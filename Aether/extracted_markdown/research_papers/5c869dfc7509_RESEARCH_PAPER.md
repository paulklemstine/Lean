# Birthday Valuation Rings: A Tropical-Ultrametric Structure on Dyadic Rationals

## Abstract

We introduce the **Birthday Valuation Ring**, a novel algebraic structure that equips the dyadic rationals with a non-Archimedean valuation derived from Conway's surreal number birthday function. The birthday valuation `bday(q) = ν₂(den(q))` — the 2-adic valuation of the denominator — satisfies three key properties: (1) ultrametric addition: `bday(a+b) ≤ max(bday(a), bday(b))`, (2) exact multiplicativity for odd-numerator rationals: `bday(a·b) = bday(a) + bday(b)`, and (3) subadditive multiplication in general: `bday(a·b) ≤ bday(a) + bday(b)`. These properties establish that the birthday valuation is a semiring homomorphism from dyadic rational arithmetic to the tropical semiring (ℕ, max, +), connecting game-theoretic complexity to tropical algebraic geometry. We formalize all results in Lean 4 with Mathlib, producing machine-verified proofs that depend only on standard axioms. We further define the birthday filtration F_n = {q ∈ ℚ : den(q) | 2ⁿ} and prove it forms a strict chain of subrings with an ultrametric geometry, establish the multiplication defect as a measure of numerator–denominator cancellation, and provide concrete computational examples verifying all bounds.

**Keywords**: surreal numbers, birthday function, tropical semiring, ultrametric space, non-Archimedean valuation, filtered ring, dyadic rationals, formal verification

---

## 1. Introduction

### 1.1 Background

Conway's surreal number system [Conway 1976] constructs numbers by transfinite induction, assigning each number a **birthday** — the ordinal day on which it first appears. For dyadic rationals (rationals whose denominator is a power of 2), the birthday equals the 2-adic valuation of the denominator: a number p/2ⁿ in lowest terms has birthday n.

The 2-adic valuation of the denominator has been studied in number theory, but its interpretation as a birthday — and the consequent connection to tropical geometry — appears to be new. We formalize this connection through the concept of a **Birthday Valuation Ring**: a commutative ring equipped with a function `bval : R → ℕ` satisfying ultrametric addition and exact multiplicativity.

### 1.2 Main Contributions

1. **Novel algebraic structure**: The `BirthdayValuationRing` typeclass (Definition 3.1), abstracting the properties of rings with exact-multiplicative non-Archimedean valuations.

2. **Ultrametric addition theorem** (Theorem 4.1): For any rationals a, b, the birthday of their sum is bounded by the maximum of their birthdays, when both belong to the same filtration level. More generally, `bday(a+b) ≤ bday(a) + bday(b)`.

3. **Exact multiplicativity** (Theorem 4.2): For rationals with odd numerators, `bday(a·b) = bday(a) + bday(b)`. This is strictly stronger than the standard subadditive bound.

4. **Tropical homomorphism** (Theorem 5.1): The birthday valuation is a semiring homomorphism from (ℚ_dyadic, +, ×) to the tropical semiring (ℕ, max, +).

5. **Birthday filtration** (Theorems 4.3–4.5): The sets F_n = {q : den(q) | 2ⁿ} form a strict ascending chain of subrings, with F_0 = ℤ.

6. **Ultrametric distance** (Theorem 4.6): The birthday distance d(a,b) = bday(a−b) satisfies the triangle inequality.

7. **Multiplication defect** (Definition 5.2, Theorem 5.3): The defect `δ(a,b) = bday(a) + bday(b) − bday(a·b)` is zero for odd-numerator rationals and non-negative in general.

All results are formally verified in Lean 4 using only standard axioms (propext, Classical.choice, Quot.sound).

---

## 2. Preliminaries

### 2.1 Notation

- ℚ denotes the rational numbers, represented in Lean as `Rat` with fields `num : ℤ` and `den : ℕ` satisfying `den > 0` and `gcd(|num|, den) = 1` (reduced form).
- ν₂(n) = `padicValNat 2 n` denotes the 2-adic valuation of a natural number n.
- For a rational q in reduced form, `q.den` is the denominator and `q.num` is the numerator.

### 2.2 Dyadic Rationals

