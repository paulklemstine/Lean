# The Hidden Geometry of Repulsion: How Mathematicians Learned to Compute the Shape of Diversity

## A Surprising Connection Between Matrices and Randomness

Imagine you're designing an algorithm to select a diverse set of news articles for a reader's homepage. You want variety — not five articles about the same political scandal, but a spread across sports, science, culture, and politics. Mathematicians have a beautiful tool for this: **determinantal point processes**, or DPPs, which are probability distributions that naturally favor diverse selections. They've been used in everything from machine learning recommendation systems to wireless network design.

But here's the puzzle that has nagged researchers for years: how do you *know* that a DPP kernel actually produces the diversity it promises? You can compute its outputs, sure, but is there a quick diagnostic — a kind of mathematical X-ray — that reveals whether the underlying geometry is healthy?

The answer, it turns out, has been hiding in an unexpected place: the same mathematics that describes the shape of spacetime.

## The Lorentzian Connection

In 1905, Hermann Minkowski realized that Einstein's special relativity could be understood through geometry. Space and time aren't separate — they form a four-dimensional fabric called spacetime, with a peculiar shape. In ordinary geometry, distances are always positive: the Pythagorean theorem says the distance from here to there is √(x² + y² + z²). But in Minkowski's spacetime, the formula gains a minus sign: √(x² + y² + z² − t²). That minus sign — one dimension behaving differently from all the others — is the hallmark of what mathematicians call *Lorentzian geometry*.

A century later, in 2020, Petter Brändén and June Huh published a landmark paper identifying a class of polynomials with an analogous one-minus-sign structure. They called them *Lorentzian polynomials*. These polynomials arise naturally in combinatorics, algebra, and — crucially — in the theory of DPPs. The generating polynomial of a DPP, it was shown, is always Lorentzian.

This was a profound theoretical result. But it had a practical gap: the proof that DPP polynomials are Lorentzian was existential, not constructive. It told you the structure existed, but didn't hand you a computationally efficient way to see it, verify it, or measure it.

## The Resolvent Hessian: An Algorithmic X-Ray

The breakthrough reported here closes that gap. It shows that the Lorentzian structure of a DPP is not just an abstract mathematical truth — it's a concrete, computable geometric object that can be extracted from the kernel matrix in the same time it takes to invert it.

The key object is the **resolvent Hessian**. Given a DPP kernel *K* — a symmetric, positive semidefinite matrix — form the matrix *A = I + K*, where *I* is the identity. Compute the inverse *L = A⁻¹* and the determinant det(*A*). Then assemble the Hessian matrix *H* with entries:

> *H*ᵢⱼ = det(*A*) × (*L*ᵢᵢ × *L*ⱼⱼ − *L*ᵢⱼ²) for *i* ≠ *j*, and *H*ᵢᵢ = 0.

This matrix *H* is the second derivative of the DPP's generating polynomial evaluated at a canonical point. Its diagonal entries vanish because the generating polynomial is *multiaffine* — each variable appears at most linearly, a reflection of the binary nature of DPP selections (each item is either chosen or not).

The stunning result: **this Hessian matrix always has at most one positive eigenvalue**. All other eigenvalues are zero or negative. That one-positive-eigenvalue signature is precisely the Lorentzian structure, made computable.

## The Proof: A Theorem in Four Steps

The mathematical argument is elegant in its simplicity.

**Step 1: Quadratic form decomposition.** The quadratic form associated to *H* — the expression *v*ᵀ*Hv* that measures "curvature" in a direction *v* — decomposes into two terms:

> *v*ᵀ*Hv* = det(*A*) × [(∑ *L*ᵢᵢ*v*ᵢ)² − ∑ᵢⱼ *L*ᵢⱼ² *v*ᵢ*v*ⱼ]

The first term is a perfect square — always nonneg. The second is a Hadamard-square quadratic form.

**Step 2: The Schur product theorem.** The matrix whose (*i,j*)-entry is *L*ᵢⱼ² is itself positive semidefinite — a classical result known as the Schur product theorem (the entrywise square of a PSD matrix is PSD). So the second term is always nonneg too.

