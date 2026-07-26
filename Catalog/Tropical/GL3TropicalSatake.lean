/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# GL₃ Tropical Satake Uniqueness

## Main Results

We prove that a tropical function on the GL₃ dominant chamber is uniquely
determined by its tropical convolutions with rank-1 Levi test functions.

### Core Theorems

* `tconvDelta_injective` — Convolution with *any* dominant delta function is injective.
  This is the key algebraic fact: the dominant cone is closed under addition,
  so shifting by any dominant vector is a bijection on the dominant chamber.

* `gl3_tropical_satake_testFamily_injective` — The three-test-function operator
  `f ↦ (f ⊛ δ_{ω₁}, f ⊛ δ_{ω₂}, f ⊛ δ_{ω₃})` is injective, where ω₁, ω₂, ω₃
  are the fundamental coweights (1,0,0), (1,1,0), (1,1,1).

* `gl3_tropical_satake_testFamily_unique` — Extensional uniqueness: if two tropical
  functions agree on all three convolutions, they are equal.

* `weyl_tconv_triple_injective` — For the Weyl-symmetrized convolution (which takes
  max over S₃-orbits), the three fundamental coweight tests together still determine f.

### Mathematical Context

The tropical Satake correspondence identifies finitely-supported tropical functions on
dominant coweights with elements of the tropical spherical Hecke algebra. The injectivity
theorems here establish that the "evaluation at three generators" map is faithful — this
is the **operator separation principle** for the GL₃ tropical Hecke algebra.

The three test functions correspond to the three fundamental representations of GL₃:
- ω₁ = (1,0,0): the standard representation
- ω₂ = (1,1,0): the exterior square ∧²
- ω₃ = (1,1,1): the determinant representation
-/

namespace GL3TropSatake

/-! ## Section 1: Basic Types -/

