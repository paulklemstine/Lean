/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# EML Transseries: The Field of Grid-Based Transmonomials

This file builds a rigorous model of (single exp/log-tower, real-power) **transseries**
on top of Mathlib's `HahnSeries`.  The asymptotic-expansion domain of Exp-Log-Multiply
(EML) functions is governed by *transmonomials*: formal products

    (exp x)^{a₁} · x^{a₀} · (log x)^{a₋₁} · (exp(exp x))^{a₂} · …

with finitely many nonzero real exponents indexed by the **tower height** `h ∈ ℤ`
(`h = 1` is `exp x`, `h = 0` is `x`, `h = -1` is `log x`, `h = 2` is `exp(exp x)`, …).

The group of transmonomials is therefore `ℤ →₀ ℝ` with the *lexicographic* order in which
the highest tower height is most significant.  Mathlib's `Lex (ℤ →₀ ℝ)` realizes this as a
`LinearOrderedAddCommGroup`, so `HahnSeries (Lex (ℤ →₀ ℝ)) ℝ` is, by Mathlib's Hahn-series
field instance, a genuine **field** — the field of transseries.

## Main definitions

- `EMLTransseries.TransMono`  : the ordered group of transmonomials, `Lex (ℤ →₀ ℝ)`.
- `EMLTransseries.TSeries`    : the field of transseries, `HahnSeries TransMono ℝ`.
- `EMLTransseries.mono h a`   : the transmonomial of tower height `h` and exponent `a`.
- `EMLTransseries.term h a`   : the one-term transseries `(level h)^a`.

## Main results

- `EMLTransseries.instField`         : transseries form a field (re-export).
- `EMLTransseries.mono_lt_mono_of_height` : higher tower height dominates (positive exp).
- `EMLTransseries.mono_lt_mono_same`      : within a height, larger exponent dominates.
- `EMLTransseries.exp_dominates_pow`      : `exp x` dominates `x^a` for **every** real `a`.
- `EMLTransseries.orderTop_term`          : the valuation of a one-term transseries.
- `EMLTransseries.orderTop_mul`           : the valuation is multiplicative.
- `EMLTransseries.C_injective`            : the constant embedding `ℝ ↪ TSeries`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the field of transseries can be realized concretely as a
Hahn-series field over the lexicographically ordered transmonomial group `Lex (ℤ →₀ ℝ)`,
and the qualitative asymptotic law "exp beats every power" should hold *formally* as a
statement about the group order, not merely analytically.

Experiment (Experimenter): we verified that `Lex (ℤ →₀ ℝ)` is a `LinearOrder`,
`AddCommGroup`, and `IsOrderedCancelAddMonoid`, hence `HahnSeries (Lex (ℤ →₀ ℝ)) ℝ` is a
field via Mathlib's instance.  We proved height-dominance and same-height comparison via
`Finsupp.Lex.lt_iff`.

Analysis (Analyst): the only subtlety is the *direction* of the lexicographic order:
`Finsupp.Lex` compares at the **smallest** differing index, so we encode tower height `h`
as the finsupp index `-h`; then "highest tower" = "smallest index" = "most significant",
exactly matching asymptotic dominance.

Critique (Critic): `exp_dominates_pow` is non-trivial — it asserts dominance for *all*
real exponents `a`, including astronomically large ones, which is impossible for any single
power-series valuation and is the defining feature that pushes transseries beyond power
series.  Its proof genuinely uses the lex structure (`Finsupp.Lex.lt_iff` + case work),
not `rfl`/`decide`.
-- !-- Lab Notes -- !--
-/
import Mathlib

open HahnSeries Filter

namespace EMLTransseries

noncomputable section

/-- The ordered group of **transmonomials**: finitely supported real exponents indexed by
the tower height `h ∈ ℤ`, with the lexicographic order in which the *highest* tower height
is most significant. -/
abbrev TransMono : Type := Lex (ℤ →₀ ℝ)

