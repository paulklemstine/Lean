# Future Directions: Algebraic Verification Infrastructure

This document outlines concrete next steps for extending the formally verified algebraic soundness stack established in this work.

---

## 1. Multivariate Schwartz–Zippel over Finite Grids

**Hypothesis**: The full Schwartz–Zippel lemma for multivariate polynomials can be proved by induction on the number of variables, reducing each step to the univariate root bound.

**Statement**: Let $p \in F[x_1, \ldots, x_n]$ be a nonzero polynomial of total degree $d$ over a finite field $F$, and let $S \subseteq F$ be a finite evaluation set. Then
$$\Pr_{a \in S^n}[p(a) = 0] \le \frac{d}{|S|}.$$

**Proof Strategy**:
1. View $p$ as a univariate polynomial in $x_n$ with coefficients in $F[x_1, \ldots, x_{n-1}]$.
2. The leading coefficient (as a polynomial in $x_1, \ldots, x_{n-1}$) is nonzero and of degree $\le d - \deg_{x_n}(p)$.
3. Apply the inductive hypothesis to the leading coefficient, then apply the univariate root bound to the specialization.
4. Combine via a union bound.

**Formalization Approach**: Use `MvPolynomial` from Mathlib. The key challenge is formalizing the "view as univariate" step and the degree bookkeeping.

**Cross-domain Connections**: This is the core lemma behind multi-round interactive proofs (sumcheck protocol), multivariate polynomial commitment schemes, and algebraic proof systems like Spartan and HyperPlonk.

---

## 2. Formal Reed–Solomon Minimum Distance and Decoding

**Hypothesis**: The Reed–Solomon code $\text{RS}[F, k]$ (evaluations of degree-$< k$ polynomials over all of $F$) has minimum distance $|F| - k + 1$, achieving the Singleton bound.

**Statement**: For distinct codewords $c_1, c_2 \in \text{RS}[F, k]$, the Hamming distance satisfies $d_H(c_1, c_2) \ge |F| - k + 1$.

**Proof Strategy**: The difference $c_1 - c_2$ is the evaluation of a nonzero polynomial of degree $< k$, which has at most $k - 1$ roots by our root bound theorem.

**Formalization Approach**:
- Define `ReedSolomonCode (F : Type*) [Field F] [Fintype F] (k : ℕ) : Set (F → F)` as the image of the evaluation map restricted to polynomials of degree $< k$.
- Prove the distance theorem using `card_roots_le_natDegree_filter`.
- State the Singleton bound and show RS achieves it (MDS code).

**Applications**: Error-correcting codes, proximity testing in STARKs, list decoding, algebraic geometry codes.

---

## 3. Sumcheck Protocol Algebraic Core

**Hypothesis**: The sumcheck protocol's soundness reduces to repeated application of the univariate root bound.

**Statement**: In each round of the sumcheck protocol, the verifier checks that a claimed univariate polynomial is consistent with a partial sum. A cheating prover must produce a polynomial that agrees with the honest one on a random point, which fails with probability $\le d/|F|$ per round.

**Proof Strategy**:
1. Formalize the sumcheck claim: $\sum_{x \in \{0,1\}^n} p(x) = v$.
2. In round $i$, the prover sends a univariate polynomial $g_i$ of degree $\le d_i$.
3. The verifier checks $g_i(0) + g_i(1) = v_i$ and evaluates $g_i(r_i)$ at a random $r_i$.
4. If the prover cheats, $g_i$ disagrees with the honest polynomial, so by our root bound, the verifier catches the cheat with probability $\ge 1 - d_i/|F|$.
5. Union bound over $n$ rounds gives total soundness error $\le \sum d_i / |F|$.

**Formalization Approach**: Define the protocol as an inductive sequence of claims, and prove soundness by induction on the number of rounds, using `card_roots_le_natDegree_filter` at each step.

**Cross-domain Connections**: The sumcheck protocol is the algorithmic backbone of virtually all modern SNARK and STARK systems, as well as quantum complexity (QMA vs. QIP) and hardness-of-approximation reductions.

---

## 4. Iterated Freivalds and Amplified Matrix Verification

**Hypothesis**: Repeating Freivalds' test $t$ times independently reduces the error probability to $|F|^{-t}$.

**Statement**: If $A \cdot B \neq C$ and we sample $r_1, \ldots, r_t$ independently, then
$$\Pr[\forall i,\, (AB)r_i = C r_i] \le |F|^{-t}.$$

**Proof Strategy**: Each test is independent, so the probability of all tests passing is at most $(1/|F|)^t$. Formally, this requires:
1. Defining the product probability space $(k \to F)^t$.
2. Showing that the events $\{r_i : (AB)r_i = Cr_i\}$ are independent.
3. Applying the product bound from `freivalds_error_prob`.

**Formalization Approach**: Use `Fintype.card` counting over the product type. Each "bad" vector independently has fraction $\le 1/|F|$ of the space, so the product of bad sets has fraction $\le 1/|F|^t$.

**Applications**: Practical matrix verification in distributed computing, streaming algorithms, and certified inference for neural network linear layers.

---

## 5. Low-Degree Testing for Affine Lines (Foundations for FRI)

**Hypothesis**: A function $f : F \to F$ that agrees with a degree-$d$ polynomial on a large fraction of evaluation points must be close to a unique low-degree polynomial. The proximity testing version: if $f$ passes the "test on random affine line" with high probability, then $f$ is close to a polynomial of degree $\le d$.

**Statement** (basic version): If $|\{a \in S : f(a) = p(a)\}| > d$ for some polynomial $p$ of degree $\le d$, then $p$ is the unique polynomial of degree $\le d$ achieving this agreement.

**Proof Strategy**: If two distinct polynomials $p, q$ of degree $\le d$ both agreed with $f$ on more than $d$ points, then $p - q$ would have degree $\le d$ and more than $d$ roots, contradicting the root bound (our `polynomial_identity_from_agreement`).

**Formalization Approach**: Direct application of `polynomial_identity_from_agreement`. For the full proximity testing theorem (as used in FRI), one would need the multivariate Schwartz–Zippel and a formalization of the FRI folding protocol.

**Cross-domain Connections**: FRI (Fast Reed-Solomon Interactive Oracle Proof of Proximity) is the core component of STARK proof systems. Formalizing its soundness would be a major milestone for verified cryptographic proofs.

---

## Summary Table

| Direction | Difficulty | Impact | Dependencies |
|-----------|-----------|--------|--------------|
| Multivariate Schwartz–Zippel | Medium | Very High | MvPolynomial, root bound |
| Reed–Solomon distance | Easy | High | Root bound (done) |
| Sumcheck protocol | Medium-Hard | Very High | Multivariate SZ |
| Iterated Freivalds | Easy | Medium | Freivalds (done) |
| Low-degree testing / FRI | Hard | Very High | Multivariate SZ, RS distance |

Each direction builds on the algebraic verification kernel established in this work. The root bound and Freivalds' theorem serve as the foundational layer upon which the entire stack of modern verifiable computation can be constructed.
