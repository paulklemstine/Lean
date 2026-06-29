# Height Is the Only Cost: A Two-Sided Theory of Combination-Tree Depth for Valuation-Depth Carriers

## Abstract

We develop a complete, two-sided quantitative theory of the *depth cost* incurred when a
value is built by repeated binary combination, governed by a single structural axiom — the
**unit-cost ultrametric law** `depth(x ⊕ y) ≤ max(depth(x), depth(y)) + 1`. We call a set
equipped with such a combining operation and depth measure a **depth carrier**. The
foundational result is that for any combination tree `t` over a depth carrier,
`depth(eval t) ≤ maxLeafDepth(t) + height(t)`: the only overhead of repeated combination
is the height of the tree. Our central contribution is the **height–leaf duality**, valid
for *every* binary tree: `numLeaves ≤ 2^height` and `height + 1 ≤ numLeaves`, which after
taking base-2 logarithms yields the universal sandwich
`⌈log₂ numLeaves⌉ ≤ height ≤ numLeaves − 1`. We prove this sandwich is *tight at both
ends* — the balanced tree attains the floor `⌈log₂ numLeaves⌉` and the caterpillar attains
the ceiling `numLeaves − 1` — establishing balanced reassociation as provably optimal and
the naive accumulation as provably worst, with an exponential gap between them. We further
establish: (i) a median-split construction realizing the optimal height for *every* leaf
count, not only powers of two; (ii) a scale-covariant generalization to an arbitrary cost
constant `c`, giving `depth(eval t) ≤ maxLeafDepth(t) + c · height(t)` with `c` the least
working constant; (iii) a two-sided witness sandwich `maxLeafDepth ≤ eval ≤ maxLeafDepth +
height` showing no leaf information is ever lost; and (iv) a universal linear-overhead bound
`depth(eval t) − maxLeafDepth(t) ≤ numLeaves − 1`. We connect the framework to *p*-adic
Hensel lifting (the `k`-fold doubling tree has depth `k` and precision `2ᵏ`), to functional
composition, and to tropical/ultrametric geometry, where the unit-cost law is precisely the
1-Lipschitz law of a functor into the tropical semiring `(ℕ, max, +)`. All results have been
formally verified. We close with open problems, including a conjectured tropical Kraft–Huffman
formula for the reassociation optimum and a 2-categorical upgrade of the depth functor.

**Keywords.** valuation depth, ultrametric, tropical semiring, combination tree, max-plus
algebra, reassociation, Hensel lifting, Kraft inequality, 1-Lipschitz functor.

---

## 1. Introduction

Many quantitative invariants in mathematics behave *sub-maximally* under a binary combining
operation. If `depth` measures the complexity, level, or cost of a value, combining two
values rarely produces something deeper than the deeper of the two by more than a bounded
amount. The cleanest such regime is the **unit cost** one: a single step of combination
deepens by at most one. This pattern recurs across number theory (*p*-adic valuation
levels), algebraic geometry (tropical/max-plus structures), and the analysis of iterative
algorithms (Newton/Hensel precision doubling).

This paper isolates the pattern as a single axiom and pushes its consequences to
completion. The organizing question is operational: when a value is assembled from `m`
ingredients by `m − 1` binary combinations, the *order* of combination is recorded by a
binary tree, and we ask how the depth of the final value depends on that tree. Our answer
is that the dependence is entirely through one statistic, the tree's **height**, and that
the height is controllable within sharp, universal bounds.

### 1.1 Contributions

1. **Foundational bound (Theorem 3.1).** `depth(eval t) ≤ maxLeafDepth(t) + height(t)` for
   every depth carrier and tree.
2. **Height–leaf duality (Theorems 4.1–4.3).** `numLeaves ≤ 2^height`, `height + 1 ≤
   numLeaves`, and hence `⌈log₂ numLeaves⌉ ≤ height` universally.
3. **Optimality sandwich (Theorems 5.1–5.2).** Balanced trees attain the height floor;
   caterpillars attain the height ceiling.
4. **Exponential reassociation gap (Theorem 5.3).** Balanced vs. caterpillar depth differs
   exponentially in the leaf count.
5. **Optimal height for all sizes (Theorem 6.1).** A median-split tree attains height
   `⌈log₂ m⌉` for every `m ≥ 1`.
