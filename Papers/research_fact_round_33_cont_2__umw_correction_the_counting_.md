# The Counting Wall for the Umans–Wang $(\alpha,\beta)$-Divisor Conjecture

**Aristotle**

*October 2026*

---

## Abstract

Umans and Wang (arXiv:2511.10851) posed the *$(\alpha,\beta)$-Divisor Conjecture*: for infinitely many $n$ there should be sets $S,T$ of positive integers, of size at most $n^\beta$ and with elements at most $e^{n^\alpha}$, whose difference set $S-T$ has the *$n$-divisor property*, meaning that every $i\in\{1,\dots,n\}$ divides some nonzero difference. The parameter point $\alpha=\beta=\tfrac13$ is the one that drives their application. We give a complete, elementary proof of the counting constraint $\alpha\ge 1-2\beta$. We prove it in a finite form, $4^{\lfloor n/2\rfloor}\le (n+1)M^{|S||T|}$, in a sharp form, $\operatorname{lcm}(1,\dots,n)\le M^{|S||T|}$, and in the asymptotic form, which is a statement about infinitely many $n$. This corrects a framing in which the boundary was taken to be $\alpha+\beta\le 1$. The correct picture has two distinct lines: the counting wall $\alpha=1-2\beta$ and the trivial line $\alpha=1-\beta+o(1)$. We prove that the trivial line is achieved by an explicit block construction. We show that the target $(\tfrac13,\tfrac13)$ lies on the wall with zero slack. We show that the sharp wall is attained exactly, with optimum $\operatorname{lcm}(1,\dots,n)+1$, when $|S|=|T|=1$. We also prove the Chinese-Remainder core of the progression lemma of Umans and Wang, and observe that its prime-hitting form is already trivial for one-term progressions, so that all of its content lies in the sizes of the parameters. Small computations support the picture: brute-force optima for $|S|=|T|=2$ lie within a factor $3$ of the wall for $n\le 10$, and random balanced sets fail to cover. The conjecture at $(\tfrac13,\tfrac13)$ remains open. We isolate it as a *balancing* problem, because the wall is essentially attained by unbalanced covers.

---

## 1. Introduction

Fix $n$. We want to "catch" every integer $1\le i\le n$ by exhibiting a multiple of $i$. One integer, $\operatorname{lcm}(1,\dots,n)$, catches all of them, but it is exponentially large in $n$. Umans and Wang ask for a cheaper certificate. The multiples should come as the pairwise differences of two small sets of moderately sized integers.

**Definition 1.1 ($n$-divisor property).** Let $S,T$ be finite sets of non-negative integers. The pair $(S,T)$ has the *$n$-divisor property* if for every integer $1\le i\le n$ there are $s\in S$ and $t\in T$ with $t<s$ and $i\mid s-t$.

Since $i\mid s-t$ if and only if $i\mid t-s$, orienting the differences positively costs nothing. Working with non-negative integers is also harmless: translating both sets by the same constant does not change any difference.

**Conjecture 1.2 ($(\alpha,\beta)$-Divisor Conjecture; Umans–Wang).** For infinitely many $n$ there exist subsets $S,T\subseteq\mathbb{Z}^+$ such that the set of pairwise differences $A=\{s-t: s\in S,\ t\in T\}$ satisfies the $n$-divisor property, and

1. all elements of $S,T$ have magnitude at most $\exp(n^\alpha)$;
2. $|S|,|T|\le n^\beta$.

In the source paper the authors note that the counting constraint is $\alpha\ge 1-2\beta$. They add: "we do not know if $\alpha=1-2\beta$ is achievable. In fact, we do not even know if $\alpha<1-\beta$ is achievable (whereas $\alpha=1-\beta+o(1)$ is trivial)." The case of interest is $\alpha=\beta=\tfrac13$, which in their work would improve an exponent from $\tfrac15$ to $\tfrac16$.

**A correction.** It is tempting to summarize the situation as "the trivial boundary is $\alpha+\beta\le 1+o(1)$". That is the wrong boundary in two ways. First, the *trivial construction* lives on the line $\alpha=1-\beta$, which is $\alpha+\beta=1$, but it is an *upper* (achievability) line, not a constraint. Second, the *counting obstruction* is the different line $\alpha+2\beta=1$. The factor $2$ reflects the $|S|\cdot|T|$ differences produced by two sets. At $\beta=\tfrac13$ the two lines give $\alpha=\tfrac23$ (trivial) and $\alpha=\tfrac13$ (wall), and the target $\alpha=\tfrac13$ is exactly on the wall.

