# Future Directions: Recursive Spectral Certification of Lorentzian Polynomials

## Synthesis

The completeness of recursive spectral certification for Lorentzian polynomials opens multiple avenues at the intersection of algebraic combinatorics, spectral theory, discrete convex analysis, and verified computation. The five directions below form a coherent research program: Direction 1 connects Lorentzianity to matroid theory and Hodge theory through the support exchange property; Direction 2 extends the spectral certificate to the multilinear and non-homogeneous settings where applications in probability and statistical physics live; Direction 3 bridges to certified numerical computation, making the recognition algorithm practically deployable; Direction 4 pushes toward the hardest open problems in log-concavity via the polynomial machinery; and Direction 5 connects to optimization theory and convex geometry. Together, they transform the recursive spectral certificate from a theoretical characterization into a computational tool with verified guarantees across multiple domains.

---

## Direction 1: M-Convexity Closure Under Differentiation

**Conjecture**: The support exchange property (M-convexity) is preserved by partial differentiation. That is, if $p$ is a homogeneous polynomial with nonneg coefficients whose support satisfies the matroid exchange axiom, then the support of $\partial p / \partial x_i$ also satisfies the exchange axiom.

Formally:
```
theorem SupportSatisfiesExchange.pderiv
    {n : ℕ} {p : MvPolynomial (Fin n) ℝ} {i : Fin n} :
    SupportSatisfiesExchange p →
    SupportSatisfiesExchange (MvPolynomial.pderiv i p)
```

**Test**: Exhaustively verify for all M-convex supports of degree ≤ 6 in ≤ 5 variables that the derivative support remains M-convex. A single counterexample disproves the conjecture; conversely, verified examples up to this bound provide strong evidence.

**Impact**: This would complete the formal bridge between Lorentzian polynomial theory and matroid/discrete convex analysis, showing that the entire derivative hierarchy preserves the combinatorial structure of the support. It would also provide a new proof technique for M-convexity results in matroid theory.

**The key insight is** that M-convexity of support is the combinatorial shadow of Lorentzianity, and the differentiation operation on polynomials corresponds to contraction in matroid theory. Proving this formally would establish a new certified interface between algebraic combinatorics and discrete convex analysis.

**Why now?** The formal definitions of both SupportSatisfiesExchange and partial differentiation are now in the catalog, and the Brändén–Huh theory provides the mathematical framework. The exhaustive computational verification is newly feasible with the recognition algorithm.

**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` — `SupportSatisfiesExchange`, `pderiv_coeff_nonneg`

**Proof Strategy**: Induction on degree. The base case (degree 2) reduces to checking that 2×2 exchange axiom is preserved. The inductive step uses the multilinearity of the derivative and the exchange axiom structure.

**Domain Bridges**: Matroid theory, discrete convex analysis, Hodge theory

**Lineage**: Extends `recursive_complete_of_exchange` and `pderiv_coeff_nonneg`

**Ambition**: Solid extension — this is a known consequence of Brändén–Huh theory but has not been formally verified

---

## Direction 2: Lorentzian Polynomials in Statistical Physics and Probability

**Conjecture**: The partition function of any determinantal point process (DPP), when restricted to its homogeneous components, yields Lorentzian polynomials. This implies that all marginal inclusion probabilities satisfy the negative dependence inequality $\Pr[i \in S \text{ and } j \in S] \le \Pr[i \in S] \cdot \Pr[j \in S]$.

Formally:
```
theorem dpp_partition_function_lorentzian
    {n : ℕ} (K : Matrix (Fin n) (Fin n) ℝ) (hK : K.PosSemidef) (d : ℕ) :
    IsBrandenHuhLorentzian d (homogeneousComponent d (dppPartitionFunction K))
