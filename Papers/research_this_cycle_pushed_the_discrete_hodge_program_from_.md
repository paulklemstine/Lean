# Spectral Positivity and the Resolution of the Identity for the Discrete Hodge Laplacian

## Abstract

We develop, over arbitrary finite-dimensional real inner-product spaces, the spectral and
operator-algebraic theory of the **Hodge Laplacian** of a two-step cochain complex
`U --e--> V --d--> W` satisfying the chain condition `d ∘ e = 0`. On the middle space `V`
the Laplacian is `Δ = d* ∘ d + e ∘ e*`. Our central observation is a single identity: the
Rayleigh quadratic form of `Δ` is an explicit sum of two squares,
`⟨Δ x, x⟩ = ‖d x‖² + ‖e* x‖²`. From this identity alone we derive, with no appeal to the
spectral theorem, the four pillars of the variational theory: positive semidefiniteness,
the identification of the vanishing locus of the quadratic form with the harmonic space
`ker Δ`, the symmetry of `Δ`, and the non-negativity of every eigenvalue. We then promote
the static orthogonal direct sum `V = range d* ⊕ range e ⊕ ker Δ` to an operator statement:
the three orthogonal projectors onto the coexact, exact, and harmonic subspaces form a
**resolution of the identity** `P_coexact + P_exact + P_harmonic = 1`, with the three
projectors pairwise annihilating and each extracting its own summand from a three-way
decomposition. Together these results exhibit the discrete Hodge decomposition as a complete
system of mutually orthogonal spectral idempotents, and present the Laplacian, the
positivity of its spectrum, and the topology-counting role of its kernel as consequences of
the geometry of the quadratic form. All results are fully formalized and machine-verified;
the present paper records the mathematics, with proof sketches in place of formal scripts.

**Keywords.** Hodge Laplacian, discrete Hodge decomposition, cochain complex, positive
semidefinite operator, orthogonal projection, resolution of the identity, harmonic space,
Betti number, spectral graph theory.

---

## 1. Introduction

### 1.1 Context

The Hodge decomposition is a cornerstone of geometry: on a compact oriented Riemannian
manifold every differential form decomposes uniquely and orthogonally into an exact part, a
coexact part, and a harmonic part, with the harmonic forms isomorphic to de Rham
cohomology. In the last decade the *discrete* incarnation of this theory — phrased over
cochain complexes of finite-dimensional inner-product spaces, equivalently over simplicial
or cellular complexes and graphs — has become foundational in applied mathematics: in
topological data analysis (persistent and harmonic homology), in spectral graph theory and
geometric deep learning (graph and simplicial Laplacians, spectral filters), in statistical
ranking (HodgeRank and the detection of inconsistency cycles), and in computational
electromagnetics and fluid dynamics (discrete exterior calculus).

This paper isolates and proves the spectral and operator-algebraic core of the discrete
theory in maximal generality — over an abstract two-step complex of finite-dimensional real
inner-product spaces — and derives every spectral fact from a single quadratic-form
identity. The development is *operator-theoretic and constructive*: the Laplacian is
represented by its Rayleigh form, the projectors are concrete star-projections, and the
spectral conclusions (positive semidefiniteness, spectrum in `[0,∞)`, kernel as harmonic
space) are read off the geometry of these representations.

### 1.2 Contributions

1. A sum-of-squares identity for the Rayleigh form of `Δ` (Theorem 3.1), from which all
   variational consequences follow.
2. Positive semidefiniteness (Theorem 3.2), the kernel-as-vanishing-locus description
   (Theorem 3.3), symmetry (Theorem 3.4), and eigenvalue non-negativity (Theorem 3.5),
   each a short corollary of Theorem 3.1.
3. The resolution of the identity by the three Hodge projectors (Theorem 4.4), together
   with their pairwise annihilation (Theorem 4.3) and the summand-extraction property
   (Theorem 4.2).

All results are formalized and verified; the formal development depends only on the standard
foundational axioms (propositional extensionality, the axiom of choice, and quotient
soundness).

