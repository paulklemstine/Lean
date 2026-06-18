# Future Directions: EML Differential Algebra

## Synthesis

This cycle established the **Logarithmic Derivative Algebra** as a novel mathematical structure for EML functions, proving 17 theorems about the differential calculus of exp-log compositions. The central discovery is that the logarithmic derivative LD(f) = f'/f acts as a graded homomorphism from the multiplicative monoid of EML functions to their additive group, with the grading given by composition depth. Each application of LD strips exactly one layer of exponential nesting.

The most promising cross-domain connection is between the **depth hierarchy** of EML expressions and **computational complexity**. The depth bound theorem (depth of derivative ≤ depth + 1) suggests that the EML depth hierarchy may be a natural measure of computational difficulty, analogous to circuit depth in complexity theory. The quadratic size bound for symbolic derivatives connects to expression complexity in the existing Catalog (EML/Complexity/), while the LD algebra connects to the closure operator framework (EML/ClosureOperator.lean, EML/GaloisInsertionClosure.lean).

The highest breakthrough potential lies in Direction 1 (EML Normal Forms), because finding a canonical simplification procedure that controls derivative size growth would have immediate practical applications in verified numerical computation and automatic differentiation, while also providing insight into the algebraic structure of the EML class.

---

### Direction 1: EML Derivative Normal Forms and Linear Size Growth

**Conjecture**: There exists a computable simplification map `norm : EMLDiffExpr → EMLDiffExpr` such that (a) norm preserves semantics (eval(norm(e), x) = eval(e, x) for all x in the domain), (b) norm is idempotent (norm(norm(e)) = norm(e)), and (c) nodeCount(norm(symDiff(e))) ≤ C · nodeCount(e) for a universal constant C (linear, not quadratic).

**Test**: Implement norm as a rewrite system with rules: constant folding (const(a) + const(b) → const(a+b)), identity elimination (mul(const(1), e) → e), zero elimination (add(const(0), e) → e, mul(const(0), e) → const(0)), exp-log cancellation (exp(log(e)) → e), and common subexpression elimination. Enumerate all EML expressions with depth ≤ 3 and nodeCount ≤ 12. Compute symDiff, apply norm, and check whether nodeCount(norm(symDiff(e))) ≤ 5 · nodeCount(e).

**Impact**: If true, this would show that EML differentiation has *linear* cost in a suitable normal form, making verified automatic differentiation practical for large EML expressions. If false, it identifies which EML subclasses (e.g., the multiplicative fragment) admit linear growth.

**Catalog References**: `EML/Complexity/Defs.lean` (EMLExpr, esize), `EML/Complexity/Basic.lean`, `EML/DiffAlgebra.lean` (symDiff, symDiff_nodeCount_le)

**Proof Strategy**: Define norm by structural recursion with a termination measure (lexicographic on depth and size). Prove confluence of the rewrite rules to ensure idempotence. For the linear bound, analyze each symDiff case with norm applied: the key is that norm eliminates the duplication caused by the product rule.

**Domain Bridges**: EML Complexity ↔ Computation (circuit depth), EML Closure ↔ Algebra (Galois connections)

**Lineage**: Builds on symDiff_nodeCount_le (quadratic bound) and symDiff_depth_le (depth bound) from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Schwarzian Derivative and EML Projective Structure

