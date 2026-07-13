import Mathlib

/-!
# Maximal determinants of `4 × 4` integer matrices with bounded entries

This file studies the classical extremal quantity

  `D(c) := max { det M : M ∈ Matrix (Fin 4) (Fin 4) ℤ, |M i j| ≤ c }`,

the order-`4` instance of **Hadamard's maximal determinant problem** (see the
attached references on Hadamard's maximal determinant problem, the Ehlich–Wojtas
bounds for ternary matrices, and computer-algebra results on small unimodular
matrices).

## The exact answer for order four

For entries bounded in absolute value by `c ≥ 0`, the sharp value is

  `D(c) = 16 · c⁴`,

attained by `c` times a `4 × 4` Hadamard matrix.  The lower bound `16 c⁴ ≤ D(c)`
(achievability) and a clean general upper bound `|det M| ≤ 24 c⁴` are both proved
here from first principles; the two together already pin `D(c)` to the interval
`[16 c⁴, 24 c⁴]`, and the achievability construction shows the left endpoint is
attained.  (The matching sharp upper bound `|det M| ≤ 16 c⁴`, i.e. Hadamard's
inequality specialised to order four, is recorded as a future direction.)

## A correction to a circulating claim

A frequently stated guess is that, writing `c = 2k − 1`, the maximum equals
`(2k−1)⁴ − 2(2k−1)² + 1 = (c² − 1)²`.  This is **false**: already for `k = 1`
(`c = 1`, ternary entries `{−1,0,1}`) the guess evaluates to `0`, whereas the
order-four Hadamard matrix has determinant `16`.  The theorem
`mission_claim_refuted` exhibits, for every `k ≥ 1`, an explicit admissible
matrix whose determinant strictly exceeds `(c² − 1)²`, so the guessed formula is
not even an upper bound.

## Main results

* `det_fin_four` — the explicit Laplace expansion of a `4 × 4` determinant
  (Mathlib only ships `det_fin_three` at this version).
* `det_hadamard4` — the base Hadamard matrix has determinant `16`.
* `det_scaledHadamard` — the scaled construction `c • H` has determinant `16 c⁴`.
* `entries_scaledHadamard_le` — its entries are bounded by `c`.
* `abs_det_le_leibniz` — the Leibniz/permanent bound `|det M| ≤ 24 c⁴`.
* `claimed_lt_achievable` — the arithmetic gap `(c² − 1)² < 16 c⁴` for `c ≥ 1`.
* `mission_claim_refuted` — the circulating maximum formula is refuted.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the order-four maximal determinant with entries
bounded by `c` is a monic degree-four monomial `A · c⁴`; candidate constants were
`(c²−1)²/c⁴` (the circulating guess), `16` (Hadamard) and `24` (Leibniz).

Experiment (Experimenter): direct evaluation of the Hadamard matrix gives
`det = 16` at `c = 1`, immediately killing the `(c²−1)²` guess (`= 0`).  Scaling
by `c` multiplies each of the four rows by `c`, hence the determinant by `c⁴`,
giving the achievable value `16 c⁴`.  Mathlib's `Matrix.det_le` supplies the
Leibniz bound `|det| ≤ 4! · c⁴ = 24 c⁴`.

Analysis (Analyst): the truth is `16 c⁴`; the guess failed because it confused
the *unimodular-lattice covolume* normalisation (where determinants are compared
to `1`) with the *bounded-entry* normalisation.  The surviving structural pattern
is separability: every bound factors as `constant · c⁴`, so the whole problem
reduces to the constant, i.e. to the `c = 1` sign-matrix problem.

Critique (Critic): none of the theorems is vacuous — `det_scaledHadamard` is a
genuine degree-four polynomial identity, `abs_det_le_leibniz` invokes a real
Mathlib inequality, and `mission_claim_refuted` produces an explicit witness.
The one honest gap is the *sharp* constant `16` in the upper bound, which needs
Hadamard's inequality for the Gram matrix; it is quarantined to FUTURE_DIRECTIONS
rather than asserted.

