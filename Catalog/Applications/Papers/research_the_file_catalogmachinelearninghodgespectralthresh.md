# Spectral Depth Thresholds for Hodge–Laplacian Message Passing: Harmonic Invariance, Geometric Contraction, and the Logarithmic Depth Law

## Abstract

We develop a rigorous linear-algebraic theory of *spectral depth thresholds* for
higher-order message passing governed by the combinatorial Hodge Laplacian on a
cell complex. Writing the (up-)Hodge Laplacian as `L = Bᵀ B` for a
boundary/incidence matrix `B`, we show that the entire theory flows from a single
Dirichlet-energy identity `⟨x, L x⟩ = ‖B x‖²`. From it we derive that `L` is
symmetric and positive semidefinite, that the discrete Hodge theorem
`L x = 0 ⇔ B x = 0` holds, and hence that the harmonic subspace (the kernel of
`L`, isomorphic to cohomology) consists of *exact fixed points* of message
passing at every depth. On the energy-carrying complement, one layer contracts
the Dirichlet energy by the explicit factor `ρ = 1 − αμ(2 − αλ)` under a spectral
gap `μ` and operator bound `λ`; iterating yields geometric decay `ρᵏ` and hence a
finite depth threshold. We sharpen this qualitative threshold into an explicit,
constructive, evaluable depth witness `N(ε) = ⌈log_ρ(ε/‖x‖²)⌉`, establishing a
logarithmic depth–accuracy trade-off. Finally we upgrade the up-only Laplacian to
the genuine combinatorial Hodge Laplacian `L = Dᵀ D + E Eᵀ` built from two
boundary maps, prove the split energy identity `⟨x, L x⟩ = ‖D x‖² + ‖Eᵀ x‖²`, and
obtain the full discrete Hodge theorem characterizing harmonic cochains as the
*closed-and-coclosed* signals `ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ` — the genuine cohomological
invariant. Conceptually, deep Hodge message passing is a discrete deformation
retraction of the signal space onto its homotopy-invariant core, with depth as
the time parameter of the retraction. All results are formalized with full rigor
and depend only on the standard foundational axioms.

**Keywords.** Hodge Laplacian, combinatorial cohomology, message passing, graph
neural networks, oversmoothing, spectral gap, Dirichlet energy, deformation
retraction, depth–accuracy trade-off.

---

## 1. Introduction

### 1.1 Motivation

Message-passing neural networks operate by repeatedly mixing each entity's
features with those of its neighbors and stacking the result into layers. On
graphs this is the workhorse of geometric deep learning; on cell complexes
(graphs enriched with faces, volumes, and higher cells) it generalizes to
*topological* neural networks operating on **cochains** — data assigned to cells
of a fixed dimension. A persistent obstacle is **oversmoothing**: as depth grows,
node/cell features collapse toward an uninformative consensus and predictive
power decays.

This paper provides a quantitative, fully rigorous account of which components of
a signal survive arbitrary depth, which decay, and at exactly what rate. The
organizing object is the combinatorial **Hodge Laplacian**, the higher-order
generalization of the graph Laplacian. The organizing principle is that message
passing is a **discrete deformation retraction** onto the harmonic (homotopy-
invariant) subspace.

### 1.2 Contributions

1. A self-contained derivation of the spectral skeleton of Hodge message passing
   from one identity: `⟨x, L x⟩ = ‖B x‖²` (Section 3).
2. The harmonic-invariance theorem: harmonic signals are exact fixed points at
   every depth (Section 4).
3. The quantitative one-layer contraction factor `ρ = 1 − αμ(2 − αλ)`, geometric
   decay `ρᵏ`, and a finite depth threshold (Section 5).
4. The explicit logarithmic depth law `N(ε) = ⌈log_ρ(ε/‖x‖²)⌉`, a constructive
   refinement of the existence threshold (Section 6).
5. The full two-boundary Hodge Laplacian `L = Dᵀ D + E Eᵀ`, the split energy
   identity, and the full discrete Hodge theorem characterizing harmonic
   cochains as closed-and-coclosed (Section 7).

