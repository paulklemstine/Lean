# How SAT Solvers Could Discover the Next Circuit Lower Bound

## The 200-Terabyte Proof That Changed Everything

In 2016, three computer scientists did something no human mathematician had ever done: they proved a theorem using a proof file so large it would fill more than forty thousand Blu-ray discs. The result itself was deceptively simple — a question about coloring the integers with two colors while avoiding a certain pattern. But the method was revolutionary. It showed that brute-force computation, guided by the right mathematical structure, could crack problems that had resisted decades of human ingenuity.

The problem was this: can you color every positive integer either red or blue so that no Pythagorean triple — a set of three numbers satisfying $a^2 + b^2 = c^2$, like 3, 4, 5 — is all the same color? Marijn Heule, Oliver Kullmann, and Victor Marek proved the answer is no, at least once you get past the number 7824. Up to that point, such a coloring exists. At 7825, it becomes impossible.

What made the proof remarkable wasn't just the answer. It was the machinery: a SAT solver, a program designed to determine whether a logical formula can be satisfied. The solver explored an astronomical number of possibilities, pruning dead ends with ruthless efficiency, until it found that no valid coloring exists. Then it produced a certificate — a mathematical proof that could be independently verified — weighing in at 200 terabytes.

This was a watershed moment. It demonstrated that certain combinatorial problems, long thought to require creative human insight, could be reduced to a systematic search. But it raised an even more tantalizing question: could the same approach discover something truly new about the limits of computation itself?

## The Hidden Geometry of Hitting Sets

To understand how SAT solvers might tackle the deepest problems in computer science, we need to understand a beautiful mathematical structure that connects coloring problems, circuit complexity, and optimization.

Imagine a collection of overlapping circles drawn on a table. A *hitting set* (or *transversal*) is a collection of points such that every circle contains at least one of your chosen points. Finding the smallest such collection is a fundamental optimization problem with applications from database theory to drug design to network security.

Now here's the key insight: this hitting set problem is secretly the same thing as a very particular kind of logical puzzle. In a *monotone* Boolean formula, every variable appears only positively — you can set variables to true, never to false, and the formula only gets "more satisfied" as you set more variables to true. Finding a minimum-cost satisfying assignment for such a formula is exactly the same as finding a minimum hitting set.

This equivalence — between geometry (which circles to hit) and logic (which variables to set true) — is not just an elegant curiosity. It means that any combinatorial search problem with this monotone structure can be handed directly to a SAT solver. And remarkably, many of the deepest unsolved problems in computer science have exactly this structure.

## Flowers in the Garden of Complexity

One of the most powerful tools for reasoning about hitting sets comes from an unexpected source: sunflowers. Not the botanical kind, but a mathematical abstraction discovered by Paul Erdős and Richard Rado in 1960.

A *sunflower* is a collection of sets that all overlap in exactly the same way — they share a common "core" (the center of the flower), and their remaining elements (the "petals") are completely disjoint from each other. Think of it like an actual sunflower: every petal attaches to the same central disc, but the petals don't touch each other.

The Sunflower Lemma says that any sufficiently large collection of small sets must contain a sunflower. This has a profound consequence for hitting sets: if you find a large sunflower within your hypergraph, the core elements become mandatory picks for any efficient transversal. You can prune petals without losing optimality, dramatically shrinking the search space.

Recent work has shown that for hypergraphs with bounded edge size (where no set is too large), this sunflower pruning leads to algorithms that are *fixed-parameter tractable* — their running time depends exponentially only on the size of the solution, not on the size of the entire input. When the hypergraph also has monotone structure (meaning that extending a set only makes covering easier), the pruning becomes even more powerful.

## From Pythagorean Triples to Circuit Barriers

The Pythagorean coloring problem illustrates a broader pattern. The set of Pythagorean triples within {1, 2, ..., n} forms a hypergraph. A valid two-coloring is equivalent to partitioning the vertices into two independent sets — two sets, each avoiding a complete triple. This is closely related to finding transversals of the "complement" hypergraph.

