var blopString = "blop";
var blop = new Blob([blopString], { type: "application/x.openblock.ob" });
var url = URL.createObjectURL(blop);
console.log(url);
