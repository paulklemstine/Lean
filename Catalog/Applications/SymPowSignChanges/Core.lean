import Mathlib

/-!
# Sign changes over sums of `m` squares — the collapse mechanism (Core)

This file develops the abstract engine behind the statement

> for a normalised Hecke eigenform `f` of even weight `k ≥ 2`, any `j ≥ 1`, and any
> even `m ≥ 2`, the coefficients `λ_{sym^j f}(n)` change sign infinitely often as `n`
> ranges over integers representable as a sum of `m` squares.

The paper this mission extends proves the statement for `2 ≤ m ≤ 12`.  The key structural
observation isolated here — and the reason the result holds for *all* even `m ≥ 2` — is that
the constraint "`n` is a sum of `m` squares" is **vacuous** as soon as `m ≥ 4`: by Lagrange's
four-square theorem every natural number is already a sum of four squares, and padding with
zeros makes it a sum of `m` squares for every `m ≥ 4`.  Consequently the restricted
sign-change problem collapses onto the *unrestricted* sign-change problem for `m ≥ 4`, and no
new analytic input is needed beyond the (known) unrestricted oscillation.

## Main definitions and results

* `IsSumOfMSquares m n` — `n` is a sum of `m` squares.
* `all_sum_of_m_squares` — for `m ≥ 4` every `n` is a sum of `m` squares (Lagrange + padding).
* `sumOfMSquares_eq_univ` — for `m ≥ 4` the representable set is all of `ℕ`.
* `sumOfMSquares_set_infinite` — for `m ≥ 1` the representable set is infinite (contains
  every square).
* `SignOscillating a` — the abstract hypothesis that `a` takes positive and negative values
  infinitely often (the known analytic input for `λ_{sym^j f}`).
* `signChanges_ge_four` — the collapse theorem: an oscillating sequence changes sign
  infinitely often over the sums of `m` squares for every `m ≥ 4`.
* `altSign_oscillating` — a concrete non-vacuous witness of `SignOscillating`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the extension of the sign-change theorem from the finite window
`2 ≤ m ≤ 12` to *all* even `m ≥ 2` should not require any new analytic machinery, because for
large `m` the representability constraint ought to become non-binding.  Bold form: "for every
`m ≥ 4` the set of sums of `m` squares is all of `ℕ`, so the restricted problem is literally
the unrestricted one."

Experiment (Experimenter): formalised `IsSumOfMSquares` via length-`m` lists of naturals and
proved `all_sum_of_m_squares` by invoking `Nat.sum_four_squares` and padding with
`List.replicate (m-4) 0`.  The padding computation (`List.map_replicate`, `List.sum` of a
constant-`0` list) plus `omega` discharges both the length and the value obligations.

Analysis (Analyst): the collapse is exact — `sumOfMSquares_eq_univ` turns the set-builder
`{n | IsSumOfMSquares m n ∧ P n}` into `{n | P n}` for `m ≥ 4`, so infinitude transfers
verbatim.  The genuinely restrictive regime is `m ≤ 3`; `m = 2` is handled separately in
`Main.lean` where the density-zero nature of two-square sums is visible (it misses the residue
class `3 mod 4`).  This cleanly separates "combinatorial collapse" (proved here) from
"analytic oscillation" (a hypothesis representing the known theorem).

Critique (Critic): is `signChanges_ge_four` vacuous?  No — `altSign_oscillating` exhibits a
concrete sequence satisfying `SignOscillating`, so the hypothesis is inhabited and the
conclusion is a genuine infinitude statement, not an empty implication.  Is it trivial `simp`?
No — the proof rewrites along a set equality justified by the four-square theorem, which is the
mathematical content.

Synthesis (PI): the file exports a reusable oscillation-collapse interface consumed by
`Main.lean`, where it is combined with the two-square boundary case to cover all even `m ≥ 2`.
-/

open scoped BigOperators

namespace SymPowSignChanges

/-- `n : ℕ` is a sum of `m` squares: there is a length-`m` list of naturals whose squares
sum to `n`. -/
def IsSumOfMSquares (m n : ℕ) : Prop :=
  ∃ l : List ℕ, l.length = m ∧ (l.map (· ^ 2)).sum = n

/-- **Lagrange + padding.** For `m ≥ 4`, *every* natural number is a sum of `m` squares. -/
theorem all_sum_of_m_squares (m n : ℕ) (hm : 4 ≤ m) : IsSumOfMSquares m n := by
  obtain ⟨a, b, c, d, habcd⟩ := Nat.sum_four_squares n
  refine ⟨[a, b, c, d] ++ List.replicate (m - 4) 0, ?_, ?_⟩
  · simp [List.length_replicate]; omega
  · simp [List.map_replicate]; omega

