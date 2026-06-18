# Future Directions: From ACI Canonicalization to a Tropical Algebra Engine

This document outlines five breakthrough-level research directions opened by the certified ACI normalization for tropical min expressions. Each direction includes specific theorem targets, proof strategies, and cross-domain connections.

---

## 1. Free Idempotent Commutative Semiring Normalization

**Goal:** Extend ACI normalization from `min` alone to the full tropical semiring with both `min` and `+`.

### The Challenge
The full tropical semiring $\mathbb{T} = (\mathbb{R}, \min, +)$ satisfies an additional identity beyond ACI:
$$
a + \min(b, c) = \min(a + b, a + c) \quad \text{(distributivity)}
$$

This means `min(x+y, x+z)` should normalize to `x + min(y, z)`. The canonical form must handle the interaction between the two operations.

### Theorem Targets
```
-- Full tropical expression type
inductive TropExpr
  | var : ℕ → TropExpr
  | tmin : TropExpr → TropExpr → TropExpr
  | tadd : TropExpr → TropExpr → TropExpr

-- Full tropical equivalence (ACI + distributivity)
inductive TropEquiv : TropExpr → TropExpr → Prop

-- Extended normalizer
def normalizeTrop : TropExpr → TropExpr

-- Canonicity theorem
theorem normalizeTrop_decides :
    ∀ e₁ e₂, TropEquiv e₁ e₂ ↔ normalizeTrop e₁ = normalizeTrop e₂
```

### Proof Strategy
1. Represent tropical expressions as formal sums of products: $\min(\sum a_{i1}, \sum a_{i2}, \ldots)$.
2. Normalize each product using AC for `+` (already handled in the existing codebase).
3. Normalize the outer `min` using ACI (our contribution).
4. Apply distributivity to factor out common prefixes.
5. Show this yields a canonical form (the "tropical normal form" of Maclagan-Sturmfels).

### Cross-Domain Impact
- **Tropical Gröbner bases**: Canonical forms are the foundation for tropical analogues of polynomial division.
- **Optimization**: Certified simplification of min-plus recurrences in dynamic programming.
- **Quantum computing**: Tropical semirings appear in the semiclassical limit of quantum amplitudes.

---

## 2. Canonical Tropical Polynomial Forms

**Goal:** Prove that duplicate tropical monomials can be eliminated without changing the tropical hypersurface, and formalize the canonical representative.

### Mathematical Background
A tropical polynomial in $n$ variables is $p(x_1, \ldots, x_n) = \min_i(a_i + \sum_j b_{ij} x_j)$ where each term $a_i + \sum_j b_{ij} x_j$ is an affine-linear function. The **tropical hypersurface** $V(p)$ is the set of points where the minimum is achieved by at least two terms.

**Key fact:** Duplicate monomials (identical coefficient vectors) do not affect $V(p)$.

### Theorem Targets
```
-- Tropical monomial and polynomial representation
structure TropMonomial (n : ℕ) where
  coeff : ℝ
  exponents : Fin n → ℝ

def TropPoly (n : ℕ) := Finset (TropMonomial n)

-- Evaluation
def TropPoly.eval (p : TropPoly n) (x : Fin n → ℝ) : ℝ :=
  p.inf' (fun m => m.coeff + ∑ i, m.exponents i * x i)

-- Canonical form preserves evaluation
theorem canonical_tropical_poly_eval :
    ∀ (p : TropPoly n) (x : Fin n → ℝ),
      (canonicalize p).eval x = p.eval x
```

### Proof Strategy
Use our ACI normalization as the inner engine: represent a tropical polynomial as a `tmin` expression over monomial-labeled leaves, then apply ACI canonicalization to remove duplicate monomials.

---

## 3. Reflective Decision Tactic (`norm_tropical`)

**Goal:** Implement a tactic that automatically decides ACI equivalence of tropical expressions within proofs.

### Architecture
```
-- Reflection principle
theorem aci_reflection (e₁ e₂ : Expr) :
    normalizeACI e₁ = normalizeACI e₂ → ACIEquiv e₁ e₂

-- Tactic usage
example : ACIEquiv (tmin x (tmin x y)) (tmin y x) := by
  norm_tropical  -- automatically reduces to normalizeACI comparison
```

