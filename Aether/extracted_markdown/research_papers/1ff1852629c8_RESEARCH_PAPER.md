# The Discrete Hodge Laplacian, its Harmonic Space, and Diffusion Message Passing: A Self-Contained Operator-Algebraic Foundation

## Abstract

We develop, from first principles, the operator-algebraic, analytic, and
dynamical theory of the **discrete Hodge Laplacian** associated with a two-step
cochain complex of finite-dimensional real inner-product spaces
`U --e--> V --d--> W`. Working on the middle space `V`, we study the operator
`Δ = d* ∘ d + e ∘ e*`, where `d*` and `e*` denote Hilbert-space adjoints. Our
organizing principle is a single sum-of-squares **Dirichlet identity**,
`⟨Δx, x⟩ = ‖dx‖² + ‖e*x‖²`, from which the entire structure theory follows by
elementary means. We prove that `Δ` is self-adjoint and positive semidefinite;
that its kernel — the *harmonic space* — coincides exactly with the
closed-and-co-closed cochains; that the Rayleigh quadratic form is strictly
positive off the kernel; and that, by self-adjointness, the image of `Δ` is
orthogonal to the harmonic space. On the dynamical side we introduce the
explicit-Euler **diffusion step** `S = I − a·Δ` and the orthogonal **harmonic
projection** `P`, and prove two conservation laws: harmonic cochains are fixed
by `S` at every iteration depth, and the harmonic projection is conserved along
the entire diffusion trajectory, `P(Sᵏ x) = P x`. These results recast the
classical Hodge program in a wholly elementary, computation-ready form, and they
furnish a rigorous account of why diffusion-based message passing preserves
topological signal while relaxing exact and co-exact noise. We close with a
detailed program of open conjectures — the orthogonal splitting `range Δ =
(ker Δ)ᗮ`, a bundled self-adjoint Green's operator, strict Lyapunov decay,
spectral-gap contraction, and a Hodge-isomorphism isometry — each reduced to a
single remaining technical step by the theorems established here.

**Keywords.** Hodge Laplacian, cochain complex, harmonic forms, Dirichlet
energy, orthogonal projection, graph diffusion, message passing, spectral graph
theory, discrete exterior calculus.

---

## 1. Introduction

### 1.1 Motivation

The Laplace operator is the connective tissue of mathematics and physics: it
governs heat flow and diffusion, electrostatics and potential theory, the
vibration of membranes, and — through Hodge theory — the topology of manifolds.
Its discrete avatars on graphs and simplicial complexes have become central to
spectral graph theory, topological data analysis, computational physics, and,
most recently, the design of graph neural networks, whose message-passing layers
are literally discrete diffusion steps.

The classical **Hodge theorem** states that on a compact oriented Riemannian
manifold, each de Rham cohomology class contains a unique harmonic
representative, and that the space of differential forms splits orthogonally into
exact, co-exact, and harmonic parts. The harmonic forms are simultaneously closed
(`dω = 0`) and co-closed (`d*ω = 0`), and their dimensions are the Betti numbers
— topological invariants. This is the prototypical *local-to-global* principle:
purely local differential data (the operators `d` and `d*`) assembles into a
global topological invariant (the harmonic space).

This paper isolates the algebraic skeleton of that principle in its leanest
finite-dimensional form. We work with a *two-step* complex — exactly the data
needed to define a Hodge Laplacian on a single middle space — and we show that a
single quadratic identity drives the entire theory, requiring neither manifold
structure, nor measure theory, nor explicit eigenvalue analysis.

### 1.2 Contributions

We establish, over arbitrary finite-dimensional real inner-product spaces:

1. **Self-adjointness** of the Hodge Laplacian `Δ` (Theorem 4.1).
2. The **Dirichlet sum-of-squares identity** `⟨Δx, x⟩ = ‖dx‖² + ‖e*x‖²`
   (Theorem 4.2), implying positive semidefiniteness.
