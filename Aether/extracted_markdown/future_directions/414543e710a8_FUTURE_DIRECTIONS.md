# Future Directions: Pseudofinite Dimension and Stabilizer Rank Bounds

## Synthesis

The formalization of pseudofinite dimension establishes the quantitative backbone — normalized log-cardinality, coset cover bounds, and dimension invariance — on which the full Hrushovski stabilizer descent can be built. The five directions below form a coherent program: Direction 1 completes the stabilizer descent theorem itself; Direction 2 extends the theory to its information-theoretic dual; Direction 3 pushes toward explicit computational applications; Direction 4 bridges to algebraic geometry; and Direction 5 proposes a grand challenge connecting dimension theory to learning theory. Together, they chart a path from the current foundations to a complete, computationally effective theory of approximate algebraic structures.

---

## Direction 1: Full Stabilizer Descent Formalization

**Conjecture:** The stabilizer of a proper approximate subgroup has strictly smaller pseudofinite dimension. Formally: if $A$ is a definable $K$-approximate subgroup in $\prod_{\mathcal{U}} G_i$ with $0 < \dim(A) < 1$, then $\dim(\text{Stab}(A)) \leq \dim(A) - c(K)$ for an explicit constant $c(K) > 0$ depending only on the doubling constant.

**Test:** Compute stabilizer chains in Z/pZ for primes p = 101, 1009, 10007 with initial sets of various doubling constants. Verify that the dimension drop per step is bounded below by a function of K alone.

**Impact:** Completes the core engine of the Breuillard-Green-Tao structure theorem for approximate groups. Would be the first machine-verified proof of stabilizer descent.

**Catalog References:** `Catalog/Pythagorean/BoundedPseudofiniteTransfer.lean` (Łoś theorem, `cosetCover_compose`), `Pythagorean/PseudofiniteDimension.lean` (`cosetCover_card_bound`, `normalizedLogCard_coset_bound`)

**Proof Strategy:** Use the formalized coset cover bound plus the Ruzsa triangle inequality (to be formalized) to show that if $gA \subseteq A^2$ for all $g \in \text{Stab}(A)$, then $\text{Stab}(A)$ is covered by $K^2$ left cosets of a subgroup $H$ with $\dim(H) < \dim(A)$. The coset cover bound then gives $\dim(\text{Stab}(A)) < \dim(A)$.

**Domain Bridges:** Model theory → combinatorics (Ruzsa calculus) → group theory (subgroup structure)

**Lineage:** Builds directly on the coset cover cardinality bound and log-cardinality coset bound.

**Ambition:** Grand challenge — requires formalizing the Ruzsa triangle inequality and connecting it to the ultraproduct framework.

---

## Direction 2: Entropy-Dimension Duality and the Polynomial Freiman-Ruzsa Conjecture

**Conjecture:** The Polynomial Freiman-Ruzsa conjecture (recently proved by Gowers-Green-Manners-Tao) can be re-derived from pseudofinite dimension theory via the entropy-dimension correspondence. Specifically: if $\dim(A + A) \leq \dim(A) + \delta$ in $\mathbb{F}_2^n$ (the $K = 2^\delta$ approximate subgroup condition), then $A$ is covered by $2^{O(\delta)}$ cosets of a subspace $V$ with $\dim(V) \leq \dim(A) + O(\delta)$.

**Test:** Formalize the entropy-dimension identity (dim = H/log|G|) and verify that Tao's entropy-based proof steps translate to dimension inequalities. Compute explicit bounds for small $\mathbb{F}_2^n$ (n = 5, 6, 7, 8).

**Impact:** Would provide a new proof pathway for PFR via model-theoretic dimension, potentially with better constants. Bridges additive combinatorics to model theory.

**Catalog References:** `Pythagorean/PseudofiniteDimension.lean` (entropy correspondence, coset bound)

**Proof Strategy:** Translate Tao's sumset entropy inequality $H(A+B) \leq H(A) + H(B) - H(A \cap B)$ into dimension language. Use the coset cover bound to extract structural conclusions.

**Domain Bridges:** Information theory ↔ model theory ↔ additive combinatorics

**Lineage:** Extends the dimension-entropy correspondence from our current work.

**Ambition:** Paradigm-shifting — connects two major recent breakthroughs (PFR proof and pseudofinite dimension).

---

## Direction 3: Computational Pseudofinite Dimension for Matrix Groups

**Conjecture:** For $G = \text{SL}_2(\mathbb{F}_p)$ and $A$ a generating set with $|A| = p^\alpha$, the stabilizer descent terminates in at most $\lceil 3/\alpha \rceil$ steps. Furthermore, the Product Theorem constant $\varepsilon$ can be computed as $\varepsilon \geq \alpha/3$.

