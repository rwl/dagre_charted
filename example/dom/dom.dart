import 'dart:html';

import 'package:graphlib/graphlib.dart';
import 'package:charted/charted.dart';
import 'package:dagre_charted/renderer.dart';

/**
 * A sample showing how to use DOM nodes in a graph. Note that IE does not
 * support this technique.
 */
main() {
  // Create a new directed graph.
  final g = new Digraph();

  g.addNode("root", {
    'label': () {
      var table = document.createElement("table"),
          tr = new SelectionScope.element(table).append("tr");
      tr.append("td").text("A");
      tr.append("td").text("B");
      return table;
    }
  });
  g.addNode("A", { 'label': "A", 'fill': "#afa" });
  g.addNode("B", { 'label': "B", 'fill': "#faa" });
  g.addEdge(null, "root", "A");
  g.addEdge(null, "root", "B");

  // Create the renderer.
  final renderer = new Renderer();

  // Set up an SVG group so that we can translate the final graph.
  final svg = new SelectionScope.selector('svg'),
      svgGroup = svg.append('g');

  // Run the renderer. This is what draws the final graph.
  final layout = renderer.run(g, svgGroup);

  // Center the graph.
  var xCenterOffset = (int.parse(svg.attr('width')) - layout.graph()['width']) ~/ 2;
  svgGroup.attr('transform', 'translate($xCenterOffset, 20)');
  svg.attr('height', layout.graph()['height'] + 40);
}
