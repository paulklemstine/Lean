# Future Directions: NTK Spectral Convergence

This cycle's artifact: `Catalog/MachineLearning/NTKSpectral.lean`, building directly on
`Catalog/MachineLearning/NTKCore.lean`.

## Synthesis

The geometric convergence theorem in `NTKCore` (`gdResidual_geometric_decay`) hides all
of its content inside an opaque contractivity constant `c < 1` (`IsContractive`). The
question driving this cycle was: *can that black box be opened spectrally, and how much
of the standard NTK convergence-rate story is actually elementary once you look along a
single eigenvector?* The answer turned out to be: almost all of it. The gradient-descent
update operator `I - ηK` is **diagonal in any eigenbasis of `K`** — along an eigenvector
`v` with eigenvalue `λ` it acts as the pure scalar `1 - ηλ`. Consequently the residual
obeys an *exact* (not merely bounded) geometric law `‖u_t‖ = |1 - ηλ|^t ‖v‖`
(`gdResidual_eigenvector_norm`), and mode stability collapses to the scalar window
`0 < ηλ < 2` (`eigenvalue_stable_iff`). This reduces the entire per-mode rate analysis to
real-scalar facts, which is why the whole file is short and axiom-clean.

The genuinely non-trivial result is the **optimal learning-rate** triple. At
`η* = 2/(μ+L)` both extreme modes of a spectrum `[μ, L]` contract by exactly the
inverse-condition-number factor `(L-μ)/(L+μ)` (`optimalRate_contraction`), this factor is
`< 1` precisely because `μ > 0` (`optimalRate_lt_one`), and — the optimality direction —
*no* step size beats it on the worse of the two modes (`optimalRate_minimizes`). The
minimization proof hinges on a small but decisive trick: the η-free linear combination
`L(1-ημ) - μ(1-ηL) = L - μ`, after which the triangle inequality forces
`(L+μ)·max ≥ L|1-ημ| + μ|1-ηL| ≥ L-μ`. Finally the PSD structure already proved in
`NTKCore` (`ntkGramMatrix_posSemidef`) was bridged to Mathlib's Hermitian eigenvalue API
(`ntkGram_eigenvalues_nonneg`), so the eigenvalues feeding the stability window are
provably nonnegative, and the capstone (`ntk_eigen_convergence`) assembles the exact decay
law plus the `< 1` rate for a genuine NTK mode.

What we deliberately did **not** attempt: the full operator-norm identity
`‖I - ηK‖ = max_i |1 - ηλ_i|`. That requires expanding an *arbitrary* vector in the
eigenbasis of `K` and is heavy in Mathlib's spectral-theorem API. The structural insight
of this cycle is that every bit of the *dynamics* lives along eigenvectors, so capturing
the mathematics exactly per-mode is both cheaper and more informative than a coarse
operator-norm bound — and it is exactly the per-mode picture that the next directions need.

## Results Summary

- `gdUpdateOp_mulVec_eigenvector`: proved — the GD update operator `I - ηK` acts as the scalar `1 - ηλ` on eigenvectors (diagonalization in the eigenbasis).
- `gdResidual_eigenvector`: proved — the residual along an eigenvector is exactly `(1 - ηλ)^t v`.
- `gdResidual_eigenvector_norm`: proved — exact geometric norm law `‖u_t‖ = |1 - ηλ|^t ‖v‖` (sharpens `gdResidual_geometric_decay` from `≤` to `=` per mode).
- `gdResidual_eigenvector_decay`: proved — any per-mode rate bound `|1-ηλ| ≤ c` upgrades to `‖u_t‖ ≤ c^t ‖v‖`.
- `eigenvalue_stable_iff`: proved — a mode is strictly contractive iff `0 < ηλ < 2`, the classical stability window.
- `optimalRate_contraction`: proved — at `η* = 2/(μ+L)` both extreme modes contract by exactly `(L-μ)/(L+μ)`.
- `optimalRate_lt_one`: proved — that optimal factor is `< 1` exactly because `μ > 0`.
- `optimalRate_minimizes`: proved — optimality: no step size beats `(L-μ)/(L+μ)` on the worse extreme mode.
- `ntkGram_eigenvalues_nonneg`: proved — NTK Gram eigenvalues are `≥ 0`, bridging `ntkGramMatrix_posSemidef` to Mathlib's `Matrix.PosSemidef.eigenvalues_nonneg`.
- `ntk_eigen_convergence`: proved — capstone: for a genuine NTK eigenmode with `λ > 0` and `η` in range, exact geometric decay with an explicit `< 1` rate.

## Research Directions

