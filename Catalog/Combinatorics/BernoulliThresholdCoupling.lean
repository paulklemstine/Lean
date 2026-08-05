/-
# Bernoulli measures from independent uniform threshold keys

This file puts a genuine probability measure on the threshold coupling of
`Catalog/Cryptography/PercolationThresholdCoupling.lean`.  Keys are drawn
independently and uniformly from `[0,1]` (the product measure `keyMeasure ι`),
and a site is open at level `p` exactly when its key is at most `p`.

## Main results

* `keyMeasure_thresholdFiber`: the probability that `siteThresholdConfig key p`
  equals a prescribed configuration `η` is `p ^ |open η| * (1-p) ^ |closed η|`,
  i.e. the coupling realizes the Bernoulli site measure of density `p`.
* `keyMeasure_eventKeys`: consequently the probability of any event `A` is the
  Bernoulli polynomial `bernProb p A`.
* `keyMeasure_eventKeys_mono` / `bernProb_mono`: for increasing events these
  probabilities are nondecreasing in `p` (all densities are coupled on one
  probability space).
* `keyMeasure_eventKeys_strictMono`, `bernProb_strictMono`: for an increasing
  event that is nonempty and misses the all-closed configuration the
  probability is strictly increasing on `(0,1)`.
* `crossing_prob_mono`, `crossing_prob_strictMono`: the horizontal crossing
  probability of the `n × n` grid is nondecreasing in `p`, and strictly
  increasing on `(0,1)`.
* `bond_keyMeasure_eventKeys`, `bond_keyMeasure_eventKeys_mono`: the bond
  analogue for an arbitrary finite vertex type.
-/

import Mathlib
import Combinatorics.Percolation
import Cryptography.PercolationThresholdCoupling

open MeasureTheory Finset Cryptography.PercolationThresholdCoupling

namespace BernoulliThresholdCoupling

/-! ## The independent uniform key measure -/

/-- The uniform probability measure on the unit interval, viewed as a measure on `ℝ`. -/
noncomputable def unifKey : Measure ℝ := volume.restrict (Set.Icc (0 : ℝ) 1)

instance : IsProbabilityMeasure unifKey := by
  constructor
  simp [unifKey]

/-- Independent uniform `[0,1]` keys indexed by a finite type `ι`. -/
noncomputable def keyMeasure (ι : Type*) [Fintype ι] : Measure (ι → ℝ) :=
  Measure.pi (fun _ : ι => unifKey)

instance (ι : Type*) [Fintype ι] : IsProbabilityMeasure (keyMeasure ι) := by
  unfold keyMeasure; infer_instance

/-- The uniform key measure of the sites with key at most `p`. -/
theorem unifKey_Iic {p : ℝ} (hp1 : p ≤ 1) :
    unifKey (Set.Iic p) = ENNReal.ofReal p := by
  rw [unifKey, Measure.restrict_apply measurableSet_Iic]
  have h : Set.Iic p ∩ Set.Icc (0 : ℝ) 1 = Set.Icc 0 p := by
    ext x
    simp only [Set.mem_inter_iff, Set.mem_Iic, Set.mem_Icc]
    constructor
    · rintro ⟨h1, h2, _⟩; exact ⟨h2, h1⟩
    · rintro ⟨h1, h2⟩; exact ⟨h2, h1, h2.trans hp1⟩
  rw [h, Real.volume_Icc, sub_zero]

/-- The uniform key measure of the sites with key above `p`. -/
theorem unifKey_Ioi {p : ℝ} (hp0 : 0 ≤ p) :
    unifKey (Set.Ioi p) = ENNReal.ofReal (1 - p) := by
  rw [unifKey, Measure.restrict_apply measurableSet_Ioi]
  have h : Set.Ioi p ∩ Set.Icc (0 : ℝ) 1 = Set.Ioc p 1 := by
    ext x
    simp only [Set.mem_inter_iff, Set.mem_Ioi, Set.mem_Icc, Set.mem_Ioc]
    constructor
    · rintro ⟨h1, _, h3⟩; exact ⟨h1, h3⟩
    · rintro ⟨h1, h2⟩; exact ⟨h1, hp0.trans h1.le, h2⟩
  rw [h, Real.volume_Ioc]

