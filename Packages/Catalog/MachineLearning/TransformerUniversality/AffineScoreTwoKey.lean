import Mathlib

/-!
# Affine-score softmax heads: the amplitude–temperature law

`Catalog/MachineLearning/TransformerUniversality/SoftmaxResolution.lean` refuted the conjectured
`Ω(1/N)` resolution barrier for softmax lookup by exhibiting a **two-key** head that
approximates the identity on `[0,1]` to arbitrary accuracy.  The construction used the logit
`log((x+ε)/(1+ε−x))`, an unbounded, task-specific nonlinearity that a real attention layer
cannot produce, and Conjecture 6 of `FUTURE_DIRECTIONS.md` therefore proposed the *affine*
score family as the honest resource class, predicting a `Θ(N^{-2})` error barrier there — in
particular a strictly positive barrier already at `N = 2`.

**This file refutes that conjecture too, and replaces it by a proved conservation law.**

The genuinely affine two-key head, with scores `aᵢx + bᵢ` and values `vᵢ`, computes
`v₂ + (v₁ − v₂)·σ((a₁−a₂)x + (b₁−b₂))` (`twoKeyHead_eq`).  Choosing score scale `a` and values
`1/2 ± 2/a` gives, in closed form, `1/2 + (2/a)·tanh(a(x−1/2)/2)` (`idHead_closed_form`), whose
uniform error against the identity on `[0,1]` is at most `a²/96` (`idHead_error_le`).  So the
affine class has **zero** infimal error (`affine_two_key_eps`), and the conjectured barrier is
false (`no_affine_two_key_barrier`).

What *is* true is a conservation law between the two resources the construction spends.  If any
affine two-key head matches the identity within `ε` at both endpoints of `[0,1]`, then

  `|v₁ − v₂| · |a₁ − a₂| ≥ 4(1 − 2ε)`   (`amplitude_times_scale_ge`),

because the logistic is exactly `1/4`-Lipschitz (`abs_logistic_sub_le`).  The tuned head spends
amplitude `4/a` at score scale `a`, i.e. product exactly `4` (`idHead_amplitude`), so the law is
**sharp**: the construction is optimal, not merely order-optimal
(`amplitude_law_is_sharp`).  Accuracy in the affine class is therefore bought by **amplitude
blow-up**, not by resolution — exactly the resource that a bounded-parameter transformer does
not have.

Analytic groundwork proved here from scratch, since Mathlib's `tanh` API is thin:

* `tanh_eq_exp` — `tanh u = (e^{2u} − 1)/(e^{2u} + 1)`;
* `hasDerivAt_tanh'` — `tanh′ = 1 − tanh²`, hence `abs_tanh_le_abs` (`tanh` is 1-Lipschitz);
* `abs_tanh_sub_le_cube` — the **sharp global cubic bound** `|tanh u − u| ≤ |u|³/3`, by
  monotonicity of `u ↦ u³/3 − (u − tanh u)`, whose derivative `u² − tanh²u` is nonnegative;
* `hasDerivAt_logistic`, `abs_logistic_sub_le` — the logistic is `1/4`-Lipschitz, the optimal
  constant, since `σ′ = e^s/(e^s+1)² ≤ 1/4` by AM–GM.
-/

open scoped BigOperators
open Real

namespace AffineScoreTwoKey

/-! ## Analytic groundwork: `tanh` and the logistic -/

/-- `tanh` in exponential form. -/
theorem tanh_eq_exp (u : ℝ) : Real.tanh u = (Real.exp (2 * u) - 1) / (Real.exp (2 * u) + 1) := by
  have h1 : Real.exp (2 * u) = Real.exp u * Real.exp u := by rw [← Real.exp_add]; ring_nf
  have hu : (0 : ℝ) < Real.exp u := Real.exp_pos u
  have h2 : Real.exp (-u) = (Real.exp u)⁻¹ := Real.exp_neg u
  rw [Real.tanh_eq_sinh_div_cosh, Real.sinh_eq, Real.cosh_eq, h1, h2]
  field_simp