Now consider a far more ambitious target: proving lower bounds on circuit complexity. A *circuit lower bound* shows that a particular function — say, detecting whether a graph contains a triangle — cannot be computed by any circuit smaller than a certain size. Such results are the holy grail of theoretical computer science; proving strong enough circuit lower bounds would resolve the famous P versus NP problem.

Here's where the connection becomes electrifying. Suppose you want to show that no monotone circuit of size $s$ can solve triangle detection on $n$ vertices. You need to find *certificates* — carefully chosen input pairs that any small circuit must misclassify. The set of all certificates that refute a given circuit forms a hypergraph edge. Finding the minimum number of certificates needed to refute *all* circuits of size $s$ is precisely a minimum hitting set problem — and by our equivalence theorem, a monotone SAT problem.

This means that discovering circuit lower bounds could, in principle, be automated. Encode the certificate search as a monotone SAT instance, feed it to a solver, and let the machine find the proof.

## The Tropical Connection

There's a third perspective on this problem that hints at even deeper mathematical structure. In *tropical geometry*, the usual operations of addition and multiplication are replaced by minimum and addition (or maximum and addition, depending on convention). This seemingly bizarre substitution turns polynomial algebra into piecewise-linear geometry — curves become collections of line segments, surfaces become polyhedral complexes.

Each certificate in the circuit lower bound game defines a halfspace in a tropical parameter space. The minimum transversal corresponds to the minimum number of tropical halfspaces needed to separate all valid circuits from all invalid ones. This connects circuit complexity to questions about *tropical rank* — the minimum dimension of a tropical linear space containing certain points.

If this connection can be made rigorous, it would open an entirely new approach to circuit lower bounds: instead of combinatorial case analysis, one could use the geometric tools of tropical algebraic geometry — a field with its own deep theorems and computational methods.

## The Phase Transition Hypothesis

Random SAT formulas exhibit a remarkable *phase transition*: below a critical ratio of clauses to variables, almost all formulas are satisfiable; above it, almost none are. This transition is sharp, like water freezing at exactly 0°C.

Does the same phenomenon occur for circuit-refutation SAT instances? If so, there would be a critical circuit size $s^*$ below which certificates are abundant (lower bounds are easy to find) and above which they become impossibly rare. Finding this phase transition would tell us exactly where to aim our computational efforts — and might even predict, before anyone proves it, what the true circuit complexity of problems like triangle detection will turn out to be.

Early computational experiments for small cases (6-8 vertices) suggest that such a transition may indeed exist, with the critical point falling near a clause-to-variable ratio of about 4.2 — tantalizingly close to the known threshold for random 3-SAT.

## What Comes Next

The vision is both modest and audacious. Modest, because the mathematical ingredients — hitting sets, monotone SAT, sunflower pruning — are well-understood individually. Audacious, because combining them could transform circuit lower bound discovery from an art practiced by a handful of virtuosos into a systematic computational pipeline.

The immediate next steps are concrete and testable. Can SAT solvers find optimal certificate families for triangle detection on 10 or 12 vertices? Does the LP relaxation of the certificate hypergraph have a bounded integrality gap (which would mean simple greedy algorithms are near-optimal)? Does sunflower pruning reduce the search space by 90% or more for moderately sized instances?

Each of these questions can be answered by computation. And each answer, whether positive or negative, would advance our understanding of why proving circuit lower bounds is so hard — and how we might finally break through.

The 200-terabyte proof showed that computers can discover combinatorial truths beyond human reach. The framework described here suggests they might do the same for the central mysteries of computational complexity. We are building, brick by mathematical brick, a bridge between the world of SAT solving and the world of circuit complexity. No one knows yet what lies on the other side. But the tools are ready, the mathematics is sound, and the computation awaits.
