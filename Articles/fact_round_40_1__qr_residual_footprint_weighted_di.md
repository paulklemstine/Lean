# The Dial That Knows Everything About Nothing

## How a two-line arithmetic formula predicts the yield of a factoring sieve — and why it can never help you factor anything

### A machine with an unexplained hum

Suppose you are running one of the great workhorses of computational number theory: the quadratic sieve, the algorithm that dominated integer factorization for a decade and still underlies the way we think about factoring today. You feed it a number $N$. It marches through a long list of integers $x$ near $\sqrt{N}$, computes the values
$$v(x) = x^2 - N,$$
and tries to factor each $v(x)$ completely over a fixed set of small primes — the *factor base*. Values that split completely are called **relations**, and once you have collected enough relations you can combine them with linear algebra to produce a congruence of squares and, with luck, a factor of $N$.

The practical question every implementer faces is: *how many relations per unit of work will I get for this particular $N$?* The answer matters. Choose the sieve interval and the smoothness bound badly and you waste hours; choose them well and you finish in minutes. So people fit a **yield dial**: a small predictive formula that, given $N$ and the parameters, estimates the harvest.

The naive dial — the one built from the size of the values, the smoothness bound, and the classical density heuristics — works reasonably well. In a controlled experiment across many moduli, it explained about $39\%$ of the out-of-sample variance in yield (a coefficient of determination of $R^2 = 0.3927$). The remaining $61\%$ looked like noise.

It was not noise. It was arithmetic.

### The two-root slogan

Here is the observation that cracks it open. Fix an odd prime $p$ from the factor base. Ask: how often does $p$ divide a sieve value $x^2 - N$?

The condition $p \mid x^2 - N$ is the congruence $x^2 \equiv N \pmod p$. As $x$ runs over one full period of $p$ consecutive integers, this has either two solutions, one solution, or none — and which of the three happens is determined entirely by $N$ modulo $p$:

- If $N$ is a nonzero **quadratic residue** mod $p$ — a square mod $p$ — there are exactly **two** roots, so $p$ divides exactly $2/p$ of the sieve values.
- If $N$ is a **non-residue**, there are **no** roots, and $p$ never touches the sieve at all.
- If $p$ divides $N$, there is exactly **one** root (a degenerate case that a real sieve handles separately, since a prime dividing $N$ has already factored it).

So half of your carefully chosen factor base is, for any given $N$, completely inert. Which half depends on $N$ — and it depends on $N$ *only through its residues modulo the base primes*.

This suggests a feature. For a bound $B$, define
$$W(N) \;=\; \sum_{\substack{p \le B,\ p \text{ odd prime} \\ N \text{ a square mod } p}} \frac{2}{p}.$$
Call it the **footprint dial**: it is the total local hit density that the factor base actually delivers for this particular $N$. Two numbers of the same size can have very different footprints, because they activate different subsets of the base.

When this single number was added to the yield model, the out-of-sample $R^2$ jumped from $0.3927$ to $0.5691$ — a gain of $+0.176$, with a bootstrap confidence interval of $[0.120,\,0.229]$. In a harder regime (values further from the smoothness threshold), it lifted $0.2063$ to $0.3078$. Add a second, cruder feature — the raw fraction of sieve values divisible by a prime at most $13$ — and the two together reach $0.5864$. The "noise" had a name.

That is the empirical story. The mathematical story is more interesting, because almost every part of the slogan above can be made *exact*, and because the exactness comes with a sting in the tail.

### From slogan to identity

The first thing to prove is that the feature is not an approximation at all. Consider one full period of the sieve: let $M$ be the product of all the odd factor-base primes, and let $x$ run over $0,1,\dots,M-1$. For each $x$, count how many factor-base primes divide $x^2 - N$. Average that count over the period. The answer is exactly
$$\frac{1}{M}\sum_{x=0}^{M-1} \#\{p \le B : p \mid x^2-N\} \;=\; \sum_{p \le B} \frac{h(N,p)}{p},$$
where $h(N,p)$ is the number of roots of $x^2 \equiv N$ in one period of $p$. And when $N$ is coprime to the whole base, that right-hand side is precisely $W(N)$, because $h$ is $2$ on residues and $0$ on non-residues.

