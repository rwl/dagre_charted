library dagre.d3;

import 'dart:html' show Element, window;
import 'dart:math' as Math;
import 'dart:svg' as svg;

import 'package:graphlib/graphlib.dart';
import 'package:dagre/src/dagre.dart';
import 'package:d3/d3.dart' as d3;

//var layout = require('dagre').layout;
//
//var d3;
//try { d3 = require('d3'); } catch (_) { d3 = window.d3; }
//
//module.exports = Renderer;

class Renderer {
  // Set up defaults...
  final layout = new Layout();

  String edgeInterpolate = 'bundle';

  double edgeTension = 0.95;

  bool zoomEnabled = true;

  double initialZoom = 1.0;

  Renderer() {
//    this.drawNodes(defaultDrawNodes);
//    this.drawEdgeLabels(defaultDrawEdgeLabels);
//    this.drawEdgePaths(defaultDrawEdgePaths);
//    this.positionNodes(defaultPositionNodes);
//    this.positionEdgeLabels(defaultPositionEdgeLabels);
//    this.positionEdgePaths(defaultPositionEdgePaths);
//    this.zoomSetup(defaultZoomSetup);
//    this.zoom(defaultZoom);
//    this.transition(defaultTransition);
//    this.postLayout(defaultPostLayout);
//    this.postRender(defaultPostRender);

//    this.edgeInterpolate('bundle');
//    this.edgeTension(0.95);
  }

  /*layout(layout) {
    if (!arguments.length) { return this._layout; }
    this._layout = layout;
    return this;
  }*/

//  drawNodes(drawNodes) {
//    if (!arguments.length) { return this._drawNodes; }
//    this._drawNodes = bind(drawNodes, this);
//    return this;
//  }
//
//  drawEdgeLabels(drawEdgeLabels) {
//    if (!arguments.length) { return this._drawEdgeLabels; }
//    this._drawEdgeLabels = bind(drawEdgeLabels, this);
//    return this;
//  }
//
//  drawEdgePaths(drawEdgePaths) {
//    if (!arguments.length) { return this._drawEdgePaths; }
//    this._drawEdgePaths = bind(drawEdgePaths, this);
//    return this;
//  }
//
//  positionNodes(positionNodes) {
//    if (!arguments.length) { return this._positionNodes; }
//    this._positionNodes = bind(positionNodes, this);
//    return this;
//  }
//
//  positionEdgeLabels(positionEdgeLabels) {
//    if (!arguments.length) { return this._positionEdgeLabels; }
//    this._positionEdgeLabels = bind(positionEdgeLabels, this);
//    return this;
//  }
//
//  positionEdgePaths(positionEdgePaths) {
//    if (!arguments.length) { return this._positionEdgePaths; }
//    this._positionEdgePaths = bind(positionEdgePaths, this);
//    return this;
//  }

//  transition(transition) {
//    if (!arguments.length) { return this._transition; }
//    this._transition = bind(transition, this);
//    return this;
//  }

//  zoomSetup(zoomSetup) {
//    if (!arguments.length) { return this._zoomSetup; }
//    this._zoomSetup = bind(zoomSetup, this);
//    return this;
//  }
//
//  zoom(zoom) {
//    if (!arguments.length) { return this._zoom; }
//    if (zoom) {
//      this._zoom = bind(zoom, this);
//    } else {
//      this.remove(_zoom);
//    }
//    return this;
//  }

//  postLayout(postLayout) {
//    if (!arguments.length) { return this._postLayout; }
//    this._postLayout = bind(postLayout, this);
//    return this;
//  }
//
//  postRender(postRender) {
//    if (!arguments.length) { return this._postRender; }
//    this._postRender = bind(postRender, this);
//    return this;
//  }

  /*edgeInterpolate(edgeInterpolate) {
    if (!arguments.length) { return this._edgeInterpolate; }
    this._edgeInterpolate = edgeInterpolate;
    return this;
  }

  edgeTension(edgeTension) {
    if (!arguments.length) { return this._edgeTension; }
    this._edgeTension = edgeTension;
    return this;
  }*/

