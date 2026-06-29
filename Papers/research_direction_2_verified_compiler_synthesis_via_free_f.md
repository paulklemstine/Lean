# Verified Compiler Synthesis via Free-Forgetful Adjunctions

## Abstract

We formalize and prove the **adjoint semantics principle**: for any adjunction F ⊣ U between a category of algebras and a base category, the adjunction transpose provides the unique structure-preserving interpreter extending a variable assignment into the algebra. This principle is instantiated for three algebraic theories — monoids, groups, and abelian groups — yielding verified evaluators that provably coincide with the standard algebraic lifts (FreeMonoid.lift, FreeGroup.lift, FreeAbelianGroup.lift). We further prove naturality (backend-independence) of the synthesized evaluators and establish a general optimizer soundness theorem: any endomorphism of a free algebra preserving generators preserves semantics. All results are machine-verified in Lean 4 using the Mathlib library, with no unresolved proof obligations. The framework demonstrates that adjunctions are not merely specification devices but executable compiler construction mechanisms.

## 1. Introduction

### 1.1 Motivation

The construction of correct interpreters and compilers is a fundamental challenge in computer science. Traditional approaches build interpreters by hand and verify them post hoc against specifications. This work inverts the process: we derive interpreters directly from universal algebraic properties and prove their correctness as a consequence of the construction.

The key observation is that free-forgetful adjunctions in algebra provide exactly the data needed for an interpreter:
- The **free functor** F constructs syntax (free algebraic expressions on generators).
- The **forgetful functor** U extracts the carrier set of an algebra (the semantic domain).
- The **adjunction transpose** (homEquiv) maps variable assignments to structure-preserving evaluators.
- **Uniqueness** of the transpose guarantees that no other semantics-preserving extension exists.

### 1.2 Contributions

1. **Generic theorem** (`adjoint_semantics_principle`): For any adjunction F ⊣ U, the transpose provides a unique interpreter. This is formalized as the `SemanticComplete` property.

2. **Three concrete instantiations**: We prove that the adjunction transposes of MonCat.adj, GrpCat.adj, and AddCommGrpCat.adj coincide with FreeMonoid.lift, FreeGroup.lift, and FreeAbelianGroup.lift respectively.

3. **Naturality theorems**: We prove that the synthesized evaluators commute with algebra homomorphisms (backend-independence).

4. **Optimizer soundness**: We prove that endomorphisms of free algebras preserving generators preserve semantics.

5. **Compositionality via adjunction naturality**: We prove the abstract backend-independence law for arbitrary adjunctions.

6. **Machine-verified proofs**: All results are formalized in Lean 4 with Mathlib, depending only on standard axioms (propext, Classical.choice, Quot.sound).

### 1.3 Related Work

The categorical perspective on universal algebra is classical (Lawvere, 1963; Mac Lane, 1971). The connection between adjunctions and free constructions is textbook material (Awodey, 2010; Riehl, 2016). The novelty of our work lies in:

- Explicitly identifying the adjunction transpose as a **compiler construction mechanism** rather than a mere existence statement.
- Machine-verifying the correspondence between abstract categorical constructions and concrete algebraic evaluators.
- Formalizing optimizer soundness as a consequence of the universal property.
- Providing a reusable framework (`InterpreterSpec`, `SemanticComplete`) for extending the approach to new theories.

## 2. Definitions and Notation

### 2.1 Categories and Functors

We work within the framework of Mathlib's category theory library. The relevant categories are:
- **Type** (or **Type u**): the category of types and functions.
- **MonCat**: the category of monoids and monoid homomorphisms.
- **GrpCat**: the category of groups and group homomorphisms.
- **AddCommGrpCat**: the category of additive commutative groups and additive group homomorphisms.

For each algebraic category C, the **forgetful functor** `forget C : C ⥤ Type` extracts the underlying type.

### 2.2 Adjunctions

An adjunction F ⊣ U consists of functors F : C ⥤ D and U : D ⥤ C together with a natural bijection:

    homEquiv X A : (F.obj X ⟶ A) ≃ (X ⟶ U.obj A)

