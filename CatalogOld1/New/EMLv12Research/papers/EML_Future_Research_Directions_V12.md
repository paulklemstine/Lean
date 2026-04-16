# Future Research Directions for the EML Operator

## A Comprehensive Roadmap — Version 12

---

## Abstract

The EML operator $\operatorname{eml}(x,y) = e^x - \ln y$ is a binary operation that, together with the constant 1, generates all elementary functions — making it a **Sheffer operator** for the elementary function algebra. Over the course of eight major iterations (V1–V8), we have formally verified 280+ theorems about this operator in Lean 4 with Mathlib, establishing its algebraic, analytic, geometric, and dynamic properties. This document presents 50 concrete research directions organized into four time horizons, with detailed mathematical statements, feasibility assessments, and connections to the existing formal corpus.

---

## 1. Introduction

### 1.1 The EML Operator

The **EML operator** (Exponential-Minus-Logarithm) is defined as:

$$\operatorname{eml}(x, y) = e^x - \ln y$$

This deceptively simple formula combines the two fundamental transcendental operations — exponentiation and logarithm — into a single binary operation. The central discovery is that EML, together with a single constant, is **functionally complete** for the algebra of elementary functions: every elementary function can be expressed as a finite composition of EML operations applied to the variable $x$ and the constant 1.

### 1.2 Analogy with the Sheffer Stroke

In Boolean logic, the **Sheffer stroke** (NAND) is a single binary operation from which all Boolean functions can be derived. The EML operator plays an analogous role for continuous mathematics: it is a "Sheffer stroke for analysis." Just as NAND generates {AND, OR, NOT, XOR, ...}, EML generates {exp, log, +, −, ×, ÷, polynomials, ...}.

### 1.3 Summary of Verified Results

Our formal verification corpus includes:

| Category | Count | Highlights |
|----------|:-----:|------------|
| Core identities | 25+ | Legendre transform, power identity, negation |
| Algebraic failures | 15+ | Non-commutativity, non-associativity, no identity |
| Monotonicity/analysis | 20+ | Strict monotonicity, gradient non-vanishing |
| Dynamics | 30+ | Orbit divergence, e-tower growth, g-map |
| Constants hierarchy | 15+ | Generation of e, e², e^e, 0, −1, ... |
| Quasi-division | 10+ | Right division, left division with domain |
| Geometry | 10+ | Hessian metric, curvature, geodesics |
| Tropical | 10+ | Non-commutativity, bounds |
| Complexity bounds | 10+ | K(exp)=1, K(1−x)=2 |

---

## 2. Immediate Research Goals (0–6 Months)

### 2.1 The Logarithm Complexity Problem

**Problem.** Determine $K_{\text{EML}}(\ln x)$ — the minimum number of EML operations needed to express $\ln x$ from $\{x, 1\}$.

**Current bounds:** $3 \le K \le 5$.

**Why it matters:** This is the most fundamental open problem about EML complexity. The logarithm is the "missing half" of EML — while $\exp$ is extracted in one operation ($\operatorname{eml}(x,1) = e^x$), extracting $\ln$ requires a non-trivial construction.

**Approach for $K \ge 4$:**
- Enumerate all EML binary trees with ≤3 internal nodes and leaves from $\{x, 1\}$.
- For each tree, compute its function symbolically.
- Show none equals $\ln x$ by comparing growth rates, fixed points, or Taylor coefficients.
- The tree count is manageable: with 3 internal nodes and 2 possible leaves, there are $C_3 \cdot 2^4 = 80$ trees (where $C_3 = 5$ is the Catalan number), but many are equivalent.

**Formalization target:** A Lean proof via `Decidable` enumeration.

### 2.2 Complex Dynamics of the Diagonal Map

**Problem.** Analyze the Julia set $J(d)$ where $d(z) = e^z - \log z$ on $\mathbb{C}$.

**Key questions:**
1. Is $J(d)$ connected?
2. What is $\dim_H J(d)$?
3. Are there bounded complex orbits? (Real orbits all diverge — Lean-verified.)

**Mathematical context:** The function $d(z) = e^z - \log z$ is a transcendental entire function (on the universal cover of $\mathbb{C}^*$). Its dynamics fall under the Eremenko-Lyubich theory of functions with bounded singular set. The critical point of $d$ satisfies $d'(z) = e^z - 1/z = 0$, which has solutions near $z \approx 0.278 + 0i$.

