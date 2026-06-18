# Spectral Depth Thresholds for Hodge-Laplacian Message Passing

## Abstract

We isolate and rigorously establish the linear-algebraic core of the conjecture
*"Spectral Universality Threshold for Hypergraph Neural Tangent Kernels on
Simplicial Complexes."* Modeling a single layer of linearized (infinite-width)
message passing on `k`-cochains as the self-adjoint operator `T = 1 − t·Δ`,
where `Δ = up + down` is the abstract combinatorial **Hodge Laplacian** — the
sum of a positive-semidefinite upper Laplacian and a positive-semidefinite lower
Laplacian — we analyze depth-`L` message passing as the operator iterate `Tᴸ`.
We prove two complementary facts. First, **topology is depth-invariant**: the
harmonic subspace `ker Δ`, which by discrete Hodge theory realizes the
cohomology of the complex, consists of *exact* fixed points of `Tᴸ` at every
depth, is characterized intrinsically as `ker Δ = ker up ⊓ ker down`, and has a
`T`-invariant orthogonal complement. The enabling lemma is a dimension-free
**Hodge vanishing principle**: for a symmetric positive-semidefinite operator
`S`, the Dirichlet energy `⟪S x, x⟫ = 0` forces `S x = 0`. Second, **non-harmonic
content is geometrically suppressed**: a mode of eigenvalue `λ ≥ μ > 0`
(spectral gap `μ`) evolves by `(1 − tλ)ᴸ ≤ (1 − tμ)ᴸ → 0`, yielding an explicit,
spectrum-uniform critical depth `L_c ≈ log ε / log(1 − tμ)` above which every
non-harmonic mode falls below any tolerance `ε`, while harmonic modes retain
amplitude `1`. Together these are a precise, falsifiable shadow of the
conjectured topology-sensitive → topology-blind phase transition: depth acts as
a low-pass filter on the Hodge spectrum whose only fixed amplitudes are the
topological ones, with transition scale governed explicitly by the spectral gap.

**Keywords.** Hodge Laplacian, simplicial complex, message passing, spectral
gap, over-smoothing, neural tangent kernel, discrete Hodge theory, depth
threshold, positive-semidefinite operators.

---

## 1. Introduction

### 1.1 Motivation

Message-passing architectures on relational data iteratively mix each unit's
state with that of its neighbors. On higher-order data — simplicial complexes,
hypergraphs, cell complexes — the appropriate diffusion operator is the
**Hodge Laplacian** acting on `k`-cochains, the higher-order generalization of
the graph Laplacian acting on vertex functions. Empirically, deeper such
networks suffer **over-smoothing**: representations contract toward a
low-dimensional subspace and distinct inputs become indistinguishable. A natural
conjecture in the infinite-width / neural-tangent-kernel regime posits a
**universality threshold** in depth, beyond which the iterated kernel becomes
insensitive to fine geometry and retains only coarse topological information.

This paper extracts the exact linear-algebraic skeleton of that conjecture and
proves it. We make no probabilistic or asymptotic-width assumptions; we work
directly with the deterministic operator `T = 1 − t·Δ` and its powers, on an
arbitrary real inner product space. Remarkably, the entire *topology-invariance*
half requires **no finite-dimensionality hypothesis**.

### 1.2 Setting and notation

Let `E` be a real inner product space (a `NormedAddCommGroup` with a real
`InnerProductSpace` structure), with inner product `⟪·, ·⟫` and induced norm
`‖·‖`. Linear operators on `E` are elements of the endomorphism ring
`End(E) = E →ₗ[ℝ] E`, whose multiplicative identity `1` is the identity map and
whose multiplication is composition. We call an operator `S`:

- **symmetric** if `⟪S x, y⟫ = ⟪x, S y⟫` for all `x, y`;
- **positive semidefinite (PSD)** if `⟪S x, x⟫ ≥ 0` for all `x`.

