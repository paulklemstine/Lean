/-
# The multiplicative law is model-independent: dilation budgets and their characters

`Algebra.TokenizerTaxMultiplicative` proved the NET-88 multiplicative law inside one
concrete family (the power-law recall model).  A critic is entitled to ask whether the
law is an artefact of that family.  This file answers: **no** — the law follows from a
single structural property, and a completely different micro-model (a continuum Zipf
attention profile, whose retention curve is *computed here from an integral*, not
postulated) satisfies the same property.

## The structure

A `DilationBudget` is a positive budget function `B` of the context length together with
a factor `chi` describing how `B` responds to a dilation of the context:
`B (u * C) = chi u * B C`.  A language shift acts precisely as such a dilation — German
prose at context `C` is the reference workload at context `lam * C` — so every language
tax is `(chi lam - 1) * B C`.

* `DilationBudget.chi_mul`, `chi_one` — `chi` is *forced* to be a character of the
  dilation monoid; multiplicativity is derived, not assumed.
* `DilationBudget.tax_amplification` — the multiplicative law in its structural form:
  `tax C₂ * B C₁ = tax C₁ * B C₂`.  Amplification of the tax = acceleration of the
  baseline, in any model of the structure.
* `DilationBudget.tax_constant_iff_trivial` — the tax is context-independent iff the
  language is free or the baseline is dilation-invariant: P3 has no room.

## Two models

* `powerLawDilation` — the model of `Algebra.TokenizerTaxMultiplicative`, with character
  `chi u = u ^ (b / a)`.
* `zipfDilation` — a continuum Zipf attention profile `x ↦ x ^ (-s)` on `(0, C]` with
  `s < 1`.  Here `zipf_retained_eq_ratio` *derives* the retention curve
  `retained = (k / C) ^ (1 - s)` from the exact mass integrals, `zipf_gate_iff` shows the
  gate is exactly `k ≥ τ ^ (1 - s)⁻¹ * C`, and the resulting budget is a dilation budget
  with character `chi u = u`.

Both models therefore obey `tax_amplification`; the `4×` amplification observed at
ctx = 4096 is a structural, not a parametric, phenomenon.
-/
import Mathlib
import Algebra.TokenizerTaxMultiplicative

namespace Catalog.Algebra.TokenizerTax

open Real intervalIntegral

/-! ## Dilation budgets -/

/-- A **dilation budget**: a positive key-budget function of the context length which
responds to dilations of the context by a multiplicative factor `chi`. -/
structure DilationBudget where
  /-- key budget needed at context length `C` -/
  B : ℝ → ℝ
  /-- response factor to a dilation of the context -/
  chi : ℝ → ℝ
  B_pos : ∀ C, 0 < C → 0 < B C
  dilate : ∀ u C, 0 < u → 0 < C → B (u * C) = chi u * B C

namespace DilationBudget

variable (D : DilationBudget)

/-- The tax charged by a language whose fragmentation ratio is `lam`. -/
noncomputable def langTax (lam C : ℝ) : ℝ := D.B (lam * C) - D.B C

/-- `chi` is normalised. -/
theorem chi_one : D.chi 1 = 1 := by
  have h := D.dilate 1 1 one_pos one_pos
  rw [one_mul] at h
  have hpos := D.B_pos 1 one_pos
  have hcancel : D.chi 1 * D.B 1 = 1 * D.B 1 := by rw [← h, one_mul]
  exact mul_right_cancel₀ hpos.ne' hcancel

/-- **`chi` is a character.**  Multiplicativity of the response factor is *derived* from
the dilation law: composing two tokenizer shifts multiplies their costs.  Nothing in the
definition of a dilation budget assumed it. -/
theorem chi_mul {u v : ℝ} (hu : 0 < u) (hv : 0 < v) :
    D.chi (u * v) = D.chi u * D.chi v := by
  have hpos := D.B_pos 1 one_pos
  have h1 : D.B (u * (v * 1)) = D.chi u * (D.chi v * D.B 1) := by
    rw [D.dilate u (v * 1) hu (by simpa using hv), D.dilate v 1 hv one_pos]
  have h2 : D.B (u * v * 1) = D.chi (u * v) * D.B 1 :=
    D.dilate (u * v) 1 (mul_pos hu hv) one_pos
  rw [mul_one] at h1 h2
  have : D.chi (u * v) * D.B 1 = D.chi u * D.chi v * D.B 1 := by
    rw [← h2, h1]; ring
  exact mul_right_cancel₀ hpos.ne' this

