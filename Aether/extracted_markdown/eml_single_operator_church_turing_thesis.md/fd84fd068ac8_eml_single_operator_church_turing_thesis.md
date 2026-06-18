# One Operator to Rule Them All: How a Single Mathematical Primitive Generates Every Elementary Function

## The Surprising Economy of Mathematics

In 1936, Alan Turing showed that a single, remarkably simple machine could compute anything computable. The Turing machine — with its tape, its head, its finite set of rules — was astonishingly minimal, yet computationally omnipotent. It was the "one ring" of computation: one device to do everything.

Now a parallel story is emerging in the mathematics of real-valued functions. Researchers have discovered that a single binary operation — combining the exponential function and the logarithm into one primitive — can generate every elementary function in mathematics: every polynomial, every trigonometric function, every power, every hyperbolic function, and all their combinations.

The operation is deceptively simple. Take two real numbers *a* and *b*. Compute *e^a − log(b)*. That's it. Call it the EML operator (for Exp-Minus-Log). From this single seed, the entire garden of classical analysis blooms.

## The Two Keys to the Kingdom

The magic of the EML operator lies in two identities that would fit on a cocktail napkin:

- **exp(x) = EML(x, 1)**: Set the second input to 1. Since log(1) = 0, the logarithm vanishes, and you're left with pure exponentiation.

- **log(y) = 1 − EML(0, y)**: Set the first input to 0. Since e⁰ = 1, the exponential contributes just a constant, and the logarithm emerges by subtraction.

These two identities are the Rosetta Stone of the EML theory. With exponentiation and logarithm both recoverable from a single operator, and with the field operations (addition, multiplication, division) available as the ambient arithmetic of the real numbers, every function that mathematicians call "elementary" falls within reach.

Polynomials? They're products and sums of the identity function — no transcendental operations needed. Hyperbolic sine and cosine? They decompose into exponentials: sinh(x) = (e^x − e^(−x))/2, and each exponential is an EML call. The mysterious function x^x (called tetration) decomposes as exp(x · log(x)) — two layers of EML.

## A Hierarchy of Transcendental Depth

But the real discovery isn't just that EML can express everything — it's that EML reveals a hidden *structure* within the elementary functions.

Define the **transcendental depth** of a function as the maximum number of nested EML applications needed to express it. Polynomials and rational functions have depth 0 — they need no transcendental operations at all. The exponential and logarithm sit at depth 1. The superexponential function exp(exp(x)) lives at depth 2. And in general, the *n*-fold iterated exponential exp(exp(…exp(x)…)) sits precisely at depth *n*.

This creates a filtration — a tower of nested function classes:

**EML₀ ⊂ EML₁ ⊂ EML₂ ⊂ ⋯**

At each level, the class is richer. At each level, new functions appear that genuinely could not be expressed at the previous level. And crucially, *field operations never increase the depth*. Adding two depth-1 functions gives a depth-1 function. Multiplying them does too. The depth measures something intrinsic — the essential transcendental content of a function, stripped of algebraic decoration.

This is not unlike the hierarchy of computability in Turing's world, where problems stratify by the number of oracle calls needed to solve them. Here, instead of oracle calls, we count layers of exponentiation.

## The Diagonal Gap: A Fixed-Point Desert

One of the most striking results concerns the **EML diagonal** — the function d(z) = EML(z, z) = e^z − log(z). This function measures the gap between exponential growth and logarithmic growth at each point.

The gap turns out to be surprisingly rigid. For every positive real number *z*, the diagonal exceeds *z* by at least 1. In symbols: d(z) − z ≥ 1. The exponential always outpaces the logarithm by a margin that never shrinks below 1.

This means the diagonal function has *no fixed points* on the positive reals. There is no positive number z satisfying e^z − log(z) = z. The exponential-logarithmic dynamics always push upward — the gap between exp and log is an unbridgeable chasm.

Furthermore, the diagonal is strictly convex on the positive reals. Its second derivative, exp(z) + 1/z², is manifestly positive. This means the gap function is bowl-shaped, achieving a unique minimum. That minimum occurs at a point z₀ satisfying the remarkable equation e^(z₀) = 1/z₀ — or equivalently, z₀ · e^(z₀) = 1. The solution is z₀ = W(1), where W is the Lambert W function, one of the special functions of analysis. The EML diagonal thus provides a natural variational characterization of the Lambert W function.

## Size Versus Depth: The Price of Transcendence

Every EML expression can be represented as a tree — constants and variables at the leaves, operations at the internal nodes. The **size** of an expression is the number of nodes; the **depth** is the maximum nesting of EML applications.

A precise tradeoff governs these two quantities: any expression of depth *d* must have at least 2d + 1 nodes. You cannot achieve deep transcendental nesting without proportional cost in expression size. This bound is tight — a chain of *d* nested EML applications with constant arguments achieves exactly 2d + 1 nodes.

This result is the information-theoretic shadow of a deeper principle: transcendental complexity requires structural investment. You cannot cheaply simulate deep exponentiation.

## The Universality Thesis

The results fit together into what might be called the **EML Universality Thesis**: *a single binary operator, combining exponential and logarithmic operations, is computationally universal for the class of elementary real functions.*

This is not a theorem about Turing machines or digital computation. It is a statement about the algebraic structure of classical analysis. The elementary functions — the functions that generations of calculus students have studied — have a hidden unity. Beneath their apparent diversity (sines, cosines, exponentials, logarithms, powers, roots), they are all compositions of one primitive.

The thesis has a provocative neural-network interpretation. A "neuron" computing EML(wx + b, w'x + b') — a single nonlinear unit combining weighted exponential and logarithmic activations — is, in principle, a universal building block for approximating elementary functions. Traditional neural networks use many neurons with simple activations (like ReLU or sigmoid); the EML perspective suggests that fewer neurons with richer activations might suffice.

## The Open Frontier

The deepest question remains open: is the depth hierarchy *strict*? We know that exp(exp(x)) is depth-2 representable. But can it be sneakily rewritten as a depth-1 expression using clever algebraic manipulations?

The conjecture is that it cannot. The argument, connecting to classical differential algebra, goes like this: depth-1 functions should correspond to Liouvillian functions — those satisfying first-order linear ordinary differential equations with rational coefficients. The function exp(exp(x)) satisfies the ODE f' = e^x · f, where the coefficient e^x is itself transcendental. This suggests exp(exp(x)) transcends the Liouvillian class, making depth-2 genuinely necessary.

If the hierarchy is strict, then transcendental depth becomes a bona fide complexity measure — a ruler for the intrinsic difficulty of real functions, as fundamental in its domain as computational complexity is in the world of algorithms.

## A New Lens on Old Functions

What makes this work exciting is not the formalism itself but what it reveals. The EML framework provides a new lens through which to view functions that mathematicians have known for centuries. It reveals that the elementary functions have a natural complexity hierarchy, that exponential and logarithmic operations play fundamentally dual roles (as the two inputs of a single operator), and that the gap between exponential growth and logarithmic growth has rigid geometric properties (convexity, a unique minimum, connection to the Lambert W function).

The EML operator is not just a curiosity — it is a coordinate system for the space of elementary functions. And like all good coordinate systems, it makes certain structures visible that were previously hidden.

As Turing showed that computation has a single universal primitive, the EML theory suggests that real analysis might have one too. One operator. All functions. A mathematical universe from a single seed.
