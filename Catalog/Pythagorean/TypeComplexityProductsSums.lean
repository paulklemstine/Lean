/-
# Type Complexity Algebra for Products, Sums, and Arrows

This file extends the type complexity theory from `TypeComplexityBounds.lean`
to a full grammar of types including products (×) and sums (+), establishing
that **type constructors induce a compositional algebra on finite state spaces**:

- Products multiply state-space cardinalities (independent composition),
- Sums add state-space cardinalities (exclusive branching),
- Arrows exponentiate (function spaces).

The key insight is that `extTypeStateBound` is not merely a syntactic measure —
it is the *cardinality of the finite denotational semantics*. We prove this by
constructing a concrete `Fintype` denotation for each type and showing its
cardinality equals the recursively defined bound.

## Main Results

1. `extTypeStateBound_pos` — Positivity of the bound for all types.
2. `fintype_card_denote_eq_bound` — The jewel: denotation cardinality = bound.
3. `denotation_card_prod` — Product semantics is multiplicative.
4. `denotation_card_sum` — Sum semantics is additive.
5. `denotation_card_arr` — Arrow semantics is exponential.
6. `complexityAlg_respects_prod_sum_arr` — Bundled semiring-homomorphism theorem.
7. `extTypeStateBound_prod_ge_left/right` — Monotonic domination for products.
8. `extTypeStateBound_sum_ge_left/right` — Monotonic domination for sums.
9. `extTypeStateBound_monotone_embed` — Monotonicity under positive-monotone embedding.

**Application keywords:** typed λ-calculus, state complexity, categorical
semantics, bicartesian closed categories, compositional complexity, finite
denotational semantics, state-space algebra, complexity-by-types
-/

import Mathlib

/-! ## Extended Type Grammar

We define an extended type syntax with base, arrow, product, and sum types.
This is a free algebra over {1, →, ×, +} — the generators of a bicartesian
closed category. -/

/-- Extended type syntax with base, arrow, product, and sum constructors. -/
inductive ExtTy : Type where
  | base : ExtTy
  | arr  : ExtTy → ExtTy → ExtTy
  | prod : ExtTy → ExtTy → ExtTy
  | sum  : ExtTy → ExtTy → ExtTy
  deriving DecidableEq, Repr

namespace ExtTy

/-! ## Extended State Bound

The central complexity functional, defined by structural recursion on types.
This is the "arithmetic shadow" of type constructors on finite state spaces. -/

/-- The extended type state bound: the number of elements in the finite
    denotational model of a type. Base types get 1, arrows exponentiate,
    products multiply, sums add. -/
def extTypeStateBound : ExtTy → ℕ
  | .base      => 1
  | .arr A B   => extTypeStateBound B ^ extTypeStateBound A
  | .prod A B  => extTypeStateBound A * extTypeStateBound B
  | .sum A B   => extTypeStateBound A + extTypeStateBound B

/-! ## Positivity -/

/-- The state bound is always positive: every type has at least one inhabitant
    in its denotational model. This is a fundamental structural property. -/
theorem extTypeStateBound_pos (A : ExtTy) : 0 < extTypeStateBound A := by
  induction A with
  | base => simp [extTypeStateBound]
  | arr A B ihA ihB => exact pow_pos ihB _
  | prod A B ihA ihB => exact Nat.mul_pos ihA ihB
  | sum A B ihA ihB => exact Nat.add_pos_left ihA _

/-! ## Denotational Semantics

We construct a concrete finite type for each `ExtTy`, then prove its
cardinality equals `extTypeStateBound`. This is the semantic foundation
that turns the recursive definition from bookkeeping into a theorem
about finite possibility spaces. -/

/-- The denotational semantics of extended types as Lean types.
    - `base` denotes `Unit` (one element),
    - `arr A B` denotes `denote A → denote B` (function space),
    - `prod A B` denotes `denote A × denote B` (Cartesian product),
    - `sum A B` denotes `denote A ⊕ denote B` (disjoint union). -/
def denote : ExtTy → Type
  | .base      => Unit
  | .arr A B   => denote A → denote B
  | .prod A B  => denote A × denote B
  | .sum A B   => denote A ⊕ denote B

open Classical in
/-- Every denotation is a Fintype. We use classical decidability for
    the function-space case. -/
noncomputable instance denoteFintype : (A : ExtTy) → Fintype (denote A)
  | .base      => inferInstanceAs (Fintype Unit)
  | .arr A B   => by
      unfold denote
      exact @Pi.instFintype _ _ (Classical.decEq _) (denoteFintype A)
        (fun _ => denoteFintype B)
  | .prod A B  => @instFintypeProd _ _ (denoteFintype A) (denoteFintype B)
  | .sum A B   => @instFintypeSum _ _ (denoteFintype A) (denoteFintype B)