Synthesis (PI): `16 c⁴ ≤ D(c) ≤ 24 c⁴`, achievability is by the scaled Hadamard
matrix, and the circulating `(c²−1)²` formula is refuted for all `k ≥ 1`.
-- !-- Lab Notes -- !--
-/

open scoped Matrix
open Matrix Finset

namespace MaxDet4x4

/-- Explicit Laplace (cofactor) expansion of a `4 × 4` determinant along the
first row.  Mathlib provides `det_fin_three` but not `det_fin_four` at this
version, so we establish it here for reuse. -/
theorem det_fin_four {R : Type*} [CommRing R] (A : Matrix (Fin 4) (Fin 4) R) :
    det A =
      A 0 0 * (A 1 1 * (A 2 2 * A 3 3 - A 2 3 * A 3 2) - A 1 2 * (A 2 1 * A 3 3 - A 2 3 * A 3 1) + A 1 3 * (A 2 1 * A 3 2 - A 2 2 * A 3 1))
      - A 0 1 * (A 1 0 * (A 2 2 * A 3 3 - A 2 3 * A 3 2) - A 1 2 * (A 2 0 * A 3 3 - A 2 3 * A 3 0) + A 1 3 * (A 2 0 * A 3 2 - A 2 2 * A 3 0))
      + A 0 2 * (A 1 0 * (A 2 1 * A 3 3 - A 2 3 * A 3 1) - A 1 1 * (A 2 0 * A 3 3 - A 2 3 * A 3 0) + A 1 3 * (A 2 0 * A 3 1 - A 2 1 * A 3 0))
      - A 0 3 * (A 1 0 * (A 2 1 * A 3 2 - A 2 2 * A 3 1) - A 1 1 * (A 2 0 * A 3 2 - A 2 2 * A 3 0) + A 1 2 * (A 2 0 * A 3 1 - A 2 1 * A 3 0)) := by
  simp only [det_succ_row_zero, submatrix_apply, Fin.succ_zero_eq_one, submatrix_submatrix,
    det_unique, Fin.default_eq_zero, Function.comp_apply, Fin.succ_one_eq_two, Fin.sum_univ_succ,
    Fin.val_zero, Fin.zero_succAbove, univ_unique, Fin.val_succ, Fin.val_eq_zero,
    Fin.succ_succAbove_zero, sum_singleton, Fin.succ_succAbove_one,
    show (Fin.succ (2 : Fin 3)) = (3 : Fin 4) from rfl,
    show ((1 : Fin 4).succAbove (2 : Fin 3)) = (3 : Fin 4) from rfl,
    show ((2 : Fin 4).succAbove (2 : Fin 3)) = (3 : Fin 4) from rfl,
    show ((3 : Fin 4).succAbove (2 : Fin 3)) = (2 : Fin 4) from rfl]
  ring

/-- A `4 × 4` Hadamard matrix (rows pairwise orthogonal, all entries `±1`). -/
def hadamard4 : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 1, 1, 1; 1, -1, 1, -1; 1, 1, -1, -1; 1, -1, -1, 1]

/-- The base Hadamard matrix attains the order-four sign-matrix maximum `16`. -/
theorem det_hadamard4 : hadamard4.det = 16 := by
  rw [det_fin_four]; simp [hadamard4]

/-- The scaled construction `c • H`, an admissible matrix with entries bounded by `c`. -/
def scaledHadamard (c : ℤ) : Matrix (Fin 4) (Fin 4) ℤ := c • hadamard4

/-- **Achievability.** The scaled Hadamard matrix has determinant `16 c⁴`.
This is a genuine degree-four polynomial identity in `c`. -/
theorem det_scaledHadamard (c : ℤ) : (scaledHadamard c).det = 16 * c ^ 4 := by
  rw [scaledHadamard, det_fin_four]
  simp [hadamard4]
  ring

/-- The entries of the scaled Hadamard matrix are bounded by `c` (for `c ≥ 0`). -/
theorem entries_scaledHadamard_le (c : ℤ) (hc : 0 ≤ c) (i j : Fin 4) :
    |scaledHadamard c i j| ≤ c := by
  fin_cases i <;> fin_cases j <;> simp [scaledHadamard, hadamard4, abs_of_nonneg hc]

