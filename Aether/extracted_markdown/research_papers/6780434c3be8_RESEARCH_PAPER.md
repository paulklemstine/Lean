# Formal Foundations of the Forbidden Minor Framework for Matroid Theory

## Abstract

We present a formal development of the forbidden minor framework connecting well-quasi-ordering (WQO) to finite excluded minor characterizations in matroid theory. Building on Mathlib's matroid library, we prove that matroid duality is an order isomorphism on the minor partial order, that forbidden minor sets are antichains, and that WQO implies finiteness of excluded minors. The central result — the **Forbidden Minor Characterization Theorem** — states that under well-foundedness, membership in a hereditary (minor-closed) class is equivalent to avoiding all forbidden minors. We also establish that duality preserves hereditary classes and maps forbidden minor sets to forbidden minor sets. All results are formalized in Lean 4 and verified against Mathlib v4.28.0.

**Keywords**: matroid theory, forbidden minors, well-quasi-ordering, Robertson-Seymour theorem, formal verification, order theory

---

## 1. Introduction

The Robertson-Seymour Graph Minor Theorem [RS04] is one of the deepest results in combinatorics: it states that finite graphs are well-quasi-ordered under the minor relation. An immediate corollary is that every minor-closed graph property is characterized by finitely many forbidden minors.

The mathematical architecture of this result separates into two layers:

1. **The abstract layer**: WQO → finite antichains → finite forbidden minor characterizations. This is pure order theory.
2. **The concrete layer**: Proving that graphs (or specific matroid classes) satisfy WQO. This requires deep structural analysis.

This paper formalizes the abstract layer completely, and establishes the matroid-specific infrastructure (duality, hereditary classes, forbidden minor sets) needed to instantiate it. The key insight is that the abstract argument is entirely self-contained: once WQO is known for any class, the finiteness result follows automatically.

### 1.1 Contributions

- **Novel definitions**: `IsHereditaryMatroidClass`, `ForbiddenMinorSet`, `AvoidsAll` — new Lean structures for matroid minor theory not present in Mathlib.
- **Duality order isomorphism**: Formal proof that matroid duality preserves the minor order (`dual_isMinor_dual`, `dual_le_dual_iff`).
- **Antichain theorem**: Forbidden minor sets form antichains (`forbiddenMinorSet_isAntichain`).
- **Characterization theorem**: Membership in hereditary classes ↔ avoidance of forbidden minors (`forbidden_minor_characterization`).
- **Finiteness theorem**: WQO implies finite forbidden minors (`wqo_forbidden_minor_finite`).
- **Duality transfer**: Hereditary classes and their forbidden minors are preserved under duality (`hereditary_dual_image`, `forbiddenMinorSet_dual_image`).
- **Abstract core**: Pure order-theoretic excluded-element theorem (`wqo_finite_minimal_excluded`).

### 1.2 Related Work

Mathlib provides extensive matroid infrastructure including the matroid type, independence axioms, deletion and contraction, the minor partial order, and matroid duality. Our work builds on this by adding the forbidden minor framework — the connection between order-theoretic properties and structural characterization.

The Robertson-Seymour theorem itself has not been formalized in any proof assistant. Our work formalizes the *consequence* of WQO, reducing the formalization challenge to establishing WQO for specific classes.

---

## 2. Preliminaries

### 2.1 Matroids

A **matroid** M on a ground set E is a structure satisfying the independence axioms: the empty set is independent, subsets of independent sets are independent, and the augmentation property holds. Mathlib's `Matroid α` encodes this for any type α.

### 2.2 Minor Operations

For a matroid M on ground set E:
- **Deletion** M \ X: Remove elements X from E and restrict independence.
- **Contraction** M / X: Contract elements X, reducing rank.
- **Minor**: N is a minor of M (N ≤ₘ M) if N = M / C \ D for some C, D ⊆ E.

Mathlib establishes that the minor relation is a partial order on `Matroid α`.

### 2.3 Duality

The **dual** M✶ of M has the same ground set but swaps independence and co-independence. Key identities:
- (M / X)✶ = M✶ \ X (dual of contraction is deletion)
- (M \ X)✶ = M✶ / X (dual of deletion is contraction)
- (M / C \ D)✶ = M✶ \ C / D (combined)
- M✶✶ = M (involution)

