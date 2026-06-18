# Future Directions

## Synthesis

This cycle established the EML (Exp-Multiply-Log) algebra as a formally verified mathematical framework for studying exp-log networks. The three main results — the EML Density Theorem, the Monomial Depth Theorem, and the depth filtration — form a triangle connecting functional analysis (Stone-Weierstrass density), algebraic complexity theory (circuit depth), and neural network theory (universal approximation).

The most promising cross-domain connection is between the **depth filtration** and **neural network depth hierarchies**. The Monomial Depth Theorem shows that exp-log operations achieve exponential compression over arithmetic operations for representing monomials. This connects to the catalog's `not_exists_uniform_exp_depth_bound` (from `Bridges/ArrowDepthComplexity.lean`), which establishes that no uniform depth bound exists for certain function classes — our work shows *where* the depth boundary lies for monomials specifically.

The highest breakthrough potential lies in Direction 1 (Jackson-type quantitative rates), because it would bridge the gap between the existential guarantee of Stone-Weierstrass and the constructive requirements of practical approximation theory. If successful, it would give EML networks a provable advantage over polynomial approximation with explicit, computable bounds.

---

### Direction 1: Quantitative EML Approximation Rates (Jackson-type Bounds)

**Conjecture**: For f ∈ Lip_α([a,b]) (α-Hölder continuous with constant L) and K = [a,b] ⊂ (0,∞), there exists an EML term t of size at most C · (L/ε)^{1/α} such that |f(x) - eval(t, x)| < ε for all x ∈ K, where C depends only on a, b, and α.

More precisely: the best EML approximation error E_n(f) = inf{‖f - eval(t,·)‖_∞ : size(t) ≤ n} satisfies E_n(f) ≤ C · ω(f, 1/n^α) where ω is the modulus of continuity.

**Test**: First prove the bound for monomials f(x) = x^k (where the EML term is exact, giving E_5(f) = 0). Then attempt Lipschitz functions f with Lip constant L on [1,2], constructing explicit piecewise-EML approximations using the partition of unity approach.

