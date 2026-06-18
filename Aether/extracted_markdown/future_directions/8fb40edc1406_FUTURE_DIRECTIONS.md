# Future Directions

## Breakthrough Research Opportunities Opened by the Anisotropic Footprint Bound

---

### Direction 1: Tensor-Product Lagrange Interpolation Equivalence

**Hypothesis:** The evaluation map from reduced polynomials on grid $S$ to functions $\text{Grid}(S) \to F$ is a bijection, and the inverse is given explicitly by the tensor-product Lagrange basis.

**Proof Strategy:**
- Construct the univariate Lagrange basis $\ell_a^{(i)}(X_i)$ for each coordinate set $S_i$.
- Show the tensor products $L_u(x) = \prod_i \ell_{u_i}^{(i)}(x_i)$ for $u \in \text{Grid}(S)$ form a basis for reduced polynomials.
- Prove injectivity (already done: the Nullstellensatz implies kernel = {0}).
- Prove surjectivity by dimension counting: $\dim(\text{reduced polys}) = \prod |S_i| = |\text{Grid}(S)|$.

**Lean Formalization:** Define `lagrangeBasis`, prove `eval_lagrangeBasis_eq_indicator`, show `Function.Bijective evalOnGrid`.

**Cross-domain impact:** This gives a complete interpolation framework for function spaces on product domains, with applications to multivariate numerical analysis, tensor decomposition, and polynomial learning.

**Estimated difficulty:** Medium. Most ingredients exist in Mathlib (univariate Lagrange interpolation). The tensor-product construction needs care with `MvPolynomial` API.

---

### Direction 2: Minimum Distance of Affine Cartesian Evaluation Codes

**Hypothesis:** The minimum distance of the affine Cartesian code $\mathcal{C}(S, e)$ equals $\prod_i (|S_i| - e_i)$, and this can be achieved by a codeword corresponding to a product of vanishing-like polynomials.

**Proof Strategy:**
- Lower bound: Already proved (footprint bound).
- Upper bound: Construct the polynomial $f = \prod_i \prod_{a \in S_i \setminus T_i} (X_i - a)$ where $T_i \subseteq S_i$ with $|T_i| = |S_i| - e_i$. Show this achieves weight exactly $\prod_i |T_i| = \prod_i (|S_i| - e_i)$.

**Lean Formalization:** Define `AffineCartesianCode`, prove `minDistance_eq_prod`.

**Cross-domain impact:**
- Coding theory: Precise distance formulas for a new family of evaluation codes.
- Cryptography: Bounds for algebraic secret sharing schemes.
- Information theory: Capacity of polynomial channels with heterogeneous alphabets.

**Estimated difficulty:** Medium-High. The upper bound construction requires showing that a specific polynomial has exactly the right weight.

---

### Direction 3: Quotient Algebra Isomorphism

**Hypothesis:** $F[X_1, \ldots, X_n] / \langle g_1, \ldots, g_n \rangle \cong \text{Fun}(\prod_i S_i, F)$ as $F$-algebras, where $g_i = \prod_{a \in S_i}(X_i - a)$.

**Proof Strategy:**
- Show the evaluation map descends to the quotient (polynomials in the ideal vanish on the grid).
- Show injectivity: a polynomial vanishing on the grid with bounded degree must be zero (Nullstellensatz).
- Show surjectivity by dimension: $\dim(F[X]/I) = \prod |S_i|$ = $|\text{Grid}|$ (using Gröbner basis theory or direct computation).

**Lean Formalization:** Build `gridQuotientEquiv : (MvPolynomial (Fin n) F) ⧸ vanishingIdeal S ≃ₐ[F] (GridPoints S → F)`.

**Cross-domain impact:**
- Algebraic geometry: First formalized zero-dimensional complete intersection isomorphism.
- Representation theory: Function algebras on finite product groups.
- Number theory: Hensel's lemma and deformation theory starting points.

**Estimated difficulty:** High. Requires ideal quotient and Gröbner basis infrastructure in Lean.

---

### Direction 4: Extension to Semisimple Coefficient Algebras

**Hypothesis:** The footprint bound extends from fields to commutative semisimple algebras (products of fields), with the bound modified by the decomposition structure.

**Proof Strategy:**
- Use the Chinese Remainder Theorem: a semisimple algebra $A \cong \prod_j F_j$.
- A polynomial over $A$ decomposes into independent polynomials over each $F_j$.
- The footprint bound applies coordinatewise.
- The combined bound involves the minimum over components.

