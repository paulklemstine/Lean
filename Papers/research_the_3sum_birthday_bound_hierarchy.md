# The 3SUM–Birthday-Bound Hierarchy: Collision Structure, gcd Queries, and a Two-Level Barrier for Semiprime Factoring

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

We study the precise sense in which collision-based factoring methods for a semiprime $N = pq$ all pay the same price, and the precise sense in which they do not. Our starting point is an exact *factor-reveal* characterisation: for distinct primes $p, q$ and any integer $s$, one has $\gcd(s, pq) = p$ if and only if $p \mid s$ and $q \nmid s$. Specialised to $s = a + b + c$ this makes a 3SUM solution modulo a hidden prime factor into a factoring witness, connecting two canonical problems — 3SUM and integer factoring — through a single divisibility lemma that also subsumes sumset differences and Pollard's $p-1$ values.

We then quantify the cost of producing such a witness. We prove an *arity-uniform* pigeonhole theorem: for every arity $r$, a collision search over an $r$-uniform family of subsets of a $k$-set is guaranteed to succeed against every evaluation into $\mathbb{Z}/p\mathbb{Z}$ if and only if $\binom{k}{r} > p$. Sufficiency is the pigeonhole principle; necessity is an adversary construction, so the threshold $p+1$ is exactly optimal. Consequently, although the required *search-set size* improves with arity ($k \gtrsim p$, $k \gtrsim \sqrt{2p}$, $k \gtrsim (6p)^{1/3}$ at arities $1, 2, 3$), the *enumeration cost* is pinned at more than $p \ge \sqrt{N}$ for every arity.

We close two loopholes. First, we prove an unconditional lower bound for the only interface these methods use — the gcd — with no hypothesis on how queries are generated: a query multiset $Q$ of nonzero integers bounded by $M$ that reveals a factor of every semiprime built from a prime pool $P$ must satisfy $|P| \le |Q| \log_2 M + 1$. Second, we prove that the deterministic $\sqrt{N}$ row is *not* tight for randomised search: an exact count of collision-free evaluations, $p^{\underline{m}} = p(p-1)\cdots(p-m+1)$ out of $p^m$, combined with an integer union bound $p^{m+1} \le p\,p^{\underline{m}} + \binom{m}{2} p^m$, yields that $m^2 < p$ forces a strict majority of evaluations to be collision-free. Hence any search succeeding with probability exceeding $1/2$ needs $m \ge \sqrt{p}$ tuples, i.e. $N^{1/4}$ for a balanced semiprime.

The resulting picture is a two-level barrier — deterministic $\sqrt{N}$, randomised $N^{1/4}$ — with both levels established as unconditional lower bounds and both independent of the arity.

**Keywords:** 3SUM, birthday bound, integer factoring, semiprime, pigeonhole principle, gcd queries, falling factorial, query complexity.

---

## 1. Introduction

### 1.1 Two problems, one witness

The **3SUM problem** asks whether a set of $n$ integers contains three elements summing to zero. It is a cornerstone of fine-grained complexity: the conjecture that 3SUM requires $n^{2-o(1)}$ time underwrites a large body of conditional lower bounds in computational geometry and string algorithms.

**Integer factoring** asks for the prime decomposition of $N$, and in the semiprime case $N = pq$ it is the assumption underlying widely deployed public-key cryptography.

These two problems are not usually discussed together. The observation driving this paper is that they meet at a single elementary lemma. Suppose $N = pq$ with $p \ne q$ prime, and suppose one has produced integers $a, b, c$ with
$$a + b + c \equiv 0 \pmod p, \qquad a + b + c \not\equiv 0 \pmod q.$$
Then $\gcd(a+b+c, N) = p$ exactly. The 3SUM solution *modulo the hidden factor* is a factoring witness, and extracting the factor from it costs one Euclidean algorithm.

This is not a factoring algorithm — one cannot search modulo $p$ without knowing $p$ — but it is a structural bridge, and it invites the natural quantitative question: **how expensive is it to produce such a witness, and does the arity $3$ buy anything over arity $2$ or arity $1$?**

### 1.2 The hierarchy and its folklore

Collision-based factoring methods come in a natural hierarchy graded by arity:

| Arity | Collision type | Search set | Tuples enumerated |
|---|---|---|---|
| $1$ | single evaluations coincide | $k \gtrsim p$ | $k$ |
| $2$ | sumset: $a+b \equiv c+d$ | $k \gtrsim \sqrt{2p}$ | $\binom{k}{2}$ |
| $3$ | 3SUM: $a+b+c \equiv 0$ | $k \gtrsim (6p)^{1/3}$ | $\binom{k}{3}$ |

Folklore says: the exponent in the search-set size improves ($1 \to 1/2 \to 1/3$), but the net cost is always $\Theta(\sqrt{N})$. We prove that the first clause is right, that the second clause is right *for deterministic guarantees* and provably optimal there, and that it is *wrong* for randomised search, where the correct threshold is $\Theta(\sqrt{p}) = \Theta(N^{1/4})$.

### 1.3 Contributions

