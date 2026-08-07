/-
# The exceptional `j`-invariant `0` is a characteristic phenomenon

`RadicalNonBacktracking.lean` proved that, over a field containing no primitive
cube root of unity, a radical 2-isogeny walk can return to its starting
`j`-invariant after two steps only when

`j ∈ {0, -3375, 287496}`,

and it exhibited backtracking at `-3375` and at `287496`.  The value `0` was
left as a *possible* exception: it enters the classification only through the
degenerate case `btDen A = 0` of the cube-root branch, and the previous cycle's
`FUTURE_DIRECTIONS.md` conjectured (Conjecture 2) that it too is attained.

This file settles that question, and the answer is a **correction** of the
conjecture:

* `btNum_btDen_no_common_root` — the two comparison polynomials
  `btNum A = A² + 60A + 132` and `btDen A = 4(A²-3)(A-2)` have **no common
  root** in any field whose characteristic avoids `2, 3, 5, 11`.  The proof is
  an explicit elimination: a common root forces `A = 2` (excluded, since
  `btNum 2 = 2⁸`) or `A² = 3` together with `15(4A+9) = 0`, whence
  `16·3 = (4A)² = 81`, i.e. `33 = 0`.
* `radical_two_step_nonbacktracking_sharp` — consequently the exceptional set
  shrinks: away from characteristic `2, 3, 5, 11`, and over a field with no
  primitive cube root of unity, two-step backtracking forces
  `j ∈ {-3375, 287496}`.  The value `0` is **not** exceptional.
* `radChain_two_step_nonbacktracking_sharp` — the walk-level version.
* Sharpness in the excluded characteristics: `backtracking_at_zero_char_three`
  and `backtracking_at_sqrt_three_char_five` show that in characteristic `3`
  (at `A = 0`) and in characteristic `5` (at `A² = 3`) backtracking at `j = 0`
  really does occur, so the hypotheses `(3 : K) ≠ 0` and `(5 : K) ≠ 0` cannot be
  dropped; `backtracking_at_six_char_eleven` shows that in characteristic `11`
  the `j = 0` locus `A² = 3` collapses onto the principal branch `A = 6`, which
  is why `11` also has to be excluded from the elimination even though it
  produces no new exceptional value.
* `char_five_backtracking_exists` makes the characteristic-`5` counterexample
  unconditional by producing it over `AlgebraicClosure (ZMod 5)`.

So the final statement of the two-step non-backtracking theorem is: outside of
characteristics `2, 3, 5, 11`, and outside of fields containing a primitive cube
root of unity, **exactly two** `j`-invariants can backtrack, namely the CM
values `-3375` (discriminant `-7`) and `287496` (discriminant `-16`).
-/
import Cryptography.IsogenySIDH.RadicalNonBacktracking

set_option maxHeartbeats 1000000

namespace Cryptography.IsogenySIDH

variable {K : Type*} [Field K]

/-! ## Eliminating the degenerate branch -/

/-- The value of the numerator polynomial at the degenerate parameter `A = 2`
is `2⁸`. -/
theorem btNum_two : btNum (2 : K) = 256 := by
  simp only [btNum]; norm_num

/-- **No common root.**  In a field whose characteristic is none of
`2, 3, 5, 11`, the polynomials `btNum` and `btDen` have no common root.  This is
the degenerate case of the cube-root branch of `backtrackPoly`, so ruling it out
removes `j = 0` from the exceptional set of the non-backtracking theorem. -/
theorem btNum_btDen_no_common_root {A : K} (h2 : (2 : K) ≠ 0) (h3 : (3 : K) ≠ 0)
    (h5 : (5 : K) ≠ 0) (h11 : (11 : K) ≠ 0) (hn : btNum A = 0) (hd : btDen A = 0) :
    False := by
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero h2 h2
  simp only [btDen] at hd
  rcases mul_eq_zero.mp hd with h1 | h1
  · rcases mul_eq_zero.mp h1 with h4 | hsq3
    · exact hfour h4
    -- Case `A² = 3`: then `btNum A = 15 (4A + 9)`.
    · have hA : A ^ 2 = 3 := by linear_combination hsq3
      have h15 : (15 : K) ≠ 0 := by
        have h : (15 : K) = 3 * 5 := by norm_num
        rw [h]; exact mul_ne_zero h3 h5
      have hlin : (15 : K) * (4 * A + 9) = 0 := by
        simp only [btNum] at hn; linear_combination hn - hA
      have h4A : 4 * A + 9 = 0 := by
        rcases mul_eq_zero.mp hlin with h | h
        · exact absurd h h15
        · exact h
      have h33 : (33 : K) = 0 := by
        have : (16 : K) * A ^ 2 = 81 := by
          linear_combination (4 * A - 9) * h4A
        rw [hA] at this
        linear_combination -this
      have : (3 : K) * 11 = 0 := by linear_combination h33
      rcases mul_eq_zero.mp this with h | h
      · exact h3 h
      · exact h11 h
  -- Case `A = 2`: `btNum 2 = 2⁸ ≠ 0`.
  · have hA2 : A = 2 := by linear_combination h1
    subst hA2
    have h256 : (256 : K) ≠ 0 := by
      have h : (256 : K) = 2 ^ 8 := by norm_num
      rw [h]; exact pow_ne_zero 8 h2
    exact h256 (by rw [← btNum_two]; exact hn)

