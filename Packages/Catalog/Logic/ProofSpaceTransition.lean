import Mathlib

/-!
# A discrete Gödel threshold in finite proof space

This file gives a precise finite model of the proposed phase-transition picture.
At cutoff `n`, `provable n` and `unprovable n` count the two classes of statements
seen so far.  Their difference is the signed order parameter.  The main theorem
shows that, whenever this difference starts positive and ends nonpositive, there
is a unique first cutoff at which the provable majority disappears.  Under a
strict-decrease hypothesis, the sign change is permanent and its location is
unique.

This is deliberately a theorem about an abstract enumeration: incompleteness
alone does not imply any particular asymptotic density or power law without a
choice of syntax, length function, and probability measure.
-/

namespace ProofSpace

/-- The rational proportion of provable statements among all classified statements. -/
def orderParameter (provable unprovable : ℕ) : ℚ :=
  provable / (provable + unprovable)

/-- The signed excess of provable over unprovable statements. -/
def imbalance (provable unprovable : ℕ) : ℤ :=
  (provable : ℤ) - (unprovable : ℤ)

/-- A cutoff is a threshold when its imbalance is nonpositive, but all earlier
cutoffs have positive imbalance. -/
def IsFirstThreshold (f : ℕ → ℤ) (n : ℕ) : Prop :=
  f n ≤ 0 ∧ ∀ m < n, 0 < f m

/-- A first threshold exists before every cutoff at which the sign has changed. -/
theorem exists_first_threshold (f : ℕ → ℤ) (N : ℕ)
    (hN : f N ≤ 0) :
    ∃ n ≤ N, IsFirstThreshold f n := by
  -- The set of n ≤ N with f n ≤ 0 is nonempty (contains N)
  let S : Finset ℕ := {n ∈ Finset.range (N + 1) | f n ≤ 0}
  have hne : S.Nonempty := by
    use N
    exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (Nat.lt_succ_self N), hN⟩
  -- Take the minimum
  let n := S.min' hne
  have hn_mem : n ∈ S := Finset.min'_mem S hne
  have hn_bound : n ≤ N := Finset.mem_range_succ_iff.mp (Finset.mem_filter.mp hn_mem).1
  use n, hn_bound
  refine ⟨(Finset.mem_filter.mp hn_mem).2, ?_⟩
  intro m hm
  by_contra h
  have h_nonpos : f m ≤ 0 := le_of_not_gt h
  have hm_in_S : m ∈ S := by
    have hm' : m < N + 1 := Nat.lt_succ_of_lt (hm.trans_le hn_bound)
    exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr hm', h_nonpos⟩
  have := S.min'_le _ hm_in_S
  omega

/-- The first threshold is unique, without any monotonicity assumption. -/
theorem first_threshold_unique (f : ℕ → ℤ) {a b : ℕ}
    (ha : IsFirstThreshold f a) (hb : IsFirstThreshold f b) : a = b := by
  apply Nat.le_antisymm
  · by_contra h
    push_neg at h
    have : 0 < f b := ha.2 b h
    linarith [hb.1]
  · by_contra h
    push_neg at h
    have : 0 < f a := hb.2 a h
    linarith [ha.1]

/-- Strict decrease makes the threshold a permanent sharp transition: every
later cutoff through `N` has negative imbalance. -/
theorem sharp_transition (f : ℕ → ℤ) (N : ℕ)
    (hdec : ∀ n < N, f (n + 1) < f n)
    (hN : f N ≤ 0) :
    ∃! n, n ≤ N ∧ IsFirstThreshold f n ∧
      ∀ m, n < m → m ≤ N → f m < 0 := by
  have hstrict : ∀ n m, n < m → m ≤ N → f m < f n := by
    intro n m hnm hmN
    induction m generalizing n with
    | zero => omega
    | succ m ih =>
      rcases lt_trichotomy n m with hnm' | rfl | hmn
      · have ih' := ih n hnm' (Nat.le_of_succ_le hmN)
        linarith [hdec m (Nat.lt_of_succ_le hmN)]
      · exact hdec n (Nat.lt_of_succ_le hmN)
      · omega
  obtain ⟨n, hn_le, hn_ft⟩ := exists_first_threshold f N hN
  use n
  refine ⟨⟨hn_le, hn_ft, ?_⟩, ?_⟩
  · intro m hnm hmN
    have := hstrict n m hnm hmN
    linarith [hn_ft.1]
  · intro y ⟨_, hy_ft, _⟩
    exact first_threshold_unique f hy_ft hn_ft

