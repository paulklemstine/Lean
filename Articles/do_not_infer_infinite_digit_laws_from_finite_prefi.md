# The Digits That Prove Nothing

## Why a billion decimals of $\pi$ cannot tell you what the next billion will look like

There is a particular kind of headline that surfaces every few years. *Statisticians find hidden pattern in the digits of $\pi$.* *The digits of $\sqrt{2}$ are perfectly random — and here is the proof.* *A surprising correlation in the decimal expansion of $e$.* The stories are usually accurate about what was computed. They are almost always wrong about what it means.

The reason is a piece of mathematics that is easy to state, slightly uncomfortable to accept, and — as we shall see — provable in complete generality. **No finite prefix of a decimal expansion constrains its asymptotic behaviour at all.** Not the frequency of the digit $7$. Not the density of nonzero digits. Not whether the number is normal. Not even whether it is rational. Whatever you measure in the first ten trillion digits of $\pi$, there exists an irrational number agreeing with $\pi$ in every one of those ten trillion digits whose long-run statistics are anything you please.

That is not a philosophical caveat. It is a theorem, and this article is about how to prove it — by building the counterexamples explicitly, with your bare hands.

---

## What we are allowed to assume

Let us fix notation. For a real number $x \ge 0$, write
$$d_m(x) = \left\lfloor x \cdot 10^{\,m+1} \right\rfloor \bmod 10, \qquad m = 0, 1, 2, \dots$$
for the $m$-th digit after the decimal point. So $d_0(\sqrt 2\,) = 4$, $d_1(\sqrt 2\,) = 1$, $d_2(\sqrt 2\,) = 4$, and so on.

Now: what do we actually *know* about the sequence $d_0(\pi), d_1(\pi), \dots$? We know $\pi$ is irrational; in fact transcendental. And irrationality does have a digit-theoretic meaning — a completely precise one.

> **The Periodicity Dichotomy.** For $x \in [0,1)$, the number $x$ is irrational **if and only if** its decimal digit sequence is not eventually periodic: there is no pair $(n, p)$ with $p \ge 1$ such that $d_{m+p}(x) = d_m(x)$ for all $m \ge n$.

That is the *whole* digit content of irrationality. It says: the expansion never settles into a repeating block. It does *not* say the digits are equidistributed, or unpredictable, or uncorrelated, or interesting. Between "not eventually periodic" and "statistically random" lies an enormous gulf, and everything in this article lives inside that gulf.

---

## Building numbers to order

The strategy is constructive. If we want to show that finite data determines nothing, we should manufacture numbers whose entire infinite expansion we control, and then splice them onto whatever prefix we like.

The first thing needed is a small technical fact, so obvious-looking that it is easy to miss that it is false as stated.

> **Digit Recovery.** Let $(d_m)_{m \ge 0}$ be any sequence of decimal digits with $d_m \le 8$ for every $m$. Put
> $$\mathrm{val}(d) = \sum_{m=0}^{\infty} \frac{d_m}{10^{\,m+1}}.$$
> Then the decimal digits of $\mathrm{val}(d)$ are exactly the $d_m$: $\ d_m(\mathrm{val}(d)) = d_m$ for all $m$.

The hypothesis $d_m \le 8$ is not a technicality one can wave away — it is *necessary*. The sequence $9,9,9,\dots$ has $\mathrm{val} = 1$, whose digits are $0,0,0,\dots$. The famous identity $0.999\ldots = 1.000\ldots$ is precisely the failure of digit recovery, and any construction that ignores it builds numbers whose digits are not what the builder thinks they are. Excluding the digit $9$ excludes the collision, and the proof then runs on an exact decomposition worth recording: if $H_n(d)$ denotes the integer $d_0 d_1 \cdots d_{n-1}$ read in base ten, then
$$10^n \cdot \mathrm{val}(d) = H_n(d) + \mathrm{val}\big(d_n, d_{n+1}, d_{n+2}, \dots\big),$$
an integer plus a tail which — because no digit is a $9$ — is trapped in $[0, 8/9]$, hence in $[0,1)$. Taking floors reads off the digits one at a time.

With prescription in hand we need irrationality on demand. Here the classical trick is *lacunarity*: make the interesting digits extremely rare.

> **Gaps force irrationality.** Suppose a digit sequence $(d_m)$ with all $d_m \le 8$ contains, for every length $L$, a run of $L$ consecutive zeros that is still followed somewhere later by a nonzero digit. Then $\mathrm{val}(d)$ is irrational.