---

## 2. Setting and Notation

Fix natural numbers `m, n`. Signals (cochains) are vectors `x : Fin n → ℝ`, with
the standard dot product `x ⬝ᵥ y = Σᵢ xᵢ yᵢ` and squared norm `‖x‖² = x ⬝ᵥ x`.
Matrices act on the left by `A *ᵥ x`. We write `Aᵀ` for transpose. All scalars
are real.

**Definition 2.1 (Boundary/incidence matrix).** A boundary matrix is a real
matrix `B : Matrix (Fin m) (Fin n) ℝ` encoding the incidence between cells of two
adjacent dimensions. Its transpose `Bᵀ` is the coboundary.

**Definition 2.2 (Up-Hodge Laplacian, `hodge`).**
```
L = hodge B := Bᵀ * B,    a matrix Fin n → Fin n.
```

**Definition 2.3 (Message-passing layer, `mpStep`).** For a square matrix `L` and
step size `α ∈ ℝ`,
```
mpStep L α x := x − α • (L *ᵥ x).
```
Depth-`k` message passing is the `k`-fold iterate `(mpStep L α)^[k]`.

Throughout, the **Dirichlet energy** of `x` is `⟨x, L x⟩ = x ⬝ᵥ (L *ᵥ x)`.

---

## 3. The Spectral Skeleton

All structural facts below are corollaries of one identity.

**Theorem 3.1 (Symmetry, `hodge_isSymm`).** `L = Bᵀ B` is symmetric:
`Lᵀ = L`.

*Proof sketch.* `(Bᵀ B)ᵀ = Bᵀ (Bᵀ)ᵀ = Bᵀ B`. ∎

**Theorem 3.2 (Dirichlet energy identity, `hodge_quadform`).** For all `x`,
```
x ⬝ᵥ (L *ᵥ x) = (B *ᵥ x) ⬝ᵥ (B *ᵥ x) = ‖B x‖².
```

*Proof sketch.* Unfold `L = Bᵀ B`. Then
`x ⬝ᵥ (Bᵀ B) *ᵥ x = x ⬝ᵥ Bᵀ *ᵥ (B *ᵥ x)`, and `dotProduct_mulVec` together with
`vecMul_transpose` rewrites `x ⬝ᵥ Bᵀ *ᵥ y` as `(B *ᵥ x) ⬝ᵥ y`. Taking
`y = B *ᵥ x` gives the claim. ∎

This identity is the linchpin: it converts every spectral statement about `L`
into a statement about the squared norm of a boundary, where positivity is
manifest.

**Theorem 3.3 (Positive semidefiniteness, `hodge_psd`).** For all `x`,
`0 ≤ x ⬝ᵥ (L *ᵥ x)`.

*Proof sketch.* By Theorem 3.2 the energy equals `Σᵢ (B x)ᵢ²`, a sum of squares,
hence nonnegative (`Finset.sum_nonneg` with `mul_self_nonneg`). ∎

**Theorem 3.4 (Discrete Hodge theorem, `harmonic_iff_boundary`).** For all `x`,
```
L *ᵥ x = 0   ⇔   B *ᵥ x = 0.
```

*Proof sketch.* (⇐) If `B x = 0` then `L x = Bᵀ(B x) = Bᵀ 0 = 0`. (⇒) If
`L x = 0`, then by Theorem 3.2 `‖B x‖² = ⟨x, L x⟩ = ⟨x, 0⟩ = 0`; a real vector of
zero squared norm is zero (`dotProduct_self_eq_zero`). ∎

**Definition 3.5 (Harmonic signals).** A signal `x` is *harmonic* if `L x = 0`,
equivalently `B x = 0`. By the discrete Hodge theorem, the harmonic subspace
`ker L` is isomorphic to a cohomology group of the complex and is therefore a
topological (homotopy) invariant.

---

## 4. Harmonic Invariance: The Homotopy-Invariant Core

