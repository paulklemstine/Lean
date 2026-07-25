/-
# Monad Algebras as Verified Normal Forms — The Evaluation-Is-Normalization Theorem

This file formalizes the connection between Eilenberg-Moore algebras for the
list monad (= free-monoid monad) and monoid structures, proving that evaluation
IS normalization.

## Main results

* `ListAlgebra` — the structure of a T-algebra for the list monad
* `ListAlgebra.toMonoid` — every list algebra induces a monoid
* `Monoid.toListAlgebra` — every monoid gives a list algebra via `List.prod`
* `normalization_compositional` — the normalization map is compositional
* `eval_append_eq_mul` — evaluation distributes over concatenation
* `prod_eq_iff_lift_eq` — normal form characterization via free monoid
* `pythagorean_normalization_compositional` — cross-domain: Pythagorean triples
-/

import Mathlib

/-! ## Part 1: List Algebra — T-algebras for the List Monad -/

/-- A `ListAlgebra` is an Eilenberg-Moore algebra for the list monad (free-monoid monad).
    It consists of a structure map `eval : List A → A` satisfying the unit and
    associativity laws. This is the categorical notion of "a way to evaluate
    formal expressions into values". -/
structure ListAlgebra (A : Type*) where
  /-- The structure map: evaluates a formal expression (list) into a value -/
  eval : List A → A
  /-- Unit law: evaluating a singleton returns the element itself -/
  unit_law : ∀ a : A, eval [a] = a
  /-- Associativity law (= compositionality of normalization):
      flattening then evaluating = evaluating subexpressions then evaluating results -/
  assoc_law : ∀ l : List (List A), eval (l.flatten) = eval (l.map eval)

/-! ## Part 2: Every List Algebra Induces a Monoid -/

namespace ListAlgebra

variable {A : Type*} (α : ListAlgebra A)

/-- The identity element of the induced monoid: evaluate the empty list -/
noncomputable def one : A := α.eval []

/-- The multiplication of the induced monoid: evaluate a two-element list -/
noncomputable def mul (a b : A) : A := α.eval [a, b]

/-
Left identity: `α.one * a = a`, derived from the algebra laws
-/
theorem mul_one_left (a : A) : α.mul α.one a = a := by
  have := α.assoc_law [ [ ], [ a ] ];
  convert this.symm using 1;
  · simp +decide [ ListAlgebra.mul, ListAlgebra.one ];
    rw [ α.unit_law ];
  · convert α.unit_law a |> Eq.symm

/-
Right identity: `a * α.one = a`, derived from the algebra laws
-/
theorem mul_one_right (a : A) : α.mul a α.one = a := by
  -- By definition of α.one, we have α.one = α.eval [].
  have h_one : α.one = α.eval [] := by
    rfl;
  convert α.assoc_law [ [ a ], [ ] ] using 1;
  · -- By definition of α.mul, we have α.mul a α.one = α.eval [a, α.one].
    simp [ListAlgebra.mul];
    convert α.assoc_law [ [ a ], [ ] ] using 1;
    · grind +suggestions;
    · convert α.assoc_law [ [ a ], [ ] ] using 1;
  · convert α.unit_law a |> Eq.symm using 1;
    exact α.assoc_law [ [ a ], [ ] ] ▸ by simp +decide ;

/-
Associativity: `(a * b) * c = a * (b * c)`, derived from the algebra laws
-/
theorem mul_assoc (a b c : A) : α.mul (α.mul a b) c = α.mul a (α.mul b c) := by
  have := α.assoc_law [ [ a, b ], [ c ] ] ; ( have := α.assoc_law [ [ a ], [ b, c ] ] ; ( ( simp_all +decide [ List.flatten ] ) ; ) );
  convert this using 1 <;> simp +decide [ ListAlgebra.mul ];
  · rw [ α.unit_law ];
  · rw [ α.unit_law ]

/-- Every list algebra induces a monoid structure.
    This is the forward direction of the comparison theorem. -/