for all X : C and A : D. The inverse of this bijection, `(homEquiv X A).symm`, sends a morphism ρ : X ⟶ U.obj A to the unique morphism g : F.obj X ⟶ A satisfying the extension property.

### 2.3 Key Definitions

**Definition (InterpreterSpec).** A structure packaging:
- A free functor F : Syn ⥤ Sem
- An adjunction adj : F ⊣ U
- An evaluation map eval : (X ⟶ U.obj A) → (F.obj X ⟶ A)
- A proof that eval = adjunction transpose

**Definition (SemanticComplete).** The property that for every variable assignment ρ : X ⟶ U.obj A, there exists a unique morphism g : F.obj X ⟶ A such that ρ = (homEquiv X A) g.

## 3. Main Results

### 3.1 The Adjoint Semantics Principle

**Theorem 1 (adjoint_semantics_principle).** For any adjunction F ⊣ U between categories C and D, the property SemanticComplete holds:

    ∀ ρ : X ⟶ U.obj A, ∃! g : F.obj X ⟶ A, ρ = (homEquiv X A) g

*Proof sketch.* Since homEquiv X A is an equivalence (bijection), we take g := (homEquiv X A).symm ρ. Existence follows from the roundtrip property of Equiv: ρ = homEquiv (homEquiv.symm ρ). Uniqueness follows from injectivity: if homEquiv g₁ = homEquiv g₂ = ρ, then g₁ = g₂ by applying homEquiv.symm. ∎

This is the core generic theorem. It says that the adjunction transpose is the unique semantics-preserving extension of any variable assignment — in other words, it is the unique correct interpreter.

### 3.2 Concrete Evaluator Identification

**Theorem 2 (freeMonoid_eval_eq_adj_transpose).** For X : Type u, M : Type u with [Monoid M], and ρ : X → M:

    (MonCat.adj.homEquiv X (MonCat.of M)).symm ρ = MonCat.ofHom (FreeMonoid.lift ρ)

*Proof sketch.* Both sides are monoid homomorphisms FreeMonoid X →* M in MonCat. By unfolding MonCat.adj (which is defined via FreeMonoid.lift internally in Mathlib), the two sides are definitionally equal after simplification with the concrete category homEquiv. ∎

**Theorem 3 (freeGroup_eval_eq_adj_transpose).** For X : Type u, G : Type u with [Group G], and ρ : X → G:

    (GrpCat.adj.homEquiv X (GrpCat.of G)).symm ρ = GrpCat.ofHom (FreeGroup.lift ρ)

*Proof sketch.* Similar to the monoid case. The proof proceeds by showing the underlying functions agree via extensionality and induction on free group elements. ∎

**Theorem 4 (freeAbelianGroup_eval_eq_adj_transpose).** The analogous result for AddCommGrpCat.adj and FreeAbelianGroup.lift.

### 3.3 Naturality (Backend-Independence)

**Theorem 5 (freeMonoid_eval_natural).** For ρ : X → M and φ : M →* N:

    φ.comp (FreeMonoid.lift ρ) = FreeMonoid.lift (φ ∘ ρ)

*Proof sketch.* Both sides are monoid homomorphisms FreeMonoid X →* N. By the universal property of free monoids (FreeMonoid.hom_eq), it suffices to check they agree on generators FreeMonoid.of x. Both sides give φ (ρ x). ∎

**Theorem 6 (freeGroup_eval_natural).** The analogous result for FreeGroup.lift.

**Theorem 7 (freeAbelianGroup_eval_natural).** The analogous result for FreeAbelianGroup.lift.

**Theorem 8 (synthesized_eval_natural_generic).** For any adjunction F ⊣ U, ρ : X ⟶ U.obj A, and φ : A ⟶ B:

    (homEquiv X A).symm ρ ≫ φ = (homEquiv X B).symm (ρ ≫ U.map φ)

This is the abstract backend-independence law. It follows from the naturality of homEquiv in the second argument (Adjunction.homEquiv_naturality_right_symm).

