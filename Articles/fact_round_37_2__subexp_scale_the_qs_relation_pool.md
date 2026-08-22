# The Sieve That Cheats — and the Two Twos That Cancel

## A suspicious approximation at the heart of factoring

Every time you buy something online, a large number gets factored — or rather, doesn't. The security of much of the world's public-key cryptography rests on a single stubborn fact: multiplying two large primes is easy, and undoing that multiplication is hard. How hard, exactly, is a question with a surprisingly delicate answer, and the best classical answers come from a family of algorithms called **sieves**.

The oldest and most transparent of them is the **quadratic sieve**. Its idea is beautifully simple. To factor a number $N$, you look for a *congruence of squares*: two numbers $X$ and $Y$ with
$$X^2 \equiv Y^2 \pmod N, \qquad X \not\equiv \pm Y \pmod N.$$
Then $N$ divides $(X-Y)(X+Y)$ without dividing either factor, so $\gcd(X-Y, N)$ is a nontrivial divisor of $N$ and you're done.

To manufacture such a congruence, the sieve considers the values
$$v(x) = x^2 - N$$
for $x$ just above $\sqrt{N}$, and hunts for those that are **$B$-smooth** — that is, whose prime factors are all at most some bound $B$. Each smooth value is a *relation*: a vector recording the parity of each prime's exponent. Collect enough relations and linear algebra over the two-element field $\mathbb{F}_2$ will find a subset whose product is a perfect square. Multiply the corresponding $x$'s and you have your $X$; take the square root of the product of the $v(x)$'s and you have your $Y$.

The whole running-time analysis of the sieve — the famous subexponential $\exp\big((1+o(1))\sqrt{\ln N \ln\ln N}\big)$ — hinges on one estimate: *how often is $x^2 - N$ smooth?* And here the standard analysis does something audacious. It says: **pretend $x^2 - N$ is a random integer of its size.**

This should make you uncomfortable. The values $x^2 - N$ are emphatically not random. They obey a rigid law.

## The constraint that looks fatal

Suppose an odd prime $p$ divides $x^2 - N$ for some integer $x$. Then $x^2 \equiv N \pmod p$, which says that $N$ is a **quadratic residue** modulo $p$ — a perfect square in the arithmetic mod $p$. And exactly half of the nonzero residues modulo $p$ are squares.

So, for a fixed $N$, roughly **half of the primes in your factor base are useless**. They can never divide any sieve value. Whole columns of your relation matrix are dead. A random integer of the same size faces no such restriction: any prime can divide it.

Half the primes gone. Surely the sieve values must be *less* smooth than random integers, and surely the standard analysis is over-optimistic?

That is the question this work settles. The answer, in one line: **no — and for an exact reason, not an approximate one.**

## The two twos

Look more carefully at what happens at a single admissible prime $p$, one for which $N$ *is* a square mod $p$. How often does $p$ divide $x^2 - N$ as $x$ runs through a full period of $p$ consecutive integers?

The condition is $x^2 \equiv N \pmod p$. If $x_0$ is one solution, then so is $-x_0$, and for odd $p$ with $N \not\equiv 0$ these are genuinely different. And there are no others: the polynomial $y^2 - N$ over the field $\mathbb{Z}/p$ has at most two roots. So an admissible prime divides the sieve values **twice per period**, whereas a random integer sequence is divisible by $p$ only *once* per period.

Now put the two facts side by side.

- Only $\tfrac{p-1}{2}$ of the $p-1$ nonzero residues of $N$ admit the prime $p$ at all: a factor $\tfrac12$.
- Each admissible residue is hit $2$ times per period instead of $1$: a factor $2$.

They cancel. Not approximately — *exactly*. This is the central theorem.

> **Theorem (Exact Random-Equivalence of the Relation Pool).** Let $p$ be an odd prime and let $r(a)$ denote the number of residues $x$ modulo $p$ with $x^2 \equiv a$. Then
> $$\sum_{a \bmod p} r(a) = p.$$
> Equivalently, if $A_p$ denotes the set of nonzero quadratic residues mod $p$, then $2\,|A_p| = p-1$, so $|A_p| = \tfrac{p-1}{2}$.

The sum on the left is the total number of local hits over a full period of moduli; dividing by the $p$ possible residues of $N$, the **average number of $x$ per period with $p \mid x^2-N$ is exactly $1$** — precisely the value for a random integer sequence, with no error term whatsoever.

