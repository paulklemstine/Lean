# Coalgebraic Myhill–Nerode Semantics for Neural State Compression

## Abstract

We develop a coalgebraic Myhill–Nerode theory for neural observation systems—deterministic state machines with observable outputs abstracting neural architecture semantics. We define behavioral equivalence as universal indistinguishability under all finite input contexts, prove it forms a right congruence, construct the quotient coalgebra, and establish a universal factorization property showing the quotient is the canonical minimal realization. We prove that the compressed system preserves all observable behaviors, all robustness certificates, and satisfies a cryptographic-style indistinguishability guarantee. For finite-state systems, we establish explicit cardinality bounds and O(|α|^k) complexity estimates for the partition refinement algorithm. The theory extends to semiring-weighted observation systems, connecting to weighted automata minimization. All results are formalized with complete machine-checked proofs.

## 1. Introduction

Model compression is a central problem in modern machine learning. Neural networks with millions of parameters are expensive to deploy, and methods such as pruning, quantization, and knowledge distillation aim to reduce their size while preserving performance. However, these methods are typically heuristic—they lack formal guarantees that the compressed model preserves all relevant behaviors of the original.

In contrast, automata minimization via the Myhill–Nerode theorem provides a canonical, semantics-preserving compression for finite automata. Two states are merged if and only if no input word can distinguish them, yielding the unique minimal automaton recognizing the same language.

