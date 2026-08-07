# Computational Evidence

Small-scale computations run inside Lean (`#eval`) that motivated and sanity-checked the
theorems added in this cycle.  These are *evidence*, not proofs; every statement listed under
"formal counterpart" is proved without `sorry` in the corresponding `Catalog/Shared` file.

## 1. Counting geodesics of one non-split torus

For a torus with fundamental unit `ε` the geodesics of norm `≤ x` correspond to the integers
`k ≥ 1` with `ε^{2k} ≤ x`.  With the (integral) test value `ε = 3` and `m = 3` (a cyclic
covering of degree 3) we computed, for `x = 10^j`:

| `x`      | `K = #{k ≥ 1 : 9^k ≤ x}` | `k ≡ 0 (3)` | `k ≡ 1 (3)` | `k ≡ 2 (3)` |
|----------|--------------------------|-------------|-------------|-------------|
| 10       | 1                        | 0           | 1           | 0           |
| 10²      | 2                        | 0           | 1           | 1           |
| 10³      | 3                        | 1           | 1           | 1           |
| 10⁴      | 4                        | 1           | 2           | 1           |
| 10⁵      | 5                        | 1           | 2           | 2           |
| 10⁶      | 6                        | 2           | 2           | 2           |
| 10⁷      | 7                        | 2           | 3           | 2           |
| 10⁸      | 8                        | 2           | 3           | 3           |

The discrepancies `K - 3·#{k ≡ 1 (3)}` are `-2, -1, 0, -2, -1, 0, -2, -1`: **bounded**, and
periodic with period 3.  This is exactly the `O(1)` behaviour — error exponent `0` — and rules
out any negative exponent, since the discrepancy does not tend to `0`.

*Formal counterparts*: `hasErrorExponent_torusClassCount` (error `≤ 4`, exponent `0`),
`abs_card_residue_sub_le`, `not_hasErrorExponent_torusCount_of_neg`,
`optimalExponent_torusCount = 0`, `tendsto_torusClassCount_ratio` (ratio `→ 1/m`).

The bound proved formally (`≤ 3` for the residue count, `≤ 4` overall) is deliberately not
optimal; the data suggest the truth is `≤ 1`, but only boundedness matters for the exponent.

## 2. Worked example verified inside Lean

For `ε = 2`, `x = 100`: the admissible `k` are `1, 2, 3` (`4, 16, 64 ≤ 100 < 256`), so
`torusCount 2 100 = 3`, splitting as `1` even and `2` odd for `m = 2`.
This is *proved*, not just computed: `torusCount_two_100` and `torusClassCount_two_100`.

## 3. Pushforward of Chebotarev densities: `S₃ ↠ {±1}`

`#(Equiv.Perm (Fin 3)) = 6`, the conjugacy classes have sizes `1` (identity), `3`
(transpositions), `2` (3-cycles), and `#{g : sign g = 1} = 3` (computed in Lean).  The classes
above the trivial class of the sign quotient are the identity and the 3-cycles, with densities
`1/6 + 2/6 = 1/2 = 3/6`, matching the density of the trivial class downstairs; the
transpositions give `3/6 = 1/2` for the non-trivial class.

*Formal counterpart*: `sum_classDensity_fiber` (for an arbitrary surjective `f : G →* H`),
`card_filter_preimage_mul_card`, and the analytic transfer `chebotarev_pushforward`.

## 4. Effective threshold

For `θ = 25/36`, `β = 1`, the exponent gap is `11/36`, so the explicit threshold produced by
`effective_lower_bound_25_36` is `(2C/c)^{72/11}`.  Numerically, with `C = c` this is
`2^{72/11} ≈ 94.4`; with `C = 10c` it is `20^{72/11} ≈ 3.0 · 10^8` — the expected extreme
sensitivity of Linnik-type thresholds to the implied constant.

## 5. No OEIS sequence

The integer sequences appearing here (`⌊log x / (2 log ε)⌋` and its residue splittings) are
floor sequences depending on a real parameter, not fixed integer sequences, so no OEIS lookup
is meaningful.

## 6. Evidence for this cycle's new theorems

### 6a. Jump spacing of the `δ`-sparse counter (`δ = 1/2`, i.e. error exponent `θ = 1/2`)

`sparseCount (1/2) x = ⌊√x⌋²` jumps exactly at the squares, so the gaps are exact integers:

| jump point `n²` | 1 | 4 | 9 | 16 | 25 | 36 | 49 |
|---|---|---|---|---|---|---|---|
| gap to next jump `2n+1` | 3 | 5 | 7 | 9 | 11 | 13 | 15 |
| `√(n²) = n` | 1 | 2 | 3 | 4 | 5 | 6 | 7 |

The gaps are `2√x + 1`, i.e. of order `x^{θ}` with `θ = 1/2`, and the error `x - ⌊√x⌋²` is of
the same order — so a window `[x, x + x^{γ}]` placed at a jump point is empty as soon as
`x^{γ} < 2√x`, which happens for all large `x` precisely when `γ < 1/2`.  This is the extremal
behaviour that pins the critical window exponent.

*Formal counterparts*: `sparseCount_abs_sub_le` (error `≤ (1/δ)2^{1/δ-1}x^{1-δ}`),
`sparseCount_no_short_window`, `sparseCount_critical_window_exponent`,
`eventually_lt_of_additive_window`.

### 6b. The effective threshold is attained, not merely sufficient

Take `c = C = 1`, `θ = 0`, `β = 1`.  The extremal counting function of
`ChebotarevGeodesicThresholdSharp.lean` is `π x = x − √x`, and

`π x ≥ (c/2)x = x/2  ⟺  x/2 ≥ √x  ⟺  x ≥ 4`,

while the general threshold formula gives `(2C/c)^{2/(β−θ)} = 2² = 4`.  The two agree exactly:
the threshold is crossed at `x = 4` and fails at every smaller `x`.

*Formal counterparts*: `criticalCount_lt_half_of_lt_threshold`, `criticalCount_at_threshold`,
`effective_threshold_sharp` (and `effective_lower_bound` for the sufficiency direction).

### 6c. Character tables

`Fintype.card (AddChar (ZMod 3) ℂ) = 3`, so the character table of `ZMod 3` is a genuine `3 × 3`
complex matrix; its left inverse `(a, ψ) ↦ ψ(−a)/3` is the discrete Fourier inversion formula.

*Formal counterpart*: `charMatrix_left_inverse`, `chebotarev_abelian_character_reduction`.
