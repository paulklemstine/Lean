import Mathlib

/-!
# Langlands for GL₁: Shapes and Colors

## Overview

The Langlands program connects Galois representations ("shapes") to automorphic forms
("colors"). At GL₁, this is class field theory: one-dimensional Galois representations
correspond to Dirichlet characters.

For quadratic fields, the correspondence becomes concrete:
- **Shape**: A quadratic field ℚ(√d), determined by squarefree d ∈ ℤ
- **Color**: The Kronecker character χ_D = J(D, ·), a quadratic Dirichlet character
  where D = quadDisc(d) is the fundamental discriminant

## Main definitions

* `ShapeColorPairing` — abstract bijective correspondence (a "Langlands functor")
* `quadDisc` — fundamental discriminant of Q(√d) for squarefree d
* `ShapeColorPairing.tensorProduct` — product of two correspondences

## Main results

* `quadDisc_injective` — discriminant is injective: different shapes → different colors
* `jacobi_bimultiplicative` — the Jacobi symbol is a bilinear pairing,
    making the shape-color correspondence respect tensor products
* `shape_color_reciprocity_symmetric` — quadratic reciprocity gives a symmetry
    between the "shape view" J(a, b) and the "color view" J(b, a), up to a sign
* `shape_color_pairing_unique` — a shape-color pairing between finite types
    is unique (there is at most one bijection compatible with a given predicate)
-/

open Finset Function

/-! ## Abstract Shape-Color Correspondence -/

/-- A `ShapeColorPairing` is a bijective correspondence between "shapes"
(e.g., Galois representations) and "colors" (e.g., automorphic forms).
This is the core structure of any Langlands-type correspondence. -/
structure ShapeColorPairing (Shape : Type*) (Color : Type*) where
  /-- Map a shape to its corresponding color -/
  toColor : Shape → Color
  /-- Map a color back to its corresponding shape -/
  toShape : Color → Shape
  /-- Round-trip: shape → color → shape is identity -/
  shape_color_shape : ∀ s, toShape (toColor s) = s
  /-- Round-trip: color → shape → color is identity -/
  color_shape_color : ∀ c, toColor (toShape c) = c

namespace ShapeColorPairing

variable {S C : Type*}

/-- A shape-color pairing is an equivalence of types. -/
def toEquiv (p : ShapeColorPairing S C) : S ≃ C where
  toFun := p.toColor
  invFun := p.toShape
  left_inv := p.shape_color_shape
  right_inv := p.color_shape_color

/-- The toColor map of a shape-color pairing is injective. -/
theorem toColor_injective (p : ShapeColorPairing S C) : Injective p.toColor :=
  p.toEquiv.injective

/-- The toColor map of a shape-color pairing is surjective. -/
theorem toColor_surjective (p : ShapeColorPairing S C) : Surjective p.toColor :=
  p.toEquiv.surjective

/-- Product of two pairings: if shapes₁ ↔ colors₁ and shapes₂ ↔ colors₂,
    then (shapes₁ × shapes₂) ↔ (colors₁ × colors₂).
    This models the "tensor product" of Langlands correspondences. -/
def tensorProduct {S₁ C₁ S₂ C₂ : Type*}
    (p₁ : ShapeColorPairing S₁ C₁) (p₂ : ShapeColorPairing S₂ C₂) :
    ShapeColorPairing (S₁ × S₂) (C₁ × C₂) where
  toColor := fun ⟨s₁, s₂⟩ => ⟨p₁.toColor s₁, p₂.toColor s₂⟩
  toShape := fun ⟨c₁, c₂⟩ => ⟨p₁.toShape c₁, p₂.toShape c₂⟩
  shape_color_shape := fun ⟨s₁, s₂⟩ => by simp [p₁.shape_color_shape, p₂.shape_color_shape]
  color_shape_color := fun ⟨c₁, c₂⟩ => by simp [p₁.color_shape_color, p₂.color_shape_color]

/-
A shape-color pairing between finite types of equal cardinality
    is determined by its toColor map. Any other bijection with the same
    toColor must have the same toShape.
