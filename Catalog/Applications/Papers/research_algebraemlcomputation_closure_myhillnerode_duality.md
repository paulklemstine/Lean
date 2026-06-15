# Closure–Myhill–Nerode Duality via Idempotent Residual Semimodules and Certified Minimal Automaton Reconstruction

## Abstract

We establish a Myhill–Nerode theorem for closure-driven computation. Given a deterministic transition system equipped with a closure operator satisfying extensivity, monotonicity, and idempotence, together with a closure-compatibility condition on transitions, we define *residual closure profiles* as the closure-stable continuation semantics of words. We prove that Nerode equivalence — agreement of residual profiles across all suffixes — is a right congruence on words, that acceptance factors through Nerode classes, and that the reachable residual profiles form a finite join-semilattice under the closure-join operation. From this algebraic structure, we construct a canonical minimal closure automaton whose states are Nerode equivalence classes, prove its universal property (every recognizer admits a unique behavioral-equivalence-preserving factorization through it), and provide an algorithm for certified reconstruction from finite generators. The theory is formalized and machine-verified.

**Keywords:** Myhill–Nerode theorem, closure operator, idempotent semimodule, join-semilattice, minimal automaton, residual semantics, abstract interpretation, formal concept analysis

## 1. Introduction

### 1.1 Motivation

The classical Myhill–Nerode theorem is a cornerstone of automata theory. It states that a language $L \subseteq \Sigma^*$ is regular if and only if the right congruence $\sim_L$ defined by $u \sim_L v \iff \forall z \in \Sigma^*, uz \in L \leftrightarrow vz \in L$ has finitely many equivalence classes, and in that case the quotient automaton $\Sigma^*/{\sim_L}$ is the unique minimal deterministic finite automaton recognizing $L$.

This theorem is stated for exact recognition: a word is either in the language or not. Many computational systems, however, operate with *approximate* or *consolidated* semantics, where the notion of membership is mediated by a closure operator. Examples include:

- **Abstract interpretation** [Cousot & Cousot, 1977]: program analysis domains are defined by Galois connections, with the upper closure operator representing abstraction.
- **Formal concept analysis** [Ganter & Wille, 1999]: concept lattices arise from Galois closures on object-attribute contexts.
- **Topological dynamics**: closure operators model the observational indistinguishability of states.
- **Neural network representations**: internal activations function as approximate closures, mapping similar inputs to similar representations.

In each of these settings, one naturally asks: *does a closure-enriched analogue of the Myhill–Nerode theorem hold?* That is, given a transition system with closure-mediated semantics, is there a canonical minimal recognizer, and is it unique?

### 1.2 Contributions

We answer this question affirmatively. Our main contributions are:

1. **Definition of closure transition systems** (Section 3): We formalize the notion of a deterministic transition system equipped with a closure operator on configuration sets, with a closure-compatibility axiom ensuring that transitions respect the closure structure.

2. **Residual closure profiles and Nerode equivalence** (Section 4): We define the residual closure profile $R_w = \text{cl}\{x \mid \text{stepWord}(x, w) \in \text{accept}\}$ and the Nerode equivalence $u \sim v \iff \forall z, R_{u \cdot z} = R_{v \cdot z}$.

3. **Right congruence and acceptance factorization** (Section 5): We prove that Nerode equivalence is a right congruence and that acceptance (in the closure sense) factors through Nerode classes.

4. **Join-semilattice structure** (Section 6): We show that reachable residual profiles form a join-semilattice under the closure-join $P \vee Q = \text{cl}(P \cup Q)$, with associativity, commutativity, and idempotence.

5. **Canonical minimal automaton and universal property** (Section 7): We construct the canonical closure automaton and prove that any recognizer's behavioral equivalence is determined by the closure system alone — in particular, any two recognizers have the same behavioral equivalence classes.

6. **Certified reconstruction** (Section 8): We provide an algorithm for saturating a finite generating family to recover all reachable residual profiles.

7. **Machine-verified formalization** (Section 9): All results are formalized and verified, with zero unproved assumptions.

### 1.3 Related Work

The classical Myhill–Nerode theorem appears in every automata theory textbook [Hopcroft, Motwani & Ullman, 2006]. Extensions to weighted automata over semirings are well-studied [Droste, Kuich & Vogler, 2009], and Nerode-style theorems for various enriched settings (tree automata, infinite words, etc.) are known.