1. **Exact factor reveal** (Section 2): a complete four-case classification of $\gcd(s, pq)$ and the iff-characterisation $\gcd(s, pq) = p \iff p \mid s \wedge q \nmid s$; the 3SUM specialisation; a verified exhaustive instance at $N = 143$.
2. **Reveal density** (Section 3): in one period $0 < s \le N$ there are exactly $q$ multiples of $p$, of which exactly $q-1$ reveal; the reveal fails on a $1/q$ fraction of its own witnesses.
3. **Arity-uniform pigeonhole** (Section 4): guaranteed collision $\iff \binom{k}{r} > p$, with a matching adversary; the resulting $\sqrt{N}$ wall, uniform in $r$; a verified threshold table at $p = 100$.
4. **Arity reduction** (Section 5): a 3SUM solution in $S \subseteq \mathbb{Z}/p\mathbb{Z}$ exists iff $-c \in S + S$ for some $c \in S$, so arity $3$ is an arity-$2$ table plus $|S|$ lookups; Pollard's $p-1$ as the same reveal lemma.
5. **Unconditional gcd-query lower bound** (Section 6): $|P| \le |Q|\log_2 M + 1$ by an adversary that hides two untouched primes.
6. **Counting birthday bound and the randomised barrier** (Section 7): exact count $p^{\underline{m}}$ of collision-free evaluations, integer union bound, and the conclusion that $m^2 < p$ implies a strict majority of collision-free evaluations.

Sections 8–10 discuss algorithms, applications and open problems.

Throughout, $p$ and $q$ denote distinct primes, $N = pq$, $\mathbb{Z}_p := \mathbb{Z}/p\mathbb{Z}$, $\binom{n}{r}$ is the binomial coefficient, and $p^{\underline{m}} := p(p-1)\cdots(p-m+1)$ denotes the falling factorial (with $p^{\underline{0}} = 1$).

---

## 2. The factor reveal

### 2.1 Statement and classification

**Lemma 2.1 (One-sided divisibility reveals).** *Let $p, q$ be primes and $s$ an integer with $p \mid s$ and $q \nmid s$. Then $\gcd(s, pq) = p$.*

*Proof sketch.* Since $p \mid s$ and $p \mid pq$, we have $p \mid \gcd(s, pq)$; write $\gcd(s,pq) = pt$. From $pt \mid pq$ we get $t \mid q$, so $t = 1$ or $t = q$ by primality of $q$. If $t = q$ then $q \mid \gcd(s, pq) \mid s$, contradicting $q \nmid s$. Hence $t = 1$. $\square$

The symmetric statement, with the roles of $p$ and $q$ exchanged, follows by commutativity of the product.

**Theorem 2.2 (Complete classification).** *Let $p \ne q$ be primes and $s$ any integer. Then*
$$\gcd(s, pq) = \begin{cases} pq, & p \mid s \text{ and } q \mid s,\\ p, & p \mid s \text{ and } q \nmid s,\\ q, & q \mid s \text{ and } p \nmid s,\\ 1, & p \nmid s \text{ and } q \nmid s.\end{cases}$$

*Proof sketch.* Case 1: $p, q$ coprime and both dividing $s$ give $pq \mid s$, so the gcd is $pq$. Cases 2 and 3 are Lemma 2.1 and its mirror. Case 4: the gcd divides $pq$; if it exceeded $1$ it would have a prime divisor $r$, and $r \mid pq$ forces $r \in \{p, q\}$ while $r \mid \gcd(s, pq) \mid s$ contradicts the hypothesis. $\square$

**Corollary 2.3 (Exact characterisation).** *For distinct primes $p \ne q$,*
$$\gcd(s, pq) = p \iff \big(p \mid s \ \text{ and } \ q \nmid s\big).$$

*Proof sketch.* ($\Leftarrow$) is Lemma 2.1. ($\Rightarrow$): $\gcd(s,pq) = p$ gives $p \mid s$; if also $q \mid s$ then $pq \mid s$, so the gcd would be $pq > p$, a contradiction since $q > 1$. $\square$

The four-case classification is the reason the reveal is *sharp*: exactly two of the four cases are informative, and they are precisely the cases where the witness hits exactly one of the two hidden primes.

### 2.2 The 3SUM specialisation

**Theorem 2.4 (3SUM factor reveal).** *Let $N = pq$ with $p \ne q$ prime. If $a, b, c$ are integers with $p \mid a+b+c$ and $q \nmid a+b+c$, then $\gcd(a+b+c, N) = p$. In particular the revealed divisor is a proper nontrivial factor: $1 < \gcd(a+b+c, N) < N$.*

*Proof sketch.* Immediate from Lemma 2.1 with $s = a+b+c$; properness follows from $1 < p$ and $p < pq$, using $q > 1$. $\square$

The same statement holds verbatim for a congruence stated in $\mathbb{Z}_p$: if $(\bar a + \bar b + \bar c) = 0$ in $\mathbb{Z}_p$ for the reductions of natural numbers $a,b,c$, then $p \mid a+b+c$ and the reveal applies.

### 2.3 An exhaustive verified instance: $N = 143$

