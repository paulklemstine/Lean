# Computational Evidence — Kitchen Query Complexity

All numbers below were produced by exact Lean `#eval` computations (interpreted, exact
natural-number arithmetic) using a brute-force optimal decision-tree solver

```
D(f) = 0                                     if f is constant on the current subcube
D(f) = 1 + min_i max( D(f|x_i=0), D(f|x_i=1) )  otherwise
```

on truth tables of length `2^n`.  `D(f)` is exactly the quantity formalised as
`KitchenQuery.tasteCost` (verification time `V(R)`); the cooking time is `C(R) = n`.

## 1. Exhaustive census of all dishes, `n ≤ 3`

Distribution of the verification time `D` over **all** `2^(2^n)` dishes:

| n | #dishes | D=0 | D=1 | D=2 | D=3 | evasive fraction (D = n) |
|---|---------|-----|-----|-----|-----|--------------------------|
| 1 | 4       | 2   | 2   | –   | –   | 2/4  = 50.0 % |
| 2 | 16      | 2   | 4   | 10  | –   | 10/16 = 62.5 % |
| 3 | 256     | 2   | 6   | 54  | 194 | 194/256 = 75.8 % |

Two immediate confirmations of formalised statements:

* `D = 0` occurs exactly twice for every `n` — the two constant dishes
  (`tasteCost_zero_iff_constant`, `card_quickDishes_zero`).
* `#{f : D(f) ≤ 1}` is `4, 6, 8` for `n = 1, 2, 3`, i.e. exactly `2n + 2`, matching the
  classification `quick_dish_classification` and the bound `quick_dishes_card_le`
  (which is therefore *tight*, not merely an upper bound).

## 2. Random sampling at `n = 4, 5` (evasiveness becomes generic)

Random truth tables (deterministic LCG, bit 10 of the state; 200 samples at `n = 4`, 40 at
`n = 5`):

| n | samples | D = n−2 | D = n−1 | D = n | evasive fraction |
|---|---------|---------|---------|-------|------------------|
| 4 | 200     | 2       | 22      | 176   | 88 % |
| 5 | 40      | 0       | 2       | 38    | 95 % |

The evasive fraction `50 %, 62.5 %, 75.8 %, ≈88 %, ≈95 %` increases monotonically in the data
and is the empirical face of the counting theorem `most_dishes_hard`
(`c_d ≤ (6n)^(2^d)` against `2^(2^n)` dishes).

## 3. The three model dishes (n = 3)

| dish | truth table | D (computed) | formal statement |
|------|-------------|--------------|------------------|
| soufflé (parity) | popcount parity | 3 | `tasteCost_souffle = n` |
| `anySpoiled` (OR) | `j ≠ 0` | 3 | `tasteCost_anySpoiled = n` |
| `mux` (`x₀ ? x₁ : x₂`) | `[F,F,F,T,T,F,T,T]` | **2** | `tasteCost_mux = 2` |

`mux` depends on all three ingredients (its truth table changes when each of the three bits
is flipped somewhere), yet is decided by two adaptive probes: this is the computational
witness for the adaptivity gap `adaptivity_gap`.

The soufflé and `anySpoiled` share the same deterministic cost `3`, but differ
nondeterministically: `anySpoiled` has one-probe certificates at every bad pantry
(`anySpoiled_certificate`), while every certificate of the soufflé is the whole pantry
(`souffle_no_certificate_shortcut`).  This is the empirical separation behind
`kitchen_P_ne_NP`.

## 4. Counterexample hunt

The universal claim of the mission statement — *"P = NP recipes have C = V, P ≠ NP recipes
have C ≫ V"* — **fails** on the data above, in a systematic way:

* the salad `x ↦ x i` has `C/V = n/1 = n` (the maximal ratio) although it is the *easiest*
  dish;
* the soufflé has `C/V = n/n = 1` although it is the *hardest* dish.

So `C = V` characterises evasiveness, i.e. maximal hardness, not quickness.  This inversion
is proved in `ratio_eq_one_iff_evasive` and `menu_ratio_one_iff_all_evasive`; no
counterexample to the corrected statements was found in the exhaustive `n ≤ 3` census.

## 5. OEIS

The exhaustive depth distributions `[2,2]`, `[2,4,10]`, `[2,6,54,194]` were compared with the
counts of Boolean functions by decision-tree depth.  The count of "quick" dishes
`4, 6, 8, 10, …` is the trivial arithmetic progression `2n+2`; the full depth distribution
gives the row sums `4, 16, 256 = 2^(2^n)`.  No further OEIS identification was pursued, as
the relevant quantities are proved exactly in the Lean files rather than conjectured from the
sequence.
