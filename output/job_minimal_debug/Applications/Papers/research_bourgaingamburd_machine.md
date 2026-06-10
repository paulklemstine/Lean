# The Bourgain–Gamburd Machine for Orthogonal Groups: A Formal Framework

## Abstract

We develop a formal framework for the Bourgain–Gamburd expansion machine specialized to finite orthogonal groups. The framework consists of four layers: (1) a theory of convolution and L² analysis on finite groups, including proofs of mass preservation, nonnegativity, Cauchy–Schwarz, and Young-type L² bounds; (2) a Dirichlet form and spectral gap formulation for Cayley graph averaging operators; (3) the abstract Bourgain–Gamburd machine theorem, which derives a spectral gap from escape and product growth hypotheses; and (4) a specialization to orthogonal groups preserving quadratic forms over finite fields, with concrete results for hyperoctahedral groups (signed permutation matrices). We prove 20+ foundational theorems with complete machine-checked proofs, establish the framework architecture for the full machine, and validate the theory with computational experiments demonstrating spectral gaps, L² flattening, and mixing in concrete orthogonal Cayley graphs.

**Keywords:** spectral gap, expander graphs, Bourgain–Gamburd machine, finite orthogonal groups, Cayley graphs, random walks, L² flattening, product theorem, convolution on groups

---

## 1. Introduction

### 1.1 Background

The Bourgain–Gamburd machine [BG08, BG09] is a powerful framework for establishing spectral gap (expansion) properties of Cayley graphs of finite matrix groups. Originally developed for SL₂(𝔽_p), the machine has been extended to higher-rank groups SL_d(ℤ/p^n ℤ) and compact groups.

The core mechanism converts two combinatorial hypotheses:
1. **Escape from structured subgroups**: the random walk measure does not concentrate on cosets of proper algebraically-defined subgroups.
2. **Product growth**: finite subsets that are not concentrated on structured subgroups exhibit super-multiplicative growth under triple products.

into a spectral gap via an **L² flattening** argument: each convolution step strictly reduces the L² norm of the walk measure until it reaches uniformity.

### 1.2 Contributions

This paper makes the following contributions:

1. **Formal convolution theory** (§3): A complete formalized theory of convolution on finite groups, including:
   - Mass preservation under convolution
   - Nonnegativity preservation
   - Convolution with uniform measure
   - Dirac delta as convolution identity
   - Cauchy–Schwarz inequality
   - Young-type L² bounds
   - Mean-zero projection theory

2. **Spectral gap framework** (§4): Formal definitions and basic properties of:
   - Dirichlet form for Cayley graphs
   - Spectral gap via Rayleigh quotient
   - Averaging operator self-adjointness

3. **Abstract machine** (§5): The Bourgain–Gamburd machine formulated as a theorem schema:
   - Structured subgroup families
   - Escape and non-concentration predicates
   - Product growth hypothesis
   - L² flattening
   - Spectral gap extraction

4. **Orthogonal specialization** (§6): Instantiation for orthogonal groups:
   - Quadratic form-preserving matrices
   - Signed permutation matrices (hyperoctahedral groups)
   - Structured subgroup families for orthogonal geometry

5. **Computational validation** (§7): Numerical experiments confirming theoretical predictions for B₂ and B₃.

### 1.3 Related Work

The Bourgain–Gamburd machine builds on:
- The Helfgott product theorem for SL₂(𝔽_p) [Hel08]
- The Balog–Szemerédi–Gowers lemma [BSG94, Gow98]
- Ruzsa's calculus for sumsets [Ruz96]
- The Selberg 3/16 theorem and arithmetic applications [Sel65]

Formal verification of combinatorial and algebraic results has advanced through projects like Mathlib, but to our knowledge this is the first formal framework targeting the Bourgain–Gamburd machine for any family of groups.

---

## 2. Notation and Preliminaries

Let G be a finite group, S ⊆ G a finite symmetric generating set (s ∈ S ⟹ s⁻¹ ∈ S).