/-- For `m ≥ 4` the set of sums of `m` squares is all of `ℕ`: the constraint is vacuous. -/
theorem sumOfMSquares_eq_univ {m : ℕ} (hm : 4 ≤ m) :
    {n | IsSumOfMSquares m n} = Set.univ := by
  ext n; simp [all_sum_of_m_squares m n hm]

/-- Every perfect square is a sum of `m` squares whenever `m ≥ 1` (one term `k`, rest `0`). -/
theorem square_isSumOfMSquares {m : ℕ} (hm : 1 ≤ m) (k : ℕ) :
    IsSumOfMSquares m (k ^ 2) := by
  refine ⟨[k] ++ List.replicate (m - 1) 0, ?_, ?_⟩
  · simp [List.length_replicate]; omega
  · simp [List.map_replicate]

/-- For any `m ≥ 1` the set of sums of `m` squares is infinite (it contains every square). -/
theorem sumOfMSquares_set_infinite {m : ℕ} (hm : 1 ≤ m) :
    {n | IsSumOfMSquares m n}.Infinite := by
  refine Set.infinite_of_injective_forall_mem (f := fun k => k ^ 2) ?_ ?_
  · intro x y h
    have : x ^ 2 = y ^ 2 := h
    nlinarith [Nat.le_total x y]
  · intro k; exact square_isSumOfMSquares hm k

/-- The abstract analytic input.  A real sequence `a` is *sign oscillating* when it is positive
infinitely often and negative infinitely often.  For `a = λ_{sym^j f}` this is the known
theorem on sign changes of symmetric-power Hecke coefficients over all of `ℕ`. -/
structure SignOscillating (a : ℕ → ℝ) : Prop where
  /-- `a` is positive on an infinite set of indices. -/
  pos_infinite : {n | 0 < a n}.Infinite
  /-- `a` is negative on an infinite set of indices. -/
  neg_infinite : {n | a n < 0}.Infinite

/-- **The collapse theorem.** If `a` oscillates in sign over `ℕ`, then for every `m ≥ 4` it
oscillates in sign over the sums of `m` squares: both the positive and the negative
sub-collections indexed by sums of `m` squares are infinite.  The proof uses that the
representability constraint is vacuous for `m ≥ 4` (`all_sum_of_m_squares`). -/
theorem signChanges_ge_four
    {a : ℕ → ℝ} (h : SignOscillating a) {m : ℕ} (hm : 4 ≤ m) :
    {n | IsSumOfMSquares m n ∧ 0 < a n}.Infinite ∧
    {n | IsSumOfMSquares m n ∧ a n < 0}.Infinite := by
  have huniv : ∀ n, IsSumOfMSquares m n := fun n => all_sum_of_m_squares m n hm
  refine ⟨?_, ?_⟩
  · have hset : {n | IsSumOfMSquares m n ∧ 0 < a n} = {n | 0 < a n} := by
      ext n; simp [huniv n]
    rw [hset]; exact h.pos_infinite
  · have hset : {n | IsSumOfMSquares m n ∧ a n < 0} = {n | a n < 0} := by
      ext n; simp [huniv n]
    rw [hset]; exact h.neg_infinite

/-- A concrete non-vacuous witness: the alternating sign sequence `n ↦ (-1)^n`. -/
def altSign : ℕ → ℝ := fun n => if Even n then 1 else -1

/-- The alternating sign sequence genuinely oscillates: it is `+1` on the (infinite) evens and
`-1` on the (infinite) odds. -/
theorem altSign_oscillating : SignOscillating altSign := by
  constructor
  · refine Set.infinite_of_injective_forall_mem (f := fun k => 2 * k) ?_ ?_
    · intro x y h; have : 2 * x = 2 * y := h; omega
    · intro k
      have he : Even (2 * k) := ⟨k, by ring⟩
      show 0 < altSign (2 * k)
      simp [altSign, he]
  · refine Set.infinite_of_injective_forall_mem (f := fun k => 2 * k + 1) ?_ ?_
    · intro x y h; have : 2 * x + 1 = 2 * y + 1 := h; omega
    · intro k
      have ho : ¬ Even (2 * k + 1) := by simp [parity_simps]
      show altSign (2 * k + 1) < 0
      simp [altSign, ho]

/-- The collapse theorem is inhabited: `altSign` changes sign infinitely often over the sums of
`8` squares (and, by the same argument, over sums of any `m ≥ 4` squares). -/
theorem altSign_signChanges_eight :
    {n | IsSumOfMSquares 8 n ∧ 0 < altSign n}.Infinite ∧
    {n | IsSumOfMSquares 8 n ∧ altSign n < 0}.Infinite :=
  signChanges_ge_four altSign_oscillating (by norm_num)

end SymPowSignChanges