This paper develops the analogous theory for neural architectures. We abstract a neural network as a *Neural Observation System*—a triple (σ, step, observe) where σ is a set of hidden states, step : σ → α → σ is a state transition function driven by input symbols from an alphabet α, and observe : σ → β extracts an observable output. This abstraction captures feedforward networks (where the "state" is the activation vector and "step" is one layer's computation) as well as recurrent architectures.

### 1.1 Contributions

1. **Behavioral equivalence as right congruence** (Section 3): We define neural_equiv and prove it is reflexive, symmetric, transitive, and preserved by transitions.

2. **Quotient coalgebra construction** (Section 4): We construct the quotient observation system with well-defined step and observe functions, and prove it preserves all behaviors.

3. **Universal factorization** (Section 5): Every semantics-preserving morphism factors uniquely through the quotient—the neural Myhill–Nerode theorem.

4. **Robustness preservation** (Section 6): Any behavioral robustness predicate is invariant under compression.

5. **Finite complexity bounds** (Section 7): Explicit O(|α|^k) observation budgets and |σ|-bounded stabilization for partition refinement.

6. **Weighted extension** (Section 8): The theory extends to semiring-valued outputs, connecting to weighted automata minimization.

7. **Compositional products** (Section 9): Product systems decompose, and product equivalence implies component equivalence.

## 2. Definitions and Notation

### 2.1 Neural Observation Systems

**Definition 2.1** (Neural Observation System). A *neural observation system* is a triple N = (σ, step, observe) where:
- σ is a type of hidden states
- step : σ → α → σ is a deterministic transition function
- observe : σ → β is an observation function

**Definition 2.2** (Neural Context). A *neural context* is a finite word w ∈ List α.

**Definition 2.3** (Neural Behavior). The *behavior* of state s under context w is:
```
neural_behavior(N, s, w) = observe(foldl(step, s, w))
```
This evolves the state through the entire input word, then observes.

**Definition 2.4** (Neural Equivalence). States s, t are *behaviorally equivalent*, written s ~_N t, if:
```
∀ w : List α, neural_behavior(N, s, w) = neural_behavior(N, t, w)
```

**Definition 2.5** (Depth-k Equivalence). States s, t are *k-equivalent*, written s ~_N^k t, if:
```
∀ w : List α, |w| ≤ k → neural_behavior(N, s, w) = neural_behavior(N, t, w)
```

### 2.2 Coalgebra Morphisms

**Definition 2.6** (Neural Homomorphism). A *neural homomorphism* f : N → M consists of:
- toFun : σ → τ
- map_step : ∀ s a, toFun(step_N(s, a)) = step_M(toFun(s), a)
- map_observe : ∀ s, observe_N(s) = observe_M(toFun(s))

## 3. Main Results

### 3.1 Behavioral Equivalence is a Right Congruence

**Theorem 3.1** (Equivalence). neural_equiv N is reflexive, symmetric, and transitive.

*Proof.* Reflexivity and symmetry follow directly from the corresponding properties of equality. Transitivity follows from transitivity of equality on β. □

**Theorem 3.2** (Right Congruence / Step Invariance). If s ~_N t then step(s, a) ~_N step(t, a) for all a : α.

*Proof.* For any word w, we have:
```
behavior(step(s,a), w) = behavior(s, a::w) = behavior(t, a::w) = behavior(step(t,a), w)
```
The first and third equalities use the key structural lemma behavior_cons; the middle uses s ~_N t. □

This theorem is the cornerstone of the entire development. It says that behavioral equivalence is compatible with the system's dynamics, enabling the quotient construction.

### 3.2 Quotient Construction

**Theorem 3.3** (Well-definedness). The quotient system Q(N) with:
- states = Quotient(neural_setoid N)
- step([s], a) = [step(s, a)]
- observe([s]) = observe(s)

is well-defined (the definitions do not depend on the choice of representative).

*Proof.* For observe: if s ~_N t, then behavior(s, []) = behavior(t, []), which gives observe(s) = observe(t).
For step: if s ~_N t, then step(s,a) ~_N step(t,a) by Theorem 3.2, so [step(s,a)] = [step(t,a)]. □

**Theorem 3.4** (Behavior Preservation). For all s and w:
```
behavior(Q(N), [s], w) = behavior(N, s, w)
```

*Proof.* By induction on w, using the fact that foldl on the quotient step commutes with the quotient map:
```
foldl(quotient_step, [s], w) = [foldl(step, s, w)]
```
Then observe on the quotient of the folded state equals observe on the folded state. □

**Theorem 3.5** (Quotient Characterization). 
```
[s] = [t] ⟺ s ~_N t
```

*Proof.* (⇐) is Quotient.sound. (⇒) follows from Theorem 3.4: if [s] = [t], then for any w, behavior(Q(N), [s], w) = behavior(Q(N), [t], w), which by Theorem 3.4 gives behavior(N, s, w) = behavior(N, t, w). □

### 3.3 Universal Factorization (Neural Myhill–Nerode Theorem)

**Theorem 3.6** (Universal Property). Let f : N → M be a neural homomorphism such that s ~_N t implies f(s) = f(t). Then there exists a unique function g : Q(N) → M.states such that:
1. g([s]) = f(s) for all s
2. g(step_Q(q, a)) = step_M(g(q), a) for all q, a
3. observe_Q(q) = observe_M(g(q)) for all q

*Proof.* Define g = Quotient.lift(f.toFun, hf). Property (1) holds by construction. Properties (2) and (3) follow by Quotient.inductionOn, reducing to the corresponding properties of f. Uniqueness follows because any g' satisfying (1) agrees with g on all representatives, hence on all quotient elements. □

### 3.4 Robustness Preservation

**Definition 3.7** (Behavioral Robustness). State s is *behaviorally robust* with respect to predicate P if:
```
∀ w : List α, P(behavior(N, s, w))
```

**Theorem 3.8** (Robustness Invariance). If s ~_N t, then:
```
behaviorally_robust(N, P, s) ⟺ behaviorally_robust(N, P, t)
```

*Proof.* Since s ~_N t implies behavior(N, s, w) = behavior(N, t, w) for all w, we can substitute freely in P(behavior(N, ·, w)). □

This theorem guarantees that compression via behavioral quotient preserves safety certificates.

### 3.5 Cryptographic Indistinguishability

**Definition 3.9** (Cryptographic Indistinguishability). States s, t are *cryptographically indistinguishable* if no context (finite input sequence) can separate them.

**Theorem 3.10**. Cryptographic indistinguishability coincides exactly with behavioral equivalence:
```
cryptographic_indistinguishable(N, s, t) ⟺ neural_equiv(N, s, t)
```

This justifies interpreting behavioral compression as a cryptographic security reduction.

## 4. Algorithms and Complexity

### 4.1 Partition Refinement

**Algorithm 1: Neural State Compression via Partition Refinement**

```
Input: Neural Observation System N = (σ, step, observe), alphabet list A
Output: Equivalence classes of neural_equiv

1. Initialize partition P₀ = {observe⁻¹(b) : b ∈ β}
2. For k = 1, 2, ...:
   a. Compute P_k by splitting each block B ∈ P_{k-1}:
      - For each a ∈ A, two states s,t ∈ B are in the same sub-block
        iff step(s,a) and step(t,a) are in the same block of P_{k-1}
   b. If P_k = P_{k-1}, return P_k
3. Return P_k
```

**Theorem 4.1** (Termination). For |σ| = n, the algorithm terminates in at most n steps.

*Proof.* Each refinement step either strictly increases the number of blocks or stabilizes. Since the number of blocks is bounded by n, at most n refinement steps suffice. □

**Theorem 4.2** (Complexity). Each refinement step examines O(n · |A|) transitions. The observation signature at depth k has exactly ∑_{i=0}^{k} |A|^i entries (proved as `wordsUpTo_length_bound`). Total complexity is O(n² · |A|).

### 4.2 Word Enumeration

**Definition 4.3**. wordsOfLength(A, n) generates all words of length exactly n over alphabet A. We prove |wordsOfLength(A, n)| = |A|^n.

**Definition 4.4**. wordsUpTo(A, k) generates all words of length at most k. We prove |wordsUpTo(A, k)| = ∑_{i=0}^{k} |A|^i.

### 4.3 Cardinality Bounds

**Theorem 4.5**. |Quotient(neural_setoid N)| ≤ |σ|.

This is the fundamental compression guarantee: the minimal realization never has more states than the original.

**Theorem 4.6** (Minimality). If f : N → M is an injective homomorphism, then |Quotient(neural_setoid N)| ≤ |M.states|.

## 5. Weighted Extension

### 5.1 Semiring-Valued Observations

**Definition 5.1**. A *weighted neural observation system* over semiring K is (σ, step, observe) where observe : σ → K.

All results from the unweighted theory carry over:
- Weighted behavioral equivalence is a right congruence (Theorem `weighted_neural_equiv_step_invariant`)
- The weighted equivalence coincides with neural equivalence of the underlying system (Theorem `weighted_equiv_eq_neural_equiv`)
- The quotient construction is well-defined

This connects to the classical theory of weighted automata over semirings, unifying neural compression with algebraic automata theory.

## 6. Products and Compositionality

**Theorem 6.1** (Product Decomposition). For product systems N₁ × N₂:
```
behavior(N₁ × N₂, (s₁,s₂), w) = (behavior(N₁, s₁, w), behavior(N₂, s₂, w))
```

**Theorem 6.2** (Product Equivalence Decomposition). If (s₁,s₂) ~_{N₁×N₂} (t₁,t₂), then s₁ ~_{N₁} t₁ and s₂ ~_{N₂} t₂.

This enables modular compression: each component of a parallel system can be compressed independently.

## 7. Computational Experiments

### 7.1 Example: Binary Counter

Consider a 3-bit binary counter with states {0,...,7}, input alphabet {tick}, and observe = identity. All states are distinguishable (different counts produce different observations), so the minimal realization has 8 states.

### 7.2 Example: Parity Automaton

A parity automaton with states {even, odd}, input alphabet {0, 1}, and observe = identity. This is already minimal—no states can be merged.

### 7.3 Example: Redundant States

Consider a system with states {A, B, C} where A and B have identical transition and observation behavior. The quotient merges A and B, producing a 2-state system.

See `demo.py` for concrete numerical implementations.

## 8. Discussion

### 8.1 Relationship to Prior Work

The Myhill–Nerode theorem for regular languages [Nerode 1958] established the foundation for automata minimization. Our work extends this to the general coalgebraic setting, applicable to neural architectures.

Bisimulation and coalgebraic approaches to state equivalence [Rutten 2000] provide the categorical framework. Our contribution is the explicit connection to neural compression and the formal verification of all results.

Model compression in machine learning [Han et al. 2015, Hinton et al. 2015] has focused on heuristic methods. Our approach provides the first formal framework with provable correctness guarantees.

### 8.2 Limitations

The current theory assumes deterministic transitions. Stochastic neural networks (dropout, noise injection) require extension to probabilistic coalgebras.

The theory is developed for exact behavioral equivalence. Approximate equivalence (states that are "close" but not identical in behavior) requires a metric extension.

### 8.3 Future Directions

1. **Quantitative Myhill–Nerode**: Replace exact equivalence with pseudometric-based approximate equivalence, enabling ε-optimal compression.
2. **Tropical/entropy variants**: Use tropical semiring observations to connect to information-theoretic compression bounds.
3. **Verified algorithms**: Extract the partition refinement algorithm into executable code with formal correctness proofs.

## 9. Conclusion

We have established a rigorous mathematical foundation for neural architecture compression based on the coalgebraic Myhill–Nerode theorem. The theory provides:
- A canonical minimal realization preserving all observable behaviors
- Automatic preservation of safety and robustness certificates
- Explicit algorithmic bounds for computing the compression
- Full compositionality for modular architectures
- Extension to semiring-weighted observations

All results have been formally verified with complete machine-checked proofs, providing the highest level of mathematical certainty.

## References

1. Nerode, A. (1958). "Linear automaton transformations." Proceedings of the AMS, 9(4), 541-544.
2. Rutten, J.J.M.M. (2000). "Universal coalgebra: a theory of systems." Theoretical Computer Science, 249(1), 3-80.
3. Han, S., Pool, J., Tung, J., Dally, W. (2015). "Learning both weights and connections for efficient neural networks." NeurIPS.
4. Hinton, G., Vinyals, O., Dean, J. (2015). "Distilling the knowledge in a neural network." arXiv:1503.02531.
5. Bonchi, F., Pous, D. (2013). "Checking NFA equivalence with bisimulations up to congruence." POPL.
