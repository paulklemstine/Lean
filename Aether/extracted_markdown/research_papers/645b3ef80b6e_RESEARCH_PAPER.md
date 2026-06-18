# Certified Clause-Space Certificates for Propositional Refutations

## Abstract

We develop a formally verified theory of **clause-space certificates** for propositional resolution refutations. A space certificate is a finite, self-verifying witness that a CNF formula is unsatisfiable within a prescribed clause-space bound *s*. We model bounded-memory proof search as a finite transition system over clause configurations and establish five main results:

1. **Soundness**: checked certificates imply unsatisfiability (Theorem 1).
2. **Completeness**: every bounded-space refutation yields a valid certificate (Theorem 2).
3. **Space monotonicity**: refutability is monotone in the space parameter (Theorem 3).
4. **Ternary injection**: consistent clauses embed injectively into ternary vectors (Theorem 4).
5. **Counting bound**: the number of consistent clauses over *n* variables is at most 3^n (Theorem 5).

All results are machine-checked with complete proofs, using no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`. The framework provides an executable certificate checker and a verified connection between proof complexity (clause space) and finite-state reachability.

**Keywords:** SAT solving, proof complexity, clause space, resolution, certified algorithms, finite-state reachability, space certificates.

---

## 1. Introduction

### 1.1 Motivation

Modern SAT solvers are central to hardware verification, planning, cryptanalysis, and combinatorial optimization. When a solver declares a formula unsatisfiable, it can produce a *proof certificate*—typically in DRAT format [Wetzler et al. 2014]—that an independent checker can verify.

DRAT certificates measure **proof length**: the number of clause introductions and deletions. However, a complementary and practically critical resource is **clause space**: the maximum number of clauses held in memory simultaneously during the refutation. Memory is often the binding constraint in practice; a solver may run out of RAM long before it exhausts time.

**Clause space** was introduced as a proof complexity measure by Esteban and Torán [2001] and has since been studied extensively [Ben-Sasson 2009, Nordström 2013]. Key results include:
- Space lower bounds for random k-CNFs and Tseitin formulas.
- Relationships between space, width, and proof length.
- The space complexity of resolution vs. stronger proof systems.

Despite this rich theory, no prior work has formalized a **certificate semantics** for clause space: a finite, checkable witness whose existence is equivalent to bounded-space refutability.

### 1.2 Contributions

We introduce a new mathematical object—the **space certificate**—that fills this gap. Our contributions are:

1. **Definitions.** We define clause-space configurations, a transition system modeling download/resolve/erase operations, and space certificates as finite traces in this system (§2).

2. **Soundness and completeness theorems.** We prove that the executable certificate checker is both sound (checked certificates imply unsatisfiability) and complete (every abstract bounded-space refutation produces a valid certificate) (§3).

3. **Monotonicity.** We prove that refutability is monotone in the space parameter, connecting to resource semantics in complexity theory (§3.3).

4. **Combinatorial bounds.** We establish an injective encoding of consistent clauses into ternary vectors, yielding the bound |clauses| ≤ 3^n, and bounding the configuration search space (§4).

5. **Machine-checked proofs.** All results are formalized with complete, sorry-free proofs (§5).

### 1.3 Related Work

**DRAT certificates** [Wetzler et al. 2014, Heule et al. 2017] are the standard proof format for SAT solvers. They certify unsatisfiability but do not bound memory usage.

**Clause space complexity** [Esteban & Torán 2001, Ben-Sasson 2009, Nordström 2013] is a well-studied proof complexity measure, but prior work focuses on lower bounds and complexity-theoretic relationships rather than certificate semantics.

**Formalized SAT** [Lammich 2020, Fleury et al. 2019] includes verified SAT solvers and DRAT checkers, but does not address space-bounded certificates.

---

## 2. Definitions and Notation

### 2.1 Propositional Logic

Let `Var` be a finite type of propositional variables.

**Definition 1** (Literal, Clause, CNF).
- A *literal* is a pair `(v, b) ∈ Var × Bool`, where `b = true` denotes positive polarity.
- A *clause* `c` is a finite set of literals: `c : Finset (Var × Bool)`.
- A *CNF formula* `F` is a finite set of clauses: `F : Finset (Finset (Var × Bool))`.

**Definition 2** (Satisfaction).
An assignment `τ : Var → Bool` *satisfies* a clause `c` if there exists `(v, b) ∈ c` with `τ(v) = b`.

**Definition 3** (Satisfiability).
A CNF `F` is *satisfiable* if there exists `τ` satisfying every clause in `F`.

**Definition 4** (Entailment).
A clause `c` is *entailed* by `F` if every assignment satisfying all clauses of `F` also satisfies `c`.

**Definition 5** (Resolution).
The *resolvent* of clauses `c₁, c₂` on variable `v` is:
```
resolve(c₁, c₂, v) = (c₁ \ {(v, true)}) ∪ (c₂ \ {(v, false)})
```
Resolution requires `(v, true) ∈ c₁` and `(v, false) ∈ c₂`.

### 2.2 Space-Bounded Proof System

**Definition 6** (Space Step).
Given a CNF `F`, a *space step* from memory configuration `mem` to `mem'` is one of:
- **Download**: `mem' = mem ∪ {c}` for some `c ∈ F`.
- **Resolve**: `mem' = mem ∪ {resolve(c₁, c₂, v)}` for `c₁, c₂ ∈ mem`.
- **Erase**: `mem' = mem \ {c}` for some `c ∈ mem`.