We fix two operators `up, down : E →ₗ[ℝ] E`, each symmetric and PSD. In the
intended geometric model `up = δ δ*` is the upper Hodge Laplacian (built from the
coboundary `δ` on `k`-cochains) and `down = d* d` is the lower Hodge Laplacian
(built from the boundary `d`); both are manifestly symmetric PSD as `A A*` forms.
We abstract away their origin and keep only symmetry and positivity.

---

## 2. Definitions

> **Definition 2.1 (Hodge Laplacian).**
> `hodgeLaplacian up down := up + down`, written `Δ`.

Since `up` and `down` are symmetric PSD, so is `Δ`: symmetry is additive, and
`⟪Δ x, x⟫ = ⟪up x, x⟫ + ⟪down x, x⟫ ≥ 0`.

> **Definition 2.2 (Harmonic cochains).** A cochain `x` is *harmonic* if
> `Δ x = 0`. The harmonic subspace is `ker Δ`. By discrete Hodge theory it is
> isomorphic to the degree-`k` cohomology of the underlying complex; its
> dimension is the `k`-th Betti number.

> **Definition 2.3 (Message-passing layer).** For a step size `t ∈ ℝ`,
> `layer up down t := (1 : End ℝ E) − t • Δ`, written `T`. Equivalently, for all
> `x`, `T x = x − t·(Δ x)`.

> **Definition 2.4 (Depth-`L` message passing).** `depthMap up down t L := Tᴸ`,
> the `L`-fold composition of `T` (a power in `End(E)`). Applying `Tᴸ` to a
> cochain models pushing it through `L` identical message-passing layers.

> **Definition 2.5 (Spectral gap).** When `Δ` admits an eigendecomposition, the
> *spectral gap* `μ` is the smallest **nonzero** eigenvalue. Modes with `λ = 0`
> are the harmonic modes; modes with `λ ≥ μ > 0` are the non-harmonic modes.

> **Definition 2.6 (Normalized step / stability).** We say the step is
> *normalized* for an eigenvalue `λ` if `0 ≤ tλ ≤ 1` (equivalently
> `0 ≤ 1 − tλ ≤ 1`), the regime in which a single layer is a (non-expansive)
> contraction on that mode. Choosing `t ≤ 1/λ_max` normalizes every mode at once.

---

## 3. The Hodge vanishing principle

The keystone is an operator analogue of "a nonnegative quadratic with a zero is
tangent to the axis there."

> **Theorem 3.1 (Hodge vanishing principle, `psd_inner_self_eq_zero`).**
> Let `S : E →ₗ[ℝ] E` be symmetric and PSD. If `⟪S x, x⟫ = 0`, then `S x = 0`.

**Proof sketch.** Consider the real function
`q(s) = ⟪S (x + s • y), x + s • y⟫` for an arbitrary `y ∈ E`. Expanding by
bilinearity and using symmetry `⟪S x, y⟫ = ⟪x, S y⟫` together with
`real_inner_comm`,
```
q(s) = ⟪S x, x⟫ + 2s ⟪S x, y⟫ + s² ⟪S y, y⟫.
```
Positivity of `S` gives `q(s) ≥ 0` for all real `s`. With `⟪S x, x⟫ = 0` this
reads `0 ≤ 2s ⟪S x, y⟫ + s² ⟪S y, y⟫` for all `s`, a one-parameter quadratic in
`s` that is nonnegative everywhere. A nonnegative-everywhere quadratic with
vanishing constant term must have vanishing linear coefficient (otherwise small
`s` of the opposite sign makes it negative); a short case analysis on whether
`⟪S y, y⟫ = 0` — choosing the optimal `s = −⟪S x, y⟫ / ⟪S y, y⟫` in the
nondegenerate case — yields `⟪S x, y⟫ = 0` for every `y`. Taking `y = S x`
forces `‖S x‖² = ⟪S x, S x⟫ = 0` (using symmetry to move `S` across), hence
`S x = 0`. ∎

This is a semidefinite Cauchy–Schwarz argument: it uses only one real parameter
and no spectral theorem, so it holds in **arbitrary** (possibly
infinite-dimensional) inner product spaces.

