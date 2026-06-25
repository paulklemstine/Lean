# Why Magnets Don't Work in One Dimension: The Exact Story of the Ising Chain

## A puzzle hidden inside a refrigerator magnet

Stick a magnet to your refrigerator and you are looking at the end product of a
quiet revolution. Inside that little black disk, trillions upon trillions of
atomic compass needles all point the same way. They do this *spontaneously* — no
external field forces them. Heat the magnet hot enough, though, and the order
collapses: the needles begin to point every which way, and the magnetism
vanishes. Cool it back down and, suddenly, below a sharp threshold temperature,
the order snaps back into place.

That sudden snap is a **phase transition**, one of the most dramatic phenomena in
all of physics. Water boiling into steam, a metal becoming a superconductor, the
early universe condensing matter out of a uniform soup — all are phase
transitions. The mathematical signature of such an event is a *singularity*: some
smooth, well-behaved quantity suddenly develops a kink, a cusp, or an outright
divergence at one special value of the temperature.

The simplest mathematical model that captures this drama is the **Ising model**,
invented in the 1920s. It is so simple that it can be written on a napkin, yet so
rich that physicists are still mining it a century later. This article tells the
exact, complete story of the Ising model in its most stripped-down form — a
single chain of spins in one dimension — and explains a result that surprised the
model's own inventor: **in one dimension, the magnet never works.** There is no
phase transition, at any temperature above absolute zero, and we can prove it
with a formula you could check by hand.

## The rules of the game

Imagine a row of $n+1$ tiny magnets, which physicists call **spins**, sitting at
positions $0, 1, 2, \dots, n$. Each spin can be in one of exactly two states:
pointing "up" ($+1$) or "down" ($-1$). A complete description of the system — a
**configuration** — is just a choice of up or down for every site. With $n+1$
sites, there are $2^{n+1}$ possible configurations.

Spins like to agree with their neighbors. We encode this with an **energy**: each
neighboring pair contributes a little energy that is *lower* when the two spins
align and *higher* when they disagree. If we write $\sigma_i = \pm 1$ for the spin
at site $i$, the energy of the whole chain is

$$E(\sigma) = -J \sum_{i=0}^{n-1} \sigma_i \, \sigma_{i+1},$$

where $J > 0$ is the **coupling strength**. When two adjacent spins point the same
way, $\sigma_i \sigma_{i+1} = +1$ and the term $-J\sigma_i\sigma_{i+1} = -J$ lowers
the energy; when they disagree it raises it. Nature prefers low energy, so the
spins *want* to line up. The chain of $n+1$ sites has $n$ such neighboring bonds.

But nature is not purely orderly. At any positive temperature, thermal jitter
shakes the spins around. The fundamental law of statistical mechanics, the
**Boltzmann distribution**, says that a configuration with energy $E$ occurs with
probability proportional to $e^{-\beta E}$, where $\beta = 1/(k_B T)$ is the
*inverse temperature*. Hot systems (small $\beta$) explore all configurations
nearly equally; cold systems (large $\beta$) overwhelmingly favor the
lowest-energy, most-ordered ones. The battle between energy and temperature is the
whole story of magnetism.

The single number that controls everything is the **partition function**, the sum
of the Boltzmann weights over *all* configurations:

$$Z = \sum_{\text{configurations } \sigma} e^{-\beta E(\sigma)}
   = \sum_{\sigma} \prod_{i=0}^{n-1} e^{\beta J \, \sigma_i \sigma_{i+1}}.$$

This looks like an astronomically complicated object — a sum over $2^{n+1}$ terms,
each a product of $n$ exponentials. For a chain of just 300 spins, the number of
terms exceeds the number of atoms in the observable universe. And yet, as we will
see, it collapses to a one-line formula.

## A domino-style trick: the transfer matrix

The key to taming the partition function is an idea of breathtaking elegance,
called the **transfer matrix** method. Instead of trying to grasp the entire chain
at once, we build it up one spin at a time, the way you might compute a long
product by multiplying in one factor at a time.

Here is the crucial observation. Consider summing over the *very first* spin,
$\sigma_0$, while holding its neighbor $\sigma_1$ fixed. That spin appears in
exactly one bond. Summing its two possible values gives

