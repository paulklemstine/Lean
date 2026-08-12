# Eight Walls Around a Secret: Why Every "Clever Formula" for Factoring Fails

## A number that keeps its secret

Take two prime numbers, multiply them, and publish the product. That is the whole
of the trick on which a large part of digital security rests. If $p = 3$ and
$q = 5$, the product $N = 15$ tells you nothing you did not already know. But if
$p$ and $q$ each have three hundred digits, the product $N$ is a six-hundred-digit
number that, so far as anyone can prove, guards its two factors as well as a
locked safe.

The strange thing is that the secret is not really hidden. Everything about $p$
is written into $N$. The smaller prime factor is a perfectly well-defined
function of $N$ alone: trial-divide by $2, 3, 5, 7, \dots$ and stop at the first
success. There is nothing missing, nothing lost, no information-theoretic veil.
The difficulty is entirely one of *shape*: we do not know a formula of the right
kind. And so, for fifty years, people have gone looking for one.

This article is about a systematic answer to that search — a framework of
**eight structural barriers** that explains, with proofs rather than folklore,
why whole families of "clever formulas" cannot work, and why the ones that
*could* work turn out to be factoring algorithms wearing a disguise.

## The shape of the search

Imagine you are hunting for a formula. You would like a function $f$ such that
$f(N) = p$ whenever $N = pq$ is a product of two distinct primes with $p < q$.
You are allowed to be creative. Try a polynomial. Try a ratio of polynomials.
Try an analytic function evaluated at $1/N$. Try one of the classical
number-theoretic invariants: the number of divisors $\tau(N)$, the sum of
divisors $\sigma(N)$, Euler's totient $\varphi(N)$, the Möbius value $\mu(N)$.
Try a hundred such quantities at once, fed into a neural network. Try an
adaptive procedure that computes one quantity, branches on the answer, computes
another, and finally guesses.

Every one of these strategies has been tried, in this project across hundreds of
computational experiments, and every one of them has failed in the *same way*.
The eight barriers are the theorems that say the failure was inevitable.

## Barrier one: polynomials are too rigid

Suppose $P$ is a polynomial with rational coefficients and $P(pq) = p$ for every
semiprime. Freeze the small factor at $p = 3$. Then
$$P(3q) = 3 \qquad \text{for every prime } q > 3.$$
There are infinitely many such primes, so the polynomial $P(X) - 3$ has
infinitely many roots. A nonzero polynomial has only finitely many roots, so
$P(X) - 3$ is identically zero: $P$ is the constant $3$. Now take $p = 5$,
$q = 7$, $N = 35$. Our constant says $P(35) = 3$, the requirement says
$P(35) = 5$. Contradiction. **No polynomial computes the smaller prime factor.**

The argument is three lines long, and it is astonishingly robust. Replace $P$ by
a ratio $A(X)/B(X)$ of polynomials — "escape into rational functions" — and the
same freeze-and-count argument kills $A - 3B$ instead. *Rational escape is
illusory.* Better: drop the requirement that $p$ be given by a formula at all,
and ask only that $p$ and $N$ satisfy *some* algebraic relation
$$F(N, p) = 0$$
for a nonzero two-variable polynomial $F$ with rational coefficients. Freezing
$p$ shows that each specialization $F(X, p)$ vanishes identically; then, viewing
$F$ as a polynomial in its second variable over the ring of polynomials in the
first, the infinitely many primes $p$ are infinitely many roots, so $F$ itself is
zero. **The smaller prime factor satisfies no algebraic relation whatsoever with
the modulus.** Not degree one, not degree two, not degree a million.

## Barrier two: how often can a formula get lucky?

"No formula works always" is a weak statement if a formula could work
$99.99\%$ of the time. So the framework sharpens it into a count.

Fix a polynomial $P$ of degree $d$ and fix the small factor $p$. The primes $q$
for which $P(pq) = p$ correspond to distinct roots of the nonzero polynomial
$P - p$, and there are at most $d$ of them. Now sum over $p$: in a semiprime
$N = pq \le X$ the smaller factor satisfies $p \le \sqrt{X}$, so the number of
semiprimes below $X$ that a fixed degree-$d$ polynomial factors correctly is at
most
$$d \cdot \pi(\sqrt{X}) \;\le\; d\,(\sqrt{X} + 1).$$
Against this stands a population of roughly $X \log\log X / \log X$ semiprimes
below $X$. A fixed formula does not merely fail eventually; its success set has
density zero, and vanishes like $X^{-1/2}$. The same bound, with degree
$\deg A + \deg B$, holds for rational functions.

