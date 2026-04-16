/-! # CatalogBuild.Pythagorean.GravitationalFactoring.Foundations

Auto-generated from theorem catalog database.
Domain: Pythagorean/GravitationalFactoring
Declarations: 32
-/

import Mathlib

/-- The energy functional on integer 4-tuples. -/
def pythagoreanEnergy (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 - d ^ 2



/-- Energy zero characterizes Pythagorean quadruples. -/
theorem energy_zero_iff_quadruple (a b c d : ℤ) :
    pythagoreanEnergy a b c d = 0 ↔ a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2 := by
  unfold pythagoreanEnergy; omega



/-- The root quadruple (0, 0, 1, 1) has zero energy. -/
theorem root_energy_zero : pythagoreanEnergy 0 0 1 1 = 0 := by
  unfold pythagoreanEnergy; ring



/-- A Pythagorean (k+1)-tuple: Σᵢ vᵢ² = d² where v has k components. -/
structure PythKTuple (k : ℕ) where
  legs : Fin k → ℤ
  hyp : ℤ
  eq : (∑ i, (legs i) ^ 2) = hyp ^ 2



/-- Energy for k-tuples. -/
def ktupleEnergy (k : ℕ) (legs : Fin k → ℤ) (d : ℤ) : ℤ :=
  (∑ i, (legs i) ^ 2) - d ^ 2



/-- Energy zero characterizes valid k-tuples. -/
theorem ktuple_energy_zero_iff (k : ℕ) (legs : Fin k → ℤ) (d : ℤ) :
    ktupleEnergy k legs d = 0 ↔ (∑ i, (legs i) ^ 2) = d ^ 2 := by
  unfold ktupleEnergy; omega



/-- Peeling off the j-th component from a k-tuple gives a factored form. -/
theorem ktuple_peel_channel {k : ℕ} (t : PythKTuple k) (j : Fin k) :
    (t.hyp - t.legs j) * (t.hyp + t.legs j) =
      ∑ i ∈ Finset.univ.erase j, (t.legs i) ^ 2 := by
  have h := t.eq
  have hsplit : (∑ i, (t.legs i) ^ 2) =
      (t.legs j) ^ 2 + ∑ i ∈ Finset.univ.erase j, (t.legs i) ^ 2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ j)]
  rw [hsplit] at h
  nlinarith



/-- The number of peel channels for a k-tuple is k. -/
theorem peel_channel_count (k : ℕ) : Fintype.card (Fin k) = k := by simp



/-- Two k-tuples sharing a hypotenuse give equal sums of squares. -/
theorem shared_hypotenuse_collision {k : ℕ}
    (t₁ t₂ : PythKTuple k) (h_shared : t₁.hyp = t₂.hyp) :
    (∑ i, (t₁.legs i) ^ 2) = (∑ i, (t₂.legs i) ^ 2) := by
  rw [t₁.eq, t₂.eq, h_shared]



/-- Cross-collision: the difference at index i equals the complementary sum difference. -/
theorem cross_collision_difference {k : ℕ}
    (t₁ t₂ : PythKTuple k) (h_shared : t₁.hyp = t₂.hyp)
    (i : Fin k) :
    (t₁.legs i) ^ 2 - (t₂.legs i) ^ 2 =
      (∑ idx ∈ Finset.univ.erase i, (t₂.legs idx) ^ 2) -
        (∑ idx ∈ Finset.univ.erase i, (t₁.legs idx) ^ 2) := by
  have h1 := t₁.eq
  have h2 := t₂.eq
  have e1 : (∑ idx, (t₁.legs idx) ^ 2) =
    (t₁.legs i) ^ 2 + ∑ idx ∈ Finset.univ.erase i, (t₁.legs idx) ^ 2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
  have e2 : (∑ idx, (t₂.legs idx) ^ 2) =
    (t₂.legs i) ^ 2 + ∑ idx ∈ Finset.univ.erase i, (t₂.legs idx) ^ 2 := by
    rw [← Finset.add_sum_erase _ _ (Finset.mem_univ i)]
  rw [e1] at h1; rw [e2] at h2; rw [h_shared] at h1
  omega



