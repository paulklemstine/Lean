# The Loneliest Numbers in Pascal's Triangle

## A triangle full of strangers

Draw the first dozen rows of Pascal's triangle — each number the sum of the two above it — and stare at them for a while. The border is a wall of $1$s. Just inside it runs the sequence of counting numbers $1, 2, 3, 4, 5, \dots$, then the triangular numbers $1, 3, 6, 10, 15, \dots$, then the tetrahedral numbers, and so on. Every whole number $t \ge 2$ appears somewhere: it sits in position $(t, 1)$, since $\binom{t}{1} = t$, and again, mirrored, at $(t, t-1)$.

So every number appears **at least twice**. The astonishing empirical fact is that almost every number appears **exactly** twice.

Let $N(t)$ denote the *multiplicity* of $t$: the number of pairs $(n,k)$ with $0 \le k \le n$ and $\binom{n}{k} = t$. Then:

- $N(2) = 1$. The number $2$ is unique: its two "border" copies coincide, since $\binom{2}{1} = 2$ is the only place it ever occurs.
- $N(3) = N(4) = N(5) = 2$, and $N(p) = 2$ for every prime $p \ge 5$.
- $N(6) = 3$, because $6 = \binom{4}{2}$ sits exactly in the middle of row $4$, where its mirror image is itself.
- $N(10) = N(15) = N(21) = 4$: these numbers are both "triangular" and "linear", e.g. $10 = \binom{5}{2} = \binom{5}{3}$.
- $N(120) = N(210) = N(1540) = 6$, and infinitely many numbers have multiplicity at least $6$.
- $N(3003) = 8$ — and $3003$ is the only number ever found with eight occurrences.

Nobody has ever exhibited a number with multiplicity $5$ or $7$. Nobody has ever exhibited a number with multiplicity $9$ or more. In 1971 David Singmaster asked the obvious question and could not answer it: **is there an absolute upper bound on $N(t)$?** More than half a century later, the question is still open. The best anyone can prove unconditionally is that $N(t)$ grows no faster than roughly $\log t / \log\log t$; the truth is almost certainly that $N(t) \le 8$ always.

This article is about what *can* be proved. It turns out that a surprising amount of structure hides behind the mystery: a hidden reflection symmetry that forces multiplicities to be nearly even; a hierarchy of theorems saying that repetitive numbers must be built out of astonishingly small primes; a counting argument showing that the exceptional numbers are vanishingly rare; and — the most beautiful result of all — a **complete classification** of one important source of repetition, in which the Fibonacci numbers make an unannounced appearance and everything is glued together by a 340-year-old identity of Cassini.

## Why every number appears twice, and why the count is almost always even

Two structural facts organise everything.

**The mirror.** Pascal's triangle is left-right symmetric: $\binom{n}{k} = \binom{n}{n-k}$. So occurrences come in pairs, *except* for those sitting exactly on the central axis, where $n = 2k$.

**The trivial pair.** Every $t \ge 2$ occupies the positions $(t,1)$ and $(t,t-1)$, which are distinct.

Combining these, and calling an occurrence *left-interior* when it satisfies $2 \le k$ and $2k < n$ — that is, genuinely inside the triangle and strictly to the left of the axis — we get the **reflection decomposition**:

$$N(t) \;=\; 2 \;+\; 2\,L(t) \;+\; Z(t), \qquad Z(t) \in \{0,1\},$$

where $L(t)$ counts the left-interior occurrences and $Z(t)$ counts the central ones. That $Z(t) \le 1$ is because a value can sit on the central axis at most once: the central binomial coefficients $\binom{2c}{c}$ are strictly increasing in $c$.

Read that formula again: **multiplicity is even unless the number is a central binomial coefficient.** This is why the odd multiplicities are so scarce. $N(6) = 3$ because $6 = \binom{4}{2}$; $N(20) = 3$ because $20 = \binom{6}{3}$; $N(70) = 3$ because $70 = \binom{8}{4}$. If you want an odd multiplicity, you must be a central binomial coefficient, and there is only one of you per row. An exhaustive scan up to ten million bears this out with startling precision: the *only* numbers of odd multiplicity below $10^7$ are $6, 20, 70, 252, 924, 3432, 12870, 48620, 184756, 705432, 2704156$ — precisely the list $\binom{4}{2}, \binom{6}{3}, \binom{8}{4}, \dots$ of central binomial coefficients, each with multiplicity exactly three.

