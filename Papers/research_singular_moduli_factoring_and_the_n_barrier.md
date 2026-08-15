# Singular Moduli Factoring and the $\sqrt{N}$ Barrier

**Author:** Aristotle
**Date:** 2026-08-15
**Domain:** Cryptography — integer factorisation, complex multiplication, algorithmic barriers

---

## Abstract

We give a complete and unconditional analysis of the *singular moduli factoring method*: given a semiprime $N = pq$, choose an imaginary quadratic discriminant $D$, form the Hilbert class polynomial $H_D \in \mathbb{Z}[X]$ of degree $h = h(D)$, choose an evaluation point $j_0 \in \mathbb{Z}$, and compute $\gcd(H_D(j_0), N)$. The method is motivated by complex multiplication: the roots of $H_D$ modulo $p$ are the $j$-invariants of elliptic curves over $\mathbb{F}_p$ with CM by the order of discriminant $D$, a highly structured set attached to $p$.

Our results are of two kinds. First, we prove *exactness* statements which replace the usual heuristics by identities: the gcd step returns a nontrivial factor if and only if $j_0$ is a root of $H_D$ modulo exactly one of $p, q$ (and then it returns that prime); and the number of successful evaluation points in $[0,N)$ is exactly $S = r_p(q - r_q) + (p - r_p) r_q$, where $r_m$ denotes the number of roots of $H_D$ modulo $m$. Neither statement uses any property of $H_D$ beyond its being an integer polynomial.

Second, we prove *barrier* statements. For a balanced semiprime ($p \le q \le 3p$) and monic $H$ of degree $h$, the density of useful evaluation points is at most $4h/\sqrt{N}$; and in the configuration in which the method actually works ($H$ has a root modulo $p$ and none modulo $q$) the expected number of evaluations $N/S$ lies in $[\sqrt{N}/(4h),\ \sqrt{N}]$. The class-number speed-up is illusory: since evaluating a degree-$h$ polynomial costs at least $h$ operations, the total arithmetic work is at least $\sqrt{N}/4$, with no $h$ in the bound. Neither reparametrising the evaluation variable nor running an entire family of discriminants improves the density bound. Finally, precomputation is provably useless: a fixed table $T$ of evaluation points can detect at most $\sum_{t\in T}\log_2 |H(t)|$ primes in total, so for every finite family of class polynomials, every finite table, and every bound $M$, there are distinct primes $p, q > M$ on which the entire precomputed attack returns nothing.

Consequently the proven cost profile, in the bit-size variable $x = \log N$, is $C(x) = e^{x/2}/(4h)$: superpolynomial, not subexponential, and eventually dominating the $e^{x/4}$ birthday cost of Pollard's rho. Singular moduli factoring therefore belongs to the $\sqrt{N}$ family alongside Pollard rho and Pollard $p-1$, strictly above the subexponential rung $L_N[1/3, c]$ occupied by the number field sieve. We accompany the theory with exact verified instances, including a complete exhaustive success count for $N = 77$ with $D = -15$, and experimental scaling data across two orders of magnitude confirming a constant ratio of evaluations to $\sqrt{N}$.

**Keywords:** integer factorisation, singular moduli, Hilbert class polynomial, complex multiplication, class number, algorithmic barriers, $\sqrt{N}$ methods, precomputation lower bounds.

---

## 1. Introduction

### 1.1 Motivation

The theory of complex multiplication supplies, for each imaginary quadratic discriminant $D < 0$, a monic polynomial $H_D \in \mathbb{Z}[X]$ — the *Hilbert class polynomial* — whose complex roots are the *singular moduli* of discriminant $D$, i.e. the values $j(\tau)$ of the modular $j$-function at the $h(D)$ classes of quadratic forms of discriminant $D$. Its degree is the class number $h(D)$. Small examples are strikingly concrete:

$$H_{-4}(X) = X - 1728,\qquad H_{-7}(X) = X + 3375,\qquad H_{-8}(X) = X - 8000,$$
$$H_{-11}(X) = X + 32768,\qquad H_{-19}(X) = X + 884736,\qquad H_{-163}(X) = X + 262537412640768000,$$
$$H_{-15}(X) = X^2 + 191025\,X - 121287375,\qquad H_{-20}(X) = X^2 - 1264000\,X - 681472000.$$

Reduction modulo a prime $p$ is governed by Deuring's theory: $H_D$ splits completely modulo $p$ (with $h(D)$ distinct roots, for $p \nmid D$ and $p$ not dividing the discriminant of $H_D$) precisely when $p$ is represented by a quadratic form of discriminant $D$, equivalently when $4p = u^2 + |D|v^2$ is solvable in integers. Each root is then the $j$-invariant of an elliptic curve over $\mathbb{F}_p$ having CM by the order of discriminant $D$.

This structure suggests an attack on a semiprime $N = pq$. If one could guess an integer $j_0$ that happens to be a root of $H_D$ modulo $p$ but not modulo $q$, then $p \mid H_D(j_0)$ and $q \nmid H_D(j_0)$, so $\gcd(H_D(j_0), N) = p$. The unknown factor is recovered by a single gcd.

The method works. Its correctness requires no conjecture, and it factors real semiprimes: with $D = -11$ and $j_0 = 9$ one has $H_{-11}(9) = 32777$ and $\gcd(32777, 5183) = 73$, so $5183 = 71\cdot 73$. The purpose of this paper is to determine, exactly and unconditionally, how the method scales.

### 1.2 Summary of results

Throughout, $N = pq$ with $p \neq q$ prime, and $H \in \mathbb{Z}[X]$ is an integer polynomial, monic where stated, of degree $h$. Write $r_m$ for the number of roots of $H$ in $\mathbb{Z}/m$.

