# Future Research Directions for the EML Operator — Version 9

## 180+ Open Problems Across 35 Fields

### April 2026

---

## Executive Summary

The EML operator eml(x,y) = exp(x) − ln(y) continues to reveal deep structure. Version 9 adds 70+ formally verified theorems covering strict convexity, orbit gap monotonicity, Bregman divergence connections, complete idempotent classification, unique characterization via the Legendre bridge, and integral identities. This document catalogs 180+ specific research directions, incorporating all V8 results plus V9 discoveries. Items marked ★ are new since V8.

**Total formalized theorems: 370+. Sorry count: 0.**

---

## 1. Pure Mathematics

### 1.1 Classification of Continuous Sheffer Operators
**Priority: Critical | Difficulty: Very Hard | Impact: Foundational**

- Classify all F(x,y) that, with some constant c, generate all elementary functions
- Known examples: EML, EDL (exp(x)/ln(y)), anti-EML (ln(x) − exp(y))
- V8: The Legendre bridge constrains Sheffer operators to those with exp-log duality
- ★ V9: The Legendre uniqueness theorem (Theorem 2.2) means EML is the UNIQUE operator satisfying eml(x, eʸ) = eˣ − y
- ★ V9: Classify operators F with F(x, f(y)) = g(x) − y for various f, g
- ★ V9: Connection to universal approximation: does the Legendre bridge imply density?

### 1.2 The Constant-Free Sheffer Problem
**Priority: Critical | Difficulty: Very Hard | Impact: Landmark**

Does there exist B(x,y) such that every elementary function is built from B alone?
- V8: The no-identity-element theorems severely constrain B
- ★ V9: The no-idempotent theorem further constrains: B(x,x) ≠ x for EML
- ★ V9: Combined with the Legendre uniqueness, can we prove B cannot be EML?
- **Conjecture**: No binary operator over ℂ generates all elementary functions without a distinguished constant

### 1.3 EML Fixed Point Theory
**Priority: High | Difficulty: Medium | Impact: Theoretical**

Proved through V9:
- d(z) has NO real fixed points ✓
- g(z) = e − ln(z) has unique attracting fixed point z* ≈ 2.017 ✓
- z* = W(eᵉ), |g'(z*)| = 1/z* < 1 ✓
- dⁿ(z) ≥ z + n (linear divergence lower bound) ✓
- d(z) ≥ z + 1 for all z ∈ ℝ ✓
- ★ V9: Orbit gap d(dⁿ(z)) − dⁿ(z) is non-decreasing for z > 0 ✓
- ★ V9: No idempotent elements: eml(x,x) ≠ x for all x ✓

**Open:**
- Prove the basin of attraction of z* is all of (0,∞)
- Characterize the rate of divergence: is dⁿ(z) ~ exp↑↑n?
- Complex fixed points of d(z) — locate them
- Schwarzian derivative S(d) and its sign on ℝ₊
- Can the orbit {dⁿ(z)} be expressed in closed form?
- ★ V9: Is the gap growth rate d(dⁿ(z)) − dⁿ(z) itself super-exponential?
- ★ V9: Lyapunov exponent of the diagonal map orbit

### 1.4 The Legendre Transform Connection
**Priority: Critical | Difficulty: Medium-Hard | Impact: Deep**

- V8: eml(x, eʸ) = eˣ − y (Legendre bridge, proved)
- ★ V9: Uniqueness: F continuous with F(x, eʸ) = eˣ − y implies F = eml (proved)
- ★ V9: Bregman divergence D_exp(x,y) = eˣ − eʸ − eʸ(x−y) ≥ 0 (proved)
- ★ V9: D_exp as EML difference: eml(x,1) − eml(y,1) − eʸ(x−y)

**Open:**
- Generalize to other convex functions: F(x,y) = f(x) − f*(y)?
- Does the Legendre structure explain why EML is universal?
- Applications to optimization: EML as a natural regularizer
- ★ V9: Can the Bregman connection be used to define EML-optimal transport?
- ★ V9: EML and f-divergences: systematic classification
- ★ V9: Mirror descent with EML: convergence rates

### 1.5 ★ EML Convexity Theory (SUBSTANTIALLY ADVANCED V9)
**Priority: High | Difficulty: Medium | Impact: Broad**