/-- The uniform key measure of an interval inside `[0,1]`. -/
theorem unifKey_Ioc {p q : ℝ} (hp0 : 0 ≤ p) (hq1 : q ≤ 1) :
    unifKey (Set.Ioc p q) = ENNReal.ofReal (q - p) := by
  rw [unifKey, Measure.restrict_apply measurableSet_Ioc]
  have h : Set.Ioc p q ∩ Set.Icc (0 : ℝ) 1 = Set.Ioc p q := by
    apply Set.inter_eq_self_of_subset_left
    intro x hx
    exact ⟨hp0.trans hx.1.le, hx.2.trans hq1⟩
  rw [h, Real.volume_Ioc]

/-! ## Bernoulli weights of finite configurations -/

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The number of open sites of a configuration. -/
def openCount (η : ι → Bool) : ℕ := (univ.filter fun v => η v = true).card

/-- The number of closed sites of a configuration. -/
def closedCount (η : ι → Bool) : ℕ := (univ.filter fun v => η v = false).card

/-- The Bernoulli weight `p ^ |open| * (1-p) ^ |closed|` of a configuration. -/
def weight (p : ℝ) (η : ι → Bool) : ℝ := p ^ openCount η * (1 - p) ^ closedCount η

omit [DecidableEq ι] in
/-- The Bernoulli weight as a product over the sites. -/
theorem weight_eq_prod (p : ℝ) (η : ι → Bool) :
    weight p η = ∏ v, (if η v then p else 1 - p) := by
  classical
  rw [← Finset.prod_filter_mul_prod_filter_not univ (fun v => η v = true)]
  have h1 : ∏ v ∈ univ.filter (fun v => η v = true), (if η v then p else 1 - p)
      = p ^ openCount η := by
    rw [Finset.prod_congr rfl (g := fun _ => p) (fun v hv => by
      simp only [mem_filter] at hv; simp [hv.2]), Finset.prod_const, openCount]
  have h2 : ∏ v ∈ univ.filter (fun v => ¬ (η v = true)), (if η v then p else 1 - p)
      = (1 - p) ^ closedCount η := by
    rw [Finset.prod_congr rfl (g := fun _ => 1 - p) (fun v hv => by
      simp only [mem_filter] at hv; simp [hv.2]), Finset.prod_const, closedCount]
    congr 2
    ext v
    simp
  rw [h1, h2, weight]

omit [DecidableEq ι] in
theorem weight_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (η : ι → Bool) :
    0 ≤ weight p η := by
  refine mul_nonneg (pow_nonneg hp0 _) (pow_nonneg ?_ _)
  linarith

omit [DecidableEq ι] in
theorem weight_pos {p : ℝ} (hp0 : 0 < p) (hp1 : p < 1) (η : ι → Bool) : 0 < weight p η :=
  mul_pos (pow_pos hp0 _) (pow_pos (by linarith) _)

/-- The Bernoulli weights of a finite site set sum to one. -/
theorem sum_weight (p : ℝ) : ∑ η : ι → Bool, weight p η = 1 := by
  classical
  have key := Finset.prod_univ_sum (fun _ : ι => (univ : Finset Bool))
      (fun (v : ι) (b : Bool) => if b then p else 1 - p)
  rw [Fintype.piFinset_univ] at key
  simp only [Fintype.sum_bool, if_true] at key
  simp only [fun η : ι → Bool => weight_eq_prod p η]
  rw [← key]
  simp

/-! ## Fibers of the threshold map -/