---

## 2. Setup and definitions

Throughout, `U`, `V`, `W` are finite-dimensional real inner-product spaces. We write
`⟨·,·⟩` for the (real) inner product, `‖·‖` for the induced norm, and `f*` for the adjoint
of a linear map `f` (with respect to these inner products). In finite dimensions every
linear map has a unique adjoint, characterized by `⟨f y, x⟩ = ⟨y, f* x⟩`.

**Definition 2.1 (Two-step cochain complex).**
A *two-step cochain complex* is a pair of linear maps
```
        U --e--> V --d--> W
```
satisfying the **chain condition** `d ∘ e = 0`. We call `V` the *middle space*, elements of
`range e` the *exact* cochains, elements of `range d*` the *coexact* cochains, and (after
Definition 2.2) elements of `ker Δ` the *harmonic* cochains.

**Definition 2.2 (Hodge Laplacian).**
The **Hodge Laplacian** of the complex, acting on the middle space, is
```
        Δ := d* ∘ d + e ∘ e*  :  V → V .
```

**Definition 2.3 (Auxiliary invariants).**
The *harmonic space* is `ker Δ ⊆ V`. The *exact subspace* is `range e`; the *coexact
subspace* is `range d*`. The three associated orthogonal projectors are
```
        P_exact    := starProjection onto range e,
        P_coexact  := starProjection onto range d*,
        P_harmonic := starProjection onto ker Δ,
```
where `starProjection onto K` denotes the orthogonal projection of `V` onto the (closed,
hence in finite dimensions automatically closed) subspace `K`.

Two standard facts about adjoints and orthogonal projections are used repeatedly:

- **(Image–kernel duality.)** `ker f* = (range f)ᗮ`. *Proof sketch.* `f* x = 0` iff
  `⟨y, f* x⟩ = 0` for all `y`, iff `⟨f y, x⟩ = 0` for all `y`, iff `x ⊥ range f`.
- **(Star-projection trichotomy.)** For a subspace `K`, the orthogonal projector `P_K`
  satisfies `P_K v = v` for `v ∈ K` and `P_K v = 0` for `v ∈ Kᗮ`.

We also record the foundational kernel description proved in the underlying development.

**Lemma 2.4 (Harmonic = closed ∩ coclosed).**
`ker Δ = ker d ∩ ker e*`. *Proof sketch.* This is the equality case of Theorem 3.1 below:
`⟨Δ x, x⟩ = ‖d x‖² + ‖e* x‖²` vanishes iff `d x = 0` and `e* x = 0`; and since `Δ` is
self-adjoint and `⟨Δ x, x⟩ = 0` forces `Δ x = 0` for such `x`, the kernel of `Δ` is exactly
the simultaneous kernel of `d` and `e*`. ∎

The *first Betti number* of the complex at `V` is `dim(ker d) − rank(e)`; the foundational
theory establishes `dim(ker Δ) = dim(ker d) − dim(range e)`, so the harmonic dimension is
the Betti number — the topological content recovered spectrally.

---

## 3. Spectral positivity

The entire variational theory rests on one identity.

### 3.1 The Rayleigh form is a sum of squares

**Theorem 3.1 (Quadratic-form identity).**
For every `x ∈ V`,
```
        ⟨Δ x, x⟩  =  ‖d x‖²  +  ‖e* x‖² .
```

*Proof sketch.* Expand `Δ = d* ∘ d + e ∘ e*` inside the inner product and use bilinearity:
```
   ⟨Δ x, x⟩ = ⟨d*(d x), x⟩ + ⟨e(e* x), x⟩ .
```
Move the adjoints across the inner product. By the adjoint adjunction
`⟨d*(d x), x⟩ = ⟨d x, d x⟩` and `⟨e(e* x), x⟩ = ⟨e* x, e* x⟩`. Finally
`⟨y, y⟩ = ‖y‖²` for the real inner product. ∎