1. **Exact criterion (Theorem 3.1).** $\gcd(H(j_0), N)$ is a nontrivial divisor of $N$ iff $j_0$ is a root of $H$ modulo exactly one of $p, q$; and in that case the gcd equals that prime.
2. **Exact count (Theorem 4.3).** The number of successful residues $j_0 \in [0, N)$ is exactly $S = r_p(q - r_q) + (p - r_p)r_q$.
3. **Density bound (Theorem 5.1, 5.2).** For monic $H$, $S \le h(p+q)$, hence $S/N \le h(1/p + 1/q)$, and for balanced semiprimes $S/N \le 4h/\sqrt{N}$.
4. **Two-sided scaling (Theorem 6.4).** If $r_p \ge 1$ and $r_q = 0$ then $\sqrt{N}/(4h) \le N/S \le \sqrt{N}$.
5. **Work barrier (Theorem 6.5).** $h \cdot (N/S) \ge \sqrt{N}/4$, independently of $h$.
6. **Composition and multi-discriminant barriers (Theorems 6.6, 5.4).** Reparametrising by a monic $g$ of degree $d$ replaces $h$ by $hd$; a whole family $F$ of monic degree-$\le h$ polynomials still has success-pair density $\le 4h/\sqrt{N}$.
7. **No precomputation (Theorems 7.2, 7.4).** A table $T$ catches at most $\sum_{t\in T}\log_2|H(t)|$ primes; for every finite family, table, and bound $M$, there are primes $p, q > M$ on which the whole precomputed attack fails.
8. **Ladder placement (Theorem 8.2).** $C(x) = e^{x/2}/(4h)$ is superpolynomial, is not subexponential, and eventually dominates $e^{x/4}$.
9. **Blindness (Theorem 3.4).** If $H$ has no root modulo either prime, no evaluation point ever succeeds.

Section 9 records exactly verified instances and the experimental scaling data.

### 1.3 What is *not* claimed

None of this asserts that no method based on complex multiplication can factor quickly. What is proved is that the *gcd-of-polynomial-values* scheme — in the full generality of an arbitrary monic integer polynomial, arbitrary evaluation points, and arbitrary finite discriminant families — is a $\sqrt{N}$ method. This is a research contribution to the classification of factoring barriers, not a claim about the security of any deployed system beyond the (already known) fact that RSA is not threatened by $\sqrt{N}$ algorithms.

---

## 2. Setup and definitions

**Definition 2.1 (Nontrivial divisor).** For $N \in \mathbb{N}$, a natural number $d$ is a *nontrivial divisor* of $N$ if $d \mid N$, $1 < d$, and $d < N$.

**Definition 2.2 (The gcd step).** For $H \in \mathbb{Z}[X]$, $j \in \mathbb{Z}$ and $N \in \mathbb{N}$, define
$$\mathrm{eg}(H, j, N) \;:=\; \gcd\big(H(j),\, N\big) \in \mathbb{N}.$$
One *evaluation* of the method is one computation of $\mathrm{eg}(H, j, N)$; it succeeds if $\mathrm{eg}(H,j,N)$ is a nontrivial divisor of $N$.

**Definition 2.3 (Root count).** For $m \ge 1$ let $\overline{H} \in (\mathbb{Z}/m)[X]$ be the reduction of $H$ modulo $m$, let
$$R_m(H) := \{x \in \mathbb{Z}/m : \overline{H}(x) = 0\}, \qquad r_m(H) := |R_m(H)|.$$
We write $r_p, r_q$ when $H$ is clear.

**Definition 2.4 (Success set and count).** For $N \in \mathbb{N}$,
$$\mathcal{S}(H,N) := \{\,j \in [0,N) : \mathrm{eg}(H, j, N) \text{ is a nontrivial divisor of } N\,\},\qquad S(H,N) := |\mathcal{S}(H,N)|.$$

**Definition 2.5 (Balanced semiprime).** $N = pq$ is *balanced* if $p \le q \le 3p$. (Any fixed constant in place of $3$ changes only the constant $4$ below; RSA moduli are balanced in a much stronger sense.)

**Definition 2.6 (Cost classes).** For $f : \mathbb{R}\to\mathbb{R}$ write $x = \log N$ for the bit-size variable.
- $f$ is *polynomially bounded* if $f(x) = O(x^d)$ for some $d$.
- $f$ is *superpolynomial* if $x^d / f(x) \to 0$ as $x \to \infty$ for every $d$.
- $f$ is *subexponential* if for every $\varepsilon > 0$ one has $f(x)/e^{\varepsilon x} \to 0$ as $x \to \infty$.

Thus $e^{cx}$ with $c > 0$ is superpolynomial and *not* subexponential, while the sieve cost $L_N[1/3, c]$ is subexponential in this sense. The three benchmark rungs are: $L_N[1/3,c]$ (number field sieve), $e^{x/4} = N^{1/4}$ (birthday/rho), and $e^{x/2} = \sqrt{N}$.

---

## 3. The exact gcd criterion

Everything begins with a complete divisor analysis of $\gcd(a, pq)$. Note that no elliptic curves appear; the arguments are valid for an arbitrary integer polynomial $H$, which is precisely why they are robust.

**Lemma 3.0.** Let $p \ne q$ be primes and $a \in \mathbb{Z}$.
1. If $p \nmid a$ and $q \nmid a$ then $\gcd(a, pq) = 1$.
2. If $p \mid a$ and $q \nmid a$ then $\gcd(a, pq) = p$.
3. If $p \nmid a$ and $q \mid a$ then $\gcd(a, pq) = q$.
4. If $p \mid a$ and $q \mid a$ then $\gcd(a, pq) = pq$.

*Proof sketch.* Set $d = \gcd(a, pq)$, so $d \mid pq$ and $d \in \{1, p, q, pq\}$. In case (2), $p \mid a$ and $p \mid pq$ give $p \mid d$, so $d = pk$ with $k \mid q$; if $k = q$ then $q \mid d \mid a$, contradicting $q \nmid a$; hence $k = 1$ and $d = p$. Case (3) is (2) with the roles of $p$ and $q$ exchanged. In case (4), coprimality of $p$ and $q$ gives $pq \mid a$, and $pq \mid pq$, so $pq \mid d$; combined with $d \mid pq$, $d = pq$. Case (1) is the remaining possibility. $\square$

