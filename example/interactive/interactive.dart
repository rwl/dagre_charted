import 'dart:math' as Math;
import 'dart:html' show document, window;

import 'package:graphlib/graphlib.dart';
import 'package:graphlib_dot/graphlib_dot.dart' as dot;
import 'package:charted/charted.dart';
import 'package:dagre_d3/renderer.dart';
import 'package:dagre/dagre.dart';


class InteractiveRenderer extends Renderer {
  final debugAlignment;
  InteractiveRenderer(this.debugAlignment);

  postLayout(graph, _) {
    if (debugAlignment) {
      // First find necessary delta...
      var minX = graph.nodes().map((u) {
        var value = graph.node(u);
        return value[debugAlignment] - value.width / 2;
      }).reduce(Math.min);

      // Update node positions
      graph.eachNode((u, value) {
        value.x = value[debugAlignment] - minX;
      });

      // Update edge positions
      graph.eachEdge((e, u, v, value) {
        value.points.forEach((p) {
          p.x = p[debugAlignment] - minX;
        });
      });
    }
  }

  Selection transition(Selection selection) {
    return selection.transition().duration(500);
  }
}

class InteractiveDemo {
  var inputGraph = document.querySelector("#inputGraph");
  var debugAlignment;

  var graphLink = new SelectionScope.selector("#graphLink");

  var oldInputGraphValue;

  InteractiveDemo() {
    final graphRE = new RegExp(r"[?&]graph=([^&]+)");
    final graphMatch = graphRE.firstMatch(window.location.search);
    if (graphMatch) {
      inputGraph.value = decodeURIComponent(graphMatch[1]);
    }
    final debugAlignmentRE = new RegExp(r"[?&]alignment=([^&]+)");
    final debugAlignmentMatch = debugAlignmentRE.firstMatch(window.location.search);
    if (debugAlignmentMatch) {
      debugAlignment = debugAlignmentMatch[1];
    }
  }

  tryDraw([bool firstRun=false]) {
    var result;
    if (oldInputGraphValue != inputGraph.value) {
      inputGraph.setAttribute("class", "");
      oldInputGraphValue = inputGraph.value;
      try {
        result = dot.parse(inputGraph.value);
      } catch (e) {
        inputGraph.setAttribute("class", "error");
        throw e;
      }

      if (result) {
        // Save link to new graph
        graphLink.attr("href", graphToURL());

        // Cleanup old graph
        var svg = new SelectionScope.selector("svg");

        var renderer = new InteractiveRenderer(debugAlignment);

        // Handle debugAlignment
  //        renderer.postLayout((graph) {
  //          if (debugAlignment) {
  //            // First find necessary delta...
  //            var minX = Math.min.apply(null, graph.nodes().map((u) {
  //              var value = graph.node(u);
  //              return value[debugAlignment] - value.width / 2;
  //            }));
  //
  //            // Update node positions
  //            graph.eachNode((u, value) {
  //              value.x = value[debugAlignment] - minX;
  //            });
  //
  //            // Update edge positions
  //            graph.eachEdge((e, u, v, value) {
  //              value.points.forEach((p) {
  //                p.x = p[debugAlignment] - minX;
  //              });
  //            });
  //          }
  //        });

        // Uncomment the following line to get straight edges
        //renderer.edgeInterpolate('linear');

  //        // Custom transition function
  //        transition(selection) {
  //          return selection.transition().duration(500);
  //        }

  //        renderer.transition(transition);

        var layout = renderer.run(result, svg.select("g"));

        (firstRun ? svg : svg.transition().duration(500))
          .attr("width", layout.graph()['width'] + 40)
          .attr("height", layout.graph()['height'] + 40);
      }
    }
  }

  graphToURL() {
    var elems = [window.location.protocol, '//',
                 window.location.host,
                 window.location.pathname,
                 '?'];

    var queryParams = [];
    if (debugAlignment) {
      queryParams.add('alignment=' + debugAlignment);
    }
    queryParams.add('graph=' + encodeURIComponent(inputGraph.value));
    elems.add(queryParams.join('&'));

    return elems.join('');
  }
}