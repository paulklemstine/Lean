# The Hidden Geometry of Memory: How Proofs Carve Paths Through State Space

## A Strange Connection Between Forgetting and Graph Theory

Imagine you are solving a jigsaw puzzle, but the table is small. You can only keep a handful of pieces in front of you at any time. When you need a new piece, you must put one back in the box. The question is: how many pieces do you *really* need to have out at once to finish the puzzle?

This seemingly simple question — about the minimum memory required to complete a structured task — turns out to conceal a deep mathematical connection. Researchers have now shown that the answer is controlled by a geometric invariant: the *pathwidth* of an invisible graph that the solver traces out as it works.

The result bridges two fields that rarely speak to one another: *proof complexity*, which studies the resources needed to verify mathematical arguments, and *structural graph theory*, which classifies networks by their shape. The bridge says, essentially, that **memory is geometry** — that the amount of information a reasoner must hold in mind at any moment determines the shape of the space it moves through.

## The Proof as a Journey

To understand this, consider how a computer verifies that a logical puzzle has no solution. The puzzle is expressed as a *formula* — a list of constraints, each saying that at least one of several conditions must hold. The computer's job is to show these constraints are collectively impossible.

It does this by *resolution*: combining pairs of constraints to derive new ones, eventually producing the empty constraint — a contradiction, proving unsatisfiability. At each step, the computer holds some set of constraints in working memory. It can download a new original constraint, derive a new one from two it already holds, or erase one it no longer needs.

The sequence of memory states — call them *configurations* — forms a trace through a vast space of possibilities. Each configuration is a snapshot: which constraints the computer is currently thinking about. The *clause space* of a proof is the maximum number of constraints held at any single step.

Now here is the key insight. These configurations, and the transitions between them, form a *graph* — a network where each node is a memory state and each edge is a single legal proof step. The proof is a walk through this graph, from the empty starting state to one containing the contradiction.

## When Memory Becomes Width

Pathwidth is a concept from graph theory that measures how "path-like" a network is. Think of it this way: imagine you need to arrange all the nodes of a graph along a line, and at each position you maintain a "window" containing some nodes. The window must be wide enough that every edge in the graph has both its endpoints visible in at least one window position, and once a node exits the window, it can never reenter. The minimum window size needed is the pathwidth.

If a graph is literally a path — a chain of nodes — its pathwidth is 1. If it is a grid or a tree, the pathwidth grows but stays small. If the graph has complex, tangled structure with many interconnections, the pathwidth can be large.

What the new work establishes is that **clause space controls pathwidth**. Specifically: if a formula can be refuted using at most *s* constraints in memory at any time, and the proof never re-derives a constraint it previously erased (a natural "regularity" condition), then the interaction graph of those constraints — the network recording which constraints coexist during the proof — has pathwidth at most *s* − 1.

This is a theorem, not a conjecture. The proof constructs the decomposition explicitly: the bags of the path decomposition are precisely the memory configurations at each step. The regularity condition ensures that constraint lifetimes form contiguous intervals along the proof timeline, which is exactly the interval property required by path decompositions.

## Why This Matters

The implications flow in both directions across the bridge.

**From proofs to graphs:** Every lower bound technique from graph theory now potentially applies to proof memory. Pathwidth has been studied for decades. There are powerful methods — separator theorems, graph minor theory, cops-and-robbers games — that can establish pathwidth lower bounds. If clause space is linked to pathwidth, then these tools can prove that certain formulas *require* large memory to refute, a central question in computational complexity.

**From graphs to proofs:** Conversely, proof complexity results now illuminate graph structure. The configuration graph of a formula is a combinatorial object in its own right, with structure determined by the formula's logical content. Understanding its pathwidth reveals something about the geometry of the proof search landscape — where the bottlenecks are, where the solver must commit to holding many facts in mind simultaneously.

**For algorithm design:** Modern SAT solvers — the engines behind hardware verification, planning systems, and cryptanalysis — are essentially heuristic explorers of configuration space. Knowing the pathwidth of the relevant portion of this space suggests new strategies: when pathwidth is low, linear scanning strategies suffice; when it is high, the solver needs fundamentally different approaches. This could lead to *structurally adaptive* solvers that match their strategy to the geometric difficulty of the proof landscape.

## The Bottleneck Metaphor

There is a striking physical analogy. Think of the proof trace as water flowing through a landscape. The configurations are pools, the transitions are channels. Clause space is the maximum pool volume, and pathwidth measures the narrowest point the flow must pass through along any linear route.

In statistical mechanics, this is reminiscent of a free-energy barrier: the system (the prover) must pass through states of high "pressure" (many simultaneously active constraints) to get from the initial state to the final one. Pathwidth quantifies how sharp this bottleneck is when the landscape is linearized.

This is not mere metaphor. In the mathematical theory of graph searching — where pursuers try to catch an evader in a network — pathwidth exactly equals the minimum number of pursuers needed if they must search along a path. A clause space bound is literally a bound on how many "searchers" the prover deploys simultaneously. The theorem says the search complexity of the proof graph is controlled by this deployment number.

## A Hierarchy of Memory

The work introduces a new invariant called the *trace memory number* of a formula. This is defined as the minimum pathwidth achievable by any valid refutation trace — a graph-theoretic distillation of the proof memory concept. The central inequality proved is:

> The trace memory number of a formula is at most its minimum clause space minus one.

This establishes a hierarchy: proof memory (a combinatorial, proof-complexity quantity) dominates trace memory (a graph-theoretic, structural quantity). It opens the door to attacking clause space lower bounds through graph theory: to show a formula needs large clause space, it suffices to show its trace memory number is large, and trace memory can potentially be bounded using pathwidth methods.

## The Bigger Picture

The longer-term vision is a conjecture: that there exists a universal constant *c* such that for *every* unsatisfiable formula, the pathwidth of the full bounded configuration graph — not just the portion visited by one particular proof — is at most *c* times the minimum clause space. Computational experiments on small formulas support this, finding ratios of pathwidth to clause space consistently bounded by 3 or 4.

If true, this conjecture would mean that proof memory and configuration graph pathwidth are equivalent up to constants — a deep structural equivalence between how hard it is to *prove* something with limited memory and how *wide* the state space is that the proof must navigate.

This kind of equivalence is rare and powerful in mathematics. It would connect a complexity-theoretic resource (memory in proof systems) to a purely combinatorial graph invariant (pathwidth), enabling tools and insights to flow freely between two rich mathematical traditions.

## A New Language for Proof Search

What emerges from this work is not just a theorem but a language — a way of talking about proofs in geometric terms. A refutation is a walk. Memory is width. Clause space is a layout. The proof search landscape has a shape, and that shape constrains what provers can do.

For decades, proof complexity has developed in its own technical idiom, often inaccessible to researchers in graph theory, algorithms, or physics. Configuration graph pathwidth provides a universal translator. A graph theorist looking at the configuration graph sees familiar structure: trees, paths, separators, minors. A proof complexity theorist looking at a path decomposition sees familiar concerns: memory, strategy, lower bounds.

The gap between these communities is exactly where new mathematics tends to grow. By building a rigorous bridge — with definitions, theorems, and computational tools — between proof memory and graph width, this work opens a corridor that future researchers can walk in either direction.

And the first step along that corridor is a single, clean insight: the configurations a prover moves through, if it never forgets and re-learns the same fact, trace out a path decomposition whose width is bounded by how much it remembers.

Memory is not just a resource. It is a shape.
