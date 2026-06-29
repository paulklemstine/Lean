# Tropical Proof Complexity: An Algebraic Framework for Verification Costs

## Abstract

We establish a rigorous mathematical framework connecting interactive proof systems with tropical (min-plus) algebra. The central observation is that the multiplicative structure of soundness error under parallel repetition corresponds to additive structure in the tropical semiring, while sequential composition corresponds to tropical addition (minimum). We prove seven main theorems: (1) tropical cost additivity under parallel repetition, (2) a lower bound on sequential composition cost via tropical addition, (3) an exponential bound on oracle corruption detection, (4) a security-cost equivalence theorem connecting tropical barriers to soundness guarantees, (5) an amplification-detection duality showing that proof amplification and corruption detection obey the same tropical scaling law, (6) a round complexity lower bound, and (7) tropical convexity of mixed verification strategies. All results are formalized and machine-verified in Lean 4 with the Mathlib library.

## 1. Introduction

Interactive proof systems [GMR89, BFL91] are the theoretical foundation of modern cryptography. A proof system consists of a prover P and a verifier V, where V accepts or rejects based on interaction with P. The two key parameters are *soundness error* ε (the probability that a cheating prover convinces V of a false statement) and *completeness* c (the probability that an honest prover convinces V of a true statement).

The fundamental technique for strengthening proof systems is *parallel repetition*: running k independent copies of the protocol and accepting only if all copies accept. This reduces the soundness error from ε to ε^k while reducing completeness from c to c^k.

In this paper, we observe that this exponential decay is naturally described by the tropical (min-plus) semiring, where the operation ⊕ is minimum and ⊗ is ordinary addition. Specifically, we define the *tropical verification cost* of a proof system as τ(P) = -log(ε), and show:

- Parallel repetition: τ(P^k) = k · τ(P) (tropical multiplication/scaling)
- Sequential composition: τ(P₁ ; P₂) ≥ min(τ(P₁), τ(P₂)) (tropical addition bound)

This correspondence is not merely notational. It reveals that proof system composition has the algebraic structure of a tropical module, and that fundamental limits on proof complexity can be expressed as constraints in tropical geometry.

## 2. Definitions

### 2.1 Proof System Parameters

**Definition 2.1.** A *proof system parameter set* is a tuple P = (ε, c) where:
- ε ∈ (0, 1) is the soundness error
- c ∈ (0, 1] is the completeness

**Definition 2.2.** The *tropical verification cost* of P = (ε, c) is τ(P) = -log(ε).

**Proposition 2.3.** For any valid proof system P, τ(P) > 0.

*Proof.* Since 0 < ε < 1, we have log(ε) < 0, so -log(ε) > 0. □

### 2.2 Parallel Repetition

**Definition 2.4.** The *k-fold parallel repetition* of P = (ε, c) is P^k = (ε^k, c^k).

This is well-defined: ε^k ∈ (0, 1) since ε ∈ (0, 1) and k > 0, and c^k ∈ (0, 1] since c ∈ (0, 1].

### 2.3 Tropical Verification System

**Definition 2.5.** A *tropical verification system* is a tuple V = (r, ε, β) where:
- r ∈ ℕ⁺ is the number of rounds
- ε ∈ (0, 1) is the base error per round
- β > 0 is the security barrier (tropical cost threshold)

The *total cost* is T(V) = r · (-log ε), the *residual error* is E(V) = ε^r, and V is *secure* if β ≤ T(V).

## 3. Main Results

### 3.1 Parallel Repetition and Tropical Cost

**Theorem 3.1** (Parallel Repetition Amplification). For any proof system P = (ε, c) and k > 0:

(P^k).soundness = ε^k

**Theorem 3.2** (Tropical Cost Additivity). For any proof system P and k > 0:

τ(P^k) = k · τ(P)

*Proof.* τ(P^k) = -log(ε^k) = -k · log(ε) = k · (-log(ε)) = k · τ(P). Uses the power rule for logarithms. □

This is the key structural result: parallel repetition acts as scaling in the tropical semiring.