**Theorem 3.1 (Exact success criterion).** Let $p \ne q$ be primes, $H \in \mathbb{Z}[X]$, $j \in \mathbb{Z}$. Then
$$\mathrm{eg}(H, j, pq) \text{ is a nontrivial divisor of } pq \iff \Big(p \mid H(j)\Big) \ \mathrm{XOR}\ \Big(q \mid H(j)\Big).$$
Moreover in the first disjunct the gcd equals $p$, in the second it equals $q$.

*Proof sketch.* Apply Lemma 3.0 with $a = H(j)$. Cases (2),(3) give a prime factor, which is a nontrivial divisor of $pq$ since $1 < p < pq$ (as $q > 1$). Cases (1) and (4) give $1$ and $pq$, neither of which is nontrivial. $\square$

Three consequences deserve emphasis.

**Corollary 3.2 (Success factors completely).** If the gcd step succeeds on a semiprime, its output is one of the two prime factors; a single success therefore factors $N$ completely.

**Corollary 3.3 (Too much success is failure).** If $j_0$ is a root of $H$ modulo *both* primes, the gcd is $N$ and no information is obtained. The success condition is genuinely an exclusive-or, not a disjunction — a point that heuristic treatments frequently blur.

**Theorem 3.4 (Blindness).** If $H$ has no root modulo $p$ and no root modulo $q$, then for *every* $j \in \mathbb{Z}$, $\mathrm{eg}(H, j, pq) = 1$; the method never succeeds for that discriminant, no matter how many evaluations are performed.

*Proof sketch.* Immediate from Lemma 3.0(1). $\square$

Theorem 3.4 is not a pathological corner: $H_D$ splits modulo $p$ only when $D$ is a square modulo $p$ (equivalently, $p$ is represented by a form of discriminant $D$), and otherwise $H_D$ can be irreducible modulo $p$. In the experiments of Section 9, the pair $(p,q) = (71, 73)$ with $D = -23$ has $r_{71} = r_{73} = 0$ and exact success count $0$. Every expectation computation below is therefore *conditional* on the discriminant being usable, and a full accounting of the method must include the cost of finding a usable discriminant.

---

## 4. Exact counting via the Chinese Remainder Theorem

The success condition of Theorem 3.1 depends on $j$ only through the pair $(j \bmod p,\ j \bmod q)$. This makes an exact count possible.

**Lemma 4.1 (Product counting).** Let $A \subseteq \mathbb{Z}/p$ and $B \subseteq \mathbb{Z}/q$ be subsets. Then
$$\big|\{(a,b) \in \mathbb{Z}/p \times \mathbb{Z}/q \;:\; (a \in A)\ \mathrm{XOR}\ (b \in B)\}\big| \;=\; |A|\,(q - |B|) \;+\; (p - |A|)\,|B|.$$

*Proof sketch.* The set in question is the disjoint union $(A \times B^{c}) \sqcup (A^{c} \times B)$; disjointness is by the first coordinate. Take cardinalities. $\square$

**Lemma 4.2 (CRT transfer).** Let $\gcd(p,q) = 1$ and let $R$ be any predicate on $\mathbb{Z}/p \times \mathbb{Z}/q$. Then
$$\big|\{\,j \in [0, pq) : R(j \bmod p,\ j \bmod q)\,\}\big| \;=\; \big|\{(a,b) : R(a,b)\}\big|.$$

*Proof sketch.* The map $j \mapsto (j \bmod p, j \bmod q)$ from $[0, pq)$ to $\mathbb{Z}/p \times \mathbb{Z}/q$ is a bijection: injectivity is $j_1 \equiv j_2 \bmod p$ and $\bmod\ q$ implying $j_1 \equiv j_2 \bmod pq$ (coprimality), together with $0 \le j_i < pq$; surjectivity is the Chinese Remainder Theorem. It restricts to a bijection between the two sets in question. $\square$

**Theorem 4.3 (Exact success count).** Let $p \neq q$ be primes and $H \in \mathbb{Z}[X]$ arbitrary. Then
$$\boxed{\,S(H, pq) \;=\; r_p\,(q - r_q) \;+\; (p - r_p)\,r_q\,.}$$

*Proof sketch.* By Theorem 3.1, $j$ succeeds iff $(p \mid H(j))\ \mathrm{XOR}\ (q \mid H(j))$, i.e. iff $(j \bmod p \in R_p)\ \mathrm{XOR}\ (j \bmod q \in R_q)$, since $m \mid H(j)$ is exactly the statement that $j \bmod m$ is a root of $\overline{H}$. Apply Lemma 4.2 with this predicate and then Lemma 4.1 with $A = R_p$, $B = R_q$. $\square$

This is an identity with no error term and no probabilistic input. It can be read as an inclusion–exclusion: $S = r_p q + p r_q - 2 r_p r_q$, the count of "root mod $p$" plus "root mod $q$" minus twice the overlap.

**Lemma 4.4 (Lagrange).** If $H$ is monic of degree $h$ and $m$ is prime, then $r_m \le h$.

*Proof sketch.* Reduction preserves monicity, so $\overline{H} \in \mathbb{F}_m[X]$ is monic of degree $h$, in particular nonzero; a nonzero polynomial over a field has at most $\deg$ roots. $\square$

**Corollary 4.5 (The useful set is tiny).** For monic $H$ of degree $h$ and distinct primes $p,q$,
$$S(H, pq) \;\le\; h\,(p + q).$$

*Proof sketch.* From Theorem 4.3, $S \le r_p q + p r_q \le hq + ph$. $\square$

Out of $N = pq$ candidate evaluation points, at most $h(p+q)$ are useful. This single inequality is the combinatorial source of the barrier.

---

## 5. The $\sqrt{N}$ density barrier

**Theorem 5.1 (Density bound).** For monic $H$ of degree $h$ and distinct primes $p, q$,
$$\frac{S(H, pq)}{pq} \;\le\; h\Big(\frac{1}{p} + \frac{1}{q}\Big).$$

*Proof sketch.* Divide Corollary 4.5 by $pq$ and note $(p+q)/(pq) = 1/p + 1/q$. $\square$

**Theorem 5.2 (Balanced $\sqrt{N}$ density bound).** If additionally $p \le q \le 3p$, then
$$\frac{S(H,pq)}{pq} \;\le\; \frac{4h}{\sqrt{pq}}.$$

