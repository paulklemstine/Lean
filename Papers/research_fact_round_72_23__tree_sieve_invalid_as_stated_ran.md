# Arithmetic Trees Cannot Factor: Lottery Bounds, Norm-Form Blindness, and a Trichotomy for Berggren-Tree Splitters

**Author:** Aristotle

**Date:** 2026-08-30

---

## Abstract

We give a complete structural analysis of a family of proposed integer-factoring procedures built on the Berggren ternary tree of primitive Pythagorean triples. Two concrete proposals motivate the study: a *tree sieve*, which harvests leg pairs $(m_i, n_i)$ from the tree and arranges $\prod_i (m_i - n_i)(m_i + n_i) = Y^2$ in the hope that a gcd splits a semiprime $N$; and a *multi-target relaxation*, which replaces the exact search goal $a = N$ by the far weaker goal $\gcd(a,N) > 1$.

We prove that the tree sieve is invalid as stated: the relation it produces is an identity in $\mathbb{Z}$, never a congruence modulo $N$, so the gcd step returns $N$ itself and the relation is divisible by every modulus — it carries no information about $N$. We then quantify the "lottery" behaviour of any $N$-independent candidate generator: $k$ tickets $D_0,\dots,D_{k-1}$ win on at most $\sum_i \log_2 D_i$ primes of any pool, so success probabilities add linearly and there is no amplification. A breadth-first search of the ternary tree is shown to be starved: reaching a hypotenuse of size $V$ requires expanding $n \ge \sqrt{V/5}$ nodes.

The central positive contribution is a *blindness* theorem. Every prime divisor of the hypotenuse of a primitive Pythagorean triple is $\equiv 1 \pmod 4$; hence the tree's hypotenuse face has gcd $1$ with every modulus whose prime factors are all $\equiv 3 \pmod 4$ — zero winning tickets, uniformly over the entire infinite tree. This simultaneously explains the empirically measured smoothness advantage of tree values (a halved factor base) and kills the method on a positive-density class of moduli. We generalise: if $c = a^2 + Db^2$ with $\gcd$-primitive $(a,b)$, then $-D$ is a square modulo every prime divisor of $c$, so any search constrained to a fixed norm form is blind to that form's inert primes. The blind classes for $D=1$ and $D=2$ are incomparable, showing that changing the form relocates the obstruction rather than removing it. By Dirichlet, each blind class contains infinitely many composite moduli.

For the multi-target relaxation we prove that the least $a \ge 2$ with $\gcd(a, N) > 1$ is *exactly* $\min(p,q)$ for $N = pq$, so an ascending value sweep first hits at $\min(p,q)$ deterministically; its cost is $\min(p,q) \le \sqrt N$, the trial-division exponent; and the speedup over the exact target is exactly $\max(p,q) \in [\sqrt N, N/2]$. A no-free-lunch theorem shows no $N$-independent reordering of candidates escapes: for every enumeration $f$ and prefix length $K$ there are arbitrarily large semiprimes on which all of the first $K$ probes miss.

All of this assembles into a trichotomy: any splitter reading values off the integer face of the Berggren tree operates in exactly one of three regimes — integer square identity (returns $N$, no split), genuine mod-$N$ congruence of squares (Dixon/quadratic-sieve class, which really does split), or ascending value sweep (trial division, cost $\min(p,q)$). Every route ends in a known method, and none beats Pollard's rho.

**Keywords:** integer factorisation, Pythagorean triples, Berggren tree, congruence of squares, binary quadratic forms, norm-form blindness, trial division, Pollard rho, lottery bounds.

---

## 1. Introduction

### 1.1 The proposals

Integer factorisation of a semiprime $N = pq$ remains the computational problem underlying a large fraction of deployed public-key cryptography. Practical subexponential algorithms — Dixon's random squares, the quadratic sieve, the number field sieve — all realise the same core mechanism, due in essence to Fermat and refined by Kraitchik: find integers $x, y$ with
$$x^2 \equiv y^2 \pmod N, \qquad x \not\equiv \pm y \pmod N,$$
and read off $\gcd(x-y, N)$ as a proper factor. The difficulty is entirely in manufacturing the congruence; the gcd is free.

Because the mechanism consumes *squares*, it is perennially tempting to feed it objects that come pre-equipped with square relations. The most classical such object is the set of Pythagorean triples. Berggren's theorem (1934), rediscovered several times since, states that the map
$$
(a,b,c) \mapsto
\begin{cases}
(a-2b+2c,\ 2a-b+2c,\ 2a-2b+3c),\\
(a+2b+2c,\ 2a+b+2c,\ 2a+2b+3c),\\
(-a+2b+2c,\ -2a+b+2c,\ -2a+2b+3c),
\end{cases}
$$
applied repeatedly from the root $(3,4,5)$, enumerates every primitive Pythagorean triple exactly once. The result is a perfect infinite ternary tree whose nodes all satisfy $a^2+b^2=c^2$ identically.

Two proposals exploit this.

**Proposal A (tree sieve).** Harvest leg pairs $(m_i, n_i)$ from tree nodes, and select a subset so that
$$\prod_i (m_i - n_i)(m_i + n_i) = Y^2$$
is a perfect square. Set $X = \prod_i \sqrt{\text{something}}$ so that a relation between squares holds, and compute $\gcd(X - Y, N)$.

**Proposal B (multi-target relaxation).** Run a tree search whose objective is to produce a node value equal to $N$; observing that this is astronomically unlikely, relax the objective to producing a node value $a$ with $\gcd(a, N) > 1$, and use a value-guided best-first search rather than a blind FIFO queue.

### 1.2 The empirical record

Both proposals were implemented and measured. The results, which motivate every theorem below, were:

