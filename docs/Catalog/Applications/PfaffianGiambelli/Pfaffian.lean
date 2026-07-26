import Mathlib

/-!
# Pfaffians of small skew-symmetric matrices and the Giambelli backbone

This file develops the elementary linear algebra that underlies the **Pfaffian
Giambelli formula** for (shifted, `t`-deformed) Schur `Q`-functions.  The classical
formula expresses a Schur `Q`-function indexed by a strict partition as a *Pfaffian*
of two-row Schur `Q`-functions, and its `t`-deformation (the shifted `t`-Schur
functions of the Greaves–Jing–Zhu construction) has exactly the same shape.

The *algebraic engine* of every such formula is the Pfaffian itself, so here we
isolate and fully prove the structural facts that make the engine run, for the
two smallest non-trivial sizes `k = 1` (a `2 × 2` block) and `k = 2` (a `4 × 4`
block, the first genuinely interesting Pfaffian):

* `Matrix.det_fin_four` — the explicit Laplace expansion of a `4 × 4` determinant
  (not in Mathlib at this version; proved here once and reused);
* `pf2_sq_eq_det`, `pf4_sq_eq_det` — the defining property **`Pf(A)² = det A`** for
  alternating matrices, the identity that pins the Pfaffian down up to sign;
* `pf4_swap12_neg` — the **alternating / sign law**: a transposition of two indices
  flips the sign of the Pfaffian, mirroring the Clifford anticommutation of the
  odd Greaves–Jing–Zhu operators;
* `pf4_giambelli` — the **complementary-minor (Giambelli) expansion** writing the
  `4 × 4` Pfaffian as an alternating sum of products of `2 × 2` Pfaffians; this is
  the `k = 2` instance of the recursive Pfaffian Giambelli formula.

Nothing here is definitional fluff: `pf4_sq_eq_det` is a genuine degree-`4`
polynomial identity in the `12` independent entries, and is what forces the
Pfaffian to be *the* square root of the determinant.

-- !-- Lab Notes -- !--
* Hypothesis (Hypothesizer): for an alternating `2k × 2k` matrix there is a
  polynomial `Pf` with `Pf² = det`, and `Pf` of a `4 × 4` block expands over
  complementary index pairs with signs `+ - +`, exactly like a Schur `Q` Giambelli
  Pfaffian.
* Experiment (Experimenter): defined `pf2`, `pf4` by their matching expansions and
  attacked `Pf² = det`.  The `4 × 4` determinant is not available in Mathlib
  (`det_fin_four` is missing), so we first reduce `det` via `det_succ_row_zero`
  and `det_fin_three`, evaluating the residual `Fin.succAbove` indices by `rfl`,
  then close the polynomial identity by `ring` after substituting the alternating
  relations.
* Analysis (Analyst): `Pf² = det` is *true but hard for `simp` alone* — it needs the
  hand-built `det_fin_four` plus `ring`; this is why the result is non-trivial.
  The sign law `pf4_swap12_neg` needs only skewness (not the zero diagonal), while
  `Pf² = det` needs both, matching the fact that "alternating" is strictly stronger
  than "skew" outside fields of characteristic `≠ 2`.
* Critique (Critic): `pf4_giambelli` is a reorganisation provable by `simp`, so it is
  recorded as a structural corollary, *not* as a headline theorem; the headline
  theorems (`pf2_sq_eq_det`, `pf4_sq_eq_det`, `pf4_swap12_neg`) each use `ring`
  on top of a non-trivial rewrite and hold over an arbitrary commutative ring.
* Synthesis (PI): this file is the reusable Pfaffian core; `ShiftedTSchur.lean`
  feeds it `t`-deformed alternating matrices to obtain the shifted `t`-Schur
  Pfaffian Giambelli statements.
-/

open Matrix Finset

namespace PfaffianGiambelli

variable {R : Type*} [CommRing R]

/-- Pfaffian of a `2 × 2` matrix (the `k = 1` case): the single super-diagonal
entry.  For an alternating matrix this is the unique square root of the
determinant. -/
def pf2 (A : Matrix (Fin 2) (Fin 2) R) : R := A 0 1

