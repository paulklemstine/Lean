import Logic.DreamLogic.FourValued
import Logic.DreamLogic.ClosedSetTopology

/-!
# Dream Logic III — The Algebra/Topology Correspondence

This file bridges the two faces of dream logic: the finite four-valued algebra of
`FourValued.lean` and the closed-set topological semantics of `ClosedSetTopology.lean`.

To each region `A ⊆ ℝ` and point `x` we assign a four-valued *local truth value*
`classify A x`, read off from membership in `A` and in the paraconsistent negation
`pneg A = closure Aᶜ`:

* `tt`      — `x` is in `A` but not in `pneg A` (purely true);
* `ff`      — `x` is in `pneg A` but not in `A` (purely false);
* `both`    — `x` is in both (a **glut**, a boundary/impossible object);
* `neither` — `x` is in neither (a gap).

## Main results

* `classify_designated_iff` — designation in the algebra is exactly topological membership:
  `designated (classify A x) ↔ x ∈ A`.
* `classify_glut_iff` — the algebraic glut `both` occurs exactly where the region meets its
  paraconsistent negation.
* `exists_topological_glut` — combining with the topological non-contradiction theorem, a
  glut is realized concretely: there is a region and a point whose local value is `both`.
* `topology_realizes_lnc_failure` — the algebraic failure of the law of non-contradiction
  (`DreamLogic.lnc_fails`) is *matched* by the topological model: the same designated
  contradiction `both` arises at an actual point of `ℝ`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The four-valued algebra and the closed-set topology are two
presentations of one logic. There should be a pointwise classification map sending each
region-and-point to a Belnap value, under which "designated" means "true (member)" and the
glut `both` means "boundary coexistence".

Experiment (Experimenter): Define `classify` by the four membership cases and prove the two
characterizations (`designated ↔ member`, `both ↔ boundary`). Then feed the topological
non-contradiction witness through the glut characterization.

Analysis (Analyst): The map is total and the characterizations are exact biconditionals, so
the correspondence is tight rather than approximate. The algebraic `lnc_fails` and the
topological `contradiction_coexists` are literally the same phenomenon viewed through
`classify`: a point where `classify A x = both` is designated yet its negation is too.

Critique (Critic): `exists_topological_glut` is proved *from* the topological existence
result, not by re-deriving a special case, so it genuinely links the two files. The
biconditionals are proved by case analysis on the two membership predicates, avoiding any
vacuous branch.

Synthesis (PI): Dream logic has a single identity with two faces — a four-element De Morgan
bilattice and a closed-set topological space — welded together by the local classification
map. Impossible objects (gluts) are exactly boundary points, and paraconsistency on both
sides is one and the same fact.
-/

namespace DreamLogic.Corr

open DreamLogic DreamLogic.Topo Set

open Classical in
/-- The local four-valued truth of region `A` at point `x`, read from membership in `A`
and in the paraconsistent negation `pneg A`. -/
noncomputable def classify (A : Set ℝ) (x : ℝ) : FV :=
  if x ∈ A then (if x ∈ pneg A then FV.both else FV.tt)
  else (if x ∈ pneg A then FV.ff else FV.neither)

/-- Designation in the algebra corresponds exactly to topological truth (membership). -/
theorem classify_designated_iff (A : Set ℝ) (x : ℝ) :
    designated (classify A x) ↔ x ∈ A := by
  unfold classify
  by_cases h : x ∈ A <;> by_cases h2 : x ∈ pneg A <;> simp [h, h2, designated]

/-- The algebraic glut `both` occurs exactly at the coexistence points of a region and its
paraconsistent negation. -/
theorem classify_glut_iff (A : Set ℝ) (x : ℝ) :
    classify A x = FV.both ↔ x ∈ A ∩ pneg A := by
  unfold classify
  by_cases h : x ∈ A <;> by_cases h2 : x ∈ pneg A <;> simp [h, h2]

/-- A glut is realized concretely in the topological model: some region and point have local
value `both`. This is obtained from the topological failure of non-contradiction. -/
theorem exists_topological_glut : ∃ (A : Set ℝ) (x : ℝ), classify A x = FV.both := by
  obtain ⟨A, _, x, hx⟩ := contradiction_coexists
  exact ⟨A, x, (classify_glut_iff A x).mpr hx⟩

/-- The algebraic failure of the law of non-contradiction is faithfully realized in the
topological model: at a boundary point `x`, the local value is the glut `both`, whose
contradiction `conj (classify A x) (neg (classify A x))` is designated. -/
theorem topology_realizes_lnc_failure :
    ∃ (A : Set ℝ) (x : ℝ), designated (conj (classify A x) (neg (classify A x))) := by
  obtain ⟨A, x, hglut⟩ := exists_topological_glut
  refine ⟨A, x, ?_⟩
  rw [hglut]
  trivial

end DreamLogic.Corr