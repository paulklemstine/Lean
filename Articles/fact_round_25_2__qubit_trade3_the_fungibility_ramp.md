# The Unlucky Half: Why Some Numbers Keep Their Secrets No Matter How Long You Look

## A coin that is not a coin

Suppose someone hands you a slot machine and tells you that it pays out one time in twenty. You have a budget for a hundred pulls. How confident should you be of walking away with a prize?

The arithmetic is familiar: each pull fails with probability $19/20$, all pulls are independent, so the probability of at least one payout is
$$P(s) = 1 - (1-p)^s = 1 - (0.95)^{100} \approx 0.994.$$
Almost certain. This is the logic behind an enormous amount of computational practice: if a randomized procedure succeeds with some fixed small probability, you simply run it again. Samples are *fungible* — one more pull is always worth something, and enough pulls are worth almost everything.

Now suppose that one machine in three on the casino floor has been quietly welded shut. It looks identical to the others. It hums, the lever moves, the reels spin. It will never pay out. You cannot tell which machine you have until you have spent your entire budget on it.

Then the arithmetic changes shape. The best you can achieve, with unlimited pulls, is the fraction of machines that are not welded shut. Your success curve still rises with every pull — but it rises toward a ceiling that has nothing to do with how many pulls you buy. Past a certain point, the honest advice is not "pull harder." It is "walk to a different machine."

This article is about the discovery that the most celebrated randomized algorithm in quantum computing — the period-finding heart of integer factorization — contains exactly such a welded machine, and about the precise arithmetic law that says which machines are welded. The law turns out to be startlingly simple, and it is about a single number: how many times two particular integers can be divided by two.

## Factoring by finding a rhythm

Start with a number $N$ you want to factor, and suppose it is a product of two distinct odd primes, $N = pq$. You do not know $p$ and $q$; that is the whole point.

Pick some number $a$ between $1$ and $N$ that shares no common factor with $N$. Then look at the sequence of its powers modulo $N$:
$$a, \; a^2, \; a^3, \; a^4, \; \dots \pmod N.$$
This sequence is eventually periodic — in fact it returns to $1$ after exactly $L$ steps, where $L$ is called the *multiplicative order* of $a$ modulo $N$. The order is the rhythm of the sequence.

Here is the classical miracle at the core of the algorithm. Suppose the rhythm $L$ is even. Then $a^{L}=1$ means
$$\left(a^{L/2} - 1\right)\left(a^{L/2}+1\right) = a^{L} - 1 \equiv 0 \pmod N,$$
so $N$ divides the product of the two neighbouring numbers $a^{L/2}-1$ and $a^{L/2}+1$. But $N$ need not divide either one separately. If it divides neither, then the prime $p$ must hide in one factor and $q$ in the other — and the greatest common divisor
$$\gcd\!\left(a^{L/2} - 1,\; N\right)$$
computed by Euclid's algorithm in microseconds, hands you $p$ or $q$ on a plate. You have factored $N$ by finding a rhythm.

The quantum part of the story does exactly one thing: it finds the rhythm. A quantum computer running the period-finding subroutine measures a value from which, with some probability depending on the size of its registers, the order $L$ (or a multiple of it) can be reconstructed. Everything else — the halving, the subtraction, the gcd — is ordinary classical arithmetic.

And here is why samples look fungible. Each run of the quantum stage is an independent draw. If one run produces a usable rhythm with probability $p$, then $s$ runs produce one with probability $1-(1-p)^s$, climbing toward certainty. Buy more shots, buy more success. That is the *fungibility ramp*: the quiet assumption that measurement samples are a currency you can spend to purchase confidence.

## The welded machine

Except that the argument above had a conditional in it, and the conditional is doing all the work. "If it divides neither." What if $N$ divides one of the two neighbours?

If $a^{L/2} \equiv 1 \pmod N$, the gcd is $N$ itself: useless. If $a^{L/2} \equiv -1 \pmod N$, then $N$ divides $a^{L/2}+1$ and the gcd with $a^{L/2}-1$ is $1$: also useless. In both cases you learn nothing about $p$ and $q$. The standard telling of the story calls this *bad luck*, assigns it a probability, and moves on: draw a new $a$ and try again.

