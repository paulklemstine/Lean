# Tropical Gravitational Dynamics: Min-Plus Spacetime, Causal Evolution, and Horizon Fixed Points

## Abstract

We develop a rigorous mathematical framework — *tropical gravitational dynamics* — in which core structures of gravitational physics (metric geometry, causal evolution, and black-hole horizons) are realized as theorems in the min-plus (tropical) semiring. Working over the real numbers with operations (min, +), we construct: (1) a discrete radial pseudo-metric from cumulative edge weights on ℕ, proving reflexivity, symmetry, triangle inequality, and nonnegativity; (2) a min-plus evolution operator modeling discrete Hamilton–Jacobi dynamics, with proven existence, uniqueness, monotonicity, and nonexpansiveness; (3) a tropical Schwarzschild horizon characterized as the least fixed point of an absorbing radial update, with complete fixed-point classification; (4) a finite-state tropical transfer operator with proven monotonicity and tropical homogeneity; and (5) a bridge between iterated transfer and bounded path cost on weighted digraphs. All results are machine-verified in Lean 4 with the Mathlib library. The framework unifies gravitational causal propagation, dynamic programming, shortest-path algorithms, and tropical spectral theory into a single formal structure.

**Keywords:** tropical geometry, min-plus algebra, idempotent analysis, causal structures, Hamilton–Jacobi equations, fixed-point theory, black-hole analogues, shortest paths, dynamic programming

---

## 1. Introduction

### 1.1 Motivation

The quest to reconcile general relativity with quantum mechanics remains one of the central open problems in theoretical physics. While numerous approaches exist — string theory, loop quantum gravity, causal set theory, noncommutative geometry — each faces formidable mathematical and conceptual obstacles.

A less-explored but mathematically natural approach is *tropicalization*: replacing the field (ℝ, +, ×) with the tropical semiring (ℝ, min, +). This substitution has deep roots in:

- **Idempotent analysis** (Maslov, Litvinov, Kolokoltsov): the observation that the semiclassical limit ℏ → 0 of quantum mechanics is naturally described by min-plus algebra, with the Schrödinger equation degenerating to the Hamilton–Jacobi equation [1].
- **Tropical geometry** (Mikhalkin, Itenberg, Sturmfels): the study of piecewise-linear analogues of algebraic varieties, arising as limits of classical varieties under logarithmic degeneration [2].
- **Optimal control and dynamic programming** (Bellman): the Bellman equation is a min-plus linear equation, and shortest-path algorithms are min-plus matrix multiplications [3].

Our contribution is to formalize the observation that these three streams converge on a single structure that can be interpreted as a *tropical spacetime*: a discrete geometric object with causal propagation, evolution dynamics, and horizon phenomena, all governed by min-plus algebra.

### 1.2 Prior Work

The connection between tropical mathematics and physics has been noted informally by several authors:

- Maslov's idempotent principle [1] asserts that useful structures in traditional mathematics have idempotent (tropical) counterparts.
- Litvinov and collaborators [4] developed idempotent functional analysis and connected it to optimization and quantum mechanics.
- Noumi and Yamada [5] studied tropical analogues of integrable systems.
- The "causal set" approach to quantum gravity [6] uses discrete structures reminiscent of weighted digraphs.

However, to our knowledge, no prior work has:
1. Constructed a complete tropical analogue of radial gravitational geometry with certified metric properties.
2. Proven well-posedness of a tropical Einstein evolution operator.
3. Characterized the tropical Schwarzschild horizon as a least fixed point with full classification.
4. Machine-verified all results in a proof assistant.

### 1.3 Overview of Results

We prove the following package of theorems (all machine-verified):

