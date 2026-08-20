# A $q$-Analogue of Kummer's Theorem

### The $\ell$-adic valuation, congruence classes and survivor counts of Gaussian binomial coefficients

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

Kummer's theorem determines the exact power of a prime $p$ dividing $\binom{n}{k}$ as the number of carries produced when $k$ and $n-k$ are added in base $p$; Lucas's theorem is its congruence-theoretic twin. We develop the corresponding theory for the Gaussian ($q$-)binomial coefficients $\binom{n}{k}_q$, which for a prime power $q$ count the $k$-dimensional subspaces of an $n$-dimensional vector space over the field with $q$ elements.

Fix an integer $q \ge 2$ and a prime $\ell \nmid q$. Let $d$ be the multiplicative order of $q$ modulo $\ell$ (modulo $4$ when $\ell = 2$) and put $e = v_\ell([d]_q)$, where $[m]_q = 1 + q + \cdots + q^{m-1}$. Our main theorem is the exact formula
$$v_\ell\!\left(\binom{n}{k}_{\!q}\right) \;=\; e\,c \;+\; v_\ell\!\left(\binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\right) \;+\; c\,v_\ell\!\left(\left\lfloor\frac{n-k}{d}\right\rfloor + 1\right),$$
where $c \in \{0,1\}$ is the carry out of the base-$d$ digit when $k$ and $n-k$ are added. Combined with Kummer's classical theorem this exhibits the valuation as a carry count in the *mixed radix* $(d, \ell, \ell, \ell, \dots)$: one anomalous digit of size $d$ and weight $e$, then ordinary base-$\ell$ arithmetic.

We isolate the exact input the argument needs in a notion of *regular datum*, prove that the multiplicative order supplies one at every odd prime $\ell \nmid q$ by lifting the exponent, show that the recipe **fails** at $\ell = 2$ and that replacing the order modulo $2$ by the order modulo $4$ repairs it, and package the two cases into a single master formula valid at every prime not dividing $q$.

On the congruence side we prove a $q$-Lucas theorem, $\binom{n}{k}_q \equiv \binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\binom{n \bmod d}{k \bmod d}_q \pmod \ell$, valid at every prime with no bound on $n$, together with its mixed-radix expansion. From it we deduce a sharp indivisibility criterion, the closed-form survivor count
$$\#\left\{k \le n : \ell \nmid \tbinom{n}{k}_{\!q}\right\} = (n \bmod d + 1)\prod_i\left(\delta_i + 1\right), \qquad \delta_i = \text{$i$-th base-$\ell$ digit of } \lfloor n/d\rfloor,$$
an exact self-similar total $\sum_{n< d\ell^m}\#\{k : \ell \nmid \binom{n}{k}_q\} = \tfrac{d(d+1)}{2}\left(\tfrac{\ell(\ell+1)}{2}\right)^m$, and a complete description of the rows all of whose entries are prime to $\ell$. Finally we show the logarithmic growth bound $v_\ell(\binom{n}{k}_q) \le e + \log_\ell\lfloor n/d\rfloor + \log_\ell(\lfloor (n-k)/d\rfloor+1)$ is attained infinitely often, on the explicit family $v_\ell\big(\binom{d\ell^s}{d+1}_q\big) = e + s$, and transport every statement to the geometric setting of subspace counts in finite vector spaces.

**Keywords:** Gaussian binomial coefficient, Kummer's theorem, Lucas's theorem, $\ell$-adic valuation, cyclotomic period, lifting the exponent, mixed radix, Sierpiński pattern, subspace counting.

---

## 1. Introduction

### 1.1 The classical picture

Two nineteenth-century theorems describe the arithmetic of binomial coefficients modulo a prime $p$ with complete precision.

**Kummer's theorem.** For $k \le n$, the $p$-adic valuation $v_p\binom{n}{k}$ equals the number of carries when $k$ and $n-k$ are added in base $p$.

**Lucas's theorem.** If $n = \sum n_i p^i$ and $k = \sum k_i p^i$ in base $p$, then $\binom{n}{k} \equiv \prod_i \binom{n_i}{k_i} \pmod p$.

Together they explain the Sierpiński pattern of Pascal's triangle modulo $p$, Glaisher's count of surviving entries in a row, and the logarithmic bound $v_p\binom{n}{k} \le \log_p n$.

### 1.2 The deformation

Fix an integer $q \ge 2$. The *$q$-integer*, *$q$-factorial* and *Gaussian binomial coefficient* are
$$[m]_q = \sum_{i=0}^{m-1} q^i = \frac{q^m-1}{q-1}, \qquad [n]_q! = \prod_{m=1}^{n}[m]_q, \qquad \binom{n}{k}_{\!q} = \frac{[n]_q!}{[k]_q!\,[n-k]_q!}.$$
At $q = 1$ these degenerate to $m$, $n!$ and $\binom{n}{k}$. For a prime power $q$ the Gaussian coefficient counts the $k$-dimensional subspaces of $\mathbb{F}_q^{\,n}$, so its arithmetic is the arithmetic of a Grassmannian over a finite field.

The question this paper answers is: **what determines $v_\ell\binom{n}{k}_q$ for a prime $\ell$?**

The primes $\ell \mid q$ are uninteresting: every $[m]_q$ with $m \ge 1$ is $\equiv 1 \pmod{\ell}$, so $\ell \nmid \binom{n}{k}_q$ always. The whole content lies in the primes $\ell \nmid q$, where the cyclotomic structure of $q^m - 1$ enters.

### 1.3 Summary of results and the shape of the answer

The answer, in a phrase: *the deformation modifies exactly one digit*. The base-$\ell$ digit expansion controlling the classical theory acquires an extra, bottom digit of size $d = \mathrm{ord}_\ell(q)$ carrying weight $e = v_\ell([d]_q)$; the higher digits are untouched. Section 3 proves this on the valuation side, Section 5 on the congruence side, Section 6 in the form of survivor counts, Section 7 in the form of sharp extremal families, and Section 8 in the geometric language of subspaces. Section 4 records the anomaly at $\ell = 2$ and its repair.

---

## 2. Foundations: exactness of the $q$-Pascal recursion

