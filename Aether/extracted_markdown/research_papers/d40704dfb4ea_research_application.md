# Certified Polynomial Method Infrastructure: From Schwartz–Zippel to Dvir's Finite-Field Kakeya Theorem

## Abstract

We present a complete, machine-verified formalization of the polynomial method over finite fields, culminating in two major theorems: the multivariate Schwartz–Zippel lemma and Dvir's finite-field Kakeya theorem. The development is organized as a layered algebraic infrastructure — from univariate root counting, through multivariate vanishing, affine line restriction, to the Kakeya impossibility principle — with each layer providing reusable building blocks for future formalization of results in additive combinatorics, coding theory, and computational complexity. All proofs are fully verified with no axioms beyond the standard foundations of mathematics.

**Key contributions:**
1. A verified multivariate Schwartz–Zippel bound: any nonzero polynomial of total degree *d* over GF(q) has at most *d* · *q*^(*n*−1) zeros in GF(q)^*n*.
2. A verified point-hypersurface incidence bound as a corollary.
3. A verified definition of affine line restriction with degree and evaluation lemmas.
4. A verified proof of Dvir's theorem: no nonzero polynomial of degree < *q* can vanish on a Kakeya set in GF(q)^*n*.

## 1. Introduction

### 1.1 Background and Motivation

The polynomial method is a powerful paradigm in combinatorics and theoretical computer science. It converts geometric and combinatorial problems into algebraic statements about polynomials, then resolves them using degree bounds and vanishing arguments. The method has yielded breakthroughs in:

- **Kakeya problems** over finite fields (Dvir, 2008)
- **Cap set bounds** (Croot–Lev–Pach, 2016; Ellenberg–Gijswijt, 2017)
- **Incidence geometry** (Guth–Katz, 2015)
- **Coding theory** (Reed–Muller codes, list decoding)
- **Pseudorandomness** (extractors, mergers)

Despite this importance, no comprehensive verified formalization of the polynomial method existed. Individual polynomial lemmas exist in proof libraries, but the *systematic pipeline* — from vanishing bounds through line restrictions to impossibility results — had not been assembled into a certified algebraic infrastructure.

### 1.2 Related Work

The Schwartz–Zippel lemma was independently discovered by Schwartz (1980) and Zippel (1979), with earlier partial results by DeMillo and Lipton (1978). Dvir's proof of the finite-field Kakeya conjecture (2008) was a landmark application of the polynomial method that resolved a conjecture of Wolff (1999).

In the formal verification community, Mathlib (the Lean 4 mathematics library) contains extensive polynomial algebra, including `MvPolynomial`, `Polynomial`, and the `finSuccEquiv` equivalence between (n+1)-variate and univariate-over-n-variate polynomials. Our work builds on this infrastructure.

### 1.3 Overview of Results

Our formalization consists of four layers:

| Layer | File | Key Result |
|-------|------|------------|
| 1 | `UnivariateVanishing.lean` | `polynomial_eq_zero_of_eval_eq_zero_all` |
| 2 | `MultivariateVanishing.lean` | `mvpolynomial_eq_zero_of_eval_eq_zero` |
| 3 | `LineRestriction.lean` | `restrictAffineLine`, `natDegree_restrictAffineLine_le_totalDegree` |
| 4 | `Dvir.lean` | `no_low_degree_polynomial_vanishing_on_kakeya` |
| 5 | `SchwartzZippel.lean` | `mvpolynomial_zero_set_card_le_totalDegree_mul_pow` |

## 2. Definitions and Notation

### 2.1 Finite Fields and Polynomial Spaces

We work over an arbitrary finite field K with |K| = q. Our polynomials live in `MvPolynomial (Fin n) K`, the space of polynomials in n indexed variables with coefficients in K. The *total degree* of a polynomial is the maximum sum of exponents over all monomials in its support.

### 2.2 Kakeya Sets