/-! ## The sharpened classification -/

/-- **Sharpened two-step non-backtracking.**  Over a field of characteristic
different from `2, 3, 5, 11` and containing no primitive cube root of unity, a
radical 2-isogeny step can return the walk to its starting `j`-invariant after
two steps only when that `j`-invariant is `-3375` or `287496`.  Compared with
`radical_two_step_nonbacktracking` the value `0` has been removed from the
exceptional set — and by `backtracking_at_sqrt_three_char_five` below, that
removal is exactly as strong as it can be. -/
theorem radical_two_step_nonbacktracking_sharp {A α : K} (h2 : (2 : K) ≠ 0)
    (h3 : (3 : K) ≠ 0) (h5 : (5 : K) ≠ 0) (h11 : (11 : K) ≠ 0)
    (hcube : ∀ t : K, t ^ 2 + t + 1 ≠ 0) (hα : α ≠ 0) (hsq : α ^ 2 = A + 2)
    (hd : A ^ 2 - 4 ≠ 0) (hj1 : jMont A ≠ -3375) (hj2 : jMont A ≠ 287496) :
    jQuot (radTwoParam A α) ≠ jMont A := by
  intro hback
  rcases radical_two_step_backtracking_classification h2 hα hsq hd hback with h | h | h
  · exact hj2 (by rw [h, jMont_six h2])
  · exact hj1 (jMont_eq_neg3375_of_quadratic hd h)
  · by_cases hv : btDen A = 0
    · -- the degenerate branch: `btDen A = 0` forces `btNum A = 0` as well
      have hn : btNum A = 0 := by
        have : btNum A ^ 2 = 0 := by rw [hv] at h; linear_combination h
        exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
      exact btNum_btDen_no_common_root h2 h3 h5 h11 hn hv
    · obtain ⟨t, ht⟩ := cube_root_of_unity_of_branch h hv
      exact hcube t ht

/-- **Walk version of the sharpened theorem.**  Along a nonsingular admissible
radical walk over a field of characteristic `∉ {2,3,5,11}` with no primitive
cube root of unity, the `j`-invariant two steps ahead differs from the current
one as soon as the current one avoids the two CM values `-3375` and
`287496`. -/
theorem radChain_two_step_nonbacktracking_sharp {r : ℕ → K} {A : K} (h2 : (2 : K) ≠ 0)
    (h3 : (3 : K) ≠ 0) (h5 : (5 : K) ≠ 0) (h11 : (11 : K) ≠ 0)
    (hcube : ∀ t : K, t ^ 2 + t + 1 ≠ 0) (h : NonsingularWalk r A) (n : ℕ)
    (hj1 : jMont (radChain r A n) ≠ -3375) (hj2 : jMont (radChain r A n) ≠ 287496) :
    jMont (radChain r A (n + 2)) ≠ jMont (radChain r A n) := by
  obtain ⟨hadm, hns⟩ := h
  obtain ⟨hr0, hrsq⟩ := hadm n
  have hstep : jMont (radChain r A (n + 2)) = jQuot (radChain r A (n + 1)) :=
    radChain_jMont_eq_jQuot h2 ⟨hadm, hns⟩ (n + 1)
  rw [hstep, radChain_succ]
  exact radical_two_step_nonbacktracking_sharp h2 h3 h5 h11 hcube hr0 hrsq (hns n) hj1 hj2

/-- **Only two exceptional `j`-invariants.**  Restated as a classification: in
the good characteristics, two-step backtracking implies that the starting
`j`-invariant is one of the two CM values. -/
theorem two_step_backtracking_j_classification {A α : K} (h2 : (2 : K) ≠ 0)
    (h3 : (3 : K) ≠ 0) (h5 : (5 : K) ≠ 0) (h11 : (11 : K) ≠ 0)
    (hcube : ∀ t : K, t ^ 2 + t + 1 ≠ 0) (hα : α ≠ 0) (hsq : α ^ 2 = A + 2)
    (hd : A ^ 2 - 4 ≠ 0) (hback : jQuot (radTwoParam A α) = jMont A) :
    jMont A = -3375 ∨ jMont A = 287496 := by
  by_contra hcon
  push_neg at hcon
  exact radical_two_step_nonbacktracking_sharp h2 h3 h5 h11 hcube hα hsq hd
    hcon.1 hcon.2 hback

