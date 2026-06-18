# Future Directions: Algebraic Compiler Lower Bounds

## Synthesis

The compiler lower bound metatheorem establishes that semantics-preserving, inverse-free-preserving optimization passes cannot reduce EML depth below the inherent lower bound for iterated exponentials. This opens a new research program: **the formal complexity theory of verified optimization**. The directions below extend this foundation in five ways: (1) strengthening the barrier from lower bound to exact invariance, (2) extending to richer languages, (3) connecting to parallel computation theory, (4) developing a general resource monotone framework, and (5) bridging to equality saturation and modern compiler IR techniques. Each direction is falsifiable and computationally testable.

---

## Direction 1: Exact Depth Invariance Under Standard Passes

**Conjecture**: For every pipeline built from {CSE, constant folding, algebraic simplification} and every canonical inverse-free `emlExprIterExp n`, the output depth is exactly `n` (not just ≥ n).

```
conjecture pipeline_preserves_exact_iterExp_depth :
  ∀ (ps : List OptPass) (n : ℕ),
    (runPipeline ps).transform (emlExprIterExp n)).emlDepth = n
```

**Test**: For n ≤ 20 and all pipelines of length ≤ 10 composed from the three standard passes, compute the output EML depth. If any output has depth ≠ n, the conjecture is disproved.

**Impact**: Would upgrade the lower bound to an exact invariance theorem, showing that these optimizations don't merely fail to break the barrier — they cannot even perturb it.

**Catalog References**: `CompilerLowerBound/Theorems.lean` (pipeline_iterExp_depth_lower_bound, canonical_iterExp_depth_after_pipeline)

**Proof Strategy**: Show that each pass applied to the canonical `emlExprIterExp n` returns an expression with the same EML depth. For CSE (identity), this is trivial. For constant folding, show that the canonical expression has no constant subexpressions to fold (the `1` coefficients are necessary). For algebraic simplification, show no double negations exist.

**Domain Bridges**: Verified compilation (CompCert normal forms), term rewriting (confluence and termination on canonical forms)

**Lineage**: Direct extension of `canonical_iterExp_depth_after_pipeline`

**Ambition**: Solid extension — natural next step from the existing lower bound

---

## Direction 2: Depth Lower Bounds for Extended EML with Conditionals

**Conjecture**: The depth lower bound extends to an EML language augmented with conditional expressions `if(a > 0, b, c)`, provided the optimizer preserves a suitable "branch-free on positive inputs" invariant.

**Test**: Define `EMLExprExt` with conditionals. Construct expressions computing `iterExp n` using conditionals (e.g., `if(x > 0, eml(1, e_{n-1}), 0)`). Verify computationally that no rearrangement with depth < n agrees with `iterExp n` on a dense set of positive inputs for n ≤ 10.

**Impact**: Would establish that the depth barrier is robust to language enrichment, not an artifact of the restricted EML syntax.

**Catalog References**: `CompilerLowerBound/Defs.lean` (EMLExpr, InverseFree), `CompilerLowerBound/GrowthBound.lean` (growth separation arguments)

**Proof Strategy**: Extend the growth bound analysis. On positive inputs, conditionals that select the positive branch reduce to unconditional expressions, so the growth rate argument still applies. The key lemma: any branch-free-on-positives EMLExprExt computing `iterExp n` has a subtree that is an inverse-free EMLExpr computing `iterExp n`.

**Domain Bridges**: Program analysis (branch elimination, partial evaluation), SMT solving (satisfiability-guided optimization)

**Lineage**: Extension of the core lower bound to richer expression types

**Ambition**: Solid extension — requires modest formal infrastructure for conditionals

---

## Direction 3: Resource Monotone Framework for Optimization Barriers

**Conjecture (Grand Challenge)**: There exists a general theory of *resource monotones* — quantities μ : EMLExpr → ℕ that are monotonically preserved under semantics-preserving transformations — such that:
(a) EML depth is a resource monotone for inverse-free-preserving passes
(b) There exist other resource monotones capturing different complexity aspects (e.g., "transcendental width")
(c) The set of all resource monotones forms a lattice under natural ordering

