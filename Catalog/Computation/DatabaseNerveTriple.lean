import Mathlib
import Computation.DatabaseNerveGeneral

/-!
# Triple overlaps: the obstruction drops to the cohomology of the 2-complex

`Catalog/Computation/DatabaseNerveGeneral.lean` computes the calibration
obstruction of a family of *pairwise* overlaps between data sources:
`dim H¹ = |ι| − |V| + c`, the first Betti number of the overlap graph.  This file
closes the graph-versus-complex half of conjecture **N1** of the previous cycle
by allowing *triple* overlaps, which turn on the second coboundary `d¹`.

A triple overlap of three sources `a, b, c` compared through overlaps `i : a—b`,
`j : b—c`, `l : a—c` imposes the cocycle relation `t i + t j = t l`: the offsets
measured along the two sides must agree with the offset measured along the
diagonal.  This is exactly `d¹ t = 0` for the coboundary `dTri`.

Main results.
* `dTri_comp_dNerve` — the triple-overlap relations are automatically satisfied
  by genuine recalibrations, so `d¹ ∘ d⁰ = 0` and `nerve2Complex` is a complex.
* `finrank_H1_nerve_triple` — the exact rank formula
  `dim H¹ + #sources + rank d¹ = #overlaps + #components`.
* `finrank_H1_nerve_triple_le` — hence `dim H¹ ≤ b₁(nerve graph)`, with equality
  iff `rank d¹ = 0`: **adding triple overlaps can only destroy obstructions,
  never create them.**
* `finrank_H1_filledTriangle = 0` versus
  `finrank_H1_openTriangle = 1` (`triple_overlap_kills_obstruction`) — filling in
  the triangle of a three-source cyclic comparison kills the holonomy obstruction
  found in `DatabaseHolonomy.lean`.  The cohomology really is that of the nerve
  *complex*, not of its 1-skeleton.

-- !-- Lab Notes -- !--
Hypothesis (N1): the graph Betti number is only an upper bound once triple
overlaps exist, and filling a triangle kills the cyclic obstruction.
Experiment: extend the calibration complex by `d¹ t = t i + t j − t l` over a
family of compatible triangles, then rerun the rank computation
`dim H¹ + rank d⁰ + rank d¹ = dim C¹` of `MissingDataCohomology.DataComplex`.
Analysis: `rank d⁰ = |V| − c` is unchanged by the extra layer, so every unit of
`rank d¹` removes one unit of `dim H¹`; the graph formula is the special case
`d¹ = 0`.  For the filled triangle `|ι| = |V| = 3`, `c = 1`, `rank d¹ = 1`, so
`dim H¹ = 3 + 1 − 3 − 1 = 0`, while the open triangle has `dim H¹ = 1`.
Critique: `dim H¹ ≤ b₁` holds with no compatibility hypothesis on the triangles
beyond `IsTriangle`, which is exactly what makes `d¹ ∘ d⁰ = 0`; without it the
"complex" is not a complex and the statement is vacuous, so the hypothesis is
load-bearing rather than cosmetic.
Synthesis: the obstruction to consistent calibration is the first cohomology of
the *nerve complex*; the previous cycle's Betti law is its 1-skeleton case, and
redundancy (extra overlaps) raises it while corroboration (triple overlaps
certifying transitivity) lowers it.
-- !-- Lab Notes -- !--
-/

namespace DatabaseNerveTriple

open DatabaseNerveGeneral MissingDataCohomology

variable (𝕜 : Type*) [Field 𝕜] {V ι σ : Type*}

/-! ### The 2-dimensional nerve complex -/

/-- The triple `(i, j, l)` of overlaps forms a triangle for the overlap family
`E`: `i` compares `a` with `b`, `j` compares `b` with `c`, and `l` compares `a`
with `c`. -/
def IsTriangle (E : ι → V × V) (t : ι × ι × ι) : Prop :=
  (E t.1).2 = (E t.2.1).1 ∧ (E t.1).1 = (E t.2.2).1 ∧ (E t.2.1).2 = (E t.2.2).2

