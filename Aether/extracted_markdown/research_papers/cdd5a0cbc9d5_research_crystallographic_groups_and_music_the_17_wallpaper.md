# Crystallographic Rhythm Theory: Algebraic Extensions of the Wallpaper–Rhythm Correspondence

## Abstract

We present three substantial extensions of the mathematical theory connecting periodic rhythm patterns to crystallographic symmetry groups. First, we establish the *crystallographic restriction theorem* in its totient form: for positive integers n, Euler's totient φ(n) ≤ 2 if and only if n ∈ {1, 2, 3, 4, 6}, providing the algebraic explanation for why only rotation orders 1, 2, 3, 4, 6 appear in wallpaper groups. The proof combines explicit computation for small cases with a general lower bound φ(n) ≥ 3 for n ≥ 7, established via multiplicative properties of the totient function. Second, we prove a *necklace counting theorem* for prime-length rhythms: the number of distinct binary necklaces of prime length p is (2^p + 2p − 2)/p, with integrality guaranteed by Fermat's little theorem. We further establish the lower bound N(p) ≥ p + 1 for p ≥ 3, demonstrating super-linear growth of rhythmic vocabulary. Third, we generalize the *double-mirror-implies-rotation theorem* to abstract group theory, proving that commuting involutions compose to involutions and that the commutator of two involutions equals the square of their product. All results are fully formalized and machine-verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Background

Periodic patterns and their symmetry groups have been studied in crystallography since the work of Fedorov (1891) and Schoenflies (1891), who independently classified the 17 wallpaper groups — the complete list of symmetry groups for doubly-periodic patterns in the Euclidean plane. The classification relies on the *crystallographic restriction*: the only possible rotation orders in a 2D lattice symmetry are 1, 2, 3, 4, and 6.

The connection to music theory arises from the observation that periodic rhythms are one-dimensional periodic patterns, and that two-dimensional "drum patterns" — functions g: ℤ × ℤ → {0,1} — are doubly-periodic patterns whose symmetry groups are wallpaper groups. This observation, explored in [1], establishes a correspondence between the 17 wallpaper group types and 17 fundamentally different types of rhythmic structure.

### 1.2 Contributions

We extend the existing formalized theory (building on `double_mirror_implies_rotation` from Catalog/Tropical/WallpaperRhythm.lean) in three directions:

1. **Crystallographic Restriction via Totient** (§3): We prove that φ(n) ≤ 2 ↔ n ∈ {1,2,3,4,6} for n ≥ 1, providing the number-theoretic foundation for the crystallographic restriction.

2. **Necklace Counting** (§4): We prove that the number of distinct binary necklaces of prime length p is (2^p + 2p − 2)/p, and establish the lower bound N(p) ≥ p + 1 for p ≥ 3.

3. **Involution Product Structure** (§5): We generalize the double-mirror theorem to abstract group theory, proving three structural results about products and commutators of involutions.

### 1.3 Formalization

All results are formalized in Lean 4 using Mathlib. The formalization comprises approximately 320 lines of verified Lean code with zero `sorry` statements. The key dependencies are Mathlib's `Nat.totient`, `ZMod`, and `Finset` libraries.

## 2. Definitions

**Definition 2.1** (Crystallographic Orders). The set of *crystallographic orders* is {1, 2, 3, 4, 6} ⊂ ℕ.

**Definition 2.2** (Finite Rhythm). A *finite rhythm of length n* is a function f: Fin n → Bool. The *onset set* is {i : f(i) = true}.

**Definition 2.3** (k-fold Symmetry). A rhythm f of length n has *k-fold rotational symmetry* (where k | n) if f(i) = f((i + n/k) mod n) for all i.

**Definition 2.4** (Necklace Count). For positive n, the necklace count N(n) = (2^n + 2n − 2) / n. (This equals the Burnside formula for the case of prime n.)

**Definition 2.5** (Involution). An element g of a group G is an *involution* if g² = 1.

**Definition 2.6** (Wallpaper Type). An inductive type with 17 constructors: p1, p2, pm, pg, cm, pmm, pmg, pgg, cmm, p4, p4m, p4g, p3, p3m1, p31m, p6, p6m.

**Definition 2.7** (Onset Count). For a rhythm f of length n, the onset count is |{i ∈ Fin n : f(i) = true}|.

## 3. Crystallographic Restriction via Euler's Totient

### 3.1 The Totient Lower Bound

**Theorem 3.1** (Totient Lower Bound). *For n ≥ 7, φ(n) ≥ 3.*

*Proof sketch.* If φ(n) ≤ 2 and n ≥ 7, then n can only have prime factors 2 and 3 (since any prime factor p ≥ 5 contributes φ(p) = p − 1 ≥ 4 to the totient by multiplicativity). The numbers of the form 2^a · 3^b with a, b ≥ 0 that exceed 6 are {8, 9, 12, 16, 18, ...}, and one verifies φ(8) = 4, φ(9) = 6, etc. — all exceed 2. □

### 3.2 The Main Theorem

