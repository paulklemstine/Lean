# Tropical Source Coding: Exact Min-Plus Rate-Distortion Theory for Finite Types

## Abstract

We develop an exact finite rate-distortion theory in the tropical (min-plus) semiring. For a source potential φ : α → ℝ on a finite alphabet and a distortion kernel d : α → β → ℝ, we define the tropical rate-distortion function R(D) = min_y max_x (φ(x) − d(x,y)) − D and prove that it equals the infimum of the feasible rate set {r | ∃ y, ∀ x, φ(x) − r ≤ d(x,y) + D} exactly—without asymptotic gap. This exactness theorem, proved in the Lean 4 proof assistant with full machine verification, establishes that in the tropical setting the achievability-converse gap of classical Shannon theory vanishes identically. We prove structural properties including antitonicity, 1-Lipschitz continuity, shift equivariance, source potential monotonicity, and min-plus convexity. We further establish a dual characterization via feasible sets and demonstrate the theory with concrete numerical examples. The results connect tropical information theory to facility location, dynamic programming, mathematical morphology, and zero-temperature statistical mechanics.

## 1. Introduction

### 1.1 Motivation

Shannon's source coding theorem [Shannon, 1948] establishes that the minimum rate for lossy compression at distortion level D is given by the rate-distortion function R(D) = min_{p(y|x)} I(X;Y) subject to E[d(X,Y)] ≤ D. This function is achievable only in the limit of infinite block length: for any finite block length n, the best achievable rate exceeds R(D) by a term of order O(1/n).

This paper asks: **Is there a natural algebraic framework in which the gap vanishes identically?**

We answer affirmatively by developing rate-distortion theory over the tropical (min-plus) semiring (ℝ, min, +). In this framework:

- Sources are described by potential functions φ : α → ℝ rather than probability distributions.
- Distortion is a cost kernel d : α → β → ℝ.
- The aggregation operation is min/max rather than expectation.
- The rate-distortion function is defined by a finite optimization.

The central theorem (Theorem 3.1) proves that the optimal coding cost equals the tropical rate-distortion function exactly for finite alphabets.

### 1.2 Related Work

**Tropical mathematics.** The min-plus semiring and its algebraic properties have been studied extensively [Litvinov, 2007; Maclagan & Sturmfels, 2015]. Tropical convexity and Legendre-Fenchel transforms in the idempotent setting were developed by [Akian et al., 2012; Singer, 2007].

**Idempotent probability.** Maslov's idempotent analysis [Maslov & Kolokoltsov, 1997] provides the foundations for replacing probabilistic structures with min-plus algebraic ones, establishing the "dequantization" principle.

**Min-plus rate-distortion.** The connection between tropical algebra and source coding was observed in [Maragos, 2005] in the context of mathematical morphology. Prior work established basic tropical source coding bounds but did not prove exact duality.

**Max-plus linear algebra.** The theory of matrices over the max-plus semiring [Baccelli et al., 1992; Butkovič, 2010] provides algorithmic foundations.

### 1.3 Contributions

1. **Exact duality theorem** (Theorem 3.1): For finite types, the optimal tropical code cost equals the rate-distortion function.
2. **Dual characterization** (Theorem 4.1): The rate-distortion function equals the infimum of the feasible rate set.
3. **No Shannon gap** (Theorem 5.1): Achievable and converse rates coincide exactly.
4. **Structural properties** (Section 6): Antitonicity, Lipschitz continuity, shift equivariance, monotonicity, min-plus convexity.
5. **Full machine verification** in Lean 4 with the Mathlib library.

## 2. Definitions

### 2.1 Setup

Throughout, let α and β be finite nonempty types.

**Definition 2.1** (Tropical Source). A *tropical source* is a function φ : α → ℝ, interpreted as assigning a cost or potential to each source symbol.

**Definition 2.2** (Distortion Kernel). A *distortion kernel* is a function d : α → β → ℝ, where d(x, y) represents the cost of representing source symbol x by reproduction symbol y.

**Definition 2.3** (Tropical Distortion Profile). The *tropical distortion profile* at reproduction symbol y is:

ψ(y) = max_{x ∈ α} (φ(x) − d(x, y))

This is the worst-case net cost (source potential minus distortion) when using y as the reproduction symbol. In the terminology of mathematical morphology, ψ is the *dilation* of φ by the kernel d.

**Definition 2.4** (Tropical Rate-Distortion Function). The *tropical rate-distortion function* is:

R(D) = min_{y ∈ β} ψ(y) − D = min_{y ∈ β} max_{x ∈ α} (φ(x) − d(x, y)) − D

**Definition 2.5** (Tropical Feasibility). A rate r is *tropically feasible* at distortion budget D if there exists y ∈ β such that for all x ∈ α:

φ(x) − r ≤ d(x, y) + D

The *feasible set* is S(D) = {r ∈ ℝ | ∃ y ∈ β, ∀ x ∈ α, φ(x) − r ≤ d(x, y) + D}.

**Definition 2.6** (Optimal Code Cost). The *optimal tropical code cost* is:

C*(D) = inf S(D) = inf {r ∈ ℝ | ∃ y ∈ β, ∀ x ∈ α, φ(x) − r ≤ d(x, y) + D}

### 2.2 Formal Lean Definitions

The definitions are formalized in Lean 4 as follows:

```lean
noncomputable def tropicalDistortionProfile
    {α β : Type*} [Fintype α] [Nonempty α]
    (φ : α → ℝ) (d : α → β → ℝ) (y : β) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun x => φ x - d x y)

noncomputable def tropicalRateDistortion
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  Finset.univ.inf' Finset.univ_nonempty
    (fun y => tropicalDistortionProfile φ d y) - D

def tropicalFeasibleSet
    {α β : Type*}
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) : Set ℝ :=
  {r | ∃ y : β, ∀ x : α, φ x - r ≤ d x y + D}

noncomputable def tropicalOptimalCodeCost
    {α β : Type*}
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) : ℝ :=
  sInf (tropicalFeasibleSet φ d D)
```

## 3. Main Result: Exact Duality

### Theorem 3.1 (Tropical Rate-Distortion Exactness)

*For finite nonempty types α and β, source potential φ : α → ℝ, distortion kernel d : α → β → ℝ, and distortion budget D ∈ ℝ:*

C*(φ, d, D) = R(φ, d, D)

*That is, the infimum of the feasible rate set equals the tropical rate-distortion function.*

### Proof Sketch

The proof proceeds in two steps via an intermediate representation.

**Step 1 (Feasible Set Characterization).** We first show that the feasible set equals {r | ∃ y, ψ(y) − D ≤ r}. The forward direction: if r is feasible via witness y, then for all x, φ(x) − d(x,y) ≤ r + D, so ψ(y) = max_x(φ(x) − d(x,y)) ≤ r + D, giving ψ(y) − D ≤ r. The reverse direction: if ψ(y) − D ≤ r, then for each x, φ(x) − d(x,y) ≤ ψ(y) ≤ r + D.

**Step 2 (Infimum Attainment).** Since β is finite, let y* = argmin_{y∈β} ψ(y). Then:
- The value ψ(y*) − D is in S(D) (by Step 1), so C*(D) ≤ ψ(y*) − D.
- For every r ∈ S(D), there exists y with ψ(y) − D ≤ r, so ψ(y*) − D ≤ ψ(y) − D ≤ r, giving ψ(y*) − D ≤ C*(D).

Therefore C*(D) = ψ(y*) − D = min_y ψ(y) − D = R(D). ∎

### Formal Lean Statement

```lean
theorem tropicalRateDistortion_exact
    {α β : Type*} [Fintype α] [Fintype β] [Nonempty α] [Nonempty β]
    (φ : α → ℝ) (d : α → β → ℝ) (D : ℝ) :
    tropicalOptimalCodeCost φ d D = tropicalRateDistortion φ d D
```

### 3.1 Why the Gap Vanishes

In classical Shannon theory, the gap between achievability and converse arises because:
1. The optimal code is defined over the product type α^n, which grows exponentially.
2. Achievability relies on random coding over typical sets.
3. The converse uses Fano's inequality and data processing, which give strict inequalities for finite n.

In tropical theory, none of these mechanisms operate:
1. The source is α itself, not α^n—no block coding is needed.
2. The optimal code is found by deterministic finite search (argmin_y).
3. The converse is an exact algebraic inequality, not a probabilistic bound.

The gap is not "closed"—it never existed. The tropical framework sidesteps the mechanisms that create it.

## 4. Dual Characterization

### Theorem 4.1 (Tropical Rate-Distortion Dual)

R(D) = sInf {r ∈ ℝ | ∃ y : β, ∀ x : α, φ(x) − r ≤ d(x, y) + D}

This follows immediately from Theorem 3.1 by unfolding definitions.

### 4.1 Connection to Tropical Fenchel Duality

The rate-distortion function can also be viewed through the lens of tropical Legendre-Fenchel transforms. Define the tropical dual functional:

F(μ) = min_{y∈β} max_{x∈α} (φ(x) − μ · d(x, y))

Then R(D) = F(1) − D, and the companion file `TropicalRateDistortion.lean` proves:
- The tropical biconjugate inequality f** ≤ f.
- The biconjugate equality under separating kernel conditions.
- Finite minimax inequalities.

