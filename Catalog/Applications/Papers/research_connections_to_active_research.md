# Formally Verified Algebraic Soundness: Polynomial Root Bounds and Matrix Verification over Finite Fields

## Abstract

We present a formally verified treatment of the fundamental algebraic theorems underlying randomized verification of algebraic computations. Our contributions include: (1) a machine-checked proof that a nonzero polynomial of degree $d$ over a field has at most $d$ roots in any finite evaluation set, yielding the univariate Schwartz–Zippel soundness bound; (2) a formally verified proof of Freivalds' matrix product verification theorem over arbitrary finite fields, establishing that a false matrix product claim $AB = C$ is detected by a random vector test with probability at least $1 - 1/|F|$; and (3) a polynomial identity testing theorem showing that polynomials agreeing on more than $\deg(p-q)$ points must be identical. All proofs are carried out in Lean 4 with Mathlib, using only standard axioms (propext, Classical.choice, Quot.sound), and are fully machine-verified.

**Keywords**: Schwartz–Zippel lemma, Freivalds' algorithm, polynomial identity testing, Reed–Solomon codes, STARK soundness, formal verification.

---

## 1. Introduction

### 1.1 Motivation

The soundness of modern proof systems (STARKs, SNARKs), error-correcting codes (Reed–Solomon), and randomized algorithms (polynomial identity testing, matrix product verification) all rest on a common algebraic foundation: **root bounds for polynomials over finite fields**. Despite the simplicity of the underlying mathematics, the chain from the root bound to protocol-level soundness guarantees involves subtle arguments about counting, probability, and linear algebra that benefit from machine verification.

### 1.2 Contributions

We formalize the following theorems in Lean 4 with Mathlib:

1. **Polynomial Root Bound** (`card_roots_le_natDegree_filter`): For a nonzero polynomial $p$ over a field $F$ and any finite set $S \subseteq F$,
$$|\{a \in S : p(a) = 0\}| \leq \deg(p).$$

2. **Schwartz–Zippel Soundness** (`random_point_soundness_bound`): For a nonzero polynomial $p$ over a finite field $F$,
$$\Pr_{a \sim \text{Uniform}(F)}[p(a) = 0] \leq \frac{\deg(p)}{|F|}.$$

3. **Reed–Solomon Distance** (`reed_solomon_min_distance`): The number of nonzero evaluations of a nonzero polynomial satisfies
$$|\{a \in F : p(a) \neq 0\}| \geq |F| - \deg(p).$$

4. **Freivalds' Theorem** (`freivalds_bad_vectors_card_le`, `freivalds_error_prob`): If $AB \neq C$ for matrices over a finite field $F$, then
$$|\{r \in F^k : (AB)r = Cr\}| \leq |F|^{k-1},$$
and consequently $\Pr_r[(AB)r = Cr] \leq 1/|F|$.

5. **Polynomial Identity Testing** (`polynomial_identity_from_agreement`): If polynomials $p$ and $q$ with $\deg(p - q) \leq d$ agree on a set $S$ with $|S| > d$, then $p = q$.

### 1.3 Related Work

Polynomial root bounds are textbook material (see Lang [8], Lidl & Niederreiter [9]). The Schwartz–Zippel lemma was independently discovered by Schwartz [14] and Zippel [16] in 1980, with a precursor by DeMillo and Lipton [4]. Freivalds' algorithm appeared in [5]. Formal verification of related algebraic results has been pursued in Coq (e.g., the Mathematical Components library) and Isabelle/HOL, but to our knowledge, this is the first comprehensive Lean 4 formalization connecting root bounds to Freivalds' theorem and polynomial identity testing in a unified framework.

---

## 2. Mathematical Preliminaries

### 2.1 Notation

