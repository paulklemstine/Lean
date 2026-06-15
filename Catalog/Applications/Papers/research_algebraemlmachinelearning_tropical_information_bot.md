# Tropical Information Bottleneck Duality via Closure Capacities and Neural Operad Rate Regions

## Abstract

We establish a rigorous min-plus information bottleneck theorem that unifies
closure-theoretic semantics of representation, operadic compositional complexity
of neural architectures, and rate-distortion duality in tropical algebra. The
main result proves that under a finite observer sufficiency hypothesis, the
tropical bottleneck value function — defined as the infimum of a scalarized
capacity-distortion objective over all admissible latent representations —
equals the minimum over a finite operadic observer spectrum. This reduces an
infinite-dimensional optimization problem to a finite combinatorial one. We
further prove that the bottleneck function is piecewise affine, that its slopes
are contained in the finite distortion spectrum, that the set of breakpoints is
finite, and that the certified rate region equals the upward closure of the
observer spectrum. All results are machine-verified with complete proofs.

**Keywords:** tropical information bottleneck, min-plus Legendre transform,
closure capacity, operadic compression spectrum, rate-distortion duality,
certified rate region, piecewise-affine value function.

---

## 1. Introduction

### 1.1 Motivation

The information bottleneck (IB) method, introduced by Tishby, Pereira, and
Bialek (2000), provides a principled framework for balancing compression and
prediction in representation learning. Given a joint distribution P(X,Y), the
IB seeks a compressed representation Z that minimizes I(X;Z) − β·I(Z;Y), where
I denotes mutual information and β controls the trade-off.

While powerful, the classical IB framework is inherently probabilistic. It
requires a joint distribution, relies on Shannon entropy, and produces results
in expectation. Many machine learning settings — particularly those involving
deterministic neural networks, algebraic feature maps, or worst-case guarantees
— call for a non-probabilistic alternative.

### 1.2 Tropical Algebra and the Min-Plus Paradigm

Tropical (min-plus) algebra replaces the usual arithmetic operations: addition
becomes minimum (⊕ = min), multiplication becomes addition (⊗ = +). This
"dequantization" (Litvinov 2007) transforms optimization into algebra.

In the tropical setting:
- **Closure capacity** Cap_cl(X → Z) replaces mutual information I(X;Z) as the
  primal resource measure.
- **Tropical distortion** D_trop(Z,Y) replaces conditional entropy H(Y|Z) as
  the fidelity measure.
- The **bottleneck value function** B(β) = inf_Z [Cap(X→Z) ⊕ (β ⊗ D(Z,Y))] =
  inf_Z [Cap(X→Z) + β · D(Z,Y)] replaces the IB Lagrangian.

### 1.3 Operadic Architecture Semantics

Neural architectures compose via operadic composition: a depth-k network is a
k-fold operadic composite of layer operations. Each compositional factorization
produces a different latent representation Z with its own capacity-distortion
pair (c, d). The collection of all such pairs is the *operadic compression
spectrum*.

### 1.4 Main Contribution

We prove that under a natural **observer sufficiency** condition — every
admissible latent is dominated by some canonical observer factor — the
bottleneck value function is:

1. **Exactly computable** as a finite minimum over the observer spectrum.
2. **Piecewise affine** with slopes from the distortion spectrum.
3. **Tropically dual** to the observer spectrum via the min-plus Legendre transform.

This establishes closure capacities as primal objects, tropical bottleneck values
as their min-plus convex conjugates, and operadic spectra as dual certificates.

---

## 2. Definitions and Notation

### 2.1 Observer Spectrum

Let ι be an index type and R a linearly ordered semiring.

**Definition 2.1** (Objective). For functions cap, dist : ι → R and parameter β ∈ R:
```
objective(cap, dist, β, i) = cap(i) + β · dist(i)
```

**Definition 2.2** (Bottleneck Value). For a nonempty finite set Obs ⊆ ι:
```
B(β) = bottleneckVal(Obs, cap, dist, β) = inf'_{i ∈ Obs} objective(cap, dist, β, i)
```

