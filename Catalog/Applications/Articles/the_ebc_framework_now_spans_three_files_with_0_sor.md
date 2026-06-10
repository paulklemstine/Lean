# The Price of Forgetting: How Thermodynamics Sets the Speed Limit of Computation

## A bill that comes due

Imagine you are cleaning up your desk. You sweep a hundred scattered notes into the
recycling bin and walk away with a clear surface. The desk is tidier — but the
*universe* is not. Every one of those notes carried information, and erasing
information, it turns out, is not free. It costs energy, and that energy turns into
heat that spills irretrievably into the world around you.

This is not a metaphor. It is one of the most beautiful and underappreciated laws of
nature, discovered by the physicist Rolf Landauer in 1961 while he was working at IBM.
**Landauer's principle** says that erasing a single bit of information — collapsing a
"could be 0 or 1" into a definite, known state — must dissipate at least

$$ k_B \, T \, \ln 2 $$

joules of energy as heat. Here $k_B$ is Boltzmann's constant (about
$1.38 \times 10^{-23}$ joules per kelvin), $T$ is the absolute temperature in kelvin,
and $\ln 2 \approx 0.693$. At room temperature ($T \approx 300$ K) this is a
breathtakingly tiny number — about $3 \times 10^{-21}$ joules per bit. But it is not
zero, and being not-zero changes everything.

The reason is subtle and gorgeous. Forgetting is irreversible. If I tell you "the
answer is now 0," but you don't know whether it *used* to be 0 or 1, then I have
destroyed information, and information is a physical quantity tied to entropy. The
second law of thermodynamics — the one that says disorder always increases — demands
its tax. Computation that throws information away must pay in heat.

This article is about a small, rigorous mathematical framework, which we call
**Entropy-Bounded Computation (EBC)**, that takes Landauer's insight completely
seriously and follows it to its logical conclusions. What emerges is a *bridge*: a set
of theorems that link three subjects that are usually taught in three different
buildings on campus — thermodynamics, information theory, and the theory of
computation. The punchline is that the laws of heat impose hard, unavoidable speed
limits on what any computer — classical, quantum, biological, or alien — can ever do.

## The ledger of erased bits

The whole framework rests on a deceptively simple idea: keep a ledger of how many bits
each computation erases, and convert that ledger into energy.

We start with the physical constants. A **LandauerParams** bundle is just a positive
Boltzmann constant $k_B$ and a positive temperature $T$. From these we define the single
most important number in the entire theory, the **per-bit cost**:

$$ \text{tempFactor} = k_B \, T \, \ln 2. $$

This is the energy price of forgetting one bit. The very first thing the theory proves —
and it is load-bearing for everything that follows — is that this number is *strictly
positive*: $\text{tempFactor} > 0$. It sounds trivial, but it is the hinge on which every
later inequality turns. As long as forgetting costs *something*, a finite energy budget
can only buy a finite amount of forgetting.

Next we model a computation as a list of steps. An **irreversible step** is characterized
by a single number: how many bits it erases. A **step sequence** is just a list of such
steps, and its **total bit count** is the sum of the bits erased by each step. The
**total cost** of running that sequence is simply

$$ \text{totalCost} = (\text{total bits erased}) \times \text{tempFactor}. $$

That's it. The model is almost insultingly simple — and yet, as we'll see, this simple
ledger is enough to derive genuine lower bounds on sorting, on cryptographic
brute-force attacks, and on the gap between easy and hard problems.

## Cost is a homomorphism (or: why the ledger always balances)

The first real theorem is about what happens when you glue two computations together.
If you run sequence $A$ and then sequence $B$, the combined sequence is their
concatenation, and the framework proves:

$$ \text{totalBits}(A \,{+}{+}\, B) = \text{totalBits}(A) + \text{totalBits}(B), $$
$$ \text{totalCost}(A \,{+}{+}\, B) = \text{totalCost}(A) + \text{totalCost}(B). $$

In words: **the cost of doing two things in a row is the sum of their costs.** No
hidden discounts, no surprise surcharges. Mathematicians have a name for this kind of
"adding inputs corresponds to adding outputs" behavior — it's called a *homomorphism* —
and recognizing it is the structural heart of the whole theory. The cost of a
computation is a homomorphism from the world of step-sequences (where the operation is
"do this, then that") into the world of real numbers (where the operation is plain
addition).

