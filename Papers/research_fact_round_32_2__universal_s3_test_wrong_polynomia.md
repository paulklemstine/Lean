# The Wrong Polynomial: Affine Fixed-Point Moments, Root-Count Alphabets, and an Accidental $x^5-2$ Measurement

**Aristotle**

*September 2026*

---

## Abstract

An experiment meant to check "universal" root-count statistics for the cubic $x^3-2$, whose Galois group is $S_3$, was in fact run on the quintic $x^5-2$, whose Galois group is the Frobenius group $F_{20}$ of order $20$. The measured mean and mean-square root counts matched the $S_3$ predictions, and the substitution went unnoticed. We explain this exactly. Both groups are members of the affine family $\mathrm{AGL}(1,q) = \{x\mapsto ax+b : a\neq 0\}$ acting on $\mathbb{F}_q$, with $q=3$ and $q=5$. We prove the **affine moment law**
$$\sum_{a\neq 0,\;b\in\mathbb{F}_q}\operatorname{fix}(x\mapsto ax+b)^k \;=\; q^k+q(q-2)\qquad(k\geq 1)$$
for every finite field $\mathbb{F}_q$. Consequently the normalised fixed-point moments of $\mathrm{AGL}(1,q)$ are $1$, $2$ and $q+2$ for $k=1,2,3$. The first two do not depend on $q$, and the third determines $q$. Through the Chebotarev density theorem, a mean-and-variance test therefore cannot tell $x^3-2$ from $x^5-2$, while the third moment separates them ($5$ versus $7$). We also show that $\mathrm{AGL}(1,3)$ is the full symmetric group on $\mathbb{F}_3$ and that $\mathrm{AGL}(1,q)$ is a proper subgroup of $\mathrm{Sym}(\mathbb{F}_q)$ for $q\geq 4$. On the single-field side we determine the possible root counts of $x^n=c$: at most $n$, empty or a coset of $\mu_n$ when $c\ne 0$, exactly one when $\gcd(n,q-1)=1$, and the **alphabet** $\{0,1,\ell\}$ for prime exponent $\ell$. Summed over all constants $c$, the counts give first moment $q$ and second moment $1+(q-1)\gcd(n,q-1)$. Explicit checks at $p=23$, $31$ and $151$ show a prime where the two polynomials cannot be told apart, a prime where one reading separates them, and a prime where $x^5-2$ has five roots, which certifies the substitution. Numerical data over the primes below $400$ and below $5000$ illustrate these results.

---

## 1. Introduction

### 1.1 The dial table and the S₃ test

A useful way to probe a Galois group $G$ acting on the $n$ roots of an irreducible integer polynomial $f$ is to count, for many primes $p$, the number $N_f(p)$ of roots of $f$ modulo $p$. For all but finitely many $p$, $N_f(p)$ equals the number of fixed points of a Frobenius element $\mathrm{Frob}_p\in G$. By the Chebotarev density theorem the Frobenius elements are equidistributed over conjugacy classes, with each class weighted by its size. Statistics of $N_f(p)$ over primes therefore converge to statistics of the fixed-point function on $G$.

In an ongoing programme of experiments, groups paired with primes ("dials") were compared through such statistics. The dials included a cyclic group $C_5$, the Frobenius group $F_{20}$, two dials for $S_3$ at the primes $31$ and $23$, a dihedral group $D_4$ and an alternating group $A_4$. One experiment was meant to test whether the first two root-count moments of the $S_3$ polynomial $x^3-2$ are "universal". The polynomial actually fed into the measurement was $x^5-2$. The reported moments agreed with the $S_3$ predictions.

### 1.2 Questions and answers

This paper answers three questions exactly.