Take $N = 143 = 11 \cdot 13$ and enumerate all triples $1 \le a < b < c \le 11$.

- Exactly $15$ of these triples satisfy $11 \mid a+b+c$.
- Exactly $0$ satisfy $143 \mid a+b+c$.
- Consequently all $15$ mod-$p$ triples satisfy $\gcd(a+b+c, 143) = 11$; each reveals the factor.

A concrete witness: $1 + 4 + 6 = 11$, and $\gcd(11, 143) = 11$. The absence of mod-both triples in this range is forced: the largest sum available is $9 + 10 + 11 = 30 < 143$, so no sum can be a multiple of $143$. This is the smallest interesting illustration of the general density statement of the next section.

---

## 3. Reveal density: how often the witness misfires

The reveal has one failure mode, $q \mid s$. We count it exactly.

**Theorem 3.1 (Witness count).** *For $p > 0$, the number of $s$ with $0 < s \le pq$ and $p \mid s$ is exactly $q$.*

*Proof sketch.* The multiples of $p$ in $(0, pq]$ are $p, 2p, \dots, qp$; there are $\lfloor pq/p \rfloor = q$ of them. $\square$

**Theorem 3.2 (Failure count).** *For $p, q > 0$, the number of $s$ with $0 < s \le pq$ and $pq \mid s$ is exactly $1$, namely $s = pq$.*

**Theorem 3.3 (Reveal density).** *Let $p \ne q$ be primes and $N = pq$. Then*
$$\#\{\, s : 0 < s \le N,\ \gcd(s, N) = p \,\} = q - 1.$$

*Proof sketch.* By Corollary 2.3, the set in question is $\{s : p \mid s\} \setminus \{s: p \mid s \text{ and } q \mid s\}$ within the period, and by coprimality the subtracted set is $\{s : pq \mid s\}$, which is contained in the former. Apply Theorems 3.1 and 3.2 and take the difference: $q - 1$. $\square$

**Corollary 3.4.** *Conditional on having produced a multiple of $p$ in one period, the reveal succeeds with probability exactly $(q-1)/q$. For $N = 143$ this is $12/13$: of the $13$ multiples of $11$ in $(0,143]$, exactly $12$ satisfy $\gcd(s,143) = 11$, the exception being $s = 143$.*

The practical reading: the non-degeneracy hypothesis $q \nmid s$ attached to every reveal theorem is a genuine but negligible restriction. Its failure probability is $1/q$, which for cryptographic parameters is astronomically small; and when it does fail one learns $N$ itself, i.e. nothing, at no cost beyond one gcd.

---

## 4. The arity-uniform birthday bound

### 4.1 The model

Fix a modulus $p > 0$ and a finite set $S$ of size $k$. An **arity-$r$ collision search over $S$** enumerates the family $\binom{S}{r}$ of all $r$-element subsets of $S$, evaluates each subset $A$ by some function $v : \binom{S}{r} \to \mathbb{Z}_p$, and succeeds if $v(A) = v(B)$ for some $A \ne B$. The canonical evaluation is the subset sum modulo $p$; the arity-$1$ case is a plain evaluation search, arity $2$ the sumset search, arity $3$ the 3SUM search.

We say the search is **guaranteed** if it succeeds *for every* evaluation $v$. This is the deterministic worst-case notion: no assumption whatsoever on the structure of $v$.

### 4.2 Sufficiency and necessity

**Theorem 4.1 (Sufficiency — pigeonhole).** *If $p < \binom{k}{r}$, then for the subset-sum evaluation there exist distinct $r$-subsets $A \ne B$ of $S$ with $\sum_{a \in A} a \equiv \sum_{b \in B} b \pmod p$.*

*Proof sketch.* The family $\binom{S}{r}$ has $\binom{k}{r} > p$ members and the map $A \mapsto (\sum A) \bmod p$ lands in a set of size $p$; a map from a larger finite set to a smaller one is not injective. $\square$

**Theorem 4.2 (Necessity — adversary).** *If a family $T$ of subsets satisfies $|T| \le p$, then there exists an evaluation $v : T \to \mathbb{Z}_p$ that is injective, i.e. produces no collision at all.*

*Proof sketch.* $|T| \le p = |\mathbb{Z}_p|$, so an injection $T \hookrightarrow \mathbb{Z}_p$ exists; extend arbitrarily. $\square$

**Theorem 4.3 (Exact threshold, uniform in arity).** *For every $p > 0$, every finite $S$ with $|S| = k$, and every arity $r$:*
$$\Big(\text{for every } v:\ \exists A \ne B \in \tbinom{S}{r},\ v(A) = v(B)\Big) \iff p < \binom{k}{r}.$$

*Proof sketch.* ($\Leftarrow$) $|\binom{S}{r}| = \binom{k}{r} > p = |\mathbb{Z}_p|$, so no $v$ is injective. ($\Rightarrow$) contrapositive: if $\binom{k}{r} \le p$, Theorem 4.2 supplies an injective $v$, defeating the guarantee. $\square$

Theorem 4.3 is the technical heart of the hierarchy. The threshold $p+1$ enumerated tuples is not an upper estimate obtained by a lossy pigeonhole argument: it is exactly optimal, at every arity, because the adversary construction matches it.

