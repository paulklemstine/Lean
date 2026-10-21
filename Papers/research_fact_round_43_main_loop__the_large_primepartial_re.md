# Large Primes Are Split Primes: The Large-Prime Variant of the Quadratic Sieve Cannot Decouple the Factor Base from the Split Set

**Aristotle**

*October 2026*

---

## Abstract

The quadratic sieve factors $N$ by collecting smooth values of $f(c) = c^2 - N$ and combining them, by linear algebra over $\mathbb{F}_2$, into a congruence of squares. The columns of the linear system are primes $p$ at which $N$ is a square modulo $p$, which we call the *split set*. One natural question about the large-prime (partial-relation) variant is whether it can decouple the number of columns from the split set, so that column count becomes a free design parameter. We show that it cannot, and the main step takes one line: if a prime $r$ divides $c^2 - N$, then $N \equiv c^2 \pmod r$, so $\left(\frac{N}{r}\right) = +1$ whenever $r \nmid N$. We build a small theory around this fact. (i) The sieve hit count of an odd prime $r$ per period is exactly $1 + \left(\frac{N}{r}\right)$, so inert primes never occur. (ii) The same statement holds, with $N$ replaced by the discriminant $D$, for every quadratic polynomial used in multiple-polynomial sieving. (iii) Whatever the number of large primes per relation, every column of a large-prime relation matrix lies in the split set up to the large-prime bound $L$. A single large prime in $(B, L]$ strictly enlarges the split set in use, and the added columns are exactly the split primes in $(B, L]$. (iv) Splitness of an odd prime depends only on its residue class modulo $4N$, so large primes cannot be selected to avoid it. (v) In the other direction, after partial relations are paired, the large primes cancel. Any $Q(B) + 1$ combined relations contain a nonempty subset whose product is a perfect square, so the final $\mathbb{F}_2$ matrix has $Q(B)$ columns whatever the value of $L$. Taken together, the large-prime variant neither decouples nor enlarges the final column count: it is purely a row-yield accelerator. We illustrate every statement numerically, including a complete toy factorisation, and we formulate four conjectures, among them a split-restricted birthday law that predicts twice the naive large-prime collision rate.

---

## 1. Introduction

### 1.1 The quadratic sieve in one paragraph

Let $N$ be an odd composite integer that is not a prime power. If integers $X, Y$ satisfy $X^2 \equiv Y^2 \pmod N$ but $X \not\equiv \pm Y \pmod N$, then $\gcd(X - Y, N)$ is a proper divisor of $N$. The quadratic sieve [Pomerance, 1982] produces such pairs as follows. For integers $c$ near $\sqrt N$ the value

$$f(c) = c^2 - N$$

is small, of order $2\sqrt N\,|c - \sqrt N|$, and so is relatively likely to be $B$-*smooth*, meaning all its prime factors are at most $B$. Each smooth value gives a *relation* $c^2 \equiv f(c) \pmod N$ whose right side factors completely over a *factor base* of small primes. Reducing exponent vectors modulo 2 turns each relation into a row of a matrix over $\mathbb{F}_2$. Once there are more rows than columns, a nonempty set of rows sums to zero. The product of the corresponding relations has a square on each side, and with probability at least $1/2$ per dependency the resulting congruence splits $N$.

### 1.2 The split set

Only some primes can occur. A prime $r$ divides some value $f(c)$ if and only if $N$ is a square modulo $r$. For odd $r$ this means $\left(\frac{N}{r}\right) \in \{0, +1\}$. Primes with $\left(\frac{N}{r}\right) = -1$ are *inert*. They never divide a value and need no column. The factor base is therefore the set of primes up to $B$ at which $N$ is a square, and its size $Q(B)$ is not a free parameter: it is determined by $N$ and $B$, with $Q(B) \approx \tfrac12 \pi(B)$ when $N$ is not a perfect square.

### 1.3 The question

When tuning the sieve, the dependence of the column count on the split set is a constraint one would like to escape. Three mechanisms suggest themselves: (a) the large-prime or partial-relation variant, (b) multiple polynomials, and (c) an adaptive bound $B$. This paper settles mechanism (a) analytically, without any search.

