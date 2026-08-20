import Probability.TalagrandDefs

/-!
# Weight-function representations of the convex distance

`Talagrand.IsRep` encodes a point of Talagrand's convex hull by an *indexed
family* of points of `A` together with convex weights.  For the inductive proof
of the concentration inequality it is far more convenient to index the convex
combination by the finite set `A` itself.  This file introduces that variant,
`Talagrand.IsRepW`, proves it equivalent to `Talagrand.IsRep`, and repackages
the basic `dTsq` API in terms of it.

## Main results

* `Talagrand.isRepW_iff_isRep` — the two encodings of the convex hull agree.
* `Talagrand.dTsq_le_of_isRepW` — a weight function bounds `dTsq` from above.
* `Talagrand.exists_isRepW_lt` — near-optimal weight representations exist.
-/

namespace Talagrand

open Finset

variable {α : Type*} [DecidableEq α] {n : ℕ}

/-- A convex combination of the Hamming indicator vectors of the points of `A`,
indexed by `A` itself: `w` is a probability weight on `A`. -/
def IsRepW (A : Finset (Fin n → α)) (x : Fin n → α) (v : Fin n → ℝ) : Prop :=
  ∃ w : (Fin n → α) → ℝ, (∀ z, 0 ≤ w z) ∧ (∑ z ∈ A, w z = 1) ∧
    ∀ i, v i = ∑ z ∈ A, w z * hamm (x i) (z i)

/-- A weight representation yields an indexed representation, by enumerating `A`. -/
lemma IsRepW.isRep {A : Finset (Fin n → α)} {x : Fin n → α} {v : Fin n → ℝ}
    (h : IsRepW A x v) : IsRep A x v := by
  obtain ⟨w, hw0, hw1, hv⟩ := h
  classical
  refine ⟨A.card, fun j => w ((A.equivFin.symm j : {z // z ∈ A}) : Fin n → α),
    fun j => ((A.equivFin.symm j : {z // z ∈ A}) : Fin n → α), fun j => hw0 _, ?_,
    fun j => (A.equivFin.symm j).2, fun i => ?_⟩
  · have h1 : ∑ j : Fin A.card, w ((A.equivFin.symm j : {z // z ∈ A}) : Fin n → α)
        = ∑ z : {z // z ∈ A}, w (z : Fin n → α) :=
      Equiv.sum_comp A.equivFin.symm (fun z : {z // z ∈ A} => w (z : Fin n → α))
    rw [h1, Finset.sum_coe_sort A w, hw1]
  · have h1 : ∑ j : Fin A.card,
        w ((A.equivFin.symm j : {z // z ∈ A}) : Fin n → α) *
          hamm (x i) (((A.equivFin.symm j : {z // z ∈ A}) : Fin n → α) i)
        = ∑ z : {z // z ∈ A}, w (z : Fin n → α) * hamm (x i) ((z : Fin n → α) i) :=
      Equiv.sum_comp A.equivFin.symm
        (fun z : {z // z ∈ A} => w (z : Fin n → α) * hamm (x i) ((z : Fin n → α) i))
    rw [h1, Finset.sum_coe_sort A (fun z => w z * hamm (x i) (z i))]
    exact hv i

/-- An indexed representation yields a weight representation, by pushing the
weights forward along the indexing map. -/
lemma IsRep.isRepW {A : Finset (Fin n → α)} {x : Fin n → α} {v : Fin n → ℝ}
    (h : IsRep A x v) : IsRepW A x v := by
  classical
  obtain ⟨k, c, y, hc0, hc1, hy, hv⟩ := h
  refine ⟨fun z => ∑ j ∈ Finset.univ.filter (fun j => y j = z), c j, fun z => ?_, ?_, fun i => ?_⟩
  · exact Finset.sum_nonneg fun j _ => hc0 j
  · rw [Finset.sum_fiberwise_of_maps_to (fun j _ => hy j) c]
    exact hc1
  · have hstep : ∀ z ∈ A,
        (∑ j ∈ Finset.univ.filter (fun j => y j = z), c j) * hamm (x i) (z i)
          = ∑ j ∈ Finset.univ.filter (fun j => y j = z), c j * hamm (x i) (y j i) := by
      intro z _
      rw [Finset.sum_mul]
      refine Finset.sum_congr rfl fun j hj => ?_
      have : y j = z := (Finset.mem_filter.mp hj).2
      rw [this]
    rw [Finset.sum_congr rfl hstep,
      Finset.sum_fiberwise_of_maps_to (fun j _ => hy j) (fun j => c j * hamm (x i) (y j i))]
    exact hv i

/-- The two encodings of Talagrand's convex hull agree. -/
theorem isRepW_iff_isRep {A : Finset (Fin n → α)} {x : Fin n → α} {v : Fin n → ℝ} :
    IsRepW A x v ↔ IsRep A x v :=
  ⟨IsRepW.isRep, IsRep.isRepW⟩

lemma dTsq_le_of_isRepW {A : Finset (Fin n → α)} {x : Fin n → α} {v : Fin n → ℝ}
    (h : IsRepW A x v) : dTsq A x ≤ sqn v :=
  dTsq_le_of_isRep h.isRep

/-- Near-optimal weight representations exist for nonempty `A`. -/
lemma exists_isRepW_lt {A : Finset (Fin n → α)} (hA : A.Nonempty) (x : Fin n → α)
    {ε : ℝ} (hε : 0 < ε) : ∃ v, IsRepW A x v ∧ sqn v < dTsq A x + ε := by
  obtain ⟨v, hv, hlt⟩ := exists_isRep_lt hA x hε
  exact ⟨v, hv.isRepW, hlt⟩

end Talagrand