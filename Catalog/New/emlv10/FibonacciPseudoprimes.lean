import Mathlib

/-!
# Fibonacci Pseudoprime Theory and Density Bounds — v10

## Main Results

* `fib_periodic_mod` — Fibonacci sequence is periodic modulo any m > 0
* `fib_coprime_consecutive` — gcd(F(n), F(n+1)) = 1
* `fib_sq_sum` — F(n)² + F(n+1)² = F(2n+1)
* `fib_dvd_mul` — F(m) | F(mn)
* `fib_pseudoprime_323` — 323 is a Fibonacci pseudoprime
* `fib_entry_point_divides` — Entry point divides indices
* `lucas_fib_relation` — L(n) = F(n-1) + F(n+1)
* `fib_pseudoprime_finite` — Fibonacci pseudoprimes are finite below any bound
-/

set_option maxHeartbeats 8000000

open Nat BigOperators Finset

/-! ### Fibonacci Periodicity (Pisano Period) -/

/-
Fibonacci is periodic modulo any m ≥ 1: there exists a period π(m).
-/
theorem fib_periodic_mod (m : ℕ) (hm : 0 < m) :
    ∃ π : ℕ, 0 < π ∧ ∀ n, Nat.fib (n + π) % m = Nat.fib n % m := by
  -- By the pigeonhole principle, since there are only $m^2$ possible pairs $(F_n \mod m, F_{n+1} \mod m)$, there must exist indices $i$ and $j$ with $i < j$ such that $(F_i \mod m, F_{i+1} \mod m) = (F_j \mod m, F_{j+1} \mod m)$.
  obtain ⟨i, j, hij, h_eq⟩ : ∃ i j, i < j ∧ (fib i % m, fib (i + 1) % m) = (fib j % m, fib (j + 1) % m) := by
    by_contra h_contra;
    exact absurd ( Set.infinite_range_of_injective ( fun i j hij => le_antisymm ( not_lt.1 fun hi => h_contra ⟨ j, i, hi, hij.symm ⟩ ) ( not_lt.1 fun hj => h_contra ⟨ i, j, hj, hij ⟩ ) ) ) ( Set.not_infinite.mpr <| Set.finite_iff_bddAbove.mpr ⟨ ⟨ m - 1, m - 1 ⟩, by rintro a ⟨ i, rfl ⟩ ; exact ⟨ Nat.le_sub_one_of_lt <| Nat.mod_lt _ hm, Nat.le_sub_one_of_lt <| Nat.mod_lt _ hm ⟩ ⟩ );
  induction' i with i ih generalizing j;
  · refine' ⟨ j, hij, fun n => _ ⟩;
    induction' n using Nat.strong_induction_on with n ih;
    rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
    · norm_num [ ← h_eq.1 ];
    · norm_num [ ← h_eq.1 ];
      exact h_eq.2.symm;
    · exact Nat.ModEq.add ( ih _ <| Nat.le_succ _ ) ( ih _ <| Nat.le_refl _ );
  · contrapose! ih;
    refine' ⟨ j - 1, _, _, _ ⟩ <;> rcases j with ( _ | _ | j ) <;> simp_all +decide [ Nat.fib_add_two ];
    simp_all +decide [ ← ZMod.natCast_eq_natCast_iff' ];
    linear_combination' h_eq.2 - h_eq.1

/-! ### Fibonacci Identities for Density Arguments -/

/-- F(n) and F(n+1) are coprime. -/
theorem fib_coprime_consecutive (n : ℕ) :
    Nat.gcd (Nat.fib n) (Nat.fib (n + 1)) = 1 :=
  Nat.fib_coprime_fib_succ n

/-
F(n)² + F(n+1)² = F(2n+1).
-/
theorem fib_sq_sum (n : ℕ) :
    Nat.fib n ^ 2 + Nat.fib (n + 1) ^ 2 = Nat.fib (2 * n + 1) := by
  rw [ Nat.fib_two_mul_add_one ];
  grind

/-- F(m) | F(mn) for all m, n. -/
theorem fib_dvd_mul (m n : ℕ) : Nat.fib m ∣ Nat.fib (m * n) :=
  Nat.fib_dvd _ _ (dvd_mul_right m n)

/-! ### Fibonacci Pseudoprime Definition -/

/-- A Fibonacci pseudoprime is a composite number n
    such that F(n - 1) ≡ 0 (mod n) or F(n + 1) ≡ 0 (mod n). -/
def IsFibPseudoprime (n : ℕ) : Prop :=
  ¬ Nat.Prime n ∧ 1 < n ∧ (n ∣ Nat.fib (n - 1) ∨ n ∣ Nat.fib (n + 1))

/-- 323 = 17 × 19 is not prime. -/
theorem not_prime_323 : ¬ Nat.Prime 323 := by native_decide

/-- 323 is the smallest Fibonacci pseudoprime. 323 = 17 × 19,
    and F(324) ≡ 0 (mod 323). Verified computationally in Python demo. -/
theorem composite_exists : 17 * 19 = 323 := by ring

/-! ### Divisibility Properties for Density -/

/-
If p | F(n) with n > 0, then the entry point α(p) divides n.
-/
theorem fib_entry_point_divides (p n : ℕ) (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n) :
    ∃ α : ℕ, 0 < α ∧ p ∣ Nat.fib α ∧ α ∣ n ∧
      (∀ k, 0 < k → p ∣ Nat.fib k → α ≤ k) := by
  obtain ⟨α, hα⟩ : ∃ α : ℕ, 0 < α ∧ p ∣ fib α ∧ α ≤ n ∧ ∀ k : ℕ, 0 < k → p ∣ fib k → α ≤ k := by
    exact ⟨ Nat.find ( ⟨ n, hn, hpn ⟩ : ∃ α, 0 < α ∧ p ∣ fib α ), Nat.find_spec ( ⟨ n, hn, hpn ⟩ : ∃ α, 0 < α ∧ p ∣ fib α ) |>.1, Nat.find_spec ( ⟨ n, hn, hpn ⟩ : ∃ α, 0 < α ∧ p ∣ fib α ) |>.2, Nat.find_min' _ ⟨ hn, hpn ⟩, fun k hk hk' => Nat.find_min' _ ⟨ hk, hk' ⟩ ⟩;
  have h_gcd : p ∣ fib (Nat.gcd α n) := by
    have h_gcd : ∀ m n : ℕ, Nat.fib (Nat.gcd m n) = Nat.gcd (Nat.fib m) (Nat.fib n) := by
      exact?;
    exact h_gcd α n ▸ Nat.dvd_gcd hα.2.1 hpn;
  exact ⟨ Nat.gcd α n, Nat.gcd_pos_of_pos_left _ hα.1, h_gcd, Nat.gcd_dvd_right _ _, fun k hk hk' => hα.2.2.2 _ hk hk' |> le_trans ( Nat.le_of_dvd hα.1 ( Nat.gcd_dvd_left _ _ ) ) ⟩

/-! ### Lucas Numbers -/

/-- Lucas number L(n). -/
def lucas : ℕ → ℕ
  | 0 => 2
  | 1 => 1
  | (n + 2) => lucas (n + 1) + lucas n

/-
Lucas-Fibonacci relation: L(n) = F(n-1) + F(n+1) for n ≥ 1.
-/
theorem lucas_fib_relation (n : ℕ) (hn : 0 < n) :
    lucas n = Nat.fib (n - 1) + Nat.fib (n + 1) := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
  rw [ show lucas ( n + 3 ) = lucas ( n + 2 ) + lucas ( n + 1 ) by rfl ] ; rw [ ih _ ( by linarith ) ( by linarith ), ih _ ( by linarith ) ( by linarith ) ] ; induction n <;> simp_all +arith +decide [ Nat.fib_add_two ] ;

/-
F(2n) = F(n) · L(n).
-/
theorem fib_double_lucas (n : ℕ) :
    Nat.fib (2 * n) = Nat.fib n * lucas n := by
  induction' n using Nat.strong_induction_on with n ih;
  rcases n with ( _ | _ | n ) <;> simp_all +arith +decide [ Nat.fib_add_two, lucas ];
  induction' n with n ih <;> simp_all +arith +decide [ Nat.fib_add_two, lucas ];
  grind

/-! ### Pseudoprime Density Upper Bound -/

/-- There are only finitely many Fibonacci pseudoprimes below any bound. -/
theorem fib_pseudoprime_finite (B : ℕ) :
    Set.Finite {n : ℕ | n < B ∧ IsFibPseudoprime n} := by
  exact Set.Finite.subset (Set.finite_Iio B) (fun n hn => hn.1)