6. **Scale covariance (Theorems 7.1–7.2).** Generalization to cost `c`, with `c = 1` the
   least working constant.
7. **Two-sided witness sandwich & universal overhead (Theorems 8.1–8.2).**
   `maxLeafDepth ≤ eval ≤ maxLeafDepth + height` and overhead `≤ numLeaves − 1`.
8. **Bridges (Section 9).** Hensel/Newton precision, composition carriers, and the tropical
   1-Lipschitz functor.

---

## 2. Definitions

### 2.1 Depth carriers

**Definition 2.1 (Depth carrier).** A *depth carrier* is a tuple `X = (K, ⊕, depth)` where
`K` is a type, `⊕ : K → K → K` is a binary combination, and `depth : K → ℕ` is a depth
measure satisfying the **unit-cost ultrametric law**
```
∀ x y,  depth(x ⊕ y) ≤ max(depth x, depth y) + 1.
```

**Definition 2.2 (Strict carrier).** A depth carrier is *strict* (idempotent / zero-cost)
if it satisfies the stronger law `depth(x ⊕ y) ≤ max(depth x, depth y)` with no `+1` slack.

**Definition 2.3 (Unit-cost witness).** The *witness carrier* is `(ℕ, ⊕, id)` with
`x ⊕ y := max(x, y) + 1` (written `unitCostAdd`). The unit-cost law holds here with
*equality*, making it the extremal carrier.

### 2.2 Combination trees

**Definition 2.4 (Combination tree).** `OpTree K` is the type of binary trees with
`K`-valued leaves: a tree is either `leaf k` or `node l r`. We define four statistics by
structural recursion:

- **Evaluation:** `eval ⊕ (leaf k) = k`, `eval ⊕ (node l r) = (eval ⊕ l) ⊕ (eval ⊕ r)`.
- **Height:** `height(leaf _) = 0`, `height(node l r) = max(height l, height r) + 1`.
- **Leaf count:** `numLeaves(leaf _) = 1`, `numLeaves(node l r) = numLeaves l + numLeaves r`.
- **Max leaf depth:** `maxLeafDepth depth (leaf k) = depth k`,
  `maxLeafDepth depth (node l r) = max(maxLeafDepth depth l, maxLeafDepth depth r)`.

**Definition 2.5 (Canonical extremal trees).**
- The *balanced* tree `balanced k n` has `balanced k 0 = leaf k` and
  `balanced k (n+1) = node (balanced k n) (balanced k n)`; it has height `n` and `2ⁿ` leaves.
- The *caterpillar* `caterpillar k n` has `caterpillar k 0 = leaf k` and
  `caterpillar k (n+1) = node (caterpillar k n) (leaf k)`; it has height `n` and `n+1` leaves.

### 2.3 Cost carriers

**Definition 2.6 (Cost-`c` carrier).** A *cost-`c` carrier* is `X = (K, ⊕, depth, c)` with
`depth(x ⊕ y) ≤ max(depth x, depth y) + c`. A depth carrier is the case `c = 1`; the
reduction `atUnit` shows any cost-`1` carrier is a depth carrier.

---

## 3. The fundamental combination-tree bound

**Theorem 3.1 (Combination-tree depth bound).** For any depth carrier `X` and tree
`t : OpTree X.K`,
```
X.depth(eval X.⊕ t) ≤ maxLeafDepth X.depth t + height t.
```

*Proof sketch.* Induction on `t`. **Base:** for `leaf k`, both sides equal `depth k` (height
`0`). **Step:** for `node l r`, the unit-cost law gives
`depth(eval l ⊕ eval r) ≤ max(depth(eval l), depth(eval r)) + 1`. By the inductive
hypotheses `depth(eval l) ≤ maxLeafDepth l + height l` and likewise for `r`; since
`max(a + p, b + q) ≤ max(a,b) + max(p,q)` and `height(node l r) = max(height l, height r)+1`,
linear arithmetic (`omega`) closes the goal. ∎

**Theorem 3.2 (Strict carriers have no overhead).** If `X` is strict, then for every tree
`depth(eval t) ≤ maxLeafDepth t`.

*Proof sketch.* Identical induction, but the strict law removes the `+1` at each node, so the
height term never accrues. ∎

This already isolates the phenomenon: the `+1` of the unit-cost law is the *sole* source of
the height overhead; remove it and the overhead disappears.

---

## 4. Height–leaf duality

