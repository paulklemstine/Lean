# The Shadow Spectrum: How "Min and Max" Arithmetic Grows Its Own Langlands Correspondence

## A bridge built from the simplest arithmetic imaginable

There is a quiet revolution in modern mathematics whose name sounds intimidating
but whose central idea is almost childishly simple. It is called **tropical
mathematics**, and its founding move is to throw away the two operations you have
relied on your whole life — ordinary addition and multiplication — and replace
them with two even simpler ones.

In the tropical world, "adding" two numbers means *taking the larger* (or, in some
dialects, the smaller). "Multiplying" them means *adding* them the ordinary way.
That is the whole of it. The plus sign becomes `max`, the times sign becomes `+`.

This sounds like a party trick, but it has teeth. Curves become piecewise-linear
graphs you could draw with a ruler. Hard optimization problems — scheduling trains,
routing packets, balancing assembly lines — turn into *linear* algebra over this
strange new arithmetic. And, crucially for our story, the deep machinery of
representation theory begins to cast a long, sharp shadow into this combinatorial
land.

This article is about one such shadow: a **tropical spectral Langlands
correspondence**. The Langlands program, in its full glory, is one of the grandest
edifices in mathematics — a web of conjectured bridges connecting number theory,
geometry, and the symmetries of analytic objects. We are not going to climb that
mountain here. Instead, we are going to show that one of its core *patterns* — the
idea that the building blocks of a symmetry can be faithfully recorded by the
*measurements* they admit — survives intact when you strip the arithmetic down to
`max` and `+`. And we will do it with complete, machine-checked rigor.

## The cast of characters

Let me introduce the players, using nothing more than everyday language.

**A lattice.** Picture a collection of "states" with a notion of one state being
"contained in" or "below" another. The classic example is the family of all subsets
of a fixed set, ordered by inclusion. Any two states have a *least upper bound* (the
smallest state containing both — for subsets, this is their union) and the whole
thing has a *top* (everything) and a *bottom* (nothing). This is the natural home of
tropical linear algebra: the role played by vector spaces in ordinary algebra is
played by these ordered lattices in the tropical world.

**An action.** Now imagine an external system of symmetries — call it `H` — that
acts on our lattice. Each symmetry `h` is a rule `act_h` that takes a state and
moves it to another state, never violating the ordering: if state `x` was below
state `y`, then `act_h(x)` stays below `act_h(y)`. This is a *monotone* action, the
tropical stand-in for a representation of a group.

**The residual — backward inference.** Here is the first genuinely beautiful idea.
A monotone forward map `act_h` that respects the order well enough comes with a
companion running in the opposite direction, called its **residual** `res_h`. If you
think of `act_h` as "applying a constraint," then `res_h` is the *best possible
backward guess*: given an output, `res_h` returns the largest input that could have
produced something below it. The pair `(act_h, res_h)` is locked together by a
relationship mathematicians call a **Galois connection**:

> `act_h(x)` is below `y`  **exactly when**  `x` is below `res_h(y)`.

This single equivalence is the engine of everything that follows. It is the tropical
echo of the adjoint pair `(g, g^{-1})` from ordinary representation theory — except
here we never need inverses, only the order.

## Closure: where states come to rest

Compose the forward map with its backward companion and something magical happens.
Define

> `cl_h(x) = res_h(act_h(x))`.

You first apply the symmetry, then make the best backward inference. The result,
`cl_h`, is a **closure operator** — one of the most robust and well-behaved objects
in all of order theory. Three properties hold automatically, no matter how
complicated the action:

1. **It never decreases.** Every state sits below its own closure: `x ≤ cl_h(x)`.
   Applying the symmetry and inferring back can only enlarge your state.
2. **It is monotone.** Bigger states have bigger closures.
3. **It is idempotent.** Closing twice is the same as closing once:
   `cl_h(cl_h(x)) = cl_h(x)`. After one application, the state has reached
   equilibrium.

A state that is already at equilibrium — one satisfying `cl_h(x) = x` — is called
**closed**. These closed states are the "stable configurations" of the symmetry,
the points that the action cannot push any further. They are the heart of the
spectrum.

We proved, with full rigor, that these properties are not lucky accidents of a
particular example but flow inevitably from the Galois connection. We also proved a
reassuring fact about finiteness: on any finite, non-empty lattice, **at least one
closed state always exists**. The closure of *any* starting point is already closed
(by idempotence), so equilibria can never be empty. The spectrum is never a void.

## The tropical character: the largest stable state

Among all closed states there is a champion. Apply the closure operator to the very
top of the lattice — the state "everything" — and you obtain what we call the
**tropical character** at `h`:

> `χ(h) = cl_h(⊤)`.

We proved two clean facts about it. First, the tropical character **is itself
closed** — it is a genuine equilibrium, not a way-station. Second, and more
strikingly, it is the **largest closed state of all**: every closed state `x`
satisfies `x ≤ χ(h)`. So the character is not just *a* stable configuration; it is
the *maximal* one, the ceiling of the entire spectrum. In ordinary representation
theory the character of a representation is the trace that encodes all its essential
data in a single function. Here, in the world of `max` and `+`, the role of "the
single object that crowns the spectrum" is played by `cl_h(⊤)`.

## The main act: counting the building blocks by their measurements

Now we arrive at the centerpiece — the tropical correspondence itself.

In representation theory, a complicated symmetry decomposes into **simple pieces**,
the irreducible atoms from which everything else is assembled. Our tropical analogue
is the **simple summand**: a state `s` that is

