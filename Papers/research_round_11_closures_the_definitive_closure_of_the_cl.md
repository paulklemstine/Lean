# The Cycle-Index Fingerprint of a Semiprime: Exact Spectra, Burnside Averages, and an Information-Theoretic Order Seal

**Author:** Aristotle
**Date:** 2026-08-12

---

## Abstract

For a semiprime $N = pq$ and a base $b$ coprime to $N$, the *cycle-index fingerprint* is the freely computable sequence $F(c) = \gcd(b^{c}-1,\,N)$. We give a complete and exact analysis of this object and of three natural structures built on top of it: its Möbius spectrum, its Burnside orbit average, and its information content about the secret statistic $p+q$.

We prove: (i) a **structure theorem**, $F(c) = p^{[d_p \mid c]} q^{[d_q \mid c]}$ where $d_p, d_q$ are the multiplicative orders of $b$ modulo $p$ and $q$; (ii) an **order seal**, namely that $d^{*} = \min(d_p,d_q)$ is the least index at which $F$ is nontrivial, and that $F(d^{*})$ is a proper nontrivial divisor of $N$ whenever $d_p \neq d_q$; (iii) an **exact four-atom Möbius spectrum**, $M_d = [d=1] + (p-1)[d_p=d] + (q-1)[d_q=d] + \varphi(N)[n=d]$ with $n = \mathrm{lcm}(d_p,d_q)$, together with the delta-function identity $\sum_{c\mid d}\mu(d/c)\,v_p(F(c)) = [d_p=d]$; (iv) a **starvation theorem**: on any finite instance family whose local orders exceed the observation window $D$, the truncated fingerprint $(F(1),\dots,F(D))$ carries exactly zero information — in an exact, finitary, counting sense — about $(p+q) \bmod \ell$ for every modulus $\ell$, and the same holds for every post-processing of the window; (v) a **Burnside/orbit-count identity** $C\cdot n = n + (p-1)(n/d_p) + (q-1)(n/d_q) + \varphi(N)$ derived from the observation that $F(k)$ is precisely the number of fixed points of multiplication by $b^{k}$ on $\mathbb{Z}/N$, together with a dichotomy showing that the orbit count is either a factoring oracle or, in the balanced case $d_p = d_q$, a function of $(N, \mathrm{ord}_N b)$ alone; and (vi) an **exponent-invariance lemma** pricing constant-factor speedups of rho-type methods as asymptotically free while showing the pricing is sharp against power-strength speedups.

Taken together these results delimit, with exact statements rather than measurements, a closed portion of the classical attack surface on semiprimes: every object considered here is, below the order scale, a constant function of the instance.

**Keywords:** semiprime factorization, multiplicative order, Möbius inversion, Burnside's lemma, cycle index, information barriers, Coppersmith hint amplification, Dickman function.

---

## 1. Introduction

### 1.1 Motivation

Let $N = pq$ be a semiprime with $p \neq q$ prime, and let $b$ be coprime to $N$. Essentially every classical factoring heuristic that is not a sieve is, at bottom, an attempt to detect the multiplicative structure of $(\mathbb{Z}/N)^{\times}$ through quantities computable from $N$ alone. The canonical such quantity is

$$F(c) \;=\; \gcd\!\left(b^{c}-1,\; N\right),$$

which we call the **cycle-index fingerprint** of the pair $(N,b)$: it is computable in $O(\log c)$ modular multiplications plus one gcd, hence in time polynomial in $\log N$ for any $c$ presented in binary. Pollard's $p-1$ method, the $\rho$ method's gcd-batching layer, and a long list of variants all read this sequence, or a randomized surrogate for it.

The question addressed in this paper is not whether $F$ can be used to factor — it can, if you can reach the right index — but the sharper structural question: **exactly how much information does $F$, or any object derived from it, carry about the factorization before the order scale is reached?** We answer this with exact identities, not asymptotics or experiments.

The motivation for exactness is the existence of a genuine amplification channel. If one knows $N$ together with the sum $\sigma = p+q$, the factorization follows immediately; and lattice methods for small roots of modular polynomials amplify an approximation $\hat\sigma$ with $|\hat\sigma - \sigma| < N^{1/4}$ into a full factorization in polynomial time. Consequently, any *source* of even weak information about $p+q$ that is computable from $N$ would be a break. It therefore matters enormously whether a rich-looking object such as the Möbius spectrum of $F$ constitutes such a source. We prove that it does not, in the strongest sense available: below the order scale the object is a constant function of the instance, so its fibres cannot separate any secret whatsoever.

### 1.2 Contributions

1. **Exact structure and order seal** for the fingerprint (Section 3).
2. **The complete Möbius spectrum**, both in its raw $N$-computable form and in its valuation form, showing that the spectrum is supported on at most four points, all at the order scale (Section 4).
3. **A finitary zero-information calculus** (`counting independence`), a data-processing lemma for it, and the starvation theorem for the truncated fingerprint and its Möbius window, with a matching sharpness witness showing the theorem fails as soon as the window reaches the order scale (Section 5).
4. **The Burnside orbit-count identity** together with the fixed-point interpretation of $F$, and a dichotomy showing that the topological re-encoding is either a factoring oracle or informationless (Section 6).
5. **An exponent-invariance lemma** pricing constant-factor policy improvements, with a sharpness counterpart (Section 7).

### 1.3 Notation

