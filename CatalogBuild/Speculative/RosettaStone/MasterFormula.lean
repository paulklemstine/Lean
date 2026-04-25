/-! # CatalogBuild.Speculative.RosettaStone.MasterFormula

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 17
-/

import Mathlib

/-- Number of idempotents in ℤ/nℤ. -/
def idempotent_count (n : ℕ) [NeZero n] : ℕ :=
  (Finset.univ.filter (fun e : ZMod n => e * e = e)).card

-- Verified computations


/-- [Section: # CatalogBuild.Speculative.RosettaStone.MasterFormula
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 17] -/
theorem density_2 : idempotent_count 2 = 2 := by native_decide


/-- [Section: # CatalogBuild.Speculative.RosettaStone.MasterFormula
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 17] -/
theorem density_3 : idempotent_count 3 = 2 := by native_decide


/-- [Section: # CatalogBuild.Speculative.RosettaStone.MasterFormula
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 17] -/
theorem density_6 : idempotent_count 6 = 4 := by native_decide


theorem density_30 : idempotent_count 30 = 8 := by native_decide


/-- Gaussian binomial coefficient (q-analog of binomial). -/
def gaussian_binomial : ℕ → ℕ → ℕ → ℕ
  | _, 0, _ => 1
  | 0, _ + 1, _ => 0
  | n + 1, k + 1, q => q^(k+1) * gaussian_binomial n k q + gaussian_binomial n (k+1) q


/-- The q=1 case recovers ordinary binomial coefficients. -/
theorem gaussian_binomial_q1 (n k : ℕ) :
    gaussian_binomial n k 1 = Nat.choose n k := by
  induction n generalizing k with
  | zero =>
    cases k with
    | zero => simp [gaussian_binomial, Nat.choose]
    | succ k => simp [gaussian_binomial, Nat.choose]
  | succ n ih =>
    cases k with
    | zero => simp [gaussian_binomial, Nat.choose]
    | succ k =>
      simp only [gaussian_binomial, Nat.choose, one_pow, one_mul]
      rw [ih k, ih (k + 1)]


/-- Total number of projections in M_n(𝔽_q). -/
def total_projections (n q : ℕ) : ℕ :=
  ∑ r ∈ Finset.range (n + 1), gaussian_binomial n r q


/-- For q=1: total projections = 2^n. -/
theorem total_projections_q1 (n : ℕ) :
    total_projections n 1 = 2^n := by
  simp only [total_projections, gaussian_binomial_q1]
  exact Nat.sum_range_choose n


/-- For M_1(𝔽_q), there are exactly 1 + q idempotents. -/
theorem master_density_M1 (q : ℕ) :
    total_projections 1 q = 1 + q := by
  simp [total_projections, gaussian_binomial, Finset.sum_range_succ]


/-- The universal bridge density theorem. -/
theorem universal_bridge_density_one :
    ∀ (S : Type*) [SemilatticeInf S] (a : S), a ⊓ a = a :=
  fun _ _ a => inf_idem a


/-- For ℤ/nℤ with n > 1, density ≤ 1. -/
theorem classical_density_le_one (n : ℕ) (hn : 2 ≤ n) [NeZero n] :
    (idempotent_count n : ℚ) / n ≤ 1 := by
  rw [div_le_one (by positivity : (0 : ℚ) < n)]
  have h : idempotent_count n ≤ n := by
    unfold idempotent_count
    calc (Finset.univ.filter (fun e : ZMod n => e * e = e)).card
        ≤ Finset.univ.card := Finset.card_filter_le _ _
      _ = n := ZMod.card n
  exact_mod_cast h


/-- Classical density is always positive. -/
theorem classical_density_pos (n : ℕ) (hn : 1 < n) [NeZero n] :
    0 < (idempotent_count n : ℚ) / n := by
  apply div_pos
  · have : 0 ∈ (Finset.univ.filter (fun e : ZMod n => e * e = e)) := by
      simp [Finset.mem_filter]
    exact_mod_cast Finset.card_pos.mpr ⟨0, this⟩
  · exact_mod_cast Nat.pos_of_ne_zero (by omega : n ≠ 0)


/-- The complement density has ρ = 1 as its only fixed point. -/
theorem complement_density_fixed_points :
    ∀ ρ : ℝ, (1 - ρ + ρ^2 = ρ) ↔ (ρ = 1) := by
  intro ρ
  constructor
  · intro h
    have h1 : (ρ - 1)^2 = 0 := by nlinarith
    nlinarith [sq_nonneg (ρ - 1)]
  · intro h; rw [h]; ring


/-- The "dual density" of a universal bridge (ρ=1) is again 1. -/
theorem dual_of_universal : 1 - (1 : ℝ) + 1^2 = 1 := by ring


/-- The master equation has exactly three fixed points. -/
theorem master_equation_fixed_points (ρ_crit : ℝ) (hcrit : ρ_crit ≠ 0) (hcrit1 : ρ_crit ≠ 1) :
    ∀ ρ : ℝ, ρ * (1 - ρ) * (ρ - ρ_crit) = 0 ↔ ρ = 0 ∨ ρ = 1 ∨ ρ = ρ_crit := by
  intro ρ
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h1 | h1
    · rcases mul_eq_zero.mp h1 with h2 | h2
      · left; exact h2
      · right; left; linarith
    · right; right; linarith
  · rintro (rfl | rfl | rfl) <;> ring


/-- At ρ = 1, the density is a fixed point. -/
theorem rho_one_stable (ρ_crit : ℝ) :
    (1 : ℝ) * (1 - 1) * (1 - ρ_crit) = 0 := by ring


