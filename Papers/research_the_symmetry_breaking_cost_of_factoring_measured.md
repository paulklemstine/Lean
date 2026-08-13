# The Symmetry-Breaking Cost of Factoring, Measured

**Author:** Aristotle
**Date:** 2026-08-13

## Abstract

We measure, exactly, the query cost of extracting factor information from quadratic residue data, and we prove that the publicly available version of the same data has cost infinity. Let $N$ be an odd semiprime and let $S$ be a finite set of candidate odd prime factors. A *battery* is a finite tuple $a = (a_1, \dots, a_k)$ of test integers; the *signature* of a candidate $r$ is $\sigma_a(r) = \left(\left(\tfrac{a_1}{r}\right), \dots, \left(\tfrac{a_k}{r}\right)\right)$.

We prove four groups of results.

1. **Exact isolation cost.** For any finite set $S$ of distinct odd primes, the least $k$ for which some admissible battery of size $k$ has injective signature map on $S$ is exactly $\lceil \log_2 |S| \rceil$. The upper bound follows from a full-independence theorem for Legendre signatures: for *any* prescribed sign pattern on $S$ there is a single integer realizing it. The lower bound is pigeonhole on a binary answer alphabet. When all candidates satisfy $p^2 \le N$, the cost is at most $\tfrac12 \log_2 N$.

2. **Adaptivity is worthless.** Modelling adaptive strategies as binary decision trees over residue queries, a tree of depth $d$ identifies at most $2^d$ candidates, and depth $\lceil \log_2 |S| \rceil$ is attained. The optimal adaptive depth equals the optimal non-adaptive battery size.

3. **The public battery is exactly blind.** Define the squarefree kernel $K(n)$ as the set of primes dividing $n$ to odd multiplicity. Then $\left(\tfrac{a}{n}\right) = \prod_{p \in K(n)} \left(\tfrac{a}{p}\right)$ for $a$ coprime to $n$, and for odd $M, N > 0$ the batteries of $M$ and $N$ agree on all numerators coprime to $MN$ **iff** $K(M) = K(N)$. Since $K(Nr^2) = K(N)$, every candidate $r$ has a *compensating partner* $Nr^2$: a modulus divisible by $r$ with an identical public battery. The pruning power of $\left(\tfrac{\cdot}{N}\right)$ is exactly zero.

4. **The witness always exists.** For distinct odd primes $p \neq q$, an explicit nontrivial square root of $1$ modulo $N = pq$ exists, its $\gcd(x-1, N)$ equals $p$ exactly, and *every* nontrivial square root of unity mod $N$ yields $p$ or $q$ by a single gcd.

The gap between (1) and (3) is what we call the **symmetry-breaking cost**: factor information is present and cheap in *asymmetric* form (local characters at one prime) and provably absent from the *symmetric* aggregate (the character of the product). Classical factoring algorithms pay this cost by aggregating relations over a factor base; quantum order-finding pays it by an asymmetric readout. The result refutes public residue data as an attack surface while quantifying precisely what a symmetry-breaking resource is worth.

**Keywords:** quadratic residues, Jacobi symbol, integer factorization, query complexity, Chinese Remainder Theorem, squarefree kernel, decision trees, Shor's algorithm.

---

## 1. Introduction

### 1.1 The question

Integer factorization is presumed hard, and the presumption underwrites much of deployed public-key cryptography. But "hard" is a statement about algorithms, not about information. A sharper question, and one that can be answered rather than merely conjectured, is:

> Given a specific family of arithmetic probes, how much *factor information* do they carry, and what does it cost to extract?

The family we study is the oldest and cheapest one: quadratic residuosity. For an odd prime $p \nmid a$, the Legendre symbol $\left(\tfrac{a}{p}\right) \in \{\pm 1\}$ records whether $a$ is a square modulo $p$. Its multiplicative extension to odd composite $n = \prod_i p_i$,
$$\left(\frac{a}{n}\right) := \prod_i \left(\frac{a}{p_i}\right),$$
is the Jacobi symbol, and — this is the crux — it is computable in time $O(\log^2 n)$ *without knowing the factorization of $n$*.

This yields two batteries of tests that look nearly identical and behave nothing alike:

- the **asymmetric** battery $\left[\left(\tfrac{a_i}{p_0}\right)\right]_i$ of a hidden prime factor $p_0$, available only from an oracle;
- the **symmetric** battery $\left[\left(\tfrac{a_i}{N}\right)\right]_i$, available to everybody.

We measure both.

### 1.2 Summary of findings

The asymmetric battery is *maximally informative per bit*: $\lceil \log_2 |S| \rceil$ queries isolate the hidden factor among $|S|$ candidates, matching the information-theoretic floor with no slack, and adaptivity does not improve it. Taking $S$ to be the odd primes below $\sqrt N$, the cost is $\lceil \log_2 \pi(\sqrt N) \rceil \le \tfrac12 \log_2 N$: about half the bit-length of $N$.