**Contributions.**

1. A self-contained proof of the counting wall in three strengths (Theorems 3.3, 3.5 and 4.3):
$$\operatorname{lcm}(1,\dots,n)\le M^{|S||T|},\qquad 4^{\lfloor n/2\rfloor}\le (n+1)M^{|S||T|},\qquad \alpha\ge 1-2\beta.$$
2. The trivial block construction achieving $\alpha=1-\beta+o(1)$ (Theorem 5.1). It attains the wall up to a factor $\log n$ when $|T|=1$.
3. Zero slack at $(\tfrac13,\tfrac13)$ (Corollary 4.4).
4. Exact optimality for one-element sets: the least possible maximum is $\operatorname{lcm}(1,\dots,n)+1$ (Theorem 6.2).
5. The Chinese-Remainder core of the Umans–Wang progression lemma (Theorem 7.1), with the observation that its prime-hitting form is trivial (Corollary 7.2 and Remark 7.3).
6. Numerical experiments (Section 8) and a list of open problems (Section 10).

---

## 2. Notation and two classical facts

Write $[n]=\{1,\dots,n\}$ and $L_n=\operatorname{lcm}(1,\dots,n)$, with $L_0=1$. For finite $S,T\subseteq\mathbb{Z}_{\ge0}$ define the *difference product*
$$
D(S,T)=\prod_{\substack{s\in S,\ t\in T\\ t<s}} (s-t).
$$
This is a product of positive integers, so $D(S,T)\ge1$.

**Fact 2.1 (Legendre / Kummer bound).** For every prime $p$ and $m\ge1$, if $p^e$ exactly divides $\binom{2m}{m}$, then $p^e\le 2m$.

*Sketch.* By Legendre's formula, $e=\sum_{j\ge1}\big(\lfloor 2m/p^j\rfloor-2\lfloor m/p^j\rfloor\big)$. Each summand is $0$ or $1$, and it is $0$ once $p^j>2m$. Hence $e\le\max\{j:p^j\le 2m\}$. $\square$

**Fact 2.2.** For every $m\ge0$, $4^m\le(2m+1)\binom{2m}{m}$.

*Proof.* $4^m=\sum_{k=0}^{2m}\binom{2m}{k}$ is a sum of $2m+1$ terms, and the middle one is the largest. $\square$

---

## 3. The finite counting wall

**Lemma 3.1 (lcm divides the difference product).** If $(S,T)$ has the $n$-divisor property, then $L_n\mid D(S,T)$.

*Proof.* For each $i\in[n]$ choose $s>t$ with $i\mid s-t$. Then $s-t$ is one of the factors of $D(S,T)$, so $i\mid D(S,T)$. Since every $i\in[n]$ divides $D(S,T)$, so does their least common multiple. $\square$

This uses all of $L_n$. Every *prime power* $p^k\le n$ is forced, not only every prime. So the bound is strictly stronger than the "primorial wall" $\prod_{p\le n}p\le D(S,T)$.

**Lemma 3.2 (size of the difference product).** If $M\ge1$ and every element of $S$ is at most $M$, then $D(S,T)\le M^{|S|\cdot|T|}$.

*Proof.* Each factor satisfies $0<s-t\le s\le M$, and there are at most $|S\times T|=|S||T|$ factors. $\square$

Only $S$ needs to be bounded here. A bound on the elements of $T$ is not used.

**Theorem 3.3 (lcm wall).** If $(S,T)$ has the $n$-divisor property, $M\ge 1$, and every element of $S$ is at most $M$, then
$$
L_n\;\le\;M^{|S|\cdot|T|}.
$$

*Proof.* By Lemma 3.1 and $D(S,T)\ge1$ we get $L_n\le D(S,T)$. Now apply Lemma 3.2. $\square$

To turn this into an explicit exponential bound we need $L_n$ to be exponentially large. We use the elementary route through central binomial coefficients.

**Lemma 3.4 (central binomial divisibility).** For every $m\ge0$, $\binom{2m}{m}\mid L_{2m}$.

*Proof.* The case $m=0$ is trivial. For $m\ge1$, compare $p$-adic valuations. If $p^e\,\|\,\binom{2m}{m}$, then $p^e\le 2m$ by Fact 2.1, so $p^e$ is one of the numbers whose lcm is $L_{2m}$, and therefore $p^e\mid L_{2m}$. Since this holds for every prime $p$, the divisibility follows. $\square$

