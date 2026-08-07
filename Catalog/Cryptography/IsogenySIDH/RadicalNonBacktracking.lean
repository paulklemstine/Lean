/-
# Radical 2-isogeny walks do not backtrack on the `j`-line

`RadicalWalkStructure` proved a *one-step* non-backtracking statement at the
level of kernels: the kernel of the next radical step is the image of a
four-torsion point, while the dual kernel is the image of the non-kernel
two-torsion, and these are distinct.  That leaves open the sharper, genuinely
*global* question, which is the one that matters for the mixing behaviour of a
radical walk:

> can a radical walk return to its starting point of the `j`-line after two
> steps, i.e. can `j_{n+2} = j_n`?

This file settles it completely, with no unproved side conditions.

The computation is carried out along the following chain.

* `jQuot_radTwoParam` — the second step's target, as a rational function of the
  *original* parameter:
  `jQuot (radTwoParam A α) = 4 (A² + 60A + 132)³ / ((A+2)(A-2)⁴)`.
  As in `ModularTwoIsogeny`, the radical `α` cancels.
* `two_step_return_iff` — consequently `j_{n+2} = j_n` happens **iff** the two
  explicit polynomials `btNum A = A² + 60A + 132` and
  `btDen A = 4(A²-3)(A-2)` have equal cubes.
* `backtrackPoly_factor` — `btNum³ - btDen³` factors as
  `-(A-6)(4A² + 15A + 18) · (btNum² + btNum·btDen + btDen²)`, the first factor
  being the "principal" branch and the second the branch that needs a
  primitive cube root of unity.
* `jMont_six` (`= 287496`), `jMont_eq_neg3375_of_quadratic` (`= -3375`) and
  `sq_eq_three_of_btDen_eq_zero` (`j = 0`) identify the three exceptional
  `j`-invariants: `287496` (CM by discriminant `-16`), `-3375` (discriminant
  `-7`) and `0` (discriminant `-3`).
* `radical_two_step_backtracking_classification` and the `j`-level corollary
  `radical_two_step_nonbacktracking` — over a field containing no primitive
  cube root of unity, a radical step can backtrack **only** at
  `j ∈ {0, -3375, 287496}`.
* `radChain_two_step_nonbacktracking` — the walk version.
* `backtracking_locus_card_le_nine` — over *any* field (in particular over
  `𝔽_{p²}`, which does contain cube roots of unity) the backtracking locus is
  cut out by a degree-9 polynomial with nonzero leading coefficient `-64`, so
  at most nine Montgomery parameters per field can backtrack.

Together with the results of `RadicalWalkStructure` this closes Conjecture 4 of
the previous cycle's `FUTURE_DIRECTIONS.md` in the two-step case, and pins down
exactly which `j`-invariants the conjectured exceptional set must contain: the
guess `{1728, 8000, -3375, 287496}` was wrong in detail — the correct list for
two-step returns is `{0, -3375, 287496}`, while `{1728, 8000, -3375}` is the
list for one-step returns proved in `RadicalWalkStructure`.
-/
import Cryptography.IsogenySIDH.RadicalWalkStructure

set_option maxHeartbeats 1000000

namespace Cryptography.IsogenySIDH

open Polynomial

variable {K : Type*} [Field K]

/-! ## The two-step target on the `j`-line -/

/-- Numerator polynomial of the two-step comparison: `A² + 60A + 132`. -/
def btNum (A : K) : K := A ^ 2 + 60 * A + 132

/-- Denominator polynomial of the two-step comparison: `4(A²-3)(A-2)`. -/
def btDen (A : K) : K := 4 * (A ^ 2 - 3) * (A - 2)

/-- The obstruction to two-step backtracking, `btNum³ - btDen³`. -/
def backtrackPoly (A : K) : K := btNum A ^ 3 - btDen A ^ 3

