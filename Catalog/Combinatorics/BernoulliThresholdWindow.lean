/-
# The Bollobás–Thomason threshold window

Building on the sprinkling laws of
`Catalog/Combinatorics/BernoulliSprinkling.lean`, this file proves that every
nondegenerate increasing event on a finite site set has a *sharp threshold in
the coarse sense*: the density has to be multiplied only by a bounded factor to
push the probability from `1/2` to `1 - 2^{-k}`.

Concretely, if `A` is increasing and `bernProb p A ≥ ε`, then

`bernProb (min (k*p) 1) A ≥ 1 - (1-ε)^k`   (`bernProb_boost`),

which is the classical Bollobás–Thomason argument: `k` independent copies at
density `p` superpose into density `1 - (1-p)^k ≤ k*p`, and by the sprinkling
law they all have to fail simultaneously for `A` to fail.

Introducing the *threshold density*
`thresholdDensity A ε = sInf {p ∈ [0,1] | bernProb p A ≥ ε}`, which is attained
because `p ↦ bernProb p A` is a polynomial, this becomes the threshold-window
statement

`thresholdDensity A (1 - (1/2)^k) ≤ k * thresholdDensity A (1/2)`
  (`thresholdDensity_window`),

and dually, using the thinning law,

`thresholdDensity A (1/2) ≤ ... ` in the multiplicative form
`bernProb_decay` : `bernProb (p^k) A ≤ ε^k` whenever `bernProb p A ≤ ε`.

## Main results

* `continuous_bernProb`: the Bernoulli probability polynomial is continuous.
* `bernProb_one_of_mem`, `bernProb_zero_of_notMem`: boundary values.
* `bernProb_boost`: the Bollobás–Thomason boosting inequality.
* `thresholdDensity_mem`: the infimum defining the threshold density is attained.
* `thresholdDensity_window`: the threshold window is multiplicatively bounded.
* `thresholdDensity_le_of_le`, `le_thresholdDensity_iff`: basic calculus of
  threshold densities.
* `crossing_thresholdDensity_window`: the window statement for horizontal
  crossings of the `n × n` grid.
-/

import Combinatorics.BernoulliSprinkling

open Finset

namespace BernoulliThresholdCoupling

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Continuity and boundary values of the Bernoulli polynomial -/

omit [DecidableEq ι] in
/-- The Bernoulli weight of a configuration is a polynomial, hence continuous,
in the density. -/
theorem continuous_weight (η : ι → Bool) : Continuous fun p : ℝ => weight p η := by
  unfold weight
  exact (continuous_id.pow _).mul ((continuous_const.sub continuous_id).pow _)

/-- The Bernoulli probability of an event is continuous in the density. -/
theorem continuous_bernProb (A : Set (ι → Bool)) :
    Continuous fun p : ℝ => bernProb p A := by
  classical
  unfold bernProb
  refine continuous_finset_sum _ fun η _ => ?_
  by_cases h : η ∈ A
  · simp only [Set.indicator_of_mem h]
    exact continuous_weight η
  · simp only [Set.indicator_of_notMem h]
    exact continuous_const

/-- An event containing the all-open configuration has probability one at
density one. -/
theorem bernProb_one_of_mem {A : Set (ι → Bool)} (htrue : (fun _ => true) ∈ A) :
    bernProb (1 : ℝ) A = 1 := by
  refine le_antisymm (bernProb_le_one zero_le_one le_rfl A) ?_
  have h := pow_le_bernProb (ι := ι) zero_le_one le_rfl htrue
  simpa using h

/-- An event missing the all-closed configuration has probability zero at
density zero. -/
theorem bernProb_zero_of_notMem {A : Set (ι → Bool)}
    (hfalse : (fun _ => false) ∉ A) : bernProb (0 : ℝ) A = 0 := by
  refine le_antisymm ?_ (bernProb_nonneg le_rfl zero_le_one A)
  have h := bernProb_le_one_sub_pow (ι := ι) le_rfl zero_le_one hfalse
  simpa using h

/-! ## The Bollobás–Thomason boosting inequality -/