Because we want valuations of *integers*, the first order of business is to know that $\binom{n}{k}_q$ *is* an integer and that the defining division is exact. We take the recursion as the definition and prove the quotient formula, rather than the reverse.

**Definition 2.1 ($q$-Pascal coefficient).** For $q \ge 0$ define $\binom{n}{k}_q \in \mathbb{N}$ by
$$\binom{n}{0}_{\!q} = 1, \qquad \binom{0}{k+1}_{\!q} = 0, \qquad \binom{n+1}{k+1}_{\!q} = \binom{n}{k}_{\!q} + q^{\,k+1}\binom{n}{k+1}_{\!q}.$$

Manifest non-negativity and integrality are built in. Two elementary identities drive everything:

**Lemma 2.2 (additivity of $q$-integers).** $[a+b]_q = [a]_q + q^{a}[b]_q$.

*Proof sketch.* Split the geometric sum $\sum_{i<a+b} q^i$ at $i = a$ and factor out $q^a$. $\square$

**Lemma 2.3.** $(q-1)[m]_q = q^m - 1$, and $[m]_q > 0$ for $m > 0$.

**Theorem 2.4 (Exactness).** For $k \le n$,
$$[k]_q!\;[n-k]_q!\;\binom{n}{k}_{\!q} = [n]_q!.$$

*Proof sketch.* Induct on $n$. In the inductive step apply the recursion and the two instances of the inductive hypothesis at $(n,k)$ and $(n,k+1)$; the two resulting terms recombine using $[k+1]_q + q^{k+1}[n-k]_q = [n+1]_q$, which is Lemma 2.2 with $a = k+1$, $b = n-k$. $\square$

**Corollary 2.5.** $\binom{n}{k}_q = [n]_q! / ([k]_q![n-k]_q!)$ exactly, $\binom{n}{k}_q > 0$ for $k \le n$, and $\binom{n}{k}_q = \binom{n}{n-k}_q$.

Theorem 2.4 is the hinge of the entire paper: it converts every valuation question about $\binom{n}{k}_q$ into a valuation question about $q$-factorials, hence into a counting question about which $q$-integers a prime divides, and how strongly.

---

## 3. The valuation theory

### 3.1 Regular data

**Definition 3.1 (regular datum).** Let $q, \ell, d, e$ be natural numbers with $d > 0$. We say $(d,e)$ is a *regular datum for $q$ at $\ell$* if for every $m > 0$,
$$v_\ell([m]_q) = \begin{cases} e + v_\ell(m/d), & d \mid m, \\[2pt] 0, & d \nmid m.\end{cases}$$

The definition abstracts exactly what a Kummer-type argument consumes. Classically ($q = 1$, $d = \ell$, $e = 1$) it reduces to the tautology $v_\ell(m) = 1 + v_\ell(m/\ell)$ for $\ell \mid m$. Its virtue is that the two independent inputs — which $q$-integers $\ell$ divides (a cyclotomic question), and how strongly (a lifting-the-exponent question) — are isolated once, and the combinatorics runs uniformly afterwards.

### 3.2 The $q$-Legendre formula

**Theorem 3.2 ($q$-Legendre).** If $(d,e)$ is a regular datum for $q$ at $\ell$, then for all $n$,
$$v_\ell\!\left([n]_q!\right) = e\left\lfloor \frac{n}{d} \right\rfloor + v_\ell\!\left(\left\lfloor \frac{n}{d}\right\rfloor!\right).$$

*Proof sketch.* Induct on $n$, using $[n+1]_q! = [n+1]_q\,[n]_q!$. If $d \mid n+1$ then $\lfloor (n+1)/d\rfloor = \lfloor n/d\rfloor + 1$ and the regular datum contributes $e + v_\ell(\lfloor (n+1)/d\rfloor)$, which is precisely the increment of the right-hand side, since $v_\ell(M!) - v_\ell((M-1)!) = v_\ell(M)$. If $d \nmid n+1$ both sides are unchanged. $\square$

Multiplying by $\ell - 1$ and invoking the classical Legendre formula gives the digit-sum form: $(\ell-1)v_\ell([n]_q!) = (\ell-1)e\lfloor n/d\rfloor + \lfloor n/d\rfloor - s_\ell(\lfloor n/d\rfloor)$, where $s_\ell$ is the base-$\ell$ digit sum.

### 3.3 The main theorem

Write $N = \lfloor n/d\rfloor$, $A = \lfloor k/d \rfloor$, $B = \lfloor (n-k)/d\rfloor$. Ordinary division with remainder gives $N = A + B + c$, where $c \in \{0,1\}$ is the base-$d$ carry
$$c = \begin{cases} 1, & (k \bmod d) + ((n-k) \bmod d) \ge d,\\ 0, & \text{otherwise.}\end{cases}$$

**Lemma 3.3 (split of a factorial along a carry).** For $c \le 1$,
$$v_\ell\!\left((A+B+c)!\right) = v_\ell\!\left(\binom{A+B+c}{A}\right) + v_\ell(A!) + v_\ell(B!) + c\,v_\ell(B+1).$$

*Proof sketch.* Apply $\binom{M}{A}A!(M-A)! = M!$ with $M = A+B+c$; for $c = 0$ this is immediate, and for $c = 1$ one extra factor $(B+1)! = (B+1)\cdot B!$ appears, contributing $v_\ell(B+1)$. $\square$

**Theorem 3.4 ($q$-Kummer, carry form).** Let $(d,e)$ be a regular datum for $q$ at the prime $\ell$, let $k \le n$, and let $c \in \{0,1\}$ satisfy $N = A + B + c$. Then
$$\boxed{\;v_\ell\!\left(\binom{n}{k}_{\!q}\right) = e\,c \;+\; v_\ell\!\left(\binom{N}{A}\right) \;+\; c\,v_\ell(B+1).\;}$$

*Proof sketch.* Take $v_\ell$ of Theorem 2.4 and substitute the $q$-Legendre formula three times:
$$v_\ell\!\left(\tbinom{n}{k}_{\!q}\right) + \big(eA + v_\ell(A!)\big) + \big(eB + v_\ell(B!)\big) = eN + v_\ell(N!).$$
Now expand $v_\ell(N!)$ by Lemma 3.3 and $eN = eA + eB + ec$, and cancel. $\square$

