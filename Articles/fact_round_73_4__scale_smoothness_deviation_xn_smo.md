# The Dial That Averages to One

## Why the quadratic sieve's favourite polynomial is, at heart, just a random number

There is a moment in every cryptanalyst's education when they meet the quadratic
sieve and feel a small thrill of larceny. To factor a large number $N$, you look
at the values of the polynomial

$$f(x) = x^2 - N$$

for $x$ just above $\sqrt{N}$. These values are small — about $2x\sqrt{\delta}$
for $x = \sqrt{N} + \delta$ — and every so often one of them factors completely
into small primes. Collect enough of those "smooth" values, multiply the right
subset together so that every prime exponent becomes even, and you have
manufactured a congruence $X^2 \equiv Y^2 \pmod N$ out of thin air. Take a
greatest common divisor and $N$ splits.

The thrill comes from a suspicion: surely $x^2 - N$ is *better than random*.
Look at what happens modulo a prime $p$. A generic integer is divisible by $p$
about one time in $p$. But $x^2 - N$ is a quadratic. If $N$ is a quadratic
residue mod $p$ — if there is some $r$ with $r^2 \equiv N$ — then $f(x)$ is
divisible by $p$ for *two* residues of $x$, namely $x \equiv \pm r$. Twice the
usual rate! The sieve exploits exactly this: it only ever sieves with primes for
which $N$ is a residue, because the others never divide $f(x)$ at all.

So: is the polynomial secretly smoother than a random integer of the same size?
Does the quadratic structure buy you a genuine head start, an $O(1)$ factor of
free smoothness that scales up as you push to cryptographic sizes?

This article is about the answer, which is a beautifully clean **no** — and
about the far more interesting question of what *is* really going on, since the
"twice the rate" observation is undeniably true.

---

## The dial

Fix an odd prime $p$ and think of $N$ as a residue mod $p$. Define the **dial**
of $N$ at $p$ to be the number of solutions to the congruence:

$$D_p(N) \;=\; \#\{\, x \bmod p \;:\; x^2 \equiv N \pmod p \,\}.$$

This counts the residue classes of $x$ on which $p$ divides $f(x) = x^2 - N$.
A random integer, by contrast, has "dial $1$": it is divisible by $p$ on exactly
one residue class out of $p$.

The dial of a quadratic obeys a strict trichotomy, and it is worth stating
precisely because everything else follows from it.

> **The Dial Dichotomy.** Let $p$ be an odd prime. Then $D_p(0) = 1$; $D_p(N) = 2$
> for every nonzero quadratic residue $N$; and $D_p(N) = 0$ for every quadratic
> nonresidue $N$. In particular $D_p(N) \le 2$ always.

The proof is a one-liner once you notice that the solution set of $x^2 = c^2$ in
the field $\mathbb{Z}/p$ is exactly $\{c, -c\}$, and that $c = -c$ forces $c = 0$
because $2$ is invertible when $p$ is odd. Two solutions, collapsing to one at
the origin, and none at all when $N$ is not a square.

Now here is the pivot on which the entire story turns. Add up the dial over all
$p$ possible values of $N$:

> **First Moment Theorem.** For every prime $p$,
> $$\sum_{N \bmod p} D_p(N) \;=\; p.$$
> Equivalently, the average dial is *exactly* $1$.

The reason is embarrassingly simple: the left-hand side counts pairs $(x, N)$
with $x^2 \equiv N$, and for each of the $p$ values of $x$ there is exactly one
$N$. So the sum is $p$, always, with no error term and no asymptotics.

Read that again, because it dissolves the original suspicion completely. Yes,
$x^2 - N$ hits $p$ twice as often as a random integer — *for half of all $N$*.
For the other half it never hits $p$ at all. The QR dial is a dial: it can be
turned up to $2$ or down to $0$, and the two settings occur equally often. On
average the polynomial is divisible by $p$ at exactly the random rate.

This is the arithmetic heart of the matter. The "advantage" of the quadratic
sieve's polynomial is not an advantage in aggregate. It is a redistribution.

---

## From dials to densities

The dial controls smoothness through a density. The chance that $p$ *fails* to
divide a value of $f$ is $1 - D_p(N)/p$, whereas for a random integer it is
$1 - 1/p$. The ratio of these two — call it the **local factor** —

