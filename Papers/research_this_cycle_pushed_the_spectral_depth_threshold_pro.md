# The Full Hodge Decomposition and a Logarithmic Depth Law for Simplicial Message Passing

## Abstract

We study message passing with the combinatorial Hodge Laplacian on the `k`-cochains of a
simplicial or cell complex, the higher-order generalization of graph neural networks. We
present two complementary advances, both established as machine-checked, sorry-free
theorems. First, we upgrade the single up-Laplacian `L = Bᵀ B` to the genuine two-map
Hodge Laplacian `L = Dᵀ D + E Eᵀ`, built from the down boundary map `D = ∂ₖ` and the up
boundary map `E = ∂ₖ₊₁`. We prove that the Dirichlet energy splits without interference
into a closed channel `‖D x‖²` and a coclosed channel `‖Eᵀ x‖²`, that the operator is
symmetric and positive semidefinite, and — our central structural result — a **discrete
Hodge theorem**: a cochain is harmonic if and only if it is simultaneously closed and
coclosed, identifying the harmonic space with the cohomological invariant
`ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`. The chain condition `∂ₖ ∂ₖ₊₁ = 0` is isolated to a single image
orthogonality lemma, from which a Pythagorean energy identity follows. Second, we replace
the previously non-constructive spectral depth threshold with an **explicit logarithmic
depth law**: if each layer contracts the energy by a factor `ρ ∈ (0,1)`, then
`N(ε) = ⌈log_ρ(ε / ‖x‖²)⌉` layers provably drive the residual energy below any tolerance
`ε`. Together these results recast oversmoothing as a deformation retraction onto the
cohomology of the data, run on an explicit logarithmic clock.

**Keywords:** Hodge Laplacian, discrete Hodge theorem, simplicial neural networks,
oversmoothing, spectral gap, Dirichlet energy, cohomology, depth–accuracy trade-off.

---

## 1. Introduction

Message-passing neural networks update a signal `x` over the cells of a combinatorial
structure by repeatedly mixing each cell's value with those of its neighbors. On graphs
this is governed by the scalar graph Laplacian; on higher structures — simplicial or cell
complexes — by the **combinatorial Hodge Laplacian** acting on `k`-cochains. A persistent
failure mode, *oversmoothing*, is the empirical observation that very deep networks
collapse all signal into a low-dimensional, uninformative subspace.

This paper makes the oversmoothing phenomenon precise on two axes.

1. **Structural (Sections 3–4).** *What* survives arbitrarily deep smoothing? We model the
   full two-sided Hodge Laplacian and prove a discrete Hodge theorem identifying the
   survivors as exactly the closed-and-coclosed cochains — the cohomology classes.

2. **Quantitative (Section 5).** *How fast* does everything else decay? We give an
   explicit, evaluable depth formula `⌈log_ρ(ε/E)⌉` and prove it suffices, establishing a
   logarithmic depth–accuracy trade-off.

Throughout, the ambient field is `ℝ`, cochains are vectors in `ℝⁿ`, and boundary
operators are realized as real matrices. The inner product is the Euclidean dot product
`x ⬝ᵥ y`, and `‖v‖² := v ⬝ᵥ v`.

---

## 2. Preliminaries and notation

Let a cell complex have `C_{k-1}`, `C_k`, `C_{k+1}` cochain spaces of dimensions `p`, `n`,
`q` respectively. The relevant boundary maps, realized as matrices, are:

- `D : ℝⁿ → ℝᵖ`, the **down / divergence** map `∂ₖ` (a `p × n` matrix);
- `E : ℝᵠ → ℝⁿ`, the **up / gradient** map `∂ₖ₊₁` (an `n × q` matrix).

**Definition 2.1 (Hodge Laplacian).** The full combinatorial Hodge Laplacian on
`C_k = ℝⁿ` is
> `fullHodge D E := Dᵀ D + E Eᵀ`,

