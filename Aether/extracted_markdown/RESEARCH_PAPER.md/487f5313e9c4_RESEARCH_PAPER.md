# The Digit Factorization Spectrum: Algebraic Structure of Vampire Numbers and Arithmetic Creatures

## Abstract

We introduce the *Digit Factorization Profile*, a novel algebraic structure that captures the complete relationship between a natural number's decimal digit representation and the digit representations of its multiplicative factors. This framework provides a unified treatment of vampire numbers (perfect digit rearrangement), ghost numbers (complete digit disjointness), werewolf numbers (single-digit overlap), and intermediate cases as points on a continuous *digit overlap spectrum*.

Our main results are:

1. **Fang Mod-3 Elimination Theorem**: For any vampire factorization v = x × y with matching digit multisets, neither x nor y can be congruent to 1 modulo 3. This eliminates one-third of all residue classes from consideration.

2. **Excess-Deficit Duality Theorem**: For balanced factorizations (equal total digit counts between product and factors), the number of excess digits always equals the number of deficit digits. This reveals a fundamental symmetry in the digit overlap spectrum.

3. **Ghost Digit Exclusion Theorem**: Every ghost number must be missing at least one nonzero digit from {1,...,9} in its decimal representation. This structural constraint limits the growth of ghost numbers.

4. **Fang Residue Classification**: The valid (x mod 9, y mod 9) pairs for vampire fangs form exactly 6 pairs, corresponding to the units of (ℤ/9ℤ)× under the shifted-inverse map. This yields a density bound of 2/27 ≈ 7.4%.

5. **Vampiric ⟹ Balanced**: Vampiric profiles (perfect digit multiset match) are automatically balanced (equal digit counts), with zero excess and zero deficit.

All results have been formally verified in Lean 4 with Mathlib.

## 1. Introduction

### 1.1 Background

A *vampire number* is a composite natural number v with 2n digits that can be expressed as v = x × y where x and y (called *fangs*) each have n digits, and the multiset of decimal digits of v equals the multiset union of the digits of x and y. The concept was introduced by Pickover (1995) and has been studied primarily from a computational and recreational perspective.

The smallest vampire number is 1260 = 21 × 60: the digits {1, 2, 6, 0} of 1260 are exactly the combined digits {2, 1} ∪ {6, 0} of its fangs. There are exactly 7 four-digit vampire numbers: 1260, 1395, 1435, 1530, 1827, 2187, and 6880.

### 1.2 Contributions

We move beyond the recreational treatment to establish a rigorous algebraic framework. Our key innovation is the *Digit Factorization Profile* — a structure that records not just whether a factorization is "vampiric" but the full spectrum of digit overlap behavior. This enables unified theorems about the entire arithmetic bestiary.

### 1.3 Organization

Section 2 defines the core objects. Section 3 presents the main theorems with proof sketches. Section 4 discusses the fang residue classification. Section 5 presents computational results. Section 6 discusses open problems and future directions.

## 2. Definitions

### 2.1 Digit Multisets

For a natural number n, the *digit multiset* dm(n) is the multiset of decimal digits of n. For example, dm(1260) = {0, 1, 2, 6} and dm(21) = {1, 2}.

The *digit sum* ds(n) is the sum of all elements of dm(n). By the classical "casting out nines" result, n ≡ ds(n) (mod 9) for all n.

### 2.2 The Digit Factorization Profile

**Definition 2.1.** A *Digit Factorization Profile* is a tuple P = (v, x, y) where v = x × y, x > 1, and y > 1. The *fang digit multiset* is fd(P) = dm(x) + dm(y) (multiset union).

**Definition 2.2.** A profile P is:
- *Balanced* if |dm(v)| = |fd(P)| (equal total digit counts)
- *Vampiric* if dm(v) = fd(P) (perfect multiset match)
- *Ghostly* if dm(v).toFinset ∩ dm(x).toFinset = ∅ and dm(v).toFinset ∩ dm(y).toFinset = ∅

**Definition 2.3.** The *digit excess* of P is |fd(P) \ dm(v)| and the *digit deficit* is |dm(v) \ fd(P)|, where \ denotes multiset difference.

### 2.3 The Creature Classification

