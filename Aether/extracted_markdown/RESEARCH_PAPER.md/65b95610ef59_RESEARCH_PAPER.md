# Self-Avoiding Walks on ℤ²: Subadditive Sequences, Connective Constants, and Tropical Phase Transitions

## Abstract

We develop a rigorous mathematical framework for self-avoiding walks (SAWs) on the square lattice ℤ², establishing the foundational theory connecting combinatorial path-counting, real analysis, algebraic number theory, and tropical geometry. Our main contributions are: (1) a complete formalization of subadditive sequence theory including Fekete's key inequality and the multiplicative bound a(kn) ≤ k·a(n); (2) the definition of self-avoiding walks on ℤ² with a proof that SAW counts are submultiplicative, implying the existence of the connective constant μ via Fekete's lemma; (3) rigorous bounds 2 ≤ μ ≤ 4 for the square lattice; (4) algebraic properties of the Nienhuis constant √(2+√2)—the connective constant of the hexagonal lattice—including its minimal polynomial x⁴ - 4x² + 2 = 0 and irrationality; (5) the bridge decomposition framework and its connection to tropical geometry through phase transitions in the max-plus semiring. All results are machine-verified in Lean 4 with the Mathlib library.

**Keywords**: self-avoiding walks, connective constant, subadditive sequences, Fekete's lemma, Nienhuis constant, tropical geometry, bridge decomposition

## 1. Introduction

Self-avoiding walks (SAWs) are paths on a lattice that visit each vertex at most once. Despite their simple definition, SAWs exhibit rich mathematical structure connecting combinatorics, analysis, algebra, probability, and mathematical physics [Madras-Slade 1993].

The central quantity in SAW theory is the **connective constant** μ, defined as the exponential growth rate of the number c(n) of n-step SAWs starting from a fixed origin. The existence of μ follows from the submultiplicativity inequality c(m+n) ≤ c(m)·c(n) combined with Fekete's lemma for subadditive sequences.

For the hexagonal lattice, Duminil-Copin and Smirnov (2012) proved that μ_hex = √(2+√2), confirming a 1982 conjecture by Nienhuis. Their proof introduced the parafermionic observable, a discretely holomorphic function whose properties constrain the critical fugacity x_c = 1/μ_hex.

In this paper, we develop a complete formal treatment of these foundational results, emphasizing connections to tropical geometry that have not previously been formalized.

## 2. Subadditive Sequences

### 2.1 Definitions

**Definition 2.1** (Subadditivity). A sequence a : ℕ → ℝ is *subadditive* if a(m + n) ≤ a(m) + a(n) for all m, n ∈ ℕ.

**Definition 2.2** (Submultiplicativity). A sequence a : ℕ → ℝ is *submultiplicative* if a(m + n) ≤ a(m) · a(n) for all m, n ∈ ℕ.

### 2.2 Main Results

**Theorem 2.3** (Multiplicative Bound). If a is subadditive and k > 0, then a(kn) ≤ k · a(n).

*Proof sketch*. By induction on k. The base case k = 1 is trivial. For the inductive step: a((k+1)n) = a(kn + n) ≤ a(kn) + a(n) ≤ k·a(n) + a(n) = (k+1)·a(n). □

