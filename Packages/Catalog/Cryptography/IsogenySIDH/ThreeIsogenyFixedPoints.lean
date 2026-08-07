/-
# Fixed points of a 3-isogeny step on the `j`-line

`RadicalWalkStructure.lean` classified the `j`-invariants that a *2*-isogeny
step can fix, by factoring the diagonal of the level-2 modular polynomial:
`Φ₂(j,j) = -(j-8000)(j+3375)²(j-1728)`.  The level-3 side, developed in
`ThreeIsogenyMontgomery.lean`, supplied the explicit Costello–Hisil 3-isogeny
and the certificate `Φ₃(j(E_A), j(E_{A'})) = 0`, but left the corresponding
question open:

> can a 3-isogeny step of the Montgomery family return to the same
> `j`-invariant?

This file answers it completely.

* `modPoly3_diagonal_factor` — the diagonal of `Φ₃` factors as
  `Φ₃(j,j) = -j (j-8000)² (j-54000) (j+32768)²`,
  a polynomial identity of degree six.  The four roots are exactly the CM
  `j`-invariants of discriminants `-3`, `-8`, `-12` and `-11`, i.e. the
  `j`-invariants of the curves carrying an endomorphism of norm three.
* `three_isogeny_fixed_point_classification` — consequently a 3-isogeny step can
  fix a `j`-invariant only at `j ∈ {0, 8000, 54000, -32768}`.
* `modPoly3_diagonal_roots` — all four values really are zeroes of `Φ₃(j,j)`, so
  the list cannot be shortened on the level of the modular polynomial.
* `three_isogeny_step_moves` — the geometric consequence for the Montgomery
  family: away from those four values, the Costello–Hisil 3-isogeny genuinely
  changes the `j`-invariant.
* `three_isogeny_diagonal_card_le_four` — over any field at most four
  `j`-invariants can be fixed.

Together with `RadicalNonBacktracking.lean` and
`BacktrackingCharacteristic.lean` this completes the picture of *stationary*
behaviour for both levels handled in this thread: level 2 fixes at most the
three CM values `{1728, 8000, -3375}`, level 3 at most the four CM values
`{0, 8000, 54000, -32768}`, and the only value common to both lists is `8000`
(discriminant `-8`).
-/
import Cryptography.IsogenySIDH.ThreeIsogenyMontgomery

set_option maxHeartbeats 1000000

namespace Cryptography.IsogenySIDH

open Polynomial

variable {K : Type*} [Field K]

/-! ## The diagonal of the level-three modular polynomial -/

/-- **Diagonal factorisation of `Φ₃`.**  The degree-six polynomial `Φ₃(j,j)`
factors completely over `ℚ`:
`Φ₃(j,j) = -j (j-8000)² (j-54000) (j+32768)²`.
Its roots are the CM `j`-invariants of discriminants `-3`, `-8`, `-12`, `-11`,
which are precisely the `j`-invariants admitting an endomorphism of norm
three. -/
theorem modPoly3_diagonal_factor (j : K) :
    modPoly3 j j = -(j * (j - 8000) ^ 2 * (j - 54000) * (j + 32768) ^ 2) := by
  simp only [modPoly3]; ring

/-- All four candidate values are genuine zeroes of the diagonal, so the
classification below is sharp at the level of the modular polynomial. -/
theorem modPoly3_diagonal_roots :
    modPoly3 (0 : K) 0 = 0 ∧ modPoly3 (8000 : K) 8000 = 0 ∧
      modPoly3 (54000 : K) 54000 = 0 ∧ modPoly3 (-32768 : K) (-32768) = 0 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;>
    · rw [modPoly3_diagonal_factor]; ring

/-! ## Classification of the fixed `j`-invariants -/

/-- **Classification of 3-isogeny fixed points.**  A zero of the diagonal of the
level-three modular polynomial is one of the four CM values `0`, `8000`,
`54000`, `-32768`. -/
theorem three_isogeny_fixed_point_classification {j : K} (h : modPoly3 j j = 0) :
    j = 0 ∨ j = 8000 ∨ j = 54000 ∨ j = -32768 := by
  rw [modPoly3_diagonal_factor, neg_eq_zero] at h
  rcases mul_eq_zero.mp h with h1 | h1
  · rcases mul_eq_zero.mp h1 with h2 | h2
    · rcases mul_eq_zero.mp h2 with h3 | h3
      · exact Or.inl h3
      · exact Or.inr (Or.inl (sub_eq_zero.mp (pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h3)))
    · exact Or.inr (Or.inr (Or.inl (sub_eq_zero.mp h2)))
  · have := pow_eq_zero_iff (n := 2) (by norm_num) |>.mp h1
    exact Or.inr (Or.inr (Or.inr (by linear_combination this)))

