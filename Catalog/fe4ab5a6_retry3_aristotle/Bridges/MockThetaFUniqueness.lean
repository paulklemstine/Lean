import Mathlib
import Bridges.MockThetaFRecurrence

/-! # Uniqueness of the solution to the claimed mock-theta recurrence

Companion to `Bridges.MockThetaFRecurrence`.  We prove that the order-3 recurrence
`(n+3) a_{n+3} = (3n+4) a_{n+2} - (3n+1) a_{n+1} + n a_n` over `ℚ` has a *unique*
solution once `a_0, a_1, a_2` are fixed (the leading coefficient `n+3` never vanishes
over `ℕ`, so each next term is determined).  Combining this with
`MockThetaF.claimSeq_satisfies_recurrence` and `MockThetaF.claimSeq_three_not_integer`
shows: the unique rational sequence obeying the *claimed* data already fails to be
integer-valued at index 3 — so it cannot be the integer q-expansion of `f(q)`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):
  H5. The claimed recurrence + claimed initials determine at most one ℚ-sequence.
  H6. Hence ANY ℚ-sequence matching the claim is non-integral at index 3.

Experiment (Experimenter):
  * `recurrence_unique`: strong induction on `n`; for `n = k+3` cancel the nonzero
    factor `(k+3)` and use the induction hypotheses at `k, k+1, k+2`.
  * `claim_solution_not_integer`: instantiate uniqueness against `MockThetaF.claimSeq`.

Analysis (Analyst):
  * The uniqueness is what upgrades "claimSeq is *a* solution" to "claimSeq is *the*
    solution", so the disproof in the companion file is not about an arbitrary choice.
  * Failure mode avoided: over `ℕ`/`ℤ` cancellation of `(k+3)` is illegal; we work in `ℚ`
    where `(k+3) ≠ 0` lets `mul_left_cancel₀` finish.

Critique (Critic):
  * Each main theorem uses real machinery (strong induction; `mul_left_cancel₀`;
    cast-injectivity), not `decide`/`simp`-only.
  * The hypotheses of `recurrence_unique` are all load-bearing (drop any initial value
    or either recurrence and the conclusion fails).

Synthesis (PI): uniqueness + non-integrality ⇒ the stated recurrence cannot present the
coefficients of the (integer) mock theta function `f(q)`.
-- !-- End Lab Notes -- !--
-/

namespace MockThetaF

/-- **Uniqueness.**  Two `ℚ`-sequences that agree on the first three values and both obey
the order-3 recurrence `(n+3) a_{n+3} = (3n+4) a_{n+2} - (3n+1) a_{n+1} + n a_n` are
equal everywhere.  (The leading coefficient `(n+3)` is nonzero over `ℕ`, pinning the
next term down.) -/
theorem recurrence_unique (a b : ℕ → ℚ)
    (h0 : a 0 = b 0) (h1 : a 1 = b 1) (h2 : a 2 = b 2)
    (hra : ∀ n : ℕ, ((n : ℚ) + 3) * a (n + 3)
      = (3 * (n : ℚ) + 4) * a (n + 2) - (3 * (n : ℚ) + 1) * a (n + 1) + (n : ℚ) * a n)
    (hrb : ∀ n : ℕ, ((n : ℚ) + 3) * b (n + 3)
      = (3 * (n : ℚ) + 4) * b (n + 2) - (3 * (n : ℚ) + 1) * b (n + 1) + (n : ℚ) * b n) :
    ∀ n, a n = b n := by
  intro n
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    match n with
    | 0 => exact h0
    | 1 => exact h1
    | 2 => exact h2
    | (k + 3) =>
        have hk := ih k (by omega)
        have hk1 := ih (k + 1) (by omega)
        have hk2 := ih (k + 2) (by omega)
        have hn : ((k : ℚ) + 3) ≠ 0 := by positivity
        have key : ((k : ℚ) + 3) * a (k + 3) = ((k : ℚ) + 3) * b (k + 3) := by
          rw [hra k, hrb k, hk, hk1, hk2]
        exact mul_left_cancel₀ hn key

/-- Any rational sequence obeying the *claimed* recurrence and *claimed* initials
`(1,0,1)` coincides with `claimSeq`. -/
theorem eq_claimSeq (a : ℕ → ℚ)
    (h0 : a 0 = 1) (h1 : a 1 = 0) (h2 : a 2 = 1)
    (hra : ∀ n : ℕ, ((n : ℚ) + 3) * a (n + 3)
      = (3 * (n : ℚ) + 4) * a (n + 2) - (3 * (n : ℚ) + 1) * a (n + 1) + (n : ℚ) * a n) :
    ∀ n, a n = claimSeq n := by
  refine recurrence_unique a claimSeq ?_ ?_ ?_ hra (fun n => claimSeq_satisfies_recurrence n)
  · simpa using h0
  · simpa using h1
  · simpa using h2

/-- **Consequence.**  Any rational sequence obeying the claimed data is non-integral at
index 3 (its value there is `4/3`).  Hence no integer sequence — in particular no
integer q-expansion of a mock theta function — can satisfy the claim. -/
theorem claim_solution_not_integer (a : ℕ → ℚ)
    (h0 : a 0 = 1) (h1 : a 1 = 0) (h2 : a 2 = 1)
    (hra : ∀ n : ℕ, ((n : ℚ) + 3) * a (n + 3)
      = (3 * (n : ℚ) + 4) * a (n + 2) - (3 * (n : ℚ) + 1) * a (n + 1) + (n : ℚ) * a n) :
    ¬ ∃ m : ℤ, a 3 = (m : ℚ) := by
  have h3 : a 3 = 4 / 3 := by rw [eq_claimSeq a h0 h1 h2 hra 3]; exact claimSeq_three
  rintro ⟨m, hm⟩
  rw [h3] at hm
  have hcast : ((3 * m : ℤ) : ℚ) = ((4 : ℤ) : ℚ) := by push_cast; linarith [hm]
  have : (3 * m : ℤ) = 4 := Int.cast_injective hcast
  omega

end MockThetaF