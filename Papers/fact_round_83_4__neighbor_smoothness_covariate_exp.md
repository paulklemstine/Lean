# Computational evidence

Evidence gathered before and while formalising the four new files in
`Catalog/MachineLearning/QRResidual/`.  Everything below is a check of a *hypothesis* of a
theorem or of the *numeric constants* used in the exp-585 instances; the theorems
themselves are proved in Lean and do not rest on these computations.

## 1. The permutation-null calibration identity

Claim (now `QRResidual.perm_null_sum_sq_dot`): for centred `r, v` on `n` points,

```
Σ_{σ ∈ S_n} ⟨r, v∘σ⟩²  =  n! · ‖r‖²‖v‖² / (n − 1).
```

**Exact rational check in Lean** (`#eval` over `ℚ`, summing over the full symmetric group):

| n | Σ over all σ of ⟨r, v∘σ⟩² | n!·‖r‖²‖v‖²/(n−1) | match |
|---|---|---|---|
| 3 | `1092` | `1092` | exact |
| 4 | `3264` | `3264` | exact |

with `r₃ = (2,−3,1)`, `v₃ = (−1,4,−3)`, `r₄ = (1,2,−5,2)`, `v₄ = (3,−1,−1,−1)` (all centred).

**Counterexample hunt — is centring load-bearing?**  Replacing `v₄` by the *non-centred*
`w₄ = (3,−1,−1,0)` gives

```
Σ_σ ⟨r₄, w₄∘σ⟩² = 2924   vs   4!·‖r₄‖²‖w₄‖²/3 = 2992,
```

so the identity genuinely fails without the centring hypothesis: `hv : Σ vᵢ = 0` is not
decoration.

**Monte-Carlo cross-check** (20 000 random shuffles per size, seed 20260827):

| n | MC mean of ⟨r, v∘σ⟩² | exact `‖r‖²‖v‖²/(n−1)` |
|---|---|---|
| 10 | 6.2493 | 6.2560 |
| 20 | 16.2260 | 16.2615 |
| 50 | 35.8660 | 35.1971 |

## 2. Tightness and slack of the block ceiling

For an orthonormal block (`λ = 1`) the increment is *exactly* `Σⱼ⟨r,vⱼ⟩²/TSS`
(`rss_block_ge` is attained), so the only slack in
`ΔR² ≤ k ρ² (1 − R²₀)/λ` comes from replacing each `⟨r,vⱼ⟩²` by the maximum `ρ²‖r‖²`.
A random 200×4 orthonormal design gives

```
exact ΔR² = 0.07404 ,  correlation ceiling k ρ² (1 − R²₀) = 0.13319   (ρ = 0.1339)
```

i.e. the certificate is loose by roughly the ratio (mean correlation²)/(max correlation²),
as expected; it is a bound, not an estimate.

## 3. The exp-585 constants

```
ceiling at ρ = 0.16   :  4 · 0.16²  · (1 − 0.4112) = 0.060293
ceiling at ρ = 0.1457 :  4 · 0.1457² · (1 − 0.4112) = 0.049997  < 0.05
observed increment                                   = 0.01946
pre-registered null boundary                         = 0.02
Markov bound on the null at n = 237                  : 0.5888/(236·0.05) = 0.0499
reported empirical null q95                          = 0.046
```

Both ceiling computations are re-checked inside Lean by `norm_num` in the `LabNotes`
section of `NeighborNull.lean`, and the reported `q95 = 0.046` lies inside the
unconditional Markov bound proved in `PermutationNull.lean`.

**Adversarial note.**  At the *observed* best single correlation `ρ = 0.16` the ceiling is
`0.0603`, which is **above** the pre-registered alternative `ΔR² ≥ 0.05`.  So the
correlation profile alone does not refute `H1`; the null verdict relies on the joint fit
and the permutation test.  This boundary is recorded as the theorem
`exp585_exclusion_threshold` rather than hidden.

## 4. Neighbour covariates

`nbOmega N s = ω(N + s)` was checked at small arguments (Lean, kernel-checked in the
`LabNotes` section): `ω(29) = 1`, `ω(31) = 1`, `ω(35) = 2`.  The arithmetic-freedom
construction (`dial_neighborhood_free`) prescribes `N ≡ N₀ (mod P)` together with
`M₁ ∣ N − 1`, `M₂ ∣ N + 1` for products of arbitrarily many large primes, so the covariate
is unbounded on every dial level set; no computation is needed beyond the proof.