1. **Why was the substitution invisible?** Both Galois groups belong to the affine family $\mathrm{AGL}(1,q)$, and the first two normalised fixed-point moments equal $1$ and $2$ for every member of the family (Theorem 3.3 and Corollary 3.5). This is a consequence of double transitivity and has nothing to do with $S_3$ in particular (Proposition 7.1).
2. **What detects it?** The third normalised moment equals $q+2$ and so determines $q$ (Theorem 3.6). Also, the top letter of the root-count alphabet $\{0,1,\ell\}$ gives a certificate at a single prime (Theorem 5.4 and Section 6).
3. **Is $S_3$ just a small $F_{20}$?** No. $\mathrm{AGL}(1,3)$ is the whole of $\mathrm{Sym}(\mathbb{F}_3)\cong S_3$, but $\mathrm{AGL}(1,q)$ is a proper subgroup of $\mathrm{Sym}(\mathbb{F}_q)$ for every $q\geq 4$ (Theorem 4.2).

The verdict is that the accidental measurement was **true but misattributed**. It correctly measured the first two moments of $F_{20}$, and those numbers cannot tell the members of a doubly transitive family apart.

### 1.3 Organisation

Section 2 fixes notation. Section 3 proves the affine moment law and its consequences. Section 4 treats the comparison of $\mathrm{AGL}(1,q)$ with $\mathrm{Sym}(\mathbb{F}_q)$. Section 5 studies the root counts of $x^n=c$ in a fixed finite field. Section 6 carries out the dial checks at $23$, $31$ and $151$. Section 7 interprets the results in terms of orbit counting. Section 8 reports numerical evidence, Section 9 gives the algorithms, and Section 10 discusses open problems.

---

## 2. Preliminaries

Throughout, $\mathbb{F}$ is a finite field with $q=|\mathbb{F}|\geq 2$ elements.

**Definition 2.1 (Affine group).** For $a\in\mathbb{F}^\times$ and $b\in\mathbb{F}$, the *affine map* $\alpha_{a,b}:\mathbb{F}\to\mathbb{F}$ is $\alpha_{a,b}(x)=ax+b$. It is a bijection with inverse $y\mapsto a^{-1}(y-b)$. The set $\mathrm{AGL}(1,q)=\{\alpha_{a,b}\}$ is a group under composition.

**Lemma 2.2 (Faithfulness).** The map $(a,b)\mapsto\alpha_{a,b}$ from $\mathbb{F}^\times\times\mathbb{F}$ to $\mathrm{Sym}(\mathbb{F})$ is injective. In particular $|\mathrm{AGL}(1,q)|=q(q-1)$.

*Proof.* If $\alpha_{a,b}=\alpha_{a',b'}$, evaluating at $0$ gives $b=b'$, and then evaluating at $1$ gives $a=a'$. $\square$

**Definition 2.3 (Fixed points and moments).** Let $\operatorname{Fix}(a,b)=\{x\in\mathbb{F}: ax+b=x\}$ and $\operatorname{fix}(a,b)=|\operatorname{Fix}(a,b)|$. For $k\geq 1$ the *$k$-th power sum* is
$$S_k(q)=\sum_{a\in\mathbb{F}^\times}\sum_{b\in\mathbb{F}}\operatorname{fix}(a,b)^k,$$
and the *normalised $k$-th moment* is $M_k(q)=S_k(q)/\bigl(q(q-1)\bigr)$, the average of $\operatorname{fix}^k$ over $\mathrm{AGL}(1,q)$.

**Definition 2.4 (Root sets).** For $n\geq 0$ and $c\in\mathbb{F}$ put $R_n(c)=\{x\in\mathbb{F}: x^n=c\}$ and $r_n(c)=|R_n(c)|$. Write $\mu_n(\mathbb{F})=R_n(1)$ for the group of $n$-th roots of unity in $\mathbb{F}$.

