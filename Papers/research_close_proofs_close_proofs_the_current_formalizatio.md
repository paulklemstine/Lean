# The Fractal Dimension of Proof Search

## Abstract

We introduce and develop a quantitative theory of *proof-search difficulty*
based on the fractal dimension of the set of successful derivation paths. We
model proof search as a complete *b*-ary tree in which exactly *k* of the *b*
children of each node lie on a path to a valid proof, and we define the
**search dimension** D = log(k)/log(b). We prove that D is a well-behaved
difficulty coordinate: it lies in the interval [0, 1]; it is monotone
non-decreasing in the survivor count *k*; it equals 1 if and only if k = b
(a sharp **critical threshold**); and below threshold (k < b) the number of
successful paths decays exponentially relative to the total, with a strictly
worsening per-level success ratio. We then establish an **entropy–dimension
bridge**: D equals the ratio of the *search entropy* log(k^d) to the
*full-tree entropy* log(b^d), independent of depth *d*, thereby identifying a
geometric invariant with an information-theoretic one. We derive the
per-level information rate log(b)·(1 − D), show information content
decomposes linearly in depth, and treat sequential **composition** of
searches, proving a containment bound and additivity of log-entropy. All
results have been formally verified. We close with applications to automated
reasoning and several directions for future work.

**Keywords:** proof search, fractal dimension, box-counting dimension,
self-similar set, Shannon entropy, branching process, automated theorem
proving, critical threshold.

---

## 1. Introduction

The difficulty of finding a proof is one of the oldest informal notions in
mathematics, yet it resists precise definition. Proof length, search-tree
size, and heuristic cost all capture facets of it, but none yields a single
bounded, dimensionless coordinate with clean structural laws. This paper
proposes such a coordinate.

Our starting point is the observation that proof search is fundamentally a
*branching* process. At each state of a search there are several applicable
inference steps; only some of them lie on a path to a completed proof. Iterate
this and one obtains a tree whose nodes are partial derivations, with a
distinguished sub-tree of *live* nodes — those that can still be completed.
As depth increases, the live nodes trace out a self-similar subset of the
tree's boundary, and self-similar sets have a fractal dimension. That
dimension, we argue, is the natural measure of search difficulty.

The contribution is fourfold: (i) a minimal but expressive formal model of
proof search; (ii) the definition of the search dimension and a complete set
of order-theoretic and extremal properties; (iii) an exact bridge between the
fractal dimension and a ratio of Shannon entropies; and (iv) a compositional
calculus for chaining searches. Every theorem stated below has been
mechanically verified.

### 1.1 Conceptual background

Three classical bodies of theory meet in this work. From **fractal
geometry** we borrow the box-counting (Minkowski) and Hausdorff dimensions of
self-similar sets, whose canonical formula log(N)/log(1/r) for a set composed
of N copies scaled by r is the template for our definition. From the
**combinatorics of trees** we take the picture of a search as a rooted tree
whose boundary is a Cantor-like space, equipped with an ultrametric in which
distance decays geometrically with the length of a shared prefix. From
**information theory** we take Shannon's identification of the logarithm of a
count with the number of nats (or bits, in base 2) needed to single out one
element. The thesis of the paper is that these three viewpoints, applied to
the set of successful proof paths, all produce the *same* invariant, and that
this invariant deserves to be called the difficulty of the search.

### 1.2 Why a *normalized* invariant

Raw counts — proof length d, tree size b^d, number of proofs k^d — are all
unbounded and incomparable across problems with different branching factors.
A theorem with branching factor 2 and one with branching factor 100 cannot be
compared by counting nodes. Dividing log(k) by log(b) removes both the
exponential blow-up in depth and the dependence on the absolute branching
factor, leaving a pure ratio in [0, 1] that is meaningfully comparable across
heterogeneous problems. This is precisely the role dimension plays in fractal
geometry: it is the scale-invariant exponent that survives after the
size-dependent quantities are normalized away.

