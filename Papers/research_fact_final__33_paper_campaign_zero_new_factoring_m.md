# Four Elementary Walls Around Integer Factoring: Split Sets, Pythagorean Legs, Symmetric Readouts, and Rank-Two Prime Covers

**Aristotle**

*October 2026*

---

## Abstract

We report the outcome of a systematic search for new integer-factoring methods. The search covered nine families of approaches: deterministic Lehman-type methods, divisor covers, Pythagorean/Berggren descents, Galois side channels, smoothness, transcendence, class groups, the quadratic sieve, and the number field sieve. It found no new method. In every family, the failure was traced either to a theorem or to a validated measurement. This paper gives complete statements and proofs of four elementary theorems that close specific routes, together with the context that motivates them.

1. **Split-set invariance.** For every prime $p \nmid a$, the prime $p$ divides a value of $(ax+b)^2 - N$ if and only if $N$ is a quadratic residue modulo $p$. Consequently no family of multiple-polynomial quadratic sieve (MPQS) polynomials enlarges or shrinks the column set, and the column density is exactly $(p-1)/2$ out of $p-1$. This corrects an earlier claimed density of $\sim 1/4$.
2. **The Pythagorean leg channel.** For every $N > 1$, a triple $N^2 + b^2 = c^2$ with $b > 0$ and $c - b \neq 1$ reveals the nontrivial divisor $\gcd(c-b, N)$. For odd $N$, $N$ is composite if and only if it is the leg of such a triple. Locating a nontrivial triple is therefore equivalent to factoring.
3. **The which-factor wall.** If a readout is invariant under an involution that flips a label, every decoder is correct on at most half of the secrets. For semiprimes, the readout $pq$ and the label "first factor" give a sharp bound of $1/2$, attained by the least-prime-factor decoder.
4. **Rank-two local obstructions.** If all differences $a - b$ with $a \in A$, $b \in B$ are primes exceeding $m$, then $A$ and $B$ occupy disjoint residue classes modulo every prime $\ell \le m$. Separately, any cover of a target set $T$ by differences satisfies $|T| \le |A||B|$, with equality forcing injectivity.

We describe algorithms and numerical experiments that illustrate each theorem, and we isolate three open problems that make up the current frontier.

---

## 1. Introduction

### 1.1 The state of factoring

Let $N$ be a positive integer, typically a product $N = pq$ of two large primes. The best rigorous deterministic factoring algorithms run in time $N^{1/5 + o(1)}$. This exponent is an *upper bound*. No matching lower bound is known, and no unconditional superpolynomial lower bound for factoring is known in any general model of computation. Heuristic and randomised methods, chiefly the quadratic sieve (QS) and the number field sieve (NFS), are much faster in practice. Their analyses depend on unproved hypotheses about the distribution of smooth numbers, or on probabilistic assumptions.

The campaign reported here asked whether any of the known families of ideas yields a new factoring method, deterministic or otherwise, or pushes the deterministic exponent below $1/5$. The headline answer is negative: **zero new factoring methods were found.** The useful output is a *rigorous characterisation of the frontier*. Each family was closed by an explicit argument, and the arguments sort into a small number of reusable principles.

### 1.2 Summary of family verdicts

We summarise the verdicts to give context. The four theorems proved in this paper are marked with a dagger ($\dagger$). The other entries are reported as findings of the broader programme, with the kind of evidence on which each rests.

| Family | Verdict | Kind of argument |
|---|---|---|
| Deterministic $N^{1/5}$ (Lehman–baby-step/giant-step) | intrinsic to the core motif | three independent re-derivations; the "interior" and "$m$-leg" constraints are slack |
| Divisor-cover (one-dimensional) | refuted | published theorem of He and Sahai (false for parameters $\alpha < 1/2$, $\beta < 3/8$, in particular $(1/3,1/3)$) |
| Divisor-cover (rank two) | open | local obstructions $\dagger$ (Section 6) |
| Pythagorean / Berggren | closed | leg channel is a coordinate gcd and is circular $\dagger$ (Section 4); cost floor $Y^{0.6232}$ |
| Galois / Frobenius side channels | closed in three ways | abelianization cap, which-factor wall $\dagger$ (Section 5), torsor no-pruning |
| Smoothness | deep but orthogonal | no per-instance upper bound; the $N^{1/5}$ record carries no smoothness term |
| Transcendence (Baker, $S$-units) | closed | object mismatch: the relevant effective bounds never involve $N$ |
| Class groups | priced by ERH, not Cohen–Lenstra | family-to-subfamily transfer measured false ($z = -41.4$); $h(-pq)$ is an output, not a cost |
| Quadratic sieve | no decoupling | column space equals split set $\dagger$ (Section 3); complete-cost rule |
| Number field sieve | as closed as QS | column set governed by the degree $d$, not by $N$, but no exploitable excess |