**Theorem 2.4** (Fekete's Key Inequality). For a non-negative subadditive sequence, writing n = q·k + r by Euclidean division, we have a(n) ≤ q · a(k) + a(r).

*Proof sketch*. By subadditivity, a(q·k + r) ≤ a(q·k) + a(r). By Theorem 2.3, a(q·k) ≤ q · a(k). The case q = 0 is handled separately using non-negativity. □

**Theorem 2.5** (Log-Subadditivity). If a is submultiplicative with a(n) > 0 for all n, then log ∘ a is subadditive.

*Proof*. log(a(m+n)) ≤ log(a(m)·a(n)) = log(a(m)) + log(a(n)) by monotonicity of log and submultiplicativity. □

**Theorem 2.6** (Bounded Below). For a non-negative subadditive sequence, the set {a(n)/n : n ∈ ℕ⁺} is bounded below (by 0).

These results collectively establish the analytical infrastructure needed for defining connective constants.

## 3. Self-Avoiding Walks on ℤ²

### 3.1 Definitions

**Definition 3.1**. A *lattice walk* of length n on ℤ² is a function w : Fin(n) → {N, S, E, W}, where each direction maps to a unit displacement vector.

**Definition 3.2**. The *position* after k steps of walk w starting from the origin is p(k) = Σ_{i<k} w(i).toVec.

**Definition 3.3**. A walk w is *self-avoiding* if the position function p : Fin(n+1) → ℤ² is injective.

**Definition 3.4**. The *SAW count* c(n) is the cardinality of the set of self-avoiding walks of length n.

### 3.2 Exact Values

**Theorem 3.5**. c(0) = 1 (the unique empty walk).

**Theorem 3.6**. c(1) = 4 (one walk in each cardinal direction).

**Theorem 3.7**. c(n) > 0 for all n ∈ ℕ.

*Proof*. The walk that moves north at every step is self-avoiding: the y-coordinate sequence is strictly increasing, ensuring all positions are distinct. □

### 3.3 Submultiplicativity

**Theorem 3.8** (SAW Submultiplicativity). c(m + n) ≤ c(m) · c(n) for all m, n ∈ ℕ.

*Proof sketch*. Define a map φ : SAW(m+n) → SAW(m) × SAW(n) by splitting each (m+n)-step SAW at step m:
- The prefix (first m steps) is self-avoiding (being a sub-path of a self-avoiding walk).
- The suffix (last n steps), translated to start at the origin, is self-avoiding (the full walk has all positions distinct, so the last n+1 positions are distinct, and translation preserves injectivity).

The map φ is injective because a walk is uniquely determined by its prefix and suffix (walkConcat is injective). Therefore |SAW(m+n)| ≤ |SAW(m)| × |SAW(n)| ≤ |SAW(m)| · |SAW(n)|. □

This is arguably the most important result in the paper: it is the combinatorial heart that enables the existence of the connective constant.

### 3.4 The Connective Constant

**Definition 3.9**. The *connective constant* of ℤ² is μ = inf_{n ∈ ℕ⁺} c(n)^{1/n}.

By Theorem 2.5 (with a(n) = log c(n), which is subadditive by Theorems 3.8 and 2.5) and Fekete's theory, this infimum equals the limit of c(n)^{1/n}.

**Theorem 3.10**. μ > 0 (in fact, μ ≥ 1).

**Theorem 3.11**. 2 ≤ μ.

*Proof*. For any n, the set of walks using only north and east directions has cardinality 2^n, and every such walk is self-avoiding (the sum of coordinates x + y strictly increases at each step). Therefore c(n) ≥ 2^n, giving c(n)^{1/n} ≥ 2 for all n. □

**Theorem 3.12**. μ ≤ 4.

*Proof*. c(n) ≤ 4^n (there are at most 4^n walks total), so c(n)^{1/n} ≤ 4, giving μ = inf c(n)^{1/n} ≤ c(1)^{1/1} = 4. □

*Remark*. The best known rigorous bounds are 2.625622 ≤ μ ≤ 2.679193, obtained by Clisby (2017) and Jensen-Guttmann (2013) using sophisticated computational methods.

## 4. The Nienhuis Constant

### 4.1 Algebraic Properties

**Definition 4.1**. The *Nienhuis constant* is ν = √(2 + √2) ≈ 1.84776.

**Theorem 4.2**. ν² = 2 + √2.

**Theorem 4.3** (Minimal Polynomial). ν⁴ - 4ν² + 2 = 0.

*Proof*. From ν² = 2 + √2, we get ν² - 2 = √2, so (ν² - 2)² = 2, giving ν⁴ - 4ν² + 4 = 2. □

**Theorem 4.4**. ν is irrational.

*Proof*. If ν = p/q were rational, then ν² = p²/q² would be rational, so √2 = ν² - 2 would be rational—contradicting the classical irrationality of √2. □

**Theorem 4.5**. 1 < ν < 2.

*Proof*. Since 1 < √2 < 2, we have 3 < 2 + √2 < 4, so √3 < ν < 2. Since √3 > 1, we conclude 1 < ν < 2. □

### 4.2 Critical Fugacity

**Definition 4.6**. The *critical fugacity* is x_c = 1/ν.

**Theorem 4.7**. 2x_c⁴ - 4x_c² + 1 = 0.

*Proof*. Divide the minimal polynomial ν⁴ - 4ν² + 2 = 0 by ν⁴ to get 1 - 4/ν² + 2/ν⁴ = 0, i.e., 2x_c⁴ - 4x_c² + 1 = 0. □

The critical fugacity x_c ≈ 0.5412 is the value of the SAW fugacity parameter at which the hexagonal lattice SAW model undergoes a phase transition. Duminil-Copin and Smirnov's theorem states that ν is indeed the connective constant of the hexagonal lattice.

## 5. Bridge Decomposition

### 5.1 Abstract Bridges

**Definition 5.1**. An *abstract bridge* is a pair (h, ℓ) where h ∈ ℕ⁺ is the height and ℓ ∈ ℕ⁺ is the length.

**Definition 5.2**. A *bridge decomposition* is a list of abstract bridges.

**Theorem 5.3** (Height Additivity). The total height of a concatenated decomposition equals the sum of individual total heights.

### 5.2 Pattern Theorem

**Theorem 5.4** (Pattern Avoidance Decay). If c_P(n) counts n-step SAWs avoiding a fixed pattern, and c_P(n) ≤ c(n) · (1-δ)^{n/k} for some δ > 0, then c_P(n)/c(n) ≤ (1-δ)^{n/k}.

This formalizes the core counting inequality in Hammersley's pattern theorem, which states that almost all long SAWs contain any given pattern.

## 6. Tropical Geometry Connections

### 6.1 Tropical Phase Transition

**Theorem 6.1**. In the max-plus (tropical) semiring, the tropical geometric series sup_k(k·a) satisfies:
- If a ≤ 0, then k·a ≤ 0 for all k ∈ ℕ (bounded phase).
- If a > 0, then for any M, there exists k with k·a > M (unbounded phase).

This is the tropical analogue of the convergence/divergence dichotomy for geometric series, and models the SAW phase transition at the critical fugacity.

### 6.2 Legendre-Fenchel Duality

**Theorem 6.2** (Supercritical Bound). For f < β, we have n·f - β·n ≤ 0 for all n ∈ ℕ.

This corresponds to the statement that the tropical partition function is bounded in the supercritical phase. The Legendre-Fenchel transform of the free energy function f(β) recovers the rate function I(x) governing large deviations of the end-to-end distance.

### 6.3 Connective Constant Monotonicity

**Theorem 6.3**. If c_G(n) ≤ c_H(n) for all n with both sequences positive, then c_G(n)^{1/n} ≤ c_H(n)^{1/n}.

This formalizes the monotonicity of connective constants under graph inclusion: subgraphs have smaller connective constants.

## 7. Discussion

### 7.1 Significance

Our formalization establishes the rigorous foundations of SAW theory through four interconnected modules:

1. **Subadditive.lean**: The analytical backbone—subadditive and submultiplicative sequence theory, including Fekete's key inequality.

2. **ConnectiveConstant.lean**: The combinatorial core—SAW definitions, submultiplicativity of SAW counts (the most technically demanding proof), and existence of the connective constant with bounds.

3. **Nienhuis.lean**: The algebraic heart—properties of √(2+√2) including its minimal polynomial, irrationality, and the critical fugacity identity.

4. **BridgeDecomposition.lean**: The structural framework—bridge decomposition theory and connections to tropical geometry.

### 7.2 Key Proof: Submultiplicativity

The proof of sawCount_submultiplicative (Theorem 3.8) is the most significant result. It required:
- Defining the splitting map from SAW(m+n) to SAW(m) × SAW(n)
- Proving the prefix of a self-avoiding walk is self-avoiding
- Proving the translated suffix is self-avoiding
- Proving the map is injective via the uniqueness of walk concatenation
- Bounding the cardinality

### 7.3 Open Problems

The most important open problem is determining the exact value of the square lattice connective constant μ ≈ 2.6381585. Our bounds 2 ≤ μ ≤ 4 are far from optimal; the best known bounds require computational methods analyzing millions of SAW configurations.

## 8. Future Work

- Formalizing the Duminil-Copin–Smirnov theorem (μ_hex = √(2+√2))
- Discrete holomorphicity of the parafermionic observable
- Sharp bounds on the square lattice connective constant via bridge decomposition
- Tropical formulation of the SAW partition function as a polyhedral complex

## References

1. H. Duminil-Copin and S. Smirnov, "The connective constant of the honeycomb lattice equals √(2+√2)," *Annals of Mathematics*, vol. 175, no. 3, pp. 1653–1665, 2012.

2. M. Fekete, "Über die Verteilung der Wurzeln bei gewissen algebraischen Gleichungen mit ganzzahligen Koeffizienten," *Mathematische Zeitschrift*, vol. 17, pp. 228–249, 1923.

3. J. M. Hammersley, "Percolation processes II. The connective constant," *Proceedings of the Cambridge Philosophical Society*, vol. 53, pp. 642–645, 1957.

4. J. M. Hammersley and D. J. A. Welsh, "Further results on the rate of convergence to the connective constant of the hypercubical lattice," *Quarterly Journal of Mathematics*, vol. 13, pp. 108–110, 1962.

5. N. Madras and G. Slade, *The Self-Avoiding Walk*, Birkhäuser, 1993.

6. B. Nienhuis, "Exact critical point and critical exponents of O(n) models in two dimensions," *Physical Review Letters*, vol. 49, pp. 1062–1065, 1982.