**Theorem 3.5 ($q$-Kummer, explicit form).** With hypotheses as above and $c$ read off from the residues,
$$v_\ell\!\left(\binom{n}{k}_{\!q}\right) = e\cdot[\,d \le k \bmod d + (n-k)\bmod d\,] + v_\ell\!\left(\binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\right) + [\,d \le k\bmod d + (n-k) \bmod d\,]\cdot v_\ell\!\left(\left\lfloor\frac{n-k}{d}\right\rfloor+1\right).$$

**Theorem 3.6 (fully combinatorial form).** Under the same hypotheses,
$$v_\ell\!\left(\binom{n}{k}_{\!q}\right) = e\,c + \#\{\,i \ge 1 : \ell^i \le (A \bmod \ell^i) + ((N-A)\bmod \ell^i)\,\} + c\,v_\ell(B+1),$$
i.e. $e$ times the base-$d$ carry, plus the number of carries when $A$ and $N - A$ are added in base $\ell$, plus the correction term.

*Proof sketch.* Substitute Kummer's classical theorem in the form $v_\ell\binom{N}{A} = \#\{i \ge 1 : \ell^i \le A \bmod \ell^i + (N-A)\bmod \ell^i\}$ into Theorem 3.4. $\square$

Thus the valuation is a carry count in the mixed radix $(d, \ell, \ell, \dots)$, with the anomalous bottom digit weighted by $e$ and accompanied by the correction $c\,v_\ell(B+1)$. The correction is not an artefact: it records the extra factor $B+1$ that a carry pushes into the block factorial, and it is visible in the extremal families of Section 7.

### 3.4 Producing regular data: lifting the exponent

**Lemma 3.7.** For $q \ge 2$ and a prime $\ell$, $\mathrm{ord}_\ell(q) \mid m \iff \ell \mid q^m - 1$. Moreover $v_\ell(q^s-1) = v_\ell(q-1) + v_\ell([s]_q)$ for $s > 0$.

**Theorem 3.8 (regularity at odd primes).** Let $\ell$ be an odd prime, $q \ge 2$, $\ell \nmid q$, and set $d = \mathrm{ord}_\ell(q)$, $e = v_\ell([d]_q)$. Then $(d,e)$ is a regular datum for $q$ at $\ell$.

*Proof sketch.* If $d \nmid m$ then $\ell \nmid q^m - 1 = (q-1)[m]_q$, so $v_\ell([m]_q) = 0$. If $m = dt$, apply lifting the exponent to $x = q^d$ and $y = 1$: since $\ell$ is odd, $\ell \mid x - 1$ and $\ell \nmid x$, one has $v_\ell(x^t - 1) = v_\ell(x-1) + v_\ell(t)$. Rewriting both sides via $v_\ell(q^s-1) = v_\ell(q-1) + v_\ell([s]_q)$ and cancelling $v_\ell(q-1)$ gives $v_\ell([dt]_q) = v_\ell([d]_q) + v_\ell(t) = e + v_\ell(t)$. $\square$

Combining Theorems 3.4 and 3.8:

**Corollary 3.9 ($q$-Kummer at an odd prime).** For $q \ge 2$, an odd prime $\ell \nmid q$, $d = \mathrm{ord}_\ell(q)$, $e = v_\ell([d]_q)$ and $k \le n$, the formula of Theorem 3.5 holds.

**Example 3.10 (the test case).** $q = 2$, $n = 6$, $k = 3$: $\binom{6}{3}_2 = 1395 = 3^2\cdot 5\cdot 31$.
*At $\ell = 5$*: $d = \mathrm{ord}_5(2) = 4$, $e = v_5([4]_2) = v_5(15) = 1$; $3 \bmod 4 + 3 \bmod 4 = 6 \ge 4$ so $c = 1$; $N = 1$, $A = 0$, $B = 0$, so $v_5\binom{1}{0} = 0$ and $v_5(B+1) = 0$. Prediction $1$; and indeed $v_5(1395) = 1$.
*At $\ell = 3$*: $d = 2$, $e = v_3([2]_2) = v_3(3) = 1$; $c = 1$; $N = 3$, $A = 1$, so $v_3\binom{3}{1} = 1$; $B = 1$, $v_3(2) = 0$. Prediction $1 + 1 = 2$; and $v_3(1395) = 2$.

**Example 3.11 (why a pure base-$d$ carry count is false).** $q = 2$, $\ell = 5$, $d = 4$, $e = 1$, $n = 16$, $k = 1$. In base $4$, $1 + 33_4 = 100_4$ carries twice, so a naive count predicts $2$. But $\binom{16}{1}_2 = [16]_2 = 65535 = 3\cdot 5\cdot 17\cdot 257$ has $v_5 = 1$. Theorem 3.5 gives the correct value: $c = 1$ contributes $e = 1$, while $N = 4$, $A = 0$ give $v_5\binom{4}{0} = 0$ and $B = 3$, $v_5(4) = 0$. Only the *bottom* digit is base $d$.

---

## 4. The prime $\ell = 2$: failure and repair

Lifting the exponent has a well-known defect at $\ell = 2$, and it propagates.

**Proposition 4.1 (failure of the naive recipe).** For odd $q$ the order of $q$ modulo $2$ is $1$, so the recipe of Theorem 3.8 proposes the datum $(d,e) = (1,0)$, i.e. $v_2([m]_q) = v_2(m)$. This is false: for $q = 3$, $[2]_3 = 4$ has $v_2 = 2$, while the recipe predicts $1$. Consequently $(1,0)$ is not a regular datum for $q = 3$ at $\ell = 2$, and the naive $q$-Kummer prediction fails: $\binom{2}{1}_3 = 4$ has $v_2 = 2$, whereas $v_2\binom{2}{1} = 1$.

**Proposition 4.2 (parity of $q$-integers).** For odd $q$, $[m]_q \equiv m \pmod 2$; in particular $v_2([m]_q) = 0$ for odd $m$.