### 1.3 General principles

Several methodological findings came out of the campaign. We state them because they are what make the closures reusable.

- **Slack-constraint principle.** Adding a hypothesis that tightens a constraint moves an optimal exponent only if that constraint is *active* at the unconstrained optimum. Slack constraints can be tightened freely without effect.
- **Complete-cost rule.** The cost of a sieve method is the sieve cost *plus* the cost of linear elimination over $\mathbb{F}_2$. Pricing the sieve alone can reverse the sign of a parameter trade-off.
- **Inequality-direction rule.** A proved ceiling can bound the wrong side of a cost. For example, an inequality of the form $\mathrm{rank} + 1 \le k_{\text{success}}$ bounds the success index from below, so a rank ceiling is not a work bound.
- **Vacuity filter.** Any bound exponential in a rank or set size must be compared with the trivial bound before it is used. In one instance, a published bound turned out to be about $7.3 \times 10^5$ orders of magnitude weaker than doing nothing.
- **No pooling across instances.** A within-pool standard error from pooled instances must not be reported as a $z$-score.
- **Symmetric-readout vacuity.** For an unordered secret and an order-sensitive label, every public-input readout is blind. Section 5 makes this precise.

### 1.4 Corrections to the record

The campaign also corrected statements in its own record:

- a density barrier described as "absolute for any method" was downgraded to conjectured, because a necessary ingredient does not exist;
- the claim that a certain 2-torsion subgroup is $C_2$ for every $N$ is false for $N \equiv 1 \pmod 4$;
- the claimed $\sim 1/4$ multiple-polynomial column density was measured at $0.487$–$0.505$, and Theorem 3.5 below proves the exact value $1/2$;
- the claim $k_{\text{success}} \le Q + 1$ is not a theorem, and the inequality $\mathrm{rank}+1 \le k_{\text{success}}$ had been used in the wrong direction;
- a set of raw experimental figures was retracted because they were published before adversarial verification and could not be reproduced.

### 1.5 Organisation

Section 2 fixes notation. Sections 3–6 state and prove the four theorems. Section 7 describes algorithms and experiments. Section 8 discusses the open frontier, and Section 9 lists future directions.

---

## 2. Preliminaries and notation

Throughout, $p$ and $\ell$ denote primes and $N$ a positive integer. For a prime $p$, $\mathbb{Z}/p\mathbb{Z}$ is the field with $p$ elements. An element $n \in \mathbb{Z}/p\mathbb{Z}$ is a *square* if $n = y^2$ for some $y \in \mathbb{Z}/p\mathbb{Z}$. Note that $0$ counts as a square.

**Definition 2.1 (Split set).** The *split set* of $N$ is the set of primes $p$ such that $N$ is a square modulo $p$.

**Definition 2.2 (Sieve polynomials).** For integers $N, a, b, c$ define
$$V_{N,a,b}(x) = (ax+b)^2 - N, \qquad Q_{a,b,c}(x) = a x^2 + 2bx + c.$$
For $a = 1$, $b = 0$, $V_{N,1,0}(x) = x^2 - N$ is the single quadratic-sieve polynomial.

**Definition 2.3 (Column).** A prime $p$ is a *column* of an integer polynomial $F$ if $p \mid F(x)$ for some integer $x$.

**Definition 2.4 (Nontrivial divisor).** An integer $d$ is a *nontrivial divisor* of $N$ if $d \mid N$ and $1 < d < N$.

**Definition 2.5 (Pythagorean triple).** A triple of integers $(x, y, z)$ is *Pythagorean* if $x^2 + y^2 = z^2$. When $x = N$ we call $N$ the *leg* and write the triple as $(N, b, c)$.

**Lemma 2.6 (Single-polynomial criterion).** A prime $p$ divides $y^2 - N$ for some integer $y$ if and only if $N$ is a square modulo $p$. Moreover, $p \mid y^2 - N$ if and only if $y^2 \equiv N$ in $\mathbb{Z}/p\mathbb{Z}$.

*Proof.* Divisibility by $p$ is the same as vanishing modulo $p$. Every residue class modulo $p$ has an integer representative. $\square$

**Lemma 2.7 (Counting residues).** For an odd prime $p$, exactly $(p-1)/2$ of the nonzero residues modulo $p$ are squares.

*Proof.* The squaring map on $(\mathbb{Z}/p\mathbb{Z})^\times$ is a group homomorphism with kernel $\{\pm 1\}$, which has two elements since $p$ is odd. Its image therefore has $(p-1)/2$ elements. $\square$

