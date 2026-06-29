# When Polynomials Remember Their Shape: A New Theory of Mathematical Surgery

## The Polynomial That Wouldn't Forget

Imagine you have a crystal — not a physical one, but a mathematical object defined by a polynomial equation. This crystal has a shape, encoded in which terms appear in the polynomial. Now suppose you slice the crystal along a plane, or pinch it at a point. Does the remaining piece still "remember" that it came from a crystal?

This question, translated into the language of modern algebra, has just received a surprising answer. A new body of mathematical work establishes that a deep class of polynomials — called *Lorentzian polynomials* — possesses an extraordinary structural property: you can perform systematic surgery on their combinatorial skeleton, and the essential character of the polynomial survives. The skeleton remembers it was Lorentzian, no matter how many cuts you make.

## The Polynomial Zoo

To understand why this matters, you need to know what a polynomial's "support" is. Take the polynomial 3x²y + 5xy² + 2y³. Its *support* is the set of exponent patterns that actually appear: (2,1), (1,2), and (0,3). The support is the skeleton — it tells you which monomials are present, while forgetting their coefficients.

For over a century, mathematicians have known that certain polynomial families have special supports. The elementary symmetric polynomials, for instance, which appear everywhere from physics to computer science, have supports that look like the bases of a *matroid* — a combinatorial structure that abstracts the notion of independence in linear algebra.

In 2020, Petter Brändén and June Huh introduced a remarkable generalization. They defined *Lorentzian polynomials*: polynomials whose coefficients are all nonneg, and whose second-derivative matrices have a very specific shape. Specifically, after taking enough partial derivatives to reduce the polynomial to degree 2, the resulting quadratic form must have at most one positive eigenvalue — a condition inspired by the geometry of Einstein's spacetime, where time behaves differently from the three spatial dimensions.

Brändén and Huh showed that Lorentzian polynomials unify an astonishing range of mathematical phenomena: log-concavity of matroid invariants, the theory of stable polynomials, and deep results in algebraic geometry related to Hodge theory.

## The Surgery Question

Here's where the new work enters. In matroid theory, one of the most powerful ideas is the concept of a *minor*. You can perform two operations on a matroid:

- **Deletion**: Remove an element and everything that depends on it.
- **Contraction**: Collapse an element and adjust the remaining structure.

These operations are analogous to surgery on a graph: cutting an edge (deletion) or shrinking it to a point (contraction). The Robertson-Seymour theorem, one of the deepest results in combinatorics, shows that graph properties closed under these operations can be characterized by finitely many "forbidden minors."

The natural question: do Lorentzian polynomial supports have this same closure property? If you delete a variable from a Lorentzian polynomial (set it to zero) or contract it (take a partial derivative), is the resulting support still realizable by some Lorentzian polynomial?

## The Breakthrough

The answer, proved with machine-verified certainty, is *yes* — for both deletion and contraction, Lorentzian support realizability is preserved.

For deletion, the argument is elegant. Setting a variable to zero in a Lorentzian polynomial simply filters the monomials, keeping only those that don't involve that variable. The resulting polynomial is still homogeneous, still has nonneg coefficients, and — here's the key insight — its Hessian matrix is the original Hessian with one row and column zeroed out. A beautiful linear algebra argument shows that zeroing out a row and column of a matrix cannot increase the number of positive eigenvalues. So the Lorentzian signature is preserved.

For contraction, the argument is subtler. The partial derivative of a Lorentzian polynomial is again Lorentzian (this is essentially built into the definition — Lorentzianity is designed to be stable under differentiation). Taking iterated derivatives, then restricting, produces a polynomial whose support is exactly the combinatorial contraction of the original support.

The flagship result combines these: every minor of a Lorentzian support — obtained by any sequence of deletions and contractions — remains Lorentzian-realizable. The degree may decrease (each contraction drops it by one), but the essential Lorentzian character persists.

## Why One Positive Eigenvalue?

