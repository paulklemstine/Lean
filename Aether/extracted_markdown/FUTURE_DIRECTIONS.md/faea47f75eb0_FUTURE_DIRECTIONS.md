# Future Directions: ACI Canonicalization and Tropical Algebra

## Overview

The formal verification of ACI canonicalization for tropical `min` expressions establishes the foundation for a certified tropical algebra engine. The following directions represent concrete, actionable research opportunities at the intersection of formal methods, algebra, optimization, and computer science.

---

## Direction 1: Full Tropical Semiring Normalization (ACI + Distributivity)

### Goal
Extend ACI normalization from `min` alone to the full tropical semiring with both `min` (⊕) and `+` (⊗), handling the distributive law `a + min(b, c) = min(a+b, a+c)`.

### Key Theorem Target
```
theorem normalizeACID_sound :
  ∀ e, ACIDEquiv e (normalizeACID e)

theorem normalizeACID_complete :
  ∀ {e₁ e₂}, ACIDEquiv e₁ e₂ → normalizeACID e₁ = normalizeACID e₂
```

### Approach
1. Define extended expressions: `Expr ::= var(n) | const(r) | tmin(a,b) | tadd(a,b)`
2. Define ACID congruence including distributivity of `+` over `min`
3. Canonical form: sum-of-products normal form → min of affine forms
4. Normalization: distribute `+` over `min`, then apply ACI to the outer `min` layer
5. Inner `+` subexpressions need their own AC normalization

### Significance
This gives canonical forms for **tropical polynomials**, the central objects of tropical geometry. A tropical polynomial min(c₁ + a₁x, c₂ + a₂x, ...) would be normalized to have distinct monomials in canonical order.

### Estimated Difficulty
High. Distributivity interacts non-trivially with idempotence, and the canonical form for the full tropical semiring is more complex than for `min` alone.

---

## Direction 2: Reflective Decision Tactic (`norm_tropical`)

### Goal
Implement a `norm_tropical` tactic that decides equalities in the tropical semiring automatically within proofs, using the verified normalizer as a certified kernel computation.

### Key Theorem Target
```
-- A tactic that closes goals of the form:
-- ⊢ min a (min a b) = min a b
-- by normalizing both sides and checking syntactic equality
```

### Approach
1. Use Lean 4's metaprogramming (Qq, reflection) to quote goal expressions into `Expr`
2. Compute `normalizeACI` on both sides (using `native_decide` or `Decidable` instances)
3. Close the goal via `eval_normalizeACI` and the completeness theorem
4. Package as a user-facing `norm_tropical` tactic

### Significance
This transforms the theoretical decision procedure into a practical proof automation tool. Users could close tropical identities automatically, similar to how `ring` closes ring identities.

### Estimated Difficulty
Medium. The mathematical foundations are complete; the engineering challenge is metaprogramming in Lean 4.

---

## Direction 3: Canonical Tropical Polynomial Forms

### Goal
Prove that duplicate tropical monomials can be eliminated without changing the tropical hypersurface (the set of non-differentiability points of the piecewise-linear function).

### Key Theorem Target
```
theorem tropical_hypersurface_eq_of_ACI :
  ∀ p q : TropicalPolynomial,
    ACIEquiv p.toMinExpr q.toMinExpr →
    tropicalHypersurface p = tropicalHypersurface q
```

### Approach
1. Define tropical polynomials as formal sums (= min of affine forms)
2. Define tropical hypersurface as the locus where the minimum is achieved by ≥2 monomials
3. Prove that ACI-equivalent polynomial expressions define the same hypersurface
4. Connect to existing tropical geometry in Mathlib (if available) or build from scratch

### Significance
This is the bridge from algebraic normalization to tropical geometry. It establishes that syntactic simplification (removing duplicate monomials) is geometrically sound.

### Estimated Difficulty
High. Requires developing tropical hypersurface theory from foundations.

---

