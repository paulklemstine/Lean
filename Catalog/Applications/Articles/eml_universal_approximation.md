# The Hidden Grammar of Scientific Laws

*How a mathematical language built from three operations could revolutionize the way machines discover nature's formulas*

---

When Johannes Kepler sat down with Tycho Brahe's painstaking astronomical observations in the early 1600s, he spent years trying different mathematical shapes — circles, ovals, egg-shapes — before stumbling upon the ellipse. The right formula was hiding in the data all along, but the search was agonizing. Four centuries later, scientists still face the same problem, only now the data comes in terabytes and the potential formulas are infinitely more complex. What if there were a mathematical theory that could tell us not just *that* a formula exists, but exactly *how complex* it needs to be?

A new line of mathematical research suggests this might be possible — and the key turns out to be a surprisingly small toolkit: just exponentials, products, and logarithms.

## Three Operations to Rule Them All

Consider how many of nature's most important equations are built. Radioactive decay: $N(t) = N_0 e^{-\lambda t}$. The Boltzmann distribution: $p \propto e^{-E/kT}$. Power laws: $y = cx^n$. The normal distribution: $e^{-x^2/2}$. Compound interest: $A = P(1+r)^t$.

What do these all have in common? They are composed entirely from multiplication, exponentiation, and logarithms — with some addition thrown in. This is no coincidence. These three transcendental operations form a kind of algebraic *closure*: any combination of them produces another function that can be described using the same operations. Multiply two exponentials, you get another exponential. Take the logarithm of a product, you get a sum of logarithms. Exponentiate a logarithm, you get a power.

Mathematicians have now formalized this observation into what they call the **EML framework** — Exponential, Multiplicative, Logarithmic. An EML expression is a tree-structured formula built from six building blocks: constants, variables, addition, multiplication, exp, and log. The remarkable discovery is that this seemingly narrow language is *universal*: it can approximate any continuous function on a bounded interval to arbitrary precision.

## Beyond "Polynomials Are Enough"

The idea that simple function classes can approximate anything is not new. In 1885, Karl Weierstrass proved that polynomials — mere sums of powers of $x$ — can approximate any continuous function on a closed interval. This result is a cornerstone of mathematical analysis and underpins much of numerical computation.

But the Weierstrass theorem has a dirty secret: it says nothing about *efficiency*. Approximating a function like $e^{e^x}$ with polynomials is possible, but you might need a polynomial of degree 20 or more to get decent accuracy. That means 21 coefficients, 21 terms, a formula that no human could interpret.

The EML framework offers a radical alternative. The same function $e^{e^x}$ is exactly represented by a three-node EML expression: `exp(exp(x))`. Size 3 versus size 41. Depth 2 versus depth 40. This is not a marginal improvement — it is a compression ratio of more than 13 to 1.

This example illustrates a deeper principle: **compositional structure compresses description length**. When a function is built by nesting operations (compute something, then exponentiate it, then exponentiate again), a system that can represent nesting directly will always beat a system that has to flatten the composition into a long sum.

## A New Kind of Complexity

The mathematical breakthrough here is not just that EML can approximate things — it is that the *complexity of the approximation* can be precisely measured and controlled.

Imagine you have two functions, $f$ and $g$, and you know how to approximate each one with small EML expressions. What can you say about approximating $f + g$? Or $f \times g$? The new theory proves that these operations are *subadditive*: if $f$ needs an expression of size $m$ and $g$ needs size $n$, then $f + g$ needs at most $m + n + 1$. The extra "+1" is just the single addition node connecting the two approximants.

This subadditivity is the engine of compositional compression. If you are building a complex model out of simpler pieces — as scientists almost always are — the total complexity grows only as the *sum* of the parts, not as their product. In a world where modern machine learning models can have billions of parameters, this kind of structural guarantee is extraordinarily valuable.

The theory goes further, introducing what might be called a "resource-bounded Kolmogorov complexity" for functions. Kolmogorov complexity, named after the great Soviet mathematician, measures the shortest computer program that produces a given output. It is a beautiful idea but fundamentally uncomputable — you can never know for certain that you have found the shortest program. The EML description complexity is a practical analogue: the size of the smallest EML expression that approximates a function within a given tolerance. Unlike true Kolmogorov complexity, this quantity is bounded, measurable, and connected to concrete performance guarantees.