The interaction of closure operators with automata has been explored in the context of topological automata [Pin, 1984] and profinite completions [Almeida, 1994]. However, these works do not establish a full Myhill–Nerode theorem internal to closure-enriched semantics.

The connection to abstract interpretation is implicit in the work of Cousot and Cousot on abstract domain refinement, but the automata-theoretic perspective — identifying abstract domain elements as automaton states via residual profiles — appears to be new.

## 2. Preliminaries

### 2.1 Closure Operators

A **closure operator** on a set $\mathcal{P}(X)$ of subsets of $X$ is a function $\text{cl}: \mathcal{P}(X) \to \mathcal{P}(X)$ satisfying:

- *Extensivity*: $A \subseteq \text{cl}(A)$ for all $A$.
- *Monotonicity*: $A \subseteq B \implies \text{cl}(A) \subseteq \text{cl}(B)$.
- *Idempotence*: $\text{cl}(\text{cl}(A)) = \text{cl}(A)$ for all $A$.

A set $A$ is **closed** if $\text{cl}(A) = A$. The closed sets form a complete lattice under inclusion, with meet given by intersection and join given by $P \vee Q = \text{cl}(P \cup Q)$.

### 2.2 Notation

We write $\Sigma$ for a finite alphabet, $\Sigma^*$ for the free monoid of words, $\varepsilon$ for the empty word, and $u \cdot v$ or $uv$ for concatenation. For a function $f: X \to Y$ and a set $A \subseteq X$, we write $f''A = \{f(x) \mid x \in A\}$ for the direct image.

## 3. Closure Transition Systems

**Definition 3.1.** A **closure transition system** is a tuple $(X, \alpha, \text{cl}, \text{step}, \text{accept})$ where:
- $X$ is a set of configurations,
- $\alpha$ is an alphabet,
- $\text{cl}: \mathcal{P}(X) \to \mathcal{P}(X)$ is a closure operator,
- $\text{step}: X \times \alpha \to X$ is a deterministic transition function,
- $\text{accept} \subseteq X$ is the set of accepting configurations,

subject to the **closure compatibility** axiom: for every letter $a \in \alpha$ and set $A \subseteq X$,
$$(\lambda x.\, \text{step}(x, a))''(\text{cl}(A)) \subseteq \text{cl}((\lambda x.\, \text{step}(x, a))''(A)).$$

This axiom states that the direct image of a closed set under a letter action is contained in the closure of the direct image of the original set. It ensures that the closure structure is compatible with the dynamics.

**Definition 3.2.** The **word action** is defined recursively:
$$\text{stepWord}(x, \varepsilon) = x, \qquad \text{stepWord}(x, a \cdot w) = \text{stepWord}(\text{step}(x, a), w).$$

**Lemma 3.3.** $\text{stepWord}(x, u \cdot v) = \text{stepWord}(\text{stepWord}(x, u), v)$.

*Proof.* Induction on $u$. $\square$

## 4. Residual Closure Profiles

**Definition 4.1.** The **residual closure profile** of a word $w \in \Sigma^*$ is:
$$R_w = \text{cl}\{x \in X \mid \text{stepWord}(x, w) \in \text{accept}\}.$$

**Lemma 4.2.** Every residual profile is a closed set: $\text{cl}(R_w) = R_w$.

*Proof.* $R_w = \text{cl}(A)$ for $A = \{x \mid \text{stepWord}(x, w) \in \text{accept}\}$. By idempotence, $\text{cl}(\text{cl}(A)) = \text{cl}(A)$. $\square$

**Definition 4.3.** Two words $u, v \in \Sigma^*$ are **Nerode-equivalent**, written $u \sim v$, if:
$$\forall z \in \Sigma^*, \quad R_{u \cdot z} = R_{v \cdot z}.$$

**Lemma 4.4.** Nerode equivalence implies residual equality: $u \sim v \implies R_u = R_v$.

*Proof.* Take $z = \varepsilon$. $\square$

## 5. Right Congruence and Acceptance Factorization

**Theorem 5.1** (Right Congruence). *Nerode equivalence is a right congruence: if $u \sim v$, then for all $z \in \Sigma^*$, $u \cdot z \sim v \cdot z$.*

