# Future Directions: Newton's Inequality and Lorentzian Polynomial Theory

## Synthesis

The formalization of Newton's inequality via elementary symmetric polynomials establishes a verified foundation for the broader Lorentzian polynomial program. The three directions below form a coherent research arc: (1) extending Newton's inequality to its ultra-log-concave strengthening, (2) formalizing the structural theory of Lorentzian polynomials (closure properties), and (3) connecting to matroid Hodge theory. The grand challenges target the deepest open problems: proving the Heron–Rota–Welsh conjecture in full generality and establishing tropical convexity certificates via Lorentzian theory. Each direction builds directly on the verified Newton inequality proof and the Lorentzian definitions framework established in this cycle.

---

## Direction 1: Ultra-Log-Concavity of Elementary Symmetric Polynomials

**Conjecture:** For nonneg weights $w_1, \ldots, w_m \geq 0$ and $1 \leq k \leq m-1$:
$$\left(\frac{e_k}{\binom{m}{k}}\right)^2 \geq \frac{e_{k-1}}{\binom{m}{k-1}} \cdot \frac{e_{k+1}}{\binom{m}{k+1}}$$

**Test:** Computationally verify for $m \leq 20$ with random weights sampled from exponential, uniform, and Bernoulli distributions. Check that the ULC margin $\tilde{e}_k^2 - \tilde{e}_{k-1}\tilde{e}_{k+1}$ is always nonneg. Generate 10,000 instances and report the minimum margin.

**Impact:** Ultra-log-concavity is strictly stronger than Newton's inequality and is the natural normalization for comparing coefficient sequences across different polynomial degrees. It appears in the theory of Schur-convex functions and majorization.

**Catalog References:** `Pythagorean/LorentzianNewton.lean` (newton_inequality, maclaurinAvg_uniform, ulc_uniform)

**Proof Strategy:** Combine Newton's inequality with the log-concavity of binomial coefficients: $\binom{m}{k}^2 \geq \binom{m}{k-1}\binom{m}{k+1}$. The ULC inequality follows from Newton + binomial log-concavity via a multiplicative argument. The binomial coefficient inequality can be proved directly from the identity $\binom{m}{k}^2 / (\binom{m}{k-1}\binom{m}{k+1}) = (k+1)(m-k+1) / (k(m-k))$.

**Domain Bridges:** Connects to information theory (ULC sequences satisfy discrete entropy power inequalities) and to algebraic geometry (Hodge index theorem for toric varieties).

**Lineage:** Extends `newton_inequality` and `ulc_uniform` from the current formalization.

**Ambition:** Solid extension — the proof strategy is clear and the result is classical.

---

## Direction 2: Lorentzian Closure Under Multiplication

**Conjecture:** If $f$ and $g$ are Lorentzian polynomials of degrees $d_1$ and $d_2$ respectively, then $f \cdot g$ is Lorentzian of degree $d_1 + d_2$.

**Test:** For $n = 2, 3$ variables and degrees $d_1, d_2 \leq 4$, enumerate pairs of Lorentzian polynomials (using random nonneg coefficients on M-convex supports) and verify that their product is Lorentzian by checking all three conditions. Report any counterexample or confirm for 1000 pairs.

**Impact:** This is the fundamental structural theorem of Brändén–Huh theory. It immediately implies that products of nonneg linear forms are Lorentzian, which is the bridge to Newton's inequality. It also enables inductive arguments on the degree of Lorentzian polynomials.

**Catalog References:** `Pythagorean/LorentzianDefs.lean` (IsLorentzian, MConvexSupport, HasAtMostOnePosEigenvalue)

**Proof Strategy:** The proof in Brändén–Huh uses the characterization of Lorentzian polynomials as limits of products of linear forms (in the "strictly Lorentzian" case) and a continuity argument. The key technical step is showing that the Hessian eigenvalue condition is preserved under multiplication, which requires the Cauchy–Binet formula for minors of product matrices.

**Domain Bridges:** Connects to real algebraic geometry (hyperbolic polynomials), optimization (semidefinite programming characterization of Lorentzian cone), and tropical geometry (product of tropical polynomials).

**Lineage:** Extends `linear_lorentzian` and `IsLorentzian` from the current formalization.

**Ambition:** Grand challenge — the proof is technically demanding and requires substantial algebraic infrastructure.

---

## Direction 3: Matroid Log-Concavity via Lorentzian Theory

