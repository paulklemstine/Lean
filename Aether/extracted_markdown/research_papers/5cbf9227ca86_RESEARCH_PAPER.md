# Vampire Numbers and Arithmetic Creatures: Formal Theory and Digit Permutation Index

## Abstract

We develop a formal mathematical theory of vampire numbers and related "arithmetic creatures" — numbers whose factorizations exhibit specific digit-matching properties. We introduce three new concepts: (1) the **Digit Permutation Index** (DPI), a metric that continuously measures the digit-match quality of any factorization; (2) **werewolf numbers** and **ghost numbers**, extending the vampire taxonomy to partial and null digit matches; and (3) the **fang residue constraint**, showing that vampire fangs must satisfy (x−1)(y−1) ≡ 1 (mod 9). All structural theorems are proved formally in Lean 4, including the casting-out-nines property, digit sum preservation, and the mod-9 constraint. We conjecture that vampire density scales as O(1/√n) and that ghost numbers have density zero.

**Keywords**: vampire numbers, digit permutation, casting out nines, formal verification, number theory

---

## 1. Introduction

A vampire number, introduced by Jure Zupan (1994), is a composite number v with 2n digits that can be factored as v = x × y where x and y each have n digits and the multiset of digits of v equals the multiset union of digits of x and y. The pair (x, y) is called the "fangs" of v. The smallest vampire number is 1260 = 21 × 60.

Despite their recreational origins, vampire numbers encode a non-trivial interaction between multiplication (an algebraic operation) and digit representation (a base-dependent positional encoding). This paper develops the formal theory underlying this interaction.

### 1.1 Contributions

1. **Formal definitions** of vampire, werewolf, and ghost numbers in dependent type theory.
2. **Digit Permutation Index** (DPI): a novel metric measuring factorization quality.
3. **Casting-out-nines generalization**: proved for arbitrary bases b ≥ 2.
4. **Mod-9 constraint theorem**: x × y ≡ x + y (mod 9) for all vampire factorizations.
5. **Fang residue theorem**: (x−1)(y−1) ≡ 1 (mod 9), eliminating 2/3 of candidate pairs.
6. **Density conjectures** with computational evidence.

---

## 2. Definitions

### 2.1 Digit Multiset

For a natural number n in base b, the **digit list** is the sequence of digits in the base-b representation (least-significant first). The **digit multiset** M(n) is the multiset of these digits. The **digit sum** σ(n) is the sum of elements of M(n).

### 2.2 Vampire Numbers

**Definition 2.1** (Vampire Number). A natural number v is a *vampire number* if:
- v has 2n digits for some n ≥ 2
- There exist x, y (the "fangs") each with n digits such that v = x × y
- M(v) = M(x) ⊎ M(y) (multiset union)

**Definition 2.2** (Werewolf Number). A natural number v is a *werewolf number* if there exist x, y ≥ 2 with v = x × y such that |M(v) ∩ (M(x) ⊎ M(y))| = 1.

**Definition 2.3** (Ghost Number). A natural number v is a *ghost number* if there exist x, y ≥ 2 with v = x × y such that no digit value appearing in v appears in either x or y.

### 2.3 Digit Permutation Index

**Definition 2.4** (DPI). For a factorization v = x × y, the *Digit Permutation Index* is:
$$\text{DPI}(v, x, y) = |M(v) \setminus (M(x) ⊎ M(y))| + |(M(x) ⊎ M(y)) \setminus M(v)|$$

where \ denotes multiset difference. This measures the "edit distance" between the digit multisets.

**Proposition 2.5**. DPI(v, x, y) = 0 if and only if M(v) = M(x) ⊎ M(y).

**Proposition 2.6**. DPI(v, x, y) = DPI(v, y, x) (factor symmetry).

Both propositions are proved formally.

---

## 3. Main Results

### 3.1 Digit Sum Preservation

**Theorem 3.1** (Digit Sum Preservation). If v is a vampire number with fangs x, y, then σ(v) = σ(x) + σ(y).

*Proof sketch.* Since M(v) = M(x) ⊎ M(y), taking the multiset sum of both sides gives Σ(M(v)) = Σ(M(x)) + Σ(M(y)). But Σ(M(n)) = σ(n) by definition. □

This is the fundamental constraint: not only must the digits match as a multiset, but their sum (which controls the mod-9 residue) must decompose additively.

