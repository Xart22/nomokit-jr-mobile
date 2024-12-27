let cvs = document.getElementById("stage-canvas");

const downloader = (url) => {
  var xhr = new XMLHttpRequest();
  xhr.open("GET", url, true);
  xhr.responseType = "blob";
  xhr.onload = function (e) {
    if (this.status == 200) {
      var blob = this.response;
      var reader = new FileReader();
      reader.readAsDataURL(blob);
      reader.onloadend = function () {
        var base64data = reader.result;
        var base64ContentArray = base64data.split(",");
        var mimeType = base64ContentArray[0].match(
          /[^:\s*]\w+\/[\w-+\d.]+(?=[;| ])/
        )[0];
        var decodedFile = base64ContentArray[1];
        window.flutter_inappwebview.callHandler(
          "saveCanvas",
          decodedFile,
          mimeType
        );
      };
    }
  };
  xhr.send();
};

downloader(cvs.toDataURL("image/png"));
