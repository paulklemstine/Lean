import Mathlib

/-!
# Recursive mixed-radix representations

This file isolates the general mixed-radix mechanism behind factoradics and
recursive-base systems.  A radix sequence `r` determines place values
`weight r 0 = 1` and `weight r (k+1) = r k * weight r k`.

The main results prove, constructively and without cardinality arguments, that
valid length-`k` digit strings represent exactly the naturals below
`weight r k`, and do so uniquely.
-/

namespace RecursiveMixedRadix

open Finset

/-- Place values associated to a sequence of radices. -/
def weight (r : ℕ → ℕ) : ℕ → ℕ
  | 0 => 1
  | k + 1 => r k * weight r k

/-- Value of the first `k` mixed-radix digits. -/
def value (r c : ℕ → ℕ) (k : ℕ) : ℕ :=
  ∑ i ∈ Finset.range k, c i * weight r i

/-- Every digit lies below its local radix. -/
def Valid (r c : ℕ → ℕ) (k : ℕ) : Prop :=
  ∀ i < k, c i < r i

/-- The canonical digit extracted by division and remainder. -/
def digit (r : ℕ → ℕ) (n i : ℕ) : ℕ :=
  (n / weight r i) % r i

@[simp] theorem weight_zero (r : ℕ → ℕ) : weight r 0 = 1 := by rfl

@[simp] theorem weight_succ (r : ℕ → ℕ) (k : ℕ) :
    weight r (k + 1) = r k * weight r k := by rfl

@[simp] theorem value_zero (r c : ℕ → ℕ) : value r c 0 = 0 := by
  simp [value]

theorem value_succ (r c : ℕ → ℕ) (k : ℕ) :
    value r c (k + 1) = value r c k + c k * weight r k := by
  simp [value, Finset.sum_range_succ]

theorem Valid.of_succ {r c : ℕ → ℕ} {k : ℕ} (h : Valid r c (k + 1)) :
    Valid r c k := fun i hi => h i (Nat.lt_succ_of_lt hi)

/-- Valid lower digits always form a number below the next place value. -/
theorem value_lt {r c : ℕ → ℕ} (hr : ∀ i, 0 < r i) {k : ℕ}
    (hc : Valid r c k) : value r c k < weight r k := by
  induction k with
  | zero => simp [value_zero, weight_zero]
  | succ k ih =>
    have hck : c k < r k := hc k (Nat.lt_succ_self k)
    rw [value_succ, weight_succ]
    have hpos : 0 < weight r k := by
      exact Nat.rec (by simp [weight_zero]) (fun m ihm => by simp [weight_succ, Nat.mul_pos (hr m) ihm]) k
    have h1 : value r c k < weight r k := ih (hc.of_succ)
    have h2 : r k ≥ 1 := hr k
    have h3 : weight r k ≥ 1 := hpos
    have h4 : value r c k ≤ weight r k - 1 := Nat.le_sub_one_of_lt h1
    have h5 : c k ≤ r k - 1 := Nat.le_sub_one_of_lt hck
    have h6 : c k * weight r k ≤ (r k - 1) * weight r k := Nat.mul_le_mul_right _ h5
    have h7 : (weight r k - 1) + (r k - 1) * weight r k = r k * weight r k - 1 := by
      have hmul : (r k - 1) * weight r k = r k * weight r k - weight r k := by
        rw [tsub_mul, one_mul]
      rw [hmul]
      have hle : weight r k ≤ r k * weight r k := by nlinarith
      omega
    have h8 : c k * weight r k < r k * weight r k := (Nat.mul_lt_mul_right hpos).mpr hck
    calc value r c k + c k * weight r k ≤ (weight r k - 1) + (r k - 1) * weight r k := Nat.add_le_add h4 h6
      _ = r k * weight r k - 1 := h7
      _ < r k * weight r k := Nat.sub_lt (by positivity) (by norm_num)