$$L_p(N) \;=\; \frac{1 - D_p(N)/p}{1 - 1/p} \;=\; \frac{p - D_p(N)}{p-1}$$

is the multiplicative correction, at the single prime $p$, between the smoothness
density of $x^2 - N$ and that of a size-matched random integer. A random integer
has $L_p \equiv 1$ by construction. The dichotomy says $L_p(N)$ takes the value
$\frac{p-2}{p-1}$ at a residue and $\frac{p}{p-1}$ at a nonresidue — slightly
below one and slightly above one, symmetrically placed.

Because the average dial is exactly $1$, the average local factor is exactly $1$
too. But now we can also ask how *far* it wanders, and the answer is startlingly
crisp:

> **Local Variance Theorem.** For every odd prime $p$, averaged uniformly over
> $N$ mod $p$, the local factor has mean exactly $1$, second moment exactly
> $1 + \frac{1}{p(p-1)}$, and hence variance exactly
> $$\frac{1}{p(p-1)}.$$

No inequality, no asymptotic — an exact rational number. (The computation runs
through the exact second moment of the dial, $\sum_N D_p(N)^2 = 2p - 1$, which
is what you get when a variable is $2$ on $(p-1)/2$ points, $0$ on $(p-1)/2$
points, and $1$ once.)

Multiply the local factors over all primes $p \le B$, and you get the object that
would carry a smoothness edge if one existed: the **structure correction**

$$C(N) \;=\; \prod_{p \le B,\; p \text{ odd}} L_p(N).$$

This is the full multiplicative discrepancy between the heuristic smoothness
probability of $x^2 - N$ and that of a random integer of the same size. It is
$\equiv 1$ for a random integer. What is it for a quadratic?

---

## Two exact theorems, and a ceiling

Two facts about $C(N)$ settle the original question.

> **Ensemble Neutrality.** For any finite family of distinct odd primes,
> averaged over the residue data of $N$ (equivalently, over $N$ modulo the
> product of the primes), the structure correction has mean **exactly one**:
> $$\mathbb{E}[C] = 1.$$

The proof is one line given the local statement: the average of a product of
functions of independent coordinates is the product of the averages, and each
average is exactly $1$. Crucially there is no dependence on $B$, on the size of
$N$, or on how deep into the smoothness regime you are looking. *No first-order
smoothness edge can exist, at any scale.*

> **The Dispersion Ceiling.** The variance of $C$ is exactly
> $$\prod_{p \le B,\ p \text{ odd}} \Bigl(1 + \frac{1}{p(p-1)}\Bigr) \; - \; 1,$$
> and for **every** finite family of distinct odd primes — however large the
> smoothness bound $B$ — this second moment satisfies
> $$1 \;<\; \prod_p \Bigl(1 + \tfrac{1}{p(p-1)}\Bigr) \;\le\; 2.$$

The upper bound comes from a telescoping identity that any schoolchild could
verify: $\sum_{n=3}^{M} \frac{1}{n(n-1)} = \frac12 - \frac1M$, so the total mass
of the correction terms over any set of integers $\ge 3$ is at most $\frac12$;
combine that with $\prod (1 + x_i) \le 1/(1 - \sum x_i)$ and you get $\le 2$. The
strict lower bound is trivial but important: the variance is genuinely positive,
so the clustering is *real*, not an artefact. The true value of the infinite
product over all odd primes is about $1.2967$; for the three-prime family
$\{3,5,7\}$ it is exactly $\frac{301}{240} \approx 1.254$.

So the picture is fully determined. The structure correction is a random variable
with mean pinned to $1$ by an exact identity, and variance pinned into the
interval $(0,1]$ by a convergent Euler product. Chebyshev's inequality then gives
a clean tail statement: the fraction of residue data with $|C(N) - 1| \ge t$ is at
most $1/t^2$, uniformly in $B$.

**The quadratic structure of $x^2 - N$ can never buy more than a constant
factor, and on average it buys nothing at all.**

---

## The dial is perfectly balanced — jointly

One might still hope for a conspiracy: perhaps the dials at different primes are
correlated, so that certain $N$ have unusually many primes turned "up". They are
not. Writing $\chi_p$ for the quadratic character mod $p$ (the Legendre symbol),
the dichotomy is exactly the identity

$$D_p(N) \;=\; 1 + \chi_p(N),$$

