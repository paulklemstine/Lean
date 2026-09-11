# Structure Theory of the Singmaster Multiplicity, and a Complete Classification of the One-Row-Shift Coincidences

**Author:** Aristotle
**Date:** 2026-09-10

---

## Abstract

For an integer $n \ge 2$ let the *Singmaster multiplicity* $m(n)$ denote the number of positions $(N,k)$, $0\le k\le N$, with $\binom{N}{k}=n$. Singmaster's conjecture asserts that $m$ is bounded; the conjecture is open, the largest known value being $m(3003)=8$. We develop an unconditional structure theory for $m$ and use it to prove several exact results.

We show that all occurrences of $n\ge 2$ lie in rows $N\le n$, and that all *interior* occurrences (those with $2\le k\le N-2$) satisfy the sharp *row squeeze* $N(N-1)\le 2n$ and, in the left half of the triangle, the *column squeeze* $2^k\le n$. From the reflection $k\mapsto N-k$ we derive the decomposition $m(n)=2\lambda(n)+\gamma(n)$ where $\lambda(n)$ counts occurrences strictly left of centre and $\gamma(n)\in\{0,1\}$ counts central ones, and hence the **parity law**: $m(n)$ is odd if and only if $n$ is a central binomial coefficient. An arithmetic obstruction shows that if a prime $p\mid n$ satisfies $p(p-1)>2n$ then $m(n)=2$ exactly; in particular $m(p)=2$ for primes $p\ge 5$ and $m(2p)=2$ for primes $p\ge 7$. Refining this we obtain the exact value $m\!\left(\binom{p}{2}\right)=4$ for every prime $p\ge 5$, giving an infinite family of numbers of multiplicity exactly four. A counting argument built on the two squeezes yields the effective density bound
$$\#\{3\le n\le x:\ m(n)\ge 3\}\ \le\ \bigl(\lfloor\sqrt{2x}\rfloor+2\bigr)\bigl(\lfloor\log_2 x\rfloor+2\bigr),$$
so almost every integer occurs exactly twice. On the small-value side we prove $m(3003)=8$, $m(n)\le 8$ for all $n<3003$, and that the values $5$ and $7$ are never attained below $3003$.

Our main new theorem is a complete classification of the *one-row-shift coincidences* $\binom{N}{k}=\binom{N-1}{k+1}$, equivalently of the Diophantine equation $N(k+1)=(N-k)(N-k-1)$. We prove that for $2\le k$ and $2k\le N$ the solutions are **exactly** the Fibonacci pairs $N=F_{2i+2}F_{2i+3}$, $k=F_{2i}F_{2i+3}$ with $i\ge 1$. The proof is an elementary two-step Vieta descent on the equivalent form $k^2+k+N^2=3Nk+2N$, with the even-index Cassini identity supplying the ascent; no Pell theory is required, though the classification implies the Pell shadow $(3N-1-2k)^2=5N^2+2N+1$. As a consequence, the Fibonacci ladder is the *only* infinite family of six-fold coincidences obtainable from a one-row shift.

**Keywords.** Singmaster's conjecture, binomial coefficients, Pascal's triangle, Cassini identity, Fibonacci numbers, Vieta jumping, Pell equation, Diophantine classification.

---

## 1. Introduction

Every integer $n\ge 2$ occurs at least twice in Pascal's triangle, at the positions $\binom{n}{1}$ and $\binom{n}{n-1}$. Some occur more: $6=\binom{4}{2}$ occurs three times, $10=\binom{5}{2}=\binom{5}{3}$ four times, $120=\binom{10}{3}=\binom{16}{2}$ six times, and
$$3003=\binom{14}{6}=\binom{14}{8}=\binom{15}{5}=\binom{15}{10}=\binom{78}{2}=\binom{78}{76}=\binom{3003}{1}=\binom{3003}{3002}$$
occurs eight times. No integer is known to occur more than eight times, and Singmaster conjectured in 1971 that the number of occurrences is bounded by an absolute constant. The conjecture remains open; the best unconditional upper bounds are of the shape $O(\log n/\log\log n)$, and stronger bounds are known only under deep conjectures in Diophantine approximation.

This paper is concerned with what can be established *unconditionally and exactly*. Three themes organise the development.

1. **Geometric confinement.** Two elementary squeezes — one on the row index, one on the column index — confine the interesting occurrences of $n$ to a $O(\sqrt n)\times O(\log n)$ rectangle. This makes the multiplicity effectively computable and yields a density theorem.
2. **Symmetry and arithmetic obstructions.** The reflection symmetry of Pascal's triangle forces a parity law; divisibility forces numbers with a large prime factor to have multiplicity exactly two, and pins an infinite family to multiplicity exactly four.
3. **Coincidence mechanisms.** Numbers of high multiplicity arise from *coincidences* between distinct rows. The best-known mechanism is the one-row shift $\binom{N}{k}=\binom{N-1}{k+1}$. Our main theorem determines all of its solutions.

Throughout, $F_j$ denotes the Fibonacci sequence $F_0=0$, $F_1=1$, $F_{j+2}=F_{j+1}+F_j$, and $\binom{N}{k}=0$ when $k>N$.

### 1.1 Summary of results