**Definition 2.3** (Certified Rate Region).
```
R = { (c, d) ∈ R² : ∃ i ∈ Obs, cap(i) ≤ c ∧ dist(i) ≤ d }
```

### 2.2 Observer Sufficiency

**Definition 2.4** (Observer Sufficiency). Given a type Z of latent representations,
a set Adm ⊆ Z of admissible latents, and functions Cap : Z → R, Dist : Z → R,
the observer spectrum Obs satisfies observer sufficiency if:
```
∀ z ∈ Adm, ∃ i ∈ Obs, cap_obs(i) ≤ Cap(z) ∧ dist_obs(i) ≤ Dist(z)
```

**Definition 2.5** (Realizability). Each observer is realized by some admissible latent:
```
∀ i ∈ Obs, ∃ z ∈ Adm, Cap(z) = cap_obs(i) ∧ Dist(z) = dist_obs(i)
```

---

## 3. Main Results

### 3.1 Bottleneck Realization (Theorem B)

**Theorem 3.1** (Bottleneck Realization). *For any nonempty finite Obs and any β,
there exists i ∈ Obs such that B(β) = objective(cap, dist, β, i).*

*Proof.* This is the Finset.exists_mem_eq_inf' lemma from Mathlib applied to the
objective function. The key point is that the infimum of a finite set is attained. □

### 3.2 Scalarization Monotonicity (Theorem C)

**Theorem 3.2** (Scalarization Monotonicity). *If cap(i) ≤ cap(j) and dist(i) ≤ dist(j)
and β ≥ 0, then objective(cap, dist, β, i) ≤ objective(cap, dist, β, j).*

*Proof.* By add_le_add and mul_le_mul_of_nonneg_left:
```
cap(i) + β · dist(i) ≤ cap(j) + β · dist(j)
```
using cap(i) ≤ cap(j) for the first term and 0 ≤ β with dist(i) ≤ dist(j) for
the second. □

### 3.3 Main Duality Theorem (Theorem D)

**Theorem 3.3** (Tropical Bottleneck Duality). *Under observer sufficiency and
realizability, for all β ≥ 0:*
```
inf'_{i ∈ Obs} (cap_obs(i) + β · dist_obs(i)) = sInf { Cap(z) + β · Dist(z) : z ∈ Adm }
```

*Proof sketch.* By antisymmetry of ≤:

**Direction 1 (≤):** For any z ∈ Adm, observer sufficiency gives i ∈ Obs with
cap_obs(i) ≤ Cap(z) and dist_obs(i) ≤ Dist(z). By scalarization monotonicity,
inf' ≤ cap_obs(i) + β · dist_obs(i) ≤ Cap(z) + β · Dist(z). Since this holds
for all z ∈ Adm, inf' ≤ sInf by le_csInf.

**Direction 2 (≥):** For each i ∈ Obs, realizability gives z ∈ Adm with
Cap(z) + β · Dist(z) = cap_obs(i) + β · dist_obs(i). So sInf ≤ cap_obs(i) + β · dist_obs(i)
by csInf_le. Since this holds for all i ∈ Obs, sInf ≤ inf' by le_inf'.

The BddBelow condition required for csInf_le is verified by observing that inf'
(from Direction 1) is a lower bound for the image set. □

### 3.4 Piecewise Affine Structure (Theorem E)

**Theorem 3.4** (Piecewise Affine). *For all β, there exist m ∈ {dist(i) : i ∈ Obs}
and b ∈ {cap(i) : i ∈ Obs} such that B(β) = b + β · m.*

*Proof.* Immediate from Theorem 3.1 by extracting dist(i) and cap(i) from the
realizing observer. □

### 3.5 Extreme Observer (Theorem F)

**Theorem 3.5** (Extreme Observer). *For every β, there exists i ∈ Obs such that
objective(cap, dist, β, i) ≤ objective(cap, dist, β, j) for all j ∈ Obs.*

*Proof.* By Finset.exists_min_image. □

### 3.6 Finite Breakpoints (Theorem G)

