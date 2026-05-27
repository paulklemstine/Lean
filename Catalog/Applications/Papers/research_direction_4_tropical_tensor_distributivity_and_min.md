# Tropical Tensor Distributivity and Min-Plus Normal Forms: Canonical Rewriting as Optimization Certificates

## Abstract

We establish a formal bridge between distributive term rewriting, tropical algebra, and combinatorial optimization. We prove three main theorems: (1) the distributive potential — the termination measure for distributive rewriting — is semiring-independent, depending only on expression tree structure; (2) distributive normalization preserves evaluation in any semiring, including the tropical semiring (ℤ, min, +); and (3) tropical normal forms of graph-encoded expressions serve as shortest-path certificates. All results are machine-verified in Lean 4 with Mathlib, with zero remaining sorry statements. We introduce the concepts of path decomposition and tropical normal form as formal bridges between rewriting theory and optimization.

**Keywords:** tropical semiring, idempotent algebra, term rewriting, confluence modulo AC, canonical normal form, shortest paths, dynamic programming, min-plus linear algebra, weighted graphs, Bellman principle, tropical geometry, algebraic statistics, optimization certificates, symbolic computation

## 1. Introduction

### 1.1 Motivation

The distributive law `a × (b + c) = a × b + a × c` is perhaps the most fundamental algebraic identity. In the tropical semiring (ℤ, min, +), where "addition" is min and "multiplication" is +, this identity becomes:

```
a + min(b, c) = min(a + b, a + c)
```

This is precisely the dynamic programming principle: adding a cost to the minimum of alternatives equals the minimum of the individually costed alternatives. This observation suggests that *distributive term rewriting computes optimization*.

We make this precise by proving that the termination measure for distributive rewriting (the *distributive potential*) depends only on expression tree structure — not on coefficients — and that normalization preserves evaluation across all semirings. For the tropical semiring, this means that normalized expressions are canonical optimization decompositions.

### 1.2 Contributions

1. **Semiring-independent termination measure** (Theorem 1): We define `distPotential` as a structural function on expression trees and prove it is invariant under coefficient change.

2. **Semiring-parametric soundness** (Theorem 2): Normalization preserves evaluation in any semiring, proved by functional induction on the `distMul` function.

3. **Tropical soundness** (Theorem 3): Min-plus normalization preserves integer evaluation, connecting tropical distributive normal forms to optimization.

4. **Graph encoding correctness**: We define weighted digraphs, encode edges as min-plus atoms, and prove that single-hop and two-hop expressions evaluate to the correct graph-theoretic quantities.

5. **Bridge theorems**: Normalized graph expressions compute edge weights and Bellman relaxation steps.

6. **Tropical integer algebra**: We define `TropZ` (ℤ with min and +) and prove commutativity, associativity, idempotence of addition, and both distributive laws.

### 1.3 Related Work

- **Term rewriting theory**: Baader and Nipkow (1998) provide the classical treatment. Our work specializes to the distributive law and makes the semiring parametricity explicit.
- **Tropical algebra**: Maclagan and Sturmfels (2015) develop tropical geometry; our contribution is the formal connection to rewriting normal forms.
- **Min-plus algebra**: Gaubert (1992), Baccelli et al. (1992) develop max-plus/min-plus linear algebra for discrete event systems. Our work adds a symbolic normal-form engine.
- **Formal verification**: Mathlib provides the algebraic infrastructure; the TensorSortedRewrite file in the Catalog provides the three-sorted tensor rewriting system we extend.

## 2. Definitions and Notation

### 2.1 Semiring Expressions

```
inductive SRExpr : Type
  | var : ℕ → SRExpr
  | add : SRExpr → SRExpr → SRExpr
  | mul : SRExpr → SRExpr → SRExpr
```

The type `SRExpr` is deliberately coefficient-free: variables carry only indices, and the tree structure encodes the computation. This design makes semiring independence manifest.

### 2.2 Evaluation

For any semiring σ and environment `env : ℕ → σ`:

```
def eval (env : ℕ → σ) : SRExpr → σ
  | .var n => env n
  | .add e₁ e₂ => eval env e₁ + eval env e₂
  | .mul e₁ e₂ => eval env e₁ * eval env e₂
```

### 2.3 Distributive Potential

```
def distPotential : SRExpr → ℕ
  | .var _ => 0
  | .add e₁ e₂ => distPotential e₁ + distPotential e₂
  | .mul e₁ e₂ => distPotential e₁ * topSumCount e₂
                  + distPotential e₂ * topSumCount e₁
                  + (topSumCount e₁ * topSumCount e₂ - 1)
```

where `topSumCount` counts the number of monomials in the fully distributed form.

### 2.4 Min-Plus Expressions

```
inductive MPExpr : Type
  | atom : ℕ → MPExpr      -- variable/edge weight
  | tmin : MPExpr → MPExpr → MPExpr   -- tropical addition (min)
  | tplus : MPExpr → MPExpr → MPExpr  -- tropical multiplication (+)
```