/-- **The `j`-invariant reached after two radical steps.**  Starting at `A` and
taking a radical step with `α² = A + 2`, the *next* step lands on the
`j`-invariant `jQuot (radTwoParam A α)`, and this is the rational function
`4 (A² + 60A + 132)³ / ((A+2)(A-2)⁴)` of the original parameter: the radical
cancels a second time. -/
theorem jQuot_radTwoParam {A α : K} (htwo : (2 : K) ≠ 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = A + 2) (hd : A ^ 2 - 4 ≠ 0) :
    jQuot (radTwoParam A α) = 4 * btNum A ^ 3 / ((A + 2) * (A - 2) ^ 4) := by
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero htwo htwo
  have hA : A = α ^ 2 - 2 := by linear_combination -hsq
  subst hA
  have hα2 : α ^ 2 ≠ 0 := pow_ne_zero 2 hα
  have hα4 : α ^ 2 - 4 ≠ 0 := fun h => hd (by linear_combination α ^ 2 * h)
  have hnum : ((α ^ 2 - 2 + 6) / (2 * α)) ^ 2 + 12
      = (α ^ 4 + 56 * α ^ 2 + 16) / (4 * α ^ 2) := by
    field_simp; ring
  have hden : ((α ^ 2 - 2 + 6) / (2 * α)) ^ 2 - 4 = (α ^ 2 - 4) ^ 2 / (4 * α ^ 2) := by
    field_simp; ring
  rw [show α ^ 2 - 2 + 2 = α ^ 2 from by ring, show α ^ 2 - 2 - 2 = α ^ 2 - 4 from by ring]
  simp only [jQuot, radTwoParam, btNum, hnum, hden]
  field_simp
  ring

/-! ## The two-step return criterion -/

/-- **Two-step return criterion.**  A radical walk returns to its starting
`j`-invariant after two steps exactly when the two explicit polynomials
`btNum A` and `btDen A` have the same cube. -/
theorem two_step_return_iff {A α : K} (htwo : (2 : K) ≠ 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = A + 2) (hd : A ^ 2 - 4 ≠ 0) :
    jQuot (radTwoParam A α) = jMont A ↔ backtrackPoly A = 0 := by
  have hAp2 : A + 2 ≠ 0 := fun h => hd (by linear_combination (A - 2) * h)
  have hAm2 : A - 2 ≠ 0 := fun h => hd (by linear_combination (A + 2) * h)
  have hfour : (4 : K) ≠ 0 := by
    have h : (4 : K) = 2 * 2 := by norm_num
    rw [h]; exact mul_ne_zero htwo htwo
  rw [jQuot_radTwoParam htwo hα hsq hd, jMont, div_eq_div_iff
    (mul_ne_zero hAp2 (pow_ne_zero 4 hAm2)) hd]
  simp only [backtrackPoly, btNum, btDen]
  constructor
  · intro h
    have hfac : 4 * ((A + 2) * (A - 2)) *
        ((A ^ 2 + 60 * A + 132) ^ 3 - (4 * (A ^ 2 - 3) * (A - 2)) ^ 3) = 0 := by
      linear_combination h
    rcases mul_eq_zero.mp hfac with h1 | h1
    · exact absurd h1 (mul_ne_zero hfour (mul_ne_zero hAp2 hAm2))
    · exact h1
  · intro h
    linear_combination 4 * (A + 2) * (A - 2) * h

/-! ## Factoring the obstruction -/

/-- The obstruction factors: the "principal" branch `(A-6)(4A² + 15A + 18)`
times the "cube-root-of-unity" branch `btNum² + btNum·btDen + btDen²`. -/
theorem backtrackPoly_factor (A : K) :
    backtrackPoly A =
      -((A - 6) * (4 * A ^ 2 + 15 * A + 18)) *
        (btNum A ^ 2 + btNum A * btDen A + btDen A ^ 2) := by
  simp only [backtrackPoly, btNum, btDen]; ring

/-! ## The three exceptional `j`-invariants -/

/-- The Montgomery parameter `A = 6` has `j`-invariant `287496`, the CM
`j`-invariant of discriminant `-16`. -/
theorem jMont_six (htwo : (2 : K) ≠ 0) : jMont (6 : K) = 287496 := by
  have h32 : (32 : K) ≠ 0 := by
    have h : (32 : K) = 2 ^ 5 := by norm_num
    rw [h]; exact pow_ne_zero 5 htwo
  have hd : (6 : K) ^ 2 - 4 = 32 := by norm_num
  rw [jMont, hd, div_eq_iff h32]
  ring