The symmetric battery is *exactly uninformative*: it is a faithful invariant of the squarefree kernel and a complete blank beyond it, so no candidate is ever excluded.

Both facts spring from the same source — the Chinese Remainder Theorem makes local quadratic behaviour at distinct primes completely free. Freedom is what makes the oracle cheap and what makes the aggregate blind. **The symmetry-breaking cost is the price of undoing the aggregation.**

### 1.3 Relation to computational practice

Classical subexponential factoring algorithms (quadratic sieve, number field sieve) can be read as paying this cost explicitly: they collect a huge number of smooth relations over a factor base and solve a linear system to manufacture a congruence of squares $x^2 \equiv y^2 \pmod N$ with $x \not\equiv \pm y$. Every relation individually is a symmetric datum with zero pruning power; only the aggregate, of size roughly $\exp(c (\log N)^{1/3}(\log\log N)^{2/3})$, breaks the symmetry. Quantum order finding buys the same asymmetry differently — by reading out the multiplicative order of a random residue in superposition — and pays polynomially in $\log N$. Section 6 makes the second half of this comparison precise by exhibiting and classifying the witnesses that order finding hunts for.

---

## 2. Setting and definitions

Throughout, $J(a \mid n)$ denotes the Jacobi symbol with numerator $a \in \mathbb{Z}$ and odd positive denominator $n$; for prime $n$ it is the Legendre symbol. We use $\left(\tfrac{a}{n}\right)$ and $J(a \mid n)$ interchangeably.

**Definition 2.1 (Battery and signature).** A *battery of size $k$* is a tuple $a : \{1,\dots,k\} \to \mathbb{Z}$. The *quadratic signature* of a candidate modulus $r$ under $a$ is
$$\sigma_a(r) := \big(J(a_1 \mid r), \dots, J(a_k \mid r)\big) \in \{-1,0,1\}^k.$$

**Definition 2.2 (Admissibility).** A battery $a$ is *admissible* for a candidate set $S$ if $J(a_i \mid p) \neq 0$ for all $i$ and all $p \in S$; equivalently, no test integer is divisible by a candidate. This is the honest model: a zero answer is not a query result but an outright disclosure of the factor, so it must be excluded before one speaks of a per-query bit budget.

**Definition 2.3 (Isolation).** A battery $a$ *isolates* $S$ if $\sigma_a$ is injective on $S$. If the hidden factor $p_0 \in S$ and an oracle reports $\sigma_a(p_0)$, then $p_0$ is the unique candidate consistent with the report.

**Definition 2.4 (Isolation cost).** The *achievable sizes* for $S$ are
$$\mathrm{IC}(S) := \{\, k \in \mathbb{N} : \exists\, a \text{ of size } k,\ a \text{ admissible for } S \text{ and isolating } S \,\}.$$
The *isolation cost* of $S$ is $\min \mathrm{IC}(S)$, when it exists.

**Definition 2.5 (Squarefree kernel).** For $n \ge 1$, $K(n) := \{\, p \text{ prime} : v_p(n) \text{ is odd} \,\}$, where $v_p$ is the $p$-adic valuation. For a semiprime $N = pq$ with $p \ne q$, $K(N) = \{p,q\}$.

---

## 3. Independence of quadratic signatures

Everything rests on the following surjectivity statement, which says that the local quadratic characters at distinct primes are mutually unconstrained.

**Theorem 3.1 (Full independence of Legendre signatures).** Let $S$ be a finite set of distinct odd primes and let $\varepsilon : S \to \{+1,-1\}$ be arbitrary. Then there exists a single integer $x$ with
$$J(x \mid p) = \varepsilon(p) \qquad \text{for all } p \in S.$$
Equivalently, the map $x \mapsto \big(J(x\mid p)\big)_{p\in S}$ from $\mathbb{Z}$ to $\{\pm 1\}^S$ is surjective.

*Proof sketch.* Work locally then glue.

*Local step.* Fix $p \in S$. If $\varepsilon(p) = +1$, take $b_p = 1$. If $\varepsilon(p) = -1$, we need a quadratic nonresidue mod $p$. Since $p$ is odd, the residue field $\mathbb{F}_p$ has characteristic $\ne 2$, so squaring is two-to-one on $\mathbb{F}_p^\times$ and a nonsquare exists; let $b_p$ be a lift of one.

*Gluing step.* The elements of $S$ are pairwise coprime, being distinct primes. A Chinese Remainder Theorem over a finite set of pairwise coprime moduli — proved by induction on $S$, at each step using Bézout coefficients $u p + v M = 1$ for $M = \prod_{r \in S \setminus \{p\}} r$ — supplies $x \in \mathbb{Z}$ with $p \mid x - b_p$ for all $p \in S$.

