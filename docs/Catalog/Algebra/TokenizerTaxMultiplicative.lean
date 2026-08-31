/-
# The algebra of the tokenizer tax: why a `+4` key tax becomes `+16` at long context

## The experiment (NET-88, German prose, ctx = 4096, gate exact, 3 held-out windows)

| k        | 24    | 32    | 40    | 48    | 56    |
|----------|-------|-------|-------|-------|-------|
| retained | 0.953 | 0.966 | 0.973 | 0.975 | 0.976 |

Every point fails the `0.98` bar; the additive `+4` fine-step penalty that a language
shift costs at short context has grown to `≥ +16` at `4096`, an exact `4×` amplification
matching the acceleration of the baseline requirement itself.

## The model formalised here

The measured curve is a *power-law recall deficit*

`deficit A a k = A * k ^ (-a)`,   `retained = 1 - deficit`,

a two-parameter family whose log–log fit to the table above is `a ≈ 0.810`, `A ≈ 0.582`
(see `ComputationalEvidence.md`; residuals `< 0.004` on all five points).  The *amplitude*
`A` is where the two experimental knobs enter:

* the **context length** `C`, through `A = A₀ * C ^ b` (longer context ⇒ more mass to
  recover), and
* the **language**, through a *fragmentation ratio* `lam`: German prose spends `lam > 1`
  tokens per unit of English content, so the effective context is `lam * C`.

The exact key budget needed to clear a retention bar `τ` is then
`budget A a τ = (A / (1 - τ)) ^ a⁻¹` (`budget_iff` proves this is *exactly* the
requirement, not a bound).

## What is proved

* `budget_iff` — the budget functional is the exact threshold of the retention gate.
* `budget_smul` — `budget` is homogeneous of degree `a⁻¹` in the amplitude: the language
  and context knobs act on it by *multiplication*.
* `ampHom` — the amplification factor `lam ↦ lam ^ (b / a)` is a monoid homomorphism
  `ℝ≥0 →* ℝ≥0` (the tax is a *character* of the fragmentation group), and
  `amplification_universal` shows it is independent of the bar `τ` and of `A₀`.
* `tax_eq_amp_mul_baseline`, `tax_amplification` — **the multiplicative law**: the
  additive tax is a fixed multiple of the baseline requirement, hence its amplification
  between two contexts *equals* the acceleration of the baseline.  `tax_four_to_sixteen`
  is the NET-88 instance: baseline `×4` forces `+4 ↦ +16`.
* `tax_unbounded`, `tax_not_constant` — P2/P3 refuted: the tax neither dissolves nor
  stays at a fixed additive offset; it diverges.
* `budget_superlinear_of_exponent_lt_one` — the *explosion*: because the measured recall
  exponent satisfies `a < 1`, the budget responds *superlinearly* to the amplitude, so the
  tax factor `lam ^ (b / a)` strictly exceeds the naive token ratio `lam ^ b`.
* `net88_exponent_lt_one` — `a < 1` is *forced* by the two measured anchors
  `deficit 24 = 0.047`, `deficit 56 = 0.024`; it is not an assumption.
* `net88_all_points_fail`, `net88_budget_gt_56` — from the single measured anchor at
  `k = 56` the whole row fails and the true requirement exceeds `56`.
-/
import Mathlib

namespace Catalog.Algebra.TokenizerTax

open Real

/-! ## The power-law recall model -/

/-- Retention **deficit** at key budget `k`: the fraction of attention mass that a
top-`k` cache fails to recover, modelled by the power law `A * k ^ (-a)`. -/
noncomputable def deficit (A a k : ℝ) : ℝ := A * k ^ (-a)

/-- The **retained** fraction: what the harness reports. -/
noncomputable def retained (A a k : ℝ) : ℝ := 1 - deficit A a k

/-- The exact real **budget** required to clear the retention bar `τ`. -/
noncomputable def budget (A a τ : ℝ) : ℝ := (A / (1 - τ)) ^ a⁻¹

/-- The deficit amplitude at context `C` for a language of fragmentation ratio `lam`:
the effective context is `lam * C`, and amplitude grows like a power `b` of it. -/
noncomputable def amplitude (A₀ b lam C : ℝ) : ℝ := A₀ * (lam * C) ^ b

