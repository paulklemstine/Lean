# The Dials That Knew Nothing

## How a stable, reproducible pattern turned out to carry no information at all

There is a particular kind of scientific disappointment that only shows up
after you have done everything right. You build a predictor. It works. Then
you push it into a harder regime, and it degrades. So you do the obvious
thing: you refit. You let the model relearn its weights in the new regime,
where it now has direct experience of the harder problem. And the refitted
model comes out *worse* than the one you never touched.

That happened. And the reason it happened is not a bug in the fitting code,
not a shortage of data, and not bad luck with random seeds. It is a theorem
about prime numbers.

---

## Sieving, and the little dials

Start with the practical problem that generated all of this. Many of the
fastest known ways to factor a large integer $N$ — the quadratic sieve and its
descendants — work by hunting for integers $x$ such that the value
$$x^2 - N$$
factors completely into small primes. Such a value is called *smooth*, and
smooth values are the raw material out of which a factorization is eventually
assembled. The whole game is finding them cheaply.

Now here is the arithmetic fact that makes the hunt structured rather than
blind. Fix a small odd prime $p$ and ask: can $p$ ever divide $x^2 - N$? That
requires $x^2 \equiv N \pmod p$, i.e. it requires $N$ to be a square modulo
$p$. Exactly half of the nonzero residues mod $p$ are squares. So for half of
all $N$, the prime $p$ is simply *forbidden* from dividing $x^2 - N$, no matter
which $x$ you choose; and for the other half, $p$ divides $x^2-N$ for two
residue classes of $x$ out of $p$ — twice the density you would naively expect.

Define the **dial** of $p$ at $N$ to be the number of solutions:
$$\operatorname{dial}_p(N) \;=\; \#\{x \bmod p : x^2 \equiv N\} \;\in\; \{0,1,2\}.$$
The dial reads $2$ when $p$ is doubly helpful, $0$ when $p$ is useless, and
$1$ in the single degenerate case $p \mid N$. For a fixed $N$, the list of
dials over all small primes $p \le B$ is the **footprint** of $N$: a short
string of $0$s, $1$s and $2$s that says which small primes are on your side.

Footprints are cheap to compute, and they obviously matter — a number whose
small primes are mostly switched off will yield fewer smooth values. So the
natural move is to build a score: take a weighted combination of the dials,
$$\text{score}(N) \;=\; c + \sum_{p \le B} \beta_p\bigl(\operatorname{dial}_p(N)-1\bigr),$$
and use it to rank candidates. Practitioners have long used a fixed, untuned
version of this score — set all the weights to zero and just take the average,
what one might call the *unrefit dial*. The question that started this work
was whether tuning the $\beta_p$ helps in the hard regime.

Empirically, the answer was a resounding no: the refitted score scored $0.605$
against the untuned score's $0.629$, a paired loss on every single trial, a
"recovery" of $-24\%$. Worse, the fitted weight vector was *stable*: rerun the
fit on a different half of the data and you get essentially the same ranking of
weights (rank agreement $0.87$ across split halves, $0.94$ leaving one prime
out). A stable, reproducible pattern that makes predictions worse. What is
going on?

---

## The design that is perfectly square

The first thing to notice is that the dials are a statistician's dream. Center
them, writing $x_p = \operatorname{dial}_p - 1 \in \{-1,0,+1\}$, and average
over residue data — that is, treat the residues $N \bmod 3$, $N \bmod 5$,
$N \bmod 7, \dots$ as uniform and independent, which by the Chinese Remainder
Theorem they exactly are. Then:

- **each feature is centered:** $\mathbb{E}[x_p] = 0$, because the number of
  squares and non-squares mod $p$ balances the single degenerate class exactly;
- **distinct features are exactly uncorrelated:** $\mathbb{E}[x_p x_q] = 0$
  for $p \neq q$;
- **each feature has an exactly known variance:**
  $\mathbb{E}[x_p^2] = \dfrac{p-1}{p}.$

