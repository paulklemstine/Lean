# Spectral Pairings: A Symmetric Axiomatization of Fourier Duality with Fully Formalized Proofs

## Abstract

We introduce **spectral pairings**, a novel mathematical structure that axiomatizes Fourier duality between a finite group and its Pontryagin dual in a manifestly symmetric way. Unlike the classical approach via character bases — which privileges the group over its dual — a spectral pairing treats both sides as equal partners through a bilinear pairing satisfying orthogonality in both variables. From these axioms alone, we derive the complete theory of finite Fourier analysis: inversion, Parseval's identity, the uncertainty principle, the convolution theorem, and the double duality (Pontryagin) theorem. We establish contravariance of the dual functor as a direct consequence of the pairing structure. All results are fully formalized in Lean 4 with Mathlib, yielding machine-verified proofs with no unresolved goals.

## 1. Introduction

Fourier analysis on finite abelian groups is a cornerstone of mathematics with applications spanning signal processing, number theory, combinatorics, and theoretical computer science. The classical development proceeds by:

1. Fixing a finite abelian group G.
2. Constructing its dual group Ĝ = Hom(G, ℂˣ).
3. Defining the Fourier transform via characters.
4. Proving orthogonality, inversion, and Parseval from the group structure.

This approach, while effective, introduces an asymmetry: G is primary, Ĝ is derived. Pontryagin's deep theorem — that the double dual G^^ is canonically isomorphic to G — then becomes a non-trivial result requiring careful construction of the evaluation map.

We propose an alternative foundation. A **spectral pairing** between two finite types G and Ĝ is a complex-valued function `⟨·,·⟩ : G × Ĝ → ℂ` satisfying:

- **Row orthogonality**: ∑_g ⟨g,ξ⟩ · ⟨g,ξ'⟩* = |G| · δ_{ξ,ξ'} for all ξ, ξ' ∈ Ĝ.
- **Column orthogonality**: ∑_ξ ⟨g,ξ⟩ · ⟨g',ξ⟩* = |Ĝ| · δ_{g,g'} for all g, g' ∈ G.
- **Completeness**: |G| = |Ĝ|.
- **Unit modulus**: |⟨g,ξ⟩|² = 1 for all g, ξ.

This structure is manifestly symmetric: interchanging G and Ĝ (with conjugation) yields another spectral pairing. The double duality theorem becomes a triviality — it is the algebraic identity conj(conj(z)) = z.

### 1.1 Contributions

1. **Novel structure** (SpectralPairing): A symmetric axiomatization of Fourier duality that makes both sides equal partners.

2. **Complete theory from axioms**: We derive nine theorems from the spectral pairing axioms:
   - Fourier inversion (Theorem 3.1)
   - Parseval's identity (Theorem 3.2)
   - Parseval's energy identity (Corollary 3.3)
   - Uncertainty principle (Theorem 3.4)
   - Convolution theorem (Theorem 3.5)
   - Double duality / transpose involution (Theorem 3.6)
   - Contravariance of the dual functor (Theorem 3.7)
   - Spectral linear independence (Theorem 3.8)
   - Injectivity of the Fourier transform (Theorem 3.9)

3. **Concrete instantiation**: The ZMod n pairing using roots of unity, including a proof of orthogonality of roots of unity.

4. **Full formalization**: All results verified in Lean 4 with Mathlib 4.28.0, with no sorry statements.

## 2. Definitions

### Definition 2.1 (Spectral Pairing)

Let G and Ĝ be finite types with decidable equality. A **spectral pairing** P between G and Ĝ consists of a function pair : G → Ĝ → ℂ satisfying:

(SP1) **Row orthogonality**: For all ξ, ξ' ∈ Ĝ,
$$\sum_{g \in G} \langle g, \xi \rangle \overline{\langle g, \xi' \rangle} = \begin{cases} |G| & \text{if } \xi = \xi' \\ 0 & \text{otherwise} \end{cases}$$

(SP2) **Column orthogonality**: For all g, g' ∈ G,
$$\sum_{\xi \in \hat{G}} \langle g, \xi \rangle \overline{\langle g', \xi \rangle} = \begin{cases} |\hat{G}| & \text{if } g = g' \\ 0 & \text{otherwise} \end{cases}$$

(SP3) **Completeness**: |G| = |Ĝ|.

(SP4) **Unit modulus**: |⟨g,ξ⟩|² = 1 for all g ∈ G, ξ ∈ Ĝ.

### Definition 2.2 (Fourier Transform)

Given a spectral pairing P, the **Fourier transform** of f : G → ℂ is:
$$\hat{f}(\xi) = \sum_{g \in G} f(g) \overline{\langle g, \xi \rangle}$$

### Definition 2.3 (Inverse Fourier Transform)

$$f(g) = \frac{1}{|G|} \sum_{\xi \in \hat{G}} F(\xi) \langle g, \xi \rangle$$

### Definition 2.4 (Transpose Pairing)

The **transpose** of P is the spectral pairing P^T : SpectralPairing Ĝ G defined by:
$$P^T(\xi, g) = \overline{P(g, \xi)}$$

### Definition 2.5 (Support Cardinality)

For f : α → ℂ, the **support cardinality** is:
$$\text{suppCard}(f) = |\{x \in \alpha : f(x) \neq 0\}|$$

## 3. Main Results

### Theorem 3.1 (Fourier Inversion)

*For any spectral pairing P and function f : G → ℂ, if |G| ≠ 0 in ℂ, then:*
$$P^{-1}(P(f)) = f$$

**Proof sketch**: Expand the composition, interchange summation order, apply column orthogonality to collapse the inner sum, and cancel the 1/|G| factor using |G| = |Ĝ|.

### Theorem 3.2 (Parseval's Identity)

*For any spectral pairing P and functions f, h : G → ℂ:*
$$\sum_{\xi \in \hat{G}} \hat{f}(\xi) \overline{\hat{h}(\xi)} = |G| \sum_{g \in G} f(g) \overline{h(g)}$$

**Proof sketch**: Expand both Fourier transforms, distribute the conjugation, interchange summation, apply column orthogonality to the inner sum over ξ.

### Corollary 3.3 (Parseval Energy Identity)

$$\sum_{\xi} |\hat{f}(\xi)|^2 = |G| \sum_g |f(g)|^2$$

### Theorem 3.4 (Uncertainty Principle)

*For any nonzero f : G → ℂ with |G| ≠ 0:*
$$\text{suppCard}(f) \cdot \text{suppCard}(\hat{f}) \geq |G|$$

**Proof sketch**: Apply Cauchy-Schwarz to bound each Fourier coefficient |f̂(ξ)|² ≤ |supp(f)| · ‖f‖₂². Sum over the spectral support. Use Parseval to get |G| · ‖f‖₂² ≤ |supp(f)| · |supp(f̂)| · ‖f‖₂². Cancel ‖f‖₂² > 0.

### Theorem 3.5 (Convolution Theorem)

*On an additive group G with an additive pairing (⟨g₁+g₂, ξ⟩ = ⟨g₁,ξ⟩ · ⟨g₂,ξ⟩):*
$$\widehat{f * h}(\xi) = \hat{f}(\xi) \cdot \hat{h}(\xi)$$

**Proof sketch**: Substitute x' = x - y in the convolution sum, use the additivity of the pairing to factor the exponential, and recognize the resulting sums as independent Fourier transforms.

### Theorem 3.6 (Double Duality / Transpose Involution)

*For any spectral pairing P:*
$$P^{TT}(g, \xi) = P(g, \xi)$$

**Proof**: Direct computation: conj(conj(z)) = z.

### Theorem 3.7 (Contravariance)

*If spectral pairings P on (G, Ĝ) and Q on (G, Ĝ₂) are compatible via φ_dual : Ĝ₂ → Ĝ (meaning Q(g,ξ) = P(g, φ_dual(ξ))), then:*
$$\text{FT}_Q(f)(\xi) = \text{FT}_P(f)(\varphi^*(\xi))$$

This is the categorical content of Pontryagin duality: the dual functor is contravariant.

### Theorem 3.8 (Spectral Linear Independence)

*If ∑_g c_g · ⟨g,ξ⟩ = 0 for all ξ and |G| ≠ 0, then c = 0.*

**Proof**: Multiply by conj(⟨g₀,ξ⟩) and sum over ξ. Column orthogonality collapses the sum to c(g₀) · |Ĝ| = 0, forcing c(g₀) = 0.

### Theorem 3.9 (Fourier Transform Injectivity)

*The Fourier transform is injective (for |G| ≠ 0).*

**Proof**: Follows immediately from Fourier inversion.

## 4. The ZMod n Construction

### Proposition 4.1

*For n ≥ 1, the function*
$$\langle a, b \rangle = \exp(2\pi i \cdot a \cdot b / n)$$
*defines a spectral pairing on ZMod n × ZMod n.*

**Proof**: Unit modulus follows from |exp(iθ)| = 1. Row and column orthogonality follow from the geometric sum formula: ∑_{k=0}^{n-1} ωᵏ = 0 for ω a non-trivial nth root of unity.

This construction witnesses the **self-duality** of cyclic groups: ZMod n is its own Pontryagin dual.

## 5. Categorical Interpretation

### 5.1 The Dual Functor

The spectral pairing framework reveals the categorical structure of Fourier duality:

1. **Objects**: Finite types equipped with spectral pairings.
2. **Morphisms**: Functions compatible with the pairings (in the sense of Theorem 3.7).
3. **Dual functor**: The transpose operation P ↦ P^T, which:
   - Reverses the roles of G and Ĝ (contravariance on objects).
   - Reverses the direction of compatible morphisms (contravariance on morphisms, Theorem 3.7).
   - Is involutive (Theorem 3.6).

This is a **duality** in the sense of category theory: a contravariant equivalence from the category of spectral-paired types to itself.

### 5.2 The Uncertainty Principle as a Categorical Statement

The uncertainty principle (Theorem 3.4) can be understood categorically: it is a statement about the **rank** of the pairing matrix. The pairing matrix M_{g,ξ} = ⟨g,ξ⟩ is a unitary matrix (after normalization), and its rows and columns are linearly independent (Theorem 3.8). The uncertainty principle says that any vector in the range of M — i.e., any Fourier transform — cannot have support smaller than |G|/|supp(f)|.

This connects to the broader theme of **information conservation** in categorical dualities: a functor that preserves too much structure in one direction (concentrating support) must spread structure in the other (expanding spectral support).

## 6. PEGB Analysis

### PEGB for Fourier Inversion (Theorem 3.1)

- **Proof**: Complete Lean 4 proof using sum interchange and column orthogonality.
- **Example**: For ZMod 4 with the standard pairing, FT of the delta function δ₀ = (1,0,0,0) is (1,1,1,1), and IFT((1,1,1,1)) = (1,0,0,0).
- **Generalization**: Holds for any spectral pairing, not just group-theoretic ones. Could extend to "approximate spectral pairings" where orthogonality holds up to ε.
- **Boundary**: Fails when |G| = 0 in ℂ (i.e., characteristic divides |G|). The hypothesis (Fintype.card G : ℂ) ≠ 0 is sharp.

### PEGB for Uncertainty Principle (Theorem 3.4)

- **Proof**: Complete Lean 4 proof via Cauchy-Schwarz and Parseval.
- **Example**: For ZMod 12, a function supported on {0,1,2} has suppCard = 3, so its FT must have suppCard ≥ ⌈12/3⌉ = 4.
- **Generalization**: For non-abelian groups, the uncertainty principle generalizes to supp(f) · dim(supp(f̂)) ≥ |G|, where dim accounts for representation dimensions.
- **Boundary**: The bound is tight: the delta function δ_g has suppCard = 1 and its FT has suppCard = |G|, achieving equality.

### PEGB for Parseval's Identity (Theorem 3.2)

- **Proof**: Complete Lean 4 proof via Fubini-type sum interchange.
- **Example**: For the function f on ZMod 4 given by f(0)=1, f(1)=i, f(2)=-1, f(3)=-i, the Parseval identity gives ∑|f̂|² = 4 · ∑|f|² = 4 · 4 = 16.
- **Generalization**: Extends to Plancherel theorem for locally compact abelian groups (with Haar measure).
- **Boundary**: The normalization factor |G| is essential; without it, the identity fails except for |G|=1.

### PEGB for Convolution Theorem (Theorem 3.5)

- **Proof**: Complete Lean 4 proof via reindexing and pairing additivity.
- **Example**: Convolution of two indicator functions on ZMod n gives the number of representations as a sum.
- **Generalization**: For non-abelian groups, convolution maps to matrix multiplication in the representation.
- **Boundary**: Requires the pairing to be additive/multiplicative. For general spectral pairings without group structure, convolution is not defined.

### PEGB for Contravariance (Theorem 3.7)

- **Proof**: One-line proof by sum congr.
- **Example**: The inclusion ι : ZMod 2 → ZMod 4 induces a dual map ι* : (ZMod 4)^ → (ZMod 2)^ going in the reverse direction.
- **Generalization**: Extends to natural transformations between functors on categories of spectral-paired types.
- **Boundary**: The compatibility condition is essential. Without it, there is no functorial relationship.

## 7. Falsifiable Conjecture

**Conjecture (Spectral Rigidity)**: If two spectral pairings P, Q on the same pair (G, Ĝ) satisfy P.pair g ξ = Q.pair (σ g) (τ ξ) for some permutations σ, τ, then σ and τ are group automorphisms (when G and Ĝ carry group structures compatible with the pairings).

**Computational test**: For ZMod p (p prime), enumerate all permutations σ of ZMod p such that the permuted DFT matrix is still a DFT matrix. Check whether all such σ are affine maps a ↦ ca + d for some c ∈ (ZMod p)ˣ, d ∈ ZMod p.

## 8. Cross-Connection to Existing Catalog

The uncertainty principle proved here (Theorem 3.4) directly generalizes the existing catalog theorem `uncertainty_principle_finite_abelian` from `Algebra/FourierAnalysis/Theorems.lean`. Our version is more general: it works for any spectral pairing, not just those arising from finite abelian groups. The key innovation is that our proof uses only the orthogonality axioms, making it applicable to approximate spectral pairings, quantum groups, and other settings where character theory may not be available.

## 9. Discussion

### 9.1 Advantages of the Spectral Pairing Framework

1. **Symmetry**: Both sides are treated equally, making double duality trivial.
2. **Modularity**: Each theorem depends only on the axioms, not on the construction of the dual group.
3. **Generality**: Applies to any complete orthogonal pairing, not just group-theoretic ones.
4. **Formalizability**: The axioms are clean and the proofs are modular, making formalization natural.

### 9.2 Limitations

1. **No group structure**: The spectral pairing doesn't directly encode the group operation. The convolution theorem requires an additional hypothesis (additivity of the pairing).
2. **Finite only**: Extension to locally compact abelian groups requires measure theory.
3. **No representation theory**: For non-abelian groups, characters are replaced by representations, which require a fundamentally different framework.

## 10. Future Work

1. Extend spectral pairings to locally compact abelian groups using integration.
2. Develop "approximate spectral pairings" for applications to compressed sensing.
3. Connect to Tannaka-Krein duality for non-abelian groups.
4. Formalize the spectral pairing as a category with duality and prove it forms a dagger category.

## References

1. Pontryagin, L. S. (1934). The theory of topological commutative groups. *Annals of Mathematics*, 35(2), 361–388.
2. Terras, A. (1999). *Fourier Analysis on Finite Groups and Applications*. Cambridge University Press.
3. Donoho, D. L., & Stark, P. B. (1989). Uncertainty principles and signal recovery. *SIAM Journal on Applied Mathematics*, 49(3), 906–931.
4. Rudin, W. (1962). *Fourier Analysis on Groups*. Wiley-Interscience.
5. Mac Lane, S. (1998). *Categories for the Working Mathematician* (2nd ed.). Springer.
