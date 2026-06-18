# Future Directions: Hessian Descent for Lorentzian Polynomials

## Synthesis

The Hessian descent program transforms Lorentzian polynomial theory from a spectral-geometric framework into a combinatorial-arithmetic one. The principal minor lemma (proved in `Catalog/Pythagorean/HessianDescent.lean`) provides the foundational algebraic bridge: for symmetric matrices with nonneg diagonal, the at-most-one-positive-eigenvalue condition forces all 2×2 minors to be nonpositive. Combined with the exchange support property from matroid theory, this yields a discrete certificate for Lorentzianity.

The forward direction is established: Lorentzian → coefficient inequalities. The precise gap in the converse (stemming from multinomial factors in the derivative-coefficient formula) is identified computationally and represents the main open challenge.

The five directions below form a coherent research program: Direction 1 closes the gap through strengthened inequalities, Direction 2 builds the algebraic infrastructure, Direction 3 connects to optimization, Direction 4 bridges to physics, and Direction 5 pushes toward complexity-theoretic consequences.

---

## Direction 1: Multinomial-Corrected Equivalence

**Conjecture:** For homogeneous degree-$d$ polynomials with positive coefficients, recursive Lorentzianity is equivalent to the **strengthened** mixed directional log-concavity:
$$\binom{m_i+2}{2} \binom{m_j+2}{2} c_{m+2e_i} c_{m+2e_j} \leq c_{m+e_i+e_j}^2$$
for all $m$ with $|m| = d-2$, together with exchange-closed support.

**Test:** Implement the corrected inequality in `demo.py` and verify: (1) the forward direction still holds with the strengthening, (2) the corrected converse has zero counterexamples for $n \leq 5$, $d \leq 6$.

**Impact:** If true, this would reduce Lorentzian recognition to checking $O(N \cdot n^2)$ arithmetic inequalities, where $N = \binom{n+d-3}{d-2}$, eliminating all eigenvalue computations. This is a polynomial-time algorithm in fixed degree.

**Catalog References:**
- `Catalog/Pythagorean/HessianDescent.lean` — `MixedDirectionalLogConcave`, `principal_minor_le_of_atMostOnePositiveEigenvalue`
- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` — `recursivelyLorentzian_iff_brandenHuh`

**Proof Strategy:** Formalize the derivative-coefficient formula: $\text{coeff}_s(\partial^\alpha f) = \frac{(s+\alpha)!}{s!} f_{s+\alpha}$, where $(s+\alpha)! = \prod_k (s_k+\alpha_k)!$ and $s! = \prod_k s_k!$. This requires building MvPolynomial iterated derivative infrastructure in Mathlib. Then substitute into the principal minor inequality to derive the corrected coefficient inequality.

**Domain Bridges:** Combinatorial optimization (polynomial-time certificate checking), algebraic complexity (polynomial identity testing)

**Lineage:** Builds directly on `principal_minor_le_of_atMostOnePositiveEigenvalue` and `two_by_two_atMostOnePos_of_nonneg_diag`.

**Ambition:** Grand challenge — if proved, this converts Lorentzian recognition from a spectral problem to a combinatorial one.

**The key insight is** that the gap between the naive coefficient inequality and the Hessian condition is precisely quantified by the multinomial coefficients from the derivative formula, and incorporating these factors should close the equivalence.

**Why now?** The principal minor lemma has been formalized and verified, providing the missing algebraic foundation. The computational experiments precisely characterize the gap, making the corrected conjecture testable and the proof strategy concrete.

---

## Direction 2: Iterated Derivative Coefficient Formula

**Conjecture:** For $f \in \mathbb{R}[x_1, \ldots, x_n]$ homogeneous of degree $d$, the coefficient of $x^s$ in $\partial^\alpha f$ is:
$$\text{coeff}_s(\partial^\alpha f) = \prod_{k=1}^n \frac{(s_k + \alpha_k)!}{s_k!} \cdot f_{s+\alpha}$$

**Test:** Verify computationally for polynomials in $n \leq 4$, $d \leq 6$ by comparing the formula with direct symbolic differentiation.

**Impact:** This is the essential infrastructure lemma for completing the Hessian descent program. Without it, the connection between Hessian entries and polynomial coefficients cannot be formalized.

**Catalog References:**
- `Catalog/Pythagorean/HessianDescent.lean` — `hessianMatrix`, `iteratedPDeriv`
- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` — `pderiv_coeff_nonneg`

**Proof Strategy:** Induction on the total order of differentiation $|\alpha|$. Base case: $\alpha = 0$, trivial. Inductive step: use the single-variable derivative formula $\text{coeff}_s(\partial_k f) = (s_k + 1) f_{s+e_k}$ and compose.

**Domain Bridges:** Symbolic computation, computer algebra

**Lineage:** Required by Direction 1; builds on `pderiv_coeff_nonneg` from the catalog.

**Ambition:** Solid extension — pure infrastructure, but essential for the program.

**The key insight is** that the iterated derivative of an MvPolynomial has a clean closed-form relationship to the original coefficients, with the factorial factors arising from the Leibniz rule applied coordinate-by-coordinate.

**Why now?** Mathlib's MvPolynomial API has matured enough to support this computation, and the `pderiv` infrastructure already handles the single-step case. The induction just needs to be carried out formally.

---

## Direction 3: M-Convexity and Optimization

**Conjecture:** The support of a recursively Lorentzian polynomial forms an M-convex set in the sense of Murota's discrete convex analysis. Conversely, every M-convex set arises as the support of some Lorentzian polynomial.

