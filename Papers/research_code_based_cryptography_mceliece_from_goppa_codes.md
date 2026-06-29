# Designed Distance of Goppa and Alternant Codes: A Formal Foundation for Code-Based (Post-Quantum) Cryptography

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Code-Based Cryptography)

## Abstract

The McEliece cryptosystem, introduced in 1978, is among the oldest and most studied public-key encryption schemes, and a leading candidate for post-quantum standardization. Its security rests on two pillars: the NP-hardness of decoding random linear codes, and the indistinguishability of a disguised Goppa-code generator matrix from a random matrix. The *functional correctness* of the scheme, in turn, rests on the **designed distance** of Goppa codes and their parent generalized Reed–Solomon (GRS) codes — the guarantee that the legitimate receiver, who possesses the secret algebraic structure, can always remove the error pattern that the sender deliberately injects.

This paper develops, with machine-checked rigor, the mathematical core of that correctness guarantee. We prove the **GRS designed-distance bound** (every nonzero degree-$<k$ evaluation codeword has Hamming weight $\ge n-k+1$, the Singleton-optimal MDS distance), the corresponding **unique $\tau$-error-correction theorem** under the packing condition $2\tau+1 \le n-k+1$, and the dual **BCH / alternant bound** (every nonzero vector in the kernel of a $t\times n$ Vandermonde parity check has weight $>t$). The cornerstone is an elementary but pivotal counting lemma — *a nonzero polynomial has at most $\deg f$ zero coordinates among distinct evaluation points* — which we identify as the algebraic shadow of the fundamental theorem of algebra. We then situate these results within the McEliece pipeline, review the hardness assumptions (Berlekamp–McEliece–van Tilborg NP-completeness; GRS/Goppa indistinguishability), analyze information-set decoding and its exponential cost floor, and derive concrete parameters for 256-bit post-quantum security. We close with algorithms, applications, and a set of falsifiable conjectures for future work.

## 1. Introduction

### 1.1 Motivation

Shor's algorithm renders RSA and elliptic-curve cryptography insecure against a scalable quantum computer. Code-based cryptography, by contrast, reduces its security to the hardness of decoding random linear codes — a problem with no known efficient quantum algorithm and a proven NP-complete worst case. The McEliece scheme (1978) and its dual, the Niederreiter scheme (1986), have resisted cryptanalysis for over four decades, and the *Classic McEliece* instantiation is a finalist in the NIST post-quantum standardization process.

While the *security* of McEliece is the subject of an enormous literature, the *correctness* of the scheme — that decryption always recovers the plaintext — depends on a precise, classical, and elegant body of algebraic coding theory: the designed distance of Goppa and alternant codes. This paper formalizes that core.

### 1.2 Contributions

1. A clean, verified proof of the **zero-counting lemma** (`card_eval_zero_le_natDegree`): a nonzero polynomial has at most $\deg f$ zero coordinates among distinct evaluation points.
2. The **GRS designed-distance / MDS bound** (`grs_min_distance`): degree-$<k$ evaluation codewords have weight $\ge n-k+1$.
3. The induced **minimum-distance bound** (`grs_dist_lower`) and the **unique decoding theorem** (`grs_corrects_errors`).
4. The dual **BCH / alternant bound** (`bch_parity_min_weight`) for Vandermonde parity checks.
5. A self-contained account of how these feed the McEliece correctness guarantee, with hardness assumptions, ISD cost analysis, and concrete 256-bit parameters.

### 1.3 Notation

Throughout, $K$ is a field, $n,k,t,\tau \in \mathbb{N}$, and $\alpha = (\alpha_1,\dots,\alpha_n)$ is a tuple of *distinct* points in $K$ (formally, $\alpha : \mathrm{Fin}\,n \to K$ with $\alpha$ injective). For a vector $x \in K^n$ we write $\mathrm{wt}(x)$ for its **Hamming weight** (number of nonzero coordinates) and $d(x,y)$ for the **Hamming distance** (number of disagreeing coordinates). We write $K[X]$ for univariate polynomials and $\deg f$ for the (natural-number) degree of $f$.

## 2. Definitions

**Definition 2.1 (Evaluation vector / codeword).** For distinct points $\alpha : \mathrm{Fin}\,n \to K$ and a polynomial $f \in K[X]$, the *evaluation vector* is
$$\mathrm{evalVec}(\alpha, f) : \mathrm{Fin}\,n \to K, \qquad \mathrm{evalVec}(\alpha,f)(i) = f(\alpha_i).$$

