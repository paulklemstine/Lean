# The Shape of a Wall: Why Every Classical Factoring Algorithm Fails in the Same Four Ways

## A number that guards the world

Take two prime numbers, each around six hundred digits long. Multiply them. The result, a number $N$ with roughly twelve hundred digits, is easy to write down and — as far as anyone knows — essentially impossible to take apart. That asymmetry is the load-bearing wall of the modern internet. It is why your bank's certificate means something, why a signed software update can be trusted, why a message can travel across a hostile network and arrive unread.

The wall is held up not by a theorem but by a failure. Nobody has proved that factoring is hard. What we have instead is a long and distinguished record of very clever people trying to make it easy and not succeeding. Every few years someone shaves a constant off the exponent; nobody has ever changed the exponent's *shape*.

This article is about a question that sits one level above "can you factor fast?" It is: **what would a fast classical factoring algorithm have to be made of?** Not what would it compute, but what raw ingredient — what *resource* — would it have to exploit? And the answer we can now state precisely is: *not any of the ingredients anyone has ever used*.

That is not a proof that factoring is hard. It is something more modest and, I think, more interesting: a rigorous map of the walls we know about, together with a theorem saying that a fast algorithm would have to walk through a part of the landscape where no wall has ever been surveyed — because nothing has ever been built there.

## The one move everybody makes

Start with what actually happens inside a factoring algorithm.

Suppose you want to factor $N$, and suppose — by whatever means — you manage to find two integers $x$ and $y$ such that
$$x^2 \equiv y^2 \pmod N,$$
while $x \not\equiv y$ and $x \not\equiv -y$ modulo $N$. Then $N$ divides $(x-y)(x+y)$ but divides neither factor separately. The divisibility has to be *split* between them, and computing $\gcd(x-y, N)$ recovers the split. Concretely:

> **Congruence-of-Squares Theorem.** Let $N > 1$ and let $x, y$ be integers with $N \mid (x-y)(x+y)$ but $N \nmid (x-y)$ and $N \nmid (x+y)$. Then $\gcd(x-y, N)$ is a divisor of $N$ strictly between $1$ and $N$.

The proof is three lines. If the gcd were $1$, then $x - y$ would be coprime to $N$, and $N \mid (x-y)(x+y)$ would force $N \mid (x+y)$ — excluded. If the gcd were $N$, then $N \mid (x-y)$ — also excluded. So the gcd is a proper nontrivial divisor.

And for the numbers that matter in cryptography — semiprimes $N = pq$ with $p, q$ prime — a nontrivial divisor is *everything*: any divisor other than $1$ and $pq$ is forced to equal $p$ or $q$. There is no partial credit and no partial progress; the moment you have the congruence, you have the factorization.

This single reduction is the skeleton of the continued fraction method, Dixon's random squares, the quadratic sieve, and the general number field sieve. It is also, remarkably, the skeleton of the *classical* half of Shor's quantum algorithm: if you know that $a$ has multiplicative order $2s$ modulo $N$, then $a^{2s} - 1 \equiv 0$, so $N$ divides $(a^s-1)(a^s+1)$, and provided $a^s \not\equiv \pm 1$ you are exactly in the situation above with $x = a^s$, $y = 1$.

The reduction is *free*. It costs one gcd, which is a few microseconds. And that is the crucial structural observation: **all of the difficulty of factoring is concentrated in producing the congruence, and none of it in exploiting the congruence.** Nobody is going to factor faster by finding a cleverer way to use $x^2 \equiv y^2$. The game is entirely about manufacturing that relation, and every classical method manufactures it by pouring in some *resource*.

## Four resources, four walls

Here is the census. Every general-purpose classical factoring method ever devised feeds one of four resources into the congruence-of-squares machine, and every one of them meets a documented running-time wall. Write $x = \log N$ for the bit-size parameter, the natural unit in which to measure these things.