The hope behind (a) runs as follows. In the large-prime variant, a value $f(c) = s \cdot r$ with $s$ $B$-smooth and $r$ a single prime in $(B, L]$ is kept as a *partial relation*, and $r$ becomes a new column. Because $r$ is "large", lying outside the factor base, one might hope that the new columns are not tied to the split condition.

### 1.4 Summary of results

The hope fails, for an elementary reason (Theorem 3.1): **every large prime is a split prime.** We then examine both stages of the large-prime method.

- *Partial-relation bookkeeping.* Every column is a split prime up to $L$ (Theorems 4.1 and 4.2). A single genuine large prime strictly enlarges the split set (Theorem 4.3), and the added columns are exactly the split primes in $(B, L]$ (Proposition 4.4). Splitness is a congruence condition modulo $4N$ (Theorem 6.1), so it cannot be avoided by choosing large primes.
- *Final matrix.* After pairing (Theorem 5.1), the large primes cancel. More than $Q(B)$ combined relations always contain a square product (Theorem 5.2), so the final matrix has $Q(B)$ columns.

Neither stage decouples the column count from the split set. The large-prime variant stays a valuable accelerator of relation yield, and the other two mechanisms (b) and (c) are not affected by this analysis.

---

## 2. Definitions and notation

Throughout, $N$ is an integer (positive when stated), and

$$f(c) = c^2 - N \qquad (c \in \mathbb{Z})$$

is the *sieve polynomial*. For an odd prime $r$, $\left(\frac{a}{r}\right)$ is the Legendre symbol. For odd positive $n$, $\left(\frac{a}{n}\right)$ is the Jacobi symbol.

**Definition 2.1 (split, inert, ramified).** Let $r$ be an odd prime. We say $r$ is *split* for $N$ if $\left(\frac{N}{r}\right) = +1$, *inert* if $\left(\frac{N}{r}\right) = -1$, and *ramified* if $r \mid N$.

**Definition 2.2 (admissible primes, the split set).** For a bound $L \ge 1$, the set of *admissible primes* is

$$\mathcal{A}(N, L) = \{\, p \le L \text{ prime} : N \text{ is a square in } \mathbb{Z}/p\mathbb{Z} \,\}.$$

It contains $2$, all split primes up to $L$, and all ramified primes up to $L$. We write

$$Q(L) = |\mathcal{A}(N, L)|.$$

We loosely call $\mathcal{A}(N, L)$ the *split set*. It is the set of primes that can ever divide a value of $f$ (Lemma 3.0), so it is the natural column set.

**Definition 2.3 (relations).** A *full relation* is a pair $(c, f(c))$ with $f(c) \neq 0$ and $B$-smooth. A *partial relation* (with one large prime) is a pair $(c, f(c))$ with $f(c) = s \cdot r$, where $s$ is $B$-smooth and $r$ is a prime with $B < r \le L$. An *LP-$k$ relation* allows up to $k$ prime factors above $B$, all at most $L$.

**Definition 2.4 (quadratic polynomials).** For integers $a, b, c$ the polynomial $g(x) = ax^2 + bx + c$ has *discriminant* $D = b^2 - 4ac$. Multiple-polynomial versions of the sieve use such $g$ in place of $f$. Note that $f$ itself has discriminant $4N$.

**Monotonicity.** Clearly $\mathcal{A}(N, B) \subseteq \mathcal{A}(N, L)$ for $B \le L$.

---

## 3. Large primes are split

**Lemma 3.0 (divisibility criterion).** For a prime $r$ and any $N$, the following are equivalent: (a) $r \mid f(c)$ for some $c \in \mathbb{Z}$; (b) $N$ is a square modulo $r$. Moreover, $r \mid f(c)$ if and only if $c^2 = N$ in $\mathbb{Z}/r\mathbb{Z}$.

*Proof.* $r \mid c^2 - N$ means exactly $c^2 \equiv N \pmod r$. For (b) $\Rightarrow$ (a), lift a square root of $N$ modulo $r$ to an integer $c$. $\square$

**Theorem 3.1 (large primes are split: Legendre form).** Let $r$ be a prime, $r \nmid N$, and suppose $r \mid c^2 - N$ for some integer $c$. Then

$$\left(\frac{N}{r}\right) = +1 .$$

(For $r = 2$ the right side is read as "$N$ is a nonzero square mod 2", which always holds when $2 \nmid N$.)