/-- The derivative of `tanh`. -/
theorem hasDerivAt_tanh' (u : ℝ) : HasDerivAt Real.tanh (1 - Real.tanh u ^ 2) u := by
  have hc : Real.cosh u ≠ 0 := (Real.cosh_pos u).ne'
  have h := (Real.hasDerivAt_sinh u).div (Real.hasDerivAt_cosh u) hc
  have heq : (Real.cosh u * Real.cosh u - Real.sinh u * Real.sinh u) / Real.cosh u ^ 2
      = 1 - Real.tanh u ^ 2 := by
    rw [Real.tanh_eq_sinh_div_cosh]; field_simp
  have hfun : Real.tanh = fun x => Real.sinh x / Real.cosh x := funext Real.tanh_eq_sinh_div_cosh
  rw [← heq, hfun]
  exact h

/-- `tanh` is 1-Lipschitz, hence `|tanh u| ≤ |u|`. -/
theorem abs_tanh_le_abs (u : ℝ) : |Real.tanh u| ≤ |u| := by
  have hb : ∀ x ∈ (Set.univ : Set ℝ), ‖1 - Real.tanh x ^ 2‖ ≤ 1 := by
    intro x _
    have h1 : Real.tanh x ^ 2 ≤ 1 := by
      have h := Real.abs_tanh_lt_one x
      nlinarith [sq_abs (Real.tanh x), abs_nonneg (Real.tanh x)]
    have h2 : 0 ≤ Real.tanh x ^ 2 := sq_nonneg _
    rw [Real.norm_eq_abs, abs_le]
    constructor <;> linarith
  have := (convex_univ (𝕜 := ℝ)).norm_image_sub_le_of_norm_hasDerivWithin_le
    (fun x _ => (hasDerivAt_tanh' x).hasDerivWithinAt) hb (Set.mem_univ 0) (Set.mem_univ u)
  simpa [Real.norm_eq_abs] using this

/-- **Sharp cubic bound for `tanh`**, valid on all of `ℝ`: the function
`u ↦ u³/3 − (u − tanh u)` has derivative `u² − tanh²u ≥ 0`, hence is monotone and vanishes at
`0`.  The cubic order (the quadratic term of `tanh` vanishes) is what makes the head error below
quadratic in the score scale rather than linear. -/
theorem abs_tanh_sub_le_cube (u : ℝ) : |Real.tanh u - u| ≤ |u| ^ 3 / 3 := by
  set g : ℝ → ℝ := fun t => t ^ 3 / 3 - (t - Real.tanh t) with hg
  have hgd : ∀ t : ℝ, HasDerivAt g (t ^ 2 - Real.tanh t ^ 2) t := by
    intro t
    have h1 : HasDerivAt (fun x : ℝ => x ^ 3 / 3) (t ^ 2) t := by
      have h := (hasDerivAt_pow 3 t).div_const 3
      convert h using 1
      push_cast; ring
    have h2 : HasDerivAt (fun x : ℝ => x - Real.tanh x) (1 - (1 - Real.tanh t ^ 2)) t :=
      (hasDerivAt_id t).sub (hasDerivAt_tanh' t)
    have h := h1.sub h2
    convert h using 1
    ring
  have hmono : Monotone g := by
    apply monotone_of_deriv_nonneg (fun t => (hgd t).differentiableAt)
    intro t
    rw [(hgd t).deriv]
    have h := abs_tanh_le_abs t
    nlinarith [sq_abs (Real.tanh t), sq_abs t, abs_nonneg (Real.tanh t), abs_nonneg t]
  have hg0 : g 0 = 0 := by simp [hg]
  rcases le_total 0 u with hu | hu
  · have h1 : 0 ≤ g u := by rw [← hg0]; exact hmono hu
    have h2 : Real.tanh u ≤ u := by
      have h := abs_tanh_le_abs u
      rw [abs_of_nonneg hu] at h
      linarith [(abs_le.mp h).2]
    rw [abs_of_nonpos (by linarith), abs_of_nonneg hu]
    simp only [hg] at h1
    linarith
  · have h1 : g u ≤ 0 := by rw [← hg0]; exact hmono hu
    have h2 : u ≤ Real.tanh u := by
      have h := abs_tanh_le_abs u
      rw [abs_of_nonpos hu] at h
      linarith [(abs_le.mp h).1]
    rw [abs_of_nonneg (by linarith), abs_of_nonpos hu]
    simp only [hg] at h1
    linarith

/-- The logistic (two-key softmax) function. -/
noncomputable def logistic (s : ℝ) : ℝ := Real.exp s / (Real.exp s + 1)

theorem logistic_eq_tanh (s : ℝ) : logistic s = 1 / 2 + Real.tanh (s / 2) / 2 := by
  have h : Real.tanh (s / 2) = (Real.exp s - 1) / (Real.exp s + 1) := by
    have h2 : 2 * (s / 2) = s := by ring
    rw [tanh_eq_exp, h2]
  have hpos : (0 : ℝ) < Real.exp s + 1 := by positivity
  rw [logistic, h]
  field_simp
  ring

theorem hasDerivAt_logistic (s : ℝ) :
    HasDerivAt logistic (Real.exp s / (Real.exp s + 1) ^ 2) s := by
  have hE : (0 : ℝ) < Real.exp s + 1 := by positivity
  have h1 : HasDerivAt (fun t => Real.exp t) (Real.exp s) s := Real.hasDerivAt_exp s
  have h2 : HasDerivAt (fun t => Real.exp t + 1) (Real.exp s) s := h1.add_const 1
  have h := h1.div h2 hE.ne'
  convert h using 1
  field_simp
  ring

/-- **The logistic is `1/4`-Lipschitz**, with the optimal constant: `σ′ = e^s/(e^s+1)² ≤ 1/4`
by AM–GM, with equality at `s = 0`. -/
theorem abs_logistic_sub_le (p q : ℝ) : |logistic p - logistic q| ≤ |p - q| / 4 := by
  have hb : ∀ x ∈ (Set.univ : Set ℝ), ‖Real.exp x / (Real.exp x + 1) ^ 2‖ ≤ 1 / 4 := by
    intro x _
    have hE : (0 : ℝ) < Real.exp x := Real.exp_pos x
    rw [Real.norm_eq_abs, abs_of_nonneg (by positivity), div_le_iff₀ (by positivity)]
    nlinarith [sq_nonneg (Real.exp x - 1)]
  have := (convex_univ (𝕜 := ℝ)).norm_image_sub_le_of_norm_hasDerivWithin_le
    (fun x _ => (hasDerivAt_logistic x).hasDerivWithinAt) hb (Set.mem_univ q) (Set.mem_univ p)
  simpa [Real.norm_eq_abs, div_eq_inv_mul, mul_comm] using this

/-! ## The two-key softmax head with affine scores -/

/-- A two-key softmax head with **affine** scores `aᵢ x + bᵢ` and values `vᵢ`. -/
noncomputable def twoKeyHead (a₁ b₁ a₂ b₂ v₁ v₂ x : ℝ) : ℝ :=
  (v₁ * Real.exp (a₁ * x + b₁) + v₂ * Real.exp (a₂ * x + b₂)) /
    (Real.exp (a₁ * x + b₁) + Real.exp (a₂ * x + b₂))

/-- **Reduction to the logit gap.**  Only the difference of the two affine scores matters. -/
theorem twoKeyHead_eq (a₁ b₁ a₂ b₂ v₁ v₂ x : ℝ) :
    twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ x
      = v₂ + (v₁ - v₂) * logistic ((a₁ - a₂) * x + (b₁ - b₂)) := by
  have hA : (0 : ℝ) < Real.exp (a₁ * x + b₁) := Real.exp_pos _
  have hB : (0 : ℝ) < Real.exp (a₂ * x + b₂) := Real.exp_pos _
  have hexp : Real.exp ((a₁ - a₂) * x + (b₁ - b₂))
      = Real.exp (a₁ * x + b₁) / Real.exp (a₂ * x + b₂) := by
    rw [← Real.exp_sub]
    ring_nf
  rw [twoKeyHead, logistic, hexp]
  field_simp
  ring

/-! ## The construction: score scale `a`, amplitude `4/a` -/

/-- The affine two-key head tuned to the identity at score scale `a`: scores `a x − a/2` and
`0`, values `1/2 ± 2/a`. -/
noncomputable def idHead (a x : ℝ) : ℝ :=
  twoKeyHead a (-a / 2) 0 0 (1 / 2 + 2 / a) (1 / 2 - 2 / a) x

/-- **Closed form** of the tuned head. -/
theorem idHead_closed_form {a : ℝ} (ha : a ≠ 0) (x : ℝ) :
    idHead a x = 1 / 2 + (2 / a) * Real.tanh (a * (x - 1 / 2) / 2) := by
  rw [idHead, twoKeyHead_eq, logistic_eq_tanh]
  have harg : (a - 0) * x + (-a / 2 - 0) = a * (x - 1 / 2) := by ring
  rw [harg]
  field_simp
  ring

/-- **Uniform error bound.**  On `[0,1]` the tuned head is within `a²/96` of the identity, for
every score scale `a > 0`.  (Numerically this is the exact leading order: see
`ComputationalEvidence.md` §7.) -/
theorem idHead_error_le {a x : ℝ} (ha : 0 < a) (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    |idHead a x - x| ≤ a ^ 2 / 96 := by
  set u : ℝ := a * (x - 1 / 2) / 2 with hu
  have habs : |u| ≤ a / 4 := by
    rw [hu, abs_div, abs_mul, abs_of_pos ha, abs_of_nonneg (by norm_num : (0 : ℝ) ≤ 2),
      div_le_div_iff₀ (by norm_num) (by norm_num)]
    have hhalf : |x - 1 / 2| ≤ 1 / 2 := by rw [abs_le]; constructor <;> linarith
    nlinarith [abs_nonneg (x - 1 / 2), ha.le]
  have hbound := abs_tanh_sub_le_cube u
  have hxu : x = 1 / 2 + (2 / a) * u := by field_simp [hu]; ring
  have hdiff : idHead a x - x = (2 / a) * (Real.tanh u - u) := by
    rw [idHead_closed_form ha.ne' x, ← hu, hxu]; ring
  rw [hdiff, abs_mul, abs_of_pos (by positivity : (0 : ℝ) < 2 / a)]
  have hcube : |u| ^ 3 ≤ (a / 4) ^ 3 := pow_le_pow_left₀ (abs_nonneg u) habs 3
  calc (2 / a) * |Real.tanh u - u| ≤ (2 / a) * (|u| ^ 3 / 3) :=
        mul_le_mul_of_nonneg_left hbound (by positivity)
    _ ≤ (2 / a) * ((a / 4) ^ 3 / 3) := by
        exact mul_le_mul_of_nonneg_left (by linarith) (by positivity)
    _ = a ^ 2 / 96 := by field_simp; ring

/-- **The affine two-key class has zero infimal error on the identity.**  For every `ε > 0`
there is an affine two-key softmax head uniformly `ε`-close to the identity on `[0,1]`. -/
theorem affine_two_key_eps {eps : ℝ} (heps : 0 < eps) :
    ∃ a₁ b₁ a₂ b₂ v₁ v₂ : ℝ, ∀ x : ℝ, 0 ≤ x → x ≤ 1 →
      |twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ x - x| ≤ eps := by
  set a : ℝ := min 1 eps with hadef
  have ha : 0 < a := lt_min one_pos heps
  have ha1 : a ≤ 1 := min_le_left _ _
  have hae : a ≤ eps := min_le_right _ _
  refine ⟨a, -a / 2, 0, 0, 1 / 2 + 2 / a, 1 / 2 - 2 / a, fun x hx0 hx1 => ?_⟩
  have h := idHead_error_le ha hx0 hx1
  have hsq : a ^ 2 / 96 ≤ eps := by nlinarith
  exact le_trans h hsq

/-- **Refutation of the conjectured affine barrier.**  There is no positive constant that lower
bounds the uniform error of every affine two-key softmax head on the identity. -/
theorem no_affine_two_key_barrier :
    ¬ ∃ c : ℝ, 0 < c ∧ ∀ a₁ b₁ a₂ b₂ v₁ v₂ : ℝ, ∃ x : ℝ, 0 ≤ x ∧ x ≤ 1 ∧
      c ≤ |twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ x - x| := by
  rintro ⟨c, hc, hbar⟩
  obtain ⟨a₁, b₁, a₂, b₂, v₁, v₂, hgood⟩ := affine_two_key_eps (half_pos hc)
  obtain ⟨x, hx0, hx1, hbad⟩ := hbar a₁ b₁ a₂ b₂ v₁ v₂
  have := hgood x hx0 hx1
  linarith

/-! ## The conservation law: amplitude × score scale -/

/-- **Amplitude–temperature conservation law.**  If an affine two-key head matches the identity
within `ε` at both endpoints of `[0,1]`, then the product of its value amplitude and its score
scale is at least `4(1 − 2ε)`. -/
theorem amplitude_times_scale_ge {a₁ b₁ a₂ b₂ v₁ v₂ eps : ℝ}
    (h0 : |twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 0 - 0| ≤ eps)
    (h1 : |twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 1 - 1| ≤ eps) :
    4 * (1 - 2 * eps) ≤ |v₁ - v₂| * |a₁ - a₂| := by
  have e0 : twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 0 = v₂ + (v₁ - v₂) * logistic (b₁ - b₂) := by
    rw [twoKeyHead_eq]; ring_nf
  have e1 : twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 1
      = v₂ + (v₁ - v₂) * logistic ((a₁ - a₂) + (b₁ - b₂)) := by
    rw [twoKeyHead_eq]; ring_nf
  have hgap : 1 - 2 * eps ≤ |twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 1 - twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 0| := by
    have hA := abs_le.mp h0
    have hB := abs_le.mp h1
    rcases le_total (twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 1) (twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 0) with h | h
    · rw [abs_of_nonpos (by linarith)]; linarith [hA.1, hA.2, hB.1, hB.2]
    · rw [abs_of_nonneg (by linarith)]; linarith [hA.1, hA.2, hB.1, hB.2]
  have hdiff : twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 1 - twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 0
      = (v₁ - v₂) * (logistic ((a₁ - a₂) + (b₁ - b₂)) - logistic (b₁ - b₂)) := by
    rw [e0, e1]; ring
  rw [hdiff, abs_mul] at hgap
  have hlip : |logistic ((a₁ - a₂) + (b₁ - b₂)) - logistic (b₁ - b₂)| ≤ |a₁ - a₂| / 4 := by
    have h := abs_logistic_sub_le ((a₁ - a₂) + (b₁ - b₂)) (b₁ - b₂)
    have harg : ((a₁ - a₂) + (b₁ - b₂)) - (b₁ - b₂) = a₁ - a₂ := by ring
    rwa [harg] at h
  have hmono : |v₁ - v₂| * |logistic ((a₁ - a₂) + (b₁ - b₂)) - logistic (b₁ - b₂)|
      ≤ |v₁ - v₂| * (|a₁ - a₂| / 4) := mul_le_mul_of_nonneg_left hlip (abs_nonneg _)
  linarith

/-- The tuned head spends amplitude exactly `4/a` at score scale `a`, so
`amplitude · scale = 4`. -/
theorem idHead_amplitude {a : ℝ} (ha : 0 < a) :
    |(1 / 2 + 2 / a) - (1 / 2 - 2 / a)| * |a - 0| = 4 := by
  have h : (1 / 2 + 2 / a) - (1 / 2 - 2 / a) = 4 / a := by ring
  rw [h, abs_of_pos (by positivity : (0 : ℝ) < 4 / a), sub_zero, abs_of_pos ha]
  field_simp

/-- **The conservation law is sharp.**  For every `ε > 0` there is an affine two-key head that
is `ε`-accurate at both endpoints and whose amplitude–scale product is exactly `4`, so the
constant `4` in `amplitude_times_scale_ge` cannot be improved. -/
theorem amplitude_law_is_sharp {eps : ℝ} (heps : 0 < eps) :
    ∃ a₁ b₁ a₂ b₂ v₁ v₂ : ℝ,
      |twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 0 - 0| ≤ eps ∧
      |twoKeyHead a₁ b₁ a₂ b₂ v₁ v₂ 1 - 1| ≤ eps ∧
      |v₁ - v₂| * |a₁ - a₂| = 4 := by
  set a : ℝ := min 1 eps with hadef
  have ha : 0 < a := lt_min one_pos heps
  have ha1 : a ≤ 1 := min_le_left _ _
  have hae : a ≤ eps := min_le_right _ _
  have hsq : a ^ 2 / 96 ≤ eps := by nlinarith
  refine ⟨a, -a / 2, 0, 0, 1 / 2 + 2 / a, 1 / 2 - 2 / a, ?_, ?_, idHead_amplitude ha⟩
  · exact le_trans (idHead_error_le ha le_rfl zero_le_one) hsq
  · exact le_trans (idHead_error_le ha zero_le_one le_rfl) hsq

end AffineScoreTwoKey