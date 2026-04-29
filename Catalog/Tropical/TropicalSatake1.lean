/-
# Tropical Satake Correspondence

This file establishes the tropical analog of the Satake isomorphism for GL_n,
connecting tropical symmetric functions to the structure of spherical Hecke algebras.

## Main Results

* `tropicalSatakeGL2_injective`: The tropical Satake map for GL₂ is injective
  on the dominant cone.

* `tropicalSatakeGL3_injective`: The tropical Satake map for GL₃ is injective
  on the dominant cone.

* `tropSymm1_invariant_GL2`, `tropSymm2_invariant_GL2`, etc.:
  Tropical elementary symmetric functions are invariant under the Weyl group action.

* `trop_e1_dominant_GL2`, `trop_e2_dominant_GL3`, etc.:
  On the dominant cone, tropical symmetric functions simplify to partial sums.

* `tropical_hecke_comm_GL2`: The tropical Hecke convolution for GL₂ is commutative.

* `tropDominanceGL2_antisymm`: The tropical dominance order is antisymmetric
  on dominant coweights.

## Mathematical Context

The classical Satake isomorphism identifies the spherical Hecke algebra
H(G(F)//G(O)) with the representation ring Rep(Ĝ) for a reductive group G
over a p-adic field F. In the tropical setting, we replace the polynomial ring
with the tropical semiring (ℤ, max, +), and the Satake isomorphism becomes
an injection from dominant coweights to tropical symmetric function values.

For GL_n, the Weyl group W = S_n acts on coweights ℤⁿ by permutation.
The tropical elementary symmetric function e_k(x₁,...,xₙ) is defined as
max over all k-element subsets S of Σ_{i∈S} xᵢ. On the dominant cone
{x₁ ≥ x₂ ≥ ... ≥ xₙ}, this simplifies to x₁ + x₂ + ... + x_k.

The map λ ↦ (e₁(λ), ..., eₙ(λ)) from the dominant cone to ℤⁿ is an injection,
which is the tropical analog of the Satake isomorphism.
-/

import Mathlib

open Finset

/-! ## Section 1: Tropical Elementary Symmetric Functions for GL₂ -/

/-- Tropical first elementary symmetric function for GL₂: e₁(a,b) = max(a,b) -/
def tropSymm1_GL2 (a b : ℤ) : ℤ := max a b

/-- Tropical second elementary symmetric function for GL₂: e₂(a,b) = a + b -/
def tropSymm2_GL2 (a b : ℤ) : ℤ := a + b

/-
On the dominant cone (a ≥ b), e₁ = a
-/
theorem trop_e1_dominant_GL2 (a b : ℤ) (h : a ≥ b) : tropSymm1_GL2 a b = a := by
  exact max_eq_left h

/-
e₁ is invariant under S₂ (swap)
-/
theorem tropSymm1_invariant_GL2 (a b : ℤ) : tropSymm1_GL2 a b = tropSymm1_GL2 b a := by
  exact max_comm a b

/-
e₂ is invariant under S₂ (swap)
-/
theorem tropSymm2_invariant_GL2 (a b : ℤ) : tropSymm2_GL2 a b = tropSymm2_GL2 b a := by
  exact add_comm _ _

/-! ## Section 2: Tropical Satake Map for GL₂ -/

/-- The dominant cone for GL₂: pairs (a,b) with a ≥ b -/
def DominantConeGL2 : Set (ℤ × ℤ) := {p | p.1 ≥ p.2}

/-- The tropical Satake map for GL₂: (a,b) ↦ (max(a,b), a+b) -/
def tropicalSatakeGL2 (p : ℤ × ℤ) : ℤ × ℤ :=
  (tropSymm1_GL2 p.1 p.2, tropSymm2_GL2 p.1 p.2)

/-
On the dominant cone, the Satake map simplifies to (a, a+b)
-/
theorem tropicalSatakeGL2_dominant (a b : ℤ) (h : a ≥ b) :
    tropicalSatakeGL2 (a, b) = (a, a + b) := by
  exact Prod.ext ( max_eq_left h ) rfl

/-
The tropical Satake map for GL₂ is injective on the dominant cone.
    This is the tropical analog of the fact that the Satake isomorphism
    separates spherical representations.
-/
theorem tropicalSatakeGL2_injective :
    Set.InjOn tropicalSatakeGL2 DominantConeGL2 := by
  intro p hp q hq;
  unfold DominantConeGL2 at hp hq;
  unfold tropicalSatakeGL2;
  unfold tropSymm1_GL2 tropSymm2_GL2;
  grind

/-
The image of the dominant cone under the GL₂ Satake map is characterized
    by the condition 2s₁ ≥ s₂ (which ensures the recovered weight is dominant).
-/
theorem tropicalSatakeGL2_image (s t : ℤ) :
    (∃ a b : ℤ, a ≥ b ∧ tropicalSatakeGL2 (a, b) = (s, t)) ↔ 2 * s ≥ t := by
  constructor;
  · unfold tropicalSatakeGL2;
    unfold tropSymm1_GL2 tropSymm2_GL2;
    grind;
  · intro h;
    unfold tropicalSatakeGL2;
    unfold tropSymm1_GL2 tropSymm2_GL2;
    exact ⟨ s, t - s, by linarith, by simp +decide [ max_eq_left ( by linarith : s ≥ t - s ) ] ⟩

/-! ## Section 3: Tropical Elementary Symmetric Functions for GL₃ -/

/-- Tropical first elementary symmetric function for GL₃: e₁(a,b,c) = max(a,b,c) -/
def tropSymm1_GL3 (a b c : ℤ) : ℤ := max (max a b) c

/-- Tropical second elementary symmetric function for GL₃:
    e₂(a,b,c) = max(a+b, a+c, b+c) -/
def tropSymm2_GL3 (a b c : ℤ) : ℤ := max (max (a + b) (a + c)) (b + c)

/-- Tropical third elementary symmetric function for GL₃: e₃(a,b,c) = a+b+c -/
def tropSymm3_GL3 (a b c : ℤ) : ℤ := a + b + c

/-
On the dominant cone (a ≥ b ≥ c), e₁ = a
-/
theorem trop_e1_dominant_GL3 (a b c : ℤ) (hab : a ≥ b) (hbc : b ≥ c) :
    tropSymm1_GL3 a b c = a := by
  unfold tropSymm1_GL3;
  grind

/-
On the dominant cone (a ≥ b ≥ c), e₂ = a + b
-/
theorem trop_e2_dominant_GL3 (a b c : ℤ) (hab : a ≥ b) (hbc : b ≥ c) :
    tropSymm2_GL3 a b c = a + b := by
  unfold tropSymm2_GL3; omega;

/-! ### S₃ Invariance of GL₃ Tropical Symmetric Functions -/

/-
e₁ for GL₃ is invariant under transposition of first two arguments
-/
theorem tropSymm1_GL3_swap12 (a b c : ℤ) :
    tropSymm1_GL3 a b c = tropSymm1_GL3 b a c := by
  unfold tropSymm1_GL3; ac_rfl;

/-
e₁ for GL₃ is invariant under cyclic permutation
-/
theorem tropSymm1_GL3_cycle (a b c : ℤ) :
    tropSymm1_GL3 a b c = tropSymm1_GL3 b c a := by
  unfold tropSymm1_GL3; ac_rfl;

/-
e₂ for GL₃ is invariant under transposition of first two arguments
-/
theorem tropSymm2_GL3_swap12 (a b c : ℤ) :
    tropSymm2_GL3 a b c = tropSymm2_GL3 b a c := by
  unfold tropSymm2_GL3;
  grind

/-
e₂ for GL₃ is invariant under cyclic permutation
-/
theorem tropSymm2_GL3_cycle (a b c : ℤ) :
    tropSymm2_GL3 a b c = tropSymm2_GL3 b c a := by
  unfold tropSymm2_GL3;
  grind

/-
e₃ for GL₃ is invariant under transposition of first two arguments
-/
theorem tropSymm3_GL3_swap12 (a b c : ℤ) :
    tropSymm3_GL3 a b c = tropSymm3_GL3 b a c := by
  unfold tropSymm3_GL3; ring;

/-
e₃ for GL₃ is invariant under cyclic permutation
-/
theorem tropSymm3_GL3_cycle (a b c : ℤ) :
    tropSymm3_GL3 a b c = tropSymm3_GL3 b c a := by
  unfold tropSymm3_GL3; ring;

/-! ## Section 4: Tropical Satake Map for GL₃ -/

/-- The dominant cone for GL₃: triples (a,b,c) with a ≥ b ≥ c -/
def DominantConeGL3 : Set (ℤ × ℤ × ℤ) := {p | p.1 ≥ p.2.1 ∧ p.2.1 ≥ p.2.2}

/-- The tropical Satake map for GL₃:
    (a,b,c) ↦ (max(a,b,c), max(a+b,a+c,b+c), a+b+c) -/
def tropicalSatakeGL3 (p : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (tropSymm1_GL3 p.1 p.2.1 p.2.2,
   tropSymm2_GL3 p.1 p.2.1 p.2.2,
   tropSymm3_GL3 p.1 p.2.1 p.2.2)

/-
On the dominant cone, the GL₃ Satake map simplifies to (a, a+b, a+b+c)
-/
theorem tropicalSatakeGL3_dominant (a b c : ℤ) (hab : a ≥ b) (hbc : b ≥ c) :
    tropicalSatakeGL3 (a, b, c) = (a, a + b, a + b + c) := by
  unfold tropicalSatakeGL3;
  unfold tropSymm1_GL3 tropSymm2_GL3 tropSymm3_GL3;
  grind

/-
The tropical Satake map for GL₃ is injective on the dominant cone.
    This is the tropical Satake isomorphism: dominant coweights are
    uniquely determined by their tropical symmetric function values.
-/
theorem tropicalSatakeGL3_injective :
    Set.InjOn tropicalSatakeGL3 DominantConeGL3 := by
  intros p hp q hq heq;
  unfold tropicalSatakeGL3 at heq;
  unfold tropSymm1_GL3 tropSymm2_GL3 tropSymm3_GL3 at heq;
  simp_all +decide [ Prod.ext_iff, DominantConeGL3 ];
  grind

/-! ## Section 5: Tropical Hecke Convolution for GL₂ -/

/-- Tropical Hecke convolution for GL₂.
    This models the convolution in the spherical Hecke algebra
    H(GL₂(F)//GL₂(O)) in the tropical semiring.

    For coweights λ = (a₁,a₂) and μ = (b₁,b₂), the tropical convolution
    produces the coweight (max(a₁,a₂)+max(b₁,b₂), min(a₁,a₂)+min(b₁,b₂)). -/
def tropHeckeConv_GL2 (p q : ℤ × ℤ) : ℤ × ℤ :=
  (max p.1 p.2 + max q.1 q.2, min p.1 p.2 + min q.1 q.2)

/-
Tropical Hecke convolution for GL₂ is commutative.
    This is a key structural property reflecting the commutativity of the
    spherical Hecke algebra, which in the classical setting follows from
    the Satake isomorphism.
-/
theorem tropical_hecke_comm_GL2 (p q : ℤ × ℤ) :
    tropHeckeConv_GL2 p q = tropHeckeConv_GL2 q p := by
  -- By definition of tropHeckeConv_GL2, we have:
  unfold tropHeckeConv_GL2;
  grind

/-
Tropical Hecke convolution on the dominant cone preserves dominance.
-/
theorem tropHeckeConv_GL2_dominant (p q : ℤ × ℤ)
    (hp : p.1 ≥ p.2) (hq : q.1 ≥ q.2) :
    (tropHeckeConv_GL2 p q).1 ≥ (tropHeckeConv_GL2 p q).2 := by
  unfold tropHeckeConv_GL2; simp +decide [ hp, hq ] ;
  grind

/-
On the dominant cone, tropical Hecke convolution is componentwise addition.
-/
theorem tropHeckeConv_GL2_dominant_eq (p q : ℤ × ℤ)
    (hp : p.1 ≥ p.2) (hq : q.1 ≥ q.2) :
    tropHeckeConv_GL2 p q = (p.1 + q.1, p.2 + q.2) := by
  unfold tropHeckeConv_GL2; simp +decide [ hp, hq ] ;

/-
The Satake map intertwines Hecke convolution with componentwise addition
    on the dominant cone: Satake(λ ⊛ μ) = Satake(λ) + Satake(μ) componentwise.
-/
theorem tropicalSatakeGL2_conv (p q : ℤ × ℤ)
    (hp : p.1 ≥ p.2) (hq : q.1 ≥ q.2) :
    tropicalSatakeGL2 (tropHeckeConv_GL2 p q) =
      ((tropicalSatakeGL2 p).1 + (tropicalSatakeGL2 q).1,
       (tropicalSatakeGL2 p).2 + (tropicalSatakeGL2 q).2) := by
  unfold tropicalSatakeGL2 tropHeckeConv_GL2;
  simp +decide [ *, tropSymm1_GL2, tropSymm2_GL2 ];
  constructor <;> linarith

/-! ## Section 6: Tropical Weyl Character Formula for GL₂ -/

/-- The tropical Weyl character value for GL₂ at a dominant weight (a,b) with a ≥ b,
    evaluated at a point (x,y). This is max over the Weyl orbit of the inner product:
    max(a*x + b*y, b*x + a*y). -/
def tropWeylChar_GL2 (a b x y : ℤ) : ℤ := max (a * x + b * y) (b * x + a * y)

/-
The tropical character is invariant under the Weyl group action on evaluation points
-/
theorem tropWeylChar_GL2_invariant (a b x y : ℤ) :
    tropWeylChar_GL2 a b x y = tropWeylChar_GL2 a b y x := by
  unfold tropWeylChar_GL2; ring_nf;
  exact max_comm _ _

/-
At the identity (evaluation at (0,0)), the tropical character is 0
    for any dominant weight
-/
theorem tropWeylChar_GL2_at_identity (a b : ℤ) :
    tropWeylChar_GL2 a b 0 0 = 0 := by
  unfold tropWeylChar_GL2; norm_num;

/-
The tropical character of the trivial representation (0,0) is always 0
-/
theorem tropWeylChar_GL2_trivial (x y : ℤ) :
    tropWeylChar_GL2 0 0 x y = 0 := by
  unfold tropWeylChar_GL2; norm_num;

/-
For the determinant representation (1,1), the tropical character equals x+y
-/
theorem tropWeylChar_GL2_det (x y : ℤ) :
    tropWeylChar_GL2 1 1 x y = x + y := by
  unfold tropWeylChar_GL2; ring_nf;
  grind

/-
For the standard representation (1,0), the tropical character is max(x,y)
-/
theorem tropWeylChar_GL2_std (x y : ℤ) :
    tropWeylChar_GL2 1 0 x y = max x y := by
  unfold tropWeylChar_GL2; ring_nf;

/-! ## Section 7: Tropical Plancherel Formula for GL₂ -/

/-- The tropical Plancherel measure for GL₂ assigns to each dominant weight
    λ = (a,b) with a ≥ b the value 2(a-b), which is the tropical analog of
    dim(π_λ)² / |G(𝔽_q)|. -/
def tropPlancherel_GL2 (a b : ℤ) : ℤ := 2 * (a - b)

/-
The tropical Plancherel measure is non-negative on the dominant cone
-/
theorem tropPlancherel_GL2_nonneg (a b : ℤ) (h : a ≥ b) :
    tropPlancherel_GL2 a b ≥ 0 := by
  exact mul_nonneg zero_le_two ( sub_nonneg_of_le h )

/-
The tropical Plancherel measure is zero exactly at the trivial weight modulo center
-/
theorem tropPlancherel_GL2_zero_iff (a b : ℤ) (h : a ≥ b) :
    tropPlancherel_GL2 a b = 0 ↔ a = b := by
  exact ⟨ fun h' => by unfold tropPlancherel_GL2 at h'; linarith, fun h' => by unfold tropPlancherel_GL2; linarith ⟩

/-! ## Section 8: Tropical Dominance Order -/

/-- The tropical dominance order: λ ≤_trop μ iff the partial sums of λ are ≤ those of μ.
    For GL₂, this means max(a₁,a₂) ≤ max(b₁,b₂) and a₁+a₂ ≤ b₁+b₂. -/
def tropDominanceGL2 (p q : ℤ × ℤ) : Prop :=
  max p.1 p.2 ≤ max q.1 q.2 ∧ p.1 + p.2 ≤ q.1 + q.2

/-
Tropical dominance is reflexive
-/
theorem tropDominanceGL2_refl (p : ℤ × ℤ) : tropDominanceGL2 p p := by
  exact ⟨ le_rfl, le_rfl ⟩

/-
Tropical dominance is transitive
-/
theorem tropDominanceGL2_trans (p q r : ℤ × ℤ)
    (hpq : tropDominanceGL2 p q) (hqr : tropDominanceGL2 q r) :
    tropDominanceGL2 p r := by
  constructor <;> linarith [ hpq.1, hpq.2, hqr.1, hqr.2 ]

/-
Tropical dominance is antisymmetric on the dominant cone:
    if two dominant coweights dominate each other, they are equal.
-/
theorem tropDominanceGL2_antisymm (p q : ℤ × ℤ)
    (hp : p.1 ≥ p.2) (hq : q.1 ≥ q.2)
    (hpq : tropDominanceGL2 p q) (hqp : tropDominanceGL2 q p) :
    p = q := by
  exact Prod.ext ( by cases hpq ; cases hqp ; cases max_cases p.1 p.2 <;> cases max_cases q.1 q.2 <;> linarith ) ( by cases hpq ; cases hqp ; cases max_cases p.1 p.2 <;> cases max_cases q.1 q.2 <;> linarith )