Throughout, $p \ne q$ are primes, $N = pq$, and $b \ge 1$ is an integer coprime to $N$. We write

- $d_p = \mathrm{ord}_p(b)$, the least $k>0$ with $b^{k} \equiv 1 \pmod p$; likewise $d_q$;
- $d^{*} = \min(d_p, d_q)$, the **order scale**;
- $n = \mathrm{ord}_N(b) = \mathrm{lcm}(d_p, d_q)$;
- $\varphi$ for Euler's totient, so $\varphi(N) = (p-1)(q-1)$;
- $\mu$ for the Möbius function;
- $[\,P\,]$ for the Iverson bracket, $1$ if $P$ holds and $0$ otherwise;
- $v_p(m)$ for the exponent of $p$ in $m$.

---

## 2. The objects of study

**Definition 2.1 (Cycle-index fingerprint).** For integers $b, N, c$ with $c \ge 0$,
$$F_{b,N}(c) \;=\; \gcd\!\left(b^{c}-1,\; N\right).$$
We drop the subscripts when they are clear. Each value is computable in $\mathrm{poly}(\log N, \log c)$ time.

**Definition 2.2 (Raw Möbius spectrum).** For $d \ge 1$,
$$M_d \;=\; \sum_{c \mid d} \mu\!\left(\frac{d}{c}\right) F(c).$$
This is $N$-computable: evaluating $M_d$ requires only the divisors of $d$ and the corresponding fingerprint values.

**Definition 2.3 (Valuation spectrum).** For a prime $p \mid N$ and $d \ge 1$,
$$M^{(p)}_d \;=\; \sum_{c \mid d} \mu\!\left(\frac{d}{c}\right) v_p\big(F(c)\big).$$
This is *not* $N$-computable — evaluating $v_p$ presupposes knowing $p$ — but it is the cleanest diagnostic of the fingerprint's spectral content.

**Definition 2.4 (Observation window).** For $D \ge 1$, the **truncated fingerprint** is the vector
$$\mathcal{W}_D(p,q,b) \;=\; \big(F(1), F(2), \dots, F(D)\big) \in \mathbb{N}^{D},$$
and the **Möbius window** is $\mathcal{M}_D(p,q,b) = (M_1, \dots, M_D) \in \mathbb{Z}^{D}$. These model exactly what an attacker with a budget of $D$ fingerprint evaluations can read.

---

## 3. Structure of the fingerprint and the order seal

The following lemma is the engine of everything that follows.

**Lemma 3.1 (Order detection).** Let $p$ be prime and $b \ge 1$ with $p \nmid b$. Then for all $c \ge 0$,
$$p \mid b^{c}-1 \iff d_p \mid c.$$

*Proof sketch.* Reducing modulo $p$, the condition $p \mid b^c - 1$ says $b^{c} \equiv 1$ in the field $\mathbb{Z}/p$; and in any group an element satisfies $x^{c}=1$ exactly when its order divides $c$. The only care needed is that the integer subtraction $b^{c}-1$ be interpreted correctly, which requires $b \ge 1$. $\square$

**Lemma 3.2 (gcd with a prime).** For any $m$ and prime $p$, $\gcd(m,p) = p$ if $p \mid m$ and $1$ otherwise. $\square$

**Theorem 3.3 (Structure of the fingerprint).** Let $N = pq$ with $p \neq q$ prime and $b \ge 1$. Then for every $c \ge 0$,
$$F(c) \;=\; p^{[\,d_p \mid c\,]}\, q^{[\,d_q \mid c\,]} \;=\; \big(\text{$p$ if $d_p\mid c$ else }1\big)\cdot\big(\text{$q$ if $d_q\mid c$ else }1\big).$$

*Proof sketch.* Since $p$ and $q$ are coprime, $\gcd(m, pq) = \gcd(m,p)\gcd(m,q)$. Apply Lemma 3.2 to each factor and rewrite the divisibility conditions with Lemma 3.1. $\square$

Thus $F$ is a two-tone multiplicative square wave: equal to $1$ off the union of the two arithmetic progressions $d_p\mathbb{Z}$ and $d_q\mathbb{Z}$, equal to $p$ on $d_p\mathbb{Z}\setminus d_q\mathbb{Z}$, to $q$ on $d_q\mathbb{Z}\setminus d_p\mathbb{Z}$, and to $N$ on $n\mathbb{Z}$.

**Lemma 3.4 (Positivity of the local order).** If $p$ is prime and $p \nmid b$, then $d_p > 0$; indeed $d_p \mid p-1$ by Fermat's little theorem. $\square$

**Theorem 3.5 (The order seal).** With hypotheses as in Theorem 3.3, for every $c$ with $0 < c < d^{*} = \min(d_p,d_q)$ we have $F(c) = 1$.

*Proof sketch.* If $d_p \mid c$ with $c > 0$ then $d_p \le c < d^{*} \le d_p$, a contradiction; likewise for $q$. Both indicators in Theorem 3.3 vanish. $\square$

**Theorem 3.6 (Informative entry at the order scale).** $F(d^{*}) > 1$.

*Proof sketch.* At $c = d^{*}$ at least one of the two divisibility conditions holds (whichever order attains the minimum divides itself), so the product contains a factor $p \ge 2$ or $q \ge 2$. $\square$

