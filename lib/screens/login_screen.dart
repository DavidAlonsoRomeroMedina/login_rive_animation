import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.3 Importar la librería para usar Timer

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  StateMachineController? _controller;

  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;

  //3.2 Timer para detener el recorrido de la mirada del oso
  Timer? _typingDebounce;

  //2.1 Crear variables para FocusNode
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode(); //¿qué es un FocusNode?
  // Que una aplicación aparezca resaltada en un campo de texto cuando el usuario hace clic en él, y que desaparezca cuando el usuario hace clic fuera del campo de texto. Para lograr esto, Flutter proporciona la clase FocusNode, que se puede usar para controlar el enfoque de los widgets de entrada de texto.

  //Crear los oyentes (listeners) para los FocusNode
  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        if (_isHandsUp != null) {
          _isHandsUp!.change(false);
          //3.3 Mirada neutral
          _numLook?.value = 50.0;
        }
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        if (_isHandsUp != null) {
          _isHandsUp!.change(true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: screenSize.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/login-bear-animation.riv',
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );

                      if (_controller == null) return;

                      artboard.addController(_controller!);

                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
                //Para separar elementos
                SizedBox(height: 10,),
                //Email
                TextField(
                  //2.3 Asignar el focus al TextField
                  focusNode: _emailFocusNode,
                  onChanged: (value) {
                    if (_isHandsUp != null) {
                      _isHandsUp!.change(false);
                    }
                    // si isChecking es null
                    if (_isChecking == null) return;
                    _isChecking!.change(true);
                    //3.4 Implementar recorrido de mirada
                    //Ajuste de límites del 00 al 100
                    //80 Medida de calibración. Clamp es un rango con límite inferior y superior. Si el valor es menor que el límite inferior, devuelve el límite inferior. Si el valor es mayor que el límite superior, devuelve el límite superior. Si el valor está dentro del rango, devuelve el valor.
                    final look = (value.length / 80.0 * 100.0).clamp(
                      0.0,
                      100.0,
                    );
                    _numLook?.value = look;

                    //3.5 Debounce: si vuelve a teclear, reinicia el contador
                    _typingDebounce?.cancel();
                    // Crear un nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      if (!mounted) return;
                      //Mirada neutra después de 3 segundos
                      _isChecking?.change(false);
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      //Para redondear los bordes
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                ),
                const SizedBox(height: 10,),
                //Password
                TextField(
                  focusNode: _passwordFocusNode,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: (){
                        //Refrescar el icono
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      )),
                    border: OutlineInputBorder(
                      //Para redondear los bordes
                      borderRadius: BorderRadius.circular(12)
                    )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    //2.4 Liberar espacio en los FocusNode
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    // Liberar timer
    _typingDebounce?.cancel();
    _controller?.dispose();
    super.dispose();
  }
}