This is an *orthogonal design* — not approximately, not asymptotically, but
exactly, with closed-form variances. Orthogonal designs are the case where
least squares becomes transparent algebra. For any target $f$ and any affine
predictor $c + \sum_p \beta_p x_p$, the mean squared error splits into three
non-interacting pieces:
$$\mathbb{E}\bigl[(f - c - \textstyle\sum_p \beta_p x_p)^2\bigr]
= \underbrace{(\mathbb{E}f - c)^2}_{\text{intercept error}}
+ \underbrace{\sum_p v_p\Bigl(\beta_p - \tfrac{\operatorname{cov}(f,x_p)}{v_p}\Bigr)^2}_{\text{weight error}}
+ \underbrace{\Bigl(\operatorname{Var} f - \sum_p \tfrac{\operatorname{cov}(f,x_p)^2}{v_p}\Bigr)}_{\text{irreducible residual}},$$
with $v_p = (p-1)/p$. Every term is a square, so every term is a penalty you
pay for being wrong, and the last term is the penalty you pay no matter what.

Read off two consequences immediately. First, the best possible improvement
over the untuned score — the **recalibration ceiling** — is the middle
quantity
$$\mathcal{E}(f) \;=\; \sum_p \frac{\operatorname{cov}(f,x_p)^2}{v_p},$$
the *footprint energy*, and it is attained by the single choice
$\beta_p = \operatorname{cov}(f,x_p)/v_p$. Second — and this is the part with
teeth — if all the covariances vanish, then the ceiling is zero and the
formula collapses to
$$\text{loss} \;=\; \operatorname{Var} f \;+\; (\mathbb{E}f-c)^2 \;+\; \sum_p v_p\beta_p^2 .$$
Every nonzero weight vector is *strictly worse* than the untuned score, by
exactly $\sum_p v_p\beta_p^2$. Refitting cannot recover. It can only lose. And
the amount it loses depends on $\beta$ only through the sum of squares
$\sum_p v_p \beta_p^2$ — which means $\beta$ and $-\beta$ fit *identically
well*. The direction of the fitted weight vector is invisible to the data.

That last sentence is the resolution of the paradox. A stable object that
carries no information is not a contradiction; it is what you get when the
loss surface is a perfectly round bowl and the fitting procedure's tie-breaking
— its regularizer, its initialization, its numerical geometry — is itself
reproducible. The weights come back the same way each time because the *design*
is the same each time, not because the data has an opinion about them. Stability
was never evidence of signal.

---

## When the target does live in the footprint

Of course, in the real problem the covariances are not exactly zero: the small
primes do carry *some* of the signal. So the question becomes quantitative.
How much?

The right target to measure against is the exact smoothness bias of $x^2-N$,
the **structure correction**
$$C(N) \;=\; \prod_{p} \frac{p - \operatorname{dial}_p(N)}{p-1},$$
which is the multiplicative factor by which the small primes tilt the
probability that $x^2-N$ is smooth. It is normalized so that
$\mathbb{E}[C] = 1$. And every quantity in the decomposition above can be
computed for it in closed form:

- the covariance of $C$ with the dial of $p$ is **exactly** $-1/p$;
- the optimal weight is therefore **exactly** $\beta_p^\ast = -\dfrac{1}{p-1}$;
- the recalibration ceiling is **exactly**
  $\displaystyle \sum_p \frac{1}{p(p-1)}$;
- the total available signal is **exactly**
  $\displaystyle \operatorname{Var} C = \prod_p\Bigl(1 + \frac{1}{p(p-1)}\Bigr) - 1 .$

Two things jump out.

**The optimal profile is negative.** Not small, not noisy — *negative*, and
shaped like $-1/p$. The theory that motivated the original score predicted a
positive profile shaped like $2/p$. Any positive profile is therefore pointing
the wrong way, and one can prove without any numerics that a footprint refit
with all weights $\beta_p \ge 0$, at least one of them strictly positive, is
*strictly worse* than not refitting at all. The measured anti-correlation of
$-0.93$ between the fitted weights and the $2/p$ theory profile is not an
anomaly to be explained. It is forced by the arithmetic.

**The ceiling is strictly below the total.** Compare
$$\sum_p c_p \qquad\text{versus}\qquad \prod_p (1+c_p) - 1,
\qquad c_p = \frac{1}{p(p-1)},$$
and you are looking at the elementary inequality
$1 + \sum c_p \le \prod (1+c_p)$, strict as soon as two of the $c_p$ are
positive. The gap is
$$\prod_p(1+c_p) - 1 - \sum_p c_p \;=\; \sum_{|S| \ge 2} \prod_{p \in S} c_p,$$
the sum over *interactions* of two or more primes. This is content that
literally does not exist in any single dial: it is the joint behaviour of pairs,
triples and larger constellations of primes. No one-prime feature, under any
weighting whatsoever, can reach it.