The argument is a Liouville-type squeeze. Suppose $\mathrm{val}(d) = p/q$. Cut the expansion at the start of a zero run of length $L = q + 1$. The decomposition above says that $q \cdot \big(10^k \mathrm{val}(d) - H_k(d)\big)$ is an integer; it is positive, because a nonzero digit survives further out; but it is at most $q \cdot \tfrac{8}{9} \cdot 10^{-L} < 1$, because the run of zeros makes the tail tiny. A positive integer smaller than $1$: contradiction.

---

## Three numbers with the same face and different souls

Now we can build. Call a position $m$ **lacunary** if $m + 1$ is a power of two, i.e. $m \in \{0, 1, 3, 7, 15, 31, 63, \dots\}$. Lacunary positions are exactly what we need: the gaps between them double, so runs of zeros grow without bound, while their count stays tiny — there are at most $\log_2 M + 1$ of them below $M$.

**The sparse number.** Put a $1$ at each lacunary position and a $0$ everywhere else:
$$S = 0.1101000100000001000000000000000100\ldots$$
By the gap criterion, $S$ is irrational. But the density of its nonzero digits is
$$\lim_{M \to \infty} \frac{\#\{m < M : d_m(S) \neq 0\}}{M} \le \lim_{M \to \infty} \frac{\log_2 M + 1}{M} = 0.$$
Almost every digit of this irrational number is a zero.

**The dense number.** Add $\tfrac19 = 0.111\ldots$ to $S$. Digitwise, every $0$ becomes a $1$ and every $1$ becomes a $2$:
$$D = S + \tfrac19 = 0.2212111211111112111111111111111211\ldots$$
Since $S$ is irrational and $\tfrac19$ is rational, $D$ is irrational too. And now *no* digit of $D$ is zero: the density of nonzero digits is $1$.

**The rational number.** And of course $0.000\ldots = 0$ is rational, with all digits zero.

Neither $S$ nor $D$ is *simply normal* — a number is simply normal in base ten when each of the ten digits occurs with limiting frequency $\tfrac1{10}$, which forces the nonzero-digit density to be exactly $\tfrac9{10}$. Density $0$ and density $1$ both miss. So irrationality alone is compatible with digit-zero-density $1$, with digit-zero-density $0$, and with everything in between; and it never implies normality.

---

## Grafting: keeping the face, replacing the soul

The last ingredient is a surgical operation. Given any $x \ge 0$, a length $n$, and a tail value $t \in [0,1)$, define the **graft**
$$G(x, n, t) = \frac{\lfloor x \cdot 10^n\rfloor + t}{10^n}.$$
This is $x$ truncated after $n$ digits, with $t$ written into the remaining places. Two facts make it useful, and both are elementary consequences of the floor computation:

* **the prefix is preserved:** $d_k(G(x,n,t)) = d_k(x)$ for all $k < n$;
* **the tail is exactly $t$:** $d_{n+m}(G(x,n,t)) = d_m(t)$ for all $m \ge 0$.

Also, $G(x,n,t)$ differs from $x$ by less than $10^{-n}$, and $G(x,n,t)$ is irrational precisely when $t$ is, since the graft is an integer translate of $t$ divided by a power of ten.

Put the pieces together and the headline theorem falls out.

> **No finite prefix determines any digit law.** Let $x \ge 0$ be any real number and $n$ any length. Then there exist reals $y, z, w$, all three agreeing with $x$ in the first $n$ decimal digits, such that
> * $y$ is irrational and the density of its nonzero digits is $0$;
> * $z$ is irrational and the density of its nonzero digits is $1$;
> * $w$ is rational;
> * none of $y, z, w$ is simply normal, and they are already distinguished at position $n$, where their digits are $1$, $2$ and $0$.

Take $y = G(x,n,S)$, $z = G(x,n,D)$, $w = G(x,n,0)$. In particular, taking $x = \sqrt 2$, or $\pi$, or $e$: whatever your computation of the first $n$ digits shows, three numbers with that same computed prefix disagree about rationality, about digit frequencies, and about normality. The prefix is silent on all three.

And there is not merely a handful of such numbers. Feed an arbitrary infinite bit stream $b_0, b_1, b_2, \dots$ into the lacunary positions — write digit $1$ where $b_i$ is true and digit $2$ where it is false, zeros everywhere else — and every one of the resulting numbers is irrational (the gaps are still there), has nonzero-digit density $0$, is not simply normal, and can be grafted onto the prefix of $x$. Distinct bit streams give distinct numbers, because the stream is read back off the digits. So:

> **Continuum many witnesses.** For every $x$ and every $n$, the set of irrational, non-simply-normal numbers sharing the first $n$ digits of $x$ is uncountable.

The prefix does not merely fail to pin down the answer; it fails to reduce the space of answers to anything countable.

---

## The correlation half of the story

Digit frequencies are only half of what people claim to see in $\pi$. The other half is *correlation*: the assertion that $d_m$ and $d_{m+r}$ are statistically independent, that the digit sequence has no memory. Make this precise by counting agreements at lag $r$,
$$A_r(x, M) = \#\{\, m < M : d_m(x) = d_{m+r}(x) \,\},$$
and calling $\alpha$ the **lag-$r$ agreement density** of $x$ when $A_r(x,M)/M \to \alpha$. For a "random" digit sequence one expects $\alpha = \tfrac1{10}$ at every lag $r \ge 1$. Is *that* pinned down by a prefix?

It is not, and the witness is a new number built from the same parts. Start with the period-two pattern $1,2,1,2,\dots$, whose value $0.1212\ldots = \tfrac{4}{33}$ is rational, and add the sparse number $S$ digitwise, bumping each lacunary digit up by one:
$$A = \tfrac{4}{33} + S = 0.2313121312121213121212121212121312\ldots$$
Digitwise addition of two digit sequences adds their values — a two-line consequence of absolute convergence — so $A$ is a rational plus an irrational, hence irrational. Yet its correlation structure is rigid:

* At **lag $1$** the digits *never* agree, except possibly at the $O(\log M)$ lacunary positions: consecutive entries of the alternating pattern always differ. Agreement density $0$.
* At **lag $2$** the digits *always* agree, again except at $O(\log M)$ positions: the pattern has period two. Agreement density $1$.

Contrast this with the dense number $D$, whose digits are $1$ except at lacunary positions. There, at *every* lag $r$, the digits agree away from an exceptional set of size at most $2\log_2 M + r + 2$. Agreement density $1$ for all $r$ simultaneously. Grafting both onto the prefix of $x$:

> **No finite prefix determines an autocorrelation law.** For every real $x$ and every $n$ there are irrational numbers $y$ and $z$, both agreeing with $x$ in the first $n$ decimal digits, such that $y$ has lag-$1$ agreement density $0$ and lag-$2$ agreement density $1$, while $z$ has agreement density $1$ at every lag.

Neither the value of the autocorrelation at a given lag, nor the *shape* of its dependence on the lag, is a function of any finite amount of data. A measured autocorrelation profile in the first $10^{12}$ digits of $\pi$ is a fact about those $10^{12}$ digits — a real fact, worth recording, sometimes worth being surprised by — but it is not evidence about $\pi$.

There is a small combinatorial subtlety hiding here that is worth flagging, because it is where the lag-$r$ arguments really bite. The exceptional positions for lag $r$ come from *two* shifted copies of the lacunary set — positions that are lacunary, and positions that become lacunary after a shift by $r$ — and to add up their sizes one needs the inequality $\log_2(M + r) \le \log_2 M + r$ for $M \ge 1$, an easy induction from $\log_2 (K+1) \le \log_2 K + 1$. With that, both exceptional sets are logarithmic and both densities are forced.

---

## What survives, and why it matters

None of this says that $\pi$ is not normal. Almost every real number is normal, $\pi$ is widely believed to be normal, and the computed digits are entirely consistent with normality. What the theorems say is that the computed digits *cannot be the reason*. The gap between "the first $N$ digits look uniform" and "the digits are uniform" is not a gap of degree, closable by computing further; it is a gap of kind, and grafting exhibits it explicitly at every $N$ at once.

Three practical morals follow.

**For the popular-science reader:** a statistic about a prefix is a statistic about a prefix. It is empirical data about a finite word. Sentences of the form "the digits of $\pi$ are random, as confirmed by computing $10^{13}$ of them" contain a genuine computation and an invalid inference.

**For the number theorist:** the resistance of normality proofs is not an accident of technique. Any proof that $\sqrt 2$ is normal must use something about $\sqrt 2$ beyond its digits up to any finite point — its algebraicity, or an equation it satisfies, or a dynamical property of the orbit $\{10^k \sqrt 2\}$. This is why we know that almost every number is normal and yet cannot name a single classical constant that is.

**For anyone who tests randomness:** the pattern is general. Finite samples underdetermine asymptotic laws, and the underdetermination can often be made explicit by a splice-and-graft construction of exactly this kind: keep the observed data, replace the unobserved future, verify that the replacement is still admissible. That is what the lacunary witnesses do here. They keep the face and swap the soul.

The digits of $\pi$ are beautiful. They are worth computing. Just don't ask them to testify about a future they have never seen.