The proof is a one-liner once you know the right identity: $r(a) = \chi(a) + 1$, where $\chi$ is the quadratic character (the function that is $+1$ on nonzero squares, $-1$ on non-squares, $0$ at zero). Summing, and using the classical fact that a nontrivial character sums to zero over the full group, gives $\sum_a r(a) = 0 + p = p$.

## Why it isn't a coincidence

An exact cancellation of two factors of $2$ demands an explanation. Here is one, and it is the most satisfying part of the story: **the two twos are literally the same two.**

Consider the squaring map on the multiplicative group of nonzero residues mod $p$, $u \mapsto u^2$. It is a group homomorphism, and its kernel is
$$\{u : u^2 = 1\} = \{1, -1\},$$
a group of order exactly $2$ (for odd $p$, since $1 \neq -1$ there).

Now the two effects are the two halves of the first isomorphism theorem:

- **The doubled hit density is the kernel.** Every fibre of the squaring map — the set of square roots of a given nonzero $a$ — is a coset of the kernel: if $x^2 = a$ then the full solution set is exactly $\{x, -x\}$. So each admissible residue is hit $|\{\pm 1\}| = 2$ times.
- **The lost half is the index of the image.** The image of the squaring map is the set of nonzero quadratic residues, and by the first isomorphism theorem it has index $|\ker| = 2$ in the group. So exactly half of the residues are admissible.

Multiply and you get the orbit–stabiliser identity
$$|\ker| \cdot |A_p| = |(\mathbb{Z}/p)^\times| = p-1.$$
The quadratic-character constraint and the doubled hit density are two faces of a *single* $\mathbb{Z}/2$ symmetry — the symmetry $x \mapsto -x$ of the sieve polynomial $x^2 - N$. That symmetry costs you a factor of two in which primes are usable and refunds you the same factor of two in how often the usable ones fire. **No amount of extra scale can create a discrepancy, because the cancellation is an identity, not an asymptotic.**

## Nothing special about squares

Is the quadratic sieve peculiarly lucky? It is not. Strip the statement to its combinatorial skeleton and the phenomenon becomes universal.

> **Theorem (Universality of the Average Hit Count).** Let $f : \mathcal{A} \to \mathcal{B}$ be *any* map between finite sets — any sieve polynomial, any degree, any modulus. Then
> $$\sum_{b \in \mathcal{B}} \#\{a \in \mathcal{A} : f(a) = b\} = |\mathcal{A}|.$$
> Hence the mean number of hits per target is exactly $|\mathcal{A}|/|\mathcal{B}|$, the random-model prediction.

The proof is nothing more than partitioning the domain into fibres. But the consequence is sharp: **averaged over the target, no sieve polynomial can beat, or lose to, a random pool.** All a polynomial can control is the *distribution* of the hit count across targets, not its mean.

And here is the companion result, which says exactly when a pool is random target-by-target and not merely on average:

> **Theorem (Pointwise Uniformity Equals Bijectivity).** For $f : \mathcal{A} \to \mathcal{B}$, every target is hit exactly once if and only if $f$ is a bijection.

Squaring mod an odd prime is not a bijection — $x$ and $-x$ collide — so the quadratic sieve's per-prime hit count is *never* the constant $1$. It is the $2$-or-$0$ dichotomy we met above. That dichotomy is what "a quadratic-character constraint" looks like from the combinatorial side. It is real, it is visible, and it averages away perfectly.

The moral for anyone trying to detect non-randomness in a sieve pool: **stop looking at one prime at a time.** Single-prime statistics are pinned by these identities and can never distinguish a sieve pool from a random pool. Any genuine deviation must be a *correlation between distinct primes* at one fixed $N$.

## What the measurements say

Theory in hand, one can go and look. A large-scale computation — $1.2$ million smoothness tests, with $N$ ranging over $2^{32}$ to $2^{44}$, each sieve pool matched against a size-matched control pool of genuinely random integers — produced two clean findings.

**First: the pool is random.** The ratio of the smooth-density gap between $x^2 - N$ and the random control came out at $1.00$ at every scale tested, in the narrow band $0.993$–$1.020$. The quadratic-character constraint is invisible to order $O(1)$ at every reachable scale, exactly as the cancellation identity demands. (An earlier, smaller study had reported wild non-monotone scatter and concluded that $x^2 - N$ is *not* random-equivalent; that conclusion was an artefact of binning by the size of $N$ rather than by the size of the individual values, combined with too few samples.)

