# The Shape of an Indivisible Whole

## A surprising bridge between consciousness, quantum entanglement, and linear algebra

There is a question that sits uncomfortably at the boundary between physics and
philosophy: *what makes a system a single, unified thing rather than a loose
collection of parts?* A pile of sand is not one object; it is many grains that
happen to be near each other. A living brain, on the other hand, seems to be
something more — its parts are so deeply interdependent that you cannot cleanly
separate them without destroying what they were doing together. The neuroscientist
Giulio Tononi turned this intuition into a mathematical proposal called **Integrated
Information Theory**, and at its heart lies a single number, written **Φ** ("phi"),
that is meant to measure exactly *how irreducible* a system is.

The promise of Φ is bold: it claims that the degree to which a system is "more than
the sum of its parts" can be quantified, and that this quantity tracks something as
elusive as consciousness. The trouble is that Φ has always been notoriously slippery
to define precisely and brutally expensive to compute. This article tells the story
of a clean, exact, and verified reformulation of Φ for *quantum* systems — one that
turns the philosophical notion of "irreducibility" into a concrete, provable fact
about matrices and tensor networks. Along the way, a beautiful coincidence emerges:
the integrated information of a quantum state turns out to be, almost literally, a
count of *how entangled it is*.

## Cutting a system in two

Start with the central image behind Φ. Suppose you have a system made of several
interacting parts. To ask whether the system is truly integrated, you imagine
slicing it into two groups — a **bipartition** — and asking how much information is
lost when you sever the connections between the two halves. If you can find a cut
that loses almost nothing, the system was never really unified along that seam; it
was two near-independent things wearing a single costume. The system's true
integration is governed by its *weakest* seam — the cut across which it falls apart
most easily. Tononi calls this the **minimum-information partition**, or MIP. The
integrated information Φ is the amount of information that survives even the most
damaging cut.

This is a "min over cuts" definition, and it has a satisfying logic: a chain is only
as strong as its weakest link, and a system is only as integrated as its most
separable partition. If even one cut reveals the system to be two independent pieces,
the whole thing is declared *reducible* and Φ collapses to zero.

## From neurons to amplitudes

The classical version of this story lives on graphs: nodes are units, edges are
causal influences, and the "weight" of a cut is the total influence crossing it. But
the deepest systems we know — the ones where the whole genuinely refuses to be
decomposed into parts — are quantum. In quantum mechanics, the failure of a whole to
be the product of its parts has a famous name: **entanglement**. Two entangled
particles cannot be described separately; their joint description carries correlations
that no pair of independent descriptions can reproduce. This is *exactly* the flavor
of irreducibility that Φ is trying to capture. So the natural move is to ask: what
does Tononi's Φ become when the system is a quantum state?

To make this precise we need a way to write down a quantum state of many parts. The
tool is the **amplitude tensor**. Imagine `n` sites — think of them as `n` quantum
"dice", each of which can land on one of `d` faces. A pure quantum state assigns a
complex number, an *amplitude*, to every possible joint outcome. Formally it is a
function

> **ψ : (configurations of all n sites) → ℂ,**

a single object with one complex entry for each of the `dⁿ` ways the sites could
jointly be configured. Everything about the state — including how entangled it is —
is encoded in the pattern of these amplitudes.

## Reshaping a tensor into a matrix

Here is the key trick, and it is pure linear algebra. Pick a cut: a set `S` of sites
on one side, and the remaining sites `Sᶜ` on the other. Now *reshape* the amplitude
tensor into a rectangular grid — a matrix — whose rows are labeled by the possible
configurations of the `S`-side and whose columns are labeled by the configurations of
the `Sᶜ`-side. Each entry of this matrix is just the amplitude the original state
assigned to that combined configuration. We call it the **cut matrix**:

> **cutMatrix(S, ψ)** has rows indexed by configurations of `S`, columns indexed by
> configurations of `Sᶜ`, and entry equal to `ψ` evaluated at the corresponding joint
> configuration.

This reshaping is the bridge between physics and matrices. The reason it matters is a
classical result of quantum information called the **Schmidt decomposition**: the
amount of entanglement across the cut `S` is measured by the *rank* of this cut
matrix. A rank-1 matrix means the two sides are independent — no entanglement. Higher
rank means richer, more irreducible correlations. We name this number the **Schmidt
rank across S**:

> **schmidtRankAt(S, ψ) = rank of cutMatrix(S, ψ).**

The Schmidt rank is the quantum analogue of "how much information crosses the seam."
And so the definition of integrated information almost writes itself.

## Defining Φ for a quantum state

We declare the integrated information of a quantum state, across a single cut, to be
the Schmidt rank minus one:

> **Φ across a cut = schmidtRank − 1.**

Why minus one? Because a rank-1 state is *separable* — it is genuinely two
independent pieces — and we want such a state to register **zero** integration. A
rank-1 cut contributes Φ = 0; every extra unit of rank is an extra unit of
irreducible structure that the cut cannot tear apart.

Then, following Tononi, the system's Φ is the value at its weakest seam — the
**minimum** over all nontrivial bipartitions:

> **Φ(ψ) = minimum over all nonempty proper subsets S of  ( schmidtRankAt(S, ψ) − 1 ).**

