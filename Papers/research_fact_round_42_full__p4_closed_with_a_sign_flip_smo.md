# The Split Set Decides: Factor-Base Size, Smooth Yield, and the Direction of the Linear-Algebra Bound in the Single-Polynomial Quadratic Sieve

**Aristotle**

*October 2026*

---

## Abstract

We study a design proposal for the single-polynomial quadratic sieve (QS): shrink the effective factor base, of size $Q$, so that fewer relations are needed for the linear-algebra step. We show that the proposal is misdirected on three independent grounds.

**(i) $Q$ is not a free parameter.** A prime $r \nmid N$ divides some sieve value $x^2-N$ if and only if the Legendre symbol $(N/r)$ equals $+1$. So the set of primes $\le B$ the sieve can ever reach is exactly the admissible set (ramified $\cup$ split), and $Q(N,B)=\pi(B)-\#\{\text{inert } r\le B\}$ is determined by $N$ and $B$.

**(ii) Smooth yield is governed by $Q$, not by $\pi(B)$.** For an arbitrary prime set $S$ we prove the exponential sandwich $2^{|S|}\le\Psi_S(X)\le(\lfloor\log_2X\rfloor+1)^{|S|}$ (the lower bound holds when $\prod S\le X$). We prove the multiplicative step $\Psi_{S\cup\{p\}}(X)\ge\Psi_S(X)+\Psi_S(\lfloor X/p\rfloor)$. We also prove the sieve-yield ceiling $\#\{x\in[a,b]: x^2-N\ \text{is } B\text{-smooth}\}\le(\lfloor\log_2(b^2-N)\rfloor+1)^{Q(N,B)}$.

**(iii) Paid work falls as $Q$ grows.** In the cost model $\mathrm{work}(S)=(|S|+1)/\Psi_S(X)$, adding a prime $p$ to $S$ does not raise the cost as soon as $(|S|+1)\,\Psi_S(\lfloor X/p\rfloor)\ge\Psi_S(X)$.

Empirically, the sieve positions actually examined fall monotonically in $Q$, by factors of $2.4\times$ to $13.1\times$. At matched $u=\log X/\log B$, the measured smooth density correlates with $Q/\pi(B)$ at $+0.882$ and with $\log\rho(u)$ at only $+0.029$.

We also settle a disputed direction in the linear-algebra bound. We prove the exact identity $k_{\rm success}=\operatorname{rank}(\text{prefix}_{k_{\rm success}})+1$, which shows $k_{\rm success}\le\operatorname{rank}(M)+1\le Q+1$ for the full collected matrix $M$, and that both bounds are sharp.

We characterize which integer test matrices can detect a rank routine that silently computes over $\mathbb{Q}$ instead of $\mathbb{F}_2$: exactly those with nonzero even determinant. We prove the error is one-sided, $\operatorname{rank}_{\mathbb{F}_2}\le\operatorname{rank}_{\mathbb{Q}}$.

Finally, we prove the algebraic core of the large-prime variant. With $a$ full relations, $b$ partial relations and $D$ distinct large primes, $Q<a+(b-D)$ already forces a congruence of squares in the same $\mathbb{F}_2^Q$ column space. This reduces the cost question to a birthday-type collision count.

---

## 1. Introduction

The quadratic sieve factors an odd composite $N$ by producing a congruence $X^2\equiv Y^2\pmod N$ with $X\not\equiv\pm Y$. Its single-polynomial form has two phases:

1. **Relation collection.** Scan positions $x\ge\lceil\sqrt N\rceil$ and keep those for which $f(x)=x^2-N$ is $B$-smooth, meaning all its prime factors are $\le B$.
2. **Linear algebra.** Reduce the exponent vectors of the relations modulo 2 and find a nonempty subset summing to $0$ in $\mathbb{F}_2^{Q}$. Here $Q$ is the number of primes that can occur.

A dependency is guaranteed once more than $Q$ relations are held. A tempting optimization follows. If $Q$ could be lowered, fewer relations would be needed and the matrix would be smaller. We call this proposal **P4**. In a preceding round of experiments, the ratio $Q/\pi(B)$ correlated with the number of relations needed at $+0.77$, which seemed to support it.

This paper shows that P4 moves the wrong term. Our contributions are:

* **Split-set forcing (§3).** The columns of the relation matrix are fixed by quadratic residuosity. They are exactly the primes $r\le B$ for which $N$ is a square modulo $r$.
* **Smooth counts over prime sets (§4).** Exponential upper and lower bounds on $\Psi_S(X)$ in terms of $|S|$, a multiplicative step, and a yield ceiling with exponent $Q(N,B)$.
* **The sign-flip criterion (§5).** One more column costs $+1$ in the relation target and gains multiplicatively in yield. We give a checkable sufficient condition for the cost to fall, and report experiments showing paid work decreasing by $2.4\times$–$13.1\times$ as $Q$ increases.
* **Dickman is blind to $Q$ (§6).** At fixed $u$, Dickman's $\rho(u)$ cannot distinguish moduli. The split ratio $Q/\pi(B)$ can.
* **The direction of the rank bound (§7).** An exact prefix-rank identity and sharpness of $k_{\rm success}\le Q+1$.
* **The $\mathbb{F}_2$-rank trap (§8).** A complete criterion for discriminating test matrices, and one-sidedness of the error.
* **Large primes (§9).** The partial-relation threshold $a+(b-D)>Q$.
* **Methodology (§10).** Instrument faults, mutation testing, and a data-integrity correction.

