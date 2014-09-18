import 'dart:math' as Math;

import 'package:graphlib/graphlib.dart';
import 'package:d3/d3.dart' as d3;
import 'package:dagre_d3/renderer.dart';
import 'package:dagre/dagre.dart';

class SentenceTokenizationRenderer extends Renderer {
  drawNodes(graph, root) {
    var svgNodes = super.drawNodes(graph, root);
    svgNodes.each((u) {
      new d3.Selection.node(this).classed(graph.node(u)['nodeclass'], true);
    });
    return svgNodes;
  }

  // Disable pan and zoom.
//  zoom(BaseGraph graph, d3.Selection svg) {}
}

main() {
  // Create the input graph
  final g = new Digraph();

  // Here we're setting nodeclass, which is used by our custom drawNodes function
  // below.
  g.addNode(0,  { 'label': 'TOP',       'nodeclass': 'type-TOP' });
  g.addNode(1,  { 'label': 'S',         'nodeclass': 'type-S' });
  g.addNode(2,  { 'label': 'NP',        'nodeclass': 'type-NP' });
  g.addNode(3,  { 'label': 'DT',        'nodeclass': 'type-DT' });
  g.addNode(4,  { 'label': 'This',      'nodeclass': 'type-TK' });
  g.addNode(5,  { 'label': 'VP',        'nodeclass': 'type-VP' });
  g.addNode(6,  { 'label': 'VBZ',       'nodeclass': 'type-VBZ' });
  g.addNode(7,  { 'label': 'is',        'nodeclass': 'type-TK' });
  g.addNode(8,  { 'label': 'NP',        'nodeclass': 'type-NP' });
  g.addNode(9,  { 'label': 'DT',        'nodeclass': 'type-DT' });
  g.addNode(10, { 'label': 'an',        'nodeclass': 'type-TK' });
  g.addNode(11, { 'label': 'NN',        'nodeclass': 'type-NN' });
  g.addNode(12, { 'label': 'example',   'nodeclass': 'type-TK' });
  g.addNode(13, { 'label': '.',         'nodeclass': 'type-.' });
  g.addNode(14, { 'label': 'sentence',  'nodeclass': 'type-TK' });

  // Set up edges, no special attributes.
  g.addEdge(null, 3, 4);
  g.addEdge(null, 2, 3);
  g.addEdge(null, 1, 2);
  g.addEdge(null, 6, 7);
  g.addEdge(null, 5, 6);
  g.addEdge(null, 9, 10);
  g.addEdge(null, 8, 9);
  g.addEdge(null, 11,12);
  g.addEdge(null, 8, 11);
  g.addEdge(null, 5, 8);
  g.addEdge(null, 1, 5);
  g.addEdge(null, 13,14);
  g.addEdge(null, 1, 13);
  g.addEdge(null, 0, 1);

  // Create the renderer
  final renderer = new SentenceTokenizationRenderer();

  // Override drawNodes to add nodeclass as a class to each node in the output
  // graph.
//  var oldDrawNodes = renderer.drawNodes();
//  renderer.drawNodes((graph, root) {
//    var svgNodes = oldDrawNodes(graph, root);
//    svgNodes.each((u) { d3.select(this).classed(graph.node(u).nodeclass, true); });
//    return svgNodes;
//  });

  // Disable pan and zoom
//  renderer.zoom(false);
  renderer.zoomEnabled = false;

  // Set up an SVG group so that we can translate the final graph.
  final svg = new d3.Selection.selector('svg'),
      svgGroup = svg.append('g');

  // Run the renderer. This is what draws the final graph.
  final layout = renderer.run(g, new d3.Selection.selector('svg g'));

  // Center the graph
  var xCenterOffset = (num.parse(svg.nodeAttr('width')) - layout.graph().width) ~/ 2;
  svgGroup.attr('transform', 'translate($xCenterOffset, 20)');
  svg.attr('height', layout.graph()['height'] + 40);
}
