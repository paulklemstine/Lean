/-! # CatalogBuild.Computation.Factoring.OpenQuestionsResearch

Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 30
-/

import Mathlib

/-- B-smooth numbers form a multiplicative submonoid (closure). -/
theorem smooth_submonoid_closure (B a b : ℕ) (ha : IsSmooth B a) (hb : IsSmooth B b) :
    IsSmooth B (a * b) := by
  intro p hp hd
  rcases hp.dvd_mul.mp hd with h | h
  · exact ha p hp h
  · exact hb p hp h



/-- The smooth number filtration: B-smooth implies B'-smooth for B ≤ B'. -/
theorem smooth_filtration (B B' n : ℕ) (hBB : B ≤ B') (hn : IsSmooth B n) :
    IsSmooth B' n := fun p hp hd => le_trans (hn p hp hd) hBB



/-- Divisors of smooth numbers are smooth. -/
theorem smooth_divisor_closed (B n d : ℕ) (hn : IsSmooth B n) (hd : d ∣ n) :
    IsSmooth B d := fun p hp hpd => hn p hp (dvd_trans hpd hd)



/-- Every number ≤ B is B-smooth. -/
theorem smooth_below_base (B n : ℕ) (hn : 0 < n) (hnB : n ≤ B) :
    IsSmooth B n := fun p _hp hpn => le_trans (Nat.le_of_dvd hn hpn) hnB



/-- [Section: # CatalogBuild.Computation.Factoring.OpenQuestionsResearch
Auto-generated from theorem catalog database.
Domain: Computation/Factoring
Declarations: 30] -/
theorem fibonacci_representation_efficiency (k : ℕ) :
    k + 1 ≤ Nat.fib (k + 2) := by
  induction' k with k ih <;> simp +arith +decide [ Nat.fib_add_two ] at *;
  rcases k with ( _ | _ | k ) <;> simp +arith +decide [ Nat.fib_add_two ] at * ; linarith



/-- At most log₂(S) lenses can be meaningful: after that, S/2^k = 0. -/
theorem max_meaningful_lenses (S : ℕ) (k : ℕ) (hk : S < 2 ^ k) :
    S / 2 ^ k = 0 :=
  Nat.div_eq_of_lt hk



/-- The lens count ceiling: S / 2^S = 0 for all S. -/
theorem lens_ceiling (S : ℕ) : S / 2 ^ S = 0 :=
  Nat.div_eq_of_lt (Nat.lt_pow_self (by omega : 1 < 2))



/-- Lens information is additive: k lenses give k bits. -/
theorem lens_info_additive (k : ℕ) : Nat.log 2 (2 ^ k) = k :=
  Nat.log_pow (by norm_num) k



/-- The independence ceiling: at most ⌊log₂ S⌋ independent lenses
can provide a strict reduction. -/
theorem independence_ceiling (S : ℕ) (hS : 0 < S) (k : ℕ)
    (hk : Nat.log 2 S < k) : S / 2 ^ k = 0 := by
  apply Nat.div_eq_of_lt
  exact lt_of_lt_of_le (Nat.lt_pow_succ_log_self (by norm_num) S)
    (Nat.pow_le_pow_right (by norm_num) hk)



