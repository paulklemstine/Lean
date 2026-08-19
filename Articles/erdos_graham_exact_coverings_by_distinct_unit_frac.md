# One, Cut Into Pieces: The Strange Combinatorics of Egyptian Fractions

## A four-thousand-year-old way of writing numbers

The scribes of ancient Egypt had a peculiar habit: they wrote fractions as sums of *distinct unit fractions* — reciprocals of whole numbers, each used at most once. Where we write $\tfrac{3}{4}$, they wrote $\tfrac{1}{2}+\tfrac{1}{4}$; where we write $\tfrac{2}{7}$, they wrote $\tfrac{1}{4}+\tfrac{1}{28}$.

The habit outlived the empire. Today an **Egyptian representation of $1$** means a finite set $S$ of integers, all at least $2$, all different, with

$$\sum_{n \in S} \frac{1}{n} = 1 .$$

The smallest one is famous:

$$1 = \frac{1}{2} + \frac{1}{3} + \frac{1}{6}.$$

Call such a set an *exact covering*. It is an oddly rigid object: you cannot nudge a denominator without destroying the identity, repeat one, or use $1$ itself. And yet exact coverings are extraordinarily abundant — they exist with every possible number of terms from three upward, they can avoid all small denominators, they can avoid all prime powers. Whether they are abundant enough to survive being *shattered by a colouring* is one of the loveliest questions in combinatorics.

## The Erdős–Graham question

Paul Erdős and Ronald Graham asked, in the 1970s, a question of a kind that has become the signature of Ramsey theory: *can structure survive an adversary?*

> **The Erdős–Graham problem.** Suppose you paint each integer $n \ge 2$ with one of $r$ colours, in any way you like. Must there always be a single colour class containing a finite set $S$ with $\sum_{n\in S} 1/n = 1$?

The adversary picks the colouring; you have to find the monochromatic exact covering. With one colour the answer is trivially yes: $\{2,3,6\}$ is there, whatever you do. With two colours it is already far from obvious. Erdős and Graham conjectured that the answer is yes for every finite number of colours, and Ernest Croot proved it in 2003 with a difficult analytic argument built on smooth numbers and the circle method.

This article is about the *combinatorial skeleton* underneath: what exact coverings look like, why the easy approaches fail, and exactly where the difficulty lives. The story turns out to have a satisfying shape, with two independent obstructions, a bridge to a classical corner of number theory, and — at the end — a reduction of the whole infinite problem to a finite search.

## How small can an exact covering be?

Start with the humblest question. How few unit fractions can add to $1$?

One is impossible: $1/n = 1$ forces $n = 1$, which is not allowed. Two is impossible too, and the reason is a one-line estimate. If $a < b$ are both at least $2$, then $a \ge 2$ and $b \ge 3$, so

$$\frac{1}{a} + \frac{1}{b} \le \frac{1}{2} + \frac{1}{3} = \frac{5}{6} < 1 .$$

So **every exact covering has at least three terms**. And with exactly three terms there is precisely one possibility.

> **Uniqueness of the smallest covering.** If $\{a,b,c\}$ is a set of three distinct integers $\ge 2$ with $1/a + 1/b + 1/c = 1$, then $\{a,b,c\} = \{2,3,6\}$.

The proof is a pleasant squeeze. Order them $a < b < c$. Then $1 = 1/a + 1/b + 1/c < 3/a$, so $a < 3$, forcing $a = 2$. Now $1/b + 1/c = 1/2$ and $1/2 < 2/b$, so $b < 4$; since $b > a = 2$ we get $b = 3$. Finally $1/c = 1/2 - 1/3 = 1/6$, so $c = 6$. Every step is forced.

So the world of exact coverings begins with a single point. What happens next is the opposite of rigidity.

## The splitting move: from one covering, infinitely many

There is an identity that anyone who has met Egyptian fractions eventually notices:

$$\frac{1}{m} = \frac{1}{m+1} + \frac{1}{m(m+1)} .$$

(Check: $\frac{1}{m+1} + \frac{1}{m(m+1)} = \frac{m+1}{m(m+1)} = \frac{1}{m}$.) It is a machine for manufacturing new coverings out of old ones.

> **The splitting operator.** Let $S$ be an exact covering and let $m$ be its *largest* element. Then
> $$T = \bigl(S \setminus \{m\}\bigr) \cup \{\, m+1,\; m(m+1) \,\}$$
> is again an exact covering, it has exactly one more element than $S$, and its largest element is $m(m+1)$.

Why does the "largest element" hypothesis matter? Because the two new denominators, $m+1$ and $m(m+1)$, must not already be in $S$ — otherwise we would be repeating a fraction, and the sum would no longer be a sum over a *set*. Taking $m$ maximal guarantees both new numbers exceed everything present. The bookkeeping is exact: we delete one element and insert two, so the size goes up by one, and the sum is unchanged because we replaced $1/m$ by two fractions with the same total.

