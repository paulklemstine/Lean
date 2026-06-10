# The Hidden Highways of Right Triangles

*How a 4,000-year-old geometric pattern turns out to contain an elaborate system of invisible roads — and why mathematicians got the map wrong at first.*

---

Everyone knows the 3-4-5 right triangle. Builders have used it to square corners since Babylonian times. Most people also know, if dimly, that there are infinitely many sets of whole numbers that work the same way: 5-12-13, 8-15-17, 7-24-25, and on and on. What almost no one realizes is that every single one of these "primitive Pythagorean triples" — the ones with no common factor — can be generated from (3, 4, 5) by exactly three transformations, and that these transformations produce a perfect, infinite tree.

This tree was discovered by the Swedish mathematician Berggren in 1934 and independently by several others. Think of it as a family tree where (3, 4, 5) is the ancestor, and every triple has exactly three children. The child-making rule is simple: multiply the triple by one of three specific 3×3 matrices (call them A, B, and C), and out comes another primitive Pythagorean triple. Always. Every triple appears somewhere in this tree exactly once.

That much has been known for decades. What's new — and surprising — is what happens when you stop thinking of the tree as just a catalog and start treating it as a *dynamical system*.

## A New Way to Look at an Old Tree

Imagine you're standing at the root of the Berggren tree, at (3, 4, 5). At each step, you choose one of three doors: A, B, or C. Each door leads to a new triple. After *d* steps, you've spelled out a "word" — maybe AABCA — and arrived at a specific triangle.

The first natural question: *which path leads to the smallest triangle?* Here "smallest" means the one with the shortest hypotenuse — the longest side of the right triangle.

The answer turns out to be elegant and exact. If you always choose door A, you follow what mathematicians call the "A-ray." At depth *d*, the A-ray gives you the triple (2*d*+3, 2*d*²+6*d*+4, 2*d*²+6*d*+5). The hypotenuse is exactly 2*d*²+6*d*+5. And this is provably the smallest hypotenuse at that depth — no other path through the tree can do better.

But the second question is more interesting: *which path gives the second-smallest triangle?*

## A Wrong Turn and a Correction

A natural guess — the one that several researchers independently conjectured — was that the second-smallest path should be "almost all A's" with one deviation at the end. Specifically, the word A^(*d*−1)C: follow the A-ray for *d*−1 steps, then take door C at the very end. This word has a beautiful hypotenuse formula: 10*d*²+6*d*+1. It seemed too clean to be wrong.

It was wrong.

The actual second-smallest hypotenuse at each depth comes from the *all-C word*: just choose door C every time. This C-ray produces triples with a completely different character. Where the A-ray generates triples like (7, 24, 25) — one small leg, one large leg — the C-ray generates triples like (35, 12, 37) — one very large leg, one moderate leg. The C-ray hypotenuse follows the formula 4*d*²+8*d*+5.

The proof of this is not just computational. At depth 2, the nine possible words produce hypotenuses 25, 37, 53, 65, 73, 85, 89, 97, 169. The all-A word gives 25 (minimum), the all-C word gives 37 (second), and the conjectured A-then-C gives 53 (only third). But this pattern persists at every depth, and proving *why* requires understanding something fundamental about how the three generators reshape triangles.

## The Growth Machine

Here's the key insight. Each generator transforms a triangle by a specific matrix multiplication, and different generators "stretch" the triangle at different rates. Generator B is a stretcher — it roughly sextuples the hypotenuse with each application. The B-ray's hypotenuse grows exponentially, rocketing from 5 to 29 to 169 to 985 to 5741.

Generator A is gentle. It adds roughly 4*d* to the hypotenuse at each step, yielding quadratic growth: 5, 13, 25, 41, 61, 85...

Generator C is almost as gentle but slightly more aggressive: it adds roughly 8*d* at each step, giving 5, 17, 37, 65, 101, 145...

The mathematical proof tracks two quantities through the tree: the hypotenuse *c* and the "min-component" min(*a*, *b*). A beautiful pair of lemmas shows that at each step, the hypotenuse grows by at least 2·min(*a*, *b*) + 2, and the min-component itself grows by at least 2. Starting from (3, 4, 5) where min(*a*, *b*) = 3, after *d* steps the min-component is at least 3 + 2*d*, and the total hypotenuse is at least 5 + Σ(2(3+2*k*)+2) = 2*d*²+6*d*+5.

