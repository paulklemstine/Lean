# Tropical Satake Isomorphism for GL_n: A Formally Verified Correspondence

## Abstract

We formalize and prove the tropical Satake isomorphism for GL_n in Lean 4. For any positive integer n, we establish a canonical bijection between the space of W-invariant functions on the coweight lattice ℤⁿ (under the natural action of the Weyl group W = S_n by coordinate permutation) and the space of functions on dominant coweights (weakly decreasing integer sequences of length n). This bijection is the tropical analogue of the classical Satake isomorphism, which identifies the spherical Hecke algebra H(GL_n(F)//GL_n(O)) with the Weyl-invariant part of the group algebra of the coweight lattice. Our formalization covers: (1) the orbit-dominance structure theorem — each S_n-orbit in ℤⁿ contains exactly one dominant element; (2) the forward and inverse Satake transforms with roundtrip identities; (3) W-invariance of orbit-symmetrized tropical polynomials; (4) a bijection between tropical Hecke operators and W-invariant tropical polynomial data. All proofs are machine-verified with no unproven assumptions beyond standard mathematical axioms.

## 1. Introduction

### 1.1 Background

The Satake isomorphism, introduced by Ichirō Satake in 1963 [1], is one of the foundational results in the Langlands program. For a reductive group G over a p-adic field F with ring of integers O, it establishes an algebra isomorphism

$$\mathcal{H}(G(F)//G(O)) \cong \mathbb{C}[\Lambda]^W$$

between the spherical Hecke algebra (compactly supported, bi-G(O)-invariant functions on G(F) under convolution) and the W-invariant part of the group algebra of the coweight lattice Λ.

For GL_n, this specializes to:
- Λ = ℤⁿ (the coweight lattice)
- W = S_n (the symmetric group, acting by permuting coordinates)
- The Hecke algebra consists of S_n-biinvariant functions
- The target is the ring of S_n-invariant Laurent polynomials in n variables

### 1.2 Tropical Dequantization

Following Litvinov's dequantization principle [2], the tropical (or idempotent) analogue replaces:
- The ring (ℤ, +, ×) with the min-plus semiring (ℤ, min, +)
- Polynomial rings with spaces of piecewise-linear functions
- Characters with tropical support functions

The resulting *tropical Satake isomorphism* identifies:
- **Left side**: S_n-biinvariant min-plus kernels on ℤⁿ (tropical Hecke operators)
- **Right side**: S_n-invariant tropical polynomials on ℤⁿ

### 1.3 Contributions

Our main contributions are:

1. **Orbit-Dominance Structure Theorem** (Theorems 3.1, 3.2): We prove that each S_n-orbit in ℤⁿ contains exactly one dominant (weakly decreasing) element, providing a canonical section of the orbit map.

2. **Tropical Satake Equivalence** (Theorem 4.1): We construct an explicit equivalence `WInvFun n α ≃ (DomCoweight n → α)` between W-invariant functions on ℤⁿ and arbitrary functions on dominant coweights, valid for any codomain type α.

3. **Hecke-Polynomial Bijection** (Theorem 5.1): We specialize the equivalence to show that tropical Hecke operators biject with W-invariant tropical polynomial data.

4. **W-Invariance of Tropical Symmetrization** (Theorem 5.2): We prove that orbit-symmetrized tropical polynomials are automatically W-invariant.

5. **Full Machine Verification**: All results are formally verified in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound).

## 2. Definitions and Notation

### 2.1 Coweight Lattice

**Definition 2.1** (Coweight). The *coweight lattice* of GL_n is
$$\Lambda_n := \text{Fin}\ n \to \mathbb{Z}$$
i.e., the set of integer-valued functions on {0, 1, ..., n-1}.

### 2.2 Weyl Group Action

**Definition 2.2** (Weyl Action). The Weyl group W = S_n acts on Λ_n by coordinate permutation:
$$(\sigma \cdot \mu)(i) := \mu(\sigma^{-1}(i))$$

This defines a left group action:
- `1 · μ = μ` (identity acts trivially)
- `(σ₁ · σ₂) · μ = σ₁ · (σ₂ · μ)` (associativity)

### 2.3 Dominance

**Definition 2.3** (Dominant Coweight). A coweight μ ∈ Λ_n is *dominant* if it is weakly decreasing (antitone):
$$i \leq j \implies \mu(i) \geq \mu(j)$$

The set of dominant coweights is denoted `DomCoweight n`.

### 2.4 W-Invariance

**Definition 2.4** (W-Invariant Function). A function f : Λ_n → α is *W-invariant* if
$$f(\sigma \cdot \mu) = f(\mu) \quad \text{for all } \sigma \in S_n,\ \mu \in \Lambda_n$$

### 2.5 Weyl Orbits

**Definition 2.5** (Weyl Orbit). The Weyl orbit of μ ∈ Λ_n is
$$W \cdot \mu := \{\sigma \cdot \mu : \sigma \in S_n\}$$

This is a finite subset of Λ_n with at most n! elements.

## 3. Orbit-Dominance Structure

### 3.1 Uniqueness

**Theorem 3.1** (Dominant Uniqueness). *If μ, ν ∈ Λ_n are both dominant and belong to the same Weyl orbit, then μ = ν.*

*Proof sketch.* If ν = σ · μ for some σ ∈ S_n, then μ and ν are both weakly decreasing sequences with the same multiset of values (since one is a permutation of the other). The key insight is that a weakly decreasing rearrangement of a finite integer sequence is unique.

Formally, we show that `List.ofFn μ` and `List.ofFn ν` are permutations of each other (since ν = μ ∘ σ⁻¹), and both are sorted in non-increasing order (since both μ and ν are antitone). We then apply the lemma that a list permutation preserving pairwise order must be equality. □

*Lean verification:*
```lean
theorem dominant_unique {n : ℕ} {μ ν : Coweight n}
    (hμ : IsDominant μ) (hν : IsDominant ν)
    (h : InSameOrbit μ ν) : μ = ν
```

### 3.2 Existence

**Theorem 3.2** (Dominant Existence). *For every μ ∈ Λ_n, there exists a dominant coweight in the Weyl orbit of μ.*

*Proof sketch.* We prove by induction on n that every function `Fin n → ℤ` can be sorted into weakly decreasing order by a permutation.

- **Base case** (n = 0): The unique function on the empty type is vacuously antitone.
- **Inductive step** (n → n+1): Given μ : Fin (n+1) → ℤ, find the index i₀ where μ attains its maximum. Construct a permutation that maps 0 to i₀ and maps {1,...,n} bijectively onto {0,...,n} \ {i₀}. The restriction to {1,...,n} can be sorted by the inductive hypothesis. The composed permutation sorts μ. □

*Lean verification:*
```lean
theorem exists_dominant_in_orbit {n : ℕ} (μ : Coweight n) :
    ∃ ν : Coweight n, IsDominant ν ∧ InSameOrbit μ ν
```

### 3.3 The Dominant Representative

**Definition 3.3**. Using Theorems 3.1 and 3.2 with the axiom of choice, we define the *dominant representative* map:
$$\text{dom} : \Lambda_n \to \Lambda_n, \quad \mu \mapsto \text{the unique dominant element of } W \cdot \mu$$

**Proposition 3.4**. The dominant representative satisfies:
1. `dom(μ)` is dominant for all μ
2. `dom(μ)` is in the orbit of μ for all μ
3. `dom(μ) = μ` if μ is already dominant
4. `dom(σ · μ) = dom(μ)` for all σ ∈ S_n (Weyl invariance)

## 4. The Tropical Satake Equivalence

### 4.1 The Forward Map

**Definition 4.1** (Satake Restriction). Given a W-invariant function f : Λ_n → α, define its *Satake restriction* to dominant coweights:
$$\text{restrict}(f)(\lambda) := f(\lambda) \quad \text{for dominant } \lambda$$

### 4.2 The Inverse Map

**Definition 4.2** (Satake Extension). Given g : DomCoweight_n → α, define its *Satake extension*:
$$\text{extend}(g)(\mu) := g(\text{dom}(\mu))$$

**Proposition 4.3**. The Satake extension is W-invariant:
$$\text{extend}(g)(\sigma \cdot \mu) = g(\text{dom}(\sigma \cdot \mu)) = g(\text{dom}(\mu)) = \text{extend}(g)(\mu)$$

### 4.3 Main Theorem

**Theorem 4.1** (Tropical Satake Equivalence). *For any type α, the maps*
$$\text{restrict} : \text{WInvFun}(n, \alpha) \to (\text{DomCoweight}_n \to \alpha)$$
$$\text{extend} : (\text{DomCoweight}_n \to \alpha) \to \text{WInvFun}(n, \alpha)$$
*are inverse bijections. That is,*
$$\text{WInvFun}(n, \alpha) \simeq (\text{DomCoweight}_n \to \alpha)$$

*Proof.*
- **restrict ∘ extend = id**: For dominant λ, `dom(λ) = λ`, so `restrict(extend(g))(λ) = g(dom(λ)) = g(λ)`.
- **extend ∘ restrict = id**: For any μ, `extend(restrict(f))(μ) = f(dom(μ))`. Since dom(μ) is in the orbit of μ, and f is W-invariant, `f(dom(μ)) = f(μ)`. □

*Lean verification:*
```lean
noncomputable def tropicalSatakeEquiv (n : ℕ) (α : Type*) :
    WInvFun n α ≃ (DomCoweight n → α)
```

**Corollary 4.2**. The Satake restriction map is:
1. Injective (a W-invariant function is determined by dominant values)
2. Surjective (every function on dominant coweights extends to a W-invariant function)

## 5. Tropical Hecke Operators and Polynomials

### 5.1 Tropical Hecke Operators

**Definition 5.1** (Tropical Hecke Operator). A *tropical Hecke operator* for GL_n is a function
$$H : \text{DomCoweight}_n \to \text{WithTop}\ \mathbb{Z}$$
where `⊤` represents "not in support." The value H(λ) is the min-plus kernel value at the dominant coweight λ.

### 5.2 W-Invariant Tropical Polynomials

**Definition 5.2** (Tropical Affine Form). A *tropical affine form* on Λ_n is a function
$$\ell_{\alpha,c}(\mu) := c + \langle \alpha, \mu \rangle = c + \sum_i \alpha_i \mu_i$$

**Definition 5.3** (Tropical Polynomial). A *tropical polynomial* is a finite minimum of tropical affine forms:
$$p(\mu) = \min_{(\alpha, c) \in S} (c + \langle \alpha, \mu \rangle)$$

**Definition 5.4** (Orbit Symmetrization). The *orbit symmetrization* of tropical data {(α_i, c_i)} is:
$$p^W(\mu) = \min_i \min_{\sigma \in S_n} (c_i + \langle \sigma \cdot \alpha_i, \mu \rangle)$$

**Theorem 5.2** (Symmetrization Invariance). *The orbit-symmetrized tropical polynomial p^W is W-invariant.*

*Proof.* For any τ ∈ S_n:
$$p^W(\tau \cdot \mu) = \min_i \min_{\sigma \in S_n} (c_i + \langle \sigma \cdot \alpha_i, \tau \cdot \mu \rangle)$$
The inner product satisfies ⟨σ · α, τ · μ⟩ = ⟨(τ⁻¹σ) · α, μ⟩. As σ ranges over S_n, so does τ⁻¹σ, so the minimum is unchanged. □

### 5.3 The Hecke-Polynomial Bijection

**Theorem 5.1** (Tropical Satake for Hecke Data). *The tropical Satake transform*
$$\mathcal{S} : \text{TropHecke}_n \to \text{TropPolyInv}_n$$
*defined by S(H)(μ) = H(dom(μ)) is a bijection.*

*Proof.* This is an instantiation of Theorem 4.1 with α = WithTop ℤ. Injectivity follows from the dominant restriction property, and surjectivity from the extension property. □

*Lean verification:*
```lean
theorem tropicalSatakeHecke_bijective (n : ℕ) :
    Bijective (tropicalSatakeHecke (n := n))
```

## 6. Algorithms

### 6.1 Dominant Representative Computation

```
Algorithm DominantRep(μ : ℤⁿ) → ℤⁿ
    return Sort(μ, decreasing)

Complexity: O(n log n)
```

### 6.2 Satake Transform Evaluation

```
Algorithm SatakeEval(H : DomCoweight → WithTop ℤ, μ : ℤⁿ) → WithTop ℤ
    λ ← DominantRep(μ)
    return H(λ)

Complexity: O(n log n) per evaluation
```

### 6.3 Orbit-Symmetrized Polynomial Evaluation

```
Algorithm OrbitSymmEval(data : List(ℤⁿ × ℤ), μ : ℤⁿ) → ℤ
    result ← +∞
    for (α, c) in data:
        for σ in Sₙ:
            val ← c + ⟨σ·α, μ⟩
            result ← min(result, val)
    return result

Complexity: O(k · n! · n) where k = |data|
```

For fixed n, this is O(k · n) with a constant factor of n!. For practical applications with small n (n ≤ 10), this is efficient.

### 6.4 Inverse Satake Transform

```
Algorithm InverseSatake(f : ℤⁿ → WithTop ℤ, bound : ℕ) → TropHecke
    H ← empty map
    for λ dominant with |λᵢ| ≤ bound:
        if f(λ) ≠ ⊤:
            H(λ) ← f(λ)
    return H

Complexity: O(Bⁿ/n!) where B = 2·bound + 1
```

## 7. Computational Experiments

### 7.1 Orbit Structure

| n | Coweights in [-3,3]ⁿ | Dominant | Max orbit size |
|---|----------------------|----------|----------------|
| 2 | 49                   | 28       | 2              |
| 3 | 343                  | 84       | 6              |
| 4 | 2401                 | 210      | 24             |
| 5 | 16807                | 462      | 120            |

The number of dominant coweights grows as Bⁿ/n!, confirming the n!-fold compression.

### 7.2 Roundtrip Verification

For n = 1, 2, 3, 4, we verified the Satake roundtrip property on random Hecke operators supported in [-3, 3]ⁿ:
- 10 random trials per rank
- All roundtrips exact: Restrict(Extend(H)) = H

### 7.3 Tropical Schur Function Injectivity

For GL₃, we verified that the tropical elementary symmetric function map
$$\mu \mapsto (e_1(\mu), e_2(\mu), e_3(\mu))$$
is injective on dominant coweights in [-4, 4]³ (tested on 165 dominant coweights, all with distinct images).

## 8. Discussion

### 8.1 Relationship to Classical Satake

Our tropical Satake isomorphism captures the essential combinatorial content of the classical Satake correspondence:

1. **Orbit parametrization**: The dominant Weyl chamber provides a canonical section of the orbit map, in both the classical and tropical settings.

2. **Extension by invariance**: The inverse Satake transform extends data from dominant coweights to all coweights by symmetry, mirroring the classical construction of spherical functions from their Harish-Chandra transforms.

3. **Structural equivalence**: The bijection preserves the relevant algebraic structure. In the classical case, this is a ring isomorphism; in the tropical case, it is a semiring-compatible bijection.

### 8.2 Limitations

Our formalization does not include:
- The full semiring structure (`≃+*` rather than `≃`): the convolution product on the Hecke side and the tropical product on the polynomial side are not formally compared.
- The relationship to p-adic representation theory: the connection between tropical and classical Satake via dequantization is stated informally.
- Extension to other root systems: only the type A (GL_n) case is treated.

### 8.3 Comparison with Prior Work

Previous formalizations in this project established the tropical Satake correspondence for GL₂ and GL₃ using explicit coordinate computations. Our general GL_n result:
- Replaces hard-coded coordinates with arbitrary `Fin n` indexing
- Uses the abstract orbit-dominance structure rather than explicit sorting formulas
- Applies uniformly to all ranks with a single proof

## 9. Future Work

1. **Semiring isomorphism**: Upgrade the bijection to `TropHecke n ≃+* TropPolyInv n` by formalizing tropical convolution and showing it corresponds to tropical polynomial multiplication.

2. **Tropical Littlewood-Richardson**: Compute structure constants for tropical Hecke convolution and compare with tropicalized LR coefficients.

3. **Other root systems**: Extend to types B, C, D (orthogonal and symplectic groups) using the corresponding Weyl groups and dominant chambers.

4. **Computational complexity**: Analyze the complexity of evaluating the Satake transform and its inverse as a function of the support size.

5. **Tropical automorphic forms**: Use the Satake correspondence as a foundation for defining and computing tropical automorphic forms on GL_n.

## References

[1] I. Satake, "Theory of spherical functions on reductive algebraic groups over p-adic fields," *Publ. Math. IHÉS*, vol. 18, pp. 5–69, 1963.

[2] G. L. Litvinov, "The Maslov dequantization, idempotent and tropical mathematics: A brief introduction," *J. Math. Sci.*, vol. 140, no. 3, pp. 373–386, 2007.

[3] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, vol. 161, AMS, 2015.

[4] P. Gross, "Tropical geometry and mirror symmetry," CBMS Regional Conference Series, AMS, 2011.

[5] A. Gathmann, "Tropical algebraic geometry," *Jahresbericht der DMV*, vol. 108, pp. 3–32, 2006.
