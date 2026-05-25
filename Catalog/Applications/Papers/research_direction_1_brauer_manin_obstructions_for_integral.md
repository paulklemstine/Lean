# Proto-Brauer–Manin Obstructions for Integral Points on the Cubic Surface x³ + y³ + z³ = k

## Abstract

We develop the first layer of a Brauer–Manin obstruction theory for the Diophantine equation x³ + y³ + z³ = k, viewed as the integer point problem on the affine cubic surface X_k. We introduce the *cubic obstruction profile* — the set of moduli at which the equation has no solution — and *proto-Brauer compatibility* — solvability modulo every positive integer. We prove five main theorems with machine-verified proofs: (1) global representability implies proto-Brauer compatibility; (2) the classical mod 9 obstruction propagates to the proto-Brauer level; (3) solvability descends along divisibility of moduli; (4) nonempty obstruction profiles certify the failure of any bounded search; and (5) the mod 9 obstruction persists through all 3-power moduli. These results create a formal bridge between explicit congruence obstructions, adelic compatibility, and computational search complexity, establishing the sums-of-three-cubes problem as a laboratory for formally verified arithmetic geometry.

**Keywords:** Brauer–Manin obstruction, integral points, cubic surfaces, sums of three cubes, local-global principle, adelic compatibility, obstruction profiles, certified algorithms

---

## 1. Introduction

### 1.1 Background

The Diophantine equation
$$x^3 + y^3 + z^3 = k$$
for integer k defines an affine cubic surface X_k ⊂ A³_ℤ. The question of which integers k admit integral representations has been studied since at least Mordell (1953) and remains largely open. The only known structural obstruction is the classical mod 9 result: since cubes modulo 9 take only the values {0, 1, 8}, the residues 4 and 5 modulo 9 are not representable.

Recent computational breakthroughs — including Booker's 2019 solution for k = 33 and Booker–Sutherland's solution for k = 42 — have renewed interest in the problem. However, the theoretical landscape remains sparse: beyond the mod 9 obstruction, no further structural obstructions are known for this family.

### 1.2 Motivation

In the theory of rational points on varieties, the Brauer–Manin obstruction provides a systematic framework for understanding failures of the Hasse principle. For integral points, Colliot-Thélène and Xu (2009) extended this framework, showing that Brauer–Manin obstructions can explain the absence of integral points on certain affine varieties.

Our goal is to create the first formal bridge between the explicit congruence obstructions for x³ + y³ + z³ = k and the conceptual framework of Brauer–Manin theory. We do not formalize full étale cohomology; instead, we introduce *finite-level shadows* of the adelic obstruction that are computable, formally verifiable, and mathematically meaningful.

### 1.3 Contributions

1. **New definitions:** The cubic obstruction profile and proto-Brauer compatibility, providing a structured language for congruence obstructions.
2. **Five verified theorems** establishing the basic theory of these objects.
3. **A verified obstruction checking algorithm** with correctness guarantees.
4. **A cross-domain connection** between obstruction theory and computational search complexity.
5. **A falsifiable conjecture** (Proto-Brauer Completeness) with computational test infrastructure.

---

## 2. Definitions and Notation

### 2.1 Core Definitions

**Definition 2.1** (Sum of Three Cubes Representability). An integer k is *representable* if there exist x, y, z ∈ ℤ with x³ + y³ + z³ = k.

**Definition 2.2** (Cubic Obstruction Profile). For k ∈ ℤ, the *cubic obstruction profile* is
$$\mathcal{O}(k) = \{m \in \mathbb{N} \mid \nexists\, x, y, z \in \mathbb{Z}/m\mathbb{Z} : x^3 + y^3 + z^3 \equiv k \pmod{m}\}.$$

**Definition 2.3** (Proto-Brauer Compatibility). An integer k is *proto-Brauer compatible* if for every positive integer m, the equation x³ + y³ + z³ ≡ k (mod m) has a solution. Equivalently, 𝒪(k) ∩ ℕ⁺ = ∅.

**Definition 2.4** (Bounded Three-Cube Search). For k ∈ ℤ and B ∈ ℕ, we write BoundedSearch(k, B) if there exist x, y, z ∈ ℤ with |x|, |y|, |z| ≤ B and x³ + y³ + z³ = k.

