# Future Directions: EML Filtered Approximation Algebra

## Synthesis

This research cycle established the **EML Depth Filtration** as a novel algebraic structure organizing real-valued functions by transcendental complexity. The key discovery is that the filtration forms a filtered algebra — each level closed under field operations, with composition acting additively on the grading. This creates a rigorous bridge between expression complexity theory and algebraic structure theory.

The most promising cross-domain connection is between the depth filtration and information-theoretic bounds. The information decay theorem (retained information decays as α^l × K through l layers) provides a fundamental constraint linking depth to initial complexity requirements. This mirrors the information bottleneck principle in deep learning, suggesting the EML framework captures essential features of neural network expressivity.

The highest breakthrough potential lies in **Direction 1** (EML Lower Bounds via Differential Algebra), because it would complete the strict hierarchy theorem — proving not just that exp^n can be represented at depth n, but that depth n is *necessary*. This would be the first formal depth separation result for the EML expression model, analogous to circuit complexity lower bounds.

---

### Direction 1: EML Lower Bounds via Differential Algebra

**Conjecture**: For any EML expression `e` with `emlDepth(e) < n`, the function `e.eval` cannot equal `iterExp(n)` on any open interval. Formally: if `e.eval = iterExp(n)` on `(0, ∞)`, then `emlDepth(e) ≥ n`.

**Test**: For n = 2, enumerate all EMLExpr trees of emlDepth ≤ 1 and size ≤ 20, and verify that none agrees with exp(exp(x)) at 100 test points in [0.1, 2]. For n = 3, do the same with emlDepth ≤ 2. If any counterexample is found, the conjecture is false.

**Impact**: If true, this gives a complete characterization of the EML depth hierarchy: `iterExp(n)` has exact EML depth n, not just an upper bound. This would be a genuine depth separation result, placing EML expressions in the same category as Boolean circuits where depth hierarchies are well-understood. If false, it would reveal unexpected compositional identities relating exponential towers to shallower EML expressions — equally interesting.

**Catalog References**: `EML/Complexity/Basic.lean` (expRank_le_emlDepth), `EML/Complexity/Defs.lean` (EMLExpr definition), `EML/FiltrationAlgebra.lean` (filtration_comp_bound, iterExp_depth_exact)

**Proof Strategy**: Use differential algebra. The key idea: define a differential complexity measure for real-analytic functions based on the structure of their differential equations. Show that:
1. iterExp(n) satisfies a differential equation of "exponential order" n (nested chain rule gives y' = y · iterExp(n-1)' · ... · 1)
2. Any function expressible at EML depth < n satisfies a differential equation of lower exponential order
3. These differential orders are preserved under the evaluation semantics

The critical lemma: `eml(a, b) = a · exp(b)` has derivative `a' · exp(b) + a · b' · exp(b)`, which increases the exponential order by exactly 1 compared to the maximum of a and b's orders.

**Domain Bridges**: Expression complexity ↔ Differential algebra ↔ Neural network depth separation

**Lineage**: Builds on `EMLExpr.expRank_le_emlDepth` and `emlExprIterExp_expRank` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: EML Complexity of Classical Functions

**Conjecture**: The EML description complexity of the Gamma function Γ(x) on [1, 10] at precision ε satisfies C_Γ(ε) = Θ(log(1/ε)²). More precisely: there exist constants c₁, c₂ > 0 such that for all small ε > 0, c₁ · (log(1/ε))² ≤ C_Γ(ε) ≤ c₂ · (log(1/ε))².

**Test**: Computationally, for ε ∈ {0.1, 0.01, 0.001, 0.0001}, find the minimum-size EML expression approximating Γ(x) on [1, 10] to within ε (using numerical optimization over EML tree structures of increasing size). Plot log(C_Γ(ε)) vs log(log(1/ε)) and check if the slope is approximately 2.

**Impact**: This would give the first concrete complexity characterization of a classical special function in the EML model. The Gamma function is particularly interesting because Stirling's approximation suggests polynomial-in-log complexity, and the EML model's exp/log primitives are perfectly suited to capture the dominant terms. If the conjectured quadratic-log scaling holds, it reveals that Gamma sits in a specific complexity class between polynomials (finite complexity) and highly oscillatory functions (polynomial-in-1/ε complexity).

**Catalog References**: `Algebra/EulerMascheroni/Series.lean` (gamma_approximation_complexity), `EML/FiltrationAlgebra.lean` (desc_complexity_antitone, EMLComplexitySpectrum)

**Proof Strategy**: Upper bound via Stirling series: Γ(x) ≈ √(2π/x) · (x/e)^x · Σ aₖ/x^k. Each term of the k-term Stirling series is expressible at EML depth 1 with O(k) nodes, and the error is O(1/x^k), so precision ε requires k = O(log(1/ε)) terms, each of size O(log(1/ε)). Lower bound via an information-theoretic argument: the coefficients of the Stirling series encode enough independent information that O((log(1/ε))²) nodes are necessary.

**Domain Bridges**: Approximation theory ↔ Special functions ↔ Information theory

**Lineage**: Builds on desc_complexity_antitone and EMLComplexitySpectrum from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Degeneration of EML Filtration

**Conjecture**: Under the tropical limit (replacing + with max, × with +), the EML depth filtration degenerates into a piecewise-linear depth hierarchy where each level F_n^trop consists of piecewise-linear functions with at most n "kinks" (non-differentiable points). The number of linear pieces at level n is exactly 2^n + 1.

