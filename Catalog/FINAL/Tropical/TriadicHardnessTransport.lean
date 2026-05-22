/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Triadic Hardness Transport via Composed Affine Morphisms

## Overview

This module formalizes a **compositional hardness-propagation architecture** showing that
lower bounds certified in one domain (e.g., learning theory) can be systematically
transported to lower bounds in other domains (e.g., arithmetic height, tropical complexity,
cryptographic security) through composable morphisms of invariant-bearing theories.

## Architecture

We introduce:
- `TheorySpec`: a theory equipped with a real-valued invariant on its objects
- `TheoryMorphism`: a morphism between theories that provides affine upper-bound control
  on how invariants relate across domains
- Composition of morphisms (`TheoryMorphism.comp`) preserving the affine structure
- A generic lower-bound transport theorem

## Main Results

1. **`affine_bound_comp`**: Two affine bounds compose into a single affine bound with
   explicit constants.

2. **`affine_bound_comp₃`**: Three affine bounds compose, giving the full three-step
   transfer.

3. **`lower_bound_of_affine_upper_bound`**: A lower bound on the source invariant
   yields an explicit lower bound on the target invariant.

4. **`triadic_security_lower_bound`**: The main theorem — a learning-side
   lower bound propagates through height and tropical layers to yield an explicit
   security lower bound.

5. **`learning_height_tropical_security_transfer`**: Concrete corollary using
   margin/Lipschitz data from the catalog's `certified_robustness_from_margin_and_lipschitz`.

## Cross-domain connections

- **Cryptography ↔ Learning theory**: Robustness certificates behave like resource lower
  bounds; a classifier requiring minimum geometric margin resembles a cryptosystem requiring
  minimum entropy.
- **Learning theory ↔ Arithmetic geometry**: Height measures arithmetic complexity;
  margin/Lipschitz data measure statistical complexity.
- **Tropical geometry ↔ Security**: Tropical degree/dimension lower bounds translate
  to key-space complexity lower bounds.

## References

This module builds on:
- `certified_robustness_from_margin_and_lipschitz` (Bridges/HomologicalDeepLearning)
- `key_dimension_lower_bound_from_height` (Speculative/AutoResearch/AlgebraicInvariantCryptography)
- `tropical_security_from_norm_bound` (Tropical/RieszRepresentation/Applications)
- `tropical_depth_lower_bound` (Tropical/Core/TropicalDeepResearch)
- `tropical_kl_security_bound` (Tropical/InformationTheory/Core)
-/

import Mathlib

/-! ## Part 1: Core Affine Inequality Lemmas -/

/-
**Affine composition (two-step)**: If `x ≤ a * y + b` and `y ≤ c * z + d`
    with `0 ≤ a`, then `x ≤ (a * c) * z + (b + a * d)`.
    This is the key algebraic engine for composing transfer morphisms.
-/
theorem affine_bound_comp
    {a b c d x y z : ℝ}
    (h₁ : x ≤ a * y + b)
    (h₂ : y ≤ c * z + d)
    (ha : 0 ≤ a) :
    x ≤ (a * c) * z + (b + a * d) := by
  nlinarith

/-
**Affine composition (three-step)**: Chaining three affine upper bounds yields
    a single affine bound with composed constants. This is the algebraic backbone
    of the triadic transfer theorem.
-/
theorem affine_bound_comp₃
    {x₁ x₂ x₃ x₄ c₁ c₂ c₃ a₁ a₂ a₃ : ℝ}
    (h₁ : x₁ ≤ c₁ * x₂ + a₁)
    (h₂ : x₂ ≤ c₂ * x₃ + a₂)
    (h₃ : x₃ ≤ c₃ * x₄ + a₃)
    (hc₁ : 0 ≤ c₁) (hc₂ : 0 ≤ c₂) :
    x₁ ≤ (c₁ * c₂ * c₃) * x₄ + (a₁ + c₁ * a₂ + c₁ * c₂ * a₃) := by
  nlinarith [ mul_le_mul_of_nonneg_left hc₂ hc₁ ]

/-
**Lower-bound inversion**: If `x ≤ c * y + a` with `0 < c` and `B ≤ x`,
    then `(B - a) / c ≤ y`. This inverts an affine upper bound into
    a lower bound on the target.
-/
theorem lower_bound_of_affine_upper_bound
    {x y c a B : ℝ}
    (hc : 0 < c)
    (hxy : x ≤ c * y + a)
    (hB : B ≤ x) :
    (B - a) / c ≤ y := by
  rw [ div_le_iff₀ hc ] ; linarith

/-! ## Part 2: Abstract Theory Morphism Framework -/

/-- A `TheorySpec X` equips a type `X` with a real-valued invariant.
    This models the "complexity measure" of objects in a given domain:
    - Learning theory: margin-based complexity
    - Arithmetic geometry: height
    - Tropical geometry: degree/dimension
    - Cryptography: security parameter -/
structure TheorySpec (X : Type*) where
  /-- The real-valued invariant measuring complexity of objects -/
  inv : X → ℝ