For the footprint $\{3,5,7\}$ the numbers are exact and small enough to write
down: the ceiling is $\tfrac16 + \tfrac1{20} + \tfrac1{42} = \tfrac{101}{420}
\approx 0.24048$, while the total signal is $\tfrac{301}{240}-1 = \tfrac{61}{240}
\approx 0.25417$. Even a *perfectly* refitted footprint reaches $94.6\%$ of the
available signal; the residual $5.4\%$ is pure multi-prime interaction and is
unreachable in principle.

---

## Closing the last escape hatch

At this point a skeptic has one move left. Everything above concerns *linear*
scores. Maybe the footprint does know about the missing content, and only a
nonlinear model — a decision tree, a small network, anything — could extract
it?

No. And the reason is again exactness rather than approximation. Split the
residue data along the footprint: the residues at the small primes on one side,
the residues at every other prime on the other. Those two halves are exactly
independent, again by the Chinese Remainder Theorem. Let $G$ be *any* function
of the mid-prime half and $F$ be *any* function of the footprint half — no
linearity, no shape assumption, no constraint at all. Then independence gives
the clean identity
$$\mathbb{E}\bigl[(G-F)^2\bigr] \;=\; \operatorname{Var} G + \operatorname{Var} F + \bigl(\mathbb{E}F - \mathbb{E}G\bigr)^2 .$$
The right-hand side is minimized by making $F$ constant and equal to
$\mathbb{E}G$ — which is exactly the untuned score. Every non-constant
footprint model, of any complexity, loses precisely
$\operatorname{Var}F + (\mathbb{E}F-\mathbb{E}G)^2$. Model capacity does not
help; expressiveness is not the bottleneck. The content is not badly-weighted
small-prime information. **It is not small-prime information at all.**

---

## What the failure was actually telling us

Put the pieces together and the negative experimental result turns into a
positive structural statement.

The drop observed in the hard regime is *real* and it is *localized*. It is not
a mis-weighting of the small primes: the small-prime channel has a hard ceiling,
that ceiling is computable in closed form, the optimal profile through it points
the opposite way to the theory that was being tested, and even an unbounded
nonlinear model of the same channel cannot climb higher. Whatever the hard
regime destroyed, it lived somewhere else: in the middle primes, or in
structure that no per-prime feature sees. Meanwhile the untuned, zero-weight
score — the one nobody was tempted to defend — is now the provably right choice
for that channel, without qualification.

There is a broader moral here about how we read model diagnostics. Two
instincts that feel like good practice turn out to be wrong in this setting.
The instinct that *refitting in the target regime should help* is wrong: when
a feature set is orthogonal to the signal, refitting is a strictly negative
operation, and the more parameters you free the more you lose. The instinct
that *a stable coefficient pattern means you have found something* is wrong:
stability measures the reproducibility of your fitting geometry, and a
perfectly symmetric loss surface reproduces beautifully while saying nothing.
Here both instincts fail simultaneously, and one can say exactly why.

And there is a forward-looking piece too. The unreachable share is not some
formless remainder — it has a name and a formula. It is
$\sum_{|S|\ge 2}\prod_{p\in S}c_p$, the tail of an elementary symmetric series,
which suggests that the recovery achievable by a model of *interaction order*
$d$ should be exactly the partial sum
$$\sum_{1 \le |S| \le d}\ \prod_{p\in S} c_p .$$
For $\{3,5,7,11\}$ this predicts that going from single primes to pairs lifts
you from $94.0\%$ to $99.9\%$ of the available signal — a precise, testable
recovery curve indexed by model order rather than by model size. That is the
constructive version of a negative result: the experiment told us the door was
locked, and the mathematics told us exactly which key is missing.

---

## Coda

The most useful thing a failed experiment can produce is a theorem explaining
why it had to fail. Here the explanation is unusually clean, because the
underlying randomness is not statistical modelling but arithmetic: residues
modulo distinct primes are *exactly* independent, quadratic residues split the
classes *exactly* in half, and so every "estimate" in the analysis is an
identity. The variances are $(p-1)/p$; the covariances are $-1/p$; the ceiling
is $\sum 1/(p(p-1))$; the total is $\prod(1+1/(p(p-1)))-1$; the gap is the
interaction tail. There is nothing left to estimate, and nothing left to hope
for from the small primes. That is a strange kind of good news — but it is
good news, because it tells you precisely where to look next.
