# Future Directions: EML Single-Operator Church-Turing Thesis

## Synthesis

This research cycle established the EML transcendental depth hierarchy as a rigorous complexity measure for real-valued computation. The key insight — that counting exp/log nodes on root-to-leaf paths, while treating field operations as free, gives a natural and strict complexity filtration — connects three domains: algebraic circuit complexity, differential algebra, and neural network theory.

The most promising cross-domain connection emerged between differential algebra and circuit complexity. The derivative fixed-point argument (no polynomial satisfies p' = p nontrivially) is a differential-algebraic obstruction that directly yields a circuit lower bound. This technique — using differential equations satisfied by target functions to prove circuit separations — generalizes beyond the polynomial case and may yield the full depth hierarchy theorem.

The highest-breakthrough-potential direction is Direction 1 (full depth hierarchy), because it would establish a complete analog of the circuit depth hierarchy for real computation. The depth-width tradeoff investigation (Direction 3) offers the most immediate falsifiable predictions through computational enumeration. Direction 4 (sin/cos non-representability) would precisely characterize the boundary of EML universality, answering the most fundamental question about what the single operator can and cannot compute.

---

### Direction 1: Full Transcendental Depth Hierarchy

**Conjecture**: For every n ≥ 0, EMLDepthClass(n) ⊊ EMLDepthClass(n+1). Specifically, iterExp(n+1) ∉ EMLDepthClass(n).

**Test**: For n = 0, prove that exp is not computable by any circuit without exp/log nodes (depth-0 circuits compute rational functions; exp is not rational). For n = 1, prove that exp(exp(x)) is not computable by any circuit with at most one exp/log nesting level. The n = 0 case reduces to showing depth-0 circuits are rational functions; the n = 1 case requires a more subtle "double transcendence" argument.

**Impact**: If true, this establishes an infinite strict hierarchy for real computation, analogous to the polynomial hierarchy in classical complexity theory. It would provide the first rigorous circuit lower bounds for transcendental functions. If the approach fails at some level n₀, the failure mode (a surprising circuit construction) would be equally interesting.

**Catalog References**: `EML/ChurchTuring.lean` (iterExp_in_depth_class, exp_ne_polynomial, EMLDepthClass_comp), `Catalog/EML/Core.lean` (eml, emlDiag), `Catalog/EML/Complexity/Defs.lean` (FullExpr, EMLExpr)

**Proof Strategy**:
1. **Step 1**: Formalize the rational function representation theorem: every depth-0 EMLCircuit evaluates to a rational function p(x)/q(x). This requires structural induction producing polynomial pairs closed under add, mul, neg, inv.
2. **Step 2**: Prove exp is not rational using the derivative argument: if p/q = exp, then q·exp = p, differentiating gives q'·exp + q·exp = p', so (q' + q)·exp = p'. Since both sides are products of a polynomial and exp, matching coefficients gives q' + q = 0 and p' = 0 simultaneously, which forces q = Ce^(-x) — not a polynomial.
3. **Step 3**: For higher n, use induction: if iterExp(n+1) ∈ EMLDepthClass(n), then by the composition decomposition, some circuit of depth ≤ n computes exp composed with a depth-(n-1) function, contradicting the induction hypothesis.

**Domain Bridges**: Algebra <-> Computation, DifferentialAlgebra <-> CircuitComplexity

**Lineage**: Builds on exp_ne_polynomial and EMLDepthClass_comp from the current cycle. Extends the depth-0 separation to all levels.

**Ambition**: grand_challenge

---

### Direction 2: Differential Algebraic Characterization of EML Classes

**Conjecture**: A function f : ℝ → ℝ belongs to EMLDepthClass(n) if and only if it satisfies a system of polynomial differential equations of "transcendental order" at most n. Formally, the n-th iterated Picard-Vessiot extension of the rational function field ℝ(x) should correspond exactly to EMLDepthClass(n).

**Test**: Verify for n = 0 (rational functions satisfy polynomial ODEs with rational coefficients — this is the classical theory of D-finite functions) and n = 1 (functions like exp, log, sinh satisfy first-order polynomial ODEs, which matches depth 1). The key test case is n = 2: does exp(exp(x)) satisfy a polynomial ODE of bounded order? It should require a "second-order" transcendental ODE.

**Impact**: This would provide an analytic characterization of the depth hierarchy, independent of circuit representations. It would connect EML theory to differential Galois theory, potentially allowing the importation of powerful algebraic techniques for proving depth separations.

**Catalog References**: `EML/ChurchTuring.lean` (EMLDepthClass, transcDepth), `Catalog/EML/Core.lean` (emlDiag, emlSelfPair_deriv)

**Proof Strategy**:
1. Define "transcendental order" of a polynomial ODE as the minimum number of successive integrations of exp/log needed to solve it.
2. Show that depth-n circuits satisfy ODEs of transcendental order ≤ n (forward direction).
3. Show that solutions of transcendental-order-n ODEs have EML circuits of depth ≤ n (reverse direction, likely harder).
4. Key lemma: the derivative of a depth-n circuit is also depth-n, with a specific polynomial coefficient structure.

**Domain Bridges**: DifferentialAlgebra <-> Computation, Analysis <-> CircuitComplexity

**Lineage**: Builds on the derivative fixed-point argument from exp_ne_polynomial. Generalizes from the polynomial case to the full differential-algebraic setting.

**Ambition**: grand_challenge

---

### Direction 3: Depth-Width Tradeoff for Iterated Exponentials

**Conjecture**: Any EML circuit computing iterExp(n) with transcendental depth exactly n has size exactly n + 1 (the simple chain exp(...exp(var)...) is optimal). No "compression" via log nodes or algebraic rearrangement can reduce the size below the chain.

**Test**: Enumerate all EML circuits of size ≤ n for n = 3, 4, 5 and check whether any circuit with transcDepth ≤ n computes iterExp(n) at test points {−2, −1, 0, 1, 2, 3}. If a smaller circuit is found, the conjecture is false. The enumeration is feasible for size ≤ 8 (approximately 8⁸ ≈ 16 million circuits, reducible by symmetry).

**Impact**: If true, this shows that the chain construction is optimal, meaning transcendental depth cannot be "traded" for width. If false, the counterexample would reveal a non-obvious algebraic identity relating iterated exponentials to lower-depth expressions — which would be a significant mathematical discovery.

**Catalog References**: `EML/ChurchTuring.lean` (EMLDepthWidthTradeoff, depth_width_tight_n1, depth_width_tight_n2, iterExpCircuit)

**Proof Strategy**:
1. Exhaustive computational search for n = 3, 4, 5 to verify or refute.
2. If the conjecture holds computationally, attempt a proof by induction on n, using the strict monotonicity of iterExp and uniqueness of the chain decomposition.
3. Key lemma needed: if c.eval = iterExp(n) and c has form exp(c'), then c'.eval = iterExp(n-1), and c' is the unique minimum-size circuit.

**Domain Bridges**: Computation <-> Combinatorics

**Lineage**: Builds on depth_width_tight_n1 and depth_width_tight_n2 from the current cycle.

**Ambition**: extension

---

### Direction 4: Sin and Cos Are Not EML-Computable

**Conjecture**: The functions sin : ℝ → ℝ and cos : ℝ → ℝ are not EML-computable. That is, there is no EML circuit c such that c.eval(x) = sin(x) for all x ∈ ℝ.

**Test**: Attempt to prove by contradiction using the oscillation properties of sin. Any EML-computable function is Liouvillian (built from rational functions by successive adjunction of exp and log). Liouvillian functions are either eventually monotone or have zeros that are isolated (no accumulation of sign changes). But sin has infinitely many zeros with bounded gaps, which is incompatible with Liouvillian behavior.

**Impact**: If true, this precisely characterizes the boundary of EML universality: EML captures all Liouvillian functions but misses the trigonometric functions, which require complex exp (Euler's formula). This would show that the "EML Church-Turing thesis" is TRUE for the Liouvillian class but FALSE for the full elementary class, making the thesis a precise rather than vague statement.

**Catalog References**: `EML/ChurchTuring.lean` (IsEMLComputable, EMLCircuit), `Catalog/EML/SingleOperatorRepresentability.lean` (sinh_EMLRepresentable, cosh_EMLRepresentable)

**Proof Strategy**:
1. Prove that any EML-computable function f has at most countably many zeros on any bounded interval (by the Liouvillian structure theory).
2. More precisely, show that between any two consecutive zeros of an EML-computable function, the function is either strictly positive or strictly negative (no accumulation of zeros).
3. Apply to sin: sin has zeros at every integer multiple of π, so any open interval of length > π contains at least one zero. But an EML-computable function with a zero at nπ for all n ∈ ℤ would need to be identically zero (by the isolation property), contradicting sin(π/2) = 1.
4. Key lemma: any depth-n EML circuit c has the property that {x : c.eval(x) = 0} is either ℝ or has no accumulation point in ℝ.

**Domain Bridges**: Analysis <-> Computation, RealAlgebra <-> ComplexAnalysis

**Lineage**: Builds on the EML-computability closure theorems from the current cycle. The contrast with sinh_EMLComputable (which IS EML-computable) highlights the role of complex numbers.

**Ambition**: extension

---

### Direction 5: EML Approximation Theory and Neural Network Depth

**Conjecture**: For any continuous function f : [0,1] → ℝ and any ε > 0, there exists an EML circuit c of transcendental depth ≤ 1 such that |c.eval(x) − f(x)| < ε for all x ∈ [0,1]. Moreover, the circuit size is bounded by O(1/ε · ω(f, ε)), where ω(f, ε) is the modulus of continuity.

**Test**: This is essentially the universal approximation theorem rephrased for EML circuits of depth 1. The Stone-Weierstrass theorem gives polynomial approximation (depth 0). Adding one layer of exp should improve the approximation rate for functions with specific smoothness properties. Compare: for f(x) = exp(−1/x²) (flat at 0), polynomial approximation converges slowly, but a single exp composition should converge faster.

**Impact**: If true, this would show that depth-1 EML circuits are universal approximators, meaning a single layer of transcendental depth suffices for approximation (though not exact computation). This has direct implications for neural network architecture: one hidden layer with exp/log activations is sufficient for universal approximation, with quantitative bounds on width.

**Catalog References**: `Catalog/EML/StoneWeierstrassApprox.lean`, `Catalog/EML/UniversalApproximation.lean`, `Catalog/EML/ApproximationBounds.lean`

**Proof Strategy**:
1. Use the Stone-Weierstrass theorem to approximate f by a polynomial p within ε/2.
2. Construct an EML circuit for p (depth 0 by power_in_depth_class_zero).
3. For improved rates, use the sigmoidal approximation: σ(ax + b) ≈ step function for large a, and sums of shifted sigmoids approximate any continuous function.
4. Key connection: the sigmoid σ(x) = 1/(1+e^(−x)) is depth 1, and universal approximation by sigmoid networks is classical.

**Domain Bridges**: ApproximationTheory <-> MachineLearning, Analysis <-> Computation

**Lineage**: Builds on sigmoid_EMLComputable and polynomial_in_depth_class_zero from the current cycle. Connects to the existing Catalog work on Stone-Weierstrass for EML.

**Ambition**: extension