3. The **harmonic characterization** `Δx = 0 ⇔ dx = 0 ∧ e*x = 0`
   (Theorem 4.3): the kernel of `Δ` is exactly the closed-and-co-closed
   cochains.
4. **Strict positivity off the kernel**: `⟨Δx, x⟩ = 0 ⇔ Δx = 0`
   (Theorem 4.4).
5. The **orthogonality of the image to the kernel**: `Δx ∈ (ker Δ)ᗮ`
   (Theorem 4.5).
6. Two **diffusion conservation laws** (Theorems 5.1–5.4): harmonic cochains are
   fixed by `S = I − a·Δ` at every depth, and the harmonic projection is
   conserved, `P(Sᵏ x) = P x`.

Each result is proved by elementary means, and the development is entirely
self-contained, depending only on standard finite-dimensional inner-product
space theory and the adjoint calculus.

---

## 2. Preliminaries and notation

Throughout, `U`, `V`, `W` are finite-dimensional real inner-product spaces. We
write `⟨·,·⟩` for the (real) inner product on whichever space is in context,
`‖x‖ = √⟨x,x⟩` for the induced norm, and we freely use the polarization-free
identity `⟨x,x⟩ = ‖x‖²`.

For a linear map `T : A → B` between finite-dimensional real inner-product
spaces, the **adjoint** `T* : B → A` is the unique linear map satisfying the
**adjunction identities**

```
   ⟨ T a , b ⟩_B = ⟨ a , T* b ⟩_A          (adjoint on the right)
   ⟨ T* b , a ⟩_A = ⟨ b , T a ⟩_B          (adjoint on the left)
```

for all `a ∈ A`, `b ∈ B`. In finite dimensions the adjoint always exists and is
unique; relative to orthonormal bases it is the matrix transpose. We will use the
adjunction identities as the *only* nontrivial input to the analytic theorems.

For a subspace `K ⊆ V`, we write `Kᗮ` for its orthogonal complement and
`ker T`, `range T` for the kernel and image of a linear map `T`. The **orthogonal
projection** onto a subspace `K` is the unique linear map `P_K : V → K` with
`x − P_K x ⊥ K` for all `x`.

---

## 3. The two-step cochain complex and the Hodge Laplacian

### 3.1 Definition

We are given two linear maps forming a two-step diagram of finite-dimensional
real inner-product spaces:

```
        e               d
   U  ------>   V   ------>   W .
```

We do **not** in general assume the complex condition `d ∘ e = 0`; none of our
core theorems require it. (When `d ∘ e = 0`, the dimension of the harmonic space
recovers the homology of the complex, the classical setting; this is the regime
of the worked example in Section 6.)

**Definition 3.1 (Hodge Laplacian).**
The *Hodge Laplacian* of the complex, acting on the middle space `V`, is the
linear endomorphism

```
   Δ  :=  d* ∘ d  +  e ∘ e*   :  V → V ,
```

where `d* = adjoint(d) : W → V` and `e* = adjoint(e) : V → U`. Explicitly, for
`x ∈ V`,

```
   Δ x  =  d*( d x )  +  e( e* x ) .
```

The first summand `d* d` is the *up-Laplacian* (it sees the level above, `W`);
the second summand `e e*` is the *down-Laplacian* (it sees the level below, `U`).
Their sum is the *full* Hodge Laplacian on `V`.

### 3.2 The diffusion step and the harmonic projection

**Definition 3.2 (Diffusion step).**
For a real step size `a`, the *explicit-Euler diffusion step* is the linear
endomorphism

```
   S  :=  I − a · Δ   :  V → V ,        S x = x − a · Δ x ,
```

where `I` is the identity on `V`. Because `S` is linear, its `k`-fold iterate
`Sᵏ` is again linear for every `k ∈ ℕ`.

**Definition 3.3 (Harmonic projection).**
The *harmonic projection* is the orthogonal projection onto the harmonic space,

```
   P  :=  P_{ker Δ}  :  V → ker Δ .
```

