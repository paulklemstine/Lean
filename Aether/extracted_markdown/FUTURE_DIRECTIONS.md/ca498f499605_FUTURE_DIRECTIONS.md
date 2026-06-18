# Future Directions: Tropical Spectral Theory

## Synthesis

This cycle closed the simplest non-trivial case of tropical spectral theory in fully
machine-checked Lean 4. Building directly on the tropical Collatz–Wielandt development
in `Tropical/CollatzWielandt.lean` (`tropSpec` = maximum cycle mean, `cycleWt`,
`cycleSucc`), we proved the closed-form **max-plus 2×2 eigenvalue formula**

> `tropSpec W = max (max W₀₀ W₁₁) ((W₀₁ + W₁₀) / 2)`

in `Tropical/Eigenvalue2x2.lean` (`tropSpec_2x2`). The proof is organized so that the
*lower bound* is genuinely dimension-free: the helper theorems `diag_le_tropSpec` and
`twoCycle_le_tropSpec` hold for arbitrary `n×n` matrices, asserting that **every**
diagonal entry and **every** symmetric 2-cycle mean `(Wᵢⱼ + Wⱼᵢ)/2` is a lower bound
for the tropical spectral radius. The 2×2 result is precisely the regime where these
two families of lower bounds become exhaustive, pinning the value exactly.

## Results Summary

- `cycleWt_one`, `cycleWt_two` — closed forms for length-1 and length-2 cycle weights
  (general `n`), the computational core.
- `diag_le_tropSpec` — `Wᵢᵢ ≤ tropSpec W` for all `i` (general `n`). Reusable.
- `twoCycle_le_tropSpec` — `(Wᵢⱼ + Wⱼᵢ)/2 ≤ tropSpec W` for `n ≥ 2` (general `n`). Reusable.
- `tropSpec_2x2_le` — the matching upper bound for `n = 2`.
- `tropSpec_2x2` — the exact 2×2 eigenvalue formula. `sorry`-free, standard axioms only.

These extend `Tropical/CollatzWielandt.lean` rather than reproving it: the spectral
radius definition and the variational `tropical_collatz_wielandt` theorem are imported
and reused.

## Research Directions

### 1. The n×n maximum-cycle-mean formula via short-cycle exhaustion

Conjecture: for every `n×n` real matrix, `tropSpec W` equals the maximum, over all
**simple** cycles (length 1 to `n`, no repeated vertex), of the cycle mean — and in
fact one never needs cycles longer than `n`. The 2×2 case (`tropSpec_2x2`) is the
base case; the lower-bound lemmas already generalize verbatim.

The key insight is that `diag_le_tropSpec` and `twoCycle_le_tropSpec` are special
cases (k = 1, 2) of a single "`k`-cycle mean ≤ tropSpec" lemma, and that the existing
`walk_shorten` / `bestWalk_n_le_potential` machinery in `CollatzWielandt.lean` already
proves the converse reduction to short cycles — so the missing piece is only the
"simple cycle suffices" pigeonhole, which is local.

Why now? The `Σ`-type sup formulation of `tropSpec` plus the proven `cycleWt_*`
closed forms make the `k`-cycle lower bound a one-line generalization of the lemmas
proved this cycle; the upper bound reuses already-verified walk-shortening lemmas.

### 2. Tropical Cayley–Hamilton / characteristic "polynomial" roots

Conjecture: define the tropical characteristic polynomial `χ(λ) = ⊕_S` over principal
minors (max-plus permanent). Then `tropSpec W` is the largest tropical root of `χ`,
and for 2×2 the roots are exactly `{W₀₀ ⊕ W₁₁, (W₀₁+W₁₀) ⊗ (corner terms)}`, matching
`eig2`.

The key insight is that `eig2 W = max(max W₀₀ W₁₁, (W₀₁+W₁₀)/2)` already exposes the
trace term `max W₀₀ W₁₁` and the "determinant" term `(W₀₁+W₁₀)/2`, so the tropical
analogue of `λ² − tr·λ + det` is literally readable off the proven formula.

Why now? `tropSpec_2x2` gives a verified ground truth to test any candidate
tropical-characteristic-polynomial definition against, before committing to the
general `n` development.

### 3. Stability / Lipschitz continuity of the tropical eigenvalue

Conjecture: `tropSpec` is 1-Lipschitz in the sup-norm on matrix entries:
`|tropSpec W − tropSpec W'| ≤ max_{i,j} |Wᵢⱼ − W'ᵢⱼ|`. For 2×2 this is provable now
directly from `eig2`, since `max` and averaging are 1-Lipschitz.

The key insight is that `tropSpec` is a sup of affine functions of the entries
(each cycle mean is an average of entries with nonnegative weights summing to 1), and
a sup of 1-Lipschitz functions is 1-Lipschitz.

Why now? `tropSpec_2x2` reduces the 2×2 instance to an explicit `max` of averages,
giving an immediate, fully-checkable first theorem, and the affine-sup viewpoint
points the way to the general case via the proven `Σ`-type formula.

### 4. Strict monotonicity and the boundary of the off-diagonal regime

Conjecture (falsifiable corner case): the off-diagonal term `(W₀₁+W₁₀)/2` is the
active value of `tropSpec_2x2` **iff** `(W₀₁+W₁₀)/2 ≥ max W₀₀ W₁₁`; on this boundary
the tropical eigenvector is degenerate (non-unique up to tropical scaling). We should
attempt to *disprove* uniqueness exactly on the tie locus.

The key insight is that `eig2` is a `max` of three affine pieces, so its "active
region" decomposition is a tropical hyperplane arrangement, and ties are precisely
where eigenvector uniqueness can fail.

Why now? With `tropSpec_2x2` proved, the tie conditions are explicit inequalities in
the four entries, making both the positive (uniqueness off the tie) and negative
(degeneracy on the tie) claims directly testable in Lean.

### 5. Min-plus dual and the `min`-convention formula

Conjecture: under the min-plus convention (replace `sup'` by `inf'`, max cycle mean
by min cycle mean) the dual formula `tropEigvalₘᵢₙ W = min(W₀₀, W₁₁, (W₀₁+W₁₀)/2)`
holds, and `tropEigvalₘᵢₙ W = − tropSpec(−W)`.

The key insight is that negation `W ↦ −W` is an order-reversing semiring isomorphism
between max-plus and min-plus, so the entire proof of `tropSpec_2x2` transfers by a
single sign flip rather than a re-derivation.

Why now? The original research prompt states the formula in the `min` convention; the
negation bridge lets us deliver it as a corollary of the already-verified `max`
version with minimal new proof burden.