## The Information Bottleneck

Perhaps the most surprising connection is to information theory. When a signal passes through a series of processing layers — as in a deep neural network, or an EML expression with many nested operations — information is inevitably lost. Claude Shannon's theory tells us that noisy channels degrade information; the EML theory shows that even without noise, *compositional depth itself acts as an information filter*.

The formal result is elegant: if each layer of an EML architecture retains a fraction $\alpha$ of the symbolic information from the previous layer, then after $l$ layers, only $\alpha^l$ of the original information survives. For $\alpha = 0.9$ and $l = 20$ layers, that is $0.9^{20} \approx 12\%$ — already a substantial loss. For $\alpha = 0.5$ and $l = 20$, it is $0.5^{20} \approx 0.0001\%$ — essentially nothing.

This creates a fundamental tradeoff. Deep architectures are powerful because each layer can compute complex transformations. But deep architectures also *compress* information aggressively, meaning that only functions with low inherent complexity can survive the journey through many layers intact. Functions with high descriptive complexity simply cannot be represented by shallow expressions — they need structures that are both deep *and* wide, with many parallel pathways preserving different aspects of the target function.

This is, in essence, a mathematical explanation for why depth matters in neural networks. It is not just that deeper networks *can* represent more functions (the universal approximation theorem guarantees that even shallow networks can do this). It is that deeper networks represent *structured* functions more *efficiently*, and the precise efficiency gain is governed by the descriptive complexity of the target.

## From Theory to Discovery

What does this mean for working scientists? The EML framework suggests a concrete workflow for scientific law discovery:

1. **Collect data** from experiments or simulations.
2. **Search over bounded-size EML expressions** for the best fit.
3. **The description complexity of the best fit** tells you how "simple" the underlying law is.
4. **The depth of the best fit** tells you how deeply nested the underlying structure is.

This is more than curve fitting. A polynomial fit of degree 15 might match your data perfectly, but it tells you nothing about the structure of the phenomenon. An EML fit of `exp(-3/x)` tells you that the phenomenon involves exponential decay modulated by inverse proportionality — which is exactly the Arrhenius equation from chemical kinetics, one of the most important formulas in all of chemistry.

The promise is a kind of mathematical microscope: by examining the *structure* of the best-fitting EML expression, scientists can infer the *mechanism* generating their data. The theory guarantees that if a compact EML formula exists, the search will find it — and the formula's structure will reflect the true compositional architecture of the underlying process.

## The Road Ahead

This mathematical framework is still young, and many questions remain. Can the depth–complexity tradeoff be sharpened into an exact scaling law? Is there a rigorous "depth separation" — a proof that certain functions genuinely require deep nesting and cannot be approximated by wide but shallow expressions? Can the information-theoretic bounds be made tight enough to guide architecture design in practice?

Early computational experiments are encouraging. For families of composed exponentials — functions of the form $e^{p(x)}$ where $p$ is a polynomial — the EML depth needed for good approximation appears to grow linearly in the polynomial degree and logarithmically in the desired precision. This is dramatically better than the polynomial approximation, where the required degree grows as a power of $1/\varepsilon$.

The deeper implication is philosophical as much as practical. The fact that nature's laws tend to have small EML descriptions — that the universe's formulas are built from a handful of compositional operations — suggests that compositional structure is not just a mathematical convenience but a reflection of how physical reality is organized. The EML framework may be the beginning of a rigorous theory of why the universe is *comprehensible* — why its laws can be written on a single page, rather than requiring an encyclopedia.

If that sounds ambitious, consider the alternative: a universe whose laws were arbitrary, unstructured, and incompressible. In such a universe, science would be impossible. The fact that EML descriptions are short for physical laws is not just a mathematical curiosity — it may be the deepest reason why science works at all.

---

*The formal mathematical results described in this article have been machine-verified using interactive proof technology, providing the highest level of certainty that the theorems are correct. The proofs cover universal approximation, compositional complexity bounds, depth–complexity connections, and information-theoretic decay — establishing a new field at the intersection of approximation theory, information theory, and symbolic computation.*
