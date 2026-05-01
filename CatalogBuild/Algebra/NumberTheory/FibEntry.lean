/-! # CatalogBuild.Algebra.NumberTheory.FibEntry

Auto-generated from theorem catalog database.
Domain: Algebra/NumberTheory
Declarations: 7
-/

import Mathlib

noncomputable section

/-- [Section: ## Entry point existence] -/
lemma fib_entry_exists (p : ℕ) (hp : p.Prime) : ∃ k, 0 < k ∧ p ∣ Nat.fib k := by
  -- By the pigeonhole principle, since there are only $p^2$ possible pairs $(F_n \mod p, F_{n+1} \mod p)$, the sequence must eventually repeat.
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ (fib i % p = fib j % p) ∧ (fib (i + 1) % p = fib (j + 1) % p) := by
    have h_finite : Set.Finite (Set.range fun n => (fib n % p, fib (n + 1) % p)) := by
      exact Set.finite_iff_bddAbove.mpr ⟨ ⟨ p - 1, p - 1 ⟩, by rintro a ⟨ n, rfl ⟩ ; exact ⟨ Nat.le_sub_one_of_lt ( Nat.mod_lt _ hp.pos ), Nat.le_sub_one_of_lt ( Nat.mod_lt _ hp.pos ) ⟩ ⟩;
    contrapose! h_finite;
    exact Set.infinite_range_of_injective fun i j hij => le_antisymm ( le_of_not_gt fun hi => h_finite _ _ hi ( by aesop ) ( by aesop ) ) ( le_of_not_gt fun hj => h_finite _ _ hj ( by aesop ) ( by aesop ) );
  obtain ⟨ i, j, hij, hi, hj ⟩ := h_pigeonhole; induction' i with i ih generalizing j; induction' j with j ihj; aesop; (
  exact ⟨ j + 1, Nat.succ_pos _, Nat.dvd_of_mod_eq_zero <| by simpa using hi.symm ⟩);
  specialize ih ( j - 1 ) ( Nat.lt_pred_iff.mpr hij ) ; rcases j <;> simp_all +arith +decide [ Nat.fib_add_two, Nat.add_mod ] ;
  simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ]


/-- The entry point (rank of apparition) of a prime p in the Fibonacci sequence:
the smallest positive k such that p ∣ F_k. -/
noncomputable def fibEntryPoint (p : ℕ) (hp : p.Prime) : ℕ :=
  Nat.find (fib_entry_exists p hp)


/-- [Section: ## Entry point definition] -/
lemma fibEntryPoint_pos (p : ℕ) (hp : p.Prime) : 0 < fibEntryPoint p hp := by
  exact (Nat.find_spec (fib_entry_exists p hp)).1


lemma fibEntryPoint_dvd_fib (p : ℕ) (hp : p.Prime) : p ∣ Nat.fib (fibEntryPoint p hp) := by
  exact (Nat.find_spec (fib_entry_exists p hp)).2


lemma fibEntryPoint_min (p : ℕ) (hp : p.Prime) (k : ℕ) (hk : k < fibEntryPoint p hp) :
    ¬(0 < k ∧ p ∣ Nat.fib k) := by
  exact Nat.find_min (fib_entry_exists p hp) hk


/-- [Section: ## Entry point divides] -/
lemma entry_dvd_of_fib_dvd (p : ℕ) (hp : p.Prime) (n : ℕ) (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    fibEntryPoint p hp ∣ n := by
  -- Since p divides F_n and p divides F_e, we have p divides gcd(F_n, F_e).
  have h_div_gcd : p ∣ Nat.gcd (fib n) (fib (fibEntryPoint p hp)) := by
    exact Nat.dvd_gcd hpn ( fibEntryPoint_dvd_fib p hp );
  -- By the properties of the gcd and the definition of the entry point, we have that gcd(n, fibEntryPoint p hp) = fibEntryPoint p hp.
  have h_gcd_eq : Nat.gcd n (fibEntryPoint p hp) = fibEntryPoint p hp := by
    exact Classical.not_not.1 fun h => fibEntryPoint_min p hp ( Nat.gcd n ( fibEntryPoint p hp ) ) ( lt_of_le_of_ne ( Nat.le_of_dvd ( fibEntryPoint_pos p hp ) ( Nat.gcd_dvd_right _ _ ) ) h ) ⟨ Nat.gcd_pos_of_pos_left _ hn, by simpa [ Nat.fib_gcd ] using h_div_gcd ⟩;
  exact h_gcd_eq ▸ Nat.gcd_dvd_left _ _


/-- p ∣ F_n ↔ entry(p) ∣ n, for n > 0. -/
lemma fib_dvd_iff_entry_dvd (p : ℕ) (hp : p.Prime) (n : ℕ) (hn : 0 < n) :
    p ∣ Nat.fib n ↔ fibEntryPoint p hp ∣ n := by
  constructor
  · exact entry_dvd_of_fib_dvd p hp n hn
  · intro h
    exact dvd_trans (fibEntryPoint_dvd_fib p hp) (Nat.fib_dvd _ _ h)

end