---

## 3. The multiple-polynomial column set is the split set

### 3.1 Background

In the quadratic sieve, a *relation* is an $x$ for which $x^2 - N$ factors completely over a fixed set of small primes, the factor base. The relations are combined by Gaussian elimination over $\mathbb{F}_2$ into a congruence of squares. Only primes in the split set can divide a value $x^2 - N$ (Lemma 2.6), so in effect the factor base is the split set below a bound.

The multiple-polynomial variant replaces $x^2 - N$ by many polynomials $Q_{a,b,c}$ with $b^2 - ac = N$. They are related to $V_{N,a,b}$ by the identity below. A claim in the record held that this confines relations to a column set of density $\sim 1/4$. We prove that the column set is unchanged.

### 3.2 Results

**Lemma 3.1 (MPQS identity).** If $b^2 - ac = N$, then for every $x$,
$$a \cdot Q_{a,b,c}(x) = V_{N,a,b}(x).$$

*Proof.* $a(ax^2 + 2bx + c) = a^2x^2 + 2abx + ac = (ax+b)^2 - (b^2 - ac)$. $\square$

**Lemma 3.2 (Shift identity).** $V_{N,a,b}(x) = (ax+b)^2 - N$ is the single-polynomial value at the point $y = ax + b$.

**Theorem 3.3 (Multiple-polynomial column criterion).** Let $p$ be a prime with $p \nmid a$, and let $N, b$ be arbitrary integers. Then
$$\exists\, x \in \mathbb{Z}:\ p \mid (ax+b)^2 - N \quad\Longleftrightarrow\quad N \text{ is a square modulo } p.$$

*Proof.* ($\Rightarrow$) By Lemma 3.2, $y = ax + b$ satisfies $p \mid y^2 - N$, so $N$ is a square modulo $p$ by Lemma 2.6.

($\Leftarrow$) By Lemma 2.6 there is an integer $y$ with $y^2 \equiv N \pmod p$. Since $p \nmid a$, the class of $a$ is a unit in $\mathbb{Z}/p\mathbb{Z}$. Put $x_0 = a^{-1}(y - b) \in \mathbb{Z}/p\mathbb{Z}$, and let $x$ be any integer representative of $x_0$. Then $ax + b \equiv y$, so $(ax+b)^2 - N \equiv y^2 - N \equiv 0 \pmod p$. $\square$

**Corollary 3.4 (Reduced form).** If $b^2 - ac = N$ and $p \nmid a$, then $p$ is a column of $Q_{a,b,c}$ if and only if $N$ is a square modulo $p$.

*Proof.* By Lemma 3.1, $p \mid Q_{a,b,c}(x)$ implies $p \mid a Q_{a,b,c}(x) = V_{N,a,b}(x)$. Conversely, if $p \mid V_{N,a,b}(x) = a\,Q_{a,b,c}(x)$ and $p \nmid a$, then $p \mid Q_{a,b,c}(x)$ because $p$ is prime. So the columns of $Q_{a,b,c}$ and $V_{N,a,b}$ coincide, and Theorem 3.3 applies. $\square$

**Theorem 3.5 (No polynomial family changes the column set).** Let $\{(a_i, b_i)\}_{i \in I}$ be any nonempty family of integer pairs, and let $p$ be a prime with $p \nmid a_i$ for all $i$. Then
$$\exists\, i \in I,\ \exists\, x:\ p \mid (a_i x + b_i)^2 - N \quad\Longleftrightarrow\quad N \text{ is a square modulo } p.$$

*Proof.* The forward direction is Theorem 3.3 applied to the index $i$ that witnesses divisibility. For the backward direction, choose any $i \in I$ (the family is nonempty) and apply Theorem 3.3. $\square$

The index set $I$ is arbitrary: finite, infinite, adaptively chosen, or even dependent on $N$. The only requirement is that $p$ be coprime to all the leading coefficients. Primes dividing some $a_i$ are the usual small set excluded in MPQS practice, and for those primes the polynomial $V_{N,a_i,b_i}$ degenerates to the constant $b_i^2 - N$ modulo $p$.

**Theorem 3.6 (Exact column density).** Let $p$ be an odd prime, $p \nmid a$, and $b$ arbitrary. Then
$$\#\{\, n \in (\mathbb{Z}/p\mathbb{Z})^\times : \exists\, x,\ p \mid (ax+b)^2 - n \,\} = \frac{p-1}{2}.$$

*Proof.* By Theorem 3.3 the set is exactly the set of nonzero squares modulo $p$. Its size is $(p-1)/2$ by Lemma 2.7. $\square$