  d3.Selection drawNodes(BaseGraph g, d3.Selection root) {
    final nodes = g.nodes().where((u) { return !isComposite(g, u); });

    final svgNodes = root
      .selectAll('g.node')
      ..classed('enter', false)
      ..data(nodes, (_, u, i) { return u; });

    svgNodes.selectAll('*').remove();

    svgNodes
      .enter()
        .append('g')
          ..style('opacity', 0)
          ..attr('class', 'node enter');

    svgNodes.each((Element node, Object u, int i, int j) {
      final attrs = g.node(u),
          domNode = new d3.Selection.node(node);
      addLabel(attrs, domNode, true, 10, 10);
    });

    this.transition(svgNodes.exit())
        .style('opacity', 0)
        .remove();

    return svgNodes;
  }

  d3.Selection drawEdgeLabels(BaseGraph g, d3.Selection root) {
    d3.Selection svgEdgeLabels = root
      .selectAll('g.edgeLabel')
      ..classed('enter', false)
      ..data(g.edges(), (_, e, i) { return e; });

    svgEdgeLabels.selectAll('*').remove();

    svgEdgeLabels
      .enter()
        .append('g')
          ..style('opacity', 0)
          ..attr('class', 'edgeLabel enter');

    svgEdgeLabels.each((Element node, Object e, int i, int j) {
      addLabel(g.edge(e), new d3.Selection.node(node), false, 0, 0);
    });

    this.transition(svgEdgeLabels.exit())
        ..style('opacity', 0)
        ..remove();

    return svgEdgeLabels;
  }

  Object drawEdgePaths(BaseGraph g, d3.Selection root) {
    d3.Selection svgEdgePaths = root
      .selectAll('g.edgePath')
      ..classed('enter', false)
      ..data(g.edges(), (n, e, i) { return e; });

    const DEFAULT_ARROWHEAD = 'url(#arrowhead)';
    var createArrowhead = DEFAULT_ARROWHEAD;
    if (!g.isDirected()) {
      createArrowhead = null;
    } else if (g.graph()['arrowheadFix'] != 'false' && g.graph()['arrowheadFix'] != false) {
      createArrowhead = (Element node, Object data, int i, int j) {
        var strokeColor = new d3.Selection.node(node).nodeStyle('stroke');
        if (strokeColor) {
          var id = 'arrowhead-' + strokeColor.replaceAll(r"[^a-zA-Z0-9]"/*g*/, '_');
          getOrMakeArrowhead(root, id).style('fill', strokeColor);
          return 'url(#' + id + ')';
        }
        return DEFAULT_ARROWHEAD;
      };
    }

    svgEdgePaths
      .enter()
        .append('g')
          .attr('class', 'edgePath enter')
          .append('path')
            .style('opacity', 0);

    svgEdgePaths
      .selectAll('path')
      ..each((Element node, Object e, int i, int j) {
        applyStyle(g.edge(e).style, new d3.Selection.node(node));
      })
      ..attr('marker-end', createArrowhead);

    this.transition(svgEdgePaths.exit())
        ..style('opacity', 0)
        ..remove();

    return svgEdgePaths;
  }

  void positionNodes(BaseGraph g, d3.Selection svgNodes) {
    transform(Element node, Object u, int i, int j) {
      Map value = g.node(u);
      return 'translate(${value['x']},${value['y']})';
    }

    // For entering nodes, position immediately without transition
    svgNodes.filter('.enter').attr('transform', transform);

    this.transition(svgNodes)
        ..style('opacity', 1)
        ..attrFunc('transform', transform);
  }

  void positionEdgeLabels(BaseGraph g, d3.Selection svgEdgeLabels) {
    transform(Element node, Object e, int i, int j) {
      var value = g.edge(e);
      var point = findMidPoint(value.points);
      return 'translate(${point.x},${point.y})';
    }

    // For entering edge labels, position immediately without transition

    svgEdgeLabels.filter('.enter').attr('transform', transform);
    this.transition(svgEdgeLabels)
      ..style('opacity', 1)
      ..attrFunc('transform', transform);
  }

