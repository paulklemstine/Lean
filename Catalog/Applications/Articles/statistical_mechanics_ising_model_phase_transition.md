# The Temperature Where Iron Forgets Itself

## A magnet's secret number

Heat a bar magnet in a flame and something strange happens. At first nothing
seems to change — it still clings to your refrigerator, still tugs at a nearby
compass needle. But keep heating, and at one precise temperature the magnetism
vanishes all at once, as if a switch had been thrown. Cool it back down and the
magnetism returns, again at that same special temperature. For iron this magic
threshold sits at about $770^{\circ}\mathrm{C}$. Physicists call it the *Curie
point*, and it marks one of the cleanest examples in all of nature of a **phase
transition**: a qualitative change in the collective behavior of matter that
happens at a single, sharp value of a control parameter.

What makes a phase transition so puzzling is that nothing dramatic happens to
any *individual* atom. Each atom is a tiny magnet, a "spin," that prefers to
point the same way as its neighbors. At low temperature this preference wins:
the spins lock together into a vast, coordinated army, and the material is
magnetized. At high temperature thermal jostling wins: each spin flickers
randomly, the army dissolves into a disorganized mob, and the magnetism
disappears. Somewhere in between is a knife-edge — the critical temperature —
where order and chaos are perfectly balanced.

The deep question is: *can we predict that knife-edge from first principles?* Not
measure it — predict it, with a formula, starting only from the rule "spins like
to align with their neighbors." For decades this looked hopeless. Then, in 1944,
Lars Onsager produced one of the most celebrated calculations of twentieth-century
physics, and out of the algebra fell a number of startling elegance.

This article is about that number, and about the beautiful self-mirroring
symmetry that makes it inevitable.

## A checkerboard of arrows

To make the problem precise, physicists strip it to its bones. Forget the
complicated three-dimensional crystal of iron. Picture instead a flat square
grid — a checkerboard — and at every square place a single arrow that can only
point in one of two directions: **up** ($+1$) or **down** ($-1$). This is the
**two-dimensional Ising model**, named after Ernst Ising, who studied its
one-dimensional cousin in the 1920s.

The rule of the game is encoded in an *energy*. Every arrow looks at its
immediate neighbors — the squares directly to its right and directly above it —
and the system pays an energy penalty whenever two neighbors disagree. Concretely,
write $\sigma_p = \pm 1$ for the spin at site $p$. The total energy, or
**Hamiltonian**, of a whole configuration $\sigma$ of arrows is

$$H(\sigma) \;=\; -\sum_{p}\left( \sigma_p\,\sigma_{p\rightarrow} + \sigma_p\,\sigma_{p\uparrow}\right),$$

where $p\rightarrow$ and $p\uparrow$ denote the right and upper neighbors of $p$.
The minus sign means that aligned neighbors ($\sigma_p\sigma_q = +1$) *lower* the
energy, while misaligned ones ($\sigma_p\sigma_q = -1$) *raise* it. Nature, left
to itself, slides toward low energy — so the model has a built-in bias toward
agreement.

How strong is that bias? It must compete with temperature. The laws of statistical
mechanics say that a configuration $\sigma$ occurs with probability proportional
to the Boltzmann weight $e^{-\beta H(\sigma)}$, where $\beta = 1/T$ is the
*inverse temperature*. When $\beta$ is large (cold), the weight punishes
high-energy, disordered states severely, and order reigns. When $\beta$ is small
(hot), all configurations are nearly equally likely, and disorder reigns. The
phase transition is the boundary between these regimes.

Two facts about this energy are worth pinning down precisely, because they are
the skeleton on which everything else hangs.

**The lowest-energy state is perfect agreement.** If every arrow points up — or
every arrow points down — then *every* neighboring pair agrees, every bond
contributes $-1$, and the energy hits rock bottom. On a periodic grid of
$N$ sites, each site owns two bonds (right and up), so the minimum energy is
exactly $-2N$. No configuration can do better: each of the $2N$ bonds contributes
at most $+1$ to the aligned count, so $H(\sigma) \ge -2N$ for every $\sigma$, with
equality precisely for the two uniform states. These two perfectly ordered states
are the **ground states** of the model.

