/-
# A finite labelled projection inequality

This is the two-coordinate finite form of the projection-counting principle
used in Shearer-type arguments.  Unlike an unlabelled union estimate, each
object retains both coordinate labels, and the coordinate map is injective.
-/
import Mathlib

namespace EndpointCubeSkeleta

open Finset

/-- A finite set of labelled pairs has cardinality at most the product of the
cardinalities of its two coordinate projections. -/
theorem card_le_mul_projection_cards
    {α β : Type*} [DecidableEq α] [DecidableEq β] (s : Finset (α × β)) :
    s.card ≤ (s.image Prod.fst).card * (s.image Prod.snd).card := by
  have h : s ⊆ (s.image Prod.fst) ×ˢ (s.image Prod.snd) := by
    intro ⟨a, b⟩ hab
    simp [Finset.mem_image]; exact ⟨⟨b, hab⟩, ⟨a, hab⟩⟩
  calc s.card ≤ ((s.image Prod.fst) ×ˢ (s.image Prod.snd)).card := card_le_card h
    _ = (s.image Prod.fst).card * (s.image Prod.snd).card := card_product _ _

/-- Functional labelled form: if two labels jointly distinguish all objects,
then their number is bounded by the product of the two label alphabets. -/
theorem card_le_mul_label_ranges
    {ι α β : Type*} [DecidableEq ι] [DecidableEq α] [DecidableEq β]
    (objects : Finset ι) (left : ι → α) (right : ι → β)
    (hinj : Set.InjOn (fun x => (left x, right x)) (↑objects : Set ι)) :
    objects.card ≤ (objects.image left).card * (objects.image right).card := by
  let labels := objects.image (fun x => (left x, right x))
  have hcard : labels.card = objects.card :=
    (Finset.card_image_iff.mpr hinj)
  have hproj := card_le_mul_projection_cards labels
  have hleft : labels.image Prod.fst = objects.image left := by
    ext a
    simp [labels]
  have hright : labels.image Prod.snd = objects.image right := by
    ext b
    simp [labels]
  simpa [hcard, hleft, hright] using hproj

/-- The product dependence cannot in general be replaced by the larger of the
two projection sizes: the full `2 × 2` relation has four labelled objects but
both projections have only two values. -/
theorem max_projection_bound_counterexample :
    let s : Finset (Fin 2 × Fin 2) := Finset.univ
    max (s.image Prod.fst).card (s.image Prod.snd).card < s.card := by
  native_decide

end EndpointCubeSkeleta