### Implementation Plan
1. **Reification**: Convert the goal's expression into the `Expr` AST using `Qq` or template metaprogramming.
2. **Computation**: Evaluate `normalizeACI` on both sides using `native_decide` or kernel reduction.
3. **Certificate**: Apply `normalizeACI_reflects` to close the goal.
4. **Integration**: Register as a `simp` extension for seamless use.

### Cross-Domain Impact
- **Proof automation**: Eliminates manual ACI reasoning in tropical algebra proofs.
- **Verified compilation**: Can be used to certify optimizations in min-plus compilers.
- **Education**: Makes tropical algebra accessible in interactive theorem provers.

---

## 4. Finite-Set Semantics Theorem (Free Semilattice Representation)

**Goal:** Formally prove that the ACI-equivalence classes of `tmin` expressions form the free meet-semilattice over the set of variables.

### Mathematical Statement
Let $\text{Expr}_V$ be the set of expressions over variables $V$. Then:
$$
\text{Expr}_V / {\equiv_{\text{ACI}}} \cong (\mathcal{P}_{\text{fin}}^+(V), \cup)
$$

where $\mathcal{P}_{\text{fin}}^+(V)$ is the collection of non-empty finite subsets of $V$, and $\cup$ is set union.

### Theorem Targets
```
-- The quotient type
def ACIQuotient := Quotient (ACIEquiv.setoid)

-- The isomorphism
def toFinset : ACIQuotient → Finset ℕ
def fromFinset : Finset ℕ → ACIQuotient

-- Bijection
theorem toFinset_fromFinset : ∀ S, S.Nonempty → toFinset (fromFinset S) = S
theorem fromFinset_toFinset : ∀ q, fromFinset (toFinset q) = q

-- Homomorphism
theorem toFinset_tmin : ∀ q₁ q₂,
    toFinset (q₁ ⊔ q₂) = toFinset q₁ ∪ toFinset q₂
```

### Significance
This upgrades our normalization from a syntactic algorithm to a **representation theorem**. It says that tropical `min` normalization is not merely a clever rewriting trick, but a manifestation of a fundamental algebraic structure: the free semilattice.

---

## 5. Optimization Certification: Shortest-Path Derivation Verification

**Goal:** Use the ACI normalizer to certify redundancy elimination in shortest-path and dynamic-programming derivations.

### Application
In Floyd-Warshall, Bellman-Ford, and Viterbi-style algorithms, intermediate computations produce redundant `min` terms. The ACI normalizer can:
1. Verify that an optimization step is correct (the simplified expression is ACI-equivalent to the original).
2. Certify that a "pruned" computation tree produces the same result as the full tree.
3. Bound the size of canonical forms to establish complexity guarantees.

### Theorem Targets
```
-- Floyd-Warshall relaxation step
def relax (d : Matrix (Fin n) (Fin n) Expr) (k : Fin n) :
    Matrix (Fin n) (Fin n) Expr :=
  fun i j => tmin (d i j) (tadd (d i k) (d k j))

-- Relaxation preserves ACI class
theorem relax_aci_invariant :
    ∀ d k, ∀ i j,
      ACIEquiv (normalizeACI (relax d k i j))
               (normalizeACI (relax (normalizeACI ∘ d) k i j))

-- Size bound
theorem normalizeACI_size_bound (e : Expr) :
    (normalizeACI e).size ≤ 2 * (leafFinset e).card - 1
```

### Cross-Domain Impact
- **Certified compilers**: Verify that compiler optimizations for min-plus programs are sound.
- **Hardware verification**: Timing analysis tools can certify that critical-path computations are correct.
- **AI safety**: Verified optimization in planning algorithms for autonomous systems.

---

## Research Team Directive

Each direction should be pursued as follows:

1. **Hypothesis**: State the core conjecture as a formal theorem.
2. **Decomposition**: Break into 5–10 independent helper lemmas.
3. **Validation**: Test with concrete examples using `#eval` before committing to proofs.
4. **Iteration**: If a lemma fails, decompose further or try alternative proof strategies.
5. **Integration**: Ensure new results build on and extend the existing ACI infrastructure.

The goal is to build a formal tropical algebra engine — not a one-off simplifier, but a reusable, extensible, verified foundation for tropical mathematics.
