# Constructive Prime Witness Extraction for Non-Derivability in Finite Distributive Closure Systems

## Abstract

We establish a formally verified prime separation theorem for finite distributive closure systems: given a closed set K and an element a not in K, there exists a prime (meet-prime) closed set P extending K that avoids a. This result is the lattice-theoretic core of non-derivability certification in proof systems. We formalize the theorem in Lean 4, building on Mathlib's theory of inf-irreducible and inf-prime elements in finite distributive lattices. The proof reduces the closure-system result to an abstract lattice separation theorem, then lifts it back through the concrete theory of closed sets. We also prove the spectral reconstruction theorem: every closed set equals the intersection of all prime closed sets above it.

## 1. Introduction

A fundamental question in logic and algebra is: **when can non-derivability be witnessed?** Given a proof system (formalized as a closure operator) and a statement that cannot be derived from a set of assumptions, can we always find a "reason" — a structured semantic object — that explains the failure?

The classical answer, going back to Lindenbaum and Tarski, is yes: every consistent theory extends to a maximal consistent theory, which serves as a countermodel. But this classical argument uses Zorn's lemma and is inherently non-constructive.

In the **finite** setting, the situation is much better. When the universe of formulas is finite and the closure operator is computable, we can search exhaustively for prime theories that witness non-derivability. The key mathematical insight is that in a finite **distributive** lattice, every element is the infimum of the inf-prime elements above it — a fact equivalent to Birkhoff's representation theorem for finite distributive lattices.

This paper formalizes this insight in Lean 4, establishing:

1. **The abstract separation theorem** (Theorem 3.1): In any finite distributive lattice with top, if a ≰ b, there exists an inf-prime element p with b ≤ p and a ≰ p.

2. **The closure system instantiation** (Theorem 5.1): In a finite distributive closure system, for any closed set K and element a ∉ K, there exists a prime closed set P ⊇ K with a ∉ P.

3. **The spectral reconstruction theorem** (Theorem 5.2): Every closed set equals the intersection of all prime closed sets above it.

All results are formally verified with no axioms beyond the standard Lean 4 foundations (propext, Classical.choice, Quot.sound).

## 2. Mathematical Background

### 2.1 Closure Operators

A **closure operator** on a set X is a function cl: P(X) → P(X) satisfying:
- **Extensive**: S ⊆ cl(S)
- **Monotone**: S ⊆ T implies cl(S) ⊆ cl(T)
- **Idempotent**: cl(cl(S)) = cl(S)

A set S is **closed** if cl(S) = S. The collection of closed sets forms a complete lattice under inclusion, with meet given by intersection and join given by cl(A ∪ B).

### 2.2 Distributive Closure Systems

A closure system is **distributive** if its lattice of closed sets is distributive: A ∩ cl(B ∪ C) ⊆ cl((A ∩ B) ∪ (A ∩ C)) for every closed set A and arbitrary sets B, C. This condition is equivalent to the lattice of closed sets satisfying (K ⊔ L) ⊓ (K ⊔ M) = K ⊔ (L ⊓ M).

Distributivity is not automatic — the convex closure on a linearly ordered set provides a counterexample (its lattice of closed sets is the "fence" lattice, which is not distributive). However, many natural proof-theoretic closure operators are distributive, including those arising from propositional logic.

### 2.3 Inf-Prime and Inf-Irreducible Elements

An element p of a lattice is **inf-irreducible** if p = a ⊓ b implies p = a or p = b (and p ≠ ⊤). An element is **inf-prime** if a ⊓ b ≤ p implies a ≤ p or b ≤ p (and p ≠ ⊤).

In a distributive lattice, these notions coincide. This is a classical result that Mathlib formalizes as `infPrime_iff_infIrred`.

### 2.4 Birkhoff's Theorem (Finite Case)

In a finite lattice with top element and well-founded strict order (which is automatic for finite types), every element can be written as a finite infimum of inf-irreducible elements. Mathlib provides this as `exists_infIrred_decomposition`.