**Theorem 3.5 (finite counting wall).** If $(S,T)$ has the $n$-divisor property, $M\ge 1$, and every element of $S$ is at most $M$, then
$$
4^{\lfloor n/2\rfloor}\;\le\;(n+1)\,M^{|S|\cdot|T|}.
$$

*Proof.* Let $m=\lfloor n/2\rfloor$. By Fact 2.2, $4^m\le(2m+1)\binom{2m}{m}$. Since $2m\le n$, we have $L_{2m}\mid L_n$. By Lemma 3.4 and Lemma 3.1,
$$
\binom{2m}{m}\ \Big|\ L_{2m}\ \Big|\ L_n\ \Big|\ D(S,T),
$$
so $\binom{2m}{m}\le D(S,T)\le M^{|S||T|}$ by Lemma 3.2. Finally $2m+1\le n+1$. $\square$

---

## 4. The asymptotic wall $\alpha\ge 1-2\beta$

**Theorem 4.1 (logarithmic wall).** Let $n\ge1$ and $\alpha,\beta\in\mathbb{R}$. Suppose $(S,T)$ has the $n$-divisor property, every element of $S$ is at most $e^{n^\alpha}$, and $|S|,|T|\le n^\beta$. Then
$$
(n-1)\log 2\;\le\;\log(n+1)+n^{\alpha+2\beta}.
$$

*Proof.* Put $X=e^{n^\alpha}\ge1$ and $M=\lfloor X\rfloor\ge1$. Every element of $S$ is an integer at most $X$, hence at most $M$. By Theorem 3.5, $4^{\lfloor n/2\rfloor}\le(n+1)M^{k}\le (n+1)X^k$, where $k=|S||T|$. Taking logarithms,
$$
2\lfloor n/2\rfloor\log 2\le \log(n+1)+k\,n^\alpha .
$$
Now $n-1\le 2\lfloor n/2\rfloor$ and $k\le n^\beta\cdot n^\beta=n^{2\beta}$, so $k\,n^\alpha\le n^{\alpha+2\beta}$. $\square$

**Lemma 4.2 (linear growth beats sublinear growth).** If $\gamma<1$, then for all sufficiently large real $x$,
$$
\log(x+1)+x^\gamma+\log 2\;<\;x\log 2 .
$$

*Proof.* Each of $\log(x+1)$, $x^\gamma$ and the constant $\log 2$ is $o(x)$ as $x\to\infty$. For $x^\gamma$ this is because $x^\gamma/x=x^{-(1-\gamma)}\to0$, and for $\log(x+1)$ it is the standard fact that $\log x=o(x)$. So their sum is eventually less than $\tfrac12 x\log 2$, and in particular less than $x\log2$. $\square$

**Theorem 4.3 (the corrected Umans–Wang counting constraint).** Let $\alpha,\beta\in\mathbb{R}$. Suppose that for infinitely many $n$ there are finite $S,T\subseteq\mathbb{Z}_{\ge0}$ with the $n$-divisor property, all elements of $S$ at most $e^{n^\alpha}$, and $|S|,|T|\le n^\beta$. Then
$$
\alpha\;\ge\;1-2\beta .
$$

*Proof.* Suppose instead that $\gamma:=\alpha+2\beta<1$. By Lemma 4.2, for every sufficiently large integer $n$,
$$
\log(n+1)+n^{\gamma}<(n-1)\log 2 .
$$
Since the hypothesis holds for infinitely many $n$, it holds for some $n\ge1$ that is also this large. For that $n$, Theorem 4.1 gives $(n-1)\log2\le\log(n+1)+n^\gamma$, a contradiction. $\square$

So the boundary is the line $\alpha+2\beta=1$. It is *not* $\alpha+\beta=1$, and the inequality points the other way from "$\alpha+\beta\le1$".

**Corollary 4.4 (zero slack at the target).** We have $1-2\cdot\tfrac13=\tfrac13$ and $1-\tfrac13=\tfrac23$. For every $\alpha<\tfrac13$, Conjecture 1.2 fails with $\beta=\tfrac13$: for all sufficiently large $n$ there are no $S,T$ with $|S|,|T|\le n^{1/3}$, elements of $S$ at most $e^{n^\alpha}$, and the $n$-divisor property.

*Proof.* The arithmetic is immediate. The final claim is the contrapositive of Theorem 4.3 with $\beta=\tfrac13$. $\square$

