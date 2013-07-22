requirejs.config
  baseUrl: "/src"
  paths:
    jquery: "../components/jquery/jquery"
    underscore: "../components/underscore/underscore"
    d3: "../components/d3/d3"
    jspdf: "../components/jspdf/jspdf"

  shim:
    underscore:
      exports: "_"
    d3:
      exports: "d3"
    jspdf:
      exports: "jsPDF"
      deps: ["jquery"]

requirejs ["jquery", "d3", "underscore", "jspdf", "Sketch"], ($, d3, _, jspdf, Sketch) ->
  sketch = new Sketch("#canvas")
  $(window).keydown (event) ->
    if event.keyCode == 13
      doc = sketch.toPDF()
      doc.output("datauri")