**Interpretation.** If $N$ is viewed as a uniformly random nonzero residue modulo each prime of the factor base, each prime is a column with probability exactly $1/2$, whatever the polynomial family. The measured densities $0.487$–$0.505$ agree with this. The claimed $\sim 1/4$ does not.

**Example 3.7.** Let $p = 7$, $a = 3$, $b = 5$. Since $3^2 = 9 \equiv 2 \pmod 7$, the integer $N = 2$ is a square modulo $7$. Over one period $x \in \{0, \dots, 6\}$, $(3x+5)^2 \equiv 2 \pmod 7$ has exactly the two solutions $x = 2$ and $x = 4$: indeed $11^2 - 2 = 119 = 7 \cdot 17$ and $17^2 - 2 = 287 = 7 \cdot 41$. For $N = 3$, a non-residue modulo $7$, there is no solution.

### 3.3 Consequence for the cost accounting

Since the column set cannot be shrunk by the choice of polynomials, the linear-algebra stage of any multiple-polynomial variant works with the same number of potential columns as the single-polynomial sieve. Together with the complete-cost rule (§1.3), this means the benefit of multiple polynomials lies entirely in the *sizes* of the sieved values, not in a smaller matrix. This is the precise sense in which there is no decoupling between the sieve and the column structure.

---

## 4. The Pythagorean leg channel is a coordinate gcd

### 4.1 Background

All primitive Pythagorean triples form a single ternary tree rooted at $(3,4,5)$, generated by three fixed integer matrices (the Berggren tree). This has motivated factoring proposals that place $N$ in a triple and navigate the tree. We show that for triples with leg $N$ the only information-bearing quantity is the coordinate gcd $\gcd(c-b, N)$, and that obtaining a nontrivial triple is equivalent to factoring.

### 4.2 Results

**Lemma 4.1 (Leg factor identity).** If $N, b, c \ge 0$ are integers with $N^2 + b^2 = c^2$, then $b \le c$ and
$$(c - b)(c + b) = N^2.$$

*Proof.* $c^2 - b^2 = N^2 \ge 0$ gives $b^2 \le c^2$, hence $b \le c$ for nonnegative integers. The identity is $c^2 - b^2 = N^2$ factored. $\square$

**Theorem 4.2 (The channel is a coordinate gcd).** Let $N > 1$, $b > 0$, $N^2 + b^2 = c^2$, and $c - b \neq 1$. Then $\gcd(c - b, N)$ is a nontrivial divisor of $N$.

*Proof.* Put $u = c - b$ and $v = c + b$. By Lemma 4.1, $uv = N^2$. Since $b > 0$, $u < v$. Also $u > 0$, since otherwise $N^2 = 0$. If $u \ge N$, then $uv > N \cdot N$ because $v > u \ge N$, a contradiction. Hence $u < N$.

Let $g = \gcd(u, N)$. Clearly $g \mid N$. If $g = 1$, then $u$ is coprime to $N^2$, and since $u \mid N^2$ this forces $u = 1$, contrary to hypothesis. So $g > 1$. Finally $g \le u < N$. $\square$

**Proposition 4.3 (The trivial triple).** For every $k \ge 0$,
$$(2k+1)^2 + (2k^2 + 2k)^2 = (2k^2+2k+1)^2,$$
and this triple has $c - b = 1$. So every odd $N$ is the leg of a triple carrying no information about its factors.

*Proof.* Direct expansion: both sides equal $4k^4 + 8k^3 + 8k^2 + 4k + 1$. $\square$

**Proposition 4.4 (Factorization triple).** For all $d, k \ge 0$,
$$\big(d(d+2k)\big)^2 + \big(2k(d+k)\big)^2 = \big(d^2 + 2kd + 2k^2\big)^2,$$
and the difference of the last two entries is $c - b = d^2$.

*Proof.* Polynomial identity. For the difference, $(d^2 + 2kd + 2k^2) - 2k(d+k) = d^2$. $\square$

So a factorization $N = de$ with $1 < d < e$ and $d \equiv e \pmod 2$ produces a triple with $c - b = d^2 \neq 1$.

**Proposition 4.5 (Scaled trivial triple).** For all $d, m \ge 0$,
$$\big(d(2m+1)\big)^2 + \big(d(2m^2+2m)\big)^2 = \big(d(2m^2+2m+1)\big)^2,$$
with $c - b = d$.

**Theorem 4.6 (Composite $\Leftrightarrow$ nontrivial leg triple).** Let $N > 1$ be odd. Then $N$ has a nontrivial divisor if and only if there are integers $b > 0$ and $c$ with $N^2 + b^2 = c^2$ and $c - b \neq 1$.

