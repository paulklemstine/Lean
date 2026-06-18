# The Hidden Mathematics of Neural Networks: How Exponentials and Logarithms Approximate Everything

*A century-old theorem meets modern machine learning*

---

In 1937, Marshall Stone proved one of the most beautiful theorems in mathematics: any continuous function can be approximated, to arbitrary precision, by a sufficiently rich algebra of simpler functions. The theorem was abstract — it said nothing about *which* functions to use or *how fast* the approximation converges. Nearly ninety years later, a new line of research is filling in those blanks, with surprising implications for how neural networks learn.

## The Two Functions That Built the Universe

If you had to pick two mathematical functions to build the universe from, you could do worse than the exponential and the logarithm. The exponential governs radioactive decay, compound interest, population growth, and the distribution of energy across quantum states. The logarithm measures earthquakes, sound intensity, information content, and the pH of your morning coffee.

What's less obvious is that these two functions, combined with addition and multiplication, can approximate *any* continuous function whatsoever. Not just polynomials or trigonometric functions — literally any function you can draw without lifting your pen.

This is the central discovery of a new mathematical framework called **EML interpolation theory** (for Exponential-Multiply-Log). The theory doesn't just prove that approximation is *possible* — it reveals the precise geometric structure behind *how* it works, and introduces a new mathematical object that quantifies the "similarity" between points as seen through the lens of exponential-logarithmic computation.

## The Kernel That Sees in Log-Space

Imagine you're comparing the sizes of planets. Mercury and Venus differ by a factor of about 1.5 in diameter. Jupiter and Saturn also differ by a factor of about 1.5. In absolute terms, the Jupiter-Saturn difference is enormous — tens of thousands of kilometers. But in *relative* terms, these pairs are equally different.

The **EML interpolation kernel** formalizes this idea. It defines the "similarity" between two positive numbers x and y as:

$$K(x, y) = e^{-(\log(x/y))^2}$$

This kernel has remarkable properties. It equals exactly 1 when x = y (perfect similarity). It's always between 0 and 1. It's symmetric: K(x,y) = K(y,x). And crucially, it measures similarity in *ratio space* rather than *difference space*. The numbers 1 and 2 are just as "similar" as 100 and 200 — they have the same ratio.

Plot this kernel and you see a beautiful Gaussian bell curve — not in ordinary space, but in logarithmic space. This isn't coincidence. The EML kernel is essentially a Gaussian process kernel on the logarithmic scale, bridging the worlds of approximation theory and machine learning.

## A Strict Hierarchy of Complexity

Not all EML computations are created equal. The theory introduces a **depth measure** that counts how many times exponentials and logarithms are nested. At depth 0, you have polynomials — functions built from addition and multiplication alone. At depth 1, you can use one layer of exp or log, giving you functions like x² · e^x or log(x) · x³. At depth 2, you get exp(exp(x)), log(log(x)), and all their algebraic combinations.

Here's the surprising part: these depth levels form a *strict hierarchy*. There are functions that require depth 2 that no depth-1 function can approximate. The iterated exponential tower — exp(exp(exp(···(x)···))) of height n — requires exactly depth n, and nothing less will do.

This mirrors a deep phenomenon in computer science called the *circuit complexity hierarchy*, where certain computations provably require circuits of a minimum depth. The EML depth hierarchy is a continuous analogue of this discrete phenomenon, suggesting that the architecture of a neural network (how many layers it has) is not merely an engineering choice but a mathematical necessity for representing certain functions.

## Stone-Weierstrass Meets Machine Learning

The classical Stone-Weierstrass theorem says: if you have a collection of continuous functions that (a) can tell any two points apart and (b) includes the constant functions, then you can approximate anything. The EML algebra passes both tests with flying colors.

The logarithm, all by itself, "tells points apart" — if x ≠ y and both are positive, then log(x) ≠ log(y). And the constant function 1 = exp(0) is trivially in the algebra. So by Stone-Weierstrass, the EML algebra is dense in the space of all continuous functions on any compact subset of the positive reals.

But the new theory goes further. It provides a *quantitative* version: for a function that doesn't vary too wildly (technically, a Lipschitz function), you can estimate how complex an EML expression you need to approximate it to a given accuracy. This transforms Stone-Weierstrass from a pure existence theorem into a practical design guide for neural architectures.

## The Vandermonde Connection

One of the most elegant results connects EML interpolation to a 200-year-old matrix called the Vandermonde matrix. Given n distinct positive numbers x₁, x₂, ..., xₙ, the matrix with entries xᵢʲ (the i-th point raised to the j-th power) is always invertible. This means: given any n values you want to hit, there is a unique polynomial of degree n-1 (an EML depth-0 function) that passes through all of them.

The EML perspective reveals why: each column of the Vandermonde matrix is the function x ↦ xʲ = exp(j · log(x)), which is an EML function of depth 1. The non-degeneracy of the Vandermonde matrix is really a statement about the linear independence of EML basis functions — a fact with deep implications for the expressiveness of neural networks built from exponentials and logarithms.

## Beyond Approximation: The EML Modulus

Perhaps the deepest new concept is the **EML modulus of continuity**. Traditional analysis measures how much a function varies using the ordinary distance |x - y| between points. The EML modulus instead uses the logarithmic distance |log(x) - log(y)|.

Why does this matter? Because many natural functions are smoother in log-space than in linear space. The function x^α (for any power α) has bounded EML modulus even though its ordinary modulus depends on the scale. This means EML networks can approximate power-law functions more efficiently than traditional polynomial methods — a fact highly relevant for scientific computing, where power laws are ubiquitous.

The kernel decay estimate makes this precise: when two points have log-distance at most δ, the EML kernel between them is at least e^{-δ²}. This gives a guaranteed lower bound on how much information about one point can be "transferred" to nearby points, the fundamental mechanism behind interpolation.

## What It Means for AI

Modern neural networks routinely use exponentials (in softmax layers, attention mechanisms) and logarithms (in loss functions, normalization layers). The EML interpolation theory suggests this isn't accidental — it's mathematically optimal.

The depth hierarchy, in particular, has implications for architecture design. If a target function has high EML depth (many nested levels of exp/log structure), then shallow networks literally cannot represent it. This provides a theoretical justification for deep architectures that goes beyond empirical observation.

The EML kernel opens up a new approach to kernel methods in machine learning, where similarity is measured in log-space rather than Euclidean space. For data with multiplicative structure — financial time series, biological growth curves, physical scaling laws — this could provide more natural and efficient learning algorithms.

## The Road Ahead

The EML interpolation theory is still young, with many open questions. Can the depth hierarchy be made quantitative — how much *better* can depth-(n+1) functions approximate compared to depth-n? Does the EML kernel define a reproducing kernel Hilbert space with useful properties? And perhaps most ambitiously: can the theory explain why specific neural network architectures work well on specific types of data?

These questions live at the intersection of approximation theory, functional analysis, and machine learning — a fertile triangle of mathematics where ancient theorems continue to illuminate cutting-edge technology. The exponential and the logarithm, humanity's oldest analytical tools, still have new stories to tell.

---

*This article describes research in EML interpolation theory, developing a mathematical framework for understanding function approximation using exponential and logarithmic operations.*
