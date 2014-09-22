import 'dart:html' show document, Element;

import 'package:charted/charted.dart';
import 'package:unittest/unittest.dart';
import 'package:dagre_charted/renderer.dart';
import 'package:graphlib/graphlib.dart';

class TestRenderer extends Renderer {
  // Assign ids to all nodes and edges to simplify getting them later
  // TODO: make this reusable, as this is likely a common need
  Selection drawNodes(BaseGraph g, Selection dom) {
    var domNodes = super.drawNodes(g, dom);
    domNodes.attrWithCallback('id', (u, int ei, Element c) {
      return 'node-$u';
    });
    return domNodes;
  }

  Selection drawEdgeLabels(BaseGraph g, Selection dom) {
    var domNodes = super.drawEdgeLabels(g, dom);
    domNodes.attrWithCallback('id', (u, int ei, Element c) {
      return 'edgeLabel-$u';
    });
    return domNodes;
  }

  Selection drawEdgePaths(BaseGraph g, Selection dom) {
    var domNodes = super.drawEdgePaths(g, dom);
    domNodes.attrWithCallback('id', (u, int ei, Element c) {
      return 'edgePath-$u';
    });
    return domNodes;
  }
}

/* Commonly used names */
main() {
  group('Renderer', () {
    TestRenderer renderer;
    Selection svg;

    /**
     * Returns the browser-specific representation for the given color.
     */
    toDOMColor(color) {
      var elem = svg.append('rect');
      elem.style('fill', color);
      try {
        return style(elem.first, 'fill');
      } finally {
        elem.remove();
      }
    };

    setUp(() {
      final scope = new SelectionScope.selector('.wrapper');
      svg = scope.append('svg:svg');
      renderer = new TestRenderer();

      // Assign ids to all nodes and edges to simplify getting them later
      // TODO: make this reusable, as this is likely a common need
//      var oldDrawNodes = renderer.drawNodes();
//      renderer.drawNodes((g, dom) {
//        var domNodes = oldDrawNodes(g, dom);
//        domNodes.attr('id', (u) { return 'node-' + u; });
//        return domNodes;
//      });

//      var oldDrawEdgeLabels = renderer.drawEdgeLabels();
//      renderer.drawEdgeLabels((g, dom) {
//        var domNodes = oldDrawEdgeLabels(g, dom);
//        domNodes.attr('id', (u) { return 'edgeLabel-' + u; });
//        return domNodes;
//      });

//      var oldDrawEdgePaths = renderer.drawEdgePaths();
//      renderer.drawEdgePaths((g, dom) {
//        var domNodes = oldDrawEdgePaths(g, dom);
//        domNodes.attr('id', (u) { return 'edgePath-' + u; });
//        return domNodes;
//      });
    });

    tearDown(() {
      //svg.selectAll('*').remove();
//      svg.remove();
    });

    test('does not change the input graph attributes', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(input.node(1), equals({}));
      expect(input.node(2), equals({}));
      expect(input.edge('A'), equals({}));
    });

    test('creates DOM nodes for each node in the graph', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});

      renderer.run(input, svg);

//      expect(new SelectionScope.selector('#node-1').length, isNonZero);
//      expect(new SelectionScope.selector('#node-1 rect').length, isNonZero);
//      expect(new SelectionScope.selector('#node-1 text').length, isNonZero);
//      expect(new SelectionScope.selector('#node-2').length, isNonZero);
      expect(svg.select('#node-1').length, isNonZero);
      expect(svg.select('#node-1 rect').length, isNonZero);
      expect(svg.select('#node-1 text').length, isNonZero);
      expect(svg.select('#node-2').length, isNonZero);
    });

    test('creates DOM nodes for each edge path in the graph', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

//      expect(new SelectionScope.selector('#edgePath-A').length, isNonZero);
//      expect(new SelectionScope.selector('#edgePath-A path').length, isNonZero);
      expect(svg.select('#edgePath-A').length, isNonZero);
      expect(svg.select('#edgePath-A path').length, isNonZero);
    });

    test('creates DOM nodes for each edge label in the graph', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

//      expect(new SelectionScope.selector('#edgeLabel-A').length, isNonZero);
//      expect(new SelectionScope.selector('#edgeLabel-A text').length, isNonZero);
      expect(svg.select('#edgeLabel-A').length, isNonZero);
      expect(svg.select('#edgeLabel-A text').length, isNonZero);
    });

    test('adds DOM elements to the svg when passed as a label', () {
      final elem1 = document.createElement('div');
      elem1.id = 'foo';

      final elem2 = document.createElement('div');
      elem2.id = 'bar';

      var input = new Digraph();
      input.addNode(1, { 'label': elem1 });
      input.addNode(2, { 'label': elem2 });
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(svg.select('#node-1 #foo').length, isNonZero);
      expect(svg.select('#node-2 #bar').length, isNonZero);
    });

    test('adds the result of a function when passed as a label', () {
      final elem1 = document.createElement('div');
      elem1.id = 'foo';

      final elem2 = document.createElement('div');
      elem2.id = 'bar';

      var input = new Digraph();
      input.addNode(1, { 'label': (d, ei, c) { return elem1; } });
      input.addNode(2, { 'label': (d, ei, c) { return elem2; } });
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(svg.select('#node-1 #foo').length, isNonZero);
      expect(svg.select('#node-2 #bar').length, isNonZero);
    });

    group('styling', () {
      test('styles nodes with the "style" attribute', () {
        var input = new Digraph();
        input.addNode(1, { 'style': 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(style(svg.select('#node-1 rect').first, 'fill'), equals(toDOMColor('#ff0000')));
      });

      test('styles node labels with the "styleLabel" attribute', () {
        var input = new Digraph();
        input.addNode(1, { 'labelStyle': 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(style(svg.select('#node-1 text').first, 'fill'), equals(toDOMColor('#ff0000')));
      });

      test('styles edge paths with the "style" attribute', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { 'style': 'stroke: #ff0000' });

        renderer.run(input, svg);

        expect(style(svg.select('#edgePath-A path').first, 'stroke'), equals(toDOMColor('#ff0000')));
      });

      test('styles edge labels with the "styleLabel" attribute', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { 'labelStyle': 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(style(svg.select('#edgeLabel-A text').first, 'fill'), equals(toDOMColor('#ff0000')));
      });
    });

    group('marker-end', () {
      test('is not used when the graph is undirected', () {
        var input = new Graph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, {});

        renderer.run(input, svg);

        expect(svg.select('#edgePath-A path').first.attributes['marker-end'], isNull);
      });

      test('defaults the marker\'s fill to the path\'s stroke color', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { 'style': 'stroke: #ff0000' });

        renderer.run(input, svg);

        var markerEnd = svg.select('#edgePath-A path').first.attributes['marker-end'],
            pattern = new RegExp(r"url\((#[A-Za-z0-9-_]+)\)$");
        expect(markerEnd, matches(pattern));
        //var id = markerEnd.match(pattern)[1];
        var id = pattern.firstMatch(markerEnd).group(0);
        expect(style(svg.select(id).first, 'fill'), equals(toDOMColor('#ff0000')));
      });

      test('is set to #arrowhead when the arrowheadFix attribute is false for the graph', () {
        var input = new Digraph();
        input.graph({ 'arrowheadFix': false });
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, {});

        renderer.run(input, svg);

        expect(svg.select('#edgePath-A path').first.attributes['marker-end'], equals('url(#arrowhead)'));
      });
    });
  });
}