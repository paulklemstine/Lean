# Future Research Directions: Fiber Graphs in Hamming Spaces

## Synthesis

This research cycle established the formal theory of fiber graphs induced by additive scoring functions on Hamming spaces. We proved 13 theorems organized around three conceptual pillars: (1) the Score Delta Algebra, establishing that per-position score changes form an antisymmetric, additive structure; (2) the Bridge Duality Theorem, showing that for configurations differing at exactly two positions, bridge existence through one position is logically equivalent to bridge existence through the other; and (3) the Position Separation Rigidity Theorem, showing that for injective weight systems, same-score configurations agreeing everywhere except one position must be identical.

The most promising cross-domain connection is between fiber expansion and tropical algebra. The additive scoring framework generalizes naturally to tropical (min-plus) scoring by replacing the abelian group $(G, +)$ with the tropical semiring $(\mathbb{Z} \cup \{\infty\}, \min, +)$. Under tropical scoring, fibers become tropical hyperplanes, and the bridge duality theorem has a tropical analogue involving "tropical bridges" — configurations where the minimum-achieving index can shift between positions. This connects to `Tropical/MixingTheory.lean` and `Bridges/TropicalMixingDirect.lean` in the Catalog, where mixing time bounds for tropical Markov chains are established.

The highest breakthrough potential lies in Direction 1 (Spectral Gap of Fiber Graphs). The bridge duality theorem provides the first structural tool: it rules out one-sided bottlenecks in fiber graphs. Proving the full spectral expansion conjecture would yield polynomial-time sampling algorithms for fibers of generic additive maps, with immediate applications in coding theory (random codeword generation), statistical physics (energy shell sampling), and computational biology (neutral network exploration). The Score Swap Lemma from this cycle provides the key technical mechanism for constructing long paths within fibers, which is needed for proving rapid mixing.

---

### Direction 1: Spectral Gap of Fiber Graphs

**Conjecture**: For $q \geq 3$ and a weight system $w: [n] \times [q] \to \mathbb{Z}$ where all $w_i$ are injective (position-separating), the second eigenvalue $\lambda_2$ of the normalized Laplacian of the fiber graph $\Gamma_v$ satisfies $\lambda_2(\Gamma_v) \geq c/n$ for a universal constant $c > 0$ depending only on $q$, for all but a measure-zero set of weight systems.

**Test**: For $n = 5, q = 3$, enumerate all $3^5 = 243$ configurations, compute fiber graphs for 100 random position-separating weight systems with integer weights in $[-20, 20]$, and verify that $\lambda_2 \geq c/5$ for all non-trivial fibers (those with $\geq 2$ vertices). The predicted constant is $c \approx 0.5$ based on heuristic calculations.

**Impact**: If true, this immediately yields $O(n \log n)$ mixing time for the natural random walk on fibers, providing efficient uniform sampling from fibers. This connects to constraint satisfaction (sampling satisfying assignments of additive constraints), coding theory (random code generation), and statistical physics (canonical ensemble sampling). If false, the counterexample would reveal bottleneck structures in fiber graphs with deep implications for hardness of sampling.

**Catalog References**: `Tropical/MixingTheory.lean` (tropical_cycle_gap_mixing_lower_bound), `Bridges/TropicalMixingDirect.lean` (lorentzian_mixing_time_le_direct_tropical)

**Proof Strategy**: (1) Establish the fiber graph is connected for position-separating systems using the Score Swap Lemma iteratively. (2) Use the canonical path method: for each pair $(x, y)$ in the fiber, construct a canonical path of length $O(n)$ using bridge duality to route through single-position changes. (3) Bound the congestion ratio by showing each edge appears in at most $O(|F_v|^2 / n)$ canonical paths, using the double-counting argument from the Plotkin bound. (4) Apply the canonical path theorem to get $\lambda_2 \geq \Omega(1/n)$.

**Domain Bridges**: Fiber graph spectral theory ↔ Tropical mixing theory (via min-plus analogue of additive scoring)

**Lineage**: Builds on Bridge Duality Theorem and Score Swap Lemma from this cycle. Extends the tropical mixing bounds in the Catalog to the additive (classical) setting.

**Ambition**: grand_challenge

---

### Direction 2: Tropical Bridge Duality