---

## 2. The branching search model

**Definition 2.1 (Branching search model).** A *branching search model* is a
tuple M = (b, k, d) of natural numbers satisfying b ≥ 2, k ≥ 1, and k ≤ b.
We interpret *b* as the branching factor (applicable moves per state), *k* as
the number of *surviving* branches per node (those on a path to a valid
proof), and *d* as the search depth (the length of a complete proof).

**Definition 2.2 (Leaf counts).** For a model M = (b, k, d):

- the *total leaves* are total(M) = b^d, the number of all derivation
  attempts of length d;
- the *successful leaves* are succ(M) = k^d, the number of completed proofs
  of length d.

These counts are exact for a complete tree in which the survivor structure is
homogeneous across nodes. The homogeneity assumption is what makes the live
set exactly self-similar; §7 discusses relaxations.

---

## 3. The search dimension

**Definition 3.1 (Search dimension).** For b ≥ 2 and k ≥ 1, the *search
dimension* is

> D(b, k) = log(k) / log(b).

The choice of logarithm base is immaterial since it cancels.

**Motivation (box-counting dimension).** Equip the boundary ∂T of the
complete b-ary tree — the set of infinite root-to-leaf rays — with the
ultrametric ρ(x, y) = b^(−n), where n is the length of the longest common
prefix of x and y. The set S ⊆ ∂T of infinite live rays is self-similar: it
consists of k scaled copies of itself, each scaled by the factor 1/b. For a
self-similar set satisfying the open-set condition, the box-counting (and
Hausdorff) dimension is log(N)/log(1/r), where N is the number of copies and
r the contraction ratio. Here N = k and r = 1/b, giving log(k)/log(b) = D.
Thus D is literally the fractal dimension of the set of successful proof
paths. The same formula yields log(3)/log(2) ≈ 1.585 for the Sierpiński
triangle and log(2)/log(3) ≈ 0.631 for the Cantor set; our setting confines
it to [0, 1] because k ≤ b.

---

## 4. Fundamental properties

Throughout, fix b ≥ 2, 1 ≤ k ≤ b.

**Theorem 4.1 (Full dimension).** D(b, b) = 1.
*Proof.* D(b, b) = log(b)/log(b) = 1, valid because log(b) > 0 for b ≥ 2. ∎

**Theorem 4.2 (Zero dimension).** D(b, 1) = 0.
*Proof.* log(1) = 0, so the numerator vanishes. ∎

**Theorem 4.3 (Range).** 0 ≤ D(b, k) ≤ 1.
*Proof.* The numerator log(k) ≥ 0 since k ≥ 1, and the denominator log(b) > 0
since b ≥ 2, giving non-negativity. For the upper bound, log is monotone so
k ≤ b yields log(k) ≤ log(b); dividing by the positive log(b) gives D ≤ 1. ∎

**Theorem 4.4 (Strict subcriticality).** If k < b then D(b, k) < 1.
*Proof.* Strict monotonicity of log gives log(k) < log(b); divide by the
positive denominator. ∎

**Theorem 4.5 (Monotonicity).** If 1 ≤ k₁ ≤ k₂ ≤ b then
D(b, k₁) ≤ D(b, k₂).
*Proof.* log(k₁) ≤ log(k₂) by monotonicity of log; divide both sides by the
fixed positive denominator log(b). ∎

Theorems 4.3–4.5 establish D as an order-preserving difficulty coordinate on
[0, 1]: more survivors never decrease the dimension, and the endpoints are
attained exactly at the degenerate cases.

---

## 5. The critical threshold and subcritical decay

**Theorem 5.1 (Critical threshold).** D(b, k) = 1 if and only if k = b.
*Proof.* (⇐) is Theorem 4.1. (⇒) Suppose log(k)/log(b) = 1. Since log(b) ≠ 0,
this gives log(k) = log(b). As log is injective on the positive reals and
k, b > 0, we conclude k = b. ∎