  void positionEdgePaths(BaseGraph g, d3.Selection svgEdgePaths, d3.Selection root) {
    final interpolate = this.edgeInterpolate,
        tension = this.edgeTension;

    calcPoints(Element node, Object e, int i, int j) {
      Map value = g.edge(e);
      Map source = g.node(g.incidentNodes(e)[0]);
      Map target = g.node(g.incidentNodes(e)[1]);
      List points = value['points'].toList();

      var p0 = points.length == 0 ? target : points[0];
      var p1 = points.length == 0 ? source : points[points.length - 1];

      points.insert(0, intersectNode(source, p0, root));
      points.add(intersectNode(target, p1, root));

      return (new d3.Line()
        ..x = (d) { return d.x; }
        ..y = (d) { return d.y; }
        ..interpolate = interpolate
        ..tension = tension)
        .line(points);
    }

    svgEdgePaths.filter('.enter').selectAll('path')
        .attrFunc('d', calcPoints);

    this.transition(svgEdgePaths.selectAll('path'))
        ..attr('d', calcPoints)
        ..style('opacity', 1);
  }

  // By default we do not use transitions
  d3.Selection transition(d3.Selection selection) {
    return selection;
  }

  // Setup dom for zooming
  d3.Selection zoomSetup(BaseGraph graph, d3.Selection svg) {
    d3.Selection root = svg.property('ownerSVGElement');
    // If the svg node is the root, we get null, so set to svg.
    if (root == null) {
      root = svg;
    } else {
      root = new d3.Selection.node(root);
    }

    if (root.select('rect.overlay').empty()) {
      // Create an overlay for capturing mouse events that don't touch foreground
      root.insert('rect', ':first-child')
        ..attr('class', 'overlay')
        ..attr('width', '100%')
        ..attr('height', '100%')
        ..style('fill', 'none')
        ..style('pointer-events', 'all');

      // Capture the zoom behaviour from the svg
      svg = svg.append('g')
        ..attr('class', 'zoom');

      //if (this._zoom) {
        //root.call(this._zoom(graph, svg));
        this._zoom(root, graph, svg);
      //}
    }

    return svg;
  }

  _zoom(d3.Selection root, BaseGraph g, d3.Selection svg) {
    // Do nothing
  }

  // By default allow pan and zoom.
  zoom(BaseGraph graph, d3.Selection svg) {
    if (zoomEnabled) {
      var z = d3.behavior.zoom().on('zoom', () {
        svg.attr('transform', 'translate(${d3.event.translate})scale(${d3.event.scale})');
      });
      z.scale(initialZoom).event(svg);
    }
  }

  postLayout(BaseGraph g, d3.Selection svg) {
    // Do nothing
  }

  postRender(graph, root) {
    if (graph.isDirected()) {
      // Fill = #333 is for backwards compatibility
      getOrMakeArrowhead(root, 'arrowhead')
        .attr('fill', '#333');
    }
  }

