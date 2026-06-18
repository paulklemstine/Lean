# A Congruence-Level Tropical Nullstellensatz for Idempotent Function Semirings

## Abstract

We formalize in Lean 4 a congruence-level tropical Nullstellensatz for function semirings. Given finitely many equations f₁ = g₁, …, fₙ = gₙ in a semiring of functions X → S, the *radical congruence* — the set of all function pairs that must agree wherever all generating equations are simultaneously satisfied — coincides with the *vanishing congruence* of the common solution locus. We establish the main theorem, prove that the vanishing congruence forms a semiring congruence (compatible with both addition and multiplication), construct a Galois connection between point sets and congruences, and demonstrate antitonicity, idempotence, and setoid-level formulations. All results are machine-verified with no axioms beyond `propext` and `Quot.sound`.

## 1. Introduction

### 1.1 From Ideals to Congruences

Hilbert's Nullstellensatz is one of the cornerstones of algebraic geometry. In its classical form, it establishes a dictionary between ideals in a polynomial ring k[x₁,…,xₙ] and algebraic varieties in affine space kⁿ: the radical of an ideal I equals the vanishing ideal of the zero set V(I).

When we move from rings to semirings — algebraic structures where subtraction is not available — ideals lose their primacy. The correct replacement is *congruences*: equivalence relations compatible with the algebraic operations. This shift is not merely cosmetic. In a ring, every congruence is determined by its kernel (an ideal), so the two languages are equivalent. In a semiring, congruences carry strictly more information.

### 1.2 The Tropical Setting

Tropical mathematics operates in idempotent semirings where a + a = a. The prototypical example is the max-plus semiring (ℝ ∪ {-∞}, max, +), fundamental in optimization, control theory, and algebraic geometry. The "tropical Nullstellensatz" relates tropical polynomial equations to their solution sets, analogous to the classical theorem.

Previous work has established ideal-level tropical Nullstellensätze, where the vanishing condition is f(x) = ⊥ (the additive identity/bottom element). Our contribution upgrades this to the congruence level, where the fundamental objects are *equations* f = g rather than *vanishing conditions* f = ⊥.

### 1.3 Contribution

We formalize the following theorem:

**Theorem (Congruence-Level Tropical Nullstellensatz).** *For any finite set R of equation pairs in a function semiring X → S, the radical congruence of R equals the vanishing congruence of the zero set of R:*

```
radical(R) = vanishing(V(R))
```

*where:*
- *V(R) = {x ∈ X | ∀ (f,g) ∈ R, f(x) = g(x)}  (solution locus)*
- *vanishing(V) = {(f,g) | ∀ x ∈ V, f(x) = g(x)}  (vanishing congruence)*
- *radical(R) = {(f,g) | ∀ x, (∀ (p,q) ∈ R, p(x) = q(x)) → f(x) = g(x)}  (radical congruence)*

This is supplemented by:
- Proof that vanishing congruences form setoids (equivalence relations)
- Compatibility of the vanishing congruence with pointwise + and ×
- A Galois connection between point sets and congruences
- Antitonicity of both V(·) and I_c(·)
- Bridge theorems connecting to ideal-level formulations

## 2. Definitions

### 2.1 Zero Set of a Relation

Given a finite set R of equation pairs (fᵢ, gᵢ) where fᵢ, gᵢ : X → S, the *zero set* (or *solution locus*) is:

```
V(R) = {x ∈ X | ∀ (f,g) ∈ R,  f(x) = g(x)}
```

This is the set of points where all equations are simultaneously satisfied.

### 2.2 Vanishing Congruence

Given a subset V ⊆ X, the *vanishing congruence* is:

```
I_c(V) = {(f,g) : (X → S)² | ∀ x ∈ V,  f(x) = g(x)}
```

This consists of all function pairs that are pointwise equal on V.

### 2.3 Radical Congruence

