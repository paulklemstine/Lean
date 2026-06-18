# Spectral Gap and Curvature Variance Bounds on Triangulated Surfaces

## Abstract

We establish formally verified bounds relating the curvature variance of a triangulated surface to the spectral gap and Dirichlet energy of its graph Laplacian. For a finite triangulated closed surface with vertex set V, combinatorial curvature K, and graph Laplacian L with spectral gap λ₁ and top eigenvalue Λ, we prove:

1. **Spectral upper bound**: Var(K) ≤ E(δ)/λ₁, where δ = K − K̄ is the mean-zero curvature defect and E(δ) = ⟨Lδ, δ⟩ its Dirichlet energy;
2. **Curvature forcing lower bound**: (A/Λ)·δ(v)² ≤ Var(K) for every vertex v, given a curvature forcing condition A·δ(v)² ≤ E(δ);
3. **Spectral sandwich**: E(δ)/Λ ≤ Var(K) ≤ E(δ)/λ₁;
4. **Zero energy rigidity**: E(δ) = 0 iff K is constant, with the constant value forced by topology via discrete Gauss-Bonnet.

We introduce the novel concept of *curvature forcing* as a new interface between local curvature concentration and global spectral rigidity. All results are formalized and verified in Lean 4 with Mathlib. We provide computational experiments validating the bounds on families of triangulated surfaces and formulate falsifiable conjectures for future research.

**Keywords**: spectral graph theory, discrete differential geometry, combinatorial curvature, Laplacian eigenvalues, curvature variance, mesh quality, Gauss-Bonnet theorem, spectral rigidity.

---

## 1. Introduction

### 1.1 Motivation

The interplay between spectral data and geometric invariants is a central theme in Riemannian geometry. Classical results such as the Lichnerowicz-Obata theorem bound the first eigenvalue of the Laplace-Beltrami operator in terms of Ricci curvature, while Cheeger's inequality relates the spectral gap to isoperimetric constants. These results have profound implications for geometric rigidity, comparison geometry, and mathematical physics.

In the discrete setting, spectral graph theory provides analogous tools for analyzing finite graphs. The spectral gap of the graph Laplacian controls mixing times of random walks, expansion properties, and connectivity. Meanwhile, discrete differential geometry assigns curvature to vertices of triangulated surfaces via angular deficit, with the discrete Gauss-Bonnet theorem providing a topological constraint.

Despite the maturity of both fields, the direct connection between the *spectral gap of the 1-skeleton* and the *distribution of vertex curvature* on triangulated surfaces has not been formalized. This paper establishes that connection through a series of verified inequalities.

### 1.2 Contributions

We make the following contributions:

1. **A Poincaré-type inequality for curvature variance** (Theorem 1): the spectral gap provides an upper bound on how much curvature can deviate from uniformity, relative to the Dirichlet energy of the defect.

2. **A novel definition of curvature forcing** (Definition 5): a quantitative condition that measures how much the Laplacian energy dominates local curvature concentration.

3. **A spectral variance sandwich** (Theorem 3): two-sided control of curvature variance by spectral data.

4. **A zero-energy rigidity theorem** (Theorem 4): characterizing constant curvature as the unique zero-energy state, with topology fixing the constant via Gauss-Bonnet.

5. **Formal verification** in Lean 4 with Mathlib, ensuring mathematical correctness.

6. **Computational experiments** on families of triangulated surfaces, validating the bounds and motivating conjectures.

### 1.3 Related Work

**Spectral graph theory**: The spectral gap of graph Laplacians is extensively studied [Chung 1997]. Poincaré inequalities on graphs relate the spectral gap to function oscillation [Diaconis-Stroock 1991].

**Discrete curvature**: Combinatorial curvature via angular deficit goes back to Descartes and was formalized by Regge [1961] for piecewise-flat manifolds. The discrete Gauss-Bonnet theorem is classical [Banchoff 1967].

**Spectral geometry**: In the smooth setting, connections between Laplacian spectra and curvature are surveyed in [Berger 2003]. Discrete analogues have been studied for Ricci curvature [Ollivier 2009, Lin-Lu-Yau 2011] but not for variance bounds.

---

## 2. Definitions and Notation

### 2.1 Setup

