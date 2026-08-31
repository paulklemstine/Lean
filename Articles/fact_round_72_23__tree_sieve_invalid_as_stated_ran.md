# The Tree That Could Not Factor

## A beautiful idea, dismantled by six theorems

There is a particular kind of mathematical hope that recurs every few years. It goes like this: *factoring large numbers is hard, but here is a gorgeous piece of classical number theory that nobody has tried pointing at it yet. Surely something will fall out.*

The gorgeous piece of classical number theory in this story is the **Berggren tree**, and it really is gorgeous. In 1934, B. Berggren showed that every primitive Pythagorean triple — every triple of whole numbers $(a,b,c)$ with $a^2+b^2=c^2$ and no common factor, like $(3,4,5)$ or $(20,21,29)$ or $(119,120,169)$ — can be reached from $(3,4,5)$ by repeatedly applying exactly three linear transformations, and reached in exactly one way. The infinite family of Pythagorean triples, one of the oldest objects in mathematics, is a perfect infinite ternary tree.

Each node has three children, given by
$$(a,b,c) \mapsto (a\mp 2b+2c,\ \pm 2a-b+2c,\ \pm 2a-2b+3c)$$
in its three sign patterns, and from the root $(3,4,5)$ this generates every primitive triple exactly once. Nothing is lost, nothing is repeated: a bijection between an infinite ternary tree and one of antiquity's favourite sets of numbers.

So here is the tempting idea. Factoring a large number $N=pq$ — the problem that guards essentially every encrypted connection you will make today — traditionally proceeds by finding a **congruence of squares**: two numbers $x$ and $y$ with $x^2 \equiv y^2 \pmod N$ but $x \not\equiv \pm y$. Then $\gcd(x-y,N)$ is a genuine factor of $N$. Every serious factoring algorithm since the 1970s, from Dixon's random squares to the quadratic sieve to the number field sieve, is a machine for manufacturing such congruences.

And the Berggren tree is *full of squares*: every node satisfies $a^2+b^2=c^2$ on the nose, and the legs factor as $c^2 - a^2 = (c-a)(c+a)$. Harvest many nodes, multiply the differences of squares together so that the product is a perfect square $Y^2$, and you have a relation between squares built entirely out of Pythagorean structure. Take a gcd. Split $N$. Break the internet before lunch.

This article is about why that does not work — and about the fact that the *reason* it does not work turns out to be far more interesting than the proposal itself. Six precise theorems, taken together, do not merely say "we tried and failed". They say: **every road out of this idea leads back to a method we already had**, and they say exactly which method, and exactly why.

---

## Obstruction one: an identity is not a congruence

The first problem is the most elementary and the most fatal, and it is easy to miss because the proposal is written in suggestive notation.

The scheme produces a relation $X^2 = Y^2$. But look carefully at where that relation lives. The product $\prod_i (c_i-a_i)(c_i+a_i)$ is an ordinary product of ordinary integers. When we arrange for it to be a perfect square, we get an equation **in $\mathbb{Z}$** — not a congruence modulo $N$. And an identity in $\mathbb{Z}$ between nonnegative numbers is a very rigid thing:

> **Theorem (Integer identities are vacuous).** If $X, Y \ge 0$ are integers with $X^2 = Y^2$, then $X = Y$; consequently $\gcd(X-Y, N) = N$ for every $N$.

The proof is a single line: over the integers $X^2 = Y^2$ forces $X = \pm Y$, and nonnegativity kills the minus sign. So $X - Y = 0$, and $\gcd(0,N)=N$.

The gcd step, the whole point of the machine, returns $N$ itself. Not a factor: the number we started with. And it does so *no matter what $N$ is* — the relation is divisible by every modulus simultaneously, which is another way of saying it carries **zero bits of information** about $N$. The proposal never touches $N$ at any point before the final gcd. That is the tell.

A congruence of squares is useful precisely because the two roots are *different* integers that become equal only after reduction mod $N$. The gap between $x$ and $y$ is the information. An identity has no gap.

---

## Obstruction two: the lottery

The obvious repair is to say, "fine, we won't insist on a perfect square identity; we will just take whatever integer $D$ the tree hands us and compute $\gcd(D, N)$, hoping for luck." This is worth taking seriously, because it is what the implemented version of any such proposal actually does. And it is exactly a lottery — provably.

Here is the point. Because the tree does not depend on $N$, the numbers $D_0, D_1, \dots, D_{k-1}$ it emits are *fixed in advance*. A ticket $D_i$ wins against a hidden prime $p$ exactly when $p \mid D_i$. And an integer cannot have many prime divisors:

