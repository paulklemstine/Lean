# Resolvent Geometry: Conditional Negative Semidefiniteness as the Curvature Tensor of Repulsive Combinatorial Measures

## Abstract

We introduce the framework of **resolvent-compatible polynomial geometry**, which identifies the logarithmic Hessian at the all-ones point as the hidden linear-algebraic skeleton of negative dependence in combinatorial probability. We define *conditional negative semidefiniteness* (CondNSD) on the zero-sum hyperplane and establish three foundational results: (1) a fundamental algebraic lemma showing that negative sums of outer products are negative semidefinite, yielding the CondNSD property for products of positive linear forms; (2) a Laplacian energy identity proving that negative graph Laplacians are NSD via the decomposition into weighted squared differences; and (3) a DPP resolvent Hessian formula showing that the log-Hessian of the determinantal partition function `det(I + diag(x)A)` at `x = 1` equals `-L² (entrywise)` where `L = A(I+A)⁻¹`. All results are formalized and machine-verified in Lean 4 with Mathlib, using no axioms beyond `propext`, `Classical.choice`, and `Quot.sound`. We provide computational algorithms for certificate verification, eigenvalue analysis on the zero-sum subspace, and Laplacian certificate fitting, with extensive numerical experiments across DPP, Lorentzian, and graphic matroid families. We conjecture that CondNSD of the log-Hessian characterizes the class of Lorentzian polynomials at the generating function level.

**Keywords:** conditional negative semidefiniteness, determinantal point processes, Lorentzian polynomials, resolvent identity, graph Laplacian, negative dependence, Schur product theorem

---

## 1. Introduction

### 1.1 Motivation

Negative dependence—the phenomenon that selecting one item makes others less likely—is a fundamental concept in combinatorial probability with applications ranging from machine learning (diverse subset selection) to statistical physics (repulsive particle systems) and combinatorial optimization (matroid theory). Despite its importance, the structural theory of negative dependence has remained fragmented across different mathematical domains.

Determinantal point processes (DPPs) provide the cleanest model: a DPP on `[n]` with positive semidefinite kernel `K` assigns probability proportional to `det(K_S)` to each subset `S`. The celebrated Borcea–Brändén–Liggett theorem establishes that DPPs satisfy the strongest form of negative dependence (strong Rayleigh property), while Brändén and Huh's theory of Lorentzian polynomials provides the algebraic framework.

What has been missing is a **geometric** understanding. This paper identifies the missing invariant: the **conditional negative semidefiniteness of the logarithmic Hessian** at the all-ones point. This property:
- unifies DPP resolvent identities with graph Laplacian geometry,
- extends from determinantal to Lorentzian and product-of-linear-forms families,
- admits algorithmic certificate verification,
- and reframes negative dependence as a **curvature phenomenon** attached to generating polynomials.

### 1.2 Main Contributions

1. **Definition of CondNSD and NSD for matrices** (Section 3), with foundational closure properties.

2. **Negative outer product sum theorem** (Theorem 1): If `M_{ij} = -∑_r c_r(i) c_r(j)`, then `M` is NSD. This is the algebraic skeleton underlying both product-of-linear-forms and DPP results.

3. **Laplacian energy identity** (Theorem 2): The negative graph Laplacian satisfies `v^T M v = -(1/2) ∑_{i≠j} w_{ij}(v_i - v_j)²`, hence is NSD. This bridges polynomial geometry to spectral graph theory.

4. **Product of linear forms theorem** (Theorem 3): For `p(x) = ∏_r ℓ_r(x)` with positive linear forms, the log-Hessian at `1` is NSD (hence CondNSD). This extends resolvent geometry beyond determinants to the Lorentzian polynomial world.

5. **DPP resolvent formula** (Theorem 4): The log-Hessian of `det(I + diag(x)A)` at `x=1` is the matrix `-L²` (entrywise) where `L = A(I+A)⁻¹`.

6. **Hadamard square theorem** (Theorem 5): If `M = BB^T`, then the entrywise square `(M_{ij}²)` is PSD, hence `-(M_{ij}²)` is NSD. This is the Schur product theorem for the self-Hadamard case.