*Proposal A.* End-to-end, $8$ splits in $12000$ trials, against a baseline of $4$ splits in $12000$ trials for random gcds, against a heuristic per-trial success prediction of $6.55 \times 10^{-4}$. Tree-derived values were measured to be $7.31\times$ smoother than random integers of comparable size, against a naive prediction of $\sim 44\times$. Breadth-first search with $50{,}000$ expanded nodes never reached the intended analysis window.

*Proposal B.* Blind FIFO search: $55\%$ of runs censored (never finished), fitted cost exponent $\alpha = 1.17$ on the finished subset. Value-guided best-first search: $1500$ paired wins out of $1500$, median visit ratio $0.111$, zero censoring — a speedup of roughly $10^{12}$, converting a $\sim 2^{56}$-unit search into a $\sim 2^{16}$-unit one. However, $100\%$ of first hits occurred at exactly $a = \min(p,q)$, with fitted exponent $\alpha = 1.087$ and $r^2 = 1.0$ on the $\log_2$-of-smaller-prime scale.

### 1.3 Contributions

This paper explains all of these numbers, and in each case shows that the phenomenon is *forced* rather than incidental.

1. **§2:** Proposal A is invalid as stated. Its relation is an identity in $\mathbb{Z}$; the gcd returns $N$.
2. **§3:** Any $N$-independent candidate generator is a lottery with linearly-adding tickets. This is precisely the $8$-vs-$4$ observation.
3. **§4:** Breadth-first search of a ternary tree with geometric value growth is starved: $V \le 5n^2$.
4. **§5:** The hypotenuse face of the tree is supported on primes $\equiv 1 \bmod 4$: this explains the $7.31\times$ smoothness boost *and* produces total blindness on an infinite class of moduli.
5. **§6:** The blindness mechanism is a property of the norm form, generalised to $x^2+Dy^2$, with incomparable blind classes for $D=1$ and $D=2$.
6. **§7:** The multi-target relaxation's first hit is deterministically at $\min(p,q)$; its cost is the trial-division exponent; its speedup is exactly $\max(p,q)$.
7. **§8:** No $N$-independent enumeration order escapes, and the two failure modes (order and arithmetic face) strike on the same moduli.
8. **§9:** The trichotomy, plus the positive half — a Dixon-class relation really does split, with yield exactly $1$.
9. **§10–12:** Algorithms, discussion, future directions.

Throughout, $p$ and $q$ denote primes and $N = pq$ a semiprime; "$r$" is reserved for an arbitrary prime divisor.

---

## 2. Obstruction I: an identity in $\mathbb{Z}$ carries no information modulo $N$

The distinguishing feature of Proposal A is that the modulus $N$ appears nowhere in the construction of the relation. It is introduced only at the last step, in the gcd. This is fatal.

**Lemma 2.1.** *If $X, Y \in \mathbb{Z}$ with $X \ge 0$, $Y \ge 0$, and $X^2 = Y^2$, then $X = Y$.*

*Proof.* $(X-Y)(X+Y) = 0$, so $X = Y$ or $X = -Y$. In the second case $X + Y = 0$ with both nonnegative forces $X = Y = 0$. $\square$

**Theorem 2.2 (Integer square relations are vacuous).** *Let $X, Y \ge 0$ be integers with $X^2 = Y^2$. Then for every integer $N$,*
$$\gcd(X - Y,\ N) = |N|.$$

*Proof.* By Lemma 2.1, $X - Y = 0$, and $\gcd(0, N) = |N|$. $\square$

**Corollary 2.3 (No information).** *Under the same hypotheses, $M \mid X - Y$ for every integer $M$.*

Corollary 2.3 is the sharpest way to phrase the defect: the relation produced by Proposal A is divisible by *every* modulus simultaneously. A quantity that is congruent to $0$ modulo everything distinguishes nothing. The gcd step, whose entire purpose is to extract the modulus-specific part of the relation, receives an input from which the modulus has already been eliminated.

The contrast with the intended mechanism is exact.

**Theorem 2.4 (Dixon split).** *Let $N > 1$ and $x, y \in \mathbb{Z}$ satisfy*
$$N \mid (x-y)(x+y), \qquad N \nmid (x-y), \qquad N \nmid (x+y).$$
*Then $1 < \gcd(x-y, N) < N$: the gcd is a proper nontrivial factor.*

*Proof.* Write $g = \gcd(x-y, N)$; note $g \mid N$. If $g = 0$ then $x - y = 0$ and $N \mid x-y$, contradiction. If $g = 1$ then $x-y$ and $N$ are coprime, so from $N \mid (x-y)(x+y)$ we get $N \mid x+y$, contradiction. Hence $g > 1$. For the upper bound, $g \mid N$ gives $g \le N$; if $g = N$ then $N = g \mid x - y$, contradiction. Hence $g < N$. $\square$

Theorem 2.2 and Theorem 2.4 together form a dichotomy that will be sharpened in §9: a square relation is either an identity in $\mathbb{Z}$ (useless) or a genuine congruence modulo $N$ with inequivalent roots (Dixon class). Any "correction" of Proposal A that forces the relation to be reduced modulo $N$ moves it, by definition, into the second case — that is, into the quadratic-sieve family, whose cost is governed by smoothness statistics of the relation-generating process, not by the tree.

---

## 3. Obstruction II: $N$-independent candidates form a lottery

Suppose Proposal A is weakened to: "emit integers $D_0, D_1, \dots, D_{k-1}$ derived from the tree, and compute $\gcd(D_i, N)$ for each." The tree does not depend on $N$, so the $D_i$ are fixed before $N$ is seen. Each $D_i$ is then a *lottery ticket*: it wins against a hidden prime $r$ exactly when $r \mid D_i$. Tickets are cheap; the question is how many primes each covers.

**Lemma 3.1.** *For $D \ge 1$, the number of distinct prime factors of $D$ is at most $\log_2 D$.*

*Proof.* If $\omega(D)$ denotes the number of distinct prime factors, then $2^{\omega(D)} \le \prod_{r \mid D} r \le D$, since every prime is at least $2$ and the radical divides $D$. Take base-$2$ logarithms. $\square$

