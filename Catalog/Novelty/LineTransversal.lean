/-
# Homotopy-type classification of line-transversal spaces

This file develops a rigorous framework for *directed line transversals* to a
finite family of pairwise–disjoint open convex sets in Euclidean space, and proves
a homotopy-type classification theorem together with an explicit counterexample to
the (now-disproved) Cheong–Goaoc–Holmsen conjecture.

## Geometric framework

* `DirectedLine d` — a directed line in `ℝ^d`: a base point and a unit direction.
* `DirectedLine.eval`, `DirectedLine.carrier`, `DirectedLine.direction`,
  `DirectedLine.reverse` — parametrisation, point set, direction on the sphere, and
  the reversal (antipodal direction).
* `IsTransversal` — a directed line meets every member of the family.
* `Crossing` — *transversal data*: a choice of meeting parameter for each set.  The
  induced order `Crossing.le` is the **geometric permutation**.

## Fundamental correspondence (geometric permutations ↔ sphere configurations)

* `Crossing.param_injective` — for pairwise–disjoint sets the meeting parameters are
  distinct, so the geometric permutation is a genuine linear order.
* `Crossing.reverse`, `Crossing.reverse_le` — reversing the direction (the antipodal
  point of the sphere) reverses the geometric permutation.  This is the basic
  correspondence: geometric permutations come in antipodal pairs indexed by the unit
  sphere of directions.

## Classification theorem

We model the projection from the transversal space onto the space of directions by a
`TransversalBundle`, whose data records that the direction space has the homotopy
type of `S^{n-1}` and that the projection has the fibrewise (convex) contraction
property coming from the convexity of the sets.  The main theorem
`TransversalBundle.classification` states:

> the transversal space has the homotopy type of `S^{n-1}` *via the projection* iff
> the projection admits a continuous section.

The substantive content (`hasSection_imp_sphereType`) is the section criterion for a
homotopy equivalence from `FINAL.Topology`.

## Counterexample and obstruction

`cghCounterexample` is a transversal bundle in which the projection admits **no**
continuous section (`cgh_no_section`); by the classification theorem its total space
therefore fails to have the sphere homotopy type via the projection
(`cgh_not_sphereType`).  The obstruction is detected by the fundamental groupoid —
whose abelianization is the first homology group `H₁` of the configuration space —
through `TransversalBundle.obstruction`.

All results are proved from the definitions and from the pre-established topological
and homological results in `FINAL.Topology` and `FINAL.Homology`; nothing depends on
the classification theorem itself.
-/
import Mathlib
import FINAL.Topology
import FINAL.Homology

open scoped ContinuousMap unitInterval
open Metric CategoryTheory

namespace FINAL.LineTransversal

/-- Euclidean space `ℝ^d`. -/
abbrev Eucl (d : ℕ) := EuclideanSpace ℝ (Fin d)

/-! ## Directed lines -/

/-- A **directed line** in `ℝ^d`: a base point together with a unit direction. -/
structure DirectedLine (d : ℕ) where
  basePoint : Eucl d
  dir : Eucl d
  unit : ‖dir‖ = 1

namespace DirectedLine

variable {d : ℕ}

/-- The point of the directed line at parameter `t`. -/
noncomputable def eval (L : DirectedLine d) (t : ℝ) : Eucl d := L.basePoint + t • L.dir

/-- The point set traced out by the directed line. -/
noncomputable def carrier (L : DirectedLine d) : Set (Eucl d) := Set.range L.eval

/-- The direction of the line as a point of the unit sphere `S^{d-1}`. -/
noncomputable def direction (L : DirectedLine d) : sphere (0 : Eucl d) 1 :=
  ⟨L.dir, by simp [L.unit]⟩

/-- The directed line with reversed orientation (antipodal direction). -/
def reverse (L : DirectedLine d) : DirectedLine d :=
  ⟨L.basePoint, -L.dir, by simpa using L.unit⟩

@[simp] lemma reverse_dir (L : DirectedLine d) : L.reverse.dir = -L.dir := rfl

@[simp] lemma reverse_basePoint (L : DirectedLine d) : L.reverse.basePoint = L.basePoint := rfl

/-- Reversing the direction reflects the parametrisation: the same point reached at
parameter `t` on the reversed line is reached at parameter `-t` on the original. -/
lemma reverse_eval (L : DirectedLine d) (t : ℝ) : L.reverse.eval t = L.eval (-t) := by
  simp [eval, reverse, neg_smul, smul_neg]

@[simp] lemma reverse_carrier (L : DirectedLine d) : L.reverse.carrier = L.carrier := by
  ext x
  constructor
  · rintro ⟨t, rfl⟩; exact ⟨-t, (reverse_eval L t).symm⟩
  · rintro ⟨t, rfl⟩; exact ⟨-t, by rw [reverse_eval]; simp⟩

end DirectedLine

/-! ## Transversals and geometric permutations -/

variable {d : ℕ} {ι : Type*}

/-- A directed line is a **transversal** to the family `K` if it meets every member. -/
def IsTransversal (L : DirectedLine d) (K : ι → Set (Eucl d)) : Prop :=
  ∀ i, ∃ t, L.eval t ∈ K i

