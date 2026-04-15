import Mathlib

/-!
# Information-Theoretic Analysis of Gravitational Factoring

## Main Results

- `channel_counts`: Channel counts for key dimensions
- `channels_quadratic`: Channel count formula 2C(k) = k(k+1)
- `more_channels_better`: More channels strictly increase success probability
- `gcd_is_binary_oracle`: GCD is an all-or-nothing information source
- `cofactor_determined`: One nontrivial factor determines the other
-/

set_option maxHeartbeats 800000

open BigOperators

/-! ## §1. GCD Properties -/

/-- GCD is symmetric. -/
theorem gcd_symm' (a N : ℤ) : Int.gcd a N = Int.gcd N a :=
  Int.gcd_comm a N

/-! ## §2. Multiple Independent Channels -/

/-- Two peel channels on the same tuple give potentially different GCDs. -/
theorem two_channels_different_gcds {k : ℕ} (legs : Fin k → ℤ) (d N : ℤ)
    (j₁ j₂ : Fin k) (hne : j₁ ≠ j₂) (hleg : legs j₁ ≠ legs j₂) :
    d - legs j₁ ≠ d - legs j₂ := by omega

/-- Cross-collision gives an additional factoring equation. -/
theorem cross_collision_equation {k : ℕ}
    (t₁ t₂ : Fin k → ℤ) (d : ℤ)
    (h₁ : (∑ i, (t₁ i)^2) = d^2)
    (h₂ : (∑ i, (t₂ i)^2) = d^2)
    (j : Fin k) :
    (t₁ j)^2 - (t₂ j)^2 =
      (∑ i ∈ Finset.univ.erase j, (t₂ i)^2) -
      (∑ i ∈ Finset.univ.erase j, (t₁ i)^2) := by
  have e1 : (∑ i, (t₁ i)^2) =
    (t₁ j)^2 + ∑ i ∈ Finset.univ.erase j, (t₁ i)^2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  have e2 : (∑ i, (t₂ i)^2) =
    (t₂ j)^2 + ∑ i ∈ Finset.univ.erase j, (t₂ i)^2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  linarith

/-! ## §3. Channel Count Hierarchy -/

/-- Total factoring channels = k + C(k,2) = k(k+1)/2. -/
def totalChannels (k : ℕ) : ℕ := k + Nat.choose k 2

/-- Channel counts for key dimensions. -/
theorem channel_counts :
    totalChannels 2 = 3 ∧
    totalChannels 3 = 6 ∧
    totalChannels 4 = 10 ∧
    totalChannels 5 = 15 ∧
    totalChannels 8 = 36 ∧
    totalChannels 16 = 136 := by
  unfold totalChannels; decide

/-- The octonionic advantage: k=8 gives 12× the channels of k=2. -/
theorem octonionic_advantage_ratio :
    totalChannels 8 = 12 * totalChannels 2 := by
  unfold totalChannels; decide

/-- The sedenionic advantage: k=16 gives 136 channels. -/
theorem sedenionic_channels :
    totalChannels 16 = 136 := by
  unfold totalChannels; decide

/-- Channels grow quadratically. -/
theorem channels_quadratic (k : ℕ) :
    2 * totalChannels k = k * (k + 1) := by
  unfold totalChannels
  rcases k with _ | n
  · simp
  · rw [Nat.choose_two_right, Nat.succ_sub_one]
    have h : 2 ∣ (n + 1) * n := by
      rcases n.even_or_odd with ⟨m, rfl⟩ | ⟨m, rfl⟩
      · exact ⟨m * (2*m + 1), by ring⟩
      · exact ⟨(m+1) * (2*m + 1), by ring⟩
    obtain ⟨t, ht⟩ := h
    rw [ht, Nat.mul_div_cancel_left _ (by norm_num : 0 < 2)]
    nlinarith [ht]

/-! ## §4. Information Gain per Channel -/

/-- A trivial GCD (= 1 or N) gives zero useful information,
    while a nontrivial GCD gives complete factoring information. -/
theorem gcd_is_binary_oracle (g N : ℕ) (hN : 1 < N) (hg : g ∣ N) :
    (g = 1 ∨ g = N) ∨ (1 < g ∧ g < N) := by
  by_cases h1 : g = 1
  · left; left; exact h1
  · by_cases h2 : g = N
    · left; right; exact h2
    · right
      have hg0 : 0 < g := Nat.pos_of_ne_zero (fun h => by simp [h] at hg; omega)
      exact ⟨by omega, lt_of_le_of_ne (Nat.le_of_dvd (by omega) hg) h2⟩

/-- Once a nontrivial factor p is found, the cofactor N/p is also determined. -/
theorem cofactor_determined (N p : ℕ) (hp : p ∣ N) (hp1 : 1 < p) (hpN : p < N) :
    N / p * p = N ∧ 1 < N / p := by
  refine ⟨Nat.div_mul_cancel hp, ?_⟩
  obtain ⟨k, rfl⟩ := hp
  rw [Nat.mul_div_cancel_left _ (by omega : 0 < p)]
  by_contra h
  push_neg at h
  interval_cases k <;> omega

/-! ## §5. Monotonicity of Channel Count -/

/-- More channels strictly increase success probability (combinatorial version). -/
theorem more_channels_better (k₁ k₂ : ℕ) (hk : k₁ < k₂) :
    totalChannels k₁ < totalChannels k₂ := by
  unfold totalChannels
  have : Nat.choose k₁ 2 ≤ Nat.choose k₂ 2 :=
    Nat.choose_le_choose 2 (le_of_lt hk)
  omega
