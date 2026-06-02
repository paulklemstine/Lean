# The Möbius Ring ℤ√1: Arithmetic on the Möbius Band

## Abstract

We formalize the **Möbius ring** ℤ√1 = ℤ[ε]/(ε² − 1), the ring of integers extended by a square root of unity, and establish its fundamental algebraic properties in connection with the topology of the Möbius band. We prove that ℤ√1 is a non-domain commutative ring with exactly four units forming the Klein four-group V₄, that its norm map N(a+bε) = a² − b² factors as (a+b)(a−b) and satisfies a mod-4 obstruction (no element has norm ≡ 2 mod 4), that the splitting homomorphism φ: ℤ√1 → ℤ × ℤ is injective with image characterized by a parity constraint, and that the ring has no nontrivial idempotents — an arithmetic rigidity result reflecting the impossibility of decomposing the Möbius band. All results are machine-verified in Lean 4 using Mathlib's `Zsqrtd` framework.

**Keywords**: Möbius ring, quadratic integers, zero divisors, idempotent rigidity, splitting homomorphism, orientation ideals, norm obstruction

## 1. Introduction

The rings ℤ√d for various integers d form a classical family in algebraic number theory. For d < 0, we obtain imaginary quadratic rings (e.g., the Gaussian integers ℤ[i] = ℤ√(−1)); for d > 1 square-free, we obtain real quadratic integer rings. The degenerate case d = 1 is typically dismissed, since ℤ√1 is not a domain and therefore not an integral extension in the traditional sense. However, this "defect" is precisely what makes ℤ√1 interesting from the perspective of topology-algebra correspondence.

We refer to ℤ√1 as the **Möbius ring** because its algebraic structure mirrors the topology of the Möbius band with remarkable fidelity. Zero divisors encode non-orientability, the unit group's exponent-2 structure captures the double-traversal property, orientation ideals correspond to the two sheets of the orientation double cover, and the parity obstruction in the splitting map reflects the mod-2 cohomological obstruction to orientability.

### 1.1 Related Work

The ring ℤ[x]/(x² − 1) appears in various contexts: as the group ring ℤ[ℤ/2ℤ], in the theory of Witt vectors, and in algebraic K-theory. Its connection to the Möbius band via the fundamental group π₁(S¹) ≅ ℤ and the orientation character ℤ/2ℤ is well-known at the level of folklore. Our contribution is to make this connection fully explicit and machine-verified, and to identify several structural theorems (idempotent rigidity, mod-4 obstruction, annihilator intersection) that illuminate the correspondence.

## 2. Definitions

### 2.1 The Möbius Ring

**Definition 2.1** (Möbius Ring). The Möbius ring is

$$\mathbb{M} = \mathbb{Z}\sqrt{1} = \mathbb{Z}[\varepsilon]/(\varepsilon^2 - 1)$$

where ε is a formal square root of 1. Elements have the form a + bε with a, b ∈ ℤ, with arithmetic:

- (a + bε) + (c + dε) = (a+c) + (b+d)ε
- (a + bε)(c + dε) = (ac + bd) + (ad + bc)ε

In our formalization, we use Mathlib's `Zsqrtd 1`, which provides the comm_ring instance automatically.

**Definition 2.2** (Orientation Elements). The positive and negative orientation elements are:

- e₊ = 1 + ε = ⟨1, 1⟩
- e₋ = 1 − ε = ⟨1, −1⟩

**Definition 2.3** (Norm). The norm N: 𝕄 → ℤ is defined by N(a + bε) = a² − b².

**Definition 2.4** (Norm Fiber). For n ∈ ℤ, the norm fiber N⁻¹(n) is the set {z ∈ 𝕄 : N(z) = n}.

**Definition 2.5** (Idempotent). An element z ∈ 𝕄 is idempotent if z² = z.

### 2.2 The Splitting Homomorphism

**Definition 2.6** (Splitting Map). The splitting map φ: 𝕄 → ℤ × ℤ is the ring homomorphism

$$\varphi(a + b\varepsilon) = (a + b, a - b)$$

## 3. Main Results

### 3.1 Basic Structure

**Theorem 3.1** (Defining Relation). ε² = 1.

*Proof*. Direct computation in ℤ√1. ∎

**Theorem 3.2** (Zero Divisor). e₊ · e₋ = (1+ε)(1−ε) = 0.

*Proof*. (1+ε)(1−ε) = 1 − ε² = 1 − 1 = 0. ∎

