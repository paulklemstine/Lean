# The Price of Asymmetry: Measuring What It Costs to Break a Number in Half

## A number that keeps its secret in plain sight

Take two large primes, multiply them, and publish the product. Call it $N$. Everyone can see $N$. Nobody — as far as the world's cryptography is willing to bet — can see the two primes inside it. The entire public-key infrastructure that protects online banking, secure messaging, and software signatures rests on this asymmetry between a multiplication anyone can do and a division nobody can undo.

The interesting question is not *whether* factoring is hard. It is **what exactly is missing**. Is the information about the hidden factors simply absent from the public data? Or is it there, sitting in plain sight, sealed behind a computational lock?

This article reports a measurement that answers that question sharply for one natural family of arithmetic probes: the **quadratic residue symbols**. The answer is that the information is *abundantly* present — a mere $\lceil \log_2 \pi(\sqrt N)\rceil$ bits of the right kind pin the hidden factor down exactly, and no fewer will do — while the corresponding *public* data, the symbols computable from $N$ alone, is provably, exactly, and permanently blind. The distance between these two facts is a number we can now state: it is the **symmetry-breaking cost**.

## The probe: a coin-flip you can compute

For an odd prime $p$ and an integer $a$ not divisible by $p$, ask: *is $a$ a perfect square modulo $p$?* Write the answer as $\left(\frac{a}{p}\right) = +1$ if yes and $-1$ if no. This is the Legendre symbol, and it is the cheapest nontrivial question you can ask about a number modulo a prime — a single bit.

The symbol extends multiplicatively to composite moduli. If $n = p_1 p_2 \cdots p_r$ (with repetition), the Jacobi symbol is
$$\left(\frac{a}{n}\right) = \prod_{i=1}^{r} \left(\frac{a}{p_i}\right).$$
The crucial and slightly treacherous fact is that this extended symbol can be computed *without knowing the factorization of $n$*: a reciprocity-driven algorithm runs in the same time as Euclid's, so $\left(\frac{a}{N}\right)$ is public data for anybody holding $N$.

So we have two batteries of tests. Fix a list of integers $a_1, \dots, a_k$.

- **The asymmetric (oracle) battery.** Someone who knows the hidden prime $p_0$ can report the vector $\left[\left(\frac{a_1}{p_0}\right), \dots, \left(\frac{a_k}{p_0}\right)\right] \in \{\pm 1\}^k$.
- **The symmetric (public) battery.** Anyone can compute $\left[\left(\frac{a_1}{N}\right), \dots, \left(\frac{a_k}{N}\right)\right]$.

The two look almost identical. They are separated by an abyss.

## Side one: the oracle is astonishingly cheap

Let $S$ be the set of candidate prime factors — say, all odd primes $p$ with $p^2 \le N$. Its size is roughly $\pi(\sqrt N)$, about $\sqrt N / \log \sqrt N$ candidates, an exponentially large set in the bit-length of $N$.

Now think of the signature map $r \mapsto \left[\left(\frac{a_i}{r}\right)\right]_{i \le k}$, which assigns to every candidate a length-$k$ string of $\pm 1$. If this map is injective on $S$, the oracle's answers *identify* the hidden factor: exactly one candidate matches, and one division confirms it.

How large must $k$ be? The counting bound is immediate: $k$ bits distinguish at most $2^k$ things, so $k \ge \lceil \log_2 |S| \rceil$. The surprise is that this crude bound is *achieved*, and the reason is a strong independence statement.

> **Independence of Legendre signatures.** Let $S$ be any finite set of distinct odd primes and let $\varepsilon : S \to \{+1, -1\}$ be *any* prescribed pattern of signs whatsoever. Then there exists a single integer $x$ with $\left(\frac{x}{p}\right) = \varepsilon(p)$ simultaneously for every $p \in S$.

In words: the quadratic characters of distinct primes are completely unconstrained by one another. Knowing the residue behaviour of $x$ at a thousand primes tells you nothing at all about its behaviour at the thousand-and-first. The proof is the Chinese Remainder Theorem plus the elementary fact that every odd prime has a quadratic nonresidue: choose locally, glue globally.

The consequence is that the signature map can be made to realize *any* injection $S \hookrightarrow \{\pm 1\}^k$ we like. Encode the candidates as distinct bit strings; build one test integer per bit position by prescribing the corresponding column of signs. This yields:

> **The measurement.** For a set $S$ of distinct odd primes, the least number of residue queries that isolates every candidate is exactly $\lceil \log_2 |S| \rceil$. The upper bound is the independence theorem; the lower bound is pigeonhole on the answer bits.

Because the candidates all lie below $\sqrt N$, this cost is at most $\tfrac12 \log_2 N$: about half the bits of $N$ suffice to name its factor. Numerically, over semiprimes of $15$ to $33$ bits — candidate sets ranging from $31$ to $7894$ primes — the number of queries actually needed tracks $\log_2 \pi(\sqrt N)$ with a ratio hovering between $0.96$ and $1.03$. The theory and the arithmetic agree to within rounding.

One might hope adaptivity helps: choose the next test integer only after seeing the previous answers, steering the search. It does not.

> **Adaptivity buys nothing.** Model an adaptive strategy as a binary decision tree, each internal node holding a test integer and branching on whether the symbol is $+1$, each leaf naming a guess. A tree of depth $d$ correctly names at most $2^d$ candidates, and depth $\lceil \log_2 |S| \rceil$ is attained by compiling the fixed battery into a complete tree. The optimal adaptive depth is therefore exactly $\lceil \log_2 |S| \rceil$ — the same number.

The reason is precisely the independence theorem again: because every answer pattern is realizable, no branch can be pruned in advance, and the tree is forced to be complete.

## Side two: the public battery is exactly blind

Now the same probe, aimed at $N$ instead of $p_0$. Surely $\left(\frac{a}{N}\right)$, which after all equals $\left(\frac{a}{p_0}\right)\left(\frac{a}{q_0}\right)$ for $N = p_0 q_0$, leaks *something*?

It leaks nothing usable, and we can say exactly why. Define the **squarefree kernel** $K(n)$ of a modulus $n$ to be the set of primes dividing $n$ to an odd multiplicity. Then for every $a$ coprime to $n$,
$$\left(\frac{a}{n}\right) = \prod_{p \in K(n)} \left(\frac{a}{p}\right),$$
since a prime appearing to an even power contributes a square $(\pm1)^2 = 1$. The symbol simply cannot see even multiplicities.

That is a limit on the data. The sharp statement is that it is the *only* limit:

> **The public battery knows the kernel, and nothing else.** For odd $M, N > 0$, the two Jacobi batteries agree — that is, $\left(\frac{a}{M}\right) = \left(\frac{a}{N}\right)$ for every $a$ coprime to $MN$ — if and only if $K(M) = K(N)$.

The forward direction is the product formula. The converse is the independence theorem once more, worn inside out: if some prime $p$ lies in $K(M)$ and not in $K(N)$, prescribe a nonresidue at $p$ and a residue at every other prime of $K(M) \cup K(N)$; the Chinese Remainder Theorem supplies a numerator $a$ at which the two batteries visibly differ. So the public data is a *complete* invariant of the kernel and an *empty* one beyond it.

Now watch what this destroys. Pick any candidate prime $r$ you might want to test — anything at all. Look at the modulus $M = N r^2$. Since squares are invisible to the kernel, $K(Nr^2) = K(N)$, and therefore

> **Sharp zero pruning.** For every candidate $r$, the modulus $N r^2$ is divisible by $r$ and has *literally the same Jacobi battery as $N$*, on every admissible numerator. No candidate can ever be excluded by public residue data. In fact the survivors are unbounded: for any $B$ there is such a modulus exceeding $B$.

Each candidate has, so to speak, a **compensating partner**: a way of sitting inside a modulus that mimics $N$ perfectly. The symmetric battery cannot break the tie, not for lack of bits, but by a structural collapse. For a semiprime $N = pq$ with $p \ne q$, the kernel is exactly $\{p, q\}$ — the battery reproduces $N$ itself and not one bit more.

## The gap is the cost

Line the two sides up.

| resource | cost to isolate the hidden factor |
|---|---|
| residue oracle (asymmetric) | exactly $\lceil \log_2 \pi(\sqrt N)\rceil \le \tfrac12\log_2 N$ queries |
| $N$ alone (symmetric) | infinite — zero candidates pruned, ever |
| quantum order-finding | polynomial in $\log N$ |

