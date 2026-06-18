# The Tower That Cannot Be Shortened

## Why adding more variables can't simplify the most complex mathematical expressions

Imagine stacking exponentials. Take a number, raise *e* to that power. Then raise *e* to *that* result. Do it again. And again.

This process—called iterated exponentiation—creates numbers that grow with terrifying speed. Raise *e* to the power 1, and you get about 2.7. Raise *e* to *that*, and you get about 15. One more layer, and you are at 3.8 million. Another, and the result exceeds the number of atoms in the observable universe by a factor that itself exceeds the number of atoms in the observable universe.

Mathematicians have long known that these towers of exponentials are intrinsically complex: you cannot build a four-layer tower using only three layers of exponentiation. That may sound obvious, but stating it precisely and proving it rigorously requires a careful theory of what "building" means.

Now a new result extends this insight into uncharted territory. It shows that the complexity of exponential towers is not merely a feature of single-variable expressions. Even when you have access to many variables—dozens, hundreds, or any number at all—the tower cannot be made shorter. The depth of the tower is a fundamental geometric property of the function itself, immune to the tricks that additional variables might offer.

## A Language for Building Functions

To make this precise, mathematicians work with a formal language of expressions. Think of it as a simple programming language with just a few operations: you can use constants (like 2 or 3.14), variables (like *x* and *y*), addition, multiplication, and exponentiation. No subtraction, no division, no logarithms—just the "forward" operations. Mathematicians call this the *inverse-free EML fragment*, where EML stands for "exp-mul-log" (though here we exclude the log).

Every expression in this language has a *depth*: the maximum number of times exponentiation is nested along any branch of the expression tree. The expression *e*^*x* has depth 1. The expression *e*^(*e*^*x*) has depth 2. The expression *x* + *y* has depth 0, because no exponentiation appears at all.

The question that drives this research is deceptively simple: **What is the minimum depth needed to compute a given function?**

## The Single-Variable Story

For functions of one variable, the answer has been known for some time. Define iterExp(*n*, *x*) as the result of applying exponentiation *n* times to *x*:

- iterExp(0, *x*) = *x*
- iterExp(1, *x*) = *e*^*x*
- iterExp(2, *x*) = *e*^(*e*^*x*)
- iterExp(3, *x*) = *e*^(*e*^(*e*^*x*))

The minimum depth to compute iterExp(*n*, *x*) is exactly *n*. You can build it with *n* nested exponentials, and you provably cannot do it with fewer. The proof uses a growth-rate argument: depth-*d* expressions grow at most as fast as iterExp(*d*, ·), but iterExp(*n*, ·) grows faster than anything achievable at depth *n* − 1.

## The Multivariate Challenge

But what happens when you have multiple variables? Consider the function that takes *k* positive numbers, adds them up, and applies the exponential tower:

**T**(*x*₁, *x*₂, …, *x*_*k*) = iterExp(*n*, *x*₁ + *x*₂ + ⋯ + *x*_*k*)

You might imagine that having multiple variables gives you a richer palette—more ways to combine things, more room for clever shortcuts. Perhaps you could use multiplication of different variables to simulate a deeper tower. Perhaps some algebraic identity lets you trade variables for depth.

The central theorem says: **No. The minimum depth remains exactly *n*, no matter how many variables you have.**

This is a striking rigidity result. The depth barrier is not an artifact of having a single variable. It is an intrinsic property of the tower function, invariant under the addition of arbitrarily many coordinates.

## How the Proof Works

The proof is beautifully simple in outline, though the details require careful analytical estimates.

**Step 1: Restriction.** Given any multivariate expression *e* that computes iterExp(*n*, *x*₁ + ⋯ + *x*_*k*), restrict it to a single-variable slice. Fix all variables except the first to the value 1, and let the first variable range freely. The result is a single-variable expression that computes *t* ↦ iterExp(*n*, *t* + (*k* − 1)).

**Step 2: Depth preservation.** The restriction process cannot increase the depth. Every exponential node in the original expression either survives (contributing its depth to the restricted expression) or becomes a constant. So the restricted expression has depth at most that of the original.