/-- The **tokenizer-tax amplification factor**: the multiple by which a fragmentation
ratio `lam` inflates every key budget. -/
noncomputable def amp (a b lam : ℝ) : ℝ := lam ^ (b / a)

/-! ### Elementary positivity and monotonicity -/

lemma deficit_pos {A a k : ℝ} (hA : 0 < A) (hk : 0 < k) : 0 < deficit A a k :=
  mul_pos hA (Real.rpow_pos_of_pos hk _)

/-- The deficit is strictly decreasing in the key budget: spending keys always helps,
which is why the failure of the *largest* measured `k` condemns the whole row. -/
theorem deficit_strictAnti {A a : ℝ} (hA : 0 < A) (ha : 0 < a) {k l : ℝ}
    (hk : 0 < k) (hkl : k < l) : deficit A a l < deficit A a k := by
  have hl : 0 < l := hk.trans hkl
  have h1 : k ^ a < l ^ a := Real.rpow_lt_rpow hk.le hkl ha
  have hkp : (0:ℝ) < k ^ a := Real.rpow_pos_of_pos hk a
  have hlp : (0:ℝ) < l ^ a := Real.rpow_pos_of_pos hl a
  have : (l ^ a)⁻¹ < (k ^ a)⁻¹ := by
    exact inv_strictAnti₀ hkp h1
  unfold deficit
  rw [Real.rpow_neg hk.le, Real.rpow_neg hl.le]
  exact mul_lt_mul_of_pos_left this hA

/-- Retention is strictly increasing in the key budget. -/
theorem retained_strictMono {A a : ℝ} (hA : 0 < A) (ha : 0 < a) {k l : ℝ}
    (hk : 0 < k) (hkl : k < l) : retained A a k < retained A a l := by
  unfold retained
  have := deficit_strictAnti hA ha hk hkl
  linarith

lemma budget_pos {A a τ : ℝ} (hA : 0 < A) (hτ : τ < 1) : 0 < budget A a τ :=
  Real.rpow_pos_of_pos (div_pos hA (by linarith)) _

/-! ## The budget functional is the exact gate threshold -/

