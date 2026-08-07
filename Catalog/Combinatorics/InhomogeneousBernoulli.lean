/-
# Inhomogeneous Bernoulli site measures and the Margulis–Russo formula

The catalog files `Catalog/Combinatorics/BernoulliThresholdCoupling.lean`,
`Catalog/Combinatorics/FiniteRussoFormula.lean` and
`Catalog/Combinatorics/HarrisFKGThresholdCoupling.lean` develop the Bernoulli
site measure of a *single* density `p`.  This file extends the whole theory to
a **site-dependent density vector** `p : ι → ℝ`, where site `v` is open with
probability `p v` independently of the others.  The homogeneous theory is
recovered by specializing to a constant vector (`bernProbVec_const`).

The central new result is the genuine **Margulis–Russo formula**: the
probability of an increasing event is an affine function of each single
coordinate `p v`, with slope exactly the probability that `v` is pivotal,

`hasDerivAt_bernProbVec : HasDerivAt (fun t => bernProbVec (update p v t) A)
    (bernProbVec p (pivotalSet A v)) t`.

Since the slope is a probability, it is nonnegative, which gives the
**coordinatewise stochastic monotonicity** `bernProbVec_mono` of increasing
events — a strictly stronger statement than monotonicity along the diagonal
proved in the catalog, and the basic comparison tool of inhomogeneous
percolation.  The Harris/FKG inequality is also upgraded to arbitrary density
vectors (`bernProbVec_harris`), and the homogeneous Russo formula is recovered
as the diagonal sum of the partial derivatives (`deriv_bernProb_eq_sum_partials`).

## Main results

* `weightVec`, `bernProbVec`: the inhomogeneous product weight and probability.
* `sum_weightVec`, `bernProbVec_univ`, `bernProbVec_add_compl`: normalization.
* `bernProbVec_update_affine`: exact affine dependence on a single coordinate.
* `hasDerivAt_bernProbVec`: the Margulis–Russo formula.
* `bernProbVec_update_mono`, `bernProbVec_mono`: coordinatewise monotonicity of
  increasing events.
* `bernProbVec_harris`: the FKG inequality for arbitrary density vectors.
* `deriv_bernProb_eq_sum_partials`: the homogeneous Russo derivative is the sum
  of the inhomogeneous partial derivatives on the diagonal.
-/

import Combinatorics.BernoulliThresholdWindow

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## The inhomogeneous product weight -/

/-- The product weight of a configuration for a site-dependent density vector. -/
def weightVec (p : ι → ℝ) (η : ι → Bool) : ℝ := ∏ v, (if η v then p v else 1 - p v)

/-- The inhomogeneous Bernoulli probability of an event. -/
noncomputable def bernProbVec (p : ι → ℝ) (A : Set (ι → Bool)) : ℝ :=
  ∑ η : ι → Bool, A.indicator (weightVec p) η

omit [DecidableEq ι] in
/-- Constant density vectors give back the homogeneous weight. -/
theorem weightVec_const (p : ℝ) (η : ι → Bool) :
    weightVec (fun _ => p) η = weight p η := (weight_eq_prod p η).symm

/-- Constant density vectors give back the homogeneous probability. -/
theorem bernProbVec_const (p : ℝ) (A : Set (ι → Bool)) :
    bernProbVec (fun _ => p) A = bernProb p A := by
  unfold bernProbVec bernProb
  refine Finset.sum_congr rfl fun η _ => ?_
  by_cases h : η ∈ A
  · rw [Set.indicator_of_mem h, Set.indicator_of_mem h, weightVec_const]
  · rw [Set.indicator_of_notMem h, Set.indicator_of_notMem h]

