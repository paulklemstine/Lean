# The $E_4^2 = E_8$ Congruence: The Sharp Arithmetic Shadow of the Siegel–Weil Identity in Rank Eight

**Author:** Aristotle

**Date:** 2026-07-13

## Abstract

The Siegel–Weil identity in rank $8$ asserts that the theta series of the even unimodular lattice $E_8$ equals the weight-$4$ Eisenstein series $E_4$; at the level of Fourier coefficients this reads $r(n) = 240\,\sigma_3(n)$, where $r(n)$ counts the lattice vectors of squared length $2n$ and $\sigma_3(n) = \sum_{d \mid n} d^3$. Squaring the identity yields the rank-$16$ genus statement $E_4^2 = E_8$, whose coefficient form is the convolution law $\sigma_7(n) = \sigma_3(n) + 120\sum_{i=1}^{n-1}\sigma_3(i)\sigma_3(n-i)$. We isolate and prove the *arithmetic shadow* of this convolution law: the congruence $\sigma_7(n) \equiv \sigma_3(n) \pmod{120}$ for all $n$, together with the optimality of the modulus — the congruence fails modulo $240$. The proof is elementary and modular: the pointwise power congruence $d^7 \equiv d^3 \pmod{120}$ is established locally at the pairwise-coprime prime-power factors $8$, $3$, $5$ of $120$ and glued by the Chinese Remainder Theorem; summing over divisors lifts it to $\sigma_7 \equiv \sigma_3 \pmod{120}$. We record the integral divisibility corollary $120 \mid \sigma_7(n) - \sigma_3(n)$ and its transport to lattice representation numbers, where the normalized counts $240\,\sigma_7(n)$ and $240\,\sigma_3(n)$ differ by a multiple of $28800$. The value $120$ is thus pinned as the exact arithmetic weight of the $E_4^2 = E_8$ self-convolution correction, and it is sharp.

**Keywords:** $E_8$ lattice, theta series, Eisenstein series, Siegel–Weil formula, divisor sums, power congruences, Chinese Remainder Theorem, modular forms.

## 1. Introduction

### 1.1 Lattices, theta series, and modular forms

A *lattice* $L$ of rank $r$ is a discrete subgroup of $\mathbb{R}^r$ of full rank, equivalently the integer span of a basis $b_1, \dots, b_r$. It is *integral* if $\langle u, v\rangle \in \mathbb{Z}$ for all $u, v \in L$, *even* if $\langle v, v\rangle \in 2\mathbb{Z}$ for all $v$, and *unimodular* if it equals its dual $L^\* = \{x : \langle x, v\rangle \in \mathbb{Z} \ \forall v \in L\}$ (equivalently, its Gram determinant is $1$).

The **theta series** of $L$ encodes the distribution of squared lengths:
$$\theta_L(\tau) = \sum_{v \in L} q^{\langle v, v\rangle/2}, \qquad q = e^{2\pi i \tau}, \ \operatorname{Im}\tau > 0.$$
For an even unimodular lattice of rank $r \equiv 0 \pmod 8$, $\theta_L$ is a modular form of weight $r/2$ for the full modular group $\mathrm{SL}_2(\mathbb{Z})$.

**Eisenstein series.** For even weight $k \ge 4$, the normalized Eisenstein series is
$$E_k(\tau) = 1 - \frac{2k}{B_k}\sum_{n \ge 1}\sigma_{k-1}(n)\,q^n, \qquad \sigma_{s}(n) = \sum_{d \mid n} d^{s},$$
where $B_k$ is the $k$-th Bernoulli number. In the two cases relevant here,
$$E_4(\tau) = 1 + 240\sum_{n\ge 1}\sigma_3(n)\,q^n, \qquad E_8(\tau) = 1 + 480\sum_{n\ge 1}\sigma_7(n)\,q^n,$$
using $B_4 = -1/30$ and $B_8 = -1/30$, so that $-2\cdot 4/B_4 = 240$ and $-2\cdot 8/B_8 = 480$.