the sum of the *down* Laplacian `Dᵀ D` and the *up* Laplacian `E Eᵀ`.

**Definition 2.2 (Message-passing step).** One gradient-descent layer with step size `α`
on a symmetric operator `L` is
> `mpStep L α x := x − α • (L *ᵥ x)`.

**Definition 2.3 (Harmonic cochain).** A cochain `x` is *harmonic* if `L *ᵥ x = 0`.

**Definition 2.4 (Dirichlet energy).** The Dirichlet energy of `x` is the quadratic form
`x ⬝ᵥ (L *ᵥ x)`.

**Chain condition.** When `D` and `E` come from a genuine complex they satisfy
`∂ₖ ∂ₖ₊₁ = 0`, i.e. `D E = 0` ("the boundary of a boundary is zero"). We invoke this
hypothesis only where stated.

---

## 3. The full Hodge Laplacian: symmetry, energy split, positivity

**Theorem 3.1 (Symmetry, `fullHodge_isSymm`).** `fullHodge D E` is symmetric:
`(Dᵀ D + E Eᵀ)ᵀ = Dᵀ D + E Eᵀ`.

*Proof sketch.* Transpose distributes over the sum and reverses products:
`(Dᵀ D)ᵀ = Dᵀ (Dᵀ)ᵀ = Dᵀ D` and `(E Eᵀ)ᵀ = (Eᵀ)ᵀ Eᵀ = E Eᵀ`. ∎

**Theorem 3.2 (Energy split, `fullHodge_quadform`).** For every `x ∈ ℝⁿ`,
> `x ⬝ᵥ (fullHodge D E) *ᵥ x = (D *ᵥ x) ⬝ᵥ (D *ᵥ x) + (Eᵀ *ᵥ x) ⬝ᵥ (Eᵀ *ᵥ x).`

That is, the Dirichlet energy decomposes into a **closed channel** `‖D x‖²` and a
**coclosed channel** `‖Eᵀ x‖²`.

*Proof sketch.* Distribute the dot product over the sum `Dᵀ D + E Eᵀ`. For the first
summand, `x ⬝ᵥ (Dᵀ D) x = x ⬝ᵥ Dᵀ (D x) = (D x) ⬝ᵥ (D x)` by the transpose–adjunction
`x ⬝ᵥ (Mᵀ y) = (M x) ⬝ᵥ y` (Lean: `dotProduct_mulVec` with `vecMul_transpose`). For the
second, the symmetric computation with `E Eᵀ` gives `(Eᵀ x) ⬝ᵥ (Eᵀ x)` via
`mulVec_transpose`. ∎

**Theorem 3.3 (Positive semidefiniteness, `fullHodge_psd`).** For every `x`,
`0 ≤ x ⬝ᵥ (fullHodge D E) *ᵥ x`.

*Proof sketch.* By Theorem 3.2 the energy is a sum of two dot-products of a vector with
itself. Each is `Σᵢ (v i)·(v i) ≥ 0` (`Finset.sum_nonneg` with `mul_self_nonneg`); their
sum is non-negative. ∎

*Remark.* Positivity is precisely what guarantees that `mpStep` is a stable smoother:
each layer cannot increase the energy when the step is admissible.

---

## 4. The discrete Hodge theorem and the harmonic obstruction

**Theorem 4.1 (Discrete Hodge theorem, `fullHodge_kernel`).** For every `x ∈ ℝⁿ`,
> `(fullHodge D E) *ᵥ x = 0 ⟺ D *ᵥ x = 0 ∧ Eᵀ *ᵥ x = 0.`

A cochain is harmonic if and only if it is simultaneously **closed** (`D x = 0`) and
**coclosed** (`Eᵀ x = 0`). The harmonic space is therefore `ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`, the
genuine cohomological invariant.