**Proposition 4.3 (lifting the exponent at $2$).** For odd $q \ge 3$ and even $m \neq 0$, $v_2([m]_q) + 1 = v_2(q+1) + v_2(m)$.

**Theorem 4.4 (repair at $\ell = 2$).** Let $q \ge 2$ be odd.
1. If $q \equiv 1 \pmod 4$ then $(1,0)$ *is* a regular datum for $q$ at $2$: $v_2([m]_q) = v_2(m)$.
2. If $q \equiv 3 \pmod 4$ then $(2, v_2([2]_q)) = (2, v_2(q+1))$ is a regular datum for $q$ at $2$.

*Proof sketch.* For odd $m$ both cases give $0$ by Proposition 4.2. For even $m$ apply Proposition 4.3. In case (1), $q \equiv 1 \pmod 4$ forces $v_2(q+1) = 1$, so $v_2([m]_q) = v_2(m)$. In case (2), $m = 2t$ and $v_2(m) = 1 + v_2(t)$, so $v_2([2t]_q) = v_2(q+1) + v_2(t)$, which is $e + v_2(t)$ with $e = v_2(q+1) = v_2([2]_q)$. $\square$

In both cases the correct period is precisely the multiplicative order of $q$ in $(\mathbb{Z}/4)^{\times}$: it is $1$ when $q \equiv 1 \pmod 4$ and $2$ when $q \equiv 3 \pmod 4$. This suggests the uniform definition:

**Definition 4.5 (period and offset).** For $q \ge 2$ and a prime $\ell \nmid q$ set
$$D(q,\ell) = \begin{cases} \mathrm{ord}_4(q), & \ell = 2,\\ \mathrm{ord}_\ell(q), & \ell \text{ odd,}\end{cases} \qquad E(q,\ell) = v_\ell\!\left([D(q,\ell)]_q\right).$$

**Theorem 4.6 (master theorem).** For every $q \ge 2$ and every prime $\ell \nmid q$, the pair $(D(q,\ell), E(q,\ell))$ is a regular datum, and hence for all $k \le n$, writing $D = D(q,\ell)$, $E = E(q,\ell)$ and $c$ for the base-$D$ carry,
$$v_\ell\!\left(\binom{n}{k}_{\!q}\right) = E\,c + v_\ell\!\left(\binom{\lfloor n/D\rfloor}{\lfloor k/D\rfloor}\right) + c\,v_\ell\!\left(\left\lfloor\frac{n-k}{D}\right\rfloor+1\right).$$

*Proof sketch.* Case split on $\ell = 2$ versus $\ell$ odd, applying Theorem 4.4 or Theorem 3.8, and then Theorem 3.4. $\square$

The $\ell = 2$ boundary is sharp in both directions: Proposition 4.1 shows the order modulo $2$ cannot be used, and Theorem 4.4 shows the order modulo $4$ suffices. Modulo $8$ is not needed.

---

## 5. The congruence side: a $q$-Lucas theorem

The valuation theorem controls how *strongly* $\ell$ divides a Gaussian coefficient. The congruence theorem identifies its residue.

### 5.1 The hypothesis

**Definition 5.1 ($q$-Lucas period).** A positive integer $d$ is a *$q$-Lucas period for the prime $\ell$* if (i) $\ell \mid [d]_q$, (ii) $q^d \equiv 1 \pmod \ell$, and (iii) $\ell \nmid [i]_q$ for $0 < i < d$.

**Proposition 5.2.** If $q \ge 2$, $\ell \nmid q$ is prime and $d = \mathrm{ord}_\ell(q) > 1$, then $d$ is a $q$-Lucas period for $\ell$. (Condition (i) uses $e \ge 1$; conditions (ii) and (iii) are the definition of the order together with Lemma 3.7.)

The degenerate case $d = 1$ (i.e. $q \equiv 1 \pmod \ell$) is handled separately: then $[m]_q \equiv m$ and $\binom{n}{k}_q \equiv \binom{n}{k} \pmod \ell$.

### 5.2 The block factorisation

**Definition 5.3.** For $d > 0$ let $\mathrm{Red}_d(n) = \prod_{m \le n,\; d \nmid m} [m]_q$ be the *$d$-free part* of the $q$-factorial.

**Lemma 5.4.** $[dj]_q = [d]_q\,S_j$ where $S_j = 1 + q^d + \cdots + q^{d(j-1)} = [j]_{q^d}$.

**Theorem 5.5 (three-factor splitting).** $\displaystyle [n]_q! = \mathrm{Red}_d(n)\cdot [d]_q^{\lfloor n/d\rfloor}\cdot \left[\left\lfloor n/d\right\rfloor\right]_{q^d}!$.

*Proof sketch.* Separate the factors $[m]_q$ of $[n]_q!$ according to $d \mid m$. The multiples contribute $\prod_{j \le \lfloor n/d\rfloor}[dj]_q$, which by Lemma 5.4 equals $[d]_q^{\lfloor n/d\rfloor}\prod_j [j]_{q^d}$, i.e. $[d]_q^{\lfloor n/d\rfloor}[\lfloor n/d\rfloor]_{q^d}!$. $\square$

**Lemma 5.6 (residual units).** If $d$ is a $q$-Lucas period for $\ell$, then modulo $\ell$: $\mathrm{Red}_d(n) \equiv [d-1]_q!^{\lfloor n/d\rfloor}\,[n \bmod d]_q!$, and $[m]_q \equiv [m \bmod d]_q$ for every $m$. In particular $[m]_q$ is a unit mod $\ell$ whenever $d \nmid m$, and $\binom{r}{s}_q$ is a unit mod $\ell$ whenever $s \le r < d$.

*Proof sketch.* Both statements follow from $[m]_q = [m \bmod d]_q + q^{m\bmod d}[d]_q S_{\lfloor m/d\rfloor}$ (Lemma 2.2 plus Lemma 5.4) together with $\ell \mid [d]_q$; the unit statement uses (iii) of Definition 5.1 and Theorem 2.4 applied inside the block. $\square$

### 5.3 The theorem