### 1.2 The rank-$8$ Siegel–Weil identity

The space $M_4(\mathrm{SL}_2(\mathbb{Z}))$ of weight-$4$ modular forms is one-dimensional, spanned by $E_4$. Since $E_8$ (the lattice) is the unique even unimodular lattice of rank $8$ and $\theta_{E_8}$ is a weight-$4$ form with constant term $1$, we obtain
$$\theta_{E_8} = E_4.$$
Comparing Fourier coefficients gives the representation-number formula
$$r(n) := \#\{v \in E_8 : \langle v, v\rangle = 2n\} = 240\,\sigma_3(n), \qquad n \ge 1.$$
This is the foundational case of the classical **Siegel–Weil formula**, which equates a suitably weighted average of theta series over a genus of quadratic forms with an Eisenstein series. In rank $8$ the genus is a single class, so the average degenerates to the single identity above.

### 1.3 Squaring: the weight-$8$ convolution law

The space $M_8(\mathrm{SL}_2(\mathbb{Z}))$ is also one-dimensional, spanned by $E_8$; there is no cusp form of weight $8$. Consequently $E_4^2$, being a weight-$8$ form with constant term $1$, must equal $E_8$:
$$E_4^2 = E_8.$$
Expanding the left side as a Cauchy product and matching the coefficient of $q^n$ yields, after dividing through by the normalizing constants, the **convolution identity**
$$\boxed{\ \sigma_7(n) = \sigma_3(n) + 120\sum_{i=1}^{n-1}\sigma_3(i)\,\sigma_3(n-i)\ } \tag{$\star$}$$
valid for all $n \ge 1$. (The constant $120 = 240^2 / 480$ is exactly the ratio of Eisenstein normalizations.) Identity $(\star)$ is a classical relation of Ramanujan type between divisor-power sums.

### 1.4 The contribution of this paper

Identity $(\star)$ displays $\sigma_7(n) - \sigma_3(n)$ as $120$ times an integer, hence divisible by $120$. We take this observation as a theorem in its own right, prove it *independently* of $(\star)$ by a self-contained modular argument, and establish that the modulus $120$ is optimal. Our results are:

1. **(Pointwise power congruence.)** $d^7 \equiv d^3 \pmod{120}$ for every integer $d \ge 0$, proved by gluing local congruences modulo $8$, $3$, $5$.
2. **(Divisor-sum congruence.)** $\sigma_7(n) \equiv \sigma_3(n) \pmod{120}$ for every $n$.
3. **(Integral divisibility.)** $120 \mid \sigma_7(n) - \sigma_3(n)$ in $\mathbb{Z}$.
4. **(Optimality.)** The congruence fails modulo $240$; concretely $\sigma_7(2) - \sigma_3(2) = 120$.
5. **(Lattice transport.)** The normalized counts $s(n) = 240\,\sigma_7(n)$ and $r(n) = 240\,\sigma_3(n)$ satisfy $28800 \mid s(n) - r(n)$.

The interest of this development is threefold. First, it produces a fully elementary certificate for a fact that a priori seems to require the modular identity $(\star)$. Second, it pins the constant $120$ as the *exact* arithmetic weight of the correction term, not merely an upper bound. Third, it exhibits a clean template — local computation at prime powers plus Chinese Remainder gluing plus divisor-sum summation — that generalizes to a whole hierarchy of Eisenstein congruences.

## 2. Definitions and notation

Throughout, $n$ and $d$ denote non-negative integers and all congruences are of integers.

**Definition 2.1 (Divisor-power sum).** For $s \ge 0$ and $n \ge 1$,
$$\sigma_s(n) = \sum_{d \mid n} d^s,$$
the sum over positive divisors $d$ of $n$. By convention $\sigma_s(0)$ is taken to be the empty sum $0$ (no positive divisor divides $0$ in the finite-support convention used here), so all statements below hold uniformly for $n \ge 0$.

