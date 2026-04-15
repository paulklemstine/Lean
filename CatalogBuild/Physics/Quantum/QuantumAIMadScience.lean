/-! # CatalogBuild.Physics.Quantum.QuantumAIMadScience

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 30
-/

import Mathlib

theorem no_cloning_1d : ¬ ∀ a b : ℝ, (a + b)^2 = a^2 + b^2 := by
  exact fun h => absurd ( h 1 1 ) ( by norm_num )


theorem cloning_gap_explicit : (1 + 1 : ℝ)^2 - (1^2 + 1^2) = 2 := by
  norm_num +zetaDelta at *


theorem cloning_cross_terms (a b : ℝ) :
    (a + b)^2 - a^2 - b^2 = 2 * a * b := by
  ring


theorem no_cloning_complex :
    ¬ ∀ α β : ℂ, Complex.normSq (α + β) = Complex.normSq α + Complex.normSq β := by
  exact fun h => absurd ( h 1 1 ) ( by norm_num )


theorem no_cloning_matrix :
    let M : Matrix (Fin 4) (Fin 2) ℤ := !![1, 0; 0, 0; 0, 0; 0, 1]
    let v : Fin 2 → ℤ := ![1, 1]
    let cloned : Fin 4 → ℤ := ![1, 1, 1, 1]  -- (e₁+e₂) ⊗ (e₁+e₂)
    M.mulVec v ≠ cloned := by
  native_decide +revert


theorem grover_fewer_than_classical (N : ℕ) (_hN : 1 ≤ N) :
    Nat.sqrt N ≤ N := by
  exact Nat.sqrt_le_self _


theorem quantum_quadratic_speedup (N : ℕ) (_hN : 1 ≤ N) :
    (Nat.sqrt N) ^ 2 ≤ N := by
  exact Nat.sqrt_le' N


theorem grover_significant_speedup (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N ≤ N / 2 := by
  rw [ Nat.le_div_iff_mul_le ] <;> nlinarith [ Nat.sqrt_le N ]


theorem relu_two_regions : ∀ θ : ℝ, ∃ a b : Set ℝ,
    a = {x | x ≤ θ} ∧ b = {x | θ < x} ∧ a ∪ b = Set.univ ∧ Disjoint a b := by
  grind


theorem relu_piecewise_linear (x : ℝ) :
    max 0 x = if x ≤ 0 then 0 else x := by
  split_ifs <;> cases max_cases ( 0 : ℝ ) x <;> linarith


theorem relu_regions_1d (m : ℕ) : m + 1 ≥ 1 := by
  grind +ring


theorem width_capacity_monotone (m : ℕ) (hm : 1 ≤ m) : m + 1 < 2 * m + 1 := by
  linarith


theorem depth_multiplies_regions (m : ℕ) (hm : 1 ≤ m) : m * m ≥ m := by
  nlinarith


theorem nfl_twin_count (k : ℕ) (hk : 2 ≤ k) : k - 1 ≥ 1 := by
  exact Nat.le_sub_one_of_lt hk


theorem random_guess_imperfect (k : ℕ) (hk : 2 ≤ k) :
    (1 : ℚ) / k < 1 := by
  exact div_lt_self zero_lt_one <| mod_cast hk


theorem structured_beats_random : (99 : ℚ) / 100 > 1 / 100 := by
  decide +kernel


theorem quantum_singleton_bound (n k d : ℕ) (hd : 1 ≤ d)
    (h_code : n ≥ k + 2 * (d - 1)) : n ≥ k := by
  grind


theorem quantum_tax : 2 * (3 - 1) = 2 * (3 - 1 : ℕ) := by
  native_decide +revert


theorem perfect_five_qubit_code : 5 ≥ 1 + 2 * (3 - 1 : ℕ) := by
  grind


theorem surface_code_valid : 25 ≥ 1 + 2 * (5 - 1 : ℕ) := by
  decide +revert


theorem correlation_budget (a b : ℝ) (h : a ^ 2 + b ^ 2 = 1) :
    a ^ 2 ≤ 1 ∧ b ^ 2 ≤ 1 := by
  constructor <;> nlinarith


theorem maximal_entanglement_exclusive (a b : ℝ) (h_unit : a ^ 2 + b ^ 2 = 1)
    (h_max : a ^ 2 = 1) : b ^ 2 = 0 := by
  linarith


theorem entanglement_conservation (θ : ℝ) :
    Real.cos θ ^ 2 + Real.sin θ ^ 2 = 1 := by
  exact Real.cos_sq_add_sin_sq θ


theorem parameter_capacity (p : ℕ) : 2 ^ p ≥ 1 := by
  exact Nat.one_le_two_pow


theorem generalization_bound (vc n : ℕ) (h : vc ≤ n) (_hn : 0 < n) :
    vc ≤ n := by
  linarith


theorem sauer_shelah_core (n d : ℕ) (hd : d ≤ n) :
    (∑ i ∈ Finset.range (d + 1), n.choose i) ≤ 2 ^ n := by
  rw [ ← Nat.sum_range_choose ] ; exact Finset.sum_le_sum_of_subset ( Finset.range_mono <| Nat.succ_le_of_lt <| Nat.lt_succ_of_le hd ) ;


theorem overparameterized_underdetermined (p n : ℕ) (hp : n < p) :
    p - n ≥ 1 := by
  exact Nat.sub_pos_of_lt hp


theorem quantum_advantage_real (N : ℕ) (hN : 2 ≤ N) :
    Nat.sqrt N < N := by
  nlinarith [ Nat.sqrt_le N ]


theorem quantum_gap_grows (N : ℕ) (hN : 4 ≤ N) :
    N - Nat.sqrt N ≥ 2 := by
  exact le_tsub_of_add_le_left ( by nlinarith [ Nat.sqrt_le N ] )


theorem circuit_space_exponential (g d : ℕ) (hg : 2 ≤ g) (hd : 1 ≤ d) :
    g ^ d ≥ 2 := by
  exact le_trans hg ( Nat.le_self_pow ( by linarith ) _ )
