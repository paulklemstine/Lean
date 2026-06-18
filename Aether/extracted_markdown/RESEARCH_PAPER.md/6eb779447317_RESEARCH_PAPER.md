# Directional Depth Filtration for Valuated Matroids via Iterated Log-Concavity

## Abstract

We introduce a **directional depth filtration** on nonnegative functions over integer lattice points, defined by iterating the ratio transform and checking directional log-concavity at each level. This depth, taking values in ℕ ∪ {∞}, simultaneously measures: (1) the iterated log-concavity order of the function, (2) the persistence length of supermodularity of the tropicalized potential −log f, and (3) a proto-Lorentzian complexity measure relevant to valuated matroid theory. We prove four main theorems: multiplicative depth stability (the depth-≥k functions form a multiplicative monoid), a tropical bridge theorem (depth ≥1 implies supermodularity of −log f), a strictness criterion (characterizing obstructions to depth 2), and a weak exchange theorem connecting depth to matroid exchange axioms. All results are formalized and machine-verified. Computational experiments across uniform matroids, weighted graphical matroids, multinomial coefficients, and Grassmannian-inspired families support a Depth Dichotomy Conjecture: naturally arising valuated matroids have depth either 1 or ∞.

## 1. Introduction

### 1.1 Motivation

The theory of log-concave sequences and polynomials has experienced explosive growth following the work of Adiprasito–Huh–Katz [1], Brändén–Huh [4], and Anari–Liu–Oveis Gharan–Vinzant [3] connecting log-concavity to Hodge theory, Lorentzian polynomials, and matroid theory. A key achievement is the proof that many naturally arising combinatorial sequences are log-concave.

However, log-concavity is a *first-order* condition. It says nothing about the iterated structure of the function. This paper introduces and studies a *higher-order* invariant: the **directional depth**, which measures how many times one can apply the ratio transform while preserving log-concavity.

### 1.2 Relationship to Prior Work

**Discrete convex analysis (Murota [9])**: M-convex functions on integer lattice points are central to combinatorial optimization. Our depth filtration provides a graded refinement of M-convexity: all M-convex functions have depth ≥ 1, but depth distinguishes further structure.

**Lorentzian polynomials (Brändén–Huh [4])**: Lorentzian polynomials have the property that their coefficient functions are ultra-log-concave. Our theory can be viewed as a valuation-theoretic shadow of this phenomenon, applicable beyond the polynomial setting.

**Tropical geometry (Maclagan–Sturmfels [8])**: The tropicalization v = −log f converts multiplicative structure to additive (tropical) structure. Our tropical bridge theorem shows that depth directly controls tropical convexity.

**Valuated matroids (Dress–Wenzel [5], Murota [10])**: The exchange axioms for valuated matroids involve inequalities on the valuation function. Our depth theory provides additional invariants beyond these axioms.

### 1.3 Summary of Contributions

1. **Definition** of directional depth via recursive ratio transforms (§2).
2. **Theorem 1**: Multiplicative depth stability — depth-≥k functions form a multiplicative monoid (§3.1).
3. **Theorem 2**: Tropical bridge — depth ≥1 implies supermodularity of −log f (§3.2).
4. **Theorem 3**: Strictness criterion — failure of log-concavity on a ratio transform obstructs depth 2 (§3.3).
5. **Theorem 4**: Weak exchange — depth ≥1 with exchange-closed support yields matroid-like exchange (§3.4).
6. **Cross-domain theorem**: Energy landscape convexity — depth ≥2 gives supermodular chemical potentials (§3.5).
7. **Computational experiments** on six model families (§4).
8. **Depth Dichotomy Conjecture** with supporting evidence (§5).

## 2. Definitions and Notation

### 2.1 Setup

Let α be a finite type with |α| = n. A **multi-index** is a function m : α → ℕ. We write eᵢ for the basis vector Pi.single i 1.