The connection between the primal form R(D) = min_y ψ(y) − D and the Legendre-Fenchel form R_LF(D) = sup_λ (F(λ) + λD) is that they agree at λ = 1.

## 5. No Shannon Gap

### Theorem 5.1 (No Shannon Gap)

*Define the tropical achievable rate and converse rate both as min_y ψ(y) − D. Then:*

tropicalAchievableRate φ d D = tropicalConverseRate φ d D

This is a definitional equality: both rates are defined as the same expression. The content is that, in contrast to classical theory where achievability and converse are defined by different mechanisms (random coding vs. Fano's inequality), in the tropical setting both collapse to the same finite optimization.

## 6. Structural Properties

### Theorem 6.1 (Antitonicity)
R(D) is antitone: D₁ ≤ D₂ implies R(D₂) ≤ R(D₁). More distortion budget means less rate needed.

*Proof.* R(D) = C − D where C = min_y ψ(y) is a constant. ∎

### Theorem 6.2 (1-Lipschitz)
|R(D₁) − R(D₂)| = |D₁ − D₂|. The rate-distortion function is exactly 1-Lipschitz.

*Proof.* R(D₁) − R(D₂) = (C − D₁) − (C − D₂) = D₂ − D₁. ∎

### Theorem 6.3 (Shift Equivariance)
R(φ + c, d, D) = R(φ, d, D) + c. Shifting all source potentials by a constant shifts the rate by the same constant.

*Proof.* The distortion profile shifts: ψ_{φ+c}(y) = max_x(φ(x) + c − d(x,y)) = ψ_φ(y) + c. So min_y ψ_{φ+c}(y) = min_y ψ_φ(y) + c. ∎

### Theorem 6.4 (Source Monotonicity)
If φ₁(x) ≤ φ₂(x) for all x, then R(φ₁, d, D) ≤ R(φ₂, d, D). Higher source potentials require higher rates.

*Proof.* For each y and x, φ₁(x) − d(x,y) ≤ φ₂(x) − d(x,y). Taking max over x and then min over y preserves the inequality. ∎

### Theorem 6.5 (Min-Plus Convexity)
R(min(D₁, D₂)) ≥ min(R(D₁), R(D₂)). The rate-distortion function is min-plus convex.

*Proof.* Since R is antitone and min(D₁, D₂) ≤ D₁ and min(D₁, D₂) ≤ D₂, we have R(D₁) ≤ R(min(D₁, D₂)) and R(D₂) ≤ R(min(D₁, D₂)), so min(R(D₁), R(D₂)) ≤ R(min(D₁, D₂)). ∎

### Theorem 6.6 (Attainment)
There exists y* ∈ β such that R(D) = ψ(y*) − D. The infimum is attained.

*Proof.* β is finite and nonempty, so the minimum of ψ over β is attained. ∎

### Theorem 6.7 (Distortion Profile Antitonicity)
If d₁(x,y) ≤ d₂(x,y) for all x, then ψ_{d₂}(y) ≤ ψ_{d₁}(y). Larger distortion kernels yield smaller profiles.

*Proof.* For each x, φ(x) − d₂(x,y) ≤ φ(x) − d₁(x,y). Taking max preserves the inequality. ∎

## 7. Computational Aspects

### 7.1 Algorithm

**Input:** Source potential φ : [n] → ℝ, distortion kernel d : [n] × [m] → ℝ, distortion budget D.
**Output:** R(D) and optimal reproduction symbol y*.

```
function TropicalRateDistortion(φ, d, D):
    best_y ← 0
    best_profile ← max_{x=1..n} (φ[x] - d[x][0])
    for y = 1 to m-1:
        profile ← max_{x=1..n} (φ[x] - d[x][y])
        if profile < best_profile:
            best_profile ← profile
            best_y ← y
    return (best_profile - D, best_y)
```

**Time complexity:** O(nm)
**Space complexity:** O(1) (beyond input)

### 7.2 Numerical Examples

**Example 1: Binary Source (Fin 2)**
- φ = [3, 1], d = [[0, 2], [2, 0]]
- ψ(0) = max(3−0, 1−2) = 3
- ψ(1) = max(3−2, 1−0) = 1
- R(0) = min(3, 1) − 0 = 1
- Optimal y* = 1

**Example 2: Ternary Source (Fin 3)**
- φ = [5, 3, 1], d = [[0,1,4],[1,0,1],[4,1,0]]
- ψ(0) = 5, ψ(1) = 4, ψ(2) = 2
- R(0) = 2, optimal y* = 2
- R(1) = 1, R(2) = 0, R(3) = −1

### 7.3 Verification

All numerical examples have been verified computationally in Python. The gap between the primal (R) and dual (C*) formulations is identically zero for all tested inputs, confirming the exactness theorem.

## 8. Cross-Domain Connections

### 8.1 Shortest Paths and Facility Location

The feasibility condition φ(x) − r ≤ d(x,y) + D is equivalent to saying that facility y covers client x with excess cost at most r + D − φ(x). The optimal code cost C*(D) is the minimum coverage slack needed for a single facility to serve all clients.

This connects tropical rate-distortion to:
- **1-center problem**: Find the point minimizing the maximum weighted distance.
- **Dominating set**: Find a node covering all others within a distance threshold.
- **Network design**: Minimum-cost hub location.

### 8.2 Dynamic Programming

Let φ be a value function, y a control action, and d(x,y) the stage cost of applying action y in state x. Then:
- ψ(y) = max_x (φ(x) − d(x,y)) is the worst-case value deficit under action y.
- R(D) = min_y ψ(y) − D is the optimal value minus the budget.

The exactness theorem says: the Bellman optimality equation has an exact solution in one stage.

### 8.3 Mathematical Morphology

The map y ↦ max_x (φ(x) − d(x,y)) is a morphological dilation of φ by the structuring element d. Tropical rate-distortion theory reinterprets data compression as finding the "most compact" dilation—the one with the smallest maximum value.

### 8.4 Zero-Temperature Limit

At inverse temperature β, the classical rate-distortion involves log-sum-exp:
R_β(D) ~ −(1/β) log min_y Σ_x exp(β(φ(x) − d(x,y))) − D

As β → ∞, log-sum-exp → max, recovering the tropical formula. The tropical theory is the zero-temperature (ground-state) limit of classical information theory.

## 9. Discussion

### 9.1 Exactness vs. Approximation

The most striking feature of tropical rate-distortion theory is its exactness. The gap between achievability and converse is structurally impossible in the min-plus framework because:

1. **Finite attainment**: Optimization over a finite set always achieves its optimum.
2. **Deterministic search**: The optimal code is found by exhaustive search, not random coding.
3. **Algebraic equality**: The converse is a direct inequality, not a probabilistic bound.

This suggests that the Shannon gap is not a fundamental feature of information but an artifact of the probabilistic framework.

### 9.2 Limitations

1. **Linearity in D**: The tropical rate-distortion function R(D) = C − D is affine in D, which is simpler than the classical convex rate-distortion curve. This reflects the simpler algebraic structure of the tropical semiring.
2. **Single-symbol coding**: The theory currently handles single-symbol codes (one reproduction symbol covers all source symbols). Extension to multi-symbol codes is a natural next step.
3. **No entropy**: The tropical framework does not have a direct analogue of Shannon entropy. The source potential φ plays the role of information content, but without a normalization condition.

### 9.3 Extensions

Several extensions are immediate:
- **Product sources**: Tensorization for φ₁ ⊗ φ₂ should give additive rate-distortion.
- **Channel coding**: A tropical channel capacity theory dual to rate-distortion.
- **Data processing**: A tropical DPI via min-plus kernel composition.
- **Multi-symbol codes**: Extension to k-center problems with k > 1 reproduction symbols.

## 10. Conclusion

We have established an exact rate-distortion theory in the tropical semiring, proving that for finite types the optimal coding cost equals the min-plus variational rate-distortion function without any asymptotic gap. The result is fully machine-verified in Lean 4, providing the highest possible confidence in its correctness. The theory connects information theory to combinatorial optimization, dynamic programming, mathematical morphology, and zero-temperature statistical mechanics, opening the door to idempotent information theory as a new mathematical discipline.

## References

1. Shannon, C. E. (1948). A mathematical theory of communication. *Bell System Technical Journal*, 27(3), 379–423.
2. Litvinov, G. L. (2007). The Maslov dequantization, and idempotent and tropical mathematics. *Journal of Mathematical Sciences*, 140(2), 209–226.
3. Maclagan, D., & Sturmfels, B. (2015). *Introduction to Tropical Geometry*. AMS.
4. Maslov, V. P., & Kolokoltsov, V. N. (1997). *Idempotent Analysis and Its Applications*. Kluwer.
5. Baccelli, F., Cohen, G., Olsder, G. J., & Quadrat, J.-P. (1992). *Synchronization and Linearity*. Wiley.
6. Butkovič, P. (2010). *Max-linear Systems: Theory and Algorithms*. Springer.
7. Akian, M., Gaubert, S., & Guterman, A. (2012). Tropical polyhedra are equivalent to mean payoff games. *International Journal of Algebra and Computation*, 22(01).
8. Singer, I. (2007). Abstract convex analysis. *Canadian Mathematical Society*.
9. Maragos, P. (2005). Lattice image processing: A unification of morphological and fuzzy algebraic systems. *Journal of Mathematical Imaging and Vision*, 22(2-3), 333–353.