**Background 2.5 (Galois groups of radical polynomials).** Let $\ell$ be an odd prime and let $a$ be an integer that is not an $\ell$-th power. The roots of $x^\ell-a$ are $\theta\zeta^i$ with $i\in\mathbb{Z}/\ell$, where $\theta^\ell=a$ and $\zeta$ is a primitive $\ell$-th root of unity. Every automorphism of the splitting field sends $\zeta\mapsto\zeta^u$ with $u\in(\mathbb{Z}/\ell)^\times$ and $\theta\mapsto\theta\zeta^v$ with $v\in\mathbb{Z}/\ell$. It therefore acts on indices by $i\mapsto ui+v$, and the Galois group is the full affine group $\mathrm{AGL}(1,\ell)$ acting on $\mathbb{F}_\ell$. So $\mathrm{Gal}(x^3-2)\cong\mathrm{AGL}(1,3)$ and $\mathrm{Gal}(x^5-2)\cong\mathrm{AGL}(1,5)=F_{20}$.

**Background 2.6 (Chebotarev transfer).** If $G$ is the Galois group of an irreducible $f\in\mathbb{Z}[x]$, then for every $k$,
$$\lim_{X\to\infty}\frac{1}{\pi(X)}\sum_{p\leq X}N_f(p)^k \;=\;\frac{1}{|G|}\sum_{g\in G}\operatorname{fix}(g)^k.$$
This follows from the Chebotarev density theorem, because $N_f(p)=\operatorname{fix}(\mathrm{Frob}_p)$ for unramified $p$ and $\operatorname{fix}$ is a class function. The results of Sections 3 and 4 compute the right-hand side exactly for the affine family.

---

## 3. The affine moment law

**Lemma 3.1 (Fixed points of an affine map).** For $a\in\mathbb{F}$ and $b\in\mathbb{F}$,
$$\operatorname{fix}(a,b)=\begin{cases} q & a=1,\ b=0,\\ 0 & a=1,\ b\neq 0,\\ 1 & a\neq 1.\end{cases}$$

*Proof.* If $a=1$ and $b=0$ every $x$ is fixed. If $a=1$ and $b\neq0$, then $x+b=x$ would force $b=0$, so nothing is fixed. If $a\neq 1$, then $1-a$ is invertible and $ax+b=x\iff x=b/(1-a)$, which is a unique solution. $\square$

Lemma 3.1 does not require $a\ne0$. It will only be applied to $a\in\mathbb{F}^\times$.

**Lemma 3.2 (Contribution of one slope).** For every $a\in\mathbb{F}$ and $k\geq1$,
$$\sum_{b\in\mathbb{F}}\operatorname{fix}(a,b)^k=\begin{cases}q^k & a=1,\\ q & a\neq 1.\end{cases}$$

*Proof.* For $a=1$ only the term $b=0$ is nonzero (since $0^k=0$ for $k\geq1$), and it contributes $q^k$. For $a\neq1$ each of the $q$ terms equals $1^k=1$. $\square$

**Theorem 3.3 (Affine moment law).** For every finite field $\mathbb{F}$ with $q$ elements and every $k\geq1$,
$$S_k(q)=\sum_{a\neq0}\sum_{b}\operatorname{fix}(a,b)^k=q^k+q(q-2).$$

*Proof.* Split off the slope $a=1$, which lies in $\mathbb{F}^\times$. By Lemma 3.2 it contributes $q^k$. Each of the remaining $|\mathbb{F}^\times|-1=q-2$ slopes contributes $q$. $\square$

In group-theoretic terms the identity contributes $q^k$, the $q-1$ nontrivial translations contribute $0$, and the $q(q-2)$ maps with $a\notin\{0,1\}$ each contribute $1$.

**Corollary 3.4 (The first three moments).** For every finite field with $q$ elements,
$$S_1(q)=q(q-1),\qquad S_2(q)=2\,q(q-1),\qquad S_3(q)=(q+2)\,q(q-1).$$
Equivalently $M_1(q)=1$, $M_2(q)=2$ and $M_3(q)=q+2$.

*Proof.* Write $q=m+2$ with $m\geq0$ and expand: $q+q(q-2)=q(q-1)$, then $q^2+q(q-2)=2q^2-2q$, and finally $q^3+q^2-2q=q(q-1)(q+2)$. $\square$

