# Matroid Minors and the Robertson-Seymour Conjecture: A Formalized Framework

## Abstract

We develop a formal framework for matroid minor theory in the Lean 4 proof assistant, building on Mathlib's matroid library. Our formalization introduces novel mathematical structures—minor ideals, excluded minor systems, dual-closed classes, and well-quasi-ordered matroid classes—and proves key theorems connecting matroid duality with the minor relation. The central results are: (1) duality preserves the minor relation (N ≤m M ↔ N✶ ≤m M✶), (2) forbidden minors of the dual property equal the duals of the original forbidden minors, (3) the Robertson-Seymour property implies finite forbidden minor characterizations, and (4) a complete forbidden minor characterization theorem under well-foundedness. These results formalize the theoretical foundation needed for the Geelen-Gerards-Whittle conjecture that F_q-representable matroids are well-quasi-ordered by minors for every finite field F_q.

**Keywords**: matroid theory, Robertson-Seymour theorem, well-quasi-ordering, forbidden minors, matroid duality, formal verification

---

## 1. Introduction

The Robertson-Seymour theorem [RS04] states that finite graphs are well-quasi-ordered by the minor relation: any infinite sequence of graphs contains a pair where one is a minor of the other. This theorem, whose proof spans over 500 pages across 23 papers, is one of the deepest results in combinatorics and has profound algorithmic consequences.

A natural generalization asks whether the Robertson-Seymour theorem extends to matroids, which abstract the combinatorial structure shared by graphs and matrices. While the theorem fails for general matroids (infinite antichains exist among non-representable matroids), the **Geelen-Gerards-Whittle conjecture** [GGW06] asserts that for any finite field F_q, the class of F_q-representable matroids is well-quasi-ordered by the matroid minor relation.

In this paper, we develop a formal framework for studying this conjecture. Our contributions are:

1. **Novel definitions**: We introduce `MinorIdeal`, `ExcludedMinorSystem`, `DualClosedClass`, and `MatroidWQO` as structured abstractions for matroid minor theory.

2. **Duality-minor interaction**: We prove that duality preserves the minor relation and derive consequences for forbidden minor characterizations.

3. **Structural theorems**: We formalize the forbidden minor characterization theorem, the antichain property of forbidden minors, and the finiteness consequence of well-quasi-ordering.

4. **Falsifiable conjecture**: We state the RS conjecture for F_q-representable matroids and derive formal consequences.

All results are machine-verified in Lean 4 using Mathlib's matroid library.

---

## 2. Preliminaries

### 2.1 Matroids

A **matroid** M = (E, I) consists of a ground set E and a collection I of "independent" subsets satisfying:
- ∅ ∈ I
- If I ∈ I and J ⊆ I, then J ∈ I (hereditary property)
- If I, J ∈ I with |I| < |J|, then ∃ e ∈ J \ I with I ∪ {e} ∈ I (augmentation)
- A maximal chain condition ensuring well-definedness

### 2.2 Minor Operations

Given a matroid M = (E, I) and an element e ∈ E:
- **Deletion** M \ e: Remove e from E and from all independent sets.
- **Contraction** M / e: If e is not a loop, the independent sets become {I ⊆ E \ {e} : I ∪ {e} ∈ I}. If e is a loop, M / e = M \ e.

A matroid N is a **minor** of M (written N ≤m M) if N = (M / C) \ D for some disjoint C, D ⊆ E. In Mathlib, this is generalized to arbitrary (possibly non-disjoint) C, D.

### 2.3 Duality

The **dual** M✶ of a matroid M has the same ground set, and its bases are the complements of the bases of M. Key identities:
- (M \ X)✶ = M✶ / X (dual of deletion = contraction of dual)
- (M / X)✶ = M✶ \ X (dual of contraction = deletion of dual)
- M✶✶ = M (involution)

### 2.4 Representability

A matroid M is **F-representable** (for a field F) if there exists a matrix A over F whose column matroid is isomorphic to M. The class of F-representable matroids is denoted Rep(F).

---

## 3. Novel Definitions

### 3.1 Minor Ideals

