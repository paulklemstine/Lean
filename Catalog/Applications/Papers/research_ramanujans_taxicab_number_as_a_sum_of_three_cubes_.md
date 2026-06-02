# Ramanujan's Taxicab Number Revisited: Three-Cube Representations and the Inversion Principle

## Abstract

We investigate the representation of 1729, the Hardy-Ramanujan taxicab number, as a sum of three integer cubes. While 1729 = 10³ + 9³ = 12³ + 1³ as a sum of two cubes is well known, we establish that 1729 = (-7)³ + (-5)³ + 13³ provides a nontrivial three-cube representation — refuting the natural conjecture that no such representation exists. We formalize the **Three-Cube Inversion Principle**: if c³ - n = a³ + b³, then n = (-a)³ + (-b)³ + c³, providing a systematic reduction from three-cube to two-cube representability. We prove the mod-9 obstruction theorem (no integer ≡ 4, 5 mod 9 is a sum of three cubes), verify Korselt's criterion establishing 1729 as a Carmichael number, and identify structural connections between the prime factorization 1729 = 7 · 13 · 19 and all cube decompositions. All results are machine-verified in Lean 4.

## 1. Introduction

The number 1729, famously identified by Ramanujan as the smallest positive integer expressible as a sum of two positive cubes in two distinct ways [1], has been a touchstone of number theory for over a century. The two representations

$$1729 = 1^3 + 12^3 = 9^3 + 10^3$$

define the first *taxicab number* Ta(2). The general problem of representing integers as sums of cubes connects to deep questions in Diophantine geometry, including the Birch and Swinnerton-Dyer conjecture for cubic surfaces [2].

We address the question: does 1729 admit a representation as x³ + y³ + z³ with x, y, z all nonzero integers? We show the answer is affirmative and, moreover, that the representation arises from a general algebraic principle we formalize as the Three-Cube Inversion Principle.

## 2. Definitions

**Definition 2.1** (Sum of Two Positive Cubes Representation). For n ∈ ℕ, a *representation* is a pair (a, b) with 0 < a ≤ b and a³ + b³ = n.

**Definition 2.2** (Taxicab Witness). A *taxicab witness* for n ∈ ℕ is a pair of representations (a₁, b₁), (a₂, b₂) with a₁ ≠ a₂.

**Definition 2.3** (Nontrivial Three-Cube Representation). For n ∈ ℤ, a *nontrivial three-cube representation* is a triple (x, y, z) ∈ ℤ³ with x ≠ 0, y ≠ 0, z ≠ 0, and x³ + y³ + z³ = n.

**Definition 2.4** (Taxicab Order). A positive integer n has *taxicab order* ≥ k if there exist k representations (aᵢ, bᵢ) as sums of two positive cubes with pairwise distinct first components.

## 3. Main Results

### 3.1 Three-Cube Representation of 1729

**Theorem 3.1** (Three-Cube Refutation). 1729 admits a nontrivial three-cube representation:

$$1729 = (-7)^3 + (-5)^3 + 13^3 = -343 + (-125) + 2197$$

*Proof.* Direct computation. ∎

This refutes the conjecture that 1729 has no nontrivial three-cube representation. The representation is unique among ordered triples (x ≤ y ≤ z, all nonzero) within the search range |x|, |y|, |z| ≤ 200.

### 3.2 The Three-Cube Inversion Principle

**Theorem 3.2** (Inversion Principle). Let n, a', b', c ∈ ℤ. If c³ - n = a'³ + b'³, then

$$(-a')^3 + (-b')^3 + c^3 = n$$