The central result here is that for a *fixed* base $a$, this is not luck at all. It is a permanent structural property of the pair $(a, N)$, and no number of quantum samples — not a thousand, not a trillion — can ever change it.

To state it, split the rhythm into per-prime pieces. The number $a$ has an order $d_p$ modulo $p$ and an order $d_q$ modulo $q$, and the order modulo $N$ is their least common multiple, $L = \operatorname{lcm}(d_p, d_q)$; this is the Chinese Remainder Theorem in action. Now write each per-prime order as a power of two times an odd number:
$$d_p = 2^{\,i} u, \qquad d_q = 2^{\,j} v, \qquad u, v \text{ odd}.$$
The exponents $i$ and $j$ are the *two-adic valuations* of the orders: how many times each can be halved before it turns odd.

> **The Two-Adic Splitting Criterion.** Let $N = pq$ be a product of two distinct odd primes and let $a$ be a unit modulo $N$ with per-prime orders $d_p = 2^i u$ and $d_q = 2^j v$, with $u$ and $v$ odd. Then *some* even period of $a$ yields a nontrivial factor of $N$ through the gcd step if and only if $i \neq j$.

Everything hangs on the comparison of two small integers. Not on the size of $N$, not on the length of the rhythm, not on the number of measurements: on whether the two per-prime orders can be halved the same number of times.

The two halves of the criterion have very different characters, and both are worth seeing.

**When the valuations agree, nothing ever works.** Suppose $i = j$. Take any exponent $m$ with $a^{2m} \equiv 1 \pmod N$ — that is, any even period the quantum stage could conceivably certify, including ones nobody would think to try. Modulo the prime $p$, the square of $a^{m}$ is $1$, and in a field the only square roots of $1$ are $\pm 1$; so $a^m \equiv \pm 1 \pmod p$, and likewise modulo $q$. The crucial step is that the two signs are forced to *match*. The sign is $+1$ modulo $p$ exactly when $d_p$ divides $m$, and $+1$ modulo $q$ exactly when $d_q$ divides $m$; and when the valuations agree these two conditions are equivalent. Indeed, both orders divide $2m$ (that is what the certificate says), so the odd part $v$ of $d_q$ divides $2m$ and hence, being odd, divides $m$; and if $d_p = 2^i u$ divides $m$ then $2^i$ divides $m$; since $2^i$ and $v$ are coprime, $d_q = 2^i v$ divides $m$ too. The argument is symmetric in $p$ and $q$. Matching signs means $a^m \equiv 1$ modulo both primes, hence modulo $N$; or $a^m \equiv -1$ modulo both, hence modulo $N$. Either way, $\gcd(a^m - 1, N)$ is $1$ or $N$. The welded machine. This is the **unlucky cap**: not a statement about a typical measurement, but a statement quantified over *every* exponent, and therefore over every possible measurement outcome and every conceivable sampling budget.

**When the valuations differ, something always works — and we can point at it.** Suppose $j < i$, so the order modulo $p$ carries strictly more factors of two. A short computation with least common multiples shows
$$L = \operatorname{lcm}(2^i u,\, 2^j v) = 2^{i}\operatorname{lcm}(u,v),$$
so the halved order is $L/2 = 2^{i-1}\operatorname{lcm}(u,v)$. This exponent is divisible by $d_q = 2^j v$ (because $j \le i-1$ and $v \mid \operatorname{lcm}(u,v)$) but *not* by $d_p = 2^i u$ (the power of two is one short). Consequently $a^{L/2} \equiv 1 \pmod q$ but $a^{L/2} \not\equiv 1 \pmod p$ — the prime $q$ divides $a^{L/2}-1$ and the prime $p$ does not — and therefore
$$\gcd\!\left(a^{L/2}-1,\ N\right) = q,$$
a genuine factor, from a single certificate. No probability is involved: this is a theorem, and it produces the factor on the first try.

