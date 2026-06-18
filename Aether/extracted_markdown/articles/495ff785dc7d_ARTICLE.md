# The Machine That Rewrites Itself — and Why Finiteness Tames It

Imagine a program that edits its own source code while it runs. Each step it
takes might rewrite the very instructions it will execute next. This is not
science fiction: just-in-time compilers patch themselves on the fly,
genetic-programming systems mutate their own routines, polymorphic malware
shuffles its code to evade detection, and a learning agent that updates its own
policy is, in a precise sense, modifying the program that governs its behaviour.

Self-modification has a fearsome reputation. The folk intuition runs: if a
program can change *what it does*, then surely predicting *whether it stops*, or
*whether it ever misbehaves*, must be even harder than for an ordinary program.
The truth turns out to be more subtle and far more beautiful. On unbounded
memory, self-modification adds no new undecidability — it is exactly as hard as
the classical halting problem, no harder. And on **finite** memory, something
remarkable happens: the machine becomes a discrete dynamical system, and the
oldest tool in the dynamicist's kit — the pigeonhole principle — tames it
completely.

This article tells the story of that taming. We will meet three facts, two of
them in apparent tension, and we will see exactly where the genuine difficulty
of controlling a self-modifying agent actually lives. The punchline, stated up
front: the hard part is **not** how complex each step is. The hard part is the
*reachability relation* — which configurations can flow into which.

## A machine that carries its own program as data

Let us be concrete about the model. A *self-modifying machine* has two kinds of
memory: a **program** `p` drawn from a set `P`, and a **state** `s` drawn from a
set `S`. One step of computation is a function

> `step : P → S → Option (P × S)`

Read that carefully. Given the current program `p` and current state `s`, the
machine produces *either* nothing (`none`, meaning "halt") *or* a brand-new pair
`(p', s')`. The crucial point is that the output contains a *new program* `p'`.
The machine has rewritten itself. The next step will run `step p' s'`, using the
edited program.

A *configuration* is just a pair `(p, s)`, and "running for `n` steps" means
applying `step` `n` times, stopping early if it ever returns `none`. The machine
**halts** from a configuration if some finite number of steps returns `none`.

The foundational result behind all of this — proved in the companion
development — is a *simulation theorem*. Define the **standard simulation** as
the fixed-program machine over the product space `P × S` whose step is

> `(p, s) ↦ step p s`

This machine never changes its "program" in any visible way; it simply treats
the pair `(p, s)` as one big state. The simulation theorem says:

> **Behavioural equivalence.** The self-modifying machine halts from `(p, s)`
> if and only if its standard simulation halts from the same pair.

In other words, *self-modification is an illusion of bookkeeping*. A machine
that rewrites its program is, behaviourally, just an ordinary machine whose
state happens to include a copy of the program. Encode the program as data and
the self-modification disappears. This is why the halting problem for
self-modifying machines is Turing-equivalent to the classical one — neither
easier nor harder.

That settles *behaviour*. The new chapter — the subject of this article — is
about **dynamics**. What does the *orbit* of a configuration look like as the
machine grinds forward forever?

## From behaviour to dynamics: the machine as a self-map

Suppose the machine never halts — call it **total** — so that `step` always
returns `some (p', s')`. Then on the configuration space `P × S` we have a
genuine function with no escape hatch:

> `dyn : P × S → P × S`,  `dyn (p, s) = the new pair produced by step`.

Running the machine is now nothing more than *iterating* `dyn`. The bridge lemma
makes this exact:

> **Run equals iterate.** For a total machine, running for `n` steps from a
> configuration is the same as applying `dyn` to it `n` times: `run = dyn^[n]`.

This single sentence collapses two worlds. Every fact about the machine's
long-run behaviour becomes a fact about iterating a function — and the theory of
iterating a function on a *finite* set is centuries old and razor sharp.

## The one idea that generates everything: a collision

Here is the engine. Suppose the configuration space `P × S` is finite, with
exactly `N` elements. Look at the orbit of a starting point `x`:

> `x,  dyn(x),  dyn(dyn(x)),  …,  dyn^[N](x).`