More generally, $M_k(q)=(q^{k-1}+q-2)/(q-1)$. For instance $M_4(q)=q^2+q+2$, which gives $14$ for $S_3$ and $32$ for $F_{20}$.

**Corollary 3.5 (Universality of the low moments).** For any two finite fields $\mathbb{F}$ and $\mathbb{K}$, $M_1(|\mathbb{F}|)=M_1(|\mathbb{K}|)$ and $M_2(|\mathbb{F}|)=M_2(|\mathbb{K}|)$.

*Proof.* Both sides equal $1$ and $2$ respectively, by Corollary 3.4. The denominators $q(q-1)$ are nonzero because $q\geq2$. $\square$

**Theorem 3.6 (The third moment determines the field size).** If $\mathbb{F}$ and $\mathbb{K}$ are finite fields with $M_3(|\mathbb{F}|)=M_3(|\mathbb{K}|)$, then $|\mathbb{F}|=|\mathbb{K}|$.

*Proof.* By Corollary 3.4 the hypothesis reads $|\mathbb{F}|+2=|\mathbb{K}|+2$ in $\mathbb{Q}$. $\square$

**Example 3.7 ($S_3$ versus $F_{20}$).** For $q=3$ and $q=5$,
$$S_1=6,\ S_2=12,\ S_3=30=6\cdot5 \qquad\text{and}\qquad S_1=20,\ S_2=40,\ S_3=140=20\cdot7.$$
The normalised moments are $(1,2,5)$ and $(1,2,7)$.

---

## 4. The affine group versus the symmetric group

**Definition 4.1.** For $a\in\mathbb{F}^\times$ and $b\in\mathbb{F}$, let $\pi_{a,b}\in\mathrm{Sym}(\mathbb{F})$ be the permutation $x\mapsto ax+b$.

**Theorem 4.2.**
1. The map $\mathbb{F}_3^\times\times\mathbb{F}_3\to\mathrm{Sym}(\mathbb{F}_3)$, $(a,b)\mapsto\pi_{a,b}$, is a bijection. So every permutation of $\mathbb{F}_3$ is affine and $\mathrm{AGL}(1,3)=\mathrm{Sym}(\mathbb{F}_3)\cong S_3$.
2. If $q\geq 4$, the map $\mathbb{F}^\times\times\mathbb{F}\to\mathrm{Sym}(\mathbb{F})$, $(a,b)\mapsto\pi_{a,b}$, is not surjective. In particular $F_{20}=\mathrm{AGL}(1,5)\neq S_5$.

*Proof.* The map is injective by Lemma 2.2. (1) Both sides have $2\cdot3=6=3!$ elements, so the map is a bijection. (2) Surjectivity would give $q!\leq q(q-1)$. Write $q=m+4$. Then $q!=q(q-1)\cdot(m+2)!$ with $(m+2)!\geq2$, so $q!\geq 2q(q-1)>q(q-1)$, a contradiction. $\square$

So the intended dial is the unique member of the affine family that is also a full symmetric group. The accidental dial is not "$S_3$ in higher degree". It is a much smaller subgroup of $S_5$, of index $6$.

---

## 5. Root counts of $x^n=c$ in a finite field

This section concerns a single field $\mathbb{F}=\mathbb{F}_q$. For a prime field $\mathbb{F}_p$, $r_n(c)$ is exactly the number of roots of $x^n-c$ modulo $p$.

**Proposition 5.1 (Degree bound).** For $n\geq1$ and $c\in\mathbb{F}$, $r_n(c)\leq n$.

*Proof.* $R_n(c)$ is contained in the set of roots of the nonzero polynomial $x^n-c$ of degree $n$, and a polynomial over a field has at most as many roots as its degree. $\square$

**Proposition 5.2 (Coset dichotomy).** Let $n\geq1$ and $c\neq0$. Then either $r_n(c)=0$ or $r_n(c)=|\mu_n(\mathbb{F})|$.

