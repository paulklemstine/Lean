/-! # CatalogBuild.Computation.Oracles.OracleHypotheses

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 18
-/

import Mathlib

noncomputable section

theorem oracle_density_2 :
    (Finset.filter (fun f : Fin 2 → Fin 2 => ∀ x, f (f x) = f x) Finset.univ).card = 3 := by
      native_decide +revert


theorem id_always_idempotent {n : ℕ} : ∀ x : Fin n, id (id x) = id x := by
  aesop


theorem const_always_idempotent {n : ℕ} (c : Fin n) :
    ∀ x : Fin n, (fun _ => c) ((fun _ => c) x) = (fun _ => c) x := by
      norm_num +zetaDelta at *


theorem idempotent_eigenvalue (lam : ℝ) (h : lam * lam = lam) : lam = 0 ∨ lam = 1 := by
  cases le_or_gt lam 0 <;> [ left; right ] <;> nlinarith


theorem idempotent_trace_rank (n : ℕ) (vals : Fin n → ℝ)
    (h : ∀ i, vals i * vals i = vals i) :
    ∀ i, vals i = 0 ∨ vals i = 1 := by
      exact fun i => or_iff_not_imp_left.mpr fun hi => mul_left_cancel₀ hi <| by linarith [ h i ] ;


theorem idempotent_real_01 (x : ℝ) (hx : x ^ 2 = x) : x = 0 ∨ x = 1 := by
  exact or_iff_not_imp_left.mpr fun h => mul_left_cancel₀ h <| by linarith;


theorem mod_idempotent (a n : ℕ) : (a % n) % n = a % n := by
  rw [ Nat.mod_mod ]


theorem mod_fixedpoints (n : ℕ) (hn : 0 < n) (a : ℕ) (ha : a < n) :
    a % n = a := by
      exact Nat.mod_eq_of_lt ha


theorem mod_compresses (a n : ℕ) (hn : 0 < n) : a % n < n := by
  exact Nat.mod_lt _ hn


/-- Primality is decidable (there exists a decision procedure) -/
def prime_decidable' (n : ℕ) : Decidable (Nat.Prime n) := inferInstance


theorem exists_prime_factor (n : ℕ) (hn : 2 ≤ n) : ∃ p, Nat.Prime p ∧ p ∣ n := by
  exact ⟨ Nat.minFac n, Nat.minFac_prime ( by linarith ), Nat.minFac_dvd n ⟩


theorem coloring_bound (n k : ℕ) (hk : k ≤ n) : k ≤ n := by
  assumption


theorem complete_graph_colorings (n : ℕ) :
    Nat.factorial n ≤ n ^ n := by
      exact factorial_le_pow n


theorem binary_entropy_bound (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    p * (1 - p) ≤ 1/4 := by
      linarith [ sq_nonneg ( p - 1 / 2 ) ]


theorem halting_diagonal : ¬ ∃ (e : ℕ → (ℕ → Bool)), Surjective e := by
  norm_num +zetaDelta at *;
  exact fun f hf => by have := hf ( fun n => if f n n = Bool.true then Bool.false else Bool.true ) ; rcases this with ⟨ n, hn ⟩ ; replace hn := congr_fun hn n ; simp +decide at hn;


theorem cantor_functions (X : Type*) [Nonempty X] :
    ¬ Surjective (fun (x : X) (y : X) => x = y) := by
      intro h_surj;
      obtain ⟨ f, hf ⟩ := h_surj ( fun _ ↦ Bool.false );
      simpa using congr_fun hf f


theorem finite_dynamics_repeat {n : ℕ} (hn : 0 < n) (f : Fin n → Fin n) (x : Fin n) :
    ∃ k m : ℕ, k < m ∧ m ≤ n ∧ f^[k] x = f^[m] x := by
      have h_pigeonhole : Finset.card (Finset.image (fun i => f^[i] x) (Finset.range (n+1))) ≤ n := by
        exact le_trans ( Finset.card_le_univ _ ) ( by simpa );
      contrapose! h_pigeonhole;
      rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => h_pigeonhole _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij.symm ) ( le_of_not_gt fun hj' => h_pigeonhole _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij ) ] ; simp +arith +decide


theorem idempotent_instant_cycle {X : Type*} (f : X → X) (hf : ∀ x, f (f x) = f x)
    (x : X) : f^[1] x = f^[2] x := by
      aesop


end