omit [DecidableEq ι] in
theorem weightVec_nonneg {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    (η : ι → Bool) : 0 ≤ weightVec p η := by
  refine Finset.prod_nonneg fun v _ => ?_
  by_cases h : η v = true
  · simp [h, hp0 v]
  · simp only [Bool.not_eq_true] at h
    simp only [h, Bool.false_eq_true, if_false]
    linarith [hp1 v]

/-- The inhomogeneous weights sum to one. -/
theorem sum_weightVec (p : ι → ℝ) : ∑ η : ι → Bool, weightVec p η = 1 := by
  classical
  have key := Finset.prod_univ_sum (fun _ : ι => (univ : Finset Bool))
      (fun (v : ι) (b : Bool) => if b then p v else 1 - p v)
  rw [Fintype.piFinset_univ] at key
  simp only [Fintype.sum_bool, if_true] at key
  simp only [weightVec]
  rw [← key]
  simp

theorem bernProbVec_nonneg {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    (A : Set (ι → Bool)) : 0 ≤ bernProbVec p A :=
  Finset.sum_nonneg fun η _ =>
    Set.indicator_nonneg (fun x _ => weightVec_nonneg hp0 hp1 x) η

theorem bernProbVec_univ (p : ι → ℝ) :
    bernProbVec p (Set.univ : Set (ι → Bool)) = 1 := by
  unfold bernProbVec
  simp only [Set.indicator_univ]
  exact sum_weightVec p

theorem bernProbVec_union_of_disjoint (p : ι → ℝ) {A B : Set (ι → Bool)}
    (h : Disjoint A B) :
    bernProbVec p (A ∪ B) = bernProbVec p A + bernProbVec p B := by
  unfold bernProbVec
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun η _ => congrFun (Set.indicator_union_of_disjoint h _) η

theorem bernProbVec_add_compl (p : ι → ℝ) (A : Set (ι → Bool)) :
    bernProbVec p A + bernProbVec p Aᶜ = 1 := by
  rw [← bernProbVec_union_of_disjoint p disjoint_compl_right, Set.union_compl_self,
    bernProbVec_univ]

theorem bernProbVec_le_one {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    (A : Set (ι → Bool)) : bernProbVec p A ≤ 1 := by
  have h := bernProbVec_add_compl p A
  have := bernProbVec_nonneg hp0 hp1 Aᶜ
  linarith

/-! ## Single-coordinate structure -/

/-- The inhomogeneous weight of all coordinates except `v`. -/
def offWeightVec (p : ι → ℝ) (v : ι) (η : ι → Bool) : ℝ :=
  ∏ u ∈ univ.erase v, (if η u then p u else 1 - p u)

theorem weightVec_eq_mul_offWeightVec (p : ι → ℝ) (v : ι) (η : ι → Bool) :
    weightVec p η = (if η v then p v else 1 - p v) * offWeightVec p v η := by
  rw [weightVec, offWeightVec]
  exact (Finset.mul_prod_erase univ (fun u => if η u then p u else 1 - p u)
    (Finset.mem_univ v)).symm

theorem offWeightVec_update_config (p : ι → ℝ) (v : ι) (η : ι → Bool) (b : Bool) :
    offWeightVec p v (Function.update η v b) = offWeightVec p v η := by
  unfold offWeightVec
  refine Finset.prod_congr rfl fun u hu => ?_
  rw [Function.update_of_ne (Finset.ne_of_mem_erase hu)]

theorem offWeightVec_update_param (p : ι → ℝ) (v : ι) (t : ℝ) (η : ι → Bool) :
    offWeightVec (Function.update p v t) v η = offWeightVec p v η := by
  unfold offWeightVec
  refine Finset.prod_congr rfl fun u hu => ?_
  rw [Function.update_of_ne (Finset.ne_of_mem_erase hu)]

theorem offWeightVec_nonneg {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    (v : ι) (η : ι → Bool) : 0 ≤ offWeightVec p v η := by
  refine Finset.prod_nonneg fun u _ => ?_
  by_cases h : η u = true
  · simp [h, hp0 u]
  · simp only [Bool.not_eq_true] at h
    simp only [h, Bool.false_eq_true, if_false]
    linarith [hp1 u]

/-- The weighted count of the configurations of `A` obtained by forcing the
state of the site `v` to `b`. -/
noncomputable def sideSum (p : ι → ℝ) (v : ι) (A : Set (ι → Bool)) (b : Bool) : ℝ :=
  ∑ η ∈ univ.filter (fun η : ι → Bool => η v = true),
    A.indicator (fun _ => (1 : ℝ)) (Function.update η v b) * offWeightVec p v η

theorem sideSum_update_param (p : ι → ℝ) (v : ι) (t : ℝ) (A : Set (ι → Bool))
    (b : Bool) : sideSum (Function.update p v t) v A b = sideSum p v A b := by
  unfold sideSum
  exact Finset.sum_congr rfl fun η _ => by rw [offWeightVec_update_param]

omit [Fintype ι] [DecidableEq ι] in
/-- Splitting an indicator into its `0/1` factor and the weight. -/
theorem indicator_eq_indicator_one_mul (A : Set (ι → Bool)) (f : (ι → Bool) → ℝ)
    (η : ι → Bool) : A.indicator f η = A.indicator (fun _ => (1 : ℝ)) η * f η := by
  by_cases h : η ∈ A <;>
    simp [Set.indicator_of_mem, Set.indicator_of_notMem, h]

/-- **Exact affine dependence on one coordinate.**  As a function of the density
at a single site, the probability of any event is affine, interpolating between
the two forced values. -/
theorem bernProbVec_update_affine (p : ι → ℝ) (v : ι) (t : ℝ) (A : Set (ι → Bool)) :
    bernProbVec (Function.update p v t) A
      = (1 - t) * sideSum p v A false + t * sideSum p v A true := by
  classical
  unfold bernProbVec
  rw [sum_split v]
  have hterm : ∀ η ∈ univ.filter (fun η : ι → Bool => η v = true),
      A.indicator (weightVec (Function.update p v t)) η +
        A.indicator (weightVec (Function.update p v t)) (Function.update η v false)
      = (1 - t) * (A.indicator (fun _ => (1 : ℝ)) (Function.update η v false) *
            offWeightVec p v η) +
        t * (A.indicator (fun _ => (1 : ℝ)) (Function.update η v true) *
            offWeightVec p v η) := by
    intro η hη
    simp only [mem_filter, mem_univ, true_and] at hη
    have hupd : Function.update η v true = η := Function.update_eq_self_iff.mpr hη.symm
    have h1 : weightVec (Function.update p v t) η = t * offWeightVec p v η := by
      rw [weightVec_eq_mul_offWeightVec, offWeightVec_update_param, hη,
        Function.update_self]
      simp
    have h2 : weightVec (Function.update p v t) (Function.update η v false)
        = (1 - t) * offWeightVec p v η := by
      rw [weightVec_eq_mul_offWeightVec, offWeightVec_update_param,
        offWeightVec_update_config, Function.update_self, Function.update_self]
      simp
    rw [indicator_eq_indicator_one_mul A _ η,
      indicator_eq_indicator_one_mul A _ (Function.update η v false), h1, h2, hupd]
    ring
  rw [Finset.sum_congr rfl hterm, Finset.sum_add_distrib, ← Finset.mul_sum,
    ← Finset.mul_sum]
  rfl


/-! ## The Margulis–Russo formula -/

/-- The slope of the affine dependence on the coordinate `v` is exactly the
probability that `v` is pivotal. -/
theorem sideSum_sub_eq_pivotal {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (p : ι → ℝ) (v : ι) :
    sideSum p v A true - sideSum p v A false = bernProbVec p (pivotalSet A v) := by
  classical
  have hL : sideSum p v A true - sideSum p v A false
      = ∑ η ∈ univ.filter (fun η : ι → Bool => η v = true),
          (A.indicator (fun _ => (1 : ℝ)) (Function.update η v true)
            - A.indicator (fun _ => (1 : ℝ)) (Function.update η v false)) *
              offWeightVec p v η := by
    unfold sideSum
    rw [← Finset.sum_sub_distrib]
    exact Finset.sum_congr rfl fun η _ => by ring
  have hR : bernProbVec p (pivotalSet A v)
      = ∑ η ∈ univ.filter (fun η : ι → Bool => η v = true),
          (pivotalSet A v).indicator (fun _ => (1 : ℝ)) η * offWeightVec p v η := by
    unfold bernProbVec
    rw [sum_split v]
    refine Finset.sum_congr rfl fun η hη => ?_
    simp only [mem_filter, mem_univ, true_and] at hη
    have h1 : weightVec p η = p v * offWeightVec p v η := by
      rw [weightVec_eq_mul_offWeightVec, hη]; norm_num
    have h2 : weightVec p (Function.update η v false)
        = (1 - p v) * offWeightVec p v η := by
      rw [weightVec_eq_mul_offWeightVec, Function.update_self,
        offWeightVec_update_config]
      norm_num
    have hind : (pivotalSet A v).indicator (fun _ => (1 : ℝ))
        (Function.update η v false)
        = (pivotalSet A v).indicator (fun _ => (1 : ℝ)) η := by
      by_cases h : η ∈ pivotalSet A v
      · rw [Set.indicator_of_mem ((pivotalSet_update_mem_iff A v η false).mpr h),
          Set.indicator_of_mem h]
      · rw [Set.indicator_of_notMem
          (fun hc => h ((pivotalSet_update_mem_iff A v η false).mp hc)),
          Set.indicator_of_notMem h]
    rw [indicator_eq_indicator_one_mul (pivotalSet A v) _ η,
      indicator_eq_indicator_one_mul (pivotalSet A v) _ (Function.update η v false),
      h1, h2, hind]
    ring
  rw [hL, hR]
  refine Finset.sum_congr rfl fun η hη => ?_
  simp only [mem_filter, mem_univ, true_and] at hη
  have hupd : Function.update η v true = η := Function.update_eq_self_iff.mpr hη.symm
  congr 1
  by_cases hin : Function.update η v true ∈ A
  · by_cases hin2 : Function.update η v false ∈ A
    · rw [Set.indicator_of_mem hin, Set.indicator_of_mem hin2,
        Set.indicator_of_notMem (fun h => h.2 hin2)]
      ring
    · rw [Set.indicator_of_mem hin, Set.indicator_of_notMem hin2,
        Set.indicator_of_mem (show η ∈ pivotalSet A v from ⟨hin, hin2⟩)]
      ring
  · have hin2 : Function.update η v false ∉ A := by
      intro hc
      refine hin (hA _ _ (fun u hu => ?_) hc)
      by_cases huv : u = v
      · subst huv; simp
      · rw [Function.update_of_ne huv] at hu ⊢; exact hu
    rw [Set.indicator_of_notMem hin, Set.indicator_of_notMem hin2,
      Set.indicator_of_notMem (fun h => hin h.1)]
    ring

/-- **The Margulis–Russo formula.**  The inhomogeneous Bernoulli probability of
an increasing event is differentiable in the density at any single site, with
derivative exactly the probability that this site is pivotal. -/
theorem hasDerivAt_bernProbVec {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (p : ι → ℝ) (v : ι) (t : ℝ) :
    HasDerivAt (fun s : ℝ => bernProbVec (Function.update p v s) A)
      (bernProbVec p (pivotalSet A v)) t := by
  have hfun : (fun s : ℝ => bernProbVec (Function.update p v s) A)
      = fun s : ℝ => sideSum p v A false
          + s * (sideSum p v A true - sideSum p v A false) := by
    funext s
    rw [bernProbVec_update_affine]
    ring
  rw [hfun, ← sideSum_sub_eq_pivotal hA p v]
  simpa using
    (((hasDerivAt_id t).mul_const (sideSum p v A true - sideSum p v A false)).const_add
      (sideSum p v A false))

/-- The Margulis–Russo formula in `deriv` form. -/
theorem deriv_bernProbVec {A : Set (ι → Bool)} (hA : IsIncreasing A) (p : ι → ℝ)
    (v : ι) (t : ℝ) :
    deriv (fun s : ℝ => bernProbVec (Function.update p v s) A) t
      = bernProbVec p (pivotalSet A v) :=
  (hasDerivAt_bernProbVec hA p v t).deriv

/-! ## Coordinatewise stochastic monotonicity -/

/-- Raising the density at a single site can only help an increasing event. -/
theorem bernProbVec_update_mono {A : Set (ι → Bool)} (hA : IsIncreasing A)
    {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1) (v : ι) {s t : ℝ}
    (hst : s ≤ t) :
    bernProbVec (Function.update p v s) A ≤ bernProbVec (Function.update p v t) A := by
  have hslope : 0 ≤ sideSum p v A true - sideSum p v A false := by
    rw [sideSum_sub_eq_pivotal hA]
    exact bernProbVec_nonneg hp0 hp1 _
  rw [bernProbVec_update_affine, bernProbVec_update_affine]
  nlinarith

/-- **Coordinatewise stochastic monotonicity.**  If the density vector increases
at every site, the probability of an increasing event increases.  This is
strictly stronger than monotonicity along constant densities. -/
theorem bernProbVec_mono {A : Set (ι → Bool)} (hA : IsIncreasing A) {p q : ι → ℝ}
    (hp0 : ∀ v, 0 ≤ p v) (hq1 : ∀ v, q v ≤ 1) (hpq : ∀ v, p v ≤ q v) :
    bernProbVec p A ≤ bernProbVec q A := by
  classical
  have hq0 : ∀ v, 0 ≤ q v := fun v => (hp0 v).trans (hpq v)
  have hp1 : ∀ v, p v ≤ 1 := fun v => (hpq v).trans (hq1 v)
  have key : ∀ s : Finset ι,
      bernProbVec p A ≤ bernProbVec (fun v => if v ∈ s then q v else p v) A := by
    intro s
    induction s using Finset.induction_on with
    | empty => simp
    | insert a s ha ih =>
      set r : ι → ℝ := fun v => if v ∈ s then q v else p v with hrdef
      have hr0 : ∀ v, 0 ≤ r v := by
        intro v; simp only [hrdef]; split <;> [exact hq0 v; exact hp0 v]
      have hr1 : ∀ v, r v ≤ 1 := by
        intro v; simp only [hrdef]; split <;> [exact hq1 v; exact hp1 v]
      have hupd : (fun v => if v ∈ insert a s then q v else p v)
          = Function.update r a (q a) := by
        funext u
        by_cases h : u = a
        · subst h; simp [hrdef]
        · simp [hrdef, Finset.mem_insert, h]
      have hself : r = Function.update r a (p a) := by
        funext u
        by_cases h : u = a
        · subst h; simp [hrdef, ha]
        · rw [Function.update_of_ne h]
      rw [hupd]
      refine ih.trans ?_
      calc bernProbVec r A = bernProbVec (Function.update r a (p a)) A := by
            rw [← hself]
        _ ≤ bernProbVec (Function.update r a (q a)) A :=
            bernProbVec_update_mono hA hr0 hr1 a (hpq a)
  have huniv := key univ
  simpa using huniv

/-! ## The FKG inequality for arbitrary density vectors -/

omit [DecidableEq ι] in
/-- The inhomogeneous product weight is log-supermodular: in fact the pair
`(η, ξ)` and the pair `(η ⊓ ξ, η ⊔ ξ)` have the same weight product. -/
theorem weightVec_inf_mul_weightVec_sup (p : ι → ℝ) (η ξ : ι → Bool) :
    weightVec p η * weightVec p ξ = weightVec p (η ⊓ ξ) * weightVec p (η ⊔ ξ) := by
  simp only [weightVec, ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun v _ => ?_
  simp only [Pi.inf_apply, Pi.sup_apply]
  have key : ∀ a b : Bool,
      ((if a = true then p v else 1 - p v) * if b = true then p v else 1 - p v) =
        (if min a b = true then p v else 1 - p v) *
          if max a b = true then p v else 1 - p v := by
    intro a b
    cases a <;> cases b <;> simp [mul_comm]
  exact key (η v) (ξ v)

theorem bernProbVec_eq_sum_mul_indicator (p : ι → ℝ) (A : Set (ι → Bool)) :
    bernProbVec p A
      = ∑ η : ι → Bool, weightVec p η * A.indicator (fun _ => (1 : ℝ)) η := by
  refine Finset.sum_congr rfl fun η _ => ?_
  rw [indicator_eq_indicator_one_mul A _ η, mul_comm]

/-- **Harris/FKG inequality for inhomogeneous Bernoulli measures.**  Two
increasing events are positively correlated for every density vector. -/
theorem bernProbVec_harris {p : ι → ℝ} (hp0 : ∀ v, 0 ≤ p v) (hp1 : ∀ v, p v ≤ 1)
    {A B : Set (ι → Bool)} (hA : IsIncreasing A) (hB : IsIncreasing B) :
    bernProbVec p A * bernProbVec p B ≤ bernProbVec p (A ∩ B) := by
  classical
  have h := fkg (μ := weightVec p) (f := A.indicator (fun _ => (1 : ℝ)))
    (g := B.indicator (fun _ => (1 : ℝ)))
    (fun η => weightVec_nonneg hp0 hp1 η) (indicator_nonneg' A) (indicator_nonneg' B)
    (indicator_monotone hA) (indicator_monotone hB)
    (fun a b => le_of_eq (weightVec_inf_mul_weightVec_sup p a b))
  rw [sum_weightVec p, one_mul] at h
  rw [bernProbVec_eq_sum_mul_indicator p A, bernProbVec_eq_sum_mul_indicator p B,
    bernProbVec_eq_sum_mul_indicator p (A ∩ B)]
  refine h.trans (le_of_eq (Finset.sum_congr rfl fun η _ => ?_))
  rw [indicator_inter]

/-! ## Recovering the homogeneous Russo formula -/

/-- The homogeneous Russo derivative is the sum of the inhomogeneous partial
derivatives taken on the diagonal: the diagonal chain rule for the Bernoulli
polynomial. -/
theorem deriv_bernProb_eq_sum_partials {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (p : ℝ) :
    deriv (fun t : ℝ => bernProb t A) p
      = ∑ v : ι, deriv (fun t : ℝ =>
          bernProbVec (Function.update (fun _ => p) v t) A) p := by
  rw [deriv_bernProb hA]
  refine Finset.sum_congr rfl fun v _ => ?_
  rw [deriv_bernProbVec hA, bernProbVec_const]

end BernoulliThresholdCoupling