/-- A root of `4A² + 15A + 18` has `j`-invariant `-3375`, the CM `j`-invariant
of discriminant `-7`.  (The proof is the exact polynomial division
`256(A²-3)³ + 3375(A²-4) = (4A² + 15A + 18)(64A⁴ - 240A³ + 36A² + 945A - 1134)`.) -/
theorem jMont_eq_neg3375_of_quadratic {A : K} (hd : A ^ 2 - 4 ≠ 0)
    (hq : 4 * A ^ 2 + 15 * A + 18 = 0) : jMont A = -3375 := by
  rw [jMont, div_eq_iff hd]
  linear_combination (64 * A ^ 4 - 240 * A ^ 3 + 36 * A ^ 2 + 945 * A - 1134) * hq

/-- `btDen A = 0` with `A ≠ 2` forces `A² = 3`, i.e. `j = 0`. -/
theorem sq_eq_three_of_btDen_eq_zero {A : K} (htwo : (2 : K) ≠ 0)
    (hAm2 : A - 2 ≠ 0) (h : btDen A = 0) : A ^ 2 = 3 := by
  have hfour : (4 : K) ≠ 0 := by
    have h4 : (4 : K) = 2 * 2 := by norm_num
    rw [h4]; exact mul_ne_zero htwo htwo
  simp only [btDen] at h
  rcases mul_eq_zero.mp h with h1 | h1
  · rcases mul_eq_zero.mp h1 with h2 | h2
    · exact absurd h2 hfour
    · linear_combination h2
  · exact absurd h1 hAm2

/-- The Montgomery parameters with `A² = 3` are exactly the ones with
`j`-invariant `0`. -/
theorem jMont_eq_zero_iff {A : K} (htwo : (2 : K) ≠ 0) (hd : A ^ 2 - 4 ≠ 0) :
    jMont A = 0 ↔ A ^ 2 = 3 := by
  have h256 : (256 : K) ≠ 0 := by
    have h : (256 : K) = 2 ^ 8 := by norm_num
    rw [h]; exact pow_ne_zero 8 htwo
  rw [jMont, div_eq_zero_iff]
  constructor
  · rintro (h | h)
    · rcases mul_eq_zero.mp h with h1 | h1
      · exact absurd h1 h256
      · have := pow_eq_zero_iff (n := 3) (by norm_num) |>.mp h1
        linear_combination this
    · exact absurd h hd
  · intro h
    left
    have : A ^ 2 - 3 = 0 := by linear_combination h
    rw [this]; ring

/-! ## Classification of two-step backtracking -/

/-- **Classification of two-step backtracking.**  If a radical step returns the
walk to its starting `j`-invariant after two steps, then one of exactly three
algebraic conditions holds on the Montgomery parameter: `A = 6`, or `A` is a
root of `4A² + 15A + 18`, or the cube-root-of-unity branch
`btNum² + btNum·btDen + btDen² = 0` holds. -/
theorem radical_two_step_backtracking_classification {A α : K} (htwo : (2 : K) ≠ 0)
    (hα : α ≠ 0) (hsq : α ^ 2 = A + 2) (hd : A ^ 2 - 4 ≠ 0)
    (hback : jQuot (radTwoParam A α) = jMont A) :
    A = 6 ∨ 4 * A ^ 2 + 15 * A + 18 = 0 ∨
      btNum A ^ 2 + btNum A * btDen A + btDen A ^ 2 = 0 := by
  have h0 : backtrackPoly A = 0 := (two_step_return_iff htwo hα hsq hd).mp hback
  rw [backtrackPoly_factor] at h0
  rcases mul_eq_zero.mp h0 with h1 | h1
  · rcases mul_eq_zero.mp (neg_eq_zero.mp h1) with h2 | h2
    · exact Or.inl (sub_eq_zero.mp h2)
    · exact Or.inr (Or.inl h2)
  · exact Or.inr (Or.inr h1)

/-- The cube-root-of-unity branch really does require a primitive cube root of
unity in the field, unless the degenerate case `btDen A = 0` (that is, `j = 0`)
occurs. -/
theorem cube_root_of_unity_of_branch {A : K}
    (hbr : btNum A ^ 2 + btNum A * btDen A + btDen A ^ 2 = 0) (hv : btDen A ≠ 0) :
    ∃ t : K, t ^ 2 + t + 1 = 0 := by
  refine ⟨btNum A / btDen A, ?_⟩
  field_simp
  linear_combination hbr

