# The Price of Forgetting: Why Erasing a Single Bit Must Warm the World

## A thought that costs heat

Imagine the smallest possible act of forgetting. Not losing a phone number or
a name, but the most elementary erasure a machine can perform: taking a single
switch that might be ON or OFF, and forcing it firmly to OFF — no matter where
it started. One bit, reset to zero.

It feels weightless. A bit is not a stone; it has no mass you can put on a
scale. And yet, in 1961, the physicist Rolf Landauer made a claim that still
startles people the first time they hear it: **erasing one bit of information
must release at least a fixed minimum amount of heat into the surroundings.**
Not "usually," not "in practice with today's chips," but *as a matter of
physical law*. The act of forgetting has a thermodynamic price tag, and you
cannot haggle it down to zero.

That minimum price is the famous quantity

$$k T \ln 2,$$

where $T$ is the absolute temperature of the environment and $k$ is Boltzmann's
constant, the tiny number ($\approx 1.38 \times 10^{-23}$ joules per kelvin)
that translates between the language of information and the language of energy.
At room temperature this is about three zeptojoules — a breathtakingly small
amount, roughly a billion times less than a single transistor wastes today. But
it is not zero, and that "not zero" is the whole story.

This article is about *why* that price exists, *how sharp* it really is, and a
surprising twist that only shows up when you look at small, fluctuating systems:
a real, jittery erasure always costs **strictly more** than the textbook
minimum. The clean number $kT\ln 2$ is a limit you approach but, in any honestly
random process, never quite touch.

## Information has a shape, and the shape is entropy

To see where $\ln 2$ comes from, we need one idea: **entropy as a measure of
uncertainty.**

Suppose our bit is in an unknown state — equally likely ON or OFF. How
uncertain are we? Shannon's entropy answers this with a formula. For a
collection of outcomes with probabilities $p_1, p_2, \dots$, the entropy is

$$H = -\sum_i p_i \ln p_i,$$

with the natural convention that an impossible outcome ($p_i = 0$) contributes
nothing. For our fair bit, with two outcomes each of probability $\tfrac12$,

$$H_{\text{uniform}} = -\tfrac12\ln\tfrac12 - \tfrac12\ln\tfrac12 = \ln 2.$$

There it is — $\ln 2$, the entropy of one fair coin's worth of ignorance.

Now perform the erasure. Afterwards the bit is OFF *for certain*. There is no
uncertainty left, so

$$H_{\text{erased}} = 0.$$

The erasure has destroyed exactly $\ln 2$ units of entropy:

$$H_{\text{uniform}} - H_{\text{erased}} = \ln 2.$$

This is a purely mathematical fact about information — no physics yet. But the
second law of thermodynamics insists that the total entropy of an isolated
system cannot decrease. If the bit's entropy went *down* by $\ln 2$, that
entropy must have gone *somewhere*: it was pushed out into the environment as
heat. And entropy dumped into a bath at temperature $T$ carries an energy cost
of temperature times entropy. Multiply by $k$ to fix the units, and the minimum
heat released is

$$kT \ln 2.$$

The deep punchline, which we will sharpen below, is that the irreversibility of
*logic* (you cannot undo an erasure — knowing the bit is now OFF tells you
nothing about whether it was ON or OFF before) forces the irreversibility of
*thermodynamics* (heat must flow out, and it cannot spontaneously flow back).
Logical forgetting and physical heating are two faces of one coin.

## Why erasure is the one operation that cannot be free

Here is the subtle part. Not every computation costs energy. Landauer's
collaborator Charles Bennett showed that any computation can, in principle, be
run *reversibly* — every step undoable — and reversible steps can be performed
with arbitrarily little dissipation. So what makes erasure special?

The answer is that erasure is **logically irreversible**: it is a many-to-one
operation. Two different inputs (ON and OFF) are mapped to the same output
(OFF). Looking only at the result, you cannot reconstruct the input. That
collapse of possibilities is precisely the loss of entropy that must be paid
for.