Let V be a finite set of vertices with |V| = n. Let K: V → ℝ be the curvature function, and L ∈ ℝ^{V×V} the graph Laplacian of the 1-skeleton.

**Definition 1 (Mean-zero).** A function f: V → ℝ is *mean-zero* if ∑_{v∈V} f(v) = 0.

**Definition 2 (Squared norm).** sqNorm(f) = ∑_{v∈V} f(v)².

**Definition 3 (Curvature defect).** The curvature defect is δ(v) = K(v) − K̄, where K̄ = (∑_w K(w))/n is the mean curvature.

**Definition 4 (Curvature variance).** curvatureVariance(K) = sqNorm(δ) = ∑_v (K(v) − K̄)².

**Definition 5 (Dirichlet energy).** dirichletEnergy(L, f) = ∑_i f(i) · ∑_j L(i,j) · f(j) = f^T L f.

**Definition 6 (Spectral gap property).** L has spectral gap λ₁ if for all mean-zero x: V → ℝ,
  λ₁ · sqNorm(x) ≤ dirichletEnergy(L, x).

**Definition 7 (Top eigenvalue bound).** L has top eigenvalue bound Λ if for all x: V → ℝ,
  dirichletEnergy(L, x) ≤ Λ · sqNorm(x).

**Definition 8 (Curvature forcing — novel).** The curvature defect δ satisfies *curvature forcing* at level A if for all v ∈ V,
  A · δ(v)² ≤ dirichletEnergy(L, δ).

This captures the condition that no single vertex's curvature defect dominates the total Dirichlet energy by more than factor 1/A. High A means curvature is delocalized relative to edge oscillation energy.

---

## 3. Main Results

### 3.1 Theorem 1: Spectral Gap Upper Bound on Curvature Variance

**Theorem.** Let L be a matrix with spectral gap λ₁ > 0 and |V| ≠ 0. Then
$$\text{Var}(K) \leq \frac{E(\delta)}{\lambda_1}$$
where E(δ) = dirichletEnergy(L, δ) is the Dirichlet energy of the curvature defect.

**Proof sketch.**
1. By definition, Var(K) = sqNorm(δ).
2. The defect δ is mean-zero: ∑_v δ(v) = ∑_v K(v) − n · K̄ = 0.
3. By the spectral gap property applied to the mean-zero function δ: λ₁ · sqNorm(δ) ≤ E(δ).
4. Dividing by λ₁ > 0: sqNorm(δ) ≤ E(δ)/λ₁.

**Significance.** This is a discrete Poincaré inequality for curvature. It says that well-connected meshes (large λ₁) suppress curvature variance unless the defect has high oscillation energy along edges.

### 3.2 Theorem 2: Curvature Forcing Lower Bound

**Theorem.** Let L satisfy curvature forcing at level A for defect δ, and let L have top eigenvalue bound Λ > 0. Then for every vertex v:
$$\frac{A}{\Lambda} \cdot \delta(v)^2 \leq \text{Var}(K).$$

**Proof sketch.**
1. By curvature forcing: A · δ(v)² ≤ E(δ).
2. By top eigenvalue bound: E(δ) ≤ Λ · sqNorm(δ) = Λ · Var(K).
3. Combining: A · δ(v)² ≤ Λ · Var(K), hence (A/Λ) · δ(v)² ≤ Var(K).

**Significance.** This converts local curvature extremes into global variance lower bounds. If any vertex has large curvature defect and the forcing condition holds, then the total curvature variance must be correspondingly large.

### 3.3 Theorem 3: Spectral Variance Sandwich

**Theorem.** Under both spectral gap λ₁ > 0 and top eigenvalue bound Λ > 0:
$$\frac{E(\delta)}{\Lambda} \leq \text{Var}(K) \leq \frac{E(\delta)}{\lambda_1}.$$

**Proof.** The upper bound is Theorem 1. The lower bound follows from the top eigenvalue bound: E(δ) ≤ Λ · Var(K), hence Var(K) ≥ E(δ)/Λ.

**Significance.** Curvature variance is determined up to a factor of Λ/λ₁ (the condition number of L restricted to the mean-zero subspace) by the Dirichlet energy of the defect. For well-conditioned Laplacians, the sandwich is tight.

