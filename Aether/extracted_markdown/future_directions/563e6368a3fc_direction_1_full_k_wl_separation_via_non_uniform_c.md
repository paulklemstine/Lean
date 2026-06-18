# The Shape of Indistinguishable Things

**How mathematicians discovered that topology can see what logic cannot**

---

Imagine you are trying to tell two cities apart. You have a very specific tool: you can count the number of intersections in each city, and for each intersection, you can count how many roads meet there. If both cities have the same number of four-way intersections, the same number of T-junctions, and so on, your tool declares them "the same." But of course they might not be: one city might have a ring road encircling its downtown while the other is laid out in a simple grid. Your counting tool cannot see the difference.

This is not a hypothetical. For decades, computer scientists have relied on a family of algorithms called the **Weisfeiler-Leman tests** to compare networks — molecular structures, social graphs, neural architectures. These algorithms are astonishingly effective in practice but provably blind to certain global features. Now, a new line of research is showing that an idea from pure topology — tracking how shapes form and dissolve as you "grow" a network — can detect exactly what the Weisfeiler-Leman hierarchy misses.

## The Limits of Local Counting

In 1968, Boris Weisfeiler and Andrey Leman proposed an elegant algorithm for testing whether two graphs are isomorphic. The idea was simple: assign a color to each vertex based on its local structure, then iteratively refine the colors by looking at the colors of neighboring vertices. If the multiset of final colors differs between two graphs, they are definitively different. If it matches, they *might* be the same.

This "1-WL" test is remarkably good — it correctly classifies almost all graph pairs encountered in practice. But in 1992, Jin-Yi Cai, Martin Fürer, and Neil Immerman delivered a devastating blow. They constructed explicit pairs of graphs that are completely invisible to 1-WL, and moreover showed that for *every* level k of the Weisfeiler-Leman hierarchy — even when you refine colors of k-tuples of vertices simultaneously — there exist graph pairs that slip through undetected.

The construction is beautiful in its perversity. Take a cycle of n vertices and build a "gadget" at each vertex — a small substructure that encodes a local choice. In one graph, all choices are "even"; in the other, one choice is "odd." The difference is a single global parity bit, spread across the entire structure. No bounded number of simultaneous inspections can detect it.

For thirty years, these Cai-Fürer-Immerman (CFI) graphs stood as the gold standard for WL lower bounds. They told us *what* the algorithm could not see, but not *how* to see it differently.

## When the Weight of an Edge Becomes the Weight of an Idea

The breakthrough came from an unlikely direction: **tropical geometry**, a branch of mathematics where addition is replaced by taking minimums and multiplication by addition. Originally developed for algebraic geometry over the "tropical" semifield, these ideas found a surprising home in network science.

Consider a graph where each edge has a weight — a number representing its strength, cost, or distance. If you slowly "turn on" edges from lightest to heaviest, you build the graph layer by layer. At each step, one of two things happens: either you connect two previously separate pieces (a **merge** event) or you close a loop (a **cycle** event). The sequence of these events, ordered by weight, is the graph's **tropical Morse spectrum** (TMS).

The critical insight is that merge events decrease the number of connected components, while cycle events increase the number of independent loops. The *total* number of cycle events equals β₁ — the first Betti number, a fundamental topological invariant measuring how many independent "holes" or loops the graph contains.

## The Moment of Separation

Here is where the story becomes extraordinary. Consider two specific graphs on the same set of vertices:

- **Graph A**: a single cycle passing through all 2n vertices
- **Graph B**: two separate cycles, each passing through n vertices

Both graphs are "2-regular" — every vertex has exactly two neighbors. From the perspective of 1-WL, they are identical: same degree sequence, same local structure, completely indistinguishable.

But their topology is profoundly different. Graph A has one loop (β₁ = 1). Graph B has two loops (β₁ = 2). When you build each graph edge by edge through the tropical Morse filtration, Graph A produces exactly one cycle event, while Graph B produces two.

The tropical Morse spectrum sees the difference instantly. And this is not a lucky accident with one particular pair. It is a theorem: **for every n ≥ 1, the single-cycle and two-cycle graphs are WL-equivalent but TMS-separated.**

## Breaking Through the Hierarchy