**Theorem 5.2 (Subcritical iff).** D(b, k) < 1 if and only if k < b.
*Proof.* (⇐) is Theorem 4.4. (⇒) Contrapositive: if k is not less than b then
k = b (using k ≤ b), whence D = 1 by Theorem 5.1, contradicting D < 1. ∎

Theorems 5.1–5.2 show the difficulty scale has a *sharp* top: dimension 1 is
reserved exactly for the non-search case k = b, and any genuine pruning of the
tree drops D strictly below 1.

**Theorem 5.3 (Subcritical decay).** If k < b and d ≥ 1 then k^d < b^d.
*Proof.* Strict monotonicity of x ↦ x^d on the naturals for positive
exponents. ∎

**Theorem 5.4 (Worsening success ratio).** If k ≥ 1 and k < b then for all d,

> k^(d+1) · b^d  <  k^d · b^(d+1).

*Proof.* Write k^(d+1)·b^d = k·k^d·b^d and k^d·b^(d+1) = k^d·b^d·b. Since
k^d·b^d > 0 and k < b, multiplying the strict inequality k < b by the positive
quantity k^d·b^d preserves it. ∎

Theorem 5.4 states that the ratio succ/total = (k/b)^d is strictly decreasing
in d: each additional level of proof depth multiplies the success fraction by
k/b < 1. This is the formal underpinning of the empirical wall that
brute-force search hits on long proofs.

---

## 6. The entropy–dimension bridge

**Definition 6.1 (Entropies).** The *search entropy* is
H_S(k, d) = log(k^d) and the *full-tree entropy* is H_T(b, d) = log(b^d).

These are Shannon (Hartley) entropies of the uniform distribution over,
respectively, the successful leaves and all leaves.

**Theorem 6.2 (Entropy–dimension bridge).** For b ≥ 2 and d ≥ 1,

> H_S(k, d) / H_T(b, d) = D(b, k).

*Proof.* H_S(k, d) = log(k^d) = d·log(k) and H_T(b, d) = log(b^d) = d·log(b).
Their ratio is (d·log(k))/(d·log(b)) = log(k)/log(b) = D(b, k), the factor d
cancelling because d ≥ 1 makes it nonzero. ∎

The bridge identifies a geometric invariant (a fractal dimension) with an
information-theoretic one (a ratio of entropies), independent of depth.

**Theorem 6.3 (Per-level information rate).** For b ≥ 2,

> log(b) − log(k) = log(b) · (1 − D(b, k)).

*Proof.* Substitute D = log(k)/log(b) on the right and simplify:
log(b)·(1 − log(k)/log(b)) = log(b) − log(k). ∎

The left side is the information gained per search level (the log of the
pruning ratio b/k); the right side exhibits it as the maximal per-level
information log(b) scaled by the *difficulty surplus* (1 − D). At D = 1 the
rate is 0 (no search); at D = 0 it is the full log(b) (a unique forced move).

**Theorem 6.4 (Linear information decomposition).** For all b, k, d,

> log(b^d) − log(k^d) = d · (log(b) − log(k)).

*Proof.* log(b^d) = d·log(b) and log(k^d) = d·log(k); subtract. ∎

Hence the total search information scales linearly in depth, while the *number*
of paths scales exponentially — the contrast that makes the dimension, a
per-level normalized quantity, the right invariant.

---

## 7. Composition of searches

**Definition 7.1 (Composed search).** A *composed search* is a tuple
C = (b₁, k₁, d₁, b₂, k₂, d₂) with each (bᵢ, kᵢ) satisfying bᵢ ≥ 2, kᵢ ≥ 1,
kᵢ ≤ bᵢ. Its *total space* is total(C) = b₁^d₁ · b₂^d₂ and its *successful
paths* are succ(C) = k₁^d₁ · k₂^d₂. This models solving one subproblem and
then, on each outcome, a second.