Two immediate consequences fall out for free. First, cost is never negative: you can't
*gain* energy by computing. Second, **cost only ever goes up when you do more work**:
appending extra steps to a sequence can never decrease its total cost. This is the
property that makes energy *budgets* meaningful and compositional — a theme that runs
through everything below.

## The flagship: an energy budget is a speed limit

Here is the central result, the one everything else orbits. Suppose you are given a
fixed energy budget $B$ joules to spend, and suppose each step of your computation
erases at least one bit (so each step costs at least $\text{tempFactor}$). Then the
number of steps you can possibly perform is bounded:

> **Step-count bound.** If a computation has a budget $B$ and every step erases at
> least one bit, then the number of steps is at most $B / \text{tempFactor}$.

This is Landauer's principle reborn as a theorem of complexity theory. It says, with
mathematical certainty: **a finite energy budget buys only a finite amount of
irreversible computation.** Want to do twice as many erasing operations? You need
(at least) twice the energy. Want to run at lower temperature to cheat? You can —
$\text{tempFactor}$ shrinks with $T$ — but you can never reach zero, because absolute
zero is unattainable.

The beauty of this theorem is the direction of the implication. Physics gives us a
*lower bound on cost* (every erasure costs at least $k_B T \ln 2$). The homomorphism
structure lets us flip that around into an *upper bound on steps*. A statement about
energy becomes, mechanically, a statement about how much computing you can do. That
flip is the bridge.

## Reversible computation: the free lunch (almost)

If forgetting is what costs energy, then the obvious escape hatch is: *don't forget.*
A computation that never erases information — one that is perfectly **reversible**, so
that from the output you could always reconstruct the input — pays no Landauer tax at
all.

The framework models this directly. A **reversible computation** on a set of states is
a *bijection*: a one-to-one, onto transformation, an exact reshuffling of possibilities
with nothing lost and nothing duplicated. Its Landauer cost is defined to be exactly
zero, and the framework proves that reversible computations *compose at zero cost*: chain
as many of them together as you like, and the bill stays at zero.

This is not a loophole; it's a profound design principle. It tells engineers and
theorists alike that the energy cost of computation is not really about *computing* —
it's about *forgetting*. In principle, you could perform an arbitrarily long
calculation for an arbitrarily small energy cost, provided you are willing to keep all
your intermediate scratch work and never throw any of it away. The catch, of course, is
that scratch work piles up: reversibility trades energy for memory. That trade-off — the
Pareto frontier between heat and space — is one of the deepest themes in the physics of
computation, and it begins right here, with the observation that bijections are free.

## Maxwell's demon, finally exorcised

For a century and a half, physics was haunted by a tiny imaginary creature. In 1867
James Clerk Maxwell imagined a "demon" sitting at a trapdoor between two gas chambers,
letting fast molecules through one way and slow molecules the other, sorting hot from
cold and seemingly creating order — and usable energy — out of nothing, in apparent
violation of the second law.

The resolution, refined over decades and sharpened by Charles Bennett, is that the
demon has to *remember* which molecules it saw, and eventually it has to *erase* those
memories to keep working. That erasure pays back, with interest, every joule the demon
seemed to gain. The bookkeeping closes; the second law survives.

EBC models the demon explicitly. A **Maxwell demon** makes some number of measurements,
each extracting some number of bits, and the total number of bits it must eventually
erase is measurements times bits-per-measurement. Its cost is, once again, that bit
count times the per-bit factor. And the framework proves the key accounting fact: **a
demon's cost is additive over the operations it performs.** Run the demon longer, make
more measurements, and the bill grows in exact proportion. There is no free order, no
perpetual motion, only an honest ledger that always balances.

## Brute force has a physical price tag

Now we connect the framework to something with real-world teeth: cryptography.

To break an encryption key by brute force — trying every possibility until one works —
you must test, in the worst case, every candidate in the key space. For an $n$-bit key,
that's $2^n$ candidates. The framework models this directly as a search problem with
$2^n$ candidate keys, realized as a step sequence with one bit-erasing step per
candidate, and proves the exact cost:

> **Brute-force cost.** Searching an $n$-bit key space by brute force costs exactly
> $2^n \times \text{tempFactor}$ joules.

This is where the abstract becomes visceral. Plug in room temperature, $T = 300$ K, so
that $\text{tempFactor} \approx 2.9 \times 10^{-21}$ joules. For a modern 256-bit key,
the cost of a brute-force search is

$$ 2^{256} \times 2.9 \times 10^{-21} \approx 3 \times 10^{56} \text{ joules}. $$

How much is $10^{56}$ joules? The Sun radiates about $4 \times 10^{26}$ joules every
second. Over its entire ten-billion-year main-sequence lifetime it will emit roughly
$10^{44}$ joules. So brute-forcing a single 256-bit key would require more energy than
*a trillion Suns* pour out over their entire lifetimes — and that is the
*thermodynamic* minimum, before you account for any real-world inefficiency. This is why
256-bit keys are considered safe not merely against today's computers, but against any
computer that could ever be built within the laws of physics. The security rests not on
clever mathematics alone but on the second law of thermodynamics itself.

## The asymptotic chasm: why hard problems are *really* hard

The final ingredient elevates these concrete numbers into a general principle. The
framework distills, from deep results in mathematical analysis, the fact that
**exponential growth eventually and permanently overwhelms any polynomial.** No matter
how steep a polynomial you write down — $n^{10}$, $n^{100}$, $n^{1000}$ — there is a
point beyond which $2^n$ is larger, and stays larger forever, by an ever-widening margin.

Applied to the energy ledger, this yields a stark dichotomy. A computation whose number
of erasing steps grows only polynomially with the problem size can be run within a
modest, slowly growing energy budget. But a computation whose steps grow exponentially —
like brute-force search — will, beyond some threshold, demand more energy than any
polynomial budget could ever supply. The framework proves this "entropy gap" is
*unbounded*: the shortfall between an exponential cost and a polynomial budget doesn't
just exist, it grows without limit. Easy and hard problems are not merely separated;
they are separated by a chasm that widens forever.

## The quantum coda: gates are free, measurement is everything

Quantum computers add a final, elegant twist. The basic operations of a quantum
computer — the "gates" that rotate and entangle qubits — are *unitary*, which is the
quantum word for reversible. By the free-lunch principle, they cost nothing in Landauer
terms. The only operation that destroys information is **measurement**: the irreversible
collapse that extracts a classical bit you can read.

The framework captures this by modeling a **quantum circuit** as just two numbers — its
gate count and its measurement count — and defining its cost as

$$ \text{cost} = (\text{measurement count}) \times \text{tempFactor}. $$

The gate count does not appear. From this fall several clean theorems. **Gate
independence:** two circuits with the same number of measurements cost the same, no
matter how many gates they use — you can compute as hard as you like for free, and pay
only when you look. **A purely unitary circuit has zero cost.** **Cost is additive** when
you compose circuits, just as in the classical case. And a **measurement budget** caps
the number of measurements you can afford, exactly mirroring the classical step-count
bound.

There is even a formal shadow of the celebrated *deferred-measurement principle* — the
fact that you can always postpone every measurement to the very end of a quantum
computation without changing the result. At the level of the energy ledger, deferring
measurements only reshuffles the order of operations; it leaves the measurement count,
and therefore the total cost, untouched. The entropy cost of a quantum computation
depends only on *how many* classical bits you ultimately extract — never on *when* you
extract them.

## The bridge, in one sentence

Strip away the details and the entire framework says something simple and profound:
**information is physical, forgetting costs energy, and that single fact ties together
the heat of thermodynamics, the bits of information theory, and the limits of
computation into one accountable ledger.** A finite budget of energy buys a finite
amount of forgetting; reversible computation forgets nothing and so costs nothing;
exponential search forgets exponentially and so is forbidden by the energy supply of
the cosmos itself.

Landauer wrote that "information is physical." Here, that slogan becomes a theorem —
several theorems, in fact — each one a small, sturdy plank in a bridge between worlds
that were always, secretly, the same world.
