# Future Directions: Semiring-Relative Mathematical Reality

## Overview

The theorems proved in this cycle — the Alien Shadow Theorem, Support Invariance, and the Counting Obstruction — establish the formal nucleus of semiring-relative foundations. Each direction below is a concrete research project with specific hypotheses, proof strategies, and cross-domain applications.

---

## Direction 1: Multivariate Support-Shadow Theorem

### Hypothesis
For multivariate polynomial expressions over `MvPolynomial σ ℕ`, evaluation in an idempotent commutative semiring depends only on the support set of the polynomial (the set of multi-indices with nonzero coefficients), not on the coefficient values.

### Proof Strategy
1. Generalize `evalListSemiring` to multivariate lists: `List (σ →₀ ℕ)` where each entry is a multi-index.
2. Prove the multi-index version of `evalListSemiring_cons_mem` using the same idempotence argument.
3. Establish the dedup theorem for multi-index lists.
4. Connect to Mathlib's `MvPolynomial.eval` and show that the tropicalization of `MvPolynomial σ ℕ` factors through the support map `MvPolynomial.support`.

### Cross-Domain Connections
- **Tropical geometry**: This would formalize the algebraic content of the tropicalization map for hypersurfaces.
- **Algebraic statistics**: Multivariate polynomial supports define toric models; idempotent collapse maps these to their combinatorial type.
- **Optimization**: Multivariate tropical polynomials encode multi-objective optimization; support invariance shows that only the Pareto frontier structure matters.

### Difficulty: Medium
The core argument generalizes straightforwardly; the main challenge is interfacing with Mathlib's `MvPolynomial` API.

---

## Direction 2: Weighted Automata Semiring-Invariance Classification

### Hypothesis
For weighted finite automata, there exists a precise classification of automaton properties into three tiers:
1. **Support-level** properties (decidable in all semirings): reachability, language support, state accessibility.
2. **Multiplicity-level** properties (decidable only in non-idempotent semirings): path counting, ambiguity degree, expected weight.
3. **Interference-level** properties (decidable only in rings with subtraction): cancellation detection, signed weight computation.

### Proof Strategy
1. Define weighted automata as `Finset State × (State → Char → State → α) × Finset State` over a generic semiring `α`.
2. Prove that support-level properties are invariant under the "idempotent projection" (replacing the semiring with its Boolean shadow).
3. Exhibit concrete automata separating each tier.
4. Formalize the Mohri-Riley semiring abstraction hierarchy.

### Cross-Domain Connections
- **Natural language processing**: Weighted transducers in speech recognition; understanding which properties of the language model survive approximation.
- **Verification**: Model checking over different semiring abstractions.
- **Quantum computing**: Quantum automata over ℂ vs tropical automata — interference vs optimization.

### Difficulty: High
Requires significant formalization of automata theory in Lean.

---

## Direction 3: Tropical Shadow Functor

### Hypothesis
There exists a functor `Trop : CommSemiringCat → IdemCommSemiringCat` that sends each commutative semiring to its "idempotent quotient" (collapsing `a + a` to `a`), and polynomial identities that hold in the image are exactly those in the combinatorial core.

### Proof Strategy
1. Define the idempotent quotient construction: for a commutative semiring `α`, form `α / ∼` where `a ∼ b` iff `a` and `b` agree after idempotent collapse.
2. Show this quotient is functorial: semiring homomorphisms descend to the quotient.
3. Prove that the kernel of the quotient map is exactly the "multiplicity information" — the equivalence classes are support orbits.
4. Characterize the image: which idempotent semirings arise as quotients of classical ones.

### Cross-Domain Connections
- **Category theory**: This is a left adjoint to the inclusion `IdemCommSemiringCat ↪ CommSemiringCat`.
- **Algebraic K-theory**: The passage from a ring to its idempotent completion has analogies with K₀.
- **Topos theory**: Different semirings as different "arithmetic toposes" — the functor mediates between mathematical universes.

### Difficulty: High
Requires category-theoretic formalization and quotient construction.

---

## Direction 4: Quantitative Multiplicity Recovery

### Hypothesis
Given "noisy tropical" evaluation (evaluation in a semiring that is "approximately idempotent"), there exist information-theoretic bounds on how much multiplicity information can be recovered.

