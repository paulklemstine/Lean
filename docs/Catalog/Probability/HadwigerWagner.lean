/-
  The Excluded-Minor Reformulation, Wagner's Equivalence and the Four Colour
  Theorem
  =========================================================================

  Hadwiger's conjecture is usually stated as an implication about colourings;
  the *equivalent* excluded-minor form — "every `K_{k+1}`-minor-free graph is
  `k`-colourable" — is what connects it to the Four Colour Theorem.  This file
  proves that equivalence and then records, as honest conditional theorems, the
  Wagner route to the Four Colour Theorem.

  Main results:

  * `Hadwiger.card_le_of_completeMinor`      : a `Kₙ` minor needs `n` vertices.
  * `Hadwiger.hadwigerProperty_iff_minorFree_colorable` : the excluded-minor
                                                reformulation, for every `k`.
  * `Hadwiger.hadwiger_four_iff_K5_free_four_colorable` : the `k = 4` instance —
                                                Hadwiger for `4` is *equivalent*
                                                to "`K₅`-minor-free graphs are
                                                `4`-colourable", the statement
                                                that Wagner's structure theorem
                                                converts into the Four Colour
                                                Theorem.
  * `Hadwiger.four_color_theorem_of_hadwiger_four` : granted the (Wagner) fact
                                                that planar graphs have no `K₅`
                                                minor, Hadwiger for `k = 4`
                                                implies the Four Colour Theorem.
  * `Hadwiger.hadwiger_le_two`               : the proved cases assemble into
                                                `HadwigerProperty k` for `k ≤ 2`.
  * `Hadwiger.hadwiger_four_implies_all_below` : Hadwiger for `4` implies all of
                                                `k = 0,1,2,3`.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): the colouring form and the excluded-minor form of
    the conjecture are literally contrapositive, so the equivalence should be
    provable with no graph theory at all; the mathematics sits entirely in the
    (unproved) statements themselves.
  Experiment (Experimenter): confirmed — `hadwigerProperty_iff_minorFree_colorable`
    is a two-line classical argument.  The interesting content is the
    *conditional* theorem: with the planarity input of Wagner's theorem taken as
    an explicit hypothesis, Hadwiger `k = 4` yields the Four Colour Theorem.
  Analysis (Analyst): we deliberately do not axiomatise Wagner's structure
    theorem or the Four Colour Theorem; instead every deep input appears as a
    named hypothesis of the theorem that uses it, so no unproved statement ever
    enters the environment.
  Critique (Critic): a reader must check that the hypothesis
    `planar_no_K5_minor` is not vacuous — it is the easy half of Wagner's
    theorem (planar graphs have no `K₅` minor), true for every reasonable
    formalisation of planarity, and it is *used*, not assumed away.
  Synthesis (PI): the chain "Hadwiger(4) ⇒ K₅-minor-free 4-colourable ⇒ (Wagner)
    Four Colour Theorem" is now formal, as is the antitone chain descending to
    the cases proved outright in this development.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerMonotone

namespace Hadwiger

open SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-! ### A complete minor forces many vertices -/

/-- If `Kₙ` is a minor of `G` then `G` has at least `n` vertices. -/
theorem card_le_of_completeMinor [Fintype V] {n : ℕ} (h : CompleteMinor n G) :
    n ≤ Fintype.card V := by
  classical
  obtain ⟨M⟩ := walkMinor_iff_isMinor.mpr h
  choose f hf using M.branch_nonempty
  have hinj : Function.Injective f := by
    intro i j hij
    by_contra hne
    exact (Set.disjoint_left.mp (M.branch_disjoint hne)) (hf i) (hij ▸ hf j)
  simpa using Fintype.card_le_of_injective f hinj

/-! ### The excluded-minor reformulation -/

/-- **Excluded-minor form of Hadwiger's conjecture.**  For every `k`, the
conjecture for `k` is equivalent to "every finite `K_{k+1}`-minor-free graph is
`k`-colourable". -/
theorem hadwigerProperty_iff_minorFree_colorable (k : ℕ) :
    HadwigerProperty k ↔
      ∀ (V : Type) [Finite V] (G : SimpleGraph V), ¬ CompleteMinor (k + 1) G → G.Colorable k := by
  constructor
  · intro h V _ G hfree
    by_contra hcol
    exact hfree (h V G hcol)
  · intro h V _ G hcol
    by_contra hfree
    exact hcol (h V G hfree)