```

**Test**: For random PSD matrices $K$ of size $n \le 8$, compute the partition function, extract homogeneous components, and verify Lorentzianity via the spectral recognizer. Compare marginal correlations against the negative dependence bound.

**Impact**: This would provide the first formally verified proof of negative dependence for DPPs, a fundamental result in probability and statistical physics. It would connect Lorentzian polynomial theory to random matrix theory, repulsive particle systems, and machine learning (DPPs are widely used for diverse subset selection).

**The key insight is** that the partition function $\det(I + \text{diag}(x) \cdot K)$ for PSD $K$ is a product of linear forms in the eigenvalue basis, making it manifestly Lorentzian. The formal challenge is connecting this spectral decomposition to the polynomial coefficient structure.

**Why now?** DPPs are experiencing a surge of interest in machine learning and spatial statistics. Formally verified negative dependence guarantees would be valuable for certified randomized algorithms.

**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` — `IsBrandenHuhLorentzian`, `lorentzian_reversed_cauchy_schwarz`

**Proof Strategy**: Decompose $\det(I + DK)$ in the eigenbasis of $K$. Each factor is a positive linear form, so the product is Lorentzian by the closure property. Transfer back to the standard basis.

**Domain Bridges**: Probability theory, statistical physics, machine learning, random matrix theory

**Lineage**: Extends `lorentzian_reversed_cauchy_schwarz` and `spectralRecognizer_sound`

**Ambition**: Grand challenge — connecting algebraic combinatorics to probability theory at the formal level

---

## Direction 3: Certified Exact Arithmetic for Spectral Recognition

**Conjecture**: For polynomials with rational coefficients, the Lorentzian signature condition can be verified in exact arithmetic using the Sylvester criterion (signs of leading principal minors of the Hessian shifted by a rank-1 perturbation), avoiding all floating-point issues.

Formally:
```
theorem rational_spectral_recognizer_decidable
    {n : ℕ} (d : ℕ) (p : MvPolynomial (Fin n) ℚ) :
    Decidable (IsRecursivelyLorentzian d (p.map (algebraMap ℚ ℝ)))
```

**Test**: Implement the rational Sylvester criterion and compare against floating-point eigenvalue computation for all polynomials with coefficients in {0,1,2,3} of degree ≤ 4 in ≤ 4 variables. Any disagreement indicates a numerical stability issue.

**Impact**: This would make Lorentzian recognition fully certified — not just mathematically sound, but computationally exact. It would enable trusted automated verification of log-concavity conjectures in combinatorics.

**The key insight is** that the "at most one positive eigenvalue" condition for a symmetric matrix can be reformulated as: the matrix $H - \epsilon \cdot vv^T$ is negative semidefinite for some small $\epsilon > 0$ and direction $v$. This can be checked via the Sylvester criterion using only determinants (exact rational arithmetic).

**Why now?** The spectral recognizer algorithm is now formally verified for soundness and completeness. The remaining gap is computational — bridging from real-number eigenvalue conditions to decidable rational-arithmetic checks.

**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` — `spectralRecognizerProp`, `HasAtMostOnePositiveEigenvalue`

**Proof Strategy**: Reformulate the eigenvalue condition in terms of the characteristic polynomial. Use Sturm's theorem or Descartes' rule of signs to count positive roots of the characteristic polynomial in exact rational arithmetic.

**Domain Bridges**: Numerical linear algebra, certified computation, computer algebra

**Lineage**: Extends `spectralRecognizer_correct` and `quadratic_leaf_count_le`

**Ambition**: Solid extension — decidability results for eigenvalue conditions are classical, but formal verification is novel

---

## Direction 4: Mason's Conjecture via Lorentzian Polynomials

**Conjecture**: For any matroid $M$ on ground set $[n]$, the sequence $f_0, f_1, \ldots, f_r$ of numbers of independent sets of each size is ultra-log-concave: $\frac{f_k^2}{\binom{n}{k}^2} \ge \frac{f_{k-1}}{\binom{n}{k-1}} \cdot \frac{f_{k+1}}{\binom{n}{k+1}}$.

This is Mason's conjecture (now a theorem by Anari–Liu–Oveis Gharan–Vinzant and Brändén–Huh), but a formal verification is still open.

Formally:
```
theorem mason_conjecture_formal
    {n r : ℕ} (M : Matroid (Fin n)) (k : ℕ) (hk : 1 ≤ k) (hkr : k < r) :
    (independentSetsOfSize M k)^2 * Nat.choose n (k-1) * Nat.choose n (k+1) ≥
    (independentSetsOfSize M (k-1)) * (independentSetsOfSize M (k+1)) * (Nat.choose n k)^2
