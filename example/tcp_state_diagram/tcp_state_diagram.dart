import 'dart:math' as Math;

import 'package:graphlib/graphlib.dart';
import 'package:charted/charted.dart';
import 'package:dagre_d3/renderer.dart';
import 'package:dagre/dagre.dart';

//class TcpStateDiagramRenderer extends Renderer {
//  final double initialScale;
//  TcpStateDiagramRenderer(this.initialScale);
//  zoom(graph, svg) {
//    var zoom = super.zoom(graph, svg);
//
//    // We must set the zoom and then trigger the zoom event to
//    // synchronize D3 and the DOM.
//    zoom.scale(initialScale).event(svg);
//    return zoom;
//  }
//}

main() {
  // States and transitions from RFC 793
  var states = [ "LISTEN", "SYN RCVD", "SYN SENT",
                 "FINWAIT-1", "CLOSE WAIT", "FINWAIT-2",
                 "CLOSING", "LAST-ACK", "TIME WAIT" ]
           .map((s) {
              return { 'id': s, 'value': { 'label': s } };
           });

  // Push a couple of states with custom styles
  states.unshift({ 'id': 'CLOSED', 'value': { 'label': 'CLOSED', 'style': 'fill: #f77' } });
  states.add({ 'id': 'ESTAB', 'value': { 'label': 'ESTAB', 'style': 'fill: #7f7' } });

  var edges = [
    { 'u': "CLOSED",     'v': "LISTEN",     'value': { 'label': "open" } },
    { 'u': "LISTEN",     'v': "SYN RCVD",   'value': { 'label': "rcv SYN" } },
    { 'u': "LISTEN",     'v': "SYN SENT",   'value': { 'label': "send" } },
    { 'u': "LISTEN",     'v': "CLOSED",     'value': { 'label': "close" } },
    { 'u': "SYN RCVD",   'v': "FINWAIT-1",  'value': { 'label': "close" } },
    { 'u': "SYN RCVD",   'v': "ESTAB",      'value': { 'label': "rcv ACK of SYN" } },
    { 'u': "SYN SENT",   'v': "SYN RCVD",   'value': { 'label': "rcv SYN" } },
    { 'u': "SYN SENT",   'v': "ESTAB",      'value': { 'label': "rcv SYN, ACK" } },
    { 'u': "SYN SENT",   'v': "CLOSED",     'value': { 'label': "close" } },
    { 'u': "ESTAB",      'v': "FINWAIT-1",  'value': { 'label': "close" } },
    { 'u': "ESTAB",      'v': "CLOSE WAIT", 'value': { 'label': "rcv FIN" } },
    { 'u': "FINWAIT-1",  'v': "FINWAIT-2",  'value': { 'label': "rcv ACK of FIN" } },
    { 'u': "FINWAIT-1",  'v': "CLOSING",    'value': { 'label': "rcv FIN" } },
    { 'u': "CLOSE WAIT", 'v': "LAST-ACK",   'value': { 'label': "close" } },
    { 'u': "FINWAIT-2",  'v': "TIME WAIT",  'value': { 'label': "rcv FIN" } },
    { 'u': "CLOSING",    'v': "TIME WAIT",  'value': { 'label': "rcv ACK of FIN" } },
    { 'u': "LAST-ACK",   'v': "CLOSED",     'value': { 'label': "rcv ACK of FIN" } },
    { 'u': "TIME WAIT",  'v': "CLOSED",     'value': { 'label': "timeout=2MSL" } }
  ];

  // Create a graph from the JSON
  var g = decode(states, edges);

  // Set initial zoom to 75%
  var initialScale = 0.75;
  //var renderer = new TcpStateDiagramRenderer(initialScale);
  final renderer = new Renderer()..initialZoom = initialScale;

  // Set up an SVG group so that we can translate the final graph.
  var svg = new SelectionScope.selector('svg'),
      svgGroup = svg.append('g');

//  var oldZoom = renderer.zoom();
//  renderer.zoom((graph, svg) {
//    var zoom = oldZoom(graph, svg);
//
//    // We must set the zoom and then trigger the zoom event to synchronize
//    // D3 and the DOM.
//    zoom.scale(initialScale).event(svg);
//    return zoom;
//  });

  // Run the renderer. This is what draws the final graph.
  final layout = renderer.run(g, svgGroup);

  // Center the graph.
  var xCenterOffset = (num.parse(svg.attr('width')) - layout.graph()['width'] * initialScale) ~/ 2;
  svgGroup.attr('transform', 'translate($xCenterOffset, 20)');
  svg.attr('height', layout.graph()['height'] * initialScale + 40);
}
