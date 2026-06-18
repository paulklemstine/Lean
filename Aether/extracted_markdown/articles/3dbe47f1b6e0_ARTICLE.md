# The Shape of a Signal: How Geometry Tells a Neural Network When to Stop

## A puzzle hidden in plain sight

Imagine a rumor spreading through a crowd. At first, it travels fast and far. Each
person tells their neighbors, who tell *their* neighbors, and within a few rounds the
news has reached every corner of the room. But keep the process going — round after
round, everyone repeating what they just heard — and something strange happens. The
crowd stops being a crowd of individuals with distinct opinions and becomes a single
murmuring blur. Everyone is saying the same thing. The information that made each person
*different* has been smoothed away.

This is not just a parable. It is, almost exactly, the central failure mode of one of
the most important tools in modern artificial intelligence: the **graph neural
network**. These networks learn by passing messages between connected nodes — proteins
in a molecule, users in a social network, intersections in a road map — and at each
step every node updates itself by mixing in what its neighbors told it. Mix a little,
and the network learns rich, useful structure. Mix too much, and you get the murmuring
blur. Practitioners have a name for this catastrophe: **oversmoothing**. Build the
network too deep, and all the signal washes out.

For years, oversmoothing was treated as a kind of engineering nuisance — something to be
patched with tricks and heuristics. But underneath it lies a beautiful and very old
piece of mathematics, one that connects the smoothing of signals to the *shape* of the
space they live on. This article is about that connection, and about two precise,
machine-checked theorems that pin it down. The first reveals exactly *what* survives the
smoothing — and shows that the survivors are a topological fingerprint of the underlying
space. The second tells us *how long* it takes for everything else to wash out — and
shows that the answer is governed by a single, clean logarithmic clock.

## From graphs to shapes: the Hodge Laplacian

To see the mathematics, we need to upgrade our picture of a network. An ordinary graph
has *nodes* and *edges*. But many real structures have more: triangles filling in
triples of mutually connected nodes, tetrahedra filling in quadruples, and so on. Such a
layered object — points, edges, triangles, higher cells — is called a **simplicial
complex**, and it is the natural home of *higher-order* message passing, where signals
live not just on nodes but on edges, on triangles, on whatever level you like. A signal
attached to the `k`-dimensional pieces is called a `k`-**cochain**.

The engine that drives smoothing on such a structure is a single linear operator: the
**Hodge Laplacian**. To build it we need the *boundary maps* of the complex — the
bookkeeping that records which lower cells sit on the edge of which higher cells. Write
`∂ₖ` for the map that sends a `k`-cell to its boundary (a combination of `(k-1)`-cells),
and `∂ₖ₊₁` for the map one level up. Realized as matrices, call them `D` (the *down* or
divergence map) and `E` (the *up* or gradient map). The full Hodge Laplacian on
`k`-cochains is then

> **L = Dᵀ D + E Eᵀ.**

This is the centerpiece of our first result, and it deserves a moment of admiration. It
is a sum of two pieces. The first, `Dᵀ D`, is the *down* Laplacian: it measures how much
a signal fails to be **closed**, i.e. how much it has nonzero boundary below. The second,
`E Eᵀ`, is the *up* Laplacian: it measures how much a signal fails to be **coclosed**,
i.e. how much it looks like the gradient of something above. Earlier work in this program
modeled only the up-Laplacian `Bᵀ B` — a single channel. The full operator restores the
genuine two-sided structure that algebraic topologists have studied for a century.

## What energy reveals

How do we measure "how smooth" a signal is? With its **Dirichlet energy** — a single
number that is small for gently varying signals and large for jagged ones. For the Hodge
Laplacian, the energy of a cochain `x` is the quantity `⟨x, Lx⟩`. The first theorem we
want to celebrate is an exact decomposition of this energy:

> **Energy split (`fullHodge_quadform`).** For every cochain `x`,
> `⟨x, Lx⟩ = ‖D x‖² + ‖Eᵀ x‖².`

Read it slowly. The total smoothing energy splits *cleanly* into two non-negative parts:
a **closed channel** `‖D x‖²` measuring boundary content below, and a **coclosed
channel** `‖Eᵀ x‖²` measuring gradient content above. There is no cross-talk, no
interference term muddying the split. Two immediate consequences fall out for free. The
energy is never negative — the operator is **positive semidefinite** (`fullHodge_psd`),
which is what makes message passing a *stable* smoother rather than an amplifier. And the
operator is **symmetric** (`fullHodge_isSymm`), the formal expression of the fact that
energy is exchanged fairly in both directions.

## The signals that never die: a discrete Hodge theorem

Now for the heart of the matter. A signal is called **harmonic** if its smoothing energy
is exactly zero — if `L x = 0`. Harmonic signals are the ones that message passing leaves
completely untouched: pour them through a network of any depth and they emerge unchanged.
They are the survivors of oversmoothing. So: *which* signals survive?

Because the energy splits into two non-negative pieces, the total can only be zero when
*both* pieces are zero. That gives a startlingly clean answer:

> **Discrete Hodge theorem (`fullHodge_kernel`).** A cochain is harmonic if and only if
> it is simultaneously **closed** (`D x = 0`) and **coclosed** (`Eᵀ x = 0`):
> `L x = 0 ⟺ D x = 0 and Eᵀ x = 0.`