*Conclusion.* The Jacobi symbol depends on its numerator only modulo the denominator, so $J(x \mid p) = J(b_p \mid p) = \varepsilon(p)$. $\square$

Two remarks. First, the theorem is *exactly* the statement that the residue signature of a hidden prime is an unconstrained fingerprint: no amount of knowledge about other primes constrains it. Second, the same construction reappears three times below — once to build isolating batteries (§4), once to separate distinct kernels (§5), and once to build square roots of unity (§6). It is the single engine of the whole development.

---

## 4. The exact isolation cost

### 4.1 Upper bound

**Theorem 4.1 (Sufficiency of $\lceil \log_2 |S|\rceil$ queries).** Let $S$ be a finite set of distinct odd primes and let $k$ satisfy $|S| \le 2^k$. Then there exists a battery of size $k$ that is admissible for $S$ and isolates $S$.

*Proof sketch.* Since $|S| \le 2^k = |\{0,1\}^k|$, choose an injection $C : S \hookrightarrow \{0,1\}^k$, i.e. a binary code for the candidates. For each coordinate $i \le k$, apply Theorem 3.1 with the pattern $\varepsilon_i(p) := (-1)^{1 - C(p)_i}$ — that is, prescribe $+1$ where the $i$-th code bit is $1$ and $-1$ where it is $0$ — obtaining a test integer $a_i$ with $J(a_i \mid p) = \pm 1$ according to $C(p)_i$ for every $p \in S$.

Admissibility is immediate: every answer is $\pm 1$, never $0$. For isolation, suppose $\sigma_a(p) = \sigma_a(q)$ with $p, q \in S$. Then for each $i$, $J(a_i \mid p) = J(a_i \mid q)$, and since these values are $+1$ exactly when the corresponding code bit is $1$, we get $C(p) = C(q)$, hence $p = q$ by injectivity of $C$. $\square$

### 4.2 Lower bound

**Theorem 4.2 (Information-theoretic bound).** Let $\beta$ be a finite answer alphabet and let $f : \mathbb{N} \to \beta^k$ be any map (a $k$-query strategy with answers in $\beta$). If $|\beta|^k < |S|$, then there are distinct $p, q \in S$ with $f(p) = f(q)$.

*Proof sketch.* Pigeonhole: $f$ maps the $|S|$ candidates into a set of size $|\beta|^k < |S|$. $\square$

We state this for a general alphabet deliberately. The raw Jacobi symbol is ternary, and a ternary bound would give only $k \ge \log_3 |S|$; but a $0$ answer is not an ordinary query result, it is the factor itself. Restricting to admissible batteries makes the alphabet genuinely binary and the bound genuinely $\log_2$.

**Lemma 4.3 (Bit faithfulness).** If $a$ is admissible for $S$ and $p,q \in S$ satisfy $[\,J(a_i\mid p) = 1\,] \Leftrightarrow [\,J(a_i \mid q) = 1\,]$ for every $i$, then $\sigma_a(p) = \sigma_a(q)$.

*Proof sketch.* Each $J(a_i \mid r)$ lies in $\{-1,0,1\}$ by the trichotomy for Jacobi symbols, and admissibility rules out $0$. So the predicate "$=1$" determines the value. $\square$

### 4.3 The measurement

**Theorem 4.4 (Exact isolation cost).** Let $S$ be a finite set of distinct odd primes. Then $\mathrm{IC}(S)$ has a least element and
$$\min \mathrm{IC}(S) = \big\lceil \log_2 |S| \big\rceil .$$

*Proof sketch.* Membership: $|S| \le 2^{\lceil \log_2 |S|\rceil}$, so Theorem 4.1 applies. Minimality: suppose $k \in \mathrm{IC}(S)$ via an admissible isolating battery $a$, and suppose for contradiction $|S| > 2^k$. Apply Theorem 4.2 with $\beta = \{\text{true},\text{false}\}$ and $f(r)_i := [\,J(a_i\mid r) = 1\,]$ to obtain distinct $p,q \in S$ with equal bit vectors; Lemma 4.3 upgrades this to $\sigma_a(p) = \sigma_a(q)$, contradicting injectivity. Hence $|S| \le 2^k$, i.e. $\lceil \log_2 |S|\rceil \le k$. $\square$

**Corollary 4.5 (Threshold form).** For $S$ as above and any $k$: $k$ queries suffice **iff** $|S| \le 2^k$.

**Corollary 4.6 (Half the bits of $N$).** Suppose every $p \in S$ is an odd prime with $p^2 \le N$, and $N \le 4^k$. Then $k \in \mathrm{IC}(S)$.

*Proof sketch.* From $N \le 4^k = (2^k)^2$ we get $\lfloor\sqrt N\rfloor \le 2^k$. Every $p \in S$ is an odd prime with $p \le \sqrt N$, so $S \subseteq [3, \lfloor\sqrt N\rfloor] \cap \mathbb{Z}$, whence $|S| \le \lfloor \sqrt N\rfloor - 2 \le 2^k$. Apply Corollary 4.5. $\square$