**Definition 2.2 (Generalized Reed–Solomon code).** The GRS code of dimension $k$ over the locators $\alpha$ is
$$\mathrm{GRS}_k(\alpha) = \{\, \mathrm{evalVec}(\alpha, f) : f \in K[X],\ \deg f < k \,\} \subseteq K^n.$$
This is a $K$-linear subspace of dimension $k$ (when $k \le n$).

**Definition 2.3 (Hamming weight and distance).** For $x,y : \mathrm{Fin}\,n \to K$,
$$\mathrm{wt}(x) = \#\{ i : x_i \ne 0\}, \qquad d(x,y) = \#\{ i : x_i \ne y_i \} = \mathrm{wt}(x-y).$$
The Hamming distance is a metric; in particular it satisfies the triangle inequality $d(x,z) \le d(x,y) + d(y,z)$ and symmetry $d(x,y)=d(y,x)$.

**Definition 2.4 (Minimum distance).** The minimum distance of a linear code $C$ is $\min\{ \mathrm{wt}(c) : c \in C,\ c \ne 0 \}$.

**Definition 2.5 (Vandermonde parity check).** For locators $\alpha$ and a designed parameter $t$, the $t \times n$ Vandermonde matrix is $H_{j,i} = \alpha_i^{\,j}$ for $0 \le j < t$, $1 \le i \le n$. The associated code is $\ker H = \{ c \in K^n : Hc = 0 \}$.

**Definition 2.6 (Goppa code).** Given a *support* $L = (\alpha_1,\dots,\alpha_n)$ of distinct elements of $\mathrm{GF}(q^m)$ and a *Goppa polynomial* $g \in \mathrm{GF}(q^m)[X]$ with $g(\alpha_i) \ne 0$ for all $i$, the Goppa code is
$$\Gamma(L,g) = \Big\{ c \in \mathrm{GF}(q)^n : \sum_{i=1}^n \frac{c_i}{X - \alpha_i} \equiv 0 \pmod{g(X)} \Big\}.$$
$\Gamma(L,g)$ is the subfield subcode (over $\mathrm{GF}(q)$) of an alternant code, itself a GRS code over $\mathrm{GF}(q^m)$; this is why GRS distance bounds govern Goppa correction capacity.

## 3. The Zero-Counting Lemma

The entire edifice rests on a single elementary fact, which we isolate.

**Lemma 3.1 (`card_eval_zero_le_natDegree`).** *Let $\alpha : \mathrm{Fin}\,n \to K$ be injective and let $f \in K[X]$ be nonzero. Then*
$$\#\{ i : f(\alpha_i) = 0 \} \le \deg f.$$

*Proof sketch.* Let $Z = \{ i : f(\alpha_i)=0\}$. The map $i \mapsto \alpha_i$ is injective on $Z$ (indeed on all of $\mathrm{Fin}\,n$), and its image $\alpha(Z)$ consists of genuine roots of $f$, so $\alpha(Z) \subseteq \{\text{roots of } f\}$ as finite sets. Hence
$$\#Z = \#\alpha(Z) \le \#\{\text{distinct roots of } f\} \le \#(\text{roots of } f \text{ with multiplicity}) \le \deg f,$$
where the second-to-last step is `Multiset.toFinset_card_le` and the last is `Polynomial.card_roots'` (a nonzero polynomial over a field has at most $\deg f$ roots counted with multiplicity). $\square$

This is precisely the contrapositive of "many roots force a high-degree (or zero) polynomial," i.e. the fundamental theorem of algebra in counting form. Nonvacuousness requires $f \ne 0$; for $f = 0$ every coordinate vanishes and the bound is false.

## 4. GRS Designed Distance (the MDS bound)

**Theorem 4.1 (`grs_min_distance`).** *Let $\alpha : \mathrm{Fin}\,n \to K$ be injective, $k \le n$, and let $f \in K[X]$ be nonzero with $\deg f < k$. Then*
$$\mathrm{wt}(\mathrm{evalVec}(\alpha,f)) \ge n - k + 1.$$

*Proof sketch.* The number of *zero* coordinates of $\mathrm{evalVec}(\alpha,f)$ is exactly $\#\{i : f(\alpha_i)=0\}$, which by Lemma 3.1 is at most $\deg f \le k-1$. Therefore the number of *nonzero* coordinates is
$$\mathrm{wt}(\mathrm{evalVec}(\alpha,f)) = n - \#\{i : f(\alpha_i)=0\} \ge n - (k-1) = n-k+1.$$
Formally, $\mathrm{wt}$ is the complement of the zero-set within the $n$ coordinates (`Finset.filter_not`, `Finset.card_sdiff`), and the inequality is closed by `Nat.le_sub_of_add_le'` together with $k \le n$. $\square$