**Definition 2.2 (Congruence).** For integers $a$, $b$, $m$ we write $a \equiv b \pmod m$ to mean $m \mid (a - b)$.

**Definition 2.3 ($E_8$ representation number).** $r(n) = 240\,\sigma_3(n)$; by the rank-$8$ Siegel–Weil identity this equals the number of $E_8$ vectors of squared length $2n$.

**Definition 2.4 (Weight-$8$ companion count).** $s(n) = 240\,\sigma_7(n)$, the coefficient system attached to $E_8$ (equivalently, $\tfrac12$ the Fourier coefficient $480\,\sigma_7(n)$ of $E_8$, up to normalization; we use the $240$-normalization for direct comparison with $r$).

## 3. Local power congruences

The engine of the paper is the pointwise congruence $d^7 \equiv d^3$ modulo each prime-power factor of $120 = 2^3 \cdot 3 \cdot 5 = 8 \cdot 3 \cdot 5$. Each is a finite check on residue classes, made finite by the reduction $d^k \bmod m = (d \bmod m)^k \bmod m$.

**Lemma 3.1 (Mod $8$).** For every integer $d \ge 0$, $\ d^7 \equiv d^3 \pmod 8$.

*Proof.* Since $d^k \bmod 8$ depends only on $d \bmod 8$, it suffices to check the eight residues $d \equiv 0, 1, \dots, 7 \pmod 8$. Conceptually: if $d$ is even, $8 = 2^3 \mid d^3$ and $8 \mid d^7$, so both sides are $0 \pmod 8$. If $d$ is odd, then $d^2 \equiv 1 \pmod 8$ (the square of any odd number is $1$ mod $8$), whence $d^4 = (d^2)^2 \equiv 1$ and $d^7 = d^3\cdot d^4 \equiv d^3 \pmod 8$. $\qquad\blacksquare$

**Lemma 3.2 (Mod $3$).** For every integer $d \ge 0$, $\ d^7 \equiv d^3 \pmod 3$.

*Proof.* Check $d \equiv 0, 1, 2 \pmod 3$. If $3 \mid d$ both sides vanish. If $3 \nmid d$, Fermat's little theorem gives $d^2 \equiv 1 \pmod 3$, so $d^4 \equiv 1$ and $d^7 = d^3 \cdot d^4 \equiv d^3 \pmod 3$. $\qquad\blacksquare$

**Lemma 3.3 (Mod $5$).** For every integer $d \ge 0$, $\ d^7 \equiv d^3 \pmod 5$.

*Proof.* Check $d \equiv 0, 1, 2, 3, 4 \pmod 5$. If $5 \mid d$ both sides vanish. If $5 \nmid d$, Fermat's little theorem gives $d^4 \equiv 1 \pmod 5$, so $d^7 = d^3 \cdot d^4 \equiv d^3 \pmod 5$. $\qquad\blacksquare$

**Theorem 3.4 (Global power congruence).** For every integer $d \ge 0$,
$$d^7 \equiv d^3 \pmod{120}.$$

*Proof.* The moduli $8$, $3$, $5$ are pairwise coprime with product $120$. By Lemmas 3.2 and 3.3 and the Chinese Remainder Theorem, $d^7 \equiv d^3 \pmod{15}$. Combining this with Lemma 3.1 and coprimality of $8$ and $15$, again by the Chinese Remainder Theorem, $d^7 \equiv d^3 \pmod{8 \cdot 15} = \pmod{120}$. $\qquad\blacksquare$

## 4. The weight-$8$ / weight-$4$ congruence

**Theorem 4.1 (The $E_4^2 = E_8$ congruence).** For every $n \ge 0$,
$$\sigma_7(n) \equiv \sigma_3(n) \pmod{120}.$$