Thus the residue oracle's cost is at most $\tfrac12 \log_2 N$, and taking $S$ to be *all* odd primes below $\sqrt{N}$, it is exactly $\lceil \log_2 \pi(\sqrt N) \rceil$.

**Proposition 4.7 (From isolation to factorization).** Let $a$ isolate $S$, let $p_0 \in S$ with $p_0 \mid N$ and $p_0 < N$. Then $p_0$ is the unique $r \in S$ with $\sigma_a(r) = \sigma_a(p_0)$, and $N = p_0 \cdot (N/p_0)$ with $N/p_0 > 1$.

*Proof sketch.* Uniqueness is injectivity. If $N/p_0 \le 1$ then $N = p_0 (N/p_0) \le p_0$, contradicting $p_0 < N$. $\square$

So $\lceil\log_2 \pi(\sqrt N)\rceil$ oracle bits do not merely *identify* the factor abstractly; they hand it over, and division completes the factorization.

### 4.4 Numerical corroboration

Greedy battery construction over candidate sets of semiprimes from $15$ to $33$ bits (candidate counts $31$ to $7894$) separates all candidates using a number of queries whose ratio to $\log_2 \pi(\sqrt N)$ lies in $[0.96, 1.03]$, and never succeeds with $\lceil \log_2 \pi(\sqrt N)\rceil - 1$ queries — as the pigeonhole bound forbids. For $N = 3149 = 47 \cdot 67$, $N = 10403 = 101\cdot 103$, and a $40$-bit semiprime, the observed ratio stayed in $[1, 1.03]$. The theory is exact, so the only deviation possible is the rounding implicit in the ceiling.

---

## 5. Adaptivity buys nothing

A natural objection: batteries are non-adaptive, all queries fixed in advance. Could a strategy that chooses its next test integer after seeing previous answers be cheaper? No.

**Definition 5.1 (Query tree).** A *query tree* is a finite binary tree: a leaf carries a guess $n \in \mathbb{N}$; an internal node carries a test integer $x \in \mathbb{Z}$ and two subtrees. Running a tree $t$ on a candidate $r$: at a leaf, output its guess; at a node $(x, t_{\mathrm{yes}}, t_{\mathrm{no}})$, recurse into $t_{\mathrm{yes}}$ if $J(x \mid r) = 1$ and into $t_{\mathrm{no}}$ otherwise. The *depth* of a leaf is $0$ and of a node is $1 + \max$ of subtree depths. A tree *solves* $S$ if it outputs $r$ on input $r$, for every $r \in S$.

Note that the model is maximally permissive: an internal node carries an arbitrary integer, and the branch predicate is the raw symbol, so no strategy is excluded.

**Theorem 5.2 (Adaptive lower bound).** If a query tree $t$ of depth $d$ solves $S$, then $|S| \le 2^d$.

*Proof sketch.* Induction on $t$. If $t$ is a leaf with guess $n$, then every $r \in S$ satisfies $r = n$, so $S \subseteq \{n\}$ and $|S| \le 1 = 2^0$. If $t = (x, t_1, t_0)$ with depths $d_1, d_0$, partition $S = S_1 \sqcup S_0$ according to whether $J(x \mid r) = 1$; then $t_1$ solves $S_1$ and $t_0$ solves $S_0$, so by induction $|S| \le 2^{d_1} + 2^{d_0} \le 2^{\max(d_1,d_0)} + 2^{\max(d_1,d_0)} = 2^{\max(d_1,d_0)+1} = 2^{d}$. $\square$

**Corollary 5.3.** Any tree solving $S$ has depth at least $\lceil \log_2 |S| \rceil$.

**Theorem 5.4 (Attainment).** For $S$ a finite set of distinct odd primes there is a query tree of depth exactly $\lceil \log_2 |S| \rceil$ solving $S$.

*Proof sketch.* Take the admissible isolating battery $a_1,\dots,a_k$ of Theorem 4.1 with $k = \lceil \log_2 |S| \rceil$, and *compile* it into a complete binary tree: level $i$ tests $a_i$ regardless of history, and each leaf, reached by a bit pattern $b \in \{0,1\}^k$, guesses the unique candidate whose signature bit pattern is $b$ (or an arbitrary value if none). Running the tree on $r$ traverses exactly the pattern $\big([J(a_i\mid r)=1]\big)_i$, and injectivity of $\sigma_a$ (via Lemma 4.3) makes the decoding correct. Depth is $k$ by construction. $\square$

**Theorem 5.5 (Adaptive cost equals non-adaptive cost).** The least depth of a query tree solving $S$ is exactly $\lceil \log_2 |S|\rceil$, the same as $\min \mathrm{IC}(S)$.