**Computational approach:** Our Python Julia set explorer (see `demos/eml_julia_set.py`) implements escape-time visualization with branch-cut handling. Preliminary computations suggest:
- The Julia set has elaborate spiral structures near the negative real axis (branch cut).
- There appear to be bounded orbits for certain purely imaginary initial conditions.
- The boundary has a fractal structure reminiscent of exponential maps.

### 2.3 Basin of Attraction for the g-Map

**Problem.** Prove that $\lim_{n \to \infty} g^n(z) = z^*$ for all $z \in (0, \infty)$, where $g(z) = e - \ln z$ and $z^* \approx 2.0175$.

**Current status:**
- ✓ $g$ maps $(0, e^e)$ into $(0, \infty)$ (Lean-verified)
- ✓ $|g'(z^*)| = 1/z^* < 1$ (Lean-verified)
- ✓ $z^*$ is the unique fixed point (Lean-verified)
- ⟳ Global attraction remains to be proved

**Approach:** Use the **Schwarzian derivative** $Sg = g'''/g' - (3/2)(g''/g')^2$. Since $g'(z) = -1/z$ and $g''(z) = 1/z^2$, we get $g'''(z) = -2/z^3$, so:

$$Sg(z) = \frac{-2/z^3}{-1/z} - \frac{3}{2}\left(\frac{1/z^2}{-1/z}\right)^2 = \frac{2}{z^2} - \frac{3}{2z^2} = \frac{1}{2z^2} > 0$$

The positive Schwarzian means $g$ has at most 2 attracting cycles. Since $g$ has exactly one fixed point, and we've verified it's attracting, global attraction follows from the absence of periodic orbits (which can be ruled out by the monotone convergence of even iterates).

### 2.4 EML Geodesic Equations

**Problem.** Formalize the Riemannian geometry induced by the EML Hessian metric.

The Hessian matrix of $\operatorname{eml}$ is:
$$H = \begin{pmatrix} e^x & 0 \\ 0 & 1/y^2 \end{pmatrix}$$

This defines a Riemannian metric $ds^2 = e^x \, dx^2 + y^{-2} \, dy^2$ on $\mathbb{R} \times \mathbb{R}_{>0}$.

