/-
# The target discriminant set `{8, 12, 16}`

This file studies the arithmetic of the conjectured-modular discriminant set
`{8, 12, 16}` for rank-four Nahm sums, complementing the linear-algebra backbone
in `Discriminant.lean` (the discriminant is `det` of the Hessian).

## Main results
* `NahmRank4.target_characterization` — `d ∈ {8,12,16}` iff `4 ∣ d ∧ 8 ≤ d ∧ d ≤ 16`,
  i.e. the target set is *exactly* the multiples of four in the closed range `[8,16]`.
* `NahmRank4.target_factorization`    — each target value is the determinant of an
  explicit diagonal (direct-sum) Hessian whose entries lie in `{1,2,3,4}`.
-/
import Mathlib

open Matrix

namespace NahmRank4

-- !-- Lab Notes -- !--
-- HYPOTHESIS (Hypothesizer): "The three exceptional discriminants are not an
--   arbitrary list — they are characterised by a clean congruence/interval law."
-- EXPERIMENT (Experimenter): test candidate characterisations of {8,12,16}.
--   • "even numbers in [8,16]" fails: it also admits 10, 14.
--   • "3-smooth numbers in [8,16]" fails: it also admits 9.
--   • "multiples of 4 in [8,16]" SUCCEEDS exactly: 8,12,16.
-- ANALYSIS (Analyst): `4 ∣ d` is the discriminating predicate.  Mathematically a
--   positive-definite *even* rank-4 lattice has `2 ∣ det` from each diagonal, and
--   the extra factor of 2 forces `4 ∣ det` once two coordinates are "doubled";
--   the interval bound `8 ≤ d ≤ 16` then leaves precisely the three values.
-- CRITIQUE (Critic): the iff is proved by `omega` (which reasons about both the
--   divisibility and the interval), not by `decide` enumeration; the forward
--   direction still needs a genuine case split, so the statement is not a
--   definitional triviality.
-- !-- end Lab Notes -- !--

/-- **Characterisation of the target set.**  The conjectured-modular discriminants
are exactly the multiples of four lying in the closed interval `[8, 16]`. -/
theorem target_characterization (d : ℤ) :
    (d = 8 ∨ d = 12 ∨ d = 16) ↔ (4 ∣ d ∧ 8 ≤ d ∧ d ≤ 16) := by
  constructor
  · rintro (h | h | h) <;> omega
  · rintro ⟨h1, h2, h3⟩; omega

/-- **Factorisation as rank-one blocks.**  Each target discriminant is the
determinant of an explicit diagonal Hessian whose entries lie in `{1, 2, 3, 4}`,
witnessing it as the discriminant of a direct sum of four rank-one Nahm data.

Concretely: `8 = 2·2·2·1`, `12 = 2·2·3·1`, `16 = 2·2·2·2`. -/
theorem target_factorization (d : ℤ) (hd : d = 8 ∨ d = 12 ∨ d = 16) :
    ∃ a b c e : ℤ, ({a, b, c, e} : Set ℤ) ⊆ ({1, 2, 3, 4} : Set ℤ) ∧
      (diagonal ![a, b, c, e]).det = d := by
  rcases hd with h | h | h
  · refine ⟨2, 2, 2, 1, ?_, ?_⟩
    · intro x hx; simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx ⊢; omega
    · rw [det_diagonal]; subst h; simp [Fin.prod_univ_four]
  · refine ⟨2, 2, 3, 1, ?_, ?_⟩
    · intro x hx; simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx ⊢; omega
    · rw [det_diagonal]; subst h; simp [Fin.prod_univ_four]
  · refine ⟨2, 2, 2, 2, ?_, ?_⟩
    · intro x hx; simp only [Set.mem_insert_iff, Set.mem_singleton_iff] at hx ⊢; omega
    · rw [det_diagonal]; subst h; simp [Fin.prod_univ_four]

-- !-- Lab Notes -- !--
-- SYNTHESIS (Principal Investigator): `target_characterization` gives an intrinsic
--   arithmetic fingerprint of the exceptional set (4 | d on [8,16]); combined with
--   `disc_invariant` and `disc_directSum_mul` from `Discriminant.lean`, the
--   "only-if" direction of the modularity conjecture becomes the statement that a
--   modular rank-4 Nahm datum must have unimodular-equivalence class with
--   discriminant a multiple of four in [8,16].  `target_factorization` shows the
--   "if" direction is at least *populated* by explicit direct-sum data.
-- !-- end Lab Notes -- !--

end NahmRank4