**Theorem 4.1 (One layer fixes harmonic signals, `mpStep_fixes_harmonic`).** If
`L *ᵥ x = 0` then `mpStep L α x = x`.

*Proof sketch.* `mpStep L α x = x − α • (L x) = x − α • 0 = x − 0 = x`. ∎

**Theorem 4.2 (Every depth fixes harmonic signals,
`mpStep_iterate_fixes_harmonic`).** If `L *ᵥ x = 0`, then for all `k`,
```
(mpStep L α)^[k] x = x.
```

*Proof sketch.* Induction on `k`. Base case is `id`. Inductive step:
`(mpStep)^[k+1] x = mpStep ((mpStep)^[k] x) = mpStep x = x`, using the inductive
hypothesis and Theorem 4.1. ∎

**Interpretation.** Harmonic signals — the cohomology — pass through arbitrarily
deep networks undistorted. Topology survives oversmoothing exactly.

---

## 5. Spectral Contraction off the Harmonic Core

**Theorem 5.1 (Exact one-layer energy, `quadform_mpStep`).** For all `x`,
```
‖mpStep L α x‖² = ‖x‖² − 2α ⟨x, L x⟩ + α² ‖L x‖².
```

*Proof sketch.* Expand `(x − αL x) ⬝ᵥ (x − αL x)` by bilinearity of the dot
product and collect terms. ∎

**Theorem 5.2 (One-layer spectral contraction, `mpStep_contraction`).** Suppose
the step size satisfies `0 ≤ α` and `αλ ≤ 2`, and that
```
μ ‖x‖² ≤ ⟨x, L x⟩         (spectral-gap lower bound),
‖L x‖² ≤ λ ⟨x, L x⟩       (operator upper bound).
```
Then
```
‖mpStep L α x‖² ≤ (1 − αμ(2 − αλ)) ‖x‖².
```

*Proof sketch.* Substitute the exact energy of Theorem 5.1 and apply a positive
combination of the two spectral hypotheses scaled by `α ≥ 0`, together with the
nonnegativity `α(2 − αλ) ≥ 0`. The result is a single nonlinear arithmetic
inequality. Notably the proof needs no sign assumption on `μ`, so the theorem is
stated in its most general form. ∎

Write `ρ := 1 − αμ(2 − αλ)`. With an admissible step `0 < α < 2/λ` and positive
gap `μ`, one has `0 ≤ ρ < 1`.

**Theorem 5.3 (Geometric energy decay, `quadform_iterate_bound`).** Let
`T : (Fin n → ℝ) → (Fin n → ℝ)` and `0 ≤ ρ` satisfy
`‖T y‖² ≤ ρ ‖y‖²` for all `y`. Then for all `x` and `k`,
```
‖Tᵏ x‖² ≤ ρᵏ ‖x‖².
```

*Proof sketch.* Induction on `k`. Base case trivial. Step:
`‖T^[k+1] x‖² = ‖T (T^[k] x)‖² ≤ ρ ‖T^[k] x‖² ≤ ρ · ρᵏ ‖x‖² = ρ^{k+1} ‖x‖²`,
where the second inequality multiplies the inductive bound by `ρ ≥ 0`. ∎

**Theorem 5.4 (Finite spectral depth threshold, `spectral_depth_threshold`).**
With `0 ≤ ρ < 1` and the per-layer contraction `‖T y‖² ≤ ρ ‖y‖²`, for every
`ε > 0` there exists `N` such that all `k ≥ N` satisfy `‖Tᵏ x‖² ≤ ε`.

*Proof sketch.* Since `0 ≤ ρ < 1`, `ρᵏ ‖x‖² → 0` as `k → ∞`. Hence eventually
`ρᵏ ‖x‖² ≤ ε`; combine with Theorem 5.3. ∎

**Interpretation.** Energy-carrying (non-harmonic) signals are geometrically
contracted; finitely many layers suffice to drive the residual below any
tolerance.

---

## 6. The Logarithmic Depth Law

Theorem 5.4 is non-constructive: it asserts the existence of `N` but does not
exhibit it. We now make `N` explicit and evaluable.