The target $(\tfrac13,\tfrac13)$ therefore lies *on* the counting wall, while the trivial construction lies at $\alpha=\tfrac23$. In the setting of Umans and Wang, this explains why the exponent $\tfrac16$ obtained from the conjecture is a floor for the method. It sits exactly on the wall, so no difference-set construction of this type can beat it.

**Remark 4.5 (numerical tightness).** At $\alpha+2\beta=1$ the logarithmic wall reads $(n-1)\log 2\le\log(n+1)+n$, which always holds; for example $692.4\le1006.9$ at $n=1000$. At $\alpha+2\beta=0.9$ it reads $(n-1)\log 2\le\log(n+1)+n^{0.9}$, which already fails at $n=100$ ($68.6>67.7$) and fails badly at $n=10^4$ ($6930.8>3990.3$).

---

## 5. The trivial line $\alpha=1-\beta+o(1)$

For $n,b\ge1$ and $j\ge0$, let $B_j=\{i\in[n]:\lfloor (i-1)/b\rfloor=j\}$ be the $j$-th block of length $b$.

**Theorem 5.1 (trivial block cover).** Let $n,b\ge 1$. Put
$$
S=\Big\{\,1+\prod_{i\in B_j} i\ :\ 0\le j<\lceil n/b\rceil\Big\},\qquad T=\{1\}.
$$
Then $(S,T)$ has the $n$-divisor property, $|S|\le\lceil n/b\rceil$, $|T|=1$, and every $s\in S$ satisfies $1\le s\le 1+n^b$.

*Proof.* For $i\in[n]$ let $j=\lfloor(i-1)/b\rfloor$. Then $j<\lceil n/b\rceil$ and $i\in B_j$. The element $s=1+\prod_{k\in B_j}k$ lies in $S$, it is greater than $1$, and $s-1=\prod_{k\in B_j}k$ is divisible by $i$. Each block lies inside an interval of $b$ consecutive integers, so $|B_j|\le b$, and each of its elements is at most $n$. Hence $\prod_{k\in B_j}k\le n^{b}$. $\square$

**Corollary 5.2.** Taking $b=\lceil n^{1-\beta}\rceil$ gives $|S|\le n^\beta+O(1)$, $|T|=1$, and $\log\max S\le n^{1-\beta}\log n+O(\log n)$. So Conjecture 1.2 holds with $\alpha=1-\beta+o(1)$ for every $\beta\in(0,1)$.

**The wall is essentially tight for unbalanced covers.** The wall of Theorem 3.5 only involves the quantity $|S|\cdot|T|\cdot\log M$, which must be at least about $n\log 2$. For the trivial cover,
$$
|S|\cdot|T|\cdot\log M\;\approx\;\frac nb\cdot1\cdot b\log n=n\log n,
$$
which exceeds the requirement by only a factor of order $\log n$. The trivial cover therefore *does* reach the wall, but in the unbalanced regime $|T|=1$, where $|S||T|=n^\beta$. Conjecture 1.2 demands balanced sets with $|S||T|=n^{2\beta}$. In that regime the differences are highly dependent. A table of differences $(s-t)_{s\in S,t\in T}$ has rank one in the additive sense, since
$$
(s_1-t_1)-(s_1-t_2)=(s_2-t_1)-(s_2-t_2),
$$
so its $|S||T|$ entries carry only $|S|+|T|-1$ degrees of freedom. **The entire open content of the conjecture at $(\tfrac13,\tfrac13)$ is a balancing question:** can multiplicative covering exploit a rank-one additive family as efficiently as a family of free integers?

---

## 6. Exact optimality for one-element sets

**Lemma 6.1.** For $n\ge1$ and integers $s,t$, the pair $(\{s\},\{t\})$ has the $n$-divisor property if and only if $t<s$ and $L_n\mid s-t$.

*Proof.* If the property holds, then $i=1$ forces $t<s$, and each $i\in[n]$ divides the only difference $s-t$, hence so does $L_n$. Conversely, every $i\in[n]$ divides $L_n$, which divides $s-t>0$. $\square$

**Theorem 6.2 (singleton optimum).** Let $n\ge1$. The pair $(\{L_n+1\},\{1\})$ has the $n$-divisor property. If $t\ge1$ and $(\{s\},\{t\})$ has the $n$-divisor property, then $s\ge L_n+1$.

*Proof.* The first claim follows from Lemma 6.1, since $(L_n+1)-1=L_n$. For the second, Lemma 6.1 gives $L_n\mid s-t$ with $s-t>0$, so $s-t\ge L_n$ and $s\ge L_n+t\ge L_n+1$. $\square$

