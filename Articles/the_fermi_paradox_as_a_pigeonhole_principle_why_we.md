# The Universe Is Empty Because It Is Supposed to Be

## A pigeonhole argument for why nobody is calling

In the summer of 1950, over lunch at Los Alamos, Enrico Fermi asked a question
that has haunted astronomy ever since: *Where is everybody?*

The reasoning behind the question is disarmingly simple. The galaxy is old — some
ten billion years. It is large — hundreds of billions of stars. Even a slow
civilization, creeping outward at a hundredth of the speed of light, would blanket
the Milky Way in a few tens of millions of years, an eyeblink on cosmic time. So
if intelligence arises with any regularity at all, the sky should be crowded. It
is not. We have listened for six decades and heard nothing but hydrogen.

This gap between expectation and observation is called the **Fermi paradox**. And
the word *paradox* is doing a great deal of unearned work.

A paradox is a contradiction between two things you have good reason to believe.
But the belief that "the sky should be crowded" is not an observation. It is the
output of a calculation — and the calculation, when you write it down carefully,
turns out to be a statement about an *average*. Averages are notoriously bad
witnesses. The average human has slightly fewer than two legs; almost nobody
does. The average lottery ticket is worth about fifty cents; virtually every
ticket is worth nothing.

What follows is an attempt to write the Fermi calculation down honestly — as a
theorem, not a slogan — and to see exactly what it predicts. The verdict is
striking. Under conservative but entirely mainstream numbers, an empty sky is not
merely *consistent* with the mathematics. It is the mathematics' confident
prediction. There is no paradox to resolve. There is only a first moment that
happens to be less than one.

---

## Counting pigeons, counting holes

The pigeonhole principle is the humblest theorem in mathematics: if you put more
pigeons than holes into a pigeon loft, some hole gets two pigeons. It is usually
deployed to force coincidences — two people in London with the same number of
hairs, two socks of the same colour in a drawer.

Applied to the cosmos, the intuition runs: civilizations are pigeons, moments in
history are holes, and if there are enough civilizations, two must land in the
same moment and meet.

But the pigeonhole principle has a shadow, a dual form that is exactly as true
and far less celebrated:

> **Dual pigeonhole.** If $c$ pigeons are placed in $T$ holes, then at least
> $T - c$ holes are empty.

This is trivial to prove — $c$ pigeons can occupy at most $c$ distinct holes — and
it is the version that matters here. Because the actual numbers in the Fermi
problem are not "many civilizations, few epochs." They are the reverse. There are
about $4.5 \times 10^{9}$ years in the history of the Earth-like universe, and,
as we will see, the expected number of technological civilizations that have ever
arisen anywhere in the observable universe may well be a *fraction of one*.

Very few pigeons. Enormously many holes. The pigeonhole principle, run in its
correct direction, predicts an overwhelmingly empty loft. The silence is the
theorem.

---

## Building the loft

To say anything precise we need a model. Here is the simplest one that captures
the physics without cheating.

Fix three numbers:

- $N$, the number of **habitable sites** in the observable universe — planets
  where life could in principle arise;
- $T$, the number of **epochs**, discrete time slots into which cosmic history is
  divided (say, one per year);
- $p$, the probability that a given habitable site **ever produces a
  technological civilization**.

An outcome of the universe is a function $f$ that assigns, to each of the $N$
sites, either the symbol *nothing* — the site never produced anyone — or a single
epoch $e$, the moment its civilization was born. The sites are independent. Each
one is barren with probability $1 - p$, and produces a civilization born in any
particular epoch with probability $p/T$.

That is the entire model. It is a finite probability space: the number of possible
universes is $(T+1)^N$, a stupendous but finite integer, and every event has an
exactly computable probability.

The engine that makes everything work is a factorization identity. Suppose you
specify, for each site $i$, a set $B_i$ of allowed states. Then

$$
\mathbb{P}\bigl(f(i) \in B_i \text{ for all } i\bigr) \;=\; \prod_{i=1}^{N} \; \sum_{x \in B_i} w(x),
$$

