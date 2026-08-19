# Computational evidence for the parity-gap conjecture

All numbers below were produced with Lean's evaluator (`#eval`) on a computable replica of the
counter

```
coeffs m n S T r  =  ∑_{σ ∈ S_n}  sgn σ · [ ∑_j S(σ j) · T j = r ]      (r ∈ ZMod m)
```

which is the computable shadow of `PrimeUncertainty.permCoeff`.  They are *exploratory*
computations, not formal verifications; the formal statements live in
`Catalog/Probability/ParityGap/` and are proved there with no `sorry`.

## 1. Small-case values of the counter

| modulus `m` | `n` | `S` | `T` | `(permCoeff r)_{r=0..m-1}` |
|---|---|---|---|---|
| 5 | 3 | `(1,2,3)` | `(1,2,4)` | `[-1, -2, 2, 1, 0]` |
| 5 | 3 | `(0,1,2)` | `(0,1,2)` | `[1, -1, 2, 0, -2]` |
| 7 | 4 | `(0,1,2,3)` | `(0,1,2,3)` | `[5, -2, -2, -2, 5, -2, -2]` |
| 7 | 4 | `(0,1,3,5)` | `(2,3,4,6)` | `[1, 1, 1, 1, -6, 1, 1]` |
| 5 | 4 | `(0,1,2,3)` | `(0,1,2,3)` | `[-5, 5, 5, -5, 0]` |
| 5 | 5 | `(0,1,2,3,4)` | `(0,1,2,3,4)` | `[0, -25, 25, 25, -25]` |
| 7 | 5 | `(0,1,2,3,4)` | `(0,1,2,3,4)` | `[-14, 0, 7, 7, 0, -14, 14]` |
| 7 | 6 | `(0,…,5)` | `(0,…,5)` | `[49, 49, -49, 49, -49, -49, 0]` |
| 11 | 4 | `(0,1,3,5)` | `(2,3,4,6)` | `[-2, 2, 0, -3, 1, 1, 0, 4, 0, 0, -3]` |

In every row the counter is non-constant, i.e. some residue really is hit by unequally many
even and odd permutations — the content of Conjecture A.  (Only the *differences* of the
`permCoeff r` are intrinsic: `∑_{r} ζ^r = 0`, so adding a constant to all coordinates does not
change the determinant `∑_r permCoeff r · ζ^r`.)

## 2. Exhaustive counterexample hunt over prime moduli

For a modulus `m` and size `n` let

```
minMax(m, n) = min over all injective pairs (S, T) of  max_r |permCoeff S T r|.
```

Conjecture A says `minMax(p, n) ≥ 1` for every prime `p`.  Exhaustive enumeration
(`60 × 60` pairs for `p = 5, n = 3`, etc.) gives:

| `(m, n)` | `(2,2)` | `(3,2)` | `(3,3)` | `(5,2)` | `(5,3)` | `(5,4)` | `(7,3)` |
|---|---|---|---|---|---|---|---|
| `minMax` | 1 | 1 | 3 | 1 | 2 | 5 | 1 |

No counterexample was found for a prime modulus at any size tested.

The minimal *number of residues carrying a nonzero counter*, again over all injective pairs:

| `(m, n)` | `(3,3)` | `(5,2)` | `(5,3)` | `(7,3)` |
|---|---|---|---|---|
| `min #{r : permCoeff r ≠ 0}` | 2 | 2 | 4 | 4 |

which is consistent with the proved bound `ParityGap.two_le_card_support_permCoeff` (`≥ 2`) and
suggests it is sharp only in the smallest cases.

## 3. Composite moduli: the gap really does close

For composite `m` the same exhaustive search finds injective pairs whose counter vanishes
identically:

| `(m, n)` | `(4,2)` | `(6,2)` | `(8,2)` | `(9,2)` | `(6,3)` |
|---|---|---|---|---|---|
| `minMax` | 0 | 0 | 0 | 0 | 0 |

The witness at `m = 4` is `S = T = (0, 2)`: every product `S i · T j` vanishes in `ZMod 4`, so
all `2! = 2` permutations share the exponent `0` and their signs cancel.  This example is
formalised as `ParityGap.parity_gap_closes_mod_four`, so primality is *provably* essential.

## 4. A `π`-adic pattern (the reason a naive mod-`p` proof cannot work)

Write `π = ζ - 1`, so that `p` is an associate of `π^{p-1}` in `ℤ[ζ_p]`.  Reading the table of
§1 modulo `p` (and remembering that constants are invisible, §1) one finds that
`det = ∑_r permCoeff r · ζ^r` is divisible by:

| `(p, n)` | `n(n-1)/2` | observed | predicted by `v_π(det) = n(n-1)/2` |
|---|---|---|---|
| `(5,3)` | 3 | `det` not divisible by `5` | `3 < 4 = p-1` ✓ |
| `(7,4)` | 6 | counter constant mod `7`, so `7 ∣ det`, `49 ∤ det` | `6 ∈ [6, 12)` ✓ |
| `(5,4)` | 6 | `5 ∥ det` | `6 ∈ [4, 8)` ✓ |
| `(5,5)` | 10 | `25 ∥ det` | `10 ∈ [8, 12)` ✓ |
| `(7,5)` | 10 | `7 ∥ det` | `10 ∈ [6, 12)` ✓ |
| `(7,6)` | 15 | `49 ∥ det` | `15 ∈ [12, 18)` ✓ |