### 3.4 Theorem 4: Zero Energy Rigidity

**Theorem.** If L has spectral gap λ₁ > 0 and |V| ≠ 0, then:
$$E(\delta) = 0 \iff K(v) = \bar{K} \text{ for all } v.$$

**Proof sketch.**
- (⇐) If K is constant, then δ = 0, hence E(0) = 0.
- (⇒) If E(δ) = 0, then by the spectral gap inequality: λ₁ · sqNorm(δ) ≤ 0. Since λ₁ > 0 and sqNorm(δ) ≥ 0, we get sqNorm(δ) = 0, hence δ = 0, hence K is constant.

### 3.5 Corollary: Gauss-Bonnet Topological Constraint

**Corollary.** If E(δ) = 0 and ∑_v K(v) = 2πχ (discrete Gauss-Bonnet), then
$$K(v) = \frac{2\pi\chi}{|V|}$$
for all v.

**Significance.** Topology prescribes the unique spectrally rigid curvature profile. On a genus-g surface with n vertices, the only constant curvature value is 2π(2−2g)/n.

---

## 4. Algorithms

### Algorithm 1: Spectral-Curvature Analysis

**Input:** Triangulation T = (V, F) with |V| = n.

**Output:** Variance, Dirichlet energy, spectral gap, ratio R(T).

```
1. Build adjacency matrix A from triangles F
2. Compute degree vector d = A·1
3. Form Laplacian L = diag(d) - A                    O(n²)
4. Compute curvature K(v) = 2π - (π/3)·d(v)          O(n)
5. Compute defect δ = K - mean(K)·1                   O(n)
6. Compute variance = ‖δ‖²                            O(n)
7. Compute energy E = δᵀLδ                             O(n²)
8. Eigendecompose L; extract λ₁, Λ                    O(n³)
9. Compute R(T) = Var/(λ₁·‖δ‖_∞²)                    O(n)
10. Verify sandwich: E/Λ ≤ Var ≤ E/λ₁                 O(1)
```

**Complexity:** O(n³) dominated by eigendecomposition. For large meshes, Lanczos iteration computes λ₁ in O(n·|E|) time.

### Algorithm 2: Mesh Quality Certification

**Input:** Mesh M with n vertices.

**Output:** Quality score Q ∈ [0, 1].

```
1. Run Algorithm 1 to get R(T)
2. Q = 1/(1 + R(T))
3. Flag vertices where |δ(v)| > 2·sqrt(Var/n)
```

Q = 1 for perfectly uniform meshes; Q → 0 for highly irregular ones.

---

## 5. Computational Experiments

### 5.1 Genus 0: Regular Polyhedra and Bipyramids

| Surface | |V| | Var(K) | λ₁ | E(δ) | R(T) |
|---------|-----|--------|------|------|------|
| Tetrahedron | 4 | 0.0000 | 4.00 | 0.00 | — |
| Octahedron | 6 | 0.0000 | 4.00 | 0.00 | — |
| Icosahedron | 12 | 0.0000 | 2.76 | 0.00 | — |
| Bipyramid-6 | 8 | 6.58 | 3.00 | 52.6 | 0.89 |
| Bipyramid-10 | 12 | 65.8 | 2.38 | 789.6 | 1.01 |
| Bipyramid-20 | 22 | 510.4 | 2.10 | 11229.4 | 1.05 |
| Bipyramid-50 | 52 | 4462.4 | 2.02 | 232045.4 | 1.03 |

**Observations:**
- Regular polyhedra (tetrahedron, octahedron, icosahedron) have zero variance — they saturate the rigidity theorem.
- For bipyramids, R(T) stabilizes around 1.0 as n grows, bounded away from 0.
- The sandwich bounds are verified in all cases.

### 5.2 Genus 1: Torus Triangulations

| Surface | |V| | Var(K) | λ₁ | E(δ) |
|---------|-----|--------|------|------|
| Torus 3×3 | 9 | 0.00 | 6.00 | 0.00 |
| Torus 4×4 | 16 | 0.00 | 4.00 | 0.00 |
| Torus 5×5 | 25 | 0.00 | 2.76 | 0.00 |
| Torus 6×6 | 36 | 0.00 | 2.00 | 0.00 |