**Theorem 7.2 (Containment bound).** succ(C) ≤ total(C).
*Proof.* k₁^d₁ ≤ b₁^d₁ and k₂^d₂ ≤ b₂^d₂ by monotonicity of base in powers
(kᵢ ≤ bᵢ); multiply the two inequalities between non-negative quantities. ∎

**Theorem 7.3 (Additivity of log-entropy).** For k₁, k₂ ≥ 1,

> log(k₁^d₁ · k₂^d₂) = d₁·log(k₁) + d₂·log(k₂).

*Proof.* Both k₁^d₁ and k₂^d₂ are positive, so log of the product is the sum
of logs; then log(kᵢ^dᵢ) = dᵢ·log(kᵢ). ∎

Theorem 7.3 says difficulty measured in bits is additive across sequential
subproblems, the quantitative form of "do one thing, then the next." The
composite dimension is a depth-weighted blend of the components'
dimensions, recovering the single-search dimension when the two stages share
branching factor and survivor count.

---

## 8. Algorithms

We summarise the computational content. Let `ln` denote natural logarithm.

**Algorithm A (Search dimension).** Input b ≥ 2, k with 1 ≤ k ≤ b. Output
D = ln(k)/ln(b). Cost: O(1) arithmetic operations. This is the elementary
evaluation underlying every theorem of §4–§6.

**Algorithm B (Critical classifier).** Input (b, k). Compute D; classify as
*trivial* if D = 1 (equivalently k = b, Theorem 5.1), *deterministic* if
D = 0 (k = 1), else *subcritical*. By Theorem 5.2 the boundary cases are
detected exactly by integer comparison k vs b, avoiding floating-point
ambiguity.

**Algorithm C (Decay forecaster).** Input (b, k, d). Return the success
fraction (k/b)^d and the per-level information ln(b) − ln(k). By Theorem 5.4
the fraction is strictly decreasing in d; by Theorem 6.4 the total
information is d·(ln(b) − ln(k)). Useful for predicting when brute-force
enumeration becomes infeasible (fraction below a resource budget).

**Algorithm D (Composition evaluator).** Input two stages (bᵢ, kᵢ, dᵢ).
Return total(C), succ(C), the containment-checked ratio, and the additive
entropy d₁·ln(k₁) + d₂·ln(k₂) (Theorems 7.2–7.3). Cost: O(1) after fast
exponentiation, O(log d) with repeated squaring for the powers.

---

## 9. Applications

**Strategy selection in automated reasoning.** The dimension prescribes
search policy. Near D = 1 (k ≈ b) almost every move helps, so cheap
breadth-first or random rollout suffices. Near D = 0 (k small) the single
live path must be located among many dead ends, demanding strong heuristics,
learned guidance, or backward chaining. Algorithm C quantifies the crossover.

**Difficulty calibration and curriculum design.** Because D is bounded in
[0, 1] and monotone in survivors (Theorem 4.5), it offers a normalized
difficulty label for benchmark problems, supporting curriculum ordering for
learning-based provers from high-D (easy) to low-D (hard).

**Resource budgeting.** Theorem 6.4 turns a depth target into an exact
information budget d·(ln(b) − ln(k)); Theorem 5.4 bounds the shrinking yield
of deeper search. Together they let a scheduler allocate compute across
candidate lemmas in proportion to predicted payoff.

**Compositional planning.** Theorem 7.3 makes the difficulty of a proof plan
the sum of its parts' difficulties, justifying greedy decomposition: minimize
total bits by minimizing each stage's dᵢ·ln(kᵢ) independently.

---

## 10. Discussion and limitations

The model assumes a *homogeneous* survivor structure: every node has exactly
k live children. Real search trees are heterogeneous — survivor counts
fluctuate by node and depth. The honest reading of D is then an *effective*
or *average* dimension, and the exact theorems become first-order
approximations. The constant-branching assumption is similarly idealized.
Nevertheless the extremal and threshold results (§5) are robust: any pruning
at all pushes the effective dimension below 1, and the success fraction still
contracts whenever the average survivor ratio is below 1.

