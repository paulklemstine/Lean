# A Generalized Variance Formula for the Digits of $1/p$ in Base $b$

## Abstract

The repeating expansion (repetend) of a unit fraction $1/p$ in an integer base $b$ is one of the oldest objects in elementary number theory, yet the statistics of its digits — their mean, and especially their variance — have classically been treated only for the extremal case of a *full reptend*, where the base is a primitive root modulo $p$ and the repetend attains its maximal length $p-1$. We develop, from a single Euclidean division identity, an exact closed-form theory of the digit mean and variance that is valid for an **arbitrary** repetend length $\ell$. Writing $S$ and $T$ for the sum and the sum of squares of the digits over one period, and $R$, $Q$, $C$ for three symmetric sums of the remainder orbit, we prove three identities: $p\,S = (b-1)\,R$; $p^2\,T + 2b\,C = (b^2+1)\,Q$; and the master variance identity

$$p^2\big(\ell\,T - S^2\big) = \ell\big((b^2+1)\,Q - 2b\,C\big) - (b-1)^2 R^2,$$

which expresses the (scaled) variance $V = (\ell T - S^2)/\ell^2$ purely in terms of the remainder-orbit sums. We further prove a Midy-type complementarity theorem for reflecting orbits, recover the classical mean value $\tfrac{b-1}{2}$ for full reptends, and exhibit an explicit disproof of the naive conjecture that the digit mean is always $\tfrac{b-1}{2}$ (the base-$2$ expansion of $1/7$). No primality hypothesis is needed for any of these identities; primality enters only when the orbit sums are interpreted as sums over the cyclic subgroup $\langle b\rangle \le (\mathbb{Z}/p\mathbb{Z})^\times$, which is the gateway to a conjectural reformulation via generalized Bernoulli numbers of Dirichlet characters whose order divides $d = (p-1)/\ell$. The present results constitute the exact, character-free skeleton of that program.

**Keywords:** repeating decimals, repetend, digit statistics, variance, Midy's theorem, multiplicative order, Dirichlet characters, generalized Bernoulli numbers.

---

## 1. Introduction

Fix an integer base $b \ge 2$ and a modulus $p \ge 2$ with $\gcd(p, b) = 1$. Long division of $1$ by $p$ in base $b$ produces a purely periodic sequence of digits; the repeating block is the *repetend*, and its length $\ell$ equals the multiplicative order $\operatorname{ord}_p(b)$ when $p$ is prime. The digits of such expansions have fascinated mathematicians since at least the eighteenth century, and their combinatorics is the source of a rich body of folklore: the cyclic-number property of $142857$, Midy's theorem that the two halves of a full-length decimal repetend sum to a string of nines, and the observation that the digits of a full-reptend prime average exactly $\tfrac{b-1}{2}$.

These classical facts share a limitation: they are stated for *full reptends*, where $b$ is a primitive root modulo the prime $p$ and $\ell = p-1$. When the order of $b$ is a proper divisor of $p-1$, the repetend is shorter and the clean statistical statements break down — the mean, in particular, need not be $\tfrac{b-1}{2}$.

The purpose of this paper is to give an exact, elementary, and fully general treatment. We show that the mean and variance of the repetend digits, for **any** period length $\ell$, are governed by three closed-form identities relating the digit sums $S, T$ to three symmetric sums $R, Q, C$ of the underlying remainder orbit. The centerpiece is a single variance identity that eliminates the digits entirely, expressing the digit variance as an explicit polynomial in $R, Q, C, p, b, \ell$.

Our development is deliberately self-contained: every identity is derived from the Euclidean relation $b r_n = p d_n + r_{n+1}$ by summing and squaring over a period. Because no primality is used, the identities hold verbatim for composite $p$ coprime to $b$. Section 6 explains how, for prime $p$, the orbit sums become subgroup sums and connect to Dirichlet characters and generalized Bernoulli numbers, which is the analytic content of the motivating conjecture.

---

## 2. Setup and definitions

### 2.1 The remainder orbit and the digit sequence

**Definition 2.1 (Remainder orbit).** For integers $p, b$ define $r_n = \operatorname{rem}(p, b, n)$ by
$$r_0 = 1, \qquad r_{n+1} = (b \cdot r_n) \bmod p.$$

**Definition 2.2 (Digit sequence).** The $n$-th repetend digit is
$$d_n = \operatorname{digit}(p, b, n) = \left\lfloor \frac{b \cdot r_n}{p} \right\rfloor.$$