*Proof.* From $r \mid c^2 - N$ we get $N \equiv c^2 \pmod r$. So $N$ is a square modulo $r$, and it is nonzero because $r \nmid N$. By the definition of the Legendre symbol, $\left(\frac{N}{r}\right) = +1$. $\square$

Note that the size of $r$ never enters. "Large" primes satisfy exactly the same condition as factor-base primes.

**Corollary 3.2 (no inert columns).** If a prime $r$ divides some value of $f$, then $\left(\frac{N}{r}\right) \neq -1$; no coprimality assumption is needed. Equivalently, if $\left(\frac{N}{r}\right) = -1$, then $r \nmid c^2 - N$ for every $c$. Hence $\left(\frac{N}{r}\right) \in \{0, 1\}$ for every prime divisor $r$ of every value, with $0$ exactly when $r \mid N$.

*Proof.* $N$ is a square modulo $r$ by Lemma 3.0, and $\left(\frac{N}{r}\right) = -1$ says precisely that it is not. $\square$

**Theorem 3.3 (Euler form).** If $r$ is an odd prime with $r \nmid N$ and $r \mid c^2 - N$, then

$$N^{(r-1)/2} \equiv 1 \pmod r .$$

*Proof.* By Theorem 3.1 and Euler's criterion $\left(\frac{N}{r}\right) \equiv N^{(r-1)/2} \pmod r$. More directly, $N^{(r-1)/2} \equiv c^{r-1} \equiv 1$ by Fermat's little theorem, since $r \nmid c$. $\square$

**Theorem 3.4 (hit count).** For an odd prime $r$ and any integer $N$,

$$\#\{\, c \in \mathbb{Z}/r\mathbb{Z} : r \mid c^2 - N \,\} \;=\; 1 + \left(\frac{N}{r}\right).$$

*Proof.* The set in question is the set of square roots of $N$ in the field $\mathbb{F}_r$. If $N \equiv 0$ there is exactly one root, $0$. If $N$ is a nonzero square $t^2$ there are exactly two, $\pm t$, which are distinct because $r$ is odd. If $N$ is a non-square there are none. These counts $1, 2, 0$ are $1 + \left(\frac{N}{r}\right)$ in the three cases. $\square$

Theorem 3.4 is the per-column *sieve weight*. A split prime is hit twice per period of length $r$, so it divides about $2/r$ of all values. This is the quantity the large-prime variant adds to when it allows new columns.

**Theorem 3.5 (multiple polynomials).** Let $g(x) = ax^2 + bx + c$ have discriminant $D$. If a prime $r \nmid D$ divides $g(x)$ for some integer $x$, then $D$ is a nonzero square modulo $r$. For odd $r$ this means $\left(\frac{D}{r}\right) = +1$.

*Proof.* Use the identity $4a\,g(x) = (2ax + b)^2 - D$. If $r \mid g(x)$, then $D \equiv (2ax + b)^2 \pmod r$. (When $r \mid a$ we can argue directly: $D = b^2 - 4ac \equiv b^2$.) In either case $D$ is a square modulo $r$, and it is nonzero since $r \nmid D$. $\square$

So passing to many polynomials, as in the multiple-polynomial quadratic sieve, does not produce non-split large primes. With $D = 4N\cdot(\text{square})$ for the usual choices, the condition is again $\left(\frac{N}{r}\right) = +1$.

---

## 4. The column set of large-prime relation matrices

**Theorem 4.1 (support theorem, any number of large primes).** Let $x \in \mathbb{Z}$ with $v = x^2 - N \neq 0$, and let $L \ge |v|$. Then every prime factor of $|v|$ lies in $\mathcal{A}(N, L)$.

*Proof.* Let $p$ be a prime factor of $|v|$. Since $v \ne 0$, $p \le |v| \le L$. Since $p \mid x^2 - N$, Lemma 3.0 shows $N$ is a square modulo $p$. So $p \in \mathcal{A}(N, L)$. $\square$

**Theorem 4.2 (columns of LP relation matrices).** Let $(x_i)_{i \in S}$ be a finite family of integers. Suppose that for each $i$, every prime factor of $|x_i^2 - N|$ is at most $L$; the values may contain arbitrarily many primes above $B$. Let

$$\mathcal{C} = \bigcup_{i \in S} \{\, p \text{ prime} : p \mid x_i^2 - N \,\}$$

