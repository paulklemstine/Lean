# Dream Logic: Non-Monotone Paraconsistent Reasoning and Quasi-Topological Semantics

## Abstract

We develop a formal theory of "dream logic" — a paraconsistent, non-monotone reasoning framework where contradictions coexist without explosion. Our formalization is grounded in Belnap's four-valued semantics (true, false, both, neither), equipped with support-based connectives satisfying De Morgan duality. We prove three main results: (1) the explosion principle fails in Belnap logic, with contradictions remaining locally contained; (2) skeptical consequence relations over conflict systems are genuinely non-monotone, satisfying singleton reflexivity but failing both full reflexivity and monotonicity; (3) monotone consequence relations yield upward-closed premise families (forming Alexandrov topologies), while non-monotone relations produce quasi-topological spaces that fail the arbitrary union axiom. We introduce the concepts of *dream frames* (Kripke frames with Belnap valuations), *dream depth* (measuring contradiction density), and *dream defect* (measuring topological failure), establishing a precise bridge between paraconsistent logic and point-set topology.

**Keywords**: Paraconsistent logic, Belnap four-valued logic, non-monotone reasoning, quasi-topological spaces, belief revision, dream frames

## 1. Introduction

Classical logic is monotone: adding premises never retracts conclusions. It is also explosive: a single contradiction trivializes the entire system via *ex falso quodlibet*. While these properties are desirable in many formal contexts, they poorly model reasoning under inconsistency — a ubiquitous feature of databases, AI knowledge bases, legal systems, and cognitive processes.

Paraconsistent logics [1, 2] address explosion by allowing contradictions without trivialization. Non-monotone logics [3, 4] address belief revision by allowing premises to retract conclusions. In this paper, we combine both features into a unified framework we call "dream logic," motivated by the observation that dream reasoning simultaneously tolerates contradictions and revises beliefs.

Our main contribution is a formal bridge between these logical properties and topology: we show that monotone reasoning corresponds to genuine topological spaces (via upward-closed families), while non-monotone reasoning corresponds to quasi-topological spaces that fail the union axiom. This bridge is mediated by "dream frames" — a novel combination of Kripke possible-worlds semantics with Belnap four-valued valuations.

All results have been formalized and verified in Lean 4 with Mathlib.

## 2. Belnap Four-Valued Logic

### 2.1 Truth Values and Support

We work with Belnap's four truth values BVal = {t, f, b, n}, where:
- **t** (true): has positive support only
- **f** (false): has negative support only
- **b** (both): has both positive and negative support
- **n** (neither): has no support

Each value is characterized by two Boolean coordinates: positive support `pos(v)` and negative support `negS(v)`. The reconstruction function `ofSupport(p, n)` inverts this:
- ofSupport(true, true) = b
- ofSupport(true, false) = t
- ofSupport(false, true) = f
- ofSupport(false, false) = n

**Theorem 2.1** (Support faithfulness): `ofSupport(pos(v), negS(v)) = v` for all v.

### 2.2 Connectives

**De Morgan negation** swaps positive and negative evidence:
- neg(t) = f, neg(f) = t, neg(b) = b, neg(n) = n

**Conjunction** combines support conjunctively for positive and disjunctively for negative:
- conj(a, c) = ofSupport(pos(a) ∧ pos(c), negS(a) ∨ negS(c))

**Disjunction** is the De Morgan dual:
- disj(a, c) = ofSupport(pos(a) ∨ pos(c), negS(a) ∧ negS(c))

**Theorem 2.2** (De Morgan duality):
- neg(conj(a, c)) = disj(neg(a), neg(c))
- neg(disj(a, c)) = conj(neg(a), neg(c))

**Theorem 2.3** (Negation involution): neg(neg(v)) = v.

### 2.3 Designation and Explosion Failure

A value is *designated* (accepted as a conclusion) iff it has positive support: isDesignated(v) = pos(v). Both t and b are designated.

**Theorem 2.4** (Conjunction preserves designation):
isDesignated(conj(a, c)) = true ↔ isDesignated(a) = true ∧ isDesignated(c) = true

**Theorem 2.5** (Explosion failure): For any n ≥ 2, there exists a valuation v : Fin n → BVal such that conj(v(0), neg(v(0))) is designated, yet v(i) is not designated for all i ≠ 0.