/-- Superposing `k` independent copies of density `p` produces density
`1 - (1-p)^k`, which never exceeds `min (k*p) 1`. -/
theorem one_sub_pow_le_min {p : ℝ} (hp1 : p ≤ 1) (k : ℕ) :
    1 - (1 - p) ^ k ≤ min ((k : ℝ) * p) 1 := by
  refine le_min ?_ ?_
  · have hb : 1 + (k : ℝ) * (-p) ≤ (1 + (-p)) ^ k :=
      one_add_mul_le_pow (by linarith) k
    have : (1 : ℝ) - (k : ℝ) * p ≤ (1 - p) ^ k := by
      simpa [sub_eq_add_neg, mul_neg] using hb
    linarith
  · have : 0 ≤ (1 - p) ^ k := pow_nonneg (by linarith) k
    linarith

/-- **Bollobás–Thomason boosting.**  For an increasing event, multiplying the
density by `k` boosts a probability of at least `ε` to a probability of at least
`1 - (1-ε)^k`. -/
theorem bernProb_boost {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) {e : ℝ} (he : e ≤ bernProb p A) (k : ℕ) :
    1 - (1 - e) ^ k ≤ bernProb (min ((k : ℝ) * p) 1) A := by
  have hpk0 : 0 ≤ (1 - p) ^ k := pow_nonneg (by linarith) k
  have hpk1 : (1 - p) ^ k ≤ 1 := pow_le_one₀ (by linarith) (by linarith)
  have hq0 : 0 ≤ 1 - (1 - p) ^ k := by linarith
  have hq1 : 1 - (1 - p) ^ k ≤ 1 := by linarith
  have hnn : 0 ≤ 1 - bernProb p A := by
    have := bernProb_le_one hp0 hp1 A; linarith
  have hpow : (1 - bernProb p A) ^ k ≤ (1 - e) ^ k :=
    pow_le_pow_left₀ hnn (by linarith) k
  have hsprinkle := one_sub_bernProb_sprinkle_pow hp0 hp1 hA k
  have hmono : bernProb (1 - (1 - p) ^ k) A ≤ bernProb (min ((k : ℝ) * p) 1) A :=
    bernProb_mono hA hq0 (one_sub_pow_le_min hp1 k) (min_le_right _ _)
  linarith

/-- **Exponential decay below the threshold.**  For an increasing event, if the
probability at density `p` is at most `ε`, then at density `p ^ k` it is at most
`ε ^ k`. -/
theorem bernProb_decay {p : ℝ} (hp0 : 0 ≤ p) (hp1 : p ≤ 1) {A : Set (ι → Bool)}
    (hA : IsIncreasing A) {e : ℝ} (he : bernProb p A ≤ e) (k : ℕ) :
    bernProb (p ^ k) A ≤ e ^ k :=
  (bernProb_pow_le hp0 hp1 hA k).trans
    (pow_le_pow_left₀ (bernProb_nonneg hp0 hp1 A) he k)

/-! ## The threshold density -/

/-- The set of densities at which an event has probability at least `ε`. -/
def thresholdSet (A : Set (ι → Bool)) (e : ℝ) : Set ℝ :=
  {p : ℝ | p ∈ Set.Icc (0 : ℝ) 1 ∧ e ≤ bernProb p A}

/-- The threshold density: the least density at which the event has probability
at least `ε`. -/
noncomputable def thresholdDensity (A : Set (ι → Bool)) (e : ℝ) : ℝ :=
  sInf (thresholdSet A e)

theorem thresholdSet_subset_Icc (A : Set (ι → Bool)) (e : ℝ) :
    thresholdSet A e ⊆ Set.Icc (0 : ℝ) 1 := fun _ hp => hp.1

theorem bddBelow_thresholdSet (A : Set (ι → Bool)) (e : ℝ) :
    BddBelow (thresholdSet A e) :=
  ⟨0, fun _ hp => hp.1.1⟩

theorem thresholdSet_nonempty {A : Set (ι → Bool)} (htrue : (fun _ => true) ∈ A)
    {e : ℝ} (he1 : e ≤ 1) : (thresholdSet A e).Nonempty :=
  ⟨1, ⟨⟨zero_le_one, le_rfl⟩, by rw [bernProb_one_of_mem htrue]; exact he1⟩⟩

