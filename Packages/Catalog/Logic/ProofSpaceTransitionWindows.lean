import Mathlib

/-!
# Transition Windows from Block Drift

A pointwise decrease assumption can be too rigid for cumulative proof-space
statistics.  This file replaces it by strict negative drift only at regularly
spaced block endpoints.  The resulting theorem produces a unique first sampled
crossing, proves permanence at all later sampled endpoints, and localizes the
unsampled crossing to one block of indices.
-/

namespace ProofSpaceTransitionWindows

/-- The signed excess in the exact shell at cutoff `n`. -/
def shellImbalance (provable unprovable : ℕ → ℕ) (n : ℕ) : ℤ :=
  (provable n : ℤ) - (unprovable n : ℤ)

/-- The cumulative signed excess through cutoff `n`. -/
def cumulativeImbalance (provable unprovable : ℕ → ℕ) (n : ℕ) : ℤ :=
  ∑ i ∈ Finset.range (n + 1), shellImbalance provable unprovable i

/-- Adding one exact-length shell changes cumulative imbalance by precisely that
shell's imbalance. -/
theorem cumulativeImbalance_succ (provable unprovable : ℕ → ℕ) (n : ℕ) :
    cumulativeImbalance provable unprovable (n + 1) =
      cumulativeImbalance provable unprovable n +
        shellImbalance provable unprovable (n + 1) := by
  simp [cumulativeImbalance, Finset.sum_range_succ]

/-- Strict descent of cumulative imbalance is equivalent to an unresolved
majority in every newly added shell. -/
theorem cumulative_strictDecrease_iff_shell_negative
    (provable unprovable : ℕ → ℕ) (N : ℕ) :
    (∀ n < N,
      cumulativeImbalance provable unprovable (n + 1) <
        cumulativeImbalance provable unprovable n) ↔
    (∀ n < N, shellImbalance provable unprovable (n + 1) < 0) := by
  constructor
  · intro h n hn
    have hstep := h n hn
    rw [cumulativeImbalance_succ] at hstep
    linarith
  · intro h n hn
    have hshell := h n hn
    rw [cumulativeImbalance_succ]
    linarith

/-- A uniform shell deficit gives a linear upper bound on cumulative imbalance. -/
theorem cumulative_linear_decay
    (provable unprovable : ℕ → ℕ) (N : ℕ) (d : ℤ)
    (hdeficit : ∀ n < N,
      shellImbalance provable unprovable (n + 1) ≤ -d) :
    cumulativeImbalance provable unprovable N ≤
      cumulativeImbalance provable unprovable 0 - N * d := by
  induction N with
  | zero => simp [cumulativeImbalance]
  | succ N ih =>
    have ih' := ih (fun n hn => hdeficit n (Nat.lt_succ_of_lt hn))
    have hshell := hdeficit N (Nat.lt_succ_self N)
    simp only [cumulativeImbalance, Finset.sum_range_succ, Finset.sum_range_zero] at *
    simp at *
    ring_nf at *
    linarith

/-- A sampled endpoint is the first nonpositive endpoint when all earlier
sampled endpoints are positive. -/
def IsFirstSampledThreshold (f : ℕ → ℤ) (block k : ℕ) : Prop :=
  f (k * block) ≤ 0 ∧ ∀ j < k, 0 < f (j * block)