---

## 4. Topology is depth-invariant

### 4.1 Harmonic = closed and coclosed

> **Theorem 4.1 (`harmonic_iff`).** Assume `up, down` symmetric and PSD. Then for
> every `x`,
> ```
> Δ x = 0  ⟺  up x = 0 ∧ down x = 0.
> ```

**Proof sketch.** (⇐) Immediate: `Δ x = up x + down x = 0 + 0 = 0`. (⇒) From
`Δ x = 0`, pair with `x`:
`0 = ⟪Δ x, x⟫ = ⟪up x, x⟫ + ⟪down x, x⟫`. Both summands are `≥ 0` by PSD, so a
sum of nonnegatives being zero forces each to vanish: `⟪up x, x⟫ = 0` and
`⟪down x, x⟫ = 0`. Apply Theorem 3.1 to `up` and to `down` separately to conclude
`up x = 0` and `down x = 0`. ∎

> **Theorem 4.2 (`ker_hodgeLaplacian`).** Under the same hypotheses,
> ```
> ker Δ = ker up ⊓ ker down.
> ```

**Proof sketch.** This is the submodule-level repackaging of Theorem 4.1:
membership of `x` in either side is, pointwise, the proposition
`Δ x = 0` resp. `up x = 0 ∧ down x = 0`, which Theorem 4.1 identifies; extend by
`SetLike` extensionality. ∎

Theorem 4.2 is the discrete Hodge decomposition statement at the level of
kernels: harmonic cochains are exactly those that are simultaneously **closed**
(`down x = 0`, no boundary obstruction) and **coclosed** (`up x = 0`, no
coboundary obstruction).

### 4.2 Exact fixed points at every depth

> **Theorem 4.3 (`harmonic_depth_invariant`).** If `Δ x = 0`, then for every
> depth `L ∈ ℕ`, `Tᴸ x = x`.

**Proof sketch.** A single layer fixes `x`: `T x = x − t·(Δ x) = x − t·0 = x`.
Induct on `L`. Base `L = 0`: `T⁰ = 1` so `T⁰ x = x`. Step: assuming `Tᴸ x = x`,
`T^{L+1} x = T (Tᴸ x) = T x = x`. Hence harmonic cochains are *exact* fixed
points at all depths — no approximation, no asymptotics, and no
finite-dimensionality assumption. ∎

> **Theorem 4.4 (`harmonic_orthogonal_invariant`).** The orthogonal complement
> `(ker Δ)ᗮ` is invariant under `T = 1 − t·Δ`: if `x ⊥ ker Δ` then `T x ⊥ ker Δ`.

**Proof sketch.** Let `h ∈ ker Δ` be arbitrary and `x ∈ (ker Δ)ᗮ`. Then
`⟪T x, h⟫ = ⟪x, h⟫ − t ⟪Δ x, h⟫`. The first term vanishes since `x ⊥ h`. For the
second, symmetry of `Δ` (sum of symmetric `up, down`) moves the operator:
`⟪Δ x, h⟫ = ⟪x, Δ h⟫ = ⟪x, 0⟫ = 0` because `h` is harmonic. Hence `⟪T x, h⟫ = 0`
for all `h ∈ ker Δ`, i.e. `T x ∈ (ker Δ)ᗮ`. ∎

Theorems 4.3–4.4 say the network splits `E` into two non-interacting channels:
the harmonic channel `ker Δ`, frozen by every depth, and its complement
`(ker Δ)ᗮ`, where all subsequent decay occurs.

---

## 5. Non-harmonic content is geometrically suppressed

We now diagonalize on `(ker Δ)ᗮ`. On a mode (eigenvector) of `Δ` with eigenvalue
`λ`, a layer acts by scalar multiplication: `T e = (1 − tλ) e`, so
`Tᴸ e = (1 − tλ)ᴸ e`. The amplitude evolution is the scalar `(1 − tλ)ᴸ`, and the
entire spectral-gap analysis reduces to elementary real analysis of this scalar.

