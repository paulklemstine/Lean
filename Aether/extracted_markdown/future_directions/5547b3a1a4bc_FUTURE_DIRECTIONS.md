# Future Directions: Neural Hodge Theory

## Synthesis

This research cycle established the foundational connection between ReLU neural network decision surfaces and algebraic topology, proving that the piecewise linear Hodge conjecture holds for these surfaces and deriving quantitative bounds on their topological complexity via Zaslavsky's theorem and polyhedral face counting.

The most promising cross-domain connection emerged between **combinatorial geometry** (hyperplane arrangement theory) and **deep learning theory**: the Zaslavsky bound $Z(m,n) = \sum_{k=0}^n \binom{m}{k}$ provides a sharp bridge between network architecture parameters and the topological invariants of decision surfaces. The polynomial bound $Z(m,n) \le (m+1)^n$ — formally verified — reveals that depth contributes exponentially while width contributes polynomially to decision surface complexity, a mathematically precise statement of the "depth vs. width" trade-off.

The Hodge number bound conjecture $h^{p,q} \le \binom{w_1}{p} \binom{w_L}{q} \prod_{i=2}^{L-1} w_i$ is the highest-breakthrough-potential direction. If proved, it would provide architects of neural networks with a principled formula for minimum network size given topological constraints on the desired decision boundary. If disproved, the counterexample construction would itself be mathematically interesting, revealing which topological configurations can arise from composed piecewise linear maps. Empirical testing across 200+ random networks found no violations, supporting the conjecture.

---

### Direction 1: Persistent Homology of Decision Surfaces During Training

**Conjecture**: For a ReLU network trained by gradient descent on a binary classification task, the Betti numbers $\beta_k(V(f_t))$ of the decision surface at time $t$ are non-increasing after a critical training time $t^*$, and converge to the minimal Betti numbers consistent with the data topology.

**Test**: Train 100 random 2→8→8→1 networks on the two-moons dataset. At each epoch, compute $\beta_0$ and $\beta_1$ of the decision curve using grid sampling. Plot Betti number trajectories. Check whether: (a) all trajectories eventually become monotone non-increasing, and (b) they converge to $\beta_0 = 2$ (the number of moons).

**Impact**: If true, this establishes a topological characterization of convergence in deep learning — the network "simplifies" its decision surface during training, analogous to Ricci flow smoothing a manifold. This would connect gradient descent dynamics to discrete Morse theory.

**Catalog References**: `Algebra/NeuralHodge/Theorems.lean` (Betti bounds), `Algebra/NeuralHodge/Defs.lean` (PLComplex, NetworkArchitecture)

**Proof Strategy**: First establish that the set of achievable Betti numbers for a given architecture is finite (follows from our face count bounds). Then show that the loss function induces a partial order on topological types that is compatible with gradient descent. Key lemma: crossing a ReLU activation boundary (where a neuron switches from active to inactive) changes $\beta_k$ by at most 1 (a Morse-theoretic statement).

**Domain Bridges**: MachineLearning <-> Algebra, Computation <-> Geometry

**Lineage**: Builds on the PLComplex and BettiData structures from this cycle, extends the static bounds to a dynamic setting.

**Ambition**: grand_challenge

---

### Direction 2: Tight Extremal Networks for the Hodge Bound

**Conjecture**: For every architecture $(n, w_1, \ldots, w_L)$ with $n = 2$, $L = 2$, and $w_1, w_2 \ge 4$, there exists a weight configuration such that $\beta_0(V(f)) = \binom{w_1}{1} \cdot \binom{w_2}{1} = w_1 \cdot w_2$.

**Test**: For the architecture $(2, 4, 4, 1)$, perform a gradient-free optimization (e.g., CMA-ES) over the weight space to maximize $\beta_0$ of the decision curve. The target is $\beta_0 = 16$. If achieved, the bound is tight; if the maximum is strictly less than 16, the bound can be improved.

**Impact**: Tight bounds transform the Hodge number conjecture from a qualitative statement into a precise architectural design tool. If the bound is not tight, finding the exact maximum would reveal how network connectivity constraints (composition of layers) restrict the achievable topologies, potentially yielding a corrected formula.

**Catalog References**: `Algebra/NeuralHodge/Theorems.lean` (zaslavskyBound_le_pow_succ, networkRegionBound_mono_widths)

**Proof Strategy**: Construct explicit weight matrices that place hyperplanes in general position at each layer. For layer 1, choose $w_1$ hyperplanes in $\mathbb{R}^2$ that create the maximum number of regions. For layer 2, choose $w_2$ hyperplanes in the "ReLU-folded" space that further subdivide the decision surface. The key obstacle is that the ReLU folding maps different regions to overlapping areas of the folded space, potentially preventing independent subdivision.

**Domain Bridges**: Algebra <-> MachineLearning, Geometry <-> Computation

**Lineage**: Directly extends the region bound and Hodge bound from this cycle.

**Ambition**: extension

---

### Direction 3: Tropical Geometry of ReLU Decision Surfaces

