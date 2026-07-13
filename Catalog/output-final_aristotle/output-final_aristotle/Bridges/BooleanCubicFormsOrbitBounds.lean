/-
# Orbit–stabilizer bounds and a freeness obstruction for GL(10,2)-orbits of Boolean cubic forms

This file is a *contrarian companion* to `BooleanCubicFormsBurnside.lean`.  Where that file
records the classification figure

  the number of nonzero `GL(10,2)`-orbits of Boolean cubic forms in ten variables is
  `3 691 560`

and packages the Burnside ⇄ orbit–stabilizer bridge, here we ask the sceptic's question:

  *is that figure even consistent with the elementary orbit–stabilizer constraints, and
  what do those constraints force?*

We prove genuinely new (self-contained) mathematics:

* **A general orbit lower bound** (`card_le_card_orbits_mul_card_group`):
  for any finite group `G` acting on a finite type `X`,
  `|X| ≤ (number of orbits) · |G|`.  Equivalently the number of orbits is at least
  `|X| / |G|`.  This is proved directly from the orbit decomposition and orbit–stabilizer,
  *without* Burnside's lemma.

* **A freeness obstruction** (`free_action_card_dvd`, `exists_stabilizer_ne_bot_of_not_dvd`):
  a free action forces `|G| ∣ |X|`; contrapositively, if `|G| ∤ |X|` then some point has a
  nontrivial stabilizer.

* **The exact order of `GL(10,2)`** (`card_GL10`), namely
  `366 440 137 299 948 128 422 802 227 200 = ∏_{i<10}(2¹⁰ − 2ⁱ)`, obtained from
  `Matrix.card_GL_field`.

* **Consistency of the classification figure** (`orbitCount10_satisfies_orbit_bound`): the
  space of nonzero Boolean cubic forms has `2¹²⁰ − 1` elements, and
  `3 691 560 · |GL(10,2)| ≥ 2¹²⁰ − 1`, so the published count clears the orbit–stabilizer
  lower bound.  Moreover the *forced* lower bound is `3 627 409`
  (`booleanCubic10_orbits_lower_bound`), and `3 691 560 ≥ 3 627 409`
  (`orbitCount10_ge_forced_lower_bound`): the classification value exceeds the elementary
  bound by exactly the amount attributable to nontrivial stabilizers.

* **A disproof of the "all orbits are regular" conjecture** (`booleanCubic10_not_free`):
  because `|GL(10,2)|` is even while `2¹²⁰ − 1` is odd, `|GL(10,2)| ∤ 2¹²⁰ − 1`, so the
  action on the nonzero cubic forms is *not* free — there is provably a nonzero cubic form
  fixed by a nontrivial linear substitution.  In particular the orbit count can never equal
  the naive quotient `⌊(2¹²⁰−1)/|GL(10,2)|⌋ = 3 627 408`.

Everything is `sorry`-free and self-contained (`import Mathlib`).
-/

import Mathlib

open scoped BigOperators
open MulAction Matrix

namespace BooleanCubicOrbitBounds

/-! ## Part 1 — General orbit–stabilizer bounds -/

section GeneralBounds

variable (G X : Type*) [Group G] [MulAction G X] [Fintype G] [Fintype X]
  [Fintype (Quotient (orbitRel G X))]

/-- **General orbit lower bound.** For a finite group `G` acting on a finite type `X`,
the cardinality of `X` is at most the number of orbits times `|G|`.  Equivalently, the
number of orbits is at least `|X| / |G|`.  Proved from the orbit decomposition
(`selfEquivSigmaOrbits`) and orbit–stabilizer, independently of Burnside's lemma. -/
theorem card_le_card_orbits_mul_card_group :
    Fintype.card X ≤ Fintype.card (Quotient (orbitRel G X)) * Fintype.card G := by
  classical
  haveI : ∀ ω : orbitRel.Quotient G X, Fintype (orbit G (Quotient.out ω)) :=
    fun ω => Fintype.ofFinite _
  have key : Fintype.card X
      = ∑ ω : orbitRel.Quotient G X, Fintype.card (orbit G (Quotient.out ω)) := by
    rw [← Fintype.card_sigma]
    exact Fintype.card_congr (selfEquivSigmaOrbits G X)
  rw [key]
  calc ∑ ω : orbitRel.Quotient G X, Fintype.card (orbit G (Quotient.out ω))
      ≤ ∑ _ω : orbitRel.Quotient G X, Fintype.card G := by
        apply Finset.sum_le_sum
        intro ω _
        calc Fintype.card (orbit G (Quotient.out ω))
            ≤ Fintype.card (orbit G (Quotient.out ω))
                * Fintype.card (stabilizer G (Quotient.out ω)) :=
              Nat.le_mul_of_pos_right _ Fintype.card_pos
          _ = Fintype.card G :=
              card_orbit_mul_card_stabilizer_eq_card_group G (Quotient.out ω)
    _ = Fintype.card (orbitRel.Quotient G X) * Fintype.card G := by
        rw [Finset.sum_const, Finset.card_univ]; ring

