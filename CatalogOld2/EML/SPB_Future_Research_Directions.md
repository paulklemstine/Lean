# Future Research Directions for the SPB-EML Program

## A Roadmap for the Next Generation of Results

---

## Executive Summary

This document outlines 12 major research directions for extending the Stereographic Projection Bridge (SPB) and Exponential-Multiplicative-Logarithmic (EML) framework. Each direction is classified by mathematical depth, potential impact, and estimated difficulty. We distinguish between directions that extend the existing machine-verified theory and those that require fundamentally new mathematical ideas.

---

## Part I: Extensions of Machine-Verified Theory

### Direction 1: SPB over Finite Fields — Complete Classification

**Status:** Partially explored (group structure known for some primes).

**Goal:** For each prime p, determine:
- The structure of the group G_p = {x ∈ F_p : 1 - x² ≠ 0 mod p} under SPB
- The order of every element
- Whether G_p is cyclic
- The connection to quadratic residues

**Key insight:** SPB over F_p corresponds to multiplication in the quotient ring F_p[i]/(i² + 1). When p ≡ 1 (mod 4), -1 is a quadratic residue, F_p[i] splits, and the SPB group decomposes. When p ≡ 3 (mod 4), F_p[i] ≅ F_{p²}, and the SPB group is cyclic of order p+1.

**Formalization target:** Prove in Lean:
- `theorem spb_finite_field_order (p : ℕ) [hp : Fact (Nat.Prime p)] (hp3 : p % 4 = 3) : ∀ x : ZMod p, spbPow (p + 1) x = 0`

**Difficulty:** MEDIUM | **Impact:** HIGH (connections to algebraic geometry over finite fields)

---

### Direction 2: SPB Functional Equation — Characterization Theorems

**Status:** Open.

**Goal:** Prove that SPB is the *unique* continuous binary operation f : ℝ × ℝ → ℝ satisfying:
1. f(x, 0) = x (identity)
2. f(x, -x) = 0 (inverse)
3. f(x, f(y, z)) = f(f(x, y), z) (associativity)
4. f is differentiable
5. f'(0, 0) = (1, 1) (normalization)

**Approach:** Show that any such f must satisfy the infinitesimal equation V(x) = f_ε(x, 0), and the only smooth V generating a group action is V(x) = c(1 + kx²) for constants c, k. Normalization fixes c = 1, k = 1.

**Difficulty:** HARD | **Impact:** VERY HIGH (uniqueness theorem for the circle group law)

---

### Direction 3: SPB Approximation Theory — Optimal Rates

**Status:** Bounds established but not tight.

**Goal:** Determine the exact approximation rate of SPB trees of depth n:
- What class of functions can depth-n SPB trees approximate?
- What is the optimal approximation rate in L² and L∞ norms?
- How does SPB tree approximation compare to rational function approximation?

**Key conjecture:** A depth-n SPB tree with optimally chosen parameters can approximate any Lipschitz function on [-1, 1] with error O(1/n²), matching the optimal rate for rational approximation.

**Approach:** Connect SPB tree depth to the degree of the resulting rational function (verified: ≤ 2^(n-1)), then use known results from rational approximation theory.

**Difficulty:** HARD | **Impact:** HIGH (computational complexity of trigonometric evaluation)

---

### Direction 4: Information Geometry of the Cauchy Family

**Status:** Key algebraic identity verified (Cauchy pullback); geometric interpretation incomplete.

**Goal:** Prove that SPB translations are isometries of the Fisher information metric on the Cauchy location-scale family.

**Specifically:**
1. Define the Fisher metric g_ij on the Cauchy manifold {(μ, σ) : σ > 0}
2. Show that the map (μ, σ) ↦ (spb(μ, t), σ·(1+t²)/(something)) is a g-isometry
3. Compute the curvature of the Fisher manifold and relate it to SPB group structure

**Formalization target:** Verify the algebraic identities underlying the isometry in Lean, even if the full differential-geometric statement requires additional Mathlib infrastructure.

**Difficulty:** MEDIUM-HARD | **Impact:** HIGH (connects SPB to information theory)

---

### Direction 5: SPB Matrix Group Theory

**Status:** Basic properties verified; deeper structure unexplored.

**Goal:** Characterize the SPB matrix group {M(a) : a ∈ ℝ} ⊂ GL₂(ℝ):
1. It is a one-parameter subgroup of GL₂(ℝ)
2. Its closure in GL₂(ℝ) is compact modulo center
3. The quotient M(a)/√det(M(a)) lies in SO(2)
4. The Lie algebra is spanned by [[0, 1], [-1, 0]]
5. The exponential map: exp(t·[[0,1],[-1,0]]) = [[cos t, sin t], [-sin t, cos t]] relates to tan(t)

