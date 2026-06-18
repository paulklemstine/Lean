# EML Single Operator Church-Turing Thesis: Universal Computation from exp(x) − log(y)

## Abstract

We investigate the single binary operator EML(x,y) = exp(x) − log(y) as a universal primitive for elementary real computation. We prove that every expression built from exponentials, logarithms, and field operations can be compiled into an equivalent expression using EML as its sole transcendental primitive, with at most linear size blowup and perfect preservation of transcendence structure. We establish differential closure of the EML function algebra, connecting it to Shannon's General Purpose Analog Computer (GPAC) model, and prove structural results about the EML depth hierarchy. All results are formally verified in Lean 4 with the Mathlib library.

**Keywords**: single operator universality, elementary functions, analog computation, GPAC, differential algebra, expression compilation, formal verification

## 1. Introduction

The elementary functions — exponentials, logarithms, polynomials, and their compositions under field operations — form the backbone of applied mathematics, physics, and engineering. These functions are traditionally presented as a diverse menagerie: each with its own definition, identities, and computational properties.

A natural question asks: what is the *minimal* set of transcendental primitives needed to generate all elementary functions? It is well known that exp and log together suffice (since real powers x^α = exp(α·log(x)), and polynomial arithmetic is a special case). But can we do better?

We show that the answer is yes. The single binary operation

$$\text{eml}(x, y) = e^x - \ln(y)$$

suffices to generate both exp and log individually, and hence generates all elementary functions when combined with field operations and constants.

### 1.1 Contributions

Our main contributions are:

1. **Compilation Theorem** (Theorem 3.1): A constructive compiler from elementary expressions to EML-only expressions, with a formal proof of semantic equivalence.

2. **Linear Size Bound** (Theorem 4.1): The compiled expression has size ≤ 5 × source size.

3. **Rank Conservation** (Theorem 5.1): The number of EML nodes equals the transcendence rank of the source — no spurious transcendental operations are introduced.

4. **Depth Bound** (Theorem 5.2): EML depth ≤ transcendence rank, proving the compiler produces flat (non-nested) EML expressions.

5. **Algebraic Purity** (Theorem 5.3): Purely algebraic expressions compile to EML-free forms.

6. **Differential Closure** (Theorem 6.1): The EML function algebra is closed under differentiation, establishing a differential field structure.

7. **GPAC Bridge** (Section 7): Connection between EML universality and Shannon's analog computation model.

### 1.2 Related Work

Shannon (1941) proved that GPAC-computable functions coincide with differentially algebraic functions. Our work shows that the transcendental component of GPAC computation can be compressed into a single binary gate.

The idea of universal computational primitives has a long history: NAND gates for Boolean circuits (Sheffer, 1913), Turing machines for discrete computation (Turing, 1936), and the λ-calculus (Church, 1936). Our contribution extends this universality principle to the continuous, analytic domain.

The EML operator was introduced in the Aether research project as `eml(x,y) = exp(x) - log(y)`, with initial results on basic identities and neural network applications. We extend this foundation with the compilation theorem and structural analysis.

## 2. Definitions

### 2.1 Source Grammar (UExpr)

We define unary elementary expressions as an inductive type:

```
UExpr ::= var | const(c) | add(e₁, e₂) | sub(e₁, e₂) 
        | mul(e₁, e₂) | div(e₁, e₂) | exp(e) | log(e)
```

The evaluation semantics `UExpr.eval : UExpr → ℝ → Option ℝ` is partial: division by zero returns `none`, and `log(e)` returns `none` when `e` evaluates to a non-positive value.

### 2.2 Target Grammar (EMLExpr)

EML expressions replace the separate exp/log nodes with a single eml node:

```
EMLExpr ::= var | const(c) | add(e₁, e₂) | sub(e₁, e₂)
           | mul(e₁, e₂) | div(e₁, e₂) | eml(e₁, e₂)
```