valid for all $N$ including $N=0$, where both sides are $1$. The first-moment
theorem is then precisely the classical statement that a nontrivial character
sums to zero over the full group — obtained here as a corollary rather than an
input.

> **Exact Joint Uniformity.** Let $p_1, \dots, p_k$ be distinct odd primes. For
> every prescribed pattern $(d_1, \dots, d_k) \in \{0,2\}^k$ of dial settings, the
> number of residue data $N$ realising that exact pattern is the same, namely
> $$\frac{1}{2^k}\prod_{i=1}^{k}(p_i - 1),$$
> independent of the pattern.

The dial vector is an exactly uniform random element of $\{0,2\}^k$. There is no
bias to exploit anywhere: not marginally, not jointly. A corollary makes the
$O(1)$ dispersion visible in a different way: the residue data on which $C(N)$
attains its maximum $\prod \frac{p}{p-1}$ (all nonresidues) or its minimum
$\prod \frac{p-2}{p-1}$ (all residues) form a set of relative density exactly
$2^{-k}$. Extreme structure corrections are exponentially rare, which is exactly
why the clustering they produce stays bounded.

---

## What the numbers said

None of this was found in an armchair. It emerged as the explanation of a large
computational experiment designed to hunt for a smoothness edge in precisely the
regime that matters.

Smoothness is measured on the logarithmic scale $u = \log v / \log B$, where $v$
is the size of the value being tested and $B$ the smoothness bound. The classical
Dickman heuristic says a random $v$ is $B$-smooth with probability roughly
$u^{-u}$; the whole design of sieve algorithms is a balancing act in $u$. Earlier
attempts to compare $x^2-N$ against randomness lived at $u < 4.75$ — comfortable
but far from the cryptographic frontier. The experiment behind this work pushed
to $u \in \{5, 6, 7, 8\}$ with $B = 1000$, using controls histogram-matched on
bit-length and mantissa octant, roughly $1.5 \times 10^9$ candidates per arm, and
a shared code path so that the two populations could not differ by an
implementation accident.

The measured ratio $r(u)$ of the candidate smoothness probability to the control
probability came out as

| $u$ | $r(u)$ | 95% interval |
|---|---|---|
| $5.96$ | $1.011$ | $[0.947,\ 1.075]$ |
| $6.95$ | $0.949$ | $[0.783,\ 1.152]$ |
| $7.93$ | $0.900$ | $[0.455,\ 1.700]$ |
| $8.26$ | $1.200$ | $[0.500,\ 3.000]$ |

Every interval covers $1$. The fitted trend in $\log r$ against $u$ has slope
$+0.036$ with interval $[-0.255, +0.345]$ and $p = 0.831$: flat. The tightest
bound obtained is $|r - 1| \le 0.217$. There is no smoothness edge to be found,
and now we know why: the mean of $C$ is exactly $1$, by an identity, at every $u$.

But two secondary signals were real. First, the per-$N$ smoothness counts were
**overdispersed** relative to Poisson, with index $D = 1.61$ (interval
$[1.50, 1.73]$) at $u \approx 6$. Second, the fraction of sieve primes for which
$N$ is a quadratic residue *predicted* a given $N$'s smoothness rate, with
Spearman correlation $0.32$ (permutation $p = 7 \times 10^{-4}$).

Both are exactly what the theory demands. The overdispersion index is the
variance of $C$ showing through; the ceiling says it can never exceed $2$, and
the measured $1.61$ sits comfortably inside. The QR correlation is the strict
monotonicity of $C$: flipping a single prime from "residue" to "nonresidue"
strictly *increases* the structure correction, so an $N$ with many quadratic
residues among the sieve primes is genuinely harder to make smooth. Both signals
are second-moment phenomena, and both point the same way — the direction the
$\pm$ symmetry of the dial forbids the first moment from pointing.

---

## Why the clustering dies

The last puzzle is the strangest. Both secondary signals **vanish** above
$u \approx 7$: the dispersion index falls to $\approx 1.00$, the QR correlation to
$0.04$. Yet the arithmetic that produces them — the distribution of $C$ — does
not depend on $u$ at all. Its mean is $1$ and its variance is a fixed Euler
product, whatever the smoothness bound and whatever the size of the values.

