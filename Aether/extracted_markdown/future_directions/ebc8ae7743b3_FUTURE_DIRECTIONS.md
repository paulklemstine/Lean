# Future Directions: Tropical Morse Theory via Active-Set Transitions

## Synthesis

The theorems established in this cycle — birth witness exactness, pair-critical extraction, the genericity bound, the pigeonhole birth theorem, and the hyperplane arrangement bridge — constitute the foundation layer of tropical Morse theory. They establish that **topology changes in tropical sublevel filtrations are sparse, atomic, and combinatorially controlled**. The five directions below extend this foundation along two axes: (1) deepening the Morse-theoretic machinery toward full homological inequalities and algorithmic topology, and (2) broadening the cross-domain bridges to oriented matroids, persistent homology, and neural network theory. Each direction builds directly on proven catalog results and is designed to be falsifiable through specific computational tests.

---

## Direction 1: Pair-Spectrum Completeness Conjecture

**Conjecture:** For a pairwise generic tropical affine family $F$ with $k$ forms in $\mathbb{Q}^n$, the map from critical values to unordered pairs $\{i, j\}$ is injective. That is, every critical value is pair-critical (proved in this cycle), and distinct critical values correspond to distinct pairs.

**Test:** Generate $10^4$ random generic families in $\mathbb{Q}^2$ with $k = 5, 10, 20$. For each family, enumerate all pair-critical values and check injectivity of the map $c \mapsto \{i, j\}$. A single counterexample — two distinct pair-critical values arising from the same unordered pair — falsifies the conjecture. Expected failure rate: < 1% for $n \geq 2$, potentially higher for $n = 1$.

**Impact:** If true, this gives an exact formula $|\text{crit}| = \binom{k}{2}$ for generic families, rather than just an upper bound. This would upgrade the complexity bound from $O(k^2)$ to exact $\Theta(k^2)$.

**Catalog References:**
- `Tropical/ArithmeticUniversality/TropicalMorse.lean`: `strictBirth_pair_imp_pairCritical`, `pairCritical_lies_on_eqHyperplane`
- `Tropical/ArithmeticUniversality/Defs.lean`: `activeSet_iff_dominates`

**Proof Strategy:** For $n \geq 2$, the equality locus $H_{ij} = \{x : f_i(x) = f_j(x)\}$ is a hyperplane (codimension 1). The pair-critical value for $(i, j)$ is the minimum of $f_i$ restricted to $H_{ij} \cap \{x : \forall l, f_l(x) \leq f_i(x)\}$, which is a linear program. Injectivity would follow if this minimum is generically unique per pair. The key step is showing that distinct pairs $(i,j)$ and $(i', j')$ yield distinct minima for generic coefficients, which could use a Sard-type dimension argument.

**Domain Bridges:** Algebraic geometry (generic position), linear programming (LP duality), computational complexity

**Lineage:** Extends `strictBirth_pair_imp_pairCritical` → injectivity → exact counting

**Ambition:** 🟡 Solid extension — likely true for $n \geq 2$, may fail for $n = 1$

---

## Direction 2: Weak Tropical Morse Inequalities

**Conjecture:** For a pairwise generic tropical affine family with finitely many critical values, the number of born $d$-cells in the active-set complex filtration bounds the $d$-th Betti number of the complex from above:
$$\beta_d(\mathcal{A}(c)) \leq |\{s : s \text{ born at threshold} \leq c, |s| = d+1\}|$$

Under genericity (Theorem 3.4: `pairwiseGeneric_activeSet_card_le_two`), only 0-cells and 1-cells are born, so $\beta_d = 0$ for $d \geq 2$.

**Test:** For $k \in \{3, 5, 10\}$ in $\mathbb{R}^2$, compute the simplicial homology of the active-set complex at each critical threshold using Smith normal form. Compare $\beta_d$ to the birth count at each threshold. Any violation $\beta_d > \text{birth count}_d$ falsifies the conjecture.

**Impact:** This would establish tropical Morse inequalities as a formal analogue of classical Morse inequalities, completing the conceptual bridge between tropical geometry and Morse theory.

**Catalog References:**
- `Tropical/ArithmeticUniversality/TropicalMorse.lean`: `criticalValue_imp_exists_strictBirth`, `face_in_complex_of_superface`, `generic_cells_dim_le_one`
- `Tropical/ArithmeticUniversality/Defs.lean`: `activeSetComplex_mono`

**Proof Strategy:** Define the chain complex of the active-set filtration. Use the acyclic matching lemma (Forman) to construct a discrete Morse function from the birth order (via `firstBirthLe_of_subset`). The weak Morse inequality then follows from the algebraic cancellation theorem for acyclic matchings.

**Domain Bridges:** Algebraic topology (homology), discrete Morse theory (Forman), persistent homology

**Lineage:** Extends `firstBirthLe_of_subset` → acyclic matching → Morse inequalities