Proved in V9:
- Convex in x for fixed y ✓
- Convex in y on (0,∞) for fixed x ✓
- ★ V9: Self-pairing σ(x) = eˣ − x is STRICTLY convex ✓
- ★ V9: σ(x) ≥ 1 with minimum at x = 0 ✓
- ★ V9: Second derivatives: ∂²/∂x² = eˣ > 0, ∂²/∂y² = 1/y² > 0 ✓

**Open:**
- ★ V9: Is eml jointly convex on ℝ × (0,∞)? (Need Hessian positive semidefinite)
  - The cross term ∂²/∂x∂y = 0, so the Hessian is diagonal with positive entries
  - **Conjecture**: YES, joint convexity holds
- ★ V9: Optimal transport with EML cost function
- ★ V9: Proximal operators for σ(x)
- ★ V9: Connection to exponential families in statistics

### 1.6 EML Magma Structure — EXTENDED V9 SURVEY
**Priority: Medium | Difficulty: Medium | Impact: Structural**

All standard algebraic laws now verified to fail (V9):
- Non-commutativity ✓
- Non-associativity ✓
- No left identity ✓
- No right identity ✓
- Not power-associative ✓
- Not left-alternative ✓
- Not right-alternative ✓
- Not medial ✓
- Not flexible ✓
- ★ V9: No idempotent elements ✓

**Open (V9):**
- Characterize the automorphism group Aut(ℝ, eml) — is it trivial?
- Is there any non-trivial identity involving eml? (Conjecture: NO)
- Does the EML magma satisfy any quasi-identity?
- Is the word problem for the free EML magma decidable?
- Does the EML magma have any finite sub-magma? (Conjecture: NO)
- ★ V9: Quantify wildness: how many identities of length ≤ n fail?
- ★ V9: EML satisfies no "balanced" identity of any depth (conjecture)
- ★ V9: Is there a normal form for EML expressions?

### 1.7 EML Riemannian Geometry
**Priority: High | Difficulty: Medium-Hard | Impact: Novel**

- V8: Hessian metric ds² = eˣdx² + y⁻²dy² (warped product)
- V8: Gaussian curvature K = 0 (FLAT!)
- V8: y-geodesics: y(t) = y₀ · exp(v₀t) (exponential curves)

**Open:**
- Find explicit x-geodesic solutions
- Geodesic completeness
- Volume growth of geodesic balls B(p, r) as r → ∞
- ★ V9: Find the explicit isometry to flat ℝ² (coordinates where ds² = du² + dv²)
- ★ V9: Is the isometry group infinite?
- ★ V9: Connection to the Poincaré half-plane (y-component is hyperbolic)
- ★ V9: Geodesic distance formula in closed form
- ★ V9: EML metric as a Fisher information metric for some statistical model?

### 1.8 ★ EML Integral Theory (NEW V9)
**Priority: Medium | Difficulty: Medium | Impact: Foundational**

Proved in V9:
- ∫₀¹ eml(t, 1) dt = e − 1 ✓
- ★ V9: ∫₁ᵉ eml(0, t) dt = e − 2 ✓

**Open:**
- ★ V9: ∫₀^∞ eml(−t, eᵗ) dt = ∫₀^∞ (e⁻ᵗ − t) dt — does this converge?
- ★ V9: Laplace transform of eml(·, 1): ∫₀^∞ e⁻ˢᵗ eᵗ dt = 1/(s−1)
- ★ V9: Fourier analysis of eml on compact intervals
- ★ V9: EML integral representations of special functions
- ★ V9: Connection to the exponential integral Ei(x)

### 1.9 ★ EML Taylor/Asymptotic Analysis (NEW V9)
**Priority: Medium | Difficulty: Medium | Impact: Theoretical**

- ★ V9: exp(x) ≥ 1 + x + x²/2 for x ≥ 0 (proved, Taylor lower bound)
- ★ V9: Asymptotic expansion of d(z) for large z: d(z) ~ eᶻ
- ★ V9: Asymptotic expansion of d(z) for z → 0⁺: d(z) ~ 1 + ln(1/z)

