# Iterated Shadow Geometry of Polynomial Supports

## Abstract

We develop a theory of **iterated support shadows** for multivariate polynomials, proving that the support of all k-th order mixed partial derivatives of a polynomial over a characteristic-zero ring is exactly the k-th combinatorial shadow of its Newton support. The k-th shadow Sh_k(S) of a finite set S ⊆ ℕⁿ consists of all exponent vectors obtainable by subtracting a non-negative multi-index of total mass k from an element of S. Our main result shows that this purely combinatorial operation captures the exact footprint of iterated differentiation, with no spurious cancellations. We prove that the shadow operator satisfies a semigroup law Sh_b(Sh_a(S)) = Sh_{a+b}(S), distributes over unions, and vanishes beyond the maximum degree. We introduce the derivative shadow profile and a discrete exchange property modeled on M-convexity, formulate a log-concavity conjecture for shadow profiles of exchange families, and verify it computationally across extensive test suites including matroid basis supports, simplex supports, and product supports up to 8 variables.

**Keywords:** sparse differentiation, Newton polytope, M-convexity, matroid basis generating polynomial, Lorentzian polynomial, ultra-log-concavity, combinatorial Hodge theory, symbolic computation, algebraic complexity, support dynamics, mixed partial derivatives, discrete convex analysis

---

## 1. Introduction

### 1.1 Motivation

The support of a multivariate polynomial — the set of exponent vectors appearing with nonzero coefficients — is a fundamental combinatorial invariant. Understanding how the support transforms under algebraic operations is central to symbolic computation, Newton polytope theory, and algebraic complexity. For first-order partial derivatives, the support transformation is well-understood: differentiating with respect to xᵢ shifts each exponent vector by -eᵢ (when the relevant coordinate is positive). However, the behavior of iterated mixed partial derivatives of arbitrary order has not been systematically formalized.

### 1.2 Contributions

We make the following contributions:

1. **Definition of the k-th shadow operator** (§2): A finitary combinatorial operation on sets of multi-indices that captures all exponent vectors reachable by subtracting mass-k multi-indices.

2. **Coefficient transport formula** (§3): An explicit formula expressing the coefficient of any monomial in an iterated mixed derivative as a product of ascending factorials times a single original coefficient.

3. **Exact shadow theorem** (§4): The support of the family of all k-th order mixed partial derivatives equals the k-th shadow of the original support, in characteristic zero.

4. **Shadow semigroup law** (§5): Sh_b(Sh_a(S)) = Sh_{a+b}(S), establishing that iterated shadows form a discrete semigroup.

5. **Exchange families and log-concavity** (§6): Introduction of discrete exchange families as a proxy for M-convexity, with computational evidence for log-concavity of shadow profiles.

6. **Machine-verified proofs** (§7): All main theorems are formally verified, providing a foundation for further mechanized developments.

### 1.3 Related Work

The Newton polytope and its role in algebraic geometry are classical (Gelfand–Kapranov–Zelevinsky, 1994). The connection between polynomial supports and combinatorial structures has been explored in the context of Lorentzian polynomials (Brändén–Huh, 2020), where support properties encode deep inequalities. M-convexity and discrete convex analysis were developed by Murota (2003). The specific question of derivative support transport was partially addressed in the context of multiaffine polynomials and matroid theory, but a complete treatment for arbitrary mixed derivatives at arbitrary orders is new.

---

## 2. Definitions and Notation

### 2.1 Multi-indices and supports

Let n ≥ 1. A **multi-index** is an element α ∈ ℕⁿ (equivalently, a finitely supported function Fin n →₀ ℕ). The **total mass** of α is |α| = Σᵢ αᵢ. For a polynomial f ∈ R[x₁,...,xₙ], the **support** is:

    Supp(f) = {α ∈ ℕⁿ : coeff_α(f) ≠ 0}

which is a finite subset of ℕⁿ.

### 2.2 The k-th shadow

**Definition 2.1.** For a finite set S ⊆ ℕⁿ and k ≥ 0, the **k-th shadow** of S is:

    Sh_k(S) = {β ∈ ℕⁿ : ∃ τ ∈ ℕⁿ, |τ| = k ∧ β + τ ∈ S}

