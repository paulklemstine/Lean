import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EREPRBridge

/-!
# The boundary of bulk reconstruction: entropies do not determine the geometry

`Novelty.EREPRBridge` proves that when *every* cell is a boundary cell the
emergent geometry is completely reconstructed from two-point mutual
informations, `w(u,v) = I(u:v)/2`.  This file shows that this reconstruction
theorem is *sharp*: as soon as one hidden bulk cell is allowed, the boundary
entanglement data no longer determines the bulk geometry.

Two explicit three-boundary geometries are compared:

* `starModel`     — a hidden bulk cell joined to each of the three boundary
  cells by a throat of area `1` (a "bulk vertex", the discrete analogue of a
  three-boundary wormhole);
* `triangleModel` — no hidden cell at all, the three boundary cells pairwise
  joined by throats of area `1/2`.

They have *identical* entanglement entropies for every boundary region
(`star_tri_same_entropy`), yet different geometries: in the star the boundary
cells are pairwise non-adjacent (`starModel_no_direct_edge`) while in the
triangle they are.  Consequently the reconstruction map from entanglement to
geometry is not injective in the presence of bulk cells
(`bulk_geometry_not_determined_by_entanglement`), although — by
`bridge_of_mutualInfo_pos` — *connectivity* is still forced: in the star model
the positive mutual information of two boundary cells is carried by a genuine
two-step Einstein–Rosen bridge through the hidden cell
(`starModel_bridge_through_bulk`).
-/

noncomputable section

namespace EmergentGeometry

open Finset

/-! ## A general one-bulk-cell reduction -/

variable {V : Type*} [Fintype V] [DecidableEq V]

/-- If exactly one cell `c` is hidden, the min-cut entropy is the minimum of
the two cut areas obtained by putting `c` inside or outside the region. -/
theorem entropy_single_bulk {M : HoloModel V} {c : V} (hc : M.bdry c = false)
    (hb : ∀ v, v ≠ c → M.bdry v = true) (A : Region V) :
    entropy M A = min (cutWeight M.toBulkGraph (Function.update A c false))
      (cutWeight M.toBulkGraph (Function.update A c true)) := by
  have hadm : ∀ b : Bool, Admissible M A (Function.update A c b) := by
    intro b v hv
    have hvc : v ≠ c := by
      intro h; rw [h, hc] at hv; exact Bool.noConfusion hv
    simp [Function.update_of_ne hvc]
  refine le_antisymm ?_ ?_
  · exact le_min (entropy_le_of_admissible (hadm false)) (entropy_le_of_admissible (hadm true))
  · obtain ⟨f, hf, hval⟩ := exists_minimal_surface M A
    have hfeq : f = Function.update A c (f c) := by
      funext v
      by_cases hvc : v = c
      · subst hvc; simp
      · rw [Function.update_of_ne hvc, hf v (hb v hvc)]
    rw [hval, hfeq]
    cases f c with
    | false => exact min_le_left _ _
    | true => exact min_le_right _ _

/-! ## The two competing three-boundary geometries -/

/-- Cells `0,1,2` are boundary cells, cell `3` is hidden. -/
def threeBdry : Region (Fin 4) := fun v => decide (v ≠ 3)

/-- A hidden bulk cell joined to each boundary cell by a throat of area `1`. -/
def starModel : HoloModel (Fin 4) where
  weight := fun i j => if i = j then 0 else if i = 3 ∨ j = 3 then 1 else 0
  weight_symm := by
    intro i j
    fin_cases i <;> fin_cases j <;> norm_num [Fin.ext_iff]
  weight_nonneg := by
    intro i j
    fin_cases i <;> fin_cases j <;> norm_num [Fin.ext_iff]
  bdry := threeBdry

/-- No hidden cell: the three boundary cells pairwise joined by area `1/2`. -/
def triangleModel : HoloModel (Fin 4) where
  weight := fun i j => if i = j then 0 else if i = 3 ∨ j = 3 then 0 else 1/2
  weight_symm := by
    intro i j
    fin_cases i <;> fin_cases j <;> norm_num [Fin.ext_iff]
  weight_nonneg := by
    intro i j
    fin_cases i <;> fin_cases j <;> norm_num [Fin.ext_iff]
  bdry := threeBdry

lemma threeBdry_three : threeBdry 3 = false := by decide

lemma threeBdry_ne_three : ∀ v : Fin 4, v ≠ 3 → threeBdry v = true := by decide

/-- Every boundary region of the two models has the same entropy: the two
geometries are entanglement-indistinguishable. -/
theorem star_tri_same_entropy (A : Region (Fin 4)) (hA : A 3 = false) :
    entropy starModel A = entropy triangleModel A := by
  rw [entropy_single_bulk (M := starModel) (c := 3) threeBdry_three threeBdry_ne_three A,
    entropy_single_bulk (M := triangleModel) (c := 3) threeBdry_three threeBdry_ne_three A]
  have hupd : Function.update A (3 : Fin 4) false = A := by
    funext v
    by_cases h : v = 3
    · subst h; simp [hA]
    · simp [Function.update_of_ne h]
  rw [hupd]
  cases h0 : A 0 <;> cases h1 : A 1 <;> cases h2 : A 2 <;>
    simp [cutWeight, Fin.sum_univ_four, sepBit, starModel, triangleModel,
      Function.update_apply, h0, h1, h2, hA] <;> norm_num