*Proof.* Suppose $x_0\in R_n(c)$. Then $x_0\neq0$, because $0^n=0\neq c$. The maps $z\mapsto x_0z$ and $y\mapsto y/x_0$ are mutually inverse bijections between $\mu_n(\mathbb{F})$ and $R_n(c)$: if $z^n=1$ then $(x_0z)^n=c$, and if $y^n=c$ then $(y/x_0)^n=c/c=1$. $\square$

**Proposition 5.3 (Inert exponents).** If $n\geq1$ and $\gcd(n,q-1)=1$, then $x\mapsto x^n$ is a bijection of $\mathbb{F}$, and $r_n(c)=1$ for every $c\in\mathbb{F}$.

*Proof.* Suppose $x^n=y^n$. If $y=0$ then $x=0$. Otherwise $x\neq0$ as well, and $u=x/y$ satisfies $u^n=1$ and $u^{q-1}=1$. Hence $u^{\gcd(n,q-1)}=u=1$, so $x=y$. An injective self-map of a finite set is bijective, so each $c$ has exactly one preimage. $\square$

**Theorem 5.4 (Root-count alphabet).** Let $\ell$ be a prime and $c\in\mathbb{F}^\times$. Then $r_\ell(c)\in\{0,1,\ell\}$. More precisely:
- if $\ell\nmid q-1$, then $r_\ell(c)=1$;
- if $\ell\mid q-1$, then $|\mu_\ell(\mathbb{F})|=\ell$ and $r_\ell(c)\in\{0,\ell\}$.

*Proof.* If $\ell\nmid q-1$ then $\gcd(\ell,q-1)=1$, and Proposition 5.3 applies. If $\ell\mid q-1=|\mathbb{F}^\times|$, Cauchy's theorem gives an element $g$ of order $\ell$. Then $g$ is a primitive $\ell$-th root of unity, so $x^\ell-1$ has the $\ell$ distinct roots $g^0,\dots,g^{\ell-1}$ and $|\mu_\ell(\mathbb{F})|=\ell$. Now apply Proposition 5.2. $\square$

So the alphabet is $\{0,1,3\}$ for the intended cubic $x^3-2$ and $\{0,1,5\}$ for the accidental quintic $x^5-2$. They share the letters $0$ and $1$ and differ only in the top letter.

**Corollary 5.5 (Inert primes for the two polynomials).** Let $p$ be a prime.
- If $p\not\equiv1\pmod 5$, then $x^5-2$ has exactly one root modulo $p$.
- If $p\equiv2\pmod 3$, then $x^3-2$ has exactly one root modulo $p$.

*Proof.* Apply Proposition 5.3 with $n=5$ (respectively $n=3$), using that $5\nmid p-1$ (respectively $3\nmid p-1$). $\square$

**Theorem 5.6 (Universal mean over constants).** For every $n\geq0$,
$$\sum_{c\in\mathbb{F}}r_n(c)=q.$$
If moreover $n\geq1$, then $\sum_{c\neq0}r_n(c)=q-1$.

*Proof.* The sets $R_n(c)$ for $c\in\mathbb{F}$ are the fibres of the map $x\mapsto x^n$, so they partition $\mathbb{F}$. For $n\geq1$ we have $R_n(0)=\{0\}$, and removing it leaves $q-1$. $\square$

**Theorem 5.7 (Second moment over constants).** For $n\geq1$,
$$\sum_{c\in\mathbb{F}}r_n(c)^2=1+(q-1)\,|\mu_n(\mathbb{F})|=1+(q-1)\gcd(n,q-1).$$

*Proof.* Grouping by fibres, $\sum_c r_n(c)^2=\sum_c\sum_{x\in R_n(c)}r_n(c)=\sum_{x\in\mathbb{F}}r_n(x^n)$. The term $x=0$ contributes $r_n(0)=1$. For $x\neq0$ the set $R_n(x^n)$ contains $x$, so it is nonempty, and by Proposition 5.2 it has $|\mu_n(\mathbb{F})|$ elements. That $|\mu_n(\mathbb{F})|=\gcd(n,q-1)$ follows from the cyclicity of $\mathbb{F}^\times$. $\square$