### 2.2 Relationship to Existing Infrastructure

Proto-Brauer compatibility is equivalent to the *everywhere local admissibility* defined in the existing catalog:

$$\text{ProtoBrauerCompatible}(k) \iff \text{EverywhereLocallyAdmissible}(k)$$

This equivalence is proved formally, establishing that our new definitions extend rather than duplicate the existing theory.

---

## 3. Main Results

### 3.1 Theorem 1: Global Implies Proto-Brauer Compatible

**Theorem 3.1.** If k is representable as a sum of three cubes, then k is proto-Brauer compatible.

*Proof sketch.* Let x, y, z ∈ ℤ with x³ + y³ + z³ = k. For any m ≠ 0, the images x̄, ȳ, z̄ ∈ ℤ/mℤ satisfy x̄³ + ȳ³ + z̄³ = k̄ by functoriality of the quotient map ℤ → ℤ/mℤ. □

This is the "easy direction" of any local-global principle. Its significance is conceptual: it upgrades the statement from "representable implies locally admissible at finitely many moduli" to "representable implies compatible across all finite quotients simultaneously," which is the correct precursor to adelic compatibility.

### 3.2 Theorem 2: The Mod 9 Obstruction at the Proto-Brauer Level

**Theorem 3.2.** If k ≡ 4 or 5 (mod 9), then k is not proto-Brauer compatible. Equivalently, 9 ∈ 𝒪(k).

*Proof sketch.* The cubes modulo 9 are {0, 1, 8}. An exhaustive check over all 9³ = 729 triples shows that x³ + y³ + z³ never equals 4 or 5 modulo 9. Since (k mod 9) ∈ {4, 5} implies (k : ℤ/9ℤ) ∈ {4, 5}, the equation has no solution modulo 9, so 9 ∈ 𝒪(k). Proto-Brauer compatibility requires solvability at all moduli, so it fails. □

The verification uses decidable finite enumeration, confirming the classical result with machine-checked certainty.

### 3.3 Theorem 3: Downward Closure

**Theorem 3.3.** If m | n and x³ + y³ + z³ ≡ k (mod n) has a solution, then x³ + y³ + z³ ≡ k (mod m) has a solution.

*Proof sketch.* The canonical ring homomorphism φ: ℤ/nℤ →+* ℤ/mℤ (given by ZMod.castHom when m | n) preserves addition and powers. Given (x, y, z) with x³ + y³ + z³ = k̄ in ℤ/nℤ, the triple (φ(x), φ(y), φ(z)) satisfies φ(x)³ + φ(y)³ + φ(z)³ = φ(k̄) = k̄' in ℤ/mℤ. □

**Corollary 3.4** (Upward Closure of Obstructions). If m ∈ 𝒪(k) and m | n, then n ∈ 𝒪(k).

This is the algebraic backbone of the obstruction theory. It means 𝒪(k) is closed under taking multiples — it is an upper set in the divisibility order. Equivalently, the complement (the set of "admissible" moduli) is downward closed.

### 3.4 Theorem 4: Obstruction Profiles as Search-Pruning Invariants

**Theorem 3.5.** If m ∈ 𝒪(k) for some m, then for every B ∈ ℕ, ¬BoundedSearch(k, B).

**Theorem 3.6.** If BoundedSearch(k, B), then 𝒪(k) = ∅.

*Proof sketch.* A bounded solution is in particular an integer solution. By Theorem 3.1, this implies proto-Brauer compatibility, meaning 𝒪(k) ∩ ℕ⁺ = ∅. For the m = 0 case, ZMod 0 = ℤ, so the obstruction at 0 would mean ¬∃ x y z : ℤ, x³+y³+z³ = k, directly contradicting the solution. □

**Cross-domain significance.** This creates an explicit bridge between arithmetic geometry and computational complexity. The obstruction profile is a *certified pruning oracle*: before investing O(B³) computation in a bounded search, one can check the obstruction profile in O(M · m²) time (where M is the modulus bound). If any obstruction is found, the search is provably futile.

### 3.5 Theorem 5: Prime-Power Persistence at p = 3

**Theorem 3.7.** If k ≡ 4 or 5 (mod 9), then for all e ≥ 2,
$$\nexists\, x, y, z \in \mathbb{Z}/3^e\mathbb{Z} : x^3 + y^3 + z^3 \equiv k \pmod{3^e}.$$

