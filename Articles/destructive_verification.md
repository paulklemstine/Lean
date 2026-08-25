# The Test That Eats the Cake

## What we lose when we pretend that checking is free

Ask a mathematician what it means to verify something and you will get a
crisp answer: verification is a *predicate*. There is a set of objects, there
is a property, and there is a procedure that takes an object and returns
`true` or `false`. Whole fields are built on that picture. Complexity theory
asks how hard the predicate is to evaluate; cryptography asks who can evaluate
it and who cannot; logic asks which predicates are decidable at all.

But look closely at that picture and you will notice a silent assumption, one
so natural that it usually escapes notice entirely: **the object survives the
check.** You hand over the thing; you get back a verdict; the thing is still
there, unchanged, ready to be checked again by somebody else.

That assumption is false almost everywhere outside mathematics.

A metallurgist verifies the tensile strength of a steel cable by pulling it
until it snaps. The verdict is trustworthy precisely because the cable is now
in two pieces. A food inspector verifies that a batch of canned goods is
sterile by opening a can and culturing its contents; the can is gone. A
physicist verifies that a photon is polarised vertically by passing it through
an analyser, and in doing so destroys the very superposition that was being
interrogated. A concert pianist verifies that a Steinway sounds right by
playing it, and the felt on the hammers is a little more compressed than it
was. A single-use authentication token verifies its bearer exactly once.

In every one of these cases the verdict comes with a bill, and the bill is
paid in the object itself. The predicate model cannot even express this. It
has no vocabulary for the residue.

This article is about what happens when you give it one.

## Verdicts with a residual dish

Here is the change. Instead of modelling a test as a function

$$t : D \longrightarrow \{\text{true}, \text{false}\},$$

model it as a **state transition**

$$t : D \longrightarrow \{\text{true}, \text{false}\} \times D.$$

Call the elements of $D$ **dishes** — samples, specimens, artefacts, quantum
states, whatever you are checking. A test now returns two things: the
**verdict** $v(d)$, the Boolean it would have returned in the old model, and
the **residue** $r(d)$, the dish you get back afterwards. Nothing has been
added to the mathematics except honesty about what is handed back.

The payoff is immediate. Three notions that the predicate model was forced to
conflate now pull cleanly apart:

- A test is **nondestructive** — a genuine *certificate check* — if
  $r(d) = d$ for every dish. You get the dish back exactly as you gave it.
- A test is **reversible** if $r$ is a bijection of $D$. The dish is
  transformed, possibly beyond recognition, but nothing is lost: in principle
  one could invert the transformation and recover the original.
- A test is **repeatable** if $v(r(d)) = v(d)$ for every dish. Running the
  test a second time, on whatever came back, reproduces the first answer.

The old predicate model is exactly the nondestructive corner of this world. It
is a corner, and — as we will see — a very small one.

## The three classes come apart

The first thing to establish is that these really are three different notions
and not three names for one. Certificates are the easy end: if $r(d) = d$,
then $r$ is the identity, which is a bijection, so **every nondestructive test
is reversible**; and $v(r(d)) = v(d)$ trivially, so **every nondestructive
test is repeatable**. In fact something stronger is true: for a certificate,
the verdict is unchanged after *any* number of re-runs, since the dish never
moves at all.

The interesting question is whether anything comes back the other way. It does
not, and two dishes are enough to prove it. Take $D = \{0, 1\}$ and consider
three tests.

**The flip test.** It always accepts, and it swaps the dish:
$t(d) = (\text{true}, \, \lnot d)$. Its residue map is the swap, a bijection,
so the test is reversible. Its verdict is constantly `true`, so it is
repeatable. And yet $r(0) = 1 \ne 0$, so it is destructive. Reversibility does
*not* imply nondestructiveness.

**The read-and-flip test.** It reports the dish and then swaps it:
$t(d) = (d, \lnot d)$. Again the residue is a bijection, so nothing is lost.
But run it twice on the dish $1$: the first run says `true`, the second says
`false`. Reversibility does *not* imply repeatability. This is the honest
formal shadow of a measurement that disturbs what it measures.

**The burn test.** It always accepts and incinerates the dish down to a fixed
ash: $t(d) = (\text{true}, 0)$. The verdict never changes, so it is
repeatable — repeatable, note, *precisely because* it always destroys the dish
in the same way. But its residue map is constant, hence not injective, so the
test is not reversible. Repeatability does *not* imply reversibility.

So the taxonomy is strict in every direction. Neither reversibility nor
repeatability implies the other, and neither implies that the dish comes home
intact. No implication holds beyond the two we proved.

There is a constraint, though, and it is a pretty one. Suppose a repeatable
test *decides* a property $P$: it accepts a dish exactly when the dish has
property $P$. Then $P$ is invariant along the residue map — $P(r(d))$ holds if
and only if $P(d)$ does. A repeatable test may wreck the dish in a thousand
ways, but it cannot wreck the one property it is checking. Destruction is not
forbidden by repeatability; it is *steered* by it. (Certificates, by contrast,
preserve every property whatsoever, which is another way of saying they do
nothing at all to the dish.)

