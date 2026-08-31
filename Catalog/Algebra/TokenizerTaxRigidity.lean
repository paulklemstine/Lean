/-
# Rigidity of the tokenizer tax: budget tables cannot be separable

`Algebra.TokenizerTaxMultiplicative` established the multiplicative law: in the power-law
recall model the language knob multiplies the key budget by `amp a b lam = lam ^ (b / a)`,
so an additive `+4` fine-step penalty at short context is *amplified* by exactly the
acceleration of the baseline requirement.

The deployment conclusion drawn from NET-88 was that "budget tables must include a
language × context interaction term".  This file proves that as a **rigidity theorem**:

* `language_context_exchange` — the model has an exact scaling symmetry: a fragmenting
  language at context `C` is *the same workload* as the reference language at context
  `lam * C`.  Language and context are one orbit of a single `ℝ>0` action.
* `log_budget_affine` — on a logarithmic scale the budget is affine with the *same*
  slope `b / a` in `log lam` and in `log C`: the interaction is exactly bilinear.
* `no_additive_budget_table` — **rigidity**: if the budget were separable,
  `budget = f C + g lam`, then the amplification factor is forced to be `1`.  Hence
  (`budget_table_needs_interaction`) for any genuinely fragmenting language no additive
  table can exist.  This is not a fitting failure; it is an algebraic impossibility.

The last section adds the *fine-step* layer actually used by the harness: budgets are
spent in a grid of `g` keys, so the reported penalty is `⌈tax / g⌉` steps.

* `steps_quadruple_lower` — a `4×` amplification of the real tax costs at least
  `4 · (fine steps) - 3` steps: rounding cannot hide the explosion.
* `net88_fine_step_jump` — the NET-88 arithmetic: on the grid `g = 4`, a `+4`-key tax is
  one fine step and its amplified `+16`-key form is four.
* `step_tax_unbounded` — no finite fine-step penalty is valid for all contexts.
-/
import Mathlib
import Algebra.TokenizerTaxMultiplicative

namespace Catalog.Algebra.TokenizerTax

open Real

/-! ## The scaling symmetry: language ≡ context -/

/-- **Language–context exchange.**  Reading German at context `C` costs exactly what
reading the reference language at context `lam * C` costs.  The two experimental knobs
are two coordinates on a single one-parameter group of workload dilations. -/
theorem language_context_exchange (A₀ b a τ lam C : ℝ) :
    budget (amplitude A₀ b lam C) a τ = budget (amplitude A₀ b 1 (lam * C)) a τ := by
  unfold amplitude
  rw [one_mul]

/-- **The interaction is exactly bilinear.**  On the log scale the budget is affine in
`log lam` and `log C` with the *same* slope `b / a`; the cross term is not a fitting
artefact but the shape of the model. -/
theorem log_budget_affine {A₀ b a τ lam C : ℝ} (hA : 0 < A₀) (hτ : τ < 1)
    (hlam : 0 < lam) (hC : 0 < C) :
    Real.log (budget (amplitude A₀ b lam C) a τ)
      = a⁻¹ * Real.log (A₀ / (1 - τ)) + (b / a) * Real.log lam + (b / a) * Real.log C := by
  have h1τ : (0:ℝ) < 1 - τ := by linarith
  have hpos : (0:ℝ) < A₀ / (1 - τ) := div_pos hA h1τ
  rw [budget_language hA.le hτ hlam.le hC.le,
    budget_baseline (b := b) hA.le hτ hC.le, amp,
    Real.log_mul (Real.rpow_pos_of_pos hlam _).ne'
      (mul_pos (Real.rpow_pos_of_pos hpos _) (Real.rpow_pos_of_pos hC _)).ne',
    Real.log_mul (Real.rpow_pos_of_pos hpos _).ne' (Real.rpow_pos_of_pos hC _).ne',
    Real.log_rpow hlam, Real.log_rpow hpos, Real.log_rpow hC]
  ring

/-! ## Rigidity: no separable budget table -/

