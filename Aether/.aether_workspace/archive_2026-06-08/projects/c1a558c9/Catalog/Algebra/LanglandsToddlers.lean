/-
# Langlands for Toddlers: The GL₁ Shape-Color Dictionary

This file formalizes the "toddler Langlands" correspondence: the bijection between
quadratic field discriminants ("shapes") and quadratic Dirichlet characters ("colors").

## Mathematical Context
The GL₁ Langlands correspondence (= class field theory) says that 1-dimensional
Galois representations correspond bijectively to Dirichlet characters. The simplest
case is *quadratic*: each quadratic extension Q(√d) corresponds to a unique quadratic
character χ_D, where D is the fundamental discriminant.

The Jacobi symbol J(D, ·) simultaneously encodes:
- The "shape" of primes in Q(√d): split, inert, or ramified
- The "color" χ_D(·): the associated Dirichlet character

## Main Results
1. `quadratic_char_sum_vanishes` — The sum of a non-trivial quadratic character over
   a finite field is zero. This is the "color orthogonality" principle.
2. `gauss_sum_sq_quadratic` — The Gauss sum of a quadratic character satisfies
   g(χ)² = χ(-1)·p. This is the "shape-color bridge."
3. `shape_color_duality` — Quadratic reciprocity as self-duality of the pairing.
4. `jacobi_bilinear_expansion` — Full bilinear expansion J(a₁a₂, b₁b₂).
5. `dict_neg4_ne_8_witness` — Concrete injectivity: distinct discriminants differ on
   specific primes.

## Novel Definitions
- `QuadraticShapeColorDict`: Structure encoding the GL₁ correspondence for a
  fundamental discriminant D, packaging the shape (discriminant) and color (character).
- `IsFundDiscriminant`: Formal definition of fundamental discriminants.

## Conjecture
- `gl1_completeness_conjecture`: The shape-color map is injective on fundamental
  discriminants, i.e., distinct discriminants yield distinct character functions.
-/

import Mathlib

open ZMod Finset Nat Int BigOperators

/-! ## Part 1: Fundamental Discriminants -/

/-- A **fundamental discriminant** is an integer D that arises as the discriminant
of a quadratic number field Q(√d). The classification is:
- D ≡ 1 (mod 4) and D is squarefree, OR
- D = 4m where m ≡ 2 or 3 (mod 4) and m is squarefree and m ≠ 0. -/
def IsFundDiscriminant (D : ℤ) : Prop :=
  (D % 4 = 1 ∧ Squarefree D) ∨
  (∃ m : ℤ, D = 4 * m ∧ Squarefree m ∧ ¬(m % 4 = 1) ∧ m ≠ 0)

/-- The discriminant of Q(√d) for squarefree d ≠ 0. -/
def fieldDiscriminant (d : ℤ) : ℤ :=
  if d % 4 = 1 then d else 4 * d

/-
Helper: -1 is squarefree as an integer.
-/
theorem int_neg_one_squarefree : Squarefree (-1 : ℤ) := by
  intro x hx;
  exact isUnit_of_dvd_one ( dvd_of_mul_left_dvd ( dvd_neg.mpr hx ) )

/-
Helper: 2 is squarefree as an integer.
-/
theorem int_two_squarefree : Squarefree (2 : ℤ) := by
  intro x hx; have := ( show x ≤ 1 by nlinarith [ Int.le_of_dvd ( by decide ) hx ] ) ; have := ( show x ≥ -1 by nlinarith [ Int.le_of_dvd ( by decide ) hx ] ) ; interval_cases x <;> trivial;

/-
Helper: 5 is squarefree as an integer.
-/
theorem int_five_squarefree : Squarefree (5 : ℤ) := by
  intro x hx; ( have : x ≤ 2 := Int.le_of_lt_add_one ( by nlinarith [ Int.le_of_dvd ( by decide ) hx ] ) ; ( have : x ≥ -2 := Int.le_of_lt_add_one ( by nlinarith [ Int.le_of_dvd ( by decide ) hx ] ) ; interval_cases x <;> trivial; ) )

/-
Helper: -3 is squarefree as an integer.
-/
theorem int_neg_three_squarefree : Squarefree (-3 : ℤ) := by
  intro x hx;
  have : x ∣ 3 := dvd_of_mul_left_dvd ( dvd_neg.mp hx ) ; have : x ≤ 3 := Int.le_of_dvd ( by decide ) this; have : x ≥ -3 := neg_le_of_abs_le ( Int.le_of_dvd ( by decide ) ( by simpa ) ) ; interval_cases x <;> trivial;