This section contains the paper's central structural results: a universal two-sided relation
between a tree's height and its leaf count, valid for *every* binary tree (not just the named
extremal families).

**Theorem 4.1 (Leaf count is at most `2^height`).** For every tree `t`,
`numLeaves t ≤ 2^(height t)`.

*Proof sketch.* Induction. A leaf has `1 ≤ 2⁰`. For `node l r` with heights `hₗ, hᵣ`,
`numLeaves = numLeaves l + numLeaves r ≤ 2^hₗ + 2^hᵣ ≤ 2·2^max(hₗ,hᵣ) = 2^(max(hₗ,hᵣ)+1) =
2^height`, using monotonicity of `2^(·)`. ∎

**Theorem 4.2 (Height is below the leaf count).** For every tree `t`,
`height t + 1 ≤ numLeaves t`, equivalently `height t ≤ numLeaves t − 1`.

*Proof sketch.* Induction. A leaf gives `0 + 1 ≤ 1`. For `node l r`, WLOG `hₗ ≥ hᵣ`; then
`height(node l r) + 1 = hₗ + 2 ≤ (numLeaves l + 1) + 1 ≤ numLeaves l + numLeaves r =
numLeaves`, using the inductive bound `hₗ + 1 ≤ numLeaves l` and `numLeaves r ≥ 1`. ∎

**Theorem 4.3 (Universal logarithmic lower bound on height).** For every tree `t`,
`⌈log₂ numLeaves t⌉ ≤ height t`.

*Proof sketch.* Apply the Galois-style equivalence `Nat.clog 2 m ≤ h ⟺ m ≤ 2ʰ`
(`Nat.clog_le_iff_le_pow`) to Theorem 4.1. ∎

Together, Theorems 4.1–4.3 yield the **sandwich**
```
⌈log₂ numLeaves t⌉ ≤ height t ≤ numLeaves t − 1   (for every tree t).
```
The lower bound is the universal companion to the fact, previously known only for the
balanced witness, that logarithmic depth is achievable; it shows logarithmic height is not
merely *achievable* but is a *floor* no reassociation can break.

---

## 5. The optimality sandwich

**Theorem 5.1 (Balanced is optimal).** `height(balanced k n) = ⌈log₂ numLeaves(balanced k n)⌉`.

*Proof sketch.* `height(balanced k n) = n` and `numLeaves = 2ⁿ`, while `⌈log₂ 2ⁿ⌉ = n` by
`Nat.clog_pow`. ∎

**Theorem 5.2 (Caterpillar is worst).** `height(caterpillar k n) = numLeaves(caterpillar k n) − 1`.

*Proof sketch.* `height = n` and `numLeaves = n + 1`, so the difference is `1`. ∎

Thus balanced reassociation attains the universal floor (Theorem 4.3) and the caterpillar
attains the universal ceiling (Theorem 4.2): both ends of the sandwich are realized.

**Theorem 5.3 (Exponential reassociation gap).** For `n ≥ 2`, evaluating under the unit-cost
operation,
```
eval(balanced 0 n) = n     and     eval(caterpillar 0 (2ⁿ − 1)) = 2ⁿ − 1,
```
with both trees having the same leaf count `2ⁿ`. Hence balanced reassociation reduces depth
from linear (`numLeaves − 1`) to logarithmic (`⌈log₂ numLeaves⌉`) in the leaf count — an
exponential improvement.

*Proof sketch.* `eval(balanced 0 n) = 0 + n` and `eval(caterpillar 0 m) = 0 + m` under
`unitCostAdd` (each level/step spends exactly one unit), proved by induction. Set
`m = 2ⁿ − 1`; the leaf counts match since `numLeaves(caterpillar 0 (2ⁿ−1)) = 2ⁿ =
numLeaves(balanced 0 n)`. The strict inequality `n < 2ⁿ − 1` for `n ≥ 2` follows from
`k + 3 < 2^(k+2)`. ∎

---

## 6. Optimal height for every leaf count

The extremal results above use power-of-two leaf counts. We now show the floor is attained
for *all* sizes.

**Theorem 6.1 (Optimal reassociation exists for every leaf count).** For every `m ≥ 1` and
every leaf value `k`, there is a tree `t = mkBalanced k m` with `numLeaves t = m` and
`height t = ⌈log₂ m⌉`. Consequently the universal lower bound of Theorem 4.3 is *attained*
for all `m`, not only powers of two.

