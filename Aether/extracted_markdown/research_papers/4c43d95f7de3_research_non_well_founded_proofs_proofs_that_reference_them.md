# Convergence Domain Theory for Non-Well-Founded Proofs

## Abstract

We develop a formal mathematical theory of **non-well-founded proofs** — proof trees that may contain circular references to their own conclusions. The central innovation is a **Proof Convergence Domain**: a complete lattice equipped with a contractive deduction operator and a consistency metric that quantifies the circularity cost of self-reference. We prove that (1) contractive deduction operators have unique fixed points, establishing that convergent self-referential proofs are unambiguous; (2) valid proof trees have consistency metric strictly less than 1, with the liar sentence exactly at the boundary; (3) every valid self-referential proof admits a well-founded kernel that preserves the target proposition; (4) self-reference provides unbounded proof compression; and (5) proof heights form a tropical semiring. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: non-well-founded proofs, fixed-point theory, consistency metric, tropical semirings, proof compression, self-referential logic

---

## 1. Introduction

Self-reference has been a central concern in mathematical logic since Gödel's incompleteness theorems [1]. The standard approach treats self-reference as inherently problematic — circular reasoning is forbidden, and the liar paradox is taken as evidence that unrestricted self-reference leads to inconsistency.

We propose an alternative perspective: self-referential proofs form a well-defined mathematical structure with precise convergence conditions. Our approach is inspired by three independent lines of work:

1. **Non-well-founded set theory** (Aczel 1988): sets that contain themselves as members, axiomatized via an anti-foundation axiom.
2. **Banach's fixed-point theorem**: contractive maps on complete metric spaces have unique fixed points, computed by iteration.
3. **Tropical geometry**: the semiring (ℝ ∪ {∞}, min, +) captures optimization problems in algebraic form.

We unify these ideas into a single framework where self-referential proofs are fixed points of contractive operators on a lattice of proof approximations, with proof heights forming a tropical semiring.

### 1.1 Summary of Results

| Result | Statement | Significance |
|--------|-----------|-------------|
| Unique Fixed Point | Contractive deduction operators have at most one fixed point | Self-referential proofs are unambiguous |
| Consistency Metric Bound | Valid proofs have CM < 1; liar has CM = 1 | Quantitative boundary between valid/invalid self-reference |
| Stratification Theorem | Every valid NWF proof has a valid well-founded kernel | Self-reference is eliminable (at a cost) |
| Unbounded Compression | For all d, there exists a depth-d proof whose kernel has depth 0 | Self-reference provides genuine proof compression |
| Tropical Distributivity | Proof heights satisfy the tropical semiring axioms | Connection to optimization theory |

---

## 2. Definitions

### 2.1 Non-Well-Founded Proof Trees

**Definition 2.1** (NWFTree). A *non-well-founded proof tree* is an element of the inductive type:
```
NWFTree ::= ax(p) | mp(f, a, p, q) | selfRef(p, inner) | bot
```
where `p, q` are proposition identifiers and `f, a, inner` are proof trees.

- `ax(p)`: an axiom proving proposition p
- `mp(f, a, p, q)`: modus ponens — f proves p → q, a proves p, yielding q
- `selfRef(p, inner)`: self-referential proof of p that uses inner (which may assume p)
- `bot`: undefined/invalid proof

**Definition 2.2** (Validity). A proof tree is *valid* if:
- `ax(p)` is always valid
- `mp(f, a, p, q)` is valid if f targets p, a has a defined target, and both are valid
- `selfRef(p, inner)` is valid if inner targets p and is valid
- `bot` is never valid

**Definition 2.3** (Structural Depth). The depth of a proof tree counts the maximum nesting:
```
depth(ax(p)) = 0
depth(mp(f,a,p,q)) = 1 + max(depth(f), depth(a))
depth(selfRef(p,t)) = 1 + depth(t)
depth(bot) = 0
```

### 2.2 The Consistency Metric

**Definition 2.4** (Consistency Metric). The consistency metric CM : NWFTree → [0, 1] is defined recursively:
```
CM(ax(p))        = 0
CM(mp(f,a,p,q))  = max(CM(f), CM(a))
CM(selfRef(p,t)) = (1 + CM(t)) / 2
CM(bot)           = 1
```

The key property of this definition is that selfRef maps the interval [0, 1) to [1/2, 1), providing a quantitative measure of circularity that strictly increases with each layer of self-reference but never exceeds 1 for valid proofs.

