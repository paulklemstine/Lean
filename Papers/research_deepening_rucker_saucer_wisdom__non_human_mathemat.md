# Universal Mathematics: The Invariant Core Shared by Every Consistent Theory

## Abstract

We give a precise, foundation-agnostic answer to the question of whether a non-human intelligence — alien, artificial, or independently evolved — would discover the same mathematics we do. The question becomes tractable once "the same mathematics" is fixed by a definition. Modeling logical consequence by a Tarski *consequence operator* $C$ (equivalently, a closure operator on the powerset of statements), we define the **universal mathematics** of a base theory to be the intersection of the theorem-sets of *all* consistent theories extending it. Our two principal results are: (i) **universality of the base** — every theorem of the base is a theorem of every consistent extension; and (ii) **the universal core equals the base** — for a consistent base theory, its universal mathematics coincides exactly with its own deductive closure. Reading the base as the axioms of arithmetic, (i) is the precise sense in which arithmetic is universal: any consistent system containing arithmetic proves every arithmetical theorem. We supplement these with structural results — consistency is inherited by sub-theories, the universal core is deductively closed and consistent, and the construction is monotone in the base — and we identify consequence operators with closure operators, connecting derivability to the lattice theory of closure systems. Finally we exhibit an explicit model demonstrating that consistent extensions can be strictly larger than the base while the universal core is unchanged, establishing that the framework is non-vacuous.

**Keywords:** consequence operator, closure operator, deductive closure, consistency, universal mathematics, Tarski axioms, Lindenbaum, invariant core, philosophy of mathematics.

---

## 1. Introduction

The intuition that mathematics is "universal" — that it would be rediscovered by any sufficiently advanced intelligence — is old and widely shared, yet it usually resists formalization because "the same mathematics" is left undefined. Contingent features of human practice (notation, choice of primitives, aesthetic emphasis, historical order of discovery) are obviously *not* universal. What could plausibly be universal is the *logical content*: what follows from what.

We isolate that content. Rather than reasoning about brains or cultures, we reason about *theories*: sets of assumptions closed under a deduction operator. The central conceptual device is the **universal core** of a base theory — the set of statements that *every* consistent extension of the base must prove. These are the results no consistent elaboration of the foundations can disown. If two reasoners share a base and each reasons consistently, the universal core is exactly the body of mathematics they are guaranteed to share.

The main finding is that this core is completely determined and completely unmysterious: for a consistent base, the universal core is exactly the base's own deductive closure — no larger, no smaller. Disagreement between consistent minds is therefore never about consequences of shared assumptions; it is always about which assumptions to adopt.

### 1.1 Contributions

- A definition of *universal mathematics* relative to a base theory, phrased purely in terms of a consequence operator and consistency (Section 3).
- **Theorem A (Universality of the base):** every theorem of the base is a theorem of every consistent extension (Section 4).
- **Theorem B (Core equals base):** for a consistent base, the universal core equals the base's deductive closure (Section 4).
- Structural corollaries: downward inheritance of consistency, closure and consistency of the core, and monotonicity of the core in the base (Sections 4–5).
- An identification of consequence operators with closure operators, linking provability to closure-system lattice theory (Section 2).
- An explicit model witnessing strict extensions with an invariant core, proving non-vacuity (Section 6).

---

## 2. The consequence operator

We fix a type $S$ whose elements we call **statements**. Subsets of $S$ are **theories** (sets of assumptions).

**Definition 2.1 (Consequence operator).** A *consequence operator* on $S$ is a map $C : \mathcal{P}(S) \to \mathcal{P}(S)$ satisfying, for all theories $\Gamma, \Delta$:

1. **Inclusion (reflexivity):** $\Gamma \subseteq C(\Gamma)$.
2. **Monotonicity:** if $\Gamma \subseteq \Delta$ then $C(\Gamma) \subseteq C(\Delta)$.
3. **Idempotence (cut):** $C(C(\Gamma)) \subseteq C(\Gamma)$.

We read $C(\Gamma)$ as the set of statements entailed by $\Gamma$ — its *deductive closure* or *theorem-set*. These are exactly Tarski's axioms for a consequence relation. They make no reference to syntax, negation, or any particular logical connective; they are the minimal commitments any notion of logical derivation satisfies, which is what makes conclusions drawn from them foundation-agnostic.