/-- A peel channel gives gcd(d-aⱼ, N) as a candidate factor. -/
theorem peel_gcd_candidate {k : ℕ} (t : PythKTuple k) (j : Fin k) (N : ℤ) :
    ↑(Int.gcd (t.hyp - t.legs j) N) ∣ N :=
  Int.gcd_dvd_right _ _



/-- Multiple peel channels give independent GCD computations. -/
theorem multi_peel_gcds {k : ℕ} (t : PythKTuple k) (N : ℤ) :
    ∀ j : Fin k, ↑(Int.gcd (t.hyp - t.legs j) N) ∣ N :=
  fun j => peel_gcd_candidate t j N



/-- The product of two peel-channel GCDs divides a square. -/
theorem gcd_product_divides_sq {k : ℕ} (t : PythKTuple k) (j₁ j₂ : Fin k) :
    (↑(Int.gcd (t.hyp - t.legs j₁) (t.legs j₂)) : ℤ) *
      ↑(Int.gcd (t.hyp + t.legs j₁) (t.legs j₂)) ∣ (t.legs j₂) ^ 2 := by
  rw [sq]; exact mul_dvd_mul (Int.gcd_dvd_right _ _) (Int.gcd_dvd_right _ _)



/-- If N divides the sum of squares, it divides d². -/
theorem modular_target_condition (a b c d N : ℤ)
    (h_pyth : a ^ 2 + b ^ 2 + c ^ 2 = d ^ 2)
    (h_mod : N ∣ (a ^ 2 + b ^ 2 + c ^ 2)) :
    N ∣ d ^ 2 := by
  rw [← h_pyth]; exact h_mod



/-- If p is prime and p*q divides d², then p divides d. -/
theorem prime_factor_from_square_div (d p q : ℤ) (hp : Prime p)
    (hpq : p * q ∣ d ^ 2) : p ∣ d := by
  have h1 : p ∣ d ^ 2 := dvd_trans (dvd_mul_right p q) hpq
  rw [sq, hp.dvd_mul] at h1
  exact h1.elim id id



/-- The quaternion norm. -/
def quaternionNorm (a b c d : ℤ) : ℤ := a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2



/-- Quaternion decompositions of p and q give a decomposition of p*q. -/
theorem quaternion_factor_product (p q : ℤ)
    (a₁ b₁ c₁ d₁ a₂ b₂ c₂ d₂ : ℤ)
    (hp : quaternionNorm a₁ b₁ c₁ d₁ = p)
    (hq : quaternionNorm a₂ b₂ c₂ d₂ = q) :
    quaternionNorm
      (a₁*a₂ + b₁*b₂ + c₁*c₂ + d₁*d₂)
      (a₁*b₂ - b₁*a₂ + c₁*d₂ - d₁*c₂)
      (a₁*c₂ - c₁*a₂ + d₁*b₂ - b₁*d₂)
      (a₁*d₂ - d₁*a₂ + b₁*c₂ - c₁*b₂) = p * q := by
  rw [← hp, ← hq, ← euler_four_square_identity]



/-- Total factoring channels. -/
def totalFactoringChannels (k : ℕ) : ℕ := k + Nat.choose k 2



/-- Cross-collision pairs grow quadratically. -/
theorem cross_collision_growth :
    crossCollisionPairs 3 = 3 ∧
    crossCollisionPairs 4 = 6 ∧
    crossCollisionPairs 5 = 10 ∧
    crossCollisionPairs 6 = 15 ∧
    crossCollisionPairs 7 = 21 := by
  unfold crossCollisionPairs; decide



/-- Total channels follow the triangular number formula: 2·C(k) = k(k+1). -/
theorem channels_triangular (k : ℕ) :
    2 * totalFactoringChannels k = k * (k + 1) := by
  unfold totalFactoringChannels
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