**Theorem 3.7 (The order scale splits $N$).** Suppose additionally $p \nmid b$, $q \nmid b$ and $d_p \neq d_q$. Then
$$1 \;<\; F(d^{*}) \;<\; N, \qquad F(d^{*}) \mid N,$$
i.e. $F(d^{*}) \in \{p,q\}$ is a proper nontrivial factor of $N$.

*Proof sketch.* Say $d_p < d_q$, so $d^{*} = d_p$. Then $d_q \nmid d_p$ (otherwise $d_q \le d_p$), so by Theorem 3.3 $F(d^{*}) = p$, which is $>1$ and $<pq$. The symmetric case is identical. Divisibility is immediate from the definition of the gcd. $\square$

**Theorem 3.8 (Sharp threshold).** Under the hypotheses of Theorem 3.7 (without needing $d_p \ne d_q$, provided both orders are positive), $d^{*}$ is the *least* element of $\{c > 0 : F(c) > 1\}$.

*Proof sketch.* Membership is Theorem 3.6; minimality is Theorem 3.5. $\square$

**Remark 3.9 (Why $d^{*} \approx \sqrt{N}$).** By Lemma 3.4, $d_p \mid p-1$. For a random base $b$ modulo a random prime $p$, the order $d_p$ is with high probability a large divisor of $p-1$; the density of bases with $d_p \le B$ is at most $B^{2}/p$ by a standard counting argument (there are at most $B$ elements of order dividing each $k \le B$). Hence for generic instances $d^{*}$ is of size comparable to $\min(p,q) \approx \sqrt{N}$, and the exceptional small-$d^{*}$ instances are exactly the ones that Pollard's $p-1$ method already exploits, i.e. those where $p-1$ is smooth. The seal is therefore not a weakness of the analysis: the square-root wall of elementary methods and the order seal are the same phenomenon.

---

## 4. The Möbius spectrum

Möbius inversion is the natural way to ask what happens *at scale $d$* rather than *at all divisors of $d$*. We compute the answer exactly. The key combinatorial ingredient is the following.

**Lemma 4.1 (Möbius detection).** For positive integers $k$ and $d$,
$$\sum_{c \mid d} \mu\!\left(\frac{d}{c}\right)\,[\,k \mid c\,] \;=\; [\,k = d\,].$$

*Proof sketch.* Substitute $c = d/j$ to rewrite the sum as $\sum_{j \mid d}\mu(j)\,[\,k \mid d/j\,]$. If $k \nmid d$ then no term survives, and $k \ne d$, so both sides vanish. If $k \mid d$, write $d = ke$; then $k \mid d/j \iff j \mid e$, so the sum collapses to $\sum_{j \mid e}\mu(j)$, which equals $[\,e=1\,]$ by the defining property of the Möbius function, and $e = 1 \iff k = d$. $\square$

**Lemma 4.2 (Valuation of the fingerprint).** $v_p\big(F(c)\big) = [\,d_p \mid c\,]$.

*Proof sketch.* Immediate from Theorem 3.3, since $p$ and $q$ are distinct primes so the factorization of $F(c)$ is squarefree with exponents given by the indicators. $\square$

**Theorem 4.3 (Valuation spectrum is an order delta).** For $d > 0$, with $p \nmid b$,
$$M^{(p)}_d \;=\; \sum_{c \mid d}\mu\!\left(\frac{d}{c}\right) v_p\big(F(c)\big) \;=\; [\,d_p = d\,].$$

*Proof sketch.* Substitute Lemma 4.2 and apply Lemma 4.1 with $k = d_p > 0$ (Lemma 3.4). $\square$

**Corollary 4.4 (Spectral vanishing below the order scale).** If $0 < d < d^{*}$ then $M^{(p)}_d = M^{(q)}_d = 0$. $\square$

**Corollary 4.5 (Unit point mass over a window).** For any $D \ge 1$,
$$\sum_{d=1}^{D} M^{(p)}_d \;=\; [\,d_p \le D\,].$$
The entire informational content of the valuation spectrum over an observation window is the single bit "the order scale has been reached". $\square$

The raw, $N$-computable spectrum has the same shape with arithmetically meaningful masses.

**Theorem 4.6 (The four-atom spectrum).** Let $p\ne q$ be primes, $b \ge 1$ with $p\nmid b$, $q\nmid b$, and $d > 0$. Then
$$M_d \;=\; [\,d=1\,] \;+\; (p-1)\,[\,d_p = d\,] \;+\; (q-1)\,[\,d_q = d\,] \;+\; (p-1)(q-1)\,[\,n = d\,],$$
where $n = \mathrm{lcm}(d_p,d_q) = \mathrm{ord}_N(b)$.

*Proof sketch.* The proof is inclusion–exclusion followed by Lemma 4.1. Expand the pointwise identity
$$F(c) \;=\; 1 + (p-1)[\,d_p \mid c\,] + (q-1)[\,d_q\mid c\,] + (p-1)(q-1)[\,n \mid c\,],$$
which is verified by checking the four cases of the pair of indicators, using $d_p \mid c \wedge d_q \mid c \iff n \mid c$. Now apply $\sum_{c\mid d}\mu(d/c)(-)$ term by term. The constant term $1 = [\,1 \mid c\,]$ contributes $[\,1 = d\,]$ by Lemma 4.1 with $k=1$; the other three terms contribute $[\,d_p=d\,]$, $[\,d_q=d\,]$, $[\,n=d\,]$ with their respective weights. $\square$

