# Tropical Proof Complexity: An Algebraic Framework for Interactive Proof Composition

## Abstract

We establish a rigorous mathematical framework connecting interactive proof system composition with tropical (min-plus) algebra. The central construction maps proof system soundness error ε to tropical cost −log(ε), under which parallel repetition becomes tropical scalar multiplication and strategy selection becomes tropical addition (minimum). We prove that the *Tropical Complexity Profile ratio* (TCP ratio) — defined as communication cost per unit of tropical security — is invariant under parallel repetition, establishing it as a fundamental complexity measure. We demonstrate that linear tropical barriers persist under composition, that amplification and detection are dual operations in the tropical semiring, and that detection probabilities are bounded below by their continuous tropical approximations. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords:** tropical algebra, min-plus semiring, proof complexity, interactive proofs, soundness amplification, parallel repetition, complexity barriers

---

## 1. Introduction

Interactive proof systems are a cornerstone of modern theoretical computer science, with applications ranging from cryptographic protocols to verified computation. A fundamental operation is *amplification*: reducing the soundness error of a proof system by independent repetition. If a proof system has soundness error ε ∈ (0,1), then k-fold parallel repetition achieves error ε^k — exponential decay in the number of rounds.

This exponential-to-linear phenomenon is precisely the domain of tropical (min-plus) algebra. The tropical semiring (ℝ ∪ {∞}, min, +) replaces ordinary addition with minimum and ordinary multiplication with addition. Under the logarithmic map, multiplicative structures become additive, and exponential decay becomes linear growth.

We exploit this observation to develop a systematic algebraic framework for proof system composition. Our contributions:

1. **Tropical Cost Function.** We define tropCost(P) = −log(ε_P), mapping proof system specifications to the tropical semiring. This converts the multiplicative error structure to additive tropical structure.

2. **TCP Ratio Invariance.** We define the Tropical Complexity Profile ratio as cost/tropCost and prove it is invariant under parallel repetition — a new complexity-theoretic invariant.

3. **Barrier Persistence.** We formalize tropical barriers as minimum cost-per-security thresholds and prove they persist under all compositions.

4. **Amplification-Detection Duality.** We prove that soundness amplification (ε → ε^k) and corruption detection (p → 1−(1−p)^k) are complementary operations summing to 1 when p = 1−ε.

5. **Detection Lower Bound.** We establish that detection probabilities always exceed their continuous tropical approximations: 1−(1−p)^k ≥ 1−e^{−kp}.

---

## 2. Definitions

### 2.1 Proof System Specification

**Definition 2.1 (ProofSpec).** A *proof system specification* is a triple P = (ε, c) where:
- ε ∈ (0,1) is the *soundness error* (probability of accepting an invalid proof),
- c ≥ 0 is the *communication cost* (total bits exchanged or computation performed).

### 2.2 Tropical Cost

**Definition 2.2 (Tropical Cost).** For a proof system P with error ε, the *tropical cost* is:

    tropCost(P) = −log(ε)

This is always positive since ε ∈ (0,1) implies log(ε) < 0.

The tropical cost measures the *security level* of the proof system on a linear scale. Higher tropical cost corresponds to stronger security (lower error probability).

### 2.3 TCP Ratio

**Definition 2.3 (Tropical Complexity Profile Ratio).** The *TCP ratio* of a proof system P is:

    tcpRatio(P) = cost(P) / tropCost(P)

This measures the communication cost per unit of tropical security — the "price of trust."

### 2.4 Parallel Repetition

**Definition 2.4 (Parallel Repetition).** The *k-fold parallel repetition* of P, denoted parRep(P, k), has:
- Error: ε^k (independent trials)
- Cost: k · c (additive accumulation)

### 2.5 Tropical Barrier

**Definition 2.5 (Tropical Barrier).** A *tropical barrier* B = (τ, f) consists of:
- A threshold τ > 0
- A monotone, non-negative cost function f : ℝ → ℝ

