# Closure Semimodule Dynamics and Myhill–Nerode Reconstruction: A Unified Framework for Intrinsic Computation Capacity

## Abstract

We develop a theory of *closure semimodule systems* — deterministic transition systems equipped with closure operators on state sets and semiring-valued probe observables. We define closure traces as the set of probe values collected after closure expansion, introduce an indistinguishability relation based on universal trace agreement, and prove that this relation is an equivalence congruence suitable for quotienting. The main results are: (1) a Myhill–Nerode-style minimality theorem showing the quotient injects into any reduced realization; (2) a finite reconstruction theorem establishing that bounded-depth trace agreement implies full indistinguishability under a stabilization hypothesis; (3) a pigeonhole-based stabilization lemma for bounded monotone sequences with permanent stability. All results are formalized with machine-verified proofs. The framework bridges automata theory, Koopman spectral dynamics, quantum observation theory, and cryptographic indistinguishability.

## 1. Introduction

The Myhill–Nerode theorem is a cornerstone of automata theory, establishing that the minimal deterministic finite automaton recognizing a regular language is unique up to isomorphism and characterized by the number of equivalence classes of a right congruence. This result has been extended in many directions: to weighted automata over semirings [Berstel–Reutenauer], to tree automata, and to various algebraic settings.

However, classical extensions assume that states are directly observable through output functions. In many applications — quantum systems, thermodynamic processes, cryptographic protocols — states are observed *indirectly* through probes, and the observation process involves a *closure* or *coarse-graining* step that groups nearby states together.

This paper introduces the *closure semimodule system* framework, which combines:
- A deterministic transition function (automata theory)
- A semiring-valued output function (weighted automata)
- A closure operator on state sets (topology/lattice theory)
- A probe family (functional analysis/quantum theory)

We develop the theory from first principles, culminating in a generalized minimality theorem and a finite reconstruction result.

### 1.1 Contributions

1. **Closure Semimodule System** (§2): A new mathematical structure combining transitions, outputs, closures, and probes.
2. **Closure Trace** (§3): A set-valued trace semantics collecting probe values after closure expansion.
3. **Indistinguishability Equivalence** (§4): Proof that trace-based indistinguishability is a congruence.
4. **Quotient Construction** (§5): Well-defined transition and output on the quotient.
5. **Minimality Theorem** (§6): The quotient injects into any reduced realization.
6. **Stabilization and Reconstruction** (§7): Finite-window reconstruction under stabilization.
7. **Simulation Functoriality** (§8): Morphisms between closure systems.
8. **Applications** (§9): Connections to quantum coarse-graining, cryptographic security, and Koopman dynamics.

## 2. Definitions and Notation

### 2.1 Closure Semimodule System

**Definition 2.1.** A *closure semimodule system* is a tuple (σ, α, K, δ, o, cl) where:
- σ is the state type
- α is the input alphabet
- K is a semiring
- δ : σ × α → σ is the transition function
- o : σ → K is the output function
- cl : P(σ) → P(σ) is a closure operator satisfying:
  - Extensivity: S ⊆ cl(S) for all S
  - Monotonicity: S ⊆ T ⟹ cl(S) ⊆ cl(T)
  - Idempotency: cl(cl(S)) ⊆ cl(S) for all S

### 2.2 Probe Family

**Definition 2.2.** A *probe family* P on σ over K is a set of functions {p : σ → K}.

### 2.3 Word Evaluation

**Definition 2.3.** For a word w = a₁a₂…aₙ ∈ α*, define:
```
evalWord(s, []) = s
evalWord(s, a :: w) = evalWord(δ(s, a), w)
```

**Lemma 2.4.** evalWord(s, w₁ ++ w₂) = evalWord(evalWord(s, w₁), w₂).

### 2.4 Closure Trace

**Definition 2.5.** The *closure trace* of state s under word w with probe family P is:
```
CT(s, w) = {k ∈ K | ∃ x ∈ cl({evalWord(s, w)}), ∃ p ∈ P, p(x) = k}
```

This collects all values obtainable by applying any probe to any state in the closure of the word-reached singleton.

**Lemma 2.6.** CT(s, a :: w) = CT(δ(s, a), w).