$$\sum_{\sigma_0 = \pm 1} e^{\beta J \, \sigma_0 \sigma_1}
   = e^{\beta J \sigma_1} + e^{-\beta J \sigma_1} = 2\cosh(\beta J).$$

Look closely at what happened: the answer, $2\cosh(\beta J)$, *does not depend on
$\sigma_1$ at all!* This is because the hyperbolic cosine is an even function —
$\cosh(x) = \cosh(-x)$ — so flipping the neighboring spin from $+1$ to $-1$ leaves
the result untouched. In our formalization this fact is captured by two small but
load-bearing lemmas: one stating that $\cosh(c \cdot \sigma) = \cosh(c)$ for any
spin $\sigma = \pm 1$, and one stating

$$\sum_{\sigma_0 = \pm 1} e^{\,c\,\sigma_0\,\sigma_1} = 2\cosh(c),$$

independent of the boundary spin $\sigma_1$.

This independence is the magic ingredient. It means that peeling off the first
spin simply multiplies the partition function of the remaining, shorter chain by
the *same constant factor* $2\cosh(\beta J)$, no matter what. Each spin we strip
away contributes one identical factor. This gives a clean recursion: if
$Z_n$ denotes the partition function of a chain with $n$ bonds, then

$$Z_{n+1} = \big(2\cosh(\beta J)\big)\, Z_n.$$

A chain with zero bonds is a single site with two states and no interactions, so
$Z_0 = 2$. Unrolling the recursion gives the exact, closed-form solution:

$$\boxed{\,Z_n = 2\,\big(2\cosh(\beta J)\big)^{n}.\,}$$

That is the entire 1D Ising model, solved exactly, for every temperature and every
chain length. A sum over more configurations than there are atoms in the universe
collapses to a single power of a hyperbolic cosine. The factor of $2$ out front
counts the two-fold freedom of the very last unconstrained spin; the factor
$\big(2\cosh(\beta J)\big)^n$ is one transfer-matrix step per bond.

## From microscopic to macroscopic: the free energy

Physicists rarely care about the partition function directly. What they care
about is the **free energy**, which governs all the thermodynamics, and especially
the **free energy density** — the free energy *per site* in an infinitely long
chain. This is where phase transitions reveal themselves: a phase transition is,
by definition, a point where the free energy density fails to be smooth.

Taking the logarithm of our exact formula and dividing by the number of sites
$n+1$, we get

$$\frac{1}{n+1}\log Z_n
   = \frac{1}{n+1}\log 2 + \frac{n}{n+1}\log\!\big(2\cosh(\beta J)\big).$$

Now send the chain length to infinity. The first term, carrying the leftover
boundary spin, vanishes like $1/n$ — boundary effects don't matter in a large
system. The fraction $n/(n+1)$ tends to $1$. So the free energy density converges
to a strikingly clean limit:

$$\lim_{n\to\infty} \frac{1}{n+1}\log Z_n = \log\!\big(2\cosh(\beta J)\big).$$

This is the **thermodynamic limit**, and it is the true bulk free energy of the
infinite 1D Ising chain. Every thermodynamic property — energy, entropy, heat
capacity — can be extracted from this one function of temperature.

## The punchline: no phase transition, ever

Now we can answer the original question. *Does the 1D Ising chain become a
spontaneous magnet at low temperature?* A phase transition would show up as a
singularity — a kink or divergence — in the free energy density
$f(\beta) = \log\!\big(2\cosh(\beta J)\big)$ at some special inverse temperature
$\beta$.

But look at the function. The hyperbolic cosine $\cosh(\beta J)$ is **strictly
positive** for every real $\beta$ — it never touches zero, never goes negative.
And the logarithm of a strictly positive, infinitely-smooth function is itself
infinitely smooth. There is simply nowhere for a singularity to hide. Formally,
$f(\beta) = \log\!\big(2\cosh(\beta J)\big)$ is **infinitely differentiable on all
of the real line** — it is, in fact, real-analytic everywhere.

This is the rigorous content of the statement "**the one-dimensional Ising model
has no phase transition at any positive temperature.**" The free energy is a
perfectly smooth curve, with no kink, no cusp, no divergence, from infinite
temperature all the way down toward absolute zero. The magnet never spontaneously
switches on. Only at $T = 0$ exactly ($\beta = \infty$) does perfect order finally
win — and that is a limit, not a true transition at finite temperature.