**Theorem 3.2** (Crystallographic Restriction, Totient Form). *For n ≥ 1, φ(n) ≤ 2 if and only if n ∈ {1, 2, 3, 4, 6}.*

*Proof.* (⇐) Direct computation: φ(1) = 1, φ(2) = 1, φ(3) = 2, φ(4) = 2, φ(6) = 2. (⇒) For n ≤ 6, check each case: φ(5) = 4 > 2 eliminates n = 5; the others are in the set. For n ≥ 7, Theorem 3.1 gives φ(n) ≥ 3 > 2, contradiction. □

### 3.3 Connection to Crystallography

The connection to lattice symmetry is classical: a rotation by angle θ preserving the integer lattice ℤ² corresponds to a 2×2 integer matrix M with det(M) = 1 and characteristic polynomial t² − tr(M)·t + 1. The eigenvalues are e^{±iθ}, so tr(M) = 2cos(θ) ∈ ℤ with |tr(M)| ≤ 2. For a rotation of order n, the minimal polynomial of a primitive nth root of unity must divide the characteristic polynomial, which has degree 2. Since this minimal polynomial is the nth cyclotomic polynomial of degree φ(n), we need φ(n) ≤ 2. Theorem 3.2 then gives n ∈ {1, 2, 3, 4, 6}.

### 3.4 PEGB Analysis

- **P**roof: Complete Lean 4 proof via case analysis (n ≤ 6) and totient lower bound (n ≥ 7).
- **E**xample: n = 5 is excluded because φ(5) = 4 > 2. This explains why pentagons cannot tile the plane.
- **G**eneralization: The same argument extends to higher dimensions. In 3D, the crystallographic restriction allows orders {1, 2, 3, 4, 6} (same set). In 4D, the allowed orders are {1, 2, 3, 4, 5, 6, 8, 10, 12} — the condition becomes φ(n) ≤ 4 since the matrix is 4×4.
- **B**oundary: The theorem breaks for *quasicrystals*, which have non-periodic long-range order and can exhibit 5-fold, 8-fold, 10-fold, and 12-fold symmetry. The key assumption is exact translational periodicity.

## 4. Necklace Counting for Prime-Length Rhythms

### 4.1 Divisibility by Fermat's Little Theorem

**Theorem 4.1** (Necklace Numerator Divisibility). *For prime p, p | (2^p + 2p − 2).*

*Proof sketch.* By Fermat's little theorem, 2^p ≡ 2 (mod p). Thus 2^p + 2p − 2 ≡ 2 + 0 − 2 = 0 (mod p). The formal proof works in ZMod p, casting the statement as a congruence and applying Fermat's theorem via Mathlib's `ZMod.pow_card`. □

### 4.2 Lower Bound on Rhythmic Vocabulary

**Theorem 4.2** (Necklace Count Lower Bound). *For prime p ≥ 3, N(p) ≥ p + 1.*

*Proof sketch.* The inequality N(p) = (2^p + 2p − 2)/p ≥ p + 1 is equivalent to 2^p + 2p − 2 ≥ p(p+1) = p² + p, i.e., 2^p ≥ p² − p + 2. For p = 3, we have 8 ≥ 8 (equality). For p ≥ 5, we proceed by induction: if 2^p ≥ p² − p + 2, then 2^{p+1} = 2 · 2^p ≥ 2(p² − p + 2) = 2p² − 2p + 4. We need 2p² − 2p + 4 ≥ (p+1)² − (p+1) + 2 = p² + p, which simplifies to p² − 3p + 4 ≥ 0, true for all p ≥ 0. □

### 4.3 Computed Values

| p | N(p) | Musical interpretation |
|---|------|-----------------------|
| 2 | 3    | {silence, single hit, double hit} |
| 3 | 4    | {∅, clave-1, clave-2, full} |
| 5 | 8    | Pentatonic-like rhythmic variety |
| 7 | 20   | Rich rhythmic vocabulary in 7/8 |

### 4.4 PEGB Analysis

- **P**roof: Lean 4 proof using ZMod arithmetic and Nat.div_le_iff.
- **E**xample: For p = 7, there are exactly 20 distinct binary necklaces, verified computationally.
- **G**eneralization: For non-prime n, the full Burnside formula is N(n) = (1/n) Σ_{d|n} φ(n/d) · 2^d. The prime case is special because only two terms survive.
- **B**oundary: The formula counts binary necklaces. For ternary or k-ary necklaces (e.g., rhythms with rests, accents, and ghost notes), the formula generalizes to (1/n) Σ_{d|n} φ(n/d) · k^d.

## 5. Involution Product Structure

### 5.1 Results

Building on `double_mirror_implies_rotation` from the Catalog, we prove three results about involutions in abstract groups.

**Theorem 5.1** (Commuting Involution Product). *If σ, τ are commuting involutions in a group G (i.e., σ² = τ² = 1 and στ = τσ), then στ is an involution: (στ)² = 1.*

**Theorem 5.2** (Equal Involution Product). *If σ is an involution and σ = τ, then στ = 1.*

