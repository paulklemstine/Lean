# The Hidden Layers of Shape: How Mathematicians Found a New Way to Measure Geometric Depth

## A question of curvature, all the way down

Imagine holding a bowl. Its interior curves upward in every direction — a simple, intuitive kind of convexity. Now imagine something stranger: a bowl whose curvature itself curves, and whose curvature-of-curvature also curves, layer after layer, like an infinite stack of nested Russian dolls made entirely of geometric structure. How deep does the curvature go?

This is not a fanciful question. It turns out to be a precise mathematical one, and answering it has led to a new tool for understanding some of the most important objects in modern combinatorics, optimization, and even statistical physics.

## The problem: discrete worlds lack smooth tools

In continuous mathematics — the world of calculus and differential equations — measuring curvature is old technology. You take derivatives, combine them into matrices, and read off eigenvalues. A surface that curves the same way everywhere has constant curvature; one that curves differently in different directions has variable curvature. The tools are powerful and well-understood.

But much of modern mathematics and computer science lives in *discrete* worlds. Networks, graphs, combinatorial structures, and tropical geometry operate on lattice points — integer grids rather than smooth surfaces. Here, the classical tools break down. You cannot take a derivative of a function defined only at integer points in the usual sense.

For decades, mathematicians have worked around this limitation using a concept called *log-concavity*. A sequence of positive numbers $a_0, a_1, a_2, \ldots$ is log-concave if $a_n^2 \geq a_{n-1} \cdot a_{n+1}$ for every $n$. This is the discrete analog of saying the logarithm of the function is concave — it curves downward. Log-concavity shows up everywhere: in the coefficients of polynomials with only real roots, in the theory of matroids (abstract structures that generalize the notion of independence in linear algebra), and in the celebrated work of June Huh and Petter Brändén on Lorentzian polynomials, which earned Huh a Fields Medal in 2022.

But log-concavity is a blunt instrument. It tells you about one layer of curvature. It says nothing about what happens when you peel that layer back and look underneath.

## The breakthrough: peeling back layers with ratio transforms

The new insight is elegant: apply a *ratio transform* and see what survives.

Given a function $f$ on integer lattice points, the ratio transform in a given direction replaces each value by the ratio of neighboring values: $R_i f(m) = f(m + e_i) / f(m)$. This is a discrete analog of taking a logarithmic derivative — it strips away one layer of multiplicative structure and exposes the next.

The key question: *is the result still log-concave?*

If $f$ is log-concave and its ratio transform is also log-concave, we say $f$ has *depth at least 2*. If that ratio transform's ratio transform is also log-concave, the depth is at least 3. And so on.

This creates a filtration — a tower of increasingly strict conditions:

$$\text{depth 0} \supset \text{depth 1} \supset \text{depth 2} \supset \text{depth 3} \supset \cdots$$

Every function has depth at least 0 (trivially). Many interesting functions have depth 1 (they are log-concave). But depth 2, 3, and beyond? That is where the new mathematics lives.

## Why it matters: three worlds connected

The depth filtration is not just an abstract curiosity. It connects three seemingly unrelated areas of mathematics.

**Tropical geometry.** When you take the negative logarithm of a positive function, you enter the "tropical" world — a shadow of algebraic geometry where addition replaces multiplication and minimum replaces addition. The researchers proved that depth at least 1 guarantees the tropicalized function is *supermodular* — a strong convexity condition in the lattice-point world. Higher depth means this tropical convexity persists under repeated transformations, producing a tower of tropical convex potentials. This is the seed of what could become a "higher tropical curvature theory."

**Matroid theory and combinatorial optimization.** Matroids are abstract structures that capture the essence of independence — think of them as generalizations of the idea that a set of vectors is linearly independent. *Valuated* matroids add a numerical weight to each independent set, and their theory (developed by Dress and Wenzel, and later by Murota under the name "M-convexity") is foundational in discrete optimization. The depth filtration provides a new invariant that is strictly finer than the classical exchange axioms: two valuated matroids might satisfy the same exchange conditions but have different depths, revealing hidden structural differences.

**Statistical physics.** In the language of statistical mechanics, $f$ is a partition function — a sum of Boltzmann weights — and $-\log f$ is an energy landscape. The ratio transform produces *chemical potentials*: the energy cost of adding one more particle of a given type. Depth measures the persistence of convexity in these response functions. A system with depth 2 has not only a convex energy landscape but also convex chemical potentials — its response to perturbations is itself well-behaved. This is directly relevant to understanding phase transitions and stability in lattice models.

## The multiplicative miracle

Perhaps the most surprising result is that depth is *multiplicative*. If two functions each have depth at least $k$, then their product also has depth at least $k$. This is not obvious: multiplying functions generally makes inequalities harder to maintain, not easier. The proof works by induction, exploiting a beautiful algebraic identity: the ratio transform of a product is the product of the ratio transforms.

$$R_i(f \cdot g) = R_i(f) \cdot R_i(g)$$

This identity is the algebraic engine that makes the entire theory work. It means the set of functions with depth at least $k$ forms a multiplicative monoid — a closed algebraic structure. This is the mathematical backbone that elevates the depth concept from a curiosity to a robust invariant.

## A dichotomy conjecture

Computational experiments across hundreds of examples reveal a striking pattern: for every naturally arising valuated matroid tested, the depth is either 1 (for indicator functions of matroid bases) or appears to be infinite (for algebraically constructed valuations like multinomial coefficients or Grassmannian Plücker coordinates).

This leads to a bold conjecture: *there are no natural examples of finite depth greater than 1*. The depth filtration divides the world of valuated matroids into two classes — the "combinatorial" (depth 1) and the "algebraic" (infinite depth) — with nothing in between.

If true, this would be a remarkable structural theorem, suggesting that the algebraic origins of a valuated matroid leave an indelible fingerprint in its curvature profile. If false, the counterexample would likely reveal new and unexpected mathematical structures.

## The bigger picture

The depth filtration sits at the confluence of several major trends in mathematics. The explosion of interest in Lorentzian polynomials and their connections to Hodge theory has shown that positivity phenomena in algebra have deep geometric meaning. Tropical geometry has matured from a curiosity into a major computational and theoretical framework. And discrete convex analysis has become indispensable in optimization, economics, and algorithm design.

What the depth filtration adds is a *hierarchy*. Rather than asking "is this function log-concave?" — a yes-or-no question — we can now ask "how deeply log-concave is it?" The answer is a number (or infinity), and that number carries geometric, algebraic, and physical meaning simultaneously.

This is reminiscent of other hierarchy-based breakthroughs in mathematics. The classification of singularities in algebraic geometry, the regularity hierarchy in PDE theory, and the hierarchy of computational complexity classes all share a common pattern: replacing a binary distinction with a graded one reveals structure that was previously invisible.

## What comes next

The immediate mathematical agenda is clear: extend the theory to handle functions with zeros (requiring more delicate support conditions), prove or disprove the dichotomy conjecture, and connect the depth invariant to the existing rich theory of Lorentzian polynomials.

But the longer-term potential is broader. Any system that can be modeled by a function on a lattice — and there are many, from machine learning models to quantum information to epidemiological networks — could potentially benefit from a depth analysis. High depth means robust convexity, which means reliable optimization. Low depth means fragility, which means caution is warranted.

The hidden layers of geometric shape, it turns out, have been there all along. We just needed the right tool to see them.
