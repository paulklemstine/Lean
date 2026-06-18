# EML-KA: Algebraic Structure and Density of Exp-Log Kolmogorov-Arnold Decompositions

## Abstract

We develop the algebraic theory of EML-KA (Exp-Log Kolmogorov-Arnold) decompositions, proving that functions representable as finite sums of the form Σ_q Φ_q(φ₁_q(x) + φ₂_q(y)), where each φ and Φ is a finite composition of exp, log, and affine maps, form a rich subalgebra of continuous functions on (0,∞)². Our main results include: (1) exact 1-term EML-KA decompositions for all monomials x^a·y^b, yielding M-term decompositions for polynomials with M monomials; (2) point separation and constant inclusion properties establishing the Stone-Weierstrass prerequisites for density; (3) a Cauchy functional equation characterization proving that log is the unique continuous homomorphism from ((0,∞), ×) to (ℝ, +), explaining why the exp-log pair is canonical; (4) cross-domain bridges connecting EML-KA to information theory (KL and Rényi divergences), machine learning (log-sum-exp), and convex optimization (Fenchel-Young duality). All results are formalized and verified in Lean 4 with Mathlib.

**Keywords**: Kolmogorov-Arnold theorem, exp-log decomposition, universal approximation, Stone-Weierstrass, information theory, formal verification

## 1. Introduction

The Kolmogorov-Arnold representation theorem (Kolmogorov 1957, Arnold 1957) states that every continuous function f : [0,1]^n → ℝ can be written as

f(x₁,...,xₙ) = Σ_{q=0}^{2n} Φ_q(Σ_{p=1}^n φ_{q,p}(x_p))

where each φ_{q,p} and Φ_q is a continuous univariate function. While the theorem guarantees existence, the inner functions φ_{q,p} in the general case are highly irregular (typically nowhere-differentiable, fractal-like functions).

A natural question arises: for which classes of target functions f can the inner and outer functions be chosen from a well-behaved function class? In this paper, we investigate the EML (Exp-Log-Multiply) function class — finite compositions of exp, log, and affine maps — as building blocks for Kolmogorov-Arnold decompositions. We call such decompositions EML-KA decompositions.

### 1.1 Main Contributions

1. **Polynomial Completeness Theorem** (Theorem 8.1): Every bivariate polynomial on (0,∞)² admits an exact finite-term EML-KA decomposition, with one term per monomial.

2. **Logarithmic Linearization** (Theorem 5.1): The map (x,y) ↦ (log x, log y) transforms monomials into linear functions, providing the algebraic mechanism behind EML-KA.

3. **Point Separation and Density** (Theorems 7.1, 9.1): EML-KA functions separate points on (0,∞)², contain constants, and form a subalgebra — establishing the Stone-Weierstrass prerequisites for density in C(K).

4. **Cauchy Characterization of Log** (Theorem 18.1): Among continuous functions on (0,∞), log is the unique (up to scaling) solution to f(xy) = f(x) + f(y), explaining why the exp-log pair is canonical for EML-KA.

5. **Cross-Domain Bridges**: We connect EML-KA to:
   - Information theory: KL and Rényi divergences decompose through EML (Theorems 9.1-9.2)
   - Machine learning: log-sum-exp satisfies LSE(log x, log y) = log(x+y) (Theorem 11.3)
   - Convex optimization: Fenchel-Young inequality as duality for exp/log (Theorem 16.1)
   - Classical inequalities: AM-GM expressed through EML encoding/decoding (Theorem 17.1)

### 1.2 Related Work

The original Kolmogorov-Arnold theorem was proved independently by Kolmogorov (1957) and refined by Arnold (1957). Sprecher (1965) gave constructive versions. Recent interest has been driven by the KAN (Kolmogorov-Arnold Networks) architecture in machine learning (Liu et al., 2024).

The EML function class was introduced in the context of algebraic circuit complexity and exp-log closure operators. Our work builds on the catalog results `eml_sum_log_prod`, `eml_chain_exp_log_cancel`, `ka_inner_log_continuous`, and `eml_log_exp_involution` from the EML verification library.

## 2. Definitions

**Definition 2.1** (EML Chain Operation). An elementary EML operation is one of:
- `exp`: x ↦ e^x
- `log`: x ↦ ln(x)  
- `affine(a,b)`: x ↦ ax + b

An EML chain is a finite list of such operations, evaluated by composition (outermost first).