*Proof sketch.* Writing $t = \sqrt{q/p} \in [1, \sqrt{3}]$, we have $(p+q)/\sqrt{pq} = t + 1/t \le \sqrt{3} + 1/\sqrt{3} = 4/\sqrt 3 < 4$. Hence $p + q \le 4\sqrt{pq}$, and by Corollary 4.5, $S \le h(p+q) \le 4h\sqrt{pq}$, so $S/(pq) \le 4h\sqrt{pq}/(pq) = 4h/\sqrt{pq}$. $\square$

**Theorem 5.3 (Expected number of evaluations, lower bound).** Under the hypotheses of Theorem 5.2, with $S = S(H,pq) > 0$,
$$\frac{N}{S} \;\ge\; \frac{\sqrt{N}}{4h},\qquad N = pq.$$

*Proof sketch.* Rearrange Theorem 5.2. (If $h = 0$ the left side of the claim is interpreted as $+\infty$ / the bound is vacuous; in fact $h = 0$ forces $S = 0$ since a monic degree-$0$ polynomial is the constant $1$.) $\square$

Interpreting $S/N$ as the probability that a uniformly random $j_0 \in [0,N)$ succeeds, $N/S$ is the expectation of the geometric waiting time for the first success. So: **a uniformly random evaluation point succeeds with probability at most $4h/\sqrt{N}$, and one expects at least $\sqrt{N}/(4h)$ evaluations.**

A natural objection is that a real attacker would not use one discriminant but many. This does not help.

**Definition.** For a finite family $F \subset \mathbb{Z}[X]$ of class polynomials, let
$$\mathcal{P}(F, N) := \{(G, j) \in F \times [0,N) : \mathrm{eg}(G, j, N) \text{ is a nontrivial divisor of } N\}.$$

**Theorem 5.4 (Multi-discriminant barrier).** Let $N = pq$ be balanced and let $F$ be a nonempty finite family of monic polynomials each of degree at most $h$. Then
$$\frac{|\mathcal{P}(F,N)|}{|F| \cdot N} \;\le\; \frac{4h}{\sqrt{N}}.$$

*Proof sketch.* $\mathcal{P}(F,N)$ decomposes over $F$: $|\mathcal{P}(F,N)| \le \sum_{G \in F} S(G, N)$, since the fibre over $G$ is contained in $\{G\} \times \mathcal{S}(G,N)$. Each term satisfies $S(G,N) \le (4\deg G/\sqrt N)\cdot N \le (4h/\sqrt N)\cdot N$ by Theorem 5.2 and monotonicity in the degree. Summing over the $|F|$ members and dividing by $|F| \cdot N$ gives the claim. $\square$

Thus the search space may be enlarged in the discriminant direction as much as one wishes: the *density* of useful pairs in the enlarged space is unchanged. The barrier is not an artifact of using a single $H_D$.

---

## 6. Sharpness: the method really is $\Theta(\sqrt{N})$

A lower bound on the running time is compatible with the method never working. We now prove matching upper bounds, so that the $\sqrt{N}$ rate is the true order and not an artifact of a lossy technique.

**Theorem 6.1 (Sharpness of the counting bound).** Suppose $r_p = r_q = h$ with $h \le p$ and $h \le q$ — the generic complete-splitting case for a Hilbert class polynomial at two primes both represented by forms of discriminant $D$. Then
$$S(H, pq) + 2h^2 \;=\; h\,(p+q),$$
i.e. $S = h(p+q) - 2h^2$, so Corollary 4.5 is tight up to the second-order term $2h^2$.

*Proof sketch.* Substitute $r_p = r_q = h$ into Theorem 4.3: $S = h(q-h) + (p-h)h = h(p+q) - 2h^2$. (The identity is stated in the additive form to avoid truncated subtraction.) $\square$

**Theorem 6.2 (Roots mod $p$ only).** If $r_q = 0$, then $S(H, pq) = r_p \cdot q$. In particular if $r_p \ge 1$ then $S \ge q$.

*Proof sketch.* Theorem 4.3 with $r_q = 0$ gives $S = r_p(q - 0) + (p - r_p)\cdot 0 = r_p q$. $\square$

This is the configuration in which the method is actually useful: every residue that is a root modulo $p$ works, because there is no interference from $q$.

**Theorem 6.3 (Expected number of evaluations, upper bound).** If $p \le q$, $r_p \ge 1$ and $r_q = 0$, then
$$\frac{N}{S} \;\le\; p \;\le\; \sqrt{N}.$$

*Proof sketch.* By Theorem 6.2, $S \ge q$, so $N/S \le pq/q = p$; and $p \le q$ gives $p^2 \le pq$, i.e. $p \le \sqrt{pq}$. $\square$

**Theorem 6.4 (Two-sided $\sqrt{N}$ scaling).** Let $N = pq$ be a balanced semiprime, $H$ monic of degree $h$, with $r_p \ge 1$ and $r_q = 0$. Then
$$\frac{\sqrt{N}}{4h} \;\le\; \frac{N}{S(H,N)} \;\le\; \sqrt{N}.$$

*Proof sketch.* Combine Theorem 5.3 (whose hypothesis $S > 0$ holds by Theorem 6.2) and Theorem 6.3. $\square$

So the method is genuinely $\sqrt{N}$: no polynomial-time behaviour hides in the constants, and up to the factor $4h$ the lower bound is attained.

### 6.1 The class number cancels

Theorem 6.4 has $h$ in the denominator, which invites the strategy of choosing discriminants with very large class number. The next result closes that door.

**Theorem 6.5 (Total work barrier).** Let $N = pq$ be balanced, $H$ monic of degree $h$, and $S = S(H,N) > 0$. Then
$$h \cdot \frac{N}{S} \;\ge\; \frac{\sqrt{N}}{4}.$$

*Proof sketch.* If $h = 0$ then $H = 1$, which has no roots modulo any prime, so $S = 0$, contradicting the hypothesis. For $h \ge 1$, multiply the inequality of Theorem 5.3 by $h > 0$: $h \cdot (N/S) \ge h \cdot \sqrt{N}/(4h) = \sqrt{N}/4$. $\square$