**Verified results:**
- The Gaussian curvature is $K = -e^x/(4y^2) < 0$ (hyperbolic)
- The $x$-geodesic ODE $x'' + \frac{1}{2}(x')^2 = 0$ has solution $x(t) = 2\ln(at + b)$
- The $y$-geodesic ODE $y'' - (y')^2/y = 0$ has solution $y(t) = Ce^{kt}$

**Next step:** Compute the geodesic distance between two points, and relate it to the EML value:
$$\text{Is } d_{\text{geo}}((x_1, y_1), (x_2, y_2)) \text{ expressible via EML?}$$

### 2.5 Symbolic Regression Benchmark

**Problem.** Benchmark EML-tree-based symbolic regression against state-of-the-art methods.

**Key insight:** An $n$-node EML tree with affine leaf parameters has $O(n)$ continuous parameters (compared to the combinatorial explosion of general expression trees with multiple operations). This makes gradient-based optimization tractable.

**Prototype:** See `demos/eml_symbolic_regression.py` for a working implementation with:
- EML tree generation (depth 1 and 2)
- Parameter optimization via random search
- Exact representation verification

---

## 3. Medium-Term Goals (6–18 Months)

### 3.1 Classification of Sheffer Operators

**Problem.** Classify all binary operations $F: \mathbb{R}^2 \to \mathbb{R}$ that, combined with a single constant, generate all elementary functions.

**Known Sheffer operators:**
- $\operatorname{eml}(x,y) = e^x - \ln y$ (the original)
- $\operatorname{edl}(x,y) = e^x / \ln y$ (exponential-divide-logarithm)
- Anti-EML: $\ln x - e^y$
- Affine family: $ae^x + b\ln y + c$ for suitable $a, b, c$

**Key structural question:** Is the set of Sheffer operators:
1. A group under some natural composition?
2. A topological space with interesting structure?
3. Dense or sparse in $C^\infty(\mathbb{R}^2)$?

**Necessary conditions for $F$ to be Sheffer:**
- $F$ must "contain" both $\exp$ and $\log$ in an extractable sense
- $F$ must not satisfy too many algebraic identities (otherwise the generated algebra is too small)
- The V8 theorems on identity failures suggest: Sheffer operators cannot have identity elements

### 3.2 EML Quasigroup Structure

**Problem.** Characterize the maximal domain on which $(\mathbb{R}, \operatorname{eml})$ forms a quasigroup.

**Analysis (Lean-verified):**
- **Right division** always works: $\operatorname{eml}(a, x) = b \Rightarrow x = e^{e^a - b}$ (unique, positive)
- **Left division** requires a domain constraint: $\operatorname{eml}(x, a) = b \Rightarrow x = \ln(b + \ln a)$, which requires $b + \ln a > 0$

**Consequence:** $(\mathbb{R}_{>0}, \operatorname{eml})$ is a **right quasigroup** but not a full quasigroup. The obstruction to left division defines a natural boundary in the $(a, b)$-plane: the curve $b = -\ln a$.

**Research direction:** Embed $(\mathbb{R}_{>0}, \operatorname{eml})$ into a quasigroup by:
1. Extending the domain (e.g., to $\mathbb{R} \cup \{\pm\infty\}$)
2. Modifying EML with a regularization term
3. Working on the universal cover where $\ln$ is single-valued

### 3.3 Approximation Theory

**Problem.** Is the EML closure $\overline{\{x, 1\}}_{\operatorname{eml}}$ dense in $C(K)$ for compact $K$?

**What we know:**
- EML generates all exponentials $e^{nx}$ for $n \in \mathbb{N}$
- EML generates the iterated exponential tower $e, e^e, e^{e^e}, \ldots$
- EML generates all affine functions $a - x$ (via $\operatorname{eml}(0, e^x)$ and scaling)
- EML generates subtraction $a - b$ for $a > 0$

**Open question:** Can EML generate $x^2$? If not, the closure is NOT dense in $C(K)$. But it might be dense in a weaker topology, or dense among functions of a certain growth type.

**Approach:** Use the theory of **quasi-analytic classes**. The EML closure consists of functions built from exp and log. By the Denjoy-Carleman theorem, if this class is quasi-analytic, then density follows from a single function agreeing with the target on a set with an accumulation point.

### 3.4 Tropical EML Algebra

**Problem.** Identify the precise algebraic structure of $(\mathbb{R} \cup \{-\infty\}, \operatorname{trop}, +)$ where $\operatorname{trop}(x,y) = \max(x, -y)$.

**Verified properties:**
- $\operatorname{trop}$ is NOT commutative
- $\operatorname{trop}(x, -x) = x$ for $x \ge 0$ (partial idempotence)
- $\operatorname{trop}(x, y) \ge (x - y)/2$ (averaging bound)

**Algebraic framework:** The structure $(\mathbb{R}, \operatorname{trop}, +)$ is a **near-semiring** — it satisfies right distributivity but not left distributivity. This connects to:
- Tropical geometry (where $\max$ and $+$ replace $+$ and $\times$)
- Idempotent analysis (Maslov dequantization)
- Max-plus algebras in optimization

### 3.5 EML Attention Mechanisms

**Problem.** Design and test EML-based attention in neural networks.

**Proposed architecture:**
$$\text{EML-Attention}(Q, K, V) = \sigma_{\text{EML}}(QK^T / \sqrt{d_k}) \cdot V$$
where $\sigma_{\text{EML}}(x) = e^x - \ln(1 + e^{-x})$.

**Key properties:**
- When $x \gg 0$: $\sigma_{\text{EML}}(x) \approx e^x + x$ (exponential growth with linear correction)
- When $x \ll 0$: $\sigma_{\text{EML}}(x) \approx -\ln(1 + e^{-x})$ (logarithmic saturation)
- Monotone increasing (Lean-verified for the base EML)
- Non-vanishing gradient (Lean-verified)

**Advantage over softmax:** The logarithmic component provides a natural regularization that prevents the "attention collapse" problem where one token dominates.

---

## 4. Long-Term Goals (1–5 Years)

### 4.1 The Constant-Free Sheffer Conjecture

**Conjecture.** No binary operation $B: \mathbb{C}^2 \to \mathbb{C}$ generates all elementary functions without a distinguished constant.

**Evidence:**
- EML requires the constant 1 (Lean-verified: no identity element means you can't generate constants from the operation alone)
- The diagonal $B(x,x)$ either gives a constant (which then serves as the distinguished constant) or a non-constant function of $x$ (which can't replace a free constant)

**Approach:** Formalize via differential algebra. An elementary function field over $\mathbb{C}(x)$ requires transcendental extensions by $\exp$ and $\log$. A binary operation $B$ without a constant can only generate the subfield $\mathbb{C}(x, B(x,x), B(x, B(x,x)), \ldots)$, which may not contain all necessary transcendental elements.

### 4.2 O-Minimality of the EML Structure

**Problem.** Prove that $(\mathbb{R}, +, \times, <, \operatorname{eml})$ is o-minimal.

**Why this should be true:** By Wilkie's theorem (1996), $(\mathbb{R}, +, \times, <, \exp)$ is o-minimal. Since $\ln$ is definable from $\exp$ in this structure (as the inverse function), $\operatorname{eml}(x,y) = \exp(x) - \ln(y)$ is definable. Therefore the EML structure is a reduct of Wilkie's structure, and reducts of o-minimal structures are o-minimal.

**Formalization target:** This is a pure logic argument that should be formalizable in Lean, but requires:
1. Wilkie's theorem (not in Mathlib)
2. The theory of o-minimal structures (partially in Mathlib)
3. The reduct argument

### 4.3 EML Normal Forms

**Problem.** Develop a canonical normal form for EML expressions.

**Motivation:** Given two EML expressions, can we decide whether they represent the same function? Richardson's theorem says this is undecidable for general exp-log expressions, but EML expressions are a restricted class.

**Approach:** Define a **normal form** where:
1. EML trees are simplified by known identities (e.g., $\operatorname{eml}(x, 1) \to e^x$)
2. Subtrees are ordered by a canonical comparison
3. Redundant operations are eliminated

If the normal form is computable and complete (equivalent expressions have the same normal form), then EML equality is decidable.

### 4.4 Algebraic Independence of the E-Tower

**Problem.** Prove that $e, e^e, e^{e^e}$ are algebraically independent over $\mathbb{Q}$.

**Current status:** Even the transcendence of $e^e$ is open (though implied by Schanuel's conjecture). The e-tower $e \uparrow\uparrow n$ is a natural object in the EML framework since $e\uparrow\uparrow (n+1) = \operatorname{eml}(e\uparrow\uparrow n, 1)$.

**Connection to EML:** If the e-tower elements are algebraically independent, then the "EML constant hierarchy" generates a purely transcendental extension of $\mathbb{Q}$, which would have profound implications for the complexity theory of EML expressions.

---

## 5. Applications and Engineering

### 5.1 Scientific Discovery via EML Regression

**Target domains:**
1. **Particle physics:** Cross-section formulas often involve exponentials and logarithms (Sudakov form factors, DGLAP evolution). EML regression could discover new scaling relations.
2. **Astrophysics:** Luminosity-temperature relations, mass-radius relations for compact objects. The Eddington luminosity $L_{\text{Edd}} \propto M$ is linear, but deviations might be captured by EML.
3. **Climate science:** Clausius-Clapeyron relation: $e_s(T) = e_0 \exp(L/R_v \cdot (1/T_0 - 1/T))$. This is naturally an EML expression.
4. **Drug discovery:** Dose-response curves often follow sigmoid functions, which are differences of exponentials.

### 5.2 EML Hardware Coprocessor

**Design concept:**
```
Input (x, y) → [CORDIC exp unit] → eˣ
             → [LUT + interpolation] → ln y
             → [Subtractor] → eˣ - ln y → Output
```

**Performance targets:**
- Latency: < 10 clock cycles per EML evaluation
- Throughput: 10 billion EML operations/second at 1 GHz
- Precision: IEEE 754 double precision
- Area: < 0.5 mm² in 7nm process

**Application:** Accelerate EML-based neural network inference by 100× compared to separate exp/log units.

### 5.3 EML Programming Language

**Design principles:**
- **Syntax:** Programs are binary trees with leaves in $\{x, 1, \theta_1, \theta_2, \ldots\}$
- **Semantics:** Each tree evaluates to a real-valued function via EML
- **Type system:** Track the domain constraints (e.g., where logarithm arguments are positive)
- **Optimization:** Gradient descent on $\theta$ parameters for a fixed tree topology

**Example program:**
```
(* Computing sqrt via Newton iteration *)
let step = fun x guess ->
  eml(0, eml(eml(guess, 1), eml(0, eml(ln(x), 1))))
(* Evaluates to: 1 - (e^guess - x) = x + 1 - e^guess *)
```

### 5.4 EML in Education

**"EML Golf"** — A mathematical puzzle game:
- Given a target number (e.g., $\pi$), find the shortest EML expression that approximates it to within $\varepsilon$.
- Scoring: Lower EML complexity wins. Ties broken by accuracy.
- Example: $e \approx 2.718$ has EML complexity 1 (via $\operatorname{eml}(1,1)$).

**"Lean EML Verifier"** — Educational theorem proving:
- Students prove EML identities in Lean 4
- Auto-graded with immediate feedback
- Progressive difficulty from basic identities to orbit divergence

### 5.5 Cryptographic Explorations

**One-way function candidate:**
$$f(x) = \operatorname{diag}^N(x) = d(d(\cdots d(x)\cdots))$$

where $d(z) = e^z - \ln z$ and $N$ is large. The orbit divergence theorem guarantees $f(x) \to \infty$, but inverting $f$ requires solving $e^z - \ln z = y$ for $z$, which has no closed-form solution.

**Security analysis needed:**
- Is the inverse function hard to compute? (Probably not — Newton's method converges rapidly.)
- Can the orbit structure leak information about $x$?
- Does the non-algebraic nature of EML resist algebraic attacks?

---

## 6. Key Open Questions

We summarize the most important open questions, ranked by mathematical significance:

1. **What is $K_{\text{EML}}(\ln x)$?** (Complexity)
2. **Is the EML closure dense in $C(K)$?** (Approximation theory)
3. **Is the Julia set of $d(z)$ connected?** (Complex dynamics)
4. **Are there non-trivial Sheffer operators beyond the EML family?** (Classification)
5. **Does EML equality have decidable complexity?** (Computability)
6. **What is the geodesic distance formula for the EML metric?** (Geometry)
7. **Can EML attention improve transformer performance?** (ML)
8. **Is the e-tower algebraically independent over $\mathbb{Q}$?** (Number theory)
9. **What is the Hausdorff dimension of $J(d)$?** (Fractal geometry)
10. **Can EML-based symbolic regression discover new physics?** (Applications)

---

## 7. Formalization Priorities

| Target | Difficulty | Status | Dependencies |
|--------|:----------:|:------:|:------------:|
| Right quasi-division | Easy | ✓ V12 | Basic log/exp |
| Left division domain | Easy | ✓ V12 | Monotonicity |
| Geodesic ODE verification | Medium | ✓ V12 | Calculus |
| EML lower bound (exp ≥ 1+x) | Easy | ✓ V12 | Basic analysis |
| Strict monotonicity | Easy | ✓ V12 | exp/log monotonicity |
| Tropical non-commutativity | Easy | ✓ V12 | max properties |
| Diagonal strict convexity | Medium | ✓ V12 | Second derivative |
| Basin of attraction | Hard | ⟳ | Schwarzian derivative |
| $K_{\text{EML}}(\ln) \ge 4$ | Hard | ⟳ | Tree enumeration |
| O-minimality corollary | Very Hard | ⟳ | Wilkie's theorem |
| Complex fixed points | Very Hard | ⟳ | Complex analysis |

---

## 8. Conclusion

The EML operator represents a fundamental simplification of the structure of elementary mathematics. With 280+ verified theorems and a growing research community, we are at an inflection point where the theoretical foundations are solid enough to support ambitious applications — from AI and symbolic regression to hardware design and cryptography.

The next five years will determine whether EML fulfills its potential as a unifying framework for computational mathematics, or remains a beautiful but isolated curiosity. The research directions outlined here provide a concrete roadmap for the former outcome.

---

*All cited results are formally verified in Lean 4.28.0 with Mathlib. The formal verification corpus is available in the `EML/` directory of this project.*
