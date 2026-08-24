# Computational evidence for the NET-79 Pythagorean knee round

All numbers below were computed in exact rational arithmetic (Python `fractions`) and
then **re-verified inside Lean**: every value quoted as a knee appears as a theorem in
`Catalog/Pythagorean/` proved by an exact pass/fail bracket over the rationals
(`norm_num`, no floating point, no `native_decide`).

## 1. Setup

For a geometric attention profile `w i = r ^ i` the retained mass of a top-`k`
truncation of a context of length `n` is exactly

```
retained(r, n, k) = (1 - r^min(k,n)) / (1 - r^n)
```

(`PythKnee.retained_geomProfile_eq`), and the knee `k*(r, n, τ)` is the least `k`
clearing the gate `τ`.  Throughout, `τ = 0.985` is the NET-79 gate and `n = 64`.

## 2. Knees of Pythagorean leg ratios (gate 0.985)

| triple | short ratio a/c | k*(short) | long ratio b/c | k*(long) | gap |
|---|---|---|---|---|---|
| (3,4,5)        | 0.60000 | 9  | 0.80000 | 19 | 10 |
| (20,21,29)     | 0.68966 | 12 | 0.72414 | 14 | 2 |
| (119,120,169)  | 0.70414 | 12 | 0.71006 | 13 | 1 |
| (696,697,985)  | 0.70660 | 13 | 0.70761 | 13 | 0 |

Stability check across contexts (`n = 24, 32, 64`): the short-leg knees are
`9/9/9`, `12/12/12`, `12/12/12`, `13/13/13`; the long-leg knees are `18/19/19`,
`13/14/14`, `13/13/13`, `13/13/13`.  Only the two smallest cases move between
`n = 24` and `n = 32`, which is why `n = 64` was chosen for the formal statements.

Formalised as: `knee_three_five`, `knee_four_five`, `knee_twenty_twentynine`,
`knee_twentyone_twentynine`, `knee_119_169`, `knee_120_169`,
`pell_short_leg_knee_eq_thirteen`, `knee_697_985`.

## 3. Counterexample hunt for the universal short-leg bound

Claim tested: *every* Pythagorean triple with `a ≤ b` has short-leg knee `≤ 13` at gate
`0.985`, at every context.

* Structural reason: `a ≤ b` and `a² + b² = c²` give `(a/c)² ≤ 1/2`, hence
  `(a/c)^13 ≤ (1/2)^6 · 0.708 ≈ 0.01106 ≤ 0.015 = 1 - τ`.
* Search: all primitive triples with `c ≤ 5000` were scanned; the largest short-leg
  ratio found is `0.7065990` at `(696, 697, 985)`, below `1/√2 = 0.7071068`.  No
  counterexample.
* Sharpness: `12` is *not* enough — `(696/985)^12 = 0.0154909 > 0.015`, and at context
  `64` the retained mass at `k = 12` is `0.9847454 < 0.985`.  So the constant `13` is
  attained, and the near-isosceles branch is exactly where it is attained.

Formalised as `pyth_short_leg_budget_le_thirteen` and
`pyth_universal_budget_thirteen_sharp`.

## 4. Long legs have no bound

For the near-square family `(2m+1, 2m(m+1), 2m(m+1)+1)` the long ratio is
`t/(t+1)` with `t = 2m(m+1)`:

| m | triple | long ratio | k* at n = 2·10³ |
|---|---|---|---|
| 1 | (3,4,5)      | 0.80000 | 19 |
| 3 | (7,24,25)    | 0.96000 | 103 |
| 10 | (21,220,221)| 0.99548 | 925 |
| 30 | (61,1860,1861) | 0.99946 | 1947 (context-limited) |

The knee grows without bound; formalised (with a Bernoulli-type estimate rather than
these samples) as `pyth_long_leg_budget_unbounded`.

## 5. Inversion of profile orderings across context

Witness profiles for the abstract inversion (gate `0.9`):

| n | `w_A i = (1/2)^i` | `w_B i = (1/16)^i + 1/1000` |
|---|---|---|
| 2 | k* = 2 | k* = 1 |
| 5000 | k* ≤ 4 | k* ≥ 5 |

At `n = 2` the retained mass of `w_B` at `k = 1` is `1.001/1.0635 = 0.9403 ≥ 0.9`,
while `w_A` retains only `2/3`.  At `n = 5000` the band bound gives
`k*(w_B) ≥ 0.9·5000·0.001/1.001 = 4.4955`, hence `≥ 5`.  Formalised as
`knee_ordering_inversion_realizable`; the crossover-context bound
`(K+1)M/(τc) = 5·1.001/0.0009 = 5561.1…` is `crossover_bound_profGap_profFloor`.

## 6. Sequence lookups

The Pell branch legs `3, 20, 119, 696, 4059, …` and hypotenuses `5, 29, 169, 985, …`
are the classical near-isosceles Pythagorean numbers (NSW numbers / Pell-related
sequences); they satisfy `c² = 2a² + 2a + 1`, verified for the first 20 terms
numerically and proved for all `k` in `pell_invariant`.  No new sequence is claimed.

## 7. What the evidence does **not** show

The coincidence that the universal Pythagorean budget at gate `0.985` is `13`, and that
the *generic* (non-geometric) tail certificate gives `16` at the same gate, is a
property of the gate value.  Nothing here derives a measured language-model knee from
arithmetic, and no theorem in this round assumes the NET-79 measurements; the measured
table enters only as the definition of the four-point sequences `net79Small` and
`net79Large`, about which purely combinatorial statements (non-separability, sign
change of the scale gap, crossover index) are proved.
