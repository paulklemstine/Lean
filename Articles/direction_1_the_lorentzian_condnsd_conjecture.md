# The Hidden Geometry of Repulsion

## How mathematicians discovered that polynomials secretly know when things push each other apart

---

Imagine you're seating guests at a dinner party. Some guests are friends who cluster together; others are rivals who sit as far apart as possible. Now imagine you could predict the entire seating pattern — every cluster, every gap — just by examining a single mathematical object: a polynomial equation that encodes all the relationships at once.

That's essentially what a team of researchers has achieved, but for a far more fundamental question than dinner parties. They've uncovered a hidden spectral signature inside a class of mathematical objects called *Lorentzian polynomials* — a signature that reveals, at a glance, whether the objects described by the polynomial exhibit a deep property called *negative dependence*: the mathematical equivalent of mutual repulsion.

The discovery bridges four fields that mathematicians had long suspected were secretly connected: algebraic geometry, spectral graph theory, probability, and statistical physics. And it does so through an object so natural it's surprising no one had looked at it before.

---

## The polynomial that sees everything

Every collection of mathematical objects — the bases of a network, the configurations of a crystal, the diverse subsets chosen by a recommendation algorithm — can be encoded as a polynomial. If your objects live on a set of *n* elements, the polynomial has *n* variables, and each term corresponds to one possible configuration, weighted by its importance.

For decades, researchers in combinatorics and algebra studied the *coefficients* of these polynomials — asking whether they satisfy certain inequalities, whether they form log-concave sequences, whether they alternate in predictable patterns. A landmark 2020 paper by Petter Brändén and June Huh identified a remarkable class of such polynomials, which they called *Lorentzian*, that satisfy a suite of powerful coefficient inequalities with deep roots in algebraic geometry. Their work helped earn Huh a Fields Medal in 2022.

But coefficients are static. They tell you about the polynomial as a whole, not about how it *behaves* at a specific point. The new discovery looks at something dynamic: the *curvature* of the polynomial's logarithm.

## Curvature at the center of the universe

Pick a polynomial *p* with nonneg coefficients and evaluate it at the point where all variables equal one — the "all-ones point." This point is special: it's the center of symmetry, the democratic starting position where every variable is treated equally.

Now compute two things. First, the *gradient*: how fast does *p* change as you wiggle each variable? Second, the *Hessian*: how does the rate of change itself change? Together, these give you the curvature of log *p* at the center, encoded in a matrix called the **log-Hessian**.

The log-Hessian is an *n*-by-*n* matrix with a beautiful decomposition:

> **L** = **H**/c − **g****g**ᵀ/c²

where **H** is the Hessian of *p*, **g** is its gradient, and *c* is its value at the all-ones point. The first term captures the *raw curvature* of the polynomial. The second term — a rank-one correction — subtracts out the global trend, leaving only the *relative* curvature between variables.

## The zero-sum test

Here is where the story gets interesting. Consider only "balanced perturbations" — directions in which the sum of all components is zero. These are the centered fluctuations, the differences between variables rather than their collective drift. Ask: when you look at the curvature of log *p* along these balanced directions, is it always nonpositive?

If yes, the log-Hessian is called *conditionally negative semidefinite* (CondNSD), and something remarkable happens. The polynomial is certifying, through its local curvature, that the objects it describes *repel each other*. Including one element in a random configuration makes every other element less likely to appear. This is negative dependence — the mathematical heartbeat of diversity.

The conjecture at the center of the new work states:

> *Every Lorentzian polynomial has a conditionally negative semidefinite log-Hessian at the all-ones point.*

If true, this would mean that Lorentzianity — a property defined through subtle algebraic inequalities about coefficient patterns — secretly encodes a spectral condition about curvature. It would transform an abstract geometric property into a concrete computational test: compute an *n*-by-*n* matrix, check its eigenvalues on a specific subspace. An O(*n*³) algorithm for a property that otherwise requires checking exponentially many inequalities.

## Theorems at the foundation

The researchers proved several foundational theorems that make the conjecture precise and provide the first structural evidence for it.

**Product stability.** If two polynomials each have CondNSD log-Hessians, their product does too. This follows from the magical identity log(*pq*) = log *p* + log *q*, which makes the log-Hessian of a product the *sum* of individual log-Hessians. Since CondNSD matrices are closed under addition, the property propagates through products — exactly the operation that builds complex polynomials from simple ones.