## Certificates commute; destructive tests do not

Real verification is rarely one test. It is a battery: run this, then that,
then the other, and accept only if everything passed. In the state-transition
model that composition writes itself. To run $t_1$ and then $t_2$, feed the
residue of the first into the second and conjoin the verdicts:

$$(t_1 \cdot t_2)(d) = \big(v_1(d) \wedge v_2(r_1(d)),\; r_2(r_1(d))\big).$$

This operation is associative, and the trivial test that accepts everything
and touches nothing is a two-sided identity. So the tests on a fixed dish type
form a **monoid**, and the certificates form a submonoid: a battery of
nondestructive tests is nondestructive. The reversible tests are closed under
composition too, since a composite of bijections is a bijection.

And now the sharpest statement in the whole subject. Suppose $t_1$ and $t_2$
are both certificates. Then

$$t_1 \cdot t_2 = t_2 \cdot t_1,$$

exactly, as tests: same verdict on every dish, same residue on every dish.
**A battery of certificates may be run in any order.** This is why the old
predicate model gets away with never mentioning order. Conjunction is
commutative, and if checking costs nothing, a battery is just a conjunction.

Introduce a single destructive participant and the property dies. Let $c$ be
the certificate that reports the dish and returns it untouched, and let $b$ be
the burn test. Run $c$ first: it reports the dish faithfully, then $b$ accepts,
so the battery reports the dish. Run $b$ first: it burns the dish to $0$, and
then $c$ reports $0$ — always. The two orderings are different tests, and they
differ *in the verdict*, not merely in the residue. Order matters as soon as
destruction enters, and it matters observably.

This is the formal core of a piece of laboratory folklore every experimentalist
knows: do the nondestructive assays first.

## Counting: certificates are exponentially rare

How much of the world does the predicate model actually cover? On a dish type
with $n$ elements, a test is a function $D \to \{\text{true},\text{false}\}
\times D$, so there are exactly $(2n)^n$ tests. A nondestructive test, on the
other hand, is uniquely determined by its verdict function — you know what it
does to the dish, namely nothing — so there are exactly $2^n$ certificates.
And the reversible tests are exactly a verdict function together with a
permutation of the dishes, giving $2^n \cdot n!$ of them, with the
certificates sitting in the slice where the permutation is trivial.

For $n \ge 2$ we therefore have $2^n < (2n)^n$, and the ratio is $n^n$. The
classical predicate model of verification describes an exponentially thin
sliver of the tests that exist.

## Watching a test destroy something

Here is where the subject gets genuinely combinatorial. Because a test returns
a dish, you can run it again — on its own residue — and again, and again. What
you observe is a stream of verdicts, the **transcript** of the test on a dish:

$$T(k) = v\big(r^{k}(d)\big), \qquad k = 0, 1, 2, \ldots$$

Repeatability, in this language, is exactly the statement that every transcript
is constant. And now a natural adversarial question: **how long can a
destructive test masquerade as a certificate?** How many identical verdicts can
you observe before you are entitled to conclude that the verdicts will never
change?

The answer is beautifully clean, and it is the number of dishes.

**Transcript rigidity.** On a dish type with $n$ elements, if the first $n$
entries of a transcript all agree with the initial verdict, the entire infinite
transcript is constant.

The reason is a pigeonhole argument on the orbit of the dish under the residue
map. There are only $n$ dishes; iterating $r$ from $d$ must revisit a dish
within $n$ steps; so every point the orbit ever reaches is already among its
first $n$ points. If the verdict is unchanged on all of those, there is nowhere
left for it to change.

And the bound is exactly sharp. For every $k$ there is a **fuse test** on
$k + 2$ dishes: the dish advances one notch per run, like a burning fuse, and
the verdict flips only when it reaches the last notch. That test accepts for
runs $0, 1, \dots, k$ and rejects at run $k + 1 = n - 1$. So on $n$ dishes a
test can conceal its destructiveness for exactly $n - 1$ runs and never for
$n$. Every destruction depth below $n$ occurs; none at or above $n$ does.

The immediate corollary is a licence to stop testing. If a dish survives $n$
consecutive runs of a test — every run accepting — then it survives
*arbitrarily many* runs. Finite testing certifies infinite testing. And by the
fuse test, $n - 1$ runs genuinely would not have been enough.

## Every test becomes a certificate eventually

Iterate a map on a finite set and it settles: the orbit runs down a tail and
into a cycle. Translated into verification, this yields something that sounds
almost paradoxical.

**Stabilisation.** On a finite dish type, for every test there is a batch
length $N > 0$ such that running the batch twice leaves the same dish as
running it once. On the image of that batch, the test *is* a certificate: every
dish there is returned unchanged by it.

