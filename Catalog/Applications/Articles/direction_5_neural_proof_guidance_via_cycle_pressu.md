# Why AI Needs Topology to Do Math

## The Map Problem

Imagine trying to navigate a sprawling city—Paris, say—using only a map of its subway system. The Metro map shows you which stations connect to which, branching outward like the limbs of a tree. It is beautifully simple, and for many trips it works perfectly well. But it is also *wrong* in a fundamental way: it tells you nothing about the loops. It does not show you that walking from Bastille to République and back forms a circle. It does not reveal that three different routes between two stations enclose a district you could explore. The tree-like map strips away exactly the information that makes Paris *Paris*—its cycles, its enclosed spaces, its topology.

For the past decade, artificial intelligence systems that guide mathematical reasoning have been making exactly this mistake. They navigate the vast landscape of mathematical knowledge using tree-shaped maps—and they have been systematically blind to the loops.

## The Hidden Architecture of Mathematical Knowledge

Mathematics is often imagined as a tower: axioms at the base, simple theorems stacked above, and towering abstractions at the top. But mathematicians have always known this picture is incomplete. Mathematical knowledge is not a tower. It is a *web*.

Consider the Pythagorean theorem. You can prove it using geometry—by rearranging squares on the sides of a right triangle. You can also prove it using algebra—by manipulating the equation a² + b² = c². You can prove it using trigonometry, or calculus, or even number theory. Each proof takes a different path through mathematical knowledge, and some of those paths loop back on themselves, creating cycles. The existence of multiple independent proofs means the mathematical landscape around the Pythagorean theorem contains genuine topological structure: loops that cannot be contracted to a point.

This is not merely a curiosity. A new line of research has shown that these loops—formalized as the *cycle rank* of mathematical knowledge graphs—carry critical information about how difficult it is to find proofs in the first place. And this information is precisely what current AI systems are missing.

## Cycles as Choice Points

Here is the key insight, expressed without a single equation: every independent loop in a mathematical knowledge graph represents a *choice point* in the search for a proof.

Think of it this way. When an AI system tries to prove a theorem, it explores a graph of possible moves—tactics it could try, lemmas it could apply, directions it could take. If that graph is tree-shaped, the search is relatively straightforward: at each branch, you choose left or right, and if you hit a dead end, you backtrack. The number of possibilities grows, but manageably.

But when the graph contains cycles—when there are multiple independent ways to get from A to B—something qualitatively different happens. Each cycle creates a genuine fork where the AI must make a choice that cannot be resolved by local information alone. You cannot tell which branch of a cycle leads to the proof without exploring both sides. And if there are *k* independent cycles, the search space doesn't just grow linearly—it grows *exponentially*. Specifically, the number of search paths multiplies by a factor of 2 for each independent cycle.

This is not a metaphor. Recent mathematical results have established a precise quantitative theorem: if a region of the proof graph contains *k* independent cycles, then any complete proof search strategy must explore at least *k* · log₂(*k* + 1) paths. The exponential branching factor 2^*k* provides the tight upper bound. Between these bounds lies the true difficulty of proof search—and it is entirely determined by topology.

## What Trees Miss

To understand why this matters for AI, consider two mathematical neighborhoods that look identical from a tree-based perspective.

The first neighborhood is a small cluster of three interconnected theorems—call them A, B, and C. Each theorem can be used to prove each of the others. This creates a triangle: A connects to B, B connects to C, and C connects back to A. The cycle rank is 1.

The second neighborhood is a chain: theorem A leads to theorem B, and theorem B leads to theorem C, but there is no direct connection from C back to A. This is a simple path. The cycle rank is 0.

Now here is the crucial observation: from the perspective of theorem B, the *local* features are identical in both cases. In both neighborhoods, B has exactly two connections (to A and to C). The vertex count is the same (three theorems). Any feature that looks only at the immediate neighborhood—the "tree-local" features—sees no difference.

But the proof search difficulty is dramatically different. In the triangle, a proof search at B must account for the cycle: should it go A → B → C or A → C → B? The cycle creates an ambiguity that forces exploration. In the chain, there is no such ambiguity. The branching factor is 2 in the first case and 1 in the second.

This is not a contrived example. It is a *theorem*—a mathematically proven fact about the limitations of tree-based features. No matter how sophisticated your tree-local feature extraction is, no matter how many layers of neighborhood aggregation you perform, you will always confuse some pairs of graphs that have genuinely different proof search difficulties. The topology carries information that trees provably cannot capture.

## The Neural Network Blind Spot

This finding has immediate implications for the graph neural networks (GNNs) that power modern AI proof assistants. Standard GNNs work by *message passing*: each node in a graph collects information from its neighbors, processes it, and passes it along. After several rounds of message passing, each node has aggregated information from its local neighborhood.

But message-passing GNNs are mathematically equivalent to a certain kind of tree-based computation. They can compute any function of the local tree structure around a node—degree sequences, depth distributions, subtree sizes—but they are provably limited in their ability to detect cycles. This is not a matter of training better or using more data. It is a fundamental architectural limitation, as inescapable as the fact that a colorblind person cannot distinguish red from green no matter how hard they try.

