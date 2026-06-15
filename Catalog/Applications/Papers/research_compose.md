# Circuit-Aware Polynomial Identity Testing and Algebraic Fingerprinting: A Formally Verified Framework

## Abstract

We present a formally verified framework connecting algebraic circuit complexity, polynomial identity testing (PIT), and streaming verification through algebraic fingerprinting. Our main contributions are:

1. **A certified Schwartz–Zippel theorem in subtype form**, stating that a nonzero $n$-variate polynomial of total degree $d$ over a finite field $K$ has at most $d \cdot |K|^{n-1}$ zeros, formulated as a cardinality bound on the zero-set subtype.

2. **An abstract fingerprinting metatheorem** (`nonzero_codeword_probe_collision_bound`): for any injective polynomial encoding with bounded degree, distinct inputs collide on at most $N - 1$ evaluation points over a finite field of size $|K|$.

3. **A concrete fingerprint collision bound** for vector-polynomial encodings, with specializations to bitstring equality testing.

4. **A contrapositive "many zeros force triviality" theorem**, providing the logical bridge to circuit lower bounds: if a polynomial's zero set exceeds the Schwartz–Zippel bound for its degree, the polynomial must be identically zero.

All theorems are proved in Lean 4 using Mathlib, with proofs depending only on the standard axioms (propext, Classical.choice, Quot.sound). No sorry remains in the final formalization.

## 1. Introduction

### 1.1 Motivation

Polynomial identity testing—the problem of determining whether a given arithmetic circuit computes the zero polynomial—is one of the central problems in algebraic complexity theory. The celebrated Schwartz–Zippel lemma [Schwartz 1980, Zippel 1979] provides a randomized algorithm: evaluate the polynomial at a random point over a large enough field, and a nonzero polynomial will produce a nonzero value with high probability.

Despite its simplicity and power, the Schwartz–Zippel lemma sits at the nexus of several deep research programs:

- **Derandomization of PIT** (Kabanets–Impagliazzo 2004): Deterministic PIT implies either circuit lower bounds or factoring algorithms.
- **Algebraic fingerprinting** (Freivalds 1979, Rabin–Karp 1987): Polynomial evaluation at random points enables efficient streaming equality testing.
- **Interactive proofs** (Lund–Fortnow–Karloff–Nisan 1992): The sum-check protocol reduces verification of complex computations to polynomial evaluations.

Our work provides the first formally verified framework that unifies these connections through a common algebraic foundation.

### 1.2 Contributions

We formalize the following hierarchy of results:

| Theorem | Statement | Significance |
|---------|-----------|-------------|
| `vecPoly_injective` | The vector-polynomial encoding is injective | Encoding faithfulness |
| `poly_eval_agreement_bound` | Distinct polynomials of degree $< N$ agree on $\leq N-1$ points | Root-counting core |
| `fingerprint_collision_bound` | Distinct vectors collide on $\leq n-1$ evaluation points | Streaming soundness |
| `nonzero_codeword_probe_collision_bound` | Abstract fingerprinting metatheorem | Universal framework |
| `schwartz_zippel_subtype` | Subtype-form multivariate Schwartz–Zippel | PIT soundness |
| `many_zeros_force_zero` | Too many zeros $\implies$ polynomial is zero | Circuit lower bound bridge |

### 1.3 Related Work

The Schwartz–Zippel lemma has been formalized in various proof assistants. Our contribution is novel in:
- Providing the **subtype-counting formulation** suitable for complexity-theoretic applications.
- Establishing the **abstract fingerprinting metatheorem** as a reusable framework.
- Proving the **contrapositive form** that directly connects to circuit lower bounds.
- Building a **unified file** where all results compose cleanly.

## 2. Definitions and Notation

### 2.1 Vector-Polynomial Encoding

**Definition** (`vecPoly`). For a vector $a = (a_0, \ldots, a_{n-1}) \in K^n$, define

$$\text{vecPoly}(a) = \sum_{i=0}^{n-1} a_i X^i \in K[X].$$

In Lean 4:
```lean
def vecPoly {K : Type*} [Semiring K] {n : ℕ} (a : Fin n → K) : Polynomial K :=
  ∑ i : Fin n, Polynomial.C (a i) * Polynomial.X ^ (i : ℕ)
```

**Definition** (`bitPoly`). For a bitstring $s : \text{Fin } n \to \text{Fin } 2$, define $\text{bitPoly}(s) = \text{vecPoly}(\text{cast}(s))$ where the cast sends $\text{Fin } 2$ to $K$ via the natural embedding.