### Direction 1: Operator-norm = spectral-radius for the symmetric update operator
**Hypothesis**: For symmetric `K` with eigenvalues `λ_i`, the Euclidean operator norm
satisfies `‖(I - ηK).mulVec v‖ ≤ (max_i |1 - ηλ_i|) · ‖v‖` for *all* `v`, hence `K`
is `IsContractive` with `c = max_i |1 - ηλ_i|`.
**Test**: Use Mathlib's spectral theorem (`Matrix.IsHermitian.spectral_theorem` /
eigenbasis) to expand an arbitrary `v` in eigenvector coordinates, apply the per-mode
identity `gdUpdateOp_mulVec_eigenvector` coordinatewise, and bound by the max. Confirm by
discharging `IsContractive K η (max_i |1 - ηλ_i|)`.
**Why now**: This cycle proved the per-mode action *exactly*; the only missing step is the
orthonormal-eigenbasis expansion, which is precisely what `Matrix.IsHermitian` provides.
**If true**: It eliminates the opaque `c` from `NTKCore` entirely — every convergence
statement becomes spectrally explicit, and `gdResidual_geometric_decay` becomes a
corollary with a computable rate.
**If false**: The failure would localize to non-normal or coordinate effects, telling us
the Euclidean norm on `Fin n → ℝ` interacts with `mulVec` differently than expected.

### Direction 2: Strict positive-definiteness from independent feature gradients
**Hypothesis**: `ntkGramMatrix Φ` is positive *definite* (all eigenvalues `> 0`, so a
spectral gap `μ > 0`) **iff** the feature rows `{Φ i · : Fin n → (Fin p → ℝ)}` are linearly
independent (which forces `n ≤ p`, the overparameterization condition).
**Test**: Prove `(ntkGramMatrix Φ).PosDef ↔ LinearIndependent ℝ Φ` via
`ntkGramMatrix = Φ Φᵀ` (already in `NTKCore` as `ntkGramMatrix_eq_mul_transpose`) and the
kernel of `Φᵀ`; then derive `0 < eigenvalues i` from `PosDef`.
**Why now**: `ntkGram_eigenvalues_nonneg` gives `≥ 0`; upgrading the inequality to strict
is the single remaining gap before the `μ > 0` hypothesis of `optimalRate_*` becomes a
*theorem about real networks* rather than an assumption.
**If true**: It supplies the `μ > 0` needed to instantiate `ntk_eigen_convergence` and
`optimalRate_lt_one` from a checkable rank condition.
**If false**: A counterexample (a PSD-but-singular Gram with independent rows) would expose
a subtlety in the Gram/rank correspondence over `ℝ`.

### Direction 3: Whole-vector convergence rate from the spectral gap
**Hypothesis**: If `K` is symmetric with all eigenvalues in `[μ, L]`, `0 < μ ≤ L`, and
`η = 2/(μ+L)`, then for *every* initial residual `u₀`,
`‖gdResidual K η u₀ t‖ ≤ ((L-μ)/(L+μ))^t · ‖u₀‖`.
**Test**: Combine Direction 1 (operator-norm bound) with `optimalRate_contraction` /
`optimalRate_lt_one`, then iterate exactly as `gdResidual_geometric_decay` does.
**Why now**: The two ingredients — the optimal scalar rate (proved this cycle) and the
operator-norm reduction (Direction 1) — compose mechanically; only their conjunction is
missing.
**If true**: This is the textbook NTK convergence theorem with a *fully explicit*,
condition-number-driven rate, formalized end to end.
**If false**: It would mean the worst-case rate is not attained simultaneously across all
initial conditions, indicating a gap between per-mode and global behavior.

### Direction 4: Multi-output / block NTK via product index types
**Hypothesis**: Re-deriving the entire file with the index type `Fin n` replaced by a
general `Fintype ι` (e.g. `ι = Fin n × Fin k` for `k`-class outputs) leaves every theorem
true verbatim, because none of the proofs use the linear order or cardinality of `Fin n`.
**Test**: Generalize `ntkGramMatrix`, `gdUpdateOp`, `gdResidual`, and the spectral lemmas
to `[Fintype ι] [DecidableEq ι]` and re-run the proofs; the block Gram structure is still
`Φ Φᵀ`, so `ntkGramMatrix_posSemidef` and `ntkGram_eigenvalues_nonneg` should transfer.
**Why now**: The proofs in this cycle are already index-agnostic (they manipulate
`mulVec`, `smul`, and scalars, never indices), making this a robustness stress-test of the
architecture rather than new mathematics.
**If true**: A single parameterized development covers scalar and vector-valued networks,
the natural setting for classification.
**If false**: The point of failure pinpoints exactly which lemma secretly depended on the
`Fin n` structure — valuable to know before larger generalizations.

### Direction 5: Loss decay rate and local strong convexity
**Hypothesis**: With `K = ntkGramMatrix Φ` positive definite (gap `μ > 0`) and the squared
loss `L(u) = ½‖u‖²` on the residual, gradient descent satisfies
`L(u_t) ≤ (1 - ημ)^{2t} L(u₀)`, i.e. linear convergence of the *loss*, not just the
residual.
**Test**: Square the residual bound from Direction 3 (or the per-mode law
`gdResidual_eigenvector_norm`) and identify `1 - ημ` as the slowest-decaying mode; relate
`L(u_t)` to `‖u_t‖²` directly.
**Why now**: `gdResidual_eigenvector_norm` already gives the *exact* squared norm per mode;
the loss is just a sum of these, so the loss-rate statement is a short corollary once the
spectral gap (Direction 2) is in hand.
**If true**: It connects the NTK picture to the strong-convexity / PL-inequality view of
optimization, opening a bridge to the convex-optimization corner of the catalog.
**If false**: A discrepancy between residual-rate and loss-rate would reveal a cross-term
the simple squaring argument misses.
