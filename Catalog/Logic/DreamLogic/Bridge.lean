import Mathlib
import Logic.DreamLogic.Belnap
import Geometry.DreamLogic.Topology

/-!
# Dream Logic III — The Bridge: Topological Frontiers *are* Belnap Gluts

This is the **cross-domain bridge** of the cycle.  It imports

* the **Logic** domain file `Logic/DreamLogic/Belnap.lean` (Belnap's four-valued
  paraconsistent algebra `FOUR`, with its `designated`/`conj`/`neg`/`glut_iff`),
  and
* the **Geometry** domain file `Geometry/DreamLogic/Topology.lean` (the
  closed-set co-Heyting model with `contradiction`/`pneg`/`frontier`),

and fuses them.  Given a closed set `A` we assign to every point a Belnap truth
value:

  `val A x = true`   if `x ∈ interior A`        (robustly inside the belief),
  `val A x = false`  if `x ∈ interior Aᶜ`       (robustly outside),
  `val A x = both`   otherwise (i.e. on the frontier).

## The new connection

* `val_both_iff_frontier` — a point receives the **glut** value `both`
  (the Logic-domain "impossible object") **iff** it lies on the topological
  **frontier** (the Geometry-domain "impossible object").  The two notions of
  dialetheia, invented in different domains, *coincide*.
* `designated_iff_mem` — for closed `A`, a point's value is *designated* iff the
  point is actually in `A`: the four-valued semantics is faithful to membership.
* `glut_iff_contradiction` — the gluts are exactly the points of the topological
  `contradiction` set: it ties the Logic `glut_iff` to the Geometry
  `contradiction_eq_frontier`.
* `dream_object_real_is_glut` — the concrete `ℝ` dialetheia `0 ∈ [0,1]` carries
  the glut value `both`, and that value is a fixed point of negation and an
  accepted contradiction (`designated (conj v (neg v))`).  This single statement
  uses real-analysis (`frontier_Icc`), the topological model, and the Belnap
  algebra together.

-- !-- Lab Notes -- !--
Bridge files used:
  * Logic domain:    `Catalog/Logic/DreamLogic/Belnap.lean`
                     (`Belnap`, `Belnap.neg`, `Belnap.conj`, `Belnap.designated`,
                      `Belnap.glut_iff`).
  * Geometry domain: `Catalog/Geometry/DreamLogic/Topology.lean`
                     (`DreamTopo.contradiction`, `DreamTopo.contradiction_eq_frontier`,
                      `DreamTopo.dream_object_real`).
New connection: the *pointwise* truth-valuation of a closed set turns the
  topological frontier into the algebraic glut value `both`.  Thus Belnap's
  syntactic "impossible object" and Tarski's topological boundary are the **same
  object** viewed in two domains — the frontier point is literally a coexisting
  contradiction (`designated (conj v (neg v))` with `neg v = v`).
Hypothesis (Stage 1): "Frontier ≟ glut."  Experiment (Stage 2): defined `val`,
  proved both directions by reducing `interior`/`closure` complements.
Analysis (Stage 3): `interior Aᶜ = Aᶜ` for closed `A` is what makes
  `designated_iff_mem` clean — closedness is essential.  Critique (Stage 4):
  removed reliance on `decide`; every bridge theorem uses `by_cases` on the
  interior/exterior split.  Synthesis (Stage 5): connectedness (Geometry) +
  glut_iff (Logic) gives the capstone `dream_object_real_is_glut`.
-/

open Set Topology DreamLogic DreamTopo

namespace DreamLogic.Bridge

variable {X : Type*} [TopologicalSpace X]

open Classical in
/-- The pointwise four-valued truth valuation induced by a set `A`. -/
noncomputable def val (A : Set X) (x : X) : Belnap :=
  if x ∈ interior A then Belnap.true
  else if x ∈ interior Aᶜ then Belnap.false
  else Belnap.both

/-- **Frontier points are exactly the gluts.**  A point receives the Belnap glut
value `both` iff it lies on the topological frontier of `A`. -/
theorem val_both_iff_frontier {A : Set X} (x : X) :
    val A x = Belnap.both ↔ x ∈ frontier A := by
  have e1 : x ∈ interior A ↔ x ∉ closure Aᶜ := by rw [closure_compl]; simp
  have e2 : x ∈ interior Aᶜ ↔ x ∉ closure A := by rw [interior_compl]; simp
  unfold val
  rw [frontier_eq_closure_inter_closure, Set.mem_inter_iff]
  by_cases h1 : x ∈ interior A <;> by_cases h2 : x ∈ interior Aᶜ <;> simp_all

/-- The gluts of `val A` are exactly the points of the topological contradiction
set — fusing the Logic `glut_iff` with the Geometry `contradiction`. -/
theorem glut_iff_contradiction {A : Set X} (h : IsClosed A) (x : X) :
    val A x = Belnap.both ↔ x ∈ DreamTopo.contradiction A := by
  rw [val_both_iff_frontier, DreamTopo.contradiction_eq_frontier h]

/-- **Faithfulness.**  For a closed set, a point's value is designated iff the
point is in `A`: membership and acceptance agree. -/
theorem designated_iff_mem {A : Set X} (h : IsClosed A) (x : X) :
    Belnap.designated (val A x) ↔ x ∈ A := by
  have key : x ∈ interior Aᶜ ↔ x ∉ A := by
    rw [h.isOpen_compl.interior_eq]; simp
  unfold val
  by_cases h1 : x ∈ interior A
  · simp [h1, Belnap.designated]; exact interior_subset h1
  · by_cases h2 : x ∈ interior Aᶜ
    · simp only [h1, h2, if_false, if_true]
      simp [Belnap.designated]; exact key.mp h2
    · simp only [h1, h2, if_false]
      simp [Belnap.designated]
      by_contra hc
      exact h2 (key.mpr hc)

/-- A frontier point's value is a fixed point of paraconsistent negation. -/
theorem val_frontier_neg_fixed {A : Set X} {x : X} (hx : x ∈ frontier A) :
    Belnap.neg (val A x) = val A x := by
  rw [(val_both_iff_frontier x).2 hx]; rfl

/-- **Capstone (cross-domain).**  The concrete real dialetheia `0 ∈ [0,1]`
receives the Belnap glut value `both`; that value equals its own negation and is
an *accepted contradiction* (`designated (conj v (neg v))`).  One statement using
real analysis, the topological model (Geometry), and the Belnap algebra (Logic). -/
theorem dream_object_real_is_glut :
    val (Set.Icc (0 : ℝ) 1) 0 = Belnap.both ∧
    Belnap.neg (val (Set.Icc (0 : ℝ) 1) 0) = val (Set.Icc (0 : ℝ) 1) 0 ∧
    Belnap.designated
      (Belnap.conj (val (Set.Icc (0 : ℝ) 1) 0)
        (Belnap.neg (val (Set.Icc (0 : ℝ) 1) 0))) := by
  have hcl : IsClosed (Set.Icc (0 : ℝ) 1) := isClosed_Icc
  have hx : (0 : ℝ) ∈ DreamTopo.contradiction (Set.Icc (0 : ℝ) 1) :=
    DreamTopo.dream_object_real
  have hval : val (Set.Icc (0 : ℝ) 1) 0 = Belnap.both :=
    (glut_iff_contradiction hcl 0).2 hx
  refine ⟨hval, ?_, ?_⟩
  · rw [hval]; rfl
  · rw [hval]; exact (Belnap.glut_iff Belnap.both).2 rfl

end DreamLogic.Bridge