A proof system P *respects* barrier B if f(tropCost(P)) ≤ cost(P).

### 2.6 Detection Probability

**Definition 2.6 (Detection Probability).** The *detection probability* after k independent checks, each with per-check detection probability p, is:

    detectionProb(p, k) = 1 − (1 − p)^k

---

## 3. Main Results

### 3.1 Tropical Scaling Theorem

**Theorem 3.1.** *For any proof system P and positive integer k:*

    tropCost(parRep(P, k)) = k · tropCost(P)

*Proof sketch.* By definition, tropCost(parRep(P,k)) = −log(ε^k) = −k·log(ε) = k·(−log(ε)) = k·tropCost(P). The key step uses the logarithm power rule: log(x^k) = k·log(x). □

**Significance.** This theorem is the fundamental bridge between proof theory and tropical algebra. It states that parallel repetition is *tropical scalar multiplication*: the multiplicative operation of exponentiating error maps to the linear operation of scaling tropical cost.

### 3.2 TCP Invariance

**Theorem 3.2.** *For any proof system P and positive integer k:*

    tcpRatio(parRep(P, k)) = tcpRatio(P)

*Proof sketch.* tcpRatio(parRep(P,k)) = (k·c)/(k·tropCost(P)) = c/tropCost(P) = tcpRatio(P). The factors of k cancel. □

**Significance.** The TCP ratio is a *fundamental invariant* of proof systems under repetition. It captures the inherent efficiency of the protocol design, independent of the amplification level. This makes it a natural complexity measure: two proof systems with different TCP ratios are fundamentally different, regardless of how many rounds each runs.

### 3.3 Monotonicity

**Theorem 3.3.** *For any proof system P and positive integers k₁ ≤ k₂:*

    tropCost(parRep(P, k₁)) ≤ tropCost(parRep(P, k₂))

*Proof sketch.* By Theorem 3.1, this reduces to k₁·tropCost(P) ≤ k₂·tropCost(P), which follows from k₁ ≤ k₂ and tropCost(P) > 0. □

### 3.4 Independent Composition

**Theorem 3.4.** *For independent proof systems P, Q:*

    −log(ε_P · ε_Q) = tropCost(P) + tropCost(Q)

*Proof sketch.* Uses log(xy) = log(x) + log(y) and negation distributes over addition. □

**Significance.** Independent parallel composition of *different* proof systems corresponds to tropical cost addition — the tropical multiplication operation. Combined with Theorem 3.1, this shows that the set of achievable tropical costs forms a tropical module.

### 3.5 Selection as Tropical Order

**Theorem 3.5.** *If P.error ≤ Q.error, then tropCost(Q) ≤ tropCost(P).*

*Proof sketch.* The logarithm is monotone increasing on positive reals, so ε_P ≤ ε_Q implies log(ε_P) ≤ log(ε_Q), hence −log(ε_Q) ≤ −log(ε_P). □

**Significance.** Choosing the best proof strategy (lowest error) corresponds to selecting the maximum tropical cost. This is the tropical "minimum" operation in the min-plus convention on costs.

### 3.6 Error-Cost Tradeoff

**Theorem 3.6.** *To achieve target tropical cost T via repetition, the required number of rounds satisfies:*

    k ≥ T / tropCost(P)

*Proof sketch.* From T ≤ tropCost(parRep(P,k)) = k·tropCost(P) and tropCost(P) > 0, divide both sides. □

### 3.7 Amplification-Detection Duality

**Theorem 3.7.** *For any proof system P and positive integer k, with detection probability p = 1 − ε:*

    parRep(P, k).error + detectionProb(1 − P.error, k) = 1

*Proof sketch.* parRep(P,k).error = ε^k and detectionProb(1−ε, k) = 1 − (1−(1−ε))^k = 1 − ε^k. Their sum is ε^k + 1 − ε^k = 1. □