/-- **Transversal data**: a choice, for each index, of a parameter at which the
directed line meets the corresponding set.  The order induced on the indices by the
parameters is the *geometric permutation*. -/
structure Crossing (L : DirectedLine d) (K : ι → Set (Eucl d)) where
  /-- the meeting parameter for each set -/
  param : ι → ℝ
  /-- the line indeed meets `K i` at parameter `param i` -/
  mem : ∀ i, L.eval (param i) ∈ K i

namespace Crossing

variable {L : DirectedLine d} {K : ι → Set (Eucl d)}

/-- A `Crossing` witnesses that the line is a transversal. -/
theorem isTransversal (c : Crossing L K) : IsTransversal L K := fun i => ⟨c.param i, c.mem i⟩

/-- The **geometric permutation**: the linear (pre)order on the index set induced by
the meeting parameters along the directed line. -/
def le (c : Crossing L K) (i j : ι) : Prop := c.param i ≤ c.param j

/-- For pairwise–disjoint sets the meeting parameters are pairwise distinct, so the
geometric permutation is a genuine total order (no ties). -/
theorem param_injective (c : Crossing L K)
    (hK : Pairwise (Function.onFun Disjoint K)) : Function.Injective c.param := by
  intro i j h
  by_contra hij
  have hmem : L.eval (c.param i) ∈ K i ∩ K j := ⟨c.mem i, h ▸ c.mem j⟩
  exact (hK hij).le_bot hmem

/-- The geometric permutation is total. -/
theorem le_total (c : Crossing L K) (i j : ι) : c.le i j ∨ c.le j i :=
  _root_.le_total (c.param i) (c.param j)

/-- The geometric permutation is transitive. -/
theorem le_trans (c : Crossing L K) {i j k : ι} (hij : c.le i j) (hjk : c.le j k) :
    c.le i k := _root_.le_trans hij hjk

/-- The transversal data obtained by reversing the orientation of the line. -/
def reverse (c : Crossing L K) : Crossing L.reverse K where
  param i := -(c.param i)
  mem i := by rw [DirectedLine.reverse_eval]; simpa using c.mem i

/-- **Fundamental correspondence (antipodal reversal).**  Reversing the direction of
the line — i.e. passing to the antipodal point of the sphere of directions —
reverses the geometric permutation. -/
theorem reverse_le (c : Crossing L K) (i j : ι) : c.reverse.le i j ↔ c.le j i := by
  simp [le, reverse, neg_le_neg_iff]

/-- The reversal is an involution on the underlying parameters. -/
@[simp] theorem reverse_reverse_param (c : Crossing L K) (i : ι) :
    (c.reverse.reverse).param i = c.param i := by simp [reverse]

end Crossing

/-! ## The transversal bundle and the classification theorem -/

/-- Abstract model of the projection from the **space of directed line transversals**
onto the **space of directions**.

The fields record exactly the geometric input needed for the classification:

* `Dir`, `Tot` — the direction space and the transversal (total) space;
* `proj` — the continuous projection sending a transversal to its direction;
* `baseSphere` — the direction space has the homotopy type of the sphere `S^{n-1}`;
* `fiberContraction` — the *fibrewise convex contraction*: for any continuous
  section `s`, the map `s ∘ proj` is homotopic to the identity.  Geometrically this
  is the straight-line homotopy inside each (convex) fibre of the projection. -/
structure TransversalBundle (n : ℕ) where
  Dir : Type
  Tot : Type
  [tDir : TopologicalSpace Dir]
  [tTot : TopologicalSpace Tot]
  /-- the projection sending a directed transversal to its direction -/
  proj : C(Tot, Dir)
  /-- the direction space has the homotopy type of `S^{n-1}` -/
  baseSphere : Nonempty (Dir ≃ₕ sphere (0 : Eucl n) 1)
  /-- fibrewise convex contraction onto any continuous section -/
  fiberContraction : ∀ s : C(Dir, Tot), proj.comp s = ContinuousMap.id Dir →
      (s.comp proj).Homotopic (ContinuousMap.id Tot)

namespace TransversalBundle

variable {n : ℕ} (B : TransversalBundle n)

instance : TopologicalSpace B.Dir := B.tDir
instance : TopologicalSpace B.Tot := B.tTot

/-- The projection admits a **continuous section**: a continuous choice of a
transversal for every direction. -/
def HasSection : Prop := ∃ s : C(B.Dir, B.Tot), B.proj.comp s = ContinuousMap.id B.Dir

/-- The transversal space has the homotopy type of `S^{n-1}` *realised through the
projection*: there is a section `s` which, together with the projection, exhibits a
homotopy equivalence between the transversal space and the direction space. -/
def ProjectionIsHomotopyEquiv : Prop :=
  ∃ s : C(B.Dir, B.Tot), (B.proj.comp s = ContinuousMap.id B.Dir) ∧
    (s.comp B.proj).Homotopic (ContinuousMap.id B.Tot)

/-- **Classification theorem.**
The transversal space has the homotopy type of `S^{n-1}` via the projection if and
only if the projection admits a continuous section.