The theoretical result shows that for any message-passing GNN, there exist pairs of mathematical neighborhoods where the network produces identical outputs but the proof search difficulties differ by a factor of at least 2. The network is, in a precise mathematical sense, *blind* to a dimension of difficulty that topology reveals.

## A New Lens: Cycle Pressure

The solution is to give AI systems topological eyes. Researchers have formalized a quantity called *cycle pressure*—essentially the cycle rank of the local neighborhood around a mathematical statement—and shown that it can be efficiently computed and used as an additional feature for proof guidance.

The cycle pressure of a statement captures, in a single number, how topologically complex its mathematical neighborhood is. A statement surrounded by many independent proof paths (high cycle pressure) is likely to require more sophisticated search strategies than one embedded in a tree-like region (low cycle pressure). And this prediction is backed by rigorous mathematical guarantees, not just empirical correlations.

What makes cycle pressure particularly elegant is its connection to classical mathematics. The cycle rank of a graph is one of the oldest invariants in graph theory, dating back to the 19th century work of Gustav Kirchhoff on electrical networks. It equals the first Betti number of the graph viewed as a topological space—a concept from algebraic topology that measures the number of "holes" in a space. The same mathematical quantity that tells you how many independent loops exist in an electrical circuit also tells you how many independent choice points exist in a proof search.

This is not a coincidence. It reflects a deep structural parallel between electrical networks and proof systems that mathematicians have suspected for decades but only recently made precise.

## The Kirchhoff Connection

Kirchhoff's laws for electrical circuits state that the number of independent current loops in a network equals the number of edges minus the number of vertices plus one (for a connected network). This is exactly the cycle rank formula. In an electrical network, each independent loop represents a degree of freedom in the current distribution—a choice the current can make about which path to flow through.

In a proof network, each independent cycle represents a degree of freedom in the proof strategy—a choice the search algorithm must make about which path to explore. The mathematical identity is perfect: the formula for independent current loops in a circuit is the same formula that counts independent choice points in a proof search.

This parallel extends further. In statistical mechanics, the *pressure* of a system measures how the free energy changes when you add particles to it. The cycle pressure of a proof graph plays an analogous role: it measures how the proof search difficulty changes when you add connections to the mathematical landscape. The thermodynamic analogy is not just poetic—it provides genuine mathematical tools for analyzing proof complexity.

## From Theory to Practice

The theoretical framework makes concrete predictions that can be tested. If cycle pressure truly captures proof search difficulty, then augmenting an AI proof assistant with topological features should improve its performance, and the improvement should be greatest on problems with high cycle pressure.

Preliminary computational experiments support this prediction. When mathematical knowledge graphs are constructed from large libraries of formalized mathematics—collections of thousands of theorems with their logical dependencies—the cycle pressure varies dramatically across the graph. Some regions are nearly tree-like (low cycle pressure), corresponding to straightforward chains of deduction. Other regions are densely cyclic (high cycle pressure), corresponding to areas where multiple proof strategies interweave.

The high-cycle-pressure regions tend to be exactly where current AI systems struggle most. They are the areas of mathematics where creativity matters—where finding a proof requires making non-obvious choices between multiple viable approaches. And they are precisely the areas where topological features should provide the most benefit.

## The Bigger Picture

This research sits at a remarkable intersection of disciplines. It draws on algebraic topology (Betti numbers and homology), graph theory (cycle rank and Kirchhoff's formula), information theory (the connection between cycles and search complexity), and machine learning (the expressiveness limitations of graph neural networks). The fact that a single mathematical quantity—the cycle rank—threads through all of these fields is a testament to the unity of mathematics.

But the implications extend beyond any single discipline. The finding that tree-based methods are provably insufficient for capturing proof difficulty challenges a widespread assumption in AI research: that local, tree-structured computation is enough to capture the essential features of complex systems. In natural language processing, in drug discovery, in social network analysis—anywhere graph neural networks are used—the same limitation applies. Cycles carry information that trees cannot capture, and any system that ignores them is leaving information on the table.

The fix is not to abandon tree-based methods but to augment them. Just as a map of Paris becomes far more useful when you add the information about which streets form loops and which neighborhoods they enclose, a graph neural network becomes more powerful when you add topological features that capture cycle structure. The theory tells us exactly which features to add (cycle rank, Betti numbers) and quantifies exactly how much information they carry (exponential in the cycle rank).

## A New Chapter

We are living through a revolution in artificial intelligence's ability to do mathematics. Automated systems can now prove theorems that would take human mathematicians days or weeks. But they still struggle with problems that require navigating complex, cycle-rich mathematical landscapes—the very problems where human intuition about "proof strategy" and "mathematical taste" makes the biggest difference.

Topology offers a way to formalize some of that intuition. The loops in mathematical knowledge are not defects or redundancies. They are the signature of richness, the mark of a mathematical landscape with genuine depth. Teaching AI to see them is not just a technical improvement. It is a step toward systems that understand not just the *content* of mathematics, but its *shape*.

The next time you look at a map of a city, notice the loops. They are what make the city navigable, livable, interesting. The same is true of mathematics—and artificial intelligence is just beginning to learn how to read the map.