### 4.3 The search-set exponents

The improvement claimed by the hierarchy lives in $k$, not in $\binom{k}{r}$.

**Proposition 4.4.** *If $p < \binom{k}{r}$ then $p < k^r$; hence $k > p^{1/r}$.*

*Proof sketch.* $\binom{k}{r} \le k^r$. $\square$

**Proposition 4.5 (Arity 2).** *If $p < \binom{k}{2}$ then $2p < k^2$, i.e. $k > \sqrt{2p}$.*

*Proof sketch.* $\binom{k}{2} = k(k-1)/2 \le k^2/2$. $\square$

**Proposition 4.6 (Arity 3).** *If $p < \binom{k}{3}$ then $6p < k^3$, i.e. $k > (6p)^{1/3}$.*

*Proof sketch.* One shows $6\binom{n}{3} \le n^3$ for all $n$ by induction using Pascal's rule $\binom{n+1}{3} = \binom{n}{3} + \binom{n}{2}$ together with $2\binom{n}{2} \le n^2$ and the expansion $(n+1)^3 = n^3 + 3n^2 + 3n + 1$. $\square$

**Proposition 4.7 (Higher arity never hurts).** *If $r < k/2$ and $p < \binom{k}{r}$ then $p < \binom{k}{r+1}$.*

*Proof sketch.* Below the midpoint the binomial coefficients increase in $r$. $\square$

Proposition 4.7 orders the hierarchy: in the regime $r < k/2$, whatever arity-$r$ guarantees, arity $r+1$ guarantees too. The hierarchy is a genuine chain, not a list of incomparable methods.

### 4.4 The $\sqrt{N}$ wall

**Theorem 4.8 (Barrier).** *Let $N = pq$ with $q \le p$, and let $C > p$. Then $\lfloor \sqrt{N} \rfloor < C$.*

*Proof sketch.* $pq \le p^2$, so $\lfloor\sqrt{pq}\rfloor \le \lfloor\sqrt{p^2}\rfloor = p < C$. $\square$

**Corollary 4.9 (Hierarchy barrier).** *For every arity $r$: if an arity-$r$ collision search over $S$ modulo $p$ is guaranteed to succeed, then it enumerates $\binom{|S|}{r} > p \ge \lfloor \sqrt{N} \rfloor$ tuples, where $N = pq$ is any semiprime with $q \le p$.*

*Proof sketch.* Combine Theorem 4.3 with Theorem 4.8. $\square$

This is the precise content of "all rows of the table cost $\sqrt{N}$", and Theorem 4.3 shows it cannot be improved for deterministic guarantees.

### 4.5 A verified threshold table

Take $p = 100$. The minimal set size $k$ guaranteeing a collision at each arity, and the resulting enumeration, are:

| Arity $r$ | Minimal $k$ | $k$ insufficient | Tuples $\binom{k}{r}$ |
|---|---|---|---|
| $1$ | $101$ | $100$ | $101$ |
| $2$ | $15$ | $14$ | $105$ |
| $3$ | $10$ | $9$ | $120$ |

All three entries were checked exhaustively: $\binom{101}{1} = 101 > 100$ while $\binom{100}{1} = 100 \not> 100$; $\binom{15}{2} = 105 > 100$ while $\binom{14}{2} = 91$; $\binom{10}{3} = 120 > 100$ while $\binom{9}{3} = 84$. The search-set sizes strictly decrease, $101 > 15 > 10$, while the tuple counts $101, 105, 120$ all exceed $p = 100$ — and hence all exceed $\lfloor\sqrt{100q}\rfloor$ for every $q \le 100$.

The table exhibits, in miniature, the whole phenomenon: a tenfold compression of the search set with no reduction whatever in the work.

---

## 5. Arity reduction and the unity of the reveal mechanisms

### 5.1 3SUM is a sumset table plus lookups

For $S \subseteq \mathbb{Z}_p$ finite, write $S + S := \{x + y : x, y \in S\}$ for the sumset, so that $|S+S| \le |S|^2$.

**Theorem 5.1 (Arity reduction).** *For any finite $S \subseteq \mathbb{Z}_p$,*
$$\big(\exists\, a, b, c \in S:\ a + b + c = 0\big) \iff \big(\exists\, c \in S:\ -c \in S + S\big).$$

*Proof sketch.* ($\Rightarrow$) From $a+b+c = 0$ we get $a + b = -c$ with $a, b \in S$, so $-c \in S+S$. ($\Leftarrow$) If $-c = a + b$ with $a, b \in S$ and $c \in S$, then $a+b+c = 0$. $\square$

The algorithmic reading is the important one. Building the sumset table costs $|S|^2$ additions and yields a set of size at most $|S|^2$; the 3SUM search then costs $|S|$ additional membership queries. So the arity-$3$ search does not access a fundamentally richer structure than the arity-$2$ search: it *is* the arity-$2$ structure, interrogated $|S|$ more times. This is a structural explanation, complementary to Theorem 4.3, of why raising the arity cannot lower the cost.