**Randomness.** Pollard's rho method iterates a pseudorandom map and hunts for a collision modulo the unknown prime $p$. Its cost is $\Theta(N^{1/4})$, which in our units is $\exp(x/4)$.

**Smoothness.** The sieve family — continued fractions, quadratic sieve, number field sieve — collects integers whose prime factorizations use only small primes, then combines them by linear algebra over $\mathbb{F}_2$ into a square. The cost is subexponential, of the form
$$L_N[\alpha, c] = \exp\!\big(c\,(\log N)^{\alpha} (\log\log N)^{1-\alpha}\big),$$
with $\alpha = 1/2$ for the quadratic sieve and the record-holding $\alpha = 1/3$ for the number field sieve.

**Iteration and dynamics.** Williams' $p+1$ method and Lenstra's elliptic curve method walk trajectories in group structures attached to $N$ and hope a group order is smooth. Their cost is $L_p[1/2,\sqrt{2}]$ — subexponential, but in $\log p$ rather than $\log N$, which is what makes ECM the champion at pulling small factors out of big numbers.

**Analog and chaotic dynamics.** Continuous-time and chaotic-dynamics schemes have been proposed repeatedly. None obtains a structural advantage; they reproduce the sieve wall.

Four resources, four walls. And the first real theorem of this framework is that these are genuinely walls — that each barrier grows faster than every polynomial in the bit-size.

## The ladder

To say that precisely, we need a vocabulary of growth. Call a function $f$ **superpolynomial** if for *every* real exponent $d$, the ratio $f(x)/x^d$ tends to infinity — it eventually outgrows every polynomial, however steep. Call $f$ **subexponential** if for every $\varepsilon > 0$, the ratio $f(x)/e^{\varepsilon x}$ tends to zero — it is eventually crushed by every genuine exponential, however shallow. And call $f$ **polynomially bounded** if $f(x) \le Cx^d$ for some constants and all large $x$.

The engine driving everything is a single limit:

> **Stretched-Exponential Growth Theorem.** For any $c > 0$ and any $\alpha > 0$, the function $x \mapsto \exp(c\,x^{\alpha})$ is superpolynomial.

No matter how tiny the exponent $\alpha$ — you may take $\alpha = 1/1000$ — the function $\exp(c\,x^{\alpha})$ eventually leaves every polynomial behind. The proof is a change of variables: substituting $u = x^{\alpha}$ reduces the claim to the familiar fact that $e^{cu}/u^{d/\alpha} \to \infty$.

From this, everything about the sieve barrier follows. For $x \ge e$ we have $\log x \ge 1$, so $(\log x)^{1-\alpha} \ge 1$ whenever $\alpha \le 1$, and therefore
$$L[\alpha,c](x) = \exp\!\big(c\,x^{\alpha}(\log x)^{1-\alpha}\big) \ \ge\ \exp(c\,x^{\alpha}).$$
Domination transfers superpolynomiality upward, so:

> **Barrier Growth Theorem.** For $0 < \alpha \le 1$ and $c > 0$, the function $L[\alpha,c]$ is superpolynomial.

And the sieve barrier is not merely superpolynomial; it is genuinely *intermediate*. The key estimate is that $x^{\alpha}(\log x)^{1-\alpha} = o(x)$ when $\alpha < 1$ — which one sees by writing the ratio as $\big((\log x)/x\big)^{1-\alpha}$ and using $(\log x)/x \to 0$. Feeding that into the exponent:

> **Strict-Intermediacy Theorem.** For $0 < \alpha < 1$ and $c > 0$, the function $L[\alpha,c]$ is simultaneously superpolynomial and subexponential. It therefore occupies a rung of the growth ladder strictly above every polynomial and strictly below every exponential.

Meanwhile a genuine exponential $e^{bx}$ is *not* subexponential — test it against $\varepsilon = b/2$ and the ratio $e^{bx}/e^{bx/2} = e^{bx/2}$ blows up. So the randomness barrier $\exp(x/4)$ and the smoothness barrier $L[1/3,1]$ sit on visibly different rungs. The census records four genuinely distinct pieces of information, not one bound wearing four hats.