**Corollary 4.7 (Instance-independence below the order scale).** For $0 < d < d^{*}$, $M_d = [\,d=1\,]$. In particular the Möbius window $\mathcal{M}_D$ equals the universal vector $(1,0,0,\dots,0)$ for *every* instance with $D < d^{*}$.

*Proof sketch.* Directly from Theorem 4.6, since none of $d_p, d_q, n$ is $< d^{*}$; alternatively, from Theorem 3.5 plus $\sum_{c \mid d}\mu(c) = [\,d=1\,]$. $\square$

**Interpretation.** The spectrum of the fingerprint is a sum of four Dirac masses located at $1$, $d_p$, $d_q$ and $n$, with masses $1$, $p-1$, $q-1$ and $\varphi(N)$. The masses are precisely the secrets: recovering the mass at $n$ is recovering $\varphi(N)$, which together with $N$ yields $p$ and $q$ by sum–product inversion (Theorem 5.1). But the atoms are *located* at the order scale. Möbius inversion is a genuine change of basis on the fingerprint sequence; it is not an information-relocating one.

---

## 5. Zero information: the starvation theorem

### 5.1 The channel is real

**Theorem 5.1 (Sum–product inversion).** If $a+b = c+d$ and $ab = cd$ for positive integers, then $\{a,b\} = \{c,d\}$.

*Proof sketch.* Over $\mathbb{Z}$, expand $(c-a)(c-b) = c^{2} - c(a+b) + ab = c^{2} - c(c+d) + cd = 0$. Hence $c = a$ or $c = b$, and the partner is forced by the sum. $\square$

Consequently the pair $(N, \sigma)$ with $\sigma = p+q$ determines $\{p,q\}$: they are the roots of $x^{2}-\sigma x + N$. Lattice methods for small modular roots extend this to approximate hints: an estimate $\hat\sigma$ with $|\hat\sigma - \sigma| < N^{1/4}$ suffices for polynomial-time recovery. The channel exists; what is at issue is the *source*.

**Theorem 5.2 (Weighted inversion).** Let $A, B \ge 0$ and suppose $pq = p'q' = N$ and $Ap + Bq = Ap' + Bq'$. Then either $p = p'$ or $A\,p\,p' = B\,N$.

*Proof sketch.* From $q = N/p$ and $q' = N/p'$, the linear relation becomes, after clearing denominators, $(p-p')\big(A(p+p') - (Ap+Bq)\big) = 0$. The first factor gives $p = p'$; the second, combined with $pq = N$, rearranges to $App' = BN$. $\square$

Thus an affine observation in $(p,q)$ with not-both-zero coefficients, combined with $N$, restricts the factorization to at most two candidates — a fact we use in Section 6.

**Corollary 5.3 (Degenerate case).** If $A = 0$ and $B > 0$, the relation reads $Bq = Bq'$, hence $q = q'$: the hint determines the factorization outright. $\square$

### 5.2 A finitary notion of zero information

We deliberately avoid probability measures in favour of an exact counting notion, which is stronger (it is an identity between integers) and composes cleanly.

**Definition 5.4 (Counting independence).** Let $\Omega$ be a finite set of instances, $T : \Omega \to \mathcal{T}$ a statistic and $S : \Omega \to \mathcal{S}$ a secret. Say $T$ carries **zero information** about $S$ on $\Omega$, written $\mathrm{ZeroInfo}(\Omega, T, S)$, if for all $t, s$,
$$\#\{\omega \in \Omega: T\omega = t,\ S\omega = s\}\cdot \#\Omega \;=\; \#\{\omega: T\omega = t\}\cdot\#\{\omega : S\omega = s\}.$$

Dividing by $\#\Omega^{2}$, this says exactly that the empirical joint distribution of $(T,S)$ on the uniform measure over $\Omega$ is a product measure — i.e. mutual information exactly $0$, with no approximation.

**Lemma 5.5 (Constant statistics are uninformative).** If $T$ is constant on $\Omega$ then $\mathrm{ZeroInfo}(\Omega,T,S)$ for every $S$.

*Proof sketch.* For the constant value $t_0$, the $T$-fibre is all of $\Omega$ and the joint fibre is the $S$-fibre, so both sides equal $\#\{S = s\}\cdot\#\Omega$. For any other $t$ both fibres are empty. $\square$

**Lemma 5.6 (Data processing).** If $\mathrm{ZeroInfo}(\Omega,T,S)$ and $g$ is any function on the range of $T$, then $\mathrm{ZeroInfo}(\Omega, g\circ T, S)$.

