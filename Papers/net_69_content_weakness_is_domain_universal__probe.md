# Computational evidence — NET-69 selection theory (round 22)

All numerical claims below were computed before formalisation and are now
*also* proved in Lean (file/theorem given in the last column).  Nothing in this
note is load-bearing on its own: it records how the instances were found.

## 1. The measured NET-69 grid

| arm | retained @ B = 64 |
|---|---|
| accumulated-HH | 0.9340 |
| probe-only | 0.8149 |
| hybrid λ = 1 | 0.9371 |

probe `R²` on code: mean 0.3185 (min 0.1225, max 0.5921); prose mean 0.329.

Derived quantities used in the formal statements:

| quantity | value | where |
|---|---|---|
| arm gap `0.9340 − 0.8149` | `0.1191` | hypothesis of `net69_dispersion_lower_bound` |
| `1 − R²` (code) | `0.6815` | ditto |
| dispersion floor `gap² / (4·B·(1−R²))` | `8.1305·10⁻⁵` | conclusion (stated as `> 8·10⁻⁵`) |
| bound ratio `√(0.6815/0.671)` | `1.0077938` | `bound_ratio_code_prose_lt_one_percent` (stated as `< 1.008`) |

The dispersion floor is the transfer bound `gap ≤ 2√(B(1−R²)SS_tot)` read
backwards.  It is the only place where the three measured numbers are combined
into a statement about the key population.

## 2. Counterexample hunt — does accuracy order retention?

Exhaustive search over budget-2 selections of four keys
(`a = (10, 9, 1, 0)`; a selection `S` is admissible for a score `s` iff no key
in `S` is scored below a key outside it).

| score | SSE vs `a` | admissible budget-2 sets | retained |
|---|---|---|---|
| `h = (1, 2, 3, 4)` | **150** | `{2,3}` (unique) | **1** |
| `p = (40, 30, 20, 10)` | **1802** | `{0,1}` (unique) | **19** |

A twelve-fold better `L²` fit retains nineteen times less mass.  Both selections
are *unique*, so the comparison cannot be blamed on tie-breaking.
→ `accuracy_does_not_order_retention`, `accuracy_inversion_is_strict`.

## 3. Counterexample hunt — can a mixture beat both parents?

Same importances `a = (10, 9, 1, 0)`.

| score | admissible budget-2 sets | retained |
|---|---|---|
| accumulated `h = (6, 2, 4, 0)` | `{0,2}` (unique) | 11 |
| probe `p = (2, 7, 2, 5)` | `{1,3}` (unique) | 9 |
| hybrid `h + p = (8, 9, 6, 5)` | `{0,1}` (unique) | **19** |

The two parents misrank *different* pairs, and the sum repairs both.
→ `hybrid_strictly_beats_both_arms`, `hybrid_gain_is_strict`.

## 4. The λ-stability interval of instance 3

Crossing weights of the accumulated selection `{0,2}`, i.e. the values of `λ`
at which a discarded key overtakes a retained one, are
`(h i − h j)/(p j − p i)`:

| pair `(i ∈ S, j ∉ S)` | crossing λ |
|---|---|
| `(0, 1)` | 0.8 |
| `(0, 3)` | 2.0 |
| `(2, 1)` | **0.4** |
| `(2, 3)` | 1.333… |

so the selection is stable exactly on `λ ≤ 2/5` and the useful weight `λ = 1`
is outside it.  The half-line structure of each constraint is what makes the
stable set an interval.
→ `hybrid_stability_threshold_example`, `hybrid_stability_ordConnected`.

## 5. Sharpness of the transfer constant

`a = (1, 1, −1, −1)`, flat score `s ≡ 0`, `ε = 1`, `B = 2`: every budget-2 set
is admissible for `s`, so the evictor may return `{2,3}` with retained mass
`−2`, against the oracle's `+2`.  The loss is `4 = 2Bε` exactly.
→ `sup_transfer_bound_is_sharp`.

## 6. OEIS

No integer sequence arises in this round: all objects are inequalities between
real-valued retention functionals, and the only integers involved are the
budget `B` and the knee.  No OEIS search was applicable.
