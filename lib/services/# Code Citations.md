# Code Citations

## License: unknown
https://github.com/LucasWerey/Steam_flutter_app/tree/1aa2e28ed5062c2a03b6df3ebc496fa2b821d4d1/steam_project/lib/screens/login_screen.dart

```
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
```


## License: unknown
https://github.com/bimalsh01/flutter_dursikshya/tree/c7a97bce735db9ef92b2a880be1630ab04f292db/lib/screens/LoginScreen.dart

```
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child
```


## License: unknown
https://github.com/yuvarajelamko/CourtSide/tree/c31838c58c79de53d58d8f2b2a4d0d0f5b041ea4/lib/pages/signin.dart

```
.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator:
```


## License: unknown
https://github.com/RafVanhoegaerden-s128965/IntroMobile/tree/d070a2642c1b978529708a732f3897cff0ac7881/parq_app/lib/views/login_view.dart

```
,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value
```


## License: unknown
https://github.com/Mkyadav4251/getx_project_oms/tree/be2bfa62f63bdd0a3d9774a639a038716ae98cd1/lib/Screens/LoginScreen.dart

```
(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
```