**Theorem 3.3** (Non-Domain). 𝕄 is not an integral domain.

*Proof*. The elements e₊ and e₋ are nonzero (they have nonzero real parts) but their product is zero by Theorem 3.2. This witnesses a zero divisor, contradicting the definition of an integral domain. ∎

### 3.2 Norm Factorization

**Theorem 3.4** (Norm Factorization). For all z ∈ 𝕄, N(z) = (re(z) + im(z))(re(z) − im(z)).

*Proof*. N(a + bε) = a² − 1·b² = a² − b² = (a+b)(a−b). ∎

This factorization is the key structural result. It implies that the norm map factors through the splitting homomorphism as the product map (x, y) ↦ xy, connecting the multiplicative structure of ℤ√1 to the multiplicative structure of ℤ × ℤ.

### 3.3 Unit Classification

**Theorem 3.5** (Unit Criterion). z ∈ 𝕄 is a unit if and only if re(z) + im(z) ∈ {±1} and re(z) − im(z) ∈ {±1}.

*Proof*. By Mathlib's `Zsqrtd.isUnit_iff_norm_isUnit`, z is a unit iff N(z) is a unit in ℤ. By Theorem 3.4, N(z) = (re(z)+im(z))(re(z)−im(z)). A product of integers is a unit iff both factors are units, and the units of ℤ are {±1}. ∎

**Corollary 3.6**. The unit group of 𝕄 is {1, −1, ε, −ε}, corresponding to (re, im) ∈ {(1,0), (−1,0), (0,1), (0,−1)}.

**Theorem 3.7** (Exponent-2 Property). Every unit z ∈ 𝕄 satisfies z² = 1.

*Proof*. By Theorem 3.5, the four possible values of (re(z)+im(z), re(z)−im(z)) are (1,1), (1,−1), (−1,1), (−1,−1), giving (re,im) ∈ {(1,0), (0,1), (0,−1), (−1,0)}. Direct computation shows z² = 1 in each case. ∎

This means the unit group is isomorphic to V₄ = (ℤ/2ℤ)², the Klein four-group. Topologically, the exponent-2 property corresponds to the fact that traversing the Möbius band twice restores orientation.

### 3.4 The Splitting Homomorphism

**Theorem 3.8** (Splitting Homomorphism). The map φ(a+bε) = (a+b, a−b) is a ring homomorphism 𝕄 → ℤ × ℤ.

*Proof*. Verified field by field:
- φ(0) = (0, 0)
- φ(1) = (1, 1)
- φ(x + y) = φ(x) + φ(y) (linearity of ±)
- φ(xy) = φ(x)φ(y) (the key computation: (ac+bd+ad+bc, ac+bd−ad−bc) = (a+b)(c+d), (a−b)(c−d))). ∎

**Theorem 3.9** (Injectivity). φ is injective.

*Proof*. If φ(x) = φ(y), then x.re + x.im = y.re + y.im and x.re − x.im = y.re − y.im. Adding: 2·x.re = 2·y.re, so x.re = y.re. Subtracting: 2·x.im = 2·y.im, so x.im = y.im. ∎

**Theorem 3.10** (Parity Obstruction). For all z ∈ 𝕄, φ(z).1 ≡ φ(z).2 (mod 2).

*Proof*. φ(z).1 − φ(z).2 = (re+im) − (re−im) = 2·im, which is even. ∎

The image of φ is exactly the subring {(x, y) ∈ ℤ² : x ≡ y (mod 2)}. The non-surjectivity of φ is the algebraic counterpart of the non-trivial double cover of the Möbius band by the cylinder.

### 3.5 Idempotent Rigidity

**Theorem 3.11** (Idempotent Rigidity). The only idempotents in 𝕄 are 0 and 1.

*Proof sketch*. Let z = a + bε satisfy z² = z. Expanding: a² + b² = a and 2ab = b. From 2ab = b we get b(2a − 1) = 0. Since 2a − 1 is odd and hence nonzero for all integers a, we must have b = 0. Then a² = a gives a ∈ {0, 1}. ∎

This is the key rigidity theorem. Over ℚ, the ring ℚ√1 ≅ ℚ × ℚ has nontrivial idempotents (1 ± ε)/2. The integrality condition prevents the decomposition, creating an arithmetic obstruction analogous to the topological indivisibility of the Möbius band.

### 3.6 Orientation Ideal Annihilation

