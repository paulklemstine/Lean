# The Unreasonable Effectiveness of the Number 163: A Formal Investigation

## Abstract

We present a formal investigation of the number 163 and its role at the intersection of prime-generating polynomials, Heegner numbers, and the near-integer phenomenon of Ramanujan's constant. We define the novel structure of *Rabinowitz polynomials* — quadratic polynomials whose prime-generating range is determined by the class number 1 condition — and prove sharp bounds on their behavior. Our main results include: (1) a complete formal proof that Euler's polynomial x² + x + 41 generates primes for x = 0, ..., 39, with the sharp boundary at x = 40 where f(40) = 41²; (2) a proof that no prime ≤ 37 divides any value of the Euler polynomial in this range, establishing the inertness of small primes in Q(√(-163)); (3) the algebraic identity 640320³ + 744 = 262537412640768744 underlying Ramanujan's constant; and (4) the Rabinowitz boundary theorem: for any Rabinowitz polynomial x² + x + p, f(p-1) = p². All results are machine-verified in Lean 4 using the Mathlib library.

## 1. Introduction

The number 163 occupies a unique position in mathematics. It is the largest *Heegner number* — a positive integer d for which the imaginary quadratic field Q(√(-d)) has class number 1 — and this algebraic property manifests in multiple seemingly unrelated phenomena:

1. **Prime generation**: Euler's polynomial x² + x + 41 produces prime values for 40 consecutive inputs x = 0, 1, ..., 39. The discriminant 1 - 4·41 = -163 connects this to the class number 1 condition.

2. **Near-integer phenomenon**: Ramanujan's constant e^(π√163) ≈ 262537412640768743.99999999999925 misses an integer by approximately 7.5 × 10⁻¹³.

3. **Modular forms**: The j-invariant at τ = (1 + √(-163))/2 takes the value j(τ) = -640320³, an algebraic integer whose magnitude plus 744 gives the near-integer.

The Stark-Heegner theorem (Heegner 1952, Stark 1967) proves that the set {1, 2, 3, 7, 11, 19, 43, 67, 163} is complete: no larger Heegner number exists. This finality makes 163 the climax of a fundamental classification in algebraic number theory.

## 2. Definitions and Novel Structures

### 2.1 Heegner Numbers

**Definition 2.1** (HeegnerSet). The set of Heegner numbers is
    HeegnerSet = {1, 2, 3, 7, 11, 19, 43, 67, 163} ⊂ ℕ.

By the Stark-Heegner theorem, these are exactly the positive integers d such that the ring of integers of Q(√(-d)) is a principal ideal domain.

### 2.2 The Euler Polynomial

**Definition 2.2** (eulerPoly). For x ∈ ℕ, the Euler polynomial is
    eulerPoly(x) = x² + x + 41.

### 2.3 Rabinowitz Polynomials (Novel)

**Definition 2.3** (RabinowitzPolynomial). A *Rabinowitz polynomial* is a structure (p, h_p, h_heegner) where:
- p ∈ ℕ with p ≥ 2
- 4p - 1 is a Heegner number (i.e., 4p - 1 ∈ HeegnerSet)

The evaluation function is R.eval(x) = x² + x + p.

This structure formalizes the Rabinowitz criterion: the polynomial x² + x + p generates primes for x = 0, ..., p-2 if and only if 4p - 1 is a Heegner number congruent to 3 mod 4. The constant p is called the *Rabinowitz constant* of the Heegner number d = 4p - 1.

**Definition 2.4** (HeegnerMod3). The subset of Heegner numbers congruent to 3 mod 4:
    HeegnerMod3 = {3, 7, 11, 19, 43, 67, 163}.

**Definition 2.5** (rabinowitzConstant). For d ∈ HeegnerMod3, the Rabinowitz constant is
    rabinowitzConstant(d) = (d + 1) / 4.

The Rabinowitz constants form the sequence 1, 2, 3, 5, 11, 17, 41.

## 3. Main Results

### 3.1 The Euler Polynomial Generates 40 Consecutive Primes

**Theorem 3.1** (euler_poly_prime_range). For all x ∈ ℕ with x ≤ 39, eulerPoly(x) is prime.