/-- The tax is a fixed multiple of the baseline. -/
theorem langTax_eq {lam C : ℝ} (hlam : 0 < lam) (hC : 0 < C) :
    D.langTax lam C = (D.chi lam - 1) * D.B C := by
  unfold langTax
  rw [D.dilate lam C hlam hC]
  ring

/-- **The multiplicative law, structurally.**  In *any* dilation budget the tax and the
baseline scale by the same factor between two contexts. -/
theorem tax_amplification {lam C₁ C₂ : ℝ} (hlam : 0 < lam) (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) :
    D.langTax lam C₂ * D.B C₁ = D.langTax lam C₁ * D.B C₂ := by
  rw [D.langTax_eq hlam hC₁, D.langTax_eq hlam hC₂]
  ring

/-- Acceleration form: a baseline that grows by `ρ` amplifies the additive tax by `ρ`. -/
theorem tax_scales {lam C₁ C₂ ρ : ℝ} (hlam : 0 < lam) (hC₁ : 0 < C₁) (hC₂ : 0 < C₂)
    (hacc : D.B C₂ = ρ * D.B C₁) : D.langTax lam C₂ = ρ * D.langTax lam C₁ := by
  rw [D.langTax_eq hlam hC₁, D.langTax_eq hlam hC₂, hacc]
  ring

/-- **P3 has no room.**  The tax takes the same value at two contexts only if the language
is free (`chi lam = 1`) or the baseline itself is unchanged between them. -/
theorem tax_constant_iff_trivial {lam C₁ C₂ : ℝ} (hlam : 0 < lam) (hC₁ : 0 < C₁)
    (hC₂ : 0 < C₂) :
    D.langTax lam C₁ = D.langTax lam C₂ ↔ (D.chi lam = 1 ∨ D.B C₁ = D.B C₂) := by
  rw [D.langTax_eq hlam hC₁, D.langTax_eq hlam hC₂]
  constructor
  · intro h
    have hz : (D.chi lam - 1) * (D.B C₁ - D.B C₂) = 0 := by
      rw [mul_sub]
      exact sub_eq_zero.2 h
    rcases mul_eq_zero.1 hz with h' | h'
    · exact Or.inl (by linarith)
    · exact Or.inr (by linarith)
  · rintro (h | h)
    · rw [h]; ring
    · rw [h]

end DilationBudget

/-! ## Model 1: the power-law recall model -/

/-- The power-law model of `Algebra.TokenizerTaxMultiplicative`, packaged as a dilation
budget.  Its character is `u ↦ u ^ (b / a)`. -/
noncomputable def powerLawDilation (A₀ b a τ : ℝ) (hA : 0 < A₀) (hτ : τ < 1) :
    DilationBudget where
  B C := (A₀ / (1 - τ)) ^ a⁻¹ * C ^ (b / a)
  chi u := u ^ (b / a)
  B_pos C hC := by
    have h1τ : (0:ℝ) < 1 - τ := by linarith
    exact mul_pos (Real.rpow_pos_of_pos (div_pos hA h1τ) _) (Real.rpow_pos_of_pos hC _)
  dilate u C hu hC := by
    rw [Real.mul_rpow hu.le hC.le]
    ring

/-- On positive contexts the packaged budget agrees with `budget ∘ amplitude`. -/
theorem powerLawDilation_B {A₀ b a τ : ℝ} (hA : 0 < A₀) (hτ : τ < 1) {C : ℝ} (hC : 0 ≤ C) :
    (powerLawDilation A₀ b a τ hA hτ).B C = budget (amplitude A₀ b 1 C) a τ := by
  simpa [powerLawDilation] using (budget_baseline (b := b) hA.le hτ hC).symm

/-- The character of the power-law model is the amplification factor `amp`. -/
theorem powerLawDilation_chi {A₀ b a τ : ℝ} (hA : 0 < A₀) (hτ : τ < 1) (u : ℝ) :
    (powerLawDilation A₀ b a τ hA hτ).chi u = amp a b u := rfl