**Conjecture**: The **Schwarzian derivative** S(f) = f'''/f' - (3/2)(f''/f')² of an EML function of depth d is an EML function of depth at most d+1. Moreover, the Schwarzian satisfies the cocycle identity S(f ∘ g) = (S(f) ∘ g) · (g')² + S(g), and this identity lifts to a structural theorem on EMLDiffExpr.

**Test**: Compute S(exp(x²)) symbolically using three applications of symDiff, verify it produces a valid EMLDiffExpr, and check its depth. Compare with the numerical Schwarzian at 10 random points.

**Impact**: The Schwarzian derivative governs conformal mappings and Möbius transformations. Proving closure under the Schwarzian would establish that EML functions have a natural **projective differential geometry**. If the cocycle identity lifts to EMLDiffExpr, it would give a formal proof that EML compositions respect projective structure — connecting analysis to geometry.

**Catalog References**: `EML/DiffAlgebra.lean` (emlLogDeriv_deriv, eml_deriv_exp_exp), `EML/KolmogorovArnoldEMLDeep.lean` (eml_chain_exp_log_cancel)

**Proof Strategy**: Define the Schwarzian as S(f) = LD(LD(f))' - (1/2)·LD(f)² where LD is the logarithmic derivative from this cycle. This reformulation in terms of LD should simplify the depth analysis. Prove the cocycle identity by direct computation using the chain rule theorems.

**Domain Bridges**: EML Analysis ↔ Geometry (projective structure), EML ↔ Physics (conformal field theory)

**Lineage**: Builds on emlLogDeriv_exp, emlLogDeriv_deriv, and the iterated LD structure from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: EML Differential Field Extensions and Liouvillian Structure

**Conjecture**: The field of EML functions (as meromorphic functions on ℝ) forms a **Liouvillian extension** of ℝ(x). The tower ℝ(x) ⊂ ℝ(x, exp) ⊂ ℝ(x, exp, log) has the property that each step is either an exponential extension (adjoining exp(h) where h is in the previous field) or a logarithmic extension (adjoining log(g) where g is in the previous field). The logarithmic derivative LD provides the connection: LD maps exponential extensions to the base field, and LD maps logarithmic extensions to rational functions in the base field.

**Test**: Formalize the Liouvillian tower for depth-2 EML functions: show that every depth-2 EML function can be obtained by at most 2 exponential/logarithmic adjunctions starting from ℝ(x). Verify that LD maps each tower level to the previous level.

**Impact**: This would connect the EML depth hierarchy to classical differential Galois theory, providing a Galois-theoretic interpretation of composition depth. The depth-d EML functions would correspond to Liouvillian extensions of transcendence degree d.

**Catalog References**: `EML/DiffAlgebra.lean` (emlLogDeriv_exp, emlLogDeriv_mul, emlLogDeriv_div), `EML/GaloisInsertionClosure.lean` (eml_closed_closure_operator_triple)

**Proof Strategy**: Define a `LiouvillianTower` inductive type with constructors for exponential and logarithmic adjunctions. Show that EMLDiffExpr of depth d embeds into a tower of height d. Use the LD algebra to prove that LD maps each level to the previous level, establishing the adjunction structure.

**Domain Bridges**: EML Analysis ↔ Algebra (Galois theory), EML ↔ Cryptography (algebraic independence)

**Lineage**: Builds on the full LD algebra (Theorems 3.6-3.12) and the depth bound from this cycle.

**Ambition**: extension

---

### Direction 4: Verified Automatic Differentiation for EML Neural Networks

**Conjecture**: For a feedforward neural network with EML activation functions (i.e., activations that are EML expressions of bounded depth d), the backpropagation gradient computation can be verified to produce an EML expression of depth at most d+1, with size bounded by O(n·d) where n is the number of network parameters.

**Test**: Define a simple 2-layer neural network with exp activation: f(x) = w₂·exp(w₁·x + b₁) + b₂. Compute the gradient ∂f/∂w₁ symbolically using symDiff, verify it is EML, and check its depth and size bounds. Compare with numerical gradient at 5 random parameter configurations.

**Impact**: This would provide a mathematical foundation for **verified automatic differentiation** in machine learning. Current AD systems compute gradients correctly in practice, but have no formal guarantees about the structure of the output. Proving that EML-network gradients are bounded EML expressions would enable formally verified gradient computation.

**Catalog References**: `EML/DiffAlgebra.lean` (symDiff, symDiff_depth_le, symDiff_nodeCount_le), `MachineLearning/ClosureUniversalApproximation.lean` (finite_function_exact_by_closure_features), `EML/UniversalApproxComplexity.lean` (eml_composition_depth_additive)

**Proof Strategy**: Define a `NeuralNetwork` type as a composition of affine maps and EML activations. Define backprop as iterated application of symDiff with the chain rule. Use the depth and size bounds from this cycle to bound the gradient expression complexity.

**Domain Bridges**: EML ↔ MachineLearning (universal approximation), EML Complexity ↔ Computation (gradient complexity)

**Lineage**: Builds on the entire DiffAlgebra framework, especially soundness theorems and size bounds.

**Ambition**: extension

---

### Direction 5: Tropical Logarithmic Derivative and Maslov Dequantization

**Conjecture**: The logarithmic derivative LD has a well-defined **tropical limit**: as ℏ → 0, the rescaled logarithmic derivative ℏ·LD(exp(f/ℏ)) converges to f', the derivative of the "classical action" f. This tropicalization of LD connects the EML differential algebra to tropical geometry and the Maslov dequantization.

**Test**: For f(x) = x² and ℏ ∈ {1, 0.1, 0.01, 0.001}, compute ℏ·LD(exp(x²/ℏ)) numerically at x = 1 and verify convergence to f'(1) = 2.

**Impact**: If true, this establishes a rigorous connection between the EML logarithmic derivative algebra and tropical mathematics. The depth hierarchy under tropicalization would correspond to the "tropical depth" of piecewise-linear functions, potentially bridging continuous and combinatorial optimization.

**Catalog References**: `EML/DiffAlgebra.lean` (emlLogDeriv_exp), `Tropical/Tropical_Feynman_Calculus_via_Maslov_Dequantization_of_the_SPB_Classical_Action.lean`

**Proof Strategy**: Use emlLogDeriv_exp to compute ℏ·LD(exp(f/ℏ)) = ℏ·(f'/ℏ) = f' exactly (no limit needed!). The "convergence" is actually an *exact identity*, which is more surprising and more powerful than a limit statement. This exact tropicalization is a consequence of the exp-stripping property of LD.

**Domain Bridges**: EML ↔ Tropical (Maslov dequantization), EML ↔ Physics (semiclassical limit)

**Lineage**: Builds on emlLogDeriv_exp and the observation that LD's exp-stripping is an exact operation.

**Ambition**: extension