### 2.3 Proof Convergence Domain

**Definition 2.5** (Proof Convergence Domain). A *Proof Convergence Domain* over a complete lattice (L, ≤) consists of:
1. A monotone function `deduct : L → L` (the deduction operator)
2. A metric `dist : L × L → ℝ≥0` satisfying the axioms of a metric
3. A contraction factor `c ∈ (0, 1)` such that `dist(deduct(x), deduct(y)) ≤ c · dist(x, y)` for all x, y

### 2.4 Well-Founded Kernel

**Definition 2.6** (Well-Founded Kernel). The *well-founded kernel* wfKernel : NWFTree → NWFTree replaces every selfRef(p, inner) with ax(p):
```
wfKernel(ax(p))        = ax(p)
wfKernel(mp(f,a,p,q))  = mp(wfKernel(f), wfKernel(a), p, q)
wfKernel(selfRef(p,t)) = ax(p)
wfKernel(bot)           = bot
```

### 2.5 Tropical Proof Heights

**Definition 2.7** (Tropical Proof Height). The type TPH = WithTop ℕ equipped with:
- Tropical addition: `a ⊕ b = min(a, b)` (choose shorter proof)
- Tropical multiplication: `a ⊗ b = a + b` (compose proofs)
- Additive identity: `0_trop = ⊤` (no proof exists)
- Multiplicative identity: `1_trop = 0` (axiom)

### 2.6 k-Convergence

**Definition 2.8** (k-Convergent). A proof tree t is *k-convergent* if its self-reference depth is at most k and it is valid. 0-convergent proofs are exactly the valid well-founded proofs.

---

## 3. Main Results

### 3.1 Unique Fixed Point Theorem

**Theorem 3.1** (Unique Fixed Point). Let D be a Proof Convergence Domain. If x and y are fixed points of D.deduct (i.e., deduct(x) = x and deduct(y) = y), then x = y.

*Proof sketch*. Since deduct(x) = x and deduct(y) = y:
```
dist(x, y) = dist(deduct(x), deduct(y)) ≤ c · dist(x, y)
```
where c < 1. This implies (1 - c) · dist(x, y) ≤ 0, so dist(x, y) ≤ 0, hence dist(x, y) = 0, hence x = y. □

**Corollary 3.2** (Geometric Convergence). The Kleene iterates deduct^n(⊥) satisfy:
```
dist(deduct^(n+1)(⊥), deduct^(n+2)(⊥)) ≤ c^(n+1) · dist(⊥, deduct(⊥))
```

### 3.2 Consistency Metric Characterization

**Theorem 3.3** (Consistency Metric Bounds). For all proof trees t:
1. 0 ≤ CM(t) ≤ 1
2. CM(t) = 0 iff t is an axiom or a pure modus ponens tree of axioms
3. CM(t) = 1 iff t contains a path to bot through selfRef nodes

**Theorem 3.4** (Valid Proofs Have CM < 1). If t is a valid proof tree, then CM(t) < 1.

*Proof sketch*. Induction on t. The key case is selfRef(p, inner): if inner is valid with CM(inner) < 1 by induction, then CM(selfRef(p, inner)) = (1 + CM(inner))/2 < (1 + 1)/2 = 1. The bot case is vacuous since bot is never valid. □

**Example 3.5**. The identity proof selfRef(p, ax(p)) has CM = 1/2. The liar sentence selfRef(p, bot) has CM = 1.

### 3.3 Stratification Theorem

**Theorem 3.6** (Stratification). For any valid proof tree t:
1. wfKernel(t) is valid
2. wfKernel(t) has no self-referential nodes
3. wfKernel(t).target = t.target
4. depth(wfKernel(t)) ≤ depth(t)

*Proof sketch*. By structural induction. The key case is selfRef(p, inner): wfKernel replaces it with ax(p), which is trivially valid and targets p. For mp, the target-preservation follows from the fact that wfKernel preserves targets (proved separately). □

### 3.4 Unbounded Compression

**Theorem 3.7** (Unbounded Compression). For every natural number d, there exists a valid proof tree of depth d whose well-founded kernel has depth 0.