/-! ## Model 2: a continuum Zipf attention profile -/

/-- Total attention mass of the profile `x ↦ x ^ (-s)` on `(0, C]`, computed exactly.
Requires `s < 1` for integrability at the origin. -/
theorem zipf_mass (s C : ℝ) (hs : s < 1) :
    ∫ x in (0:ℝ)..C, x ^ (-s) = C ^ (1 - s) / (1 - s) := by
  rw [integral_rpow (Or.inl (by linarith))]
  have h0 : (0:ℝ) ^ (-s + 1) = 0 := Real.zero_rpow (by linarith)
  rw [h0]
  have : -s + 1 = 1 - s := by ring
  rw [this]
  ring

/-- **The Zipf retention curve, derived.**  With a continuum Zipf profile the fraction of
attention mass recovered by the top `k` positions of a context of length `C` is exactly
`(k / C) ^ (1 - s)`.  This is computed from the mass integrals, not assumed. -/
theorem zipf_retained_eq_ratio {s C k : ℝ} (hs : s < 1) (hk : 0 < k) (hC : 0 < C) :
    (∫ x in (0:ℝ)..k, x ^ (-s)) / (∫ x in (0:ℝ)..C, x ^ (-s)) = (k / C) ^ (1 - s) := by
  rw [zipf_mass s k hs, zipf_mass s C hs, Real.div_rpow hk.le hC.le]
  have h1s : (0:ℝ) < 1 - s := by linarith
  field_simp

/-- The Zipf key budget: the exact number of keys needed to clear the bar `τ`. -/
noncomputable def zipfBudget (s τ C : ℝ) : ℝ := τ ^ (1 - s)⁻¹ * C

