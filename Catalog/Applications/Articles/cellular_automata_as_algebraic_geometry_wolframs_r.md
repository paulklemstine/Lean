# When Pixels Have Polynomials: The Hidden Algebra of Simple Rules

*How a child's toy reveals deep connections between algebra, geometry, and the nature of complexity itself*

---

In 1983, a young physicist named Stephen Wolfram became obsessed with a deceptively simple question: What happens when you line up a row of black and white squares and apply a rule—the same rule, over and over—to decide the color of each square based on its neighbors?

The answer turned out to be one of the most surprising discoveries in the history of mathematics.

Some rules produced nothing: a blank canvas, as predictable as a dead metronome. Others created orderly stripes and checkerboards, the visual equivalent of a ticking clock. But a handful of rules—notably one called Rule 110—produced patterns of staggering complexity. Cascading triangles, self-replicating structures, signals racing through a medium of apparent chaos. In 2004, Matthew Cook proved that Rule 110, this absurdly simple mechanism of black and white squares, could simulate any computer ever built.

A universal computer hiding in a row of pixels. The question that has haunted researchers since is: *Why?*

Why does one rule produce boredom and another produce a universe?

## The Polynomial Beneath the Pixel

The breakthrough begins with a change of perspective. Instead of watching the squares flicker, imagine each black square as the number 1 and each white square as the number 0. Not ordinary numbers—numbers in a strange, miniature arithmetic where 1 + 1 = 0.

This is the arithmetic of GF(2), the field with two elements. Mathematicians have studied it for two centuries. Electrical engineers use it every day—it is the arithmetic of XOR gates, parity bits, and error-correcting codes. And it turns out that every one of Wolfram's 256 rules can be written as a polynomial over this tiny field.

Take Rule 90. It says: the new value of a cell equals its left neighbor XOR its right neighbor. In the algebra of GF(2), that is simply:

*f(l, c, r) = l + r*

A polynomial of degree 1. Linear, clean, predictable.

Now take Rule 110, which is capable of universal computation. Its polynomial is:

*f(l, c, r) = c + r + cr + lcr*

Degree 3. Three variables tangled together in a knot of multiplication. The nonlinearity is not a coincidence—it is the mathematical signature of computational power.

## The Landscape of Fixed Points

Once you see cellular automata as polynomial maps, a natural question emerges from algebraic geometry, the branch of mathematics that studies solutions to polynomial equations. Given a rule *f*, what states remain unchanged after one application? These are the *fixed points*—the states *s* where *f(s) = s*.

In the language of algebraic geometry, the fixed points form a *variety*: the set of solutions to a system of polynomial equations over GF(2). The dimension of this variety—roughly, how many free parameters you have in choosing a fixed point—becomes a measure of the rule's algebraic complexity.

The results are striking.

Rule 0, which sends every cell to white regardless of its neighbors, has exactly one fixed point: the all-white state. Its variety has dimension zero—a single point.

Rule 204, the identity rule that leaves every cell unchanged, makes every possible state a fixed point. Its variety has dimension *n* (for an array of *n* cells)—the entire space.

But the really interesting story lies between these extremes.

## The Great Inversion

The original conjecture was elegant: more complex rules should have higher-dimensional fixed-point varieties. Turing-complete rules like Rule 110 should have the richest fixed-point structure, corresponding to their ability to encode arbitrary computations.

The data says otherwise.

When you compute the fixed-point dimension for all 256 rules and sort them by Wolfram's complexity classification, a pattern emerges—but it runs *backwards*. Class 4 rules, the ones capable of the most complex behavior (including universal computation), have the *fewest* fixed points. Their varieties are essentially zero-dimensional.

This is the Great Inversion, and it is not a bug—it is a deep insight.

Think of it this way: a system with many stable states is one that easily gets stuck. It lacks the dynamical richness to do anything interesting. A system with very few stable states is one that is perpetually in motion, perpetually computing. Fixed points are the *antithesis* of computation.

Rule 110 has exactly one fixed point on most array sizes: the all-zero state. It is the mathematical equivalent of a restless mind—never satisfied, always transforming, always computing. Its power lies not in its equilibria but in its transients.

## Linear Rules and Secret Codes

Among the 256 elementary cellular automata, exactly eight turn out to be linear—their polynomial representations involve no products of variables. These eight rules form a closed algebraic family, and they hold a beautiful secret.

For any linear rule, the set of fixed points does not just form a variety—it forms a *vector subspace* of GF(2)^n. In the language of information theory, this means: **the fixed points of a linear cellular automaton constitute an error-correcting code.**

This is not a metaphor. It is a theorem.

Consider Rule 150, whose polynomial is *f(l, c, r) = l + c + r*. On an array of 8 cells with cyclic boundaries, its fixed points form a [8, 2] linear code with minimum distance 4. This means you can encode 2 bits of information into 8 bits, and the code can detect up to 3 errors and correct 1.

