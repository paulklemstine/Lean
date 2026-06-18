# When Prime Numbers Meet the Shape of Data

## The Unexpected Bridge Between Ancient Arithmetic and Modern Data Science

There is a formula that Leonhard Euler discovered in 1737 that changed mathematics forever. It says that adding up the reciprocals of all whole numbers—1 + 1/2 + 1/3 + 1/4 + ...—can be rewritten as a product over prime numbers alone. This "Euler product" revealed that the primes, those indivisible atoms of arithmetic, secretly control vast swathes of mathematics. Every generation since has found new domains where Euler products appear: in quantum physics, in cryptography, in the statistical mechanics of crystal lattices.

Now, for the first time, an Euler product has been found in the mathematics of *shape*.

---

## Barcodes of Data

Over the past two decades, mathematicians have developed a powerful set of tools called *topological data analysis*, or TDA. The central idea is deceptively simple: take a cloud of data points—the locations of galaxies, the gene expression profiles of cancer cells, the pixel intensities of an image—and study how the *shape* of that data changes as you zoom in and out.

Imagine you are looking at a set of points scattered on a table. From far away, they all blur into one blob. But at a medium distance, you might see several clusters, or perhaps a ring of points enclosing an empty hole. As you zoom closer, more fine-grained structure appears. TDA tracks these features—clusters, loops, voids—across every possible zoom level, recording when each feature is "born" and when it "dies."

The result is a *barcode*: a collection of horizontal line segments, each representing one topological feature and its lifespan. Long bars represent robust features of the data; short bars are noise. This barcode is, in a precise mathematical sense, a complete summary of the multi-scale topology of the data.

Barcodes have become essential tools across the sciences. Neuroscientists use them to map the topology of neural networks. Materials scientists track the evolution of pores in metal alloys. Drug designers use barcodes to compare the shapes of protein binding sites.

But barcodes are complicated objects—lists of intervals that resist easy comparison. What if there were a single number, a fingerprint, that captured the essential structure of a barcode?

---

## Enter the Primes

Here is where the story takes its most surprising turn.

Consider not arbitrary data, but a specific kind of mathematical object: a *filtered finite abelian group*. These are the algebraic structures that arise naturally when you study the symmetries of finite systems—crystal lattices, error-correcting codes, the arithmetic of clock mathematics. A filtration is a sequence of nested subgroups, like a series of Russian dolls, each one containing the next.

The classical Chinese Remainder Theorem, known for over two millennia, tells us that a finite abelian group decomposes uniquely into prime-power components. The group of integers modulo 60, for instance, splits cleanly into its 2-part (modulo 4), its 3-part (modulo 3), and its 5-part (modulo 5). These components don't interact: they are arithmetically independent.

The new discovery extends this primewise decomposition to *filtrations* and their *barcodes*. At each prime p, one can define a *local barcode length*—a measure of how much the p-primary component contributes to the persistence data. Then the entire barcode can be encoded into a single function of a parameter s:

> Z(D, s) = ∏ (1 + ℓ_p / p^s)

where the product runs over all primes p in the support and ℓ_p is the local barcode length at p. This is a *persistence zeta function*: a finite Euler product built from topological data.

---

## The Multiplicativity Theorem

The headline result is as clean as any in classical number theory:

**Theorem.** *If two filtered finite abelian groups have coprime torsion—that is, no prime divides the order of both groups—then the persistence zeta function of their product equals the product of their individual zeta functions.*

In symbols: Z(G₁ × G₂, s) = Z(G₁, s) · Z(G₂, s).

This is not a numerical coincidence. The proof builds on the Chinese Remainder Theorem decomposition: when the groups have no shared prime factors, their p-primary components are completely independent. Each prime contributes to exactly one factor in the product, and the Euler product splits cleanly over the disjoint union of prime supports.

The theorem identifies persistence zeta as a genuinely *multiplicative* invariant—the first topological invariant known to behave like a classical arithmetic function.

---

## When Multiplicativity Fails: The Correction Factor

But the real depth of the theory emerges when primes *are* shared.

When two groups both have 2-torsion and 3-torsion, for instance, the local barcode lengths at shared primes interact. The product's barcode at prime 2 depends on both groups' contributions, and the naive product of zeta functions overcounts.

The theory provides an exact correction:

> Z(product, s) = Z(G₁, s) · Z(G₂, s) · C(G₁, G₂, s)

where C is an explicit correction factor—a finite product over the shared primes that measures the deviation from multiplicativity. This correction factor has a precise algebraic formula, computable from the local barcode data alone.

Remarkably, the correction factor tends to 1 as the parameter s grows. This means that at large scales (high values of s), even interacting systems become approximately multiplicative. The interaction is a short-range effect, concentrated at the smallest shared primes.

This behavior is strikingly reminiscent of *ramification* in algebraic number theory, where certain primes cause problems for global factorization theorems. The shared primes in persistence zeta play exactly the role of "bad primes" in classical arithmetic. The correction factor is the analogue of a local ramification correction.

---

## An Obstruction Theorem

The theory also proves a sharp obstruction result: *multiplicativity can only fail at shared primes*. If the zeta function of a product differs from the product of zeta functions, there must exist at least one prime dividing the order of both groups where the local barcode data fails to decompose additively.

This is the persistence-theoretic analogue of the classical principle that "bad behavior is localized at bad primes." It transforms a vague intuition into a precise theorem with computational teeth: to check whether multiplicativity holds, you need only examine the shared primes.

---

## What Makes This Matter

Why should anyone outside pure mathematics care that a topological invariant has an Euler product?

First, because it opens a computational shortcut. Computing barcodes is expensive—the algorithms scale poorly with the size of the data. But if your data has a natural prime decomposition (as any finite algebraic structure does), the persistence zeta function can be computed *primewise*, independently at each prime, and the results multiplied together. This is exactly the efficiency gain that Euler products provide in number theory: replace a global sum with local computations.

Second, because it creates a bridge between two fields that have never spoken to each other. Number theory—the study of primes and their distribution—is one of the oldest and deepest branches of mathematics. Topological data analysis is one of the newest and most applied. The persistence zeta function sits at their intersection, suggesting that techniques from one field might solve problems in the other.

Could the distribution of barcode lengths satisfy an analogue of the prime number theorem? Could Tauberian theorems from analytic number theory provide asymptotic estimates for barcode growth? Could persistence invariants shed light on the distribution of primes themselves?

These are not idle questions. The correction factor formula, with its dependence on shared primes and its asymptotic decay, already hints at a "thermodynamics of barcodes" where the parameter s plays the role of inverse temperature. At high temperature (small s), interactions between prime components are strong and the system is far from multiplicative. As the temperature drops (s increases), the system factorizes and the components decouple.

---

## The Road Ahead

The persistence zeta function is the first entry in what promises to be a much larger dictionary between arithmetic and topology. Just as classical zeta functions spawned L-functions, Dirichlet series, and an entire ecosystem of analytic invariants, persistence zeta may be the seed of a new family of *arithmetic persistence invariants*.

The immediate open questions are tantalizing:
- Does the correction factor have a cohomological interpretation?
- Can persistence zeta be extended from finite abelian groups to more general persistence modules?
- Is there a persistence-theoretic analogue of the Riemann Hypothesis?

What is already clear is that the primes, those ancient objects that have fascinated mathematicians since Euclid, have found a new home—in the topology of data. And the conversation between these two worlds has only just begun.