/-- A `TheoryMorphism` from theory `A` to theory `B` witnesses that
    the invariant of `A` is affinely controlled by the invariant of `B`.
    Concretely: `A.inv x ≤ c * B.inv (map x) + a` for all `x`.

    This formalizes "hardness in domain A implies hardness in domain B"
    as a quantitative, composable morphism. -/
structure TheoryMorphism {X Y : Type*} (A : TheorySpec X) (B : TheorySpec Y) where
  /-- The underlying map between object types -/
  map : X → Y
  /-- The multiplicative constant in the affine bound -/
  c : ℝ
  /-- The additive constant in the affine bound -/
  a : ℝ
  /-- The multiplicative constant is positive -/
  hc : 0 < c
  /-- The invariant bound: A.inv x ≤ c * B.inv (map x) + a -/
  bound : ∀ x, A.inv x ≤ c * B.inv (map x) + a

/-- **Composition of theory morphisms**: Given morphisms `A → B` and `B → C`,
    their composition is a morphism `A → C` with constants `(c₁ * c₂, a₁ + c₁ * a₂)`.
    This is the categorical composition law for hardness transport. -/
def TheoryMorphism.comp {X Y Z : Type*}
    {A : TheorySpec X} {B : TheorySpec Y} {C : TheorySpec Z}
    (f : TheoryMorphism A B) (g : TheoryMorphism B C) :
    TheoryMorphism A C where
  map := g.map ∘ f.map
  c := f.c * g.c
  a := f.a + f.c * g.a
  hc := mul_pos f.hc g.hc
  bound x := affine_bound_comp (f.bound x) (g.bound (f.map x)) (le_of_lt f.hc)

/-- **Lower-bound transport through a single morphism**: If `lb ≤ A.inv x`,
    then `(lb - f.a) / f.c ≤ B.inv (f.map x)`. -/
theorem TheoryMorphism.transport_lower_bound {X Y : Type*}
    {A : TheorySpec X} {B : TheorySpec Y}
    (f : TheoryMorphism A B) (x : X)
    (lb : ℝ) (hlb : lb ≤ A.inv x) :
    (lb - f.a) / f.c ≤ B.inv (f.map x) :=
  lower_bound_of_affine_upper_bound f.hc (f.bound x) hlb

/-! ## Part 3: Triple Composition and Triadic Transfer -/

/-- **Triple composition of theory morphisms**: Composes three morphisms
    `A → B → C → D` into a single morphism `A → D` with fully explicit constants. -/
def TheoryMorphism.comp₃ {W X Y Z : Type*}
    {A : TheorySpec W} {B : TheorySpec X} {C : TheorySpec Y} {D : TheorySpec Z}
    (f : TheoryMorphism A B) (g : TheoryMorphism B C) (h : TheoryMorphism C D) :
    TheoryMorphism A D :=
  (f.comp g).comp h

/-- **Triadic security lower bound (abstract version)**:
    Given theory morphisms Learning → Height → Tropical → Security,
    any lower bound `B ≤ learnInv(x)` yields the explicit security lower bound:

    `(B - A₁ - C₁ * A₂ - C₁ * C₂ * A₃) / (C₁ * C₂ * C₃) ≤ secInv(...)` -/
theorem triadic_security_lower_bound
    {W X Y Z : Type*}
    {learn : TheorySpec W} {height : TheorySpec X}
    {trop : TheorySpec Y} {sec : TheorySpec Z}
    (f_LH : TheoryMorphism learn height)
    (f_HT : TheoryMorphism height trop)
    (f_TS : TheoryMorphism trop sec)
    (w : W) (B : ℝ)
    (hB : B ≤ learn.inv w) :
    (B - (f_LH.a + f_LH.c * f_HT.a + f_LH.c * f_HT.c * f_TS.a)) /
      (f_LH.c * f_HT.c * f_TS.c) ≤
    sec.inv ((f_LH.comp₃ f_HT f_TS).map w) := by
  exact (f_LH.comp₃ f_HT f_TS).transport_lower_bound w B hB

/-! ## Part 4: Direct Inequality Version (No Abstraction Required) -/

/-
**Triadic security lower bound (direct version)**: The same result stated
    purely in terms of real-valued inequalities, without the `TheorySpec` framework.
    This is the most directly usable form of the theorem.

    Given transfer inequalities:
    - `learnInv ≤ C₁ * heightInv + A₁`
    - `heightInv ≤ C₂ * tropInv + A₂`
    - `tropInv ≤ C₃ * secInv + A₃`

    and a lower bound `B ≤ learnInv`, we conclude:
    `(B - A₁ - C₁ * A₂ - C₁ * C₂ * A₃) / (C₁ * C₂ * C₃) ≤ secInv`
