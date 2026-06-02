# Fractal Dimension of Proof Search: A Geometric Theory of Theorem Difficulty

## Abstract

We introduce the *search dimension* D(T) = log(k)/log(b) as a measure of theorem difficulty, where b is the branching factor of the proof search tree and k is the number of surviving branches per node. We prove that D ∈ [0,1], that D = 1 iff every path is a valid proof (trivial theorems), and that D = 0 iff proofs are unique (deterministic search). We establish a phase transition theorem showing these are the only critical points, with monotonicity of D in the survival count k. We prove the entropy-dimension bridge connecting D to the ratio of search entropy to full tree entropy, and show that proof search difficulty composes multiplicatively. We conjecture that D(T) ≈ 1 - c/n for generic theorems of statement length n, and propose an empirical test using Lean's Mathlib library.

**Keywords**: proof complexity, fractal dimension, branching processes, search dimension, information theory, phase transitions

## 1. Introduction

The difficulty of finding mathematical proofs is a central question in mathematical logic, computer science, and artificial intelligence. While proof complexity theory provides lower bounds on proof length in specific proof systems [1], it does not directly address the *search* problem: how hard is it to *find* a proof, given that one exists?

We propose a geometric approach. When a theorem prover searches for a proof, it explores a tree where each node represents a proof state and each edge represents an inference rule application. The set of paths leading to successful proofs forms a subset of all possible paths. The fractal dimension of this subset — defined via box-counting on the tree boundary — captures the intrinsic difficulty of the search.

### 1.1 Contributions

1. **Novel definition**: The *search dimension* D = log(k)/log(b), where b is the branching factor and k is the per-node survival count.

2. **Phase transition theorem**: D provides a complete classification of proof difficulty into three phases with sharp transitions at D = 0 and D = 1.

3. **Entropy-dimension bridge**: D equals the ratio of search entropy to full tree entropy, connecting fractal geometry to information theory.

4. **Composition theorem**: Sequential proof search has multiplicative difficulty, hence additive dimension in log-space.

5. **Universality conjecture**: D(T) ≈ 1 - c/n for generic theorems, with a proposed empirical test.

6. **Machine-verified proofs**: All main theorems are formalized and verified in Lean 4 with Mathlib.

## 2. Definitions

### 2.1 Branching Search Model

**Definition 2.1** (Branching Search Model). A *branching search model* is a triple M = (b, k, d) where:
- b ≥ 2 is the *branching factor* (number of applicable inference rules per proof state)
- k ∈ {1, ..., b} is the *survival count* (number of children leading to eventual proofs)
- d is the *search depth* (proof length)

The model describes a complete b-ary tree of depth d where at each internal node, exactly k of the b children are "productive" (lead to at least one successful leaf).

**Definition 2.2** (Total and successful leaves). For a model M = (b, k, d):
- Total leaves: L(M) = b^d
- Successful leaves: S(M) = k^d

### 2.2 Search Dimension

**Definition 2.3** (Search Dimension). The *search dimension* of a branching search model with parameters (b, k) is:

D(b, k) = log(k) / log(b)

This is defined for b ≥ 2 and k ≥ 1. It equals the Hausdorff dimension of the set of successful paths in the boundary of the b-ary tree equipped with the natural ultrametric d(x, y) = b^{-n(x,y)}, where n(x,y) is the length of the longest common prefix.

### 2.3 Search Entropy

**Definition 2.4** (Search Entropy). For depth d:
- SearchEntropy(k, d) = log(k^d) = d · log(k)
- FullTreeEntropy(b, d) = log(b^d) = d · log(b)

### 2.4 Composed Search

**Definition 2.5** (Composed Search). The sequential composition of searches M₁ = (b₁, k₁, d₁) and M₂ = (b₂, k₂, d₂) has:
- Total space: b₁^{d₁} · b₂^{d₂}
- Successful paths: k₁^{d₁} · k₂^{d₂}

## 3. Main Results

### 3.1 Fundamental Properties

**Theorem 3.1** (Range). For b ≥ 2, 1 ≤ k ≤ b: 0 ≤ D(b,k) ≤ 1.

