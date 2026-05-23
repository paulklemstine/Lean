# The Geometry of Forgetting: How Mathematicians Proved That Memory Has a Shape

## A Computer That Reasons With a Notepad

Imagine trying to solve a giant logic puzzle — the kind that fills an entire wall — but you're only allowed to write on a small notepad. You can jot down facts, combine them, cross things out, but at no point can you have more than, say, five lines written at once. Could you still solve the puzzle? And if you managed to, could someone else check your work by looking only at the sequence of notepad snapshots, without understanding the puzzle at all?

This is not a hypothetical. It is the exact situation facing billions of computer chips every day, and mathematicians have just proved something remarkable about it: *the act of reasoning under memory constraints has a precise, finite geometry — and that geometry can be witnessed, certified, and checked.*

## The Billion-Dollar Question Behind Every Search

At the heart of modern computing lies a class of problems called Boolean satisfiability, or SAT. Given a logical formula — a web of "and," "or," and "not" — does some assignment of True and False make it all come out True?

SAT solvers are the unsung engines of the digital age. They verify microchip designs before fabrication. They schedule airline crews. They crack cryptographic puzzles and prove mathematical theorems. Every year, SAT solvers get faster, handling formulas with millions of variables. But there's a catch that has haunted computer science since the 1970s: when a solver says "unsatisfiable" — this formula has *no* solution — how do you know it's telling the truth?

The standard answer is a *proof certificate*: the solver emits a step-by-step record of its reasoning, and a separate, trusted checker verifies each step. The dominant format, called DRAT, has been a triumph of engineering. But DRAT certificates measure the *length* of a proof — how many reasoning steps were used. They say nothing about *memory*.

This matters enormously. A DRAT proof might use a million steps but only need a tiny scratch space, or it might sprawl across gigabytes of working memory. For embedded systems, spacecraft, and real-time controllers — anywhere memory is precious and must be budgeted — knowing that a proof *exists* is not enough. You need to know it fits.

## What the Mathematicians Built

A team of researchers has now established a complete mathematical theory of *clause-space certificates*: objects that certify not just "this formula is unsatisfiable," but "this formula is unsatisfiable *and the proof fits in s memory slots*."

The key insight is deceptively simple. Think of the solver's memory as a small whiteboard. At any moment, the whiteboard holds a few logical clauses — fragments of the original formula, or new facts derived from them. The solver can do three things:

1. **Download** a clause from the original formula (copy it to the whiteboard).
2. **Resolve** two clauses on the whiteboard to derive a new one (logical deduction).
3. **Erase** a clause to make room.

A *configuration* is a snapshot of the whiteboard at some instant. A *space certificate* is the entire sequence of snapshots — from a blank whiteboard to one containing the *empty clause* (the logical equivalent of "contradiction found"), with the whiteboard never holding more than *s* clauses at once.

This sounds straightforward, but the mathematical consequences are profound.

## Soundness: Why the Certificate Never Lies

The first major theorem is *soundness*: if such a certificate exists, the formula really is unsatisfiable.

The proof rests on a beautiful invariant. At every step, every clause on the whiteboard is *semantically entailed* by the original formula — meaning any assignment that satisfies the formula must also satisfy that clause. When you download a clause, it's already part of the formula, so this is trivially true. When you resolve two clauses, the resolvent inherits the same property (this is the classic soundness of resolution, going back to the 1960s). When you erase a clause, you simply have fewer things to check.

If you ever reach the empty clause — a clause with zero literals, which *no* assignment can satisfy — then the formula itself must be unsatisfiable, because any satisfying assignment would have to make the empty clause true, which is impossible.

What makes this theorem non-trivial is that it works for *any* space certificate, regardless of how it was generated. A human, a computer, or even a random process that happens to produce a valid certificate will have genuinely proved unsatisfiability.

## Completeness: Nothing Is Lost

The second theorem goes the other direction: if a bounded-space refutation *exists* in the abstract sense (as a sequence of allowed deduction steps), then it can always be packaged into a concrete certificate that the checker accepts.

This is the theorem that turns an abstract notion ("there exists a proof that fits in this much memory") into a practical engineering artifact ("here is the actual object, and here is how to check it"). Without completeness, the certificate framework would have a gap: some formulas might be refutable in bounded space but without any checkable witness.

