import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _controller;
  @override
  void initState(){
    _controller=TextEditingController();
    super.initState();
  }
  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context)=>CounterBloc(),
      child: Scaffold(
      appBar: AppBar(title: const Text('Testing Bloc'),
    ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context,state){
            _controller.clear();
          },
          builder: (context,state){
            final invalidValue=(state is CounterStateInvalidNumber)
                ?  state.invalidValue:'';
            return Column(
              children: [
                Text('Current Value => ${state.value}'),
                Visibility(
                    child: Text('Invalid input :$invalidValue'),
                  visible: state is CounterStateInvalidNumber,
                ),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Enter a number here'
                  ),
                ),
                Row(
                  children: [
                   TextButton(
                       onPressed:(){
                         context.read<CounterBloc>().add(DecrementEvent(_controller.text));
                       },
                       child: const Text('-')
                   ),
                    TextButton(
                        onPressed:(){
                          context.read<CounterBloc>().add(IncrementEvent(_controller.text));
                        },
                        child: const Text('+')
                    ),
                  ],
                )
              ],
            );
          },
        ),
      )
    );
  }
}


abstract class CounterState{
  final int value;
  CounterState(this.value);
}

class CounterStateValid extends CounterState{
   CounterStateValid(int value) : super(value);
}

class CounterStateInvalidNumber extends CounterState {
  final String invalidValue;

  CounterStateInvalidNumber({
    required this.invalidValue,
    required int previousValue,
  }) :super(previousValue);
}

abstract class CounterEvent{
  final String value;
  CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent{
  IncrementEvent(String value):super(value);
}

class DecrementEvent extends CounterEvent{
  DecrementEvent(String value):super(value);
}

class CounterBloc extends Bloc<CounterEvent,CounterState>{
  CounterBloc():super(CounterStateValid(0)){
    on<IncrementEvent>((event,emit){
      final integer=int.tryParse(event.value);
      if(integer==null){
        emit(CounterStateInvalidNumber(
            invalidValue: event.value,
            previousValue: state.value)
        );
      }else{
        emit(CounterStateValid(state.value+integer));
      }
    });
    on<DecrementEvent>((event,emit){
      final integer=int.tryParse(event.value);
      if(integer==null){
        emit(CounterStateInvalidNumber(
            invalidValue: event.value,
            previousValue: state.value)
        );
      }else{
        emit(CounterStateValid(state.value-integer));
      }
    });
  }
}