Every subsequent result in this section is a corollary obtained by elementary real
arithmetic on the right-hand side.

### 3.2 Positive semidefiniteness

**Theorem 3.2 (PSD).** For every `x ∈ V`, `0 ≤ ⟨Δ x, x⟩`.

*Proof sketch.* By Theorem 3.1 the value equals `‖d x‖² + ‖e* x‖²`, a sum of squares of
real norms, hence non-negative. ∎

### 3.3 The vanishing locus is the harmonic space

**Theorem 3.3 (Equality case).** For every `x ∈ V`,
```
        ⟨Δ x, x⟩ = 0   ⟺   x ∈ ker Δ .
```

*Proof sketch.* ( ⇒ ) By Theorem 3.1, `⟨Δ x, x⟩ = 0` reads `‖d x‖² + ‖e* x‖² = 0`. A sum
of two non-negative reals is zero only if each is zero, so `‖d x‖ = ‖e* x‖ = 0`, i.e.
`d x = 0` and `e* x = 0`; by Lemma 2.4 this means `x ∈ ker Δ`. ( ⇐ ) If `Δ x = 0` then
`⟨Δ x, x⟩ = ⟨0, x⟩ = 0`. ∎

Theorem 3.3 is the operator-level statement that the harmonic space — the topology-carrying
kernel — is *exactly* the zero set of the energy functional `x ↦ ⟨Δ x, x⟩`. Equivalently,
`Δ` is *strictly positive* on the orthogonal complement `(ker Δ)ᗮ = range d* ⊕ range e`: the
Rayleigh form is bounded below by a positive multiple of `‖x‖²` away from the harmonic
space, which is precisely the strict positivity needed to invert `Δ` there (see §6).

### 3.4 Symmetry

**Theorem 3.4 (Symmetry).** `Δ` is symmetric: `⟨Δ x, y⟩ = ⟨x, Δ y⟩` for all `x, y ∈ V`.

*Proof sketch.* `Δ = d* ∘ d + e ∘ e*` is self-adjoint because `(d* ∘ d)* = d* ∘ d** =
d* ∘ d` and `(e ∘ e*)* = e** ∘ e* = e ∘ e*`, and the sum of self-adjoint operators is
self-adjoint. A self-adjoint operator on a real inner-product space is symmetric. ∎

Symmetry is the precise hypothesis required by the finite-dimensional spectral theorem,
which then guarantees an orthonormal eigenbasis of `V` consisting of eigenvectors of `Δ`
with real eigenvalues.

### 3.5 Eigenvalue non-negativity

**Theorem 3.5 (Non-negative spectrum).** If `Δ x = μ x` for some scalar `μ ∈ ℝ` and some
`x ≠ 0`, then `0 ≤ μ`.

*Proof sketch.* Compute the Rayleigh form for the eigenvector:
`⟨Δ x, x⟩ = ⟨μ x, x⟩ = μ ‖x‖²`. By Theorem 3.2 the left side is `≥ 0`, and `‖x‖² > 0`
since `x ≠ 0`; dividing gives `μ ≥ 0`. ∎

Combining Theorems 3.4 and 3.5: the spectrum of `Δ` is real and contained in `[0, ∞)`, and
by Theorem 3.3 the `0`-eigenspace is exactly `ker Δ`, the harmonic space. This is the full
spectral envelope of the Hodge Laplacian, derived from the single identity of Theorem 3.1.

---

## 4. The resolution of the identity

We now upgrade the static orthogonal direct sum
```
        V = range d*  ⊕  range e  ⊕  ker Δ          (coexact ⊕ exact ⊕ harmonic)
```
to an operator statement about the three orthogonal projectors of Definition 2.3.

### 4.1 Pairwise orthogonality of the three subspaces

