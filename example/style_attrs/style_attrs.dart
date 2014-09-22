
import 'package:graphlib/graphlib.dart';
import 'package:charted/charted.dart';
import 'package:dagre_charted/renderer.dart';

main() {
  // Create the input graph.
  var g = new Digraph();

  // Fill node 'A' with the color green.
  g.addNode('A', { 'label': 'A', 'style': 'fill: #afa;' });

  // Make the label for node 'B' bold.
  g.addNode('B', { 'label': 'B', 'labelStyle': 'font-weight: bold;'});

  // Double the size of the font for node 'C'.
  g.addNode('C', { 'label': 'C', 'labelStyle': 'font-size: 2em;' });

  // Make the edge from 'A' to 'B' red and thick.
  g.addEdge(null, 'A', 'B', { 'style': 'stroke: #f66; stroke-width: 3px;' });

  // Make the label for the edge from 'C' to 'B' italic and underlined.
  g.addEdge(null, 'C', 'B', {
      'label': 'A to C',
        'style': 'stroke-width: 1.5px',
          'labelStyle': 'font-style italic; text-decoration: underline;'
  });

  // Create the renderer.
  final renderer = new Renderer();

  // Disable pan / zoom for this demo.
//  renderer.zoom(false);
  renderer.zoomEnabled = false;

  // Set up an SVG group so that we can translate the final graph.
  final svg = new SelectionScope.selector('.wrapper')
    .append('svg:svg')
      ..attr('width', '960')
      ..attr('height', '600');
  final svgGroup = svg.append('g');

  // Run the renderer. This is what draws the final graph.
  var layout = renderer.run(g, svgGroup);

  // Center the graph.
  var xCenterOffset = (num.parse(svg.first.attributes['width']) - layout.graph()['width']) / 2;
  svgGroup.attr('transform', 'translate($xCenterOffset, 20)');
  svg.attr('height', layout.graph()['height'] + 40);
}