Equivalently:

    Sh_k(S) = {α - τ : α ∈ S, τ ≤ α, |τ| = k}

where τ ≤ α means τᵢ ≤ αᵢ for all i.

In the formal development, we implement this as:

```
def kthShadow (S : Finset (Fin n →₀ ℕ)) (k : ℕ) : Finset (Fin n →₀ ℕ) :=
  S.biUnion (fun α =>
    ((Finset.Iic α).filter (fun τ => τ.sum (fun _ m => m) = k)).image (α - ·))
```

### 2.3 Iterated mixed partial derivative

**Definition 2.2.** For a multi-index τ ∈ ℕⁿ, the **iterated mixed partial derivative** is:

    ∂^τ f = ∂₁^{τ₁} ∂₂^{τ₂} ⋯ ∂ₙ^{τₙ} f

Formally, we define `pderivPow i k f` as the k-fold application of `pderiv i` to f, and `iteratedPDeriv τ f` as the composition of `pderivPow i (τ i)` over all variables i.

### 2.4 Derivative shadow profile

**Definition 2.3.** The **derivative shadow profile** of f is the function:

    P_f(k) = |Sh_k(Supp(f))|

recording the size of the k-th shadow.

### 2.5 Discrete exchange family

**Definition 2.4.** A finite set S ⊆ ℕⁿ satisfies the **discrete exchange property** if for all α, β ∈ S and all i with αᵢ > βᵢ, there exists j with βⱼ > αⱼ such that α - eᵢ + eⱼ ∈ S.

This is the symmetric exchange axiom from M-convex set theory (Murota, 2003), adapted to our setting. It captures the fundamental exchange structure of matroid basis sets and generalized permutahedra.

---

## 3. The Coefficient Transport Formula

### 3.1 Single-variable case

**Theorem 3.1** (coeff_pderiv). For any polynomial f, variable i, and multi-index β:

    coeff_β(∂ᵢ f) = (βᵢ + 1) · coeff_{β+eᵢ}(f)

*Proof sketch.* Expand f as a sum of monomials. The derivative of the monomial cα · x^α with respect to xᵢ is cα · αᵢ · x^{α-eᵢ}. Setting β = α - eᵢ gives αᵢ = βᵢ + 1 and the coefficient at β is (βᵢ + 1) · cα. Since different monomials produce contributions at different exponent positions (each β comes from exactly one α = β + eᵢ), there is no cancellation. □

**Theorem 3.2** (coeff_pderivPow). For k-fold differentiation with respect to variable i:

    coeff_β(∂ᵢ^k f) = ascFact(βᵢ + 1, k) · coeff_{β + k·eᵢ}(f)

where ascFact(m, k) = m(m+1)⋯(m+k-1) is the ascending factorial (Pochhammer symbol).

*Proof.* By induction on k. The base case k = 0 is trivial. For the inductive step, apply Theorem 3.1 to ∂ᵢ^k f and use the recurrence ascFact(m, k+1) = m · ascFact(m+1, k). The key observation is that (β + eᵢ)ᵢ = βᵢ + 1 and (β + eᵢ) + k·eᵢ = β + (k+1)·eᵢ, which perfectly aligns the inductive hypothesis. □

### 3.2 Multi-index case

**Theorem 3.3** (coeff_iteratedPDeriv). For the full iterated mixed derivative:

    coeff_β(∂^τ f) = (∏ᵢ ascFact(βᵢ + 1, τᵢ)) · coeff_{β+τ}(f)

*Proof sketch.* We use induction over the list of variables (Fin n), applying Theorem 3.2 at each step. The key technical lemma is that differentiating with respect to variable i does not affect the contribution from other variables j ≠ i: the scalar factor factorizes as a product over variables. This is formalized as `coeff_foldr_pderivPow`, which handles the induction on a list of variables with the nodup property. □

### 3.3 The non-vanishing scalar

**Proposition 3.4** (prod_ascFactorial_pos). For all β, τ ∈ ℕⁿ:

    ∏ᵢ ascFact(βᵢ + 1, τᵢ) > 0

*Proof.* Each factor ascFact(m+1, k) = (m+1)(m+2)⋯(m+k) is a product of positive integers, hence positive. The product of positive numbers is positive. □

