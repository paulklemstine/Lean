# The Loneliest Numbers in Pascal's Triangle

### A guided tour of multiplicity, smoothness, and the Fibonacci machine

---

## 1. Warming up: how often does a number appear?

Write down Pascal's triangle. Every entry is the sum of the two above it, the border is all
$1$s, and the whole thing is left–right symmetric because $\binom{n}{k} = \binom{n}{n-k}$.

Now ask a question a child could ask: **pick a number — how many times does it appear?**

Every $t \ge 2$ appears at least twice, at $(t, 1)$ and $(t, t-1)$, since $\binom{t}{1} = t$.
The astonishing empirical fact is that almost every number appears *exactly* twice. Define

$$N(t) \;=\; \#\{(n,k) : 0 \le k \le n,\ \tbinom{n}{k} = t\}.$$

Then $N(3) = N(4) = N(5) = 2$, $N(6) = 3$, $N(10) = 4$, $N(120) = 6$, and — the champion —
$N(3003) = 8$. Nobody has ever found a number appearing five times, seven times, or nine or
more times. In 1971 David Singmaster asked whether $N$ is bounded at all. It is still open.

Try it yourself. Type a value into the explorer below and watch where it hides. Red cells are
left-interior occurrences, pink their mirror images, blue a central occurrence.

{{interactive_demo:0}}

> **Things to try.** Enter $6$, $20$, $70$, $252$ — all of them have multiplicity three, and all
> of them sit exactly in the middle of an even row. Enter $3003$ and count eight. Enter a large
> prime, or something like $2 \times 101 = 202$, and read the verdict: the smoothness test
> settles the multiplicity *without searching at all*.

---

## 2. Why the count is almost always even

Two structural facts organise the entire subject.

**The mirror.** $\binom{n}{k} = \binom{n}{n-k}$, so occurrences pair up — except those on the
central axis $n = 2k$.

**The trivial pair.** $(t,1)$ and $(t,t-1)$ are always there and always distinct.

<details>
<summary><strong>Click to reveal: the reflection decomposition and its proof</strong></summary>

Call an occurrence *left-interior* if $2 \le k$ and $2k < n$, and *central* if $n = 2k$ with
$k \ge 2$. Let $L(t)$ and $Z(t)$ count them. Then for $t \ge 3$,

$$N(t) = 2 + 2L(t) + Z(t), \qquad Z(t) \in \{0,1\}.$$

*Proof.* The boundary occurrences of $t \ge 3$ are exactly $(t,1)$ and $(t,t-1)$: they
contribute $2$. The mirror is a fixed-point-free involution between left- and right-interior
occurrences: they contribute $2L(t)$. Central occurrences are the fixed points of the mirror.
Finally $Z(t) \le 1$ because central binomial coefficients strictly increase:
$\binom{2c+2}{c+1} = \frac{2(2c+1)}{c+1}\binom{2c}{c} > \binom{2c}{c}$. $\blacksquare$

</details>

The consequence is startling in its simplicity:

> **$N(t)$ is even unless $t$ is a central binomial coefficient $\binom{2c}{c}$.**

That is why odd multiplicities are so rare. In fact, an exhaustive scan up to $10^7$ finds that
the numbers of odd multiplicity are *exactly*
$6, 20, 70, 252, 924, 3432, 12870, 48620, 184756, 705432, 2704156$ — the central binomial
coefficients — each with multiplicity exactly three.

It also turns the conjecture "$N(t) \ne 5, 7$" into a concrete Diophantine question: can a
central binomial coefficient $\binom{2c}{c}$ have two (or three) further non-central
representations?

---

## 3. Big primes are fatal: the smoothness theorem

Here is the first real theorem, and it comes from crossing two unrelated pieces of information.

**Geometry.** If $\binom{n}{k} = t$ with $2 \le k \le n-2$, then rows increase toward the middle,
so $\binom{n}{2} \le t$, i.e.
$$n(n-1) \le 2t.$$
Interior occurrences live in a tiny corner of the triangle: rows at most about $\sqrt{2t}$.

**Arithmetic.** $\binom{n}{k}$ divides $n!$, so every prime dividing it is at most $n$.

Combine them: if $p \mid t$ and $t$ has any interior occurrence, then $p \le n$ and hence
$p(p-1) \le n(n-1) \le 2t$.