**Definition.** A subset E ⊆ K^n is a *Kakeya set* if for every nonzero direction vector v ∈ K^n \ {0}, there exists a base point x ∈ K^n such that the entire affine line {x + tv : t ∈ K} lies in E.

Formally:
```
def IsKakeyaSet {K : Type*} [Field K] {n : ℕ} (E : Set (Fin n → K)) : Prop :=
  ∀ v : Fin n → K, v ≠ 0 → ∃ x : Fin n → K, ∀ t : K, x + t • v ∈ E
```

### 2.3 Affine Line Restriction

**Definition.** Given a polynomial f ∈ K[X₁, ..., Xₙ] and vectors x, v ∈ K^n, the *affine line restriction* is the univariate polynomial g(T) = f(x + Tv) obtained by substituting Xᵢ ↦ xᵢ + vᵢT.

```
def restrictAffineLine {K : Type*} [CommRing K] {n : ℕ}
    (f : MvPolynomial (Fin n) K) (x v : Fin n → K) : Polynomial K :=
  MvPolynomial.aeval (fun i => Polynomial.C (x i) + Polynomial.C (v i) * Polynomial.X) f
```

## 3. Main Results

### 3.1 Univariate Vanishing (Layer 1)

**Theorem 1** (`polynomial_eq_zero_of_eval_eq_zero_all`). *Let p ∈ K[T] be a polynomial with natDegree(p) < |K|. If p(a) = 0 for every a ∈ K, then p = 0.*

*Proof.* Immediate from Mathlib's `Polynomial.eq_zero_of_degree_lt_of_eval_finset_eq_zero` applied to `Finset.univ`. □

### 3.2 Multivariate Vanishing (Layer 2)

**Lemma 2** (`totalDegree_coeff_finSuccEquiv_le`). *For f ∈ K[X₀, ..., Xₙ], the total degree of the i-th coefficient of `finSuccEquiv f` (viewed as a univariate polynomial in X₀ over K[X₁,...,Xₙ]) is at most the total degree of f.*

*Proof.* By the characterization `finSuccEquiv_coeff_coeff`: if a monomial m appears in the i-th coefficient, then `Finsupp.cons i m` appears in the support of f. Since `degree(Finsupp.cons i m) = i + degree(m) ≤ totalDegree(f)`, we get `degree(m) ≤ totalDegree(f) - i ≤ totalDegree(f)`. □

**Theorem 3** (`mvpolynomial_eq_zero_of_eval_eq_zero`). *Let f ∈ K[X₁, ..., Xₙ] with totalDegree(f) < |K|. If f(x) = 0 for every x ∈ K^n, then f = 0.*

*Proof.* By induction on n.

**Base case (n = 0):** `MvPolynomial (Fin 0) K ≅ K` via `isEmptyAlgEquiv`. Since `Fin 0 → K` has exactly one element, f is a constant that evaluates to zero, hence f = 0.

**Inductive step (n → n+1):** Use `finSuccEquiv K n` to write f as p ∈ K[T][X₁,...,Xₙ]. By `eval_eq_eval_mv_eval'`, for any a ∈ K^n and y ∈ K:

    eval(cons(y, a), f) = eval(y, map(eval_a, p))

Since f vanishes everywhere, for each fixed a, the univariate polynomial `map(eval_a, p)` vanishes at all y ∈ K. Its degree is at most `natDegree(p) ≤ degreeOf(0, f) ≤ totalDegree(f) < |K|`. By the univariate vanishing theorem, `map(eval_a, p) = 0`.

This means each coefficient cᵢ of p, evaluated at a, gives zero. Since a was arbitrary, cᵢ vanishes on all of K^n. By Lemma 2, `totalDegree(cᵢ) ≤ totalDegree(f) < |K|`. By the inductive hypothesis, cᵢ = 0 for all i.

Hence p = 0, so f = 0 (by injectivity of `finSuccEquiv`). □

### 3.3 Affine Line Restriction (Layer 3)