/-- **At most two backtracking `j`-invariants.**  Any finite set of
`j`-invariants of Montgomery curves that backtrack after two radical steps has
at most two elements, in the good characteristics and in the absence of a
primitive cube root of unity.  Compare `backtracking_locus_card_le_nine`, which
bounds the locus by nine *parameters* over an arbitrary field. -/
theorem backtracking_j_locus_card_le_two [DecidableEq K] (h2 : (2 : K) ≠ 0)
    (h3 : (3 : K) ≠ 0) (h5 : (5 : K) ≠ 0) (h11 : (11 : K) ≠ 0)
    (hcube : ∀ t : K, t ^ 2 + t + 1 ≠ 0) (S : Finset K)
    (hS : ∀ j ∈ S, ∃ A α : K, α ≠ 0 ∧ α ^ 2 = A + 2 ∧ A ^ 2 - 4 ≠ 0 ∧
      j = jMont A ∧ jQuot (radTwoParam A α) = jMont A) :
    S.card ≤ 2 := by
  have hsub : S ⊆ ({-3375, 287496} : Finset K) := by
    intro j hj
    obtain ⟨A, α, hα0, hsq, hd, hjA, hback⟩ := hS j hj
    subst hjA
    rcases two_step_backtracking_j_classification h2 h3 h5 h11 hcube hα0 hsq hd hback with
      h | h
    · simp [h]
    · simp [h]
  calc S.card ≤ ({-3375, 287496} : Finset K).card := Finset.card_le_card hsub
    _ ≤ 2 := (Finset.card_insert_le _ _).trans (by simp)

/-! ## Sharpness in the excluded characteristics -/

/-- A helper: whenever `btNum A = 0` and `btDen A = 0`, two-step backtracking
does occur (this is the degenerate branch of `backtrackPoly`). -/
theorem backtracking_of_common_root {A α : K} (h2 : (2 : K) ≠ 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = A + 2) (hd : A ^ 2 - 4 ≠ 0) (hn : btNum A = 0) (hv : btDen A = 0) :
    jQuot (radTwoParam A α) = jMont A := by
  refine (two_step_return_iff h2 hα hsq hd).mpr ?_
  simp only [backtrackPoly, hn, hv]
  ring

/-- **Characteristic `3`: backtracking at `j = 0`.**  In characteristic `3` the
parameter `A = 0` satisfies `btNum 0 = 132 = 0` and `btDen 0 = 24 = 0`, so the
radical walk returns to its starting `j`-invariant after two steps, and that
`j`-invariant is `0`. -/
theorem backtracking_at_zero_char_three {α : K} (h3 : (3 : K) = 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = (0 : K) + 2) :
    jQuot (radTwoParam (0 : K) α) = jMont (0 : K) ∧ jMont (0 : K) = 0 := by
  have h2 : (2 : K) ≠ 0 := by
    intro h
    have : (1 : K) = 0 := by linear_combination h3 - h
    exact one_ne_zero this
  have hd : (0 : K) ^ 2 - 4 ≠ 0 := by
    intro h
    have : (1 : K) = 0 := by linear_combination -h - h3
    exact one_ne_zero this
  have hn : btNum (0 : K) = 0 := by
    simp only [btNum]; linear_combination (44 : K) * h3
  have hv : btDen (0 : K) = 0 := by
    simp only [btDen]; linear_combination (8 : K) * h3
  refine ⟨backtracking_of_common_root h2 hα hsq hd hn hv, ?_⟩
  rw [jMont, div_eq_zero_iff]
  left
  linear_combination (-2304 : K) * h3

/-- **Characteristic `5`: backtracking at `j = 0`.**  In characteristic `5` any
`A` with `A² = 3` satisfies `btNum A = 60A + 135 = 0` and `btDen A = 0`, so
backtracking occurs at `j = 0`.  Hence the hypothesis `(5 : K) ≠ 0` in
`radical_two_step_nonbacktracking_sharp` is necessary. -/
theorem backtracking_at_sqrt_three_char_five {A α : K} (h5 : (5 : K) = 0)
    (hA : A ^ 2 = 3) (hα : α ≠ 0) (hsq : α ^ 2 = A + 2) :
    jQuot (radTwoParam A α) = jMont A ∧ jMont A = 0 := by
  have h2 : (2 : K) ≠ 0 := by
    intro h
    have : (1 : K) = 0 := by linear_combination h5 - 2 * h
    exact one_ne_zero this
  have hd : A ^ 2 - 4 ≠ 0 := by
    intro h
    have : (1 : K) = 0 := by linear_combination -h + hA
    exact one_ne_zero this
  have hn : btNum A = 0 := by
    simp only [btNum]; linear_combination hA + (12 * A + 27) * h5
  have hv : btDen A = 0 := by
    simp only [btDen]; linear_combination (4 * A - 8) * hA
  refine ⟨backtracking_of_common_root h2 hα hsq hd hn hv, ?_⟩
  rw [jMont, div_eq_zero_iff]
  left
  have : A ^ 2 - 3 = 0 := by linear_combination hA
  rw [this]; ring