**Definition 7** (Space Reachability).
A configuration `mem` is *space-s-reachable* from `F` if there exists a finite sequence of space steps from `∅` to `mem`, with every intermediate configuration having cardinality ≤ s.

**Definition 8** (Clause-Space Refutability).
`F` is *clause-space refutable in space s* if there exists a space-s-reachable configuration containing the empty clause `∅`.

### 2.3 Executable Certificates

**Definition 9** (Step Action).
A step action is an annotated instruction:
- `download(c)`: load clause `c`.
- `resolve(c₁, c₂, v)`: resolve `c₁` and `c₂` on `v`.
- `erase(c)`: remove clause `c`.

**Definition 10** (Space Certificate).
A *space certificate* is a list of step actions.

**Definition 11** (Certificate Checker).
The checker `certificateChecks(F, s, cert)` runs the actions from empty memory, checking at each step that:
1. The action is valid (clause membership, resolution prerequisites).
2. The resulting configuration has cardinality ≤ s.

It returns `true` iff the final configuration contains the empty clause.

---

## 3. Main Results

### 3.1 Theorem 1: Soundness of Space Certificates

**Theorem** (Soundness). *For every CNF `F` and bound `s`, if there exists a space certificate accepted by the checker, then `F` is unsatisfiable.*

```
spaceCertificate_sound : (∃ C, certificateChecks F s C = true) → ¬ satisfiable F
```

**Proof sketch.** The proof proceeds in two stages:

*Stage 1: Semantic invariant.* We prove by induction on the space-reachability derivation that every clause in every reachable configuration is entailed by `F`.

- **Base case** (`init`): The empty configuration has no clauses; the property holds vacuously.
- **Download**: The new clause is in `F`, hence entailed (by `entailed_of_mem`).
- **Resolve**: The resolvent of two entailed clauses is entailed (by `entailed_resolve`, which uses `resolve_sound`).
- **Erase**: Removing a clause preserves the invariant for remaining clauses.

*Stage 2: Contradiction.* If the checker accepts, then `runActions` produces a configuration `mem` containing `∅`. By `runActions_reachable`, `mem` is space-reachable. By the invariant, `∅` is entailed by `F`. But `∅` (the empty clause) is unsatisfiable by `empty_clause_unsat`, contradicting the assumption that some `τ` satisfies all entailed clauses.

The resolution soundness lemma—the semantic core—is proved by case analysis on `τ(v)`:
- If `τ(v) = true`: the literal `(v, false)` is not satisfied, so the satisfying literal of `c₂` must lie in `c₂ \ {(v, false)}`, which is a subset of the resolvent.
- If `τ(v) = false`: symmetric argument using `c₁`.

### 3.2 Theorem 2: Completeness of Space Certificates

**Theorem** (Completeness). *If `F` is clause-space refutable in space `s`, then there exists a certificate accepted by the checker.*

```
spaceCertificate_complete : clauseSpaceRefutable F s →
    ∃ C, certificateChecks F s C = true
```

**Proof sketch.** By induction on the `SpaceReachable` derivation, we construct a list of step actions whose execution reproduces the reachability sequence.