> **Smoothness Theorem.** If $N(t) \ge 3$, then every prime factor $p$ of $t$ satisfies
> $p(p-1) \le 2t$, i.e. $p \le \sqrt{2t} + 1$.
>
> Equivalently: **any number with a prime factor bigger than about $\sqrt{2t}$ occurs exactly
> twice.**

That single criterion disposes of vast swathes of the integers at a glance: $N(cp) = 2$ for
every $c \ge 1$ and every prime $p > 2c+1$. In particular every divisibility class contains
infinitely many numbers of multiplicity exactly two.

The algorithm below converts a factorisation into an unconditional ceiling on the multiplicity —
and is honest about when the method gives nothing, which is precisely the case for the
interesting numbers.

{{algorithm:1}}

---

## 4. The hierarchy: more repetitions, smaller primes

The smoothness theorem is the first rung of a ladder. Push the counting harder.

<details>
<summary><strong>Click to reveal: from multiplicity to a deep column</strong></summary>

If $N(t) \ge 2m+2$, then by the reflection decomposition $L(t) \ge m$: there are at least $m$
left-interior occurrences. Distinct interior occurrences of the same value lie in distinct
columns (in a fixed column $k \ge 2$ the entries $\binom{n}{k}$ strictly increase with $n$, so a
value determines its row). Those $m$ distinct columns are all $\ge 2$; they cannot all lie in
$\{2,\dots,m\}$, a set of size $m-1$. So at least one occurrence has column $k \ge m+1$.

Now repeat the geometry-meets-arithmetic trick with $\binom{n}{m+1}$ in place of $\binom{n}{2}$:
$p \le n$ gives $\binom{p}{m+1} \le \binom{n}{m+1} \le \binom{n}{k} = t$.

</details>

> **Smoothness Hierarchy.** If $N(t) \ge 2m+2$, then every prime factor $p$ of $t$ satisfies
> $$\binom{p}{m+1} \le t, \qquad\text{hence}\qquad (p-m)^{m+1} \le (m+1)!\,t .$$

A number occurring six times is essentially $t^{1/3}$-smooth; occurring eight times, essentially
$t^{1/4}$-smooth. The visualization makes the ladder visible: each extra pair of occurrences
drags the admissible prime factors down by another root.

{{visualization:1}}

**Watch it bite on the champion.** $N(3003) = 8 = 2\cdot3+2$, so at $m = 3$ the hierarchy demands
$\binom{p}{4} \le 3003$ for every prime $p \mid 3003$. Since $\binom{18}{4} = 3060 > 3003$, no
prime factor can reach $18$. And indeed
$$3003 = 3 \cdot 7 \cdot 11 \cdot 13,$$
saturating the constraint. The champion of Pascal's triangle is exactly as smooth as it is
forced to be.

There is a matching lower bound on size: $N(t) \ge 2m+2$ forces $t \ge \binom{2m+3}{m+1}$.
Multiplicity is *expensive*.

---

## 5. How rare are the exceptions? Density zero

An interior occurrence with value $t \le X$ has $n \le \sqrt{2X}+1$ (row bound) and
$2^k \le t \le X$, so $k \le \log_2 X$. Every exceptional number is therefore a value of
$\binom{n}{k}$ on an explicit rectangle, and counting the rectangle gives:

> **Counting Bound.** $\#\{t \le X : N(t) \ge 3\} \le (\sqrt{2X}+2)(\log_2 X + 1)$.

Since $\sqrt X \log X = o(X)$, the numbers of multiplicity exactly two have **density one**.
Numerically: at $X = 10^6$ the bound gives $28{,}320$ against a true count of $1{,}732$; at
$X = 10^7$, $107{,}376$ against $5{,}125$.

{{visualization:0}}

There is also a *universal* bound, and here a free pigeonhole halves the classical constant.

<details>
<summary><strong>Click to reveal: halving the leading constant</strong></summary>

The classical elementary bound uses $2^b \le \binom{n}{b}$ to get $N(t) \le 2\log_2 t$. But the
smallest entry in folded column $b$ is $\binom{2b}{b} \approx 4^b/\sqrt b$, not $2^b$. Pigeonhole
on row $2b$ — its $2b+1$ entries sum to $4^b$ and none exceeds the central one — gives
$4^b \le (2b+1)\binom{2b}{b}$ at zero cost. Running the same argument yields