*Proof.* ($\Rightarrow$) Write $N = de$ with $d$ a nontrivial divisor, so $1 < d < N$ and $e = N/d > 1$. Since $N$ is odd, $e$ is odd, say $e = 2m+1$ with $m \ge 1$. Proposition 4.5 gives the triple $(N, d(2m^2+2m), d(2m^2+2m+1))$. Its second entry is positive, and $c - b = d \neq 1$.

($\Leftarrow$) This is Theorem 4.2. $\square$

**Example 4.7.** For $N = 15$ the triples with $b > 0$ are
$$15^2 + 112^2 = 113^2,\quad 15^2 + 36^2 = 39^2,\quad 15^2+20^2 = 25^2,\quad 15^2 + 8^2 = 17^2,$$
with $c - b \in \{1, 3, 5, 9\}$ and $\gcd(c-b, 15) \in \{1, 3, 5, 3\}$.

### 4.3 Interpretation

Theorem 4.6 says that "find a nontrivial triple with leg $N$" and "find a nontrivial divisor of $N$" are equivalent problems, with reductions computable by one gcd in one direction and a polynomial formula in the other. Any procedure that walks the Berggren tree, or uses any other triple-generating mechanism, and ends at a nontrivial leg triple has therefore solved the factoring instance. Its cost is at least the cost of factoring. The channel is circular. In the broader programme this is complemented by a cost analysis showing a floor of $Y^{0.6232}$ for tree descents, because the branching rate is smaller than the growth of the entries.

---

## 5. Symmetric readouts and the which-factor wall

### 5.1 Setting

Several proposed side channels (Frobenius elements, Galois actions, quadratic characters) try to extract an *order-sensitive* bit about the factors. Typical examples are "which factor is first" or "which factor has property $X$". The public data, however, is a function of $N = pq$, which is symmetric in $p$ and $q$. We formalise the obstruction abstractly.

**Definition 5.1.** A *symmetric-readout problem* consists of:

- a finite set $S$ of secrets;
- an involution $\sigma: S \to S$, meaning $\sigma(\sigma(x)) = x$;
- a readout $R: S \to Y$ with $R(\sigma x) = R(x)$;
- a label $L: S \to Z$ with $L(\sigma x) \neq L(x)$ for all $x \in S$.

A *decoder* is any function $D: Y \to Z$, with no restriction on its computational complexity.

### 5.2 Results

**Theorem 5.2 (Which-factor wall).** In any symmetric-readout problem and for every decoder $D$,
$$2 \cdot \#\{x \in S : D(R(x)) = L(x)\} \le \# S.$$

*Proof.* Let $T = \{x \in S : D(R(x)) = L(x)\}$. The map $\sigma$ is injective, being its own inverse, so $|\sigma(T)| = |T|$. We claim $T \cap \sigma(T) = \emptyset$. Suppose $x = \sigma(y)$ with $y \in T$ and $x \in T$. Then
$$L(\sigma y) = L(x) = D(R(x)) = D(R(\sigma y)) = D(R(y)) = L(y),$$
which contradicts $L(\sigma y) \neq L(y)$. Since $T \cup \sigma(T) \subseteq S$ and the union is disjoint, $2|T| \le |S|$. $\square$

**Corollary 5.3 (Symmetric-readout vacuity).** If $S \neq \emptyset$, no decoder satisfies $D(R(x)) = L(x)$ for all $x \in S$.

*Proof.* Otherwise $T = S$ and $2|S| \le |S|$, forcing $|S| = 0$. $\square$

**Theorem 5.4 (Semiprime instance).** Let $P$ be a finite set of natural numbers and let $S = \{(p,q) \in P \times P : p \neq q\}$ be the set of ordered pairs of distinct elements. For every function $D: \mathbb{N} \to \mathbb{N}$,
$$2 \cdot \#\{(p,q) \in S : D(pq) = p\} \le \#S.$$

*Proof.* Apply Theorem 5.2 with $\sigma(p,q) = (q,p)$, $R(p,q) = pq$, and $L(p,q) = p$. The swap is an involution preserving $S$, $pq = qp$, and $p \neq q$ on $S$. $\square$

**Lemma 5.5 (Balanced orientation).** With $S$ as in Theorem 5.4, $2\cdot\#\{(p,q) \in S : p < q\} = \#S$.

*Proof.* The swap is a bijection between pairs with $p < q$ and pairs with $p > q$, and every pair in $S$ is of one of these two kinds. $\square$