By definition of orthogonal projection, `P` is linear and `x − P x ∈ (ker Δ)ᗮ`
for every `x`.

---

## 4. The static structure theory

This section establishes the operator-algebraic and analytic backbone. The proofs
are short and use only the adjunction identities and the sum-of-squares
principle.

### 4.1 Self-adjointness

**Theorem 4.1 (Self-adjointness).**
The Hodge Laplacian is self-adjoint:

```
   ⟨ Δ x , y ⟩ = ⟨ x , Δ y ⟩    for all  x, y ∈ V .
```

*Proof sketch.* Expand `Δ = d*d + e e*` and treat the two summands separately.
For the up-Laplacian, two applications of the adjunction identity give
`⟨ d*(dx), y ⟩ = ⟨ dx, dy ⟩ = ⟨ x, d*(dy) ⟩`. For the down-Laplacian, similarly
`⟨ e(e*x), y ⟩ = ⟨ e*x, e*y ⟩ = ⟨ x, e(e*y) ⟩`. Both summands are symmetric in
`x` and `y`, hence so is their sum. ∎

Self-adjointness is the source of all later orthogonality statements; in
particular it makes `Δ` diagonalizable in an orthonormal basis (the finite-
dimensional spectral theorem), a fact we invoke only in the discussion of future
directions.

### 4.2 The Dirichlet identity

**Theorem 4.2 (Dirichlet sum-of-squares identity).**
For every `x ∈ V`,

```
   ⟨ Δ x , x ⟩  =  ‖ d x ‖²  +  ‖ e* x ‖² .
```

*Proof sketch.* Compute the two summands of `⟨Δx, x⟩` separately. The
adjunction identity gives `⟨ d*(dx), x ⟩ = ⟨ dx, dx ⟩ = ‖dx‖²`, and likewise
`⟨ e(e*x), x ⟩ = ⟨ e*x, e*x ⟩ = ‖e*x‖²`. Summing yields the claim. ∎

**Corollary 4.2.1 (Positive semidefiniteness).**
The quadratic form `x ↦ ⟨Δx, x⟩` is non-negative, so `Δ` is positive
semidefinite. Consequently every eigenvalue of `Δ` is `≥ 0`.

The left side `⟨Δx, x⟩` is the **Dirichlet energy** (equivalently, the
unnormalized Rayleigh quotient numerator) of the configuration `x`. The two
squares on the right measure, respectively, the failure of `x` to be *closed*
(`dx = 0`) and *co-closed* (`e*x = 0`). The identity is the engine of the entire
theory.

### 4.3 The harmonic characterization

**Theorem 4.3 (Harmonic ⇔ closed and co-closed).**
For every `x ∈ V`,

```
   Δ x = 0    ⇔    d x = 0   and   e* x = 0 .
```

*Proof sketch.* (⇐) If `dx = 0` and `e*x = 0` then both summands of
`Δx = d*(dx) + e(e*x)` vanish, so `Δx = 0`. (⇒) Suppose `Δx = 0`. Pairing with
`x` and applying Theorem 4.2 gives `0 = ⟨Δx, x⟩ = ‖dx‖² + ‖e*x‖²`. A sum of two
non-negative reals is zero only if each is zero, so `‖dx‖² = 0` and `‖e*x‖² = 0`,
whence `dx = 0` and `e*x = 0`. ∎

Theorem 4.3 is the algebraic core of Hodge theory: the kernel of `Δ` — the
*harmonic space* — is exactly the intersection of the closed cochains `ker d`
with the co-closed cochains `ker e*`. When `d ∘ e = 0`, the dimension of this
space equals `dim(ker d) − dim(range e)`, the homology of the complex at `V`; in
the graph setting of Section 6 it is the first Betti number, the number of
independent cycles.

### 4.4 Strict positivity off the kernel

**Theorem 4.4 (Rayleigh form vanishes only on harmonics).**
For every `x ∈ V`,

```
   ⟨ Δ x , x ⟩ = 0    ⇔    Δ x = 0 .
```

