import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EREPRBridge

/-!
# Spacetime from entanglement: the full reconstruction theorem

`Novelty.EREPRBridge` reconstructs the *metric data* of a bulk geometry without
hidden cells from two-point entanglement, `w(u,v) = I(u:v)/2`
(`weight_eq_half_mutualInfo`, `bulk_weights_determined_by_mutualInfo`).  That is
a statement about edges.  Here the reconstruction is completed at the level of
the whole geometry:

* `cutWeight_congr_offDiag` — cut areas never see the diagonal of the weight
  matrix, so two geometries agreeing off the diagonal are indistinguishable;
* `entropy_eq_iff_mutualInfo_eq` — for models without hidden bulk cells, the
  *entire* entropy function of every boundary region is determined by, and
  determines, the family of two-point mutual informations.  This is the precise
  sense in which "spacetime emerges from entanglement": a single `V × V` table
  of pairwise entanglements fixes all `2^{|V|}` Ryu–Takayanagi areas;
* `bulkPath_congr_of_mutualInfo` — the *topology* of the emergent spacetime, the
  Einstein–Rosen connectivity relation `BulkPath`, is likewise fixed by the
  two-point data (self-loops, which entanglement cannot see, are also
  irrelevant to connectivity);
* `spacetime_from_entanglement` — the two statements packaged together.

Note that the diagonal weights `w(u,u)` are *not* determined: they are pure
gauge, invisible both to areas and to connectivity.  `weight_diag_is_gauge`
makes this precise, so the reconstruction theorem is sharp.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Cut areas ignore the diagonal -/

omit [DecidableEq V] in
/-- Two geometries whose weights agree away from the diagonal assign the same
area to every surface: the diagonal never contributes, because a cell is never
separated from itself. -/
theorem cutWeight_congr_offDiag (G H : BulkGraph V)
    (h : ∀ u v : V, u ≠ v → G.weight u v = H.weight u v) (f : Region V) :
    cutWeight G f = cutWeight H f := by
  simp only [cutWeight]
  congr 1
  refine Finset.sum_congr rfl fun u _ => Finset.sum_congr rfl fun v _ => ?_
  rcases eq_or_ne u v with rfl | huv
  · simp
  · rw [h u v huv]

/-- **Full reconstruction.**  For bulk geometries without hidden cells, the
two-point mutual informations determine — and are determined by — the entropies
of *all* boundary regions. -/
theorem entropy_eq_iff_mutualInfo_eq {M N : HoloModel V}
    (hM : NoBulk M) (hN : NoBulk N) :
    (∀ u v : V, mutualInfo M (single u) (single v)
        = mutualInfo N (single u) (single v))
      ↔ ∀ A : Region V, entropy M A = entropy N A := by
  constructor
  · intro h A
    rw [entropy_of_noBulk hM, entropy_of_noBulk hN]
    exact cutWeight_congr_offDiag _ _
      (bulk_weights_determined_by_mutualInfo hM hN h) A
  · intro h u v
    simp only [mutualInfo, h]

/-! ## The emergent topology is reconstructed too -/

omit [DecidableEq V] in
/-- Bulk connectivity only uses off-diagonal weights: a self-loop step never
takes a path anywhere new. -/
theorem bulkPath_congr_offDiag (G H : BulkGraph V)
    (h : ∀ u v : V, u ≠ v → G.weight u v = H.weight u v) (u v : V) :
    BulkPath G u v ↔ BulkPath H u v := by
  have key : ∀ (G H : BulkGraph V), (∀ u v : V, u ≠ v → G.weight u v = H.weight u v) →
      ∀ u v : V, BulkPath G u v → BulkPath H u v := by
    intro G H h u v hp
    induction hp with
    | refl => exact Relation.ReflTransGen.refl
    | tail _ hbc ih =>
        rename_i b c _
        rcases eq_or_ne b c with rfl | hbc'
        · exact ih
        · exact ih.tail (by simpa only [BulkAdj, ← h b c hbc'] using hbc)
  exact ⟨key G H h u v, key H G (fun a b hab => (h a b hab).symm) u v⟩

/-- **The Einstein–Rosen connectivity of the emergent spacetime is fixed by the
entanglement data.**  Two hidden-cell-free geometries with the same two-point
mutual informations have literally the same bridges. -/
theorem bulkPath_congr_of_mutualInfo {M N : HoloModel V}
    (hM : NoBulk M) (hN : NoBulk N)
    (h : ∀ u v : V, mutualInfo M (single u) (single v)
      = mutualInfo N (single u) (single v)) (u v : V) :
    BulkPath M.toBulkGraph u v ↔ BulkPath N.toBulkGraph u v :=
  bulkPath_congr_offDiag _ _ (bulk_weights_determined_by_mutualInfo hM hN h) u v

/-- **Spacetime from entanglement.**  For geometries without hidden bulk cells,
the table of two-point mutual informations determines the whole emergent
spacetime: every Ryu–Takayanagi area and the entire bridge (connectivity)
structure. -/
theorem spacetime_from_entanglement {M N : HoloModel V}
    (hM : NoBulk M) (hN : NoBulk N)
    (h : ∀ u v : V, mutualInfo M (single u) (single v)
      = mutualInfo N (single u) (single v)) :
    (∀ A : Region V, entropy M A = entropy N A) ∧
      (∀ u v : V, BulkPath M.toBulkGraph u v ↔ BulkPath N.toBulkGraph u v) :=
  ⟨(entropy_eq_iff_mutualInfo_eq hM hN).1 h, bulkPath_congr_of_mutualInfo hM hN h⟩

/-! ## Sharpness: the diagonal is pure gauge -/

/-- Re-weighting the self-loops of a geometry. -/
def reDiag (G : BulkGraph V) (d : V → ℝ) (hd : ∀ u, 0 ≤ d u) : BulkGraph V where
  weight u v := if u = v then d u else G.weight u v
  weight_symm u v := by
    rcases eq_or_ne u v with rfl | huv
    · simp
    · simp [huv, Ne.symm huv, G.weight_symm u v]
  weight_nonneg u v := by
    rcases eq_or_ne u v with rfl | huv
    · simpa using hd u
    · simpa [huv] using G.weight_nonneg u v

/-- **The diagonal weights are unobservable.**  Changing every self-loop of a
geometry leaves all areas and all bridges unchanged, so the reconstruction
theorem above is sharp: entanglement determines exactly the off-diagonal data,
and nothing is missing. -/
theorem weight_diag_is_gauge (G : BulkGraph V) (d : V → ℝ) (hd : ∀ u, 0 ≤ d u) :
    (∀ f : Region V, cutWeight (reDiag G d hd) f = cutWeight G f) ∧
      (∀ u v : V, BulkPath (reDiag G d hd) u v ↔ BulkPath G u v) := by
  have hoff : ∀ u v : V, u ≠ v → (reDiag G d hd).weight u v = G.weight u v := by
    intro u v huv; simp [reDiag, huv]
  exact ⟨fun f => cutWeight_congr_offDiag _ _ hoff f,
    bulkPath_congr_offDiag _ _ hoff⟩

/-- A concrete consequence: the emergent area of every region, and hence every
entanglement entropy, is a function of the mutual-information table alone.  In
particular a geometry with all self-loops removed produces exactly the same
physics. -/
theorem cutWeight_eq_of_diag_zero (G : BulkGraph V) :
    ∀ f : Region V,
      cutWeight (reDiag G (fun _ => 0) (fun _ => le_refl 0)) f = cutWeight G f :=
  (weight_diag_is_gauge G (fun _ => 0) (fun _ => le_refl 0)).1

end EmergentGeometry