# Future Directions: State Compression via Semiconjugacy

This document outlines concrete next steps opened by the formalization of periodic orbit compression under semiconjugacy of finite dynamical systems.

---

## 1. Eventual-Period Preservation for Pre-Periodic Points

**Hypothesis**: If `x` is pre-periodic under `f` (i.e., `f^[k](x)` is periodic for some `k > 0` but `x` itself is not periodic), and `e` semiconjugates `f` to `g`, then `e(x)` is pre-periodic under `g` with pre-period at most `k` and eventual period dividing the eventual period of `x`.

**Proof Strategy**: Extend `semiconj_periodic_dvd` by applying it to the iterate `f^[k](x)`, which is periodic. The semiconjugacy iterate lemma gives `e(f^[k](x)) = g^[k](e(x))`, reducing the problem to the periodic case for the tail orbit.

**Impact**: This would complete the classification of orbit types under compression: fixed points, periodic orbits, and pre-periodic tails are all systematically preserved with quantitative bounds. It is the natural completion of the period-compression theory.

**Cross-Domain**: In recurrent neural networks, pre-periodic behavior corresponds to transient dynamics before the network settles into a memory loop. Formalizing this would give verified bounds on how long transient behavior can last in the compressed model.

---

## 2. Entropy-Style Lower Bounds from Cycle Structure

**Hypothesis**: Let `C(f)` be the number of distinct periodic orbits of `f` on a finite type `α`. If `e : α → β` surjectively semiconjugates `f` to `g`, then `C(g) ≤ C(f)`. Moreover, if `f` has orbits of lengths `n₁, n₂, ..., n_k` whose images under `e` remain distinct orbits of the same lengths, then `card(β) ≥ n₁ + n₂ + ... + n_k`.

**Proof Strategy**: Use `surjective_semiconj_periodicPts_image` to show periodic orbits map surjectively onto periodic orbits. Count orbits by partitioning `periodicPts` into equivalence classes under the orbit relation. The cardinality bound follows from the fact that distinct orbits contribute disjoint subsets of `β`.

**Impact**: This gives a combinatorial information-theoretic lower bound on latent space size: the more complex the cycle structure, the larger the latent space must be. This is a step toward a topological entropy bound for finite-state compression.

**Cross-Domain**: Connects to symbolic dynamics (entropy of subshifts), automata minimization (Myhill-Nerode theory), and information-theoretic capacity bounds in representation learning.

---

## 3. Categorical Quotient Dynamics for Learned Encoders

**Hypothesis**: The category of finite dynamical systems with semiconjugacies as morphisms admits a well-defined quotient construction: given `f : α → α` and a surjection `e : α → β` satisfying `FiberInvariant f e`, there exists a unique `g : β → β` such that `e` semiconjugates `f` to `g`.

**Proof Strategy**: Define `g(y) = e(f(x))` for any `x` with `e(x) = y`; fiber invariance ensures this is well-defined. Prove uniqueness from surjectivity. Then show this quotient is functorial: composing two fiber-invariant quotients yields a fiber-invariant quotient.

**Impact**: This provides the categorical foundation for multi-level compression: an encoder can be decomposed as a chain of successively coarser quotients, each preserving periodic structure. It is the mathematical framework for hierarchical representation learning.

**Cross-Domain**: Connects to categorical dynamics (Leinster's work on entropy of functors), algebraic topology (quotient spaces and covering maps), and multi-scale model reduction in engineering.

---

## 4. Algebraic Circuit Lower Bounds for Exact Latent Simulators

**Hypothesis**: If a Boolean/arithmetic circuit of depth `d` computes both the encoder `e : {0,1}^n → {0,1}^m` and the latent update `g : {0,1}^m → {0,1}^m` such that `e ∘ f = g ∘ e` for a given `f` with a cycle of length `2^k`, then `d ≥ k` or the circuit size is at least `2^k`.

**Proof Strategy**: Unroll the semiconjugacy for `2^k` steps. The composed circuit `e ∘ f^[2^k]` must be the identity on the orbit, while `g^[2^k]` must also be the identity. Use degree-based or gate-count lower bounds from algebraic circuit complexity (e.g., `depth_lower_bound_from_degree` style arguments) to show that representing a permutation of order `2^k` requires sufficient circuit resources.

**Impact**: This is the bridge between dynamical state compression and circuit complexity. It would show that preserving high-period cycles under compression is computationally expensive, giving formal lower bounds on the resources needed for compressed neural simulation.

**Cross-Domain**: Connects to circuit complexity (Strassen, Valiant), algebraic complexity of permutation groups, and hardware-aware neural architecture search.

---

## 5. Verified Abstraction-Refinement for Quantized RNNs

**Hypothesis**: Given a quantized RNN with state space `S = Fin N` and transition function `T`, and a candidate encoder `e : Fin N → Fin M` (with `M < N`), one can algorithmically verify whether `e` admits a semiconjugacy `U` and, if so, compute `U` and certify that all safety/liveness properties verified on `(Fin M, U)` transfer to `(Fin N, T)`.

**Proof Strategy**: 
1. Check fiber invariance: for each pair `(x, y)` with `e(x) = e(y)`, verify `e(T(x)) = e(T(y))`.
2. If fiber-invariant, define `U(z) = e(T(x))` for any `x` with `e(x) = z`.
3. Use `periodic_lift_of_surjective_semiconj` to certify that periodic orbits in the abstraction lift to genuine periodic orbits.
4. For safety (invariant sets): if `S ⊆ Fin M` is `U`-invariant, then `e⁻¹(S)` is `T`-invariant.

**Impact**: This is a complete, mechanically verified abstraction-refinement pipeline for finite-state neural networks. It transforms the theoretical results into a practical verification tool.

**Cross-Domain**: Connects to model checking (CEGAR), formal methods for neural networks (Marabou, α-β-CROWN), and certified AI safety.

---

## Implementation Priority

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|--------------|
| 1. Pre-periodic preservation | Low | Medium | Direct extension of current work |
| 2. Entropy lower bounds | Medium | High | Orbit counting infrastructure |
| 3. Categorical quotients | Medium | High | Fiber invariance, category theory |
| 4. Circuit lower bounds | High | Very High | Algebraic complexity foundations |
| 5. Verified abstraction-refinement | Medium | Very High | Algorithm formalization |

Directions 1 and 5 are the most immediately actionable. Direction 4 represents the deepest theoretical advance but requires substantial algebraic complexity infrastructure. Direction 3 provides the cleanest mathematical framework for the entire program.