  addLabel(Map node, d3.Selection root, bool addingNode, num marginX, num marginY) {
    // If the node has 'useDef' meta data, we rely on that
    if (node.containsKey('useDef')) {
      root.append('use').attr('xlink:href', '#${node['useDef']}');
      return;
    }
    // Add the rect first so that it appears behind the label
    var label = node['label'];
    d3.Selection rect = root.append('rect');
    if (node.containsKey('width')) {
      rect.attr('width', node['width']);
    }
    if (node.containsKey('height')) {
      rect.attr('height', node['height']);
    }

    d3.Selection labelSvg = root.append('g'),
        innerLabelSvg;

    // Allow the label to be a string, a function that returns a DOM element, or
    // a DOM element itself.
    if (label is String) {
      if (label[0] == '<') {
        addForeignObjectLabel(label, labelSvg);
        // No margin for HTML elements
        marginX = marginY = 0;
      } else {
        innerLabelSvg = addTextLabel(label,
                                     labelSvg,
                                     node['labelCols'].floor(),
                                     node['labelCut']);
        applyStyle(node['labelStyle'], innerLabelSvg);
      }
    } else if (label is Function) {
      addForeignObjectElementFunction(label, labelSvg);
      // No margin for HTML elements
      marginX = marginY = 0;
    } else if (label is Map) {
      addForeignObjectElement(label, labelSvg);
      // No margin for HTML elements
      marginX = marginY = 0;
    }

    final labelBBox = labelSvg.node.getBBox();
    labelSvg.attr('transform',
                  'translate(${-labelBBox.width / 2},${-labelBBox.height / 2})');

    final bbox = root.node.getBBox();

    rect
      ..attr('rx', node.containsKey('rx') ? node['rx'] : 5)
      ..attr('ry', node.containsKey('ry') ? node['ry'] : 5)
      ..attr('x', -(bbox.width / 2 + marginX))
      ..attr('y', -(bbox.height / 2 + marginY))
      ..attr('width', bbox.width + 2 * marginX)
      ..attr('height', bbox.height + 2 * marginY)
      ..attr('fill', '#fff');

    if (addingNode) {
      applyStyle(node['style'], rect);

      if (node.containsKey('fill')) {
        rect.style('fill', node['fill']);
      }

      if (node.containsKey('stroke')) {
        rect.style('stroke', node['stroke']);
      }

      if (node.containsKey('stroke-width')) {
        rect.style('stroke-width', node['stroke-width'] + 'px');
      }

      if (node.containsKey('stroke-dasharray')) {
        rect.style('stroke-dasharray', node['stroke-dasharray']);
      }

      if (node.containsKey('href')) {
        root
          ..attr('class', root.nodeAttr('class') + ' clickable')
          ..on('click', () {
            window.open(node['href']);
          });
      }
    }
  }

  void addForeignObject(modifier(d3.Selection e), d3.Selection root) {
    final fo = root
      .append('foreignObject')
        ..attr('width', '100000');

    final div = fo
      .append('xhtml:div')
        ..style('float', 'left');

    modifier(div);

    // TODO find a better way to get dimensions for foreignObjects...
    int w, h;
    div
      .each((Element node, Object e, int i, int j) {
        w = node.clientWidth;
        h = node.clientHeight;
      });

    fo
      .attr('width', w)
      .attr('height', h);
  }

  addForeignObjectLabel(String label, d3.Selection root) {
    addForeignObject((d3.Selection e) {
      e.htmlFunc((n, d, i, j) { return label; });
    }, root);
  }

  addForeignObjectElementFunction(Function elemFunc, d3.Selection root) {
    addForeignObject((d3.Selection e) {
      e.insert(elemFunc);
    }, root);
  }

  addForeignObjectElement(Map elem, d3.Selection root) {
    addForeignObjectElementFunction(() {
      return elem;
    }, root);
  }

  d3.Selection addTextLabel(String label, d3.Selection root, num labelCols, bool labelCut) {
    if (labelCut == null) {
      labelCut = 'false';
    }
    labelCut = (labelCut.toString().toLowerCase() == 'true');

    final node = root
      .append('text')
      ..attr('text-anchor', 'left');

    label = label.replaceAll(r"\\n"/*g*/, '\n');

    var arr = labelCols != null ? wordwrap(label, labelCols, labelCut) : label;
    arr = arr.split('\n');
    for (var i = 0; i < arr.length; i++) {
      node
        .append('tspan')
          ..attr('dy', '1em')
          ..attr('x', '1')
          ..text(arr[i]);
    }

    return node;
  }

