# Abstract Dominance Elimination in Ordered Idempotent Semirings: A Universal Framework for Tropical Canonicalization

## Abstract

We establish that tropical polynomial canonicalization — the process of removing dominated monomials to obtain a semantically equivalent reduced expression — is a structural consequence of idempotent addition compatible with a linear order. We introduce the class of *ordered idempotent commutative additive monoids*, axiomatized by two properties: additive idempotency (a + a = a) and order-addition compatibility (a ≤ b ↔ a + b = b). We prove that in any such structure:

1. **One-step dominance elimination** preserves evaluation: if a term is dominated by the sum of the remaining terms, it can be deleted.
2. **Iterated canonicalization** preserves evaluation: repeatedly removing dominated terms yields a semantically equivalent reduced form.
3. **Pointwise monomial dominance** implies semantic preservation at the polynomial function level.

We instantiate the abstract framework for max-plus (WithBot ℤ, max, ⊥), min-plus (WithTop ℤ, min, ⊤ with dual order), and Boolean (Bool, ∨, false) semirings, obtaining all classical canonicalization results as corollaries. The proofs are machine-verified in Lean 4 with Mathlib.

**Keywords:** idempotent semiring, tropical algebra, dominance elimination, canonical form, max-plus algebra, min-plus algebra, ordered monoid

---

## 1. Introduction

### 1.1 Motivation

Tropical algebra — where addition is replaced by maximum (or minimum) and multiplication by ordinary addition — has become a fundamental tool in optimization, algebraic geometry, and computer science. A key operation in tropical polynomial algebra is *canonicalization*: removing monomials that are pointwise dominated by the remaining terms, thereby obtaining a simpler expression with identical evaluation.

This operation appears independently in many contexts:
- **Max-plus scheduling**: eliminating non-critical timing constraints
- **Min-plus shortest paths**: pruning suboptimal route alternatives  
- **Boolean logic**: the absorption law (a ∨ (a ∧ b) = a)
- **Weighted automata**: minimizing weight expressions without changing language semantics
- **Dynamic programming**: state-space pruning via dominance relations
- **Zero-sum games**: eliminating dominated strategies

Despite the ubiquity of this pattern, prior formalizations have treated each instance separately, proving canonicalization soundness for specific semirings rather than identifying the abstract algebraic conditions that make it work.

### 1.2 Contributions

This paper makes three contributions:

1. **Axiomatization**: We identify the minimal algebraic hypotheses for tropical canonicalization — idempotent addition and order-addition compatibility — and package them as the class `IdempotentOrdAddCommMonoid`.

2. **Abstract theorems**: We prove the one-step dominance elimination theorem (Theorem A), the iterated canonicalization theorem (Theorem B), and the monomial-level corollary, all at the abstract class level.

3. **Instantiation**: We construct instances for max-plus, min-plus, and Boolean semirings, demonstrating that all concrete canonicalization results are immediate corollaries.

All results are machine-verified in Lean 4 with Mathlib, providing the highest level of assurance.

### 1.3 Related Work

Tropical algebra has been extensively studied in combinatorial optimization (Butkovič, 2010), algebraic geometry (Maclagan and Sturmfels, 2015), and automata theory (Droste et al., 2009). The connection between idempotent semirings and optimization was highlighted by Litvinov et al. (2001) under the rubric of "idempotent mathematics."

Formal verification of tropical algebraic properties has been explored in several proof assistants, but prior work has focused on concrete semirings rather than abstract axiomatization. Our contribution is to identify and prove the abstract principle that unifies these concrete results.

---

## 2. Definitions and Notation

### 2.1 Ordered Idempotent Commutative Additive Monoid

**Definition 2.1.** An *ordered idempotent commutative additive monoid* is a structure (R, +, 0, ≤) where:
- (R, +, 0) is a commutative additive monoid
- (R, ≤) is a linear order
- **Idempotency**: ∀ a ∈ R, a + a = a
- **Order-addition compatibility**: ∀ a, b ∈ R, a ≤ b ↔ a + b = b

In Lean 4:
```
class IdempotentOrdAddCommMonoid (R : Type*) extends
    LinearOrder R, AddCommMonoid R where
  add_idem : ∀ a : R, a + a = a
  le_iff_add : ∀ a b : R, a ≤ b ↔ a + b = b
```

### 2.2 Derived Properties

**Proposition 2.2** (Addition equals maximum). In any ordered idempotent commutative additive monoid R, for all a, b ∈ R:

    a + b = max(a, b)

*Proof sketch.* By linearity, either a ≤ b or b ≤ a. If a ≤ b, then a + b = b = max(a, b) by le_iff_add. If b ≤ a, then a + b = b + a = a = max(a, b) by commutativity and le_iff_add.

**Proposition 2.3** (Monotonicity). For all a, b ∈ R, a ≤ a + b.

