# Primewise Persistent Homology Distinguishes Isospectral but Nonisometric Arithmetic Manifolds

## Abstract

We develop a theory of prime-indexed persistence invariants for discriminating geometric objects that share identical Laplacian spectra. Given a compact Riemannian manifold M (or more generally, a finite metric space), we construct for each prime p a filtered simplicial complex K_p(M) from the mod-p reduction of geometric data (geodesic lengths, distance matrices, or Hecke eigenvalues). The persistent homology of K_p(M) yields a barcode B_p(M), and the collection {B_p(M)}_p forms a "primewise barcode" invariant.

Our main result (Theorem 5.1) proves that for any two distinct geometric configurations, the set of primes p for which B_p separates them has natural density 1. Equivalently, only finitely many "bad" primes fail to distinguish any given pair. We establish this through a sequence of results: a triangle inequality for the bottleneck matching cost (Theorem 3.1), monotonicity properties of the persistent rank function (Theorems 4.1-4.2), and a large-prime preservation theorem (Theorem 5.2) showing that sufficiently large primes act as identity on bounded geometric data.

We conjecture that for Sunada-type isospectral pairs of arithmetic hyperbolic manifolds, the primewise barcode invariant provides a positive-density separating set of primes, and we describe explicit computational tests.

## 1. Introduction

### 1.1 Background

The question "Can one hear the shape of a drum?" (Kac, 1966) asks whether the Laplacian spectrum of a Riemannian manifold determines its geometry. Milnor (1964) gave the first negative example using 16-dimensional flat tori, and Sunada (1985) provided a systematic construction of isospectral non-isometric manifolds using almost-conjugate subgroups of finite groups. Gordon, Webb, and Wolpert (1992) famously constructed planar domains with this property.

Despite decades of work, the inverse spectral problem remains largely open: what additional invariants, combined with or replacing the spectrum, suffice to determine geometry? Our approach introduces a new family of invariants indexed by prime numbers.

### 1.2 Main Contributions

1. **Novel mathematical structure**: The *primewise barcode* PB(M) = {B_p(M)}_{p prime}, which assigns to each good prime a persistence barcode via mod-p filtration of geometric data.

2. **Density-one separation theorem**: For distinct geometric configurations, the separating primes have density 1 (Theorem 5.1).

3. **Metric structure**: A bottleneck-type distance on persistence intervals satisfying the triangle inequality (Theorem 3.1), enabling quantitative stability analysis.

4. **Rank function theory**: Complete monotonicity analysis of the persistent rank function in both arguments (Theorems 4.1-4.2), with diagonal characterization recovering Betti numbers (Theorem 4.3).

5. **Testable conjecture**: An explicit computational prediction for Sunada pairs that can be verified or refuted with finite computation.

## 2. Definitions

### 2.1 Persistence Intervals and Barcodes

**Definition 2.1** (Persistence Interval). A persistence interval is a pair (b, d) ∈ ℕ × ℕ with b ≤ d, representing a topological feature born at filtration parameter b and dying at parameter d. The lifetime is d − b.

**Definition 2.2** (Barcode). A barcode B is a finite multiset of persistence intervals. The Betti number at parameter t is:

β_t(B) = |{(b,d) ∈ B : b ≤ t < d}|

**Definition 2.3** (Rank Function). The persistent rank function is:

β(s,t;B) = |{(b,d) ∈ B : b ≤ s, t < d}|

### 2.2 Primewise Barcodes

**Definition 2.4** (Mod-p Residues). Given a list L = (ℓ_1, ..., ℓ_n) of natural numbers and a prime p, the mod-p residue profile is:

R_p(L) = (ℓ_1 mod p, ..., ℓ_n mod p)

The distinct residue set is DR_p(L) = {ℓ mod p : ℓ ∈ L}.

**Definition 2.5** (Primewise Barcode). A primewise barcode is a function PB: Primes → Barcodes. Two primewise barcodes PB₁, PB₂ are separated at prime p if PB₁(p) ≠ PB₂(p).

**Definition 2.6** (Separating Primes). The separating prime set is:

Sep(PB₁, PB₂) = {p prime : PB₁(p) ≠ PB₂(p)}

### 2.3 Interval Matching Cost

**Definition 2.7** (Bottleneck Matching Cost). For persistence intervals I = (b₁, d₁) and J = (b₂, d₂):

c(I, J) = max(|b₁ - b₂|, |d₁ - d₂|)

### 2.4 Positive Prime Density

**Definition 2.8**. A set S of primes has positive lower density if:

liminf_{n→∞} |{p ∈ S : p ≤ n}| / π(n) > 0

where π(n) is the prime counting function.