**Test:** Implement the stabilizer chain algorithm for SL_2(F_p) for p = 5, 7, 11, 13. For random generating sets of various sizes, measure the descent length and compare to the predicted bound.

**Impact:** Would give the first explicit, computationally verified constants for the Product Theorem in SL_2. Bridges theoretical asymptotic results to concrete numerical bounds.

**Catalog References:** `Pythagorean/PseudofiniteDimension.lean` (dimension computation), `Catalog/Pythagorean/HelfgottGrowth.lean`, `Catalog/Pythagorean/HelfgottSL2.lean`

**Proof Strategy:** Combine Helfgott's growth bound $|A^3| \geq |A|^{1+\varepsilon}$ with the coset cover bound to control each stabilizer step. The bound $3/\alpha$ comes from the fact that dimension starts at $\alpha$ and decreases by at least $\alpha/3$ per step.

**Domain Bridges:** Computational algebra → number theory → expander graphs

**Lineage:** Extends the Product Theorem analysis with quantitative dimension bounds.

**Ambition:** Solid extension — computational verification of existing theoretical predictions.

---

## Direction 4: Lang-Weil Bridge: Pseudofinite Dimension = Zariski Dimension

**Conjecture:** For constructible sets $A$ defined by polynomial equations over $\mathbb{F}_q$, the pseudofinite dimension (taken along the ultrafilter of all prime powers) equals the Zariski dimension. Formally: if $V \subseteq \mathbb{A}^n_{\mathbb{F}_q}$ is a variety of dimension $d$, then $\dim_{\mathcal{U}}(V(\mathbb{F}_{q_i})) = d/n$ where $G_i = \mathbb{A}^n(\mathbb{F}_{q_i})$.

**Test:** Formalize the Lang-Weil estimate $|V(\mathbb{F}_q)| = c \cdot q^d + O(q^{d-1/2})$ for curves (d=1) over finite fields. Verify that $\log|V(\mathbb{F}_q)|/\log q^n \to d/n$ as $q \to \infty$.

**Impact:** Establishes pseudofinite dimension as a genuine generalization of algebraic dimension, connecting model theory to algebraic geometry in a formalized setting.

**Catalog References:** `Pythagorean/PseudofiniteDimension.lean` (dimension definition and properties)

**Proof Strategy:** Use the Lang-Weil estimate to show $\log|V(\mathbb{F}_q)| = d \log q + O(\sqrt{q} \log q)$. Dividing by $n \log q$ and taking the ultralimit gives $d/n$.

**Domain Bridges:** Model theory ↔ algebraic geometry ↔ number theory (counting points over finite fields)

**Lineage:** New direction branching from the pseudofinite dimension definition.

**Ambition:** Solid extension — the Lang-Weil estimate is classical and the proof is straightforward once formalized.

---

## Direction 5: VC Dimension Bounds from Pseudofinite Dimension

**Conjecture:** For a definable family of sets $\{A_g : g \in G\}$ parametrized by elements of a pseudofinite group, the VC dimension satisfies $\text{VC}(\{A_g\}) \leq C \cdot (\dim(\text{parameter space}) + 1) \cdot \log(\dim + 1)$ for a universal constant $C$.

**Test:** Disprove the naive bound $\text{VC} \leq 2 \cdot \dim$: for the family of intervals $\{[0, g] : g \in \mathbb{Z}/p\mathbb{Z}\}$, $\text{VC} = \lceil \log_2 p \rceil$ while $\dim = 1$, so the bound fails for $p \geq 5$. Then test the logarithmic bound for various families in $(\mathbb{Z}/p\mathbb{Z})^n$.

**Impact:** Would establish a new interface between model theory and statistical learning theory. VC dimension controls sample complexity in PAC learning, so bounds from pseudofinite dimension would connect group structure to learnability.

**Catalog References:** `Pythagorean/PseudofiniteDimension.lean` (dimension theory)

**Proof Strategy:** Use the Sauer-Shelah lemma combined with dimension bounds on intersections to control shattering. The key is that in NIP (non-independence property) theories, VC dimension is bounded by a function of the number of parameters, and pseudofinite dimension provides a quantitative refinement.

**Domain Bridges:** Model theory ↔ statistical learning theory ↔ combinatorics (Sauer-Shelah)

**Lineage:** Novel direction inspired by the VC dimension test in the problem statement.

**Ambition:** Grand challenge — this is unexplored territory connecting model theory to machine learning theory.