### 3.2 Sequential Composition

**Theorem 3.3** (Sequential Composition Error). For independent proof systems with errors ε₁, ε₂ ∈ (0, 1), the combined error under sequential composition (accept iff both accept, applied to a cheating prover who may attack either) is:

ε₁ + ε₂ - ε₁ε₂ < 1

This is the inclusion-exclusion formula for the union of two independent events.

**Theorem 3.4** (Inclusion-Exclusion vs. Union Bound). For ε₁, ε₂ > 0:

ε₁ + ε₂ - ε₁ε₂ < ε₁ + ε₂

The exact error is strictly less than the union bound.

**Theorem 3.5** (Tropical Cost Lower Bound for Sequential Composition). For ε₁, ε₂ ∈ (0, 1):

min(-log ε₁, -log ε₂) ≤ -log(ε₁ · ε₂)

*Proof.* Since -log(ε₁ · ε₂) = -log(ε₁) + (-log(ε₂)) and both summands are positive (as ε₁, ε₂ ∈ (0, 1) imply log(εᵢ) < 0), the minimum of the two summands is bounded by their sum. □

**Interpretation.** In the tropical semiring, the combined cost (right side) is the tropical product of individual costs. The tropical sum (left side, the minimum) provides a lower bound. This means sequential composition never loses more than a single component's worth of security.

### 3.3 Oracle Corruption Detection

**Theorem 3.6** (Oracle Corruption Detection Bound). For corruption rate δ ∈ (0, 1) and q > 0 queries:

(1 - δ)^⌈q⌉ ≤ exp(-δq)

*Proof.* Uses the fundamental inequality 1 - x ≤ exp(-x) for all x, applied pointwise, then raised to the ⌈q⌉-th power. □

This connects oracle verification to the exponential decay framework: the tropical detection cost is δq, growing linearly in the number of queries.

**Theorem 3.7** (Miss Probability Doubling). For any δ and k:

(1 - δ)^{2k} = ((1 - δ)^k)²

Doubling the number of queries squares the miss probability.

### 3.4 Security-Cost Equivalence

**Theorem 3.8** (Security-Cost Equivalence). A tropical verification system V = (r, ε, β) is secure if and only if its residual error satisfies:

E(V) = ε^r ≤ exp(-β)

*Proof.* The system is secure iff β ≤ r · (-log ε). Since ε^r = exp(r · log ε), we have ε^r ≤ exp(-β) iff r · log(ε) ≤ -β iff β ≤ r · (-log ε)). □

This is the fundamental theorem of the framework: it establishes a precise dictionary between the probabilistic world (residual error ≤ exp(-β)) and the tropical world (total cost ≥ barrier β).

**Theorem 3.9** (Minimum Rounds). For any ε ∈ (0, 1) and barrier β > 0, if k ≥ ⌈β / (-log ε)⌉, then ε^k ≤ exp(-β).

### 3.5 Amplification-Detection Duality

**Theorem 3.10** (Amplification-Detection Duality). For ε, δ ∈ (0, 1) and k ∈ ℕ:

-log(ε^k) = k · (-log ε)      [amplification cost]
-log((1-δ)^k) = k · (-log(1-δ))  [detection cost]

Both are instances of the tropical scaling law: cost(k) = k · cost(1).

**Interpretation.** Soundness amplification and corruption detection are not merely analogous — they are the same mathematical operation (tropical scaling) applied to different base costs. The base cost for amplification is -log(ε) and for detection is -log(1-δ).

### 3.6 Round Complexity Lower Bounds

**Theorem 3.11** (Round Complexity Lower Bound). If ε^k ≤ target for ε, target ∈ (0, 1), then:

k ≥ log(target) / log(ε)

This is tight: k = ⌈log(target) / log(ε)⌉ rounds suffice.

**Corollary 3.12** (Exponential Rounds). To achieve soundness error ≤ 2^{-n} from base error ε:

k ≥ n / log₂(1/ε)

### 3.7 Tropical Convexity