**Impact**: If true, this gives EML networks a provable, constructive approximation guarantee with explicit rates — going beyond the existential guarantee of Stone-Weierstrass. This would be the first formal result linking EML circuit complexity to function smoothness. If false, the failure would reveal fundamental limitations of exp-log circuits compared to polynomial circuits (which do satisfy Jackson's theorem).

**Catalog References**: `Bridges/ContinuousDiscreteTransfer.lean` (lipschitz_cellwise_error_bound), `MachineLearning/ClosureNetworkBreakthrough.lean` (lipschitz_error_bound_closure_net)

**Proof Strategy**:
1. Establish that EML terms on [a,b] ⊂ (0,∞) are Lipschitz with constants bounded by an expression involving depth and the interval endpoints.
2. Use the monomial representation (depth 3) to construct polynomial approximations within the EML algebra.
3. Apply Jackson's theorem for polynomials, then translate the polynomial approximation bound into an EML circuit size bound.
4. Key lemma needed: bound the EML size required to represent a polynomial of degree d (it should be O(d log d) using binary addition trees).

**Domain Bridges**: Functional Analysis (modulus of continuity) ↔ Circuit Complexity (EML depth/size) ↔ Machine Learning (approximation rates for networks)

**Lineage**: Builds on EML Density Theorem (this cycle) and lipschitz_cellwise_error_bound from the catalog.

**Ambition**: grand_challenge

---

### Direction 2: Strict EML Depth Hierarchy

**Conjecture**: For each d ≥ 1, there exists a continuous function f_d ∈ C([1,2], ℝ) such that f_d cannot be ε-approximated by any EML term of depth less than d, for some fixed ε > 0 depending on d. In other words, the depth filtration is *strictly increasing* in approximation power.

Candidate separating functions:
- Depth 1 vs 0: f₁(x) = exp(x) (cannot be approximated by constants and id at depth 0)
- Depth 2 vs 1: f₂(x) = exp(exp(x)) (iterated exponential)
- Depth d vs d-1: f_d(x) = exp^{(d)}(x) (d-fold iterated exponential)

**Test**: For the depth 1 vs 0 case, prove that no affine function a·x + b can uniformly approximate exp(x) on [1,2] within ε = 0.1. This reduces to computing inf_{a,b} sup_{x ∈ [1,2]} |exp(x) - ax - b| and showing it exceeds 0.1. Computationally verify with Python: the best affine approximation to exp on [1,2] has error ≈ 0.067, so ε = 0.1 may be too generous — try ε = 0.01. For higher depths, the verification becomes harder.

**Impact**: A strict depth hierarchy would be the EML analogue of classical circuit complexity separation results. It would prove that the depth filtration captures genuine computational complexity, not just syntactic complexity. This connects to the catalog's `not_exists_uniform_exp_depth_bound`, potentially providing a more refined version.

**Catalog References**: `Bridges/ArrowDepthComplexity.lean` (not_exists_uniform_exp_depth_bound), `EML/KolmogorovArnoldEMLDeep.lean` (chainDepth)

**Proof Strategy**:
1. Prove that depth-0 EML functions are exactly the polynomials of degree ≤ 1 (affine functions).
2. Show that exp has superlinear growth, so no affine function can approximate it well on [1,2].
3. For higher depths, use the growth rate of iterated exponentials: exp^{(d)}(x) grows as a tower function, while depth-(d-1) EML terms have bounded growth rate.
4. Key lemma: upper bound on the growth rate of depth-d EML terms on compact sets.

**Domain Bridges**: Circuit Complexity (depth separation) ↔ Real Analysis (growth rates) ↔ EML Theory (depth filtration)

**Lineage**: Builds on depth filtration (this cycle) and not_exists_uniform_exp_depth_bound from catalog.

**Ambition**: grand_challenge

---

### Direction 3: Multivariate EML Density on Compact Subsets of (0,∞)^n

**Conjecture**: The multivariate EML algebra on K ⊂ (0,∞)^n — generated by coordinate projections π₁,...,πn, exp, log, +, × — is dense in C(K, ℝ) for any compact K ⊂ (0,∞)^n.

**Test**: Prove the result for n = 2 by verifying that the multivariate EML generators separate points of K ⊂ (0,∞)². Two points (x₁,x₂) ≠ (y₁,y₂) differ in at least one coordinate, so π_i separates them. Then apply the multivariate Stone-Weierstrass theorem.

**Impact**: Extends the EML Density Theorem to the practically important multivariate case, relevant for multi-input neural networks. The multivariate monomial x₁^{a₁} · x₂^{a₂} = exp(a₁ log(x₁) + a₂ log(x₂)) still has bounded depth, extending the compression result.

**Catalog References**: `Applications/EMLStoneWeierstrass.lean` (eml_dense, emlSubalgebra_separatesPoints)

**Proof Strategy**:
1. Define multivariate EML terms with n variable constructors var(i) for i ∈ {1,...,n}.
2. Define the multivariate EML subalgebra as Algebra.adjoin ℝ {π₁,...,πn, exp, log}.
3. Prove separation: coordinate projections separate points of (0,∞)^n.
4. Apply Stone-Weierstrass.
5. Prove multivariate monomial depth theorem: x₁^{a₁}···xn^{an} has depth 3 + ⌈log₂ n⌉.

**Domain Bridges**: Multivariable Analysis ↔ EML Theory ↔ Machine Learning (multi-input networks)

**Lineage**: Direct extension of the univariate EML Density Theorem (this cycle).

**Ambition**: extension

---

### Direction 4: EML Complexity of Elementary Functions

**Conjecture**: Every elementary function (in the sense of Liouville — finite compositions of exp, log, algebraic functions, and their inverses) restricted to a compact K ⊂ (0,∞) has finite EML depth. Moreover, the minimum EML depth of common functions satisfies:
- sin(x) on [0.1, 3]: minimum EML depth is infinite (sin is not in the EML algebra), but the minimum *approximation depth* for ε-approximation is O(log(1/ε)).
- The gamma function Γ(x) on [1, 3]: also not exactly EML-representable, but ε-approximable at depth O(log(1/ε)).

**Test**: Verify computationally that sin(x) on [0.1, 3] can be approximated to 6 decimal places by an EML term of depth ≤ 10. Construct the approximation explicitly using Taylor series within the EML framework: sin(x) ≈ x - x³/6 + x⁵/120 - ..., where each x^k = exp(k log(x)).

**Impact**: Understanding which functions have low EML complexity gives a "computational map" of function space, analogous to computational complexity classes. Functions with low EML depth are "easy" for exp-log networks; those with high minimum depth are "hard."

**Catalog References**: `EML/AdvancedTheory.lean` (ensembleComplexity), `EML/EMLv17Core.lean` (eml, sigmaEml)

**Proof Strategy**:
1. Express Taylor partial sums as EML terms (using the monomial depth theorem for each x^k).
2. Bound the total EML depth of a degree-N Taylor partial sum: it is 3 + ⌈log₂ N⌉ (depth 3 for monomials, plus ⌈log₂ N⌉ for summing N terms).
3. Use Taylor remainder bounds to relate N to ε.
4. Combine: ε-approximation requires EML depth ≤ 3 + ⌈log₂ N(ε)⌉ where N(ε) is the Taylor degree needed for error ε.

**Domain Bridges**: Classical Analysis (Taylor series) ↔ EML Complexity ↔ Numerical Methods (function evaluation)

**Lineage**: Builds on Monomial Depth Theorem (this cycle) and ensembleComplexity from the catalog.

**Ambition**: extension

---

### Direction 5: Tropical EML Connection

**Conjecture**: The tropical limit (as temperature T → 0) of the EML algebra converges to the tropical semiring algebra. Specifically, define the T-scaled EML evaluation:
```
eval_T(exp(t), x) = T · log(exp(eval_T(t, x) / T))
```
Then as T → 0, the EML operations exp and log degenerate to tropical max and identity, recovering the tropical semiring {max, +} from {exp, log, +, ×}.

**Test**: Verify computationally for specific EML terms that T-scaled evaluation converges to tropical evaluation as T → 0. For example, T · log(exp(a/T) + exp(b/T)) → max(a, b) as T → 0.

**Impact**: This would provide a formal bridge between EML networks and tropical geometry, connecting the catalog's tropical semiring results to the EML framework. It would show that tropical networks are the "zero-temperature limit" of EML networks, unifying two apparently separate lines of research.

**Catalog References**: `Bridges/TropicalStoneWeierstrass.lean` (tropical_stone_weierstrass_eml_dense), `Tropical/Applications.lean` (tropical_network_lipschitz_bound)

**Proof Strategy**:
1. Define T-scaled EML evaluation as a family parameterized by T > 0.
2. Prove that T · log(exp(a/T) + exp(b/T)) → max(a, b) as T → 0 (this is the classical softmax-to-max convergence).
3. Show that T-scaled EML evaluation converges pointwise to tropical evaluation for all EML terms.
4. Investigate whether the convergence is uniform on compact sets.

**Domain Bridges**: EML Theory ↔ Tropical Geometry ↔ Statistical Mechanics (temperature limits)

**Lineage**: Builds on EML Density Theorem (this cycle) and tropical_stone_weierstrass_eml_dense from catalog.

**Ambition**: grand_challenge