No new factoring algorithm results. The contribution is a corrected map of which parameters are real levers.

---

## 2. Setting and notation

Throughout, $N$ is a positive integer (in applications an odd composite that is not a perfect square), $B\ge 2$ is the smoothness bound, and $\pi(B)$ is the number of primes $\le B$. The **factor base** is the set $\mathcal{P}_B=\{p\le B: p\text{ prime}\}$.

**Definition 2.1 (sieve value).** For $x\in\mathbb{Z}$, the sieve value is $f(x)=x^2-N$.

**Definition 2.2 (admissible, ramified, split, inert).** A prime $r$ is *admissible for $N$* if $N$ is a square modulo $r$, that is, $N\equiv y^2\pmod r$ for some $y$. An admissible prime with $r\mid N$ is *ramified*. An admissible prime with $r\nmid N$ (equivalently, Legendre symbol $(N/r)=+1$) is *split*. A non-admissible prime is *inert*. We write
$$\mathcal{A}(N,B)=\{r\in\mathcal{P}_B : N \text{ is a square mod } r\},\qquad Q(N,B)=|\mathcal{A}(N,B)|.$$
For $r=2$ every residue is a square, so $2$ is always admissible.

**Definition 2.3 (sieve-reachable primes).** $\mathcal{R}(N,B)=\{r\in\mathcal{P}_B: r\mid f(x)\text{ for some } x\in\mathbb{Z}\}$.

**Definition 2.4 (smooth counts over a prime set).** For a finite set $S$ of primes and $X\ge 0$,
$$\Psi_S(X)=\#\{1\le n\le X:\ \text{every prime factor of } n \text{ lies in } S\}.$$
In particular $\Psi_{\mathcal{P}_B}(X)=\Psi(X,B)$ is the classical count of $B$-smooth integers.

**Definition 2.5 (sieve yield).** For $a\le b$, $\mathrm{yield}(N,B;a,b)=\#\{x\in[a,b]: f(x)\ \text{is } B\text{-smooth}\}$.

**Definition 2.6 (model work).** For a prime set $S$ with $\Psi_S(X)>0$,
$$\mathrm{work}(S;X)=\frac{|S|+1}{\Psi_S(X)}.$$
This is the number of candidates of size $\le X$ examined per guaranteed dependency, under the idealization that the sieve values behave like the integers in $[1,X]$.

**Definition 2.7 (first dependency).** Let $v_0,v_1,v_2,\dots$ be vectors in a finite-dimensional vector space $V$ over a field $K$. For $k\ge 0$ write $\mathrm{pre}_k=(v_0,\dots,v_{k-1})$ and $\operatorname{rk}(k)=\dim\operatorname{span}(\mathrm{pre}_k)$. Define $k_{\rm success}$ as the least $k$ such that $\mathrm{pre}_k$ is linearly dependent. Such a $k$ exists because any $\dim V+1$ vectors are dependent.

---

## 3. Split-set forcing: $Q$ is fixed by the polynomial

**Theorem 3.1 (sieve divisibility forces a split prime).** Let $r$ be prime with $r\nmid N$. If $r\mid x^2-N$ for some integer $x$, then $(N/r)=+1$.