/-- A positive imbalance is exactly an order parameter strictly above one half. -/
theorem orderParameter_gt_half_iff {p u : ℕ} (htotal : 0 < p + u) :
    (1 / 2 : ℚ) < orderParameter p u ↔ u < p := by
  unfold orderParameter
  have hpos : (0 : ℚ) < ↑p + ↑u := by
    norm_cast
  rw [div_lt_div_iff₀ (by norm_num : (0 : ℚ) < 2) hpos]
  constructor
  · intro h
    norm_cast at h
    linarith
  · intro h
    norm_cast
    linarith

/-- A nonpositive imbalance is exactly an order parameter at most one half. -/
theorem orderParameter_le_half_iff {p u : ℕ} (htotal : 0 < p + u) :
    orderParameter p u ≤ (1 / 2 : ℚ) ↔ p ≤ u := by
  simp [orderParameter]
  have hpou : (0 : ℚ) < p + u := by norm_cast
  rw [div_le_iff₀ hpou]
  have h2 : (2 : ℚ)⁻¹ = 1 / 2 := by norm_num
  rw [h2]
  have : (↑p : ℚ) ≤ 1 / 2 * (↑p + ↑u) ↔ 2 * p ≤ p + u := by
    rw [div_mul_eq_mul_div, le_div_iff₀ (by norm_num : (0 : ℚ) < 2)]
    constructor <;> intro h <;> norm_cast at * <;> ring_nf at * <;> linarith
  rw [this]
  omega

