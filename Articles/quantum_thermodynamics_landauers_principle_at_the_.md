# The Price of Forgetting: Landauer's Principle at the Nanoscale

## A thought that costs energy

Imagine you are cleaning up your desk at the end of a long day. You crumple a
scribbled note and toss it in the bin. The note is gone, your desk is tidy, and
it feels as though nothing of consequence has happened. But if that note were a
single bit of information stored in a microscopic memory, physics would send you
a bill. Erasing it — truly destroying the information it held — releases a tiny,
unavoidable puff of heat into the surrounding world.

That bill has a name and a price. The name is **Landauer's principle**, after
Rolf Landauer, who in 1961 argued that *logical irreversibility* — the act of
throwing information away — must be paid for in *thermodynamic irreversibility*,
the generation of heat. The price is

$$E[W] \ge k T \ln 2,$$

where $k$ is Boltzmann's constant, $T$ is the temperature of the environment, and
$\ln 2 \approx 0.693$. At room temperature this is about $3 \times 10^{-21}$
joules per bit — almost nothing, yet stubbornly *not zero*. It is the smallest
amount of energy the universe will accept in exchange for forgetting.

For decades this was a profound but informal statement, argued with pictures of
pistons and gases and a great deal of physical intuition. This article tells the
story of how that intuition can be turned into a chain of fully rigorous
mathematical theorems — and, in the process, sharpened into something more
precise than the textbook slogan. We will see exactly *why* forgetting costs
energy, what happens when memories are tiny and noisy, and how the famous bound
is only the average of a far richer story.

## Information has a shape: entropy

Before we can talk about the *cost* of erasing information, we need to measure
*how much* information there is. The right ruler is **Shannon entropy**. If a
system can be in several states, and state $\omega$ occurs with probability
$p(\omega)$, then the entropy is

$$H(p) = -\sum_\omega p(\omega) \ln p(\omega),$$

with the natural convention that a state of probability zero contributes nothing.
Entropy is largest when we are maximally uncertain and smallest when we are
certain.

Consider the humblest memory of all: a single bit, equally likely to be $0$ or
$1$. Each outcome has probability $\tfrac12$, and the entropy works out to
exactly

$$H = -\tfrac12 \ln \tfrac12 - \tfrac12 \ln \tfrac12 = \ln 2.$$

Now erase it: force the bit to read $0$ no matter what it was before. The erased
bit has probability $1$ of being $0$ and probability $0$ of being $1$. There is
no uncertainty left, so its entropy is exactly $0$. The information that
vanished is the difference,

$$H_{\text{before}} - H_{\text{after}} = \ln 2 - 0 = \ln 2.$$

This number, $\ln 2$, is the same $\ln 2$ that appears in Landauer's bound. That
is not a coincidence; it is the whole point. The lost information, measured in
*nats* (the natural-logarithm cousin of bits), is converted at a fixed exchange
rate of $kT$ joules per nat into dissipated heat.

Why must erasure lose information at all? Because erasure is a *many-to-one* map:
both the input $0$ and the input $1$ are sent to the same output $0$. The map
that does the erasing cannot be undone — knowing the output tells you nothing
about the input. This is *logical irreversibility*, and it can be stated with
complete precision: the erasure function on bits is **not injective**. Two
different inputs share one output. That single, almost trivial-sounding fact is
the seed from which the entire thermodynamic cost grows.

## From logic to heat: the bridge

Here is the central claim, made sharp. Suppose a physical device erases a bit,
and suppose its operation obeys a remarkable law of nonequilibrium physics — the
**Jarzynski equality** — which we will meet in a moment. Then two things are true
simultaneously:

1. The erasure map is not injective (logical irreversibility).
2. The average work the device must dissipate is *strictly positive*
   (thermodynamic irreversibility).

The first is a statement about abstract functions; the second is a statement
about energy and heat. The bridge between them is Landauer's principle, and it
can be proved as a theorem rather than asserted as a philosophy. Logical
irreversibility *forces* thermodynamic irreversibility. You cannot forget for
free.

## The Jarzynski equality: a window into fluctuations

How does a physicist model the act of erasure? Not as a smooth, idealized,
infinitely slow process, but as a real, jittery, finite operation in which the
work done varies from one run to the next. Push a microscopic bit around with
electric fields and on one run you might do a bit more work, on the next a bit
less — thermal noise sees to that. So the work $W$ is a random variable, and what
we can hope to control is its statistics.