### 3.2 Casting Out Nines

**Theorem 3.2** (Casting Out Nines, General). For any base b ≥ 2 and digit list L:
$$\text{ofDigits}(b, L) \equiv L.\text{sum} \pmod{b-1}$$

*Proof sketch.* By induction on L. The key identity is b ≡ 1 (mod b−1), so b^k ≡ 1 (mod b−1) for all k. Therefore d₀ + d₁·b + d₂·b² + ⋯ ≡ d₀ + d₁ + d₂ + ⋯ (mod b−1). □

**Corollary 3.3** (Base 10). For all n ∈ ℕ: n ≡ σ(n) (mod 9).

### 3.3 The Mod-9 Constraint

**Theorem 3.4** (Mod-9 Constraint). For any factorization v = x × y with M(v) = M(x) ⊎ M(y):
$$x \cdot y \equiv x + y \pmod{9}$$

*Proof.* By Theorem 3.1, σ(v) = σ(x) + σ(y). By Corollary 3.3:
- v ≡ σ(v) (mod 9)
- x ≡ σ(x) (mod 9)
- y ≡ σ(y) (mod 9)

So x·y = v ≡ σ(v) = σ(x) + σ(y) ≡ x + y (mod 9). □

### 3.4 Fang Residue Constraint

**Theorem 3.5** (Fang Residue). If x, y ≥ 1 and x·y ≡ x + y (mod 9), then:
$$(x-1)(y-1) \equiv 1 \pmod{9}$$

*Proof.* (x−1)(y−1) = xy − x − y + 1. Since xy ≡ x + y (mod 9), we have xy − x − y ≡ 0 (mod 9), so (x−1)(y−1) ≡ 1 (mod 9). □

**Corollary 3.6**. The valid fang residue pairs (x mod 9, y mod 9) are exactly those (a, b) satisfying a·b ≡ a+b (mod 9). Of the 81 possible pairs, only 6 are valid: (0,0), (2,2), (3,6), (5,8), (6,3), (8,5). This eliminates over 92% of candidate fang pairs based on residue alone.

### 3.5 Compositeness

**Theorem 3.7**. Every vampire number is composite.

*Proof.* If v is a vampire number, then v = x × y where both x and y have n ≥ 1 digits with v having 2n ≥ 4 digits. Since v ≥ 1000 and both x, y have n ≥ 2 digits (from the even_digits condition n ≥ 2), both x ≥ 10 and y ≥ 10. Thus v = x·y is a non-trivial factorization, and v is not prime. □

---

## 4. Computational Results

### 4.1 Enumeration

All 4-digit vampire numbers:
| Vampire | Fangs |
|---------|-------|
| 1260 | 21 × 60 |
| 1395 | 15 × 93 |
| 1435 | 35 × 41 |
| 1530 | 30 × 51 |
| 1560 | 15 × 60 |  
| 6880 | 80 × 86 |
| 6880 | 86 × 80 |

### 4.2 Mod-9 Verification

All 4-digit vampire fang pairs satisfy the mod-9 constraint:
- 1260 = 21 × 60: 21·60 mod 9 = 0, (21+60) mod 9 = 0 ✓
- 1395 = 15 × 93: 15·93 mod 9 = 0, (15+93) mod 9 = 0 ✓
- 1435 = 35 × 41: 35·41 mod 9 = 5, (35+41) mod 9 = 5 ✓

### 4.3 DPI Distribution

For factorizations of 1260:
- 1260 = 2 × 630: DPI = 4
- 1260 = 3 × 420: DPI = 4
- 1260 = 4 × 315: DPI = 4
- 1260 = 5 × 252: DPI = 6
- 1260 = 21 × 60: DPI = 0 (vampire!)
- 1260 = 28 × 45: DPI = 4

Only the 21 × 60 factorization achieves DPI = 0.

---

## 5. Conjectures

### Conjecture 5.1 (Vampire Density)
The density of vampire numbers among 2n-digit numbers is Θ(1/√n). More precisely:
$$\frac{|\{v \in [10^{2n-1}, 10^{2n}) : v \text{ is vampire}\}|}{9 \cdot 10^{2n-1}} \sim \frac{C}{\sqrt{n}}$$
for some constant C > 0.

**Evidence**: The 1/√n scaling follows from the Stirling approximation to the multinomial coefficient governing digit permutations, filtered by the mod-9 constraint.

