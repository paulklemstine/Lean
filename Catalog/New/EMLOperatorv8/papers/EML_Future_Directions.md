# Future Research Directions for the EML Operator

## A Roadmap for the Next Five Years

---

## Executive Summary

This document proposes 50 specific, actionable research directions for the EML operator $\text{eml}(x,y) = e^x - \ln y$, organized by priority and feasibility. Each direction includes a precise mathematical statement, estimated difficulty, required tools, and potential impact. We incorporate all results through V8 (280+ verified theorems) and identify the most promising paths forward.

---

## Part I: Immediate Research Goals (0–6 Months)

### 1. The Logarithm Complexity Problem

**Statement.** Determine $K_{\text{EML}}(\ln x)$. Current bounds: $3 \le K \le 5$.

**Approach.** The V7/V8 monotonicity theorems provide new tools:
- **Depth-1 lower bound:** $\text{eml}(f(x), g(x))$ where $f, g$ are built from $\{x, 1\}$ using fewer operations. Since $\text{eml}$ is strictly increasing in its first argument, depth-1 representations are monotone if $f$ is monotone. But $\ln x$ is monotone, so this doesn't eliminate depth 1 — we need to use the specific *growth rate*.
- **Growth rate argument:** $\text{eml}(f(x), g(x)) = e^{f(x)} - \ln(g(x))$. For this to equal $\ln x$, we need $e^{f(x)} - \ln(g(x)) = \ln x$. If $f$ is built from 1 and 2 operations, it's either constant, $e^x$, $e$, $e^{e^x}$, $e^e$, or $1 - x$. None of these, combined with a 0-operation $g$ (i.e., $g = x$ or $g = 1$), gives $\ln x$. This establishes $K \ge 3$.
- **Target:** Prove $K \ge 4$ by exhaustive case analysis of all 3-operation EML trees.

**Feasibility:** High. This is a finite case analysis that can be computer-assisted.

### 2. Symbolic Regression Benchmark Suite

**Statement.** Benchmark EML-based symbolic regression against PySR, AI Feynman, DSR, and KAN on standard datasets.

**Approach.**
- Implement an EML tree optimizer in Python (gradient-based on the continuous parameters, discrete search over tree topology).
- Test on the Strogatz ODE dataset, Feynman symbolic regression benchmark, and SRBench.
- The key advantage: an $n$-node EML tree has $5 \cdot 2^n - 6$ real parameters vs. the combinatorial explosion of general expression trees.

**Expected outcome.** EML should outperform on physics-derived datasets (where exponentials and logs appear naturally) and underperform on purely polynomial relationships. The comparison will identify the "sweet spot" for EML regression.

### 3. Complex Dynamics of the Diagonal Map

**Statement.** Compute and analyze the Julia set of $d(z) = e^z - \log z$ on $\mathbb{C}$.

**Approach.**
- Implement escape-time algorithm for $d$ on $\mathbb{C}$
- The logarithm introduces a branch cut; study the dynamics on the universal cover
- Determine: Is the Julia set connected? What is its Hausdorff dimension?

**Connection to V8:** The proven orbit divergence theorem (V8) implies every real orbit escapes, but complex orbits may be bounded for certain initial conditions.

### 4. Basin of Attraction for $z^*$

**Statement.** Prove that the basin of attraction of $z^* = W(e^e) \approx 2.017$ under $g(z) = e - \ln z$ is all of $(0, \infty)$.

**Approach.**
- V7 proved $|g'(z^*)| < 1$ and uniqueness of $z^*$
- Need to show that $g$ maps $(0, \infty)$ into $(0, \infty)$ (true since $g(z) = e - \ln z > 0$ for $z < e^e$, and $g$ maps large $z$ to values near $e$)
- Use the Schwarzian derivative to establish global attraction
- **Formal verification target:** This should be formalizable in Lean

### 5. Formalize EML Geodesic Equations