The payoff is a clean incompatibility: a superpolynomial function is never polynomially bounded. **Every one of the four classified barriers rules out polynomial time.**

## Why the exponent is $1/3$ and not something better

There is a suspicious pattern in the sieve running times: the exponents are $1/2$ and $1/3$, never $1/7$ or $0.29$. Why?

Model a sieve as a strategy that splits its work into $k$ exponential stages, with costs $e^{y_1}, \dots, e^{y_k}$, where the budget parameters obey a *multiplicative* constraint $y_1 y_2 \cdots y_k = x$. That constraint is the mathematical content of "making the smoothness bound smaller makes relation-collection proportionally harder." Then two applications of the arithmetic–geometric mean inequality give:

> **Multiplicative Trade-off Theorem.** For positive budgets $y_1,\dots,y_k$ with $\prod_i y_i = x$,
> $$\sum_{i=1}^{k} e^{y_i} \ \ge\ k\, \exp\!\big(x^{1/k}\big),$$
> and the bound is attained exactly at the balanced point $y_1 = \cdots = y_k = x^{1/k}$.

The first AM–GM says the arithmetic mean of the budgets is at least their geometric mean $x^{1/k}$; the second, applied to the costs, says the arithmetic mean of $e^{y_i}$ is at least $e^{(\sum y_i)/k}$. Chain them.

This reframes the exponent completely. The $1/k$ is not a parameter some algorithm designer chose well. It is *the balance point of a constraint*. Improving the exponent is not a matter of being cleverer within a fixed architecture — it is literally the same problem as adding another stage. And since $k\exp(x^{1/k})$ is superpolynomial for every fixed $k$, no bounded-arity trade-off strategy can ever run in polynomial time.

The framework then does something a less honest account would skip: it shows exactly where its own barrier ends. If the arity $k$ is allowed to *grow with the input*, the bound collapses. Choosing $k = \lceil \log x \rceil$ makes the balanced budget $x^{1/k} \le e$, so the total cost is at most $e^{e}(\log x + 1)$ — polynomial, indeed logarithmic, in $x$. The trade-off barrier is a theorem about *bounded* arity. Escaping it requires balancing unboundedly many stages at once, and no classical method supplies the structure to do that.

## The heuristic under the randomness barrier

The $N^{1/4}$ figure for Pollard rho deserves the same scrutiny, and it does not entirely survive. That number is a *birthday-paradox heuristic*: it assumes the iterates behave like uniform random residues modulo the unknown prime. Two unconditional facts sit underneath.

First, collisions are not one tactic among several — they are the whole method. If $a$ and $b$ are distinct modulo $p$ and distinct modulo $q$, then $\gcd(a-b, pq) = 1$, and the gcd step returns nothing at all. (Any prime dividing the gcd divides $pq$, hence equals $p$ or $q$, hence gives a collision.)

Second, and more pointedly: the arithmetic trajectory $x_i = i$ is *blind*. For $N = pq$ and any $K \le \min(p,q)$, every pair of distinct points $i \ne j$ among the first $K$ satisfies $\gcd(i-j, pq)=1$, simply because $0 < |i-j| < K \le \min(p,q)$ leaves no room for $p$ or $q$ to divide the difference. So a collision-based search can be made to waste $\min(p,q) \approx \sqrt{N}$ steps.

The honest conclusion: the *worst-case provable* wall for collision methods is $\sqrt{N}$, not $N^{1/4}$. The celebrated fourth root is an average-case phenomenon about random-looking trajectories, not a theorem about all of them.

## The one resource that gets through

Shor's algorithm gets through all four walls, and it is worth being exact about how. It does *not* find a better way to use a congruence of squares — we saw that step is free for everyone. It does not sieve, iterate, or gamble. It reads the *period* of the function $j \mapsto a^j \bmod N$ out of a Fourier transform.