The key auxiliary lemma shows that `runActions` distributes over list concatenation: if `runActions(actions₁, ∅) = some(mem)` and `applyAction(mem, a) = some(mem')`, then `runActions(actions₁ ++ [a], ∅) = some(mem')`.

Each space step is converted to a step action via `step_implies_applyAction`, which destructs the `SpaceStep` inductive and constructs the corresponding `StepAction`.

### 3.3 Theorem 3: Space Monotonicity

**Theorem** (Monotonicity). *If `s ≤ t` and `F` is clause-space refutable in space `s`, then `F` is clause-space refutable in space `t`.*

```
certificate_monotone_in_space : s ≤ t → clauseSpaceRefutable F s → clauseSpaceRefutable F t
```

**Proof sketch.** By induction on the `SpaceReachable` derivation, replacing every bound `mem'.card ≤ s` with `mem'.card ≤ t` (which follows from `s ≤ t` by transitivity).

### 3.4 Theorem 4: Ternary Injection

**Theorem** (Ternary Injection). *The map `clauseToTernary : Clause Var → (Var → Fin 3)` is injective on consistent clauses.*

```
clauseToTernary_injective : c₁.consistent → c₂.consistent →
    clauseToTernary c₁ = clauseToTernary c₂ → c₁ = c₂
```

**Definition.** `clauseToTernary(c)(v) = 0` if `(v, true) ∈ c`, `1` if `(v, false) ∈ c`, `2` if neither.

**Proof sketch.** By `Finset.ext`: for each literal `(v, b)`, show membership in `c₁` iff membership in `c₂`. The ternary encoding determines, for each variable, which polarity (if any) is present. Consistency ensures the encoding is faithful: the first branch of the if-then-else uniquely determines whether a variable appears positively.

### 3.5 Theorem 5: Counting Bound

**Theorem** (Clause Count). *The number of consistent clauses over `n` variables is at most `3^n`.*

```
numConsistentClauses_le_three_pow :
    Fintype.card {c : Clause Var // c.consistent} ≤ 3 ^ Fintype.card Var
```

**Proof sketch.** By `Fintype.card_le_of_injective` applied to the ternary injection (Theorem 4), noting that `Fintype.card (Var → Fin 3) = 3 ^ Fintype.card Var`.

### 3.6 Additional Results

**Abstract Soundness.** `clauseSpaceRefutable_sound : clauseSpaceRefutable F s → ¬ satisfiable F`.

**Potential Bounds.** The space potential (configuration cardinality) is:
- Zero for the initial configuration.
- Bounded by *s* for all reachable configurations.
- Increased by at most 1 by download/resolve.
- Decreased by exactly 1 by erase.

---

## 4. Combinatorial Analysis

### 4.1 Configuration Space Geometry

For a finite variable set of size *n*, the space of all possible configurations of size ≤ s is:

```
|S(F, s)| ≤ Σ_{k=0}^{s} C(3^n, k)
```

for consistent clauses. This bound follows directly from Theorem 5.

The configuration graph `G(F, s)` has:
- **Vertices**: all configurations `mem ⊆ Clause(Var)` with `|mem| ≤ s`.
- **Edges**: pairs `(mem, mem')` connected by a valid space step.

A space certificate corresponds to a path in `G(F, s)` from `∅` to a vertex containing `∅`.

### 4.2 Complexity Implications

The finiteness of `G(F, s)` immediately implies:
- Decidability of clause-space refutability (for finite `Var`).
- Termination of exhaustive search (BFS/DFS over `G(F, s)`).
- Explicit upper bounds on certificate length (at most `|V(G(F,s))|`).

For the general (inconsistent) clause case, the total number of possible clauses is `2^(2n)` (all subsets of `Var × Bool`), giving configuration count `Σ_{k=0}^s C(4^n, k)`.

### 4.3 Relationship to Known Space Bounds

The Esteban-Torán [2001] framework defines clause space as the minimum *s* such that `F` is clause-space refutable in space *s*. Our framework provides a *certificate* for any particular value of *s*, enabling:

1. **Verification**: check that a claimed space bound is achievable.
2. **Optimization**: search for minimal *s* by binary search on the space parameter.
3. **Lower bounds**: prove non-existence of certificates for small *s* by exhausting the configuration graph.