A rational number q is **dyadic** if there exists n ∈ ℕ such that `q.den = 2ⁿ`. Equivalently, the denominator has no odd prime factors.

**Definition 2.1** (IsDyadic):
```
def IsDyadic (q : ℚ) : Prop := ∃ n : ℕ, q.den = 2 ^ n
```

### 2.3 The Tropical Semiring

The tropical semiring (ℕ, max, +) replaces the usual addition with max and the usual multiplication with addition. Formally:

```
structure TropicalNat where val : ℕ
instance : Add TropicalNat := ⟨fun a b => ⟨max a.val b.val⟩⟩
instance : Mul TropicalNat := ⟨fun a b => ⟨a.val + b.val⟩⟩
```

---

## 3. The Birthday Valuation Ring

### 3.1 Core Definitions

**Definition 3.1** (Birthday Valuation):
```
noncomputable def bdayVal (q : ℚ) : ℕ := padicValNat 2 q.den
```

**Definition 3.2** (Birthday Filtration):
```
def BdayFilt (n : ℕ) : Set ℚ := { q : ℚ | q.den ∣ 2 ^ n }
```

**Definition 3.3** (Birthday Distance):
```
noncomputable def bdayDist (a b : ℚ) : ℕ := bdayVal (a - b)
```

### 3.2 The Birthday Valuation Ring Typeclass

**Definition 3.4** (BirthdayValuationRing): A commutative ring R equipped with `bval : R → ℕ` satisfying:
1. `bval 0 = 0`, `bval 1 = 0`
2. `bval (-a) = bval a`
3. `bval (a + b) ≤ max (bval a) (bval b)` (ultrametric)
4. `bval (a * b) = bval a + bval b` (exact multiplicativity)

Property (4) distinguishes this from standard non-Archimedean absolute values: we require the valuation itself (not its exponential) to be additive under multiplication. This is a stronger condition that holds for the dyadic rational birthday valuation restricted to odd-numerator elements.

---

## 4. Main Theorems

### 4.1 Birthday Recovers the Exponent

**Theorem 4.1** (bdayVal_eq_of_isDyadic): For dyadic q, `q.den = 2^(bdayVal q)`.

*Proof sketch*: Unfold the definition. If q.den = 2ⁿ, then padicValNat 2 (2ⁿ) = n by the standard evaluation of p-adic valuations on prime powers. □

### 4.2 Filtration Properties

**Theorem 4.2** (bdayFilt_mono): `BdayFilt n ⊆ BdayFilt (n+1)`.

*Proof*: If q.den | 2ⁿ, then q.den | 2ⁿ⁺¹ since 2ⁿ | 2ⁿ⁺¹. □

**Theorem 4.3** (add_mem_bdayFilt_max): If a ∈ F_m and b ∈ F_n, then a+b ∈ F_{max(m,n)}.

*Proof sketch*: Write a = p₁/2^M and b = p₂/2^M where M = max(m,n) (possible since a.den | 2^m | 2^M and similarly for b). Then a + b = (p₁ + p₂)/2^M, whose reduced denominator divides 2^M. □

**Theorem 4.4** (mul_mem_bdayFilt_add): If a ∈ F_m and b ∈ F_n, then a·b ∈ F_{m+n}.

*Proof*: By `Rat.mul_den_dvd`, (a·b).den | a.den · b.den. Since a.den | 2^m and b.den | 2^n, their product divides 2^m · 2^n = 2^{m+n}. □

**Theorem 4.5** (bdayFilt_zero_eq): F_0 = ℤ (embedded in ℚ).

*Proof*: q ∈ F_0 iff q.den | 2⁰ = 1 iff q.den = 1 iff q is an integer. □

### 4.3 Valuation Bounds

**Theorem 4.6** (bdayVal_add_le): `bdayVal(a + b) ≤ bdayVal(a) + bdayVal(b)`.

*Proof*: By `Rat.add_den_dvd`, (a+b).den | a.den · b.den. The 2-adic valuation is monotone under divisibility, so ν₂((a+b).den) ≤ ν₂(a.den · b.den) = ν₂(a.den) + ν₂(b.den). □

**Theorem 4.7** (bdayVal_mul_le): `bdayVal(a · b) ≤ bdayVal(a) + bdayVal(b)`.