Iterating from $\{2,3,6\}$:

$$\{2,3,6\} \to \{2,3,7,42\} \to \{2,3,7,43,1806\} \to \cdots$$

with sizes $3, 4, 5, \dots$. Combined with the impossibility of one or two terms, this pins down the answer completely.

> **The cardinality spectrum.** There exists an exact covering with exactly $k$ terms if and only if $k \ge 3$.

The spectrum $\{3,4,5,6,\dots\}$ is *tight at both ends of the argument*: the lower bound comes from an inequality, the upper unboundedness from an algebraic identity. Nothing is left over.

There is also a pretty two-sided bound relating the size of a covering to the numbers inside it.

> **Bracketing.** Every exact covering $S$ contains an element $n \le |S|$ and an element $n' \ge |S|$.

Both halves come from one averaging idea. If $m$ is the smallest element, then $1 = \sum 1/n \le |S|/m$, so $m \le |S|$; if $M$ is the largest, then $1 \ge |S|/M$, so $M \ge |S|$. You can push all denominators above $10$ — but only at the cost of having at least eleven of them.

## Step one of every known attack: some colour is heavy

Now return to the colouring problem. What is the *first* thing anybody tries?

The harmonic series diverges: $\sum_{n\ge2} 1/n = \infty$. If we split the integers into $r$ colour classes, the total mass $\infty$ has to go somewhere, so at least one class must itself carry infinite reciprocal mass. Made precise:

> **The pigeonhole step.** For every colouring of the integers $\ge 2$ with $r$ colours, some colour class $C$ has *divergent reciprocals*: for every bound $M$ there is a finite $F \subseteq C$ with $\sum_{n \in F} 1/n > M$.

The proof needs no analysis at all, only a clean rational inequality. Group the integers into dyadic blocks $(2^k, 2^{k+1}]$. Each block has $2^k$ members, each at least $1/2^{k+1}$, so each block contributes at least $2^k \cdot 2^{-(k+1)} = 1/2$. Summing $k$ blocks:

$$\sum_{n=2}^{2^{k}} \frac{1}{n} \;\ge\; \frac{k}{2}.$$

That single inequality — provable by induction, entirely inside the rational numbers — is all the divergence we need. If every colour class had reciprocal sums bounded by some $M_i$, any finite set would have reciprocal sum at most $M_1 + \cdots + M_r$, contradicting the unbounded dyadic sums.

So: **some colour class is reciprocally huge.** Surely a huge class must contain an exact covering?

## Why step one can never be step two

It cannot. And the reason is one of the most elegant parts of the story.

Consider the set of all prime numbers. By Euler's theorem $\sum_p 1/p$ diverges — the primes are reciprocally huge. Yet:

> **No finite set of distinct primes has reciprocal sum $1$.**

Why? Suppose $S$ is a set of distinct primes with $\sum_{p \in S} 1/p = 1$, and let $q$ be its largest member. The term $1/q$ contributes a factor $q$ in the denominator that nothing else can cancel — every other term $1/p$ has denominator coprime to $q$. So the left side, in lowest terms, has $q$ in its denominator, while the right side is the integer $1$. Contradiction.

That argument has a sharp general form, the arithmetic heart of the subject.

> **The local obstruction.** Let $S$ be an exact covering, $p$ a prime, and suppose some $m \in S$ is divisible by $p$. Then there is a *different* element $n \in S$ whose $p$-adic valuation is at least that of $m$:
> $$v_p(n) \ge v_p(m), \qquad n \in S,\ n \ne m .$$

In words: **the largest power of $p$ appearing among the denominators is never attained by a single denominator.** It must be attained at least twice.

The mechanism is the *ultrametric inequality* for the $p$-adic valuation: $v_p(x+y) \ge \min(v_p(x), v_p(y))$, with equality whenever the two valuations differ. If $m$ were the unique element realising the maximal power $p^e$ ($e \ge 1$), then among the terms $1/n$ the value $v_p(1/n) = -v_p(n)$ would attain its strict minimum $-e$ exactly once. Strictness of the minimum makes the ultrametric inequality an equality, so the whole sum would have valuation $-e < 0$. But the sum is $1$, and $v_p(1) = 0$. Contradiction.

Two immediate and charming corollaries:

- **An exact covering never contains exactly one multiple of a given prime $p$.** Divisibility comes in company.
- In particular, **an exact covering never contains exactly one even number.** Look at $\{2,3,6\}$: the evens are $2$ and $6$ — two of them, as required.

And now the general Egyptian-freeness criterion. Call a set $A$ of integers **$p$-adically separated** if for every prime $p$, two distinct members of $A$ never share the same *positive* $p$-adic valuation.