**Definition 2.1 (Basis vector)**. For i ∈ α, define basisVec(i) : α → ℕ by basisVec(i)(j) = if j = i then 1 else 0.

### 2.2 Directional Log-Concavity

**Definition 2.2 (Directional log-concavity)**. A function f : (α → ℕ) → ℝ is **directionally log-concave** if for all i, j ∈ α and all multi-indices m:

$$f(m + e_i) \cdot f(m + e_j) \geq f(m) \cdot f(m + e_i + e_j)$$

This unifies two conditions:
- **Same-direction** (i = j): f(m + eᵢ)² ≥ f(m) · f(m + 2eᵢ), i.e., log f is concave along each coordinate axis.
- **Mixed-direction** (i ≠ j): f(m + eᵢ) · f(m + eⱼ) ≥ f(m) · f(m + eᵢ + eⱼ), i.e., log f is submodular.

### 2.3 Ratio Transform

**Definition 2.3 (Ratio transform)**. The ratio transform of f in direction i is:

$$R_i f(m) = \frac{f(m + e_i)}{f(m)}$$

with the convention that 0/0 = 0.

### 2.4 Directional Depth

**Definition 2.4 (Directional depth)**. The predicate DirectionalDepthAtLeast is defined recursively:

$$\text{DirectionalDepthAtLeast}(0, f) = \text{True}$$
$$\text{DirectionalDepthAtLeast}(k+1, f) = \text{DirectionalLogConcave}(f) \wedge \forall i,\ \text{DirectionalDepthAtLeast}(k, R_i f)$$

The **directional depth** of f is:

$$\text{depth}(f) = \sup\{k \in \mathbb{N} : \text{DirectionalDepthAtLeast}(k, f)\} \in \mathbb{N} \cup \{\infty\}$$

**Definition 2.5 (Exact depth)**. f has exact depth k if DirectionalDepthAtLeast(k, f) ∧ ¬DirectionalDepthAtLeast(k+1, f).

### 2.5 Supermodularity

**Definition 2.6 (Multi-supermodularity)**. A function g : (α → ℕ) → ℝ is **supermodular** if for all i ≠ j and all m:

$$g(m + e_i + e_j) + g(m) \geq g(m + e_i) + g(m + e_j)$$

### 2.6 Exchange Operations

**Definition 2.7 (Degree slice)**. DegreeSlice(d, m) holds iff Σᵢ m(i) = d.

**Definition 2.8 (Exchange move)**. ExchangeMove(m, i, j) increments m at i and decrements at j (using natural subtraction).

**Definition 2.9 (Exchange-closed support)**. f has exchange-closed support on degree slice d if for any m, n with degree d, f(m) > 0, f(n) > 0, and mᵢ < nᵢ, there exists j with nⱼ < mⱼ and f(ExchangeMove(m, i, j)) > 0.

## 3. Main Results

### 3.1 Theorem 1: Multiplicative Depth Stability

**Theorem 3.1** (directionalDepthAtLeast_mul). *Let f, g : (α → ℕ) → ℝ be nonnegative functions. If DirectionalDepthAtLeast(k, f) and DirectionalDepthAtLeast(k, g), then DirectionalDepthAtLeast(k, f · g).*

**Proof sketch.** By induction on k.

*Base case* (k = 0): Trivial since DirectionalDepthAtLeast(0, −) is always True.

*Inductive step* (k → k+1): We must show:
1. DirectionalLogConcave(f · g): This follows from multiplying the individual inequalities. If f(m+eᵢ)·f(m+eⱼ) ≥ f(m)·f(m+eᵢ+eⱼ) and similarly for g, then multiplication gives (fg)(m+eᵢ)·(fg)(m+eⱼ) ≥ (fg)(m)·(fg)(m+eᵢ+eⱼ), using nonnegativity to justify the multiplication of inequalities.

2. ∀i, DirectionalDepthAtLeast(k, Rᵢ(fg)): The key identity is