## Barrier three: analysis does not help either

Polynomials are rigid because a nonzero one has finitely many roots. Analytic
functions are rigid for a deeper reason: the identity theorem. So one might hope
that analysis, being more flexible than algebra, offers an escape.

It does not, and the reason is beautiful. Look at the *reciprocals*. Ask for an
analytic function $f$ with
$$f\!\left(\tfrac{1}{N}\right) = \frac{1}{p} \qquad \text{for every semiprime } N = pq .$$
Freeze $p = 3$ again. The points $1/(3q)$, as $q$ runs over the primes,
accumulate at $0$ — they crowd in on the origin, and $f$ takes the same value
$1/3$ at all of them. An analytic function that repeats a value on a sequence
converging to a point of its domain is constant. So $f \equiv 1/3$; and then
$p = 5$ contradicts it.

The barrier survives the removal of analyticity at the origin. If $f$ merely has
an isolated, non-essential singularity at $0$ — if it is *meromorphic* there,
which covers every entire function, every rational function, every function with
a pole of finite order — the same conclusion holds. Near an isolated singularity
a meromorphic function either vanishes on a whole punctured neighbourhood or is
nonzero throughout one; the semiprimes $3q$ force the first alternative for
$f - 1/3$, and the semiprimes $5q$ then contradict it. Only the two families
$p = 3$ and $p = 5$ are used: the barrier applies even to a function that is
only asked to work for these two small primes.

## Barrier four: the symmetry that hides the factors

Now change tack. Instead of a formula for $p$, compute *invariants* of $N$ and
hope one of them is informative. The most natural invariants of a factor pair
are the power sums $p^k + q^k$. Here is Newton's recursion: setting
$s = p + q$ and $N = pq$,
$$T_0 = 2, \quad T_1 = s, \quad T_{k+2} = s\,T_{k+1} - N\,T_k ,$$
and $T_k = p^k + q^k$ for all $k$. Read the recursion carefully: it mentions
only $s$ and $N$. It never touches $p$ and $q$ individually. Consequently, any
two factor pairs with the same sum and the same product are **indistinguishable
by every power-sum invariant at once**. The invariants see through a filter that
only passes symmetric functions, and $p$ is not symmetric.

## Barrier five: circularity, the trap at the other end

So make an invariant that *does* break the symmetry — one that reveals $s = p+q$
along with $N = pq$. Surely that is progress?

It is total victory, and that is precisely the problem. From $s$ and $N$ the
factors fall out in closed form:
$$s^2 - 4N = (q - p)^2, \qquad p = \frac{s - \sqrt{s^2-4N}}{2}, \qquad
q = \frac{s + \sqrt{s^2-4N}}{2} .$$
So an invariant strong enough to break the symmetry barrier *is already a
factoring algorithm*. And the classical invariants that reveal $s$ do so
transparently: for a semiprime,
$$\sigma(N) = N + 1 + s, \qquad \varphi(N) = N + 1 - s .$$
Computing the sum of divisors of a semiprime, or its Euler totient, is exactly
as hard as factoring it. This is **computational circularity**: the route from
$N$ to $p$ through such an invariant is a loop that passes through the answer.

The two traps — symmetry and circularity — are the two sides of a genuine
dichotomy. Among the classical multiplicative invariants, the number of divisors
is always $4$, the number of distinct prime factors is always $2$, and the
Möbius value is always $1$: literally constant on semiprimes, therefore useless.
The sum of divisors and the totient hand over $s$: therefore circular. There is
no third option. **Every classical multiplicative invariant of a semiprime is
either blind or omniscient.**

Remarkably, that dichotomy holds in every degree. Take *any* polynomial $F$ with
integer coefficients and form the multiplicative invariant $F(p)F(q)$. Divide
$F$ by $X^2 - sX + N$ — the minimal polynomial of the unknown factor pair —
treating $s$ and $N$ as formal symbols. The remainder is $BX + A$ with $A, B$
polynomials in $s$ and $N$, and then
$$F(p)\,F(q) \;=\; A^2 + ABs + B^2N \;=:\; \Psi_F(s, N),$$
a single universal quadratic form, computable from $N$ without knowing anything
about the factors, of degree at most $2\deg F$ in $s$. Fix $N$ and let
$\psi(s) = \Psi_F(s,N)$. Either $\psi$ is constant, and then $F(p)F(q)$ takes the
very same value for *every* factorization of $N$ — blindness in the strongest
form — or $\psi$ is nonconstant, in which case the observed value $T$ makes
$s$ a root of $\psi - T$, of degree at most $2\deg F$: at most $2\deg F$
candidate sums, each of which yields the factorization in closed form.
Omniscience. Nothing in between, at any degree.