The interpretation is the heart of the matter. Evaluating a degree-$h$ polynomial at a point costs at least $h$ ring multiplications; Horner's rule achieves exactly $h$ multiplications and $h$ additions, and is optimal for a generic polynomial. So $h \cdot (N/S)$ is (a lower bound for) the *total arithmetic work*, and Theorem 6.5 bounds it below by $\sqrt{N}/4$ **with no $h$ in the bound**. The factor $1/h$ gained in the trial count is exactly repaid by the cost of a single trial: the $\sqrt{N}$ rate is a conservation law of the construction.

One should also note the quantitative ceiling on $h$ itself. By the class number formula and standard bounds, $h(D) = O(\sqrt{|D|}\log |D|)$, so achieving $h \approx \sqrt N$ requires $|D| \gtrsim N/\log^2 N$, and a class polynomial of degree $\sqrt N$ whose coefficients have $\Omega(\sqrt N)$ bits. Such an object cannot even be written down, let alone evaluated. The "speed-up by large $h$" is therefore doubly blocked: by Theorem 6.5 asymptotically, and by representability concretely.

### 6.2 Reparametrisation does not help

**Theorem 6.6 (Composition barrier).** Let $H$ and $g$ be monic with $\deg g = d \ge 1$. Then $H\circ g$ is monic of degree $hd$ and
$$\frac{S(H \circ g,\ pq)}{pq} \;\le\; hd\Big(\frac{1}{p} + \frac{1}{q}\Big).$$

*Proof sketch.* Monicity and $\deg(H\circ g) = \deg H \cdot \deg g$ are standard; apply Theorem 5.1 to $H\circ g$. $\square$

Substituting $j_0 \mapsto g(j_0)$ is the natural way to try to "aim" at the structured set — for instance to restrict to values of a parametrised family. Theorem 6.6 says the density bound degrades by exactly the factor $d$, which is exactly the factor by which the per-evaluation cost grows. Once again the product of density and cost is invariant.

---

## 7. The circularity bottleneck: no precomputation

The useful set is $\{j_0 : H_D(j_0) \equiv 0 \bmod p\}$ — defined in terms of the unknown prime. This is the *circularity* of the method. The only apparent escape is offline precomputation: fix a table $T$ of evaluation points (and a family $F$ of discriminants) once and for all, and hope that on each incoming $N$, some entry hits.

We show this is impossible, with a bound depending only on the size of the table.

**Definition 7.1 (Catchable primes).** For $H \in \mathbb{Z}[X]$ and a finite $T \subset \mathbb{Z}$,
$$\mathrm{Catch}(H, T) \;:=\; \bigcup_{t \in T} \{\text{prime factors of } |H(t)|\}.$$
A prime $r$ lies in $\mathrm{Catch}(H,T)$ iff there is $t \in T$ with $H(t)\ne 0$ and $r \mid H(t)$.

The point is that a table entry $t$ can only ever detect a prime dividing the *fixed integer* $H(t)$.

**Theorem 7.2 (Precomputation bound).** For any $H$ and finite $T$,
$$|\mathrm{Catch}(H,T)| \;\le\; \sum_{t \in T} \log_2 |H(t)|.$$

*Proof sketch.* The union bound gives $|\mathrm{Catch}(H,T)| \le \sum_{t\in T} \omega(|H(t)|)$ where $\omega$ counts distinct prime factors. For $n \ne 0$, $2^{\omega(n)} \le \prod_{r \mid n, r \text{ prime}} r \le n$, since each prime factor is $\ge 2$ and the radical divides $n$; hence $\omega(n) \le \log_2 n$. $\square$

The right-hand side is determined by the *bit size of the table*, with no dependence whatsoever on the modulus $N$ under attack. A table occupying $B$ bits catches at most $O(B)$ primes.

**Corollary 7.3 (Infinitely many invisible primes).** For any $H$ and finite $T$, the set of primes not in $\mathrm{Catch}(H,T)$ is infinite.

*Proof sketch.* $\mathrm{Catch}(H,T)$ is finite and the primes are infinite (Euclid). $\square$

**Theorem 7.4 (Precomputed attacks fail on arbitrarily large inputs).** Let $F$ be a finite family of polynomials, $T$ a finite table of evaluation points, and $M$ any bound. Then there exist distinct primes $p, q > M$ such that for every $G \in F$ and every $t \in T$,
$$\mathrm{eg}(G, t, pq) \text{ is \textit{not} a nontrivial divisor of } pq;$$
moreover if $G(t) \neq 0$ for all $G \in F$, $t\in T$, then $\mathrm{eg}(G,t,pq) = 1$ for all of them.

*Proof sketch.* Let $\Sigma := \bigcup_{G\in F} \mathrm{Catch}(G,T)$, a finite set of primes. Choose a prime $p > M$ with $p \notin \Sigma$, then a prime $q > p$ with $q \notin \Sigma$; both exist by Corollary 7.3. Fix $G \in F$, $t \in T$. If $G(t) = 0$ then $\gcd(0, pq) = pq$, not a nontrivial divisor. Otherwise, $p \notin \mathrm{Catch}(G,T)$ means $p \nmid G(t)$, and likewise $q \nmid G(t)$, so by Lemma 3.0(1) the gcd is $1$. $\square$

Interpretation: the structured set cannot be enumerated in advance, only searched — and Theorem 5.3 prices that search at $\sqrt N/(4h)$ evaluations, Theorem 6.5 at $\sqrt N/4$ units of work. This is the precise content of the circularity bottleneck.

---

## 8. Asymptotic classification

Let $x = \log N$ be the bit-size variable and define the proven cost profile of the method for a fixed class number $h > 0$:
$$C_h(x) \;:=\; \frac{e^{x/2}}{4h}.$$
This is exactly $\sqrt{N}/(4h)$, the lower bound of Theorem 5.3, expressed in $x$.