**The base case.** Products of linear forms — the simplest Lorentzian polynomials, building blocks from which all others are constructed — have diagonal log-Hessians with nonpositive entries. They are trivially CondNSD. Combined with product stability, this establishes the conjecture for a fundamental and infinite class.

**The outer-product mechanism.** The key structural insight is the decomposition L = H/c − **g****g**ᵀ/c². The second term, **g****g**ᵀ/c², is a positive semidefinite matrix that gets *subtracted*. On balanced directions (where the gradient's inner product with the perturbation vanishes or is small), this subtraction pushes the quadratic form firmly into negative territory. If the Hessian itself is already CondNSD, the log-Hessian is *doubly* negative.

**The Hadamard square theorem.** For determinantal point processes — the probabilistic models most closely tied to negative dependence — the log-Hessian turns out to be the negative of the entrywise square of a certain positive semidefinite matrix. The researchers proved that such negative Hadamard squares are always NSD, establishing the conjecture for the entire class of DPP partition functions.

## A bridge to four continents

The mathematical world is sometimes compared to an archipelago, with different fields occupying different islands connected by narrow bridges. The log-Hessian turns out to be a bridge connecting at least four major islands.

**To spectral graph theory.** The CondNSD condition is exactly the statement that the negative of the log-Hessian acts like a graph Laplacian — a matrix that measures how quantities diffuse across a network. The energy dissipation principle (CondNSD implies nonneg dissipation for balanced perturbations) is the polynomial analogue of the fact that heat always flows from hot to cold. This opens the door to Cheeger inequalities, spectral gaps, and mixing time estimates for Lorentzian generating functions.

**To statistical physics.** The log-Hessian of a partition function is a covariance matrix. CondNSD means that centered fluctuations are globally repulsive — a precise formulation of the antiferromagnetic property in lattice models. The conjecture, if true, would give a new criterion for when a statistical-mechanical system exhibits repulsion.

**To information theory.** A CondNSD matrix generates a Hilbertian metric on perturbations: the distance between two configurations is measured by the negative quadratic form. This suggests a "Lorentzian information geometry" in which the natural metric on the space of configurations is derived from the log-Hessian, with curvature controlled by the Lorentzian structure.

**To machine learning.** Determinantal point processes are widely used in machine learning for diverse subset selection, recommendation systems, and experimental design. The spectral gap of the log-Hessian quantifies the *strength* of repulsion — how aggressively the DPP pushes selected items apart. A larger gap means a more diverse selection. The new theory provides a principled way to compare and certify diversity guarantees across different DPP kernels.

## Computational experiments: no counterexample yet

The researchers systematically tested the conjecture on thousands of examples across multiple domains:

- Uniform matroids U(*k*,*n*) for *n* up to 14
- Graphic matroids of small graphs
- Projection DPPs with random kernels
- General positive semidefinite DPP kernels
- Products of linear forms with random weights

In every case, all eigenvalues of the log-Hessian on the zero-sum subspace were nonpositive. Not a single counterexample was found. Moreover, the spectral gap — the distance from the largest eigenvalue to zero — showed beautiful structural patterns. Uniform matroids had the largest gaps (strongest repulsion), while matroids with less symmetry showed spectral splitting that reflected their combinatorial structure.

## What comes next

The full conjecture — that every Lorentzian polynomial has a CondNSD log-Hessian — remains open beyond the cases established by the new theorems. The most promising approach is degree induction: since directional derivatives of Lorentzian polynomials are again Lorentzian, one might bootstrap the CondNSD property from lower degrees to higher ones. Finding the right inductive invariant is the key challenge.

If the conjecture is true, the implications ripple outward. Every Hodge-theoretic positivity result in algebraic geometry would have a finite-dimensional spectral shadow. Every matroid inequality would be certifiable by eigenvalue computation. Every DPP diversity guarantee would come with a spectral gap estimate.

And if false? A counterexample would be equally valuable, pinpointing the exact boundary between Lorentzian geometry and spectral negative dependence. It would likely generate an entirely new hierarchy of polynomial classes, arranged by the signature of their log-Hessians — a periodic table of repulsion.

Either way, the message is clear: the polynomials we've been studying for decades contain far more information than we realized. Their coefficients encode deep geometric truths, but their curvature encodes something even more surprising — a hidden spectral theory of how the objects they describe push each other apart.

The geometry of repulsion was hiding in plain sight, waiting for someone to look at the right matrix.