*Proof sketch.* By Theorem 4.2, `⟨Δx, x⟩ = ‖dx‖² + ‖e*x‖²`, and this vanishes iff
`dx = 0` and `e*x = 0` (sum of squares), which by Theorem 4.3 holds iff `Δx = 0`.
∎

Equivalently, `⟨Δx, x⟩ > 0` for every non-harmonic `x`: the Dirichlet energy is
*strictly positive* away from the kernel. This is the quantitative statement that
`Δ` has a genuine spectral gap above its zero eigenspace, expressed without any
explicit eigenvalue computation.

### 4.5 Orthogonality of the image to the kernel

**Theorem 4.5 (Image lands in the orthogonal complement of the kernel).**
For every `x ∈ V`,

```
   Δ x  ∈  (ker Δ)ᗮ .
```

*Proof sketch.* Let `h ∈ ker Δ` be harmonic, so `Δh = 0`. By self-adjointness
(Theorem 4.1), `⟨ Δx , h ⟩ = ⟨ x , Δh ⟩ = ⟨ x , 0 ⟩ = 0`. Since this holds for
every harmonic `h`, the vector `Δx` is orthogonal to all of `ker Δ`. ∎

Theorem 4.5 says the Laplacian moves data strictly *transverse* to the harmonic
core: it can never produce a harmonic output, and it never has a harmonic
component to subtract. This is the first half of the Hodge decomposition
`V = ker Δ ⊕ range Δ`; the reverse inclusion `range Δ ⊇ (ker Δ)ᗮ` is identified
as a conjecture in Section 7.

---

## 5. Diffusion message passing: two conservation laws

We now turn to the dynamics of the diffusion step `S = I − a·Δ`. The results say,
in two complementary ways, that diffusion *preserves topology*.

### 5.1 Harmonics are fixed points at every depth

**Theorem 5.1 (Harmonic fixed point).**
If `h ∈ V` is harmonic, i.e. `Δh = 0`, then for every step size `a`,

```
   S h = h .
```

*Proof sketch.* `S h = h − a · Δh = h − a · 0 = h`. ∎

**Theorem 5.2 (Fixed at every depth).**
If `Δh = 0`, then for every `k ∈ ℕ`,

```
   Sᵏ h = h .
```

*Proof sketch.* Induction on `k`. The base case `S⁰h = h` is immediate. For the
step, `S^{k+1} h = S( Sᵏ h ) = S h = h`, using the inductive hypothesis
`Sᵏ h = h` and then Theorem 5.1. ∎

Thus the harmonic space is an invariant subspace on which `S` acts as the
identity: no amount of diffusion alters a purely harmonic configuration.

### 5.2 The harmonic projection is conserved

The deeper conservation law concerns *arbitrary* configurations, whose harmonic
content is extracted by the projection `P` of Definition 3.3.

**Theorem 5.3 (Harmonic projection conserved in one step).**
For every `x ∈ V` and every step size `a`,

```
   P( S x ) = P x .
```

*Proof sketch.* By linearity of `P` and the definition of `S`,
`P(Sx) = P(x − a·Δx) = P x − a · P(Δx)`. By Theorem 4.5, `Δx ∈ (ker Δ)ᗮ`, and
the orthogonal projection onto a subspace annihilates its orthogonal complement,
so `P(Δx) = 0`. Hence `P(Sx) = P x`. ∎

**Theorem 5.4 (Harmonic projection conserved at every depth).**
For every `x ∈ V`, every step size `a`, and every `k ∈ ℕ`,

```
   P( Sᵏ x ) = P x .
```

*Proof sketch.* Induction on `k`. The base case is `P(S⁰x) = P x`. For the step,
`P(S^{k+1} x) = P( S (Sᵏ x) ) = P( Sᵏ x ) = P x`, applying Theorem 5.3 to the
vector `Sᵏ x` and then the inductive hypothesis. ∎