> **The separation criterion.** A $p$-adically separated set contains no exact covering at all.

Pairwise coprime sets are $p$-adically separated (if $p$ divided two of them it would divide their gcd), and so are the prime powers (a prime power $p^e$ has positive valuation only at $p$, and two distinct powers of $p$ have different exponents). Hence:

> **The primes are covering-free. The prime powers are covering-free. Any pairwise coprime family is covering-free.**

Which delivers the punchline:

> **Divergence does not suffice.** There is a set of integers $\ge 2$ whose reciprocal sum diverges and which contains no exact covering — namely, the primes.

The pigeonhole step, on its own, can *never* prove the Erdős–Graham conjecture. Any successful proof must inject genuinely arithmetic information about the colour class, not merely its size. This is not a soft remark: it is a theorem about the limits of a proof strategy.

## A second obstruction, of a completely different kind

The $p$-adic obstruction is *local*: it looks at one prime at a time. There is a second, *global* obstruction, and it comes from a classical corner of number theory.

Call a positive integer $N$ **pseudoperfect** (or semiperfect) if some set of *distinct proper divisors* of $N$ sums to $N$. For example $6 = 1 + 2 + 3$, and $12 = 6 + 4 + 2$. There is a perfect dictionary between these and our subject:

> **The divisor duality.** For $N > 0$: $N$ is pseudoperfect **if and only if** some exact covering consists entirely of divisors of $N$.

The bijection is divisor complementation $d \mapsto N/d$. If $D$ is a set of distinct proper divisors with $\sum_{d \in D} d = N$, divide by $N$: $\sum_{d\in D} \frac{d}{N} = 1$, i.e. $\sum_{d \in D} \frac{1}{N/d} = 1$. The numbers $N/d$ are distinct divisors of $N$, and they are all $\ge 2$ precisely because each $d$ was a *proper* divisor. The converse runs backwards along the same map.

This dictionary pays immediately in both directions.

- **Every perfect number gives a covering.** $6$ is perfect, its proper divisors $1,2,3$ summing to $6$; dually $1 = \frac16 + \frac13 + \frac12$. From $28 = 1+2+4+7+14$ we get $1 = \frac{1}{28} + \frac{1}{14} + \frac17 + \frac14 + \frac12$.
- **Running the other way:** the least common multiple of any exact covering is pseudoperfect.
- **Deficient numbers are barren.** Call $N$ *deficient* if its proper divisors sum to less than $N$. Then the divisors of $N$ that are $\ge 2$ form a covering-free set, for the crudest of reasons: there is not enough mass. This is a *global* obstruction — it counts total weight and knows nothing about individual primes. Since every prime power is deficient, we recover the prime-power result by a second, independent route.

So we have two mechanisms preventing exact coverings: **too separated** (local, $p$-adic) and **too light** (global, mass). Is that the whole story?

## The number 70 says no

No. And the counterexample is a single, celebrated integer.

$70$ is **weird**: it is *abundant* (its proper divisors $1,2,5,7,10,14,35$ sum to $74 > 70$, so there is plenty of mass) but *not pseudoperfect* (no sub-collection of those divisors sums to exactly $70$ — you may check all $2^7$ possibilities). Under the duality, this says the divisors of $70$ that are $\ge 2$ contain no exact covering.

And they are certainly not $p$-adically separated: $2$ and $10$ are both divisors, and both have $2$-adic valuation exactly $1$.

> **Neither obstruction is complete.** There exists a covering-free set of integers $\ge 2$ that is *not* $p$-adically separated and *not* mass-deficient — the divisors of $70$.

So a third mechanism exists, and "weirdness" is its name. This is where the frontier of the combinatorial picture currently sits.

## Coverings can dodge almost anything

Lest the obstructions suggest that exact coverings are fragile, here are two that dodge the natural traps.

**Avoiding all prime powers.** The $21$-element set

$$\{6, 10, 12, 14, 15, 18, 20, 21, 22, 24, 28, 30, 33, 36, 40, 42, 44, 45, 55, 60, 63\}$$

has reciprocal sum exactly $1$, and not one of its members is a prime power — every one has at least two distinct prime factors. (All divide $27720 = 2^3\cdot3^2\cdot5\cdot7\cdot11$, which is why the arithmetic works out cleanly.) So the prime-power obstruction is sharp: prime powers are covering-free, but their *complement* certainly is not.

**Avoiding all small denominators.** The $23$-element set

$$\{10, 11, 12, 14, 15, 16, 18, 20, 21, 22, 24, 28, 30, 33, 36, 40, 42, 45, 48, 55, 60, 63, 66\}$$

has reciprocal sum exactly $1$ with every denominator at least $10$. No finite collection of small denominators is indispensable.