**Conjecture**: In the tropical semiring $(\mathbb{Z} \cup \{\infty\}, \min, +)$, define the tropical score as $f_w^{\text{trop}}(x) = \min_{i=1}^n w_i(x_i)$. For two configurations $x, y$ with $f_w^{\text{trop}}(x) = f_w^{\text{trop}}(y)$ differing at positions $\{i, j\}$, define a tropical bridge through $i$ as a configuration $z$ agreeing with $x$ except at $i$ (where $z_i = y_i$) with $f_w^{\text{trop}}(z) = f_w^{\text{trop}}(x)$. Conjecture: tropical bridge duality FAILS — there exist weight systems where a tropical bridge exists through $i$ but not through $j$.

**Test**: Construct explicit counterexample. Consider $n=3, q=2$. Let $w_1(0) = 0, w_1(1) = 5, w_2(0) = 3, w_2(1) = 0, w_3(0) = 2, w_3(1) = 2$. Take $x = (0, 0, 0)$ and $y = (1, 1, 0)$. Compute $f^{\text{trop}}(x) = \min(0, 3, 2) = 0$ and $f^{\text{trop}}(y) = \min(5, 0, 2) = 0$. Check bridges through position 1 and 2 separately. Bridge through 1: $z = (1, 0, 0)$, $f^{\text{trop}}(z) = \min(5, 3, 2) = 2 \neq 0$. Bridge through 2: $z' = (0, 1, 0)$, $f^{\text{trop}}(z') = \min(0, 0, 2) = 0$. Bridge through 2 exists but not through 1!

**Impact**: Confirms that bridge duality is a specifically additive phenomenon, not a general feature of scoring functions. The failure mode reveals why tropical geometry requires fundamentally different tools than linear algebra — the lack of cancellation in the min-plus semiring breaks the seesaw argument that underlies additive bridge duality. This connects to the broader question of which algebraic structures support symmetric obstruction theorems.

**Catalog References**: `Algebra/TropicalDragon.lean` (not_all_space_filling_are_dragon_limits), `Tropical/SymbolicDynamics/Core.lean` (tropical_spectral_gap_implies_mixing_and_extraction)

**Proof Strategy**: (1) Formalize the tropical scoring function as min over per-position weights. (2) Define tropical bridges analogously to additive bridges. (3) Prove by explicit construction that tropical bridge duality fails: exhibit a weight system where bridge through $i$ exists but bridge through $j$ does not. (4) Characterize when tropical bridge duality holds (conjecture: iff the minimizing indices are the same for both configurations).

**Domain Bridges**: Additive fiber theory ↔ Tropical algebra (failure of bridge duality marks the boundary between linear and tropical regimes)

**Lineage**: Extends the Bridge Duality Theorem from this cycle by testing its limits. Builds on the tropical spectral gap theory in the Catalog.

**Ambition**: extension

---

### Direction 3: Fiber Counting via Fourier Analysis

**Conjecture**: For a weight system $w: [n] \times [q] \to \mathbb{Z}_m$ (scoring into a cyclic group), the fiber size $|F_v|$ satisfies $|F_v| = q^n / m + O(q^{n/2} \sqrt{m})$ for all $v \in \mathbb{Z}_m$, provided the weight system is "balanced" (each $w_i$ is surjective onto $\mathbb{Z}_m$).

**Test**: For $n = 6, q = 3, m = 9$, enumerate all $3^6 = 729$ configurations for 50 random balanced weight systems. Compute exact fiber sizes and verify the deviation from $729/9 = 81$ is at most $O(729^{1/2} \cdot 3) = O(81)$.

**Impact**: Fiber counting is the fundamental question in additive combinatorics. This bound would generalize the classical result that cosets of linear codes have equal size ($|F_v| = q^{n-k}$ for $[n, k]$ codes) to the nonlinear setting. It would provide a "universality" result: most fibers are approximately the same size regardless of the weight system, as long as each position's weights cover all residues.

**Catalog References**: `Novelty/CollatzSpectral/Theorems.lean` (spectral_energy_bound)

**Proof Strategy**: (1) Express $|F_v|$ as a Fourier sum using characters of $\mathbb{Z}_m$: $|F_v| = (1/m) \sum_{\chi} \overline{\chi}(v) \prod_{i=1}^n \sum_{a \in [q]} \chi(w_i(a))$. (2) The $\chi = 1$ term gives $q^n/m$. (3) For $\chi \neq 1$ and balanced weights, each factor $|\sum_a \chi(w_i(a))| \leq q - m/q$ by the surjectivity condition. (4) Bound the error by $(m-1) \cdot (q - m/q)^n$, which is exponentially small when $q > m$.