**Test:** For all matroids on $\leq 8$ elements, verify that the basis generating polynomial is Lorentzian and its support satisfies the M-convexity axioms. Check whether every M-convex set of rank $\leq 4$ can be realized as Lorentzian support.

**Impact:** This would establish a formal bridge between Lorentzian polynomial theory and discrete convex analysis, opening connections to:
- Submodular function minimization
- Discrete optimization on lattice polytopes
- Valuated matroid theory

**Catalog References:**
- `Catalog/Pythagorean/HessianDescent.lean` — `HasExchangeSupport`, `exchange_support_degree_le_one`
- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` — `SupportSatisfiesExchange`

**Proof Strategy:** Show that `HasExchangeSupport` is equivalent to M-convexity of the support set (they share the same exchange axiom). For the realization direction, construct the Lorentzian polynomial from the M-convex set using the product-of-linear-forms representation.

**Domain Bridges:** Discrete optimization, tropical geometry, operations research

**Lineage:** Builds on `HasExchangeSupport` and the exchange lemma for degree ≤ 1.

**Ambition:** Grand challenge — a full M-convexity bridge would unify two major mathematical theories.

**The key insight is** that the exchange axiom for Lorentzian support is formally identical to the defining axiom of M-convex sets, suggesting a deeper structural identity between the two theories.

**Why now?** The exchange support definition and low-degree verification are formalized. Murota's theory provides ready-made tools and characterizations that can be directly imported.

---

## Direction 4: Partition Function Correlation Inequalities

**Conjecture:** For a Lorentzian polynomial $f = \sum c_\alpha x^\alpha$ with positive coefficients, the induced probability measure $\mu(\alpha) = c_\alpha / \sum c_\beta$ satisfies the **strong Rayleigh** property: for all increasing events $A, B$:
$$\mu(A \cap B) \cdot \mu(\bar{A} \cap \bar{B}) \leq \mu(A \cap \bar{B}) \cdot \mu(\bar{A} \cap B)$$

**Test:** Generate Lorentzian polynomials (products of linear forms) and verify the correlation inequality for all pairs of coordinate events $\{x_i \geq 1\}$ and $\{x_j \geq 1\}$.

**Impact:** This connects Lorentzian polynomials to the theory of negative dependence in statistical physics and probability, enabling:
- New proofs of correlation decay in spin systems
- Rapid mixing results for Markov chains on matroid bases
- FKG-type inequalities for Lorentzian measures

**Catalog References:**
- `Catalog/Pythagorean/HessianDescent.lean` — `MixedDirectionalLogConcave`
- `Catalog/Pythagorean/HigherOrderLogConcavity.lean` — `KFoldLogConcave`, `logConcaveN_mul`

**Proof Strategy:** The mixed log-concavity inequality directly implies pairwise negative dependence when normalized to a probability measure. For the full strong Rayleigh property, use the characterization via the real stability of the generating polynomial and connect to the Lorentzian condition.

**Domain Bridges:** Statistical physics, probability theory, Markov chain Monte Carlo

**Lineage:** Builds on `MixedDirectionalLogConcave` and `KFoldLogConcave.mul`.

**Ambition:** Solid extension — pairwise negative dependence follows directly; full strong Rayleigh requires deeper work.

**The key insight is** that the coefficient inequalities of Lorentzian polynomials are precisely the negative dependence inequalities for the induced probability distribution, creating a direct bridge from algebraic geometry to statistical physics.

**Why now?** The connection between log-concavity and negative dependence has been established informally. The formal coefficient inequality definitions provide the precise mathematical objects needed to state and prove the correlation inequalities rigorously.

---

## Direction 5: Complexity of Lorentzian Certification

**Conjecture:** Deciding whether a homogeneous polynomial with positive integer coefficients is Lorentzian is in **coNP**: there exists a polynomial-size certificate (the Hessian descent certificate) that can be verified in polynomial time.

**Test:** Benchmark the certificate checking algorithm against direct spectral computation for polynomials with $n \leq 10$, $d \leq 8$. Measure the speedup and the certificate size as a function of $n$ and $d$.

**Impact:** This would place Lorentzian recognition in a well-studied complexity class and open connections to:
- Polynomial identity testing
- Sum-of-squares certification
- Algebraic proof complexity

**Catalog References:**
- `Catalog/Pythagorean/HessianDescent.lean` — `HessianDescentCertificate`, `certificate_sound_degree_two`
- `Catalog/Pythagorean/LorentzianRecognitionComplete.lean` — `quadratic_leaf_count_le`

**Proof Strategy:** The certificate size is bounded by the number of multi-indices of degree $d-2$ in $n$ variables, which is $\binom{n+d-3}{d-2} \leq n^{d-2}$. For fixed degree, this is polynomial in $n$. Each inequality check is $O(1)$ arithmetic operations. The exchange support check requires $O(|supp|^2 \cdot n)$ operations. Total verification time is polynomial for fixed $d$.

**Domain Bridges:** Computational complexity, proof complexity, algebraic computation

**Lineage:** Builds on `quadratic_leaf_count_le` and `certificate_sound_degree_two`.

**Ambition:** Solid extension — the coNP membership follows from the certificate structure; coNP-completeness would be a grand challenge.

**The key insight is** that the Hessian descent certificate has size bounded by the number of derivative leaves, which is polynomial in $n$ for fixed $d$, and each condition in the certificate can be verified in constant time.

**Why now?** The certificate structure is defined and its soundness at degree 2 is proved. The complexity analysis follows directly from the combinatorial bounds already established in the catalog.