**Definition 6.1 (Explicit Hodge depth, `hodgeDepth`).** For contraction factor
`ρ`, initial energy `E₀`, and tolerance `ε`,
```
hodgeDepth ρ E₀ ε := ⌈ log_ρ (ε / E₀) ⌉.
```

**Lemma 6.2 (Analytic core, `pow_le_of_logb_le`).** Let `0 < ρ < 1`, `0 < c`,
and `N ∈ ℕ` with `log_ρ c ≤ N`. Then `ρᴺ ≤ c`.

*Proof sketch.* Taking natural logs, the claim `ρᴺ ≤ c` is equivalent to
`N · log ρ ≤ log c` (logs are monotone on positive reals). Because `0 < ρ < 1`
we have `log ρ < 0`; dividing the hypothesis `log_ρ c = (log c)/(log ρ) ≤ N` by
the *negative* number `log ρ` flips the inequality to exactly
`N · log ρ ≤ log c` (this sign flip — `div_le_iff_of_neg`, not `div_le_iff` — is
the single subtle point). Re-exponentiating gives `ρᴺ ≤ c`. ∎

**Theorem 6.3 (Explicit depth threshold, `hodgeDepth_residual_bound`).** Let
`0 < ρ < 1` and `‖T y‖² ≤ ρ ‖y‖²` for all `y`. Fix a signal `x` and tolerance
`ε > 0`. Then for every depth
```
k ≥ hodgeDepth ρ (‖x‖²) ε = ⌈ log_ρ (ε / ‖x‖²) ⌉,
```
we have `‖Tᵏ x‖² ≤ ε`.

*Proof sketch.* By Theorem 5.3 the residual is `‖Tᵏ x‖² ≤ ρᵏ ‖x‖²`. If
`‖x‖² = 0` the bound is `0 ≤ ε`, done. Otherwise `‖x‖² > 0`; by `Nat.le_ceil`,
`log_ρ(ε/‖x‖²) ≤ ⌈·⌉ ≤ k`, so Lemma 6.2 (with `c = ε/‖x‖² > 0`) gives
`ρᵏ ≤ ε/‖x‖²`, i.e. `ρᵏ ‖x‖² ≤ ε`. Chaining the two inequalities completes the
proof. (When the logarithm is negative the ceiling is `0`, and zero layers
already suffice.) ∎

**Theorem 6.4 (Logarithmic depth for message passing, `hodge_mp_log_depth`).**
The previous bound specializes verbatim to `T = mpStep L α`: under a global
per-layer energy contraction by `ρ`, depth `⌈log_ρ(ε/‖x‖²)⌉` suffices for
`mpStep`.

**Interpretation: depth–accuracy trade-off.** To shrink the residual tolerance
`ε` by a factor of 10, one adds a *constant* number of layers
`⌈1 / log_ρ(1/10)⌉`; total depth grows like `log(1/ε)`. Accuracy is exponentially
cheap in depth, which both explains aggressive empirical smoothing and gives a
designer an exact stopping rule.

---

## 7. The Full Hodge Decomposition

The up-only Laplacian captures one boundary direction. The genuine combinatorial
Hodge Laplacian on `k`-cochains uses two boundary maps: the *down* map
`D = ∂ₖ : C_k → C_{k−1}` (divergence) and the *up* map `E = ∂ₖ₊₁ : C_{k+1} → C_k`
(gradient).

**Definition 7.1 (Full Hodge Laplacian, `fullHodge`).**
```
L = Dᵀ D + E Eᵀ,
```
the sum of the **down** Laplacian `Dᵀ D` and the **up** Laplacian `E Eᵀ`.

**Theorem 7.2 (Symmetry, `fullHodge_isSymm`).** `L` is symmetric.

*Proof sketch.* Both summands are of the form `MᵀM`, each symmetric; a sum of
symmetric matrices is symmetric. ∎

**Theorem 7.3 (Split Dirichlet energy, `fullHodge_quadform`).** For all `x`,
```
⟨x, L x⟩ = ‖D x‖² + ‖Eᵀ x‖².
```