**The energy cannot tell up from down.** Flip *every* arrow at once,
$\sigma \mapsto -\sigma$. Then every product $\sigma_p\sigma_q$ becomes
$(-\sigma_p)(-\sigma_q) = \sigma_p\sigma_q$, unchanged. So the Hamiltonian is
perfectly symmetric: $H(-\sigma) = H(\sigma)$. This is a global $\mathbb{Z}/2$
symmetry — a two-element symmetry group, "flip everything or don't." The
*magnetization* $M(\sigma) = \sum_p \sigma_p$, by contrast, is *odd*: it changes
sign under the flip, $M(-\sigma) = -M(\sigma)$, and is bounded in magnitude by the
number of sites.

Here is the paradox that the whole subject revolves around. The energy is
symmetric — it has no preference for up over down. Yet below the critical
temperature the system *chooses*. It piles up around one of the two ground states
and develops a nonzero average magnetization, breaking the very symmetry that the
energy respects. This is **spontaneous symmetry breaking**, and it is the
mathematical heart of magnetism.

## The mirror trick

Onsager's full solution is a tour de force. But the *location* of the critical
point — the value of $T_c$ — can be pinned down by an argument of breathtaking
economy, discovered by Hendrik Kramers and Gregory Wannier in 1941, three years
*before* Onsager. Their idea is a kind of mirror.

Imagine you understand the Ising model perfectly at very low temperature, where
the system is almost perfectly ordered and the only excitations are small
"islands" of flipped spins. And imagine you also understand it at very high
temperature, where the system is almost perfectly random and order appears only
as faint, fleeting correlations. Kramers and Wannier discovered something
miraculous: *these two descriptions are the same description.* The low-temperature
theory at inverse temperature $\beta$ is mathematically identical to the
high-temperature theory at a different inverse temperature $\beta^{*}$, its
**dual**. The precise dictionary relating them is the elegant relation

$$\sinh(2\beta)\,\sinh(2\beta^{*}) \;=\; 1.$$

This is the **Kramers–Wannier duality**. It is an involution: apply it twice and
you return to where you started, because the relation is symmetric in $\beta$ and
$\beta^*$. Low maps to high, and high maps back to low. The map folds the entire
temperature axis onto itself like a sheet of paper.

Now comes the punchline. A phase transition is a point where the system's behavior
turns non-smooth — a crease in the fabric of its thermodynamics. If there is
exactly one such crease, then duality, which is a symmetry of the whole theory,
*must map the crease to itself*. The only way a point can be sent to itself by the
duality is to be a **fixed point**: a temperature equal to its own dual,
$\beta = \beta^{*}$. Set $\beta = \beta^*$ in the duality relation and it collapses
to a single clean equation:

$$\sinh(2\beta_c) \;=\; 1.$$

The critical point is *self-dual*. It is the unique temperature that looks the
same in the low-temperature mirror as in the high-temperature one. Order and
disorder meet exactly where the model becomes its own reflection.

## Solving the riddle

The equation $\sinh(2\beta_c) = 1$ is now just algebra, and it unwinds into a
gem. Recall $\sinh(x) = \tfrac{1}{2}(e^x - e^{-x})$. Writing $u = e^{2\beta_c}$,
the condition $\sinh(2\beta_c)=1$ becomes $u - 1/u = 2$, i.e. $u^2 - 2u - 1 = 0$,
whose positive root is

$$e^{2\beta_c} \;=\; 1 + \sqrt{2}.$$

Taking logarithms,

$$\beta_c \;=\; \tfrac{1}{2}\ln\!\bigl(1 + \sqrt{2}\,\bigr), \qquad\text{and therefore}\qquad T_c \;=\; \frac{1}{\beta_c} \;=\; \frac{2}{\ln\!\bigl(1 + \sqrt{2}\,\bigr)}.$$

There it is — the **Onsager critical temperature**, conjured from a single
self-mirroring equation. Plug in $\sqrt{2} \approx 1.41421$ and you find
$\ln(1+\sqrt 2) \approx 0.88137$, so