**Definition (Minor Ideal).** A *minor ideal* is a pair (S, ↓) where S ⊆ {matroids} is downward-closed under the minor relation:
```
structure MinorIdeal (α : Type*) where
  carrier : Set (Matroid α)
  downward_closed : ∀ M N, M ∈ carrier → N.IsMinor M → N ∈ carrier
```

Every minor-closed property defines a minor ideal. The **boundary** of a minor ideal I consists of matroids not in I whose proper minors are all in I—these are precisely the forbidden minors.

### 3.2 Excluded Minor Systems

**Definition (Excluded Minor System).** An *excluded minor system* bundles a minor-closed property with its excluded minors and the proof of their equivalence:
```
structure ExcludedMinorSystem (α : Type*) where
  property : Matroid α → Prop
  is_minor_closed : IsMinorClosed property
  excluded : Set (Matroid α)
  excluded_eq : excluded = ForbiddenMinors property
```

### 3.3 Dual-Closed Classes and MatroidWQO

**Definition (Dual-Closed Class).** A class of matroids closed under duality:
```
structure DualClosedClass (α : Type*) where
  carrier : Set (Matroid α)
  dual_closed : ∀ M, M ∈ carrier → M✶ ∈ carrier
```

**Definition (MatroidWQO).** A well-quasi-ordered matroid class:
```
structure MatroidWQO (α : Type*) extends DualClosedClass α where
  rs_property : HasRSProperty carrier
  minor_closed : ∀ M N, M ∈ carrier → N.IsMinor M → N ∈ carrier
```

This structure captures the hypothesized properties of Rep(F_q) under the Geelen-Gerards-Whittle conjecture.

---

## 4. Main Results

### 4.1 Duality Preserves Minors

**Theorem 1 (dual_minor_of_minor).** *If N ≤m M, then N✶ ≤m M✶.*

*Proof sketch.* Write N = (M / C) \ D. Then:
N✶ = ((M / C) \ D)✶ = ((M / C)✶) / D = (M✶ \ C) / D

The last expression is a minor of M✶ (obtained by deleting C then contracting D). □

**Theorem 2 (minor_iff_dual_minor).** *N ≤m M if and only if N✶ ≤m M✶.*

*Proof.* Forward: Theorem 1. Backward: Apply Theorem 1 to N✶ ≤m M✶ to get N✶✶ ≤m M✶✶, then use M✶✶ = M. □

### 4.2 Forbidden Minors Form an Antichain

**Theorem 3 (forbiddenMinors_antichain).** *For any minor-closed property P, the set of forbidden minors of P is an antichain in the minor order.*

*Proof.* Suppose M, N are forbidden minors with M ≤m N and M ≠ N. Since N is a forbidden minor, all proper minors of N satisfy P. Since M is a proper minor of N, P(M) holds. But M is a forbidden minor, so ¬P(M)—contradiction. □

### 4.3 RS Implies No Infinite Antichains

**Theorem 4 (rs_implies_no_infinite_antichain).** *If a class C has the Robertson-Seymour property, then C contains no infinite antichain.*

*Proof.* Given an infinite injective sequence f : ℕ → C forming an antichain (f(i) ≤m f(j) ⟹ i = j), the RS property yields i < j with f(i) ≤m f(j), so i = j, contradicting i < j. □

### 4.4 RS + Minor-Closed ⟹ Finite Obstructions

**Theorem 5 (rs_forbiddenMinors_no_infinite_seq).** *If C has the RS property and P is minor-closed, then there is no infinite injective sequence of elements of C that are all forbidden minors of P.*

*Proof.* Combines Theorems 3 and 4: forbidden minors form an antichain, and RS forbids infinite antichains. □

### 4.5 Forbidden Minor Characterization

**Theorem 6 (forbidden_minor_characterization_wf).** *Assuming well-foundedness of the proper minor relation: P(M) ↔ (∀ N ∈ FM(P), ¬(N ≤m M)).*

