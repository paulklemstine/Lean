import Mathlib

/-!
# “Escher staircases” and the direction of ideal containment

The proposed motivating family is formalized below.  The key correction is that
ideals of elements divisible by increasing powers of `2` form a strictly
*descending* chain, not an ascending one.  More generally, the intersection of
a monotone ascending chain of ideals is exactly its first ideal.  Membership of
zero in that intersection is automatic for every family of ideals and hence
does not create a loop.
-/

namespace EscherStaircases

variable {R : Type*} [Semiring R]

/-- The first ideal of an ascending sequence is contained in every ideal in the sequence. -/
theorem first_le_each_of_monotone (I : ℕ → Ideal R) (hI : Monotone I) (n : ℕ) :
    I 0 ≤ I n := by
  exact hI n.zero_le

/-- Consequently, the first ideal is contained in the intersection. -/
theorem first_le_iInf_of_monotone (I : ℕ → Ideal R) (hI : Monotone I) :
    I 0 ≤ ⨅ n, I n := by
  exact le_iInf fun n => hI n.zero_le

/-- The intersection of an ascending sequence of ideals is its first term. -/
theorem iInf_eq_first_of_monotone (I : ℕ → Ideal R) (hI : Monotone I) :
    (⨅ n, I n) = I 0 := by
  aesop

/-- An ascending sequence beginning with a nonzero ideal cannot have zero intersection. -/
theorem iInf_ne_bot_of_monotone (I : ℕ → Ideal R) (hI : Monotone I) (h0 : I 0 ≠ ⊥) :
    (⨅ n, I n) ≠ ⊥ := by
  rw [iInf_eq_first_of_monotone I hI]
  exact h0

/-- Zero belongs to the intersection of every family of ideals, independently of nesting. -/
theorem zero_mem_iInf (I : ℕ → Ideal R) : (0 : R) ∈ ⨅ n, I n := by
  simp

section Integers

/-- The ideal of integers divisible by `2^n`, expressed as a power of `(2)`. -/
def twoPowerIdeal (n : ℕ) : Ideal ℤ := (Ideal.span ({(2 : ℤ)} : Set ℤ)) ^ n

/-- Increasing the exponent gives inclusion in the reverse direction. -/
theorem twoPowerIdeal_antitone : Antitone twoPowerIdeal := by
  intro m n hmn
  exact Ideal.pow_le_pow_right hmn

/-- Each containment `(2^(n+1)) ⊆ (2^n)` is strict. -/
theorem twoPowerIdeal_strictAnti : StrictAnti twoPowerIdeal := by
  refine strictAnti_nat_of_succ_lt ?_
  intro n
  refine lt_of_le_of_ne (twoPowerIdeal_antitone n.le_succ) ?_
  induction n <;> simp_all +decide [twoPowerIdeal, pow_succ]

/-- The intersection of all ideals `(2^n)` in `ℤ` is the zero ideal. -/
theorem iInf_twoPowerIdeal_eq_bot : (⨅ n, twoPowerIdeal n) = ⊥ := by
  convert Ideal.iInf_pow_eq_bot_of_isDomain (Ideal.span {(2 : ℤ)}) _
  simp +decide

/-- The corrected complete statement: the power-of-two ideals form an infinite,
strictly descending chain with zero intersection. -/
theorem powers_of_two_corrected_staircase :
    StrictAnti twoPowerIdeal ∧ (⨅ n, twoPowerIdeal n) = ⊥ := by
  exact ⟨ twoPowerIdeal_strictAnti, iInf_twoPowerIdeal_eq_bot ⟩

end Integers

end EscherStaircases