# Formalizing Homotopy Type Theory in Classical Type Theory: Eckmann-Hilton, Encode-Decode, and Structure Identity

## Abstract

We present a formalization of core homotopy type theory (HoTT) concepts within Lean 4's classical type theory with Mathlib. Our development includes: (1) a complete proof of the Eckmann-Hilton argument showing that two unital binary operations satisfying the interchange law must coincide and be commutative; (2) an abstract encode-decode framework for computing path spaces; (3) a covering space theory with monodromy homomorphism; (4) fiber sequence exactness; (5) the Structure Identity Principle for algebraic signatures; (6) a custom Type-valued path type (`HPath`) with full groupoid structure and UIP; and (7) the fundamental groupoid construction. All proofs are constructive where possible, with the Eckmann-Hilton theorem requiring no axioms at all. We discuss the relationship between HoTT concepts and their classical analogs, and propose a conjecture on higher Eckmann-Hilton stabilization.

## 1. Introduction

Homotopy type theory (HoTT) [Univalent Foundations Program, 2013] proposes an alternative foundation for mathematics based on Martin-Löf type theory augmented with the univalence axiom. While HoTT is natively implemented in proof assistants like Agda with `--without-K`, formalizing its key ideas in classical type theory (as used by Lean 4) serves two purposes:

1. **Cross-pollination**: HoTT concepts like the encode-decode method and fiber characterization of equivalences are useful mathematical tools regardless of foundational commitments.

2. **Comparison**: By building HoTT structures in classical type theory, we can precisely identify which results depend on the univalence axiom and which are consequences of general type-theoretic reasoning.

Our formalization is built on Lean 4 with Mathlib and consists of approximately 500 lines of verified code with zero uses of `sorry`.

## 2. The Eckmann-Hilton Argument

### 2.1 Setup

**Definition 2.1** (Interchange System). An *interchange system* on a type M consists of:
- Two binary operations ⋆, ◇ : M → M → M
- A shared unit e : M
- Unit laws: e ⋆ a = a = a ⋆ e and e ◇ a = a = a ◇ e for all a
- The interchange law: (a ⋆ b) ◇ (c ⋆ d) = (a ◇ c) ⋆ (b ◇ d)

### 2.2 Main Theorem

**Theorem 2.2** (Eckmann-Hilton). In any interchange system (M, ⋆, ◇, e):
1. ⋆ = ◇ (the operations coincide)
2. ⋆ is commutative

*Proof.* Step 1 (Operations coincide):
```
a ◇ b = (a ⋆ e) ◇ (e ⋆ b)     [unit laws for ⋆]
      = (a ◇ e) ⋆ (e ◇ b)     [interchange]
      = a ⋆ b                  [unit laws for ◇]
```

Step 2 (Commutativity):
```
a ⋆ b = a ◇ b                  [Step 1]
      = (e ⋆ a) ◇ (b ⋆ e)     [unit laws for ⋆]
      = (e ◇ b) ⋆ (a ◇ e)     [interchange]
      = b ⋆ a                  [unit laws for ◇]
```

### 2.3 Significance

The Eckmann-Hilton argument explains why π₂(X, x₀) is abelian: the two-dimensional loop space Ω²X carries two natural compositions (vertical and horizontal) that share the constant loop as unit and satisfy interchange by the naturality of composition. The theorem then forces both compositions to be equal and commutative.

Our formalization requires **no axioms** — it is purely equational reasoning in any type theory.

## 3. The Encode-Decode Method

### 3.1 Framework

**Definition 3.1** (Encode-Decode Data). For a pointed type (B, b₀), encode-decode data consists of:
- A code family Code : B → Type
- A base code code₀ : Code b₀
- An encoding map encode : (b₀ = b) → Code b
- A decoding map decode : Code b → (b₀ = b)
- Reflexivity: encode(refl) = code₀
- Retraction: decode(encode(p)) = p

**Theorem 3.2** (Encode-Decode Equivalence). If additionally encode(decode(c)) = c for all codes c, then encode is a bijection between the path space (b₀ = b) and Code b.

### 3.2 Applications

The encode-decode method is the standard technique for computing:
- π₁(S¹) ≅ ℤ (Code(base) = ℤ, encode counts winding, decode builds loops)
- π₁(BG) ≅ G for a group G
- Path spaces of pushouts and other higher inductive types

## 4. Covering Space Theory

### 4.1 Definitions

**Definition 4.1** (Covering Space). A covering space over B consists of:
- A fiber family Fiber : B → Type
- A lifting operation lift : (b₁ = b₂) → Fiber b₁ → Fiber b₂
- lift(refl) = id (identity lift)
- lift(p · q) = lift(q) ∘ lift(p) (functoriality)

### 4.2 Monodromy

**Definition 4.2**. The monodromy of a loop γ at b is monodromy(b, γ) = lift(γ) : Fiber b → Fiber b.

**Theorem 4.3** (Monodromy Homomorphism). Monodromy respects path composition:
monodromy(b, γ₁ · γ₂) = monodromy(b, γ₂) ∘ monodromy(b, γ₁)

This establishes the monodromy representation π₁(B, b) → Aut(Fiber b).

**Theorem 4.4**. The trivial covering (constant fiber, identity lift) has trivial monodromy.

## 5. Fiber Sequences and Exactness

**Definition 5.1** (Fiber Sequence). A fiber sequence F →^{incl} E →^{proj} B with basepoint b₀ satisfies:
- proj(incl(f)) = b₀ for all f : F
- For all e with proj(e) = b₀, there exists f with incl(f) = e
- incl is injective

**Theorem 5.2** (Exactness). (∃ f, incl(f) = e) ↔ (proj(e) = b₀)