So the population of bases splits cleanly into two camps. The mixed-valuation bases factor $N$ immediately once their rhythm is known. The matched-valuation bases never factor $N$, no matter what.

## How much of the floor is welded?

If the unlucky bases were the overwhelming majority, the algorithm would be in trouble. They are not, and the reason is a pleasant counting argument about cyclic groups.

The units modulo a prime $p$ form a cyclic group of order $p-1$, which is even. In a cyclic group of even order $n$, exactly $n/2$ elements have order dividing $n/2$ — the "lower half" of the group is precisely half of it. Sharpening this slightly gives the key fact: for any fixed value of the valuation, the set of elements $x$ whose order has that exact two-adic valuation contains at most half of the group. Intuitively, the top valuation level is exactly half the group (those are the elements that are not squares), and every lower level is progressively rarer.

Now bases modulo $N$ correspond, by the Chinese Remainder Theorem, to *pairs* of residues, one modulo $p$ and one modulo $q$ — a product of two cyclic groups of even order. Fix the first coordinate; the valuation of its order is some number $k$. The second coordinate is unlucky only if its own valuation also equals $k$, and we have just seen that this catches at most half of the possibilities. Averaging over the first coordinate:

> **The Unlucky Density Bound.** In a product of two cyclic groups of even order, at most half of all elements have coordinates whose orders share the same two-adic valuation. Consequently at most half of the bases modulo an odd semiprime are permanently unlucky, and re-drawing the base escapes the cap with probability at least $1/2$.

Exhaustive computation over small semiprimes matches this beautifully and even suggests that the bound is not tight in a typical case: for $N = 23 \cdot 29$, $31\cdot 37$, $53 \cdot 59$ the unlucky densities come out at $0.249$, $0.249$, $0.250$ — very close to one quarter, comfortably under the guaranteed half.

There is also a completely explicit escape route. For any odd semiprime $N = pq$ with distinct factors, take a generator of the units modulo $p$ and glue it, via the Chinese Remainder Theorem, to the residue $1$ modulo $q$. The resulting base has order $p-1$ modulo $p$ and order $1$ modulo $q$ — valuations that certainly differ, since $p-1$ is even. So a splitting base always exists, and one can even name it:

> **Escape by Re-drawing.** For every product $N = pq$ of two distinct odd primes there exists a base whose period certificate splits $N$ on the first certificate.

## The ramp, and the ceiling it climbs toward

Put the two halves together and you get the shape of the whole computation, which is the real point.

Fix a base and a modulus. If the base is unlucky, the probability of extracting a factor is exactly zero at every sample budget. If the base is mixed, then each quantum sample independently produces a usable certificate with some probability $p$ (depending on register size and post-processing), so the chance of success after $s$ samples is the capped ladder
$$P(s) = C\left(1 - (1-p)^s\right),$$
where $C \le 1$ absorbs the certification ceiling of the sampling stage. This ladder has exactly the properties one wants of a currency: successive samples compound as independence, in the sense that failure probabilities multiply, $1 - P(s+t) = (1-P(s))(1-P(t))$ in the uncapped case; the gain from each additional sample is smaller than the gain from the previous one; small budgets buy success essentially linearly, $P(s) \le C\,p\,s$; and the ladder converges to $C$ without ever attaining it at any finite $s$.

Average this over a population of instances. Unlucky instances contribute zero forever; mixed instances contribute their ladder. The population success rate therefore obeys
$$P_{\text{pop}}(s) \;\nearrow\; C \times (\text{fraction of mixed-role instances}),$$
converging to a **saturation value that factorizes** into the certification rate of the quantum stage multiplied by the fraction of the population that is not welded shut — and, at every finite budget, staying *strictly* below it.