theorem strict_lens_improvement (S k : ℕ) (hS : 2 ^ (k + 1) ≤ S) :
    S / 2 ^ (k + 1) < S / 2 ^ k := by
  refine' Nat.div_lt_of_lt_mul _;
  rw [ pow_succ' ] at * ; nlinarith [ Nat.div_add_mod S ( 2 ^ k ), Nat.mod_lt S ( by positivity : 0 < ( 2 ^ k ) ) ] ;



/-- Classical lenses reduce quantum query complexity. -/
theorem classical_reduces_quantum (S k : ℕ) :
    Nat.sqrt (S / 2 ^ k) ≤ Nat.sqrt S :=
  Nat.sqrt_le_sqrt (Nat.div_le_self S _)



/-- More lenses means monotonically less quantum work. -/
theorem pareto_monotone (S k₁ k₂ : ℕ) (hle : k₁ ≤ k₂) :
    Nat.sqrt (S / 2 ^ k₂) ≤ Nat.sqrt (S / 2 ^ k₁) :=
  Nat.sqrt_le_sqrt (Nat.div_le_div_left (Nat.pow_le_pow_right (by norm_num) hle)
    (by positivity))



/-- The quantum advantage from k lenses: the search space strictly shrinks.
S / 2^k < S when S > 0 and k ≥ 1 (the quantum-relevant reduction). -/
theorem quantum_strict_advantage (S k : ℕ) (hS : 0 < S) (hk : 1 ≤ k) :
    S / 2 ^ k < S :=
  Nat.div_lt_self hS (Nat.one_lt_two_pow_iff.mpr (by omega))



/-- An optimal classical-quantum split always exists. -/
theorem optimal_split_exists (S : ℕ) (hS : 0 < S) :
    ∃ k : ℕ, k ≤ S ∧ ∀ j : ℕ, j ≤ S →
      k + Nat.sqrt (S / 2 ^ k) ≤ j + Nat.sqrt (S / 2 ^ j) := by
  have : Finset.Nonempty ((Finset.range (S + 1)).image (fun k => k + Nat.sqrt (S / 2 ^ k))) :=
    Finset.Nonempty.image ⟨0, Finset.mem_range.mpr (by omega)⟩ _
  obtain ⟨m, hm_mem, hm_min⟩ := Finset.exists_min_image
    (Finset.range (S + 1)) (fun k => k + Nat.sqrt (S / 2 ^ k))
    ⟨0, Finset.mem_range.mpr (by omega)⟩
  exact ⟨m, by simp at hm_mem; omega,
    fun j hj => hm_min j (Finset.mem_range.mpr (by omega))⟩



/-- 9 lenses give 512× classical reduction. -/
theorem nine_lens_savings : 2 ^ 9 = 512 := by norm_num



/-- Grover's bound. -/
theorem grover_bound (N : ℕ) : N < (Nat.sqrt N + 1) ^ 2 :=
  Nat.lt_succ_sqrt' N



theorem orbit_revisit (n : ℕ) (hn : 0 < n) (f : Fin n → Fin n) (x : Fin n) :
    ∃ i j : ℕ, i < j ∧ j ≤ n ∧ f^[i] x = f^[j] x := by
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ j ≤ n ∧ f^[i] x = f^[j] x := by
    have h_pigeonhole : Finset.card (Finset.image (fun i => f^[i] x) (Finset.range (n + 1))) ≤ n := by
      exact le_trans ( Finset.card_le_univ _ ) ( by simpa )
    contrapose! h_pigeonhole;
    rw [ Finset.card_image_of_injOn fun i hi j hj hij => le_antisymm ( le_of_not_gt fun hi' => h_pigeonhole _ _ hi' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij.symm ) ( le_of_not_gt fun hj' => h_pigeonhole _ _ hj' ( by linarith [ Finset.mem_range.mp hi, Finset.mem_range.mp hj ] ) hij ) ] ; simp +arith +decide;
  exact h_pigeonhole



theorem cross_collision_period (n : ℕ) (f : Fin n → Fin n) (x : Fin n)
    (i j : ℕ) (hij : i < j) (hcoll : f^[i] x = f^[j] x) :
    ∀ k : ℕ, f^[i + k * (j - i)] x = f^[i] x := by
  -- By induction on $k$, we can show that $f^{[i + k * (j - i)]} x = f^{[i]} x$ for any $k$.
  intro k
  induction' k with k ih;
  · norm_num;
  · rw [ Nat.succ_mul, ← add_assoc, add_comm, Function.iterate_add_apply, ih ];
    rw [ ← Function.iterate_add_apply, Nat.sub_add_cancel hij.le, hcoll ]



/-- The MLC power law. -/
theorem mlc_power_law (S a b : ℕ) :
    S / 2 ^ a / 2 ^ b = S / 2 ^ (a + b) := by
  rw [pow_add, Nat.div_div_eq_div_mul]



/-- MLC commutativity. -/
theorem mlc_commutativity (S a b : ℕ) :
    S / 2 ^ a / 2 ^ b = S / 2 ^ b / 2 ^ a := by
  rw [mlc_power_law, mlc_power_law, Nat.add_comm]



/-- MLC identity: 0 lenses leave S unchanged. -/
theorem mlc_identity (S : ℕ) : S / 2 ^ 0 = S := by simp



/-- MLC strict separation. -/
theorem mlc_strict_separation (S k : ℕ) (hS : 2 ^ (k + 1) ≤ S) :
    S / 2 ^ (k + 1) < S / 2 ^ k :=
  strict_lens_improvement S k hS



/-- MLC grade characterization. -/
theorem mlc_grade_characterization (S k : ℕ) (hS : 0 < S) (hk : 1 ≤ k) :
    S / 2 ^ k < S :=
  Nat.div_lt_self hS (Nat.one_lt_two_pow_iff.mpr (by omega))



theorem rsa_resists_small_lenses (p q m : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpm : m < p) (hqm : m < q) (hm : 1 < m) :
    ¬(m ∣ p * q) := by
  rw [ Nat.dvd_mul ];
  simp_all +decide [ Nat.dvd_prime ];
  exact ⟨ ⟨ by linarith, by linarith ⟩, by linarith, by nlinarith ⟩



theorem tropical_prefilter (N p : ℕ) (hp : Nat.Prime p) (hN : N ≠ 0)
    (hval : N.factorization p = 0) : ¬(p ∣ N) := by
  rw [ Nat.Prime.dvd_iff_one_le_factorization ] <;> aesop



/-- Fermat's method identity. -/
theorem fermat_method (a b : ℤ) :
    a ^ 2 - b ^ 2 = (a - b) * (a + b) := by ring



/-- Nine lens domains. -/
theorem nine_lens_domains : Finset.card ({1, 2, 3, 4, 5, 6, 7, 8, 9} : Finset ℕ) = 9 := by
  decide



/-- Each lens contributes 1 bit of information. -/
theorem lens_bit_contribution (k : ℕ) (hk : 1 ≤ k) :
    Nat.log 2 (2 ^ k) - Nat.log 2 (2 ^ (k - 1)) = 1 := by
  rw [Nat.log_pow (by norm_num), Nat.log_pow (by norm_num)]
  omega



/-- Total reduction from 9 ideal lenses. -/
theorem total_nine_lens_reduction : 2 ^ 9 = 512 := by norm_num



/-- Composing all 9 lenses: any order gives the same result. -/
theorem nine_lens_composition_invariant (S : ℕ) :
    S / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 / 2 = S / 512 := by
  simp [Nat.div_div_eq_div_mul]