## Direction 4: Finite-Set Semantics Theorem (Free Semilattice)

### Goal
Formally prove the isomorphism between ACI-equivalence classes of `min`-expressions and the power set lattice, establishing that our normalizer computes representatives for the **free meet-semilattice**.

### Key Theorem Target
```
theorem free_semilattice_iso :
  ∀ (S : Finset ℕ) (hS : S.Nonempty),
    ∃! (e : Expr), Canonical e ∧ varSet e = S

def ACIQuotient := Quotient ACIEquivSetoid

theorem ACI_quotient_iso_finset :
  ACIQuotient ≃ { S : Finset ℕ // S.Nonempty }
```

### Approach
1. Define `Canonical : Expr → Prop` (right-associated, sorted, deduplicated)
2. Prove `normalizeACI e` is canonical for all e
3. Prove canonical forms are unique: Canonical e₁ ∧ Canonical e₂ ∧ varSet e₁ = varSet e₂ → e₁ = e₂
4. Construct the quotient and the bijection explicitly

### Significance
This is the deep algebraic content: ACI normalization is the computational manifestation of the universal property of free semilattices. It opens the door to formalizing universal algebra in the proof assistant.

### Estimated Difficulty
Medium. The mathematical content is already implicit in our proofs; making it explicit requires constructing quotient types and equivalences.

---

## Direction 5: Certified Optimization and Shortest-Path Verification

### Goal
Use the ACI normalizer to certify redundancy elimination in shortest-path computations and dynamic programming, producing verified certificates that simplified computations are correct.

### Key Theorem Target
```
theorem bellman_ford_aci_optimization :
  ∀ (G : WeightedGraph) (s t : Vertex),
    eval σ (normalizeACI (bellmanFordExpr G s t)) =
    eval σ (bellmanFordExpr G s t)

theorem dp_redundancy_elimination :
  ∀ (dp_raw dp_opt : DPTable),
    ACIEquiv dp_raw.toExpr dp_opt.toExpr →
    dp_raw.optimal = dp_opt.optimal
```

### Approach
1. Define symbolic Bellman-Ford producing tropical expressions
2. Show that ACI normalization of the output preserves the optimal value
3. Quantify the compression ratio (output size / input size)
4. Extend to matrix min-plus exponentiation for all-pairs shortest paths

### Significance
This connects formal verification of algebraic identities to verified algorithms in combinatorial optimization—a bridge between pure algebra and systems correctness.

### Estimated Difficulty
Medium-High. Requires formalizing graph algorithms and connecting them to tropical expressions.

---

## Cross-Cutting Theme: Toward a Tropical Algebra Engine

All five directions contribute to a single vision: a **formally verified tropical algebra engine** embedded in a proof assistant, capable of:

1. Deciding equalities in the tropical semiring (Direction 2)
2. Computing canonical forms for tropical polynomials (Direction 3)
3. Certifying optimizations in combinatorial algorithms (Direction 5)
4. Providing the algebraic foundation for tropical geometry (Direction 4)
5. Handling the full equational theory of idempotent semirings (Direction 1)

The ACI canonicalization theorem proved in this work is the seed from which this engine grows. Each direction extends the scope while building on the verified core: soundness, completeness, and idempotence of the normalizer.

---

## Priority Ranking

| Direction | Impact | Feasibility | Priority |
|-----------|--------|-------------|----------|
| 2. Reflective tactic | High | High | ★★★★★ |
| 4. Free semilattice | High | High | ★★★★★ |
| 1. Full semiring | Very High | Medium | ★★★★ |
| 5. Certified optimization | High | Medium | ★★★★ |
| 3. Tropical polynomials | Very High | Low-Medium | ★★★ |

Direction 2 (reflective tactic) has the highest immediate payoff: it makes the theoretical results practically usable. Direction 4 (free semilattice) deepens the theoretical foundations with relatively modest additional effort. These two should be pursued first.
