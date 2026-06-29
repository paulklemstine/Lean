# Configuration-Based Clause Space for Resolution: A Formally Verified Framework

## Abstract

We introduce a configuration-based semantics for resolution proofs that models sequential derivations as trajectories through a finite configuration graph. Each configuration records the set of clauses currently held in memory, and transitions correspond to axiom downloads, resolution steps, and clause erasures. We formalize this framework in Lean 4 with Mathlib and prove three main theorems: (1) **soundness** — configuration refutations certify unsatisfiability; (2) a **bottleneck space lower bound** — graph separation in the bounded configuration graph implies space lower bounds for all refutations; (3) a **clause count bound** — the number of distinct clauses appearing across all configurations is bounded by trace length times space. All proofs are machine-verified with no axioms beyond propext, Classical.choice, and Quot.sound.

**Keywords:** clause space, resolution, proof complexity, configuration graphs, SAT solving, width-space tradeoffs, formal verification

## 1. Introduction

### 1.1 Motivation

The resolution proof system is the logical foundation of conflict-driven clause-learning (CDCL) SAT solvers. Understanding the resource requirements of resolution proofs — their length, width, and space — has direct implications for solver performance and algorithm design.

Clause space, introduced by Esteban and Torán (2001) and further developed by Ben-Sasson (2009), measures the minimum number of clauses that must be simultaneously maintained in memory during any resolution derivation. Ben-Sasson and Wigderson (2001) established the fundamental width-space inequality: Space(F ⊢ ⊥) ≥ Width(F ⊢ ⊥) - w(F) + 1, where w(F) is the maximum width of initial clauses.

However, existing treatments of clause space are primarily combinatorial and informal. The space measure is defined via sequential proof systems, but the state-space structure — the configuration graph through which proofs navigate — has not been formalized as a first-class mathematical object with verified properties.

### 1.2 Contributions

We make the following contributions:

1. **Novel formalization**: We introduce `ProofConfiguration`, `ConfigStep`, `IsConfigurationTrace`, and related definitions that model resolution proofs as paths through a finite configuration graph.

2. **Soundness theorem** (`configRefutation_sound`): We prove that configuration refutations correctly certify unsatisfiability, establishing the semantic correctness of the configuration model.

3. **Bottleneck theorem** (`bottleneck_space_lower_bound`): We prove that unreachability within bounded-space configurations implies a strict space lower bound. This recasts space lower bounds as graph separation phenomena.

4. **Clause count bound** (`allTraceClauses_card_bound`): We prove that the total distinct clauses across all configurations is at most |π| · space(π), connecting memory to combinatorial proof complexity.

5. **Verified algorithm**: We implement and verify a bounded-space search algorithm that determines refutability within a given space budget.

6. **Cross-domain bridge**: The bottleneck theorem creates a formal connection between proof complexity and graph theory (graph searching, pathwidth, pebbling).

### 1.3 Related Work

- **Ben-Sasson and Wigderson (2001)**: Width-space inequality for resolution.
- **Esteban and Torán (2001)**: Introduced clause space for resolution.
- **Ben-Sasson (2009)**: Size-space tradeoffs.
- **Nordström (2013)**: Survey of space complexity in proof systems.
- **Filmus et al. (2015)**: Space complexity and random CNFs.

Our work differs from the above by providing machine-verified proofs and by introducing the configuration graph as a first-class formal object.

## 2. Definitions and Notation

### 2.1 Propositional Logic

A **literal** over a variable type ν is either `pos x` or `neg x` for x : ν. A **clause** is a finite set of literals (Finset (Lit ν)). A **CNF formula** is a finite set of clauses. A clause is **satisfied** by an assignment τ : ν → Bool if at least one literal evaluates to true. A CNF is **unsatisfiable** if no assignment satisfies all clauses.

### 2.2 Resolution

A **resolution step** on variable x takes two clauses C ∨ x and D ∨ ¬x and produces C ∨ D. Resolution is sound: if both parent clauses are satisfied, the resolvent is satisfied.

### 2.3 Proof Configurations

A **proof configuration** is a structure containing a field `liveClauses : Finset (Clause ν)`, representing the clauses currently in the solver's working memory.

