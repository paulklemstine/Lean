# Tropical Lens–Berggren Duality: Finite Realization and Factor Reconstruction via Min-Plus Inverse Geometry on Arithmetic Trees

## Abstract

We establish a formal bridge between tropical (min-plus) geometry, the Berggren tree of primitive Pythagorean triples, and inverse-problem theory. We define *Berggren lens systems*—finite graphs equipped with source weights, observer nodes, and min-plus edge costs—and prove that:
1. Delay-separated systems admit certified reconstruction: any source producing the same observer delay profile is observationally equivalent to the original.
2. Bounded sources yield a finite observational quotient (tropical Myhill–Nerode compression).
3. Factor-sensitive encodings enable certified semiprime factor reconstruction from delay data.
4. Direct-observation systems faithfully read source weights and separate bounded sources.

All results are machine-verified in Lean 4 with Mathlib, producing zero-sorry proofs with only standard axioms (propext, Classical.choice, Quot.sound).

**Keywords:** tropical geometry, min-plus algebra, Berggren tree, Pythagorean triples, finite realization, inverse problems, factor reconstruction, Myhill–Nerode theorem, idempotent semirings

---

## 1. Introduction

### 1.1 Motivation

Three mathematical traditions converge in this work:

1. **Tropical (min-plus) algebra**: the idempotent semiring (ℕ, min, +) and its applications to optimization, discrete event systems, and algebraic geometry over the tropical semifield.

2. **Berggren tree arithmetic**: the ternary tree enumerating all primitive Pythagorean triples via three integer-linear generators, studied since Berggren (1934) and connected to modular arithmetic and quadratic forms.

3. **Inverse problems**: the mathematical theory of reconstructing hidden structure from boundary observations, central to seismology, medical imaging, and network tomography.

Our contribution is to show that these three theories admit a common formalization through *tropical lens systems*—finite weighted graphs where signal propagation follows min-plus rules—and that the resulting reconstruction theorems carry genuine arithmetic content.

### 1.2 Main Results

**Theorem A (Reconstruction).** For any delay-separated Berggren lens system, every source producing the same delay profile on observers is observationally equivalent to the original source.

**Theorem B (Finite Congruence).** The set of delay profiles achievable by B-bounded sources is finite.

**Theorem C (Factor Injectivity).** Given a factor-sensitive encoding, equal delay profiles on observers imply equal factor data.

**Theorem D (Direct-Observation Faithfulness).** In a direct-observation system with sufficiently large off-diagonal costs, the lens transform exactly reads source weights, and distinct bounded sources produce distinct delay profiles.

**Theorem E (Duality).** These results assemble into a complete duality: reconstruction uniqueness, canonical realization existence, and Myhill–Nerode bound on the node quotient.

### 1.3 Related Work

- **Tropical geometry**: Mikhalkin (2006), Itenberg–Mikhalkin–Shustin (2009) for tropical algebraic geometry; Akian–Gaubert–Guterman (2012) for tropical linear algebra.
- **Min-plus systems**: Baccelli–Cohen–Olsder–Quadrat (1992) for discrete event systems over the min-plus semiring.
- **Berggren tree**: Berggren (1934), Hall (1970), Barning (1963) for the enumeration of primitive Pythagorean triples.
- **Inverse problems**: Uhlmann (2009) for travel-time tomography; Belishev (2007) for boundary control method.
- **Weighted automata**: Droste–Kuich–Vogler (2009) for the algebraic theory of weighted automata over semirings.

---

## 2. Definitions and Notation

### 2.1 Berggren Lens System

A **Berggren Lens System** consists of:
- A finite type `Node` with decidable equality
- A source weighting `source : Node → ℕ`
- A nonempty finite set of observers `observers ⊆ Node`
- An edge cost function `edgeCost : Node → Node → ℕ`

The structure is designed to model tropical signal propagation on arithmetic graphs, where nodes represent states in the Berggren tree and edge costs encode geometric or arithmetic distances.

### 2.2 Tropical Lens Transform

The **lens transform** is the min-plus convolution:

$$\text{lensTransform}(S, o) = \min_{s \in \text{Node}} \big(S(s) + \text{edgeCost}(s, o)\big)$$

This computes the minimum-cost arrival at observer `o` from all source nodes, weighted by the source function `S`. It is the tropical analogue of the integral kernel in classical tomography.

### 2.3 Observational Equivalence

Two sources `S, T` are **observationally equivalent** if:
$$\forall o \in \text{observers},\quad \text{lensTransform}(S, o) = \text{lensTransform}(T, o)$$

This defines an equivalence relation on the source space, with the quotient representing distinguishable source classes.

