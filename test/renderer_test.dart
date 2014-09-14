import 'package:unittest/unittest.dart';

/* Commonly used names */
rendererTest() {
  group('Renderer', () {
    var renderer,
        svg;

    /**
     * Returns the browser-specific representation for the given color.
     */
    var toDOMColor = (color) {
      var elem = svg.append('rect');
      elem.style('fill', color);
      try {
        return elem.style('fill');
      } finally {
        elem.remove();
      }
    };

    setUp(() {
      svg = d3.select('svg');
      renderer = new Renderer();

      // Assign ids to all nodes and edges to simplify getting them later
      // TODO: make this reusable, as this is likely a common need
      var oldDrawNodes = renderer.drawNodes();
      renderer.drawNodes((g, dom) {
        var domNodes = oldDrawNodes(g, dom);
        domNodes.attr('id', (u) { return 'node-' + u; });
        return domNodes;
      });

      var oldDrawEdgeLabels = renderer.drawEdgeLabels();
      renderer.drawEdgeLabels((g, dom) {
        var domNodes = oldDrawEdgeLabels(g, dom);
        domNodes.attr('id', (u) { return 'edgeLabel-' + u; });
        return domNodes;
      });

      var oldDrawEdgePaths = renderer.drawEdgePaths();
      renderer.drawEdgePaths((g, dom) {
        var domNodes = oldDrawEdgePaths(g, dom);
        domNodes.attr('id', (u) { return 'edgePath-' + u; });
        return domNodes;
      });
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

      expect(input.node(1)).to.deep.equal({});
      expect(input.node(2)).to.deep.equal({});
      expect(input.edge('A')).to.deep.equal({});
    });

    test('creates DOM nodes for each node in the graph', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});

      renderer.run(input, svg);

      expect(d3.select('#node-1').empty(), isFalse);
      expect(d3.select('#node-1 rect').empty(), isFalse);
      expect(d3.select('#node-1 text').empty(), isFalse);
      expect(d3.select('#node-2').empty(), isFalse);
    });

    test('creates DOM nodes for each edge path in the graph', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(d3.select('#edgePath-A').empty(), isFalse);
      expect(d3.select('#edgePath-A path').empty(), isFalse);
    });

    test('creates DOM nodes for each edge label in the graph', () {
      var input = new Digraph();
      input.addNode(1, {});
      input.addNode(2, {});
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(d3.select('#edgeLabel-A').empty(), isFalse);
      expect(d3.select('#edgeLabel-A text').empty(), isFalse);
    });

    test('adds DOM elements to the svg when passed as a label', () {
      var elem1 = document.createElement('div');
      elem1.id = 'foo';

      var elem2 = document.createElement('div');
      elem2.id = 'bar';

      var input = new Digraph();
      input.addNode(1, { label: elem1 });
      input.addNode(2, { label: elem2 });
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(d3.select('#node-1 #foo').empty(), isFalse);
      expect(d3.select('#node-2 #bar').empty(), isFalse);
    });

    test('adds the result of a function when passed as a label', () {
      var elem1 = document.createElement('div');
      elem1.id = 'foo';

      var elem2 = document.createElement('div');
      elem2.id = 'bar';

      var input = new Digraph();
      input.addNode(1, { label: () { return elem1; } });
      input.addNode(2, { label: () { return elem2; } });
      input.addEdge('A', 1, 2, {});

      renderer.run(input, svg);

      expect(d3.select('#node-1 #foo').empty(), isFalse);
      expect(d3.select('#node-2 #bar').empty(), isFalse);
    });

    group('styling', () {
      test('styles nodes with the "style" attribute', () {
        var input = new Digraph();
        input.addNode(1, { style: 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(d3.select('#node-1 rect').style('fill'), equals(toDOMColor('#ff0000')));
      });

      test('styles node labels with the "styleLabel" attribute', () {
        var input = new Digraph();
        input.addNode(1, { labelStyle: 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(d3.select('#node-1 text').style('fill'), equals(toDOMColor('#ff0000')));
      });

      test('styles edge paths with the "style" attribute', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { style: 'stroke: #ff0000' });

        renderer.run(input, svg);

        expect(d3.select('#edgePath-A path').style('stroke'), equals(toDOMColor('#ff0000')));
      });

      test('styles edge labels with the "styleLabel" attribute', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { labelStyle: 'fill: #ff0000' });

        renderer.run(input, svg);

        expect(d3.select('#edgeLabel-A text').style('fill'), equals(toDOMColor('#ff0000')));
      });
    });

    group('marker-end', () {
      test('is not used when the graph is undirected', () {
        var input = new Graph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, {});

        renderer.run(input, svg);

        expect(d3.select('#edgePath-A path').attr('marker-end'), isNull);
      });

      test('defaults the marker\'s fill to the path\'s stroke color', () {
        var input = new Digraph();
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, { style: 'stroke: #ff0000' });

        renderer.run(input, svg);

        var markerEnd = d3.select('#edgePath-A path').attr('marker-end'),
            pattern = r"url\((#[A-Za-z0-9-_]+)\)$";
        expect(markerEnd, matches(pattern));
        var id = markerEnd.match(pattern)[1];
        expect(d3.select(id).style('fill'), equals(toDOMColor('#ff0000')));
      });

      test('is set to #arrowhead when the arrowheadFix attribute is false for the graph', () {
        var input = new Digraph();
        input.graph({ arrowheadFix: false });
        input.addNode(1, {});
        input.addNode(2, {});
        input.addEdge('A', 1, 2, {});

        renderer.run(input, svg);

        expect(d3.select('#edgePath-A path').attr('marker-end'), equals('url(#arrowhead)'));
      });
    });
  });
}