**Theorem 5.3** (Involution Commutator). *If σ, τ are involutions, then the commutator [σ,τ] = σ⁻¹τ⁻¹στ equals (στ)².*

### 5.2 Musical Interpretation

Theorem 5.1 explains why a drum pattern with both time-mirror (palindrome) and pitch-mirror symmetry automatically has 2-fold rotational symmetry: the time and pitch reflections commute (they act on orthogonal directions), and their product — a half-turn — is also an involution.

Theorem 5.3 reveals the deeper structure: the commutator of two reflections, which measures "how far they are from commuting," equals the square of their product rotation. When the reflections commute, the commutator is trivial and the product is an involution. When they do not commute, the product has higher order, and the commutator reveals the rotation angle.

### 5.3 PEGB Analysis

- **P**roof: Clean group-theoretic proofs using `mul_assoc` and involution identities.
- **E**xample: In the dihedral group D_4, two reflections across perpendicular axes compose to a 90° rotation.
- **G**eneralization: For general (non-commuting) involutions, the order of στ determines the "angle" between them. If ord(στ) = n, the group generated by σ and τ is the dihedral group D_n.
- **B**oundary: The theorem about commuting involutions requires commutativity. For non-commuting involutions, the product στ can have arbitrary finite or infinite order.

## 6. Additional Results

### 6.1 Wallpaper Type Distribution

We establish the complete distribution of the 17 wallpaper types across crystallographic orders:
- Order 1: 4 types (p1, pm, pg, cm)
- Order 2: 5 types (p2, pmm, pmg, pgg, cmm)
- Order 3: 3 types (p3, p3m1, p31m)
- Order 4: 3 types (p4, p4m, p4g)
- Order 6: 2 types (p6, p6m)

The sum 4 + 5 + 3 + 3 + 2 = 17 is verified. Non-crystallographic orders (e.g., 5) have zero wallpaper types.

### 6.2 Symmetry Determines Rhythm

**Theorem 6.1** (k-fold Symmetry Determination). *If two rhythms of length n both have k-fold rotational symmetry (k | n) and agree on their first n/k positions, they are identical.*

This formalizes the information-theoretic content of symmetry: a rhythm with k-fold symmetry carries only n/k bits of information instead of n bits.

### 6.3 Complementary Rhythm Theorem

**Theorem 6.2** (Onset Complement). *For any rhythm f of length n, the onset count of f plus the onset count of its complement equals n: |f| + |¬f| = n.*

## 7. Discussion

### 7.1 Bridge to Number Theory

The most surprising result of this work is the direct connection between music theory and number theory via the crystallographic restriction. The fact that rhythmic symmetry types are constrained by Euler's totient function — a purely arithmetic quantity — reveals that the limitations on musical pattern are not aesthetic or cultural but algebraic.

### 7.2 Information Content of Rhythm

The necklace counting result and the symmetry determination theorem together paint a quantitative picture of rhythmic information. A rhythm of prime length p has N(p) = Θ(2^p/p) distinct forms, but imposing k-fold symmetry reduces the information content to n/k bits. This trade-off between variety and structure is central to musical aesthetics: too much symmetry produces monotony, too little produces chaos.

### 7.3 Catalog Integration

This work builds directly on:
- `double_mirror_implies_rotation` (Catalog/Tropical/WallpaperRhythm.lean): generalized from drum patterns to abstract involutions.
- `crystallographic_restriction` (Catalog/Tropical/WallpaperRhythm.lean): deepened from a case-check on the wallpaper enumeration to a number-theoretic characterization via Euler's totient.
- `wallpaper_type_card` (Catalog/Tropical/WallpaperRhythm.lean): extended with complete distribution analysis across rotation orders.

## 8. Future Work

1. **Higher-Dimensional Crystallographic Restriction**: Characterize {n : φ(n) ≤ d} for d > 2, corresponding to the allowed rotation orders in d-dimensional crystallography.

2. **Full Burnside Formula**: Formalize the necklace counting formula for composite n using Burnside's lemma and the Möbius function.

3. **Rhythmic Entropy**: Define and formalize a Shannon entropy measure for rhythms and prove that k-fold symmetry reduces entropy by log₂(k) bits.

4. **Dihedral Group Classification**: Formalize the theorem that the group generated by two involutions σ, τ with ord(στ) = n is isomorphic to the dihedral group D_n.

## References

[1] G. Toussaint, "The Geometry of Musical Rhythm: What Makes a 'Good' Rhythm Good?" Springer, 2013.

[2] E.S. Fedorov, "Symmetry of regular systems of figures" (Симметрия правильных систем фигур), Proc. St. Petersburg Mineral. Soc., 1891.

[3] W. Burnside, "On the Theory of Groups of Finite Order," Proc. London Math. Soc., 1897.

[4] Catalog/Tropical/WallpaperRhythm.lean — Formalized wallpaper-rhythm correspondence including `double_mirror_implies_rotation`, `crystallographic_restriction`, and `wallpaper_type_card`.
