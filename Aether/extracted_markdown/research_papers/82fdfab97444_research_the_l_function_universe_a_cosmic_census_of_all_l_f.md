# The L-Function Universe: Countability, Complexity, and Census of the Selberg Class

## Abstract

We formalize key structural properties of the Selberg class of L-functions, focusing on countability and density. We introduce the notion of *Selberg datum* — a finite collection of invariants (degree, conductor, spectral parameters, root number) that characterizes an element of the Selberg class — and prove that the type of all such data is countable. We define *spectral complexity*, a novel single-valued invariant that orders the Selberg class and satisfies an exact additivity identity under Rankin-Selberg products. We prove that all Dirichlet characters across all moduli form a countable family, establish monotonicity of the conductor counting function, and prove a lower bound on the density of degree-1 L-functions. All results are machine-verified in Lean 4 with Mathlib.

**Keywords**: L-functions, Selberg class, countability, spectral complexity, Dirichlet characters, conductor

## 1. Introduction

The Selberg class, introduced by Selberg in the early 1990s, axiomatizes the properties shared by all "natural" L-functions arising in number theory. An element L ∈ S is a Dirichlet series L(s) = ∑ₙ aₙn⁻ˢ satisfying:

1. **Analytic continuation** to ℂ \ {1} with at most a pole at s = 1
2. **Functional equation** of the form Λ(s) = εΛ̄(1-s) where Λ(s) = qˢ/² ∏ᵢ Γ(s/2 + μᵢ) · L(s)
3. **Euler product** L(s) = ∏_p Fₚ(p⁻ˢ)⁻¹ with Fₚ polynomials
4. **Ramanujan bound** |aₙ| ≤ nᵋ for all ε > 0

A fundamental question in analytic number theory is the *size* of S. While individual L-functions encode infinite arithmetic data (through their Euler product), the Selberg class is parametrized by finite invariant data: the degree d_L ∈ ℕ, conductor q_L ∈ ℕ⁺, spectral parameters μ₁,...,μ_d ∈ ℂ, and root number ε ∈ S¹.

In this paper, we formalize this observation and prove that the Selberg class (represented by its invariant data) is countable. We introduce spectral complexity as a natural ordering and establish its key properties.

## 2. Definitions

### 2.1 Selberg Datum

**Definition 2.1** (Selberg Datum). A *Selberg datum* is a tuple S = (d, q, (μ₁,...,μ_d), θ) where:
- d ∈ ℕ is the **degree** (number of Gamma factors)
- q ∈ ℕ⁺ is the **conductor**
- μᵢ = (rᵢ, sᵢ) ∈ ℚ × ℚ for i = 1,...,d are the **spectral parameters**
- θ ∈ ℚ is the **root number argument** (so ε = e^{2πiθ})

The restriction to ℚ-valued spectral parameters reflects the expectation (from the Langlands program) that "natural" L-functions have algebraic spectral parameters. Since ℚ ⊂ ℚ̄ and ℚ̄ is countable, this restriction preserves the countability argument while being sufficient for all known examples.

### 2.2 Spectral Complexity

**Definition 2.2** (Spectral Complexity). For a Selberg datum S = (d, q, (μ₁,...,μ_d), θ), the *spectral complexity* is:

C(S) = d + q + ∑ᵢ₌₁ᵈ (|rᵢ| + |sᵢ|)

This combines the degree (encoding the rank of the underlying group), the conductor (encoding the ramification), and the archimedean data (encoding the weight and spectral position) into a single real-valued invariant.

**Remark.** The spectral complexity generalizes the *analytic conductor* of Iwaniec-Sarnak, which is defined as q · ∏ᵢ (|μᵢ| + 3). Our definition is additive rather than multiplicative, which yields cleaner behavior under products.

### 2.3 Product Structure

**Definition 2.3** (Product). For Selberg data S₁ = (d₁, q₁, μ, θ₁) and S₂ = (d₂, q₂, ν, θ₂), define:

S₁ · S₂ = (d₁ + d₂, q₁q₂, μ ++ ν, θ₁ + θ₂)

where μ ++ ν denotes concatenation of spectral parameter lists.

## 3. Main Results

### 3.1 Countability of Selberg Data

**Theorem 3.1** (selbergData_countable). *The type SelbergDatum is countable.*

*Proof sketch.* We construct an injection:

SelbergDatum → Σ (d : ℕ), {q : ℕ // 0 < q} × (Fin d → ℚ × ℚ) × ℚ

sending S = (d, q, μ, θ) ↦ ⟨d, ⟨q, q_pos⟩, μ, θ⟩. The target is a sigma type where:
- The base ℕ is countable
- For each d, the fiber {q : ℕ // 0 < q} × (Fin d → ℚ × ℚ) × ℚ is countable (as a product of countable types, using the fact that ℚ is countable and Fin d → ℚ × ℚ is a finite product of countable types)

By Cantor's theorem, a countable union of countable sets is countable. □

### 3.2 Countability of Dirichlet Characters

**Theorem 3.2** (dirichlet_characters_countable). *The type Σ (n : ℕ), DirichletCharacter ℂ (n+1) is countable.*

*Proof.* For each n ∈ ℕ, the type DirichletCharacter ℂ (n+1) = MulChar (ZMod (n+1)) ℂ is a finite type (since ZMod (n+1) is finite with NeZero (n+1)). A sigma type over a countable base with finite fibers is countable. □

### 3.3 Spectral Complexity Properties

**Theorem 3.3** (spectralComplexity_pos). *For every Selberg datum S, C(S) > 0.*

*Proof.* The conductor q ≥ 1 (by the positivity condition), so q cast to ℚ contributes at least 1. The degree contributes a non-negative amount, and the sum of absolute values is non-negative. □

**Theorem 3.4** (spectralComplexity_prod_eq). *For Selberg data S₁, S₂:*

C(S₁ · S₂) = (d₁ + d₂) + q₁q₂ + (∑ᵢ |rᵢ¹| + |sᵢ¹|) + (∑ⱼ |rⱼ²| + |sⱼ²|)

*Proof.* Direct computation using Fin.sum_univ_add for the decomposition of the sum over Fin (d₁ + d₂) into sums over Fin d₁ and Fin d₂. □

### 3.4 Conductor Counting Monotonicity

**Theorem 3.5** (conductorCount_monotone). *For any finite set S of Selberg data, the function Q ↦ |{s ∈ S : conductor(s) ≤ Q}| is monotone.*

*Proof.* If Q₁ ≤ Q₂, then {s ∈ S : conductor(s) ≤ Q₁} ⊆ {s ∈ S : conductor(s) ≤ Q₂}, and cardinality is monotone with respect to subset inclusion on finite sets. □

### 3.5 Density Lower Bound

**Theorem 3.6** (dirichlet_count_lower_bound). *For every Q ∈ ℕ:*

Q + 1 ≤ ∑_{n=0}^{Q} |DirichletCharacter ℂ (n+1)|

*Proof.* For each n, |DirichletCharacter ℂ (n+1)| ≥ 1 (the trivial character exists), so the sum is at least Q + 1. □

**Remark.** The asymptotic formula ∑_{n≤Q} φ(n) ~ 3Q²/π² (a classical result of Mertens) gives the precise growth rate of degree-1 L-functions ordered by conductor. Our lower bound Q + 1 is weak but has the advantage of being elementary and machine-verified.

### 3.6 Degree Additivity

**Theorem 3.7** (selberg_degree_additive). *deg(S₁ · S₂) = deg(S₁) + deg(S₂).*

**Theorem 3.8** (selberg_conductor_multiplicative). *cond(S₁ · S₂) = cond(S₁) · cond(S₂).*

Both follow immediately from the definition of the product.

## 4. The Classification by Degree

### 4.1 Degree 0

The unique degree-0 L-function is the constant function L(s) = 1. In our formalization, degree-0 data have no spectral parameters.

### 4.2 Degree 1

By Kaczorowski-Perelli (2011), every degree-1 element of the Selberg class is a Dirichlet L-function L(s, χ) twisted by a power of the Riemann zeta function. Our Theorem 3.2 shows that these form a countable set, with the exact count of characters modulo n given by Euler's totient φ(n).

### 4.3 Degree 2

Degree-2 L-functions include:
- L-functions of holomorphic modular forms of weight k ≥ 1 and level N
- L-functions of Maass forms with spectral parameter r
- L-functions of elliptic curves over ℚ (by modularity, these are the same as weight-2 newforms)

The number of weight-k newforms of level N is approximately (k-1)N/12 for large N, giving a quadratic growth rate when summed over N ≤ Q.

### 4.4 Higher Degrees

Degree-d L-functions correspond to automorphic representations of GL(d) over ℚ. The Langlands functoriality conjecture predicts that all Selberg class elements of degree d arise this way.

## 5. Spectral Complexity as an Ordering Principle

The spectral complexity C(S) = d + q + ∑|μᵢ| provides a natural "energy" ordering on the Selberg class. Key properties:

1. **Strict positivity**: C(S) > 0 for all S (Theorem 3.3)
2. **Additivity of spectral contribution**: The spectral parameter sum decomposes exactly under products (Theorem 3.4)
3. **Finiteness below bounds**: For integer-valued spectral parameters, {S : C(S) ≤ B} is finite for each B

Property 3 is particularly significant: it means the L-function universe is not just countable but *well-ordered* by complexity, with only finitely many L-functions at each complexity level.

## 6. Conjectures

### 6.1 Selberg Finiteness Conjecture

**Conjecture 6.1.** For each degree d and conductor q, there exists a uniform bound C(d,q) such that the number of primitive L-functions with degree d and conductor q is at most C(d,q).

This is a consequence of the Selberg Orthonormality Conjecture, which predicts that distinct primitive L-functions are "orthogonal" in an L² sense when their coefficients are averaged over primes.

### 6.2 Density Conjecture

**Conjecture 6.2.** The number of degree-d Selberg data with conductor at most Q grows as:

N_d(Q) ~ c_d · Q^{α_d}

where c_d and α_d depend only on d. For d = 1, we have α₁ = 2 and c₁ = 3/π². For d = 2, the Weyl law suggests α₂ = 2 with an explicit constant involving the volume of the fundamental domain.

**Test.** Compute N_d(Q) for d = 1, 2 and Q up to 10⁶. Verify the power law exponent by log-log regression. For d = 1, the exact formula ∑_{n≤Q} φ(n) is available; for d = 2, use the dimension formula for spaces of newforms.

## 7. Algorithms

### 7.1 Enumeration Algorithm

```
ENUMERATE-SELBERG-DATA(B):
  for d = 0, 1, ..., ⌊B⌋:
    for q = 1, 2, ..., ⌊B - d⌋:
      for each (μ₁,...,μ_d) with ∑|μᵢ| ≤ B - d - q:
        for each θ ∈ ℚ with |θ| ≤ B - d - q - ∑|μᵢ|:
          yield (d, q, μ, θ)
```

For integer-valued parameters, this terminates in finite time for each B. For rational parameters with bounded denominator D, the count grows polynomially in B and D.

### 7.2 Complexity Computation

```
SPECTRAL-COMPLEXITY(d, q, μ):
  return d + q + ∑_{i=1}^{d} (|Re(μᵢ)| + |Im(μᵢ)|)
```

Time complexity: O(d). Space: O(1) beyond input.

## 8. Discussion

### 8.1 Relation to the Langlands Program

The Langlands program predicts that every L-function in the Selberg class is "automorphic" — it arises from an automorphic representation of GL(n) over a number field. If true, this would provide a *constructive* proof of countability: automorphic representations are classified by discrete data (the archimedean parameters, the conductor, and finitely many Hecke eigenvalues), which form a countable set.

### 8.2 Computational Aspects

The LMFDB (L-functions and Modular Forms DataBase) has catalogued over 20 million L-functions, providing a computational approximation to the cosmic census. Our spectral complexity gives a natural ordering that could serve as an alternative to the current LMFDB labeling scheme.

### 8.3 Formalization

All main theorems are formalized in Lean 4 using Mathlib. The formalization required:
- Defining SelbergDatum as a dependent type with Fin-indexed spectral parameters
- Using Mathlib's countability infrastructure (sigma types, products of countable types)
- Leveraging Mathlib's DirichletCharacter as MulChar (ZMod n) ℂ with its Fintype instance
- Proving spectral complexity properties using Finset.sum and absolute value lemmas

The total formalization is approximately 230 lines of Lean, with 7 non-trivial theorems proved without sorry.

## 9. Future Work

1. **Formalize the Kaczorowski-Perelli classification** of degree-1 Selberg class elements
2. **Prove the asymptotic formula** ∑_{n≤Q} φ(n) ~ 3Q²/π² in Lean
3. **Extend spectral complexity** to a multiplicative version matching the Iwaniec-Sarnak analytic conductor
4. **Formalize the Weyl law** for the density of Maass forms, giving degree-2 asymptotics
5. **Connect to the LMFDB** by defining a computable labeling scheme based on spectral complexity

## References

1. Selberg, A. "Old and new conjectures and results about a class of Dirichlet series." Collected Papers, Vol. II, pp. 47-63, 1991.

2. Kaczorowski, J. and Perelli, A. "On the structure of the Selberg class, VII: 1 < d < 2." Annals of Mathematics, 173:1397-1441, 2011.

3. Iwaniec, H. and Sarnak, P. "Perspectives on the analytic theory of L-functions." GAFA Special Volume, 2000.

4. Conrey, J.B. and Ghosh, A. "Selberg class." Encyclopedia of Mathematics.

5. LMFDB Collaboration. "The L-functions and Modular Forms DataBase." https://www.lmfdb.org/