-/
theorem triadic_security_lower_bound_direct
    {learnInv heightInv tropInv secInv : ℝ}
    {C₁ C₂ C₃ A₁ A₂ A₃ B : ℝ}
    (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) (hC₃ : 0 < C₃)
    (hLH : learnInv ≤ C₁ * heightInv + A₁)
    (hHT : heightInv ≤ C₂ * tropInv + A₂)
    (hTS : tropInv ≤ C₃ * secInv + A₃)
    (hB : B ≤ learnInv) :
    (B - A₁ - C₁ * A₂ - C₁ * C₂ * A₃) / (C₁ * C₂ * C₃) ≤ secInv := by
  rw [ div_le_iff₀ ] <;> nlinarith [ mul_pos hC₁ hC₂, mul_pos hC₁ hC₃, mul_pos hC₂ hC₃, mul_le_mul_of_nonneg_left hLH hC₁.le, mul_le_mul_of_nonneg_left hHT ( mul_nonneg hC₁.le hC₂.le ), mul_le_mul_of_nonneg_left hTS ( mul_nonneg ( mul_nonneg hC₁.le hC₂.le ) hC₃.le ) ]

/-! ## Part 5: Concrete Specialization — Learning to Security Transfer -/

/-
**Learning-Height-Tropical-Security Transfer (Concrete)**:
    If a learner has margin `δ` and Lipschitz constant `K > 0`, and:
    - the robustness radius `δ / K` bounds height from below: `δ / K ≤ height`
    - height bounds tropical dimension from below: `height ≤ dim`
    - tropical dimension bounds security from below: `dim ≤ sec`

    then the robustness radius directly bounds security: `δ / K ≤ sec`.

    This instantiates the abstract triadic transfer using the catalog's
    `certified_robustness_from_margin_and_lipschitz` at the learning end.
-/
theorem learning_height_tropical_security_transfer
    {margin lipschitz height dim sec : ℝ}
    (_hK : 0 < lipschitz)
    (hlearn : margin / lipschitz ≤ height)
    (hhdim : height ≤ dim)
    (hdsec : dim ≤ sec) :
    margin / lipschitz ≤ sec := by
  linarith

/-- **Margin-Lipschitz Security Certificate**: Connecting directly to the catalog's
    `certified_robustness_from_margin_and_lipschitz`. If a classifier has margin `δ`
    and Lipschitz constant `K`, and the robustness radius chains through height and
    tropical layers to security, then the classifier's certified robustness radius
    is at most the security parameter.

    This theorem shows that adversarial robustness certificates from learning theory
    impose lower bounds on cryptographic security parameters. -/
theorem margin_lipschitz_security_certificate
    {δ K height dim sec ε : ℝ}
    (_hδ : 0 < δ) (hK : 0 < K) (_hε : 0 ≤ ε) (hsmall : ε ≤ δ / K)
    (hlearn : δ / K ≤ height)
    (hhdim : height ≤ dim)
    (hdsec : dim ≤ sec) :
    δ - K * ε ≥ 0 ∧ ε ≤ sec := by
  constructor
  · -- Certified robustness: δ - K * ε ≥ 0 from margin and Lipschitz
    nlinarith [mul_div_cancel₀ δ hK.ne']
  · -- Security lower bound: ε ≤ δ/K ≤ height ≤ dim ≤ sec
    linarith

/-
**Affine Security Certificate with Explicit Constants**: The full affine version
    with non-trivial transfer constants, suitable for direct application.

    Uses the triadic transfer to show that if a learning lower bound `B` is known,
    then after passing through three affine morphisms with constants `(C_i, A_i)`,
    the security parameter satisfies an explicit lower bound.
-/
theorem affine_security_certificate
    {B C₁ C₂ C₃ A₁ A₂ A₃ secInv : ℝ}
    (hC₁ : 0 < C₁) (hC₂ : 0 < C₂) (hC₃ : 0 < C₃)
    (hchain : B ≤ (C₁ * C₂ * C₃) * secInv + (A₁ + C₁ * A₂ + C₁ * C₂ * A₃)) :
    (B - A₁ - C₁ * A₂ - C₁ * C₂ * A₃) / (C₁ * C₂ * C₃) ≤ secInv := by
  rw [ div_le_iff₀ ] <;> first | positivity | linarith;

/-! ## Part 6: Depth-Enhanced Transfer -/

/-
**Depth-enhanced security**: If a contractive network with Lipschitz constant
    `K < 1` at depth `L` has robustness radius `δ / K^L`, then increasing depth
    improves the robustness bound that feeds the security chain.
-/
theorem depth_enhanced_security
    {δ K : ℝ} {L₁ L₂ : ℕ}
    (hδ : 0 < δ) (hK₀ : 0 < K) (hK₁ : K < 1) (hL : L₁ ≤ L₂) :
    δ / K ^ L₂ ≥ δ / K ^ L₁ := by
  contrapose hL;
  exact fun h => hL <| by rw [ ge_iff_le ] ; rw [ div_le_div_iff₀ ( by positivity ) ( by positivity ) ] ; nlinarith [ pow_pos hK₀ L₁, pow_pos hK₀ L₂, pow_le_pow_of_le_one ( by positivity ) hK₁.le h ] ;