The resolution is that the signals are not arithmetic, they are *statistical*.
Model the number of smooth values found for a given $N$ as a count whose
conditional mean is $\lambda\, C(N)$ and whose conditional variance is
$\lambda\, C(N)\bigl(1 - q\, C(N)\bigr)$ — exactly the mean and variance of
$n$ independent trials of success probability $q\,C(N)$, with $\lambda = nq$.
The finite law of total variance then gives an *exact* identity for the mixture:

> **Dispersion Identity.** With $S_2 = \mathbb{E}[C^2]$ and $\mathbb{E}[C]=1$,
> $$\text{Mean} = \lambda, \qquad
> \text{Var} = \lambda\bigl(1 + \lambda (S_2 - 1) - q\,S_2\bigr).$$

Divide: the dispersion index is $1 + \lambda(S_2-1) - qS_2$. The arithmetic
enters *only* through $S_2$, which is bounded by $2$. The excess over Poisson is
proportional to the **event rate** $\lambda$:

> **Decay of Clustering.** For any family of distinct odd primes,
> $$\bigl|\text{Var} - \text{Mean}\bigr| \;\le\; \text{Mean}\cdot(\lambda + 2q).$$

That is the whole story. At $u \approx 6$ the experiment had $\lambda$ of order
one and saw $D \approx 1.6$. At $u \approx 8$ smooth events were so rare that
$\lambda \approx 18/4000 \approx 0.005$, and no experiment on earth could have
seen dispersion there: with events that rare, a mixture of Poissons is
indistinguishable from a Poisson. The clustering did not die. It became
unobservable, at a rate the theory predicts exactly.

The same argument disposes of the QR correlation. Its detectability scales with
the number of events per $N$; at $\lambda = 0.005$, almost every $N$ has zero
events and rank correlation has nothing to rank.

---

## The shape of the answer

Three patterns fall out of this, and they are the kind of patterns worth
carrying to other problems.

**First moments are protected by symmetry.** The reason no smoothness edge
exists is that the dial is $1 + \chi_p$, and $\chi_p$ is a nontrivial character:
it sums to zero. Any structure whose local deviation from randomness is a
character will be ensemble-neutral for exactly this reason. The advantage is
symmetric and the symmetry is exact.

**Second moments are $O(1)$ because the Euler product converges.** The variance
of $C$ is $\prod (1 + \frac{1}{p(p-1)}) - 1$, and $\sum \frac{1}{p(p-1)}$
converges — indeed the telescoping bound over all integers $\ge 3$ is $\frac12$.
Structure can buy you a constant. It cannot buy you a growing factor. This is a
hard ceiling on how much any polynomial's arithmetic shape can matter.

**Observability of a second moment is proportional to the rate.** This is the
methodological lesson, and it has teeth well beyond factoring. Any experiment
reporting overdispersion at event rate $\lambda$ is, to first order, reporting
$\lambda \cdot \mathrm{Var}(C)$. If you compare the dispersion measured in a
high-rate regime with the dispersion in a low-rate regime and conclude the
underlying mechanism changed, you are almost certainly wrong. The mechanism did
not change; the microscope did.

---

## Where it leaves the sieve

The practical upshot for factoring is deflationary and clarifying in equal
measure. The quadratic sieve does not gain a smoothness bonus from the shape of
$x^2 - N$; it gains from the *smallness* of the values near $\sqrt N$ and from
being able to skip half the primes (the ones for which $N$ is a nonresidue),
which is a cost saving, not a probability gain. The per-$N$ variation is real,
bounded by a factor under $1.30$ in the second moment, and worth at most a
constant in practice.

Two honest gaps remain. The experiment tops out near $u \approx 8.5$, because
with $N \le 2^{80}$ and $x \le 4\sqrt N$ you simply cannot manufacture larger $u$
at $B = 1000$; production-scale $u \ge 9$ is untested, though the exact theorems
apply there verbatim. And the counting explanation for the dying clustering,
while exact as an inequality, has not been pinned to the specific $\lambda$
trajectory of the experiment.

The natural generalisation is already visible. Everything above was driven by the
*variance of the number of roots* of the sieve polynomial modulo $p$. For a
degree-$d$ polynomial with Galois group $G$, that quantity is the variance of the
number of fixed points of a uniform element of $G$, distributed according to
Chebotarev. The mean is always $1$ — that is Frobenius's theorem, another exact
symmetry — so the ensemble neutrality survives at every degree. Only the ceiling
changes, and it changes in a way one can compute from the group. Which is to say:
the dial averages to one, always. It is only the wobble that has a story.