/-! ## The two geometries are genuinely different -/

/-- In the star geometry no two boundary cells are directly joined. -/
theorem starModel_no_direct_edge (i j : Fin 4) (hi : i ≠ 3) (hj : j ≠ 3) :
    starModel.weight i j = 0 := by
  simp [starModel, hi, hj]

/-- In the triangle geometry distinct boundary cells are directly joined. -/
theorem triangleModel_direct_edge (i j : Fin 4) (hij : i ≠ j) (hi : i ≠ 3) (hj : j ≠ 3) :
    triangleModel.weight i j = 1/2 := by
  simp [triangleModel, hij, hi, hj]

/-- **Sharpness of bulk reconstruction.**  There are two holographic models with
the same boundary, the same entanglement entropies for every boundary region,
and different bulk geometries.  Hence `weight_eq_half_mutualInfo` genuinely
requires the absence of hidden bulk cells. -/
theorem bulk_geometry_not_determined_by_entanglement :
    (∀ A : Region (Fin 4), A 3 = false → entropy starModel A = entropy triangleModel A) ∧
      starModel.weight 0 1 ≠ triangleModel.weight 0 1 := by
  refine ⟨fun A hA => star_tri_same_entropy A hA, ?_⟩
  rw [starModel_no_direct_edge 0 1 (by decide) (by decide),
    triangleModel_direct_edge 0 1 (by decide) (by decide) (by decide)]
  norm_num

/-! ## Entanglement without an edge: a genuine bridge through the bulk -/

/-- Closed formula for the entropies of the star geometry: a boundary region is
unentangled from its complement exactly when it is empty or everything. -/
theorem star_entropy_of_bits (A : Region (Fin 4)) (a b c : Bool)
    (h0 : A 0 = a) (h1 : A 1 = b) (h2 : A 2 = c) (hA : A 3 = false) :
    entropy starModel A = if a = b ∧ b = c then 0 else 1 := by
  rw [entropy_single_bulk (M := starModel) (c := 3) threeBdry_three threeBdry_ne_three]
  cases a <;> cases b <;> cases c <;>
    simp [cutWeight, Fin.sum_univ_four, sepBit, starModel,
      Function.update_apply, h0, h1, h2, hA] <;> norm_num

/-- Two boundary cells of the star geometry are entangled: their mutual
information equals `1`. -/
theorem starModel_mutualInfo_eq_one :
    mutualInfo starModel (single (0 : Fin 4)) (single (1 : Fin 4)) = 1 := by
  have e0 : entropy starModel (single (0 : Fin 4)) = 1 := by
    rw [star_entropy_of_bits (single (0 : Fin 4)) true false false (by decide) (by decide)
      (by decide) (by decide)]
    norm_num
  have e1 : entropy starModel (single (1 : Fin 4)) = 1 := by
    rw [star_entropy_of_bits (single (1 : Fin 4)) false true false (by decide) (by decide)
      (by decide) (by decide)]
    norm_num
  have e01 : entropy starModel
      (fun v => single (0 : Fin 4) v || single (1 : Fin 4) v) = 1 := by
    rw [star_entropy_of_bits (fun v => single (0 : Fin 4) v || single (1 : Fin 4) v)
      true true false (by decide) (by decide) (by decide) (by decide)]
    norm_num
  simp only [mutualInfo, e0, e1, e01]
  norm_num

/-- Two boundary cells of the star geometry are entangled. -/
theorem starModel_mutualInfo_pos :
    0 < mutualInfo starModel (single (0 : Fin 4)) (single (1 : Fin 4)) := by
  rw [starModel_mutualInfo_eq_one]
  norm_num

/-- Although they share no edge, the two entangled boundary cells of the star
geometry are joined by a two-step Einstein–Rosen bridge through the hidden bulk
cell — exactly as forced by `bridge_of_mutualInfo_pos`. -/
theorem starModel_bridge_through_bulk :
    BulkPath starModel.toBulkGraph 0 1 ∧
      ¬ BulkAdj starModel.toBulkGraph 0 1 := by
  constructor
  · exact Relation.ReflTransGen.tail
      (Relation.ReflTransGen.single (show (0:ℝ) < starModel.weight 0 3 by
        simp [starModel]))
      (show (0:ℝ) < starModel.weight 3 1 by simp [starModel])
  · intro hcon
    have : starModel.weight 0 1 = 0 := starModel_no_direct_edge 0 1 (by decide) (by decide)
    rw [BulkAdj, this] at hcon
    exact lt_irrefl 0 hcon

end EmergentGeometry