We can make this exact and completely general. Consider *any* deterministic
computation, modeled as a function $f$ that takes inputs to outputs, applied to
inputs drawn from some probability distribution $p$. The outputs follow a new
distribution — the "pushforward" $f_* p$, where the probability of an output $y$
is the total probability of all inputs that map to it. The central theorem is a
form of the **data-processing inequality**:

$$H(f_* p) \le H(p).$$

In words: *a deterministic computation can never increase entropy.* You can
shuffle information around or destroy it, but you can never manufacture
uncertainty from nothing by computing. And the inequality becomes an *equality*
exactly when $f$ is injective — one-to-one, i.e. reversible. Reversible
computations preserve entropy perfectly; they are, thermodynamically, free.
Erasure sits at the opposite extreme: it crushes everything down to a single
value, achieving the maximum possible entropy loss.

From this single inequality the heat bound follows immediately. The heat that
must be dissipated when running $f$ is $kT\,(H(p) - H(f_* p))$, which is always
nonnegative, and is exactly zero for reversible maps. Forgetting costs; perfect
remembering is free.

## The fluctuation twist: the bound is never actually reached

Everything so far is the textbook story, and it leaves an impression that
$kT\ln 2$ is a target a clever engineer could hit dead-on. The richer truth,
visible only when you take small-system randomness seriously, is more
interesting.

In a nanoscale device, the "work" $W$ done in a single erasure is not a fixed
number. Run the same erasure protocol twice and you get two slightly different
energy costs, because the molecule or electron you are pushing around is itself
being kicked by thermal noise. So $W$ is a random variable, and what Landauer's
bound really constrains is its *average*, $\mathbb{E}[W]$.

The bridge to the average comes from a jewel of modern statistical physics: the
**Jarzynski equality** (1997). It states an exact relation that holds however
violently far from equilibrium you drive the system:

$$\mathbb{E}\!\left[e^{-\alpha W}\right] = e^{-\alpha \,\Delta F},$$

where $\alpha = 1/(kT)$ is the inverse temperature and $\Delta F$ is the
free-energy difference between the start and end of the protocol. This is
remarkable: an *average of an exponential of a fluctuating quantity* equals a
clean equilibrium number.

From the Jarzynski equality one can extract the average work exactly. A short
calculation rearranges it into an **identity**:

$$\mathbb{E}[W] = \Delta F + \frac{1}{\alpha}\,
\ln \mathbb{E}\!\left[e^{-\alpha (W - \mathbb{E}[W])}\right].$$

The first term, $\Delta F$, is the reversible cost — for our bit, exactly
$kT\ln 2$. The second term is a **correction** built entirely from the
fluctuations of the work around its own mean. It is the finite-size, nanoscale
fingerprint that the smooth textbook formula misses.

Now comes the decisive step. What is the *sign* of that correction term? Here a
single elementary inequality does all the work — the fact that for every real
number $x$,

$$1 + x \le e^x,$$

the exponential curve always lies above its own tangent line. Because the
fluctuation $W - \mathbb{E}[W]$ has, by definition, zero average, this convexity
fact forces

$$\mathbb{E}\!\left[e^{-\alpha (W - \mathbb{E}[W])}\right] \ge 1,$$

so its logarithm is nonnegative, and therefore

$$\boxed{\;\Delta F \le \mathbb{E}[W].\;}$$

The correction can only *add* to the cost. Specialized to a bit, this is
Landauer's principle as a genuine inequality:

$$kT\ln 2 \le \mathbb{E}[W].$$

The average dissipated work is at least $kT\ln 2$ — never less.

But the same elementary inequality has a **strict** cousin: $1 + x < e^x$ for
every $x \ne 0$. Feeding this into the argument tells us *exactly when* equality
holds. The correction term is zero **if and only if** the work $W$ does not
fluctuate at all — it takes the same value every single time the protocol runs.
That is the idealized, infinitely slow, "quasi-static" limit. In any genuinely
stochastic erasure, where the energy cost rattles from run to run, the
inequality is **strict**:

$$kT\ln 2 < \mathbb{E}[W].$$