noncomputable def toMonoid : Monoid A where
  one := α.one
  mul := α.mul
  one_mul := α.mul_one_left
  mul_one := α.mul_one_right
  mul_assoc := α.mul_assoc

end ListAlgebra

/-! ## Part 3: Every Monoid Gives a List Algebra via `List.prod` -/

/-
Every monoid gives a list algebra via `List.prod`.
    This is the reverse direction of the comparison theorem.
-/
def Monoid.toListAlgebra (A : Type*) [Monoid A] : ListAlgebra A where
  eval := List.prod
  unit_law := by simp
  assoc_law := by
    simp +decide [ *, List.prod_append ]

/-! ## Part 4: The Comparison Theorem -/

/-- **The Comparison Theorem (T-Algebras Are Monoids)**:
    A type carries a list algebra structure if and only if it carries a monoid structure.
    This is the Eilenberg-Moore comparison theorem for the free-forgetful adjunction
    between monoids and sets, made explicit. -/
theorem list_algebra_iff_monoid (A : Type*) :
    Nonempty (ListAlgebra A) ↔ ∃ (_ : Monoid A), True := by
  constructor
  · rintro ⟨α⟩
    exact ⟨α.toMonoid, trivial⟩
  · rintro ⟨inst, _⟩
    exact ⟨@Monoid.toListAlgebra A inst⟩

/-! ## Part 5: Normalization Compositionality -/

/-- **Evaluation distributes over concatenation**: For any monoid, the evaluation
    map `List.prod` sends list concatenation to monoid multiplication.
    This is the key lemma for compositionality. -/
theorem eval_append_eq_mul {A : Type*} [Monoid A] (l₁ l₂ : List A) :
    (l₁ ++ l₂).prod = l₁.prod * l₂.prod :=
  List.prod_append

/-
**Normalization is compositional (Second Monad Algebra Law)**:
    For any monoid, normalizing a flattened expression equals normalizing each
    subexpression first, then normalizing the results.
    This is `α ∘ μ = α ∘ Tα` expressed as a computational guarantee.
-/
theorem normalization_compositional {A : Type*} [Monoid A]
    (l : List (List A)) : (l.flatten).prod = (l.map List.prod).prod := by
      exact?

/-
General evaluation theorem: `List.prod` computes the iterated product.
    Proved by induction with explicit use of monoid associativity.
-/
theorem list_prod_foldl_eq {A : Type*} [Monoid A] (l : List A) :
    l.prod = l.foldl (· * ·) 1 := by
      induction l <;> simp_all +decide [ List.foldl ];
      rename_i k l ih; rw [ ← ih ] ; exact (by
      clear ih; induction l using List.reverseRecOn <;> simp +decide [ *, mul_assoc ] ;
      rw [ ← mul_assoc, ‹k * _ = _› ]);

/-! ## Part 6: Verified Normalizer Structure -/

/-- A verified normalizer for the list monad: a normalization map from lists to values
    that is both correct (unit law) and compositional (associativity law).
    This IS a T-algebra by definition — the verification conditions are exactly
    the Eilenberg-Moore algebra axioms. -/
structure VerifiedNormalizer (A : Type*) where
  /-- The normalization map -/
  normalize : List A → A
  /-- Correctness: normalizing a singleton returns the element -/
  correct : ∀ a, normalize [a] = a
  /-- Compositionality: normalizing a flattened list equals
      normalizing sublists then normalizing results -/
  compositional : ∀ (l : List (List A)), normalize l.flatten = normalize (l.map normalize)

/-- Every verified normalizer is a list algebra -/
def VerifiedNormalizer.toListAlgebra {A : Type*} (ν : VerifiedNormalizer A) :
    ListAlgebra A where
  eval := ν.normalize
  unit_law := ν.correct
  assoc_law := ν.compositional

