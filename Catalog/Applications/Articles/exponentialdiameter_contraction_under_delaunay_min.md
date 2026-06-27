# The Shrinking Mesh: How Refinement Tames Geometry, Even When It's Noisy

Picture a sculptor roughing out a statue. The first cuts are crude — big, blocky
facets that only hint at the shape inside. Then comes the refinement: each broad
plane gets split into smaller ones, then smaller still, until the surface
flows smoothly under the chisel. The same drama plays out, invisibly, inside
nearly every piece of computational geometry you've ever benefited from: the
weather forecast, the crash-test simulation, the animated film, the airflow over
a wing. All of them begin by chopping space into simple pieces — triangles in
the plane, tetrahedra in space, *simplices* in general — and then refining that
mesh until the pieces are small enough to trust.

The crucial question is the *speed* of that taming. If every round of refinement
only shaved a sliver off the largest piece, you'd be refining forever. What you
want is **geometric contraction**: every round multiplies the size of the worst
piece by a fixed fraction less than one, so the mesh collapses toward fineness
*exponentially fast*. Ten rounds and the worst piece is a thousandth of its
original size; twenty rounds and it's a millionth.

This article is about a clean mathematical heart of that phenomenon — and, more
interestingly, about what happens when refinement is *imperfect*. Real refinement
schemes are noisy. When you insert a new vertex (a "Steiner point") to split a
piece, you sometimes nudge the neighbors, you accumulate floating-point error, you
re-triangulate and a little local mess creeps back in. Does exponential
contraction survive that noise? And if the mesh never quite reaches zero, where
does it settle?

The answers turn out to be beautiful, exact, and provable.

## The ideal world: clean contraction

Let's name the quantity we care about. After $k$ rounds of refinement, let $d_k$
be the **diameter of the worst simplex** — the largest straight-line distance
across the biggest remaining piece. It is a nonnegative number, and the whole
game is to drive it down.

The cleanest possible model says: each round multiplies the worst diameter by a
fixed factor $1/\lambda$, where $\lambda > 1$. In symbols,
$$d_{k+1} \le \tfrac{1}{\lambda}\, d_k.$$
From this single assumption, an easy induction gives the exponential law
$$d_k \le \left(\tfrac{1}{\lambda}\right)^{k} d_0,$$
and since $1/\lambda < 1$, the right-hand side marches to zero. The mesh becomes
arbitrarily fine, and you can even compute *how many rounds* you need: for any
tolerance $\varepsilon > 0$ there is a finite step count $N$ after which
$d_k < \varepsilon$ forever.

Is this just wishful modeling? No — there's an honest geometric witness in the
simplest case. Take a one-dimensional simplex, an edge $[a,b]$. Its
"minicenter" — the center of the smallest ball enclosing it — is *exactly its
midpoint* $m = \tfrac{1}{2}(a+b)$. Splitting the edge there yields two
sub-edges, and each has length exactly half the original:
$$\operatorname{dist}(a,m) = \operatorname{dist}(m,b) = \tfrac{1}{2}\operatorname{dist}(a,b).$$
So edge bisection realizes the ideal law perfectly, with contraction factor
$\lambda = 2$: an edge of length $D$ becomes a worst sub-edge of length $D/2^k$
after $k$ rounds. The ideal model is not a fantasy; it is the exact behavior of
the very first case.

## The real world: noisy refinement and the attractor

Now add the noise. Suppose each round still contracts the geometry by a factor
$a$ (with $0 \le a < 1$), but *also* introduces a bounded perturbation of size at
most $b \ge 0$ — the local mess from inserting fresh Steiner points and
re-stitching the mesh. The recurrence becomes
$$d_{k+1} \le a\, d_k + b.$$
This is the **inhomogeneous contraction process**, and it is the protagonist of
our story. The number $a$ is how much the geometry shrinks; the number $b$ is
how much noise refuses to go away.

Two forces are now in tension. Contraction ($a < 1$) pulls the diameter down.
The additive defect ($b$) keeps pushing it back up. Where do they balance?

The answer is a single, memorable number — the **attractor radius**, or fixed
point:
$$L = \frac{b}{1-a}.$$
It is the level at which shrinking and noise exactly cancel. You can check the
balance directly: if the diameter sits at $L$, then one more round leaves it at
$a \cdot L + b = L$. The noise floor is self-sustaining. (It is also obviously
nonnegative, since $b \ge 0$ and $a < 1$.)

Here is the exact law governing the whole trajectory, the central theorem of the
work:
$$d_k \le a^{k}\, d_0 + b\,\frac{1 - a^{k}}{1 - a}.$$
This closed form, proved by induction, says something wonderfully concrete. The
first term, $a^k d_0$, is the *memory of the start* — it decays geometrically and
is soon forgotten. The second term climbs from $0$ up to $b/(1-a) = L$ as $k$
grows. Add them and you get a curve that slides smoothly from $d_0$ down toward
the attractor $L$.

Even cleaner is to measure the **excess over the noise floor**, $d_k - L$.
Rewriting the closed form around $L$ shows
$$d_k - L \le a^{k}\,(d_0 - L).$$
The *transient* — how far you are above where you'll eventually settle — decays
purely geometrically, exactly as in the noiseless world. Noise doesn't slow the
approach; it only changes the destination from $0$ to $L$.

