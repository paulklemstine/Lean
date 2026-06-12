# When You Prove Something Matters: A Logic for Proofs That Happen in Time

## The timeless lie at the heart of mathematics

There is a quiet fiction that mathematicians tell themselves, and it is so
convenient that we almost never notice it. The fiction is this: that a theorem,
once true, was always true and will always be true, and that the act of *proving*
it adds nothing to the world except our private knowledge of it. The Pythagorean
theorem, we say, was true before Pythagoras, true before there were triangles to
measure, true before there was anyone to care. Proof, on this view, is a kind of
flashlight. It illuminates a landscape that was already there.

For most purposes this fiction is harmless and even beautiful. But it hides
something real. Proofs are not eternal facts; they are *events*. They happen at a
particular time, in a particular order, built on top of earlier proofs the way a
city is built on top of its old foundations. Andrew Wiles did not prove Fermat's
Last Theorem in 1637; he proved it in 1994, and the proof leaned on machinery —
elliptic curves, modular forms, Galois representations — that simply did not exist
in Fermat's century. The *truth* may be timeless. The *proof* is a thing that
came into being on a Tuesday.

Once you take that seriously, a strange new set of questions opens up. If proofs
happen in time, then "provable" is not a fixed property of a statement; it is a
property that a statement *acquires*, at some moment, and keeps thereafter. We can
ask: is this provable *yet*? Will it be provable *later*? If I can prove it today,
does that guarantee I will still be able to prove it tomorrow? And here is the one
that sounds like a riddle but turns out to have a precise answer: could a statement
be provable *tomorrow but not today* — and could one be provable *today but not
tomorrow*?

This article is about a logic built to answer exactly those questions. We call it
**Temporal Gödel–Löb logic**, or **TGL**. It is what you get when you take the
classical logic of provability and add a clock.

## The logic of provability, before the clock

To see what TGL adds, you first have to meet what it extends.

In the 1930s Kurt Gödel discovered that any sufficiently powerful, consistent
mathematical system — Peano Arithmetic, say, the standard theory of the whole
numbers — cannot prove its own consistency. This is his celebrated **second
incompleteness theorem**, and it is one of the great intellectual shocks of the
twentieth century. Arithmetic can talk about itself: it can encode statements like
"there exists a proof of `0 = 1`," and it can reason about those statements. But the
one thing it cannot do is certify that it will never prove a falsehood.

Over the following decades logicians distilled the *behavior* of the phrase "it is
provable that…" into a compact modal logic. They wrote `□A` ("box A") for "A is
provable," and they asked: what are the laws this box obeys? Three turned out to be
fundamental.

- **Distribution (K):** if you can prove an implication and you can prove its
  premise, you can prove its conclusion. Provability respects logical steps.
- **Transitivity (the "4" axiom):** `□A → □□A`. If A is provable, then it is
  provable *that* A is provable. A proof can be inspected and re-certified from the
  inside.
- **Löb's axiom:** `□(□A → A) → □A`. This is the deep one, and it is the engine of
  the whole subject. Read it slowly: "if it is provable that 'A's provability would
  guarantee A,' then A is already provable." Löb's axiom is what makes the logic
  *not* trivially reflexive. It says, in effect, that the system cannot wishfully
  bootstrap itself into believing things just because believing them would make them
  true.

The modal logic with exactly these laws is called **GL**, for Gödel and the
logician Martin Löb. Its triumph is a result by Robert Solovay: GL is *arithmetically
complete*. The modal theorems of GL are precisely the schemes that Peano Arithmetic
can prove about its own provability predicate, no matter how you fill in the
sentence-variables. GL is, in a strong sense, **the** logic of mathematical
provability.

But GL has no clock. In GL, `□A` means "A is provable, full stop," with no when.
Solovay's universe is timeless. And that is exactly the fiction we set out to break.

## Adding a clock: two relations, two kinds of "necessity"

The right way to model provability-in-time is with a picture logicians call a
*frame*: a collection of "worlds," together with relations that say how the worlds
are connected. In TGL each world is a *stage of mathematical knowledge* — a snapshot
of what has been established. And there are **two** relations connecting these stages.

The first relation, written `R`, is the old provability relation from GL. Think of
`R w v` as saying "v is a world that w cannot rule out" — a possible counterexample,
a way things could go that w has not yet closed off. To prove A at w means to close
off every such escape route: A holds at every world `R` leads to. This is the
classical box, defined exactly as

> **`Box R A w` :** A holds at every `R`-successor of `w`, i.e. `∀ v, R w v → A v`.

`R` carries two structural demands inherited from GL. It is **transitive** (a
successor of a successor is a successor — this is what makes the "4" axiom work),
and it is **converse well-founded** (you cannot have an infinite ascending chain of
ever-deeper counterexamples). That second property is the secret heart of Löb's
axiom and, ultimately, of Gödel's theorem. It is the formal way of saying *proofs
are finite; they bottom out.*