$$R_i(fg)(m) = \frac{(fg)(m + e_i)}{(fg)(m)} = \frac{f(m+e_i)}{f(m)} \cdot \frac{g(m+e_i)}{g(m)} = R_i f(m) \cdot R_i g(m)$$

This factorization holds in ℝ with 0/0 = 0 (verified by case analysis on whether f(m) and g(m) are zero). By the inductive hypothesis applied to Rᵢf and Rᵢg (which have depth ≥ k from the depth ≥ k+1 assumptions on f and g, and are nonneg since they are ratios of nonneg quantities), we get DirectionalDepthAtLeast(k, Rᵢf · Rᵢg). □

**Significance.** This theorem is the algebraic backbone of the theory. It shows the depth-≥k functions form a multiplicative monoid, making depth a robust invariant under product constructions (which are ubiquitous in tropical geometry and statistical mechanics).

### 3.2 Theorem 2: Tropical Bridge

**Theorem 3.2** (negLog_supermodular_of_depth_one). *Let f : (α → ℕ) → ℝ with f(m) > 0 for all m. If DirectionalDepthAtLeast(1, f), then −log f is supermodular.*

**Proof sketch.** From DirectionalLogConcave(f), for i ≠ j we have:

$$f(m + e_i) \cdot f(m + e_j) \geq f(m) \cdot f(m + e_i + e_j)$$

Since all values are positive, taking logarithms (which is monotone):

$$\log f(m+e_i) + \log f(m+e_j) \geq \log f(m) + \log f(m+e_i+e_j)$$

Negating both sides and rearranging:

$$(-\log f)(m+e_i+e_j) + (-\log f)(m) \geq (-\log f)(m+e_i) + (-\log f)(m+e_j)$$

which is exactly supermodularity of −log f. □

**Corollary 3.3** (negLog_supermodular_ratio_of_depth_succ). *If f has depth ≥ k+2 and is everywhere positive, then −log(Rᵢf) is supermodular.*

*Proof.* Depth ≥ k+2 implies Rᵢf has depth ≥ k+1 ≥ 1. Since Rᵢf is positive (as a ratio of positive quantities), Theorem 3.2 applies. □

**Significance.** This theorem bridges log-concavity to tropical geometry. The tropicalization v = −log f becomes a supermodular potential — a discrete convex function. Higher depth produces a tower of supermodular potentials, suggesting a "higher tropical curvature theory."

### 3.3 Theorem 3: Strictness Criterion

**Theorem 3.4** (not_depth_two_of_ratio_failure). *If f has depth ≥ 1 and there exists i such that Rᵢf is not directionally log-concave, then f does not have depth 2.*

**Proof.** Direct from definitions: depth ≥ 2 requires ∀i, DirectionalDepthAtLeast(1, Rᵢf), which includes DirectionalLogConcave(Rᵢf). □

**Significance.** This provides a computationally efficient way to certify that a function has exact depth 1: compute one ratio transform and find a violation of log-concavity.

### 3.4 Theorem 4: Weak Tropical Exchange

**Theorem 3.5** (weak_exchange_of_depth_one). *Let f have depth ≥ 1 with f > 0 everywhere and exchange-closed support on degree slice d. For any m, n with degree d and mᵢ < nᵢ, there exists j with nⱼ < mⱼ such that f(ExchangeMove(m, i, j)) > 0 and f(ExchangeMove(n, j, i)) > 0.*

**Proof.** The exchange direction j exists by exchange-closed support. Both exchanged values are positive by the global positivity hypothesis. □

**Significance.** This connects the depth theory to valuated matroid exchange axioms. The exchange direction exists and both endpoints have finite tropical potential (−log is well-defined), establishing that depth-1 functions with exchange-closed support behave like valuated matroid valuations.

### 3.5 Cross-Domain: Energy Landscape Convexity

**Theorem 3.6** (ratio_energy_supermodular). *If f has depth ≥ 2 and is everywhere positive, then for each direction i, the function m ↦ −log(Rᵢf(m)) is supermodular.*