### 5.2 Pollard's $p-1$ is the same lemma

**Lemma 5.2 (Fermat step).** *Let $p$ be prime, $p \nmid a$, and $(p-1) \mid k$. Then $p \mid a^k - 1$.*

*Proof sketch.* Write $k = (p-1)m$. In $\mathbb{Z}_p$, $a \ne 0$ gives $a^{p-1} = 1$ by Fermat's little theorem, so $a^k = (a^{p-1})^m = 1$; lift the congruence back to $\mathbb{Z}$. $\square$

**Theorem 5.3 (Pollard $p-1$ reveal).** *Let $p \ne q$ be primes, $p \nmid a$, $(p-1) \mid k$ and $q \nmid a^k - 1$. Then $\gcd(a^k - 1, pq) = p$.*

*Proof sketch.* Lemma 5.2 supplies $p \mid a^k-1$; apply Lemma 2.1. $\square$

**Theorem 5.4 (Collision reveal).** *Let $p \ne q$ be primes and let $x \ge y$ satisfy $x \equiv y \pmod p$ and $q \nmid x - y$. Then $\gcd(x-y, pq) = p$.*

*Proof sketch.* $x \equiv y \pmod p$ with $y \le x$ gives $p \mid x - y$; apply Lemma 2.1. $\square$

Theorems 2.4, 5.3 and 5.4 are three faces of Lemma 2.1. Sumset differences, 3SUM sums, Pollard $p-1$ values and differences of singular moduli all feed the same divisibility test. This unification is what licenses treating them as *one hierarchy* rather than four unrelated tricks.

### 5.3 The end-to-end pipeline

**Theorem 5.5 (Collision search factors, at every arity).** *Let $p \ne q$ be primes, $S$ a finite set of naturals, $r$ an arity with $p < \binom{|S|}{r}$. Then there exist distinct $r$-subsets $A \ne B$ of $S$ such that, writing $d$ for the absolute difference of their sums, $p \mid d$; and if additionally $q \nmid d$, then $\gcd(d, pq) = p$.*

*Proof sketch.* Theorem 4.1 gives the sum collision; the modular equality with $y \le x$ gives $p \mid x - y$; Theorem 5.4 finishes. $\square$

For $r = 3$ this is exactly the 3SUM factor reveal in its search form: enumerate more than $p$ triples, obtain a sum collision modulo the unknown prime, and cash it in with one gcd.

---

## 6. An unconditional gcd-query lower bound

Sections 4–5 bound one *mechanism* (collision by pigeonhole). A sceptic may ask whether some entirely different mechanism produces multiples of $p$ more cheaply. We now bound not the mechanism but the *interface*.

### 6.1 The model

A **gcd-query algorithm** produces a finite set $Q$ of nonzero integers, each at most $M$, and computes $\gcd(x, N)$ for each $x \in Q$. It **solves** $N$ if some query has a nontrivial gcd with $N$. Every method discussed so far is of this shape: 3SUM sums, sumset differences, $a^k - 1$, singular-moduli differences.

Define the **touched set** of $Q$ to be the set of primes dividing at least one query:
$$U(Q) := \bigcup_{x \in Q} \{\, \pi \text{ prime} : \pi \mid x \,\}.$$

### 6.2 Counting touched primes

**Lemma 6.1.** *Every nonzero $x$ has at most $\log_2 x$ distinct prime factors.*

*Proof sketch.* If $x$ has $t$ distinct prime factors, their product divides $x$ and is at least $2^t$; hence $2^t \le x$, i.e. $t \le \log_2 x$. $\square$

**Lemma 6.2.** *If every $x \in Q$ satisfies $x \le M$, then $|U(Q)| \le |Q| \cdot \log_2 M$.*

*Proof sketch.* $|U(Q)| \le \sum_{x \in Q} |\{\pi : \pi \mid x\}| \le \sum_{x\in Q} \log_2 M = |Q|\log_2 M$, using Lemma 6.1 and monotonicity of $\log$. $\square$

### 6.3 The adversary

**Lemma 6.3.** *If $p, q$ are distinct primes with $p, q \notin U(Q)$, then $\gcd(x, pq) = 1$ for every nonzero $x \in Q$.*

*Proof sketch.* $p \notin U(Q)$ means $p \nmid x$; likewise $q \nmid x$. Theorem 2.2, case 4, gives $\gcd(x, pq) = 1$. $\square$

**Lemma 6.4.** *If $|P| > |U(Q)| + 1$, then $P$ contains two distinct primes both outside $U(Q)$.*

*Proof sketch.* $|P \setminus U(Q)| \ge |P| - |U(Q)| > 1$. $\square$

**Theorem 6.5 (gcd-query lower bound).** *Let $Q$ be a finite set of nonzero integers, each $\le M$, and $P$ a finite set of primes. If for all distinct $p, q \in P$ some $x \in Q$ has $\gcd(x, pq) \ne 1$, then*
$$|P| \le |Q| \cdot \log_2 M + 1, \qquad\text{equivalently}\qquad |Q| \ge \frac{|P| - 1}{\log_2 M}.$$