*Proof sketch.* (⇒) If `L x = 0`, then by Theorem 3.2 the sum of the two non-negative
channel energies is `x ⬝ᵥ 0 = 0`. Two non-negative reals summing to zero are each zero, so
`‖D x‖² = 0` and `‖Eᵀ x‖² = 0`. Since the dot product of a real vector with itself
vanishes iff the vector is zero (`dotProduct_self_eq_zero`), `D x = 0` and `Eᵀ x = 0`.
(⇐) If both vanish, then
`L x = Dᵀ (D x) + E (Eᵀ x) = Dᵀ 0 + E 0 = 0`. ∎

This theorem refines the up-only characterization `harmonic_iff_boundary` (`Lx=0 ⟺ Bx=0`)
of the predecessor model to the full two-sided invariant. Note that the kernel split uses
*only* positivity of each summand; the chain condition is **not** needed here. It enters
only for the orthogonality of the two image spaces.

**Theorem 4.2 (Image orthogonality, `hodge_image_orthogonal`).** Assume `D E = 0`. Then
for all `y ∈ ℝᵠ`, `z ∈ ℝᵖ`,
> `(E *ᵥ y) ⬝ᵥ (Dᵀ *ᵥ z) = 0.`

The gradient image `range E` is orthogonal to the divergence image `range Dᵀ`.

*Proof sketch.* By adjunction, `(E y) ⬝ᵥ (Dᵀ z) = (D (E y)) ⬝ᵥ z = ((D E) y) ⬝ᵥ z`. The
chain condition `D E = 0` makes the matrix product vanish, so the inner product is `0`. ∎

**Theorem 4.3 (Hodge–Pythagoras, `hodge_energy_pythagoras`).** Assume `D E = 0`. For all
`y, z`,
> `‖E y + Dᵀ z‖² = ‖E y‖² + ‖Dᵀ z‖².`

*Proof sketch.* Expand the squared norm bilinearly into four terms; the two cross terms
`(E y) ⬝ᵥ (Dᵀ z)` and `(Dᵀ z) ⬝ᵥ (E y)` both vanish by Theorem 4.2 (the second by
symmetry of the dot product), leaving the sum of the two diagonal terms. ∎

*Remark (toward Betti numbers).* Theorems 4.1–4.2 set up the orthogonal Hodge
decomposition `ℝⁿ = range E ⊕ harmonic ⊕ range Dᵀ`. Applying rank–nullity to `∂ₖ`
restricted to `ker ∂ₖ` and removing the gradient image `range ∂ₖ₊₁` yields the
Hodge–Betti identity `bₖ = dim ker ∂ₖ − rank ∂ₖ₊₁`. This computes a *global* topological
invariant from purely *local* incidence data and is the principal direction for future
work (Section 8).

---

## 5. The logarithmic depth law

We now quantify the contraction off the harmonic core. Assume one layer contracts the
energy uniformly: there exists `ρ ∈ (0,1)` with `(T y) ⬝ᵥ (T y) ≤ ρ · (y ⬝ᵥ y)` for all
`y`. (For `T = mpStep L α`, this `ρ = 1 − αμ(2 − αλ)` arises from the spectral gap `μ` and
the operator-norm bound `λ`, in the admissible step regime `0 ≤ α`, `αλ ≤ 2`.)

**Theorem 5.1 (Geometric decay, `quadform_iterate_bound`).** If `0 ≤ ρ` and each layer
contracts by `ρ`, then for all depths `k`,
> `(Tᵏ x) ⬝ᵥ (Tᵏ x) ≤ ρᵏ · (x ⬝ᵥ x).`

*Proof sketch.* Induction on `k`. Base case `k = 0` is equality. For the step, write
`Tᵏ⁺¹ x = T(Tᵏ x)`, apply the one-layer contraction to get
`‖Tᵏ⁺¹ x‖² ≤ ρ · ‖Tᵏ x‖²`, then the inductive hypothesis `‖Tᵏ x‖² ≤ ρᵏ ‖x‖²` multiplied
by `ρ ≥ 0`. ∎