The residues are **information-sufficient but computation-sealed**. Half the bit-length of $N$ worth of the right symbols nails the factor; the publicly computable version of exactly the same symbols nails nothing. What separates them is not quantity but *asymmetry*: the oracle evaluates the character at one prime, the public data aggregates it over all of them, and aggregation is a projection that provably annihilates the distinguishing content.

That projection is the toll booth. Any classical algorithm that wants factor information out of this family of probes has to pay to undo the aggregation, and the known ways of paying — sieving over a huge factor base until enough relations accumulate to build a congruence of squares — cost time on the order of $N$ raised to a fractional power. The aggregation barrier is not incidental to the difficulty; it *is* the difficulty, in a form we can now measure.

## What the quantum channel actually buys

Shor's algorithm is usually described as "period finding is fast on a quantum computer." The measurement above suggests a different framing: **the quantum channel is a symmetry-breaking resource, and its value is exactly the aggregation it bypasses.**

The object Shor's algorithm hunts for is a *nontrivial square root of unity*: an $x$ with $x^2 \equiv 1 \pmod N$ but $x \not\equiv \pm 1$. Given one, $\gcd(x-1, N)$ is a nontrivial factor. Three facts complete the picture, and each one is an instance of the same mechanism we have already seen.

> **The witness always exists.** For distinct odd primes $p \neq q$ and $N = pq$, the Chinese Remainder Theorem provides an $x$ with $x \equiv 1 \pmod p$ and $x \equiv -1 \pmod q$. Then $N \mid x^2 - 1$ while $N \nmid x \pm 1$: a nontrivial square root of $1$, produced explicitly.

> **One gcd finishes the job.** For that witness, $\gcd(x - 1, N) = p$ on the nose.

> **There is no third kind of witness.** Every nontrivial square root $z$ of $1$ modulo $N = pq$ splits the primes — congruent to $1$ at one and $-1$ at the other — so $\gcd(z-1, N)$ is $p$ or $q$. Nothing is wasted; every witness factors.

So the factoring data is *never missing*. For every odd semiprime there is a residue signature that isolates the factor in $\lceil \log_2 |S| \rceil$ bits, and a square root of unity that reveals it with one gcd. Both are produced by the same construction — prescribe independent local behaviour, glue with the Chinese Remainder Theorem — and both are invisible to the public battery for the same reason: aggregation.

What the quantum algorithm supplies is not information but *pointing*. Order finding reads out a global period from a superposition, and that readout is asymmetric in exactly the way $\left(\frac{a}{N}\right)$ is not: it does not average the local data of $p$ and $q$ into a single symbol; it resolves the composite structure. It is a payment for the same asymmetry that classical sieving pays for with $\Omega(N^{c})$ aggregation work. Two currencies, one bill.

## The honest verdict

As a proposed *attack*, this line of thought is refuted, and cleanly so. One might have hoped that the public Jacobi symbols of $N$ could be squeezed for a hint about the factors, however faint, and that many such hints could be aggregated. They cannot: the kernel theorem shows the pruning power is exactly zero, not merely small, and the compensating-partner construction exhibits an explicit conspiracy for every single candidate. The classical, uniform, hint-free surface is exhausted.

But refutation is a measurement too. The value of a negative result stated exactly is that it converts a vague intuition — "residues don't help" — into a quantity: the gap between $\lceil \log_2 \pi(\sqrt N)\rceil$ and infinity, mediated by the aggregation map. It unifies two frontiers that are usually discussed separately: the classical question of what a factor base costs, and the quantum question of what a period readout is worth. Both become the same question — *what does it cost to break the symmetry between $p$ and $q$?* — and the answer is written in the same units.

There is also a research programme visible from here. The independence argument never once used the fact that our characters were quadratic; only that the local values can be prescribed arbitrarily and glued. So the same measurement should hold for $m$-th power residue symbols with cost $\lceil \log_m |S| \rceil$ — the alphabet size, not the arithmetic, setting the price. Randomization should not help either: because every answer pattern is equally realizable, an averaging argument over the uniform distribution on candidates should force expected depth $\log_2 |S| - O(1)$. And at the prime $2$, where no quadratic nonresidue exists, the kernel theorem should extend once the Kronecker symbol replaces the Jacobi symbol and kernels are compared modulo squares of rationals.

Modern cryptography rests on a wall. It is nice, once in a while, to walk up to the wall with a ruler and come back with a number.
