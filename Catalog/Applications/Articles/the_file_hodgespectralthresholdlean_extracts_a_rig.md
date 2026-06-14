# When Depth Forgets Shape: How Networks Learn to See Only the Holes

## A puzzle hiding inside modern machine learning

Imagine you are handed a strange, many-dimensional object — not a smooth
surface like a sphere or a doughnut, but a sprawling combinatorial scaffold
built from points, edges, triangles, tetrahedra, and their higher-dimensional
cousins. Mathematicians call such a thing a *simplicial complex*. It is the
natural language for anything where relationships come in groups rather than in
pairs: a protein where three residues touch at once, a social network where a
whole committee interacts, a sensor array where overlapping regions cover a
landscape.

Now suppose you want a machine to learn something about this object. A modern
approach is **message passing**: each piece of the scaffold repeatedly mixes its
own information with that of its neighbors, layer after layer, until a useful
pattern emerges. Stack a few layers and the machine sees local detail. Stack
many and information spreads farther.

But practitioners noticed something unsettling. As these networks get *deeper*,
they often get *worse* at telling shapes apart. Two very different scaffolds —
one with many holes, one with few — start to look identical to a deep enough
network. The fine geometry washes out. The machine becomes, in a precise sense,
**blind to almost everything except the holes themselves**.

Is this a bug, a coincidence, or a law of nature? This article tells the story
of why it is a law — and exactly where the tipping point lies.

## The shape of a shape: harmonics and holes

To understand the phenomenon we need one beautiful idea that has been circling
mathematics for two centuries: **the Laplacian**.

On a vibrating drum, the Laplacian is the operator whose special vibration
patterns — its *eigenmodes* — are the pure tones. Low tones are smooth; high
tones wiggle rapidly. On our combinatorial scaffold there is an exact analogue,
the **Hodge Laplacian**, written `Δ`. It acts on *cochains*: assignments of a
number to every triangle (or every edge, or every tetrahedron — pick a
dimension `k` and stay there).

The Hodge Laplacian splits cleanly into two halves that pull in opposite
directions along the scaffold:

- an **upper Laplacian** `up`, which measures how a value on a triangle fails to
  agree with the higher-dimensional cells built on top of it, and
- a **lower Laplacian** `down`, which measures how it fails to agree with the
  lower-dimensional cells it sits upon.

Their sum is the full Hodge Laplacian:

> **Definition (Hodge Laplacian).** `Δ = up + down`.

Both halves share two crucial properties. They are **symmetric** — swapping the
two slots of the inner product `⟪up x, y⟫ = ⟪x, up y⟫` makes no difference — and
they are **positive semidefinite**, meaning the energy `⟪up x, x⟫` is never
negative. (The same holds for `down`.) These are not technical decorations; they
are the source of everything that follows.

The miracle, known as **discrete Hodge theory**, is this: the cochains that the
Laplacian annihilates — the solutions of `Δ x = 0`, called **harmonic**
cochains — are in exact one-to-one correspondence with the *holes* of the
scaffold. The dimension of this harmonic space is a Betti number, a count of
independent loops or voids. The harmonic cochains *are* the topology, made
algebraic.

So our question becomes sharp: when a deep network filters a cochain through
many layers, what survives?

## One layer at a time

Model a single message-passing layer as the simplest possible operator built
from the Laplacian:

> **Definition (one layer).** `T = 1 − t·Δ`, where `t > 0` is a small step size.

Reading this is easy: "leave the cochain mostly alone, but nudge it a little in
the direction the Laplacian points." Applying the layer `L` times — stacking `L`
layers of equal width — gives depth-`L` message passing:

> **Definition (depth-`L` map).** `Tᴸ`, the `L`-fold composition of `T` with
> itself.

Everything we want to know is encoded in how `Tᴸ` treats the eigenmodes of `Δ`.

## Half the story: topology never moves

Here is the first theorem, and it is exact — not approximate, not asymptotic,
and astonishingly it needs no assumption that the space is finite-dimensional.

> **Topology is depth-invariant.** If `x` is harmonic, that is `Δ x = 0`, then
> `Tᴸ x = x` for *every* depth `L`.

Why? If `Δ x = 0` then a single layer does `T x = x − t·Δ x = x − 0 = x`.
Nothing happens. Repeat forever; still nothing happens. The harmonic cochains
are perfect, unshakeable fixed points of the network at every depth. Whatever
else the machine forgets, it can never forget the holes.

But we can say *what* harmonic means in a far more useful way. A cochain is
harmonic exactly when **both** halves of the Laplacian kill it:

> **Harmonic = closed and coclosed.** `Δ x = 0` if and only if `up x = 0` and
> `down x = 0`. Equivalently, the kernel of the Laplacian is the intersection of
> the two kernels: `ker Δ = ker up ⊓ ker down`.

This looks almost too clean. After all, `Δ x = up x + down x`, and in general a
sum being zero does not force each summand to be zero — they could cancel. The
reason they *cannot* cancel here is the deepest small lemma in the whole story,
worth stating on its own.

> **Hodge vanishing principle.** If `S` is symmetric and positive semidefinite,
> and the energy `⟪S x, x⟫ = 0`, then in fact `S x = 0`.