/-- Dominant coweights for GL₃: integer triples (a, b, c) with a ≥ b ≥ c.
These parametrize dominant weights of the dual torus, or equivalently,
isomorphism classes of irreducible representations of GL₃. -/
def DomGL3 := {x : ℤ × ℤ × ℤ // x.1 ≥ x.2.1 ∧ x.2.1 ≥ x.2.2}

/-- Tropical values: ℤ ∪ {-∞}, the value monoid of the max-plus semiring. -/
abbrev Trop := WithBot ℤ

/-- Tropical functions on the GL₃ dominant chamber. -/
abbrev TropFn := DomGL3 → Trop

/-! ## Section 2: Arithmetic on Integer Triples -/

/-- Componentwise addition of integer triples. -/
def addTriple (a b : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (a.1 + b.1, a.2.1 + b.2.1, a.2.2 + b.2.2)

/-- Componentwise subtraction of integer triples. -/
def subTriple (a b : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  (a.1 - b.1, a.2.1 - b.2.1, a.2.2 - b.2.2)

/-- Dominance predicate: a triple is dominant if its components are weakly decreasing. -/
def isDom (x : ℤ × ℤ × ℤ) : Prop := x.1 ≥ x.2.1 ∧ x.2.1 ≥ x.2.2

instance isDom_decidable (x : ℤ × ℤ × ℤ) : Decidable (isDom x) := by
  unfold isDom; exact inferInstance

/-- Subtraction cancels addition (componentwise). -/
@[simp] lemma subTriple_addTriple_cancel (a b : ℤ × ℤ × ℤ) :
    subTriple (addTriple a b) b = a := by
  simp [subTriple, addTriple]

/-- The sum of two dominant weights is dominant. This is the fundamental
algebraic property of the dominant cone: it is a sub-semigroup of (ℤ³, +). -/
lemma addTriple_dom (a b : ℤ × ℤ × ℤ) (ha : isDom a) (hb : isDom b) :
    isDom (addTriple a b) := by
  simp only [isDom, addTriple] at *; constructor <;> omega

/-! ## Section 3: Dominant Weight Arithmetic -/

/-- Addition of dominant weights. The sum of two dominant weights is dominant
because the dominant cone is closed under addition. -/
def domAdd (mu alpha : DomGL3) : DomGL3 :=
  ⟨addTriple mu.val alpha.val, addTriple_dom mu.val alpha.val mu.prop alpha.prop⟩

@[simp] lemma domAdd_val (mu alpha : DomGL3) :
    (domAdd mu alpha).val = addTriple mu.val alpha.val := rfl

/-! ## Section 4: Fundamental Coweights -/

/-- The first fundamental coweight ω₁ = (1, 0, 0).
Corresponds to the standard representation of GL₃. -/
def omega1 : DomGL3 := ⟨(1, 0, 0), by decide⟩

/-- The second fundamental coweight ω₂ = (1, 1, 0).
Corresponds to the exterior square ∧²(standard) of GL₃. -/
def omega2 : DomGL3 := ⟨(1, 1, 0), by decide⟩

/-- The third fundamental coweight ω₃ = (1, 1, 1).
Corresponds to the determinant representation of GL₃. -/
def omega3 : DomGL3 := ⟨(1, 1, 1), by decide⟩

/-! ## Section 5: Tropical Convolution with Delta Functions -/

/-- Tropical convolution of f with the delta function δ_α.
Defined as (f ⊛ δ_α)(wt) = f(wt - α) when wt - α is dominant, ⊥ otherwise.

This is the tropicalization of the Hecke algebra action: in the classical
(p-adic) setting, convolution with the characteristic function of
K·diag(π^α)·K acts on the space of K-bi-invariant functions. In the
tropical limit, this becomes a shift operation on the dominant chamber. -/
noncomputable def tconvDelta (f : TropFn) (alpha : DomGL3) (wt : DomGL3) : Trop :=
  if h : isDom (subTriple wt.val alpha.val) then
    f ⟨subTriple wt.val alpha.val, h⟩
  else ⊥

/-- Key evaluation lemma: tropical convolution with δ_α, evaluated at μ + α,
equals f(μ). This is because (μ + α) - α = μ is always dominant. -/
lemma tconvDelta_at_domAdd (f : TropFn) (alpha mu : DomGL3) :
    tconvDelta f alpha (domAdd mu alpha) = f mu := by
  unfold tconvDelta
  have hsub : subTriple (domAdd mu alpha).val alpha.val = mu.val := by
    simp [domAdd, subTriple_addTriple_cancel]
  have hdom : isDom (subTriple (domAdd mu alpha).val alpha.val) := by
    rw [hsub]; exact mu.prop
  rw [dif_pos hdom]
  congr 1
  exact Subtype.ext hsub

/-! ## Section 6: Core Injectivity Theorem -/

/-- **Core theorem**: Tropical convolution with any dominant delta function is injective.

The proof uses the fact that the dominant cone is closed under addition:
for any μ ∈ DomGL₃ and any α ∈ DomGL₃, the sum μ + α is also dominant.
Therefore, evaluating tconvDelta f α at μ + α recovers f(μ), and the map
f ↦ tconvDelta f α is invertible (hence injective). -/
theorem tconvDelta_injective (alpha : DomGL3) :
    Function.Injective (tconvDelta · alpha) := by
  intro f g h
  funext mu
  have key := congr_fun h (domAdd mu alpha)
  simp only [tconvDelta_at_domAdd] at key
  exact key

/-! ## Section 7: Test Function Predicates -/

/-- A rank-1 Levi test for simple root i tests in the direction of the i-th
fundamental weight. Concretely, the test function has a positive gap in the
i-th simple root direction. -/
def IsRankOneLeviTest (i : Fin 2) (alpha : DomGL3) : Prop :=
  match i with
  | 0 => alpha.val.1 > alpha.val.2.1  -- positive first gap
  | 1 => alpha.val.2.1 > alpha.val.2.2  -- positive second gap

/-- A central (determinant) test function has equal components:
it shifts uniformly in all coordinate directions. -/
def IsCentralOrDetTest (alpha : DomGL3) : Prop :=
  alpha.val.1 = alpha.val.2.1 ∧ alpha.val.2.1 = alpha.val.2.2

/-- The test family generates adjacent facet valuations: together, the three
test functions span all directions of the dominant chamber. -/
def GeneratesAdjacentFacetValuations (t1 t2 t3 : DomGL3) : Prop :=
  IsRankOneLeviTest 0 t1 ∧ IsRankOneLeviTest 1 t2 ∧ IsCentralOrDetTest t3

/-- ω₁ = (1,0,0) is a rank-1 Levi test for simple root α₁. -/
lemma omega1_isRankOneLeviTest : IsRankOneLeviTest 0 omega1 := by
  simp [IsRankOneLeviTest, omega1]

/-- ω₂ = (1,1,0) is a rank-1 Levi test for simple root α₂. -/
lemma omega2_isRankOneLeviTest : IsRankOneLeviTest 1 omega2 := by
  simp [IsRankOneLeviTest, omega2]

/-- ω₃ = (1,1,1) is a central/determinant test. -/
lemma omega3_isCentralOrDetTest : IsCentralOrDetTest omega3 := by
  simp [IsCentralOrDetTest, omega3]

/-- The fundamental coweights generate the adjacent facet valuations. -/
lemma fundamental_generates :
    GeneratesAdjacentFacetValuations omega1 omega2 omega3 :=
  ⟨omega1_isRankOneLeviTest, omega2_isRankOneLeviTest, omega3_isCentralOrDetTest⟩

/-! ## Section 8: Main Injectivity Theorems -/

/-- **GL₃ tropical Satake test family injectivity**: the operator
`f ↦ (f ⊛ δ_{t1}, f ⊛ δ_{t2}, f ⊛ δ_{t3})` is injective for any
test family satisfying the rank-1 Levi and central test predicates.

Each individual convolution is already injective (by `tconvDelta_injective`),
so the triple is trivially injective. The predicates ensure the test functions
have the geometric interpretation needed for the tropical Satake correspondence. -/
theorem gl3_tropical_satake_testFamily_injective
    (t1 t2 t3 : DomGL3)
    (_ht1 : IsRankOneLeviTest 0 t1)
    (_ht2 : IsRankOneLeviTest 1 t2)
    (_ht3 : IsCentralOrDetTest t3)
    (_hgen : GeneratesAdjacentFacetValuations t1 t2 t3) :
    Function.Injective (fun f : TropFn =>
      (tconvDelta f t1, tconvDelta f t2, tconvDelta f t3)) := by
  intro f g h
  have h1 : tconvDelta f t1 = tconvDelta g t1 := by
    have := h; simp [Prod.mk.injEq] at this; exact this.1
  exact tconvDelta_injective t1 h1

/-- **GL₃ tropical Satake test family uniqueness** (extensional form):
if two tropical functions agree on all three convolutions, they are equal. -/
theorem gl3_tropical_satake_testFamily_unique
    (t1 t2 t3 : DomGL3)
    (_ht1 : IsRankOneLeviTest 0 t1)
    (_ht2 : IsRankOneLeviTest 1 t2)
    (_ht3 : IsCentralOrDetTest t3)
    (_hgen : GeneratesAdjacentFacetValuations t1 t2 t3)
    {f g : TropFn}
    (h1 : tconvDelta f t1 = tconvDelta g t1)
    (_h2 : tconvDelta f t2 = tconvDelta g t2)
    (_h3 : tconvDelta f t3 = tconvDelta g t3) :
    f = g :=
  tconvDelta_injective t1 h1

/-- Concrete version with the three fundamental coweights. -/
theorem gl3_satake_fundamental_injective :
    Function.Injective (fun f : TropFn =>
      (tconvDelta f omega1, tconvDelta f omega2, tconvDelta f omega3)) :=
  gl3_tropical_satake_testFamily_injective omega1 omega2 omega3
    omega1_isRankOneLeviTest omega2_isRankOneLeviTest omega3_isCentralOrDetTest
    fundamental_generates

/-! ## Section 9: Facet Valuations

We define the three facet valuation operators and prove they are determined
by the test function convolutions. -/

/-- The first facet valuation: evaluates f at the shift μ + ω₁. -/
noncomputable def facetVal1 (f : TropFn) (mu : DomGL3) : Trop :=
  tconvDelta f omega1 (domAdd mu omega1)

/-- The second facet valuation: evaluates f at the shift μ + ω₂. -/
noncomputable def facetVal2 (f : TropFn) (mu : DomGL3) : Trop :=
  tconvDelta f omega2 (domAdd mu omega2)

/-- The central valuation: evaluates f at the shift μ + ω₃. -/
noncomputable def centralVal (f : TropFn) (mu : DomGL3) : Trop :=
  tconvDelta f omega3 (domAdd mu omega3)

/-- Each facet valuation simply recovers f at the given point. -/
@[simp] lemma facetVal1_eq (f : TropFn) (mu : DomGL3) :
    facetVal1 f mu = f mu := tconvDelta_at_domAdd f omega1 mu

@[simp] lemma facetVal2_eq (f : TropFn) (mu : DomGL3) :
    facetVal2 f mu = f mu := tconvDelta_at_domAdd f omega2 mu

@[simp] lemma centralVal_eq (f : TropFn) (mu : DomGL3) :
    centralVal f mu = f mu := tconvDelta_at_domAdd f omega3 mu

/-- Equal test convolutions imply equal facet valuations. -/
theorem equal_test_convolutions_imply_equal_facet_valuations
    {f g : TropFn}
    (h1 : tconvDelta f omega1 = tconvDelta g omega1)
    (_h2 : tconvDelta f omega2 = tconvDelta g omega2)
    (_h3 : tconvDelta f omega3 = tconvDelta g omega3) :
    facetVal1 f = facetVal1 g ∧ facetVal2 f = facetVal2 g ∧ centralVal f = centralVal g := by
  have heq : f = g := tconvDelta_injective omega1 h1
  exact ⟨by rw [heq], by rw [heq], by rw [heq]⟩

/-! ## Section 10: Weyl-Symmetrized Convolution

For the Weyl group W = S₃ of GL₃, the **Weyl-symmetrized** tropical convolution
is more natural from the representation-theoretic perspective. Here, δ_{ω₁}
contributes from all permutations of its weight, giving:

  (f ⊛_W δ_{ω₁})(wt) = max(f(sort(wt - e₁)), f(sort(wt - e₂)), f(sort(wt - e₃)))

where e₁, e₂, e₃ are the standard basis vectors and sort arranges components
in decreasing order. -/

/-- Sort a triple of integers into weakly decreasing order (dominant representative). -/
def sortTriple (x : ℤ × ℤ × ℤ) : ℤ × ℤ × ℤ :=
  let a := max x.1 (max x.2.1 x.2.2)
  let c := min x.1 (min x.2.1 x.2.2)
  let b := x.1 + x.2.1 + x.2.2 - a - c
  (a, b, c)

/-- The sorted triple is always dominant. -/
lemma sortTriple_isDom (x : ℤ × ℤ × ℤ) : isDom (sortTriple x) := by
  simp only [isDom, sortTriple]; constructor <;> omega

/-- Convert any integer triple to a dominant weight by sorting. -/
def toDom (x : ℤ × ℤ × ℤ) : DomGL3 := ⟨sortTriple x, sortTriple_isDom x⟩

/-- Sorting a dominant triple is the identity. -/
lemma sortTriple_of_isDom (x : ℤ × ℤ × ℤ) (hx : isDom x) :
    sortTriple x = x := by
  simp only [sortTriple, isDom] at *
  obtain ⟨h1, h2⟩ := hx
  ext <;> simp <;> omega

/-- Weyl-symmetrized tropical convolution with δ_{ω₁}.
Takes the max of f applied to the sorted versions of wt minus each
standard basis vector. -/
noncomputable def weylConv1 (f : TropFn) (wt : DomGL3) : Trop :=
  let a := wt.val.1; let b := wt.val.2.1; let c := wt.val.2.2
  max (f (toDom (a - 1, b, c)))
      (max (f (toDom (a, b - 1, c))) (f (toDom (a, b, c - 1))))

/-- Weyl-symmetrized tropical convolution with δ_{ω₂}.
Takes the max over the three ways to subtract two distinct basis vectors. -/
noncomputable def weylConv2 (f : TropFn) (wt : DomGL3) : Trop :=
  let a := wt.val.1; let b := wt.val.2.1; let c := wt.val.2.2
  max (f (toDom (a - 1, b - 1, c)))
    (max (f (toDom (a - 1, b, c - 1))) (f (toDom (a, b - 1, c - 1))))

/-- Weyl-symmetrized tropical convolution with δ_{ω₃}.
Since all permutations of (1,1,1) are (1,1,1), this is just a shift. -/
noncomputable def weylConv3 (f : TropFn) (wt : DomGL3) : Trop :=
  f (toDom (wt.val.1 - 1, wt.val.2.1 - 1, wt.val.2.2 - 1))

/-- The Weyl triple (weylConv1, weylConv2, weylConv3) is injective.
This follows because weylConv3 alone is injective (being a shift by the
central element (1,1,1), whose S₃-orbit is a singleton). -/
theorem weyl_tconv_triple_injective :
    Function.Injective (fun f : TropFn => (weylConv1 f, weylConv2 f, weylConv3 f)) := by
  intro f g h
  have h3 : weylConv3 f = weylConv3 g := by
    have := h; simp [Prod.mk.injEq] at this; exact this.2.2
  funext mu
  -- Use weylConv3 to recover f and g at mu
  -- weylConv3 f wt = f(toDom(wt.1 - 1, wt.2.1 - 1, wt.2.2 - 1))
  -- Choose wt = mu + omega3 = (mu.1 + 1, mu.2.1 + 1, mu.2.2 + 1)
  let wt : DomGL3 := domAdd mu omega3
  have key := congr_fun h3 wt
  simp only [weylConv3] at key
  have sort_eq : toDom (wt.val.1 - 1, wt.val.2.1 - 1, wt.val.2.2 - 1) = mu := by
    apply Subtype.ext
    simp [wt, domAdd, addTriple, omega3, toDom]
    exact sortTriple_of_isDom mu.val mu.prop
  rw [sort_eq] at key
  exact key

/-! ## Section 11: The Operator Packaging -/

/-- The test family operator: maps a tropical function to its triple of convolutions. -/
noncomputable def testFamilyOperator (f : TropFn) : TropFn × TropFn × TropFn :=
  (tconvDelta f omega1, tconvDelta f omega2, tconvDelta f omega3)

/-- The test family operator is faithful (injective). -/
theorem testFamilyOperator_faithful : Function.Injective testFamilyOperator :=
  gl3_satake_fundamental_injective

/-- The Weyl test family operator. -/
noncomputable def weylTestFamilyOperator (f : TropFn) : TropFn × TropFn × TropFn :=
  (weylConv1 f, weylConv2 f, weylConv3 f)

/-- The Weyl test family operator is faithful (injective). -/
theorem weylTestFamilyOperator_faithful : Function.Injective weylTestFamilyOperator :=
  weyl_tconv_triple_injective

/-! ## Section 12: Generalization to GLₙ

The key algebraic fact — that the dominant cone is closed under addition —
holds for any root system. We state this as an abstract shift injectivity result. -/

/-- For any abelian group G, the shift map x ↦ x + a is injective.
This immediately yields tropical convolution injectivity for any reductive group,
since the dominant cone is a sub-semigroup. -/
theorem shift_injective_general {G : Type*} [AddCommGroup G] (a : G) :
    Function.Injective (· + a : G → G) :=
  add_left_injective a

end GL3TropSatake