When $\gcd(p,b)=1$ the orbit $(r_n)$ is purely periodic; its minimal period is $\ell = \operatorname{ord}_p(b)$ for prime $p$. Throughout, a *period* is any index $\ell$ with $r_\ell = r_0$, and all sums below are taken over one such period, $k = 0, 1, \dots, \ell-1$.

### 2.2 The master identity

**Lemma 2.3 (Euclidean identity).** For all $n$,
$$b \cdot r_n = p \cdot d_n + r_{n+1}.$$

*Proof.* This is the defining relation of integer quotient and remainder: $d_n = \lfloor b r_n / p\rfloor$ and $r_{n+1} = (b r_n) \bmod p$, so $p\,d_n + r_{n+1} = p\lfloor b r_n/p\rfloor + (b r_n \bmod p) = b r_n$. $\qquad\blacksquare$

Every result in this paper is a consequence of Lemma 2.3, obtained by summing it (Section 3), squaring and summing it (Section 4), and combining the two (Section 5).

### 2.3 The five period sums

Over one period of length $\ell$ define the *digit sums*
$$S = \sum_{k=0}^{\ell-1} d_k, \qquad T = \sum_{k=0}^{\ell-1} d_k^2,$$
and the *remainder-orbit sums*
$$R = \sum_{k=0}^{\ell-1} r_k, \qquad Q = \sum_{k=0}^{\ell-1} r_k^2, \qquad C = \sum_{k=0}^{\ell-1} r_k\, r_{k+1}.$$

The mean and variance of the digits over a period are
$$\mu = \frac{S}{\ell}, \qquad V = \frac{T}{\ell} - \mu^2 = \frac{\ell\,T - S^2}{\ell^2}.$$

A recurring technical tool is the following telescoping fact.

**Lemma 2.4 (Shift lemma).** For any function $f:\mathbb{N}\to\mathbb{Z}$ and any $n$,
$$\sum_{k=0}^{n-1} f(k+1) = \left(\sum_{k=0}^{n-1} f(k)\right) + f(n) - f(0).$$
In particular, over a period $r_\ell = r_0$, the shifted remainder sum satisfies $\sum_{k=0}^{\ell-1} r_{k+1} = R$, and likewise $\sum_{k=0}^{\ell-1} r_{k+1}^2 = Q$.

*Proof.* The left side telescopes: $\sum_{k=0}^{n-1}(f(k+1)-f(k)) = f(n)-f(0)$, and adding $\sum f(k)$ gives the claim. Applying it with $f = r$ (resp. $f = r^2$) and using $r_\ell = r_0$ makes the boundary terms cancel. $\qquad\blacksquare$

---

## 3. The digit-sum formula

**Theorem 3.1 (Digit-sum identity).** Over any period ($r_\ell = r_0$),
$$b\cdot R = p\cdot S + R, \qquad\text{equivalently}\qquad p\cdot S = (b-1)\cdot R.$$

*Proof.* Summing Lemma 2.3 over $k = 0, \dots, \ell-1$,
$$b\sum_k r_k = p\sum_k d_k + \sum_k r_{k+1}, \quad\text{i.e.}\quad b\,R = p\,S + \sum_k r_{k+1}.$$
By the shift lemma (Lemma 2.4) with $r_\ell = r_0$, the last sum equals $R$. Hence $bR = pS + R$, and rearranging gives $pS = (b-1)R$. $\qquad\blacksquare$

**Corollary 3.2 (Digit mean).** The digit mean is
$$\mu = \frac{S}{\ell} = \frac{(b-1)R}{p\,\ell}.$$

Thus the mean of the repetend digits is entirely governed by the remainder sum $R$. The classical value $\tfrac{b-1}{2}$ arises precisely when $R = \tfrac{p\ell}{2}\cdot\tfrac{1}{\,?}$; the sharp statement is Theorem 5.3 below.

---

## 4. The digit sum-of-squares formula

**Lemma 4.1 (Pointwise quadratic identity).** For all $n$,
$$p^2 d_n^2 + 2b\, r_n r_{n+1} + r_{n+1}^2 = b^2 r_n^2 + 2 r_{n+1}^2.$$

*Proof.* Square Lemma 2.3: $b^2 r_n^2 = (p d_n + r_{n+1})^2 = p^2 d_n^2 + 2 p d_n r_{n+1} + r_{n+1}^2$. Also $p d_n = b r_n - r_{n+1}$, so $2 p d_n r_{n+1} = 2 b r_n r_{n+1} - 2 r_{n+1}^2$. Substituting,
$$b^2 r_n^2 = p^2 d_n^2 + 2 b r_n r_{n+1} - 2 r_{n+1}^2 + r_{n+1}^2 = p^2 d_n^2 + 2 b r_n r_{n+1} - r_{n+1}^2.$$
Rearranging yields the stated identity. $\qquad\blacksquare$