**Formalization target:**
- `theorem spbMat_normalized_in_SO2 (a : ℝ) : (1/√(1+a²)) • spbMat a ∈ SpecialOrthogonalGroup (Fin 2) ℝ`

**Difficulty:** MEDIUM | **Impact:** MEDIUM (representation theory connections)

---

## Part II: New Mathematical Directions

### Direction 6: Division Algebra Obstruction — Higher Dimensions

**Status:** d = 1 case verified (SPB ↔ ℂ); general conjecture open.

**Goal:** Prove (or investigate computationally) the Division Algebra Obstruction Conjecture: a d-dimensional SPB exists if and only if d+1 ∈ {1, 2, 4, 8}.

**Definitions needed:**
- d-dimensional SPB: a bilinear operation ℝ^d × ℝ^d → ℝ^d with norm multiplicativity
- Norm: N(x) = 1 + ||x||²
- The conjecture reduces to: norm multiplicativity ⟺ existence of a composition algebra of dimension d+1

**Known:** Hurwitz's theorem (1898) classifies all composition algebras as ℝ, ℂ, ℍ, 𝕆. The SPB conjecture rephrases this in terms of the specific norm 1 + ||x||².

**Formalization approach:**
1. Verify d = 3 case (quaternionic SPB): define 3-dimensional SPB using quaternion multiplication of 1+xi+yj+zk
2. Verify d = 7 case (octonionic SPB): similarly, using Cayley-Dickson construction
3. Prove impossibility for d ∉ {0, 1, 3, 7}: this requires formalizing Hurwitz's theorem

**Difficulty:** VERY HARD | **Impact:** VERY HIGH (fundamental algebraic topology)

---

### Direction 7: p-adic SPB

**Status:** Unexplored in formal verification.

**Goal:** Study the SPB operation on the p-adic numbers ℤ_p:
- When is spb(x, y) well-defined in ℤ_p?
- What is the group structure of (ℤ_p, spb)?
- How does the p-adic SPB norm relate to the p-adic absolute value?

**Key difference from ℝ:** Over ℤ_p, the set where 1 - xy = 0 has a different (p-adic) topology. For p ≡ 1 (mod 4), i = √(-1) exists in ℤ_p, so the SPB norm 1 + x² factors.

**Research questions:**
- Is there a p-adic Cauchy distribution invariant under p-adic SPB?
- What is the p-adic analogue of the elliptic classification?
- Can p-adic SPB be used for p-adic modular forms?

**Difficulty:** HARD | **Impact:** HIGH (p-adic geometry and number theory)

---

### Direction 8: SPB Modular Forms and Automorphic Forms

**Status:** Speculative.

**Goal:** Investigate whether there exist automorphic forms invariant under the discrete SPB subgroup generated by M(1):

The group Γ_SPB = ⟨M(1)⟩ = ⟨[[1,1],[-1,1]]⟩ is a discrete subgroup of GL₂(ℝ). Does the quotient ℍ/Γ_SPB support interesting automorphic forms?

**Key computation:** M(1)^n has characteristic polynomial λ² - 2λ + 2, with eigenvalues 1 ± i. So M(1)^n has eigenvalues (1+i)^n and (1-i)^n, giving |eigenvalue| = (√2)^n. This means Γ_SPB acts on the upper half-plane with exponentially growing orbits — very different from classical modular groups.

**Research question:** Is the quotient ℍ/Γ_SPB a Riemann surface? If so, what is its genus?

**Difficulty:** VERY HARD | **Impact:** POTENTIALLY VERY HIGH (connections to Langlands program)

---

### Direction 9: SPB and Tropical Geometry

**Status:** Initial explorations done.

**Goal:** Define and study the "tropical SPB" obtained by replacing addition with max and multiplication with addition:

spb_trop(x, y) = max(x, y) - min(0, x + y)

**Questions:**
- Is tropical SPB associative?
- What is the tropical analogue of the Cauchy distribution?
- Does tropical SPB have applications to optimization (tropical geometry meets convex optimization)?

**Difficulty:** MEDIUM | **Impact:** MEDIUM (tropical geometry connections)

---

### Direction 10: SPB Neural Networks — Theoretical Foundations

**Status:** Activation function concept described; no formal theory.