The three summands are mutually orthogonal. The underlying development provides the three
inclusions (each a one-line consequence of image–kernel duality and the chain condition):
```
   range e   ≤ (range d*)ᗮ        (exact ⊥ coexact),
   ker Δ     ≤ (range e)ᗮ         (harmonic ⊥ exact),
   ker Δ     ≤ (range d*)ᗮ        (harmonic ⊥ coexact).
```
Taking orthogonal complements and using `K ≤ Kᗮᗮ` yields the symmetric forms
`range d* ≤ (range e)ᗮ` and `range d* ≤ (ker Δ)ᗮ`, which we use below.

**Lemma 4.1 (Orthogonality, dual forms).**
```
   range d* ≤ (range e)ᗮ      and      range d* ≤ (ker Δ)ᗮ .
```
*Proof sketch.* From `range e ≤ (range d*)ᗮ`, apply the order-reversing map `K ↦ Kᗮ` to get
`(range d*)ᗮᗮ ≤ (range e)ᗮ`, then `range d* ≤ (range d*)ᗮᗮ`. Likewise for the harmonic
inclusion. ∎

### 4.2 Each projector extracts its own summand

**Theorem 4.2 (Summand extraction).**
Let `x = c + a + h` with `c ∈ range d*` (coexact), `a ∈ range e` (exact), and
`h ∈ ker Δ` (harmonic). Then
```
   P_coexact (c + a + h) = c,
   P_exact   (c + a + h) = a,
   P_harmonic(c + a + h) = h .
```

*Proof sketch.* Each projector is additive. We treat `P_coexact`; the others are identical
by symmetry. By the star-projection trichotomy, `P_coexact c = c` because `c ∈ range d*`.
By Lemma 4.1 (more precisely its source inclusions), `a ∈ range e ≤ (range d*)ᗮ` and
`h ∈ ker Δ ≤ (range d*)ᗮ`, so `P_coexact a = 0` and `P_coexact h = 0`. Adding,
`P_coexact(c + a + h) = c`. For `P_harmonic`, the only subtlety is identifying `P_harmonic a = 0`
for an exact `a = e u`; this is the projector annihilating the exact channel, a foundational
fact. ∎

### 4.3 Pairwise annihilation

**Theorem 4.3 (Idempotents annihilate pairwise).**
For all `x ∈ V`,
```
   P_harmonic (P_exact x)   = 0,
   P_harmonic (P_coexact x) = 0,
   P_exact    (P_coexact x) = 0 .
```

*Proof sketch.* In each case the inner projector lands in a subspace orthogonal to the
target of the outer projector, so the outer projector kills it. For the first identity,
`P_exact x ∈ range e ≤ (ker Δ)ᗮ`, hence `P_harmonic (P_exact x) = 0`. For the second,
`P_coexact x ∈ range d* ≤ (ker Δ)ᗮ` by Lemma 4.1. For the third,
`P_coexact x ∈ range d* ≤ (range e)ᗮ` by Lemma 4.1. ∎

The pairwise annihilation, together with idempotence of each `P_i` (a defining property of
orthogonal projections), shows the three projectors form a *complete system of mutually
orthogonal idempotents*.

### 4.4 The resolution of the identity

**Theorem 4.4 (Resolution of the identity).**
Assume the span condition `range d* ⊕ range e ⊕ ker Δ = V` (the three-way Hodge
decomposition, established in the foundational development). Then for every `x ∈ V`,
```
        P_coexact x  +  P_exact x  +  P_harmonic x  =  x .
```
Equivalently, `P_coexact + P_exact + P_harmonic = 1` as operators.

*Proof sketch.* By the span condition, write `x = c + a + h` with `c` coexact, `a` exact,
`h` harmonic (decomposition obtained from membership in the join of the three subspaces).
By Theorem 4.2 the three projectors return `c`, `a`, and `h` respectively, whose sum is
`c + a + h = x`. ∎

Theorem 4.4 is the operator form of the discrete Hodge decomposition: every cochain is the
unique orthogonal sum of a coexact, an exact, and a harmonic part, and these parts are
recovered by mutually orthogonal idempotents that resolve the identity.

---

## 5. Algorithms

The constructive content of the theory yields directly executable algorithms over Euclidean
`ℝⁿ`, where adjoints are matrix transposes.

