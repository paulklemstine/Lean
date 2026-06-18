# Future Research Directions

## Synthesis

This research cycle established the formal connection between ReLU neural network decision surfaces and polyhedral geometry, proving Zaslavsky-type bounds on linear regions, monotonicity of the Montúfar deep region bound, and the piecewise-linear Hodge property for polyhedral complexes. The key insight is that ReLU decision boundaries are polyhedral complexes where every homology class decomposes as a sum of face cycles — the PL analogue of the Hodge conjecture is *trivially true*.

The most promising cross-domain connection is between the **hyperplane arrangement combinatorics** established here and the **tropical geometry** already present in the Catalog (see `Tropical/` modules). ReLU networks compute piecewise-linear functions that can be viewed as tropical rational functions; the dual complex of a tropical variety is precisely a polyhedral complex of the type we formalized. This bridge could connect network expressiveness bounds to the rich theory of tropical algebraic geometry — including tropical Hodge theory, which is an active area of current research.

The quantitative Hodge rank bound $h^{p,q} \leq \binom{w_1}{p} \cdot \binom{w_L}{q}$ was verified for specific architectures but remains conjectural in general. Proving or disproving this bound for deep networks is the highest-priority open problem, as it would either provide a new tool for architecture design or reveal unexpected topological phenomena in deep decision surfaces.

---

### Direction 1: Tropical Hodge Theory for ReLU Networks

**Conjecture**: For a ReLU network $f: \mathbb{R}^n \to \mathbb{R}$ with $L$ hidden layers, the tropical dual complex $\Delta(f)$ is homotopy equivalent to the decision surface $V(f) = f^{-1}(0)$, and the tropical Hodge numbers of $\Delta(f)$ satisfy the bound $h^{p,q}_{\text{trop}} \leq \binom{w_1}{p} \cdot \binom{w_L}{q}$.

**Test**: Compute the tropical dual complex for explicit 2-layer ReLU networks $f: \mathbb{R}^2 \to \mathbb{R}$ with varying widths $w \in \{3, 5, 10\}$. Compare the tropical Hodge numbers with the conjectured bound. If any network violates the bound, the conjecture is false.

**Impact**: If true, this would unify three fields: (1) neural network expressiveness theory, (2) tropical algebraic geometry, and (3) polyhedral combinatorics. It would provide a computational tool for predicting the topological complexity of decision boundaries *before training*.

**Catalog References**: `Tropical/` (tropical geometry modules), `Algebra/NeuralHodge/Theorems.lean`

**Proof Strategy**: First, establish that ReLU networks define tropical rational functions via the max/plus semiring. Then show the dual complex of the tropical variety coincides with the polyhedral complex of the decision surface. Finally, apply the Adiprasito-Huh-Katz theory of log-concavity to bound the Hodge numbers.

**Domain Bridges**: Tropical geometry <-> Neural network expressiveness <-> Polyhedral combinatorics

**Lineage**: Builds on the Zaslavsky bounds and PL Hodge property from this cycle, extends toward the tropical geometry modules in the Catalog.

**Ambition**: grand_challenge

---

### Direction 2: Training Dynamics of Decision Surface Topology

**Conjecture**: During gradient descent training of a ReLU network, the Betti numbers $\beta_p$ of the decision surface $V(f_t)$ are monotonically non-decreasing until a critical epoch $t^*$, after which they monotonically decrease. The critical epoch $t^*$ coincides with the transition from underfitting to overfitting.

**Test**: Train 100 random 3-layer ReLU networks $[2, w, 1]$ with $w \in \{5, 10, 20\}$ on synthetic 2D classification datasets with known topology (e.g., concentric circles with $\beta_1 = 1$, two moons with $\beta_0 = 2$). Track $\beta_0$ and $\beta_1$ of the decision boundary at each training epoch. Plot the Betti number trajectories and identify whether the conjectured monotonicity pattern holds.

**Impact**: If true, this would provide a topological criterion for early stopping — stop training when the Betti numbers match the target topology. If false, the failure mode (oscillating Betti numbers? no monotone phase?) would reveal important features of how gradient descent navigates the space of PL functions.

**Catalog References**: `Algebra/NeuralHodge/Theorems.lean`, `MachineLearning/` modules

**Proof Strategy**: Use the fact that small parameter perturbations can only change the combinatorial type of the arrangement by finitely many transitions. Each transition either adds or removes a face, changing Betti numbers by at most 1. The conjecture reduces to showing that gradient descent follows a path in parameter space that respects this local topology.

**Domain Bridges**: Optimization theory <-> Algebraic topology <-> Neural network generalization

**Lineage**: Builds on the Euler characteristic formulas and face bounds from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Sharp Zaslavsky Bounds for Structured Arrangements

