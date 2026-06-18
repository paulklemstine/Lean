# The Scissors and the Glue: How Mathematicians Found a New Language for Structure

## A discovery about polynomial "DNA" connects abstract algebra to network science, physics, and knot theory

---

Imagine you are holding a complicated recipe — not for food, but for a mathematical object called a polynomial. This recipe has ingredients (variables like *x*, *y*, *z*) and instructions (exponents that tell you how to combine them). The collection of all the different monomial terms in a polynomial — say *x²y*, *xy²*, *xyz* — forms a pattern called the **support**. It's like the polynomial's fingerprint, encoding its combinatorial structure.

For decades, mathematicians have known that certain polynomial supports possess a remarkable property: you can swap ingredients between any two terms and always stay within the support. This "exchange property," borrowed from a branch of mathematics called matroid theory, turns out to be the secret ingredient behind some of the most powerful polynomials in modern mathematics — the Lorentzian polynomials discovered by Petter Brändén and June Huh in 2020, work that contributed to Huh's Fields Medal.

But there was a missing piece. In matroid theory, two fundamental operations — **deletion** and **contraction** — allow mathematicians to break complex structures into simpler ones, like disassembling a machine to understand its parts. These operations are so central that the entire theory of graph invariants, network reliability, and even connections to knot theory flow from them. Yet nobody had shown that these same operations work at the level of polynomial supports.

Until now.

---

## The Scissors Operation

Think of a polynomial in three variables as a three-dimensional object. Each term corresponds to a point in space, and the support is the constellation of all those points. The operation of **deletion** at a variable — say, setting *x* = 0 — is like slicing this constellation with a plane. You keep only the points that lie on the *x* = 0 face. It's the mathematical equivalent of cutting away a dimension.

The key question: if your original constellation had the exchange property (meaning you could always swap ingredients between terms), does the slice still have it?

The answer, now proved rigorously, is yes. And the proof is surprisingly elegant. Suppose you have two terms in the slice — they both have *x* = 0. If one term has more *y* than the other, the exchange property in the original polynomial guarantees you can find a swap. The crucial insight is that this swap can never involve *x* itself. Why? Because both terms have *x* = 0, so neither can "give" or "receive" any *x*. The swap must happen entirely within the remaining coordinates, which means the swapped terms also have *x* = 0 — they stay in the slice.

This argument has the beauty of inevitability. Once you see it, it seems obvious. But it had never been formalized before.

## The Glue Operation

**Contraction** is subtler. Instead of cutting away, you are compressing. You take all the terms that use a variable minimally, reduce that variable's power to zero, and keep the resulting pattern. If deletion is cutting, contraction is squeezing.

The same argument works, with a twist. Elements in the contraction all have the same value at the contracted coordinate (they all achieved the minimum). So when you apply the exchange property, the swapping coordinate can't be the one you're contracting — both elements have equal values there. The exchange happens in the other coordinates, and the results still achieve the minimum. The operation is closed.

## Building a Machine

With both deletion and contraction preserving the exchange property, something powerful emerges: a **minor theory**. In mathematics, a minor is what you get by repeatedly applying these two operations. The collection of all minors of a support set forms a structured family, a lattice of simpler objects derived from the original.

This is exactly what matroid theory has: every matroid has minors, and the collection of minors carries rich structural information. But now, for the first time, we know that polynomial supports have the same structure.

Why does this matter? Because matroid minors are the engine behind some of the deepest theorems in combinatorics. The famous Robertson-Seymour theorem in graph theory — which took twenty years and over 500 pages to prove — is fundamentally about minors. The Tutte polynomial, one of the most important objects in discrete mathematics, is defined through a deletion-contraction recurrence. Network reliability, the Potts model in statistical physics, the Jones polynomial in knot theory — all of these are specializations of the Tutte polynomial, and all of them work because of minor theory.

## The Recursion Engine

With minors in hand, the next step is to build a recursive invariant — a quantity that can be computed by breaking a support into smaller pieces via deletion and contraction, then combining the results.

The construction follows the classical template: choose a coordinate, classify it as a "loop" (deletion produces nothing), a "coloop" (contraction changes nothing), or "regular" (both operations genuinely simplify). Then recurse:

- For a loop, multiply by a parameter *y* and contract.
- For a coloop, multiply by a parameter *x* and contract.  
- For a regular coordinate, add the values from deletion and contraction.

The base case — an empty support — has value 1. The recursion always terminates because each step reduces the size of the support.

This "support-Tutte invariant" captures the combinatorial essence of the support's structure in a single polynomial. For supports arising from classical matroids, it should recover the classical Tutte polynomial — a powerful consistency check.

## Why This Changes the Map

The significance of this work extends far beyond a technical theorem about polynomials. Consider the landscape it connects:

**Network science.** The reliability of a communication network — the probability that it stays connected when links fail randomly — is a specialization of the Tutte polynomial. A support-level Tutte theory means we can study reliability-like questions for much more general algebraic systems, not just graphs.

**Statistical physics.** The Potts model, which describes phase transitions in magnets and other systems, is also controlled by the Tutte polynomial. Support-level recursion suggests new recursive structures for partition functions of polynomial-valued models.

**Knot theory.** The Jones polynomial, which distinguishes different knots, is a specialization of the Tutte polynomial for planar graphs. The deletion-contraction structure at the support level hints at connections between polynomial supports and topological invariants.

**Tropical geometry.** Deletion corresponds to intersecting a Newton polytope with a coordinate hyperplane; contraction resembles tropical projection. A support minor theory could yield a tropical minor theory for valuated matroids.

**Discrete convex analysis.** The exchange property is the central axiom of M-convexity, the discrete analogue of convexity studied extensively in optimization. Knowing that M-convex sets form a minor-closed class opens new inductive proof strategies for discrete optimization problems.

## The Deeper Pattern

Perhaps most intriguing is what this suggests about the nature of mathematical structure itself. The exchange property is not just an abstract axiom — it appears naturally in the supports of Lorentzian polynomials, which are connected to Hodge theory, algebraic geometry, and the deepest questions about positivity in mathematics.

If every minor of a Lorentzian support is again Lorentzian — a conjecture now supported by computational evidence — then Lorentzian polynomials would form a minor-closed species in a precise sense. This would connect the Hodge-theoretic revolution of the 2010s (which proved long-standing conjectures about log-concavity using algebraic geometry) to the combinatorial revolution of minor theory.

The parallel is striking. In the 1960s and 1970s, matroid theory emerged as a unifying framework connecting graph theory, linear algebra, and combinatorial optimization. It took decades for the full power of this framework to be appreciated. Now, at the level of polynomial supports, we may be seeing the beginning of a similar unification — one that connects algebra, geometry, physics, and topology through the simple operations of cutting and squeezing.

## A New Language

Every scientific revolution begins with a new language. Newton gave us calculus to describe motion. Darwin gave us natural selection to describe evolution. Shannon gave us information theory to describe communication.

Deletion and contraction give us a language for describing how complex polynomial structures decompose into simpler ones. This language is native to the objects that matter most in modern algebraic combinatorics: generating functions, Newton polytopes, tropical varieties, log-concave sequences.

The theorems proved here are the grammar of this language — the rules that guarantee it is internally consistent. The vocabulary will grow as mathematicians discover what new phenomena it can describe. And the stories it will tell — about networks, phases, knots, and the geometry of positivity — are only beginning to be written.

What started as a question about swapping exponents in polynomials has opened a door to a new combinatorial world. The scissors and the glue, it turns out, were there all along. We just needed to look at the right level.
