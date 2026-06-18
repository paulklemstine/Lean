# Future Directions: Conceptual Dependency Critical Path Theory

## Overview

The formalization of conceptual depth as a graph invariant on dependency DAGs opens several concrete research frontiers. Each direction below specifies target theorems, proof strategies, and cross-domain connections.

---

## Direction 1: Weighted Conceptual Depth and Novelty Costs

**Goal**: Generalize uniform-depth to weighted depth, where each node carries a "conceptual novelty" weight `w : V → ℕ`. The weighted depth of a path is the sum of weights along it, and the weighted critical path bounds weighted discovery complexity.

**Target theorem**:
```
theorem weightedDepth_le_of_discoverable
  (G : DepGraph V) (w : V → ℕ)
  (S : Finset V) (hS : ∀ v ∈ S, G.isSource v) :
  ∀ {n v}, v ∈ weightedDiscovered G w S n → weightedDepth G w v ≤ n
```

**Why it matters**: Uniform depth treats a routine lemma and a paradigm-shifting insight equally. Weighted depth would distinguish:
- Long-but-routine dependency chains (low total weight)
- Short-but-revolutionary conceptual jumps (high total weight)

This enables quantitative measurement of "conceptual breakthroughs" versus "incremental work."

**Proof strategy**: Define `weightedDepth` by well-founded recursion where `weightedDepth G w v = w v + sup(weightedDepth of predecessors)` for non-sources. The discovery process uses `weightedDiscovered` where round `n` expands nodes whose weighted prerequisites sum to at most `n`. The lower bound proof follows the same inductive structure as the unweighted case.

**Cross-domain connections**: Operations research (weighted CPM/PERT), proof complexity (weighted formula depth), machine learning curriculum design with difficulty scores.

---

## Direction 2: Categorical/Functorial Transfer of Dependency Depth

**Goal**: Define a morphism between dependency graphs (a functor between the corresponding partial orders) and prove that depth is preserved or bounded under structure-preserving maps.

**Target theorem**:
```
theorem depth_le_of_graph_morphism
  (G₁ : DepGraph V₁) (G₂ : DepGraph V₂)
  (f : V₁ → V₂) (hf : ∀ u v, u ∈ G₁.pred v → f u ∈ G₂.pred (f v)) :
  ∀ v, G₁.depth v ≤ G₂.depth (f v)
```

**Why it matters**: This would enable *transfer theorems* — proving that if theory A embeds into theory B preserving dependency structure, then the conceptual depth of results in A is a lower bound for their images in B. This could formalize why certain mathematical translations (e.g., algebraization of topology) cannot simplify the conceptual landscape.

**Proof strategy**: Induction on `G₁.wf`. The morphism condition ensures that predecessors map to predecessors, so the depth inequality follows from the sup characterization.

**Cross-domain connections**: Category theory, model theory (interpretations between theories), algebraic topology (functorial invariants).

---

## Direction 3: Empirical Critical Path Extraction from Mathlib

**Goal**: Build a meta-programming tool that extracts the dependency graph of declarations in a Mathlib module and computes critical paths.

**Concrete deliverable**:
- A Lean 4 metaprogram that, given a declaration name, traverses `Expr.getUsedConstants` to build `depOf : Name → Finset Name`.
- Computation of `depth` and `criticalPathLength` for selected Mathlib subgraphs.
- Identification of "bottleneck theorems" — declarations that lie on every long path.

**Target analysis**:
- Compare critical path lengths across Mathlib domains (algebra, analysis, topology, combinatorics).
- Identify the "deepest" theorems in each domain.
- Measure how much of the total dependency depth is concentrated in a small number of bottleneck lemmas.

**Why it matters**: This converts the abstract theory into a practical tool for:
- Library refactoring (identifying unnecessary dependencies)
- Curriculum design (optimal ordering of prerequisites)
- Proof search guidance (prioritizing lemmas on critical paths)

---

## Direction 4: Lower Bounds Under Branching-Factor Constraints

**Goal**: Prove that if exploration is additionally constrained by a branching factor (each round discovers at most `b` new nodes), then discovery requires at least `⌈|V|/b⌉` rounds regardless of dependency structure.

**Target theorem**:
```
theorem rounds_ge_card_div_branching
  (G : DepGraph V) (S : Finset V) (b : ℕ) (hb : 0 < b)
  (bounded_discovery : ∀ n, (bounded_discovered G S b (n+1) \ bounded_discovered G S b n).card ≤ b) :
  ∀ v, v ∈ bounded_discovered G S b n → n ≥ (Fintype.card V - S.card) / b
```

**Why it matters**: Real research programs have finite bandwidth — a team can only absorb a bounded number of new concepts per unit time. This theorem shows that bandwidth limitations compound with dependency depth to create even stronger lower bounds on discovery time.

**Proof strategy**: Counting argument. If each round adds at most `b` nodes, then after `n` rounds at most `|S| + nb` nodes are discovered. If all `|V|` nodes must be discovered, `n ≥ (|V| - |S|) / b`.

**Cross-domain connections**: Parallel computing (BSP model), communication complexity, project management (resource-constrained scheduling).

---

## Direction 5: Comparison with Human Textbook Dependency Structure

**Goal**: Formalize a comparison framework between the machine-extracted dependency graph and human-authored textbook prerequisite orderings.

**Concrete approach**:
1. Define a "textbook ordering" as a total order on theorems compatible with dependency (a topological sort).
2. Define "textbook depth" as the chapter/section number assigned to each theorem.
3. Prove that textbook depth is always an upper bound on graph-theoretic depth:
   ```
   theorem textbook_depth_ge_graph_depth
     (G : DepGraph V) (σ : V → ℕ) (hσ : ∀ u v, u ∈ G.pred v → σ u < σ v) :
     ∀ v, G.depth v ≤ σ v
   ```
4. Measure the *gap* between textbook depth and graph depth empirically.

**Why it matters**: A large gap indicates "unnecessary serialization" — the textbook introduces concepts in a longer chain than the mathematical dependencies require. This could guide:
- Textbook optimization
- Personalized learning paths
- Identification of "shortcut theorems" that collapse long textbook sequences

**Cross-domain connections**: Educational psychology (zone of proximal development), knowledge space theory (Doignon & Falmagne), learning analytics.

---

## Research Team Organization

Each direction can be pursued semi-independently:

| Direction | Prerequisites | Estimated Effort | Priority |
|-----------|--------------|------------------|----------|
| 1. Weighted depth | Current formalization | Medium | High |
| 2. Functorial transfer | Direction 1 optional | Medium | Medium |
| 3. Empirical extraction | Lean 4 metaprogramming | High | High |
| 4. Branching bounds | Current formalization | Low | Medium |
| 5. Textbook comparison | Direction 3 | Medium | High |

Directions 1 and 4 can proceed immediately in parallel. Direction 3 should start concurrently as it provides the empirical backbone. Directions 2 and 5 build on earlier results.

---

## Long-Term Vision

The ultimate goal is a **certified metamathematical complexity theory** where:
- Every formal theorem has a computable "conceptual depth" score.
- Research programs can be analyzed for their critical path structure.
- AI theorem provers can use depth-aware search strategies.
- Library architects can identify and resolve conceptual bottlenecks.

This creates a new bridge between proof theory, operations research, and AI — one grounded in machine-verified mathematics rather than informal analogy.