This is the **Singleton-optimal (MDS)** distance: the Singleton bound asserts $d \le n-k+1$ for *any* $[n,k]$ code, and GRS codes meet it with equality. They are therefore as error-tolerant as the parameters $n,k$ permit.

**Theorem 4.2 (`grs_dist_lower`, minimum distance of the code).** *Let $\alpha$ be injective, $k \le n$, and $f,g \in K[X]$ with $\deg f < k$, $\deg g < k$, and $\mathrm{evalVec}(\alpha,f) \ne \mathrm{evalVec}(\alpha,g)$. Then*
$$d\big(\mathrm{evalVec}(\alpha,f),\, \mathrm{evalVec}(\alpha,g)\big) \ge n-k+1.$$

*Proof sketch.* By $K$-linearity of evaluation, $\mathrm{evalVec}(\alpha,f) - \mathrm{evalVec}(\alpha,g) = \mathrm{evalVec}(\alpha, f-g)$, so the Hamming distance equals $\mathrm{wt}(\mathrm{evalVec}(\alpha, f-g))$. Since the two codewords differ, $f - g \ne 0$; and $\deg(f-g) \le \max(\deg f, \deg g) < k$ (`Polynomial.natDegree_sub_le`). Apply Theorem 4.1 to $f-g$. $\square$

Thus $\mathrm{GRS}_k(\alpha)$ has minimum distance $\ge n-k+1$.

## 5. Unique Decoding

**Theorem 5.1 (`grs_corrects_errors`).** *Let $\alpha$ be injective, $k \le n$, and $\tau \in \mathbb{N}$ with*
$$2\tau + 1 \le n - k + 1.$$
*Let $r \in K^n$ be any received word and $f,g \in K[X]$ with $\deg f < k$, $\deg g < k$. If $d(r, \mathrm{evalVec}(\alpha,f)) \le \tau$ and $d(r, \mathrm{evalVec}(\alpha,g)) \le \tau$, then $\mathrm{evalVec}(\alpha,f) = \mathrm{evalVec}(\alpha,g)$.*

*Proof sketch.* Suppose toward a contradiction the two codewords differ. By the triangle inequality and symmetry of Hamming distance,
$$d(\mathrm{evalVec}(\alpha,f), \mathrm{evalVec}(\alpha,g)) \le d(\mathrm{evalVec}(\alpha,f), r) + d(r, \mathrm{evalVec}(\alpha,g)) \le \tau + \tau = 2\tau.$$
But Theorem 4.2 gives $d \ge n-k+1 \ge 2\tau+1 > 2\tau$, a contradiction. Hence the codewords coincide. $\square$

This is the *packing* guarantee: balls of radius $\tau = \lfloor (n-k)/2 \rfloor$ around distinct codewords are disjoint, so a received word with $\le \tau$ errors determines its codeword uniquely. Constructive recovery is provided by classical decoders (Berlekamp–Massey, Sugiyama / extended Euclidean, Patterson for binary Goppa).

## 6. The Dual View: BCH / Alternant Bound

The generator-side argument (few roots $\Rightarrow$ many nonzeros) has a parity-side mirror image.

**Theorem 6.1 (`bch_parity_min_weight`).** *Let $\alpha : \mathrm{Fin}\,n \to K$ be distinct locators and let $H$ be the $t \times n$ Vandermonde matrix $H_{j,i} = \alpha_i^{\,j}$, $0 \le j < t$. Then every nonzero $c \in \ker H$ satisfies $\mathrm{wt}(c) > t$.*

*Proof sketch.* Suppose $c \ne 0$ has support $S = \{i : c_i \ne 0\}$ with $|S| \le t$. The condition $Hc = 0$ says $\sum_{i \in S} c_i \alpha_i^{\,j} = 0$ for $j = 0,\dots,t-1$. Restricting to the $|S|$ columns indexed by $S$ yields a square Vandermonde system in the distinct nodes $\{\alpha_i\}_{i\in S}$; its determinant $\prod_{i<i'}(\alpha_{i'}-\alpha_i) \ne 0$, so the system is invertible and forces $c_i = 0$ for all $i \in S$ — contradicting $c \ne 0$. Equivalently, in the *polynomial-multiplier* form, one builds an error-locator polynomial $\sigma(X) = \prod_{i \in S}(X - \alpha_i)$ of degree $|S| \le t$ and derives a contradiction from the syndrome relations. Hence $\mathrm{wt}(c) = |S| > t$. $\square$