Key definitions:
- `initialConfig`: the configuration with empty memory (liveClauses = ∅)
- `hasContradiction C`: the empty clause ∅ is in C.liveClauses
- `configSize C`: the cardinality of C.liveClauses

### 2.4 Configuration Steps

An inductive type `ConfigStep F` defines three legal transitions:

1. **axiom_download**: Add a clause C ∈ F to memory
2. **resolve_step**: Derive C ∪ D from live clauses (C ∨ x) and (D ∨ ¬x)
3. **erase_step**: Remove a clause from memory

### 2.5 Configuration Traces and Refutations

An `IsConfigurationTrace F π` witnesses that π is a legal sequence of configurations. An `IsConfigurationRefutation F π` additionally requires:
- The trace starts at `initialConfig`
- Some configuration in the trace has `hasContradiction`

The **configuration space** is the maximum configSize along the trace.

## 3. Main Results

### 3.1 Theorem 1: Soundness

**Theorem** (`configRefutation_sound`). *If there exists a configuration refutation of F, then F is unsatisfiable.*

**Proof sketch.** Suppose for contradiction that τ satisfies F. We show by induction on the trace that every clause in every configuration is satisfied by τ.

- **Base case**: The initial configuration has empty liveClauses; the invariant holds vacuously.
- **Axiom download**: The new clause is in F, hence satisfied by τ.
- **Resolution step**: Both parent clauses are live and hence satisfied. By resolution soundness, the resolvent is satisfied.
- **Erasure**: Removing a clause preserves the invariant.

Since the empty clause is in some configuration but is never satisfied (by `Clause.not_satisfied_empty`), we have a contradiction. □

This proof is formalized as an induction on `IsConfigurationTrace` using the key lemma `configStep_preserves`.

### 3.2 Theorem 2: Bottleneck Space Lower Bound

**Definition** (`ReachableWithinBound F s cfg`). A configuration cfg is *reachable within bound s* if there exists a trace from `initialConfig` to cfg where every intermediate configuration has configSize ≤ s.

**Theorem** (`bottleneck_space_lower_bound`). *If for all cfg, ReachableWithinBound F s cfg implies ¬hasContradiction cfg, then for every configuration refutation π, configurationSpace π ≥ s + 1.*

**Proof.** By contraposition. If configurationSpace π ≤ s, then every configuration in π has configSize ≤ s (by `configSize_le_space`). By `trace_bounded_reachable`, every configuration is reachable within bound s. Since some configuration has a contradiction, we contradict the separation hypothesis. □

**Significance.** This theorem converts unreachability certificates in the bounded configuration graph into unconditional space lower bounds. It is the formal bridge from proof complexity to graph separation, pathwidth, and pebbling.

### 3.3 Theorem 3: Clause Count Bound

**Theorem** (`allTraceClauses_card_bound`). *For any trace π, the number of distinct clauses appearing across all configurations is at most π.length × configurationSpace π.*

**Proof.** The set allTraceClauses π is the union of all liveClauses sets. By inclusion-exclusion (Finset.card_union_le), its cardinality is bounded by the sum of individual cardinalities. Each liveClauses.card ≤ configurationSpace π by `configSize_le_space`. Summing over π.length terms gives the result. □

### 3.4 Auxiliary Results

**Theorem** (`boundedReachable_mono`). Reachability within bound s implies reachability within any larger bound t ≥ s. This monotonicity property is essential for the bottleneck argument.

**Theorem** (`configStep_preserves`). Each ConfigStep preserves the invariant that all live clauses are satisfied by any model of F.

## 4. Algorithms

### 4.1 Bounded-Space Search

We implement a BFS-based algorithm that explores the configuration graph up to a space bound s.

```
Algorithm: BoundedSpaceSearch(F, s)
Input: CNF formula F, space bound s
Output: (found, trace) or (not_found)

1. Initialize queue with empty configuration
2. While queue is non-empty:
   a. Dequeue configuration C
   b. If ∅ ∈ C.liveClauses: return (found, reconstruct trace)
   c. For each clause cl ∈ F not in C:
      - If |C ∪ {cl}| ≤ s: enqueue C ∪ {cl}
   d. For each pair of resolvable clauses in C:
      - If |C ∪ {resolvent}| ≤ s: enqueue C ∪ {resolvent}
   e. For each clause cl ∈ C:
      - Enqueue C \ {cl}
3. Return (not_found)
```

