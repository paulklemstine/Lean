# Free Witnesses, Aggregation Depth, and the Localisation of the Quantum Advantage in Integer Factorisation

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

We study the *free-witness family* of a modulus $N$: the invariants
$R_k(N) = \#\{x \in (\mathbb{Z}/N)^\times : x^k = 1\}$, indexed by an exponent $k$. These are the
canonical structural quantities that an attacker can extract from $N$ alone, without side
information, and they underlie a large class of classical factoring heuristics.

We prove a complete classification of the family and derive from it a sharp map of what the family
can and cannot do. The *trace lemma* states that $R_k(pq) = \gcd(k,p-1)\gcd(k,q-1)$ for a semiprime,
$R_k(N) = \prod_{r \mid N}\gcd(k,r-1)$ for a squarefree modulus, and
$R_k(N) = \prod_{p \mid N} \gcd(\varphi(p^{v_p(N)}), k)$ for every odd modulus. Three consequences
follow.

*(i) An information-theoretic barrier.* For every finite exponent set $S$ and every prime $q$, there
exist infinitely many primes $p$ whose semiprimes $pq$ share one and the same joint profile
$(R_k(pq))_{k \in S}$; hence no function of the joint profile returns a prime factor. The
obstruction is not computational: colliding inputs are literally equal.

*(ii) An exact aggregation depth.* The family is nonetheless complete in the limit: $R_k(N) =
\varphi(N)$ holds precisely for the multiples of the Carmichael exponent $\lambda(N)$, and a single
complete witness yields the factorisation in closed form via
$p,q = \tfrac12\big(s \pm \sqrt{s^2-4N}\big)$ with $s = N+1-\varphi(N)$. The least positive complete
exponent is exactly $\lambda(N) = \operatorname{lcm}(p-1,q-1) = \varphi(N)/\gcd(p-1,q-1)$ for a
semiprime, and $\operatorname{lcm}_{p\mid N}\varphi(p^{v_p(N)})$ for every odd $N$ — exponential in
$\log N$. Even the crude divisibility bound $R_k(N) \mid k^2$ forces $k \ge \sqrt{\varphi(N)}$.

*(iii) Localisation of the quantum advantage.* Order finding computes a *classified* coordinate of
this same family, not an unclassified one: for $N = pq$ with distinct odd primes there are exactly
four square roots of unity, and each of the two nontrivial ones splits $N$ by a single greatest
common divisor. Hence the quantum speedup bypasses the aggregation cost, not the classification.

We also prove that the multiplicative smooth-step walk $x \mapsto xs \bmod N$ is sterile — every
visited value is a unit, so its greatest-common-divisor channel is identically trivial, and its
orbit is a coset of $\langle s\rangle$ — and we delimit the scope of the framework by pricing an
external hint: the additive hint $p+q$ amplifies to the full factorisation in closed form and
determines the ordered factor pair uniquely. Extraction from $N$ alone and amplification of external
hints are therefore different problems, and any hardness claim must declare which one it addresses.

**Keywords:** integer factorisation, roots of unity, Carmichael function, Dirichlet's theorem,
Chinese remainder theorem, order finding, aggregation barrier, cryptographic hardness.

---

## 1. Introduction

### 1.1 The problem and the frame

Let $N$ be a composite integer with unknown factorisation. Classical factoring algorithms come in
families — trial division and Fermat-type numeric methods, sieve methods (quadratic sieve, number
field sieve), Pollard's $p-1$ and $\rho$, elliptic-curve methods, lattice methods — and the best of
them run in subexponential but superpolynomial time. There is no proof that polynomial time is
impossible; there is also no serious candidate algorithm.

A productive intermediate goal is to prove *conditional* or *channel-restricted* impossibility: fix
a natural class of quantities that an algorithm may extract from $N$, and show that this class does
not carry enough information. The class studied here is the most canonical one attached to the
multiplicative structure of $\mathbb{Z}/N$.

**Definition 1.1 (Free witness).** For integers $N \ge 1$ and $k \ge 0$, the *free witness of
exponent $k$* is
$$R_k(N) \;=\; \#\{x \in (\mathbb{Z}/N\mathbb{Z})^\times \;:\; x^k = 1\},$$
the number of $k$-th roots of unity in the unit group modulo $N$.

The name records two properties: the quantity depends only on $N$ (it is *free* of side
information), and it is a *witness* in the sense that its value constrains the factorisation. The
family $\{R_k\}_{k \ge 1}$ is the natural target of any algorithm that probes the exponent structure
of $(\mathbb{Z}/N)^\times$ — Pollard's $p-1$, order finding, and their relatives all live here.

### 1.2 What we prove

The paper answers four questions about this family.

- **Classification.** What is $R_k(N)$, exactly? (Section 3.)
- **Joint closure.** Do finitely many witnesses, taken together, determine the factorisation?
  (Section 4.)
- **Cost of completeness.** The family does determine the factorisation in the limit; at what
  exponent does it first do so? (Section 5.)