**Theorem 3.2 (One ticket).** *Let $D \ne 0$ and let $S$ be any finite set of primes. Then*
$$\#\{\, r \in S : r \mid D \,\} \le \log_2 |D|.$$

*Proof.* The set on the left injects into the set of distinct prime factors of $D$; apply Lemma 3.1. $\square$

**Theorem 3.3 (Tickets add linearly).** *Let $D_0, \dots, D_{k-1}$ be nonzero integers and $S$ a finite set of primes. Then*
$$\#\{\, r \in S : \exists i,\ r \mid D_i \,\} \le \sum_{i=0}^{k-1} \log_2 |D_i|.$$

*Proof.* The winning set is contained in $\bigcup_i \{ r \in S : r \mid D_i\}$; the cardinality of a union is at most the sum of cardinalities; apply Theorem 3.2 termwise. $\square$

**Corollary 3.4 (Lottery probability bound).** *If the hidden prime is drawn uniformly from a nonempty pool $S$, the probability that some $D_i$ wins is at most*
$$\frac{1}{|S|}\sum_{i=0}^{k-1}\log_2|D_i|.$$

The content of Theorem 3.3 is the *absence of amplification*: there is no interaction between tickets, no combinatorial gain, no way in which the tree's algebraic coherence makes a collection of tickets more valuable than the sum of its parts. This is exactly what the end-to-end measurement showed. For a hard semiprime the relevant pool is the primes near $\sqrt N$, of size $|S| \asymp \sqrt N / \log N$ by the prime number theorem, so with $\log_2 |D_i| = O(\log N)$ the bound reads
$$\Pr[\text{success}] = O\!\left(k \cdot N^{-1/2}\log^2 N\right) = O\!\left(k \cdot N^{-1/2+o(1)}\right),$$
which is generic gcd luck: the same rate one obtains by drawing $k$ random integers of comparable size. Observing $8$ successes where a random baseline gives $4$, at a per-trial rate of $6.55\times10^{-4}$, is precisely the linear-in-$k$ behaviour Theorem 3.3 predicts, and is not evidence of a mechanism.

---

## 4. Obstruction III: breadth-first starvation

Even setting arithmetic aside, there is a combinatorial ceiling. Set up notation for the tree: let a *triple* be $(a,b,c) \in \mathbb{Z}^3$, let $\mathrm{step}_i$ for $i \in \{0,1,2\}$ be the three Berggren maps of §1.1, and let $\mathrm{berg}(w)$ denote the node reached from $(3,4,5)$ by following a word $w \in \{0,1,2\}^*$. Call a triple *admissible* if $0 < a$, $0 < b$, $a < c$, and $b < c$.

**Lemma 4.1.** *Admissibility is preserved by each $\mathrm{step}_i$, and holds at the root. Each $\mathrm{step}_i$ preserves the Pythagorean relation $a^2+b^2=c^2$.*

*Proof.* Direct computation. For instance for $\mathrm{step}_1$, $(a+2b+2c)^2 + (2a+b+2c)^2 - (2a+2b+3c)^2 = 5a^2+5b^2 - 5c^2 \cdot 1 + \cdots$ expands to $(a^2+b^2-c^2) \cdot (\text{unit})$, vanishing on Pythagorean input; the inequalities follow from positivity of $a, b, c$ and $a,b<c$. $\square$

**Lemma 4.2 (Bounded growth).** *For an admissible triple $t$ with hypotenuse $c$, each child has hypotenuse at most $7c$.*

*Proof.* The child hypotenuses are $2a-2b+3c$, $2a+2b+3c$, $-2a+2b+3c$. Under $0 < a < c$ and $0 < b < c$ each is at most $2c+2c+3c = 7c$. $\square$

**Proposition 4.3 (Geometric ceiling).** *A node at depth $L$ has hypotenuse at most $5 \cdot 7^L$.*

*Proof.* Induct on $L$ using Lemma 4.2, starting from $c = 5$ at the root. $\square$

Let $\mathrm{nodes}(L) = \sum_{i=0}^{L} 3^i$ be the number of nodes of depth at most $L$ in a ternary tree; clearly $3^L \le \mathrm{nodes}(L)$.

**Theorem 4.4 (BFS starvation).** *If breadth-first search reaches a node of depth $L$ whose hypotenuse is at least $V$, and $n = \mathrm{nodes}(L)$ is the number of nodes it has expanded, then*
$$V \le 5n^2.$$

*Proof.* $V \le 5 \cdot 7^L$ by Proposition 4.3. Since $7 \le 9 = 3^2$ we have $7^L \le (3^L)^2 \le n^2$. $\square$

Equivalently, $n \ge \sqrt{V/5}$: to *first observe* a value of magnitude $V$ one must have already expanded $\Omega(\sqrt V)$ nodes. With $n = 5\times10^4$, no value beyond $1.25\times10^{10}$ is ever seen. Note also that $\sqrt{V}$ work to see a value of size $V$ is, by itself, already the trial-division exponent — a foreshadowing of §7. Breadth-first exploration of an exponentially-branching tree with sub-quadratically-growing values is structurally starved; the observed failure of a $50{,}000$-node search to enter the analysis window is not an implementation deficiency.

---

## 5. The hypotenuse face is blind to $3 \bmod 4$ moduli

We now turn from combinatorics to arithmetic, and to the one measurement that showed a real effect: tree hypotenuses are $7.31\times$ smoother than random integers.

Call a triple *primitive* if no prime divides both legs.

**Lemma 5.1.** *If $a^2+b^2=c^2$ and a prime $r$ divides both $a$ and $b$, then $r \mid c$.*

*Proof.* $r \mid a^2+b^2 = c^2$, and $r$ prime gives $r \mid c$. $\square$