Each of these yields an unconditional case of the two-colour conjecture, with no analysis whatsoever:

> If a $2$-colouring gives colour $0$ only to prime powers, then colour $1$ contains an exact covering. If a $2$-colouring gives colour $0$ only to numbers below $10$, then colour $1$ contains an exact covering.

The adversary who hoards the prime powers, or the small numbers, has hoarded the wrong things.

## Squeezing infinity into a box

The Erdős–Graham statement quantifies over colourings of an *infinite* set, which makes it look hopeless for a computer. It isn't. There is a finitisation.

Say the **finite property** $\mathrm{EG}(r, N)$ holds if *every* $r$-colouring of the integers $\ge 2$ admits a monochromatic exact covering using denominators all at most $N$. This is obviously monotone in $N$, and obviously implies the full statement.

> **Finitisation.** For every $r$: the Erdős–Graham property for $r$ colours holds **if and only if** $\mathrm{EG}(r,N)$ holds for some $N$.

The forward direction is the interesting one, and the naive approach fails instructively. Suppose no $N$ works. Then for each $N$ there is a bad colouring $g_N$: no monochromatic covering with all denominators $\le N$. We would like to take a limit colouring, but "just take $g_N$ for large $N$" is nonsense — *different candidate coverings need different $N$'s*, and no single $g_N$ is bad for all of them.

The fix is a *limit along an ultrafilter*. For each integer $n$, the values $g_1(n), g_2(n), \dots$ live in the finite set of $r$ colours, so one colour occurs "almost always" in the sense of a fixed non-principal ultrafilter on the levels $N$; define $c(n)$ to be that colour. Since $c$ is an honest colouring, the Erdős–Graham property hands us a monochromatic covering $S$ for $c$. Now two "almost all" conditions intersect: almost all levels agree with $c$ on the finitely many members of $S$, and almost all satisfy $N \ge \max S$. Any level in the intersection gives a $g_N$ for which $S$ is a monochromatic covering with all elements $\le N$ — contradicting badness. Finiteness of the palette is what makes the diagonalisation possible; the ultrafilter is what makes it uniform across all candidate sets at once.

The catch — and it is a real one — is that this argument is **effective in structure but not in size**. It proves that a bound $N(r)$ exists whenever the conjecture holds for $r$ colours, but produces no value for it. For one colour we know the answer exactly: $\mathrm{EG}(1,6)$ holds, witnessed by $1 = \frac12+\frac13+\frac16$, and $6$ cannot be lowered because $\{2,3,6\}$ is the unique three-term covering and every covering has at least three terms.

For two colours, the value is unknown — and it is not small. A direct search produces explicit two-colourings that beat every bound up to at least $55$. Here is one: colour red the numbers

$$3, 4, 6, 7, 8, 10, 11, 14, 17, 20, 21, 24, 25, 27, 29, 31, 32, 33, 34, 37, 41, 45, 46, 47, 49, 50, 52$$

and blue the rest of $\{2,3,\dots,55\}$. Neither class contains a subset whose reciprocals sum to $1$ — an exact, exhaustive check, confirmed by two independent search methods. What makes this colouring so striking is the *mass*: the red class has reciprocal sum about $1.889$ and the blue class about $1.704$. Each has nearly twice the material it needs, and still cannot assemble a clean $1$. This is the phenomenon of the weird number $70$, writ large: enough weight, no exact decomposition.

So the least valid two-colour bound exceeds $55$. But the finitisation converts an infinitary conjecture into a finite, in-principle-decidable statement — and thereby makes the two-colour case of Erdős–Graham a legitimate target for a structured computer search, rather than an object of pure contemplation.

## What the picture looks like now

The **easy half** of the problem is completely understood. Exact coverings exist with every cardinality from three upward and only from three upward; the unique minimal one is $\{2,3,6\}$; each covering brackets its own size; the splitting identity generates the whole ladder; and pigeonhole always hands you a reciprocally divergent colour class.

The **hard half** is understood in the sense of knowing why it is hard. Divergence provably does not suffice — the primes prove it. Two independent obstructions block exact coverings, one local and $p$-adic, one global and mass-theoretic. And $70$ shows that even together they do not exhaust the phenomenon: weirdness is a third mechanism, and nobody knows whether there is a fourth. Meanwhile the infinite-to-finite bridge means the whole question, for any fixed number of colours, is a finite statement in disguise.

What Erdős and Graham noticed, and Croot proved, is that unit fractions are resilient: no matter how an adversary partitions the integers, one part always contains a perfect decomposition of $1$. The combinatorial anatomy behind that resilience — where it comes from, and precisely where the easy arguments run out — is what makes the problem worth returning to. Four thousand years after the scribes, the number $1$ still has secrets in how it comes apart.