*Proof*. Define nestedSR(p, 0) = ax(p) and nestedSR(p, n+1) = selfRef(p, nestedSR(p, n)). Then:
- nestedSR(p, n) is valid for all n (by induction: the target is always some p)
- depth(nestedSR(p, n)) = n
- depth(wfKernel(nestedSR(p, n))) = 0 (since wfKernel collapses to ax(p))

The compression ratio is n : 0, which is unbounded. □

### 3.5 Tropical Semiring Structure

**Theorem 3.8** (Tropical Semiring Laws). The tropical proof height operations satisfy:
1. (TPH, ⊕, ⊤) is a commutative monoid
2. (TPH, ⊗, 0) is a commutative monoid
3. ⊗ distributes over ⊕: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)
4. ⊤ annihilates: ⊤ ⊗ a = ⊤

*Proof*. Direct verification using properties of min and addition on WithTop ℕ. □

### 3.6 Convergence Stratification

**Theorem 3.9** (k-Convergence Characterization). 
1. 0-convergent proofs are exactly the valid proofs with no self-reference.
2. k-convergence is monotone: if t is j-convergent and j ≤ k, then t is k-convergent.
3. The identity proof is 1-convergent but not 0-convergent.

---

## 4. PEGB Analysis

### 4.1 Unique Fixed Point (Theorem 3.1)

**P (Proof)**: Machine-verified in Lean 4 as `ProofConvergenceDomain.unique_fixed_point`.

**E (Example)**: Consider the complete lattice [0, 1] with deduction operator f(x) = x/2. This is contractive with factor 1/2. The unique fixed point is 0, which represents the proof that "starting from any assumption, repeated deduction converges to the trivial proof."

**G (Generalization)**: The result generalizes to any complete metric space (not just complete lattices) — this is Banach's fixed-point theorem. The lattice structure provides additional monotonicity guarantees but is not essential for uniqueness.

**B (Boundary)**: The contraction factor must be *strictly* less than 1. With factor = 1, the identity function has every element as a fixed point — self-reference becomes ambiguous. The boundary case c = 1 is precisely where paradoxes live.

### 4.2 Consistency Metric (Theorem 3.4)

**P**: Machine-verified as `consistencyMetric_valid_lt_one`.

**E**: Identity proof: CM = 1/2. Nested selfRef(p, selfRef(p, ax(p))): CM = (1 + 1/2)/2 = 3/4. Each layer of self-reference brings CM closer to 1 but never reaches it.

**G**: The consistency metric could be parameterized by a weight function w : NWFTree → ℝ, giving CM(selfRef(p,t)) = (w(t) + CM(t)) / (1 + w(t)). Our choice w = 1 is the simplest; other choices could capture different notions of "circularity cost."

**B**: The liar sentence selfRef(p, bot) has CM = 1, sitting exactly on the boundary. This is the *unique* minimal invalid self-referential proof: any deeper nesting would exceed 1, which is impossible since CM ≤ 1 always.

### 4.3 Stratification Theorem (Theorem 3.6)

**P**: Machine-verified as `wfKernel_valid`, `wfKernel_no_sr`, `wfKernel_target`, `wfKernel_depth_le`.

**E**: wfKernel(selfRef(p, mp(ax(p), ax(q), p, q))) = ax(p). The complex self-referential structure collapses to a single axiom.

**G**: The wfKernel operation can be generalized to a *k-kernel* that strips only self-references at depth > k, providing a family of approximations between the full proof and its well-founded skeleton.

**B**: wfKernel does not preserve all semantic content — it replaces self-referential subproofs with axioms, which may not be sound in the ambient proof system. The kernel is structurally valid but semantically weaker.

### 4.4 Unbounded Compression (Theorem 3.7)

**P**: Machine-verified as `unbounded_compression`.

**E**: nestedSR(p, 5) has depth 5 but wfKernel depth 0. The ratio is 5:0.

**G**: More complex self-referential structures (not just nesting) could achieve even richer compression. In particular, mutual self-reference between multiple propositions could compress multi-dimensional proof structures.

**B**: Compression is only in structural depth, not in semantic complexity. The axiom ax(p) that the kernel produces requires p to be independently justified. Self-reference doesn't create information from nothing — it compresses its representation.

---

## 5. Falsifiable Conjecture

**Conjecture 5.1** (Self-Reference Elimination Preserves Provability). For every proof system S and every proposition p provable via a valid k-convergent NWF proof (k > 0), p is also provable via a 0-convergent proof in S, possibly with greater depth.