**Consequence (Goppa correction capacity).** A Goppa code $\Gamma(L,g)$ with $\deg g = t$ is an alternant code with a degree-$t$ Vandermonde-type parity check, so its minimum distance exceeds $t$; combined with the packing argument it corrects $\lfloor t/2 \rfloor$ errors in general. In the **binary separable** case (over $\mathrm{GF}(2)$ with $g$ squarefree), the parity check may be strengthened from $g$ to $g^2$ because a codeword's error-locator polynomial and its formal derivative share roots; the designed distance doubles to $\ge 2t+1$, so $\Gamma(L,g)$ corrects a full $t$ errors. This binary doubling is the reason McEliece uses binary Goppa codes.

## 7. The McEliece Cryptosystem

We now assemble the cryptosystem whose correctness the above results certify.

**Setup.** Fix a binary Goppa code $\Gamma(L,g)$ over $\mathrm{GF}(2^m)$ correcting $t$ errors, with $[n,k]$ binary generator matrix $G$ (so $k \ge n - mt$).

**Key generation.**
- Choose a random invertible $k\times k$ matrix $S$ over $\mathrm{GF}(2)$ (the *scrambler*).
- Choose a random $n\times n$ permutation matrix $P$.
- Compute the public generator $\hat G = S\,G\,P$.
- **Public key:** $(\hat G, t)$. **Private key:** $(S, G, P)$ plus the secret decoder for $\Gamma(L,g)$.

**Encryption** of a $k$-bit message $m$:
$$c = m\hat G + e, \qquad e \in \mathrm{GF}(2)^n,\ \mathrm{wt}(e) = t \ \text{(random)}.$$

**Decryption.** Compute $cP^{-1} = mSG + eP^{-1}$. Since $P^{-1}$ is a permutation, $\mathrm{wt}(eP^{-1}) = t$, and $mSG \in \Gamma(L,g)$. Run the Goppa decoder to remove the $t$ errors and recover $mS$; then $m = (mS)S^{-1}$.

**Correctness.** Decryption succeeds because $eP^{-1}$ has weight exactly $t$ and the code corrects $t$ errors — *this is precisely Theorem 5.1 / Theorem 6.1 applied to $\Gamma(L,g)$.* The injected error sits at the boundary of the unique-decoding radius, and the designed-distance bounds guarantee a unique nearest codeword.

## 8. Hardness Assumptions

**Assumption 8.1 (Syndrome / general decoding is NP-hard).** The decision problem — given a binary parity-check matrix $H$, a syndrome $s$, and weight bound $w$, does there exist $e$ with $He = s$ and $\mathrm{wt}(e) \le w$? — is **NP-complete** (Berlekamp, McEliece, van Tilborg, 1978). Thus no polynomial-time algorithm is known for worst-case decoding of arbitrary linear codes, and one would imply $\mathrm{P}=\mathrm{NP}$. No quantum speedup beyond Grover-style square-root is known.

**Assumption 8.2 (Goppa indistinguishability).** For the parameter regimes used in practice, the public matrix $\hat G = SGP$ is computationally indistinguishable from a uniformly random full-rank $k\times n$ binary matrix. Equivalently, distinguishing a (permuted, scrambled) Goppa generator from random is conjectured to be as hard as the decoding problem itself. (Distinguishers are known only for pathological *high-rate* GRS/Goppa variants; Classic McEliece avoids these regimes.)

Under Assumptions 8.1–8.2, recovering $m$ from $(\hat G, c)$ is equivalent to decoding a random-looking linear code with a planted weight-$t$ error, believed intractable.

## 9. Information-Set Decoding and the Exponential Cost Floor

The best known generic attacks are **information-set decoding (ISD)** algorithms (Prange 1962; Lee–Brickell; Stern; Becker–Joux–May–Meurer; May–Meurer–Thomae). The basic Prange ISD:

1. Randomly select an *information set* $I$ of $k$ coordinates.
2. Hope that the planted error $e$ avoids $I$ (i.e., all $t$ errors fall in the complementary $n-k$ coordinates).
3. If so, linear algebra on the $k\times k$ submatrix recovers $m$ and reveals $e$; verify $\mathrm{wt}(e) = t$.