*Proof.* Forward: If P(M) and N is a forbidden minor with N ≤m M, then P(N) by minor-closure, contradicting N being a forbidden minor. Backward: By contrapositive. If ¬P(M), use well-founded induction to find a minimal ¬P element below M; this element is a forbidden minor of P that is a minor of M. □

### 4.6 Duality of Forbidden Minors

**Theorem 7 (forbiddenMinors_dual_eq).** *FM(P ∘ dual) = dual(FM(P)), i.e., the forbidden minors of the dual property are exactly the duals of the forbidden minors of P.*

*Proof.* Uses Theorem 2 (minor_iff_dual_minor) and the involution M✶✶ = M to establish a bijection between the two sets. □

### 4.7 MatroidWQO Properties

**Theorem 8 (matroidWQO_finite_boundary).** *In a MatroidWQO, every minor ideal has no infinite sequence of boundary elements in the ambient class.*

This formalizes the consequence that well-quasi-ordering implies finite forbidden minor characterizations for all minor-closed subproperties.

---

## 5. The Robertson-Seymour Conjecture for Matroids

### 5.1 Statement

**Conjecture (Geelen-Gerards-Whittle).** For any finite field F_q, the class Rep(F_q) of F_q-representable matroids is well-quasi-ordered by the minor relation.

Formally:
```
def RSConjectureForField (F : Type*) [Field F] [Fintype F] : Prop :=
  HasRSProperty (RepresentableOver F)
```

### 5.2 Known Results

| Field | Status | Reference |
|-------|--------|-----------|
| GF(2) | Proved | Robertson-Seymour (graphs ≈ binary matroids) |
| GF(3) | Open | Geelen-Gerards-Whittle program |
| GF(4) | Open | Partial results by Geelen-Gerards-Whittle |
| GF(q), q > 4 | Open | Expected to follow from structural theory |

### 5.3 Consequences

Our Theorem 5 shows that the conjecture implies: for any minor-closed property P of F_q-representable matroids, the set of excluded minors is finite (in the sense of having no infinite injective antichain in Rep(F_q)).

### 5.4 Testable Prediction

**Conjecture (Ternary Excluded Minors).** The set of excluded minors for GF(3)-representability among all matroids includes exactly four matroids: U(2,5), U(3,5), the Fano plane F₇, and the dual Fano plane F₇*.

**Test:** Enumerate all matroids on ground sets of size ≤ 9 and verify that the excluded minors for GF(3)-representability are contained in the known list.

---

## 6. Discussion

### 6.1 The Role of Duality

Our results reveal that duality plays a central organizational role in matroid minor theory. The bijection FM(P✶) = (FM(P))✶ (Theorem 7) shows that the forbidden minor theory is perfectly symmetric under duality. This suggests that any proof of the Geelen-Gerards-Whittle conjecture must fundamentally engage with duality—a structural constraint on possible proof strategies.

### 6.2 Minor Ideals as a Unifying Framework

The `MinorIdeal` and `ExcludedMinorSystem` structures provide a clean algebraic framework for studying forbidden minor characterizations. The fact that minor ideals are closed under intersection (and form a lattice) suggests connections to order theory and domain theory that deserve further exploration.

### 6.3 Relationship to the Catalog

Our formalized results build on and extend the matroid minor results in `Catalog/Algebra/MatroidMinors/Theorems.lean`, adding the duality theory and the novel structural definitions. The `MatroidWQO` structure provides a natural framework for stating and studying the Geelen-Gerards-Whittle conjecture.

---

## 7. References

- [GGW06] J. Geelen, B. Gerards, G. Whittle. "Towards a matroid-minor structure theory." *Combinatorics, Complexity, and Chance*, Oxford University Press, 2007.
- [Oxl11] J. Oxley. *Matroid Theory*, 2nd edition. Oxford University Press, 2011.
- [RS04] N. Robertson, P.D. Seymour. "Graph Minors. XX. Wagner's conjecture." *Journal of Combinatorial Theory, Series B*, 92(2):325–357, 2004.
- [Whi35] H. Whitney. "On the abstract properties of linear dependence." *American Journal of Mathematics*, 57(3):509–533, 1935.