**Test**: Construct a proof system S with a proposition p that has a valid 1-convergent proof but no valid 0-convergent proof. This would require a proposition whose only proof essentially involves self-reference — i.e., the axiom base is insufficient to prove p without circular reasoning.

**Prediction**: Such a system exists (making the conjecture false). Consider a system where the only axiom is "p → p" (expressed as a self-referential proof), with no independent axiom for p. The wfKernel reduces to ax(p), but p may not be independently axiomatizable.

---

## 6. Cross-Domain Connections

### 6.1 Connection to Catalog Results

Our work connects to several existing catalog results:

1. **`direct_self_reference_paradox`** (MachineLearning/GazingPool.lean): Proves that P ↔ ¬P implies False. Our consistency metric provides a *quantitative* version: self-referential statements with CM = 1 are paradoxical, while those with CM < 1 are valid.

2. **`fixed_point_unique_under_theory_separation`** (Bridges/ProofStoneCechDynamics.lean): Our unique fixed point theorem specializes to the same result when the theory separation condition implies contractivity.

3. **`self_reasoning_fixed_point`** (Tropical/TropicalSelfReasoning.lean): Our tropical semiring structure on proof heights extends this work by providing algebraic operations on proof heights.

### 6.2 Connection to Tropical Mathematics

The proof height semiring (WithTop ℕ, min, +) is a *tropical semiring* — the same algebraic structure that appears in tropical geometry, optimization, and phylogenetics. This connection suggests that:

1. **Proof search as tropical optimization**: Finding the shortest proof is a tropical linear programming problem.
2. **Proof varieties**: The set of achievable proof height vectors forms a tropical variety.
3. **Tropical Gröbner bases**: The ideal theory of proof heights could yield canonical forms for proof systems.

---

## 7. Algorithms

### 7.1 Consistency Metric Computation

```python
def consistency_metric(tree):
    if tree.type == 'axiom': return 0.0
    elif tree.type == 'mp':
        return max(consistency_metric(tree.left), consistency_metric(tree.right))
    elif tree.type == 'selfRef':
        return (1 + consistency_metric(tree.inner)) / 2
    elif tree.type == 'bot': return 1.0
```

Time complexity: O(n) where n is the number of nodes.

### 7.2 Well-Founded Kernel Extraction

```python
def wf_kernel(tree):
    if tree.type == 'axiom': return tree
    elif tree.type == 'mp':
        return MP(wf_kernel(tree.left), wf_kernel(tree.right), tree.p, tree.q)
    elif tree.type == 'selfRef': return Axiom(tree.p)
    elif tree.type == 'bot': return tree
```

Time complexity: O(n) where n is the number of nodes. The kernel is always smaller or equal in size.

---

## 8. Discussion and Future Work

### 8.1 Limitations

1. Our NWFTree type is an *inductive* type, not coinductive. True non-well-founded structures (infinite proof trees) would require coinductive types, which are more complex to work with in Lean 4.

2. The consistency metric is a syntactic measure. A deeper semantic version would require modeling the ambient logic and its interpretation.

3. The connection to tropical geometry is algebraic but not yet geometric — we establish the semiring structure but not the associated tropical varieties.

### 8.2 Open Problems

1. **Semantic consistency**: Does there exist a proof system where a valid NWF proof proves a proposition that has no classical proof?

2. **Complexity-theoretic bounds**: Is there a relationship between the minimum self-reference depth of a proof and the computational complexity of the proved statement?

3. **Coinductive extension**: Can the framework be extended to infinite proof trees using coinductive types, and if so, what is the analog of the consistency metric for infinite trees?

---

## 9. References

[1] K. Gödel, "Über formal unentscheidbare Sätze der Principia Mathematica und verwandter Systeme I," *Monatshefte für Mathematik und Physik*, vol. 38, pp. 173–198, 1931.

[2] P. Aczel, *Non-Well-Founded Sets*, CSLI Lecture Notes, 1988.

[3] S. Banach, "Sur les opérations dans les ensembles abstraits et leur application aux équations intégrales," *Fundamenta Mathematicae*, vol. 3, pp. 133–181, 1922.

[4] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, AMS, 2015.

[5] A. Tarski, "A lattice-theoretical fixpoint theorem and its applications," *Pacific Journal of Mathematics*, vol. 5, pp. 285–309, 1955.
