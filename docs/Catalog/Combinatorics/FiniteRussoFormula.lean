/-
# Russo's formula on a finite site set

For a finite site set `ι`, the Bernoulli probability polynomial
`bernProb p A = ∑ η, 1_A(η) p ^ |open η| (1-p) ^ |closed η|`
of an increasing event `A` is differentiable in `p`, and its derivative is the
sum over sites of the pivotal probabilities

`pivotalSet A v = {η | opening v puts η in A while closing v keeps it out}`.

This is the finite (purely algebraic) form of Russo's formula.  It is proved
here by differentiating the product form of the Bernoulli weight and pairing
each configuration with its flip at the differentiated coordinate.

## Main results

* `hasDerivAt_bernProb`: Russo's formula as a `HasDerivAt` statement.
* `deriv_bernProb`: the same statement for `deriv`.
* `deriv_bernProb_nonneg`: the derivative of an increasing event is nonnegative.
* `deriv_bernProb_pos_iff`, `deriv_bernProb_pos`: the derivative is positive on
  `(0,1)` exactly for the events having a pivotal configuration, which is the
  case for every nonempty increasing event missing the all-closed
  configuration.
-/

import Combinatorics.BernoulliThresholdCoupling

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The site `v` is pivotal for `A` at `η` when opening `v` realizes `A` and
closing `v` destroys it.  This does not depend on the state of `v` in `η`. -/
def pivotalSet (A : Set (ι → Bool)) (v : ι) : Set (ι → Bool) :=
  {η | Function.update η v true ∈ A ∧ Function.update η v false ∉ A}

/-- The Bernoulli weight of all coordinates except `v`. -/
def offWeight (p : ℝ) (v : ι) (η : ι → Bool) : ℝ :=
  ∏ u ∈ univ.erase v, (if η u then p else 1 - p)

theorem offWeight_update (p : ℝ) (v : ι) (η : ι → Bool) (b : Bool) :
    offWeight p v (Function.update η v b) = offWeight p v η := by
  unfold offWeight
  refine Finset.prod_congr rfl (fun u hu => ?_)
  rw [Function.update_of_ne (Finset.ne_of_mem_erase hu)]

theorem weight_eq_mul_offWeight (p : ℝ) (v : ι) (η : ι → Bool) :
    weight p η = (if η v then p else 1 - p) * offWeight p v η := by
  rw [weight_eq_prod, offWeight]
  exact (Finset.mul_prod_erase univ (fun u => if η u then p else 1 - p)
    (Finset.mem_univ v)).symm

omit [Fintype ι] in
theorem pivotalSet_update_mem_iff (A : Set (ι → Bool)) (v : ι) (η : ι → Bool) (b : Bool) :
    Function.update η v b ∈ pivotalSet A v ↔ η ∈ pivotalSet A v := by
  simp only [pivotalSet, Set.mem_setOf_eq, Function.update_idem]

/-- Splitting a sum over configurations at one coordinate. -/
theorem sum_split (v : ι) (g : (ι → Bool) → ℝ) :
    ∑ η : ι → Bool, g η =
      ∑ η ∈ univ.filter (fun η : ι → Bool => η v = true),
        (g η + g (Function.update η v false)) := by
  classical
  rw [Finset.sum_add_distrib, ← Finset.sum_filter_add_sum_filter_not univ
    (fun η : ι → Bool => η v = true) g]
  congr 1
  refine Finset.sum_nbij' (fun η => Function.update η v true)
    (fun η => Function.update η v false) ?_ ?_ ?_ ?_ ?_
  · intro a _; simp
  · intro a _; simp
  · intro a ha
    simp only [mem_filter, mem_univ, true_and, Bool.not_eq_true] at ha
    simp only [Function.update_idem]
    exact Function.update_eq_self_iff.mpr ha.symm
  · intro a ha
    simp only [mem_filter, mem_univ, true_and] at ha
    simp only [Function.update_idem]
    exact Function.update_eq_self_iff.mpr ha.symm
  · intro a ha
    simp only [mem_filter, mem_univ, true_and, Bool.not_eq_true] at ha
    simp only [Function.update_idem]
    rw [Function.update_eq_self_iff.mpr ha.symm]

