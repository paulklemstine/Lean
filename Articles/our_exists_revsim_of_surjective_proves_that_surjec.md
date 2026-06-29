# The Price of Forgetting: How Many Bits Does It Cost to Be Irreversible?

## A computer that never forgets

Imagine a machine that, no matter what it does, can always be run backwards.
Feed it any output and it will faithfully reconstruct the input that produced
it. Such a machine never *forgets* anything. At first this sounds like a
parlor trick, but it touches one of the deepest facts about computation:
**forgetting is not free.** Every time a computer discards information — every
time two different inputs are crushed down to the same output — a tiny,
unavoidable thermodynamic toll is paid, in heat, to the surrounding world.

This is not science fiction. It is a law of physics, first articulated by Rolf
Landauer in 1961 and made concrete by Charles Bennett in 1973: *logically
irreversible operations have a minimum energy cost*. Erase one bit of
information and you must dissipate at least `kT ln 2` joules of energy as heat,
where `k` is Boltzmann's constant and `T` is the temperature. The connection is
breathtaking. A statement about *abstract information* — whether a function can
be undone — becomes a statement about *physical energy*.

This article tells the story of a single, humble quantity that turns out to
govern this entire landscape: the **maximum fiber size** of a function. It is a
purely combinatorial number — you can compute it by counting — yet it
simultaneously controls how much extra memory a reversible machine needs, and
how much heat an irreversible machine must release. By the end, we will see
that three apparently different questions —

- *How much scratch memory must I add to make this computation reversible?*
- *Is this computation losing information?*
- *Does running this computation cost energy?*

— are, at bottom, **the same question**, and all three are answered by counting
fibers.

## What is a fiber, and why should you care?

Take any function `f` that maps a finite set of inputs to a finite set of
outputs. Pick an output value `b`. The set of all inputs that `f` sends to `b`
is called the **fiber over `b`** — written `f⁻¹(b)`. It is the complete list of
"suspects" that could have produced the output `b`.

If every fiber has exactly one element, then knowing the output tells you the
input uniquely: the function is **injective** (one-to-one), and nothing has been
lost. But if some fiber has two or more elements, the function has genuinely
*merged* distinct inputs. Looking only at the output, you can no longer tell
which input you started with. That ambiguity is precisely the information that
was destroyed.

The single most important number in this story is the size of the *largest*
fiber. Call it the **maximum fiber size**, `maxFiberSize f`:

> `maxFiberSize f` = the largest number of inputs that `f` ever maps to a single
> output.

A first, reassuring sanity check: the fibers tile the whole input set without
overlap. Each input lands in exactly one output's fiber, so if you add up the
sizes of all the fibers you recover the total number of inputs:

> **The Counting Identity.** For any function `f` from a finite set to a finite
> set, the sum over all outputs `b` of the fiber sizes `|f⁻¹(b)|` equals the
> total number of inputs `|α|`.

This is obvious once stated, but it is the bookkeeping backbone of everything
that follows.

## Bennett's escape hatch: never forget, and you can always go back

Here is the central tension. Most useful computations are *not* reversible. A
function that adds two numbers and reports only their sum has thrown away the
individual addends. A sorting routine that takes a shuffled deck and returns it
in order has erased *which* shuffle it started from. These are exactly the
operations with big fibers.

Bennett's beautiful insight was that you can *always* dodge irreversibility, at
a price. The trick is to **keep a receipt**. Instead of computing `f(a)` and
throwing `a` away, compute `f(a)` *and* record just enough extra data — a
"history" or "ancilla" — to recover `a`. Now the augmented operation is
reversible: from the pair `(output, receipt)` you can always reconstruct the
input.

How big must the receipt be? Bennett's construction says: the receipt over an
output `b` only needs to say *which member of the fiber `f⁻¹(b)`* the input was.
Formally, the entire computation becomes a perfect, reversible repackaging:

> **Bennett's Reversible Decomposition.** Every function `f` from a finite set
> can be turned into a bijection between the inputs and the pairs
> `(output b, an element of the fiber f⁻¹(b))`. The first half of each pair
> recovers `f`. No information is created or destroyed — the inputs are merely
> re-shelved.