*Proof sketch*: Set v(0) = b and v(i) = f for i > 0. Then conj(b, neg(b)) = conj(b, b) = b is designated, while f is not. □

This is the fundamental paraconsistent property: contradictions are *locally contained*. The contradiction at proposition 0 does not propagate to other propositions.

## 3. Dream Frames

### 3.1 Definition

A **dream frame** F = (W, R, V) consists of:
- A set W of *dream worlds*
- An accessibility relation R ⊆ W × W
- A four-valued valuation V : W → P → BVal

Unlike standard Kripke frames, V assigns Belnap values (not just true/false), and R need not be transitive (modeling non-logical dream jumps).

### 3.2 Modal Operators

- **Dream possibility**: ◇p holds at w iff ∃w'. R(w,w') ∧ isDesignated(V(w',p))
- **Dream necessity**: □p holds at w iff ∀w'. R(w,w') → isDesignated(V(w',p))
- **Dream negation necessity**: □¬p holds at w iff ∀w'. R(w,w') → isDesignated(neg(V(w',p)))

### 3.3 Coexistence of Contradictions

**Theorem 3.1** (Dream contradiction coexistence): There exists a dream frame F and a world w such that □p and □¬p both hold at w.

*Proof*: Take W = {w₀}, R = W × W, V(w₀, p) = b. Since neg(b) = b, both b and neg(b) are designated. □

**Theorem 3.2** (Necessity without impossibility): There exists a dream frame where □p holds while ¬□¬p fails — that is, p is necessary yet its negation is also possible. In classical Kripke semantics, □p implies ¬◇¬p, but in dream frames this fails.

## 4. Non-Monotone Consequence

### 4.1 Conflict Systems and Skeptical Consequence

A **conflict system** C on propositions α specifies a binary "conflicts" relation. The **skeptical consequence** relation is:

Γ ⊢_C p  iff  p ∈ Γ ∧ ∀q ∈ Γ, ¬conflicts(p, q)

This captures *cautious reasoning*: a conclusion follows only if no premise contradicts it.

### 4.2 Properties

**Theorem 4.1** (Singleton reflexivity): If ¬conflicts(p, p), then {p} ⊢_C p.

**Theorem 4.2** (Reflexivity failure): There exists C such that the full reflexivity property (p ∈ Γ → Γ ⊢ p) fails.

*Proof*: Take conflicts(0, 1) and conflicts(1, 0). Then 0 ∈ {0, 1} but {0, 1} ⊬ 0 since 1 conflicts with 0. □

**Theorem 4.3** (Non-monotonicity): There exists C such that ⊢_C is not monotone.

*Proof*: Same C. {0} ⊢ 0 but {0, 1} ⊬ 0, despite {0} ⊆ {0, 1}. □

**Theorem 4.4** (Belief retraction): For any C, p, q with conflicts(p, q) and ¬conflicts(p, p):
{p} ⊢ p  and  {p, q} ⊬ p.

This formalizes the core mechanism of belief revision: adding conflicting information retracts previously valid conclusions.

## 5. Quasi-Topological Spaces and the Logic-Topology Bridge

### 5.1 Quasi-Topological Spaces

A **quasi-topological space** (X, τ) consists of a set X and a predicate isQOpen on subsets satisfying:
1. ∅ and X are quasi-open
2. Finite intersections of quasi-open sets are quasi-open
3. (No union axiom)

Every topological space is a quasi-topological space (Theorem 5.1), and a quasi-topological space is topological iff it satisfies the arbitrary union axiom.

### 5.2 The Finite Quasi-Topology

**Definition**: The *finite quasi-topology* on ℕ declares S quasi-open iff S = ∅, S = ℕ, or S is finite.

**Theorem 5.2**: The finite quasi-topology is a valid quasi-topological space.

**Theorem 5.3**: The finite quasi-topology is NOT topological.

*Proof*: Consider f(n) = {2n}. Each {2n} is finite, hence quasi-open. But ⋃_n {2n} = {even naturals}, which is infinite and ≠ ℕ (since 1 is not even), hence not quasi-open. □

### 5.3 The Logic-Topology Correspondence

**Theorem 5.4** (Monotone ↔ upward closed): If a consequence relation R is monotone, then for each conclusion p, the set {Γ | R.entails Γ p} is upward-closed under ⊆.

The collection of upward-closed sets on any poset forms an Alexandrov topology. Thus monotone consequence relations naturally generate topological structures.

**Theorem 5.5** (Non-monotone ↔ non-upward-closed): The skeptical consequence relation produces premise-sets that are NOT upward-closed.

*Proof*: {0} ∈ {Γ | Γ ⊢ 0} and {0} ⊆ {0, 1}, but {0, 1} ∉ {Γ | Γ ⊢ 0}. □

**Corollary**: Non-monotone reasoning corresponds to quasi-topological structures that fail to be topological. The "dream defect" — the existence of quasi-open families whose union is not quasi-open — precisely characterizes the gap between monotone and non-monotone reasoning.

### 5.4 Dream Defect

**Definition**: A quasi-topological space has a *dream defect* if there exists a family of quasi-open sets whose union is not quasi-open.

**Theorem 5.6**: A quasi-topology has a dream defect iff it is not topological.

**Theorem 5.7**: The finite quasi-topology has a dream defect.

## 6. Dream Depth

### 6.1 Measuring Contradiction Density

For a Belnap valuation v : Fin n → BVal, the **dream depth** is the number of propositions assigned the contradictory value b:

dreamDepth(v) = |{i | v(i) = b}|

**Theorem 6.1**: dreamDepth(v) = n iff ∀i, v(i) = b.

**Theorem 6.2**: dreamDepth(v) equals the number of propositions where both the proposition and its negation are designated. That is, v(i) = b iff isDesignated(v(i)) ∧ isDesignated(neg(v(i))).

### 6.2 Dream Chromatic Conjecture

We conjecture a connection between dream depth and graph coloring:

**Conjecture**: For a conflict graph G on n propositions with chromatic number χ(G), the minimum dream depth needed for all propositions to be designated while respecting the conflict structure is n − χ(G).

**Theorem 6.3** (Trivial case verified): For n = 3 with no conflicts, dream depth 0 suffices for full designation (assign t to all propositions).

**Testable prediction**: For K₄ (complete graph on 4 vertices, χ = 4), the minimum dream depth should be 0. For K₄ with 2-coloring constraint (χ = 2 is insufficient), minimum dream depth should be 2.

## 7. Related Work

Belnap's four-valued logic [5] was originally motivated by database applications. Priest's LP (Logic of Paradox) [1] is a related three-valued paraconsistent system. Non-monotone logics include Reiter's default logic [3], circumscription [4], and the stable model semantics [6]. The topological semantics of modal logic is well-established [7], but the quasi-topological connection to non-monotone reasoning appears to be new. Dream frames combine ideas from Kripke semantics [8] and Belnap's bilattice framework.

## 8. Future Work

Key open directions include:
1. Characterizing which quasi-topologies arise from specific conflict systems
2. Developing a proof theory for dream frames (completeness, decidability)
3. Connecting dream depth to computational complexity (can bounded dream depth make decision problems easier?)
4. Extending to infinite-valued dream logic using continuous support functions
5. Exploring connections to rough set theory and formal concept analysis

## References

[1] G. Priest, "The Logic of Paradox," Journal of Philosophical Logic, 1979.
[2] N. da Costa, "On the Theory of Inconsistent Formal Systems," Notre Dame Journal of Formal Logic, 1974.
[3] R. Reiter, "A Logic for Default Reasoning," Artificial Intelligence, 1980.
[4] J. McCarthy, "Circumscription — A Form of Non-Monotone Reasoning," Artificial Intelligence, 1980.
[5] N. Belnap, "A Useful Four-Valued Logic," in Modern Uses of Multiple-Valued Logic, 1977.
[6] M. Gelfond and V. Lifschitz, "The Stable Model Semantics for Logic Programming," ICLP, 1988.
[7] J.C.C. McKinsey and A. Tarski, "The Algebra of Topology," Annals of Mathematics, 1944.
[8] S. Kripke, "Semantical Considerations on Modal Logic," Acta Philosophica Fennica, 1963.