*Proof.* D = log(k)/log(b). Since k ≥ 1, log(k) ≥ 0. Since b ≥ 2, log(b) > 0. Since k ≤ b, log(k) ≤ log(b). Thus 0 ≤ D ≤ 1. □

**Theorem 3.2** (Boundary values).
- D(b, 1) = 0 for all b ≥ 2 (deterministic proofs)
- D(b, b) = 1 for all b ≥ 2 (trivial theorems)

**Theorem 3.3** (Monotonicity). D(b, k) is (weakly) increasing in k for fixed b ≥ 2.

*Proof.* log is increasing, and division by the positive constant log(b) preserves order. □

**Theorem 3.4** (Strict subcriticality). D(b, k) < 1 if and only if k < b.

### 3.2 The Critical Threshold Theorem

**Theorem 3.5** (Critical Threshold). For b ≥ 2, 1 ≤ k ≤ b:
D(b, k) = 1 ↔ k = b

*Proof.* The forward direction uses injectivity of log on positive reals: if log(k) = log(b) and both k, b > 0, then k = b. The reverse direction is immediate from Definition 2.3. □

This theorem identifies the exact phase boundary between trivial and non-trivial proof search.

### 3.3 Subcritical Exponential Decay

**Theorem 3.6** (Exponential Decay). If k < b and d ≥ 1, then k^d < b^d.

**Theorem 3.7** (Decay Worsening). If 1 ≤ k < b, then for all d:
k^{d+1} · b^d < k^d · b^{d+1}

This shows that the success-to-total ratio (k/b)^d strictly decreases at each depth level.

### 3.4 The Entropy-Dimension Bridge

**Theorem 3.8** (Entropy-Dimension Bridge). For b ≥ 2 and d ≥ 1:
SearchEntropy(k, d) / FullTreeEntropy(b, d) = D(b, k)

*Proof.* 
SearchEntropy(k, d) / FullTreeEntropy(b, d)
= [d · log(k)] / [d · log(b)]
= log(k) / log(b)
= D(b, k) □

This shows the search dimension equals the ratio of "useful" entropy to "total" entropy.

### 3.5 Information Rate

**Theorem 3.9** (Information Rate). The information per depth level is:
log(b) - log(k) = log(b) · (1 - D)

**Corollary 3.10** (Information decomposition). Over d levels:
log(b^d) - log(k^d) = d · log(b) · (1 - D)

This shows that each proof step carries log(b) · (1 - D) bits of genuine information.

### 3.6 Composition

**Theorem 3.11** (Composition bound). For a composed search:
k₁^{d₁} · k₂^{d₂} ≤ b₁^{d₁} · b₂^{d₂}

**Theorem 3.12** (Log additivity). For same-branching composition:
log(k₁^{d₁} · k₂^{d₂}) = d₁ · log(k₁) + d₂ · log(k₂)

### 3.7 The Fractal Phase Transition

**Theorem 3.13** (Fractal Phase Transition). For b ≥ 2, the search dimension D(b, ·) : {1,...,b} → [0,1] satisfies:
1. D ∈ [0, 1] (bounded)
2. D(b, 1) = 0 (deterministic boundary)
3. D(b, k) = 1 ↔ k = b (critical boundary)
4. D is monotone increasing in k (smooth interpolation)

This provides a complete, continuous classification of proof difficulty.

### 3.8 The Doubling Lemma

**Theorem 3.14** (Doubling). If 2k ≤ b, then D(b, k) < D(b, 2k).

Each doubling of the survival count strictly increases the dimension, quantifying how additional proof strategies reduce search difficulty.

### 3.9 The Search Dimension Trichotomy

**Theorem 3.15** (Trichotomy). For b ≥ 2, 1 ≤ k ≤ b, d ≥ 1:
- k = 1 ⟹ k^d = 1 (unique proof path)
- 1 < k < b ⟹ 1 < k^d < b^d (exponential search required)
- k = b ⟹ k^d = b^d (trivial)

## 4. The Universality Conjecture

### 4.1 Statement