/-- The Bernoulli weight of a fixed configuration is a polynomial in `p` whose
derivative is the sum of the coordinatewise derivatives. -/
theorem hasDerivAt_weight (p : ℝ) (η : ι → Bool) :
    HasDerivAt (fun p : ℝ => weight p η)
      (∑ v : ι, (if η v then (1 : ℝ) else -1) * offWeight p v η) p := by
  have hfun : (fun p : ℝ => weight p η)
      = ∏ v ∈ (univ : Finset ι), (fun p : ℝ => if η v then p else 1 - p) := by
    funext x
    rw [weight_eq_prod, Finset.prod_apply]
  rw [hfun]
  have hd : ∀ v ∈ (univ : Finset ι),
      HasDerivAt (fun p : ℝ => if η v then p else 1 - p) (if η v then (1 : ℝ) else -1) p := by
    intro v _
    by_cases h : η v = true
    · simp only [h, if_true]
      exact hasDerivAt_id p
    · simp only [Bool.not_eq_true] at h
      simp only [h, Bool.false_eq_true, if_false]
      simpa using (hasDerivAt_const p (1 : ℝ)).sub (hasDerivAt_id p)
  have hprod := HasDerivAt.finset_prod hd
  convert hprod using 1
  refine Finset.sum_congr rfl (fun v _ => ?_)
  rw [smul_eq_mul, mul_comm]
  congr 1

/-- For an increasing event, the coordinatewise derivative sums to the pivotal
probability of that coordinate. -/
theorem pivotal_sum_eq {A : Set (ι → Bool)} (hA : IsIncreasing A) (v : ι) (p : ℝ) :
    ∑ η : ι → Bool,
        A.indicator (fun η => (if η v then (1 : ℝ) else -1) * offWeight p v η) η =
      bernProb p (pivotalSet A v) := by
  classical
  rw [sum_split v, bernProb, sum_split v]
  refine Finset.sum_congr rfl (fun η hη => ?_)
  simp only [mem_filter, mem_univ, true_and] at hη
  have hupd : Function.update η v true = η := Function.update_eq_self_iff.mpr hη.symm
  have hW : offWeight p v (Function.update η v false) = offWeight p v η :=
    offWeight_update p v η false
  have hwpos : weight p η = p * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v η, hη]; norm_num
  have hwneg : weight p (Function.update η v false) = (1 - p) * offWeight p v η := by
    rw [weight_eq_mul_offWeight p v (Function.update η v false), Function.update_self, hW]
    norm_num
  have hfpos : (if η v then (1 : ℝ) else -1) * offWeight p v η = offWeight p v η := by
    rw [hη]; norm_num
  have hfneg : (if (Function.update η v false) v then (1 : ℝ) else -1) *
      offWeight p v (Function.update η v false) = - offWeight p v η := by
    rw [Function.update_self, hW]; norm_num
  by_cases hin : η ∈ A
  · by_cases h2 : Function.update η v false ∈ A
    · have hpiv : η ∉ pivotalSet A v := fun h => h.2 h2
      have hpiv2 : Function.update η v false ∉ pivotalSet A v := fun h =>
        hpiv ((pivotalSet_update_mem_iff A v η false).mp h)
      rw [Set.indicator_of_mem hin, Set.indicator_of_mem h2,
        Set.indicator_of_notMem hpiv, Set.indicator_of_notMem hpiv2, hfpos, hfneg]
      ring
    · have hpiv : η ∈ pivotalSet A v := ⟨by rwa [hupd], h2⟩
      have hpiv2 : Function.update η v false ∈ pivotalSet A v :=
        (pivotalSet_update_mem_iff A v η false).mpr hpiv
      rw [Set.indicator_of_mem hin, Set.indicator_of_notMem h2,
        Set.indicator_of_mem hpiv, Set.indicator_of_mem hpiv2, hfpos, hwpos, hwneg]
      ring
  · have h2 : Function.update η v false ∉ A := by
      intro hc
      refine hin (hA _ _ (fun u hu => ?_) hc)
      by_cases huv : u = v
      · subst huv; exact hη
      · rwa [Function.update_of_ne huv] at hu
    have hpiv : η ∉ pivotalSet A v := fun h => hin (by rw [← hupd]; exact h.1)
    have hpiv2 : Function.update η v false ∉ pivotalSet A v := fun h =>
      hpiv ((pivotalSet_update_mem_iff A v η false).mp h)
    rw [Set.indicator_of_notMem hin, Set.indicator_of_notMem h2,
      Set.indicator_of_notMem hpiv, Set.indicator_of_notMem hpiv2]