where $w(\text{nothing}) = 1-p$ and $w(\text{born in epoch } e) = p/T$. Global
questions become products of local answers. Every estimate below is this identity
plus a union bound.

---

## The Drake equation is an average, and that is all it is

In 1961 Frank Drake wrote down the famous product

$$
\mathcal{N} = R_* \cdot f_p \cdot n_e \cdot f_\ell \cdot f_i \cdot f_c \cdot L,
$$

a chain of factors estimating the number of communicating civilizations in the
galaxy. Sixty years of argument have gone into estimating the factors. Almost no
argument has gone into asking *what kind of quantity the left-hand side is*.

In our model the answer is unambiguous. Let $X$ count the sites that host a
civilization. Then:

> **The Drake equation is a first moment.** The expected number of technological
> civilizations is exactly
> $$\mathbb{E}[X] = N p.$$

The proof is a two-line calculation. Write $X$ as a sum of indicators, one per
site; the expectation of each indicator is the probability that its site is
civilized, which is exactly $p$ — the epoch variable integrates out, since a
civilization has to be born *some*time. Sum, and you get $Np$.

Notice the epoch count $T$ has vanished entirely. This is important and slightly
counterintuitive: giving the universe more time does not change how many
civilizations you expect. It only changes how thinly they are spread.

So $\mathcal{N}$ is an average. And an average, on its own, tells you almost
nothing about whether anything is actually out there. That is what the next
theorem is for.

---

## Emptiness is typical

How likely is it that the universe is *completely* lifeless — that not one of the
$N$ sites ever produced anyone? The factorization identity answers instantly:

> **Probability of a lifeless cosmos.**
> $$\mathbb{P}(\text{no civilization anywhere}) = (1-p)^N.$$

Now apply Bernoulli's inequality, $(1+x)^n \ge 1 + nx$ for $x \ge -2$, with
$x = -p$:

> **The emptiness bound.**
> $$\mathbb{P}(\text{no civilization anywhere}) \;\ge\; 1 - Np.$$

Read that again with the previous theorem in hand. The right-hand side is
$1 - \mathbb{E}[X]$: *one minus the Drake number*. So the moment the Drake
expectation drops below $1$, a completely empty universe becomes not just
possible but **likely** — with probability at least $1 - Np > 0$.

Is this bound wasteful? Barely. A short induction gives the matching upper
estimate $(1-p)^N \le 1 - Np + \tfrac{1}{2}N^2p^2$, and combining the two pins
down the probability that *somebody* exists to a narrow band:

> **Two-sided first-moment estimate.**
> $$Np - \tfrac{1}{2}(Np)^2 \;\le\; \mathbb{P}(\text{somebody exists}) \;\le\; Np.$$

When $Np$ is small, the Drake number *is* the probability that we have any
neighbours at all — accurate to within a quadratic correction. This is the honest
interpretation of the Drake equation, and it is not the one usually given. Drake's
$\mathcal{N}$ is not a headcount. When it is small it is a **probability**.

---

## Contact is quadratically rare

Existing is not the same as meeting. For two civilizations to make contact they
must both exist *and* overlap in time. This raises the bar dramatically, and the
mathematics shows exactly how.

Fix two distinct sites $i \ne j$ and two epochs. The factorization identity gives
the exact probability that site $i$ is born in the first and site $j$ in the
second:

$$
\mathbb{P}\bigl(f(i) = e,\; f(j) = e'\bigr) = \left(\frac{p}{T}\right)^{2}.
$$

Summing over the $T$ ways for the two births to coincide, a fixed pair of sites is
contemporaneous with probability at most $p^2/T$. Summing over the $N^2 - N$
ordered pairs of distinct sites gives the central estimate:

> **Contact bound.** The probability that the universe ever contains two
> contemporaneous civilizations satisfies
> $$\mathbb{P}(\text{contact}) \;\le\; \frac{(N^2 - N)\, p^2}{T} \;\le\; \frac{(Np)^2}{T} = \frac{\mathbb{E}[X]^2}{T}.$$

Every symbol in that formula is telling you something.

The **square** on $\mathbb{E}[X]$ is the reason optimism about contact is so
fragile. Contact is a pairwise event: halving the abundance of civilizations
quarters the chance of a meeting. And the **division by $T$** is the punchline of
this whole essay. *More time makes contact less likely.* A longer cosmic history
is not more opportunity — it is more holes to scatter the pigeons into. The
universe's vast age, usually cited as an argument that someone should have shown
up by now, is in the denominator.

---

## Long-lived civilizations do not save you

An obvious objection: civilizations are not points in time. If a culture stays
detectable for ten thousand years, near-misses become hits.

So let us grant it. Say a civilization born in epoch $e$ remains detectable for
$L$ epochs; two civilizations can meet if their birth epochs differ by less than
$L$. For a fixed birth epoch, at most $2L - 1$ other epochs lie inside that
window, so among the $T^2$ ordered pairs of epochs at most $T(2L-1)$ are
compatible with contact. Feeding this count into the same union bound:

> **Windowed contact bound.** If every civilization is detectable for $L$ epochs,
> $$\mathbb{P}(\text{contact}) \;\le\; (N^2 - N)\,\frac{(2L-1)\,p^2}{T}.$$

Setting $L = 1$ recovers the previous bound. But look at the *shape* of the
dependence. The lifetime $L$ enters **linearly**; the abundance $p$ enters
**quadratically**. Doubling how long civilizations last roughly doubles the
chance of contact. Doubling how often they arise quadruples it.

This is a concrete piece of advice for anyone reasoning about the Drake equation,
and it cuts against the received wisdom. The lifetime factor $L$ is traditionally
treated as the great unknown, the term on which everything hinges. In the
mathematics of *contact*, it is the weakest lever on the board.

---

## Pigeonhole, restored to its correct orientation

Now we can close the circle. Suppose an outcome of the universe contains $c$
civilizations, scattered across $T$ epochs. Three purely combinatorial facts hold,
with no probability at all:

> **Quantitative pigeonhole.** If $T \cdot n < c$, some single epoch contains more
> than $n$ civilizations. In particular, if $c > T$, two distinct civilizations
> are contemporaries and contact is *forced*.

> **Sharpness.** If $c \le T$, there exists a schedule of birth epochs in which no
> two civilizations are contemporaries. The threshold $c = T$ is exact: below it,
> pigeonhole forces nothing whatsoever.

> **Dual pigeonhole.** At least $T - c$ of the $T$ epochs contain no civilization
> at all.

The first is the version everyone reaches for when they invoke pigeonhole in a
cosmic setting. It requires more civilizations than years of cosmic history — a
condition off by a factor of billions in the wrong direction.

The third is the one that applies. Marrying it to the first-moment theorem gives
the central quantitative statement of this work:

> **Expected emptiness.** The expected number of epochs containing no civilization
> anywhere in the universe satisfies
> $$\mathbb{E}[\#\{\text{empty epochs}\}] \;\ge\; T - Np.$$

When the Drake expectation $Np$ is below $1$, this says that **all but at most one
of the $T$ epochs of cosmic history are expected to be completely empty**. Not
"probably empty." Expected to be empty, on average, all of them but a fraction of
one.

---

## The dichotomy

Bundle everything together and you get a single clean statement. Write
$\mathcal{E} = Np$ for the Drake expectation.

> **The Fermi dichotomy.** If $\mathcal{E} < 1$, then simultaneously:
> 1. the universe is completely lifeless with probability at least
>    $1 - \mathcal{E} > 0$;
> 2. contact ever occurring has probability at most $1/T$;
> 3. more than $T - 1$ of the $T$ epochs are expected to be empty.

Three predictions from one hypothesis. And the hypothesis is not exotic — it is
just the statement that the average number of civilizations is less than one.

---

## Running the numbers

Time to be concrete. Take conservative but defensible values:

- $N = 10^{10}$ habitable sites in the observable universe;
- $T = 4.5 \times 10^{9}$ epochs of one year each;
- $p = 10^{-11}$, the chance that a given habitable world ever produces a
  technological civilization.

That value of $p$ is the crux, and it is where the honest uncertainty lives. It is
the product of the probability of abiogenesis, of the emergence of complex cells,
of multicellularity, of intelligence, and of technology — a chain of five or more
contingent transitions on Earth, several of which took a billion years and
happened exactly once. If each has probability a few times $10^{-3}$ — and there
is nothing in the fossil record forbidding that — their product lands right here.

The theorems then yield, with no further assumptions:

- **Expected number of technological civilizations:** exactly $\mathcal{E} = Np = 0.1$.
- **Probability the universe is completely lifeless:** at least $0.9$.
- **Probability that anyone at all exists:** between $0.095$ and $0.1$.
- **Probability that contact ever occurs:** at most $10^{-11}$.
- **Probability of contact, granting every civilization ten thousand years of
  detectability:** still at most $10^{-7}$.
- **Expected number of empty years of cosmic history:** at least
  $4\,499\,999\,999.9$ out of $4\,500\,000\,000$.

We observe silence. The model predicts silence with probability $0.9$, and
predicts that even in the $10\%$ of universes containing somebody, contact is
essentially impossible. The observation and the prediction agree. That is not a
paradox; that is a successful theory.

---

## What this does and does not say

Let us be scrupulous about the logic, because it is easy to overclaim.

**This is not a proof that we are alone.** It is a conditional: *if* the per-planet
probability of technological life is around $10^{-11}$, *then* silence is expected.
The mathematics does not tell you $p$. Nothing currently known does.

**What it does establish is that no additional explanation is required.** The
"paradox" motivated an entire literature of exotic resolutions: Great Filters
behind us or ahead of us, zoo hypotheses, dark forests, simulation arguments,
civilizations that reliably self-destruct. Each posits some mechanism that
suppresses the visible population below what the Drake calculation "predicts."

But the Drake calculation predicts no such thing. It computes an average. And when
that average is below one, the theorems above show that emptiness is the typical
outcome, contact is quadratically suppressed, and nearly every epoch of history is
vacant. The exotic mechanisms are solutions to a problem that a careful reading of
the first moment dissolves.

There is a real inferential payoff here, and it runs backwards. Because the
first-moment estimate is *two-sided* — $\mathbb{P}(\text{somebody exists})$ is
squeezed between $Np - \tfrac{1}{2}(Np)^2$ and $Np$ — the observation of silence
constrains $p$ rather than demanding a new mechanism. Every century of null SETI
results is a Bayesian update on a single number, not evidence for a Great Filter.

**And the structural lessons survive regardless of $p$.** These are unconditional:

- The Drake number is a mean, and when it is small it should be read as the
  probability that anyone exists, not as a headcount.
- Contact scales as the *square* of abundance and *inversely* with available time.
  Cosmic vastness in time is an obstacle to meeting, not an opportunity.
- Civilization lifetime is a linear lever; abundance is a quadratic one. If you
  want to argue for a populated galaxy, argue about $p$, not about $L$.
- The pigeonhole principle, applied with the actual counts, predicts empty holes.

---

## The silence, correctly heard

There is a certain grandeur in the reframing. For seventy years the empty sky has
been treated as an anomaly demanding explanation — a cosmic mystery, a warning, a
riddle with a sinister answer.

It is none of those. It is a consequence of a small number multiplied by a large
one and coming out under unity. Very few pigeons, unimaginably many holes: most
holes are empty, and ours is one of them.

That answer is, in its way, more sobering than any Great Filter. There is no
mechanism suppressing our neighbours, no filter ahead to fear, no zookeepers
watching. There is just a probability, and it is small, and the universe is doing
exactly what the arithmetic says it should.

We are not being ignored. We are early, we are rare, and we are — with probability
about nine in ten — the only ones who ever were.
