import Mathlib

/-!
# The magma monoid as a transformation monoid

A formalization of the pairmorph viewpoint from Baiduk and Kozerenko,
*Transformation Semigroup Perspective on the Magma Monoid* (2026).
-/

namespace MagmaMonoid

/-- A binary operation on `X`. -/
abbrev Operation (X : Type*) := X → X → X

/-- The product of binary operations defining the magma monoid. -/
def product {X : Type*} (f g : Operation X) : Operation X :=
  fun a b ↦ g (f a b) (f b a)

/-- The left-zero operation, which is the identity of the magma monoid. -/
def leftZero {X : Type*} : Operation X := fun a _ ↦ a

/-- The right-zero operation. -/
def rightZero {X : Type*} : Operation X := fun _ b ↦ b

/-- Reversal of an ordered pair. -/
def swap {X : Type*} (p : X × X) : X × X := (p.2, p.1)

/-- The pairmorph transformation induced by a binary operation. -/
def pairmorph {X : Type*} (f : Operation X) : X × X → X × X :=
  fun p ↦ (f p.1 p.2, f p.2 p.1)

/-- Transformations that commute with reversal of ordered pairs. -/
def IsPairmorph {X : Type*} (T : X × X → X × X) : Prop :=
  Function.Commute T swap

/-- The image of the pairmorph transformation. -/
def pairImage {X : Type*} (f : Operation X) : Set (X × X) :=
  Set.range (pairmorph f)

/-- The image under the pairmorph transformation of diagonal pairs. -/
def diagonalImage {X : Type*} (f : Operation X) : Set (X × X) :=
  Set.range (fun x ↦ pairmorph f (x, x))

/-- Diagonal points occurring anywhere in the pairmorph image. -/
def commutativeImage {X : Type*} (f : Operation X) : Set (X × X) :=
  pairImage f ∩ Set.range (fun x ↦ (x, x))

/-- Regularity in the magma monoid. -/
def IsRegular {X : Type*} (f : Operation X) : Prop :=
  ∃ g : Operation X, product (product f g) f = f

/-- The magma product is associative. -/
theorem product_assoc {X : Type*} (f g h : Operation X) :
    product (product f g) h = product f (product g h) := by
  funext a b
  simp [product]

/-- The left-zero operation is a left identity. -/
theorem leftZero_product {X : Type*} (f : Operation X) :
    product leftZero f = f := by
  funext a b
  simp [product, leftZero]

/-- The left-zero operation is a right identity. -/
theorem product_leftZero {X : Type*} (f : Operation X) :
    product f leftZero = f := by
  funext a b
  simp [product, leftZero]

/-- Pairmorph converts the magma product into composition of transformations. -/
theorem pairmorph_product {X : Type*} (f g : Operation X) :
    pairmorph (product f g) = pairmorph g ∘ pairmorph f := by
  funext p
  simp [product, pairmorph]

/-- Every pairmorph transformation commutes with pair reversal. -/
theorem pairmorph_commutes {X : Type*} (f : Operation X) :
    IsPairmorph (pairmorph f) := by
  simp [IsPairmorph, Function.Commute, Function.Semiconj]
  intro a b
  rfl

/-- A transformation is induced by a binary operation exactly when it commutes with
pair reversal (Lemma 2 of the paper). -/
theorem exists_pairmorph_iff {X : Type*} (T : X × X → X × X) :
    (∃ f : Operation X, pairmorph f = T) ↔ IsPairmorph T := by
  constructor
  · intro ⟨f, hf⟩
    rw [hf.symm]
    exact pairmorph_commutes f
  · intro hT
    use fun a b => (T (a, b)).1
    funext p
    simp only [pairmorph]
    have h := hT p
    simp only [swap] at h
    rw [h]

/-- Pairmorph faithfully represents binary operations. -/
theorem pairmorph_injective {X : Type*} :
    Function.Injective (pairmorph : Operation X → (X × X → X × X)) := by
  intro f g hfg
  funext a b
  have h := congr_arg Prod.fst (congr_fun hfg (a, b))
  simpa [pairmorph] using h