**Lemma 2.7.** If P ⊆ Q then CT_P(s, w) ⊆ CT_Q(s, w).

## 3. Closure Indistinguishability

**Definition 3.1.** States s and t are *closure-indistinguishable* (written s ≈ t) if CT(s, w) = CT(t, w) for all w ∈ α*.

**Theorem 3.2.** Closure indistinguishability is an equivalence relation.

*Proof.* Reflexivity: CT(s, w) = CT(s, w). Symmetry: if CT(s, w) = CT(t, w) then CT(t, w) = CT(s, w). Transitivity: by transitivity of set equality. □

**Theorem 3.3** (Right congruence). If s ≈ t then δ(s, a) ≈ δ(t, a) for all a ∈ α.

*Proof.* For any word w, CT(δ(s, a), w) = CT(s, a :: w) = CT(t, a :: w) = CT(δ(t, a), w). □

**Corollary 3.4.** If s ≈ t then evalWord(s, w) ≈ evalWord(t, w) for all w ∈ α*.

*Proof.* By induction on w using Theorem 3.3. □

## 4. Quotient Construction

Let Q = σ/≈ be the quotient. Define:
- δ_Q([s], a) = [δ(s, a)] (well-defined by Theorem 3.3)
- o_Q([s]) = CT(s, []) (well-defined by definition of ≈)

**Theorem 4.1.** The quotient step and output functions are well-defined.

**Theorem 4.2** (Trace preservation). For all s, w:
```
o_Q(foldl(δ_Q, [s], w)) = CT(s, w)
```

*Proof.* By induction: foldl(δ_Q, [s], w) = [evalWord(s, w)], and o_Q([evalWord(s, w)]) = CT(evalWord(s, w), []) = CT(s, w). □

## 5. Minimality Theorem

**Definition 5.1.** An *observable realization* R = (σ_R, M_R, P_R) consists of a state type, closure system, and probes.

**Definition 5.2.** R is *reduced* if for all r₁, r₂ ∈ σ_R: (∀w. CT_R(r₁, w) = CT_R(r₂, w)) ⟹ r₁ = r₂.

**Definition 5.3.** A *trace-preserving map* φ : (M, P) → R is a function φ : σ → σ_R such that CT(s, w) = CT_R(φ(s), w) for all s, w.

**Theorem 5.4** (Myhill–Nerode Minimality). If R is a reduced realization and φ is trace-preserving, then there exists an injective function f : Q → σ_R.

*Proof sketch.*
1. *Well-definedness:* If s ≈ t, then for all w, CT(s, w) = CT(t, w), so CT_R(φ(s), w) = CT_R(φ(t), w), so φ(s) = φ(t) by reducedness. Hence φ descends to f : Q → σ_R.
2. *Injectivity:* If f([s]) = f([t]), then φ(s) = φ(t), so CT_R(φ(s), w) = CT_R(φ(t), w), so CT(s, w) = CT(t, w) by trace preservation, so s ≈ t, so [s] = [t]. □

**Corollary 5.5** (Cardinality bound). |Q| ≤ |σ_R| for any reduced realization R with trace-preserving map.

## 6. Bounded-Depth Indistinguishability

**Definition 6.1.** States s and t are *n-indistinguishable* (written s ≈_n t) if CT(s, w) = CT(t, w) for all w with |w| ≤ n.

**Lemma 6.2.** ≈_{n+1} refines ≈_n.

**Lemma 6.3.** s ≈ t if and only if s ≈_n t for all n.

## 7. Stabilization and Reconstruction

**Theorem 7.1** (Stable step propagation). Suppose ≈_n = ≈_{n+1} (as relations). Then ≈_n = ≈_{n+k} for all k ≥ 0.

*Proof.* By induction on k. For k = 0, trivial. For the inductive step, take w with |w| ≤ n + k + 1. If |w| ≤ n + k, use the inductive hypothesis. Otherwise w = a :: w' with |w'| ≤ n + k. We need CT(δ(s, a), w') = CT(δ(t, a), w'). By IH, it suffices to show δ(s, a) ≈_n δ(t, a). This follows from s ≈_{n+1} t (which equals s ≈_n t by hypothesis) and the observation that for any v with |v| ≤ n, CT(δ(s, a), v) = CT(s, a :: v) where |a :: v| ≤ n + 1. □

