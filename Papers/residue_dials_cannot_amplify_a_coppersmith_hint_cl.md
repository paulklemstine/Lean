# Computational evidence — DIAL-THRESHOLD (#380)

All numbers below were produced by `#eval` in Lean 4 / Mathlib (same toolchain as
the formal files), using `jacobiSym` for the Kronecker dial readings `(D | p)`.
They motivated the theorems in
`Catalog/Combinatorics/DialThresholdNoAmplification.lean`,
`Catalog/Combinatorics/DialThresholdSharpness.lean` and
`Catalog/Combinatorics/DialThresholdConductorThreshold.lean`; every claim they
suggest is *proved* there, so nothing here is load-bearing on its own.

## 1. Regime 1 — hint `m = 168`, dials `D = -3, 21, 42` (conductors `12, 84, 168`)

Primes in the hint class `p ≡ 1 (mod 168)` and their dial vectors
`((-3|p), (21|p), (42|p))`:

| p | (-3\|p) | (21\|p) | (42\|p) |
|---|---|---|---|
| 337 | 1 | 1 | 1 |
| 673 | 1 | 1 | 1 |
| 1009 | 1 | 1 | 1 |
| 2017 | 1 | 1 | 1 |
| 2521 | 1 | 1 | 1 |
| 2689 | 1 | 1 | 1 |
| 2857 | 1 | 1 | 1 |
| 3361 | 1 | 1 | 1 |
| 3529 | 1 | 1 | 1 |
| 3697 | 1 | 1 | 1 |

A different hint residue gives a different *constant*: for `p ≡ 5 (mod 168)`
(primes `5, 173, 509, 677, 1013, 1181, 2357, 2693, 2861, 3533`) every dial vector
is `(-1, 1, -1)`.

Number of **distinct** dial vectors over all odd residues `< 40000` in the class
`1 mod 168`: **1** (the single vector `[1,1,1]`).  This is `zero pinning`:
formalized as `DialThreshold.regime1_zero_pinning` / `dial_cut_trivial`.

## 2. Regime 2 — hint `m = 135`, dial `D = -4` (conductor `16`, `16 ∤ 135`)

Primes `p ≡ 1 (mod 135)` with `p mod 4` and `(-4|p)`:

| p | p mod 4 | (-4\|p) |
|---|---|---|
| 271 | 3 | -1 |
| 541 | 1 | 1 |
| 811 | 3 | -1 |
| 1621 | 1 | 1 |
| 2161 | 1 | 1 |
| 2971 | 3 | -1 |
| 3511 | 3 | -1 |
| 4051 | 3 | -1 |
| 4591 | 3 | -1 |
| 4861 | 1 | 1 |
| 6211 | 3 | -1 |
| 6481 | 1 | 1 |

Both readings occur inside one hint class, so the hint `p mod 135` cannot
determine the dial: 2 distinct vectors over the whole class.  The pair
`(541, 811)` is the witness used in `DialThreshold.regime2_separating`, and the
general phenomenon (any odd `m`) is `DialThreshold.chi4_not_hintComputable`.

## 3. The master bound `M*/gcd(M*, m)` versus the true count

`distinctRes M m r` = number of distinct residues mod `M` visited by the hint
class `r mod m` (computed over one full period `lcm(M, m)`):

| M* | m | distinct residues mod M* in the class | budget `M*/gcd(M*,m)` |
|---|---|---|---|
| 12 | 168 | 1 | 1 |
| 84 | 168 | 1 | 1 |
| 168 | 168 | 1 | 1 |
| 16 | 135 | 16 | 16 |
| 12 | 135 | 4 | 4 |
| 24 | 135 | 8 | 8 |
| 168 | 135 | 56 | 56 |
| 60 | 168 | 5 | 5 |
| 40 | 135 | 8 | 8 |

Equality in every case — this is exactly `DialThreshold.card_image_resDial_eq`
(sharpness), and the general `≤` is `DialThreshold.card_image_dialVec_le`.

## 4. Counterexample hunt

* *Can a larger dial family beat the hint?*  Eight Kronecker dials
  `D = -3, 21, 42, -4, 8, -8, 5, -7` (conductors `12, 84, 168, 16, 32, 32, 20, 28`,
  `M* = 3360`) on the class `1 mod 168`: only **3** distinct dial vectors occur
  among all odd residues `< 40000`.  The residue budget is `3360/168 = 20`, the
  sign capacity is `3^8`; the realized count `3` respects both.  No family tested
  came anywhere near separating the `≈ N^{1/4}` candidates a Coppersmith class
  contains.
* *Is the master bound ever violated?*  No violation was found in the sweep of
  §3 — as it must be, the bound is proved.
* *Could a dial with `M* ∣ m` be non-constant on a class?*  Searched over all the
  §1 data: never.  Proved impossible (`dialVec_const_of_dvd`).

## 5. OEIS

No new integer sequence arises: the quantities that appear are the classical
`M/gcd(M,m)` (index of an arithmetic progression inside another) and `3^K`.
Nothing was submitted to or matched against OEIS beyond these.