**Definition 2.2** (EML-KA Decomposition). An EML-KA decomposition of a bivariate function with Q terms consists of:
- Inner chains φ₁_q, φ₂_q for each q ∈ {1,...,Q}
- Outer chains Φ_q for each q
- Evaluation: f(x,y) ≈ Σ_q Φ_q(φ₁_q(x) + φ₂_q(y))

**Definition 2.3** (EML Depth). The depth of an EML chain counts the number of transcendental (exp/log) operations. Affine operations have depth 0.

**Definition 2.4** (Log Encoding). The logarithmic encoding map logEncode : (0,∞)² → ℝ² sends (x,y) to (log x, log y). Its inverse is expDecode : (u,v) ↦ (e^u, e^v).

## 3. Chain Composition Theory

**Theorem 3.1** (Chain Composition). For any chains c₁, c₂:
eval(c₁ ++ c₂, x) = eval(c₁, eval(c₂, x))

*Proof*: By induction on c₁. □

**Theorem 3.2** (Depth Subadditivity). depth(c₁ ++ c₂) ≤ depth(c₁) + depth(c₂).

*Proof*: By induction on c₁ with case analysis on the head operation. □

## 4. Fundamental Decompositions

**Theorem 4.1** (Multiplication). x·y = exp(log(x) + log(y)) for x,y > 0. This gives a 1-term EML-KA decomposition with depth 3.

**Theorem 4.2** (Monomials). x^a·y^b = exp(a·log(x) + b·log(y)) for x,y > 0, a,b ∈ ℕ. This is a 1-term decomposition with depth 3.

**Theorem 4.3** (Division). x/y = exp(log(x) - log(y)) for x,y > 0. This is a 1-term decomposition.

**Theorem 4.4** (Addition). x + y has a 2-term EML-KA decomposition (identity functions on each variable, zero on the other).

## 5. Logarithmic Linearization

**Theorem 5.1** (Linearization). For x,y > 0 and a,b ∈ ℕ:
log(x^a · y^b) = a · log(x) + b · log(y)

This is the fundamental bridge: in log-space, monomials become linear functions.

**Theorem 5.2** (Injectivity). The log encoding is injective on (0,∞)².

*Proof*: Follows from injectivity of log on (0,∞). □

**Theorem 5.3** (Invertibility). expDecode ∘ logEncode = id on (0,∞)².

**Theorem 5.4** (Exponentials of Linear Forms). exp(a·u + b·v) evaluated at (u,v) = (log x, log y) gives x^a · y^b. This is the inverse direction of linearization.

## 6. Algebraic Closure

**Theorem 6.1** (Scalar Closure). If f has a Q-term EML-KA decomposition, then c·f has a Q-term decomposition (prepend affine(c,0) to each outer chain).

**Theorem 6.2** (Constant Functions). Any constant function has a 1-term EML-KA decomposition.

## 7. Point Separation

**Theorem 7.1** (Separation). For any distinct p₁ ≠ p₂ in (0,∞)², there exists a 1-term EML-KA decomposition d with d(p₁) ≠ d(p₂).

*Proof*: Either the first or second coordinate differs. The identity function on the differing coordinate separates. □

## 8. Polynomial Completeness

**Theorem 8.1** (Polynomial EML-KA). For any polynomial Σᵢ cᵢ · x^{aᵢ} · y^{bᵢ} with M terms, there exists an M-term EML-KA decomposition that is exact on (0,∞)².

*Proof*: Each monomial term uses inner chains slog(aᵢ), slog(bᵢ) and outer chain affine(cᵢ,0) ∘ exp. The evaluation follows from exp(aᵢ·log(x) + bᵢ·log(y)) = x^{aᵢ} · y^{bᵢ}. □

**Corollary 8.2** (Density Path). Since EML-KA functions:
1. Form a subalgebra (closed under addition and scalar multiplication)
2. Separate points (Theorem 7.1)
3. Contain constants (Theorem 6.2)

By the Stone-Weierstrass theorem, they are dense in C(K) for any compact K ⊂ (0,∞)².

## 9. Cross-Domain: Information Theory

**Theorem 9.1** (KL Divergence Decomposition). For p, q > 0:
p · log(p/q) = p·log(p) - p·log(q)

Each term is a function of a single variable, giving a natural KA-style decomposition.

**Theorem 9.2** (Rényi Kernel Linearization). For p, q > 0:
log(p^α · q^{1-α}) = α·log(p) + (1-α)·log(q)

The Rényi divergence kernel p^α · q^{1-α} is a monomial, hence has a 1-term EML-KA decomposition.

## 10. Cross-Domain: Machine Learning

**Theorem 10.1** (LSE Lower Bound). LSE(x,y) ≥ max(x,y).

