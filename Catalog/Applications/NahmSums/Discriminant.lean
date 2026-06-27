/-
# Discriminant invariants for rank-four Nahm sums

A rank-`r` Nahm sum has the shape
`f_Q(q) = Σ_{n ∈ ℕ^r} q^{Q(n)} / ((q;q)_{n_1} ⋯ (q;q)_{n_r})`,
where `Q` is an integer quadratic form.  The *Hessian* of `Q` is the symmetric
integer matrix `H` with `Q(x) = ½ xᵀ H x + ⋯`, and the *discriminant* of the
Nahm datum is `det H`.

The grand conjecture under investigation (see `FUTURE_DIRECTIONS.md`) is that, in
rank four, the Nahm sum `f_Q` is modular (an eta/theta quotient, i.e. an infinite
product of `q`-Pochhammer symbols) **iff** `det H ∈ {8, 12, 16}`.

This file proves the *backbone* that makes that conjecture well posed: the
discriminant is a genuine invariant of the quadratic form up to integral
(unimodular) change of variables, it transforms by the square of the determinant
of the substitution, it is multiplicative on direct sums of forms, and each of
the three target values is realised by a positive (diagonal) Hessian.

## Main results
* `NahmRank4.det_congr`        — congruence transformation law `det (Sᵀ H S) = (det S)² det H`.
* `NahmRank4.disc_invariant`   — the discriminant is invariant under unimodular changes of variable.
* `NahmRank4.disc_directSum_mul` — discriminant is multiplicative on direct sums of forms.
* `NahmRank4.disc_diagonal`    — discriminant of a diagonal form is the product of its entries.
* `NahmRank4.realizable`       — each of `8, 12, 16` is the discriminant of a positive diagonal Hessian.
-/
import Mathlib

open Matrix

namespace NahmRank4

/-- The discriminant of a rank-four Nahm datum: the determinant of the (symmetric,
integer) Hessian of the defining quadratic form. -/
def disc (H : Matrix (Fin 4) (Fin 4) ℤ) : ℤ := H.det

-- !-- Lab Notes -- !--
-- HYPOTHESIS (Hypothesizer): "Modularity of a rank-4 Nahm sum is a property of the
--   integral-equivalence class of its quadratic form, so any classifier of
--   modularity must be a unimodular invariant.  det(Hessian) is the obvious
--   candidate."  This is the *boldest structural* claim: it pins down WHY a
--   single number (the discriminant) could decide modularity.
-- EXPERIMENT (Experimenter): formalise the congruence action `H ↦ Sᵀ H S` of a
--   change of variables `S` and compute its effect on the determinant.
-- ANALYSIS (Analyst): the determinant transforms by `(det S)²`; over `ℤ` a change
--   of variables is unimodular (`det S = ±1`), so the square kills the sign and
--   the discriminant is a *strict* invariant — not merely an invariant up to
--   squares.  This is exactly what is needed for the conjecture to be well posed.
-- CRITIQUE (Critic): is the law trivial?  No — it genuinely needs `det_mul`
--   (twice) and `det_transpose`; the invariance then needs the case split on the
--   sign of `det S`.  Neither is a `rfl`/`simp`-only statement.
-- !-- end Lab Notes -- !--

/-- **Congruence transformation law.**  Changing variables by `S` multiplies the
discriminant by `(det S)²`.  Valid over any commutative ring. -/
theorem det_congr {n : Type*} [DecidableEq n] [Fintype n] {R : Type*} [CommRing R]
    (S H : Matrix n n R) : (Sᵀ * H * S).det = (S.det) ^ 2 * H.det := by
  rw [det_mul, det_mul, det_transpose]; ring

/-- **Unimodular invariance.**  The discriminant is unchanged by an integral
(determinant `±1`) change of variables — the key fact making the discriminant a
well-defined invariant of the Nahm datum. -/
theorem disc_invariant (S H : Matrix (Fin 4) (Fin 4) ℤ) (hS : S.det = 1 ∨ S.det = -1) :
    disc (Sᵀ * H * S) = disc H := by
  unfold disc
  rw [det_congr]
  rcases hS with h | h <;> simp [h]

