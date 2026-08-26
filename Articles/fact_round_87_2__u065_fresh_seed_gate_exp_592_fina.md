# The Dial That Only Turns One Way

## How a failed replication led to a theorem about what divisibility can — and cannot — tell you

There is a particular kind of scientific disappointment that turns out to be the
most productive thing that can happen to you.

A pattern had been reported. Sift a large population of integers by simple
divisibility rules — is this number even? is it divisible by $3$? by $5$? by $7$? —
sort them into the resulting sixteen boxes, and something interesting seemed to
happen. Two things, in fact. First, the boxes had noticeably different
*occupancy rates*: some collected members roughly twice as fast as others.
Second — and this was the exciting part — the numbers in some boxes appeared to
prefer certain *positions* within the range being scanned. Divisibility, the
report suggested, was not just a rate dial but a position dial: it seemed to
nudge where things landed, not merely how many landed.

That second claim rested on a single run of data. So the whole apparatus was
rebuilt from scratch on a completely fresh, independently generated population
and run again, identically.

The signal was gone.

Not weakened — gone, and instructively so. The size of the effect measured on
the fresh data, $0.074 \pm 0.038$, was *smaller than the measured bias of the
measurement procedure itself*, $0.140 \pm 0.048$. In other words, a procedure
fed pure noise would typically report a *larger* effect than the one observed.
On the calibrated scale — effect minus the procedure's own baseline — the two
runs bracketed zero from opposite sides: $+1.53$ standard deviations the first
time, $-1.08$ the second. That is the fingerprint of a statistic that was
selected for being the largest of many, not of a real mechanism.

Meanwhile, the *first* effect — the differing occupancy rates — replicated
almost perfectly. The busiest box and the emptiest box were the same boxes both
times, and the spread between them matched to about two percent: $0.649$ to
$1.432$ on the second run against $0.645$ to $1.406$ on the first.

So the slogan survived in halves. **Divisibility is a rate dial, not a position
dial.** The rate half was solid. The position half had been an illusion.

What follows is the story of what happened next: instead of collecting more
data, we proved the slogan.

---

## Cells, periods, and one very clean count

Fix a finite set $P$ of distinct primes — say $P = \{2,3,5,7\}$. To each integer
$v$ attach its *divisibility signature*: the list of yes/no answers to "does $p$
divide $v$?" as $p$ runs over $P$. Two integers with the same signature belong to
the same **cell**. There are $2^{|P|}$ cells, sixteen in our example. The
signature repeats with period
$$L \;=\; \prod_{p \in P} p,$$
which is $2 \cdot 3 \cdot 5 \cdot 7 = 210$ here, because divisibility by each $p$
depends only on $v$ modulo $p$.

Now count. How many of the $210$ residues carry a given signature? Write
$\sigma(p) = \texttt{true}$ if the signature demands $p \mid v$ and
$\texttt{false}$ if it forbids it. The answer is the completely factorised
quantity
$$\kappa(\sigma) \;=\; \prod_{p \in P} \begin{cases} 1 & \sigma(p) = \texttt{true},\\ p-1 & \sigma(p) = \texttt{false}.\end{cases}$$

**The Rate Law.** *For every finite set $P$ of distinct primes and every
signature $\sigma$, exactly $\kappa(\sigma)$ of the $L$ residues modulo
$L = \prod_{p\in P} p$ lie in the cell of $\sigma$.*

The reason is the Chinese Remainder Theorem, applied one prime at a time. Modulo
$p$ there is exactly one residue divisible by $p$ (namely $0$) and exactly $p-1$
that are not; the constraints at distinct primes are independent, so the counts
multiply. For $P = \{2,3,5,7\}$ this gives the whole table at a glance:

| signature (primes required to divide) | $\kappa$ |
| --- | --- |
| none — all cleared | $1\cdot 2\cdot 4\cdot 6 = 48$ |
| $\{2\}$ | $1\cdot 2\cdot 4\cdot 6 = 48$ |
| $\{7\}$ | $1\cdot2\cdot4\cdot1 = 8$ |
| $\{2,3,5\}$ | $1\cdot1\cdot1\cdot6 = 6$ |
| $\{2,3,5,7\}$ | $1$ |

Two features leap out, and both are theorems.

The all-cleared cell is exactly the set of integers coprime to $L$, so its rate
is Euler's totient $\varphi(L) = 48$. That is the top of the dial. The
all-dividing cell contains only the multiples of $L$ itself: rate $1$. That is
the bottom. Every other cell sits strictly in between, so **the full spread of
the dial is exactly the factor $\varphi(L)$**, with both extremes attained — and
attained *only* by those two signatures, up to one exception.

The exception is the second feature: rows one and two of the table are equal.
Requiring divisibility by $2$ costs nothing, because $2 - 1 = 1$. **The prime
$2$ is a dead coordinate of the dial**: flipping the parity requirement never
changes the rate of any cell. All the modulation is carried by the odd primes.
This innocuous-looking remark will come back with teeth.

