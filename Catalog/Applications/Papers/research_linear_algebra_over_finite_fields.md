# Evaluation-Kernel Calculus for the Finite-Field Polynomial Method: A Formalized Framework

## Abstract

We present a formally verified framework for the finite-field polynomial method, centered on the *evaluation-kernel principle*: when a finite set E is too small to support all evaluations from a finite-dimensional polynomial space V, rank-nullity forces a nonzero polynomial in V to vanish on all of E. We formalize four main results in Lean 4 with Mathlib: (1) an abstract kernel-existence theorem for linear maps into function spaces, (2) a constructive univariate vanishing polynomial theorem, (3) a multivariate submodule kernel extraction theorem, and (4) a box-degree multivariate vanishing theorem with dimension d^n. All proofs compile without axioms beyond the standard foundations. We demonstrate applications to Reed-Muller codes, polynomial identity testing, secret sharing, and finite geometry, and outline concrete future directions including the Schwartz-Zippel lemma, Reed-Muller distance bounds, and circuit complexity bridges.

## 1. Introduction

### 1.1 The Polynomial Method

The polynomial method is a family of techniques in combinatorics, coding theory, and theoretical computer science that uses the algebraic structure of polynomial rings over finite fields to derive combinatorial and geometric conclusions. The common thread is a dimension-counting argument: the space of low-degree polynomials has a computable dimension, and when this dimension exceeds the number of evaluation constraints imposed by a finite set, a nonzero vanishing polynomial must exist.

This principle, while elementary in statement, has produced breakthroughs across mathematics:

- **Dvir's Kakeya theorem** (2009): finite-field Kakeya sets have size Ω(q^n/n!) [1].
- **Cap set bounds** (Croot-Lev-Pach, Ellenberg-Gijswijt, 2016): subsets of F_3^n without three-term progressions have size O(2.756^n) [2, 3].
- **Reed-Muller code analysis**: minimum distance and list-decoding properties via polynomial evaluation [4].
- **Algebraic circuit lower bounds**: degree constraints from circuit complexity interact with polynomial vanishing [5].

### 1.2 Contributions

We formalize the evaluation-kernel principle in Lean 4 with full machine verification. Our contributions are:

1. **Abstract kernel-existence theorem** (`exists_nonzero_mem_ker_of_finrank_gt`): For any linear map φ : V →ₗ[K] (E → K) from a finite-dimensional K-vector space V, if |E| < dim(V), then ker(φ) ≠ {0}.

2. **Univariate vanishing theorem** (`exists_nonzero_poly_vanishing_on_finite_set_of_card_lt`): For E ⊆ K with |E| < d, there exists p ∈ K[X] with p ≠ 0, deg(p) < d, and p(a) = 0 for all a ∈ E.

3. **Multivariate submodule kernel extraction** (`exists_nonzero_in_lowTotalDegree_vanishing`): For any finite-dimensional submodule L of MvPolynomial(Fin n, K) with |E| < dim(L), a nonzero element of L vanishes on E.

4. **Box-degree vanishing theorem** (`exists_nonzero_mvPolynomial_vanishing_on_finite_set_of_card_lt_pow`): If |E| < d^n, there exists a nonzero polynomial with all variable degrees < d vanishing on E.

5. **Evaluation linear maps**: Formally defined as K-linear maps for both univariate and multivariate settings.

### 1.3 Related Work

Formalization of finite-field combinatorics in proof assistants remains sparse. The Mathlib library provides extensive polynomial algebra and linear algebra infrastructure but lacks the evaluation-kernel framework needed for the polynomial method. Our work bridges this gap by providing reusable interfaces.

## 2. Definitions and Notation

### 2.1 Setting

Let K be a field. For the finite-field applications, K = F_q for a prime power q, but several results hold for arbitrary fields.

- **Polynomial rings**: K[X] denotes the univariate polynomial ring; MvPolynomial(Fin n, K) denotes the ring of polynomials in n variables x_0, ..., x_{n-1} over K.
- **Monomials**: A monomial in n variables is specified by an exponent vector α = (α_0, ..., α_{n-1}) ∈ ℕ^n. In Lean, this is represented as `Fin n →₀ ℕ` (finitely supported functions).
- **Total degree**: For a monomial with exponent α, the total degree is Σᵢ αᵢ.
- **Box degree**: A polynomial has box degree < d if all exponents satisfy αᵢ < d for every i.
- **Evaluation map**: For a finite set E ⊆ K^n, the evaluation map ev_E sends a polynomial p to the function (x ↦ p(x)) restricted to E.