/-- **Rigidity of the budget table.**  Suppose someone proposes a budget table that is
*separable*: a context column `f C` plus a language surcharge `g lam`, with no interaction
term.  Then the amplification factor must be trivial.  Equivalently: an additive
language surcharge is only consistent with the model if there is no surcharge at all. -/
theorem no_additive_budget_table {A₀ b a τ lam : ℝ} (hA : 0 < A₀) (ha : 0 < a) (hb : 0 < b)
    (hτ : τ < 1) (hlam : 0 < lam) (f g : ℝ → ℝ)
    (hsep : ∀ l C : ℝ, 0 < l → 0 < C → budget (amplitude A₀ b l C) a τ = f C + g l) :
    amp a b lam = 1 := by
  have h1τ : (0:ℝ) < 1 - τ := by linarith
  set K : ℝ := (A₀ / (1 - τ)) ^ a⁻¹ with hK
  have hKpos : 0 < K := Real.rpow_pos_of_pos (div_pos hA h1τ) _
  -- a second context at which the baseline is exactly doubled
  set C₂ : ℝ := (2:ℝ) ^ (a / b) with hC₂def
  have hC₂ : 0 < C₂ := Real.rpow_pos_of_pos (by norm_num) _
  have hC₂pow : C₂ ^ (b / a) = 2 := by
    rw [hC₂def, ← Real.rpow_mul (by norm_num)]
    have : a / b * (b / a) = 1 := by field_simp
    rw [this, Real.rpow_one]
  -- baselines at the two contexts
  have base1 : budget (amplitude A₀ b 1 1) a τ = K := by
    rw [budget_baseline (b := b) hA.le hτ (by norm_num), Real.one_rpow, mul_one]
  have base2 : budget (amplitude A₀ b 1 C₂) a τ = 2 * K := by
    rw [budget_baseline (b := b) hA.le hτ hC₂.le, hC₂pow]
    ring
  -- the four table entries
  have e11 := hsep 1 1 one_pos one_pos
  have e12 := hsep 1 C₂ one_pos hC₂
  have el1 := hsep lam 1 hlam one_pos
  have el2 := hsep lam C₂ hlam hC₂
  rw [budget_language hA.le hτ hlam.le (by norm_num), base1] at el1
  rw [budget_language hA.le hτ hlam.le hC₂.le, base2] at el2
  rw [base1] at e11
  rw [base2] at e12
  -- subtracting the reference row: `(amp - 1) * baseline` must be the same constant
  have d1 : (amp a b lam - 1) * K = g lam - g 1 := by
    have : amp a b lam * K - K = g lam - g 1 := by rw [el1, e11]; ring
    linarith [this]
  have d2 : (amp a b lam - 1) * (2 * K) = g lam - g 1 := by
    have : amp a b lam * (2 * K) - 2 * K = g lam - g 1 := by rw [el2, e12]; ring
    linarith [this]
  have : (amp a b lam - 1) * K = 0 := by linarith
  rcases mul_eq_zero.1 this with h | h
  · linarith
  · exact absurd h hKpos.ne'

/-- **Interaction terms are mandatory.**  For a language that really does fragment
(`lam > 1`) and a growing amplitude (`b > 0`), no separable budget table exists. -/
theorem budget_table_needs_interaction {A₀ b a τ lam : ℝ} (hA : 0 < A₀) (ha : 0 < a)
    (hb : 0 < b) (hτ : τ < 1) (hlam : 1 < lam) :
    ¬ ∃ f g : ℝ → ℝ, ∀ l C : ℝ, 0 < l → 0 < C →
        budget (amplitude A₀ b l C) a τ = f C + g l := by
  rintro ⟨f, g, hsep⟩
  have h1 : amp a b lam = 1 :=
    no_additive_budget_table hA ha hb hτ (by linarith) f g hsep
  have h2 : 1 < amp a b lam := one_lt_amp ha hb hlam
  rw [h1] at h2
  exact lt_irrefl 1 h2

/-! ## The fine-step grid -/

/-- The harness spends keys on a grid of width `g`; a real budget `x` costs `⌈x / g⌉`
**fine steps**. -/
noncomputable def steps (g x : ℝ) : ℤ := ⌈x / g⌉

lemma steps_mono {g : ℝ} (hg : 0 < g) {x y : ℝ} (hxy : x ≤ y) : steps g x ≤ steps g y :=
  Int.ceil_le_ceil (by gcongr)

/-- Rounding to the grid cannot absorb the amplification: quadrupling the real tax costs
at least `4 · steps - 3` fine steps. -/
theorem steps_quadruple_lower (g x : ℝ) :
    4 * steps g x - 3 ≤ steps g (4 * x) := by
  have hy : (4:ℝ) * x / g = 4 * (x / g) := by ring
  have hceil : ((4 * ⌈x / g⌉ : ℤ) : ℝ) < ((⌈4 * (x / g)⌉ : ℤ) : ℝ) + 4 := by
    have h1 : (⌈x / g⌉ : ℝ) < x / g + 1 := Int.ceil_lt_add_one _
    have h2 : (4:ℝ) * (x / g) ≤ (⌈4 * (x / g)⌉ : ℤ) := Int.le_ceil _
    push_cast
    linarith
  have hZ : 4 * ⌈x / g⌉ < ⌈4 * (x / g)⌉ + 4 := by exact_mod_cast hceil
  unfold steps
  rw [hy]
  omega

/-- **The NET-88 fine-step arithmetic.**  On the harness grid `g = 4`, the short-context
tax of `+4` keys is a single fine step, while its amplified long-context form of `+16`
keys is four fine steps — and the general bound `steps_quadruple_lower` shows this jump
is forced, not an artefact of the particular numbers. -/
theorem net88_fine_step_jump : steps 4 4 = 1 ∧ steps 4 16 = 4 := by
  constructor <;> · unfold steps; norm_num

/-- **No finite fine-step surcharge is safe.**  For every step count `N` there is a
context whose tokenizer tax costs at least `N` fine steps. -/
theorem step_tax_unbounded {A₀ b a τ lam gr : ℝ} (hA : 0 < A₀) (ha : 0 < a) (hb : 0 < b)
    (hτ : τ < 1) (hlam : 1 < lam) (hg : 0 < gr) (N : ℤ) :
    ∃ C : ℝ, 0 < C ∧ N ≤ steps gr (tax A₀ b a τ lam C) := by
  obtain ⟨C, hC, hlt⟩ := tax_unbounded hA ha hb hτ hlam ((N : ℝ) * gr)
  refine ⟨C, hC, ?_⟩
  unfold steps
  rw [Int.le_ceil_iff]
  have : (N : ℝ) < tax A₀ b a τ lam C / gr := by
    rw [lt_div_iff₀ hg]
    exact hlt
  linarith

end Catalog.Algebra.TokenizerTax