**Theorem 3.13** (Mixed Strategy Bound). For costs c₁, c₂ and mixing probability p ∈ (0, 1):

p · c₁ + (1-p) · c₂ ≤ max(c₁, c₂)

The expected cost of a mixed strategy is bounded by the tropical supremum (max) of component costs. This establishes that the achievable cost region is tropically convex.

## 4. Algorithms

### 4.1 Optimal Round Selection

**Input:** Base error ε, target security level β (in bits)
**Output:** Minimum number of rounds k

```
k ← ⌈β · ln(2) / (-ln(ε))⌉
return k
```

**Correctness:** By Theorem 3.9, k rounds achieve tropical cost k · (-log ε) ≥ β · ln(2), which corresponds to security level ≥ β bits.

### 4.2 Tropical Cost Analysis

**Input:** Collection of proof systems P₁, ..., Pₙ
**Output:** Achievable cost vectors under composition

```
For parallel composition:
    total_cost ← Σᵢ τ(Pᵢ)
    total_error ← Πᵢ εᵢ

For sequential composition:
    cost_bound ← minᵢ τ(Pᵢ)
    exact_error ← 1 - Πᵢ(1 - εᵢ)
```

## 5. Discussion

### 5.1 Relationship to Existing Work

The connection between repeated independent trials and exponential error decay is classical (Chernoff bounds, Hoeffding's inequality). Our contribution is the observation that the *algebraic structure* of this decay is precisely the tropical semiring, and that this structure extends from simple repetition to general proof system composition.

The tropical semiring has appeared in diverse contexts: optimization [BCOQ92], algebraic geometry [MS15], phylogenetics [SS04], and machine learning [ZMG+18]. To our knowledge, this is the first systematic application to proof complexity and cryptographic security.

### 5.2 The Tropical Proof Length Conjecture

We conjecture that for resolution-like proof systems with n variables and soundness error ε, the minimum proof length L satisfies:

L ≥ n · (-log ε)

This conjecture is motivated by:
1. The tropical cost of n independent variables is n · τ (by Theorem 3.2 applied to n independent sub-systems).
2. Each variable contributes at least one bit of information to the proof.
3. The tropical cost per bit of information is -log(ε).

The conjecture is computationally testable on random 3-SAT instances at the satisfiability threshold (clause-to-variable ratio ≈ 4.267).

### 5.3 Implications for Cryptographic Design

The tropical framework provides a principled approach to security parameter selection:

1. **Identify the base error** ε of the underlying protocol.
2. **Compute the tropical cost** τ = -log(ε) per round.
3. **Set the barrier** β = security_bits × ln(2).
4. **Compute rounds** k = ⌈β / τ⌉.

This is optimal by Theorem 3.11: fewer rounds are provably insufficient.

## 6. Future Work

1. **Tropical proof complexity classes**: Define complexity classes based on tropical cost bounds and study their relationships.
2. **Non-independent repetition**: Extend the framework to correlated rounds (e.g., direct product theorems for games).
3. **Quantum proof systems**: Analyze quantum interactive proofs (QIP) through the tropical lens.
4. **Categorical framework**: Formalize proof system composition as a monoidal category with tropical enrichment.

## References

- [BFL91] Babai, Fortnow, Lund. Non-deterministic exponential time has two-prover interactive protocols. *Computational Complexity* 1(1), 1991.
- [BCOQ92] Baccelli, Cohen, Olsder, Quadrat. *Synchronization and Linearity: An Algebra for Discrete Event Systems*. Wiley, 1992.
- [GMR89] Goldwasser, Micali, Rackoff. The knowledge complexity of interactive proof systems. *SIAM J. Computing* 18(1), 1989.
- [MS15] Maclagan, Sturmfels. *Introduction to Tropical Geometry*. AMS, 2015.
- [SS04] Speyer, Sturmfels. The tropical Grassmannian. *Advances in Geometry* 4(3), 2004.
- [ZMG+18] Zhang, Maddison, Grosse, et al. Tropical geometry of deep neural networks. *ICML*, 2018.