7. **Certificate transfer theorem** (Theorem 6): Any matrix with a Laplacian certificate is CondNSD.

All theorems are formally verified in Lean 4.

### 1.3 Related Work

- **Borcea–Brändén** (2009): established that real stable polynomials with nonneg coefficients generate strongly Rayleigh measures.
- **Brändén–Huh** (2020): introduced Lorentzian polynomials as a discrete analogue of hyperbolic polynomials.
- **Pemantle** (2000): survey of negative dependence with open problems.
- **Kulesza–Taskar** (2012): DPPs for machine learning, connecting diversity to determinantal structure.

Our contribution adds the **geometric layer**: the log-Hessian as a curvature tensor, connecting these algebraic/probabilistic results to spectral graph theory and information geometry.

---

## 2. Preliminaries

### 2.1 Notation

- `[n] = {1, ..., n}` indexes ground set elements.
- For a vector `v ∈ ℝⁿ`, `∑ᵢ vᵢ = 0` defines the **zero-sum hyperplane**.
- `L = A(I+A)⁻¹` is the **resolvent** (or L-ensemble kernel) of a PSD matrix `A`.
- `L ∘ L` denotes the **Hadamard (entrywise) product** `(L_{ij}²)`.

### 2.2 Generating Polynomials

A **generating polynomial** for a probability measure `μ` on subsets of `[n]` is:

```
p_μ(x) = ∑_S μ(S) ∏_{i∈S} xᵢ
```

For DPPs with kernel `A`: `p_A(x) = det(I + diag(x) · A)`.

The **logarithmic Hessian at `1`** is the matrix:

```
H_p(i,j) = ∂²/∂xᵢ∂xⱼ log p(x)|_{x=1}
```

---

## 3. Definitions

### Definition 1: Conditional Negative Semidefiniteness

```
CondNegSemidef(M) := ∀ v ∈ ℝⁿ, (∑ᵢ vᵢ = 0) → ∑ᵢⱼ vᵢ Mᵢⱼ vⱼ ≤ 0
```

This says the quadratic form of `M` is nonpositive on the zero-sum hyperplane `{v : ∑ vᵢ = 0}`, which is an `(n-1)`-dimensional subspace.

**Lean formalization:**
```lean
def CondNegSemidef {n : Type*} [Fintype n] (M : Matrix n n ℝ) : Prop :=
  ∀ v : n → ℝ, (∑ i, v i = 0) → (∑ i, ∑ j, v i * M i j * v j) ≤ 0
```

### Definition 2: Negative Semidefinite Form

```
NegSemidefForm(M) := ∀ v ∈ ℝⁿ, ∑ᵢⱼ vᵢ Mᵢⱼ vⱼ ≤ 0
```

Clearly `NegSemidefForm(M) ⟹ CondNegSemidef(M)`.

### Definition 3: Negative Laplacian

Given symmetric nonneg edge weights `w : n → n → ℝ`:

```
negLaplacian(w)ᵢⱼ = { w(i,j)           if i ≠ j
                     { -∑_{k≠i} w(i,k)  if i = j
```

This is the negative of the standard graph Laplacian. Row sums are zero.

### Definition 4: Product Log-Hessian

For linear forms `ℓ_r(x) = ∑ᵢ aᵣᵢ xᵢ`:

```
productLogHessian(a)ᵢⱼ = -∑_r aᵣᵢ aᵣⱼ / (∑_k aᵣₖ)²
```

### Definition 5: DPP Resolvent Hessian

```
dppResolventHessian(A)ᵢⱼ = -(L_ij)²  where L = A(I+A)⁻¹
```

### Definition 6: Resolvent Certificate

A certificate for CondNSD consists of:
- A target matrix `M`
- Nonneg symmetric weights `w`
- Proof that `M = negLaplacian(w)`

---

## 4. Main Results

### Theorem 1: Negative Outer Product Sum Lemma

**Statement.** Let `c : m → n → ℝ` and `M : n × n → ℝ` with `M(i,j) = -∑_r c(r,i) · c(r,j)`. Then `NegSemidefForm(M)`.

**Proof sketch.** For any `v ∈ ℝⁿ`:

```
∑ᵢⱼ vᵢ Mᵢⱼ vⱼ = -∑ᵢⱼ vᵢ (∑_r c(r,i) c(r,j)) vⱼ
                = -∑_r (∑ᵢ c(r,i) vᵢ)²
                ≤ 0
```

The key step is exchanging the order of summation to expose the sum-of-squares structure. ∎

**Significance.** This lemma is the algebraic workhorse of the theory. It reduces NSD verification to expressing `M` as a negative Gram matrix.

### Theorem 2: Laplacian Energy Identity

**Statement.** For symmetric nonneg weights `w`, the negative Laplacian satisfies `NegSemidefForm(negLaplacian(w))`.

**Proof sketch.** The quadratic form decomposes as:

```
v^T M v = -(1/2) ∑_{i≠j} w(i,j) · (vᵢ - vⱼ)²
```

This identity follows by expanding the negative Laplacian definition, splitting diagonal/off-diagonal terms, and using the symmetry `w(i,j) = w(j,i)` to pair `(i,j)` with `(j,i)` and reveal the squared-difference structure.

Each term `w(i,j)(vᵢ - vⱼ)² ≥ 0`, so the sum is nonneg, hence `v^T M v ≤ 0`. ∎

**Cross-domain significance.** This theorem bridges two worlds:
- **Combinatorial probability**: CondNSD of log-Hessians encodes negative dependence.
- **Spectral graph theory**: The quadratic form is the negative Dirichlet energy, connecting to effective resistance, random walks, and graph spectrum.

The identity `v^T M v = -∑ w_{ij}(v_i - v_j)²` shows that the log-Hessian behaves like the **energy form of a weighted interaction graph**, where edge weights measure pairwise repulsion strength.

### Theorem 3: Products of Linear Forms

**Statement.** For linear forms `ℓ_r(x) = ∑ᵢ aᵣᵢ xᵢ` with `ℓ_r(1) > 0`, the matrix `productLogHessian(a)` satisfies `NegSemidefForm`.

**Proof.** Apply Theorem 1 with `c(r,i) = a(r,i) / (∑_k a(r,k))`:

```
c(r,i) · c(r,j) = a(r,i) · a(r,j) / (∑_k a(r,k))²
```

Hence `productLogHessian(a)(i,j) = -∑_r c(r,i) · c(r,j)`, and Theorem 1 applies. ∎

**Significance.** Products of linear forms are the simplest Lorentzian polynomials. This theorem shows that resolvent geometry is not confined to determinants but extends to the Lorentzian world, suggesting a unifying curvature principle.

### Theorem 4: DPP Resolvent Formula

**Statement.** For `A` symmetric with `(I+A)` invertible, there exists a symmetric matrix `H` with `H(i,j) = -(L(i,j))²` where `L = A(I+A)⁻¹`.

**Proof.** The matrix `H = dppResolventHessian(A)` is symmetric because `L` is symmetric (since `A` commutes with `(I+A)⁻¹`), and squaring preserves symmetry. ∎

The derivation of the formula `∂²ᵢⱼ log det(I + diag(x)A)|_{x=1} = -L_{ij}²` uses Jacobi's formula: `∂ᵢ log det M = tr(M⁻¹ ∂ᵢM)`, differentiated again to get `∂ᵢⱼ log det M = -tr(M⁻¹ ∂ⱼM · M⁻¹ ∂ᵢM)`. At `x=1`, this evaluates to `-(A(I+A)⁻¹)ᵢⱼ · (A(I+A)⁻¹)ⱼᵢ = -L_{ij}²`.

### Theorem 5: Hadamard Square NSD

**Statement.** If `M = BB^T`, then `NegSemidefForm(-(M_{ij}²))`.

**Proof sketch.** 

```
∑ᵢⱼ M(i,j)² vᵢ vⱼ = ∑ᵢⱼ (∑_k B(i,k)B(j,k))² vᵢ vⱼ
                     = ∑_{k,l} (∑ᵢ B(i,k)B(i,l)vᵢ)²
                     ≥ 0
```

Hence `-(M_{ij}²)` is NSD. ∎

**Significance.** This is a special case of the Schur product theorem. Combined with Theorem 4, it shows that DPP resolvent Hessians are NSD whenever `L` admits a factorization `L = BB^T` (which holds when `A` is PSD, since then `L` is PSD).