/-- The set of keys producing a prescribed configuration at level `p`. -/
def thresholdFiber (p : ℝ) (η : ι → Bool) : Set (ι → ℝ) :=
  {key | siteThresholdConfig key p = η}

omit [Fintype ι] [DecidableEq ι] in
theorem thresholdFiber_eq_pi (p : ℝ) (η : ι → Bool) :
    thresholdFiber p η =
      Set.univ.pi (fun v => if η v then Set.Iic p else Set.Ioi p) := by
  ext key
  simp only [thresholdFiber, Set.mem_setOf_eq, Set.mem_univ_pi, funext_iff,
    siteThresholdConfig]
  refine forall_congr' (fun v => ?_)
  cases η v <;> simp

omit [DecidableEq ι] in
theorem measurableSet_thresholdFiber (p : ℝ) (η : ι → Bool) :
    MeasurableSet (thresholdFiber (ι := ι) p η) := by
  rw [thresholdFiber_eq_pi]
  exact MeasurableSet.univ_pi (fun v => by
    by_cases h : η v = true <;> simp [h, measurableSet_Iic, measurableSet_Ioi])

omit [DecidableEq ι] in
/-- **Finite-key probability formula.**  Under independent uniform keys, the
probability that the threshold configuration at level `p` equals `η` is
`p ^ |open η| * (1-p) ^ |closed η|`. -/
theorem keyMeasure_thresholdFiber {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (η : ι → Bool) :
    keyMeasure ι (thresholdFiber p η) = ENNReal.ofReal (weight p η) := by
  rw [thresholdFiber_eq_pi, keyMeasure, Measure.pi_pi, weight_eq_prod,
    ENNReal.ofReal_prod_of_nonneg]
  · refine Finset.prod_congr rfl (fun v _ => ?_)
    by_cases h : η v = true
    · simp [h, unifKey_Iic hp1]
    · simp only [Bool.not_eq_true] at h
      simp [h, unifKey_Ioi hp0]
  · intro v _
    by_cases h : η v = true
    · simp [h, hp0]
    · simp only [Bool.not_eq_true] at h
      simp only [h, Bool.false_eq_true, if_false]
      linarith

/-! ## Events -/

/-- An event is increasing if it is preserved by opening extra sites. -/
def IsIncreasing (A : Set (ι → Bool)) : Prop :=
  ∀ η ξ : ι → Bool, (∀ v, η v = true → ξ v = true) → η ∈ A → ξ ∈ A

/-- The set of keys whose level-`p` configuration lies in `A`. -/
def eventKeys (p : ℝ) (A : Set (ι → Bool)) : Set (ι → ℝ) :=
  {key | siteThresholdConfig key p ∈ A}

/-- The Bernoulli probability polynomial of an event. -/
noncomputable def bernProb (p : ℝ) (A : Set (ι → Bool)) : ℝ :=
  ∑ η : ι → Bool, A.indicator (weight p) η

theorem bernProb_nonneg {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (A : Set (ι → Bool)) :
    0 ≤ bernProb p A :=
  Finset.sum_nonneg (fun η _ => Set.indicator_nonneg
    (fun x _ => weight_nonneg hp0 hp1 x) η)

/-- The Bernoulli probability of an event as a sum of weights over the event. -/
theorem bernProb_eq_sum (p : ℝ) (A : Set (ι → Bool)) (hAfin : A.Finite) :
    bernProb p A = ∑ η ∈ hAfin.toFinset, weight p η := by
  classical
  rw [bernProb, ← Finset.sum_subset (Finset.subset_univ hAfin.toFinset)
      (fun x _ hx => Set.indicator_of_notMem (by simpa using hx) _)]
  exact Finset.sum_congr rfl (fun x hx => Set.indicator_of_mem (by simpa using hx) _)

omit [Fintype ι] [DecidableEq ι] in
theorem eventKeys_eq_iUnion (p : ℝ) (A : Set (ι → Bool)) :
    eventKeys p A = ⋃ η ∈ A, thresholdFiber p η := by
  ext key
  simp only [eventKeys, Set.mem_setOf_eq, Set.mem_iUnion, thresholdFiber, exists_prop]
  constructor
  · intro h; exact ⟨siteThresholdConfig key p, h, rfl⟩
  · rintro ⟨η, hη, rfl⟩; exact hη

omit [DecidableEq ι] in
theorem measurableSet_eventKeys (p : ℝ) (A : Set (ι → Bool)) :
    MeasurableSet (eventKeys p A) := by
  rw [eventKeys_eq_iUnion]
  exact (Set.toFinite A).measurableSet_biUnion
    (fun η _ => measurableSet_thresholdFiber p η)

/-- The threshold coupling realizes the Bernoulli site measure of every density
simultaneously: the key probability of an event is its Bernoulli polynomial. -/
theorem keyMeasure_eventKeys {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (A : Set (ι → Bool)) :
    keyMeasure ι (eventKeys p A) = ENNReal.ofReal (bernProb p A) := by
  classical
  have hAfin : A.Finite := Set.toFinite A
  have hunion : eventKeys p A = ⋃ η ∈ hAfin.toFinset, thresholdFiber p η := by
    rw [eventKeys_eq_iUnion]
    simp only [Set.Finite.mem_toFinset]
  rw [hunion, measure_biUnion_finset]
  · rw [Finset.sum_congr rfl
      (fun η _ => keyMeasure_thresholdFiber hp0 hp1 η),
      ← ENNReal.ofReal_sum_of_nonneg (fun η _ => weight_nonneg hp0 hp1 η),
      bernProb_eq_sum p A hAfin]
  · intro x _ y _ hxy
    simp only [Function.onFun]
    rw [Set.disjoint_left]
    intro key hkx hky
    exact hxy (by rw [← (show siteThresholdConfig key p = x from hkx),
      ← (show siteThresholdConfig key p = y from hky)])
  · exact fun η _ => measurableSet_thresholdFiber p η

omit [Fintype ι] [DecidableEq ι] in
/-- Increasing events have nested key sets: this is the monotone coupling. -/
theorem eventKeys_subset {A : Set (ι → Bool)} (hA : IsIncreasing A) {p q : ℝ}
    (hpq : p ≤ q) : eventKeys p A ⊆ eventKeys q A :=
  fun key hkey => hA _ _ (fun v => siteThresholdConfig_mono key hpq v) hkey

omit [DecidableEq ι] in
/-- **Monotonicity of increasing-event probabilities.** -/
theorem keyMeasure_eventKeys_mono {A : Set (ι → Bool)} (hA : IsIncreasing A) {p q : ℝ}
    (hpq : p ≤ q) : keyMeasure ι (eventKeys p A) ≤ keyMeasure ι (eventKeys q A) :=
  measure_mono (eventKeys_subset hA hpq)

/-- The Bernoulli polynomial of an increasing event is nondecreasing in `p`. -/
theorem bernProb_mono {A : Set (ι → Bool)} (hA : IsIncreasing A) {p q : ℝ}
    (hp0 : 0 ≤ p) (hpq : p ≤ q) (hq1 : q ≤ 1) : bernProb p A ≤ bernProb q A := by
  have h := measure_mono (μ := keyMeasure ι) (eventKeys_subset hA hpq)
  rw [keyMeasure_eventKeys hp0 (hpq.trans hq1) A,
    keyMeasure_eventKeys (hp0.trans hpq) hq1 A] at h
  exact (ENNReal.ofReal_le_ofReal_iff (bernProb_nonneg (hp0.trans hpq) hq1 A)).mp h

/-! ## Strict monotonicity for nondegenerate increasing events -/

omit [DecidableEq ι] in
/-- A box of keys, i.e. a product of intervals, is measurable. -/
theorem measurableSet_keyBox (s : ι → Set ℝ) (hs : ∀ v, MeasurableSet (s v)) :
    MeasurableSet (Set.univ.pi s) :=
  MeasurableSet.univ_pi hs

omit [DecidableEq ι] in
/-- A key box built from intervals of positive uniform measure has positive
probability. -/
theorem keyMeasure_keyBox_pos (s : ι → Set ℝ) (hs : ∀ v, 0 < unifKey (s v)) :
    0 < keyMeasure ι (Set.univ.pi s) := by
  rw [keyMeasure, Measure.pi_pi]
  simp only [pos_iff_ne_zero, ne_eq, Finset.prod_eq_zero_iff, not_exists]
  intro v hv
  exact absurd hv.2 (pos_iff_ne_zero.mp (hs v))

/-- A nonempty event avoiding the all-closed configuration has a configuration
with a pivotal site: a member of the event with minimal number of open sites
leaves the event when any one of its open sites is closed. -/
theorem exists_pivotal_config {A : Set (ι → Bool)} (hne : A.Nonempty)
    (hfalse : (fun _ => false) ∉ A) :
    ∃ (η : ι → Bool) (v : ι), η ∈ A ∧ η v = true ∧ Function.update η v false ∉ A := by
  classical
  have hfin : A.Finite := Set.toFinite A
  obtain ⟨η, hηmem, hmin⟩ := hfin.toFinset.exists_min_image openCount
    ((Set.Finite.toFinset_nonempty hfin).mpr hne)
  rw [Set.Finite.mem_toFinset] at hηmem
  have hv : ∃ v, η v = true := by
    by_contra hc
    push_neg at hc
    exact hfalse (by
      have : η = fun _ => false := funext (fun u => by simpa using hc u)
      rwa [this] at hηmem)
  obtain ⟨v, hv⟩ := hv
  refine ⟨η, v, hηmem, hv, ?_⟩
  intro hmem
  have hsub : univ.filter (fun u => Function.update η v false u = true) ⊂
      univ.filter (fun u => η u = true) := by
    rw [Finset.ssubset_iff_of_subset]
    · exact ⟨v, by simp [hv], by simp⟩
    · intro u hu
      simp only [mem_filter, mem_univ, true_and] at hu ⊢
      by_cases huv : u = v
      · subst huv; simp at hu
      · rwa [Function.update_of_ne huv] at hu
  exact absurd (hmin _ (by rwa [Set.Finite.mem_toFinset]))
    (not_le.mpr (Finset.card_lt_card hsub))

/-- The box of keys witnessing strict monotonicity at a pivotal site `v` of a
configuration `η`: the key of `v` lies in `(p, q]`, the other open sites of `η`
have keys below `p`, and the closed sites have keys above `q`. -/
def strictBox (η : ι → Bool) (v : ι) (p q : ℝ) : ι → Set ℝ :=
  fun u => if u = v then Set.Ioc p q else if η u then Set.Iic p else Set.Ioi q

omit [Fintype ι] in
/-- At threshold `q` the keys of the box produce exactly the configuration `η`. -/
theorem strictBox_config_high {η : ι → Bool} {v : ι} {p q : ℝ} (hpq : p ≤ q)
    (hv : η v = true) {key : ι → ℝ} (hkey : key ∈ Set.univ.pi (strictBox η v p q)) :
    siteThresholdConfig key q = η := by
  simp only [Set.mem_univ_pi, strictBox] at hkey
  funext u
  have hku := hkey u
  by_cases huv : u = v
  · subst huv
    rw [if_pos rfl] at hku
    simp [siteThresholdConfig, hv, hku.2]
  · rw [if_neg huv] at hku
    by_cases hu : η u = true
    · rw [if_pos hu] at hku
      simp [siteThresholdConfig, hu, le_trans hku hpq]
    · simp only [Bool.not_eq_true] at hu
      rw [if_neg (by simp [hu])] at hku
      simp [siteThresholdConfig, hu, not_le.mpr (Set.mem_Ioi.mp hku)]

omit [Fintype ι] in
/-- At threshold `p` the keys of the box produce `η` with the pivotal site
closed. -/
theorem strictBox_config_low {η : ι → Bool} {v : ι} {p q : ℝ} (hpq : p ≤ q)
    {key : ι → ℝ} (hkey : key ∈ Set.univ.pi (strictBox η v p q)) :
    siteThresholdConfig key p = Function.update η v false := by
  simp only [Set.mem_univ_pi, strictBox] at hkey
  funext u
  have hku := hkey u
  by_cases huv : u = v
  · subst huv
    rw [if_pos rfl] at hku
    simp [siteThresholdConfig, not_le.mpr hku.1]
  · rw [if_neg huv] at hku
    rw [Function.update_of_ne huv]
    by_cases hu : η u = true
    · rw [if_pos hu] at hku
      simp [siteThresholdConfig, hu, Set.mem_Iic.mp hku]
    · simp only [Bool.not_eq_true] at hu
      rw [if_neg (by simp [hu])] at hku
      simp [siteThresholdConfig, hu,
        not_le.mpr (lt_of_le_of_lt hpq (Set.mem_Ioi.mp hku))]

theorem measurableSet_strictBox (η : ι → Bool) (v : ι) (p q : ℝ) :
    MeasurableSet (Set.univ.pi (strictBox η v p q)) := by
  refine MeasurableSet.univ_pi (fun u => ?_)
  rw [strictBox]
  split
  · exact measurableSet_Ioc
  · split
    · exact measurableSet_Iic
    · exact measurableSet_Ioi

theorem keyMeasure_strictBox_pos (η : ι → Bool) (v : ι) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p < q) (hq1 : q < 1) :
    0 < keyMeasure ι (Set.univ.pi (strictBox η v p q)) := by
  refine keyMeasure_keyBox_pos _ (fun u => ?_)
  rw [strictBox]
  split
  · rw [unifKey_Ioc hp0.le hq1.le]
    exact ENNReal.ofReal_pos.mpr (by linarith)
  · split
    · rw [unifKey_Iic (by linarith : p ≤ 1)]
      exact ENNReal.ofReal_pos.mpr hp0
    · rw [unifKey_Ioi (by linarith : (0 : ℝ) ≤ q)]
      exact ENNReal.ofReal_pos.mpr (by linarith)

/-- **Strict monotonicity of increasing-event probabilities.**  For an
increasing event that is nonempty and does not contain the all-closed
configuration, the probability is strictly increasing on `(0,1)`. -/
theorem keyMeasure_eventKeys_strictMono {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hfalse : (fun _ => false) ∉ A) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p < q) (hq1 : q < 1) :
    keyMeasure ι (eventKeys p A) < keyMeasure ι (eventKeys q A) := by
  obtain ⟨η, v, hηA, hv, hoff⟩ := exists_pivotal_config hne hfalse
  set S := Set.univ.pi (strictBox η v p q) with hS
  have hdisj : Disjoint (eventKeys p A) S := by
    rw [Set.disjoint_right]
    intro key hkS hkE
    rw [eventKeys, Set.mem_setOf_eq, strictBox_config_low hpq.le hkS] at hkE
    exact hoff hkE
  have hsub : eventKeys p A ∪ S ⊆ eventKeys q A := by
    rintro key (hk | hk)
    · exact eventKeys_subset hA hpq.le hk
    · rw [eventKeys, Set.mem_setOf_eq, strictBox_config_high hpq.le hv hk]
      exact hηA
  have hunion := measure_union (μ := keyMeasure ι) hdisj (measurableSet_strictBox η v p q)
  calc keyMeasure ι (eventKeys p A)
      < keyMeasure ι (eventKeys p A) + keyMeasure ι S :=
        ENNReal.lt_add_right (measure_ne_top _ _)
          (pos_iff_ne_zero.mp (keyMeasure_strictBox_pos η v hp0 hpq hq1))
    _ = keyMeasure ι (eventKeys p A ∪ S) := hunion.symm
    _ ≤ keyMeasure ι (eventKeys q A) := measure_mono hsub

/-- The Bernoulli polynomial of a nondegenerate increasing event is strictly
increasing on `(0,1)`. -/
theorem bernProb_strictMono {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (hne : A.Nonempty) (hfalse : (fun _ => false) ∉ A) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p < q) (hq1 : q < 1) :
    bernProb p A < bernProb q A := by
  have h := keyMeasure_eventKeys_strictMono hA hne hfalse hp0 hpq hq1
  rw [keyMeasure_eventKeys hp0.le (by linarith) A,
    keyMeasure_eventKeys (by linarith) hq1.le A] at h
  exact (ENNReal.ofReal_lt_ofReal_iff_of_nonneg
    (bernProb_nonneg hp0.le (by linarith) A)).mp h

/-! ## Horizontal crossings of the square grid -/

/-- Horizontal crossing as an event on site configurations of the `n × n` grid. -/
def crossingEvent (n : ℕ) (hn : 0 < n) : Set (Fin n × Fin n → Bool) :=
  {η | HasHorizontalCrossing n hn η}

theorem crossingEvent_isIncreasing (n : ℕ) (hn : 0 < n) :
    IsIncreasing (crossingEvent n hn) :=
  fun _ _ hdom h => hasHorizontalCrossing_increasing n hn _ _ hdom h

/-- **Crossing probability monotonicity.** -/
theorem crossing_prob_mono (n : ℕ) (hn : 0 < n) {p q : ℝ} (hpq : p ≤ q) :
    keyMeasure (Fin n × Fin n) (eventKeys p (crossingEvent n hn)) ≤
      keyMeasure (Fin n × Fin n) (eventKeys q (crossingEvent n hn)) :=
  keyMeasure_eventKeys_mono (crossingEvent_isIncreasing n hn) hpq

/-- A straight walk along a column of the grid, staying inside that column. -/
theorem gridGraph_column_walk (n : ℕ) (hn : 0 < n) (c : Fin n) (k : ℕ) (hk : k < n) :
    ∃ w : (gridGraph n).Walk (⟨0, hn⟩, c) (⟨k, hk⟩, c), ∀ x ∈ w.support, x.2 = c := by
  induction k with
  | zero => exact ⟨SimpleGraph.Walk.nil, by simp⟩
  | succ m ih =>
    obtain ⟨w, hw⟩ := ih (by omega)
    have hadj : (gridGraph n).Adj (⟨m, by omega⟩, c) (⟨m + 1, hk⟩, c) :=
      Or.inr ⟨rfl, Or.inl rfl⟩
    refine ⟨w.concat hadj, ?_⟩
    intro x hx
    rw [SimpleGraph.Walk.support_concat] at hx
    simp only [List.concat_eq_append, List.mem_append, List.mem_singleton] at hx
    rcases hx with hx | hx
    · exact hw x hx
    · subst hx; rfl

/-- The all-open configuration crosses, so the crossing event is nonempty. -/
theorem crossingEvent_nonempty (n : ℕ) (hn : 0 < n) : (crossingEvent n hn).Nonempty := by
  obtain ⟨w, _⟩ := gridGraph_column_walk n hn ⟨0, hn⟩ (n - 1) (by omega)
  exact ⟨fun _ => true, ⟨0, hn⟩, ⟨0, hn⟩, w, fun x _ => rfl⟩

/-- The all-closed configuration does not cross. -/
theorem crossingEvent_false_notMem (n : ℕ) (hn : 0 < n) :
    (fun _ => false) ∉ crossingEvent n hn := by
  rintro ⟨a, b, w, hw⟩
  exact absurd (hw _ w.start_mem_support) (by simp)

/-- **Threshold coupling strictness for grids.**  For `0 < p < q < 1` the
horizontal crossing probability of the `n × n` grid is strictly larger at `q`
than at `p`. -/
theorem crossing_prob_strictMono (n : ℕ) (hn : 0 < n) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p < q) (hq1 : q < 1) :
    keyMeasure (Fin n × Fin n) (eventKeys p (crossingEvent n hn)) <
      keyMeasure (Fin n × Fin n) (eventKeys q (crossingEvent n hn)) :=
  keyMeasure_eventKeys_strictMono (crossingEvent_isIncreasing n hn)
    (crossingEvent_nonempty n hn) (crossingEvent_false_notMem n hn) hp0 hpq hq1