be the column set of the corresponding relation matrix. Then

$$\mathcal{C} \subseteq \mathcal{A}(N, L) \qquad\text{and hence}\qquad |\mathcal{C}| \le Q(L).$$

*Proof.* Each $p \in \mathcal{C}$ is prime, satisfies $p \le L$ by hypothesis, and divides some value of $f$, so $N$ is a square modulo $p$ by Lemma 3.0. The cardinality bound follows. $\square$

The theorem is uniform in the number of large primes. Single, double, and triple large-prime variants all draw their columns from the split set up to $L$.

**Theorem 4.3 (a large prime strictly enlarges the split set).** Let $r$ be a prime with $B < r \le L$ that divides some value $x^2 - N$. Then

$$Q(B) < Q(L).$$

*Proof.* By monotonicity, $\mathcal{A}(N, B) \subseteq \mathcal{A}(N, L)$. The prime $r$ belongs to $\mathcal{A}(N, L)$ by Lemma 3.0 and $r \le L$. It does not belong to $\mathcal{A}(N, B)$ because $r > B$. So the inclusion is strict, and so is the inequality of cardinalities. $\square$

**Proposition 4.4 (the extra columns are exactly split primes).** For $B \le L$,

$$Q(L) = Q(B) + \bigl|\mathcal{A}(N, L) \setminus \mathcal{A}(N, B)\bigr|,$$

and $\mathcal{A}(N, L) \setminus \mathcal{A}(N, B)$ consists of the primes in $(B, L]$ at which $N$ is a square. Inert primes in $(B, L]$ contribute nothing.

*Proof.* This is the decomposition of a finite set into a subset and its complement, applied to $\mathcal{A}(N, B) \subseteq \mathcal{A}(N, L)$. $\square$

**Interpretation.** At the level of partial-relation bookkeeping, the large-prime variant does not decouple the column count from the split set. Each large prime is a split prime (Theorem 3.1). The full column set is a subset of the split set up to $L$ (Theorem 4.2). Whenever the variant actually contributes, it moves from the split set up to $B$ to a strictly larger split set (Theorem 4.3). The added columns are counted exactly by the split primes between $B$ and $L$ (Proposition 4.4).

---

## 5. Pairing and the final matrix

A partial relation alone cannot help, because its large prime occurs to the first power and nothing else in the factor base cancels it. Partial relations become useful when they share a large prime.

**Theorem 5.1 (pigeonhole pairing).** Let $m$ partial relations be given:

$$x_i^2 - N = s_i\, r_i \qquad (1 \le i \le m),$$

where each $s_i \ge 1$ is $B$-smooth and each $r_i$ is prime. Suppose all $r_i$ lie in a finite set $R$ with $|R| < m$. Then there exist $i \neq j$ with $r_i = r_j$, and every prime occurring to an odd power in $(s_i r_i)(s_j r_j)$ lies in the small split set $\mathcal{A}(N, B)$.

*Proof.* The map $i \mapsto r_i$ from an $m$-element set to $R$ cannot be injective, which gives $i \ne j$ with $r_i = r_j =: r$. Then $(s_i r)(s_j r) = s_i s_j r^2$, so the odd-exponent primes are among those dividing $s_i s_j$. Each such prime $p$ is at most $B$ and divides a value of $f$, namely $x_i^2 - N$ or $x_j^2 - N$. By Lemma 3.0 it lies in $\mathcal{A}(N, B)$. $\square$

Multiplying the two congruences gives the *combined relation*

$$(x_i x_j)^2 \equiv s_i s_j\, r^2 \pmod N,$$

whose right side is, modulo squares, supported on the small split set.

**Theorem 5.2 (combined relations need only $Q(B) + 1$ rows).** Let $n$ pairs of relations be given:

$$x_{1,i}^2 - N = s_{1,i}\, r_i, \qquad x_{2,i}^2 - N = s_{2,i}\, r_i \qquad (1 \le i \le n),$$

with $s_{1,i}, s_{2,i} \ge 1$ $B$-smooth and $r_i$ arbitrary positive integers (primality is not needed). If $n > Q(B)$, there is a nonempty set $T \subseteq \{1, \dots, n\}$ such that

$$\prod_{i \in T} (s_{1,i} r_i)(s_{2,i} r_i)$$

