# The Geometry of Memory: How Mathematicians Discovered a New Way to Certify Reasoning Under Pressure

## A surprising connection between computer memory, puzzle solving, and the shape of proof

Imagine you are solving a jigsaw puzzle on a very small table. You can only spread out a handful of pieces at a time. If you need to compare a new piece against one you examined earlier, you may have to put something down first. The table — your working memory — is the bottleneck. The puzzle isn't harder in the abstract, but the constraint on how many pieces you can hold simultaneously transforms the problem entirely.

This scenario, it turns out, is not just a metaphor. It is the precise mathematical situation that arises every time a computer tries to prove that a logical formula has no solution. And a team of researchers has just shown that the dance of picking up and putting down pieces on that cramped table has a hidden geometric structure — one that can be certified, checked, and analyzed with the same rigor as a mathematical proof itself.

## The Billion-Dollar Question Behind Every Chip

Every modern microprocessor, every cloud server, every smartphone contains circuits whose correctness depends on solving a problem called SAT — short for *satisfiability*. Given a logical formula with hundreds of thousands of variables connected by AND, OR, and NOT, is there any combination of true-and-false assignments that makes the whole formula come out true?

If the answer is yes, you can exhibit a satisfying assignment as proof. But if the answer is no — if the formula is *unsatisfiable* — how do you convince someone? You can't just say "I tried everything." There are more possible assignments than atoms in the universe.

For decades, SAT solvers have produced proofs of unsatisfiability in a format called DRAT, which records the sequence of logical deductions that led to a contradiction. These proofs can be enormous — sometimes terabytes long — but they can be checked line by line. Each step follows from the previous ones by a simple rule.

What DRAT does not tell you is *how much memory the solver needed*. And memory, it turns out, is where the real complexity hides.

## The Memory Wall

In the 1990s, proof complexity theorists began studying a quantity called *clause space*: the maximum number of intermediate logical facts a solver needs to hold in memory at any moment during a proof. Think of it as the size of that jigsaw table.

They discovered something remarkable. Some formulas that are easy to refute with unlimited memory become exponentially harder when memory is restricted. The *pigeonhole principle* — the obvious fact that you can't fit four pigeons into three holes — requires a proof whose memory footprint grows with the number of pigeons, no matter how clever you are.

This created a strange gap in our understanding. We could certify that a formula is unsatisfiable (via DRAT), and we could measure how much memory a particular solver used. But we had no way to certify the memory requirement itself. Could you prove, in a checkable way, that a formula is unsatisfiable *within a given memory budget*?

## A New Kind of Certificate

The breakthrough comes from treating memory-bounded reasoning as a finite-state dynamical system. Here is the key insight: if you fix a set of variables and a memory bound *s*, the number of possible memory states is finite. Each state is just a set of at most *s* logical clauses, drawn from a finite universe. The transitions between states — loading a clause, deriving a new one by resolution, or erasing one to free space — form a finite directed graph.

A *space certificate* is simply a path through this graph. It starts at the empty state (no clauses in memory), ends at a state containing the *empty clause* (which represents a contradiction), and never passes through a state with more than *s* clauses.

This sounds almost trivially simple, but the consequences are profound.

First, **soundness**: any such path really does constitute a proof of unsatisfiability. This requires a genuine mathematical argument. You must show that every clause held in memory at every point along the path is *semantically entailed* by the original formula — that is, every truth assignment satisfying the formula also satisfies every clause in memory. When the empty clause appears, you have a contradiction: the empty clause is satisfied by nothing, yet it is entailed by the formula, so the formula must be unsatisfiable.

Second, **completeness**: if a formula *can* be refuted in space *s* by any means, then a valid space certificate exists. The abstract refutation can be unrolled, step by step, into a concrete path through the configuration graph.

Third, **finiteness**: because the graph is finite, you can search it exhaustively. The question "Is this formula refutable in space *s*?" becomes a graph reachability problem — can you get from the start node to a goal node? And graph reachability is algorithmically well understood.

## Counting the Landscape

How big is this graph? The researchers proved an elegant combinatorial bound. Each clause over *N* Boolean variables corresponds to choosing, for each variable, one of three options: the variable appears positively, it appears negatively, or it is absent. This gives at most 3^N possible clauses — a connection to the mathematics of ternary codes that links proof complexity to information theory.