**Measures.** A probability measure on G is a function μ : G → ℝ with μ(g) ≥ 0 for all g and ∑_g μ(g) = 1. A measure is symmetric if μ(g) = μ(g⁻¹).

**Convolution.** For μ, ν : G → ℝ:
$$(\mu * \nu)(x) = \sum_{g \in G} \mu(g) \nu(g^{-1}x)$$

**L² norm.** ‖f‖₂² = ∑_g f(g)².

**Averaging operator.** T_S f(x) = |S|⁻¹ ∑_{s ∈ S} f(sx).

**Dirichlet form.** E_S(f) = (2|S|)⁻¹ ∑_{s ∈ S} ∑_x (f(sx) - f(x))².

**Spectral gap.** The spectral gap of Cay(G,S) is the infimum of E_S(f)/‖f‖₂² over all mean-zero f.

---

## 3. Convolution Theory on Finite Groups

### 3.1 Basic Properties

**Theorem 3.1** (Mass Preservation). If ∑_g μ(g) = 1 and ∑_g ν(g) = 1, then ∑_x (μ * ν)(x) = 1.

*Proof.* By Fubini (exchange of summation) and reindexing:
$$\sum_x (μ * ν)(x) = \sum_x \sum_g μ(g)ν(g^{-1}x) = \sum_g μ(g) \sum_x ν(g^{-1}x) = \sum_g μ(g) \sum_y ν(y) = 1 \cdot 1 = 1$$
The reindexing y = g⁻¹x is a bijection (left multiplication by g⁻¹). ∎

**Theorem 3.2** (Nonnegativity). If μ ≥ 0 and ν ≥ 0, then μ * ν ≥ 0.

*Proof.* Each term μ(g)ν(g⁻¹x) is a product of nonneg reals. ∎

**Theorem 3.3** (Probability Preservation). If μ and ν are probability measures, so is μ * ν.

**Theorem 3.4** (Uniform Absorbs). If ∑_g μ(g) = 1, then μ * u_G = u_G, where u_G is the uniform measure.

*Proof.* (μ * u_G)(x) = ∑_g μ(g) · |G|⁻¹ = |G|⁻¹ · 1 = u_G(x). ∎

**Theorem 3.5** (Dirac Identity). f * δ_1 = f and δ_1 * f = f.

### 3.2 L² Analysis

**Theorem 3.6** (Cauchy–Schwarz). (∑_g f(g)g₀(g))² ≤ (∑_g f(g)²)(∑_g g₀(g)²).

**Theorem 3.7** (L² of Uniform). ‖u_G‖₂² = |G|⁻¹.

**Theorem 3.8** (L² ≤ L¹ · L∞). ‖f‖₂² ≤ ‖f‖₁ · ‖f‖_∞.

### 3.3 Mean-Zero Decomposition

**Definition.** The mean of f is m(f) = |G|⁻¹ ∑_g f(g). The mean-zero projection is f₀(g) = f(g) - m(f).

**Theorem 3.9** (Mean-Zero Projection). f₀ has mean zero: ∑_g f₀(g) = 0.

**Theorem 3.10** (Pythagorean). ‖f₀‖₂² ≤ ‖f‖₂².

*Proof.* ‖f‖₂² = ‖f₀ + m(f)‖₂² = ‖f₀‖₂² + 2m(f)∑_g f₀(g) + |G| · m(f)² = ‖f₀‖₂² + |G| · m(f)² ≥ ‖f₀‖₂². ∎

---

## 4. Spectral Gap Framework

### 4.1 Dirichlet Form

**Definition.** For a finite symmetric set S ⊆ G:
$$E_S(f) = \frac{1}{2|S|} \sum_{s \in S} \sum_{x \in G} (f(sx) - f(x))^2$$

**Theorem 4.1** (Nonnegativity). E_S(f) ≥ 0 for all f.

**Theorem 4.2** (Constants Vanish). E_S(c) = 0 for any constant function.

### 4.2 Spectral Gap

**Definition.** The generating set S has spectral gap at least γ if:
$$E_S(f) \geq \gamma \cdot \|f\|_2^2 \quad \text{for all mean-zero } f$$