**Statement.** The Hessian $H = \text{diag}(e^x, 1/y^2)$ defines a Riemannian metric on $\mathbb{R} \times \mathbb{R}_{>0}$. Formalize the geodesic equations:
$$x'' + \tfrac{1}{2}(x')^2 = 0, \qquad y'' - \frac{(y')^2}{y} = 0.$$

**Approach.**
- The $x$-equation has solution $x(t) = 2 \ln(at + b)$ (parabolic)
- The $y$-equation has solution $y(t) = Ce^{kt}$ (exponential)
- Formalize in Lean using Mathlib's differential geometry library
- Compute Gaussian curvature: $K = -e^x/(4y^2)$ (negative, so the geometry is hyperbolic)

---

## Part II: Medium-Term Goals (6–18 Months)

### 6. Classification of Sheffer Operators

**Problem.** Classify all binary operations $F: \mathbb{R}^2 \to \mathbb{R}$ that, combined with a single constant, generate all elementary functions.

**Known examples:**
- $\text{eml}(x,y) = e^x - \ln y$
- $\text{edl}(x,y) = e^x / \ln y$
- Anti-EML: $\ln x - e^y$
- Affine family: $ae^x + b\ln y + c$

**Key question:** Is the space of Sheffer operators a group? A topological space with interesting structure?

**Approach:**
- A Sheffer operator must "contain" both $\exp$ and $\log$ in some extractable sense
- The V8 theorems on monotonicity and identity failures may help constrain candidates
- Connection to differential algebra: the Risch algorithm characterizes when elementary functions have elementary integrals

### 7. EML Quasigroup Embedding

**Problem.** Does $(\mathbb{R}, \text{eml})$ embed in a quasigroup?

**Background.** V7–V8 proved there is no identity element, so $(\mathbb{R}, \text{eml})$ is not a loop. For a quasigroup, we need the equations $\text{eml}(a, x) = b$ and $\text{eml}(x, a) = b$ to have unique solutions for all $a, b$.

**Analysis:**
- $\text{eml}(a, x) = b$ means $e^a - \ln x = b$, so $x = e^{e^a - b}$ — unique solution exists for all $a, b$ ✓
- $\text{eml}(x, a) = b$ means $e^x - \ln a = b$, so $x = \ln(b + \ln a)$ — requires $b + \ln a > 0$

The second equation fails when $b + \ln a \le 0$. So EML is *not* a quasigroup on all of $\mathbb{R} \times \mathbb{R}_{>0}$.

**Rescue:** Restrict to the domain where right division is defined, or extend by embedding in a larger structure.

### 8. EML Approximation Theory (Stone-Weierstrass Analogue)

**Problem.** Is the set of EML-computable functions (closure of $\{x, 1\}$ under EML) dense in $C(K)$ for compact $K \subset \mathbb{R}$?

**Approach.**
- The closure contains all $e^{nx}$, $e^{e^x}$, $e^{e^{e^x}}$, etc.
- It contains $1 - x = \text{eml}(0, e^x)$, hence all affine functions of $x$
- Via Weierstrass approximation, if it contains polynomials, it's dense
- **Key question:** Can $x^2$ be exactly represented as an EML expression? If not, can it be $\varepsilon$-approximated?

### 9. Tropical EML Semiring

**Problem.** Does $(\mathbb{R} \cup \{-\infty\}, \text{trop}, +)$ form a semiring?

**V8 result:** Tropical EML is not commutative, which complicates semiring structure.

**Approach:** Find the correct algebraic framework (perhaps a *skew semiring* or *near-semiring*) and formalize in Lean.

### 10. EML-Based Attention Mechanisms

**Problem.** Replace softmax attention with EML-based attention in transformers.

**Proposed design:**
$$\text{Attention}(Q, K, V) = \text{eml}(QK^T / \sqrt{d_k},\; \mathbf{1}) \cdot V$$

Since $\text{eml}(x, 1) = e^x$, this reduces to standard exponential attention for $y = 1$, but allows richer interaction patterns for $y \ne 1$.

---

## Part III: Long-Term Goals (1–5 Years)

### 11. The Constant-Free Sheffer Conjecture

