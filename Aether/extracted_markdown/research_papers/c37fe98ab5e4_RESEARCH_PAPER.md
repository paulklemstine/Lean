# Formalized Density Heuristics for Sums of Three Cubes: Local Factors, Euler Products, and Singular Series

## Abstract

We develop a formally verified framework connecting local admissibility for the Diophantine equation x³ + y³ + z³ = k to quantitative density heuristics in the style of the Hardy–Littlewood circle method. Starting from the existing catalog of local obstruction theorems, we introduce the local density δ_k(n) — the normalized count of residue solutions modulo n — and prove three structural theorems: (1) global representability implies positive local density at every modulus, (2) local densities are multiplicative over coprime moduli via the Chinese Remainder Theorem, and (3) the truncated singular series (product of local densities at primes) is positive whenever k is globally representable. We additionally establish a probability bridge theorem relating local density to the uniform probability of solving the cubic congruence, and provide verified computational algorithms for all quantities. All theorems are machine-checked with complete proofs and no unverified assumptions.

## 1. Introduction

### 1.1 The Three-Cubes Problem

The equation x³ + y³ + z³ = k, where k is a fixed integer and x, y, z range over all integers, is one of the most classical Diophantine problems. Despite its simple appearance, the equation exhibits remarkably complex behavior:

- Some values of k (those congruent to 4 or 5 modulo 9) admit no representations at all.
- Among admissible k, the representations can involve extremely large coordinates (e.g., k = 33 requires 16-digit numbers).
- The Hardy–Littlewood circle method predicts that the number of representations R_k(N) = #{(x,y,z) ∈ ℤ³ : |x|,|y|,|z| ≤ N, x³+y³+z³ = k} should grow as c_k · N^{1/3} for a positive constant c_k.

### 1.2 Prior Work in the Catalog

The existing formal development contains:
- `SumThreeCubesRep k` — the predicate that k is representable as a sum of three cubes
- `ThreeCubeLocalAdmissible n a` — local admissibility of residue a modulo n
- `EverywhereLocallyAdmissible k` — everywhere local admissibility
- `sumThreeCubesRep_implies_everywhereLocallyAdmissible` — the global-to-local implication
- `not_threeCubeLocalAdmissible_mod9_four/five` — the mod-9 obstruction

### 1.3 Contributions

We introduce four new definitions and prove five main theorems that transform the qualitative local admissibility framework into a quantitative density theory:

1. **Local density** δ_k(n) = #{solutions mod n} / n² — the natural normalization for singular series factors.
2. **Uniform probability** Pr_k(n) = #{solutions} / n³ — connecting to probability theory.
3. **Truncated singular series** 𝔖_P(k) = ∏_{p∈P} δ_k(p) — the Euler product proxy.
4. **Positivity, multiplicativity, and probability bridge** theorems with complete machine-checked proofs.

## 2. Definitions and Notation

### 2.1 Local Solution Set

For k ∈ ℤ and n ∈ ℕ with n ≥ 1, define the local solution set:

```
threeCubeResidueSet(k, n) = {(a, b, c) ∈ (ℤ/nℤ)³ : a³ + b³ + c³ = k̄}
```

where k̄ denotes the image of k in ℤ/nℤ. This is a finite set, computable by exhaustive enumeration.

### 2.2 Local Density

The local density is the normalized cardinality:

```
δ_k(n) = |threeCubeResidueSet(k, n)| / n²
```

The normalization by n² (rather than n³) reflects the codimension-one nature of the cubic constraint: in three variables with one equation, the expected solution count scales as n^{3-1} = n².

### 2.3 Uniform Probability

The uniform probability is:

```
Pr_k(n) = |threeCubeResidueSet(k, n)| / n³
```

This is the probability that three independent uniform random elements of ℤ/nℤ satisfy the cubic congruence.

### 2.4 Truncated Singular Series