Given a finite set R of equation pairs, the *radical congruence* is:

```
rad(R) = {(f,g) | ∀ x ∈ X,  (∀ (p,q) ∈ R, p(x) = q(x)) → f(x) = g(x)}
```

This is the set of all function pairs that must agree at any point where all equations in R are satisfied. It is the congruence-geometric analogue of the radical ideal.

## 3. Main Results

### 3.1 The Nullstellensatz

**Theorem 3.1** (`radical_eq_vanishing_zeroSet`). *For any finite set R of equation pairs,*

```
rad(R) = I_c(V(R))
```

*Proof.* By set extensionality. A pair (f,g) belongs to rad(R) if and only if for every x, the condition "all pairs in R agree at x" implies f(x) = g(x). But "all pairs in R agree at x" is exactly the condition x ∈ V(R). So rad(R) = {(f,g) | ∀ x ∈ V(R), f(x) = g(x)} = I_c(V(R)). □

### 3.2 Equivalence Relation Structure

**Theorem 3.2** (`vanishingSetoid`, `radicalSetoid`). *Both I_c(V) and rad(R) define equivalence relations (setoids) on the function space X → S.*

The reflexivity, symmetry, and transitivity of pointwise equality on a fixed subset are immediate.

### 3.3 Semiring Congruence Properties

**Theorem 3.3** (`vanishing_compatible_add`, `vanishing_compatible_mul`). *If (f₁,g₁) and (f₂,g₂) belong to I_c(V), then so do (f₁+f₂, g₁+g₂) and (f₁·f₂, g₁·g₂).*

*Proof.* If f₁(x) = g₁(x) and f₂(x) = g₂(x) for all x ∈ V, then (f₁+f₂)(x) = f₁(x)+f₂(x) = g₁(x)+g₂(x) = (g₁+g₂)(x) by congruence of the addition operation, and similarly for multiplication. □

### 3.4 Galois Connection

**Theorem 3.4** (`galoisConnection`). *For any finset R and set V,*

```
R ⊆ I_c(V)  ⟺  V ⊆ V(R)
```

This establishes a Galois connection between the posets of point sets (ordered by inclusion) and congruences (ordered by reverse inclusion).

### 3.5 Antitonicity

**Theorem 3.5.** *The operators V(·) and I_c(·) are antitone:*
- *V ⊆ W implies I_c(W) ⊆ I_c(V)*
- *R₁ ⊆ R₂ implies V(R₂) ⊆ V(R₁)*

### 3.6 Boundary Cases

- V(∅) = X  (the empty set of equations is satisfied everywhere)
- I_c(∅) = (X → S)²  (the empty point set imposes no constraints)
- I_c(X) = {(f,g) | f = g}  (all points distinguish all functions)
- rad(∅) = {(f,g) | f = g}  (the diagonal, since all points are solutions)

## 4. Bridge to Ideal-Level Formulations

When S has a bottom element ⊥, equations of the form f = ⊥ (where ⊥ denotes the constant-bottom function) recover the ideal-level setting. We prove:

**Theorem 4.1** (`zeroSet_singleton_eq_idealZeroSet`). *For any f : X → S,*

```
V({(f, ⊥)}) = {x | f(x) = ⊥}
```

**Theorem 4.2** (`vanishing_bot_eq_idealOfSet`). *The vanishing congruence restricted to pairs (f, ⊥) recovers the ideal-level vanishing ideal:*

```
(f, ⊥) ∈ I_c(V)  ⟺  ∀ x ∈ V, f(x) = ⊥
```

These bridge theorems show that the congruence-level formulation strictly generalizes the ideal-level one.

## 5. Discussion: A New Language for Tropical Geometry

### For the General Reader

Imagine you have a system of equations, but you're working in a world where you can't subtract — only add and multiply. This is the world of *semirings*, and it arises naturally in many computational settings: the "max-plus" algebra of scheduling and optimization, Boolean logic, and the tropical geometry underlying modern algebraic geometry.