Theorem 5.4 is the central dynamical statement: **the harmonic (topological)
component of the data is an exact invariant of the entire diffusion trajectory.**
Diffusion can relax the exact and co-exact (noise) components arbitrarily, but it
can neither create nor destroy harmonic content. In the language of graph neural
networks, message passing preserves the global topological signal while smoothing
local fluctuations — a guarantee that simultaneously explains the *value* of
diffusion (it protects meaningful structure) and the phenomenon of
*over-smoothing* (in the limit, only the harmonic part survives).

---

## 6. A worked example

To make the theory concrete we exhibit a small complex with non-trivial topology.

**The theta graph.** Take two vertices `{0, 1}` joined by three parallel edges
`e₀, e₁, e₂`, each oriented `0 → 1`. Let the middle space be the edge space
`V = ℝ³`, the lower space the vertex space `U = ℝ²`, and the upper space
`W = ℝ¹`, carrying a single 2-cell whose oriented boundary is the loop
`e₀ − e₁`. The maps are

```
        ⎡ −1   1 ⎤
   e  = ⎢ −1   1 ⎥  :  ℝ² → ℝ³ ,        d = [ 1  −1   0 ]  :  ℝ³ → ℝ¹ .
        ⎣ −1   1 ⎦
```

Here `e` is the vertex→edge coboundary `(e f)(u→v) = f(v) − f(u)`, and `d` is the
edge→face coboundary. One checks `d ∘ e = 0`, so this is a genuine cochain
complex. Computing the adjoints as transposes,

```
   Δ = d*d + e e*  =  ⎡ 3  1  2 ⎤
                      ⎢ 1  3  2 ⎥ .
                      ⎣ 2  2  2 ⎦
```

This matrix is symmetric (illustrating Theorem 4.1). Its kernel is
one-dimensional — the theta graph has two independent loops, one of which has
been filled by the 2-cell, leaving a single un-filled loop, so the first Betti
number is `1`. The unique (up to scale) harmonic vector is both closed
(`d h = 0`) and co-closed (`e* h = 0`), confirming Theorem 4.3.

**Dirichlet identity.** For a generic `x ∈ ℝ³`, direct computation confirms
`⟨Δx, x⟩ = ‖dx‖² + ‖e*x‖²` to machine precision (Theorem 4.2), and the value is
strictly positive whenever `x` is not harmonic (Theorem 4.4).

**Diffusion.** With step size `a = 0.1`, the diffusion step `S = I − a·Δ` fixes
the harmonic vector exactly at every depth (Theorem 5.2), and for a random
initial `x` the harmonic projection `P(Sᵏ x)` equals `P x` for all `k`
(Theorem 5.4), while the non-harmonic residual `‖Sᵏ x − P x‖` decays
exponentially:

```
   k =   0   ‖Sᵏx − Px‖ ≈ 2.05
   k =   1   ‖Sᵏx − Px‖ ≈ 1.06
   k =   5   ‖Sᵏx − Px‖ ≈ 0.32
   k =  50   ‖Sᵏx − Px‖ ≈ 1.4 × 10⁻⁵
   k = 200   ‖Sᵏx − Px‖ ≈ 1.0 × 10⁻¹⁶
```

The numerical companion `demo.py` reproduces all of these checks.

---

## 7. Discussion and applications

### 7.1 The economy of the sum-of-squares identity

The striking feature of this development is how much is extracted from a single
identity. Theorem 4.2 — energy equals `‖dx‖² + ‖e*x‖²` — simultaneously yields
positive semidefiniteness (Corollary 4.2.1), the topological identification of
the kernel (Theorem 4.3), the strict spectral gap off the kernel
(Theorem 4.4), and, in concert with self-adjointness, the orthogonal
transversality of the image (Theorem 4.5). The dynamical conservation laws
(Theorems 5.1–5.4) then require nothing beyond the linearity of `Δ` and of the
projection `P`, plus the transversality `Δx ∈ (ker Δ)ᗮ`.

