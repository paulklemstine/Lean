/-! # CatalogBuild.Speculative.AutoResearch.Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers_via_LTE_and_Entry_Point_Theory

Auto-generated from theorem catalog database.
Domain: Speculative/AutoResearch
Declarations: 6
-/

import Mathlib

/-- Every prime divides some positive Fibonacci number.
This follows from the Pisano period: the Fibonacci sequence mod `p` is periodic,
so the pair `(0, 1)` must recur, giving `F_k ≡ 0 (mod p)` for some `k > 0`. -/
lemma prime_dvd_some_fib (p : ℕ) (hp : Nat.Prime p) :
    ∃ k, 0 < k ∧ p ∣ Nat.fib k := by
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ (fib i % p = fib j % p) ∧
      (fib (i + 1) % p = fib (j + 1) % p) := by
    have h_finite : Set.Finite ((fun k => (fib k % p, fib (k + 1) % p)) '' Set.Ici 0) := by
      exact Set.finite_iff_bddAbove.mpr ⟨⟨p - 1, p - 1⟩, by
        rintro a ⟨k, -, rfl⟩
        exact ⟨Nat.le_sub_one_of_lt (Nat.mod_lt _ hp.pos),
               Nat.le_sub_one_of_lt (Nat.mod_lt _ hp.pos)⟩⟩
    contrapose! h_finite
    exact Set.infinite_of_injective_forall_mem
      (fun i j hij => le_antisymm
        (not_lt.1 fun hi => h_finite _ _ hi (by aesop) (by aesop))
        (not_lt.1 fun hj => h_finite _ _ hj (by aesop) (by aesop)))
      fun i => ⟨i, by norm_num, rfl⟩
  obtain ⟨i, j, hij, hi, hj⟩ := h_pigeonhole
  induction' i with i ih generalizing j
  · induction' j with j ih' <;> simp_all +decide [Nat.fib_add_two, Nat.dvd_iff_mod_eq_zero]
    exact ⟨j + 1, by linarith, by simp +decide [← hi]⟩
  · specialize ih (j - 1) (Nat.lt_pred_iff.mpr hij)
    rcases j <;> simp_all +decide [Nat.fib_add_two, Nat.add_mod]
    simp_all +decide [← ZMod.natCast_eq_natCast_iff']


/-- The entry point (rank of apparition) of a prime divides `n` whenever `p ∣ F_n`.
Returns the minimal positive `d` such that `d ∣ n`, `p ∣ F_d`, and `p ∤ F_k`
for all `0 < k < d`. -/
lemma entry_point_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) :
    ∃ d, 0 < d ∧ d ∣ n ∧ p ∣ Nat.fib d ∧ ∀ k, 0 < k → k < d → ¬(p ∣ Nat.fib k) := by
  obtain ⟨d, hd1, hd2, hd3⟩ : ∃ d, 0 < d ∧ p ∣ fib d ∧ ∀ k, 0 < k → k < d → ¬p ∣ fib k := by
    have := prime_dvd_some_fib p hp
    exact ⟨Nat.find this, Nat.find_spec this |>.1, Nat.find_spec this |>.2, by aesop⟩
  refine ⟨d, hd1, ?_, hd2, hd3⟩
  contrapose! hd3
  exact ⟨Nat.gcd d n, Nat.gcd_pos_of_pos_left _ hd1,
    lt_of_le_of_ne (Nat.le_of_dvd hd1 (Nat.gcd_dvd_left _ _))
      fun con => hd3 <| con ▸ Nat.gcd_dvd_right _ _,
    prime_dvd_fib_gcd p d n hp hd2 hpn⟩


/-- For composite `n > 1`, every proper divisor is at most `n / 2`. -/
lemma composite_proper_div_le_half (n : ℕ) (hn : n > 1) (hcomp : ¬Nat.Prime n)
    (d : ℕ) (hd : d ∣ n) (hdn : d < n) : d ≤ n / 2 := by
  rw [Nat.le_div_iff_mul_le (by norm_num : (0:ℕ) < 2)]
  obtain ⟨k, rfl⟩ := hd
  have hk : k > 1 := by
    rcases k with _ | _ | k
    · omega
    · simp at hcomp; exact absurd (by omega : d * 1 < d * 1 + d) (by omega)
    · omega
  nlinarith


/-- `F_n ≥ 2` for `n ≥ 3`. -/
lemma fib_ge_two (n : ℕ) (hn : n ≥ 3) : Nat.fib n ≥ 2 :=
  Nat.le_trans (by decide) (Nat.fib_mono hn)


/-- `F_n ≠ 1` for `n ≥ 3`. -/
lemma fib_ne_one (n : ℕ) (hn : n ≥ 3) : Nat.fib n ≠ 1 :=
  Nat.ne_of_gt (fib_ge_two n hn)


/-- `F_n ≥ n` for `n ≥ 5`. -/
lemma fib_ge_id (n : ℕ) (hn : n ≥ 5) : Nat.fib n ≥ n := by
  induction hn <;> simp +arith +decide [Nat.fib_add_two, *]
  rename_i m hm ih
  rcases m with _ | _ | _ | _ | _ | m <;> simp_all +arith +decide [Nat.fib_add_two]
  grind +splitIndPred

