# The Price of Forgetting: Why Erasing a Bit Always Costs Heat

## A puzzle at the edge of physics and logic

Imagine a tiny switch that can be either *on* or *off* — a single bit of memory.
Flipping it back and forth seems like the most innocent thing in the world. But ask a
sharper question: what does it cost, in raw physical energy, simply to *forget* what the
switch was holding — to reset it to *off* no matter where it started?

The astonishing answer, first glimpsed by Rolf Landauer in 1961, is that forgetting is
not free. Erasing one bit of information must dissipate at least

$$k T \ln 2$$

joules of heat into the surrounding world, where $T$ is the temperature and $k$ is
Boltzmann's constant. At room temperature this is a minuscule $3 \times 10^{-21}$ joules —
far too small to notice in your laptop today. But it is not zero, and it is not negotiable.
It is a hard floor written into the laws of thermodynamics. As we push computers toward the
nanoscale, where each logical operation jostles only a handful of atoms, this floor stops
being a curiosity and starts being a wall.

This article tells the story of *why* that wall exists, and how the whole of Landauer's
principle — usually phrased in the heavy language of statistical mechanics — turns out to
rest on a single, almost embarrassingly simple, piece of mathematics about counting.

## Information, measured

To talk about "the cost of forgetting," we first need to measure how much there is to
forget. The right yardstick is **Shannon entropy**. Suppose a system can be in several
states, and state $x$ occurs with probability $p(x)$. The Shannon entropy of that
probability distribution is

$$H(p) = -\sum_x p(x)\,\log p(x).$$

You can read $H(p)$ as the average number of yes/no questions you'd need to ask to pin down
the state — or, equivalently, as the amount of *uncertainty* you carry about it. A fair coin
($p = (\tfrac12, \tfrac12)$) has entropy $\log 2$, one bit. A coin you already know the
result of has entropy $0$: there is nothing left to learn.

Here is the crucial reframing. **Computation is a function.** A logic gate, a memory reset,
an arithmetic step — each takes an input state $x$ and deterministically produces an output
state $f(x)$. If your input is random, described by a distribution $p$, then your output is
also random, described by a new distribution. That new distribution has a name: the
**pushforward** of $p$ along $f$, written $f_* p$. Its recipe is simply to gather up
probability:

$$(f_* p)(y) = \sum_{x \,:\, f(x) = y} p(x).$$

In words: the probability of landing on output $y$ is the total probability of all the
inputs that get mapped to $y$ — the inputs in the *fiber* over $y$.

## The one idea that does all the work

Now comes the heart of the matter, and it is a counting observation a child could verify.
Fix an input $x$. It lands on the output $f(x)$. The fiber over $f(x)$ — the set of all
inputs that share that destination — certainly *contains* $x$ itself. Since probabilities
are never negative, the total weight of the fiber is at least the weight of that one
member:

$$p(x) \le (f_* p)(f(x)).$$

That's it. A bucket holds at least as much as any single grain you drop into it. From this
one inequality, the entire edifice of Landauer's principle unfolds.

Watch how. The entropy of the output distribution can be rewritten — by regrouping the sum
fiber by fiber — as a sum back over the *inputs*:

$$H(f_* p) = -\sum_x p(x)\,\log\big((f_* p)(f(x))\big).$$

Subtract this from the input entropy $H(p) = -\sum_x p(x)\log p(x)$ and the difference
telescopes into something beautifully transparent:

$$H(p) - H(f_* p) = \sum_x p(x)\,\Big(\log\big((f_* p)(f(x))\big) - \log p(x)\Big).$$

Every term in that sum is non-negative. Why? Because $p(x) \le (f_* p)(f(x))$ from our
bucket observation, and the logarithm is an increasing function, so each parenthesized
difference is $\ge 0$, and each is weighted by the non-negative probability $p(x)$. A sum of
non-negative things is non-negative. Therefore:

$$\boxed{\,H(f_* p) \le H(p)\,}$$

**A deterministic computation can never increase entropy.** This is the *data-processing
inequality*, and it is the true mathematical content of Landauer's principle. Running a
program can only ever destroy uncertainty, never create it. Information, once funneled
together, cannot spontaneously un-funnel.

## When forgetting is free, and when it costs

The inequality $H(f_* p) \le H(p)$ has a razor-sharp boundary case. When does *equality*
hold — when does a computation lose nothing at all?

The answer is exactly when the map $f$ is **injective** (one-to-one): no two distinct inputs
share an output. In that case every fiber is a single point, the bucket holds exactly one
grain, $(f_* p)(f(x)) = p(x)$, and every term in our telescoping sum is zero:

$$f \text{ injective} \;\Longrightarrow\; H(f_* p) = H(p).$$