**Goal:** Develop a rigorous approximation theory for SPB neural networks:
1. **Universal approximation**: Can SPB networks approximate any continuous function?
2. **Depth separation**: Are there functions that SPB networks can approximate in depth d but not depth d-1?
3. **Optimization landscape**: Does the SPB Cauchy connection help with gradient flow?

**Key conjecture:** SPB networks are universal approximators for functions on the circle, and achieve better approximation rates than standard networks for functions with rotational structure.

**Approach:** Use the connection spbPow(n, x) = tan(n·arctan(x)) to relate SPB network depth to trigonometric polynomial degree.

**Difficulty:** HARD | **Impact:** VERY HIGH (machine learning theory)

---

### Direction 11: Quantum SPB

**Status:** Matrix formulation suggests quantum applications; not formalized.

**Goal:** Develop a quantum version of SPB:
1. Define SPB gates as elements of SU(2) (normalized SPB matrices)
2. Show that SPB gates generate a dense subset of SU(2) (universality)
3. Design quantum algorithms using SPB gate decomposition
4. Relate SPB cocycle to Berry phase

**Key insight:** The normalized SPB matrix M(a)/√(1+a²) = [[cos θ, sin θ], [-sin θ, cos θ]] where θ = arctan(a) is exactly a rotation gate R_z(θ) in the Z basis.

**Research question:** Is there a natural quantum error correction code associated with the SPB group structure?

**Difficulty:** HARD | **Impact:** HIGH (quantum computing)

---

### Direction 12: SPB and the Langlands Program

**Status:** Highly speculative.

**Goal:** Investigate whether the SPB matrix group Γ_SPB ⊂ GL₂(ℝ) and its finite field analogues connect to automorphic representations in the Langlands program.

**Motivation:** 
- The SPB group over F_p is related to F_{p²}^× (when p ≡ 3 mod 4)
- The L-function of the SPB group should encode information about the distribution of primes p for which the SPB group has specific structure
- The SPB cocycle c(x,y) = 1/(1-xy) might be related to Whittaker functions

**Difficulty:** EXTREMELY HARD | **Impact:** POTENTIALLY REVOLUTIONARY

---

## Priority Ranking

### Tier 1 (Immediate, High Impact)
1. **Direction 1:** SPB over finite fields — most of the infrastructure exists
2. **Direction 4:** Information geometry — algebraic part can be verified now
3. **Direction 5:** Matrix group theory — direct extension of current work

### Tier 2 (Medium Term, High Impact)  
4. **Direction 6:** Division algebra obstruction — d = 3 (quaternionic) case
5. **Direction 10:** SPB neural network theory — universal approximation
6. **Direction 2:** Functional equation characterization

### Tier 3 (Long Term, Exploratory)
7. **Direction 3:** Approximation theory — optimal rates
8. **Direction 7:** p-adic SPB
9. **Direction 9:** Tropical geometry
10. **Direction 11:** Quantum SPB

### Tier 4 (Speculative)
11. **Direction 8:** Modular forms
12. **Direction 12:** Langlands program

---

## Resource Recommendations

### For a Single Researcher (6 months)
Focus on Directions 1 and 5: Complete the finite field classification and matrix group analysis. These build directly on the existing verified foundation and produce publishable results.

### For a Small Team (2-3 researchers, 1 year)
Add Directions 4, 6 (d=3 case), and 10. The information geometry work connects to statistics, the quaternionic SPB connects to physics, and the neural network theory connects to ML — giving each team member a distinct publication trajectory.

### For a Research Program (5+ researchers, 3+ years)
Pursue all Tier 1-3 directions simultaneously. The p-adic and tropical directions offer high-risk, high-reward opportunities. The quantum direction could attract funding from quantum computing agencies.

---

## Open Problems (Formally Stated)

For the Lean formalization community, here are concrete open problems:

1. **SPB Characterization:** Formalize and prove that spb is the unique continuous commutative group law on ℝ with identity 0 and generator 1 + x².

2. **Quaternionic SPB:** Define and verify the 3-dimensional SPB using quaternion multiplication of pure quaternions xi + yj + zk mapped to 1 + xi + yj + zk.

3. **SPB Fourier Analysis:** Prove that the functions x ↦ tan(n·arctan(x)) form a complete orthogonal system on ℝ with respect to the Cauchy measure.

4. **Projective SPB Universal Property:** Prove that projective SPB is the free commutative group on one generator in the category of groups with norm-multiplicative binary operations.

5. **SPB Entropy Bound:** Prove that the differential entropy of the Cauchy distribution equals log(4π), and relate this to SPB group structure.

---

*Research directions document. Based on machine-verified SPB-EML results. April 2026.*