**Ambition:** 🟠 Grand challenge — requires formalizing simplicial homology + Forman's theorem

---

## Direction 3: Arrangement-Controlled Critical Spectrum

**Conjecture:** Two tropical affine families $F, G$ that share the same *oriented matroid* of their equality hyperplane arrangement $\mathcal{H}(F) = \{H_{ij}\}$ have identical critical spectra (up to affine reparameterization of threshold values).

**Test:** Generate pairs of families with the same combinatorial arrangement type (same face lattice of the arrangement) but different numerical coefficients. Compare their critical value sequences. A pair with the same arrangement type but different critical spectra (after normalization) falsifies the conjecture.

**Impact:** This would show that tropical Morse theory is a *matroid invariant*, massively reducing the parameter space. Classification of tropical critical spectra would reduce to classification of oriented matroids.

**Catalog References:**
- `Tropical/ArithmeticUniversality/TropicalMorse.lean`: `pairCritical_lies_on_eqHyperplane`, `pairCritical_in_pairEventSet`
- `Tropical/ArithmeticUniversality/Defs.lean`: `SameSignType`, `activeComplex_bij_of_sameSignType`

**Proof Strategy:** Use `activeComplex_bij_of_sameSignType` to show that sign-type equivalent families have bijective active-set complexes. Then show that the birth order is preserved under sign-type equivalence. The key challenge is relating the threshold values (not just the combinatorial structure) across the bijection.

**Domain Bridges:** Oriented matroid theory, hyperplane arrangement combinatorics, computational geometry

**Lineage:** Extends `SameSignType` → `activeComplex_bij_of_sameSignType` → critical spectrum invariance

**Ambition:** 🟠 Grand challenge — connects tropical geometry to matroid theory

---

## Direction 4: Tropical Persistent Homology and TDA

**Conjecture:** The persistence diagram of the active-set complex filtration $\{\mathcal{A}(c)\}_{c \in \mathbb{Q}}$ is completely determined by the pair-critical events and their associated face births. Moreover, all persistence intervals have left endpoints at pair-critical values, and all intervals are of the form $[c_i, c_j)$ or $[c_i, \infty)$ where $c_i, c_j$ are pair-critical values.

**Test:** Implement persistent homology computation (using boundary matrices / Smith normal form) for the active-set complex filtration. Verify that birth times in the persistence diagram coincide with pair-critical values for 1000 random families.

**Impact:** This would create a **certified persistent homology algorithm** for tropical filtrations, with provable complexity bounds $O(k^3)$ (from the $O(k^2)$ critical values and $O(k)$ face size).

**Catalog References:**
- `Tropical/ArithmeticUniversality/TropicalMorse.lean`: all main theorems
- `Tropical/ArithmeticUniversality/Defs.lean`: `activeSetComplex_mono`, `sublevel_mono`

**Proof Strategy:** Construct the filtered chain complex from the birth sequence. Use the standard persistence algorithm (column reduction) on the boundary matrix indexed by birth order. The key formalization step is showing that the boundary matrix respects the birth filtration (proved by `firstBirthLe_of_subset`).

**Domain Bridges:** Topological data analysis, persistent homology, computational algebraic topology

**Lineage:** Extends `firstBirthLe_of_subset` + `criticalValue_imp_exists_strictBirth` → persistence diagram control

**Ambition:** 🟡 Solid extension with high practical impact

---

## Direction 5: Neural Network Loss Landscape Phase Transitions

**Conjecture:** For a single-layer ReLU network with $k$ neurons and input dimension $n$, the number of topological phase transitions in the loss landscape under threshold annealing is bounded by $k(k-1)/2$ and each transition corresponds to a pairwise exchange of neuron dominance.

**Test:** Train single-layer ReLU networks on synthetic classification tasks. Monitor the loss landscape topology (via sublevel set Betti numbers or connectivity) as the loss threshold varies from $\infty$ to 0. Count topology-changing events and compare to the $\binom{k}{2}$ bound.

**Impact:** This would provide the first **certified topological complexity bounds** for neural network loss landscapes, with immediate implications for understanding optimization dynamics and generalization.

**Catalog References:**
- `Tropical/ArithmeticUniversality/TropicalMorse.lean`: `pairwiseGeneric_activeSet_card_le_two`, `strictBirth_pair_imp_pairCritical`
- `Tropical/ArithmeticUniversality/Defs.lean`: `tropMax_sublevel_convex`

**Proof Strategy:** Model each ReLU neuron as an affine form (pre-activation). The network output is a max-affine function of the pre-activations. Apply the pair-critical bound theorem. The key challenge is handling the composition of layers (depth > 1), which introduces tropical polynomials of higher degree.

**Domain Bridges:** Machine learning, neural network theory, optimization theory, computational neuroscience

**Lineage:** Extends tropical Morse theory → neural loss landscapes → certified complexity

**Ambition:** 🔴 Paradigm-shifting — would connect formal mathematics to deep learning practice