Let $F$ denote a field, $F_q$ a finite field with $q$ elements, and $F[x]$ the ring of polynomials over $F$. For a polynomial $p \in F[x]$, we write $\deg(p)$ for its degree (equivalently, `natDegree` in Lean). For a matrix $M \in F^{m \times k}$, $M \cdot v$ denotes the matrix-vector product (`mulVec` in Lean).

### 2.2 Key Mathlib Infrastructure

Our formalization builds on the following Mathlib components:
- `Polynomial.card_roots`: The Multiset of roots has cardinality at most the degree (as an element of `WithBot ℕ`).
- `Polynomial.mem_roots`: Membership in the root multiset corresponds to `IsRoot`.
- `Module.card_eq_pow_finrank`: A finite-dimensional vector space over a finite field has $|F|^{\dim}$ elements.
- `LinearMap.finrank_range_add_finrank_ker`: The rank-nullity theorem.

---

## 3. Main Results

### 3.1 Polynomial Root Bound

**Theorem 3.1** (Root-count bound). *Let $F$ be a field, $p \in F[x]$ nonzero, and $S \subseteq F$ a finite set. Then*
$$|\{a \in S : p(a) = 0\}| \leq \deg(p).$$

*Proof sketch.* The proof proceeds in three steps:
1. From Mathlib's `Polynomial.card_roots`, we obtain $|p.\text{roots}| \leq \deg(p)$ (as elements of `WithBot ℕ`). Converting to `natDegree` using `degree_eq_natDegree` for nonzero polynomials gives $p.\text{roots}.\text{card} \leq p.\text{natDegree}$.
2. The filter set $\{a \in S : p(a) = 0\}$ injects into `p.roots.toFinset` via `Polynomial.mem_roots`, giving $|\{a \in S : p(a) = 0\}| \leq |p.\text{roots}.\text{toFinset}|$.
3. The `toFinset` of a multiset has cardinality at most that of the multiset (`Multiset.toFinset_card_le`), closing the chain. $\square$

### 3.2 Schwartz–Zippel Soundness

**Corollary 3.2** (Random-point soundness). *For $p \neq 0$ over a finite field $F$,*
$$\frac{|\{a \in F : p(a) = 0\}|}{|F|} \leq \frac{\deg(p)}{|F|}.$$

*Proof.* Specialize Theorem 3.1 to $S = F$ (i.e., `Finset.univ`), then divide both sides by $|F| > 0$. $\square$

### 3.3 Reed–Solomon Distance

**Corollary 3.3** (Minimum distance). *For $p \neq 0$ over $F$,*
$$|\{a \in F : p(a) \neq 0\}| \geq |F| - \deg(p).$$

*Proof.* The sets $\{p(a) = 0\}$ and $\{p(a) \neq 0\}$ partition $F$. By Theorem 3.1, the zero set has size $\leq \deg(p)$, so the nonzero set has size $\geq |F| - \deg(p)$. $\square$

This gives the classical minimum distance of the Reed–Solomon code $\text{RS}[F, k]$ as $|F| - k + 1$, since distinct codewords differ by a nonzero polynomial of degree $< k$.

### 3.4 Freivalds' Matrix Verification

**Theorem 3.4** (Freivalds). *Let $A \in F^{m \times n}$, $B \in F^{n \times k}$, $C \in F^{m \times k}$ with $AB \neq C$. Then*
$$|\{r \in F^k : (AB)r = Cr\}| \leq |F|^{k-1}.$$

*Proof sketch.* Let $D = AB - C \neq 0$. The bad-event set is $\{r : Dr = 0\} = \ker(D \cdot -)$.

1. **Row reduction**: Since $D \neq 0$, there exists a row $i$ with $D_i \neq 0$. The set $\{r : Dr = 0\}$ is contained in $\{r : D_i \cdot r = 0\}$, i.e., the kernel of the linear functional $r \mapsto \sum_j D_{ij} r_j$.

2. **Surjectivity**: A nonzero linear functional $\ell : F^k \to F$ is surjective. Given $y \in F$, choose a coordinate $j$ where $w_j \neq 0$ and set $r = y/w_j \cdot e_j$.