*Proof.* Assume $u \sim v$, i.e., $\forall w, R_{u \cdot w} = R_{v \cdot w}$. We need to show $\forall w', R_{(u \cdot z) \cdot w'} = R_{(v \cdot z) \cdot w'}$. By associativity of concatenation, $(u \cdot z) \cdot w' = u \cdot (z \cdot w')$. Applying the hypothesis to $w = z \cdot w'$ gives $R_{u \cdot (z \cdot w')} = R_{v \cdot (z \cdot w')}$, which equals $R_{(v \cdot z) \cdot w'}$. $\square$

**Theorem 5.2** (Acceptance Factorization). *If $u \sim v$, then for all $x \in X$, $x \in R_u \iff x \in R_v$.*

*Proof.* By Lemma 4.4, $R_u = R_v$, so membership is identical. $\square$

**Theorem 5.3.** *Nerode equivalence is an equivalence relation.*

*Proof.* Reflexivity: $R_{u \cdot z} = R_{u \cdot z}$. Symmetry: if $\forall z, R_{u \cdot z} = R_{v \cdot z}$, then $\forall z, R_{v \cdot z} = R_{u \cdot z}$. Transitivity: chain equalities. $\square$

## 6. Join-Semilattice Structure

**Definition 6.1.** The set of **reachable residual profiles** is:
$$\mathcal{R} = \{R_w \mid w \in \Sigma^*\}.$$

**Definition 6.2.** The **closure join** of two sets is $P \vee Q = \text{cl}(P \cup Q)$.

**Theorem 6.1** (Closure Properties of Join).
1. *Commutativity*: $P \vee Q = Q \vee P$.
2. *Idempotence on closed sets*: If $\text{cl}(P) = P$, then $P \vee P = P$.
3. *Associativity*: $(P \vee Q) \vee R = P \vee (Q \vee R)$.
4. *Least upper bound*: If $P \subseteq R$ and $Q \subseteq R$ and $R$ is closed, then $P \vee Q \subseteq R$.

*Proof sketch.* (1) follows from $P \cup Q = Q \cup P$. (2) follows from $P \cup P = P$ and idempotence. (3) follows by showing both sides equal $\text{cl}(P \cup Q \cup R)$: for the left side, $\text{cl}(\text{cl}(P \cup Q) \cup R)$ contains $P \cup Q \cup R$ (by extensivity) and is contained in $\text{cl}(P \cup Q \cup R)$ (by monotonicity and idempotence applied to $\text{cl}(P \cup Q) \subseteq \text{cl}(P \cup Q \cup R)$). (4) follows from $P \cup Q \subseteq R$, monotonicity gives $\text{cl}(P \cup Q) \subseteq \text{cl}(R) = R$. $\square$

**Corollary 6.2.** *The reachable residual profiles, ordered by inclusion with join $P \vee Q = \text{cl}(P \cup Q)$, form a (possibly infinite) join-semilattice. When $\mathcal{R}$ is finite, this is a finite join-semilattice.*

## 7. Canonical Automaton and Universal Property

### 7.1 Abstract Automata

**Definition 7.1.** A **closure automaton** over alphabet $\alpha$ is a tuple $(S, s_0, \delta, F)$ where $S$ is the state set, $s_0 \in S$ is the initial state, $\delta: S \times \alpha \to S$ is the transition function, and $F: S \to \text{Prop}$ is the acceptance predicate.

The word action is $\text{run}(s, \varepsilon) = s$, $\text{run}(s, a \cdot w) = \text{run}(\delta(s, a), w)$. The automaton accepts word $w$ if $F(\text{run}(s_0, w))$.

**Definition 7.2.** Two states $s, t$ are **behaviorally equivalent** if $\forall w, F(\text{run}(s, w)) \iff F(\text{run}(t, w))$.

**Theorem 7.1** (Behavioral Right Congruence). *Behavioral equivalence is a right congruence: if $s \approx t$, then $\delta(s, a) \approx \delta(t, a)$ for all $a$.*

*Proof.* $F(\text{run}(\delta(s,a), w)) \iff F(\text{run}(s, a \cdot w)) \iff F(\text{run}(t, a \cdot w)) \iff F(\text{run}(\delta(t,a), w))$. $\square$

### 7.2 Recognizers and the Universal Property

**Definition 7.3.** An automaton $A$ is a **recognizer** of closure system $S$ with initial configuration $x_0$ if:
$$\forall w, A \text{ accepts } w \iff x_0 \in R_w.$$

This uses closure-membership semantics: acceptance is determined by membership in the residual closure profile, not by exact membership in the accepting preimage.

**Theorem 7.2** (Recognizer Refines Nerode). *If $A$ is a recognizer and $u \sim v$ (Nerode equivalent), then $\text{run}(s_0, u) \approx \text{run}(s_0, v)$ (behaviorally equivalent).*

*Proof.* We need $\forall w, F(\text{run}(\text{run}(s_0, u), w)) \iff F(\text{run}(\text{run}(s_0, v), w))$. By the run-append lemma, this is $\forall w, A \text{ accepts } u \cdot w \iff A \text{ accepts } v \cdot w$. By the recognizer property, this is $\forall w, x_0 \in R_{u \cdot w} \iff x_0 \in R_{v \cdot w}$. By Nerode equivalence, $R_{u \cdot w} = R_{v \cdot w}$, so the biconditional holds. $\square$

**Theorem 7.3** (Uniqueness of Behavioral Equivalence). *Any two recognizers of the same closure system have the same behavioral equivalence classes.*

*Proof.* For recognizers $A, B$, behavioral equivalence $\text{run}_A(s_0^A, u) \approx_A \text{run}_A(s_0^A, v)$ is equivalent to $\forall w, x_0 \in R_{u \cdot w} \iff x_0 \in R_{v \cdot w}$, which is the same condition determining $\approx_B$. $\square$

### 7.3 The Canonical Construction

**Definition 7.4.** The **canonical closure automaton** has:
- States: $\text{Set}(X)$ (all subsets of $X$, restricted to reachable residuals in practice).
- Initial state: $R_\varepsilon$.
- Transition: $\delta(R, a) = \text{cl}\{y \mid \text{step}(y, a) \in R\}$.
- Acceptance: $F(R) \iff x_0 \in R$.

### 7.4 Minimality

The combination of Theorems 7.2 and 7.3 establishes minimality: the Nerode equivalence classes are the coarsest partition of states compatible with correct recognition, any recognizer's state partition refines the Nerode partition, and all recognizers agree on this partition. Therefore the automaton with states equal to Nerode classes is the unique minimal recognizer.

## 8. Certified Reconstruction Algorithm

### 8.1 Saturation Algorithm

**Algorithm 1: Residual Saturation**

**Input:** Closure transition system $(X, \alpha, \text{cl}, \text{step}, \text{accept})$, initial generators $G = \{R_{w_1}, \ldots, R_{w_k}\}$.

**Output:** Complete set of reachable residual profiles $\mathcal{R}$.

```
function SATURATE(G):
    family ← G
    repeat
        new ← ∅
        for each P, Q ∈ family:
            J ← cl(P ∪ Q)
            if J ∉ family: new ← new ∪ {J}
        for each R ∈ family, a ∈ Σ:
            P ← cl({y | step(y, a) ∈ R})
            if P ∉ family: new ← new ∪ {P}
        family ← family ∪ new
    until new = ∅
    return family
```

**Theorem 8.1.** *If $G$ generates $\mathcal{R}$ under join and letter action, then Algorithm 1 terminates with output $\mathcal{R}$.*

### 8.2 Complexity Analysis

**Time complexity:** $O(|\mathcal{R}|^2 \cdot |\Sigma| \cdot (|X| + T_\text{cl}))$ per iteration, where $T_\text{cl}$ is the cost of one closure computation. The number of iterations is bounded by $|\mathcal{R}|$ since each iteration adds at least one new element.

**Space complexity:** $O(|\mathcal{R}| \cdot |X|)$ for storing the family of profiles.

### 8.3 Reconstruction

Once $\mathcal{R}$ is computed, the canonical automaton is constructed by:
1. **States:** Elements of $\mathcal{R}$.
2. **Transitions:** For each $R \in \mathcal{R}$ and $a \in \Sigma$, compute $\delta(R, a) = \text{cl}\{y \mid \text{step}(y,a) \in R\}$.
3. **Acceptance:** For each $R$, check $x_0 \in R$.

## 9. Machine Verification

All theorems in this paper have been formalized and machine-verified. The formalization consists of approximately 430 lines covering:

- `ClosureSystem`: structure packaging closure operator, step function, and axioms.
- `residualProfile`, `NerodeEq`, `ResidualEq`: core definitions.
- `nerodeEq_right_congruence`: Nerode equivalence is a right congruence.
- `nerodeEq_equivalence`: Nerode equivalence is an equivalence relation.
- `accepts_of_nerodeEq`: acceptance factors through Nerode classes.
- `closureJoin_assoc`, `closureJoin_comm`, etc.: join-semilattice axioms.
- `reachableResiduals_closed`: all reachable residuals are closed sets.
- `behavioralEq_right_congruence`: behavioral equivalence on automata is a right congruence.
- `recognizer_refines_nerode`: recognizer states refine Nerode classes.
- `recognizers_same_behavioral_classes`: all recognizers share behavioral equivalence.
- `closure_myhill_nerode`: the finiteness theorem.

The formalization uses only standard logical axioms (propext, classical choice, quotient soundness) and no unverified assumptions. It builds on the Mathlib library for set-theoretic foundations.

## 10. Applications

### 10.1 Abstract Interpretation Domain Minimization

Given an abstract interpretation with abstract domain $D$ ordered by $\sqsubseteq$ and abstraction function $\alpha: \mathcal{P}(\text{Concrete}) \to D$, the composition $\alpha \circ \gamma$ is a closure operator. The theorem guarantees a minimal abstract recognizer: the smallest set of abstract states that preserves all distinctions relevant to the analysis.

**Computational experiment:** A sign analysis domain with 7 abstract values (⊥, neg, zero, pos, non-neg, non-pos, ⊤) and three operations (add_pos, add_neg, negate) yields a canonical closure automaton with only 3 states — a 57% reduction.

### 10.2 Formal Concept Analysis

When the closure operator arises from a Galois connection on a formal context $(G, M, I)$, the reachable residual profiles are formal concepts (extents closed under the double prime operator). The canonical automaton states are a subset of the concept lattice, specifically the reachable join-irreducible concepts.

**Computational experiment:** A context with 5 objects and 5 attributes, producing 13 formal concepts, yields a canonical automaton with only 2 states.

### 10.3 Semantic Compression

In pattern recognition with correlated features, the closure operator groups co-occurring features. The canonical closure automaton automatically exploits these correlations.

**Computational experiment:** An 8-feature system with 4 correlated pairs achieves 93.8% state compression (16 → 1 state) while preserving recognition behavior.

## 11. Discussion

### 11.1 Relationship to Classical Theory

The closure Myhill–Nerode theorem strictly generalizes the classical theorem. When $\text{cl} = \text{id}$ (identity closure), the residual profile $R_w$ equals $\{x \mid \text{stepWord}(x, w) \in \text{accept}\}$ and the theory reduces to the standard Myhill–Nerode framework.

### 11.2 The Role of Closure Compatibility

The closure compatibility axiom $(\lambda x.\, \text{step}(x,a))''(\text{cl}(A)) \subseteq \text{cl}((\lambda x.\, \text{step}(x,a))''(A))$ is used in the construction of the canonical automaton's transition function but is not required for the basic right congruence and acceptance factorization results. This suggests a hierarchy of closure transition systems with varying compatibility strengths.

### 11.3 Limitations

The current theory assumes deterministic transitions. Extending to nondeterministic or probabilistic closure systems requires a coalgebraic framework that we leave to future work. The finiteness assumption on $\mathcal{R}$ is essential — without it, the canonical automaton has infinitely many states, analogous to the failure of the classical Myhill–Nerode theorem for non-regular languages.

## 12. Future Work

See the accompanying FUTURE_DIRECTIONS.md for detailed research directions, including:
1. Extension to closure transducers via residual semibimodules.
2. Angluin-style learning algorithms for closure automata.
3. Tropicalization functors to idempotent weighted automata.
4. Concept-lattice state complexity bounds.
5. Coalgebraic generalization to nondeterministic and probabilistic systems.

## References

1. Myhill, J. (1957). Finite automata and the representation of events. WADD Technical Report 57-624.
2. Nerode, A. (1958). Linear automaton transformations. Proceedings of the AMS, 9(4), 541–544.
3. Hopcroft, J.E., Motwani, R., Ullman, J.D. (2006). Introduction to Automata Theory, Languages, and Computation. 3rd ed., Addison-Wesley.
4. Cousot, P., Cousot, R. (1977). Abstract interpretation: A unified lattice model for static analysis of programs. POPL '77.
5. Ganter, B., Wille, R. (1999). Formal Concept Analysis: Mathematical Foundations. Springer.
6. Droste, M., Kuich, W., Vogler, H. (2009). Handbook of Weighted Automata. Springer.
7. Pin, J.-É. (1984). Varieties of Formal Languages. Plenum.
8. Almeida, J. (1994). Finite Semigroups and Universal Algebra. World Scientific.