**Mean-Footprint Identity.** *The average number of factor-base primes dividing a sieve value, taken over a full period of sieve locations, is exactly the footprint dial $W(N)$.*

No error term, no asymptotics, no "approximately". The feature *is* the mean footprint, on the nose. The same argument extends to prime powers, which real sieves also harvest: by an explicit Hensel-lifting bijection, the number of roots of $x^2 \equiv N \pmod{p^k}$ is the *same* as the number mod $p$, for every $k \ge 1$ and every odd $p$ not dividing $N$. So an admissible prime power $p^k$ hits exactly $2/p^k$ of the locations, and an inadmissible one hits nothing, forever. (The prime $2$ behaves differently and more rigidly: if $N$ is odd and $N \not\equiv 1 \pmod 8$, then no power $2^k$ with $k \ge 3$ ever divides a sieve value at all.)

### The signal lives in the wobble

Now a puzzle. A classical result about the quadratic sieve says the relation pool behaves like a *random* pool prime by prime: averaged over $N$, each prime hits once per period, exactly as it would for a random integer. If that is true, how can $W(N)$ predict anything?

The resolution is a computation. Average the raw footprint $\sum_p h(N,p)/p$ over one full period of moduli $N$: you get exactly
$$\sum_{p \le B} \frac{1}{p},$$
the random-integer footprint. The dial's *mean* is the random model, precisely. The QR-form dial $W$ has the slightly larger mean $\sum_{p \le B}(p+1)/p^2$, the excess $\sum 1/p^2$ coming from the degenerate residues $p \mid N$.

So there is no contradiction: the random model is right about the average, and every bit of predictive content lives in the **fluctuation** around that average. Which raises the obvious question — how big is the fluctuation?

Big enough, and exactly computable. The quadratic-residue indicators at distinct primes turn out to be *exactly* independent as $N$ runs over one period, with $(p+1)/2$ favourable residues out of $p$ at each prime. This is not an asymptotic independence; it is a Chinese-remainder identity. From it one reads off the count of moduli realising any prescribed pattern $T$ of active primes:
$$\#\{N < P : \text{active set of } N = T\} \;=\; \prod_{p\in T}\frac{p+1}{2}\ \cdot \prod_{p \notin T}\frac{p-1}{2},$$
where $P$ is the product of the base. Every pattern occurs, always. And summing the independent contributions gives the variance in closed form:

**Variance Identity.** *Over one full period of moduli, the footprint dial has variance exactly*
$$\operatorname{Var}(W) \;=\; \sum_{p \le B} \frac{p^2-1}{p^4}.$$

This is a lovely little series. Every term is positive, so the dial is genuinely non-constant — the observed $R^2$ lift cannot be an artefact of a degenerate, nearly-constant regressor. But the series *converges*, and in fact is bounded above by $1/2$ no matter how large $B$ is, while the mean $\sum (p+1)/p^2$ grows without bound. The dial is a **bounded-fluctuation** feature riding on a diverging trend: a small, permanent wobble whose size does not wash out as the factor base grows.

### What a lift in $R^2$ actually measures

The experiment reports "$+0.176$". What does that number *mean*? Here the answer is pure linear algebra, and it is exact.

Suppose you have a baseline predictor $g$ for the target $y$, with residual $r = y - g$, and you augment your model by allowing an arbitrary multiple of a new feature $v$. Optimizing over the multiple $t$ is a one-dimensional projection, and the residual sum of squares drops by exactly $\langle r,v\rangle^2/\|v\|^2$. Dividing by the total sum of squares:

**Exact One-Feature Lift.** *Augmenting a fit by a single feature raises the coefficient of determination by exactly*
$$\Delta R^2 \;=\; \frac{\langle r, v\rangle^2}{\|v\|^2 \cdot \mathrm{TSS}} \;=\; \rho^2 \,\bigl(1 - R^2_{\text{before}}\bigr),$$
*where $\rho$ is the sample correlation between the baseline residual and the new feature.*