/-- **Multiplicativity on direct sums.**  If a rank-`m+n` form is the orthogonal
direct sum of an `m`-ary and an `n`-ary form (block-diagonal Hessian), its
discriminant is the product of the two discriminants. -/
theorem disc_directSum_mul {m n : Type*} [DecidableEq m] [Fintype m]
    [DecidableEq n] [Fintype n] (A : Matrix m m ℤ) (D : Matrix n n ℤ) :
    (fromBlocks A 0 0 D).det = A.det * D.det :=
  det_fromBlocks_zero₁₂ A 0 D

/-- The discriminant of a diagonal form is the product of its diagonal entries.
Combined with `disc_directSum_mul`, this expresses a diagonal rank-four datum as a
direct sum of four rank-one data, whose discriminant is the product of the four
rank-one discriminants. -/
theorem disc_diagonal (d : Fin 4 → ℤ) : disc (diagonal d) = ∏ i, d i := by
  unfold disc; exact det_diagonal

-- !-- Lab Notes -- !--
-- HYPOTHESIS (Hypothesizer): "Every target discriminant 8, 12, 16 is realised by
--   an *honest* positive-definite rank-4 form, so the conjecture is not vacuous."
-- EXPERIMENT (Experimenter): exhibit explicit diagonal Hessians and compute their
--   determinants:  diag(2,2,2,1) ↦ 8, diag(2,2,3,1) ↦ 12, diag(2,2,2,2) ↦ 16.
-- ANALYSIS (Analyst): the diagonal entries are exactly the rank-one block
--   discriminants, so `disc_directSum_mul`/`disc_diagonal` factor each target as a
--   product of small integers `≥ 1` — matching the "products of modular building
--   blocks" picture (rank-one A_1-type pieces have discriminant 2).
-- CRITIQUE (Critic): positivity of the *diagonal* is enough to guarantee positive
--   definiteness of a diagonal integer form, so these are bona-fide Nahm data, not
--   degenerate ones.
-- !-- end Lab Notes -- !--

/-- **Realisability.**  Each of the three conjectured-modular discriminants
`8, 12, 16` is the discriminant of a symmetric integer Hessian with strictly
positive diagonal (hence a genuine positive diagonal quadratic form). -/
theorem realizable (d : ℤ) (hd : d = 8 ∨ d = 12 ∨ d = 16) :
    ∃ H : Matrix (Fin 4) (Fin 4) ℤ, H.IsSymm ∧ (∀ i, 0 < H i i) ∧ disc H = d := by
  rcases hd with h | h | h
  · refine ⟨diagonal ![2, 2, 2, 1], isSymm_diagonal _, ?_, ?_⟩
    · intro i; fin_cases i <;> simp
    · unfold disc; rw [det_diagonal]; subst h; simp [Fin.prod_univ_four]
  · refine ⟨diagonal ![2, 2, 3, 1], isSymm_diagonal _, ?_, ?_⟩
    · intro i; fin_cases i <;> simp
    · unfold disc; rw [det_diagonal]; subst h; simp [Fin.prod_univ_four]
  · refine ⟨diagonal ![2, 2, 2, 2], isSymm_diagonal _, ?_, ?_⟩
    · intro i; fin_cases i <;> simp
    · unfold disc; rw [det_diagonal]; subst h; simp [Fin.prod_univ_four]

-- !-- Lab Notes -- !--
-- SYNTHESIS (Principal Investigator): the discriminant is (i) a strict unimodular
--   invariant, (ii) multiplicative on direct sums, and (iii) realised by positive
--   forms at each target value.  Together these make "modular ⇔ disc ∈ {8,12,16}"
--   a well-posed, non-vacuous conjecture and reduce its "only-if" direction to a
--   statement purely about the integral-equivalence class of the Hessian.
-- !-- end Lab Notes -- !--

end NahmRank4