/-- Dividing by the current place value recovers the top digit. -/
theorem splitting_div {r c : ℕ → ℕ} (hr : ∀ i, 0 < r i) {k : ℕ}
    (hc : Valid r c (k + 1)) :
    value r c (k + 1) / weight r k = c k := by
  rw [value_succ]
  have hval : value r c k < weight r k := value_lt hr (hc.of_succ)
  have hpos : 0 < weight r k := by
    exact Nat.rec (by simp [weight_zero])
      (fun m ihm => by simp [weight_succ, Nat.mul_pos (hr m) ihm]) k
  calc
    (value r c k + c k * weight r k) / weight r k =
        (value r c k + weight r k * c k) / weight r k := by rw [Nat.mul_comm]
    _ = value r c k / weight r k + c k := Nat.add_mul_div_left _ _ hpos
    _ = 0 + c k := by rw [Nat.div_eq_of_lt hval]
    _ = c k := by omega

/-- Taking the remainder modulo the current place value removes the top digit. -/
theorem splitting_mod {r c : ℕ → ℕ} (hr : ∀ i, 0 < r i) {k : ℕ}
    (hc : Valid r c (k + 1)) :
    value r c (k + 1) % weight r k = value r c k := by
  rw [value_succ]
  have hvlt : value r c k < weight r k := value_lt hr (hc.of_succ)
  rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hvlt]