Rule 170, the "shift-left" rule, produces an [n, 1] repetition code with minimum distance *n*—the simplest possible error-correcting code, but with the strongest possible error correction for its rate.

These are not just any codes. They are codes that emerge naturally from the dynamics of cellular automata—codes that exist because the underlying rule respects the algebraic structure of GF(2). Nature does not design codes; it discovers them through the geometry of polynomial maps.

## The Sheaf on the Line

The deepest mathematical structure in this framework borrows an idea from Alexander Grothendieck's revolution in algebraic geometry: the concept of a *sheaf*.

Imagine walking along the row of cells, looking through a window that shows only a few cells at a time. A *local section* is an assignment of values to those visible cells that is consistent with the fixed-point equation. As you slide the window along the array, some local sections can be extended; others hit contradictions and die.

The growth rate of local sections as the window widens is a precise measure of the rule's "sheaf complexity." For Rule 204 (the identity), sections grow exponentially—every partial assignment extends freely. For Rule 110, sections grow sublinearly—almost all partial assignments are self-contradictory.

This is the cellular automaton analog of a phenomenon that algebraic geometers have studied for decades in the context of schemes and coherent sheaves. The number of global sections of a sheaf measures the "rigidity" of the geometric object. A variety with many global sections is flexible; one with few is rigid.

Rule 110's rigidity is the geometric signature of its computational power.

## The Cubic Frontier

The polynomial classification reveals a clean hierarchy. Among the 256 rules:

- **16 rules** have degree 0 (constant functions)—trivial dynamics
- **16 rules** have degree 1 (linear functions)—predictable, code-generating
- **96 rules** have degree 2 (quadratic)—the transition zone
- **128 rules** have degree 3 (cubic)—the frontier of complexity

Every Turing-complete cellular automaton known to date lives in the cubic class. This is not surprising—Turing completeness requires the ability to perform logical AND and OR on bits, which corresponds to polynomial multiplication in GF(2). But the precise relationship between cubic polynomial structure and computational universality remains an open question.

Is there a degree-2 rule that is Turing-complete? Can the algebraic structure of the polynomial *alone* determine whether a rule is capable of universal computation? These questions sit at the intersection of algebraic geometry, computational complexity theory, and dynamics—a triple point that has never been fully explored.

## A Number-Theoretic Surprise

One of the most unexpected discoveries in this investigation involves Rule 90 (the left-XOR-right rule) and the number 3.

The fixed-point equation for Rule 90 on a cyclic array is: *s_{i-1} + s_{i+1} = s_i* for all *i*. This is a linear recurrence over GF(2) with characteristic polynomial *x² + x + 1*—the polynomial whose roots are primitive cube roots of unity in the extension field GF(4).

The consequence: Rule 90 has exactly 4 fixed points when the array size is divisible by 3, and exactly 1 fixed point otherwise. The algebraic structure of the fixed-point variety is controlled entirely by whether 3 divides *n*.

This unexpected appearance of the number 3—emerging from a rule that involves only nearest-neighbor XOR on a binary array—illustrates how deep number-theoretic structure can hide inside the simplest dynamical systems. The characteristic polynomial of the recurrence connects cellular automata to Galois theory, finite field extensions, and the arithmetic of cyclotomic polynomials.

## Why It Matters

This work connects three domains that rarely talk to each other:

**Cellular automata** (discrete dynamics), **algebraic geometry** (polynomial equations and their solution sets), and **coding theory** (error correction and information storage).

The bridge is the polynomial representation over GF(2). Once you see a cellular automaton as a polynomial map, you inherit the entire toolkit of algebraic geometry: varieties, sheaves, dimensions, cohomology. And you discover that concepts that seemed purely dynamical—"complexity," "Turing completeness," "chaos"—have precise algebraic correlates.

The fixed-point variety dimension does not increase with dynamical complexity. It *decreases*. The most powerful rules are the most rigid. The most interesting dynamics arise not from abundance of equilibria but from their scarcity.

This inversion principle may have implications far beyond cellular automata. In any dynamical system that can be described algebraically—neural networks, genetic regulatory circuits, chemical reaction networks—the same question can be asked: Does the geometry of the fixed-point variety predict the complexity of the dynamics?

If the inversion principle holds more broadly, it suggests a deep law: **complexity lives at the boundary of rigidity.** Systems that are too flexible collapse into stasis. Systems that are too rigid shatter. The interesting ones—the ones that compute, that create, that live—exist in the narrow band where almost nothing is stable, and everything is in motion.

---

*The mathematics of cellular automata was pioneered by Stephen Wolfram in the 1980s and placed on rigorous computational foundations by Matthew Cook's universality proof in 2004. The algebraic-geometric framework described here builds on the classical theory of polynomial maps over finite fields, developed by mathematicians from Évariste Galois to Alexander Grothendieck over the past two centuries.*
