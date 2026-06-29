# The Algebra of Time's Arrow

## A rigorous axiomatic skeleton for reversible physics

Time, in the equations of fundamental physics, is strangely two-faced. Run the
film of two billiard balls colliding backwards and nothing looks wrong: the
laws of mechanics do not care which way the clock turns. Run the film of a
shattering coffee cup backwards and the world looks absurd. Physics has lived
with this tension for over a century, and at the heart of David Hilbert's sixth
problem — his 1900 call to give physics the same axiomatic rigor that Euclid
gave geometry — lies a deceptively simple question: *what is the precise
algebraic structure of a theory in which time can be reversed?*

This article is about a small, sharp answer to that question. Instead of starting
from differential equations or Hilbert spaces, we start from the bare bones of
*combining processes*. Two operations capture almost everything a physicist does
with processes: you can run them **in sequence** (first this, then that) and you
can consider **alternatives** (this could happen, or that could). Add one more
operation — **time reversal**, the act of running a process backwards — and you
have the seed of a complete, machine-checked algebraic theory. We call the
resulting structure a **chronometric semiring**, and everything below has been
formalized and verified down to the last symbol.

## The two ways to combine a process

Imagine the elementary "moves" of some physical system — a quantum gate, a
chemical step, a state transition in an automaton. Call the collection of all
the things you can build from these moves `R`. There are two natural ways to put
moves together.

The first is **sequencing**, written as multiplication `a · b`: do `a`, then do
`b`. Like function composition, it is associative — `(a·b)·c` is the same as
`a·(b·c)` — and there is a "do nothing" move, the identity `1`, with `1·a = a·1
= a`.

The second is **choice**, written as addition `a + b`: either `a` happens or `b`
happens. There is an "impossible" move `0`, the choice with no options, satisfying
`0 + a = a`. Choice is commutative and associative, and — crucially for physics —
sequencing distributes over it: `a·(b + c) = a·b + a·c`. Offering a choice after
a fixed prefix is the same as offering the two full alternatives.

A set with these two operations satisfying these laws is called a **semiring**.
It is one rung below a ring: there is no subtraction, no notion of "negative
process". That omission is a feature, not a bug. You cannot un-happen an event by
adding its negative; the only structure available is what genuinely combines
processes.

We demand one extra law that distinguishes our setting from ordinary arithmetic:
**idempotent choice**, `a + a = a`. Offering the same alternative twice is no
different from offering it once. This single equation is what turns the bland
semiring into a *qualitative* algebra of possibilities, the kind that underlies
shortest-path computations, formal-language theory, and the "max-plus" tropical
mathematics used in scheduling and optimization. It also quietly installs a
natural notion of order: we declare `a ≤ b` to mean `a + b = b`, i.e. "`b`
already includes `a` as one of its possibilities." From `a + a = a` alone one
proves reflexivity (`a ≤ a`), and a three-line calculation gives transitivity,
so possibilities are partially ordered with the impossible event `0` at the very
bottom.

## Reversing the arrow

Now we add the protagonist: **time reversal**, a map `†` (read "dagger") that
sends every process to its run-backwards counterpart. What laws must it obey to
deserve the name?

First, reversing twice gets you home: `(a†)† = a`. Mathematicians call a map with
this property an **involution**; physicists recognize it as the defining feature
of the time-reversal operator `T`. In our formalization this is the theorem with
the evocative name `thermodynamic_rev_rev_collapse`: the double application of `†`
collapses back to the identity.

Second, reversal must respect choice exactly: `(a + b)† = a† + b†`. The
time-reverse of "either `a` or `b`" is "either `a`-backwards or `b`-backwards."

Third — and this is the law with real physical teeth — reversal must *flip the
order* of sequencing:

> **(a · b)† = b† · a†.**

If you do `a` and then `b`, the backwards film shows `b`-reversed first and
`a`-reversed second. This is not a quirk; it is the single most important
structural fact about reversal, and it appears throughout physics. It is exactly
the rule for the adjoint of a product of quantum gates, `(UV)† = V†U†`, and for
the inverse of a composition of motions. A map that reverses multiplication order
is called an **anti-automorphism**. So the precise slogan is: *time reversal is an
involutive anti-automorphism that fixes the trivial process and respects choice.*

Finally we require `0† = 0` and `1† = 1`: the impossible and the do-nothing
processes are their own mirror images.

A semiring carrying such a `†`, together with one more ingredient we describe
below, is a **chronometric semiring**. The whole of classical and quantum process
algebra, stripped to its reversibility skeleton, fits inside this definition.

It is worth pausing on what falls out for free. An element `x` with `x† = x` is
its own time-reverse — a **time-symmetric**, or `T`-invariant, observable, the
kind that survives the reversal of the clock. We prove that the impossible event
`0`, the trivial process `1`, and the sum of any two symmetric processes are all
themselves symmetric. The `T`-invariant world is closed under choice: a tidy,
verified fact about the algebra of symmetries.

## Causality, as a closure

There is a third operation lurking in physics that has nothing to do with
sequencing or choice: **causal propagation**. Given a set of events, its *causal
closure* is the larger set of everything those events can influence — their
forward light cone, in relativistic language. Whatever the details, causal
closure obeys three abstract laws that mathematicians have isolated as the axioms
of a **closure operator**:

- it only ever *adds* events (a set is contained in its closure);
- it is *monotone* (a bigger input gives a bigger closure);
- it is *idempotent* (closing an already-closed set changes nothing).

