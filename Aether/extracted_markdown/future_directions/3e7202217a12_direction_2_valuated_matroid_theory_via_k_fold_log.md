# The Hidden Layers of Mathematical Curvature

## How a New "Depth" Measurement Reveals Secret Structure in Combinatorial Objects

---

In 1935, the British mathematician Hassler Whitney introduced an idea so abstract that most mathematicians politely ignored it for decades. He called it a *matroid* — a structure that captures the essence of independence, the mathematical DNA shared by linearly independent vectors, spanning trees in networks, and algebraically independent field extensions. It was, Whitney believed, the skeleton key that would unlock connections between seemingly unrelated areas of mathematics.

He was right, but it took eighty years for the full payoff to arrive.

In 2020, June Huh and Petter Brändén published a landmark paper proving that a vast class of mathematical objects called *Lorentzian polynomials* — cousins of the equations governing spacetime in Einstein's general relativity — provide the hidden architecture behind some of the deepest combinatorial inequalities known. Their work resolved conjectures that had stood open for decades and won Huh the Fields Medal in 2022.

But one question remained tantalizingly open: *How deep does this Lorentzian structure go?*

---

## Peeling the Onion

Imagine you have a sequence of positive numbers — say, the coefficients of a polynomial that counts something meaningful: spanning trees in a network, matchings in a graph, or independent sets in a database. A fundamental property of such sequences is *log-concavity*: the square of each middle term is at least as large as the product of its neighbors. Formally, $a_n^2 \geq a_{n-1} \cdot a_{n+1}$ for every $n$.

Log-concavity is like saying the sequence has a single "hump" — it rises, peaks, and falls without wobbling. It's a surprisingly powerful condition. Knowing that a sequence is log-concave immediately tells you about its concentration properties, its central limit behavior, and the efficiency of algorithms that sample from it.

But here's the surprise: log-concavity itself has *layers*.

Take that same sequence and form its *ratio sequence*: $r_n = a_{n+1} / a_n$. If the original sequence is log-concave, the ratios are decreasing — each step up gets proportionally smaller. Now ask: is this ratio sequence *also* log-concave? If yes, form *its* ratio sequence, and ask again.

Each time you can peel away another layer and still find log-concavity, you've discovered a deeper structural regularity. A sequence that survives $k$ layers of this process is called *$k$-fold log-concave*. The hierarchy is strict: each level imposes genuinely stronger constraints.

The depth at which this process fails — the number of layers you can peel before hitting a bump — is a new invariant: the *Lorentzian depth*.

---

## From Sequences to Landscapes

The real power emerges when we move from sequences to multidimensional functions. Instead of a single row of numbers, imagine a function defined on a lattice — a grid of integer points in $n$-dimensional space. This is the natural setting for *valuated matroids*, where the function assigns a "weight" to each possible basis of a combinatorial structure.

In this setting, the ratio transform acquires a direction. Instead of a single ratio sequence, there are $n$ different ratio transforms — one for each coordinate direction. The function $f(m)$ defined on integer vectors $m = (m_1, \ldots, m_n)$ gets transformed into

$$R_i f(m) = \frac{f(m + e_i)}{f(m)}$$

where $e_i$ is the unit vector in direction $i$. This is the discrete analog of the logarithmic derivative $\partial_i \log f$, the mathematical tool that extracts curvature information from a surface.

The $k$-fold directional log-concavity hierarchy then works as follows: at each depth level, we check that the function satisfies a convexity condition in every direction, then apply all ratio transforms and check again. The depth at which this tower collapses measures the "smoothness" of the underlying valuated matroid.

---

## Why This Matters: Three Bridges

What makes the Lorentzian depth genuinely novel is that it simultaneously connects to three different mathematical worlds.

**Bridge 1: Tropical Geometry.** Taking the negative logarithm of a log-concave function converts multiplication into addition — this is the *tropicalization* map that transforms questions about multiplicative inequalities into questions about additive (min-plus) algebra. We proved that $k$-fold directional log-concavity at depth 1 implies *tropical convexity*: the tropicalized function satisfies the discrete midpoint inequality