- **Localisation.** What precisely does a quantum order-finding algorithm bypass? (Section 6.)

Sections 7 and 8 treat two boundary phenomena: the sterility of multiplicative random walks, and the
pricing of external hints, which delimits the scope of the whole framework. Section 9 assembles the
results into a single statement and Section 10 discusses the open frontier.

### 1.3 Summary of the main statements

$$
\begin{array}{ll}
\textbf{Trace lemma} & R_k(pq) = \gcd(k,p-1)\gcd(k,q-1) \\[2pt]
\textbf{Information budget} & R_k(pq) \mid k^2, \qquad R_k(r_1\cdots r_n) \le k^n \\[2pt]
\textbf{Joint closure} & \forall\, S \text{ finite},\ \nexists\, F:\ F\big((R_k(pq))_{k\in S}\big)=p \\[2pt]
\textbf{Completeness criterion} & R_k(pq)=\varphi(N) \iff \operatorname{lcm}(p-1,q-1)\mid k \\[2pt]
\textbf{Aggregation depth} & \min\{k>0: R_k(N)=\varphi(N)\} = \lambda(N) \\[2pt]
\textbf{Residue sufficiency} & \exists\, a:\ a^2\equiv 1,\ a\not\equiv\pm1 \Rightarrow \gcd(a-1,N)\in\{p,q\} \\[2pt]
\textbf{Hint amplification} & p = \tfrac12\big(s-\sqrt{s^2-4N}\big),\quad s = p+q
\end{array}
$$

---

## 2. Preliminaries

We use standard notation: $\varphi$ is Euler's totient, $\lambda$ the Carmichael function,
$\omega(N)$ the number of distinct prime factors, $v_p(N)$ the $p$-adic valuation, and
$(\mathbb{Z}/N)^\times$ the group of units modulo $N$. Three classical inputs are used, and nothing
deeper.

**Fact 2.1 (Cyclic root count).** In a finite cyclic group $G$ of order $n$, the equation $x^k = 1$
has exactly $\gcd(n,k)$ solutions.

*Proof sketch.* Write $G = \langle g \rangle$. Then $g^{jk} = 1$ iff $n \mid jk$ iff
$\tfrac{n}{\gcd(n,k)} \mid j$, and there are exactly $\gcd(n,k)$ residues $j$ modulo $n$ with that
property. Equivalently, the solution set is the kernel of the $k$-th power endomorphism, whose image
has index $\gcd(n,k)$. $\square$

**Fact 2.2 (Chinese remainder theorem for units).** If $\gcd(m,n)=1$ then the ring isomorphism
$\mathbb{Z}/mn \cong \mathbb{Z}/m \times \mathbb{Z}/n$ restricts to a group isomorphism
$(\mathbb{Z}/mn)^\times \cong (\mathbb{Z}/m)^\times \times (\mathbb{Z}/n)^\times$.

**Fact 2.3 (Dirichlet).** For coprime $a$ and $M$ with $M \ge 1$, the arithmetic progression
$a, a+M, a+2M, \dots$ contains infinitely many primes.

Two elementary lemmas about $R_k$ are recorded first, since everything else rests on them.

**Lemma 2.4 (Isomorphism invariance and multiplicativity).** Write $\rho_k(G) = \#\{x \in G : x^k =
1\}$ for a group $G$. Then $\rho_k$ is invariant under group isomorphism, and
$\rho_k(G \times H) = \rho_k(G)\,\rho_k(H)$.

*Proof sketch.* An isomorphism $e$ carries solutions to solutions in both directions because
$e(x)^k = e(x^k)$. For the product, $(x,y)^k = (x^k, y^k) = (1,1)$ iff $x^k=1$ and $y^k=1$, so the
solution set of the product is the product of solution sets. $\square$

**Lemma 2.5 (Multiplicativity of the free witness).** If $\gcd(m,n)=1$ then $R_k(mn) = R_k(m)R_k(n)$;
and $R_k(1) = 1$.

*Proof sketch.* Combine Facts 2.2 and Lemma 2.4. The trivial modulus has a trivial unit group.
$\square$

Lemma 2.5 is the precise sense in which the free-witness family is *CRT-separable*: it never mixes
information across coprime factors. This is simultaneously the reason the classification is
tractable and the reason the family is weak.

---

## 3. The trace lemma

### 3.1 Semiprimes

**Theorem 3.1 (Trace lemma).** Let $p \neq q$ be primes and $N = pq$. Then for all $k \ge 0$,
$$R_k(N) \;=\; \gcd(p-1,\,k)\cdot \gcd(q-1,\,k).$$

*Proof.* By Fact 2.2, $(\mathbb{Z}/N)^\times \cong (\mathbb{Z}/p)^\times \times
(\mathbb{Z}/q)^\times$. By Lemma 2.4 the root count is invariant under this isomorphism and
multiplicative across the product. Each factor is cyclic of order $p-1$, respectively $q-1$, so Fact
2.1 gives $\gcd(p-1,k)$ and $\gcd(q-1,k)$ solutions. Multiply. $\square$