> **Theorem (One ticket).** A nonzero integer $D$ has at most $\log_2 D$ distinct prime factors. Hence, within any pool $S$ of candidate primes, the number of primes on which the single ticket $D$ wins is at most $\log_2 D$.

The proof is a two-line squeeze: if $D$ has $m$ distinct prime factors then $2^m \le \prod_{p \mid D} p \le D$.

> **Theorem (Tickets add linearly).** For $N$-independent outputs $D_0,\dots,D_{k-1}$, the number of primes in the pool on which *some* ticket wins is at most $\sum_{i} \log_2 D_i$. In probability form: if the hidden prime is drawn uniformly from a pool $S$, the success probability is at most $\left(\sum_i \log_2 D_i\right)/|S|$.

There is no amplification. No clever combination of tickets makes the union bigger than the sum. And with a pool of size $|S| \asymp \sqrt{N}/\log N$ — the primes up to $\sqrt N$, which is where the factors of a hard semiprime live — the success probability is $O(N^{-1/2+o(1)})$. That is exactly the "generic gcd luck" you would get by picking random integers and taking gcds with $N$: no tree required.

The experiments bear this out. Over 12000 trials the tree-based sieve produced 8 splits; a baseline of random gcds produced 4; the heuristic prediction from pure luck was $6.55\times10^{-4}$ per trial. Eight versus four is a factor of two on a lottery with a $10^{-3}$ payoff rate, which is exactly what "tickets add linearly" predicts when you buy twice as many tickets.

---

## Obstruction three: the tree grows too fast to be searched

Suppose you ignore all this and just want to *look* at the tree. Along any branch the hypotenuse grows by at most a factor of $7$ per step, so a node at depth $L$ has hypotenuse at most $5 \cdot 7^L$. But the tree is ternary, so reaching depth $L$ by breadth-first search means expanding at least $3^L$ nodes. Since $7 \le 9 = 3^2$:

> **Theorem (Breadth-first starvation).** If a breadth-first search has reached a node whose hypotenuse is at least $V$, then the number $n$ of nodes it has expanded satisfies $V \le 5n^2$.

You must expand about $\sqrt{V/5}$ nodes before you *first see* a value of size $V$. Concretely: with $50{,}000$ nodes expanded — a substantial search — no value beyond about $1.25 \times 10^{10}$ is ever encountered. For factoring problems of any interest the analysis window is never even entered. This was observed experimentally as "BFS starvation", and it is a theorem, not a tuning problem.

---

## The surprise: the tree is *arithmetically blind*

Now comes the part that turns a debunking into mathematics.

The experiments recorded something real and positive: hypotenuse values harvested from the tree are about $7.31$ times more likely to be smooth (to factor into small primes) than random integers of the same size. A naive prediction had said $\sim 44\times$; the measured value was much smaller but definitely nonzero. Where does a real-but-modest smoothness advantage come from?

The answer is a two-thousand-year-old fact about sums of two squares, and it is devastating.

> **Theorem (Hypotenuse primes are $1 \bmod 4$).** Every node of the Berggren tree is a *primitive* Pythagorean triple, and every prime divisor of the hypotenuse of a primitive Pythagorean triple is congruent to $1$ modulo $4$.

The reason: $c^2 = a^2 + b^2$ with $a,b$ coprime, so modulo any prime $r$ dividing $c$ we get $a^2 \equiv -b^2$, and $b$ is invertible mod $r$ (else $r$ would divide both legs). So $-1$ is a square mod $r$, which for odd $r$ happens exactly when $r \equiv 1 \pmod 4$.

That single fact explains **both** the good news and the bad news.

The good news: the effective factor base for tree hypotenuses is only *half* the primes. Hypotenuse values are never divisible by $2$, $3$, $7$, $11$, $19$, $23$, and so on forever. Restricting to a density-$1/2$ subset of the primes makes smoothness genuinely more likely — hence the measured $7.31\times$.

The bad news is much bigger. Take $N = pq$ where both $p$ and $q$ are $\equiv 3 \pmod 4$. Then:

> **Theorem (Blindness).** If every prime factor of $N$ is $\equiv 3 \pmod 4$, then $\gcd(c, N) = 1$ for *every* hypotenuse $c$ appearing anywhere in the infinite Berggren tree.

