import Applications.ImpossibleFiguresTorus
import Pythagorean.EscherStaircases

/-!
# Gauge Classification of Periodic Impossible Figures

A periodic impossible figure is represented by horizontal and vertical increment
fields on a discrete torus. Changing the local reference height adds a discrete
gradient, but cannot alter curvature or either fundamental period. Thus the
obstruction to development is intrinsic rather than an artifact of the chosen
height convention.

The results also separate two meanings often conflated in pictures of endless
stairs. A periodic geometric staircase is governed by additive holonomy, whereas
the power-of-two ideal construction is an infinite strictly descending filtration.
The latter has zero intersection but is not a periodic ascent.
-/

open Finset
open ImpossibleFigures.Torus

namespace ImpossibleObjects.Gauge

variable {m n : ℕ} [NeZero m] [NeZero n]
variable {A : Type*} [AddCommGroup A]

/-- Changing the local height reference by `g` adds its discrete gradient. -/
def shift (g : Grid m n A) (a b : Grid m n A) : Grid m n A × Grid m n A :=
  (a + dx g, b + dy g)

/-
Curvature is invariant under a change of local height reference.
-/
omit [NeZero m] [NeZero n] in
theorem curv_shift (g a b : Grid m n A) :
    curv (shift g a b).1 (shift g a b).2 = curv a b := by
  ext p;
  unfold curv shift; simp +decide [ dx, dy ] ; abel1;

/-
Horizontal holonomy is gauge invariant.
-/
omit [NeZero n] in
theorem periodX_shift (g a b : Grid m n A) :
    periodX (shift g a b).1 = periodX a := by
  convert congr_arg ( fun x : A => x + periodX a ) ( periodX_gradient g ) using 1;
  · unfold shift periodX;
    simp +decide [ add_comm, Finset.sum_add_distrib ];
  · rw [ zero_add ]

/-
Vertical holonomy is gauge invariant.
-/
omit [NeZero m] in
theorem periodY_shift (g a b : Grid m n A) :
    periodY (shift g a b).2 = periodY b := by
  unfold shift periodY;
  convert congr_arg ( fun x : A => x + ∑ j : ZMod n, b ( 0, j ) ) ( ImpossibleFigures.Torus.periodY_gradient g ) using 1 ; simp +decide;
  · rw [ Finset.sum_add_distrib, add_comm ] ; rfl;
  · rw [ zero_add ]

/-
Developability is invariant under a change of local height reference.
-/
theorem realizable_shift_iff (g a b : Grid m n A) :
    Realizable (shift g a b).1 (shift g a b).2 ↔ Realizable a b := by
  rw [ ImpossibleFigures.Torus.realizable_iff, ImpossibleFigures.Torus.realizable_iff ];
  rw [ curv_shift, periodX_shift, periodY_shift ]

/-
The complete obstruction triple is constant on gauge classes.
-/
theorem obstruction_triple_shift (g a b : Grid m n A) :
    (curv (shift g a b).1 (shift g a b).2,
      periodX (shift g a b).1, periodY (shift g a b).2) =
    (curv a b, periodX a, periodY b) := by
  rw [ curv_shift, periodX_shift, periodY_shift ]

/-
Gauge-invariant classification: after any local reference change, a figure is
 developable exactly when its original curvature and periods vanish.
-/
theorem shifted_developable_iff (g a b : Grid m n A) :
    Realizable (shift g a b).1 (shift g a b).2 ↔
      curv a b = 0 ∧ periodX a = 0 ∧ periodY b = 0 := by
  exact realizable_shift_iff g a b |>.trans ( ImpossibleFigures.Torus.realizable_iff a b )

section Examples

/-- A concrete nonconstant gauge on the three-by-three torus. -/
def checkerGauge : Grid 3 3 ℝ := fun p => (p.1.val : ℝ) - (p.2.val : ℝ)

/-
No choice of the concrete checkerboard reference makes the Waterfall
 developable.
-/
example : ¬ Realizable
    (shift checkerGauge waterfall.1 waterfall.2).1
    (shift checkerGauge waterfall.1 waterfall.2).2 := by
  intro h;
  convert waterfall_impossible ( realizable_shift_iff checkerGauge waterfall.1 waterfall.2 |>.1 h ) using 1

/-- The catalogued power-of-two filtration supplies a boundary example: it is a
strictly descending algebraic staircase with zero intersection, not an ascending
periodic geometric staircase. -/
example : StrictAnti EscherStaircases.twoPowerIdeal ∧
    (⨅ k, EscherStaircases.twoPowerIdeal k) = ⊥ := by
  exact EscherStaircases.powers_of_two_corrected_staircase

#check shifted_developable_iff
#check EscherStaircases.powers_of_two_corrected_staircase

end Examples

-- !-- Lab Notes -- !--
/-
**Hypothesis.** (1) Curvature and the two torus periods survive every local change
of height reference. (2) Developability is therefore a property of a gauge class,
not a drawing convention. (3) Every flat periodic field with zero periods is
integrable. (4) A uniformly descending Waterfall remains impossible in every
gauge. (5) The power-of-two ideal staircase is descending, not a model of periodic
ascent. (6) A smooth-manifold formulation should require a precise definition of
“embedded Penrose triangle”; non-orientability alone is not such a definition.

**Experiment.** The first five claims were tested against arbitrary additive
coefficient groups and arbitrary torus sizes. Gradient curvature cancels tile by
tile, while gradient periods telescope. The concrete checker gauge provides a
nonconstant example. The ideal-filtration example imports the existing corrected
staircase theorem and tests the analogy at its boundary.

**Analysis.** The surviving structure is cohomological: exact changes preserve a
closed field's periods. Local inconsistency is measured by curvature and global
inconsistency by two independent holonomies. This unifies developability,
discrete differential geometry, and additive algebra. The proposed universal
non-orientable-manifold claim needs a different definition: an embedded object
cannot simultaneously be merely an immersed surface, and “Penrose triangle” has
no canonical smooth topological type.

**Critique.** The main results are not definitional restatements: they use
cancellation of mixed discrete derivatives, finite-sum reindexing, and the torus
integration theorem. Boundary cases include arbitrary nonzero torus sizes and
arbitrary additive commutative groups. No orientability assertion is smuggled in;
the unsupported smooth claim is withheld rather than made vacuous.

**Synthesis.** Periodic developable figures are classified modulo gauge by local
curvature and two global periods. The broader extension is to cellular cochains
on arbitrary finite complexes and, after choosing rigorous geometric semantics,
to smooth or piecewise-linear surfaces.
-/

end ImpossibleObjects.Gauge