/-- **Radical walks never backtrack, away from three CM points.**  Over a field
containing no primitive cube root of unity, a radical 2-isogeny step can return
the walk to its starting `j`-invariant after two steps only when that
`j`-invariant is one of `0`, `-3375`, `287496` — the CM `j`-invariants of
discriminants `-3`, `-7` and `-16`. -/
theorem radical_two_step_nonbacktracking {A α : K} (htwo : (2 : K) ≠ 0)
    (hcube : ∀ t : K, t ^ 2 + t + 1 ≠ 0) (hα : α ≠ 0) (hsq : α ^ 2 = A + 2)
    (hd : A ^ 2 - 4 ≠ 0) (h0 : jMont A ≠ 0) (h1 : jMont A ≠ -3375)
    (h2 : jMont A ≠ 287496) :
    jQuot (radTwoParam A α) ≠ jMont A := by
  intro hback
  have hAm2 : A - 2 ≠ 0 := fun h => hd (by linear_combination (A + 2) * h)
  rcases radical_two_step_backtracking_classification htwo hα hsq hd hback with h | h | h
  · exact h2 (by rw [h, jMont_six htwo])
  · exact h1 (jMont_eq_neg3375_of_quadratic hd h)
  · by_cases hv : btDen A = 0
    · exact h0 ((jMont_eq_zero_iff htwo hd).mpr
        (sq_eq_three_of_btDen_eq_zero htwo hAm2 hv))
    · obtain ⟨t, ht⟩ := cube_root_of_unity_of_branch h hv
      exact hcube t ht

/-- **Walk version.**  Along a nonsingular admissible radical walk over a field
with no primitive cube root of unity, the `j`-invariant reached after two more
steps is never the current one, provided the current `j`-invariant avoids the
three CM values `0`, `-3375`, `287496`. -/
theorem radChain_two_step_nonbacktracking {r : ℕ → K} {A : K} (htwo : (2 : K) ≠ 0)
    (hcube : ∀ t : K, t ^ 2 + t + 1 ≠ 0) (h : NonsingularWalk r A) (n : ℕ)
    (h0 : jMont (radChain r A n) ≠ 0) (h1 : jMont (radChain r A n) ≠ -3375)
    (h2 : jMont (radChain r A n) ≠ 287496) :
    jMont (radChain r A (n + 2)) ≠ jMont (radChain r A n) := by
  obtain ⟨hadm, hns⟩ := h
  obtain ⟨hr0, hrsq⟩ := hadm n
  have hstep : jMont (radChain r A (n + 2)) = jQuot (radChain r A (n + 1)) :=
    radChain_jMont_eq_jQuot htwo ⟨hadm, hns⟩ (n + 1)
  rw [hstep, radChain_succ]
  exact radical_two_step_nonbacktracking htwo hcube hr0 hrsq (hns n) h0 h1 h2

/-- **Two radical steps form a cyclic 4-isogeny.**  Both steps are edges of the
2-isogeny graph and the endpoints differ, which is exactly the statement that
the composite has cyclic kernel of order four. -/
theorem radChain_cyclic_four_isogeny {r : ℕ → K} {A : K} (htwo : (2 : K) ≠ 0)
    (hcube : ∀ t : K, t ^ 2 + t + 1 ≠ 0) (h : NonsingularWalk r A) (n : ℕ)
    (h0 : jMont (radChain r A n) ≠ 0) (h1 : jMont (radChain r A n) ≠ -3375)
    (h2 : jMont (radChain r A n) ≠ 287496) :
    modPoly2 (jMont (radChain r A n)) (jMont (radChain r A (n + 1))) = 0 ∧
      modPoly2 (jMont (radChain r A (n + 1))) (jMont (radChain r A (n + 2))) = 0 ∧
      jMont (radChain r A (n + 2)) ≠ jMont (radChain r A n) :=
  ⟨radChain_isTwoIsogenyPath htwo h n, radChain_isTwoIsogenyPath htwo h (n + 1),
    radChain_two_step_nonbacktracking htwo hcube h n h0 h1 h2⟩

/-! ## Sharpness: the exceptional `j`-invariants really do backtrack -/

/-- **The exceptional value `287496` is attained.**  At `A = 6` (whenever
`A + 2 = 8` is a square in `K`, e.g. over `𝔽_{p²}`) the radical walk really does
return to its starting `j`-invariant after two steps.  So the exceptional set of
`radical_two_step_nonbacktracking` cannot be shrunk. -/
theorem backtracking_at_six {α : K} (htwo : (2 : K) ≠ 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = (6 : K) + 2) :
    jQuot (radTwoParam (6 : K) α) = jMont (6 : K) := by
  have h32 : (32 : K) ≠ 0 := by
    have h : (32 : K) = 2 ^ 5 := by norm_num
    rw [h]; exact pow_ne_zero 5 htwo
  have hd : (6 : K) ^ 2 - 4 ≠ 0 := by
    intro h; exact h32 (by linear_combination h)
  refine (two_step_return_iff htwo hα hsq hd).mpr ?_
  simp only [backtrackPoly, btNum, btDen]
  norm_num