/-- Helper: the denotation cardinality as a natural number. -/
noncomputable def denotationCard (A : ExtTy) : ℕ :=
  @Fintype.card (denote A) (denoteFintype A)

/-! ## The Jewel: Cardinality = Bound

This is the central theorem establishing that `extTypeStateBound` is not
just a syntactic measure but the exact cardinality of the semantic model. -/

/-- **The Jewel Theorem**: The cardinality of the finite denotational model
    of a type equals `extTypeStateBound`. This proves that type constructors
    are operations on finite possibility spaces and the bound is their
    exact arithmetic shadow. -/
theorem fintype_card_denote_eq_bound (A : ExtTy) :
    @Fintype.card (denote A) (denoteFintype A) = extTypeStateBound A := by
  induction A with
  | base => rfl
  | arr A B ihA ihB =>
    convert Fintype.card_fun using 1
    exact ihB.symm ▸ ihA.symm ▸ rfl
  | prod A B ihA ihB =>
    convert Fintype.card_prod _ _ using 1
    aesop
  | sum A B ihA ihB =>
    exact Fintype.card_sum.trans (by aesop)

/-! ## Semantic Cardinality Theorems

These theorems follow from the jewel but are stated independently for clarity
and direct usability. They establish that the complexity algebra respects
type constructors semantically. -/

/-- Product semantics is multiplicative: the number of states in a product
    type equals the product of component state counts. -/
theorem denotation_card_prod (A B : ExtTy) :
    denotationCard (.prod A B) = denotationCard A * denotationCard B := by
  simp only [denotationCard]
  rw [fintype_card_denote_eq_bound, fintype_card_denote_eq_bound,
      fintype_card_denote_eq_bound]
  rfl

/-- Sum semantics is additive: the number of states in a sum type equals
    the sum of component state counts. -/
theorem denotation_card_sum (A B : ExtTy) :
    denotationCard (.sum A B) = denotationCard A + denotationCard B := by
  simp only [denotationCard]
  rw [fintype_card_denote_eq_bound, fintype_card_denote_eq_bound,
      fintype_card_denote_eq_bound]
  rfl

/-- Arrow semantics is exponential: the number of states in a function type
    equals the target count raised to the source count. -/
theorem denotation_card_arr (A B : ExtTy) :
    denotationCard (.arr A B) = denotationCard B ^ denotationCard A := by
  simp only [denotationCard]
  rw [fintype_card_denote_eq_bound, fintype_card_denote_eq_bound,
      fintype_card_denote_eq_bound]
  rfl

/-! ## Semiring-Homomorphic Complexity Algebra -/

/-- The complexity algebra interpretation: type → ℕ. -/
def complexityAlg : ExtTy → ℕ := extTypeStateBound

/-- **Semiring Homomorphism**: Type formation induces a semiring/exponential
    algebra of state complexity. Products multiply, sums add, arrows exponentiate.
    This is the decategorification of the type grammar into ℕ. -/
theorem complexityAlg_respects_prod_sum_arr :
    (∀ A B, complexityAlg (.prod A B) =
      complexityAlg A * complexityAlg B) ∧
    (∀ A B, complexityAlg (.sum A B) =
      complexityAlg A + complexityAlg B) ∧
    (∀ A B, complexityAlg (.arr A B) =
      complexityAlg B ^ complexityAlg A) :=
  ⟨fun _ _ => rfl, fun _ _ => rfl, fun _ _ => rfl⟩

/-! ## Monotonic Domination

These theorems show that combining types via products or sums never decreases
complexity: the result always has at least as much complexity as each component. -/

theorem extTypeStateBound_prod_ge_left (A B : ExtTy) :
    extTypeStateBound A ≤ extTypeStateBound (.prod A B) :=
  Nat.le_mul_of_pos_right _ (extTypeStateBound_pos B)

theorem extTypeStateBound_prod_ge_right (A B : ExtTy) :
    extTypeStateBound B ≤ extTypeStateBound (.prod A B) :=
  le_mul_of_one_le_left (Nat.zero_le _) (Nat.one_le_of_lt (extTypeStateBound_pos A))

theorem extTypeStateBound_sum_ge_left (A B : ExtTy) :
    extTypeStateBound A ≤ extTypeStateBound (.sum A B) :=
  Nat.le_add_right _ _

theorem extTypeStateBound_sum_ge_right (A B : ExtTy) :
    extTypeStateBound B ≤ extTypeStateBound (.sum A B) :=
  Nat.le_add_left _ _

/-! ## Positive-Monotone Structural Embedding

We define a notion of structural embedding restricted to product and sum
contexts (which are monotone in both components), excluding arrows
(which are contravariant in the domain). -/