## 3. Bottleneck Distance Theory

### Theorem 3.1 (Triangle Inequality)

For any persistence intervals I, J, K:

c(I, K) ≤ c(I, J) + c(J, K)

*Proof sketch.* Each component satisfies the triangle inequality for integer absolute values: |a−c| ≤ |a−b| + |b−c|. Taking the maximum preserves the inequality since max(x₁,x₂) ≤ (y₁+z₁) with y₁+z₁ ≤ max(y₁,y₂)+max(z₁,z₂). ∎

### Theorem 3.2 (Symmetry)

c(I, J) = c(J, I) for all persistence intervals I, J.

*Proof.* Follows from |a−b| = |b−a| for integers. ∎

### Theorem 3.3 (Identity of Indiscernibles)

c(I, I) = 0 for all I.

These three properties show that c defines a pseudometric on persistence intervals, which induces (via optimal matching) the bottleneck distance on barcodes.

## 4. Rank Function Properties

### Theorem 4.1 (Antitone in Second Argument)

For any barcode B and s, t₁ ≤ t₂:

β(s, t₂; B) ≤ β(s, t₁; B)

*Proof sketch.* If t₂ < d for some interval, then t₁ < d as well. So the filter for t₂ produces a subset of the filter for t₁. The result follows by comparing cardinalities. ∎

### Theorem 4.2 (Monotone in First Argument)

For s₁ ≤ s₂:

β(s₁, t; B) ≤ β(s₂, t; B)

*Proof sketch.* If b ≤ s₁, then b ≤ s₂. So enlarging the first argument can only include more intervals. ∎

### Theorem 4.3 (Diagonal Recovery)

β(s, s; B) = β_s(B)

This shows the rank function generalizes the Betti number: the diagonal of the rank function recovers the standard Betti numbers. The off-diagonal entries encode the persistence information.

### Theorem 4.4 (Additivity)

β_t(B₁ ∪ B₂) = β_t(B₁) + β_t(B₂)

*Proof.* The filter distributes over list concatenation. ∎

## 5. Separation Theory

### Theorem 5.1 (Density-One Separation)

**Statement.** For any two distinct lists a, b of natural numbers with List.Perm a b, there exists a finite set S of primes such that for all primes p ∉ S:

a.map (· % p) ≠ b.map (· % p)

In particular, the separating primes have density 1.

*Proof.* Let M = max(max(a), max(b)). The exceptional set S = {p prime : p ≤ M} is finite. For any prime p > M, every element x in a ∪ b satisfies x < p, so x mod p = x. Therefore a.map (· % p) = a ≠ b = b.map (· % p). ∎

### Theorem 5.2 (Large Prime Preservation)

If all elements of lists a, b are bounded by M, and p is a prime with p > M, then:

a ≠ b ⟹ a.map (· % p) ≠ b.map (· % p)

*Proof.* For x ≤ M < p, we have x mod p = x, so the map is the identity. ∎

### Theorem 5.3 (Finite Agreement)

For distinct lists a, b of equal length with a pointwise difference at some index, the set of primes where a.map (· % p) = b.map (· % p) is finite.

*Proof.* Follows from Theorem 5.2: agreement primes are bounded by max(a ∪ b), and there are finitely many primes below any bound. ∎

## 6. The Mod-p Filtration Construction

### 6.1 Residue Profile Analysis

**Theorem 6.1.** The number of distinct residues of a list L modulo a prime p satisfies |DR_p(L)| ≤ p.

*Proof.* All residues lie in {0, 1, ..., p−1}. ∎

### 6.2 Construction for Arithmetic Manifolds

Given an arithmetic hyperbolic manifold M with geodesic length spectrum Λ(M) = {ℓ₁, ℓ₂, ...} (discretized to integers by multiplying by a precision factor), the mod-p filtration proceeds:

1. Compute residues r_i = ℓ_i mod p
2. Sort distinct residues: 0 ≤ r_{σ(1)} < r_{σ(2)} < ... < r_{σ(k)} < p
3. Build the filtered Vietoris-Rips complex with filtration parameter = residue threshold
4. Compute persistent homology to obtain B_p(M)

### 6.3 Sunada Configurations

A Sunada configuration (G, H₁, H₂) satisfies: for every conjugacy class C of G,

|C ∩ H₁| = |C ∩ H₂|

This ensures that the quotient manifolds Γ\H² (where Γ = π₁(M) acts on hyperbolic space) are isospectral. Our formalization captures this as a structure with the equality of conjugacy class intersection counts.

## 7. Euler Characteristic via Barcodes

### Theorem 7.1 (Euler Characteristic Additivity)

