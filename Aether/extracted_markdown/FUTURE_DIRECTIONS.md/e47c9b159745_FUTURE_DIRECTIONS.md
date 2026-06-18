# Future Directions: Tropical AC Normalization

## Overview

The certified AC normalization theorem for tropical expressions opens several concrete research directions, each building directly on the canonicalization infrastructure established here.

---

## Direction 1: Extend to ACI (Associativity, Commutativity, Idempotence)

**Goal:** Upgrade the normalizer to quotient by the idempotence law `min(a, a) = a`.

**Key insight:** The current `flattenMin` produces a *list* of children. To handle idempotence, replace the internal representation with a *set* (or sorted list with deduplication). The multiset-based approach used here naturally extends: replace `Multiset` with `Finset` for the min operation.

**Proof strategy:**
1. Define `flattenMinSet : TropExpr → Finset TropExpr` that deduplicates.
2. Prove that `Finset.sort` on equal finsets gives equal lists.
3. Extend `ACEquiv` with `| tmin_idem (e : TropExpr) : ACEquiv (.tmin e e) e`.
4. Prove completeness for the extended congruence.

**Challenges:**
- Idempotence only applies to `min`, not `+`. The normalizer must treat the two operations asymmetrically.
- Need to prove that deduplication commutes with recursive normalization.

**Impact:** This captures the full lattice structure of `min`, enabling stronger simplification of tropical expressions.

---

## Direction 2: Integrate Distributivity via Knuth–Bendix Completion

**Goal:** Extend the normalizer to handle the distributive law `a + min(b, c) = min(a + b, a + c)`.

**Key insight:** The current AC normalizer deliberately stops at the AC fragment. Distributivity introduces cross-operator interactions that require a fundamentally different normal form: tropical polynomials as sets of monomials (as in the existing `TropicalNF` module).

**Proof strategy:**
1. Define oriented rewrite rules: `add a (tmin b c) → tmin (add a b) (add a c)`.
2. Show termination using a suitable measure (e.g., number of `add`-over-`tmin` patterns).
3. Show confluence by verifying all critical pairs are joinable.
4. Alternatively, bypass rewriting by directly normalizing to monomial support form.

**Challenges:**
- The distributive law is not terminating under naive orientation. Need to restrict to specific normal forms.
- Interaction with AC normalization requires careful layering.

**Impact:** A complete tropical polynomial normal form would yield a certified decision procedure for the full equational theory of `(ℝ, min, +)`.

---

## Direction 3: Build a Reflection Tactic for Tropical Goals

**Goal:** Use `normalize_ca` as the computational kernel of a proof-producing tactic that automatically closes tropical AC goals.

**Key insight:** The completeness theorem `normalize_ca_complete` already provides the core logic: to prove `ACEquiv e₁ e₂`, compute `normalize_ca e₁` and `normalize_ca e₂` and check equality. The soundness theorem then certifies the result.

**Implementation plan:**
1. Make `normalize_ca` computable by replacing the `WellOrderingRel`-based `LinearOrder` with a concrete decidable comparison on `TropExpr`.
2. Write a Lean 4 macro/tactic that:
   a. Reifies a tropical expression goal into `TropExpr` syntax.
   b. Calls `normalize_ca` on both sides.
   c. Uses `native_decide` or `decide` to check syntactic equality.
   d. Applies `eval_normalize_ca` to close the goal.
3. Extend to handle goals of the form `eval σ e₁ = eval σ e₂` by applying soundness.

**Challenges:**
- Reification of Lean expressions into `TropExpr` requires metaprogramming.
- The current `LinearOrder` is noncomputable; a computable version needs explicit comparison logic.

**Impact:** Automates routine AC reasoning in tropical algebra, analogous to `ring` for commutative rings.

---

## Direction 4: Certified Tropical Polynomial Normal Form

**Goal:** Define a canonical representation for tropical polynomials (expressions modulo AC + distributivity) and prove it complete.

**Key insight:** A tropical polynomial in `n` variables is a finite pointwise minimum of affine forms `c + w₁x₁ + ... + wₙxₙ`. The normal form is a `Finset` of `(ℝ × (Fin n → ℕ))` pairs. This is the Newton polytope representation.

**Proof strategy:**
1. Define `TropPolyNF` as `Finset (ℝ × (ℕ → ℕ))` (or `Fin n → ℕ`).
2. Define normalization by expanding distributivity fully, then collecting monomials.
3. Prove soundness: evaluation of the normal form equals evaluation of the original.
4. Prove completeness: two expressions with the same evaluation for all σ have the same monomial support.

**Challenges:**
- Completeness requires proving that the tropical semiring `(ℝ, min, +)` is "free" over generators in the appropriate sense. This is a nontrivial algebraic fact.
- Need to handle cancellation: `min(a + b, a + c)` might simplify when `b ≤ c` always holds.

**Impact:** Full decision procedure for tropical polynomial identity, enabling certified optimization and circuit minimization.

---

## Direction 5: Connect to Shortest-Path and Optimization Algorithms

**Goal:** Use canonical tropical expressions to certify shortest-path computations and min-plus dynamic programs.

**Key insight:** Tropical matrix multiplication computes shortest paths. An expression `min(a + b, c + d, ...)` over path weights can be represented as a `TropExpr`. The canonical form eliminates redundant subexpressions, enabling certified common-subexpression elimination (CSE) in optimization pipelines.

**Proof strategy:**
1. Define tropical matrix multiplication in terms of `TropExpr` composition.
2. Show that normalization of the resulting expression corresponds to shortest-path computation.
3. Prove that CSE via normalization preserves the optimal value.
4. Connect to the Bellman-Ford or Floyd-Warshall algorithms as special cases.

**Challenges:**
- Tropical matrices over `n × n` generate expressions exponential in `n`. Need efficient representations.
- The AC fragment alone doesn't suffice; need distributivity for full path-algebra reasoning.

**Impact:** Certified optimization algorithms with formal correctness guarantees, applicable to network routing, scheduling, and resource allocation.

---

## Cross-Cutting Themes

### Universal Algebra Perspective
The AC normalization theorem is an instance of the word problem for the free algebra over two commutative-associative operations. Generalizing this framework to arbitrary equational theories would yield a generic certified normalization toolkit.

### Connection to E-Graphs and Equality Saturation
The canonical form produced by `normalize_ca` is a deterministic alternative to e-graph saturation for the AC fragment. Formalizing the connection between canonical forms and e-graphs could lead to certified equality-saturation engines.

### Boolean Logic Analogy
Via the correspondence `min ↔ ∧` (tropical min corresponds to logical conjunction), AC normalization of `tmin` is analogous to clause canonicalization in SAT preprocessing. Extending this analogy could connect tropical algebra to certified SAT/SMT preprocessing.