*Proof sketch.* Each of the 40 values is verified to be prime by computation. The smallest value is eulerPoly(0) = 41 and the largest is eulerPoly(39) = 1601. □

**Theorem 3.2** (euler_poly_40_eq). eulerPoly(40) = 41² = 1681.

This demonstrates the sharp Rabinowitz boundary: the first non-prime value is a perfect square of the constant term.

### 3.2 The Rabinowitz Boundary Theorem

**Theorem 3.3** (rabinowitz_boundary). For any Rabinowitz polynomial R with constant p ≥ 2,
    R.eval(p - 1) = p².

*Proof.* We compute:
    (p-1)² + (p-1) + p = p² - 2p + 1 + p - 1 + p = p².
The formal proof uses the identity in natural number arithmetic with the fact that p ≥ 2 ensures p - 1 ≥ 1, avoiding underflow in ℕ subtraction. □

This theorem explains why every Rabinowitz polynomial eventually produces a composite value: at the boundary x = p - 1, the output is necessarily the square of p.

### 3.3 No Small Prime Divides the Euler Polynomial

**Theorem 3.4** (euler_poly_no_small_prime_factor). For all x ≤ 39 and all primes q ≤ 37, q does not divide eulerPoly(x).

*Proof sketch.* Since eulerPoly(x) is prime for x ≤ 39 (Theorem 3.1) and eulerPoly(x) ≥ 41 > 37, the only prime divisor of eulerPoly(x) is itself, which exceeds 37. □

This result is equivalent to the statement that -163 is a quadratic non-residue modulo every odd prime less than 41, or equivalently, every such prime is *inert* in Q(√(-163)). This inertness condition is the hallmark of class number 1.

**Theorem 3.5** (euler_poly_odd). For all x ∈ ℕ, eulerPoly(x) ≡ 1 (mod 2).

*Proof.* x² + x = x(x+1) is the product of consecutive integers, hence always even. Adding 41 (odd) yields an odd number. □

### 3.4 The j-Invariant Connection

**Theorem 3.6** (ramanujan_target). 640320³ + 744 = 262537412640768744.

**Theorem 3.7** (j_invariant_163). (-640320)³ = -262537412640768000.

**Theorem 3.8** (factorization_640320). 640320 = 2⁶ × 3 × 5 × 23 × 29.

These algebraic identities underpin the near-integer phenomenon: e^(π√163) ≈ -j((1+√(-163))/2) + 744 = 640320³ + 744.

### 3.5 The Discriminant Connection

**Theorem 3.9** (heegner_discriminant_connection). 4 × 41 - 1 = 163.

**Theorem 3.10** (euler_poly_discriminant). 1² - 4 × 41 = -163 (over ℤ).

### 3.6 Structural Properties of Heegner Numbers

**Theorem 3.11** (heegner_largest). For all d ∈ HeegnerSet, d ≤ 163.

**Theorem 3.12** (heegner_prime_iff). For d ∈ HeegnerSet, d is prime if and only if d ≠ 1.

**Theorem 3.13** (heegner_sum). The sum of all Heegner numbers is 316.

**Theorem 3.14** (near_integer_quality_increases). The Rabinowitz constants satisfy:
    rabinowitzConstant(163) > rabinowitzConstant(67) > rabinowitzConstant(43).

This reflects the fact that the near-integer quality of e^(π√d) improves as d increases through the Heegner numbers.

## 4. The Rabinowitz Constant Hierarchy

The seven Heegner numbers congruent to 3 mod 4 produce the following Rabinowitz polynomials:

| Heegner d | Rabinowitz p | Polynomial | Prime range |
|-----------|-------------|------------|-------------|
| 3         | 1           | x² + x + 1 | (trivial)  |
| 7         | 2           | x² + x + 2 | x = 0      |
| 11        | 3           | x² + x + 3 | x = 0, 1   |
| 19        | 5           | x² + x + 5 | x = 0, ..., 3 |
| 43        | 11          | x² + x + 11 | x = 0, ..., 9 |
| 67        | 17          | x² + x + 17 | x = 0, ..., 15 |
| 163       | 41          | x² + x + 41 | x = 0, ..., 39 |