/-- Concrete verification: D = -4 is a fundamental discriminant (for Q(i)). -/
theorem neg_four_is_fund_disc : IsFundDiscriminant (-4) := by
  right; exact ⟨-1, by ring, int_neg_one_squarefree, by omega, by omega⟩

/-- Concrete verification: D = 8 is a fundamental discriminant (for Q(√2)). -/
theorem eight_is_fund_disc : IsFundDiscriminant 8 := by
  right; exact ⟨2, by ring, int_two_squarefree, by omega, by omega⟩

/-- Concrete verification: D = 5 is a fundamental discriminant (for Q(√5)). -/
theorem five_is_fund_disc : IsFundDiscriminant 5 := by
  left; exact ⟨by omega, int_five_squarefree⟩

/-- Concrete verification: D = -3 is a fundamental discriminant (for Q(√(-3))). -/
theorem neg_three_is_fund_disc : IsFundDiscriminant (-3) := by
  left; exact ⟨by omega, int_neg_three_squarefree⟩

/-! ## Part 2: Character Sum Vanishing — "Color Orthogonality" -/

/-- **Color Orthogonality**: The sum of a non-trivial multiplicative character over
a finite type is zero. This is the fundamental "orthogonality of colors" principle:
distinct colors cancel when mixed. -/
theorem mul_char_sum_vanishes {F : Type*} [CommMonoid F] [Fintype F]
    {R : Type*} [CommRing R] [IsDomain R]
    (χ : MulChar F R) (hχ : χ ≠ 1) :
    ∑ a : F, χ a = 0 :=
  MulChar.sum_eq_zero_of_ne_one hχ

/-- The quadratic character of a finite field of odd characteristic is non-trivial.
This is the "two-coloring" theorem: in odd characteristic, the nonzero elements
split into exactly two classes (squares and non-squares). -/
theorem quadratic_char_ne_one' {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (hF : ringChar F ≠ 2) :
    quadraticChar F ≠ 1 :=
  quadraticChar_ne_one hF