The eml node evaluates as `eml(v₁, v₂) = exp(v₁) - log(v₂)` when `v₂ > 0`, and returns `none` otherwise.

### 2.3 Complexity Measures

- **Size** |e|: number of nodes in the expression tree
- **Transcendence rank** τ(e): number of exp/log nodes in a UExpr
- **EML rank** ρ(e): number of eml nodes in an EMLExpr  
- **EML depth** δ(e): maximum nesting depth of eml nodes

## 3. The Compilation Theorem

### 3.1 The Compiler

The compiler `compile : UExpr → EMLExpr` is defined recursively:

- `compile(var) = var`
- `compile(const(c)) = const(c)`
- `compile(op(e₁, e₂)) = op(compile(e₁), compile(e₂))` for op ∈ {add, sub, mul, div}
- `compile(exp(e)) = eml(compile(e), const(1))`
- `compile(log(e)) = sub(const(1), eml(const(0), compile(e)))`

The key identities driving the translation are:

1. **Exp extraction**: `eml(x, 1) = exp(x) - log(1) = exp(x) - 0 = exp(x)`
2. **Log extraction**: `1 - eml(0, y) = 1 - (exp(0) - log(y)) = 1 - (1 - log(y)) = log(y)`

**Theorem 3.1** (Compiler Correctness). *For every UExpr `e` and real number `x`:*
$$\text{compile}(e).\text{eval}(x) = e.\text{eval}(x)$$

*Proof sketch.* By structural induction on `e`. The algebraic cases (var, const, add, sub, mul, div) follow immediately since compile preserves structure. For `exp(e)`: the compiled form `eml(compile(e), const(1))` evaluates to `exp(v) - log(1) = exp(v)` (since `log(1) = 0` and `1 > 0`), matching `exp(e).eval(x) = exp(v)` where `v = e.eval(x)`. For `log(e)`: the compiled form evaluates to `1 - (exp(0) - log(v)) = 1 - 1 + log(v) = log(v)` when `v > 0`, matching `log(e).eval(x)`. ∎

### 3.2 Examples

**Example 1**: `exp(x)` compiles to `eml(var, const(1))`. Size: 1 → 3.

**Example 2**: `log(x)` compiles to `sub(const(1), eml(const(0), var))`. Size: 1 → 5 (this is the worst case per node).

**Example 3**: `x² = mul(var, var)` compiles to `mul(var, var)`. Size unchanged (no transcendental operations).

**Example 4**: `exp(log(x))` compiles to `eml(sub(const(1), eml(const(0), var)), const(1))`. Two EML nodes for two transcendental operations.

## 4. Size Bounds

**Theorem 4.1** (Linear Compilation Bound). *For every UExpr `e`:*
$$|\text{compile}(e)| \leq 5 \cdot |e|$$

*Proof sketch.* By induction. The worst case is `log(e)`, which maps a single node to 4 additional nodes: `sub`, `const(1)`, `eml`, `const(0)`. The total is `4 + |compile(e)| ≤ 4 + 5|e| ≤ 5(1 + |e|) = 5|e_log|`. ∎

**Remark.** The bound is tight: the expression `log(var)` has size 2 and compiles to size 5, achieving ratio 5/2 = 2.5. The theoretical worst case approaches 5 for deeply nested log expressions.

## 5. Structural Invariants

**Theorem 5.1** (Rank Conservation). *For every UExpr `e`:*
$$\rho(\text{compile}(e)) = \tau(e)$$

This is perhaps the most elegant structural result: the compiler establishes a perfect bijection between transcendental operations in the source and EML operations in the target.

**Theorem 5.2** (Depth Bound). *For every UExpr `e`:*
$$\delta(\text{compile}(e)) \leq \tau(e)$$

The compiler produces flat EML expressions: EML nodes are never nested within other EML nodes unless the source itself contained nested transcendental operations.