/-- **Block-drift transition theorem.** If imbalance strictly decreases between
successive block endpoints and is nonpositive at endpoint `K`, there is a unique
first sampled crossing. Every later sampled endpoint through `K` is negative.
Moreover, if the initial endpoint is positive, the actual sign change is
localized between the preceding and crossing endpoints, a window of width one
block. -/
theorem unique_transition_window
    (f : ℕ → ℤ) (block K : ℕ)
    (hblock : ∀ k < K, f ((k + 1) * block) < f (k * block))
    (hfinal : f (K * block) ≤ 0) :
    ∃! k : ℕ, k ≤ K ∧ IsFirstSampledThreshold f block k ∧
      (∀ j, k < j → j ≤ K → f (j * block) < 0) ∧
      (0 < f 0 → 0 < k ∧
        0 < f ((k - 1) * block) ∧ f (k * block) ≤ 0) := by
  -- Define k as the first index where f(k*block) ≤ 0
  have hexists : ∃ k ≤ K, f (k * block) ≤ 0 := ⟨K, le_refl K, hfinal⟩
  -- Use well-founded recursion to find the minimum such k
  let S := {k | k ≤ K ∧ f (k * block) ≤ 0}
  have hSnonempty : S.Nonempty := ⟨K, by simp [S, hfinal]⟩
  let k := Nat.find hSnonempty
  have hk_mem : k ∈ S := Nat.find_spec hSnonempty
  have hk_le : k ≤ K := hk_mem.1
  have hk_neg : f (k * block) ≤ 0 := hk_mem.2
  -- k is the first index with f(k*block) ≤ 0, so for j < k, f(j*block) > 0
  have hfirst : ∀ j < k, 0 < f (j * block) := by
    intro j hj
    by_contra h
    push_neg at h
    have hjK : j < K := Nat.lt_of_lt_of_le hj hk_le
    have hble : j ≤ K := Nat.le_of_lt hjK
    have hjinS : j ∈ S := ⟨hble, h⟩
    exact Nat.find_min hSnonempty hj hjinS
  -- Helper: for n < m ≤ K, f(m*block) < f(n*block)
  have hdecr : ∀ n m, n < m → m ≤ K → f (m * block) < f (n * block) := by
    intro n m hnm hmK
    induction m using Nat.strong_induction_on with
    | _ m ih =>
      by_cases hnm' : n + 1 = m
      · subst hnm'; exact hblock n (by omega)
      · have hnm'' : n < m - 1 := by omega
        have hmK' : m - 1 ≤ K := by omega
        have := ih (m - 1) (by omega) hnm'' hmK'
        have hb := hblock (m - 1) (by omega)
        simp only [Nat.sub_add_cancel (by omega : 1 ≤ m)] at hb
        exact lt_trans hb this
  -- Now prove the main result
  use k
  refine ⟨⟨hk_le, ?_, ?_, ?_⟩, ?_⟩
  -- Prove IsFirstSampledThreshold f block k
  · exact ⟨hk_neg, hfirst⟩
  -- Prove ∀ j, k < j → j ≤ K → f (j * block) < 0
  · exact fun j hkj hjK => lt_of_lt_of_le (hdecr k j hkj hjK) hk_neg
  -- Prove the conditional about k > 0
  · intro hf0
    refine ⟨?_, ?_, hk_neg⟩
    · -- k > 0
      by_contra hk0
      push_neg at hk0
      interval_cases k
      simp at hk_neg
      linarith
    · -- f ((k-1) * block) > 0
      have hkpos : 0 < k := by
        by_contra hk0
        push_neg at hk0
        interval_cases k
        simp at hk_neg
        linarith
      exact hfirst _ (Nat.sub_lt hkpos zero_lt_one)
  -- Prove uniqueness
  · intro y hy
    obtain ⟨hy_le, hy_thresh, _, _⟩ := hy
    -- y is also the first index where f(y * block) ≤ 0
    rw [IsFirstSampledThreshold] at hy_thresh
    obtain ⟨hy_neg, hy_first⟩ := hy_thresh
    -- Show y = k by antisymmetry
    apply le_antisymm
    · -- y ≤ k: if k < y, then f(k*block) > 0 by hy_first, contradicting hk_neg
      by_contra hk
      push_neg at hk
      have := hy_first k hk
      linarith
    · -- k ≤ y: if y < k, then f(y*block) > 0 by hfirst, contradicting hy_neg
      by_contra hy
      push_neg at hy
      have := hfirst y hy
      linarith

/-- Integer-valued block descent forces at least one unit of decay per block. -/
theorem sampled_linear_decay
    (f : ℕ → ℤ) (block K : ℕ)
    (hblock : ∀ k < K, f ((k + 1) * block) < f (k * block)) :
    f (K * block) ≤ f 0 - K := by
  induction K with
  | zero => simp
  | succ K ih =>
    have h1 := hblock K (Nat.lt_succ_self K)
    have h2 := ih (fun k hk => hblock k (Nat.lt_of_lt_of_le hk (Nat.le_succ K)))
    have hcast : ((K + 1 : ℕ) : ℤ) = (K : ℤ) + 1 := by simp
    linarith

/-- If the number of sampled blocks is at least the initial integer imbalance,
then a sampled threshold must occur by the final endpoint. -/
theorem sampled_threshold_by_initial_imbalance
    (f : ℕ → ℤ) (block K : ℕ)
    (hblock : ∀ k < K, f ((k + 1) * block) < f (k * block))
    (hsize : f 0 ≤ K) :
    ∃ k ≤ K, IsFirstSampledThreshold f block k := by
  -- First, show f (K * block) ≤ 0 using linear decay
  have hK : f (K * block) ≤ 0 := by
    have := sampled_linear_decay f block K hblock
    linarith
  -- Use Nat.find to get the first k ≤ K with f (k * block) ≤ 0
  let k := Nat.find (⟨K, le_rfl, hK⟩ : ∃ m, m ≤ K ∧ f (m * block) ≤ 0)
  use k
  constructor
  · -- Show k ≤ K
    have hspec := Nat.find_spec (⟨K, le_rfl, hK⟩ : ∃ m, m ≤ K ∧ f (m * block) ≤ 0)
    exact hspec.1
  · -- Show IsFirstSampledThreshold f block k
    have hspec := Nat.find_spec (⟨K, le_rfl, hK⟩ : ∃ m, m ≤ K ∧ f (m * block) ≤ 0)
    constructor
    · -- f (k * block) ≤ 0
      exact hspec.2
    · -- ∀ j < k, 0 < f (j * block)
      intro j hj
      by_contra h
      push_neg at h
      -- If f (j * block) ≤ 0, then j is a valid witness with j < k
      have hk_le_K : k ≤ K := hspec.1
      have hj_le_K : j ≤ K := by linarith
      have hj_valid : j ≤ K ∧ f (j * block) ≤ 0 := ⟨hj_le_K, h⟩
      have hex : ∃ n, n ≤ K ∧ f (n * block) ≤ 0 := Exists.intro K (And.intro le_rfl hK)
      have hji : j ≤ K ∧ f (j * block) ≤ 0 := And.intro hj_le_K h
      exact Nat.find_min hex hj hji

end ProofSpaceTransitionWindows