/-- The same statement for grids of side at least two, in Bernoulli-polynomial
form. -/
theorem crossing_bernProb_strictMono (n : ℕ) (hn : 2 ≤ n) {p q : ℝ}
    (hp0 : 0 < p) (hpq : p < q) (hq1 : q < 1) :
    bernProb p (crossingEvent n (by omega)) < bernProb q (crossingEvent n (by omega)) :=
  bernProb_strictMono (crossingEvent_isIncreasing n (by omega))
    (crossingEvent_nonempty n (by omega)) (crossingEvent_false_notMem n (by omega))
    hp0 hpq hq1

/-! ## The bond analogue -/

section Bond

variable {V : Type*} [Fintype V] [DecidableEq V]

omit [Fintype V] [DecidableEq V] in
/-- The bond threshold configuration is the site threshold configuration of the
edge-key family. -/
theorem bondThresholdConfig_eq (key : Sym2 V → ℝ) (p : ℝ) :
    bondThresholdConfig key p = siteThresholdConfig key p := rfl

omit [DecidableEq V] in
/-- **Bond analogue of the finite-key formula.** -/
theorem bond_keyMeasure_thresholdFiber {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (ω : Sym2 V → Bool) :
    keyMeasure (Sym2 V) {key | bondThresholdConfig key p = ω} =
      ENNReal.ofReal (weight p ω) :=
  keyMeasure_thresholdFiber hp0 hp1 ω

/-- **Bond analogue.** The independent uniform edge-key coupling realizes the
Bernoulli bond measure of every density. -/
theorem bond_keyMeasure_eventKeys {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (A : Set (Sym2 V → Bool)) :
    keyMeasure (Sym2 V) {key | bondThresholdConfig key p ∈ A} =
      ENNReal.ofReal (bernProb p A) :=
  keyMeasure_eventKeys hp0 hp1 A

omit [DecidableEq V] in
/-- **Bond analogue.** Increasing bond events are pointwise nondecreasing in the
threshold, hence have nondecreasing probability. -/
theorem bond_keyMeasure_eventKeys_mono {A : Set (Sym2 V → Bool)} (hA : IsIncreasing A)
    {p q : ℝ} (hpq : p ≤ q) :
    keyMeasure (Sym2 V) {key | bondThresholdConfig key p ∈ A} ≤
      keyMeasure (Sym2 V) {key | bondThresholdConfig key q ∈ A} :=
  keyMeasure_eventKeys_mono hA hpq

omit [DecidableEq V] in
/-- Bond connectivity between two vertices is an increasing bond event, so its
probability is nondecreasing in `p`. -/
theorem bond_connected_prob_mono (G : SimpleGraph V) (u v : V) {p q : ℝ} (hpq : p ≤ q) :
    keyMeasure (Sym2 V)
        {key | BondConnected G (bondThresholdConfig key p) u v} ≤
      keyMeasure (Sym2 V)
        {key | BondConnected G (bondThresholdConfig key q) u v} := by
  have hincr : IsIncreasing {ω : Sym2 V → Bool | BondConnected G ω u v} :=
    fun ω ξ hdom h => bondConnected_increasing G u v ω ξ hdom h
  exact keyMeasure_eventKeys_mono hincr hpq

end Bond

end BernoulliThresholdCoupling