> **Theorem 5.1 (`harmonic_mode_invariant`).** For the harmonic mode `λ = 0` and
> any depth `L`, `(1 − t·0)ᴸ = 1ᴸ = 1`. Harmonic modes retain amplitude `1` at
> every depth.

**Proof sketch.** `1 − t·0 = 1` and `1ᴸ = 1`. ∎ (Consistent with Theorem 4.3.)

> **Theorem 5.2 (`mode_decay`).** Suppose `0 ≤ tμ` and `tλ ≤ 1` with `λ ≥ μ`
> (normalized step, Definition 2.6). Then for every depth `L`,
> ```
> (1 − tλ)ᴸ ≤ (1 − tμ)ᴸ.
> ```

**Proof sketch.** From `λ ≥ μ` and `t ≥ 0` we get `tλ ≥ tμ`, hence
`1 − tλ ≤ 1 − tμ`. Normalization gives `0 ≤ 1 − tλ` and
`1 − tμ ≤ 1`, so both bases lie in `[0, 1]`. Monotonicity of `x ↦ xᴸ` on
nonnegative reals (`pow_le_pow_left`) yields the claim. Thus the gentlest
non-harmonic mode (eigenvalue `μ`) is the slowest to decay and dominates the
whole non-harmonic spectrum. ∎

> **Theorem 5.3 (`gap_mode_tendsto_zero`).** If `0 < tμ < 1`, then
> `(1 − tμ)ᴸ → 0` as `L → ∞`.

**Proof sketch.** Let `r = 1 − tμ`. The hypothesis gives `0 < r < 1`, and for
such `r`, `rᴸ → 0` (`tendsto_pow_atTop_nhds_zero_of_lt_one`). ∎

Combining Theorems 5.2 and 5.3: **every** non-harmonic mode of gap at least `μ`
decays to zero, uniformly bounded by the single envelope `(1 − tμ)ᴸ`.

> **Theorem 5.4 (`depth_threshold`).** Fix a tolerance `ε > 0` and assume
> `0 < tμ < 1`. Define the **critical depth**
> ```
> L_c = ⌈ log ε / log(1 − tμ) ⌉.
> ```
> Then for every depth `L > L_c` and every non-harmonic eigenvalue `λ ≥ μ`
> (normalized step), `(1 − tλ)ᴸ ≤ (1 − tμ)ᴸ ≤ ε`. The suppression is uniform
> across the entire non-harmonic spectrum, while harmonic modes keep amplitude
> `1` (Theorem 5.1).

**Proof sketch.** We need `(1 − tμ)ᴸ ≤ ε`. With `r = 1 − tμ ∈ (0, 1)` and `ε >
0`, take natural logs: `(1 − tμ)ᴸ ≤ ε ⟺ L · log r ≤ log ε`. Since `log r < 0`,
dividing reverses the inequality: `L ≥ log ε / log r`. Hence any
`L ≥ ⌈log ε / log r⌉ = L_c` works; in particular all `L > L_c`. For such `L`,
Theorem 5.2 transports the bound from the gap mode to every `λ ≥ μ`. ∎

**Reading the threshold.** The dependence on tolerance is logarithmic:
sharpening `ε` to `ε/10` costs `+ log 10 / |log(1 − tμ)|` additional layers, an
*additive* increment. The gap enters through `log(1 − tμ) ≈ −tμ` for small `tμ`,
so `L_c ≈ log(1/ε) / (tμ)`: the critical depth is inversely proportional to the
spectral gap. Complexes with a small gap (near-disconnected or
higher-dimensionally degenerate) require far greater depth before their geometry
blurs — the data's own spectrum prices the cost of forgetting it.

---

## 6. Synthesis: a provable phase transition

Putting the two halves together, depth-`L` message passing factors, on each
eigenmode, as multiplication by `(1 − tλ)ᴸ`:

- harmonic modes (`λ = 0`): amplitude **`1`**, fixed forever (Thms. 4.3, 5.1);
- non-harmonic modes (`λ ≥ μ`): amplitude **`≤ (1 − tμ)ᴸ → 0`** (Thms. 5.2–5.4).

This is the exact linear-algebraic content of the conjectured
**topology-sensitive → topology-blind transition**. Depth is a low-pass filter
on the Hodge spectrum whose only fixed amplitudes are the topological (harmonic)
ones; the transition scale is `L_c ≈ log ε / log(1 − tμ)`, set explicitly by the
spectral gap. Over-smoothing is not pathology but the inevitable convergence of
`Tᴸ` toward the harmonic projector — i.e. toward cohomology.

---

## 7. Algorithms

### 7.1 Critical-depth estimator

**Input.** spectral gap `μ`, step `t`, tolerance `ε`.
**Output.** critical depth `L_c` past which all non-harmonic modes are below `ε`.

```
function CriticalDepth(μ, t, ε):
    assert 0 < t*μ < 1 and ε > 0
    r ← 1 − t*μ                  # gap-mode per-layer factor, in (0,1)
    Lc ← ceil( log(ε) / log(r) ) # log(r) < 0 flips the inequality
    return max(Lc, 0)
```

Complexity `O(1)`. This realizes Theorem 5.4.

### 7.2 Spectral depth filter

**Input.** symmetric PSD Laplacian `Δ` (as a matrix), step `t`, depth `L`,
cochain `x`.
**Output.** `Tᴸ x` together with the per-mode amplitude profile `(1 − tλ_i)ᴸ`.

```
function SpectralDepthFilter(Δ, t, L, x):
    (λ, U) ← SymmetricEigendecompose(Δ)   # Δ = U diag(λ) Uᵀ
    c      ← Uᵀ x                          # coordinates in eigenbasis
    factor ← (1 − t*λ)^L                   # elementwise; harmonic λ=0 → 1
    y      ← U (factor ⊙ c)                # reassemble
    return y, factor
```

Complexity: one symmetric eigendecomposition `O(n³)` then `O(n²)` per
application. The amplitude profile makes the low-pass behavior explicit:
harmonic entries stay `1`, the rest contract by `(1 − tλ)ᴸ`.

---

## 8. Applications

- **Diagnosing over-smoothing.** `CriticalDepth` predicts the depth at which a
  Hodge-Laplacian network collapses to topology, from the data's spectral gap
  alone — a principled stopping rule.
- **Architectural design dial.** To preserve geometry, keep `L < L_c`; to distil
  robust topological invariants (Betti numbers, harmonic representatives), push
  `L > L_c`. The threshold is computed, not guessed.
- **Robust topological feature extraction.** Because harmonic content is an exact
  fixed point at all depths (Thm. 4.3), deep iteration is a stable estimator of
  cohomology, immune to the contraction afflicting geometric features.
- **Hyperparameter coupling.** The relation `L_c ≈ log(1/ε)/(tμ)` ties step size
  `t`, depth `L`, and gap `μ` into a single budget, guiding joint tuning.

---

## 9. Discussion and limitations

The harmonic-side results (Sections 3–4) are **dimension-free**: they hold on any
real inner product space, since the vanishing principle uses only one-parameter
positivity. The spectral-gap side (Section 5) is stated mode-by-mode and uses an
eigendecomposition of `Δ`; in finite dimensions a symmetric `Δ` always provides
one. The current statements quantify per-eigenmode amplitudes rather than a
single operator-norm contraction; the operator-level bound
`‖Tᴸ x − P_𝓗 x‖ ≤ (1 − tμ)ᴸ ‖x‖`, with `P_𝓗` the harmonic projector, follows by
assembling the modes and is the natural next consolidation (Section 10,
direction 1). We assume the affine filter `T = 1 − t·Δ`; general polynomial
filters are addressed in direction 5.

---

## 10. Future directions