**Conjecture (Heron–Rota–Welsh, proved by AHK):** For any matroid $M$ on ground set $[n]$ with rank $r$, the sequence of Whitney numbers of the second kind $W_0, W_1, \ldots, W_r$ (where $W_k$ is the number of flats of rank $k$) is log-concave:
$$W_k^2 \geq W_{k-1} \cdot W_{k+1}$$

**Test:** Enumerate all matroids on $\leq 8$ elements (there are 68,687 non-isomorphic matroids on 8 elements). For each, compute Whitney numbers and verify log-concavity. Report any failure (there should be none, as the theorem is proved).

**Impact:** This is one of the landmark results in combinatorics, proved by Adiprasito–Huh–Katz using algebraic geometry. A purely algebraic proof via Lorentzian polynomials would be a major achievement and could potentially extend to wider classes of combinatorial objects.

**Catalog References:** `Pythagorean/LorentzianDefs.lean` (IsLorentzian, MConvexSupport)

**Proof Strategy:** Construct the Lorentzian polynomial associated to a matroid (the "volume polynomial" of the Bergman fan) and apply the Lorentzian ⟹ ULC theorem. The main challenge is defining the volume polynomial and proving it is Lorentzian.

**Domain Bridges:** Connects to tropical geometry (Bergman fans), algebraic geometry (Chow rings of matroids), and combinatorial optimization (matroid intersection algorithms).

**Lineage:** Would use `IsLorentzian` and `MConvexSupport` as foundations.

**Ambition:** Grand challenge — requires formalizing substantial matroid theory and tropical geometry.

---

## Direction 4: Spectral Gap Bounds for Lorentzian Hessians

**Conjecture:** For any Lorentzian polynomial $f$ of degree $d$ in $n$ variables with coefficients in $[0, 1]$, and any multi-index $\alpha$ with $|\alpha| = d-2$:
$$\lambda_{\max}(\text{Hess}_\alpha f) - \lambda_2^+(\text{Hess}_\alpha f) \geq \frac{1}{d^2}$$

**Test:** For $n \leq 8$ and $d \leq 6$, generate random Lorentzian polynomials by:
1. Choose an M-convex support uniformly at random
2. Assign random coefficients in $[0, 1]$
3. Check Lorentzian property
4. If Lorentzian, compute all Hessian eigenvalues and spectral gaps
Report the minimum gap across all instances and check against $1/d^2$.

**Impact:** A spectral gap bound would provide quantitative stability for the Lorentzian property — measuring how "far" a polynomial is from losing its Lorentzian structure. This has implications for perturbation theory and numerical algorithms.

**Catalog References:** `Pythagorean/LorentzianDefs.lean` (hessianMatrix, HasAtMostOnePosEigenvalue)

**Proof Strategy:** For the bivariate case ($n = 2$), the Hessian is $2 \times 2$ and the spectral gap can be computed explicitly using the discriminant. For general $n$, a perturbation theory argument using Weyl's inequality may give the bound.

**Domain Bridges:** Connects to numerical linear algebra (eigenvalue perturbation), optimization (condition numbers of semidefinite programs), and spectral graph theory.

**Lineage:** Extends the spectral analysis in `LorentzianDefs.lean`.

**Ambition:** Solid extension — the bivariate case should be provable; the general case is more challenging.

---

## Direction 5: Tropical Convexity and Generalized Permutohedra

**Conjecture:** The Newton polytope of any Lorentzian polynomial is a generalized permutohedron (i.e., it can be obtained from the standard permutohedron by moving facets parallel to themselves).

**Test:** For $n = 3, 4$ and $d \leq 6$, generate Lorentzian polynomials and compute their Newton polytopes. Check if each polytope is a generalized permutohedron by verifying that all edge directions are of the form $e_i - e_j$.

**Impact:** This result, proved by Brändén–Huh, connects Lorentzian theory to Postnikov's theory of generalized permutohedra, which appears in algebraic combinatorics, optimization, and physics (scattering amplitudes).

**Catalog References:** `Pythagorean/LorentzianDefs.lean` (IsLorentzian, MConvexSupport)

**Proof Strategy:** The key step is showing that M-convexity of the support implies the generalized permutohedron property. This follows from the theory of polymatroids: M-convex sets are precisely the sets of lattice points in generalized permutohedra intersected with a hyperplane.

**Domain Bridges:** Connects to polyhedral geometry, algebraic combinatorics (Postnikov's positroids), and theoretical physics (BCFW recursion in scattering amplitudes).

**Lineage:** Would extend `MConvexSupport` and connect to tropical geometry results in the Catalog.

**Ambition:** Solid extension — the mathematical connection is well-understood; the formalization challenge is in polyhedral geometry infrastructure.