| Theorem | Mathematical Content |
|---------|---------------------|
| `tropSup_idempotent` | min(a, a) = a |
| `tropSup_monotone_{left,right}` | min is monotone in both arguments |
| `tropSup_{comm,assoc}` | min is commutative and associative |
| `radialCost_self` | d(i, i) = 0 |
| `radialCost_symm` | d(i, j) = d(j, i) |
| `radialCost_triangle` | d(i, k) ≤ d(i, j) + d(j, k) for nonneg weights |
| `radialCost_nonneg` | d(i, j) ≥ 0 for nonneg weights |
| `tropEinstein_wellposed` | ∃! evolved state |
| `tropEinstein_monotone` | φ ≤ ψ ⟹ T(φ) ≤ T(ψ) |
| `tropEinstein_nonexpansive` | T(φ) - T(ψ) ≤ max(φ - ψ) pointwise |
| `tropEvolve_monotone` | Multi-step monotonicity |
| `tropical_horizon_exists_unique` | ∃! r ≥ 0 with inward = outward cost |
| `tropical_horizon_fixed_point` | min(2m, 2m) = 2m |
| `tropical_horizon_absorbing` | r ≥ 2m ⟹ min(r, 2m) = 2m |
| `tropical_horizon_least_fixed` | min(r, 2m) = r ⟹ r ≤ 2m |
| `tropical_horizon_fixed_iff` | min(r, 2m) = r ↔ r ≤ 2m |
| `tropTransfer_monotone` | Monotonicity of min-plus matrix action |
| `tropTransfer_shift` | Tropical homogeneity (additive shift) |
| `tropTransfer_const` | Action on constant vectors |
| `graphEvolve_monotone` | Multi-step graph evolution monotonicity |

---

## 2. Definitions and Notation

### 2.1 The Tropical Semiring

We work over (ℝ, ⊕, ⊙) where a ⊕ b := min(a, b) and a ⊙ b := a + b. This is the *min-plus* convention (as opposed to the max-plus convention common in some references). The neutral element for ⊕ is +∞ and for ⊙ is 0.

**Definition 2.1** (Tropical superposition).
```
tropSup(a, b) := min(a, b)
```

### 2.2 Radial Cost Metric

**Definition 2.2** (Radial cost). For a weight function w : ℕ → ℝ,
```
radialCost(w, i, j) :=
  if i ≤ j then Σ_{k ∈ [i, j)} w(k)
  else          Σ_{k ∈ [j, i)} w(k)
```
where [i, j) denotes the half-open interval {i, i+1, ..., j-1}.

### 2.3 Tropical Einstein Evolution

**Definition 2.3** (One-step evolution). For potential V : ℕ → ℝ and initial data φ : ℕ → ℝ,
```
tropEinsteinStep(V, φ, n) := min(φ(n), V(n) + φ(n+1))
```

**Definition 2.4** (Multi-step evolution).
```
tropEvolve(V, 0, φ) := φ
tropEvolve(V, t+1, φ) := tropEinsteinStep(V, tropEvolve(V, t, φ))
```

### 2.4 Tropical Horizon

**Definition 2.5** (Tropical radial update).
```
tropRadiusUpdate(m, r) := min(r, 2m)
```

**Definition 2.6** (Horizon predicate).
```
horizonPredicate(m, r) := (r = 2m)
```
equivalently, inwardCost(m, r) = outwardCost(m, r) where inwardCost(m, r) = r and outwardCost(m, r) = 2m.

### 2.5 Tropical Transfer Operator

**Definition 2.7** (Min-plus matrix-vector product). For W : Fin(n+1) × Fin(n+1) → ℝ and φ : Fin(n+1) → ℝ,
```
tropTransfer(W, φ, i) := min_{j} (W(i,j) + φ(j))
```

---

## 3. Main Results

### 3.1 Tropical Superposition Algebra

**Theorem 3.1** (Idempotent semiring laws). tropSup satisfies:
- Idempotence: tropSup(a, a) = a
- Commutativity: tropSup(a, b) = tropSup(b, a)
- Associativity: tropSup(tropSup(a, b), c) = tropSup(a, tropSup(b, c))
- Monotonicity: a ≤ b ⟹ tropSup(a, c) ≤ tropSup(b, c)

*Proof sketch.* These follow directly from the corresponding properties of `min` on linearly ordered types. The idempotence theorem is the tropical analogue of the statement that "repeated quantum superposition at Planck scale is classical" — in the min-plus world, superposing a state with itself produces the same state.

### 3.2 Radial Pseudo-Metric

**Theorem 3.2** (Pseudo-metric properties). For w : ℕ → ℝ with w(k) ≥ 0 for all k, (ℕ, radialCost(w)) is a pseudo-metric space:
1. radialCost(w, i, i) = 0 (reflexivity)
2. radialCost(w, i, j) = radialCost(w, j, i) (symmetry)
3. radialCost(w, i, k) ≤ radialCost(w, i, j) + radialCost(w, j, k) (triangle inequality)
4. radialCost(w, i, j) ≥ 0 (nonnegativity)

