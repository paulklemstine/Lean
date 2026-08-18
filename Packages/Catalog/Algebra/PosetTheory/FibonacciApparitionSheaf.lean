import Mathlib

/-! # The Fibonacci rank of apparition

This module supplies the rank-of-apparition machinery used by
`Shared.NumberTheory.CarmichaelCompositeEntryPoint`: for a positive modulus `p`, the *rank
of apparition* (entry point) `fibRank p` is the least positive index `k` with `p ∣ F k`.

The two substantial facts proved here are

* `FibonacciApparitionSheaf.hasFibRank_of_pos` : every positive modulus divides some positive
  Fibonacci number.  The proof is the classical pigeonhole argument on the pairs
  `(F n, F (n+1))` in `ZMod p`: the pair sequence repeats, and the Fibonacci recurrence is
  invertible, so the repetition can be pushed back to index `0`, where `F 0 = 0`.
* `FibonacciApparitionSheaf.fibRank_dvd_iff` : `p ∣ F n ↔ fibRank p ∣ n`, i.e. the indices of
  apparition form exactly the multiples of the rank.  This uses the strong divisibility
  property `Nat.fib_gcd` of the Fibonacci sequence.
-/

namespace FibonacciApparitionSheaf

/-- `p` has a rank of apparition when it divides some Fibonacci number of positive index. -/
def HasFibRank (p : ℕ) : Prop := ∃ k, 0 < k ∧ p ∣ Nat.fib k

/-- The rank of apparition (entry point): the least positive index `k` with `p ∣ F k`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {k | 0 < k ∧ p ∣ Nat.fib k}

section Pigeonhole

variable {m : ℕ}

/-- The state of the Fibonacci recurrence modulo `m` at index `n`. -/
private def fibPair (m n : ℕ) : ZMod m × ZMod m := ((Nat.fib n : ZMod m), (Nat.fib (n + 1) : ZMod m))

/-- The Fibonacci recurrence is invertible: equal successor states have equal states. -/
private theorem fibPair_back {i j : ℕ} (h : fibPair m (i + 1) = fibPair m (j + 1)) :
    fibPair m i = fibPair m j := by
  obtain ⟨h1, h2⟩ := Prod.mk.injEq .. ▸ h
  have hi : ((Nat.fib (i + 2) : ℕ) : ZMod m) = (Nat.fib i : ZMod m) + (Nat.fib (i + 1) : ZMod m) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hj : ((Nat.fib (j + 2) : ℕ) : ZMod m) = (Nat.fib j : ZMod m) + (Nat.fib (j + 1) : ZMod m) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have h2' : ((Nat.fib (i + 2) : ℕ) : ZMod m) = ((Nat.fib (j + 2) : ℕ) : ZMod m) := by
    simpa using h2
  have : (Nat.fib i : ZMod m) = (Nat.fib j : ZMod m) := by
    have := h2'
    rw [hi, hj, h1] at this
    exact add_right_cancel this
  exact Prod.ext this h1

/-- Pushing a repetition of the state back to index `0`. -/
private theorem fibPair_shift (d : ℕ) : ∀ i : ℕ, fibPair m i = fibPair m (i + d) →
    fibPair m 0 = fibPair m d := by
  intro i
  induction i with
  | zero => exact fun h => by simpa using h
  | succ n ih =>
      intro h
      refine ih (fibPair_back ?_)
      have : n + 1 + d = n + d + 1 := by omega
      rw [this] at h
      exact h

end Pigeonhole

/-- **Existence of the rank of apparition.**  Every positive modulus divides some Fibonacci
number of positive index. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := by
  haveI : NeZero p := ⟨hp.ne'⟩
  obtain ⟨i, j, hij, hfij⟩ :=
    Finite.exists_ne_map_eq_of_infinite (fun n : ℕ => fibPair p n)
  -- normalise so that `i < j`
  rcases Nat.lt_or_ge i j with hlt | hge
  · refine ⟨j - i, by omega, ?_⟩
    have hshift : fibPair p i = fibPair p (i + (j - i)) := by
      have : i + (j - i) = j := by omega
      rw [this]; exact hfij
    have h0 := fibPair_shift (m := p) (j - i) i hshift
    have : ((Nat.fib (j - i) : ℕ) : ZMod p) = 0 := by
      have := congrArg Prod.fst h0
      simp only [fibPair] at this
      simpa using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).1 this
  · have hlt : j < i := by
      rcases Nat.lt_or_ge j i with h | h
      · exact h
      · exact absurd (le_antisymm h hge) hij
    refine ⟨i - j, by omega, ?_⟩
    have hshift : fibPair p j = fibPair p (j + (i - j)) := by
      have : j + (i - j) = i := by omega
      rw [this]; exact hfij.symm
    have h0 := fibPair_shift (m := p) (i - j) j hshift
    have : ((Nat.fib (i - j) : ℕ) : ZMod p) = 0 := by
      have := congrArg Prod.fst h0
      simp only [fibPair] at this
      simpa using this.symm
    exact (ZMod.natCast_eq_zero_iff _ _).1 this

/-- The rank of apparition is a positive index of apparition. -/
theorem fibRank_mem {p : ℕ} (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem (s := {k | 0 < k ∧ p ∣ Nat.fib k}) h

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **The indices of apparition are exactly the multiples of the rank.** -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hnpos
    · exact dvd_zero _
    have hgcd : p ∣ Nat.fib (Nat.gcd (fibRank p) n) := by
      rw [Nat.fib_gcd]
      exact Nat.dvd_gcd (dvd_fib_fibRank h) hn
    have hgpos : 0 < Nat.gcd (fibRank p) n := Nat.gcd_pos_of_pos_right _ hnpos
    have hle : Nat.gcd (fibRank p) n ≤ fibRank p := Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_left _ _)
    have heq : Nat.gcd (fibRank p) n = fibRank p := by
      by_contra hne
      exact fibRank_min hgpos (lt_of_le_of_ne hle hne) hgcd
    exact heq ▸ Nat.gcd_dvd_right (fibRank p) n
  · intro hdvd
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hdvd)

end FibonacciApparitionSheaf