---

## 5. Implementation

### 5.1 Executable Checker

The certificate checker is implemented as a pure function:

```
certificateChecks(F, s, cert) =
  match runActions(F, s, cert.actions, ∅) with
  | some(mem) => ∅ ∈ mem
  | none => false
```

where `runActions` folds the actions over the initial memory state, checking validity and space bounds at each step.

### 5.2 Search Procedure

The search procedure (implemented in Python for the computational experiments) performs BFS over the configuration graph:

```
findSpaceCertificate(F, s):
  queue ← {∅}
  visited ← {∅}
  parent ← {}
  while queue ≠ ∅:
    mem ← dequeue(queue)
    if ∅ ∈ mem: return reconstruct_path(parent, mem)
    for mem' in successors(F, s, mem):
      if mem' ∉ visited:
        visited ← visited ∪ {mem'}
        parent[mem'] ← mem
        enqueue(queue, mem')
  return none
```

### 5.3 Computational Experiments

We tested the framework on all CNFs over at most 3 variables with space bound s ≤ 4. For each formula:
1. Exhaustive BFS over the configuration graph.
2. Certificate reconstruction when a goal configuration is found.
3. Certificate verification by the checker.
4. Runtime statistics (configurations explored, certificate length, total configuration count).

Results confirm that:
- All unsatisfiable formulas with space-bounded refutations are found by BFS.
- Certificate lengths are bounded by the number of reachable configurations.
- The configuration count matches the theoretical bound.

See `demo.py` for the complete experimental setup.

---

## 6. Discussion

### 6.1 Significance

Space certificates introduce a new interface between proof complexity and certified computation. They answer not only "is F unsatisfiable?" but "is F unsatisfiable within memory budget s, and can that fact be independently verified?"

This is orthogonal to DRAT-style certificates, which bound proof *length* rather than *space*. The two notions can coexist: a single refutation could carry both a DRAT certificate (bounding length) and a space certificate (bounding memory), giving a complete resource profile.

### 6.2 Limitations

- The current framework uses resolution as the only inference rule. Extending to stronger proof systems (extended resolution, cutting planes) requires new step definitions and soundness proofs.
- The configuration graph is exponentially large in general. Practical search requires heuristics (clause learning, symmetry breaking) that are not yet integrated.
- The framework does not address *total space* (counting literal occurrences) or *variable space* (counting distinct variables), which are related but distinct complexity measures.

### 6.3 Open Questions

1. **Minimal space certificates**: Is the shortest space-s certificate for a formula polynomially related to the diameter of its reachable configuration subgraph?
2. **Space-length tradeoffs**: Can space certificates be used to prove new space-length tradeoff results?
3. **Practical integration**: Can existing CDCL solvers be modified to output space certificates alongside DRAT proofs?

---

## 7. Future Work

1. **Extended proof systems**: Define space certificates for extended resolution, polynomial calculus, and cutting planes.
2. **Lower bound proofs**: Use the configuration graph framework to formalize known space lower bounds (e.g., for pebbling formulas).
3. **Practical solvers**: Build a SAT solver that outputs space certificates in addition to DRAT proofs.
4. **Parallel certificates**: Extend the framework to parallel and distributed proof search.
5. **Connections to circuit complexity**: Investigate the relationship between clause space and circuit depth.

---

## References

- Ben-Sasson, E. (2009). Size-space tradeoffs for resolution. *STOC*.
- Esteban, J. L., & Torán, J. (2001). Space bounds for resolution. *Inf. Comput.*, 171(1), 84–97.
- Fleury, M., Blanchette, J. C., & Lammich, P. (2019). A verified SAT solver with watched literals. *CPP*.
- Heule, M. J. H., Hunt, W. A., & Wetzler, N. (2017). Efficient, verified checking of propositional proofs. *ITP*.
- Lammich, P. (2020). Efficient verified (UN)SAT certificate checking. *J. Autom. Reason.*, 64(3), 513–532.
- Nordström, J. (2013). Pebble games, proof complexity, and time-space trade-offs. *Logical Methods in Computer Science*, 9(3).
- Wetzler, N., Heule, M. J. H., & Hunt, W. A. (2014). DRAT-trim: Efficient checking and trimming using expressive clausal proofs. *SAT*.
