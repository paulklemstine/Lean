import Mathlib
import Shared.Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers

/-!
# The rank-of-apparition interface

This module packages the *rank of apparition* of a natural number in the
Fibonacci sequence — the least positive index at which the number appears as a
divisor — in the form used by the entry-point files of the catalog.

The underlying theory (existence of the rank via pure periodicity of the
Fibonacci pair sequence modulo `m`, and the divisibility criterion
`m ∣ F n ↔ rank m ∣ n` via the strong divisibility law
`gcd (F a) (F b) = F (gcd a b)`) lives in
`Shared.Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers`.
Here it is restated in a hypothesis-carrying form: `HasFibRank m` records that
`m` appears at all, and every statement about `fibRank m` takes that witness as
its argument.
-/

namespace FibonacciApparitionSheaf

/-- `m` **has a rank of apparition** when it divides some Fibonacci number of
positive index. -/
def HasFibRank (m : ℕ) : Prop := ∃ n, 0 < n ∧ m ∣ Nat.fib n

/-- Every positive number has a rank of apparition: the Fibonacci pair sequence
modulo `m` is purely periodic, so the pair `(0, 1)` recurs. -/
theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m :=
  FibPrimitive.exists_pos_dvd_fib m hm

/-- A number with a rank of apparition is positive (`F n = 0` only at `n = 0`). -/
theorem pos_of_hasFibRank {m : ℕ} (h : HasFibRank m) : 0 < m := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · obtain ⟨n, hn, hdvd⟩ := h
    rw [Nat.zero_dvd] at hdvd
    rw [Nat.fib_eq_zero] at hdvd
    omega
  · exact hm

/-- The **rank of apparition** of `m`: the least positive index `n` with
`m ∣ F n`. -/
noncomputable def fibRank (m : ℕ) : ℕ := FibPrimitive.fibRank m

theorem fibRank_pos {m : ℕ} (h : HasFibRank m) : 0 < fibRank m :=
  FibPrimitive.fibRank_pos m (pos_of_hasFibRank h)

theorem dvd_fib_fibRank {m : ℕ} (h : HasFibRank m) : m ∣ Nat.fib (fibRank m) :=
  FibPrimitive.dvd_fib_fibRank m (pos_of_hasFibRank h)

/-- **Minimality.**  Below the rank of apparition the number never appears. -/
theorem fibRank_min {m k : ℕ} (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k := by
  intro hdvd
  have hle := FibPrimitive.fibRank_le hk hdvd
  rw [fibRank] at hlt
  omega

/-- **The divisibility criterion.**  `m` divides `F n` exactly when its rank of
apparition divides `n`. -/
theorem fibRank_dvd_iff {m : ℕ} (h : HasFibRank m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n :=
  FibPrimitive.dvd_fib_iff_fibRank_dvd m (pos_of_hasFibRank h) n

end FibonacciApparitionSheaf