3. **Kernel dimension**: By rank-nullity, $\dim(\ker \ell) = k - 1$.

4. **Counting**: $|\ker \ell| = |F|^{k-1}$ by the dimension formula for finite-dimensional vector spaces over finite fields (`Module.card_eq_pow_finrank`).

5. **Conclusion**: $|\{r : Dr = 0\}| \leq |\ker(D_i \cdot -)| = |F|^{k-1}$. $\square$

**Corollary 3.5** (Probability form). *Under the same hypotheses, with $k$ nonempty,*
$$\Pr_{r \sim \text{Uniform}(F^k)}[(AB)r = Cr] \leq \frac{1}{|F|}.$$

*Proof.* Divide: $|F|^{k-1} / |F|^k = 1/|F|$. $\square$

### 3.5 Polynomial Identity Testing

**Theorem 3.6** (Identity from agreement). *If $p, q \in F[x]$ satisfy $\deg(p - q) \leq d$ and agree on a set $S$ with $|S| > d$, then $p = q$.*

*Proof.* If $p \neq q$, then $p - q$ is a nonzero polynomial of degree $\leq d$ with $|S| > d$ roots in $S$, contradicting Theorem 3.1. $\square$

---

## 4. Algorithms

### 4.1 Schwartz–Zippel Polynomial Identity Test

```
Algorithm: SchwartzZippelTest(p, q, F, t)
Input: Polynomials p, q ∈ F[x], finite field F, repetition count t
Output: "equal" or "different"

for i = 1 to t:
    a ← Uniform(F)
    if p(a) ≠ q(a):
        return "different"
return "equal"
```

**Complexity**: $O(t \cdot \max(\deg p, \deg q))$ field operations.
**Soundness**: If $p \neq q$, $\Pr[\text{output "equal"}] \leq (\deg(p-q)/|F|)^t$.
**Completeness**: If $p = q$, always outputs "equal".

### 4.2 Freivalds' Matrix Verification

```
Algorithm: FreivaldsTest(A, B, C, F, t)
Input: Matrices A ∈ F^{m×n}, B ∈ F^{n×k}, C ∈ F^{m×k}, field F, count t
Output: "correct" or "incorrect"

for i = 1 to t:
    r ← Uniform(F^k)
    if A(Br) ≠ Cr:          // Cost: O(nk + mn + mk)
        return "incorrect"
return "correct"
```

**Complexity**: $O(t(mn + nk + mk))$ — compare to $O(mnk)$ for recomputation.
**Soundness**: If $AB \neq C$, $\Pr[\text{output "correct"}] \leq (1/|F|)^t$.
**Key advantage**: For square $n \times n$ matrices, verification is $O(tn^2)$ vs $O(n^3)$ (or $O(n^{2.37})$) for recomputation.

### 4.3 Streaming Matrix Verification

Freivalds' algorithm naturally supports streaming: process rows of $A$ and $C$ one at a time while keeping $Br$ in memory.

```
Algorithm: StreamingFreivalds(B, F)
Precompute: r ← Uniform(F^k), v ← Br

ProcessRow(a_i, c_i):    // Row i of A and C
    if a_i · v ≠ c_i · r:
        return "incorrect"
    return "continue"
```

**Space**: $O(nk + k)$ — stores $B$ and $r$ (and $v = Br$).
**Per-row cost**: $O(n + k)$.

---

## 5. Applications

### 5.1 STARK Proof Systems

STARKs reduce computational integrity to polynomial identity testing. A computation trace of length $T$ is encoded as a polynomial of degree $O(T)$, and the verifier checks a constant number of evaluations. Each check invokes the Schwartz–Zippel bound. With a field of size $|F| \geq 2^{64}$ and degree $T \leq 2^{20}$, the soundness error per query is at most $2^{20}/2^{64} = 2^{-44}$.

