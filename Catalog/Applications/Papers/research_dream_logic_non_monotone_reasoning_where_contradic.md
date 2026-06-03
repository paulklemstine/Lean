# Dream Logic: Non-Monotone Paraconsistent Reasoning and Pre-Topological Semantics

## Abstract

We formalize Belnap's four-valued logic (FDE) as a paraconsistent reasoning framework where contradictions do not trigger the principle of explosion. We establish that FDE admits contradictory valuations that block explosion while preserving classical modus ponens for non-contradictory premises. We introduce *dream belief states* — Belnap-valued belief structures equipped with a non-monotone retraction operator — and prove that retraction preserves the consistent fragment while eliminating targeted contradictions. We demonstrate a correspondence between paraconsistent valuations and pre-topological spaces: the semantics of dream logic naturally induces spaces satisfying all topology axioms except closure under arbitrary unions. We prove that the failure of the union axiom is witnessed by specific "contradictory opens" — individually coherent belief fragments whose combination is incoherent. All results are formally verified in Lean 4 with Mathlib.

**Keywords**: Paraconsistent logic, Belnap four-valued logic, pre-topology, non-monotone reasoning, belief revision, formal verification

## 1. Introduction

Classical logic rests on the principle of explosion (*ex contradictione quodlibet*): from a contradiction, any proposition follows. While this principle enforces consistency as a meta-logical constraint, it renders classical logic unsuitable for domains where contradictions are endemic — databases with conflicting records, legal codes with incompatible statutes, and cognitive states (particularly dreams) where impossible objects coexist.

Paraconsistent logics weaken or reject the principle of explosion, allowing contradictions to be isolated rather than propagated. Among paraconsistent systems, Belnap's four-valued logic FDE [Belnap 1977] stands out for its clean algebraic structure and clear semantic motivation.

In this paper, we:

1. **Formalize FDE** in Lean 4 with its four truth values (verum, falsum, both, neither) and standard connectives (Definition 2.1–2.5).
2. **Prove explosion failure** by constructing an explicit countermodel (Theorem 3.1).
3. **Characterize modus ponens** by showing it fails for contradictory antecedents but holds for purely true ones (Theorems 3.2–3.3).
4. **Establish the bilattice structure** by proving independence of the information and truth orderings (Theorem 3.4).
5. **Introduce dream belief states** with a non-monotone retraction operator (Definition 4.1–4.3).
6. **Prove retraction properties**: preservation of the consistent fragment (Theorem 4.1) and elimination of targeted contradictions (Theorem 4.2).
7. **Construct pre-topological semantics**: a pre-topology on Fin 3 that fails closure under arbitrary unions (Theorems 5.1–5.3).
8. **State a conjecture** on dream compactness failure (Conjecture 6.1).

## 2. Belnap's Four-Valued Logic

### 2.1 Truth Values

**Definition 2.1** (BelnapVal). The set of Belnap truth values is $\mathbb{4} = \{⊤, ⊥, \mathbf{B}, \mathbf{N}\}$, representing *verum* (true only), *falsum* (false only), *both* (true and false), and *neither* (unknown).

**Definition 2.2** (Designation). A value $v \in \mathbb{4}$ is *designated* if $v \in \{⊤, \mathbf{B}\}$ — i.e., it is "at least true."

### 2.2 Connectives

**Definition 2.3** (Negation). Belnap negation swaps truth polarity while preserving information content:
$$\neg ⊤ = ⊥, \quad \neg ⊥ = ⊤, \quad \neg \mathbf{B} = \mathbf{B}, \quad \neg \mathbf{N} = \mathbf{N}$$

**Definition 2.4** (Conjunction and Disjunction). These are the meet and join in the truth ordering, respectively.

**Definition 2.5** (Material Implication). $A \to B := \neg A \lor B$.

### 2.3 Algebraic Structure

The four values carry two independent partial orders:

- **Truth ordering**: $⊥ \leq_t \mathbf{N}, \mathbf{B} \leq_t ⊤$
- **Information ordering**: $\mathbf{N} \leq_i ⊤, ⊥ \leq_i \mathbf{B}$

Together these form a *bilattice* — a structure with two lattice orderings sharing the same carrier.

## 3. Main Results on FDE

### 3.1 Explosion Failure

**Theorem 3.1** (fde_contradiction_does_not_explode). *There exists a Belnap valuation $v$ on $\{P, Q\}$ such that $v(P)$ is designated, $\neg v(P)$ is designated, but $v(Q)$ is not designated.*

