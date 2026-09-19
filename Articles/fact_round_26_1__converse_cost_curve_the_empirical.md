# The Price of a Secret: Why Every Known Way of "Seeing" a Factor Costs the Same

## A number that keeps a secret in plain sight

Take two prime numbers, multiply them, and publish the answer. That is the whole trick behind a large part of modern cryptography. The product $N = pq$ is public; the factors $p$ and $q$ are the secret. Multiplying is instantaneous. Undoing the multiplication has resisted three centuries of effort.

What makes this asymmetry so stubborn? It is not that $N$ hides its factors. In a strict mathematical sense $N$ *is* its factors: by unique factorisation, the number $143$ contains no information that $11$ and $13$ do not. The secret is not hidden; it is merely *expensive*. Every fact about $N$ that would betray the factors seems to demand an amount of work that grows like a power of $N$ itself, rather than a power of the number of digits of $N$ — and the gap between those two growth rates is the entire security margin of the internet.

This article is about a family of such facts — we will call them *witnesses* — and a single, rather humbling discovery: they are all the same fact wearing different clothes, and they all cost about the same. There is no cheap route among them. Not because nobody has looked hard enough, but because one can prove it.

## Four witnesses

Here are four quantities you can attach to a number $N$. Each one, on the face of it, comes from a completely different corner of mathematics. Each one, if you could compute it cheaply, would hand you the factorisation.

**Witness 1: the greatest-common-divisor sum.** Walk through every residue $x = 0, 1, 2, \dots, N-1$, compute $\gcd(x, N)$, and add them all up:
$$M_1(N) \;=\; \sum_{x=0}^{N-1} \gcd(x, N).$$
For $N = 15$ this sum is $45$. For $N = 143 = 11 \cdot 13$ it is $525$.

**Witness 2: the first zero divisor.** Walk $x = 1, 2, 3, \dots$ and stop at the first $x$ that shares a factor with $N$ — the first $x$ with $\gcd(x, N) > 1$. For $N = 143$ you stop at $x = 11$.

**Witness 3: a congruence of squares.** Find integers $x \ne \pm y$ with $x^2 \equiv y^2 \pmod N$. This is the engine inside Fermat's method, the continued-fraction method, and the quadratic sieve.

**Witness 4: the idempotent count.** Count the solutions of $x^2 \equiv x \pmod N$ — the residues that are their own square. For $N = 15$ there are four: $0, 1, 6, 10$.

Four witnesses, four moods: an arithmetic sum, a search, an algebraic coincidence, a fixed-point count. The question this article answers is: *how much do they cost, and what do they buy?*

## Witness 1 is an affine function in disguise

Start with the gcd-sum. It looks like a genuine sum over $N$ terms — a shapeless object that could encode anything. It does not. For $N = pq$ with distinct primes $p$ and $q$:

> **Theorem (closed form for the gcd-sum).** If $p \ne q$ are primes and $N = pq$, then
> $$M_1(N) + 2(p+q) \;=\; 4N + 1, \qquad \text{that is,} \qquad M_1(N) = 4N - 2s + 1$$
> where $s = p + q$.

The proof is a single counting argument. Because $p$ and $q$ are coprime, $\gcd(x, N)$ factors as $\gcd(x,p)\cdot\gcd(x,q)$, and each of those is either the prime (when it divides $x$) or $1$. So the residues below $N$ split into exactly four cells: the $q$ multiples of $p$, the $p$ multiples of $q$, their single overlap $x = 0$, and everything else. Adding up $1 \cdot$ (size of cell) $\times$ (gcd value on that cell) gives $pq + p(q-1) + q(p-1) + (p-1)(q-1)$, which rearranges to $4pq - 2(p+q) + 1$. Check it on $N = 143$: $4\cdot 143 - 2 \cdot 24 + 1 = 525$. ✓

The consequence is startling in both directions. On one hand, the sum is *informative*: from $N$ and $M_1(N)$ you recover
$$s = p + q = \frac{4N + 1 - M_1(N)}{2}$$
by one subtraction and one halving. And knowing the sum and the product pins the primes:

> **Theorem (rigidity of the pair).** Two ordered pairs of natural numbers with the same sum and the same product are equal (after sorting). Hence $(N, s)$ determines $\{p, q\}$.

The proof is the schoolbook symmetric-function argument: $(q - p)^2 = s^2 - 4N$ is determined, so the difference is determined, so the pair is. The chain **witness $\to s \to \{p,q\}$** closes.

On the other hand, the sum is *empty*: it is an affine function of $N$ and $s$, nothing more. You spend $N$ gcd computations to learn one number. And that number is not even new: the gcd-sum and Euler's totient are two views of the same datum,
$$M_1(N) + 1 = 2\varphi(N) + 2N,$$
and computing $\varphi(N)$ for a semiprime has been known since RSA to be exactly as hard as factoring it.

## Every sum of that shape is the same sum

A natural reflex: maybe the gcd wasn't the right summand. What if we sum $f(\gcd(x,N))$ for some cleverer $f$ — squares, logarithms, indicator functions? Call the result $S_f(N)$. The reflex dies immediately:

> **Theorem (the whole class at once).** For every function $f$ on the natural numbers and every semiprime $N = pq$,
> $$S_f(N) \;=\; \sum_{x=0}^{N-1} f(\gcd(x,N)) \;=\; f(pq) + (q-1)f(p) + (p-1)f(q) + (p-1)(q-1)f(1).$$

The same four-cell partition proves it; only the weights change. And that is the point: *every* member of this infinite class of witnesses is a function of $f$'s values on the four divisors $1, p, q, pq$, weighted by four cell sizes. No choice of $f$ sees anything finer than the unordered pair $\{p, q\}$. The class even contains completely blind members: taking $f \equiv 1$ returns $S_f(N) = N$, a $\Theta(N)$ computation whose output is the input.

So an entire infinite family of $N$-cost witnesses collapses onto one plane whose only coordinate is $s = p + q$.

## Witness 2: the cost is a theorem, not a measurement

The zero-divisor scan is the most honest of the four: you can watch it work. Its running time is not an estimate:

> **Theorem (the scan's stopping point).** For $N = pq$ with $p, q$ prime, the least positive $x$ with $\gcd(x, N) > 1$ is exactly $\min(p, q)$.

Both halves are easy and both matter: $\min(p,q)$ is a hit because it divides $N$; and nothing smaller is a hit, because any hit must be a multiple of $p$ or of $q$, hence at least $\min(p,q)$. When the scan finally stops, it has done everything: the stopping value is one prime, and $N$ divided by it is the other.

The geometry of the scan plane is just as sharp. Among the $N$ residues, exactly $p + q - 1$ are hits (the $q$ multiples of $p$ and the $p$ multiples of $q$, overlapping only at $0$), and exactly $\varphi(N) = (p-1)(q-1)$ are wasted probes: units, carrying literally no information about the factorisation. For a balanced semiprime the informative fraction is about $2/\sqrt{N}$ — a vanishingly thin sliver.

That thinness kills the obvious escape route of randomisation. Since the number of hits times $\min(p,q)$ never exceeds $2N$, a uniformly random probe succeeds with probability at most $2/\min(p,q)$; the expected number of probes to see a hit is $\Omega(\min(p,q))$, the same wall the deterministic scan runs into. Randomness does not buy a shortcut; it buys a coin flip about *when* you pay.

And the wall is genuinely exponential in the input size. If $p \le q \le 2p$ — a *balanced* semiprime, which is exactly what cryptographic key generation produces — then $N \le 2\min(p,q)^2$, so the scan cost is at least $\sqrt{N/2}$. The input has $\log_2 N$ bits; the cost is $2^{(\log_2 N)/2}$ steps.

## Witnesses 3 and 4 are counting the wrong thing

The last two witnesses are the most instructive, because they fail in a way that is easy to misread as success.

Count the idempotents mod $N$ — the solutions of $x^2 \equiv x$. For a semiprime you always get exactly four: $0$, $1$, and a conjugate pair $e$, $1-e$ coming from the Chinese Remainder Theorem, which splits $\mathbb{Z}/N$ into $\mathbb{Z}/p \times \mathbb{Z}/q$ and lets you pick $0$ or $1$ independently in each coordinate. (An early version of this experiment excluded $x = 0$ as "trivial" and then failed its own count of four. The trivial idempotent is not a rounding error; it is one of the two CRT sign choices.)

Exactly four — for $15$, for $35$, for $143$, for a $2048$-bit RSA modulus. Which means:

> **Theorem (the counter is constant).** The number of idempotents modulo a semiprime is $4$, independently of which semiprime it is. The $\Theta(N)$ scan that computes it carries **zero** bits about the factorisation.

The general statement is prettier and explains why:

> **Theorem (the idempotent ladder).** For every $N > 0$, the ring of residues modulo $N$ has exactly $2^{\omega(N)}$ idempotents, where $\omega(N)$ is the number of distinct prime factors of $N$.

Two ingredients: *local rigidity* — modulo a prime power $p^n$ the only idempotents are $0$ and $1$, because $p^n \mid v(v-1)$ and $p$ cannot divide both $v$ and $v-1$ — and the Chinese Remainder Theorem, which multiplies the local counts. So the idempotent route is an $\omega$-detector: it reports how many distinct primes divide $N$, and nothing else. For a $\Theta(N)$ price you learn a number you could have guessed.

The same story repeats one shelf up. The square roots of unity — the solutions of $x^2 \equiv 1$ — are the objects Fermat's method, the continued-fraction method, Pell-type relations and the Miller–Rabin test all chase.

> **Theorem (the square-root ladder).** For every odd $N > 0$ the equation $x^2 \equiv 1 \pmod N$ has exactly $2^{\omega(N)}$ solutions.

Again local rigidity plus CRT, with one extra twist: modulo an odd prime power, $p$ cannot divide both $v-1$ and $v+1$, because their difference is $2$. (The oddness hypothesis is not decoration — modulo $8$ there are four square roots of unity, $1, 3, 5, 7$, though $\omega(8) = 1$. The ladder really does break at the prime $2$.) So every odd semiprime has exactly four square roots of unity, and the counter is once more a constant.

But the individual roots are gold. If $x^2 \equiv y^2 \pmod N$ while $x \not\equiv \pm y$, then $N$ divides $(x-y)(x+y)$ but divides neither factor, so each prime must go to a different side and $\gcd(x - y, N)$ *is* one of the primes. One gcd — microseconds — turns the witness into the answer. Likewise a nontrivial idempotent $x$ satisfies $\gcd(x, N) \in \{p, q\}$.

This is the sharpest lesson in the whole story. **All the content lives in the individual witnesses, never in how many there are.** Counting is cheap information and expensive computation; finding is the reverse. Every classical factoring algorithm is a scheme for *finding* one nontrivial square root, and every one of them pays roughly $\sqrt{N}$ or worse for the privilege.

## One plane, no shortcuts

Put the four routes side by side and they occupy a single cost–information plane. The two full scans (gcd-sum, idempotent count) cost $\Theta(N)$. The zero-divisor scan costs exactly $\min(p,q)$, which is $\Theta(\sqrt N)$ for balanced semiprimes. The square-root routes cost whatever it costs to find a congruence of squares — in practice, the $\sqrt{N}$-scale classical methods. And the information every informative route delivers is the *same single number*, $s = p+q$, from which the pair follows.

That observation becomes a theorem:

> **Theorem (no polylogarithmic route anywhere).** Fix any exponent $d$. Then beyond an explicit threshold, every route in this family, evaluated on any balanced semiprime $N$, costs more than $(\log_2 N)^d$ operations.

The proof compresses the whole picture into two lines. Every route in the family costs at least the cheapest one, $\min(p,q)$. For a balanced semiprime $\min(p,q) \ge \sqrt{N/2}$, so with $k = \lfloor \log_2 N \rfloor$ bits we have $\min(p,q)^2 \ge 2^{k-1}$. And polynomials lose to exponentials: $k^{2d} < 2^{k-1}$ for all large $k$. Hence $k^d < \min(p,q) \le$ every route cost. The bit length can never catch the square root.

## The strongest version: a blind oracle

All of the above is about *these* routes — the natural way of evaluating each of these four witnesses. A sceptic is entitled to ask: so what? Maybe a cleverer algorithm avoids the whole family.

Restrict attention to what all four routes actually do at the machine level — they probe residues and look at $\gcd(x, N)$ — and the sceptic can be answered completely. Model an algorithm as an *adaptive strategy*: hand it the list of gcd answers it has received so far, and it names the next residue to probe. After $T$ probes it produces a *transcript*, and any output rule whatsoever reads the pair $(p,q)$ off that transcript.

> **Theorem (the black-box converse).** For any adaptive gcd-probe strategy, any budget $T$, and any output rule, there exist two semiprimes with completely disjoint factorisations on which the strategy receives the **identical** all-ones transcript. Consequently some semiprime is answered wrongly: no $T$-query gcd-probe algorithm factors.

The argument is a one-line adversary. Run the strategy in a *null world* where every answer is $1$; it makes $T$ specific probes, and all of them are bounded by some number $B$. Now pick four primes larger than $B$. On either of the two semiprimes they build, every probe is a positive integer smaller than both primes, hence coprime to the modulus, hence answers $1$ — which is exactly the null world the strategy assumed. The two runs are indistinguishable, so one of the two answers is wrong.

This is a strictly stronger kind of barrier than a cost curve. It is not that the algorithm is slow; it is that it is *blind*. No amount of cleverness in choosing probes helps, because the answers it receives contain no signal at all until it stumbles onto a multiple of a prime — and finding one of those is the original problem.

## What this settles, and what it does not

It would be wonderful, and false, to say this proves factoring is hard. It does not, and the honesty is part of the result. What it proves is a *converse for a family*: within the class of gcd-local statistics, the idempotent and square-root counters, and the zero-divisor scan, there is no polylogarithmic route — and within the black-box gcd-probe model, there is no algorithm at all.

Some measured facts in the experimental phase came out contrary to the naive guess and are reported as measured, not as hoped. The continued-fraction route's cost exponent came out *below* the naive $\tfrac12$ across the sizes tested; the period length of $\sqrt N$ lags $\sqrt N$ rather than tracking it. An early run mis-sized its semiprimes and had to be discarded before it produced a claim. The idempotent scan first failed its own count-of-four assertion because it excluded $x = 0$ — a bug that turned out to be a lesson about the CRT.

What emerges is a geometry rather than a hardness proof. The classical factoring landscape has a shape: the informative content of every witness anyone has found is the single symmetric datum $s = p+q$; the counters are $\omega$-detectors that see the *shape* of the factorisation and not its *identity*; and the cheapest way anyone knows to produce a genuine witness rides the $\sqrt N$ scale, precisely where the classical methods already live. Every route in the family has the same destination and the same toll.

That is not a proof that no road exists. But it is a map showing that all the known roads run through one pass — and a proof that the pass is high. The next frontier is to show that the pass is the only way through: an unconditional lower bound, not for a family of witnesses, but for every algorithm. That remains open, as it has been for fifty years. Meanwhile, every time you open an encrypted connection, you are betting that nobody has found a road off this map.