Three immediate corollaries fix the shape of the family.

**Corollary 3.2 (Symmetry).** $R_k(pq) = R_k(qp)$: the family is symmetric in the two prime factors
and can therefore never, by itself, distinguish $p$ from $q$.

**Corollary 3.3 (Information budget).** $R_k(pq) \mid k^2$. In particular
$R_k(pq) \le k^2$, so a single free witness carries at most $2\log_2 k$ bits, uniformly in $N$.

*Proof.* Both gcds divide $k$. $\square$

**Corollary 3.4 (Square roots of unity).** If $p$ and $q$ are distinct *odd* primes then
$R_2(pq) = 4$.

*Proof.* $p-1$ and $q-1$ are even, so $\gcd(p-1,2) = \gcd(q-1,2) = 2$. $\square$

### 3.2 Squarefree and odd moduli

**Theorem 3.5 (Squarefree trace lemma).** Let $P$ be a finite set of distinct primes and
$N = \prod_{r \in P} r$. Then $R_k(N) = \prod_{r \in P} \gcd(r-1,\,k)$.

*Proof sketch.* Induct on $|P|$ using Lemma 2.5, the base case being $R_k(1)=1$; at each step the new
prime $r$ is coprime to the product of the others, and the local factor is $\gcd(r-1,k)$ by Fact 2.1
applied to the cyclic group $(\mathbb{Z}/r)^\times$. $\square$

**Corollary 3.6 (The residue coordinate counts prime factors).** If $N$ is odd and squarefree with
$\omega(N) = n$ distinct prime factors, then $R_2(N) = 2^{\,n}$.

This is a striking half-measure: the residue coordinate *knows* $\omega(N)$ exactly, while — by
Theorem 4.4 below — it still cannot name a single prime factor.

**Corollary 3.7 (Bounded-exponent budget, general squarefree case).** For $k \ge 1$,
$R_k(N) \le k^{\omega(N)}$: the leak per exponent grows only linearly in the number of prime
factors.

The squarefree restriction can be removed on the odd part, at the cost of one extra classical input:
the unit group $(\mathbb{Z}/p^e)^\times$ is cyclic of order $\varphi(p^e)$ for every odd prime $p$.

**Theorem 3.8 (Trace lemma for odd moduli).** Let $N$ be odd and nonzero. Then
$$R_k(N) \;=\; \prod_{p \mid N} \gcd\!\big(\varphi(p^{v_p(N)}),\, k\big).$$

*Proof sketch.* Decompose $N = \prod_{p \mid N} p^{v_p(N)}$ into pairwise coprime prime powers and
apply Lemma 2.5 repeatedly (formally, an induction over the set of prime divisors, using that
distinct prime powers are coprime). Each local factor is a cyclic group of order
$\varphi(p^{v_p(N)})$ because $p$ is odd, so Fact 2.1 gives the local gcd. $\square$

**Remark 3.9 (The 2-adic obstruction).** Oddness is used exactly once, and essentially: for
$e \ge 3$ the group $(\mathbb{Z}/2^e)^\times \cong \mathbb{Z}/2 \times \mathbb{Z}/2^{e-2}$ is not
cyclic, so its root count is $\gcd(2,k)\cdot\gcd(2^{e-2},k)$ rather than
$\gcd(\varphi(2^e),k) = \gcd(2^{e-1},k)$. The even part therefore *shortens* the aggregation depth,
by a bounded factor; see Section 10.

### 3.3 Interpretation

Theorems 3.1, 3.5 and 3.8 say that the entire free-witness family factors through the local
gcd-residue coordinates $\gcd(\varphi(p^{v_p}), k)$ and through nothing else. Every algorithm that
reads only free witnesses is therefore an algorithm that reads only those coordinates. The remainder
of the paper studies what such an algorithm can do.

---

## 4. Joint closure: aggregation is information-theoretically insufficient

A single witness is bounded by $k^2$ and cannot suffice. The natural strengthening is to read many
witnesses at once.

**Definition 4.1 (Joint profile).** For a finite set $S \subseteq \mathbb{Z}_{>0}$ of exponents, the
*$S$-profile* of a modulus $N$ is the function
$$\Pi_S(N) : k \longmapsto \begin{cases} R_k(N) & k \in S,\\ 0 & k \notin S,\end{cases}$$
so that profiles of different moduli are comparable as objects of one type.

**Definition 4.2 (Saturating prime).** A prime $p$ *saturates* $S$ if $\gcd(p-1, k) = k$ for every
$k \in S$; equivalently, if $k \mid p-1$ for all $k \in S$.

**Lemma 4.3 (Saturating primes are abundant).** Let $S$ be a finite set of positive integers and
put $M = \prod_{k \in S} k$. For every bound $n$ there is a prime $p > n$ with
$p \equiv 1 \pmod M$; every such prime saturates $S$.