**Theorem 4** (`eval_restrictAffineLine'`). *For all t ∈ K:*
    *eval(t, restrictAffineLine(f, x, v)) = eval(x + t·v, f)*

*Proof.* By functoriality of `eval₂` and the ring homomorphism property of polynomial evaluation. The key identity is `eval₂_comp_left`: composing eval₂ with a ring homomorphism distributes over the substitution. □

**Theorem 5** (`natDegree_restrictAffineLine_le_totalDegree`). *natDegree(restrictAffineLine(f, x, v)) ≤ totalDegree(f).*

*Proof.* Write f as a sum of monomials. Each monomial c_m · ∏ Xᵢ^{mᵢ} maps to c_m · ∏(C(xᵢ) + C(vᵢ)·T)^{mᵢ}. The natDegree of each factor (C(xᵢ) + C(vᵢ)·T)^{mᵢ} is at most mᵢ (bounded by natDegree_pow_le and the fact that C(x) + C(v)·T has degree ≤ 1). So the product has degree ≤ ∑mᵢ = degree(m). Taking the sum over monomials and using natDegree_sum_le gives the bound. □

### 3.4 Homogeneous Component Analysis (Layer 4)

**Theorem 6** (`homogeneousComponent_totalDegree_ne_zero`). *If f ≠ 0, then `homogeneousComponent(totalDegree(f), f) ≠ 0`.*

*Proof.* Since f ≠ 0, its support is nonempty. The total degree equals the supremum of monomial degrees over the support, so there exists some monomial d₀ with `degree(d₀) = totalDegree(f)`. This monomial appears in `homogeneousComponent(totalDegree(f), f)` with nonzero coefficient. □

**Theorem 7** (`coeff_top_restrictAffineLine`). *The coefficient of T^d in restrictAffineLine(f, x, v), where d = totalDegree(f), equals eval(v, homogeneousComponent(d, f)).*

*Proof.* For each monomial c_m · ∏ Xᵢ^{mᵢ} with degree(m) = ∑mᵢ:
- If degree(m) < d: the image has degree < d, contributing 0 to the T^d coefficient.
- If degree(m) = d: the coefficient of T^d in ∏(C(xᵢ) + C(vᵢ)·T)^{mᵢ} is ∏vᵢ^{mᵢ} (the leading coefficient, extracting the top power of T from each binomial factor).

Summing c_m · ∏vᵢ^{mᵢ} over monomials with degree = d gives exactly eval(v, homogeneousComponent(d, f)). □

### 3.5 Dvir's Theorem (Layer 4)

**Theorem 8** (`no_low_degree_polynomial_vanishing_on_kakeya`). *Let n ≥ 1, let E ⊆ K^n be a Kakeya set, and let f ∈ K[X₁,...,Xₙ] with totalDegree(f) < |K|. If f vanishes on E, then f = 0.*

*Proof.* Assume for contradiction that f ≠ 0. Let d = totalDegree(f).

**Step 1 (Direction vanishing):** For each nonzero v ∈ K^n, by the Kakeya property, there exists x₀ such that ∀t: x₀ + tv ∈ E. Since f vanishes on E, restrictAffineLine(f, x₀, v) evaluates to 0 at all t ∈ K. By Theorem 5, its degree is ≤ d < |K|. By Theorem 1, it is the zero polynomial. By Theorem 7, the coefficient of T^d is eval(v, homogeneousComponent(d, f)) = 0.

**Step 2 (Zero evaluation):** The polynomial h_d = homogeneousComponent(d, f) is homogeneous of degree d. If d > 0, then eval(0, h_d) = 0 (since every monomial of positive degree vanishes at the origin). If d = 0, f is a constant; since n ≥ 1, there exist nonzero directions, hence E is nonempty (it contains a full line), so f vanishes at some point, forcing the constant to be zero — contradicting f ≠ 0.