## Barrier six: old methods in new clothes

Some proposals return not a factor but a *representation*: "my method writes
$N$ as a difference of two squares". For odd $N$ this is not a new idea; it is
Fermat's, from 1643. The equivalence is exact: for odd $N$, producing integers
$a > b + 1 \ge 1$ with $N = a^2 - b^2$ is the same thing as producing a
nontrivial factorization $N = uv$ with $1 < u \le v$, because
$$a^2 - b^2 = (a-b)(a+b), \qquad
u\,v = \left(\tfrac{u+v}{2}\right)^2 - \left(\tfrac{v-u}{2}\right)^2$$
and oddness makes the halves integral. Any method whose output is a difference
of squares is Fermat's method in disguise; its novelty must be argued at the
level of running time, not of structure.

## The core: structural orthogonality

The barriers above each rule out a class of formulas. The last and most general
result rules out something much bigger — every *statistical* strategy — and it is
a theorem of elementary probability with nothing arithmetic in it at all.

Here is the experimental protocol it formalizes, called the **near-equal-$N$
test**. Collect a large population of semiprimes. Group them into narrow size
bands (in practice, by the value of $\lfloor N/40 \rfloor$). Within a band, all
the moduli are essentially the same size, but the hidden factors vary wildly:
one $N$ might be $\text{small}\times\text{huge}$, its neighbour
$\text{medium}\times\text{medium}$. Now take your favourite invariant, compute
it across the band, and measure its correlation with the hidden factor $p$. If
the invariant is worth anything, that correlation should be nonzero.

Applied to $284$ invariants drawn from more than sixty paradigms, the measured
correlation was zero every time. The theorem says it had to be.

Model the situation abstractly. Let $\Omega$ be a finite population, let each
member $i$ carry a **band label** $n(i)$, and let $Y(i)$ be the hidden target.
An invariant *computable from $N$ alone* is exactly a function of the band label:
a quantity of the form $g(n(i))$. Write $E[Y \mid n](i)$ for the average of $Y$
over the band containing $i$. Then:

> **Structural Orthogonality Theorem.** For every function $g$ whatsoever,
> $$\sum_{i \in \Omega} g(n(i))\,\bigl(Y(i) - E[Y\mid n](i)\bigr) \;=\; 0 .$$

The proof is a single regrouping: sum band by band; inside a band $g \circ n$ is
a constant and can be pulled out; and the residual $Y - E[Y\mid n]$ sums to zero
inside each band by the definition of the average. That is the whole argument,
and it is airtight.

Its consequences are sweeping.

*All correlation is band correlation.* The covariance of any $N$-only invariant
with the target equals its covariance with the *band means* of the target:
$\operatorname{cov}(g \circ n, Y) = \operatorname{cov}(g \circ n, E[Y\mid n])$.
If the band means are constant — the situation the near-equal-$N$ protocol is
designed to create — the covariance, and hence the correlation, is exactly zero.

*Nothing predicts better than the band mean.* For every $g$,
$$\sum_{i}\bigl(g(n(i)) - Y(i)\bigr)^2
= \sum_i \bigl(g(n(i)) - E[Y\mid n](i)\bigr)^2 + \sum_i \bigl(E[Y\mid n](i) - Y(i)\bigr)^2 .$$
The second term is fixed; the first is a non-negative penalty. The band mean is
the best $N$-only predictor there is, and every other invariant pays exactly its
squared deviation from it.

*Pooling free witnesses is free of information.* Combine any finite collection
of $N$-only invariants by *any* rule, however nonlinear — a neural network, a
gradient-boosted forest, a hand-tuned heuristic. The result is still a function
of the band label, so it is still governed by the same theorem. Aggregation
cannot manufacture information that no ingredient possesses.

