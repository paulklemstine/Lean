# Matroid Minors and Well-Quasi-Ordering: A Formal Framework for the Robertson-Seymour Paradigm

## Abstract

We develop a formal framework for studying matroid minor theory within the well-quasi-ordering (WQO) paradigm. Our main contributions are: (1) a complete formalization of abstract minor systems with size-graded partial orders; (2) a proof that excluded minors form antichains, leading to the fundamental theorem that WQO implies finitely many excluded minors for any minor-closed property; (3) a forbidden minor characterization theorem showing that every minor-closed property in a WQO class is determined by a finite forbidden set; (4) a novel "obstruction spectrum" invariant that fingerprints minor-closed properties by counting excluded minors at each size level; (5) a formal proof of Dickson's lemma (products of WQOs are WQOs); and (6) structural results including monotonicity of excluded minor counts under property inclusion. All results have been formalized and mechanically verified, with no unproven assumptions.

## 1. Introduction

The Robertson-Seymour theorem [RS04] states that finite graphs are well-quasi-ordered by the minor relation: any infinite sequence of graphs contains a pair where one is a minor of the other. This deep theorem, proved over two decades in a series of 23 papers, has profound consequences for structural graph theory and algorithm design.

The Geelen-Gerards-Whittle (GGW) conjecture extends this to matroid theory: for any finite field 𝔽_q, the class of 𝔽_q-representable matroids is well-quasi-ordered by the matroid minor relation. This conjecture would unify graph minor theory with matroid theory, since graphic matroids correspond to 𝔽₂-representable matroids.

In this paper, we develop an abstract framework that captures the essential structure underlying both the Robertson-Seymour theorem and the GGW conjecture. Our framework is based on "minor systems" — partial orders equipped with a size function satisfying the descending chain condition for the strict part of the ordering. Within this framework, we prove the key structural theorems that connect WQO to forbidden minor characterizations.

### 1.1 Main Results

**Theorem (Excluded Minors are Antichains).** In a minor system with antisymmetry, if m₁ and m₂ are both excluded minors for a minor-closed property P, and m₁ ≤ m₂, then m₁ = m₂.

**Theorem (WQO ⟹ Finite Excluded Minors).** If a class C is well-quasi-ordered by the minor relation, then every minor-closed property P has finitely many excluded minors within C.

**Theorem (Forbidden Minor Characterization).** If C is WQO and minor-closed, then every minor-closed property P is completely characterized by a finite set F of forbidden minors: an element m ∈ C fails P if and only if some element of F is a minor of m.

