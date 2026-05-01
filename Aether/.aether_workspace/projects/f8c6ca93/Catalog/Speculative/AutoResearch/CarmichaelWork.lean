import Mathlib

/-! # Standalone Carmichael theorem helper

This file proves key lemmas for Carmichael's primitive divisor theorem
for Fibonacci numbers, to be imported by the main proof.
-/

set_option maxHeartbeats 800000
open Classical

/-- The entry point of a prime p in the Fibonacci sequence -/
noncomputable def fibEntry' (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then Nat.find h else 0

lemma fibEntry'_pos {p n : ℕ} (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    0 < fibEntry' p := by
  unfold fibEntry'; aesop

lemma fibEntry'_dvd {p n : ℕ} (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    fibEntry' p ∣ n := by
  unfold fibEntry'
  split_ifs with h
  · have h_gcd : Nat.gcd (Nat.find h) n = Nat.find h := by
      have h_gcd : p ∣ Nat.fib (Nat.gcd (Nat.find h) n) := by
        exact Nat.dvd_gcd (Nat.find_spec h |>.2) hpn |> fun h => h.trans (by simp +decide [Nat.fib_gcd])
      exact le_antisymm (Nat.le_of_dvd (Nat.pos_of_ne_zero (by aesop)) (Nat.gcd_dvd_left _ _))
        (Nat.find_min' h ⟨Nat.gcd_pos_of_pos_left _ (Nat.pos_of_ne_zero (by aesop)), h_gcd⟩)
    exact h_gcd ▸ Nat.gcd_dvd_right _ _
  · exact False.elim <| h ⟨n, hn, hpn⟩

lemma fibEntry'_dvd_fib {p n : ℕ} (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (fibEntry' p) := by
  unfold fibEntry'
  split_ifs <;> simp_all +decide [Nat.find_spec (show ∃ k, 0 < k ∧ p ∣ Nat.fib k from ⟨n, hn, hpn⟩)]

lemma fibEntry'_min {p n : ℕ} (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n)
    {k : ℕ} (hk : 0 < k) (hk2 : k < fibEntry' p) : ¬ p ∣ Nat.fib k := by
  contrapose! hk2; unfold fibEntry'; aesop

/-- For composite n > 10000, F(n) has a primitive prime divisor.

    This is the key sorry that blocks the Carmichael theorem.
    The proof requires showing that the "primitive part" Ψ(n) of F(n) is > 1
    for large composite n, which follows from the Binet formula and
    Möbius inversion. -/
theorem fib_carmichael_large' (n : ℕ) (hn : 10000 < n) (hnp : ¬ Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬ p ∣ Nat.fib k := by
  sorry