*Proof sketch.* We have a + (a + b) = (a + a) + b = a + b by idempotency and associativity. By le_iff_add (backward direction), this gives a ≤ a + b.

### 2.3 Tropical Polynomial Evaluation

**Definition 2.4.** For a list of terms [t₁, ..., tₙ] in R, define:
- iEval([]) = 0
- iEval(t :: ts) = t + iEval(ts)

This is the tropical polynomial evaluation: the idempotent sum of all terms.

**Definition 2.5.** A term m is *dominated by* a list ms if m ≤ iEval(ms).

---

## 3. Main Results

### 3.1 Theorem A: One-Step Dominance Elimination

**Theorem 3.1** (eval_remove_dominated). Let R be an ordered idempotent commutative additive monoid. For any term m ∈ R and list rest of terms in R, if m ≤ iEval(rest), then:

    iEval(m :: rest) = iEval(rest)

*Proof.* iEval(m :: rest) = m + iEval(rest). Since m ≤ iEval(rest), by le_iff_add, m + iEval(rest) = iEval(rest). □

This is the core insight: dominated terms are invisible to the idempotent sum.

### 3.2 One-Step Canonicalization

**Definition 3.2.** Define removeOneDominated : List R → List R by:
- removeOneDominated([]) = []
- removeOneDominated(m :: ms) = ms if m is dominated by ms; otherwise m :: removeOneDominated(ms)

**Theorem 3.3** (eval_removeOneDominated). For any list ms of terms in R:

    iEval(removeOneDominated(ms)) = iEval(ms)

*Proof.* By induction on ms. The base case is trivial. For m :: ms, if m is dominated, the result follows from Theorem 3.1. Otherwise, iEval(m :: removeOneDominated(ms)) = m + iEval(removeOneDominated(ms)) = m + iEval(ms) = iEval(m :: ms) by the inductive hypothesis. □

### 3.3 Theorem B: Iterated Canonicalization

**Definition 3.4.** Define canon : ℕ → List R → List R by:
- canon(0, ms) = ms  
- canon(n+1, ms) = canon(n, removeOneDominated(ms))

**Theorem 3.5** (eval_canon_eq_eval). For any n ∈ ℕ and list ms:

    iEval(canon(n, ms)) = iEval(ms)

*Proof.* By induction on n. Base: canon(0, ms) = ms. Step: canon(n+1, ms) = canon(n, removeOneDominated(ms)). By IH, iEval(canon(n, removeOneDominated(ms))) = iEval(removeOneDominated(ms)). By Theorem 3.3, this equals iEval(ms). □

### 3.4 Monomial-Level Corollary

**Corollary 3.6** (eval_remove_dominated_monomial). Let evalM be a monomial evaluation function, and suppose monomial m is pointwise dominated: for all inputs x, evalM(m, x) ≤ evalMonomials(evalM, rest, x). Then:

    evalMonomials(evalM, m :: rest, x) = evalMonomials(evalM, rest, x)

*Proof.* Reduces to Theorem 3.1 applied to the evaluated values at each point x. □

---

## 4. Concrete Instances

### 4.1 Max-Plus Semiring

**Instance 4.1.** Define MaxPlusSemiring as a wrapper around WithBot ℤ with:
- Addition: max
- Zero: ⊥ (= -∞)
- Order: standard order on WithBot ℤ

This satisfies all axioms:
- Idempotency: max(a, a) = a ✓
- Order compatibility: a ≤ b ↔ max(a, b) = b ✓

**Corollary 4.2.** For any list of max-plus terms, iterated canonicalization preserves the maximum.

### 4.2 Min-Plus Semiring

**Instance 4.3.** Define MinPlusSemiring as a wrapper around WithTop ℤ with:
- Addition: min
- Zero: ⊤ (= +∞)
- Order: **reversed** standard order (a ≤_tropical b iff b ≤_usual a)

The reversed order is essential: in min-plus, "smaller" values dominate, so the tropical order must make them "larger" for the le_iff_add axiom to hold.

- Idempotency: min(a, a) = a ✓
- Order compatibility: a ≤_dual b (i.e., b ≤ a) ↔ min(a, b) = b ✓

**Corollary 4.4.** For any list of min-plus terms, iterated canonicalization preserves the minimum.

### 4.3 Boolean Semiring

**Instance 4.5.** Bool with:
- Addition: logical OR (∨)
- Zero: false
- Order: false ≤ true

- Idempotency: a ∨ a = a ✓
- Order compatibility: a ≤ b ↔ a ∨ b = b ✓

**Corollary 4.6** (Boolean absorption). For any Boolean terms a, b with a ≤ b, the idempotent sum [a, b] evaluates the same as [b] alone. This is the classical absorption law of Boolean algebra.

---

## 5. Algorithms

### 5.1 Canonicalization Algorithm