/-- **Quadratic Color Orthogonality**: The sum of the quadratic character over a finite
field of odd characteristic is zero. This says: among the elements of F,
the quadratic residues and non-residues exactly cancel. -/
theorem quadratic_char_sum_vanishes {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (hF : ringChar F ≠ 2) :
    ∑ a : F, quadraticChar F a = 0 :=
  mul_char_sum_vanishes _ (quadratic_char_ne_one' hF)

/-! ## Part 3: The Gauss Sum Bridge -/

/-- **The Gauss Sum Bridge**: For a non-trivial quadratic character χ of a finite
field F with primitive additive character ψ, we have g(χ)² = χ(-1) · |F|.

This is the central "bridge" between shapes and colors:
- The LEFT side (g(χ)²) involves the *additive* structure (shape/geometry)
- The RIGHT side (χ(-1) · |F|) involves the *multiplicative* structure (color/symmetry)
- The Gauss sum g(χ) = ∑ₐ χ(a)ψ(a) is the literal bridge between the two worlds.

The sign χ(-1) is the "twist" between shape and color. -/
theorem gauss_sum_sq_quadratic {F : Type*} [Field F] [Fintype F]
    {R : Type*} [CommRing R] [IsDomain R]
    (χ : MulChar F R) (hχ : χ ≠ 1) (hχ2 : χ.IsQuadratic)
    (ψ : AddChar F R) (hψ : ψ.IsPrimitive) :
    gaussSum χ ψ ^ 2 = χ (-1) * ↑(Fintype.card F) :=
  gaussSum_sq hχ hχ2 hψ

/-! ## Part 4: The Legendre-Jacobi Connection -/

/-- For a prime p, the Legendre symbol and Jacobi symbol agree. This connects the
"abstract" quadratic character to the "concrete" Jacobi symbol. -/
theorem legendre_eq_jacobi (p : ℕ) [hp : Fact (Nat.Prime p)] (a : ℤ) :
    legendreSym p a = jacobiSym a p :=
  jacobiSym.legendreSym.to_jacobiSym p a

/-! ## Part 5: Euler's Criterion — The Computational Engine -/

/-
**Euler's Criterion**: For a prime p > 2 and a ∈ (ℤ/pℤ)× with a ≠ 0,
the quadratic character χ(a) = a^((p-1)/2). This gives an explicit formula
for computing the "color" of any element.
-/
theorem euler_criterion_quadratic {p : ℕ} [Fact (Nat.Prime p)] (hp2 : p ≠ 2)
    (a : ZMod p) (ha : a ≠ 0) :
    (quadraticChar (ZMod p) a : ZMod p) = a ^ (p / 2) := by
      -- Since $a \neq 0$, we can apply Euler's criterion.
      have h_euler : a ^ ((p - 1) / 2) = quadraticChar (ZMod p) a := by
        have := @quadraticChar_eq_pow_of_char_ne_two;
        specialize this ( show ringChar ( ZMod p ) ≠ 2 from ?_ ) ha;
        · rw [ ZMod.ringChar_zmod_n ] ; aesop;
        · cases Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime p ) <;> simp_all +decide [ Nat.add_div ];
          rw [ show ( p - 1 ) / 2 = p / 2 by omega ] ; split_ifs <;> simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ] ;
          have h_order : a ^ (p - 1) = 1 := by
            exact ZMod.pow_card_sub_one_eq_one ha;
          exact Or.resolve_left ( eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ ← pow_mul', show 2 * ( p / 2 ) = p - 1 from by omega ] ; aesop ) ‹_›;
      convert h_euler.symm using 2 ; rcases Nat.even_or_odd' p with ⟨ c, rfl | rfl ⟩ <;> simp_all +decide [ Nat.add_div ] ; ring;
      exact absurd ( Nat.Prime.eq_two_or_odd ( Fact.out : Nat.Prime ( 2 * c ) ) ) ( by omega )

/-! ## Part 6: The Shape-Color Dictionary Structure -/

/-- The **Quadratic Shape-Color Dictionary** packages the GL₁ Langlands correspondence
for a single fundamental discriminant D:
- The "shape" is the discriminant D (encoding the quadratic field Q(√d))
- The "color" is the function n ↦ J(D, n) (encoding the Dirichlet character)

This structure captures the essence of "each shape has exactly one matching color." -/
structure QuadraticShapeColorDict where
  /-- The fundamental discriminant (the "shape") -/
  discriminant : ℤ
  /-- Proof that it is a fundamental discriminant -/
  is_fundamental : IsFundDiscriminant discriminant

namespace QuadraticShapeColorDict

/-- The character function: the "color" assigned to each natural number. -/
def colorFun (D : QuadraticShapeColorDict) (n : ℕ) : ℤ :=
  jacobiSym D.discriminant n

/-- The character is multiplicative: the color of a product is the product of colors. -/
theorem color_mult (D : QuadraticShapeColorDict) (b₁ b₂ : ℕ)
    (h₁ : b₁ ≠ 0) (h₂ : b₂ ≠ 0) :
    D.colorFun (b₁ * b₂) = D.colorFun b₁ * D.colorFun b₂ := by
  unfold colorFun
  haveI : NeZero b₁ := ⟨h₁⟩
  haveI : NeZero b₂ := ⟨h₂⟩
  exact jacobiSym.mul_right D.discriminant b₁ b₂

end QuadraticShapeColorDict

/-- The shape-color dictionary for D = -4 (the Gaussian integers Q(i)). -/
def gaussianDict : QuadraticShapeColorDict :=
  ⟨-4, neg_four_is_fund_disc⟩

/-- The shape-color dictionary for D = 8 (the field Q(√2)). -/
def sqrt2Dict : QuadraticShapeColorDict :=
  ⟨8, eight_is_fund_disc⟩

/-- The shape-color dictionary for D = 5 (the golden ratio field Q(√5)). -/
def goldenDict : QuadraticShapeColorDict :=
  ⟨5, five_is_fund_disc⟩

/-- The shape-color dictionary for D = -3 (the Eisenstein integers Q(ω)). -/
def eisensteinDict : QuadraticShapeColorDict :=
  ⟨-3, neg_three_is_fund_disc⟩

/-! ## Part 7: Shape-Color Duality (Quadratic Reciprocity) -/

/-- **Shape-Color Duality (Quadratic Reciprocity)**: For odd primes p, q, the
color of p in shape q equals the color of q in shape p, up to a sign correction.
The correction sign (-1)^((p-1)/2 · (q-1)/2) measures the "twist" between readings. -/
theorem shape_color_duality {p q : ℕ} [Fact (Nat.Prime p)] [Fact (Nat.Prime q)]
    (hp : p ≠ 2) (hq : q ≠ 2) (hpq : p ≠ q) :
    legendreSym q (↑p) * legendreSym p (↑q) = (-1) ^ (p / 2 * (q / 2)) :=
  legendreSym.quadratic_reciprocity hp hq hpq

/-! ## Part 8: Injectivity Witnesses -/

/-
D = -4 and D = 8 produce different characters at p = 5:
χ_{-4}(5) = 1 but χ_8(5) = -1. The prime 5 splits in Q(i) but is inert in Q(√2).
-/
theorem dict_neg4_ne_8_witness :
    gaussianDict.colorFun 5 ≠ sqrt2Dict.colorFun 5 := by
      native_decide

/-
D = 5 and D = -3 produce different characters at p = 7:
χ_5(7) = -1 but χ_{-3}(7) = 1. The prime 7 is inert in Q(√5) but splits in Q(√(-3)).
-/
theorem dict_5_ne_neg3_witness :
    goldenDict.colorFun 7 ≠ eisensteinDict.colorFun 7 := by
      native_decide

/-
D = -4 and D = 5 produce different characters at p = 11:
χ_{-4}(11) = -1 but χ_5(11) = 1.
-/
theorem dict_neg4_ne_5_witness :
    gaussianDict.colorFun 11 ≠ goldenDict.colorFun 11 := by
      native_decide

/-! ## Part 9: Full Bilinear Expansion -/

/-
**Full Bilinear Expansion**: The Jacobi symbol decomposes as
J(a₁·a₂, b₁·b₂) = J(a₁,b₁)·J(a₁,b₂)·J(a₂,b₁)·J(a₂,b₂).
This is the multiplicative bilinear expansion of the shape-color pairing.
-/
theorem jacobi_bilinear_expansion (a₁ a₂ : ℤ) (b₁ b₂ : ℕ)
    (hb₁ : b₁ ≠ 0) (hb₂ : b₂ ≠ 0) :
    jacobiSym (a₁ * a₂) (b₁ * b₂) =
    jacobiSym a₁ b₁ * jacobiSym a₁ b₂ * (jacobiSym a₂ b₁ * jacobiSym a₂ b₂) := by
      convert jacobiSym.mul_left a₁ a₂ ( b₁ * b₂ ) using 1;
      rw [ jacobiSym.mul_right', jacobiSym.mul_right' ]; all_goals assumption

/-! ## Part 10: Character Value Classification -/

/-
The quadratic character takes only values in {-1, 0, 1}.
-/
theorem quadratic_char_trichotomy {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (a : F) :
    quadraticChar F a = -1 ∨ quadraticChar F a = 0 ∨ quadraticChar F a = 1 := by
      grind +suggestions

/-
At nonzero elements, the quadratic character is ±1.
-/
theorem quadratic_char_unit_dichotomy {F : Type*} [Field F] [Fintype F] [DecidableEq F]
    (a : F) (ha : a ≠ 0) :
    quadraticChar F a = -1 ∨ quadraticChar F a = 1 := by
      obtain h | h | h := quadratic_char_trichotomy a <;> simp_all +decide [ quadraticCharFun ];
      grind

/-! ## Part 11: Specific Character Values -/

/-
χ_{-4}(3) = -1: the prime 3 is inert in Q(i).
-/
theorem chi_neg4_at_3 : jacobiSym (-4) 3 = -1 := by
  native_decide

/-
χ_8(3) = -1: the prime 3 is inert in Q(√2).
-/
theorem chi_8_at_3 : jacobiSym 8 3 = -1 := by
  native_decide

/-
χ_{-4}(5) = 1: the prime 5 splits in Q(i).
-/
theorem chi_neg4_at_5 : jacobiSym (-4) 5 = 1 := by
  native_decide

/-
χ_8(7) = 1: the prime 7 splits in Q(√2).
-/
theorem chi_8_at_7 : jacobiSym 8 7 = 1 := by
  native_decide +revert

/-
χ_5(3) = -1: the prime 3 is inert in Q(√5).
-/
theorem chi_5_at_3 : jacobiSym 5 3 = -1 := by
  native_decide +revert

/-
χ_{-3}(5) = -1: the prime 5 is inert in Q(√(-3)).
-/
theorem chi_neg3_at_5 : jacobiSym (-3) 5 = -1 := by
  native_decide +revert

/-! ## Part 12: Conjecture — GL₁ Completeness -/

/-- **Conjecture (GL₁ Shape-Color Injectivity)**: Distinct fundamental discriminants
produce distinct character functions. That is, if J(D₁, p) = J(D₂, p) for all
primes p, then D₁ = D₂.

This is the "injectivity half" of the GL₁ Langlands correspondence for quadratic
characters. The surjectivity half (every primitive quadratic character arises from
some fundamental discriminant) requires the theory of Hecke L-functions.

Testable prediction: For all pairs of fundamental discriminants D₁, D₂ with
|D₁|, |D₂| ≤ 1000 and D₁ ≠ D₂, there exists a prime p ≤ |D₁| · |D₂| with
J(D₁, p) ≠ J(D₂, p). -/
def gl1_shape_color_injectivity : Prop :=
  ∀ D₁ D₂ : ℤ,
    IsFundDiscriminant D₁ → IsFundDiscriminant D₂ →
    (∀ p : ℕ, Nat.Prime p → jacobiSym D₁ p = jacobiSym D₂ p) →
    D₁ = D₂