That factorized ceiling is the punchline, and it was measured, not assumed. On a population of specially constructed semiprimes — primes chosen congruent to $1$ modulo a control parameter $r \in \{210, 310, 434, 510\}$, per-prime orders forced into the pair $\{r, r/2\}$, and bases assembled by the Chinese Remainder Theorem — the single-sample factoring probability climbed the expected ladder as the register grew, $0.018 \to 0.056 \to 0.158 \to 0.181$; additional samples compounded as independence, $0.056 \to 0.204 \to 0.471$, tracking $1-(1-0.06)^s$; and the whole curve saturated near $0.53$, exactly the certification rate multiplied by the roughly two-thirds mixed-role share of that population. Sample count moved the curve along the ladder. It never moved the ceiling.

Why build artificial semiprimes at all? Because for real ones the rhythm is astronomically long — the order of a random base modulo a cryptographic semiprime is on the scale of $\operatorname{lcm}(p-1,q-1)$, which for even modest sizes is around $2^{30}$ and beyond, far past what an honest register simulation can reach. Searching at random for small semiprimes with prescribed simultaneous orders is hopeless too: the density of such pairs is on the order of $10^{-7}$. The way through was to *construct* rather than search — choose $p \equiv 1 \pmod r$, manufacture an element of exact order $d \mid r$ by raising a generator to the power $(p-1)/d$, and glue two such elements together. That construction is itself a small theorem: if $d$ divides the order $n$ of a group element $g$, then $g^{n/d}$ has order exactly $d$; and for every divisor $r$ of $p-1$ the units modulo $p$ do contain an element of exact order $r$.

Building that population is also what surfaced the welded machine in the first place. The first runs produced measurements that were all zero, again and again, and the reason was not a bug in the simulator: it was that identical per-prime orders make a base permanently unlucky. The construction had accidentally been drawing welded machines.

## What this says about factoring, and about sampling in general

For quantum factoring, the practical moral is a reordering of priorities. In the short-register regime — the regime where hardware will live for a long time — the cost model prices samples roughly linearly: each additional shot buys a nearly fixed increment of success, until it does not. The binding constraint is not the shot budget but the base. The classical ritual of *re-drawing $a$* is not a minor cleanup step; it is the only operation in the pipeline that can move the ceiling, and the density bound guarantees it works at least half the time.

There is a second, quieter moral, visible in the outcome taxonomy of the experiment. Across the full run, the outcomes broke down as: spurious or partial certificates $0.844$, permanently unlucky bases $0.109$, successful factor extraction $0.044$, and failure to certify anything at all $0.003$. Read that last number again. Getting *some* certificate out of the quantum stage is almost never the problem. The dominant cost is sorting the good certificates from the bad — and that sorting is pure classical verification against $N$, cheap per item but overwhelming in aggregate. The bottleneck in this pipeline is not the quantum device; it is the filter behind it.

And there is a general lesson that reaches past factoring. Randomized algorithms are usually analyzed as if every instance were a fair coin with the same bias. The moment some instances are structurally dead — a welded machine hidden among working ones — the success curve acquires a ceiling that averaging cannot see and repetition cannot lift. The right question to ask of any such algorithm is not "what is the per-sample success probability?" but "what fraction of instances has a per-sample success probability of exactly zero, and what other operation can I perform to draw a new instance?"

In factoring, the answer to the second question is beautifully cheap: pick a new $a$. In other settings, the analogous move may not exist at all. Knowing which of the two you are in is worth more than any number of extra samples.

## The shape of the result

Strip away the machinery and the story is a single sentence: *whether a period certificate can factor a number depends only on whether two integers can be halved the same number of times.*

It is an oddly small hinge for so large a door. The size of $N$, the length of the rhythm, the sophistication of the measurement — none of them enter. Two valuations, compared. Equal, and the door stays shut forever; unequal, and it opens on the first push.

That sharpness is what turns a probabilistic folklore statement ("sometimes you get unlucky, so try again") into an exact dichotomy with an exact escape and an exact density. And it is what converts the fungibility ramp from a hopeful metaphor about buying success with samples into a precise statement with a named ceiling: samples buy you motion along the ladder; only a new base buys you a taller ladder.