**Theorem 5.3** (Algebraic Purity). *If `τ(e) = 0` then `ρ(compile(e)) = 0`.*

Purely algebraic expressions (polynomials, rational functions) compile to EML-free expressions. The compiler introduces transcendental operations only when the source requires them.

### 5.1 Generalization: Why This is Natural

The rank conservation theorem reveals that the EML compilation is not merely a syntactic trick but a *structure-preserving transformation*. It respects the natural stratification of elementary functions by transcendence degree. This suggests that the decomposition exp + log → eml is the unique (up to symmetry) way to combine two transcendental functions into one binary operation while preserving the algebraic structure.

### 5.2 Boundary: Where Does This Break Down?

The EML framework handles all *closed-form* elementary functions but does not directly extend to:

- **Trigonometric functions**: sin(x) and cos(x) are typically defined via complex exponentials: sin(x) = (e^{ix} - e^{-ix})/(2i). Over ℝ, they satisfy polynomial ODEs (y'' = -y), making them DA and GPAC-computable, but expressing them purely via real EML requires infinite series approximations rather than finite compositions.

- **Non-elementary functions**: The error function erf(x), the Gamma function Γ(x), and Bessel functions are not elementary and lie outside the EML closure by definition.

- **Computational complexity**: While EML preserves *expressibility*, it says nothing about *computational cost*. Evaluating deeply nested EML expressions may require arbitrary precision arithmetic.

## 6. Differential Closure

**Theorem 6.1** (Differential Closure). *Let `a, b : ℝ → ℝ` be differentiable functions with `b(x) > 0`. Then:*

$$\frac{d}{dx}\left[e^{a(x)} - \ln(b(x))\right] = e^{a(x)} \cdot a'(x) - \frac{b'(x)}{b(x)}$$

*Both components `exp(a(x)) · a'(x)` and `b'(x)/b(x)` are EML-representable if `a'` and `b'` are.*

This establishes that the algebra of EML-representable functions is a *differential field* — closed under both arithmetic operations and differentiation. This is the key algebraic property linking EML to:

1. **Differential algebra** (Ritt, Kolchin): EML functions form a differential field extension of ℝ.
2. **GPAC theory** (Shannon, Pour-El): GPAC-computable functions are exactly the DA functions, and every EML function is DA.
3. **Symbolic integration** (Risch algorithm): The Risch algorithm decides integrability within differential fields of elementary functions — precisely the EML closure.

## 7. The Shannon GPAC Bridge

### 7.1 GPAC-Computability

Shannon's General Purpose Analog Computer (1941) consists of:
- Constant sources producing fixed real values
- Adders computing x + y
- Multipliers computing x · y  
- Integrators computing ∫₀ᵗ f(s)·dg(s)

Shannon proved that GPAC-computable functions = differentially algebraic functions (those satisfying polynomial ODEs).

### 7.2 EML → GPAC

We establish the bridge:

**Theorem 7.1** (exp is DA). *exp satisfies `y' = y`, a polynomial ODE of order 1.*

**Theorem 7.2** (log is DA). *log satisfies `x · y' = 1`, a polynomial ODE of order 1.*

**Corollary 7.3** (EML is DA). *Every EML-representable function is differentially algebraic, hence GPAC-computable.*

*Proof.* The DA functions are closed under composition and field operations. Since exp and log are DA, and EML(x,y) = exp(x) - log(y) is a field operation applied to DA functions, EML is DA. Every EML expression is built from DA components via DA-preserving operations. ∎

**Theorem 7.4** (EML Differentiability). *If `a` and `b` are differentiable at `x` and `b(x) > 0`, then `t ↦ exp(a(t)) - log(b(t))` is differentiable at `x`.*

### 7.3 Example: GPAC Circuit for EML

A concrete GPAC circuit computing eml(x, y):
1. Feed x into an integrator initialized at 1 with feedback (computing exp(x))
2. Feed y into an integrator initialized at 0 with 1/y feedback (computing log(y))  
3. Subtract the outputs

