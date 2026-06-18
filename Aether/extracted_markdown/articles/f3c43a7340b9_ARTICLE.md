# The Hidden Lattice of Proof

## A surprising order behind every way of being convinced

Imagine two mathematicians arguing. One reaches for a slick one-line trick; the
other grinds through a long, mechanical calculation. Both end up convinced of the
same fact. We tend to think of their *proofs* as utterly different objects — one
elegant, one plodding — but if we step back and ask only *which statements each
method is capable of establishing*, a remarkable structure snaps into focus. The
messy world of proofs, with all its idiosyncrasies, organizes itself into a clean,
almost crystalline shape: a **lattice**, the same algebraic skeleton that governs
how sets nest inside one another.

This article is about that hidden order. It is a story from the corner of logic
and computer science called **proof complexity**, and it concerns not whether a
statement is *true*, but how *hard it is to certify* that truth. The punchline —
made completely precise below — is that when you compare proof systems by their
raw power, you are secretly comparing subsets of all possible theorems. Every
question about "can this method prove what that method proves?" becomes a question
about "is this set contained in that set?" And once you see that, a great deal of
the subject's mystery dissolves into ordinary set theory.

## What is a proof system, really?

Forget, for a moment, the human drama of insight and elegance. A working
definition that a machine could check needs only three ingredients. A **proof
system** over some universe of formulas `F` is:

1. an abstract collection of objects we agree to call *proofs*;
2. a rule, `concl`, that reads each proof and reports the single formula it
   establishes — its *conclusion*;
3. a measure, `size`, that assigns to each proof a natural number recording how
   long or expensive it is.

That is the entire definition. Notice what is *not* there: we never say how a
proof is structured, what its inference rules are, or what language it is written
in. A proof could be a derivation in classical logic, a run of a SAT solver, a
filled-in truth table, or a certificate spat out by some exotic algorithm. As long
as we can extract "what it proves" and "how big it is," it counts.

From these three ingredients one quantity matters above all others: the set of
statements a system can actually establish. We call it the **provable set**:

> **Definition (Provable set).** `Prov P` is the set of all formulas that arise
> as the conclusion of *some* proof in `P`. In symbols, `Prov P = range(concl)`.

This is the system's repertoire — its complete list of theorems. Two systems with
the same repertoire are, for our purposes, interchangeable, no matter how
differently their internal proofs are built.

## Comparing power: the simulation preorder

Now we can compare systems. We say a system `Q` **simulates** a system `P` when
everything `P` can prove, `Q` can prove too:

> **Definition (Simulation).** `Q` simulates `P`, written `Simulates Q P`, exactly
> when `Prov P ⊆ Prov Q`.

Read that twice, because it is the keystone of the whole edifice. Simulation is
nothing more than containment of repertoires. It immediately inherits the good
manners of containment:

- **Reflexivity.** Every system simulates itself (`Prov P ⊆ Prov P`).
- **Transitivity.** If `R` simulates `Q` and `Q` simulates `P`, then `R` simulates
  `P` — because containment chains together.

When two systems simulate each other, they have exactly the same theorems, and we
call them **simulation-equivalent**. The precise statement is clean:

> **Theorem (Equivalence is equality of repertoires).** `P` and `Q` are
> simulation-equivalent if and only if `Prov P = Prov Q`.

This is our license to *stop caring about the internal lives of proofs*. Up to
simulation-equivalence, a proof system simply *is* its set of theorems. The
elegant one-liner and the plodding calculation, if they happen to establish the
same family of statements, are the very same point in this geometry.

## Building new systems from old: union, meet, and the lattice

Once a proof system is "just" a set of theorems, we can ask the natural algebraic
question: can we combine systems? There are two fundamental ways, and they mirror
the two basic operations on sets.

**Combine by union (the join).** Given systems `P` and `Q`, form a new system whose
proofs are "a proof from `P` *or* a proof from `Q`." Run either method; accept
whatever either one establishes. The repertoire of this combined system is exactly
the union of the two repertoires:

> **Theorem (Join).** `Prov(P ∪ Q) = Prov P ∪ Prov Q`.