The second relation, written `T`, is brand new. It is **time**. `T w w'` means "w'
is now-or-later than w." Time is **reflexive** (every moment is now-or-later than
itself) and **transitive** (later-than-later is later), making it a *preorder* — the
mathematician's minimal model of a flow of time. Along `T` we get two new operators,
the standard ones from temporal logic:

> **`Glob T A w`** ("globally," written `G A`): A holds at *all* future times,
> `∀ v, T w v → A v`.
>
> **`Fut T A w`** ("eventually," written `◇A`): A holds at *some* future time,
> `∃ v, T w v ∧ A v`.

So now we have two flavors of necessity living on the same worlds: `□` looks along
proof-structure, `G` looks along time, and `◇` is the temporal "someday." The
question is how they interact — and the single most important law governing that
interaction is a compatibility condition we call **monotonicity in time**.

## The one law that makes it all hang together

Here is the principle, and it is almost embarrassingly intuitive once you say it
out loud: **you never lose a proof.** Knowledge accumulates. If something is settled
today, it stays settled tomorrow.

In the language of the two relations, this becomes a precise geometric statement
about how `T` and `R` fit together, which we call `compat`:

> **Time-monotonicity (`compat`):** if `T w w'` (w' is in w's future) and `R w' v`
> (v is a live counterexample at the future stage w'), then `R w v` (v was already a
> live counterexample now).

Read the contrapositive and it sings: any escape route you have *closed off* by
now stays closed off forever. The set of counterexamples only shrinks as time goes
on. And since proving A means closing off all the counterexamples to A, that means:
**provability only grows.** A frame carrying all of this structure — the GL relation
`R`, the time preorder `T`, and the bridge `compat` between them — is what we call a
**temporal GL frame**.

From this single picture, a cascade of results follows. Let me walk you through the
ones that matter, in plain words, with their exact statements.

## What survives, what's new, and what's impossible

**The old laws still hold.** First, the reassuring news: adding a clock breaks
none of the classical machinery. On every temporal GL frame:

- **The "4" axiom is sound:** `□A → □□A`. If A is provable now, then it is provable
  that A is provable. The proof is pure transitivity of `R`: a successor of a
  successor is a successor.
- **Löb's axiom is sound:** `□(□A → A) → □A`. The proof is a beautiful induction
  that runs *backwards* along the well-founded relation `R`. Because there are no
  infinite descending chains of counterexamples, you can prove A holds at every
  counterexample world by assuming it already holds at all the *deeper* ones — and
  Löb's hypothesis is exactly the lever that turns "A holds deeper down" into "A
  holds here." This single argument is, in miniature, the reason arithmetic cannot
  lie about itself.

**The new temporal law.** Now the genuinely new axiom, the one that justifies the
name "temporal." It reads `□A → □□◇A`, and unpacked it says:

> **If A is provable now, then it is provable that it is provable that A will
> someday be provable.**

This is the formal echo of a deeply human intuition about discovery. Once you have
nailed something down, not only is it nailed down — the fact that it *stays*
available into the future is itself something you can certify, and certify from the
inside, and certify that you can certify. The proof combines `R`-transitivity with
the reflexivity of time: A is provable two `R`-steps out, and "now" itself
witnesses the "someday." It is the axiom by which TGL strictly extends GL.

**Proofs persist.** The cleanest payoff of the monotonicity law is the statement
that gives the whole project its slogan:

> **Persistence of provability (`□A → G□A`):** if A is provable now, then at every
> future time A is *still* provable.

Knowledge, once gained, is not lost. We also state it in mirror form as
*provability monotonicity* — proofs are never un-proved. This is the formal license
for the way mathematics actually works: nobody re-derives the fundamental theorem of
calculus every morning. It was proved; it stays proved.

**The paradox that isn't.** Now we reach the riddle from the opening. Consider the
unsettling sentence:

> *"A is provable today, but A will not be provable tomorrow."*

If proofs could evaporate, this would be a genuine possibility, and it would be a
nightmare — it would mean that the ground under mathematics could shift, that a
theorem could be true-and-proved on Monday and unprovable on Tuesday. TGL settles
the matter cleanly:

> **The paradox is refutable.** In TGL, "provable today but not tomorrow" cannot
> happen. It is not merely unlikely; it is logically impossible on any temporal GL
> frame.

The proof is immediate from persistence: if A is provable today, persistence forces
A to be provable at every future time, including tomorrow — flatly contradicting the
second half of the sentence. The nightmare is ruled out by the structure of time
itself.

**But the asymmetry is real.** Here is where it gets subtle and, I think, genuinely
beautiful. Reverse the sentence:

> *"A is provable tomorrow, but A is not provable today."*

This one is **satisfiable**. There is a perfectly consistent temporal GL frame — an
explicit little two-world model — in which exactly this happens. And of course there
is, because *this is just what mathematical discovery looks like.* Fermat's Last
Theorem was provable in 1995 and not in 1994. New proofs appear; old proofs never
vanish. TGL captures both halves of that asymmetry at once: the future can bring you
things you did not have (satisfiable), but it can never take away things you had
(the paradox is refuted). Time, for proofs, is a one-way ratchet.