/-- Every list algebra is a verified normalizer -/
def ListAlgebra.toVerifiedNormalizer {A : Type*} (α : ListAlgebra A) :
    VerifiedNormalizer A where
  normalize := α.eval
  correct := α.unit_law
  compositional := α.assoc_law

/-- The canonical verified normalizer for any monoid is `List.prod` -/
def Monoid.canonicalNormalizer (A : Type*) [Monoid A] : VerifiedNormalizer A where
  normalize := List.prod
  correct := by simp
  compositional := normalization_compositional

/-! ## Part 7: Cross-Domain — Normalization and Free Monoid Homomorphisms -/

/-- **Normal Form Characterization via Free Monoid**:
    Two words over α are equal as free monoid elements iff they are equal as lists.
    This connects T-algebra normalization to the universal property of free monoids. -/
theorem normal_form_iff_freeMonoid {α : Type*} (w₁ w₂ : List α) :
    (FreeMonoid.ofList w₁) = (FreeMonoid.ofList w₂) ↔ w₁ = w₂ := by
  exact Equiv.apply_eq_iff_eq FreeMonoid.ofList

/-
In any monoid, the lift of the identity is a retraction of ofList.
    This connects the free monoid to its underlying list representation
    and shows that normalization via List.prod factors through FreeMonoid.lift.
-/
theorem freeMonoid_lift_id_eq_prod {α : Type*} [Monoid α] (w : FreeMonoid α) :
    FreeMonoid.lift _root_.id w = (FreeMonoid.toList w).prod := by
      -- By definition of `FreeMonoid.lift`, we know that `FreeMonoid.lift id` is the identity function on `FreeMonoid α`.
      have h_lift_id : ∀ w : FreeMonoid α, FreeMonoid.lift id w = List.prod (FreeMonoid.toList w) := by
        intro w
        induction' w using FreeMonoid.recOn with w hw;
        · aesop;
        · aesop;
      exact h_lift_id w

/-! ## Part 8: Cross-Domain — Pythagorean Triple Monoid and Normalization -/

/-- The Berggren matrices generate all primitive Pythagorean triples via a ternary tree.
    Each matrix acts on triples, and their composition forms a monoid.
    We represent the action as 3×3 integer matrices. -/
def berggrenMatrix (i : Fin 3) : Matrix (Fin 3) (Fin 3) ℤ :=
  match i with
  | 0 => !![1, -2, 2; 2, -1, 2; 2, -2, 3]   -- U
  | 1 => !![1, 2, 2; 2, 1, 2; 2, 2, 3]       -- A
  | 2 => !![-1, 2, 2; -2, 1, 2; -2, 2, 3]    -- D

/-- **Pythagorean Normalization Theorem**: The Berggren matrix word normalizer
    is compositional — normalizing subwords then combining equals normalizing
    the whole word. This connects Pythagorean triple generation to the
    T-algebra compositionality framework. -/
theorem pythagorean_normalization_compositional
    (words : List (List (Matrix (Fin 3) (Fin 3) ℤ))) :
    (words.flatten).prod = (words.map List.prod).prod :=
  normalization_compositional words

/-! ## Part 9: Normalization Complexity -/

/-- The number of multiplications needed to normalize a list of length n is n-1
    (or 0 for empty lists). This formalizes the linear-time normalization property. -/
def normalization_cost : List α → ℕ
  | [] => 0
  | [_] => 0
  | _ :: t => 1 + normalization_cost t

/-
The normalization cost of a list of length n is max(0, n-1)
-/
theorem normalization_cost_eq_length_sub_one {α : Type*} (l : List α) :
    normalization_cost l = l.length - 1 := by
      induction' l with hd tl ih;
      · rfl;
      · cases tl <;> simp_all! +arith +decide