One more piece of bookkeeping, a sanity check that everything is accounted for:
summing $\kappa$ over all $2^{|P|}$ signatures returns exactly $L$, because
$\prod_p \big(1 + (p-1)\big) = \prod_p p$. The cells tile a period, with no
remainder.

---

## The other half: positions

So much for rates. What about position?

Slide a window of length $L$ anywhere along the integers — start it at $0$, at
$L$, at $17L$, wherever, so long as its left edge is a multiple of $L$. Because
the signature of $v$ depends only on $v \bmod L$, the window sees exactly the
same $\kappa(\sigma)$ members of the cell every single time.

**Exact Positional Flatness.** *Every period block contains exactly the same
number of cell members: the profile in the block index has zero drift, not small
drift.* Consequently, counting over $m$ whole periods gives exactly
$m \cdot \kappa(\sigma)$, and the ratio of two cells' counts is the same number
$\kappa(\sigma)/\kappa(\tau)$ no matter how many periods you observe. The law is
*scale-carrying*: it transfers unchanged from short windows to long ones, from
small numbers to large ones.

That already kills a positional mechanism at the resolution of period blocks.
But the reported effect had been measured at a finer resolution, and a sceptic
could reasonably ask: what if the signal hides *inside* a period, at some scale
the block-counting argument cannot see?

It cannot. Here is the sharp form.

**The Coprime-Statistic No-Go Theorem.** *Let $P$ be a finite set of distinct
primes with period $L$, let $\sigma$ be any signature, and let $M$ be any modulus
coprime to $L$. Let $Q$ be **any** property of integers whatsoever that depends
only on $v \bmod M$. Then over one common period $[0, LM)$ the cell of $\sigma$
and the event $Q$ are exactly independent: the number of $v$ in $[0,LM)$ lying in
the cell and satisfying $Q$ equals*
$$\kappa(\sigma) \cdot \#\{\, r < M : Q(r) \,\}.$$

Not approximately independent. Not independent up to an error term. Exactly
independent, for every $M$, every $Q$, every $\sigma$, every $P$. The proof is
again the Chinese Remainder Theorem: coprimality of $L$ and $M$ makes
$v \mapsto (v \bmod L,\, v \bmod M)$ a bijection from $[0,LM)$ onto the product
of residue systems, and a joint count over a product is a product of counts.

The special case worth framing is $Q(v) : v \equiv r \pmod M$.

**Coprime-Scale Equidistribution.** *For any $M$ coprime to $L$ and any residue
$r$ modulo $M$, the cell of $\sigma$ places exactly $\kappa(\sigma)$ of its
members in the class $r$ inside $[0, LM)$ — the same number for every $r$.*

Concretely: among the $2310$ integers in $[0, 2310)$, exactly $48$ of the ones
coprime to $210$ fall in each of the eleven residue classes modulo $11$. Not
$47$, not $49$. Forty-eight, eleven times, $528 = 11 \times 48$ in total.

This is the theorem that finishes the story. A divisibility cell carries *no*
information about any observable measurable at a coprime scale. The positional
mechanism did not merely fail to replicate on fresh data — in the exact model it
is *provably absent*. The only positional structure a divisibility cell can ever
express is structure at scales sharing a factor with $L$, and that is not a new
mechanism; it is the same divisibility, restated.

---

## Sharpening the dial: the valuation ladder

"Divisible by $3$" is a coarse question. A finer one is: *what is the exact power
of $3$ dividing $v$?* Fix, for each $p \in P$, a target exponent $e_p$, and ask
for the integers with $p$-adic valuation exactly $e_p$ — that is, $p^{e_p} \mid v$
but $p^{e_p+1} \nmid v$ — simultaneously for all $p \in P$. This refines each
divisibility cell into infinitely many sub-cells, with the coarser period $L$
replaced by
$$L_e \;=\; \prod_{p \in P} p^{\,e_p + 1}.$$

What happens to the count?

**The Valuation Ladder.** *Over the refined period $L_e$, the exact-valuation
cell contains exactly*
$$\prod_{p \in P} (p - 1)$$
*members — a quantity completely **independent of the exponents** $e_p$.*

Sharpening the resolution changes only the denominator. The numerator is frozen.
The density of the cell is therefore the clean geometric expression
$$\frac{\prod_p (p-1)}{\prod_p p^{e_p+1}} \;=\; \prod_{p \in P} p^{-e_p}\left(1 - \frac1p\right),$$
so each extra unit of $p$-adic resolution costs precisely a factor of $p$ in
density and nothing else. For $p = 3$: exactly two residues of valuation $e$ in
every period $3^{e+1}$, giving densities $2/3, 2/9, 2/27, \ldots$ — the numerator
never moves. At the all-zero exponent pattern the ladder is anchored at the
totient, recovering the top of the coarse dial.

