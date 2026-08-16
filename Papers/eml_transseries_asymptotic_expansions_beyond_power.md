# Computational Evidence — EML Transseries

All formal claims below are proved in `Catalog/Applications/EML/Transseries*.lean`.
This file records the *pre-formal* exploration that guided the definitions; the numbers
here come from floating-point scratch computation and are **not** machine-verified.
Where a numeric observation was later turned into a theorem, the theorem name is given.

## 1. The growth scale is genuinely lexicographic (small-case calculations)

The mission asks for series in `x, log x, exp x, exp exp x`. The rank group chosen is
`Rank = ℝ ×ₗ (ℝ ×ₗ (ℝ ×ₗ ℝ))`, a rank `(d,a,b,c)` standing for
`exp(d·exp x)·exp(a·x)·x^b·(log x)^c`. For this to be the right ordering, no finite power
of one scale may reach the next. Sampling `x = e^k`:

| `k` | `log(log x^5 / x)` = `5 log k − k` | `x^10 − exp x` |
|-----|-----------------------------------:|---------------:|
| 10  | `+1.513`                           | `−2.19e4`      |
| 20  | `−5.021`                           | `−4.85e8`      |
| 50  | `−30.440`                          | `−5.18e21`     |
| 100 | `−76.974`                          | `−2.69e43`     |
| 200 | `−173.508`                         | `−7.23e86`     |
| 400 | `−370.043`                         | `−5.22e173`    |

The crossover for `(log x)^5` vs `x` occurs near `k ≈ 12.7` (i.e. `x ≈ e^{12.7}`) and then
never reverses; `x^10` is already hopeless against `exp x` at `k = 10`. The *uniform* form
of this observation — for **every** exponent `n`, not just the sampled ones — is what the
lexicographic rank encodes, and it is proved in

* `EMLTS.Llog_pow_lt_Lx`, `EMLTS.Lx_pow_lt_Lexp`, `EMLTS.Lexp_pow_lt_Lexpexp`,
* and in the general comparison `EMLTS.T_lt_T_iff`.

The numeric table is what convinced us that a **lexicographic** (rather than, say, a
single real "growth exponent") ordering is forced: no single real invariant can separate
`x^n` from `exp x` for all `n` simultaneously while remaining a group homomorphism.

## 2. Counterexample hunt for the asymptotic comparison theorem

The claim under test: *a transseries dominated by every transmonomial is zero.*

Candidate counterexamples we tried, and what happened:

| candidate | is it in `TS`? | dominated by all transmonomials? | verdict |
|---|---|---|---|
| `exp(−x)` | yes, rank `(0,1,0,0)` | no — it dominates `exp(−2x)` | not a counterexample |
| `exp(−exp x)` | yes, rank `(1,0,0,0)` | no — it dominates `exp(−2 exp x)` | not a counterexample |
| `1/(x log x)` | yes, rank `(0,0,1,1)` | no | not a counterexample |
| `exp(−exp(exp x))` | **no** — outside the 4-level scale | would be | shows the theorem is scale-relative |
| infinite sum `Σ_{n≥1} x^{−n}` | yes (support well-ordered) | no — its order is `x^{−1}`, so it dominates `x^{−2}` | not a counterexample |

The last row was the informative one: an infinite Hahn series still has a well-ordered
support, hence an `order`, hence a dominant transmonomial. This is exactly the mechanism
of the proof (`EMLTS.mono_lt_of_order_lt`, `EMLTS.exists_mono_lt_of_pos`), and the
fourth row marks the honest boundary: the comparison theorem is a statement *relative to a
fixed transmonomial scale*, and any strictly larger scale (log-exp depth `> 2`) produces
elements flat with respect to the smaller one. This boundary is recorded as Conjecture C1
in `FUTURE_DIRECTIONS.md`.

## 3. Root extraction: which `n`-th roots exist?

Testing the shape of the binomial expansion `(1+ε)^{1/n} = Σ binom(1/n, k) ε^k` on the
smallest cases (`ε = 1/x`, `n = 2`):

```
sqrt(1 + 1/x) ≈ 1 + 1/(2x) − 1/(8x²) + 1/(16x³) − 5/(128 x⁴) + ...
```

coefficients `1, 1/2, −1/8, 1/16, −5/128, 7/256, …`, i.e. `binom(1/2,k)`. (We did not run
an OEIS lookup: the sequence is the classical binomial series and no identification was
needed.) This confirmed that the
needed input is exactly Mathlib's `PowerSeries.binomialSeries` together with divisibility
of the rank group, and led to `EMLTS.oneUnit_exists_pow` and
`EMLTS.exists_pow_eq_of_pos`.

Sanity checks that shaped the *statements*:

* `n = 2`, `f = −1`: no root — hence the square-root theorem must be conditional on
  `0 ≤ f` (`EMLTS.isSquare_iff_nonneg`, `EMLTS.no_sqrt_neg_one`).
* `n = 3`, `f = −1`: root `−1` exists — hence odd roots are unconditional
  (`EMLTS.exists_pow_eq_of_odd`).
* `n = 2`, `f = x`: root exists, of rank `(0,0,−1/2,0)` — this is where divisibility of
  the rank group is used (`EMLTS.exists_rank_nsmul`).

## 4. Quadratics: discriminant test

Sampling monic quadratics `z² + b z + c` with `b, c` transmonomials:

| `b` | `c` | `b² − 4c` | root? |
|---|---|---|---|
| `x` | `1` | `x² − 4 > 0` | yes |
| `1` | `x` | `1 − 4x < 0` | no |
| `0` | `−exp x` | `4 exp x > 0` | yes, `±exp(x/2)` |
| `0` | `1` | `−4 < 0` | no |

Every sample matched "root ⇔ discriminant `≥ 0`", which is the statement proved as
`EMLTS.quadratic_solvable_iff`.

## 5. What the computations did *not* settle

No amount of sampling gave evidence either way about **odd-degree** polynomials of degree
`≥ 3` over `TS` (e.g. `z³ − z − 1/x`): the Newton-polygon iteration converges only after
transfinitely many steps in general, so finite numeric truncation is uninformative. We
therefore did **not** claim full real closedness; see `FUTURE_DIRECTIONS.md`, Conjecture
C2, for the precise open statement.