This combined system is the *least* system powerful enough to simulate both `P`
and `Q`: it proves everything they prove and nothing extra. It is their **least
upper bound**, or **join**.

**Combine by agreement (the meet).** The dual construction is subtler and more
interesting. Form a system whose proofs are *pairs* — one proof from `P` and one
from `Q` — but only pairs that establish the *same* formula. A proof in this system
is a guarantee that *both* methods independently certify the conclusion. Its
repertoire is exactly the intersection:

> **Theorem (Meet).** `Prov(meet P Q) = Prov P ∩ Prov Q`.

This is the *greatest* system that both `P` and `Q` can simulate — their **greatest
lower bound**, or **meet**. And here is a quietly beautiful detail in the
construction: because a proof in the meet carries one proof from each side, its
*size* is the sum of the two component sizes. Agreement is not free; it costs the
combined length of two independent certificates. We will return to this.

**Combine arbitrarily many.** The union construction does not stop at two. Given a
whole family of systems indexed by some set — possibly infinite — we can form their
combined system, whose proofs are "a proof from any one of them." Its repertoire is
the union over the entire family:

> **Theorem (Arbitrary join).** `Prov(⋃ᵢ Pᵢ) = ⋃ᵢ Prov(Pᵢ)`.

Together, these three results say something striking. The operations of *combining
by union* and *combining by agreement* behave, at the level of repertoires, exactly
like the union and intersection of sets. Proof systems, compared by simulation,
form a **lattice** — and not just any lattice, but a faithful copy of the lattice
of all subsets of `F`.

## The duality: proof systems are subsets in disguise

How faithful is the copy? Completely. Here is the result that seals it.

> **Theorem (Duality / surjectivity).** *Every* set of formulas is the repertoire
> of *some* proof system.

The construction behind this is almost a joke. Given any target set `S` of
formulas you want to be provable, build the "tautology-table" system whose proofs
*are simply the elements of `S`*, each proof concluding itself, each of size zero.
Its repertoire is `S` exactly. A special case is the **singleton system** that
proves one chosen formula `f` and nothing else; its repertoire is `{f}`.

So the map sending each proof system to its repertoire is *onto* the entire
powerset of `F`. Combined with the equivalence theorem — that systems with equal
repertoires are interchangeable — we reach the central organizing principle:

> **Proof systems, compared by simulation, are exactly the subsets of all possible
> theorems, compared by inclusion.**

This is a genuine *duality*, in the same spirit that links geometric objects to
the algebra of functions on them, or logical theories to the spaces of their
models. The combinatorial chaos of inference rules collapses onto a structure
every student of mathematics already knows intimately: sets and their containment.

## The maximal systems: completeness as the top of the order

If proof systems form a lattice ordered by power, is there a top? In any fixed
context we usually carry along a notion of which formulas *ought* to be provable —
the **valid** ones (the tautologies, say, or the true statements of arithmetic).
Two adjectives describe how a system relates to validity:

- A system is **sound** if it only ever proves valid formulas — it never lies.
- A system is **complete** if it proves *every* valid formula — it misses nothing.

These two notions interact to pin down the top of the order:

> **Theorem (Maximality of complete systems).** Any complete system simulates every
> sound system.

The proof is a single breath. Take a complete system `C` and any sound system `P`.
Whatever `P` proves is valid (soundness), and `C` proves everything valid
(completeness), so `C` proves whatever `P` proves. Done.

Modest as it looks, this is the abstract heart of one of proof complexity's
deepest themes — the search for *optimal* proof systems. Among all the sound,
trustworthy ways of certifying truth, the complete ones sit at the very top: they
can reproduce any honest argument anyone could ever give. The famous open
questions of the field are about whether one can do this *efficiently* — and that
is where size comes back into the story.

## When size matters: polynomial boundedness

So far we have measured systems only by *what* they can prove. But the soul of
complexity theory is *how cheaply*. A system is **polynomially bounded** — "p-bounded"
— when every theorem has a proof whose size is no larger than a fixed polynomial in
the size of the formula being proved. Crucially, the polynomial is the *same* for
all theorems: there are constants `c` and `k` such that every provable formula `f`
admits a proof of size at most `c · (size of f + 1)^k`.

