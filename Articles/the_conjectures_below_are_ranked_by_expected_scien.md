# When Does Structure Suddenly Snap Into Place? The Arithmetic of a Phase Transition

## A tale of two questions

Water does not become ice gradually. Cool it degree by degree and, for a long
while, nothing dramatic happens — until, at a single sharp temperature, the
whole liquid reorganizes itself into a crystal. Physicists call this a *phase
transition*, and one of the deepest lessons of twentieth-century science is that
the same abrupt reorganization shows up almost everywhere: in magnets, in
epidemics, in traffic jams, in the connectivity of vast networks.

A phase transition really asks two very different questions at once, and the
central idea of this article is that they should be *kept apart*:

1. **Where does the change happen?** At what point does an inert system suddenly
   "switch on"?
2. **How loudly does it announce itself?** Once switched on, how fast does the
   new order grow as we push further past the tipping point?

The surprising claim we will make precise is this: for a natural family of
number-theoretic models, the *location* of the tipping point is a rigid,
combinatorial fact — you cannot budge it — while the *loudness* is entirely a
matter of how you choose to measure. These are two logically independent
features of the same picture, and confusing them has muddied many an empirical
"discovery" of a critical threshold.

## Building a phase transition out of prime numbers

To make the idea concrete we need an arithmetic quantity that grows as we turn
some dial. Ours comes from one of the crown jewels of number theory, the theory
of *cyclotomic fields* — the number systems you get by adjoining a root of unity
$\zeta_n = e^{2\pi i/n}$ to the rational numbers $\mathbb{Q}$.

Attached to each such field is a symmetry group, its *Galois group*, and a
classical theorem (Artin reciprocity, the abelian tip of the celebrated
Langlands program) tells us its symmetries are labelled by the invertible
residues modulo $n$. The number of one-dimensional ways this symmetry can act on
the complex numbers — the number of *characters* — is therefore exactly Euler's
totient function $\varphi(n)$, the count of integers from $1$ to $n$ that share
no factor with $n$.

For a prime conductor $p$ this count is beautifully simple:
$$\varphi(p) = p - 1.$$

Think of $p - 1$ as the number of "connections" this arithmetic object supports.
As we run through larger and larger primes, the connection count climbs. That is
our dial.

Now we borrow the language of statistical mechanics. Fix a critical connection
budget $c = 10000$. Define an **order parameter** — a number measuring how much
large-scale coherence the system exhibits — by the mean-field square-root law
$$\Phi(x) = \sqrt{\kappa}\,\sqrt{\max(x - c,\, 0)},$$
where $x$ is the connection count and $\kappa > 0$ is a coupling strength. Below
the budget the order parameter is flatly zero: no coherence. Above it, coherence
switches on and grows like the square root of the excess $x - c$ — exactly the
signature of a classical (mean-field) critical point.

Feeding the arithmetic into the physics gives a clean, exact statement.

> **Arithmetic phase diagram.** For a prime conductor $p$, the modeled coherence
> is zero precisely when $p \le 10001$, and strictly positive precisely when
> $p > 10001$. Above the cutoff it obeys the exact law
> $\Phi = \sqrt{\kappa}\,\sqrt{(p-1) - 10000}$.

Why $10001$ and not $10000$? Because a prime $p$ contributes $p - 1$ connections,
and the condition "more than $10000$ connections" reads $p - 1 > 10000$, i.e.
$p > 10001$. The arithmetic quietly shifts the tipping point by one — a small but
honest reminder that the counting law, not the physics, sets the boundary.

## The main idea: the boundary is rigid, the exponent is free

Here is where the story becomes interesting. The square-root law above was a
*choice*. Nothing forced us to report coherence as a square root of the excess.
We could have used the excess itself, its cube root, its square, or any of a vast
zoo of "response laws." Does the tipping point move if we change our minds?

To answer this cleanly, strip the model down to its skeleton. The one quantity
that everything depends on is the **excess above threshold**,
$$e_c(x) = \max(x - c,\, 0),$$
the amount by which the connection count overshoots the budget (and $0$ if it
falls short). Two elementary but decisive facts:

- $e_c(x) = 0$ **exactly when** $x \le c$. The excess detects the boundary and
  nothing else.
- $e_c$ is monotone and continuous: nudging $x$ up never lowers the excess, and
  small changes in $x$ produce small changes in $e_c$.

