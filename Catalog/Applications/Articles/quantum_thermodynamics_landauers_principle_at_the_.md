# The Price of Forgetting: Why Erasing a Bit Always Costs Heat

## A thought experiment that refused to die

In 1867 the physicist James Clerk Maxwell imagined a tiny, intelligent
being — later christened "Maxwell's demon" — sitting at a trapdoor between two
gas chambers. By letting fast molecules through one way and slow molecules the
other, the demon seemed to sort hot from cold for free, quietly building a
temperature difference out of nothing. If it could do that, you could run an
engine off the gradient forever. The Second Law of Thermodynamics, the
bedrock principle that forbids perpetual motion, appeared to have a loophole.

It took almost a century to close that loophole, and the answer turned out to
be about *information*, not gas. The demon has to remember which molecules it
sorted. Its memory is finite. Sooner or later it must **erase** old records to
make room for new ones — and that act of forgetting, Rolf Landauer argued in
1961, is where the bill comes due. Erasing information is not free. It costs
energy, and that energy is dumped into the environment as heat.

How much? Landauer's answer is one of the most beautiful numbers in physics:

$$ W \;\ge\; k T \ln 2. $$

To erase a single bit of information at temperature $T$, you must dissipate at
least $kT\ln 2$ joules of heat, where $k$ is Boltzmann's constant. At room
temperature this is a minuscule $\approx 2.9 \times 10^{-21}$ joules — about
three zeptojoules — but it is never zero. No clever engineering, no
reversible trick, no future technology can drive the cost of forgetting below
this floor. This article tells the story of *why* that floor exists, and how a
single elementary inequality from calculus turns it into a theorem.

## Logical irreversibility: the moment information vanishes

Start with what "erasing a bit" actually means. A bit of memory can be in one
of two states, call them $0$ and $1$. Before erasure, suppose you have no idea
which — the two states are equally likely. After erasure, the memory is
**reset** to a fixed standard state, say $0$, no matter what it held before.

Here is the crucial point. The reset operation is a function from the old
state to the new one, and that function is *not invertible*. Both inputs $0$
and $1$ map to the same output $0$. Looking only at the result, you cannot
reconstruct what was there before. The information is gone. Computer
scientists call this **logical irreversibility**: a map that cannot be undone
because two distinct inputs collapse to one output.

We can quantify "how much you didn't know" with **Shannon entropy**. For a
state that is $0$ with probability $p_0$ and $1$ with probability $p_1$, the
entropy is

$$ H = -p_0 \ln p_0 - p_1 \ln p_1, $$

with the natural convention that a term $p\ln p$ is $0$ whenever $p = 0$
(there is no surprise in an outcome that never happens). For the unknown bit,
$p_0 = p_1 = \tfrac12$, and the entropy works out to exactly $\ln 2$. For the
erased bit, the state is $0$ with certainty, so $p_0 = 1$, $p_1 = 0$, and the
entropy is $0$. Erasure has destroyed exactly $\ln 2$ "nats" of entropy:

$$ \Delta H = H(\text{unknown}) - H(\text{erased}) = \ln 2 - 0 = \ln 2. $$

That number $\ln 2$ is the same $\ln 2$ that appears in Landauer's bound — and
that is not a coincidence. It is the bridge between the abstract world of
information and the physical world of heat.

## The Second Law, restated for computers

Why should destroying entropy in your *memory* cost energy in the *world*?
Because the total entropy of the universe — your memory plus its environment —
can never decrease. That is the Second Law. If the entropy stored in the bit
goes down by $\ln 2$, the entropy of the surrounding heat bath must go up by at
least $\ln 2$ to compensate. And entropy flowing into a bath at temperature
$T$ is precisely heat divided by temperature. Multiply through and you get the
energy cost: at least $kT\ln 2$ of heat must flow out.

This is the intuitive picture. The achievement of the work behind this article
is to make it a *theorem* — a statement proved with full rigor, with every
assumption made explicit and every step checked — starting not from the Second
Law as an axiom but from a more fundamental and surprising place: a single
equality discovered in 1997 by Christopher Jarzynski.

