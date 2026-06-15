# Provability Logic GL: Algebraic Semantics, Kripke Frames, and the Lattice of Theories

## Abstract

We present a unified formal framework for provability logic GL (Gödel-Löb logic), connecting three perspectives: (1) algebraic semantics via provability lattices, (2) Kripke semantics via finite transitive irreflexive frames, and (3) the lattice-theoretic structure of consistent theory extensions. Our main contributions are:

- A formalization of **provability lattices** as distributive lattices with a monotone box operator, including the concept of Gödel elements and a proof that any nontrivial consistent provability lattice with a Gödel element contains independent (undecidable) elements.

- A formalization of **GL Kripke frames** as finite transitive irreflexive structures, with a proof that such frames validate Löb's axiom via well-founded induction — establishing the soundness of GL for its characteristic frame class.

- The **well-foundedness theorem** for GL frames: the accessibility relation on any finite transitive irreflexive frame is well-founded, connecting GL to the theory of well-founded orderings.

- A **theory space construction** showing that proper filters on a provability lattice form a GL frame under the strict subset relation, providing a concrete bridge between the algebraic and semantic perspectives.

All results are machine-verified in Lean 4 with Mathlib.

## 1. Introduction

Provability logic GL, introduced by Solovay [1976], is the modal logic of formal provability in Peano Arithmetic. Its distinctive axiom — Löb's axiom □(□p → p) → □p — captures the behavior of the Hilbert-Bernays-Löb derivability conditions and subsumes both Löb's theorem and Gödel's second incompleteness theorem as special cases.

The algebraic semantics of GL uses **provability algebras** (also called Magari algebras or diagonalizable algebras): Boolean algebras equipped with a unary operator □ satisfying the GL axioms. The Kripke semantics uses finite transitive irreflexive frames. Solovay's completeness theorem establishes that GL is sound and complete for both semantics.

Our work formalizes the core of this theory, emphasizing the lattice-theoretic perspective. The key insight is that **incompleteness is a lattice-theoretic phenomenon**: Gödel elements in a provability lattice create binary branching in the lattice of consistent extensions, and the existence of independent elements is a structural consequence of the self-refuting/self-affirming duality of Gödel sentences.

### 1.1 Related Work

Formal verifications of Gödel's theorems have been undertaken in various proof assistants, including Isabelle/HOL (Paulson, 2015) and Coq (O'Connor, 2005). Our approach differs by working at the algebraic/lattice-theoretic level rather than formalizing the arithmetic directly. This yields cleaner proofs and reveals structural connections that are obscured by arithmetic encoding.

The algebraic theory of provability is developed extensively by Boolos [1993], Artemov and Beklemishev [2004], and Verbrugge [2017]. Our formalization follows the algebraic approach of Magari [1975] and the lattice-theoretic perspective of Smoryński [1985].

## 2. Provability Lattices

### 2.1 Definition

A **provability lattice** is a bounded distributive lattice (L, ⊓, ⊔, ⊥, ⊤) equipped with a monotone operator □ : L → L satisfying □⊤ = ⊤.

The elements of L represent equivalence classes of sentences under provable equivalence. The lattice operations correspond to logical connectives: ⊓ = conjunction, ⊔ = disjunction, ⊥ = contradiction, ⊤ = tautology. The operator □ models provability: □a represents the equivalence class of the sentence "a is provable."

### 2.2 Gödel Elements

A **Gödel element** in a provability lattice L is an element g ∈ L satisfying:
1. **Self-refutation**: g ⊓ □g = ⊥
2. **Self-affirmation**: g ⊔ □g = ⊤

Condition (1) says that g and "g is provable" are contradictory — g asserts its own unprovability. Condition (2) says that either g holds or g is provable — this is the law of excluded middle applied to the Gödel sentence.

### 2.3 Incompleteness Theorem (Lattice Version)

**Theorem 1** (Gödel Element Incompleteness). *Let L be a nontrivial provability lattice (⊥ ≠ ⊤) with □⊥ = ⊥ (consistency). If g is a Gödel element in L, then □g ≠ ⊤ — the Gödel sentence is not provable.*

**Proof.** Suppose □g = ⊤. By self-refutation, g ⊓ ⊤ = ⊥, so g = ⊥. Then by self-affirmation, ⊥ ⊔ □⊥ = ⊤. But □⊥ = ⊥ by consistency, giving ⊥ = ⊤, contradicting nontriviality. □