/-- **A 3-isogeny step moves the `j`-invariant.**  If `r` is the abscissa of a
point of order three on the Montgomery curve `E_A`, the degenerate loci are
avoided, and `j(E_A)` is none of the four CM values `0`, `8000`, `54000`,
`-32768`, then the Costello–Hisil 3-isogeny lands on a *different*
`j`-invariant.  This is the level-3 counterpart of `radical_step_moves`. -/
theorem three_isogeny_step_moves {A r : K} (htwo : (2 : K) ≠ 0)
    (hpsi : threeDivPoly A r = 0) (h1 : r ^ 2 - 1 ≠ 0) (h9 : 9 * r ^ 2 - 1 ≠ 0)
    (hj0 : jMont A ≠ 0) (hj1 : jMont A ≠ 8000) (hj2 : jMont A ≠ 54000)
    (hj3 : jMont A ≠ -32768) :
    jMont (threeIsoParam A r) ≠ jMont A := by
  intro hfix
  have hdiag : modPoly3 (jMont A) (jMont A) = 0 := by
    have := modPoly3_three_isogeny htwo hpsi h1 h9
    rwa [hfix] at this
  rcases three_isogeny_fixed_point_classification hdiag with h | h | h | h
  · exact hj0 h
  · exact hj1 h
  · exact hj2 h
  · exact hj3 h

/-! ## A counting bound for the diagonal -/

/-- The diagonal of `Φ₃` as an honest univariate polynomial of degree six. -/
noncomputable def modPoly3Diag : K[X] :=
  C (-1) * X ^ 6 + C 4464 * X ^ 5 + C 2585778176 * X ^ 4 + C 17800519680000 * X ^ 3
    + C (-769939996672000000) * X ^ 2 + C 3710851743744000000000 * X

theorem modPoly3Diag_eval (j : K) : (modPoly3Diag).eval j = modPoly3 j j := by
  simp only [modPoly3Diag, modPoly3, eval_add, eval_mul, eval_pow, eval_C, eval_X]
  ring

theorem modPoly3Diag_natDegree : (modPoly3Diag (K := K)).natDegree = 6 := by
  unfold modPoly3Diag
  compute_degree
  all_goals first | omega | exact neg_ne_zero.mpr one_ne_zero

theorem modPoly3Diag_ne_zero : (modPoly3Diag (K := K)) ≠ 0 := by
  intro h
  have hdeg := modPoly3Diag_natDegree (K := K)
  rw [h] at hdeg
  simp at hdeg

/-- **At most four fixed `j`-invariants, over any field.**  Even in
characteristics where the four CM values collide or where extra roots could a
priori appear, the diagonal of `Φ₃` is a nonzero polynomial of degree six whose
root set has at most four distinct elements by the factorisation
`modPoly3_diagonal_factor`. -/
theorem three_isogeny_diagonal_card_le_four [DecidableEq K] (S : Finset K) (hS : ∀ j ∈ S, modPoly3 j j = 0) : S.card ≤ 4 := by
  have hsub : S ⊆ ({0, 8000, 54000, -32768} : Finset K) := by
    intro j hj
    rcases three_isogeny_fixed_point_classification (hS j hj) with h | h | h | h <;> simp [h]
  have hc : ({0, 8000, 54000, -32768} : Finset K).card ≤ 4 := by
    have h1 : ({-32768} : Finset K).card = 1 := Finset.card_singleton _
    have h2 := Finset.card_insert_le (54000 : K) ({-32768} : Finset K)
    have h3 := Finset.card_insert_le (8000 : K) ({54000, -32768} : Finset K)
    have h4 := Finset.card_insert_le (0 : K) ({8000, 54000, -32768} : Finset K)
    simp only [Finset.insert_eq] at *
    omega
  exact (Finset.card_le_card hsub).trans hc

/-! ## Comparison of the two levels -/

/-- **The two stationary sets meet only at `j = 8000`.**  In characteristic zero
a `j`-invariant fixed by both a 2-isogeny step and a 3-isogeny step must be
`8000`, the CM `j`-invariant of discriminant `-8` — the unique discriminant in
this thread whose order contains an endomorphism of norm two *and* one of norm
three. -/
theorem two_and_three_fixed_point_meet [CharZero K] {j : K}
    (hj2 : modPoly2 j j = 0) (hj3 : modPoly3 j j = 0) : j = 8000 := by
  rcases three_isogeny_fixed_point_classification hj3 with e3 | e3 | e3 | e3
  · exfalso
    rw [e3, modPoly2_diagonal_factor] at hj2
    norm_num at hj2
  · exact e3
  · exfalso
    rw [e3, modPoly2_diagonal_factor] at hj2
    norm_num at hj2
  · exfalso
    rw [e3, modPoly2_diagonal_factor] at hj2
    norm_num at hj2

end Cryptography.IsogenySIDH