/-- The `k = 4` instance: Hadwiger's conjecture for `4` is *equivalent* to the
statement that `K₅`-minor-free graphs are `4`-colourable.  Via Wagner's
structure theorem the right-hand side is equivalent to the Four Colour
Theorem. -/
theorem hadwiger_four_iff_K5_free_four_colorable :
    HadwigerProperty 4 ↔
      ∀ (V : Type) [Finite V] (G : SimpleGraph V), ¬ CompleteMinor 5 G → G.Colorable 4 :=
  hadwigerProperty_iff_minorFree_colorable 4

/-- **Hadwiger `k = 4` implies the Four Colour Theorem**, given the easy half of
Wagner's theorem (a planar graph has no `K₅` minor), which is supplied here as
an explicit hypothesis about an abstract planarity predicate. -/
theorem four_color_theorem_of_hadwiger_four
    (IsPlanar : ∀ {V : Type}, SimpleGraph V → Prop)
    (planar_no_K5_minor :
      ∀ (V : Type) [Finite V] (G : SimpleGraph V), IsPlanar G → ¬ CompleteMinor 5 G)
    (h : HadwigerProperty 4) :
    ∀ (V : Type) [Finite V] (G : SimpleGraph V), IsPlanar G → G.Colorable 4 := by
  intro V _ G hplanar
  exact hadwiger_four_iff_K5_free_four_colorable.mp h V G (planar_no_K5_minor V G hplanar)

/-- Conversely, the Four Colour Theorem plus the hard half of Wagner's theorem
(every `K₅`-minor-free graph is `4`-colourable, obtained from the clique-sum
decomposition into planar pieces and `V₈`) gives Hadwiger's conjecture for
`k = 4`. -/
theorem hadwiger_four_of_wagner
    (wagner_K5_free_four_colorable :
      ∀ (V : Type) [Finite V] (G : SimpleGraph V), ¬ CompleteMinor 5 G → G.Colorable 4) :
    HadwigerProperty 4 :=
  hadwiger_four_iff_K5_free_four_colorable.mpr wagner_K5_free_four_colorable

/-! ### What is proved outright, and what the open cases would give -/

/-- The cases settled in this development: Hadwiger's conjecture holds for every
`k ≤ 2`. -/
theorem hadwiger_le_two {k : ℕ} (hk : k ≤ 2) : HadwigerProperty k := by
  interval_cases k
  · exact hadwiger_zero
  · exact hadwiger_one
  · exact hadwiger_two

/-- Antitonicity in action: Hadwiger for `k = 4` (the Wagner case) implies all
smaller cases. -/
theorem hadwiger_four_implies_all_below (h : HadwigerProperty 4) :
    ∀ k ≤ 4, HadwigerProperty k := by
  have h3 : HadwigerProperty 3 := hadwiger_monotone h
  have h2 : HadwigerProperty 2 := hadwiger_monotone h3
  have h1 : HadwigerProperty 1 := hadwiger_monotone h2
  have h0 : HadwigerProperty 0 := hadwiger_monotone h1
  intro k hk
  interval_cases k <;> assumption

/-- A `K₅`-minor-free graph on at most four vertices is automatically
`4`-colourable — the base case that any inductive attack on the Wagner case must
start from, here verified from the vertex-count bound. -/
theorem colorable_four_of_card_le_four {V : Type} [Fintype V] (G : SimpleGraph V)
    (hcard : Fintype.card V ≤ 4) : G.Colorable 4 := by
  classical
  obtain ⟨f⟩ := Function.Embedding.nonempty_of_card_le (α := V) (β := Fin 4)
    (by simpa using hcard)
  exact ⟨Coloring.mk f fun {x y} hxy hcon => (G.ne_of_adj hxy) (f.injective hcon)⟩

end Hadwiger