For a finite set P of primes, the truncated singular series is:

```
𝔖_P(k) = ∏_{p ∈ P} δ_k(p)
```

This is a finite approximation to the full singular series of the Hardy–Littlewood circle method.

## 3. Main Results

### 3.1 Theorem 1: Global Representation Implies Local Density Positivity

**Statement.** If there exist x, y, z ∈ ℤ with x³ + y³ + z³ = k, then for every n ≥ 1, δ_k(n) > 0.

```lean
theorem threeCubeRep_implies_localDensity_pos (k : ℤ)
    (hrep : ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k)
    (n : ℕ) [NeZero n] :
    0 < threeCubeLocalDensity k n
```

**Proof sketch.** A global solution (x, y, z) reduces modulo n to give a local solution (x̄, ȳ, z̄) ∈ (ℤ/nℤ)³, showing the residue set is nonempty. Since the cardinality of a nonempty finite set is positive, and n² > 0, the density δ_k(n) = |S| / n² is positive.

**Significance.** This upgrades the catalog's `sumThreeCubesRep_implies_everywhereLocallyAdmissible` from a Boolean (exists/not exists) statement to a quantitative positivity result, which is precisely what's needed for singular series theory.

### 3.2 Theorem 2: Multiplicativity via CRT

**Statement.** If gcd(m, n) = 1, then:

```
|threeCubeResidueSet(k, mn)| = |threeCubeResidueSet(k, m)| · |threeCubeResidueSet(k, n)|
```

and consequently:

```
δ_k(mn) = δ_k(m) · δ_k(n)
```

```lean
theorem threeCubeResidueCount_mul_of_coprime (k : ℤ) {m n : ℕ}
    [NeZero m] [NeZero n] (hcop : Nat.Coprime m n) :
    threeCubeResidueCount k (m * n) =
      threeCubeResidueCount k m * threeCubeResidueCount k n
```

**Proof sketch.** The Chinese Remainder Theorem provides a ring isomorphism φ : ℤ/mnℤ → ℤ/mℤ × ℤ/nℤ. Since φ is a ring homomorphism, it preserves cubes and sums: φ(a³ + b³ + c³) = (φ(a)³ + φ(b)³ + φ(c)³) in the product ring. Moreover, φ(k̄) = (k̄_m, k̄_n). Therefore φ induces a bijection between solution triples modulo mn and pairs of solution triples modulo m and n. The cardinality equality follows from the product formula for Cartesian products of finite sets.

**Significance.** Multiplicativity is the structural backbone of Euler products. It means the local density at any squarefree modulus factors completely into contributions from individual primes, justifying the singular series decomposition.

### 3.3 Theorem 3: Positivity of Truncated Singular Series

**Statement.** If k is representable as a sum of three cubes, then for any finite set P of primes, 𝔖_P(k) > 0.

```lean
theorem truncatedSingularSeries_pos_of_rep (k : ℤ)
    (hrep : ∃ x y z : ℤ, x ^ 3 + y ^ 3 + z ^ 3 = k)
    (P : Finset ℕ) (hP : ∀ p ∈ P, Nat.Prime p) :
    0 < truncatedSingularSeries k P
```

**Proof sketch.** Each factor δ_k(p) in the product is positive by Theorem 1 (since p is prime, hence ≥ 1). A finite product of positive rationals is positive.

**Significance.** This is the first formally verified statement that the local-global infrastructure produces positive Euler factors for the asymptotic prediction. It ensures that the singular series, to the extent it converges, predicts a positive asymptotic constant — consistent with infinitely many representations.

### 3.4 Theorem 5: Probability Bridge

**Statement.** δ_k(n) = n · Pr_k(n), where Pr_k(n) is the uniform probability.

```lean
theorem threeCubeLocalDensity_eq_n_mul_prob (k : ℤ) (n : ℕ) [NeZero n] :
    threeCubeLocalDensity k n = (n : ℚ) * uniformThreeCubeProb k n
```