/-
The normalization cost of concatenation is bounded by the sum of costs plus one
-/
theorem normalization_cost_append {α : Type*} (l₁ l₂ : List α)
    (h₁ : l₁ ≠ []) (h₂ : l₂ ≠ []) :
    normalization_cost (l₁ ++ l₂) = normalization_cost l₁ + normalization_cost l₂ + 1 := by
      rcases l₁ with ( _ | ⟨ a, l₁ ⟩ ) <;> rcases l₂ with ( _ | ⟨ b, l₂ ⟩ ) <;> simp_all +arith +decide;
      induction' l₁ with c l₁ ih generalizing b l₂ <;> simp_all +arith +decide [ normalization_cost ];
      cases l₁ <;> simp_all +arith +decide [ normalization_cost ]

/-! ## Part 10: Algebra Morphisms Preserve Normalization -/

/-- A morphism of list algebras: a function between carrier types that
    commutes with the evaluation maps -/
structure ListAlgebraMorphism {A B : Type*} (α : ListAlgebra A) (β : ListAlgebra B) where
  /-- The underlying function -/
  func : A → B
  /-- Compatibility: evaluation then mapping = mapping then evaluation -/
  compat : ∀ l : List A, β.eval (l.map func) = func (α.eval l)

/-- The identity morphism -/
def ListAlgebraMorphism.id {A : Type*} (α : ListAlgebra A) :
    ListAlgebraMorphism α α where
  func := _root_.id
  compat := by simp [List.map_id]

/-
Composition of algebra morphisms
-/
def ListAlgebraMorphism.comp {A B C : Type*}
    {α : ListAlgebra A} {β : ListAlgebra B} {γ : ListAlgebra C}
    (g : ListAlgebraMorphism β γ) (f : ListAlgebraMorphism α β) :
    ListAlgebraMorphism α γ where
  func := g.func ∘ f.func
  compat := by
    intro l; rw [ show List.map ( g.func ∘ f.func ) l = List.map g.func ( List.map f.func l ) by ext; simp +decide ] ; rw [ g.compat, f.compat ] ;
    rfl

/-
**Monoid homomorphisms are list algebra morphisms**: every monoid homomorphism
    between monoids induces a morphism between their canonical list algebras.
    This connects the category of monoids to the Eilenberg-Moore category.
-/
theorem monoidHom_is_algebra_morphism {A B : Type*} [Monoid A] [Monoid B]
    (f : A →* B) :
    ∀ l : List A, (l.map f).prod = f l.prod := by
      intro l; induction l <;> simp +decide [ * ] ;

/-! ## Part 11: Idempotency of Normalization -/

/-- **Normalization is idempotent**: applying the normalizer to a singleton
    (i.e., to an already-normalized value) returns the value unchanged.
    This is equivalent to the unit law of the T-algebra. -/
theorem normalization_idempotent {A : Type*} [Monoid A] (a : A) :
    List.prod [List.prod [a]] = List.prod [a] := by simp

/-- More generally, normalizing a list of already-normalized singletons
    is the same as normalizing the original list -/
theorem normalization_singleton_map {A : Type*} [Monoid A] (l : List A) :
    (l.map (fun a => [a].prod)).prod = l.prod := by simp

/-! ## Part 12: Normalization Uniqueness -/

/-
**Normalization Uniqueness Theorem**: For a given monoid, the canonical
    normalizer `List.prod` is the UNIQUE verified normalizer that additionally
    satisfies `normalize [] = 1` and `normalize [a, b] = a * b`.
    This asserts that the T-algebra structure is rigid — there is
    essentially only one way to normalize with these boundary conditions.
-/
theorem normalization_uniqueness {A : Type*} [Monoid A]
    (ν : VerifiedNormalizer A)
    (h_nil : ν.normalize [] = 1)
    (h_pair : ∀ a b : A, ν.normalize [a, b] = a * b) :
    ∀ l : List A, ν.normalize l = l.prod := by
      intro l;
      induction' l with a l ih;
      · exact h_nil;
      · convert ν.compositional [ [ a ], l ] using 1 <;> simp +decide [ h_nil, h_pair, ih ];
        rw [ ν.correct ]