is a perfect square.

*Proof.* Every prime factor of $s_{1,i}$ or $s_{2,i}$ is at most $B$ and divides a value of $f$, so it lies in $\mathcal{A}(N, B)$. Map each $i$ to the exponent vector of $s_{1,i}s_{2,i}$ modulo $2$, an element of $\mathbb{F}_2^{\mathcal{A}(N, B)}$. This space has dimension $Q(B) < n$, so the $n$ vectors are linearly dependent. A nonempty subset $T$ therefore has vector sum zero, which makes $\prod_{i \in T} s_{1,i}s_{2,i}$ a square. Finally,

$$\prod_{i \in T} (s_{1,i} r_i)(s_{2,i} r_i) = \Bigl(\prod_{i\in T} s_{1,i}s_{2,i}\Bigr)\cdot\Bigl(\prod_{i \in T} r_i\Bigr)^2,$$

which is a product of two squares. $\square$

**Interpretation (the boundary of the bookkeeping claim).** Theorem 5.2 marks a precise boundary. The statement "the large-prime variant adds split-prime columns" is correct for the matrix of *partial* relations. It is not correct for the *final* matrix. After pairing, the large primes occur squared and drop out modulo 2. The final $\mathbb{F}_2$ system has $Q(B)$ columns (plus one sign column if negative values are allowed), and $Q(B) + 1$ combined rows suffice for a dependency, independently of $L$. Combining the two stages:

> **Corollary 5.3.** The large-prime variant does not decouple the column count from the split set. At the partial stage its columns are split primes up to $L$. At the final stage the column count is $Q(B)$. Its only effect on the linear algebra is to supply more rows per unit of sieving, so it is a pure row-yield accelerator.

---

## 6. Reciprocity: the split set is a union of residue classes

One could try to rescue decoupling by selecting large primes from some special set. The next theorem rules this out: splitness is a property of a residue class.

**Theorem 6.1 (periodicity modulo $4N$).** Let $N > 0$, and let $r, r'$ be odd primes with $r \equiv r' \pmod{4N}$. If $r \nmid N$ and $r \mid c^2 - N$ for some integer $c$, then $r' \mid c'^2 - N$ for some integer $c'$.