### Proof Strategy
1. Define a parameterized family of semirings interpolating between ℕ and the tropical semiring (e.g., using softmax: `a ⊕_β b = (1/β) log(exp(βa) + exp(βb))` which converges to max as β → ∞).
2. For finite polynomial expressions, compute the mutual information between coefficients and evaluation as a function of the temperature parameter β.
3. Prove that as β → ∞, mutual information drops to the support entropy (number of bits needed to encode which monomials are present).
4. Give explicit convergence rates.

### Cross-Domain Connections
- **Statistical mechanics**: The β parameter is inverse temperature; this is the partition function → free energy transition.
- **Machine learning**: Log-sum-exp pooling vs max pooling in neural networks — our theorem explains when they differ.
- **Information theory**: Rate-distortion theory for algebraic structures.
- **Compressed sensing**: Support recovery from linear measurements is the continuous analogue.

### Difficulty: Medium-High
Combines analysis (convergence rates) with algebra (semiring interpolation).

---

## Direction 5: Proof-Theoretic Semantics of Semiring Change

### Hypothesis
The passage from a classical semiring to an idempotent one corresponds, in proof theory, to collapsing *contraction* — the structural rule that allows using a hypothesis multiple times. In an idempotent proof system, using a lemma twice is the same as using it once.

### Proof Strategy
1. Define a simple proof system where "evidence" for a proposition is accumulated in a semiring.
2. In the classical (ℕ) system, k independent proofs of P give evidence "k" for P.
3. In the idempotent system, k independent proofs give evidence "1" for P.
4. Prove that the set of *provable* propositions is the same (both systems prove the same things), but the *evidence structure* differs.
5. Show that the evidence quotient map is exactly the tropical shadow map.

### Cross-Domain Connections
- **Linear logic**: Idempotent collapse corresponds to the passage from linear to classical logic (where contraction is free).
- **Homotopy type theory**: Proof irrelevance / truncation levels — "being a proposition" (at most one proof) vs "being a set" (proofs carry data).
- **Program verification**: Counting vs reachability in program analysis is the computational version.

### Difficulty: Medium
The proof-theoretic formalization is straightforward; the deep insight is connecting it to the algebraic theorems.

---

## Meta-Direction: Semiring-Indexed Theorem Universes

### Vision
Build a database of mathematical theorems tagged with their *semiring prerequisites* — the minimal assumptions on the additive structure needed for the theorem to hold. This would create a machine-searchable atlas of mathematical reality indexed by algebraic substrate.

### Concrete Steps
1. For each theorem in a target fragment of Mathlib, determine whether it uses cancellation, counting, or idempotence.
2. Classify into: universal (all semirings), classical-only (requires non-idempotent), tropical-only (requires idempotent), or specific (requires particular semiring).
3. Build a dependency graph showing how semiring requirements propagate through proof chains.
4. Identify "bottleneck theorems" where a single semiring-specific step forces the entire proof chain to be substrate-dependent.

### Impact
This would be the first *formal taxonomy of mathematics by algebraic substrate*, directly realizing the "alien mathematics" vision at scale.

---

## Research Team Directives

Each direction should be pursued by a team of 2-3 researchers with the following roles:
- **Formalizer**: Writes and maintains the Lean proofs.
- **Mathematician**: Develops the theory and identifies the right abstractions.
- **Application specialist**: Connects the formal results to the target domain.

### Iteration Protocol
1. **Hypothesis formulation**: State the conjecture precisely in natural language.
2. **Lean skeleton**: Write the statement in Lean with `sorry`.
3. **Verification**: Check edge cases with `#eval` and small examples.
4. **Proof attempt**: Use the theorem proving infrastructure to fill sorries.
5. **Failure analysis**: If the proof fails, determine whether the statement is false (find counterexample) or the proof strategy needs revision.
6. **Documentation**: Update the knowledge base with results, both positive and negative.
7. **Cross-pollination**: Check whether results in one direction unlock progress in others.

### Priority Order
1. Direction 1 (multivariate) — most natural extension, validates the framework.
2. Direction 5 (proof-theoretic) — deepest philosophical payoff.
3. Direction 4 (quantitative recovery) — most practical applications.
4. Direction 2 (weighted automata) — largest formal infrastructure requirement.
5. Direction 3 (functor) — most abstract, highest ceiling.