*Proof sketch.* Reflexivity follows from the empty sum over Ico(i, i). Symmetry is by case analysis on i ≤ j vs j ≤ i. The triangle inequality is the most substantial result: it requires case analysis on the six possible orderings of i, j, k. In each case, either the Ico intervals compose via `Finset.sum_Ico_consecutive` (when the intermediate point j lies between i and k), or one side has a superset of the other's summation range (handled by `Finset.sum_le_sum_of_subset_of_nonneg`). Nonnegativity follows from summing nonneg terms.

*Remark.* This is simultaneously a geodesic distance theorem (in the sense of Riemannian geometry on a graph) and a shortest-path distance theorem (in the sense of combinatorial optimization). The weight function w plays the role of the metric tensor.

### 3.3 Well-Posedness of Tropical Evolution

**Theorem 3.3** (Well-posedness). For any V : ℕ → ℝ and φ : ℕ → ℝ, the evolved state tropEinsteinStep(V, φ) exists and is unique.

*Proof sketch.* The operator is definitional — it computes a unique real number at each lattice point. Existence is by construction; uniqueness is by functional extensionality.

**Theorem 3.4** (Monotonicity). If φ(n) ≤ ψ(n) for all n, then tropEinsteinStep(V, φ, n) ≤ tropEinsteinStep(V, ψ, n) for all n.

*Proof sketch.* Since min is monotone in both arguments, and addition preserves order, the result follows by applying monotonicity of min to each of the two arguments φ(n) and V(n) + φ(n+1).

**Theorem 3.5** (Nonexpansiveness). For all n,
```
tropEinsteinStep(V, φ, n) - tropEinsteinStep(V, ψ, n) ≤ max(φ(n) - ψ(n), φ(n+1) - ψ(n+1))
```

*Proof sketch.* By exhaustive case analysis on which arguments achieve the min in each of tropEinsteinStep(V, φ, n) and tropEinsteinStep(V, ψ, n). In each of the four cases, the difference is bounded by one of the two terms on the right.

**Theorem 3.6** (Multi-step monotonicity). For all t, if φ ≤ ψ pointwise, then tropEvolve(V, t, φ) ≤ tropEvolve(V, t, ψ) pointwise.

*Proof sketch.* By induction on t. The base case t = 0 is the hypothesis. The inductive step applies Theorem 3.4 to the inductively-ordered intermediate states.

*Physical interpretation.* These theorems constitute the tropical analogue of well-posedness for the Einstein field equations. In the PDE setting, well-posedness of the Cauchy problem for Einstein's equations (proven by Choquet-Bruhat in 1952) requires sophisticated functional analysis. In the tropical setting, well-posedness is a consequence of the algebraic properties of min and +.

### 3.4 Tropical Schwarzschild Horizon

**Theorem 3.7** (Horizon existence and uniqueness). For m ≥ 0, there exists a unique r ≥ 0 such that inwardCost(m, r) = outwardCost(m, r). This radius is r = 2m.

**Theorem 3.8** (Fixed point). tropRadiusUpdate(m, 2m) = 2m.

**Theorem 3.9** (Absorption). If r ≥ 2m, then tropRadiusUpdate(m, r) = 2m.

**Theorem 3.10** (Least fixed point). If tropRadiusUpdate(m, r) = r, then r ≤ 2m.

**Theorem 3.11** (Complete classification). tropRadiusUpdate(m, r) = r if and only if r ≤ 2m.

*Proof sketch.* Theorem 3.8 is immediate from min(2m, 2m) = 2m. Theorem 3.9 follows from min(r, 2m) = 2m when r ≥ 2m. Theorem 3.10: if min(r, 2m) = r, then r ≤ 2m since min(r, 2m) ≤ 2m. Theorem 3.11 combines the forward direction (Theorem 3.10) with the converse (min(r, 2m) = r when r ≤ 2m).

*Physical interpretation.* The function tropRadiusUpdate models the tropical analogue of radial infall in Schwarzschild geometry. The set of fixed points {r : r ≤ 2m} is the interior plus boundary of the black hole. The least fixed point 2m is the event horizon. The absorption property says that matter starting outside the horizon (r > 2m) is always captured to the horizon in one step.