**Conjecture**: For a ReLU network with weight matrices of rank $r_i$ at layer $i$, the number of linear regions is at most $\text{maxRegions}(w, r) = \sum_{k=0}^{r} \binom{w}{k}$ where $r = \min_i r_i$, strictly improving the standard bound $\text{maxRegions}(w, d)$ when the weight matrices are rank-deficient.

**Test**: Construct 2-layer networks $[d, w, 1]$ with $d = 10$, $w = 20$, and weight matrices of rank $r \in \{2, 5, 10\}$. Enumerate the actual linear regions (possible for small examples) and compare with both the standard bound $\text{maxRegions}(20, 10)$ and the conjectured sharp bound $\text{maxRegions}(20, r)$.

**Impact**: This would tighten the expressiveness bounds for networks with structured (low-rank) weights, which are common in practice due to regularization and pruning.

**Catalog References**: `Algebra/NeuralHodge/Theorems.lean` (specifically `maxRegions_mono_right` which shows dimension monotonicity)

**Proof Strategy**: Use the fact that rank-$r$ weight matrices map $\mathbb{R}^d$ into an $r$-dimensional subspace, so the induced arrangement has at most $w$ hyperplanes in $\mathbb{R}^r$. Apply the standard Zaslavsky bound in the lower dimension.

**Domain Bridges**: Linear algebra (matrix rank) <-> Hyperplane arrangement combinatorics <-> Neural network compression

**Lineage**: Directly extends `maxRegions_mono_right` from this cycle to structured settings.

**Ambition**: extension

---

### Direction 4: Euler Characteristic as a Loss Regularizer

**Conjecture**: Adding a penalty term $\lambda \cdot |\chi(V(f)) - \chi_{\text{target}}|$ to the training loss, where $\chi_{\text{target}}$ is the Euler characteristic of the ground-truth decision boundary, improves generalization on datasets with known topology, reducing test error by at least 10% compared to unregularized training for $\lambda$ in an appropriate range.

**Test**: On the "two moons" dataset ($\chi_{\text{target}} = 2$, two connected components), train networks with and without the Euler regularizer. Measure test accuracy over 50 random seeds. The regularizer can be computed from the polyhedral structure of $V(f)$ using the formula $\chi = \sum (-1)^i f_i$ verified in this cycle.

**Impact**: This would be the first *topologically-aware* regularization method for neural networks, going beyond standard $L^2$ / dropout approaches.

**Catalog References**: `Algebra/NeuralHodge/Theorems.lean` (specifically `euler_char_graph`, `euler_char_zero_dim`)

**Proof Strategy**: The Euler characteristic can be computed from the face vector of the polyhedral decision boundary. Show that the gradient of $\chi$ with respect to network parameters is piecewise-constant (since $\chi$ is integer-valued and changes only at combinatorial transitions). Use a surrogate smooth approximation for gradient-based optimization.

**Domain Bridges**: Topological data analysis <-> Regularization theory <-> Neural network training

**Lineage**: Builds on the Euler characteristic computations from this cycle.

**Ambition**: extension

---

### Direction 5: Betti Number Bounds for Multi-Layer Architectures

**Conjecture**: For a deep ReLU network with architecture $[n, w_1, w_2, \ldots, w_L, 1]$, the $p$-th Betti number of the decision surface satisfies $\beta_p(V(f)) \leq \prod_{i=1}^{L} \binom{w_i}{p}$.

**Test**: Formalize this bound in Lean 4 for $L = 2$ (i.e., architecture $[n, w_1, w_2, 1]$) and attempt to prove it using the face bounds and PL Hodge property. For the computational test, enumerate linear regions of random 3-layer networks with small widths ($w_1, w_2 \leq 5$) and compute Betti numbers of the decision boundary using computational topology (e.g., persistent homology).

**Impact**: This would generalize the two-layer Hodge rank bound $h^{p,q} = \binom{w_1}{p} \cdot \binom{w_L}{q}$ to arbitrary depth, providing the first *depth-dependent* topological capacity theorem.

**Catalog References**: `Algebra/NeuralHodge/Theorems.lean` (specifically `hodge_rank_two_layer`, `deep_bound_mono_layers`)

**Proof Strategy**: Induction on the number of layers. At each layer, the arrangement is refined by at most $w_i$ new hyperplanes, each of which can increase $\beta_p$ by at most $\binom{w_i}{p}$ (by the Mayer-Vietoris sequence). The product bound follows from the multiplicative nature of the refinement.

**Domain Bridges**: Algebraic topology (Mayer-Vietoris) <-> Neural network depth theory <-> Combinatorics

**Lineage**: Directly extends `hodge_rank_two_layer` and `deep_bound_mono_layers` from this cycle.

**Ambition**: extension