**Conjecture 4.1** (Proof Search Universality). For generic theorems T in a sufficiently expressive proof system:
D(T) = 1 - c / |T|
where |T| is the statement length and c > 0 is a universal constant.

### 4.2 Consequences

If true, the universality conjecture implies:
1. Short statements (|T| small) have low dimension → hard to prove
2. Long statements (|T| large) have dimension close to 1 → easier to prove
3. The difficulty per unit of theorem complexity is bounded: the search cost for proof depth d ∝ |T| scales as b^c (independent of |T|)

### 4.3 Proposed Test

**Protocol**: Sample 1000 theorems from Mathlib. For each theorem T:
1. Measure statement length s = |T| (number of tokens in the type)
2. Measure proof length p (number of tactic tokens)
3. Estimate D(T) via Monte Carlo: at each proof step, count available tactics (≈ b) and count those leading to eventual success (≈ k). Average log(k)/log(b) over all steps.
4. Compute (1 - D(T)) · s for each theorem.

**Prediction**: (1 - D(T)) · s ∈ [0.5, 5] for ≥ 90% of theorems, with c ≈ 2.

**Refutation criterion**: If (1 - D(T)) · s diverges or converges to 0 as s → ∞, the conjecture is false.

## 5. Connections to Existing Theory

### 5.1 Galton-Watson Processes

The branching search model is a deterministic analogue of the Galton-Watson branching process. In the stochastic setting, a GW process with mean offspring μ:
- Goes extinct a.s. if μ ≤ 1
- Survives with positive probability if μ > 1

Our k/b plays the role of the extinction probability per generation. The search dimension D = log(k)/log(b) determines the rate of exponential decay (subcritical) or growth (supercritical).

### 5.2 Kolmogorov Complexity

The information content bound (Theorem 3.9) connects to Kolmogorov complexity: a proof with search dimension D carries (1 - D) · d · log(b) bits of Kolmogorov complexity. Low-dimension proofs (D ≈ 0) are algorithmically incompressible; high-dimension proofs (D ≈ 1) are nearly redundant.

### 5.3 Proof Complexity Theory

The search dimension provides a geometric reinterpretation of proof complexity. While traditional proof complexity studies proof length in specific proof systems, the search dimension captures the *density* of proofs in the search space — a complementary measure that is invariant under polynomial-time translations between proof systems.

## 6. Discussion

### 6.1 Limitations

The branching search model assumes uniform branching factor and survival count at each node — a strong simplification. Real proof searches have heterogeneous branching. The model captures the essential scaling behavior but not the fine structure.

### 6.2 Implications for AI

For AI theorem provers, the search dimension provides a principled difficulty metric. Problems with D ≈ 1 are accessible to brute-force search; problems with D ≈ 0 require targeted heuristics. The doubling lemma suggests that even modest improvements in tactic selection (doubling the effective k) yield measurable dimension increases.

### 6.3 Philosophical Implications

The fractal phase transition theorem suggests that mathematical difficulty is not a binary classification but a continuous spectrum parameterized by a single real number. The universality conjecture, if true, would mean that this spectrum has a simple, universal shape — mathematics is a fractal at the edge of chaos.

## 7. Future Work

1. **Empirical validation**: Implement the Monte Carlo protocol (Section 4.3) on Mathlib.
2. **Heterogeneous branching**: Extend the model to allow variable (b_i, k_i) at each node.
3. **Connection to automata theory**: Relate the search dimension to the state complexity of proof automata.
4. **Quantum search**: Analyze how Grover-type quantum speedups interact with the search dimension (expected: D → D/2).
5. **Category-theoretic formulation**: Express the composition theorem as a monoidal functor between proof categories and dimension categories.

## References

[1] Cook, S. A., & Reckhow, R. A. (1979). The relative efficiency of propositional proof systems. *Journal of Symbolic Logic*, 44(1), 36-50.

[2] Mandelbrot, B. B. (1982). *The Fractal Geometry of Nature*. W. H. Freeman.

[3] Harris, T. E. (1963). *The Theory of Branching Processes*. Springer.

[4] Krajíček, J. (2019). *Proof Complexity*. Cambridge University Press.