A second caveat is interpretational: D measures the *abundance* of proofs,
not the *cost of finding one*. A high-dimensional problem has many proofs and
is easy to stumble into; a low-dimensional one has few. This aligns with
search difficulty under uninformed strategies but can diverge under strong
heuristics that exploit structure invisible to the counting model.

---

## 11. Future work

1. **Heterogeneous trees.** Replace the constant k by a survivor distribution
   and define the dimension via the pressure/variational formula of
   thermodynamic formalism, recovering D = log(k)/log(b) in the homogeneous
   case as a special point.
2. **Random survivor models.** Treat survival as a Galton–Watson branching
   process with mean offspring μ ∈ (0, b]; conjecture an effective dimension
   log(μ)/log(b) almost surely on survival, with a phase transition at μ = 1.
3. **Empirical estimation.** Estimate D from real prover traces by
   regressing log(live nodes) against depth, and test whether measured
   dimensions predict wall-clock difficulty.
4. **Multifractal spectrum.** Where survivor density varies across the tree,
   compute the full multifractal spectrum f(α) and relate its peak to the
   typical search experience.
5. **Lower bounds.** Connect D to information-theoretic lower bounds on the
   number of inference steps any complete search procedure must perform.

---

## 11a. Worked examples

We close the technical development with three concrete instances that exercise
the theorems numerically.

**Example A (binary search, half alive).** Take b = 2, k = 1, any depth d.
Here only one of two branches survives, so D = log(1)/log(2) = 0: a single
forced path, the most rigid possible search. The success fraction is
(1/2)^d, halving with every level — the textbook image of a needle in a
geometrically growing haystack. The per-level information is
log(2) − log(1) = log(2), one full bit per step, the maximum.

**Example B (octal tree, three survivors).** Take b = 8, k = 3. Then
D = log(3)/log(8) ≈ 0.528 — strikingly, the same value as the box-counting
dimension of a Cantor-like set keeping 3 of 8 sub-intervals. The success
fraction (3/8)^d at depth d = 6 is about 0.0028, so fewer than 3 in 1000
length-6 attempts succeed, yet the dimension being well above 0 signals that
proofs are still comparatively abundant. The per-level information is
log(8) − log(3) ≈ 0.981 nats.

**Example C (composed lemma-then-theorem).** Compose stage 1 = (b₁, k₁, d₁)
= (3, 2, 4) with stage 2 = (b₂, k₂, d₂) = (5, 2, 3). The total space is
3^4 · 5^3 = 81 · 125 = 10125 and the successful paths number
2^4 · 2^3 = 16 · 8 = 128, comfortably within the containment bound of
Theorem 7.2 (128 ≤ 10125). The composite log-entropy is
4·log(2) + 3·log(2) = 7·log(2) ≈ 4.852 nats, the additive sum guaranteed by
Theorem 7.3. The stage dimensions are log(2)/log(3) ≈ 0.631 and
log(2)/log(5) ≈ 0.431; the harder (lower-dimensional) second stage dominates
the felt difficulty, matching intuition about bottleneck subproblems.

These examples illustrate the general lesson: the dimension is a coarse but
robust difficulty label, while the success fraction and information rate give
the fine-grained, depth-dependent picture needed for resource decisions.

---

## 12. Conclusion

We have given a compact, fully verified theory that assigns to a proof-search
problem a single number D ∈ [0, 1] — the fractal dimension of its set of
successful paths — and shown this number to be a faithful, monotone
difficulty coordinate with a sharp critical threshold at D = 1, an
exponential subcritical decay regime, and an exact identity with a ratio of
Shannon entropies. The dimension behaves additively under composition and
yields a clean per-level information rate log(b)·(1 − D). The theory is
deliberately minimal, but it cleanly unifies fractal geometry, tree
combinatorics, and information theory in the service of a very old question:
how hard is it to find a proof?