The proof is the same engine one rung up: modulo $p^{e+1}$, the residues of
valuation exactly $e$ are $p^e k$ for $k = 1, \ldots, p-1$, which is $p-1$ of
them, and coprimality across distinct primes multiplies the counts.

So the dial is not just a dial — it is a pure geometric ladder. There is no
resolution at which a new numerator, some unexpected arithmetic constant, comes
into view.

---

## How many knobs does a sweep really have?

Now back to the failed replication, because the theory has something sharp to say
about *why* it failed.

The original positional signal had been found by sweeping roughly thirty cells
and reporting the most extreme one. Everybody knows to correct for that — the
maximum of $n$ noise draws drifts upward like $\sqrt{2\log n}$ — but the
correction needs an honest $n$. How many *genuinely distinct* things does a sweep
over all $2^{|P|}$ divisibility cells actually test?

Fewer than $2^{|P|}$, and here is the exact count. Recall that the rate of the
cell whose required-divisor set is $T \subseteq P$ is
$$\kappa_T = \prod_{p \in P \setminus T} (p-1),$$
the product of $p-1$ over the *cleared* primes. Since $2-1 = 1$, the prime $2$
contributes nothing, and the set of rates a full sweep can reach is exactly the
set of subset products of the numbers $p - 1$ over the **odd** primes of $P$.

**Effective Sweep Size.** *If $2 \in P$, a sweep over all $2^{|P|}$ divisibility
cells explores at most $2^{|P|-1}$ distinct rate values. Moreover every rate
divides $\varphi(L)$, so the sweep never explores an unconstrained set of numbers
— it explores a sub-family of a single divisor lattice.*

And the bound is attained exactly when nothing else collides:

**The Sidon Criterion.** *A sweep attains the maximum $2^{|P \setminus \{2\}|}$
distinct rates precisely when the numbers $p-1$, over the odd primes $p \in P$,
have pairwise distinct subset products — that is, when $\{p-1\}$ is a
multiplicative Sidon system.*

Is this criterion ever violated? Yes, and pleasingly cheaply. Take
$P = \{3, 7, 13\}$. Then $(3-1)(7-1) = 12 = 13 - 1$, so two different cells carry
the identical rate $12$, and the sweep reaches only $7$ distinct values instead of
$8$. Meanwhile $P = \{2,3,5,7\}$ is clean: $1, 2, 4, 6$ with the dead $2$ removed
leaves $\{2,4,6\}$, whose eight subset products $1,2,4,6,8,12,24,48$ are distinct,
so the sixteen cells express exactly $8 = 2^3$ rates. Half the sweep is
redundant, provably, before a single datum is collected.

That is not a rhetorical point. A selection correction applied with $n = 16$ when
the true effective $n$ is $8$ is over-conservative; applied with $n = 16$ when
distinct cells are *correlated by construction* it is simply wrong. The effective
dimension of a divisibility sweep is a theorem, not an estimate, and the theorem
says it is a question about the multiplicative combinatorics of the shifted
primes $p-1$ — an object with nothing to do with the data at all.

---

## What is left standing

Strip the story to its bones and this is what remains.

A divisibility signature is a *rate* device of the purest kind. It multiplies the
density of a set by the completely factorised amount $\prod_{p}(1 \text{ or }
1-1/p)$, and that factor is exact, is stable under refinement of the valuation
resolution up to a pure power, is invariant under change of observation scale,
and ranges over exactly the divisors-of-$\varphi(L)$ lattice with extremes $1$ and
$\varphi(L)$.

A divisibility signature is *not* a position device, and this is not a
measurement result but a theorem: it is exactly independent of every observable
measurable at any coprime scale, and identically flat across period blocks.

The empirical claim that fell was the positional one, and it fell twice — once to
a fresh dataset, once to a proof, with the proof explaining why the dataset had
to come out that way. The empirical claim that stood was the rate one, and the
proof explains why it *had* to stand: it is a product formula, and product
formulas do not depend on which numbers you happened to sample.

There is a moral here about honest maps. A replication that removes an entry from
a map is doing exactly the same work as one that adds an entry — it is
constraining the truth. In this case the removal came within hours of the
recording, and what it removed was not a random guess but a plausible, carefully
measured, four-sigma-looking result. What made the removal cheap was that the
underlying object was small enough to be settled outright. Divisibility cells are
completely understood; the only question was ever which half of the slogan the
data was seeing.

The door back in has been left open, but it is a narrow one, and it is specified
in advance: a single pre-registered hypothesis at one fixed location — no sweep,
no post-hoc choice of where to look — tested on at least three pooled independent
fresh datasets, and scored against the measurement procedure's own calibrated
baseline rather than against zero. If a positional effect exists at a scale
sharing a factor with $L$, that test will find it. If it lives at a coprime
scale, the theorem above guarantees it does not exist at all.

That is what a negative result is worth when you can prove the negative.
