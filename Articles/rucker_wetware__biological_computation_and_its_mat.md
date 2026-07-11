# Wetware: The Hidden Bargain of Thinking Machines

Somewhere behind your eyes, roughly eighty-six billion neurons are trading
electrochemical whispers. That wet, warm, three-pound organ is the most
capable computer we know of, and it runs on about twenty watts — less than the
light bulb in your refrigerator. A data center trained to imitate a fraction of
what it does can burn through the output of a small power plant. Why is the
brain such a bargain? What, exactly, is it paying for, and what is it getting
for free?

This article is about a precise answer to that question. Strip away the biology
and the silicon, and a computer — any computer — is a rule that turns one state
of the world into the next. Apply the rule again and again, and computation
happens. From this bare skeleton we can prove three things: that such systems
are genuinely universal computers on finite data; that a machine with finitely
many parts must eventually repeat itself; and — the heart of the story — that
the *style* of computation the brain seems to use is dramatically cheaper to
specify than the style silicon uses. The gap is not a rounding error. It is the
difference between a cost that grows like $n \log n$ and one that grows like
$n^2$, and asymptotically the cheaper one becomes an infinitely small fraction
of the other.

## Computation as iterated change

Forget wires and axons for a moment. Picture the complete condition of a
machine — every voltage, every synapse, every bit — as a single point in an
abstract "state space" $S$. Computation is nothing more than a rule for moving
that point. Call the rule the **step map**, a function

$$\text{step} : S \to S.$$

To *run* the machine is to apply the step map over and over. After $t$ ticks of
the clock, a machine that started in state $x$ has arrived at

$$\mathrm{run}(t, x) = \underbrace{\text{step}(\text{step}(\cdots \text{step}}_{t \text{ times}}(x)\cdots)).$$

This is what we call a **wetware system**: a state space together with a step
map. It is deliberately spartan. A pocket calculator, a spreadsheet
recalculating its cells, a spiking neural circuit, a Turing machine grinding
across its tape — all are wetware systems for the right choice of $S$ and
$\text{step}$.

One small fact turns out to be the backbone of everything: running for $s + t$
steps is the same as running for $t$ steps and then for $s$ more. In symbols,

$$\mathrm{run}(s + t, x) = \mathrm{run}\big(s, \mathrm{run}(t, x)\big).$$

This is the **flow law**. It says that time in a computation adds up the way
time always does; the machine has no memory of *when* it started, only of
*where* it is now. Mathematically, it makes running the system an action of the
natural numbers under addition — the clean algebraic core of "iterating a
process." Every further result leans on it.

## Everything is computable — if the data is finite

The first surprise is how little you need for universality. Suppose you have
*any* function $f$ that turns inputs of one kind into outputs of another —
a lookup table, a decision rule, a translation from questions to answers. Can a
wetware system compute it?

Yes, always. Here is the construction. Let the state space be big enough to hold
either a *pending input* or a *finished output* — think of it as a scratchpad
with two compartments. To feed the machine an input $x$, drop $x$ into the input
compartment; that is the **encoder**. The step map does exactly one thing: if it
sees a pending input $x$, it writes $f(x)$ into the output compartment; if it
already sees an output, it leaves it alone. After a single tick, the answer is
sitting in the output compartment, and a **decoder** reads it off. Formally,
every function $f$ is *computed* by some wetware system, meaning there exist an
encoder and a decoder such that

$$\text{decode}\big(\mathrm{run}(1, \text{encode}(x))\big) = f(x) \quad \text{for every input } x.$$

This is the finite-data cousin of the famous fact that neural networks are
Turing-complete. It tells us the *model itself* imposes no ceiling: iterated
step maps can, in principle, realize any input–output behavior. The interesting
constraints live elsewhere — in *resources*, not in *expressiveness*.

## A machine with finitely many parts must repeat itself

The second result is a limit, and it comes for free from counting. Suppose the
state space is **finite** — say the machine has a fixed, bounded number of
distinguishable configurations, as any physical device does. Watch its orbit:
the sequence of states $\mathrm{run}(0,x), \mathrm{run}(1,x), \mathrm{run}(2,x),
\dots$ There are infinitely many time steps but only finitely many states, so by
the pigeonhole principle two different times must land on the same state. There
exist $i < j$ with

$$\mathrm{run}(i, x) = \mathrm{run}(j, x).$$

Once a deterministic system revisits a state, it is trapped: from that moment on
it retraces the same loop forever. Every orbit is **eventually periodic**. A
finite machine, run by pure iteration, cannot produce genuinely novel behavior
indefinitely — it must fall into a cycle. This is a hard geometric boundary on
biological computation: unbounded novelty demands either unbounded state or a
source of fresh randomness from outside. The brain's apparent open-endedness is
a clue that its effective state space is astronomically, but not infinitely,
large — and that it is constantly re-fed by a changing world.

