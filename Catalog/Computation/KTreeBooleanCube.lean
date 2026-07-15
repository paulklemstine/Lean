import Mathlib

/-!
# k-tree attachments are Boolean cubes

A simplicial `k`-tree is built by repeatedly attaching a fresh vertex along a
`k`-clique.  This file isolates the counting mechanism behind its linear face
complexity.  The faces created in one attachment are canonically indexed by the
Boolean cube (powerset) of the attaching clique.  Consequently every attachment
creates exactly `2^k` faces, converting a geometric elimination construction into
an additive counting recurrence.
-/

open Finset

namespace KTreeBooleanCube

variable {α : Type*} [DecidableEq α]

/-- Faces created by adjoining a fresh vertex `v` over every face of `σ`. -/
def coneFaces (v : α) (σ : Finset α) : Finset (Finset α) :=
  σ.powerset.image (fun τ => insert v τ)

/-
The Boolean-cube parametrization of new cone faces is injective when the apex
is fresh.
-/
theorem insert_apex_injective {v : α} {σ : Finset α} (hv : v ∉ σ) :
    Set.InjOn (fun τ : Finset α => insert v τ) (σ.powerset : Set (Finset α)) := by
  intro τ hτ;
  simp_all +decide [ Finset.ext_iff ];
  grind

/-
**Boolean cube bridge.** Attaching an apex over a `k`-face creates exactly
`2^k` new faces: one for every bit-vector/subset of the attaching face.
-/
theorem card_coneFaces {v : α} {σ : Finset α} (hv : v ∉ σ) :
    (coneFaces v σ).card = 2 ^ σ.card := by
  rw [ coneFaces, Finset.card_image_of_injOn ];
  · rw [ Finset.card_powerset ];
  · exact insert_apex_injective hv

/-
New cone faces are disjoint from every old face supported on the old ground
set, because each new face contains the fresh apex.
-/
theorem old_faces_disjoint_cone {v : α} {σ ground : Finset α}
    {K : Finset (Finset α)} (hv : v ∉ ground)
    (hK : ∀ τ ∈ K, τ ⊆ ground) : Disjoint K (coneFaces v σ) := by
  simp_all +decide [ Finset.disjoint_left, coneFaces ];
  grind

/-
One `k`-tree attachment increments the face count by exactly `2^k`.
-/
theorem card_attach_cone {v : α} {σ ground : Finset α}
    {K : Finset (Finset α)} (hσ : σ ⊆ ground) (hv : v ∉ ground)
    (hK : ∀ τ ∈ K, τ ⊆ ground) :
    (K ∪ coneFaces v σ).card = K.card + 2 ^ σ.card := by
  rw [ Finset.card_union_of_disjoint ];
  · rw [ card_coneFaces ( fun h => hv ( hσ h ) ) ];
  · grind +suggestions

/-- The additive recurrence obtained from Boolean-cube attachments.  Starting
with the full simplex on `k+1` vertices and making `steps` fresh `k`-attachments
gives the exact linear face count `2^(k+1) + steps * 2^k`. -/
def stackedFaceCount (k steps : ℕ) : ℕ := 2 ^ (k + 1) + steps * 2 ^ k

/-
In terms of the final vertex count `n = k+1+steps`, the exact count is
`2^k * (n-k+1)`.
-/
theorem stackedFaceCount_eq_linear (k steps : ℕ) :
    stackedFaceCount k steps = 2 ^ k * (steps + 2) := by
  unfold stackedFaceCount; ring;

/-
**Sharp linear witness bound.** The exact Boolean-cube count is bounded by
(and in fact improves) the proposed linear bound
`2^k (n-k) + (2^(k+1)-1)` for `n = k+1+steps`.
-/
theorem stackedFaceCount_le_proposed_bound (k steps : ℕ) :
    stackedFaceCount k steps ≤
      2 ^ k * (steps + 1) + (2 ^ (k + 1) - 1) := by
  zify [ stackedFaceCount_eq_linear ] ; ring_nf ; norm_num;
  linarith [ pow_pos ( by decide : 0 < 2 ) k ]

/-
For positive width the proposed bound has slack exactly `2^k-1`; the sharper
Boolean-cube count exposes the optimal constant furnished by the recursive
construction.
-/
theorem proposed_bound_sub_exact (k steps : ℕ) :
    (2 ^ k * (steps + 1) + (2 ^ (k + 1) - 1)) - stackedFaceCount k steps
      = 2 ^ k - 1 := by
  grind +locals

end KTreeBooleanCube