### 2.4 Well-Quasi-Ordering

A relation r on α is **well-quasi-ordered** (WQO) if every infinite sequence has an increasing pair: for any f : ℕ → α, there exist i < j with r (f i) (f j). Equivalently, every antichain is finite and there are no infinite strictly decreasing sequences.

---

## 3. Duality as an Order Isomorphism

**Theorem 3.1** (dual_isMinor_dual). *If N ≤ M in the minor order, then N✶ ≤ M✶.*

*Proof.* Since N ≤ M, there exist C, D with N = M / C \ D. Then N✶ = (M / C \ D)✶ = M✶ \ C / D by the duality identity. Now M✶ \ C / D is a minor of M✶ \ C (by contracting D), and M✶ \ C is a minor of M✶ (by deleting C). By transitivity, N✶ ≤ M✶. □

**Theorem 3.2** (dual_le_dual_iff). *N✶ ≤ M✶ if and only if N ≤ M.*

*Proof.* Forward: Theorem 3.1. Backward: Apply Theorem 3.1 to N✶ ≤ M✶ to get N✶✶ ≤ M✶✶, then use M✶✶ = M. □

**Corollary 3.3.** *Matroid duality is an order isomorphism (Matroid α, ≤) → (Matroid α, ≤).*

---

## 4. Hereditary Classes and Forbidden Minors

### 4.1 Definitions

**Definition 4.1.** A set C of matroids is **hereditary** (or minor-closed) if M ∈ C and N ≤ M implies N ∈ C.

**Definition 4.2.** The **forbidden minor set** of C is:
$$\mathcal{F}(C) = \{ M \mid M \notin C \text{ and } \forall N < M,\, N \in C \}$$

**Definition 4.3.** A matroid M **avoids** a set F if no element of F is a minor of M.

### 4.2 The Antichain Property

**Theorem 4.4** (forbiddenMinorSet_isAntichain). *For any hereditary class C, the set 𝓕(C) is an antichain in the minor order.*

*Proof.* Suppose F₁, F₂ ∈ 𝓕(C) with F₁ ≠ F₂ and F₁ ≤ F₂. Since F₁ ≠ F₂ and F₁ ≤ F₂, we have F₁ < F₂. Since F₂ ∈ 𝓕(C), every strict minor of F₂ is in C, so F₁ ∈ C. But F₁ ∈ 𝓕(C) requires F₁ ∉ C. Contradiction. □

### 4.3 The Characterization Theorem

**Theorem 4.5** (forbidden_minor_characterization). *Assume the strict minor order is well-founded. Then for any hereditary class C and any matroid M:*
$$M \in C \iff M \text{ avoids } \mathcal{F}(C)$$

*Proof.* (⇒) If M ∈ C and some F ∈ 𝓕(C) satisfies F ≤ M, then F ∈ C by hereditariness, contradicting F ∉ C.

(⇐) By well-founded induction. Suppose M ∉ C. Either every strict minor of M is in C (making M ∈ 𝓕(C), contradicting avoidance since M ≤ M), or some N < M has N ∉ C. By induction, N doesn't avoid 𝓕(C), giving F ∈ 𝓕(C) with F ≤ N ≤ M, contradicting avoidance. □

---

## 5. WQO Implies Finiteness

**Theorem 5.1** (wqo_forbidden_minor_finite). *If the minor order on matroids is WQO, then 𝓕(C) is finite for every hereditary class C.*

*Proof.* By Theorem 4.4, 𝓕(C) is an antichain. By the WQO property, every antichain is finite (this is a standard result, `IsAntichain.finite_of_wellQuasiOrdered` in Mathlib). □

**Theorem 5.2** (wqo_finite_minimal_excluded). *In any partial order with WQO, for any lower set S, the set of minimal elements of Sᶜ is finite.*

This is the abstract order-theoretic core, independent of matroid theory.

---

## 6. Duality of Hereditary Classes

**Theorem 6.1** (hereditary_dual_image). *If C is hereditary, then C✶ = {M✶ | M ∈ C} is hereditary.*

*Proof.* Suppose M✶ ∈ C✶ and N ≤ M✶. Then N✶ ≤ M by the order isomorphism (Theorem 3.2). Since C is hereditary, N✶ ∈ C. Hence N = (N✶)✶ ∈ C✶. □

