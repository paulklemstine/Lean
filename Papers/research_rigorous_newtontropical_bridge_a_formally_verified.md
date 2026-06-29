# The Newton–Tropical Bridge: From Polynomial Valuations to Divisibility Certificates

## Abstract

We establish a rigorous bridge between the Newton polygon of a polynomial — the convex hull data derived from coefficient valuations — and tropical polynomial evaluation, proving that the p-adic valuation of a polynomial's value is always bounded below by its tropical evaluation under the Newton profile. The central result, the Root–Valuation Bridge Theorem, states that for any ultrametric valuation v on a commutative ring R and polynomial f = Σ aᵢxⁱ, the inequality v(f(a)) ≥ T_f(v(a)) holds, where T_f(t) = minᵢ(v(aᵢ) + i·t) is the tropical evaluation. We extend the ultrametric inequality from pairs to finite sums, prove concavity of the tropical evaluation function, introduce slope certificates for exact dominant-term identification, and derive divisibility depth certificates as a cryptographic application. All results are formally verified in Lean 4 with Mathlib.

**Keywords:** Newton polygon, tropical geometry, ultrametric valuation, divisibility certificate, formal verification

---

## 1. Introduction

### 1.1 Background

The Newton polygon of a polynomial f(x) = Σᵢ aᵢxⁱ over a valued field (K, v) is the lower convex hull of the points {(i, v(aᵢ))}. Since Newton's 1676 letter to Oldenburg, this construction has been fundamental in p-adic analysis and algebraic number theory, providing information about the valuations of roots of f.

Tropical geometry replaces the operations (×, +) with (+, min) in the "tropical semiring" (ℝ ∪ {∞}, min, +). Under this replacement, a polynomial f = Σ aᵢxⁱ becomes the tropical polynomial T_f(t) = minᵢ(v(aᵢ) + i·t), which is a piecewise-linear concave function whose breakpoints encode the slopes of the Newton polygon.

### 1.2 Contributions

We make the following contributions:

1. **Ultrametric Sum Inequality** (Theorem 3.1): Extension of the ultrametric inequality from binary to n-ary sums over arbitrary finite index sets.

2. **Root–Valuation Bridge Theorem** (Theorem 4.1): The fundamental inequality v(f(a)) ≥ T_f(v(a)) connecting polynomial evaluation with tropical evaluation.

3. **Slope Certificate Framework** (Definition 5.1, Theorem 5.2): A formal mechanism for certifying when the tropical bound is tight — when a single term dominates the sum.

4. **Concavity Theorem** (Theorem 6.1): The tropical evaluation function is concave, being the infimum of affine functions.

5. **Divisibility Depth Certificate** (Theorem 7.1): Application of the bridge theorem to divisibility verification.

6. **Monotonicity and Boundary Theorems** (Theorems 8.1–8.3): Structural properties of tropical evaluation under profile modifications.

### 1.3 Related Work

The relationship between Newton polygons and tropical geometry is well-known in the algebraic geometry community (Maclagan–Sturmfels [1], Mikhalkin [2]). However, to our knowledge, the specific formulation of the bridge theorem as a valuation inequality for polynomial evaluation, together with its formal verification, is new. The slope certificate concept connects to the theory of dominant terms in non-archimedean analysis (Gouvêa [3]).

---

## 2. Preliminaries

### 2.1 Ultrametric Valuations

**Definition 2.1** (UltrametricFn). An *ultrametric function* on a commutative ring R is a function v: R → ℝ satisfying:
- (Multiplicativity) v(xy) = v(x) + v(y) for all x, y ∈ R
- (Ultrametric inequality) v(x + y) ≥ min(v(x), v(y)) for all x, y ∈ R

Note: We use the additive convention where larger values indicate greater divisibility. The p-adic valuation vₚ is the prototypical example, with vₚ(pⁿm) = n when gcd(m, p) = 1.

**Theorem 2.2** (Power Rule). For any ultrametric function v and natural number n:
v(xⁿ) = n · v(x)

*Proof sketch.* By induction on n. Base case: v(x⁰) = v(1) = 0 (from v(1·1) = v(1) + v(1)). Inductive step: v(x^{n+1}) = v(x · xⁿ) = v(x) + v(xⁿ) = v(x) + n·v(x) = (n+1)·v(x). □

### 2.2 Tropical Polynomials

**Definition 2.3** (Newton Profile). A *Newton profile of degree n* is a function p: Fin(n+1) → ℝ, representing the valuations (v(a₀), v(a₁), ..., v(aₙ)) of a polynomial's coefficients.

**Definition 2.4** (Tropical Term). The *tropical term* at index i for profile p and evaluation point t is:
Tᵢ(t) = p(i) + i · t

**Definition 2.5** (Tropical Evaluation). The *tropical evaluation* of profile p at point t is:
T_p(t) = minᵢ Tᵢ(t) = minᵢ (p(i) + i · t)