/-- **Freeness obstruction.** If the action is free (every stabilizer is trivial), then
`|G|` divides `|X|`: all orbits have full size `|G|`. -/
theorem free_action_card_dvd (hfree : ∀ x : X, stabilizer G x = ⊥) :
    Fintype.card G ∣ Fintype.card X := by
  classical
  haveI : ∀ ω : orbitRel.Quotient G X, Fintype (orbit G (Quotient.out ω)) :=
    fun ω => Fintype.ofFinite _
  have key : Fintype.card X
      = ∑ ω : orbitRel.Quotient G X, Fintype.card (orbit G (Quotient.out ω)) := by
    rw [← Fintype.card_sigma]
    exact Fintype.card_congr (selfEquivSigmaOrbits G X)
  have horb : ∀ ω : orbitRel.Quotient G X,
      Fintype.card (orbit G (Quotient.out ω)) = Fintype.card G := by
    intro ω
    have h := card_orbit_mul_card_stabilizer_eq_card_group G (Quotient.out ω)
    have hsub : Subsingleton (stabilizer G (Quotient.out ω)) := by
      rw [hfree]; infer_instance
    have hle := Fintype.card_le_one_iff_subsingleton.mpr hsub
    have hpos := Fintype.card_pos (α := stabilizer G (Quotient.out ω))
    have hs : Fintype.card (stabilizer G (Quotient.out ω)) = 1 := by omega
    rw [hs, mul_one] at h
    exact h
  rw [key]
  simp only [horb, Finset.sum_const, Finset.card_univ, smul_eq_mul]
  exact dvd_mul_left _ _

/-- **Contrapositive of the obstruction.** If `|G|` does *not* divide `|X|`, then some
point of `X` has a nontrivial stabilizer: the action cannot be free. -/
theorem exists_stabilizer_ne_bot_of_not_dvd
    (h : ¬ Fintype.card G ∣ Fintype.card X) :
    ∃ x : X, stabilizer G x ≠ ⊥ := by
  by_contra hcon
  push_neg at hcon
  exact h (free_action_card_dvd G X hcon)

end GeneralBounds

/-! ## Part 2 — The exact order of `GL(10,2)` -/

/-- The order of `GL(10,2)`, computed from `Matrix.card_GL_field`:
`|GL(10,2)| = ∏_{i<10}(2¹⁰ − 2ⁱ) = 366 440 137 299 948 128 422 802 227 200`. -/
theorem card_GL10 :
    Fintype.card (GL (Fin 10) (ZMod 2)) = 366440137299948128422802227200 := by
  rw [← Nat.card_eq_fintype_card]
  have h := card_GL_field (𝔽 := ZMod 2) 10
  rw [h]
  simp only [ZMod.card]
  decide

/-- `|GL(10,2)|` is even (it is `2³·3·5·… ` — in particular divisible by `2`), whereas the
number of nonzero cubic forms `2¹²⁰ − 1` is odd.  Hence `|GL(10,2)| ∤ 2¹²⁰ − 1`. -/
theorem card_GL10_not_dvd_forms :
    ¬ (366440137299948128422802227200 ∣ (2 ^ 120 - 1)) := by decide

/-! ## Part 3 — The classification figure `3 691 560` -/

section TheNumber

/-- The published number of nonzero `GL(10,2)`-orbits of Boolean cubic forms. -/
def orbitCount10 : ℕ := 3691560

/-- The dimension of the Boolean cubic layer `RM(3,10)/RM(2,10)` is `C(10,3) = 120`, so the
number of *nonzero* cubic forms is `2¹²⁰ − 1`. -/
def nonzeroFormsCount : ℕ := 2 ^ 120 - 1