The astonishing **Jarzynski equality** (Christopher Jarzynski, 1997) says that no
matter how violently or quickly you drive the system, a particular average is
pinned exactly:

$$E\!\left[e^{-\alpha W}\right] = e^{-\alpha \,\Delta F}.$$

Here $\alpha = 1/(kT)$ is the inverse temperature and $\Delta F$ is the
free-energy difference between the start and end of the process — for one-bit
erasure, $\Delta F = kT \ln 2$. The left side averages the *exponential* of the
work; the right side depends only on $\Delta F$, an equilibrium quantity. Out of
this single identity, everything else flows.

The first thing it yields is an *exact* accounting of the average work. A short
calculation rearranges the Jarzynski equality into

$$E[W] = \Delta F + \frac{1}{\alpha} \ln E\!\left[e^{-\alpha (W - E[W])}\right].$$

The mean work equals the free-energy cost $\Delta F$ *plus* a correction built
entirely from the fluctuations of the work around its own average. This is the
**finite-size Landauer identity**. It is not an inequality and not an
approximation; it is an equality valid for memories of any size, however small
and however noisy.

## Why the bill is never negative

The correction term hides the second law in plain sight. The quantity inside the
logarithm,

$$E\!\left[e^{-\alpha (W - E[W])}\right],$$

is an average of an exponential of a quantity whose own average is zero. And here
a beautifully elementary inequality does all the work: for every real number $x$,

$$1 + x \le e^{x}.$$

Average both sides over the fluctuations. The left side averages to
$1 + 0 = 1$, because the centered work $W - E[W]$ has mean zero by construction.
The right side is exactly our correction factor. Therefore

$$E\!\left[e^{-\alpha (W - E[W])}\right] \ge 1.$$

The logarithm of something at least $1$ is at least $0$, so the correction term
is never negative. Feeding this back into the identity gives the **second law**
in its cleanest form,

$$\Delta F \le E[W],$$

and, with $\Delta F = kT\ln 2$, the headline result:

$$kT \ln 2 \le E[W].$$

No convexity machinery, no thermodynamic hand-waving — just $1 + x \le e^x$ and
the Jarzynski equality. The puff of heat is unavoidable because an exponential
curves upward.

## When is the bill exactly $kT\ln 2$?

A natural question: can we ever pay *exactly* the Landauer minimum, with not a
joule wasted? The mathematics answers precisely. The correction term vanishes —
and the bound is saturated — *if and only if* the work is constant across every
outcome that actually occurs. In physical language, the dissipated work must have
**no fluctuations** at all. This is the idealized, infinitely slow,
quasi-static, reversible limit beloved of textbooks. Any real, fluctuating
erasure does *strictly* better than break even for the universe and strictly
worse for you: it dissipates *more* than $kT\ln 2$. The textbook number is not a
typical cost but a perfect-world floor that genuine devices only approach.

## The bill comes with a guarantee against fraud

The bound $kT\ln 2$ is an average. Could a lucky individual run cheat it,
dissipating less? Occasionally, yes — thermal fluctuations sometimes lend a hand.
But the Jarzynski equality also caps how often, and by how much, such "violations"
can happen. If you ask for the probability that a single erasure undershoots the
free-energy cost by a margin $\xi$, the answer is bounded by

$$\Pr\!\big[\,W < \Delta F - \xi\,\big] \le e^{-\alpha \xi} = e^{-\xi/(kT)}.$$

Large violations are not impossible, merely *exponentially* improbable. Undershoot
the Landauer cost by a few $kT$ and the odds collapse to essentially nil. And as
the margin $\xi$ grows, this ceiling strictly decreases — bigger miracles are
rarer miracles. The second law, at the nanoscale, is not an iron prohibition but
an overwhelming statistical tendency, with the exact odds written down.

## Scaling up: memories, registers, and the thermodynamic limit

One bit was just the beginning. Real memories hold many bits. An $n$-bit register
that is completely scrambled — every one of its $2^n$ configurations equally
likely — carries the maximal entropy

$$H = \ln(2^n) = n \ln 2.$$

Erasing it must therefore cost at least

$$E[W] \ge n \, kT \ln 2,$$

and the cost *per bit* is exactly $kT\ln 2$ for every register size. Landauer's
bound is **extensive**: double the memory and you double the minimum heat. This is
the genuine "thermodynamic limit," and it is not an asymptotic statement that
only holds for huge $n$; it is exact for each $n$.