**Second: both pools miss the textbook prediction — together.** Compare the measured smooth density against the Dickman prediction $\rho(u)$, where $u = \ln v / \ln B$ is the "size in factor-base units" of the value $v$ being tested. The empirical-to-predicted ratio sits at $0.877$–$0.913$ at every scale. But — and this is the point — *the random control misses by exactly the same amount*. It is not a property of $x^2-N$ at all. It is the finite-size correction to the Dickman model itself.

## The slow convergence of a famous function

The Dickman function $\rho(u)$ is the standard model for smoothness: it is the limiting probability that a random integer of size $x$ has no prime factor exceeding $x^{1/u}$. It is defined by a delay differential equation,
$$u\,\rho'(u) = -\rho(u-1), \qquad \rho(u) = 1 \text{ for } 0 \le u \le 1,$$
and on the first nontrivial interval it has an exact closed form:
$$\rho(u) = 1 - \ln u \qquad (1 \le u \le 2).$$
One checks immediately that this satisfies the equation: $u\rho'(u) = u \cdot (-1/u) = -1 = -\rho(u-1)$, since $\rho \equiv 1$ on $[0,1]$. And it is genuinely a probability there: $\rho(u) < 1$ for $u > 1$, and $\rho(u) > 0$ for $u \le 2$ because $\ln 2 < 1$.

In asymptotic analyses of factoring, however, nobody uses $\rho$; everybody uses its leading term,
$$L(u) = \exp\big(-u(\ln u + \ln\ln u - 1)\big).$$
This is where the trouble starts. $L$ is a superb approximation to $\rho$ — as $u \to \infty$. At the values of $u$ any real computation reaches, it is a catastrophe.

> **Theorem (The Leading Term Is Not a Probability at Small $u$).** For $1 < u \le 2$ one has $\rho(u) < 1 < L(u)$.

The reason is charmingly elementary. On $(1,2]$ we have $0 < \ln u \le \ln 2 < 1$, so $\ln\ln u < 0$; and the classical inequality $\ln t \le t-1$ applied to $t = \ln u$ gives $\ln\ln u \le \ln u - 1$. Hence $\ln u + \ln\ln u - 1 \le 2\ln u - 2 < 0$, the exponent $-u(\ln u + \ln\ln u - 1)$ is *positive*, and $L(u) > e^0 = 1$. A quantity that exceeds $1$ is not an approximation to a probability; it is not even in the right universe.

How badly wrong? Quantitatively:

> **Theorem (Ninefold Overshoot at $u = 2$).** $L(2) > 9\,\rho(2)$.

Here $\rho(2) = 1 - \ln 2 \approx 0.3069$, while $L(2) = \exp\big(-2(\ln 2 + \ln\ln 2 - 1)\big) \approx 3.845$ — a ratio of about $12.5$. The leading term is off by more than an order of magnitude at the most common operating point of a toy-scale sieve.

Only from $u = 3$ onwards does $L$ even become a legal probability:

> **Theorem (Admissibility Threshold).** For $u \ge 3$, $L(u) < 1$.

The proof is the mirror image: at $u \ge 3$, $\ln u > 1$, so $\ln\ln u \ge 0$ and the exponent flips sign.

But "legal" is not "accurate", and the truth is stranger still: the overshoot factor $L(u)/\rho(u)$ does not shrink with $u$ — it *grows without bound*. It is $12.5$ at $u = 2$, dips to $11.5$ near $u = 3$, then climbs: $19.0$ at $u = 10$, $31.0$ at $u = 14.75$, $601.8$ at $u = 40$. As an estimate of a probability, the leading term never becomes usable at all. What *does* converge is the exponent — the asymptotic statement is really about $\ln\rho$ — and there the relative error falls from $214\%$ at $u = 2$ to $9.9\%$ at $u = 12$ and $8.0\%$ at $u = 14.75$. Even in that weak sense the honest threshold is $u \approx 12$, far beyond anything a realistic sieve visits.

## Why the gap closes, but glacially

That leaves the $0.877$–$0.913$ deficit of both pools against $\rho(u)$ itself. Its source is the finite-size correction: the Dickman model is an asymptotic statement about integers of unbounded size, and at finite value size $v$ the leading correction has relative size
$$c(v) = \frac{\ln\ln v}{\ln v}.$$
Two facts about $c$ tell the whole story.

> **Theorem (Monotone Decay).** $c(v) = \ln\ln v/\ln v$ is decreasing for $v \ge e^{e}$, and $c(v) \to 0$ as $v \to \infty$.

So **nothing blocks convergence.** The Dickman model is asymptotically correct; the deficit is not a barrier, not a structural obstruction, not a property of $x^2-N$. It simply vanishes — eventually.

