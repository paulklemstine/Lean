# Computational evidence

All numbers below were produced by `#eval` inside the project
(`Catalog/Physics/GradedTransitivityLabNotes.lean`, which compiles as part of the
`Physics` library); the outputs are reproduced verbatim from the build log.  The three
sampled entries of each difference table are additionally *proved* in that file
(`D3_descSeq3`, `D4_descSeq3`, `D3_binom3`), so the tabulated pattern is machine checked
on the sampled range and proved in general by the theorems in
`Catalog/Physics/GradedTransitivityCore.lean`.

Notation: `Δ` is the forward difference `(Δa)ₙ = aₙ₊₁ − aₙ`; the coefficient formula
proved in the core file is `[q^{n+s}] ((1−q)^s · ∑ₖ aₖ qᵏ) = (Δ^s a)ₙ`, so "denominator
divides `(1−q)^s`" is *equivalent* to "`Δ^s a` eventually vanishes".

## 1. Trivial action on `Yₙ = Fin n` (no symmetry at all)

Here `t r Yₙ = n^{\underline r}`.  For `r = 3`, `n = 0 … 9`:

| sequence | values |
|---|---|
| `t₃(Yₙ) = n(n−1)(n−2)` | 0, 0, 0, 6, 24, 60, 120, 210, 336, 504 |
| `Δ t₃` | 0, 0, 6, 18, 36, 60, 90, 126, 168, 216 |
| `Δ² t₃` | 0, 6, 12, 18, 24, 30, 36, 42, 48, 54 |
| `Δ³ t₃` | 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 |
| `Δ⁴ t₃` | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 |

`Δ³ ≡ 3! = 6 ≠ 0` and `Δ⁴ ≡ 0`: the denominator is **exactly** `(1−q)^4 = (1−q)^{r+1}`
and no smaller power works.  Formalized as `not_denom_trivFin_pow_le` and `denom_trivFin`.

## 2. Free rotation action of `ZMod n` on `Fin n`

The action is free, so `t r Yₙ = n^{\underline r}/n`:

| sequence | values (`n = 0 … 9`) |
|---|---|
| `t₁` | 0, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| `t₂` | 0, 0, 1, 2, 3, 4, 5, 6, 7, 8 |
| `t₃` | 0, 0, 0, 2, 6, 12, 20, 30, 42, 56 |

This family is eventually `1`-transitive (so `∑ₙ t₁ qⁿ = q/(1−q)`, denominator `(1−q)`),
but never eventually `2`-transitive — a concrete separation between the hypotheses.  The
same numbers are realized by a *fixed* group in the formalization: `Yₙ = ZMod (n+1)` with
`ℤ` acting by translation, where `t₂(Yₙ) = n` is proved (`transCount_two_cycGrade`) and
the denominator is shown to be exactly `(1−q)^2` (`denom_cycGrade_two`,
`denom_cycGrade_two_not_one`).
The general "never eventually `r`-transitive" phenomenon for actions with polynomially
growing counts is formalized (for the trivial action) as
`not_eventually_transitive_trivFin`.

## 3. The extremal binomial model `C(n+r, r)`

For `r = 3` (the tetrahedral numbers, OEIS A000292; identification from standard
references, no online lookup was performed):

| sequence | values |
|---|---|
| `C(n+3,3)` | 1, 4, 10, 20, 35, 56, 84, 120, 165, 220 |
| `Δ³` | 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 |
| `Δ⁴` | 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 |

`Δ³` is the all-ones sequence, i.e. `(1−q)^3 ∑ C(n+3,3) qⁿ = 1/(1−q)`, which is **not**
polynomial, while `(1−q)^4 ∑ C(n+3,3) qⁿ = 1`.  Formalized as `gf_binom_denom` and
`gf_binom_not_poly_of_pow_le`.

## 4. A synthetic eventually `2`-transitive family

`t₂ = 0, 0, 2, 1, 1, 1, 1, 1` gives `Δ t₂ = 0, 2, −1, 0, 0, 0, 0, 0`: a single power of
`1 − q` clears the denominator, with numerator degree `≤ N + r`
(`numerator_of_eventually_transitive`).

## 5. Counterexample hunt

We tested the universal claim "*eventual `r`-transitivity ⇒ denominator divides
`(1−q)^{r+1}`*" against the three families above and found no counterexample; the
regimes where the conclusion is tight (families 1 and 3) are exactly the ones where the
hypothesis *fails*, which is proved in `not_eventually_transitive_trivFin`.  The failed
attempt to lower the exponent below `r + 1` is recorded as a proved impossibility rather
than as numerical evidence.