/-- The second coboundary: on each triangle, the failure of the two measured
offsets to compose to the third. -/
def dTri (T : σ → ι × ι × ι) : (ι → 𝕜) →ₗ[𝕜] (σ → 𝕜) where
  toFun t := fun s => t (T s).1 + t (T s).2.1 - t (T s).2.2
  map_add' t u := by funext s; simp; ring
  map_smul' a t := by funext s; simp; ring

@[simp] lemma dTri_apply (T : σ → ι × ι × ι) (t : ι → 𝕜) (s : σ) :
    dTri 𝕜 T t s = t (T s).1 + t (T s).2.1 - t (T s).2.2 := rfl

/-- **Genuine recalibrations satisfy the triangle relations.** -/
lemma dTri_comp_dNerve (E : ι → V × V) (T : σ → ι × ι × ι)
    (hT : ∀ s, IsTriangle E (T s)) :
    (dTri 𝕜 T).comp (dNerve 𝕜 E) = 0 := by
  ext s x
  obtain ⟨h1, h2, h3⟩ := hT x
  simp only [LinearMap.comp_apply, dTri_apply, dNerve_apply, LinearMap.zero_apply,
    Pi.zero_apply]
  rw [h1, h2, h3]
  ring

/-- The calibration complex of a family of pairwise overlaps *together with* a
family of triple overlaps. -/
def nerve2Complex [Fintype V] [Fintype ι] [Fintype σ] (E : ι → V × V)
    (T : σ → ι × ι × ι) (hT : ∀ s, IsTriangle E (T s)) : DataComplex 𝕜 where
  C0 := V → 𝕜
  C1 := ι → 𝕜
  C2 := σ → 𝕜
  d0 := dNerve 𝕜 E
  d1 := dTri 𝕜 T
  d_sq := dTri_comp_dNerve 𝕜 E T hT

/-- **Rank formula with triple overlaps.** Every independent triangle relation
removes one dimension of obstruction. -/
theorem finrank_H1_nerve_triple [Fintype V] [Fintype ι] [Fintype σ] (E : ι → V × V)
    (T : σ → ι × ι × ι) (hT : ∀ s, IsTriangle E (T s)) :
    Module.finrank 𝕜 (nerve2Complex 𝕜 E T hT).H1 + Fintype.card V
        + Module.finrank 𝕜 (LinearMap.range (dTri 𝕜 (σ := σ) T))
      = Fintype.card ι + Nat.card (Comp E) := by
  have hform := (nerve2Complex 𝕜 E T hT).finrank_H1_formula
  have hC1 : Module.finrank 𝕜 (nerve2Complex 𝕜 E T hT).C1 = Fintype.card ι :=
    Module.finrank_fintype_fun_eq_card 𝕜
  have hC0 : Module.finrank 𝕜 (nerve2Complex 𝕜 E T hT).C0 = Fintype.card V :=
    Module.finrank_fintype_fun_eq_card 𝕜
  have hd1 : Module.finrank 𝕜 (LinearMap.range (nerve2Complex 𝕜 E T hT).d1)
      = Module.finrank 𝕜 (LinearMap.range (dTri 𝕜 (σ := σ) T)) := rfl
  have hrn := LinearMap.finrank_range_add_finrank_ker (nerve2Complex 𝕜 E T hT).d0
  have hker : Module.finrank 𝕜 (LinearMap.ker (nerve2Complex 𝕜 E T hT).d0)
      = Nat.card (Comp E) := finrank_ker_dNerve 𝕜 E
  omega

/-- **Triple overlaps can only destroy obstructions.** The graph Betti number of
the nerve is an upper bound for the calibration obstruction, attained exactly
when the triangle relations are vacuous (`rank d¹ = 0`). -/
theorem finrank_H1_nerve_triple_le [Fintype V] [Fintype ι] [Fintype σ] (E : ι → V × V)
    (T : σ → ι × ι × ι) (hT : ∀ s, IsTriangle E (T s)) :
    Module.finrank 𝕜 (nerve2Complex 𝕜 E T hT).H1 + Fintype.card V
      ≤ Fintype.card ι + Nat.card (Comp E) := by
  have h := finrank_H1_nerve_triple 𝕜 E T hT
  omega

