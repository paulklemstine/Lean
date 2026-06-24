# Computational Evidence — Ordered, Non-Archimedean Transseries

This cycle's new results live in `OrderedField.lean`. Below is the evidence gathered before
formalization. The claims are *order-theoretic*, so the relevant "computations" are
hand-evaluations of leading coefficients and small dominance checks rather than numeric
sequences; we note this explicitly under each heading.

## 1. Small-case dominance checks (transmonomial group `Lex (ℤ →₀ ℝ)`)

Encoding: `mono h a = toLex (Finsupp.single (-h) a)`, tower height `h` (1 = exp x, 0 = x,
-1 = log x, 2 = exp(exp x)). Lexicographic comparison happens at the *least differing* index.

| comparison                         | reduces to (index, values)        | verdict                  |
|------------------------------------|-----------------------------------|--------------------------|
| `mono 0 a  <  mono 1 1` (∀ a)      | index −1: `0 < 1`                 | exp x ≻ x^a, every a     |
| `mono 1 5  <  mono 2 1`            | index −2: `0 < 1`                 | exp(exp x) ≻ (exp x)^5   |
| `mono 0 2  <  mono 0 3`            | index 0: `2 < 3`                  | x^3 ≻ x^2                |
| `mono (-1) 7 < mono 0 1`           | index −1: `7 > 0` → x ≻ (log x)^7 | x ≻ (log x)^7            |

These are exactly the cases proved by `mono_lt_mono_of_height` / `mono_lt_mono_same` in
`Field.lean` and reused in `OrderedField.lean`.

## 2. Order-direction experiment (the decisive finding)

We tested both indexings of the Hahn field and computed the sign of `single g 1 − (n : ·)`
by its leading coefficient (coeff at the least support element):

- Indexing by `TransMono` (naive): the least element of `{mono 1 1, 0}` is `0`
  (since `0 < mono 1 1`), leading coefficient `−n < 0`, so `single (mono 1 1) 1 < n`.
  **`exp x` comes out infinitesimal — wrong.**
- Indexing by `TransMonoᵒᵈ` (dual): the least element of `{toDual (mono 1 1), 0}` is
  `toDual (mono 1 1)`, leading coefficient `+1 > 0`, so `n < single (toDual (mono 1 1)) 1`.
  **`exp x` is infinite — correct.**

This experiment is what fixed the definition `OrderedTSeries := Lex (HahnSeries TransMonoᵒᵈ ℝ)`
and is the formal content of `nat_lt_gen_one`.

## 3. Counterexample hunt

- **`gen_lt_gen_of_height` without `0 < a'`.** Take height jump `0 → 1` but `a' = −1`
  (i.e. compare `x^a` with `(exp x)^{-1}`). At the dominant index the relevant coefficient is
  `−1 < 0`, so the dominance *reverses*: `gen 1 (-1) < gen 0 a` for large `a`. Hence the
  positivity hypothesis `0 < a'` is **load-bearing**, mirroring the same hypothesis flagged in
  `CatalogBridge.lean`. (The theorem as stated is therefore robust; the boundary is exactly
  `a' ≤ 0`.)
- **`nat_lt_gen_one` for `gen 0 1` (= x) instead of `exp x`.** Still true with the dual
  indexing (`x` is also infinite), confirming the claim is not special to `exp`; we kept the
  `exp x` form because it is the canonical witness "beyond power series".
- **`not_archimedean` vacuity check.** `Archimedean` is a nonempty, satisfiable class (ℝ
  satisfies it), so `¬ Archimedean OrderedTSeries` is a substantive negative, not vacuous; the
  proof contradicts `exists_nat_gt` against `nat_lt_gen_one`.

## 4. OEIS

No integer sequence arises; the objects are real-exponent transmonomials and an ordered field,
so an OEIS search is not applicable.

## Why a heavy numeric stage is unnecessary here

The theorems are statements about a *formal* order on a Hahn-series field; their truth is
decided by leading-coefficient sign computations (shown above), not by floating-point sampling.
The little-o facts in `AsymptoticComparison.lean` already pin the analytic side to Mathlib's
`Real.isLittleO_pow_exp_atTop`, so no separate numerical asymptotics experiment is needed.