**Step 3: Conditional negativity.** On the hyperplane where ∑ *L*ᵢᵢ*v*ᵢ = 0, the first term vanishes. The quadratic form becomes the negative of a nonneg quantity times the positive determinant. So *v*ᵀ*Hv* ≤ 0 on this hyperplane.

**Step 4: The one-positive-direction conclusion.** Since there exists an (*n* − 1)-dimensional subspace on which the quadratic form is nonpositive, there can be at most one direction in which it's positive. This is the Lorentzian signature: (1, *n* − 1).

## Why This Matters: From Abstraction to Algorithm

The passage from "there exists a Lorentzian structure" to "here is a computable matrix certificate" transforms the theoretical landscape in several ways.

**For machine learning:** DPP kernels are widely used in diversity-promoting sampling. When you train a kernel for document summarization or image selection, you want to know it's well-behaved. The Lorentzian certificate provides a checkable diagnostic: compute the Hessian, check its spectrum. If it has more than one positive eigenvalue, something is wrong with your kernel.

**For numerical analysis:** The certificate computation requires only a matrix inversion and a determinant — both standard operations that run in *O*(*n*³) time. This is the same asymptotic cost as the preprocessing already needed for DPP sampling. In other words, the Lorentzian certificate comes for free.

**For optimization:** The conditional negative semidefiniteness property is the same structure that underlies semidefinite programming and interior-point methods. The certificate makes Lorentzianity verifiable by the same tools that power modern convex optimization solvers.

**For statistical physics:** DPP generating polynomials are partition functions. The Hessian measures pair correlations — how the inclusion of one item affects the probability of another. The Lorentzian property constrains these correlations in a way that links to stability of fermionic systems and negative dependence phenomena.

## A Deeper Mystery

Perhaps the most intriguing finding is a conjecture that emerged from computational experiments. For every nonzero PSD contraction kernel tested — thousands of random matrices across dimensions from 3 to 50 — the Hessian has *exactly* one positive eigenvalue, never zero. This is stronger than the theorem, which only guarantees "at most one."

If true, this would mean the Lorentzian signature is not just an upper bound but a rigid law: every nontrivial DPP has precisely the geometric signature of a one-sheeted hyperboloid, the Lorentzian analog of a sphere. The diversity encoded in the kernel would always manifest as exactly one "direction of expansion" in the correlation geometry, surrounded by *n* − 1 directions of contraction.

This rigidity — if proved — would have implications beyond DPPs. It would suggest that the Lorentzian structure in combinatorial generating functions is not merely a sufficient condition for nice behavior, but a necessary consequence of the underlying linear algebra.

## The Bigger Picture

This work sits at a remarkable crossroads of mathematical ideas.

From **algebraic combinatorics** comes the theory of Lorentzian polynomials, rooted in Hodge theory and the geometry of convex bodies. From **probability theory** comes the DPP framework, with its elegant determinantal structure. From **numerical linear algebra** comes the resolvent — the inverse of (*I* + *K*) — a fundamental object in spectral theory and operator algebra. And from **Lorentzian geometry** comes the signature concept: the idea that a quadratic form's sign pattern reveals the shape of the underlying space.

What's new is the realization that these threads don't just coexist — they are the same thread, viewed from different angles. The resolvent entries *are* the Lorentzian certificate entries. The determinant *is* the partition function value. The Hadamard square *is* the Schur product applied to the resolvent. Everything reduces to one matrix inverse, and that inverse contains the full geometric story.

## Opening a New Chapter

The implications extend to problems not yet formulated. If Lorentzian certificates can be computed for DPPs, can they be computed for strongly Rayleigh measures, the broader class of negatively dependent probability distributions? Can the certificate be used as a barrier function in convex optimization, enforcing Lorentzianity as a constraint? Can machine learning systems be trained with Lorentzian regularization, ensuring that learned kernels always produce certifiably diverse outputs?

These questions define a nascent field that might be called *algorithmic Lorentzian geometry*: the study of Lorentzian structure not as an abstract property to be proved, but as a computational object to be constructed, verified, and optimized.

The mathematics of repulsion has gained a new tool. And like all the best tools, it reveals not just what we can compute, but what we didn't know we should be looking for.