/-! ### Three sources compared cyclically, with and without the triangle -/

/-- Three sources compared pairwise: `0—1`, `1—2` and `0—2`. -/
def triangleEdges : Fin 3 → Fin 3 × Fin 3
  | 0 => (0, 1)
  | 1 => (1, 2)
  | 2 => (0, 2)

/-- The single triple overlap of the three sources. -/
def triangleFaces : Fin 1 → Fin 3 × Fin 3 × Fin 3 := fun _ => (0, 1, 2)

lemma triangleFaces_isTriangle : ∀ s, IsTriangle triangleEdges (triangleFaces s) := by
  intro s
  fin_cases s
  exact ⟨rfl, rfl, rfl⟩

lemma triangleConnected : NerveConnected triangleEdges := by
  have h01 : (nerveSetoid triangleEdges).r 0 1 := Relation.EqvGen.rel _ _ ⟨0, rfl⟩
  have h12 : (nerveSetoid triangleEdges).r 1 2 := Relation.EqvGen.rel _ _ ⟨1, rfl⟩
  have h02 : (nerveSetoid triangleEdges).r 0 2 := Relation.EqvGen.rel _ _ ⟨2, rfl⟩
  intro a b
  fin_cases a <;> fin_cases b <;>
    first
      | exact Relation.EqvGen.refl _
      | exact h01
      | exact h12
      | exact h02
      | exact Relation.EqvGen.symm _ _ h01
      | exact Relation.EqvGen.symm _ _ h12
      | exact Relation.EqvGen.symm _ _ h02

/-- **The open triangle: a genuine obstruction.** Three sources compared
cyclically, with no triple overlap, carry a one-dimensional obstruction — the
holonomy of `DatabaseHolonomy.lean`. -/
theorem finrank_H1_openTriangle :
    Module.finrank 𝕜 (nerveComplex 𝕜 triangleEdges).H1 = 1 := by
  have h := finrank_H1_nerve_connected 𝕜 triangleEdges triangleConnected
  simp only [Fintype.card_fin] at h
  omega

/-- The triangle relation is a surjective constraint. -/
lemma dTri_triangle_surjective : Function.Surjective (dTri 𝕜 triangleFaces) := by
  intro y
  refine ⟨fun i => if i = 0 then y 0 else 0, ?_⟩
  funext s
  fin_cases s
  simp [triangleFaces]

lemma finrank_range_dTri_triangle :
    Module.finrank 𝕜 (LinearMap.range (dTri 𝕜 triangleFaces)) = 1 := by
  rw [LinearMap.range_eq_top.2 (dTri_triangle_surjective 𝕜)]
  simp

/-- **Filling in the triangle kills the obstruction.** Once the three sources
also share a common triple overlap — so that the transitivity of their pairwise
offsets is actually measured — every prescribed family of offsets satisfying the
triangle relation is realisable: `dim H¹ = 0`. -/
theorem finrank_H1_filledTriangle :
    Module.finrank 𝕜
        (nerve2Complex 𝕜 triangleEdges triangleFaces triangleFaces_isTriangle).H1 = 0 := by
  have h := finrank_H1_nerve_triple 𝕜 triangleEdges triangleFaces triangleFaces_isTriangle
  rw [finrank_range_dTri_triangle 𝕜] at h
  have hcomp : Nat.card (Comp triangleEdges) = 1 := card_comp_of_connected triangleConnected
  rw [hcomp] at h
  simp only [Fintype.card_fin] at h
  omega

/-- **The obstruction lives on the nerve complex, not on its 1-skeleton.** The
same three sources and the same three pairwise comparisons give
`dim H¹ = 1` without the triple overlap and `dim H¹ = 0` with it. -/
theorem triple_overlap_kills_obstruction :
    Module.finrank 𝕜 (nerveComplex 𝕜 triangleEdges).H1 = 1 ∧
      Module.finrank 𝕜
        (nerve2Complex 𝕜 triangleEdges triangleFaces triangleFaces_isTriangle).H1 = 0 :=
  ⟨finrank_H1_openTriangle 𝕜, finrank_H1_filledTriangle 𝕜⟩

end DatabaseNerveTriple