-/
theorem unique_inverse (p q : ShapeColorPairing S C)
    (h : p.toColor = q.toColor) : p.toShape = q.toShape := by
  -- Since p.toColor = q.toColor, we can apply the inverse function to both sides to get p.toShape = q.toShape.
  apply funext; intro c; exact (by
  obtain ⟨s, hs⟩ : ∃ s : S, p.toColor s = c := by
    exact ⟨ _, p.color_shape_color c ⟩;
  have := p.shape_color_shape s; have := q.shape_color_shape s; aesop;)

end ShapeColorPairing

/-! ## Quadratic Discriminant -/

/-- The fundamental discriminant of the quadratic field ℚ(√d).
    For squarefree d:
    - If d ≡ 1 (mod 4), the discriminant is d
    - Otherwise, the discriminant is 4d
    This is the "shape → color" map for the GL₁ Langlands correspondence. -/
def quadDisc (d : ℤ) : ℤ :=
  if d % 4 = 1 then d else 4 * d

/-
The discriminant map is injective: different squarefree integers
    give different fundamental discriminants.
    This is the key "each shape has a unique color" theorem.
-/
theorem quadDisc_injective : Injective quadDisc := by
  intro a b; unfold quadDisc; split_ifs <;> omega;

/-- When d ≡ 1 (mod 4), the discriminant equals d itself. -/
theorem quadDisc_of_one_mod_four {d : ℤ} (h : d % 4 = 1) :
    quadDisc d = d := by
  simp [quadDisc, h]

/-- When d ≢ 1 (mod 4), the discriminant equals 4d. -/
theorem quadDisc_of_not_one_mod_four {d : ℤ} (h : d % 4 ≠ 1) :
    quadDisc d = 4 * d := by
  simp [quadDisc, h]

/-! ## The Jacobi Symbol as a Bilinear Pairing

The Jacobi symbol J(a, n) is multiplicative in both arguments,
making it a "bilinear form" on ℤ × ℕ. This bilinearity is the
algebraic core of the shape-color correspondence: it means the
correspondence respects tensor products of representations.
-/

/-
**Bi-multiplicativity of the Jacobi symbol**: The Jacobi symbol
    decomposes as a product over all pairs of factors.
    J(a₁·a₂, b₁·b₂) = J(a₁,b₁) · J(a₁,b₂) · J(a₂,b₁) · J(a₂,b₂)

    This is the algebraic statement that the shape-color correspondence
    is a "bilinear pairing" — it respects tensor products on both sides.
    The proof combines left-multiplicativity and right-multiplicativity.
-/
theorem jacobi_bimultiplicative (a₁ a₂ : ℤ) (b₁ b₂ : ℕ) [NeZero b₁] [NeZero b₂] :
    jacobiSym (a₁ * a₂) (b₁ * b₂) =
      jacobiSym a₁ b₁ * jacobiSym a₁ b₂ * (jacobiSym a₂ b₁ * jacobiSym a₂ b₂) := by
  rw [ jacobiSym.mul_left, jacobiSym.mul_right, jacobiSym.mul_right ]

/-
The Jacobi symbol is quadratic: J(a, n)² ∈ {0, 1}.
    This says the "color" assigned to each shape is a square root of unity
    (or zero at ramified primes).
-/
theorem jacobi_sq_eq_zero_or_one (a : ℤ) (n : ℕ) :
    jacobiSym a n ^ 2 = 0 ∨ jacobiSym a n ^ 2 = 1 := by
  have h_trichotomy : jacobiSym a n = 0 ∨ jacobiSym a n = 1 ∨ jacobiSym a n = -1 := by
    exact jacobiSym.trichotomy a n
  rcases h_trichotomy with h | h | h <;> norm_num [ h ]

/-! ## Quadratic Reciprocity as Shape-Color Duality