**Test**: Define candidate monotones: transcendental width (max number of independent eml nodes at any level), eml count, exp rank. For each, check computationally whether the pipeline test from Direction 1 preserves them for n ≤ 15.

**Impact**: Would establish a "periodic table" of optimization barriers, each monotone corresponding to a different aspect of complexity that optimizers cannot reduce.

**Catalog References**: `CompilerLowerBound/Defs.lean` (OptPass, CannotReduceIterExpDepth), `CompilerLowerBound/Theorems.lean` (optPass_cannot_reduce_depth)

**Proof Strategy**: Abstract the proof pattern: any quantity μ satisfying (i) μ(e) depends only on the semantic function of e and (ii) μ is computable from syntax, is automatically preserved by semantics-preserving passes. The challenge is finding non-trivial monotones beyond depth.

**Domain Bridges**: Quantum information theory (entanglement monotones), thermodynamics (entropy as a monotone), algebraic topology (homotopy invariants)

**Lineage**: Grand generalization of the depth lower bound

**Ambition**: Grand challenge — would open a new subfield

---

## Direction 4: DAG Representation and Non-Trivial CSE

**Conjecture**: In a DAG representation where CSE merges structurally equal subexpressions, the depth lower bound still holds, and furthermore CSE can reduce *size* but never *depth* for the `iterExp` family.

**Test**: Implement a DAG-based EMLExpr with hash-consing. For expressions computing `iterExp n` with artificially duplicated subexpressions (e.g., `eml(eml(1, x), eml(1, x))` for a variant of `iterExp 2`), apply CSE and measure depth and size. Verify depth ≥ n for all test cases with n ≤ 15.

**Impact**: Would make the CSE pass non-trivial and demonstrate the depth/size asymmetry in a concrete setting: CSE reduces size (from O(2^n) shared-free to O(n) shared) while preserving depth.

**Catalog References**: `CompilerLowerBound/Defs.lean` (cseTransform), `CompilerLowerBound/Theorems.lean` (cse_cannot_reduce_iterExp_depth)

**Proof Strategy**: Define `DAGExpr` as a list of nodes with back-references. Define CSE as hash-consing. Prove that hash-consing preserves evaluation (by showing each node's eval is unchanged). The depth argument carries over because DAG depth ≥ tree depth for any unrolling.

**Domain Bridges**: Compiler engineering (SSA form, e-graphs), algebraic geometry (rational equivalence of expressions)

**Lineage**: Concrete enrichment of the CSE formalization

**Ambition**: Solid extension — standard compiler IR technique

---

## Direction 5: Connection to Equality Saturation Lower Bounds

**Conjecture (Grand Challenge)**: The depth lower bound extends to equality saturation — the most powerful known technique for program optimization. Specifically: no e-graph rewriting system with inverse-free rewrite rules can derive, from the canonical `emlExprIterExp n`, any expression with EML depth < n.

**Test**: Implement a simple e-graph for EML expressions with rewrite rules for associativity, commutativity, distributivity, and identity elements. Run equality saturation on `emlExprIterExp n` for n ≤ 8 and extract the minimum-depth expression. Verify that the minimum depth found is always ≥ n.

**Impact**: Would connect the lower bound theory to the most active area of compiler optimization research (e-graphs, egg, Herbie), showing that even the most powerful known optimization technique cannot break the barrier.

**Catalog References**: `CompilerLowerBound/Theorems.lean` (optPass_iterExp_depth_lower_bound — the metatheorem applies to any pass satisfying the OptPass contract, including those derived from equality saturation)

**Proof Strategy**: Model equality saturation as a sequence of OptPass applications, one per rewrite rule. Each rewrite rule that preserves semantics and inverse-freeness is a valid OptPass. By the pipeline theorem, their composition cannot break the barrier. The key challenge: proving that the standard algebraic rewrite rules (associativity, commutativity, distributivity) preserve inverse-freeness.

**Domain Bridges**: Program synthesis (enumerative search lower bounds), automated theorem proving (resolution lower bounds), algebraic rewriting (Knuth-Bendix completion)

**Lineage**: Grand extension connecting to modern compiler optimization techniques

**Ambition**: Grand challenge — would bridge formal verification and practical optimization
