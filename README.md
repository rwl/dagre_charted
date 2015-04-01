# dagre_charted - A Charted renderer for Dagre

## DEPRECATED (See [graphlib](https://pub.dartlang.org/packages/graphlib))

Dagre is a Dart library that makes it easy to lay out directed graphs on
the client-side. The dagre_charted library acts a front-end to dagre, providing
actual rendering using [Charted][].

`dagre_charted` was ported to Dart from [dagre-d3](https://github.com/cpettitt/dagre-d3)
by [Richard Lincoln](http://git.io/rwl).
<!--
## Demo

Try our [interactive demo](http://rwl.github.io/project/dagre_charted/latest/demo/interactive-demo.html)!

Or some of our other examples:

* [Sentence Tokenization](http://rwl.github.io/project/dagre_charted/latest/demo/sentence-tokenization.html)
* [TCP State Diagram](http://rwl.github.io/project/dagre_charted/latest/demo/tcp-state-diagram.html)
    * [TCP State Diagram](http://rwl.github.io/project/dagre_charted/latest/demo/tcp-state-diagram-json.html) using JSON as input.
* [ETL Visualization](http://rwl.github.io/project/dagre_charted/latest/demo/etl-status.html)
* [Style Attributes](http://rwl.github.io/project/dagre_charted/latest/demo/style-attrs.html)
* [User-defined Node Shapes](http://rwl.github.io/project/dagre_charted/latest/demo/user-defined-nodes.html)
* [Tooltip on Hover](http://rwl.github.io/project/dagre_charted/latest/demo/hover.html)

These demos and more can be found in the `example` folder of the project. Simply
open them in your browser - there is no need to start a web server.
-->
## Using dagre_charted

To use dagre_charted, there are a few basic steps:

1. Create a graph
2. Render the graph
3. Optionally configure the layout

We'll walk through each of these steps below.

### Creating a Graph

We use [graphlib](https://pub.dartlang.org/packages/graphlib) to create graphs in
dagre, so its probably worth taking a look at its API.

```dart
// Create a new directed graph
var graph = new Digraph();

// Add nodes to the graph. The first argument is the node id. The second is
// metadata about the node. In this case we're going to add labels to each of
// our nodes.
graph.addNode("kspacey",    { 'label': "Kevin Spacey" });
graph.addNode("swilliams",  { 'label': "Saul Williams" });
graph.addNode("bpitt",      { 'label': "Brad Pitt" });
graph.addNode("hford",      { 'label': "Harrison Ford" });
graph.addNode("lwilson",    { 'label': "Luke Wilson" });
graph.addNode("kbacon",     { 'label': "Kevin Bacon" });

// Add edges to the graph. The first argument is the edge id. Here we use null
// to indicate that an arbitrary edge id can be assigned automatically. The
// second argument is the source of the edge. The third argument is the target
// of the edge. The last argument is the edge metadata.
graph.addEdge(null, "kspacey",   "swilliams", { 'label': "K-PAX" });
graph.addEdge(null, "swilliams", "kbacon",    { 'label': "These Vagabond Shoes" });
graph.addEdge(null, "bpitt",     "kbacon",    { 'label': "Sleepers" });
graph.addEdge(null, "hford",     "lwilson",   { 'label': "Anchorman 2" });
graph.addEdge(null, "lwilson",   "kbacon",    { 'label': "Telling Lies in America" });
```

This simple graph was derived from [The Oracle of
Bacon](http://oracleofbacon.org/).

### Embedding HTML in the SVG Graph
If the label starts with an HTML tag, it is interpreted as HTML and is embeded
as an foreignobject SVG element. But note that the IE does not support this
SVG element.


### Rendering the Graph

To render the graph, we first need to create a wrapper for our SVG element on
the page:

```html
<div class="wrapper"></div>
```

Next we add our SVG elements to the page:

```dart
var scope = new SelectionScope.selector('.wrapper');
var svg = scope.append('svg:svg')
  ..attr('width', '650')
  ..attr('height', '680');
var g = svg.append('g')
  ..attr('transform', 'translate(20,20)');
```

Then we ask the renderer to draw our graph in the SVG element:

```dart
var renderer = new Renderer();
renderer.run(graph, g);
```

We also need to add some basic style information to get a usable graph. These
values can be tweaked, of course.

```css
<style>
svg {
    overflow: hidden;
}

.node rect {
    stroke: #333;
    stroke-width: 1.5px;
    fill: #fff;
}

.edgeLabel rect {
    fill: #fff;
}

.edgePath {
    stroke: #333;
    stroke-width: 1.5px;
    fill: none;
}
</style>
```

This produces the graph:

![oracle-of-bacon1.png](http://rwl.github.io/project/dagre_charted/static/oracle-of-bacon1.png)

### Configuring the Renderer

This section describes experimental rendering configuration.

* `edgeInterpolate` sets the path interpolation used with Charted. For a list
  of interpolation options, see the [D3 API](https://github.com/mbostock/d3/wiki/SVG-Shapes#wiki-line_interpolate).
* `edgeTension` is used to set the tension for use with Charted. See the
  [D3 API](https://github.com/mbostock/d3/wiki/SVG-Shapes#wiki-line_tension) for details.

For example, to set the edge interpolation to 'linear':

```dart
renderer.edgeInterpolate = 'linear';
renderer.run(graph, g);
```

Or for example, to disable drag and zoom:

```dart
renderer.zoomEnabled = false;
renderer.run(graph, g);
```

### Configuring the Layout

Here are a few properties you can call on the layout object to change layout behavior:

* `debugLevel` sets the level of logging verbosity. Currently 4 is th max.
* `nodeSep` sets the separation between adjacent nodes in the same rank to `x` pixels.
* `edgeSep` sets the separation between adjacent edges in the same rank to `x` pixels.
* `rankSep` sets the sepration between ranks in the layout to `x` pixels.
* `rankDir` sets the direction of the layout.
    * Defaults to `"TB"` for top-to-bottom layout
    * `"LR"` sets layout to left-to-right

For example, to set node separation to 20 pixels and the rank direction to left-to-right:

```dart
renderer.layout = new dagre.Layout()
                    ..nodeSep = 20
                    ..rankDir = "LR";
renderer.run(graph, g);
```

This produces the following graph:

![oracle-of-bacon2.png](http://rwl.github.io/project/dagre_charted/static/oracle-of-bacon2.png)

## License

dagre_charted is licensed under the terms of the MIT License. See the LICENSE file
for details.

[Charted]: https://pub.dartlang.org/packages/charted