Quadratic reciprocity says that the "shape view" of a prime
(how p looks from q's perspective) is almost the same as the "color view"
(how q looks from p's perspective), up to a sign correction.

This is the deepest symmetry in the GL₁ correspondence: shapes and colors
are nearly interchangeable perspectives.
-/

/-
**Shape-Color Reciprocity**: For coprime odd a, b, the Jacobi symbol
    satisfies J(a,b) · J(b,a) = (-1)^((a/2)·(b/2)).
    This is quadratic reciprocity reframed: the product of the
    "shape-to-color" and "color-to-shape" evaluations equals a
    computable sign.
    Coprimality ensures both symbols are ±1 (not 0).
-/
theorem shape_color_reciprocity (a b : ℕ) (ha : Odd a) (hb : Odd b)
    (hcop : Nat.Coprime a b) :
    jacobiSym (↑a) b * jacobiSym (↑b) a = (-1) ^ (a / 2 * (b / 2)) := by
  rw [ jacobiSym.quadratic_reciprocity ];
  · -- Since $a$ and $b$ are coprime and both odd, $jacobiSym (b : ℤ) a$ is either $1$ or $-1$.
    have h_jacobi : jacobiSym (b : ℤ) a = 1 ∨ jacobiSym (b : ℤ) a = -1 := by
      exact jacobiSym.eq_one_or_neg_one <| by simpa [ Nat.coprime_comm ] using hcop;
    cases h_jacobi <;> simp +decide [ * ];
  · assumption;
  · assumption

/-
The correction sign in reciprocity vanishes when either
    a or b is ≡ 1 (mod 4): the shape and color views agree perfectly.
    This is the "transparent" case of the correspondence.
-/
theorem reciprocity_transparent (a b : ℕ) (ha : Odd a) (hb : Odd b)
    (hcop : Nat.Coprime a b) (h1 : a % 4 = 1 ∨ b % 4 = 1) :
    jacobiSym (↑a) b * jacobiSym (↑b) a = 1 := by
  convert shape_color_reciprocity a b ha hb hcop using 1;
  rcases h1 with ( h | h ) <;> rw [ ← Nat.mod_add_div a 4, ← Nat.mod_add_div b 4 ] <;> norm_num [ Nat.even_div, h ]

/-! ## Conjecture: Non-vanishing of Quadratic Character Sums

The Langlands correspondence predicts that L-functions of automorphic
forms have analytic continuation and functional equation. For GL₁,
this means Dirichlet L-functions L(s, χ_D) should not vanish at s = 1
for non-trivial χ_D.

A consequence: the partial character sum ∑_{n=1}^{N} χ_D(n) should
be bounded but not eventually zero.
-/

/-
**Testable Conjecture**: For any odd prime p ≥ 3, the Jacobi symbol
    J(·, p) takes both values +1 and -1 among {1, ..., p-1}.
    This is a consequence of the non-triviality of the quadratic character.
    Equivalent to: the quadratic residues mod p are a proper subgroup.
-/
theorem quadratic_char_nontrivial (p : ℕ) [hp : Fact (Nat.Prime p)] (hodd : p ≠ 2) :
    ∃ a : ℤ, 1 ≤ a ∧ a < p ∧ jacobiSym a p = -1 := by
  -- Since $p$ is an odd prime, there exists a quadratic non-residue modulo $p$.
  obtain ⟨x, hx⟩ : ∃ x : ZMod p, ¬IsSquare x := by
    by_contra! h;
    -- If every element in ZMod p is a square, then the squaring map is surjective.
    have h_surjective : Function.Surjective (fun x : ZMod p => x^2) := by
      exact fun x => by obtain ⟨ y, rfl ⟩ := h x; exact ⟨ y, by ring ⟩ ;
    -- Since the squaring map is surjective, it must also be injective.
    have h_injective : Function.Injective (fun x : ZMod p => x^2) := by
      exact Finite.injective_iff_surjective.mpr h_surjective;
    have := @h_injective ( -1 ) 1 ; simp_all +decide;
    rw [ neg_eq_iff_add_eq_zero ] at this;
    rcases p with ( _ | _ | _ | p ) <;> cases this <;> contradiction;
  refine' ⟨ x.val, _, _, _ ⟩;
  · exact mod_cast Nat.pos_of_ne_zero fun h => hx <| by rw [ ZMod.val_eq_zero ] at h; aesop;
  · exact_mod_cast ZMod.val_lt x;
  · rw [ jacobiSym ];
    simp +decide [ Nat.primeFactorsList_prime hp.1, legendreSym ];
    rw [ quadraticCharFun ] ; aesop