The number of memory configurations of size at most *s* is then bounded by the sum of binomial coefficients:

> Configurations ≤ C(3^N, 0) + C(3^N, 1) + … + C(3^N, s)

For small *s* (and the interesting cases often have small *s*), this is polynomial in 3^N. The search space is vast but finite — and its size can be computed in advance.

## The Monotonicity Principle

One of the most satisfying results is the *monotonicity theorem*: if a formula is refutable in space *s*, it is automatically refutable in space *t* for any *t ≥ s*. More memory never hurts. This sounds obvious, but it requires proof: you must verify that every step valid under the tighter budget remains valid under the looser one.

The proof is beautifully simple. A space certificate is a sequence of memory states. If every state has at most *s* clauses and *s ≤ t*, then every state also has at most *t* clauses. The same sequence serves as a certificate for the larger budget.

This monotonicity is the analogue of a thermodynamic principle: increasing the available resources can never make a task impossible. It positions clause space as a genuine *resource* in the formal sense used by theoretical computer science.

## The Ternary Bridge

Perhaps the most surprising connection is the injection of clauses into ternary vectors. Define a mapping that sends each clause to a vector of length *N* over the alphabet {0, 1, 2}: 0 if the variable appears positively, 1 if negatively, 2 if absent. For *proper* clauses — those where no variable appears both positively and negatively — this mapping is injective. Different clauses get different codes.

This is more than a counting trick. It reveals that the space of proper clauses has the algebraic structure of a subset of a ternary Hamming space. Distances between clauses correspond to the number of variables on which they disagree. Resolution — the fundamental inference rule — becomes an operation in this coding-theoretic space. The geometry of proofs becomes, quite literally, a geometry.

## What the Computer Found

Running the search algorithm on all unsatisfiable formulas with two variables and up to three clauses produced striking results. Every unsatisfiable instance could be certified. The minimum space required was typically 3 — you need enough room to hold two parent clauses and their resolvent. The BFS search explored far fewer configurations than the theoretical bound: the ratio of explored states to the bound was often less than 1%.

The researchers also tested a conjecture: that BFS finds certificates in time at most quadratic in the number of reachable configurations. Across all 59 unsatisfiable instances tested, the conjecture held, with a maximum ratio of explored-to-reachable-squared of just 0.5.

## Why This Matters

The immediate practical implication is a new kind of SAT certificate. Current DRAT proofs certify *that* a formula is unsatisfiable. Space certificates certify that it is unsatisfiable *within a memory budget*. This is directly relevant to embedded systems, real-time verification, and any setting where memory is constrained.

But the deeper significance is conceptual. By treating bounded-memory reasoning as a finite dynamical system, the researchers have opened proof complexity to the tools of graph theory, combinatorics, and even statistical mechanics. The configuration graph is a state space; the certificate is a trajectory; the space bound is a thermodynamic constraint. These are not analogies — they are precise mathematical correspondences.

Consider what this means for artificial intelligence. Modern large language models and neural theorem provers operate under memory constraints. Understanding the geometry of memory-bounded reasoning could inform the design of more efficient AI systems — not by giving them more memory, but by helping them use the memory they have more wisely.

## The Road Ahead

Several tantalizing questions remain open. Is there a polynomial relationship between the minimum space and the minimum proof length? Can space certificates be composed — if you can certify two sub-formulas separately, can you combine the certificates? And what happens when you allow more powerful inference rules beyond resolution?

The ternary encoding hints at connections to error-correcting codes and information theory. Could the "distance" between clauses in ternary space predict the difficulty of finding proofs? Could techniques from coding theory yield better bounds on proof space?

Perhaps most ambitiously, the framework suggests a new approach to lower bounds in computational complexity. Proving that a formula *requires* space *s* means showing that no path exists in the configuration graph — that two regions of a finite state space are disconnected. Such arguments are the bread and butter of combinatorial topology, a field that has barely been applied to proof complexity.

What began as a practical question — "Can I certify that this chip is correct using only 64 kilobytes of working memory?" — has opened a window onto the deep geometry of reasoning under constraint. The jigsaw table turns out to have a shape, and that shape is telling us something fundamental about the nature of proof itself.