**Step 3: Single-variable lower bound.** Now apply the known single-variable result. The restricted function iterExp(*n*, *t* + *c*) for any constant *c* ≥ 0 requires depth at least *n*. This follows because shifting the argument does not reduce the growth rate—adding a positive constant only makes the function grow faster.

Combining these steps: the original multivariate expression must have depth at least *n*, since its restriction does, and restriction cannot increase depth. Meanwhile, the canonical construction—just nesting *n* exponentials around the sum—achieves depth exactly *n*. So the minimum depth is precisely *n*.

## Every Variable Matters

A second theorem reveals another layer of structure. Not only must the expression be deep, but it must also mention every variable.

The argument is elegant: if an expression omits variable *x*_*j*, then its value does not change when you vary *x*_*j*. But the function iterExp(*n*, *x*₁ + ⋯ + *x*_*k*) clearly does change when any single variable is perturbed—the sum changes, and the iterated exponential amplifies even tiny changes into enormous differences. Therefore, every variable must appear.

This has a quantitative consequence: the expression must have at least *k* variable leaves (one for each coordinate) plus *n* exponential nodes (for the tower depth). Counting carefully, the total syntactic size must be at least *n* + *k*. This is the first lower bound in the theory that simultaneously tracks tower height and variable arity.

## Why Should Anyone Care?

**For machine learning and symbolic regression.** When algorithms search for mathematical formulas to fit data, they explore a space of symbolic expressions. This theorem says that if the true underlying function involves deeply nested exponentials, no shallow formula will capture it—regardless of how many input features are available. This is a formal obstruction result for model class selection, moving beyond empirical intuition to mathematical proof.

**For circuit complexity.** The result is a distant cousin of lower bounds in computational complexity theory. Arithmetic circuits compute functions by composing operations; the depth of the circuit reflects the inherent parallelism of the computation. Tower functions are "hard" not because they require many operations, but because they require deeply nested ones.

**For approximation theory.** In multivariate approximation, a central question is how the complexity of a function depends on the number of variables. For polynomial approximation, there are well-known "curse of dimensionality" results. This theorem reveals a different phenomenon: for compositional complexity, the number of variables is irrelevant. The tower height is the binding constraint, and it is dimension-invariant.

**For physics and statistical mechanics.** In statistical physics, partition functions often involve exponentiating sums over many variables. The result says that such exponential towers of collective observables carry irreducible compositional depth—you cannot simplify them by rewriting in terms of fewer layers of exponentiation.

## A Geometric Invariant

Perhaps the deepest conceptual takeaway is that tower depth is a *geometric invariant* of the function, not a syntactic accident.

In geometry, invariants are properties that do not change under transformations. The Euler characteristic of a surface does not change when you stretch or bend it. The genus of a curve is preserved under smooth deformations.

Tower depth plays an analogous role for symbolic expressions. You can add variables, combine coordinates, rearrange the expression tree—but the depth remains. It is a measure of how fundamentally nested the function's growth pattern is.

This opens a tantalizing direction: could there be a complete theory of "expression complexity invariants," analogous to topological invariants, that classifies functions by their intrinsic symbolic complexity? The multivariate tower theorem is a first step toward such a theory.

## What Comes Next

Several questions remain open. The strongest version of the size lower bound—pinning down the exact minimum size, not just *n* + *k*—is still conjectural. The interaction between tower depth and other expression features (like the degree of polynomial subexpressions) is largely unexplored.

Most tantalizing is the question of approximation. Even if exact representation requires depth *n*, how well can a shallower expression approximate the tower function on a bounded domain? Preliminary computational experiments suggest that the approximation quality degrades dramatically with each missing depth level, but a formal theory of this phenomenon does not yet exist.

The tower that cannot be shortened is a small but rigid piece of mathematical truth. It tells us something fundamental about the structure of the functions we use to model the world: some complexities are irreducible, and no amount of clever variable manipulation can eliminate them. In a world increasingly reliant on mathematical models—from neural networks to symbolic regression to physical simulations—understanding the inherent limits of expression is not just an intellectual exercise. It is a practical necessity.