**Theorem 5.6 (The wall is sharp).** If every element of $P$ is prime, the decoder $D(N) = \operatorname{lpf}(N)$, the least prime factor, satisfies
$$2 \cdot \#\{(p,q) \in S : \operatorname{lpf}(pq) = p\} = \#S.$$

*Proof.* For distinct primes $p, q$, the least prime factor of $pq$ is a prime dividing $pq$, hence equal to $p$ or $q$. It is at most each of $p$ and $q$, since both divide $pq$. So $\operatorname{lpf}(pq) = \min(p,q)$, and $\operatorname{lpf}(pq) = p$ exactly when $p < q$. Now apply Lemma 5.5. $\square$

**Example 5.7.** For $P = \{2,3,5,7\}$ there are $12$ ordered pairs. The least-prime-factor decoder is correct on the $6$ increasing ones, and the decoder $N \mapsto N/\operatorname{lpf}(N)$ is correct on the other $6$.

### 5.3 Interpretation

The bound in Theorem 5.2 is *information-theoretic*. It holds for decoders of unbounded computational power. So any side channel whose target is an order-sensitive label of an unordered secret, and whose input is a symmetric function of the secret, is blind: on a uniformly random secret it does no better than a fair coin. In the programme this is one of three independent closures of the Galois side-channel family. The other two are an abelianization cap and a torsor "no-pruning" argument, in which an apparent additional primitive turned out to be a ghost, an artefact that carries no extra information.

---

## 6. Local obstructions for rank-two prime covers

### 6.1 Background

The divisor-cover approach asks for small structured sets whose differences or products cover a large set of primes. Its one-dimensional version is refuted by a published theorem of He and Sahai, which shows the required statement false for exponent parameters $\alpha < 1/2$, $\beta < 3/8$, in particular at $(1/3,1/3)$. The rank-two version is open. It asks for sets $A, B$ with $|A| = |B| \approx n^{1/3}$ whose difference set realises prime mass $\approx n^{2/3}$. We prove two unconditional necessary conditions.

**Definition 6.1.** Finite sets $A, B \subset \mathbb{Z}$ form a *prime-difference pair above $m$* if for all $a \in A$ and $b \in B$, $|a - b|$ is a prime exceeding $m$.

### 6.2 Results

**Lemma 6.2.** Let $\ell \le m$ be prime, and suppose $|a - b|$ is a prime exceeding $m$. Then $a \not\equiv b \pmod \ell$.

*Proof.* If $\ell \mid a - b$, then $\ell$ divides the prime $|a-b|$, so $\ell = |a-b| > m \ge \ell$, a contradiction. $\square$

**Theorem 6.3 (Disjoint residue classes).** If $(A, B)$ is a prime-difference pair above $m$ and $\ell \le m$ is prime, then the residue sets $A \bmod \ell$ and $B \bmod \ell$ are disjoint subsets of $\mathbb{Z}/\ell\mathbb{Z}$.

*Proof.* A common residue would be $a \bmod \ell = b \bmod \ell$ for some $a \in A$, $b \in B$, which Lemma 6.2 rules out. $\square$

**Corollary 6.4 (Local residue budget).** Under the same hypotheses,
$$\#(A \bmod \ell) + \#(B \bmod \ell) \le \ell.$$

*Proof.* The two sets are disjoint subsets of a set with $\ell$ elements. $\square$

**Corollary 6.5 (Parity rigidity).** If $(A,B)$ is a prime-difference pair above $m \ge 2$ and $B \neq \emptyset$, then all elements of $A$ have the same parity, and by symmetry so do all elements of $B$, the opposite one.

*Proof.* Fix $b \in B$. For $a, a' \in A$, Lemma 6.2 with $\ell = 2$ gives $a \not\equiv b$ and $a' \not\equiv b \pmod 2$. In $\mathbb{Z}/2\mathbb{Z}$ two elements different from the same element are equal, so $a \equiv a' \pmod 2$. $\square$

**Theorem 6.6 (Capacity).** Let $A, B \subset \mathbb{Z}$ be finite and $T \subset \mathbb{N}$ finite. If every $t \in T$ equals $|a - b|$ for some $a \in A$, $b \in B$, then $|T| \le |A|\cdot|B|$.

*Proof.* $T$ is contained in the image of $A \times B$ under $(a,b) \mapsto |a-b|$, and an image has at most as many elements as its domain. $\square$

**Theorem 6.7 (Tight capacity forces injectivity).** If in addition $|T| = |A|\cdot|B|$, then $(a,b) \mapsto |a-b|$ is injective on $A \times B$.

*Proof.* We have $|T| \le |\text{image}| \le |A \times B| = |T|$, so the image has the same size as the domain, and the map is injective. $\square$

