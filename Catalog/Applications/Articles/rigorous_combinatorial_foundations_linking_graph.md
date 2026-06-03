# The Geometry of Reasoning: How Graph Theory Reveals the Shape of Proof

## A hidden landscape governs how hard it is to prove a theorem

Imagine you're standing in a vast city, and you need to reach a specific building. The streets are one-way. Some neighborhoods are densely connected; others are sparse. How many steps will it take you to get there?

This is, in essence, the question that proof complexity asks about mathematical reasoning. Every mathematical proof is a journey from assumptions to conclusions, and the structure of the "streets" — the logical rules that let you move from one statement to another — determines how long that journey must be.

A team of researchers has now shown that the geometry of this logical landscape can be captured by a single number: the *directed conductance*, a measure of how well-connected the network of derivations is. Their work reveals that the difficulty of proving a theorem is not an accident of the particular statements involved, but a consequence of the deep geometric structure of the space of all possible proofs.

## The derivation graph: a map of all possible reasoning

The key insight begins with a simple but powerful idea: represent every mathematical statement as a point, and draw an arrow from statement A to statement B whenever B can be derived from A in a single logical step. The result is a *derivation graph* — a directed network that encodes the entire landscape of possible reasoning.

In this graph, a proof is simply a path: a sequence of arrows leading from your axioms (starting points) to your target theorem. The length of the shortest such path is the *proof depth* — the minimum number of logical steps needed. And understanding what controls proof depth turns out to be equivalent to understanding how information spreads through networks.

## Expansion: the bottleneck principle

Some graphs are "expanders" — networks where every small group of nodes has many outgoing connections to new nodes. Social networks, for instance, tend to be expanders: your friends' friends quickly span much of the population.

The researchers showed that if a derivation graph is an expander, then the "proof ball" — the set of all statements reachable from your axioms in *k* steps — grows exponentially. Specifically, if every small set of statements has at least φ times as many new neighbors (the *directed conductance*), then the proof ball grows by a factor of (1 + φ) at each step.

This is a powerful result. It means that in an expanding derivation graph, you can reach any statement in logarithmically many steps relative to the total number of statements. Conversely, if a particular target statement requires many steps to reach, the graph must have a bottleneck — a set of statements that is poorly connected to the rest.

## The hierarchy of proof depth

But the story gets richer. The researchers introduced *proof depth classes*: the set of statements first reachable at exactly step *k*, and never before. These classes partition the entire reachable component of the graph into concentric layers, like the rings of a tree.

The depth hierarchy theorem shows that under expansion, these layers are substantial. Each new depth class contains at least φ times as many elements as the previous proof ball. This means the layers can't thin out prematurely — the proof ball must keep growing robustly until it covers a significant fraction of the graph.

This has a striking consequence: proof complexity is *stratified*. There is a genuine hierarchy of difficulty levels, with each level separated from the next by a gap proportional to the conductance. Theorems at depth 10 are genuinely harder to reach than theorems at depth 5, not just by a constant factor, but by the compounding effect of exponential growth.

## Layered proofs and the structure of formal systems

The researchers also studied a special class of derivation graphs — *layered derivations* — where every edge moves exactly one layer up. This models structured proof systems like Frege calculus or sequent calculus, where each inference rule increases the complexity of a formula by exactly one.

In layered derivations, the proof ball and the layer structure align perfectly: a vertex at layer *k* cannot possibly appear in the proof ball of radius less than *k*. This gives a tight, exact characterization of proof depth in terms of the layering function — a result that connects the abstract graph theory to the concrete structure of formal logic.

## The dichotomy of reachability

Perhaps the most philosophically striking result is the *reachability dichotomy*: for any statement, either it is eventually reachable from the axioms, or it is *forever* unreachable — there is no step at which it magically becomes accessible.

This follows from a beautiful finiteness argument. The proof ball is monotonically growing in a finite universe, so it must eventually stabilize. Once it stops growing, the stabilized set is *closed* under derivation — it is a self-contained logical universe from which nothing new can be derived. The researchers proved that this stabilization occurs within |V| steps, where |V| is the total number of statements, and that the fixed-point condition is equivalent to closure under the derivation rules.

## The spectral connection

The directed conductance connects to a deep mathematical theory: the *spectral gap* of the graph's Laplacian matrix. The classical Cheeger inequality, a cornerstone of spectral graph theory, relates the expansion of a graph to the eigenvalues of its adjacency matrix. Through this connection, the researchers' expansion-based proof complexity bounds become *spectral* bounds.

The conjecture — not yet fully established — is that a directed version of the Cheeger inequality holds for derivation graphs. If true, this would mean that the difficulty of proving a theorem could be read directly from the eigenvalues of a matrix — a linear-algebraic computation. The proof complexity of a logical system would be encoded not in the specific logical rules, but in the spectrum of a single operator.

This is a remarkable possibility. It would mean that proof complexity, traditionally studied through intricate combinatorial arguments tailored to specific proof systems, could be approached through the universal language of linear algebra. The same eigenvalue computations that predict the mixing time of random walks, the conductivity of electrical networks, and the vibrational modes of physical structures would also predict how hard it is to prove a theorem.

## The renormalization perspective

There is yet another connection — to statistical physics. The researchers' earlier work established that *coarse-graining* a derivation graph (collapsing groups of statements into single nodes) preserves reachability. This is the same operation that physicists call *renormalization*: looking at a system from a distance, blurring the fine details to reveal the large-scale structure.

In physics, systems that look the same under renormalization are said to be at a *critical point* — a phase transition where the microscopic details become irrelevant and universal laws emerge. The researchers' results suggest that derivation graphs may exhibit similar universality: the proof complexity of a logical system may be governed by a few universal parameters (like the spectral gap) that are invariant under coarse-graining.

If this analogy proves fruitful, it would establish a genuine bridge between the foundations of mathematics and the foundations of physics — two disciplines that have long been entangled but whose connections remain mysterious.

## What lies ahead

The immediate next step is to establish the directed Cheeger inequality rigorously for derivation graphs. Beyond that, the researchers envision a complete "spectral proof complexity theory" that classifies proof systems by their spectral properties, much as materials are classified by their band structure in solid-state physics.

The deeper question, still open, is whether the spectral approach can prove *new* lower bounds — showing that certain theorems require proofs of a certain minimum length. Current proof complexity lower bounds are among the hardest results in theoretical computer science, and a spectral approach could potentially bypass the intricate combinatorial arguments that have been needed until now.

The shape of reasoning, it turns out, is not formless. It has a geometry — one governed by eigenvalues, expansion ratios, and spectral gaps. And in that geometry may lie the key to understanding the deepest limits of mathematical thought.