**Corollary 1** (Independent Element Existence). *Under the same conditions, g is an independent element: g ≠ ⊥, g ≠ ⊤, and □g ≠ ⊤.*

### 2.4 Consequences Map

For each element a ∈ L, the **consequences** of a are the upward closure ↑a = {b ∈ L | a ≤ b}. This map is antitone: if a ≤ b then ↑b ⊆ ↑a (stronger statements have more consequences). The consequences of ⊥ is all of L (ex falso), and the consequences of ⊤ is {⊤}.

### 2.5 Provability Iteration

The **iteration hierarchy** □⁰a = a, □ⁿ⁺¹a = □(□ⁿa) forms a monotonically increasing sequence when □ is inflationary (a ≤ □a, i.e., soundness). We prove □ⁿ⊤ = ⊤ for all n.

### 2.6 Soundness-Extensiveness Collapse

**Theorem 2** (Collapse). *If a provability lattice satisfies both soundness (□a ≤ a) and extensiveness (a ≤ □a), then □ is the identity: □a = a for all a.*

This shows that no nontrivial GL algebra can be both sound and extensive — the two conditions collapse the provability operator to the identity.

## 3. GL Kripke Frames

### 3.1 Definition

A **GL frame** is a pair (W, R) where W is a finite set of worlds and R ⊆ W × W is a transitive, irreflexive relation. The irreflexivity condition — no world sees itself — is the semantic counterpart of Gödel's second incompleteness theorem.

### 3.2 Box and Diamond

The **box operator** on a GL frame is defined by:
□S = {w ∈ W | ∀v, R(w,v) → v ∈ S}

The **diamond operator** is its dual:
◇S = {w ∈ W | ∃v, R(w,v) ∧ v ∈ S}

We prove □ and ◇ are dual: ◇S = (□Sᶜ)ᶜ and □S = (◇Sᶜ)ᶜ.

### 3.3 Properties of □

We establish:
- **Monotonicity**: S ⊆ T implies □S ⊆ □T
- **□W = W**: tautologies are provable
- **Distribution**: □(S ∩ T) = □S ∩ □T
- **Upward closure**: If w ∈ □S and R(w,v) then v ∈ □S

### 3.4 Well-Foundedness

**Theorem 3** (Well-Foundedness). *The accessibility relation of any GL frame is well-founded.*

**Proof.** By the well-founded characterization: we show every nonempty subset has an R-minimal element. Given a nonempty finite set, proceed by strong induction on cardinality. □

### 3.5 Löb's Axiom on GL Frames