**Algorithm A (Hodge decomposition of a signal).**
*Input:* matrices `d` (shape `dim W × dim V`) and `e` (shape `dim V × dim U`) with
`d e = 0`, and a signal `x ∈ ℝ^{dim V}`. *Output:* the orthogonal triple `(c, a, h)` with
`x = c + a + h`.
```
   1. form  Δ ← dᵀ d + e eᵀ                            # Hodge Laplacian
   2. H ← orthonormal basis of ker Δ                   # via SVD null space
   3. P_coexact ← dᵀ (dᵀ)⁺ ;  P_exact ← e e⁺ ;  P_harmonic ← H Hᵀ
   4. c ← P_coexact x ;  a ← P_exact x ;  h ← P_harmonic x
   5. return (c, a, h)
```
Cost: `O(m³)` for `m = dim V` (dominated by the SVD / pseudoinverses). Correctness is
Theorem 4.4; orthogonality of the outputs is Theorem 4.3.

**Algorithm B (Energy / harmonic certificate).**
*Input:* `d, e, x`. *Output:* the Rayleigh energy and a Boolean "is `x` harmonic?".
```
   1. energy ← ‖d x‖² + ‖eᵀ x‖²                        # equals ⟨Δ x, x⟩ by Theorem 3.1
   2. return (energy, energy ≈ 0)                       # harmonic ⟺ energy = 0  (Theorem 3.3)
```
This avoids forming `Δ` altogether and certifies harmonicity by a single non-negative
number, exploiting the sum-of-squares identity.

**Algorithm C (Betti number via the spectral kernel).**
*Input:* `d, e`. *Output:* the harmonic dimension (= first Betti number).
```
   1. Δ ← dᵀ d + e eᵀ
   2. λ ← eigenvalues of Δ (real, ≥ 0 by Theorems 3.4–3.5)
   3. return  #{ i : λ_i ≈ 0 }
```
Correctness rests on Theorem 3.3 (the `0`-eigenspace is exactly `ker Δ`) and the
foundational identity `dim ker Δ = dim ker d − rank e`.

---

## 6. Applications and discussion

**Topological feature detection.** By Theorem 3.3 and the Betti identity, the multiplicity
of the eigenvalue `0` of `Δ` counts the independent cycles of the underlying complex. On
graphs (no `2`-cells, `d = 0`) this is the loop count; the harmonic eigenvectors are the
circulation patterns around the loops. This is the spectral basis of harmonic cycle
detection in sensor coverage, network resilience, and topological data analysis.

**Spectral filtering and geometric deep learning.** Theorems 3.4 and 3.5 guarantee a real,
non-negative spectrum and an orthonormal eigenbasis, the prerequisites for defining a graph
/ simplicial Fourier transform and spectral convolution filters. The harmonic subspace is
the DC component of this transform; the resolution of the identity (Theorem 4.4) separates a
signal into low-frequency harmonic content and the gradient/curl channels that filters
attenuate.

**Statistical ranking (HodgeRank).** Pairwise comparison data is an edge-flow; Theorem 4.4
splits it into a *gradient* part (a globally consistent ranking), a *curl* (local
inconsistency around triangles), and a *harmonic* part (global inconsistency around large
cycles). The orthogonality (Theorem 4.3) makes the consistent ranking the unique least-
squares projection, and the size of the non-gradient parts quantifies inconsistency.

**Toward the Green's operator.** Theorem 3.3 shows `Δ` is injective on `(ker Δ)ᗮ`, and
self-adjointness gives `range Δ = (ker Δ)ᗮ`, so `Δ` is a bijection there. Its inverse,
extended by `0` on `ker Δ`, is the **Green's operator** (Moore–Penrose pseudoinverse `G`)
with `Δ G = G Δ = 1 − P_harmonic` and `G P_harmonic = 0`. The two ingredients — a
complemented kernel (Theorem 4.4) and strict positivity on the complement (Theorem 3.3) —
are exactly the present results; assembling `G` is then projector bookkeeping plus the
inversion of `Δ` on a fixed-dimension complement.