* **Theorem A** (Row squeeze). If $\binom{N}{k}=n$ with $2\le k\le N-2$ then $N(N-1)\le 2n$.
* **Theorem B** (Trivial splitting). For $n\ge 3$, $m(n)=2+\iota(n)$, where $\iota(n)$ is the number of interior occurrences.
* **Theorem C** (Reflection decomposition and parity law). For $n\ge 2$, $m(n)=2\lambda(n)+\gamma(n)$ with $\gamma(n)\le 1$; consequently $m(n)$ is odd if and only if $n=\binom{2t}{t}$ for some $t$.
* **Theorem D** (Large prime factor). If $n\ge 3$ has a prime factor $p$ with $p(p-1)>2n$ then $m(n)=2$. Hence $m(p)=2$ for primes $p\ge 5$, $m(2p)=2$ for primes $p\ge 7$, and $\{n: m(n)=2\}$ is infinite.
* **Theorem E** (Exact multiplicity four). For every prime $p\ge 5$, $m\!\left(\binom{p}{2}\right)=4$, and the only interior occurrences are $(p,2)$ and $(p,p-2)$. Hence $\{n:m(n)=4\}$ is infinite.
* **Theorem F** (Density). $\#\{3\le n\le x:\ m(n)\ge 3\}\le(\lfloor\sqrt{2x}\rfloor+2)(\lfloor\log_2 x\rfloor+2)$, and $\#\{n\le x:\ m(n)\ne 2\}$ exceeds this by at most $3$.
* **Theorem G** (Small values). $m(3003)=8$; $m(n)\le 8$ for all $n<3003$; $m(n)\notin\{5,7\}$ for $n<3003$; if $3\le n<3003$ and $m(n)$ is odd then $m(n)=3$. The attained multiplicities among the values considered are $\{0,1,2,3,4,6,8\}$.
* **Theorem H** (Fibonacci ladder). For every $i\ge1$, $m\!\left(\binom{F_{2i+2}F_{2i+3}}{F_{2i}F_{2i+3}}\right)\ge 6$; hence $\{n:m(n)\ge6\}$ is infinite. The case $i=1$ is $\binom{15}{5}=3003$.
* **Theorem I** (Cassini classification). For $0\le a\le b$, $b^2=ab+a^2+1$ holds if and only if $(a,b)=(F_{2i},F_{2i+1})$ for some $i\ge0$.
* **Theorem J** (Row-shift classification; main new result). For $2\le k$ and $2k\le N$,
  $$N(k+1)=(N-k)(N-k-1)\iff \exists\, i\ge 1:\ N=F_{2i+2}F_{2i+3},\ k=F_{2i}F_{2i+3}.$$
* **Corollary K** (Pell shadow). Any such solution satisfies $(3N-1-2k)^2=5N^2+2N+1$; equivalently $(5N+1)^2-5(3N-1-2k)^2=-4$.
* **Corollary L** (Exhaustion of the mechanism). Every six-fold coincidence produced by a one-row shift is a member of the Fibonacci ladder; the mechanism yields no further infinite family.

---

## 2. The occurrence set

**Definition 2.1 (Occurrence set, multiplicity).** For $n\ge 2$ set
$$\mathcal{O}(n)=\{(N,k)\in\mathbb{Z}_{\ge0}^2:\ k\le N,\ \tbinom{N}{k}=n\},\qquad m(n)=\#\mathcal{O}(n).$$
For $n=1$ the set is infinite (the border of the triangle), and for $n=0$ it is empty; we therefore restrict attention to $n\ge 2$ throughout, where finiteness is guaranteed by Lemma 2.4.

**Definition 2.2 (Interior, lower, upper, central occurrences).**
$$\mathcal{I}(n)=\{(N,k)\in\mathcal{O}(n): 2\le k,\ k+2\le N\},$$
$$\mathcal{L}(n)=\{(N,k)\in\mathcal{O}(n): 2k<N\},\quad \mathcal{U}(n)=\{(N,k)\in\mathcal{O}(n): N<2k\},\quad \mathcal{C}(n)=\{(N,k)\in\mathcal{O}(n): N=2k\}.$$
Write $\iota(n)=\#\mathcal{I}(n)$, $\lambda(n)=\#\mathcal{L}(n)$, $\gamma(n)=\#\mathcal{C}(n)$.

The basic tool is unimodality of a row in the following convenient asymmetric form.

**Lemma 2.3 (Row monotonicity).** If $j\le k$ and $j+k\le N$ then $\binom{N}{j}\le\binom{N}{k}$.

*Proof sketch.* First prove the statement under the stronger hypothesis $2k\le N$, by induction on $k$: the inductive step is the standard fact that $\binom{N}{k}\le\binom{N}{k+1}$ whenever $2(k+1)\le N$, which follows from $\binom{N}{k+1}=\binom{N}{k}\frac{N-k}{k+1}$ and $N-k\ge k+1$. For the general case, if $2k>N$ then $k\le N$ and $j+k\le N$ gives $j\le N-k$ with $2(N-k)\le N$; apply the special case to $j\le N-k$ and use $\binom{N}{k}=\binom{N}{N-k}$. $\square$

**Lemma 2.4 (Row bound).** If $\binom{N}{k}=n\ge 2$ and $k\le N$ then $N\le n$.

*Proof sketch.* If $k=0$ or $k=N$ then $n=1$, contradiction. Otherwise $1\le k$ and $1+k\le N$, so Lemma 2.3 with $j=1$ gives $N=\binom{N}{1}\le\binom{N}{k}=n$. $\square$

Thus $m(n)$ is finite for $n\ge2$ and can be computed by a search over $N\le n$. The next theorem improves this dramatically for the non-trivial occurrences.

**Theorem A (Row squeeze).** If $\binom{N}{k}=n$ with $2\le k$ and $k+2\le N$, then
$$N(N-1)\le 2n.$$

*Proof.* By Lemma 2.3 with $j=2$ we get $\binom{N}{2}\le\binom{N}{k}=n$, and $2\binom{N}{2}=N(N-1)$. $\square$

Equality can occur: for $n=\binom{N}{2}$ itself. Theorem A confines interior occurrences to rows $N\le\frac{1+\sqrt{1+8n}}{2}=O(\sqrt n)$; for $n<3003$ it gives $N\le 78$.

**Theorem A′ (Column squeeze).** If $\binom{N}{k}=n$ with $2k\le N$, then $2^k\le n$; in particular $k\le\log_2 n$.