/-- Positive-monotone structural embedding: `A` is embedded in `B` if `A`
    can be found as a sub-expression within product and sum constructors of `B`.
    Arrow types are treated as leaves since function-space complexity is
    not monotone in the domain component. -/
inductive TyFragmentEmbeds : ExtTy → ExtTy → Prop where
  | refl (A : ExtTy) : TyFragmentEmbeds A A
  | prod_left (A B C : ExtTy) :
      TyFragmentEmbeds A B → TyFragmentEmbeds A (.prod B C)
  | prod_right (A B C : ExtTy) :
      TyFragmentEmbeds A C → TyFragmentEmbeds A (.prod B C)
  | sum_left (A B C : ExtTy) :
      TyFragmentEmbeds A B → TyFragmentEmbeds A (.sum B C)
  | sum_right (A B C : ExtTy) :
      TyFragmentEmbeds A C → TyFragmentEmbeds A (.sum B C)

/-
**Monotonicity under positive embedding**: If type `A` is structurally
    embedded in type `B` via product/sum contexts, then `A`'s state-space
    complexity does not exceed `B`'s.
-/
theorem extTypeStateBound_monotone_embed {A B : ExtTy}
    (h : TyFragmentEmbeds A B) :
    extTypeStateBound A ≤ extTypeStateBound B := by
  induction h;
  · rfl;
  · exact le_trans ‹_› ( extTypeStateBound_prod_ge_left _ _ );
  · exact le_trans ‹_› ( extTypeStateBound_prod_ge_right _ _ );
  · exact le_trans ‹_› ( extTypeStateBound_sum_ge_left _ _ );
  · exact le_trans ‹_› ( extTypeStateBound_sum_ge_right _ _ )

/-! ## Size and Depth Measures -/

/-- Size of an extended type (number of constructors). -/
def size : ExtTy → ℕ
  | .base => 1
  | .arr A B => 1 + size A + size B
  | .prod A B => 1 + size A + size B
  | .sum A B => 1 + size A + size B

/-- Depth of an extended type. -/
def depth : ExtTy → ℕ
  | .base => 0
  | .arr A B => 1 + max (depth A) (depth B)
  | .prod A B => 1 + max (depth A) (depth B)
  | .sum A B => 1 + max (depth A) (depth B)

/-! ## Connection to Existing Catalog -/

/-- Arrow recurrence for the extended bound (definitional). -/
theorem extTypeStateBound_arr_recurrence (A B : ExtTy) :
    extTypeStateBound (.arr A B) =
      extTypeStateBound B ^ extTypeStateBound A := rfl

/-- Product recurrence for the extended bound (definitional). -/
theorem extTypeStateBound_prod_recurrence (A B : ExtTy) :
    extTypeStateBound (.prod A B) =
      extTypeStateBound A * extTypeStateBound B := rfl

/-- Sum recurrence for the extended bound (definitional). -/
theorem extTypeStateBound_sum_recurrence (A B : ExtTy) :
    extTypeStateBound (.sum A B) =
      extTypeStateBound A + extTypeStateBound B := rfl

/-! ## Computational Verification -/

/-- Concrete computations verifying the algebra. -/
theorem extTypeStateBound_examples :
    extTypeStateBound .base = 1 ∧
    extTypeStateBound (.prod .base .base) = 1 ∧
    extTypeStateBound (.sum .base .base) = 2 ∧
    extTypeStateBound (.arr .base .base) = 1 ∧
    extTypeStateBound (.arr (.sum .base .base) (.sum .base .base)) = 4 ∧
    extTypeStateBound (.prod (.sum .base .base) (.sum .base .base)) = 4 := by
  decide

/-
The product-sum interplay: (A + B) × C has more states than either
    A × C or B × C alone. This is the distributive law shadow.
-/
theorem extTypeStateBound_distrib_ge (A B C : ExtTy) :
    extTypeStateBound (.prod (.sum A B) C) =
      extTypeStateBound (.prod A C) + extTypeStateBound (.prod B C) := by
  convert extTypeStateBound_sum_recurrence ( A.prod C ) ( B.prod C ) using 1;
  -- By definition of extTypeStateBound, we can expand both sides.
  have h_expand : ∀ (A B C : ExtTy), extTypeStateBound (ExtTy.prod (ExtTy.sum A B) C) = (extTypeStateBound A + extTypeStateBound B) * extTypeStateBound C ∧ extTypeStateBound (ExtTy.sum (ExtTy.prod A C) (ExtTy.prod B C)) = extTypeStateBound A * extTypeStateBound C + extTypeStateBound B * extTypeStateBound C := by
    intros A B C
    simp [extTypeStateBound_prod_recurrence, extTypeStateBound_sum_recurrence];
  rw [ h_expand A B C |>.1, h_expand A B C |>.2, add_mul ]

end ExtTy