**Domain Bridges**: Fiber graph structure ↔ Fourier analysis on finite abelian groups (Pontryagin duality provides the counting tool)

**Lineage**: Builds on the fiber partition theorem from this cycle (fibers are disjoint and cover the space).

**Ambition**: extension

---

### Direction 4: Multi-Position Bridge Duality

**Conjecture**: The Bridge Duality Theorem generalizes to configurations differing at $k \geq 3$ positions. Specifically, for $x, y \in F_v$ with $\text{diff}(x, y) = S$ where $|S| = k$, define a bridge through subset $T \subset S$ as a configuration $z$ agreeing with $x$ on $[n] \setminus T$, with $z_i = y_i$ for $i \in T$, and $f_w(z) = v$. Conjecture: for additive scoring, bridge existence through any $T$ of size $t$ depends only on $t$, not on which positions are in $T$.

**Test**: For $n = 4, q = 3$, find $x, y$ differing at positions $\{1, 2, 3\}$ with the same score. Check whether a bridge through $\{1\}$ exists iff a bridge through $\{2\}$ exists iff a bridge through $\{3\}$ exists (size-1 case). Then check whether a bridge through $\{1, 2\}$ exists iff a bridge through $\{1, 3\}$ exists iff a bridge through $\{2, 3\}$ exists (size-2 case).

**Impact**: If true, this would reveal that the "symmetric obstruction" property of bridge duality extends to all scales, establishing a deep equivariance property of fiber graphs under position permutations (restricted to the differing positions). This would have applications to the design of error-correcting codes with prescribed local correction properties.

**Catalog References**: `Novelty/FiberGraph/Theorems.lean` (bridge_duality, score_swap_via_matches)

**Proof Strategy**: (1) For size-1 subsets: a bridge through $\{i\}$ exists iff $w_i(y_i) = w_i(x_i)$ (from score_modify). Bridge through $\{j\}$ iff $w_j(y_j) = w_j(x_j)$. From $\sum_{k \in S} (w_k(y_k) - w_k(x_k)) = 0$, if one delta vanishes, the others sum to zero, but individual deltas need not vanish. So the conjecture may fail for $k \geq 3$ and size-1 subsets! (2) Verify computationally. (3) If the conjecture fails for size-1 subsets with $k = 3$, characterize exactly when multi-position bridge duality holds.

**Domain Bridges**: Multi-position bridges ↔ Error-correcting code local correction (bridge sets correspond to information sets in coding theory)

**Lineage**: Direct generalization of the Bridge Duality Theorem from this cycle.

**Ambition**: grand_challenge

---

### Direction 5: Fiber Graph Chromatic Number

**Conjecture**: The chromatic number of the fiber graph $\Gamma_v$ for a position-separating weight system $w: [n] \times [q] \to \mathbb{Z}$ satisfies $\chi(\Gamma_v) \leq q$ for all fibers $v$.

**Test**: For $n = 4, q = 3$, enumerate fiber graphs for 100 random position-separating weight systems and compute chromatic numbers (via brute-force or greedy coloring). Verify $\chi \leq 3$ in all cases.

**Impact**: If true, this would establish an elegant connection between the alphabet size and the graph coloring complexity of fibers. Since fiber graphs are subgraphs of the Hamming graph (which has chromatic number $q$), the conjecture asks whether restricting to a single fiber preserves this bound. A positive answer would have implications for distributed computing on fiber-structured networks.

**Catalog References**: `Novelty/FiberGraph/Defs.lean` (PositionSeparating, fiberAdj)

**Proof Strategy**: Attempt a coloring construction based on the value at position 1: color configuration $x$ with $x_1$. Two adjacent configurations differ at one position $i$; if $i = 1$, they have different colors by construction. If $i \neq 1$, they agree at position 1 and have the same color — so this naive approach fails. Try a more sophisticated coloring using hash functions of the configuration values, or prove the bound using the Lovász theta function.

**Domain Bridges**: Fiber graph combinatorics ↔ Graph coloring theory (chromatic number bounds from algebraic structure)

**Lineage**: Builds on the fiber graph definitions and position-separation theory from this cycle.

**Ambition**: extension