*Proof sketch.* Partition each $(g\circ T)$-fibre into the $T$-fibres it contains, i.e. sum over $t \in g^{-1}(t')$ met by $\Omega$. Both sides of the defining identity are additive over this partition, so the identity for $g \circ T$ is the sum of the identities for the constituent $t$. $\square$

**Lemma 5.7 (Non-vacuity of the notion).** If $\omega_1 \ne \omega_2$ with $T\omega_1 \ne T\omega_2$ and $S\omega_1 \ne S\omega_2$, then $\mathrm{ZeroInfo}(\{\omega_1,\omega_2\},T,S)$ fails.

*Proof sketch.* Take $t = T\omega_1$, $s = S\omega_1$: the joint fibre, the $T$-fibre and the $S$-fibre are each the singleton $\{\omega_1\}$, so the identity would read $1\cdot 2 = 1\cdot 1$. $\square$

### 5.3 Starvation

**Definition 5.8.** For a modulus $\ell$, the secret statistic is $S_\ell(p,q,b) = (p+q) \bmod \ell$.

**Theorem 5.9 (Starvation of the truncated fingerprint).** Let $D, \ell \ge 1$ and let $\Omega$ be any finite set of instances $(p,q,b)$ such that for each member, $p$ and $q$ are distinct primes, $b \ge 1$, and
$$D \;<\; \min(d_p, d_q).$$
Then $\mathrm{ZeroInfo}\big(\Omega,\ \mathcal{W}_D,\ S_\ell\big)$.

*Proof sketch.* By Theorem 3.5, for each instance in $\Omega$ and each $1 \le c \le D$ we have $F(c) = 1$; hence $\mathcal{W}_D$ is the constant vector $(1,\dots,1)$ on $\Omega$. Apply Lemma 5.5. $\square$

**Theorem 5.10 (No post-processing helps).** Under the hypotheses of Theorem 5.9 and for any function $g$ on $\mathbb{N}^{D}$,
$$\mathrm{ZeroInfo}\big(\Omega,\ g\circ \mathcal{W}_D,\ S_\ell\big).$$
In particular no hash, projection, statistical estimator or learned predictor $\hat\sigma$ built from the window carries any information about $(p+q)\bmod \ell$.

*Proof sketch.* Lemma 5.6 applied to Theorem 5.9. $\square$

**Theorem 5.11 (Starvation of the Möbius window).** Under the same hypotheses, $\mathrm{ZeroInfo}(\Omega, \mathcal{M}_D, S_\ell)$.

*Proof sketch.* By Corollary 4.7, $\mathcal{M}_D$ is the constant vector $(1,0,\dots,0)$ on $\Omega$; apply Lemma 5.5. Post-processing invariance follows again from Lemma 5.6. $\square$

**Proposition 5.12 (Non-vacuity).** The hypothesis of Theorem 5.9 is satisfiable: for $(p,q,b) = (3,5,2)$ one has $d_3 = 2$ and $d_5 = 4$, so $\min = 2 > 1 = D$ is legitimate.

*Proof sketch.* $2^1 = 2 \not\equiv 1 \bmod 3$ and $2^{1} \not\equiv 1 \bmod 5$, so both orders are at least $2$. $\square$

**Proposition 5.13 (Sharpness at the order scale).** Zero information genuinely fails once the window reaches the order scale. On $\Omega = \{(3,5,2), (3,7,2)\}$ with $D = 4$ and $\ell = 3$: the order of $2$ modulo $7$ is $3$, so the first instance has window $(1,3,1,15)$ while the second has $(1,3,7,3)$; and $(3+5)\bmod 3 = 2$ while $(3+7) \bmod 3 = 1$. By Lemma 5.7, $\mathrm{ZeroInfo}$ fails. $\square$

**Interpretation.** The dichotomy is total. Below the order scale, the window and every function of it are constants of the instance: no separation, hence no information, hence no hint, hence no amplification. At the order scale, the window contains a proper factor of $N$ outright (Theorem 3.7). There is no intermediate regime in which the attacker accumulates a statistical edge. The amplification channel of Section 5.1 remains real, but no source for it is visible from this surface.

---

## 6. Burnside's mirror: the orbit count

We now consider a re-encoding of a completely different flavour. The base $b$ determines a unit $u \in (\mathbb{Z}/N)^{\times}$, and the cyclic group $\langle u \rangle$ acts on the set $\mathbb{Z}/N$ by multiplication. The number of orbits $C$ — the "homotopy cardinality" of the associated action groupoid — is a natural topological/categorical invariant. Is it easier to compute than the factorization?

**Theorem 6.1 (The fingerprint is a fixed-point count).** For $N = pq$ with $p\ne q$ prime and $b \ge 1$,
$$\#\{x \in \mathbb{Z}/N : b^{k}x = x\} \;=\; \gcd(b^{k}-1, N) \;=\; F(k).$$

*Proof sketch.* By the Chinese Remainder Theorem, $\mathbb{Z}/N \cong \mathbb{Z}/p \times \mathbb{Z}/q$ and the fixed-point condition splits coordinatewise. In a field, $cx = x$ has all of the field as solutions if $c=1$ and only $x=0$ otherwise; hence the count is $p^{[b^{k}\equiv 1 \bmod p]}q^{[b^{k}\equiv 1 \bmod q]}$, which is $F(k)$ by Theorem 3.3 and Lemma 3.1. $\square$

**Lemma 6.2 (Order modulo a semiprime).** $\mathrm{ord}_N(b) = \mathrm{lcm}(d_p,d_q) = n$.

*Proof sketch.* The CRT isomorphism is a ring isomorphism, hence preserves multiplicative orders; the order of a pair in a product group is the lcm of the coordinate orders. $\square$

**Lemma 6.3 (Counting multiples).** If $d \mid n$ and $d > 0$, the number of $k \in \{0,\dots,n-1\}$ with $d \mid k$ is $n/d$. $\square$

**Theorem 6.4 (Period sum of the fingerprint).** For $p,q \ge 1$ and $d_p, d_q > 0$ with $n = \mathrm{lcm}(d_p,d_q)$,
$$\sum_{k=0}^{n-1} p^{[d_p \mid k]} q^{[d_q\mid k]} \;=\; n + (p-1)\frac{n}{d_p} + (q-1)\frac{n}{d_q} + (p-1)(q-1).$$

*Proof sketch.* Use the same inclusion–exclusion expansion as in Theorem 4.6, $p^{[d_p|k]}q^{[d_q|k]} = 1 + (p-1)[d_p|k] + (q-1)[d_q|k] + (p-1)(q-1)[n|k]$, and sum each term over a full period using Lemma 6.3; the last term contributes $n/n = 1$ multiple. $\square$

**Theorem 6.5 (Orbit-count identity).** Let $N = pq$, $b$ coprime to $N$, $u$ the corresponding unit, and $C$ the number of orbits of $\langle u\rangle$ on $\mathbb{Z}/N$. Then
$$C\cdot n \;=\; n + (p-1)\frac{n}{d_p} + (q-1)\frac{n}{d_q} + (p-1)(q-1),$$
equivalently, dividing by $n$,
$$C \;=\; 1 + \frac{p-1}{d_p} + \frac{q-1}{d_q} + \frac{\varphi(N)}{n}.$$

*Proof sketch.* Burnside's lemma states $C \cdot \#\langle u \rangle = \sum_{g \in \langle u\rangle} \#\mathrm{Fix}(g)$. The group $\langle u \rangle$ has order $n$ by Lemma 6.2 and its elements are $u^{k}$, $0 \le k < n$; by Theorem 6.1 the $k$-th fixed-point count is $F(k)$. Evaluate the resulting period sum by Theorem 6.4. $\square$

This is a genuine and pretty identity. It is also, as an attack, closed — in two complementary ways.

**Theorem 6.6 (Balanced case: no leak).** If $d_p = d_q = d$, then
$$C\cdot d \;=\; d + N - 1.$$
Hence $C$ is a function of $N$ and $\mathrm{ord}_N(b) = d$ alone, and is therefore independent of how $N$ splits.

*Proof sketch.* With $d_p=d_q=d$ we have $n = d$, $n/d_p = n/d_q = 1$, so Theorem 6.5 reads $Cd = d + (p-1)+(q-1)+(p-1)(q-1) = d + pq - 1$. $\square$

**Theorem 6.7 (Affine-hint dichotomy).** In general, substituting $(p-1)(q-1) = N-p-q+1$ into Theorem 6.5 and rearranging gives the affine observation
$$\left(\frac{n}{d_p}-1\right)p + \left(\frac{n}{d_q}-1\right)q \;=\; Cn - n + \frac{n}{d_p} + \frac{n}{d_q} - N - 1 .$$
By Theorem 5.2, knowledge of the right-hand side together with $N$ pins the factorization to at most two candidates, *unless* both coefficients vanish — which happens exactly when $n/d_p = n/d_q = 1$, i.e. in the balanced case $d_p = d_q$ of Theorem 6.6.

*Proof sketch.* The rearrangement is elementary algebra over $\mathbb{Z}$ from the identity of Theorem 6.5. The conclusion is Theorem 5.2 with $A = n/d_p - 1$, $B = n/d_q - 1$; Corollary 5.3 handles the case where exactly one coefficient vanishes. $\square$

**Interpretation (the topological seal).** The orbit count $C$ is either (i) unbalanced, in which case knowing it is essentially knowing the factorization — so it cannot be computable from $N$ alone unless factoring is easy; or (ii) balanced, in which case it is a function of $(N, \mathrm{ord}_N b)$ and carries no information about the splitting at all. Moreover, by Theorem 6.1, $C$ is a $\mathbb{Z}$-linear functional of the fingerprint sequence over one period. Burnside's lemma re-sums exactly the data that Sections 3–5 showed to be sealed at the order scale. Topological and categorical re-encodings of the problem produce new *descriptions*, not new *computation*.

---

## 7. Pricing constant-factor improvements

A different genre of attempted improvement is algorithmic policy tuning. For rho-type methods one may schedule early aborts using the Dickman function $\rho$, which governs the density $\Psi(x, x^{1/u})/x \to \rho(u)$ of $x^{1/u}$-smooth integers up to $x$. Empirically such a policy yields a mean speedup factor of roughly $1.95$ over the unmodified method. The following lemma prices that.

**Theorem 7.1 (Exponent invariance).** Let $T, T' : \mathbb{N}\to\mathbb{R}$ and $C \ge 1$ satisfy $T'(n) > 1$ for all $n$, $T'(n) \le T(n) \le C\,T'(n)$, and $T'(n)\to\infty$. Then
$$\frac{\log T(n)}{\log T'(n)} \;\longrightarrow\; 1 .$$

*Proof sketch.* Since $\log T' > 0$ and $\log T \ge \log T'$, the ratio is $\ge 1$. Since $\log T \le \log C + \log T'$, the ratio is $\le 1 + \log C/\log T'(n)$, and $\log T'(n)\to\infty$, so the upper bound tends to $1$. Squeeze. $\square$

**Corollary 7.2 (No asymptotic gain).** A uniform speedup $T = C\,T'$ — in particular the measured $C \approx 1.95$ — leaves the running-time exponent equal to $1$: it is asymptotically free. $\square$

**Theorem 7.3 (Sharpness).** If instead $T = (T')^{\theta}$ with $T' > 1$, then $\log T/\log T' \to \theta$.

*Proof sketch.* The ratio is identically $\theta$ once $\log$ of a real power is expanded. $\square$

So the pricing is a real dichotomy rather than an artefact of the formulation: constant factors never move the exponent, while power-strength improvements always do. A $1.95\times$ speedup against a subexponential baseline is worth roughly one extra bit of modulus, and belongs to the early-abort folklore of the quadratic sieve family rather than to the theory of asymptotic improvements.

---

## 8. Algorithms

We record the procedures implicit in the results above, together with their complexity. Throughout, $\mathsf{M}(\log N)$ denotes the cost of one modular multiplication.

### 8.1 Fingerprint evaluation

**Input:** $N$, $b$, $c$. **Output:** $F(c) = \gcd(b^{c}-1, N)$.
Compute $r = b^{c} \bmod N$ by square-and-multiply, then $\gcd(r-1 \bmod N, N)$ by the Euclidean algorithm.
**Complexity:** $O(\log c)$ multiplications plus one gcd, i.e. $\tilde{O}(\log c \cdot \log N)$ bit operations. Notably, evaluating $F$ at a *single large* index is cheap; what is expensive is *reaching* an index at the order scale, since the informative indices are $\Theta(\sqrt N)$ apart in the worst case and there are $\Theta(\sqrt N)$ of them to try.

### 8.2 Raw Möbius coefficient

**Input:** $N$, $b$, $d$. **Output:** $M_d$.
Enumerate the divisors $c$ of $d$, evaluate $F(c)$ for each, and accumulate $\mu(d/c)F(c)$.
**Complexity:** $\tau(d)$ fingerprint evaluations, where $\tau(d)$ is the divisor count, plus factoring $d$ (which is cheap: $d$ is a *search index*, not a cryptographic modulus). By Corollary 4.7 the output is $[\,d=1\,]$ for all $d < d^{*}$; the algorithm is therefore an *order detector* and nothing else.

### 8.3 Window scan and the order-scale certificate

**Input:** $N$, $b$, budget $D$. **Output:** either a nontrivial factor of $N$, or the certificate "$\min(d_p,d_q) > D$".
Scan $c = 1, \dots, D$ computing $F(c)$ incrementally (one multiplication per step, since $b^{c+1} = b\cdot b^{c}$); return the first $F(c) \notin \{1, N\}$. If none occurs, return the certificate.
**Complexity:** $D$ multiplications and $D$ gcds (batchable into $O(D/k)$ gcds by accumulating products of $k$ consecutive values of $b^{c}-1$ modulo $N$ — this is exactly the standard gcd-batching layer of rho). Correctness of the certificate is Theorem 3.5 together with Theorem 3.8: a failed scan *proves* $\min(d_p,d_q) > D$.

### 8.4 Orbit count from the factorization

**Input:** $p$, $q$, $b$. **Output:** $C$.
Compute $d_p$, $d_q$ (by factoring $p-1$, $q-1$ and testing divisors), $n = \mathrm{lcm}(d_p,d_q)$, and return $1 + (p-1)/d_p + (q-1)/d_q + (p-1)(q-1)/n$.
**Complexity:** dominated by the order computations. Note the input: this algorithm *needs the factorization*, which is precisely the content of Theorem 6.7.

---

## 9. Applications and consequences

**9.1 A certificate for order lower bounds.** Section 8.3 gives a cheap, verifiable certificate: if the fingerprint window of length $D$ is all ones, then both local orders exceed $D$. This is a genuinely useful positive by-product — it can be used, for example, in parameter validation to confirm that a chosen base has no small local order, without knowing the factorization.

**9.2 Design guidance.** The four-atom spectrum makes precise which instances are weak: those where an atom sits at a small index, i.e. where some $d_p$ is small, i.e. where $p-1$ has only small prime factors. This recovers, from the spectral side, the classical recommendation to use *safe* primes ($p = 2p'+1$ with $p'$ prime), which forces $d_p \in \{1,2,p',2p'\}$ and so puts every atom at the order scale for all but two bases.

**9.3 A template for barrier arguments.** The proof pattern of Section 5 — show that an attacker's observable is *literally constant* on the relevant instance family, then invoke a data-processing lemma — is reusable and much stronger than a statistical estimate. Any proposed statistic on the fingerprint window inherits the closure automatically, with no new analysis required. It also clarifies what a successful attack must do: it must produce an observable that is *not* a function of the sub-order-scale window.

**9.4 Delimiting the quantum exception.** All of the above are statements about classical access to the fingerprint. A quantum period-finding subroutine determines $n = \mathrm{ord}_N(b)$ directly, and by Theorem 3.7 knowledge of the order scale is knowledge of a factor. The results here therefore locate exactly where the quantum advantage lives: not in extracting more from the sub-order-scale data — there is nothing there — but in reaching the order scale itself.

---

## 10. Discussion

The unifying theme is that four apparently independent approaches collapse onto the same invariant.

- The **arithmetic** approach reads the fingerprint directly, and finds a two-tone square wave with a single feature at $d^{*}$.
- The **spectral** approach Möbius-inverts, and finds four Dirac masses with cryptographically precious weights parked at $d_p$, $d_q$, $n$.
- The **information-theoretic** approach measures the window's correlation with $p+q$, and finds exact zero, stable under all post-processing.
- The **topological** approach counts orbits, and finds a Burnside average of the same fingerprint, with an affine-hint dichotomy that is a factoring oracle exactly when it is not computable.

The reason for the collapse is visible in Theorem 3.3 together with Theorem 6.1: everything here is a linear functional of the indicator pair $\big([d_p\mid c],[d_q\mid c]\big)$. Any transform that is linear in the fingerprint values — Möbius inversion, Burnside averaging, Dirichlet convolution with any kernel, discrete Fourier analysis over a period — can only redistribute mass among the atoms; it cannot create an atom below $\min(d_p,d_q)$, because the underlying sequence is constant there. That is a structural obstruction, not a computational one.

**Limitations.** Three honest caveats. First, the zero-information results are stated for instance families in which *both* orders exceed the window; families containing small-order instances are exactly the ones classical methods already exploit, and there the results correctly fail (Proposition 5.13). Second, the counting notion of independence is exact but *finitary*: it says nothing about asymptotic families with non-uniform distributions beyond what the constancy argument gives — although constancy is so strong that the extension is routine. Third, the analysis concerns *uniform, hint-free* access to this particular observable; it does not, and cannot, address attacks that use side information, non-uniform advice, or algebraic structure outside the fingerprint (sieve-based methods, for instance, live in a different world entirely and are unaffected by any of this).

**What remains open.** Two things, sharply delimited. The amplification channel of Section 5.1 is real and unpriced: a source of even $N^{1/4}$-accurate information about $p+q$ would be decisive, and nothing here rules out such a source arising from an observable *not* built from the fingerprint window. And the general lower-bound question — whether *every* $N$-computable observable is sealed at the order scale — remains a conjecture; the results here establish it for the concrete and rich family described above.

---

## 11. Future directions

**C1 (Spectral rigidity: the atom count as a structure oracle).** Theorem 4.6 is really a statement about the inclusion–exclusion expansion of $F(c) = \prod_{p \mid N} p^{[\mathrm{ord}_p b \mid c]}$; nothing in the argument is special to two primes. This suggests: for $N$ with $k$ distinct prime factors and generic $b$, the raw spectrum should have exactly $2^{k}$ atoms, indexed by subsets $S$ of the prime divisors, with mass $\prod_{p\in S}(p-1)$ located at $\mathrm{lcm}_{p\in S}\,\mathrm{ord}_p b$. Consequently the raw spectrum has at most four nonzero coefficients for *every* base if and only if $N$ is a prime power or a semiprime. The conjecture has an immediately checkable consequence: an $N$-computable *count of spectral atoms* would be a primality-structure oracle. The general case requires only a multiplicative version of the Möbius detection lemma.

**C2 (The order-scale barrier as an information dichotomy).** Conjecture: for every $D$ and every finite instance family on which $d^{*} > D$, *any* statistic computable from $(N, b, F(1),\dots,F(D))$ has zero information about $(p+q)\bmod \ell$; and conversely, for every family on which $d^{*} \le D$ there exists $\ell$ and a statistic with strictly positive information. Theorems 5.9 and 5.10 give the first half for the fingerprint window itself, and Proposition 5.13 witnesses the second half. The missing step is to close the "any statistic" quantifier by proving that the window is a *sufficient statistic* for $(N,b)$ below the order scale. The counting notion of independence used here is finitary and composes under post-processing, so the general statement should reduce to a lemma about fibres of an explicitly constant map, with no probability theory required.

**C3 (Burnside seal, general form).** Conjecture: for any finite abelian group $G$ and any $g \in G$ acting on a $G$-set built functorially from $\mathbb{Z}/N$, the orbit count is a $\mathbb{Z}$-linear functional of the fixed-point sequence $k \mapsto \#\mathrm{Fix}(g^{k})$, and every such functional is computable from $(N, \mathrm{ord}_N b)$ alone precisely when the local orders coincide. Theorem 6.1 (the fixed-point identification) and Theorem 6.6 (the balanced no-leak case) are the two-prime instance of this statement; the general form would seal the entire topological/categorical school in one stroke.

**C4 (Beyond linear functionals).** All transforms considered here are linear in the fingerprint values. A nonlinear functional — for instance a ratio, or a spectral statistic of the associated dynamical system — is not covered by the structural obstruction of Section 10, although constancy below $d^{*}$ still applies to any *function* of the window. The interesting question is whether an observable exists that is cheap to compute from $N$ but is *not* a function of any sub-order-scale window: such an observable would fall outside every result proved here.

**C5 (Certified order lower bounds at scale).** Section 8.3 turns a failed window scan into a proof that $\min(d_p,d_q) > D$. Batching makes this cheap. It would be worthwhile to develop this into a practical certification protocol for base selection, with explicit constants, and to determine the largest $D$ for which certification is economical relative to the sieve-based alternative.

---

## 12. Conclusion

The cycle-index fingerprint of a semiprime is a rich, freely computable object with a genuinely interesting spectral theory: its Möbius transform is a sum of four Dirac masses whose weights are $1$, $p-1$, $q-1$ and $\varphi(N)$, and its Burnside average is the orbit count of the natural cyclic action on $\mathbb{Z}/N$. Both structures are real mathematics. Neither relocates any information. Below the order scale $d^{*} = \min(\mathrm{ord}_p b, \mathrm{ord}_q b)$, the fingerprint, its spectrum, and every function of either are literally constant across all instances; at the order scale the fingerprint hands over a factor of $N$. The classical, uniform, hint-free surface around this observable is closed — exactly, and with the location of the seal identified: it sits at the order scale, which is the square-root wall in disguise.
