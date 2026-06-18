# Future Directions: Research Ordinal Depth

## Team Directive

Create a team to conduct research, brainstorm hypotheses, run experiments, validate data, update knowledge base and iterate forever. Each future direction below is specific enough for a team to pick up and pursue with clear hypotheses, proof strategies, and cross-domain connections.

---

## 1. Ordinal Collapse Thresholds for Oracle Research

**Conjecture**: For every bounded-branching oracle strategy class with branching factor `k`, there exists a least ordinal `β(k)` such that every realized research object with branching bound `k` has `researchDepth < β(k)`.

**Precise Statement**: Define a family of research objects `R(k, n)` parameterized by branching factor `k` and height `n`. Then:
- For each `k`, the set `{ researchDepth(A) | BranchingBound k A ∧ HeightBound n A, n ∈ ℕ }` is bounded by `ω` (the first infinite ordinal).
- For unbounded branching with fixed height, the supremum of achievable depths equals `ω · (n+1)`.
- Characterize `β(k)` as a function of the branching bound.

**Test**: 
1. Formalize strategy classes for small `k = 1, 2, 3`.
2. Compute candidate upper bounds using the `natDepth_height_bound` theorem.
3. Either prove uniform boundedness or construct families that approach the bound.
4. Connect to `query_strategy_output_bound`: does the 2^k output bound from oracle complexity translate to a tighter ordinal bound?

**Proof Strategy**: Use the `natDepth_eq_researchDepth` theorem to reduce ordinal questions to computable natural-number bounds. The key insight is that for finitely branching objects, all depths are natural numbers, so `β(k)` should be `ω` for any finite `k`.

**Cross-Domain Connections**: 
- Query complexity (oracle branching → depth bounds)
- Kolmogorov complexity (description length → depth bounds)
- Ramsey theory (unavoidable depth patterns in large enough structures)

---

## 2. Strict Depth Growth Under Iterated Bootstrap

**Conjecture**: If `A` is any research object with positive depth, then the sequence `n ↦ researchDepth(bootstrapIter n A)` is strictly increasing for all `n`, and the depth grows exactly linearly: `researchDepth(bootstrapIter n A) = researchDepth(A) + n`.

**Status**: PROVED in the current development (`bootstrapIter_depth` and `bootstrapIter_strict_increasing`).

**Extended Conjecture**: Define a *generalized bootstrap* operator `gboot(f, A)` where `f` is a monotone function on research objects (not just the successor-taking `bootstrap`). Then:
- If `f` is non-idempotent in the sense of `DynamicalProofComplexity`, the sequence `n ↦ researchDepth(f^[n](A))` is strictly increasing.
- The growth rate of depth under `f` characterizes the "acceleration" of `f` as a research operator.
- Classify bootstrap operators by their ordinal growth rate: constant additive = linear research, multiplicative = polynomial research, exponential = super-polynomial research.

**Test**: 
1. Define `gboot` as a structure with a `ResearchObject → ResearchObject` field satisfying monotonicity.
2. Prove strict growth for the standard bootstrap (already done).
3. Define composition-bootstrap: `compBoot(A) = compose(A, A)`, which doubles depth. Prove depth grows as `2^n · d₀`.
4. Search for a bootstrap operator with super-exponential growth.
5. Connect to `nontrivial_depth_one_implies_not_idempotent`: prove that any depth-preserving operator must be idempotent.

**Cross-Domain Connections**:
- Dynamical systems (Lyapunov exponents as ordinal growth rates)
- Fixed-point theory (non-idempotence ↔ non-trivial dynamics)
- Self-referential systems (Gödel numbering as a bootstrap operation)

---

## 3. Holographic Bound on Proof Corpora

**Conjecture**: For dependency graphs with separator size at most `s` (in the graph-theoretic sense), the research depth is bounded by a function polynomial in `s`, independent of total node count.

**Precise Statement**: Define the *separator size* `sep(A)` of a research object as the minimum number of nodes whose removal disconnects the dependency graph into components of size at most half the original. Then:
- `natDepth(A) ≤ C · sep(A)^2` for some universal constant `C`.
- This is an "area law" for proof depth: the depth is controlled by the boundary (separator), not the bulk (total nodes).

**Test**:
1. Formalize graph separators for `ResearchObject` dependency graphs.
2. Compute `natDepth` and `sep` on example families: linear chains, binary trees, grid graphs.
3. For linear chains: `sep = 1`, `depth = n` — this violates the conjecture! So the conjecture needs refinement.
4. Refined conjecture: for *oracle-node-dominated* objects (where compose nodes are negligible), `natDepth ≤ C · sep + 1`.
5. Prove or refute the refined conjecture.
6. Connect to `area_law_proof` from HolographicProofs: does the `sqrt(n) ≤ n` bound suggest an analogy?