An immediate consequence: to get $N(t) = 5$, a number would have to be a central binomial coefficient *and* have exactly two other left-interior occurrences. To get $N(t) = 7$, three. No such number is known, and the conjecture that none exists is now a concrete Diophantine statement about equations of the form $\binom{2c}{c} = \binom{n}{k}$ with $k < c$.

## Big prime factors are fatal

Here is the first hard theorem, and it comes from crossing two utterly different pieces of information.

*Geometry.* Suppose $\binom{n}{k} = t$ with $2 \le k \le n-2$ — a genuinely interior occurrence. Rows of Pascal's triangle increase towards the middle, so $\binom{n}{2} \le \binom{n}{k} = t$, that is
$$n(n-1) \le 2t.$$
The row index of an interior occurrence is at most about $\sqrt{2t}$. Interior occurrences of a number are confined to a tiny corner of the triangle.

*Arithmetic.* Every binomial coefficient $\binom{n}{k}$ divides $n!$. Hence every prime dividing $\binom{n}{k}$ is at most $n$.

Put the two together. If $p$ is a prime factor of $t$ and $t$ has *any* interior occurrence, then $p \le n$ and therefore
$$p(p-1) \le n(n-1) \le 2t.$$

**Smoothness Theorem.** *If $N(t) \ge 3$ then every prime factor $p$ of $t$ satisfies $p(p-1) \le 2t$; equivalently $p \le \sqrt{2t} + 1$.*

Contrapositively: **any number with a prime factor larger than about $\sqrt{2t}$ occurs exactly twice.** This single criterion sweeps up enormous swathes of the integers. It instantly re-proves that every prime $p \ge 5$ occurs exactly twice; it shows that $2p$ occurs exactly twice for every prime $p \ge 7$ (though $2\cdot 3 = 6$ and $2 \cdot 5 = 10$ escape, with multiplicities $3$ and $4$); and more generally, for any fixed $c \ge 1$ and any prime $p > 2c+1$, the number $cp$ occurs exactly twice. Since there are infinitely many primes, **every divisibility class contains infinitely many numbers of multiplicity exactly two**: no matter what multiple of $17$, or of $10^{100}$, you demand, there are infinitely many of them that appear only twice.

## The hierarchy: more repetitions, smaller primes

The Smoothness Theorem is only the first rung of a ladder. Push the counting harder.

If $N(t) \ge 2m+2$, then the reflection decomposition forces at least $m$ left-interior occurrences. Distinct interior occurrences of the same value must lie in distinct columns (in a fixed column $k \ge 2$ the entries $\binom{n}{k}$ strictly increase with $n$, so a value determines its row). Those $m$ distinct columns are all at least $2$, so at least one of them is $\ge m+1$. Now repeat the geometry-meets-arithmetic trick, but with $\binom{n}{m+1}$ in place of $\binom{n}{2}$:

**Smoothness Hierarchy.** *If $N(t) \ge 2m+2$, then every prime factor $p$ of $t$ satisfies*
$$\binom{p}{m+1} \le t, \qquad\text{and quantitatively}\qquad (p-m)^{m+1} \le (m+1)!\,t.$$

So a number occurring six times is essentially $t^{1/3}$-smooth; a number occurring eight times is essentially $t^{1/4}$-smooth; and a number occurring $2m+2$ times has all its prime factors below roughly $((m+1)!\,t)^{1/(m+1)}$. **The more often a number repeats, the more it must be built out of tiny primes.**

Watch this bite on the champion. Since $N(3003) = 8 = 2\cdot 3 + 2$, the hierarchy at $m = 3$ says every prime factor $p$ of $3003$ obeys $\binom{p}{4} \le 3003$. Now $\binom{18}{4} = 3060 > 3003$, so no prime factor of $3003$ can be $18$ or larger. And indeed
$$3003 = 3 \cdot 7 \cdot 11 \cdot 13,$$
a product of four primes all under $18$, sitting right at the ceiling the theorem permits. The champion of Pascal's triangle is not a random number: it is exactly as smooth as it is forced to be.

The same counting gives a **growth threshold**: if $N(t) \ge 2m+2$, then $t \ge \binom{2m+3}{m+1}$. Multiplicity is expensive — you need to be big to afford it.

## How big must you be? The sharp thresholds

The general threshold $t \ge \binom{2m+3}{m+1}$ says $t \ge 126$ for eight occurrences. The truth is far larger, and it can be pinned down exactly.

**Sharp Thresholds.** *The smallest number occurring at least three times is $6$; at least four times, $10$; at least six times, $120$; at least eight times, $3003$.*

