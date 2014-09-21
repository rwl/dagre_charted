import 'dart:html' show document;

import 'package:charted/charted.dart';
import 'package:unittest/unittest.dart';
import 'package:dagre_d3/renderer.dart';
import 'package:graphlib/graphlib.dart';

class TestRenderer extends Renderer {
  // Assign ids to all nodes and edges to simplify getting them later
  // TODO: make this reusable, as this is likely a common need
  drawNodes(g, dom) {
    var domNodes = super.drawNodes(g, dom);
    domNodes.attr('id', (u) { return 'node-' + u; });
    return domNodes;
  }

  drawEdgeLabels(g, dom) {
    var domNodes = super.drawEdgeLabels(g, dom);
    domNodes.attr('id', (u) { return 'edgeLabel-' + u; });
    return domNodes;
  }

  drawEdgePaths(g, dom) {
    var domNodes = super.drawEdgePaths(g, dom);
    domNodes.attr('id', (u) { return 'edgePath-' + u; });
    return domNodes;
  }
}

/* Commonly used names */
rendererTest() {
  group('Renderer', () {
    TestRenderer renderer;
    SelectionScope svg;

    /**
     * Returns the browser-specific representation for the given color.
     */
    toDOMColor(color) {
      var elem = svg.append('rect');
      elem.style('fill', color);
      try {
        return elem.nodeStyle('fill');
      } finally {
        elem.remove();
      }
    };

    setUp(() {
      svg = new SelectionScope.selector('svg');
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
      svg.selectAll('*').remove();
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

      expect(new SelectionScope.selector('#node-1').empty(), isFalse);
      expect(new SelectionScope.selector('#node-1 rect').empty(), isFalse);
      expect(new SelectionScope.selector('#node-1 text').empty(), isFalse);
      expect(new SelectionScope.selector('#node-2').empty(), isFalse);
    });

    test('creates DOM nodes for each edge path in the graph', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(new SelectionScope.selector('#edgePath-A').empty(), isFalse);
      expect(new SelectionScope.selector('#edgePath-A path').empty(), isFalse);
    });

    test('creates DOM nodes for each edge label in the graph', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(new SelectionScope.selector('#edgeLabel-A').empty(), isFalse);
      expect(new SelectionScope.selector('#edgeLabel-A text').empty(), isFalse);
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

      expect(new SelectionScope.selector('#node-1 #foo').empty(), isFalse);
      expect(new SelectionScope.selector('#node-2 #bar').empty(), isFalse);
    });

    test('adds the result of a function when passed as a label', () {
      final elem1 = document.createElement('div');
      elem1.id = 'foo';

      final elem2 = document.createElement('div');
      elem2.id = 'bar';

      var input = new Digraph();
      input.addNode(1, { 'label': () { return elem1; } });
      input.addNode(2, { 'label': () { return elem2; } });
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(new SelectionScope.selector('#node-1 #foo').empty(), isFalse);
      expect(new SelectionScope.selector('#node-2 #bar').empty(), isFalse);
    });

    group('styling', () {
      test('styles nodes with the "style" attribute', () {
        var input = new Digraph();
        input.addNode(1, { 'style': 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(new SelectionScope.selector('#node-1 rect').style('fill'), equals(toDOMColor('#ff0000')));
      });

      test('styles node labels with the "styleLabel" attribute', () {
        var input = new Digraph();
        input.addNode(1, { 'labelStyle': 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(new SelectionScope.selector('#node-1 text').style('fill'), equals(toDOMColor('#ff0000')));
      });

      test('styles edge paths with the "style" attribute', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { 'style': 'stroke: #ff0000' });

        renderer.run(input, svg);

        expect(new SelectionScope.selector('#edgePath-A path').style('stroke'), equals(toDOMColor('#ff0000')));
      });

      test('styles edge labels with the "styleLabel" attribute', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { 'labelStyle': 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(new SelectionScope.selector('#edgeLabel-A text').style('fill'), equals(toDOMColor('#ff0000')));
      });
    });

    group('marker-end', () {
      test('is not used when the graph is undirected', () {
        var input = new Graph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, {});

        renderer.run(input, svg);

        expect(new SelectionScope.selector('#edgePath-A path').attr('marker-end'), isNull);
      });

      test('defaults the marker\'s fill to the path\'s stroke color', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { 'style': 'stroke: #ff0000' });

        renderer.run(input, svg);

        var markerEnd = new SelectionScope.selector('#edgePath-A path').attr('marker-end'),
            pattern = new RegExp(r"url\((#[A-Za-z0-9-_]+)\)$");
        expect(markerEnd, matches(pattern));
        //var id = markerEnd.match(pattern)[1];
        var id = pattern.firstMatch(markerEnd).group(0);
        expect(new SelectionScope.selector(id).style('fill'), equals(toDOMColor('#ff0000')));
      });

      test('is set to #arrowhead when the arrowheadFix attribute is false for the graph', () {
        var input = new Digraph();
        input.graph({ 'arrowheadFix': false });
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, {});

        renderer.run(input, svg);

        expect(new SelectionScope.selector('#edgePath-A path').attr('marker-end'), equals('url(#arrowhead)'));
      });
    });
  });
}