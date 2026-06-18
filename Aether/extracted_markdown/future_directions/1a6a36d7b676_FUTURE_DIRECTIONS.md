# Future Research Directions: Cognitive Dynamics and Period Forcing

## Synthesis

This research cycle established a rigorous formalized foundation for the theory of period forcing in continuous dynamical systems, motivated by modeling cognitive state transitions and déjà vu. The crown jewel — Theorem `period3_full_recurrence_spectrum` — proves that any continuous map with a period-3 orbit has periodic points of every positive integer period, formalizing the core of the Li-Yorke/Sharkovsky theorem. This was achieved through a remarkably clean argument: the period-3 orbit provides global bounds on iterates (minimum stays a lower bound, maximum an upper bound), enabling direct application of the Intermediate Value Theorem to each iterate f^n.

The covering lemma machinery (Theorems `period3_I1_self_covers`, `period3_I0_covers_I1`, `period3_I1_covers_I0`) decomposed the forcing mechanism into three modular interval-covering relations that form a directed graph with cycles of every length. The forward invariance of ω-limit sets (`omegaLimit_forward_invariant`) connects the periodic orbit structure to long-term attractor theory. The recurrence spectrum harmonic closure (`recurrence_harmonic`) and orbit entropy monotonicity (`orbitEntropy_strictMono`) bridge dynamical systems with information theory.

The most promising cross-domain connection is between the **covering graph structure** and **symbolic dynamics / automata theory** in the Computation catalog. The directed graph of covering relations (I₀ → I₁, I₁ → I₀, I₁ → I₁) is equivalent to a subshift of finite type, connecting period forcing to formal language theory and computability. This bridge could yield new results on the decidability of dynamical properties and complexity-theoretic characterizations of chaos. The existing `Computation/AutomaticDecidability.lean` and `Computation/InfoEfficientAlgorithms.lean` in the catalog provide natural foundations.

---

### Direction 1: Full Sharkovsky Ordering and Minimal Period Forcing

**Conjecture**: For every pair of positive integers (m, n) with m ◁ n in the Sharkovsky ordering (3 ◁ 5 ◁ 7 ◁ ... ◁ 2·3 ◁ 2·5 ◁ ... ◁ 4 ◁ 2 ◁ 1), if a continuous function f : ℝ → ℝ has a periodic point of minimal period m, then f has a periodic point of minimal period n. Moreover, for each position in the ordering, there exists a continuous function that has that period but not the one immediately preceding it.

**Test**: Formalize the Sharkovsky ordering as a well-ordering on ℕ. Prove the forward direction (period m forces period n) for the first few cases beyond period 3: specifically, prove that period 5 forces periods 3, 2, and 1; and that period 2·3 = 6 forces period 3. Construct explicit continuous functions achieving each boundary case.

**Impact**: A full formalization of Sharkovsky's theorem would be a landmark in formalized mathematics — this theorem is surprisingly difficult to prove in full generality and has never been completely formalized in any proof assistant. It would establish the complete hierarchy of period forcing and provide definitive answers about which cognitive recurrence patterns imply which others.