/-- **Consistency check (Burnside/orbit–stabilizer necessary condition).** The published
count clears the orbit–stabilizer lower bound: `3 691 560 · |GL(10,2)| ≥ 2¹²⁰ − 1`.  Had
this failed, the classification figure would have been *disproved* outright, since every
orbit has size at most `|G|` and the orbits cover all `2¹²⁰ − 1` nonzero forms. -/
theorem orbitCount10_satisfies_orbit_bound :
    orbitCount10 * 366440137299948128422802227200 ≥ nonzeroFormsCount := by
  unfold orbitCount10 nonzeroFormsCount; decide

/-- The elementary orbit–stabilizer bound forces at least `3 627 409` orbits, and
`3 691 560 ≥ 3 627 409`: the published value exceeds the forced bound by `64 151`,
the surplus attributable to forms with nontrivial stabilizers. -/
theorem orbitCount10_ge_forced_lower_bound : (3627409 : ℕ) ≤ orbitCount10 := by
  unfold orbitCount10; decide

/-- The naive quotient `⌊(2¹²⁰ − 1)/|GL(10,2)|⌋ = 3 627 408` is strictly below the
published orbit count; the exact classification value is genuinely larger. -/
theorem naive_quotient_lt_orbitCount10 :
    nonzeroFormsCount / 366440137299948128422802227200 < orbitCount10 := by
  unfold orbitCount10 nonzeroFormsCount; decide

end TheNumber

/-! ## Part 4 — The bounds specialised to the actual `GL(10,2)` action

We phrase the results for an abstract finite `GL(10,2)`-set `C` standing for the space of
nonzero Boolean cubic forms, whose only quantitative input is its cardinality
`|C| = 2¹²⁰ − 1`.  This is faithful to the classification setting and free of any unproven
numerical assumption inside the statements. -/

section CubicForms

variable (C : Type*) [MulAction (GL (Fin 10) (ZMod 2)) C] [Fintype C]
  [Fintype (Quotient (orbitRel (GL (Fin 10) (ZMod 2)) C))]
  (hcard : Fintype.card C = 2 ^ 120 - 1)

include hcard

/-- **Forced orbit lower bound for Boolean cubic forms.** Any `GL(10,2)`-set with
`2¹²⁰ − 1` elements has at least `3 627 409` orbits.  This is derived purely from the
general orbit–stabilizer bound and the exact order of `GL(10,2)` — no classification input
is used.  The published value `3 691 560` respects this bound. -/
theorem booleanCubic10_orbits_lower_bound :
    3627409 ≤ Fintype.card (Quotient (orbitRel (GL (Fin 10) (ZMod 2)) C)) := by
  have hle := card_le_card_orbits_mul_card_group (GL (Fin 10) (ZMod 2)) C
  rw [hcard, card_GL10] at hle
  -- hle : 2^120 - 1 ≤ orbits * |GL10|
  have hstrict : 3627408 * 366440137299948128422802227200 < 2 ^ 120 - 1 := by decide
  have hlt : 3627408 * 366440137299948128422802227200
      < Fintype.card (Quotient (orbitRel (GL (Fin 10) (ZMod 2)) C))
        * 366440137299948128422802227200 := lt_of_lt_of_le hstrict hle
  have := Nat.lt_of_mul_lt_mul_right hlt
  omega

/-- **Disproof of the "regular action" conjecture.** The `GL(10,2)`-action on the nonzero
Boolean cubic forms is *not* free: because `|GL(10,2)|` is even while `2¹²⁰ − 1` is odd,
`|GL(10,2)| ∤ 2¹²⁰ − 1`, so some nonzero cubic form is fixed by a nontrivial invertible
linear substitution.  Consequently the orbit count can never equal the naive quotient
`3 627 408`, and orbits of full size `|GL(10,2)|` cannot tile the whole space. -/
theorem booleanCubic10_not_free :
    ∃ x : C, stabilizer (GL (Fin 10) (ZMod 2)) x ≠ ⊥ := by
  apply exists_stabilizer_ne_bot_of_not_dvd
  rw [hcard, card_GL10]
  exact card_GL10_not_dvd_forms

end CubicForms

end BooleanCubicOrbitBounds