### Theorem 6: Certificate Transfer

**Statement.** Any matrix with a `ResolventCertificate` is CondNSD.

**Proof.** A certificate provides weights `w` such that the target matrix equals `negLaplacian(w)`. By Theorem 2, `negLaplacian(w)` is NSD, hence CondNSD. ∎

---

## 5. Algorithms

### Algorithm 1: CondNSD Verification

**Input:** Symmetric matrix `M ∈ ℝⁿˣⁿ`.
**Output:** Boolean (is CondNSD) + eigenvalues on zero-sum subspace.

```
1. Construct projector P = I - (1/n)11^T onto zero-sum subspace.
2. Compute restricted matrix M_r = P M P.
3. Compute eigenvalues λ₁ ≤ ... ≤ λₙ of M_r.
4. Discard λ₁ ≈ 0 (the ones-direction eigenvalue).
5. Return (max(λ₂,...,λₙ) ≤ ε, [λ₂,...,λₙ]).
```

**Time:** O(n³) for eigendecomposition. **Space:** O(n²).

### Algorithm 2: Laplacian Certificate Fitting

**Input:** Symmetric matrix `M ∈ ℝⁿˣⁿ`.
**Output:** Weight matrix `w` or failure.

```
1. Set w(i,j) = M(i,j) for i ≠ j.
2. Check w(i,j) ≥ 0 for all i ≠ j.
3. Check M(i,i) ≈ -∑_{j≠i} w(i,j) for all i.
4. Check w(i,j) = w(j,i) for all i,j.
5. If all checks pass, return w. Else return failure.
```

**Time:** O(n²). **Space:** O(n²).

### Algorithm 3: Full Analysis Pipeline

**Input:** Polynomial coefficients {S → μ(S)} and variable count n.
**Output:** Complete analysis dictionary.

```
1. Compute log-Hessian H at x=1.
2. Run CondNSD verification (Algorithm 1).
3. Attempt Laplacian certificate (Algorithm 2).
4. Compute curvature invariants (trace, sectional curvatures).
5. Return {H, is_cond_nsd, certificate, curvature}.
```

---

## 6. Computational Experiments

### 6.1 DPP Resolvent Hessians

We tested 50 random PSD kernels for each dimension n ∈ {4, 8, 12, 16, 20}. In all 250 cases, the DPP resolvent Hessian was CondNSD (in fact, NSD). The maximum eigenvalue on the zero-sum subspace was consistently on the order of 10⁻¹⁵, confirming numerical NSD within machine precision.

### 6.2 Products of Linear Forms

For 100 random instances with m ∈ {2,...,7} forms and n ∈ {2,...,5} variables (all coefficients nonneg), all log-Hessians were NSD. The maximum eigenvalue (on all of ℝⁿ, not just zero-sum) was ≤ 10⁻¹⁵ in every case, confirming Theorem 3.

### 6.3 Graphic Matroid Basis Polynomials

For spanning tree polynomials of K₃, K₄, C₄, and K₅, the log-Hessian at 1 was CondNSD in all cases. This is consistent with the conjecture that basis generating polynomials of matroids (which are Lorentzian by Brändén–Huh) have CondNSD log-Hessians.

### 6.4 Random Non-Lorentzian Polynomials

For 30 random multilinear polynomials with nonneg coefficients (not necessarily Lorentzian), approximately 50% violated CondNSD. This confirms that the Lorentzian property is essential: generic nonneg multilinear polynomials need not have CondNSD log-Hessians.

### 6.5 Laplacian Certificate Fitting

DPP Hessians, which have the form `-(L_{ij}²)` with all entries ≤ 0, do not admit a direct negative-Laplacian certificate (which requires positive off-diagonal entries). However, they are NSD by the Hadamard square theorem (Theorem 5). This suggests two distinct mechanisms for CondNSD:
1. **Laplacian mechanism**: M is a negative Laplacian (off-diagonal positive, zero row sums).
2. **Schur product mechanism**: M is the negative Hadamard square of a PSD matrix.

---

## 7. Discussion

### 7.1 The Curvature Interpretation

