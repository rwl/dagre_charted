import 'dart:math' as Math;

import 'package:graphlib/graphlib.dart';
import 'package:charted/charted.dart';
import 'package:dagre_d3/renderer.dart';
import 'package:dagre/dagre.dart';

final Map<String, Map> workers = {
  'identifier': {
    'consumers': 2,
    'count': 20
  },
  'lost-and-found': {
    'consumers': 1,
    'count': 1,
    'inputQueue': 'identifier',
    'inputThroughput': 50
  },
  'monitor': {
    'consumers': 1,
    'count': 0,
    'inputQueue': 'identifier',
    'inputThroughput': 50
  },
  'meta-enricher': {
    'consumers': 4,
    'count': 9900,
    'inputQueue': 'identifier',
    'inputThroughput': 50
  },
  'geo-enricher': {
    'consumers': 2,
    'count': 1,
    'inputQueue': 'meta-enricher',
    'inputThroughput': 50
  },
  'elasticsearch-writer': {
    'consumers': 0,
    'count': 9900,
    'inputQueue': 'geo-enricher',
    'inputThroughput': 50
  }
};

var zoom = d3.behavior.zoom();

class EtlStatusRenderer extends Renderer {

  final bool isUpdate;

  EtlStatusRenderer(this.isUpdate);

  // Extend drawNodes function to set custom ID and class on nodes
  drawNodes(graph, root) {
    var svgNodes = super.drawNodes(graph, root);
    svgNodes.attr("id", (u) {
      return "node-$u";
    });
    svgNodes.attr("class", (u) {
      return "node " + graph.node(u)['className'];
    });
    return svgNodes;
  }

  // Custom transition function
  Selection transition(Selection selection) {
    if (isUpdate) {
      return selection.transition().duration(500);
    }
    return super.transition(selection);
  }

  zoom(graph, svg) {
    return zoom.on('zoom', () {
      svg.attr('transform', 'translate(' + d3.event.translate + ')scale(' + d3.event.scale + ')');
    });
  }
}

draw(bool isUpdate) {
  var nodes = [];
  var edges = [];
  for (var id in workers.keys) {
    Map worker = workers[id];
    String className = '';
    className += worker['consumers'] != 0 ? 'running' : 'stopped';
    if (worker['count'] > 10000) {
      className += ' warn';
    }
    String html = '<div>';
    html += '<span class="status"></span>';
    html += '<span class="consumers">${worker['consumers']}</span>';
    html += '<span class="name">$id</span>';
    html += '<span class="queue"><span class="counter">${worker['count']}</span></span>';
    html += '</div>';
    nodes.add({
      'id': id,
      'value': {
        'label': html,
        'className': className
      }
    });

    if (worker.containsKey('inputQueue')) {
      final label = '${worker['inputThroughput']}/s';
      edges.add({
        'u': worker['inputQueue'],
        'v': id,
        'value': {
          'label': '<span>$label</span>'
        }
      });
    }
  }

  final renderer = new EtlStatusRenderer();
  final svg = new SelectionScope.selector("svg");

  // Extend drawNodes function to set custom ID and class on nodes
//  var oldDrawNodes = renderer.drawNodes();
//  renderer.drawNodes((graph, root) {
//    var svgNodes = oldDrawNodes(graph, root);
//    svgNodes.attr("id", (u) { return "node-" + u; });
//    svgNodes.attr("class", (u) { return "node " + graph.node(u).className; });
//    return svgNodes;
//  });

  // Custom transition function
//  transition(selection) {
//    return selection.transition().duration(500);
//  }
  //isUpdate && renderer.transition(transition);

//  renderer.zoom((graph, svg) {
//    return zoom.on('zoom', () {
//      svg.attr('transform', 'translate(' + d3.event.translate + ')scale(' + d3.event.scale + ')');
//    });
//  });

  // Left-to-right layout
  renderer.layout = new Layout()
    ..nodeSep = 70
    ..rankSep = 120
    ..rankDir = "LR";
  final renderedLayout = renderer
    .run(decode(nodes, edges), new SelectionScope.selector("svg g"));

  // Zoom and scale to fit
  var zoomScale = zoom.scale();
  final graphWidth = renderedLayout.graph()['width'] + 80;
  final graphHeight = renderedLayout.graph()['height'] + 40;
  final width = int.parse(svg.style('width').replaceAll("px", ''));
  final height = int.parse(svg.style('height').replaceAll("px", ''));
  zoomScale = Math.min(width / graphWidth, height / graphHeight);
  final translate = [(width/2) - ((graphWidth*zoomScale)/2), (height/2) - ((graphHeight*zoomScale)/2)];
  zoom.translate(translate);
  zoom.scale(zoomScale);
  zoom.event(isUpdate ? svg.transition().duration(500) : new SelectionScope.selector('svg'));
}

final r = new Math.Random();

main() {
  // Do some mock queue status updates
  setInterval(() {
    var stoppedWorker1Count = workers['elasticsearch-writer']['count'];
    var stoppedWorker2Count = workers['meta-enricher']['count'];
    for (var id in workers.keys) {
      workers[id]['count'] = (r.nextDouble() * 3).ceil();
      if (workers[id].containsKey('inputThroughput')) {
        workers[id]['inputThroughput'] = (r.nextDouble() * 250).ceil();
      }
    }
    workers['elasticsearch-writer']['count'] = stoppedWorker1Count + (r.nextDouble() * 100).ceil();
    workers['meta-enricher']['count'] = stoppedWorker2Count + (r.nextDouble() * 100).ceil();
    draw(true);
  }, 1000);

  // Do a mock change of worker configuration
  setInterval(() {
    workers['elasticsearch-monitor'] = {
      'consumers': 0,
      'count': 0,
      'inputQueue': 'elasticsearch-writer',
      'inputThroughput': 50
    };
  }, 5000);
}