/-- Pfaffian of a `4 × 4` matrix (the `k = 2` case): the signed sum over the three
perfect matchings of `{0,1,2,3}`.  This is the first genuinely interesting
Pfaffian and the `k = 2` instance of the Pfaffian Giambelli formula. -/
def pf4 (A : Matrix (Fin 4) (Fin 4) R) : R :=
  A 0 1 * A 2 3 - A 0 2 * A 1 3 + A 0 3 * A 1 2

set_option maxHeartbeats 1000000 in
/-- Explicit Laplace expansion of a `4 × 4` determinant along the first row.
Mathlib provides `det_fin_three` but not `det_fin_four` at this version, so we
prove it here and reuse it for the Pfaffian–determinant identity. -/
theorem _root_.Matrix.det_fin_four (A : Matrix (Fin 4) (Fin 4) R) :
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

/-- **Pfaffian–determinant identity, `k = 1`.** For an alternating `2 × 2` matrix
`A` (skew-symmetric with zero diagonal), `det A = (Pf A)²`. -/
theorem pf2_sq_eq_det (A : Matrix (Fin 2) (Fin 2) R)
    (hskew : ∀ i j, A i j = - A j i) (hdiag : ∀ i, A i i = 0) :
    A.det = (pf2 A) ^ 2 := by
  rw [Matrix.det_fin_two, pf2, hdiag 0, hdiag 1, hskew 1 0]
  ring

/-- **Pfaffian–determinant identity, `k = 2`.** For an alternating `4 × 4` matrix
`A`, `det A = (Pf A)²`.  This is the first genuinely interesting instance of
`Pf² = det` and the algebraic heart of the Pfaffian Giambelli formula: it is what
guarantees that the Pfaffian (not just its square) is a well-defined polynomial. -/
theorem pf4_sq_eq_det (A : Matrix (Fin 4) (Fin 4) R)
    (hskew : ∀ i j, A i j = - A j i) (hdiag : ∀ i, A i i = 0) :
    A.det = (pf4 A) ^ 2 := by
  rw [Matrix.det_fin_four, pf4, hdiag 0, hdiag 1, hdiag 2, hdiag 3,
    hskew 1 0, hskew 2 0, hskew 3 0, hskew 2 1, hskew 3 1, hskew 3 2]
  ring

/-- **Alternating / sign law.** Transposing the two indices `1` and `2`
(simultaneously in rows and columns) flips the sign of the `4 × 4` Pfaffian.  This
is the matrix-level shadow of the Clifford anticommutation `ψ_i ψ_j = - ψ_j ψ_i`
of the odd Greaves–Jing–Zhu operators.  Only skewness is needed. -/
theorem pf4_swap12_neg (A : Matrix (Fin 4) (Fin 4) R)
    (hskew : ∀ i j, A i j = - A j i) :
    pf4 (A.submatrix (Equiv.swap (1 : Fin 4) 2) (Equiv.swap (1 : Fin 4) 2)) = - pf4 A := by
  simp only [pf4, Matrix.submatrix_apply]
  rw [show (Equiv.swap (1 : Fin 4) 2) 0 = 0 from rfl,
      show (Equiv.swap (1 : Fin 4) 2) 1 = 2 from rfl,
      show (Equiv.swap (1 : Fin 4) 2) 2 = 1 from rfl,
      show (Equiv.swap (1 : Fin 4) 2) 3 = 3 from rfl,
      hskew 2 1]
  ring

/-- **Complementary-minor (Giambelli) expansion, `k = 2`.** The `4 × 4` Pfaffian is
the alternating sum, over the three ways to split `{0,1,2,3}` into an ordered pair
of complementary `2`-element index sets, of products of the corresponding `2 × 2`
Pfaffians.  This is the recursive Pfaffian Giambelli formula at `k = 2`. -/
theorem pf4_giambelli (A : Matrix (Fin 4) (Fin 4) R) :
    pf4 A =
      pf2 (A.submatrix ![0, 1] ![0, 1]) * pf2 (A.submatrix ![2, 3] ![2, 3])
      - pf2 (A.submatrix ![0, 2] ![0, 2]) * pf2 (A.submatrix ![1, 3] ![1, 3])
      + pf2 (A.submatrix ![0, 3] ![0, 3]) * pf2 (A.submatrix ![1, 2] ![1, 2]) := by
  simp [pf4, pf2, Matrix.submatrix_apply]

end PfaffianGiambelli