*Proof.* $M \ge 1$ and $\gcd(1,M)=1$, so Fact 2.3 supplies infinitely many primes
$p \equiv 1 \pmod M$, and in particular one exceeding $n$. For such $p$ we have $M \mid p-1$ and
$k \mid M$ for each $k \in S$, hence $k \mid p-1$ and $\gcd(p-1,k)=k$. $\square$

**Theorem 4.4 (Joint-closure theorem).** Let $S$ be a finite set of positive integers and let $q$ be
a prime. Then the set
$$\Big\{\,p \text{ prime} \;:\; p > q,\ \Pi_S(pq) = \big(k \mapsto k\cdot\gcd(q-1,k)\ \text{on } S\big) \Big\}$$
is infinite. Consequently there exist distinct primes $p \neq p'$, both larger than $q$, with
$$\Pi_S(pq) \;=\; \Pi_S(p'q),$$
and there is **no** function $F$ with $F\big(\Pi_S(pq)\big) = p$ for all primes $p > q$.

*Proof.* Let $p$ saturate $S$ (Lemma 4.3, with $n$ arbitrary), and let $p \neq q$. By Theorem 3.1,
for $k \in S$,
$$R_k(pq) = \gcd(p-1,k)\gcd(q-1,k) = k\,\gcd(q-1,k),$$
which is independent of $p$. Since Lemma 4.3 produces saturating primes above any bound, the
displayed set is infinite; pick two distinct members $p \neq p'$ to obtain a collision. If a function
$F$ as in the statement existed, then $p = F(\Pi_S(pq)) = F(\Pi_S(p'q)) = p'$, a contradiction.
$\square$

Two remarks explain why this is stronger than a typical hardness statement.

**Remark 4.5 (Information-theoretic, not computational).** The colliding inputs are *equal*, not
merely indistinguishable to an efficient observer. No amount of running time, nondeterminism, or
advice depending only on the profile can separate them. The barrier applies to unbounded
adversaries.

**Remark 4.6 (Where the profile lives).** By Theorem 3.1, $R_k(pq) \le k\gcd(q-1,k)$ for every
$k > 0$ — the saturating value is the top of a finite divisor lattice. The $S$-profile takes values
in the finite set $\prod_{k \in S} \operatorname{div}(k) \times \operatorname{div}(q-1)$; as $p$
ranges over infinitely many primes, collisions are forced by pigeonhole even before Dirichlet is
invoked. Dirichlet's role is to make the collision *explicit and constructive*: the colliding class
is precisely the saturating one.

**Example 4.7 (An explicit collision).** Take $S = \{6,12,15,20,30,60\}$, whose least common multiple
is $60$, and $q = 7$. Both $61$ and $181$ are primes congruent to $1$ modulo $60$, hence saturate
$S$. Therefore the distinct semiprimes $427 = 61\cdot 7$ and $1267 = 181\cdot 7$ have identical
$S$-profiles, namely $k \mapsto k\cdot\gcd(6,k)$ on $S$:
$$\Pi_S = \big(6\!\cdot\!6,\ 12\!\cdot\!6,\ 15\!\cdot\!3,\ 20\!\cdot\!2,\ 30\!\cdot\!6,\ 60\!\cdot\!6\big) = (36, 72, 45, 40, 180, 360).$$

Theorem 4.4 is what we call *closure under joints*: joining partial witnesses never yields a complete
one. Every additional exponent shrinks the colliding family but never empties it.

---

## 5. The exact cost of completeness

Theorem 4.4 concerns finite exponent sets and bounded exponents. It leaves open — deliberately — the
possibility that the family closes at very large exponents. It does, and the threshold is exact.

### 5.1 Completeness criterion

**Lemma 5.1 (Maximality).** For $N = pq$, $R_k(N) \le (p-1)(q-1) = \varphi(N)$ for all $k$.

*Proof.* Each gcd is at most its first argument. $\square$

**Lemma 5.2 (Cancellation).** If $a \le A$, $b \le B$, $A,B > 0$ and $ab = AB$, then $a = A$ and
$b = B$.

*Proof.* If $a < A$ then $ab \le aB < AB$, contradiction; so $a = A$, and then $b = B$ by
cancellation. $\square$

**Theorem 5.3 (Completeness criterion).** For $N = pq$ with $p \ne q$ prime,
$$R_k(N) = \varphi(N) \iff (p-1)\mid k \ \text{ and }\ (q-1)\mid k \iff \operatorname{lcm}(p-1,q-1)\mid k.$$

*Proof.* By Theorem 3.1, $R_k(N) = \gcd(p-1,k)\gcd(q-1,k)$ with $\gcd(p-1,k) \le p-1$ and
$\gcd(q-1,k)\le q-1$. If the product equals $(p-1)(q-1)$ then by Lemma 5.2 both factors are maximal,
i.e. $(p-1)\mid k$ and $(q-1)\mid k$. Conversely those divisibilities make each gcd maximal. The last
equivalence is the universal property of the least common multiple. $\square$

The same argument, with the termwise cancellation lemma extended to finite products by induction,
gives the general statements.

**Theorem 5.4 (Completeness criterion, squarefree and odd).** For squarefree $N = \prod_{r\in P} r$,
$R_k(N) = \prod_{r \in P}(r-1) = \varphi(N)$ iff $(r-1) \mid k$ for all $r \in P$. For odd $N \ne 0$,
$R_k(N) = \varphi(N)$ iff $\varphi(p^{v_p(N)}) \mid k$ for every prime $p \mid N$.

### 5.2 A complete witness factors

**Lemma 5.5 (Totient–trace identity).** For $p, q \ge 1$: $(p-1)(q-1) + (p+q) = pq + 1$.

**Definition 5.6 (Closed-form trace extractor).** For integers $N$ and $s$, set
$$\Phi(N, s) \;=\; \frac{s - \sqrt{s^2 - 4N}}{2}.$$

**Theorem 5.7 (Trace inversion).** If $p \le q$ then $\Phi(pq,\ p+q) = p$.

*Proof.* Write $q = p + d$ with $d \ge 0$. Then $s = 2p+d$ and
$s^2 - 4N = (2p+d)^2 - 4p(p+d) = d^2$, so $\sqrt{s^2-4N} = d$ and
$\Phi = (2p+d-d)/2 = p$. $\square$

**Theorem 5.8 (A complete witness yields the factorisation).** Let $N = pq$ with $q \le p$, and
suppose $R_k(N) = \varphi(N)$ for some $k$. Then
$$\Phi\big(N,\ N + 1 - R_k(N)\big) = q,$$
i.e. one closed-form evaluation recovers the smaller prime factor.

*Proof.* By hypothesis and Lemma 5.5, $N + 1 - R_k(N) = pq + 1 - (p-1)(q-1) = p+q$; now apply
Theorem 5.7. $\square$

In particular the exponent $k = \operatorname{lcm}(p-1,q-1)$ is complete (Theorem 5.3) and therefore
closes the factorisation. **The free-witness family is complete.** The question is the price.

### 5.3 Lower bounds on the complete exponent

**Theorem 5.9 (Crude aggregation cost).** If $k > 0$ and $R_k(pq) = \varphi(N)$, then
$\varphi(N) \le k^2$; equivalently $k \ge \sqrt{\varphi(N)} \approx \sqrt N$.

*Proof.* By Corollary 3.3, $R_k(N) \mid k^2$, and $k^2 > 0$, so $R_k(N) \le k^2$. $\square$

**Theorem 5.10 (Sharp aggregation cost).** Let $N = pq$. Then
$$\min\{k > 0 : R_k(N) = \varphi(N)\} \;=\; \operatorname{lcm}(p-1,q-1) \;=\; \frac{\varphi(N)}{\gcd(p-1,q-1)},$$
and this minimum is attained: the set of complete exponents is exactly the set of its positive
multiples. Consequently $\varphi(N) \le \gcd(p-1,q-1)\cdot k$ for every positive complete $k$.

*Proof.* By Theorem 5.3, the complete exponents are the multiples of $L = \operatorname{lcm}(p-1,q-1)$,
and $L > 0$ since $p,q \ge 2$. A positive multiple of $L$ is at least $L$, and $L$ itself is
complete, so $L$ is the least element of the set. The identity
$\gcd(p-1,q-1)\cdot L = (p-1)(q-1) = \varphi(N)$ gives both the displayed formula and the final
inequality. $\square$

**Theorem 5.11 (Aggregation depth of a general modulus).** For squarefree $N = \prod_{r\in P} r$ the
least positive complete exponent is $\operatorname{lcm}_{r \in P}(r-1)$; for every odd $N \ne 0$ it
is
$$\lambda(N) \;=\; \operatorname{lcm}_{p \mid N}\ \varphi\!\big(p^{v_p(N)}\big),$$
the Carmichael exponent of $N$ — the exponent of the group $(\mathbb{Z}/N)^\times$.

*Proof sketch.* By Theorem 5.4 the complete exponents are exactly the common multiples of the local
totients; the least positive such is their least common multiple, which is positive because each
local totient is. $\square$

### 5.4 The dichotomy

**Theorem 5.12 (Aggregation dichotomy).** For a semiprime $N = pq$ with $q \le p$:

1. *(completeness)* $\Phi\big(N,\ N+1-R_{\operatorname{lcm}(p-1,q-1)}(N)\big) = q$; and
2. *(cost)* every positive $k$ with $R_k(N) = \varphi(N)$ satisfies $k \ge \sqrt{\varphi(N)}$, and in
   fact $k \ge \varphi(N)/\gcd(p-1,q-1)$.

For cryptographically generated primes one typically has $\gcd(p-1,q-1) = 2$, so the least complete
exponent is $\varphi(N)/2 \approx N/2$: linear in $N$, exponential in $\log N$. Completeness and
efficiency are mutually exclusive within this channel — this is the quantitative form of the
aggregation barrier, and it matches the $O(N)$ aggregation cost observed empirically.

---

## 6. Localising the quantum advantage

Shor's algorithm factors in polynomial time on a quantum computer by computing the multiplicative
order $\operatorname{ord}_N(a)$ of a random unit $a$. The question we answer is precisely *which*
step of the classical picture this bypasses.

The order of $a$ is not a quantity outside the free-witness classification; it is the dual
description of the very same data. Indeed $\operatorname{ord}_N(a) \mid k$ iff $a$ is counted by
$R_k(N)$, so the family $\{R_k(N)\}_k$ is exactly the cumulative distribution function of the order
statistic. The trace lemma computes that distribution in closed form. Therefore **order finding
computes a classified coordinate.** What it does not do classically is *locate* one cheaply — and
that is exactly the aggregation cost of Theorem 5.10.

The following theorem shows that once the coordinate is located, the rest is elementary and
unconditional.

**Theorem 6.1 (Residue-witness sufficiency).** Let $p \ne q$ be distinct odd primes and $N = pq$.
Then there exists an integer $a$ with
$$N \mid a^2 - 1, \qquad N \nmid a-1, \qquad N \nmid a+1,$$
and for any such $a$, $\gcd(a-1, N) \in \{p, q\}$ — a nontrivial prime factor of $N$.

*Proof.* Existence is constructive: by Fact 2.2, let $a$ be the residue corresponding to
$(1, -1) \in (\mathbb{Z}/p)^\times \times (\mathbb{Z}/q)^\times$. Then $a^2$ corresponds to
$(1,1)$, so $N \mid a^2-1$. If $N \mid a-1$ then $a \equiv 1$, so its $q$-component would be $1$, but
it is $-1 \ne 1$ since $q$ is odd. If $N \mid a+1$ then $a \equiv -1$, so its $p$-component would be
$-1 \ne 1$, contradiction since it is $1$ and $p$ is odd.

For sufficiency, let $a$ be any such integer. From $N = pq \mid (a-1)(a+1)$ we get $p \mid (a-1)(a+1)$
and $q\mid(a-1)(a+1)$, so each of $p, q$ divides $a-1$ or $a+1$. They cannot both divide $a-1$ (else
$N \mid a-1$) nor both divide $a+1$ (else $N \mid a+1$). Hence exactly one of them divides $a-1$, and
$\gcd(a-1, N)$ is that prime. $\square$

**Theorem 6.2 (The witness is not rare).** For $N = pq$ with distinct odd primes there are exactly
$R_2(N) = 4$ square roots of unity modulo $N$; two of them are $\pm 1$ and each of the other two
splits $N$ by Theorem 6.1. For odd squarefree $N$, the count is $2^{\omega(N)}$, of which $2$ are
trivial.

*Proof.* Corollary 3.4 and Corollary 3.6; the constructed $a$ of Theorem 6.1 is a square root of
unity that is neither $1$ nor $-1$. $\square$

**Corollary 6.3 (Localisation).** The quantum speedup in factoring is attributable to the
*aggregation* step, not to the classification of witnesses:

- the coordinate order finding reads is fully classified (Theorem 3.1) and its population is known
  exactly (Theorem 6.2) — half of the square roots of unity are useful;
- the classical post-processing from that coordinate to a factor is unconditional and constant-time
  (Theorem 6.1);
- yet within the classical free-witness channel the coordinate is unreachable by any finite
  aggregation (Theorem 4.4) and reachable only at exponent depth $\lambda(N)$ (Theorem 5.10).

In this precise sense the quantum channel is a genuine counterexample to *classical aggregation
necessity*, and to nothing else in the framework.

---

## 7. Multiplicative walks are sterile

Randomised factoring methods in the Pollard tradition search for a factor through the
greatest-common-divisor channel: iterate a map on residues and test $\gcd(\cdot, N)$ at each step. A
natural "smooth-step" variant multiplies by a fixed smooth $s$.

**Definition 7.1 (Smooth-step walk).** For a modulus $N$, seed $x$ and step $s$, define
$w_0 = x \bmod N$ and $w_{t+1} = w_t\, s \bmod N$.

**Lemma 7.2 (Closed form).** $w_t = x s^t \bmod N$ for all $t \ge 0$.

*Proof.* Induction: $w_{t+1} = (x s^t \bmod N)\, s \bmod N = x s^{t+1} \bmod N$. $\square$

**Theorem 7.3 (Sterility).** If $\gcd(x,N) = 1$ and $\gcd(s,N)=1$ then $\gcd(w_t, N) = 1$ for every
$t$. In particular no $w_t$ ever produces a nontrivial divisor of $N$ through the
greatest-common-divisor channel.

*Proof.* Induction on $t$: units are closed under multiplication, and reduction modulo $N$ preserves
coprimality to $N$. $\square$

**Theorem 7.4 (The orbit is a coset).** If $s^r \equiv 1 \pmod N$ then $w_{t+r} = w_t$ for all $t$;
in particular, if $s$ is a unit of multiplicative order $r$, the walk is periodic with period
dividing $r$ and visits at most $r$ distinct values.

*Proof.* $x s^{t+r} = (x s^t)s^r \equiv x s^t \pmod N$. $\square$

**Interpretation.** The walk carries no randomness beyond the cyclic subgroup $\langle s \rangle$; its
"birthday floor" is $|\langle s\rangle| = \operatorname{ord}_N(s)$, and its greatest-common-divisor
channel is identically trivial. The only exploitable resource is the *smoothness* of the visited
values, which is exactly what the quadratic sieve and number field sieve already use, and which
yields subexponential — via the Dickman–de Bruijn smoothness density — but never polynomial running
time. A multiplicative walk is a sieve wearing a walk mask.

Note the contrast with Pollard's $\rho$, whose iteration is *additive-quadratic* ($x \mapsto x^2 + c$)
and hence can leave the unit group; that is precisely why $\rho$ can emit a nontrivial gcd, and the
smooth-step walk cannot.

---

## 8. Pricing an external hint: the scope of the framework

The results above concern extraction from $N$ alone. Real attacks sometimes have side information,
and methods in the Coppersmith small-root tradition amplify roughly half the bits of $p$ into the
full factorisation in polynomial time. To see that this is not a counterexample but a change of
problem, we price the simplest possible hint.

**Theorem 8.1 (Hint amplification).** Let $N = pq$ with $p \le q$ and let $s = p+q$ be given. Then
$\Phi(N, s) = p$: one closed-form evaluation with a single integer square root recovers the
factorisation.

*Proof.* Theorem 5.7. $\square$

**Theorem 8.2 (Hint completeness).** If $pq = p'q'$, $p+q = p'+q'$, $p \le q$ and $p' \le q'$, then
$p = p'$ and $q = q'$. The pair $(N, s)$ determines the ordered factorisation uniquely.

*Proof.* $p = \Phi(pq, p+q) = \Phi(p'q', p'+q') = p'$ by Theorem 5.7 and the hypotheses; then
$q = (p+q) - p = (p'+q') - p' = q'$. $\square$

**Theorem 8.3 (Scope restatement).** Fix a prime $q$ and a finite set $S$ of positive exponents.
Then simultaneously:

1. *(hint-free)* there is no function $F$ with $F(\Pi_S(pq)) = p$ for all primes $p > q$; and
2. *(hinted)* there is an explicit function $G$ — namely $G(N,s) = \Phi(N,s)$ — with
   $G(qp,\, q+p) = q$ for all primes $p > q$.

*Proof.* (1) is Theorem 4.4; (2) is Theorem 5.7. $\square$

**Example 8.4.** $N = 8051$, hint $s = 180$. Then $s^2 - 4N = 32400 - 32204 = 196 = 14^2$ and
$\Phi(8051,180) = (180 - 14)/2 = 83$; indeed $8051 = 83 \cdot 97$.

The framework is therefore about *extraction from $N$ alone*. Hint amplification is a distinct
resource, provably powerful, and must be priced separately by any hardness claim.

---

## 9. Synthesis

**Theorem 9.1 (Exhaustion of the classical hint-free surface).** Let $p \ne q$ be distinct odd primes
with $q < p$, put $N = pq$, let $S$ be any finite set of positive exponents, and let $x, s$ be units
modulo $N$. Then:

1. **(Aggregation barrier.)** There is no function of the joint profile $\Pi_S$ which returns a
   prime factor: for no $F$ does $F(\Pi_S(rq)) = r$ hold for all primes $r > q$.
2. **(Walk sterility.)** For every $t$, $\gcd(w_t, N) = 1$ where $w$ is the smooth-step walk with
   seed $x$ and step $s$; the walk never emits a nontrivial divisor.
3. **(Completeness at exponential depth.)** $\Phi\big(N,\ N+1-R_{\operatorname{lcm}(p-1,q-1)}(N)\big)
   = q$, while every positive complete exponent $k$ satisfies $k \ge \sqrt{\varphi(N)}$ (and in fact
   $k \ge \varphi(N)/\gcd(p-1,q-1)$).
4. **(Residue sufficiency.)** There exists $a$ with $N \mid a^2-1$, $N \nmid a \pm 1$, and
   $\gcd(a-1,N) \in \{p,q\}$; moreover exactly four square roots of unity exist modulo $N$.
5. **(Hint amplification.)** $\Phi(N, p+q) = q$.

*Proof.* (1) Theorem 4.4; (2) Theorem 7.3; (3) Theorems 5.8, 5.9, 5.10; (4) Theorems 6.1, 6.2;
(5) Theorem 8.1. $\square$

Items (1) and (3) are the two halves of the aggregation barrier — impossibility below the threshold,
possibility only at exponential depth. Item (4) is the coordinate the quantum channel reads in one
shot. Item (5) marks the boundary of the framework's scope. The barrier is *aggregation*, not the
classification.

### 9.1 Numerical corroboration

Brute-force counts of $\{x \in (\mathbb{Z}/N)^\times : x^k = 1\}$ against the trace-lemma prediction
$\gcd(k,p-1)\gcd(k,q-1)$:

| $N$ | $k=1$ | $2$ | $3$ | $4$ | $5$ | $6$ | $7$ | $8$ |
|---|---|---|---|---|---|---|---|---|
| $15 = 3\cdot 5$ | 1 | 4 | 1 | 8 | 1 | 4 | 1 | 8 |
| $21 = 3\cdot 7$ | 1 | 4 | 3 | 4 | 1 | 12 | 1 | 4 |
| $35 = 5\cdot 7$ | 1 | 4 | 3 | 8 | 1 | 12 | 1 | 8 |

Saturating primes for $S = \{6,12,15,20,30,60\}$ (primes $\equiv 1 \bmod 60$): $61, 181, 241, 421,
541, 601, 661, \dots$ — an infinite family by Lemma 4.3, all with identical joint profiles.

Smooth-step walk $x \mapsto 2x \bmod 8051$ from seed $3$ (note $8051 = 83\cdot 97$): the values
$3, 6, 12, 24, 48, 96, 192, 384, 768, 1536, 3072, 6144, \dots$ all have $\gcd$ with $8051$ equal to
$1$, as forced by Theorem 7.3.

Hint amplification on $8051$: $\Phi(8051,180) = 83$, matching Example 8.4.

---

## 10. Discussion and future work

### 10.1 What is and is not proved

The results are *channel-restricted*. They prove that an algorithm whose only access to $N$ is
through free witnesses — of any finite collection of exponents — cannot factor, and that the family
becomes informative only at exponent depth $\lambda(N)$. They do **not** prove that factoring is
classically hard: an algorithm may access $N$ in other ways (lattice reduction, sieving over
smooth relations, elliptic curves), and those channels are outside the model. Making the aggregation
cost unavoidable for arbitrary classical algorithms is precisely the open problem the framework
isolates.

### 10.2 Open problems

**(A) The 2-adic case.** For $N = 2^e M$ with $M$ odd and $e \ge 3$ we conjecture
$$R_k(N) \;=\; \gcd(2,k)\cdot\gcd(2^{e-2},k)\cdot\prod_{p \mid M}\gcd\!\big(\varphi(p^{v_p}),k\big),$$
with least complete exponent $\operatorname{lcm}(2^{e-2}, \lambda(M))$ — strictly smaller than
$\varphi(N)$, so the even part *shortens* the aggregation depth by a bounded factor, never enough to
make it polynomial. The only missing ingredient is a root count in
$\mathbb{Z}/2 \times \mathbb{Z}/2^{e-2}$, which the multiplicativity of the root count over direct
products already supplies.

**(B) Sparse infinite exponent sets.** We conjecture that joint closure survives well past finiteness:
for every infinite $S \subseteq \mathbb{Z}_{>0}$ with $\#(S \cap [1,X]) = O(X^{1-\varepsilon})$ and
every prime $q$, there still exist distinct primes $p \ne p'$ with $R_k(pq) = R_k(p'q)$ for all
$k \in S \cap [1,N]$. The Dirichlet argument needs only primes $\equiv 1$ modulo
$\operatorname{lcm}(S \cap [1,X])$, and for sparse $S$ that modulus remains small enough for such a
prime to exist under standard prime-gap heuristics; sparsity, not finiteness, is the operative
hypothesis.

**(C) An unconditional lower bound.** Can the exponent-depth lower bound be promoted from "algorithms
restricted to free witnesses" to "algorithms with black-box access to arithmetic modulo $N$"? A
generic-group model result of this shape would be the strongest available formal evidence that
factoring is classically hard.

**(D) Beyond gcd channels for walks.** Theorem 7.3 closes the greatest-common-divisor channel for
multiplicative walks. Whether *any* efficiently samplable classical stochastic process on
$\mathbb{Z}/N$ can have provably useful randomness beyond the birthday floor of its orbit remains
open; all known candidates reduce either to smoothness (subexponential) or to order finding
(currently quantum).

### 10.3 Practical reading

For a cryptographic engineer, the concrete content is reassuring and specific: exponent-probing
attacks on RSA moduli are bounded by the Carmichael exponent, and no clever combination of them
improves matters. Guard $\varphi(N)$ and $\lambda(N)$ as you guard $p$: by Theorems 5.8 and 8.1 either
one, or the sum $p+q$, converts to the factorisation in constant time. And do not confuse hint-free
hardness with hardness under partial key exposure: the second is a genuinely different — and
genuinely broken — regime.

---

## 11. Conclusion

The free-witness family $\{R_k(N)\}$ is completely classified: for every odd modulus,
$R_k(N) = \prod_{p\mid N}\gcd(\varphi(p^{v_p(N)}),k)$. From that single formula follow an
information-theoretic impossibility for finite aggregation, an exact aggregation depth equal to the
Carmichael exponent, the sterility of multiplicative random walks, the exact population of useful
residue witnesses, and the closed-form amplification of the additive hint. Together these delimit a
classical attack surface, price it exactly, and localise the one known way through it: not a failure
of the classification, but a shortcut past its cost.
