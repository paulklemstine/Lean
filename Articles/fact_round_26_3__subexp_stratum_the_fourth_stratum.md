# The Stratum That Refused to Be Measured

## A story about smooth numbers, a failed experiment, and the two theorems that came out of it

### Four floors of one building

If you want to break a large number into its prime factors, you have a menu of
algorithms, and the menu is organized into strata — floors of a building, each
one defined by how its cost grows.

On the ground floor live the polynomial-time methods: cost $N^{c}$ for some
fixed exponent $c$, where $N$ is the number you are factoring. Upstairs sit the
exponential methods: trial division, cost roughly $\sqrt{N}$, which is
$e^{\frac{1}{2}\log N}$ — exponential in the *number of digits*. Between these
extremes lies a strange intermediate floor, the one where the real workhorses
live: the quadratic sieve and the number field sieve. Their cost is neither
polynomial nor exponential in the digit count. It is
$$
L_N[1/2] \;=\; \exp\!\Big( (c + o(1))\sqrt{\log N \, \log\log N} \Big),
$$
the square root of the exponent — a genuinely intermediate growth rate that
number theorists call **sub-exponential**.

This article is about an attempt to *see* that fourth stratum experimentally, at
a scale small enough to run on a laptop; about the attempt's honest failure; and
about the two hard theorems that were extracted from the wreckage. One of them
explains why the folklore formula everyone quotes for smooth-number densities is
numerically worthless in exactly the range where small experiments live. The
other proves that the sub-exponential floor of the building really is a floor:
no tuning of the algorithm's one free parameter can get underneath it.

### Smooth numbers, and the function that counts them

Everything in the sieve family rests on one idea: **smooth numbers**. An integer
is called $B$-smooth if all of its prime factors are at most $B$. The quadratic
sieve works by hunting for values $x^2 - N$ that happen to be $B$-smooth for a
modest bound $B$; each such value becomes a relation, and enough relations
produce a factorization by linear algebra over $\mathbb{F}_2$.

So the whole cost analysis hinges on a single quantity: *how often is a random
number of size $X$ smooth with respect to $B$?* Set
$$
u \;=\; \frac{\log X}{\log B},
$$
the "smoothness depth": $u = 2$ means you want the prime factors below the square
root of $X$, $u = 5$ means below its fifth root, and so on. The classical answer
is that the probability is approximately $\rho(u)$, where $\rho$ is the
**Dickman function**, defined by the delay differential equation
$$
\rho(u) = 1 \ \ (0 \le u \le 1), \qquad u\,\rho'(u) = -\rho(u-1) \ \ (u > 1).
$$
Equivalently, and more usefully, $\rho$ satisfies the integral relation
$$
u\,\rho(u) \;=\; \int_{u-1}^{u} \rho(t)\,dt .
$$
There is no closed form for $\rho$ beyond the first couple of bands. On $(1,2]$
one finds $\rho(u) = 1 - \log u$; past $u = 2$ one must integrate numerically or
estimate.

The estimate everyone quotes is
$$
\rho(u) \;=\; \exp\!\big(-u(\log u + \log\log u - 1) + o(u)\big),
$$
usually abbreviated to $u^{-u}$ and used as though the $o(u)$ were negligible.
Substituting the surrogate $L(u) = \exp(-u(\log u + \log\log u - 1))$ into the
sieve's cost function is exactly how one derives the $L[1/2]$ running time in a
textbook.

### The experiment, and the null

The plan was simple. Take a composite $N$, sample $x$ uniformly in
$[\sqrt{N}, 2\sqrt{N}]$, factor $x^2 - N$ by trial division, record whether it
is $B$-smooth, and compare the empirical hit rate against $\rho(u)$ with
$u = \log(x^2 - N)/\log B$. Sweep $B$, sweep $N$, and watch the cost model
$$
C(B) \;=\; \frac{\pi(B)}{\rho(u)} + \pi(B)^2
$$
— relations needed divided by the probability of getting one, plus the linear
algebra — trace out the characteristic $L[1/2]$ curve as $N$ grows.

It did not work. With $2400$ samples over six $(N,B)$ cells, the ratios of
empirical density to predicted $\rho(u)$ came out as

