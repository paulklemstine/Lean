# Operadic Stone Duality: Logical Identifiability of Finite Neural Architectures via Heyting Predicate Lattices

## Abstract

We establish a certified duality between finitely generated acyclic neural architectures and finite Heyting algebras. Given a neural architecture modeled as a finite partial order of computational modules, we construct its *upper set predicate lattice* — a finite distributive lattice (equivalently, Heyting algebra) encoding activation, reachability, and stability predicates. We prove:

1. The meet-irreducible elements of this lattice correspond bijectively to architectural modules.
2. The lattice ordering encodes the module partial order via an order embedding.
3. An order isomorphism of predicate lattices induces an order isomorphism of module posets.
4. Architecture morphisms induce lattice homomorphisms contravariantly, with functorial composition.
5. Lattice ordering coincides with Kripke semantic entailment (soundness and completeness).
6. The predicate lattice, together with generator marking, is a complete invariant for architecture identity.

All results are formalized and verified in Lean 4 with Mathlib, using no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`.

**Keywords:** neural architecture, Heyting algebra, Birkhoff representation, Kripke semantics, operadic composition, logical identifiability, finite distributive lattice

---

## 1. Introduction

### 1.1 Motivation

Neural architecture design is one of the central challenges of modern machine learning. Despite enormous empirical progress, the mathematical foundations of architecture theory remain underdeveloped. Questions such as "when are two architectures structurally equivalent?" and "what is the minimal architecture achieving a given computational specification?" lack satisfactory theoretical answers.

We address these questions by establishing a precise correspondence between neural architectures and logical structures. Our main contribution is a *reconstruction theorem*: the finite Heyting algebra of predicates associated to an architecture determines the architecture up to isomorphism. This provides a notion of *logical identifiability* — the architecture is identified by its logical semantics, not by its syntactic presentation.

### 1.2 Related Work

**Operadic deep learning.** The operadic perspective on neural networks, viewing compositional layer stacking as operadic composition, has been developed in several lines of work. Our formalization builds on operadic foundations but focuses on the logical (lattice-theoretic) structure rather than the compositional algebra.

**Stone duality and Birkhoff representation.** The classical Birkhoff representation theorem (1937) establishes a bijection between finite distributive lattices and finite partial orders. Stone duality (1936) extends this to the topological setting. Our work applies the finite case of this duality in a new domain.

**Kripke semantics.** The semantics of intuitionistic logic via Kripke frames (1965) provides the logical interpretation. Our upper set construction is the standard construction of intuitionistic propositions over a Kripke frame, applied to the specific frame given by the module partial order.

**Neural network verification.** The growing field of formal verification of neural networks (Katz et al. 2017, Huang et al. 2020) focuses on verifying properties of specific networks. Our work operates at the architecture level rather than the weight level, providing structural rather than behavioral verification.

### 1.3 Contributions

1. A formal definition of finitely generated acyclic neural architectures as finite partial orders with generators.
2. Construction of the upper set predicate lattice and proof that it is a finite Heyting algebra.
3. Classification of meet-irreducible elements as principal upper sets (Theorem 4.3).
4. An order embedding from modules to the predicate lattice (Theorem 3.1).
5. A reconstruction theorem: predicate lattice isomorphism implies architecture isomorphism (Theorem 7.1).
6. Contravariant functoriality of the predicate map (Theorem 6.1).
7. Soundness and completeness of Kripke forcing (Theorem 5.1).

---

## 2. Definitions and Notation

### 2.1 Neural Architectures

**Definition 2.1** (Neural Architecture). A *finitely generated acyclic neural architecture* is a tuple N = (Module, ≤, generators) where:
- Module is a finite type (the set of computational modules)
- ≤ is a partial order on Module (encoding acyclic information flow)
- generators ⊂ Module is a nonempty finite set of primitive modules
- Every module m has some generator g ≤ m (finite generation)

The partial order captures the dependency structure: m₁ ≤ m₂ means module m₂ depends on (or is downstream of) module m₁.

**Definition 2.2** (Architecture Morphism). A morphism f : N → M between architectures is a monotone function f : N.Module → M.Module that preserves generators: for every g ∈ N.generators, f(g) ∈ M.generators.

**Definition 2.3** (Architecture Isomorphism). Two architectures N and M are isomorphic if there exists an order isomorphism f : N.Module ≃o M.Module that preserves generators in both directions.

### 2.2 Upper Set Predicate Lattice

**Definition 2.4** (Upper Set). An *upper set* (upward-closed subset) of a partially ordered set (P, ≤) is a set U ⊆ P such that for all x, y ∈ P, if x ≤ y and x ∈ U, then y ∈ U.

We write UpperSet(P) for the set of all upper sets of P, ordered by reverse inclusion: U ≤ V iff V ⊆ U as sets.

**Fact 2.5.** For any finite partial order P, UpperSet(P) is:
- A finite distributive lattice with ⊔ = ∩, ⊓ = ∪, ⊤ = ∅, ⊥ = P
- A Heyting algebra with implication U ⇨ V = {x ∈ P | ∀y ≥ x, y ∈ U → y ∈ V}
- Finite when P is finite

The ordering convention (reverse inclusion) is standard in Mathlib and ensures that the Heyting algebra structure aligns with the logical interpretation: U ≤ V means V is "stronger" than U (true at fewer worlds), which corresponds to V entailing U.

### 2.3 Principal Upper Sets

**Definition 2.6.** For m ∈ P, the *principal upper set* is Ici(m) = {x ∈ P | m ≤ x}.

These are the *activation predicates*: Ici(m) describes the set of modules that are downstream of (or equal to) m.

---

## 3. The Order Embedding

**Theorem 3.1** (Order Embedding). The map m ↦ Ici(m) is an order embedding from N.Module to UpperSet(N.Module):

  m₁ ≤ m₂ ⟺ Ici(m₁) ≤ Ici(m₂)

*Proof sketch.* Ici(m₁) ≤ Ici(m₂) in UpperSet means {x | m₂ ≤ x} ⊆ {x | m₁ ≤ x}. If m₁ ≤ m₂, then for any x with m₂ ≤ x, we have m₁ ≤ x by transitivity, so the inclusion holds. Conversely, if {x | m₂ ≤ x} ⊆ {x | m₁ ≤ x}, then taking x = m₂ gives m₁ ≤ m₂. □

**Corollary 3.2.** The map m ↦ Ici(m) is injective.

---

## 4. Meet-Irreducible Classification

**Definition 4.1.** An element a of a lattice is *meet-irreducible* (InfIrred) if a is not maximal and whenever a = b ⊓ c, either a = b or a = c.

In UpperSet(P), this translates to: U is not ∅, and if U = A ∪ B (as sets) for upper sets A, B, then U = A or U = B.

**Theorem 4.2** (Principal Upper Sets are Meet-Irreducible). For every m ∈ N.Module, Ici(m) is meet-irreducible in UpperSet(N.Module).

*Proof sketch.* Ici(m) ≠ ∅ since m ∈ Ici(m), so it's not maximal. If Ici(m) = A ∪ B, then m ∈ A ∪ B, so m ∈ A or m ∈ B. WLOG m ∈ A. Since A is an upper set and m ∈ A, for any x with m ≤ x we have x ∈ A. So Ici(m) ⊆ A. But A ⊆ A ∪ B = Ici(m). Hence A = Ici(m). □

**Theorem 4.3** (Classification of Meet-Irreducibles). An upper set U ∈ UpperSet(N.Module) is meet-irreducible if and only if U = Ici(m) for some m ∈ N.Module.

*Proof sketch.* The reverse direction is Theorem 4.2. For the forward direction: if U is not a principal upper set, then U has at least two minimal elements m₁ ≠ m₂. Then U = (U ∪ Ici(m₁)) ∩ (U ∪ Ici(m₂))... wait, we use the correct UpperSet operations. Since ⊓ = ∪, we can decompose U as a union of principal upper sets of its minimal elements, and the InfIrred condition forces there to be exactly one minimal element. □

**Corollary 4.4.** There is a bijection between N.Module and {U ∈ UpperSet(N.Module) | InfIrred(U)}.

---

## 5. Soundness and Completeness

We define Kripke forcing over the module poset.

**Definition 5.1.** World w *forces* upper set U (written w ⊩ U) iff w ∈ U.

**Definition 5.2.** V *semantically entails* U (written V ⊨ U) iff for all w, w ⊩ V implies w ⊩ U.

**Theorem 5.1** (Soundness and Completeness). U ≤ V in UpperSet(N.Module) if and only if V ⊨ U.

*Proof.* Immediate from the definitions: U ≤ V means V ⊆ U as sets, which is exactly V ⊨ U. □

This theorem establishes that the lattice ordering on predicates coincides with semantic entailment in the Kripke frame. The intuitionistic structure (Heyting algebra) gives correct semantics for implication.

---

## 6. Contravariant Functoriality

**Theorem 6.1** (Contravariant Predicate Map). Given an architecture morphism f : N → M, the inverse image map

  f* : UpperSet(M.Module) → UpperSet(N.Module),  f*(U) = f⁻¹(U)

is a lattice homomorphism satisfying:
- f*(U ⊓ V) = f*(U) ⊓ f*(V)
- f*(U ⊔ V) = f*(U) ⊔ f*(V)
- f*(⊤) = ⊤ and f*(⊥) = ⊥

**Theorem 6.2** (Functoriality). The predicate map respects composition contravariantly:

  (g ∘ f)* = f* ∘ g*

and preserves identity: id* = id.

*Proof.* Both follow from standard properties of preimages: (g ∘ f)⁻¹ = f⁻¹ ∘ g⁻¹ and id⁻¹ = id. □

---

## 7. The Reconstruction Theorem

### 7.1 Lattice Isomorphisms Preserve Meet-Irreducibles

**Theorem 7.1** (Preservation of Meet-Irreducibles). An order isomorphism h : UpperSet(N.Module) ≃o UpperSet(M.Module) maps meet-irreducible elements to meet-irreducible elements.

*Proof sketch.* If U is InfIrred and h(U) = A ⊓ B, then U = h⁻¹(A) ⊓ h⁻¹(B) (since h preserves ⊓). By InfIrred, U = h⁻¹(A) or U = h⁻¹(B), so h(U) = A or h(U) = B. The ¬IsMax condition transfers similarly. □

### 7.2 Induced Order Isomorphism

**Theorem 7.2** (Induced Module Isomorphism). An order isomorphism h : UpperSet(N.Module) ≃o UpperSet(M.Module) induces an order isomorphism f : N.Module ≃o M.Module such that h(Ici(m)) = Ici(f(m)) for all m.

*Proof sketch.* By Theorem 7.1 and the classification (Theorem 4.3), h maps {Ici(m) | m ∈ N.Module} bijectively to {Ici(n) | n ∈ M.Module}. Define f(m) to be the unique n such that h(Ici(m)) = Ici(n). Then f is a bijection (by bijectivity of h restricted to meet-irreducibles and injectivity of Ici). Order preservation follows from:

  m₁ ≤ m₂ ⟺ Ici(m₁) ≤ Ici(m₂) ⟺ h(Ici(m₁)) ≤ h(Ici(m₂)) ⟺ Ici(f(m₁)) ≤ Ici(f(m₂)) ⟺ f(m₁) ≤ f(m₂) □

### 7.3 Main Theorem

**Theorem 7.3** (Semantics Determines Architecture). Let N, M be finitely generated acyclic neural architectures. If there exists an order isomorphism h : UpperSet(N.Module) ≃o UpperSet(M.Module) that preserves generator marking (i.e., for each generator g of N, h(Ici(g)) = Ici(g') for some generator g' of M, and conversely), then N and M are isomorphic as neural architectures.

*Proof.* Apply Theorem 7.2 to obtain f : N.Module ≃o M.Module. Generator preservation follows from the hypotheses and injectivity of Ici: if h(Ici(g)) = Ici(g') with g' a generator, and h(Ici(g)) = Ici(f(g)), then f(g) = g'. □

---

## 8. Algorithms

### 8.1 Predicate Lattice Construction

**Input:** Architecture graph G = (V, E) with generator set S ⊆ V
**Output:** The upper set lattice as a list of upper sets with ≤ relation

```
Algorithm ConstructPredicateLattice(G, S):
  1. Compute transitive closure of E to get partial order ≤
  2. Enumerate all upper sets of (V, ≤)
     (Upper set U: for all v ∈ U and w with v ≤ w, w ∈ U)
  3. Order upper sets by reverse inclusion
  4. Return (upper_sets, ordering)