**Significance.** This duality reveals that amplification and detection are two sides of the same coin. The probability mass that leaves the "error" region after amplification is exactly the probability mass that enters the "detection" region. Both processes are governed by the same exponential base ε, hence the same tropical cost.

### 3.8 Detection Lower Bound

**Theorem 3.8.** *For p ∈ (0,1) and positive integer k:*

    1 − e^{−kp} ≤ detectionProb(p, k) = 1 − (1−p)^k

*Proof sketch.* Equivalent to (1−p)^k ≤ e^{−kp}. This follows from the fundamental inequality 1−x ≤ e^{−x} (applied with x = p), raised to the k-th power: (1−p)^k ≤ (e^{−p})^k = e^{−kp}. □

**Significance.** This connects discrete detection (k independent checks) with continuous tropical approximation (exponential decay). The tropical framework gives conservative bounds: tropical predictions are always at least as pessimistic as reality.

### 3.9 Barrier Persistence

**Theorem 3.9.** *If α · tropCost(P) ≤ cost(P) for some α ≥ 0, then for all k ≥ 1:*

    α · tropCost(parRep(P, k)) ≤ cost(parRep(P, k))

*Proof sketch.* The left side equals α · k · tropCost(P) = k · (α · tropCost(P)) ≤ k · cost(P) = cost(parRep(P,k)). □

**Significance.** Linear tropical barriers cannot be circumvented by repetition. If a proof system requires at least α units of communication per unit of tropical security, every amplified version preserves this ratio. Breaking a barrier requires a fundamentally new protocol with a lower TCP ratio.

### 3.10 Tropical Ray Structure

**Theorem 3.10.** *For a proof system P with positive cost and positive integers k₁, k₂:*

    tropCost(parRep(P,k₂)) / tropCost(parRep(P,k₁)) = cost(parRep(P,k₂)) / cost(parRep(P,k₁))

*Proof sketch.* Both ratios equal k₂/k₁ after cancellation of tropCost(P) > 0 and cost(P) > 0. □

**Significance.** The set of achievable (tropCost, cost) pairs lies on a ray through the origin. This geometric structure means the tropical cost-efficiency frontier is one-dimensional for any fixed proof system.

### 3.11 TCP Ratio Unboundedness

**Theorem 3.11.** *For any C > 0, there exist proof systems P, Q with tcpRatio(P)/tcpRatio(Q) > C.*

*Proof sketch.* Take P and Q with the same error (e.g., 1/2) but different costs. Since TCP ratio is proportional to cost when error is fixed, the ratio of TCP ratios equals the ratio of costs, which can be made arbitrarily large. □

**Significance.** There is no universal bound on TCP ratio. Proof systems can be arbitrarily efficient or inefficient, and the TCP ratio captures this full range.

---

## 4. Algorithms

### 4.1 TCP Ratio Computation

```
Algorithm: ComputeTCPRatio(error, cost)
Input: error ε ∈ (0,1), cost c ≥ 0
Output: TCP ratio c / (-log ε)
1. Compute T ← -log(ε)
2. Return c / T
```

### 4.2 Optimal Repetition Count

```
Algorithm: OptimalRepetition(error, cost, target_error)
Input: base error ε, cost c, target error δ
Output: minimum rounds k, total cost
1. T_base ← -log(ε)
2. T_target ← -log(δ)
3. k ← ⌈T_target / T_base⌉
4. Return (k, k · c)
```

### 4.3 Barrier Verification

```
Algorithm: VerifyBarrier(systems, α)
Input: list of proof systems, barrier coefficient α
Output: boolean (all systems respect barrier?)
1. For each system (ε, c):
   a. T ← -log(ε)
   b. If c < α · T: return False
2. Return True
```

---

## 5. Discussion

### 5.1 Relation to Existing Work