So the sharp wall $L_n\le M^{|S||T|}$ is attained up to the additive $+1$ when $|S|=|T|=1$.

---

## 7. The progression lemma and its Chinese-Remainder core

Umans and Wang use the following construction (their Lemma 6.2). Let $U$ be the product of the primes in $[n]$. Given a factorization $U=U_1\cdots U_\ell$, let $T_i$ be the inverse of $U/U_i$ modulo $U_i$, and put $V_i=(U/U_i)T_i$. Then there is an arithmetic progression $A=\{b+ic:1\le i\le\ell\}$ containing multiples of each prime in $[n]$ in the prescribed pattern if and only if $c\cdot\big(\sum_i i V_i\big)+b\equiv0\pmod U$. The existence part rests on the following statement.

**Theorem 7.1 (CRT progression).** Let $U_0,\dots,U_{\ell-1}$ be nonzero and pairwise coprime, and let $c$ be any integer. Then there is $b\ge0$ with
$$
U_i\ \mid\ b+(i+1)c\qquad\text{for all }0\le i<\ell .
$$

*Proof.* By the Chinese Remainder Theorem there is $b$ with $b\equiv-(i+1)c\pmod{U_i}$ for every $i$. $\square$

**Corollary 7.2 (prime-hitting form).** If every prime $p\le n$ divides one of the pairwise coprime blocks $U_0,\dots,U_{\ell-1}$, then for every step $c$ there is an $\ell$-term progression $b+c,\dots,b+\ell c$ that contains a multiple of every prime $p\le n$.

*Proof.* Take $b$ from Theorem 7.1. If $p\mid U_i$, then $p\mid U_i\mid b+(i+1)c$. $\square$

**Remark 7.3 (why the prime-hitting form is not evidence).** Corollary 7.2 already holds with $\ell=1$: take $U_0=U$, and the single term $b+c$ can be any multiple of $U$. So exhibiting a two-term progression that hits every prime up to $n$ is cheap. For instance, splitting the primes up to $10$ as $\{2,5\}\cup\{3,7\}$ gives the progression $20,21$, and similar two-term progressions exist for every $n$. This is *not* the divisor property. That property requires every $i\le n$, prime powers included, to divide a *difference* of two small sets. The whole content of the Umans–Wang use of the lemma lies in the *sizes* of $b$ and $c$, which the existence statement does not control.

The paper also proves a limitation that applies to generic inputs (their Lemma 6.3):