**Theorem 3.12** (Annihilation). For all a, b ∈ ℤ, (a · e₊)(b · e₋) = 0.

*Proof*. (a · e₊)(b · e₋) = ab · (e₊ · e₋) = ab · 0 = 0. ∎

**Theorem 3.13** (Annihilator Intersection). If e₊ · z = 0 and e₋ · z = 0, then z = 0.

*Proof*. From e₊ · z = 0: re(z) + im(z) = 0 (from both components). From e₋ · z = 0: re(z) − im(z) = 0. Adding: 2·re(z) = 0, so re(z) = 0, hence im(z) = 0. ∎

### 3.7 Mod-4 Obstruction

**Theorem 3.14** (Mod-4 Obstruction). For all z ∈ 𝕄, N(z) ≢ ±2 (mod 4).

*Proof*. By Theorem 3.4, N(z) = (re+im)(re−im). Since re+im ≡ re−im (mod 2), both factors have the same parity. If both are even, the product is ≡ 0 (mod 4). If both are odd, the product is odd. In neither case is the product ≡ ±2 (mod 4). ∎

**Corollary 3.15**. 2 is not a Möbius norm: there is no z ∈ 𝕄 with N(z) = 2.

## 4. Algorithms

### 4.1 Norm Computation

Given z = a + bε, compute N(z) = (a+b)(a−b) in O(1) arithmetic operations.

### 4.2 Unit Detection

Given z = a + bε, check if |a+b| = 1 and |a−b| = 1 in O(1) time.

### 4.3 Norm Representability

Given n ∈ ℤ, determine if n is a Möbius norm:
- If n ≡ 2 (mod 4), return False.
- Otherwise, find a, b with a² − b² = n:
  - If n is odd: a = (n+1)/2, b = (n−1)/2.
  - If n ≡ 0 (mod 4): a = n/4 + 1, b = n/4 − 1. (More precisely: a = (n/2+2)/2, b = (n/2−2)/2 when 4 | n.)

## 5. Discussion

### 5.1 Topology-Algebra Dictionary

The results above establish a precise dictionary between topological features of the Möbius band and algebraic properties of ℤ√1:

| Topological Property | Algebraic Property | Theorem |
|---------------------|-------------------|---------|
| Non-orientability | Zero divisors exist | 3.2, 3.3 |
| Orientation double cover | Splitting hom φ: 𝕄 ↪ ℤ × ℤ | 3.8, 3.9 |
| Cover is non-trivial | Parity obstruction | 3.10 |
| Double traversal restores orientation | Unit group has exponent 2 | 3.7 |
| Cannot decompose into two disks | Idempotent rigidity | 3.11 |
| Two local orientations | Orientation ideals e₊, e₋ | 3.12, 3.13 |
| Norm is indefinite | Mod-4 obstruction | 3.14 |

### 5.2 Connections to Other Areas

**K-theory**: The Möbius ring can be viewed as KO⁰ of the Möbius band in the sense that it classifies real vector bundles over the band. The non-trivial line bundle corresponds to the element ε.

**Group rings**: ℤ√1 ≅ ℤ[ℤ/2ℤ], the group ring of the cyclic group of order 2, which is precisely the fundamental group of the circle (the base of the Möbius band as a fiber bundle).

**Witt ring**: The Möbius ring appears in the theory of quadratic forms as related to the Witt ring of ℤ. The norm form ⟨1, −1⟩ represents the hyperbolic plane, which is trivial in the Witt group.

## 6. Future Work

1. **Klein Bottle Ring**: Formalize the group ring ℤ[π₁(K)] of the Klein bottle's fundamental group and study its non-commutative structure.

2. **Density of Norm Values**: Prove that the asymptotic density of Möbius norms in [1, N] converges to 3/4.

3. **Higher Cohomology**: Connect the mod-4 obstruction to the second Stiefel-Whitney class and formalize this in the language of sheaf cohomology.

4. **Generalization to ℤ√d**: Systematically compare the algebraic features of ℤ√d for various d, identifying which topological properties persist and which are specific to d = 1.

## References

1. Lang, S. *Algebraic Number Theory*. Springer, 1994.
2. Milnor, J. and Stasheff, J. *Characteristic Classes*. Princeton University Press, 1974.
3. Serre, J.-P. *Local Fields*. Springer, 1979.
4. Mathlib Community. *Mathlib: Zsqrtd*. https://leanprover-community.github.io/mathlib4_docs/