This is equivalent to the second eigenvalue of T_S being at most 1 - γ.

### 4.3 Generator Measure

**Theorem 4.3**. The uniform measure on S is a probability measure.

**Theorem 4.4**. If S is symmetric, the uniform measure on S is symmetric.

---

## 5. The Abstract Bourgain–Gamburd Machine

### 5.1 Structured Subgroup Families

**Definition.** A structured family 𝓗 for G consists of a predicate on subgroups of G satisfying:
- ⊤ (the whole group) is not structured.

In practice, structured subgroups are algebraically or geometrically distinguished proper subgroups (stabilizers, normalizers, maximal tori, etc.).

### 5.2 Escape and Non-Concentration

**Definition.** A measure μ escapes 𝓗 at scale κ if for every proper structured H and every g ∈ G:
$$\text{CosetConc}(μ, g, H) \leq |G|^{-\kappa}$$

### 5.3 Product Growth

**Definition.** The product growth hypothesis PG(ε, δ, η) states: for every A ⊆ G with |G|^ε ≤ |A| ≤ |G|^{1-ε} that is η-non-concentrated on 𝓗:
$$|A \cdot A \cdot A| \geq |A|^{1+\delta}$$

### 5.4 Machine Theorem

**Theorem 5.1** (Bourgain–Gamburd Machine). Let S be a symmetric generating set of G. If the generator measure escapes 𝓗 at scale κ, and the product growth hypothesis PG(ε, δ, η) holds, then there exists gap > 0 such that:
$$E_S(f) \geq \text{gap} \cdot \|f\|_2^2 \quad \text{for all mean-zero } f$$

The proof proceeds by:
1. **Flattening step**: Show ‖μ_S^{(2k)}‖₂² ≤ (1-c) · ‖μ_S^{(k)}‖₂² for a constant c > 0, using escape + product growth.
2. **Iteration**: After O(log |G|) convolution steps, ‖μ_S^{(t)}‖₂² ≈ |G|⁻¹ (uniform).
3. **Spectral extraction**: Exponential convergence to uniformity implies spectral gap.

---

## 6. Orthogonal Specialization

### 6.1 Finite Orthogonal Groups

For p an odd prime, n ≥ 3, and Q an n × n nondegenerate symmetric matrix over 𝔽_p:
$$O(Q, \mathbb{F}_p) = \{M \in GL_n(\mathbb{F}_p) : M^T Q M = Q\}$$

### 6.2 Hyperoctahedral Groups

The hyperoctahedral group B_n ≅ (ℤ/2)^n ⋊ S_n consists of signed permutation matrices. Each element (σ, ε) with σ ∈ S_n and ε ∈ {±1}^n acts as M_{ij} = ε_i · δ_{σ(i),j}.

**Theorem 6.1** (Orthogonality). For any signed permutation matrix M: M^T M = I.

*Proof.* (M^T M)_{ij} = ∑_k M_{ki} M_{kj} = ∑_k ε_k δ_{σ(k),i} · ε_k δ_{σ(k),j}. Since σ is a permutation, the only nonzero term is k = σ⁻¹(i) = σ⁻¹(j), which requires i = j. The value is ε_{σ⁻¹(i)}² = 1. ∎

### 6.3 Structured Subgroups for Orthogonal Groups

For orthogonal groups, the structured subgroups include:
- Stabilizers of isotropic lines/subspaces
- Block-diagonal subgroups (stabilizers of orthogonal decompositions)
- Coordinate subgroup stabilizers
- Maximal tori

In our formalization, we use the maximal family: every proper subgroup is structured. This is the strongest escape hypothesis but produces the cleanest framework.

---

## 7. Computational Experiments

### 7.1 Spectral Gap Computation

| Group | |G| | |S| | λ₂ | Gap | Mixing Time |
|-------|-----|-----|------|------|-------------|
| B₂ | 8 | 2 | 0.707 | 0.293 | ~20 |
| B₃ | 48 | 3 | 0.911 | 0.089 | ~74 |