This is not a numerical accident. The space of closed-and-coclosed cochains is, in the
language of topology, the `k`-th **cohomology** of the complex — a genuine invariant of
its *shape*, insensitive to how you triangulate or coordinatize it. A loop around a hole
in a doughnut is harmonic; a ripple that can be flattened out is not. The theorem says,
in effect: *message passing forgets everything except the topology.* What survives an
infinitely deep network is precisely the count of holes, voids, and higher-dimensional
tunnels in the data's underlying space.

There is one more delicate ingredient. The two channels are guaranteed not to overlap
only because of the famous **chain condition** `∂ₖ ∂ₖ₊₁ = 0` — "the boundary of a
boundary is empty," the identity that makes all of homology theory work. In our matrix
language this reads `D E = 0`, and it is consumed in exactly one place:

> **Image orthogonality (`hodge_image_orthogonal`).** If `D E = 0`, then every gradient
> field `E y` is orthogonal to every divergence field `Dᵀ z`: `⟨E y, Dᵀ z⟩ = 0.`

From this single orthogonality, a Pythagorean theorem for signals follows immediately:
the energy of a gradient-plus-curl field is just the sum of the two separate energies
(`hodge_energy_pythagoras`). The deep geometry of "the boundary of a boundary is zero"
becomes, at the level of energy, the most familiar identity in all of mathematics:
`a² + b² = c²`.

## The logarithmic clock: how deep is deep enough?

We now know *what* survives. The second theorem answers *how fast everything else dies*.

Suppose one layer of message passing shrinks the Dirichlet energy by a factor `ρ`
somewhere strictly between 0 and 1 — the contraction regime that holds off the harmonic
core, governed by the operator's spectral gap. Then `k` layers shrink the energy by `ρ`
raised to the `k`-th power: `‖Tᵏ x‖² ≤ ρᵏ ‖x‖²` (`quadform_iterate_bound`). The residual
energy decays *geometrically*. This is the engine of smoothing — and, run too long, the
engine of oversmoothing.

The old result merely promised that *some* finite depth would push the residual below any
target tolerance `ε`. Useful, but vague: it never said how deep. The new theorem replaces
that shrug with a formula. Define the depth

> **N(ε) = ⌈ log\_ρ (ε / ‖x‖²) ⌉.**

This is the **`hodgeDepth`**, an explicit, computable number of layers. And it provably
suffices:

> **Logarithmic depth law (`hodgeDepth_residual_bound`).** For every depth `k ≥ N(ε)`,
> the residual energy is at most `ε`.

Specialized to the concrete message-passing operator `x ↦ x − α L x`, this becomes
`hodge_mp_log_depth`. The analytic crux is a small but subtle lemma
(`pow_le_of_logb_le`): to make `ρᴺ ≤ c`, it is enough that `N ≥ log\_ρ c`. The subtlety is
a sign flip — because `ρ < 1`, its logarithm is *negative*, and the inequality must be
turned around carefully. Get that wrong and the whole bound reverses.

The punchline is the qualitative shape of `N(ε)`. To buy one more decimal digit of
accuracy — to shrink `ε` by a factor of ten — you do *not* need ten times more layers.
You need a *constant number* more, set by `ρ`. Accuracy improves geometrically with
depth; equivalently, depth grows only **logarithmically** with the demanded precision.
This is the quantitative depth–accuracy trade-off, and it is exactly the kind of clean
scaling law that lets engineers size a network rationally instead of by trial and error.

## Why this matters

Step back and the two theorems lock together into a single picture. Message passing is a
**deformation retraction**: a continuous shrinking of the space of all signals onto a
small, special core. The core is the harmonic space — and by the discrete Hodge theorem,
that core *is the topology* of the data, the cohomology that counts its holes. The speed
of the retraction is set by an explicit **logarithmic clock**, the `hodgeDepth`, ticking
at a rate fixed by the spectral gap.

For the practitioner staring at an oversmoothing curve, this reframes a nuisance as a
law. Oversmoothing is not a bug; it is the network doing exactly what the geometry
demands — collapsing onto the topological invariants of the data at a logarithmically
predictable pace. Knowing the survivors are cohomology classes tells you what
information a deep network can and cannot retain. Knowing the depth is `⌈log\_ρ(ε/E)⌉`
tells you how many layers to budget for a target accuracy, and — because the energy `E`
sits inside a logarithm of a ratio — that incremental accuracy gains depend only on the
*ratio* of tolerances, not on the raw size of the signal.

There is a further beauty in the bookkeeping. Because the harmonic space is `ker D` cut
down by removing the gradient image `range E`, its dimension is governed by the most
elementary theorem in linear algebra — rank–nullity — applied to the boundary maps. The
abstract Betti numbers of topology, the global counts of holes, become computable from
purely *local* incidence data: who touches whom. A global invariant, read off from a
local ledger.

## The view from here

What makes these results satisfying is not their difficulty but their inevitability.
Once you see the energy split into two non-negative squares, the discrete Hodge theorem
is forced. Once you see the decay is geometric, the logarithmic depth is forced. The
hard part was finding the *right* objects — the full two-map Laplacian, the explicit
ceiling-of-a-logarithm depth — so that the theorems could fall out as clean,
machine-verifiable certainties.

The crowd in our opening parable will always, eventually, fall into a single murmur. But
now we know precisely what that murmur encodes — the unchanging shape of the room they
stand in — and exactly how many rounds of whispering it takes to get there. The rumor
was never really lost. It was being distilled, layer by logarithmic layer, into geometry.