Three consequences fall out immediately. First, the lift is **at most** $1 - R^2_{\text{before}}$: a single feature can never explain more than what is left unexplained, and $R^2$ can never be pushed above $1$. Second, the lift is strictly positive **exactly when** the residual is non-orthogonal to the feature. Third — the contrapositive, and the one that matters scientifically — if augmenting produced no lift at all, the residual would have to be *exactly orthogonal* to the feature.

That last statement is the death certificate of the null hypothesis "the residual contains nothing systematic". A measured lift is not a fitting artefact; it is a certificate of correlation. And it is a *quantitative* certificate: running the identity backwards on the reported numbers, $0.176 = \rho^2(1 - 0.3927)$ pins the residual–feature correlation at $|\rho| \approx 0.539$. The unexplained part of the yield was, to that precision, aligned with the arithmetic of quadratic residues.

### Everything about the input, nothing about the answer

So we have a cheap, principled, genuinely predictive feature: one Euler test per odd prime up to the bound — seventy-seven of them at a bound of 400 — plus a modular count, and the yield model nearly doubles its explanatory power. The natural next thought is the exciting one. If the residues of $N$ modulo small primes carry real information, do they carry information about the *factorization* of $N$?

They do not. And this can be proved, unconditionally.

The argument has two halves that are best appreciated together. The first half is that the dial is *maximally informative about the residues*. Distinct patterns of active primes give distinct dial values — this follows from a pretty primorial argument: multiply the subset sum by $D = \prod_{p \le B} p$ and it becomes the integer $\sum_{p \in T} 2(D/p)$, whose divisibility by a base prime $p$ detects exactly whether $p \notin T$. Combined with a Chinese-remainder construction showing every pattern is realised by some $N$, this gives the **exact capacity**: the range of the dial has precisely $2^{|\text{base}|}$ elements. The dial carries exactly $|\text{base}|$ bits about $N$ — no more, and no fewer. It is a maximally efficient encoder of the input's residue signature.

The second half is that *those bits are all it has*. The dial is, by construction, a function of $N$ modulo the base primes and nothing else. Two moduli congruent to each other modulo the whole base share a dial value regardless of anything else about them. And by Dirichlet's theorem on primes in arithmetic progressions, every residue class coprime to the base contains arbitrarily large primes — and, with a little more work, arbitrarily large products of two primes.

**Blindness Theorem.** *Fix any classifier — any function whatsoever of the dial value — and any modulus $N$ coprime to the factor base. Then there exist arbitrarily large primes $q$ and arbitrarily large semiprimes $rs$ (with $r \ne s$ distinct primes) on which the classifier returns exactly the same verdict as it does on $N$.*

No test built on the footprint dial can distinguish a prime from a product of two primes, let alone locate a factor. Every dial value is shared by infinitely many numbers of every factorization type. The feature has full dynamic range, exact information capacity, and *zero factor information*: it knows everything about the sieve's input statistics and nothing about the answer the sieve is looking for.

### Why the negative result is the interesting one

It is tempting to read the blindness theorem as disappointing. It is the opposite: it is what makes the positive result trustworthy.

Machine-learned features in computational number theory are perpetually shadowed by the suspicion that a model is exploiting a leak — that it has, by accident, been shown a shadow of the answer. Here, that suspicion is settled by theorem rather than by argument. The dial is provably a function of the *method's input statistics*: it describes how the sieve's own machinery will behave on this input, and it is provably incapable of describing the input's arithmetic structure. The $+0.176$ is a real improvement in resource prediction, and it is guaranteed not to be a disguised factoring oracle.

That is a clean separation, and a useful template. It says: *calibrate freely on residue dials — they are cheap, exact, and safe — but do not expect them to become an attack.* The barrier is not a gap in a proof; it is a proof.

And the mathematics that emerges along the way stands on its own: the two-root slogan upgraded to an exact mean-footprint identity, Hensel lifting extending it verbatim to prime powers, exact independence of quadratic-residue indicators across the base, a closed-form variance $\sum (p^2-1)/p^4$ that converges while the mean diverges, an exact information capacity of $2^{|\text{base}|}$ values, and a projection identity that turns a reported $R^2$ gain into a measured correlation of $0.539$. A dial with a small, permanent, perfectly quantified wobble — that knows everything about nothing.