Could a classical method do the same with only a few Fourier samples? No — and this is the sharpest, most model-independent statement in the whole framework.

> **Fourier Sample Lower Bound.** Let $r \ge 1$ and consider signals on $\mathbb{Z}/r\mathbb{Z}$ with complex values. Suppose a family of $K$ sample frequencies has the property that the discrete Fourier transform values at those $K$ frequencies determine the signal uniquely. Then $K \ge r$.

The reason is linear algebra of the most unforgiving kind. Fourier sampling at $K$ chosen frequencies is a linear map from an $r$-dimensional space to a $K$-dimensional space. If $K < r$ the map has a nontrivial kernel, so two *distinct* signals produce identical readings at every sampled frequency. No amount of ingenuity in choosing the frequencies helps; the obstruction is dimensional, not computational. And the bound is sharp: sampling all $r$ frequencies does determine the signal, since the transform is invertible.

So if you want to learn the period $r$ by sampling, you must pay $r$ samples — and $r$ is typically comparable to $N$. Quantum superposition is precisely the resource that supplies all $r$ amplitudes in one physical shot. That is the whole trick, stated as a resource claim rather than a slogan.

## The conditional, stated honestly

Now the pieces assemble. Abstract a classical factoring algorithm to its cost profile $C(x)$ as a function of the bit-size $x = \log N$, and say it is *limited by* a classified resource if its cost is eventually at least that resource's barrier.

> **Conditional Impossibility Theorem.** Suppose a classical algorithm factors semiprimes with cost polynomially bounded in $\log N$. Then for each of the four classified resources, the ratio (barrier)/(cost) tends to infinity; the algorithm is limited by none of the four barriers; and therefore the resource it exploits lies outside the set $\{\text{randomness},\ \text{smoothness},\ \text{iteration},\ \text{analog}\}$.

The proof is short once the ladder is in place. Polynomial boundedness gives $C(x) \le Cx^d$ for large $x$; superpolynomiality of the barrier gives $\mathrm{barrier}(x)/x^d \to \infty$; divide.

And here is the part that separates this from bluster. The statement "every classical algorithm is limited by one of the four barriers" — call it the *Classified Resource Hypothesis* — is a **hypothesis, not a theorem**. It is a claim about the unknown, and it is not proved. What is proved is the two-way relationship: the hypothesis implies no polynomial-time classical factoring exists, and conversely any polynomial-time classical factoring algorithm *falsifies* the hypothesis by exhibiting a genuinely novel resource.

The schema is also demonstrably non-vacuous, which matters — a conditional whose sides are empty is worthless. Both sides are inhabited: the abstract algorithm whose cost *is* a barrier uses a classified resource and is not polynomial; the cost profile $x \mapsto x^2$ is polynomial and uses no classified resource. The implication has real content and the two classes are genuinely disjoint.

## What this is, and what it isn't

This is not a proof that factoring is hard. Nobody has one, and this framework does not sneak one in.

What it is: a rigorous classification of what is *known*, plus an airtight logical consequence. Every classical resource anyone has brought to bear on factoring provably runs into a superpolynomial wall. The exponents in those walls are not design choices but balance points of multiplicative constraints. The sampling shortcut that would let a classical machine imitate Shor is blocked by a dimension count that no algorithm can argue with. Therefore, if a fast classical factoring algorithm exists, it is not a clever recombination of anything we have — it is made of something new.

There is a certain scientific dignity in a result shaped like that. It converts a vague intuition — "people have tried hard and failed" — into a precise statement about where the failure lives and what a success would have to look like. It tells the would-be breaker of RSA exactly what to bring: not a faster sieve, not a better random walk, not an analog computer, but a resource nobody has named. And it tells the rest of us that the wall, while not proven infinite, is at least fully surveyed on every side we have ever approached from.