A concrete example makes this vivid. Suppose each round contracts by $a = 1/2$
and re-injects a perturbation of $b = 1$, starting from a worst diameter of
$d_0 = 100$. The attractor is $L = 1/(1 - 1/2) = 2$. The bound predicts
$$d_k \le 100 \cdot (1/2)^k + 2\bigl(1 - (1/2)^k\bigr).$$
At $k=0$ that's $100$; at $k=5$ it's about $5.06$; at $k=10$ about $2.10$; at
$k=20$ it's $2.00009\ldots$. The diameter doesn't go to zero — it can't, because
the noise floor is $2$ — but it converges to that floor exponentially fast. After
twenty rounds you are, for all practical purposes, sitting exactly on the
attractor.

## Why the destination depends on how you ask

There is a subtle and honest twist here that the mathematics insists upon. The
*inequality* $d_{k+1} \le a d_k + b$ guarantees that you eventually drop below
$L + \varepsilon$ for any cushion $\varepsilon > 0$, and that this happens after a
finite, computable number of steps. But it does **not** guarantee that you
converge *to* $L$.

Why not? Because the inequality only bounds you from above. A scheme that simply
sets every diameter to zero — $d_k \equiv 0$ — satisfies $0 \le a\cdot 0 + b$
whenever $b \ge 0$. It contracts faster than required and lands below the
attractor, not on it. So from the inequality alone, all you can honestly claim is
the *one-sided* statement: the diameters are eventually trapped in the band
$[0,\, L+\varepsilon]$.

To get genuine, two-sided convergence to $L$, you need the *exact* recurrence
$$d_{k+1} = a\, d_k + b.$$
Under equality — when the noise really is reinjected at full strength every round
— the diameters converge to $L$ on the nose, with a sharp two-sided rate:
$$\bigl|\, d_k - L \,\bigr| \le a^{k}\,\bigl|\, d_0 - L \,\bigr|.$$
Whether you start above the floor or below it, you spiral in toward $L$ at the
geometric rate $a^k$. This distinction — inequality gives a trap, equality gives
a target — is exactly the kind of precision that separates a true theorem from a
plausible story.

## The hidden engine: a contraction map

Underneath all of this sits one of the most reliable engines in mathematics: the
**contraction mapping**. Consider the update rule as a function on the real line,
$$f(x) = a\,x + b.$$
Each refinement round applies $f$ to the current diameter (in the exact case) or
is dominated by it (in the inequality case). And $f$ is a contraction: for any two
values $x$ and $y$,
$$\operatorname{dist}\bigl(f(x), f(y)\bigr) = a \cdot \operatorname{dist}(x, y).$$
Distances between trajectories shrink by the factor $a$ every step. The classical
Banach fixed-point theorem then promises a single, unique fixed point that
everything converges toward — and a direct computation confirms it is precisely
our attractor $L = b/(1-a)$: it is fixed ($f(L) = L$), and it is the *only* fixed
point. The geometry of meshes and the abstract theory of contractions are, at
heart, the same theorem wearing two costumes.

This also explains two homely but important guarantees. Every iterate stays in
the bounded band $[0,\, d_0 + L]$ — refinement never blows up. And every single
step perturbs the diameter by at most $b$ — the noise is genuinely bounded, never
cumulative runaway.

## Are the bounds tight?

A skeptic should ask: maybe the inequality $d_k \le \cdots$ is loose, and real
trajectories do much better. The honest answer is that the bound is *achieved*.
There is an explicit process — call it the affine iteration — defined by starting
at any $d_0 \ge 0$ and applying $d_{k+1} = a d_k + b$ exactly. It satisfies the
recurrence with equality, its closed form is exactly $a^k d_0 + b(1-a^k)/(1-a)$,
and its limit is exactly $L$. So no scheme that suffers a per-step defect of size
$b$ can promise to settle below $b/(1-a)$. The attractor radius is not just an
upper bound on where you end up; it is the genuine, unbeatable noise floor.

## Why this matters beyond meshes

Strip away the geometry and you are left with a template that appears everywhere
a system is pulled toward order while being kicked by bounded noise:

- **Numerical analysis.** Iterative solvers that converge linearly but carry
  round-off error per step settle not at the true solution but at a noise floor of
  size proportional to the machine epsilon divided by $(1-a)$ — exactly $L$.
- **Control and signal processing.** A first-order filter $x_{k+1} = a x_k + b$
  is *literally* this recurrence; its steady state $b/(1-a)$ is the DC gain that
  every engineer computes.
- **Probability and learning.** Stochastic approximation and many
  reinforcement-learning updates contract toward a target while bounded noise
  keeps them hovering in a ball of radius $\sim b/(1-a)$ around it.
- **Adaptive simulation.** The original motivation: mesh refiners that can't
  afford perfect Steiner placement still enjoy exponential contraction down to a
  predictable, controllable resolution floor.

The lesson is liberating. You do not need perfect refinement to win. As long as
each round contracts more than it corrupts — as long as $a < 1$ — exponential
progress is guaranteed, and the only price of imperfection is a known, finite
floor $b/(1-a)$ below which you cannot go. Cut the noise $b$ in half and the floor
halves with it. Push the contraction $a$ toward zero and the floor approaches the
noise level $b$ itself.

From a sculptor's chisel to a climate model's grid, the mathematics says the same
thing: refine boldly. The geometry will shrink for you, exponentially, and even
when the world is noisy it will deliver you, swiftly and predictably, to a floor
you can name in advance — $b/(1-a)$, the place where shrinking and noise make
their peace.