## The Jarzynski equality: order from chaos

Classical thermodynamics talks about averages and idealized, infinitely slow
("quasi-static") processes. But real erasure happens fast, in a small device,
where random thermal fluctuations matter enormously. Sometimes, by sheer luck,
a fluctuation helps you and the erasure costs *less* than $kT\ln 2$ on that
particular run. Does that break Landauer's bound?

No — and Jarzynski's equality explains exactly why. Suppose you drive a small
system from one state to another, and you measure the work $W$ you put in.
Because of fluctuations, $W$ is random: repeat the experiment and you get a
different value each time. Jarzynski discovered that, no matter how violently
or quickly you drive the system, the random work obeys an exact identity:

$$ \big\langle e^{-\alpha W} \big\rangle = e^{-\alpha \,\Delta F}. $$

Here $\langle \cdot \rangle$ denotes the average over many runs, $\Delta F$ is
the free-energy difference between the start and end configurations, and
$\alpha = 1/(kT)$ is the inverse temperature. The remarkable thing is that
this is an *equality*, valid arbitrarily far from equilibrium. It pins down a
particular average of the work — the average of $e^{-\alpha W}$ — with no
inequality, no slop, no idealization.

In the formal development this is taken as the defining property of the
process, the **Jarzynski condition**: for weights $p$ over the possible
outcomes and work values $W$,

$$ \mathbb{E}_p\!\left[e^{-\alpha W}\right] = e^{-\alpha \Delta F}. $$

From this exact identity one can extract, with pure algebra, an exact formula
for the *ordinary* average work:

$$ \mathbb{E}_p[W] \;=\; \Delta F \;+\; \frac{1}{\alpha}\,
\ln \mathbb{E}_p\!\left[e^{-\alpha (W - \mathbb{E}_p[W])}\right]. $$

The mean work equals the free-energy difference $\Delta F$ *plus* a correction
term built entirely out of the **fluctuations** of the work around its own
mean. This is the finite-size Landauer identity. It is exact — but on its own
it does not yet tell you the sign of that correction. Maybe fluctuations push
the cost down? The whole physical content of the Second Law lives in answering
that question.

## One inequality to rule them all

Here is the heart of the matter, and it is gloriously simple. Everything turns
on a fact you can prove in one line of calculus, true for every real number
$x$:

$$ 1 + x \;\le\; e^{x}. $$

The exponential curve always sits above its own tangent line at the origin.
That's it. That is the entire analytic engine of the proof.

Apply it to the random variable $g = -\alpha(W - \mathbb{E}_p[W])$, the
*centered* work fluctuation. Averaging the inequality $1 + g \le e^{g}$ over
all outcomes gives

$$ 1 + \mathbb{E}_p[g] \;\le\; \mathbb{E}_p\!\left[e^{g}\right]. $$

This is a discrete cousin of Jensen's inequality, proved here directly from the
tangent-line bound, with no heavy convexity machinery. Now comes the trick.
The variable $g$ was *centered* — it measures deviation from the mean — so its
own average is zero:

$$ \mathbb{E}_p\!\left[-\alpha (W - \mathbb{E}_p[W])\right] = 0. $$

Substituting $\mathbb{E}_p[g] = 0$ into the inequality leaves

$$ 1 \;\le\; \mathbb{E}_p\!\left[e^{-\alpha(W - \mathbb{E}_p[W])}\right]. $$

The fluctuation factor — the very quantity inside the logarithm of the
Jarzynski correction — is *at least one*. The logarithm of a number $\ge 1$ is
$\ge 0$. So the correction term is nonnegative:

$$ \frac{1}{\alpha}\,\ln \mathbb{E}_p\!\left[e^{-\alpha(W - \mathbb{E}_p[W])}\right]
\;\ge\; 0 \qquad (\alpha > 0). $$

Plug this back into the exact identity, and the conclusion is immediate:

$$ \boxed{\;\Delta F \;\le\; \mathbb{E}_p[W]\;} $$

