# Computational Evidence — Anti-Gravity Mathematics

We model a formal library as a finite set of theorems `V` with a dependency
relation `D a b` = "`b` depends on `a`". The **gravitational weight** of `a` is
`depWeight a = #{ b : D a b }` (its number of dependents). A theorem is
**anti-gravity** if `weight ≥ w0` and `plen ≤ l0` (high weight, short proof).

All claims below are *also* proved in `Catalog/Speculative/AntiGravity.lean`;
this file just records the small-case sanity checks that motivated them.

## 1. The linear library `L_n` on `{0,…,n-1}`

Dependency: `i` is used by `j` iff `i < j` (theorem `j` builds on all earlier ones).
This is the extreme "high gravity" case.

| n | weights (theorem 0 … n-1) | total weight | # edges |
|---|---------------------------|--------------|---------|
| 1 | 0                         | 0            | 0       |
| 2 | 1, 0                      | 1            | 1       |
| 3 | 2, 1, 0                   | 3            | 3       |
| 4 | 3, 2, 1, 0                | 6            | 6       |
| 5 | 4, 3, 2, 1, 0             | 10           | 10      |

* Theorem `0` has weight `n-1` (everything depends on it) — matches
  `linear_library_bottom_weight`.
* Total weight `= 0+1+…+(n-1) = n(n-1)/2` equals the number of dependency edges —
  matches the handshake identity `sum_depWeight_eq_sum_inDeg`.
* With `plen ≡ 1`, theorem `0` is anti-gravity at threshold `w0 = n-1` — matches
  `linear_library_antigravity`. This is the theme's "weight `O(n)` but proof
  length `O(1)`" phenomenon made precise (the theme's FTA example claims `O(n^2)`;
  a quadratic weight arises for a bottom theorem shared by an `n × n` grid of
  dependents, which our `linear_library` specializes).

## 2. The empty library (antichain) `A_n`

Dependency: `D a b` is always false (no theorem uses any other).

| n | weights        | total weight | # anti-gravity (w0 ≥ 1) |
|---|----------------|--------------|-------------------------|
| any | all 0        | 0            | 0                       |

So the fraction of anti-gravity theorems is **0%**, for every `n`. This is a
direct counterexample to the mission's *universal* prediction that "10% of
theorems in any library are anti-gravity" — matches `no_deps_no_antigravity`.

## 3. Averaging / pigeonhole sanity check

Take `L_5`, short-proof set `S = {0,1,2}` (say these have `plen ≤ 1`), with
weights `4,3,2`, total `9`. Here `|S| · w0 = 3·3 = 9 ≤ 9`, so the averaging
hypothesis of `exists_antigravity_of_short_heavy` holds with `w0 = 3`, and indeed
theorem `0` (weight `4 ≥ 3`, short) is anti-gravity. Lowering the total below
`|S|·w0` (e.g. weights `2,2,2`, total `6 < 9`) can destroy the guarantee, showing
the hypothesis is tight.

## 4. Counterexample hunt for the strong theme-claims

* "Anti-gravity theorems exist in **every** branch": FALSE as a universal claim —
  `A_n` (§2) is a perfectly good library with none. TRUE once one requires the
  library to actually have dependencies with enough concentrated weight (§3, §1).
* "The set of anti-gravity theorems is **dense**": this needs a topology on
  "the space of all theorems" that the theme does not specify. Under the discrete
  topology it is vacuous; under any reasonable metric it is model-dependent. We do
  not formalize a false version — see `FUTURE_DIRECTIONS.md`.
* "**10%** are anti-gravity": FALSE as a universal law (§2 gives 0%); the true
  statement is a conditional existence result (§3).

**Conclusion.** The robust, provable core of the theme is: (i) a handshake
identity relating total weight to dependency count, (ii) an averaging/pigeonhole
existence theorem for anti-gravity theorems under a weight-concentration
hypothesis, (iii) monotonicity making foundational theorems heaviest, and
(iv) a concrete linear-library witness. The universal quantitative predictions are
refuted. All four are formalized and proved.