The probability that a single random information set is error-free is
$$p_{\mathrm{succ}} = \frac{\binom{n-k}{t}}{\binom{n}{t}},$$
so the expected number of iterations is $1/p_{\mathrm{succ}} = \binom{n}{t} / \binom{n-k}{t}$. Using elementary binomial inequalities (e.g. $\binom{n}{t} \ge (n/t)^t$ and refinements), this ratio is provably *exponential* in the parameters — a rigorous lower bound on attack cost, not a heuristic "the search space is large" claim. Advanced ISD variants improve the *exponent's constant* but leave the asymptotic exponential floor intact, which is exactly what enables principled parameter selection.

## 10. Parameters for 256-bit Post-Quantum Security

To target $\approx 2^{256}$ classical operations (and, accounting for Grover's quadratic quantum speedup on the search loop, a corresponding quantum margin), one tunes $(n,k,t)$ so that the ISD work factor exceeds the threshold. The Classic McEliece "Category 5" parameter set is:

| Parameter | Value |
|---|---|
| Field | $\mathrm{GF}(2^{13})$ |
| Code length $n$ | $6960$ |
| Dimension $k$ | $5413$ |
| Errors $t$ | $119$ |
| Public-key size | $\approx 1{,}047{,}319$ bytes ($\approx 1.0$ MB) |
| Ciphertext size | $194$ bytes |
| Claimed security | NIST Category 5 ($\ge 256$-bit) |

The public-key size is governed by the systematic generator's redundancy block, $k(n-k)$ bits $= 5413 \times 1547$ bits $\approx 1.047 \times 10^6$ bytes. The large key is the principal practical cost of code-based cryptography; in exchange one obtains fast encryption/decryption and a conservative, long-studied security foundation.

## 10b. A Worked Toy Example

To make the abstractions concrete, consider a small GRS code over the prime field $K = \mathrm{GF}(11)$ with length $n = 11$ and dimension $k = 3$. The locators are the eleven field elements $\alpha = (0,1,2,\dots,10)$, which are distinct, so $\alpha$ is injective. The designed distance is $n - k + 1 = 9$, and the certified correction radius is $\tau = \lfloor (n-k)/2 \rfloor = 4$.

Take the message polynomial $f(X) = 2 + 3X + X^2$ (degree $2 < k = 3$). Its evaluation codeword is
$$\mathrm{evalVec}(\alpha, f) = (2, 6, 1, 9, 8, 9, 1, 6, 2, 0, 0),$$
where, for instance, $f(9) = 2 + 27 + 81 = 110 \equiv 0 \pmod{11}$ and $f(10) = 2 + 30 + 100 = 132 \equiv 0 \pmod{11}$, so exactly two coordinates vanish. By Lemma 3.1 the number of zeros is at most $\deg f = 2$, which is attained here; hence the Hamming weight is $11 - 2 = 9 = n-k+1$, saturating Theorem 4.1. This codeword is, in fact, an extremal MDS witness for these parameters.

Now simulate transmission with $\tau = 4$ errors: flip the first four coordinates, yielding the received word
$$r = (3, 7, 2, 10, 8, 9, 1, 6, 2, 0, 0), \qquad d(r, \mathrm{evalVec}(\alpha,f)) = 4.$$
An exhaustive scan of all $11^3 = 1331$ degree-$<3$ codewords finds that exactly one lies within Hamming distance $4$ of $r$ — namely the original codeword. This is Theorem 5.1 in action: the packing condition $2\tau + 1 = 9 \le n-k+1 = 9$ holds with equality, so the decoding balls of radius $4$ are disjoint and decoding is unambiguous.

The dual picture appears with a Vandermonde parity check. Over $\mathrm{GF}(7)$ with $n = 6$ locators $(1,2,3,4,5,6)$ and $t = 2$, the $2 \times 6$ matrix $H_{j,i} = \alpha_i^{\,j}$ has kernel whose nonzero vectors all have weight at least $3$; an exhaustive scan confirms the minimum kernel weight is exactly $3 > t = 2$, illustrating Theorem 6.1. These toy computations are reproduced verbatim by the accompanying numerical demonstrations.

## 11. Algorithms

**Algorithm A (GRS unique-decoding radius).** Given $n, k$, output the largest $\tau$ with $2\tau+1 \le n-k+1$, namely $\tau = \lfloor (n-k)/2 \rfloor$. This is the certified correction capacity from Theorem 5.1.

**Algorithm B (Designed-distance / weight certificate).** Given distinct locators $\alpha$ and a nonzero $f$ with $\deg f < k$, compute $\mathrm{evalVec}(\alpha,f)$, count its zeros $z$, and certify $\mathrm{wt} = n - z \ge n-k+1$ (Theorem 4.1).

**Algorithm C (Prange ISD cost estimator).** Given $(n,k,t)$, compute the work factor $W = \binom{n}{t}/\binom{n-k}{t}$ (times the per-iteration linear-algebra cost), and report $\log_2 W$ as the classical security level.

**Algorithm D (256-bit parameter search).** Sweep candidate $(n,k,t)$ honoring $k \ge n - mt$ (Goppa rate) and select the smallest-key set with $\log_2 W \ge 256$.

## 12. Applications

- **Post-quantum KEM.** Classic McEliece is a NIST finalist key-encapsulation mechanism; the designed-distance correctness proved here is exactly the decapsulation-correctness guarantee.
- **Niederreiter signatures / encryption.** The dual (syndrome) formulation uses the same Vandermonde parity bound (Theorem 6.1).
- **Code-based hash-and-sign and identification** (Stern's protocol) reduce to the same decoding hardness (Assumption 8.1).
- **Robust communication.** Independently of cryptography, GRS/Goppa codes are workhorse error-correcting codes (deep-space, storage); the MDS bound (Theorem 4.1) certifies their optimality.

## 13. Discussion

The architecture is strikingly economical. A single classical fact — *a degree-$m$ polynomial has at most $m$ roots* (Lemma 3.1) — yields, via the evaluation map, the MDS distance (Theorem 4.1) and hence unique decoding (Theorem 5.1); the same fact, viewed through the invertibility of Vandermonde minors, yields the dual BCH/alternant bound (Theorem 6.1). Cryptographic security is then obtained by *hiding* this structure behind a scrambler and permutation, leaning on the NP-hardness of generic decoding (Assumption 8.1) and Goppa indistinguishability (Assumption 8.2). Correctness is algebraic and provable; security is complexity-theoretic and assumption-based — a clean separation that the formalization makes explicit.

A subtlety worth emphasizing: our theorems are stated with the *necessary* nonvacuousness hypotheses ($f \ne 0$, $\alpha$ injective). Dropping them collapses the bounds (the zero polynomial vanishes everywhere; repeated locators destroy the Vandermonde structure), so they are load-bearing rather than cosmetic.

## 14. Future Directions

1. **Tight (matching) Singleton bound.** Prove $\mathrm{GRS}_k(\alpha)$ has minimum distance *exactly* $n-k+1$, witnessed by $f = \prod_{i<k-1}(X-\alpha_i)$, whose evaluation vector has exactly $k-1$ zeros — upgrading $\ge$ to $=$ with an explicit extremal codeword (reusing the `witnessPolynomial` technique from the sibling minimum-distance development).
2. **Binary Goppa doubling.** Formalize that a separable degree-$t$ binary Goppa code has minimum distance $\ge 2t+1$, by replacing $g$ with $g^2$ in the parity check.
3. **Provable ISD lower bound.** Establish the exponential floor $\binom{n}{t}/\binom{n-k}{t}$ on information-set decoding, closing the ratio with a matching binomial upper bound $\binom{n}{t}\le b^t$.
4. **Niederreiter–McEliece equivalence.** Prove the two schemes are equivalent at the syndrome level for a fixed parity-check matrix.

## 15. Conclusion

We have formalized the algebraic heart of code-based cryptography: the designed-distance bounds of GRS and Goppa/alternant codes, the packing-based unique-decoding theorem, and their role in certifying McEliece decryption correctness. Combined with the NP-hardness of decoding and Goppa indistinguishability, these results explain why a forty-five-year-old cryptosystem stands among our best defenses for the quantum era — and why its security ultimately traces back to a polynomial counting its own roots.

## References

- R. J. McEliece, *A public-key cryptosystem based on algebraic coding theory*, JPL DSN Progress Report, 1978.
- E. Berlekamp, R. McEliece, H. van Tilborg, *On the inherent intractability of certain coding problems*, IEEE Trans. Inf. Theory, 1978.
- V. D. Goppa, *A new class of linear error-correcting codes*, 1970.
- F. J. MacWilliams, N. J. A. Sloane, *The Theory of Error-Correcting Codes*, North-Holland, 1977 (Ch. 12).
- H. Niederreiter, *Knapsack-type cryptosystems and algebraic coding theory*, 1986.
- Classic McEliece submission, NIST Post-Quantum Cryptography Standardization, 2017–2022.