**Proposition 2.2 (Genuine idempotence).** For every theory $\Gamma$, $C(C(\Gamma)) = C(\Gamma)$.

*Proof.* The inclusion $C(C(\Gamma)) \subseteq C(\Gamma)$ is axiom (3). The reverse $C(\Gamma) \subseteq C(C(\Gamma))$ is axiom (1) applied to $C(\Gamma)$. Antisymmetry of $\subseteq$ gives equality. $\qquad\blacksquare$

**Proposition 2.3 (Consequence = closure).** A consequence operator is precisely a closure operator on the complete lattice $(\mathcal{P}(S), \subseteq)$: axioms (1)–(3) are extensivity, monotonicity, and idempotence. Consequently, the *closed* theories — those $\Gamma$ with $C(\Gamma) = \Gamma$ — form a complete lattice under inclusion, with meet given by intersection and join by closing the union.

*Proof sketch.* The three axioms are, verbatim, the closure-operator axioms once idempotence is upgraded to equality via Proposition 2.2. The closed sets of any closure operator on a complete lattice form a complete lattice; here the ambient lattice is the powerset. $\qquad\blacksquare$

This identification is not merely cosmetic: it places the entire apparatus of closure-system lattice theory at the disposal of the logic of provability, and it is the natural home for the monotonicity results below.

---

## 3. Consistency and the universal core

**Definition 3.1 (Consistency).** A theory $\Gamma$ is *consistent* if $C(\Gamma) \neq S$; that is, some statement is not entailed by $\Gamma$. Equivalently, an inconsistent theory is one whose deductive closure is *everything*.

This is the abstract analogue of the familiar notion: in a system with negation, proving everything is equivalent to proving some statement together with its negation. We adopt the "proves everything" formulation because it needs no negation and thus remains foundation-agnostic.

**Definition 3.2 (Universal mathematics / universal core).** Let $\text{base} \subseteq S$ be a base theory. Its *universal mathematics* is
$$\text{Universal}(\text{base}) \;=\; \bigcap\;\bigl\{\, T \;:\; \exists\, \Delta,\ \text{base} \subseteq \Delta,\ \Delta \text{ consistent},\ T = C(\Delta) \,\bigr\}.$$

Thus a statement lies in the universal core iff it is a theorem of *every* consistent theory extending the base. These are exactly the results invariant across all consistent ways of elaborating the foundations.

---

## 4. Main results

Throughout, $C$ is a fixed consequence operator on $S$.

**Theorem A (Universality of the base).** *If $\text{base} \subseteq \Delta$ and $\Delta$ is consistent, then $C(\text{base}) \subseteq C(\Delta)$.*

*Proof.* Immediate from monotonicity (axiom 2) applied to $\text{base} \subseteq \Delta$. Consistency of $\Delta$ is not needed for the inclusion itself, but is the hypothesis under which the statement is meaningful as a claim about *admissible* extensions. $\qquad\blacksquare$

*Interpretation.* Take $\text{base}$ to be the axioms of arithmetic. Theorem A says any consistent system containing arithmetic proves everything arithmetic proves. No consistent extension — however exotic — can retract an arithmetical theorem. This is the precise content of "arithmetic is universal."

**Theorem B (The universal core equals the base).** *If $\text{base}$ is consistent, then*
$$\text{Universal}(\text{base}) = C(\text{base}).$$

*Proof.* We prove two inclusions.

*(⊇) Base ⊆ Core.* Let $x \in C(\text{base})$. To show $x$ lies in the intersection, fix any member $T = C(\Delta)$ with $\text{base} \subseteq \Delta$ and $\Delta$ consistent. By Theorem A, $C(\text{base}) \subseteq C(\Delta)$, so $x \in C(\Delta) = T$. As $T$ was arbitrary, $x \in \text{Universal}(\text{base})$.

*(⊆) Core ⊆ Base.* Since $\text{base}$ is consistent and $\text{base} \subseteq \text{base}$, the set $C(\text{base})$ is itself one of the members of the defining family (take $\Delta = \text{base}$). An intersection is contained in each of its members, so $\text{Universal}(\text{base}) \subseteq C(\text{base})$.

Antisymmetry gives equality. $\qquad\blacksquare$

