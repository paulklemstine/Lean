import Mathlib

/-!
# Direction 4: Topological Collapse — Retractions and Deformation Retracts
-/

open Set Function

/-- A retraction onto a subset. -/
structure Retraction' (α : Type*) (S : Set α) where
  map : α → α
  maps_into : ∀ x, map x ∈ S
  fixes_S : ∀ x ∈ S, map x = x

/-- Every retraction is idempotent. -/
theorem retraction_idempotent' {α : Type*} {S : Set α} (r : Retraction' α S) :
    ∀ x, r.map (r.map x) = r.map x :=
  fun x => r.fixes_S (r.map x) (r.maps_into x)

/-- Image of retraction = target. -/
theorem retraction_range' {α : Type*} {S : Set α} (r : Retraction' α S) :
    range r.map = S := by
  ext x; simp only [mem_range]
  constructor
  · rintro ⟨y, rfl⟩; exact r.maps_into y
  · intro hx; exact ⟨x, r.fixes_S x hx⟩

/-
PROBLEM
Idempotent on Fin(n+1) with n-element image has one non-fixed point.

PROVIDED SOLUTION
f idempotent on Fin(n+1) with image of size n. The fixed points are exactly the image (since f(f(x))=f(x) means every image point is fixed). So |fixed points| = n. Since |Fin(n+1)| = n+1, there is exactly one non-fixed point. Use Finset.card_compl or similar counting argument.
-/
theorem idempotent_almost_identity' {n : ℕ} (f : Fin (n+1) → Fin (n+1))
    (hf : ∀ x, f (f x) = f x)
    (h_image : Finset.card (Finset.image f Finset.univ) = n)
    (hn : 0 < n) :
    ∃! x : Fin (n+1), f x ≠ x := by
      -- The set of fixed points of $f$ is exactly the image of $f$.
      have h_fixed_points : Finset.filter (fun x => f x = x) Finset.univ = Finset.image f Finset.univ := by
        ext x; aesop;
      -- Since the image of $f$ has $n$ elements and there are $n+1$ points in total, there must be exactly one point not in the image.
      have h_not_fixed_points : (Finset.univ \ Finset.image f Finset.univ).card = 1 := by
        simp +decide [ Finset.card_sdiff, * ];
      obtain ⟨ x, hx ⟩ := Finset.card_eq_one.mp h_not_fixed_points; use x; simp_all +decide [ Finset.ext_iff ] ;

/-- An idempotent is the identity on its image. -/
theorem collapse_is_id_on_image {α : Type*} (f : α → α) (hf : ∀ x, f (f x) = f x) :
    ∀ x ∈ range f, f x = x := by
  rintro x ⟨y, rfl⟩; exact hf y

/-- The fiber of a map over a point. -/
def retraction_fiber' {α : Type*} (f : α → α) (y : α) : Set α := {x | f x = y}

/-- Every element is in its fiber. -/
theorem fiber_partition' {α : Type*} (f : α → α) :
    ∀ x, x ∈ retraction_fiber' f (f x) := fun _ => rfl

/-- Fixed points are in their own fiber. -/
theorem fixed_point_in_fiber' {α : Type*} (f : α → α)
    (y : α) (hy : f y = y) : y ∈ retraction_fiber' f y := hy