**Theorem 4.2 (Sum-of-squares identity).** Over any period ($r_\ell = r_0$),
$$p^2\cdot T + 2b\cdot C = (b^2+1)\cdot Q.$$

*Proof.* Sum Lemma 4.1 over $k = 0, \dots, \ell-1$:
$$p^2 T + 2b\,C + \sum_k r_{k+1}^2 = b^2 Q + 2\sum_k r_{k+1}^2.$$
By the shift lemma, $\sum_k r_{k+1}^2 = Q$. Substituting and cancelling one copy of $Q$ from each side,
$$p^2 T + 2b\,C = b^2 Q + 2Q - Q = (b^2+1)Q. \qquad\blacksquare$$

---

## 5. The generalized variance formula

Theorems 3.1 and 4.2 together determine both digit statistics from the three remainder sums. Eliminating $S$ and $T$ gives the main result.

**Theorem 5.1 (Generalized variance identity).** For any period length $\ell$ ($r_\ell = r_0$),
$$p^2\big(\ell\,T - S^2\big) = \ell\big((b^2+1)\,Q - 2b\,C\big) - (b-1)^2\,R^2.$$
Consequently the digit variance has the exact closed form
$$V = \frac{\ell T - S^2}{\ell^2} = \frac{\ell\big((b^2+1)Q - 2bC\big) - (b-1)^2 R^2}{p^2\,\ell^2}.$$

*Proof.* From Theorem 4.2, $p^2 T = (b^2+1)Q - 2bC$, so
$$p^2\,\ell\,T = \ell\big((b^2+1)Q - 2bC\big).$$
From Theorem 3.1, $pS = (b-1)R$, so $p^2 S^2 = (b-1)^2 R^2$. Subtracting,
$$p^2(\ell T - S^2) = \ell\big((b^2+1)Q - 2bC\big) - (b-1)^2 R^2,$$
which is the claimed identity. Dividing by $p^2\ell^2$ gives the closed form for $V$. $\qquad\blacksquare$

The right-hand side contains no digit quantities: the variance of the repetend digits is a fixed polynomial in the remainder-orbit sums $R, Q, C$ and the parameters $p, b, \ell$. This holds for every divisor $\ell$ of the period, unifying the classically separate cases $\ell = p-1$ (full reptend) and $\ell = (p-1)/2$ (half reptend).

**Worked example.** For $1/7$ in base $10$: $\ell = 6$, $R = 21$, $Q = 91$, $C = 70$. The right side is
$$6\,(101\cdot 91 - 20\cdot 70) - 81\cdot 441 = 6\cdot 7791 - 35721 = 11025,$$
and the left side is $49\,(6\cdot 159 - 27^2) = 49\cdot 225 = 11025$. The variance is $V = 225/36 = 25/4 = 6.25$.

### 5.1 The mean, exactly, for full reptends

**Theorem 5.2 (Full-reptend mean).** Suppose $p \ne 0$ and the orbit over the period sums to $2R = p(p-1)$ — the case realized when $b$ is a primitive root modulo the prime $p$, so that the remainders range over all of $\{1, \dots, p-1\}$. Then
$$2S = (b-1)(p-1), \qquad\text{i.e.}\qquad \mu = \frac{b-1}{2}.$$

*Proof.* By Theorem 3.1, $pS = (b-1)R$, hence $2pS = (b-1)\cdot 2R = (b-1)p(p-1)$. Cancelling $p \ne 0$ gives $2S = (b-1)(p-1)$. Since a full reptend has length $\ell = p-1$, the mean is $\mu = S/\ell = \tfrac{b-1}{2}$. $\qquad\blacksquare$

This recovers the classical average of $4.5$ for full-reptend decimal primes.

### 5.2 The mean is not always $\tfrac{b-1}{2}$

**Theorem 5.3 (Failure of the naive mean conjecture).** It is *not* true that $2S = (b-1)\ell$ for every $p, b$ and every period length $\ell > 0$. Explicitly, for $p = 7$, $b = 2$, $\ell = 3$, the repetend of $1/7 = 0.\overline{001}$ has digits $0, 0, 1$, so $S = 1$ and $2S = 2$, whereas $(b-1)\ell = 3$.