/-- Count formulation of the phase-transition theorem. -/
theorem count_phase_transition (provable unprovable : ℕ → ℕ) (N : ℕ)
    (hpositive : ∀ n ≤ N, 0 < provable n + unprovable n)
    (hdec : ∀ n < N,
      imbalance (provable (n + 1)) (unprovable (n + 1)) <
        imbalance (provable n) (unprovable n))
    (hend : provable N ≤ unprovable N) :
    ∃! n, n ≤ N ∧
      orderParameter (provable n) (unprovable n) ≤ (1 / 2 : ℚ) ∧
      (∀ m < n, (1 / 2 : ℚ) < orderParameter (provable m) (unprovable m)) ∧
      ∀ m, n < m → m ≤ N →
        orderParameter (provable m) (unprovable m) < (1 / 2 : ℚ) := by
  -- Define the imbalance function
  let f := fun n => imbalance (provable n) (unprovable n)
  -- Get the first threshold
  have hN : f N ≤ 0 := by unfold f; simp [imbalance]; omega
  obtain ⟨n, hn_le, hn_first⟩ := exists_first_threshold f N hN
  use n
  refine ⟨⟨hn_le, ?_, ?_, ?_⟩, ?_⟩
  -- Case 1: orderParameter n ≤ 1/2
  · rw [orderParameter_le_half_iff (hpositive n hn_le)]
    have := hn_first.1
    unfold f at this
    simp [imbalance] at this
    linarith
  -- Case 2: For all m < n, orderParameter m > 1/2
  · intro m hm
    rw [orderParameter_gt_half_iff (hpositive m (by linarith))]
    have := hn_first.2 m hm
    unfold f at this
    simp [imbalance] at this
    omega
  -- Case 3: For all m with n < m ≤ N, orderParameter m < 1/2
  · -- First establish orderParameter < 1/2 ↔ p < u
    have ord_lt_half : ∀ p u : ℕ, (0 < p + u) → (orderParameter p u < 1/2 ↔ p < u) := by
      intro p u htotal
      constructor
      · intro h
        by_contra hc
        push_neg at hc
        -- hc : u ≤ p
        -- Need to show orderParameter p u ≥ 1/2 to contradict h : orderParameter p u < 1/2
        have hge : orderParameter p u ≥ 1/2 := by
          have hpu : p ≥ u := hc
          by_contra hc2
          push_neg at hc2
          -- hc2 : orderParameter p u < 1/2
          -- Need to derive a contradiction from p ≥ u
          have hlt : p < u := by
            rw [orderParameter] at hc2
            have hpou : (0 : ℚ) < p + u := by norm_cast
            rw [div_lt_iff₀ hpou] at hc2
            have : (p : ℚ) < u := by linarith
            exact_mod_cast this
          linarith
        linarith
      · intro h
        rw [orderParameter]
        have hpou : (0 : ℚ) < p + u := by norm_cast
        rw [div_lt_iff₀ hpou]
        have : (p : ℚ) < u := by norm_cast
        linarith
    intro m hm1 hm2
    have := (ord_lt_half (provable m) (unprovable m)) (hpositive m hm2)
    rw [this]
    -- Now show provable m < unprovable m using strict decrease
    have hfdec : ∀ k, n < k → k ≤ N → f k < f n := by
      intro k hk1 hk2
      induction k with
      | zero => omega
      | succ k ih =>
        by_cases hk3 : n < k
        · have := ih hk3 (by linarith)
          have := hdec k (by linarith)
          linarith
        · push_neg at hk3
          have : k = n := by omega
          rw [this]
          exact hdec n (by omega)
    have hfm := hfdec m hm1 hm2
    have hfn : f n ≤ 0 := hn_first.1
    simp only [f, imbalance] at hfm hfn
    linarith
  -- Case 4: Uniqueness
  · intro y hy
    obtain ⟨hy_le, hy_le_half, hy_gt_half, _⟩ := hy
    -- y is a first threshold: f y ≤ 0 and ∀ m < y, f m > 0
    have hy_first : IsFirstThreshold f y := by
      constructor
      · -- f y ≤ 0 from hy_le_half
        rw [orderParameter_le_half_iff (hpositive y hy_le)] at hy_le_half
        simp only [f, imbalance]
        omega
      · -- ∀ m < y, f m > 0 from hy_gt_half
        intro m hm
        have := hy_gt_half m hm
        rw [orderParameter_gt_half_iff (hpositive m (by linarith))] at this
        simp only [f, imbalance]
        omega
    exact first_threshold_unique f hy_first hn_first

/-- A quantitative consequence: integer-valued strict decrease forces the
imbalance down by at least one unit per cutoff. -/
theorem imbalance_linear_drop (f : ℕ → ℤ) (N : ℕ)
    (hdec : ∀ n < N, f (n + 1) < f n) :
    f N ≤ f 0 - N := by
  induction N with
  | zero => simp
  | succ n ih =>
    have h := hdec n (Nat.lt_succ_self n)
    have ih' := ih (fun m hm => hdec m (Nat.lt_succ_of_lt hm))
    have h' : f (n + 1) + 1 ≤ f n := Int.lt_iff_add_one_le.mp h
    have hinj : (n : ℤ) + 1 = (n + 1 : ℕ) := by norm_cast
    linarith

/-- Consequently a positive initial excess cannot survive more cutoffs than
its integer magnitude under strict decrease. -/
theorem threshold_by_initial_imbalance (f : ℕ → ℤ) (N : ℕ)
    (hdec : ∀ n < N, f (n + 1) < f n)
    (hsize : f 0 ≤ N) :
    ∃ n ≤ N, IsFirstThreshold f n := by
  have hfN : f N ≤ 0 := by
    have := imbalance_linear_drop f N hdec
    linarith
  exact exists_first_threshold f N hfN

end ProofSpace