**Theorem 5.7 ($q$-Lucas).** Let $d$ be a $q$-Lucas period for the prime $\ell$. Then for all $k \le n$,
$$\binom{n}{k}_{\!q} \;\equiv\; \binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\cdot\binom{n \bmod d}{\,k \bmod d}_{\!q} \pmod{\ell}.$$

*Proof sketch.* Feed the three-factor splitting (Theorem 5.5) for $n$, $k$ and $n-k$ into the exactness identity (Theorem 2.4). Two exact identities over $\mathbb{N}$ emerge, according to whether the base-$d$ digits carry:
$$\mathrm{Red}(k)\,\mathrm{Red}(n-k)\binom{n}{k}_{\!q} = \mathrm{Red}(n)\binom{N}{A}_{\!q^{d}} \quad\text{(no carry)},$$
$$\mathrm{Red}(k)\,\mathrm{Red}(n-k)\binom{n}{k}_{\!q} = \mathrm{Red}(n)\,[d]_q\,[N]_{q^{d}}\binom{N-1}{A}_{\!q^{d}} \quad\text{(carry)}.$$
In the carry-free case every $\mathrm{Red}$-factor is a unit modulo $\ell$ by Lemma 5.6, and since $q^d \equiv 1 \pmod \ell$ the $q^d$-binomial coefficient degenerates to the classical one, $\binom{N}{A}_{q^d} \equiv \binom{N}{A}$. Cancelling the units and reinstating the residual block factor gives the congruence. In the carry case the explicit factor $[d]_q$ is divisible by $\ell$, so the left side vanishes mod $\ell$; and the right side vanishes too, because $\binom{r}{s}_q = 0$ whenever $s > r$. $\square$

Two features are worth stressing.

* **No parity hypothesis.** The proof uses only that $\mathbb{Z}/\ell$ is a field, so the congruence holds at $\ell = 2$ (unlike the valuation theorem, which needs the modulo-$4$ repair).
* **No bound on $n$.** A naive cancellation argument would require $\lfloor n/d\rfloor < \ell$; routing the block product through the $q^d$-binomial coefficient removes the restriction. This is precisely the "large block index" regime, e.g. $q=2$, $\ell=3$, $n=13$: $d = 2$, $N = 6 \ge \ell$, and $\binom{13}{6}_2 = 14877590196755 \equiv \binom{6}{3}\binom{1}{0}_2 = 20 \equiv 2 \pmod 3$.

**Corollary 5.8 (order form).** For $q \ge 2$ and any prime $\ell \nmid q$ (including $\ell = 2$), with $d = \mathrm{ord}_\ell(q)$, the congruence of Theorem 5.7 holds for all $k \le n$; the degenerate case $d = 1$ is included.

**Theorem 5.9 (mixed-radix form).** If moreover $\lfloor n/d\rfloor < \ell^{a}$, then
$$\binom{n}{k}_{\!q} \;\equiv\; \binom{n\bmod d}{k \bmod d}_{\!q}\cdot\prod_{i<a}\binom{\left\lfloor n/d\right\rfloor / \ell^{i} \bmod \ell}{\left\lfloor k/d\right\rfloor / \ell^{i} \bmod \ell} \pmod{\ell}.$$

*Proof sketch.* Apply Theorem 5.7 once and then classical Lucas to the block coefficient. $\square$

Exactly one $q$-binomial factor survives — the one attached to the anomalous radix $d$ — and all remaining factors are classical binomial coefficients of single base-$\ell$ digits. This is the congruence-theoretic mirror of Theorem 3.6.

---

## 6. Counting survivors

Call an entry $\binom{n}{k}_q$ a *survivor* (at $\ell$) if $\ell \nmid \binom{n}{k}_q$.

**Theorem 6.1 (indivisibility criterion).** Let $d$ be a $q$-Lucas period for $\ell$ and $k \le n$. Then
$$\ell \nmid \binom{n}{k}_{\!q} \iff \Big(k \bmod d \le n \bmod d \ \text{ and } \ \ell \nmid \binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\Big).$$

*Proof sketch.* By Theorem 5.7 the reduction of $\binom{n}{k}_q$ is a product of two factors. If $k \bmod d > n\bmod d$ the residual factor is $\binom{r}{s}_q$ with $s > r$, hence $0$. Otherwise it is a unit (Lemma 5.6), so the product vanishes iff the classical factor does. $\square$

The criterion holds at every prime $\ell \nmid q$ with $d = \mathrm{ord}_\ell(q)$, no oddness needed, degenerate case included.

**Theorem 6.2 (row count factorises).**
$$\#\left\{k \le n : \ell \nmid \tbinom{n}{k}_{\!q}\right\} = \left(n \bmod d + 1\right)\cdot\#\left\{A \le \left\lfloor n/d\right\rfloor : \ell \nmid \tbinom{\lfloor n/d\rfloor}{A}\right\}.$$

*Proof sketch.* Write $k = dA + s$ with $0 \le s < d$. Criterion 6.1 factors the condition on $k$ into a condition on $s$ alone ($s \le n \bmod d$, satisfied by exactly $n \bmod d + 1$ values) and a condition on $A$ alone. Summing over the $A$-blocks gives the product. $\square$

The residual factor is $n \bmod d + 1$, **not** $d - (n \bmod d)$: the surviving residues are those *below* the last base-$d$ digit of $n$, and the complementary guess already fails at $n = 1$.