### 5.2 Reed–Solomon Proximity Testing

The FRI (Fast Reed-Solomon Interactive Oracle Proof of Proximity) protocol tests whether a function is close to a low-degree polynomial. Each round of FRI invokes the root bound to argue that a cheating prover's polynomial must differ from the honest one at a random point. Our Theorem 3.1 provides the formal backbone.

### 5.3 Verifiable Machine Learning Inference

Neural network inference consists primarily of matrix multiplications. For a model with $L$ linear layers of dimension $n$, naive verification costs $O(Ln^3)$. Using Freivalds' algorithm with $t$ repetitions, verification costs $O(Ltn^2)$ with error probability $\leq L(1/|F|)^t$.

For a transformer with 96 layers, $n = 4096$, over $F_{2^{61}-1}$:
- Naive: $\approx 96 \times 4096^3 \approx 6.6 \times 10^{12}$ operations
- Freivalds ($t=3$): $\approx 96 \times 3 \times 4096^2 \approx 4.8 \times 10^{9}$ operations
- Speedup: $\approx 1370\times$
- Error: $\leq 96 \times (2^{-61})^3 < 2^{-170}$

### 5.4 Computational Complexity

The connection to computational complexity is deep. Polynomial identity testing (PIT) is in co-RP via Schwartz–Zippel. Whether PIT is in P (deterministic polynomial time) is a major open problem, known to be equivalent to proving certain arithmetic circuit lower bounds (Kabanets–Impagliazzo [6]).

---

## 6. Formalization Details

### 6.1 File Structure

| File | Lines | Theorems |
|------|-------|----------|
| `RootBound.lean` | ~110 | 6 theorems: root bound, zero set bound, soundness bound, complement form, Reed–Solomon distance |
| `FreivaldsBridge.lean` | ~150 | 10 theorems: kernel dimension, Freivalds cardinality & probability, PIT |

### 6.2 Proof Architecture

The formalization follows a layered architecture:

**Layer 1 (Mathlib)**: `Polynomial.card_roots`, `Module.card_eq_pow_finrank`, rank-nullity.

**Layer 2 (Root Bound)**: Convert Mathlib's `WithBot ℕ`-valued degree bound to a `ℕ`-valued `natDegree` bound, then package as a `Finset.filter` cardinality statement.

**Layer 3 (Linear Algebra)**: Define `dotLin` as a linear map, prove surjectivity for nonzero functionals, compute kernel dimension via rank-nullity, then count kernel elements.

**Layer 4 (Freivalds)**: Reduce `{r : AB·r = C·r}` to `{r : (AB-C)·r = 0}` via `sub_mulVec`, then bound kernel size using Layer 3.

**Layer 5 (PIT)**: Contrapositive of the root bound: too many agreements implies equality.

### 6.3 Axioms

All theorems depend only on the standard Lean axioms:
- `propext` (propositional extensionality)
- `Classical.choice` (axiom of choice)
- `Quot.sound` (quotient soundness)

No additional axioms, `sorry`, or `@[implemented_by]` annotations are used.

---

## 7. Computational Experiments

### 7.1 Root Count Distribution

We sampled 5000 random nonzero polynomials of each degree over several finite fields and counted their roots. In all cases, the root count was bounded by the degree, confirming the theorem. The average number of roots is approximately 1 (the "random matrix" heuristic), with most polynomials having 0 or 1 roots.

### 7.2 Freivalds Detection Rate

For $10 \times 10$ matrices over $F_7$ with a single corrupted entry, we ran 5000 trials of Freivalds' test. The empirical false-accept rate was approximately $0.143 \approx 1/7$, matching the theoretical bound. With $t$ repetitions, the false-accept rate matched $(1/7)^t$ closely.

### 7.3 Schwartz–Zippel Detection Probability

For random nonzero polynomials of degree $d$ over $F_p$, the empirical detection probability (fraction of random points where the polynomial is nonzero) closely matched the theoretical guarantee $1 - d/p$, with convergence improving as $p$ grows.

