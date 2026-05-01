/-! # CatalogBuild.Shared.CarmichaelComposite

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 6
-/

import Mathlib
import Shared.CarmichaelHelper
import Shared.CarmichaelProof

noncomputable section

/-- The "Fibonacci entry point" of p: smallest k > 0 with p | F(k), or 0 if none. -/
noncomputable def fibEntryPt (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else 0


/-- [Section: # Carmichael's theorem for composite n
We prove that for composite n ≥ 14, F(n) has a primitive prime divisor.] -/
lemma fib_dvd_gcd_of_dvd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) := by
  exact Nat.dvd_gcd hn hk |> fun h => by simpa [ Nat.fib_gcd ] using h;


lemma fibEntryPt_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) : fibEntryPt p ∣ n := by
  set α := fibEntryPt p
  have hα_pos : 0 < α := by
    unfold α fibEntryPt;
    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ]
  have hα_div : p ∣ Nat.fib α := by
    simp +zetaDelta at *;
    unfold fibEntryPt at *;
    split_ifs at * <;> simp_all +decide [ Nat.find_spec ( _ : ∃ k, 0 < k ∧ p ∣ Nat.fib k ) ]
  have hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m) := by
    simp +zetaDelta at *;
    unfold fibEntryPt at *; aesop;
  have h_gcd_eq : Nat.gcd n α = α := by
    exact le_antisymm ( Nat.le_of_dvd hα_pos ( Nat.gcd_dvd_right _ _ ) ) ( Nat.le_of_not_gt fun h => hα_min _ ( Nat.gcd_pos_of_pos_left _ hn ) h <| fib_dvd_gcd_of_dvd _ _ _ hpn hα_div );
  exact h_gcd_eq ▸ Nat.gcd_dvd_left _ _


lemma fibEntryPt_pos (p : ℕ) (hp : Nat.Prime p) (hn : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPt p := by
  unfold fibEntryPt; aesop;


lemma primitive_of_entryPt_eq (p n : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
    (heq : fibEntryPt p = n) (hn : 0 < n) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hk' hk''; have := fibEntryPt_dvd_of_fib_dvd p k ( by assumption ) ( by linarith ) hk''; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
  rw [ Nat.mod_eq_of_lt ] at this <;> linarith


/-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
This combines the prime case (from CarmichaelHelper) with the composite case. -/
theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases hnp : Nat.Prime n
  · exact fib_primitive_divisor_prime n hn hnp
  · exact fib_carmichael_composite n hn hnp


end