This is computed as `Finset.univ.inf'` over the finite type `Fin(n+1)`.

---

## 3. The Ultrametric Sum Inequality

**Theorem 3.1** (Ultrametric Finset Sum). Let v be an ultrametric function on R, s a nonempty finite set, and f: s → R. Then:

v(Σᵢ∈s f(i)) ≥ inf'ᵢ∈s v(f(i))

*Proof.* By induction on the construction of s using `Finset.Nonempty.cons_induction`.

**Base case:** s = {a}. Then Σᵢ∈{a} f(i) = f(a) and inf'ᵢ∈{a} v(f(i)) = v(f(a)), so equality holds.

**Inductive step:** s = {b} ∪ s' with b ∉ s'. Then:
- Σᵢ∈s f(i) = f(b) + Σᵢ∈s' f(i)
- By ultrametric: v(f(b) + Σᵢ∈s' f(i)) ≥ min(v(f(b)), v(Σᵢ∈s' f(i)))
- By IH: v(Σᵢ∈s' f(i)) ≥ inf'ᵢ∈s' v(f(i))
- Therefore: v(Σᵢ∈s f(i)) ≥ min(v(f(b)), inf'ᵢ∈s' v(f(i))) = inf'ᵢ∈s v(f(i)) □

This theorem is the key technical ingredient for the bridge theorem.

---

## 4. The Root–Valuation Bridge Theorem

**Theorem 4.1** (Newton–Tropical Bridge). For any ultrametric function v on a commutative ring R, coefficients (a₀, ..., aₙ) ∈ Rⁿ⁺¹, and element a ∈ R:

v(Σᵢ aᵢ · aⁱ) ≥ T_p(v(a))

where p(i) = v(aᵢ) is the Newton profile.

*Proof.* Apply Theorem 3.1 to the sum Σᵢ aᵢ · aⁱ:

v(Σᵢ aᵢ · aⁱ) ≥ minᵢ v(aᵢ · aⁱ)

For each term:
v(aᵢ · aⁱ) = v(aᵢ) + v(aⁱ)     (multiplicativity)
             = v(aᵢ) + i · v(a)   (power rule)
             = Tᵢ(v(a))           (definition of tropical term)

Therefore:
minᵢ v(aᵢ · aⁱ) = minᵢ Tᵢ(v(a)) = T_p(v(a)) □

The proof elegantly combines all three components: the ultrametric sum inequality, multiplicativity, and the power rule.

---

## 5. Slope Certificates

**Definition 5.1** (Slope Certificate). A *slope certificate* for profile p at point t consists of:
- A dominant index k ∈ Fin(n+1)
- A positive gap δ > 0
- Proof that Tₖ(t) ≤ Tⱼ(t) for all j (minimality)
- Proof that Tⱼ(t) ≥ Tₖ(t) + δ for all j ≠ k (strict gap)

The slope certificate is a computational witness that the k-th term strictly dominates.

**Theorem 5.2** (Certificate Exactness). If a slope certificate exists for profile p at point t, then:

T_p(t) = Tₖ(t) = p(k) + k · t

*Proof.* The tropical evaluation T_p(t) = inf'ᵢ Tᵢ(t). Since k is the index achieving the minimum (by `is_min`), we have inf'ᵢ Tᵢ(t) ≤ Tₖ(t) (by `Finset.inf'_le`). Conversely, Tₖ(t) ≤ Tⱼ(t) for all j implies Tₖ(t) ≤ inf'ᵢ Tᵢ(t) (by `Finset.le_inf'`). By antisymmetry, equality holds. □

**Remark.** The strict gap condition is stronger than needed for Theorem 5.2, but it is essential for stability: it ensures that small perturbations of the profile or evaluation point do not change which term is dominant. This robustness property is critical for cryptographic applications.

---

## 6. Concavity of Tropical Evaluation

**Theorem 6.1** (Tropical Concavity). For any Newton profile p, the function t ↦ T_p(t) is concave:

T_p(w₁t₁ + w₂t₂) ≥ w₁ · T_p(t₁) + w₂ · T_p(t₂)

for all t₁, t₂ ∈ ℝ and w₁, w₂ ≥ 0 with w₁ + w₂ = 1.

*Proof.* For each index i:
- Tᵢ(w₁t₁ + w₂t₂) = p(i) + i·(w₁t₁ + w₂t₂)
  = w₁·(p(i) + i·t₁) + w₂·(p(i) + i·t₂)     (using w₁ + w₂ = 1)
  = w₁·Tᵢ(t₁) + w₂·Tᵢ(t₂)
  ≥ w₁·T_p(t₁) + w₂·T_p(t₂)                  (since Tᵢ(t) ≥ T_p(t))

Since every term in the infimum is ≥ w₁·T_p(t₁) + w₂·T_p(t₂), the infimum itself is ≥ this value. □

**Corollary.** The epigraph {(t, y) : y ≤ T_p(t)} is a convex set, making optimization over tropical evaluation domains amenable to convex programming.

---

## 7. Divisibility Depth Certificates

**Theorem 7.1** (Divisibility Certificate). If v(aᵢ) + i · v(a) ≥ k for all i, then v(f(a)) ≥ k.

*Proof.* By the bridge theorem (4.1), v(f(a)) ≥ T_p(v(a)) = minᵢ(v(aᵢ) + i·v(a)) ≥ k. □

**Application.** Let R = ℤ, v = vₚ (p-adic valuation). The certificate states: if each coefficient aᵢ and the evaluation point a are such that vₚ(aᵢ) + i · vₚ(a) ≥ k, then pᵏ | f(a). This converts a divisibility claim about the (possibly large) number f(a) into simple arithmetic on exponents.

---

## 8. Structural Properties

**Theorem 8.1** (Boundary Value). T_p(0) = minᵢ p(i), the minimum coefficient valuation.

**Theorem 8.2** (Monotonicity). If p(i) ≤ q(i) for all i and t ≥ 0, then T_p(t) ≤ T_q(t).

**Theorem 8.3** (Upper Bound). If 0 ≤ p(i) ≤ B for all i and 0 ≤ t ≤ B, then T_p(t) ≤ (n+1)·B.

---

## 9. Algorithms

### 9.1 Tropical Evaluation Algorithm

```
Input: Profile p[0..n], point t
Output: T_p(t)

min_val ← p[0]
for i = 1 to n:
    val ← p[i] + i * t
    if val < min_val:
        min_val ← val
return min_val
```

Time complexity: O(n). Space complexity: O(1).

### 9.2 Slope Certificate Verification

```
Input: Profile p[0..n], point t, claimed dominant index k
Output: (valid, gap)

dom_val ← p[k] + k * t
gap ← ∞
for i = 0 to n:
    if i ≠ k:
        diff ← (p[i] + i * t) - dom_val
        if diff < 0:
            return (false, 0)
        gap ← min(gap, diff)
return (gap > 0, gap)
```

### 9.3 Divisibility Certificate Generation

```
Input: Coefficient valuations v[0..n], point valuation v_a, target depth k
Output: Certificate or FAIL

for i = 0 to n:
    if v[i] + i * v_a < k:
        return FAIL
return Certificate(v, v_a, k)
```

---

## 10. Discussion

### 10.1 Relationship to Classical Results

The bridge theorem can be seen as a quantitative refinement of classical Newton polygon theory. While the classical theory relates the *slopes* of the Newton polygon to the *valuations of roots*, our bridge theorem relates the *tropical evaluation* (which encodes both slopes and intercepts) to the *valuation of polynomial values*. This is strictly more information: knowing v(f(a)) for all a determines the root valuations (via f(a) = 0), but the bridge theorem applies even when a is not a root.

### 10.2 The Role of the Ultrametric Inequality

The ultrametric inequality is the sole non-trivial input from the valuation theory; multiplicativity and the power rule are algebraic consequences. The fact that our bridge theorem requires *only* these three properties (and not, for example, the full structure of a valued field) means it applies in settings beyond classical p-adic analysis — for example, to Krull valuations, to valuations on function fields, and to non-archimedean norms on Banach algebras.

### 10.3 Formal Verification

All results have been formalized in Lean 4 using the Mathlib library. The formalization follows the mathematical development closely, with the key definitions (`UltrametricFn`, `NewtonProfile`, `tropEval`, `SlopeCertificate`) and all theorems verified by the Lean type checker. The proofs use standard Mathlib tactics including `induction`, `simp`, `nlinarith`, and `grind`.

---

## 11. Future Work

1. **Multivariate Extension**: Replace Fin(n+1) → ℝ with (Fin d → ℕ) → ℝ (multi-index profiles) and prove the multivariate bridge theorem using Newton polytopes.

2. **Tropical Helly Composition**: Combine with tropical Helly-type theorems to derive simultaneous divisibility results for families of polynomials.

3. **Hensel Lifting Integration**: Use slope certificates to automate Hensel's lemma applications, producing certified p-adic root approximations.

4. **Quantitative Tightness**: Characterize when the bridge inequality is tight in terms of the Newton polygon's combinatorial structure.

---

## References

[1] D. Maclagan and B. Sturmfels, *Introduction to Tropical Geometry*, Graduate Studies in Mathematics, vol. 161, AMS, 2015.

[2] G. Mikhalkin, "Enumerative tropical algebraic geometry in ℝ²," *J. Amer. Math. Soc.* 18 (2005), 313–377.

[3] F. Q. Gouvêa, *p-adic Numbers: An Introduction*, 2nd ed., Universitext, Springer, 1997.

[4] J.-P. Serre, *Local Fields*, Graduate Texts in Mathematics, vol. 67, Springer, 1979.

[5] M. Baker and S. Norine, "Riemann–Roch and Abel–Jacobi theory on a finite graph," *Advances in Mathematics* 215 (2007), 766–788.