### 3.4 Optimizer Soundness

**Theorem 9 (endomorphism_preserves_semantics).** For any monoid endomorphism opt : FreeMonoid X →* FreeMonoid X satisfying opt (FreeMonoid.of x) = FreeMonoid.of x for all generators x, and any ρ : X → M:

    (FreeMonoid.lift ρ).comp opt = FreeMonoid.lift ρ

*Proof sketch.* Both sides are monoid homomorphisms FreeMonoid X →* M. They agree on generators: (FreeMonoid.lift ρ).comp opt (FreeMonoid.of x) = FreeMonoid.lift ρ (opt (FreeMonoid.of x)) = FreeMonoid.lift ρ (FreeMonoid.of x) = ρ x. By FreeMonoid.hom_eq, they are equal everywhere. ∎

**Corollary (optimizer_semantics_preserved).** The canonical optimizer optimizeFreeMonoid := FreeMonoid.lift FreeMonoid.of preserves semantics. (This optimizer is the identity, but the proof pattern generalizes.)

## 4. Algorithms

### 4.1 Adjunction Transpose (Evaluator Synthesis)

```
Algorithm ADJUNCTION_TRANSPOSE(theory, ρ, expr):
    Input: Algebraic theory T, assignment ρ : X → A, expression expr ∈ F(X)
    Output: The unique T-homomorphism extending ρ, evaluated at expr
    
    match expr with
    | generator(x) → return ρ(x)
    | identity → return 1_A
    | product(a, b) → return ADJUNCTION_TRANSPOSE(T, ρ, a) ·_A ADJUNCTION_TRANSPOSE(T, ρ, b)
    | inverse(a) → return (ADJUNCTION_TRANSPOSE(T, ρ, a))⁻¹  // for groups
    
    Time: O(|expr|)
    Space: O(depth(expr))
```

### 4.2 Naturality Check

```
Algorithm CHECK_NATURALITY(theory, ρ, φ, test_exprs):
    Input: Theory T, assignment ρ, homomorphism φ : A →_T B, test expressions
    Output: Boolean (all pass / some fail)
    
    for each expr in test_exprs:
        lhs ← φ(LIFT(ρ, expr))
        rhs ← LIFT(φ ∘ ρ, expr)
        if lhs ≠ rhs: return FAIL
    return PASS
    
    Time: O(|test_exprs| × max_size)
```

### 4.3 Optimizer Soundness Check

```
Algorithm CHECK_OPTIMIZER(theory, opt, ρ_list, expr_list):
    Input: Theory T, endomorphism opt, list of assignments, list of expressions
    Output: Boolean
    
    // Precondition check: opt preserves generators
    for each generator x:
        if opt(of(x)) ≠ of(x): return FAIL (precondition violated)
    
    // Soundness check
    for each (ρ, expr) in ρ_list × expr_list:
        if LIFT(ρ, opt(expr)) ≠ LIFT(ρ, expr): return FAIL
    return PASS
    
    Time: O(|ρ_list| × |expr_list| × max_size)
```

## 5. Applications

### 5.1 Arithmetic Expression Compilation

Arithmetic expressions over variables {x₁, ..., xₙ} with multiplication form a free monoid. The evaluator FreeMonoid.lift maps variable assignments to numerical evaluation. Backend-independence (naturality) ensures that changing the number representation (e.g., from float to arbitrary precision) commutes with evaluation.

### 5.2 String Processing DSL

A sequence of string transformations (upper, reverse, trim, ...) forms a free monoid under composition. The lift evaluates a program by composing the operations. Compositionality follows from the monoid homomorphism property.

### 5.3 Permutation Group Word Problem

Free group words on generators {s₁, ..., sₙ} can be evaluated into symmetric groups via FreeGroup.lift. This solves the word problem for permutation groups: two words represent the same permutation if and only if they evaluate equally.

### 5.4 Polynomial Evaluation

Monomials in variables {x₁, ..., xₙ} form a free commutative monoid. Polynomial evaluation is the free abelian group lift applied to formal sums of monomials.