*Proof sketch.* Define `mkBalanced` by strong recursion: split `m` into `⌈m/2⌉ = (m+1)/2` and
`⌊m/2⌋ = m/2`, recurse on each, and combine with a node. A leaf-count induction gives
`numLeaves(mkBalanced k m) = m`. For the height, use the recurrence
`Nat.clog 2 m = Nat.clog 2 ⌈m/2⌉ + 1` (for `m ≥ 2`): both halves have `clog`-height one less,
so the node has height `⌈log₂ m⌉`. On the unit-cost carrier this yields evaluated depth
exactly `maxLeafDepth + ⌈log₂ m⌉`. ∎

This upgrades the optimality statement from the dyadic witnesses to a complete theorem: an
information-theoretically optimal combination order always exists.

---

## 7. Scale covariance: the cost constant

**Theorem 7.1 (Scaled combination-tree bound).** For a cost-`c` carrier `X` and tree `t`,
```
X.depth(eval X.⊕ t) ≤ maxLeafDepth X.depth t + c · height t.
```

*Proof sketch.* Repeat the induction of Theorem 3.1 with `+c` in place of `+1`. The only new
ingredient is the scaled sub-distributivity
`max(a + c·x, b + c·y) ≤ max(a,b) + c·max(x,y)`, handled by monotonicity of multiplication
(`Nat.mul_le_mul_left`). At `c = 1` this is Theorem 3.1. ∎

**Theorem 7.2 (Least working constant).** A constant `c` makes
`depth(x ⊕ y) ≤ max(depth x, depth y) + c` hold for *every* depth carrier iff `1 ≤ c`; hence
`1` is the least such constant.

*Proof sketch.* Sufficiency is the unit-cost law plus monotonicity. Necessity: the witness
carrier at `0 ⊕ 0` gives `depth(0 ⊕ 0) = 1 = max(0,0) + 1`, forcing `c ≥ 1`. ∎

The cost-`c` family shows the theory is *scale-covariant*: changing the per-step cost merely
rescales the height axis without altering any structural conclusion.

---

## 8. Two-sided witness bound and universal overhead

**Theorem 8.1 (Witness sandwich).** On the unit-cost witness carrier, for every tree `t`,
```
maxLeafDepth t ≤ eval t ≤ maxLeafDepth t + height t,
```
with both ends attained (the lower end by, e.g., a leaf or strict-like configuration; the
upper end by the balanced tree, Theorem 5.3).

*Proof sketch.* The upper bound is Theorem 3.1 specialized to the witness. The lower bound
`maxLeafDepth ≤ eval` is an induction: `unitCostAdd x y = max(x,y) + 1 ≥ max(x,y)`, so each
node weakly increases the running max, and `eval ≥ maxLeafDepth` follows. Operationally:
combining never destroys leaf information — *no leaf value is ever lost*. ∎

**Theorem 8.2 (Universal linear overhead).** For every depth carrier and tree,
```
X.depth(eval t) ≤ maxLeafDepth X.depth t + (numLeaves t − 1).
```

*Proof sketch.* Combine Theorem 3.1 with `height t ≤ numLeaves t − 1` (Theorem 4.2). ∎

No depth carrier ever pays more than `numLeaves − 1` extra depth, irrespective of
associativity structure — the caterpillar's worst case made universal.

---

## 9. Bridges and applications

### 9.1 Hensel lifting and Newton precision

**Definition 9.1.** A *composition-depth carrier* is `(M, ∘, vdepth)` with the unit-cost law
`vdepth(f ∘ g) ≤ max(vdepth f, vdepth g) + 1`. Every such carrier is a depth carrier
(via `comp = ⊕`), so Theorems 3.1, 4.x, 5.x transfer verbatim. The *doubling carrier* is
`(ℕ, unitCostAdd, id)`.

**Theorem 9.2 (Hensel certificate as a balanced tree).** For the `k`-fold quadratic-doubling
tree `balanced 0 k` evaluated in the doubling carrier:
```
vdepth(eval) = height = k     and     2^vdepth(eval) = 2ᵏ.
```
*Proof sketch.* By the balanced-evaluation identity `eval(balanced 0 k) = 0 + k = k`. ∎