/-- **Exactness of the budget functional.**  A key budget `k` clears the bar `τ` if and
only if it is at least `budget A a τ`.  This is an iff, not an estimate: the model has a
sharp threshold, and everything below is a genuine failure. -/
theorem budget_iff {A a τ k : ℝ} (hA : 0 < A) (ha : 0 < a) (hτ : τ < 1) (hk : 0 < k) :
    τ ≤ retained A a k ↔ budget A a τ ≤ k := by
  have h1τ : (0:ℝ) < 1 - τ := by linarith
  have hka : (0:ℝ) < k ^ a := Real.rpow_pos_of_pos hk a
  have step1 : τ ≤ retained A a k ↔ A / (1 - τ) ≤ k ^ a := by
    unfold retained deficit
    rw [Real.rpow_neg hk.le, ← div_eq_mul_inv, div_le_iff₀ h1τ]
    constructor
    · intro h
      have h2 : A / k ^ a ≤ 1 - τ := by linarith
      rw [div_le_iff₀ hka] at h2
      linarith
    · intro h
      have h2 : A / k ^ a ≤ 1 - τ := by
        rw [div_le_iff₀ hka]
        linarith
      linarith
  rw [step1]
  unfold budget
  constructor
  · intro h
    have := (Real.rpow_le_rpow_iff (le_of_lt (div_pos hA h1τ)) hka.le (inv_pos.2 ha)).2 h
    rwa [Real.rpow_rpow_inv hk.le ha.ne'] at this
  · intro h
    have := (Real.rpow_le_rpow_iff (Real.rpow_nonneg (le_of_lt (div_pos hA h1τ)) _) hk.le ha).2 h
    rwa [Real.rpow_inv_rpow (le_of_lt (div_pos hA h1τ)) ha.ne'] at this

/-! ## Homogeneity: the two knobs act multiplicatively -/

/-- **Homogeneity of the budget.**  Scaling the deficit amplitude by `c` scales the key
requirement by `c ^ a⁻¹`.  Both experimental knobs — language and context — act on the
model only through the amplitude, so both act on the budget by multiplication. -/
theorem budget_smul {A a τ c : ℝ} (hA : 0 ≤ A) (hc : 0 ≤ c) (hτ : τ < 1) :
    budget (c * A) a τ = c ^ a⁻¹ * budget A a τ := by
  have h1τ : (0:ℝ) < 1 - τ := by linarith
  unfold budget
  rw [mul_div_assoc, Real.mul_rpow hc (div_nonneg hA h1τ.le)]

/-- The context-only baseline budget in closed form: `K * C ^ (b / a)`. -/
theorem budget_baseline {A₀ b a τ C : ℝ} (hA : 0 ≤ A₀) (hτ : τ < 1)
    (hC : 0 ≤ C) :
    budget (amplitude A₀ b 1 C) a τ = (A₀ / (1 - τ)) ^ a⁻¹ * C ^ (b / a) := by
  have h1τ : (0:ℝ) < 1 - τ := by linarith
  unfold amplitude budget
  have hexp : b * a⁻¹ = b / a := by ring
  rw [one_mul, mul_comm A₀ (C ^ b), mul_div_assoc,
    Real.mul_rpow (Real.rpow_nonneg hC b) (div_nonneg hA h1τ.le),
    ← Real.rpow_mul hC, hexp, mul_comm]

/-- **The language knob is exactly the amplification factor.**  Switching from a language
of fragmentation `1` to one of fragmentation `lam` multiplies the required key budget by
`amp a b lam = lam ^ (b / a)` — for every context length, every bar `τ`, every `A₀`. -/
theorem budget_language {A₀ b a τ lam C : ℝ} (hA : 0 ≤ A₀) (hτ : τ < 1)
    (hlam : 0 ≤ lam) (hC : 0 ≤ C) :
    budget (amplitude A₀ b lam C) a τ = amp a b lam * budget (amplitude A₀ b 1 C) a τ := by
  have h1τ : (0:ℝ) < 1 - τ := by linarith
  have hsplit : amplitude A₀ b lam C = lam ^ b * amplitude A₀ b 1 C := by
    unfold amplitude
    rw [one_mul, Real.mul_rpow hlam hC]
    ring
  have hnn : (0:ℝ) ≤ amplitude A₀ b 1 C := by
    unfold amplitude
    exact mul_nonneg hA (Real.rpow_nonneg (by simpa using hC) b)
  rw [hsplit, budget_smul hnn (Real.rpow_nonneg hlam b) hτ]
  congr 1
  unfold amp
  rw [← Real.rpow_mul hlam, div_eq_mul_inv]

/-! ## The amplification factor is a character of the fragmentation group -/

/-- The amplification factor as a **monoid homomorphism** `ℝ≥0 →* ℝ≥0`: composing two
tokenizer shifts multiplies their taxes.  Language shifts form a group and the tax is a
character of it. -/
noncomputable def ampHom (e : ℝ) : NNReal →* NNReal where
  toFun x := x ^ e
  map_one' := NNReal.one_rpow e
  map_mul' _ _ := NNReal.mul_rpow

@[simp] lemma ampHom_apply (e : ℝ) (x : NNReal) : ampHom e x = x ^ e := rfl

/-- Composition of fragmentation ratios multiplies the taxes. -/
theorem amp_mul {a b l₁ l₂ : ℝ} (h₁ : 0 ≤ l₁) (h₂ : 0 ≤ l₂) :
    amp a b (l₁ * l₂) = amp a b l₁ * amp a b l₂ := by
  unfold amp
  exact Real.mul_rpow h₁ h₂

@[simp] theorem amp_one (a b : ℝ) : amp a b 1 = 1 := Real.one_rpow _

/-- A genuinely fragmenting language costs strictly more. -/
theorem one_lt_amp {a b lam : ℝ} (ha : 0 < a) (hb : 0 < b) (hlam : 1 < lam) :
    1 < amp a b lam :=
  Real.one_lt_rpow_iff_of_pos (by linarith) |>.2 (Or.inl ⟨hlam, by positivity⟩)

/-- **Universality of the amplification.**  The ratio between the two language budgets is
the same number for any pair of bars `τ₁, τ₂` and any pair of amplitudes: the tax factor
knows nothing about the gate or the corpus size, only about `b / a`. -/
theorem amplification_universal {a b lam τ₁ τ₂ A B : ℝ} (hA : 0 ≤ A) (hB : 0 ≤ B)
    (hlam : 0 ≤ lam) (h₁ : τ₁ < 1) (h₂ : τ₂ < 1) :
    budget (lam ^ b * A) a τ₁ * budget B a τ₂
      = budget A a τ₁ * budget (lam ^ b * B) a τ₂ := by
  rw [budget_smul hA (Real.rpow_nonneg hlam b) h₁,
    budget_smul hB (Real.rpow_nonneg hlam b) h₂]
  ring

/-! ## The multiplicative law: amplification of the tax = acceleration of the baseline -/

/-- The **tokenizer tax**: extra keys the fragmenting language needs at context `C`. -/
noncomputable def tax (A₀ b a τ lam C : ℝ) : ℝ :=
  budget (amplitude A₀ b lam C) a τ - budget (amplitude A₀ b 1 C) a τ

/-- The tax is a *fixed multiple* of the baseline requirement. -/
theorem tax_eq_amp_mul_baseline {A₀ b a τ lam C : ℝ} (hA : 0 ≤ A₀)
    (hτ : τ < 1) (hlam : 0 ≤ lam) (hC : 0 ≤ C) :
    tax A₀ b a τ lam C = (amp a b lam - 1) * budget (amplitude A₀ b 1 C) a τ := by
  unfold tax
  rw [budget_language hA hτ hlam hC]
  ring

/-- **The multiplicative law (NET-88).**  For any two contexts the tax and the baseline
requirement scale by the *same* factor:
`tax C₂ * baseline C₁ = tax C₁ * baseline C₂`.
So an additive penalty measured at short context cannot be transported additively: it is
multiplied by exactly the acceleration of the baseline. -/
theorem tax_amplification {A₀ b a τ lam C₁ C₂ : ℝ} (hA : 0 ≤ A₀)
    (hτ : τ < 1) (hlam : 0 ≤ lam) (hC₁ : 0 ≤ C₁) (hC₂ : 0 ≤ C₂) :
    tax A₀ b a τ lam C₂ * budget (amplitude A₀ b 1 C₁) a τ
      = tax A₀ b a τ lam C₁ * budget (amplitude A₀ b 1 C₂) a τ := by
  rw [tax_eq_amp_mul_baseline hA hτ hlam hC₁, tax_eq_amp_mul_baseline hA hτ hlam hC₂]
  ring

/-- Ratio form: if the baseline requirement accelerates by `ρ` between two contexts, the
additive tax is amplified by exactly `ρ`. -/
theorem tax_scales_with_baseline {A₀ b a τ lam C₁ C₂ ρ : ℝ} (hA : 0 ≤ A₀)
    (hτ : τ < 1) (hlam : 0 ≤ lam) (hC₁ : 0 ≤ C₁) (hC₂ : 0 ≤ C₂)
    (hacc : budget (amplitude A₀ b 1 C₂) a τ = ρ * budget (amplitude A₀ b 1 C₁) a τ) :
    tax A₀ b a τ lam C₂ = ρ * tax A₀ b a τ lam C₁ := by
  rw [tax_eq_amp_mul_baseline hA hτ hlam hC₁, tax_eq_amp_mul_baseline hA hτ hlam hC₂,
    hacc]
  ring

/-- **The NET-88 headline, as an equation.**  A `4×` acceleration of the baseline turns a
`+4` fine-step tax into exactly `+16`. -/
theorem tax_four_to_sixteen {A₀ b a τ lam C₁ C₂ : ℝ} (hA : 0 ≤ A₀)
    (hτ : τ < 1) (hlam : 0 ≤ lam) (hC₁ : 0 ≤ C₁) (hC₂ : 0 ≤ C₂)
    (hacc : budget (amplitude A₀ b 1 C₂) a τ = 4 * budget (amplitude A₀ b 1 C₁) a τ)
    (hshort : tax A₀ b a τ lam C₁ = 4) :
    tax A₀ b a τ lam C₂ = 16 := by
  rw [tax_scales_with_baseline hA hτ hlam hC₁ hC₂ hacc, hshort]
  norm_num

/-! ## P2 and P3 refuted: the tax neither dissolves nor stays put -/

/-- **The tax diverges.**  For a fragmenting language (`lam > 1`) with growing amplitude
(`b > 0`), no additive budget line survives: for every `M` there is a context length whose
tax exceeds `M`.  In particular the tax does not dissolve (P2) and is not an intermediate
constant (P3). -/
theorem tax_unbounded {A₀ b a τ lam : ℝ} (hA : 0 < A₀) (ha : 0 < a) (hb : 0 < b)
    (hτ : τ < 1) (hlam : 1 < lam) (M : ℝ) :
    ∃ C : ℝ, 0 < C ∧ M < tax A₀ b a τ lam C := by
  have h1τ : (0:ℝ) < 1 - τ := by linarith
  set K : ℝ := (A₀ / (1 - τ)) ^ a⁻¹ with hK
  have hKpos : 0 < K := Real.rpow_pos_of_pos (div_pos hA h1τ) _
  have hamp : 1 < amp a b lam := one_lt_amp ha hb hlam
  set c : ℝ := (amp a b lam - 1) * K with hc
  have hcpos : 0 < c := mul_pos (by linarith) hKpos
  set t : ℝ := |M| + 1 with ht
  have htpos : 0 < t := by positivity
  refine ⟨(t / c) ^ (a / b), Real.rpow_pos_of_pos (div_pos htpos hcpos) _, ?_⟩
  have hCnn : (0:ℝ) ≤ (t / c) ^ (a / b) := (Real.rpow_pos_of_pos (div_pos htpos hcpos) _).le
  rw [tax_eq_amp_mul_baseline hA.le hτ (by linarith) hCnn,
    budget_baseline hA.le hτ hCnn]
  rw [← Real.rpow_mul (div_pos htpos hcpos).le]
  have hexp : a / b * (b / a) = 1 := by field_simp
  rw [hexp, Real.rpow_one]
  have hval : (amp a b lam - 1) * (K * (t / c)) = t := by
    field_simp [hc]
    ring
  calc M ≤ |M| := le_abs_self M
    _ < t := by linarith
    _ = (amp a b lam - 1) * (K * (t / c)) := hval.symm

/-- **No additive law exists** (P3 refuted formally): the tax cannot be a constant `t`
independent of context. -/
theorem tax_not_constant {A₀ b a τ lam : ℝ} (hA : 0 < A₀) (ha : 0 < a) (hb : 0 < b)
    (hτ : τ < 1) (hlam : 1 < lam) :
    ¬ ∃ t : ℝ, ∀ C : ℝ, 0 < C → tax A₀ b a τ lam C = t := by
  rintro ⟨t, ht⟩
  obtain ⟨C, hC, hlt⟩ := tax_unbounded hA ha hb hτ hlam t
  rw [ht C hC] at hlt
  exact lt_irrefl t hlt

/-! ## The explosion: a sub-linear recall exponent makes the budget super-linear -/

/-- **Super-linear response.**  When the recall exponent satisfies `a < 1` — which the
NET-88 anchors force, see `net88_exponent_lt_one` — multiplying the deficit amplitude by
`c > 1` multiplies the key budget by *more* than `c`.  This is the algebraic content of
"the tax explodes": the amplification `lam ^ (b/a)` strictly exceeds the naive token
ratio `lam ^ b`. -/
theorem budget_superlinear_of_exponent_lt_one {A a τ c : ℝ} (hA : 0 < A) (ha : 0 < a)
    (ha1 : a < 1) (hτ : τ < 1) (hc : 1 < c) :
    c * budget A a τ < budget (c * A) a τ := by
  have hbpos : 0 < budget A a τ := budget_pos hA hτ
  rw [budget_smul hA.le (by linarith) hτ]
  have hcc : c < c ^ a⁻¹ := by
    have h1 : (1:ℝ) < a⁻¹ := by
      rw [lt_inv_comm₀ (by norm_num) ha]
      simpa using ha1
    calc c = c ^ (1:ℝ) := (Real.rpow_one c).symm
      _ < c ^ a⁻¹ := Real.rpow_lt_rpow_left_iff hc |>.2 h1
  exact mul_lt_mul_of_pos_right hcc hbpos

/-- The amplification factor strictly exceeds the naive token ratio when `a < 1`. -/
theorem amp_gt_token_ratio {a b lam : ℝ} (ha : 0 < a) (ha1 : a < 1) (hb : 0 < b)
    (hlam : 1 < lam) : lam ^ b < amp a b lam := by
  unfold amp
  refine Real.rpow_lt_rpow_left_iff hlam |>.2 ?_
  rw [div_eq_mul_inv]
  have h1 : (1:ℝ) < a⁻¹ := by
    rw [lt_inv_comm₀ (by norm_num) ha]
    simpa using ha1
  nlinarith

/-! ## The measured anchors -/

/-- **The recall exponent is forced to be sub-linear.**  From the two NET-88 anchors
`deficit 24 = 0.047` and `deficit 56 = 0.024` alone — no fitting, no extra assumption —
the power law must have `a < 1`.  Combined with
`budget_superlinear_of_exponent_lt_one` this is the mechanism of the explosion. -/
theorem net88_exponent_lt_one {A a : ℝ}
    (h24 : deficit A a 24 = 0.047) (h56 : deficit A a 56 = 0.024) : a < 1 := by
  by_contra hcon
  push_neg at hcon
  have h24p : (0:ℝ) < (24:ℝ) ^ a := Real.rpow_pos_of_pos (by norm_num) a
  have h56p : (0:ℝ) < (56:ℝ) ^ a := Real.rpow_pos_of_pos (by norm_num) a
  have e24 : A = 0.047 * (24:ℝ) ^ a := by
    unfold deficit at h24
    rw [Real.rpow_neg (by norm_num)] at h24
    field_simp at h24
    linarith [h24]
  have e56 : A = 0.024 * (56:ℝ) ^ a := by
    unfold deficit at h56
    rw [Real.rpow_neg (by norm_num)] at h56
    field_simp at h56
    linarith [h56]
  -- hence `(56/24) ^ a = 47/24`, but `a ≥ 1` forces `(56/24) ^ a ≥ 56/24 > 47/24`
  have key : (0.024:ℝ) * (56:ℝ) ^ a = 0.047 * (24:ℝ) ^ a := by rw [← e56, ← e24]
  have hratio : ((56:ℝ) / 24) ^ a = 0.047 / 0.024 := by
    rw [Real.div_rpow (by norm_num) (by norm_num)]
    field_simp
    linarith [key]
  have hbig : (56:ℝ) / 24 ≤ ((56:ℝ) / 24) ^ a := by
    calc (56:ℝ) / 24 = ((56:ℝ) / 24) ^ (1:ℝ) := (Real.rpow_one _).symm
      _ ≤ ((56:ℝ) / 24) ^ a := Real.rpow_le_rpow_left_iff (by norm_num) |>.2 hcon
  rw [hratio] at hbig
  norm_num at hbig

/-- **The whole NET-88 row fails.**  The harness measured `retained = 0.976` at the
largest budget `k = 56`, below the `0.98` bar.  Monotonicity of the model then condemns
every smaller budget as well — the five failures are one failure. -/
theorem net88_all_points_fail {A a : ℝ} (hA : 0 < A) (ha : 0 < a)
    (h56 : retained A a 56 < 0.98) :
    ∀ k : ℝ, 0 < k → k ≤ 56 → retained A a k < 0.98 := by
  intro k hk hk56
  rcases eq_or_lt_of_le hk56 with h | h
  · rwa [h]
  · exact lt_trans (retained_strictMono hA ha hk h) h56

/-- The true requirement lies strictly beyond the largest measured point. -/
theorem net88_budget_gt_56 {A a : ℝ} (hA : 0 < A) (ha : 0 < a)
    (h56 : retained A a 56 < 0.98) : 56 < budget A a 0.98 := by
  by_contra hcon
  push_neg at hcon
  have := (budget_iff (τ := 0.98) hA ha (by norm_num) (by norm_num : (0:ℝ) < 56)).2 hcon
  linarith

/-- **Anti-vacuity witness.**  The hypotheses of `tax_four_to_sixteen` are simultaneously
satisfiable: take `A₀ = b = a = 1`, `τ = 1/2`, fragmentation `lam = 3` and the contexts
`C₁ = 1`, `C₂ = 4`.  The baseline requirement then really does accelerate by `4×`, the
short-context tax really is `+4`, and the long-context tax really is `+16`. -/
theorem net88_witness_instance :
    budget (amplitude 1 1 1 4) 1 (1/2) = 4 * budget (amplitude 1 1 1 1) 1 (1/2) ∧
      tax 1 1 1 (1/2) 3 1 = 4 ∧ tax 1 1 1 (1/2) 3 4 = 16 := by
  refine ⟨?_, ?_, ?_⟩ <;> · simp only [tax, budget, amplitude]; norm_num

end Catalog.Algebra.TokenizerTax