This simple positivity result is the critical ingredient: it ensures that the scalar factor in the coefficient transport formula is a nonzero natural number. In characteristic zero, this means the transport map coeff_{β+τ}(f) ↦ coeff_β(∂^τ f) is injective on nonzero values.

---

## 4. The Exact k-th Shadow Theorem

### 4.1 Support criterion

**Corollary 4.1** (coeff_iteratedPDeriv_ne_zero_iff). Over a characteristic-zero domain:

    coeff_β(∂^τ f) ≠ 0  ⟺  coeff_{β+τ}(f) ≠ 0

*Proof.* Forward: if the product of a nonzero scalar and coeff_{β+τ}(f) is nonzero, then coeff_{β+τ}(f) ≠ 0. Backward: if coeff_{β+τ}(f) ≠ 0 and the scalar ∏ᵢ ascFact(βᵢ+1, τᵢ) is nonzero (which it is, by Proposition 3.4, using characteristic zero and no zero divisors to lift from ℕ to R), then the product is nonzero. □

### 4.2 Main theorem

**Theorem 4.2** (mem_kthShadow_iff_exists_iteratedDerivative). Let R be a commutative semiring with no zero divisors and characteristic zero. For any f ∈ R[x₁,...,xₙ] and k ≥ 0:

    β ∈ Sh_k(Supp(f))  ⟺  ∃ τ ∈ ℕⁿ, |τ| = k ∧ β ∈ Supp(∂^τ f)

*Proof.* By Corollary 4.1, β ∈ Supp(∂^τ f) iff coeff_{β+τ}(f) ≠ 0 iff β + τ ∈ Supp(f). The existence of such τ with |τ| = k is exactly the definition of β ∈ Sh_k(Supp(f)). □

### 4.3 Interpretation