Better still: on the stabilised core — the set of dishes reachable after $N$
preparatory runs — the residue map of the *original* test is a bijection.
**Destruction is confined to the transient.** Whatever a test does on the way
in, once the dish space has settled the test is reversible on what remains.
There is a real-world flavour to this: break-in periods, burn-in tests,
pre-conditioning a sample until further handling stops changing it.

## Which verdict streams can exist at all?

We know transcripts cannot be arbitrary. What exactly can they be? The answer
is an exact characterisation, and it turns the number of dishes into a measure
of complexity.

Since the orbit of a dish is a tail feeding a cycle, the transcript is
eventually periodic: there are a preperiod $i$ and a period $p > 0$ with
$T(m + p) = T(m)$ for all $m \ge i$, and crucially $i + p \le n$. That is the
analysis. The synthesis runs the other way, and it is completely explicit.
Given any eventually periodic Boolean stream with preperiod $i$ and period $p$,
build the **rho test** on exactly $i + p$ dishes: a tail of length $i$ feeding a
cycle of length $p$ — the classical "$\rho$" shape — with the verdict at each
dish reading off the stream at that position. Its transcript is the given
stream, on the nose.

Together:

**State-complexity duality.** A Boolean stream is the transcript of some test
on at most $n$ dishes if and only if it is eventually periodic with
$\text{preperiod} + \text{period} \le n$.

The number of dishes required to realise a verification behaviour is *exactly*
the combinatorial complexity of its verdict stream. Certificates sit at the
very bottom of the scale, at complexity $1$: a transcript is constant precisely
when it needs no transient and has period one. And the hierarchy is strict at
every level — the stream that rejects exactly at the multiples of $n$ needs $n$
dishes and cannot be produced with fewer, because its period must be a multiple
of $n$. Each additional dish buys a genuinely new verification behaviour.

## How long until two samples part company?

One last question, and it is the one an experimentalist would actually ask.
You have two dishes and one test. You run the test on each, over and over, and
the verdict streams agree. When may you conclude that they will *always* agree?

The obvious argument runs the test on the pair $(d, e)$ simultaneously, treats
it as a dynamical system on $D \times D$, and applies the pigeonhole principle
to get a bound of $n^2$ runs. That is correct and badly wasteful.

The right bound is linear, and getting it requires importing a tool from a
different field entirely: the **Fine–Wilf periodicity lemma** from combinatorics
on words, which says that a word simultaneously periodic with periods $p$ and
$q$ over a long enough window is periodic with period $\gcd(p, q)$. Both
transcripts are eventually periodic with $\text{preperiod} + \text{period} \le
n$ — that is the state-transition input. A window of agreement of length
$p + q$ forces the common stretch to have period $\gcd(p, q)$ — that is the
word-combinatorial input. Put together, they pin the two streams to each other
forever, and yield a bound of $2n$ runs.

Halving that constant to the optimum-so-far takes more structure again. Replace
the pigeonhole recurrence by the *minimal* recurrence of each orbit, whose
first $i + p$ points are pairwise distinct, and whose period divides every
eventual period of the orbit. Then split into two cases. If the two orbits
never meet, their point sets are disjoint, so $(i_1 + p_1) + (i_2 + p_2) \le n$
and the Fine–Wilf window fits inside $n$ easily. If they do meet, they are
running around the same cycle, so $p_1 = p_2$, the gcd absorbs one of the two
periods, and the window collapses to $\max(i_1, i_2) + p_1 \le n$. Either way:

**Observational equivalence is decided by $n$ runs.** If two dishes give the
same verdict for the first $n$ runs of a test, they give the same verdict
forever.

The same number, $n$, governs both phenomena: after $n$ runs a transcript can
no longer change its mind, and after $n$ runs two dishes can no longer part
company.

And watching really is necessary. On five dishes, consider the **clock test**
whose residue map consists of a two-cycle $\{0,1\}$ and a three-cycle
$\{2,3,4\}$, with verdicts `true, false, true, false, true` at the five
positions. Dishes $0$ and $2$ produce identical transcripts for three runs and
disagree on the fourth. Delay is real; one run never suffices.

Exhaustive search over small dish types suggests the true threshold is $n - 1$
rather than $n$, and the five-dish clock test is exactly the extremal witness
one would expect. Closing that final gap of one is the obvious next problem.

## What the model buys

None of this assigns a hardness label to anything. There is no claim that
destructive tests are harder, or cheaper, or more powerful. The content is
purely structural: once you admit that verification returns a residue, three
notions separate, they separate strictly, they separate again at the level of
closure properties, and they separate a third time in the verdict streams they
can produce — and all of it is governed by a single combinatorial parameter,
the number of distinguishable states a dish can be in.

The predicate model was never wrong. It was a coordinate chart, valid on the
patch where checking is free. What the state-transition picture shows is how
small that patch is: $2^n$ points in a world of $(2n)^n$, one commutative
sliver of a thoroughly non-commutative monoid. Everywhere else, the test eats
the cake — and the mathematics of how much, how fast, and how long you can fail
to notice turns out to be sharp, finite, and surprisingly pretty.