**Step 3 (Global vanishing):** Combining Steps 1 and 2, h_d vanishes at every point of K^n. By Theorem 6, if f ≠ 0 then h_d ≠ 0. But h_d is a polynomial of total degree ≤ d < |K| that vanishes everywhere. By Theorem 3, h_d = 0. Contradiction. □

### 3.6 Schwartz–Zippel Lemma (Layer 5)

**Theorem 9** (`mvpolynomial_zero_set_card_le_totalDegree_mul_pow`). *Let f ∈ K[X₁,...,Xₙ] be nonzero with total degree d. Then*

    |{x ∈ K^n : f(x) = 0}| ≤ d · |K|^{n-1}.

*Proof.* By induction on n, using `finSuccEquiv` to decompose the polynomial and partition the zero set into fibers. For each assignment a ∈ K^{n-1} of the last n-1 variables, the fiber contributes at most natDegree(p) zeros (when the specialized univariate polynomial is nonzero) or |K| zeros (when it is zero). The set of "bad" assignments is controlled by the zero set of the leading coefficient, which has degree ≤ d - natDegree(p), and is bounded by the inductive hypothesis.

The total is bounded by:
    (d - natDeg(p)) · |K|^{n-2} · |K| + |K|^{n-1} · natDeg(p) = d · |K|^{n-1}. □

**Corollary 10** (`point_hypersurface_incidence_bound`). *For S ⊆ K^n and nonzero f of degree d:*

    |{x ∈ S : f(x) = 0}| ≤ min(|S|, d · |K|^{n-1}).

## 4. Algorithms and Computational Experiments

### 4.1 Schwartz–Zippel Identity Testing

**Input:** A polynomial f represented as a black-box, degree bound d, field GF(q).
**Output:** "ZERO" or "NONZERO" with error probability ≤ d/q per trial.

```
Algorithm SchwartzZippelTest(f, d, q, num_trials):
    for i = 1 to num_trials:
        sample random point x ∈ GF(q)^n
        if f(x) ≠ 0:
            return NONZERO
    return ZERO (with confidence 1 - (d/q)^num_trials)
```

**Complexity:** O(num_trials · T_eval), where T_eval is the cost of evaluating f at one point.

### 4.2 Low-Degree Vanishing Polynomial Detection

**Input:** Points S ⊆ GF(q)^n, degree bound d.
**Output:** A nonzero polynomial of degree ≤ d vanishing on S, or ⊥ if none exists.

```
Algorithm FindVanishingPoly(S, d, q, n):
    monomials ← enumerate all monomials of degree ≤ d in n variables
    D ← |monomials| = C(d+n, n)
    if |S| ≥ D: return ⊥
    M ← |S| × D evaluation matrix, M[i,j] = monomial_j(S[i])
    v ← nonzero vector in kernel(M) via Gaussian elimination
    return polynomial with coefficients v
```

**Complexity:** O(|S| · D²) field operations, where D = C(d+n, n).

### 4.3 Experimental Results

We verified the Schwartz–Zippel bound computationally for all polynomials in our test suite:

| Polynomial | q | n | deg | |zeros| | Bound d·q^(n-1) | Ratio |
|---|---|---|---|---|---|---|
| x₀ + x₁ | 5 | 2 | 1 | 5 | 5 | 1.000 |
| x₀² + x₁² + 1 | 5 | 2 | 2 | 4 | 10 | 0.400 |
| x₀³ - 1 | 7 | 2 | 3 | 21 | 21 | 1.000 |
| x₀x₁ + x₂ | 3 | 3 | 2 | 9 | 18 | 0.500 |
| x₀x₁x₂ + 1 | 5 | 3 | 3 | 16 | 75 | 0.213 |

The bound is tight for several classes of polynomials (ratio = 1.000) and typically loose for polynomials with richer structure.

## 5. Applications

### 5.1 Reed–Muller Codes

The Reed–Muller code RM(q, n, d) consists of evaluation vectors of all polynomials of total degree ≤ d in n variables over GF(q). Our Theorem 9 directly gives:

- **Block length:** q^n
- **Dimension:** C(d+n, n)
- **Minimum distance:** ≥ (q - d) · q^(n-1)

These parameters make Reed–Muller codes fundamental in practice for error correction, local testing, and list decoding.

### 5.2 Polynomial Identity Testing

Given black-box access to a polynomial f of degree d, the Schwartz–Zippel test evaluates f at O(1) random points in GF(q)^n and declares f = 0 iff all evaluations return 0. The error probability is at most d/q per evaluation, giving exponentially small failure probability with O(log(1/ε)) evaluations.

### 5.3 Kakeya and Extractors

Dvir's theorem implies that any Kakeya set in GF(q)^n has cardinality at least C(q+n-1, n). This has direct consequences for the construction of randomness mergers and extractors, because Kakeya sets characterize the worst-case behavior of certain seeded extraction protocols.

## 6. Discussion

### 6.1 Significance of the Formalization

Our formalization demonstrates that the core polynomial method pipeline can be implemented as reusable infrastructure. Each layer (univariate vanishing → multivariate vanishing → line restriction → Dvir) builds on the previous one in a modular way, and each layer has independent applications.

### 6.2 Limitations

- Our Schwartz–Zippel bound is for the full grid K^n. The general Schwartz–Zippel lemma over arbitrary product sets S₁ × ... × Sₙ ⊆ K^n is not formalized here.
- The quantitative Kakeya lower bound (from dimension counting) is not formally derived, though Dvir's impossibility theorem — the conceptual core — is fully verified.
- The formalization uses `set_option maxHeartbeats 800000` for the Schwartz–Zippel proof; optimization of this proof term remains future work.

### 6.3 Axiom Usage

All theorems depend only on the standard axioms: `propext`, `Classical.choice`, and `Quot.sound`. No `sorry`, `axiom`, or `@[implemented_by]` declarations are used.

## 7. Future Work

1. **Quantitative Kakeya bound:** Formalize the dimension count for bounded-degree polynomial spaces and derive |E| ≥ C(q+n-1, n) for Kakeya sets.
2. **General Schwartz–Zippel:** Extend to arbitrary product domains S₁ × ... × Sₙ.
3. **Combinatorial Nullstellensatz:** Formalize Alon's combinatorial Nullstellensatz and its applications.
4. **Cap set bounds:** Build the slice rank / polynomial method infrastructure for Croot–Lev–Pach type results.
5. **Reed–Muller interface:** Define Reed–Muller codes and derive distance bounds from the formalized Schwartz–Zippel lemma.

## References

1. Dvir, Z. (2008). On the size of Kakeya sets in finite fields. *J. Amer. Math. Soc.* 22(4), 1093–1097.
2. Schwartz, J.T. (1980). Fast probabilistic algorithms for verification of polynomial identities. *J. ACM* 27(4), 701–717.
3. Zippel, R. (1979). Probabilistic algorithms for sparse polynomials. *Proc. EUROSAM 79*, LNCS 72, 216–226.
4. Alon, N. (1999). Combinatorial Nullstellensatz. *Combin. Probab. Comput.* 8(1–2), 7–29.
5. Croot, E., Lev, V.F., Pach, P.P. (2017). Progression-free sets in Z₄ⁿ are exponentially small. *Ann. of Math.* 185(1), 331–337.
6. Ellenberg, J.S., Gijswijt, D. (2017). On large subsets of F_q^n with no three-term arithmetic progression. *Ann. of Math.* 185(1), 339–343.
7. Guth, L., Katz, N. (2015). On the Erdős distinct distances problem in the plane. *Ann. of Math.* 181(1), 155–190.
8. Tao, T. (2014). Algebraic combinatorial geometry: the polynomial method in arithmetic combinatorics, incidence combinatorics, and number theory. *EMS Surv. Math. Sci.* 1, 1–46.
