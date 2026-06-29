# Formal Bridges Between Homotopy Type Theory and Classical Mathematics in Lean 4

## Abstract

We develop a formal library establishing bridges between Homotopy Type Theory (HoTT) and classical mathematics within Lean 4's type-theoretic framework. Our contributions include: (1) a complete proof of the Eckmann-Hilton argument showing that two unital operations with interchange coincide and are commutative; (2) a fiber-based characterization of bijections connecting HoTT equivalences to classical bijective functions; (3) the h-level hierarchy with closure properties under products, function spaces, and subtypes; (4) a Structure Identity Principle for algebraic structures with automatic transport of commutativity and associativity along isomorphisms; and (5) models of the fundamental group of the circle via winding numbers. All results are machine-verified with no axioms beyond the standard ones (propext, Classical.choice, Quot.sound). We identify the "ladder of univalence" — a pattern connecting decidable finite univalence through tropical univalence to the full topological axiom — as a unifying theme.

## 1. Introduction

Homotopy Type Theory (HoTT) reinterprets the identity type of Martin-Löf type theory through the lens of homotopy theory: types are spaces, terms are points, and equalities are paths. This geometric perspective yields powerful new principles — univalence, higher inductive types, and the encode-decode method — that have revolutionized the foundations of mathematics.

However, HoTT is typically developed in specialized type theories (cubical Agda, cubical type theory) that differ significantly from the classical type theories used in mainstream formalization (Lean 4, Isabelle/HOL, Coq). A central challenge is to *bridge* HoTT concepts and results into classical settings, making them available to the broader formalization community.

In this paper, we address this challenge by developing HoTT-inspired structures and theorems within Lean 4's classical type theory. Our approach is to model HoTT concepts as mathematical structures (typeclasses, structures, definitions) and prove theorems about these models that reflect genuine homotopical insights. While our models cannot capture the full intensional content of HoTT (Lean 4 has uniqueness of identity proofs for most types), they faithfully represent the *algebraic* content and provide practical tools for proof engineering.

### 1.1 Contributions

1. **The Eckmann-Hilton Argument** (§3): We formalize and prove the complete Eckmann-Hilton theorem: given a type M with two unital binary operations sharing a unit and satisfying the interchange law, both operations are pointwise equal and commutative. This is the algebraic foundation for the abelianness of higher homotopy groups.

2. **H-Level Hierarchy** (§2): We define the first three h-levels (contractible, mere proposition, h-set) and prove the hierarchy IsContr → IsMereProp → IsHSet, along with closure under products, dependent function spaces, and subtypes.

3. **Fiber Characterization** (§4): We prove that a function is bijective if and only if every fiber has a unique element, and that functions with contractible fibers are bijective. This connects the HoTT notion of equivalence to classical bijections.

4. **Structure Identity Principle** (§5): We prove that algebraic properties (commutativity, associativity) transport along isomorphisms of magma structures. This is a concrete instance of the SIP from HoTT.

5. **Transport Algebra** (§6): We formalize the transport operation and prove its key properties: functoriality (transport along p·q = transport q ∘ transport p) and the dependent action on paths (apd).

## 2. The H-Level Hierarchy

### 2.1 Definitions

We define the first three levels of the homotopy-theoretic hierarchy:

**Definition 2.1** (Contractible). A type A is *contractible* (written `IsContr A`) if there exists a center point c : A such that every element equals c:
```
IsContr A := ∃ c : A, ∀ a : A, a = c
```

**Definition 2.2** (Mere Proposition). A type A is a *mere proposition* (written `IsMereProp A`) if any two elements are equal:
```
IsMereProp A := ∀ a b : A, a = b
```

**Definition 2.3** (H-Set). A type A is an *h-set* (written `IsHSet A`) if all identity proofs between the same elements are equal:
```
IsHSet A := ∀ (a b : A) (p q : a = b), p = q
```

### 2.2 The Hierarchy

**Theorem 2.4** (Contractible ⟹ Mere Proposition). If A is contractible with center c, then for any a, b : A, we have a = c and b = c, hence a = b by transitivity.