That asymmetry is not an accident of one model — it is forced by the converse
well-foundedness of `R`. To see that the structure is *load-bearing*, TGL also pins
down the boundary case: if you throw away converse well-foundedness and allow even a
single world that is its own counterexample (a "reflexive" world), **Löb's axiom
fails.** The whole edifice depends on proofs being finite, on the chains bottoming
out. Remove that, and the logic collapses.

## Gödel, now with a timestamp

The crown jewels of the development are two new faces of Gödel's second
incompleteness theorem.

The first is **semantic**. Strip away the arithmetic and look purely at the frame:

> **Kripke second incompleteness:** on any GL frame, if a world is *consistent*
> (it has at least one possible future it cannot rule out — it does not prove
> outright falsehood), then its own consistency is *not provable* there.

The proof is a gem of well-founded reasoning: climb to a deepest accessible world,
and show that if consistency were provable, that maximal world would have to
contradict its own maximality. Gödel's theorem, in other words, is not really about
numbers at all. It is about the geometry of well-founded structures. The numbers are
just one place that geometry shows up.

The second face is **temporal**, and it is the punchline the whole logic was built
to deliver:

> **Time-stamped second incompleteness:** if a system is consistent at stage `t`,
> then the statement "the system is consistent at stage `t`" cannot itself be proved
> by stage `t`.

You cannot certify your own consistency *on your own clock*. The proof is a direct
application of Löb's axiom to the time-indexed provability predicate. This is
Gödel's ancient limitation, now wearing a wristwatch — and it tells us something the
timeless version could not. Incompleteness is not just a fact about what arithmetic
*can* prove; it is a fact about what it can prove *in time*, about the order of
discovery.

## Proofs that vouch for themselves, later

Underneath the picture-logic sits a second, more concrete layer: an abstract
*time-stamped provability predicate*, written `prov t A`, meaning "there is a proof
of A established by stage `t`." This predicate is asked to obey exactly the laws a
real, honest, bounded provability predicate obeys: persistence (a proof by time `t`
is a proof by any later time), modus ponens (proofs combine), positive
introspection — the **Σ₁-completeness** that says if you have a proof you can prove
that you have it — and Löb.

From these, one gets a small but striking theorem about how proofs certify
themselves across time:

> **Future self-certification (`prov t A → prov s (prov t A)` for `t ≤ s`):** a
> proof established by time `t` is, at every later time `s`, *provably* established.

A proof does not merely persist; its very existence becomes a certifiable historical
fact. Yesterday's theorem is not just still true today — today we can prove that it
was proved. This is the formal backbone of how mathematics cites its own past: a
modern paper invokes a nineteenth-century lemma not by re-deriving it, but by
certifying that it was, in fact, established. The citation graph of mathematics is
`prov t A → prov s (prov t A)` made social.

And to be sure none of this is empty talk about nothing, the development includes a
consistency check: there is an actual model satisfying all the axioms of the
time-stamped predicate. The Gödel results above are not vacuous truths about an
impossible system; they bite on something real.

## Why a logic of *when* matters

It is tempting to file all of this under "elegant but academic." I want to argue the
opposite. The order in which things get proved is becoming one of the most practical
questions in modern mathematics, for a very twenty-first-century reason: more and
more mathematics is being done, checked, and *managed* by machines.

When a computer assembles a large proof, it is doing exactly what TGL describes:
establishing lemmas in some order, each one unlocking the next, building a temporal
dependency graph where some facts must be proved before others can even be stated.
"Proof mining" — the art of extracting better, more explicit information from
existing proofs — is fundamentally about *reorganizing* this temporal order.
Automated theorem provers schedule their work; they decide what to attempt now and
what to defer, and the value of a partial result depends entirely on *when* it
arrives and what it unlocks. A logic in which "provable by time `t`" is a first-class
citizen is precisely the right language for reasoning about these systems — for
proving that a proof-search strategy will *eventually* succeed (`◇`), that an
established lemma will *remain* available (`G□A`), or that the absence of a result
*now* does not doom it *later* (the satisfiable mirror).

But the deeper reason to care is conceptual. For ninety years, Gödel's theorems have
been told as a story about limits — about the things mathematics can never do. TGL
retells that story as one about *process*. Yes, a system cannot certify its own
consistency. But now we can say something sharper: it cannot do so *on its own
clock*, in its own present moment. The limitation has a temporal shape. And on the
other side of the ledger, the very thing that makes incompleteness inescapable — the
finiteness of proofs, the well-foundedness that forbids infinite regress — is the
*same* structure that guarantees the good news: that knowledge accumulates, that
proofs persist, that the nightmare of "provable today, gone tomorrow" can never
occur.

That is the quiet moral of Temporal Gödel–Löb logic. Time, for mathematical truth,
runs only one way. The future can hand you new theorems. It can never take the old
ones back. And the proof that this is so turns out to be the very same argument that
Gödel used to show us the edge of what we can know. The flashlight, it turns out,
remembers everywhere it has shone.