**Diffusion message passing.** The explicit-Euler step `S = 1 − α Δ` is the elementary unit
of Laplacian-based message passing. Self-adjointness and `range Δ = (ker Δ)ᗮ` make `ker Δ`
and `(ker Δ)ᗮ` simultaneously `S`-invariant; on the harmonic block `Δ = 0`, so `S` fixes it
pointwise (the harmonic component is conserved across all iterations), while Theorem 3.5
gives strictly positive eigenvalues on the complement, hence geometric contraction of the
non-harmonic part for admissible `0 < α < 2/λ_max`. The convergence of message passing onto
`P_harmonic` thus reduces, eigenvector by eigenvector, to a one-dimensional geometric-series
estimate.

**Limitations.** The theory is finite-dimensional and assumes exact arithmetic in the proofs;
numerical implementations must threshold near-zero eigenvalues to identify the harmonic
space. The complex is two-step; the multi-step case (a full chain complex) requires gluing
the present results level by level, which the resolution of the identity is designed to
support functorially.

---

## 7. Future work

The present spectral and operator-algebraic layer opens five concrete directions, each now
reduced to assembling established theorems rather than new analysis.

1. **The Green's operator.** Construct `G`, the Moore–Penrose pseudoinverse of `Δ`, with
   `Δ G = G Δ = 1 − P_harmonic` and `G P_harmonic = 0`. The complemented kernel (Theorem
   4.4) and strict positivity on the complement (Theorem 3.3) are the only ingredients.
2. **Isometry of the Hodge isomorphism.** Upgrade the linear isomorphism
   `(ker d / range e) ≅ ker Δ` to a *quotient isometry*: the quotient norm of a cohomology
   class equals the norm of its harmonic representative, `‖[x]‖ = ‖P_harmonic x‖`. The
   minimization (the harmonic representative is the minimal-norm class element) and the
   projector identification are in hand; only matching the quotient-norm infimum to the
   attained minimum remains.
3. **Diffusion contraction at the spectral-gap rate.** Prove that `(1 − αΔ)^k → P_harmonic`
   with `‖(1 − αΔ)^k x − P_harmonic x‖ ≤ ρ^k ‖x − P_harmonic x‖`, where
   `ρ = max|1 − αλ| < 1` over the nonzero eigenvalues. The invariant splitting and strict
   positivity on the complement are theorems; convergence is a per-eigenvector geometric
   series.
4. **Full spectral resolution.** Establish `Δ = Σ λ_i P_i` with `P_0 = P_harmonic` and the
   positive eigenprojections refining `P_coexact + P_exact`. Symmetry (Theorem 3.4) feeds
   the spectral theorem, eigenvalue non-negativity (Theorem 3.5) pins the spectrum to
   `[0,∞)`, and the kernel description (Theorem 3.3) identifies the `0`-eigenspace.
5. **Functoriality.** Show a morphism of two-step complexes induces a map on harmonic
   spaces intertwining the projectors and agreeing with the induced cohomology map; the
   summand-extraction characterization (Theorem 4.2) reduces naturality to the two ladder
   squares plus the resolution of the identity.

---

## 8. Conclusion

A single identity — the Rayleigh quadratic form of the Hodge Laplacian is a sum of two
squares, `⟨Δ x, x⟩ = ‖d x‖² + ‖e* x‖²` — generates the entire variational theory: positive
semidefiniteness, the identification of the harmonic space with the vanishing locus of the
energy, symmetry, and a non-negative spectrum. Layered on top, the three Hodge projectors
resolve the identity and pairwise annihilate, exhibiting the discrete Hodge decomposition as
a complete system of orthogonal spectral idempotents. The result is a compact,
self-contained, and fully machine-verified foundation on which the Green's operator, the
isometric Hodge isomorphism, spectral-gap convergence of message passing, and the full
spectral resolution can all be built.