**Remark 5.8 (Two kinds of averaging).** Theorems 5.6 and 5.7 average over the constant $c$ in one field. The first moment is again universal: the mean root count is exactly $1$ for every exponent. The second moment, however, depends on $n$. In $\mathbb{F}_{31}$ it is $91$ for $n=3$ and $151$ for $n=5$. Averaging over primes for a fixed polynomial behaves differently: there the second moment is $2$ for both polynomials (Corollary 3.4). Whether a statistic is universal depends on the averaging measure as well as on the order of the moment.

---

## 6. Dial checks at single primes

**Proposition 6.1 (Prime 23: indistinguishable).** Modulo $23$, both $x^3-2$ and $x^5-2$ have exactly one root.

*Proof.* $23\equiv2\pmod3$ and $23\not\equiv1\pmod5$, so Corollary 5.5 applies. (The roots are $16$ and $6$ respectively.) $\square$

**Proposition 6.2 (Prime 31: separated).** Modulo $31$, $x^3-2$ has exactly three roots, namely $4$, $7$ and $20$, and $x^5-2$ has no root.

*Proof.* Direct computation gives $4^3\equiv7^3\equiv20^3\equiv2$, and three is the maximum by Proposition 5.1. If $x^5\equiv2$, then $x\neq0$ and $2^6\equiv x^{30}\equiv1$ by Fermat's little theorem. But $2^6=64\equiv2\pmod{31}$, a contradiction. $\square$

**Proposition 6.3 (Prime 151: a certificate).** Modulo $151$, $x^5-2$ has exactly the five roots $22,25,49,90,116$. For every $c$ in every field, $x^3-c$ has at most three roots. Hence the root count of $x^5-2$ modulo $151$ differs from the root count of $x^3-c$ modulo $151$ for every $c$.

*Proof.* Each of the five values satisfies $x^5\equiv2\pmod{151}$, by direct computation, and five is the maximum by Proposition 5.1. The second claim is Proposition 5.1 with $n=3$. $\square$

These three primes show everything a single reading can do: sometimes nothing ($23$), sometimes a separation within the shared letters ($31$), and sometimes a proof of the substitution through the top letter ($151$). The first primes at which $x^5-2$ has five roots are $151$, $241$ and $251$. By Chebotarev they have density $1/20$.

---

## 7. Interpretation: orbit counting and the blindness of low moments

The universality in Corollary 3.5 is an instance of a general principle.

**Proposition 7.1 (Moments count orbits on tuples).** Let $G$ act on a finite set $X$ with $|X|\ge k$. For $j\geq1$,
$$\frac{1}{|G|}\sum_{g\in G}\operatorname{fix}(g)^j=\#\{G\text{-orbits on }X^j\}.$$
If $G$ is $k$-transitive, then for every $j\leq k$ this number equals the number of set partitions of $\{1,\dots,j\}$. In particular it is $1$ for $j=1$ and $2$ for $j=2$, independently of $G$ and $X$.

*Proof sketch.* $\operatorname{fix}(g)^j$ is the number of fixed points of $g$ on $X^j$, and the orbit-counting (Cauchy–Frobenius–Burnside) lemma gives the first claim. The equality pattern of a $j$-tuple, meaning which coordinates coincide, is a $G$-invariant set partition of $\{1,\dots,j\}$. When $j\leq k$ and $G$ is $k$-transitive, any two tuples with the same pattern lie in one orbit, because their distinct entries form injective tuples of the same length at most $k$. $\square$