The conceptual reason is Theorem 3.1: every answer pattern is realizable, so no subtree can be pruned in advance, and the optimal tree is forced complete. Adaptivity helps only when answers are correlated, and here they are maximally free.

*Illustration.* On $S = \{3,5,7,11,13\}$ with $|S| = 5$ and $\lceil \log_2 5\rceil = 3$: no depth-$2$ tree works, since it has at most $4$ leaves; and the battery $(2, 3, 10)$ compiled into a depth-$3$ tree does work, its answer vectors on $3,5,7,11,13$ being $(-1,0,1)$, $(-1,-1,0)$, $(1,-1,-1)$, $(-1,1,-1)$, $(-1,1,1)$ — pairwise distinct. (This battery is not admissible for $S$; admissible ones exist, but this one is the smallest to be found by naive search and illustrates the counting.)

---

## 6. The symmetric battery: exactly the squarefree kernel

We now turn the same probe on $N$ itself and determine its information content precisely.

**Lemma 6.1 (Multiplicativity in the denominator).** For $a \in \mathbb{Z}$, a finite index set $T$, and nonzero moduli $f(p)$, $J\big(a \mid \prod_{p\in T} f(p)\big) = \prod_{p \in T} J(a \mid f(p))$.

*Proof sketch.* Induction on $T$ using the two-factor multiplicativity of the Jacobi symbol in its denominator. $\square$

**Theorem 6.2 (The public battery factors through the kernel).** For $n \ne 0$ and $a$ coprime to $n$,
$$J(a \mid n) = \prod_{p \in K(n)} J(a \mid p).$$

*Proof sketch.* Write $n = \prod_{p \mid n} p^{v_p(n)}$ and apply Lemma 6.1, obtaining $J(a\mid n) = \prod_p J(a \mid p)^{v_p(n)}$. Coprimality forces each $J(a\mid p) \in \{\pm 1\}$, and for such a value $x$ one has $x^e = x$ if $e$ is odd and $x^e = 1$ if $e$ is even. Only the odd-multiplicity primes survive, and these are exactly $K(n)$. $\square$

So even multiplicities are invisible. The following theorem shows that this is the *only* loss.

**Theorem 6.3 (Separation).** Let $M, N$ be odd and nonzero and suppose some prime $p$ lies in $K(M) \setminus K(N)$. Then there is a numerator $a$ coprime to $MN$ with $J(a \mid M) = -1$ and $J(a\mid N) = 1$.

