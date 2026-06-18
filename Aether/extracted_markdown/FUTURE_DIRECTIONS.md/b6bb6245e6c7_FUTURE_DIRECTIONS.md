# Future Directions: Tropical Expression Normalization

This document outlines concrete next steps opened by the verified tropical expression normalizer.

---

## 1. Confluence and Canonical Forms for Commutative-Associative Tropical Syntax

**Precise statement:** Extend `TropExpr` with associativity and commutativity normalization rules for `tmin` and `add`. Define `normalize_ca : TropExpr → TropExpr` that flattens nested `tmin`/`add` nodes into sorted lists of children (using a total order on `TropExpr`). Prove:

```
∀ e, eval σ (normalize_ca e) = eval σ e
∀ e, normalize_ca (normalize_ca e) = normalize_ca e
∀ e₁ e₂, (∀ σ, eval σ e₁ = eval σ e₂) → normalize_ca e₁ = normalize_ca e₂  -- on the AC fragment
```

**Proof strategy:** Define a canonical flattened representation (sorted lists of summands/minands). Show the flattening+sorting procedure preserves eval by commutativity and associativity of `min` and `+` over `ℝ`. Idempotence follows from the determinism of sorting. Completeness on the AC fragment requires showing that all semantic equalities in the free commutative-associative min-plus algebra are captured by AC-normalization.

**Cross-domain payoff:** This gives a decision procedure for tropical polynomial identity testing on the AC fragment—directly relevant to tropical geometry (checking if two tropical polynomials define the same tropical hypersurface) and to verified optimization (canonicalizing objective functions).

---

## 2. Certified Decision Procedure for Semantic Equality on Finite Fragments

**Precise statement:** For expressions over finitely many variables `{0, ..., n-1}`, define a function `tropDecide : TropExpr → TropExpr → Bool` that returns `true` iff the two expressions are semantically equivalent. Prove:

```
∀ e₁ e₂, tropDecide e₁ e₂ = true ↔ ∀ σ, eval σ e₁ = eval σ e₂
```

**Proof strategy:** On a finite variable set, the semantics of min-plus expressions defines piecewise-linear functions. Two such functions are equal iff they agree on a finite test set (vertices of a sufficiently refined polyhedral decomposition). Alternatively, use the normal form: if the canonical normal form captures all identities, then `tropDecide e₁ e₂ := (normalize e₁ == normalize e₂)`.

**Cross-domain payoff:** This is a verified solver for tropical polynomial identity—a fundamental problem in tropical algebraic geometry. It also enables proof-by-reflection tactics: to prove `eval σ e₁ = eval σ e₂` in a proof, simply compute `tropDecide e₁ e₂` and reflect the result.

---

## 3. Normalization with Ultrametric/Tropical Bounds Preservation

**Precise statement:** Define a recursive upper bound function `ub : TropExpr → ℝ` using the tropical ultrametric structure (e.g., `ub (tmin a b) = min (ub a) (ub b)`, `ub (add a b) = ub a + ub b`, with base cases from a priori bounds). Prove:

```
∀ σ e, (∀ n, σ n ≤ bound n) → eval σ e ≤ ub e
∀ σ e, (∀ n, σ n ≤ bound n) → eval σ (normalize e) ≤ ub e
```

The second follows from the first + `normalize_preserves_semantics`, but the point is to show that normalization can be used as a certified preprocessing step for bound analysis.

**Proof strategy:** The bound `ub` is defined by structural recursion and inherits monotonicity from `min` and `+`. Transport across normalization using the existing `normalize_preserves_semantics` theorem. This connects directly to `tropical_ultrametric_bounds_semantics` from the catalog.

**Cross-domain payoff:** Certified bound propagation through normalized expressions is the core of verified tropical optimization. It enables safe preprocessing: simplify the expression first, then compute bounds on the simpler form with the guarantee that bounds are preserved.

---

## 4. Reflection Tactic: Reify and Discharge Tropical Goals

**Precise statement:** Implement a tactic `tropical_norm` that:
1. Reifies a goal of the form `min a (min b c) + d = min (a + d) (min b c + d)` into `TropExpr` terms `e₁`, `e₂`
2. Computes `normalize e₁` and `normalize e₂`
3. If equal, discharges the goal using `normalize_extensional_uniqueness`

Prove the reflection principle:
```
∀ e₁ e₂, normalize e₁ = normalize e₂ → ∀ σ, eval σ e₁ = eval σ e₂
```
(Already proved as `normalize_extensional_uniqueness`.)

**Proof strategy:** The reflection principle is already established. The engineering challenge is the reification step (a Lean 4 macro/tactic that pattern-matches on goal expressions and constructs `TropExpr` syntax trees). The key insight is that our `eval` function is the semantic bridge: if `eval σ e = goal_lhs` and `eval σ e' = goal_rhs`, and `normalize e = normalize e'`, then the goal follows.

**Cross-domain payoff:** This is the crown jewel—a proof-producing automation tactic for tropical arithmetic. It would allow users to write `by tropical_norm` to discharge equalities in min-plus algebra, analogous to `ring` for commutative rings or `omega` for linear arithmetic.

---

## 5. Closure-Operator Abstraction and Connection to Stone Duality

**Precise statement:** Define an abstract closure operator structure:

```
structure ClosureOp (α : Type) where
  cl : α → α
  idempotent : ∀ x, cl (cl x) = cl x
  extensive : ∀ x, ... -- or contractive, depending on direction
```

Show that `normalize` instantiates this structure (it is already idempotent). Connect to `closure_table_recovers_basis_and_spectrum`: show that the set of normal forms `{e | isNormalized e = true}` forms a "basis" for the space of tropical expressions modulo semantic equivalence, analogous to how a closure system's closed sets form a basis for a topology.

**Proof strategy:** The idempotence theorem is already proved. For the abstract closure structure, additionally prove that normalize is "contractive" in a suitable sense (e.g., `size (normalize e) ≤ size e`, already proved). The connection to Stone duality requires showing that the lattice of normal forms, ordered by a suitable semantic preorder, has the structure of a distributive lattice or frame—linking to the spectrum recovery theorem in the catalog.

**Cross-domain payoff:** This connects syntactic normalization to the deep algebraic-logical tradition of closure systems, Galois connections, and Stone duality. It shows that normalization is not just an optimization but a fundamental algebraic operation—extracting canonical representatives from equivalence classes. This perspective unifies rewriting theory, lattice theory, and formal logic.

---

## Summary of Priorities

| Priority | Direction | Difficulty | Impact |
|----------|-----------|------------|--------|
| 1 | Reflection tactic (#4) | Medium | Very High — immediate practical tool |
| 2 | AC-normalization (#1) | Medium-High | High — decision procedure for tropical identities |
| 3 | Bounds preservation (#3) | Low | Medium — certified optimization preprocessing |
| 4 | Decision procedure (#2) | High | Very High — verified solver |
| 5 | Closure abstraction (#5) | Medium | High — conceptual unification |

Each direction builds on the verified normalizer established in this work and extends it toward practical automation and deeper mathematical connections.