*Proof sketch.* Suppose for contradiction that a solution exists modulo 3^e. Since 9 = 3² divides 3^e (because e ≥ 2), by Theorem 3.3 (downward closure), a solution would also exist modulo 9. But Theorem 3.2 says 9 ∈ 𝒪(k), contradiction. □

**Significance.** This is a genuine *p*-adic result: the obstruction at the prime 3 is not a single-level phenomenon but persists through the entire 3-adic tower. In the language of arithmetic geometry, solvability fails over ℤ₃ (the 3-adic integers), not just over ℤ/9ℤ. This is exactly the local condition that enters the Brauer–Manin obstruction at the place p = 3.

---

## 4. Algorithms

### 4.1 Finite Obstruction Checker

**Algorithm 1: hasCubicSolutionMod(k, m)**

```
Input: k ∈ ℤ, m ∈ ℕ with m > 0
Output: true if ∃ x, y, z ∈ ℤ/mℤ : x³+y³+z³ ≡ k (mod m)

1. C ← {x³ mod m : x = 0, ..., m-1}     // cube residues
2. for c₁ ∈ C:
3.   for c₂ ∈ C:
4.     if (k - c₁ - c₂) mod m ∈ C:
5.       return true
6. return false
```

**Time complexity:** O(m + |C|²) where |C| ≤ m. In the worst case O(m²), but |C| is typically much smaller (approximately m/3 for large primes by cubic reciprocity estimates).

**Space complexity:** O(m) for storing the cube residue set.

### 4.2 Obstruction Profile Computation

**Algorithm 2: obstructionProfileUpTo(k, M)**

```
Input: k ∈ ℤ, M ∈ ℕ
Output: sorted list of m ∈ {1, ..., M} with m ∈ 𝒪(k)

1. profile ← []
2. for m = 1 to M:
3.   if not hasCubicSolutionMod(k, m):
4.     profile.append(m)
5. return profile
```

**Time complexity:** O(∑_{m=1}^{M} m²) = O(M³/3).

**Correctness:** Every listed modulus is a genuine obstruction, certified by the exhaustive check over ℤ/mℤ. By Theorem 3.5, if the output is nonempty, then k is not representable.

---

## 5. Computational Experiments

### 5.1 Obstruction Profiles for Selected Values

| k | k mod 9 | Profile (up to 100) | Status |
|---|---------|---------------------|--------|
| 4 | 4 | {9, 18, 27, 36, 45, 54, 63, 72, 81, 90, 99} | Obstructed |
| 5 | 5 | {9, 18, 27, 36, 45, 54, 63, 72, 81, 90, 99} | Obstructed |
| 33 | 6 | ∅ | Compatible |
| 42 | 6 | ∅ | Compatible |
| 114 | 6 | ∅ | Compatible |

**Observation:** For the tested range, the only obstructions arise from multiples of 9, confirming that the mod 9 obstruction is the dominant (and possibly only) finite congruence obstruction for this family.

### 5.2 3-adic Tower

For k = 4:
- mod 3: solvable (1³+1³+1³ = 3 ≡ 0, but 2³+1³+1³ = 10 ≡ 1 mod 3, need to check 4 mod 3 = 1: yes)
- mod 9: **obstructed**
- mod 27: **obstructed**
- mod 81: **obstructed**
- mod 243: **obstructed**
- mod 729: **obstructed**

The obstruction persists at all levels 3^e for e ≥ 2, consistent with Theorem 3.7.

### 5.3 Statistical Summary (k = 1 to 1000, M = 100)

- Mod 9 obstructed (k ≡ 4, 5 mod 9): 222 values (22.2%)
- Other obstructed: 0 values (0.0%)
- Congruence compatible: 778 values (77.8%)

The fraction 2/9 ≈ 22.2% of obstructed values matches the theoretical prediction exactly.

---

## 6. The Proto-Brauer Completeness Conjecture

**Conjecture 6.1** (Proto-Brauer Completeness). If k is proto-Brauer compatible (i.e., 𝒪(k) = ∅ in ℕ⁺), then k is representable as a sum of three cubes.

