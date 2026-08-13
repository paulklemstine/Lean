# Computational evidence — bond dimension of Shor's periodic comb

All numbers below were produced by exact rational Gaussian elimination on the
0/1 amplitude matrices themselves (no floating point), before the Lean proofs
were attempted.  They are exploratory data, *not* verification: the verified
statements are the Lean theorems in `Catalog/Computation/DeQuantization/`.

## 1. The object

For a register of size `n = P·Q`, the (truncated) comb state is

    |comb⟩ = Σ_{x < n, x ≡ x₀ (mod r)} |x⟩ ,

and its Schmidt rank across the cut `x = p·Q + q` is the rank of the `P × Q`
matrix `M[p][q] = 1` iff `p·Q + q ≡ x₀ (mod r)`.  This rank is the minimal MPS /
tensor-train bond dimension at that cut.

## 2. Small-case table (`P = Q = 8`, `x₀ = 0`)

| r | gcd(r,8) | rank | odd part of r |
|---|---------|------|---------------|
| 1 | 1 | 1 | 1 |
| 2 | 2 | 1 | 1 |
| 3 | 1 | 3 | 3 |
| 4 | 4 | 1 | 1 |
| 5 | 1 | 5 | 5 |
| 6 | 2 | 3 | 3 |
| 7 | 1 | 7 | 7 |
| 8 | 8 | 1 | 1 |

The rank tracks the **odd part** of the period, not the period — and certainly
not `log r`.  The same pattern continues at `P = Q = 16`, `x₀ = 3`
(`r = 1..16 ↦ 1,1,3,1,5,3,7,1,9,5,11,3,13,7,15,1`).

## 3. Unbalanced cut (`P = 4`, `Q = 16`, `x₀ = 1`)

`r = 1..12 ↦ rank 1,1,3,1,4,3,4,1,4,4,4,3`, matching `min(P, r/gcd(r,Q))`
exactly: the left block caps the rank at `P = 4`.

## 4. Exhaustive counterexample hunt

* All `P, Q, r ∈ [1,12]`, `x₀ ∈ [0,3]` (6912 matrices): the rank equals the number
  of **distinct nonzero rows** in every single case (0 mismatches).
* All `P, Q, r ∈ [1,16]`, `x₀ ∈ [0,3]` with `r ≤ P`, `r ≤ Q`, `gcd(Q,r) = 1`:
  rank `= r` in every case (0 mismatches).  This is the hypothesis set of
  `combMatrix_rank_eq`.
* All `P, Q, r ∈ [1,12]`, `x₀ ∈ [0,3]` with `r ≤ Q`: rank `= min(P, r/gcd(r,Q))`
  in every case.  This is the hypothesis set of `combMatrix_rank_eq_min`.
* Dropping `r ≤ Q` **does** produce mismatches (empty residue classes on the
  right block), which is why the hypothesis appears in the theorem.

## 5. Complementarity check (QFT input vs output)

For all `P, Q ≤ 29` and all factorisations `n = P·Q = r·m` with `r ≤ Q`, `m ≤ Q`
(1200 configurations): `min(P, r/gcd(r,Q)) · min(P, m/gcd(m,Q)) ≤ P` holds
always, with equality in 832 of the 1200 cases — the bound proved as
`qft_bond_complementarity` is tight, not merely valid.

Example: `n = 12`, cut `P = 3`, `Q = 4`, period `r = 3`, co-period `m = 4`.
Input rank `3`, output rank `1`, product `3 = P`.

## 6. OEIS

The rank sequence for the balanced binary cut, `r ↦ rank`, is the *odd part of
r* sequence: `1, 1, 3, 1, 5, 3, 7, 1, 9, 5, 11, 3, 13, 7, 15, 1, ...`
(OEIS **A000265**, "odd part of n", i.e. `n / 2^(v₂(n))`).  This identification is
what suggested the exact theorem `qubit_comb_rank_eq_oddPart` and, through it,
the general formula `min(P, r/gcd(r,Q))`.

## 7. What the data does *not* show

No configuration was found in which the comb's bond dimension grows like
`log r` or stays bounded while `r` grows with `gcd(r,Q)` fixed.  The
de-quantization hope for order finding is not supported by any small case.