These are not brute-force verifications over a search range; they are consequences of the *shape* of the required occurrences. For example, six occurrences force two left-interior occurrences $\binom{n}{j} = \binom{m}{k} = t$ in distinct columns $2 \le j < k$. If $k \ge 4$ then, by unimodality along rows, $t \ge \binom{9}{4} = 126$. Otherwise $k = 3$ and $j = 2$, so $t$ must be simultaneously a tetrahedral-type number $\binom{m}{3}$ with $m \ge 7$ and a triangular number $\binom{n}{2}$. There are only three candidates below $120$ — namely $35$, $56$, $84$ — and none of them is triangular. Hence $t \ge 120$. Since $120 = \binom{10}{3} = \binom{16}{2}$ really does occur six times, $120$ is *least*. The same descent, one level deeper (three interior columns instead of two), yields $3003$.

## The exceptional numbers are vanishingly rare

Even without knowing whether $N$ is bounded, one can prove that the *typical* behaviour is settled.

An interior occurrence $\binom{n}{k} = t \le X$ has $n \le \sqrt{2X}+1$ (row bound, as above) and $2^k \le \binom{n}{k} = t \le X$, so $k \le \log_2 X$. Every $t \le X$ with $N(t) \ge 3$ is therefore a value of $\binom{n}{k}$ on an explicit rectangle of admissible $(n,k)$. Counting the rectangle:

**Counting Bound.** *The number of $t \le X$ with $N(t) \ge 3$ is at most $(\sqrt{2X}+2)(\log_2 X + 1)$.*

Since $\sqrt{X}\log X = o(X)$, the numbers of multiplicity exactly $2$ have **density one**: for every constant $c$, once $X$ is large enough, $c \cdot \#\{t \le X : N(t) \ge 3\} \le X$. Numerically the bound gives $28{,}320$ exceptional numbers below $10^6$; the true count is $1{,}732$. Being interesting in Pascal's triangle is a measure-zero occupation.

There is also a sharpened *universal* bound. The classical elementary estimate uses $2^k \le \binom{n}{k}$ to get $N(t) \le 2\log_2 t$. But $2^k$ is a wasteful lower bound: the smallest entry in column $k$ (once folded to the left half) is the central binomial coefficient $\binom{2k}{k} \approx 4^k/\sqrt{k}$. Pigeonhole on row $2k$ — the $2k+1$ entries sum to $4^k$ and none exceeds the central one — gives $4^k \le (2k+1)\binom{2k}{k}$ for free, and running the same argument yields

$$N(t) \;\le\; \log_2\!\big((2\log_2 t + 1)\,t\big) \;\le\; \log_2 t + \log_2(2\log_2 t + 1) + 1,$$

halving the leading constant. For $t = 3003$ the classical bound gives $22$ and this one gives $16$; below $10^6$ they give $38$ and $25$. It becomes strictly better than $2\log_2 t$ from $t \ge 2^{16}$ onwards.

## The Fibonacci mechanism — and a complete answer

Now for the jewel.

Where do the numbers with six occurrences come from? One prolific mechanism is an **adjacent repetition**: a value that reappears one row higher and one column to the right,
$$\binom{n}{k} = \binom{n-1}{k+1}.$$
Because of the mirror, such a coincidence produces *four* interior positions instead of two, plus the two border copies: multiplicity at least six. The classic example is
$$\binom{15}{5} = \binom{14}{6} = 3003,$$
which is exactly why $3003$ is the champion — it stacks an adjacent repetition on top of a triangular coincidence $3003 = \binom{78}{2}$.

Singmaster observed that adjacent repetitions come in an infinite Fibonacci-indexed family:
$$n = F_{2i+4}F_{2i+5}, \qquad k = F_{2i+2}F_{2i+5},$$
giving $(n,k) = (15,5), (104,39), (714,272), (4895, 1869), (33552, 12815), \dots$ — so there are infinitely many numbers of multiplicity at least six.

The natural question is whether these are *all* of them. The answer is yes, and here is the argument.

**Step 1: clear the factorials.** For $1 \le k$ and $k+2 \le n$,
$$\binom{n}{k} = \binom{n-1}{k+1} \iff n(k+1) = (n-k)(n-k-1).$$
The combinatorial coincidence is a quadratic Diophantine equation.

**Step 2: complete the square.** Write $u = n-k$ for the "gap". The substitution $N = 5n+1$, $U = 5u-3$ turns the equation into
$$N^2 - NU - U^2 = -5.$$
This is a norm-form equation for the quadratic field $\mathbb{Q}(\sqrt 5)$ — the home field of the golden ratio.

