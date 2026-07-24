# Computational Evidence — Finite Prime Holograms

All new results live in `Catalog/Tropical/HolographicPrimes.lean` and build on the
existing (already complete) development in that file. The claims are exact finite
identities/inequalities, so the evidence below is a sanity check of the algebra
rather than a search for asymptotics.

## 1. The holographic factorization identity

Claim (`finite_holographic_factorization`, pre-existing):
`∏_i ∑_{n≤N} exp(-β·n·E_i) = ∑_{a : I→Fin(N+1)} exp(-β·∑_i a_i·E_i)`.

Small-case check, `I = {2,3}` (two modes), `E = (log 2, log 3)`, `N = 1`, `β = 1`:

- Boundary: `(exp0 + exp(-log2))·(exp0 + exp(-log3)) = (1 + 1/2)·(1 + 1/3) = 2`.
- Bulk: profiles `(0,0),(1,0),(0,1),(1,1)` give
  `1 + 1/2 + 1/3 + 1/6 = 2`. ✓ Equal.

With `N = 2`, same modes, `β = 1`:
- Boundary: `(1 + 1/2 + 1/4)·(1 + 1/3 + 1/9) = (7/4)·(13/9) = 91/36`.
- Bulk (9 profiles): sum of `2^{-a}·3^{-b}` for `a,b ∈ {0,1,2}` = `(7/4)(13/9) = 91/36`. ✓

This is exactly distributivity of a product of sums over the product index set
(`Finset.sum_prod_piFinset`), which is what the Lean proof uses.

## 2. Vacuum lower bound `1 ≤ Z`

Claim (`bulkPartition_ge_one`): the vacuum profile `a ≡ 0` contributes weight
`exp(-β·0) = 1`, and every other profile contributes a strictly positive weight,
so `Z ≥ 1` for every `E`, `N`, `β`.

Check (`I={2}`, `E=log2`, `N=2`, `β=1`): `Z = 1 + 1/2 + 1/4 = 7/4 ≥ 1`. ✓
Check (`β = -1`, same): `Z = 1 + 2 + 4 = 7 ≥ 1`. ✓ (holds for negative β too).

## 3. Sharp ground-state bound `exp(-β·E_ground) ≤ Z`

Claim (`bulkPartition_ge_exp_neg_ground`): with `E_ground = ⨅_σ H(σ)` the
tropical (zero-temperature) partition function, the single Boltzmann term at the
minimizer is `exp(-β·E_ground)`, which is `≤ Z` (a sum of nonnegative terms).

For nonnegative energies (e.g. prime energies `log p ≥ 0`), the minimizer is the
vacuum and `E_ground = 0`, so the bound specializes to `1 ≤ Z`
(`prime_bulkPartition_ge_one`), consistent with §2.

## 4. Cutoff / temperature limits

- `bulkPartition_zero_cutoff`: at `N = 0` the only profile is the vacuum, `Z = 1`.
  Check: `I={2,3}`, `N=0` ⇒ one profile `(0,0)` ⇒ `Z = 1`. ✓
- `bulkPartition_beta_zero`: at `β = 0` every weight is `1`, so
  `Z = #{profiles} = (N+1)^{|I|}`.
  Check: `I={2,3}`, `N=1`, `β=0` ⇒ `Z = 4 = 2^2`. ✓

No counterexamples were found; every finite instance tested matches the theorems
exactly (differences are `0`, not merely small).
