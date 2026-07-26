import Mathlib

/-! # A Number-Theory ⋈ Holonomy Bridge: Ramanujan's third order mock theta f(q)

This file investigates the claim (Phase A research prompt v16):

> The coefficients `a_n` in `f(q) = ∑_{n≥0} a_n q^n` (Ramanujan's third order mock
> theta function `f(q) = ∑_{n≥0} q^{n^2} / ∏_{k=1}^n (1+q^k)^2`) satisfy
> `(n+3) a_{n+3} = (3n+4) a_{n+2} - (3n+1) a_{n+1} + n a_n` for all `n ≥ 0`,
> with `a_0 = 1, a_1 = 0, a_2 = 1`.

**Both halves of the claim are false.**  The genuine coefficients of `f(q)` are the
integer sequence OEIS A000025 `1, 1, -2, 3, -3, 3, -5, 7, -6, 6, ...`, so the stated
initial data `(a_0,a_1,a_2) = (1,0,1)` is already wrong (the true triple is
`(1, 1, -2)`).  Moreover, *the recurrence with the stated initial data has no integer
solution at all*: it forces `3 a_3 = 4`, i.e. `a_3 = 4/3 ∉ ℤ`.  Since the genuine
coefficients of `f(q)` are integers, the recurrence-with-initials simply cannot
describe them.

This is the "Bridges" content: it connects elementary number theory (integrality of
the q-expansion of a mock theta function) to the *holonomy* of a sequence (existence
of a polynomial-coefficient linear recurrence, i.e. P-recursiveness).  Mock theta
functions are famously **non-holonomic**, so no finite linear recurrence with
polynomial coefficients can hold — consistent with our computational search finding no
recurrence of order ≤ 5 and polynomial degree ≤ 5.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer):
  H1. The stated recurrence + initials describes the f(q) coefficients.            [tested]
  H2. The stated initials (1,0,1) are the true coefficients.                        [tested]
  H3. The stated recurrence has *some* integer solution with these initials.     [tested]
  H4. f(q)'s coefficients satisfy *some* low-order polynomial recurrence.           [tested, computational]

Experiment (Experimenter):
  * Computed f(q) coefficients to order 60 by formal power-series division:
      1, 1, -2, 3, -3, 3, -5, 7, -6, 6, -10, 12, -11, 13, -17, 20, ...  (A000025).
  * Evaluating the stated recurrence on the *stated* initials gives a_3 = 4/3, a_4 = 4/3,
    a_5 = 6/5 — non-integers.  → refutes H1, H3.
  * The true initials are (1,1,-2), not (1,0,1).                          → refutes H2.
  * Gaussian elimination over ℚ found NO nonzero polynomial recurrence of order r ≤ 5
    and degree d ≤ 5 fitting A000025.                                     → evidence against H4.

Analysis (Analyst):
  * "false" (not "true but hard"): the premise is internally inconsistent.  Over ℤ the
    recurrence's n=0 instance reads `3 a_3 = 4 a_2 - a_1 = 4`, with no integer root.
  * The deep reason H4 fails: mock theta functions are non-holonomic (Andrews et al.),
    so the very *shape* of the claim (a P-recurrence) cannot hold for genuine f(q).

Critique (Critic):
  * The integer-impossibility theorem must not be vacuous: we keep all three stated
    initials as hypotheses and derive a contradiction from a *single* recurrence
    instance, via `omega` on `3 * a 3 = 4`.
  * We additionally pin down the exact rational value forced at index 3 to make the
    non-integrality concrete and machine-checked, not merely asserted.

Synthesis (PI): see the three theorems below + the uniqueness companion file.
-- !-- End Lab Notes -- !--
-/

namespace MockThetaF

/-- The triple `(a n, a (n+1), a (n+2))` produced by running the *claimed* recurrence
`(n+3) a_{n+3} = (3n+4) a_{n+2} - (3n+1) a_{n+1} + n a_n` forward over `ℚ`, starting
from the *claimed* initial data `(a_0,a_1,a_2) = (1,0,1)`. -/
def claimAux : ℕ → ℚ × ℚ × ℚ
  | 0 => (1, 0, 1)
  | (n+1) =>
      ((claimAux n).2.1, (claimAux n).2.2,
        ((3 * (n : ℚ) + 4) * (claimAux n).2.2 - (3 * (n : ℚ) + 1) * (claimAux n).2.1
          + (n : ℚ) * (claimAux n).1) / ((n : ℚ) + 3))