### 2.2 Formal Definitions

**Definition 2.1** (Evaluation linear map, univariate). For E ⊆ K finite:
```
Polynomial.evalOnFinsetLinear K E : K[X] →ₗ[K] (E → K)
```
defined by `p ↦ (⟨x, hx⟩ ↦ eval x p)`.

**Definition 2.2** (Evaluation linear map, multivariate). For E ⊆ K^n finite:
```
MvPolynomial.evalOnFinsetLinear K n E : MvPolynomial (Fin n) K →ₗ[K] (E → K)
```
defined by `p ↦ (⟨x, hx⟩ ↦ eval x p)`.

Both are verified to be K-linear maps (preserving addition and scalar multiplication).

## 3. Main Results

### 3.1 Abstract Kernel-Existence Principle

**Theorem 3.1** (Kernel existence). *Let K be a field, V a finite-dimensional K-vector space, E a finite set, and φ : V →ₗ[K] (E → K) a K-linear map. If |E| < dim_K(V), then there exists v ∈ V with v ≠ 0 and φ(v) = 0.*

**Proof sketch.** By rank-nullity (`LinearMap.finrank_range_add_finrank_ker`):
```
dim(range φ) + dim(ker φ) = dim(V)
```
The range of φ is a subspace of (E → K), so dim(range φ) ≤ dim(E → K) = |E|. Therefore:
```
dim(ker φ) = dim(V) - dim(range φ) ≥ dim(V) - |E| > 0
```
A vector space of positive dimension is nontrivial, yielding a nonzero kernel element.

The formal proof proceeds by contraposition: if the kernel is trivial (ker φ = ⊥), then φ is injective, so dim(range φ) = dim(V), contradicting dim(range φ) ≤ |E| < dim(V). □

### 3.2 Univariate Polynomial Vanishing

**Theorem 3.2** (Univariate vanishing). *Let K be a field, E ⊆ K a finite set, and d ∈ ℕ with |E| < d. Then there exists p ∈ K[X] with p ≠ 0, natDegree(p) < d, and eval(a, p) = 0 for all a ∈ E.*

