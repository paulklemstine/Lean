# A Formal Convex-Geometric Engine: Minkowski Sums, Brunn–Minkowski, and Newton's Inequality in Lean 4

## Abstract

We present a formally verified development of foundational convex geometry in Lean 4, establishing the first machine-checked proofs of (1) the linearization of support functions under Minkowski addition, (2) the Brunn–Minkowski inequality for axis-aligned boxes via a weighted AM-GM argument, and (3) Newton's log-concavity inequality for mixed volume coefficients via the Pólya frequency (PF₂) property. The development introduces reusable definitions of Minkowski sums, support functions, box structures, and mixed volume coefficients, along with 15+ formally verified theorems. All proofs are sorry-free and depend only on standard axioms (propext, Classical.choice, Quot.sound). We demonstrate applications to container design, entropy power inequalities, robotics, and isoperimetric optimization.

## 1. Introduction

### 1.1 Motivation

The Brunn–Minkowski inequality is one of the most fundamental results in convex geometry, with applications spanning geometric functional analysis, information theory, probability, and combinatorics. Despite its importance, machine-verified formalizations have been scarce, particularly for the algebraic infrastructure (mixed volumes, support functions, Newton's inequality) that connects the inequality to its many applications.

### 1.2 Contributions

1. **Definitions**: Minkowski sum, support function, convex body (using Mathlib's `ConvexBody`), axis-aligned box structure (`Box n`) with volume, side lengths, and Minkowski sum operations.

2. **Support function theory** (Theorem Cluster A):
   - `le_supportFn`: membership bound ⟨u, x⟩ ≤ h_K(u)
   - `supportFn_mono`: monotonicity under set inclusion
   - `supportFn_attained`: attainment on compact sets (finite-dimensional)
   - `supportFn_minkowskiSum`: linearization h_{A⊕B}(u) = h_A(u) + h_B(u)

3. **Brunn–Minkowski for boxes** (Theorem Cluster B):
   - `geom_le_arith_mean_fin`: AM-GM for Fin n
   - `sum_geom_means_le_one`: complementary geometric means
   - `prod_add_rpow_le`: core algebraic inequality
   - `brunn_minkowski_box`: vol(A⊕B)^{1/n} ≥ vol(A)^{1/n} + vol(B)^{1/n}

4. **Newton's inequality** (Theorem Cluster D):
   - `isPF2_conv`: PF₂ preservation under convolution
   - `prodLinCoeff_isPF2`: PF₂ property of polynomial coefficients
   - `newton_ineq`: c_{k-1}·c_{k+1} ≤ c_k² for products of linear polynomials
   - `box_mixed_coeff_sq_le`: Alexandrov–Fenchel shadow for boxes

5. **Box infrastructure**:
   - `Box.toSet_isCompact`, `Box.toSet_convex`, `Box.toSet_nonempty`
   - `Box.minkowskiSum_toSet`: Minkowski sum of box carriers

### 1.3 Related work

Formalization of convex geometry in proof assistants is limited. Mathlib includes `ConvexBody`, basic convexity, and some functional analysis, but lacks Minkowski sum theory, support function linearization, and volume inequalities. Our work builds directly on Mathlib's infrastructure for compact sets, inner product spaces, and conditional suprema.

## 2. Definitions and Notation

### 2.1 Minkowski Sum

```
def minkowskiSum {E : Type*} [Add E] (A B : Set E) : Set E :=
  {x | ∃ a ∈ A, ∃ b ∈ B, a + b = x}
```

We prove commutativity and nonemptiness preservation.

### 2.2 Support Function

```
def supportFn {E : Type*} [SeminormedAddCommGroup E] [InnerProductSpace ℝ E]
    (K : Set E) (u : E) : ℝ :=
  sSup ((fun x => ⟨u, x⟩) '' K)
```

### 2.3 Box Structure

```
structure Box (n : ℕ) where
  lo : Fin n → ℝ
  hi : Fin n → ℝ
  hle : ∀ i, lo i ≤ hi i
```

With derived operations: `sideLength`, `volume`, `minkSum`, `toSet`.

### 2.4 Mixed Volume Coefficients

```
def boxMixedCoeff {n : ℕ} (A B : Box n) (k : ℕ) : ℝ :=
  ∑ S ∈ univ.filter (fun S : Finset (Fin n) => S.card = k),
    (∏ i ∈ S, B.sideLength i) * (∏ i ∈ univ \ S, A.sideLength i)
```

### 2.5 Recursive Polynomial Coefficients (for Newton's inequality)

```
def prodLinCoeff : ℕ → (ℕ → ℝ) → (ℕ → ℝ) → ℕ → ℝ
  | 0, _, _, k => if k = 0 then 1 else 0
  | n + 1, a, b, 0 => a n * prodLinCoeff n a b 0
  | n + 1, a, b, k + 1 => a n * prodLinCoeff n a b (k + 1) + b n * prodLinCoeff n a b k
```

## 3. Main Results

### 3.1 Support Function Linearization

**Theorem (supportFn_minkowskiSum).** For nonempty compact sets A, B in a finite-dimensional inner product space:

h_{A⊕B}(u) = h_A(u) + h_B(u)

*Proof sketch.* By antisymmetry. The ≤ direction uses `csSup_le`: for any x = a + b ∈ A ⊕ B, we have ⟨u, x⟩ = ⟨u, a⟩ + ⟨u, b⟩ ≤ h_A(u) + h_B(u). The ≥ direction uses `supportFn_attained` to find maximizers a₀ ∈ A, b₀ ∈ B, then observes that a₀ + b₀ ∈ A ⊕ B achieves the sum. The formal proof uses `csSup_eq_of_forall_le_of_forall_lt_exists_gt` for a clean formulation.

**Significance.** This theorem converts the nonlinear Minkowski addition into ordinary addition of functions, opening the door to linear-algebraic techniques in convex geometry.

### 3.2 Brunn–Minkowski for Boxes

**Theorem (brunn_minkowski_box).** For boxes A, B in ℝⁿ with n > 0:

vol(A ⊕ B)^{1/n} ≥ vol(A)^{1/n} + vol(B)^{1/n}

*Proof architecture.* Three-layer reduction:

1. **AM-GM** (`geom_le_arith_mean_fin`): (∏ wᵢ)^{1/n} ≤ (∑ wᵢ)/n. Uses Mathlib's `Real.geom_mean_le_arith_mean`.

2. **Complementary means** (`sum_geom_means_le_one`): For 0 ≤ tᵢ ≤ 1, (∏ tᵢ)^{1/n} + (∏(1-tᵢ))^{1/n} ≤ 1. Follows by applying AM-GM to both terms and using ∑ tᵢ + ∑(1-tᵢ) = n.

3. **Product inequality** (`prod_add_rpow_le`): The main algebraic content. When ∏(aᵢ+bᵢ) > 0, set tᵢ = aᵢ/(aᵢ+bᵢ) and apply step 2. When ∏(aᵢ+bᵢ) = 0, some aᵢ+bᵢ = 0 implies aᵢ = bᵢ = 0 (by nonnegativity), making both sides zero.

The `brunn_minkowski_box` theorem then follows by unfolding `Box.volume` and `Box.sideLength_minkSum`.

### 3.3 Newton's Inequality via PF₂

**Theorem (newton_ineq).** For nonneg sequences aᵢ, bᵢ, let cₖ be the k-th coefficient of ∏(aᵢ + t·bᵢ). Then:

c_{k-1} · c_{k+1} ≤ cₖ²

*Proof architecture.* We prove the stronger PF₂ property:

**Definition (IsPF2).** A sequence c is PF₂ if c(i)·c(j) ≤ c(i+1)·c(j-1) for all i+1 < j.

**Key Lemma (isPF2_conv).** If c is PF₂ and nonneg, and α, β ≥ 0, then d(k) = α·c(k) + β·c(k-1) is PF₂.

*Proof of key lemma.* Case analysis on indices i, j. In each case, the difference d(i+1)·d(j-1) - d(i)·d(j) decomposes as α²·(PF₂ term₁) + αβ·(PF₂ term₂) + β²·(PF₂ term₃), where each PF₂ term is nonneg by the PF₂ hypothesis on c. The formal proof uses `nlinarith` with carefully selected auxiliary nonneg products.

**Induction.** Base: prodLinCoeff 0 is PF₂ (trivially, since c(k) = 0 for k ≥ 1). Step: prodLinCoeff (n+1) = α·c(·) + β·c(·-1) where c = prodLinCoeff n, and α = a(n), β = b(n). Apply `isPF2_conv`.

**From PF₂ to Newton.** PF₂ at i = k-1, j = k+1 gives c(k-1)·c(k+1) ≤ c(k)·c(k) = cₖ².

### 3.4 Alexandrov–Fenchel Shadow for Boxes

**Theorem (box_mixed_coeff_sq_le).** For boxes A, B in ℝⁿ and 0 < k < n:

boxMixedCoeff A B (k-1) · boxMixedCoeff A B (k+1) ≤ (boxMixedCoeff A B k)²

*Proof.* The formal proof establishes that `boxMixedCoeff A B k` equals `prodLinCoeff n a' b' k` where a'(i) = A.sideLength⟨i⟩ and b'(i) = B.sideLength⟨i⟩, by showing both compute the same polynomial coefficients. It then applies `newton_ineq`. The bridge uses polynomial equality testing via `Polynomial.funext`.

## 4. Algorithms

### 4.1 Mixed Volume Coefficient Computation

**Algorithm 1: Subset enumeration** (O(2ⁿ) time)
```
for each subset S of {1,...,n} with |S| = k:
    c_k += prod_{i in S} b_i * prod_{i not in S} a_i
```

**Algorithm 2: Polynomial multiplication** (O(n²) time)
```
poly = [1]
for i = 1 to n:
    new_poly = [0, ..., 0]  (length len(poly) + 1)
    for j = 0 to len(poly)-1:
        new_poly[j] += a_i * poly[j]
        new_poly[j+1] += b_i * poly[j]
    poly = new_poly
return poly
```

Both algorithms are implemented in `algorithms.py` with verified agreement.

### 4.2 Support Function Evaluation for Boxes

O(n) time: h_K(u) = ∑ᵢ max(uᵢ·loᵢ, uᵢ·hiᵢ).

### 4.3 Brunn–Minkowski Verification

O(n) time: compute vol(A+B)^{1/n} and vol(A)^{1/n} + vol(B)^{1/n}, compare.

## 5. Computational Experiments

### 5.1 Brunn–Minkowski Verification

1000 random box pairs in dimensions 2-7 tested. All satisfy the inequality. Equality is approached only for homothetic boxes (proportional side lengths). See `demo.py` output.

### 5.2 Newton's Log-Concavity

1000 random box pairs tested for log-concavity of mixed coefficients. Zero violations found across all valid indices k. The gap c_k² - c_{k-1}·c_{k+1} is typically large, suggesting the inequality is far from tight for generic boxes.

### 5.3 Perimeter Proxy

The formula perimProxy = 2n·s^{n-1} for cubes of side s is verified computationally for n = 2,...,5 and s = 1, 2, 3.

### 5.4 Volume Interpolation Concavity

For boxes A = [1,2,3], B = [3,1,2] in ℝ³, the function t ↦ vol(A+tB)^{1/3} is verified to be concave on [0,1] (lies above the chord) at 11 sample points.

## 6. Applications

### 6.1 Container Design

Minkowski sums provide outer bounds on container dimensions for packing problems. Brunn–Minkowski gives theoretical lower bounds on required volume, with efficiency ratios typically 0.7-0.9 for heterogeneous items.

### 6.2 Entropy Power Inequality

For Gaussian distributions with diagonal covariance, the EPI reduces exactly to Brunn–Minkowski for boxes. Computational verification in dimensions 2-4 confirms the analogy.

### 6.3 Robotics

Configuration-space obstacles are Minkowski sums of robot and obstacle shapes. Brunn–Minkowski provides guaranteed volume bounds on collision regions.

### 6.4 Isoperimetric Optimization

Among boxes of fixed volume, the cube minimizes the perimeter proxy (surface area). This is verified computationally and connects to the classical isoperimetric inequality.

## 7. Discussion

### 7.1 Proof Architecture

The development is organized into three files:
- `Defs.lean` (215 lines): Definitions and support function theory
- `Newton.lean` (125 lines): PF₂ theory and Newton's inequality
- `BrunnMinkowski.lean` (195 lines): AM-GM, Brunn–Minkowski, mixed volumes

Total: ~535 lines of Lean 4, all sorry-free.

### 7.2 Key Design Decisions

1. **Box-first approach**: Rather than attempting full measure-theoretic generality, we develop the theory for boxes first. This captures the essential algebraic structure while avoiding the heaviest geometric measure theory.

2. **PF₂ for Newton**: The standard inductive proof of Newton's inequality requires a stronger induction hypothesis than log-concavity alone. The PF₂ (Pólya frequency) property provides exactly the right strengthening.

3. **Recursive vs. subset definition**: Mixed volume coefficients admit both a subset-sum definition (natural for the geometric interpretation) and a recursive definition (natural for induction). The bridge between them is established via polynomial identity.

### 7.3 Limitations

- The development is restricted to axis-aligned boxes. Extension to general convex bodies requires formalizing Lebesgue measure on compact convex sets.
- The isoperimetric inequality is only established as a computational observation, not a formal theorem.
- The Alexandrov–Fenchel inequality is proved only for boxes (Newton's inequality), not for general convex bodies.

## 8. Future Work

1. **General Brunn–Minkowski**: Extend to arbitrary measurable sets using Mathlib's measure theory.
2. **Mixed volumes**: Define mixed volumes for general convex bodies via polarization.
3. **Steiner formula**: Formalize the polynomial expansion of parallel body volume.
4. **Alexandrov–Fenchel**: Prove the full inequality using the Hilbert space method or Alexandrov's topological approach.
5. **Entropy power inequality**: Formalize the connection between Brunn–Minkowski and Shannon entropy.

## 9. References

1. Schneider, R. *Convex Bodies: The Brunn–Minkowski Theory*. Cambridge University Press, 2014.
2. Gardner, R.J. "The Brunn–Minkowski inequality." *Bulletin of the AMS* 39.3 (2002): 355-405.
3. Alexandrov, A.D. "Zur Theorie der gemischten Volumina von konvexen Körpern." *Matematicheskii Sbornik* 2.5 (1937): 947-972.
4. Karlin, S. *Total Positivity*. Stanford University Press, 1968.
5. Cover, T.M. and Thomas, J.A. *Elements of Information Theory*. Wiley, 2006.