$$2 \cdot (-\log f(m + e_i)) \leq (-\log f(m)) + (-\log f(m + 2e_i))$$

This means the curvature hierarchy, born from purely combinatorial considerations, speaks the language of tropical geometry — the geometry of the "maximally degenerate" limit where multiplication becomes addition and addition becomes minimum.

**Bridge 2: Discrete Convex Analysis.** Kazuo Murota's theory of M-convexity provides the algebraic foundation for discrete optimization — the exchange axiom that guarantees efficient algorithms for finding optimal bases. The Lorentzian depth refines M-convexity: two valuated matroids with the same exchange structure can have different depths, potentially distinguishing matroids that are otherwise indistinguishable by classical invariants like the Tutte polynomial.

**Bridge 3: Multiplicative Stability.** Perhaps the most striking structural result is that the $k$-fold classes form *multiplicative monoids*. If two functions are both $k$-fold directionally log-concave, their pointwise product is too. This is the product stability theorem, and it means the depth hierarchy is preserved under the most natural algebraic operation — a property that hints at deeper categorical structure.

---

## The Infinite-Depth Mystery

There's a puzzle at the heart of this theory: every "natural" valuated matroid we've tested has *infinite* depth.

The uniform matroid valuation — the multinomial coefficients that arise as coefficients of $(x_1 + \cdots + x_n)^d$ — survives every depth level. So do the constant functions (trivially) and the exponential-linear families. The pattern is striking: naturally occurring valuated matroids seem to live at the deepest level of the hierarchy.

This leads to a bold conjecture: *Is there a valuated matroid with M-convex support that has finite but nontrivial Lorentzian depth?* Specifically, does there exist a valuation with depth exactly 2 — one that is 2-fold directionally log-concave but fails at depth 3?

If no such example exists, it would suggest a deep rigidity theorem: M-convexity alone might force infinite depth, meaning the entire hierarchy collapses for well-behaved matroids. If such an example does exist, it would define a new invariant that genuinely refines the classical matroid taxonomy.

The most promising candidates for finite depth are *graphic matroid valuations* — weight functions on spanning trees of graphs. The complete graph $K_4$ has 16 spanning trees, and generic edge weights might produce a valuation whose curvature profile is rich enough to have finite depth. Computational experiments are underway.

---

## The Bigger Picture

The Lorentzian depth invariant is part of a broader revolution in how mathematicians think about combinatorial objects. For most of the twentieth century, combinatorics was seen as the "art of counting" — a collection of clever tricks for enumerating configurations. The breakthrough insight of the Brändén-Huh era is that counting problems come equipped with hidden geometric structure, and this structure carries real information.

Log-concavity isn't just a pretty inequality — it's a symptom of underlying geometry. The $k$-fold hierarchy takes this idea to its logical conclusion: the depth of log-concavity measures how much geometry is present. A shallow depth means the object has some geometric regularity but harbors hidden singularities. An infinite depth means the object is as smooth as the mathematics allows.

This perspective has practical implications. In network design, the reliability polynomial of a network — the probability that it remains connected as edges randomly fail — has coefficients that are log-concave. The Lorentzian depth of this polynomial measures the *robustness* of the network's connectivity: deeper means more resilient. In statistical physics, the partition function of the Ising model on a graph has coefficient sequences whose depth profile tracks the nature of phase transitions.

The tools are in place. The hierarchy is defined, the structural theorems are proved, and the computational machinery is built. What remains is the detective work: mapping out the landscape of depth values across the zoo of valuated matroids, identifying the boundary between finite and infinite depth, and discovering what this boundary tells us about the deep structure of combinatorial objects.

Hassler Whitney's skeleton key, it turns out, has more teeth than anyone imagined. The question now is which doors they open.