**Theorem 6.2** (forbiddenMinorSet_dual_image). *𝓕(C✶) = {F✶ | F ∈ 𝓕(C)}.*

*Proof.* (⊆) If M ∈ 𝓕(C✶), set P = M✶. Then P ∉ C (else M = P✶ ∈ C✶). For Q < P, we have Q✶ < M, so Q✶ ∈ C✶, giving Q ∈ C. Thus P ∈ 𝓕(C) and M = P✶.

(⊇) If P ∈ 𝓕(C), set M = P✶. Then M ∉ C✶ (else P ∈ C). For N < M = P✶, we have N✶ < P, so N✶ ∈ C, giving N = (N✶)✶ ∈ C✶. Thus M ∈ 𝓕(C✶). □

---

## 7. Algorithms

### 7.1 Forbidden Minor Recognition

Given a finite forbidden minor set 𝓕 = {F₁, ..., Fₖ}, membership in the corresponding hereditary class can be tested by checking, for each Fᵢ, whether Fᵢ is a minor of the input matroid M. For graphs, Robertson and Seymour showed this can be done in O(n³) time for each Fᵢ, giving an O(kn³) algorithm overall.

### 7.2 Forbidden Minor Enumeration

For a hereditary class C with an explicit membership test, the forbidden minors can be enumerated by:
1. Enumerate matroids by increasing ground set size.
2. For each matroid M ∉ C, check if all proper minors are in C.
3. If yes, M is a forbidden minor.

This terminates if the class is finitely characterized, but the termination is guaranteed only by the WQO assumption.

---

## 8. Discussion

### 8.1 The Architecture of Deep Theorems

Our formalization reveals that the Robertson-Seymour theorem has a clean two-layer architecture:
- **Layer 1** (abstract): WQO → finite antichains → finite forbidden characterizations. This is pure order theory, and we have formalized it completely.
- **Layer 2** (concrete): Graphs are WQO under the minor relation. This requires 500+ pages of deep structural analysis.

The entire mathematical content is in Layer 2. Layer 1 is a reusable framework that applies to any WQO structure.

### 8.2 The Conjecture

We state the conjecture that matroids on bounded ground sets are WQO under the minor relation. For finite ground sets Fin n, there are finitely many matroids, so the conjecture is trivially true in a set-theoretic sense (any finite partial order is WQO). The interest lies in understanding the structure of the minor order and extending to infinite families.

The deeper conjecture — that GF(q)-representable matroids are WQO — remains one of the central open problems in matroid theory, being actively pursued by Geelen, Gerards, and Whittle.

### 8.3 Computational Aspects

The finiteness theorems are inherently non-constructive: they guarantee that a finite forbidden minor set exists without providing it. Computing the actual forbidden minors requires explicit structural analysis for each hereditary class.

---

## 9. Future Work

1. **WQO for uniform matroids**: Prove that the class of uniform matroids U(k,n) is WQO under the minor relation.
2. **Constructive forbidden minors**: For specific hereditary classes (e.g., binary matroids, graphic matroids), compute the actual forbidden minor sets.
3. **Tropical matroid minors**: Extend the framework to tropical matroids and valuated matroids.
4. **Algorithmic content**: Formalize the O(n³) minor-testing algorithm for graphs.

---

## References

[RS04] N. Robertson and P. Seymour. Graph Minors. XX. Wagner's conjecture. *J. Combin. Theory Ser. B*, 92(2):325–357, 2004.

[Oxl11] J. Oxley. *Matroid Theory*. Oxford University Press, 2nd edition, 2011.

[Whi35] H. Whitney. On the abstract properties of linear dependence. *American Journal of Mathematics*, 57(3):509–533, 1935.

[GGW14] J. Geelen, B. Gerards, and G. Whittle. Solving Rota's conjecture. *Notices of the AMS*, 61(7):736–743, 2014.

[Hig52] G. Higman. Ordering by divisibility in abstract algebras. *Proc. London Math. Soc.*, 2(3):326–336, 1952.

[Kru60] J.B. Kruskal. Well-quasi-ordering, the tree theorem, and Vazsonyi's conjecture. *Trans. Amer. Math. Soc.*, 95(2):210–225, 1960.