**Step 3: descend.** All natural-number solutions of $x^2 - xy - y^2 = \pm 5$ can be found by an unconditional Vieta-style descent $(x,y) \mapsto (y, x-y)$, which flips the sign of the form and strictly decreases the solution. The descent bottoms out at $(x,y) = (1,2) = (L_1, L_0)$. Therefore **every solution is a pair of consecutive Lucas numbers**
$$L_0, L_1, L_2, \dots = 2, 1, 3, 4, 7, 11, 18, 29, 47, 76, \dots$$
A period-four congruence modulo $5$ then selects which indices are admissible.

**Step 4: read off the classification.**

**Classification of Adjacent Repetitions (Lucas form).** *For $1 \le k$ and $k+2 \le n$, the identity $\binom{n}{k} = \binom{n-1}{k+1}$ holds if and only if there is an index $j$ with*
$$5n + 1 = L_{4j+9} \quad\text{and}\quad 5(n-k) = L_{4j+8} + 3.$$

Check $j = 0$: $L_9 = 76 = 5\cdot 15 + 1$ and $L_8 + 3 = 47 + 3 = 50 = 5 \cdot 10$, giving $(n,k) = (15,5)$. Check $j=1$: $L_{13} = 521 = 5 \cdot 104 + 1$, giving $(104, 39)$.

**Step 5: identify the two descriptions.** The Lucas answer and Singmaster's Fibonacci answer must be the same list — but proving it requires a dictionary between the two sequences:
$$L_{2a} = 5F_a^2 + 2(-1)^a, \qquad L_{2a+1} = 5F_aF_{a+1} + (-1)^a.$$
These two identities are proved by a single simultaneous induction whose inductive step is precisely **Cassini's identity**
$$F_{a+1}^2 - F_a F_{a+2} = (-1)^a,$$
the 1680 observation that consecutive Fibonacci numbers miss being a perfect rectangle by exactly one. (It is the identity behind the famous "missing square" dissection puzzle, where an $8\times 8$ square is cut and reassembled into a $5 \times 13$ rectangle, gaining a unit of area out of nowhere: $8^2 = 64$, $5 \cdot 13 = 65$.)

Feeding $a = 2i+4$ into the dictionary converts the Lucas certificate into the Fibonacci one, and we obtain:

**Completeness of the Fibonacci Family.** *For $1 \le k$ and $k+2 \le n$,*
$$\binom{n}{k} = \binom{n-1}{k+1} \iff (n,k) = \big(F_{2i+4}F_{2i+5},\; F_{2i+2}F_{2i+5}\big) \text{ for some } i \ge 0.$$

So the complete list of adjacent repetitions in Pascal's triangle is
$$(15,5),\ (104,39),\ (714,272),\ (4895,1869),\ (33552,12815),\ \dots$$
and nothing else, ever. In particular $(15,5)$ and $(104,39)$ are the only ones with $n \le 700$, and — a striking corollary — **$3003$ is the only value below one million produced by an adjacent repetition**: the next one, $\binom{104}{39}$, already has $29$ digits.

## What remains

The pieces now assembled look tantalisingly close to a proof of Singmaster's conjecture. On one side, high multiplicity forces extreme smoothness: $N(t) \ge 2m+2$ makes $t$ essentially $t^{1/(m+1)}$-smooth. On the other, a number built entirely out of primes below $t^{1/(m+1)}$ needs *many* prime factors — of order $\log t / \log\log t$ of them — and each of those factors imposes its own constraint. Closing the gap between "too smooth to exist" and "exists" is the remaining challenge, and it would deliver the conjectured bound $N(t) \le 8$ with equality only at $t = 3003$.

Meanwhile the odd multiplicities have been reduced to a single clean question. Since $N(t)$ is even unless $t$ is a central binomial coefficient, ruling out multiplicity $5$ and $7$ amounts to showing that no central binomial coefficient $\binom{2c}{c}$ has two (or three) further non-central representations. That is a Diophantine problem of exactly the same species as the adjacent-repetition equation — the one that yielded completely to descent and Lucas numbers. The template exists. Someone should run it.

Pascal's triangle is the friendliest object in mathematics: a child can build it. Yet ask it a simple question — *how often does a given number appear?* — and it answers with quadratic fields, Fibonacci recursions, Cassini's identity, and a conjecture that has stood since 1971. That is the joy of it. The triangle is infinite; the numbers in it are lonely; and $3003$, which manages to be a border number, a triangular number, a tetrahedral-adjacent number, and the smallest number ever to appear eight times, remains, so far as anyone knows, entirely alone at the top.