Now let $F$ be *any* response law — any function we apply to the excess to get a
reported order parameter, $\Phi_F(x) = F\big(e_c(x)\big)$. Suppose only that $F$
is **zero-reflecting**: on nonnegative inputs, $F(y) = 0$ if and only if $y = 0$.
This is the mild demand that "no excess" and "no reported coherence" mean the
same thing. Then:

> **Deformation invariance of the boundary.** For every zero-reflecting response
> law $F$, the reported order parameter $\Phi_F$ vanishes exactly when $x \le c$.

In words: *the location of the tipping point does not depend on the response law
at all.* Square root, cube root, linear, quadratic — every zero-reflecting choice
switches on at the very same place. The boundary is an order-theoretic invariant,
baked into the arithmetic, immune to our measurement conventions.

What, then, *does* depend on the response law? The loudness — the critical
exponent. Take the power-law family $F(y) = y^{\alpha}$ for an exponent
$\alpha > 0$, giving $\Phi_\alpha(x) = \big(e_c(x)\big)^{\alpha}$. Each such law
is zero-reflecting, so all of them share the identical boundary. But they announce
themselves at wildly different volumes, and this is captured by an exact scaling
identity:

> **Exact critical scaling.** For distances $t > 0$ past the threshold and any
> magnification factor $a > 0$,
> $$\Phi_\alpha\big(c + a\,t\big) = a^{\alpha}\,\Phi_\alpha\big(c + t\big).$$

Magnify your distance from criticality by $a$, and the order parameter scales by
$a^{\alpha}$. The number $\alpha$ *is* the critical exponent, and this identity
pins it down without ever moving the boundary. The classical square-root physics
is simply the case $\alpha = \tfrac12$; a tree-like network would show
$\alpha = 1$; and every positive $\alpha$ is realizable.

Combining the two halves with the arithmetic gives the punchline for prime
conductors:

> **Universal arithmetic activation.** For *every* positive exponent $\alpha$,
> the power-law order parameter at prime conductor $p$ is strictly positive
> precisely when $p > 10001$ — the same cutoff for all $\alpha$ — while $\alpha$
> alone dictates how sharply coherence grows beyond it.

## Why this separation matters

This might sound like bookkeeping, but it dissolves a genuine confusion. When
scientists hunt for a critical threshold in real data — a tipping point in a
climate record, a percolation threshold in a network, a "phase change" in the
accumulation of knowledge — they measure some observable and look for where it
departs from zero. The theorem above warns: *the departure point is a property of
the system, but the shape of the departure is a property of your instrument.*
Two researchers using different (but equally reasonable) observables will agree
on **where** the transition sits and can legitimately disagree about its
**exponent**. Any claimed universality of an exponent must therefore be earned
from the geometry of the system, not read off a chosen measurement law.

It also clarifies what would make a threshold *scientifically real* rather than
merely stipulated. In our model the number $10000$ was inserted by hand. A more
satisfying threshold would be *derived* — recovered, for instance, as the peak of
a susceptibility curve (the expected jump in global coherence when one more
connection is verified). The rigidity theorem tells us exactly what such an
empirical search may and may not blame for a moving threshold: not the choice of
observable, which provably cannot move it, but the way the underlying network of
connections is built and weighted.

## The horizon

The prime-conductor model is deliberately the simplest rung on a tall ladder. Its
value is as a *null model* with an exactly known answer, against which bolder
conjectures can be tested. Several beckon:

- **Higher-rank networks.** Replace one-dimensional characters by a bipartite
  graph of rank-two automorphic and Galois representations, linked by established
  compatibilities. Does a giant connected component appear above a universal mean
  degree — and, as the rigidity theorem predicts, at a boundary untouched by how
  we report component size?
- **Arithmetic universality.** Ordering number fields by their discriminant, do
  their coherence exponents fall into finitely many classes — exponent $1$ for
  tree-like compatibility networks, $\tfrac12$ for symmetry-breaking character
  models — determined by local geometry rather than by the names of the objects?
- **Derived thresholds.** Can the cutoff near ten thousand be *recovered* as a
  unique susceptibility peak instead of stipulated, and shown stable under every
  zero-reflecting change of observable?
- **Totient intermittency.** Beyond primes, composite conductors replace the
  smooth law $p - 1$ by the jagged $\varphi(n)$. Do conductors then cross the
  threshold in clustered cascades, so that every short window
  $[T, T + T^{\theta}]$ straddles the boundary $\varphi(n) > T$?

Each of these keeps faith with the same discipline learned from the simplest
case: *measure the arithmetic, then choose the lens — and never confuse the two.*
The place where structure snaps into being is written in the numbers themselves.
How brightly it shines when it does is up to us.
