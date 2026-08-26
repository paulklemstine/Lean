import Mathlib

/-! # Ranks of apparition for the Fibonacci sequence

For a positive modulus `p` the pair sequence `n ↦ (F n, F (n+1))` taken in `ZMod p`
is *purely* periodic, because the Fibonacci step map is invertible.  Consequently
`p` divides some positive Fibonacci number, and the least such index — the *rank of
apparition* `fibRank p` — controls all Fibonacci divisibility by `p`:
`p ∣ F n ↔ fibRank p ∣ n`.

This file supplies that theory; downstream files (entry points of primes,
primitive divisors) are built on top of it.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition: some positive Fibonacci number is divisible by `p`. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- The state of the Fibonacci recursion at time `n`, read modulo `p`. -/
private def fpair (p n : ℕ) : ZMod p × ZMod p :=
  ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))

/-- The Fibonacci step map is injective on states: the state at time `n` is recoverable
from the state at time `n + 1`. -/
private lemma fpair_step_injective {p m n : ℕ} (h : fpair p (m + 1) = fpair p (n + 1)) :
    fpair p m = fpair p n := by
  have h1 : (Nat.fib (m + 1) : ZMod p) = (Nat.fib (n + 1) : ZMod p) := congrArg Prod.fst h
  have h2 : (Nat.fib (m + 2) : ZMod p) = (Nat.fib (n + 2) : ZMod p) := congrArg Prod.snd h
  have e : ∀ k : ℕ,
      (Nat.fib (k + 2) : ZMod p) = (Nat.fib k : ZMod p) + (Nat.fib (k + 1) : ZMod p) := by
    intro k; rw [Nat.fib_add_two]; push_cast; ring
  have hm : (Nat.fib m : ZMod p) = (Nat.fib n : ZMod p) := by
    rw [e m, e n, h1] at h2
    exact add_right_cancel h2
  exact Prod.ext hm h1

/-- Injectivity of the step map upgrades eventual periodicity to pure periodicity. -/
private lemma fpair_shift {p : ℕ} :
    ∀ i d : ℕ, fpair p (i + d) = fpair p i → fpair p d = fpair p 0
  | 0, d, h => by simpa using h
  | (i + 1), d, h => by
      refine fpair_shift i d ?_
      refine fpair_step_injective (p := p) ?_
      have hi : i + 1 + d = (i + d) + 1 := by omega
      rw [hi] at h
      exact h

/-- Every positive modulus divides some positive Fibonacci number. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  obtain ⟨i, j, hij, hfe⟩ := Finite.exists_ne_map_eq_of_infinite (fpair p)
  rcases lt_or_gt_of_ne hij with hlt | hlt
  · refine ⟨j - i, by omega, ?_⟩
    have hh : fpair p (i + (j - i)) = fpair p i := by
      have hji : i + (j - i) = j := by omega
      rw [hji, hfe]
    have hs := fpair_shift i (j - i) hh
    have h0 : (Nat.fib (j - i) : ZMod p) = 0 := by
      simpa [fpair] using congrArg Prod.fst hs
    exact (ZMod.natCast_eq_zero_iff _ _).mp h0
  · refine ⟨i - j, by omega, ?_⟩
    have hh : fpair p (j + (i - j)) = fpair p j := by
      have hji : j + (i - j) = i := by omega
      rw [hji, hfe]
    have hs := fpair_shift j (i - j) hh
    have h0 : (Nat.fib (i - j) : ZMod p) = 0 := by
      simpa [fpair] using congrArg Prod.fst hs
    exact (ZMod.natCast_eq_zero_iff _ _).mp h0

open Classical in
/-- The rank of apparition of `p`: the least positive index `n` with `p ∣ F n`
(and `0` for the degenerate moduli that never appear). -/
noncomputable def fibRank (p : ℕ) : ℕ := if h : HasFibRank p then Nat.find h else 0

theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := by
  classical
  rw [fibRank, dif_pos h]
  exact (Nat.find_spec h).1

theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := by
  classical
  rw [fibRank, dif_pos h]
  exact (Nat.find_spec h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  classical
  by_cases h : HasFibRank p
  · rw [fibRank, dif_pos h] at hlt
    intro hdvd
    exact Nat.find_min h hlt ⟨hk, hdvd⟩
  · rw [fibRank, dif_neg h] at hlt
    omega

/-- The divisibility law: `p ∣ F n` exactly when the rank of apparition divides `n`. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hpn
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · exact dvd_zero _
    · have hg : p ∣ Nat.fib (Nat.gcd n (fibRank p)) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hpn (dvd_fib_fibRank h)
      have hrpos := fibRank_pos h
      have hgd : Nat.gcd n (fibRank p) ∣ fibRank p := Nat.gcd_dvd_right _ _
      have hgpos : 0 < Nat.gcd n (fibRank p) := Nat.gcd_pos_of_pos_left _ hn
      have hle : Nat.gcd n (fibRank p) ≤ fibRank p := Nat.le_of_dvd hrpos hgd
      have heq : Nat.gcd n (fibRank p) = fibRank p := by
        rcases lt_or_eq_of_le hle with hlt | heq
        · exact absurd hg (fibRank_min hgpos hlt)
        · exact heq
      exact heq ▸ Nat.gcd_dvd_left n (fibRank p)
  · intro hd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hd)

end FibonacciApparitionSheaf