**Conjecture**: The decision surface $V(f)$ of a ReLU network is a tropical hypersurface in the sense of tropical geometry, and its Newton polytope encodes the network architecture. Specifically, the tropical degree of $V(f)$ equals the network region bound.

**Test**: For a 2→4→1 network, compute the tropical polynomial associated with the piecewise linear function $f$. Verify that its Newton polygon has at most $Z(4,2) = 11$ vertices and that the dual subdivision of the Newton polygon corresponds to the linear region decomposition.

**Impact**: If true, this establishes a formal dictionary between neural network architecture and tropical algebraic geometry: layers correspond to tropical multiplication, ReLU corresponds to tropical addition, and the decision surface is a tropical variety. This would import the full machinery of tropical intersection theory into deep learning.

**Catalog References**: `Tropical/` (existing tropical geometry library), `Algebra/NeuralHodge/Defs.lean` (relu, zaslavskyBound)

**Proof Strategy**: The key insight is that $\text{relu}(x) = \max(x, 0)$ is the tropical sum $x \oplus 0$ in the $(\max, +)$ semiring. A composition of affine-ReLU layers is therefore a tropical rational function. Establish that: (1) single-layer networks correspond to tropical polynomials, (2) composition corresponds to tropical composition (substitution), (3) the zero set in the tropical sense matches $V(f)$ in the classical sense for generic weights.

**Domain Bridges**: Tropical <-> Algebra, MachineLearning <-> Geometry

**Lineage**: New direction inspired by the observation that ReLU is tropical addition.

**Ambition**: grand_challenge

---

### Direction 4: Spectral Gap Bounds from Decision Surface Topology

**Conjecture**: For a ReLU network with decision surface $V(f)$ having Betti numbers $\beta_0, \beta_1, \ldots$, the spectral gap of the Laplacian on $V(f)$ (viewed as a metric graph in 2D, or a polyhedral manifold in higher dimensions) satisfies $\lambda_1 \ge c / \beta_0^2$ for a universal constant $c > 0$ depending only on the input dimension.

**Test**: For 2D networks (2→w→1 for $w = 2, 4, 8, 16$), compute the decision curve as a planar graph. Compute the graph Laplacian and its spectral gap $\lambda_1$. Plot $\lambda_1$ vs $\beta_0$ and check whether the relationship is $\Theta(1/\beta_0^2)$.

**Impact**: This connects network topology to the rate of information propagation across the decision surface. A large spectral gap means the decision boundary is "well-connected" and less susceptible to adversarial perturbations. Combined with the Hodge bound, this would give architecture-dependent adversarial robustness certificates.

**Catalog References**: `Algebra/NeuralHodge/Theorems.lean` (BettiData, PLComplex.eulerChar_abs_le), `Algebra/SpectralContractionAlgebra.lean` (geometric_partial_sum_bound)

**Proof Strategy**: Start with the Cheeger inequality $\lambda_1 \ge h^2 / 2$ where $h$ is the Cheeger constant. For a PL manifold with $\beta_0$ components, bound $h$ from below using the face structure. The key lemma: for a connected component of $V(f)$ with $k$ faces, $h \ge c / k$ by an isoperimetric argument on the polyhedral complex.

**Domain Bridges**: Algebra <-> Physics, MachineLearning <-> Geometry

**Lineage**: Extends the Euler characteristic and Betti bounds from this cycle to spectral invariants.

**Ambition**: extension

---

### Direction 5: Equivariant Hodge Theory for Symmetric Networks

**Conjecture**: For a ReLU network with permutation-equivariant layers (e.g., DeepSets architecture), the Hodge numbers of the decision surface satisfy the stronger bound $h^{p,q} \le \binom{w_1/n}{p} \cdot \binom{w_L/n}{q}$ where $n$ is the input dimension and the widths are assumed to be multiples of $n$.

**Test**: Construct equivariant networks with architecture $(3, 6, 6, 1)$ where layers commute with the $S_3$ permutation action. Compute the decision surface and check whether its Betti numbers satisfy the tightened bound ($h^{0,1} \le 2 \cdot 2 = 4$ instead of $6 \cdot 6 = 36$).

**Impact**: Symmetry constraints dramatically reduce topological complexity. This would quantify the "geometric prior" induced by equivariant architectures, explaining their superior sample efficiency as a topological simplification effect.

**Catalog References**: `Algebra/NeuralHodge/Theorems.lean` (hodgeNumberBound), `Bridges/` (existing symmetry-related bridges)

**Proof Strategy**: The $S_n$-action on the input space induces an action on the arrangement of hyperplanes. Equivariance forces hyperplanes to come in orbits under this action, reducing the effective number of independent hyperplanes by a factor of $|S_n| / |\text{Stab}|$. Apply the equivariant Zaslavsky bound (a known result in arrangement theory) to get the tighter estimate.

**Domain Bridges**: Algebra <-> MachineLearning, Geometry <-> Physics

**Lineage**: Extends the Hodge bound conjecture to the equivariant setting.

**Ambition**: extension