That is `N + 1` configurations. But there are only `N` distinct configurations
in the whole universe. By the **pigeonhole principle**, two of them must
coincide. Formally:

> **Iterate collision.** For any self-map `f` of a finite set with `N` elements
> and any starting point `x`, there exist indices `i < j ≤ N` with
> `f^[i](x) = f^[j](x)`.

That is the *entire* mathematical seed. Every structural fact below grows from
this single collision. It is worth pausing on how little we assumed: nothing
about what the machine computes, nothing about the complexity of a single step —
only that the memory is finite. Let us harvest the consequences.

### Consequence 1 — Finiteness makes prediction trivial

Once two iterates collide at `i < j`, the orbit becomes periodic from index `i`
onward, with period `p = j - i`. Concretely, applying `dyn` another `p` times to
`f^[i](x)` returns you exactly to `f^[i](x)`. From this we get two clean
statements.

> **Eventual periodicity.** Every point of a finite self-map reaches, within
> `N` steps, a point that is periodic with some positive period at most `N`.
> Formally: there exist `k ≤ N` and `0 < p ≤ N` with
> `f^[p](f^[k](x)) = f^[k](x)`.

> **Orbit confinement.** Every single iterate `f^[n](x)`, no matter how
> astronomically large `n` is, already equals one of the first `N + 1` iterates.
> Formally: for every `n` there is some `k ≤ N` with `f^[n](x) = f^[k](x)`.

Think about what orbit confinement buys you. Suppose you want to know whether a
total machine *ever* enters some "bad" region `R` of configurations — a region
you have flagged as unsafe, off-spec, or undesirable. Naively this is an
infinite-horizon question: you would have to check `step` `0`, after step `1`,
after step `2`, ... forever. But orbit confinement says the entire future orbit
is contained in the first `N + 1` configurations. So:

> **Bounded search.** A total machine on a finite space *ever* reaches the bad
> region if and only if it reaches it within the first `N` steps.

An infinite question collapses to a finite one. On bounded memory,
self-modification adds **no analytic difficulty whatsoever**. You simulate `N`
steps and you have your answer. This is a sharp counterpoint to the unbounded
case, where the very same question is undecidable. The lesson: undecidability is
a phenomenon of *infinite* memory, not of self-modification per se.

### Consequence 2 — Finiteness forces self-reproduction

The same collision has a poetic reading. A configuration that the machine
returns to is a configuration that *reproduces itself* over the course of a
cycle. A program that, after some steps of self-editing, restores exactly its
own earlier program-and-state — that is a **quine**, a self-reproducing
fixed point, in the dynamical sense.

> **Quine cycle.** A total self-modifying machine on a finite configuration
> space re-enters a previously visited configuration within `N` steps, and then
> runs forever, cycling through that configuration again and again.

This is a finitary cousin of Kleene's recursion theorem — the classical result
guaranteeing self-referential programs. Here, no clever construction is needed:
on finite memory, self-reproduction is not a possibility to be engineered, it is
an *inevitability*. A machine that never halts and never repeats would need
infinitely many distinct configurations, and a finite world simply does not
contain them. Every immortal finite self-modifier is, eventually, a quine.

### Consequence 3 — Where control actually fails: reachability

Now the twist. We have just seen that on finite memory, *predicting* a
self-modifier is easy — bounded search settles everything. So is *controlling*
one equally easy? Can we build a monitor that keeps the machine forever inside a
"safe" region, never touching a bad configuration?

This is the alignment question, in miniature. And here finiteness offers no
comfort. To state the obstruction we need two notions:

- A self-map is **strongly connected** if every configuration can reach every
  other: for all `x, y` there is some `n` with `f^[n](x) = y`. (Think of a
  machine whose self-edits are rich enough that, from anywhere, it could in
  principle wander to anywhere.)
- A region `R` is **forward-invariant** if the dynamics never leaves it: if
  `x ∈ R` then `dyn(x) ∈ R`. A forward-invariant safe region is exactly what a
  state-based monitor would need — a set of configurations the agent provably
  cannot escape.

The key structural lemma is almost shocking in its strength:

> **Invariant sets are all-or-nothing.** Under strong connectivity, the *only*
> nonempty forward-invariant set is the entire space. There is no nontrivial
> trap, no proper safe harbour.

Why? Pick any nonempty forward-invariant `R` and any point `x` inside it.
Strong connectivity lets `x` reach *every* configuration `y`; forward invariance
guarantees the whole orbit of `x` stays inside `R`; so every `y` is in `R`.
Hence `R` is everything. From this, the alignment obstruction follows
immediately:

> **Alignment obstruction.** If a self-modifying machine is strongly connected
> and even a *single* configuration is bad, then there is **no** nonempty
> forward-invariant region of exclusively safe states. Consequently, from every
> starting configuration the machine reaches a bad state.

One rotten apple spoils the entire barrel. A solitary misaligned configuration,
combined with rich enough reachability, makes *every* trajectory eventually
unsafe. No state-based monitor — no rule that inspects the current
configuration and decides whether to allow it — can confine the agent to safety,
because the only region it could confine the agent to is the whole space,
bad state and all.

Look at what is doing the work here. It is **not** the complexity of the step
function. It is **not** how many bits the program has. It is purely the
*reachability relation*: who can flow into whom. Predictability and
controllability come apart. Finiteness makes the first trivial and leaves the
second hostage to connectivity.

## The real moral

Put the three consequences side by side and a clean picture emerges:

1. **Predicting** a finite self-modifier is easy — orbit confinement turns every
   infinite-horizon question into a bounded search of length `N`.
2. **Self-reproduction** is not a feat but a fate — every immortal finite
   self-modifier must cycle, hence quine, within `N` steps.
3. **Controlling** a finite self-modifier can be impossible — strong
   connectivity plus one bad state forbids any nontrivial safe region.

The difficulty of alignment, then, does not live in the step map. You can make
each individual edit as simple as you like; you can make the program tiny. What
matters is the *shape of the reachability graph*. If the agent's self-edits can
carry it from anywhere to anywhere, and even one destination is unsafe, then
safety is structurally impossible — not because we lack a clever monitor, but
because no monitor of the right kind can exist.

This reframes a worry that often gets attached to self-modifying systems. The
fear is usually phrased in terms of *power*: "a machine that rewrites itself
could become unpredictably complex." The mathematics says: on finite memory,
unpredictability is not the issue — everything repeats, everything is
foreseeable in `N` steps. The issue is *connectivity*. The right engineering
question is not "how do I bound the machine's cleverness?" but "how do I shape
its reachability graph so that the unsafe region is genuinely walled off — so
that there *exists* a nontrivial forward-invariant safe region in the first
place?"

That is a question about the *topology of self-modification*, and it is the
frontier these results open. We now know precisely what to design for: not
simpler steps, but **disconnected reachability** — orbits that physically cannot
flow into the bad set. The pigeonhole principle, four hundred years old, has
handed us both the good news and the bad news about machines that rewrite
themselves, and told us exactly which knob to turn.

## A worked miniature

To make all of this tangible, picture the smallest interesting case: a machine
whose configuration space has just six states arranged in a single directed
cycle, `c₀ → c₁ → c₂ → c₃ → c₄ → c₅ → c₀`. This `dyn` is total (every state has
a successor) and strongly connected (following arrows long enough takes you from
any state to any other). Iterate collision predicts a repeat within six steps —
and indeed, starting at `c₀`, the seventh configuration `dyn^[6](c₀)` is `c₀`
again: a quine cycle of period six. Orbit confinement predicts every future
configuration is among the first seven — and of course it is, since there are
only six. Now flag `c₃` as bad. Strong connectivity means every state reaches
`c₃`, so no safe region can be forward-invariant: the alignment obstruction
bites. The only way to rescue safety is to *cut an arrow* — to break the cycle
so that the states upstream of `c₃` can no longer reach it. That single edit to
the reachability graph, not any change to the per-step logic, is what restores
the possibility of control. In one tiny picture you can see the whole theory:
prediction is trivial, reproduction is forced, and safety lives or dies on the
arrows.