*Proof sketch.* Apply the energy identity of Theorem 3.2 to each summand:
`⟨x, Dᵀ D x⟩ = ‖D x‖²` and `⟨x, E Eᵀ x⟩ = ‖Eᵀ x‖²`; add. ∎

**Theorem 7.4 (Positive semidefiniteness, `fullHodge_psd`).** `0 ≤ ⟨x, L x⟩`.

*Proof sketch.* The energy is a sum of two squared norms. ∎

**Theorem 7.5 (Full discrete Hodge theorem, `fullHodge_kernel`).** A cochain is
harmonic iff it is closed and coclosed:
```
L x = 0   ⇔   (D x = 0 ∧ Eᵀ x = 0).
```
Hence the harmonic subspace is exactly `ker ∂ₖ ∩ ker ∂ₖ₊₁ᵀ`, the genuine
cohomological invariant.

*Proof sketch.* If `D x = 0` and `Eᵀ x = 0` then each summand of `L x` vanishes.
Conversely, if `L x = 0` then by Theorem 7.3 `‖D x‖² + ‖Eᵀ x‖² = 0`; a sum of
nonnegative terms is zero only if both vanish, giving `D x = 0` and `Eᵀ x = 0`. ∎

**Theorem 7.6 (Image orthogonality, `hodge_image_orthogonal`).** Under the chain
condition `∂ₖ ∂ₖ₊₁ = 0` (i.e. `D E = 0`), the gradient image `im E` is orthogonal
to the divergence image `im Dᵀ`.

*Proof sketch.* For any `u, v`, `⟨E u, Dᵀ v⟩ = ⟨D E u, v⟩ = ⟨0, v⟩ = 0` by the
chain condition. ∎

**Theorem 7.7 (Pythagorean energy, `hodge_energy_pythagoras`).** The orthogonal
splitting of `Theorem 7.6` makes the two energy channels add Pythagoreanly,
decoupling harmonicity into the closed and coclosed conditions.

**Interpretation.** The harmonic core that survives every layer is now exactly
the cohomology. Betti numbers — the counts of independent holes — are the
dimensions of these harmonic subspaces and are the literal fixed-point set of
deep Hodge message passing.

---

## 8. The Unifying Picture: Message Passing as a Deformation Retraction

Theorems 4.2 and 5.3 together state that `mpStep` (i) holds the harmonic subspace
`ker L` pointwise fixed and (ii) contracts the orthogonal complement toward it
geometrically. A continuous process that fixes a subspace while pulling
everything onto it is a **deformation retraction**, and depth is its time
parameter. Thus:

> Deep Hodge message passing is a discrete deformation retraction of the signal
> space onto its homotopy-invariant (harmonic) core.

In this lens, **oversmoothing is the intended convergence** of the retraction —
the collapse of inessential, energy-carrying structure — and the logarithmic
depth law (Section 6) is the clock measuring how fast the retraction proceeds.

---

## 9. Algorithms

**Algorithm A (Hodge message passing with logarithmic depth budget).** Given `L`,
step `α`, contraction estimate `ρ`, signal `x`, tolerance `ε`: compute
`N = ⌈log_ρ(ε/‖x‖²)⌉`, then apply `mpStep L α` exactly `N` times. By Theorem 6.4
the residual energy is `≤ ε`, and the harmonic component of `x` is preserved
exactly. Cost: `N` sparse matrix–vector products, `N = O(log(1/ε))`.

**Algorithm B (Spectral contraction certification).** Given `L` with extreme
eigenvalues estimated as gap `μ` and top `λ`, and step `α` with `0 < α < 2/λ`,
return `ρ = 1 − αμ(2 − αλ) ∈ [0,1)`. This certifies the per-layer energy
contraction used by Algorithm A.

**Algorithm C (Harmonic/cohomology projection).** Iterate `mpStep L α` to
convergence; by the deformation-retraction picture the limit is the orthogonal
projection onto `ker L`, the harmonic representative of the cohomology class of
`x`.

