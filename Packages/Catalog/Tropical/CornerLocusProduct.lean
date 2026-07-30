import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Data.Fintype.Basic

/-!
# Corner loci of min-plus products

A finite tropical polynomial is represented by its finite family of term values.
Its corner locus consists of points where the minimum is attained by at least two
terms.  The theorem below proves, without genericity assumptions, that the corner
locus of a tropical product is the union of the two corner loci.
-/

namespace Tropical

variable {X α I J : Type*}

/-- A term `i` is minimal at `x`. -/
def IsMin [Preorder α] (f : I → X → α) (x : X) (i : I) : Prop :=
  ∀ k, f i x ≤ f k x

/-- The minimum of the finite family of tropical terms is attained at least twice. -/
def IsCorner [Preorder α] (f : I → X → α) (x : X) : Prop :=
  ∃ i j, i ≠ j ∧ IsMin f x i ∧ IsMin f x j

/-- Terms of the min-plus product are pairwise sums of terms. -/
def productTerms [Add α] (f : I → X → α) (g : J → X → α) : I × J → X → α :=
  fun ij x ↦ f ij.1 x + g ij.2 x

section OrderedGroup

variable [AddCommGroup α] [PartialOrder α] [IsOrderedAddMonoid α]

/-- A minimal term of either factor gives minimal product terms when paired with
    a minimal term of the other factor. -/
theorem isMin_productTerms_iff (f : I → X → α) (g : J → X → α)
    (x : X) (i : I) (j : J) :
    IsMin (productTerms f g) x (i, j) ↔ IsMin f x i ∧ IsMin g x j := by
  constructor
  · intro h
    constructor
    · intro k
      have h' := h (k, j)
      simp only [productTerms] at h'
      rwa [add_le_add_iff_right] at h'
    · intro k
      have h' := h (i, k)
      simp only [productTerms] at h'
      rwa [add_le_add_iff_left] at h'
  · intro ⟨h₁, h₂⟩ (a, b)
    simp
    exact add_le_add (h₁ a) (h₂ b)

/-- Fundamental min-plus factorization law: the corner locus of a tropical
product is exactly the union of the corner loci of its factors. -/
theorem isCorner_productTerms_iff
    (f : I → X → α) (g : J → X → α) (x : X)
    (hf : ∃ i, IsMin f x i) (hg : ∃ j, IsMin g x j) :
    IsCorner (productTerms f g) x ↔ IsCorner f x ∨ IsCorner g x := by
  constructor
  · -- Forward: corner in product implies corner in f or g
    intro ⟨(i1, j1), (i2, j2), hij, hi1, hi2⟩
    rw [isMin_productTerms_iff] at hi1 hi2
    rcases eq_or_ne i1 i2 with rfl | hne
    · -- i1 = i2, so j1 ≠ j2
      right
      have hjne : j1 ≠ j2 := by contrapose! hij; simp [hij]
      exact ⟨j1, j2, hjne, hi1.2, hi2.2⟩
    · -- i1 ≠ i2
      left
      exact ⟨i1, i2, hne, hi1.1, hi2.1⟩
  · -- Backward: corner in f or g implies corner in product
    intro h
    rcases h with ⟨i1, i2, hne, hi1, hi2⟩ | ⟨j1, j2, hne, hj1, hj2⟩
    · -- IsCorner f x: use distinct i's with same j
      obtain ⟨j, hj⟩ := hg
      refine ⟨(i1, j), (i2, j), by simp [hne], ?_, ?_⟩ <;> intro k <;> simp [productTerms] <;> exact add_le_add (‹IsMin f x _› k.1) (hj k.2)
    · -- IsCorner g x: use distinct j's with same i
      obtain ⟨i, hi⟩ := hf
      refine ⟨(i, j1), (i, j2), by simp [hne], ?_, ?_⟩ <;> intro k <;> simp [productTerms] <;> exact add_le_add (hi k.1) (‹IsMin g x _› k.2)

/-- Set-valued form of the product/union theorem. -/
theorem cornerLocus_productTerms
    (f : I → X → α) (g : J → X → α)
    (hf : ∀ x, ∃ i, IsMin f x i) (hg : ∀ x, ∃ j, IsMin g x j) :
    {x | IsCorner (productTerms f g) x} = {x | IsCorner f x} ∪ {x | IsCorner g x} := by
  ext x
  simp only [Set.mem_setOf_eq, Set.mem_union]
  exact isCorner_productTerms_iff f g x (hf x) (hg x)

/-- Tropical scalar multiplication (adding the same function to every term)
    does not alter the corner locus. -/
theorem isCorner_add_common_iff (f : I → X → α) (c : X → α) (x : X) :
    IsCorner (fun i x ↦ f i x + c x) x ↔ IsCorner f x := by
  have isMin_add_common_iff (i : I) :
      IsMin (fun i x => f i x + c x) x i ↔ IsMin f x i := by
    unfold IsMin
    simp only [add_le_add_iff_right]
  unfold IsCorner
  refine ⟨fun ⟨i, j, hij, hi, hj⟩ => ⟨i, j, hij, (isMin_add_common_iff i).mp hi, (isMin_add_common_iff j).mp hj⟩,
          fun ⟨i, j, hij, hi, hj⟩ => ⟨i, j, hij, (isMin_add_common_iff i).mpr hi, (isMin_add_common_iff j).mpr hj⟩⟩

end OrderedGroup
end Tropical