*Proof.* From $r\mid x^2-N$ we get $x^2\equiv N\pmod r$, so $N$ is a square modulo $r$, and it is nonzero modulo $r$ because $r\nmid N$. By definition of the Legendre symbol (Euler's criterion for odd $r$; trivially for $r=2$), $(N/r)=+1$. $\square$

**Theorem 3.2 (the factor base is the split set).** For every $N$ and $B$, $\mathcal{R}(N,B)=\mathcal{A}(N,B)$.

*Proof.* ($\subseteq$) If $r\mid x^2-N$ then $N\equiv x^2\pmod r$. ($\supseteq$) If $N\equiv y^2\pmod r$, take $x=y$: then $r\mid y^2-N$. $\square$

So a prime outside $\mathcal{A}(N,B)$ is never hit by the sieve, and every prime inside is hit, periodically with period $r$.

**Theorem 3.3 (ramified $\cup$ split decomposition).**
$$\mathcal{A}(N,B)=\{r\in\mathcal{P}_B: r\mid N\}\ \cup\ \{r\in\mathcal{P}_B: (N/r)=+1\}.$$

*Proof.* If $r\mid N$ then $N\equiv 0=0^2$. If $r\nmid N$, then $N$ is a square mod $r$ if and only if $(N/r)=+1$. $\square$

**Corollary 3.4 (smoothness is smoothness over the split set).** If $v=x^2-N>0$, then $v$ is $B$-smooth if and only if every prime factor of $v$ lies in $\mathcal{A}(N,B)$.

*Proof.* Every prime factor $r$ of $v$ divides a sieve value, hence lies in $\mathcal{A}(N,\infty)$ by Theorem 3.2. It lies in $\mathcal{P}_B$ exactly when $r\le B$. $\square$

**Corollary 3.5 (exact deficit).** $Q(N,B)+\#\{r\in\mathcal{P}_B:\ r \text{ inert}\}=\pi(B)$. In particular $Q(N,B)\le\pi(B)$.

The columns of the $\mathbb{F}_2$ relation matrix are therefore pinned to $\mathcal{A}(N,B)$. Short of changing $B$ or the polynomial, no design choice can enlarge the column set. The only way to make it smaller is to throw away admissible primes on purpose, and §5 shows that this is counterproductive.

**Example 3.6.** Let $N=103\,764\,863$ and $x=10188$. Then $x^2-N=30\,481=11\cdot17\cdot163$. Theorem 3.1 predicts, and direct computation confirms, $(N/11)=(N/17)=(N/163)=+1$. For this $N$:

| $B$ | $\pi(B)$ | $Q(N,B)$ | inert primes $\le B$ |
|---:|---:|---:|---:|
| 100 | 25 | 13 | 12 |
| 500 | 95 | 49 | 46 |
| 2000 | 303 | 133 | 170 |

In a real single-polynomial sieve run, all $2\,215$ of $2\,215$ smooth values found had prime support inside the split set, as Theorem 3.2 requires.

**Remark 3.7 (the CRT premise).** A related proposal aimed to control a fraction of the factor base by working modulo a product $R^\#=\prod_{p\le R}p$ via the Chinese Remainder Theorem. For this to be meaningful we need $\theta(R)=\sum_{p\le R}\log p<\ln N$. Since $\theta(R)\sim R$, this forces $R=O(\ln N)$. Hence $\pi(R)/\pi(B)\to0$ for any factor-base bound $B$ growing faster than $\ln N$, which covers every regime of interest. The premise was also excluded by exhaustive enumeration at experimental sizes. We regard it as closed.

---

## 4. Smooth counts over a prime set

**Lemma 4.1 (monotonicity).** If $S\subseteq T$ then $\Psi_S(X)\le\Psi_T(X)$. $\square$

**Proposition 4.2 (multiplicative step).** Let $p$ be a prime with $p\notin S$. Then
$$\Psi_{S\cup\{p\}}(X)\ \ge\ \Psi_S(X)+\Psi_S(\lfloor X/p\rfloor).$$

*Proof.* Let $\mathcal{S}(Y)$ denote the $S$-smooth integers in $[1,Y]$. Map $m\mapsto pm$ from $\mathcal{S}(\lfloor X/p\rfloor)$ into $[1,X]$. The map is injective, and its images are $(S\cup\{p\})$-smooth. They are divisible by $p\notin S$, so they are disjoint from $\mathcal{S}(X)$. Hence $\mathcal{S}(X)$ and $p\cdot\mathcal{S}(\lfloor X/p\rfloor)$ are disjoint subsets of the $(S\cup\{p\})$-smooth integers in $[1,X]$. $\square$

**Proposition 4.3 (exponential floor).** If $S$ consists of primes and $\prod_{p\in S}p\le X$, then $2^{|S|}\le\Psi_S(X)$.

*Proof.* The $2^{|S|}$ square-free products $\prod_{p\in T}p$, for $T\subseteq S$, are distinct by unique factorization. Each is at most $\prod_{p\in S}p\le X$, and each is $S$-smooth. $\square$

**Proposition 4.4 (exponential ceiling).** For every finite prime set $S$ and $X\ge1$,
$$\Psi_S(X)\ \le\ (\lfloor\log_2X\rfloor+1)^{|S|}.$$

*Proof.* An $S$-smooth $n\le X$ is $\prod_{p\in S}p^{e_p}$ with $2^{e_p}\le p^{e_p}\le X$, so $0\le e_p\le\lfloor\log_2X\rfloor$. By unique factorization, $n\mapsto(e_p)_{p\in S}$ is injective into a set of size $(\lfloor\log_2X\rfloor+1)^{|S|}$. $\square$

At a fixed value size $X$ (hence fixed $u$), $\Psi_S(X)$ is therefore squeezed between two functions exponential in $|S|$. The base changes between the two bounds; the exponent is always the size of the prime set.

**Theorem 4.5 (yield ceiling governed by $Q$).** Let $a\le b$ with $a^2>N$. Then
$$\mathrm{yield}(N,B;a,b)\ \le\ \Psi_{\mathcal{A}(N,B)}(b^2-N)\ \le\ \bigl(\lfloor\log_2(b^2-N)\rfloor+1\bigr)^{Q(N,B)}.$$

*Proof.* The map $x\mapsto x^2-N$ is injective on $[a,b]\subset\mathbb{Z}_{>0}$, and its values lie in $[1,b^2-N]$ because $a^2>N$. By Corollary 3.4 a $B$-smooth value has all its prime factors in $\mathcal{A}(N,B)$, so it is counted by $\Psi_{\mathcal{A}(N,B)}(b^2-N)$. The second inequality is Proposition 4.4. $\square$

**Remark 4.6.** Take two moduli $N_1,N_2$ of the same size, sieved with the same $B$ over the same window, so that $u$ is the same. Their ceilings differ by the factor $(\lfloor\log_2 X\rfloor+1)^{Q(N_1,B)-Q(N_2,B)}$. Because $Q/\pi(B)$ fluctuates around $1/2$ from one modulus to the next, this factor can be very large. This is the structural shadow of the empirical finding in §6.

---

## 5. The sign-flip criterion: paid work decreases in $Q$

**Theorem 5.1 (criterion).** Let $p\notin S$ with $\Psi_S(X)>0$, and write $S'=S\cup\{p\}$. Then
$$\mathrm{work}(S';X)\le\mathrm{work}(S;X)\iff \Psi_S(X)\ \le\ (|S|+1)\bigl(\Psi_{S'}(X)-\Psi_S(X)\bigr).$$