/-- The candidate coefficient sequence forced by the claimed recurrence and initials. -/
def claimSeq (n : ℕ) : ℚ := (claimAux n).1

/-- Alignment: `claimSeq (m+1)` is the middle slot of `claimAux m`. -/
theorem claimSeq_succ (m : ℕ) : claimSeq (m + 1) = (claimAux m).2.1 := rfl

/-- Alignment: `claimSeq (m+2)` is the last slot of `claimAux m`. -/
theorem claimSeq_succ_succ (m : ℕ) : claimSeq (m + 2) = (claimAux m).2.2 := rfl

/-- Alignment: the explicit forward formula for `claimSeq (m+3)`. -/
theorem claimSeq_add_three (m : ℕ) :
    claimSeq (m + 3)
      = ((3 * (m : ℚ) + 4) * (claimAux m).2.2 - (3 * (m : ℚ) + 1) * (claimAux m).2.1
          + (m : ℚ) * (claimAux m).1) / ((m : ℚ) + 3) := rfl

@[simp] theorem claimSeq_zero : claimSeq 0 = 1 := rfl
@[simp] theorem claimSeq_one : claimSeq 1 = 0 := rfl
@[simp] theorem claimSeq_two : claimSeq 2 = 1 := rfl

/-- The claimed recurrence forces `a_3 = 4/3`. -/
theorem claimSeq_three : claimSeq 3 = 4 / 3 := by
  norm_num [claimSeq, claimAux]

/-- The claimed recurrence forces `a_4 = 4/3`. -/
theorem claimSeq_four : claimSeq 4 = 4 / 3 := by
  norm_num [claimSeq, claimAux]

/-- **Well-definedness / faithfulness.**  The sequence `claimSeq` really does satisfy the
claimed recurrence for *every* `n` — so it is the unique candidate, and refuting it
refutes the claim itself.  (Companion file proves the uniqueness.) -/
theorem claimSeq_satisfies_recurrence (n : ℕ) :
    ((n : ℚ) + 3) * claimSeq (n + 3)
      = (3 * (n : ℚ) + 4) * claimSeq (n + 2)
        - (3 * (n : ℚ) + 1) * claimSeq (n + 1) + (n : ℚ) * claimSeq n := by
  have hn : ((n : ℚ) + 3) ≠ 0 := by positivity
  rw [claimSeq_add_three n, claimSeq_succ_succ n, claimSeq_succ n]
  show ((n : ℚ) + 3) * (_ / ((n : ℚ) + 3)) = _
  have hcs : claimSeq n = (claimAux n).1 := rfl
  rw [hcs]
  field_simp

/-- **Headline disproof.**  No integer sequence whatsoever can satisfy the claimed
recurrence with the claimed initial data `(1,0,1)`: the `n = 0` instance forces
`3 a_3 = 4`, which has no integer solution.  In particular the genuine (integer)
coefficient sequence of `f(q)` does not satisfy it. -/
theorem no_integer_sequence_satisfies_claim :
    ¬ ∃ a : ℕ → ℤ, a 0 = 1 ∧ a 1 = 0 ∧ a 2 = 1 ∧
      (∀ n : ℕ, ((n : ℤ) + 3) * a (n + 3)
        = (3 * (n : ℤ) + 4) * a (n + 2) - (3 * (n : ℤ) + 1) * a (n + 1) + (n : ℤ) * a n) := by
  rintro ⟨a, _h0, h1, h2, hrec⟩
  have h := hrec 0
  simp only [Nat.cast_zero] at h
  rw [h1, h2] at h
  omega

/-- The value forced at index `3` is genuinely non-integral: there is no integer `m`
with `claimSeq 3 = m`.  This makes the inconsistency with an *integer* power series
concrete. -/
theorem claimSeq_three_not_integer : ¬ ∃ m : ℤ, claimSeq 3 = (m : ℚ) := by
  rintro ⟨m, hm⟩
  rw [claimSeq_three] at hm
  have hcast : ((3 * m : ℤ) : ℚ) = ((4 : ℤ) : ℚ) := by
    push_cast
    linarith [hm]
  have : (3 * m : ℤ) = 4 := Int.cast_injective hcast
  omega

end MockThetaF