/-! # CatalogBuild.Speculative.FibonacciPseudoprimes

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 2
-/

import Speculative.PisanoPeriodFactoring
import Mathlib

theorem pisano_period_exists (m : ℕ) (hm : 0 < m) :
    ∃ T : ℕ, 0 < T ∧ ∀ n, Nat.fib (n + T) % m = Nat.fib n % m := by
  -- By the pigeonhole principle, since there are only $m^2$ possible pairs $(F(n) \mod m, F(n+1) \mod m)$, there must exist indices $i < j$ such that $(F(i) \mod m, F(i+1) \mod m) = (F(j) \mod m, F(j+1) \mod m)$.
  obtain ⟨i, j, hij, h_pair⟩ : ∃ i j : ℕ, i < j ∧ (fib i % m = fib j % m ∧ fib (i + 1) % m = fib (j + 1) % m) := by
    -- By the pigeonhole principle, since there are only $m^2$ possible pairs $(F(n) \mod m, F(n+1) \mod m)$, there must exist indices $i < j$ such that $(F(i) \mod m, F(i+1) \mod m) = (F(j) \mod m, F(j+1) \mod m)$, because there are infinitely many pairs.
    have h_pigeonhole : Set.Finite (Set.range fun n => (fib n % m, fib (n + 1) % m)) := by
      exact Set.finite_iff_bddAbove.mpr ⟨ ⟨ m - 1, m - 1 ⟩, by rintro a ⟨ n, rfl ⟩ ; exact ⟨ Nat.le_sub_one_of_lt ( Nat.mod_lt _ hm ), Nat.le_sub_one_of_lt ( Nat.mod_lt _ hm ) ⟩ ⟩;
    contrapose! h_pigeonhole;
    exact Set.infinite_range_of_injective fun i j hij => le_antisymm ( le_of_not_gt fun hi => h_pigeonhole _ _ hi ( by aesop ) ( by aesop ) ) ( le_of_not_gt fun hj => h_pigeonhole _ _ hj ( by aesop ) ( by aesop ) );
  induction' i with i ih generalizing j;
  · refine' ⟨ j, hij, fun n => _ ⟩ ; induction' n using Nat.strong_induction_on with n ih ; rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ] ;
    · norm_num [ ← h_pair.1 ];
    · norm_num [ ← h_pair.1 ];
      exact h_pair.2.symm;
    · simp +decide [ Nat.add_mod, ih n ( by linarith ), ih ( n + 1 ) ( by linarith ) ];
      grind +qlia;
  · contrapose! ih;
    refine' ⟨ j - 1, _, _, ih ⟩ <;> rcases j with ( _ | _ | j ) <;> simp_all +decide [ Nat.fib_add_two ];
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ];
    linear_combination' h_pair.2 - h_pair.1


/-- For prime p, the Pisano period divides p² - 1. -/
theorem pisano_period_divides_prime_bound (p : ℕ) (hp : Nat.Prime p) (hp5 : p ≠ 5) :
    ∃ T : ℕ, 0 < T ∧ T ∣ (p^2 - 1) ∧ ∀ n, Nat.fib (n + T) % p = Nat.fib n % p := by
  obtain ⟨T, hT_pos, hT_dvd, hT_period⟩ := pisano_factor_constraint p hp hp5
  exact ⟨T, hT_pos, by rwa [sq], hT_period⟩