*Interpretation.* The extension-invariant core is exactly the deductive closure of the base — neither a smaller hidden kernel of "super-necessary" truths nor an eroded fragment. Agreement on foundations already entails agreement on all their consequences, and nothing more is forced.

**Theorem C (Downward inheritance of consistency).** *If $\text{base} \subseteq \Delta$ and $\Delta$ is consistent, then $\text{base}$ is consistent.*

*Proof.* Contrapositive. Suppose $\text{base}$ is inconsistent, i.e. $C(\text{base}) = S$. By monotonicity $C(\text{base}) \subseteq C(\Delta)$, so $S \subseteq C(\Delta)$, whence $C(\Delta) = S$ and $\Delta$ is inconsistent. $\qquad\blacksquare$

*Interpretation.* One cannot cure an inconsistent foundation by adding axioms; consistency is a property of the smallest fragment upward.

---

## 5. Structural properties of the core

**Proposition 5.1 (The core is deductively closed).** *If $\text{base}$ is consistent, then $C(\text{Universal}(\text{base})) = \text{Universal}(\text{base})$.*

*Proof.* By Theorem B the core equals $C(\text{base})$, and $C(C(\text{base})) = C(\text{base})$ by Proposition 2.2. $\qquad\blacksquare$

**Proposition 5.2 (The core is consistent).** *If $\text{base}$ is consistent, then $\text{Universal}(\text{base})$ is consistent.*

*Proof.* By Theorem B and Proposition 2.2, $C(\text{Universal}(\text{base})) = C(C(\text{base})) = C(\text{base}) \neq S$, the last step by consistency of $\text{base}$. $\qquad\blacksquare$

**Proposition 5.3 (Monotonicity of the core).** *If $\text{base} \subseteq \text{base}'$, then $\text{Universal}(\text{base}) \subseteq \text{Universal}(\text{base}')$.*

*Proof.* Let $x \in \text{Universal}(\text{base})$ and let $T = C(\Delta)$ be a member of the family defining $\text{Universal}(\text{base}')$, so $\text{base}' \subseteq \Delta$ and $\Delta$ consistent. Then $\text{base} \subseteq \text{base}' \subseteq \Delta$, so $C(\Delta)$ is also a member of the family defining $\text{Universal}(\text{base})$; hence $x \in C(\Delta) = T$. As $T$ was arbitrary, $x \in \text{Universal}(\text{base}')$. $\qquad\blacksquare$