**Theorem (Dickson's Lemma for WQO).** The product of two well-quasi-orders is a well-quasi-order under componentwise ordering.

**Theorem (Obstruction Spectrum Finiteness).** The obstruction spectrum of a minor-closed property in a WQO class has finite support.

**Theorem (Excluded Minor Monotonicity).** If P ⊆ Q are minor-closed, then every excluded minor of Q contains an excluded minor of P.

## 2. Definitions

### 2.1 Finite Matroids

We define a finite matroid M on a ground set E via a rank function rk : 2^E → ℕ satisfying:
- (R1) rk(∅) = 0
- (R2) rk(A) ≤ |A| for all A ⊆ E
- (R3) A ⊆ B ⟹ rk(A) ≤ rk(B) (monotonicity)
- (R4) rk(A ∪ B) + rk(A ∩ B) ≤ rk(A) + rk(B) (submodularity)

From these axioms, we derive:
- **Unit increase**: rk(A ∪ {e}) ≤ rk(A) + 1
- **Monotonicity corollary**: rk(A) ≤ rk(A ∪ {e})
- **Loop property**: If e is a loop (rk({e}) = 0), then rk(A ∪ {e}) = rk(A)

### 2.2 Well-Quasi-Ordering

A **well-quasi-order** (WQO) on a set α is a pair (α, ≤) where ≤ is reflexive and transitive, and every infinite sequence f : ℕ → α contains a pair i < j with f(i) ≤ f(j).

Key property: **In a WQO, every antichain is finite.** An antichain is a set where no two distinct elements are comparable.

### 2.3 Minor Systems

A **minor system** is a tuple (M, ≤, size) where:
- (M, ≤) is a partial order (reflexive, transitive, antisymmetric)
- size : M → ℕ
- If a ≤ b and a ≠ b, then size(a) < size(b)

This captures the essential properties of the matroid minor relation: it is a partial order, and proper minors are strictly smaller.

### 2.4 Minor-Closed Properties

A property P : M → Prop is **minor-closed** if a ≤ b and P(b) implies P(a). The **excluded minors** for P are the elements m with ¬P(m) such that all proper minors of m satisfy P.

### 2.5 The Obstruction Spectrum (Novel)

For a minor system (M, ≤, size), class C ⊆ M, and minor-closed property P, the **obstruction spectrum** is:

σ(k) = |{m ∈ C ∩ Excl(P) : size(m) = k}|

This counts excluded minors at each size level. Under WQO, σ has finite support.

## 3. Main Theorems

### 3.1 Excluded Minors Form Antichains

**Theorem 3.1.** Let (M, ≤, size) be a minor system and P a minor-closed property. If m₁, m₂ ∈ Excl(P) and m₁ ≤ m₂, then m₁ = m₂.

*Proof sketch.* If m₁ ≠ m₂, then m₁ is a proper minor of m₂. Since m₂ ∈ Excl(P), all proper minors of m₂ satisfy P, so P(m₁). But m₁ ∈ Excl(P) means ¬P(m₁). Contradiction. □

### 3.2 WQO Implies Finite Excluded Minors

**Theorem 3.2.** If C is WQO, then {m ∈ C : m ∈ Excl(P)} is finite for any minor-closed P.

*Proof sketch.* By Theorem 3.1, the excluded minors in C form an antichain in the minor relation restricted to C. If this antichain were infinite, we could extract an injective sequence f : ℕ → C of excluded minors. By the WQO property, there exist i < j with f(i) ≤ f(j). By Theorem 3.1, f(i) = f(j), contradicting injectivity. □

### 3.3 Every Non-Member Contains an Excluded Minor

**Theorem 3.3.** For any minor-closed P and element m with ¬P(m), there exists n ∈ Excl(P) with n ≤ m.

*Proof sketch.* By strong induction on size(m). If all proper minors of m satisfy P, then m ∈ Excl(P) and we're done. Otherwise, there exists a proper minor a of m with ¬P(a). Since size(a) < size(m), by induction there exists n ∈ Excl(P) with n ≤ a ≤ m. □

### 3.4 Forbidden Minor Characterization

**Theorem 3.4.** If C is WQO and minor-closed, and P is minor-closed, then there exists a finite set F such that:
1. Every element of F is an excluded minor for P.
2. For all m ∈ C: ¬P(m) ↔ ∃ n ∈ F, n ≤ m.

*Proof sketch.* Let F = (Excl(P) ∩ C).toFinset, which is finite by Theorem 3.2. Part 1 is immediate. For part 2, the forward direction uses Theorem 3.3 plus the hypothesis that C is minor-closed (so the excluded minor stays in C). The backward direction uses minor-closedness of P: if n ≤ m and ¬P(n), then ¬P(m) (contrapositive of minor-closedness). □

### 3.5 Dickson's Lemma

**Theorem 3.5.** If (α, ≤_α) and (β, ≤_β) are WQOs, then (α × β, ≤) is a WQO under (a₁,b₁) ≤ (a₂,b₂) iff a₁ ≤_α a₂ and b₁ ≤_β b₂.

*Proof sketch.* Given f : ℕ → α × β, extract a subsequence where the first components are non-decreasing (using a Ramsey-type argument for WQOs), then apply the WQO property to the second components of this subsequence. □

### 3.6 Structural Theorems

**Theorem 3.6 (Closure properties).** Minor-closed classes are closed under finite union and intersection.

**Theorem 3.7 (Sandwich theorem).** If P ⊆ Q are both minor-closed and C is WQO, then {m ∈ C : m ∈ Excl(P) ∧ Q(m)} is finite.

**Theorem 3.8 (Excluded minor monotonicity).** If P ⊆ Q are minor-closed, then every excluded minor of Q contains an excluded minor of P.

**Theorem 3.9 (Obstruction spectrum finiteness).** Under WQO, the obstruction spectrum has finite support.

## 4. Applications

### 4.1 The Robertson-Seymour Theorem

The Robertson-Seymour theorem is the special case where M = {isomorphism classes of graphs}, ≤ = graph minor relation, size = |V(G)|, and C = M. Our Theorem 3.4 then gives: every minor-closed graph property is characterized by a finite forbidden minor set.

### 4.2 The GGW Conjecture

The GGW conjecture states that for any finite field 𝔽_q, the class of 𝔽_q-representable matroids is WQO. Our framework shows that if this conjecture is true, then:
- Every minor-closed property of 𝔽_q-representable matroids has finitely many excluded minors.
- The obstruction spectrum for each such property has finite support.
- The excluded minor monotonicity principle applies.

Known excluded minors for representability:
- 𝔽₂: U₂,₄ (1 excluded minor)
- 𝔽₃: U₂,₅, U₃,₅, F₇, F₇* (4 excluded minors)
- 𝔽₄: 7 excluded minors (Geelen-Gerards-Kapoor 2000)

### 4.3 Algorithmic Consequences

For any minor-closed property P in a WQO class with known excluded minors F₁, ..., Fk:
- **Recognition**: Testing if M has property P reduces to checking if any Fᵢ is a minor of M.
- **Complexity**: For graphs, this can be done in O(n³) time for fixed k (Robertson-Seymour).

## 5. The Obstruction Spectrum: A New Invariant

The obstruction spectrum σ_P : ℕ → ℕ defined by σ_P(k) = |{m ∈ Excl(P) : size(m) = k}| provides a new lens for studying minor-closed properties.

**Properties:**
1. σ_P has finite support under WQO (Theorem 3.9).
2. Σ_k σ_P(k) = |Excl(P)| (the total number of excluded minors).
3. If P ⊆ Q, the spectrum of P "dominates" that of Q in a precise sense (via Theorem 3.8).

**Example spectra:**
- Planarity (graphs): σ(5) = 2 (K₅ and K₃,₃), all others 0.
- 𝔽₂-representability (matroids): σ(4) = 1 (U₂,₄), all others 0.
- 𝔽₃-representability (matroids): σ(5) = 2 (U₂,₅, U₃,₅), σ(7) = 2 (F₇, F₇*), all others 0.

## 6. Discussion

### 6.1 The Antisymmetry Requirement

Our framework requires the minor relation to be antisymmetric (a partial order, not just a preorder). This is natural when working with isomorphism classes of matroids, but it's a genuine requirement: without antisymmetry, the excluded minors can form equivalence classes rather than antichains, and finiteness can fail.

### 6.2 The Minor-Closure Hypothesis

The forbidden minor characterization (Theorem 3.4) requires the ambient class C to be minor-closed. This is because `contains_excluded_minor` produces an excluded minor that might lie outside C if C is not minor-closed. For the GGW conjecture, this is satisfied: representability over a fixed field is preserved under taking minors.

### 6.3 Relation to Existing Work

Our framework abstracts the structural core of the Robertson-Seymour theory into a clean algebraic setting. The key insight is that the interaction between WQO and minor-closedness produces a finite basis theorem that is independent of the specific combinatorial content (graphs, matroids, etc.).

## 7. Future Work

1. **Formalize matroid deletion and contraction** and verify that they produce a valid minor system.
2. **Formalize the dual matroid** and prove that duality commutes with minors.
3. **Connect to Mathlib's matroid theory** (Matroid.Minor).
4. **Explore the obstruction spectrum** as a tool for distinguishing minor-closed properties.
5. **Formalize Higman's lemma** and use it to construct WQOs on sequences.

## References

[GGW06] J. Geelen, B. Gerards, G. Whittle. "Towards a matroid-minor structure theory." Combinatorics, Complexity, and Chance, Oxford, 2007.

[RS04] N. Robertson, P. Seymour. "Graph Minors. XX. Wagner's conjecture." J. Combin. Theory Ser. B, 2004.

[Oxl11] J. Oxley. "Matroid Theory." Oxford University Press, 2nd edition, 2011.

[Hig52] G. Higman. "Ordering by divisibility in abstract algebras." Proc. London Math. Soc., 1952.

[Dic13] L.E. Dickson. "Finiteness of the odd perfect and primitive abundant numbers with n distinct prime factors." Amer. J. Math., 1913.