**Theorem 6.3 (Glaisher's count).** For a prime $p$ and any $N$, $\#\{A \le N : p \nmid \binom{N}{A}\} = \prod_i (N_i + 1)$, the product over the base-$p$ digits $N_i$ of $N$.

*Proof sketch.* The one-step Lucas criterion says $p \nmid \binom{N}{A}$ iff $A \bmod p \le N \bmod p$ and $p \nmid \binom{\lfloor N/p\rfloor}{\lfloor A/p\rfloor}$; the same block-decomposition argument as in Theorem 6.2 gives the recursion $F(N) = (N \bmod p + 1)F(\lfloor N/p\rfloor)$, whose solution is the digit product. $\square$

**Theorem 6.4 (closed-form $q$-row count).** With $d$ a $q$-Lucas period for $\ell$ and digits taken in base $\ell$,
$$\#\left\{k \le n : \ell \nmid \tbinom{n}{k}_{\!q}\right\} = \left(n \bmod d + 1\right)\prod_i\left(\mathrm{digit}_i\!\left(\left\lfloor n/d\right\rfloor\right)+1\right).$$

**Theorem 6.5 (exact self-similar total).** For every $m \ge 0$,
$$\sum_{n < d\,\ell^{m}} \#\left\{k \le n : \ell \nmid \tbinom{n}{k}_{\!q}\right\} = \left(\sum_{r<d}(r+1)\right)\left(\sum_{t<\ell}(t+1)\right)^{m} = \frac{d(d+1)}{2}\left(\frac{\ell(\ell+1)}{2}\right)^{m}.$$

*Proof sketch.* Group the rows $n < d\ell^m$ as $n = Md + j$ with $j < d$. By Theorem 6.4 the row count factors as $(j+1)$ times the digit product of $M$, so the sum factors as $\left(\sum_{j<d}(j+1)\right)\sum_{M<\ell^m}\prod(\text{digits}+1)$. The classical sum $\sum_{N<\ell^m}\prod_i(N_i+1) = \left(\sum_{t<\ell}(t+1)\right)^m$ is proved by the same blockwise induction. $\square$

The classical case $d = 1$ recovers the familiar statement that the first $\ell^m$ rows of Pascal's triangle contain exactly $\left(\ell(\ell+1)/2\right)^m$ entries prime to $\ell$ — the fractal dimension $\log_\ell(\ell(\ell+1)/2)$ of the Sierpiński pattern. The deformation multiplies the total by the constant $d(d+1)/2$, the number of cells in one triangular block, and leaves the growth rate untouched.

**Theorem 6.6 (full rows, classical).** For a prime $p$, the $N$-th row of Pascal's triangle contains no multiple of $p$ if and only if $N + 1 = c\,p^{t}$ for some $1 \le c \le p$. (Equivalently, every base-$p$ digit of $N$ below the leading one equals $p-1$; the case $t=0$ covers all rows $N < p$, which is why the guess "$N+1$ is a power of $p$" is false.)

*Proof sketch.* Strong induction on $N$ via the one-step criterion: for $N \ge p$, the row is full iff $N \bmod p = p - 1$ and the row $\lfloor N/p\rfloor$ is full. $\square$

**Theorem 6.7 (full rows, deformed).** Let $d$ be a $q$-Lucas period for $\ell$. The $n$-th row of the $q$-Pascal triangle consists entirely of integers prime to $\ell$ if and only if
$$n + 1 \le d \qquad\text{or}\qquad n+1 = d\,c\,\ell^{t} \ \text{ for some } 1 \le c \le \ell,\ t \ge 0.$$
Equivalently, the row count of Theorem 6.4 attains its maximum $n+1$ exactly on these rows.

*Proof sketch.* By Criterion 6.1 the row is full iff $n \bmod d = d-1$ (so that no $s < d$ is excluded) and the block row $\lfloor n/d\rfloor$ is classically full, or $n < d$; then apply Theorem 6.6 and translate. $\square$

So the full rows of the deformed triangle are exactly the $d$-dilates of the classical ones, preceded by the $d$ initial rows. Complementarily:

**Proposition 6.8 (residual entry).** Let $(d,e)$ be a regular datum. If $n \ge d$ and $n \bmod d < d-1$, then the entry $k = n \bmod d + 1$ forces a base-$d$ carry and
$$v_\ell\!\left(\binom{n}{\,n \bmod d + 1}_{\!q}\right) = e + v_\ell\!\left(\left\lfloor n/d\right\rfloor\right) \ \ge e.$$

So the offset $e$ is *available* in every row except those with maximal last digit — exactly the residue class excluded by the full-row criterion. The two statements dovetail: a row is either full, or contains an entry of valuation at least $e$.

---

## 7. Growth, sharpness and self-similarity

**Theorem 7.1 (upper bound).** For a regular datum $(d,e)$ and $k \le n$,
$$v_\ell\!\left(\binom{n}{k}_{\!q}\right) \le e + \log_\ell\left\lfloor \frac{n}{d}\right\rfloor + \log_\ell\left(\left\lfloor \frac{n-k}{d}\right\rfloor+1\right).$$

*Proof sketch.* In Theorem 3.4, $c \le 1$, the classical term is at most $\log_\ell\lfloor n/d\rfloor$ by Kummer, and $v_\ell(B+1)\le \log_\ell(B+1)$. $\square$

**Theorem 7.2 (sharpness).** Let $(d,e)$ be a regular datum with $d \ge 2$. Then for every $s \ge 1$,
$$v_\ell\!\left(\binom{d\,\ell^{s}}{\,d+1}_{\!q}\right) = e + s.$$

*Proof sketch.* Set $n = d\ell^s$, $k = d+1$. Then $k \bmod d = 1$ and $n - k = d(\ell^s-2)+(d-1)$, so $(n-k)\bmod d = d - 1$ and the base-$d$ addition carries: $c = 1$. The block indices are $N = \ell^{s}$, $A = 1$, $B = \ell^{s}-2$; hence $v_\ell\binom{\ell^s}{1} = s$ and $v_\ell(B+1) = v_\ell(\ell^s - 1) = 0$. Theorem 3.4 gives $e + s$. $\square$

**Corollary 7.3.** The bound of Theorem 7.1 is attained on this family, since $\log_\ell\lfloor n/d\rfloor = s$ and the third term is $0$. In particular the $\ell$-adic valuations of Gaussian binomial coefficients are unbounded, and neither the constant $e$ nor the logarithmic term can be removed.

**Theorem 7.4 (self-similarity).** For a regular datum $(d,e)$ and $A \le N$,
$$v_\ell\!\left(\binom{dN}{dA}_{\!q}\right) = v_\ell\!\left(\binom{N}{A}\right).$$

*Proof sketch.* Both $dA$ and $dN - dA = d(N-A)$ are multiples of $d$, so the base-$d$ digits are $0$ and $c = 0$; Theorem 3.4 collapses to the classical term. $\square$

**Theorem 7.5 (divisibility criterion, valuation form).** For a regular datum $(d,e)$ with $e \ge 1$ and $k \le n$,
$$\ell \mid \binom{n}{k}_{\!q} \iff \Big(c = 1 \ \text{ or } \ \ell \mid \binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\Big),$$
with $c$ the base-$d$ carry. For an odd prime $\ell \nmid q$ and $d = \mathrm{ord}_\ell(q) > 1$ the hypothesis $e \ge 1$ is automatic.

This is Theorem 6.1 seen from the valuation side; the two agree, as they must, and the congruence route additionally covers $e$-degenerate situations and $\ell = 2$.

---

## 8. Application: subspaces of finite vector spaces

For a prime power $q$, the number of $k$-dimensional subspaces of an $n$-dimensional vector space over $\mathbb{F}_q$ is classically written as the quotient
$$\mathrm{Gr}_q(n,k) = \frac{\prod_{i<k}(q^{n} - q^{i})}{\prod_{i<k}(q^{k}-q^{i})},$$
the numerator counting ordered linearly independent $k$-tuples in the space and the denominator those inside a fixed $k$-dimensional subspace.

**Theorem 8.1 (identification).** For $q \ge 2$ and $k \le n$, $\mathrm{Gr}_q(n,k) = \binom{n}{k}_q$, the $q$-Pascal coefficient of Definition 2.1.

*Proof sketch.* One shows $\prod_{i<k}(q^n-q^i)\,[n-k]_q! = q^{\binom{k}{2}}(q-1)^{k}[n]_q!$ by induction on $k$, using $q^n - q^i = q^i(q-1)[n-i]_q$; specialising $n = k$ evaluates the denominator as $q^{\binom{k}{2}}(q-1)^k[k]_q!$. Dividing and invoking exactness (Theorem 2.4) identifies the quotient with $\binom{n}{k}_q$. $\square$

**Theorem 8.2 ($\ell$-adic valuation of subspace counts).** Let $K$ be a finite field with $q$ elements, $V$ a $K$-vector space with $\dim_K V = n$, and $\ell$ an odd prime with $\ell \nmid q$. Put $d = \mathrm{ord}_\ell(q)$ and $e = v_\ell([d]_q)$. Then for $k \le n$, the number of $k$-dimensional subspaces $W \le V$ satisfies
$$v_\ell\left(\#\{W \le V : \dim W = k\}\right) = e\,c + v_\ell\!\left(\binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\right) + c\,v_\ell\!\left(\left\lfloor\frac{n-k}{d}\right\rfloor+1\right),$$
with $c$ the base-$d$ carry of $k$ and $n-k$. (At $\ell = 2$ the same holds with $d$ the order of $q$ modulo $4$.)

**Theorem 8.3 (congruence for subspace counts).** Under the same hypotheses, with no parity restriction,
$$\#\{W \le V : \dim W = k\} \equiv \binom{\lfloor n/d\rfloor}{\lfloor k/d\rfloor}\binom{n \bmod d}{k \bmod d}_{\!q} \pmod \ell.$$

**Example 8.4.** $V = \mathbb{F}_2^{6}$, $k = 3$: there are $1395$ three-dimensional subspaces, $1395 = 3^2\cdot 5\cdot 31$, and the predictions $v_3 = 2$, $v_5 = 1$, $v_{31} = 1$ of Example 3.10 are exactly the valuations of the subspace count. For $\ell = 31$: $d = \mathrm{ord}_{31}(2) = 5$, $e = v_{31}([5]_2)= v_{31}(31) = 1$, $3\bmod 5 + 3 \bmod 5 = 6 \ge 5$ so $c = 1$, and both remaining terms vanish.

These statements are exactly what one needs when studying the $\ell$-modular representation theory of $\mathrm{GL}_n(\mathbb{F}_q)$ in *non-defining characteristic* $\ell \nmid q$, where the relevant combinatorics is governed by the order $d = \mathrm{ord}_\ell(q)$ — the same $d$ that indexes the anomalous digit here. The valuation of Grassmannian cardinalities controls the $\ell$-part of permutation-module ranks and the Sylow structure of $\mathrm{GL}_n(\mathbb{F}_q)$ acting on Grassmannians.

---

## 9. Algorithms

Three computations are worth isolating.

**Algorithm A (Gaussian binomial coefficient by the $q$-Pascal recursion).** Build the rows of the $q$-Pascal triangle iteratively: row $0$ is $(1,0,\dots,0)$, and row $i+1$ has entries $R_{i+1}[j] = R_i[j-1] + q^{j}R_i[j]$. Cost: $O(n^2)$ big-integer operations; the entries have $O(nk\log q)$ bits, so the total bit cost is $O(n^{3}k\log q)$ in the worst case. Correctness is Definition 2.1; agreement with the quotient of $q$-factorials is Theorem 2.4.

**Algorithm B (valuation by the $q$-Kummer formula).** Given $q, \ell, n, k$: compute $D$ (multiplicative order of $q$ modulo $\ell$, or modulo $4$ if $\ell = 2$) by repeated multiplication, $E = v_\ell([D]_q)$ by trial division, the carry $c$ by one comparison of residues, the classical term $v_\ell\binom{N}{A}$ by counting base-$\ell$ carries (Kummer), and the correction $c\,v_\ell(B+1)$ directly. Cost: $O(\ell)$ for the order, $O(\log_\ell n)$ for the carries, and one $\gcd$-free valuation computation — polynomial in $\log n$ once $D$ and $E$ are cached, in stark contrast with the exponential cost of forming $\binom{n}{k}_q$ explicitly (its bit length is $\Theta(k(n-k)\log q)$).

**Algorithm C (residue by the mixed-radix $q$-Lucas expansion).** Reduce $n$ and $k$ modulo $D$, compute the small $q$-binomial coefficient $\binom{n \bmod D}{k \bmod D}_q$ modulo $\ell$ from the $D \times D$ block, then multiply in the classical Lucas product $\prod_i \binom{\lfloor n/D\rfloor_i}{\lfloor k/D\rfloor_i}$ over base-$\ell$ digits. Cost $O(D^2 + \log_\ell n)$ arithmetic operations modulo $\ell$. This yields $\binom{n}{k}_q \bmod \ell$ for astronomically large $n$ — e.g. $n = 10^{100}$ — where the coefficient itself cannot be written down.

Both B and C are exponentially faster than direct computation, and are the practical payoff of the theory.

---

## 10. Discussion

**One digit, and only one.** The unifying statement is that passing from $q = 1$ to general $q$ splices a single new digit, of size $d = \mathrm{ord}_\ell(q)$ and weight $e = v_\ell([d]_q)$, into the bottom of the base-$\ell$ expansion that governs the classical theory. Every result above is a facet of this: valuations become mixed-radix carry counts (Theorem 3.6); congruences become mixed-radix digit products with exactly one deformed factor (Theorem 5.9); the fractal is dilated by $d$ (Theorem 6.4); the total survivor count acquires one constant factor $d(d+1)/2$ (Theorem 6.5); the full rows are $d$-dilates of the classical ones plus $d$ initial rows (Theorem 6.7); the growth bound acquires the additive constant $e$ (Theorems 7.1, 7.2); and along multiples of $d$ the classical theory is recovered on the nose (Theorem 7.4).

**Why the correction term is unavoidable.** The term $c\,v_\ell(B+1)$ has no classical shadow, and it is easy to mistake it for slack. It is not: it comes from the extra factor $(B+1)$ that appears when the base-$d$ carry pushes the block factorial from $(A+B)!$ to $(A+B+1)!$. It vanishes on the extremal family of Theorem 7.2 (where $B+1 = \ell^{s}-1$), but it is genuinely nonzero elsewhere; for instance whenever $B + 1$ is divisible by $\ell$ and a base-$d$ carry occurs.

**Where the valuation and congruence theories part company.** The valuation theorem needs a lifting-the-exponent input and therefore feels the $2$-adic anomaly, requiring the order modulo $4$. The congruence theorem needs only that $\mathbb{Z}/\ell$ is a field, and holds at $\ell = 2$ with the naive period. This asymmetry is instructive: it is *strength* of divisibility, not divisibility itself, that is $2$-adically delicate. Consistently, the indivisibility criterion of Theorem 6.1 (a congruence statement) needs no parity hypothesis, whereas the criterion in valuation form (Theorem 7.5) carries the hypothesis $e \ge 1$.

**Sharpness of the abstractions.** The notion of regular datum is exactly right in the sense that Theorem 3.4 uses nothing else, and every concrete input — odd primes via lifting the exponent, $\ell = 2$ via the order modulo $4$ — is a separate lemma feeding the same machine. Likewise the $q$-Lucas period isolates the three facts a congruence proof consumes. The failed guesses are informative: $d - (n \bmod d)$ is *not* the residual row factor, and "the order modulo $2$" is *not* the period at $\ell = 2$.

**Relation to cyclotomic factorisations.** Behind the scenes lies the factorisation $q^m - 1 = \prod_{j \mid m}\Phi_j(q)$ into cyclotomic values. A prime $\ell \nmid q$ divides $\Phi_j(q)$ essentially only for $j = d$ and $j = d\ell^{i}$, and the regular datum is the numerical shadow of that statement. Making the connection explicit — expressing $e$ as $v_\ell(\Phi_d(q))$ and the higher structure as a Zsygmondy-type statement — is the natural next step for a more conceptual proof.

---

## 11. Future directions

* **Prime powers and $\ell$-adic limits.** Replace $v_\ell$ by congruences modulo $\ell^{r}$: is there a Granville-style $q$-analogue with a correction unit, refining Theorem 5.7 to modulus $\ell^{r}$?
* **Cyclotomic reformulation.** Prove the regular-datum property directly from $q^m - 1 = \prod_{j\mid m}\Phi_j(q)$, obtaining $e = v_\ell(\Phi_d(q))$ intrinsically and clarifying the $\ell = 2$ anomaly as the Zsygmondy exception.
* **Roots of unity and $q$ non-integral.** Everything here treats $q$ as an integer $\ge 2$. For $q$ a root of unity in a local field, or for the polynomial ring $\mathbb{Z}[q]$ with $\ell$ replaced by a cyclotomic prime, the same mixed-radix pattern should appear with $d$ replaced by the order of $q$ in a residue field.
* **Multinomials and Grassmannian analogues.** Extend to $q$-multinomial coefficients — counting flags rather than subspaces — where one expects a mixed-radix carry count for each successive step of the flag.
* **Fractal geometry of the deformed triangle.** Theorem 6.5 gives an exact self-similar total. What is the Hausdorff dimension and the exact renormalisation limit of the deformed pattern, and how does the initial $d \times d$ block deform the classical Sierpiński measure?
* **Modular representation theory.** Feed Theorems 8.2 and 8.3 into the block theory of $\mathrm{GL}_n(\mathbb{F}_q)$ in non-defining characteristic, where $d = \mathrm{ord}_\ell(q)$ already organises unipotent blocks; the valuation of Grassmannian sizes should be readable off the same digit combinatorics.
* **Effective bounds and inverse problems.** Given a target valuation $v$, characterise all $(n,k)$ with $v_\ell\binom{n}{k}_q = v$; Theorem 7.2 solves the extremal case, but the full fibre structure is open.

---

## 12. Conclusion

Kummer's carry-counting theorem survives the deformation of the integers into $q$-integers, but not unchanged. The correct statement replaces the single base $\ell$ by the mixed radix $(d,\ell,\ell,\dots)$, where $d$ is the multiplicative order of $q$ modulo $\ell$; the anomalous bottom digit carries the weight $e = v_\ell([d]_q)$ and contributes a correction term $c\,v_\ell(\lfloor(n-k)/d\rfloor+1)$; and at $\ell = 2$ the order must be taken modulo $4$. Everything classical — Lucas's congruence, Glaisher's survivor count, the Sierpiński pattern, the logarithmic growth bound and its sharpness — has an exact counterpart obtained by dilating the classical picture by $d$. Translated through the identification of Gaussian coefficients with subspace counts, the theory determines the exact power of a prime dividing the number of $k$-dimensional subspaces of a finite vector space.