**Observation:** Regular grid torus triangulations have exactly constant curvature (all vertices have degree 6), confirming the rigidity theorem. The spectral gap decreases as the torus gets larger.

### 5.3 Scaling of the Forcing Constant

For bipyramid-n, the curvature forcing constant A = E(δ)/max_v δ(v)² grows linearly with n:

| n | A |
|---|---|
| 6 | 21.3 |
| 10 | 28.8 |
| 20 | 48.4 |
| 50 | 108.2 |

This suggests A ≈ 2n for bipyramids, supporting Hypothesis 2 that A(g, n) > 0 exists for all triangulations.

---

## 6. Discussion

### 6.1 Interpretation

The results can be interpreted through several lenses:

**Discrete Hodge theory.** The mean-zero defect δ lies in the orthogonal complement of the kernel of L (the constant functions). The spectral gap inequality is a Poincaré estimate on this complement. The Dirichlet energy is the Hodge inner product on 0-cochains.

**Statistical mechanics.** Curvature variance is a fluctuation observable, Dirichlet energy is an interaction energy, and the spectral gap is an inverse correlation length. The sandwich theorem says fluctuations are controlled by interactions modulo spectral stiffness.

**Regge calculus / quantum gravity.** Vertex curvature defects are the 2D analogue of concentrated curvature in piecewise-flat gravity. The spectral bound says that low-gap triangulations allow long-wavelength curvature modes, while large-gap ones suppress them.

### 6.2 Limitations

- The spectral gap and top eigenvalue are defined via hypotheses (the Rayleigh quotient characterization) rather than constructive eigenvalue computation. This is standard in formal verification but means the theorems don't directly produce numerical bounds without eigenvalue computation.
- The curvature forcing condition is an assumption about the defect-Laplacian interaction that must be verified for specific triangulation families.
- We work with the combinatorial Laplacian rather than the cotan Laplacian or Hodge Laplacian, which limits direct applicability to metric geometry.

### 6.3 Connections to Classical Results

The spectral gap upper bound on variance is the discrete analogue of the Lichnerowicz-type bound: in the smooth setting, a lower Ricci curvature bound implies λ₁ ≥ n/(n−1)·R_min (Lichnerowicz-Obata). Our result reverses the direction: given the spectral gap, we bound curvature *fluctuation* rather than curvature *magnitude*.

The zero-energy rigidity theorem parallels the classical result that on a compact manifold, the only functions with zero Dirichlet energy are constants — this is immediate from elliptic theory but requires spectral gap positivity in the discrete case.

---

## 7. Future Work

1. **Constructive spectral gap bounds.** Prove that specific triangulation families (Delaunay, regular, bounded-degree) have spectral gap λ₁ ≥ c/n for explicit c > 0.

2. **Edge-weight Laplacians.** Extend to cotangent-weight Laplacians for metric-aware curvature bounds.

3. **Higher-dimensional analogs.** Generalize to 3D and 4D simplicial complexes for Regge calculus applications.

4. **Random triangulations.** Prove concentration of R(T) for random triangulations of fixed genus.

5. **Computational certification.** Implement efficient spectral gap estimation via Lanczos iteration for large meshes.

---

## References

- [Banchoff 1967] T. Banchoff, "Critical Points and Curvature for Embedded Polyhedra," *J. Diff. Geom.* 1 (1967), 245–256.
- [Berger 2003] M. Berger, *A Panoramic View of Riemannian Geometry*, Springer, 2003.
- [Chung 1997] F. Chung, *Spectral Graph Theory*, CBMS Regional Conference Series, AMS, 1997.
- [Diaconis-Stroock 1991] P. Diaconis, D. Stroock, "Geometric bounds for eigenvalues of Markov chains," *Ann. Appl. Probab.* 1 (1991), 36–61.
- [Lin-Lu-Yau 2011] Y. Lin, L. Lu, S.-T. Yau, "Ricci curvature of graphs," *Tohoku Math. J.* 63 (2011), 605–627.
- [Ollivier 2009] Y. Ollivier, "Ricci curvature of Markov chains on metric spaces," *J. Funct. Anal.* 256 (2009), 810–864.
- [Regge 1961] T. Regge, "General relativity without coordinates," *Nuovo Cimento* 19 (1961), 558–571.
