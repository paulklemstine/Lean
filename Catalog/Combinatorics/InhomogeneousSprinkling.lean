/-
# Inhomogeneous sprinkling and strict Margulis–Russo positivity

This file merges the two deepenings of the catalog Bernoulli theory: the
sprinkling/thinning calculus of `Catalog/Combinatorics/BernoulliSprinkling.lean`
and the site-dependent densities of
`Catalog/Combinatorics/InhomogeneousBernoulli.lean`.

The coordinatewise pushforward formula `sum_prod_pushforward` is applied with a
*different* pair weight at every site, which produces the inhomogeneous
superposition and intersection laws

* `sum_weightVec_or`: densities combine as `p v + r v - p v * r v`;
* `sum_weightVec_and`: densities combine as `p v * r v`,

and hence the two dual product bounds `bernProbVec_and_le`, `bernProbVec_or_ge`
for increasing events, together with their `k`-fold iterates
`bernProbVec_pow_le` and `one_sub_bernProbVec_sprinkle_pow`, which are the
inhomogeneous forms of the `k`-th root trick.

Finally the Margulis–Russo formula is sharpened: for a nondegenerate increasing
event and a strictly interior density vector some site has *positive* pivotal
probability, so the probability strictly increases in that coordinate
(`exists_deriv_bernProbVec_pos`).

## Main results

* `sum_weightVec_pair`, `sum_weightVec_or`, `sum_weightVec_and`.
* `bernProbVec_and_le`, `bernProbVec_or_ge`.
* `bernProbVec_pow_le`, `one_sub_bernProbVec_sprinkle_pow`.
* `weightVec_pos`, `bernProbVec_pos`: strict positivity in the interior.
* `exists_deriv_bernProbVec_pos`: strict Margulis–Russo positivity.
* `bernProbVec_strictMono_coord`: strict monotonicity in a pivotal coordinate.
-/

import Combinatorics.InhomogeneousBernoulli

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The inhomogeneous superposition formula -/

omit [DecidableEq ι] in
/-- The joint weight of two independent inhomogeneous configurations is the
product of the site pair weights. -/
theorem weightVec_mul_weightVec_eq_prod (p r : ι → ℝ) (η ξ : ι → Bool) :
    weightVec p η * weightVec r ξ = ∏ v, pairWeight (p v) (r v) (η v, ξ v) := by
  rw [weightVec, weightVec, ← Finset.prod_mul_distrib]
  rfl