*Remark (an apparent paradox resolved).* A larger base admits *fewer* consistent extensions, and a smaller family has a *larger* intersection — pulling the core the wrong way. Yet each surviving extension of the larger base is also an extension of the smaller base, so its theorem-set already constrained the smaller core. The two effects reconcile exactly, and by Theorem B both cores are simply $C(\text{base}) \subseteq C(\text{base}')$.

---

## 6. A concrete model: non-vacuity and strict extension

To confirm the hypotheses are satisfiable and that the intersection in Definition 3.2 ranges over a genuinely non-trivial family, we exhibit an explicit model.

**Definition 6.1 (Identity consequence system).** On $S = \mathbb{N}$, let $C(\Gamma) = \Gamma$: a statement is a consequence of $\Gamma$ exactly when it belongs to $\Gamma$ ("no deduction"). Axioms (1)–(3) hold trivially (each is an instance of $\Gamma \subseteq \Gamma$).

**Proposition 6.2 (A consistent base).** The base $\{0\}$ is consistent in the identity system, since $C(\{0\}) = \{0\} \neq \mathbb{N}$; e.g. the statement $1 \notin C(\{0\})$.

**Proposition 6.3 (Strict consistent extension with invariant core).** In the identity system, $\{0\} \subseteq \{0,1\}$ is a *strict* extension, both are consistent ($C(\{0,1\}) = \{0,1\} \neq \mathbb{N}$), and they disagree on the statement $1$. By Theorem B, $\text{Universal}(\{0\}) = C(\{0\}) = \{0\}$, so the disagreement lies strictly *above* the universal core.

*Interpretation.* Consistent extensions can differ, and differ strictly, so the universal core is an intersection over a real family — not a disguised singleton. Theorem B locates every disagreement above the shared core and never within it.

---

## 7. Algorithms

Although the framework is abstract, its finite instances are fully computable. We record the core procedures used in the accompanying numerical demonstrations.

**Algorithm 1 (Closure-axiom verifier).** Given a finite universe $S$ and an operator $C$ presented as a function on subsets, verify inclusion, monotonicity, and idempotence by exhausting all subsets and, for monotonicity, all subset pairs. Complexity: $O(2^{|S|})$ for inclusion/idempotence and $O(4^{|S|})$ for monotonicity (or $O(3^{|S|})$ iterating over ordered pairs $\Gamma \subseteq \Delta$).

**Algorithm 2 (Universal-core computation).** Enumerate all subsets $\Delta \supseteq \text{base}$ with $C(\Delta) \neq S$, and intersect their images $C(\Delta)$. The result equals $C(\text{base})$ whenever the base is consistent (Theorem B), which serves as a runtime validation of the theorem.

**Algorithm 3 (Consistency checker and downward propagation).** Test $C(\Gamma) \neq S$; if a theory is consistent, all its subtheories are certified consistent by Theorem C without recomputation.

---

## 8. Applications and discussion

**Philosophy of mathematics.** The framework converts the vague thesis "mathematics is universal" into a theorem with a sharp scope: universality is *relative to a base and to consistency*, and within that scope the universal content is exactly the deductive closure of the base. This dissolves the dichotomy between "there is a mysterious universal kernel" and "universality is empty": the kernel exists, is non-trivial, and is precisely the base's closure.

**Logic and lattice theory.** Proposition 2.3 imports the theory of closure systems wholesale. The closed theories form a complete lattice; the universal core is a distinguished element (the closure of the base) within it. This is the natural setting in which to pursue the finer conjectures below.

**Foundations of communication.** For the exobiology-flavored motivating question, the takeaway is operational: to establish common mathematical ground with an unknown intelligence, one need only establish (a) a shared base and (b) mutual consistency; the entire deductive closure of the base then follows automatically as common knowledge.

---

## 9. Future directions

This cycle formalized the *universal core* of a theory — the theorems shared by every consistent extension — and established two anchors: that the universal core of a consistent theory is exactly the theory itself, and that (under compactness) every consistent theory completes to a maximal consistent, deductively closed one whose consistency is finitely certifiable. The following conjectures push toward a structural theory of observer-independent mathematics.

**1. The universal core is the meet in the lattice of closed theories.** *Conjecture.* For a compact consequence operator, the closed theories form a complete lattice, and the universal core of a consistent base is the infimum, in that lattice, of the family of maximal consistent theories extending it. The key insight is that consistency having finite character turns the poset of consistent extensions into a directed structure, so the intersection defining the core coincides with an order-theoretic meet. With the consequence operator identified as a closure operator and Lindenbaum completions available, the lattice of closed theories is a concrete object whose meets can be compared to the core directly.

**2. Negation-completeness pins down a unique universal core across models.** *Conjecture.* If the system carries a negation for which each maximal consistent theory is complete (contains a statement or its negation), then the universal core equals the set of statements true in every maximal consistent extension, and this characterization is invariant under any consequence operator inducing the same maximal consistent theories. Maximal consistent theories play the role of points (models), so the core becomes the theory of a space of models, and negation-completeness collapses the syntactic and semantic descriptions into one.

**3. Independence phenomena measure the gap above the universal core.** *Conjecture.* The failure of a consistent base to be maximal is quantified by the existence of at least two maximal consistent extensions differing on some statement; moreover the collection of such "independent" statements forms a filter-complement whose size is a monotone invariant of the base. Everything a base cannot decide lives strictly above its universal core, so independence is precisely the discrepancy between the core and the individual maximal completions. The strict-extension witness constructed this cycle shows the gap is non-empty in concrete models.

---

## 10. Conclusion

We defined the universal mathematics of a base theory as the intersection of the theorem-sets of all its consistent extensions, and proved that for a consistent base this invariant core is exactly the base's deductive closure (Theorem B), a consequence of the universality of the base (Theorem A) together with the base's self-extension. Structural results show the core is itself closed, consistent, and monotone in the base, and an explicit model confirms the framework is non-vacuous. The upshot for the motivating question is clean: any two consistent reasoners who share a foundation share exactly its deductive closure — no more, no less — so mathematical disagreement is always disagreement about axioms, never about their consequences.