The condition "at most one positive eigenvalue" might seem arbitrary, but it has deep geometric meaning. Think of a quadratic form as defining the curvature of a surface. A form with all negative eigenvalues describes a surface that curves downward in every direction — a hilltop. Adding one positive eigenvalue creates a saddle: curving up in one direction but down in all others.

This saddle geometry is exactly what appears in Einstein's theory of relativity, where the metric of spacetime has signature (+, −, −, −) — one "timelike" direction and three "spacelike" ones. The Lorentzian polynomial condition says: the curvature landscape of every degree-2 derivative has this same spacetime-like geometry.

What the minor closure theorem reveals is that this curvature property is *structurally stable* under combinatorial surgery. You can't escape the saddle by cutting.

## A New Species of Combinatorial Object

The implications reach beyond polynomial algebra. Since Lorentzian supports are now known to form a minor-closed class, they sit alongside matroids, delta-matroids, and jump systems as a *combinatorial species* — a class of discrete objects closed under a natural notion of substructure.

This means the tools of structural combinatorics can be brought to bear. Just as the Robertson-Seymour theorem tells us that any minor-closed class of graphs is characterized by finitely many forbidden minors, the new theory raises the question: what are the forbidden minors for Lorentzian support realizability?

No one knows yet. But the question is now well-posed, and the theory provides the foundation for a systematic search.

## Connections That Span Mathematics

The theory builds bridges in multiple directions:

**To probability theory**: Lorentzian polynomials with positive coefficients define *negatively dependent* probability distributions — distributions where knowing one event occurred makes others less likely. The minor closure theorem means that conditioning (contraction) and marginalization (deletion) preserve negative dependence. This has immediate applications to random sampling algorithms.

**To optimization**: The reversed Cauchy-Schwarz inequality for Lorentzian forms — proved as part of this work — provides new convexity certificates. If a polynomial is Lorentzian, its support gives structural information that optimization algorithms can exploit.

**To algebraic geometry**: The exchange property of Lorentzian supports connects to the Hodge-Riemann relations in algebraic geometry. The minor closure theorem suggests that these deep geometric inequalities have a purely combinatorial shadow that persists under structural operations.

**To network theory**: The spanning-tree polynomial of a graph is Lorentzian. Graph deletion and contraction correspond to support deletion and contraction. The theory provides a new lens on network reliability and electrical network analysis.

## The Computational Frontier

The theory isn't just abstract — it comes with algorithms. Given a support set, one can:
1. Test the exchange property in polynomial time.
2. Generate the full minor lattice by systematic deletion and contraction.
3. Attempt Lorentzian realization by searching for positive coefficients satisfying the Hessian conditions.

Computational experiments on elementary symmetric polynomials up to 7 variables confirm the conjecture: every minor satisfies exchange, and all tested minors admit Lorentzian realizations.

## What Remains

The strongest version of the conjecture — that every minor of a *positively* Lorentzian support is itself positively realizable — remains open. Positive realizability is the natural inductive invariant, because strict positivity of coefficients prevents accidental cancellation under differentiation. But proving it requires controlling the exact support of iterated derivatives, a delicate analytic problem.

There's also the tantalizing question of forbidden minors. If Lorentzian support realizability is minor-closed, what are the minimal obstructions? Finding even one forbidden minor would be a significant achievement, connecting Hodge-theoretic positivity to finite combinatorial characterization.

## A Property Becomes a Theory

Mathematics occasionally experiences phase transitions: a property, studied in isolation, is recognized as the surface manifestation of a structural theory. The discovery that matroids are minor-closed transformed them from a useful abstraction into the foundation of structural combinatorics. The recognition that stable homotopy groups form a ring launched stable homotopy theory.

Lorentzian polynomial supports may be undergoing a similar transformation. They were introduced as an analytic condition — a tool for proving log-concavity. The minor closure theorem reveals them as a *combinatorial species*, subject to the same structural decomposition that made matroid theory so powerful.

The polynomial remembers its shape. And now we know: no matter how you cut it, that memory endures.