### 7.2 L² Flattening

Starting from the generator measure μ_S on B₃:
- ‖μ_S‖₂² = 0.333
- ‖μ_S * μ_S‖₂² = 0.210
- Contraction ratio: 0.630

After 15 convolution steps, ‖μ_S^{(15)}‖₂² ≈ 0.023 ≈ 1.1 · |G|⁻¹, confirming near-uniformity.

### 7.3 Product Growth

For a random subset A ⊆ B₃ with |A| = 12:
- |A·A·A| = 48 (the full group)
- δ ≈ 0.558 (since 12^{1.558} ≈ 48)

This illustrates the product growth phenomenon: moderate subsets of B₃ expand to fill the entire group under triple products.

---

## 8. Discussion

### 8.1 Formalization Achievements

We have formally verified 20+ theorems about convolution, spectral gap, and orthogonal structure:

**Fully proved (no sorry):**
- Convolution mass preservation, nonnegativity, probability preservation
- Convolution with uniform/Dirac measures
- L² norm nonnegativity, L² of uniform
- Cauchy–Schwarz inequality
- L¹/L∞ bound on L²
- Dirichlet form nonnegativity and vanishing on constants
- Generator measure is probability/symmetric
- Signed permutation orthogonality (M^T M = I)
- Mean-zero projection theory
- Spectral gap contraction from Dirichlet bounds

**Framework (stated with sorry):**
- Full Bourgain–Gamburd machine theorem
- L² decay from product growth
- Spectral gap from L² decay
- Machine composition theorem

### 8.2 Limitations

The four sorry'd theorems represent the deep analytical core of the Bourgain–Gamburd machine. Their full proofs require:
- Ruzsa calculus / Plünnecke inequality formalization
- Balog–Szemerédi–Gowers lemma
- Careful entropy/L² analysis of approximate subgroups
- Spectral theory for self-adjoint operators on finite-dimensional spaces

These represent significant formalization challenges that could be addressed in future work.

### 8.3 Significance

The framework is designed for reuse. Once the four core machine lemmas are proved, the entire apparatus immediately applies to:
- Any finite group with a structured subgroup family
- Any symmetric generating set satisfying escape
- Any group satisfying a product theorem

The orthogonal specialization provides a concrete testbed and demonstrates the geometric content of the escape hypothesis.

---

## 9. Future Work

1. **Complete the machine proofs**: Formalize Ruzsa calculus and the flattening argument.
2. **SL₂ instantiation**: Apply the same framework to SL₂(𝔽_p).
3. **Escape from subvarieties**: Formalize orbit-counting arguments for escape.
4. **Spectral-to-robustness bridge**: Connect spectral gap to Lipschitz smoothing.
5. **Quantum applications**: Orthogonal designs and mixing channels.

---

## References

[BG08] J. Bourgain, A. Gamburd, "Uniform expansion bounds for Cayley graphs of SL₂(𝔽_p)," Annals of Mathematics 167 (2008), 625–642.

[BG09] J. Bourgain, A. Gamburd, "Expansion and random walks in SL_d(ℤ/p^n ℤ): I," J. Eur. Math. Soc. 11 (2009), 1057–1103.

[BSG94] A. Balog, E. Szemerédi, "A statistical theorem of set addition," Combinatorica 14 (1994), 263–268.

[Gow98] W.T. Gowers, "A new proof of Szemerédi's theorem for arithmetic progressions of length four," Geometric and Functional Analysis 8 (1998), 529–551.

[Hel08] H. Helfgott, "Growth and generation in SL₂(ℤ/pℤ)," Annals of Mathematics 167 (2008), 601–623.

[Ruz96] I. Ruzsa, "Sums of finite sets," in: D.V. Chudnovsky et al. (eds.), Number Theory: New York Seminar 1991–1995, Springer, 1996.

[Sel65] A. Selberg, "On the estimation of Fourier coefficients of modular forms," Proc. Sympos. Pure Math. 8 (1965), 1–15.