**Theorem 5.3** (Fiber Equivalence). The map f ↦ (incl(f), proof) is a bijection from F to {e : E | proj(e) = b₀}.

## 6. Structure Identity Principle

### 6.1 Algebraic Signatures and Isomorphisms

**Definition 6.1**. An algebraic signature AlgSig = (carrier, op) consists of a type with a binary operation. An isomorphism AlgIso(A, B) consists of an equivalence equiv : A.carrier ≃ B.carrier preserving the operation.

### 6.2 Transfer Theorems

**Theorem 6.2** (SIP for Associativity). If A is associative and A ≅ B, then B is associative.

**Theorem 6.3** (SIP for Commutativity). If A is commutative and A ≅ B, then B is commutative.

**Theorem 6.4** (SIP for Identity). If eA is an identity for A and A ≅ B via iso, then iso(eA) is an identity for B.

*Proof strategy.* In each case, we use the surjectivity of iso.equiv to write arbitrary elements of B as images of elements of A, then use op_compat to reduce the B-equation to an A-equation.

## 7. HPath: Type-Valued Identity Types

### 7.1 Motivation

In Lean 4, Eq lives in Prop, making all proof-irrelevance results trivially true. To capture the genuine mathematical content of HoTT path algebra, we define HPath as an inductive type in Type.

### 7.2 Groupoid Structure

HPath satisfies all groupoid laws:
- **Associativity**: (p · q) · r = p · (q · r)
- **Left/right identity**: refl · p = p = p · refl
- **Left/right inverse**: p⁻¹ · p = refl = p · p⁻¹
- **Involution**: (p⁻¹)⁻¹ = p

### 7.3 UIP (Hedberg's Theorem)

**Theorem 7.1** (HPath UIP). Any two HPaths between the same endpoints are equal: for p q : HPath a b, p = q.

This is proved by pattern matching: since HPath has a single constructor (refl), any two terms at the same type index must both be refl.

### 7.4 Transport and ap

Transport along HPath is functorial:
- transport(p · q, x) = transport(q, transport(p, x))
- transport commutes with natural transformations

The action on paths (ap) is also functorial:
- ap f (p · q) = ap f p · ap f q
- ap f (p⁻¹) = (ap f p)⁻¹
- ap id p = p
- ap (g ∘ f) p = ap g (ap f p)

## 8. The Fundamental Groupoid

We construct the fundamental groupoid of a type A using PLift(a = b) as the Hom-type (lifting Prop-valued equality to Type). This satisfies all groupoid axioms.

**Theorem 8.1**. The automorphism group at any point satisfies the group axioms (identity, associativity, inverses).

## 9. Finite Univalence

**Theorem 9.1**. m = n ↔ Nonempty(Fin m ≃ Fin n).

This is a constructive instance of the univalence axiom restricted to finite types.

## 10. Equivalence via Contractible Fibers

**Theorem 10.1**. A function f : A → B is bijective if and only if every fiber {a : A | f(a) = b} is contractible (has a center with all other elements equal to it).

## 11. Conjecture: Higher Eckmann-Hilton Stabilization

**Conjecture**. For n ≥ 2, the n-fold iterated loop space Ωⁿ(A, a) carries a canonical InterchangeSystem structure. The Eckmann-Hilton theorem forces all n compositions to coincide and be commutative.

**Computational test**: Verify for Ω²(A, a) that vertical and horizontal composition satisfy interchange.

**Prediction**: Stabilization occurs at exactly n = 2, matching π₁ non-abelian, πₙ abelian for n ≥ 2.

## 12. Discussion

### 12.1 Axiom Usage

Our formalization is remarkably axiom-light:
- The Eckmann-Hilton theorem requires **no axioms**
- HPath groupoid laws require **no axioms**
- Transport and ap functoriality require **no axioms**
- The monodromy homomorphism uses only **Quot.sound** (via funext)
- The SIP theorems use only **Quot.sound**

### 12.2 Classical vs. Constructive

Working in Lean 4's classical type theory means:
- UIP for Eq is automatic (proof irrelevance)
- We cannot directly formalize univalence (it contradicts UIP for a general universe)
- We can formalize *consequences* of univalence (e.g., finite univalence, SIP)
- HPath provides a constructive alternative for demonstrating groupoid structure

### 12.3 Relationship to Existing Work

Our development complements the existing catalog entries:
- `Bridges/HoTTFoundations.lean`: Consistency results, winding numbers, foundational systems
- `Logic/HoTT/Basic.lean`: Contractible types, QEquiv, singleton contraction
- `Logic/HoTT/Foundations.lean`: IdentitySystem, Contractible structure

We extend these with the Eckmann-Hilton argument, encode-decode framework, covering spaces, and Type-valued path algebra.

## 13. Future Work

1. **Formalize the Seifert-van Kampen theorem** for pushout-like constructions
2. **Higher Eckmann-Hilton**: Extend the interchange argument to n-fold loop spaces
3. **Encode-decode for concrete types**: Apply the framework to compute π₁ of specific types
4. **Categorical semantics**: Connect our AlgSig/AlgIso to Mathlib's category theory library

## References

1. Univalent Foundations Program. *Homotopy Type Theory: Univalent Foundations of Mathematics*. Institute for Advanced Study, 2013.
2. Eckmann, B. and Hilton, P.J. "Group-like structures in general categories." *Mathematische Annalen*, 145:227–255, 1962.
3. Licata, D. and Shulman, M. "Calculating the fundamental group of the circle in homotopy type theory." *LICS*, 2013.
4. Rijke, E. *Introduction to Homotopy Type Theory*. Cambridge University Press, 2023.