## 3. The Abstract Separation Theorem

**Theorem 3.1** (exists_infPrime_separation). *Let L be a finite distributive lattice with ⊤. If a ≰ b in L, then there exists an inf-prime element p ∈ L with b ≤ p and a ≰ p.*

*Proof.* By `exists_infIrred_decomposition`, write b = ⨅ s for some finite set s of inf-irreducible elements. Since a ≰ b = ⨅ s, there must exist some p ∈ s with a ≰ p (otherwise a ≤ ⨅ s = b, contradiction). Since the lattice is distributive, p is inf-prime by `infPrime_iff_infIrred`. Finally, b = ⨅ s ≤ p since p ∈ s. ∎

**Corollary 3.2** (le_iff_forall_infPrime). *a ≤ b if and only if every inf-prime p with b ≤ p also has a ≤ p.*

This corollary is the "spectral characterization of the order": the order relation is completely determined by the inf-prime elements.

## 4. Finite Closure Systems in Lean 4

### 4.1 The FiniteClosureSystem Structure

We define a bundled closure system:

```lean
structure FiniteClosureSystem (α : Type*) [Fintype α] [DecidableEq α] where
  cl : Set α → Set α
  mono_cl : Monotone cl
  extensive : ∀ s, s ⊆ cl s
  idempotent : ∀ s, cl (cl s) = cl s
```

### 4.2 Closed Sets Form a Lattice

Closed sets are bundled with their closedness proof:

```lean
structure ClosedSet (C : FiniteClosureSystem α) where
  carrier : Set α
  is_closed : C.IsClosed carrier
```

We prove that closed sets form a lattice with:
- **Meet**: intersection (proven closed via monotonicity)
- **Join**: closure of union
- **Top**: the universe Set.univ

### 4.3 Distributive Closure Systems

We extend `FiniteClosureSystem` with a distributivity axiom:

```lean
structure DistribClosureSystem (α : Type*) [Fintype α] [DecidableEq α]
    extends FiniteClosureSystem α where
  cl_distrib : ∀ (A B C : Set α),
    toFiniteClosureSystem.IsClosed A →
    A ∩ toFiniteClosureSystem.cl (B ∪ C) ⊆
      toFiniteClosureSystem.cl ((A ∩ B) ∪ (A ∩ C))
```

This axiom is sufficient to prove that the closed-set lattice is distributive (instance `DistribClosureSystem.instDistribLattice`).

## 5. Prime Separation for Closed Sets

### 5.1 From Lattice Elements to Set Elements

The key challenge is bridging between the lattice-theoretic separation (Theorem 3.1, about lattice elements) and the set-theoretic separation we want (about elements of the ground set α).

The bridge is the **singleton closure map**: for each element a ∈ α, define the closed set cl({a}). If a ∉ K (where K is a closed set), then cl({a}) ≰ K in the lattice of closed sets. By Theorem 3.1, there exists an inf-prime P with K ≤ P and cl({a}) ≰ P. Since P is closed and a ∈ cl({a}), we conclude a ∉ P (otherwise cl({a}) ⊆ P, contradicting cl({a}) ≰ P).

**Theorem 5.1** (exists_prime_closedSet_separation). *In a finite distributive closure system, for any closed set K and any element a ∉ K, there exists a prime closed set P ⊇ K with a ∉ P.*

**Theorem 5.2** (closedSet_eq_iInter_prime_extensions). *Every closed set K equals the intersection of all prime closed sets containing K:*

K = ⋂ {P : P is prime and K ⊆ P}

## 6. Algorithmic Witness Extraction

The separation theorem is constructive in the finite setting: the proof proceeds by enumerating inf-irreducible decompositions and selecting appropriate elements. We package this as a certificate:

```lean
structure PrimeWitnessCert (K : ClosedSet D.toFCS) (a : α) where
  P : ClosedSet D.toFCS
  isPrime : IsPrimeClosedSet D P
  extends_K : K ≤ P
  avoids_a : a ∉ P.carrier
```

