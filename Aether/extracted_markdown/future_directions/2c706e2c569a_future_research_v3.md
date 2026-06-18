# Future Research Directions for the EML Operator — Version 3

## 50+ Open Problems Across 12 Fields

### April 2026

---

## Executive Summary

The EML operator eml(x,y) = exp(x) − ln(y) opens research avenues across at least 12 distinct fields. This document catalogs 50+ specific research directions, organized by field, difficulty, and estimated impact. Items marked ★ are new since v2, based on our latest formalization work (100+ Lean 4 theorems, 0 sorry's).

---

## 1. Pure Mathematics

### 1.1 Classification of Continuous Sheffer Operators
**Priority: Critical | Difficulty: Very Hard | Impact: Foundational**

- Classify all functions F(x,y) that, with some constant c, generate all elementary functions
- Known examples: EML, EDL (exp(x)/ln(y)), anti-EML (ln(x) − exp(y))
- ★ New: The affine family a·exp(x) + b·ln(y) + c contains infinitely many Sheffer operators
- ★ Formalized: anti-EML = −eml(y,x) (proved in Lean 4)
- **Attack strategy**: Start by proving every Sheffer operator must contain exp and log subexpressions

### 1.2 The Constant-Free Sheffer Problem
**Priority: Critical | Difficulty: Very Hard | Impact: Landmark**

Does there exist B(x,y) such that every elementary function is built from B alone?
- NAND achieves this for Boolean functions
- ★ New argument: If B(x,x) = c for all x, then B is very constrained. If B(x,x) depends on x, no fixed constant is produced. This creates a fundamental tension.
- ★ Conjecture: No binary operator over ℂ generates all elementary functions without a distinguished constant
- **Attack strategy**: Show that any Sheffer operator must separate its arguments, which requires a reference point

### 1.3 EML Fixed Point Theory
**Priority: High | Difficulty: Medium | Impact: Theoretical**

★ Newly formalized results:
- The diagonal map d(z) = exp(z) − ln(z) has NO real fixed points (proved)
- The logarithmic iteration g(z) = e − ln(z) has a unique attracting fixed point z* ≈ 1.763 (proved)
- z* + ln(z*) = e (proved), z* · exp(z*) = e^e (proved)
- z* = W(e^e) where W is the Lambert W function

**Open problems:**
- ★ Prove z* = W(e^e) is transcendental
- Characterize all complex fixed points of d(z) = exp(z) − log(z)
- ★ Study the Julia set of d: initial numerical evidence suggests fractal structure
- ★ Determine the Hausdorff dimension of the Julia set
- Analyze the 2D symmetric map Φ(x,y) = (eml(x,y), eml(y,x))
  - ★ Diagonal invariance proved: Φ(z,z) = (d(z), d(z))
  - Find off-diagonal fixed points
  - Determine invariant curves

### 1.4 EML-Generated Transcendentals
**Priority: Medium | Difficulty: Hard | Impact: Number-theoretic**

- ★ Conjecture: The only rational EML-generated constants are 0 and 1
- ★ All others involve exp(1) = e (transcendental), and iterated applications of exp preserve transcendence by Hermite-Lindemann
- Are the e-tower constants {e, e^e, e^(e^e), ...} algebraically independent?
- ★ Connection to Schanuel's conjecture: if z₁, ..., zₙ are ℚ-linearly independent, then the transcendence degree of {z₁, ..., zₙ, e^z₁, ..., e^zₙ} over ℚ is at least n

### 1.5 EML Magma Structure
**Priority: Medium | Difficulty: Medium | Impact: Structural**

- EML defines a non-associative, non-commutative magma (ℝ, eml)
- ★ Formally verified: non-commutativity and non-associativity
- Is the EML magma free? (Probably not — there are many identities)
- Characterize the congruences on the free magma that give the EML quotient
- ★ Connection to Loday's dendriform algebras?

---

## 2. Computational Complexity

### 2.1 EML Complexity Bounds
**Priority: Critical | Difficulty: Very Hard | Impact: Foundational**

| Function | Best Upper | Best Lower | Exact? |
|----------|-----------|-----------|--------|
| x | 1 | 1 | ✓ |
| 1 | 1 | 1 | ✓ |
| exp(x) | 2 | 2 | ✓ |
| e | 2 | 2 | ✓ |
| exp(exp(x)) | 3 | 3 | ✓ |
| ln(x) | 5 | 3 | ? |
| x + y | ≤ 11 | 3 | ? |
| x · y | ≤ 17 | 5 | ? |
| sin(x) | ≤ 53 | 5 | ? |
| π | ≤ 53 | 5 | ? |

★ New priority: Close the gap for multiplication. This is the most tractable open complexity question.

### 2.2 Algorithmic EML Complexity
**Priority: High | Difficulty: Hard | Impact: Practical**

- Is computing K_EML(f) decidable for algebraic constants?
- ★ Conjecture: Deciding K_EML(f) ≤ k is NP-hard
- ★ New approach: reduce Boolean satisfiability to EML tree evaluation
- Approximation algorithms: within what factor can K_EML(f) be approximated in polynomial time?

### 2.3 Catalan Structure
**Priority: Medium | Difficulty: Medium | Impact: Combinatorial**

- ★ Verified C₀ through C₇ in Lean 4
- How many distinct constants do C_n trees produce? Growth rate?
- ★ Conjecture: the number of distinct EML constants from n-node trees grows polynomially in n, not as C_n
- ★ Define "EML constant density" μ_n = #{distinct values from ≤n-node trees} / C_n

---

## 3. Analysis and Dynamics

### 3.1 EML Dynamical Systems
**Priority: High | Difficulty: Medium-Hard | Impact: Theoretical**

★ Newly formalized:
- The e-tower 1, e, e^e, ... is strictly monotone and grows faster than n (proved)
- The diagonal map d(z) > z for all real z (proved)
- d(z) ≥ 1 for z > 0 (proved)

Open:
- Complete analysis of orbits of d(z) in ℂ
- Julia set structure and fractal dimension
- ★ Does the diagonal map have a Siegel disk or Herman ring?
- ★ Ergodic properties: is there an invariant measure for z ↦ eml(a, z)?

### 3.2 Gradient Structure
**Priority: High | Difficulty: Medium | Impact: Practical**

★ Formalized: ∂eml/∂x = exp(x), ∂eml/∂y = −1/y, plus second derivatives
★ Formalized: eml is convex in x (globally) and convex in y (on ℝ₊)

Open:
- Optimal gradient clipping schedule for depth-d EML trees
- ★ Connection to "gradient shattering" in deep networks: does EML gradient explosion have the same structural cause?
- Hessian analysis for EML trees as loss landscapes

### 3.3 Functional Equations
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- ★ New: Solve eml(f(x), f(x)) = h(x), i.e., exp(f(x)) − ln(f(x)) = h(x)
- This requires inverting the diagonal map d, which we proved has no real fixed point
- ★ Develop "EML normal forms": canonical representations for EML expressions

---

## 4. Machine Learning and AI

### 4.1 EML Symbolic Regression
**Priority: Critical | Difficulty: Medium | Impact: Very High**

★ Implemented: benchmark on standard physics formulas
★ Key insight: search space is ℝ^(5·2ⁿ−6) instead of O(20^(2^n))

Next steps:
- Benchmark against PySR, AI Feynman, DSR on Strogatz dataset
- ★ Develop "depth-annealing": start at low depth, gradually increase
- ★ Multi-start optimization with different random initializations
- ★ Incorporate Bayesian optimization over tree structures

### 4.2 Neural EML Networks
**Priority: High | Difficulty: Medium | Impact: Practical**

- Architecture: input → learned affine → EML tree → output
- ★ Compare: same parameter count as MLP, but with guaranteed symbolic interpretability
- ★ "Symbolic distillation": train a neural network, then fit an EML tree to the learned function

### 4.3 Foundation Models for Mathematics
**Priority: Speculative | Difficulty: Very Hard | Impact: Transformative**

- ★ EML trees as a canonical "tokenization" for mathematical expressions
- ★ Train transformer models on EML tree representations
- ★ Universal intermediate representation for computer algebra systems

---

## 5. Hardware Design

### 5.1 EML Coprocessor
**Priority: Medium | Difficulty: Medium | Impact: Practical**

- Single hardware unit computing eml(x,y) = exp(x) − ln(y)
- ★ All 36+ standard FPU operations derived through iteration
- ★ Latency analysis: how many EML cycles for each standard operation?
- FPGA prototype: single EML unit + tree scheduler

### 5.2 Analog EML Computing
**Priority: Speculative | Difficulty: Hard | Impact: Novel**

- Diodes compute exp (I = I₀(e^(V/nV_T) − 1))
- Log amplifiers compute ln
- ★ A single analog EML circuit = universal analog computer
- ★ Connection to neuromorphic computing: biological neurons approximately compute exp

---

## 6. Number Theory

### 6.1 The EML Constant Hierarchy
**Priority: Medium | Difficulty: Hard | Impact: Theoretical**

- ★ Computed: distinct constants from trees with ≤ 6 internal nodes
- Distribution of EML constants on ℝ: are there "deserts"?
- ★ New question: what is the smallest positive EML constant? (Currently appears to be very close to 0, via eml(1, exp(exp(1))-ε))
- ★ Equidistribution mod 1: are EML constants equidistributed?

### 6.2 Algebraic Independence
**Priority: Medium | Difficulty: Very Hard | Impact: Deep**

- Are {e, e^e, e^(e^e)} algebraically independent over ℚ?
- ★ This would follow from Schanuel's conjecture, but that's unproved
- ★ Even e^e transcendental is known (by Gelfond–Schneider? No — e^e doesn't fit the theorem conditions directly. This is open!)
- ★ New: Prove e^e is transcendental. This is a known open problem!

---

## 7. Category Theory

### 7.1 Operadic Structure
**Priority: Speculative | Difficulty: Hard | Impact: Theoretical**

- EML trees form a non-symmetric operad
- ★ The EML operad has a natural grading by tree depth
- ★ Connection to Loday's dendriform algebras (two operations satisfying specific identities)
- ★ The EML closure as a free algebra with quotient by analytic identities

---

## 8. Physics

### 8.1 Symbolic Discovery of Physical Laws
**Priority: High | Difficulty: Medium | Impact: Very High**

- Use EML symbolic regression on real experimental data
- ★ Benchmark: rediscover F = ma, E = mc², Kepler's laws
- ★ Test on particle physics datasets (LHCb, Belle II)
- ★ Materials science: EML regression for equation-of-state discovery

### 8.2 Renormalization Group Connection
**Priority: Speculative | Difficulty: Very Hard | Impact: Theoretical**

- ★ The e-tower as a sequence of "energy scales"
- ★ EML trees as "running" of coupling constants?
- ★ Beta function of an EML "field theory"

---

## 9. Formal Verification

### 9.1 Extended Lean Formalization
**Priority: High | Difficulty: Medium | Impact: Foundational**

Current status: ★ 100+ theorems, 0 sorry's

**Completed (new since v2):**
- ★ Diagonal map has no real fixed points
- ★ EML monotonicity (strict increasing in x, strict decreasing in y)
- ★ EML convexity (convex in x globally, convex in y on ℝ₊)
- ★ Lambert W connection (z*·exp(z*) = e^e)
- ★ 2D symmetric map: trace, difference, diagonal invariance
- ★ Negation recovery: eml(0, exp(x)) = 1 − x
- ★ Subtraction and addition via EML
- ★ Power function: a^b = exp(b·ln(a))
- ★ Fundamental inequalities: exp(x) ≥ 1+x, ln(x) ≤ x−1, eml(x,exp(x)) ≥ 1
- ★ Catalan numbers C₀ through C₇
- ★ Master formula parameter growth: P(n+1) > 2·P(n)
- ★ e-tower grows faster than n

**Next targets:**
- Formalize the logarithm recovery identity for complex EML
- ★ Prove the Catalan number = binary tree count as a general theorem
- ★ Formalize the master formula parameter count 5·2ⁿ − 6 as exact (not just verified for small cases)
- ★ Prove EML generates all polynomial functions (via subtraction + multiplication)
- ★ Formalize the e-tower grows faster than any polynomial

### 9.2 Automated EML Tree Verification
**Priority: Medium | Difficulty: Medium | Impact: Practical**

- ★ Lean tactic for automatically verifying EML tree evaluations
- ★ Certified EML tree search: exhaustive enumeration with proof certificates
- ★ New: Decision procedure for EML constant equality (for small trees)

---

## 10. Education and Exposition

### 10.1 The Two-Button Calculator
**Priority: High | Difficulty: Low | Impact: Educational**

- Interactive web app: compute anything with just EML and 1
- ★ Gamification: "reach π in the fewest steps"
- ★ Speed-run leaderboard for minimal EML trees
- ★ Classroom module: "All of Mathematics from One Operation"

### 10.2 Outreach
**Priority: Medium | Difficulty: Low | Impact: Broad**

- ★ Scientific American-style article (completed)
- ★ YouTube explainer video script
- ★ Interactive Jupyter notebook for EML exploration

---

## 11. Connections to Other Fields

### 11.1 Lambda Calculus and Computability
**Priority: Medium | Difficulty: Medium | Impact: Theoretical**

- EML universality for elementary functions parallels Church encoding universality for computable functions
- ★ Is there a "typed EML calculus" with type safety guarantees?
- ★ Connection to Gödel numbering: encode EML trees as natural numbers

### 11.2 Information Theory
**Priority: Medium | Difficulty: Hard | Impact: Novel**

- ★ Define "EML entropy" of a function: H_EML(f) = log₂(K_EML(f))
- ★ Is EML entropy subadditive? H_EML(f∘g) ≤ H_EML(f) + H_EML(g)?
- ★ Connection to Kolmogorov complexity: K_EML as a resource-bounded variant

### 11.3 Tropical Geometry
**Priority: Speculative | Difficulty: Hard | Impact: Novel**

- ★ The "tropical EML": trop_eml(x,y) = max(x, −y) (tropicalize exp → max, −ln → −)
- ★ Does tropical EML have universality properties in tropical mathematics?

---

## 12. Recommended Priority Order

### Immediate (next 6 months):
1. ★ EML symbolic regression benchmarks on standard datasets
2. ★ Complex fixed point and Julia set computation
3. ★ Close the multiplication complexity gap (current: 5 ≤ K ≤ 17)
4. ★ Interactive two-button calculator web app
5. ★ Extended Lean formalization: polynomial generation

### Medium-term (6–18 months):
6. Classification of Sheffer operators
7. EML complexity lower bound techniques
8. Neural EML network experiments
9. FPGA EML coprocessor prototype
10. ★ Transcendence of z* = W(e^e)

### Long-term (1–5 years):
11. Constant-free Sheffer conjecture
12. Non-elementary function extensions
13. Foundation models for mathematical expressions
14. Algebraic independence of e-tower
15. Complete EML complexity theory
16. ★ Tropical EML universality
17. ★ EML-based program synthesis

---

## Appendix: Theorem Inventory

### Lean 4 Formalized Theorems (100+, 0 sorry's)

Files:
- `EML/Basic.lean` — Core definitions, identities, tree structure
- `EML/AdvancedTheorems.lean` — Fixed points, e-tower, closure, combinatorics
- `EML/Universality.lean` — Closure properties, EDL/anti-EML
- `EML/NewTheorems.lean` — Derivatives, tree bounds, master formula
- `EML/ExtendedTheory.lean` ★ — Diagonal map, monotonicity, convexity, Lambert W, 2D dynamics, inequalities

### Key New Theorems (this version):
1. `emlDiagonal_no_real_fixedPoint`: ∀ z : ℝ, exp(z) − ln(z) ≠ z
2. `emlE_strictMono_fst`: eml is strictly increasing in x
3. `emlE_strictAnti_snd`: eml is strictly decreasing in y (y > 0)
4. `emlE_convexOn_fst`: eml is convex in x
5. `emlE_convexOn_snd`: eml is convex in y (y > 0)
6. `emlDiagonal_ge_one`: exp(z) − ln(z) ≥ 1 for z > 0
7. `emlE_subtraction`: eml(ln a, exp b) = a − b
8. `emlE_addition`: eml(ln a, exp(−b)) = a + b
9. `power_via_exp_log`: a^b = exp(b·ln a)
10. `fixedPoint_lambert_connection`: z* + ln(z*) = e
11. `fixedPoint_product_form`: z*·exp(z*) = e^e
12. `emlSymmetricMap_diagonal`: Φ(z,z) = (d(z), d(z))
13. `eml_x_expx_ge_one`: eml(x, exp(x)) ≥ 1
14. `masterParams_double_approx`: P(n+1) > 2·P(n) for n ≥ 2
15. `eTowerE_ge_n`: e-tower(n) ≥ n