*Proof.* Lemma 2.3 (applied in row $N$, or directly by monotonicity in $N$) gives $\binom{N}{k}\ge\binom{2k}{k}$, and $2^k\le\binom{2k}{k}$ by induction, using $(t+1)\binom{2t+2}{t+1}=2(2t+1)\binom{2t}{t}$, whence $\binom{2t+2}{t+1}\ge 2\binom{2t}{t}$. $\square$

---

## 3. Splitting off the trivial occurrences

**Theorem B (Trivial splitting).** For every $n\ge 3$,
$$\mathcal{O}(n)\setminus\mathcal{I}(n)=\{(n,1),\ (n,n-1)\},\qquad\text{hence } m(n)=2+\iota(n).$$

*Proof sketch.* The two listed positions are genuine occurrences ($\binom{n}{1}=n$ and $\binom{n}{n-1}=n$) and they are distinct because $n\ge3$ forces $n-1\ne1$; neither is interior. Conversely, let $(N,k)\in\mathcal{O}(n)$ be non-interior, so $k\le 1$ or $N\le k+1$. If $k=0$ then $n=1$, excluded; if $k=1$ then $N=n$. If $k=N$ then $n=1$, excluded; if $k=N-1$ then $\binom{N}{N-1}=N=n$, so $(N,k)=(n,n-1)$. Cardinalities then give $m(n)=2+\iota(n)$. $\square$

Theorem B is the reason all later statements are phrased in terms of $\iota$: the two boundary occurrences carry no information, and the whole difficulty of Singmaster's conjecture is the size of $\mathcal{I}(n)$.

---

## 4. Reflection symmetry and the parity law

**Lemma 4.1.** For $n\ge2$ the map $(N,k)\mapsto(N,N-k)$ is a bijection $\mathcal{L}(n)\to\mathcal{U}(n)$; hence $\lambda(n)=\#\mathcal{U}(n)$.

*Proof sketch.* If $(N,k)\in\mathcal{L}(n)$ then $k\le N$, $\binom{N}{N-k}=\binom{N}{k}=n$, and $2k<N$ gives $N<2(N-k)$, so the image lies in $\mathcal{U}(n)$. The map is its own two-sided inverse on these sets. $\square$

**Lemma 4.2.** $\mathcal{O}(n)=\mathcal{L}(n)\sqcup\mathcal{U}(n)\sqcup\mathcal{C}(n)$, a disjoint union determined by the trichotomy $2k<N$, $2k>N$, $2k=N$.

**Theorem C (Reflection decomposition and parity law).** For $n\ge2$,
$$m(n)=2\lambda(n)+\gamma(n),\qquad \gamma(n)\le 1,$$
and consequently
$$m(n)\ \text{is odd}\iff n=\binom{2t}{t}\ \text{for some } t\ge 0 .$$

*Proof.* The identity is Lemmas 4.1 and 4.2. For $\gamma(n)\le1$: a central occurrence is a pair $(2t,t)$ with $\binom{2t}{t}=n$, and $t\mapsto\binom{2t}{t}$ is strictly increasing, because $(t+1)\binom{2t+2}{t+1}=2(2t+1)\binom{2t}{t}$ and $\binom{2t}{t}>0$ give $\binom{2t+2}{t+1}>\binom{2t}{t}$; injectivity yields at most one central occurrence. Finally $2\lambda(n)+\gamma(n)$ is odd iff $\gamma(n)=1$ iff $n$ is a central binomial coefficient. $\square$

Theorem C explains the empirical rarity of odd multiplicities. The central binomial coefficients below $3003$ are $1,2,6,20,70,252,924$; correspondingly the only $n<3003$ with $m(n)$ odd are $2$ (multiplicity $1$) and $6,20,70,252,924$ (each of multiplicity $3$). Numerically, among $2\le n<3003$ the multiplicity distribution is
$$m=1:\ 1\ \text{value},\quad m=2:\ 2890,\quad m=3:\ 5,\quad m=4:\ 102,\quad m=6:\ 3 .$$

---

## 5. An arithmetic obstruction

**Lemma 5.1.** If $p$ is prime, $k\le N$ and $p\mid\binom{N}{k}$, then $p\le N$.

*Proof sketch.* $\binom{N}{k}$ divides $N!$ (indeed $N!=\binom{N}{k}k!(N-k)!$), so $p\mid N!$, hence $p\le N$ since a prime dividing $N!$ divides one of $1,\dots,N$. $\square$

**Theorem D (Large prime factor).** Let $n\ge 3$ and let $p$ be a prime with $p\mid n$ and $p(p-1)>2n$. Then $\mathcal{I}(n)=\varnothing$ and $m(n)=2$.

*Proof.* Suppose $(N,k)\in\mathcal{I}(n)$. By Lemma 5.1, $p\le N$; by Theorem A, $N(N-1)\le2n$. Since $t\mapsto t(t-1)$ is increasing on $t \ge 1$, $p(p-1)\le N(N-1)\le 2n$, contradicting $p(p-1)>2n$. Hence $\iota(n)=0$ and Theorem B gives $m(n)=2$. $\square$

**Corollary D1.** $m(p)=2$ for every prime $p\ge5$.
*Proof.* Take $p\mid p$: since $p-1\ge 3$ we have $p(p-1)\ge 3p>2p$. $\square$

**Corollary D2.** $m(2p)=2$ for every prime $p\ge7$.
*Proof.* $p\mid 2p$ and $p-1\ge 5$ give $p(p-1)\ge 5p>4p=2\cdot(2p)$. $\square$

**Corollary D3.** $\{n:\ m(n)=2\}$ is infinite (indeed unbounded), by Corollary D1 and the infinitude of primes.

---

## 6. An infinite family of multiplicity exactly four

Theorem D produces multiplicity exactly $2$. The same circle of ideas produces the first infinite family with a larger *exact* multiplicity.

**Lemma 6.1.** If $p\ge5$ is prime then $p\mid\binom{p}{2}$ and $\binom{p}{2}\ge 3$.
*Proof sketch.* $2\binom{p}{2}=p(p-1)$ with $p$ odd, so $p\mid\binom{p}{2}$; and $p(p-1)\ge 20$ gives $\binom{p}{2}\ge 10$. $\square$

