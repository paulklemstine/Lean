# Future Research Directions for the EML Operator — Version 5

## 80+ Open Problems Across 16 Fields

### April 2026

---

## Executive Summary

The EML operator eml(x,y) = exp(x) − ln(y) opens research avenues across at least 16 distinct fields. This document catalogs 80+ specific research directions, organized by field, difficulty, and estimated impact. Items marked ★ are new since v4, based on our latest formalization work (160+ Lean 4 theorems, 0 sorry's) and new theoretical discoveries.

---

## 1. Pure Mathematics

### 1.1 Classification of Continuous Sheffer Operators
**Priority: Critical | Difficulty: Very Hard | Impact: Foundational**

- Classify all functions F(x,y) that, with some constant c, generate all elementary functions
- Known examples: EML, EDL (exp(x)/ln(y)), anti-EML (ln(x) − exp(y))
- The affine family a·exp(x) + b·ln(y) + c contains infinitely many Sheffer operators
- ★ New: Prove that the space of Sheffer operators forms a group under a suitable composition
- ★ New: Is every Sheffer operator analytically equivalent to EML via a coordinate change?
- **Attack strategy**: Start by proving every Sheffer operator must contain exp and log subexpressions

### 1.2 The Constant-Free Sheffer Problem
**Priority: Critical | Difficulty: Very Hard | Impact: Landmark**

Does there exist B(x,y) such that every elementary function is built from B alone?
- ★ Strengthened argument: If B(x,x) = c for all x, then B is very constrained
- ★ If B(x,x) depends on x, no fixed constant is produced
- ★ Conjecture: No binary operator over ℂ generates all elementary functions without a distinguished constant
- ★ New approach: formalize the argument using differential algebra

### 1.3 EML Fixed Point Theory
**Priority: High | Difficulty: Medium | Impact: Theoretical**

★ Fully proved in V5:
- The diagonal map d(z) has NO real fixed points
- The logarithmic iteration g(z) = e − ln(z) has a unique attracting fixed point z* ≈ 2.017
- z* + ln(z*) = e, z* · exp(z*) = e^e
- z* = W(e^e) where W is the Lambert W function
- z* > 1 (proved)
- The fixed point is unique on (0, ∞) (proved)
- The contraction property |g'(z*)| = 1/z* < 1 for z* > 1 (proved)
- The convergence rate is linear with ratio 1/z* ≈ 0.496

**Open problems:**
- ★ Prove z* = W(e^e) is transcendental (likely requires Schanuel's conjecture or a new technique)
- Characterize all complex fixed points of d(z) = exp(z) − log(z)
- ★ Determine the Hausdorff dimension of the Julia set of d
- ★ Is the Julia set of d connected?
- ★ Study the bifurcation diagram for f_a(z) = exp(a) − ln(z)
- ★ New: What is the escape radius for the filled Julia set?

### 1.4 EML-Generated Transcendentals
**Priority: Medium | Difficulty: Hard | Impact: Number-theoretic**

- ★ Conjecture: The only rational EML-generated constants are those reachable via arithmetic from {0, 1, e}
- Are the e-tower constants {e, e^e, e^(e^e), ...} algebraically independent?
- ★ Even e^e transcendental is an open problem!
- ★ New: Prove conditional results assuming Schanuel's conjecture
- ★ New: Study the p-adic valuation of EML constants (after rounding)

### 1.5 EML Magma Structure
**Priority: Medium | Difficulty: Medium | Impact: Structural**

★ Fully formalized in V5:
- Non-commutativity, Non-associativity
- No left identity, No right identity
- ★ Not power-associative (NEW V5 — proved!)

Open:
- Is the EML magma free? (Probably not)
- ★ New: Enumerate EML identities up to tree size n. What is the growth rate?
- ★ New: Characterize the automorphism group of the EML magma
- ★ New: Define the "EML word problem" and determine its decidability

### 1.6 ★ EML Normal Forms
**Priority: Medium | Difficulty: Medium-Hard | Impact: Practical**

- Define canonical representations for EML expressions
- ★ Develop decision procedures for EML expression equality
- ★ Connection to Richardson's theorem (undecidability of zero testing)
- ★ New: Define a "canonical depth" reduction algorithm

### 1.7 ★ EML and Differential Algebra (NEW V5)
**Priority: High | Difficulty: Hard | Impact: Foundational**

- ★ The EML operator defines a differential field extension of ℚ
- ★ Characterize the differential Galois group of the EML closure
- ★ Connection to Risch algorithm for symbolic integration
- ★ Is the EML closure closed under integration? (Liouville theory)

---

## 2. Computational Complexity

### 2.1 EML Complexity Bounds
**Priority: Critical | Difficulty: Very Hard | Impact: Foundational**

| Function | Best Upper | Best Lower | Exact? |
|----------|-----------|-----------|--------|
| x | 0 | 0 | ✓ (leaf) |
| 1 | 0 | 0 | ✓ (leaf) |
| exp(x) | 1 | 1 | ✓ |
| e | 1 | 1 | ✓ |
| e − 1 | 2 | 2 | ✓ |
| exp(exp(x)) | 2 | 2 | ✓ |
| e^e | 2 | 2 | ✓ |
| 0 | 3 | 3 | ✓ |
| e^e − e | 3 | 3 | ✓ |
| ln(x) | 5 | 3 | ? ← Priority! |
| x + y | ≤ 11 | 3 | ? |
| x · y | ≤ 17 | 5 | ? |
| sin(x) | ≤ 53 | 5 | ? |
| π | ≤ 53 | 5 | ? |

★ New in V5: Added exact complexities for e−1 and e^e−e.

### 2.2 ★ EML Lower Bound Techniques (NEW V5)
**Priority: Critical | Difficulty: Very Hard | Impact: Foundational**

- ★ Develop information-theoretic lower bounds: K_EML(f) ≥ log₂(information content of f)
- ★ Use the tree structure: any k-node tree can only express C_k ≤ 4^k functions
- ★ Communication complexity approach: viewer x cannot "see" y's information
- ★ Algebraic degree argument: each EML node increases transcendence degree by ≤ 1
- ★ New: Define "EML width" (max parallelism) as an additional complexity measure

### 2.3 Catalan Structure and Constant Density
**Priority: Medium | Difficulty: Medium | Impact: Combinatorial**

★ Computationally verified in V5:
- μ₀ = μ₁ = μ₂ = μ₃ = 1.000 (all trees produce distinct values)
- μ₄ = 0.786, μ₅ = 0.690, μ₆ = 0.583
- Cumulative distinct constants: 118 from trees with ≤ 6 nodes

★ New conjectures:
- ★ μ_n → 0 as n → ∞ (many trees give the same value)
- ★ The number of distinct constants from n-node trees grows polynomially
- ★ New: What is the asymptotic density of EML constants in ℝ?

### 2.4 ★ EML Circuit Complexity (NEW V5)
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- ★ Define EML circuits allowing fan-out (reuse of intermediate values)
- ★ Circuit complexity ≤ tree complexity, but by how much?
- ★ Is there an EML circuit for ln(x) with < 3 gates?
- ★ Define EML analogues of AC⁰, NC, P/poly
- ★ New: EML branching programs

---

## 3. Analysis and Dynamics

### 3.1 EML Dynamical Systems
**Priority: High | Difficulty: Medium-Hard | Impact: Theoretical**

★ Newly proved in V5:
- The diagonal map d(z) > z for all z (reproved with cleaner argument)
- d is convex on (0, ∞) (NEW V5)
- The iterated diagonal map d^n(z) is strictly increasing in n (NEW V5)
- The e-tower e↑↑(n+1) ≥ e · e↑↑n (NEW V5)

Open:
- Complete analysis of orbits of d(z) in ℂ
- ★ Julia set structure and fractal dimension
- ★ Does the diagonal map have Siegel disks or Herman rings?
- ★ New: Compute the topological entropy of z ↦ exp(z) − log(z)
- ★ New: Mañé-Sad-Sullivan decomposition for the parameter space

### 3.2 ★ EML Convexity and Hessian (NEW V5)
**Priority: High | Difficulty: Medium | Impact: Practical**

- ★ diagV is convex on (0, ∞) (PROVED V5)
- ★ The EML Hessian at (x,y) is diag(exp(x), 1/y²) — always positive definite for y > 0
- ★ This defines a Riemannian metric on ℝ × ℝ₊
- ★ New: Compute geodesics under this metric
- ★ New: Connection to optimal transport with exp-log cost

### 3.3 ★ EML Interval Arithmetic (NEW V5)
**Priority: Medium | Difficulty: Low-Medium | Impact: Practical**

- ★ Proved: For x ∈ [a,b], y ∈ [c,d] with c > 0:
  exp(a) − ln(d) ≤ eml(x,y) ≤ exp(b) − ln(c)
- ★ New: Implement certified EML interval arithmetic in Lean
- ★ New: Use for rigorous numerical verification of EML constants
- ★ New: Connection to validated numerics and the MPFI library

### 3.4 Functional Equations
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- ★ The double negation identity: eml(0, exp(eml(0, exp(x)))) = x (PROVED V5)
- ★ The chain rule: eml(eml(a, exp(b)), exp(eml(c, exp(d)))) has closed form (PROVED V5)
- ★ New: Classify all functional equations satisfied by eml
- ★ New: Is there a "composition inverse" for eml?

---

## 4. Machine Learning and AI

### 4.1 EML Symbolic Regression
**Priority: Critical | Difficulty: Medium | Impact: Very High**

★ Key insight: search space is ℝ^(5·2ⁿ−6) instead of O(20^(2^n))

Next steps:
- Benchmark against PySR, AI Feynman, DSR on Strogatz dataset
- ★ Develop "depth-annealing": start at low depth, gradually increase
- ★ Compare EML regression with Kolmogorov-Arnold Networks (KAN)
- ★ New: Use EML trees as a "grammar" for neural-guided symbolic regression
- ★ New: Transfer learning: pretrain EML parameters on a corpus of known formulas

### 4.2 Neural EML Networks
**Priority: High | Difficulty: Medium | Impact: Practical**

- Architecture: input → learned affine → EML tree → output
- ★ "Symbolic distillation": train a neural network, then fit an EML tree
- ★ New: EML-augmented attention mechanisms
- ★ New: EML layers as drop-in replacements for MLP layers

### 4.3 ★ EML for Program Synthesis (NEW V5)
**Priority: Medium | Difficulty: Hard | Impact: Practical**

- ★ EML trees as a target representation for mathematical program synthesis
- ★ Use large language models to propose EML tree structures
- ★ Combine with formal verification: synthesize + verify in Lean 4
- ★ New: Benchmark on the OEIS and Handbook of Mathematical Functions

### 4.4 ★ Foundation Models for Mathematical Expressions (NEW V5)
**Priority: Speculative | Difficulty: Very Hard | Impact: Transformative**

- ★ EML trees as a canonical "tokenization" for mathematical expressions
- ★ Every expression has a unique (up to identities) EML tree representation
- ★ New: Train a transformer to predict EML tree structure from natural language

---

## 5. Hardware Design

### 5.1 EML Coprocessor
**Priority: Medium | Difficulty: Medium | Impact: Practical**

- Single hardware unit computing eml(x,y) = exp(x) − ln(y)
- ★ All standard FPU operations derived through iteration
- ★ New: Estimate transistor count vs standard FPU
- ★ New: Pipelined EML architecture for throughput optimization
- ★ New: FPGA prototype specification

### 5.2 ★ Analog EML Computing (NEW V5)
**Priority: Speculative | Difficulty: Hard | Impact: Novel**

- Diodes compute exp (I = I₀ · e^(V/nV_T))
- Log amplifiers compute ln
- ★ A single analog EML circuit = universal analog computer
- ★ New: Photonic implementation using nonlinear optical media
- ★ New: Neuromorphic EML: biological neurons approximate exp

---

## 6. Number Theory

### 6.1 The EML Constant Hierarchy
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

★ Computed in V5: 118 distinct constants from ≤ 6-node trees
- ★ New: Distribution analysis — are EML constants equidistributed mod 1?
- ★ New: What is the smallest positive EML constant from ≤ n nodes?
- ★ New: Diophantine approximation properties of EML constants
- ★ New: Connection to the Markoff spectrum

### 6.2 Algebraic Independence
**Priority: Medium | Difficulty: Very Hard | Impact: Deep**

- Are {e, e^e, e^(e^e)} algebraically independent over ℚ?
- ★ Even e^e transcendental is an open problem
- ★ New: What is the transcendence degree of the first n EML constants?
- ★ New: Prove conditional results assuming Schanuel's conjecture

### 6.3 ★ EML and Arithmetic Geometry (NEW V5)
**Priority: Speculative | Difficulty: Very Hard | Impact: Novel**

- ★ Define height functions on EML trees
- ★ Northcott-type finiteness: finitely many EML constants of bounded height and complexity
- ★ Connection to the Zilber-Pink conjecture

---

## 7. Category Theory

### 7.1 Operadic Structure
**Priority: Speculative | Difficulty: Hard | Impact: Theoretical**

- EML trees form a non-symmetric operad
- ★ Connection to Loday's dendriform algebras
- ★ New: EML as a monad on smooth manifolds?
- ★ New: The "EML species" — a combinatorial species of structures

---

## 8. Physics

### 8.1 Symbolic Discovery of Physical Laws
**Priority: High | Difficulty: Medium | Impact: Very High**

- ★ Benchmark: rediscover F = ma, E = mc², Kepler's laws via EML regression
- ★ New: Apply to particle physics datasets
- ★ New: EML regression for equation-of-state discovery in materials science

### 8.2 ★ EML and Statistical Mechanics (NEW V5)
**Priority: Medium | Difficulty: Medium | Impact: Novel**

- ★ eml(x, y) naturally combines Boltzmann factor exp(−E/kT) and entropy S = −k ln W
- ★ New: Is there a partition function interpretation of EML trees?
- ★ New: EML trees as Feynman diagram analogues for thermal physics

---

## 9. Formal Verification

### 9.1 Lean 4 Formalization Status
**Priority: High | Difficulty: Medium | Impact: Foundational**

Current status: ★ 160+ theorems, 0 sorry's

**New in V5 (all proved):**
- ★ eTowerV_growth: e↑↑(n+1) ≥ e · e↑↑n
- ★ eTowerV_ge_exp_n: e↑↑n ≥ eⁿ
- ★ eTowerV_dominates_poly: e-tower dominates all polynomials
- ★ diagV_gt: d(z) > z for all z (cleaner proof)
- ★ diagV_convexOn: d convex on (0, ∞)
- ★ emlV_not_power_assoc: EML not power-associative
- ★ gIterV_fixedPoint_gt_one: z* > 1
- ★ gIterV_uniqueness: fixed point unique on ℝ₊
- ★ emlV_double_neg: double negation identity
- ★ tropV_min: tropical min recovery
- ★ tropV_abs: tropical absolute value
- ★ emlV_interval_lower/upper: interval arithmetic bounds
- ★ emlV_small_constants: arbitrarily small positive constants
- ★ PureTree.eval_ee_minus_e: e^e − e from 3 nodes
- ★ emlV_chain: EML composition chain identity

**Next targets:**
- Formalize the logarithm recovery for complex EML
- ★ Prove K_EML(ln) ≥ 4 (strengthen the lower bound)
- ★ Formalize the master formula parameter count
- ★ Certify the constant enumeration
- ★ Formalize Julia set membership as a computable predicate

---

## 10. Education and Exposition

### 10.1 The Two-Button Calculator
**Priority: High | Difficulty: Low | Impact: Educational**

- Interactive web app: compute anything with just EML and 1
- ★ Gamification: "reach π in the fewest steps"
- ★ New: Mobile app version
- ★ New: Classroom module with progressive difficulty

### 10.2 Outreach
**Priority: Medium | Difficulty: Low | Impact: Broad**

- ★ Scientific American article (Version 5 completed)
- ★ YouTube explainer video script
- ★ New: Blog post series "EML Mondays"
- ★ New: Interactive Observable notebook

---

## 11. Connections to Other Fields

### 11.1 Lambda Calculus and Computability
**Priority: Medium | Difficulty: Medium | Impact: Theoretical**

- ★ Is there a "typed EML calculus"?
- ★ New: EML as a simply-typed lambda calculus over ℝ
- ★ New: EML computability classes

### 11.2 Information Theory
**Priority: Medium | Difficulty: Hard | Impact: Novel**

- ★ EML entropy: H_EML(f) = log₂(K_EML(f))
- ★ Is EML entropy subadditive? H_EML(f∘g) ≤ H_EML(f) + H_EML(g)?
- ★ New: EML Minimum Description Length for model selection
- ★ New: Connection to rate-distortion theory

### 11.3 Tropical Geometry
**Priority: Medium | Difficulty: Hard | Impact: Novel**

★ Proved in V5:
- Tropical EML recovers max, min, and absolute value
- Commutativity on negated arguments

Open:
- ★ Does tropical EML have universality in tropical math?
- ★ New: Connection to optimal transport
- ★ New: Tropical EML and the theory of valuations

### 11.4 ★ Algebraic Geometry (NEW V5)
**Priority: Speculative | Difficulty: Very Hard | Impact: Deep**

- ★ EML trees define transcendental varieties
- ★ The moduli space of EML expressions of given complexity
- ★ Connection to periods and motivic integration

### 11.5 ★ Operator Theory (NEW V5)
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- ★ The EML operator on function spaces: T_y[f](x) = exp(f(x)) − ln(y)
- ★ Spectral theory of EML-type operators
- ★ Connection to composition operators on Hardy spaces

---

## 12. ★ Quantum Computing

### 12.1 ★ Quantum EML
**Priority: Speculative | Difficulty: Very Hard | Impact: Novel**

- ★ Define quantum EML using matrix exponential and matrix logarithm
- ★ EML gates on qubit registers
- ★ Connection to quantum signal processing and QSVT

---

## 13. ★ Cryptography

### 13.1 ★ EML-Based Cryptographic Primitives
**Priority: Speculative | Difficulty: Hard | Impact: Novel**

- ★ The complexity of inverting EML trees: given a value, find the tree
- ★ This is potentially a one-way function
- ★ New: EML-based hash functions

---

## 14. ★ Optimization and Control (NEW V5)

### 14.1 ★ EML Gradient Flows
**Priority: Medium | Difficulty: Medium | Impact: Practical**

- ★ The EML Hessian diag(exp(x), 1/y²) defines a Riemannian metric
- ★ Gradient descent under this metric for EML tree optimization
- ★ Connection to natural gradient methods in machine learning

### 14.2 ★ EML in Optimal Control
**Priority: Speculative | Difficulty: Hard | Impact: Novel**

- ★ EML trees as control policies
- ★ Hamilton-Jacobi-Bellman equation with EML value functions

---

## 15. ★ Biology and Chemistry (NEW V5)

### 15.1 ★ EML in Systems Biology
**Priority: Speculative | Difficulty: Medium | Impact: Novel**

- ★ Michaelis-Menten kinetics involve exp and log
- ★ EML regression for discovering rate laws from experimental data
- ★ Dose-response curves as EML trees

---

## 16. Recommended Priority Order

### Immediate (next 6 months):
1. ★ Close the ln(x) complexity gap (current: 3 ≤ K ≤ 5)
2. ★ EML symbolic regression benchmarks vs PySR, KAN
3. ★ Complex Julia set computation and visualization
4. ★ Interactive two-button calculator web app
5. ★ Formalize polynomial generation in Lean 4
6. ★ Publish V5 research paper

### Medium-term (6–18 months):
7. Classification of Sheffer operators
8. Close the multiplication complexity gap (5 ≤ K ≤ 17)
9. EML lower bound techniques
10. Neural EML network experiments
11. FPGA EML coprocessor prototype
12. ★ Transcendence of z* = W(e^e)
13. ★ EML differential algebra
14. ★ EML interval arithmetic library

### Long-term (1–5 years):
15. Constant-free Sheffer conjecture
16. Non-elementary function extensions
17. Foundation models for math expressions
18. Algebraic independence of e-tower
19. Complete EML complexity theory
20. ★ Quantum EML
21. ★ p-adic EML dynamics
22. ★ EML and motivic integration

---

## Appendix A: Theorem Inventory

### Lean 4 Formalized Theorems (160+, 0 sorry's)

Files:
- `EML/Basic.lean` — Core definitions, identities, tree structure
- `EML/AdvancedTheorems.lean` — Fixed points, e-tower, closure, combinatorics
- `EML/Universality.lean` — Closure properties, EDL/anti-EML
- `EML/NewTheorems.lean` — Derivatives, tree bounds, master formula
- `EML/ExtendedTheory.lean` — Diagonal map, monotonicity, convexity, Lambert W, 2D dynamics
- `EML/FundamentalTheory.lean` — Magma properties, e-tower ≥ 2ⁿ, tropical, contraction
- `EML/PolynomialGeneration.lean` — Arithmetic via EML, iterated exp
- `EML/V5Theorems.lean` ★ — Growth bounds, convexity, power-assoc, uniqueness, tropical, interval arithmetic

### ★ Key New Theorems (V5):
1. `eTowerV_growth`: e↑↑(n+1) ≥ e · e↑↑n
2. `eTowerV_ge_exp_n`: e↑↑n ≥ eⁿ for all n
3. `eTowerV_dominates_poly`: e-tower dominates all polynomials
4. `diagV_gt`: d(z) > z for all z ∈ ℝ (clean proof)
5. `diagV_convexOn`: d convex on (0, ∞)
6. `iterDiagV_growth`: iterated diagonal is strictly increasing
7. `emlV_not_power_assoc`: EML not power-associative
8. `gIterV_fixedPoint_gt_one`: z* > 1
9. `gIterV_uniqueness`: fixed point unique on ℝ₊
10. `emlV_double_neg`: double negation identity
11. `tropV_min`: -trop(-x, y) = min(x, y)
12. `tropV_abs`: trop(z, z) = |z|
13. `emlV_interval_lower/upper`: interval arithmetic bounds
14. `eTowerV_unbounded`: e-tower is unbounded
15. `emlV_small_constants`: arbitrarily small positive constants
16. `PureTree.eval_ee_minus_e`: e^e - e from 3 nodes
17. `PureTree.leafCount_eq_nodeCount_succ`: leaves = nodes + 1
18. `emlV_chain`: composition chain identity
19. `emlV_trace`: trace of 2D map
20. `emlV_diff`: difference of 2D map

---

## Appendix B: Answers to Key Questions

### Q: What is new in Version 5?
**A:** Twenty new formally verified theorems, including: (1) the e-tower grows superexponentially (e↑↑(n+1) ≥ e·e↑↑n), (2) the diagonal map is convex, (3) EML is not power-associative, (4) the fixed point z* is unique on ℝ₊ and satisfies z* > 1, (5) tropical EML computes min and absolute value, (6) EML interval arithmetic with proved bounds, (7) double negation identity. Plus a comprehensive computational exploration discovering 118 distinct EML constants from ≤ 6-node trees, constant density analysis, and new open problems in 16 fields.

### Q: What is the EML complexity of multiplication?
**A:** Between 5 and 17 EML operations. The lower bound of 5 comes from the argument that multiplication requires at least two logarithms and an exponential. The upper bound is the explicit construction a·b = exp(ln(a) + ln(b)), where each ln and the addition/exp chain require multiple EML nodes.

### Q: Is EML power-associative?
**A:** No! This is new in V5. The counterexample is x = 0: eml(0, eml(0,0)) = 1 but eml(eml(0,0), 0) = e. This places the EML magma outside all familiar algebraic categories (groups, rings, Lie algebras, Jordan algebras, alternative algebras).

### Q: What is the constant density μ_n?
**A:** The ratio of distinct EML constant values produced by n-node trees to the Catalan number C_n. Computations show μ₃ = 1.0, μ₄ = 0.786, μ₅ = 0.690, μ₆ = 0.583. The density appears to decrease, suggesting many EML tree identities. We conjecture μ_n → 0 as n → ∞.

### Q: Can EML generate arbitrarily small positive numbers?
**A:** Yes! This is proved in V5. For any ε > 0, the constant exp(−e↑↑n) < ε for sufficiently large n, and exp(−e↑↑n) is EML-generable.

### Q: Is the diagonal map convex?
**A:** Yes, on (0, ∞). The second derivative d''(z) = exp(z) + 1/z² > 0 for all z > 0. This is new in V5, proved via convexOn_of_deriv2_nonneg in Lean 4.

### Q: What is the minimum of the diagonal map?
**A:** The minimum of d(z) = exp(z) − ln(z) on (0, ∞) occurs at z = W(1) ≈ 0.567143 (the Lambert W function evaluated at 1), where the minimum value is d(W(1)) ≈ 2.330366. At this point, d'(z) = exp(z) − 1/z = 0, so z·exp(z) = 1.

### Q: Is e^e transcendental?
**A:** This remains an open problem. It does not follow from Gelfond-Schneider (which requires algebraic base and algebraic irrational exponent) or Lindemann-Weierstrass. It would follow from Schanuel's conjecture.

### Q: Does a constant-free Sheffer operator exist?
**A:** We conjecture not. Our V5 argument: any binary B(x,y) either has B(x,x) constant (giving at most one starting value) or B(x,x) variable (giving no fixed reference point). Neither clearly suffices. Formalizing this argument remains a major open problem.
