# The Register That Cannot Be Shrunk

## A quantum computer's most famous algorithm has a hidden budget line — and it turns out to be non-negotiable

Somewhere in the specification of every serious plan to build a
cryptographically relevant quantum computer, there is a line item that reads
something like: *phase register, $2\lceil \log_2 N\rceil$ qubits.* For a
2048-bit RSA modulus that is roughly four thousand qubits — and those qubits
are not the cheap kind. They must stay coherent through the entire modular
exponentiation, they must be error-corrected, and each logical one of them may
cost thousands of physical ones. If you could shave the register in half, you
would shave years off the timeline of quantum factoring.

So it is worth asking a very concrete engineering question. Shor's algorithm
ends by measuring a big register and reading out an integer. What if we simply
*throw away the low-order bits*? Keep the top $t$ of them, take more samples to
compensate, and let the classical post-processing sort it out. Information is
information; surely a coarse measurement repeated many times can substitute for
one fine measurement.

The answer, it turns out, is no — and the "no" is sharp, quantitative, and
provable. The register size Shor specified is not a comfortable margin. It is a
wall. Below roughly $2\log_2 r$ bits, where $r$ is the hidden order the
algorithm is chasing, *no amount of sampling helps at all*: the data you collect
is literally identical for many different answers. Above that threshold,
sampling suddenly becomes cheap and powerful, and two samples already succeed
more than half the time, for every order, with no exceptions.

This is a story about a phase transition — and about the beautiful, very old
piece of number theory that puts it exactly where it is.

---

## The problem behind the problem

Shor's algorithm does not factor numbers directly. It solves a different
problem, and factoring falls out as a corollary. The problem is **order
finding**: given a modulus $N$ and a base $a$ coprime to it, find the smallest
positive integer $r$ with
$$a^r \equiv 1 \pmod N.$$
This $r$ is the *order* of $a$ modulo $N$. Once you know it — and if it is even
and $a^{r/2} \not\equiv -1$ — then $\gcd(a^{r/2} \pm 1, N)$ hands you a
nontrivial factor of $N$ almost for free.

The quantum part of the algorithm produces, after a Fourier transform and a
measurement, an integer that encodes an approximation to a fraction
$$\frac{k}{r}, \qquad 0 \le k < r,$$
with $k$ essentially uniform. Note what the machine gives you and what it does
not: it gives you a *number close to* $k/r$; it does not give you $k$, and it
does not give you $r$. The final step is entirely classical. You take the
measured real number $x \approx k/r$ and you ask: *which fraction with small
denominator is this?* The continued-fraction expansion of $x$ answers that
question, and its denominator is your candidate for $r$.

Everything hinges on the word "which". For the question to have a unique answer,
the measurement must be precise enough that only one small-denominator fraction
is close to $x$. That is not a quantum condition. It is a fact about the
geometry of rational numbers on the line.

---

## Rationals hate crowds

Here is the classical fact — it goes back to Farey and to the elementary theory
of continued fractions — that governs the whole story.