> Suppose for all positive integers $A_1,\dots,A_\ell$ with $A_i\le M$ there exist $A'_1,\dots,A'_{\ell'}$ in arithmetic progression, $A'_j\le M'$, such that for all $i$ there exists $j$ with $A_i\mid A'_j$. Then either $\ell'\ge M^{\Omega(1)}$ or $M'\ge M^{\log\log M}$.

This rules out building the covering from an *arbitrary* partition of $[n]$ into blocks. Only non-generic, structured factorizations of the smooth integer $U$ can escape it.

---

## 8. Computations

All computations below are small exhaustive or randomized searches. They illustrate the theorems; they are not part of any proof.

**8.1 The walls on explicit covers.** For the trivial cover with $(n,b)=(10,3),(20,4),(30,5)$ we get $\max S=505$, $116281$ and $17100721$, with $|S|=4,5,6$. In every case $L_n\mid D(S,T)$, and both walls hold. For example, at $n=30$ we have $\log_2L_{30}\approx41.1$ against $|S||T|\log_2 M\approx144.2$. The divisibility $\binom{2m}{m}\mid L_{2m}$ was checked for $m\le40$.

**8.2 One-element sets.** Exhaustive search confirms Theorem 6.2 for $n\le10$. The optima are $2,3,7,13,61,61,421,841,2521,2521$.

**8.3 Two-element sets.** For $|S|=|T|=2$ (positive integers), the wall predicts $M\ge L_n^{1/4}$. Exhaustive search gives:

| $n$ | optimal $M$ | witness $S$ | witness $T$ | $L_n^{1/4}$ | ratio |
|---|---|---|---|---|---|
| 5 | 6 | $\{4,6\}$ | $\{1,2\}$ | 2.78 | 2.16 |
| 6 | 7 | $\{5,7\}$ | $\{1,2\}$ | 2.78 | 2.52 |
| 7 | 8 | $\{6,8\}$ | $\{1,2\}$ | 4.53 | 1.77 |
| 8 | 9 | $\{7,9\}$ | $\{1,2\}$ | 5.38 | 1.67 |
| 9 | 19 | $\{8,19\}$ | $\{1,3\}$ | 7.09 | 2.68 |
| 10 | 21 | $\{17,21\}$ | $\{1,3\}$ | 7.09 | 2.96 |

For $2\le n\le10$ the ratio stays between $1.67$ and $2.96$.

**8.4 Exponents of the trivial cover.** With $b=n^{2/3}$, the ratio $\log\max S/(n^{2/3}\log n)$ is $0.969$, $0.990$ and $0.996$ at $n=64$, $512$ and $4096$, with $|S|=n^{1/3}$ exactly. This confirms $\alpha=\tfrac23+o(1)$ at $\beta=\tfrac13$.

**8.5 Random balanced sets.** Drawing $S,T$ uniformly with $|S|=|T|\approx n^{1/3}$ and elements at most $e^{n^{1/3}}$, the best fraction of $[n]$ covered over $20$ trials was $0.39$, $0.34$, $0.28$ and $0.27$ for $n=64$, $128$, $256$ and $512$. No trial produced a full cover, and greedy set-cover searches in the same regime also fail. This is expected. On the wall there is no room for waste, and random differences rarely have many small divisors. It is not evidence against the conjecture. It only shows that a successful construction must be structured.

---

## 9. Discussion

The picture that emerges is simple and rigid.

* The counting wall $\alpha+2\beta\ge1$ is a theorem, with a proof that uses nothing beyond Legendre's formula and the binomial theorem.
* The target $(\tfrac13,\tfrac13)$ lies on the wall with zero slack.
* The trivial construction lies on the line $\alpha=1-\beta$. It *matches the wall* up to $\log n$ in the unbalanced regime $|T|=1$, and so it misses the conjecture purely because of imbalance.
* The progression lemma provides an arithmetic building block whose difficulty lies entirely in the sizes of its parameters. By the paper's obstruction lemma, only structured factorizations can work.

The precise open problem is the following. *For infinitely many $n$, construct structured sets $S,T$ with $|S|,|T|\le n^{1/3}$ and elements at most $e^{n^{1/3}}$ whose difference set divide-covers $[n]$.*

---

## 10. Future directions

**10.1 Balanced–unbalanced transfer.** *Conjecture.* For every $\varepsilon>0$ and infinitely many $n$ there is a cover with $|S|=|T|\le n^{1/3}$ and $\log\max S\le n^{1/3+\varepsilon}$, that is, Conjecture 1.2 up to $n^{\varepsilon}$. Since unbalanced covers already attain the wall up to $\log n$, the whole conjecture is a balancing question.

**10.2 Two-dimensional progression grids.** *Conjecture.* Take $S=\{b+ic\}$ and $T=\{-jc'\}$, shifted to be positive. For suitable smooth $c,c'$, every prime power $\le n$ divides some $b+ic+jc'$, with $b,c,c'\le\exp(n^{1/3+o(1)})$. A progression minus a progression is a two-dimensional lattice box. The Chinese Remainder Theorem solves the congruences along each row independently (Theorem 7.1), and the obstruction lemma rules out the one-dimensional version, which makes the box the natural next object.

**10.3 Prime-power refinement of the wall.** *Conjecture.* For $|S|=|T|=2$ the sharp wall is tight up to a constant factor, that is, $\min M\le C\cdot L_n^{1/4}$ for all $n$. The case $|S|=|T|=1$ is exactly tight (Theorem 6.2), and the data of §8.3 stay within a factor $3$. A smarter search could test $n\le30$.

**10.4 An additive-rank wall?** *Conjecture.* No counting wall stronger than $\alpha+2\beta\ge1$ arises from the rank-one structure of $S-T$ alone. For every $\beta$ there should be (possibly non-explicit) $S,T$ with $\alpha=1-2\beta+o(1)$, for example via a probabilistic construction over smooth moduli. The point is that divisibility constraints for different prime powers are nearly independent across residues, so the additive dependencies among differences need not cost anything in the exponent.

---

## References

- Umans and Wang, *arXiv:2511.10851* (2025). Source of Conjecture 1.2, the counting constraint $\alpha\ge1-2\beta$, the progression lemma (Lemma 6.2) and the obstruction lemma (Lemma 6.3).
- Classical: Legendre's formula for $p$-adic valuations of factorials; the binomial theorem.