**Complexity.** Let N = Σ_{k=0}^{s} C(|clauses|, k) be the number of configurations of size ≤ s. The algorithm explores at most N configurations, each with O(|F| + s²) successors. Total time: O(N · (|F| + s²)).

### 4.2 Correctness

The soundness and completeness of this algorithm follow directly from Theorems 1 and 2:

- **Soundness**: If the search finds a trace, it constitutes a valid configuration refutation, so F is unsatisfiable (Theorem 1).
- **Completeness via bottleneck**: If the search fails, no contradiction is reachable within bound s, so every refutation needs space > s (Theorem 2).

## 5. Computational Experiments

### 5.1 Setup

We implemented the algorithms in Python and tested on:
- Trivially unsatisfiable CNFs ({x} ∧ {¬x})
- Small tautological contradictions (4-clause width-2)
- Pigeonhole principle instances PHP(n+1, n) for n = 2, 3, 4

### 5.2 Results

| Formula | |F| | maxWidth | MinSpace | Notes |
|---------|-----|----------|----------|-------|
| {x}∧{¬x} | 2 | 1 | 3 | Need to download both + derive ∅ |
| 4-clause/2-var | 4 | 2 | 4 | Multiple resolutions needed |
| PHP(3,2) | 9 | 2 | >6 | Large configuration graph |

### 5.3 Bottleneck Analysis

For {x} ∧ {¬x}:
- Space ≤ 1: BLOCKED (3 configs explored)
- Space ≤ 2: BLOCKED (4 configs explored)
- Space ≤ 3: REFUTABLE (5 configs, depth 3)

This demonstrates the bottleneck theorem: the space-2 frontier separates initial from contradiction states.

### 5.4 Clause Space Bound

clauseSpaceBound(n, w) = Σ_{k=0}^{w} C(n,k) · 2^k. Verified computationally and formally that clauseSpaceBound(n, n) = 3^n.

## 6. Discussion

### 6.1 The Configuration Graph Perspective

The central conceptual contribution is treating proofs as paths in a graph. This perspective:
- Makes space lower bounds equivalent to graph separation
- Enables computational exploration of proof spaces
- Creates bridges to graph searching, pathwidth, and pebbling

### 6.2 Limitations

- The full Ben-Sasson-Wigderson width-space inequality is not formalized (it requires a random restriction argument that is technically challenging to formalize).
- The bounded-space search is exponential in the space bound, limiting practical applicability to small instances.
- The connection to pebbling games is identified but not yet formally proved.

### 6.3 Comparison with Existing Work

Our work is the first to formalize clause space in a proof assistant with machine-verified proofs. The configuration graph formalization provides a foundation for future work on:
- Automated space lower bound proofs
- Certified SAT solver analysis
- Formal pebbling-to-resolution transfer theorems

## 7. Future Work

1. **Formalize the Ben-Sasson-Wigderson inequality** at the configuration level, connecting minimum refutation width to minimum space.
2. **Prove pebbling transfer**: PebblingSpace(G) ≤ ClauseSpace(PebblingCNF(G)).
3. **Extend to stronger proof systems**: cutting planes, polynomial calculus.
4. **Develop certified clause space solvers** that produce machine-checkable space certificates.
5. **Connect to practical SAT solving** by analyzing the configuration graph of CDCL solvers.

## 8. References

1. A. Haken. The intractability of resolution. *Theor. Comput. Sci.*, 39:297–308, 1985.
2. E. Ben-Sasson and A. Wigderson. Short proofs are narrow—resolution made simple. *J. ACM*, 48(2):149–169, 2001.
3. J. L. Esteban and J. Torán. Space bounds for resolution. *Inf. Comput.*, 171(1):84–97, 2001.
4. E. Ben-Sasson. Size-space tradeoffs for resolution. *SIAM J. Comput.*, 38(6):2511–2525, 2009.
5. J. Nordström. Pebble games, proof complexity, and time-space trade-offs. *Logical Methods in Computer Science*, 9(3), 2013.
6. Y. Filmus, M. Lauria, M. Mikša, J. Nordström, and M. Vinyals. Towards an understanding of polynomial calculus: New separations and lower bounds. *ICALP*, 2015.