Factorizations can be classified along the digit overlap spectrum:
- **Vampire**: excess = deficit = 0, perfect digit match
- **Werewolf**: exactly one digit of overlap (multiset intersection has cardinality 1)
- **Ghost**: zero digit overlap (at the set level)
- **Partial**: intermediate overlap

### 2.4 The Valid Fang Pairs

**Definition 2.4.** The set of *valid fang pairs* modulo 9 is:
V₉ = {(a, b) ∈ (ℤ/9ℤ)² : (a-1)(b-1) = 1}

## 3. Main Theorems

### 3.1 Theorem 1: Fang Mod-3 Elimination

**Theorem 3.1.** If x × y ≡ x + y (mod 9), then x ≢ 1 (mod 3).

*Proof sketch.* The hypothesis gives x × y − x − y ≡ 0 (mod 9), which factors as (x−1)(y−1) − 1 ≡ 0 (mod 9), hence (x−1)(y−1) ≡ 1 (mod 9). In particular, (x−1)(y−1) ≡ 1 (mod 3). If x ≡ 1 (mod 3), then 3 | (x−1), so 3 | (x−1)(y−1). But (x−1)(y−1) ≡ 1 (mod 3) means 3 ∤ (x−1)(y−1), a contradiction. □

**Corollary 3.2.** For any vampire number v = x × y with n-digit fangs, both x and y satisfy x, y ≢ 1 (mod 3).

*PEGB Analysis:*
- **P**roof: Formally verified in Lean 4 (see `fang_not_one_mod_three`)
- **E**xample: All 7 four-digit vampire numbers have fangs with remainder 0 or 2 mod 3
- **G**eneralization: In base b, the analogous constraint eliminates residue class 1 mod gcd(b−1, 3) from fang candidates
- **B**oundary: The constraint is tight — both residue classes 0 and 2 mod 3 do appear as fangs (e.g., 21 ≡ 0 and 35 ≡ 2)

### 3.2 Theorem 2: Excess-Deficit Duality

**Theorem 3.3.** For any two multisets A, B of equal cardinality, |A \ B| = |B \ A|.

*Proof sketch.* We have |A| = |A ∩ B| + |A \ B| and |B| = |A ∩ B| + |B \ A| (multiset decomposition). Since |A| = |B| and A ∩ B = B ∩ A, subtraction gives |A \ B| = |B \ A|. □

**Corollary 3.4.** For a balanced profile P, the digit excess equals the digit deficit.

*PEGB Analysis:*
- **P**roof: Formally verified (see `multiset_excess_eq_deficit`)
- **E**xample: 1000 = 25 × 40 has excess = deficit = 3 (digits {1,0,0,0} vs {2,5,4,0})
- **G**eneralization: The theorem holds for arbitrary multisets over any type, not just digit multisets
- **B**oundary: For unbalanced factorizations (different total digit counts), the equality fails. Example: 100 = 10 × 10, where dm(100) = {0,0,1} has 3 digits but dm(10) + dm(10) = {0,1,0,1} has 4 digits.

### 3.3 Theorem 3: Ghost Digit Exclusion

**Theorem 3.5.** If v is a ghost number, then there exists d ∈ {1,...,9} such that d does not appear among the digits of v.

*Proof sketch.* Since v = x × y with x > 1, x has at least one nonzero digit d (every positive integer has a nonzero most significant digit). By the ghost property, d ∉ dm(v).toFinset. Since d ≥ 1 and d < 10 (digits in base 10 are bounded by the base), we have our witness. □

*PEGB Analysis:*
- **P**roof: Formally verified (see `ghost_missing_nonzero_digit`)
- **E**xample: 6 = 2 × 3 is a ghost number missing digits {1,2,3,4,5,7,8,9}
- **G**eneralization: In base b, ghost numbers must be missing at least one nonzero digit from {1,...,b−1}
- **B**oundary: The bound is tight in the sense that ghost numbers *can* use all digits except one nonzero digit, but large ghost numbers become increasingly rare as they must avoid more and more digit values

### 3.4 Theorem 4: Fang Residue Classification

**Theorem 3.6.** |V₉| = 6. The valid pairs are: (0,0), (2,2), (3,6), (5,8), (6,3), (8,5).

*Proof.* The condition (a−1)(b−1) = 1 in ℤ/9ℤ requires a−1 to be a unit, i.e., gcd(a−1, 9) = 1. The units of ℤ/9ℤ are {1,2,4,5,7,8}, giving a ∈ {0,2,3,5,6,8} (mod 9). For each such a, b is uniquely determined as (a−1)⁻¹ + 1. □