**Proof sketch.** Direct algebraic manipulation: δ_k(n) = count/n² = n · (count/n³) = n · Pr_k(n).

**Significance.** This creates a bridge between analytic number theory and probability. The singular series becomes a product of rescaled local probabilities, making "independence of local constraints at different primes" a precise, testable mathematical statement.

### 3.5 Catalog Bridge Theorems

We also prove bidirectional equivalences connecting the new density framework to the catalog's admissibility predicates:

```lean
theorem threeCubeResidueSet_nonempty_iff_localAdmissible (k : ℤ) (n : ℕ) [NeZero n] :
    (threeCubeResidueSet k n).Nonempty ↔ ThreeCubeLocalAdmissible n (k : ZMod n)

theorem threeCubeLocalDensity_pos_iff_localAdmissible (k : ℤ) (n : ℕ) [NeZero n] :
    0 < threeCubeLocalDensity k n ↔ ThreeCubeLocalAdmissible n (k : ZMod n)
```

## 4. Algorithms

### 4.1 Residue Count Algorithm

**Input:** Integer k, positive integer n.
**Output:** #{(a,b,c) ∈ {0,...,n-1}³ : a³+b³+c³ ≡ k (mod n)}.

```
function THREE_CUBE_RESIDUE_COUNT(k, n):
    count ← 0
    k_mod ← k mod n
    for a in 0..n-1:
        a3 ← a³ mod n
        for b in 0..n-1:
            ab3 ← (a3 + b³ mod n) mod n
            for c in 0..n-1:
                if (ab3 + c³ mod n) mod n = k_mod:
                    count ← count + 1
    return count
```

**Complexity:** O(n³) time, O(1) space.

For large primes, an optimized O(n²) algorithm precomputes cube tables:

```
function THREE_CUBE_RESIDUE_COUNT_FAST(k, n):
    cube_count ← array of size n, initialized to 0
    for x in 0..n-1:
        cube_count[x³ mod n] += 1
    count ← 0
    for a in 0..n-1:
        for b in 0..n-1:
            target ← (k - a³ - b³) mod n
            count += cube_count[target]
    return count
```

**Complexity:** O(n²) time, O(n) space.

### 4.2 Truncated Singular Series

**Input:** Integer k, prime bound P.
**Output:** ∏_{p ≤ P, p prime} δ_k(p).

```
function TRUNCATED_SINGULAR_SERIES(k, P):
    primes ← SIEVE(P)
    product ← 1.0
    for p in primes:
        product ← product × THREE_CUBE_RESIDUE_COUNT(k, p) / p²
    return product
```

**Complexity:** O(∑_{p≤P} p³) ≈ O(P⁴/ln P) using the naive count; O(P³/ln P) with the fast count.

## 5. Computational Experiments

### 5.1 Local Densities at p = 9

| k mod 9 | Count | δ_k(9) | Status |
|---------|-------|--------|--------|
| 0 | 189 | 2.3333 | Admissible |
| 1 | 162 | 2.0000 | Admissible |
| 2 | 81 | 1.0000 | Admissible |
| 3 | 27 | 0.3333 | Admissible |
| 4 | 0 | 0.0000 | **Obstructed** |
| 5 | 0 | 0.0000 | **Obstructed** |
| 6 | 27 | 0.3333 | Admissible |
| 7 | 81 | 1.0000 | Admissible |
| 8 | 162 | 2.0000 | Admissible |

### 5.2 Multiplicativity Verification

| k | m | n | count(mn) | count(m)·count(n) | Match |
|---|---|---|-----------|-------------------|-------|
| 0 | 4 | 9 | 3780 | 3780 | ✓ |
| 1 | 4 | 9 | 2592 | 2592 | ✓ |
| 2 | 5 | 7 | 675 | 675 | ✓ |
| 3 | 8 | 9 | 1728 | 1728 | ✓ |

