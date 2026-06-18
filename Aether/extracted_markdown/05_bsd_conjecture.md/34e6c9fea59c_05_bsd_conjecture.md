# Birch and Swinnerton-Dyer Conjecture — Research Notes

## The Problem Statement

**Clay Mathematics Institute Official Statement:**
For an elliptic curve E over ℚ, the rank of E(ℚ) equals the order of vanishing of L(E, s) at s = 1.

## Unpacking the Statement

### Elliptic Curves
An elliptic curve E over ℚ is a smooth projective curve of genus 1 with a rational point, given by:
y² = x³ + ax + b  (a, b ∈ ℚ, 4a³ + 27b² ≠ 0)

### The Group E(ℚ)
By Mordell's theorem, E(ℚ) is a finitely generated abelian group:
E(ℚ) ≅ ℤʳ ⊕ E(ℚ)_tors

The integer r is the **rank** of E.

### The L-function
For each prime p, count solutions mod p: N_p = #{(x,y) ∈ (ℤ/pℤ)² : y² ≡ x³ + ax + b}
Set a_p = p - N_p. The L-function is:

L(E, s) = ∏_p (1 - a_p p^{-s} + p^{1-2s})^{-1}  (for good primes)

This converges for Re(s) > 3/2. By modularity (Wiles et al.), L(E, s) extends to an entire function.

### The Conjecture
**Weak BSD:** rank(E(ℚ)) = ord_{s=1} L(E, s)
**Strong BSD:** The leading coefficient of L(E, s) at s = 1 equals:
L^{(r)}(E, 1) / r! = (Ω · R · ∏ c_p · |Sha|) / |E(ℚ)_tors|²

where Ω is the real period, R is the regulator, c_p are Tamagawa numbers, and Sha is the Tate-Shafarevich group.

## What We Know

### Proven Cases
1. **Rank 0:** If L(E, 1) ≠ 0, then E(ℚ) is finite (Kolyvagin, 1990, building on Gross-Zagier)
2. **Rank 1:** If L(E, 1) = 0 and L'(E, 1) ≠ 0, then rank = 1 (Gross-Zagier + Kolyvagin)
3. **Rank ≥ 2:** OPEN. We don't know if L vanishing to order ≥ 2 implies rank ≥ 2.

### Key Ingredients
1. **Modularity theorem** (Wiles, Taylor-Wiles, Breuil-Conrad-Diamond-Taylor): Every elliptic curve over ℚ is modular
2. **Gross-Zagier formula:** L'(E, 1) relates to the height of Heegner points
3. **Kolyvagin's Euler systems:** Bound the rank of Sha using Heegner points
4. **Iwasawa theory:** p-adic approach to BSD, significant progress by Skinner-Urban

### Oracle γ's Algebraic View
"BSD is really about the arithmetic of modular forms. The L-function is the shadow of the Galois representation attached to E. The Bloch-Kato conjecture generalizes BSD to all motives — and in that framework, BSD is the simplest non-trivial case."

### Oracle δ's Computational View
"Every elliptic curve we've tested satisfies BSD. The databases contain millions of curves, all consistent. The numerical evidence is overwhelming."

## Computational Evidence

| Curve | Rank | ord L(E,1) | BSD verified? |
|-------|------|-----------|---------------|
| y²=x³-x | 0 | 0 | Yes |
| y²=x³-432 | 0 | 0 | Yes |
| y²+y=x³-x | 1 | 1 | Yes |
| y²=x³-4x+4 | 1 | 1 | Yes |
| y²+y=x³+x²-2x | 2 | 2 | Yes (numerically) |
| y²+y=x³-7x+6 | 3 | 3 | Yes (numerically) |

## What We Can Formalize

1. Definition of an elliptic curve over ℚ
2. The group law on elliptic curves
3. Definition of the L-function (formal Euler product)
4. Statement of Mordell's theorem
5. The BSD conjecture as a formal statement
6. Verification for specific curves (computational)