*Proof sketch.* Suppose $|P| > |Q|\log_2 M + 1$. By Lemma 6.2, $|P| > |U(Q)| + 1$, so by Lemma 6.4 there are distinct $p, q \in P$ outside $U(Q)$. By Lemma 6.3 every query has trivial gcd with $pq$, contradicting the solving hypothesis. $\square$

**Corollary 6.6 (64-bit instance).** *If all queries are below $2^{64}$, covering a pool of $n$ candidate primes requires at least $(n-1)/64$ queries.*

**Proposition 6.7 (Non-vacuity).** *If $p \mid x$ and $q \nmid x$ for distinct primes $p, q$, then $\gcd(x, pq) = p \ne 1$, so a single revealing query does solve the instance.*

Proposition 6.7 is essential for interpretation: the bound of Theorem 6.5 does not say gcd testing is expensive — testing is one Euclidean algorithm. It says the *search* for a query touching the right prime is expensive, because each query can touch only $\log_2 M$ primes and there are many candidates.

### 6.4 Recovering the $\sqrt{N}$ wall unconditionally

For a balanced semiprime $N \approx p^2$, the candidate primes near $\sqrt{N}$ number about $\sqrt{N}/\log\sqrt{N}$ by the prime number theorem. Applying Theorem 6.5 with $|P| \approx \sqrt{N}/\log\sqrt{N}$ and $\log_2 M = O(\log N)$ gives
$$|Q| \;\ge\; \Omega\!\left(\frac{\sqrt{N}}{\log^2 N}\right),$$
a $\tilde\Omega(\sqrt{N})$ lower bound *for the non-adaptive worst-case guarantee*, obtained with no pigeonhole hypothesis and no assumption on how queries are generated. It is a query-complexity statement, and it is the strongest unconditional form of the hierarchy's headline claim.

---

## 7. The counting birthday bound and the randomised barrier

### 7.1 The objection

The $\sqrt{N}$ wall concerns *guarantees*. Real collision-based factoring is randomised: Pollard's rho finds a collision modulo $p$ after about $\sqrt{p} \approx N^{1/4}$ values. If the deterministic wall were the whole truth, rho could not work. The hierarchy table is therefore incomplete, and this section supplies the missing row — again as a proved lower bound, not a heuristic.

### 7.2 Exact counting

Model the enumeration of $m$ distinct tuples as an assignment of residues, i.e. a function $\{1,\dots,m\} \to \mathbb{Z}_p$. There are $p^m$ such assignments. Call one **collision-free** if it is injective.

**Theorem 7.1 (Exact count of collision-free evaluations).** *The number of collision-free assignments of $m$ tuples into $\mathbb{Z}_p$ is the falling factorial*
$$p^{\underline{m}} \;=\; p(p-1)(p-2)\cdots(p-m+1).$$

*Proof sketch.* A collision-free assignment is precisely an injection $\{1,\dots,m\} \hookrightarrow \mathbb{Z}_p$, and the number of injections from an $m$-set into an $n$-set is the falling factorial $n^{\underline{m}}$. Here $|\mathbb{Z}_p| = p$. $\square$

**Theorem 7.2 (Total count).** *The number of all assignments is $p^m$.*

### 7.3 The union bound in integer form

**Theorem 7.3 (Integer union bound).** *For all $p$ and all $m \le p$:*
$$p^{\,m+1} \;\le\; p \cdot p^{\underline{m}} \;+\; \binom{m}{2}\, p^{\,m}.$$

*Proof sketch.* By induction on $m$. The base case $m=0$ reads $p \le p$. For the step, multiply the inductive hypothesis by $p$ to obtain
$$p^{m+2} \le p\big(p \cdot p^{\underline m}\big) + \tbinom{m}{2} p^{m+1}.$$
Then split $p = (p - m) + m$ in the leading term and use $p^{\underline m} \le p^m$:
$$p \big(p \cdot p^{\underline m}\big) = (p-m)\,p\,p^{\underline m} + m\, p\, p^{\underline m} \le p\big((p-m) p^{\underline m}\big) + m\,p^{m+1}.$$
Since $(p-m)p^{\underline m} = p^{\underline{m+1}}$ and $\binom{m}{2} + m = \binom{m+1}{2}$, collecting terms yields the statement for $m+1$. $\square$

Dividing by $p^{m+1}$ turns Theorem 7.3 into the familiar probabilistic form: for a uniformly random assignment of $m$ items into $p$ boxes,
$$\Pr[\text{some collision}] \;=\; 1 - \frac{p^{\underline m}}{p^m} \;\le\; \frac{\binom{m}{2}}{p},$$
one term per pair that could collide. Theorem 7.3 is exactly this inequality cleared of denominators, so no real-number probability theory is needed.

### 7.4 The barrier

**Theorem 7.4 (Majority collision-free).** *Let $0 < p$ and $m \le p$ with $2\binom{m}{2} < p$. Then $p^m < 2\, p^{\underline m}$: strictly more than half of all assignments are collision-free.*

