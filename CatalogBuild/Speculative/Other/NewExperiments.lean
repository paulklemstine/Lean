/-! # CatalogBuild.Speculative.Other.NewExperiments

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24
-/

import Mathlib

/-- Experiment 1: Count solutions to x² + y² = n for small n.
This measures the "circle density" at each radius. -/
def countSumTwoSq (n : ℕ) : ℕ :=
  (Finset.Icc 0 n |>.product (Finset.Icc 0 n)).filter
    (fun p => p.1^2 + p.2^2 = n) |>.card


/-- Theorem 30.1: x² + y² = 0 has exactly 1 non-negative solution: (0,0). -/
theorem count_sum_two_sq_0 : countSumTwoSq 0 = 1 := by native_decide


/-- Theorem 30.2: x² + y² = 1 has 2 non-negative solutions: (0,1) and (1,0). -/
theorem count_sum_two_sq_1 : countSumTwoSq 1 = 2 := by native_decide


/-- Theorem 30.3: x² + y² = 2 has 1 non-negative solution: (1,1). -/
theorem count_sum_two_sq_2 : countSumTwoSq 2 = 1 := by native_decide


/-- Theorem 30.4: x² + y² = 5 has 2 non-negative solutions. -/
theorem count_sum_two_sq_5 : countSumTwoSq 5 = 2 := by native_decide


/-- Theorem 30.5: x² + y² = 25 has 4 non-negative solutions: (0,5),(3,4),(4,3),(5,0). -/
theorem count_sum_two_sq_25 : countSumTwoSq 25 = 4 := by native_decide


/-- Theorem 30.6: x² + y² = 3 has 0 non-negative solutions. The oracle rejects 3. -/
theorem count_sum_two_sq_3 : countSumTwoSq 3 = 0 := by native_decide


/-- Theorem 30.7: x² + y² = 7 has 0 non-negative solutions. -/
theorem count_sum_two_sq_7 : countSumTwoSq 7 = 0 := by native_decide


/-- Oracle on Fin 4 that maps to mod 2. -/
def mod2Oracle4 : Fin 4 → Fin 4 := fun x => ⟨x.val % 2, by omega⟩


/-- [Section: # CatalogBuild.Speculative.Other.NewExperiments
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24] -/
theorem zeroOracle_is_oracle (n : ℕ) :
    ∀ x : Fin (n + 1), zeroOracle n (zeroOracle n x) = zeroOracle n x := by
  aesop


/-- [Section: # CatalogBuild.Speculative.Other.NewExperiments
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24] -/
theorem mod2Oracle4_is_oracle :
    ∀ x : Fin 4, mod2Oracle4 (mod2Oracle4 x) = mod2Oracle4 x := by
  native_decide +revert


/-- [Section: # CatalogBuild.Speculative.Other.NewExperiments
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 24] -/
theorem zeroOracle_fixed_count (n : ℕ) :
    (Finset.univ.filter (fun x : Fin (n + 1) => zeroOracle n x = x)).card = 1 := by
  unfold zeroOracle;
  exact Finset.card_eq_one.mpr ⟨ 0, by aesop ⟩


theorem idOracle_fixed_count (n : ℕ) :
    (Finset.univ.filter (fun x : Fin (n + 1) => idOracle n x = x)).card = n + 1 := by
  unfold idOracle; aesop;


/-- Theorem 31.5: mod2Oracle4 fixes exactly 2 points: 0 and 1. -/
theorem mod2Oracle4_fixed_count :
    (Finset.univ.filter (fun x : Fin 4 => mod2Oracle4 x = x)).card = 2 := by
  native_decide


/-- Theorem 32.1: F(12)² = F(12) × F(12) = 144 × 144 = 20736. -/
theorem fib_12_sq : Nat.fib 12 ^ 2 = 20736 := by native_decide


/-- Theorem 32.2: F(12) = 144 = 12². -/
theorem fib_12_is_square : Nat.fib 12 = 12 ^ 2 := by native_decide


/-- Theorem 32.3: F(0) = 0, F(1) = 1, F(12) = 144 are the only perfect squares
in F(0)..F(25). -/
theorem fib_squares_up_to_25 :
    (Finset.Icc 0 25).filter (fun n => ∃ k, k ≤ Nat.fib n ∧ k^2 = Nat.fib n) =
    {0, 1, 2, 12} := by
  native_decide


theorem oracle_retract_section {α : Type*} (O : α → α) (hO : ∀ x, O (O x) = O x)
    (y : α) (hy : ∃ x, O x = y) : O y = y := by
  grind +ring


theorem oracle_image_eq_fixed {α : Type*} (O : α → α) (hO : ∀ x, O (O x) = O x) :
    Set.range O = {x | O x = x} := by
  exact Set.ext fun x => ⟨ by rintro ⟨ y, rfl ⟩ ; exact hO y, by rintro hx; exact ⟨ x, hx ⟩ ⟩


/-- Construct an oracle from a subset: fix points in S, map others to a chosen point in S. -/
def subsetOracle {n : ℕ} (S : Finset (Fin n)) (c : Fin n) (hc : c ∈ S) : Fin n → Fin n :=
  fun x => if x ∈ S then x else c


theorem subsetOracle_is_oracle {n : ℕ} (S : Finset (Fin n)) (c : Fin n) (hc : c ∈ S) :
    ∀ x, subsetOracle S c hc (subsetOracle S c hc x) = subsetOracle S c hc x := by
  unfold subsetOracle; aesop;


theorem subsetOracle_truth {n : ℕ} (S : Finset (Fin n)) (c : Fin n) (hc : c ∈ S) :
    ∀ x, subsetOracle S c hc x = x ↔ x ∈ S := by
  -- By definition of subsetOracle, if x is in S, then subsetOracle S c hc x = x.
  intro x
  simp [subsetOracle];
  by_cases hx : x ∈ S <;> aesop


theorem hurwitz_dims_are_powers_of_two :
    ∀ n ∈ ({1, 2, 4, 8} : Finset ℕ), ∃ k, n = 2^k := by
  norm_num +zetaDelta at *;
  exact ⟨ ⟨ 0, rfl ⟩, ⟨ 1, rfl ⟩, ⟨ 2, rfl ⟩, ⟨ 3, rfl ⟩ ⟩


/-- Theorem 35.6: 85 = 5 × 17, both Fermat primes, both sums of two squares. -/
theorem hurwitz_sum_sq_factored : 1^2 + 2^2 + 4^2 + 8^2 = 5 * 17 := by norm_num