**Theorem 4** (GL Soundness for Löb's Axiom). *For any GL frame (W, R) and set S ⊆ W:*
*□((□S)ᶜ ∪ S) ⊆ □S*

This states that GL frames validate Löb's axiom. The proof uses well-founded induction on R.

**Proof sketch.** Let w ∈ □((□S)ᶜ ∪ S) and suppose R(w,v). We must show v ∈ S. By well-founded induction, assume all R-successors of v satisfy S. Then v ∈ □S. Since w ∈ □((□S)ᶜ ∪ S) and R(w,v), we have v ∈ (□S)ᶜ ∪ S. Since v ∈ □S, the first disjunct fails, so v ∈ S. □

This is the deepest theorem in our formalization, requiring the interplay of well-foundedness, transitivity, and the specific structure of Löb's axiom.

### 3.6 Maximal Worlds

A world w is **maximal** if it has no R-successors. At maximal worlds, □S holds vacuously for any S. We prove that every nonempty GL frame has at least one maximal world (by well-foundedness of the reverse relation).

### 3.7 Upward-Closed Sets

We show that the upward-closed subsets of a GL frame are closed under intersection, union, and contain both ∅ and W. Moreover, □S is always upward-closed. This establishes that the upward-closed sets form a sublattice of the power set.

## 4. Theory Space Construction

### 4.1 Theory Worlds

Given a provability lattice L, a **theory world** is a proper filter F on L: an upward-closed, meet-closed set containing ⊤ but not ⊥. Theory worlds represent consistent complete theories.

### 4.2 Extension Relation

Two theory worlds are related by **strict extension** if one filter strictly contains the other. This relation is irreflexive and transitive, making the set of theory worlds a GL frame.

### 4.3 Theory Branching

**Theorem 5** (Theory Branching). *If G is independent of a theory T (i.e., neither G nor its negation nG is a theorem), and G ≠ nG, then the extensions T ∪ {G} and T ∪ {nG} are distinct.*

This formalizes the idea that independent sentences create binary branching in the space of theories.

## 5. The Abstract Löb System

### 5.1 Definition

A **Löb system** consists of a type of sentences, a provability predicate, and logical connectives satisfying:
- **Modus ponens**: From ⊢(p → q) and ⊢p, derive ⊢q
- **Löb's condition**: If ⊢(□p → p) then ⊢p

### 5.2 Gödel's Second Incompleteness (Abstract)

**Theorem 6** (Gödel's Second, Abstract). *In a consistent Löb system, the consistency statement is not provable.*

**Proof.** If ⊢Con(T) then ⊢(□⊥ → ⊥). By Löb's condition applied to ⊥: ⊢⊥. Contradiction with consistency. □

This reveals Gödel's second incompleteness theorem as an immediate corollary of Löb's theorem.

## 6. Algorithms

### 6.1 GL Validity Checker

Given a modal formula φ and a GL frame (W, R, V), checking whether φ is valid reduces to evaluating □ and ◇ operators on subsets of W. This can be done in O(|W|² · |φ|) time by processing subformulas bottom-up.

### 6.2 Gödel Element Finder

Given a provability lattice L (finite), finding Gödel elements reduces to checking all pairs (g, □g) for the self-refutation and self-affirmation conditions. Complexity: O(|L|) after precomputing □.

## 7. Discussion

### 7.1 What Incompleteness Really Is

Our framework reveals that Gödelian incompleteness is not primarily about arithmetic or Gödel numbering — it is about the algebraic structure of self-referential operators on lattices. The essential ingredients are:
1. A lattice with top and bottom (representing tautology and contradiction)
2. A monotone operator □ (representing provability)
3. A Gödel element (a complement of □g)
4. Consistency (□⊥ = ⊥)

From these four ingredients alone, incompleteness follows.

### 7.2 The Well-Foundedness Connection

The well-foundedness of GL frames connects provability logic to ordinal analysis. The ordinal height of a world in a GL frame corresponds to the consistency strength of the corresponding theory. The consistency hierarchy Con(T), Con(T + Con(T)), ... corresponds to ascending the ordinal hierarchy ω, ω+1, ω+2, ....

### 7.3 Limitations

Our formalization works at the algebraic level and does not include Solovay's arithmetic completeness theorem, which requires a detailed formalization of Peano Arithmetic and its provability predicate. This is a natural target for future work.

## 8. Future Work

1. **Solovay's Completeness Theorem**: Formalizing that GL is arithmetically complete — every GL-consistent formula has an arithmetical model.

2. **Japaridze's Polymodal Logic GLP**: Extending from a single □ to a family □_α indexed by ordinals, capturing the full ordinal analysis of formal theories.

3. **Lattice of Consistent Extensions**: Proving that the set of consistent deductively closed extensions of PA forms a distributive lattice, and characterizing its structure.

4. **Connection to Tropical Algebra**: Investigating the lattice-theoretic connection between provability algebras and tropical semirings, where the min operation corresponds to lattice meet.

## References

- Boolos, G. (1993). *The Logic of Provability*. Cambridge University Press.
- Gödel, K. (1931). Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I. *Monatshefte für Mathematik und Physik*, 38, 173-198.
- Kripke, S. (1963). Semantical analysis of modal logic I. *Zeitschrift für mathematische Logik*, 9, 67-96.
- Löb, M. H. (1955). Solution of a problem of Leon Henkin. *Journal of Symbolic Logic*, 20(2), 115-118.
- Magari, R. (1975). The diagonalizable algebras. *Bollettino della Unione Matematica Italiana*, 12, 117-125.
- Segerberg, K. (1971). *An Essay in Classical Modal Logic*. Uppsala Universitet.
- Smoryński, C. (1985). *Self-Reference and Modal Logic*. Springer.
- Solovay, R. (1976). Provability interpretations of modal logic. *Israel Journal of Mathematics*, 25, 287-304.