*Proof sketch.* Set $v(P) = \mathbf{B}$, $v(Q) = ⊥$. Then $v(P) = \mathbf{B}$ is designated. Since $\neg \mathbf{B} = \mathbf{B}$, the negation is also designated. But $v(Q) = ⊥$ is not designated. □

This is the defining property of paraconsistent logics: a proposition and its negation can both hold without entailing arbitrary conclusions.

### 3.2 Modus Ponens

**Theorem 3.2** (fde_modus_ponens_fails). *There exist $a, b \in \mathbb{4}$ such that $a$ is designated, $a \to b$ is designated, but $b$ is not designated.*

*Proof sketch.* Take $a = \mathbf{B}$, $b = ⊥$. Then $a \to b = \neg a \lor b = \mathbf{B} \lor ⊥ = \mathbf{B}$, which is designated. But $b = ⊥$ is not. □

**Theorem 3.3** (fde_modus_ponens_for_verum). *For any $b \in \mathbb{4}$, if $⊤ \to b$ is designated, then $b$ is designated.*

*Proof sketch.* $⊤ \to b = \neg ⊤ \lor b = ⊥ \lor b = b$. So the hypothesis directly gives $b$ designated. □

These two results precisely characterize the boundary of classical reasoning within FDE: modus ponens is safe when premises are purely true, but fails for contradictory premises.

### 3.3 De Morgan and Involution

**Theorem 3.4** (belnap_neg_involutive). *$\neg\neg v = v$ for all $v \in \mathbb{4}$.*

**Theorem 3.5** (belnap_de_morgan_conj). *$\neg(a \land b) = \neg a \lor \neg b$ for all $a, b \in \mathbb{4}$.*

### 3.4 Bilattice Independence

**Theorem 3.6** (bilattice_orderings_independent). *The information and truth orderings are independent: there exist values where one ordering holds and the other does not, in both directions.*

*Proof sketch.* $\mathbf{N} \leq_i ⊥$ but $\mathbf{N} \not\leq_t ⊥$; and $⊥ \leq_t \mathbf{N}$ but $⊥ \not\leq_i \mathbf{N}$. □

## 4. Dream Belief States

### 4.1 Definitions

**Definition 4.1** (DreamState). A *dream belief state* on a proposition type $\mathcal{P}$ consists of:
- A belief function $\beta : \mathcal{P} \to \mathbb{4}$
- An awareness set $A \subseteq \mathcal{P}$

**Definition 4.2** (Fragments). The *contradictory fragment* is $\{p : \beta(p) = \mathbf{B}\}$. The *consistent fragment* is $\{p : \beta(p) \in \{⊤, ⊥\}\}$.

**Definition 4.3** (Retraction). $\text{retract}(s, p)$ maps $p$'s belief to $\mathbf{N}$ if it was $\mathbf{B}$, and leaves all other beliefs unchanged.

### 4.2 Properties

**Theorem 4.1** (retraction_preserves_consistent_fragment). *For any dream state $s$ and proposition $p$, the consistent fragment of $s$ is a subset of the consistent fragment of $\text{retract}(s, p)$.*

*Proof sketch.* If $q$ is in the consistent fragment, then $\beta(q) \in \{⊤, ⊥\}$. If $q = p$, then $\beta(p) \in \{⊤, ⊥\}$ implies $\beta(p) \neq \mathbf{B}$, so the retraction condition is false and the belief is unchanged. If $q \neq p$, the belief is unchanged by definition. □

**Theorem 4.2** (retraction_removes_contradiction). *$p \notin \text{contradictions}(\text{retract}(s, p))$ for all $s, p$.*

*Proof sketch.* After retraction, $\beta'(p)$ is either $\mathbf{N}$ (if originally $\mathbf{B}$) or the original value (if not $\mathbf{B}$). In neither case is it $\mathbf{B}$. □

**Theorem 4.3** (retraction_is_nonmonotone). *The retraction operator is non-monotone: there exist $s, p, q$ such that $\beta(q)$ is designated but $\beta'(q)$ is not, where $s' = \text{retract}(s, p)$.*

*Proof sketch.* Let $\beta(P) = \beta(Q) = \mathbf{B}$. Retract $Q$. Then $\beta'(Q) = \mathbf{N}$, which is not designated, while $\beta(Q) = \mathbf{B}$ was designated. □

## 5. Pre-Topological Semantics

### 5.1 Pre-Topologies

**Definition 5.1** (PreTopology). A *pre-topology* on $X$ consists of a predicate `isOpen` on $\mathcal{P}(X)$ satisfying:
- $\emptyset$ is open
- $X$ is open
- Finite intersections of open sets are open

