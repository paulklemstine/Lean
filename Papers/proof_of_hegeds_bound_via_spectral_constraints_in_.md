# Computational Evidence — constant-pattern Gram spectrum & Fisher bound

All claims below were subsequently turned into machine-checked Lean theorems
(`SpectralBound.lean`, `EquiangularFisher.lean`, `FalsifiabilityWitness.lean`).
This note records the small-case exploration that guided the formalisation.

## 1. Eigenvalues of the constant-pattern matrix `G = (k−λ)I + λJ` (size `m`)

`G` has two eigenvalues:
* `k − λ`, with multiplicity `m − 1` (eigenvectors orthogonal to the all-ones
  vector `𝟙`);
* `k + (m−1)λ`, with multiplicity `1` (eigenvector `𝟙`).

Positive definiteness ⇔ both are `> 0`. With `λ ≥ 0`:
`k − λ > 0` (i.e. `λ < k`) already forces `k + (m−1)λ ≥ k − λ > 0`.
So the single algebraic constraint is **`0 ≤ λ < k`** — matching
`constPattern_posDef`.

Small cases (`k = 3`):

| m | λ | eigenvalues of G            | PosDef? |
|---|---|-----------------------------|---------|
| 2 | 0 | 3 (×1), 3 (×1)              | yes     |
| 2 | 1 | 2 (×1), 4 (×1)              | yes     |
| 3 | 2 | 1 (×2), 7 (×1)             | yes     |
| 3 | 3 | 0 (×2), 9 (×1)             | NO (singular) |
| 4 | 3 | 0 (×3), 12 (×1)           | NO (singular) |

The `λ = k = 3` rows are exactly the degenerate regime captured by
`degenerate_gram_not_posDef` (zero eigenvalue ⇒ not PosDef).

## 2. Fisher bound check (`incidence_inner` dictionary)

Ground set `[4]`, `k`-uniform families with constant pairwise intersection `λ`:

* Singletons `{0},{1},{2},{3}`: `k=1, λ=0`, `m=4=n`. Bound `m ≤ n` tight. ✓
  (formalised as `singletonFamily_fisher`).
* Pairs through a fixed point `{0,1},{0,2},{0,3}`: `k=2, λ=1<k`, `m=3 ≤ 4`. ✓
* All of `[4]` repeated, `k=λ=4`: hypothesis `λ<k` fails; one may list
  `m=5 > 4` copies. ✗ for the conclusion — matches
  `fisher_lam_lt_k_necessary`.

## 3. Counterexample hunt

The only way to violate `m ≤ n` under "`k`-uniform, constant pairwise
intersection" is to drop `λ < k`. Every sampled family with `0 ≤ λ < k`
satisfied `m ≤ n`; the boundary `λ = k` (identical sets) is the sole source of
counterexamples, in agreement with the spectral analysis (loss of positive
definiteness).

## 4. OEIS

No new integer sequence is introduced; the objects are eigenvalue/cardinality
inequalities rather than counting sequences, so an OEIS lookup is not applicable.