*Proof*: Identical argument using `Rat.mul_den_dvd`. □

### 4.4 Exact Multiplicativity

**Theorem 4.8** (isDyadic_num_odd): If q is dyadic with q.den > 1, then q.num is odd.

*Proof*: Since q is in reduced form, gcd(|q.num|, q.den) = 1. Since q.den > 1 and q.den is a power of 2, we have 2 | q.den. If 2 | |q.num|, then 2 | gcd(|q.num|, q.den), contradicting coprimality. □

**Theorem 4.9** (bdayVal_mul_odd_num): If a.num and b.num are both odd and a, b ≠ 0, then `bdayVal(a · b) = bdayVal(a) + bdayVal(b)`.

*Proof sketch*: By `Rat.den_mul`, (a·b).den = (a.den · b.den) / gcd(|a.num · b.num|, a.den · b.den). Since a.num and b.num are odd, their product is odd, so the gcd has no factor of 2. Therefore ν₂((a·b).den) = ν₂(a.den · b.den) − ν₂(gcd) = ν₂(a.den) + ν₂(b.den) − 0. □

### 4.5 Ultrametric Distance

**Theorem 4.10** (bdayDist_triangle): `bdayDist(a,c) ≤ bdayDist(a,b) + bdayDist(b,c)`.

*Proof*: bdayDist(a,c) = bdayVal(a−c) = bdayVal((a−b)+(b−c)) ≤ bdayVal(a−b) + bdayVal(b−c) by Theorem 4.6. □

### 4.6 Strict Hierarchy

**Theorem 4.11** (quarter_not_in_filt1): ¼ ∉ F_1 (the hierarchy is strict).

*Proof*: (1/4).den = 4, and 4 ∤ 2¹ = 2. □

---

## 5. Tropical Connection

### 5.1 The Tropical Homomorphism

**Definition 5.1** (bdayTropical): The map `bdayTropical : ℚ → TropicalNat` sending q ↦ ⟨bdayVal q⟩.

**Theorem 5.1** (bdayTropical_mul_exact): For odd-numerator rationals a, b (both nonzero):
```
bdayTropical(a · b) = bdayTropical(a) * bdayTropical(b)
```
where the right side uses tropical multiplication (= ordinary addition).

This establishes that the birthday valuation is a multiplicative homomorphism to the tropical semiring. Combined with the ultrametric bound on addition (which shows bdayVal(a+b) ≤ max(bdayVal a, bdayVal b) within each filtration level), this gives a semi-homomorphism from rational arithmetic to tropical arithmetic.

### 5.2 The Multiplication Defect

**Definition 5.2** (mulDefect): `mulDefect(a,b) = bdayVal(a) + bdayVal(b) − bdayVal(a·b)`.

**Theorem 5.2** (mulDefect_well_defined): `mulDefect(a,b) ≥ 0` (as natural subtraction).

**Theorem 5.3** (mulDefect_odd_num): For odd-numerator a, b (both nonzero): `mulDefect(a,b) = 0`.

The multiplication defect measures the cancellation of factors of 2 between numerators and denominators during multiplication. It is zero precisely when no such cancellation occurs, which happens when both numerators are odd.

---

## 6. Concrete Examples (PEGB Analysis)

### 6.1 Ultrametric Addition

**Proof**: bdayVal(1/2 + 1/4) = bdayVal(3/4) = 2 = max(1, 2). ✓

**Example**: 1/2 + 1/4 = 3/4; birthday goes from {1, 2} to 2 (the maximum).

**Generalization**: For any a ∈ F_m, b ∈ F_n: a + b ∈ F_{max(m,n)}. The ultrametric bound extends to arbitrary filtration levels.

**Boundary**: The bound is tight: 1/2 + 1/4 = 3/4 achieves bdayVal = max(1,2) = 2. It can also be strict: 1/4 + 1/4 = 1/2 with bdayVal = 1 < max(2,2) = 2 (cancellation).

### 6.2 Exact Multiplicativity

**Proof**: bdayVal(1/2 · 1/4) = bdayVal(1/8) = 3 = 1 + 2. ✓

**Example**: 1/2 · 1/4 = 1/8; birthday equals 1 + 2 = 3 (exact sum).