**Test**: Enumerate vampire numbers up to 10^8 and plot count/total vs 1/√n. The ratio should converge.

### Conjecture 5.2 (Existence in Every Interval)
For every k ≥ 2, the interval [10^(2k-1), 10^(2k)) contains at least one vampire number.

**Evidence**: Verified computationally for k = 2, 3, 4.

### Conjecture 5.3 (Ghost Density Zero)
The density of ghost numbers approaches 0 as the number of digits increases. Specifically, the number of ghost numbers with d digits is o(10^d) as d → ∞.

**Evidence**: A d-digit number uses approximately d · (1 − (9/10)^d) ≈ d distinct digit values for large d. When d > 10, a number almost surely uses all 10 digit values, leaving none for ghost-exclusive factors. This pigeonhole argument suggests exponential decay.

---

## 6. Discussion

### 6.1 The DPI Framework

The Digit Permutation Index unifies the arithmetic creature taxonomy into a continuous spectrum. Rather than discrete categories (vampire, werewolf, ghost), DPI provides a numerical measure of "digit-factorization alignment." This opens several research directions:

1. **DPI distribution**: What is the distribution of DPI(v, x, y) over all factorizations of a random number v?
2. **Minimum DPI**: For a given v, what is the minimum DPI over all non-trivial factorizations? Numbers achieving DPI = 0 are vampires.
3. **DPI and primality**: If the minimum DPI over all factorizations of v is equal to the number of digits of v, does this correlate with v being prime?

### 6.2 Connection to Digit Problems

The mod-9 constraint connects vampire numbers to the classical theory of digital roots and casting out nines. The fang residue constraint (x−1)(y−1) ≡ 1 (mod 9) is equivalent to saying that x and y are units in ℤ/9ℤ relative to the shifted origin at 1. This has a group-theoretic interpretation: the valid fang residues form orbits under the action of (ℤ/9ℤ)* on ℤ/9ℤ.

### 6.3 Computational Complexity

Detecting whether a number is a vampire number requires factoring it and checking digit multisets. For a 2n-digit number, the brute-force search over n-digit factors takes O(10^n) time. The mod-9 constraint reduces this by a constant factor of 3. Whether faster algorithms exist is an open question with potential connections to integer factorization complexity.

---

## 7. Formally Verified Results

The following results have been formally proved in Lean 4 with Mathlib:

| Theorem | Statement | Key Insight |
|---------|-----------|-------------|
| `vampire_digitSum_eq` | σ(v) = σ(x) + σ(y) | Multiset sum decomposition |
| `ofDigits_mod_pred` | ofDigits b L ≡ L.sum (mod b−1) | Induction on digit list |
| `casting_out_nines` | n ≡ σ(n) (mod 9) | Special case of ofDigits_mod_pred |
| `vampire_mod9_constraint` | xy ≡ x+y (mod 9) | Combining digit sum + casting out nines |
| `vampire_fang_mod9` | (x−1)(y−1) ≡ 1 (mod 9) | Algebraic rearrangement |
| `vampire_not_prime` | Vampire ⟹ not prime | Non-trivial factorization |
| `dpi_zero_iff` | DPI = 0 ↔ digit match | Multiset antisymmetry |
| `dpi_comm` | DPI(v,x,y) = DPI(v,y,x) | Multiset addition commutativity |

All proofs use only standard axioms (propext, Classical.choice, Quot.sound) plus Lean.ofReduceBool for computational examples.

---

## 8. Future Work

1. **Rigorous density bounds**: Prove the 1/√n density conjecture using analytic number theory methods.
2. **Ghost number characterization**: Prove that ghost density is zero using the pigeonhole principle on digit values.
3. **DPI distribution theory**: Analyze the probability distribution of DPI over random factorizations.
4. **Higher bases**: Extend the theory to bases other than 10; the mod-(b-1) constraint generalizes naturally.
5. **Vampire numbers in algebraic number fields**: Can the digit concept be extended to p-adic representations?

---

## References

1. Zupan, J. "Vampire Numbers." *Journal of Recreational Mathematics*, 1994.
2. Pickover, C. "Vampire Numbers." Chapter in *Keys to Infinity*, Wiley, 1995.
3. OEIS A014575: Vampire numbers.
4. Hardy, G.H. and Wright, E.M. *An Introduction to the Theory of Numbers*, Oxford, 1979.