This recovers the classical exponential-precision Newton/Hensel certificate — precision
`2^(#steps)` — as nothing more than the height of a balanced composition tree. The doubling
of *p*-adic precision per Newton step is exactly the `+1` of the unit-cost law applied along a
balanced spine.

### 9.2 The tropical 1-Lipschitz functor

Let `TropObj` denote the tropical semiring `(ℕ, max, +)`. Define `depthTropObj X := (ℕ, max)`
and `depthTropMap X := depth`. The unit-cost law is exactly the statement that `depthTropMap`
is **1-Lipschitz** into the tropical addition:
```
depthTropMap X (x ⊕ y) ≤ max(depthTropMap X x, depthTropMap X y) + 1.
```
Thus every depth carrier maps into a single tropical object with unit Lipschitz slack, and
the combination-tree bound is the functorial statement that this 1-Lipschitz property
propagates along trees with overhead exactly the height.

---

## 10. Algorithms

**Algorithm A (Median-split optimal tree, `mkBalanced`).** Given `m ≥ 1`, build a tree of
height `⌈log₂ m⌉`: if `m = 1` return a leaf; else split `m = ⌈m/2⌉ + ⌊m/2⌋`, recurse on each
half, return their node. Time `Θ(m)`; height `⌈log₂ m⌉` (Theorem 6.1).

**Algorithm B (Height/leaf certificate).** Given any tree, compute `height`, `numLeaves`, and
verify the sandwich `⌈log₂ numLeaves⌉ ≤ height ≤ numLeaves − 1` in `Θ(size)`.

**Algorithm C (Depth evaluation on a cost-`c` carrier).** Fold a tree with `⊕`, tracking
`depth`; the result is bounded by `maxLeafDepth + c · height` (Theorem 7.1).

---

## 11. Discussion

The results give a complete, scale-covariant, two-sided account of combination-tree depth.
The conceptual core is the *separation of concerns*: the unit-cost law contributes one unit
per node, and the only tree statistic that survives the analysis is the height. Everything
else — leaf values, leaf count beyond its logarithm, operation specifics — is invisible to
the depth, save for the universal bounds it imposes. The duality `⌈log₂ m⌉ ≤ height ≤ m − 1`
turns a vague intuition ("balanced is better") into a sharp, attained, exponential
quantitative law.

The bridges to Hensel lifting, composition, and tropical geometry are not analogies but
literal instances of one axiom. This is the payoff of axiomatizing at the right level: the
optimal strategy ("balance your trees") and its exact cost (`⌈log₂ m⌉`) are theorems about
the axiom, inherited by every model at once.

---

## 12. Future directions

**D7 — The reassociation optimum equals `maxLeafDepth + ⌈log₂ leaves⌉`.** *Conjecture.* Fix a
multiset `L` of `m` leaf values on the unit-cost witness carrier. The minimum of `eval t`
over all trees `t` with leaf multiset `L` equals `maxLeafDepth L + ⌈log₂ m⌉` when all leaf
values are equal, and in general is governed by a *tropical Huffman/Kraft* formula: the
minimum is the least `D` with `∑_{ℓ∈L} 2^(depth(ℓ) − D) ≤ 1`. *Test.* Prove the tropical
Kraft inequality `∑_leaves 2^(−(eval − value)) ≤ 1` for unit-cost evaluation, then show the
Huffman construction attains it; the lower-bound side already follows from Section 4.

**D8 — Depth as a genuine lax 2-functor.** *Conjecture.* Depth carriers with cost-non-increasing
morphisms (`f : X.K → Y.K` with `Y.depth(f a) ≤ X.depth a` and `f(a ⊕ b) = f a ⊕ f b`) form
a category, and `depthTropMap` extends to a lax functor into `(ℕ, max, +1)` such that the
combination-tree bound is *natural*: preserved and reflected by morphisms, giving a
2-categorical upgrade of the bridge.

---

## 13. Conclusion

We have proved that the depth cost of repeated combination, under the unit-cost ultrametric
law, depends only on tree height; that height is universally trapped between `⌈log₂ m⌉` and
`m − 1`; that both ends are attained, with an exponential gap; that an optimal tree exists for
every size; that the theory scales with the per-step cost; and that the same arithmetic
governs Hensel lifting, composition, and tropical geometry. The slogan is now a theorem:
**height is the only cost, and `⌈log₂ leaves⌉ ≤ height ≤ leaves − 1` pins it on both sides.**