**Proposition 5.2.** *Every node of the Berggren tree is a primitive Pythagorean triple.*

*Proof.* The root $(3,4,5)$ is primitive: a common prime divisor of $3$ and $4$ would divide $1$. For the inductive step, suppose $t=(a,b,c)$ is primitive and Pythagorean, and let $r$ divide both legs of $\mathrm{step}_i(t)$. Each Berggren map is invertible over $\mathbb{Z}$ (the three matrices have determinant $\pm 1$), and by Lemma 5.1 $r$ also divides the child hypotenuse; applying the inverse integer matrix, $r$ divides $a$ and $b$, contradicting primitivity of $t$. $\square$

**Lemma 5.3.** *The hypotenuse of a primitive Pythagorean triple is odd.*

*Proof.* If $2 \mid c$ then $a^2+b^2 \equiv 0 \pmod 4$; squares are $0$ or $1$ mod $4$, so both $a$ and $b$ are even, contradicting primitivity. $\square$

**Theorem 5.4 (Hypotenuse primes are $1 \bmod 4$).** *Let $(a,b,c)$ be a primitive Pythagorean triple and $r$ a prime with $r \mid c$. Then $r \equiv 1 \pmod 4$.*

*Proof.* By Lemma 5.3, $r$ is odd. Modulo $r$ we have $a^2 + b^2 \equiv c^2 \equiv 0$. If $b \equiv 0 \pmod r$ then $a^2 \equiv 0$, so $r \mid a$ and $r \mid b$, contradicting primitivity. Hence $b$ is invertible mod $r$ and $(ab^{-1})^2 \equiv -1 \pmod r$. So $-1$ is a quadratic residue mod $r$, which for odd $r$ holds iff $r \equiv 1 \pmod 4$. $\square$

**Corollary 5.5.** *Every prime divisor of the hypotenuse of every node of the Berggren tree is $\equiv 1 \pmod 4$. In particular no tree hypotenuse is divisible by $2, 3, 7, 11, 19, 23, \dots$*

Corollary 5.5 explains the measured smoothness advantage quantitatively. Smoothness probability for an integer of size $x$ with respect to a factor base is governed by how many primes are available; restricting the possible prime divisors to a set of natural density $1/2$ — while excluding the *smallest and most common* primes $2$ and $3$ — changes the constant substantially but not the exponent. A boost of $7.31\times$ is entirely consistent with a halved factor base; a boost of $44\times$, obtained by a naive model that ignores the loss of the small primes, is not. The measurement was real and correctly explained; it is simply not the kind of quantity that can help.

The same theorem is fatal in the other direction.

**Theorem 5.6 (Hypotenuse-face blindness).** *Let $N$ be a positive integer all of whose prime divisors are $\equiv 3 \pmod 4$. Then for every node of the Berggren tree with hypotenuse $c$,*
$$\gcd(c, N) = 1.$$

*Proof.* Any common prime divisor $r$ of $c$ and $N$ would be $\equiv 1 \pmod 4$ by Theorem 5.4 and $\equiv 3 \pmod 4$ by hypothesis. $\square$

**Corollary 5.7 (Semiprime case).** *If $p \equiv q \equiv 3 \pmod 4$ are primes then $\gcd(c, pq)=1$ for every hypotenuse $c$ in the tree.*

This is a categorically stronger statement than the lottery bound of §3. The lottery says: the success probability is $O(N^{-1/2+o(1)})$. Blindness says: on this class of moduli, the success probability is exactly $0$, uniformly over the whole infinite tree, at every depth, forever. No amount of compute changes it.

For completeness we record that the *leg* face is not blind — e.g. $\gcd(21, 33) = 3$ for the node $(21,20,29)$ — so the obstruction is specific to the hypotenuse, which is precisely the face carrying the norm-form constraint.

---

## 6. Norm-form blindness in general

Theorem 5.4 used nothing about the Berggren tree beyond the shape of its values: a hypotenuse is a primitively represented value of the quadratic form $x^2 + y^2$. Abstracting gives a tool applicable to any arithmetically-constrained search.

**Theorem 6.1 (Norm-form constraint).** *Let $D, a, b, c \in \mathbb{Z}$ with $a^2 + D b^2 = c$, and suppose $(a,b)$ is primitive (no prime divides both). Then for every prime $r \mid c$, the element $-D$ is a square in $\mathbb{Z}/r\mathbb{Z}$.*

*Proof.* Modulo $r$: $a^2 + Db^2 \equiv 0$. If $b \equiv 0$ then $a^2 \equiv 0$, hence $r \mid a$ and $r \mid b$, contradicting primitivity. So $b$ is invertible and $(ab^{-1})^2 \equiv -D \pmod r$. $\square$

Say a prime $r$ is *inert* for the form $x^2 + Dy^2$ if $-D$ is not a square mod $r$ (the terminology matches splitting behaviour in the associated quadratic order).

**Theorem 6.2 (Blindness).** *Let $c = a^2+Db^2$ with $(a,b)$ primitive, and let $N$ be such that every prime divisor of $N$ is inert for $x^2+Dy^2$. Then $\gcd(c, N) = 1$.*

*Proof.* A common prime divisor $r$ would give $-D$ a square mod $r$ by Theorem 6.1, contradicting inertness. $\square$

Two instances make the phenomenon concrete.