Not "rarely wins". Not "wins with probability $N^{-1/2}$". **Zero winning tickets, uniformly over the entire infinite tree.** By Dirichlet's theorem on primes in arithmetic progressions there are infinitely many primes $\equiv 3 \pmod 4$, so there are infinitely many such semiprimes, arbitrarily large — a positive-density class of moduli on which the method cannot possibly work, ever, at any depth.

And this is not a quirk of Pythagoras. The argument used nothing about the tree except the *shape* of the values it produces. Abstracting it:

> **Theorem (Norm-form blindness).** Let $D$ be an integer. If $c = a^2 + Db^2$ with $a, b$ sharing no common prime factor, then for every prime $r \mid c$, the element $-D$ is a square modulo $r$. Consequently, if every prime factor of $N$ is *inert* for the form — i.e. $-D$ is a non-square modulo it — then $\gcd(c, N) = 1$ for every primitively represented value $c$.

Any search whose values are constrained to be represented by a fixed quadratic form is blind to the primes that are inert for that form. Change the form and you move the blind spot; you do not remove it. For $x^2+y^2$ the blind primes are $3 \bmod 4$; for $x^2 + 2y^2$ they are $5$ and $7 \bmod 8$. And these classes are genuinely incomparable: $3$ is invisible to $x^2+y^2$ but visible to $x^2+2y^2$ (since $3 = 1^2 + 2\cdot 1^2$), while $5$ is invisible to $x^2+2y^2$ but visible to $x^2+y^2$ (since $5 = 1^2+2^2$). Every form has a blind class; no form escapes.

This is the deepest lesson in the whole affair. *Arithmetic structure is a double-edged sword.* The very constraint that makes tree values unusually smooth — that they live on a thin, well-behaved subvariety of the integers — is the constraint that makes them systematically unable to see half the primes. Structure buys you a smaller factor base; it charges you a blind spot of the same size. The two effects are the same theorem read in two directions.

---

## The relaxation: an enormous speedup that lands exactly on trial division

There is one more repair worth examining, because it *works* — and its success is the most instructive failure of all.

The idea: instead of demanding that the search hit the exact target $a = N$ (which is astronomically unlikely), relax the goal to "find any value $a \ge 2$ with $\gcd(a,N) > 1$". Call such an $a$ a **hit**. Now there are many targets rather than one. The experiments confirmed a spectacular improvement: a blind first-in-first-out search was hopeless — 55% of runs censored, an effective cost exponent that never finished — while a value-guided best-first search won all $1500$ of $1500$ paired trials, with a median visit ratio of $0.111$ and zero censoring. Measured against the exact-target formulation, the relaxation converts something requiring around $2^{56}$ units of work into something requiring around $2^{16}$: a factor of roughly $10^{12}$.

Then someone plotted the histogram of *where* the first hit occurred. It was a single spike. Every single time — $100\%$ of runs — the first hit was at $a = \min(p,q)$.

That is not an empirical accident. It is a theorem, and once you see it you cannot unsee it:

> **Theorem (Ascending-sweep first hit).** For a semiprime $N = pq$ with $p, q$ prime, the least $a \ge 2$ with $\gcd(a,N) > 1$ is exactly $\min(p,q)$.

Proof: $\min(p,q)$ divides $N$ and exceeds $1$, so it is a hit. Conversely, if $a$ is a hit then $\gcd(a,N)>1$ has a prime divisor $r$, which divides $N$, so $r \in \{p,q\}$, and $r \mid a$ with $a \ge 2$ gives $\min(p,q) \le r \le a$.

Any search that examines candidate values in ascending order therefore reports $\min(p,q)$ on its first success. Always. The observed histogram was a corollary waiting to be noticed. And now the cost follows immediately: $\min(p,q)^2 \le pq = N$, so

> **Theorem (The relaxation is trial division).** The ascending sweep's cost is $\min(p,q) \le \sqrt N$ — precisely the trial-division exponent $1/2$.

The fitted exponent from the experiments was $\alpha = 1.087$ with $r^2 = 1.0$ on a $\log_2$-of-the-smaller-prime scale — dead centre of the trial-division band, with a correlation coefficient of exactly one. The relaxed search is not *like* trial division. It *is* trial division, wearing a tree costume.

Even the size of the speedup is pinned exactly. Searching for the exact target costs $N$ sweep steps; the relaxed target costs $\min(p,q)$; the ratio is exactly $\max(p,q)$, which sits between $\sqrt N$ and $N/2$. An enormous win, and a strictly bounded one — bounded by the fact that you have arrived at trial division and can go no further. Even for perfectly balanced semiprimes (the two primes within a factor of $2$ of each other), the sweep still costs at least $\sqrt{N/2}$.