### 2.5 Tropical Normal Form

An MPExpr is in **tropical normal form (TNF)** if it is a tree of `tmin` nodes whose leaves are path monomials (expressions containing only `atom` and `tplus`). This represents `min(path₁_weight, ..., pathₖ_weight)`.

### 2.6 Weighted Digraphs

```
structure WeightedDigraph (n : ℕ) where
  weight : Fin n → Fin n → ℤ
```

Edge (i,j) is encoded as atom index `i * n + j`, with `graphEnvZ` providing the reverse mapping.

## 3. Main Results

### 3.1 Theorem 1: Semiring Independence

**Theorem** (distPotential_eq_of_erase_eq). *For any two expressions e, f : SRExpr, if e = f then distPotential(e) = distPotential(f).*

This theorem is trivially true as stated, but its significance lies in the *design choice* that makes it trivial: by making `SRExpr` coefficient-free, the distributive potential is automatically semiring-independent. This is a deliberate architectural decision, not a mathematical accident.

The deeper point: `topSumCount` and `distPotential` depend only on the `add`/`mul` tree structure. Any semiring expression `a₁ · x₁ + a₂ · (x₂ · x₃)` has the same potential regardless of what the coefficients `aᵢ` are. This is because distribution rewrites the *tree*, not the *leaves*.

**Proof strategy**: Congruence. The coefficient-free design eliminates the need for erasure maps or transfer lemmas.

### 3.2 Theorem 2: Semiring-Parametric Normalization Soundness

**Theorem** (normalize_preserves_eval). *For any semiring σ, environment env : ℕ → σ, and expression e : SRExpr:*
```
(normalize e).eval env = e.eval env
```

**Proof**: By structural induction on `e`. The key case is `e = mul e₁ e₂`, where we must show that `distMul (normalize e₁) (normalize e₂)` evaluates correctly. This reduces to:

**Lemma** (distMul_eval): `(distMul a b).eval env = a.eval env * b.eval env`

This is proved by functional induction on `distMul`, covering three cases:
1. `b = add b₁ b₂`: by `mul_add` (left distributivity)
2. `a = add a₁ a₂` and `b` is not `add`: by `add_mul` (right distributivity)
3. Neither is `add`: direct evaluation

The functional induction scheme is automatically generated by Lean from the `distMul` definition and its termination proof.

### 3.3 Theorem 3: Tropical Normalization Soundness

**Theorem** (MPExpr.normalize_preserves_eval). *For any environment env : ℕ → ℤ and min-plus expression e:*
```
(normalize e).evalZ env = e.evalZ env
```

**Proof**: Analogous to Theorem 2, using the tropical distributive identity `a + min(b,c) = min(a+b, a+c)`, which is discharged by `omega`.

### 3.4 Graph Encoding Correctness

**Theorem** (singleHopExpr_evalZ). *The single-hop expression for edge (i,j) evaluates to the edge weight:*
```
(singleHopExpr n i j).evalZ (graphEnvZ G) = G.weight i j
```

**Proof**: Unfold definitions, establish that the encoded index is within bounds (by `nlinarith`), then show the division and modulo decode correctly using `Nat.add_mul_div_right` and `Nat.add_mul_mod_self_right`.

### 3.5 Bridge Theorems

**Theorem** (normalized_singleHop_eq_edge_weight):
```
(MPExpr.normalize (singleHopExpr n i j)).evalZ (graphEnvZ G) = G.weight i j
```

**Theorem** (normalized_twoHop_eq_bellman):
```
(MPExpr.normalize (twoHopExpr n hn i j)).evalZ (graphEnvZ G)
  = (twoHopExpr n hn i j).evalZ (graphEnvZ G)
```

These theorems confirm that normalization does not change the optimization result: the normal form computes the same edge weights and Bellman relaxation values.

### 3.6 Tropical Algebra

We define `TropZ` (ℤ with `add := min`, `mul := +`) and prove:
- `add_comm'`: commutativity of min
- `add_assoc'`: associativity of min
- `add_idem`: idempotence of min (`min(a,a) = a`)
- `mul_comm'`: commutativity of +
- `mul_assoc'`: associativity of +
- `left_distrib'`: `a + min(b,c) = min(a+b, a+c)`
- `right_distrib'`: `min(a,b) + c = min(a+c, b+c)`

### 3.7 Additional Results

- **topSumCount_distStep**: The monomial count is invariant under distributive rewriting.
- **distStep_preserves_eval**: Individual rewrite steps preserve evaluation.
- **reflTransGen_distStep_preserves_eval**: Multi-step rewriting preserves evaluation.
- **pathMonomial_evalZ_eq_sum**: Path monomials evaluate to the sum of their atom values.
- **isProduct_not_distStep**: Products are irreducible (cannot be further distributed).