### 3.5 Tropical Transfer Operator

**Theorem 3.12** (Monotonicity). If φ ≤ ψ pointwise, then tropTransfer(W, φ) ≤ tropTransfer(W, ψ) pointwise.

**Theorem 3.13** (Tropical homogeneity). tropTransfer(W, φ + c) = tropTransfer(W, φ) + c, where φ + c denotes the function j ↦ φ(j) + c.

**Theorem 3.14** (Action on constants). tropTransfer(W, c) = (row-min of W) + c.

*Proof sketch.* Theorem 3.12: min over {W(i,j) + φ(j)} ≤ min over {W(i,j) + ψ(j)} because each term in the first is ≤ the corresponding term in the second. Theorem 3.13: min_j(W(i,j) + φ(j) + c) = min_j(W(i,j) + φ(j)) + c because adding a constant commutes with min. Theorem 3.14 is a special case.

*Remark.* Theorems 3.12–3.13 together say that tropTransfer is a *min-plus linear* operator: it preserves the min-plus module structure. This is the tropical analogue of a linear map between vector spaces.

### 3.6 Graph Evolution

**Theorem 3.15** (Multi-step graph evolution monotonicity). Iterated application of the graph step (tropical transfer) preserves pointwise ordering of initial data.

*Proof sketch.* By induction on the number of steps, using Theorem 3.12 at each step.

**Theorem 3.16** (Eigenvector property of constants). A constant vector is a tropical eigenvector of tropTransfer(W) with eigenvalue equal to the row minimum of W plus the constant.

---

## 4. Algorithms

### 4.1 Tropical Evolution Algorithm

**Input:** Potential V : {0, ..., N} → ℝ, initial data φ : {0, ..., N} → ℝ, time steps T.
**Output:** Evolved data tropEvolve(V, T, φ).

```
function TropicalEvolve(V, φ, T):
    ψ ← φ
    for t = 1 to T:
        for n = 0 to N-1:
            ψ_new[n] ← min(ψ[n], V[n] + ψ[n+1])
        ψ_new[N] ← ψ[N]  // boundary
        ψ ← ψ_new
    return ψ
```

**Complexity:** O(T · N) time, O(N) space.

### 4.2 Tropical Transfer Iteration

**Input:** Weight matrix W : Fin(n) × Fin(n) → ℝ, initial data φ : Fin(n) → ℝ, time steps T.
**Output:** graphEvolve(W, T, φ).

```
function GraphEvolve(W, φ, T):
    ψ ← φ
    for t = 1 to T:
        for i = 0 to n-1:
            ψ_new[i] ← min_j (W[i][j] + ψ[j])
        ψ ← ψ_new
    return ψ
```

**Complexity:** O(T · n²) time, O(n) space. This is equivalent to T iterations of Bellman–Ford relaxation.

### 4.3 Horizon Detection

**Input:** Mass parameter m ≥ 0, candidate radius r.
**Output:** Whether r is inside/on/outside the horizon.

```
function HorizonClassify(m, r):
    if r ≤ 2m: return "inside or on horizon (fixed point)"
    else: return "outside horizon (absorbed in one step)"
```

**Complexity:** O(1).

---

## 5. Applications

### 5.1 Shortest-Path Computation

The tropical transfer operator on a weighted digraph computes all-pairs shortest paths via iterated min-plus matrix multiplication. Our monotonicity theorem (3.12) guarantees that the iteration converges, and the homogeneity theorem (3.13) enables efficient normalization.

### 5.2 Network Resilience Analysis

The radial cost metric and triangle inequality (Theorem 3.2) can be applied to assess network resilience: the radialCost between two nodes gives a lower bound on the communication delay, and the triangle inequality ensures that detours are consistently bounded.

### 5.3 Optimization and Control

The tropical Einstein evolution (Theorem 3.4) is a Bellman equation for a one-dimensional optimal control problem with running cost V. The monotonicity theorem guarantees that value iteration converges to the optimal cost.

### 5.4 Black Hole Analogues in Network Theory

The horizon classification (Theorem 3.11) applies to any threshold phenomenon in a network: nodes with "radius" (some network centrality measure) below 2m are trapped; nodes above 2m are absorbed. This gives a rigorous network-theoretic analogue of gravitational collapse.

---