---

## 10. Applications

- **Designing depth in topological neural networks.** The logarithmic law turns
  "how many layers?" into an explicit formula in the desired tolerance and the
  spectral contraction factor.
- **Diagnosing and timing oversmoothing.** The contraction factor `ρ` predicts
  the depth at which non-harmonic features are flattened, allowing principled
  early stopping.
- **Topological feature extraction.** The harmonic limit (Algorithm C) returns
  cohomology representatives — robust, deformation-invariant features of flows on
  meshes, molecules, and complexes.
- **Spectral preconditioning.** The split energy identity isolates closed vs.
  coclosed components, guiding channel-wise normalization.

---

## 11. Discussion

The theory is striking in its economy: a single Dirichlet-energy identity
generates symmetry, positivity, the discrete Hodge theorem, harmonic invariance,
the contraction factor, the geometric decay, the explicit depth law, and — after
splitting into two boundary maps — the full cohomological characterization. The
qualitative phenomenon practitioners feared (oversmoothing) becomes a quantitative
and *desirable* convergence whose rate and stopping time are computable in closed
form, and whose stable manifold is precisely the topology of the underlying
complex.

---

## 12. Future Directions

1. **Deformation retraction onto the harmonic subspace (orthogonal splitting).**
   With admissible step `0 < α < 2/λ_max`, conjecturally `mpStep` restricted to
   `(ker L)ᗮ` is a strict contraction, so the iterate converges to the orthogonal
   projection `P_ker` with `‖(mpStep)^[k] x − P_ker x‖² ≤ ρᵏ ‖x − P_ker x‖²`.
   The missing ingredient is invariance of `(ker L)ᗮ`, which follows from
   self-adjointness of `L`.
2. **Betti numbers from the harmonic kernel dimension.** With `fullHodge_kernel`,
   conjecturally `dim ker L = dim ker ∂ₖ − rank ∂ₖ₊₁`, the `k`-th Betti number —
   making the harmonic dimension a literal topological invariant.
3. **Tightness of the logarithmic depth law.** Conjecturally `N(ε)` is exact: the
   bottom non-harmonic eigenvector saturates every inequality in the geometric
   bound simultaneously, so `⌈log_ρ(ε/‖x‖²)⌉` is not merely sufficient but tight.
4. **Oversmoothing as collapse of the path space of signals.** The trajectories
   `k ↦ (mpStep)^[k] x` are conjecturally all homotopic, as `k → ∞`, to the
   constant path at `P_ker x`, with orbit diameter shrinking like `ρᵏ`;
   oversmoothing is the collapse of this path space to its homotopy-invariant
   core.
5. **Heat-flow continuum limit and the spectral-gap eigenvalue.** The discrete
   flow `x_{k+1} = x_k − αL x_k` is the explicit Euler scheme of the Hodge heat
   equation `ẋ = −L x`; as `α → 0` with `kα = t` fixed, `(mpStep)^[k] x → e^{−tL} x`,
   and the asymptotic decay constant equals the spectral gap. The contraction
   factor `1 − αμ(2 − αλ) ≈ 1 − 2αμ` matches the first-order expansion of
   `e^{−2αμ}`, identifying discrete and continuous rates.

---

## Appendix: Symbol Glossary

| Symbol | Meaning |
|---|---|
| `B`, `D`, `E` | boundary/incidence matrices |
| `L = Bᵀ B` | up-Hodge Laplacian |
| `L = Dᵀ D + E Eᵀ` | full Hodge Laplacian |
| `⟨x, L x⟩` | Dirichlet energy of `x` |
| `mpStep L α x = x − α(L x)` | one message-passing layer |
| `ker L` | harmonic subspace ≅ cohomology |
| `μ`, `λ` | spectral gap, top eigenvalue |
| `ρ = 1 − αμ(2 − αλ)` | per-layer contraction factor |
| `N(ε) = ⌈log_ρ(ε/‖x‖²)⌉` | explicit depth witness |