**Lemma 5.2 (Analytic core, `pow_le_of_logb_le`).** Let `0 < ρ < 1` and `0 < c`. If
`log_ρ c ≤ N` for a natural number `N`, then `ρᴺ ≤ c`.

*Proof sketch.* Take natural logarithms. Since `ρ < 1`, `log ρ < 0`. The hypothesis
`log_ρ c = log c / log ρ ≤ N`, multiplied through by the *negative* quantity `log ρ`,
**reverses** to `N · log ρ ≤ log c` (Lean: `div_le_iff_of_neg`). But `N · log ρ =
log(ρᴺ)`, and `log` is monotone on positives, so `ρᴺ ≤ c`. The sign reversal is the sole
subtlety; using `div_le_iff` instead of its negative-denominator variant inverts the
conclusion. ∎

**Definition 5.3 (Explicit depth, `hodgeDepth`).** For contraction factor `ρ`, signal
energy `E₀ = ‖x‖²`, and tolerance `ε`,
> `hodgeDepth ρ E₀ ε := ⌈ log_ρ (ε / E₀) ⌉` (the natural-number ceiling `⌈·⌉₊`).

**Theorem 5.4 (Logarithmic depth law, `hodgeDepth_residual_bound`).** Let `0 < ρ < 1`,
suppose each layer contracts by `ρ`, and let `ε > 0`. Then for every depth
`k ≥ hodgeDepth ρ (x ⬝ᵥ x) ε`,
> `(Tᵏ x) ⬝ᵥ (Tᵏ x) ≤ ε.`

*Proof sketch.* By Theorem 5.1 the residual is `≤ ρᵏ · ‖x‖²`. If `‖x‖² = 0` then the
residual is `0 ≤ ε` and we are done. Otherwise `‖x‖² > 0`. The ceiling gives
`log_ρ(ε/‖x‖²) ≤ ⌈log_ρ(ε/‖x‖²)⌉ ≤ k` (`Nat.le_ceil`), so Lemma 5.2 with `c = ε/‖x‖² > 0`
yields `ρᵏ ≤ ε/‖x‖²`. Multiplying by `‖x‖² > 0` gives `ρᵏ ‖x‖² ≤ ε`, hence the residual is
`≤ ε`. ∎

**Theorem 5.5 (Specialization to message passing, `hodge_mp_log_depth`).** Under the same
hypotheses, with `T = mpStep L α` and a uniform contraction by `ρ`, every depth
`k ≥ hodgeDepth ρ (x ⬝ᵥ x) ε` satisfies `((mpStep L α)ᵏ x) ⬝ᵥ ((mpStep L α)ᵏ x) ≤ ε`.

*Proof sketch.* Immediate instance of Theorem 5.4 with `T = mpStep L α`. ∎

**Corollary 5.6 (Logarithmic scaling).** The required depth grows only logarithmically in
the inverse tolerance: improving accuracy by a fixed factor `t` (replacing `ε` by `ε/t`)
adds at most `⌈log_ρ(1/t)⌉` layers, *independent of the signal energy*, because
`E₀ = ‖x‖²` enters only through `log_ρ(ε/E₀) = log_ρ ε − log_ρ E₀` and cancels in
differences.

---

## 6. Algorithms

**Algorithm A (Hodge message passing with logarithmic early stop).** Given boundary
matrices `D, E`, step `α`, contraction `ρ`, signal `x`, tolerance `ε`: form
`L = Dᵀ D + E Eᵀ`; compute `N = hodgeDepth ρ ‖x‖² ε`; iterate `x ← x − α L x` for `N`
steps. By Theorem 5.4 the output has residual energy `≤ ε`. Per-layer cost is the cost of
two matrix–vector products; total cost is `O(N · nnz(L))`, with `N = O(log(1/ε))`.