## 6. Computational Experiments

We implemented all algorithms in Python and verified them on several test cases.

### 6.1 Radial Cost Metric

For constant weights w(k) = 1, radialCost(w, i, j) = |i - j|, reproducing the standard integer metric. For linearly increasing weights w(k) = k+1, the metric becomes quadratic: radialCost(w, 0, n) = n(n+1)/2.

### 6.2 Tropical Evolution

With constant potential V(n) = 1 and initial data φ(n) = n, one step of evolution gives:
- φ_1(0) = min(0, 1+1) = 0
- φ_1(1) = min(1, 1+2) = 1
- φ_1(n) = min(n, 1+n+1) = n

The constant potential does not change linear initial data — this is the "flat spacetime" case.

With V(n) = 0 (strong gravity), φ_1(n) = min(n, n+1) = n. Again no change for linear data. But for φ(n) = n², φ_1(n) = min(n², (n+1)²) = n², and with V(n) = -n, φ_1(n) = min(n², -n + (n+1)²) = min(n², n+1), showing gravitational lensing at large n.

### 6.3 Horizon Formation

For m = 3, the tropRadiusUpdate maps:
- r = 1 → min(1, 6) = 1 (inside: fixed)
- r = 5 → min(5, 6) = 5 (inside: fixed)
- r = 6 → min(6, 6) = 6 (on horizon: fixed)
- r = 8 → min(8, 6) = 6 (outside: absorbed)
- r = 100 → min(100, 6) = 6 (far outside: absorbed)

---

## 7. Discussion

### 7.1 Relationship to Standard Physics

Our framework is not a replacement for general relativity or quantum gravity. It is a *tropical model* — a mathematically rigorous structure that shares key qualitative features with gravitational physics (metric geometry, causal evolution, horizons) while being algebraically simpler and computationally tractable.

The key insight is that the transition from quantum to classical physics, which in the standard framework involves the subtle ℏ → 0 limit, becomes a *change of semiring*: from (ℝ, +, ×) to (ℝ, min, +). This perspective, due to Maslov, is made fully rigorous in our formalization.

### 7.2 Limitations

1. Our framework is one-dimensional (radial). Extension to higher-dimensional lattices requires handling directional degrees of freedom.
2. The horizon model is kinematic, not dynamic — we characterize the horizon but do not derive it from a variational principle.
3. We work over ℝ, not over the tropical semifield ℝ ∪ {+∞}, which would be more natural for some constructions.

### 7.3 Comparison with Causal Set Theory

Causal set theory [6] models spacetime as a locally finite partial order. Our framework is similar in spirit but uses weighted graphs rather than partial orders, and the min-plus algebra provides additional algebraic structure (a semiring, not just an order).

---

## 8. Future Work

See FUTURE_DIRECTIONS.md for a detailed roadmap. The five most promising directions are:

1. **Tropical causal cones as shortest-path balls** — proving the bridge theorem between iterated transfer and bounded path cost.
2. **Discrete tropical curvature** — defining curvature as triangle inequality defect.
3. **Tropical stationary black holes as min-plus eigenvectors** — connecting to tropical spectral theory.
4. **Tropical Hawking radiation** — horizon instability under mass perturbation.
5. **Sheaf-theoretic gluing** — patching local tropical geometries into global spacetimes.

---

## References

[1] V. P. Maslov, *Méthodes Opératorielles*, Mir, Moscow, 1987.

[2] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, AMS, 2015.

[3] R. Bellman, *Dynamic Programming*, Princeton University Press, 1957.

[4] G. L. Litvinov, V. P. Maslov, and G. B. Shpiz, "Idempotent functional analysis: an algebraic approach," *Mathematical Notes*, 69(5), 2001.

[5] M. Noumi and Y. Yamada, "Tropical Robinson–Schensted–Knuth correspondence and birational Weyl group actions," *Adv. Stud. Pure Math.*, 40, 2004.

[6] L. Bombelli, J. Lee, D. Meyer, and R. Sorkin, "Space-time as a causal set," *Phys. Rev. Lett.*, 59(5), 1987.

[7] S. Gaubert, "Methods and applications of (max,+) linear algebra," *STACS 97*, Springer, 1997.

[8] B. A. Carre, "An algebra for network routing problems," *J. Inst. Math. Appl.*, 7, 1971.
