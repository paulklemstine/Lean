import Applications.JokeColimitUniversality

/-!
# Closing the universality conjecture: the hull quotient of the joke category

`Applications.JokeColimitUniversality` proved that universal (terminal) jokes maximise
surprise, and **refuted** the converse: `exists_maximal_humor_not_terminal` exhibits a
non-terminal joke of maximal humor, because a refinement that only adds *interior*
readings changes the joke without changing its surprise.

This file closes that open conjecture rather than abandoning it. The obstruction is
entirely accounted for by one construction: the **hull** of a setup, the pair of its
extreme readings. Surprise factors through the hull, the failure of the converse is
exactly the failure of the hull map to be injective, and after passing to the hull
quotient the conjecture becomes **true**.

## Results

* `hullFunctor` : the hull is a functor `Setup ⥤ Hull` from setups to interpretive
  intervals ordered by inclusion, and `humorS_eq_humorHull` shows surprise factors
  through it.
* `humorS_eq_iff_hull_eq` : **exactly what surprise reflects.** For a refinement
  `S ≤ T`, the surprises agree iff the hulls agree. Surprise is blind to interior
  readings and to nothing else.
* `maximal_humor_iff_hullTop` : **the repaired universality conjecture.** In the
  category of jokes over a fixed setup inside an ambient universe, a joke has maximal
  humor **iff** it is terminal in the hull quotient. "Funniest = universal" is true
  after localising at hull-equivalence, and false before (see
  `JokeColimitUniversality.exists_maximal_humor_not_terminal`).
* `hullTop_of_isTerminal` : terminality upstairs implies terminality downstairs, so
  the repaired statement is a genuine weakening of the original — the original
  implication is recovered as a corollary (`humor_le_of_hullTop`).

-- !-- Lab Notes -- !--
Hypothesis (H9): the counterexample to "funniest implies universal" is not a defect of
the humor invariant but an artefact of working in a category finer than the invariant
can see; localising at hull-equivalence should restore the equivalence.

Experiment: the hull map `S ↦ (min' S, max' S)` was made a functor into the poset of
intervals ordered by inclusion. The reflection lemma was reduced to the arithmetic
fact that if `m' ≤ m ≤ M ≤ M'` and `M - m = M' - m'` then `m = m'` and `M = M'`
(`linarith`). The repaired conjecture then follows in both directions from
monotonicity of `humorHull` and the reflection lemma.

Analysis: H9 survives in the strongest possible form — the criterion is an `iff`, not
an implication, and the hull quotient is the *coarsest* localisation that works, since
`humorS_eq_iff_hull_eq` shows any two setups identified by surprise along a refinement
already have equal hulls.

Critique: the localisation is not vacuous — the fibres of the hull map are large
(every interior reading may be added or removed freely), so the quotient genuinely
loses information about the joke while retaining exactly the information humor uses.
The result should therefore be read as a limitation of the humor invariant, not as a
vindication of the naive conjecture.

Synthesis: humor factors as `Setup ⥤ Hull ⥤ ℝ`; the first functor is where the
counterexample lives and the second is where the universality conjecture is true.
-/

open CategoryTheory Limits Finset JokeSurpriseAlgebra JokeColimitUniversality

namespace JokeHullQuotient

/-- An **interpretive interval**: the pair of extreme readings of a setup. -/
def Hull : Type := {p : ℝ × ℝ // p.1 ≤ p.2}

/-- Intervals are ordered by **inclusion**: a wider interval is larger. -/
instance : Preorder Hull where
  le p q := q.1.1 ≤ p.1.1 ∧ p.1.2 ≤ q.1.2
  le_refl _ := ⟨le_rfl, le_rfl⟩
  le_trans _ _ _ h₁ h₂ := ⟨le_trans h₂.1 h₁.1, le_trans h₁.2 h₂.2⟩

theorem Hull.ext {p q : Hull} (h1 : p.1.1 = q.1.1) (h2 : p.1.2 = q.1.2) : p = q :=
  Subtype.ext (Prod.ext h1 h2)

/-- The **hull** of a setup: its two extreme readings. -/
noncomputable def hullOf (S : Setup) : Hull :=
  ⟨(S.1.min' S.2, S.1.max' S.2), S.1.min'_le_max' S.2⟩

theorem hullOf_monotone : Monotone hullOf := by
  rintro ⟨S, hS⟩ ⟨T, hT⟩ (hsub : S ⊆ T)
  exact ⟨T.min'_le _ (hsub (S.min'_mem hS)), T.le_max' _ (hsub (S.max'_mem hS))⟩