**Example 6.8.** $A = \{0, 6\}$, $B = \{-5, -11\}$ give differences $5, 11, 11, 17$, all prime and above $m = 3$. Modulo $2$: $A \mapsto \{0\}$, $B \mapsto \{1\}$. Modulo $3$: $A \mapsto \{0\}$, $B \mapsto \{1\}$. The difference set $\{5, 11, 17\}$ has $3 < 4$ elements, and the cover is not injective because $11$ occurs twice.

### 6.3 Interpretation

At the target parameters $|A| = |B| = n^{1/3}$ and $|T| = n^{2/3}$, the capacity bound is an equality. So every pair must yield a *distinct* prime, and there is no slack at all. Simultaneously, Corollary 6.4 confines $(A \bmod \ell, B \bmod \ell)$ to pairs of disjoint subsets of $\mathbb{Z}/\ell\mathbb{Z}$ for every small $\ell$. If $\omega_\ell$ denotes the number of residue classes used, the proportion of admissible configurations carries a local factor of the form $\prod_{\ell \le m}(1 - \omega_\ell/\ell)$. This is the input of a two-dimensional Selberg sieve. The remaining step towards closing the rank-two door is therefore a global sieve upper bound (Section 9).

---

## 7. Algorithms and numerical experiments

We describe four procedures that illustrate the theorems. All of them are elementary and run in time polynomial in the sizes of their inputs, except where noted.

### 7.1 Column-set computation for a polynomial family

**Input:** $N$, a family $\{(a_i,b_i)\}$, and a factor base of primes.
**Output:** the union of column sets over primes coprime to every $a_i$.

For each prime $p$, skip it if $p \mid a_i$ for some $i$. Otherwise test, for each $i$, whether some $x \in \{0,\dots,p-1\}$ satisfies $(a_i x + b_i)^2 \equiv N \pmod p$. One period suffices by periodicity. This costs $O(|I| \cdot p)$ per prime. By Theorem 3.5 the answer can be computed in $O(\log p)$ by Euler's criterion $N^{(p-1)/2} \equiv 1 \pmod p$ (or $p \mid N$), independently of the family.

*Experiment.* For a twelve-digit semiprime $N = 1000003 \cdot 999983$, a factor base of the $2261$ odd primes below $20000$ that do not divide $N$, and six random MPQS pairs $(a_i, b_i)$ with entries below $10^6$, the family column set coincided exactly with the split set and with the single-polynomial column set on the common primes. Its empirical density was $1172/2255 \approx 0.520$. For each of nine primes $p \le 101$ and random $(a,b)$ with $p \nmid a$, the number of nonzero $n$ for which $p$ is a column was exactly $(p-1)/2$.

### 7.2 Leg-triple enumeration and the gcd channel

**Input:** $N$. **Output:** all triples $(N, b, c)$ with $b > 0$, and the gcd of each with $N$.

Enumerate divisors $u$ of $N^2$ with $u < N$ and $u \equiv N^2/u \pmod 2$. Set $b = (N^2/u - u)/2$ and $c = (N^2/u + u)/2$. Output $\gcd(c - b, N) = \gcd(u, N)$. The cost is dominated by enumerating divisors of $N^2$, which requires the factorization of $N$, in line with the circularity in Theorem 4.6.

*Experiment.* For every $N \in [3, 400]$, every nontrivial triple yielded a gcd strictly between $1$ and $N$, with no exceptions. For every odd $N \in [3, 999]$, the existence of a nontrivial triple matched compositeness exactly. The converse construction (Proposition 4.5) was checked on $(d,e) = (3,5), (7,11), (101,103)$.

### 7.3 Optimal decoders under a symmetric readout

**Input:** a finite set $P$ of primes. **Output:** the maximum accuracy of any decoder $N \mapsto$ guess for the first factor.

Group the ordered pairs by readout $N = pq$. Each group is $\{(p,q),(q,p)\}$, and the optimal decoder picks one label per group. This gives the exact optimum $|S|/2$, as Theorem 5.2 predicts. *Experiment:* for the $43$ primes in $[7, 200]$, the brute-force optimum was $903/1806 = 1/2$ exactly, the least-prime-factor decoder attained the same value, and a random coin-flip decoder scored $0.4945$.

### 7.4 Greedy search for prime-difference pairs

**Input:** a target size $s$, a threshold $m$, and a range $[0, X)$. **Output:** sets $A$, $B$ of size $s$ forming a prime-difference pair above $m$.

