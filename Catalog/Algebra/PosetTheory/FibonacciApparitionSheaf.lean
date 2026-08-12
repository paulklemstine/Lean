import Mathlib
import Shared.Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers

/-! # Rank-of-apparition interface

This module is imported by `Shared.NumberTheory.CarmichaelCompositeEntryPoint` but is
absent from the catalog snapshot.  The theory it is used for — the rank of apparition
`fibRank` of a modulus and its divisibility characterisation — is developed in
`Shared.Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers` under the
namespace `FibPrimitive`.  The section below is a thin interface exposing that
development under the names its consumers use.
-/

namespace FibonacciApparitionSheaf

open FibPrimitive

/-- A modulus has a rank of apparition as soon as it is positive. -/
def HasFibRank (m : ℕ) : Prop := 0 < m

/-- The rank of apparition: the least positive index whose Fibonacci number is
divisible by `m`. -/
noncomputable def fibRank (m : ℕ) : ℕ := FibPrimitive.fibRank m

theorem hasFibRank_of_pos (m : ℕ) (hm : 0 < m) : HasFibRank m := hm

theorem fibRank_pos {m : ℕ} (h : HasFibRank m) : 0 < fibRank m :=
  FibPrimitive.fibRank_pos m h

theorem dvd_fib_fibRank {m : ℕ} (h : HasFibRank m) : m ∣ Nat.fib (fibRank m) :=
  FibPrimitive.dvd_fib_fibRank m h

theorem fibRank_dvd_iff {m : ℕ} (h : HasFibRank m) (n : ℕ) :
    m ∣ Nat.fib n ↔ fibRank m ∣ n :=
  FibPrimitive.dvd_fib_iff_fibRank_dvd m h n

theorem fibRank_min {m k : ℕ} (hk : 0 < k) (hlt : k < fibRank m) : ¬ m ∣ Nat.fib k := by
  intro hdvd
  exact absurd (FibPrimitive.fibRank_le hk hdvd) (not_le.2 hlt)

end FibonacciApparitionSheaf