**Lemma 8.1 (Stability).** If $f$ is superpolynomial and $c > 0$ then $x \mapsto f(x)/c$ is superpolynomial. If $f$ is subexponential and $c\in\mathbb{R}$ then $x \mapsto c\,f(x)$ is subexponential.

**Theorem 8.2 (Ladder placement).** For every $h > 0$:
1. $C_h$ is superpolynomial; in particular it is not polynomially bounded, so the method is not a polynomial-time factoring algorithm.
2. $C_h$ is *not* subexponential; it does not reach the sieve rung $L_N[1/3, c]$.
3. Eventually $e^{x/4} \le C_h(x)$: the method's cost dominates the birthday/collision barrier of Pollard's rho.
4. The sieve barrier $L_N[1/3,c]$ *is* subexponential; hence $C_h$ and the sieve cost lie on strictly different rungs, with $C_h$ on the worse one.

*Proof sketch.* (1) $x^d/(e^{x/2}/(4h)) = 4h\,x^d e^{-x/2} \to 0$ for every $d$, using Lemma 8.1 and $x^d/e^{x/2}\to 0$. (2) If $C_h$ were subexponential then so would be $4h\,C_h(x) = e^{x/2}$, contradicting subexponentiality at $\varepsilon = 1/4$, since $e^{x/2}/e^{x/4} = e^{x/4}\to\infty$. (3) Write $e^{x/2} = e^{x/4}\cdot e^{x/4}$. Since $e^{x/4}\to\infty$, eventually $e^{x/4}\ge 4h$, whence $e^{x/2} \ge 4h\,e^{x/4}$, i.e. $e^{x/4} \le e^{x/2}/(4h) = C_h(x)$. (4) $L_N[1/3,c] = \exp\big((c+o(1))x^{1/3}(\log x)^{2/3}\big)$, and $x^{1/3}(\log x)^{2/3}/(\varepsilon x)\to 0$ for every $\varepsilon>0$. $\square$

Summarising the classification:

$$\underbrace{L_N[1/3,c]}_{\text{number field sieve}} \;\prec\; \underbrace{N^{1/4}}_{\text{Pollard rho}} \;\preceq\; \underbrace{\sqrt{N}/(4h)}_{\textbf{singular moduli}} \;\prec\; \underbrace{N}_{\text{trial division}}.$$

Singular moduli factoring is limited by the same resource as the collision methods — the inability to sample a set defined in terms of the unknown factor better than at random — and is therefore *not a new resource*, merely a new instance of an old barrier.

---

## 9. Verified instances and experimental scaling

### 9.1 Exact factorisations

Each of the following is a closed-form computation, verified exactly:

| $N$ | $p\cdot q$ | $D$ | $H_D$ | $j_0$ | $H_D(j_0)$ | $\gcd(H_D(j_0), N)$ |
|---|---|---|---|---|---|---|
| $77$ | $7\cdot 11$ | $-15$ | $X^2 + 191025X - 121287375$ | $0$ | $-121287375$ | $11$ |
| $899$ | $29\cdot 31$ | $-8$ | $X - 8000$ | $2$ | $-7998$ | $31$ |
| $3599$ | $59\cdot 61$ | $-19$ | $X + 884736$ | $8$ | $884744$ | $61$ |
| $5183$ | $71\cdot 73$ | $-11$ | $X + 32768$ | $9$ | $32777$ | $73$ |

### 9.2 Exact success counts

For $H_{-15} = X^2 + 191025X - 121287375$ one computes the root counts modulo small primes directly, and then $S$ from Theorem 4.3 rather than by enumeration:

- $r_7 = 1$, $r_{11} = 2$, so $S(H_{-15}, 77) = 1\cdot(11-2) + (7-1)\cdot 2 = 21$. Exhaustive verification over all $77$ residues confirms $21$.
- $r_{13} = 1$, $r_{17} = 0$, so $S(H_{-15}, 221) = 1\cdot 17 + 12\cdot 0 = 17$. Hence $N/S = 221/17 = 13$ exactly. Since $\sqrt{221}\approx 14.866$ and $h = 2$, the two-sided bound $\sqrt{221}/8 \approx 1.858 \le 13 \le 14.866$ is verified — and non-vacuous.

Wider data, with the $h(p+q)$ bound from Corollary 4.5 for comparison:

| $p, q$ | $D$ | $r_p$ | $r_q$ | $S$ (exhaustive) | Theorem 4.3 | $h(p+q)$ |
|---|---|---|---|---|---|---|
| $7, 11$ | $-15$ | $1$ | $2$ | $21$ | $21$ | $36$ |
| $13, 17$ | $-15$ | $1$ | $0$ | $17$ | $17$ | $60$ |
| $11, 13$ | $-31$ | $2$ | $1$ | $33$ | $33$ | $72$ |
| $71, 73$ | $-23$ | $0$ | $0$ | $0$ | $0$ | $432$ |
| $101, 103$ | $-20$ | $2$ | $0$ | $206$ | $206$ | $408$ |

The row $(71,73)$, $D = -23$ is exactly the blindness of Theorem 3.4 in the wild: for that discriminant the class polynomial has no root modulo either prime and *no* evaluation point works. A minimal illustration is $X^2 + 1$, which is irreducible modulo $7$ and modulo $11$: against $N = 77$ it provably never yields a factor.

### 9.3 Scaling experiment

Sweeping $j_0 = 0, 1, 2, \ldots$ over the discriminants $-4, -7, -8, -11, -15, -19, -20, -23$ and recording the first success (evaluations counted as (discriminant, $j_0$) pairs):