The group $\mathrm{AGL}(1,q)$ is sharply $2$-transitive: a pair $(u,v)$ with $u\ne v$ is sent to $(u',v')$ with $u'\ne v'$ by exactly one map, with $a=(u'-v')/(u-v)$ and $b=u'-au$. So Proposition 7.1 explains $M_1=1$ and $M_2=2$. It is not $3$-transitive for $q\geq4$, since a map is determined by the images of two points. The third moment counts orbits on triples: $M_3=q+2$ consists of the $5$ equality patterns of a triple ($1$ all-equal, $3$ with exactly one coincidence, $1$ all-distinct), where the all-distinct triples split into $(q-2)$ orbits under $\mathrm{AGL}(1,q)$, parametrised by the affine invariant $(w-u)/(v-u)\in\mathbb{F}\setminus\{0,1\}$. That gives $4+(q-2)=q+2$ orbits. For $q=3$ this is $5$, the Bell number $B_3$, as full $3$-transitivity of $S_3$ requires.

**Diagnosis.** A test of "universality" based on the first two root-count moments can only detect a failure of double transitivity. Every $\mathrm{AGL}(1,q)$ passes. The accidental $x^5-2$ measurement was therefore:
- *true*: the moments $1$ and $2$ are the correct limits for $F_{20}$;
- *misattributed*: the same numbers hold for $S_3$ and for every doubly transitive group, so they carry no information about which polynomial was measured;
- *detectable*: through $M_3$ ($5$ versus $7$), through the top letter $5\notin\{0,1,3\}$, or through lucky primes such as $31$.

---

## 8. Numerical evidence

The data below are direct computations of root counts of $x^n-2$ modulo $p$. They illustrate the limits in Background 2.6 and are not used in any proof.

**Primes $7\leq p<400$ (75 primes).**

| polynomial | $\#\{N=0\}$ | $\#\{N=1\}$ | $\#\{N=\ell\}$ | mean | mean square | mean cube | predicted |
|---|---|---|---|---|---|---|---|
| $x^3-2$ | 26 | 38 | 11 | 0.947 | 1.83 | 4.47 | $1,\,2,\,5$ |
| $x^5-2$ | 14 | 58 | 3 | 0.973 | 1.77 | 5.77 | $1,\,2,\,7$ |

**Primes $7\leq p<5000$ (666 primes).**

| polynomial | $\#\{N=0\}$ | $\#\{N=1\}$ | $\#\{N=\ell\}$ | mean | mean square | mean cube |
|---|---|---|---|---|---|---|
| $x^3-2$ | 225 | 336 | 105 | 0.977 | 1.92 | 4.76 |
| $x^5-2$ | 131 | 503 | 32 | 0.995 | 1.96 | 6.76 |

The Chebotarev class proportions are $(1/3,1/2,1/6)$ for $S_3$ and $(1/5,3/4,1/20)$ for $F_{20}$. On $666$ primes these predict $(222,333,111)$ and $(133.2,499.5,33.3)$, close to what we observe. Across both ranges the first two moments of the two polynomials are close to each other and approach $1$ and $2$. The third moments stay about $2$ apart, as $M_3(5)-M_3(3)=2$ predicts. The third moment converges most slowly because it is dominated by the rare top-letter primes.

---

## 9. Algorithms

**Algorithm A (Exact affine moment table).** *Input:* $q$ and $k_{\max}$. *Output:* $M_k(q)$ for $k=1,\ldots,k_{\max}$. Return $(q^k+q(q-2))/(q(q-1))$. Each value costs $O(\log k)$ arithmetic operations. A brute-force check that enumerates all $q(q-1)$ maps and all $q$ points costs $O(q^3)$ per $k$. Its agreement with Theorem 3.3 is a useful consistency test, which we ran for all primes $q\leq13$ and $k\leq5$.

**Algorithm B (Root-count alphabet and dial check).** *Input:* a prime $p$ and exponents $n_1$, $n_2$. For each $n_i$, compute $g_i=\gcd(n_i,p-1)$. If $g_i=1$, the count is $1$. Otherwise decide whether $2$ is an $n_i$-th power residue by testing $2^{(p-1)/g_i}\equiv1\pmod p$, the $n_i$-th power residue criterion in the cyclic group $\mathbb{F}_p^\times$; the count is $g_i$ if it is and $0$ if not. Report "indistinguishable" if the two counts agree, "separated" if they differ, and "certificate" if one count exceeds the degree of the other polynomial. This costs $O(\log p)$ modular multiplications.