*Proof.* By Theorem 3.1, $\left(\frac{N}{r}\right) = 1$. For a prime, the Legendre and Jacobi symbols agree. For fixed $N > 0$, the Jacobi symbol $n \mapsto \left(\frac{N}{n}\right)$ on odd positive $n$ depends only on $n \bmod 4N$. This is a standard consequence of quadratic reciprocity together with its supplementary laws for $\left(\frac{-1}{n}\right)$ and $\left(\frac{2}{n}\right)$. Hence $\left(\frac{N}{r'}\right) = \left(\frac{N}{r}\right) = 1$. In particular $N \not\equiv 0 \pmod{r'}$, since otherwise the symbol would be $0$, and $N$ is a nonzero square modulo $r'$. Lemma 3.0 then gives $c'$. $\square$

**Consequences.** The split primes are exactly the primes in a certain union of residue classes modulo $4N$. When $N$ is not a perfect square, the character $n \mapsto \left(\frac{N}{n}\right)$ is nontrivial modulo $4N$, so exactly half of the $\varphi(4N)$ classes coprime to $4N$ are split. Every large prime of every partial relation lies in one of these $\varphi(4N)/2$ classes. For example, for $N = 15$ the split classes modulo $60$ are $\{1, 7, 11, 17, 43, 49, 53, 59\}$ and the inert classes are $\{13, 19, 23, 29, 31, 37, 41, 47\}$.

---

## 7. Numerical illustration

All numbers below were computed by direct calculation (complete factorisation by trial division and Pollard's rho method, Legendre symbols by Euler's criterion, and the sieve exactly as described in Section 8).

**7.1 A pure large-prime relation.** Let

$$N = 15\,916\,539\,906\,629, \qquad c = 3\,989\,570 \quad(\lfloor\sqrt N\rfloor = 3\,989\,553).$$

Then $f(c) = c^2 - N = 128\,878\,271$, which is prime. So $(c, f(c))$ is a partial relation with smooth part $s = 1$ and large prime $r = 128\,878\,271$. Theorem 3.1 predicts $\left(\frac{N}{r}\right) = 1$. Indeed $N \equiv c^2 \equiv 73\,438\,129 \pmod r$, and Euler's criterion confirms $\left(\frac{N}{r}\right) = +1$.

**7.2 A scan.** For the same $N$ and the $400$ consecutive values $c = 3\,989\,554, \ldots, 3\,989\,953$, complete factorisation of $f(c)$ gives $996$ odd prime divisors, counted with repetition across values. All $996$ are split, none is inert, and none is ramified. The largest is about $3.16 \times 10^9$. This is a sanity check consistent with Corollary 3.2, not a substitute for its proof.

**7.3 Hit counts.** For $N = 87\,463$ and every odd prime $r < 60$, direct counting of $c \bmod r$ with $r \mid c^2 - N$ agrees with $1 + \left(\frac{N}{r}\right)$ (Theorem 3.4). The inert primes $5, 7, 11, 23, 31, 37, 47$ have zero hits. The split primes $3, 13, 17, 19, 29, 41, 43, 53, 59$ have two hits each.

**7.4 A complete toy factorisation with large primes.** Take $N = 1\,000\,000\,016\,000\,000\,063$, $B = 4000$, $L = 400\,000$, and sieve the $120\,000$ values of $c$ with $|c - \sqrt N| \le 60\,000$:

| quantity | value |
|---|---|
| $Q(B)$ (factor base) | $276$ |
| $Q(L)$ | $16\,961$ |
| full relations | $326$ |
| partial relations | $3\,288$ |
| distinct large primes | $2\,757$, none inert |
| combined relations from pairing | $531$ |
| final matrix | $857$ rows $\times$ $277$ columns |

The $277$ columns are the $Q(B) = 276$ factor-base primes plus one sign column. The large-prime bound $L$ does not affect this number (Theorem 5.2). A three-row dependency gives $\gcd(X - Y, N) = 1\,000\,000\,007$, so $N = 1\,000\,000\,007 \times 1\,000\,000\,009$.

**7.5 Residue classes.** For $N = 15$, every odd prime $r < 20\,000$ with $r \nmid 15$ has a Legendre symbol determined by $r \bmod 60$. The split classes are the eight listed in Section 6, which is $\varphi(60)/2 = 8$.

---

## 8. Algorithms

**Algorithm A (split-set factor base).** Input $N$, $B$. Sieve the primes up to $B$. Keep $2$ and every odd prime $p$ with $N^{(p-1)/2} \not\equiv -1 \pmod p$. For each kept odd $p \nmid N$, compute the two roots $\pm t_p$ of $t^2 \equiv N \pmod p$, for instance by Tonelli–Shanks. *Cost:* $O(B \log\log B)$ for the prime sieve, plus $O(\pi(B)\log^2 B)$ word operations for the symbols and roots. By Theorem 3.4, each kept odd prime has $1 + \left(\frac{N}{p}\right)$ sieve progressions; discarded primes have none.

**Algorithm B (single-large-prime sieve with pairing).** For each $c$ in the interval, divide $f(c)$ by the factor base to get a cofactor $u$. If $u = 1$, record a full relation. If $B < u \le L$ and $u$ is prime, record a partial relation in a hash table keyed by $u$. (When $L < B^2$, any cofactor $u \in (B, L]$ is automatically prime, since all of its prime factors exceed $B$.) At the end, for each key $r$ with relations $\rho_1, \ldots, \rho_k$, emit the $k-1$ combined relations $\rho_1\rho_j$ ($2 \le j \le k$). By Theorem 3.1 the keys are always split primes, so the table can be sized by $Q(L) - Q(B)$ rather than $\pi(L) - \pi(B)$. *Cost:* sieving dominates. Pairing takes expected linear time in the number of partials.

**Algorithm C ($\mathbb{F}_2$ dependency).** Encode each final relation as a bit vector of length $Q(B) + 1$, consisting of the factor-base primes and the sign. Perform incremental Gaussian elimination, keeping for each pivot a mask of the rows combined into it. The first row that reduces to zero yields a dependency. By Theorem 5.2, at most $Q(B) + 2$ rows are needed, independently of $L$. *Cost:* $O(R \cdot Q(B)^2 / w)$ word operations for $R$ rows and word size $w$. Structured or block Lanczos methods are used at scale.

---

## 9. Discussion

**What is ruled out.** In the mechanism examined here, the "large" primes were hoped to provide columns outside the split set. Theorem 3.1 shows they lie inside it by construction. Theorem 6.1 shows the constraint cannot be bypassed by selection. Theorem 5.2 shows that in the final linear algebra the large primes disappear altogether. Corollary 5.3 states the joint conclusion. The argument requires no experiments, which is why we regard the question as settled by analysis, not by search.

**What survives.** The large-prime variant remains a standard and effective accelerator. It converts near-misses into usable rows. In the toy run of Section 7.4 it increased the number of final rows from $326$ to $857$ on the same sieve interval. It simply acts on rows and not on columns. Multiple-polynomial sieving does not escape the split condition at the level of individual primes either (Theorem 3.5). Whether multiple polynomials, or an adaptive choice of $B$, can change the cost trade-off in other ways is outside the scope of the present argument and remains open.

**A remark on presentation.** It is easy to state the large-prime phenomenon too strongly in either direction. "The large-prime variant adds split columns" is true of the partial-relation matrix (Theorems 4.2 and 4.3). "The final matrix has $Q(B)$ columns" is true after pairing (Theorem 5.2). Both statements are consistent, and both rule out decoupling.

---

## 10. Future directions and conjectures

**Conjecture 10.1 (split-restricted birthday law).** Among $m$ partial relations with large primes in $(B, L]$, the expected number of repeated large primes is approximately

$$\frac{m^2}{2\bigl(Q(L) - Q(B)\bigr)} \qquad\text{for } m \ll \sqrt{Q(L) - Q(B)} .$$

*Heuristic:* large primes are distributed only over the split primes in $(B, L]$ (Theorem 3.1). There are about $\tfrac12(\pi(L) - \pi(B))$ of these, so the birthday denominator is halved and the collision rate doubled compared with a naive all-primes model. In a uniform-draw simulation with $m = 60$ for the $N$ of Section 7.1, $B = 2000$, $L = 200\,000$ ($Q(L) - Q(B) = 8721$ against $\pi(L) - \pi(B) = 17\,681$), the predicted $0.206$ collisions compare with a simulated $0.216$, while the naive model gives $0.102$. The real distribution of large primes, which is biased toward smaller primes, remains to be measured.

**Conjecture 10.2 (adaptive-$B$ column monotonicity).** For any adaptive schedule $B_1 \le B_2 \le \cdots \le B_{\max}$, the final column count is $Q(B_{\max})$, and the work needed to collect $Q(B_{\max}) + 1$ rows cannot fall below the static optimum. *Heuristic:* by monotonicity of $\mathcal{A}(N, \cdot)$, every schedule is dominated by its endpoint.

**Conjecture 10.3 (equidistribution in split classes).** The large primes of partial relations are asymptotically equidistributed over the $\varphi(4N)/2$ split residue classes modulo $4N$. *Heuristic:* Theorem 6.1 together with Dirichlet's theorem on primes in arithmetic progressions.

**Conjecture 10.4 (double-large-prime cycle rank).** In the graph whose vertices are split primes (together with a vertex $1$), with an edge for each relation carrying two large primes, the number of independent combined relations equals the cycle rank $\#\text{edges} - \#\text{vertices} + \#\text{components}$. Each cycle gives a relation supported on the $Q(B)$ small columns. *Heuristic:* Theorem 4.1 places every vertex in the split set, and Theorem 5.2 is the two-edge case.

---

## 11. Conclusion

A prime that divides $c^2 - N$ sees $N$ as a square. That single congruence decides the question this paper set out to answer. The large primes of the partial-relation variant are split primes, the columns they add are split columns, their splitness is fixed by their residue class modulo $4N$, and after pairing they cancel, leaving $Q(B)$ columns. The large-prime variant increases the yield of rows. It does not change the column side of the trade-off.

---

## References

- C. Pomerance, *Analysis and comparison of some integer factoring algorithms*, in Computational Methods in Number Theory, Math. Centrum, Amsterdam, 1982.
- R. Crandall and C. Pomerance, *Prime Numbers: A Computational Perspective*, 2nd ed., Springer, 2005.
- K. Ireland and M. Rosen, *A Classical Introduction to Modern Number Theory*, 2nd ed., Springer, 1990.