Polynomial boundedness is the dividing line between proof systems that are
practical and those that, in the worst case, demand astronomically long
certificates. One of the great open problems of the field — equivalent to a vast
strengthening of the question of whether `NP` equals `coNP` — asks whether *any*
proof system for propositional tautologies is polynomially bounded. Nobody knows.

What we *can* settle cleanly is how this efficiency interacts with the lattice
operations. Recall that the join — combining by union — runs whichever component
finds a proof. If both components are individually p-bounded, the combination
inherits a single polynomial bound that works for both repertoires at once:

> **Theorem (Join preserves polynomial boundedness).** The union of two p-bounded
> systems is p-bounded.

The argument is the natural one: if `P`'s proofs fit under `c₁ · (n+1)^{k₁}` and
`Q`'s under `c₂ · (n+1)^{k₂}`, then take `c = c₁ + c₂` and exponent `k = max(k₁, k₂)`,
and every proof in the combined system — coming from one side or the other — fits
under `c · (n+1)^k`.

And this scales. The flagship quantitative result of the theory is that *finitely
many* p-bounded systems, joined all at once, remain p-bounded:

> **Theorem (Finite joins preserve polynomial boundedness).** The combined system
> of finitely many p-bounded systems is itself p-bounded.

Here is the intuition, and it is genuinely the right one. Each system in the
finite family comes with its own constant and exponent. Because there are only
finitely many, we can take the *largest* exponent and the *sum* of the constants,
producing one universal polynomial that dominates them all simultaneously. The
combined system, free to use whichever component is cheapest for a given theorem,
never exceeds this single bound.

Why insist on *finitely* many? Because the moment we allow infinitely many systems
with ever-growing constants, the "largest exponent, summed constants" trick breaks:
there is no largest exponent and no finite sum. This is not a defect of the proof —
it is the precise location of one of the discipline's deepest open problems. The
gap between *finite* and *countable* joins is exactly where the question of whether
a single, universally efficient proof system can exist lives. The finite case is a
theorem; the infinite case is a famous conjecture. Our lattice draws the line
between them with surgical clarity.

## Why this matters beyond logic

It is tempting to file all this under "abstract nonsense," but the duality has
teeth in the real world. Every automated reasoning tool — the SAT and SMT solvers
that verify microprocessors, schedule airline fleets, and check that safety-critical
software cannot crash — is, underneath, a proof system in exactly the sense above.
When engineers ask "is solver A strictly more powerful than solver B?" or "if I
bolt these two solvers together, what can the combination do, and how big do the
certificates get?", they are asking simulation and join questions. The lattice
answers them in a uniform language: *power is containment of repertoires, and
combining is union of repertoires.*

The polynomial-boundedness results have an equally concrete reading. Bundling
several efficient solvers into a portfolio — running them in parallel and accepting
whichever finishes first — is precisely the join construction. The theorem that
finite joins preserve polynomial boundedness is the formal promise that such a
portfolio stays efficient: it is never asymptotically worse than its best member.
Conversely, the cost of the *meet* — where proof sizes add because you demand
agreement from two independent methods — quantifies the price of cross-checking,
of insisting that two solvers independently confirm the same result for extra
assurance.

## The shape of the answer

Step back and admire the arc. We began with proofs as unruly, incomparable
artifacts of human and machine ingenuity. By insisting on measuring them only by
*what they can establish*, we discovered that they line up into a lattice — and not
a mysterious new one, but a perfect mirror of the humble lattice of subsets.
Combining proof methods by alternative is union; combining by agreement is
intersection; the most powerful honest systems sit at the top; and efficiency,
that most precious and elusive property, is preserved exactly as far as finite
combination and no further.

The deepest questions remain gloriously open. We do not know whether truth admits
a universally efficient certificate. But we now know precisely *where* that
question lives — in the chasm between finite and infinite joins — and we have a
clean, complete map of everything surrounding it. Sometimes the greatest progress
in mathematics is not answering the question, but finally seeing the exact shape of
the room in which the question is hiding.