This is the counterintuitive headline. The clean number $kT\ln 2$ that
textbooks quote is a boundary that real, fluttering, finite-temperature devices
never reach. The closer you get, the slower and gentler your protocol must be;
to touch the bound exactly you would need an infinitely patient, perfectly
noiseless process. Fluctuations are not a nuisance to be averaged away — they
are a fundamental tax, and they always make forgetting *more* expensive than
the ideal.

## A second portrait: forgetting as the distance from equilibrium

There is an elegant alternative way to see the cost, which connects Landauer's
principle to the very heart of information theory. Instead of measuring the
entropy a single distribution carries, measure how *far apart* two
distributions are using the **relative entropy** (Kullback–Leibler divergence):

$$D(p \,\|\, q) = \sum_i p_i \ln\frac{p_i}{q_i}.$$

This quantity measures how distinguishable a state $p$ is from a reference state
$q$. A foundational result, **Gibbs' inequality**, says it is never negative:

$$D(p \,\|\, q) \ge 0,$$

with equality only when the two distributions coincide. The proof is again a
one-line convexity fact, the twin of the one above: $\ln x \le x - 1$.

Now take the reference $q$ to be the uniform distribution — pure equilibrium,
maximal ignorance — and let $p$ be the sharply-erased state, all mass on one
outcome. Then the relative entropy is

$$D(\text{erased}\,\|\,\text{uniform}) = \ln 2,$$

and the Landauer cost can be rewritten as

$$kT\ln 2 = kT \cdot D(\text{erased}\,\|\,\text{uniform}).$$

So the energy you must pay to erase a bit is exactly $kT$ times the "information
distance" between the crisp, erased state and the bland equilibrium state. The
two pictures — entropy *lost* by the bit, and relative entropy of the final
state *from* equilibrium — give the identical number, $\ln 2$, by two
completely different routes. That agreement is not a coincidence; it is the
mathematical signature of a single underlying truth.

## Scaling up: the cost is extensive

What about erasing not one bit but a whole register of $n$ bits? Intuitively the
cost should be $n$ times as large, and it is. A register of $n$ bits, when its
state is completely unknown, has $2^n$ equally likely configurations, and the
entropy of $N$ equally likely states is $\ln N$. So $n$ uniform bits carry
entropy

$$\ln(2^n) = n \ln 2,$$

and erasing them all costs at least

$$n \cdot kT\ln 2.$$

Dividing by $n$ recovers a per-bit cost of *exactly* $kT\ln 2$, for every
register size. The bound is **extensive** — it scales cleanly with the amount
of information destroyed — which is exactly the behavior a respectable
thermodynamic law should have. It also means the per-bit price is not a quirk of
considering a lonely single bit; it is the universal currency of forgetting.

## Why this matters

Landauer's principle is not an academic curiosity. It draws a hard floor under
the energy efficiency of *all* computation. Today's processors dissipate
millions of times more than $kT\ln 2$ per logical operation, so the limit is not
yet a practical wall. But the trend of the last seventy years has been a
relentless march toward it, and as devices shrink toward the scale of
individual molecules and electrons — where the fluctuation correction above is
no longer negligible — the question of the true, fundamental cost of an
irreversible operation moves from philosophy to engineering.

It also reframes a much older puzzle. For over a century, "Maxwell's demon" — a
hypothetical being who sorts fast and slow molecules to seemingly violate the
second law — haunted physics. The resolution, sharpened by Landauer and Bennett,
is that the demon must eventually *erase its memory* of the molecules it
sorted, and that erasure costs exactly enough heat to save the second law. The
ledger always balances, and it balances at $kT\ln 2$ per bit.

The most beautiful thing about the whole edifice is how little it leans on. The
existence of a fundamental energy cost for forgetting, the fact that this cost
is never undercut, and the fact that any genuine fluctuation makes it strictly
worse — all three follow from a single, almost childishly simple inequality:
the exponential curve lies above its tangent line, $1 + x \le e^x$, strictly so
unless $x = 0$. From that one geometric fact about a curve, the thermodynamic
price of memory, the impossibility of free erasure, and the universal tax of
nanoscale noise all unfold. Forgetting, it turns out, is governed by the same
quiet mathematics that bends every exponential — and it is never, ever free.