### 2.2 Zero Sets and Collision Sets

For a multivariate polynomial $f \in K[X_1, \ldots, X_n]$, the **zero set** is
$$Z(f) = \{x \in K^n : f(x) = 0\}.$$

For univariate polynomials $p, q \in K[X]$, the **collision set** is
$$\text{Coll}(p, q) = \{x \in K : p(x) = q(x)\} = Z(p - q).$$

## 3. Main Results

### 3.1 Coefficient Characterization

**Theorem** (`vecPoly_coeff`). For $a \in K^n$ and $j \in \mathbb{N}$:
$$(\text{vecPoly}(a))_j = \begin{cases} a_j & \text{if } j < n \\ 0 & \text{otherwise.} \end{cases}$$

*Proof sketch.* Expand the sum; only the $i = j$ term contributes to the $j$-th coefficient, using orthogonality of the monomials $X^i$.

### 3.2 Injectivity

**Theorem** (`vecPoly_injective`). The map $\text{vecPoly} : K^n \to K[X]$ is injective for any nontrivial semiring $K$.

*Proof sketch.* If $\text{vecPoly}(a) = \text{vecPoly}(b)$, then by `vecPoly_coeff`, $a_i = b_i$ for all $i < n$.

**Corollary** (`vecPoly_sub_ne_zero`). If $a \neq b$ then $\text{vecPoly}(a) - \text{vecPoly}(b) \neq 0$.

### 3.3 Degree Bounds

**Theorem** (`vecPoly_natDegree_lt`). For $a \in K^n$ with $K$ nontrivial, either $\deg(\text{vecPoly}(a)) < n$ or $n = 0$.

**Theorem** (`vecPoly_sub_natDegree_lt`). If $n > 0$, then $\deg(\text{vecPoly}(a) - \text{vecPoly}(b)) < n$.

*Proof sketch.* Each polynomial is a sum of terms $c_i X^i$ with $i < n$. The degree of the sum (or difference) is bounded by the maximum degree of the summands.

### 3.4 Root Counting Core

**Theorem** (`poly_eval_agreement_bound`). Let $p, q \in K[X]$ be distinct polynomials over a finite field with $\deg(p - q) < N$. Then
$$|\{x \in K : p(x) = q(x)\}| \leq N - 1.$$

*Proof.* The agreement set equals the root set of $p - q$. Since $p \neq q$, we have $p - q \neq 0$. A nonzero polynomial over a field has at most $\deg(p - q)$ roots (by `Polynomial.card_roots'`). Since $\deg(p - q) < N$, the root count is $\leq N - 1$.

### 3.5 The Fingerprint Collision Bound

**Theorem** (`fingerprint_collision_bound`). For $a, b \in K^n$ with $a \neq b$ and $n > 0$:
$$|\{x \in K : \text{vecPoly}(a)(x) = \text{vecPoly}(b)(x)\}| \leq n - 1.$$

*Proof.* Apply `poly_eval_agreement_bound` with $N = n$. The hypotheses are satisfied by `vecPoly_injective` (giving $p \neq q$) and `vecPoly_sub_natDegree_lt` (giving degree $< n$).

**Corollary** (Error probability). If $x$ is chosen uniformly at random from $K$:
$$\Pr[\text{vecPoly}(a)(x) = \text{vecPoly}(b)(x)] \leq \frac{n - 1}{|K|}.$$

### 3.6 Abstract Fingerprinting Metatheorem

**Theorem** (`nonzero_codeword_probe_collision_bound`). Let $\text{encode} : \alpha \to K[X]$ be an injective map with the property that for all $a \neq b$, $\deg(\text{encode}(a) - \text{encode}(b)) < N$. Then for all $a \neq b$:
$$|\{x \in K : \text{encode}(a)(x) = \text{encode}(b)(x)\}| \leq N - 1.$$

This theorem abstracts the fingerprinting paradigm: any injective polynomial encoding with bounded degree automatically yields a randomized equality test with controlled error. Instantiations include:
- $\alpha = K^n$ with $\text{encode} = \text{vecPoly}$: vector equality testing.
- $\alpha = \{0,1\}^n$ with $\text{encode} = \text{bitPoly}$: bitstring streaming equality.
- $\alpha$ = circuit outputs with $\text{encode}$ = the polynomial computed by the circuit: PIT.

### 3.7 Multivariate Schwartz–Zippel (Subtype Form)