The single algebraic fact responsible for this verdict is worth savoring: the
dominant transfer-matrix eigenvalue, $2\cosh(\beta J)$, is a strictly positive,
real-analytic function of $\beta$. Because it never vanishes and never misbehaves,
its logarithm — the free energy — can never become singular. Dimensionality, in
the end, comes down to whether the transfer matrix has room to develop a
degeneracy. In one dimension, it never does.

## Why one dimension is different

This might feel anticlimactic — we built a beautiful model of magnetism and it
refuses to be a magnet! Ernst Ising, in his 1925 thesis, found exactly this and
concluded, pessimistically, that the model was useless for explaining real
ferromagnets. He was wrong, but in an instructive way.

The deep reason is about the *cost of disorder*. Imagine an ordered chain, all
spins up. To create a region of disorder, you flip a contiguous block of spins.
In one dimension, doing so costs energy only at the **two boundaries** of the
flipped block — just two unhappy bonds — regardless of how large the block is. So
a single, cheap "domain wall" can be inserted anywhere, and there are many places
to put it. Entropy (the sheer number of ways to be disordered) always beats the
fixed, finite energy cost. Order cannot survive at any positive temperature.

In **two dimensions**, the situation flips. The boundary of a disordered region is
now a closed loop whose energy cost *grows* with its size. Large disordered
patches become expensive, and below a critical temperature, order finally wins.
This is the celebrated result of Lars Onsager, who in 1944 solved the 2D Ising
model exactly and found a genuine phase transition at the critical temperature

$$T_c = \frac{2J}{k_B \ln(1+\sqrt{2})} \approx \frac{2.269\,J}{k_B}.$$

The contrast between the smooth 1D free energy and the singular 2D one is one of
the cleanest illustrations in all of science of how *dimensionality* shapes
collective behavior. The same local rules — spins prefer to agree — produce a
magnet in two dimensions and refuse to in one. The difference is entirely a matter
of geometry and counting.

## What we have actually established

Let us collect the exact results, stated plainly:

1. **Exact partition function.** For a chain of $n$ bonds at inverse temperature
   $\beta$ and coupling $J$, the partition function summed over all $2^{n+1}$
   spin configurations equals exactly $Z_n = 2\,\big(2\cosh(\beta J)\big)^n$.

2. **Transfer recursion.** Adding one bond multiplies the partition function by
   the dominant eigenvalue: $Z_{n+1} = \big(2\cosh(\beta J)\big)\,Z_n$.

3. **Thermodynamic limit.** The free energy density converges:
   $\frac{1}{n+1}\log Z_n \to \log\!\big(2\cosh(\beta J)\big)$ as
   $n \to \infty$.

4. **No phase transition.** The limiting free energy density
   $\beta \mapsto \log\!\big(2\cosh(\beta J)\big)$ is infinitely differentiable on
   all of $\mathbb{R}$ — smooth and singularity-free at every temperature.

None of these is an approximation. Each is an exact identity, true for every
finite chain or every real temperature. The transfer-matrix method turns an
impossible-looking sum into elementary algebra, and elementary algebra delivers a
verdict that took the physics community years to fully appreciate.

## The bigger picture

The Ising chain is a gateway. The transfer-matrix idea — reduce an extended
many-body sum to repeated multiplication by a small matrix — reappears throughout
physics and mathematics: in quantum mechanics (where it becomes the path
integral), in the theory of stochastic processes (Markov chains), in coding
theory, and in modern machine learning (where it underlies the forward algorithm
for hidden Markov models). The humble lesson that "summing one spin gives the same
factor regardless of its neighbor" is the seed of an entire computational
philosophy.

And the headline result — that order can or cannot survive depending on the
*dimension* of space — echoes far beyond magnets. It tells us that collective
phenomena are not just about the local rules but about the stage on which those
rules play out. A society of agents who each merely want to agree with their
neighbors will reach consensus on a grid but never on a line. The same arithmetic
that governs a refrigerator magnet governs, in spirit, any system where local
agreement competes with random noise.

One dimension is too small a world for order to take hold. Two dimensions is just
big enough. That razor's edge, captured exactly in a single hyperbolic cosine, is
one of the quiet marvels of mathematical physics.