**Cross-domain impact:**
- Number theory: Footprint bounds over $\mathbb{Z}/m\mathbb{Z}$ for composite $m$.
- Cryptography: Multi-party computation with ring-based schemes.
- Algebra: Connecting the theorem to the theory of Artinian rings.

**Estimated difficulty:** Medium. The field case is proved; the extension is mostly structural.

---

### Direction 5: Tropical and Idempotent Analogues

**Hypothesis:** In the tropical semiring $(\mathbb{R} \cup \{-\infty\}, \max, +)$, there exists an analogue of the footprint bound where:
- "vanishing" is replaced by "achieving the minimum" (tropical root),
- the product $\prod(|S_i| - e_i)$ becomes a sum $\sum(|S_i| - e_i)$ (tropical product → sum),
- the bound constrains the entropy or combinatorial complexity of tropical polynomial optimization.

**Proof Strategy:**
- Define tropical polynomials as piecewise-linear functions.
- Characterize "tropical roots" (points where the maximum is achieved by multiple terms).
- Prove a tropical version of the footprint bound via the connection between tropical and algebraic geometry (Kapranov's theorem).

**Cross-domain impact:**
- Optimization: Lower bounds on the complexity of piecewise-linear objectives on product domains.
- Information theory: Capacity bounds for discrete memoryless channels with product structure.
- Phylogenetics: Bounds on tree spaces from tropical geometry.

**Estimated difficulty:** High. Requires establishing tropical geometry foundations in Lean.

---

### Direction 6: Uncertainty Principles on Product Domains

**Hypothesis:** The footprint bound implies a discrete uncertainty principle: for a function $f$ on $\text{Grid}(S)$,
$$|\text{supp}(f)| \cdot |\text{supp}(\hat{f})| \geq |\text{Grid}(S)|,$$
where $\hat{f}$ is the "reduced polynomial transform" (coefficient representation).

**Proof Strategy:**
- Use the interpolation equivalence (Direction 1) to define $\hat{f}$.
- The footprint bound gives $|\text{supp}(f)| \geq \prod(|S_i| - e_i)$ when $\hat{f}$ has bounded support.
- The dual statement bounds $|\text{supp}(\hat{f})|$ from the support of $f$.
- Combining gives the uncertainty product.

**Cross-domain impact:**
- Signal processing: Discrete uncertainty principles for non-uniform sampling.
- Compressed sensing: Sparsity constraints on product domains.
- Quantum information: Mutually unbiased bases on product state spaces.

**Estimated difficulty:** Medium-High. Requires Direction 1 as prerequisite.

---

### Direction 7: Weighted and Multiplicity Versions

**Hypothesis:** The footprint bound extends to weighted evaluations and multiplicity versions:
- **Weighted:** $\sum_{x \in \text{Grid}(S)} w(x) \cdot \mathbb{1}[f(x) \neq 0] \geq$ (weighted product bound).
- **Multiplicity:** Replace "nonzero count" with "sum of multiplicities of nonvanishing."

**Proof Strategy:**
- For weights: Use the weighted polynomial $w \cdot f$ and apply the original bound with modified degree analysis.
- For multiplicity: Use higher-order derivatives and jet-space evaluation, applying the bound iteratively.

**Cross-domain impact:**
- Algebraic geometry: Local-global principles for evaluation multiplicities.
- Analytic number theory: Weighted counting of rational points on varieties.

**Estimated difficulty:** Medium.

---

## Team Directive

Each direction above is self-contained with:
1. A precise mathematical hypothesis.
2. A concrete proof strategy decomposed into verifiable steps.
3. Cross-domain connections that motivate the work.
4. An estimated difficulty level.

**Recommended priority ordering:**
1. Direction 1 (interpolation) — unlocks Directions 2, 6
2. Direction 2 (code distance) — immediate applications
3. Direction 4 (semisimple extension) — broadest generalization
4. Direction 3 (quotient algebra) — deepest algebraic content
5. Directions 5, 6, 7 — exploratory and high-risk/high-reward

**Validation methodology:** Each direction should produce:
- A Lean formalization with zero `sorry` statements.
- Computational verification in Python.
- At least one worked application example.
- Connection to the existing footprint bound infrastructure.
