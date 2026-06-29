# Where Everything Rolls Downhill: Counting the Valleys of a Dynamical World

Drop a marble onto a crumpled landscape and let go. It rolls, it wobbles, it
loses a little energy at every bounce, and eventually it settles into a valley.
Do it again from a slightly different spot and it might settle into the *same*
valley — or a different one. The set of all starting points that drain into one
particular valley is that valley's **basin of attraction**. The whole landscape
is carved up into these basins, one per valley, like watersheds dividing a
continent into river systems.

This picture is everywhere. It is how a memory network recalls a stored pattern
from a noisy hint. It is how a machine-learning model slides down a loss
landscape toward a configuration that works. It is how a crystal anneals, how a
spin glass freezes, how an optimization algorithm converges. In every case the
same two questions return: *how many valleys are there?* and *which starting
points belong to which valley?*

There is a beautifully simple answer hiding underneath all of this, and it can
be stated and proved with complete rigor. **In a discrete world where everything
genuinely rolls downhill, the number of basins of attraction is exactly the
number of resting places.** Not "approximately," not "generically," not "under
mild conditions" — exactly, always. This is the **Basin Fixed Point Theorem**,
and this article is the story of why it is true and why it matters.

## The setup: a world that can't waste time

Let's make the marble picture precise without losing its intuition. We work with
a finite collection of possible states — call the whole collection `S`. You can
think of `S` as the set of all black-and-white pictures on a fixed grid, or all
configurations of a small physical system, or all of the discrete "positions" an
algorithm can occupy. Finiteness is the only structural luxury we ask for, and
it is a mild one: any system you actually simulate on a computer lives in a
finite state space.

On top of `S` we put two ingredients.

The first is a **rule of motion**, a function we'll call `step`. Given any state
`s`, the rule tells you the *next* state, `step s`. This is the deterministic
"let go of the marble and watch it move one tick" operation. Iterating it —
`step` applied again and again — traces out the trajectory of a state through
time.

The second ingredient is an **energy**, a function we'll call `energy`, that
assigns to each state a whole number — its height on the landscape. A higher
number means a higher, less stable perch; a lower number means closer to the
valley floor.

These two ingredients are tied together by a single, decisive promise, the
**strict descent law**:

> Whenever a state is not already at rest, taking a step *strictly lowers* its
> energy. In symbols: if `step s ≠ s`, then `energy (step s) < energy s`.

That's it. That one inequality is the entire engine of the theory. It says the
world cannot dawdle: as long as you are still moving, you are paying for it in
energy, and energy is a non-negative whole number, so you cannot pay forever. A
state that *has* stopped moving — one where `step s = s` — is called a **fixed
point**. Fixed points are the valleys, the resting places, the stored memories,
the trained models. Everything else is a marble still in motion.

We bundle these pieces — the finite space `S`, the rule `step`, the `energy`
function, and the strict descent law — into a single object called a
**DescentSystem**. It is a deliberately spare abstraction. It throws away
geometry, metric, smoothness, and dimension, and keeps only the bare bones of
"things move and energy decreases." The reward for this austerity is that the
theorems below apply to *every* such system at once: cellular automata, memory
networks, discretized gradient descent, combinatorial optimizers, and systems no
one has invented yet.

## The one idea that makes it all work

Here is the move that turns the strict descent law from a vague promise into a
hard guarantee. Suppose you start at a state `s` whose energy is, say, 7. Each
step you take while still moving knocks the energy down by *at least* one. Energy
can never go negative. So after at most **seven** steps you must have run out of
room to descend — which can only mean you've stopped moving. You've hit a fixed
point.

The number `energy s` is therefore a literal, hard ceiling on how long your
journey can last. This is the heart of the formal proof, captured in the lemma
**`step_iterate_isFix`**: applying the rule exactly `energy s` times to `s`
always lands on a fixed point. In symbols, `step^[energy s] s` is a fixed point,
no matter what `s` was. The proof is a single clean induction on the energy
budget: either you're already at rest, or you take a step, your energy strictly
drops, and a smaller budget suffices for the rest of the trip.

This gives us, for free, a way to fast-forward any state straight to its destiny.
Define the **limit map**:

> `limitPoint s := step^[energy s] s`

— "apply the rule `energy s` times and read off where you land." By the lemma we
just described, `limitPoint s` is always a fixed point. It is the valley that the
marble dropped at `s` eventually settles into. Two basic sanity checks confirm it
behaves the way a destination should:

- **`limitPoint_isFixedPt`**: every state flows to a genuine fixed point —
  `limitPoint s` is always at rest.
- **`limitPoint_eq_self`**: a state that is *already* a fixed point is its own
  destination — if `s` is at rest then `limitPoint s = s`. Valleys don't roll.

## Basins are just fibers — and that changes everything

Now comes the conceptual twist that makes the whole theory snap into focus.

A **basin** is the set of all starting states that share a single destination.
For a fixed point `t`, its basin is `{ s : limitPoint s = t }`. In the language of
functions, this is precisely a **fiber** of the limit map — the preimage of a
single output value. "Which marbles end up in valley `t`?" becomes "which inputs
does `limitPoint` send to `t`?"

That reframing is liberating because it converts a *dynamical* question — about
trajectories evolving over time — into a *static* question about a single
function and its image. Once you see basins as fibers, the structural facts
become almost self-evident:

- **`mem_basin_self`**: every fixed point lives in its own basin (it maps to
  itself), so no basin is empty.