  BaseGraph run(BaseGraph graph, d3.Selection orgSvg) {
    // First copy the input graph so that it is not changed by the rendering
    // process.
    graph = copyAndInitGraph(graph);

    // Create zoom elements.
    final svg = zoomSetup(graph, orgSvg);

    // Create layers
    svg
      .selectAll('g.edgePaths, g.edgeLabels, g.nodes')
      .data(['edgePaths', 'edgeLabels', 'nodes'])
      .enter()
        ..append('g')
        ..attr('class', (d) { return d; });

    // Create node and edge roots, attach labels, and capture dimension
    // information for use with layout.
    final svgNodes = drawNodes(graph, svg.select('g.nodes'));
    final svgEdgeLabels = drawEdgeLabels(graph, svg.select('g.edgeLabels'));

    svgNodes.each((Element node, Object u, int i, int j) {
      calculateDimensions(this, graph.node(u));
    });
    svgEdgeLabels.each((Element node, Object e, int i, int j) {
      calculateDimensions(this, graph.edge(e));
    });

    // Now apply the layout function
    BaseGraph result = runLayout(graph, layout);

    // Copy useDef attribute from input graph to output graph
    graph.eachNode((u, Map a) {
      if (a.containsKey('useDef')) {
        result.node(u)['useDef'] = a['useDef'];
      }
    });

    // Run any user-specified post layout processing
    postLayout(result, svg);

    final svgEdgePaths = drawEdgePaths(graph, svg.select('g.edgePaths'));

    // Apply the layout information to the graph
    positionNodes(result, svgNodes);
    positionEdgeLabels(result, svgEdgeLabels);
    positionEdgePaths(result, svgEdgePaths, orgSvg);

    postRender(result, svg);

    return result;
  }
}

BaseGraph copyAndInitGraph(BaseGraph graph) {
  final copy = graph.copy();

  if (copy.graph() == null) {
    copy.graph({});
  }

  if (!(copy.graph().containsKey('arrowheadFix'))) {
    copy.graph()['arrowheadFix'] = true;
  }

  // Init labels if they were not present in the source graph.
  copy.nodes().forEach((u) {
    final value = copyObject(copy.node(u));
    copy.node(u, value);
    if (!(value.containsKey('label'))) {
      value['label'] = '';
    }
  });

  copy.edges().forEach((e) {
    var value = copyObject(copy.edge(e));
    copy.edge(e, value);
    if (!(value.containsKey('label'))) {
      value['label'] = '';
    }
  });

  return copy;
}

Map copyObject(Map obj) {
  var copy = {};
  for (var k in obj.keys) {
    copy[k] = obj[k];
  }
  return copy;
}

calculateDimensions(Element group, Map value) {
  var bbox = group.getBBox();
  value['width'] = bbox.width;
  value['height'] = bbox.height;
}

BaseGraph runLayout(BaseGraph graph, Layout layout) {
  final result = layout.run(graph);

  // Copy labels to the result graph.
  graph.eachNode((u, Map value) {
    result.node(u)['label'] = value['label'];
  });
  graph.eachEdge((e, u, v, Map value) {
    result.edge(e)['label'] = value['label'];
  });

  return result;
}

isEllipse(obj) {
  //return Object.prototype.toString.call(obj) == '[object SVGEllipseElement]';
  return obj is svg.EllipseElement;
}

isCircle(obj) {
  //return Object.prototype.toString.call(obj) == '[object SVGCircleElement]';
  return obj is svg.CircleElement;
}

isPolygon(obj) {
  //return Object.prototype.toString.call(obj) == '[object SVGPolygonElement]';
  return obj is svg.PolygonElement;
}

intersectNode(Map nd, p1, d3.Selection root) {
  if (nd.containsKey('useDef')) {
    var definedFig = root.select("defs #${nd['useDef']}").node;
    if (definedFig != null) {
      var outerFig = definedFig.childNodes[0];
      if (isCircle(outerFig) || isEllipse(outerFig)) {
        return intersectEllipse(nd, outerFig, p1);
      } else if (isPolygon(outerFig)) {
        return intersectPolygon(nd, outerFig, p1);
      }
    }
  }
  // TODO: use bpodgursky's shortening algorithm here
  return intersectRect(nd, p1);
}


d3.Selection getOrMakeArrowhead(d3.Selection root, id) {
  d3.Selection search = root.select('#$id');
  if (!search.empty()) { return search; }

  d3.Selection defs = root.select('defs');
  if (defs.empty()) {
    defs = root.append('svg:defs');
  }

  final marker =
    defs
      .append('svg:marker')
        ..attr('id', id)
        ..attr('viewBox', '0 0 10 10')
        ..attr('refX', 8)
        ..attr('refY', 5)
        ..attr('markerUnits', 'strokeWidth')
        ..attr('markerWidth', 8)
        ..attr('markerHeight', 5)
        ..attr('orient', 'auto');

  marker
    .append('svg:path')
      ..attr('d', 'M 0 0 L 10 5 L 0 10 z');

  return marker;
}