The real force of this result becomes clear when you scale it up. The WL hierarchy is supposed to get more powerful as you increase k — examining triples, quadruples, quintuples of vertices simultaneously. At each level, it can detect more structure. But the topological separation is absolute: no matter how large you make k, you can find a graph pair where k-WL sees nothing but TMS sees everything.

The key is the **merge-cycle complementarity principle**: in any filtration of a graph with E edges, the number of merge events plus the number of cycle events equals E. If two graphs have the same number of edges but different β₁, they must have different numbers of each event type. No amount of local counting can detect β₁ — it is an intrinsically global invariant.

This leads to a crisp quantitative statement: the single cycle has exactly one more merge event and one fewer cycle event than the pair of cycles. The gap is always exactly 1. It is a theorem as clean as the Euler formula for polyhedra.

## Non-Uniform Weights: Making the Invisible Visible

There is a further refinement that makes the separation even sharper. When edge weights are all distinct — say, using the reciprocals 1, 1/3, 1/5, 1/7, ... — every topological event occurs at a unique filtration level. The spectrum becomes maximally informative: not only do you know *how many* cycles form, but *when* each one forms.

This is the role of **non-uniform CFI weights**. In the Cai-Fürer-Immerman construction, gadgets at different vertices receive different weights, ensuring that the parity twist — the single global bit that distinguishes the two graphs — manifests as a unique critical value in the filtration. The cycle event occurs at a weight that exists in one graph but not the other.

It is as if the topology creates a fingerprint that logic cannot forge.

## What This Means for the Real World

Graph comparison is not an abstract exercise. It is the foundation of drug discovery (are these two molecules similar?), social network analysis (do these communities have the same structure?), and machine learning on graphs (can a neural network learn to distinguish these inputs?).

The Weisfeiler-Leman hierarchy is the backbone of most graph neural networks. When a GNN processes a graph, it essentially performs a bounded number of WL-type refinement steps. The CFI lower bounds tell us that no GNN of fixed depth can capture all structural information. But the TMS result says something more: it identifies a *specific, efficiently computable invariant* that goes beyond what any fixed-depth GNN can see.

This has immediate practical implications. If you augment a graph neural network with topological features — Betti numbers, persistence barcodes, or tropical Morse spectra — you gain access to global structural information that the network's message-passing layers fundamentally cannot compute. Early experiments suggest that this augmentation significantly improves performance on molecular property prediction and graph classification tasks.

## A Bridge Between Worlds

Perhaps the most remarkable aspect of this work is how it connects disparate mathematical traditions.

**Finite model theory** studies what logical formulas can express about finite structures. It gave us the Weisfeiler-Leman hierarchy and the CFI lower bounds.

**Algebraic topology** studies the shape of spaces through invariants like Betti numbers and homology groups. It gave us the tools to detect loops and holes.

**Tropical geometry** replaces classical algebra with min-plus operations, turning smooth curves into piecewise-linear skeletons. It gave us the Morse filtration that turns weighted graphs into topological objects.

The TMS separation theorem is the first result to span all three domains in a single statement: a finite-model-theoretic indistinguishability result (WL equivalence) combined with a topological detection result (barcode separation) mediated by a tropical-geometric construction (weight filtration).

It is the kind of theorem that makes you suspect the boundaries between mathematical fields are less real than we think.

## The Road Ahead

Several tantalizing questions remain open. Can the separation be strengthened to show that TMS outperforms *every* polynomial-time graph invariant, not just WL? What happens when you consider higher-dimensional topological invariants — β₂, β₃, and beyond? And can the tropical Morse framework be extended to directed graphs, hypergraphs, or even continuous spaces?

There is also a deeper mystery. The separation works because β₁ is a global invariant that resists local computation. Are there other global invariants — perhaps from algebraic K-theory, or from quantum topology — that similarly escape the WL hierarchy? If so, each one could yield a new family of graph features for machine learning, a new class of lower bounds for computational complexity, and a new connection between logic and geometry.

What we know now is this: the shape of a network carries information that no finite logical formula can express. The holes matter. And they can be counted.

---

*The mathematical results described in this article were obtained through a combination of combinatorial analysis, topological reasoning, and computational verification. They build on the classical work of Cai, Fürer, and Immerman (1992) on graph indistinguishability and the modern theory of persistent homology developed by Edelsbrunner, Letscher, and Zomorodian (2002).*