```

**Test**: Verify computationally for all matroids on ≤ 8 elements. Any counterexample would disprove the theorem (which is known to be true, so none should exist).

**Impact**: Formal verification of Mason's conjecture would be a landmark result in formalized mathematics — one of the most celebrated recent theorems in combinatorics, proved using the full power of Lorentzian polynomial theory.

**The key insight is** that the independent set generating polynomial of a matroid is Lorentzian (Brändén–Huh), and ultra-log-concavity follows from the reversed Cauchy–Schwarz inequality applied to specializations.

**Why now?** The reversed Cauchy–Schwarz inequality is now formally verified (`lorentzian_reversed_cauchy_schwarz`), and the recursive spectral certificate provides the connection to Lorentzianity. The remaining work is formalizing the matroid-to-polynomial bridge.

**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` — `lorentzian_reversed_cauchy_schwarz`, `IsBrandenHuhLorentzian`

**Proof Strategy**: (1) Define the independent set polynomial. (2) Show it is Lorentzian via the basis generating polynomial and deletion-contraction. (3) Apply reversed Cauchy–Schwarz to a 2-variable specialization. (4) Extract ultra-log-concavity.

**Domain Bridges**: Matroid theory, combinatorics, Hodge theory

**Lineage**: Extends `lorentzian_reversed_cauchy_schwarz` and `recursivelyLorentzian_iff_brandenHuh`

**Ambition**: Grand challenge — formalizing a major theorem of 21st-century combinatorics

---

## Direction 5: Lorentzian Certificates for Convex Optimization

**Conjecture**: For any homogeneous Lorentzian polynomial $p$ of degree $d$, the function $x \mapsto p(x)^{1/d}$ is concave on the cone $\{x \in \mathbb{R}_{\ge 0}^n : p(x) > 0\}$. This concavity certificate can be verified in polynomial time (for fixed $d$) using the recursive spectral certificate.

Formally:
```
theorem lorentzian_root_concave
    {n d : ℕ} {p : MvPolynomial (Fin n) ℝ}
    (hL : IsRecursivelyLorentzian d p) (hd : 0 < d)
    (x y : Fin n → ℝ) (hx : ∀ i, 0 ≤ x i) (hy : ∀ i, 0 ≤ y i)
    (hpx : eval x p > 0) (hpy : eval y p > 0) (t : ℝ) (ht : 0 ≤ t) (ht1 : t ≤ 1) :
    eval (t • x + (1 - t) • y) p ^ (1 / d : ℝ) ≥
    t * (eval x p) ^ (1 / d : ℝ) + (1 - t) * (eval y p) ^ (1 / d : ℝ)
```

**Test**: Numerically verify concavity of $p^{1/d}$ on random points in the positive cone for all Lorentzian polynomials in the test suite. Any convexity violation would be a counterexample.

**Impact**: This would provide certified concavity guarantees for optimization, connecting Lorentzian polynomial theory to barrier methods, self-concordant functions, and interior-point algorithms. It could enable new polynomial-time algorithms for optimization over Lorentzian-definable sets.

**The key insight is** that the tangent-space negativity theorem (already proven) is the infinitesimal version of this concavity statement. The global concavity follows by integration along geodesics in the positive cone, using the reversed Cauchy–Schwarz as the key inequality.

**Why now?** The tangent-space negativity theorem is now formally verified, providing the key local ingredient. The global-from-local argument is well-understood analytically and should be formalizable with existing Mathlib calculus infrastructure.

**Catalog References**: `Pythagorean/LorentzianRecognitionComplete.lean` — `lorentzian_signature_tangent_neg_semidef`, `lorentzian_reversed_cauchy_schwarz`

**Proof Strategy**: (1) Prove that the Hessian of $\log p$ is negative semidefinite on the tangent space (follows from tangent-space negativity). (2) Conclude $\log p$ is concave. (3) Exponentiate and use the AM-GM inequality to get $p^{1/d}$ concavity.

**Domain Bridges**: Convex optimization, interior-point methods, self-concordant barriers, computational geometry

**Lineage**: Extends `lorentzian_signature_tangent_neg_semidef`

**Ambition**: Solid extension with high practical impact — bridges pure algebraic combinatorics to applied optimization