theorem isClosed_thresholdSet (A : Set (ι → Bool)) (e : ℝ) :
    IsClosed (thresholdSet A e) := by
  have h : thresholdSet A e
      = Set.Icc (0 : ℝ) 1 ∩ (fun p : ℝ => bernProb p A) ⁻¹' Set.Ici e := rfl
  rw [h]
  exact isClosed_Icc.inter (IsClosed.preimage (continuous_bernProb A) isClosed_Ici)

/-- **The threshold infimum is attained**: at the threshold density the event
already has probability at least `ε`. -/
theorem thresholdDensity_mem {A : Set (ι → Bool)} (htrue : (fun _ => true) ∈ A)
    {e : ℝ} (he1 : e ≤ 1) : thresholdDensity A e ∈ thresholdSet A e :=
  (isClosed_thresholdSet A e).csInf_mem (thresholdSet_nonempty htrue he1)
    (bddBelow_thresholdSet A e)

theorem thresholdDensity_nonneg {A : Set (ι → Bool)} (htrue : (fun _ => true) ∈ A)
    {e : ℝ} (he1 : e ≤ 1) : 0 ≤ thresholdDensity A e :=
  (thresholdDensity_mem htrue he1).1.1

theorem thresholdDensity_le_one {A : Set (ι → Bool)} (htrue : (fun _ => true) ∈ A)
    {e : ℝ} (he1 : e ≤ 1) : thresholdDensity A e ≤ 1 :=
  (thresholdDensity_mem htrue he1).1.2

theorem le_bernProb_thresholdDensity {A : Set (ι → Bool)}
    (htrue : (fun _ => true) ∈ A) {e : ℝ} (he1 : e ≤ 1) :
    e ≤ bernProb (thresholdDensity A e) A :=
  (thresholdDensity_mem htrue he1).2

/-- Any density realizing probability `ε` dominates the threshold density. -/
theorem thresholdDensity_le_of_le {A : Set (ι → Bool)} {e p : ℝ}
    (hp0 : 0 ≤ p) (hp1 : p ≤ 1) (hp : e ≤ bernProb p A) :
    thresholdDensity A e ≤ p :=
  csInf_le (bddBelow_thresholdSet A e) ⟨⟨hp0, hp1⟩, hp⟩

/-- Above the threshold density the probability stays at least `ε`. -/
theorem le_bernProb_of_thresholdDensity_le {A : Set (ι → Bool)}
    (hA : IsIncreasing A) (htrue : (fun _ => true) ∈ A) {e p : ℝ} (he1 : e ≤ 1)
    (hp : thresholdDensity A e ≤ p) (hp1 : p ≤ 1) : e ≤ bernProb p A :=
  (le_bernProb_thresholdDensity htrue he1).trans
    (bernProb_mono hA (thresholdDensity_nonneg htrue he1) hp hp1)

/-- The threshold density is monotone in the target probability. -/
theorem thresholdDensity_mono {A : Set (ι → Bool)} (htrue : (fun _ => true) ∈ A)
    {e f : ℝ} (hef : e ≤ f) (hf1 : f ≤ 1) :
    thresholdDensity A e ≤ thresholdDensity A f :=
  thresholdDensity_le_of_le (thresholdDensity_nonneg htrue hf1)
    (thresholdDensity_le_one htrue hf1)
    (hef.trans (le_bernProb_thresholdDensity htrue hf1))

/-! ## The threshold window -/