**Corollary 3.7.** At most 6/81 = 2/27 of all residue class pairs (mod 9) can produce vampire factorizations.

*PEGB Analysis:*
- **P**roof: Verified by `native_decide` in Lean 4
- **E**xample: 1260 = 21 × 60 has 21 ≡ 3 (mod 9) and 60 ≡ 6 (mod 9), matching the pair (3,6) ∈ V₉
- **G**eneralization: In base b, the valid pairs are determined by the units of ℤ/(b−1)ℤ
- **B**oundary: The density 2/27 is a necessary but not sufficient condition. The actual vampire density is much lower due to the additional digit permutation constraint.

### 3.5 Theorem 5: Vampiric ⟹ Balanced

**Theorem 3.8.** If dm(v) = dm(x) + dm(y), then |dm(v)| = |dm(x)| + |dm(y)|.

**Theorem 3.9.** A vampiric profile has zero excess and zero deficit.

*Proof.* From dm(v) = fd(P), the multiset difference fd(P) \ dm(v) is empty (zero excess). Similarly dm(v) \ fd(P) is empty (zero deficit). □

## 4. The Group Structure of Fang Residues

The valid fang pairs V₉ have a natural algebraic interpretation. The map φ: (ℤ/9ℤ)× → (ℤ/9ℤ)² defined by φ(u) = (u + 1, u⁻¹ + 1) parameterizes V₉. This reveals that V₉ is in bijection with the group of units (ℤ/9ℤ)× ≅ ℤ/6ℤ.

The involution σ: (a,b) ↦ (b,a) on V₉ corresponds to the inverse map u ↦ u⁻¹ on (ℤ/9ℤ)×. The fixed points of σ in V₉ are (0,0) and (2,2), corresponding to the self-inverse units 8 ≡ −1 and 1 in ℤ/9ℤ.

## 5. Computational Results

### 5.1 Vampire Number Counts

| Digits | Count | Density |
|--------|-------|---------|
| 4 | 7 | 7.78 × 10⁻⁴ |
| 6 | 148 | 1.64 × 10⁻⁴ |
| 8 | ~3228 | ~3.59 × 10⁻⁵ |

The density appears to decrease roughly as c/n^α for some constants, consistent with heuristic predictions based on digit permutation counting.

### 5.2 Ghost Number Counts

We found 2,698 ghost numbers in [4, 10000]. Ghost numbers become progressively rarer as numbers grow, because larger numbers tend to use more distinct digits, leaving fewer "unused" digits available for factors.

### 5.3 Fang Mod-3 Verification

Among all 155 known vampire numbers with ≤ 6 digits, zero violations of the mod-3 elimination theorem were observed, computationally confirming the formal proof.

## 6. Open Problems and Conjectures

### 6.1 Vampire Density Conjecture

**Conjecture.** The number V(n) of vampire numbers with 2n digits satisfies V(n) ~ C · 4ⁿ / √(πn) for some constant C.

*Evidence:* Heuristically, for a 2n-digit number v, there are C(2n,n) ways to partition the digits into two n-digit groups, and the probability that a random partition gives a valid factorization is approximately (n!)² / 10^{2n} · (correction factors for the mod-9 constraint and leading zeros).

### 6.2 Ghost Density Conjecture

**Conjecture.** The density of ghost numbers in [1, N] approaches 0 as N → ∞.

*Evidence:* As numbers grow, they tend to use more distinct digits. A number with k distinct digits forces its ghost factors to use only 10−k digits. For k ≥ 9, no ghost factorization exists. Since "most" large numbers use many distinct digits, ghost numbers become rare.

### 6.3 Base Dependence

**Open Problem.** How does the valid fang pair count |V_b| depend on the base b? We have |V₁₀| = 6 (since 10−1 = 9 has φ(9) = 6 units). In general, |V_b| = φ(b−1), the Euler totient function.

## 7. References

1. C. Pickover, "Vampire Numbers," Chapter 30 in *Keys to Infinity*, Wiley, 1995.
2. OEIS A014575: Vampire numbers.
3. The Lean 4 formalization: `Catalog/Geometry/VampireSpectrum.lean`