This is a finite-level shadow of the question whether the Brauer–Manin obstruction is the only obstruction for integral points on X_k. The full Brauer–Manin conjecture involves the Brauer group Br(X_k) and evaluation maps on adelic points; our conjecture replaces this with the computationally accessible condition of solvability modulo every m.

**Testable prediction.** Define PassesSearchAndCongruenceTests(k, B, M) to mean that k passes all congruence tests up to M but has no solution with coordinates bounded by B. If the conjecture is false, there should exist k and increasing B, M such that this condition persists. Our computational infrastructure provides the tools to search for such counterexamples.

---

## 7. Discussion

### 7.1 Relationship to Brauer–Manin Theory

Proto-Brauer compatibility is a deliberate finite approximation to the Brauer–Manin condition. In the full theory:

1. One defines the Brauer group Br(X_k) via Azumaya algebras or étale cohomology.
2. For each Brauer class α ∈ Br(X_k) and each place v (including archimedean), one evaluates α on local points.
3. The Brauer–Manin set X_k(𝔸_ℤ)^Br is the subset of adelic points where all evaluations sum to zero.
4. If X_k(𝔸_ℤ)^Br = ∅, there are no integral points.

Our obstruction profile captures step (3) at finite levels: solvability modulo m for all m is a necessary condition for lying in the Brauer–Manin set. The mod 9 obstruction should be viewed as the evaluation of a specific Brauer class at the place p = 3.

### 7.2 Cross-Domain Connections

**Arithmetic geometry ↔ Computational complexity.** Theorem 3.5 makes the connection explicit: obstruction profiles are certified pruning oracles for Diophantine search. This is the first formal bridge between the abstract theory of obstructions and the practical complexity of integer programming.

**Arithmetic geometry ↔ Probabilistic heuristics.** The Hardy–Littlewood circle method predicts that the number of representations of k by sums of three cubes up to bound B should grow as C(k) · B^ε for some constant C(k) depending on local densities. Our obstruction profile computes the "bad" local factors that make C(k) = 0 for obstructed k.

**Arithmetic geometry ↔ Certified algorithms.** The verified obstruction checker provides the first certified front-end for large-scale three-cubes search: one can rigorously prefilter candidates before committing computational resources.

### 7.3 Limitations

1. Our obstruction profile captures only congruence obstructions, not the full Brauer group.
2. The Chinese Remainder Theorem would allow factoring solvability over coprime moduli into solvability over prime powers, but this reduction is not yet formalized.
3. We do not address the archimedean (real) place, which contributes sign conditions.
4. The full Brauer–Manin machinery requires étale cohomology, which is not yet available in Mathlib.

---

## 8. Future Work

1. **CRT factorization.** Prove that solvability modulo mn (with gcd(m,n) = 1) is equivalent to solvability modulo m and modulo n separately. This would reduce the obstruction profile to prime power levels.

2. **Explicit Brauer classes.** Construct specific elements of Br(X_k) whose evaluation at p = 3 recovers the mod 9 obstruction.

3. **Archimedean conditions.** Incorporate the real place to obtain a complete adelic obstruction.

4. **Generalization.** Extend the framework to other Diophantine equations: x³ + y³ + z³ = k·w³ (projective version), norm equations, Markoff surfaces.

5. **Computational certification.** Develop a verified obstruction engine that can serve as a front-end for large-scale Diophantine search programs.

---

## References

1. Booker, A. R. (2019). Cracking the problem with 33. *Research in Number Theory*, 5(3), 26.

2. Booker, A. R., & Sutherland, A. V. (2021). On a question of Mordell. *Proceedings of the National Academy of Sciences*, 118(11).

3. Colliot-Thélène, J.-L., & Xu, F. (2009). Brauer–Manin obstruction for integral points of homogeneous spaces and representation by integral quadratic forms. *Compositio Mathematica*, 145(2), 309–363.

4. Heath-Brown, D. R., Lioen, W. M., & te Riele, H. J. J. (1993). On solving the Diophantine equation x³ + y³ + z³ = k on a vector computer. *Mathematics of Computation*, 61(203), 235–244.

5. Mordell, L. J. (1953). On the integer solutions of the equation x² + y² + z² + 2xyz = n. *Journal of the London Mathematical Society*, 28, 500–510.

6. Poonen, B. (2017). *Rational Points on Varieties*. Graduate Studies in Mathematics, vol. 186. American Mathematical Society.