The function `extractPrimeWitness` produces such a certificate given any pair (K, a) with a ∉ K.

## 7. Discussion: What This Means for Proof Theory

### For a General Audience

Imagine you're a detective trying to prove someone is innocent. You have a collection of evidence (your "theory" K), and you want to show that a particular conclusion (the element a) does NOT follow from this evidence. How can you be certain?

Our theorem says: in any finite logical system with a "distributive" structure, you can always find a **prime witness** — a maximally structured counterexample that explains exactly why the conclusion doesn't follow. This witness is not just any counterexample; it's "prime," meaning it's as logically tight as possible: it can't be decomposed into simpler witnesses.

Think of it like factoring a number into primes. Just as every integer has a unique prime factorization, every "theory gap" (a statement not derivable from assumptions) can be traced back to a prime gap — an irreducible reason for non-derivability.

The practical implication: in finite proof systems, **non-derivability is always certifiable**. You don't just know that something can't be proved; you have an explicit, verifiable certificate explaining why.

### Historical Context

This result sits at the intersection of several classical traditions:

1. **Lindenbaum's Lemma** (1930s): Every consistent theory extends to a maximal consistent theory. Our theorem is a finite, constructive analogue.

2. **Birkhoff's Representation Theorem** (1937): Finite distributive lattices are isomorphic to lattices of downsets of finite posets. Our spectral reconstruction theorem is a direct consequence.

3. **Stone Duality** (1936): Boolean algebras are dual to Stone spaces. Our prime spectrum is the finite version of Stone's construction.

4. **Hilbert's Nullstellensatz** (1893): A polynomial vanishes on all points of a variety iff it belongs to the corresponding ideal. Our theorem is an analogous "Nullstellensatz for proof systems": a statement is derivable iff it belongs to every prime theory extending the assumptions.

### Connections to Existing Work

The formalization builds on Mathlib's theory of:
- Inf-irreducible and inf-prime elements (`Mathlib.Order.Irreducible`)
- The decomposition theorem `exists_infIrred_decomposition`
- Distributive lattices and their properties

## 8. Applications

### 8.1 Automated Reasoning

In finite propositional systems, the prime witness extraction can be used as a **certified non-derivability checker**: given a sequent Γ ⊬ φ, extract a prime theory T ⊇ Γ with φ ∉ T. This T serves as a machine-checkable proof of non-derivability.

### 8.2 Database Query Optimization

Closure operators model functional dependencies in databases. Prime closed sets correspond to "maximally independent" attribute sets. The separation theorem guarantees that every non-implied dependency is witnessed by a prime attribute configuration.

### 8.3 Concept Analysis

In Formal Concept Analysis, closure operators generate concept lattices. When the lattice is distributive, prime concepts provide a complete set of "atomic explanations" for why an object does not have a given attribute.

## 9. Conclusion

We have formally verified, in Lean 4, the constructive prime separation theorem for finite distributive closure systems. The key insight is reducing the problem to Birkhoff's decomposition theorem for finite distributive lattices, which Mathlib already provides. The bridge between lattice elements and set elements is the singleton closure map.

The formalization comprises approximately 260 lines of Lean 4 code, with all proofs machine-checked and depending only on standard axioms. The code is organized into six parts: abstract lattice separation, closure system definitions, closed set lattice structure, distributivity, prime separation, and algorithmic witness extraction.

## References

1. Birkhoff, G. (1937). "Rings of sets." Duke Mathematical Journal, 3(3), 443–454.
2. Stone, M.H. (1936). "The theory of representations for Boolean algebras." Transactions of the AMS, 40(1), 37–111.
3. Davey, B.A. & Priestley, H.A. (2002). *Introduction to Lattices and Order.* Cambridge University Press.
4. The Mathlib Community. (2024). *Mathlib: The Lean mathematical library.* https://github.com/leanprover-community/mathlib4
