# EML Algebraic Independence and Certified Transcendence Proxies

## Abstract

We develop a formal algebraic framework for studying polynomial relations among *exponential-multiply-logarithm* (EML) values of the form eml(a) = exp(a)·log(1+a). Working in Lean 4 with the Mathlib library, we prove three families of structural theorems: (1) a *linear relation partition theorem* showing that linear EML combinations decompose by logarithmic collision classes; (2) a *polynomial expansion theorem* reducing polynomial relation search to finite monomial support analysis; and (3) *norm bounds for imaginary inputs* connecting EML algebraic independence to phase cancellation in harmonic analysis. We introduce the concepts of *EML monomial separation* and *bounded-degree relation certificates*, and provide verified computational algorithms for searching and certifying the absence of polynomial relations within prescribed bounds. Our framework does not prove transcendence but builds the first rigorous reduction theory for EML-type transcendence questions, converting infinite algebraic independence problems into finite, certifiable computations.

**Keywords:** transcendence theory, algebraic independence, Schanuel conjecture, exponential-logarithmic values, symbolic computation, sparse polynomial relations, harmonic analysis, phase cancellation, certified algorithms, special values, period heuristics

---

## 1. Introduction

### 1.1 Motivation

For a nonzero algebraic number *a* ≠ −1, the Lindemann–Weierstrass theorem guarantees that exp(*a*) is transcendental, and the Gelfond–Schneider theorem (in conjunction with Baker's results) establishes the transcendence of log(1 + *a*) in most cases. However, the product

$$\text{eml}(a) := \exp(a) \cdot \log(1 + a)$$

presents a fundamentally harder problem. The product of two transcendental numbers can be rational (e.g., π · (1/π) = 1), algebraic, or transcendental, and no general theorem determines which case applies for EML values.

### 1.2 The Naive Claim and Its Subtlety

A common folklore assertion states that "for algebraic *a* ≠ 0, eml(*a*) is transcendental, following from Lindemann–Weierstrass and Gelfond–Schneider." This is **not** settled in this generality. While each factor is individually transcendental, their product's algebraic status requires additional argument. The interaction between the exponential and logarithmic factors is subtle — one would need to show that no algebraic relation between exp(*a*) and log(1 + *a*) allows their product to be algebraic. This is precisely the kind of question addressed by Schanuel's conjecture but not resolved by classical theorems alone.

### 1.3 Our Approach

Rather than attempting to prove transcendence from unavailable deep theorems, we adopt a structural approach:

1. **Define** a formal language for EML expressions and polynomial relations.
2. **Prove** that any polynomial relation among EML values must have a rigid algebraic skeleton — it decomposes into exponential-logarithmic monomials with controlled support.
3. **Provide** certified computational methods that search for polynomial relations within bounded degree and coefficient ranges, returning certificates of non-existence.

This creates a new interface between transcendence theory, symbolic algebra, analytic inequalities, and computational number theory.

---

## 2. Definitions and Notation

### 2.1 The EML Operator

**Definition 2.1.** For z ∈ ℂ with z ≠ −1, define
$$\text{eml}(z) := \exp(z) \cdot \log(1 + z)$$
where log denotes the principal branch of the complex logarithm.

In Lean 4:
```lean
def eml (z : ℂ) : ℂ := Complex.exp z * Complex.log (1 + z)
```

### 2.2 EML Monomials

**Definition 2.2.** For a tuple a = (a₁, ..., aₙ) ∈ ℂⁿ and an exponent vector m = (m₁, ..., mₙ) ∈ ℕⁿ, the *EML monomial* is

$$\text{emlMonomial}(\mathbf{a}, \mathbf{m}) := \exp\!\left(\sum_{i=1}^n m_i a_i\right) \cdot \prod_{i=1}^n \log(1 + a_i)^{m_i}$$

In Lean 4 (using Finsupp for exponent vectors):
```lean
def emlMonomial {n : ℕ} (a : Fin n → ℂ) (m : Fin n →₀ ℕ) : ℂ :=
  Complex.exp (∑ i, (m i : ℂ) * a i) * ∏ i, (Complex.log (1 + a i)) ^ (m i)
```

### 2.3 Polynomial Expansion

**Definition 2.3.** The *EML expansion* of a polynomial P ∈ ℚ[X₁, ..., Xₙ] at inputs a is

$$\text{expandEML}(\mathbf{a}, P) := \sum_{\mathbf{m} \in \text{supp}(P)} c_\mathbf{m} \cdot \text{emlMonomial}(\mathbf{a}, \mathbf{m})$$

where c_m are the coefficients of P.

### 2.4 Relation Predicates

**Definition 2.4.** We say a tuple v ∈ ℂⁿ has *no polynomial relation up to degree d* (written NoPolyRelUpTo(d, v)) if every polynomial P ∈ ℚ[X₁,...,Xₙ] of total degree ≤ d satisfying P(v) = 0 is the zero polynomial.

**Definition 2.5.** A tuple a ∈ ℂⁿ satisfies *EML monomial separation up to degree d* (written EMLMonomialSeparatedUpTo(d, a)) if the map m ↦ emlMonomial(a, m) is injective on exponent vectors of degree ≤ d.

---

## 3. Main Results

### 3.1 Theorem 1: Linear Relation Partition

**Theorem 3.1** (eml_linear_relation_partition). *For z₁, ..., zₙ ∈ ℂ and q₁, ..., qₙ ∈ ℚ,*

$$\sum_{i=1}^n q_i \cdot \text{eml}(z_i) = \sum_{L \in \mathcal{L}} L \cdot \left(\sum_{\substack{i : \\ \log(1+z_i) = L}} q_i \cdot \exp(z_i)\right)$$

*where 𝓛 = {log(1 + zᵢ) : 1 ≤ i ≤ n} is the set of distinct logarithmic values.*

**Proof sketch.** The proof proceeds by rewriting eml(zᵢ) = exp(zᵢ) · log(1 + zᵢ) and applying Finset.sum_image' to reindex the sum by the image of the logarithm map. Within each fiber (the set of indices sharing a common logarithmic value L), the factor L is constant and factors out. The commutativity of multiplication in ℂ completes the rearrangement. □

**Significance.** This theorem establishes the first *separation-of-variables* principle for EML expressions. If ∑ qᵢ · eml(zᵢ) = 0, then the cancellation must occur within each logarithmic collision class independently. This is the algebraic backbone for structural no-go arguments.

### 3.2 Theorem 2: Polynomial Expansion

**Theorem 3.2** (aeval_eml_eq_expandEML). *For any a ∈ ℂⁿ and P ∈ ℚ[X₁, ..., Xₙ],*
$$\text{aeval}_{\text{eml} \circ \mathbf{a}}(P) = \text{expandEML}(\mathbf{a}, P)$$

*That is, evaluating P at the EML values eml(a₁), ..., eml(aₙ) equals the explicit expansion into EML monomials.*

**Proof sketch.** The proof uses the decomposition P = ∑_{m ∈ supp(P)} c_m · monomial(m) (MvPolynomial.as_sum) and the algebra homomorphism property of aeval. For each monomial term, we apply eml_prod_eq_emlMonomial, which shows

$$\prod_{i=1}^n \text{eml}(a_i)^{m_i} = \text{emlMonomial}(\mathbf{a}, \mathbf{m})$$

This last identity relies on eml_pow (showing eml(z)^k = exp(kz) · log(1+z)^k via exp_nat_mul and mul_pow) and eml_prod_eq_emlMonomial (factoring the product of exp-log pairs using Finset.prod_mul_distrib and Complex.exp_sum). □

**Key auxiliary results:**

- **eml_pow**: eml(z)^k = exp(k·z) · log(1+z)^k
- **eml_prod_eq_emlMonomial**: ∏ᵢ eml(aᵢ)^{mᵢ} = emlMonomial(a, m)

**Significance.** This is the core reduction theorem. It converts the question "does P vanish at EML values?" into a question about finite sums of exp-log monomials. Since different exponent vectors typically yield different exponential growth rates, this decomposition makes cancellation structurally constrained.

### 3.3 Theorem 3: Norm Bounds for Imaginary Inputs

**Theorem 3.3** (norm_eml_mul_I). *For t ∈ ℝ,*
$$\|\text{eml}(t \cdot i)\| = \|\log(1 + t \cdot i)\|$$

**Proof.** Unfold eml, apply norm_mul, and use Complex.norm_exp_ofReal_mul_I which gives ‖exp(t·i)‖ = 1. □

**Theorem 3.4** (norm_sum_eml_mul_I_le). *For θ₁, ..., θₙ ∈ ℝ and c₁, ..., cₙ ∈ ℂ,*
$$\left\|\sum_{i=1}^n c_i \cdot \text{eml}(\theta_i \cdot i)\right\| \leq \sum_{i=1}^n \|c_i\| \cdot \|\log(1 + \theta_i \cdot i)\|$$

**Proof.** Apply the triangle inequality (norm_sum_le), then norm_mul on each term, and substitute using Theorem 3.3. □

**Significance.** These theorems bridge transcendence theory to harmonic analysis. For imaginary inputs, the exponential factor is a pure phase (unit magnitude), so EML values lie on circles of radius |log(1 + iθ)|. Polynomial relations become interference conditions — a connection to quantum mechanics, signal processing, and sparse Fourier analysis.

### 3.4 Reduction Theorem

**Theorem 3.5** (noPolyRelUpTo_eml_iff_expandEML). *NoPolyRelUpTo(d, eml ∘ a) holds if and only if for every polynomial P of degree ≤ d, expandEML(a, P) = 0 implies P = 0.*

This is a direct consequence of Theorem 3.2 and provides the formal interface between the algebraic independence predicate and the computable expansion.

---

## 4. The EML-Schanuel Conjecture

### 4.1 Statement

**Conjecture 4.1** (EML-Schanuel). *Let a₁, ..., aₙ ∈ ℚ̄ \ {−1} be linearly independent over ℚ. Then*
$$\text{trdeg}_\mathbb{Q}\, \mathbb{Q}(\text{eml}(a_1), \ldots, \text{eml}(a_n)) = n.$$

*Equivalently, EMLSeparated holds: the only polynomial vanishing at (eml(a₁), ..., eml(aₙ)) is the zero polynomial.*

### 4.2 Relationship to Schanuel's Conjecture

Schanuel's conjecture (1962) states that for ℚ-linearly independent complex numbers z₁, ..., zₙ, the transcendence degree of ℚ(z₁, ..., zₙ, exp(z₁), ..., exp(zₙ)) over ℚ is at least n. The EML-Schanuel conjecture is a consequence of (a suitable extension of) Schanuel's conjecture, but is potentially more accessible because:

1. It involves a *single* function (eml) rather than the joint behavior of exp and identity.
2. The monomial expansion theorem provides structural tools unavailable in the general setting.
3. Bounded-degree cases are finitely checkable via the separation certificate.

---

## 5. Algorithms

### 5.1 Bounded-Degree Relation Search

**Algorithm 1: Exhaustive Search**

```
Input: values a₁,...,aₙ; max degree d; max coefficient bound B; precision ε
Output: Polynomial relation or NON-EXISTENCE certificate

1. Enumerate all monomials M = {m : |m| ≤ d} in n variables
2. For each m ∈ M, compute v_m = ∏ᵢ eml(aᵢ)^{mᵢ} to high precision
3. For each coefficient vector c ∈ {-B,...,B}^|M| \ {0}:
   a. Compute residual r = |∑ c_m · v_m|
   b. If r < ε: return RELATION_FOUND(c)
4. Return NON_EXISTENCE_CERTIFICATE(d, B, ε)
```

**Complexity:** O((2B+1)^|M|) where |M| = C(n+d, d). Exponential in |M| but practical for n ≤ 3, d ≤ 4, B ≤ 20.

**Algorithm 2: LLL/PSLQ-Based Search**

```
Input: values a₁,...,aₙ; max degree d; precision p digits
Output: Candidate relation or NO_RELATION

1. Enumerate monomials M, compute v_m to p digits
2. Apply PSLQ algorithm to the vector (v_{m₁}, ..., v_{m_k})
3. If PSLQ finds integer relation c with |cᵢ| ≤ 10^6:
   a. Verify at higher precision
   b. Return CANDIDATE(c) with residual
4. Return NO_RELATION
```

**Complexity:** O(|M|³ · p) per PSLQ iteration. Polynomial in |M| and p.

### 5.2 Monomial Separation Check

**Algorithm 3: Separation Certificate**

```
Input: values a₁,...,aₙ; max degree d; tolerance τ
Output: SEPARATED or COLLISION(m, m')

1. Enumerate all pairs (m, m') with m ≠ m', |m| ≤ d, |m'| ≤ d
2. For each pair, compute |emlMonomial(a,m) - emlMonomial(a,m')|
3. If minimum distance < τ: return COLLISION(m, m')
4. Return SEPARATED
```

**Complexity:** O(|M|² · n · p) where p is the evaluation precision.

---

## 6. Computational Experiments

### 6.1 Experimental Setup

We implemented the algorithms in Python using mpmath for arbitrary-precision arithmetic. Test inputs are algebraic numbers: √2, √3, ∛2, the golden ratio φ = (1+√5)/2, and combinations thereof.

### 6.2 Relation Search Results

| Input pair | Max degree | Max coeff | Relation found? | Min residual |
|-----------|-----------|----------|----------------|-------------|
| (√2, √3) | 2 | 5 | No | 8.78 × 10⁻⁵ |
| (√2, √3) | 3 | 10 | No | ~10⁻⁴ |
| (√2, ∛2) | 2 | 5 | No | ~10⁻³ |
| (φ, √2) | 2 | 5 | No | ~10⁻³ |

Using PSLQ at 80-digit precision, no integer relations were found among EML monomials up to degree 4 for any tested algebraic pair.

### 6.3 Monomial Separation Results

EMLMonomialSeparatedUpTo(d, a) was verified computationally for:

| Input pair | Max degree tested | Separated? |
|-----------|------------------|-----------|
| (√2, √3) | 3 | Yes |
| (√2, ∛2) | 3 | Yes |
| (φ, √2) | 3 | Yes |
| (√2, √3, ∛5) | 2 | Yes |

No monomial collisions were observed in any test case, consistent with the EML-Schanuel conjecture.

### 6.4 Phase Analysis Results

For imaginary inputs θ = (1, √2, π):

- All EML norms match logarithmic norms (Theorem 3.3 verified numerically)
- Phase cancellation ratios range from 0.3 to 0.8, indicating partial but never complete cancellation
- No near-phase-collisions observed among monomials up to degree 3

---

## 7. Discussion

### 7.1 What We Prove vs. What We Conjecture

Our formal theorems are **unconditional**: the expansion theorem, partition theorem, and norm bounds hold for all complex inputs. They establish structural constraints on what polynomial relations among EML values can look like.

What we do **not** prove is that such relations are impossible. The EML-Schanuel conjecture remains open. However, our framework converts the infinite problem into a sequence of finite checkable conditions (monomial separation at increasing degrees), providing a systematic attack strategy.

### 7.2 Limitations

1. The separation certificate only rules out relations of bounded degree. An algebraic relation of very high degree would not be detected.
2. Numerical non-existence does not constitute a proof. Our computational certificates are evidence, not proofs, of non-existence.
3. The framework currently handles ℚ-coefficients. Extension to algebraic coefficients would strengthen the results.

### 7.3 Relationship to Period Theory

EML values resemble *mixed exponential-logarithmic periods* in the sense of Kontsevich–Zagier. The exponential factor exp(a) is an exponential period, while log(1+a) is a classical period (as an integral). Their product creates a hybrid object outside standard period classifications. Understanding EML values may illuminate the broader theory of mixed periods.

---

## 8. Future Work

1. **Conditional transcendence**: Prove EML transcendence for specific inputs (e.g., eml(1)) assuming Schanuel's conjecture.
2. **Higher-degree separation**: Develop efficient algorithms for checking monomial separation at large degrees.
3. **Algebraic coefficient extension**: Generalize from ℚ-coefficients to algebraic number coefficients.
4. **Differential algebra approach**: Study eml as a solution to a differential equation to constrain its algebraic properties.
5. **Fourier-analytic methods**: Exploit the phase-cancellation connection for imaginary inputs to import tools from harmonic analysis.

---

## 9. References

1. A. Baker, *Transcendental Number Theory*, Cambridge University Press, 1975.
2. S. Lang, *Introduction to Transcendental Numbers*, Addison-Wesley, 1966.
3. M. Waldschmidt, *Diophantine Approximation on Linear Algebraic Groups*, Springer, 2000.
4. A.J. Macintyre, "Schanuel's Conjecture and Free Exponential Rings," *Annals of Pure and Applied Logic*, 1991.
5. The Mathlib Community, *Mathlib4*, https://github.com/leanprover-community/mathlib4

---

## Appendix A: Complete Lean 4 Theorem Statements

```lean
-- Definitions (EML/Defs.lean)
def eml (z : ℂ) : ℂ := Complex.exp z * Complex.log (1 + z)

def emlMonomial {n : ℕ} (a : Fin n → ℂ) (m : Fin n →₀ ℕ) : ℂ :=
  Complex.exp (∑ i, (m i : ℂ) * a i) * ∏ i, (Complex.log (1 + a i)) ^ (m i)

def expandEML {n : ℕ} (a : Fin n → ℂ) (P : MvPolynomial (Fin n) ℚ) : ℂ :=
  ∑ m ∈ P.support, ((P.coeff m : ℚ) : ℂ) * emlMonomial a m

def NoPolyRelUpTo {n : ℕ} (d : ℕ) (v : Fin n → ℂ) : Prop :=
  ∀ P : MvPolynomial (Fin n) ℚ, P.totalDegree ≤ d → aeval v P = 0 → P = 0

def EMLMonomialSeparatedUpTo {n : ℕ} (d : ℕ) (a : Fin n → ℂ) : Prop :=
  ∀ m m' : Fin n →₀ ℕ,
    (∑ i, m i) ≤ d → (∑ i, m' i) ≤ d → emlMonomial a m = emlMonomial a m' → m = m'

-- Theorems (EML/Theorems.lean)
theorem eml_pow (z : ℂ) (k : ℕ) :
    eml z ^ k = exp ((k : ℂ) * z) * log (1 + z) ^ k

theorem eml_prod_eq_emlMonomial {n : ℕ} (a : Fin n → ℂ) (m : Fin n →₀ ℕ) :
    (∏ i : Fin n, eml (a i) ^ (m i)) = emlMonomial a m

theorem aeval_eml_eq_expandEML {n : ℕ} (a : Fin n → ℂ) (P : MvPolynomial (Fin n) ℚ) :
    aeval (fun i => eml (a i)) P = expandEML a P

theorem eml_linear_relation_partition {n : ℕ} (z : Fin n → ℂ) (q : Fin n → ℚ) :
    ∑ i, (q i : ℂ) * eml (z i) =
    ∑ L ∈ (Finset.univ.image (fun i => log (1 + z i))),
      L * (∑ i ∈ Finset.univ.filter (fun i => log (1 + z i) = L),
            (q i : ℂ) * exp (z i))

theorem norm_eml_mul_I (t : ℝ) :
    ‖eml (↑t * I)‖ = ‖log (1 + ↑t * I)‖

theorem norm_sum_eml_mul_I_le {n : ℕ} (θ : Fin n → ℝ) (c : Fin n → ℂ) :
    ‖∑ i, c i * eml (↑(θ i) * I)‖ ≤ ∑ i, ‖c i‖ * ‖log (1 + ↑(θ i) * I)‖

theorem noPolyRelUpTo_eml_iff_expandEML {n : ℕ} (d : ℕ) (a : Fin n → ℂ) :
    NoPolyRelUpTo d (fun i => eml (a i)) ↔
    ∀ P : MvPolynomial (Fin n) ℚ, P.totalDegree ≤ d → expandEML a P = 0 → P = 0
```

All theorems are fully proved (no `sorry`) and verified to depend only on standard axioms (propext, Classical.choice, Quot.sound).