**Lemma 6.2.** If $p\ge7$ then $\binom{p}{2}<\binom{p}{3}$.
*Proof sketch.* $\binom{p}{3}\cdot 3=\binom{p}{2}(p-2)$ and $p-2\ge5>3$. $\square$

**Theorem E (Exact multiplicity four).** For every prime $p\ge5$,
$$\mathcal{I}\!\left(\tbinom{p}{2}\right)=\{(p,2),\,(p,p-2)\},\qquad m\!\left(\tbinom{p}{2}\right)=4 .$$

*Proof sketch.* Write $n=\binom{p}{2}$. Let $(N,k)\in\mathcal{I}(n)$. Theorem A gives $N(N-1)\le 2n=p(p-1)$, hence $N\le p$. Since $p\mid n=\binom{N}{k}$, Lemma 5.1 gives $p\le N$. Therefore $N=p$. Within row $p$, monotonicity (Lemma 2.3) plus Lemma 6.2 forces $k\in\{2,p-2\}$: if $3\le k\le p-3$ then $\binom{p}{k}\ge\binom{p}{3}>\binom{p}{2}=n$. (For $p=5$ the interval $3\le k\le p-3$ is empty and the conclusion is immediate.) The two positions $(p,2)$ and $(p,p-2)$ are distinct since $p\ge5$, and both are interior. Theorem B gives $m(n)=2+2=4$. $\square$

**Corollary E1.** $\{n:\ m(n)=4\}$ is infinite. The first members are $10,21,55,78,136,171,253,406,\dots$

**Corollary E2 (Attained values).** The multiplicities $1,2,3,4,6,8$ all occur, witnessed by
$$m(2)=1,\quad m(5)=2,\quad m(6)=3,\quad m(21)=4,\quad m(120)=6,\quad m(3003)=8 .$$

---

## 7. Almost every integer occurs exactly twice

**Theorem F (Density bound).** For every $x\ge 1$,
$$\#\{\,3\le n\le x:\ m(n)\ge3\,\}\ \le\ \bigl(\lfloor\sqrt{2x}\rfloor+2\bigr)\bigl(\lfloor\log_2x\rfloor+2\bigr),$$
and consequently
$$\#\{\,n\le x:\ m(n)\ne 2\,\}\ \le\ \bigl(\lfloor\sqrt{2x}\rfloor+2\bigr)\bigl(\lfloor\log_2x\rfloor+2\bigr)+3 .$$

*Proof sketch.* Let $3\le n\le x$ with $m(n)\ge3$. By Theorem B, $\iota(n)\ge1$; and if $(N,k)$ is interior then so is its reflection $(N,N-k)$, one of which satisfies $2k\le N$. Choose for each such $n$ one interior occurrence $c(n)=(N_n,k_n)$ with $2k_n\le N_n$ (a canonical choice). The assignment $n\mapsto c(n)$ is injective, since $\binom{N_n}{k_n}=n$ recovers $n$. By Theorem A, $N_n(N_n-1)\le 2n\le 2x$, so $N_n\le\lfloor\sqrt{2x}\rfloor+1$; by Theorem A′, $2^{k_n}\le n\le x$, so $k_n\le\lfloor\log_2 x\rfloor$. Hence $c$ maps injectively into a rectangle with at most $(\lfloor\sqrt{2x}\rfloor+2)(\lfloor\log_2 x\rfloor+2)$ lattice points. The second statement adds the at most three exceptional values $n\in\{0,1,2\}$. $\square$

So the exceptional set has counting function $O(\sqrt x\log x)$: the multiplicity equals $2$ for all but a density-zero set of integers, with an explicit and completely effective error term. Numerically:

| $x$ | actual $\#\{m\ge3\}$ | bound of Theorem F |
|---:|---:|---:|
| $100$ | $16$ | $128$ |
| $300$ | $32$ | $260$ |
| $1000$ | $64$ | $506$ |
| $3000$ | $110$ | $1027$ |

Note the striking asymmetry with Singmaster's conjecture: we can prove that high multiplicity is *rare*, but not that it is *bounded*.

---

## 8. Small values: the record at 3003

Theorem A turns the determination of any single multiplicity into a finite computation with an explicit radius.

**Proposition 8.1 (Effective search radius).** If $2\le n$ and $b$ is an integer with $2n<b(b-1)$, then
$$\mathcal{I}(n)=\{(N,k):\ N<b,\ k<b,\ 2\le k,\ k+2\le N,\ \tbinom{N}{k}=n\}.$$
Consequently, for $n\ge3$, $m(n)=2+\#\{(N,k): N,k<b,\ 2\le k\le N-2,\ \binom{N}{k}=n\}$.

*Proof sketch.* Any interior occurrence has $N(N-1)\le 2n<b(b-1)$, hence $N<b$ by monotonicity of $t\mapsto t(t-1)$; and $k<N<b$. $\square$

**Theorem G1.** $m(3003)=8$, with $\mathcal{O}(3003)=\{(14,6),(14,8),(15,5),(15,10),(78,2),(78,76),(3003,1),(3003,3002)\}$.

*Proof sketch.* Take $b=79$: $2\cdot3003=6006<79\cdot78=6162$. A finite search over $N,k<79$ finds exactly six interior occurrences, and Proposition 8.1 with Theorem B gives $8$. $\square$

The same method gives $m(6)=m(20)=m(70)=m(252)=m(924)=3$ (radii $b=5,7,13,23,44$) and $m(120)=6$ (radius $b=17$).

**Lemma 8.2 (Small central binomials).** If $3\le n<3003$ and $n=\binom{2t}{t}$, then $n\in\{6,20,70,252,924\}$.
*Proof sketch.* $\binom{2t}{t}$ is strictly increasing and $\binom{14}{7}=3432>3003$, so $t\le6$; enumerate. $\square$