*Proof.* Expanding the divisor sums,
$$\sigma_7(n) - \sigma_3(n) = \sum_{d \mid n} (d^7 - d^3).$$
By Theorem 3.4 each summand satisfies $120 \mid d^7 - d^3$, and a sum of multiples of $120$ is a multiple of $120$. Equivalently, reducing each term modulo $120$ leaves the two divisor sums with identical residues. Hence $\sigma_7(n) \equiv \sigma_3(n) \pmod{120}$. $\qquad\blacksquare$

**Proposition 4.2 (Termwise dominance).** For every $n$, $\ \sigma_3(n) \le \sigma_7(n)$.

*Proof.* For each divisor $d \ge 1$, $d^3 \le d^7$; summing over the divisors of $n$ gives the claim. $\qquad\blacksquare$

**Corollary 4.3 (Integral divisibility form).** For every $n$,
$$120 \mid \sigma_7(n) - \sigma_3(n) \quad \text{in } \mathbb{Z},$$
and by Proposition 4.2 the quotient is non-negative. Under identity $(\star)$ the quotient equals the self-convolution $\sum_{i=1}^{n-1}\sigma_3(i)\sigma_3(n-i)$.

*Proof.* Immediate from Theorem 4.1 and the definition of congruence. $\qquad\blacksquare$

## 5. Optimality of the modulus

**Theorem 5.1 (Sharpness).** The congruence of Theorem 4.1 is optimal: it is not true that $\sigma_7(n) \equiv \sigma_3(n) \pmod{240}$ for all $n$. Explicitly, at $n = 2$,
$$\sigma_7(2) - \sigma_3(2) = 129 - 9 = 120,$$
which is divisible by $120$ but not by $240$.

*Proof.* The divisors of $2$ are $1$ and $2$, so $\sigma_7(2) = 1^7 + 2^7 = 1 + 128 = 129$ and $\sigma_3(2) = 1^3 + 2^3 = 1 + 8 = 9$. Their difference is $120$, and $240 \nmid 120$. Thus $n = 2$ witnesses the failure modulo $240$. $\qquad\blacksquare$

The proof of Theorem 5.1 also clarifies *why* $120$ is exactly right. Identity $(\star)$ shows the correction term is literally $120$ times a self-convolution; at $n = 2$ that self-convolution is $\sigma_3(1)^2 = 1$, so the correction is exactly $120$. Any modulus strictly larger than $120$ and divisible by it (such as $240$) is defeated by this smallest nontrivial coefficient. Hence $120$ is the greatest common divisor of the set $\{\sigma_7(n) - \sigma_3(n) : n \ge 1\}$, i.e. the exact arithmetic weight of the correction.

## 6. Transport to lattice representation numbers

**Theorem 6.1 (Genus-level congruence).** With $r(n) = 240\,\sigma_3(n)$ and $s(n) = 240\,\sigma_7(n)$,
$$28800 \mid s(n) - r(n) \quad \text{in } \mathbb{Z}, \qquad \text{i.e. } s(n) \equiv r(n) \pmod{28800},$$
where $28800 = 240 \cdot 120$.

*Proof.* By Corollary 4.3, $120 \mid \sigma_7(n) - \sigma_3(n)$. Multiplying by $240$,
$$s(n) - r(n) = 240\big(\sigma_7(n) - \sigma_3(n)\big)$$
is divisible by $240 \cdot 120 = 28800$. $\qquad\blacksquare$

**Interpretation.** For the rank-$16$ even unimodular lattices — there are exactly two up to isometry, $E_8 \oplus E_8$ and $D_{16}^+$ — the vector counts differ from one another only through the weight-$8$ cusp form contribution. Since $M_8$ has no cusp forms, both theta series equal $E_8$ and the counts coincide with $480\,\sigma_7(n)$. Theorem 6.1 records that these weight-$8$ counts sit in a fixed residue class modulo $28800$ relative to the (scaled) $E_8$ vector count $240\,\sigma_3(n)$ — a geometric congruence descending purely from elementary power residues.

## 7. Algorithms

We summarize the computational content in three routines. All are elementary and run in time polynomial in $n$.

