# Three Numbers That Add to Nothing: How a Puzzle About Sums Meets the Wall That Protects Your Secrets

## A number that gives itself away

Take the number $143$. If you did not already know it, you would have to work a little to discover that $143 = 11 \times 13$. Now take three small numbers — $1$, $4$ and $6$ — and add them: $1 + 4 + 6 = 11$. Ask a computer for the greatest common divisor of $11$ and $143$, a computation so cheap it is essentially free, and out drops the answer: $11$. The secret factor of $143$ has been handed over by three numbers that had no obvious connection to it whatsoever.

That little trick is not luck, and it is not confined to $143$. It is a completely general phenomenon, and it sits at the heart of a surprising bridge between two problems that live in different neighbourhoods of mathematics: **3SUM**, the innocuous-looking question of whether three elements of a list add up to zero, and **integer factoring**, the problem whose difficulty guards most of the encrypted traffic on the planet.

This article is about that bridge — and about what one finds after crossing it, which is not a shortcut but a *wall*, and one that turns out to have two distinct heights depending on whether you demand certainty or are content with a coin flip.

## The reveal

Here is the general statement behind the $143$ trick.

> **Factor Reveal.** Let $N = pq$ be the product of two distinct primes and let $s$ be any whole number. Then $\gcd(s, N) = p$ **if and only if** $p$ divides $s$ and $q$ does not.

Read it in both directions, because both directions matter.

Left to right: producing *any* number that is a multiple of the hidden prime $p$ but not of the other hidden prime $q$ is exactly as good as factoring $N$. You never need to know $p$; you only need to stumble on a multiple of it. The greatest common divisor does the extraction for you.

Right to left: if the number you produce is a multiple of *both* $p$ and $q$, the gcd returns $N$ itself and you learn nothing. And if it is a multiple of neither, the gcd returns $1$ and you learn nothing. In fact the full picture is a clean four-way classification: for distinct primes $p, q$,
$$\gcd(s, pq) = \begin{cases} pq & \text{if } p \mid s \text{ and } q \mid s,\\ p & \text{if } p \mid s,\ q \nmid s,\\ q & \text{if } q \mid s,\ p \nmid s,\\ 1 & \text{otherwise.}\end{cases}$$
Only two of the four boxes are useful, and both of them are "hit exactly one of the primes".

Now specialise to sums of three numbers. If $a + b + c \equiv 0 \pmod p$ but $a + b + c \not\equiv 0 \pmod q$, then $\gcd(a+b+c, N) = p$. That is the **3SUM factor reveal**: *a 3SUM solution modulo a hidden prime factor exposes that factor.*

For $143$, one can check this exhaustively. Among all triples $1 \le a < b < c \le 11$, exactly $15$ have a sum divisible by $11$, and **not one** has a sum divisible by $143$. So every single one of those $15$ triples reveals the factor $11$ on the first gcd. The failure mode — hitting both primes at once — simply does not occur in that range, and that is not an accident either.

## Failure is rare, and we can count exactly how rare

How often does the reveal misfire? Only when the sum happens to be divisible by $q$ as well. Over one full period — the numbers $s$ with $0 < s \le N$ — the count is exact and beautiful:

> **Reveal Density.** Among $0 < s \le N = pq$, exactly $q$ values are divisible by $p$, and exactly $q - 1$ of those satisfy $\gcd(s, N) = p$. The single exception is $s = N$ itself.

So conditional on having found a multiple of $p$ at all, the reveal succeeds with probability $(q-1)/q$. For $N = 143$: thirteen multiples of $11$ in the range, twelve of which hand you the factor, and the one failure is $s = 143$. The "non-degeneracy condition" that mathematicians attach to this kind of statement — *provided the sum is not also divisible by $q$* — is thus not a hedge. It fails on a $1/q$ fraction of witnesses, which for cryptographic sizes is a probability with hundreds of zeros after the decimal point.

So we have a genuine mechanism. Find three numbers summing to zero modulo an unknown prime, and the prime is yours. The obvious next question is: **how hard is it to find them?**

## The birthday bound, dressed in three costumes

There is a folk observation in cryptanalysis that many factoring-adjacent attacks "all cost about $\sqrt{N}$", and that different attacks merely rearrange the same work. The 3SUM connection makes it possible to say precisely what that folklore means, and where it is right and where it is wrong.

Consider three styles of collision hunting over a set $S$ of $k$ numbers, each reduced modulo the hidden prime $p$:

- **Arity 1 — evaluations.** Look at the $k$ residues themselves and hope two coincide. (This is the shape of a singular-moduli search, or of Pollard's rho.)
- **Arity 2 — the sumset.** Look at all $\binom{k}{2}$ pairs and hope two pairs have the same sum: $a + b \equiv c + d$.
- **Arity 3 — 3SUM.** Look at all $\binom{k}{3}$ triples and hope for $a+b+c \equiv 0$.

Each style has a *search set* (how many numbers you must hold) and an *enumeration cost* (how many tuples you must actually examine). The seductive observation is that the search set shrinks dramatically as the arity grows: you need $k \gtrsim p$ residues, or only $k \gtrsim \sqrt{2p}$ numbers for pairs, or only $k \gtrsim (6p)^{1/3}$ for triples. The exponent improves from $1$ to $1/2$ to $1/3$. Surely something is being gained?

Here is the crisp answer, and it is a matching pair of bounds valid at *every* arity simultaneously.

> **Arity-Uniform Pigeonhole.** Fix a modulus $p$, a set $S$ of size $k$, and an arity $r$. An arity-$r$ collision search over $S$ is *guaranteed* to find two distinct $r$-subsets with equal value — against **every** possible way of evaluating subsets into residues mod $p$ — **if and only if** $\binom{k}{r} > p$.

The "if" half is the pigeonhole principle: more tuples than residue classes forces a repeat. The "only if" half is an adversary argument: if you enumerate at most $p$ tuples, one can always build an evaluation that assigns them all distinct residues, because there is room. So the threshold $p + 1$ is not an artefact of a crude estimate — it is exactly optimal.

The consequence is the punchline of the hierarchy:

> **The $\sqrt{N}$ Wall.** For a semiprime $N = pq$ with $q \le p$, any collision search that is guaranteed to succeed must enumerate more than $p \ge \sqrt{N}$ tuples — at every arity.

The arity changes the *packaging* of the work, never its amount. You can store fewer numbers by looking at higher-order combinations of them, but the number of combinations you must sift through is pinned at more than $p$, come what may. It is a conservation law for search.

A concrete table makes this vivid. Take $p = 100$. The smallest set size $k$ that guarantees a collision is $101$ at arity $1$, drops to $15$ at arity $2$, and drops again to $10$ at arity $3$. Spectacular compression of the search *set*: $101 \to 15 \to 10$. And the number of tuples enumerated? $101$, then $\binom{15}{2} = 105$, then $\binom{10}{3} = 120$. All just over $100$. The wall does not move.

There is even a structural reason the 3SUM row cannot secretly be cheaper than the sumset row: a 3SUM solution inside a set $S$ exists precisely when $-c$ lies in the sumset $S + S$ for some $c \in S$. In other words, the arity-$3$ search *is* an arity-$2$ table plus $k$ lookups. Nothing is hidden in the extra dimension.

And it is not just 3SUM. Pollard's classic $p-1$ method produces the number $a^k - 1$, which is divisible by $p$ whenever $p-1$ divides $k$; feed it to the same gcd and the same reveal fires. Sumset differences, 3SUM sums, $a^k - 1$, differences of singular moduli — these are four disguises of a single divisibility lemma, and they all cash out at the same counter.

## Closing the last loophole: it isn't about collisions

A sceptic can still object. All of the above concerns methods that work by *collision*. Maybe some cleverer algorithm produces its multiples of $p$ by a completely different route — algebraic, analytic, who knows — and slips past the pigeonhole.

That objection can be answered without assuming anything at all about the mechanism, by looking at the one interface every such method must use: the gcd itself. Model an algorithm as a finite list $Q$ of numbers it will offer up, each at most $M$, hoping one has a nontrivial gcd with $N$.

> **The gcd-Query Bound.** Suppose $Q$ succeeds on *every* semiprime built from two distinct primes drawn from a pool $P$. Then $|P| \le |Q| \cdot \log_2 M + 1$; equivalently, $|Q| \ge (|P| - 1)/\log_2 M$.

The proof is an ambush. Every query $x \le M$ has at most $\log_2 M$ distinct prime factors, simply because the product of $t$ distinct primes is at least $2^t$. So the whole query list *touches* at most $|Q| \log_2 M$ primes. If the pool $P$ is larger than that touched set by two, then two primes $p, q$ in the pool are untouched by every query — and for the semiprime $N = pq$ built from those two, every single gcd query returns $1$. The algorithm learns nothing at all.

Since the primes available to build a balanced semiprime $N$ number about $\sqrt{N}/\log\sqrt{N}$, this reproduces the $\sqrt{N}$ wall — unconditionally, with no pigeonhole hypothesis and no assumption about how the queries are cooked up. Concretely, with all queries below $2^{64}$, covering a pool of $n$ candidate primes needs at least $(n-1)/64$ queries. And the bound is not vacuous in the other direction: a single well-chosen query does solve an instance, which is precisely the point — the hard part is *finding* the number, never *testing* it.

## The wall has two heights

Now for the twist, and the reason this story is more interesting than a tidy confirmation of folklore.

Everything above concerns *guarantees*. But nobody factors numbers with a guarantee. Pollard's rho, the workhorse of small-factor extraction, is randomised: it finds a collision modulo $p$ after roughly $\sqrt{p}$ steps, not $p$ steps — the ordinary birthday paradox, the same reason $23$ people in a room probably share a birthday even though there are $365$ days. If the deterministic wall really were the whole story, rho could not exist.

So the deterministic $\sqrt{N}$ row of the hierarchy is *not tight for randomised search*, and the honest thing to do is prove where the randomised wall actually stands. That can be done by pure counting, with no probability theory at all.

Suppose you enumerate $m$ tuples and each is assigned a residue in $\{0, 1, \dots, p-1\}$. There are $p^m$ possible assignments in total. How many are collision-free — that is, injective? Exactly the falling factorial
$$p^{\underline{m}} = p(p-1)(p-2)\cdots(p-m+1),$$
since a collision-free assignment is precisely an injection of $m$ items into $p$ boxes. That is the exact count. From it one derives an integer form of the union bound,
$$p^{m+1} \;\le\; p \cdot p^{\underline{m}} \;+\; \binom{m}{2}\, p^{m},$$
which says in disguise that the collision probability among $m$ items in $p$ boxes is at most $\binom{m}{2}/p$ — one term for each pair that could collide. And from that:

> **The Randomised Barrier.** If $m^2 < p$, then strictly more than half of all $p^m$ assignments are collision-free: $p^m < 2\,p^{\underline{m}}$. Hence any collision search that succeeds with probability greater than $1/2$ must enumerate at least $\sqrt{p}$ tuples.

For a balanced semiprime $N = pq$ with $p \approx q \approx \sqrt{N}$, that threshold is $\sqrt{p} \approx N^{1/4}$ — two whole exponent steps below the deterministic wall, and exactly the running time of Pollard's rho. Both statements are *lower* bounds, not heuristics; and both are unconditional.

Numbers make the gap concrete. Take the prime $p = 10007$. A deterministic guarantee needs more than $10007$ tuples. But with only $m = 100 \approx \sqrt{p}$ tuples, one has $2\binom{100}{2} = 9900 < 10007$, so a majority of assignments are *still* collision-free — the randomised threshold genuinely sits near $100$, two orders of magnitude below $10007$. Below $\sqrt{p}$ you lose more often than you win; above it you start winning. The transition is sharp, and it is exactly where the birthday paradox says it should be.

So the corrected picture is a **two-level barrier**:

| Regime | Tuples needed | For a balanced $N = pq$ |
|---|---|---|
| Deterministic guarantee | more than $p$ | $\sqrt{N}$ |
| Randomised, success probability $> 1/2$ | at least $\sqrt{p}$ | $N^{1/4}$ |

Both rows hold at every arity. Whether you look at single residues, at pairs, or at triples, the cost is the same; only the size of the bag of numbers you carry around changes.

## Why this is worth knowing

Three things deserve emphasis.

**First, a bridge.** 3SUM is a fixture of fine-grained complexity theory — the conjecture that it needs essentially quadratic time is the hardness assumption behind dozens of geometric and combinatorial lower bounds. Factoring is a fixture of cryptography. The reveal lemma links them at the level of *mechanism*: a 3SUM solution modulo a hidden prime is a factoring witness. That suggests a genuinely two-way research programme, one direction transferring 3SUM hardness into a lower bound for restricted factoring algorithms, the other asking whether a subquadratic 3SUM algorithm would say anything about factoring over structured sets.

**Second, a correction.** It is tempting — and it has been tempting — to summarise all of this as "everything costs $\sqrt{N}$". That is false as stated, and the falsehood matters: it would rule out Pollard's rho, which manifestly works. The right statement separates the deterministic guarantee from the randomised threshold, and both halves can be proved. A hierarchy table is only as good as the quantifiers hiding in its column headings.

**Third, a warning about improved exponents.** The arity story is a model of a very common trap. Going from pairs to triples genuinely improves an exponent — from $p^{1/2}$ to $p^{1/3}$ — and that improvement is real. But it is an improvement in the wrong quantity. The exponent lives in the size of the generating set; the cost lives in the number of tuples, and there the exponent never budges. Any claimed speedup should be checked against the question: *which* quantity did the exponent improve?

None of this is a factoring breakthrough, and it is not meant to be. It is something arguably more useful: a precise account of why a whole family of appealing ideas cannot be one — together with the exact place, at $N^{1/4}$ rather than $\sqrt{N}$, where the ground actually gives way.