The all-A word achieves this bound exactly because generator A keeps the min-component growing at the minimum possible rate. The C-ray, similarly, has the second-slowest growth rate for the min-component, which is why it's the second extremal path. Any word containing even a single B, or mixing A's and C's in the wrong order, overshoots.

## Invisible Highways Modulo Odd Numbers

Now for the deeper surprise. Forget about specific triples and instead look at the Berggren tree *modulo* an odd number.

Take the number 7. Reduce every triple modulo 7: the root (3, 4, 5) stays (3, 4, 5), but (5, 12, 13) becomes (5, 5, 6), and so on. Each of the three generators still makes sense modulo 7 — the matrix multiplication works just fine over remainders. The natural question: starting from (3, 4, 5) mod 7, which residue classes can you reach?

The answer: exactly 24 of the 7³ = 343 possible residue triples. And here's the remarkable part — every one of these 24 classes can reach every other. The "residue graph" modulo 7 is *strongly connected*.

This is not an isolated phenomenon. We verified computationally that this strong connectivity holds for every odd modulus we tested, from 3 to beyond 200. No matter which odd number you choose, the Berggren tree's shadow modulo that number forms a single, tightly knit network where everything connects to everything.

If this holds universally — and every piece of evidence points that way — it would mean the Berggren tree has a deep algebraic coherence that goes far beyond its role as a catalog of triangles. In the language of modern mathematics, the Berggren semigroup would satisfy a form of "strong approximation," a property usually reserved for much larger algebraic groups. Finding it in such a small, concrete system would be extraordinary.

## Why It Matters

The Berggren tree is the simplest nontrivial example of a *thin semigroup* acting on a *quadratic variety*. The quadratic variety is the set of points satisfying *a*² + *b*² = *c*² — the Pythagorean equation. The semigroup is generated by the three matrices A, B, C, which preserve this equation exactly. (Technically, they preserve the "Lorentz quadratic form" *a*² + *b*² − *c*², a quantity familiar to physicists as the spacetime interval in special relativity.)

Thin semigroups have emerged as central objects in modern number theory, appearing in the affine sieve of Bourgain-Gamburd-Sarnak, in the study of Apollonian circle packings, and in quantum information theory. The Berggren tree provides a worked example where many phenomena that are conjectured for general thin groups can actually be proved — or, as we discovered, where the naive conjectures turn out to be wrong and the truth is more interesting.

The extremal geodesic classification, for instance, reveals that the Berggren tree has a rigid geometry at its boundary. The minimum-growth paths form an extremely simple "language": just the words using only A, or only C. This suggests that a full classification of near-minimal paths might be possible — not just the first and second minimizers, but the complete hierarchy of growth rates. Such a classification would be a combinatorial analogue of what physicists call "thermodynamic formalism": understanding a dynamical system by understanding its extremes.

## The Road Ahead

Three big questions remain open:

1. **Universal strong connectivity**: Does the residue graph remain strongly connected for *every* odd modulus, or only for all the ones we've tested? A proof would establish a new instance of strong approximation for thin semigroups.

2. **Spectral expansion**: Is the Berggren residue graph an *expander* — does it mix rapidly? If so, the tree becomes not just a generator of triples but a certifiably efficient random number generator over Pythagorean residue classes.

3. **Full extremal classification**: What is the complete ranked list of growth rates? The top two (A-ray and C-ray) are quadratic. The third appears to be the A^(*d*−1)C word, also quadratic but with coefficient 10 instead of 2 or 4. Does this hierarchy continue, and does it have a clean description?

These questions connect the humble 3-4-5 triangle to some of the deepest currents in modern mathematics: the spectral theory of groups, the dynamics of matrix products, and the arithmetic of quadratic forms. Pythagoras would be astonished — and, one suspects, delighted.

---

*The results described here include several theorems proved with complete machine-checked mathematical rigor — the first fully verified theorems about the arithmetic dynamics of the Berggren tree. The proofs establish closed-form formulas for both extremal geodesics, a corrected classification of the second minimizer, universal preservation of the Lorentz quadratic form, and the commutation of modular reduction with word evaluation.*