*Proof sketch.* Suppose instead $2p^{\underline m} \le p^m$. Multiplying by $p$ and combining with Theorem 7.3 in the form $p \cdot p^m \le p\,p^{\underline m} + \binom{m}{2}p^m$ gives
$$p \cdot p^m \le \tfrac12 p \cdot p^m + \tbinom{m}{2} p^m,$$
whence $p \le 2\binom{m}{2}$, contradicting the hypothesis. (In integer arithmetic the same chain is carried out without halving, by combining $p(2p^{\underline m}) \le p\cdot p^m$ with the union bound.) $\square$

**Theorem 7.5 (Randomised $\sqrt{p}$ barrier).** *Let $0 < p$ and suppose $m^2 < p$. Then $p^m < 2\,p^{\underline m}$. Consequently, any collision search that enumerates fewer than $\sqrt{p}$ tuples fails on a strict majority of evaluations, so a success probability exceeding $1/2$ requires at least $\sqrt{p}$ tuples.*

*Proof sketch.* From $m^2 < p$ we get $m \le p$, and $2\binom{m}{2} = m(m-1) \le m^2 < p$; apply Theorem 7.4. $\square$

**Corollary 7.6 (Two-level barrier).** *For a balanced semiprime $N = pq$ with $p \approx q \approx \sqrt{N}$:*

| Regime | Tuples needed | In terms of $N$ |
|---|---|---|
| Deterministic guarantee | $> p$ | $\sqrt{N}$ |
| Randomised, success probability $> 1/2$ | $\ge \sqrt{p}$ | $N^{1/4}$ |

*Both rows are lower bounds, and both are independent of the arity $r$.*

### 7.5 A numeric instance of the gap

Take $p = 10007$ (prime) and $m = 100 \approx \sqrt{p}$. Then $2\binom{100}{2} = 9900 < 10007$, so by Theorem 7.4
$$10007^{100} \;<\; 2 \cdot 10007^{\underline{100}} :$$
with only $100$ tuples enumerated, a strict majority of all $10007^{100}$ evaluations remain collision-free. Meanwhile a deterministic guarantee at the same modulus requires more than $10007$ tuples. The two thresholds differ by two orders of magnitude at this modulus, and the gap widens as $\sqrt{p}$.

This is the honest correction to the folklore: **the hierarchy table is tight only for deterministic guarantees.** The randomised threshold is $\Theta(\sqrt{p})$, precisely the classical birthday exponent, and precisely the running time of Pollard's rho.

---

## 8. Algorithms

Three algorithmic procedures are implicit in the results above.

### 8.1 Witness-to-factor extraction

**Input:** $N$, a candidate witness $s$. **Output:** a nontrivial factor of $N$, or `FAIL`.

Compute $g = \gcd(s \bmod N, N)$. If $1 < g < N$ return $g$, else return `FAIL`. Correctness is Theorem 2.2; cost is $O(\log^2 N)$ bit operations by the Euclidean algorithm. Theorem 3.3 says that if $s$ was drawn uniformly from the multiples of $p$ in one period, this succeeds with probability $(q-1)/q$.

### 8.2 Arity-$r$ collision search

**Input:** a set $S$, an arity $r$, a modulus context $N$. **Output:** a factor of $N$, or `FAIL`.

Enumerate the $\binom{|S|}{r}$ subsets, keep a dictionary keyed by the subset sum reduced modulo $N$ — one cannot reduce modulo the unknown $p$, so the reduction is done modulo $N$ and the *difference* of two colliding sums is offered to the gcd. On any repeated key, extract the difference and call the routine of 8.1. Theorem 4.1 guarantees a collision once $\binom{|S|}{r} > p$; Theorem 4.3 says nothing smaller can guarantee it. Time and space are $\Theta(\binom{|S|}{r})$, i.e. $\Omega(p) = \Omega(\sqrt{N})$ for guaranteed success — the wall in algorithmic form.

### 8.3 Arity reduction for 3SUM

**Input:** $S \subseteq \mathbb{Z}_p$. **Output:** a 3SUM triple, or `NONE`.

Build the sumset table $\{a + b : a, b \in S\}$ as a hash map from value to a witnessing pair, in $|S|^2$ operations. Then for each $c \in S$ look up $-c$: a hit yields $(a, b, c)$ with $a+b+c=0$. Correctness is Theorem 5.1. Total time $O(|S|^2)$, space $O(|S|^2)$ — so the arity-$3$ search costs the arity-$2$ table plus $|S|$ lookups, never less.

---

## 9. Applications and interpretation

**Reading the hierarchy correctly.** The single most useful consequence is a template for auditing claimed speedups. The arity story features a real exponent improvement — the required set size drops from $\Theta(p)$ to $\Theta(\sqrt{p})$ to $\Theta(p^{1/3})$ — and yet the cost is unchanged. The improvement is in the *generating set*, and the cost lives in the *tuple count*. Any proposal that improves an exponent should be asked which quantity it improved.

**A bridge for fine-grained complexity.** Theorem 2.4 makes a 3SUM solution modulo a hidden prime a factoring witness, and Theorem 5.1 places 3SUM exactly one layer above the sumset. This is the raw material for hardness transfer in both directions: from 3SUM lower bounds to lower bounds on restricted factoring algorithms, and from hypothetical subquadratic 3SUM algorithms to structured factoring attacks.

