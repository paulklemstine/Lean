import Algebra.RLHFDriftCore

/-!
# The PPO-ptx objective: definition and uniqueness of the optimum

Domain: Algebra (convex analysis × information theory × alignment theory).

`Algebra.RLHFPTXMonotone` studies the comparative statics of the PPO-ptx
objective

`J_γ(q) = objective β r p q + γ · ∑_y d y · log (q y)`,

where `objective β r p q = 𝔼_q[r] − β · KL(q ‖ p)` is the usual KL-regularised
RLHF objective on the finite outcome space `Ω`, `d` is the pretraining
distribution and `γ ≥ 0` the mix-in coefficient.  This file supplies the two
objects that the comparative-statics file is phrased in (`RLHF.objective` and
`RLHF.objectivePTX`, both written in terms of the base functionals `RLHF.mean`
and `RLHF.klDiv` of `Algebra.RLHFDriftCore`) together with the structural fact
that makes the phrase "*the* optimum `q*_γ`" legitimate:

* `RLHF.objectivePTX_midpoint_lt` — strict midpoint concavity of the PTX
  objective in the policy `q` (for `β > 0`, `γ ≥ 0`, `d ≥ 0`): the value at the
  midpoint of two distinct positive policies strictly exceeds the average of the
  two values;
* `RLHF.ptx_optimum_unique` — hence a maximiser of `J_γ` over the positive
  policies is unique.

The mechanism is elementary: `t ↦ −β t log t` is *strictly* concave,
`t ↦ γ d y log t` is concave, and everything else is affine in `q`.  Both facts
come from the single inequality `log x ≤ x − 1`, strict for `x ≠ 1`.
-/

namespace RLHF

open Finset

variable {Ω : Type*} [Fintype Ω]

/-- The KL-regularised RLHF objective `𝔼_q[r] − β · KL(q ‖ p)`. -/
noncomputable def objective (β : ℝ) (r p q : Ω → ℝ) : ℝ := mean q r - β * klDiv q p

/-- The PPO-ptx objective: the RLHF objective plus `γ` times the pretraining
cross-entropy `∑_y d y log (q y)`. -/
noncomputable def objectivePTX (β γ : ℝ) (r p d q : Ω → ℝ) : ℝ :=
  objective β r p q + γ * ∑ y, d y * Real.log (q y)

/-! ## Two elementary convexity inequalities -/

/-- Strict midpoint convexity of `t ↦ t log t` on `(0, ∞)`. -/
theorem mul_log_midpoint_lt {a b : ℝ} (ha : 0 < a) (hb : 0 < b) (hab : a ≠ b) :
    (a + b) / 2 * Real.log ((a + b) / 2) < (a * Real.log a + b * Real.log b) / 2 := by
  set s : ℝ := (a + b) / 2 with hs_def
  have hs : 0 < s := by rw [hs_def]; linarith
  have hane : s / a ≠ 1 := by
    intro h
    apply hab
    have hsa : s = a := by field_simp at h; linarith
    rw [hs_def] at hsa
    linarith
  have h1 : a * Real.log s - a * Real.log a < s - a := by
    have hlt : Real.log (s / a) < s / a - 1 :=
      Real.log_lt_sub_one_of_pos (by positivity) hane
    rw [Real.log_div (ne_of_gt hs) (ne_of_gt ha)] at hlt
    have hmul := mul_lt_mul_of_pos_left hlt ha
    have hfield : a * (s / a - 1) = s - a := by field_simp
    have hexp : a * (Real.log s - Real.log a) = a * Real.log s - a * Real.log a := by ring
    rw [hfield, hexp] at hmul
    exact hmul
  have h2 : b * Real.log s - b * Real.log b ≤ s - b := by
    have hle : Real.log (s / b) ≤ s / b - 1 := Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_div (ne_of_gt hs) (ne_of_gt hb)] at hle
    have hmul := mul_le_mul_of_nonneg_left hle hb.le
    have hfield : b * (s / b - 1) = s - b := by field_simp
    have hexp : b * (Real.log s - Real.log b) = b * Real.log s - b * Real.log b := by ring
    rw [hfield, hexp] at hmul
    exact hmul
  have hsum : a + b = 2 * s := by rw [hs_def]; ring
  have hls : a * Real.log s + b * Real.log s = 2 * (s * Real.log s) := by
    rw [show a * Real.log s + b * Real.log s = (a + b) * Real.log s by ring, hsum]; ring
  linarith

