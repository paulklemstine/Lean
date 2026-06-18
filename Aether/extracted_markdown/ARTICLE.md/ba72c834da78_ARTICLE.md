# The Six Immortal Rules: Why Only a Handful of Simple Automata Can Remember Their Past

*A surprising mathematical result reveals that among 256 elementary cellular automata, exactly six are perfectly reversible — and they all work the same astonishingly simple way.*

---

In 1961, IBM physicist Rolf Landauer posed a question that would haunt physics and computer science for decades: when a computation erases information, where does it go? His answer — it turns into heat — established a fundamental link between information and thermodynamics. But the deeper question Landauer raised was about *reversibility*: under what conditions can a computation be run backward, perfectly reconstructing its inputs from its outputs?

This question finds its sharpest expression in the world of cellular automata — the mathematical universes that Stephen Wolfram has spent a career exploring. A cellular automaton is a row of cells, each black or white, that evolves according to a simple rule: each cell looks at itself and its two nearest neighbors, and decides its next color based on what it sees. There are exactly 256 possible rules for this setup (called "elementary" cellular automata), and they produce an astonishing variety of behaviors — from boring uniformity to apparent chaos to structures that can simulate any computer ever built.

But which of these 256 rules are *reversible*? Which ones preserve all information, so that seeing the output uniquely determines the input? This is more than an abstract question: it's the computational analog of asking whether the laws of physics are time-reversible.

## The Surprising Answer: Six, and Only Six

The answer turns out to be both elegant and unexpected. Of the 256 elementary cellular automata, exactly **six** are universally reversible — meaning their global evolution map is a perfect bijection (a one-to-one and onto mapping) regardless of the lattice size.

What makes this result striking is *why* these six rules are special. They don't share an obvious pattern when you look at their rule numbers (15, 51, 85, 170, 204, 240). But they share a hidden structural property that, once you see it, makes the result feel almost inevitable.

## The Single-Dependency Principle

Every elementary CA rule takes three inputs — the left neighbor, the cell itself, and the right neighbor — and produces one output. The six reversible rules are precisely those that **ignore two of their three inputs entirely**.

- Rule 204 copies the center cell (the identity)
- Rule 51 flips the center cell (logical NOT)
- Rule 240 copies the left neighbor (a spatial shift)
- Rule 15 flips the left neighbor
- Rule 170 copies the right neighbor (opposite shift)
- Rule 85 flips the right neighbor

Each reversible rule does the same simple thing: pick one neighbor, copy or flip its value. That's it. No mixing. No combining. No logic gates.

This is the "single-dependency principle": a rule is reversible if and only if it depends on at most one of its three inputs and applies a reversible function (identity or negation) to that input.

## Why Mixing Destroys Information

The key insight is that *any genuine combination of multiple inputs inevitably creates collisions* — situations where two different inputs produce the same output. Consider the XOR rule (Rule 90), which outputs the exclusive-or of the left and right neighbors. This seems like it should be perfectly well-behaved: XOR is a fundamental operation in cryptography and error correction, after all.

But on a cyclic lattice of just three cells, XOR is fatally lossy. The all-zeros state (000) and the all-ones state (111) both evolve to the same thing (000), because 0⊕0 = 0 and 1⊕1 = 0. Information has been irreversibly destroyed.

This isn't a special property of XOR. It's universal: whenever a rule combines information from multiple spatial positions, the overlapping neighborhoods on a cyclic lattice create feedback loops that guarantee collisions. The only way to avoid this is to not mix information at all.

## The Factorization Theorem

The mathematical heart of the result is a *factorization theorem*. Each reversible rule decomposes cleanly into two operations:

1. **An index permutation**: a cyclic shift of the lattice (reading from the left, center, or right neighbor)
2. **A pointwise transform**: applying identity or negation to every cell independently

Both operations are trivially reversible — cyclic shifts can be undone by shifting the other way, and double negation returns to the original. Their composition is therefore also reversible. And this factorization exists *only* for the six single-dependency rules.

The inverse of each rule has a beautiful structure: swap the shift direction (left ↔ right) and keep the negation the same. Rule 240 (copy left) is reversed by Rule 170 (copy right). Rule 15 (flip left) is reversed by Rule 85 (flip right). Rules 204 and 51, which don't shift at all, are their own inverses.

## Connections to Thermodynamics

This result connects directly to the thermodynamics of computation. A theorem from the theory of reversible computing states that a function has zero entropy loss — no heat generation, no information destruction — if and only if it is a bijection. Combined with the single-dependency characterization, this gives a complete picture: the thermodynamically free elementary CAs are precisely those that read one neighbor and apply a bijection.

This is Landauer's principle made concrete. Every other rule — every rule that combines information from multiple neighbors — must dissipate energy proportional to the information it destroys.

## The Deeper Pattern

Why three choices of neighbor times two choices of transform? The six reversible rules form a structure isomorphic to ℤ/3ℤ × ℤ/2ℤ — three spatial positions crossed with two Boolean bijections. This isn't a coincidence. It reflects the fundamental symmetries of the one-dimensional lattice: cyclic shifts (a discrete translation symmetry) and the binary flip (the only nontrivial automorphism of the two-element alphabet).

Extending to higher-radius automata, where each cell can look at more distant neighbors, the number of reversible rules grows, but the structure remains the same: each reversible rule must be a single-dependency rule. For radius *r* (looking at 2r+1 neighbors), there are 2(2r+1) reversible rules: (2r+1) choices of which neighbor to read times 2 choices of bijection. The proof is the same factorization argument.

## What This Means

The single-dependency characterization says something profound about the nature of information in discrete dynamical systems. Reversibility — the ability to reconstruct the past from the present — requires a radical kind of simplicity. You cannot mix information from different spatial positions without destroying some of it.

This has implications beyond cellular automata. In any system where local operations combine information from multiple sources (as most interesting computations do), achieving reversibility requires augmenting the system with auxiliary storage — "garbage bits" in the language of Bennett's reversible computing theory. The single-dependency principle quantifies exactly when this extra storage is unnecessary: only when the operation is trivially simple.

The result also connects to the Garden of Eden theorem from symbolic dynamics, which characterizes surjectivity (and hence bijectivity, in the finite case) of cellular automata. But where the Garden of Eden theorem works with infinite lattices and topological arguments, the single-dependency characterization works directly with finite cyclic lattices and algebraic factorization — a more elementary but equally sharp result.

## Looking Forward

The most tantalizing open question is what happens in two dimensions. For one-dimensional CAs, reversibility is decidable and completely characterized. But for two-dimensional CAs on finite grids, the reversibility question becomes dramatically harder — in fact, it has been shown to be undecidable in general. The clean algebraic structure of the one-dimensional case may not survive the passage to higher dimensions.

But the single-dependency principle suggests a productive line of attack: even in higher dimensions, the single-dependency rules (those reading from exactly one position in their neighborhood) will always be reversible. The question is whether other reversible rules can emerge from the richer geometric structure of two-dimensional neighborhoods.

The answer, whatever it turns out to be, will tell us something fundamental about the relationship between locality, information, and the arrow of time in discrete universes.

---

*This research establishes a complete formal characterization of reversible elementary cellular automata, connecting discrete dynamics, information theory, and thermodynamics through the novel SingleDepCA abstraction.*