Could a cleverer ordering of the candidates help? No — and this is provable in a strong form:

> **Theorem (No free lunch for search orders).** Fix any enumeration $f : \mathbb{N} \to \mathbb{N}$ of candidate values that does not depend on $N$, any prefix length $K$, and any bound $B$. Then there exist primes $B < p < q$ such that all of the first $K$ probes miss: $\gcd(f(k), pq) = 1$ for every $k < K$.

The reason is embarrassingly simple, which is what makes it convincing: a finite prefix of an $N$-independent enumeration is a *finite set of integers*, and a finite set of integers only ever exposes the primes below its maximum. Choose both prime factors above that maximum and the whole prefix is dead. No reordering escapes the size barrier that the first-hit theorem sets at $\min(p,q)$.

Worse still, the two failure modes strike together. Given any enumeration order, any prefix length, and any bound, one can produce a single semiprime $pq$ with $p, q \equiv 3 \pmod 4$ above the bound on which *both* the entire prefix of the enumeration misses *and* the entire infinite Berggren hypotenuse face has gcd $1$. Trading one route for the other buys nothing.

---

## The trichotomy: every road is a road you have already walked

Everything above assembles into one statement, and it is the right way to remember the whole story. Consider any factoring procedure that reads integer values off the Berggren tree and finishes with a gcd. It falls into exactly one of three regimes:

1. **Integer square identity.** The relation $X^2 = Y^2$ holds in $\mathbb{Z}$. The gcd step returns $N$ itself. No split, ever.
2. **Genuine congruence of squares mod $N$.** The relation is $N \mid (x-y)(x+y)$ with $N \nmid x-y$ and $N \nmid x+y$. Then the gcd step *does* return a proper nontrivial factor — this is Dixon's method and the quadratic sieve, whose cost is governed entirely by smoothness statistics and not at all by the tree. (This half is not vacuous: for distinct odd primes $p \ne q$, writing $up + vq = 1$ by Bézout, the explicit value $z = 1 - 2up$ satisfies $z^2 \equiv 1 \pmod{pq}$ with $z \not\equiv \pm 1$, and $\gcd(z-1, N) = p$ while $\gcd(z+1,N) = q$ exactly. A structured root has yield $1$: all the cost of a Dixon-class method sits in *producing* the relation, none in exploiting it.)
3. **Ascending value sweep.** The first success occurs at $\min(p,q) \le \sqrt N$: trial division.

There is no fourth possibility, and none of the three beats a textbook method. Regime 1 is a no-op. Regime 2 is the quadratic sieve. Regime 3 is trial division. And trial division's exponent $1/2$ is dominated by Pollard's rho method at exponent $1/4$, no matter how good the constants: for any constant $C>0$, we have $C \cdot N^{1/4} < N^{1/2}$ as soon as $N > C^4$. That is the fate of the measured $7.31\times$ smoothness advantage — a constant factor cannot move an exponent. The relaxed search's fitted $\alpha \approx 1.087$ (trial-division class) sits against rho's $\alpha = 0.458$, and rho wins for all large $N$.

---

## What a negative result is worth

It would be easy to file this under "another factoring idea that didn't work". That undersells it. What the analysis produced is a *classification*: not that the tree sieve fails, but precisely where it fails, precisely how much of its apparent success was luck (all of it), precisely how much of its smoothness advantage was real (a factor of $7.31$, explained by a halved factor base), and precisely what the relaxation computes (the smaller prime factor, by ascending sweep). Each is a sharper statement than "it doesn't work", and each is reusable.

The norm-form blindness theorem in particular is a general tool, applying to *any* proposed factoring search whose candidate values are primitively represented by a fixed binary quadratic form — a large family, since arithmetic structure is exactly what makes such searches attractive. Before implementing, one now has a one-line test: identify the form, compute its inert primes, and check whether the target modulus is built from them. If it is, no amount of compute helps.

There is also a general moral about experimental mathematics. The multi-target relaxation looked, by every operational measure, like a triumph: a clean paired win, $1500$ out of $1500$, zero censoring, a twelve-orders-of-magnitude improvement over the baseline. Every one of those numbers is true. It was only when someone asked *where the successes were landing* that the picture inverted — and the answer, $100\%$ at $a=\min(p,q)$, was not a statistical observation at all but a two-line theorem that had been true from the start.

Benchmarks measure whether you improved. Theorems tell you what you built. It is entirely possible to improve enormously and to have built trial division.