## Monotonicity: More Memory Never Hurts

A third result captures something intuitively obvious but mathematically necessary: if you can refute a formula using *s* memory slots, you can certainly refute it using *s + 1*. More memory never makes things harder. This is the proof-complexity analogue of a principle from thermodynamics: giving a system more resources never reduces its capabilities.

## The Ternary Bridge: When Logic Meets Coding Theory

Perhaps the most surprising theorem concerns the *counting* of what's possible. How many distinct clauses can exist over *n* Boolean variables? Each variable can appear positively, negatively, or not at all — three choices per variable, giving exactly 3^n proper clauses. The researchers proved this by constructing an explicit injection from clauses to ternary vectors (strings over a three-letter alphabet), showing the map is one-to-one.

This isn't just bookkeeping. It connects clause-space theory to the mathematics of *coding theory* and *statistical mechanics*, where systems of three-state particles are a fundamental object of study. The same mathematical structure that governs error-correcting codes and magnetic materials governs the universe of logical clauses. Memory-bounded reasoning inherits the combinatorics of the ternary state space.

## A Finite Geometry of Proof

The deepest conceptual achievement is the realization that bounded-space reasoning has a *finite geometry*. The set of all possible memory configurations — whiteboards with at most *s* clauses — forms a finite directed graph. Nodes are configurations; edges are valid steps (download, resolve, erase). A space certificate is simply a *path* in this graph from the empty whiteboard to a contradiction.

This transforms proof complexity into graph exploration. Questions about proofs become questions about paths. "Does a space-*s* refutation exist?" becomes "Is the goal reachable from the start in the configuration graph?" And since the graph is finite, this question is decidable — it can always be answered, in principle, by exhaustive search.

The researchers proved an explicit upper bound on the number of nodes in this graph: at most the sum of binomial coefficients $\sum_{k=0}^{s} \binom{3^n}{k}$, where $n$ is the number of variables. For small $n$ and $s$, this is tractable. For larger values, it grows rapidly — but it is always *finite*, which is the point. The search space has a definite, computable size.

## Why This Matters Now

We live in an era of increasingly autonomous systems. Self-driving cars make millions of logical decisions per second. Satellites running verification algorithms cannot ask for more RAM. Neural network accelerators have fixed memory budgets and must certify their outputs.

For all these systems, the question is not just "can we verify this result?" but "can we verify it *within our resources*?" Clause-space certificates provide a mathematical framework for answering that question with mathematical certainty. They are the first objects to simultaneously certify both *correctness* (the answer is right) and *resource compliance* (the proof fits in the budget).

## The Road Ahead

The researchers' computational experiments on small formulas — up to 5 variables and space bound 4 — show that the BFS-based certificate search works effectively, finding certificates in milliseconds and verifying them independently. The pigeonhole principle, a famously hard family of formulas, requires progressively more space as the number of pigeons grows — consistent with known lower bounds from proof complexity.

Several open questions beckon. Is there a polynomial relationship between the time to find a certificate and the size of the reachable configuration space? Can space certificates be composed or compressed? What is the exact clause-space complexity of natural formula families like those arising in hardware verification?

Most tantalizing: can space certificates be extended to other proof systems — cutting planes, polynomial calculus, algebraic proofs — creating a unified theory of resource-bounded certification across all of mathematical reasoning?

The answer, whatever it turns out to be, will have the same flavor as the results proved here: the geometry of forgetting — the precise shape of what can be accomplished when memory is scarce — is itself a rich mathematical object, worthy of study on its own terms and powerful enough to change how we think about computation under constraint.

## The Takeaway

The next time your phone verifies a software update, or a power grid controller checks a safety condition, or a satellite confirms a navigation solution, the underlying logic is doing something like scribbling on a tiny notepad — downloading facts, combining them, erasing to make room. What these mathematicians have shown is that this process has a precise, certifiable structure. The sequence of notepad snapshots is itself a mathematical proof — one that can be checked by anyone, one that fits in a guaranteed amount of space, and one whose very existence tells us something deep about the geometry of reasoning under constraint.

Memory, it turns out, has a shape. And that shape can be proven correct.