**Theorem 3.6** (Finite Breakpoints). *The set of β values where two distinct
observers with different distortions tie is finite.*

*Proof.* The set is contained in the image of the finite set Obs.offDiag under
the map (i, j) ↦ (cap(j) − cap(i)) / (dist(i) − dist(j)), which is finite.
The containment is proved by solving the equation cap(i) + β·dist(i) = cap(j) + β·dist(j)
for β when dist(i) ≠ dist(j). □

### 3.7 Certified Rate Region (Theorems H, I)

**Theorem 3.7** (Rate Region Membership). *Under observer sufficiency, for any
z ∈ Adm, the pair (Cap(z), Dist(z)) lies in the certified rate region.*

**Theorem 3.8** (Upward Closure). *The certified rate region is upward closed:
if (c, d) ∈ R and c ≤ c', d ≤ d', then (c', d') ∈ R.*

---

## 4. Algorithms

### 4.1 Bottleneck Computation

**Algorithm 1:** Compute B(β) for a given β.

```
Input: Obs = {(c₁,d₁), ..., (cₙ,dₙ)}, β ≥ 0
Output: B(β) and optimal observer index
1. For each i ∈ {1,...,n}: compute v_i = c_i + β · d_i
2. Return min(v₁, ..., vₙ) and the minimizing index
Time: O(n)
Space: O(1) beyond input
```

### 4.2 Breakpoint Enumeration

**Algorithm 2:** Enumerate all breakpoints of B(β).

```
Input: Obs = {(c₁,d₁), ..., (cₙ,dₙ)}
Output: Sorted list of active breakpoints
1. For each pair (i,j) with d_i ≠ d_j:
     compute β* = (c_j - c_i) / (d_i - d_j)
2. Filter: keep only β* ≥ 0 where both i,j are on the lower envelope at β*
3. Sort and return
Time: O(n² log n)
Space: O(n²)
```

### 4.3 Complete Trade-off Curve

**Algorithm 3:** Compute the full piecewise-affine trade-off curve.

```
Input: Obs = {(c₁,d₁), ..., (cₙ,dₙ)}
Output: List of (β_start, β_end, slope, intercept) segments
1. Compute all breakpoints (Algorithm 2)
2. Sort breakpoints: 0 = β₀ < β₁ < ... < β_k
3. For each interval [β_j, β_{j+1}]:
     find optimal observer at midpoint (β_j + β_{j+1})/2
     record (β_j, β_{j+1}, d_opt, c_opt)
4. Handle the last interval [β_k, ∞)
Time: O(n² log n)
Space: O(n²)
```

---

## 5. Applications

### 5.1 Neural Architecture Comparison

Given a set of neural architectures with measured capacity-distortion pairs:

| Architecture | Capacity (c) | Distortion (d) |
|-------------|-------------|----------------|
| Deep-Narrow | 1.0 | 5.0 |
| Medium | 2.5 | 2.0 |
| Wide-Shallow | 4.0 | 1.0 |
| Balanced | 2.0 | 3.0 |
| Ultra-Compressed | 0.5 | 8.0 |

The bottleneck function B(β) is:
- B(0) = 0.5 (Ultra-Compressed dominates — pure capacity minimization)
- B(0.167) = 1.83 (breakpoint: Ultra-Compressed ↔ Deep-Narrow)
- B(0.5) = 3.5 (breakpoint: Deep-Narrow ↔ Medium)
- B(1.5) = 5.5 (breakpoint: Medium ↔ Wide-Shallow)
- B(β) → 4.0 + β as β → ∞ (Wide-Shallow dominates — high distortion weight)

### 5.2 Certified Compression Guarantees

The rate region certificate says: any compression scheme achieving (c, d) must
satisfy c ≥ c_i and d ≥ d_i for some observer i. This gives lower bounds on
the cost of compression.

For example, no architecture can simultaneously achieve capacity < 0.5 and
distortion < 1.0, since no observer in the spectrum dominates such a pair.

---

## 6. Computational Experiments

We implemented the algorithms in Python and verified the theoretical predictions.