**Theorem 2.5** (Mere Proposition ⟹ H-Set). If A is a mere proposition, then A is a subsingleton, and any two proofs of equality in a subsingleton type are equal by proof irrelevance.

*Remark*: In Lean 4's type theory, the passage from Theorem 2.5 uses the fact that Lean's kernel has UIP (uniqueness of identity proofs) for all types. In a HoTT setting, this theorem requires a more careful argument (Hedberg's theorem for decidable equality, or direct path manipulation for propositions).

### 2.3 Closure Properties

**Theorem 2.6** (Products). Products preserve each h-level:
- `IsContr A ∧ IsContr B → IsContr (A × B)`: center is (cA, cB)
- `IsMereProp A ∧ IsMereProp B → IsMereProp (A × B)`: by Prod.ext

**Theorem 2.7** (Function Spaces). Dependent function types into mere propositions are mere propositions: if B a is a mere proposition for all a, then (∀ a, B a) is a mere proposition, by function extensionality.

**Theorem 2.8** (Subtypes). Subtypes of mere propositions are mere propositions.

## 3. The Eckmann-Hilton Argument

### 3.1 Setup

**Definition 3.1** (Eckmann-Hilton Data). An *Eckmann-Hilton datum* on a type M consists of:
- Two binary operations op₁, op₂ : M → M → M
- A shared unit element e : M
- Unit laws: op₁(e, a) = a = op₁(a, e) and op₂(e, a) = a = op₂(a, e)
- The interchange law: op₂(op₁(a,b), op₁(c,d)) = op₁(op₂(a,c), op₂(b,d))

### 3.2 Main Results

**Theorem 3.2** (Operation Equality). For any Eckmann-Hilton datum D on M and elements a, b : M:
```
D.op₁ a b = D.op₂ a b
```

*Proof*. We compute:
```
D.op₂ a b = D.op₂ (D.op₁ a e) (D.op₁ e b)     [unit laws for op₁]
          = D.op₁ (D.op₂ a e) (D.op₂ e b)     [interchange]
          = D.op₁ a b                            [unit laws for op₂]
```

**Theorem 3.3** (Commutativity). For any Eckmann-Hilton datum D on M and elements a, b : M:
```
D.op₁ a b = D.op₁ b a
```

*Proof*. Using Theorem 3.2:
```
D.op₁ a b = D.op₂ a b                            [Theorem 3.2]
          = D.op₂ (D.op₁ e a) (D.op₁ b e)       [unit laws for op₁]
          = D.op₁ (D.op₂ e b) (D.op₂ a e)       [interchange]
          = D.op₁ b a                              [unit laws for op₂]
```

### 3.3 Topological Significance

In a pointed topological space (X, x₀), the n-th homotopy group πₙ(X, x₀) is defined as the set of homotopy classes of maps (Sⁿ, *) → (X, x₀). For n ≥ 2, the double loop space Ω²X carries two composition operations (horizontal and vertical) satisfying the interchange law. The Eckmann-Hilton argument then shows that πₙ(X) is abelian for n ≥ 2.

## 4. Fiber Characterization of Equivalences

### 4.1 Homotopy Fibers

**Definition 4.1**. The *homotopy fiber* of f : A → B over b : B is:
```
HFiber f b := { a : A // f a = b }
```

### 4.2 Main Result

**Theorem 4.2** (Fiber-Bijection Equivalence). A function f : A → B is bijective if and only if every fiber has exactly one element:
```
Function.Bijective f ↔ ∀ b : B, ∃! a : A, f a = b
```

*Proof*. (⟹) Surjectivity gives existence; injectivity gives uniqueness. (⟸) Existence gives surjectivity; uniqueness gives injectivity.

**Theorem 4.3** (Contractible Fibers ⟹ Bijective). If every fiber of f is contractible (in the sense of `IsContr`), then f is bijective.

### 4.3 Connection to HoTT Equivalences

In HoTT, a function f : A → B is an *equivalence* if all its fibers are contractible. Theorem 4.3 bridges this to the classical notion: HoTT equivalences give bijections. The converse holds in HoTT but requires the univalence axiom.

**Definition 4.4** (Half-Adjoint Equivalence). A *half-adjoint equivalence* consists of:
- An inverse function g : B → A
- Left and right homotopies: g ∘ f ~ id and f ∘ g ~ id
- A coherence condition (the "adjointness"): the two ways of showing f(g(f(a))) = f(a) agree

We prove that half-adjoint equivalences are bijective.

## 5. Structure Identity Principle

### 5.1 Motivation

In HoTT, the univalence axiom implies that identity of types is equivalent to equivalence of types. For structured types (groups, rings, topological spaces), this specializes to: identity is equivalent to *structured* equivalence (isomorphism preserving the structure).

### 5.2 Formalization

We define magmas (types with a binary operation, no axioms) and their homomorphisms and isomorphisms. The key results are:

**Theorem 5.1** (Commutativity Transport). If M is a commutative magma and φ : M ≅ N is a magma isomorphism, then N is commutative.

**Theorem 5.2** (Associativity Transport). If M is an associative magma and φ : M ≅ N is a magma isomorphism, then N is associative.

*Proof technique*: Use surjectivity of φ to pull back elements from N to M, apply the algebraic law in M, then push forward using the homomorphism property.

## 6. Transport Algebra

We formalize the transport operation and its key properties:

**Definition 6.1**. `transport P p : P a → P b` for p : a = b.

**Theorem 6.2** (Functoriality). `transport P (p · q) = transport P q ∘ transport P p`

**Theorem 6.3** (Dependent Action). `transport P p (f a) = f b` for f : ∀ a, P a

**Theorem 6.4** (Naturality). `transport (P ∘ f) p = transport P (ap f p)`

## 7. Winding Numbers and π₁(S¹)

We model the fundamental theorem of the circle, π₁(S¹) ≅ ℤ, by constructing the winding number as a group isomorphism. In the full HoTT development, this uses the encode-decode method with the universal cover of S¹ defined as a higher inductive type. Our model captures the end result: a concrete group isomorphism ℤ ≃+ ℤ.

## 8. Discussion

### 8.1 Limitations

Our development operates within Lean 4's classical type theory, which has UIP (uniqueness of identity proofs). This means:
- We cannot distinguish between different h-levels above 0 (all types are h-sets in Lean 4)
- Higher inductive types must be simulated via quotients or inductive types
- The univalence axiom cannot be stated in its full generality

Despite these limitations, the *algebraic* content of HoTT translates faithfully.

### 8.2 The Ladder of Univalence

A key observation from this work is the existence of a "ladder of univalence" — a spectrum of increasingly powerful instances of the univalence principle:

1. **Decidable finite univalence**: For finite types (Fin n), equivalence (bijection) determines identity (equal cardinality). This is trivially decidable.
2. **Tropical univalence**: For tropical semiring structures, isomorphism (permutation equivalence of weight matrices) determines identity.
3. **Full univalence**: For arbitrary types, equivalence determines identity.

Each step in the ladder adds complexity but also expressive power.

## 9. Future Work

1. **Cubical models**: Extend the cubical semantics framework to compute π₂(S²) ≅ ℤ using formal encode-decode.
2. **Higher inductive types**: Model pushouts, truncations, and the James construction.
3. **Automated SIP**: Automatically transport all algebraic properties along isomorphisms.
4. **Blakers-Massey**: Formalize the connectivity theorem for pushouts.

## References

1. The Univalent Foundations Program. *Homotopy Type Theory: Univalent Foundations of Mathematics*. Institute for Advanced Study, 2013.
2. Eckmann, B., Hilton, P.J. "Group-like structures in general categories I: Multiplications and comultiplications." *Mathematische Annalen*, 145, 227-255, 1962.
3. Licata, D.R., Shulman, M. "Calculating the Fundamental Group of the Circle in Homotopy Type Theory." *LICS*, 2013.
4. Rijke, E. *Introduction to Homotopy Type Theory*. Cambridge University Press, 2023.
5. Coquand, T., Huber, S., Mörtberg, A. "On Higher Inductive Types in Cubical Type Theory." *LICS*, 2018.