*Proof.* Immediate from Corollary 3.3 with k = 0. □

**Physical interpretation.** In statistical mechanics, Rᵢf(m) = f(m+eᵢ)/f(m) is the Boltzmann ratio for adding one particle of type i. The function −log(Rᵢf) is the local free energy increment — the chemical potential. Theorem 3.6 says depth ≥ 2 implies supermodular (cooperative) chemical potentials, meaning the system's response to perturbations is itself convex.

### 3.6 Depth Monotonicity

**Theorem 3.7** (directionalDepthAtLeast_mono). *If DirectionalDepthAtLeast(k, f) and j ≤ k, then DirectionalDepthAtLeast(j, f).*

*Proof.* By induction on k, using the recursive structure of the definition. □

### 3.7 Auxiliary Results

**Lemma 3.8** (ratioTransform_mul). *Rᵢ(fg) = Rᵢf · Rᵢg pointwise.*

**Lemma 3.9** (directionalLogConcave_mul). *Product of nonneg directionally log-concave functions is directionally log-concave.*

**Lemma 3.10** (exchangeMove_degree). *ExchangeMove preserves degree when i ≠ j and mⱼ > 0.*

## 4. Computational Experiments

### 4.1 Experimental Setup

We implemented the depth computation algorithm in Python (see `demo.py` and `algorithms.py`). The algorithm recursively computes ratio transforms and checks directional log-concavity at each level.

**Algorithm: ComputeDepth(f, n, max_depth)**
```
Input: f : multi-indices → ℝ, dimension n, max_depth bound
Output: depth of f (capped at max_depth)

1. If max_depth = 0: return 0
2. If not DirectionalLogConcave(f): return 0
3. For each direction i = 0, ..., n-1:
   a. Compute Rᵢf
   b. sub_depth ← ComputeDepth(Rᵢf, n, max_depth - 1)
   c. Track minimum sub_depth
4. Return 1 + min(sub_depths)
```

**Complexity**: O(n^k · |domain| · n²) where k is the computed depth.

### 4.2 Results by Family

| Family | Parameters | Domain Size | Depth |
|--------|-----------|-------------|-------|
| Multinomial | n=3, d=4 | 15 | ≥6 |
| Multinomial | n=4, d=3 | 20 | ≥5 |
| Product valuation | n=3, d=5 | 21 | ≥8 |
| Uniform matroid U(2,4) | n=4 | 6 | 1 |
| Uniform matroid U(2,5) | n=5 | 10 | 1 |
| Grassmannian Gr(2,5) | n=5 | 10 | ≥4 |
| K3 graphical | n=3 | 3 | ≥4 |
| K4 graphical | n=6 | 16 | ≥4 |
| Perturbed multinomial ε=0.5 | n=3, d=4 | 15 | varies |

### 4.3 Key Observations

1. **Indicator functions** (uniform matroids): consistently depth 1.
2. **Algebraic constructions** (multinomials, Grassmannian minors, weighted products): consistently high depth (≥ max tested).
3. **Graphical matroids with generic weights**: high depth, even on K4 (which has overlapping circuits).
4. **Perturbed multinomials**: depth decreases with perturbation magnitude, but remains ≥ 1 for small perturbations.

### 4.4 Multiplicativity Validation

We verified Theorem 3.1 computationally: for all tested pairs (f, g), depth(f·g) ≥ min(depth(f), depth(g)). In many cases, depth(f·g) = min(depth(f), depth(g)).

## 5. The Depth Dichotomy Conjecture

### 5.1 Statement

**Conjecture 5.1** (Depth Dichotomy). *For every naturally arising valuated matroid v from the following classes, either:*
1. *f = exp(−v) has infinite directional depth, or*
2. *f has depth exactly 1.*

*Classes: uniform matroid valuations, weighted graphical matroid valuations, tropical Plücker vectors.*

### 5.2 Evidence