/-- **The hull is a functor** from setups to interpretive intervals. -/
noncomputable def hullFunctor : Setup ⥤ Hull := hullOf_monotone.functor

/-- The surprise of an interpretive interval. -/
def humorHull (p : Hull) : ℝ := p.1.2 - p.1.1

theorem humorHull_monotone : Monotone humorHull := by
  rintro p q ⟨h1, h2⟩
  simp only [humorHull]
  linarith

/-- Surprise as a functor on interpretive intervals. -/
def humorHullFunctor : Hull ⥤ ℝ := humorHull_monotone.functor

/-- **Surprise factors through the hull.** -/
theorem humorS_eq_humorHull (S : Setup) : humorS S = humorHull (hullOf S) := rfl

/-- **Exactly what surprise reflects.** Along a refinement, two setups have the same
surprise precisely when they have the same hull: surprise is blind to interior
readings, and blind to nothing else. -/
theorem humorS_eq_iff_hull_eq {S T : Setup} (h : S ≤ T) :
    humorS S = humorS T ↔ hullOf S = hullOf T := by
  obtain ⟨hmin, hmax⟩ := hullOf_monotone h
  constructor
  · intro heq
    have h1 : (hullOf T).1.1 ≤ (hullOf S).1.1 := hmin
    have h2 : (hullOf S).1.2 ≤ (hullOf T).1.2 := hmax
    have h3 : (hullOf S).1.2 - (hullOf S).1.1 = (hullOf T).1.2 - (hullOf T).1.1 := heq
    exact Hull.ext (by linarith) (by linarith)
  · intro heq
    simp only [humorS_eq_humorHull, heq]

/-! ### The repaired universality conjecture -/

variable {S U : Setup}

/-- A joke is **hull-universal** when its hull dominates that of every joke with the
same setup: it is a terminal object of the hull quotient of the joke category. -/
def HullTop (J : JokeOver S U) : Prop := ∀ K : JokeOver S U, hullOf K.1 ≤ hullOf J.1

/-- **Hull-universal jokes are the funniest.** -/
theorem humor_le_of_hullTop {J : JokeOver S U} (hJ : HullTop J) (K : JokeOver S U) :
    humorOver K ≤ humorOver J :=
  humorHull_monotone (hJ K)

/-- **Terminality descends to the hull quotient**, so `HullTop` is a genuine weakening
of terminality. -/
theorem hullTop_of_isTerminal {J : JokeOver S U} (hJ : IsTerminal J) : HullTop J :=
  fun K => hullOf_monotone (leOfHom (hJ.from K))

/-- **The universality conjecture, closed.** For jokes over a fixed setup inside an
ambient universe `U`, a joke has maximal humor **iff** it is terminal in the hull
quotient. The counterexample of
`JokeColimitUniversality.exists_maximal_humor_not_terminal` is therefore precisely and
only the failure of the hull functor to be injective. -/
theorem maximal_humor_iff_hullTop (h : S ≤ U) (J : JokeOver S U) :
    (∀ K : JokeOver S U, humorOver K ≤ humorOver J) ↔ HullTop J := by
  constructor
  · intro hmax K
    have hKU : K.1 ≤ U := K.2.2
    have hJU : J.1 ≤ U := J.2.2
    have hUJ : humorOver (ambient S U h) ≤ humorOver J := hmax (ambient S U h)
    have hJU' : humorS J.1 ≤ humorS U := humorS_monotone hJU
    have hEq : humorS J.1 = humorS U := le_antisymm hJU' hUJ
    have hhull : hullOf J.1 = hullOf U := (humorS_eq_iff_hull_eq hJU).1 hEq
    rw [hhull]
    exact hullOf_monotone hKU
  · intro hJ K
    exact humor_le_of_hullTop hJ K

/-- **The hull quotient is not degenerate.** The hull functor is not injective: the
jokes `{0,1}` and `{0,1/2,1}` are distinct but hull-equivalent, which is exactly why
localisation was needed. -/
theorem hullOf_not_injective : ∃ S T : Setup, S ≠ T ∧ hullOf S = hullOf T := by
  refine ⟨pun, punRefined, ?_, ?_⟩
  · intro heq
    exact absurd (heq ▸ le_refl pun) (not_le_of_gt pun_lt_punRefined)
  · exact (humorS_eq_iff_hull_eq (le_of_lt pun_lt_punRefined)).1
      (by rw [humorS_pun, humorS_punRefined])

end JokeHullQuotient