/-- **General upper bound (Leibniz / permanent bound).** For every `4 × 4`
integer matrix whose entries are bounded by `c`, the determinant satisfies
`|det M| ≤ 24 c⁴` (`24 = 4!`). -/
theorem abs_det_le_leibniz (c : ℤ) (M : Matrix (Fin 4) (Fin 4) ℤ)
    (h : ∀ i j, |M i j| ≤ c) : |M.det| ≤ 24 * c ^ 4 := by
  have hle := Matrix.det_le (A := M) (abv := AbsoluteValue.abs) (x := c) h
  simp only [Fintype.card_fin] at hle
  norm_num at hle
  convert hle using 2

/-- The circulating guess `(c² − 1)²` is strictly below the achievable value
`16 c⁴` whenever `c ≥ 1`. -/
theorem claimed_lt_achievable (c : ℤ) (hc : 1 ≤ c) : (c ^ 2 - 1) ^ 2 < 16 * c ^ 4 := by
  nlinarith [sq_nonneg c, sq_nonneg (c ^ 2 - 1)]

/-- **Refutation of the circulating maximum formula.**  For every `k ≥ 1`,
setting `c = 2k − 1`, there is an admissible `4 × 4` matrix (entries bounded by
`c`) whose determinant strictly exceeds the guessed value
`(2k−1)⁴ − 2(2k−1)² + 1 = (c² − 1)²`.  Hence that value is not even an upper
bound on the determinant, let alone the maximum. -/
theorem mission_claim_refuted (k : ℤ) (hk : 1 ≤ k) :
    ∃ M : Matrix (Fin 4) (Fin 4) ℤ,
      (∀ i j, |M i j| ≤ 2 * k - 1) ∧
      ((2 * k - 1) ^ 4 - 2 * (2 * k - 1) ^ 2 + 1) < M.det := by
  have hc : (1 : ℤ) ≤ 2 * k - 1 := by linarith
  refine ⟨scaledHadamard (2 * k - 1), ?_, ?_⟩
  · intro i j
    exact entries_scaledHadamard_le (2 * k - 1) (by linarith) i j
  · rw [det_scaledHadamard]
    have := claimed_lt_achievable (2 * k - 1) hc
    nlinarith [this]

/-
**A `2³` divisibility law for order-four sign matrices.**  If every entry of
`M` is `±1`, then `8 ∣ det M`.  This is the order-four case of the classical fact
that the determinant of an `n × n` `±1` matrix is divisible by `2^{n-1}`
(subtract the first row from the others: the resulting three rows have even
entries, contributing a factor `2³ = 8` by multilinearity of the determinant).
It underlies the Hadamard/Ehlich–Wojtas congruence restrictions on maximal
determinants.
-/
theorem eight_dvd_det_sign (M : Matrix (Fin 4) (Fin 4) ℤ)
    (h : ∀ i j, M i j = 1 ∨ M i j = -1) : (8 : ℤ) ∣ M.det := by
  -- Every entry of M is ±1. Subtract row 0 from rows 1, 2, 3.
  let N : Matrix (Fin 4) (Fin 4) ℤ := Matrix.of (fun i j => if i = 0 then M 0 j else M i j - M 0 j);
  -- By multilinearity of the determinant, we can factor out the common factor of 2 from each of the three rows.
  have h_factor : ∃ N' : Matrix (Fin 4) (Fin 4) ℤ, N = Matrix.of (fun i j => if i = 0 then M 0 j else 2 * N' i j) := by
    use fun i j => if i = 0 then M 0 j else (M i j - M 0 j) / 2;
    grind;
  -- By multilinearity of the determinant, we can factor out the common factor of 2 from each of the three rows, yielding $8 \cdot \det(N')$.
  obtain ⟨N', hN'⟩ := h_factor;
  have h_det_N : Matrix.det N = 8 * Matrix.det (Matrix.of (fun i j => if i = 0 then M 0 j else N' i j)) := by
    rw [ hN' ];
    simp +decide [ Matrix.det_succ_row_zero, Fin.sum_univ_succ ];
    ring!;
  grind +suggestions

end MaxDet4x4