import Mathlib
import Bridges.SternDiatomicFibonacci

/-! # Stern ↔ Fibonacci bridge along the Jacobsthal indices

Building on the core development in `Bridges/SternDiatomicFibonacci.lean`, this
file proves the headline cross-domain result of the cycle: **Stern's diatomic
sequence reproduces the even-index Fibonacci numbers along the Jacobsthal
indices**.

The Jacobsthal numbers `J n = (4^n − 1)/3 = 0, 1, 5, 21, 85, …` (OEIS A002450)
are exactly the natural numbers whose binary expansion is the alternating block
`0101…01` with `n` ones. The main theorem is

  `s (J n) = F (2n)`   (`stern_jacobsthal_fib`),

with odd-index companion `s (2·J n + 1) = F (2n+1)`.

This is a genuine bridge between two classical integer sequences of entirely
different origin — a binary-recursive "fusc" function and the additive Fibonacci
recurrence — which coincide exactly along an explicit sparse set of indices.

-- !-- Lab Notes -- !--
Hypothesis (H3, H5, H6 from the core file): along `J n`, Stern reads off the even
  Fibonacci numbers, and along `2·J n + 1` the odd Fibonacci numbers; the pair
  `(s(Jₙ), s(2Jₙ+1))` obeys the same 2-step linear recurrence as `(F(2n), F(2n+1))`.
Experiment: verified numerically — `s(Jₙ) = [0,1,3,8,21,55,144,377] = F(2n)` and
  `s(2Jₙ+1) = [1,2,5,13,34,89,233,610] = F(2n+1)` for the first eight indices.
Analysis / Synthesis: neither component of the pair is provable in isolation; the
  step for `s(J (n+1))` needs `s(2·J n + 1)` and vice-versa. The clean fix is the
  *joint* invariant `stern_jacobsthal_pair`, proved by a single induction that
  feeds both equational lemmas `stern_even`/`stern_odd` into `Nat.fib_add_two`.
Critique: the closed form `jac_closed : 3·J n + 1 = 4^n` guards the translation to
  the `(4^n − 1)/3` statement, avoiding any hidden division-by-zero corner case.
  No `sorry`; axioms are the standard three.
-/

namespace SternDiatomicFibonacci

open Nat

/-- The Jacobsthal indices `J 0 = 0`, `J (n+1) = 4·J n + 1` (OEIS A002450);
`J n` is the natural number with binary expansion `0101…01` (`n` ones). -/
def jac : ℕ → ℕ
  | 0 => 0
  | (n + 1) => 4 * jac n + 1

/-- Closed form: `3·J n + 1 = 4^n`, i.e. `J n = (4^n − 1)/3`. -/
lemma jac_closed (n : ℕ) : 3 * jac n + 1 = 4 ^ n := by
  induction n <;> simp +arith +decide [*, pow_succ']
  rw [show jac (_ + 1) = 4 * jac _ + 1 from rfl]; linarith

/-- Coupled bridge: along the Jacobsthal indices, the pair
`(s(J n), s(2·J n + 1))` equals `(F(2n), F(2n+1))`. This joint invariant is what
makes the induction go through — neither component closes on its own. -/
lemma stern_jacobsthal_pair (n : ℕ) :
    stern (jac n) = Nat.fib (2 * n) ∧
      stern (2 * jac n + 1) = Nat.fib (2 * n + 1) := by
  induction' n with n ih
  · refine ⟨?_, ?_⟩ <;> simp [jac]
  · simp_all +decide [Nat.mul_succ, jac]
    convert And.intro _ _ using 2
    · rw [show 4 * jac n + 1 = 2 * (2 * jac n) + 1 by ring, stern_odd]
      rw [stern_even, ih.1, ih.2, Nat.fib_add_two]
    · rw [show 2 * (4 * jac n) + 2 + 1 = 2 * (4 * jac n + 1) + 1 by ring, stern_odd]
      rw [show 4 * jac n + 1 = 2 * (2 * jac n) + 1 by ring, stern_odd]
      simp +arith +decide [*]
      rw [show 4 * jac n + 2 = 2 * (2 * jac n + 1) by ring, stern_even]
      simp +arith +decide [*, Nat.fib_add_two]
      rw [stern_even, ih.1]

/-! ### Theorem 3 : the Fibonacci bridge -/

/-- **Fibonacci bridge.** Stern's diatomic sequence reproduces the even-index
Fibonacci numbers along the Jacobsthal indices: `s(J n) = F(2n)`. -/
theorem stern_jacobsthal_fib (n : ℕ) : stern (jac n) = Nat.fib (2 * n) :=
  (stern_jacobsthal_pair n).1

/-- Odd-index companion: `s(2·J n + 1) = F(2n+1)`. -/
theorem stern_jacobsthal_fib_odd (n : ℕ) :
    stern (2 * jac n + 1) = Nat.fib (2 * n + 1) :=
  (stern_jacobsthal_pair n).2

/-- Closed-form restatement of the bridge in terms of `(4^n − 1)/3`. -/
theorem stern_fib_closed (n : ℕ) : stern ((4 ^ n - 1) / 3) = Nat.fib (2 * n) := by
  have h : (4 ^ n - 1) / 3 = jac n := by
    have := jac_closed n
    omega
  rw [h]; exact stern_jacobsthal_fib n

end SternDiatomicFibonacci