/-- **Two-source superposition, site by site.**  If at every site the pair
weights push forward under `g` to the Bernoulli weights of density `q v`, then a
`p`-configuration and an independent `r`-configuration combine coordinatewise
into a `q`-configuration. -/
theorem sum_weightVec_pair (p r q : ι → ℝ) (g : Bool → Bool → Bool)
    (hg : ∀ v : ι, ∀ b : Bool,
      (∑ k ∈ univ.filter (fun k : Bool × Bool => g k.1 k.2 = b),
          pairWeight (p v) (r v) k) = if b then q v else 1 - q v)
    (f : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool,
        weightVec p η * weightVec r ξ * f (fun v => g (η v) (ξ v))
      = ∑ ζ : ι → Bool, weightVec q ζ * f ζ := by
  classical
  have h1 : ∑ η : ι → Bool, ∑ ξ : ι → Bool,
      weightVec p η * weightVec r ξ * f (fun v => g (η v) (ξ v))
      = ∑ c : ι → Bool × Bool, (∏ v, pairWeight (p v) (r v) (c v)) *
          f (fun v => g (c v).1 (c v).2) := by
    rw [← sum_sum_eq_sum_pair (fun v => pairWeight (p v) (r v))
      (fun c => f (fun v => g (c v).1 (c v).2))]
    exact Finset.sum_congr rfl fun η _ => Finset.sum_congr rfl fun ξ _ => by
      rw [weightVec_mul_weightVec_eq_prod]
  rw [h1, sum_prod_pushforward (fun v => pairWeight (p v) (r v))
    (fun k => g k.1 k.2) f]
  refine Finset.sum_congr rfl fun ζ _ => ?_
  congr 1
  rw [weightVec]
  exact Finset.prod_congr rfl fun v _ => hg v (ζ v)

/-- **Inhomogeneous sprinkling identity.** -/
theorem sum_weightVec_or (p r : ι → ℝ) (f : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool,
        weightVec p η * weightVec r ξ * f (fun v => η v || ξ v)
      = ∑ ζ : ι → Bool, weightVec (fun v => p v + r v - p v * r v) ζ * f ζ := by
  refine sum_weightVec_pair p r _ (fun a b => a || b) (fun v b => ?_) f
  cases b <;>
    · simp [Finset.sum_filter, Fintype.sum_prod_type, pairWeight]
      ring

/-- **Inhomogeneous thinning identity.** -/
theorem sum_weightVec_and (p r : ι → ℝ) (f : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool,
        weightVec p η * weightVec r ξ * f (fun v => η v && ξ v)
      = ∑ ζ : ι → Bool, weightVec (fun v => p v * r v) ζ * f ζ := by
  refine sum_weightVec_pair p r _ (fun a b => a && b) (fun v b => ?_) f
  cases b
  · simp [Finset.sum_filter, Fintype.sum_prod_type, pairWeight]
    ring
  · simp [Finset.sum_filter, Fintype.sum_prod_type, pairWeight]

/-- A weighted double sum of a product factorizes, inhomogeneous version. -/
theorem sum_sum_mul_factor_vec (p r : ι → ℝ) (u w : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, ∑ ξ : ι → Bool, weightVec p η * weightVec r ξ * (u η * w ξ)
      = (∑ η : ι → Bool, weightVec p η * u η) *
          (∑ ξ : ι → Bool, weightVec r ξ * w ξ) := by
  rw [Finset.sum_mul_sum]
  exact Finset.sum_congr rfl fun η _ => Finset.sum_congr rfl fun ξ _ => by ring

/-! ## The dual product bounds for density vectors -/

/-- **Inhomogeneous thinning bound.** -/
theorem bernProbVec_and_le {p r : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    (hr0 : ∀ v, 0 ≤ r v) (hr1 : ∀ v, r v ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    bernProbVec (fun v => p v * r v) A ≤ bernProbVec p A * bernProbVec r A := by
  classical
  have hkey := sum_weightVec_and (ι := ι) p r (A.indicator (fun _ => (1 : ℝ)))
  have hle : ∑ η : ι → Bool, ∑ ξ : ι → Bool,
      weightVec p η * weightVec r ξ *
        A.indicator (fun _ => (1 : ℝ)) (fun v => η v && ξ v)
      ≤ ∑ η : ι → Bool, ∑ ξ : ι → Bool, weightVec p η * weightVec r ξ *
        (A.indicator (fun _ => (1 : ℝ)) η * A.indicator (fun _ => (1 : ℝ)) ξ) := by
    refine Finset.sum_le_sum fun η _ => Finset.sum_le_sum fun ξ _ => ?_
    exact mul_le_mul_of_nonneg_left (indicator_and_le hA η ξ)
      (mul_nonneg (weightVec_nonneg hp0 hp1 η) (weightVec_nonneg hr0 hr1 ξ))
  rw [hkey, sum_sum_mul_factor_vec] at hle
  rw [bernProbVec_eq_sum_mul_indicator, bernProbVec_eq_sum_mul_indicator,
    bernProbVec_eq_sum_mul_indicator]
  exact hle

/-- **Inhomogeneous sprinkling bound.** -/
theorem bernProbVec_or_ge {p r : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    (hr0 : ∀ v, 0 ≤ r v) (hr1 : ∀ v, r v ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) :
    1 - bernProbVec (fun v => p v + r v - p v * r v) A ≤
      (1 - bernProbVec p A) * (1 - bernProbVec r A) := by
  classical
  have hkey := sum_weightVec_or (ι := ι) p r (Aᶜ.indicator (fun _ => (1 : ℝ)))
  have hle : ∑ η : ι → Bool, ∑ ξ : ι → Bool,
      weightVec p η * weightVec r ξ *
        Aᶜ.indicator (fun _ => (1 : ℝ)) (fun v => η v || ξ v)
      ≤ ∑ η : ι → Bool, ∑ ξ : ι → Bool, weightVec p η * weightVec r ξ *
        (Aᶜ.indicator (fun _ => (1 : ℝ)) η * Aᶜ.indicator (fun _ => (1 : ℝ)) ξ) := by
    refine Finset.sum_le_sum fun η _ => Finset.sum_le_sum fun ξ _ => ?_
    exact mul_le_mul_of_nonneg_left (indicator_compl_or_le hA η ξ)
      (mul_nonneg (weightVec_nonneg hp0 hp1 η) (weightVec_nonneg hr0 hr1 ξ))
  rw [hkey, sum_sum_mul_factor_vec] at hle
  rw [← bernProbVec_eq_sum_mul_indicator, ← bernProbVec_eq_sum_mul_indicator,
    ← bernProbVec_eq_sum_mul_indicator] at hle
  have e1 : bernProbVec (fun v => p v + r v - p v * r v) Aᶜ
      = 1 - bernProbVec (fun v => p v + r v - p v * r v) A := by
    have := bernProbVec_add_compl (ι := ι) (fun v => p v + r v - p v * r v) A
    linarith
  have e2 : bernProbVec p Aᶜ = 1 - bernProbVec p A := by
    have := bernProbVec_add_compl (ι := ι) p A; linarith
  have e3 : bernProbVec r Aᶜ = 1 - bernProbVec r A := by
    have := bernProbVec_add_compl (ι := ι) r A; linarith
  rwa [e1, e2, e3] at hle

/-! ## The inhomogeneous exponential laws -/

/-- **Inhomogeneous exponential thinning law.** -/
theorem bernProbVec_pow_le {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    {A : Set (ι → Bool)} (hA : IsIncreasing A) (k : ℕ) :
    bernProbVec (fun v => p v ^ k) A ≤ (bernProbVec p A) ^ k := by
  induction k with
  | zero =>
    simpa using bernProbVec_le_one (ι := ι) (p := fun _ => (1 : ℝ))
      (fun _ => zero_le_one) (fun _ => le_rfl) A
  | succ m ih =>
    have hpm0 : ∀ v, 0 ≤ p v ^ m := fun v => pow_nonneg (hp0 v) m
    have hpm1 : ∀ v, p v ^ m ≤ 1 := fun v => pow_le_one₀ (hp0 v) (hp1 v)
    have hstep := bernProbVec_and_le (ι := ι) hp0 hp1 hpm0 hpm1 hA
    have hnn : 0 ≤ bernProbVec p A := bernProbVec_nonneg hp0 hp1 A
    have hrw : (fun v => p v ^ (m + 1)) = fun v => p v * p v ^ m := by
      funext v; rw [pow_succ, mul_comm]
    calc bernProbVec (fun v => p v ^ (m + 1)) A
        = bernProbVec (fun v => p v * p v ^ m) A := by rw [hrw]
      _ ≤ bernProbVec p A * bernProbVec (fun v => p v ^ m) A := hstep
      _ ≤ bernProbVec p A * (bernProbVec p A) ^ m :=
          mul_le_mul_of_nonneg_left ih hnn
      _ = (bernProbVec p A) ^ (m + 1) := by ring

/-- **Inhomogeneous exponential sprinkling law** (`k`-th root trick with
site-dependent densities). -/
theorem one_sub_bernProbVec_sprinkle_pow {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v)
    (hp1 : ∀ v, p v ≤ 1) {A : Set (ι → Bool)} (hA : IsIncreasing A) (k : ℕ) :
    1 - bernProbVec (fun v => 1 - (1 - p v) ^ k) A ≤ (1 - bernProbVec p A) ^ k := by
  induction k with
  | zero =>
    have hzero : (fun v : ι => 1 - (1 - p v) ^ 0) = fun _ : ι => (0 : ℝ) := by
      funext v; norm_num
    rw [hzero]
    simp only [pow_zero]
    have := bernProbVec_nonneg (ι := ι) (p := fun _ : ι => (0 : ℝ))
      (fun _ => le_rfl) (fun _ => zero_le_one) A
    linarith
  | succ m ih =>
    have hq0 : ∀ v, 0 ≤ 1 - (1 - p v) ^ m := fun v => by
      have : (1 - p v) ^ m ≤ 1 := pow_le_one₀ (by linarith [hp1 v]) (by linarith [hp0 v])
      linarith
    have hq1 : ∀ v, 1 - (1 - p v) ^ m ≤ 1 := fun v => by
      have : 0 ≤ (1 - p v) ^ m := pow_nonneg (by linarith [hp1 v]) m
      linarith
    have hstep := bernProbVec_or_ge (ι := ι) hp0 hp1 hq0 hq1 hA
    have hsum : (fun v => p v + (1 - (1 - p v) ^ m) - p v * (1 - (1 - p v) ^ m))
        = fun v => 1 - (1 - p v) ^ (m + 1) := by
      funext v; ring
    rw [hsum] at hstep
    have hnn : 0 ≤ 1 - bernProbVec p A := by
      have := bernProbVec_le_one hp0 hp1 A; linarith
    calc 1 - bernProbVec (fun v => 1 - (1 - p v) ^ (m + 1)) A
        ≤ (1 - bernProbVec p A) * (1 - bernProbVec (fun v => 1 - (1 - p v) ^ m) A) :=
          hstep
      _ ≤ (1 - bernProbVec p A) * (1 - bernProbVec p A) ^ m :=
          mul_le_mul_of_nonneg_left ih hnn
      _ = (1 - bernProbVec p A) ^ (m + 1) := by ring

/-! ## Strict Margulis–Russo positivity -/

omit [DecidableEq ι] in
/-- In the open interior every configuration has positive weight. -/
theorem weightVec_pos {p : ι → ℝ} (hp0 : ∀ v, 0 < p v) (hp1 : ∀ v, p v < 1)
    (η : ι → Bool) : 0 < weightVec p η := by
  refine Finset.prod_pos fun v _ => ?_
  by_cases h : η v = true
  · simpa [h] using hp0 v
  · simp only [Bool.not_eq_true] at h
    simp only [h, Bool.false_eq_true, if_false]
    linarith [hp1 v]

/-- In the open interior every nonempty event has positive probability. -/
theorem bernProbVec_pos {p : ι → ℝ} (hp0 : ∀ v, 0 < p v) (hp1 : ∀ v, p v < 1)
    {A : Set (ι → Bool)} (hne : A.Nonempty) : 0 < bernProbVec p A := by
  obtain ⟨η, hη⟩ := hne
  refine Finset.sum_pos' (fun ζ _ => Set.indicator_nonneg
    (fun x _ => (weightVec_pos hp0 hp1 x).le) ζ) ⟨η, Finset.mem_univ η, ?_⟩
  rw [Set.indicator_of_mem hη]
  exact weightVec_pos hp0 hp1 η

/-- **Strict Margulis–Russo positivity.**  A nondegenerate increasing event has a
site whose pivotal probability, i.e. whose Margulis–Russo partial derivative, is
strictly positive at every interior density vector. -/
theorem exists_deriv_bernProbVec_pos {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hfalse : (fun _ => false) ∉ A) {p : ι → ℝ}
    (hp0 : ∀ v, 0 < p v) (hp1 : ∀ v, p v < 1) :
    ∃ v : ι, 0 < deriv (fun s : ℝ => bernProbVec (Function.update p v s) A) (p v) := by
  obtain ⟨η, v, hηA, hv, hoff⟩ := exists_pivotal_config hne hfalse
  refine ⟨v, ?_⟩
  rw [deriv_bernProbVec hA]
  refine bernProbVec_pos hp0 hp1 ⟨η, ?_, hoff⟩
  rwa [Function.update_eq_self_iff.mpr hv.symm]

/-- **Strict monotonicity in a pivotal coordinate.**  If the site `v` is pivotal
for some configuration, then raising the density at `v` strictly increases the
probability of the increasing event. -/
theorem bernProbVec_strictMono_coord {A : Set (ι → Bool)} (hA : IsIncreasing A)
    {p : ι → ℝ} (hp0 : ∀ u, 0 < p u) (hp1 : ∀ u, p u < 1) (v : ι)
    (hpiv : (pivotalSet A v).Nonempty) {s t : ℝ} (hst : s < t) :
    bernProbVec (Function.update p v s) A < bernProbVec (Function.update p v t) A := by
  have hslope : 0 < sideSum p v A true - sideSum p v A false := by
    rw [sideSum_sub_eq_pivotal hA]
    exact bernProbVec_pos hp0 hp1 hpiv
  rw [bernProbVec_update_affine, bernProbVec_update_affine]
  nlinarith


/-- **Inhomogeneous threshold window.**  If the failure density at every site is
at least the `k`-th power of the original failure density, the failure
probability of an increasing event is at most the `k`-th power of the original
failure probability.  This removes the homogeneity assumption from the `k`-th
root trick. -/
theorem one_sub_bernProbVec_le_pow {p q : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v)
    (hp1 : ∀ v, p v ≤ 1) (hq1 : ∀ v, q v ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) (k : ℕ) (hdom : ∀ v, 1 - q v ≤ (1 - p v) ^ k) :
    1 - bernProbVec q A ≤ (1 - bernProbVec p A) ^ k := by
  have hcurve0 : ∀ v, 0 ≤ 1 - (1 - p v) ^ k := fun v => by
    have : (1 - p v) ^ k ≤ 1 := pow_le_one₀ (by linarith [hp1 v]) (by linarith [hp0 v])
    linarith
  have hle : ∀ v, 1 - (1 - p v) ^ k ≤ q v := fun v => by linarith [hdom v]
  have hmono : bernProbVec (fun v => 1 - (1 - p v) ^ k) A ≤ bernProbVec q A :=
    bernProbVec_mono hA hcurve0 hq1 hle
  have hstep := one_sub_bernProbVec_sprinkle_pow hp0 hp1 hA k
  linarith

end BernoulliThresholdCoupling