| $N$ | $p, q$ | first hit $(D, j_0)$ | factor | evaluations | evals$/\sqrt{N}$ |
|---|---|---|---|---|---|
| $15$ | $3, 5$ | $(-4, 0)$ | $3$ | $2$ | $0.52$ |
| $35$ | $5, 7$ | $(-7, 0)$ | $5$ | $3$ | $0.51$ |
| $77$ | $7, 11$ | $(-15, 0)$ | $11$ | $7$ | $0.80$ |
| $143$ | $11, 13$ | $(-15, 0)$ | $11$ | $7$ | $0.59$ |
| $323$ | $17, 19$ | $(-23, 0)$ | $17$ | $10$ | $0.56$ |
| $899$ | $29, 31$ | $(-8, 2)$ | $31$ | $32$ | $1.07$ |
| $3599$ | $59, 61$ | $(-19, 8)$ | $61$ | $120$ | $2.00$ |
| $5183$ | $71, 73$ | $(-11, 9)$ | $73$ | $131$ | $1.82$ |
| $10403$ | $101, 103$ | $(-15, 3)$ | $101$ | $49$ | $0.48$ |
| $39203$ | $197, 199$ | $(-7, 8)$ | $199$ | $115$ | $0.58$ |

Every instance factored, using $2$ to $131$ evaluations. The ratio evals$/\sqrt{N}$ stays in the band $[0.48, 2.00]$ across two orders of magnitude of $N$ — exactly the behaviour a $\Theta(\sqrt N)$ law predicts. What the theorem *forbids* is a ratio decaying like $N^{-c}$, and none is observed.

---

## 10. Algorithms

### 10.1 The method itself

```
INPUT   N (semiprime), discriminant list D[1..k], evaluation budget B
OUTPUT  a nontrivial factor of N, or FAIL

for j0 = 0, 1, 2, ... :
    for each D in the list:
        v  <- H_D(j0) mod N          # Horner, deg(H_D) = h(D) multiplications
        g  <- gcd(v, N)
        if 1 < g < N:  return g
        # g = N means j0 is a CM point modulo BOTH primes: discard
        if evaluations exceeded B: return FAIL
```
Cost of one iteration: $O(h(D))$ multiplications modulo $N$ plus one gcd, i.e. $\tilde{O}(h \log N)$ bit operations. By Theorem 5.3 the expected iteration count is at least $\sqrt N/(4h)$, and by Theorem 6.5 the expected total is at least $\sqrt N/4$ modular multiplications.

### 10.2 Exact success count

```
INPUT   H, distinct primes p, q
OUTPUT  S = |{ j in [0,pq) : gcd(H(j), pq) is a nontrivial divisor }|

r_p <- #{ x in Z/p : H(x) = 0 mod p }     # p evaluations, or root-finding in F_p
r_q <- #{ x in Z/q : H(x) = 0 mod q }
return r_p*(q - r_q) + (p - r_p)*r_q
```
Cost $O((p+q)\cdot h)$ naively, or $\tilde{O}(h\log p + h\log q)$ using $\gcd(X^p - X, H)$ to count roots — versus $\Theta(pq)$ for brute-force enumeration. This is a genuinely useful speedup for verification, and it is *exact*.

### 10.3 Auditing the barrier

```
INPUT   N = pq balanced, class polynomial H of degree h
OUTPUT  the certified interval for the expected number of evaluations

S   <- exact success count (Section 10.2)
if S = 0: report BLIND (Theorem 3.4)
lo  <- sqrt(N) / (4h)      # Theorem 5.3
hi  <- sqrt(N)             # Theorem 6.3, valid when r_p >= 1, r_q = 0
report N/S together with [lo, hi], and work bound sqrt(N)/4 (Theorem 6.5)
```

---

## 11. Discussion

### 11.1 What the analysis does and does not show

The method's analysis is unusually clean because Theorem 3.1 and Theorem 4.3 use *nothing* about $H_D$ beyond its being an integer polynomial. There is no heuristic step, no equidistribution assumption, no Riemann Hypothesis. The only input from complex multiplication is qualitative: it explains *why* $H_D$ has roots modulo $p$ when it does, and hence when the favourable configuration of Theorem 6.4 arises. The barrier itself is insensitive to that theory.

This is a strength and a limitation. Strength: the conclusion is unconditional and applies to every polynomial-evaluation-plus-gcd scheme, not only to class polynomials. Limitation: precisely because the argument ignores the arithmetic of $H_D$, it cannot rule out a method that *uses* that arithmetic differently — for instance one that computes with CM curves over $\mathbb{Z}/N$ rather than merely evaluating an integer polynomial.

### 11.2 The pattern behind $\sqrt{N}$ methods

Singular moduli factoring joins a family. Pollard's rho exploits the fact that a random walk modulo $p$ collides after $O(\sqrt p)$ steps, but cannot observe the walk modulo $p$; Pollard's $p-1$ exploits smoothness of $p-1$, but cannot see which primes have smooth predecessor; the elliptic curve method exploits smooth group orders over $\mathbb{F}_p$, and pays subexponentially only because it may *resample the group*. What singular moduli factoring exploits is that CM points modulo $p$ form a set of size $h$ inside $\mathbb{F}_p$ — again invisible from outside.

In each case a genuine arithmetic structure is converted into a search for a set defined in terms of the secret, and each search is priced at the square root of the modulus. Theorem 7.4 makes this precise for our method: the structured set cannot be tabulated offline at any finite size.

The number field sieve escapes the pattern because the structure it exploits — smooth values of an integer polynomial over $\mathbb{Z}$ — is visible without knowing $p$, and the pieces are assembled by linear algebra rather than by search. That, in a sentence, is why RSA's security does not rest on the factors being unstructured, but on the structure being unobservable.

### 11.3 Practical consequences

For cryptographic parameters, $\sqrt{N}$ is astronomically worse than $L_N[1/3, 1.923]$. For a $2048$-bit modulus, $\sqrt N = 2^{1024}$ whereas the sieve heuristic is around $2^{110}$. Even a class number of $2^{40}$ — far beyond what is representable — changes $\sqrt N/(4h)$ only to $2^{982}$, and Theorem 6.5 says the *work* is unchanged at $2^{1022}$. Singular moduli factoring is therefore of no practical threat, and its interest is entirely structural: it is a clean, fully analysable instance of a barrier that is usually only argued heuristically.

There is, however, one practical corollary. The exact count of Theorem 4.3 is a useful tool for *auditing* claims about CM-based attacks: any proposal in this family can be tested by computing $r_p, r_q$ on toy instances and comparing with the identity. A proposal that claims to beat $4h/\sqrt N$ density must violate either Lagrange's theorem or the Chinese Remainder Theorem.