**Query complexity as the right abstraction.** Theorem 6.5 shows that the interesting bound does not depend on collisions at all. Because every method in the family ultimately consults $\gcd(\cdot, N)$, the information-theoretic cost can be charged to the queries, which each touch at most $\log_2 M$ primes. This is a robust way to argue that a whole design space is a dead end, without enumerating the designs.

**Cryptographic reading.** Nothing here threatens any deployed parameter set; on the contrary, both barriers are lower bounds and thus reassurances. The $N^{1/4}$ randomised level is exactly the classical rho threshold, and is the reason balanced semiprimes are used: an unbalanced $N = pq$ with small $p$ collapses the randomised barrier to $\sqrt{p}$, which is small.

---

## 10. Limitations and future directions

**Limitations.** (i) The barriers are stated for the *search* step; they say nothing about algorithms exploiting algebraic structure beyond the gcd interface, such as the number field sieve, which is subexponential and lies entirely outside this model. (ii) Theorem 6.5 is non-adaptive: $Q$ is fixed in advance. Adaptive gcd queries are a natural and open strengthening. (iii) The randomised barrier is stated for uniform evaluations; extending it to arbitrary evaluation distributions with bounded collision entropy is open.

**Conjecture 1 (arity-independence as an information-theoretic law).** For every arity $r$ and every family $F$ of $r$-subsets of a $k$-set, a search guaranteeing a sum collision modulo $p$ must satisfy $|F| > p$, and for randomised search with success probability $\varepsilon$ the requirement is $|F| \ge \sqrt{2\varepsilon p}$ — with *no dependence on $r$ in either bound*. The insight is that the arity merely repackages the same $|F|$ residue evaluations, so the entropy available to the searcher is $\log|F|$ however the tuples are structured; the exponent $1/r$ lives in the *size of the generating set*, never in the *cost*. Both endpoints are already established here for subset-sum evaluations; the remaining step is to replace "subset sum" by an arbitrary evaluation, which the adversary construction of Theorem 4.2 already supports.

**Conjecture 2 (the gcd-query barrier is tight up to logarithms).** For every $n$ there is a query set $Q$ with $|Q| = O(n\log n/\log M)$ revealing a factor of every semiprime built from the first $n$ primes below $M$; combined with Theorem 6.5 this pins the gcd-query complexity of factoring over a prime pool of size $n$ at $\tilde\Theta(n/\log M)$. The insight is that the lower bound counts *touched primes*, so a matching upper bound is a packing problem — pack primes into products of size $\le M$ — a covering-design question rather than a number-theoretic one. The lower bound is unconditional; the upper bound is a finite combinatorial construction (product trees), hence falsifiable by an explicit $Q$ for small $n$.

**Conjecture 3 (3SUM-hardness transfer).** If 3SUM over $n$ integers requires $n^{2-o(1)}$ time, then any factoring algorithm that only inspects sums of at most $3$ elements of an adaptively chosen set $S \subseteq \mathbb{Z}_p$, together with gcds thereof, requires $p^{2/3-o(1)}$ operations; conversely a truly subquadratic 3SUM algorithm would yield a corresponding speedup for such structured searches.

**Further questions.** Does the two-level barrier persist for evaluations with algebraic structure (polynomial maps, as in rho's $x \mapsto x^2+1$)? Can the union bound of Theorem 7.3 be sharpened to a matching upper bound, giving a *threshold* rather than a barrier at $\sqrt{p}$? And is there a arity-graded analogue of the reveal density of Theorem 3.3, counting revealing $r$-tuples rather than revealing residues?

---

## 11. Conclusion

A single divisibility lemma — $\gcd(s, pq) = p$ exactly when $p \mid s$ and $q \nmid s$ — unifies 3SUM sums, sumset differences, Pollard $p-1$ values and singular-moduli differences into one family of factoring witnesses, and makes 3SUM modulo a hidden prime a structural neighbour of factoring. Quantifying the cost of producing such a witness yields a matching pair of bounds valid at every arity: guaranteed success requires more than $p$ enumerated tuples, and this threshold is exactly optimal. The arity improves the search-set exponent from $1$ to $1/2$ to $1/3$ while leaving the cost untouched.

Two further results delimit the picture. Unconditionally, and independently of any collision mechanism, a gcd-query algorithm covering a pool of $n$ primes with queries bounded by $M$ needs at least $(n-1)/\log_2 M$ queries — recovering the $\sqrt{N}$ wall as a query-complexity statement. And by exact counting, fewer than $\sqrt{p}$ enumerated tuples leave a strict majority of evaluations collision-free, so the randomised threshold is $\Theta(\sqrt{p}) = \Theta(N^{1/4})$, strictly below the deterministic wall.

The final picture is a two-level barrier — $\sqrt{N}$ deterministic, $N^{1/4}$ randomised, both unconditional, both arity-uniform. It is not a factoring breakthrough; it is a precise account of why a natural family of ideas cannot become one, and of exactly where the boundary lies.