**1. Lift the scalar threshold to a uniform operator-norm contraction.**
Upgrade the mode-wise decay to `‖Tᴸ x − P_𝓗 x‖ ≤ (1 − tμ)ᴸ ‖x‖`, the convergence
of depth-`L` message passing to the harmonic projector (cohomology). On a
finite-dimensional inner product space a symmetric `Δ` orthogonally
diagonalizes, so `Tᴸ` is block-diagonal with identity harmonic block and
non-harmonic block of norm `≤ (1 − tμ)ᴸ`; the one nontrivial ingredient is that a
product of commuting PSD self-adjoint operators is PSD (a square-root / spectral
argument). The finite-dimensional spectral theorem already supplies the
orthonormal eigenbasis, so this is largely a packaging of `mode_decay` and
`gap_mode_tendsto_zero`.

**2. Make `L_c` a sharp two-sided threshold.** Complement the above-threshold
half with a below-threshold guarantee: for `L < L_c` a non-harmonic mode with
`tλ` small retains amplitude `(1 − tλ)ᴸ ≥ 1 − Ltλ ≥ δ`, so
topological-vs-nonharmonic discriminability persists, giving matching
`Θ(log(1/ε)/(tμ))` upper and lower bounds. Monotonicity of `(1 − tλ)ᴸ` in both
`λ` and `L` plus a Bernoulli inequality `(1 − a)ᴸ ≥ 1 − La` converts gap `μ` and
top eigenvalue `λ_max` into a genuine interval `[L_-, L_+]` of transitional
depths whose width is controlled by the spectral spread `λ_max / μ`.

**3. A sheaf/local-to-global formulation of the harmonic obstruction.** Recast
`ker Δ = ker up ⊓ ker down` as gluing: a cellular cosheaf of cochains on the face
poset, with `down` the local coboundary obstruction and `up` the local boundary
obstruction; harmonic cochains are the global sections simultaneously locally
closed and locally coclosed. `harmonic_iff` is exactly a stalk-level reduction —
global harmonicity detected by two independent local conditions — the defining
shape of a vanishing cohomological obstruction class. This unifies the continuous
and combinatorial Hodge stories.

**4. Topology-blindness as a quantitative indistinguishability theorem.**
Formalize the refutable core: given complexes `X, X'` with identical local
face-degree statistics (hence identical non-harmonic spectral law in the
universality regime) but different cohomology dimensions `b ≠ b'`, prove that for
`L > L_c` the centered iterated kernels satisfy
`‖(Tᴸ − P_𝓗)_X − (Tᴸ − P_𝓗)_{X'}‖ ≤ ε`, while for small `L` the difference is
bounded below by a function of `|b − b'|`. The only depth-stable difference lives
in the harmonic blocks, whose ranks are the Betti numbers, making
topology-blindness a precise rank-vs-tolerance trade-off.

**5. Polynomial (graph-filter) updates and the heat-kernel limit.** Replace the
affine layer by an arbitrary polynomial filter `p(Δ)` and identify the class of
`p` for which the threshold survives, with the heat semigroup `e^{−tΔ}` as the
continuous-depth limit `(1 − (t/L)·Δ)ᴸ → e^{−tΔ}`. Since
`ker Δ ⊆ ker(p(Δ) − p(0)·I)` for every polynomial with `p(0) = 1`,
depth-invariance of topology is automatic for all such filters, and the threshold
is governed by the single spectral condition `sup_{λ ≥ μ} |p(λ)| < 1`. This
pinpoints exactly which architectures are topology-preserving vs
topology-erasing.

---

## 11. Conclusion

We have turned the heart of a sweeping universality conjecture into theorems with
no loose ends. Depth-`L` Hodge-Laplacian message passing fixes the harmonic
(topological) subspace exactly at every depth, characterizes it intrinsically as
closed-and-coclosed cochains via a dimension-free vanishing principle, and
suppresses all non-harmonic content uniformly with explicit critical depth
`L_c ≈ log ε / log(1 − tμ)`. The result is a clean, falsifiable account of why
deep higher-order networks forget geometry and remember topology — and exactly
when they cross that line.