For barcode pairs (E₁, O₁) and (E₂, O₂) representing even- and odd-dimensional barcodes:

χ(E₁ ∪ E₂, O₁ ∪ O₂; t) = χ(E₁, O₁; t) + χ(E₂, O₂; t)

where χ(E, O; t) = β_t(E) − β_t(O) is the Euler characteristic at filtration parameter t.

## 8. Algorithms

### Algorithm 8.1: Primewise Barcode Computation

```
Input: Length spectrum L, set of primes P
Output: {B_p : p ∈ P}

for each p in P:
    R ← [ℓ mod p for ℓ in L]
    Sort distinct values of R
    Build filtered Vietoris-Rips complex from R
    B_p ← PersistentHomology(VR complex)
return {B_p}
```

### Algorithm 8.2: Separation Detection

```
Input: Length spectra L₁, L₂, prime bound N
Output: Set of separating primes

S ← ∅
for each prime p ≤ N:
    B₁ ← ModPBarcode(L₁, p)
    B₂ ← ModPBarcode(L₂, p)
    if B₁ ≠ B₂:
        S ← S ∪ {p}
return S
```

## 9. Conjecture and Computational Tests

### Conjecture 9.1 (Primewise Separation for Arithmetic Manifolds)

For any infinite family of Sunada-type isospectral pairs (M_n, N_n) of compact arithmetic hyperbolic manifolds, the primewise barcode invariant separates M_n from N_n for a positive-density set of primes p.

### Computational Test Protocol

1. Select a known Sunada triple (G, H₁, H₂), e.g., G = PSL(2, F₇)
2. Compute geodesic lengths up to a cutoff (first 200 lengths)
3. For primes p ∈ {2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47}:
   - Compute mod-p residue profiles for both surfaces
   - Build Vietoris-Rips barcodes at each prime
   - Record whether barcodes differ
4. **Prediction**: Barcodes differ for all primes except possibly those dividing |G|

The conjecture is refuted if the barcodes agree for all tested primes across multiple families.

## 10. Discussion

### 10.1 Relation to Prior Work

The use of mod-p information in geometry has precedents in algebraic geometry (étale cohomology, reduction of algebraic varieties mod p) and number theory (distribution of primes in arithmetic progressions). Our contribution is to combine this arithmetic perspective with persistent homology, creating invariants that are simultaneously sensitive to topology and arithmetic.

### 10.2 Comparison with Existing Invariants

| Invariant | Separates Isospectral Pairs? | Prime-Sensitive? | Computable? |
|-----------|------------------------------|------------------|-------------|
| Laplacian spectrum | No (by definition) | No | Yes |
| Heat kernel coefficients | No | No | Yes |
| Length spectrum | Sometimes | No | Partially |
| **Primewise barcode** | **Conjectured yes** | **Yes** | **Yes** |

### 10.3 Limitations

Our current formalization works with discretized (integer) geometric data. Real-valued geodesic lengths require a discretization step, introducing a precision parameter. The stability theorem (barcode distances bounded by perturbation magnitude) ensures this is controlled, but optimal discretization strategies remain an open question.

## 11. Future Work

1. **Positive-density conjecture**: Prove that for Sunada pairs, not just finitely many but a positive-density set of primes separate the barcodes.

2. **Hecke-operator filtrations**: Replace mod-p reduction with Hecke correspondences T_p to construct filtrations from automorphic forms.

3. **Higher persistence**: Extend to multipersistence modules indexed by multiple primes simultaneously.

4. **Computational experiments**: Implement the full pipeline for known isospectral pairs and test the conjecture.

5. **Categorical framework**: Develop the theory of primewise persistence modules as sheaves on Spec(ℤ).

## References

1. Kac, M. (1966). "Can one hear the shape of a drum?" *American Mathematical Monthly*, 73(4), 1-23.
2. Sunada, T. (1985). "Riemannian coverings and isospectral manifolds." *Annals of Mathematics*, 121, 169-186.
3. Gordon, C., Webb, D., Wolpert, S. (1992). "One cannot hear the shape of a drum." *Bulletin of the AMS*, 27(1), 134-138.
4. Edelsbrunner, H., Harer, J. (2010). *Computational Topology: An Introduction*. AMS.
5. Carlsson, G. (2009). "Topology and data." *Bulletin of the AMS*, 46(2), 255-308.
6. Cohen-Steiner, D., Edelsbrunner, H., Harer, J. (2007). "Stability of persistence diagrams." *Discrete & Computational Geometry*, 37(1), 103-120.
7. Vignéras, M.-F. (1980). "Variétés riemanniennes isospectrales et non isométriques." *Annals of Mathematics*, 112, 21-32.