/-- Concrete channel values. -/
theorem factoring_channels_values :
    totalFactoringChannels 3 = 6 ∧
    totalFactoringChannels 4 = 10 ∧
    totalFactoringChannels 5 = 15 ∧
    totalFactoringChannels 7 = 28 := by
  unfold totalFactoringChannels; decide



/-- The root Pythagorean quadruple (0, 0, 1, 1). -/
def rootQuadruple : PythKTuple 3 where
  legs := ![0, 0, 1]
  hyp := 1
  eq := by native_decide



/-- Root node (1, 2, 2, 3). -/
def rootQuadruple_1223 : PythKTuple 3 where
  legs := ![1, 2, 2]
  hyp := 3
  eq := by native_decide



/-- A quadruple "solves" factoring N if any peel channel gives a nontrivial GCD. -/
def solvesFactoring (a b c d N : ℤ) : Prop :=
  (1 < Int.gcd (d - a) N ∧ ↑(Int.gcd (d - a) N) < Int.natAbs N) ∨
  (1 < Int.gcd (d - b) N ∧ ↑(Int.gcd (d - b) N) < Int.natAbs N) ∨
  (1 < Int.gcd (d - c) N ∧ ↑(Int.gcd (d - c) N) < Int.natAbs N)



/-- A quadruple that solves factoring gives at least one nontrivial factor. -/
theorem solving_gives_factor (a b c d N : ℤ)
    (h : solvesFactoring a b c d N) :
    ∃ (g : ℕ), 1 < g ∧ g < Int.natAbs N ∧ (↑g : ℤ) ∣ N := by
  rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩ | ⟨h1, h2⟩
  · exact ⟨Int.gcd (d - a) N, h1, h2, Int.gcd_dvd_right _ _⟩
  · exact ⟨Int.gcd (d - b) N, h1, h2, Int.gcd_dvd_right _ _⟩
  · exact ⟨Int.gcd (d - c) N, h1, h2, Int.gcd_dvd_right _ _⟩



/-- The factoring distance. -/
def factorDistance (d N : ℤ) : ℤ := d ^ 2 % N



/-- Zero distance means N divides d². -/
theorem zero_distance_signal (d N : ℤ) (_hN : 0 < N)
    (h : factorDistance d N = 0) :
    N ∣ d ^ 2 := by
  exact Int.dvd_of_emod_eq_zero h



/-- If p*q divides d² and p is prime, then p divides d. -/
theorem semiprime_square_divisibility (d p q : ℤ) (hp : Prime p)
    (hpq : p * q ∣ d ^ 2) : p ∣ d := by
  have : p ∣ d ^ 2 := dvd_trans (dvd_mul_right p q) hpq
  rw [sq, hp.dvd_mul] at this
  exact this.elim id id



/-- The factoring score: count of nontrivial GCD channels. -/
def factoringScore {k : ℕ} (t : Fin k → ℤ) (d : ℤ) (N : ℤ) : ℕ :=
  (Finset.univ.filter (fun j : Fin k => 1 < Int.gcd (d - t j) N)).card



/-- The factoring score is bounded by the dimension. -/
theorem factoring_score_bound {k : ℕ} (t : Fin k → ℤ) (d N : ℤ) :
    factoringScore t d N ≤ k := by
  unfold factoringScore
  calc (Finset.univ.filter _).card ≤ Finset.univ.card := Finset.card_filter_le _ _
    _ = k := Finset.card_fin k



/-- 36 channels for k=8, which is 6× quadruples. -/
theorem octonionic_advantage :
    totalFactoringChannels 8 = 36 ∧
    totalFactoringChannels 8 = 6 * totalFactoringChannels 3 := by
  unfold totalFactoringChannels; decide



/-- Octonionic to Gaussian ratio is 12:1. -/
theorem octonionic_vs_gaussian :
    totalFactoringChannels 8 / totalFactoringChannels 2 = 12 := by
  unfold totalFactoringChannels; decide