**Cross-Domain Connections**:
- Quantum information (area law for entanglement entropy)
- Graph theory (tree-width and separator theorems)
- Proof complexity (proof length vs. proof depth)

---

## 4. Completeness of Natural Approximation for Extended Objects

**Conjecture**: For finitely branching, finite-height research objects, `(natDepth A : Ordinal) = researchDepth A`.

**Status**: PROVED in the current development (`natDepth_eq_researchDepth`).

**Extended Conjecture**: Define an *extended research object* type that allows countably infinite branching (oracle nodes with `ℕ → ResearchObject` dependencies instead of `Fin arity → ResearchObject`). Then:
- The ordinal depth can exceed `ω` (the first infinite ordinal).
- The natural-number approximation `natDepth` is no longer sound for extended objects.
- Define a *transfinite depth* `transDepth : ExtResearchObject → Ordinal` that handles infinite branching.
- Prove that `transDepth` restricted to finite objects equals `natDepth`.

**Test**:
1. Define `ExtResearchObject` with `ℕ`-indexed oracle nodes.
2. Construct an extended object with `transDepth = ω`: the oracle node `oracleNode(ℕ, fun n => bootstrapIter n (atom 0))` should have depth `sup { n + 1 | n ∈ ℕ } = ω`.
3. Prove `transDepth` is well-defined using ordinal arithmetic.
4. Prove the restriction theorem.
5. Explore: does `transDepth` of doubly-nested infinite oracle nodes reach `ω²`?

**Cross-Domain Connections**:
- Set theory (ordinal arithmetic, countable ordinals)
- Proof theory (proof-theoretic ordinals of arithmetic)
- Computability theory (the arithmetical hierarchy corresponds to finite ordinal levels)

---

## 5. Depth-Guided ATP Heuristic Validity

**Conjecture**: In a formal proof search model, prioritizing goals by maximal predicted ordinal-depth gain strictly improves theorem discovery efficiency over breadth-first search on a benchmark family.

**Precise Formulation**: Define a proof search model as a tree where:
- Nodes are proof states (sets of unproved goals).
- Edges are tactic applications.
- Each tactic application transforms a proof state by resolving one goal and potentially creating new ones.
- The *depth gain* of a tactic is the increase in `natDepth` of the associated research object.

Then the *depth-first-by-depth-gain* (DFDG) strategy, which always expands the tactic with maximum depth gain, discovers proofs in fewer expansions than breadth-first search for a class of structured problems.

**Test**:
1. Implement a proof search simulator in Python using the `ResearchObject` framework.
2. Define a benchmark family: chains of lemmas with branching structure.
3. Run BFS vs. DFDG on 100 randomly generated proof problems.
4. Measure: number of node expansions, wall-clock time, proof length.
5. Statistical test: paired t-test or Wilcoxon signed-rank on expansion counts.

**Cross-Domain Connections**:
- Automated theorem proving (A* search with depth as heuristic)
- Machine learning (depth as a reward signal for reinforcement learning)
- Information theory (depth gain as information content of a proof step)
- Program synthesis (depth-guided search for correct programs)

---

## 6. Compositional Depth Algebras

**Conjecture**: The depth function `researchDepth` defines a homomorphism from the free algebra of research objects to the ordinal numbers under addition and successor.

**Precise Statement**: Define the *depth algebra* as the triple `(Ordinal, +, succ)`. Then:
- `researchDepth` is a surjection from `ResearchObject` to `ℕ ⊂ Ordinal`.
- The kernel of `researchDepth` (objects with the same depth) forms a congruence.
- The quotient `ResearchObject / ≡_depth` is isomorphic to `(ℕ, +, succ, max)`.
- This algebraic structure can be extended to a semiring or lattice.

**Test**:
1. Formalize the equivalence relation `A ≡ B ↔ researchDepth A = researchDepth B`.
2. Prove that `≡` is a congruence for `compose` (already follows from additivity).
3. Prove that `≡` is a congruence for `bootstrap` (follows from successor being injective).
4. Characterize the quotient algebra explicitly.
5. Explore: is there a natural multiplication on research objects that makes the quotient a semiring?

**Cross-Domain Connections**:
- Universal algebra (quotient algebras, congruences)
- Category theory (functorial properties of depth)
- Type theory (graded type systems indexed by ordinals)