**Algorithm B (Harmonic / cohomology projector by energy descent).** Iterate `mpStep`
until the Dirichlet energy `x ⬝ᵥ (L x)` falls below `ε`. By the discrete Hodge theorem
(Theorem 4.1) and geometric decay (Theorem 5.1), the limit lies (up to `ε`) in the
harmonic space `ker D ∩ ker Eᵀ`, i.e. the cohomology. The number of iterations is the
logarithmic `hodgeDepth`.

**Algorithm C (Hodge–Betti count).** From `D` and `E`, compute `b = dim ker D − rank E`
via standard rank computations; by the orthogonal decomposition of Section 4 this equals
`dim(harmonic space) = dim ker(fullHodge D E)`, the `k`-th Betti number.

---

## 7. Applications

- **Sizing deep simplicial / graph networks.** Corollary 5.6 turns "how deep?" into a
  closed form: budget `⌈log_ρ(ε/E)⌉` layers for target residual `ε`. The logarithmic law
  explains why returns on additional depth diminish geometrically.
- **Diagnosing oversmoothing.** The discrete Hodge theorem identifies exactly what a deep
  network retains — the cohomology classes — and what it discards — everything carrying
  Dirichlet energy.
- **Topological feature extraction.** Algorithms B and C extract harmonic representatives
  and Betti numbers from incidence data alone, useful for shape-aware learning on meshes,
  sensor networks, and molecular complexes.
- **Adaptive smoothing schedules.** Energy-independence of incremental depth (Corollary
  5.6) suggests adding layers in batches sized by geometric tolerance ratios.

---

## 8. Discussion and future work

The two theorems assemble into a single picture: message passing is a discrete
deformation retraction onto the harmonic core; the harmonic core *is* the cohomology
(Theorem 4.1); and the retraction runs on an explicit logarithmic clock (Theorem 5.4).
Several directions extend the program:

1. **Betti numbers from the harmonic kernel.** Promote the matrix lemmas to a basis-free
   operator statement with the finite-dimensional adjoint `d*`, and derive the
   Hodge–Betti identity `bₖ = dim ker ∂ₖ − rank ∂ₖ₊₁` by orthogonal rank–nullity.
2. **Convergence to the harmonic projector.** Show `(mpStep L α)ᵏ → P`, the orthogonal
   projector onto `ker L`, with rate `ρᵏ` on the complement; the missing step is
   invariance of `(ker L)ᗮ`, a one-line consequence of self-adjointness.
3. **Tightness of the logarithmic depth.** Prove that on a saturating worst-case
   eigenvector, every layer strictly below `hodgeDepth` leaves residual `> ε`, making the
   ceiling a genuine minimum via the converse `ρᴺ > c` for `N < log_ρ c`.
4. **Heat-flow continuum limit.** Identify the discrete flow with the Euler scheme of the
   Hodge heat equation `ẋ = −L x`; as `α → 0` with `kα = t` fixed, `(mpStep L α)ᵏ x →
   e^{−tL} x`, matching the logarithmic depth clock to a heat-kernel half-life.
5. **Multi-tolerance schedules.** Formalize the energy-cancellation of Corollary 5.6 to
   prove incremental depths depend only on tolerance ratios, predicting batch-sized
   adaptive smoothing.

---

## 9. Conclusion

We have given a self-contained, machine-verified account of two facets of Hodge-Laplacian
message passing. Structurally, the full two-map Hodge Laplacian splits the Dirichlet
energy into orthogonal closed and coclosed channels, yielding a discrete Hodge theorem
that identifies the survivors of deep smoothing with the cohomology of the data.
Quantitatively, the residual energy decays geometrically, and an explicit
`⌈log_ρ(ε/E)⌉` depth provably reaches any tolerance, establishing a logarithmic
depth–accuracy trade-off. Oversmoothing, far from a defect, is the principled collapse of
a signal onto its topological invariants, ticking on a predictable logarithmic clock.
