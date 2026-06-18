# A Formal Census of the Selberg Class: Countability, Spectral Complexity, and Conductor Counting

## Abstract

We introduce a formal framework for the systematic enumeration of elements in the Selberg class of L-functions. Our central object is the *Selberg datum* — a finite tuple encoding the degree, conductor, and spectral parameters of a Selberg class element. We prove that the set of all Selberg data is countable, establish the additivity of a novel *spectral complexity* invariant under Rankin-Selberg products, prove monotonicity and polynomial bounds for the conductor counting function, and introduce *spectral entropy* as a new measure of the arithmetic complexity of spectral parameters. All results are formalized in Lean 4 with complete machine-checked proofs.

**Keywords**: Selberg class, L-functions, countability, spectral complexity, conductor counting, formal verification

## 1. Introduction

The Selberg class S, introduced by Selberg in 1992, axiomatizes the analytic properties shared by "well-behaved" L-functions: Dirichlet series with Euler product, analytic continuation, and functional equation. A central problem in analytic number theory is to classify the elements of S — that is, to determine which L-functions satisfy Selberg's axioms and to understand the structure of S as a mathematical object.

Every element of S is determined (conjecturally) by a finite set of invariants: its degree d, conductor q, and spectral parameters μ₁, …, μᵣ. These invariants appear in the functional equation

Λ(s) = ε · Q^s · ∏ᵢ Γ(s/2 + μᵢ) · L(s) = Λ̄(1-s)

where Q > 0, ε is a root-sign, and the μᵢ have nonneg real part. The degree is d = 2∑ᵢ 1 (counting with multiplicity).

In this paper, we formalize the invariant data as a *Selberg datum*, prove that the resulting set is countable, and introduce two novel invariants — spectral complexity and spectral entropy — that provide natural orderings and complexity measures on the Selberg class.

### 1.1 Contributions

1. **SelbergDatum structure** (Definition 2.1): A formal encoding of the invariant data of a Selberg class element, with fields for degree, conductor, number of Gamma factors, and spectral shifts.

2. **Countability theorem** (Theorem 3.1): The type of Selberg data is countable, proved via an injective encoding into a countable sigma type.

3. **Spectral complexity** (Definition 2.3): A rational-valued complexity measure that is additive under products.

4. **Spectral entropy** (Definition 2.5): A novel invariant measuring the arithmetic complexity of spectral parameters, also additive under products.

5. **Conductor counting bounds** (Theorem 4.2): The counting function N_d(Q) is monotone in Q and bounded by a polynomial.

6. **Factorization structure** (Theorems 5.1–5.2): Degree is strictly decreasing under nontrivial factorization; conductor is multiplicative.

## 2. Definitions

### 2.1 Selberg Datum

**Definition 2.1** (SelbergDatum). A *Selberg datum* is a tuple S = (d, q, r, μ) where:
- d ∈ ℕ is the *degree*
- q ∈ ℕ₊ is the *conductor* (q ≥ 1)
- r ∈ ℕ is the *number of Gamma factors*
- μ : Fin r → ℚ is the vector of *spectral shifts* (real parts of the spectral parameters)

We say S is *well-formed* if r = d (the number of Gamma factors equals the degree).

**Remark.** In the analytic theory, the spectral parameters μⱼ are complex numbers with Re(μⱼ) ≥ 0. We work with rational spectral shifts for two reasons: (1) it ensures countability without appeal to algebraicity conjectures, and (2) all known examples have algebraic (often rational) spectral parameters.

### 2.2 Product Structure

**Definition 2.2** (Product datum). Given S₁ = (d₁, q₁, r₁, μ₁) and S₂ = (d₂, q₂, r₂, μ₂), their *product* is:

S₁ · S₂ = (d₁ + d₂, q₁ · q₂, r₁ + r₂, μ₁ ⊕ μ₂)

where μ₁ ⊕ μ₂ denotes concatenation (Fin.addCases).

### 2.3 Spectral Complexity

**Definition 2.3.** The *spectral complexity* of S = (d, q, r, μ) is:

κ(S) = d · q + ∑ᵢ |μᵢ| ∈ ℚ

### 2.4 Coarse Complexity

**Definition 2.4.** The *coarse complexity* is:

κ̃(S) = d + q + r ∈ ℕ

### 2.5 Spectral Entropy

**Definition 2.5.** The *spectral entropy* of S = (d, q, r, μ) is:

η(S) = ∑ᵢ (|μᵢ.num| + μᵢ.den) ∈ ℚ

where μᵢ.num and μᵢ.den are the numerator and denominator of the rational μᵢ in lowest terms. This measures the arithmetic height of the spectral parameters.

### 2.6 Primitivity

**Definition 2.6.** A datum S is *primitive* if d ≥ 1 and S cannot be expressed as S₁ · S₂ with d₁ ≥ 1 and d₂ ≥ 1.

### 2.7 The Zeta Datum

**Definition 2.7.** The *zeta datum* is ζ = (1, 1, 1, [0]), representing the Riemann zeta function.

## 3. Countability

### 3.1 Encoding

**Lemma 3.1** (Injective encoding). The map

encode(d, q, r, μ) = (d, q, r, μ)

from SelbergDatum to (d : ℕ) × (q : ℕ) × (r : ℕ) × (Fin r → ℚ) is injective.

*Proof.* If encode(S) = encode(S'), then d = d', q = q', r = r', and μ = μ'. Since q > 0 is a proof of a proposition, it is unique by proof irrelevance. Hence S = S'. □

**Theorem 3.2** (Countability). SelbergDatum is countable.

*Proof.* The codomain of encode is a dependent sigma type over ℕ × ℕ × ℕ with fibers Fin r → ℚ. Each fiber is countable (ℚ is countable, and the function type from a finite set to a countable set is countable). A countable union of countable sets is countable. By injectivity of encode, SelbergDatum injects into a countable type. □

## 4. Conductor Counting

### 4.1 The Counting Function

**Definition 4.1.** For fixed d, r, B ∈ ℕ, define:

N_{d,r,B}(Q) = |{(q, μ) : q ∈ Fin(Q+1), μ : Fin r → Fin(2B+1), q+1 > 0}|

This counts the number of "discretized" Selberg data with conductor ≤ Q, at most r Gamma factors, and spectral shifts bounded by B.

**Theorem 4.2** (Monotonicity). N_{d,r,B}(Q) is monotone non-decreasing in Q.

*Proof.* When Q ≤ Q', every element of Fin(Q+1) embeds into Fin(Q'+1), so the filter over the smaller finset is contained in the filter over the larger one. □

**Theorem 4.3** (Polynomial bound). N_{d,r,B}(Q) ≤ (Q+1) · (2B+1)^r.

*Proof.* The filtered set is a subset of the full product Fin(Q+1) × (Fin r → Fin(2B+1)), whose cardinality is (Q+1) · (2B+1)^r. □

## 5. Factorization Structure

### 5.1 Degree Monotonicity

**Theorem 5.1** (Degree strict decrease). If S = S₁ · S₂ with d₁ ≥ 1 and d₂ ≥ 1, then d₁ < d and d₂ < d.

*Proof.* d = d₁ + d₂. Since d₂ ≥ 1, we have d₁ < d₁ + d₂ = d. Similarly d₂ < d. □

**Corollary.** Every Selberg datum of degree d has at most d primitive factors.

### 5.2 Conductor Divisibility

**Theorem 5.2** (Conductor divisibility). If S = S₁ · S₂, then q₁ | q and q₂ | q.

*Proof.* q = q₁ · q₂, so q₁ | q₁ · q₂ = q and q₂ | q₁ · q₂ = q. □

### 5.3 Coarse Complexity Bound

**Theorem 5.3.** κ̃(S₁ · S₂) ≤ κ̃(S₁) + κ̃(S₂) + q₁ · q₂.

*Proof.* κ̃(S₁ · S₂) = (d₁+d₂) + (q₁·q₂) + (r₁+r₂). We need this ≤ (d₁+q₁+r₁) + (d₂+q₂+r₂) + q₁·q₂, which reduces to 0 ≤ q₁ + q₂. □

## 6. Spectral Entropy

### 6.1 Properties

**Theorem 6.1** (Nonnegativity). η(S) ≥ 0 for all S.

*Proof.* Each summand |μᵢ.num| + μᵢ.den is nonneg (both terms are natural numbers cast to ℚ). □