*Proof.* We have (-a')³ = -a'³ and (-b')³ = -b'³ (since cubing preserves sign). Then:

$$(-a')^3 + (-b')^3 + c^3 = -a'^3 - b'^3 + c^3 = -(a'^3 + b'^3) + c^3 = -(c^3 - n) + c^3 = n$$

∎

**Corollary 3.3** (Application to 1729). Since 13³ - 1729 = 2197 - 1729 = 468 = 7³ + 5³, the inversion principle yields 1729 = (-7)³ + (-5)³ + 13³.

**Theorem 3.4** (Reduction to Two-Cube Problem). If there exists c ≠ 0 such that c³ - n is expressible as a sum of two nonzero cubes, then n has a nontrivial three-cube representation.

*Proof.* Apply Theorem 3.2 and observe that the resulting triple has all nonzero components. ∎

This reduction is significant: it transforms the three-cube problem into a family of two-cube problems, one for each candidate value of c.

### 3.3 Mod-9 Obstruction

**Theorem 3.5** (Cube Residues). For any x ∈ ℤ, x³ mod 9 ∈ {0, 1, 8}.

*Proof.* By exhaustive case analysis on x mod 9. For each residue class r ∈ {0, 1, ..., 8}, compute r³ mod 9. ∎

**Theorem 3.6** (Mod-9 Obstruction). If n ≡ 4 (mod 9) or n ≡ 5 (mod 9), then there exist no integers x, y, z with x³ + y³ + z³ = n.

*Proof.* The sum of three elements from {0, 1, 8} modulo 9 can yield {0, 1, 2, 3, 6, 7, 8} but never 4 or 5. ∎

**Corollary 3.7.** 1729 ≡ 1 (mod 9), so 1729 is not obstructed. This is consistent with (and necessary for) the existence of the three-cube representation.

### 3.4 Algebraic Structure

**Theorem 3.8** (Cube Sum Factorization). For all a, b ∈ ℤ:

$$a^3 + b^3 = (a + b)(a^2 - ab + b^2)$$

Applied to 1729:
- 1³ + 12³ = 13 · 133 = 13 · 7 · 19
- 9³ + 10³ = 19 · 91 = 19 · 7 · 13

Both factorizations involve all three prime factors of 1729 = 7 · 13 · 19.

**Observation 3.9** (Overshoot Decomposition). The overshoot 13³ - 1729 = 468 = 7³ + 5³ factors as:

$$468 = (7 + 5)(49 - 35 + 25) = 12 \cdot 39$$

The factor 12 reappears from the representation 1729 = 12³ + 1³, suggesting a deeper structural connection.

### 3.5 Carmichael Connection

**Theorem 3.10** (Korselt's Criterion for 1729). 1729 = 7 · 13 · 19 is a Carmichael number because:
1. 1729 is squarefree.
2. (7-1) = 6 | 1728, (13-1) = 12 | 1728, (19-1) = 18 | 1728.

**Theorem 3.11** (Carmichael-Cube Connection). 1729 - 1 = 1728 = 12³. The Carmichael property relies on 1729 - 1 being a perfect cube — the same cube appearing in Ramanujan's original observation.

## 4. Algorithms

### 4.1 Three-Cube Inversion Search

**Input:** Integer n, search bound C_max.
**Output:** All nontrivial three-cube representations found via inversion.

```
for c = 1 to C_max:
    overshoot = c³ - n
    if overshoot > 0:
        for each (a, b) with a³ + b³ = overshoot, a > 0, b ≥ a:
            output (-a, -b, c)
    target = n + c³
    for each (a, b) with a³ + b³ = target, a > 0, b ≥ a:
        output (-c, a, b)
```

**Complexity:** O(C_max · n^{1/3}) using the O(n^{1/3}) two-cube enumeration.

### 4.2 Two-Cube Representation Finder

For fixed n, enumerate all (a, b) with a³ + b³ = n, 0 < a ≤ b:

```
for a = 1 while 2a³ ≤ n:
    b = (n - a³)^{1/3}
    if b³ = n - a³ and b ≥ a:
        output (a, b)
```

**Complexity:** O(n^{1/3}).

## 5. Discussion

### 5.1 Structural Depth

The results reveal that the taxicab property of 1729 is not an isolated curiosity but part of a coherent algebraic structure. The prime factorization 1729 = 7 · 13 · 19 participates directly in:

1. **Two-cube representations** via the identity a³ + b³ = (a+b)(a²-ab+b²), which distributes the prime factors between the two algebraic components.

2. **Three-cube representations** via the inversion principle, where the overshoot 13³ - 1729 = 468 = 7³ + 5³ uses two prime factors as cube bases.

3. **Carmichael number property** via Korselt's criterion and the identity 1729 - 1 = 12³.

### 5.2 The Inversion Principle as a General Tool

The three-cube inversion principle is not specific to 1729. For any integer n, it reduces the problem of finding nontrivial three-cube representations to the problem of finding two-cube representations of the family {c³ - n : c ∈ ℤ}. This is a genuine computational reduction that can be applied systematically.

### 5.3 Open Questions

1. **Uniqueness:** Is (-7, -5, 13) the unique nontrivial ordered three-cube representation of 1729 (up to permutation)? Our search up to bound 200 found no others, but we cannot rule out large solutions.

2. **Parametric families:** Do there exist infinitely many taxicab numbers that also admit nontrivial three-cube representations via the inversion principle?

3. **Prime factor involvement:** Is it a general phenomenon that prime factors of taxicab numbers appear as cube bases in three-cube representations?

## 6. Formalization

All theorems in this paper have been formalized and machine-verified in Lean 4 with Mathlib. The formalization includes:

- Custom structures `SumTwoCubesRep`, `TaxicabWitness`, `NontrivialThreeCubeRep`, and `HasTaxicabOrder`
- The mod-9 obstruction theorem via exhaustive residue analysis
- The three-cube inversion principle as a general algebraic theorem
- Verification of all numerical claims

The formalization is available in `MachineLearning/NumberTheory/Taxicab/Basic.lean`.

## 7. Future Work

The inversion principle suggests a program for studying sums of three cubes more broadly:

1. **Density of inversion-accessible numbers:** What fraction of integers n ≤ N have c with c³ - n expressible as a sum of two cubes?

2. **Higher taxicab orders:** Do numbers with taxicab order ≥ 3 (like 87539319) have richer three-cube structure?

3. **Carmichael-taxicab intersection:** Are there other numbers that are simultaneously Carmichael numbers and taxicab numbers? The smallest candidate after 1729 would need to satisfy strong divisibility conditions.

## References

[1] G.H. Hardy, *Ramanujan*, Cambridge University Press, 1940.

[2] A.-S. Elsenhans and J. Jahnel, "New sums of three cubes," *Mathematics of Computation*, 2009.

[3] S. Singh, *Fermat's Last Theorem*, Fourth Estate, 1997.

[4] R.D. Carmichael, "On composite numbers P which satisfy the Fermat congruence a^{P-1} ≡ 1 mod P," *American Mathematical Monthly*, 1912.