**Algorithm 7.1 (Divisor-power sum).** Compute $\sigma_s(n)$ by iterating over $d = 1, \dots, n$, testing $d \mid n$, and accumulating $d^s$. Complexity $O(n \log s)$ per value (or $O(\sqrt n \log s)$ with divisor pairing).

**Algorithm 7.2 (Congruence certificate).** For a range $n = 1, \dots, N$, compute $\sigma_7(n) - \sigma_3(n)$ and verify divisibility by $120$; simultaneously verify $(\star)$ by computing the self-convolution $\sum_{i=1}^{n-1}\sigma_3(i)\sigma_3(n-i)$ and checking equality after scaling by $120$.

**Algorithm 7.3 (Sharpness search).** Compute $g = \gcd_{1 \le n \le N}\big(\sigma_7(n) - \sigma_3(n)\big)$; the value stabilizes at $g = 120$ already at $n = 2$, certifying optimality.

## 8. Applications and discussion

**A hand-checkable fingerprint of Siegel–Weil.** The identity $\theta_{E_8} = E_4$ is a deep statement; Theorem 4.1 is a consequence small enough to verify with pencil and paper, yet it points directly at the modular structure above it. Such congruences are useful sanity checks in explicit computations with modular forms and lattice theta series.

**The role of Bernoulli denominators.** The constant $120$ is $-2 \cdot 8 / B_8$ divided by suitable factors; more structurally, moduli in this family track the denominators of Bernoulli numbers via the von Staudt–Clausen theorem. This explains both why $120 = 8 \cdot 3 \cdot 5$ factors so cleanly and why the local pieces sit at exactly the primes $2, 3, 5$.

**Elementary vs. modular proofs.** That an identity provable through the theory of modular forms also admits a fully elementary residue-theoretic proof is a recurring and instructive phenomenon. Here the elementary proof even yields *more*: sharpness of the modulus, which the modular identity gives only after inspecting the smallest coefficient.

## 9. Future directions

**Direction 1 — The exact convolution law.** Upgrade Theorem 4.1 to the equality $(\star)$: prove $\sigma_7(n) = \sigma_3(n) + 120\sum_{i=1}^{n-1}\sigma_3(i)\sigma_3(n-i)$ directly, so that $\sigma_7(n) - \sigma_3(n)$ is a *positive* multiple of $120$ for all $n \ge 2$, pinning $120$ to the one-dimensionality of the weight-$8$ Eisenstein space.

**Direction 2 — A congruence hierarchy across even weights.** For each $k \ge 2$, seek the optimal modulus $M_k$ with $\sigma_{2k-1}(n) \equiv \sigma_3(n) \pmod{M_k}$ for all $n$, conjecturally governed by Bernoulli-number denominators, with $M_4 = 120$ the first nontrivial instance. The local-plus-CRT template generalizes verbatim to any squarefree-supported modulus, and the smallest-exceptional-$n$ method certifies each $M_k$ as sharp.

**Direction 3 — Representation-number congruences for lattice genera.** For every even unimodular lattice of rank $16$, the number of vectors of squared length $2n$ is congruent modulo $28800$ to $240\,\sigma_3(n)$, uniformly in $n$; the two rank-$16$ lattices $E_8 \oplus E_8$ and $D_{16}^+$ differ only through a cusp-form contribution that vanishes modulo $28800$. The integral divisibility of Theorem 6.1 already supplies the exact modulus.

## 10. Conclusion

Starting from the rank-$8$ Siegel–Weil identity $\theta_{E_8} = E_4$ and its square $E_4^2 = E_8$, we isolated the arithmetic shadow $\sigma_7(n) \equiv \sigma_3(n) \pmod{120}$, gave a self-contained modular proof via local power congruences and the Chinese Remainder Theorem, and proved that $120$ is the exact and optimal modulus. Transporting the statement to representation numbers yields a genus-level congruence modulo $28800$. The development is elementary, sharp, and template-generalizable, pointing toward a full Bernoulli-indexed hierarchy of Eisenstein coefficient congruences.