The average work you must invest is *at least* the free-energy difference. The
extra you pay is exactly the fluctuation correction, which is never negative.
This is the Second Law, derived not assumed — a clean inequality squeezed out
of Jarzynski's equality by the tangent-line bound. Physicists call the gap the
"dissipated work"; it is the thermodynamic-irreversibility surcharge you pay on
top of the reversible minimum $\Delta F$.

## Landauer's number falls out

Now specialize. For erasing one bit, the relevant free-energy difference is
exactly the Landauer cost, $\Delta F = kT\ln 2$, and the inverse temperature is
$\alpha = 1/(kT)$. The general theorem instantly gives

$$ k T \ln 2 \;\le\; \mathbb{E}_p[W]. $$

There it is: **Landauer's principle**, as a rigorous lower bound, for any
one-bit erasure obeying the Jarzynski equality at positive temperature $T$ and
positive Boltzmann constant $k$. No process can beat $kT\ln 2$ on average. The
fluctuations that occasionally help you on a single run are *exactly*
compensated, on average, by the runs where they hurt — that is what the
inequality $\langle e^{g}\rangle \ge 1$ encodes.

And the bridge to information is made explicit. The free-energy cost is
literally temperature times the entropy you destroyed:

$$ k T \ln 2 \;=\; k T\,\big(H(\text{unknown}) - H(\text{erased})\big). $$

The thermodynamic price tag $kT\ln 2$ *is* $kT$ times the $\ln 2$ of Shannon
entropy that vanished when the bit was reset. Logic and heat are two faces of
the same coin.

## Why forgetting must cost something — the dichotomy

The final result closes Maxwell's loophole completely. It says that **logical
irreversibility forces thermodynamic irreversibility**. The erasure map sends
both $0$ and $1$ to the same state; it is not injective; you cannot undo it.
Precisely *because* it is not injective, any physical process that implements
it — subject to Jarzynski's equality — must dissipate a *strictly positive*
amount of work:

$$ 0 < \mathbb{E}_p[W]. $$

The logic is airtight. A reversible computation — one whose map *is* injective,
that loses no information — can in principle be run at zero energy cost; the
companion data-processing result shows that injective maps preserve entropy
exactly, so their Landauer cost is zero. But the instant your computation
throws information away, the thermodynamic meter starts running. Forgetting is
the only step in computation that is fundamentally, unavoidably expensive.

## Why it matters today

This is not academic hairsplitting. Modern processors dissipate heat by the
hundreds of watts, and an ever-growing fraction of the world's electricity goes
to computing and cooling data centers. The vast majority of that energy is
wasted far above the Landauer floor — today's transistors operate thousands of
times less efficiently than the theoretical minimum. But the floor is real, and
experiments since 2012 have actually measured single-bit erasure approaching
$kT\ln 2$ in colloidal particles and nanomagnets. As devices shrink toward the
scale where thermal fluctuations dominate, the finite-size correction term —
the fluctuation surcharge above $kT\ln 2$ — stops being a curiosity and becomes
a design constraint.

The same mathematics points toward the quantum frontier, where bits become
qubits and Shannon entropy becomes von Neumann entropy, and toward the dream of
*reversible computing*, which sidesteps the Landauer cost by never erasing
anything at all. The principle even reframes a philosophical puzzle: it shows
that information is not an abstraction floating above physics but a physical
quantity with a thermodynamic price, as Landauer himself put it — "information
is physical."

## The shape of the argument

Step back and admire the architecture. We began with a riddle about a demon, a
century-old threat to the Second Law. We translated "forgetting" into the
precise notion of a non-invertible map, and measured the lost information as a
drop of $\ln 2$ in Shannon entropy. We invoked Jarzynski's exact equality to
get a formula for the average work — free energy plus a fluctuation correction.
And then a single, humble inequality, $1 + x \le e^x$, the exponential lying
above its tangent, forced that correction to be nonnegative and delivered the
Second Law and Landauer's $kT\ln 2$ bound in one stroke.

That a principle this consequential — the energetic cost of thought itself —
should rest on so slender an analytic fact is, in the end, the most beautiful
part of the story. The price of forgetting is small, but it is never zero, and
now we can prove it.