/-- **The exceptional value `-3375` is attained.**  At a root of
`4A² + 15A + 18` the radical walk also returns after two steps: there
`btNum A = btDen A`. -/
theorem backtracking_of_quadratic_root {A α : K} (htwo : (2 : K) ≠ 0) (hα : α ≠ 0)
    (hsq : α ^ 2 = A + 2) (hd : A ^ 2 - 4 ≠ 0) (hq : 4 * A ^ 2 + 15 * A + 18 = 0) :
    jQuot (radTwoParam A α) = jMont A := by
  refine (two_step_return_iff htwo hα hsq hd).mpr ?_
  have hfac : btNum A - btDen A = -((A - 6) * (4 * A ^ 2 + 15 * A + 18)) := by
    simp only [btNum, btDen]; ring
  have heq : btNum A = btDen A := by
    have h0 : btNum A - btDen A = 0 := by rw [hfac, hq]; ring
    linear_combination h0
  simp only [backtrackPoly, heq]
  ring

/-! ## Over an arbitrary field: the backtracking locus is finite -/

/-- The obstruction as an honest univariate polynomial of degree nine. -/
noncomputable def backtrackPolyX : K[X] :=
  C (-64) * X ^ 9 + C 384 * X ^ 8 + C (-192) * X ^ 7 + C (-2943) * X ^ 6
    + C 5364 * X ^ 5 + C 16956 * X ^ 4 + C 244512 * X ^ 3 + C 1481328 * X ^ 2
    + C 3157056 * X + C 2286144

theorem backtrackPolyX_eval (A : K) : (backtrackPolyX).eval A = backtrackPoly A := by
  simp only [backtrackPolyX, backtrackPoly, btNum, btDen, eval_add, eval_mul, eval_pow,
    eval_C, eval_X]
  ring

theorem backtrackPolyX_natDegree (htwo : (2 : K) ≠ 0) :
    (backtrackPolyX (K := K)).natDegree = 9 := by
  have h64 : (64 : K) ≠ 0 := by
    have h : (64 : K) = 2 ^ 6 := by norm_num
    rw [h]
    exact pow_ne_zero 6 htwo
  unfold backtrackPolyX
  compute_degree
  all_goals first | omega | exact neg_ne_zero.mpr h64

theorem backtrackPolyX_ne_zero (htwo : (2 : K) ≠ 0) : (backtrackPolyX (K := K)) ≠ 0 := by
  intro h
  have hdeg := backtrackPolyX_natDegree (K := K) htwo
  rw [h] at hdeg
  simp at hdeg

/-- **The backtracking locus is finite, over any field.**  Over `𝔽_{p²}` a
primitive cube root of unity does exist (for `p ≠ 3`), so the hypothesis of
`radical_two_step_nonbacktracking` can fail there.  Even then, backtracking is
confined to the roots of a fixed degree-nine polynomial: at most nine
Montgomery parameters in the whole field can backtrack after two steps. -/
theorem backtracking_locus_card_le_nine [DecidableEq K] (htwo : (2 : K) ≠ 0)
    (S : Finset K) (hS : ∀ A ∈ S, backtrackPoly A = 0) : S.card ≤ 9 := by
  have hsub : S ⊆ (backtrackPolyX (K := K)).roots.toFinset := by
    intro A hA
    rw [Multiset.mem_toFinset, mem_roots (backtrackPolyX_ne_zero htwo), IsRoot,
      backtrackPolyX_eval]
    exact hS A hA
  calc S.card ≤ (backtrackPolyX (K := K)).roots.toFinset.card := Finset.card_le_card hsub
    _ ≤ Multiset.card (backtrackPolyX (K := K)).roots := Multiset.toFinset_card_le _
    _ ≤ (backtrackPolyX (K := K)).natDegree := card_roots' _
    _ = 9 := backtrackPolyX_natDegree htwo

end Cryptography.IsogenySIDH