- **`basin_disjoint`**: distinct fixed points have disjoint basins — a single
  starting point has exactly one destination, so it can't belong to two valleys
  at once.
- **`iUnion_basin_eq_univ`**: every state belongs to *some* basin, because every
  state has a destination. The basins cover the whole space.

Put together, these three say the basins form a **partition** of the entire state
space, indexed by the fixed points. The landscape really is cleanly carved into
watersheds, with no overlaps and no gaps.

And now the headline result drops out almost without effort. The key lemma is
**`range_limitPoint_eq_fixedPoints`**: the set of values that `limitPoint`
actually outputs is *exactly* the set of fixed points — no more, no less. Every
fixed point is achieved (it maps to itself), and nothing but a fixed point is
ever a destination. Since the non-empty fibers of a function are in one-to-one
correspondence with the values in its range, and here every fixed point gives a
non-empty fiber, we conclude:

> **The Basin Fixed Point Theorem (`basin_count_eq_fixedPoint_count`).** The
> number of basins of attraction equals the number of fixed points.

Count the valleys and you have counted the watersheds. The marble's-eye view and
the cartographer's view agree, exactly, forever.

## Why this is more than a tautology

It would be easy to mistake the theorem for a triviality — "of course there's one
basin per resting place." But the content is in the hypotheses, and the strict
descent law is doing real work. Drop it, and everything breaks.

Imagine a rule that, instead of always descending, sometimes cycles: state `A`
steps to `B`, and `B` steps back to `A`, with no energy lost. Now there is no
resting place in that loop at all, yet the two states clearly form a coherent
"basin-like" region. The clean count collapses, the limit map is no longer
well-defined, and the watershed picture dissolves into whirlpools. The strict
descent law is precisely the hypothesis that *outlaws whirlpools*. It guarantees
that motion always terminates, that destinies exist, and that they are fixed
points rather than orbits. The theorem is the payoff for ruling out exactly the
one pathology that would wreck the count.

## Two extensions that come almost for free

Because basins are fibers of a single map, two powerful generalizations follow
with surprisingly little extra work.

**Basin counts multiply.** Suppose you run two independent descent systems side
by side — system 1 on its own states, system 2 on its own, each ticking forward
without talking to the other. Together they form a **product system** on the
pairs of states. A pair is at rest exactly when *both* coordinates are at rest,
so the fixed points of the combined system are exactly the pairs of fixed points
of the parts. Counting them, the number of basins of the product is the product
of the numbers of basins (the lemma **`prod_fixedPoint_count`**). If system 1 has
3 valleys and system 2 has 4, the combined system has exactly 12. This
multiplicative law is the rigorous, classical shadow of a conjectured "quantum"
refinement in which one weights each basin by the lengths of the descent paths
that feed it — but even the plain version is a genuinely useful bookkeeping tool
for decomposable systems.

**Basin counts respect symmetry.** Suppose your system has a symmetry: a
relabeling of states that leaves the energy unchanged and commutes with the rule
of motion — do the symmetry then step, or step then symmetry, you get the same
answer. Then that symmetry permutes the fixed points among themselves
(**`isFix_equiv`**), and it intertwines cleanly with the limit map
(**`limitPoint_equivariant`**): the destination of a relabeled state is the
relabeled destination. In plain terms, **symmetric landscapes have symmetric
watersheds**. This is exactly the structure you need to count basins *up to*
symmetry — to ask how many "essentially different" valleys there are once you mod
out the relabelings — using classical orbit-counting tools. It is the doorway to
treating, for instance, the neuron-permutation symmetries of a neural network,
where vast numbers of "different" minima are really the same solution wearing
different name tags.

## Where the marble rolls next

The theory as proved lives in a deliberately discrete world: energy takes whole-
number values, and that discreteness is what guarantees descent terminates in a
bounded number of steps. The most natural frontier is to loosen this. Replace the
whole-number energy with a real-valued one and demand only that each genuine step
lowers energy by at least some fixed gap `δ`. The same counting argument survives,
with the step budget now bounded by the total energy drop divided by `δ`. Push
further into the truly continuous setting — gradient flow on a smooth loss
surface — and the discrete "no dawdling" law becomes the celebrated *Łojasiewicz
inequality*, which forces trajectories to have finite length and converge to a
single resting point rather than wandering forever. That is the bridge from this
crisp combinatorial theorem to the messy reality of training real neural networks.

Other frontiers beckon too. The basins, viewed as "descending cells," look
tantalizingly like the cells of *discrete Morse theory*, suggesting that the same
fiber bookkeeping that counts valleys could count higher-dimensional critical
features and recover topological invariants like Betti numbers and the Euler
characteristic. And the symmetry result is the first half of a Burnside-style
count of basins modulo a group of symmetries — a closed-form census of the truly
distinct destinations a symmetric optimizer can find.

## The moral

Strip a dynamical system down to its essentials — a finite world, a deterministic
rule, and an energy that genuinely falls whenever anything moves — and a single
inequality organizes everything. Motion terminates, destinies exist, every
starting point has exactly one of them, and the map from starting points to
destinies carves the world into a clean partition with precisely one piece per
resting place. Counting valleys *is* counting watersheds.

The deepest lesson is one of perspective. The hard-looking, time-dependent
question "where does each trajectory end up?" turns into the easy, static
question "what are the fibers of one map?" — and once you see it that way, the
multiplicativity and the symmetry both fall out like loose change. Sometimes the
whole art of a theorem is finding the angle from which it is obvious. Here, the
angle is this: **a basin is a fiber, and a valley is its name.**