/-- **The Bollobás–Thomason threshold window.**  For every nondegenerate
increasing event and every `k`, the density needed to reach probability
`1 - (1-ε)^k` is at most `k` times the density needed to reach probability `ε`.
The bound is uniform: it does not depend on the site set, on the event, or on
its number of sites. -/
theorem thresholdDensity_window {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (htrue : (fun _ => true) ∈ A) {e : ℝ} (he1 : e ≤ 1) (k : ℕ) :
    thresholdDensity A (1 - (1 - e) ^ k) ≤ (k : ℝ) * thresholdDensity A e := by
  set p := thresholdDensity A e with hp
  have hp0 : 0 ≤ p := thresholdDensity_nonneg htrue he1
  have hp1 : p ≤ 1 := thresholdDensity_le_one htrue he1
  have hep : e ≤ bernProb p A := le_bernProb_thresholdDensity htrue he1
  have hboost := bernProb_boost hp0 hp1 hA hep k
  have hmin0 : 0 ≤ min ((k : ℝ) * p) 1 :=
    le_min (mul_nonneg (Nat.cast_nonneg k) hp0) zero_le_one
  have hstep : thresholdDensity A (1 - (1 - e) ^ k) ≤ min ((k : ℝ) * p) 1 :=
    thresholdDensity_le_of_le hmin0 (min_le_right _ _) hboost
  exact hstep.trans (min_le_left _ _)

/-- The `ε = 1/2` case: the density doubling `k` times reaches probability
`1 - 2^{-k}`. -/
theorem thresholdDensity_window_half {A : Set (ι → Bool)} (hA : IsIncreasing A)
    (htrue : (fun _ => true) ∈ A) (k : ℕ) :
    thresholdDensity A (1 - (1 / 2 : ℝ) ^ k) ≤ (k : ℝ) * thresholdDensity A (1 / 2) := by
  have h := thresholdDensity_window hA htrue (e := 1 / 2) (by norm_num) k
  norm_num at h ⊢
  exact h

/-! ## Application: the crossing threshold of the square grid -/

/-- The all-open configuration crosses the grid. -/
theorem crossingEvent_all_true (n : ℕ) (hn : 0 < n) :
    (fun _ : Fin n × Fin n => true) ∈ crossingEvent n hn := by
  obtain ⟨η, hη⟩ := crossingEvent_nonempty n hn
  exact crossingEvent_isIncreasing n hn η _ (fun _ _ => rfl) hη

/-- **The crossing threshold window.**  For the `n × n` grid the density
required for a horizontal crossing with probability `1 - 2^{-k}` is at most `k`
times the density required for probability `1/2`, uniformly in `n`. -/
theorem crossing_thresholdDensity_window (n : ℕ) (hn : 0 < n) (k : ℕ) :
    thresholdDensity (crossingEvent n hn) (1 - (1 / 2 : ℝ) ^ k) ≤
      (k : ℝ) * thresholdDensity (crossingEvent n hn) (1 / 2) :=
  thresholdDensity_window_half (crossingEvent_isIncreasing n hn)
    (crossingEvent_all_true n hn) k

/-- The crossing threshold density at level `1/2` is positive: for `p` below
`(1/2) ^ (1 / (n*n))` the crossing probability is smaller than `1/2`.  Stated
in the equivalent form that the threshold density is at least the value at
which the a priori upper bound `1 - (1-p)^{n*n}` first reaches `1/2`. -/
theorem crossing_thresholdDensity_pos (n : ℕ) (hn : 0 < n) {p : ℝ} (hp0 : 0 ≤ p)
    (hp1 : p ≤ 1) (hlow : 1 - (1 - p) ^ (n * n) < 1 / 2) :
    p < thresholdDensity (crossingEvent n hn) (1 / 2) := by
  by_contra hc
  push_neg at hc
  have hmem := thresholdDensity_mem (crossingEvent_all_true n hn)
    (e := (1 / 2 : ℝ)) (by norm_num)
  have hle : bernProb (thresholdDensity (crossingEvent n hn) (1 / 2))
      (crossingEvent n hn) ≤ bernProb p (crossingEvent n hn) :=
    bernProb_mono (crossingEvent_isIncreasing n hn) hmem.1.1 hc hp1
  have hcard : Fintype.card (Fin n × Fin n) = n * n := by simp
  have hupper : bernProb p (crossingEvent n hn) ≤ 1 - (1 - p) ^ (n * n) := by
    have := bernProb_le_one_sub_pow (ι := Fin n × Fin n) hp0 hp1
      (crossingEvent_false_notMem n hn)
    rwa [hcard] at this
  have := hmem.2
  linarith

end BernoulliThresholdCoupling