*Proof.* The base-$2$ remainder orbit of $1/7$ is $r_0 = 1, r_1 = 2, r_2 = 4, r_3 = 1 = r_0$, so $\ell = 3$ is a period, and the digits are $d_0 = \lfloor 2/7\rfloor = 0$, $d_1 = \lfloor 4/7\rfloor = 0$, $d_2 = \lfloor 8/7\rfloor = 1$. Thus $S = 1$, and $2S = 2 \ne 3 = (b-1)\ell$. $\qquad\blacksquare$

The obstruction is transparent from Corollary 3.2: the mean equals $\tfrac{b-1}{2}$ if and only if $2R = p\ell$ (times the appropriate factor), and for a short orbit $R$ is far from that value. Here $\operatorname{ord}_7(2) = 3 < 6$, so the orbit $\{1, 2, 4\}$ is a proper subgroup of $(\mathbb{Z}/7\mathbb{Z})^\times$ and sums to $7$, not $21$.

---

## 6. Midy-type complementarity

**Theorem 6.1 (Midy pairing).** Let $p > 0$. Suppose the remainder orbit *reflects* with offset $m$, meaning
$$r_{n+m} + r_n = p \qquad\text{and}\qquad r_{n+m+1} + r_{n+1} = p.$$
Then the paired digits are complementary:
$$d_n + d_{n+m} + 1 = b, \qquad\text{i.e.}\qquad d_n + d_{n+m} = b - 1.$$

*Proof.* Add the Euclidean identity (Lemma 2.3) at indices $n$ and $n+m$:
$$b(r_n + r_{n+m}) = p(d_n + d_{n+m}) + (r_{n+1} + r_{n+m+1}).$$
By hypothesis $r_n + r_{n+m} = p$ and $r_{n+1} + r_{n+m+1} = p$, so
$$b\,p = p(d_n + d_{n+m}) + p = p(d_n + d_{n+m} + 1).$$
Cancelling $p > 0$ gives $b = d_n + d_{n+m} + 1$. $\qquad\blacksquare$

For prime $p$ with even period $\ell$, taking $m = \ell/2$ realizes the reflection hypothesis (since $b^{\ell/2} \equiv -1 \pmod p$), and Theorem 6.1 becomes the classical Midy theorem: opposite digits of the repetend sum to $b-1$. In base ten this is the familiar rule that the two halves of a full-length repeating decimal add to a string of nines: $142 + 857 = 999$.

---

## 7. Algorithms

The theory is fully constructive. We record the two computational primitives used throughout.

### 7.1 Orbit generation

**Input:** integers $p \ge 2$, $b \ge 2$ with $\gcd(p, b) = 1$.
**Output:** one full period of remainders $(r_k)$ and digits $(d_k)$.

```
r <- 1
remainders <- [], digits <- []
repeat
    append r to remainders
    append floor(b * r / p) to digits
    r <- (b * r) mod p
until r = 1
return remainders, digits
```

The loop runs $\ell = \operatorname{ord}_p(b)$ times; each step is $O(\log b + \log p)$ bit operations, so the total cost is $O(\ell \cdot \log(bp))$. The period $\ell$ divides $p-1$ for prime $p$.

### 7.2 Variance via orbit sums

**Input:** the period from §7.1.
**Output:** the exact rational variance $V$, together with a verification of Theorem 5.1.

```
R <- sum r_k
Q <- sum r_k^2
C <- sum r_k * r_{k+1 mod l}
S <- sum d_k
T <- sum d_k^2
assert p*S = (b-1)*R                        # Theorem 3.1
assert p^2*T + 2*b*C = (b^2+1)*Q             # Theorem 4.2
numerator <- l*((b^2+1)*Q - 2*b*C) - (b-1)^2 * R^2
assert p^2*(l*T - S^2) = numerator          # Theorem 5.1
return numerator / (p^2 * l^2)              # exact rational V
```

All arithmetic is exact (integers / rationals); no floating point is required. The dominant cost is the single pass over the period, $O(\ell)$ big-integer operations.

---

## 8. Applications and discussion

**Digit statistics of unit fractions.** Theorem 5.1 gives a formula for the variance of repetend digits that requires computing only three integer sums over the remainder orbit, rather than examining the digits directly. For long repetends this reframing is both conceptually and computationally advantageous.

