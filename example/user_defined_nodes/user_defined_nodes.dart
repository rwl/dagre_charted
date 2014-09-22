
import 'package:graphlib/graphlib.dart';
import 'package:charted/charted.dart';
import 'package:dagre_charted/renderer.dart';

main() {
  // Set up an SVG group so that we can translate the final graph.
  final svg = new SelectionScope.selector('svg'),
      svgGroup = svg.select('g');

  final g = new Digraph();

  // Render the graph from left-to-right, instead of the default top-to-bottom.
  g.graph({ 'rankDir': 'LR' });

  // Set up nodes. Note the use of 'useDef' which will search for a shape
  // definition with the specified id.
  g.addNode("N0", {'label': "N0", 'useDef': "def-N0"});
  g.addNode("N1", {'label': "N1", 'useDef': "def-N1"});
  g.addNode("N2", {'label': "N2", 'useDef': "def-N2"});
  g.addNode("N3", {'label': "N3", 'useDef': "def-N3"});
  g.addNode("N4", {'label': "N4", 'useDef': "def-N4"});
  g.addNode("N5", {'label': "N5", 'useDef': "def-N5"});

  g.addEdge(null, "N0", "N1", { 'label': "N0-N1" });
  g.addEdge(null, "N0", "N2", { 'label': "N0-N2" });
  g.addEdge(null, "N1", "N2", { 'label': "N1-N2" });
  g.addEdge(null, "N2", "N3", { 'label': "N2-N3" });
  g.addEdge(null, "N3", "N0", { 'label': "N3-N0" });
  g.addEdge(null, "N3", "N4", { 'label': "N3-N4" });
  g.addEdge(null, "N4", "N5", { 'label': "N4-N5" });
  g.addEdge(null, "N5", "N0", { 'label': "N5-N0" });

  // Set up the zoom for 70%
  var initialZoom = 0.7;
  final renderer = new Renderer()..initialZoom = initialZoom;

  // Tell the layout engine to separate ranks by 70 pixels.
  renderer.layout.rankSep = 70;

//  // Set up the zoom for 70%
//  var initialZoom = 0.7;
//  var oldZoom = renderer.zoom();
//  renderer.zoom((graph, svg) {
//    var zoom = oldZoom(graph, svg);
//    zoom.scale(initialZoom).event(svg);
//    return zoom;
//  });

  // Run the renderer. This is what draws the final graph.
  var layout = renderer.run(g, svgGroup);

  // Center the graph
  var xCenterOffset = (num.parse(svg.root.attributes['width']) - layout.graph()['width'] * initialZoom) / 2;
  svgGroup.attr('transform', 'translate($xCenterOffset, 20)');
  svg.root.attributes['height'] = (layout.graph()['height'] * initialZoom + 40).toString();
}