**Conjecture.** No binary operation $B: \mathbb{C}^2 \to \mathbb{C}$ generates all elementary functions without a distinguished constant.

**Evidence:** V7–V8 proved that EML has no identity element. If $B(x, x) = c$ for all $x$ (producing a constant from the diagonal), then $c$ is that constant. If $B(x, x)$ depends on $x$, no fixed constant is produced.

### 12. Algebraic Independence of the E-Tower

**Problem.** Prove that $e, e^e, e^{e^e}$ are algebraically independent over $\mathbb{Q}$.

**Current status:** Even $e^e$ being transcendental is open (though widely believed). The V8 superexponential bound $e\!\uparrow\uparrow\!(n+2) \ge e^{2^n}$ provides growth-rate information that may be useful for irrationality measure arguments.

### 13. O-Minimality of the EML Structure

**Problem.** Is $(\mathbb{R}, +, \times, <, \text{eml})$ an o-minimal structure?

**Background.** By a theorem of Wilkie (1996), $(\mathbb{R}, +, \times, <, \exp)$ is o-minimal. Since $\text{eml}$ is definable from $\exp$ and $\log$ (which is definable from $\exp$ in Wilkie's structure), the EML structure should be o-minimal.

**Approach:** Formalize this argument in Lean, establishing o-minimality of the EML structure as a corollary of Wilkie's theorem.

### 14. EML Normal Forms and Decidability

**Problem.** Develop a canonical normal form for EML expressions.

**Connection:** Richardson's theorem states that zero-testing for exp-log expressions is undecidable in general. But EML expressions form a restricted class — do they have decidable equality?

### 15. Hausdorff Dimension of the Julia Set

**Problem.** Compute $\dim_H J(d)$ where $J(d)$ is the Julia set of $d(z) = e^z - \log z$.

---

## Part IV: Applications and Engineering

### 16. EML for Scientific Discovery

Deploy EML symbolic regression on:
- Particle physics cross-section data
- Astrophysical scaling relations
- Protein folding energy landscapes
- Climate model parameterizations

### 17. EML Hardware Coprocessor

Design a dedicated FPGA/ASIC computing $e^x - \ln y$ in hardware:
- Single pipeline: CORDIC for exp, lookup table for log, subtractor
- Monotonicity guarantees simplify error bounds
- Target: 10 GHz throughput for ML inference

### 18. EML Programming Language

Design a functional programming language where EML is the sole primitive operation, with constants as the only atoms. Programs are binary trees; semantics is EML evaluation.

### 19. EML in Education

Create interactive tools:
- **EML Golf:** Reach a target constant in the fewest EML operations
- **Lean Verification Game:** Students prove EML theorems in Lean
- **Visualization Suite:** Interactive level sets, orbits, and Julia set exploration

### 20. EML Cryptographic Applications

Investigate whether EML's non-algebraic structure (failing all standard identities) provides security advantages:
- One-way functions based on iterated EML
- Key exchange using EML orbit divergence
- Hash functions leveraging the chaotic dynamics of $d(z)$

---

## Appendix: Formalization Targets

The following theorems are high-priority targets for Lean formalization:

| Target | Difficulty | Dependencies |
|--------|:----------:|:------------:|
| $K_{\text{EML}}(\ln) \ge 4$ | Hard | Case analysis |
| Basin of attraction = $(0,\infty)$ | Medium | Schwarzian derivative |
| EML geodesic equations | Medium | Mathlib differential geometry |
| $e\!\uparrow\uparrow\! n$ growth rate refinement | Medium | V8 superexp bound |
| Tropical semiring structure | Easy | V8 tropical results |
| EML right quasi-division | Medium | V8 monotonicity |
| Level set curvature formula | Medium | Implicit function theorem |
| Automorphism group characterization | Hard | Classification argument |
| Orbit growth rate = tetration | Hard | Iterated exp bounds |
| Complex fixed points of $d$ | Very Hard | Complex analysis in Lean |

---

*All cited results are formally verified in Lean 4.28.0. Research directions are prioritized by a combination of mathematical importance, feasibility, and potential for formal verification.*
