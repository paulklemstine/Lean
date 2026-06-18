# Periodicity in Monoidal Categories: When Tensor Powers Repeat

## Mathematical Context

In a monoidal category (C, ⊗, I), an object X is called **periodic** (or has **tensor torsion**) if there exist distinct natural numbers m ≠ n such that X^⊗m ≅ X^⊗n, where X^⊗0 = I and X^⊗(k+1) = X ⊗ X^⊗k. This is the categorical analog of torsion in group theory: just as a group element g has torsion if g^n = e, a monoidal object has periodicity if its tensor powers eventually repeat.

This phenomenon arises naturally: in the category of finite-dimensional vector spaces, every object is periodic (since dim(X^⊗n) = dim(X)^n is determined by dimension, and in a skeletal subcategory, equal dimensions force isomorphism). In representation categories of finite groups, periodicity reflects the finite number of irreducible representations.

## Definitions to Formalize

1. **Tensor power**: `mpow (X : C) (n : ℕ) : C` — defined by induction: mpow X 0 = 𝟙_ C, mpow X (n+1) = X ⊗ mpow X n. Use Mathlib's existing `CategoryTheory.Monoidal.Iteration` infrastructure if available, or define from scratch.

2. **Periodicity predicate**: `IsPeriodic (X : C) : Prop` — ∃ m n, 0 < m ∧ m < n ∧ Nonempty (mpow X m ≅ mpow X n). We require positive exponents m, n to capture non-trivial periodicity (excluding the trivial case X ≅ 𝟙_ C with m=0).

3. **Minimal period**: For a periodic X, define `minPeriod X` as the smallest positive d such that ∃ k ≥ 0, Nonempty (mpow X k ≅ mpow X (k + d)).

## Main Results to Prove

### Theorem 1: Shift Invariance
`theorem shift_periodicity {C : Type*} [Category C] [MonoidalCategory C] {X : C} {m n : ℕ} (h : m ≤ n) (f : mpow X m ≅ mpow X n) (k : ℕ) : mpow X (m + k) ≅ mpow X (n + k)`

Proof sketch: Tensor both sides of f with mpow X k. Use the monoidal structure to show ⊗ preserves isomorphisms.

### Theorem 2: Eventual Periodicity
`theorem eventual_periodicity {C : Type*} [Category C] [MonoidalCategory C] {X : C} {m n : ℕ} (hmn : m < n) (f : mpow X m ≅ mpow X n) : ∀ r ≥ m, mpow X r ≅ mpow X (r + (n - m))`

Proof sketch: Let d = n - m. By Theorem 1, mpow X (m+j) ≅ mpow X (n+j) = mpow X (m + d + j) for all j. For r ≥ m, write r = m + j and apply.

### Theorem 3: Minimal Period Divides All Witness Differences
`theorem minPeriod_dvd {C : Type*} [Category C] [MonoidalCategory C] {X : C} (hX : IsPeriodic X) {a b : ℕ} (hab : a < b) (f : mpow X a ≅ mpow X b) : (minPeriod X) ∣ (b - a)`

Proof sketch: The set of differences d such that mpow X k ≅ mpow X (k+d) for some k forms a subsemigroup of ℕ. The minimal period generates this subsemigroup.

### Theorem 4: Tensor Product of Periodic Objects (Braided Case)
`theorem tensor_periodic {C : Type*} [Category C] [BraidedCategory C] {X Y : C} (hX : IsPeriodic X) (hY : IsPeriodic Y) : IsPeriodic (X ⊗ Y)`

Proof sketch: In a braided monoidal category, (X ⊗ Y)^⊗n ≅ X^⊗n ⊗ Y^⊗n via the braiding. If X has period p and Y has period q, then (X ⊗ Y)^⊗lcm(p,q) is isomorphic to (X ⊗ Y)^⊗(2*lcm(p,q)).

### Theorem 5: Finiteness Implies Periodicity
`theorem finite_of_skeletal_finite_iso_classes {C : Type*} [Category C] [MonoidalCategory C] [Skeletal C] (h : Finite (Quotient (isoRelation C))) (X : C) : IsPeriodic X`

Proof sketch: In a skeletal category, isomorphic objects are equal. The sequence mpow X 0, mpow X 1, mpow X 2, ... takes values in a finite set of isomorphism classes, so by pigeonhole, some mpow X m = mpow X n with m ≠ n.

### Theorem 6: Delooping Interpretation (Statement Only)
`theorem deloop_periodic_iff {C : Type*} [Category C] [MonoidalCategory C] (X : C) : IsPeriodic X ↔ ∃ m n, 0 < m ∧ m < n ∧ Nonempty ((@CategoryTheory.MonoidalSingleObj C _ _ _).Hom (mpow X m) (mpow X n))`

This connects periodicity in C to compositional loops in the delooped bicategory. A full proof requires more bicategory infrastructure, so this may remain a sorry.

## Key Insight

The key insight is that periodicity in monoidal categories obeys structural laws directly analogous to torsion in groups: it propagates under tensor product (with period dividing lcm), has a well-defined minimal period that divides all witness differences, and is forced by finiteness. This provides the first formal verification of these fundamental structural properties.

## Why Now?

Mathlib has mature monoidal category infrastructure (CategoryTheory.Monoidal) including tensor iteration utilities. The braided monoidal category infrastructure (CategoryTheory.Braided) supports the tensor product result. The skeletal category assumption in Theorem 5 is available via CategoryTheory.Skeletal. This combination makes the formalization tractable.

## Formalization Strategy

1. First define `mpow` by induction on ℕ, proving basic lemmas (mpow X 0 = 𝟙_ C, mpow X 1 ≅ X, mpow X (m+n) ≅ mpow X m ⊗ mpow X n).
2. Define `IsPeriodic` and `minPeriod`.
3. Prove Theorems 1-5 in order (each builds on the previous).
4. Theorem 6 can be stated but may use sorry for the proof.
5. Use sorry_fill mode: all definitions and theorem statements must type-check, but proofs can use sorry for technically difficult steps.

## Catalog References
- Mathlib.CategoryTheory.Monoidal
- Mathlib.CategoryTheory.Monoidal.Iteration
- Mathlib.CategoryTheory.BraidedCategory
- Mathlib.CategoryTheory.Skeletal
- Mathlib.CategoryTheory.MonoidalSingleObj