$$N(t) \le \log_2\big((2\log_2 t + 1)t\big) \le \log_2 t + \log_2(2\log_2 t + 1) + 1,$$

strictly better than $2\log_2 t$ from $t \ge 2^{16}$ on. At $t = 3003$: $16$ versus $22$; below
$10^6$: $25$ versus $38$.

</details>

---

## 6. Sharp thresholds: you must be big to repeat

The general bound $t \ge \binom{2m+3}{m+1}$ is not tight. The truth, for the first few
multiplicities, can be pinned down exactly.

> **Sharp Thresholds.** The smallest number occurring at least three times is $6$; at least four
> times, $10$; at least six times, $120$; at least eight times, $3003$.

<details>
<summary><strong>Click to reveal: why $120$ is forced (a two-parameter descent)</strong></summary>

Six occurrences force two left-interior occurrences $\binom{n}{j} = \binom{m}{k} = t$ in
*distinct* columns $2 \le j < k$.

- If $k \ge 4$: then $m \ge 2k+1 \ge 9$, so $t = \binom{m}{k} \ge \binom{9}{4} = 126 > 120$.
- If $k = 3$: then $j = 2$, so $t$ is simultaneously $\binom{m}{3}$ with $m \ge 7$ and a
  triangular number $\binom{n}{2}$. Below $120$ the only candidates are
  $\binom{7}{3} = 35$, $\binom{8}{3} = 56$, $\binom{9}{3} = 84$ — and none is triangular.

Hence $t \ge 120$; and $120 = \binom{16}{2} = \binom{10}{3}$ attains it. This is a structural
argument, not a search: only three residual numbers are decided by computation. The same descent,
one level deeper (three interior columns), yields $3003$.

</details>

Run the exhaustive record hunt yourself:

{{demo:1}}

---

## 7. The jewel: adjacent repetitions, completely classified

Where do the numbers with six occurrences come from? One prolific mechanism is an **adjacent
repetition** — a value that reappears one row higher and one column to the right:

$$\binom{n}{k} = \binom{n-1}{k+1}.$$

Because of the mirror, this yields four interior positions instead of two, plus the two border
copies: multiplicity at least six. The classic instance is
$$\binom{15}{5} = \binom{14}{6} = 3003,$$
which is exactly why $3003$ is the champion: it stacks an adjacent repetition on top of the
triangular coincidence $3003 = \binom{78}{2}$.

Singmaster noticed an infinite Fibonacci-indexed family of such repetitions. Are these *all* of
them? Yes — and the proof is a four-step chain that ends in one of the oldest identities about
Fibonacci numbers. Explore each step in the machine below.

{{interactive_demo:1}}

### Step 1 — clear the factorials

For $1 \le k$ and $k+2 \le n$,
$$\binom{n}{k} = \binom{n-1}{k+1} \iff n(k+1) = (n-k)(n-k-1).$$
A combinatorial coincidence has become a quadratic Diophantine equation. (Panel 2 of the machine
uses exactly this test — it never computes a binomial coefficient at all.)

### Step 2 — complete the square

Write $u = n-k$ for the gap. The substitution $N = 5n+1$, $U = 5u-3$ turns the equation into

$$N^2 - N U - U^2 = -5,$$