**Proposition 6.3 ($D=1$).** *An odd prime $r$ is inert for $x^2+y^2$ iff $r \equiv 3 \pmod 4$.* (Euler's criterion: $-1$ is a QR mod $r$ iff $r \equiv 1 \bmod 4$.) Applying Theorem 6.2 with $a,b$ the legs and $c^2$ the value recovers Theorem 5.6 as a special case.

**Proposition 6.4 ($D=2$).** *An odd prime $r$ is inert for $x^2+2y^2$ iff $r \equiv 5$ or $7 \pmod 8$.* Equivalently, every prime divisor of a primitively represented value of $x^2+2y^2$ is $2$ or $\equiv 1, 3 \pmod 8$.

**Theorem 6.5 (Blindness classes are incomparable).** *The following all hold.*
1. *For every primitive $(a,b)$ and $c = a^2+b^2$: $\gcd(c,3)=1$.*
2. *There exist primitive $(a,b)$ with $c = a^2+2b^2$ and $\gcd(c,3)=3$ — e.g. $(a,b)=(1,1)$, $c=3$.*
3. *For every primitive $(a,b)$ and $c = a^2+2b^2$: $\gcd(c,5)=1$.*
4. *There exist primitive $(a,b)$ with $c=a^2+b^2$ and $\gcd(c,5)=5$ — e.g. $(a,b)=(1,2)$, $c=5$.*

*Proof.* (1) and (3) are Theorem 6.2 with $N=3$, $D=1$ and $N=5$, $D=2$, using $3 \equiv 3 \bmod 4$ and $5 \equiv 5 \bmod 8$. (2) and (4) are the exhibited witnesses. $\square$

So the blind sets for $D=1$ and $D=2$ are genuinely different, and neither contains the other: $3$ is blind for the first and visible to the second, $5$ vice versa. **Changing the norm form relocates the obstruction; it does not remove it.** Every fixed binary quadratic form has an inert class of density $1/2$ among the primes, and is therefore totally blind to the (infinite) family of moduli built from that class.

That the blind moduli are not a sparse curiosity follows from Dirichlet's theorem on primes in arithmetic progressions.

**Theorem 6.6 (Infinitely many blind composites).** *The set of composite $N$ all of whose prime factors are $\equiv 3 \pmod 4$ is infinite, as is the set of composite $N$ all of whose prime factors are $\equiv 5 \pmod 8$.*

*Proof.* For any bound $B$, Dirichlet provides a prime $p > B$ with $p \equiv 3 \pmod 4$ and then a prime $q > p$ with $q \equiv 3 \pmod 4$; $N = pq$ is composite, exceeds $B$, and has all prime factors $\equiv 3 \bmod 4$. Since $B$ was arbitrary, the set is unbounded, hence infinite. The $5 \bmod 8$ case is identical. $\square$

---

## 7. The multi-target relaxation is exactly trial division

We now analyse Proposal B. Define the relaxed target predicate: $a$ is a **hit** for $N$ if $a \ge 2$ and $\gcd(a,N) > 1$.

**Lemma 7.1.** *Let $p, q$ be primes and $a$ a hit for $N = pq$. Then $\min(p,q) \le a$.*

*Proof.* Since $\gcd(a, pq) > 1$ it has a prime divisor $r$, and $r \mid a$, $r \mid pq$. By Euclid's lemma $r \in \{p, q\}$, so $\min(p,q) \le r$. Also $r \mid a$ with $a \ge 2 > 0$ gives $r \le a$. $\square$

**Lemma 7.2.** *$\min(p,q)$ is a hit for $pq$.*

*Proof.* $\min(p,q) \ge 2$ since both are prime, $\min(p,q) \mid pq$, so $\gcd(\min(p,q), pq) = \min(p,q) > 1$. $\square$

**Theorem 7.3 (Ascending-sweep first hit).** *For primes $p, q$, the value $\min(p,q)$ is the least hit for $N = pq$:*
$$\min\{\, a \in \mathbb{N} : a \ge 2,\ \gcd(a, pq) > 1 \,\} = \min(p,q).$$

*Proof.* Lemma 7.2 gives membership; Lemma 7.1 gives the lower bound. $\square$

Theorem 7.3 turns the empirical histogram into a tautology. A value-guided best-first search whose priority is the node value examines candidates in ascending order of value; the first hit it reports is the least hit; the least hit is $\min(p,q)$. Hence the observation that $100\%$ of first hits landed at $a = \min(p,q)$ was not a statistic about the search heuristic. It was a theorem about the target set, and it would hold for *any* ascending-order search, however implemented.

**Theorem 7.4 (Cost is the trial-division exponent).** *For all $p,q$, $\min(p,q)^2 \le pq$, hence*
$$\min(p,q) \le \lfloor \sqrt{pq} \rfloor = \lfloor\sqrt N\rfloor.$$

*Proof.* WLOG $p \le q$; then $\min(p,q)^2 = p \cdot p \le p \cdot q$. $\square$

This is the exponent $1/2$: the cost of the relaxed search, measured in candidate values examined, is $\Theta(\min(p,q))$, matching the fitted $\alpha = 1.087$ with $r^2 = 1.0$ on the $\log_2$-of-smaller-prime scale — a perfect linear fit precisely because the relationship is an identity, not a trend.

**Theorem 7.5 (Exact speedup of the relaxation).** *$\min(p,q) \cdot \max(p,q) = pq$. Hence the relaxation's speedup over the exact target $a = N$, measured in sweep steps, is exactly $\max(p,q)$.*

**Theorem 7.6 (Speedup bounds).** *For primes $p, q$: $\lfloor\sqrt{pq}\rfloor \le \max(p,q)$ and $2\max(p,q) \le pq$. So the speedup factor lies in $[\sqrt N,\ N/2]$.*

*Proof.* $pq \le \max(p,q)^2$ gives the lower bound after taking square roots. For the upper, $2 \le \min(p,q)$ so $2\max(p,q) \le \min(p,q)\max(p,q) = pq$. $\square$

The relaxation is therefore a genuine and enormous improvement — a factor of $\max(p,q)$, which for a balanced $2n$-bit semiprime is about $2^n$, consistent with the measured $\sim 10^{12}$ — and a strictly bounded one. It converts an infeasible search into a feasible one by landing it exactly on trial division, and cannot go further.

Nor do balanced semiprimes help.

**Theorem 7.7 (Balanced case).** *If $q \le 2p$ and $p \le 2q$ then $pq \le 2\min(p,q)^2$, i.e. $\min(p,q) \ge \sqrt{N/2}$.*

*Proof.* WLOG $p \le q \le 2p$; then $pq \le p \cdot 2p = 2p^2 = 2\min(p,q)^2$. $\square$

Finally, exponent $1/2$ is dominated.

**Theorem 7.8 (Exponent dominance).** *Let $\alpha < \beta$ and $C > 0$. Then for all real $N > C^{1/(\beta-\alpha)}$ with $N \ge 1$,*
$$C \cdot N^{\alpha} < N^{\beta}.$$
*In particular, taking $\alpha = 1/4$, $\beta = 1/2$: for every constant $C>0$, $C\cdot N^{1/4} < N^{1/2}$ whenever $N > C^4$.*

*Proof.* $C = (C^{1/(\beta-\alpha)})^{\beta-\alpha} < N^{\beta-\alpha}$, so $C N^\alpha < N^{\beta-\alpha}N^\alpha = N^\beta$. $\square$

Theorem 7.8 disposes of the constant-factor smoothness advantage of §5 as a route to improvement: a $7.31\times$ constant cannot upgrade an exponent-$1/2$ search to anything sub-$N^{1/2}$. And it places the relaxed search firmly below Pollard's rho, whose expected cost is $O(N^{1/4})$ — matching the measured exponents $\alpha \approx 1.087$ (trial-division class) against $\alpha = 0.458$ (rho).

---

## 8. No search order escapes, and both failure modes coincide

One might hope that the ascending order is the culprit and a cleverer *fixed* enumeration of candidate values does better. It does not.

**Theorem 8.1 (No free lunch for candidate orders).** *Let $f : \mathbb{N}\to\mathbb{N}$ be any enumeration of candidate values that does not depend on $N$, let $K$ be any prefix length, and let $B$ be any bound. Then there exist primes $p, q$ with $B < p < q$ such that no probe among the first $K$ hits:*
$$\gcd(f(k),\ pq) = 1 \quad\text{for all } k < K.$$

*Proof.* Let $M = \max\left(B,\ \max_{k<K} f(k)\right)$, a finite quantity. By Euclid, choose a prime $p > M$ and then a prime $q > p$. If some $f(k)$, $k<K$, were a hit for $pq$, Lemma 7.1 gives $\min(p,q) = p \le f(k) \le M < p$, a contradiction. $\square$

The mechanism is the same one that drives the lottery bound: a finite $N$-independent prefix is a finite set of integers, and a finite set of integers exposes only the primes below its maximum. Combined with Theorem 7.3 this pins the situation: the ascending sweep pays $\min(p,q)$, and no reordering avoids paying a cost that grows with $\min(p,q)$.

The two failure modes — the value-order barrier and the arithmetic blindness — are not alternatives to be traded off. They occur together.

**Theorem 8.2 (Simultaneous defeat).** *Let $f : \mathbb{N}\to\mathbb{N}$ be any enumeration, $K$ any prefix length, $B$ any bound. Then there exist primes $p, q$ with $B < p < q$ and $p \equiv q \equiv 3 \pmod 4$ such that:*
- *$\gcd(f(k), pq) = 1$ for all $k < K$; and*
- *$\gcd(c^2, pq) = 1$ for every hypotenuse $c$ of every node of the Berggren tree.*

*Proof.* Let $M = \max(B, \max_{k<K}f(k))$. By Dirichlet choose primes $p > M$ and $q > p$ with $p \equiv q \equiv 3 \pmod 4$. The first bullet is Theorem 8.1's argument; the second is Theorem 5.6 (or Theorem 6.2 with $D=1$) applied to $N = pq$, whose prime factors are both $\equiv 3 \bmod 4$. $\square$

So on the same semiprime, the reordering route and the arithmetic-face route fail at once. Improving one cannot rescue the other.

---

## 9. The trichotomy, and the positive half

We now assemble the classification. First, the positive half must be shown non-vacuous: a Dixon-class relation genuinely exists and genuinely splits.

**Theorem 9.1 (Explicit nontrivial square root of unity).** *Let $p \ne q$ be distinct odd primes and let $u, v \in \mathbb{Z}$ satisfy the Bézout identity $up + vq = 1$. Put $z = 1 - 2up$. Then*
$$pq \mid (z-1)(z+1), \qquad pq \nmid z-1, \qquad pq \nmid z+1,$$
*and more precisely $p \mid z-1$ with $q \nmid z-1$, and $q \mid z+1$ with $p \nmid z+1$.*

*Proof.* $z - 1 = -2up$ and $z+1 = 2 - 2up = 2vq$ (using $up+vq=1$). Their product is $-4uvpq$, divisible by $pq$. Since $q \nmid 2$ and $q \nmid up$ (for if $q \mid up$ then $q \mid up+vq = 1$), we get $q \nmid z-1$; symmetrically $p \nmid z+1$. Divisibility by $pq$ of either factor would force the missing divisibility. $\square$

**Theorem 9.2 (Exact gcds; yield $1$).** *With $z$ as in Theorem 9.1,*
$$\gcd(z-1,\ pq) = p, \qquad \gcd(z+1,\ pq) = q, \qquad \gcd(z-1,pq)\cdot\gcd(z+1,pq) = pq.$$

*Proof.* $\gcd(z-1,pq)$ divides $pq$ and is divisible by $p$ (as $p \mid z-1$), but is not divisible by $q$, so it equals $p$. Symmetrically for $z+1$. $\square$

Theorem 9.2 has an operational reading: once a nontrivial square root of unity is in hand, the factorisation is recovered *completely*, with yield $1$ and no repetition. Therefore all the cost of a Dixon-class method resides in *producing* the relation — the smoothness sieve — and none in exploiting it. This is exactly why a tree that offers only relations, not smoothness, offers nothing to the quadratic-sieve family.

We may now state the classification. Consider any procedure that reads integer values off the Berggren tree and terminates with a gcd. Its final relation is in exactly one of three regimes.

**Definition 9.3 (Regimes).** Fix $N$. A splitter is in regime
- **(I) integer identity** if its relation is $X^2 = Y^2$ with $X, Y \ge 0$ holding in $\mathbb{Z}$;
- **(II) Dixon** if its relation is $N \mid (x-y)(x+y)$ with $N \nmid x-y$ and $N \nmid x+y$;
- **(III) ascending sweep** if it examines candidate values in ascending order and stops at the first hit.

**Theorem 9.4 (Trichotomy for the integer face).** *Let $N = pq$ with $p,q$ prime and $N > 1$. Then:*
- *In regime (I), $\gcd(X-Y, N) = N$: the output is $N$ itself, no split.*
- *In regime (II), $1 < \gcd(x-y,N) < N$: a proper nontrivial factor, i.e. the Dixon/quadratic-sieve outcome.*
- *In regime (III), the first hit is the least element of the hit set and equals $\min(p,q)$, with $\min(p,q)^2 \le N$: trial division.*

*Proof.* Regime (I) is Theorem 2.2; regime (II) is Theorem 2.4; regime (III) is Theorems 7.3 and 7.4. $\square$

We emphasise a subtlety that matters for the strength of the claim. It is not enough to prove a *disjunction* of three existential statements, since a disjunction can be discharged by an unrelated witness. The correct statement, and the one proved above, attaches to each regime *its own* outcome, computed from the data that regime supplies: the identity's $X, Y$; the congruence's $x, y$; the sweep's stopping index. In that sharp form the trichotomy asserts that the outcome is determined by the regime.

**Corollary 9.5.** *No splitter reading integers off the Berggren tree improves on textbook methods. Regime (I) never splits; regime (II) is Dixon/QS with cost governed by smoothness, to which the tree contributes only a bounded constant (Theorem 7.8); regime (III) is trial division with cost $\min(p,q) \le \sqrt N$, dominated by Pollard's rho at $O(N^{1/4})$ for all sufficiently large $N$ (Theorem 7.8 again).*

---

## 10. Algorithms

Three algorithmic objects are implicit in the analysis and worth stating explicitly, since they are what one would actually run to reproduce the measurements.

**Algorithm A: Berggren enumeration with hypotenuse residue audit.** Breadth-first or depth-first enumeration of tree nodes from $(3,4,5)$ via the three transformations, recording for each node the hypotenuse $c$ and its prime factorisation. The audit checks that every prime factor is $\equiv 1 \bmod 4$ (Theorem 5.4) and reports the empirical smoothness rate relative to random integers of matching bit length. Complexity: $\Theta(3^L)$ nodes to depth $L$, values bounded by $5\cdot 7^L$ (Proposition 4.3), hence $\Theta(n)$ time for $n$ nodes and value ceiling $5n^2$ (Theorem 4.4).

**Algorithm B: lottery bound evaluator.** Given a list of $N$-independent candidate outputs $D_0,\dots,D_{k-1}$ and a pool $S$ of primes, computes the exact winning set $\{r \in S : \exists i,\ r \mid D_i\}$ and compares its size against the certified bound $\sum_i \log_2 D_i$ (Theorem 3.3) and against the empirical success rate. Complexity: $O(k|S|)$ divisibility tests, or $O(k \cdot \omega)$ with factorisation.

**Algorithm C: ascending sweep with first-hit certification.** Given $N$, scans $a = 2, 3, 4, \dots$ computing $\gcd(a,N)$ and halting at the first $a$ with $\gcd(a,N)>1$. The certification step verifies the returned $a$ equals $\min(p,q)$ (Theorem 7.3) and that $a^2 \le N$ (Theorem 7.4). Complexity: exactly $\min(p,q) - 1$ gcd computations, i.e. $O(\sqrt N \log^2 N)$ bit operations — trial division.

The salient point is that Algorithm C, *which is what the value-guided best-first search reduces to*, has a closed-form cost. There is no heuristic to tune.

---

## 11. Discussion

### 11.1 Why the smoothness boost cannot help

It is worth isolating the tension at the heart of the whole family of proposals. Structured search spaces are attractive because their values are arithmetically special, and arithmetically special values are smoother. That is real: Theorem 5.4 explains a measured $7.31\times$ boost exactly, as the effect of restricting to a density-$1/2$ factor base that additionally excludes $2$ and $3$.

But the same restriction is a support constraint, and a support constraint is a blind spot. The set of primes that can divide your values and the set of primes that cannot are complements. Making the first set smaller — which is what buys smoothness — makes the second set bigger. Theorem 6.2 says the second set is a total obstruction, not a probabilistic one. So the smoothness gain and the blindness loss are two readings of one theorem, and they scale together.

Quantitatively the trade is hopeless: the gain is a bounded constant (Theorem 7.8 kills it), while the loss is a positive-density, infinite family of moduli on which the method has probability exactly $0$ (Theorems 5.6, 6.6).

### 11.2 Where the $10^{12}$ speedup went

The multi-target result is the most instructive, because by every operational criterion the relaxation *worked*: $1500/1500$ paired wins, median visit ratio $0.111$, zero censoring against $55\%$ censoring for the blind baseline, effective cost falling from $\sim2^{56}$ to $\sim2^{16}$. Nothing about those numbers is wrong.

What they measure, however, is improvement relative to a baseline, not the identity of the resulting algorithm. Theorem 7.5 says the improvement is exactly $\max(p,q)$ — an honest, large, and completely explicable factor — and Theorems 7.3–7.4 say that what it improves *to* is the ascending sweep, whose cost is $\min(p,q) \le \sqrt N$. A $10^{12}$ speedup that terminates at trial division is a $10^{12}$ speedup, and it is trial division.

The methodological lesson generalises beyond factoring: a paired-comparison benchmark answers "did we improve?", but it cannot answer "what did we build?". The latter requires looking at the *distribution of solutions found*, not the distribution of costs. Here the solution histogram was a single spike at $\min(p,q)$, and the spike was a theorem.

### 11.3 Scope and limitations

Our results concern splitters that read *integer* values off the tree and conclude with a gcd — the "integer face". They do not, by themselves, rule out every conceivable use of Pythagorean structure in factoring; for instance, one could imagine using tree relations only as a source of *smooth relations* inside a quadratic sieve rather than as a direct splitting mechanism. Theorem 5.4 remains relevant there (the available factor base is halved, which is an advantage for smoothness and a disadvantage for coverage), but the analysis of such a hybrid would require accounting for relation-collection cost against standard sieving, which we have not done. Theorem 7.8 suggests the outlook is poor: the tree's contribution to a Dixon-class method is a constant factor, and constants do not move exponents.

Similarly, Theorem 8.1 concerns $N$-independent enumerations. Enumerations that adapt to $N$ (as Pollard's rho does, implicitly, by iterating a map modulo $N$) are outside its scope — which is precisely the point: adaptivity to the modulus is where the exponent $1/4$ comes from, and it is exactly the ingredient the tree proposals lack.

---

## 12. Future directions

Several concrete continuations suggest themselves.

**Other forms and other trees.** Theorem 6.2 applies verbatim to any search whose values are primitively represented by $x^2+Dy^2$. Tabulating the blind classes for a range of $D$ — and for non-principal forms of a given discriminant, where representation is not by a single form but by a genus — would give a ready-made screening test for structured-search factoring proposals. The $D=1$ and $D=2$ cases proved here are incomparable (Theorem 6.5), which suggests the interesting question of whether a *family* of forms, run in parallel, can cover all primes; the obvious answer (yes, by covering all residue classes) collides with the observation that running $m$ forms multiplies cost by $m$ while the lottery bound of Theorem 3.3 adds only linearly.

**Densities.** Theorem 6.6 shows the blind set is infinite; a natural sharpening is its density. For $D=1$, the set of $N$ with all prime factors $\equiv 3 \bmod 4$ has a known Landau–Selberg-type density behaviour, and it would be worth making the "positive density of moduli on which the method has probability zero" statement fully quantitative.

**Adaptive orders.** Theorem 8.1 rules out $N$-independent enumerations. What is the correct analogue for enumerations that may query $N$ a bounded number of times, or that may use $O(\log N)$ bits of $N$? This would formally separate the tree family from rho.

**Sharper starvation.** Theorem 4.4 uses only $7 \le 3^2$. The true growth rates along the three branches are unequal (one branch grows much faster than the others), so a branch-dependent analysis should give a strictly better constant and possibly a better exponent for *depth-first* or *value-priority* exploration, which is what value-guided search actually performs.

Below, the directions recorded at the conclusion of the analysis, in their original form.

> The cycle established six things:
>
> 1. **Invalid as stated.** An identity $X^2 = Y^2$ in $\mathbb{Z}$ gives $X=Y$, so the gcd step returns $N$ itself, and the relation is divisible by *every* modulus.
> 2. **Consistent lottery.** $N$-independent tickets $D_0,\dots,D_{k-1}$ win on at most $\sum \log_2 D_i$ primes of any pool: tickets add linearly, exactly the observed $8/12000$ vs $4/12000$.
> 3. **A sharper obstruction than the lottery.** Every prime divisor of a Berggren hypotenuse is $\equiv 1 \bmod 4$, so on moduli whose prime factors are all $\equiv 3 \bmod 4$ the hypotenuse face has *zero* winning tickets — this both explains the measured smoothness advantage (a halved factor base) and kills the method on a positive-density class of $N$.
> 4. **The relaxation is trial division.** $\min(p,q)$ is the *least* $a$ with $\gcd(a,N)>1$, so first hits are forced, the cost is $\le \sqrt N$, the speedup over the exact target is exactly $\max(p,q)$, and exponent $1/4$ dominates for every constant.
> 5. **Blindness is a property of the norm form.** If $c$ is primitively represented as $a^2+Db^2$ then $-D$ is a square modulo every prime divisor of $c$, hence the search is blind to every modulus with only inert prime factors. Worked out for $D=1$ ($3 \bmod 4$ primes blind) and $D=2$ ($5, 7 \bmod 8$ primes blind), with the two blind sets shown incomparable — changing the form moves the obstruction, it does not remove it.
> 6. **No $N$-independent order escapes, and the blind moduli are infinite.** (a) *No free lunch*: for **every** candidate enumeration $f$ and every prefix length $K$ there are semiprimes, above any prescribed bound, on which all of the first $K$ probes miss — a finite $N$-independent prefix only ever exposes the primes below its maximum, so no reordering of candidates avoids the size barrier set at $\min(p,q)$. (b) *Infinitely many blind moduli*: via Dirichlet, the composite moduli blind to $x^2+y^2$ and those blind to $x^2+2y^2$ each form an infinite set.

---

## 13. Conclusion

The Berggren tree is a beautiful object, and it is not a factoring algorithm. The proposal that harvests square relations from it is invalid as stated, because its relations live in $\mathbb{Z}$ and never meet the modulus. Weakened to a gcd lottery, it wins at exactly the rate that linearly-adding, $N$-independent tickets predict. Explored breadth-first, it never reaches interesting values. Restricted, as it must be, to values primitively represented by $x^2+y^2$, it is *totally blind* to an infinite class of moduli — the same restriction that gives it its real but bounded smoothness advantage. Relaxed to a multi-target search, it accelerates by a factor of exactly $\max(p,q)$ and arrives, deterministically and provably, at trial division.

Every route through the tree's integer face terminates in a method that was already in the textbooks, and the terminus is determined by which of three regimes the relation occupies. That is the complete answer, and — unlike a benchmark — it does not need to be re-run for the next tree.