In words: for these well-behaved operators, *zero energy means zero motion.* A
positive-semidefinite form is, by a one-line Cauchy–Schwarz argument, pinned to
the ground exactly where its diagonal value vanishes. Apply this to the energy
identity `⟪Δ x, x⟫ = ⟪up x, x⟫ + ⟪down x, x⟫`: both terms on the right are
non-negative, so if their sum is zero each must be zero, and the vanishing
principle then forces `up x = 0` and `down x = 0` separately. The harmonic
cochains are precisely those that are simultaneously "closed" (`down x = 0`) and
"coclosed" (`up x = 0`).

One more invariance rounds out this half. The space orthogonal to the harmonic
cochains — everything that is *not* topology — is itself preserved by the layer:

> **Orthogonal invariance.** The orthogonal complement `(ker Δ)ᗮ` is invariant
> under `T = 1 − t·Δ`.

So the network cleanly separates the world into two non-mixing parts: the
harmonic part, frozen in place, and its complement, where all the action — and,
as we will now see, all the *decay* — happens.

## The other half: everything else fades

Inside the non-harmonic world, the Laplacian behaves like a collection of
independent tuning forks. Each eigenmode has an eigenvalue `λ > 0` measuring how
"un-harmonic" it is — how sharply it wiggles across the scaffold. A single layer
multiplies that mode's amplitude by exactly `1 − tλ`. After `L` layers the
amplitude is

> `(1 − tλ)ᴸ`.

Choose the step size `t` small enough (the natural normalization `0 < tλ < 1`)
and `1 − tλ` is a number strictly between zero and one. Raise it to a high power
and it collapses toward zero. Depth is a *contraction* on every non-harmonic
mode.

The crucial quantity is the **spectral gap** `μ`: the smallest nonzero
eigenvalue, the amplitude of the gentlest non-harmonic mode. Because `(1 − tλ)`
shrinks as `λ` grows, the gentlest mode is the slowest to die, and it controls
everyone:

> **Mode decay.** For any non-harmonic eigenvalue `λ ≥ μ`, we have
> `(1 − tλ)ᴸ ≤ (1 − tμ)ᴸ`. The whole non-harmonic spectrum decays at least as
> fast as the gap mode.

> **The gap mode vanishes.** `(1 − tμ)ᴸ → 0` as `L → ∞`.

Contrast this with the harmonic modes, where the eigenvalue is `λ = 0`, the
per-layer factor is `(1 − t·0) = 1`, and so:

> **Harmonic modes are immortal.** A harmonic mode keeps amplitude exactly `1` at
> every depth.

The picture is now complete and vivid. Depth acts as a **low-pass filter** on
the Hodge spectrum. High-frequency, geometric, non-topological detail is damped
toward nothing. The zero-frequency, harmonic, topological content alone survives
untouched. A deep network does not "fail" to see geometry — it *converges* to
seeing only topology.

## The tipping point, written down

The most satisfying part is that we can name the exact depth at which geometry
effectively disappears. Fix any tolerance `ε > 0` — the amplitude below which we
agree to call a mode "gone." We want `(1 − tμ)ᴸ ≤ ε`. Taking logarithms of both
sides (and remembering that `log(1 − tμ)` is negative, which flips the
inequality) gives an explicit **critical depth**:

> **Depth threshold.** There is an explicit
> `L_c ≈ log ε / log(1 − tμ)` such that for every depth `L > L_c`, *every*
> non-harmonic mode of gap at least `μ` is suppressed below `ε`, uniformly across
> the entire spectrum — while harmonic modes remain at amplitude `1`.

Read off the dependence. To suppress geometry ten times more sharply (a tenfold
smaller `ε`), you need an *additive* increase in depth, not a multiplicative one:
the cost grows like `log(1/ε)`. And the gap `μ` sits in the denominator, so
scaffolds with a *small* spectral gap — those that are nearly disconnected or
nearly higher-dimensionally degenerate — demand *much* deeper networks before
their geometry blurs out. The geometry of the data sets the price of forgetting
it.

## Why this matters beyond the proof

This little theory is a precise, provable shadow of a sweeping conjecture in the
theory of very wide neural networks — the idea that as such networks scale, their
behavior on structured data passes through a **universality threshold**, beyond
which the fine details of the architecture and the geometry stop mattering and
only coarse, robust, topological features remain. Our result captures the
clean linear-algebraic heart of that claim and turns it into mathematics with no
loose ends:

- **It explains over-smoothing.** The notorious tendency of deep
  message-passing networks to collapse all signals into a uniform blur is, in the
  Hodge picture, not pathology but inevitability: the only signals immune to
  collapse are the harmonic (topological) ones, and the rate of collapse is set
  by the spectral gap.

- **It gives a design dial.** If you *want* a network to preserve geometric
  detail, keep it shallower than `L_c`; if you want it to distill pure topology —
  to count holes, components, and voids robustly — push it past `L_c`. The
  threshold is a knob, computed from the data's own spectrum.

- **It connects two great traditions.** On one side, Hodge theory and the
  topology of shape; on the other, the dynamics of learning in deep networks. The
  bridge between them is a single operator, `1 − tΔ`, raised to a power.

There is a quiet elegance to the conclusion. We often fear that depth destroys
information. Here, depth is a sculptor: it patiently chisels away everything that
can be deformed, everything that is merely geometric and accidental, until what
remains is the one feature that *cannot* be deformed away — the shape's holes,
its topology, the part that was true all along. Forgetting, done carefully, is
how the machine learns to see what matters.