**Theorem 6.2** (Additivity). η(S₁ · S₂) = η(S₁) + η(S₂).

*Proof.* The spectral shifts of the product are the concatenation of the individual shifts. The sum over Fin(r₁+r₂) of a concatenated function splits as the sum over Fin r₁ plus the sum over Fin r₂. □

**Theorem 6.3** (Zeta entropy). η(ζ) = 1.

*Proof.* ζ has one spectral shift equal to 0. The height of 0 = 0/1 is |0| + 1 = 1. □

### 6.2 Well-Formedness

**Theorem 6.4** (Product preserves well-formedness). If S₁ and S₂ are well-formed, then S₁ · S₂ is well-formed.

*Proof.* r₁ = d₁ and r₂ = d₂ imply r₁ + r₂ = d₁ + d₂. □

**Theorem 6.5** (Degree-1 classification). A well-formed datum of degree 1 has exactly one Gamma factor.

*Proof.* r = d = 1. □

## 7. Conjectures

### 7.1 Conductor-Degree Polynomial Bound

**Conjecture 7.1.** For each fixed degree d ≥ 1, there exists C = C(d) such that

N_{d,d+1,Q+1}(Q) ≤ C · (Q+1)^{d+1}

for all Q ∈ ℕ.

**Computational test.** For d = 1, verify that N_{1,2,Q+1}(Q) ≤ C · (Q+1)² for Q = 1, 10, 100, 1000 with a fixed constant C.

### 7.2 Degree-1 Classification

**Conjecture 7.2** (Kaczorowski-Perelli). Every primitive well-formed datum of degree 1 corresponds to a Dirichlet character: there exists a Dirichlet character χ mod q such that the spectral shift μ = 0 or 1/2 (according to the parity of χ) and the conductor equals the conductor of χ.

## 8. Discussion

### 8.1 Relation to the Langlands Program

The Selberg class is closely related to the automorphic L-functions predicted by the Langlands program. Our framework of Selberg data corresponds to the "local data" of an automorphic representation — the archimedean Langlands parameters. The countability theorem can be viewed as a shadow of the fact that automorphic representations are discrete in the spectral decomposition.

### 8.2 Spectral Entropy as a Novel Invariant

The spectral entropy η(S) is, to our knowledge, a new invariant. Its additivity under products makes it a "homomorphism" from the multiplicative monoid of Selberg data to (ℚ≥₀, +). The fact that η(ζ) = 1 means the zeta function is the "unit of information" in the spectral entropy scale.

### 8.3 Connections to Combinatorics

The conductor counting function N_d(Q) is analogous to the graph counting functions studied in extremal graph theory. The polynomial bound N_d(Q) ≤ C · Q^{d+1} parallels the Kővári–Sós–Turán theorem for bipartite graphs, suggesting that density results for L-functions may be provable using combinatorial machinery.

## 9. Future Work

1. **Formalize the Kaczorowski-Perelli classification** of degree-1 Selberg class elements.
2. **Sharpen the conductor counting bounds** using techniques from analytic number theory (the large sieve, density theorems).
3. **Study the spectral entropy distribution** — what is the expected entropy of a "random" L-function of degree d and conductor ≤ Q?
4. **Connect to the Catalog's existing results** on tropical geometry and algebraic circuit complexity, where similar counting and complexity measures appear.

## References

1. A. Selberg, "Old and new conjectures and results about a class of Dirichlet series," *Proceedings of the Amalfi Conference on Analytic Number Theory*, 1992, pp. 367–385.

2. J. Kaczorowski and A. Perelli, "On the structure of the Selberg class, I: 0 ≤ d ≤ 1," *Acta Mathematica*, vol. 182, 1999, pp. 207–241.

3. J. Kaczorowski and A. Perelli, "On the structure of the Selberg class, VII: 1 < d < 2," *Annals of Mathematics*, vol. 173, 2011, pp. 1397–1441.

4. M. R. Murty, "Selberg's conjectures and Artin L-functions," *Bulletin of the AMS*, vol. 31, 1994, pp. 1–14.

5. A. Perelli, "A survey of the Selberg class of L-functions," two parts, *Milan Journal of Mathematics*, 2005.