> **Theorem (The Experimental Window).** For $e^{12} \le v \le e^{20}$ — the range of value sizes sieved when $N$ runs from $2^{32}$ to $2^{44}$ — the correction satisfies $0.1 \le c(v) \le 0.25$.

That bracket contains the measured $17$–$20\%$ shortfall exactly. The observed deficit is not a mystery; it is the finite-size term, arriving right on schedule and at the right magnitude.

And "eventually" is the operative word: $c$ decays like $\ln\ln v/\ln v$, so doubling the bit-length of $N$ improves the ratio by a couple of percent, not a couple of factors. Over the twelve bits of scale explored, the ratio crept up by about $2.6\%$ relative. The convergence is real and it is logarithmic — which is to say, for practical purposes, it is not going to happen. **The correct toy-scale smoothness model is not $\rho(u)$; it is $\rho(u)$ times $0.88$–$0.91$.**

## The constraint pays a dividend elsewhere

If the quadratic-character constraint costs nothing in smoothness, does it do anything at all? Yes — and the direction is favourable.

Because every prime dividing a smooth value $x^2 - N$ must be admissible, the exponent vectors of the relations do not live in the full space $\mathbb{F}_2^{\pi(B)}$ indexed by all primes up to $B$. They live in the subspace indexed only by the *admissible* primes — about half as many.

> **Theorem (Congruence of Squares from Half a Factor Base).** Let $A$ be the set of primes $p \le B$ for which $N$ is a quadratic residue mod $p$. Given more than $|A|$ nonzero $B$-smooth values $x_i^2 - N$, some nonempty sub-collection has a perfect-square product.

The proof is the linear-algebra step of the sieve, made exact: assign each value its exponent-parity vector in $\mathbb{F}_2^{A}$; more than $|A|$ vectors in an $|A|$-dimensional space must be linearly dependent; a dependency is a nonempty subset whose exponents all sum to even, and a positive integer with all exponents even is a perfect square.

So the constraint that looked like a liability is a genuine asset: it **halves the number of relations you must collect** before the linear algebra can bite. It costs nothing on the input side and saves a factor of two on the output side.

## And why the sieve is subexponential at all

One last unconditional fact anchors the whole picture, and it explains why the factor base cannot simply be held fixed and small.

> **Theorem (Sparsity of the Smooth Pool).** The number of $B$-smooth integers in $[1, x]$ is at most $(\lfloor \log_2 x\rfloor + 1)^{\pi(B)}$, where $\pi(B)$ counts the primes up to $B$.

The proof is an injection: a $B$-smooth number is *determined* by its vector of prime exponents, each exponent is at most $\log_2 x$, and there are $\pi(B)$ of them. No heuristics, no Dickman — just counting.

The consequence is decisive. For a *fixed* factor base the smooth pool grows only polylogarithmically in $x$: sieve as far as you like and you find essentially nothing. The bound forces $B \to \infty$ together with $x$, and optimising that trade-off — larger $B$ makes values likelier to be smooth but demands more relations — is precisely what produces the subexponential running time.

## What has been settled

Put together, the picture is unusually clean.

The input statistics of the quadratic sieve are **measured and understood**. The relation pool is random-equivalent — exactly, at every prime, for a structural reason that no increase in scale can perturb. The observed discrepancy from the textbook Dickman prediction is real but is shared identically by a random control, and is exactly the finite-size correction of the model, of size $\ln\ln v / \ln v \approx 17$–$20\%$ in the accessible range, shrinking only logarithmically. The leading-term Dickman formula, ubiquitous in the literature, is not even a probability below $u = 3$, overshoots the true value by a factor that grows without bound, and captures the exponent to within ten percent only from $u \approx 12$.

What remains unmeasured is therefore something quite specific: the sieve's *algorithmic* advantage — the fact that it finds its smooth values by an efficient sieving procedure rather than by trial division — and any *cross-prime correlation* in the pool at fixed $N$. The universality theorem is what makes this sharp: since one-prime statistics are pinned to the random value by an identity, correlation across primes is the only remaining place where the quadratic sieve could differ from a bag of random integers.

There is a broader lesson here for anyone who models an arithmetic object as random. "This sequence is constrained, therefore it is less random" is a tempting inference and a frequently false one. Constraints come in pairs: a symmetry that forbids something usually compensates by making what remains more likely. When the symmetry is a group — here, the two-element group $\{\pm 1\}$ — the compensation is governed by the orbit–stabiliser theorem, and the bookkeeping comes out exactly even. The sieve does not cheat the random model. It obeys it, precisely, for reasons written into the group theory of squaring.