| $u$ | samples | empirical | $\pm 1\sigma$ | $\rho(u)$ | ratio |
|---|---|---|---|---|---|
| $3.0$ | 161 | 0.0124 | 0.0087 | 0.0487 | 0.26 |
| $3.5$ | 265 | 0.0302 | 0.0105 | 0.0163 | 1.86 |
| $4.0$ | 413 | 0.0073 | 0.0042 | 0.0049 | 1.47 |
| $5.0$ | 303 | 0.0033 | 0.0033 | 0.00036 | 9.27 |

The ratios scatter between $0.26$ and $9.3$, non-monotonically. Most bins are
underpowered — the error bar is nearly $100\%$ of the estimate. Three bins sit
in a region where $\rho$ predicts a density below what a few hundred Monte Carlo
samples can resolve at all. And the fitted growth exponent of the cost model,
$d(\log_2 C)/d(\log_2 N) = 0.024$, is flat: at this scale the cost simply is not
growing, so there is nothing to fit a $\sqrt{\log N \log\log N}$ law to.

The verdict is an honest inconclusive: **the fourth stratum could not be
measured at toy scale.** But two things inside the null were solid enough to
turn into theorems, and they are what this article is really about.

## Finding one: the folklore formula is off by an order of magnitude

Evaluate the surrogate at $u = 3$. We have $\log 3 \approx 1.0986$ and
$\log\log 3 \approx 0.094$, so
$$
L(3) \;=\; \exp\!\big(-3(1.0986 + 0.094 - 1)\big) \;=\; \exp(-0.578) \;\approx\; 0.561 .
$$
The true value, obtained by integrating the delay equation, is
$\rho(3) \approx 0.0486$. The surrogate is **about twelve times too large**, and
the overshoot persists all the way through $u \approx 6$ — which is to say,
throughout the entire range that any small-scale experiment can reach.

This is not a subtlety. It means that any informal argument which manipulates
the leading-term formula below $u \approx 8$ and draws a quantitative conclusion
is meaningless. And it matters practically: a sieve designer who tunes the
factor base using $L(u)$ instead of $\rho(u)$ will believe relations are an
order of magnitude more plentiful than they are.

Can one *prove* the overshoot without ever constructing $\rho$? Yes, and the
trick is to stop asking for the function and ask only for an envelope. Call a
function $\rho$ a **Dickman majorant** if it is non-negative, equal to $1$ on
$[0,1]$, non-increasing on $[0,\infty)$, and satisfies the one-sided inequality
$$
u\,\rho(u) \;\le\; \int_{u-1}^{u}\rho(t)\,dt \qquad (u \ge 1).
$$
The true Dickman function is a majorant — it satisfies the last clause with
equality. So anything proved for all majorants is automatically true of $\rho$.
And the class is not empty in a vacuous sense: the indicator function of
$[0,1]$ is a member, with the inequality tight at $u = 1$.

From this one inequality everything follows by a two-line argument. Because
$\rho$ is non-increasing, the integral over $[u-1,u]$ is at most $\rho(u-1)$;
hence

> **Contraction Step.** Every Dickman majorant satisfies
> $\rho(u) \le \rho(u-1)/u$ for $u \ge 1$.

Iterating from $\rho(0) = 1$:

> **Factorial Tail Bound.** Every Dickman majorant satisfies
> $\rho(n) \le 1/n!$ at every integer $n$, and therefore
> $\rho(u) \le 1/\lfloor u \rfloor!$ for every real $u \ge 0$.

Now the overshoot becomes arithmetic. Starting from the exact band value
$\rho(2) = 1 - \log 2 \approx 0.3069$ and applying one contraction step,
$\rho(3) \le (1-\log 2)/3 \approx 0.1023$; one more gives
$\rho(4) \le (1-\log 2)/12 \approx 0.0256$. Meanwhile one can bound the
surrogate from below by elementary exponential estimates: $L(3) > 0.54$ and
$L(4) > 0.038$. Comparing:

> **Leading-Term Overshoot Theorem.** For every Dickman majorant with
> $\rho(2) \le 1 - \log 2$,
> $$ L(3) \;>\; 5\,\rho(3), \qquad L(4) \;>\; \rho(4). $$

