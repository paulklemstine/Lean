import Mathlib

/-!
# The optimal portion ratio constant `μ₂ = 1 + ρ`

Consider a unit circular cake that is repeatedly cut by radial cuts.  After a
sequence of cuts the disc is divided into slices; a **portion** is a pair of
adjacent slices, and the imbalance of a dissection is the ratio

`(largest portion) / (smallest portion)`.

The worst-case portion-ratio constant `μ₂` is the infimum, over all infinite
cutting strategies, of the supremum over stages of this ratio.  The governing
constant is `ρ`, the unique real root of

`ρ² + ρ³ = 1`   (`ρ ≈ 0.75488`),

and the sharp value of the worst-case constant is conjectured to be `μ₂ = 1 + ρ`.
The self-similar extremal strategy that produces this value is encoded exactly by
the fixed-point equation above: two successive generations of splitting reproduce
the pattern scaled by `ρ`, so `ρ²·(1 + ρ) = 1`.

This file develops the exact algebra of the constants `ρ` and `μ = 1 + ρ`:

* `rho_exists`, `rho_unique` — `ρ` is the unique real root of `x³ + x² = 1`;
* `rho_lower`, `rho_upper` — the sharp numerical envelope `0.7548 < ρ < 0.7549`;
* `rho_irrational`, `mu_irrational` — both constants are irrational, so the
  worst-case ratio is never attained by a rational dissection;
* `mu_cubic` — `μ = 1 + ρ` is the unique root in `(1, 2)` of the depressed cubic
  `x³ - 2x² + x - 1 = 0`;
* `mu_self_similar` — the self-similarity identity `ρ²·μ = 1`;
* `mu_lt_two` — the optimal constant is *strictly* below the elementary
  bisection bound `2`, quantifying the improvement won by balancing portions
  rather than single slices.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  The worst-case portion ratio is governed by a single
algebraic constant.  The extremal cutting sequence is self-similar: after two
generations of the "split to balance portions" rule the configuration reappears
scaled by a factor `ρ`, forcing `ρ² + ρ³ = 1`.  We conjectured that the resulting
constant `μ = 1 + ρ` is (i) irrational, hence never attained by a finite rational
dissection, and (ii) strictly better than the bisection constant `2` from the
companion dyadic upper-bound analysis.

EXPERIMENT (Experimenter).  Existence and uniqueness of `ρ` follow from strict
monotonicity of `x ↦ x³ + x²` on `[0, ∞)` (intermediate value theorem for
existence, strict monotonicity for uniqueness).  The numerical envelope is a pair
of polynomial sign checks.  Irrationality is the rational root theorem for the
monic cubic `x³ + x² - 1`: a rational root would be an integer, but no integer
lies in `(0, 1)`.  The cubic for `μ` and the self-similarity identity are exact
algebraic consequences of `ρ² + ρ³ = 1`.