### 6.1 Lower Envelope Verification

For the 5-observer example above, we computed B(β) at 1000 uniformly spaced
points in [0, 5] and verified:
- B(β) = cap(i*) + β · dist(i*) for the optimal observer i* at each β
- Piecewise-affine structure with exactly 3 active breakpoints at β ∈ {0.167, 0.5, 1.5}
- Slopes decrease monotonically: {8.0, 5.0, 2.0, 1.0}

### 6.2 Domination Analysis

The scalarization monotonicity theorem predicts that if observer i dominates
observer j (c_i ≤ c_j and d_i ≤ d_j), then i is never worse than j at any β ≥ 0.
In our example, no observer strictly dominates another, confirming that all five
observers contribute to the lower envelope or the rate region boundary.

---

## 7. Discussion

### 7.1 Relationship to Classical Information Bottleneck

The classical IB minimizes I(X;Z) − β·I(Z;Y) over the space of conditional
distributions P(Z|X). Our tropical analogue minimizes Cap(X→Z) + β·D(Z,Y) over
the space of admissible latent representations. The key differences:

| Classical IB | Tropical IB |
|-------------|-------------|
| Probabilistic (P(X,Y)) | Deterministic/algebraic |
| Shannon entropy | Closure capacity |
| Mutual information | Tropical distortion |
| Convex optimization | Finite min-plus algebra |
| Rate-distortion curve | Piecewise-affine envelope |

### 7.2 Role of Observer Sufficiency

Observer sufficiency is the tropical analogue of the "sufficient statistic"
condition in classical statistics. It ensures that the finite observer spectrum
captures all relevant compression-distortion trade-offs. In practice, this
condition holds when:
- The architecture space is finitely generated (e.g., by operadic composition
  of a finite set of layer types),
- The closure operator has finite rank (finitely generated idempotent semiring),
- The distortion measure is compatible with the operadic structure.

### 7.3 Connections to Tropical Geometry

The bottleneck function B(β) is a *tropical polynomial* in one variable: the
minimum of finitely many affine functions. Its graph is a tropical curve. The
breakpoints are the *tropical roots*. The observer spectrum is a point
configuration whose *tropical convex hull* determines B.

In higher dimensions (multiple targets), the bottleneck becomes a function of
(β₁, ..., β_k) and its graph is a tropical hypersurface — a piecewise-linear
complex with rich geometric structure.

---

## 8. Future Work

See FUTURE_DIRECTIONS.md for detailed research roadmap including:
1. Tropical data processing inequality for closure capacities
2. Blackwell sufficiency for idempotent operadic channels
3. Multi-observer tropical rate regions and Pareto fronts
4. Phase transition theorems for breakpoint geometry
5. Tropical variational principles for deep compositional encoders

---

## 9. References

1. Tishby, N., Pereira, F., and Bialek, W. (2000). The information bottleneck method. *Proceedings of the 37th Allerton Conference*.

2. Litvinov, G.L. (2007). Maslov dequantization, idempotent and tropical mathematics: a brief introduction. *Journal of Mathematical Sciences*, 140(3), 373-386.

3. Shannon, C.E. (1959). Coding theorems for a discrete source with a fidelity criterion. *IRE National Convention Record*, 7(4), 142-163.

4. Lawvere, F.W. (1973). Metric spaces, generalized logic, and closed categories. *Rendiconti del Seminario Matematico e Fisico di Milano*, 43, 135-166.

5. Leinster, T. (2004). *Higher Operads, Higher Categories*. London Mathematical Society Lecture Note Series 298, Cambridge University Press.

6. Maclagan, D. and Sturmfels, B. (2015). *Introduction to Tropical Geometry*. Graduate Studies in Mathematics 161, AMS.

7. Pachter, L. and Sturmfels, B. (2004). Tropical geometry of statistical models. *Proceedings of the National Academy of Sciences*, 101(46), 16132-16137.

8. Joswig, M. (2021). *Essentials of Tropical Combinatorics*. Graduate Studies in Mathematics 219, AMS.