**Theorem** (`schwartz_zippel_subtype`). Let $f \in K[X_1, \ldots, X_n]$ be a nonzero polynomial of total degree $d$ over a finite field $K$. Then:
$$|\{x \in K^n : f(x) = 0\}| \leq d \cdot |K|^{n-1}.$$

Stated formally as a bound on `Fintype.card {x : Fin n → K // MvPolynomial.eval x f = 0}`.

*Proof.* Induction on $n$. For $n = 0$: a nonzero constant has no zeros. For $n + 1$: decompose $f$ via `MvPolynomial.finSuccEquiv` into a univariate polynomial with multivariate coefficients. Split the zero set based on whether the leading coefficient vanishes, and apply the inductive hypothesis to each part.

### 3.8 Many Zeros Force Triviality

**Theorem** (`many_zeros_force_zero`). If
$$d \cdot |K|^{n-1} < |\{x \in K^n : f(x) = 0\}|$$
then $f = 0$.

*Proof.* Contrapositive of `schwartz_zippel_subtype`.

This theorem is the logical bridge to circuit lower bounds: if a circuit with bounded multiplicative complexity $m$ computes a polynomial of degree $\leq 2^m$, and the circuit's zero set exceeds $2^m \cdot |K|^{n-1}$, then the circuit must compute the zero polynomial.

## 4. Algorithms

### 4.1 Algebraic Fingerprint Equality Test

**Input:** Vectors $a, b \in \mathbb{F}_p^n$, number of trials $k$.
**Output:** "Equal" or "Not equal."

```
Algorithm AlgebraicFingerprintTest(a, b, p, k):
  for trial = 1 to k:
    r ← random element of F_p
    fa ← Σᵢ aᵢ rⁱ mod p   // Horner's method: O(n) time
    fb ← Σᵢ bᵢ rⁱ mod p
    if fa ≠ fb:
      return "Not equal"    // Certain
  return "Equal"            // Error ≤ ((n-1)/p)^k
```

**Complexity:** Time $O(nk)$, space $O(\log p)$, randomness $O(k \log p)$ bits.

**Soundness:** By `fingerprint_collision_bound`, if $a \neq b$, each trial detects the difference with probability $\geq 1 - (n-1)/p$. With $k$ independent trials, false positive probability $\leq ((n-1)/p)^k$.

### 4.2 Schwartz–Zippel PIT

**Input:** Arithmetic circuit $C$ with $n$ inputs over $\mathbb{F}_p$, degree bound $d$, trials $k$.
**Output:** "Zero" or "Nonzero."

```
Algorithm SchwartzZippelPIT(C, n, d, p, k):
  for trial = 1 to k:
    r ← random element of F_p^n
    if C(r) ≠ 0:
      return "Nonzero"      // Certain
  return "Zero"             // Error ≤ (d/p)^k
```

**Complexity:** Time $O(|C| \cdot k)$, space $O(n \log p)$.

**Soundness:** By `schwartz_zippel_subtype`, if $C$ computes a nonzero polynomial of degree $\leq d$, each trial detects nonzeroness with probability $\geq 1 - d/p$.

### 4.3 Streaming Fingerprint Verifier

**Input:** Two data streams $S_1, S_2$ of length $n$ over alphabet $[q]$, field $\mathbb{F}_p$ with $p > q$.
**Output:** "Equal" or "Different."

```
Algorithm StreamingVerifier(S1, S2, p):
  r ← random element of F_p
  fp1 ← 0; fp2 ← 0; power ← 1
  for i = 1 to n:
    fp1 ← (fp1 + S1[i] * power) mod p
    fp2 ← (fp2 + S2[i] * power) mod p
    power ← (power * r) mod p
  return fp1 = fp2 ? "Equal" : "Different"
```

**Complexity:** Time $O(n)$, space $O(\log p)$ (streaming).

This is the algorithm underlying Rabin–Karp hashing and streaming deduplication.

## 5. Applications

### 5.1 Streaming Equality Verification

Using `fingerprint_collision_bound` with vectors over $\mathbb{F}_p$ for a Mersenne prime $p = 2^{61} - 1$:
- Data length: $n = 10^9$ (1 billion elements)
- Fingerprint size: 61 bits
- Error probability: $\leq (10^9 - 1)/(2^{61} - 1) \approx 4.3 \times 10^{-10}$
- After 3 trials: $\leq 8 \times 10^{-29}$

### 5.2 Rabin–Karp String Matching

Pattern search in text of length $N$ with pattern of length $m$:
- Preprocessing: $O(m)$
- Search: $O(N)$ expected time
- Error per position: $\leq (m-1)/p$
- Total false positive probability: $\leq N(m-1)/p$