/-- Midpoint concavity of `log` on `(0, ∞)`. -/
theorem log_midpoint_le {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    (Real.log a + Real.log b) / 2 ≤ Real.log ((a + b) / 2) := by
  set s : ℝ := (a + b) / 2 with hs_def
  have hs : 0 < s := by rw [hs_def]; linarith
  have h1 : Real.log a - Real.log s ≤ a / s - 1 := by
    have hle : Real.log (a / s) ≤ a / s - 1 := Real.log_le_sub_one_of_pos (by positivity)
    rwa [Real.log_div (ne_of_gt ha) (ne_of_gt hs)] at hle
  have h2 : Real.log b - Real.log s ≤ b / s - 1 := by
    have hle : Real.log (b / s) ≤ b / s - 1 := Real.log_le_sub_one_of_pos (by positivity)
    rwa [Real.log_div (ne_of_gt hb) (ne_of_gt hs)] at hle
  have hab : a / s + b / s = 2 := by
    rw [hs_def]; field_simp
  linarith

/-- The per-outcome strict inequality behind the strict concavity of the PTX
objective: the integrand `t ↦ t r' − β t log (t / p) + γ d log t` is strictly
concave in `t > 0` as soon as `β > 0`. -/
theorem ptx_term_midpoint_lt {β γ dy py a b r' : ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ) (hdy : 0 ≤ dy)
    (hpy : 0 < py) (ha : 0 < a) (hb : 0 < b) (hab : a ≠ b) :
    ((a * r' - β * (a * Real.log (a / py)) + γ * (dy * Real.log a))
      + (b * r' - β * (b * Real.log (b / py)) + γ * (dy * Real.log b))) / 2
      < (a + b) / 2 * r' - β * ((a + b) / 2 * Real.log ((a + b) / 2 / py))
          + γ * (dy * Real.log ((a + b) / 2)) := by
  have hs : 0 < (a + b) / 2 := by linarith
  have hsplit : ∀ t : ℝ, 0 < t → Real.log (t / py) = Real.log t - Real.log py :=
    fun t ht => Real.log_div (ne_of_gt ht) (ne_of_gt hpy)
  rw [hsplit a ha, hsplit b hb, hsplit ((a + b) / 2) hs]
  have hconv := mul_log_midpoint_lt ha hb hab
  have hlog := log_midpoint_le ha hb
  nlinarith [mul_le_mul_of_nonneg_left hlog (mul_nonneg hγ hdy),
    mul_lt_mul_of_pos_left hconv hβ]

/-! ## Strict concavity of the PTX objective, and uniqueness of the optimum -/

/-- The PTX objective written as a single sum over the outcome space. -/
theorem objectivePTX_eq_sum {β γ : ℝ} {r p d q : Ω → ℝ} :
    objectivePTX β γ r p d q
      = ∑ y, (q y * r y - β * (q y * Real.log (q y / p y)) + γ * (d y * Real.log (q y))) := by
  simp only [objectivePTX, objective, mean, klDiv, Finset.mul_sum, Finset.sum_add_distrib,
    Finset.sum_sub_distrib]

/-- The midpoint of two positive probability vectors is a positive probability
vector. -/
theorem IsPosDist.midpoint {q₁ q₂ : Ω → ℝ} (h₁ : IsPosDist q₁) (h₂ : IsPosDist q₂) :
    IsPosDist (fun y => (q₁ y + q₂ y) / 2) where
  pos y := by have := h₁.pos y; have := h₂.pos y; linarith
  total := by
    rw [← Finset.sum_div, Finset.sum_add_distrib, h₁.total, h₂.total]
    norm_num

/-- **Strict midpoint concavity of the PTX objective.**  For `β > 0`, `γ ≥ 0` and
a nonnegative pretraining vector `d`, the value at the midpoint of two *distinct*
positive policies strictly exceeds the average of the two values. -/
theorem objectivePTX_midpoint_lt {β γ : ℝ} {r p d q₁ q₂ : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hd : ∀ y, 0 ≤ d y) (hp : ∀ y, 0 < p y)
    (h₁ : IsPosDist q₁) (h₂ : IsPosDist q₂) (hne : q₁ ≠ q₂) :
    (objectivePTX β γ r p d q₁ + objectivePTX β γ r p d q₂) / 2
      < objectivePTX β γ r p d (fun y => (q₁ y + q₂ y) / 2) := by
  obtain ⟨y₀, hy₀⟩ : ∃ y, q₁ y ≠ q₂ y := by
    by_contra h
    push_neg at h
    exact hne (funext h)
  set F : (Ω → ℝ) → Ω → ℝ := fun q y =>
    q y * r y - β * (q y * Real.log (q y / p y)) + γ * (d y * Real.log (q y)) with hF
  have key : ∀ y : Ω, q₁ y ≠ q₂ y →
      (F q₁ y + F q₂ y) / 2 < F (fun z => (q₁ z + q₂ z) / 2) y := fun y hy =>
    ptx_term_midpoint_lt hβ hγ (hd y) (hp y) (h₁.pos y) (h₂.pos y) hy
  have weak : ∀ y : Ω, (F q₁ y + F q₂ y) / 2 ≤ F (fun z => (q₁ z + q₂ z) / 2) y := by
    intro y
    by_cases hy : q₁ y = q₂ y
    · have hmid : (q₁ y + q₂ y) / 2 = q₁ y := by rw [hy]; ring
      have e1 : F q₂ y = F q₁ y := by simp only [hF, hy]
      have e2 : F (fun z => (q₁ z + q₂ z) / 2) y = F q₁ y := by simp only [hF, hmid]
      rw [e1, e2]
      linarith
    · exact (key y hy).le
  have hsum : ∑ y, (F q₁ y + F q₂ y) / 2 < ∑ y, F (fun z => (q₁ z + q₂ z) / 2) y :=
    Finset.sum_lt_sum (fun y _ => weak y) ⟨y₀, Finset.mem_univ _, key y₀ hy₀⟩
  have hl : ∑ y, (F q₁ y + F q₂ y) / 2
      = (objectivePTX β γ r p d q₁ + objectivePTX β γ r p d q₂) / 2 := by
    rw [objectivePTX_eq_sum, objectivePTX_eq_sum, ← Finset.sum_add_distrib, ← Finset.sum_div]
  rw [hl, ← objectivePTX_eq_sum] at hsum
  exact hsum

/-- **Uniqueness of the PTX optimum.**  For `β > 0`, `γ ≥ 0` and a nonnegative
pretraining vector, two maximisers of the PTX objective over the positive
policies coincide.  This is what licenses the notation `q*_γ` used in the
comparative statics of `Algebra.RLHFPTXMonotone`. -/
theorem ptx_optimum_unique {β γ : ℝ} {r p d q₁ q₂ : Ω → ℝ} (hβ : 0 < β) (hγ : 0 ≤ γ)
    (hd : ∀ y, 0 ≤ d y) (hp : ∀ y, 0 < p y) (h₁ : IsPosDist q₁) (h₂ : IsPosDist q₂)
    (hmax₁ : ∀ q, IsPosDist q → objectivePTX β γ r p d q ≤ objectivePTX β γ r p d q₁)
    (hmax₂ : ∀ q, IsPosDist q → objectivePTX β γ r p d q ≤ objectivePTX β γ r p d q₂) :
    q₁ = q₂ := by
  by_contra hne
  have hmid := h₁.midpoint h₂
  have hlt := objectivePTX_midpoint_lt (r := r) hβ hγ hd hp h₁ h₂ hne
  have hA := hmax₁ q₂ h₂
  have hB := hmax₂ q₁ h₁
  have hM := hmax₁ _ hmid
  linarith

end RLHF