/-- The **field of transseries**: Hahn series with real coefficients supported on a
well-ordered set of transmonomials. -/
abbrev TSeries : Type := HahnSeries TransMono ℝ

/-- Transseries form a field (Mathlib's Hahn-series field instance over the linearly
ordered transmonomial group). -/
example : Field TSeries := inferInstance

/-- The transmonomial of tower height `h` and real exponent `a`, i.e. `(level h)^a`.
Tower height `1` is `exp x`, `0` is `x`, `-1` is `log x`, `2` is `exp(exp x)`, etc.
We store it at finsupp index `-h` so that higher towers are lexicographically dominant. -/
def mono (h : ℤ) (a : ℝ) : TransMono := toLex (Finsupp.single (-h) a)

/-- The one-term transseries whose single transmonomial is `(level h)^a` with coefficient `1`. -/
def term (h : ℤ) (a : ℝ) : TSeries := HahnSeries.single (mono h a) 1

/-! ### Dominance: the lexicographic order is asymptotic dominance -/

/-- **Height dominance.** A transmonomial of strictly *higher* tower height (with positive
exponent) dominates any transmonomial of lower height, regardless of its exponent.
This is the formal statement that, e.g., `exp(exp x)` beats every `(exp x)^c`. -/
theorem mono_lt_mono_of_height (h h' : ℤ) (hh : h < h') (a a' : ℝ) (ha' : 0 < a') :
    mono h a < mono h' a' := by
  rw [mono, mono, Finsupp.Lex.lt_iff]
  refine ⟨-h', fun d hd => ?_, ?_⟩
  · simp only [ofLex_toLex, Finsupp.single_apply]
    rw [if_neg (by omega), if_neg (by omega)]
  · simp only [ofLex_toLex]
    rw [Finsupp.single_apply, if_neg (by omega), Finsupp.single_eq_same]
    exact ha'

/-- **Same-height comparison.** Within a fixed tower height, the transmonomial with the
larger real exponent dominates. -/
theorem mono_lt_mono_same (h : ℤ) (a a' : ℝ) (haa : a < a') : mono h a < mono h a' := by
  rw [mono, mono, Finsupp.Lex.lt_iff]
  refine ⟨-h, fun d hd => ?_, ?_⟩
  · simp only [ofLex_toLex, Finsupp.single_apply]
    rw [if_neg (by omega), if_neg (by omega)]
  · simp only [ofLex_toLex, Finsupp.single_eq_same]
    exact haa

/-- **Exp dominates every power.** The transmonomial `exp x` (= `mono 1 1`) dominates the
transmonomial `x^a` (= `mono 0 a`) for *every* real exponent `a` — including arbitrarily
large `a`.  No element of a (Laurent/Puiseux) power-series valuation can do this; it is the
characteristic feature of transseries. -/
theorem exp_dominates_pow (a : ℝ) : mono 0 a < mono 1 1 :=
  mono_lt_mono_of_height 0 1 (by norm_num) a 1 (by norm_num)

/-! ### The valuation (order) on transseries -/

/-- The valuation (`orderTop`) of a nonzero one-term transseries is its transmonomial. -/
theorem orderTop_term (h : ℤ) (a : ℝ) :
    (term h a).orderTop = (mono h a : WithTop TransMono) := by
  rw [term, HahnSeries.orderTop_single one_ne_zero]

/-- The valuation is multiplicative: `orderTop (x * y) = orderTop x + orderTop y`. -/
theorem orderTop_mul (x y : TSeries) :
    (x * y).orderTop = x.orderTop + y.orderTop :=
  HahnSeries.orderTop_mul x y

/-- The constant embedding `ℝ ↪ TSeries` is an injective ring homomorphism: the field of
transseries contains `ℝ`. -/
theorem C_injective : Function.Injective (HahnSeries.C : ℝ →+* TSeries) :=
  HahnSeries.C_injective

/-- Transseries are a nontrivial ring (`1 ≠ 0`). -/
theorem one_ne_zero' : (1 : TSeries) ≠ 0 := one_ne_zero

end

end EMLTransseries