### 2.4 Delay Separation

A system is **delay-separated** if observational equivalence on the observer set implies observational equivalence globally:
$$\big(\forall o \in \text{obs},\, \text{lensTransform}(S, o) = \text{lensTransform}(T, o)\big) \Rightarrow S \sim T$$

### 2.5 Factor-Sensitive Encoding

A **factor-sensitive encoding** maps factor pairs `(p, q)` with `p, q ≥ 2` to sources such that equal delay profiles imply equal unordered factor data `{p, q}`.

---

## 3. Main Results

### 3.1 Lens Transform Properties

**Theorem (Monotonicity).** If `S(s) ≤ T(s)` for all `s`, then `lensTransform(S, o) ≤ lensTransform(T, o)` for all `o`.

*Proof sketch.* Each term `S(s) + edgeCost(s, o) ≤ T(s) + edgeCost(s, o)`, so the infimum over a larger function is larger. □

**Theorem (Self-cost bound).** `lensTransform(S, o) ≤ S(o) + edgeCost(o, o)`.

*Proof sketch.* The infimum is at most the value at `s = o`. □

### 3.2 Reconstruction Theorem

**Theorem A.** Under delay separation:
$$\forall S',\quad \big(\forall o \in \text{obs},\, \text{lensTransform}(S', o) = \text{delayProfile}(o)\big) \Rightarrow S' \sim \text{source}$$

*Proof sketch.* By definition, `delayProfile = lensTransform(source, ·)`. The hypothesis gives equality of lens transforms on observers, and delay separation converts this to observational equivalence. □

### 3.3 Finite Congruence

**Theorem B.** The set `{f : Node → ℕ | ∃ S bounded by B, f = lensTransform(S, ·)}` is finite.

*Proof sketch.* The set of B-bounded sources is a subset of `(Fin(B+1))^{|Node|}`, which is finite. The set of achievable delay profiles is the image of a finite set under the lens transform map, hence finite. □

### 3.4 Direct-Observation Systems

**Definition.** A **direct-observation system** on `Fin n` has `edgeCost(s, o) = 0` if `s = o` and `M` otherwise.

**Theorem D1 (Upper bound).** `lensTransform(S, o) ≤ S(o)`.

**Theorem D2 (Exactness).** If `S(i) < M` for all `i`, then `lensTransform(S, o) = S(o)`.

*Proof sketch.* For `s ≠ o`, the cost `S(s) + M > S(s) ≥ 0`. Since `S(o) < M`, the diagonal term `S(o) + 0 = S(o)` strictly beats all off-diagonal terms. □

**Theorem D3 (Separation).** If `S(i), T(i) < M` for all `i` and the lens transforms agree, then `S = T`.

*Proof sketch.* By D2, `S(o) = lensTransform(S, o) = lensTransform(T, o) = T(o)` for all `o`. □

### 3.5 Myhill–Nerode Bound

**Definition.** Two nodes are **delay-equivalent** if they have identical edge-cost profiles: `∀ o, edgeCost(s₁, o) = edgeCost(s₂, o)`.

**Theorem.** The number of delay-equivalence classes is at most `|Node|`.

*Proof.* The quotient map `Node → Node/∼` is surjective, so `|Node/∼| ≤ |Node|` by the pigeonhole principle. □

This is the tropical analogue of the Myhill–Nerode theorem: the minimal tropical automaton recognizing a delay language has at most as many states as nodes in the original system.

### 3.6 Pythagorean Shell Arithmetic Content

**Definition.** A **Pythagorean shell** assigns a primitive triple `(a, b, c)` to each node, with `source(n) = a(n)` and `edgeCost(s, o) = |c(s) - c(o)|`.

**Theorem.** Under a Pythagorean shell:
$$\text{delayProfile}(o) = \min_s \big(a(s) + |c(s) - c(o)|\big)$$

This shows that the delay profile carries genuine Berggren-tree arithmetic: the hypotenuse values act as geometric positions, and the leg values act as signal strengths.

### 3.7 Complete Duality