the norm form of $\mathbb{Z}[\varphi]$ with $\varphi = \tfrac{1+\sqrt5}{2}$ — the home field of
the golden ratio. Read more about
[norm forms and quadratic fields](https://en.wikipedia.org/wiki/Quadratic_field) if you want the
algebraic background.

### Step 3 — descend

<details>
<summary><strong>Click to reveal: the Vieta descent that classifies all solutions</strong></summary>

Consider $x^2 - xy - y^2 = \pm 5$ in natural numbers. The map $(x,y) \mapsto (y, x-y)$ satisfies
$$y^2 - y(x-y) - (x-y)^2 = -(x^2 - xy - y^2),$$
so it preserves solutions while *negating* the form. One checks $x \ne y$ (else $-y^2 = \pm 5$,
impossible since $5$ is not a square), and that $x > y$ for any solution above the base, so the
descent strictly decreases $x$ and must terminate. It bottoms out at $(1,2) = (L_1, L_0)$.

Reversing the descent reconstructs consecutive [Lucas
numbers](https://en.wikipedia.org/wiki/Lucas_number) $L_0, L_1, L_2, \dots = 2, 1, 3, 4, 7, 11,
18, 29, 47, 76, \dots$ Therefore **every** solution is a consecutive Lucas pair. A period-four
congruence mod $5$ then selects which indices are admissible.

</details>

The result is a complete classification in Lucas coordinates:

> For $1 \le k$ and $k+2 \le n$, the identity $\binom{n}{k} = \binom{n-1}{k+1}$ holds **iff**
> there is $j \ge 0$ with $5n+1 = L_{4j+9}$ and $5(n-k) = L_{4j+8}+3$.

Check $j = 0$: $L_9 = 76 = 5\cdot15+1$ and $L_8+3 = 50 = 5\cdot 10$, giving $(n,k) = (15,5)$.
Panel 3 of the machine lets you run the descent on any pair you like.

### Step 4 — the dictionary, powered by Cassini

The Lucas answer and Singmaster's Fibonacci answer must describe the same list, but proving it
needs a bridge between the two sequences:

$$L_{2a} = 5F_a^2 + 2(-1)^a, \qquad L_{2a+1} = 5F_aF_{a+1} + (-1)^a .$$

These are proved by a *single simultaneous induction*, and the inductive step is precisely
**Cassini's identity**

$$F_{a+1}^2 - F_a F_{a+2} = (-1)^a,$$

the 1680 observation that consecutive Fibonacci numbers miss being a perfect rectangle by exactly
one. It is the identity behind the
[missing square puzzle](https://en.wikipedia.org/wiki/Missing_square_puzzle), where an $8\times8$
square is cut up and reassembled into a $5\times13$ rectangle, apparently gaining a unit of area:
$8^2 = 64$, $5\cdot13 = 65$. Panel 4 of the machine lets you watch the sign $(-1)^a$ flip.

Feeding $a = 2i+4$ into the dictionary converts the Lucas certificate into the Fibonacci one:

> **Completeness of the Fibonacci Family.** For $1 \le k$ and $k+2 \le n$,
> $$\binom{n}{k} = \binom{n-1}{k+1} \iff (n,k) = \big(F_{2i+4}F_{2i+5},\ F_{2i+2}F_{2i+5}\big)
> \text{ for some } i \ge 0.$$

So the complete list of adjacent repetitions is
$$(15,5),\ (104,39),\ (714,272),\ (4895,1869),\ (33552,12815),\ \dots$$
and nothing else, ever. In particular $3003$ is the only value below one million produced this
way — the next one, $\binom{104}{39}$, already has $29$ digits.

The enumeration algorithm exploits completeness: instead of scanning rows, just iterate the
Fibonacci recursion.

{{algorithm:2}}

---

## 8. Putting it all together

The full numerical tour — multiplicities, smoothness certificates, bounds, the Fibonacci family,
the descent chains, and the anatomy of $3003$ — runs in one script:

{{demo:0}}

And here is the basic engine, the multiplicity computation with the row bound built in:

{{algorithm:0}}

---

## 9. What remains open

The assembled pieces sit tantalisingly close to Singmaster's conjecture.

- **The grand challenge.** High multiplicity forces extreme smoothness. A number built entirely
  out of primes below $t^{1/(m+1)}$ needs *many* prime factors — of order
  $\log t/\log\log t$ of them. Closing the gap between "too smooth to exist" and "exists" would
  deliver $N(t) \le 8$, with equality only at $t = 3003$.
- **Odd multiplicities.** Since $N(t)$ is even unless $t$ is a central binomial coefficient,
  ruling out $5$ and $7$ means showing that no $\binom{2c}{c}$ has two or three further
  non-central representations — a Diophantine problem of exactly the species that yielded
  completely to descent above.
- **Is $3003$ unique?** Is it the only number with multiplicity eight? It would have to be a
  triangular number *and* an adjacent repetition; the next adjacent repetition has $29$ digits.

Pascal's triangle is the friendliest object in mathematics: a child can build it. Ask it how
often a number appears, and it answers with quadratic fields, Fibonacci recursions, Cassini's
identity, and a question open since 1971.