This is the logical heart of reversible computing. It says reversibility is
always *achievable*; the only question is *how expensive* the receipt is.

## The receipt has an exact, unavoidable size

If you want a *uniform* receipt — one drawer of fixed size that works for every
output — how many slots must that drawer have? This is the question of the
**ancilla bound**, and it has a crisp, two-sided answer.

To make it precise, define a **reversible simulation** of `f` as an *injective*
encoding that turns each input `a` into a pair `(f(a), receipt)`, where the
receipts are drawn from some auxiliary set `Aux`. "Injective" is the whole
point: no two inputs share the same `(output, receipt)` pair, so the simulation
can always be reversed.

**The lower bound.** You cannot get away with a small drawer. If some output has
`k` inputs in its fiber, those `k` inputs all share the same output `f(a) = b`,
so the *only* thing distinguishing them is the receipt. With fewer than `k`
distinct receipts, two of those inputs would be forced to collide — and the
encoding would no longer be reversible. So the receipt drawer needs at least
`maxFiberSize f` slots:

> **Lower bound.** Every reversible simulation of `f` requires an ancilla set of
> size at least `maxFiberSize f`.

**The upper bound.** And you never need more. By labelling the elements within
each fiber `0, 1, 2, …` and reusing those labels across all fibers, the largest
fiber sets the size of the drawer, and every input gets a unique
`(output, label)` pair:

> **Upper bound.** There is a reversible simulation of `f` whose ancilla set is
> exactly `{0, 1, …, maxFiberSize f − 1}`.

Put the two halves together and you get an exact law, with no slack:

> **The Tight Ancilla Theorem.** The minimum ancilla size needed to make `f`
> reversible is *exactly* `maxFiberSize f`. One fewer slot is provably
> impossible the moment `f` has any fiber with more than one element.

This is the kind of result mathematicians love: a quantity defined by pure
counting (`maxFiberSize`) turns out to be the precise, optimal answer to an
operational question (how much memory reversibility costs). There is no clever
trick that beats it, and no waste in achieving it.

A pleasant special case falls right out. When is *one* receipt slot enough? Only
when no fiber ever holds two inputs — that is, only when `f` is injective:

> **One slot ⇔ injective.** `maxFiberSize f ≤ 1` if and only if `f` is
> one-to-one. Injective computations are exactly the ones that are "almost
> already reversible."

## From bits to heat: the strict price of forgetting

So far the story is combinatorial. Now physics enters. Information has a natural
currency: **bits**. The information content of an input drawn uniformly from a
set of size `N` is `log₂ N` bits. When a function `f` squashes its `|α|` inputs
down to only `|image(f)|` distinct outputs, the number of bits it destroys is
the difference:

> **Information erased** by `f` = `log₂|α| − log₂|image(f)|` bits.

This quantity is never negative — you cannot erase a negative amount of
information — because the image can never be bigger than the domain. Multiply it
by Landauer's constant `kT ln 2` and you get the **Landauer gap**: the minimum
thermodynamic work an irreversible implementation must dissipate that a
reversible one avoids.

> **Landauer's bound (non-strict form).** At any positive temperature, the
> Landauer gap of any function is greater than or equal to zero. Irreversible
> computation never costs *less* than reversible computation.

That inequality is comforting, but the truly satisfying result is the *strict*
version — the one that tells you exactly when the cost is positive rather than
merely "at least zero." Here the fiber picture pays off again. A function erases
a *positive* amount of information precisely when its image is strictly smaller
than its domain, which happens precisely when two inputs collide, which is
precisely the failure of injectivity:

> **Strict information erasure.** The information erased by `f` is strictly
> positive *if and only if* `f` is not injective.

And so the energy bill becomes strict, too:

> **The Strict Landauer Theorem.** At any positive temperature, every
> non-injective computation has a *strictly positive* Landauer gap.
> Irreversibility is never free — it always costs real, quantifiable energy.