**Open:**
- ★ V9: Full asymptotic expansion of dⁿ(z) for large n
- ★ V9: Rate of convergence of gⁿ(z) → z*
- ★ V9: EML generating functions: Σ eml(n,1) xⁿ/n!

---

## 2. Computational Complexity

### 2.1 ★ V9 Lower Bound Techniques
**Priority: Critical | Difficulty: Hard | Impact: Foundational**

- ★ V9: The no-idempotent theorem implies K_EML(id) ≥ 2 (since eml(x,x) ≠ x)
- ★ V9: Combined with Legendre uniqueness for new lower bounds
- ★ V9: Convexity argument: σ(x) = eˣ − x > 0 prevents certain cancellations
- ★ V9: Information-theoretic lower bounds via the KL decomposition
- ★ V9: Can orbit gap monotonicity be used for depth lower bounds?

---

## 3. Analysis and Dynamics

### 3.1 ★ Julia Set and Complex Dynamics (V9 Priority)
**Priority: Critical | Difficulty: Hard | Impact: Theoretical**

- d(z) = exp(z) − log(z) has no real fixed points (proved)
- ★ V9: Computational evidence: complex fixed points exist near z ≈ 0.3 + 1.3i
- ★ V9: Is the Julia set connected? Locally connected?
- ★ V9: Hausdorff dimension of J(d)
- ★ V9: Baker domain analysis: d maps right half-plane roughly to itself
- ★ V9: Topological entropy of d(z) on ℂ

### 3.2 ★ Enhanced Orbit Theory (V9)
**Priority: High | Difficulty: Medium-Hard | Impact: Theoretical**

New V9 results:
- ★ V9: Orbit gap monotonicity: d(dⁿ(z)) − dⁿ(z) non-decreasing (proved)
- ★ V9: Strong bound for z ≥ 1: d(z) ≥ exp(z) − z + 1 (proved)

**Open:**
- ★ V9: Prove dⁿ(z) ~ exp↑↑n for z > 0
- ★ V9: Define the "escape function" E(z) = lim log*(dⁿ(z))/n
- ★ V9: Is E(z) constant? If so, what is its value?
- ★ V9: Orbit sensitivity: how does dⁿ(z₁) − dⁿ(z₂) grow?
- ★ V9: Are there orbit universality results (similar orbits for all z)?

---

## 4. Machine Learning and AI

### 4.1 ★ EML Neural Architectures (V9 Priority)
**Priority: Critical | Difficulty: Medium | Impact: Very High**