Every data point is compatible with the exact valuation `v_π(det) = n(n-1)/2`.  In particular
for `n(n-1)/2 ≥ p-1` the whole counter becomes constant modulo `p`, which is precisely why the
theorem cannot be proved by reducing the determinant mod `p`: the proof in
`Catalog/Probability/ParityGap/Chebotarev.lean` therefore works in characteristic zero inside
`ℤ[ζ_p]` and only reduces a rescaled kernel vector.  See `FUTURE_DIRECTIONS.md`, Conjecture 1.

## 5. OEIS

No new integer sequence is being introduced here; the counters above are minors of DFT matrices
and the relevant "sequence" (`max_r |permCoeff|` over all injective pairs) depends on two
parameters `(p, n)` and was not matched against OEIS.

## 6. How wide a closed gap can be over a composite modulus

For composite `m` let

```
w(m) = max { n : ∃ injective S, T : Fin n → ZMod m with permCoeff S T ≡ 0 }.
```

Two reductions make an exhaustive search feasible.  First, translating `S` (or `T`) by a constant
translates the counter, so one may assume `0 ∈ S` and `0 ∈ T`; permuting the entries of `S` only
multiplies the counter by a global sign, so only the *sets* of values matter.  Second,
`permCoeff S T ≡ 0` holds if and only if the group-ring element `∑_σ sgn(σ) x^{E_σ}` vanishes in
`ℤ[x]/(x^m − 1)`, which happens exactly when the numerical determinants
`det ( z^{S_i T_j} )` vanish for all `m`-th roots of unity `z`.

Searching all value sets in decreasing size gives

| `m` | 4 | 6 | 8 | 9 | 10 | 12 | 14 | 15 |
|---|---|---|---|---|---|---|---|---|
| `w(m)` | 2 | 4 | 6 | 7 | 8 | 10 | 12 | 13 |
| `m − 2` | 2 | 4 | 6 | 7 | 8 | 10 | 12 | 13 |

e.g. for `m = 8` the maximal witness found is `S = (0,1,2,3,4,6)`, `T = (0,1,2,4,5,6)`, and for
`m = 15` it is `S = (0,1,2,3,4,5,6,7,8,9,10,12,13)`, `T = (0,1,2,3,4,5,6,7,8,10,11,12,13)`.
These witnesses are *not* of the annihilating-progression shape `S ⊂ (a)`, `T ⊂ (b)` proved in
`ParityGap.parity_gap_closes_of_factorisation`, which only reaches `n = min(a,b)`; the extra
cancellation is genuinely sign-theoretic.  This is the evidence behind Conjecture 3 of
`FUTURE_DIRECTIONS.md`.

*Caveat: this section reports floating-point machine exploration, not a machine-checked
computation.  The only statements verified in Lean are the two directions of*
`ParityGap.parity_gap_closes_iff_not_prime` *and the lower bound*
`ParityGap.parity_gap_closes_of_factorisation`.

## 7.  Exact group-ring evidence for the wide constructions (`Width.lean`)

The parity-weighted counter of a pair `(S, T)` vanishes identically exactly when the determinant
of the matrix `M_{jk} = g^{S_j T_k}` over the group ring `ℤ[ℤ/m]` (`g` a generator) is zero, since
the group elements form a `ℤ`-basis.  That determinant is an *exact integer* computation: expand
it by the standard subset dynamic program (`O(n·2ⁿ)` monomial products), which never leaves `ℤ`.
The table below records this computation for the digit-swapped family

```
S j = a·(j mod b) + ⌊j/b⌋,     T k = b·(k mod a) + ⌊k/a⌋,     m = a·b
```

now proved to close the gap for all `2 ≤ n ≤ m − a` (`ParityGap.parity_gap_closes_wide`).

| `(a,b)` | `m` | widths `n` where the counter vanishes | proved range `n ≤ m − a` | `m − 2` |
|---|---|---|---|---|
| `(2,3)` | 6 | 2 – 4 | 2 – 4 | 4 |
| `(3,3)` | 9 | 2 – 7 | 2 – 6 | 7 |
| `(2,5)` | 10 | 2 – 8 | 2 – 8 | 8 |
| `(4,3)` | 12 | 2 – 10 | 2 – 8 | 10 |
| `(3,4)` | 12 | 2 – 10 | 2 – 9 | 10 |
| `(2,7)` | 14 | 2 – 12 | 2 – 12 | 12 |
| `(3,5)` | 15 | 2 – 13 | 2 – 12 | 13 |
| `(5,3)` | 15 | 2 – 13 | 2 – 10 | 13 |

Two observations.  First, the computation agrees with the theorem in every case.  Second, in every
case tested the digit-swapped family in fact closes the gap for **all** `2 ≤ n ≤ m − 2`, i.e. right
up to the proved obstruction — even when the proved range `n ≤ m − a` stops earlier (`(5,3)`:
`10` versus `13`).  This suggests the sharper Conjecture 3 in `FUTURE_DIRECTIONS.md`: the *same*
explicit family already realises the maximal width `m − 2` for every composite `m`.  In the same
run, `n = m − 1` and `n = m` never close — consistent with the now-proved obstructions
`ParityGap.parity_gap_open_at_width_pred` and `ParityGap.parity_gap_open_at_full_width`.

*Caveat: the table above is exact integer machine exploration, not a machine-checked computation.
The statements verified in Lean are `ParityGap.parity_gap_closes_wide`,
`ParityGap.parity_gap_closes_of_even`, `ParityGap.parity_gap_closes_of_not_prime_wide`,
`ParityGap.parity_gap_open_at_width_pred`, `ParityGap.parity_gap_open_at_full_width` and
`ParityGap.gapCloses_iff_of_even`.*