Methodologically, two choices keep the proofs elementary. First, working with the
inner-product energy `⟨v, v⟩` rather than the norm `‖v‖` avoids square roots
entirely. Second, phrasing the kernel characterization through the quadratic form
(`⟨Δx, x⟩ = 0 ⇔ Δx = 0`) sidesteps any explicit eigenvalue bookkeeping: the
spectral gap is encoded qualitatively, exactly where it is needed.

### 7.2 Applications

- **Topological data analysis and spectral graph theory.** With `U`, `V`, `W`
  the vertices, edges, and faces of a simplicial complex, `Δ` is the
  combinatorial Hodge Laplacian. Its harmonic space detects loops that cannot be
  contracted — independent cycles — relevant to robust sensor coverage,
  electrical network analysis, and the global geometry of point clouds.

- **Computational physics.** When `V` carries a discretized physical field, `Δ`
  governs the relaxation of heat, charge, or incompressible flow toward
  equilibrium, while the harmonic component encodes conserved topological
  currents (e.g. circulation around obstacles) that diffusion cannot dissipate.

- **Graph neural networks.** The diffusion step `S = I − a·Δ` is precisely a
  message-passing layer. Theorem 5.4 proves that such layers preserve the global
  topological signal, while Theorems 4.4 and the residual decay of Section 6
  quantify *over-smoothing*: as depth grows, the representation converges to its
  harmonic projection, so all non-topological information is eventually lost. The
  theory thus identifies both the benefit and the failure mode of deep message
  passing.

### 7.3 Soundness

Every theorem above is established by elementary finite-dimensional arguments —
the adjunction identities, the sum-of-squares principle, the definition of
orthogonal projection, and induction — with no appeal to nonconstructive
machinery beyond the standard existence of adjoints and orthogonal projections in
finite dimensions.

---

## 8. Future directions

The static and dynamical theorems above were specifically chosen because each one
reduces a deeper structural conjecture to a single remaining step. We list the
program.

**Direction 1 — The orthogonal splitting `range Δ = (ker Δ)ᗮ`.**
We proved the easy inclusion `Δx ∈ (ker Δ)ᗮ` (Theorem 4.5). The full identity
`range Δ = (ker Δ)ᗮ` would yield the complete Hodge decomposition
`V = ker Δ ⊕ range Δ` and make `Δ` a linear isomorphism of `(ker Δ)ᗮ` onto
itself. It is falsifiable by any `y ∈ (ker Δ)ᗮ` not of the form `Δx`, or any
nonzero `z ∈ (ker Δ)ᗮ` with `Δz = 0`. Because `Δ` is self-adjoint and positive
semidefinite, this follows from the finite-dimensional rank–nullity and spectral
theorems applied to the invariant complement.

**Direction 2 — A bundled, self-adjoint Green's operator.**
Conjecture that the pointwise solver of `Δz = x − P x` on `(ker Δ)ᗮ` bundles into
a genuine linear map `G : V → V` with `G ∘ Δ = Δ ∘ G = I − P`, `G ∘ P = 0`, and
`G` self-adjoint. The key insight is that uniqueness is the *only* obstruction to
linearity: if `z(x)` is the unique solution in `(ker Δ)ᗮ`, then `z(x+y)` and
`z(x)+z(y)` solve the same problem and injectivity on the complement forces them
equal, so `G` is automatically additive and homogeneous; self-adjointness follows
from Theorem 4.1 restricted to the invariant complement. Falsifiable by a
candidate `G` with `Δ(Gx) ≠ x − Px` or `⟨Gx, y⟩ ≠ ⟨x, Gy⟩`.