> **Separation of rationals.** If $p/q$ and $p'/q'$ are distinct rational
> numbers written in lowest terms, then
> $$\left|\frac{p}{q} - \frac{p'}{q'}\right| \;\ge\; \frac{1}{qq'}.$$

The proof is one line: the difference is $(pq' - p'q)/(qq')$, the numerator is a
nonzero integer, so it has absolute value at least $1$.

One line, but it is the whole ballgame. Suppose all the fractions you care
about have denominator at most $R$. Then any two distinct ones are separated by
at least $1/R^2$. Consequently:

* **If your measurement is finer than $1/R^2$, you win.** At most one fraction
  of denominator $\le R$ can lie inside your error bar, so the target is
  uniquely determined.
* **If your measurement is coarser than $1/R^2$, you can lose** — and you
  provably do, because there really are pairs of fractions that close together.
  The neighbours $1/R$ and $1/(R-1)$ sit at distance exactly
  $$\frac{1}{R-1} - \frac{1}{R} = \frac{1}{R(R-1)},$$
  and both are legitimate order fractions arising from legitimate orders $R$ and
  $R-1$.

A register of $t$ bits pins the phase down to a window of width $2^{-t}$. So the
condition "finer than $1/R^2$" is exactly $2^t \gtrsim R^2$, i.e.
$$t \;\gtrsim\; 2\log_2 R.$$
The factor $2$ is not slack. It is the two denominators in $1/(qq')$.

This gives a two-sided theorem, and the two sides pinch the truth to within a
couple of bits:

> **The register threshold.** Fix a bound $R \ge 3$ on the order.
> If $t \ge 2\log_2 R + 2$, then any two fractions of denominator at most $R$
> compatible with the same $t$-bit reading are equal — the post-processing
> target is determined. If $t + 1 \le 2\log_2 R$, then there is a reading
> compatible with two *distinct* fractions of denominator at most $R$ — the
> target is not determined, and no post-processing, however clever or
> computationally unbounded, can break the tie.

The minimal usable register size therefore satisfies
$$2\log_2 R - 1 \;\le\; t_{\min} \;\le\; 2\log_2 R + 2 .$$

It also kills, in one stroke, the natural optimistic guess. One might hope that
$\log_2 r$ bits — just enough to *write down* the answer — plus a small
correction of order $\log\log r$ would do. It does not:

> **No linear register works.** For every constant $c$, a register of
> $\log_2 R + c$ bits is ambiguous as soon as $R > 2^c + 1$.

You cannot buy your way out with a constant, and you cannot buy your way out
with $O(\log\log R)$ either. The exponent $2$ is real.

---

## Below the threshold, the data goes blind

The above says the *classical decoding step* becomes ill-posed. One might still
hope that repetition rescues it — that although a single coarse sample is
ambiguous, the *statistics* of many coarse samples are not. After all, the
distribution of outcomes might differ between orders even if their supports
overlap.

Here the collapse is much more brutal than mere ambiguity. Model the truncated
register honestly: for a sample with numerator $k$ and order $r$, a $t$-bit
register reports the cell index
$$\left\lfloor \frac{2^t k}{r} \right\rfloor \in \{0, 1, \dots, 2^t - 1\}.$$

> **Support collapse.** If $2^t \le r$, then the map $k \mapsto \lfloor 2^t k/r
> \rfloor$ is *onto* the whole alphabet $\{0,\dots,2^t-1\}$. Hence the set of
> observable outcomes does not depend on $r$ at all.

The proof is a counting argument: because the order exceeds the number of cells,
each cell is wide enough to contain at least one point of the arithmetic
progression $k/r$.

The consequence is stark. Every *record* — every finite list of readings, of any
length whatsoever — that can occur at order $r$ can also occur at order $r'$,
for any two orders $r, r' \ge 2^t$. Therefore:

> **Samples do not help below the threshold.** For any two distinct orders
> $r \ne r'$, both at least $2^t$, there is no estimator — no function from
> records to answers, with no bound on the number of samples, no bound on
> computation time — that is correct for both.

And the collapse is not a boundary effect: *all* $R - 2^t + 1$ orders in the
window $[2^t, R]$ share one and the same set of observable records. This is not
a statistical difficulty; it is an information-theoretic identity. There is
nothing to estimate.

A companion fact measures precisely how much a truncated sample is worth:

> **Capacity of a truncated sample.** The number of distinct outcomes a $t$-bit
> register can emit at order $r$ is exactly $\min(2^t, r)$.

Below the collapse threshold the register is saturated — it emits $2^t$ symbols
and learns nothing about $r$ from the symbol alphabet. Above it, the map is
injective and the register sees the full order. And the standard counting bound
then says: to identify an order out of a family $S$ using $m$ samples of $t$
bits each, you need
$$m \cdot t \;\ge\; \log_2 |S| .$$
Qubits and samples enter only through their *product* — but the product bound is
the soft statement. The collapse is the hard one: below threshold the required
product can never be achieved, because the records themselves coincide.

There is one more obstruction that no register size ever removes. If $r$ divides
$r'$, then every outcome achievable at order $r$ is achievable at order $r'$ —
because $k/r = (sk)/(sr)$ *exactly*, at every resolution. So no estimator that
looks only at *which* outcomes occurred, rather than *how often*, can ever
distinguish $r$ from a multiple of it. Divisor ambiguity is permanent; only
frequencies, never precision, can break it.

---

## Above the threshold, samples become cheap

Cross the threshold and the picture inverts completely.

Above $2\log_2 r$ bits the decoding is well-posed, but there is still a catch,
and it is the familiar one from Shor's original analysis. Continued fractions
return the fraction $k/r$ *in lowest terms*. Its denominator is not $r$ but
$$\frac{r}{\gcd(k,r)} .$$
If the sampled numerator shares a factor with the order, you get a proper
divisor of $r$ — an under-report. This is exactly where extra samples earn
their keep.

> **The sample criterion.** A record of numerators $k_1,\dots,k_m$ recovers the
> order — meaning the least common multiple of the reduced denominators equals
> $r$ — **if and only if** $\gcd(\gcd(k_1,\dots,k_m),\, r) = 1$.

And this criterion has a pleasing structural reading. The denominator returned
by a single sample $k$ is precisely the additive order of $k$ in the cyclic
group $\mathbb{Z}/r\mathbb{Z}$ — the size of the subgroup $k$ generates. By
Bézout, the joint gcd of the record lies in the subgroup generated by the whole
record. Hence:

> **Recovery is generation.** A record recovers the order if and only if the
> sampled residues *generate* the group $\mathbb{Z}/r\mathbb{Z}$.

That is the honest meaning of "qubit–sample fungibility". Extra samples enlarge
the subgroup you have seen, until it is everything. Extra qubits, below the
resolution threshold, enlarge nothing at all.

So: how many samples? Remarkably few, and one can count them *exactly*. Call a
record of $m$ numerators drawn from $\{0,1,\dots,r-1\}$ **good** if it satisfies
the criterion above. A record is bad precisely when some prime $p \mid r$
divides every entry, which happens for a $p^{-m}$ fraction of records;
inclusion–exclusion over the prime divisors gives the exact count.

> **Exact success count.** The number of good records of length $m$ is
> $$\sum_{d \mid r} \mu(d)\left(\frac{r}{d}\right)^{m} \;=\; r^m \prod_{p \mid r}\left(1 - p^{-m}\right),$$
> which is Jordan's totient $J_m(r)$. Equivalently, the success probability of
> $m$ samples is exactly $\prod_{p \mid r}(1 - p^{-m})$.

From this closed form everything follows. Since
$\prod_{p\mid r}(1 - p^{-m}) \ge 1 - \sum_{p \mid r} p^{-m}$ and, for $m \ge 2$,
$\sum_{p} p^{-2} < 1/2$ over *any* finite set of primes — the four primes below
$11$ contribute $18589/44100$ and the rest telescope to at most $1/20$ — we get
a bound with no dependence on the number of prime factors at all:

> **Two samples suffice, for every order.** For every $r \ge 1$ and every
> $m \ge 2$, strictly more than half of all length-$m$ records recover the
> order. More sharply, the failure probability of $m$ samples is less than
> $2^{-(m-1)}$, uniformly in $r$.

And in the existence form: a successful record of length $m$ exists as soon as
$m \ge \log_2\log_2 r + 1$, because an order below $2^b$ has at most $b$ distinct
prime factors.

Here, then, is the ledger of Shor's algorithm, in its final form:
$$\textbf{qubits: } 2\log_2 r + O(1) \quad\text{(rigid)}, \qquad
\textbf{samples: } O(1) \quad\text{(nearly free)}.$$
That asymmetry *is* the answer to the trade question. Samples are cheap, but
they are cheap only on the far side of the wall.

---

## Making the wall model-independent

One might object that the "error bar of width $2^{-t}$" model is an artifact of
how we chose to describe a truncated measurement. So the same threshold was
proved in the strictest possible model, where the register reports nothing but
the dyadic cell index $\lfloor 2^t x \rfloor$ and two phases are confusable
exactly when they land in the same cell.

The proof is a pigeonhole argument that needs a lower bound on how many
distinct fractions must be crammed into $[0,1)$. That bound comes from counting
coprime pairs. Splitting the $R^2$ pairs in $[1,R]^2$ by their gcd gives the
exact fibration identity
$$R^2 = \sum_{d=1}^{R} C\!\left(\left\lfloor R/d \right\rfloor\right),$$
where $C(n)$ counts coprime pairs in $[1,n]^2$; combined with the elementary
tail bound $\sum_{d\ge 2} d^{-2} \le 3/4$ this yields
$$R^2 \;\le\; 4\,C(R),$$
i.e. at least a quarter of all pairs are coprime. Each coprime pair $(a,b)$
gives a distinct fraction $a/(a+b) \in (0,1)$ of denominator at most $2R$, so
there are at least $R^2/4$ such fractions. If the grid has fewer cells than
that — $4 \cdot 2^t < R^2$ — two of them collide. Since the dyadic cell of an
order fraction $k/r$ is *literally* the truncated register outcome
$\lfloor 2^t k/r\rfloor$, the collision is a genuine failure of order finding:

> **The grid threshold, two-sided.** If $R^2 \le 2^t$, distinct fractions of
> denominator at most $R$ always land in distinct cells. If $4\cdot 2^t < R^2$,
> two distinct such fractions share a cell. The critical number of cells lies
> between $R^2/4$ and $R^2$: again $t_{\min} = 2\log_2 R + O(1)$.

Two different models of what "truncation" means, the same quadratic wall. And
the wall applies to genuine arithmetic instances, not just to abstract
fractions: for every $r \ge 3$, the Mersenne modulus $N = 2^r - 1$ with base
$a = 2$ has multiplicative order exactly $r$, so orders of every size really do
occur and really are subject to the bound.

Finally, the depth bound composes with a width bound in the frequency domain: a
Fourier-sampling scheme that determines a period-$r$ signal must query at least
$r$ frequencies. Put together:

> **Shor's channel is irreducible on both axes.** The scheme needs at least $r$
> frequencies (width) *and* each retained outcome must be read to
> $2\log_2 r - O(1)$ bits (depth). Neither axis can be traded for the other.

---

## What this means for a machine that does not exist yet

For a random base modulo a semiprime $N$, the order $r$ is typically comparable
to $N$ itself — that is why the algorithm works at all. Substituting
$r \sim N$ into the threshold gives
$$t_{\min} \;\approx\; 2\log_2 N,$$
which is exactly the register Shor specified: $\ell = 2\lceil \log_2 N\rceil$.
The standard choice is not a safety margin chosen for convenience of analysis.
It is the minimum, and it is forced by the separation of rationals.

There is a broader moral here, and it is one that recurs across quantum
algorithms. The quantum advantage in Shor's algorithm is a *precision*
advantage: the Fourier transform delivers a real number to $2\log_2 N$ bits of
accuracy in one shot, something no classical sampling procedure can imitate at
that cost. The temptation is always to imagine that the precision can be
amortized — traded for repetition, for classical post-processing, for cleverness
somewhere downstream. The results above say that for order finding the trade
does not exist. Precision below the threshold is not partial information; it is
*no* information, in the exact sense that the observable data of different
answers coincide symbol for symbol.

Above the threshold, by contrast, the remaining difficulty — the gcd
under-reporting — is genuinely statistical, genuinely cheap, and now counted
exactly by a classical arithmetic function that Camille Jordan wrote down in the
nineteenth century. Two samples beat a coin flip for every order in existence;
$m$ samples fail with probability below $2^{-(m-1)}$.

Two thresholds, then, and a clean division of labour between them. Below
$2\log_2 r$ qubits: an information-theoretic vacuum, where a thousand samples
are worth the same as one. Above it: a mild, exponentially-vanishing nuisance
that a handful of samples dispatches. The quantum register cannot be shrunk —
but once it is big enough, almost nothing else has to be.