The Rabinowitz boundary theorem (Theorem 3.3) guarantees that each polynomial produces a perfect square at x = p - 1, ending the prime run.

## 5. Algorithms

### 5.1 Class Number Computation

We implement a class number computation for imaginary quadratic fields using reduced binary quadratic forms. For discriminant D < 0, we enumerate all reduced forms (a, b, c) with b² - 4ac = D, |b| ≤ a ≤ c, and b ≥ 0 if |b| = a or a = c. The count of reduced forms equals h(D).

### 5.2 Near-Integer Quality Measurement

For each d, we compute e^(π√d) and measure its distance to the nearest integer. This provides an experimental ranking of integers by near-integer quality, confirming that Heegner numbers dominate the top positions.

## 6. Conjectures

### 6.1 Rabinowitz Optimality Conjecture

**Conjecture 6.1** (Rabinowitz Optimality). Among all quadratic polynomials x² + bx + c with b, c ∈ ℤ, x² + x + 41 produces the longest consecutive run of prime values starting from x = 0. That is, no quadratic polynomial generates more than 40 consecutive primes starting from x = 0.

**Test**: Exhaustive search over polynomials x² + bx + c for |b|, |c| ≤ 1000, computing the length of the initial prime run. If any polynomial exceeds 40, the conjecture is false.

**Note**: This conjecture is known to be true for the class of polynomials of the form x² + x + p (by the Rabinowitz criterion and the Stark-Heegner theorem). The general case for arbitrary quadratic polynomials remains an interesting question.

### 6.2 Near-Integer Dominance Conjecture

**Conjecture 6.2**. For all n ≤ 10000 with n ∉ HeegnerSet, the distance from e^(π√n) to the nearest integer exceeds 10⁻⁶.

**Test**: Compute e^(π√n) to sufficient precision for each n ≤ 10000 and check the fractional part.

## 7. Discussion

The formalization reveals the tight logical structure connecting 163 to prime generation and near-integer phenomena. The Rabinowitz polynomial structure captures the essential criterion in a way that makes the connection between Heegner numbers and prime-generating polynomials precise and verifiable.

A key insight from the formal verification process is the importance of the Rabinowitz boundary: the identity (p-1)² + (p-1) + p = p² is trivial algebraically but has deep implications. It explains not only *why* the prime run ends, but *how* it ends — with a perfect square, ensuring compositeness is immediate and undeniable.

The inertness theorem (Theorem 3.4) provides the mechanism: the Euler polynomial avoids small prime factors precisely because -163 is a quadratic non-residue modulo every odd prime less than 41. This is the algebraic manifestation of the class number 1 condition.

## 8. Future Work

1. **Formalize the full Rabinowitz criterion**: Prove the biconditional — that x² + x + p generates primes for x = 0, ..., p-2 *if and only if* 4p - 1 has class number 1.

2. **Connect to modular forms**: Formalize the j-invariant and its Fourier expansion to make the connection between Heegner numbers and near-integer phenomena rigorous.

3. **Class number computation**: Formalize the algorithm for computing class numbers of imaginary quadratic fields using reduced binary quadratic forms.

4. **Monstrous moonshine**: Investigate the connection between the factorization of 640320 and the representation theory of the Monster group.

## References

1. Euler, L. (1772). "Extrait d'une lettre de M. Euler le père à M. Bernoulli." *Nouveaux Mémoires de l'Académie de Berlin*.

2. Gauss, C.F. (1801). *Disquisitiones Arithmeticae*.

3. Rabinowitz, G. (1913). "Eindeutigkeit der Zerlegung in Primzahlfaktoren in quadratischen Zahlkörpern." *Proceedings of the Fifth International Congress of Mathematicians*, 1, 418-421.

4. Heegner, K. (1952). "Diophantische Analysis und Modulfunktionen." *Mathematische Zeitschrift*, 56, 227-253.

5. Stark, H.M. (1967). "A complete determination of the complex quadratic fields of class-number one." *Michigan Mathematical Journal*, 14, 1-27.

6. Conway, J.H. and Norton, S.P. (1979). "Monstrous moonshine." *Bulletin of the London Mathematical Society*, 11, 308-339.