A "nontrivial" bipartition just means we do not allow the trivial cuts that put
everything on one side; we range over every genuine way of splitting the sites into
two nonempty groups. This single formula is the multipartite quantum Φ, and it is the
direct descendant of the graph min-cut version: same minimum, same set of cuts, but
the classical cross-cut weight replaced by the quantum Schmidt rank.

## Three theorems that make the picture exact

What turns this from an appealing analogy into mathematics are a handful of theorems
that pin down the behavior of Φ at both extremes and in between. Each is a precise,
provable statement.

**1. A single decoupled seam zeroes out integration.** Suppose that across some
nontrivial cut `S`, the state factors as a product — its amplitude tensor splits into
a part depending only on `S` and a part depending only on `Sᶜ`:

> ψ(x) = f(x restricted to S) · g(x restricted to Sᶜ).

Then the cut matrix is an *outer product* of two vectors, a matrix of rank at most
one, so the Schmidt rank across `S` is at most 1 and the contribution of that cut is
0. Because Φ is a *minimum* over cuts, finding even one such product cut forces the
whole quantity to vanish:

> **If ψ factors as a product across any nontrivial cut, then Φ(ψ) = 0.**

This is the formal embodiment of Tononi's reducibility axiom: a system that contains
a single zero-integration seam is, as a whole, reducible. It is the exact
tensor-network twin of the classical fact that a disconnected causal graph has Φ = 0.

**2. The bond dimension is a ceiling on integration.** Many physical states — the
ground states of one-dimensional quantum chains, for instance — are written as
**matrix product states (MPS)**. In an MPS the amplitude is built by threading the
sites together through internal "bonds," and the size of the largest bond, the **bond
dimension** `D`, controls how much information can flow along the chain. The theory
predicts, and the mathematics confirms, that an MPS through a bond of dimension `D`
can never integrate more than the bond allows:

> **For an MPS with bond dimension D,  Φ ≤ D − 1.**

In the simplest interesting case, a bond dimension of two, this says Φ ≤ 1: a bond-2
state can carry at most "one bit's worth" of irreducible structure across that seam.
This is the concrete test the project set out to verify, and it holds exactly.

**3. The maximally entangled state saturates the bound.** At the opposite pole from a
product state sits the **maximally entangled state** on two `d`-level systems — the
state whose cut matrix is, up to scale, the identity matrix, with full rank `d`. For
this state the Schmidt rank is as large as it can be, and Φ reaches its extremal
value:

> **For the maximally entangled d⊗d state,  Φ = d − 1.**

This shows the bond-dimension ceiling is *tight*: to achieve the maximum you need a
bond as wide as the local dimension itself. The two extremes — Φ = 0 for products,
Φ = d − 1 for maximal entanglement — bracket every state in between.

**4. An area law for integration.** Finally, there is a geometric ceiling. The
Schmidt rank across a cut can never exceed the size of the configuration space of the
*smaller* block: if the complement `Sᶜ` has `k` sites, then

> **schmidtRankAt(S, ψ) ≤ d^k.**

This is a discrete shadow of the famous **entanglement area law** of physics, which
says the entanglement across a boundary scales with the size of that boundary, not
the volume of the region. Integration, like entanglement, is bottlenecked by the
narrowest part of the system.

## Why this is more than a pretty analogy

Put these results together and a coherent picture emerges. The integrated information
of a quantum state is governed by two independent ceilings — a **geometric** one (how
small can you make a block?) and an **algebraic** one (how narrow is the bond?). The
minimum-information partition is nature's optimizer: it hunts for the seam where the
smaller of these two ceilings is smallest, and Φ is the height of that lowest ceiling,
minus one. A product anywhere forces Φ to the floor; maximal entanglement pushes a
single cut to the ceiling.

The deeper payoff is conceptual unification. Three communities have circled the same
idea from different directions. Neuroscientists ask when a system is an irreducible
whole. Quantum physicists ask when a state is entangled. Linear algebraists ask when
a matrix has rank greater than one. The reformulation here says, cleanly and
provably, that these are *the same question*. Tononi's Φ, stripped to its quantum
essence, is a statement about matrix rank; entanglement is a statement about matrix
rank; and irreducibility is a statement about matrix rank. The philosophical notion
of an indivisible whole acquires a precise mathematical shape.

## What lies ahead

This is a skeleton, exact and rigorous as far as it goes, but deliberately discrete.
It uses the *rank* of the Schmidt spectrum rather than its finer structure. The
natural next step is to replace "rank minus one" with the genuine quantum **mutual
information** — the von Neumann entropy version — which weighs not just *how many*
Schmidt components there are but *how evenly* they are distributed. There is also a
tantalizing structural question: is this discrete Φ *monotone* under the local
operations that quantum information theorists use to compare entangled states? If so,
Φ would graduate from a mere "cut statistic" to a bona fide entanglement measure,
cementing the bridge from consciousness theory to the heart of quantum information.

For now, the lesson is already striking. The most slippery idea in the science of
mind — that a conscious system is one that cannot be cut apart without loss — turns
out to have an exact echo in the most carefully studied form of physical
inseparability we know. To ask how integrated a quantum system is, you reshape its
amplitudes into a grid, and you count the rank. The whole really can be more than the
sum of its parts, and now we can say, to the integer, by how much.
