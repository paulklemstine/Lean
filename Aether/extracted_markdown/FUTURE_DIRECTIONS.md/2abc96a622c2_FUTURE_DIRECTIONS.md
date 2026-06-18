# Future Directions: Metamathematical Complexity Theory for Formalized Mathematics

This document outlines concrete breakthrough research opportunities opened by the formalization of conceptual dependency critical path theory.

---

## 1. Weighted Conceptual Depth and Novelty Costs

**Status:** Definition sketched in current formalization; theorems unproven.

**Goal:** Extend the unweighted critical path theory to weighted DAGs where each node carries a "conceptual novelty cost" `w(v) ≥ 1`. The weighted depth of a node is the maximum sum of weights along any directed path ending at that node. This distinguishes long-but-routine proof chains from short-but-revolutionary conceptual jumps.

**Key theorem targets:**
- `weightedDepth_le_of_discoverableIn`: Weighted analogue of Theorem A1, proving that weighted discovery rounds lower-bound weighted depth.
- `weighted_separation`: There exist nodes unreachable by any exploration with weighted budget below the weighted critical path length.
- `weight_one_recovers_unweighted`: When all weights are 1, weighted depth equals unweighted depth.

**Proof strategy:** Define weighted discovery rounds where each round consumes weight proportional to the nodes being discovered. The lower bound proof proceeds by weighted induction on discovery round number.

**Why it matters:** This is the key to distinguishing "deep but routine" (long chains of incremental lemmas) from "shallow but revolutionary" (a single conceptual leap that restructures the field). Weighted depth is the right complexity measure for AI-guided research.

---

## 2. Categorical/Functorial Transfer of Dependency Depth Across Theories

**Goal:** When a functor F : C → D maps one mathematical theory to another (e.g., algebraization of topology, or tropicalization), how does conceptual depth transform? Prove that certain functors preserve or collapse depth, while faithful functors can only increase it.

**Key theorem targets:**
- `depth_monotone_under_faithful_functor`: If F is faithful and maps the dependency structure of C into D, then depth in D is at least depth in C.
- `depth_collapse_under_adjunction`: Left adjoints can collapse depth (analogous to how algebraization can simplify topological arguments).
- `Morita_invariance_of_critical_path`: Morita-equivalent categories have the same critical path length.

**Proof strategy:** Define a morphism of DepGraphs (a graph homomorphism preserving the predecessor relation) and prove depth monotonicity for injective morphisms.

**Why it matters:** This would formalize why some translations between mathematical fields (e.g., algebraic geometry ↔ commutative algebra) can make deep theorems shallow, and vice versa. It connects to the philosophy of "the right framework" for a problem.

---

## 3. Empirical Extraction of Critical Paths from Mathlib

**Goal:** Build a meta-programming tool that extracts the actual dependency DAG from Mathlib declarations and computes critical paths. Identify the "deepest" theorems in Mathlib and the conceptual bottleneck chains leading to them.

**Key deliverables:**
- A Lean 4 metaprogram that, given a declaration name, recursively extracts all constant dependencies and builds a `DepGraph` instance.
- Computation of `depth` and `criticalPathLength` for selected Mathlib subgraphs (e.g., the proof of the fundamental theorem of algebra, or Sylow's theorems).
- Comparison of formal dependency depth with textbook chapter depth.

**Technical approach:**
```
-- Pseudocode for extraction
meta def extractDeps (n : Name) : MetaM (Finset Name) :=
  get all constants referenced in the type and proof of n,
  filter to only Mathlib declarations (not kernel/Lean builtins),
  return as a Finset
```

**Why it matters:** This bridges the abstract theory to concrete mathematical practice. It would enable automated curriculum extraction — given a target theorem, compute the minimum prerequisite chain and generate a study plan.

---

## 4. Lower Bounds for Discovery Under Branching-Factor Constraints

**Goal:** Extend the critical path theory to model resource-bounded exploration where each round can discover at most `b` new nodes (branching factor constraint). Prove that under branching constraints, the discovery time can be strictly larger than the critical path length.

**Key theorem targets:**
- `branching_bounded_discovery_time_lower_bound`: If the DAG has a layer with more than `b` nodes, discovery takes at least `⌈layer_size / b⌉` extra rounds for that layer.
- `optimal_branching_schedule`: Characterize the optimal discovery schedule under branching constraints as a solution to a scheduling problem.
- `NP_hardness_of_optimal_schedule`: Under suitable encoding, finding the optimal discovery schedule with branching constraints is NP-hard (formalized as a reduction).

**Proof strategy:** Pigeonhole argument — if a layer has `L` nodes and we can discover at most `b` per round, we need at least `⌈L/b⌉` rounds for that layer alone.

**Why it matters:** This models the real constraint that AI theorem provers have bounded computational resources per step. The critical path gives a lower bound assuming unlimited parallelism; branching constraints give tighter bounds reflecting actual compute limitations.

---

## 5. Probabilistic and Information-Theoretic Models of Mathematical Discovery

**Goal:** Define a probabilistic discovery model where each node has a probability of being "discovered" given its prerequisites, and prove concentration inequalities for the discovery time around the critical path length.

**Key theorem targets:**
- `expected_discovery_time_ge_critical_path`: The expected number of rounds to discover all nodes is at least the critical path length.
- `concentration_around_critical_path`: Under independence assumptions, the discovery time concentrates around the critical path length with sub-Gaussian tails.
- `information_bottleneck_theorem`: The mutual information between the seed set and a deep target is bounded by the sum of channel capacities along the critical path.

**Proof strategy:** Model discovery as a stochastic process on the DAG. Use martingale arguments and Azuma-Hoeffding to prove concentration.

**Why it matters:** This connects conceptual depth to information theory, providing a rigorous framework for understanding why some mathematical insights are "surprising" — they require passing through information bottlenecks. It also connects to the theory of algorithmic information (Kolmogorov complexity) and could yield a formal definition of "mathematical creativity" as the ability to cross information bottlenecks efficiently.

---

## Cross-Cutting Themes

All five directions share a common vision: **metamathematical complexity theory** — the systematic study of what makes some mathematics intrinsically harder than other mathematics, not because of proof length or logical complexity, but because of the *structure of conceptual dependencies*.

The unifying insight is that mathematical knowledge has a geometric structure (the dependency DAG), and this geometry imposes fundamental limits on how quickly any agent — human or artificial — can traverse it. The critical path is the central invariant of this geometry.

### Connections to Existing Fields
- **Operations research:** Critical path method (CPM/PERT) for project scheduling
- **Circuit complexity:** Depth lower bounds for Boolean circuits
- **Category theory:** Functorial invariants of compositional structure
- **Information theory:** Channel capacity and bottleneck theorems
- **AI/ML:** Curriculum learning and knowledge graph navigation

### Impact on AI for Mathematics
The most immediate practical impact is on AI-guided theorem proving. Current systems search for proofs in a relatively undirected way. The critical path theory suggests a principled alternative: identify conceptual bottlenecks, acquire prerequisite understanding in the right order, and allocate computational resources proportional to conceptual depth. This is the mathematical formalization of "you need to learn to walk before you can run."