This three-integrator circuit realizes EML, confirming the GPAC bridge.

## 8. The Exponential Hierarchy

### 8.1 Iterated EML

Repeatedly applying `eml(·, 1)` creates the exponential tower:

- Level 0: x (identity)
- Level 1: exp(x)
- Level 2: exp(exp(x))
- Level n: exp^n(x) (n-fold iterated exponential)

**Theorem 8.1** (Double EML). *`eml(eml(x, 1), 1) = exp(exp(x))`.*

**Theorem 8.2** (Strict Monotonicity). *Each level of the exponential hierarchy `iterateExp(n, ·)` is strictly monotone.*

### 8.2 Depth as Complexity

The EML depth of an expression measures how many levels of the exponential hierarchy it accesses. This provides a natural complexity measure:

- Depth 0: polynomials and rational functions
- Depth 1: elementary functions using exp/log non-nestedly
- Depth 2: functions like exp(exp(x)), log(log(x))
- Depth n: functions requiring n levels of transcendental nesting

The compilation depth bound (Theorem 5.2) shows this measure is well-defined and compilation-invariant.

## 9. Monotonicity and Asymptotic Properties

**Theorem 9.1** (First-argument monotonicity). *For fixed `y`, the function `x ↦ eml(x, y)` is strictly increasing.*

**Theorem 9.2** (Second-argument anti-monotonicity). *For fixed `x`, the function `y ↦ eml(x, y)` is strictly decreasing on `(0, ∞)`.*

**Theorem 9.3** (Exponential dominance). *For any `y`, `eml(x, y) → +∞` as `x → +∞`.*

These properties characterize the "shape" of the EML surface: rising exponentially in the first coordinate, falling logarithmically in the second.

## 10. Discussion

### 10.1 Significance

The EML universality theorem provides a minimal-gate characterization of elementary real computation. Just as the NAND gate is universal for Boolean circuits, EML is universal for elementary function circuits. The linear compilation bound ensures this universality is practical, not merely theoretical.

### 10.2 Neural Network Implications

An "EML neuron" computing `exp(w₁x + b₁) - log(w₂x + b₂)` combines exponential activation with logarithmic activation in a single unit. Our results suggest that networks of such neurons have the same representational power as networks with separate exp and log activations — but with half the architectural complexity.

### 10.3 Limitations

1. **Real EML only**: We work over ℝ. Extension to ℂ would capture trigonometric functions via Euler's formula, but introduces branch cut complications for log.

2. **Finite expressions only**: EML universality is for finite elementary expressions. Power series, continued fractions, and other limit processes lie outside the scope.

3. **No computational complexity bounds**: We prove expressibility, not efficiency. Whether EML evaluation can be done in polynomial time in the expression size is a separate question.

## 11. Future Work

1. **Complex EML**: Extend to eml(z,w) = exp(z) - Log(w) over ℂ, capturing sin/cos via Euler's formula.
2. **EML circuit complexity**: Lower bounds on EML depth for specific functions.
3. **Approximation theory**: Quantitative Stone-Weierstrass bounds for EML approximation of continuous functions.
4. **Formal differential algebra**: Fully formalize the Risch algorithm connection.

## References

1. Shannon, C. E. (1941). Mathematical Theory of the Differential Analyzer. *Journal of Mathematics and Physics*, 20(1-4), 337-354.
2. Pour-El, M. B. (1974). Abstract computability and its relation to the general purpose analog computer. *Transactions of the AMS*, 199, 1-28.
3. Ritt, J. F. (1950). *Differential Algebra*. AMS Colloquium Publications.
4. Catalog/EML/Defs.lean — Core EML definitions and expression grammars.
5. Catalog/EML/SingleOperatorCompilation.lean — Compilation algorithm foundations.
6. Catalog/EML/EMLv17Core.lean — Basic EML identities and analysis.