### 5.3 Verifiable Matrix Multiplication (Freivalds)

Verify $C = AB$ for $n \times n$ matrices:
- Verification cost: $O(n^2)$ per trial (vs $O(n^3)$ for recomputation)
- Error: $\leq 1/p$ per trial
- By `schwartz_zippel_subtype` with degree 1

## 6. Computational Experiments

### 6.1 Fingerprint Collision Statistics

We tested the fingerprint collision bound experimentally over $\text{GF}(101)$ with vectors of length $n = 10$.

| Vector pair | Theoretical bound | Observed collisions | Bound satisfied |
|-------------|-------------------|---------------------|-----------------|
| Random pair 1 | 9 | 1 | ✓ |
| Random pair 2 | 9 | 0 | ✓ |
| Differ by 1 entry | 9 | 1 | ✓ |

In all cases, the observed collision count was well below the theoretical bound of $n - 1 = 9$.

### 6.2 Schwartz–Zippel Tightness

Over $\text{GF}(7)^2$ with various polynomials:

| Polynomial | Degree | Zeros | Bound ($d \cdot 7$) | Ratio |
|-----------|--------|-------|---------------------|-------|
| $x + y$ | 1 | 7 | 7 | 1.00 |
| $xy$ | 2 | 13 | 14 | 0.93 |
| $x^2 + y^2 - 1$ | 2 | 8 | 14 | 0.57 |
| $x^3 + y^3$ | 3 | 19 | 21 | 0.90 |

The bound is tight for the linear polynomial $x + y$ and near-tight for products of linear factors.

### 6.3 Error Amplification

For vectors of length $n = 16$ over $\text{GF}(101)$:
- Base error: $(n-1)/p = 15/101 \approx 0.149$
- After 5 trials: $\approx 7.3 \times 10^{-5}$
- After 10 trials: $\approx 5.4 \times 10^{-9}$
- After 20 trials: $\approx 2.9 \times 10^{-17}$

## 7. Discussion

### 7.1 Significance

Our formalization establishes the first certified bridge between:
- **Syntax** (circuit structure / multiplicative complexity)
- **Semantics** (polynomial zero-set size / PIT soundness)
- **Algorithms** (fingerprinting / streaming verification)

The `many_zeros_force_zero` theorem, in particular, provides the exact logical form needed for circuit lower bound arguments: if a circuit's behavior (large zero set) is inconsistent with its complexity (bounded degree), then the circuit must be trivial.

### 7.2 Limitations

Our current formalization does not include:
- Formal arithmetic circuit types with syntactic degree analysis
- Explicit hitting set constructions
- The full Kabanets–Impagliazzo conditional theorem
- Probability spaces for stating error bounds as actual probabilities

These are natural next steps identified in our future directions.

### 7.3 Relationship to Existing Formalizations

The project builds on an existing catalog of verified results including a Schwartz–Zippel lemma (`mvpolynomial_zero_set_card_le_totalDegree_mul_pow`) proved by induction on the number of variables. Our contribution reformulates this in subtype-counting form, connects it to the fingerprinting paradigm, and establishes the abstract metatheorem that unifies all applications.

## 8. Future Work

See `FUTURE_DIRECTIONS.md` for detailed next steps, including:
1. Explicit hitting sets for bounded-degree circuits
2. Formal Kabanets–Impagliazzo implications
3. Streaming lower bounds from fingerprint impossibility
4. Cryptographic collision resistance from root bounds
5. Sum-check protocol formalization

## 9. References

1. Schwartz, J. T. "Fast Probabilistic Algorithms for Verification of Polynomial Identities." *JACM* 27(4), 1980.
2. Zippel, R. "Probabilistic Algorithms for Sparse Polynomials." *EUROSAM '79*, LNCS 72, 1979.
3. Kabanets, V. and Impagliazzo, R. "Derandomizing Polynomial Identity Tests Means Proving Circuit Lower Bounds." *Computational Complexity* 13, 2004.
4. Freivalds, R. "Fast Probabilistic Algorithms." *MFCS '79*, LNCS 74, 1979.
5. Karp, R. M. and Rabin, M. O. "Efficient Randomized Pattern-Matching Algorithms." *IBM Journal of R&D* 31(2), 1987.
6. Lund, C., Fortnow, L., Karloff, H., and Nisan, N. "Algebraic Methods for Interactive Proof Systems." *JACM* 39(4), 1992.
7. The Mathlib Community. "Mathlib4." https://github.com/leanprover-community/mathlib4, 2024.