The certified factor at $u=3$ is $5$ rather than the measured $12$ — the gap is
the slack in the crude tail bound, not in the phenomenon. The point stands: the
surrogate is not a usable numerical approximation in the small-$u$ regime.

And yet — and this is the pleasing twist — the *shape* encoded by the surrogate
is exactly right. The elementary Stirling-type inequality $n^n \le n!\,e^n$,
which follows by induction from $(1 + 1/n)^n \le e$, converts the factorial
bound into

> **Shape Theorem.** Every Dickman majorant satisfies, for $u \ge 1$,
> $$ \rho(u) \;\le\; \Big(\frac{e}{n}\Big)^{n} = \exp\big(-n(\log n - 1)\big), \qquad n = \lfloor u \rfloor . $$

So $u^{-u}$-type decay is genuinely correct; only the constant in front, and the
$\log\log u$ refinement, are being abused when one plugs in $u = 3$.

## Finding two: the floor of the fourth stratum, by proof

The experiment could not place the stratum. But the majorant class is strong
enough to place its *floor*.

Model a sieve on values of size $e^{L}$ with factor base cut at $B = e^{b}$. It
needs about $\pi(B) \approx e^{b}$ relations, and each trial succeeds with
probability about $\rho(u)$ where $u = L/b$. So the cost exponent is governed by
$$
C(b) \;=\; \frac{e^{b}}{\rho(L/b)} .
$$
Two forces pull against each other: enlarging the factor base makes relations
easier to find (good) but demands more of them (bad). The classical optimization
balances them at $b \approx \sqrt{L}$ and produces $L[1/2]$. Here is that
conclusion as a theorem, valid for every majorant and *every* $b$ — no
optimization, no asymptotics, no hidden constant:

> **Sub-Exponential Cost Floor.** Let $\rho$ be any Dickman majorant and let
> $0 < b \le L$ with $\rho(L/b) > 0$. Then
> $$ \frac{e^{b}}{\rho(L/b)} \;\ge\; \exp\!\big(2\sqrt{L \log 2} \;-\; 2\log 2\big). $$

The proof is a pleasing collision of two elementary facts. From the factorial
tail bound and $n! \ge 2^{\,n-1}$ we get $\rho(u) \le 2^{\,2-u}$, so the cost
exponent is at least $b + (u-2)\log 2$ with $u = L/b$. Then the
arithmetic–geometric mean inequality in the form $b + c/b \ge 2\sqrt{c}$, applied
with $c = L\log 2$, finishes it. The $\sqrt{L}$ in the exponent *is* the
$L[1/2]$ shape: with $L = \log N$ it reads $\exp(2\sqrt{\log N \log 2})$.

Spending the factorial on $2^{n-1}$ is wasteful, and the sharper bound
$n! \ge (n/e)^n$ improves the constant. The cost exponent becomes
$b + u(\log u - 1)$, whose infimum over $b$ has no closed form — but the
Legendre transform does: $u(\log u - 1) = \sup_{\ell}(\ell u - e^{\ell})$, so for
*every* $\ell \ge 0$ we get a closed-form floor,

> **Sharpened Floor.** For all $L > 0$, $b > 0$, $\ell \ge 0$,
> $$ b + \frac{L}{b}\Big(\log\frac{L}{b} - 1\Big) \;\ge\; 2\sqrt{\ell L} - e^{\ell}, $$
> and in particular, choosing $\ell = \tfrac12\log L$, for $L \ge 1$
> $$ b + \frac{L}{b}\Big(\log\frac{L}{b} - 1\Big) \;\ge\; \sqrt{2 L \log L} - \sqrt{L}. $$

That $\sqrt{2L\log L}$ is the genuine $L[1/2,\,c]$ shape with the correct
logarithmic factor — the same $\sqrt{\log N \log\log N}$ that appears in the
running time of the quadratic sieve, now derived from first principles as an
unconditional lower bound on the model, rather than measured.

## Finding three: sieve values are not random integers, and here is exactly how

The second surprise in the data was that even against a *correctly integrated*
$\rho$, the ratios refused to line up monotonically. The suspect is structural:
the numbers $x^2 - N$ are not random integers. A prime $p$ divides $x^2 - N$
only when $N$ is a quadratic residue mod $p$ — and then it divides for two values
of $x$ per period rather than one. Half the primes never appear at all; the
other half appear twice as often. On average that is the same as random, which
is exactly why averages cannot detect it.

