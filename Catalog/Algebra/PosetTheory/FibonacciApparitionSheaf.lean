import Mathlib
import Shared.Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers

/-!
# The Fibonacci rank of apparition, in the form used by the entry-point files

This module was referenced by `Shared.NumberTheory.CarmichaelCompositeEntryPoint` but was not
present in the repository.  It is reconstructed here as a thin interface over the rank of
apparition theory already developed in
`Shared.Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers` (namespace
`FibPrimitive`), so that nothing is duplicated: existence of the rank is the pigeonhole
argument proved there, and the divisibility criterion is the strong divisibility law
`gcd (F a) (F b) = F (gcd a b)`.

* `HasFibRank m` — `m` divides some Fibonacci number of positive index.
* `fibRank m` — the least such index.
* `hasFibRank_of_pos`, `fibRank_pos`, `dvd_fib_fibRank`, `fibRank_min`, `fibRank_dvd_iff`.
-/

namespace FibonacciApparitionSheaf

/-- `m` has a rank of apparition: it divides a Fibonacci number of positive index. -/
def HasFibRank (m : ℕ) : Prop := ∃ n, 0 < n ∧ m ∣ Nat.fib n

/-- The rank of apparition of `m`: the least positive index `n` with `m ∣ F n`. -/
noncomputable def fibRank (m : ℕ) : ℕ := FibPrimitive.fibRank m

/-- **Existence of the rank of apparition**: every positive integer divides a Fibonacci
number of positive index. -/
theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m :=
  FibPrimitive.exists_pos_dvd_fib m hm

/-- Only positive integers have a rank of apparition. -/
theorem pos_of_hasFibRank {m : ℕ} (h : HasFibRank m) : 0 < m := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · obtain ⟨n, hn, hdvd⟩ := h
    have h0 : Nat.fib n = 0 := Nat.eq_zero_of_zero_dvd hdvd
    have : 0 < Nat.fib n := Nat.fib_pos.mpr hn
    omega
  · exact hm

theorem fibRank_pos {m : ℕ} (h : HasFibRank m) : 0 < fibRank m :=
  FibPrimitive.fibRank_pos m (pos_of_hasFibRank h)

theorem dvd_fib_fibRank {m : ℕ} (h : HasFibRank m) : m ∣ Nat.fib (fibRank m) :=
  FibPrimitive.dvd_fib_fibRank m (pos_of_hasFibRank h)

/-- Minimality of the rank of apparition. -/
theorem fibRank_min {m k : ℕ} (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k := by
  intro hdvd
  have := FibPrimitive.fibRank_le hk hdvd
  exact absurd this (by simpa [fibRank] using Nat.not_le.mpr hlt)

/-- **The divisibility criterion**: `m ∣ F n` exactly when the rank of apparition divides
`n`. -/
theorem fibRank_dvd_iff {m : ℕ} (h : HasFibRank m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n :=
  FibPrimitive.dvd_fib_iff_fibRank_dvd m (pos_of_hasFibRank h) n

end FibonacciApparitionSheaf