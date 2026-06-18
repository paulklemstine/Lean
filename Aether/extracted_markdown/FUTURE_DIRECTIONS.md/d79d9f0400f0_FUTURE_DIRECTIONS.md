# Future Research Directions: Tropical Recipe Complexity Theory

## Synthesis

This cycle established the algebraic foundations of recipe complexity theory, formally proving seventeen theorems connecting the creation-verification gap to tropical (max-plus) semiring structure. The central discovery is that the gap functional is exactly additive under sequential composition, subadditive under parallel composition, and linearly scaled under iteration — making it a well-behaved invariant of recipe algebra. The tropical distributive law for scheduling was proved, providing the algebraic foundation for critical path algorithms.

The strongest cross-domain connection is the bridge between **tropical algebra and computational complexity**. The pipeline throughput formula identifies the bottleneck time as a tropical eigenvalue (spectral radius), and the recipe complexity classes (Trivial, LinearGap, SuperlinearGap) provide an algebraic classification of computational problems by their creation-verification gap behavior. The existing catalog contains tropical infrastructure (`Catalog/Tropical/MaxPlusAlgebra.lean`, `Catalog/Tropical/ComplexityTransfer.lean`) and computation theory (`Catalog/Computation/InfoEfficientAlgorithms.lean`), and our recipe framework provides a concrete bridge between them.

The direction with the highest breakthrough potential is **Direction 1 (Tropical Spectral Complexity Hierarchy)**, which would formalize a hierarchy of computational hardness classes using tropical spectral radii. The gap refinement invariance theorem (Theorem 7.1) suggests that the gap is a topological invariant of computational tasks — it's preserved under refinement, much like how topological invariants are preserved under homeomorphism. If this analogy can be made precise, it would connect complexity theory to tropical topology in a novel way. **Direction 3 (Resource-Bounded Tropical Scheduling)** has the most immediate practical potential, connecting our algebraic framework to real-world scheduling with limited parallel resources.

---

### Direction 1: Tropical Spectral Complexity Hierarchy

**Conjecture**: For any recipe family F : ℕ → RecipeStep with linear gap growth (∃ c > 0, ∀ n, c·n ≤ gap(F(n))), the associated tropical matrix sequence M_F(n) has spectral radius ρ(M_F(n)) = Θ(gap(F(n))/n), and the complexity class of F is determined by the limit behavior of ρ(M_F(n)) as n → ∞. Specifically:
- Trivial gap ⟺ ρ(M_F(n)) → 0
- Linear gap ⟺ ρ(M_F(n)) → c > 0 (constant)
- Superlinear gap ⟺ ρ(M_F(n)) → ∞

**Test**: Construct explicit recipe families for each class (e.g., F_trivial(n) with createTime = n, verifyTime = n; F_linear(n) with createTime = 2n, verifyTime = n; F_super(n) with createTime = n², verifyTime = n). Compute the associated tropical matrices and verify that the spectral radii match the predicted behavior. If any class has spectral radius behavior contradicting the conjecture, the classification fails.

**Impact**: If true, this would provide the first algebraic characterization of complexity classes via tropical spectral theory. It would mean that determining computational hardness reduces to computing a tropical eigenvalue — a problem that is itself solvable in polynomial time for fixed matrix dimensions. This could yield new polynomial-time algorithms for classifying the difficulty of scheduling problems.

**Catalog References**: `Catalog/Tropical/MaxPlusAlgebra.lean`, `Catalog/Tropical/ComplexityTransfer.lean`, `Catalog/Tropical/SpectralTheory.lean`, `Catalog/Computation/InfoEfficientAlgorithms.lean`

**Proof Strategy**: 
1. Define the tropical matrix M_F(n) ∈ Max-Plus(ℕ^{n×n}) associated with a recipe family of size n, where entry (i,j) encodes the gap of the j-th subtask when preceded by the i-th subtask.
2. Prove that the critical path of the recipe network equals the maximum weight path in the associated directed graph, which equals the (1,n) entry of M_F(n)^n in the max-plus semiring.
3. Use the Cuninghame-Green theorem relating max-plus spectral radius to the maximum cycle mean in the associated graph.
4. Connect cycle mean behavior to asymptotic gap growth.

**Domain Bridges**: Algebra (tropical semiring) ↔ Computation (complexity classes) ↔ Graph Theory (maximum weight paths)

**Lineage**: Builds on `gap_iter_linear`, `iteration_family_linear_gap`, `pipeline_throughput_bound`, and the recipe complexity class definitions from this cycle.

**Ambition**: grand_challenge

---

### Direction 2: Gap Topology and Refinement Invariants