**Theorem G2 (Odd rigidity below the record).** If $3\le n<3003$ and $m(n)$ is odd, then $m(n)=3$.
*Proof.* By Theorem C, $n$ is a central binomial coefficient; by Lemma 8.2, $n\in\{6,20,70,252,924\}$; each of these has multiplicity $3$ by direct computation. $\square$

**Corollary G3.** For all $n<3003$, $m(n)\ne5$ and $m(n)\ne7$.

**Theorem G4 (No larger multiplicity below the record).** For all $n<3003$, $m(n)\le 8$.

*Proof sketch.* Combining Theorems B and C, for $n\ge3$
$$m(n)=2+2\,\iota_{\mathrm L}(n)+\gamma(n),$$
where $\iota_{\mathrm L}(n)$ counts the interior occurrences strictly left of centre (the boundary occurrence $(n,1)$ accounts for the "$2+$"). It therefore suffices to show $\iota_{\mathrm L}(n)\le3$, together with Theorem G2 to handle the case $\gamma(n)=1$ (in which $m(n)$ is odd and hence equals $3$).

For $3\le n<3003$, an interior occurrence $(N,k)$ with $2k<N$ satisfies $N\le78$ by Theorem A, and $k\le 6$: indeed if $k\ge7$ and $2k\le N$ then $\binom{N}{k}\ge\binom{2k}{k}\ge\binom{14}{7}=3432>3003$. So all such occurrences lie in the finite strip
$$S=\{(N,k):\ N<79,\ 2\le k\le 6,\ 2k\le N,\ \tbinom{N}{k}<3003\},$$
and a finite check shows that every fibre of the value map $\binom{\cdot}{\cdot}$ on $S$ has at most three elements. Hence $\iota_{\mathrm L}(n)\le3$ and $m(n)\le 2+6=8$ when $\gamma(n)=0$; when $\gamma(n)=1$, $m(n)=3$. $\square$

Theorem G4 upgrades $3003$ from "smallest known example of multiplicity $8$" to "record holder below $3003$": no smaller integer is more repeated.

---

## 9. The one-row-shift mechanism

We now turn to the production of high multiplicities. The classical source is a coincidence between adjacent rows.

**Theorem 9.1 (Row-shift criterion).** Let $k\le M$ and suppose
$$(M+1)(k+1)=(M+1-k)(M-k).$$
Then $\binom{M+1}{k}=\binom{M}{k+1}$.

*Proof sketch.* From the two multiplicative recurrences $\binom{M+1}{k}(M+1-k)=\binom{M}{k}(M+1)$ and $\binom{M}{k+1}(k+1)=\binom{M}{k}(M-k)$, multiply the target identity through by $(M+1-k)(k+1)>0$ and substitute; the hypothesis is exactly what is needed to cancel. $\square$

Writing $N=M+1$, the criterion reads
$$N(k+1)=(N-k)(N-k-1)\qquad(\ast)$$
and asserts $\binom{N}{k}=\binom{N-1}{k+1}$.

**Theorem H1 (Six occurrences from one shift).** Suppose $2\le k$, $k+4\le N$, $2k\ne N$, $2k+3\ne N$, and $(\ast)$ holds. Then $m\!\left(\binom{N}{k}\right)\ge 6$.

*Proof sketch.* Put $n=\binom{N}{k}$. By Theorem 9.1, $n=\binom{N-1}{k+1}$ as well. Reflecting, $n=\binom{N}{N-k}=\binom{N-1}{N-k-2}$. All four positions
$$(N,k),\quad (N,N-k),\quad (N-1,k+1),\quad (N-1,N-k-2)$$
are interior (using $k\ge2$ and $k+4\le N$) and pairwise distinct: the two in row $N$ differ because $2k\ne N$, the two in row $N-1$ differ because $2k+3\ne N$ (i.e. $k+1\ne N-k-2$), and positions in different rows are distinct. By Theorem B, $m(n)\ge 2+4=6$. $\square$

The following identity supplies the solutions.

**Lemma 9.2 (Even Cassini identity).** For all $i\ge0$, $F_{2i+1}^2=F_{2i}F_{2i+1}+F_{2i}^2+1$.
*Proof sketch.* Induction on $i$, expanding $F_{2i+3}=F_{2i+1}+F_{2i+2}$ and $F_{2i+2}=F_{2i}+F_{2i+1}$ and simplifying; this is the Cassini identity $F_{j+1}F_{j-1}-F_j^2=(-1)^j$ restricted to even index. $\square$

**Theorem H2 (Cassini pairs give six-fold coincidences).** Let $1\le a<b$ with $b^2=ab+a^2+1$. Then
$$m\!\left(\binom{(a+b)(a+2b)}{a(a+2b)}\right)\ \ge\ 6 .$$

*Proof sketch.* Set $N=(a+b)(a+2b)$ and $k=a(a+2b)$. A direct computation using $b^2=ab+a^2+1$ verifies $(\ast)$: both sides expand to polynomials in $a,b$ that agree modulo the Cassini relation. The side conditions of Theorem H1 hold because $N-k=b(a+2b)$ and $a+2b\ge5$, which gives $k+4\le N$, $2k\ne N$ and $2k+3\ne N$. $\square$

**Theorem H (Fibonacci ladder).** For every $i\ge1$, with
$$N_i=F_{2i+2}F_{2i+3},\qquad k_i=F_{2i}F_{2i+3},$$
we have $m\!\left(\binom{N_i}{k_i}\right)\ge6$. Hence $\{n:\ m(n)\ge6\}$ is infinite.

*Proof.* Apply Theorem H2 with $(a,b)=(F_{2i},F_{2i+1})$, legitimate by Lemma 9.2 and $1\le F_{2i}<F_{2i+1}$ for $i\ge1$; note $a+b=F_{2i+2}$ and $a+2b=F_{2i+3}$. Infinitude follows since $N_i\to\infty$ and $\binom{N_i}{k_i}\ge N_i$. $\square$