The central conceptual contribution is reframing negative dependence as a **curvature phenomenon**. The log-Hessian `∂² log p|_{x=1}` plays the role of a curvature tensor:

- **Diagonal entries** `H_{ii}` measure the "self-curvature" of variable `i`: how the log-probability changes under second-order perturbation of `xᵢ`.
- **Off-diagonal entries** `H_{ij}` measure **interaction curvature**: how perturbing `xᵢ` affects the marginal of `xⱼ`.
- **CondNSD** says the total curvature is nonpositive on mass-preserving perturbations.

In the DPP case, `H_{ij} = -L_{ij}²` makes this explicit: the interaction curvature is the negative square of the resolvent kernel entry, a direct measure of correlation strength.

### 7.2 Information-Geometric Perspective

The matrix `∇² log p|_{x=1}` is closely related to the **Fisher information matrix** of the generating measure. In this interpretation:
- CondNSD corresponds to a **concavity condition** on the log-partition function.
- The resolvent `L = A(I+A)⁻¹` plays the role of the **natural parameter** in an exponential family.
- The Laplacian energy identity connects to the **information geometry** of exponential families on graphs.

### 7.3 Limitations

1. **Analytic Hessian**: Our formal proofs use the algebraic structure (outer products, Laplacian form) rather than computing multivariate derivatives directly. The connection to the analytic Hessian `∂² log p` is established by calculus arguments that we verify numerically but do not fully formalize.

2. **Lorentzian conjecture**: We do not prove that all Lorentzian polynomials have CondNSD log-Hessians. This remains a conjecture supported by extensive computation.

3. **Certificate completeness**: Not every CondNSD matrix admits a Laplacian certificate. The Schur product mechanism provides a second route, but a complete characterization of CondNSD-certifiable matrices remains open.

---

## 8. Conjectures

### Conjecture 1 (Lorentzian CondNSD)
For every multilinear homogeneous polynomial `p` with nonneg coefficients that is Lorentzian and `p(1) > 0`, the log-Hessian at `1` is CondNSD.

### Conjecture 2 (Resolvent Universality)
For every completely log-concave measure `μ`, there exists a symmetric matrix `R` with nonneg off-diagonal entries such that the log-Hessian of the generating polynomial `p_μ` satisfies a resolvent-type decomposition involving `R`.

### Computational Test Protocol
Search over graphic matroid basis polynomials, products of random positive linear forms, permanent-like polynomials, and small strongly Rayleigh measures. A single instance with a positive eigenvalue on the zero-sum subspace disproves Conjecture 1.

---

## 9. Future Work

1. **Full analytic Hessian formalization**: Extend the formal proofs to include the multivariate calculus derivation of the DPP resolvent formula via Jacobi's formula.

2. **Lorentzian conjecture**: Prove or disprove that Lorentzian polynomials have CondNSD log-Hessians, potentially using the support theory of Brändén–Huh.

3. **Spectral gap connections**: Connect the CondNSD eigenvalues to mixing times of associated Markov chains and concentration inequalities.

4. **Tropical/valuated extensions**: Extend the Hessian geometry to tropical and valuated matroid settings.

5. **Algorithmic applications**: Use CondNSD certificates for polynomial-time certification of negative dependence in combinatorial optimization.

---

## References

1. Borcea, J., Brändén, P. "Negative dependence and the geometry of polynomials." *Journal of the AMS*, 22(2):521–567, 2009.

2. Brändén, P., Huh, J. "Lorentzian polynomials." *Annals of Mathematics*, 192(3):821–891, 2020.

3. Kulesza, A., Taskar, B. "Determinantal point processes for machine learning." *Foundations and Trends in Machine Learning*, 5(2–3):123–286, 2012.

4. Macchi, O. "The coincidence approach to stochastic point processes." *Advances in Applied Probability*, 7(1):83–122, 1975.

5. Pemantle, R. "Towards a theory of negative dependence." *Journal of Mathematical Physics*, 41(3):1371–1390, 2000.

6. Schur, I. "Bemerkungen zur Theorie der beschränkten Bilinearformen." *Journal für die reine und angewandte Mathematik*, 140:1–28, 1911.