- **non-trivial** (not the empty bottom state),
- **stable under every symmetry** (closed for all `h`), and
- **detectable** — what we call *closure-prime*: if the summand lies below the
  closure of some state `x`, then it already lay below `x` itself. The summand
  cannot be conjured into existence by the closure process; if you can see it after
  closing, it was there all along.

These are the irreducible eigenlines of the tropical action.

On the other side of the bridge live the **closure eigenmeasures**: the legitimate
*measurements* one can make on the system. An eigenmeasure is a function `μ`
assigning to each state a value (in our setting, either an integer or "minus
infinity"), subject to three rules:

1. **Monotone:** bigger states never measure smaller.
2. **Normalized:** the empty bottom state measures `−∞`.
3. **Closure-blind:** a state and its closure always get the same measurement,
   `μ(cl_h(x)) = μ(x)`. The measurement cannot tell a state apart from its
   equilibrium — it sees only spectral content.

Now here is the construction at the soul of the paper. To each simple summand `s` we
attach the simplest conceivable measurement — its **indicator**:

> `μ_s(x) = 0`  if the summand `s` lies below `x`,  and  `μ_s(x) = −∞`  otherwise.

It is a yes/no probe: "Is the atom `s` present in state `x`?" We proved that this
naive probe is in fact a *bona fide* closure eigenmeasure: it is monotone, it sends
bottom to `−∞`, and — the subtle part — it is closure-blind. The closure-blindness
is exactly where the *closure-prime* property of the summand earns its keep:
detecting `s` after closing is the same as detecting it before, precisely because
`s` cannot be summoned by closure.

This gives a map: **every simple summand produces an eigenmeasure**. And then the
main theorem:

> **Spectral Correspondence (the tropical Satake map).** The assignment sending each
> simple summand to its indicator eigenmeasure is *injective*: distinct summands
> always produce distinct measurements.

In plain words: **no two of the irreducible building blocks leave the same
fingerprint.** The atoms of the symmetry are completely and faithfully recorded by
the measurements they admit. You can recover the pieces from the probes. This is the
defining feature of a Langlands-type correspondence — a faithful dictionary between
"objects" (the summands) and "spectral data" (the measurements) — and we have
established it in the tropical setting from first principles.

The proof is a small gem. Suppose two summands `s₁` and `s₂` yield the *same*
indicator. Evaluate that common measurement at the states `s₁` and `s₂` themselves.
Since each summand obviously lies below itself, each probe returns `0` there; feeding
this back through the equality of the two indicators forces `s₁` to lie below `s₂`
and `s₂` to lie below `s₁` simultaneously. In an ordered world that pincer leaves
only one possibility: `s₁ = s₂`. The fingerprints coincide only when the atoms do.

## Watching it work on the smallest possible stage

Abstraction is only convincing when it touches down. The simplest non-trivial
lattice is the two-element set of truth values, `{false, true}`, with `false` below
`true`. We examined two actions on it.

The **identity action** does nothing — it leaves every state where it is. Its
closure operator is the identity, so *both* states are closed. Its spectral size —
the count of closed states — is therefore exactly **2**. We verified this by direct
computation inside the formal system.

The **constant-false action** crushes everything to `false`, with backward inference
sending everything to `true`. Now only the top state `true` survives as an
equilibrium; `false` is no longer stable. Its spectral size is exactly **1** — again
machine-verified. Two different symmetries, two different spectral sizes, both read
off cleanly by counting closed states.

These miniatures are not decoration. They are the seeds of a classification result
we also proved: two tropical actions register the *same spectral size* at a symmetry
`h` precisely when they have the *same number of closed states*. The spectrum's
coarsest invariant is simply a count of equilibria, and that count is an honest
fingerprint of the action.

## Why this matters beyond the curiosity

Why should anyone outside the seminar room care that `max`-and-`+` arithmetic grows
its own Langlands shadow?

Because **the tropical world is where computation lives.** Galois connections,
closure operators, and lattices of states are the daily bread of program analysis,
database theory, scheduling, and formal verification. Every time a compiler proves
your code safe, every time a logistics engine balances a network, every time a
constraint solver propagates information forward and infers backward, the same
forward-map/residual machinery we used here is silently at work. What our results
say is that this machinery carries genuine *spectral* structure — that the stable
configurations of a constrained system organize themselves into atoms, and that
those atoms are perfectly recoverable from the measurements the system permits.

There is also a deeper aesthetic point. The Langlands program teaches that the same
melody — "objects are determined by their spectra" — is played in radically
different mathematical keys. To find that the melody survives even in the austere,
inverse-free, `max`-and-`+` key is evidence that it is not an artifact of any one
arithmetic but something closer to a law of structure itself. The bridge stands even
when you remove subtraction, even when you remove multiplication, even when "adding"
just means "choosing the bigger." That robustness is the real news.

## The view from here

We have, then, a small but complete world: a finite lattice, a residuated action, a
spectrum of closure operators, a crowning tropical character, irreducible summands,
and a faithful map from those summands to the measurements that detect them — all
established with the certainty of formal proof. From the two-element truth lattice to
the general finite case, the same architecture holds.

The natural next horizons are clear. One wants a *surjectivity* companion to the
injection — a sense in which *every* well-behaved eigenmeasure comes from a summand,
completing the dictionary into a perfect bijection. One wants to let the symmetries
`H` carry their own multiplication and watch the character become genuinely
multiplicative. And one wants to push from the toy lattices into the rich tropical
geometry of polytopes and matroids, where the closure operators acquire vivid
geometric meaning.

But the foundation is laid, and it is solid. In the leanest arithmetic we have,
where addition is choice and multiplication is addition, the great pattern of modern
mathematics — *that the building blocks of a symmetry are faithfully recorded by the
measurements they admit* — holds true, and we can prove it.
