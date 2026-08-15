/-
# Non-negativity of the counting mutual information

The channel quantities used for the cyclic splitting-type channel are honest
information-theoretic objects: this file proves the Gibbs inequality for the
counting framework, i.e. `I(g ; k) ≥ 0` for every pair of read-outs of a finite
uniform source, and derives the sandwich `0 ≤ I(g ; k) ≤ H(g)`.

The proof is the classical one: `I` is the Kullback–Leibler divergence between
the joint law and the product of the marginals, and `log t ≤ t - 1`.
-/
import Shared.CyclicTypeChannel

namespace CyclicTypeChannel

open Finset

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-! ## 1. The analytic core -/

/-- Gibbs' term-wise estimate `q log₂(q/p) ≥ (q - p) / log 2`. -/
lemma gibbs_term {q p : ℝ} (hq : 0 ≤ q) (hp : 0 ≤ p) (hp' : q ≠ 0 → 0 < p) :
    (q - p) / Real.log 2 ≤ q * Real.logb 2 (q / p) := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  rcases hq.eq_or_lt with h0 | h0
  · rw [← h0]
    simp only [zero_mul, zero_sub]
    exact div_nonpos_of_nonpos_of_nonneg (by linarith) hlog2.le
  · have hp0 : 0 < p := hp' (ne_of_gt h0)
    have hkey : Real.log (p / q) ≤ p / q - 1 := Real.log_le_sub_one_of_pos (by positivity)
    have hpq : Real.log (p / q) = -Real.log (q / p) := by
      rw [← Real.log_inv, inv_div]
    have h1 : q - p ≤ q * Real.log (q / p) := by
      have h2 := mul_le_mul_of_nonneg_left hkey h0.le
      rw [hpq] at h2
      have h3 : q * (p / q - 1) = p - q := by field_simp
      rw [h3] at h2
      linarith
    have hsplit : q * Real.logb 2 (q / p) = (q * Real.log (q / p)) / Real.log 2 := by
      rw [Real.logb]
      ring
    rw [hsplit]
    gcongr

omit [DecidableEq β] [DecidableEq γ] in
/-- **Gibbs' inequality for a joint count array.** If `n c v` is a non-negative
array whose row sums are `M c`, and `m v`, `M c` are positive marginals adding
up to `N`, then the mutual-information sum is non-negative. -/
theorem gibbs_double (C : Finset γ) (T : Finset β) (N : ℝ) (hN : 0 < N)
    (n : γ → β → ℝ) (m : β → ℝ) (M : γ → ℝ)
    (hn : ∀ c v, 0 ≤ n c v) (hm : ∀ v ∈ T, 0 < m v) (hM : ∀ c ∈ C, 0 < M c)
    (hsm : ∑ v ∈ T, m v = N) (hsM : ∑ c ∈ C, M c = N)
    (hnv : ∀ c ∈ C, ∑ v ∈ T, n c v = M c) :
    0 ≤ ∑ c ∈ C, ∑ v ∈ T,
      (n c v / N) *
        (Real.logb 2 N - Real.logb 2 (m v) - Real.logb 2 (M c) + Real.logb 2 (n c v)) := by
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  -- term-wise Gibbs bound
  have key : ∀ c ∈ C, ∀ v ∈ T,
      (n c v / N - m v * M c / (N * N)) / Real.log 2
        ≤ (n c v / N) *
          (Real.logb 2 N - Real.logb 2 (m v) - Real.logb 2 (M c) + Real.logb 2 (n c v)) := by
    intro c hc v hv
    have hmv : 0 < m v := hm v hv
    have hMc : 0 < M c := hM c hc
    have hq : 0 ≤ n c v / N := div_nonneg (hn c v) hN.le
    have hppos : 0 < m v * M c / (N * N) := div_pos (mul_pos hmv hMc) (mul_pos hN hN)
    refine le_trans (gibbs_term hq hppos.le (fun _ => hppos)) (le_of_eq ?_)
    rcases (hn c v).eq_or_lt with h0 | h0
    · rw [← h0]
      simp
    · have hEq : (n c v / N) / (m v * M c / (N * N)) = n c v * N / (m v * M c) := by
        field_simp
      rw [hEq, Real.logb_div (by positivity) (by positivity),
        Real.logb_mul (ne_of_gt h0) (ne_of_gt hN), Real.logb_mul (ne_of_gt hmv) (ne_of_gt hMc)]
      ring
  refine le_trans ?_ (Finset.sum_le_sum fun c hc => Finset.sum_le_sum (key c hc))
  -- the lower bound telescopes to zero
  have h1 : ∑ c ∈ C, ∑ v ∈ T, n c v / N = 1 := by
    have hstep : ∑ c ∈ C, ∑ v ∈ T, n c v / N = (∑ c ∈ C, ∑ v ∈ T, n c v) / N := by
      simp only [← Finset.sum_div]
    rw [hstep, Finset.sum_congr rfl hnv, hsM, div_self (ne_of_gt hN)]
  have h2 : ∑ c ∈ C, ∑ v ∈ T, m v * M c / (N * N) = 1 := by
    have hstep : ∑ c ∈ C, ∑ v ∈ T, m v * M c / (N * N)
        = ((∑ v ∈ T, m v) * (∑ c ∈ C, M c)) / (N * N) := by
      rw [Finset.sum_mul, Finset.sum_div, Finset.sum_comm]
      refine Finset.sum_congr rfl fun v _ => ?_
      rw [Finset.mul_sum, Finset.sum_div]
    rw [hstep, hsm, hsM, div_self (by positivity)]
  have hzero : ∑ c ∈ C, ∑ v ∈ T, (n c v / N - m v * M c / (N * N)) = 0 := by
    simp only [Finset.sum_sub_distrib]
    rw [h1, h2, sub_self]
  have hcollapse : ∑ c ∈ C, ∑ v ∈ T, (n c v / N - m v * M c / (N * N)) / Real.log 2
      = (∑ c ∈ C, ∑ v ∈ T, (n c v / N - m v * M c / (N * N))) / Real.log 2 := by
    simp only [← Finset.sum_div]
  rw [hcollapse, hzero, zero_div]

/-! ## 2. The joint count array of two read-outs -/

section Joint

variable (s : Finset α) (g : α → β) (k : α → γ)

lemma jointCount_sum_g (c : γ) :
    ∑ v ∈ s.image g, #{x ∈ s | k x = c ∧ g x = v} = #{x ∈ s | k x = c} := by
  classical
  rw [Finset.card_eq_sum_card_fiberwise
    (f := g) (t := s.image g) (fun x hx => mem_image_of_mem g (mem_filter.1 hx).1)]
  exact Finset.sum_congr rfl fun v _ => by simp only [Finset.filter_filter]

lemma jointCount_sum_k (v : β) :
    ∑ c ∈ s.image k, #{x ∈ s | k x = c ∧ g x = v} = #{x ∈ s | g x = v} := by
  classical
  rw [Finset.card_eq_sum_card_fiberwise
    (f := k) (t := s.image k) (fun x hx => mem_image_of_mem k (mem_filter.1 hx).1)]
  refine Finset.sum_congr rfl fun c _ => ?_
  simp only [Finset.filter_filter]
  exact congrArg _ (Finset.filter_congr fun x _ => by tauto)

end Joint

/-- `uEnt` written as a sum over the image. -/
lemma uEnt_eq_image (s : Finset α) (g : α → β) :
    uEnt s g = Real.logb 2 s.card
      - (∑ v ∈ s.image g, (#{x ∈ s | g x = v} : ℝ) * Real.logb 2 (#{x ∈ s | g x = v} : ℝ))
        / s.card := by
  rw [uEnt, sum_logb_fiber]

/-- The conditional entropy in terms of the joint count array. -/
lemma condEnt_eq_joint (s : Finset α) (g : α → β) (k : α → γ) :
    condEnt s g k = ∑ c ∈ s.image k,
      (((#{x ∈ s | k x = c} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
        - (∑ v ∈ s.image g, (#{x ∈ s | k x = c ∧ g x = v} : ℝ)
            * Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ)) / s.card) := by
  classical
  refine Finset.sum_congr rfl fun c hc => ?_
  obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
  have hMc : (0 : ℝ) < (#{x ∈ s | k x = k a} : ℝ) := by
    exact_mod_cast fiber_card_pos ha
  have hfilter : ∀ v : β, {x ∈ {x ∈ s | k x = k a} | g x = v} = {x ∈ s | k x = k a ∧ g x = v} := by
    intro v
    simp only [Finset.filter_filter]
  have hsubset : ({x ∈ s | k x = k a}).image g ⊆ s.image g := by
    intro v hv
    obtain ⟨b, hb, rfl⟩ := mem_image.1 hv
    exact mem_image_of_mem g (mem_filter.1 hb).1
  have hzero : ∀ v ∈ s.image g, v ∉ ({x ∈ s | k x = k a}).image g →
      (#{x ∈ s | k x = k a ∧ g x = v} : ℝ)
        * Real.logb 2 (#{x ∈ s | k x = k a ∧ g x = v} : ℝ) = 0 := by
    intro v _ hv
    have hemp : {x ∈ {x ∈ s | k x = k a} | g x = v} = ∅ := by
      rw [Finset.filter_eq_empty_iff]
      intro x hx hgx
      exact hv (mem_image.2 ⟨x, hx, hgx⟩)
    rw [← hfilter v, hemp]
    simp
  have hsub : uEnt {x ∈ s | k x = k a} g
      = Real.logb 2 (#{x ∈ s | k x = k a} : ℝ)
        - (∑ v ∈ s.image g, (#{x ∈ s | k x = k a ∧ g x = v} : ℝ)
            * Real.logb 2 (#{x ∈ s | k x = k a ∧ g x = v} : ℝ))
          / (#{x ∈ s | k x = k a} : ℝ) := by
    rw [uEnt_eq_image]
    simp only [hfilter]
    rw [Finset.sum_subset hsubset hzero]
  rw [hsub]
  field_simp

/-- The mutual information of two read-outs as a single Kullback–Leibler sum. -/
lemma mutInfo_eq_double (s : Finset α) (g : α → β) (k : α → γ) (hs : s.Nonempty) :
    mutInfo s g k = ∑ c ∈ s.image k, ∑ v ∈ s.image g,
      ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | g x = v} : ℝ)
          - Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
          + Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ)) := by
  classical
  have hN0 : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast card_pos.2 hs
  have hsum_M : ∑ c ∈ s.image k, (#{x ∈ s | k x = c} : ℝ) = (s.card : ℝ) := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s k)
  have hsum_nv : ∀ c ∈ s.image k,
      ∑ v ∈ s.image g, (#{x ∈ s | k x = c ∧ g x = v} : ℝ) = (#{x ∈ s | k x = c} : ℝ) := by
    intro c _
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) (jointCount_sum_g s g k c)
  have hsum_nc : ∀ v ∈ s.image g,
      ∑ c ∈ s.image k, (#{x ∈ s | k x = c ∧ g x = v} : ℝ) = (#{x ∈ s | g x = v} : ℝ) := by
    intro v _
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) (jointCount_sum_k s g k v)
  have e1 : ∑ c ∈ s.image k, ∑ v ∈ s.image g,
      ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card) * Real.logb 2 (s.card : ℝ)
      = Real.logb 2 (s.card : ℝ) := by
    have hstep : ∑ c ∈ s.image k, ∑ v ∈ s.image g,
        ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card) * Real.logb 2 (s.card : ℝ)
        = ((∑ c ∈ s.image k, ∑ v ∈ s.image g, (#{x ∈ s | k x = c ∧ g x = v} : ℝ)) / s.card)
            * Real.logb 2 (s.card : ℝ) := by
      simp only [← Finset.sum_div, ← Finset.sum_mul]
    rw [hstep, Finset.sum_congr rfl hsum_nv, hsum_M, div_self (ne_of_gt hN0), one_mul]
  have e2 : ∑ c ∈ s.image k, ∑ v ∈ s.image g,
      ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | g x = v} : ℝ)
      = (∑ v ∈ s.image g,
          (#{x ∈ s | g x = v} : ℝ) * Real.logb 2 (#{x ∈ s | g x = v} : ℝ)) / s.card := by
    rw [Finset.sum_comm, Finset.sum_div]
    refine Finset.sum_congr rfl fun v hv => ?_
    rw [← Finset.sum_mul, ← Finset.sum_div, hsum_nc v hv, div_mul_eq_mul_div]
  have e3 : ∑ c ∈ s.image k, ∑ v ∈ s.image g,
      ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
      = ∑ c ∈ s.image k,
          ((#{x ∈ s | k x = c} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | k x = c} : ℝ) := by
    refine Finset.sum_congr rfl fun c hc => ?_
    rw [← Finset.sum_mul, ← Finset.sum_div, hsum_nv c hc]
  have e4 : ∑ c ∈ s.image k, ∑ v ∈ s.image g,
      ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card)
        * Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ)
      = ∑ c ∈ s.image k, (∑ v ∈ s.image g, (#{x ∈ s | k x = c ∧ g x = v} : ℝ)
          * Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ)) / s.card := by
    refine Finset.sum_congr rfl fun c _ => ?_
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun v _ => by ring
  have expand : ∑ c ∈ s.image k, ∑ v ∈ s.image g,
      ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card) *
        (Real.logb 2 (s.card : ℝ) - Real.logb 2 (#{x ∈ s | g x = v} : ℝ)
          - Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
          + Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ))
      = (∑ c ∈ s.image k, ∑ v ∈ s.image g,
            ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card) * Real.logb 2 (s.card : ℝ))
        - (∑ c ∈ s.image k, ∑ v ∈ s.image g,
            ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card)
              * Real.logb 2 (#{x ∈ s | g x = v} : ℝ))
        - (∑ c ∈ s.image k, ∑ v ∈ s.image g,
            ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card)
              * Real.logb 2 (#{x ∈ s | k x = c} : ℝ))
        + (∑ c ∈ s.image k, ∑ v ∈ s.image g,
            ((#{x ∈ s | k x = c ∧ g x = v} : ℝ) / s.card)
              * Real.logb 2 (#{x ∈ s | k x = c ∧ g x = v} : ℝ)) := by
    rw [← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun c _ => ?_
    rw [← Finset.sum_sub_distrib, ← Finset.sum_sub_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun v _ => by ring
  rw [expand, e1, e2, e3, e4, mutInfo, uEnt_eq_image, condEnt_eq_joint,
    Finset.sum_sub_distrib]
  ring

/-! ## 3. Non-negativity -/

/-- **Non-negativity of the counting mutual information** (Gibbs' inequality):
conditioning on a second read-out never increases the average uncertainty. -/
theorem mutInfo_nonneg (s : Finset α) (g : α → β) (k : α → γ) : 0 ≤ mutInfo s g k := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [mutInfo, condEnt, uEnt]
  have hN0 : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast card_pos.2 hs
  rw [mutInfo_eq_double s g k hs]
  refine gibbs_double (s.image k) (s.image g) (s.card : ℝ) hN0
    (fun c v => (#{x ∈ s | k x = c ∧ g x = v} : ℝ))
    (fun v => (#{x ∈ s | g x = v} : ℝ)) (fun c => (#{x ∈ s | k x = c} : ℝ))
    (fun c v => by positivity) ?_ ?_ ?_ ?_ ?_
  · intro v hv
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hv
    show (0 : ℝ) < (#{x ∈ s | g x = g a} : ℝ)
    exact_mod_cast fiber_card_pos ha
  · intro c hc
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
    show (0 : ℝ) < (#{x ∈ s | k x = k a} : ℝ)
    exact_mod_cast fiber_card_pos ha
  · show ∑ v ∈ s.image g, ((#{x ∈ s | g x = v} : ℕ) : ℝ) = (s.card : ℝ)
    exact_mod_cast sum_fiber_card s g
  · show ∑ c ∈ s.image k, ((#{x ∈ s | k x = c} : ℕ) : ℝ) = (s.card : ℝ)
    exact_mod_cast sum_fiber_card s k
  · intro c _
    show ∑ v ∈ s.image g, ((#{x ∈ s | k x = c ∧ g x = v} : ℕ) : ℝ)
      = ((#{x ∈ s | k x = c} : ℕ) : ℝ)
    exact_mod_cast jointCount_sum_g s g k c

/-- `0 ≤ I(g ; k) ≤ H(g)`: the channel of a read-out lies between zero and the
entropy of that read-out. -/
theorem mutInfo_le_uEnt (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k ≤ uEnt s g := by
  have hnn : 0 ≤ condEnt s g k := by
    refine Finset.sum_nonneg fun c _ => ?_
    have h1 : (0 : ℝ) ≤ (#{x ∈ s | k x = c} : ℝ) / s.card := by positivity
    exact mul_nonneg h1 (uEnt_nonneg _ _)
  simp only [mutInfo]
  linarith

/-- The `C n` type-pair channel is a genuine channel: `0 ≤ I_pair n ≤ H(Π)`. -/
theorem Ipair_mem_Icc (n : ℕ) : 0 ≤ Ipair n ∧ Ipair n ≤ pairEntropy n :=
  ⟨mutInfo_nonneg _ _ _, mutInfo_le_uEnt _ _ _⟩

end CyclicTypeChannel