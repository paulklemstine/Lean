# Future Directions: Tropical AC Normalization

This document outlines concrete breakthrough research opportunities opened by the certified AC normalization theorem for tropical expressions.

---

## Direction 1: Extend to ACI — Idempotence of `min`

**Hypothesis**: The canonical form can be extended to handle the idempotence law `min(a, a) = a` by replacing sorted lists with sorted sets (removing duplicates after normalization).

**Proof Strategy**:
1. Define `normalize_aci` that applies `List.dedup` after sorting in the `tmin` case.
2. Prove soundness: `eval σ (normalize_aci e) = eval σ e` (since `min(a, a) = a`).
3. Define `ACIEquiv` extending `ACEquiv` with `tmin_idem : ∀ e, ACIEquiv (tmin e e) e`.
4. Prove completeness: `ACIEquiv e₁ e₂ → normalize_aci e₁ = normalize_aci e₂`.

**Key Challenge**: The idempotence rule interacts with the recursive structure — deduplication must happen at every level. The proof requires showing that `dedup` on a sorted list is well-defined and that it preserves the `evalMinList` semantics (via `min(a, a) = a` on ℝ).

**Impact**: This captures a strictly larger fragment of tropical identities and connects to lattice-theoretic canonicalization. In applications, idempotent min arises naturally in shortest-path computations where redundant paths can be pruned.

**Cross-domain Connections**: Lattice theory (join-semilattice normal forms), BDD construction (where Boolean AND is idempotent), database query optimization (duplicate elimination in unions).

---

## Direction 2: Integrate Distributivity via Knuth–Bendix Completion

**Hypothesis**: The distributive law `a + min(b, c) = min(a+b, a+c)` can be oriented as a rewrite rule and integrated into a term rewriting system that extends the AC normalizer.

**Proof Strategy**:
1. Orient distributivity as `a + min(b, c) → min(a+b, a+c)` (expanding form).
2. Define a termination measure (e.g., a weighted sum of nesting depths and sizes).
3. Prove local confluence by analyzing critical pairs between distributivity and AC rules.
4. Apply Newman's lemma (in Mathlib: `Relation.ReflTransGen.confluent_of_locally_confluent`) to derive a complete rewriting system.
5. Extract the normalized form as the unique normal form under the completed system.

**Key Challenge**: The critical pair analysis is nontrivial — distributivity interacts with both associativity of `+` and commutativity of `min`. Some critical pairs may require additional rules (e.g., factoring `min(a+b, a+c) → a + min(b, c)`).

**Impact**: A complete rewriting system for the full tropical semiring theory would give a decision procedure for tropical polynomial identity. This is the tropical analogue of Gröbner bases for commutative algebra.

**Cross-domain Connections**: Automated theorem proving (Knuth–Bendix completion), SMT solvers (theory normalization), computer algebra systems (canonical simplification).

---

## Direction 3: Certified Tropical Polynomial Normal Form

**Hypothesis**: Tropical polynomials (finite sums of monomials, where each monomial is a product of variables with a constant coefficient, and sums use `min`) can be canonicalized into a sorted list of sorted monomials.

**Proof Strategy**:
1. Define `TropMonomial := ℝ × List (ℕ × ℕ)` (coefficient + sorted list of (variable, exponent) pairs).
2. Define `TropPolynomial := List TropMonomial` (sorted list of monomials).
3. Define `eval_poly` and `normalize_poly`.
4. Prove the analogue of the AC normalization theorem: two tropical polynomials are equal under all valuations iff they have the same canonical form.

**Key Challenge**: The freeness/injectivity argument is more delicate for polynomials than for the AC fragment, because tropical polynomials can have accidental equalities (e.g., `min(x, x+1)` equals `x` for all `x ≥ -1`). The correct statement must either restrict to formal equality or handle the tropical Nullstellensatz.

**Impact**: Tropical polynomial normal forms are the foundation for tropical algebraic geometry computations, tropical curve enumeration, and connections to Newton polygons. A certified normal form would enable verified computation in these areas.

**Cross-domain Connections**: Algebraic geometry (Newton polygons, tropical varieties), optimization (linear programming duality), phylogenetics (tropical tree spaces).

---

## Direction 4: Build a Reflection Tactic for Tropical Goals

**Hypothesis**: The `normalize_ca_decides_ACEquiv` theorem can be used to build a proof-producing tactic that automatically closes goals of the form `eval σ e₁ = eval σ e₂` when `e₁` and `e₂` are AC-equivalent.

**Proof Strategy**:
1. Define a `reflect` function that maps Lean expressions involving `min` and `+` on ℝ into `TropExpr` values.
2. Use `native_decide` or `Decidable.decide` on the equality `normalize_ca (reflect e₁) = normalize_ca (reflect e₂)`.
3. Apply `normalize_ca_sound` to convert the syntactic equality back to semantic equality.
4. Package as a `tactic` using Lean 4's metaprogramming framework.

**Key Challenge**: The reflection step requires careful handling of coercions, especially when the goal involves mixed arithmetic (e.g., `min(a + b, c) = min(c, b + a)`). The tactic must also handle partial applications and higher-order terms gracefully.

**Impact**: This would give users a `tropical_ac` tactic that solves AC goals automatically, analogous to `ring` for commutative ring identities. It would dramatically reduce proof effort for tropical algebra formalizations.

**Cross-domain Connections**: Proof automation (reflection tactics), verified compilation (proof-producing optimizers), formal methods (decision procedures in proof assistants).

---

## Direction 5: Connect to Equality Saturation and E-Graphs

**Hypothesis**: The AC canonical form provides a deterministic alternative to e-graph saturation for the AC fragment of tropical algebra. For larger fragments (with distributivity), e-graph techniques may be needed, and the AC normalizer can serve as a preprocessing step.

**Proof Strategy**:
1. Formalize e-graphs as quotient structures on expression DAGs.
2. Show that the AC congruence closure in an e-graph produces the same equivalence classes as `normalize_ca`.
3. Prove that adding distributivity rewrite rules to the e-graph saturates to a fixpoint that refines the AC classes.
4. Use the canonical form as a hash-consing key for e-graph nodes to improve efficiency.

**Key Challenge**: E-graph formalization in Lean 4 requires careful handling of mutable state and fixpoint computation. The termination argument for saturation with distributivity is nontrivial (it may not terminate in general, requiring bounds or heuristics).

**Impact**: A certified equality saturation engine for tropical expressions would be the first of its kind, connecting formal verification with state-of-the-art program optimization techniques. It could be used for certified tropical circuit optimization, verified compiler passes for min-plus programs, and formal analysis of ReLU neural networks (which are piecewise-linear, hence tropical).

**Cross-domain Connections**: Program optimization (equality saturation, egg framework), neural network verification (ReLU networks as tropical rational functions), compiler verification (certified optimization passes), SAT/SMT solving (preprocessing and simplification).

---

## Research Team Directive

Each direction above is designed to be independently pursuable by a small team (1–3 researchers). The recommended workflow:

1. **Formulate** the precise mathematical statement in Lean 4 (theorem with `sorry`).
2. **Validate** with computational experiments in Python (counterexample search, performance benchmarks).
3. **Decompose** into helper lemmas (5–15 per direction).
4. **Prove** bottom-up, starting with the simplest structural lemmas.
5. **Iterate**: if a lemma is false, adjust the statement and re-validate.

The certified AC normalizer provides the foundation. Each extension builds on it, creating an expanding infrastructure for tropical formal methods.