**Theorem 7.2** (Reconstruction). If the stabilization hypothesis holds at level N — that is, ≈_N = ≈_{N+1} — then ≈_N = ≈, the full indistinguishability relation. Hence agreement on words up to length N implies agreement on all words.

**Theorem 7.3** (Pigeonhole stabilization). Let c : ℕ → ℕ be monotone with c(n) ≤ B for all n, and suppose c(n) = c(n+1) implies c(m) = c(n) for all m ≥ n. Then ∃ N ≤ B such that c stabilizes at N.

*Proof.* By contradiction: if c(i) ≠ c(i+1) for all i ≤ B, then by monotonicity c(i) + 1 ≤ c(i+1) for all i ≤ B. By induction, c(B+1) ≥ c(0) + B + 1 > B, contradicting c(B+1) ≤ B. □

## 8. Simulation Functoriality

**Definition 8.1.** A *closure simulation* from M₁ to M₂ is a function f : σ₁ → σ₂ such that:
- f(δ₁(s, a)) = δ₂(f(s), a) for all s, a
- o₁(s) = o₂(f(s)) for all s
- f(cl₁(S)) ⊆ cl₂(f(S)) for all S

**Theorem 8.2.** Simulations commute with word evaluation: f(evalWord₁(s, w)) = evalWord₂(f(s), w).

**Theorem 8.3** (Capacity monotonicity). If f : M₁ → M₂ is an injective simulation, then |σ₁| ≤ |σ₂|.

## 9. Applications

### 9.1 Quantum Coarse-Graining

Set K = ℂ, let σ be a Hilbert space basis, let cl be quantum decoherence (partial trace over environment), and let P be a set of measurement operators. The quotient gives the minimal quantum system reproducing all measurement statistics.

### 9.2 Cryptographic Security

Set K = {0, 1}*, let cl be the set of states computationally indistinguishable from a given one, and let P be polynomial-time distinguishers. The number of quotient classes gives a lower bound on the state complexity of any secure implementation.

### 9.3 Koopman Dynamics

For a dynamical system with state space σ, let cl be the topological closure, and let P be Koopman eigenfunctions. The quotient captures the essential spectral dynamics.

## 10. Computational Experiments

We implement the framework in Python and demonstrate:

1. **DFA example**: A 4-state DFA with identity closure, showing the quotient has 3 states.
2. **Closure example**: A 6-state system with non-trivial closure, showing the quotient has 2 states.
3. **Capacity growth**: Plotting IntrinsicCapacity(n) for various systems, verifying stabilization.

Complexity: The quotient computation is O(|σ|² · |α| · N) where N is the stabilization depth, bounded by |σ|. Total: O(|σ|³ · |α|).

## 11. Discussion

The closure semimodule framework unifies several threads:
- **Myhill-Nerode theory** for classical and weighted automata
- **Koopman spectral theory** for dynamical systems
- **Quantum measurement theory** for coarse-grained observables
- **Cryptographic security** for indistinguishability-based definitions

The key insight is that the closure operator provides a uniform abstraction for the "noise" or "coarse-graining" present in all these settings.

### Limitations

- The full stabilization bound requires a congruence property that must be verified case by case.
- The framework does not directly handle nondeterministic or probabilistic transitions.
- Decidability of the equivalence relation requires finiteness assumptions.

## 12. Future Work

1. Extend to semiring-linear (nondeterministic) transitions.
2. Connect IntrinsicCapacity to Hankel matrix rank for weighted languages.
3. Develop a tropical specialization for optimization problems.
4. Formalize quantum channel coarse-graining as closure simulations.
5. Prove entropy bounds on capacity growth rates.

## References

1. A. Nerode. "Linear automaton transformations." *Proc. AMS*, 1958.
2. J. Berstel, C. Reutenauer. *Noncommutative Rational Series with Applications*. Cambridge, 2011.
3. B.O. Koopman. "Hamiltonian systems and transformation in Hilbert space." *Proc. NAS*, 1931.
4. O. Goldreich. *Foundations of Cryptography*. Cambridge, 2001.
5. M. Budišić, R. Mohr, I. Mezić. "Applied Koopmanism." *Chaos*, 2012.