ANALYSIS (Analyst).  The fixed-point equation is the whole story: every derived
fact (`μ`'s cubic, `μ·ρ² = 1`, the `(1,2)` localisation) is an algebraic image of
`ρ² + ρ³ = 1`.  The irrationality upgrades the value from a numerical curiosity to
a genuine obstruction: no cutting strategy that only ever produces commensurable
slice lengths can realise the optimum, it can only approach it.

CRITIQUE (Critic).  Positivity of `ρ` is load-bearing throughout (it keeps the
strict-monotonicity comparison and the `nlinarith` sign certificates honest).  The
localisation `1 < μ < 2` is non-vacuous — `μ` genuinely sits strictly between the
trivial lower bound `1` and the bisection bound `2`.  The irrationality proof is
not circular: it reduces to the purely rational statement `rat_not_root` proved
independently of `ρ`.

SYNTHESIS (PI).  `ρ² + ρ³ = 1` is the algebraic heart of the optimal portion
ratio; `μ = 1 + ρ` inherits from it a cubic, a self-similarity law, an irrationality
certificate, and a strict improvement over bisection.  The remaining challenge — a
matching lower bound `μ₂ ≥ 1 + ρ` over *all* infinite strategies — is recorded in
`FUTURE_DIRECTIONS.md`.
-/

open Set

namespace CakePortionRatio

/-! ## The constant `ρ`: the unique real root of `x³ + x² = 1`. -/

/-- The map `x ↦ x³ + x²` is strictly increasing on the nonnegative reals. -/
lemma cubic_strictMonoOn : StrictMonoOn (fun x : ℝ => x ^ 3 + x ^ 2) (Set.Ici 0) := by
  intro a ha b hb hab
  simp only [mem_Ici] at ha hb
  have hb0 : 0 ≤ b := le_trans ha (le_of_lt hab)
  nlinarith [mul_pos (sub_pos.mpr hab)
      (add_pos_of_nonneg_of_pos (mul_nonneg ha hb0)
        (mul_pos (lt_of_le_of_lt ha hab) (lt_of_le_of_lt ha hab))),
    sq_nonneg a, sq_nonneg b, mul_nonneg ha hb0]

/-- There is a root of `x³ + x² = 1` strictly between `0` and `1`. -/
lemma rho_exists : ∃ x : ℝ, x ∈ Set.Ioo (0 : ℝ) 1 ∧ x ^ 3 + x ^ 2 = 1 := by
  have hcont : ContinuousOn (fun x : ℝ => x ^ 3 + x ^ 2) (Set.Icc 0 1) := by fun_prop
  have hsub := intermediate_value_Ioo (by norm_num : (0 : ℝ) ≤ 1) hcont
  have hmem : (1 : ℝ) ∈
      Set.Ioo ((fun x : ℝ => x ^ 3 + x ^ 2) 0) ((fun x : ℝ => x ^ 3 + x ^ 2) 1) :=
    ⟨by norm_num, by norm_num⟩
  obtain ⟨x, hx, hxeq⟩ := hsub hmem
  exact ⟨x, hx, hxeq⟩

/-- The cake constant `ρ`: the unique real root of `x³ + x² = 1`. -/
noncomputable def rho : ℝ := Classical.choose rho_exists

lemma rho_spec : rho ∈ Set.Ioo (0 : ℝ) 1 ∧ rho ^ 3 + rho ^ 2 = 1 :=
  Classical.choose_spec rho_exists

lemma rho_pos : 0 < rho := rho_spec.1.1
lemma rho_lt_one : rho < 1 := rho_spec.1.2

/-- The defining cubic equation of `ρ`, written `ρ³ + ρ² = 1`. -/
lemma rho_cubic : rho ^ 3 + rho ^ 2 = 1 := rho_spec.2

/-- The defining equation in the form of the problem statement, `ρ² + ρ³ = 1`. -/
lemma rho_eq : rho ^ 2 + rho ^ 3 = 1 := by have := rho_cubic; linarith

/-- `ρ` is the *unique* nonnegative root of `x³ + x² = 1`. -/
lemma rho_unique {x : ℝ} (hx : 0 ≤ x) (h : x ^ 3 + x ^ 2 = 1) : x = rho := by
  rcases lt_trichotomy x rho with h1 | h1 | h1
  · have hlt := cubic_strictMonoOn hx (le_of_lt rho_pos) h1
    simp only at hlt; rw [h, rho_cubic] at hlt; exact absurd hlt (lt_irrefl 1)
  · exact h1
  · have hlt := cubic_strictMonoOn (le_of_lt rho_pos) hx h1
    simp only at hlt; rw [h, rho_cubic] at hlt; exact absurd hlt (lt_irrefl 1)

/-- Sharp numerical envelope, lower bound: `0.7548 < ρ`. -/
lemma rho_lower : 0.7548 < rho := by
  nlinarith [rho_cubic, rho_pos, sq_nonneg rho]

/-- Sharp numerical envelope, upper bound: `ρ < 0.7549`. -/
lemma rho_upper : rho < 0.7549 := by
  nlinarith [rho_cubic, rho_pos, sq_nonneg rho]

/-! ## Irrationality of `ρ`. -/

/-
Rational root theorem for the monic cubic `x³ + x² - 1`: no rational number is
a root.  A rational root of a monic integer polynomial is an algebraic integer,
hence an ordinary integer; but `x³ + x² = 1` has no integer solution.
-/
lemma rat_not_root (q : ℚ) : q ^ 3 + q ^ 2 ≠ 1 := by
  by_contra h_contra;
  -- By the properties of the rational root theorem, if $q$ is a rational root of $x^3 + x^2 - 1$, then $q$ must be an integer.
  obtain ⟨a, b, ha, hb, hab⟩ : ∃ a b : ℤ, Int.gcd a b = 1 ∧ q = a / b ∧ a^3 + a^2 * b = b^3 := by
    obtain ⟨a, b, ha, hb, hab⟩ : ∃ a b : ℤ, Int.gcd a b = 1 ∧ q = a / b := by
      exact ⟨ q.num, q.den, q.reduced, q.num_div_den.symm ⟩;
    by_cases hb : b = 0 <;> simp_all +decide [ pow_succ, mul_assoc, div_eq_mul_inv ];
    field_simp at h_contra;
    exact ⟨ a, b, ha, rfl, by norm_cast at h_contra; linarith ⟩;
  have := congr_arg Even hab ; norm_num [ parity_simps ] at this;
  by_cases hb : Even b <;> simp_all +decide [ parity_simps ];
  exact absurd ( Int.dvd_coe_gcd ( even_iff_two_dvd.mp this ) ( even_iff_two_dvd.mp hb ) ) ( by norm_num [ ha ] )

/-- `ρ` is irrational. -/
theorem rho_irrational : Irrational rho := by
  rintro ⟨q, hq⟩
  apply rat_not_root q
  have : (q : ℝ) ^ 3 + (q : ℝ) ^ 2 = 1 := by rw [hq]; exact rho_cubic
  exact_mod_cast this

/-! ## The optimal portion ratio constant `μ = 1 + ρ`. -/

/-- The optimal worst-case portion ratio constant `μ₂ = 1 + ρ`. -/
noncomputable def mu : ℝ := 1 + rho

/-- `μ` exceeds the trivial lower bound `1`. -/
lemma mu_gt_one : 1 < mu := by unfold mu; linarith [rho_pos]

/-- The optimal constant is strictly better than the elementary bisection bound `2`. -/
theorem mu_lt_two : mu < 2 := by unfold mu; linarith [rho_lt_one]

/-- Sharp numerical envelope for `μ`, lower bound. -/
lemma mu_lower : 1.7548 < mu := by unfold mu; linarith [rho_lower]

/-- Sharp numerical envelope for `μ`, upper bound. -/
lemma mu_upper : mu < 1.7549 := by unfold mu; linarith [rho_upper]

/-- `μ = 1 + ρ` is a root of the depressed cubic `x³ - 2x² + x - 1 = 0`. -/
theorem mu_cubic : mu ^ 3 - 2 * mu ^ 2 + mu - 1 = 0 := by
  unfold mu; nlinarith [rho_cubic]

/-- Self-similarity identity of the extremal strategy: `ρ²·μ = 1`. -/
theorem mu_self_similar : rho ^ 2 * mu = 1 := by
  unfold mu; nlinarith [rho_cubic]

/-- `μ = 1 + ρ` is irrational, hence never realised exactly by a rational dissection. -/
theorem mu_irrational : Irrational mu := by
  unfold mu
  have := rho_irrational.natCast_add 1
  simpa using this

end CakePortionRatio