What if the memory is not uniformly scrambled but biased — some configurations
likelier than others? Then the relevant cost is $kT \cdot H(p)$, with $H(p)$ the
actual entropy of the memory's distribution, and a clean theorem shows this can
never exceed the uniform-memory cost $kT \ln N$. The maximally ignorant memory is
the most expensive to erase, because it holds the most information to destroy.

## A second face: the cost as a "distance from equilibrium"

There is an entirely different way to see Landauer's cost, through a quantity
called **relative entropy** (or Kullback–Leibler divergence). Given an actual
distribution $p$ and a reference equilibrium $q$, it is

$$D(p \,\|\, q) = \sum_\omega p(\omega) \ln \frac{p(\omega)}{q(\omega)}.$$

It measures how far $p$ sits from $q$ — a kind of one-directional distance. A
cornerstone result, **Gibbs' inequality**, says this distance is never negative:

$$D(p \,\|\, q) \ge 0,$$

with equality only when $p$ and $q$ coincide. The proof again rests on
$\ln x \le x - 1$: each term obeys
$p(\omega)\ln\frac{p(\omega)}{q(\omega)} \ge p(\omega) - q(\omega)$, and summing,
the right side collapses to $\sum p - \sum q = 1 - 1 = 0$.

Now take $p$ to be the *erased* bit and $q$ the *uniform* bit. The relative
entropy comes out to exactly $\ln 2$ — the very same number again. Landauer's cost
$kT\ln 2$ is therefore $kT$ times the "distance" of the erased state from
equilibrium. The free energy you must dissipate is precisely the free energy
stored in being out of equilibrium, and Gibbs' inequality guarantees this is
never something the universe pays you. Two completely different accountings —
entropy *lost* and distance *travelled* — agree to the last digit. That agreement
is itself a theorem.

## Reversible computing: the loophole that proves the rule

If forgetting costs energy, can we compute without forgetting? Strikingly, yes —
in principle. A computation that never discards information corresponds to an
*injective* (one-to-one) map: distinct inputs always give distinct outputs, so no
two histories ever merge. For such a map the entropy is unchanged, and the
Landauer cost is exactly **zero**. A *deterministic data-processing inequality*
makes the general statement: any deterministic operation can only *decrease* or
preserve entropy, never increase it, and the heat it must dissipate,
$kT\,(H_{\text{before}} - H_{\text{after}})$, is correspondingly nonnegative —
vanishing precisely in the reversible, injective case.

This is the theoretical foundation of **reversible computing**, the dream of
machines that compute by shuffling information rather than destroying it, sliding
under the Landauer bound because they never trigger it. The cost is not in the
logic gates themselves but in the eventual cleanup — the moment you finally erase
the scratch work and reset the memory.

## Why it matters

These are not idle abstractions. Modern processors dissipate energy enormously
above the Landauer limit — by factors of thousands or more — but the gap is
closing as devices shrink toward the scale where single electrons and single bits
matter. The fundamental floor set by $kT\ln 2$ is now within experimental reach;
laboratories have measured the heat of erasing single bits and confirmed the
bound. As computing pushes toward its physical limits, the thermodynamics of
information stops being philosophy and becomes engineering.

And there is a deeper resonance. Landauer's principle is the sharpest knife we
have for dissecting the old paradox of **Maxwell's demon**, the imaginary being
who seems to violate the second law by sorting fast molecules from slow ones. The
resolution is that the demon must *remember* what it measures, and eventually
must *forget* — paying back, in erasure heat, exactly what it appeared to gain.
Information is physical. To know costs nothing in principle, but to forget costs
$kT\ln 2$, and the universe keeps perfect books.

## The view from the summit

What began as Landauer's intuition — that logic and heat are secretly the same
ledger — can be assembled into a tower of exact results. A single bit obeys a
hard floor of $kT\ln 2$. Finite, noisy memories obey an *exact identity* in which
that floor is corrected by their own fluctuations, a correction that is provably
nonnegative and vanishes only in the reversible limit. Individual runs may dip
below, but only with exponentially small probability. Many-bit registers pay
extensively, $n\,kT\ln 2$. The cost wears two faces, entropy lost and distance
from equilibrium, and they always agree. And the whole edifice rests on
inequalities a curious student could check by hand: $1 + x \le e^x$ and
$\ln x \le x - 1$.

The next time you delete a file, spare a thought for the heat. It is small,
it is fundamental, and it is the universe quietly reminding you that even thinking
has a thermodynamic price.