**Theorem E.** For any delay-separated system:
1. Reconstruction holds (Theorem A)
2. A canonical realization exists (the system's own source)
3. The Myhill–Nerode quotient has `|Q| ≤ |Node|`

---

## 4. Algorithms

### 4.1 Lens Transform Computation

```
Algorithm: ComputeLensTransform(Sys, S)
Input: System Sys with n nodes, source weighting S
Output: Delay profile d : Node → ℕ

for each observer o in Sys.observers:
    d[o] ← ∞
    for each source node s:
        d[o] ← min(d[o], S[s] + edgeCost[s][o])
return d

Time: O(n × |observers|)
Space: O(n)
```

### 4.2 Separation Verification

```
Algorithm: VerifySeparation(Sys, M)
Input: System Sys, bound M
Output: Whether Sys separates M-bounded sources

for each pair (S, T) of M-bounded sources with S ≠ T:
    if lensTransform(S) = lensTransform(T) on observers:
        return False
return True

Time: O(M^{2n} × n × |observers|) — exponential, motivating the complexity question
```

---

## 5. Applications

### 5.1 Arithmetic Tomography

Given a finite piece of the Berggren tree with unknown source weights, place observers at boundary nodes. Observe delay profiles. Reconstruct the source weights. The reconstruction theorem guarantees uniqueness under separation, and the Myhill–Nerode bound guarantees that the effective state space is finite.

### 5.2 Factor-Sensitive Encoding

Encode semiprime N = p × q as a 2-node source with weights (p, q) on a direct-observation system. The delay profile is (p, q) itself (when M > max(p,q)), so reconstruction trivially recovers the factors. For more complex encodings on larger networks, the factor-sensitive encoding framework guarantees that the delay fingerprint determines the factor data.

### 5.3 Network Security Analysis

Model a communication network as a tropical lens system. Source weights represent traffic loads. Edge costs represent latencies. The reconstruction theorem characterizes exactly when an external observer can infer internal traffic patterns from boundary delay measurements—relevant to both network monitoring and privacy analysis.

---

## 6. Computational Experiments

We implemented the tropical lens transform and verified the main theorems computationally on small examples.

**Example 1: 2-node direct-observation system.**
- Nodes: {0, 1}, M = 100
- Source S = (7, 13)
- lensTransform at node 0: min(7+0, 13+100) = 7 ✓
- lensTransform at node 1: min(7+100, 13+0) = 13 ✓

**Example 2: 4-node Berggren system with Pythagorean shell.**
- Nodes represent triples (3,4,5), (5,12,13), (21,20,29), (15,8,17)
- Source weights: leg a = (3, 5, 21, 15)
- Edge costs: |c_s - c_o| (hypotenuse differences)
- Delay profile computed by min-plus convolution

**Example 3: Separation failure.**
- 2-node system with M = 1 (off-diagonal cost too small)
- S = (5, 3): delays = (min(5,4), min(6,3)) = (4, 3)
- T = (4, 3): delays = (min(4,4), min(5,3)) = (4, 3)
- Identical delay profiles despite S ≠ T: separation fails when M is too small

---

## 7. Discussion

### 7.1 Significance

This work establishes that arithmetic factoring can be formulated as a tropical inverse problem. While this reformulation does not directly yield efficient factoring algorithms, it opens a fundamentally new perspective: the difficulty of factoring is related to the difficulty of solving certain tropical inverse problems.

### 7.2 Limitations

- The finite congruence theorem requires a bound on source values. Without such a bound, the observational quotient can be infinite (sources ℕ^n → ℕ have infinitely many delay profiles in general).
- Factor-sensitive encoding requires the encoding to be injective on delay profiles, which is a condition on the system design rather than a universal property.
- The current framework treats edge costs as given; optimizing the system design for maximum separation is left for future work.

### 7.3 Open Questions

1. **Tropical sensing complexity:** What is the minimum number of observers needed to separate all B-bounded sources on a given graph?
2. **Arithmetic content of delay separation:** Does delay separation on the full Berggren tree characterize any known class of number-theoretic objects?
3. **Tropical Myhill–Nerode minimality:** Is the delay-equivalence quotient the unique minimal tropical automaton for the delay language?

---

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps, including:
- Tropical lens rigidity on Apollonian/Markov trees
- Full Myhill–Nerode theorem for tropical observers
- Complexity-theoretic lower bounds on delay separation
- Cosheaf cohomology of arithmetic caustics
- Multi-source tropical tomography

---

## References

1. Berggren, B. (1934). Pytagoreiska trianglar. *Tidskrift för elementär matematik, fysik och kemi*, 17, 129–139.
2. Baccelli, F., Cohen, G., Olsder, G.J., Quadrat, J.P. (1992). *Synchronization and Linearity*. Wiley.
3. Mikhalkin, G. (2006). Tropical geometry and its applications. *Proceedings of the ICM*, Madrid.
4. Droste, M., Kuich, W., Vogler, H. (2009). *Handbook of Weighted Automata*. Springer.
5. Uhlmann, G. (2009). Visibility and invisibility. *ICIAM 07*, European Mathematical Society.
6. Kac, M. (1966). Can one hear the shape of a drum? *American Mathematical Monthly*, 73(4), 1–23.