So look past the average. Fix an odd prime $p$ and define the **hit pattern**
$$
h_p(a) \;=\; \#\{x \in \mathbb{Z}/p : x^2 = a\},
$$
the number of $x$ per period for which $p \mid x^2 - N$, when $N \equiv a$. The
elementary identity here is that $h_p(a) = \chi_p(a) + 1$, where $\chi_p$ is the
Legendre symbol: two roots for residues, none for non-residues, one for $a = 0$.

The "random integer" null model is the constant pattern $h \equiv 1$. Measure the
deviation.

> **Zero-Lag Dispersion Theorem.** For every odd prime $p$,
> $$ \sum_{a \bmod p} \big(h_p(a) - 1\big)^2 \;=\; p - 1, $$
> equivalently the mean square deviation from the random model is exactly
> $1 - 1/p$, which never drops below $1/2$ and increases to $1$.

The proof is one line once you know $h_p = \chi_p + 1$: the summand is
$\chi_p(a)^2$, which is $1$ for every $a \neq 0$ and $0$ at $a = 0$. Combined
with the first moment $\sum_a h_p(a) = p$ this gives
$\sum_a h_p(a)^2 = 2p - 1$.

This is the algebraic source of the scatter. The quadratic-sieve pool is
*maximally dispersed* relative to the random model, at every prime, for ever.
The $O(1)$ per-prime correction does not wash out as $p$ grows; it saturates at
$1$.

Now shift the pattern against itself and correlate. Surprise number two:

> **Pair-Correlation Theorem.** For every odd prime $p$ and every nonzero lag
> $c$,
> $$ \sum_{a \bmod p} h_p(a)\, h_p(a+c) \;=\; p - 1 $$
> — precisely the value the random model predicts.

The proof is a bijection. The left side counts pairs $(x,y)$ with
$y^2 - x^2 = c$. Factor: $(y-x)(y+x) = c$. Since $c \neq 0$ the difference
$v = y - x$ is a nonzero element, and given $v$ the pair is determined by
$y - x = v$, $y + x = c/v$, solvable uniquely because $2$ is invertible. So the
solutions are in bijection with the $p-1$ nonzero $v$, and the count is $p-1$
exactly — no error term, no Weil bound needed.

Putting the two together:

> **Autocorrelation Dichotomy.** For every odd prime $p$ and every nonzero lag
> $c$,
> $$ \sum_{a} h_p(a)^2 \;-\; \sum_{a} h_p(a)\,h_p(a+c) \;=\; p. $$

All of the pool's deviation from randomness lives at lag zero, and it is exactly
one full period's worth. Off the diagonal the sieve pool is
*indistinguishable* from random — perfectly so, with no error term. That is a
sharp and rather beautiful statement: the quadratic sieve's non-randomness is a
single spike, not a smear.

## What was learned, and what it cost

A ledger is part of the result. Three errors were made and caught. The first
design sampled $x$ from a narrow window, so that $x^2 - N$ had size on the order
of $N^{1/2}$, while $u$ was computed as though the values had size $N$ — every
bin was mis-assigned, and the tell was empirical densities sitting *above* the
prediction. A pre-written success verdict, drafted before the data existed, had
to be discarded and regenerated from the numbers. A syntax error in the analysis
script was caught by parsing the source before running it.

The landscape now stands at three measured strata plus one unmeasured. What the
failure bought is a shift in kind: two quantities that were going to be
*measured* are now *proved*. The folklore density formula is off by more than a
factor of five at $u = 3$ and still overshoots at $u = 4$, with the $u^{-u}$
shape nevertheless exactly right. The sub-exponential floor $\exp(2\sqrt{L\log
2} - 2\log 2)$, and its sharpening $\sqrt{2L\log L} - \sqrt{L}$, hold uniformly
over every choice of factor base. And the non-randomness of the sieve pool is
pinned down to a single lag with an exact identity at every prime.

A null result that converts two measurement targets into theorems is not a
failure of the experiment. It is what an honest experiment is for.