An injective computation is **logically reversible**: from the output you can always
reconstruct the input. And logical reversibility, we now see, means *thermodynamic*
reversibility — no entropy is destroyed, so no heat need be paid. This is the precise,
provable bridge between the two senses of "reversible," one logical and one physical, that
Landauer and later Charles Bennett intuited.

To convert entropy into energy we invoke the thermodynamic dictionary: dissipated heat is
temperature times the entropy destroyed. If a process at temperature $T$ runs the map $f$ on
a distribution $p$, the heat it must release is

$$W = k\,T\,\big(H(p) - H(f_* p)\big).$$

Because the entropy difference is never negative (our boxed inequality), and because $k$ and
$T$ are non-negative physical quantities, we conclude:

$$W = k\,T\,\big(H(p) - H(f_* p)\big) \;\ge\; 0.$$

**Landauer's lower bound.** No deterministic computation can dissipate negative heat — you
cannot run a logic gate and *extract* free energy from the destruction of information. And
the only computations that are thermodynamically free are precisely the reversible ones,
for which $W = 0$ exactly.

## The iconic $kT\ln 2$, recovered

Where does the famous "one bit costs $kT \ln 2$" come from? It is the most extreme case of
everything above: total forgetting.

Consider a register of $n$ bits that is completely random — all $2^n$ patterns equally
likely, each with probability $2^{-n}$. Its entropy is

$$H = -\sum_{x} 2^{-n} \log(2^{-n}) = n \log 2.$$

Now apply the ultimate erasure: the map $f$ that sends *every* pattern to the single state
"all zeros." This $f$ is as far from injective as possible — its single fiber is the entire
input space. The output is certain (entropy $0$), so the entropy destroyed is the whole
$n \log 2$, and the heat dissipated is

$$W = k\,T \cdot n \log 2.$$

For a single bit, $n = 1$, and we land exactly on Landauer's celebrated constant,

$$W = k\,T \ln 2.$$

Erasure is the *collapse-to-a-point* limit of the data-processing inequality. The general
theorem we proved is not a different statement from Landauer's bound — it is the parent of
which $kT\ln 2$ is one particularly dramatic child.

## Why a tiny number matters more every year

For decades $kT\ln 2$ was a footnote. A modern transistor squanders *billions* of times that
energy on each switch, lost to leakage and resistance long before any fundamental limit
comes into play. Engineers optimizing chips had bigger fish to fry.

But the trend lines are unforgiving. Every generation packs transistors closer, drives
voltages lower, and shaves the energy per operation. Extrapolate far enough and you arrive
at the Landauer wall — the point where the very act of discarding a bit's worth of
uncertainty dominates the energy budget. You cannot engineer your way past it with cleverer
materials or smaller wires, because it is not a property of any device. It is a property of
*forgetting itself*, baked into the relationship between information and entropy.

There is, however, a loophole hiding in our theorems, and it is the most hopeful part of the
story. The cost is incurred *only* when entropy is destroyed — only when the computation is
many-to-one. The reversible computations, the injective maps, pay nothing:
$f$ injective $\Rightarrow W = 0$. This is the seed of **reversible computing**: if you
design logic that never throws information away — that keeps enough of a record to run
backward — you sidestep the Landauer toll entirely. Bennett showed in the 1970s that *any*
computation can in principle be rearranged into a reversible one, copying out its answer and
then carefully un-computing its scratch work. The price is memory rather than heat. Our
result is the clean statement of why that trade is even possible: information destruction,
not computation, is what costs energy.

## The shape of certainty

What makes this story satisfying is how little machinery it actually needs. The usual
textbook derivation of the data-processing inequality reaches for the concavity of entropy,
Jensen's inequality applied fiber by fiber, and a fair amount of convex-analysis
bookkeeping. All of that can be swept away. The entire result rests on one childlike fact —
*a bucket holds at least as much as a single grain dropped into it*, $p(x) \le (f_*p)(f(x))$
— plus the monotonicity of the logarithm. Every other step is honest arithmetic:
re-summing, telescoping, and adding up non-negative numbers.

That economy is not just aesthetic. It is what let the whole chain of reasoning be checked,
line by line, with complete rigor: the pushforward really is a probability distribution; its
entropy really is no larger than the original's; injective maps really do preserve it
exactly; and the dissipated heat really is non-negative, vanishing precisely for reversible
computations. There are no gaps, no "it can be shown," no appeals to physical intuition
standing in for proof.

Landauer once wrote that "information is physical." The mathematics here makes the slogan
exact. To forget is to merge distinct possibilities into one, to shrink the space of what
might have been. That merging has a measure — the drop in entropy — and that measure has a
price in heat. The wall at $kT\ln 2$ is simply the smallest possible act of forgetting,
seen from the inside. And the only way over the wall is never to forget at all.