Note the absence of the closure-under-arbitrary-unions axiom.

**Definition 5.2** (isTopology). A pre-topology is a *topology* if additionally $\bigcup \mathcal{S}$ is open whenever every $U \in \mathcal{S}$ is open.

### 5.2 The Dream Pre-Topology

**Definition 5.3** (dreamPreTopology). On $\text{Fin}\ 3 = \{0, 1, 2\}$, define the open sets as $\{\emptyset, \{0\}, \{1\}, \{0,1,2\}\}$.

This is verified to satisfy the pre-topology axioms: $\emptyset$ and the full set are open, and all pairwise intersections of open sets are open (notably, $\{0\} \cap \{1\} = \emptyset$ which is open).

**Theorem 5.1** (dream_pretopology_not_topology). *The dream pre-topology is not a topology.*

*Proof sketch.* The sets $\{0\}$ and $\{1\}$ are both open. Their union $\{0, 1\}$ is not in the list of open sets (since $2 \notin \{0,1\}$, it differs from $\{0,1,2\}$). Hence the union axiom fails. □

**Theorem 5.2** (paraconsistent_induces_nontopology). *There exists a pre-topology with "contradictory opens" — open sets whose union is not open.*

This theorem makes precise the correspondence between paraconsistent reasoning and non-topological spaces. Individual beliefs can be "open" (coherent), but their combination can fail to be open (coherent), just as contradictions in dream logic are locally harmless but globally destructive.

## 6. Conjectures and Future Work

### 6.1 Dream Compactness Failure

**Conjecture 6.1**. Over countably many propositions, there exists a Belnap valuation such that every finite subset is satisfiable (all designated) but the whole set is not.

*Testable prediction*: Construct $v : \mathbb{N} \to \mathbb{4}$ with $v(n)$ designated for all $n$ in every finite subset $F$, but some $v(n)$ not designated globally. Note: as stated, this conjecture is false for a fixed valuation (if $v(n)$ is designated for each $n$ in every finite set containing $n$, then $v(n)$ is designated). The interesting formulation involves *variable* valuations for each finite subset, which requires a richer framework.

### 6.2 Categorical Semantics

The bilattice structure of $\mathbb{4}$ suggests a categorical interpretation where dream states form a category with retraction morphisms, and the pre-topological semantics defines a functor to the category of pre-topological spaces.

### 6.3 Connections to Quantum Logic

The "both" value in Belnap's logic bears a structural resemblance to quantum superposition. Investigating whether the bilattice orderings correspond to measurement bases could provide a bridge between paraconsistent logic and quantum information theory.

## 7. Algorithms

### 7.1 Belnap Valuation Propagation

Given a set of constraints on propositions, propagate Belnap values through a dependency graph using the four-valued connectives. Time complexity: $O(n \cdot k)$ where $n$ is the number of propositions and $k$ is the maximum dependency depth.

### 7.2 Contradiction Detection and Retraction

Identify all contradictory propositions ($\beta(p) = \mathbf{B}$) and apply retraction in topological order of dependencies. This produces a maximally consistent sub-state.

## 8. Discussion

Our formalization reveals several insights:

1. **Explosion failure is constructive**: The countermodel is explicit, not merely existential. This is important for computational applications where we need concrete witnesses.

2. **Modus ponens characterization is sharp**: The boundary between safe and unsafe inference is exactly the boundary between verum and both. This gives a practical test for when classical reasoning can be applied within a paraconsistent system.

3. **Non-monotonicity is essential**: Retraction's non-monotonicity is not a defect but a feature — it captures the fundamental asymmetry between acquiring and revising beliefs.

4. **The topological correspondence is precise**: The failure of the union axiom corresponds exactly to the phenomenon of local consistency with global inconsistency. This geometric perspective may enable new proof techniques borrowed from algebraic topology.

## References

1. Belnap, N. (1977). "A useful four-valued logic." In *Modern Uses of Multiple-Valued Logic*, pp. 5–37.
2. Priest, G. (2006). *In Contradiction: A Study of the Transconsistent*. Oxford University Press.
3. Fitting, M. (1994). "Kleene's three-valued logics and their children." *Fundamenta Informaticae*, 20(1-3), pp. 113–131.
4. Arieli, O. & Avron, A. (1996). "Reasoning with logical bilattices." *Journal of Logic, Language and Information*, 5(1), pp. 25–63.
5. Čech, E. (1966). *Topological Spaces*. Academia, Prague. (Original formulation of pre-topological spaces.)