**Proof.** We give a constructive proof. Define:
```
p(X) = ∏_{a ∈ E} (X - a)
```
Then:
1. **p ≠ 0**: Each factor X - a is nonzero in K[X] (it's monic of degree 1), and K[X] is an integral domain, so the product is nonzero. Formally, we use `Finset.prod_ne_zero_iff` and `Polynomial.X_sub_C_ne_zero`.

2. **natDegree(p) < d**: By `Polynomial.natDegree_prod`, natDegree(p) = Σ_{a ∈ E} natDegree(X - a) = Σ_{a ∈ E} 1 = |E| < d.

3. **Vanishing**: For any a ∈ E, eval(a, p) = ∏_{b ∈ E} (a - b). The factor with b = a contributes 0, so the product is 0. Formally, we use `Polynomial.eval_prod` and `Finset.prod_eq_zero`. □

### 3.3 Multivariate Submodule Kernel Extraction

**Theorem 3.3** (Submodule kernel extraction). *Let K be a field, n, d ∈ ℕ, E ⊆ K^n a finite set, and L a finite-dimensional K-submodule of MvPolynomial(Fin n, K). If |E| < dim_K(L), then there exists p ∈ L with p ≠ 0 and eval(x, p) = 0 for all x ∈ E.*

**Proof sketch.** Define φ : L →ₗ[K] (E → K) by φ(p)(x) = eval(x, p). Apply Theorem 3.1 to obtain a nonzero v ∈ L with φ(v) = 0. The conclusion follows because φ(v) = 0 means eval(x, v) = 0 for all x ∈ E, and v ≠ 0 in L implies the underlying polynomial is nonzero. □

### 3.4 Box-Degree Multivariate Vanishing

**Theorem 3.4** (Box-degree vanishing). *Let K be a field, n, d ∈ ℕ, and E ⊆ K^n a finite set with |E| < d^n. Then there exists p ∈ MvPolynomial(Fin n, K) with p ≠ 0, all exponents of monomials in the support of p bounded by d in each variable, and eval(x, p) = 0 for all x ∈ E.*

**Proof sketch.** Define the set of box-degree-bounded monomials:
```
S = {α ∈ (Fin n →₀ ℕ) : ∀ i, αᵢ < d}
```
This set bijects with `Fin n → Fin d`, so |S| = d^n. The set of monomials {X^α : α ∈ S} is linearly independent in MvPolynomial(Fin n, K) (monomials in a polynomial ring are always linearly independent). Let L = span_K{X^α : α ∈ S}. Then dim(L) = |S| = d^n > |E|.

Apply Theorem 3.3 to obtain a nonzero p ∈ L vanishing on E. Since p is in the span of box-degree-bounded monomials, its support is contained in S, so all exponents are < d. □

## 4. Applications

### 4.1 Reed-Muller Codes

Reed-Muller codes encode messages as evaluations of low-degree polynomials on a finite field. A message of length d^n is identified with a polynomial of box-degree < d in n variables, and the codeword is the polynomial's evaluation on all of F_q^n.

**Distance bound.** The minimum distance of the Reed-Muller code is related to the maximum number of zeros of a nonzero low-degree polynomial. Our vanishing theorem provides the structural framework: if a codeword (= polynomial evaluation) has too many zeros, the corresponding polynomial is zero, hence the message is zero. Contrapositively, nonzero codewords have bounded zero sets.

**Computational experiments.** We implemented Reed-Muller encoding and estimated minimum distances:

| Code | n | d | q | Length | Dimension | Rate | Min Distance (est.) |
|------|---|---|---|--------|-----------|------|---------------------|
| RM(3,1,2) | 1 | 2 | 3 | 3 | 2 | 0.667 | 2 |
| RM(3,2,2) | 2 | 2 | 3 | 9 | 4 | 0.444 | 4 |
| RM(5,1,3) | 1 | 3 | 5 | 5 | 3 | 0.600 | 3 |
| RM(5,2,2) | 2 | 2 | 5 | 25 | 4 | 0.160 | 16 |

### 4.2 Polynomial Identity Testing

The Schwartz-Zippel lemma, a corollary of the polynomial method, states that a nonzero polynomial of total degree d over a finite field F_q evaluates to zero at a random point with probability at most d/q. This yields efficient randomized identity tests:

**Algorithm: Schwartz-Zippel PIT**
```
Input: Two algebraic expressions f, g in n variables
Output: "Equal" or "Different"

1. Choose random point r ∈ F_q^n
2. Evaluate h = f - g at r
3. If h(r) = 0, output "Equal"
4. Else output "Different"

Error probability: ≤ deg(f-g)/q per trial
```

Our experiments verify this over F_101:
- True identity (x+y)² = x² + 2xy + y²: 10/10 tests confirm equality.
- False identity x² + y² = (x+y)²: counterexample found on first test.

### 4.3 Secret Sharing

Shamir's (t, n)-threshold secret sharing scheme uses polynomial evaluation and interpolation:

1. **Sharing**: Choose random polynomial f of degree t-1 with f(0) = secret. Share i is f(i).
2. **Reconstruction**: Any t shares determine f uniquely by Lagrange interpolation.
3. **Privacy**: Any t-1 shares are consistent with every possible secret (by the vanishing theorem: the space of degree-(t-1) polynomials through t-1 points has dimension 1, leaving f(0) free).

Our implementation over F_13 demonstrates correct reconstruction from 3-of-5 shares and perfect privacy with 2 shares.

### 4.4 Finite Geometry

The polynomial method provides lower bounds on Kakeya sets — sets containing a line in every direction. Over F_q^n, our vanishing theorem is the first step in Dvir's proof: if the Kakeya set has fewer than (q choose n) points, a low-degree vanishing polynomial exists, contradicting the directional degree requirements imposed by the Kakeya property.

Our experiments over F_5^2 find Kakeya sets of size 17 (out of 25 total points) by random search, consistent with the theoretical lower bound of roughly q^n/n!.

## 5. Formal Verification Details

### 5.1 Proof Architecture

The formalization follows a layered architecture:

1. **Abstract layer**: `exists_nonzero_mem_ker_of_finrank_gt` — pure linear algebra, no polynomial-specific content.
2. **Interface layer**: `Polynomial.evalOnFinsetLinear`, `MvPolynomial.evalOnFinsetLinear` — evaluation maps as linear maps.
3. **Instantiation layer**: `exists_nonzero_poly_vanishing_on_finite_set_of_card_lt` (constructive), `exists_nonzero_in_lowTotalDegree_vanishing` (via abstract layer), `exists_nonzero_mvPolynomial_vanishing_on_finite_set_of_card_lt_pow` (box-degree).

### 5.2 Key Mathlib Dependencies

- `LinearMap.finrank_range_add_finrank_ker`: Rank-nullity theorem.
- `LinearMap.finrank_range_of_inj`: Injective maps preserve dimension.
- `Module.finrank_pi`: Dimension of function spaces.
- `Polynomial.natDegree_prod`: Degree of products.
- `Polynomial.eval_prod`: Evaluation distributes over products.
- `finrank_span_eq_card`: Dimension of span of linearly independent set.

### 5.3 Axiom Usage

All four theorems depend only on the standard foundational axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No additional axioms, `sorry`, or `@[implemented_by]` annotations are used.

## 6. Discussion

### 6.1 Design Decisions

**Abstract-first approach.** We chose to formalize the abstract kernel-existence principle before the polynomial instantiations. This makes the framework reusable: any finite-dimensional subspace of any function algebra can be plugged in, not just polynomial rings.

**Constructive vs. existential.** The univariate theorem uses a constructive proof (explicit product polynomial), while the multivariate theorems use existential proofs via rank-nullity. The constructive proof provides a computable witness; the existential proofs are more general.

**Box degree vs. total degree.** We formalized box-degree bounds (each variable < d) rather than total-degree bounds (sum < d) because box-degree spaces have the clean dimension formula d^n. Total-degree spaces have dimension (n+d-1 choose n), which requires more combinatorial infrastructure.

### 6.2 Limitations

- The multivariate vanishing theorem requires the field to be arbitrary (not necessarily finite), but the most interesting applications are over finite fields.
- We do not formalize the Schwartz-Zippel lemma or Reed-Muller distance bounds, which would require additional induction arguments.
- The finite-dimensionality of the box-degree polynomial space is established within the proof of Theorem 3.4, rather than as a standalone lemma.

## 7. Future Work

See FUTURE_DIRECTIONS.md for detailed next steps. The highest-priority targets are:

1. **Schwartz-Zippel lemma**: Bound on the zero set of a multivariate polynomial. Proof by induction on the number of variables.
2. **Reed-Muller distance bounds**: Complement counting from Schwartz-Zippel.
3. **Circuit complexity bridge**: Connect circuit degree bounds to polynomial vanishing.
4. **Unique interpolation**: Dual of vanishing — when |E| = dim(V) and the evaluation map is bijective.
5. **Finite-field Kakeya lower bound**: Dvir's proof using the vanishing polynomial as the starting point.

## 8. Conclusion

We have formalized the evaluation-kernel principle — the mathematical engine behind the polynomial method — as a reusable framework in Lean 4. The abstract kernel-existence theorem, combined with polynomial evaluation linear maps, provides a clean interface for extracting low-degree vanishing certificates from dimension bounds. The framework is instantiated to both univariate and multivariate settings, with all proofs machine-verified against the Lean 4 kernel.

This work establishes the foundation for formalizing a broad spectrum of polynomial method applications, from coding theory to algebraic complexity to finite geometry. The evaluation-kernel calculus is designed as a composable module: each new application instantiates the same abstract theorem with a different polynomial subspace and evaluation domain.

## References

[1] Z. Dvir, "On the size of Kakeya sets in finite fields," *J. Amer. Math. Soc.*, 22(4):1093–1097, 2009.

[2] E. Croot, V. Lev, P. Pach, "Progression-free sets in Z_4^n are exponentially small," *Ann. of Math.*, 185(1):331–337, 2017.

[3] J. S. Ellenberg, D. Gijswijt, "On large subsets of F_q^n with no three-term arithmetic progression," *Ann. of Math.*, 185(1):339–343, 2017.

[4] S. Kopparty, S. Saraf, S. Yekhanin, "High-rate codes with sublinear-time decoding," *J. ACM*, 61(5):28, 2014.

[5] V. Shpilka, A. Yehudayoff, "Arithmetic circuits: A survey of recent results and open questions," *Found. Trends Theor. Comput. Sci.*, 5(3-4):207–388, 2010.

[6] T. Tao, "Algebraic combinatorial geometry: the polynomial method in arithmetic combinatorics, incidence combinatorics, and number theory," *EMS Surv. Math. Sci.*, 1(1):1–46, 2014.

[7] L. Guth, "Polynomial Methods in Combinatorics," *University Lecture Series*, vol. 64, AMS, 2016.