We bundle this closure into the chronometric semiring and require, sensibly, that
the impossible event always lies in any causal closure. A set equal to its own
closure is a **causal fixed point** — a self-contained, equilibrium-like region
of the theory from which causality cannot escape. We prove the closure of *any*
set is automatically such a fixed point, and that the universal set (everything)
is too.

This is where the framework reveals an unexpected bridge: between *time* and the
*spectral geometry* of algebra. Borrowing the machinery of algebraic geometry, we
attach to the semiring a **spectrum** of "chrono-prime" theories — coherent ways
of declaring which processes count as negligible, compatible simultaneously with
sequencing, with time reversal, and with causal closure. To each set of processes
we associate its **zero locus**: the chrono-primes in which all those processes
vanish. Two clean theorems mirror the Zariski topology of classical geometry: the
zero locus of nothing is everything (`chronoZeroLocus_empty`), and the zero locus
of a union is the intersection of the separate zero loci (`chronoZeroLocus_union`).
A third, the multiplicative law `D(a·b) = D(a) ∩ D(b)`, says a sequential process
is observable exactly when *both* of its parts are.

The crown of this section is a *reconstruction* theorem. It says that a causal
fixed point can be recovered entirely from the chrono-primes that see it vanish:

> **A causally closed set equals the set of all processes that vanish in every
> chrono-prime where the original set vanishes.**

In plainer words, *a causal theory is completely determined by its spectrum of
elementary observations*. This is the algebraic shadow of a deep idea in modern
mathematical physics — that a physical system can be reconstructed from the
lattice (or topos) of its observable propositions — made fully explicit and
verified. Along the way we prove that causal closure does not change observability
at all: the zero locus of a set and of its causal closure are identical. Causes
and their consequences are spectrally indistinguishable.

## From axioms to computation: the trace calculus

Axioms are only half of Hilbert's dream. The other half is *effectiveness* — the
ability to actually compute. Here the framework earns its keep.

We introduce a tiny programming language of **trace expressions**. Its grammar is
exactly the six operations of the algebra: the constants `0` and `1`, a way to
name an atomic move, sequencing `e · f`, choice `e + f`, and reversal `e†`. Any
finite reversible process is a term in this language.

The central computational object is a **normal form**: a *sum of words*, where a
word is a product of *signed atoms*. A signed atom is just an elementary move
tagged with a direction — forwards, or time-reversed. The normal form is the
algebraic analogue of expanding a polynomial into a sum of monomials, except the
"monomials" are sequences of directed moves and the bookkeeping must respect the
order-flipping law of reversal.

Normalization proceeds by the obvious recursion. The empty choice `0` becomes the
empty sum; `1` becomes the single empty word; an atom becomes a one-letter
forward word; choice concatenates the two sums; sequencing distributes, producing
every word of the first times every word of the second; and reversal flips each
word — reversing the letter order *and* flipping every atom's direction, the
discrete echo of `(a·b)† = b†·a†`.

Two theorems make this calculus trustworthy.

The first is **soundness**: for every trace expression `e` and every assignment
`σ` of actual processes to atoms,

> **evaluating the normal form of `e` gives exactly the same element as
> evaluating `e` directly.**

Normalization rearranges syntax without ever changing meaning. The proof is an
induction over the six constructors, each step leaning on a matching algebraic
law — distributivity for sequencing, the order-flip for reversal, involutivity to
cancel double daggers. The reversal case is the subtle one, and it is precisely
where the anti-automorphism law does the heavy lifting.

The second is a **complexity bound**. Normal forms can blow up — distributing a
product of `k` choices against another genuinely multiplies the number of words —
but never uncontrollably. We prove

> **the normal form of an expression of size `s` contains at most `2^s` words,**

a clean exponential ceiling on the cost of canonicalization, with the reversal
operation adding *nothing* to the count (reversing a sum has exactly as many
words as the original). And when the expression contains no sequencing at all —
only choices and reversals — the blow-up vanishes entirely: normalization is
**linear**, producing at most `s` words. The exponential cost is the price of
multiplication, and nothing else.

These bounds turn the algebra into a decision procedure. Because two expressions
with identical normal forms must evaluate identically *in every chronometric
semiring at once*, we obtain a **sound equality test**: compute both normal
forms, compare them as data, and if they match the two processes are
indistinguishable in any reversible physical model whatsoever. Time-reversal
symmetry, in this corner of physics, has become something a computer can check.

## Why this matters

It would be easy to mistake all this for abstract nonsense. It is the opposite:
it is abstraction in the service of *certainty*. Every claim above — the
involution law, the order-flip, the lattice of zero loci, the reconstruction of
causal theories, the soundness of normalization, the `2^s` bound — has been
written in the formal language of a proof assistant and checked by machine. There
are no hand-waves, no "it can be shown that," no appeals to physical intuition
standing in for proof. This is what Hilbert asked for in 1900: physics with the
deductive hygiene of mathematics.

The chronometric semiring will not, by itself, derive the Standard Model. That
was never the point. Its point is to isolate one universal feature of physical
law — reversibility, with its tell-tale order-flip — and pin it down so exactly
that an entire calculus of reversible processes, complete with a working,
verified normalization algorithm and honest complexity bounds, follows by pure
deduction. From two ways of combining processes and one way of running them
backwards, a small but genuine fragment of axiomatic physics emerges, fully
formed and fully checked. Time's arrow, it turns out, has an algebra — and we can
now write it down without fear of error.