/-- Idempotents are exactly the operations whose pairmorph fixes every point of its
image (Proposition 20 of the paper). -/
theorem product_self_eq_iff {X : Type*} (f : Operation X) :
    product f f = f ↔ ∀ p ∈ pairImage f, pairmorph f p = p := by
  constructor
  · intro h p hp
    obtain ⟨q, rfl⟩ := hp
    have : pairmorph f (pairmorph f q) = (pairmorph f ∘ pairmorph f) q := rfl
    rw [this, ← pairmorph_product, h]
  · intro h
    funext a b
    have hp : (f a b, f b a) ∈ pairImage f := ⟨(a, b), rfl⟩
    have hf := h (f a b, f b a) hp
    simp [pairmorph] at hf
    exact hf.1

/-- Every commutative, pointwise-idempotent operation is an idempotent of the magma
monoid (Proposition 21 of the paper). -/
theorem commutative_idempotent_is_magma_idempotent {X : Type*} (f : Operation X)
    (hcomm : ∀ a b, f a b = f b a) (hidem : ∀ a, f a a = a) :
    product f f = f := by
  funext a b
  simp [product, hcomm a b, hidem]

/-- For a magma-monoid idempotent, the diagonal image equals the diagonal part of
its full pairmorph image (Proposition 22 of the paper). -/
theorem commutativeImage_eq_diagonalImage_of_idempotent {X : Type*}
    (f : Operation X) (h : product f f = f) :
    commutativeImage f = diagonalImage f := by
  ext ⟨x, y⟩
  simp [commutativeImage, diagonalImage, pairImage, pairmorph]
  constructor
  · rintro ⟨⟨a, b, hab, hba⟩, rfl⟩
    have hidem : f (f a b) (f b a) = f a b := by
      have hx : product f f a b = f a b := congr_fun (congr_fun h a) b
      simpa [product] using hx
    rw [hab, hba] at hidem
    exact ⟨x, hidem, hidem⟩
  · rintro ⟨z, hz⟩
    exact ⟨⟨z, z, hz.1, hz.2⟩, hz.1.symm.trans hz.2⟩

/-- Regularity forces every diagonal point in the full pairmorph image to already
occur as the image of a diagonal input (the forward implication of Proposition 24). -/
theorem commutativeImage_eq_diagonalImage_of_regular {X : Type*}
    (f : Operation X) (h : IsRegular f) :
    commutativeImage f = diagonalImage f := by
  obtain ⟨g, hreg⟩ := h
  ext ⟨x, y⟩
  simp [commutativeImage, diagonalImage, pairImage, pairmorph]
  constructor
  · rintro ⟨⟨a, b, hab, hba⟩, rfl⟩
    have hx : f (g x x) (g x x) = x := by
      have heq : product (product f g) f a b = f a b :=
        congr_fun (congr_fun hreg a) b
      simpa [product, hab, hba] using heq
    exact ⟨g x x, hx, hx⟩
  · rintro ⟨z, hz⟩
    exact ⟨⟨z, z, hz.1, hz.2⟩, hz.1.symm.trans hz.2⟩

/-- Reversing the arguments of an operation. -/
def opposite {X : Type*} (f : Operation X) : Operation X :=
  fun a b ↦ f b a

/-- Multiplication by the right-zero operation on the right reverses arguments. -/
theorem product_rightZero {X : Type*} (f : Operation X) :
    product f rightZero = opposite f := by
  funext a b
  rfl

/-- Multiplication by the right-zero operation on the left reverses arguments. -/
theorem rightZero_product {X : Type*} (f : Operation X) :
    product rightZero f = opposite f := by
  funext a b
  rfl

/-- The right-zero operation commutes with every element of the magma monoid. -/
theorem rightZero_commutes {X : Type*} (f : Operation X) :
    product rightZero f = product f rightZero := by
  rw [rightZero_product, product_rightZero]

/-- The left-zero identity commutes with every element of the magma monoid. -/
theorem leftZero_commutes {X : Type*} (f : Operation X) :
    product leftZero f = product f leftZero := by
  rw [leftZero_product, product_leftZero]

/-- The right-zero operation is an involutive unit: its square is the identity. -/
theorem rightZero_square {X : Type*} :
    product (rightZero : Operation X) rightZero = leftZero := by
  funext a b
  rfl

/-- The right-zero operation is regular. -/
theorem rightZero_regular {X : Type*} :
    IsRegular (rightZero : Operation X) := by
  refine ⟨rightZero, ?_⟩
  rw [rightZero_square, leftZero_product]

end MagmaMonoid