/-- **The Zipf gate is exact.**  A budget of `k` keys clears the retention bar `τ` if and
only if `k ≥ τ ^ (1-s)⁻¹ * C`; in particular the requirement is exactly linear in the
context length. -/
theorem zipf_gate_iff {s τ C k : ℝ} (hs : s < 1) (hτ : 0 < τ) (hk : 0 < k) (hC : 0 < C) :
    τ ≤ (k / C) ^ (1 - s) ↔ zipfBudget s τ C ≤ k := by
  have h1s : (0:ℝ) < 1 - s := by linarith
  have hkc : (0:ℝ) < k / C := div_pos hk hC
  unfold zipfBudget
  constructor
  · intro h
    have h' : τ ^ (1 - s)⁻¹ ≤ ((k / C) ^ (1 - s)) ^ (1 - s)⁻¹ :=
      Real.rpow_le_rpow hτ.le h (inv_nonneg.2 h1s.le)
    rw [Real.rpow_rpow_inv hkc.le h1s.ne'] at h'
    exact (le_div_iff₀ hC).1 h'
  · intro h
    have hdiv : τ ^ (1 - s)⁻¹ ≤ k / C := (le_div_iff₀ hC).2 h
    have h' : (τ ^ (1 - s)⁻¹) ^ (1 - s) ≤ (k / C) ^ (1 - s) :=
      Real.rpow_le_rpow (Real.rpow_nonneg hτ.le _) hdiv h1s.le
    rwa [Real.rpow_inv_rpow hτ.le h1s.ne'] at h'

/-- The Zipf model as a dilation budget: its character is the identity, `chi u = u`. -/
noncomputable def zipfDilation (s τ : ℝ) (hτ : 0 < τ) : DilationBudget where
  B C := zipfBudget s τ C
  chi u := u
  B_pos C hC := mul_pos (Real.rpow_pos_of_pos hτ _) hC
  dilate u C _ _ := by unfold zipfBudget; ring

/-- **Model independence.**  The Zipf micro-model, built from attention-mass integrals and
sharing no parameter with the power-law model, obeys the same multiplicative law: the tax
of a fragmenting language is amplified by exactly the acceleration of the baseline. -/
theorem zipf_tax_amplification {s τ lam C₁ C₂ : ℝ} (hτ : 0 < τ) (hlam : 0 < lam)
    (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) :
    (zipfDilation s τ hτ).langTax lam C₂ * zipfBudget s τ C₁
      = (zipfDilation s τ hτ).langTax lam C₁ * zipfBudget s τ C₂ :=
  (zipfDilation s τ hτ).tax_amplification hlam hC₁ hC₂

/-- In the Zipf model the tax is exactly `(lam - 1)` baselines: a `4×` longer context
carries a `4×` larger tokenizer tax. -/
theorem zipf_langTax_eq {s τ lam C : ℝ} (hτ : 0 < τ) (hlam : 0 < lam) (hC : 0 < C) :
    (zipfDilation s τ hτ).langTax lam C = (lam - 1) * zipfBudget s τ C :=
  (zipfDilation s τ hτ).langTax_eq hlam hC

/-- **The two models share the multiplicative law but not the exponent.**  The power-law
model amplifies by `lam ^ (b / a)`, the Zipf model (whose character is the identity) by
`lam`; the two characters agree exactly when `b = a`.  So the *law* is structural while
the *exponent* is the measurable content — the NET-88 datum `4× amplification` measures
`b / a`, nothing else. -/
theorem amp_eq_identity_iff {a b lam : ℝ} (ha : 0 < a) (hlam : 1 < lam) :
    amp a b lam = lam ↔ b = a := by
  unfold amp
  constructor
  · intro h
    have h' : lam ^ (b / a) = lam ^ (1:ℝ) := by rw [Real.rpow_one]; exact h
    have h1 : b / a ≤ 1 := (Real.rpow_le_rpow_left_iff hlam).1 h'.le
    have h2 : (1:ℝ) ≤ b / a := (Real.rpow_le_rpow_left_iff hlam).1 h'.ge
    have hba : b / a = 1 := le_antisymm h1 h2
    field_simp at hba
    linarith
  · intro h
    subst h
    rw [div_self ha.ne', Real.rpow_one]

/-- The Zipf character is the identity, so `amp_eq_identity_iff` really does compare the
two models' characters. -/
theorem zipfDilation_chi {s τ : ℝ} (hτ : 0 < τ) (u : ℝ) : (zipfDilation s τ hτ).chi u = u :=
  rfl

/-! ## Falsifiable predictions for the next experimental cells -/

namespace DilationBudget

variable (D : DilationBudget)

/-- **Prediction 1: the language ratio is a context invariant.**  Each language's tax
diverges with context, but the *ratio* of two languages' taxes is the same at every
context length.  Measuring French and German at two context lengths tests this with no
free parameter: `taxFr C₁ · taxDe C₂ = taxFr C₂ · taxDe C₁`. -/
theorem tax_ratio_context_invariant {l₁ l₂ C₁ C₂ : ℝ} (h₁ : 0 < l₁) (h₂ : 0 < l₂)
    (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) :
    D.langTax l₁ C₁ * D.langTax l₂ C₂ = D.langTax l₁ C₂ * D.langTax l₂ C₁ := by
  rw [D.langTax_eq h₁ hC₁, D.langTax_eq h₂ hC₂, D.langTax_eq h₁ hC₂, D.langTax_eq h₂ hC₁]
  ring

/-- **Prediction 2: the language ranking never crosses.**  If one language's character is
at least another's, its tax is at least the other's at *every* context length; no context
length can reverse the ordering of two languages. -/
theorem tax_ordering_context_invariant {l₁ l₂ C : ℝ} (h₁ : 0 < l₁) (h₂ : 0 < l₂)
    (hC : 0 < C) (hchi : D.chi l₁ ≤ D.chi l₂) :
    D.langTax l₁ C ≤ D.langTax l₂ C := by
  rw [D.langTax_eq h₁ hC, D.langTax_eq h₂ hC]
  exact mul_le_mul_of_nonneg_right (by linarith) (D.B_pos C hC).le

end DilationBudget

/-- In the power-law model the ordering hypothesis of `tax_ordering_context_invariant` is
decided by the fragmentation ratios alone: a more fragmenting language has a strictly
larger character.  So a French cell at `4096` is predicted to sit strictly between the
English baseline and the German curve exactly when `1 < lam_fr < lam_de`. -/
theorem amp_strictMono {a b l₁ l₂ : ℝ} (ha : 0 < a) (hb : 0 < b) (h₁ : 0 < l₁)
    (h₁₂ : l₁ < l₂) : amp a b l₁ < amp a b l₂ :=
  Real.rpow_lt_rpow h₁.le h₁₂ (by positivity)

end Catalog.Algebra.TokenizerTax