// Thanks to
// http://james.padolsey.com/javascript/wordwrap-for-javascript/
String wordwrap(String str, [num width=75, bool cut=false, String brk='\n']) {
  if (str == null || str.length == 0) { return str; }

  var regex = r'.{1,' + width.toString() + r'}(\\s|$)' +
      (cut ? r'|.{' + width.toString() + r'}|.+$' : r'|\\S+?(\\s|$)');

  return new RegExp(regex).allMatches(str).map((Match m) {
    return m.group(0);
  }).join(brk);
}

Map findMidPoint(List points) {
  var midIdx = points.length / 2;
  if (points.length % 2 != 0) {
    return points[(midIdx).floor()];
  } else {
    var p0 = points[midIdx - 1];
    var p1 = points[midIdx];
    return {'x': (p0.x + p1.x) / 2, 'y': (p0.y + p1.y) / 2};
  }
}

intersectRect(Map rect, Math.Point point) {
  final x = rect['x'];
  final y = rect['y'];

  // Rectangle intersection algorithm from:
  // http://math.stackexchange.com/questions/108113/find-edge-between-two-boxes
  final dx = point.x - x;
  final dy = point.y - y;
  num w = rect['width'] / 2;
  num h = rect['height'] / 2;

  num sx, sy;
  if (dy.abs() * w > dx.abs() * h) {
    // Intersection is top or bottom of rect.
    if (dy < 0) {
      h = -h;
    }
    sx = dy == 0 ? 0 : h * dx / dy;
    sy = h;
  } else {
    // Intersection is left or right of rect.
    if (dx < 0) {
      w = -w;
    }
    sx = w;
    sy = dx == 0 ? 0 : w * dy / dx;
  }

  return {'x': x + sx, 'y': y + sy};
}

intersectEllipse(Map node, Element ellipseOrCircle, Math.Point point) {
  // Formulae from: http://mathworld.wolfram.com/Ellipse-LineIntersection.html

  final cx = node['x'];
  final cy = node['y'];
  num rx, ry;

  if (isCircle(ellipseOrCircle)) {
    rx = ry = ellipseOrCircle.r.baseVal.value;
  } else {
    rx = ellipseOrCircle.rx.baseVal.value;
    ry = ellipseOrCircle.ry.baseVal.value;
  }

  final px = cx - point.x;
  final py = cy - point.y;

  final det = Math.sqrt(rx * rx * py * py + ry * ry * px * px);

  num dx = (rx * ry * px / det).abs();
  if (point.x < cx) {
    dx = -dx;
  }
  var dy = (rx * ry * py / det).abs();
  if (point.y < cy) {
    dy = -dy;
  }

  return {'x': cx + dx, 'y': cy + dy};
}

bool sameSign(num r1, num r2) {
  return r1 * r2 > 0;
}

// Add point to the found intersections, but check first that it is unique.
void addPoint(num x, num y, List intersections) {
  if (!intersections.any((elm) { return elm[0] == x && elm[1] == y; })) {
    intersections.add([x, y]);
  }
}