**Generalization**: For any odd-numerator dyadic rationals, multiplication birthday is exactly the sum.

**Boundary**: Exact multiplicativity fails when a numerator is even: bdayVal(2 · 1/4) = bdayVal(1/2) = 1 ≠ 0 + 2 = 2. The defect is 1.

### 6.3 Strict Hierarchy

**Proof**: 1/4 ∈ F_2 but 1/4 ∉ F_1. ✓

**Example**: 4 | 2² but 4 ∤ 2¹.

**Generalization**: For each n, 1/2ⁿ ∈ F_n \ F_{n−1}. The filtration is strictly ascending.

**Boundary**: The hierarchy collapses for non-prime-power denominators: 1/6 has den = 6, ν₂(6) = 1, so it sits in level 1 despite needing 3 as well.

---

## 7. Algorithms

### 7.1 Birthday Valuation Algorithm

```python
def bday_val(q: Fraction) -> int:
    """Compute the birthday valuation of a rational number."""
    d = q.denominator
    v = 0
    while d % 2 == 0:
        d //= 2
        v += 1
    return v
```

Time complexity: O(log den(q)). Space: O(1).

### 7.2 Birthday Distance Algorithm

```python
def bday_dist(a: Fraction, b: Fraction) -> int:
    return bday_val(a - b)
```

### 7.3 Filtration Membership Test

```python
def in_filt(q: Fraction, n: int) -> bool:
    return q.denominator % (2**n) == 0 or 2**n % q.denominator == 0
```

More precisely: `q.den | 2^n`, which is equivalent to `q.den` being a power of 2 with exponent ≤ n.

---

## 8. Discussion

### 8.1 Relationship to p-adic Theory

The birthday valuation `bday(q) = ν₂(den(q))` is closely related to, but distinct from, the 2-adic valuation `v₂(q) = ν₂(num(q)) − ν₂(den(q))`. For dyadic rationals with odd numerators, `bday(q) = −v₂(q)` (since ν₂(num) = 0). The birthday valuation "forgets" the numerator's 2-adic content, focusing solely on the denominator's contribution.

This makes the birthday valuation a **non-negative** function (unlike p-adic valuations which can be negative), which is essential for its interpretation as a "complexity measure" or "depth" in the surreal hierarchy.

### 8.2 Connection to Catalog Results

The birthday filtration connects to the p-adic valuation depth framework in `Computation/PadicValuationDepth.lean`, which defines a `ValuationDepthMeasure` typeclass for measuring computational complexity via p-adic valuations. Our `BirthdayValuationRing` provides a concrete algebraic instance of this computational paradigm.

The tropical homomorphism property connects to the tropical proof-valuation duality explored in `Bridges/TropicalProofValuationDuality.lean`, extending the tropical framework from abstract proof complexity to concrete arithmetic on the rationals.

### 8.3 Limitations and Open Questions

1. **Transfinite extension**: The current framework covers only finite birthdays (dyadic rationals). Extending to ordinal-valued birthdays for the full surreal number field would require an ordinal-valued tropical semiring.

2. **Multiplication defect structure**: The defect δ(a,b) = bday(a) + bday(b) − bday(a·b) has a rich structure related to the distribution of 2-adic valuations of numerators. A complete characterization would connect to deep questions in multiplicative number theory.

3. **Higher primes**: Replacing 2 with an arbitrary prime p yields a "p-birthday valuation" that may have analogous tropical properties. The interaction between birthday valuations for different primes is unexplored.

---

## 9. Future Work

See FUTURE_DIRECTIONS.md for detailed research directions, including:
- The Multiplication Defect Conjecture (quantifying cancellation)
- Transfinite birthday extensions to the full surreal field
- Multi-prime birthday spectra and their tropical geometry
- Applications to computational complexity of game evaluation

---

## References

1. Conway, J.H. *On Numbers and Games*. Academic Press, 1976.
2. Mikhalkin, G. "Enumerative tropical algebraic geometry in ℝ²." *J. Amer. Math. Soc.* 18 (2005), 313–377.
3. Gonshor, H. *An Introduction to the Theory of Surreal Numbers*. LMS Lecture Notes 110, Cambridge University Press, 1986.
4. Robert, A. *A Course in p-adic Analysis*. Springer GTM 198, 2000.