**Conjecture**: The creation-verification gap defines a topological invariant on the space of recipe networks. Specifically, define two recipe networks to be *refinement-equivalent* if one can be obtained from the other by splitting or merging sequential subtasks (preserving total creation and verification times). Then the gap is a complete invariant of refinement equivalence classes — two networks are refinement-equivalent if and only if they have the same total gap.

Moreover, the space of refinement equivalence classes, equipped with the gap metric d(R₁, R₂) = |gap(R₁) - gap(R₂)|, is isometric to (ℕ, |·|), and the composition operations (sequential and parallel) are continuous with respect to this topology.

**Test**: Find two recipe networks that have the same gap but are NOT refinement-equivalent (which would disprove the completeness claim), or prove that gap equality implies refinement equivalence (which would confirm it). A computational search over all recipe networks with ≤ 10 steps and total creation time ≤ 100 should be exhaustive.

**Impact**: If the gap is a complete refinement invariant, it would establish a deep connection between recipe complexity and topological invariant theory. The metric space structure would enable the application of topological data analysis techniques to complexity classification. If the completeness fails, the counterexample would reveal additional invariants beyond the gap.

**Catalog References**: `Catalog/Algebra/TropicalRecipeComplexity.lean` (gap_refinement_invariant), `Catalog/Tropical/Convexity.lean`

**Proof Strategy**:
1. Formalize refinement equivalence as an equivalence relation on recipe networks.
2. Prove that gap is invariant under refinement (already done: gap_refinement_invariant).
3. For completeness: show that any two networks with the same total creation time, total verification time, and hence the same gap, can be connected by a sequence of splits and merges.
4. The key lemma: any recipe step (c, v) can be split into two steps (c₁, v₁) and (c - c₁, v - v₁) for any c₁ ≤ c and v₁ ≤ min(c₁, v).

**Domain Bridges**: Algebra (recipe composition) ↔ Topology (invariant theory) ↔ Combinatorics (equivalence classes)

**Lineage**: Builds on `gap_refinement_invariant`, `gap_seq_additive`, and the RecipeStep definitions from this cycle.

**Ambition**: extension

---

### Direction 3: Resource-Bounded Tropical Scheduling

**Conjecture**: When parallel composition is limited to at most k simultaneous tasks (modeling k workers/processors), the creation-verification gap of the optimal k-bounded schedule satisfies:

gap_k(R) ≥ gap_∞(R) ≥ gap_k(R) - (k-1) · max_task_gap(R)

where gap_∞ is the unlimited-parallelism gap and max_task_gap is the maximum gap of any individual task. This means resource constraints can amplify the gap by at most a factor proportional to the number of workers.

**Test**: Construct recipe networks with n = 20 tasks and varying parallelism bounds k = 1, 2, 4, 8, 16, 20. Compute gap_k for each k and verify the conjectured inequality. The test should use both random networks and adversarial constructions (e.g., all tasks with the same gap, or one task with a huge gap and the rest with zero gap).

**Impact**: This would connect our algebraic framework to practical scheduling with limited resources — the regime relevant to real kitchens, factories, and computing clusters. The bound would provide a quantitative answer to "how much does limited parallelism hurt?" in terms of the gap structure. It would also connect to the theory of scheduling on parallel machines (P||C_max), a well-studied problem in operations research.

**Catalog References**: `Catalog/Computation/OptimalPlanning.lean`, `Catalog/Computation/InfoEfficientAlgorithms.lean`, `Catalog/Tropical/BellmanFord.lean`

**Proof Strategy**:
1. Define k-bounded parallel composition: par_k partitions tasks into groups of at most k, runs each group in parallel, and sequences the groups.
2. The optimal k-bounded schedule minimizes total time; its gap is gap_k(R).
3. Lower bound: gap_k ≥ gap_∞ because restricting parallelism can only increase creation time relative to verification time.
4. Upper bound: Use a greedy scheduling algorithm (longest-processing-time first) and analyze its gap.
5. The key lemma: any greedy schedule produces at most ⌈n/k⌉ parallel rounds, each with gap ≤ max_task_gap.

**Domain Bridges**: Algebra (tropical composition) ↔ Computation (scheduling theory) ↔ Operations Research (parallel machine scheduling)

**Lineage**: Builds on `gap_par_subadditive`, `critical_path_le_sequential`, `critical_path_ge_avg`, and `pipeline_throughput_bound` from this cycle.

**Ambition**: extension

---

### Direction 4: Tropical Proof Complexity

**Conjecture**: There exists a proof system where proof length corresponds to tropical circuit size, and proof verification corresponds to tropical evaluation. Specifically, define a *tropical proof* of a scheduling bound T for a recipe network R as a tropical circuit C such that C evaluates to T on the input durations. Then:

1. Every recipe network R with n tasks has a tropical proof of its critical path of size O(n).
2. There exist scheduling optimization problems (e.g., minimize makespan with precedence constraints and resource conflicts) whose optimal value requires tropical proofs of size Ω(n²).
3. The existence of short tropical proofs for a scheduling problem is equivalent to the problem being in a tropical analogue of NP.

**Test**: Construct explicit tropical circuits for critical path computation on DAGs with n = 10, 20, 50, 100 nodes. Measure circuit size as a function of n. Verify that the O(n) upper bound holds for DAGs, and search for precedence-constrained problems requiring larger circuits.

**Impact**: This would create a new bridge between proof complexity and tropical algebra. The tropical analogue of NP would be a novel complexity class with potentially different computational properties from classical NP. If the Ω(n²) lower bound holds, it would be one of the first superlinear lower bounds in a natural proof system.

**Catalog References**: `Catalog/Tropical/Circuits/`, `Catalog/Computation/CircuitComplexity/`, `Catalog/Algebra/AlgebraicCircuitComplexity.lean`, `Catalog/Algebra/GCT/Foundation.lean`

**Proof Strategy**:
1. Define tropical circuits as directed acyclic graphs with max and + gates.
2. Show that critical path computation on a DAG with n nodes reduces to a tropical circuit of size O(n + edges).
3. For the lower bound: use a communication complexity argument. Show that any tropical circuit computing the optimal makespan with resource conflicts must have a bottleneck gate that processes information from Ω(n) inputs.
4. Define the tropical NP class and prove basic closure properties.

**Domain Bridges**: Computation (proof complexity, circuit complexity) ↔ Algebra (tropical circuits) ↔ Combinatorics (DAG scheduling)

**Lineage**: Builds on `tropical_distributive_createTime`, `critical_path_le_sequential`, and the tropical scheduling framework. Connects to `circuit_lower_bound_from_obstruction` from `Algebra/GCT/Foundation.lean`.

**Ambition**: grand_challenge

---

### Direction 5: Verification Hardness Amplification

**Conjecture**: There exists a polynomial-time computable transformation T that takes a recipe step r with gap(r) = g and produces a recipe step T(r) with gap(T(r)) ≥ g² while preserving createTime(T(r)) ≤ createTime(r)³. In other words, the gap can be "amplified" quadratically with only cubic blowup in creation time.

If this amplification is possible, then iterating it O(log log n) times starting from a step with gap = 2 produces a step with gap ≥ 2^{2^{O(log log n)}} = n^{O(1)}, achieving polynomial gap from constant gap with polynomial blowup. This would imply that the recipe complexity classes {Trivial, Linear, Superlinear} do NOT form a strict hierarchy — any non-trivial gap can be amplified to superlinear.

**Test**: Search for explicit constructions of gap-amplifying transformations using:
1. Tensor products of recipe steps (creating verification challenges from multiple independent subtasks)
2. Iterative composition with feedback (using the output of verification as input to creation)
3. Cryptographic hardness assumptions (one-way functions provide natural gap amplification)

If no polynomial-time transformation achieves quadratic gap amplification, the conjecture is false, and the complexity class hierarchy is genuine.

**Impact**: If true, the recipe complexity hierarchy collapses: any problem with a non-trivial creation-verification gap has a polynomially related problem with superlinear gap. This would be analogous to (and potentially imply) the collapse of the polynomial hierarchy. If false, the strict hierarchy provides a new structural result in complexity theory.

**Catalog References**: `Catalog/Tropical/HardnessAmplification.lean`, `Catalog/Computation/HardnessRandomness/`, `Catalog/Cryptography/BerggrenFingerprintRigidity.lean`

**Proof Strategy**:
1. Define the tensor product r ⊗ s of recipe steps, where creation requires creating both r and s, but verification only requires verifying one (chosen adversarially).
2. Prove gap(r ⊗ s) ≥ gap(r) + gap(s) (or gap(r) · gap(s) under suitable definitions).
3. For the amplification: take T(r) = r ⊗ r (self-tensor product).
4. Analyze the blowup in creation time: createTime(r ⊗ r) ≤ 2 · createTime(r), so the polynomial blowup bound might be achievable.
5. The key challenge is defining "tensor product" of recipe steps so that verification only requires checking one component.

**Domain Bridges**: Computation (hardness amplification) ↔ Algebra (tensor products) ↔ Cryptography (one-way functions)

**Lineage**: Builds on `gap_seq_additive`, `iteration_family_linear_gap`, and the recipe complexity class definitions. Connects to `Catalog/Tropical/HardnessAmplification.lean` and `Catalog/Computation/HardnessRandomness/`.

**Ambition**: grand_challenge