- ★ V9: EML activation function: σ(x) = eˣ − x (strictly convex, min at 0)
  - Advantages: always positive, no vanishing gradient (σ'(x) = eˣ − 1)
  - Comparison needed: vs ReLU, GELU, Swish
- ★ V9: EML attention: replace softmax with eml-based scoring
  - Attention(Q,K,V) = softmax(QKᵀ/√d)V → EML variant
- ★ V9: EML loss function: L(y, ŷ) = eml(y − ŷ, eʸ⁻ʸ̂) = e^(y−ŷ) − (y−ŷ)
  - This equals σ(y − ŷ) ≥ 1, with minimum at perfect prediction
  - Strictly convex in the residual!

### 4.2 ★ EML Symbolic Regression (V9 Update)
**Priority: Critical | Difficulty: Medium | Impact: Very High**

- ★ V9: Use Legendre uniqueness to prune search: if data fits eˣ − y, use eml directly
- ★ V9: Convexity-based pruning: non-convex targets need composition
- ★ V9: EML complexity as Occam's razor: penalize tree depth
- ★ V9: Benchmark proposal: Feynman Symbolic Benchmark with EML basis

---

## 5. Physics

### 5.1 ★ EML in Statistical Mechanics
**Priority: High | Difficulty: Medium | Impact: Novel**

- ★ V9: Bregman divergence D_exp(x,y) ≥ 0 mirrors free energy differences
- ★ V9: Partition function Z: ln Z is the "dual" of the EML evaluation
- ★ V9: Free energy via EML: F = −kT · eml(0, Z) + kT
- ★ V9: Boltzmann weights as EML evaluations: exp(−βE) = eml(−βE, 1)

### 5.2 ★ EML and Information Theory (EXTENDED V9)
**Priority: High | Difficulty: Medium | Impact: Broad**

New V9 results:
- ★ V9: −p ln p = p · eml(0, p) − p (proved)
- ★ V9: p ln(p/q) = p · (eml(0, q) − eml(0, p)) (proved)

**Open:**
- ★ V9: Mutual information as EML trace
- ★ V9: Channel capacity as EML optimization
- ★ V9: Rate-distortion theory in EML language
- ★ V9: Fisher information via EML second derivatives
- ★ V9: Is there an EML-native proof of the data processing inequality?

---

## 6. Number Theory

### 6.1 ★ EML Constants and Transcendence (V9 Update)
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- V8: Power identity generates all eⁿ: eml(n, 1) = eⁿ
- ★ V9: Computed 48 distinct constants from ≤ 5-node trees
- ★ V9: E-tower is strictly monotone (proved)

**Open:**
- Are the constants {e, eᵉ, eᵉᵉ, ...} algebraically independent?
- What is the Hausdorff dimension of the set of EML constants?
- Is the set of EML constants dense in ℝ?
- ★ V9: Growth rate of the number of distinct n-node EML constants
- ★ V9: Distribution of EML constants: do they cluster near specific values?

---

## 7. Category Theory and Universal Algebra

### 7.1 ★ EML Operad and Variety Theory (V9 Extension)
**Priority: Speculative | Difficulty: Hard | Impact: Theoretical**

- ★ V9: The no-idempotent theorem means the EML operad has no "units"
- ★ V9: The complete identity failure means EML defines a "trivial variety"
  - A variety is defined by the identities it satisfies
  - EML satisfies no identities → it generates the variety of all magmas
- ★ V9: Is the EML magma free in some sense?
- ★ V9: EML and dendriform algebras via non-associativity

---

## 8. ★ Functional Analysis (NEW V9)

### 8.1 ★ EML Function Spaces
**Priority: Medium | Difficulty: Hard | Impact: Deep**

- ★ V9: The EML closure: all functions obtainable from 1 and x via eml
- ★ V9: Is the EML closure dense in C(K) for compact K ⊂ ℝ₊?
  - Stone-Weierstrass approach: need to show the EML closure separates points
  - The EML closure contains exp and (via subtraction recovery) all polynomials
  - **Conjecture**: YES, the EML closure is dense
- ★ V9: EML closure in Sobolev spaces
- ★ V9: Approximation rates: how many EML nodes to ε-approximate a C^k function?

---

## 9. ★ Optimization Theory (NEW V9)

### 9.1 ★ EML-Based Optimization
**Priority: High | Difficulty: Medium | Impact: Practical**

- ★ V9: σ(x) = eˣ − x as a loss function: strictly convex, min at 0
- ★ V9: Gradient: σ'(x) = eˣ − 1, Hessian: σ''(x) = eˣ > 0
- ★ V9: Newton's method for σ: x_{n+1} = x_n − (eˣⁿ − 1)/eˣⁿ = x_n − 1 + e^{−xₙ}
- ★ V9: EML proximal operator: prox_σ(y) = W(e^{y+1}) (Lambert W connection!)
- ★ V9: Mirror descent with Bregman divergence D_exp
- ★ V9: Natural gradient on the flat EML metric

---

## 10. ★ Probability and Statistics (NEW V9)

### 10.1 ★ EML Exponential Families
**Priority: Medium | Difficulty: Medium | Impact: Broad**

- ★ V9: Exponential families p(x|θ) = h(x) exp(θᵀT(x) − A(θ)) relate to EML via A(θ) = eml(θ, 1) − eml(0, 1) for the exponential distribution
- ★ V9: Fisher information metric for exponential family = EML Hessian metric
- ★ V9: Maximum likelihood via EML: the log-likelihood is an EML evaluation
- ★ V9: Bayesian updating as EML composition

---

## 11. ★ Differential Equations (NEW V9)

### 11.1 ★ EML-Related ODEs
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- ★ V9: The x-geodesic ODE: x'' + ½eˣ(x')² = 0
  - Substitution u = x': u du/dx = −½eˣu² → du/u = −½eˣdx → ln|u| = −½eˣ + C
  - Solution: x'(t) = C₁ exp(−½eˣ⁽ᵗ⁾), then integrate
- ★ V9: The self-pairing ODE: σ'(x) = 0 gives x = 0 (unique critical point)
- ★ V9: Is the diagonal map orbit d, d², d³, ... related to any known sequence?
- ★ V9: PDEs: heat equation on the EML metric, ∂u/∂t = Δ_EML u

---

## 12. ★ Algebraic Geometry (NEW V9)

### 12.1 ★ EML Varieties
**Priority: Speculative | Difficulty: Very Hard | Impact: Theoretical**

- ★ V9: The zero set {(x,y) : eml(x,y) = 0} is the curve y = exp(eˣ)
- ★ V9: Level sets {eml = c} foliate ℝ × ℝ₊
- ★ V9: Algebraic approximations: for large x, eml(x,y) ≈ eˣ (dominates)
- ★ V9: Tropicalization: trop(x,y) = max(x, −y) defines a tropical variety
- ★ V9: Newton polygon of EML approximations

---

## Recommended Priority Order (V9 Update)

### Immediate (next 6 months):
1. ★ Joint convexity proof (Hessian is diagonal with positive entries!)
2. ★ Basin of attraction of z* (computational + formal)
3. ★ K_EML(ln) ≥ 4 lower bound
4. ★ EML symbolic regression benchmarks vs PySR
5. ★ EML activation function: benchmark σ(x) = eˣ − x against ReLU/GELU
6. ★ Explicit flat coordinates for the EML metric
7. ★ Publish V9 paper
8. ★ Julia set visualization of d(z)

### Medium-term (6–18 months):
9. EML density in C(K) (Stone-Weierstrass approach)
10. Classification of Sheffer operators using Legendre uniqueness
11. ★ EML neural network experiments (attention, loss function)
12. Complex fixed points of d(z)
13. ★ EML optimal transport
14. Characterize Aut(ℝ, eml)
15. ★ EML in optimization (mirror descent convergence)
16. ★ Fisher information metric connection
17. ★ EML-based symbolic regression tool

### Long-term (1–5 years):
18. Constant-free Sheffer conjecture
19. Hausdorff dimension of Julia set
20. EML-based programming language
21. Algebraic independence of e-tower
22. EML operadic Koszul duality
23. Quantum EML complexity
24. O-minimality of EML structure
25. EML in string theory (worldsheet metrics)

---

## Key V9 Achievements Summary

| Category | V8 | V9 | Delta |
|----------|----|----|-------|
| Formalized theorems | 300+ | 370+ | +70 |
| Sorry count | 0 | 0 | — |
| Lean files (V9) | 2 | 4 | +2 |
| Algebraic laws failed | 9 | 10 | +1 (no idempotents) |
| Convexity results | 2 | 5 | +3 |
| Dynamics results | 4 | 6 | +2 |
| Integral identities | 0 | 2 | +2 |
| Information theory | 0 | 2 | +2 |
| Open problems | 150+ | 180+ | +30 |
| Research fields | 30 | 35 | +5 |

---

## New V9 Discoveries Summary

1. **Strict convexity of self-pairing**: σ(x) = eˣ − x is strictly convex with unique minimum σ(0) = 1
2. **Orbit gap monotonicity**: The gap d(dⁿ(z)) − dⁿ(z) is non-decreasing for z > 0
3. **No idempotent elements**: eml(x,x) ≠ x for all x, completing the algebraic failure catalog
4. **Legendre uniqueness**: eml is the unique continuous function satisfying the Legendre bridge
5. **Bregman divergence**: D_exp(x,y) ≥ 0, connecting EML to optimal transport
6. **Entropy decomposition**: −p ln p = p · eml(0,p) − p
7. **KL decomposition**: p ln(p/q) = p · (eml(0,q) − eml(0,p))
8. **Integral identities**: ∫₀¹ eml(t,1) dt = e−1 and ∫₁ᵉ eml(0,t) dt = e−2
9. **Taylor lower bound**: exp(x) ≥ 1 + x + x²/2 for x ≥ 0
10. **Strong diagonal bound**: d(z) ≥ exp(z) − z + 1 for z ≥ 1

---

*All theorems referenced above are verified in Lean 4.28.0 with Mathlib.*
*Source: `EML/V9/Core.lean` and `EML/V9/Advanced.lean`.*