*Proof.* Since $|S'|=|S|+1$ and both denominators are positive, the inequality $\frac{|S|+2}{\Psi_{S'}}\le\frac{|S|+1}{\Psi_S}$ is equivalent to $(|S|+2)\Psi_S\le(|S|+1)\Psi_{S'}$. Rearranging gives $\Psi_S\le(|S|+1)(\Psi_{S'}-\Psi_S)$. $\square$

**Corollary 5.2 (the sign flip).** If $p$ is a prime not in $S$, $\Psi_S(X)>0$, and
$$(|S|+1)\cdot\Psi_S(\lfloor X/p\rfloor)\ \ge\ \Psi_S(X),$$
then $\mathrm{work}(S\cup\{p\};X)\le\mathrm{work}(S;X)$.

*Proof.* By Proposition 4.2, $\Psi_{S'}(X)-\Psi_S(X)\ge\Psi_S(\lfloor X/p\rfloor)$. Now apply Theorem 5.1. $\square$

Adding a column costs an *additive* $+1$ in the relation target and buys a *multiplicative* gain in the smooth count. The hypothesis of Corollary 5.2 asks only that the $S$-smooth numbers below $X/p$ be at least a $1/(|S|+1)$ fraction of those below $X$. For a small prime $p$ and a moderately large $S$ this is mild.

**Example 5.3.** Take $S=\{2,3\}$, $X=100$, $p=5$. Then $\Psi_{\{2,3\}}(100)=20$ and $\Psi_{\{2,3\}}(20)=10$, and $3\cdot10=30\ge20$. Corollary 5.2 therefore certifies $\mathrm{work}(\{2,3,5\})\le\mathrm{work}(\{2,3\})$ without computing $\Psi_{\{2,3,5\}}$. In fact $\Psi_{\{2,3,5\}}(100)=34$, and $\mathrm{work}(\{2,3,5\})=4/34<3/20=\mathrm{work}(\{2,3\})$ strictly.

**Empirical evidence.** Three independent experimental designs were run, each with cross-validated instruments: a synthetic smoothness model, a CRT-based model, and a real single-polynomial QS. All three reached the same verdict. The number of sieve positions examined, which is the paid cost, decreases monotonically as $Q$ increases, by $2.4\times$ to $13.1\times$ across the range tested depending on the design. The earlier correlation $\operatorname{corr}(Q/\pi(B),k_{\rm success})=+0.77$ is genuine and survives controls, but it describes the number of relations, not the paid work.

A small reproducible instance shows the effect. Take $N=103\,764\,863$ and $B=400$, so $Q(N,B)=41$. Restrict the columns to the $q$ smallest admissible primes and count the positions $x\ge\lceil\sqrt N\rceil$ scanned until $q+1$ relations smooth over those $q$ primes have been found:

| $q$ | 16 | 22 | 28 | 34 | 41 |
|---|---:|---:|---:|---:|---:|
| positions scanned | 1651 | 784 | 747 | 638 | 599 |

**Design rule 5.4.** *At fixed $B$, the paid sieve length decreases in $Q$. A proposal that shrinks the factor base in order to shrink the linear algebra is moving the wrong term by construction.* The magnitude of the effect depends on $B$, and any quoted ratio should be labelled as a fixed-$B$ number.

---

## 6. The smooth density is governed by $Q$, not by Dickman's $\rho(u)$ alone

Let $\rho$ denote the Dickman function: $\rho(u)=1$ for $0\le u\le1$ and $u\rho'(u)=-\rho(u-1)$ for $u>1$. Classically $\Psi(X,X^{1/u})\sim\rho(u)X$. An earlier round reported that "the Dickman density survives measurement". We refine this claim.

**Empirical finding 6.1.** Across instances compared at matched $u=\log X/\log B$:
$$\operatorname{corr}\bigl(\log\rho(u),\ \text{measured smooth density}\bigr)=+0.029,\qquad \operatorname{corr}\bigl(Q/\pi(B),\ \text{measured smooth density}\bigr)=+0.882.$$

**Interpretation.** $\rho(u)$ correctly predicts how yield depends on $u$, but $u$ alone does not determine the yield across instances. Once $u$ is held fixed, $\rho(u)$ is a constant and carries no information about the variation between moduli. That variation is governed by the split structure of the factor base. Theorem 4.5 and Remark 4.6 give the rigorous counterpart: the yield ceiling has exponent $Q(N,B)$, not $\pi(B)$. The classical heuristic $\Psi(X,B)\approx\rho(u)X$ concerns *all* integers. Sieve values $x^2-N$ are not typical integers, because their prime factors are confined to $\mathcal{A}(N,B)$ (Theorem 3.2), and each admissible odd prime $r\nmid N$ divides a sieve value with frequency $2/r$ rather than $1/r$. The claim that "Dickman survives" is thus true of $u$ but blind to $Q$.

---

## 7. Which way does the rank bound point?

Let $v_0,v_1,\dots$ be the exponent vectors of relations in $V=\mathbb{F}_2^{\mathcal{A}(N,B)}$, so $\dim V=Q$. A disputed chain read "$k_{\rm success}\le\operatorname{rank}+1\le Q+1$". The objection was that the first inequality is backwards. We show that the two readings concern different ranks and that both are correct. Everything in this section holds over an arbitrary field $K$.

**Lemma 7.1.** $\operatorname{rk}(k)\le k$, and $\operatorname{rk}$ is non-decreasing in $k$. Moreover, $\mathrm{pre}_k$ is linearly independent if and only if $\operatorname{rk}(k)=k$. $\square$

**Proposition 7.2 (dependence forces a gap).** If $\mathrm{pre}_k$ is linearly dependent, then $\operatorname{rk}(k)+1\le k$.

*Proof.* Combine $\operatorname{rk}(k)\le k$ with $\operatorname{rk}(k)\ne k$. $\square$

**Theorem 7.3 (prefix-rank identity).**
$$k_{\rm success}=\operatorname{rk}(k_{\rm success})+1.$$

*Proof.* Write $k=k_{\rm success}$. Then $k\ge1$ because the empty family is independent. By Proposition 7.2, $\operatorname{rk}(k)+1\le k$. By minimality, $\mathrm{pre}_{k-1}$ is independent, so $\operatorname{rk}(k-1)=k-1$. By monotonicity, $k-1\le\operatorname{rk}(k)$. $\square$

**Corollary 7.4 (the original chain, for the full collected matrix).** Let $M=\mathrm{pre}_n$ with $n\ge k_{\rm success}$. Then $k_{\rm success}\le\operatorname{rank}(M)+1\le\dim V+1$.

*Proof.* Use Theorem 7.3 together with $\operatorname{rk}(k_{\rm success})\le\operatorname{rk}(n)\le\dim V$. $\square$

**Theorem 7.5 (sharpness).** In $K^Q$, if $v_i=e_i$ is the $i$-th standard basis vector for $0\le i<Q$, then $k_{\rm success}=Q+1$.

*Proof.* $\mathrm{pre}_Q$ is a basis, so every shorter prefix is independent, and $k_{\rm success}\le Q+1$ by Corollary 7.4. $\square$

**Corollary 7.6 (QS form).** For relation vectors in $\mathbb{F}_2^{\mathcal{A}(N,B)}$, the first dependency occurs after at most $Q(N,B)+1$ relations, and exactly one relation after the rank of the prefix it closes.

**Remarks.**

1. The objection is right about the *prefix* rank: dependence at prefix $k$ requires $k>\operatorname{rk}(k)$. The original chain is right about the rank of *all* collected relations. Theorem 7.3 says the two meet at the first dependency.
2. All of these bounds count **relations**. None of them bounds the number of sieve **positions** needed to find $k_{\rm success}$ relations, and that number is the paid work of §5. In particular, $\operatorname{rank}\le Q$ yields a guaranteed nontrivial null vector after $Q+1$ relations, and it gives no upper bound on sieving work.
3. In the corrected experimental run, $k_{\rm success}\le Q+1$ held in $180/180$ instances. An earlier apparent violation was traced to a sieve bug. The measured ratio $k_{\rm success}/Q$ was about $0.78$, $0.71$ and $0.60$ at $B=1024$, $2048$ and $4096$. By Theorem 7.5 these ratios are properties of the instances, not of the algebra. A single "typical" value such as $0.72$ is a mid-range figure, not a constant.

---

## 8. The $\mathbb{F}_2$-rank trap

During the experiments, two rank routines in a widely used computer-algebra library were found to return the rank over $\mathbb{Q}$ when asked for the rank over $\mathbb{F}_2$. One was a general matrix rank; the other explicitly advertises a $\mathrm{GF}(2)$ domain. On a matrix of $\mathbb{F}_2$-rank 2 they returned 3. We explain why such a bug survives ordinary testing, and in which direction it errs.

**Theorem 8.1.** Over any field, a square matrix has full rank if and only if its determinant is nonzero. $\square$

**Corollary 8.2.** Let $A$ be a square integer matrix. Then:
(a) $A$ has full rank over $\mathbb{F}_2$ if and only if $\det A$ is odd;
(b) $A$ has full rank over $\mathbb{Q}$ if and only if $\det A\ne0$.

*Proof.* The determinant commutes with ring homomorphisms. So $\det(A\bmod 2)=\det A\bmod2$, and $\det(A\otimes\mathbb{Q})=\det A$. Now apply Theorem 8.1. $\square$

**Theorem 8.3 (discriminating-test criterion).** For a square integer matrix $A$, the statements "$A$ has full rank over $\mathbb{Q}$" and "$A$ has full rank over $\mathbb{F}_2$" disagree if and only if $\det A$ is a nonzero even integer.

*Proof.* By Corollary 8.2 the two statements are "$\det A\neq0$" and "$\det A$ odd". They agree when $\det A=0$ (both false) and when $\det A$ is odd (both true). They disagree exactly when $\det A$ is nonzero and even. $\square$

So on the full-rank question, a validation suite built from matrices whose determinants are odd or zero cannot detect a routine that computes over $\mathbb{Q}$. Identity matrices, unitriangular matrices and visibly singular matrices all belong to this blind class.

**Example 8.4 (the witness).** Let $T$ be the incidence matrix of a triangle:
$$T=\begin{pmatrix}1&1&0\\0&1&1\\1&0&1\end{pmatrix},\qquad \det T=2.$$
Then $\operatorname{rank}_{\mathbb{Q}}T=3$ and $\operatorname{rank}_{\mathbb{F}_2}T=2$. Over $\mathbb{F}_2$ the three rows sum to zero, and the upper-left $2\times2$ minor equals $1$, which gives the lower bound $2$. (Rank does not increase when passing to an arbitrary submatrix.)

**Lemma 8.5 (2-adic lifting of independence).** Let $v_1,\dots,v_k\in\mathbb{Z}^m$ be vectors whose reductions mod 2 are linearly independent over $\mathbb{F}_2$. Then $v_1,\dots,v_k$ are linearly independent over $\mathbb{Z}$.

*Proof.* Suppose $\sum g_iv_i=0$ with $g\in\mathbb{Z}^k$. Reducing mod 2 gives a relation over $\mathbb{F}_2$, so every $g_i$ is even. Then $\sum(g_i/2)v_i=0$ is again an integer relation. By induction, $2^j\mid g_i$ for every $j$, which forces $g_i=0$. $\square$

**Theorem 8.6 (one-sided error).** For every integer matrix $A$, $\operatorname{rank}_{\mathbb{F}_2}(A\bmod2)\le\operatorname{rank}_{\mathbb{Q}}(A)$.

*Proof.* Choose columns of $A$ whose reductions form a basis of the $\mathbb{F}_2$-column space. By Lemma 8.5 these columns are $\mathbb{Z}$-independent. Hence they are $\mathbb{Q}$-independent, since clearing denominators turns a rational relation into an integer one. $\square$

**Consequence.** A routine that silently returns the rational rank can only *over*-report the $\mathbb{F}_2$-rank. It therefore under-reports the null space, and its failure mode is a sieve that reports "no dependency yet" while one exists. It never invents a spurious dependency, which is why the bug presents as a puzzling shortage of results rather than as wrong answers.

**Mutation testing.** A validation suite is evidence only if it can fail. Following Theorem 8.3, the experimental pipeline added a mutation test: deliberately broken routines were injected (including a rational-rank routine posing as an $\mathbb{F}_2$-rank routine), and the suite was required to reject them. Both injected mutants were caught. Without this step, "validation passed" is unfalsifiable.

---

## 9. The large-prime channel: more relations, same columns

The open problem left by §§3–5 is the following. *Given a fixed $B$, can the yield collapse be evaded without shrinking the column space?* The first candidate channel is the classical large-prime (partial-relation) variant. We prove its algebraic core.

**Setting 9.1.** Let $A$ be a finite set of primes, the column set, with $|A|=Q$. We are given:

* $a$ **full relations** $F_1,\dots,F_a$: nonzero integers with all prime factors in $A$;
* $b$ **partial relations** $P_i=s_i\ell_i$ ($1\le i\le b$): each $s_i$ is a nonzero integer with prime factors in $A$, and each $\ell_i$ is a prime (the *large prime*, typically in $(B,B^2]$);
* $D=\#\{\ell_1,\dots,\ell_b\}$, the number of **distinct** large primes.

For each $i$, let $\operatorname{rep}(i)$ be the least index $j$ with $\ell_j=\ell_i$. Call $i$ *paired* if $\operatorname{rep}(i)\neq i$.

**Lemma 9.2 (pairing count).** At least $b-D$ indices are paired.

*Proof.* The unpaired indices are the fixed points of $\operatorname{rep}$. The map $i\mapsto\ell_i$ is injective on them, since $\operatorname{rep}$ depends only on $\ell_i$. So there are at most $D$ fixed points. $\square$

**Lemma 9.3 (the large prime cancels).** For each paired $i$,
$$P_i\,P_{\operatorname{rep}(i)}=s_i\,s_{\operatorname{rep}(i)}\,\ell_i^2.$$
$\square$

**Lemma 9.4 (pigeonhole in $\mathbb{F}_2^A$).** Given more than $|A|$ nonzero integers, all with prime factors in $A$, some nonempty subcollection has a product that is a perfect square.

*Proof.* Their exponent vectors mod 2 are more than $\dim\mathbb{F}_2^A$ vectors, so some nonempty subset sums to $0$. The product over that subset has only even exponents. $\square$

**Theorem 9.5 (large-prime congruence of squares).** In Setting 9.1, if
$$Q<a+(b-D),$$
then some nonempty collection of full relations and paired products $P_iP_{\operatorname{rep}(i)}$ multiplies to a perfect square.

*Proof.* Form the combined family: the $a$ full relations, together with the products $P_iP_{\operatorname{rep}(i)}$ for paired $i$. By Lemma 9.2 the family has at least $a+(b-D)>Q$ members. Their *cores*, namely $F_j$ and $s_is_{\operatorname{rep}(i)}$, are nonzero and supported on $A$. By Lemma 9.4 some nonempty subfamily has square core product. By Lemma 9.3, the full product equals that square times $\prod\ell_i^2$, which is again a square. $\square$

**Example 9.6.** Let $A=\{2,3\}$ ($Q=2$), with one full relation $F_1=6$ and partials $2\cdot101$, $3\cdot101$, $6\cdot101$. Then $a=1$, $b=3$, $D=1$, and $a+(b-D)=3>2$. Pairing with the representative gives $P_2P_1=6\cdot101^2$, and
$$6\cdot(3\cdot101)(2\cdot101)=(6\cdot101)^2.$$
Without the partials ($a=1\le Q$) no dependency is guaranteed.

**Interpretation.** The column count stays at $Q$, while the effective relation count grows from $a$ to $a+(b-D)$. This is precisely the sense in which the large-prime channel "evades the yield collapse without shrinking the column space". Whether it is *cheaper* is no longer a linear-algebra question. It reduces to the growth of the collision count $b-D$, which is a weighted birthday problem.

**Conjecture 9.7 (large-prime collision threshold).** Suppose the large primes $\ell_i$ lie in $(B,B^2]$ with probability weight proportional to $1/\ell$. Then the expected collision count $\mathbb{E}[b-D]$ grows quadratically in $b$ until saturation, and the first time $a+(b-D)>Q$ occurs strictly earlier, in sieve positions, than the first time $a>Q$.

A simulation with $B=300$ gives mean collision counts of about $1.2$, $4.3$, $18.7$, $61.9$ and $197.8$ for $b=50$, $100$, $200$, $400$ and $800$, consistent with the predicted early quadratic growth.

---

## 10. Methodology and data integrity

Every instrument fault in this study was caught by cross-checking, never by inspection:

1. **Rank over the wrong field (§8).** Two library routines returned the rational rank.
2. **Modular square roots.** A Tonelli–Shanks implementation passed $4\,692$ random test pairs while carrying two defects.
3. **The gcd step.** A routine halved exponents per relation instead of summing them first. The resulting sieve ran cleanly and reported "no factor" on every instance.
4. **The log-sieve.** A logarithmic sieve without prime-power terms had recall $0.54$, which inflated absolute work by about $2.1\times$. Relative comparisons were unaffected.

A data-integrity issue was also found and corrected. Two experimental reports contained 16-row sample tables that had been transcribed rather than regenerated from the per-instance records. Ten of the sixteen quoted $(p,q)$ rows matched no stored record, one modulus was digit-transposed, and some quoted "ranks" were the ceiling $Q+1$ rather than the measured rank. Every *aggregate* statistic in those reports was exact. The sample tables were withdrawn, and only aggregates are used in this paper. The general rule is that a table that looks primary must be regenerated from primary data.

---

## 11. Algorithms

**Algorithm A (admissible factor base).** *Input:* $N$, $B$. *Output:* $\mathcal{A}(N,B)$.
1. Enumerate the primes $p\le B$ with the sieve of Eratosthenes.
2. For $p=2$, or $p\mid N$, include $p$.
3. Otherwise compute $N^{(p-1)/2}\bmod p$ (Euler's criterion) and include $p$ if the result is $1$.

The cost is $O(\pi(B)\log B)$ modular multiplications. By Theorem 3.2 the output is exactly the set of primes the sieve can hit.

**Algorithm B ($\Psi_S(X)$ by product enumeration).** Recursively enumerate exponent vectors $(e_p)_{p\in S}$ with $\prod p^{e_p}\le X$. The running time is $O(\Psi_S(X))$, which by Proposition 4.4 is at most $(\lfloor\log_2X\rfloor+1)^{|S|}$.

**Algorithm C (first dependency over $\mathbb{F}_2$).** Maintain an XOR basis indexed by pivot bit. For each new exponent vector, reduce it by the basis. If it reduces to $0$, return the current count $k=k_{\rm success}$; otherwise insert it. By Theorem 7.3, the basis size at termination is $k_{\rm success}-1$. The cost is $O(k\,Q^2/w)$ word operations with word size $w$.

**Algorithm D (discriminating test generation).** Draw random small integer square matrices and keep those with $\det$ nonzero and even (Theorem 8.3). Include the triangle witness $T$. Confirm that a rational-rank mutant is rejected before accepting a suite.

**Algorithm E (large-prime pairing).** Hash partials by large prime. Pair each later partial with the first one sharing its large prime. Append each pair's core $s_is_{\operatorname{rep}(i)}$ as a relation. A dependency is guaranteed once $a+(b-D)>Q$ (Theorem 9.5). The running time is linear in $b$.

---

## 12. Discussion and future work

The argument is short to state. Quadratic residuosity fixes the columns (§3). Smooth yield is exponential in the number of columns (§4). Adding a column costs $+1$ but gains a multiplicative factor (§5). Hence, at fixed $B$, the optimal factor base is as large as the method allows. Classical Dickman heuristics describe dependence on $u$ but say nothing about the variation in $Q$ between moduli (§6). The linear-algebra bound $k_{\rm success}\le Q+1$ is correct, sharp and exactly characterized (§7), but it bounds relations, not work.

**Open problem.** At fixed $B$, evade the yield collapse without shrinking the column space. The candidate channels are:
1. **Large primes and partial relations** (§9). The algebra is settled; the remaining task is to price the collision statistics (Conjecture 9.7). Double-large-prime variants lead to cycle counting in a graph on large primes.
2. **Multi-polynomial sieving.** Many polynomials $(\alpha x+\beta)^2-N$ keep the value size small. It remains to determine whether the split-set forcing of §3 transfers polynomial by polynomial. It should, since every such value is $\equiv$ a square minus $N$ modulo each prime, and therefore $Q$ remains the column count.
3. **Per-instance adaptive $B$.** Raising $B$ raises $Q$. Whether the penalty is escapable depends on the joint growth of $\Psi$ and $Q$ in $B$, which could be modelled with Theorem 4.5 and Corollary 5.2.

All three lie outside the single-polynomial regime analysed here. Consistent with every earlier round of this investigation, no new factoring method results. What does result is that one popular lever (shrinking $Q$) is disproved, one heuristic (Dickman alone) is sharpened, one inequality is oriented correctly, and one class of silent software faults is characterized completely.

---

## Appendix: worked numerical summary

* $10188^2-103\,764\,863=11\cdot17\cdot163$, with $(N/11)=(N/17)=(N/163)=+1$.
* $\Psi_{\{2,3\}}(100)=20$, $\Psi_{\{2,3\}}(20)=10$, $\Psi_{\{2,3,5\}}(100)=34$; $\mathrm{work}(\{2,3\})=0.15$, $\mathrm{work}(\{2,3,5\})\approx0.118$.
* For $X=10^6$, with $S$ the first $k$ primes: $(2^k,\Psi_S(X),20^k)=(2,20,20)$, $(4,142,400)$, $(8,507,8000)$, $(16,1273,1.6\cdot10^5)$, $(32,2432,3.2\cdot10^6)$, $(64,4106,6.4\cdot10^7)$, $(128,6179,1.28\cdot10^9)$ for $k=1,\dots,7$.
* Triangle matrix: $\det=2$, rational rank $3$, $\mathbb{F}_2$-rank $2$. Among $2000$ random $4\times4$ zero–one matrices, the criterion of Theorem 8.3 held in every case, and only $78$ were discriminating.
* Large primes: $6\cdot(3\cdot101)(2\cdot101)=606^2$.