The proof is a chain of equivalences worth savoring. Non-injectivity means two
inputs collide, which means the image set is strictly smaller than the domain,
which (because `log₂` is strictly increasing) means a strictly positive number
of erased bits, which (because temperature is positive) means a strictly
positive energy cost. Each link is elementary; together they forge an iron law.

## The grand unification: one number, four faces

Now stand back and look at what `maxFiberSize` has done. The following four
statements about a finite function `f` are all equivalent:

1. **`f` needs more than one ancilla slot** to be made reversible.
2. **`f` is not injective** — it merges distinct inputs.
3. **`f` erases a positive amount of information.**
4. **`f` has a strictly positive Landauer gap** — it costs energy to run.

Combinatorics (slot 1), set theory (slot 2), information theory (slot 3), and
thermodynamics (slot 4) all turn out to be reading the *same dial*. The needle
on that dial is the maximum fiber size. When it sits at 1, the function is
reversible, lossless, and free. The moment it climbs to 2, all four costs switch
on together.

## Sorting: a worked example you already understand

Consider the most relatable irreversible computation imaginable: **sorting**.
Hand a sorting machine a shuffled list of `n` distinct items and it returns them
in order. There are `n!` (n-factorial) possible shuffles, and they *all* map to
the same sorted output. So the sorting "function" has a single, enormous fiber
of size `n!`.

Run the theory on this example and the numbers tumble out:

- **Ancilla cost.** Because the largest (indeed only) fiber has size `n!`, any
  reversible sorter must carry an ancilla of at least `n!` states — enough to
  remember *which* of the `n!` permutations it undid. This is exactly the
  receipt that lets you "unsort."
- **Information erased.** The information destroyed by sorting `n` items is
  exactly `log₂(n!)` bits. For a modest deck of `n = 13` cards that is already
  about `32.5` bits — over four bytes of information annihilated by a single
  sort.
- **Energy.** Multiply by `kT ln 2` and you get the irreducible heat that an
  irreversible sort must release. At room temperature this is minuscule per
  operation, but it is *strictly positive*, and it scales with `log₂(n!)`, which
  by Stirling's approximation grows like `n log₂ n` — the very same quantity
  that appears in the classic comparison-sorting lower bound. The information
  theory of sorting and the thermodynamics of sorting are telling the same
  story.

## Why reversibility composes

One last elegant fact rounds out the picture. Suppose you make `f` reversible
with a receipt of one kind, and `g` reversible with a receipt of another. Can
you make the *composition* `g ∘ f` reversible? Yes — and you simply staple the
two receipts together. The combined ancilla is the *product* of the two
ancillas, so its size multiplies:

> **Reversibility composes.** If `f` is made reversible with ancilla `A` and `g`
> with ancilla `B`, then `g ∘ f` is reversible with ancilla `A × B`, whose size
> is `|A| · |B|`.

This is exactly how Bennett imagined building large reversible programs out of
small reversible pieces: each step keeps its own receipt, and the receipts pile
up multiplicatively. It is also why uncomputation — Bennett's famous trick of
running a sub-computation, copying its answer, and then running it *backwards*
to erase the receipt — is so important in practice and in quantum computing,
where every gate must be reversible by the laws of quantum mechanics.

## The takeaway

We began with a fanciful machine that never forgets and ended with a precise
accounting of the cost of forgetting. The bridge between them is a single
counting invariant — the maximum fiber size of a function — which turns out to
be simultaneously:

- the **exact** amount of scratch memory reversibility demands,
- the **signature** of whether information is being destroyed, and
- the **switch** that turns the thermodynamic energy bill from zero to strictly
  positive.

Forgetting, it turns out, is a measurable act. Every collapsed pair of inputs
leaves a permanent mark: a slot you must add to go back, a bit you can never
recover, and a whisper of heat released into the universe. The mathematics does
not merely assert that these costs exist — it pins them down *exactly*, and
shows they are all the same cost wearing different clothes. That is the quiet
beauty of reversible computing: it reveals that information, memory, and energy
were never really separate ledgers. They were always one.