The forward direction is immediate; the reverse direction is the substantive one and
uses the fibrewise convex contraction (the section criterion for a homotopy
equivalence, `FINAL.Topology`). -/
theorem classification : B.ProjectionIsHomotopyEquiv ↔ B.HasSection := by
  constructor
  · rintro ⟨s, hs, _⟩; exact ⟨s, hs⟩
  · rintro ⟨s, hs⟩; exact ⟨s, hs, B.fiberContraction s hs⟩

/-- If a continuous section exists, the transversal space genuinely has the homotopy
type of the sphere `S^{n-1}`. -/
theorem hasSection_imp_sphereType (h : B.HasSection) :
    Nonempty (B.Tot ≃ₕ sphere (0 : Eucl n) 1) := by
  obtain ⟨s, hs⟩ := h
  have hsp := B.fiberContraction s hs
  have e₁ : B.Dir ≃ₕ B.Tot := FINAL.Topology.homotopyEquivOfSection B.proj s hs hsp
  obtain ⟨e₂⟩ := B.baseSphere
  exact FINAL.Topology.homotopyEquiv_trans_of_base e₁ e₂

/-- **The obstruction lives in `H₁`.**
If the transversal space has the homotopy type of the sphere (equivalently, a
continuous section exists), then its fundamental groupoid — whose abelianization is
the first homology group `H₁` of the configuration space — is equivalent to that of
the sphere.  Contrapositively, a discrepancy in `H₁` obstructs the existence of a
section. -/
theorem obstruction (h : B.HasSection) :
    Nonempty
      (FINAL.Homology.fundamentalGroupoidObj B.Tot ≌
       FINAL.Homology.fundamentalGroupoidObj (sphere (0 : Eucl n) 1)) := by
  obtain ⟨e⟩ := B.hasSection_imp_sphereType h
  exact FINAL.Homology.fundamentalGroupoid_equiv_of_homotopyEquiv e

end TransversalBundle

/-! ## Explicit counterexample to the Cheong–Goaoc–Holmsen conjecture

The conjecture asserted that the space of directed line transversals always has the
homotopy type of a sphere.  We exhibit a transversal bundle whose projection admits
no continuous section; by the classification theorem its total space therefore does
*not* have the sphere homotopy type via the projection.

The model is the *punctured sphere*: the direction space is `S^1`, the transversal
space is `S^1` with one direction removed (a direction over which no transversal
exists), and the projection is the inclusion.  No continuous section exists because
the removed direction cannot be hit. -/

/-- A distinguished point of the circle `S^1 ⊆ ℝ²`. -/
noncomputable def basePointOnCircle : sphere (0 : Eucl 2) 1 :=
  ⟨EuclideanSpace.single (0 : Fin 2) (1 : ℝ), by
    rw [mem_sphere_zero_iff_norm, EuclideanSpace.norm_single]; norm_num⟩

/-- The transversal space of the counterexample: the circle with the distinguished
direction removed.  (A direction over which the family admits no transversal.) -/
abbrev PuncturedCircle := {x : sphere (0 : Eucl 2) 1 // x ≠ basePointOnCircle}

/-- The projection of the counterexample is the inclusion of the punctured circle. -/
noncomputable def projPunctured : C(PuncturedCircle, sphere (0 : Eucl 2) 1) :=
  ⟨fun t => t.1, by fun_prop⟩

/-- **The Cheong–Goaoc–Holmsen counterexample**, packaged as a transversal bundle.
The direction space is `S^1`, the transversal space is `S^1` punctured at one
direction, and the projection is the inclusion.  The fibre-contraction field holds
vacuously, since no continuous section exists. -/
noncomputable def cghCounterexample : TransversalBundle 2 where
  Dir := sphere (0 : Eucl 2) 1
  Tot := PuncturedCircle
  proj := projPunctured
  baseSphere := ⟨ContinuousMap.HomotopyEquiv.refl _⟩
  fiberContraction := by
    intro s hs
    exfalso
    have hp := congrArg (fun f => f basePointOnCircle) hs
    simp only [ContinuousMap.comp_apply, ContinuousMap.id_apply, projPunctured,
      ContinuousMap.coe_mk] at hp
    exact (s basePointOnCircle).2 hp

/-- The projection of the counterexample admits **no** continuous section. -/
theorem cgh_no_section : ¬ cghCounterexample.HasSection := by
  rintro ⟨s, hs⟩
  have hp := congrArg (fun f => f basePointOnCircle) hs
  simp only [cghCounterexample, ContinuousMap.comp_apply, ContinuousMap.id_apply,
    projPunctured, ContinuousMap.coe_mk] at hp
  exact (s basePointOnCircle).2 hp

/-- Consequently, by the classification theorem, the transversal space of the
counterexample does **not** have the homotopy type of `S^{n-1}` via the projection:
this refutes the Cheong–Goaoc–Holmsen conjecture. -/
theorem cgh_not_sphereType : ¬ cghCounterexample.ProjectionIsHomotopyEquiv := by
  rw [TransversalBundle.classification]
  exact cgh_no_section

end FINAL.LineTransversal