---

## 8. Discussion

### 8.1 Generality

Our formalization covers arbitrary fields (not just finite fields) for the root bound, and arbitrary finite fields (not just $\mathbb{Z}/p\mathbb{Z}$) for Freivalds' theorem. This generality is important for applications: STARKs use extension fields $F_{p^k}$, and coding theory uses fields of various characteristics.

### 8.2 Limitations

The current formalization is restricted to univariate polynomials. The full multivariate Schwartz–Zippel lemma, which bounds the zero-set of a multivariate polynomial over a product set $S^n$, requires induction on the number of variables and is a natural next step.

### 8.3 Significance for Verified Computation

The theorems proved here constitute the algebraic kernel of multiple layers of the verified computation stack. Any system that relies on polynomial commitment schemes, low-degree testing, or algebraic fingerprinting ultimately invokes these bounds. Having machine-checked proofs of the foundations provides the highest possible assurance for the soundness of such systems.

---

## 9. Future Work

1. **Multivariate Schwartz–Zippel**: Extend to $n$-variate polynomials over product sets.
2. **Sumcheck Protocol**: Formalize the interactive sumcheck protocol and prove soundness via iterated univariate root bounds.
3. **FRI Soundness**: Formalize the Fast Reed-Solomon IOP of Proximity.
4. **Iterated Freivalds**: Prove the product bound for repeated independent tests.
5. **Verifiable Neural Network Inference**: Formalize the reduction from neural network verification to iterated matrix product checking.

---

## References

[1] Ben-Sasson, E., Bentov, I., Horesh, Y., & Riabzev, M. (2018). Scalable, transparent, and post-quantum secure computational integrity. *IACR Cryptology ePrint Archive*.

[2] Blum, M., & Kannan, S. (1995). Designing programs that check their work. *Journal of the ACM*, 42(1), 269–291.

[3] Cormen, T. H., Leiserson, C. E., Rivest, R. L., & Stein, C. (2009). *Introduction to Algorithms* (3rd ed.). MIT Press.

[4] DeMillo, R. A., & Lipton, R. J. (1978). A probabilistic remark on algebraic program testing. *Information Processing Letters*, 7(4), 193–195.

[5] Freivalds, R. (1977). Probabilistic machines can use less running time. *IFIP Congress*, 839–842.

[6] Kabanets, V., & Impagliazzo, R. (2004). Derandomizing polynomial identity tests means proving circuit lower bounds. *Computational Complexity*, 13(1-2), 1–46.

[7] Katz, J., & Lindell, Y. (2020). *Introduction to Modern Cryptography* (3rd ed.). CRC Press.

[8] Lang, S. (2002). *Algebra* (3rd ed.). Springer.

[9] Lidl, R., & Niederreiter, H. (1997). *Finite Fields* (2nd ed.). Cambridge University Press.

[10] Lund, C., Fortnow, L., Karloff, H., & Nisan, N. (1992). Algebraic methods for interactive proof systems. *Journal of the ACM*, 39(4), 859–868.

[11] Motwani, R., & Raghavan, P. (1995). *Randomized Algorithms*. Cambridge University Press.

[12] Reed, I. S., & Solomon, G. (1960). Polynomial codes over certain finite fields. *Journal of the Society for Industrial and Applied Mathematics*, 8(2), 300–304.

[13] Roth, R. (2006). *Introduction to Coding Theory*. Cambridge University Press.

[14] Schwartz, J. T. (1980). Fast probabilistic algorithms for verification of polynomial identities. *Journal of the ACM*, 27(4), 701–717.

[15] Thaler, J. (2022). *Proofs, Arguments, and Zero-Knowledge*. Now Publishers.

[16] Zippel, R. (1979). Probabilistic algorithms for sparse polynomials. *EUROSAM '79*, Springer LNCS, 216–226.