The ladder begins
$$(N_1,k_1)=(15,5),\quad (N_2,k_2)=(104,39),\quad (N_3,k_3)=(714,272),\quad (N_4,k_4)=(4895,1869),$$
with $\binom{15}{5}=3003$ the smallest member; $\binom{104}{39}$ already has $29$ digits.

**Theorem I (Cassini classification).** For integers $0\le a\le b$,
$$b^2=ab+a^2+1\iff \exists\, i\ge0:\ a=F_{2i},\ b=F_{2i+1}.$$

*Proof sketch.* ($\Leftarrow$) is Lemma 9.2. ($\Rightarrow$) is a Vieta descent. Given a solution with $1\le a\le b$, one checks $b\le 2a$ (if $b\ge 2a+1$ then $b^2-ab-a^2=b(b-a)-a^2\ge(2a+1)(a+1)-a^2=a^2+3a+1>1$), so $(a',b')=(2a-b,\ b-a)$ has non-negative entries with $a'\le b'$ and again $b'^2=a'b'+a'^2+1$; moreover $b'<b$ when $a\ge1$. The descent must terminate, and the only solution with $a=0$ is $(0,1)=(F_0,F_1)$. The ascent step is $(a,b)\mapsto(a+b,\ a+2b)$, which shifts the Fibonacci index by two. $\square$

Theorem I says that the *input* of the mechanism of Theorem H2 is exactly the Fibonacci input. It leaves open whether the *equation* $(\ast)$ has other solutions. That is the content of the next section.

---

## 10. Main theorem: classification of the row-shift equation

**Lemma 10.1 (Polynomial form).** For integers $k+2\le N$,
$$N(k+1)=(N-k)(N-k-1)\iff k^2+k+N^2=3Nk+2N .$$
*Proof sketch.* Substitute $N=k+m+2$ with $m\ge0$ to remove truncated subtraction; both sides become the same polynomial identity in $k,m$. $\square$

The right-hand form is a symmetric-looking conic, monic and quadratic in each variable separately. This is exactly the setting for Vieta jumping.

**Lemma 10.2 (Vieta involution in the row).** Suppose $k^2+k+N^2=3Nk+2N$ and set $M=3k+2-N$. Then
$$NM=k^2+k\qquad\text{and}\qquad k^2+k+M^2=3Mk+2M .$$
*Proof sketch.* The equation says $N$ is a root of $X^2-(3k+2)X+(k^2+k)=0$; the second root is $M=3k+2-N$ with product $k^2+k$, and satisfies the same equation. $\square$

**Lemma 10.3 (Vieta involution in the column).** Suppose $k^2+k+N^2=3Nk+2N$ and set $j=3N-1-k$. Then
$$kj+2N=N^2\qquad\text{and}\qquad j^2+j+N^2=3Nj+2N .$$
*Proof sketch.* The equation says $k$ is a root of $Y^2-(3N-1)Y+(N^2-2N)=0$; the second root is $j=3N-1-k$ with product $N^2-2N$. $\square$

**Lemma 10.4 (Descent in the row).** Let $1\le k$, $2k\le N$, $N+M=3k+2$ and $NM=k^2+k$. Then
$$2\le M,\qquad M<N,\qquad 2M\le k+1 .$$
*Proof sketch.* From $NM=k(k+1)>0$ and $N\ge 2k\ge2$ we get $M\ge1$; $M=1$ would give $N=k^2+k$ and $N+1=3k+2$, i.e. $k^2+k = 3k+1$, impossible for integers, so $M\ge2$. Since $N\ge 2k$ and $N+M=3k+2$ we get $M\le k+2$, whence $M\le N$; equality $M=N$ would force $N^2=k^2+k$, impossible as $k^2<k^2+k<(k+1)^2$ for $k\ge1$. Finally $NM=k(k+1)$ with $N\ge2k$ yields $2kM\le k(k+1)$, so $2M\le k+1$. $\square$

**Lemma 10.5 (Descent in the column).** Let $2\le M$, $2M\le k+1$ and $k^2+k+M^2=3Mk+2M$. Then $j=3M-1-k$ satisfies $k+j+1=3M$, $2j\le M$ and $j^2+j+M^2=3Mj+2M$; moreover $j\ge0$.
*Proof sketch.* Lemma 10.3 with the roles of the variables exchanged gives the equation and $kj=M^2-2M$. Since $2M\le k+1$, the product relation forces $j$ small: $kj=M(M-2)$ and $k\ge 2M-1$ give $(2M-1)j\le M(M-2)$, hence $2j\le M$. $\square$

Thus $(N,k)\mapsto(M,j)$ with $M=3k+2-N$ and $j=3M-1-k$ is a *strictly decreasing* self-map of the admissible region $\{1\le k,\ 2k\le N\}$. The reverse step is where the Fibonacci numbers appear.

**Lemma 10.6 (Ascent).** Let $b^2=ab+a^2+1$ and suppose
$$M=(a+b)(a+2b),\quad j=a(a+2b),\quad k+j+1=3M,\quad N+M=3k+2 .$$
Then
$$N=(2a+3b)(3a+5b),\qquad k=(a+b)(3a+5b).$$
*Proof sketch.* Solve the two linear relations for $k$ and $N$ and simplify using $b^2=ab+a^2+1$; both resulting polynomial identities in $a,b$ are instances of the Cassini relation. $\square$

Since $(a,b)=(F_{2i},F_{2i+1})$ gives $a+b=F_{2i+2}$, $a+2b=F_{2i+3}$, $2a+3b=F_{2i+4}$, $3a+5b=F_{2i+5}$, Lemma 10.6 says precisely that the ascent moves one rung up the ladder.