### 5.3 Truncated Singular Series

| k | P ≤ 5 | P ≤ 7 | P ≤ 11 | P ≤ 13 |
|---|-------|-------|--------|--------|
| 0 | 1.000 | 1.122 | 1.122 | 0.724 |
| 1 | 1.000 | 1.837 | 1.837 | 2.739 |
| 2 | 1.000 | 0.551 | 0.551 | 0.440 |
| 3 | 1.000 | 0.551 | 0.551 | 0.440 |
| 6 | 1.000 | 1.837 | 1.837 | 1.467 |
| 7 | 1.000 | 1.122 | 1.122 | 0.897 |
| 8 | 1.000 | 1.837 | 1.837 | 2.739 |
| 9 | 1.000 | 0.551 | 0.551 | 0.440 |

The variation in singular series values across admissible k reflects the nonuniform distribution of representations predicted by the circle method.

## 6. Discussion

### 6.1 Relationship to the Full Circle Method

The definitions and theorems established here formalize the "arithmetic side" of the Hardy–Littlewood circle method for the cubic form. The full asymptotic R_k(N) ~ c_k · N^{1/3} requires additionally:

1. The **singular integral** J(k), encoding the real-analytic contribution.
2. The **minor arc estimates**, bounding the contribution of non-major-arc exponential sums.
3. **Convergence** of the infinite singular series ∏_p δ_k(p).

Our truncated singular series provides a certified lower bound framework: by Theorem 3, every finite truncation is positive for representable k. The full convergence would follow from showing that δ_k(p) → 1 sufficiently fast as p → ∞ (specifically, that |δ_k(p) - 1| = O(p^{-1-ε}) for some ε > 0).

### 6.2 Strengths and Limitations

**Strengths:**
- All theorems are fully machine-verified with no unproved assumptions.
- The multiplicativity proof handles the CRT bijection at the level of solution sets, not just counts.
- The framework connects directly to the catalog's existing infrastructure.

**Limitations:**
- We work with squarefree densities (at individual primes) rather than prime-power densities. The full singular series requires p-adic limits.
- The computational algorithms have polynomial but non-trivial complexity.
- We do not prove convergence of the infinite product.

### 6.3 Cross-Domain Connections

1. **Number Theory ↔ Probability:** The probability bridge theorem (Theorem 5) makes the "independence of local constraints" principle precise.
2. **Algebra ↔ Analysis:** The CRT multiplicativity (Theorem 2) is the algebraic fact underlying the analytic Euler product.
3. **Computation ↔ Theory:** The verified algorithms make the singular series a testable prediction, not just a theoretical construct.

## 7. Future Work

1. **Prime-power densities and p-adic limits:** Extend to δ_k(p^m) and prove stabilization as m → ∞.
2. **Convergence of the infinite product:** Show |δ_k(p) - 1| = O(p^{-3/2}) for p ≥ 5.
3. **Singular integral computation:** Formalize the real-analytic factor J(k).
4. **Finite Fourier expansion:** Express the local count as an exponential sum character formula.
5. **Extension to other Diophantine problems:** Apply the framework to Waring's problem and other additive equations.

## 8. References

1. G. H. Hardy and J. E. Littlewood, "Some problems of 'Partitio Numerorum' (VI): Further researches in Waring's problem," Math. Z. 23 (1925), 1–37.
2. H. Davenport, *Analytic Methods for Diophantine Equations and Diophantine Inequalities*, Cambridge University Press, 2005.
3. A. R. Booker, "Cracking the problem with 33," Research in Number Theory 5 (2019).
4. A. R. Booker and A. V. Sutherland, "On a question of Mordell," Proceedings of the National Academy of Sciences 118 (2021).
5. R. C. Vaughan, *The Hardy-Littlewood Method*, 2nd ed., Cambridge Tracts in Mathematics 125, 1997.