$$T_c \;\approx\; 2.269\quad(\text{in units where the coupling }J\text{ and Boltzmann's constant }k_B\text{ equal }1).$$

Even without a calculator one can box the answer in cleanly. Since
$\sqrt 2$ lies strictly between $1.41$ and $1.42$, the quantity $1+\sqrt 2$ lies
between $2$ and Euler's number $e \approx 2.71828$. Because the logarithm is
increasing, $\ln(1+\sqrt 2)$ lies strictly between $\ln 2 \approx 0.693$ and
$\ln e = 1$. Inverting and doubling, the critical temperature is trapped in the
honest interval

$$2 \;<\; T_c \;<\; 3.$$

This crude bracket already rules out any lazy misreading of the formula: $T_c$ is
a genuine transcendental number near $2.27$, not some disguised triviality.

The same fixed point has an equally pretty *bond* form. The natural variable in
the lattice expansions is not $\beta$ itself but $t = \tanh\beta$, the strength of
a single bond's correlation. At the critical point this collapses to

$$\tanh(\beta_c) \;=\; \sqrt 2 - 1 \;=\; e^{-2\beta_c}.$$

The middle expression, $\sqrt 2 - 1 \approx 0.41421$, is simply the reciprocal of
$1+\sqrt 2$ — the same silver number wearing a different mask. The identity
$\tanh\beta_c = e^{-2\beta_c}$ is the form Kramers and Wannier actually used, the
exact place where the high-temperature bond expansion and the low-temperature
contour expansion shake hands.

So the critical point is pinned down three independent ways, each a different
language for the same truth: **transcendentally** as $\sinh(2\beta_c) = 1$;
**algebraically** in bond variables as $\tanh(\beta_c) = \sqrt 2 - 1$; and
**numerically** as $2 < T_c < 3$, with true value $\approx 2.269$.

## Why the magnet really breaks

Knowing *where* the transition sits is one thing; proving that order *actually
survives* at low temperature is another. That order is real — that below $T_c$ the
infinite lattice settles into a magnetized state rather than washing out to zero —
is the content of a marvelous geometric argument by Rudolf Peierls, dating to
1936.

Peierls reasoned about the *boundaries* between regions of up-spins and
down-spins. Start from the all-up ground state and ask: could the system, in
thermal equilibrium at low temperature, secretly contain a large island of
flipped spins big enough to destroy the overall magnetization? Any such island is
surrounded by a closed contour — a loop on the grid separating "up" territory from
"down" territory. Flipping a region bounded by a contour of length $L$ costs energy
proportional to $L$, so its Boltzmann weight is suppressed by a factor like
$e^{-2\beta L}$: long boundaries are exponentially expensive when $\beta$ is large.

Now the combinatorial magic. The *number* of distinct contours of length $L$
through a given point grows only exponentially in $L$ — there are at most about
$3^L$ ways for a self-avoiding loop to wander. So the total probabilistic weight of
all large islands is bounded by a sum like $\sum_L 3^L e^{-2\beta L}$, a geometric
series that **converges and stays small** whenever $\beta$ is large enough that
$3\,e^{-2\beta} < 1$. The energy cost of a long fence beats the entropy of all the
ways to build it. Large islands are vanishingly rare; the sea of up-spins
percolates across the entire infinite lattice; and the magnetization stays
strictly positive. The symmetry is broken, and the magnet remembers which way it
was pointing. This is **spontaneous magnetization**, and the energy-versus-entropy
competition that drives it — short cheap fences win, long expensive ones lose — is
the same accounting that fixes the critical temperature in the first place.

By contrast, repeat the experiment in *one* dimension — a single chain of spins
rather than a sheet — and the magic fails. There the "boundary" of a flipped
segment is just a pair of points, costing a fixed energy no matter how long the
segment, while the number of places to put it grows with the chain. Entropy always
wins, the chain never orders at any positive temperature, and there is no phase
transition at all. The transfer-matrix method makes this exact: the chain's free
energy per spin equals the perfectly smooth function $\ln(2\cosh\beta)$, analytic
for every real $\beta$, with no crease anywhere. The contrast between the smooth
one-dimensional chain and the cusped two-dimensional sheet is precisely the
contrast between a world with no magnets and the world we live in.

## The shape of a deeper truth

It is worth pausing on how much is packed into the single equation
$\sinh(2\beta_c) = 1$. It says that the special temperature is not an accident of
detailed dynamics but a *symmetry point* — the one place where the model's low- and
high-temperature faces coincide. Such self-dual points turn up again and again
across physics and mathematics: in lattice gauge theories, in percolation, in the
study of the Riemann zeta function's functional equation, in string theory's
T-duality relating large and small spacetimes. The Ising critical point is the
simplest, sharpest member of this family — the place where a humble checkerboard of
arrows teaches a lesson about how the universe organizes itself.

The number $T_c = 2/\ln(1+\sqrt 2)$ is, in the end, a piece of poetry written in
the language of hyperbolic functions. It is what a magnet computes, silently, every
time it is heated through its Curie point — the temperature at which iron forgets,
and then remembers, itself.