The connection between proof system amplification and logarithmic measures has been implicit in the interactive proof literature since the foundational work of Goldwasser, Micali, and Rackoff (1985). However, the systematic algebraic framework — particularly the TCP ratio invariance and barrier persistence — appears to be new.

The tropical perspective connects naturally to the hardness-versus-randomness paradigm, where tropical matrix operations govern circuit complexity bounds. The detection lower bound (Theorem 3.8) is closely related to the coupon collector's problem and birthday bounds in cryptography.

### 5.2 Limitations

Our framework models independent parallel repetition, which is the simplest amplification strategy. Sequential amplification, where later rounds depend on earlier outcomes, introduces dependencies that break the clean tropical structure. Extending the framework to adaptive strategies is an important open direction.

The TCP ratio is invariant under repetition but not under all transformations. Protocol transformations that change the error/cost tradeoff (e.g., batching, recursive composition) can change the TCP ratio. Understanding which transformations preserve or improve the TCP ratio is a natural follow-up question.

### 5.3 Connections to Other Domains

The tropical semiring appears in diverse mathematical contexts:
- **Optimization:** Shortest path algorithms are tropical matrix-vector products.
- **Algebraic geometry:** Tropical varieties are combinatorial shadows of algebraic varieties.
- **Physics:** Free energy computations in statistical mechanics use the tropical (zero-temperature) limit.
- **Machine learning:** Log-sum-exp operations in softmax layers approach tropical operations as temperature → 0.

Our framework suggests that each of these domains may have analogues of the TCP ratio and barrier persistence. For instance, in network optimization, the TCP ratio would measure the efficiency of a routing protocol in terms of path cost per unit of reliability.

---

## 6. Future Work

1. **Tropical Proof Complexity Classes.** Define complexity classes based on TCP ratio bounds and study their relationship to standard classes (IP, AM, MA).

2. **Categorical Structure.** The composition operations on proof systems (parallel, sequential, selection) suggest a monoidal category structure. Formalizing this could connect to the categorical semantics of linear logic.

3. **Quantum Extensions.** Quantum interactive proofs have different amplification behavior. Extending the tropical framework to quantum protocols could reveal new structural results.

4. **Non-Linear Barriers.** Our barrier persistence theorem covers linear barriers (f(x) = αx). Characterizing which non-linear barrier functions persist under composition is open.

5. **Computational TCP Ratio.** For concrete proof systems (sumcheck, low-degree test, PCP), compute explicit TCP ratios and determine whether known protocols are optimal.

---

## 7. References

1. Goldwasser, S., Micali, S., Rackoff, C. "The Knowledge Complexity of Interactive Proof Systems." *SIAM J. Computing* 18(1), 186-208 (1989).

2. Babai, L. "Trading Group Theory for Randomness." *STOC 1985*, 421-429.

3. Raz, R. "A Parallel Repetition Theorem." *SIAM J. Computing* 27(3), 763-803 (1998).

4. Maclagan, D., Sturmfels, B. *Introduction to Tropical Geometry.* Graduate Studies in Mathematics, Vol. 161, AMS (2015).

5. Mikhalkin, G. "Enumerative Tropical Algebraic Geometry in ℝ²." *J. Amer. Math. Soc.* 18, 313-377 (2005).

6. Pin, J.-E. "Tropical Semirings." *Idempotency*, Cambridge University Press, 50-69 (1998).

7. Arora, S., Barak, B. *Computational Complexity: A Modern Approach.* Cambridge University Press (2009).

---

## Appendix: Formalization Summary

All definitions and theorems in this paper have been formalized in Lean 4 using the Mathlib library. The formalization comprises:
- 6 definitions (ProofSpec, tropCost, tcpRatio, parRep, TropicalBarrier, detectionProb)
- 12 theorems, all proved without `sorry`
- Clean axiom usage (only propext, Classical.choice, Quot.sound)

The Lean source file is `Tropical/ProofComplexity/Core.lean`.