/-- **Finite Russo formula.**  The derivative of the Bernoulli probability
polynomial of an increasing event is the sum of the pivotal probabilities. -/
theorem hasDerivAt_bernProb {A : Set (ι → Bool)} (hA : IsIncreasing A) (p : ℝ) :
    HasDerivAt (fun p : ℝ => bernProb p A) (∑ v : ι, bernProb p (pivotalSet A v)) p := by
  classical
  have h1 : ∀ η : ι → Bool, HasDerivAt (fun p : ℝ => A.indicator (weight p) η)
      (A.indicator (fun η => ∑ v : ι, (if η v then (1 : ℝ) else -1) * offWeight p v η) η) p := by
    intro η
    by_cases h : η ∈ A
    · simp only [Set.indicator_of_mem h]
      exact hasDerivAt_weight p η
    · simp only [Set.indicator_of_notMem h]
      exact hasDerivAt_const p 0
  have h3 : ∀ η : ι → Bool,
      A.indicator (fun η => ∑ v : ι, (if η v then (1 : ℝ) else -1) * offWeight p v η) η =
        ∑ v : ι, A.indicator (fun η => (if η v then (1 : ℝ) else -1) * offWeight p v η) η := by
    intro η
    by_cases h : η ∈ A
    · simp only [Set.indicator_of_mem h]
    · simp only [Set.indicator_of_notMem h, Finset.sum_const_zero]
  have h4 : ∑ v : ι, bernProb p (pivotalSet A v) =
      ∑ η : ι → Bool,
        A.indicator (fun η => ∑ v : ι, (if η v then (1 : ℝ) else -1) * offWeight p v η) η := by
    simp only [h3]
    rw [Finset.sum_comm]
    exact Finset.sum_congr rfl (fun v _ => (pivotal_sum_eq hA v p).symm)
  have hfun : (fun p : ℝ => bernProb p A)
      = ∑ η ∈ (univ : Finset (ι → Bool)), (fun p : ℝ => A.indicator (weight p) η) := by
    funext x
    rw [bernProb, Finset.sum_apply]
  rw [h4, hfun]
  exact HasDerivAt.sum (fun η _ => h1 η)

/-- **Finite Russo formula**, stated with `deriv`. -/
theorem deriv_bernProb {A : Set (ι → Bool)} (hA : IsIncreasing A) (p : ℝ) :
    deriv (fun p : ℝ => bernProb p A) p = ∑ v : ι, bernProb p (pivotalSet A v) :=
  (hasDerivAt_bernProb hA p).deriv

/-- Russo's formula makes the monotonicity of increasing events transparent:
all pivotal probabilities are nonnegative for `p ∈ [0,1]`. -/
theorem deriv_bernProb_nonneg {A : Set (ι → Bool)} (hA : IsIncreasing A) {p : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ deriv (fun p : ℝ => bernProb p A) p := by
  rw [(hasDerivAt_bernProb hA p).deriv]
  exact Finset.sum_nonneg (fun v _ => bernProb_nonneg hp0 hp1 _)

/-- A nonempty event has positive Bernoulli probability for `p ∈ (0,1)`. -/
theorem bernProb_pos {A : Set (ι → Bool)} (hne : A.Nonempty) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) : 0 < bernProb p A := by
  obtain ⟨η, hη⟩ := hne
  refine Finset.sum_pos' (fun ζ _ => Set.indicator_nonneg
    (fun x _ => (weight_pos hp0 hp1 x).le) ζ) ⟨η, Finset.mem_univ η, ?_⟩
  rw [Set.indicator_of_mem hη]
  exact weight_pos hp0 hp1 η

theorem bernProb_empty (p : ℝ) : bernProb p (∅ : Set (ι → Bool)) = 0 := by
  simp [bernProb]

/-- **Strict Russo positivity.**  For `p ∈ (0,1)` the derivative of the
Bernoulli polynomial of an increasing event is positive exactly when some site
is pivotal for some configuration. -/
theorem deriv_bernProb_pos_iff {A : Set (ι → Bool)} (hA : IsIncreasing A) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) :
    0 < deriv (fun p : ℝ => bernProb p A) p ↔ ∃ v : ι, (pivotalSet A v).Nonempty := by
  rw [deriv_bernProb hA]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have hzero : ∀ v : ι, bernProb p (pivotalSet A v) = 0 := by
      intro v
      rw [hc v, bernProb_empty]
    simp only [hzero, Finset.sum_const_zero] at h
    exact lt_irrefl 0 h
  · rintro ⟨v, hv⟩
    exact Finset.sum_pos' (fun u _ => bernProb_nonneg hp0.le hp1.le _)
      ⟨v, Finset.mem_univ v, bernProb_pos hv hp0 hp1⟩

/-- A nondegenerate increasing event has strictly positive derivative on
`(0,1)`, recovering `bernProb_strictMono` from Russo's formula. -/
theorem deriv_bernProb_pos {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hfalse : (fun _ => false) ∉ A) {p : ℝ}
    (hp0 : 0 < p) (hp1 : p < 1) :
    0 < deriv (fun p : ℝ => bernProb p A) p := by
  refine (deriv_bernProb_pos_iff hA hp0 hp1).mpr ?_
  obtain ⟨η, v, hηA, hv, hoff⟩ := exists_pivotal_config hne hfalse
  exact ⟨v, η, ⟨by rwa [Function.update_eq_self_iff.mpr hv.symm], hoff⟩⟩

end BernoulliThresholdCoupling