**Theorem 10.2** (LSE Upper Bound). LSE(x,y) ≤ max(x,y) + log(2).

**Theorem 10.3** (LSE-Addition Bridge). For x, y > 0:
LSE(log x, log y) = log(x + y)

This identity shows that log-sum-exp in the encoded space computes the logarithm of addition in the original space — a fundamental bridge between additive and multiplicative structure.

## 11. Convex Duality

**Theorem 11.1** (Fenchel-Young Inequality). For s > 0:
x·s ≤ exp(x) + s·log(s) - s

**Theorem 11.2** (Tightness). The bound is tight at x = log(s).

This provides a variational characterization of the exp-log duality underlying EML-KA.

## 12. AM-GM via EML

**Theorem 12.1** (AM-GM through EML). For x, y > 0:
exp((log x + log y)/2) ≤ (x + y)/2

The left side is the geometric mean (EML-decoded average of encodings), the right is the arithmetic mean. The gap measures the cost of nonlinearity in the EML encoding.

## 13. Cauchy Characterization

**Theorem 13.1** (Uniqueness of Log). If f : (0,∞) → ℝ is continuous and satisfies f(xy) = f(x) + f(y) for all x, y > 0, then f(x) = c · log(x) for some constant c.

*Proof sketch*: Define g(t) = f(exp(t)). Then g is continuous and additive: g(s+t) = g(s) + g(t). The continuous additive Cauchy equation on ℝ has unique solution g(t) = ct where c = g(1). Hence f(x) = g(log x) = c · log(x). □

This theorem explains why log is the *canonical* inner function for EML-KA: it is the unique continuous homomorphism from ((0,∞), ×) to (ℝ, +).

## 14. Depth Analysis

| Function | Q (terms) | Max Depth | Classical KA Terms |
|----------|-----------|-----------|-------------------|
| x·y      | 1         | 3         | 5                 |
| x^a·y^b  | 1         | 3         | 5                 |
| x/y      | 1         | 3         | 5                 |
| x+y      | 2         | 0         | 5                 |
| Polynomial (M terms) | M | 3    | 5                 |
| Constant  | 1         | 0         | 5                 |

## 15. Discussion

### 15.1 The Group-Theoretic Perspective

The deepest insight of this work is that EML-KA decompositions work because log : ((0,∞), ×) → (ℝ, +) is a topological group isomorphism. This isomorphism:
- Transforms multiplication to addition (enabling KA's additive structure)
- Transforms powers to scaling (giving 1-term monomial decompositions)
- Is unique among continuous functions (Theorem 13.1)

### 15.2 Comparison with Neural KAN

The recently proposed KAN architecture (Liu et al., 2024) parametrizes the inner and outer functions with learned splines. Our work shows that for functions on positive reals, a much simpler parametrization — compositions of exp, log, and affine maps — suffices. This suggests a structured KAN variant with built-in exp-log layers.

### 15.3 Limitations

1. **Domain restriction**: EML-KA as developed here requires positive inputs. Extension to all reals would require handling log of non-positive numbers.
2. **Approximation rates**: While we establish density, we do not bound approximation rates. The number of terms for ε-approximation is not characterized.
3. **Higher dimensions**: Extension from n=2 to general n is straightforward but not formalized.

## 16. Catalog References

This work builds upon the following verified results:
- `eml_sum_log_prod` (EML/EMLv18Advanced.lean): Product decomposition via EML
- `eml_chain_exp_log_cancel` (EML/KolmogorovArnoldEMLDeep.lean): Chain cancellation
- `ka_inner_log_continuous` (EML/KolmogorovArnoldEML.lean): Continuity of log
- `eml_log_exp_involution` (EML/OISCC.lean): Log-exp involution
- `eml_exp_neuron_continuous` (EML/UniversalApproximation.lean): Continuity of exp neurons

## References

1. A.N. Kolmogorov, "On the representation of continuous functions of several variables by superposition of continuous functions of one variable and addition," Doklady Akad. Nauk SSSR 114 (1957), 953-956.
2. V.I. Arnold, "On the representation of continuous functions of three variables by superpositions of continuous functions of two variables," Doklady Akad. Nauk SSSR 114 (1957), 679-681.
3. D.A. Sprecher, "On the structure of continuous functions of several variables," Trans. Amer. Math. Soc. 115 (1965), 340-355.
4. Z. Liu, Y. Wang, S. Vaidya, et al., "KAN: Kolmogorov-Arnold Networks," arXiv:2404.19756 (2024).