The theorem says:
- **No missing monomials:** every combinatorially admissible exponent vector actually appears in some derivative (no accidental cancellations).
- **No extra monomials:** every exponent vector in a derivative can be traced to an ancestor in the original support (derivatives don't create structure from nothing).

This is the "exact combinatorial footprint" property: iterated differentiation is governed precisely by the shadow operator.

---

## 5. The Shadow Semigroup Law

### 5.1 Statement and proof

**Theorem 5.1** (kthShadow_add). For any finite S ⊆ ℕⁿ and a, b ≥ 0:

    Sh_b(Sh_a(S)) = Sh_{a+b}(S)

*Proof sketch.*

**Forward (⊆):** If β ∈ Sh_b(Sh_a(S)), there exist τ₂ with |τ₂| = b and β + τ₂ ∈ Sh_a(S), and τ₁ with |τ₁| = a and (β + τ₂) + τ₁ ∈ S. Setting τ = τ₂ + τ₁, we get |τ| = a + b and β + τ ∈ S, so β ∈ Sh_{a+b}(S).

**Backward (⊇):** If β ∈ Sh_{a+b}(S), there exists τ with |τ| = a + b and β + τ ∈ S. We need to decompose τ into τ₁ + τ₂ with |τ₁| = a and |τ₂| = b. This is possible by the lemma `Finsupp.exists_le_degree_eq`, which states that any finitely supported function of degree d has a sub-function of any prescribed degree d' ≤ d. Given such a decomposition, β + τ₂ ∈ Sh_a(S) (witnessed by τ₁) and β ∈ Sh_b(Sh_a(S)) (witnessed by τ₂). □

### 5.2 Consequences

The semigroup law has several important consequences:

1. **Recursive shadow computation:** Sh_k(S) = Sh_1(Sh_{k-1}(S)), so the k-th shadow can be computed by iterating the 1-step shadow.

2. **Associativity:** The shadow operator forms a commutative semigroup under composition, parameterized by the natural numbers under addition.

3. **Monotonicity base:** Combined with the trivial observation Sh_1(T) ⊇ Sh_1(T') whenever T ⊇ T', the semigroup law implies that the shadow profile is eventually non-increasing (once the shadow starts shrinking, it cannot grow again at deeper levels).

---

## 6. Additional Structural Properties

### 6.1 Boundary behavior

**Theorem 6.1** (kthShadow_zero). Sh_0(S) = S.

**Theorem 6.2** (kthShadow_eq_empty_of_lt_degree). If every element of S has degree less than k, then Sh_k(S) = ∅.

### 6.2 Union compatibility

**Theorem 6.3** (kthShadow_union). Sh_k(S₁ ∪ S₂) = Sh_k(S₁) ∪ Sh_k(S₂).

This says the shadow operator distributes over unions, making it a finitary lattice morphism. This is crucial for decomposing shadow computations and for connecting to the polynomial algebra (since Supp(f + g) ⊆ Supp(f) ∪ Supp(g)).

### 6.3 Monotonicity

**Theorem 6.4** (kthShadow_mono). If S₁ ⊆ S₂, then Sh_k(S₁) ⊆ Sh_k(S₂).

### 6.4 Recursive structure

**Theorem 6.5** (kthShadow_succ_eq). Sh_{k+1}(S) = Sh_k(Sh_1(S)).

This follows immediately from the semigroup law and commutativity of addition.

---

## 7. Exchange Families and the Log-Concavity Conjecture

### 7.1 Exchange families

We define discrete exchange families (Definition 2.4) as a formalization of the M-convex exchange property. Key properties verified:

- Singleton sets are exchange families (vacuously).
- The empty set is an exchange family.
- Uniform matroid basis supports are exchange families.

### 7.2 Shadow profile computations

We computed shadow profiles for extensive families of supports:

| Family | |S| | Profile | Log-concave | Ratio-monotone |
|--------|-----|---------|-------------|----------------|
| U(2,4) | 6 | [6, 4, 1] | ✓ | ✓ |
| U(3,5) | 10 | [10, 10, 5, 1] | ✓ | ✓ |
| U(2,6) | 15 | [15, 6, 1] | ✓ | ✓ |
| U(3,6) | 20 | [20, 15, 6, 1] | ✓ | ✓ |
| Δ(3,3) | 10 | [10, 6, 3, 1] | ✓ | ✓ |
| Δ(4,2) | 10 | [10, 4, 1] | ✓ | ✓ |
| Prod[2,2,2] | 27 | [27, 26, 23, 17, 10, 4, 1] | ✓ | ✓ |
| Prod[3,2,1] | 24 | [24, 23, 20, 15, 9, 4, 1] | ✓ | ✓ |

### 7.3 The conjecture

**Conjecture 7.1** (Shadow Log-Concavity for Exchange Supports). If S is a discrete exchange family, then the shadow profile sequence a_k = |Sh_k(S)| is log-concave:

    a_k² ≥ a_{k-1} · a_{k+1}  for all admissible k.

**Computational evidence.** We tested this conjecture on:
- All uniform matroid basis supports U(r,n) for n ≤ 8, r ≤ n
- All simplex supports Δ(n,d) for n ≤ 5, d ≤ 5
- Product simplex supports for dimensions up to [4,4,3]

Total: 58+ exchange families tested, **0 counterexamples found**.

### 7.4 Connection to Lorentzian polynomials

If S is the support of a Lorentzian polynomial (Brändén–Huh, 2020), then the Hessian conditions already imply certain positivity properties of the coefficients. The shadow profile in this case should satisfy log-concavity as a consequence of the Hodge–Riemann relations. Our conjecture extends this prediction to all M-convex sets, regardless of whether they arise as Lorentzian supports.

---

## 8. Algorithms

### 8.1 Shadow computation

**Algorithm 1: kth_shadow(S, k)**
```
Input: Finite set S ⊂ ℕⁿ, integer k ≥ 0
Output: Sh_k(S)
1. Initialize result ← ∅
2. For each α ∈ S:
3.   For each τ ∈ ℕⁿ with |τ| = k and τ ≤ α:
4.     result ← result ∪ {α - τ}
5. Return result
```

**Complexity:** O(|S| · C(n+k-1, k) · n) time, where C(n+k-1, k) is the number of weak compositions of k into n parts.

### 8.2 Shadow profile computation

**Algorithm 2: shadow_profile(S)**
```
Input: Finite set S ⊂ ℕⁿ
Output: Sequence [a_0, a_1, ..., a_D] where D = max degree
1. D ← max{|α| : α ∈ S}
2. For k = 0, 1, ..., D:
3.   a_k ← |kth_shadow(S, k)|
4. Return [a_0, ..., a_D]
```

### 8.3 Verification algorithm

**Algorithm 3: verify_shadow_theorem(f, k)**
```
Input: Polynomial f ∈ R[x₁,...,xₙ], integer k ≥ 0
Output: Boolean (True if theorem verified)
1. S ← Supp(f)
2. shadow ← kth_shadow(S, k)
3. deriv_supp ← ∅
4. For each τ ∈ ℕⁿ with |τ| = k:
5.   deriv_supp ← deriv_supp ∪ Supp(∂^τ f)
6. Return shadow = deriv_supp
```

---

## 9. Computational Experiments

### 9.1 Shadow theorem verification

We verified the exact shadow theorem on polynomials in 2-4 variables with up to 10 terms and total degree up to 6. In every case, the shadow and derivative support agree exactly.

Example: f(x,y,z) = 3x²y - z³ + 5xy² + 2x³

| k | |Sh_k(Supp(f))| | |⋃_{|τ|=k} Supp(∂^τ f)| | Match |
|---|-----------------|-------------------------|-------|
| 0 | 4 | 4 | ✓ |
| 1 | 4 | 4 | ✓ |
| 2 | 3 | 3 | ✓ |
| 3 | 1 | 1 | ✓ |

### 9.2 Shadow composition verification

The semigroup law Sh_b(Sh_a(S)) = Sh_{a+b}(S) was verified for simplex supports Δ(3,4) across all pairs (a,b) with a + b ≤ 4.

### 9.3 Log-concavity testing

No counterexamples to the log-concavity conjecture were found across all tested exchange families (58+ examples). The stronger ratio-monotonicity property also held universally.

---

## 10. Discussion

### 10.1 Significance

The exact k-th shadow theorem upgrades the well-known first-derivative support transport from a one-step observation to a complete hierarchy of derivative shadows. The key insight is that the "no cancellation" property (each derivative coefficient is an explicit nonzero multiple of a single original coefficient) extends perfectly to all orders and all mixed derivatives.

### 10.2 Limitations

- The theorem requires characteristic zero (positive characteristic can create cancellations via the scalar factor).
- The log-concavity conjecture is purely computational evidence; a proof would likely require deep connections to Hodge theory or representation theory.
- The shadow computation is exponential in k for fixed n, though this matches the intrinsic combinatorial complexity.

### 10.3 Open problems

1. Prove the log-concavity conjecture for matroid basis supports.
2. Determine whether the shadow profile of an M-convex set determines the set up to symmetry.
3. Establish connections between shadow decay rates and algebraic complexity measures.
4. Develop a tropical analogue of the shadow theorem.
5. Characterize which sequences arise as shadow profiles.

---

## 11. Future Work

The theory developed here opens several specific research programs:

1. **Shadow Hodge theory:** Develop intersection-theoretic tools to prove log-concavity of shadow profiles, potentially using the Kähler package of Adiprasito–Huh–Katz.

2. **Tropical shadow calculus:** Extend the shadow operator to tropical varieties and develop tropical differential invariants.

3. **Algorithmic applications:** Use shadow profiles for fast sparsity prediction in automatic differentiation systems.

4. **Circuit complexity:** Investigate whether shadow decay rates yield lower bounds on algebraic circuit size.

5. **Statistical physics:** Apply shadow geometry to analyze the observable structure of lattice models.

---

## References

1. Brändén, P., Huh, J. (2020). Lorentzian polynomials. *Annals of Mathematics*, 192(3), 821-891.

2. Murota, K. (2003). *Discrete Convex Analysis*. SIAM Monographs on Discrete Mathematics.

3. Adiprasito, K., Huh, J., Katz, E. (2018). Hodge theory for combinatorial geometries. *Annals of Mathematics*, 188(2), 381-452.

4. Gelfand, I. M., Kapranov, M. M., Zelevinsky, A. V. (1994). *Discriminants, Resultants, and Multidimensional Determinants*. Birkhäuser.

5. Huh, J. (2022). Combinatorics and Hodge theory. *Proceedings of the ICM 2022*.
