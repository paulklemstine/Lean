/-
  Hadwiger's Conjecture: Statement and the Cases k ≤ 2
  ===================================================

  Hadwiger's conjecture states that a graph whose proper colourings all need at
  least `k+1` colours contains `K_{k+1}` as a minor.  This file gives the formal
  statement `Hadwiger.HadwigerProperty k` in terms of the branch-set minor
  relation of `MinorModel.lean`, links it to Mathlib's `chromaticNumber`, and
  proves the conjecture unconditionally for `k = 0, 1, 2`.

  Main results:

  * `Hadwiger.HadwigerProperty`          : the formal statement.
  * `Hadwiger.not_colorable_iff_chromaticNumber_ge` : `¬ G.Colorable k` really
                                           says "needs at least `k+1` colours".
  * `Hadwiger.hadwiger_zero`, `Hadwiger.hadwiger_one`, `Hadwiger.hadwiger_two`
                                         : the conjecture for `k = 0, 1, 2`.
  * `Hadwiger.hadwiger_two_chromatic`    : the `k = 2` case in chromatic-number
                                           form: `3 ≤ χ(G) → K₃ ≼ G`.

  -- !-- Lab Notes -- !--
  Hypothesis (Hypothesizer): the low cases should follow from three separate
    structural facts — `χ ≥ 1 ⇒ a vertex`, `χ ≥ 2 ⇒ an edge`, `χ ≥ 3 ⇒ a cycle` —
    each converted into a branch-set model by the constructions of
    `HadwigerK3.lean`.
  Experiment (Experimenter): `k = 0` is `colorable_zero_iff`; `k = 1` needs "no
    edges ⇒ 1-colourable"; `k = 2` is the contrapositive of
    `colorable_two_of_isAcyclic` followed by `completeMinor_three_of_not_isAcyclic`.
  Analysis (Analyst): the three cases are genuinely different in strength: the
    `k = 2` case already needs both halves (colouring and contraction), which is
    the pattern that persists for `k = 3` (Dirac) and `k = 4` (Wagner + 4CT).
  Critique (Critic): the statement quantifies over finite vertex types in
    `Type`; the finiteness hypothesis is used only through the colouring half
    (`colorable_two_of_isAcyclic`), whose induction is on the edge count.
  Synthesis (PI): `k ≤ 2` is now a theorem of this development, and the
    remaining cases are isolated as explicit conditional statements in
    `HadwigerWagner.lean`.
  -- !-- Lab Notes -- !--
-/
import Mathlib
import Probability.HadwigerK3
import Probability.HadwigerBipartite

namespace Hadwiger

open SimpleGraph

variable {V : Type*} {G : SimpleGraph V}

/-- **Hadwiger's conjecture for the parameter `k`**: every finite graph that
cannot be properly coloured with `k` colours contains `K_{k+1}` as a minor. -/
def HadwigerProperty (k : ℕ) : Prop :=
  ∀ (V : Type) [Finite V] (G : SimpleGraph V), ¬ G.Colorable k → CompleteMinor (k + 1) G

/-- `¬ G.Colorable k` is exactly "the chromatic number is at least `k+1`". -/
theorem not_colorable_iff_chromaticNumber_ge {k : ℕ} :
    ¬ G.Colorable k ↔ (k : ℕ∞) + 1 ≤ G.chromaticNumber := by
  rw [← chromaticNumber_le_iff_colorable, not_le, ENat.add_one_le_iff (by simp)]

/-- A graph with no edges is `1`-colourable. -/
theorem colorable_one_of_no_adj (h : ∀ x y : V, ¬ G.Adj x y) : G.Colorable 1 :=
  ⟨Coloring.mk (fun _ => 0) (fun {x y} hxy => absurd hxy (h x y))⟩

/-- **Hadwiger for `k = 0`.**  A graph that is not `0`-colourable has a vertex,
hence a `K₁` minor. -/
theorem hadwiger_zero : HadwigerProperty 0 := by
  intro V _ G h
  have : Nonempty V := by
    by_contra hcon
    exact h (colorable_zero_iff.mpr (not_nonempty_iff.mp hcon))
  obtain ⟨v⟩ := this
  exact completeMinor_one v

/-- **Hadwiger for `k = 1`.**  A graph that is not `1`-colourable has an edge,
hence a `K₂` minor. -/
theorem hadwiger_one : HadwigerProperty 1 := by
  intro V _ G h
  by_cases hE : ∃ u v, G.Adj u v
  · obtain ⟨u, v, huv⟩ := hE
    exact completeMinor_two_of_adj huv
  · push_neg at hE
    exact absurd (colorable_one_of_no_adj hE) h

/-- **Hadwiger for `k = 2`.**  A graph that is not `2`-colourable contains a
cycle, hence a `K₃` minor. -/
theorem hadwiger_two : HadwigerProperty 2 := by
  intro V _ G h
  have hacyc : ¬ G.IsAcyclic := fun hac => h (colorable_two_of_isAcyclic hac)
  exact completeMinor_three_of_not_isAcyclic hacyc

/-- Chromatic-number form of the `k = 2` case: a graph needing three colours has
`K₃` as a minor. -/
theorem hadwiger_two_chromatic {V : Type} [Finite V] (G : SimpleGraph V)
    (h : 3 ≤ G.chromaticNumber) : CompleteMinor 3 G := by
  refine hadwiger_two V G ?_
  rw [not_colorable_iff_chromaticNumber_ge]
  simpa using h

/-- Contrapositive packaging: a `K₃`-minor-free finite graph is `2`-colourable —
the "excluded minor ⇒ colouring" direction for `k = 2`. -/
theorem colorable_two_of_no_K3_minor {V : Type} [Finite V] (G : SimpleGraph V)
    (h : ¬ CompleteMinor 3 G) : G.Colorable 2 := by
  by_contra hcon
  exact h (hadwiger_two V G hcon)

end Hadwiger