Scan candidates in random order and add each one to the smaller side when this keeps all differences prime and above $m$. This is a heuristic with no guarantee of success. *Experiment:* with $s = 5$, $m = 7$, $X = 3000$, the search found
$$A = \{494, 662, 1352, 1454, 1754\},\quad B = \{31, 1491, 1771, 1813, 2361\},$$
whose $25$ differences are $25$ *distinct* primes, a tight and injective cover. The residue occupancies were $(1,1)$ modulo $2$, $(1,2)$ modulo $3$, $(2,2)$ modulo $5$, and $(3,3)$ modulo $7$, all disjoint and within budget, as required by Corollary 6.4.

---

## 8. Discussion: the frontier

### 8.1 What has and has not been shown

Nothing in this work bears on lower bounds for factoring in general. The deterministic exponent $1/5$ is unchanged and remains an upper bound. What has been shown is that specific mechanisms cannot contribute:

- **polynomial diversity** in the quadratic sieve cannot alter the column set (Theorems 3.3–3.6);
- **Pythagorean structure** on the leg cannot deliver a factor more cheaply than factoring (Theorem 4.6);
- **symmetric public data** cannot determine an order-sensitive label of the factors with accuracy above $1/2$ (Theorems 5.2, 5.6);
- **rank-two prime covers** must be perfectly injective and residue-rigid (Theorems 6.3–6.7).

Each closure is unconditional and elementary. Taken together with the principles of §1.3, they show that the failures were structural and not a matter of insufficient effort.

### 8.2 The three open doors

1. **Rank-two additive separability.** Realise $n^{2/3}$ of prime mass as the difference set of two sets of size $n^{1/3}$, a system overdetermined by a factor $n^{1/3}$. No construction is known. Section 6 gives the necessary local conditions.
2. **Smooth-value upper bounds for structured forms.** An inequality of the shape $\Psi_F(x, y) \le C \cdot x \cdot \prod_i \rho(d_i u)$ for the number of $y$-smooth values of a structured polynomial form $F$, where $\rho$ is the Dickman function and $u = \log x / \log y$. This is the missing ingredient for the smoothness route, and it is open in both directions.
3. **A per-instance class-number bound.** A bound on $h(-pq)$ for a *single* imaginary quadratic field $\mathbb{Q}(\sqrt{-pq})$, as opposed to averages over families, which currently cannot be reached by enumeration.

---

## 9. Future directions

1. **Residue-box sieve bound for rank-two prime covers.** *Conjecture:* if $A, B \subset [1, X]$ and $A - B$ consists of primes exceeding $m$, then $|A|\cdot|B| \le C\, X^2/(\log X)^2$. Then the rank-two door cannot be reached with $|A| = |B| = n^{1/3}$ inside an interval of length $n^{1/3 + o(1)}$. The local residue budget supplies the local densities for a two-dimensional Selberg sieve.
2. **Exact leg-triple count.** *Conjecture:* for odd $N$, the number of triples $N^2 + b^2 = c^2$ with $b > 0$ is exactly $(\tau(N^2) - 1)/2$, and exactly one of them has $\gcd(c - b, N) = 1$. Lemma 4.1 turns triples into factorizations $uv = N^2$ with $u < v$, and for odd $N$ the parity condition $u \equiv v \pmod 2$ is automatic. Numerically, the count formula holds for all odd $N \le 799$.
3. **Which-factor wall for $k$-factor secrets.** *Conjecture:* for ordered $k$-tuples of distinct primes, readout equal to the product, and label equal to the first coordinate, every decoder is correct on at most a $1/k$ fraction, and the least prime factor attains $1/k$. The symmetric group $S_k$ acts freely on such tuples while preserving the readout, which turns the involution argument into an orbit argument.
4. **Number-field analogue of the split set.** *Conjecture:* in the number field sieve with a fixed degree-$d$ polynomial $f$, changing the family of linear polynomials $a - b\theta$ does not change the set of degree-one primes that can appear. That set is exactly $\{p : f \text{ has a root modulo } p\}$, with density $|G|^{-1}\cdot\#\{\sigma \in G : \sigma \text{ has a fixed point}\}$, where $G$ is the Galois group of $f$. The unit-shift argument of Theorem 3.3 should apply to a root of $f$ modulo $p$.

---

## 10. Conclusion

A broad search for new factoring methods ended without a method. It did end with a map. For each family examined there is an identified obstruction, and for four of them we have given complete elementary proofs. The column set of the quadratic sieve is rigid under change of polynomial. The Pythagorean leg channel is a single gcd and is equivalent to factoring. Symmetric readouts are blind to order-sensitive labels, with the sharp constant $1/2$. Rank-two prime covers must be injective and residue-disjoint at every small prime. The remaining frontier consists of three explicitly stated open problems.