## The bargain: the price of determinism versus the price of connection

Now to the centerpiece. We want to compare two disciplines of hardware, both
built from $n$ elementary units — call them neurons — and ask a sharp question:
*how much information does it take to specify one machine?* This is a fair proxy
for its cost. Every distinguishable configuration must be pinned down, and the
number of bits needed is the base-2 logarithm of how many configurations there
are. This quantity is the configuration's **Shannon information**; we will call
it the machine's **energy**, because to build, wire, or hold a configuration in
place is to pay for that information.

**Wetware.** In the biological style, each of the $n$ neurons deterministically
points to a single successor state — the system is a definite transition rule,
one arrow out of every node. A deterministic transition map on $n$ states is a
function from an $n$-element set to itself, and there are exactly

$$n^n$$

of them. The information needed to name one is therefore

$$\mathrm{wetwareEnergy}(n) = \log_2\!\big(n^n\big) = n \log_2 n \text{ bits}.$$

So the wetware discipline costs $\Theta(n \log n)$ bits — it grows just a hair
faster than linearly.

**Silicon.** In the engineered style, we allow an *arbitrary* pattern of
connections: for each ordered pair of neurons, a wire is either present or
absent. That is a binary connection matrix, a function assigning a bit to each
of the $n^2$ pairs, and there are

$$2^{(n^2)}$$

of them. Naming one costs

$$\mathrm{siliconEnergy}(n) = \log_2\!\big(2^{(n^2)}\big) = n^2 \text{ bits}.$$

The silicon discipline costs $\Theta(n^2)$ bits — quadratic in the number of
units.

Two theorems make the comparison exact.

**The strict bargain.** For every $n \ge 1$,

$$n \log_2 n < n^2,$$

so wetware is *always* cheaper to specify than silicon. The proof is a
one-liner in disguise: since $n < 2^n$ for all $n$, taking base-2 logarithms
gives $\log_2 n < n$, and multiplying both sides by the positive quantity $n$
yields $n \log_2 n < n^2$.

**The asymptotic bargain.** Far more striking is what happens in the limit. The
ratio of the two costs is

$$\frac{\mathrm{wetwareEnergy}(n)}{\mathrm{siliconEnergy}(n)} = \frac{n \log_2 n}{n^2} = \frac{\log_2 n}{n},$$

and as $n$ grows without bound this tends to **zero**:

$$\lim_{n \to \infty} \frac{n \log_2 n}{n^2} = 0.$$

The information cost of *determinism* is not merely smaller than the cost of
arbitrary *connectivity* — it becomes a vanishingly small fraction of it. Double
the number of neurons in a silicon design and you roughly quadruple its
specification cost; do the same in a wetware design and you barely more than
double it. At brain scale, with $n$ in the tens of billions, $\log_2 n$ is only
about thirty-six. The deterministic discipline pays that tiny multiplier where
the connectionist discipline pays the full factor of $n$.

## What the bargain means

The mathematics is clean, but its resonance is broad. Two abstract accounting
schemes — one from *enumerative combinatorics* (how many machines are there?)
and one from *asymptotic analysis* (how does a ratio behave at infinity?) — turn
out to tell a single story about efficiency. The bridge between them is a
logarithm.

The lesson is not that biology beats engineering at every task; a wetware
transition map, being deterministic, cannot express the same wild variety of
wiring that an arbitrary connection matrix can. The lesson is subtler and more
beautiful: *constraint is cheap*. By committing to a definite next step rather
than an open sea of possible connections, a system slashes the information it
must carry from quadratic to nearly linear — and the savings only grow with
scale. Evolution, it seems, discovered that a disciplined, deterministic
dynamical system is an extraordinarily economical way to compute, and it built
brains accordingly.

There is a tantalizing frontier just past this result. Everything above assumes
a finite, discrete machine — and we proved such machines must eventually repeat
themselves. What if the state space were a smooth continuum, a curved landscape
of possibilities flowed along by continuous dynamics with infinite precision?
Could such a system, drawing on the uncountable richness of the real numbers,
compute functions no ordinary discrete computer ever could? This is the
"super-Turing" hypothesis, and it remains genuinely open and physically
contentious. The honest reading of the mathematics is a warning label: any such
extra power would have to be smuggled in through the assumption of *unbounded
real precision*, not from biology itself. The reals are a generous fiction; the
brain, warm and finite, computes its bargain within the world we can build.