/-- **Characteristic `11`: the `j = 0` locus collapses onto the principal
branch.**  In characteristic `11` a parameter with `A² = 3` and `btNum A = 0`
must be `A = 6`, which is the principal branch `A = 6` of
`backtrackPoly_factor`; so characteristic `11` produces no new exceptional
`j`-invariant, but the elimination in `btNum_btDen_no_common_root` genuinely
fails there. -/
theorem backtracking_at_six_char_eleven {A : K} (h11 : (11 : K) = 0)
    (h2 : (2 : K) ≠ 0) (h3 : (3 : K) ≠ 0) (h5 : (5 : K) ≠ 0)
    (hA : A ^ 2 = 3) (hn : btNum A = 0) : A = 6 := by
  have h15 : (15 : K) ≠ 0 := by
    have h : (15 : K) = 3 * 5 := by norm_num
    rw [h]; exact mul_ne_zero h3 h5
  have hlin : (15 : K) * (4 * A + 9) = 0 := by
    simp only [btNum] at hn; linear_combination hn - hA
  have h4A : 4 * A + 9 = 0 := by
    rcases mul_eq_zero.mp hlin with h | h
    · exact absurd h h15
    · exact h
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero h2 h2
  have : (4 : K) * (A - 6) = 0 := by linear_combination h4A - 3 * h11
  rcases mul_eq_zero.mp this with h | h
  · exact absurd h hfour
  · linear_combination h

/-- Characteristic `11` is consistent with the sharp classification: at `A = 6`
the `j`-invariant is simultaneously `287496` and `0`, because
`287496 = 11 · 26136`. -/
theorem jMont_six_eq_zero_char_eleven (h11 : (11 : K) = 0) (h2 : (2 : K) ≠ 0) :
    jMont (6 : K) = 0 := by
  rw [jMont_six h2]
  linear_combination (26136 : K) * h11

/-! ## An unconditional counterexample in characteristic five -/

section CharFive

private lemma fact_prime_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩

attribute [local instance] fact_prime_five

/-- **The characteristic-`5` exception is real.**  Over the algebraic closure of
`𝔽₅` there is an actual Montgomery parameter `A` and an actual radical `α` for
which the radical 2-isogeny walk returns to its starting `j`-invariant after two
steps, and that `j`-invariant is `0`.  This makes the necessity of the
hypothesis `(5 : K) ≠ 0` unconditional, rather than merely conditional on the
existence of a square root of `3`. -/
theorem char_five_backtracking_exists :
    ∃ (A α : AlgebraicClosure (ZMod 5)), α ≠ 0 ∧ α ^ 2 = A + 2 ∧
      jQuot (radTwoParam A α) = jMont A ∧ jMont A = 0 := by
  have h5 : (5 : AlgebraicClosure (ZMod 5)) = 0 := by
    exact_mod_cast CharP.cast_eq_zero (AlgebraicClosure (ZMod 5)) 5
  obtain ⟨A, hAsq⟩ :=
    IsAlgClosed.exists_pow_nat_eq (3 : AlgebraicClosure (ZMod 5)) (n := 2) (by norm_num)
  obtain ⟨α, hαsq⟩ := IsAlgClosed.exists_pow_nat_eq (A + 2) (n := 2) (by norm_num)
  have hne : A + 2 ≠ 0 := by
    intro h
    have hA4 : A ^ 2 = 4 := by
      have hA2 : A = -2 := by linear_combination h
      rw [hA2]; ring
    have hone : (1 : AlgebraicClosure (ZMod 5)) = 0 := by linear_combination hAsq - hA4
    exact one_ne_zero hone
  have hα : α ≠ 0 := by
    intro h
    rw [h] at hαsq
    exact hne (by linear_combination -hαsq)
  obtain ⟨h1, h2⟩ := backtracking_at_sqrt_three_char_five h5 hAsq hα hαsq
  exact ⟨A, α, hα, hαsq, h1, h2⟩

end CharFive

end Cryptography.IsogenySIDH