**Catalog References**: `Computation/CognitiveDynamics.lean` (this cycle's results), `Computation/Bifurcation.lean` (existing bifurcation theory)

**Proof Strategy**: 
1. Define the Sharkovsky ordering formally as a total order on ℕ⁺
2. Prove the ordering is a well-ordering
3. For each consecutive pair in the ordering, construct the covering graph of a period-m orbit and show it contains cycles of all required lengths
4. The key technical tool is Stefan's theorem: any period-m orbit can be decomposed into a specific pattern of left/right moves, determining the covering graph structure

**Domain Bridges**: Computation (automata theory, subshifts) ↔ Analysis (IVT, continuity) ↔ Combinatorics (directed graph cycle structure)

**Lineage**: Builds on `period3_full_recurrence_spectrum`, `period3_I1_self_covers`, `period3_I0_covers_I1`, `period3_I1_covers_I0` from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Li-Yorke Chaos — Uncountable Scrambled Sets

**Conjecture**: If f : [0,1] → [0,1] is continuous and has a period-3 orbit, then there exists an uncountable set S ⊂ [0,1] such that for every pair of distinct points x, y ∈ S:
- lim inf_{n→∞} |f^n(x) - f^n(y)| = 0 (orbits come arbitrarily close)
- lim sup_{n→∞} |f^n(x) - f^n(y)| > 0 (orbits repeatedly separate)

This is the full content of the Li-Yorke chaos theorem — not just period existence, but genuine topological complexity.

**Test**: Construct the scrambled set explicitly using a Cantor-type construction in the covering graph. Each point in the scrambled set corresponds to an infinite path in the directed graph I₀ ↔ I₁ that avoids all eventually periodic patterns. Show this set is uncountable using a diagonal/injection argument.

**Impact**: This would be the first complete formalization of Li-Yorke chaos in any proof assistant. It establishes that period-3 cognitive dynamics are not just rich in periodic orbits — they contain uncountably many trajectories that are genuinely aperiodic yet exhibit complex recurrence. This is the formal mathematical content of "deterministic unpredictability" in cognitive dynamics.

**Catalog References**: `Computation/CognitiveDynamics.lean`, `Computation/CollatzTropical.lean` (contraction arguments)

**Proof Strategy**:
1. Use the covering lemmas to construct nested sequences of intervals I_{n,0}, I_{n,1} such that f maps each into the next
2. By the nested interval theorem, each infinite binary sequence ω ∈ {0,1}^ℕ determines a unique point x_ω
3. Show that distinct sequences give distinct points (injectivity from the covering structure)
4. Prove the scrambling property: sequences that agree on long blocks give close orbits (liminf = 0), while differing sequences give separated orbits (limsup > 0)

**Domain Bridges**: Computation (Cantor set, uncountability) ↔ Analysis (nested intervals, completeness) ↔ Topology (limit sets, closure)

**Lineage**: Builds on the covering lemmas from this cycle.

**Ambition**: grand_challenge

---

### Direction 3: Topological Entropy from Period Counting

**Conjecture**: For a continuous map f : [0,1] → [0,1], the topological entropy h(f) satisfies:
$$h(f) = \lim_{n \to \infty} \frac{1}{n} \log |Fix(f^n)|$$
where Fix(f^n) is the set of fixed points of f^n (equivalently, periodic points of f with period dividing n). Moreover, for the logistic map at r = 4, h(f) = log 2 and |Fix(f^n)| = 2^n.

**Test**: 
1. Prove the formula |Fix(f^n)| = 2^n for the full logistic map f(x) = 4x(1-x) using the conjugacy with the tent map T(x) = 1 - |2x - 1|
2. Establish that topological entropy equals the exponential growth rate of periodic points
3. Computationally verify for logistic maps at various r values

**Impact**: Connects the periodic orbit structure (our recurrence spectrum) to a single numerical invariant — topological entropy. This would provide a quantitative measure of "cognitive complexity" derived from the déjà vu spectrum, bridging our qualitative forcing results with quantitative information theory.

**Catalog References**: `Computation/CognitiveDynamics.lean`, `EML/AdvancedTheory.lean` (entropy definitions), `Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**:
1. Define topological entropy via the Bowen-Dinaburg definition (minimal covers of orbit segments)
2. Prove the variational principle: h(f) = sup_μ h_μ(f) over invariant measures
3. Establish the period-counting formula as a consequence
4. For the logistic map, use the semiconjugacy with the tent map

**Domain Bridges**: Computation (entropy, information theory) ↔ Analysis (measure theory) ↔ EML (ensemble complexity)

**Lineage**: Builds on `orbitEntropy_strictMono` and `recurrence_harmonic` from this cycle.

**Ambition**: extension

---

### Direction 4: Symbolic Dynamics and Covering Graph Automata

**Conjecture**: The covering graph of a period-n orbit (the directed graph on intervals determined by the IVT covering relations) is equivalent to a sofic subshift, and the topological entropy of the original map equals the logarithm of the spectral radius of the covering graph's adjacency matrix.

**Test**: Formalize the adjacency matrix of the covering graph for period-3, period-5, and period-7 orbits. Compute spectral radii and compare with known topological entropies. For period-3: the adjacency matrix is [[0,1],[1,1]] with spectral radius (1+√5)/2 (golden ratio), giving entropy log((1+√5)/2) ≈ 0.481.

**Impact**: This bridges dynamical systems theory with automata theory and linear algebra. The covering graph becomes a finite automaton that "generates" all possible orbit patterns, and the spectral radius of its transition matrix controls the asymptotic complexity. This connects to the existing `Computation/AutomaticDecidability.lean` work on automatic sequences and decidability.

**Catalog References**: `Computation/AutomaticDecidability.lean`, `Computation/CognitiveDynamics.lean`, `Algebra/Advanced.lean`

**Proof Strategy**:
1. Define the covering graph formally as a directed graph
2. Associate to each covering graph its adjacency matrix over ℝ
3. Prove that paths of length n in the covering graph correspond to periodic orbits of f^n (via nested IVT applications)
4. Use the transfer matrix method to count paths, establishing |Per_n(f)| = Tr(A^n)
5. Apply the spectral radius formula: growth rate = log(ρ(A))

**Domain Bridges**: Computation (automata, formal languages) ↔ Algebra (spectral theory, Perron-Frobenius) ↔ Analysis (dynamical systems)

**Lineage**: Builds on covering lemmas from this cycle. Connects to `Computation/AutomaticDecidability.lean` in the catalog.

**Ambition**: extension

---

### Direction 5: Cognitive State Space Dimension and Period Forcing in Higher Dimensions

**Conjecture**: The Sharkovsky ordering is specific to one-dimensional dynamics. In dimension d ≥ 2, period-3 does NOT imply all periods for continuous maps f : ℝ^d → ℝ^d. Specifically, for every n ≥ 1, there exists a continuous map f : ℝ² → ℝ² with a period-3 orbit but no period-n orbit.

**Test**: Construct explicit continuous maps on ℝ² with period-3 orbits but missing specific other periods. The standard construction uses rotations composed with radial scaling: f(r,θ) = (g(r), θ + 2π/3) where g is chosen to have period 3 but not the target period. Verify computationally for n = 2, 5, 7.

**Impact**: This establishes a fundamental limitation of the cognitive dynamics model: the one-dimensional forcing theorems do NOT extend to realistic high-dimensional neural state spaces. This is scientifically important because it means the "déjà vu is inevitable" conclusion depends critically on the state space structure, not just on continuity and the existence of period-3 orbits. Higher-dimensional cognitive models may escape the period-forcing constraints.

**Catalog References**: `Computation/CognitiveDynamics.lean`, `Geometry/` catalog entries

**Proof Strategy**:
1. Construct the explicit counterexample in ℝ²
2. Prove it has a period-3 orbit (by direct computation)
3. Prove it lacks the target period (by analyzing the radial dynamics)
4. This is a negative result that clarifies the boundaries of the theory

**Domain Bridges**: Computation (dynamical systems) ↔ Geometry (topology of manifolds) ↔ Physics (dimensionality constraints)

**Lineage**: Builds on the one-dimensional results from this cycle, specifically identifying what breaks in higher dimensions.

**Ambition**: extension