## 6. Computational Experiments

### 6.1 Evaluator Correctness

We implemented the synthesized evaluators in Python and verified correctness on test cases:

| Theory | Expression | Assignment | Result | Expected | Match |
|--------|-----------|------------|--------|----------|-------|
| Monoid (×) | x·y·x·y | x↦2, y↦3 | 36 | 36 | ✓ |
| Monoid (++) | x·y·x·y | x↦"ab", y↦"cd" | "abcdabcd" | "abcdabcd" | ✓ |
| Group (S₃) | x·y·x⁻¹ | x↦(1,2,0), y↦(0,2,1) | (1,0,2) | (1,0,2) | ✓ |
| Ab. Group | x+3y | x↦10, y↦7 | 31 | 31 | ✓ |

### 6.2 Naturality Verification

Backend-independence was verified for:
- Monoid evaluator with additive monoid (ℤ,+) and φ(n)=2n: PASS
- All test expressions up to length 4: PASS

### 6.3 Residual Finiteness Conjecture

We tested the conjecture that distinct free group words of length ≤3 on 2 generators are separated by evaluation into finite abelian quotients Z/pZ (p ∈ {2,3,5,7}):

- Total distinct pairs: 1378
- Separated by abelian quotients: 1338 (97.1%)
- Unseparated: 40 pairs (conjugate pairs requiring non-abelian groups)

The unseparated pairs are exactly conjugate pairs (e.g., a vs b·a·b⁻¹), confirming that non-abelian quotients are needed for full separation. This is consistent with the known residual finiteness of free groups.

## 7. Discussion

### 7.1 Significance

The main contribution is conceptual: adjunctions are not merely existence statements but **compiler construction mechanisms**. The adjunction transpose is literally a correct-by-construction interpreter. This reframes a classical area of abstract algebra as an applied tool for software verification.

### 7.2 Limitations

- The current instantiation covers only equational theories (monoids, groups, abelian groups). Extending to theories with non-trivial axioms (e.g., commutative monoids, rings) requires constructing the appropriate free functors and adjunctions.
- The optimizer soundness theorem covers only generator-preserving endomorphisms. More sophisticated optimizations (constant folding, dead code elimination) would require richer algebraic structure.
- Performance considerations are not addressed: the categorical framework provides correctness guarantees but does not optimize for runtime efficiency.

### 7.3 Open Questions

1. Can the framework be extended to algebraic effects and handlers?
2. Is there a systematic way to compose adjunction-derived compilers for multi-pass compilation?
3. Can the optimizer soundness theorem be generalized to quotient algebras (congruence-based optimization)?

## 8. Future Work

1. **Free semirings and arithmetic circuits**: Instantiate the framework for free semirings to generate verified evaluators for arithmetic circuits.
2. **Lawvere theories**: Generalize from individual algebraic theories to Lawvere's categorical framework for universal algebra.
3. **Chains of adjunctions**: Model multi-pass compilation as compositions of adjoint functors.
4. **Operadic syntax**: Extend to operads for languages with variable binding and higher-order functions.
5. **Algebraic effects**: Apply to Plotkin-Power algebraic effects for verified effect handler synthesis.

## 9. References

1. S. Awodey, *Category Theory*, 2nd ed., Oxford University Press, 2010.
2. S. Eilenberg and S. Mac Lane, "General theory of natural equivalences," *Transactions of the AMS*, 58(2), 1945.
3. D.M. Kan, "Adjoint functors," *Transactions of the AMS*, 87(2), 1958.
4. F.W. Lawvere, *Functorial Semantics of Algebraic Theories*, PhD thesis, Columbia University, 1963.
5. S. Mac Lane, *Categories for the Working Mathematician*, Springer, 1971.
6. E. Riehl, *Category Theory in Context*, Dover, 2016.
7. G. Plotkin and J. Power, "Algebraic operations and generic effects," *Applied Categorical Structures*, 11(1), 2003.
8. The Mathlib Community, *Mathlib: the Lean 4 mathematics library*, https://github.com/leanprover-community/mathlib4.
