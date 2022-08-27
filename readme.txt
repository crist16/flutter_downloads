Manifest Usage  
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>

USOS
Crear una instancia de la clase Downloader : 
recibe dos parametros {context}




  el boton de descargar debera llamar a la clase 

  Downloader.download()

  recibira 3 parametros : 
  El nombre del archivo, la direccion de descarga 
  
   y una funcion que dibuja el porcentaje de descarga ejm _onReceiveProgress

  void _onReceiveProgress(int? received, int? total) {
    print("Executada progreso");
    print("$received, $total");
    if (total != -1) {
      setState(() {
        _progress = (received! / total! * 100).toStringAsFixed(0) + "%";
        print(_progress);
      });
    }
  }