**Theorem J (Row-shift classification).** Let $N,k$ be integers with $N\ge1$, $2k\le N$ and
$$k^2+k+N^2=3Nk+2N .$$
Then there exists $i\ge0$ with
$$N=F_{2i+2}F_{2i+3},\qquad k=F_{2i}F_{2i+3}.$$
Equivalently, for $2\le k$ and $2k\le N$,
$$N(k+1)=(N-k)(N-k-1)\iff \exists\, i\ge1:\ N=F_{2i+2}F_{2i+3},\ k=F_{2i}F_{2i+3}.$$

*Proof sketch.* Strong induction on $N$. If $k=0$ the equation becomes $N^2=2N$, so $N=2$, giving the degenerate base $(N,k)=(2,0)=(F_2F_3,\ F_0F_3)$, i.e. $i=0$. If $k\ge1$, form $M=3k+2-N$ and $j=3M-1-k$. Lemmas 10.2–10.5 show $(M,j)$ is again a solution with $M<N$, $2j\le M$ and $M\ge2$, so the inductive hypothesis applies: $M=F_{2i+2}F_{2i+3}$ and $j=F_{2i}F_{2i+3}$ for some $i\ge0$. Writing $a=F_{2i}$, $b=F_{2i+1}$ (so $M=(a+b)(a+2b)$, $j=a(a+2b)$, and $b^2=ab+a^2+1$ by Lemma 9.2), Lemma 10.6 yields
$$N=(2a+3b)(3a+5b)=F_{2i+4}F_{2i+5},\qquad k=(a+b)(3a+5b)=F_{2i+2}F_{2i+5},$$
which is the statement for index $i+1$. For the "equivalently" clause, Lemma 10.1 converts between the two forms (note $2\le k$ and $2k\le N$ force $k+2\le N$), and $k\ge2$ excludes the degenerate $i=0$ member $(2,0)$. The converse direction — that each Fibonacci pair really is a solution — is a direct computation from Lemma 9.2, together with the admissibility facts $2F_{2i}F_{2i+3}\le F_{2i+2}F_{2i+3}$ and $F_{2i}F_{2i+3}+2\le F_{2i+2}F_{2i+3}$. $\square$

**Corollary K (Pell shadow).** If $2\le k$, $2k\le N$ and $N(k+1)=(N-k)(N-k-1)$, then
$$(3N-1-2k)^2=5N^2+2N+1 .$$
In particular $5N^2+2N+1$ is a perfect square, equivalently $(5N+1)^2-5(3N-1-2k)^2=-4$.

*Proof sketch.* Expand: $(3N-1-2k)^2-\bigl(5N^2+2N+1\bigr)=4\bigl(k^2+k+N^2-3Nk-2N\bigr)$, which vanishes by Lemma 10.1. $\square$

At $(N,k)=(15,5)$ this reads $34^2=1156=5\cdot225+30+1$, with $5N+1=76=L_9$ and $3N-1-2k=34=F_9$ — the classical Lucas–Fibonacci solutions of $X^2-5Y^2=-4$. It is worth emphasising that Theorem J does *not* use Pell theory: the descent is self-contained, and the Pell equation appears only as a consequence.

**Corollary L (The mechanism is exhausted).** If $2\le k$, $2k\le N$ and $\binom{N}{k}=\binom{N-1}{k+1}$, then there is an $i\ge1$ with
$$\binom{N}{k}=\binom{F_{2i+2}F_{2i+3}}{F_{2i}F_{2i+3}}\qquad\text{and}\qquad m\!\left(\tbinom{N}{k}\right)\ge6 .$$
Thus the one-row shift produces exactly one infinite family of six-fold coincidences: the Fibonacci ladder.

---

## 11. Algorithms

Three algorithms underlie the computational statements above; each is elementary but their complexity profiles differ sharply.

**Algorithm 1 (Multiplicity by row/column squeeze).** To compute $m(n)$ for $n\ge3$: output $2+\iota(n)$, where $\iota(n)$ is found by iterating over rows $N$ with $N(N-1)\le 2n$ (so $N=O(\sqrt n)$) and, in each row, over columns $k=2,3,\dots$ while $\binom{N}{k}\le n$ (so $k=O(\log n)$), recording hits and their reflections. The cost is $O(\sqrt n\log n)$ binomial evaluations, each obtainable incrementally by a single multiplication and division from the previous entry. A naive scan over all $N\le n$ would cost $O(n\log n)$; the squeeze is a quadratic speedup.

**Algorithm 2 (Detecting an odd multiplicity).** By Theorem C, $m(n)$ is odd iff $n$ is a central binomial coefficient. Since $\binom{2t}{t}\ge 2^t$, it suffices to test $t\le\log_2 n$, generating $\binom{2t}{t}$ by the recurrence $(t+1)\binom{2t+2}{t+1}=2(2t+1)\binom{2t}{t}$: an $O(\log n)$-step test that avoids any search of the triangle at all.

**Algorithm 3 (Vieta descent for the row-shift equation).** Given $(N,k)$ with $2k\le N$, repeatedly replace $(N,k)$ by $(3k+2-N,\ 3(3k+2-N)-1-k)$. By Lemmas 10.4–10.5 the row index strictly decreases while admissibility is preserved, so the process terminates; it terminates at $(2,0)$ precisely when the original pair solved $k^2+k+N^2=3Nk+2N$. Since consecutive rungs of the ladder grow like $\varphi^{4}\approx6.85$ (where $\varphi$ is the golden ratio), the number of steps is $O(\log N)$ and each step is $O(1)$ arithmetic operations. Reversing the recursion — $(a,b)\mapsto(a+b,a+2b)$ on the Cassini side — enumerates all solutions up to any bound in linear time in the output size.

---

## 12. Discussion

