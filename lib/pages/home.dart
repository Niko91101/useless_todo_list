
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';



class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String _userToDo;
  List todoList = [];

  @override
  void initState() {
    super.initState();
    todoList.addAll(['Позаниматься флаттером', 'Погулять с собакой', 'Повторить']);
  }

  void _menuOpen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(title: Text('Меню'),),
          body: Row(
            children: [
              ElevatedButton(onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              }, child: const Text('На главную')),
              const Padding(padding: EdgeInsets.only(left: 40)),
              const Text('Простое меню')
            ],
          )
        );
      })
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text("Список дел"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _menuOpen,
           icon: const Icon(Icons.menu_sharp)),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('items').snapshots(),
        builder: (BuildContext context, AsyncSnapshot <QuerySnapshot> snapshot) {
          if(!snapshot.hasData) return const Text("Нет записей");
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index ) {
              return Dismissible(
                key: Key(snapshot.data!.docs[index].id), 
            // ignore: sort_child_properties_last
                child: Card(
                  child: ListTile(
                    title: Text(snapshot.data!.docs[index].get('item')),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_forever_sharp,
                        color: Colors.blueAccent,       
                      ), 
                      onPressed: () {  
                         FirebaseFirestore.instance.collection('items').doc(snapshot.data!.docs[index].id).delete();
                      },
                    ),
                  ),
                ),
                onDismissed: ((direction) {
                 FirebaseFirestore.instance.collection('items').doc(snapshot.data!.docs[index].id).delete();
                }),
              );
            }
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          showDialog(context: context, builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Добавить задачу"),
              content: TextField(
                onChanged: (String value){
                  _userToDo = value;
                },
              ),
              actions: [
                ElevatedButton(onPressed: () {
                  FirebaseFirestore.instance.collection('items').add({'item': _userToDo});
                  Navigator.of(context).pop();
                }, child: const Text('Добавить'))
              ],
            );
          });
        },
        child: const Icon(
          Icons.add_circle,
          color: Color.fromARGB(255, 242, 243, 244),
        ),
    ),
  );
  }
}