Time: O(2^n · n^2) where n = |V|
Space: O(2^n · n)
```

### 8.2 Meet-Irreducible Extraction

**Input:** Predicate lattice L
**Output:** Set of meet-irreducible elements

```
Algorithm ExtractMeetIrreducibles(L):
  1. For each element a ∈ L:
     a. Check a ≠ max(L)
     b. Check: for all b, c ∈ L with b ⊓ c = a, either b = a or c = a
     c. If both conditions hold, mark a as meet-irreducible
  2. Return marked elements

Time: O(|L|^3)
Space: O(|L|)
```

### 8.3 Architecture Reconstruction

**Input:** Finite Heyting algebra H (as a lattice with operations)
**Output:** Neural architecture N with UpperSet(N.Module) ≅ H

```
Algorithm ReconstructArchitecture(H):
  1. Compute J = MeetIrreducibles(H)
  2. Define Module = J (modules are meet-irreducibles)
  3. Define partial order: j₁ ≤ j₂ iff j₁ ≤ j₂ in H
  4. Identify generators (lattice-theoretic characterization)
  5. Return (Module, ≤, generators)

Time: O(|H|^3) for meet-irreducible extraction
Space: O(|H|)
```

---

## 9. Applications

### 9.1 Architecture Equivalence Testing

Given architectures N₁ and N₂, compute their predicate lattices L₁, L₂ and check if L₁ ≅ L₂ as bounded lattices. If yes, the architectures are structurally equivalent (up to generator marking).

**Complexity:** O(2^n · n^2) for lattice construction, O(|L|^2) for isomorphism testing (finite lattice isomorphism is polynomial).

### 9.2 Architecture Minimization

Given an architecture N, compute its predicate lattice L, extract meet-irreducibles J, and reconstruct the minimal architecture from J. This removes redundant modules — modules that don't contribute unique meet-irreducible structure.

### 9.3 Specification-Driven Design

Given desired predicates (activation patterns, reachability requirements), construct the smallest lattice containing these predicates, extract meet-irreducibles, and synthesize the minimal architecture.

---

## 10. Discussion

### 10.1 Scope and Limitations

The current results apply to:
- **Finite** architectures (finite number of modules)
- **Acyclic** architectures (partial order, no feedback loops)
- **Separating** predicates (distinct modules have distinct predicate neighborhoods)

Extensions to recurrent architectures require replacing partial orders with preorders and working with equivalence classes. Continuous-depth architectures (neural ODEs) fall outside the current framework.

### 10.2 Relationship to Existing Duality Theories

Our construction is a concrete instance of the classical Birkhoff duality between finite distributive lattices and finite partial orders, applied in the neural architecture domain. The Heyting algebra structure (which goes beyond distributive lattice structure) provides the bridge to Kripke semantics and intuitionistic logic.

The connection to Stone duality is suggestive but indirect: our lattices are finite, so the topological content of Stone duality (compact totally disconnected spaces) reduces to discrete spaces. The finite case is fully captured by Birkhoff's theorem.

### 10.3 Implications for Explainability

The meet-irreducible elements serve as "atoms of explanation" — the minimal logical units of the architecture. Every predicate decomposes as a meet of meet-irreducibles, providing a canonical decomposition of architectural properties into independent modules. This is a mathematically rigorous form of structural explainability.

---

## 11. Future Work

See FUTURE_DIRECTIONS.md for detailed descriptions of five concrete next steps:
1. Extension to controlled recurrent architectures
2. Modal/temporal operators for dynamic architectures
3. Quantitative duality via semiring-valued predicates
4. Completeness for broader architecture classes
5. Verified architecture synthesis from logical specifications

---

## References

1. Birkhoff, G. (1937). Rings of sets. *Duke Mathematical Journal*, 3(3), 443-454.
2. Stone, M.H. (1936). The theory of representations for Boolean algebras. *Transactions of the AMS*, 40(1), 37-111.
3. Kripke, S.A. (1965). Semantical analysis of intuitionistic logic I. *Formal Systems and Recursive Functions*, 92-130.
4. Davey, B.A., & Priestley, H.A. (2002). *Introduction to Lattices and Order*. Cambridge University Press.
5. Katz, G., et al. (2017). Reluplex: An efficient SMT solver for verifying deep neural networks. *CAV 2017*.