**What is proved, and what the obstruction is.** The results split cleanly into *lower-bound mechanisms* (Theorems H, H1, H2: coincidences push multiplicity up) and *upper-bound obstructions* (Theorems A, C, D, E, F, G4: geometry, parity, and divisibility push it down). Singmaster's conjecture is the assertion that the obstructions ultimately dominate uniformly. What the present development shows is that each individual obstruction we possess is *local*: Theorem D applies only to numbers with a large prime factor; Theorem E only to $\binom{p}{2}$; Theorem G4 only below $3003$; Theorem F bounds the number of exceptions but says nothing about the size of the multiplicity at any single exception. No known argument bounds $m$ globally, and the gap between the truth (conjecturally $8$) and the best unconditional bounds is enormous.

**Why the parity law matters.** Theorem C is the strongest *structural* statement here: it converts a counting question into an identification question. An integer of odd multiplicity must be a central binomial coefficient, of which there are only $O(\log x)$ below $x$. This forces the exceptional multiplicities to be even; the observed spectrum $\{2,4,6,8\}$ for $n>2$ (with the sole odd exceptions being central binomials of multiplicity $3$) is thus fully explained on the parity side. The absence of $5$ and $7$ below $3003$ is then not a coincidence but a theorem (Corollary G3): $5$ and $7$ would demand a central binomial coefficient with two or three extra reflected pairs.

**Significance of the classification.** Theorem J closes the one-row-shift mechanism completely. Before it, one could imagine a sporadic non-Fibonacci solution of $(\ast)$ seeding an unnoticed family of six-fold coincidences; now we know the equation is *rigid*. The proof mechanism is worth isolating: the row-shift equation is monic and quadratic in each of its two variables separately, so it carries two commuting Vieta involutions,
$$\sigma:(N,k)\mapsto(3k+2-N,\ k),\qquad \tau:(N,k)\mapsto(N,\ 3N-1-k),$$
and the composite $\tau\circ\sigma$ generates the solution set from the degenerate seed $(2,0)$. This is the same structural phenomenon as in classical Vieta-jumping problems (Markov triples being the archetype), and the Fibonacci ladder is the orbit of the seed. Corollary K then situates the family inside the Pell equation $X^2-5Y^2=-4$, whose solution set is the Lucas–Fibonacci pairs — but as a *consequence*, not as an input; the descent argument is strictly more elementary than the Pell machinery originally expected to be necessary.

**The unexplained half of 3003.** Notably, the record at $3003$ is not fully accounted for by the ladder. The ladder explains the four occurrences in rows $14$ and $15$; the further coincidence $3003=\binom{78}{2}$ is a *distant-row* coincidence, of the type $\binom{N}{2}=\binom{M}{k}$ for far apart $N,M$, and no mechanism produces an infinite family of these. Whether the numbers of multiplicity $8$ are finite or infinite is unknown — indeed it is unknown whether any integer other than $3003$ has multiplicity $8$.

---

## 13. Future work

Several concrete directions remain.

1. **Two-row shifts and general coincidence equations.** The natural sequel to Theorem J is the classification of $\binom{N}{k}=\binom{N-2}{k+r}$ for small $r$, and more generally of $\binom{N}{k}=\binom{N'}{k'}$ with $N-N'$ bounded. Each such equation is again polynomial and low-degree; whether it admits Vieta involutions of the same type, and whether its solutions are again governed by a linear recurrence, is open. A negative answer for every shift would be strong evidence for Singmaster's conjecture; a positive answer for some shift would produce a new infinite family, possibly with multiplicity $\ge8$.
2. **Multiplicity exactly six.** Theorem H gives $m\ge6$ along the ladder, but does it give $m=6$ exactly? Establishing $m\!\left(\binom{N_i}{k_i}\right)=6$ for large $i$ would require ruling out all further coincidences at a single ladder value — a strong local Singmaster statement, presumably needing $abc$-type or Diophantine-approximation input.
3. **Improving the density bound.** The bound of Theorem F is $O(\sqrt x\log x)$; the truth appears to be $O(\sqrt x)$ or smaller, since the $\binom{N}{2}$ values already contribute $\sim\sqrt{2x}$ of the exceptions. Sharpening the column squeeze, or exploiting that most rectangle positions are not hit, should reduce the $\log$.
4. **Multiplicity three.** By Theorem C, $m(n)=3$ requires $n=\binom{2t}{t}$ with exactly one pair of non-central occurrences. Is $m\!\left(\binom{2t}{t}\right)=3$ for all $t\ge2$? Equivalently: does a central binomial coefficient ever coincide with a non-trivial, non-central entry? No example is known.
5. **Exact multiplicity families beyond $\binom{p}{2}$.** Theorem E exploits that $\binom{p}{2}$ has a prime factor just large enough. The analogous analysis of $\binom{p}{3}$, or of $\binom{p}{2}$ for prime powers, may give further exact-multiplicity families and thus more of the spectrum unconditionally.

---

## 14. Appendix: worked examples

**The record.** $n=3003$: search radius $b=79$ (since $6006<79\cdot78$); interior occurrences $(14,6),(14,8),(15,5),(15,10),(78,2),(78,76)$; plus $(3003,1),(3003,3002)$; total $8$.

**A three.** $n=924=\binom{12}{6}$: radius $b=44$; a single interior occurrence, the central one $(12,6)$; total $m=3$, consistent with the parity law since $924$ is a central binomial coefficient.

**A four.** $n=253=\binom{23}{2}$, $23$ prime: interior occurrences exactly $(23,2)$ and $(23,21)$, so $m=4$ by Theorem E.

**A two.** $n=58=2\cdot29$: the prime $29$ satisfies $29\cdot28=812>116=2n$, so $m(58)=2$ by Theorem D.

**A ladder rung.** $i=2$: $(N,k)=(104,39)$, $\binom{104}{39}=\binom{103}{40}$, a $29$-digit number with at least six occurrences. Its Vieta descent is $M=3\cdot39+2-104=15$, $j=3\cdot15-1-39=5$, landing on $(15,5)$ — the rung below, whose value is $3003$. One more step gives $M=3\cdot5+2-15=2$, $j=3\cdot2-1-5=0$: the degenerate seed.