**Algorithm C (Sequential third-moment discriminator).** Run over primes, accumulating the running mean of $N(p)^3$. Compare its distance from $5$ with its distance from $7$, and stop when a top-letter prime (count $5$) appears or the running mean stays on one side of $6$. Since top-letter primes for $x^5-2$ have density $1/20$, one is expected within about the first $20$ unramified primes. In practice the certificate route of Proposition 6.3 is the fastest.

---

## 10. Discussion and future directions

The main lesson is methodological. A statistical check of a Galois group can pass only if it was capable of failing. Moments of order $j$ see only the action on $j$-tuples, so two groups that are equally transitive up to order $k$ cannot be told apart by moments of order at most $k$ (Proposition 7.1). For the affine family the separating order is exactly $3$, and Theorem 3.3 gives the complete moment sequence $M_k(q)=(q^{k-1}+q-2)/(q-1)$ in closed form.

We list directions suggested by the results.

1. **Third-moment discriminant for radical polynomials.** For a prime $\ell$ and an integer $a$ that is not an $\ell$-th power, the prime-averaged third moment of the root count of $x^\ell-a$ equals $\ell+2$. The group side is Corollary 3.4 combined with Background 2.5. What remains is the quantitative Chebotarev transfer, meaning explicit rates of convergence, and large-scale numerical testing.
2. **Moment-truncation blindness.** Proposition 7.1 shows that $k$-transitive groups of the same degree have the same first $k$ moments. The $\mathrm{AGL}(1,3)$ versus $\mathrm{AGL}(1,5)$ case shows the order $k+1$ can be needed exactly, with $k=2$. Characterising which pairs of groups separate at order exactly $k+1$ is open.
3. **Divisor-count second moment for Kummer polynomials.** By Theorem 5.7, at a fixed prime $p$ the second moment averaged over constants is $(1+(p-1)\gcd(n,p-1))/p$, which is within $1/p$ of $\gcd(n,p-1)$. Writing $\gcd(n,p-1)=\sum_{d\mid\gcd(n,p-1)}\varphi(d)$ and averaging over primes with Dirichlet's theorem gives $\sum_{d\mid n}\varphi(d)/\varphi(d)=\tau(n)$, the number of divisors of $n$. We conjecture that for generic $a$ the prime-averaged second moment of the root count of $x^n-a$ is $\tau(n)$. For prime $n$ this gives $2$, in agreement with Corollary 3.4.

---

## Appendix: summary of exact results

- Fixed points of $x\mapsto ax+b$: $q$, $0$ or $1$.
- Affine moment law: $\sum_{a\ne0,b}\operatorname{fix}^k=q^k+q(q-2)$ for $k\ge1$.
- Normalised moments of $\mathrm{AGL}(1,q)$: $1,\ 2,\ q+2$. The first two are universal and the third determines $q$.
- $|\mathrm{AGL}(1,q)|=q(q-1)$; $\mathrm{AGL}(1,3)=\mathrm{Sym}(\mathbb{F}_3)$; $\mathrm{AGL}(1,q)\subsetneq\mathrm{Sym}(\mathbb{F}_q)$ for $q\ge4$.
- Root counts of $x^n=c$: at most $n$; $0$ or $|\mu_n|$ for $c\ne0$; exactly $1$ if $\gcd(n,q-1)=1$; alphabet $\{0,1,\ell\}$ for prime $\ell$.
- Over constants: $\sum_c r_n(c)=q$ and $\sum_c r_n(c)^2=1+(q-1)|\mu_n|$.
- Dials: at $p=23$ the counts are $(1,1)$; at $p=31$ they are $(3,0)$; at $p=151$, $x^5-2$ has $5$ roots, which no cubic can have.