In ordinary algebra, when you want to study the solutions of equations like f(x) = g(x), you can rearrange to f(x) - g(x) = 0 and study the single quantity f - g. The solutions are the "zero set" of f - g. But without subtraction, you can't form f - g. Instead, you must work directly with the *equation* f = g as a fundamental object.

The mathematical structures that encode "equations modulo consequences" are called *congruences* — equivalence relations that respect the algebraic operations. Our theorem says: **the algebraic consequences of a system of equations are exactly the equations that hold on the common solution set.** This is intuitively obvious but mathematically precise, and the formalization ensures there are no hidden assumptions.

Think of it like this: if you know that certain equations hold at every point of a region, and you want to know what other equations must also hold there, the answer is simple — exactly the equations that hold at every point of that region. The "radical" closure doesn't add anything beyond what the geometry already determines.

### Historical Context

The classical Nullstellensatz, proved by David Hilbert in 1893, is one of the founding theorems of algebraic geometry. It establishes a dictionary between algebra (ideals) and geometry (varieties). Our theorem extends this dictionary to the semiring setting, where the correct algebraic objects are congruences rather than ideals.

The tropical Nullstellensatz has been studied by several authors in the context of tropical polynomial rings. Our contribution is formalized (machine-verified), works at full generality (arbitrary function semirings, not just polynomials), and operates at the correct categorical level (congruences rather than ideals).

## 6. Applications

### 6.1 Neural Network Identifiability

In the study of neural network identifiability, one asks: given a network's input-output behavior, what can we infer about the internal parameters? ReLU networks naturally correspond to tropical rational functions. The congruence Nullstellensatz provides the algebraic framework for determining when two parameterizations produce identical behavior: they do if and only if they satisfy the vanishing congruence of the parameter-space solution locus.

### 6.2 Tropical Optimization

In operations research, tropical semirings model scheduling, routing, and resource allocation. Systems of tropical equations encode timing constraints. The Nullstellensatz tells us that any consequence of these constraints is determined by the feasible set — there are no "hidden" algebraic consequences beyond the geometric ones.

### 6.3 Formal Verification

The machine-verified nature of this result makes it suitable as a foundation for verified software that reasons about tropical algebraic systems. The Lean formalization can be imported and used as a library for further developments in formalized tropical geometry.

## 7. Formalization Details

The full formalization comprises approximately 340 lines of Lean 4 code using Mathlib. Key design decisions:

1. **Maximal generality**: The types X and S are completely unrestricted. No semiring, order, or algebraic structure on S is required for the core theorem. Algebraic structure is only assumed where needed (compatibility with + and × requires those operations on S).

2. **Setoid formulation**: We provide both set-level (`radical`, `vanishing`) and setoid-level (`radicalSetoid`, `vanishingSetoid`) formulations, connected by definitional equalities.

3. **Clean axiom usage**: The main theorem depends only on `propext` and `Quot.sound` — the minimal axioms needed for set extensionality.

## 8. Future Directions

1. **Intrinsic semiring-congruence radical**: Show that the congruence radical defined via the lattice of semiring congruences agrees with the ideal-induced radical.

2. **Kernel congruence theorem**: Prove that the kernel of the evaluation map `A → Fun(V, S)` equals the vanishing congruence, giving a first isomorphism theorem.

3. **Quotient coordinate semiring**: Establish the universal property of the quotient `A / I_c(V)` as a coordinate semiring for the tropical variety V.

4. **Tropical elimination**: Show that projections of congruence-defined loci remain congruence-definable.

5. **Tensor-product Nullstellensatz**: Lift the congruence Nullstellensatz to tensor products of function semirings.

---

*All theorems in this paper are machine-verified in Lean 4 using Mathlib. The source code is available in `Catalog/Bridges/EML/TropicalCongruenceNullstellensatz.lean`.*