**A diagnostic for primitivity.** Corollary 3.2 and Theorem 5.2 together show that the digit mean equals $\tfrac{b-1}{2}$ exactly in the balanced-orbit case. Deviations of the mean from $\tfrac{b-1}{2}$ therefore detect that $b$ is not a primitive root modulo $p$ — a fact visible already in the base-$2$ expansion of $1/7$ (Theorem 5.3).

**Midy phenomena in all bases.** Theorem 6.1 isolates the exact hypothesis (orbit reflection) behind the "casting out nines" folklore and shows it is a base-independent phenomenon governed purely by the additive symmetry of the remainder orbit.

**No primality required.** All identities in Sections 3–6 hold for any $p$ coprime to $b$. Primality is only invoked to identify the orbit with a full subgroup, as in Theorem 5.2, and to guarantee reflection for Midy's theorem.

---

## 9. Toward a character-theoretic form

For prime $p$, the remainder orbit is exactly the cyclic subgroup $H = \langle b\rangle \le (\mathbb{Z}/p\mathbb{Z})^\times$ of order $\ell$, and the three orbit sums are symmetric functions over $H$:
$$R = \sum_{h \in H} h, \qquad Q = \sum_{h \in H} h^2, \qquad C = \sum_{h \in H} h\cdot(bh \bmod p).$$
This is the doorway to the conjectural analytic reformulation.

**Step 1 — Subgroup indicator as a character sum.** With $d = (p-1)/\ell$, the indicator of $H$ is
$$\mathbf{1}_H(x) = \frac{\ell}{p-1}\sum_{\chi:\,\chi|_H = 1}\chi(x),$$
the sum over the $d$ Dirichlet characters mod $p$ that are trivial on $H$. Substituting expresses $R$, $Q$, $C$ as $\tfrac{1}{p-1}$-weighted combinations of twisted power sums $\sum_x \chi(x)\,x^k$ over these $d$ characters.

**Step 2 — Twisted power sums as generalized Bernoulli numbers.** For a nonprincipal character $\chi$ mod $p$, the twisted sums $\sum_{x=1}^{p-1}\chi(x)\,x$ and $\sum_{x=1}^{p-1}\chi(x)\,x^2$ equal $p\cdot B_{1,\chi}$ and (up to elementary corrections) $p^2\cdot B_{2,\chi}$, where $B_{k,\chi}$ are the generalized Bernoulli numbers. Substituting turns $R$, $Q$, $C$ into $\mathbb{Q}$-linear combinations of $B_{k,\chi}$ for $\chi$ of order dividing $d$.

Combining these two steps with the elementary identities of this paper would upgrade Theorem 5.1 into a closed formula for the digit variance in terms of generalized Bernoulli numbers of Dirichlet characters whose order divides $d = (p-1)/\ell$, matching the conjectured shape and recovering the known $\ell = p-1$ and $\ell = (p-1)/2$ formulas. The only genuinely new analytic input required is the treatment of the cross sum $C = \sum_h h\cdot(bh \bmod p)$, the single orbit sum that references the base $b$ nontrivially.

---

## 10. Future directions

This work establishes the exact, character-free skeleton of the generalized variance formula, valid for arbitrary repetend length $\ell$ and with no primality assumption. The remaining program is the analytic bridge of Section 9: (i) formalize the subgroup orthogonality relation that writes $\mathbf{1}_H$ as a sum over the $d$ characters trivial on $H$; (ii) establish the identification of twisted power sums $\sum \chi(x)x^k$ with generalized Bernoulli numbers $B_{k,\chi}$; and (iii) handle the base-dependent cross sum $C$, which is the crux of the reduction. Completing these steps would express the digit variance entirely through generalized Bernoulli numbers of characters of order dividing $d$, unifying and extending the classical mean and variance formulas to every repetend length dividing $p-1$.

---

## 11. Conclusion

From the single Euclidean relation $b r_n = p d_n + r_{n+1}$ we derived a complete, exact theory of the mean and variance of the repetend digits of $1/p$ in base $b$: the digit-sum identity $pS = (b-1)R$, the sum-of-squares identity $p^2 T + 2bC = (b^2+1)Q$, and the master variance identity $p^2(\ell T - S^2) = \ell((b^2+1)Q - 2bC) - (b-1)^2 R^2$. These hold for arbitrary period length and without primality, subsuming the classical full- and half-reptend results as special cases, formalizing Midy-type complementarity, and disproving the naive universality of the mean $\tfrac{b-1}{2}$. The remainder-orbit sums $R, Q, C$ are the true carriers of the digit statistics, and their subgroup structure marks the precise point where elementary arithmetic hands off to the analytic theory of Dirichlet characters.