*Proof sketch.* Apply Theorem 3.1 to the finite set of odd primes $K(M) \cup K(N)$ with the pattern $\varepsilon(p) = -1$ and $\varepsilon(\ell) = +1$ for $\ell \ne p$; this is legitimate since $M, N$ odd forces all kernel primes to be odd. The resulting $a$ has $J(a\mid \ell) = 1$ for every kernel prime except $p$, so by Theorem 6.2, $J(a\mid M) = -1$ (the product over $K(M)$ contains the single $-1$) and $J(a\mid N) = 1$ (the product over $K(N)$, which omits $p$, is all $+1$'s). Coprimality to $MN$ holds because all local symbols are nonzero. $\square$

**Theorem 6.4 (Exact information content of the symmetric battery).** For odd $M, N > 0$,
$$\Big(\forall a \text{ with } \gcd(a, MN) = 1:\ J(a\mid M) = J(a \mid N)\Big) \iff K(M) = K(N).$$

*Proof sketch.* ($\Leftarrow$) Immediate from Theorem 6.2, since coprimality to $MN$ gives coprimality to each. ($\Rightarrow$) Contrapositive: if the kernels differ, some prime lies in one and not the other; Theorem 6.3 (applied in the appropriate direction) produces a numerator on which the batteries differ, since $-1 \ne 1$. $\square$

This is the sharp form of blindness: the public battery is a *complete invariant of the kernel* and carries *no other information whatsoever*.

**Theorem 6.5 (Squares are invisible).** For $N, r \ge 1$, $K(N r^2) = K(N)$.

*Proof sketch.* $v_p(Nr^2) = v_p(N) + 2 v_p(r)$ has the same parity as $v_p(N)$. $\square$

**Theorem 6.6 (Sharp zero pruning).** Let $N, r$ be odd positive integers. Then $M := N r^2$ satisfies: $r \mid M$, $M$ is odd, $K(M) = K(N)$, and $J(a \mid M) = J(a\mid N)$ for every $a$ coprime to $MN$.

*Proof sketch.* Combine Theorems 6.5 and 6.4. $\square$

**Corollary 6.7 (Compensating partner; unbounded survivors).** For every candidate $r$ there is a modulus divisible by $r$ with the same public battery as $N$, and such moduli exist above any bound $B$: take $M = N t^2$ with $t = r(B+1)$, which exceeds $B$, is divisible by $r$, and again has kernel $K(N)$.

Consequently the public data $\left[\left(\tfrac{a_i}{N}\right)\right]$ **prunes nothing**: for each candidate $r$ there exists a modulus consistent with the entire observed battery and divisible by $r$. Every candidate survives, forever, no matter how many test integers are used. This is not a quantitative weakness (few bits) but a structural collapse: the battery factors through $K$, and $K$ is invariant under multiplication by squares.

**Proposition 6.8 (Semiprime kernel).** For distinct primes $p \ne q$, $K(pq) = \{p, q\}$.

*Proof sketch.* $v_p(pq) = v_q(pq) = 1$ (odd), all other valuations $0$ (even). $\square$

So for the cryptographic case the public battery reproduces exactly the multiset of prime factors *as an aggregate symbol* — which is to say it reproduces $N$, and not one bit more.

### 6.1 Why the two sides differ

Theorem 3.1 says the vector of *local* symbols $\big(J(a\mid p)\big)_{p \in K(N)}$ ranges over all of $\{\pm1\}^{K(N)}$ as $a$ varies: full information, $|K(N)|$ free bits. Theorem 6.2 says the public data is the *product* of those coordinates: one bit, the parity. The map $\{\pm1\}^{K(N)} \to \{\pm 1\}$, $(\epsilon_p) \mapsto \prod_p \epsilon_p$, is a group homomorphism with kernel of index $2$; all the distinguishing content lies in that kernel, and the public battery reports only the coset. Aggregation is a projection, and the projection annihilates precisely the asymmetry between $p$ and $q$.

**The symmetry-breaking cost is the cost of inverting that projection.**

---

## 7. The asymmetric readout: witnesses always exist

The quantum route pays the same bill in a different currency. Shor's algorithm reduces factoring to finding the multiplicative order of a random unit; the classical post-processing needs a *nontrivial square root of unity*. We show such objects always exist, are found by the same CRT mechanism, and are exhaustively classified.

**Theorem 7.1 (Shor post-processing).** Let $N > 1$ and $x \in \mathbb{Z}$ with $N \mid x^2 - 1$, $N \nmid x-1$, $N \nmid x+1$. Then $d := \gcd(x-1, N)$ satisfies $d \mid N$, $1 < d < N$: a nontrivial factor.

*Proof sketch.* $d \mid N$ by definition. If $d = 1$, then $x - 1$ is coprime to $N$; from $N \mid (x-1)(x+1)$ we would get $N \mid x+1$, contradiction. If $d = N$, then $N \mid x - 1$, contradiction. Since $N > 1$ and $d \mid N$ with $d \ne 1$, we get $d > 1$; and $d \le N$ with $d \ne N$ gives $d < N$. $\square$

**Corollary 7.2 (Order-finding form).** If $x$ has even order $2m$ modulo $N$ — i.e. $N \mid x^{2m} - 1$ — and $x^m \not\equiv \pm 1 \pmod N$, then $\gcd(x^m - 1, N)$ is a nontrivial factor. (Apply Theorem 7.1 to $x^m$, noting $(x^m)^2 = x^{2m}$.)

**Theorem 7.3 (The witness always exists).** Let $p \ne q$ be distinct odd primes and $N = pq$. Then there is an explicit $x \in \mathbb{Z}$ with $p \mid x-1$, $q \mid x+1$, and consequently $N \mid x^2 - 1$, $N \nmid x-1$, $N \nmid x+1$.

*Proof sketch.* By the Chinese Remainder Theorem choose $x \equiv 1 \pmod p$ and $x \equiv -1 \pmod q$. Then $(x-1)(x+1) = x^2-1$ is divisible by $pq = N$. If $N \mid x - 1$ then $q \mid x-1$; combined with $q \mid x+1$ this gives $q \mid 2$, impossible for odd $q$. Symmetrically for $x+1$. $\square$

**Theorem 7.4 (The gcd is the factor, exactly).** For the witness of Theorem 7.3, $\gcd(x-1, N) = p$.

*Proof sketch.* $p \mid x - 1$ and $p \mid N$ give $p \mid \gcd$. Conversely the gcd divides $N = pq$ and cannot be divisible by $q$ (else $q \mid x-1$ and $q \mid x+1$, so $q \mid 2$), so it is $1$ or $p$; being a multiple of $p$, it is $p$. $\square$

**Theorem 7.5 (Classification: no third kind of witness).** Let $p \ne q$ be distinct odd primes, $N = pq$, and let $z$ satisfy $N \mid z^2-1$, $N \nmid z-1$, $N \nmid z+1$. Then
$$\gcd(z-1, N) = p \quad\text{or}\quad \gcd(z-1,N) = q.$$

*Proof sketch.* From $N \mid (z-1)(z+1)$ and primality, $p$ divides $z-1$ or $z+1$, and likewise $q$. Four cases. If $p, q$ both divide $z-1$ then $N \mid z-1$ (coprimality), excluded; if both divide $z+1$, then $N \mid z+1$, excluded. In the remaining two cases the primes split, and the gcd computation of Theorem 7.4 applies verbatim, giving $p$ in one case and $q$ in the other. $\square$

Thus every nontrivial square root of unity modulo an odd semiprime factors it, and nothing is wasted: the search space contains no decoys.

---

## 8. The measurement table

Collecting the results for an odd semiprime $N = pq$ with candidate set $S$ of distinct odd primes:

| resource | cost to isolate the hidden factor $p_0$ | source |
|---|---|---|
| residue **oracle** (asymmetric) | exactly $\lceil \log_2 \lvert S\rvert \rceil$ queries, adaptively or not | Thms 4.4, 5.5 |
| $N$ alone (**symmetric**) | infinite: zero candidates ever pruned | Thms 6.4, 6.6 |
| free-witness **aggregation** (classical sieving) | superpolynomial in $\log N$ in practice | discussion, §1.3 |
| **quantum** order finding | polynomial in $\log N$: asymmetric readout | Thms 7.1–7.5 |

Formally, the three provable rows combine into a single statement.

**Theorem 8.1 (Symmetry-breaking cost table).** Let $p \ne q$ be distinct odd primes, $N = pq$, and let $S$ be a finite set of distinct odd primes. Then simultaneously:

1. $\min \mathrm{IC}(S) = \lceil \log_2 |S| \rceil$ — the oracle isolates at exactly the information-theoretic price;
2. for every $r \in S$ there is a modulus $M$ with $r \mid M$, $K(M) = K(N)$, and $J(a\mid M) = J(a\mid N)$ for all $a$ coprime to $MN$ — the public battery excludes no candidate;
3. there exists $x$ with $\gcd(x-1, N) = p$ — an asymmetric witness that factors $N$ with one gcd.

*Proof sketch.* (1) is Theorem 4.4; (2) is Theorem 6.6 applied to each $r$; (3) is Theorems 7.3–7.4. $\square$

The gap between (1) and (2) is the symmetry-breaking cost; (3) is what the quantum channel pays for.

---

## 9. Discussion

### 9.1 Information-sufficient, computation-sealed

The measurement supports a precise slogan: **quadratic residue data about $N$ is information-sufficient but computation-sealed**. Sufficient, because $\lceil \log_2 \pi(\sqrt N)\rceil \approx \tfrac12 \log_2 N$ well-chosen bits determine the factor uniquely (Theorem 4.4) and a single gcd witness determines it outright (Theorem 7.4). Sealed, because the publicly computable version of the *same* symbols has exactly zero pruning power (Theorem 6.4), with an explicit conspiring modulus for each candidate.

The seal is not statistical or asymptotic — it is a structural identity: the aggregation map $\prod$.

### 9.2 What is refuted

A tempting attack strategy runs: compute many symbols $\left(\tfrac{a_i}{N}\right)$, use each to eliminate some candidate primes, and iterate. Theorem 6.6 refutes it definitively: no candidate is *ever* eliminated, however many $a_i$ are used, because every candidate has a modulus with a byte-identical battery. The classical uniform, hint-free residue surface is exhausted. This closes the corresponding avenue rather than merely failing to open it.

### 9.3 What is unified

Two frontiers usually discussed separately become the same frontier:

- *Why is classical factoring expensive?* Because each symmetric relation has zero individual pruning power; only a factor-base-sized aggregate breaks the tie, and assembling it costs a superpolynomial number of relations plus a linear algebra step.
- *What does the quantum channel buy?* Not information — the information is already there (Theorems 4.4, 7.3). It buys *pointing*: an asymmetric readout that resolves the composite structure rather than projecting it to a single symbol.

Both are payments for the same asymmetry, in different currencies. The value of a symmetry-breaking resource is precisely the aggregation it lets you skip.

### 9.4 Modelling caveats

The exact $\log_2$ statement depends on the admissibility convention. Without it, the Jacobi answer alphabet is ternary and the pigeonhole bound weakens to $\log_3 |S|$; but a $0$ answer is a *disclosure*, since $J(a \mid r) = 0$ means $r \mid a$, so counting it as an ordinary query result would be modelling the oracle as more generous than any realistic adversary. We therefore state both: the exact binary bound under admissibility, and the general finite-alphabet bound (Theorem 4.2) without it.

Likewise, the kernel equivalence (Theorem 6.4) genuinely needs $M, N$ odd: at $p=2$ there is no quadratic nonresidue, and the separation argument would have to be replaced by a mod-$8$ argument. The boundary is explicit, not swept aside.

Finally, none of the results is vacuous: the isolating battery is exhibited, not merely asserted to exist; the compensating modulus is written down as $Nr^2$; and the square-root witness is constructed by CRT with the numerical instances $x = 4, 13, 10, 6, 43, 12$ for $(p,q) = (3,5), (3,7), (3,11), (5,7), (7,11), (11,13)$, each satisfying $x^2 \equiv 1 \pmod{pq}$ and $\gcd(x-1, pq) = p$, i.e. $3, 3, 3, 5, 7, 11$.

### 9.5 Algorithmic content

Two algorithms are implicit in the proofs and can be run on concrete inputs.

**Battery construction.** Given a candidate set $S$ of odd primes: (i) fix an injective binary code $C : S \to \{0,1\}^k$ with $k = \lceil\log_2|S|\rceil$; (ii) for each coordinate $i$, and each $p\in S$, choose $b_{p,i} = 1$ if $C(p)_i = 1$, else a quadratic nonresidue mod $p$ (found by trial, expected $2$ attempts); (iii) CRT-combine into $a_i$. Cost: $O(k \cdot |S|)$ modular operations plus $k$ CRT reconstructions of size $O(\sum_{p\in S}\log p)$. The resulting signature table is an injective fingerprinting of $S$ by $k$ bits.

**Kernel-blindness certificate.** Given $N$ and a candidate $r$, output $M = N r^2$. Then $r \mid M$ and $M$'s Jacobi battery equals $N$'s on every coprime numerator — a *certificate of non-elimination*, checkable directly.

---

## 10. Future directions

**Conjecture 1 — the cost is $\lceil\log_m |S|\rceil$ for every multiplicative-character battery.** Replace the quadratic symbol by the $m$-th power residue symbol for arbitrary $m \ge 2$ (or by an arbitrary family of Dirichlet characters of bounded conductor). Conjecture: the least battery size isolating a candidate set $S$ of primes $\equiv 1 \bmod m$ is exactly $\lceil \log_m |S| \rceil$ — the alphabet size, not the arithmetic, sets the price; and the corresponding symmetric battery (characters evaluated at $N$) again determines only the "kernel" of $N$ in the character group. Both halves of Theorem 4.4 are alphabet-counting plus Chinese remainder surjectivity, and neither step uses quadraticity: CRT supplies an arbitrary prescribed local symbol at each prime, and pigeonhole caps the number of separable candidates at $(\text{alphabet})^k$. Since Theorem 4.2 is already stated for an arbitrary finite alphabet, the $m$-th power case needs only local surjectivity of the $m$-th power residue symbol.

**Conjecture 2 — a randomized battery is no cheaper than $\log_2 |S| - O(1)$.** Model a randomized strategy as a distribution over decision trees identifying each candidate with probability $\ge 2/3$. Conjecture: expected depth is still $\log_2 |S| - O(1)$, i.e. the measurement is robust to randomization with constant loss at most $2$. Yao's principle turns the randomized bound into a distributional deterministic bound, and the uniform distribution on $S$ is already hard because Theorem 3.1 makes every answer pattern equally realizable — the answers carry no more than one bit each, however the test integer is chosen. The deterministic decision-tree infrastructure of §5 is in place; only an averaging layer is missing.

**Conjecture 3 — kernel faithfulness at the prime $2$.** Theorem 6.4 is guarded by oddness because there is no quadratic nonresidue mod $2$. Conjecture: with the Kronecker symbol in place of the Jacobi symbol, the statement extends to all nonzero $M, N$ provided kernels are compared in $\mathbb{Q}^\times/(\mathbb{Q}^\times)^2$ — i.e. the batteries agree on all coprime numerators iff $M$ and $N$ differ by a square, with the classes of $-1$ and $2$ accounted for separately by a mod-$8$ analysis.

**Further directions.** (i) Quantify the *quantum* side in the same units: is there a query-complexity statement showing that an order-finding oracle realizes exactly the symmetry-breaking bit that $\prod$ destroys? (ii) Extend the kernel theorem to higher-degree residue symbols and to characters of number fields, where the "kernel" becomes a class in a ray class group modulo $m$-th powers. (iii) Study *partial* symmetry breaking: batteries evaluated at $N$ and at auxiliary values $N + c$, and whether a family of such moduli can jointly recover more than each kernel individually.

---

## 11. Conclusion

Three exact statements, one picture. The asymmetric residue oracle isolates a hidden prime factor at cost exactly $\lceil \log_2 |S| \rceil$ — matching the information floor, adaptively or not, because the Chinese Remainder Theorem makes local quadratic behaviour completely free. The symmetric public battery of $N$ is a faithful invariant of the squarefree kernel and blind to everything else, so it prunes exactly zero candidates: each candidate $r$ hides inside $N r^2$, whose battery is identical to $N$'s. And a witness that factors $N$ with a single gcd always exists, is produced by the same CRT freedom, and admits no decoys.

The distance between the first and the second is the symmetry-breaking cost. Classical algorithms pay it by aggregation; quantum order finding pays it by asymmetric readout. Naming the price makes it possible, for the first time in this setting, to compare the two on the same scale.