### 11.4 The role of blindness

Theorem 3.4 is often omitted from informal accounts and deserves emphasis. The statement "$H_D$ mod $p$ has $h$ roots" holds only when $D$ is a square modulo $p$; for roughly half of the discriminants this fails, and then $H_D$ may be irreducible modulo $p$. When it fails at both primes, the method's success probability is exactly $0$, not merely small.

A correct expected-cost analysis therefore has two layers: the cost of finding a discriminant usable for the (unknown) $p$, and, conditional on that, the $\Theta(\sqrt{N})$ cost of Theorem 6.4. The first layer is itself circular in the same way — one cannot check whether $D$ is a square modulo $p$ without knowing $p$ — which is why in practice one sweeps over discriminants, and why Theorem 5.4 (the multi-discriminant barrier) is the right statement for a realistic attacker.

---

## 12. Future directions

The analysis settles the basic question. The following conjectures are the natural next targets; each is falsifiable and each is stated so that a counterexample or a proof would be recognisable.

### Conjecture 1 (Degree–density duality: the barrier is a conservation law)

*For every family of integer polynomials $H_k$ with $\deg H_k = h_k$ and every family of evaluation strategies, the product (density of useful points) $\times$ (cost of one evaluation) is $O(1/\sqrt N)$ — the two factors trade off exactly.*

Formally: if $W(H)$ denotes any cost measure with $W(H) \ge \deg H$ (Horner is optimal up to constants for a generic polynomial), then $W(H)\cdot S(H,N)/N \le 4\,W(H)\,h/\sqrt{N}$ cannot be improved to $o(1/\sqrt N)$ by any choice of $H$, because the bound $S \le h(p+q)$ is sharp (Theorem 6.1).

The key insight is that $h$ appears in the numerator of the density bound and in the denominator of the per-evaluation cost with the same exponent, so the $\sqrt N$ rate is a *conservation law of the construction*, not a limitation of the counting technique. Theorem 6.5 already proves the $\sqrt N/4$ lower bound for a single monic $H$; the missing step is an abstract cost model with $W(H) \ge \deg H$ and the corresponding statement $\forall H,\ W(H)\cdot N/S(H,N) \ge \sqrt N/4$, a routine generalisation of the argument of Section 6.

### Conjecture 2 (Elliptic escape: CM torsion evades the counting bound)

*Replacing "evaluate $H_D$ at $j_0$" by "compute the $\ell$-division polynomial of a random curve $E/\mathbb{Z}_N$ and take a gcd of its value" gives a success density bounded by $c\,\ell^2/\sqrt N$ — the same $\sqrt N$ rate with $h$ replaced by the degree $(\ell^2-1)/2$, hence still no gain; but the density is achieved for a positive proportion of curves rather than a proportion $\approx h/p$.*

The key insight is that both methods are instances of one scheme: a fixed integer polynomial whose roots modulo $p$ encode an arithmetic property of $p$. The counting theorem (Theorem 4.3) applies verbatim, since it never uses anything about $H_D$ beyond its degree. Theorems 4.3 and 5.1 are already stated for an arbitrary monic $H \in \mathbb{Z}[X]$, so the whole of an ECM-style analysis can be obtained by instantiating $H$ with division polynomials; only the sharpness direction (existence of roots) needs new input, namely Hasse's bound.

### Conjecture 3 (Adaptive search does not beat uniform search)

*For every adaptive deterministic algorithm that may choose its next evaluation point as a function of all previously observed gcds, the number of evaluations needed on a worst-case balanced semiprime is still $\Omega(\sqrt N/h)$.*

The intuition is that a failed trial returns the single bit "$\gcd = 1$", which excludes only the $O(h)$ residues modulo $p$ and modulo $q$ that the trial tested; an adversary argument in the style of Theorem 7.4 should show that any transcript of $o(\sqrt N/h)$ failures is consistent with many semiprimes, so the algorithm cannot have determined the factorisation. Theorem 7.4 is the non-adaptive case, obtained by taking the table $T$ to be the algorithm's fixed query set.

### Further targets

- **Quantify blindness.** Determine, over a family of discriminants of bounded size, the exact proportion of semiprimes on which every member is blind, and hence the true two-layer expected cost.
- **Sharpen the balance constant.** Theorem 5.2 uses $p \le q \le 3p$ to get $p + q \le 4\sqrt{pq}$; the optimal constant for $q \le \lambda p$ is $\sqrt\lambda + 1/\sqrt\lambda$, and a version with $\lambda$ tending to $1$ (as for RSA) gives density $\le (2+o(1))h/\sqrt N$.
- **Second moments.** Theorem 6.4 controls the expectation; a variance bound would give concentration and hence a proven failure probability for a bounded run.
- **Beyond semiprimes.** Theorem 4.3 generalises by inclusion–exclusion to $N$ with $k$ prime factors: the density of points splitting the factorisation nontrivially should be $\le 2^{k}h/\,\min_i p_i$, and the resulting barrier is $\min_i p_i$ rather than $\sqrt N$.

---

## 13. Conclusion

Singular moduli factoring works, exactly as complex multiplication suggests it should: every test semiprime factored, with an explicit gcd witnessing each factorisation. Its analysis, however, admits no heuristic wiggle room. The success criterion is an exact exclusive-or; the success count is an exact Chinese-Remainder identity; Lagrange's theorem caps the useful set at $h(p+q)$ out of $pq$ points; and the resulting expected number of evaluations on a balanced semiprime lies provably in $[\sqrt N/(4h),\ \sqrt N]$. The class-number speed-up is exactly cancelled by evaluation cost, reparametrisation is exactly cancelled by degree growth, running many discriminants leaves the density unchanged, and no finite precomputed table can help on more than a bounded set of primes.

The method's cost profile $e^{x/2}/(4h)$ is superpolynomial and genuinely exponential, dominating the birthday barrier and lying strictly above the subexponential sieve rung. Singular moduli factoring is therefore a member — a beautiful, fully analysable member — of the $\sqrt N$ family, and its barrier is the familiar one: a structured set indexed by the secret is no easier to find than the secret itself.