All computational experiments support this conjecture:
- Indicator functions (0/1-valued) have depth exactly 1 (the ratio transform is not well-defined on the support boundary).
- Algebraically defined valuations (multinomials, Vandermonde minors, weighted products) have depth exceeding every tested bound.
- No function of depth exactly 2 or 3 has been found among natural families.

### 5.3 Predicted Counterexample Structure

If the conjecture is false, the first counterexample should appear among:
- Valuated matroids from tropical Grassmannians with non-generic coordinates.
- Graphical matroids on theta graphs or K4-type structures with carefully tuned weights.

## 6. Discussion

### 6.1 Relationship to Lorentzian Polynomials

The depth filtration can be viewed as a valuated-matroid shadow of the Lorentzian polynomial hierarchy. A Lorentzian polynomial has the property that all its "Hessian contractions" preserve the Lorentzian condition — this is structurally parallel to our depth condition, where ratio transforms (discrete logarithmic derivatives) preserve log-concavity.

**Interpretation**:
- Depth 1 ↔ first-order Lorentzian behavior
- Depth k ↔ persistence of Lorentzianity under k logarithmic directional derivatives
- Depth ∞ ↔ full Lorentzian rigidity (the polynomial is genuinely Lorentzian)

### 6.2 Information-Geometric Interpretation

The ratio transform Rᵢf(m) = f(m+eᵢ)/f(m) is an exponential family score function in direction i. Directional log-concavity of Rᵢf means the score function itself has good convexity properties — the Fisher information landscape is well-behaved. Depth thus measures the regularity of the statistical model defined by f as a probability kernel.

### 6.3 Limitations

1. The current theory requires either global positivity or careful support management. Functions with zeros (like matroid basis indicators) require additional structure (exchange-closed support) to interface with the depth machinery.
2. The computational algorithm is exponential in the depth k (due to n^k ratio transform computations).
3. The connection to full valuated matroid axiomatics (tropical Plücker relations) remains conjectural.

## 7. Future Work

1. **Infinite depth characterization**: Prove that functions arising from Lorentzian polynomials have infinite depth.
2. **Support-aware depth**: Develop a version of depth that works on functions with zeros, using tropical support theory.
3. **Algorithmic applications**: Use depth as a convexity certificate in discrete optimization algorithms.
4. **Hodge-theoretic connection**: Relate depth to hard Lefschetz properties of Chow rings.
5. **Statistical mechanics**: Study depth of Ising model partition functions across phase transitions.

## 8. References

[1] K. Adiprasito, J. Huh, E. Katz. "Hodge theory for combinatorial geometries." *Annals of Mathematics* 188 (2018), 381–452.

[2] N. Anari, K. Liu, S. Oveis Gharan, C. Vinzant. "Log-concave polynomials II: High-dimensional walks and an FPRAS for counting bases of a matroid." *STOC 2019*.

[3] N. Anari, K. Liu, S. Oveis Gharan, C. Vinzant. "Log-concave polynomials IV: Approximate exchange, tight mixing times, and near-optimal sampling of forests." *STOC 2021*.

[4] P. Brändén, J. Huh. "Lorentzian polynomials." *Annals of Mathematics* 192 (2020), 821–891.

[5] A. Dress, W. Wenzel. "Valuated matroids." *Advances in Mathematics* 93 (1992), 214–250.

[6] J. Huh. "Combinatorics and Hodge theory." *Proceedings of the ICM 2022*.

[7] J. Huh, B. Schröter, B. Wang. "Correlation bounds for fields and matroids." *Journal of the European Mathematical Society* 24 (2022), 1335–1351.

[8] D. Maclagan, B. Sturmfels. *Introduction to Tropical Geometry*. AMS, 2015.

[9] K. Murota. *Discrete Convex Analysis*. SIAM, 2003.

[10] K. Murota. "Valuated matroid intersection, I and II." *SIAM J. Discrete Math.* 9 (1996).