/-- Direct uniqueness of bounded mixed-radix representations. -/
theorem value_unique {r c d : ℕ → ℕ} (hr : ∀ i, 0 < r i) {k : ℕ}
    (hc : Valid r c k) (hd : Valid r d k)
    (hv : value r c k = value r d k) : ∀ i < k, c i = d i := by
  -- Key lemma: if c and d agree on all j < i, then value r c i = value r d i
  have agree_implies_value : ∀ i, (∀ j < i, c j = d j) → value r c i = value r d i := by
    intro i hagree
    induction i with
    | zero => simp [value_zero]
    | succ i ih => 
      have hci_di : c i = d i := hagree i (Nat.lt_succ_self i)
      have hvic : value r c i = value r d i := ih (fun j hj => hagree j (Nat.lt_succ_of_lt hj))
      rw [value_succ, value_succ, hvic, hci_di]
  -- Now prove the main result by contradiction
  by_contra hne
  push_neg at hne
  obtain ⟨i, hi_lt, hi_ne⟩ := hne
  -- Take the largest index where they differ
  have hne_set : (Finset.filter (fun j => j < k ∧ c j ≠ d j) (Finset.range (k + 1))).Nonempty := by
    use i
    simp [hi_lt, hi_ne]
    omega
  let m := Finset.max' _ hne_set
  have hm_mem : m < k ∧ c m ≠ d m := by
    have h := Finset.mem_filter.mp (Finset.max'_mem _ hne_set)
    simp only [Finset.mem_range] at h
    exact ⟨h.2.1, h.2.2⟩
  -- All indices j with m < j < k have c j = d j
  have hm_max : ∀ j, m < j → j < k → c j = d j := by
    intro j hj_lt hj_lt_k
    by_contra hne_j
    have hj_mem : j ∈ Finset.filter (fun j => j < k ∧ c j ≠ d j) (Finset.range (k + 1)) := by
      simp only [Finset.mem_filter, Finset.mem_range]
      exact ⟨by omega, hj_lt_k, hne_j⟩
    have hj_le_m : j ≤ m := Finset.le_max' _ _ hj_mem
    exact absurd hj_lt (not_lt.mpr hj_le_m)
  -- value r c k = value r d k, and they agree on indices m+1 to k-1
  -- So value r c (m+1) = value r d (m+1)
  -- Use splitting_mod: value r c (m+1) = value r c k % weight r (m+1)
  -- and the sum over [m+1, k) is the same for both
  have hval_m1_eq : value r c (m + 1) = value r d (m + 1) := by
    -- value r c k = value r c (m+1) + sum over [m+1, k)
    have hck : m + 1 ≤ k := by omega
    have hcalc_c : value r c k = value r c (m + 1) + ∑ j ∈ Ico (m + 1) k, c j * weight r j := by
      rw [value, value, ← Finset.sum_range_add_sum_Ico _ hck]
    have hcalc_d : value r d k = value r d (m + 1) + ∑ j ∈ Ico (m + 1) k, d j * weight r j := by
      rw [value, value, ← Finset.sum_range_add_sum_Ico _ hck]
    have hsum_eq : ∑ j ∈ Ico (m + 1) k, c j * weight r j = ∑ j ∈ Ico (m + 1) k, d j * weight r j := by
      apply Finset.sum_congr rfl
      intro j hj
      rw [hm_max j (Finset.mem_Ico.mp hj).1 (Finset.mem_Ico.mp hj).2]
    rw [hcalc_c, hcalc_d, hsum_eq] at hv
    omega
  -- By splitting_div, c m = value r c (m+1) / weight r m = value r d (m+1) / weight r m = d m
  have hcm : value r c (m + 1) / weight r m = c m := splitting_div hr (fun i hi => hc i (by omega))
  have hdm : value r d (m + 1) / weight r m = d m := splitting_div hr (fun i hi => hd i (by omega))
  rw [hval_m1_eq] at hcm
  rw [hcm] at hdm
  exact hm_mem.2 hdm

/-- Canonically extracted digits satisfy their local bounds. -/
theorem digit_valid {r : ℕ → ℕ} (hr : ∀ i, 0 < r i) (n k : ℕ) :
    Valid r (digit r n) k := by
  intro i _
  exact Nat.mod_lt _ (hr i)

/-- A telescoping division identity underlying existence. -/
theorem digit_decomposition {r : ℕ → ℕ} (n k : ℕ) :
    n = value r (digit r n) k + (n / weight r k) * weight r k := by
  induction k with
  | zero => simp [value_zero, weight_zero]
  | succ k ih =>
    rw [value_succ, weight_succ]
    have div_eq : n / weight r k / r k = n / (r k * weight r k) := by
      rw [Nat.mul_comm]
      exact Nat.div_div_eq_div_mul n (weight r k) (r k)
    rw [← div_eq]
    have da := Nat.div_add_mod (n / weight r k) (r k)
    have digit_eq : digit r n k = n / weight r k % r k := rfl
    have key : n / weight r k * weight r k = digit r n k * weight r k + n / (r k * weight r k) * (r k * weight r k) := by
      calc n / weight r k * weight r k
          = (r k * (n / weight r k / r k) + n / weight r k % r k) * weight r k := by rw [da]
        _ = r k * (n / weight r k / r k) * weight r k + n / weight r k % r k * weight r k := by ring
        _ = n / weight r k / r k * (r k * weight r k) + digit r n k * weight r k := by rw [digit_eq]; ring
        _ = n / (r k * weight r k) * (r k * weight r k) + digit r n k * weight r k := by rw [← div_eq]
        _ = digit r n k * weight r k + n / (r k * weight r k) * (r k * weight r k) := by ring
    calc n
        = value r (digit r n) k + n / weight r k * weight r k := ih
      _ = value r (digit r n) k + (digit r n k * weight r k + n / (r k * weight r k) * (r k * weight r k)) := by rw [key]
      _ = value r (digit r n) k + digit r n k * weight r k + n / (r k * weight r k) * (r k * weight r k) := by ring
      _ = value r (digit r n) k + digit r n k * weight r k + n / weight r k / r k * (r k * weight r k) := by rw [← div_eq]

/-- Every natural below the next place value has its canonical representation. -/
theorem value_digit {r : ℕ → ℕ} {n k : ℕ}
    (hn : n < weight r k) : value r (digit r n) k = n := by
  have hdiv : n / weight r k = 0 := Nat.div_eq_of_lt hn
  have h := digit_decomposition (r := r) n k
  simp [hdiv] at h
  exact h.symm

end RecursiveMixedRadix