*The band-spread law.* Without any hypothesis at all, Cauchy–Schwarz gives
$$\bigl|\operatorname{corr}(g\circ n, Y)\bigr| \;\le\;
\sqrt{\frac{\operatorname{Var}\bigl(E[Y\mid n]\bigr)}{\operatorname{Var}(Y)}} .$$
The entire empirical programme therefore collapses to one number: the *spread of
the band means*. If the band means vary by at most an $\varepsilon$ fraction of
the total variance, then every $N$-only invariant — linear or not, single or
aggregated — has correlation at most $\sqrt{\varepsilon}$. This is not a
heuristic; it is a uniform bound over all invariants simultaneously, and it is
exactly why every experiment came back reading zero.

## Adaptivity, randomness, and the collapse of depth

Three natural escape routes remain, and all three are closed.

**Adaptivity.** Run a test, branch on the outcome, run another test, branch
again, finally output a guess. Formalize this as a decision tree whose internal
tests and whose leaf outputs are all computable from the band label. A short
structural induction shows the whole tree's output is itself band-computable —
and so the barrier applies verbatim, *for any depth and any branching pattern*.

**Randomness.** Take a probability mixture of strategies. An exact
bias–variance identity says the expected squared error of the mixture equals the
error of its *mean* predictor plus a strictly positive randomization variance,
unless all strategies with positive weight agree pointwise. Randomizing never
helps and usually hurts, and the mixture's mean predictor is band-computable, so
it too is dominated by the band mean. Equality holds exactly for the degenerate
mixtures in which every strategy already *is* the band mean.

**Depth.** Finally, a quantitative sharpening. If a strategy can emit only
finitely many distinct values $V$ — as any tree of bounded size must, with
$|V| \le \text{size} + 1$ — then on top of the irreducible error it also pays a
**quantization error**
$$\sum_{i \in \Omega} \min_{v \in V} \bigl(v - E[Y\mid n](i)\bigr)^2 ,$$
which is strictly positive as soon as one band mean is not in the palette. Every
strategy with the same palette obeys the *same* lower bound, whatever its size.
Growing the search tree past the point at which its values are realized buys
literally nothing. Depth confers no advantage.

## Where the walls end

A framework is only trustworthy if it also says what it does *not* prove, and
this one is explicit on three points.

First, **the barriers are not information-theoretic**. The smaller prime factor
really is a function of $N$ alone — trial division computes it. So "any
computable function of $N$ alone is $N$-only" must be read structurally: what is
excluded are specific, richly structured classes of such functions (polynomial,
rational, meromorphic, symmetric, band-measurable), not the existence of a
function.

Second, **the near-equal-$N$ test needs genuinely coarse bands**. If the band
label separates the population — one semiprime per band — then the band mean
reproduces the target exactly, the residual vanishes, and the test says nothing.
The protocol's power comes entirely from the coarseness of $\lfloor N/40 \rfloor$.

Third, **the constant-band-mean hypothesis is necessary**, not decorative. On
the two-point population $\{6, 15\}$, with the target being the smaller factor,
an $N$-only invariant has covariance $9/4$ with the target — comfortably nonzero.
Zero correlation is a consequence of the protocol, not a law of nature.

## What it all adds up to

Put the pieces together and a picture emerges that is sharper than the usual
shrug of "factoring seems hard". Any classical proposal for factoring must
compute *something* from $N$. If that something is algebraic, the polynomial,
rational and algebraic barriers apply, and the counting barrier says success is
vanishingly rare. If it is analytic, meromorphic rigidity applies. If it is a
multiplicative invariant, the dichotomy applies: constant, hence blind, or
sum-revealing, hence circular. If it is a difference-of-squares representation,
it is Fermat's. If it is statistical — a witness, a battery of witnesses, an
adaptive tree, a randomized ensemble, a learned model — structural orthogonality
applies, and the band mean bounds it from below.

That is the content of the eight barriers, and it is why the honest state of the
art has not moved. The best known classical factoring algorithm, the general
number field sieve, still runs in time
$$L_N\!\left[\tfrac13,\; \sqrt[3]{64/9}\right]
= \exp\!\Bigl( (1.923\ldots + o(1)) (\log N)^{1/3}(\log\log N)^{2/3}\Bigr),$$
sub-exponential but far from polynomial. The only known algorithm that factors
in time polynomial in $\log N$ is Shor's — and it needs a quantum computer.

None of this proves that factoring is hard; that remains one of the great open
questions. What it does is map the terrain. Eight walls now stand where before
there was fog, each one a theorem, each one telling a would-be factorer exactly
which direction not to walk. Progress in mathematics is often like this: not the
storming of the summit, but a careful survey of the cliffs, so that the next
expedition knows where the route cannot be.