void intersectLine(num x1, num y1, num x2, num y2, num x3, num y3, num x4, num y4, List intersections) {
  // Algorithm from J. Avro, (ed.) Graphics Gems, No 2, Morgan Kaufmann, 1994, p7 and p473.

//  var a1, a2, b1, b2, c1, c2;
//  var r1, r2 , r3, r4;
//  var denom, offset, num;
//  var x, y;

  // Compute a1, b1, c1, where line joining points 1 and 2 is F(x,y) = a1 x + b1 y + c1 = 0.
  final a1 = y2 - y1;
  final b1 = x1 - x2;
  final c1 = (x2 * y1) - (x1 * y2);

  // Compute r3 and r4.
  final r3 = ((a1 * x3) + (b1 * y3) + c1);
  final r4 = ((a1 * x4) + (b1 * y4) + c1);

  // Check signs of r3 and r4. If both point 3 and point 4 lie on
  // same side of line 1, the line segments do not intersect.
  if ((r3 != 0) && (r4 != 0) && sameSign(r3, r4)) {
    return /*DONT_INTERSECT*/;
  }

  // Compute a2, b2, c2 where line joining points 3 and 4 is G(x,y) = a2 x + b2 y + c2 = 0
  final a2 = y4 - y3;
  final b2 = x3 - x4;
  final c2 = (x4 * y3) - (x3 * y4);

  // Compute r1 and r2
  final r1 = (a2 * x1) + (b2 * y1) + c2;
  final r2 = (a2 * x2) + (b2 * y2) + c2;

  // Check signs of r1 and r2. If both point 1 and point 2 lie
  // on same side of second line segment, the line segments do
  // not intersect.
  if ((r1 != 0) && (r2 != 0) && (sameSign(r1, r2))) {
    return /*DONT_INTERSECT*/;
  }

  // Line segments intersect: compute intersection point.
  final denom = (a1 * b2) - (a2 * b1);
  if (denom == 0) {
    return /*COLLINEAR*/;
  }

  final offset = (denom / 2).abs();

  // The denom/2 is to get rounding instead of truncating. It
  // is added or subtracted to the numerator, depending upon the
  // sign of the numerator.
  num n = (b1 * c2) - (b2 * c1);
  final x = (n < 0) ? ((n - offset) / denom) : ((n + offset) / denom);

  n = (a2 * c1) - (a1 * c2);
  final y = (n < 0) ? ((n - offset) / denom) : ((n + offset) / denom);

  // lines_intersect
  addPoint(x, y, intersections);
}

intersectPolygon(Map node, Element polygon, Math.Point point) {
  final x1 = node['x'];
  final y1 = node['y'];
  final x2 = point.x;
  final y2 = point.y;

  final intersections = [];
  List points = polygon.points;

  num minx = 100000, miny = 100000;
  for (int j = 0; j < points.length; j++) {
    var p = points[j];
    minx = Math.min(minx, p.x);
    miny = Math.min(miny, p.y);
  }

  final left = x1 - node['width'] / 2 - minx;
  final top =  y1 - node['height'] / 2 - miny;

  for (var i = 0; i < points.length; i++) {
    final p1 = points[i];
    final p2 = points[i < points.length - 1 ? i + 1 : 0];
    intersectLine(x1, y1, x2, y2, left + p1.x, top + p1.y, left + p2.x, top + p2.y, intersections);
  }

  if (intersections.length == 1) {
    return {'x': intersections[0][0], 'y': intersections[0][1]};
  }

  if (intersections.length > 1) {
    // More intersections, find the one nearest to edge end point
    intersections.sort((p, q) {
      var pdx = p[0] - point.x,
         pdy = p[1] - point.y,
         distp = Math.sqrt(pdx * pdx + pdy * pdy),

         qdx = q[0] - point.x,
         qdy = q[1] - point.y,
         distq = Math.sqrt(qdx * qdx + qdy * qdy);

      return (distp < distq) ? -1 : (distp == distq ? 0 : 1);
    });
    return {'x': intersections[0][0], 'y': intersections[0][1]};
  } else {
    print('NO INTERSECTION FOUND, RETURN NODE CENTER');//, node);
    return node;
  }
}

//bool isComposite(g, u) {
//  return g.containsKey('children') && g.children(u).length;
//}

/*bind(func, thisArg) {
  // For some reason PhantomJS occassionally fails when using the builtin bind,
  // so we check if it is available and if not, use a degenerate polyfill.
  if (func.bind) {
    return func.bind(thisArg);
  }

  return () {
    return func.apply(thisArg, arguments);
  };
}*/
/*
applyStyle(style, domNode) {
  if (style) {
    var currStyle = domNode.attr('style') || '';
    domNode.attr('style', currStyle + '; ' + style);
  }
}
*/