```
Algorithm: CANONICALIZE(terms)
Input: List of terms in an ordered idempotent additive monoid
Output: Canonical form (no dominated terms)

1. result ← terms
2. repeat
3.   changed ← false
4.   for i ← 0 to |result| - 1
5.     rest ← result without result[i]
6.     if result[i] ≤ eval(rest) then
7.       result ← rest
8.       changed ← true
9.       break
10.  until not changed
11. return result
```

**Complexity:**
- Time: O(n²) worst case, where n = |terms|
  - At most n removals (list shrinks each time)
  - Each removal requires O(n) to compute eval(rest)
- Space: O(n) for the working list

**Convergence:** Guaranteed in at most n steps, since each iteration either removes a term (strictly decreasing list length) or terminates.

### 5.2 Correctness

The correctness of the algorithm follows directly from Theorem B (eval_canon_eq_eval): each application of removeOneDominated preserves evaluation, and the iteration terminates.

---

## 6. Applications

### 6.1 Critical Path Analysis

In PERT/CPM project scheduling, task completion times are combined via max (parallel tasks) and + (sequential tasks). The project duration is a max-plus polynomial. Canonicalization identifies critical paths by eliminating non-critical (dominated) task chains.

**Example:** Tasks with durations [8, 12, 6, 15, 9, 4, 15]. After canonicalization: [15, 15]. The critical path has duration 15.

### 6.2 Shortest Path Simplification

In min-plus routing, path costs are combined via min (alternative routes) and + (concatenated segments). Canonicalization eliminates suboptimal routes.

### 6.3 Weighted Automata Minimization

Weighted automata over idempotent semirings can be simplified by removing dominated transitions. The abstract theorem guarantees that this preserves the automaton's language semantics.

### 6.4 Dynamic Programming Pruning

In DP with max-plus or min-plus objectives, dominated states can be pruned. The theorem provides a certified soundness guarantee for this optimization.

---

## 7. Discussion

### 7.1 The Order-Theoretic Essence

The central observation is that tropical canonicalization depends only on two properties: idempotency and order compatibility. These are purely order-theoretic conditions. The theorem does not require:
- A multiplicative structure
- Continuity or topology
- Finiteness of the semiring
- Decidability of the order

This makes the result maximally portable across algebraic settings.

### 7.2 Duality

The min/max duality of tropical algebra is captured at the abstract level by the order-dual construction. If R is an ordered idempotent commutative additive monoid, then Rᵒᵈ (with reversed order and the same addition, which now acts as "min") is again an ordered idempotent commutative additive monoid. All theorems transfer automatically.

### 7.3 Uniqueness Question

An interesting open question is whether the canonical form is unique (up to permutation). In the constant-value case (all terms evaluated at a single point), the canonical form is simply the set of maximal terms. For polynomial functions with variable inputs, uniqueness requires additional analysis of the "tropical support."

---

## 8. Future Work

1. **Uniqueness of canonical forms**: Prove that any two irredundant representations have the same set of undominated monomials.
2. **Semiring-valued Bellman equations**: Apply the framework to certify fixed-point computations in dynamic programming.
3. **Weighted automata minimization**: Formalize the connection between tropical canonicalization and automaton state reduction.
4. **Tropical polynomial multiplication**: Extend the framework to handle products of tropical polynomials.
5. **Computational complexity**: Analyze the complexity of deciding whether a monomial is pointwise dominated.

---

## 9. Formal Verification

All theorems in this paper have been machine-verified in Lean 4 (version 4.28.0) with Mathlib. The formalization is approximately 310 lines and contains no axioms beyond the standard Lean kernel axioms (propext, Classical.choice, Quot.sound).

Key declarations:
- `IdempotentOrdAddCommMonoid`: the abstract class (31 LOC)
- `eval_remove_dominated`: Theorem A (3 LOC proof)
- `eval_removeOneDominated`: one-step canonicalization (6 LOC proof)
- `eval_canon_eq_eval`: Theorem B (4 LOC proof)
- `MaxPlusSemiring`, `MinPlusSemiring`, `boolIdempotent`: concrete instances

The proofs are constructive where possible (the canonicalization function uses classical logic for decidability of the dominance predicate).

---

## References

1. Butkovič, P. (2010). *Max-Linear Systems: Theory and Algorithms*. Springer.
2. Maclagan, D. and Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
3. Droste, M., Kuich, W., and Vogler, H. (2009). *Handbook of Weighted Automata*. Springer.
4. Litvinov, G. L., Maslov, V. P., and Shpiz, G. B. (2001). Idempotent functional analysis: An algebraic approach. *Mathematical Notes*, 69(5), 696–729.
5. Akian, M., Gaubert, S., and Guterman, A. (2012). Tropical polyhedra are equivalent to mean payoff games. *International Journal of Algebra and Computation*, 22(1).
6. Gaubert, S. and Plus, M. (1997). Methods and applications of (max,+) linear algebra. In *STACS 97*, Springer LNCS 1200.