**Test**: Define the tropical EML evaluation `eml_trop(a, b) = a + max(b, 0)` (tropicalization of a · exp(b)). For n = 1, 2, 3, 4, compute all functions representable by tropical EML trees of depth n, and count the distinct piecewise-linear patterns. Verify the pattern gives 2^n + 1 pieces.

**Impact**: If true, this gives a beautiful connection between the EML algebraic hierarchy and the combinatorics of piecewise-linear functions. The tropical limit is the "skeleton" of the EML filtration, and the count 2^n + 1 would connect to the expressivity of ReLU neural networks (which are piecewise-linear). This could provide a formal path from EML depth bounds to neural network expressivity bounds.

**Catalog References**: `Tropical/` (tropical optimization framework), `EML/FiltrationAlgebra.lean` (EMLDepthFiltration), `EML/MaxPlusStoneWeierstrass.lean`

**Proof Strategy**: Define tropical EML semantics by replacing exp with ReLU (the tropical limit of exp under log-space scaling). Show that:
1. Each tropical eml node adds at most one kink
2. Addition and multiplication of piecewise-linear functions preserve the total kink count
3. Composition can double the kink count (proved by explicit construction)

The key lemma: tropical eml(1, f)(x) = max(f(x), 0) introduces exactly one new breakpoint at each zero of f.

**Domain Bridges**: EML complexity ↔ Tropical geometry ↔ ReLU neural networks ↔ Piecewise-linear topology

**Lineage**: Builds on EMLDepthFiltration from this cycle, connects to existing Tropical catalog.

**Ambition**: grand_challenge

---

### Direction 4: Multi-Variable EML and Kolmogorov-Arnold Representation

**Conjecture**: The Kolmogorov-Arnold representation theorem (every continuous f: [0,1]^n → ℝ can be written as Σ_q Φ_q(Σ_p ψ_{q,p}(x_p))) can be lifted to an EML representation with depth ≤ 3 and size O(n²), where the inner functions ψ and outer functions Φ are single-variable EML expressions.

**Test**: For n = 2, implement the Kolmogorov-Arnold construction with EML inner/outer functions. Approximate f(x,y) = sin(x·y) on [0,1]² to precision ε = 0.01 and measure the total EML size. Compare with direct polynomial approximation (which requires O(1/ε²) terms for bivariate functions).

**Impact**: This would establish EML as a universal representation framework for multivariate functions, with explicit complexity bounds derived from the Kolmogorov-Arnold structure. The depth-3 bound (outer EML, then addition, then inner EML) gives a concrete architecture that is both universal and depth-efficient.

**Catalog References**: `EML/KolmogorovArnoldEMLDeep.lean` (existing KA-EML connection), `EML/FiltrationAlgebra.lean` (filtration_comp_bound)

**Proof Strategy**: 
1. Formalize the Kolmogorov-Arnold theorem for [0,1]^n → ℝ (exists in some Mathlib form, or define a weaker version)
2. Show that each ψ_{q,p} can be approximated by an EML expression of bounded depth and size (using the universal approximation theorem from this cycle)
3. The sum Σ_p ψ_{q,p}(x_p) stays at depth 0 (it's a sum of depth-d functions)
4. Each Φ_q applied to this sum adds depth 1

The total depth is max(depth(Φ)) + max(depth(ψ)) ≤ 1 + 1 = 2, plus 1 for the outer sum = 3.

**Domain Bridges**: EML univariate theory ↔ Multivariate approximation ↔ Kolmogorov superposition ↔ Neural architecture

**Lineage**: Builds on KolmogorovArnoldEMLDeep.lean from the Catalog and filtration_comp_bound from this cycle.

**Ambition**: extension

---

### Direction 5: EML Complexity and Algorithmic Information

**Conjecture**: The EML description complexity C_f(ε) satisfies a Levin-style coding theorem: for any computable f, C_f(ε) ≤ K(f|ε) + O(log(1/ε)), where K(f|ε) is the conditional Kolmogorov complexity of a description of f to precision ε. In other words, EML expressions are an asymptotically optimal representation for computable functions.

**Test**: For specific computable functions (polynomials, rational functions, exp, sin), compute both C_f(ε) and the Kolmogorov complexity upper bound (via shortest program in a fixed language), and verify the inequality holds with a reasonable constant in O(log(1/ε)).

**Impact**: This would establish a formal bridge between EML expression complexity and algorithmic information theory. If true, it means the EML framework is not just one of many possible representation systems — it is asymptotically as good as any computable representation. This is the information-theoretic justification for using EML as a universal function representation.

**Catalog References**: `EML/FiltrationAlgebra.lean` (emlDescComplexity, desc_complexity_antitone), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: The key insight is that any Turing machine program computing f to precision ε can be "compiled" to an EML expression by simulating the computation:
1. Arithmetic operations translate directly (field operations in EMLExpr)
2. Loops can be unrolled (contributing size proportional to running time)
3. Each transcendental function call contributes depth 1

The log(1/ε) overhead comes from the precision management in floating-point emulation. The formal proof would require defining a specific computational model and showing the compilation is size-efficient.

**Domain Bridges**: EML complexity ↔ Kolmogorov complexity ↔ Computability theory ↔ Information theory

**Lineage**: Builds on emlDescComplexity from this cycle and existing Catalog results on Kolmogorov complexity bounds.

**Ambition**: grand_challenge