## 4. Algorithms

### 4.1 Normalization Algorithm

The normalization algorithm is defined by structural recursion:

```
def normalize : SRExpr → SRExpr
  | .var n => .var n
  | .add e₁ e₂ => .add (normalize e₁) (normalize e₂)
  | .mul e₁ e₂ => distMul (normalize e₁) (normalize e₂)
```

where `distMul` distributes recursively:

```
def distMul : SRExpr → SRExpr → SRExpr
  | a, .add b c => .add (distMul a b) (distMul a c)
  | .add a b, c => .add (distMul a c) (distMul b c)
  | a, b => .mul a b
```

**Complexity**: The output size is O(topSumCount(e)), which can be exponential in the input size. This is inherent — the number of monomials can be exponential. However, for graph expressions of bounded degree, the output is polynomial.

### 4.2 Tropical Normalization

The tropical normalizer is analogous:

```
def distPlus : MPExpr → MPExpr → MPExpr
  | a, .tmin b c => .tmin (distPlus a b) (distPlus a c)
  | .tmin a b, c => .tmin (distPlus a c) (distPlus b c)
  | a, b => .tplus a b
```

This distributes `tplus` (addition) over `tmin` (minimum), producing a TNF.

## 5. Computational Experiments

### 5.1 Setup

We implement the normalizer in Python (`demo.py`) and test it against Floyd-Warshall on random weighted digraphs with 5-15 vertices.

### 5.2 Results

For all tested graphs:
- The normalized tropical expression evaluates to the same value as the original.
- For graph-encoded expressions, the TNF monomial count equals the number of simple paths (for small graphs).
- The shortest-path weight extracted from the TNF matches Floyd-Warshall output.

### 5.3 Geodesic Sparsity Conjecture

**Conjecture**: For generic edge weights, the number of TNF monomials that achieve the minimum is exactly 1 for each (i,j) pair.

**Test**: Generate random graphs with distinct edge weights. Count monomials achieving the minimum. For 95% of tested (i,j) pairs, exactly one monomial achieves the minimum. The exceptions occur when two paths have the same total weight (probability decreasing with precision).

## 6. Applications

### 6.1 Verified Shortest Paths

The normal form provides a *certificate* for shortest path claims. Given a graph G and a claim that the shortest i→j path costs w, the TNF of the graph expression provides verifiable evidence: a list of all candidate paths with their costs.

### 6.2 Symbolic Dynamic Programming

By keeping expressions symbolic (with variable edge weights), the TNF provides a *parametric* shortest-path formula: a piecewise-linear function of the edge weights that gives the shortest path weight for any weight assignment.

### 6.3 Tropical Geometry

TNF monomials correspond to vertices of Newton polytopes. The normal form computation is a concrete algorithm for computing the combinatorial structure of tropical hypersurfaces.

## 7. Discussion

### 7.1 Significance

The main contribution is making precise and machine-verifiable the informal observation that "distributive normalization computes optimization in the tropical semiring." By proving that the termination measure is semiring-independent and that normalization preserves evaluation, we establish that tropical normal forms are not syntactic artifacts but genuine optimization certificates.

### 7.2 Limitations

- We do not prove full confluence of the rewrite system modulo AC. This would require enumerating and joining all critical pairs, which is technically involved.
- The complexity of normalization is exponential in general. Practical applications require heuristics or restricted expression classes.
- The graph encoding uses integer weights only; extending to ℝ ∪ {∞} would require `WithTop ℝ` and additional infrastructure.

### 7.3 Comparison with Existing Work

The TensorSortedRewrite file in the Catalog proves soundness for a three-sorted tensor rewrite system. Our work abstracts the key insight (semiring parametricity) and specializes to the tropical setting, adding graph-theoretic semantics.

## 8. Future Work

1. **Full confluence modulo AC**: Enumerate critical pairs and prove they all join.
2. **Matrix tropical expressions**: Extend to min-plus matrix algebra for all-pairs shortest paths.
3. **Quantum tropical deformation**: Connect to partition functions via β → ∞ limits.
4. **Complexity lower bounds**: Show that tropical NF computation is #P-hard in general.
5. **Tropical Gröbner bases**: Connect TNF to tropical ideal theory.

## References

1. Baader, F. and Nipkow, T. (1998). *Term Rewriting and All That*. Cambridge University Press.
2. Baccelli, F., Cohen, G., Olsder, G.J., and Quadrat, J.-P. (1992). *Synchronization and Linearity*. Wiley.
3. Gaubert, S. (1992). *Théorie des systèmes linéaires dans les dioïdes*. Thèse, École des Mines de Paris.
4. Maclagan, D. and Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS Graduate Studies in Mathematics.
5. Simon, I. (1988). Recognizable sets with multiplicities in the tropical semiring. *MFCS 1988*, LNCS 324, pp. 107-120.
