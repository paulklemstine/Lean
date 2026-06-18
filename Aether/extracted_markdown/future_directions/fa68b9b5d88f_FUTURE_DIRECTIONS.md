# Future Directions: ACI Normalization for Tropical Semirings

## 1. Generic ACI Normalization for Arbitrary Idempotent Commutative Binary Operations

**Goal**: Generalize the `normalize_aci` framework from tropical `min` to any idempotent commutative monoid operation.

**Theorem target**:
```
theorem generic_aci_normalize_sound {α : Type} [LinearOrder α] [DecidableEq α]
    (op : α → α → α) (h_comm : ∀ a b, op a b = op b a)
    (h_assoc : ∀ a b c, op (op a b) c = op a (op b c))
    (h_idem : ∀ a, op a a = a) :
    ∀ e₁ e₂ : GenExpr α, GenACIEquiv op e₁ e₂ ↔ generic_normalize e₁ = generic_normalize e₂
```

**Approach**: Abstract the `TropExpr` inductive to a parametric expression type, with `op` replacing `tmin`. The flattening, sorting, and deduplication pipeline transfers directly. The key proof infrastructure (permutation invariance, dedup soundness) is already operation-agnostic.

**Impact**: Provides certified normalization for lattice operations (`∧`, `∨`), set operations (`∪`, `∩`), and any semilattice operation in a single framework.

---

## 2. Canonicalization for Full Tropical Semiring Expressions with Distributivity

**Goal**: Extend ACI normalization to handle the distributive law `a + min(b, c) = min(a + b, a + c)` in the tropical semiring.

**Theorem target**:
```
theorem tropical_polynomial_normal_form (p : TropPoly) :
    ∀ σ, eval σ (normalize_tropical p) = eval σ p
```

**Approach**: Tropical polynomial normal form represents expressions as `min` of a finite set of affine functions (monomials `c + Σ aᵢxᵢ`). Normalization distributes `+` over `min`, collects terms, and applies ACI deduplication on the resulting `min`-of-monomials. The ACI normalizer from this work handles the final deduplication step.

**Cross-domain impact**: Enables certified comparison of tropical polynomials, with applications to tropical geometry (hypersurface computation), optimization (LP relaxations), and compiler intermediate representations.

---

## 3. Certified Equivalence for Weighted Automata over Tropical Semirings

**Goal**: Use ACI normalization as a preprocessing step for deciding equivalence of weighted automata expressions over the min-plus semiring.

**Theorem target**:
```
theorem weighted_automaton_equiv_decidable
    (A B : WeightedAutomaton ℝ) (h : language_equiv A B) :
    ∀ w : List Σ, weight A w = weight B w
```

**Approach**: Weighted automata over (ℝ, min, +) compute shortest-path weights. Their algebraic expressions involve `min` (nondeterminism) and `+` (sequential composition). ACI normalization eliminates redundant paths (duplicate `min` branches). Combined with Kleene-star expansion and distributivity normalization, this yields a decision procedure for bounded-depth equivalence.

**Connection to this work**: The `normalize_aci_strictly_stronger` theorem shows that ACI normalization collapses genuinely more expressions than AC alone—exactly the redundancies arising from path duplication in weighted automata.

---

## 4. Tropical Polynomial Support Normalization and Hypersurface Invariance

**Goal**: Prove that ACI-normalized tropical polynomials compute the same tropical hypersurface (the locus where the minimum is achieved by at least two terms).

**Theorem target**:
```
theorem tropical_hypersurface_invariant (p q : TropPoly)
    (h : normalize_aci_poly p = normalize_aci_poly q) :
    tropical_hypersurface p = tropical_hypersurface q
```

**Approach**: A tropical hypersurface `V(p)` is the set of points where the minimum in `p` is achieved by ≥ 2 monomials. Since ACI normalization preserves the set of monomials (removing only duplicates, which don't affect the achieving set), the hypersurface is invariant. The formal proof uses `eval_eq_of_normalize_aci_eq` to show pointwise equality, then derives hypersurface equality.

**Significance**: This connects symbolic normalization to geometric invariants, opening the door to certified tropical intersection theory.

---

## 5. Reflective Tactic for Semilattice/Idempotent-Semiring Equalities

**Goal**: Package the ACI decision procedure as a reflective tactic that automatically discharges goals of the form `min(a, min(a, b)) = min(a, b)` or more complex semilattice equalities.

**Implementation sketch**:
```
/-- Tactic that normalizes both sides of a min-equality using ACI normalization
    and checks syntactic equality of normal forms. -/
macro "aci_norm" : tactic => ...
```

**Approach**: Use the `normalize_aci_eq_iff_aci` theorem as the soundness certificate. The tactic:
1. Reifies the goal into `TropExpr` syntax
2. Applies `normalize_aci` to both sides
3. Checks `DecidableEq` on normal forms
4. Uses `eval_eq_of_normalize_aci_eq` to close the goal

**Impact**: Provides push-button automation for min/max/lattice identities throughout Mathlib and downstream projects. This is the most immediate practical payoff of the formalization.

---

## Cross-Cutting Theme

All five directions share a common architecture: **certified normalization as a bridge between syntax and semantics**. The ACI normalizer proved here is the seed crystal for this architecture. Each direction extends it along a different axis—generality (1), algebraic depth (2, 4), computational complexity (3), or automation (5)—while preserving the core invariant: normalization is sound, complete, and idempotent.