**Direction 3 — Strict Lyapunov decay with harmonic limit.**
Conjecture that the Dirichlet energy `E(x) = ⟨Δx, x⟩` is non-increasing along
admissible diffusion, `E(Sx) ≤ E(x)` for `0 < a < 2/λ_max`, with equality iff `x`
is harmonic, and that `Sᵏ x → P x` as `k → ∞`. The key insight is that
Theorem 4.2 already exhibits `E` as a sum of squares whose zero set is exactly
`ker Δ` (Theorem 4.4), and Theorem 5.4 pins the limit's harmonic part to `P x`,
so only the complementary part must be shown to vanish. Monotonicity reduces to
the algebraic estimate `E(x) − E(Sx) = 2a⟨Δx, Δx⟩ − a²⟨Δx, Δ(Δx)⟩ ≥ 0`.
Falsifiable by an `x` and admissible `a` with `E(Sx) > E(x)`.

**Direction 4 — Quantitative contraction at the spectral-gap rate.**
Conjecture that for `0 < a < 2/λ_max`, `‖Sᵏ x − P x‖ ≤ ρᵏ ‖x − P x‖` with
`ρ = max_{λ>0} |1 − aλ| < 1` over the nonzero eigenvalues of `Δ`. The key insight
is that Theorem 5.4 makes `x − P x` the only part that moves, and on `(ker Δ)ᗮ`
the Laplacian has strictly positive eigenvalues (Theorems 4.4 and the injectivity
of `Δ` on the complement), so the bound collapses to the one-dimensional estimate
`|1 − aλ| ≤ ρ` per eigenvector. Falsifiable by an iterate failing to contract by
`ρ`.

**Direction 5 — Spectral resolution `Δ = Σ λᵢ Pᵢ`.**
Conjecture the finite-dimensional spectral theorem for `Δ`: an orthonormal
eigenbasis with `0 = λ₀ ≤ λ₁ ≤ ⋯`, the `0`-eigenprojection equal to the harmonic
projection `P`, `Δ = Σ λᵢ Pᵢ`, and the Green's operator `G = Σ_{λᵢ>0} λᵢ⁻¹ Pᵢ`.
Self-adjointness (Theorem 4.1) feeds Mathlib's spectral theorem directly, the
Dirichlet form pins the spectrum to `[0, ∞)` (Corollary 4.2.1), and Theorem 4.4
identifies the `0`-eigenspace with `ker Δ`, so the eigendecomposition is an
*application* of established results. Falsifiable by a negative eigenvalue, a
non-harmonic `0`-eigenvector, or a mismatch `G ≠ Σ λᵢ⁻¹ Pᵢ`.

**Direction 6 — The discrete Hodge isomorphism as a quotient isometry.**
Conjecture that the harmonic representative realizes the cohomology quotient:
every class `[x]` with `dx = 0` has a unique harmonic representative
`P x ∈ ker Δ`, giving a linear isomorphism `ker d / range e ≃ ker Δ` that is an
*isometry* for the quotient norm, `‖[x]‖ = ‖P x‖`. The key insight is that the
orthogonal splitting (Direction 1) decomposes any closed cochain into a harmonic
part `P x` and a part in `range Δ`; restricted to closed cochains the
`d*`-component vanishes, so `x − P x ∈ range e` and `P x` is the canonical class
representative, with the energy minimization `‖P x‖ ≤ ‖x − e u‖` making the
quotient infimum attained exactly at `P x`. Falsifiable by a closed `x` whose
harmonic projection leaves its class, or a class whose quotient norm differs from
`‖P x‖`.

---

## 9. Conclusion

We have given a wholly elementary, self-contained foundation for the discrete
Hodge Laplacian of a two-step cochain complex, organized around a single
sum-of-squares Dirichlet identity. From that identity flow self-adjointness,
positive semidefiniteness, the topological identification of the harmonic space,
a strict spectral gap, and the orthogonal transversality of the image. Layering
on the diffusion step `S = I − a·Δ`, we proved two conservation laws — harmonics
are fixed at every depth, and the harmonic projection is an exact invariant of
the trajectory — that rigorously explain why diffusion-based message passing
preserves topological signal while relaxing noise. The six future directions show
that the same handful of theorems place the full Hodge decomposition, a
self-adjoint Green's operator, Lyapunov decay, spectral-gap contraction, a
spectral resolution, and a Hodge-isomorphism isometry each within a single step's
reach.
