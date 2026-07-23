# The Oracle That Knows Everything — and the Ones That Never Could

## A tempting promise

Imagine a machine that answers every yes-or-no question you could ever ask.
Not most questions — *every* question. You type in a sentence, and it tells
you, instantly and correctly, whether that sentence is true or false. It
sounds like science fiction, or perhaps like the marketing copy for the next
generation of artificial intelligence.

Here is a claim that sounds outrageous but turns out to be a theorem: **if you
agree in advance to keep your questions short, such a machine provably exists.**
Not "might exist," not "could be approximated" — it exists, exactly, with one
hundred percent accuracy.

And here is the twist that makes the story worth telling: the very same line of
reasoning that hands you this all-knowing oracle also draws a hard, permanent
boundary around it. Loosen the rules even slightly — let the questions grow
without bound, or ask for a single machine that works no matter how "truth"
itself is defined — and the oracle evaporates. It cannot exist, and we can
prove that too.

This article is about that boundary: where omniscience is free, where it is
impossible, and why the difference comes down to two words that mathematicians
have fought over for a century — *finite* and *uniform*.

## The Library of Babel, tidied up

Jorge Luis Borges imagined a library containing every book that could ever be
written using a fixed alphabet up to a fixed length. Most of its volumes are
gibberish; a precious few contain profound truths; the vast majority are
somewhere in between. The library is unimaginably enormous, yet — and this is
the crucial point — it is *finite*.

Our questions live in a Borgesian library. Fix an alphabet with $a$ symbols
and a maximum length $\ell$. A **statement** is simply a string of at most that
length. The number of such statements is exactly

$$a^{\ell},$$

a number that can be astronomically large but is never infinite. With $a = 26$
letters and length $\ell = 100$, we are talking about $26^{100}$ statements —
more than the number of atoms in the observable universe. Still finite.

This single fact — finiteness — is the hinge on which everything turns.

## Why a perfect oracle is free

Suppose someone hands you a notion of truth: a rule that labels each of these
$a^{\ell}$ statements as either **true** or **false**. Call this rule the
*semantics*. It might be arithmetic truth, or the laws of physics, or the
private opinions of a committee — the mathematics does not care. All that
matters is that every statement gets one definite label.

Now build the oracle in the most naive way imaginable: **write the answers
down.** For each of the finitely many statements, record its label in a giant
lookup table. When a question arrives, look it up and read off the answer.

This oracle is correct on *every single statement*, by construction. Its
accuracy is not 95%, not 99% — it is 100%. Formally:

> **Theorem (Perfect Finite Oracle).** For any finite bounded language and any
> assignment of truth values to its statements, there exists an oracle whose
> answers are correct on every statement. In particular it clears any accuracy
> benchmark, including $95\%$.

The proof is almost insultingly short. The exact oracle answers "yes" exactly
when the statement is true and "no" exactly when it is false, so the set of
statements it gets right is the *entire* library. The count of correct answers
equals the total number of statements, and

$$95 \cdot a^{\ell} \;\le\; 100 \cdot a^{\ell}$$

holds trivially. The benchmark is met with room to spare.

We can even say what the oracle physically *is*. Since the domain is finite,
the oracle's complete behaviour can be listed as a finite table of
(statement, answer) pairs:

> **Theorem (Everything Is a Table).** Every oracle on a finite bounded
> language is completely described by a finite list pairing each statement with
> its answer.

So on a bounded language, omniscience is not mysterious. It is a filing
cabinet. A colossal one — but a filing cabinet nonetheless.

## The catch nobody mentions

At this point the promise looks too good. If a perfect oracle always exists,
why isn't every hard question already answered?

The answer is a distinction that is easy to state and easy to forget:
**existence is not feasibility.** A table with $26^{100}$ rows exists as a
mathematical object, but no one can build it, store it, or search it. Knowing
that the answers *can be written down* tells you nothing about whether you can
*find* them. Computability, storage, learnability, and complexity are four
different mountains, and clearing one says nothing about the others.

This is the first of our sharply drawn lines: **the perfect oracle exists, but
its existence is a statement about finiteness, not about power.**

## An adversary who rewrites the truth

So far we fixed the semantics first and *then* built the oracle. What if we are
greedier? What if we want *one* oracle, chosen once and for all, that stays 95%
accurate *no matter what the truth turns out to be*?

This is a different promise entirely, and it is a fatal one. Here mathematics
delivers a flat refusal:

> **Theorem (No Universal Oracle).** On any nonempty finite language, there is
> no single oracle that is 95% accurate against every possible semantics.

The proof is a small act of sabotage. Take any oracle you like and let it
commit to its answers. Now an adversary defines the truth *in response*:
wherever the oracle said "yes," the adversary declares the statement false;
wherever it said "no," the adversary declares it true; and where the oracle
abstained, the adversary picks a label that the abstention cannot match. Every
answer the oracle gave is now wrong. Its accuracy against this tailor-made
semantics is not 94% — it is exactly $0\%$.

The lesson is about the *order of the quantifiers*, the most underrated
subtlety in all of mathematics. "For each truth, there is a good oracle" is
true and easy. "There is an oracle good for every truth" is false and
impossible. Swapping the words *for each* and *there is* flips a theorem into
its opposite. An oracle can be a perfect fit for a truth it was built to match,
and utterly helpless against a truth designed to spite it.

## What a diagonal really argues

There is a third temptation: maybe we cannot beat *every* semantics, but surely
we can at least *list* all the possible truth-behaviours, cataloguing them one
by one so that nothing escapes our enumeration.

Here we meet the ghost of Georg Cantor, whose 1891 diagonal argument is one of
the most reused ideas in mathematics. Picture the possible infinite
truth-sequences — each an endless string of yes/no verdicts — arranged as the
rows of an infinite table. Row $0$, row $1$, row $2$, and so on forever.

Now walk down the diagonal and *flip every bit you step on*. At position $k$,
look at what row $k$ says about coordinate $k$, and record the opposite. The
sequence you build this way, the **diagonal jump**, disagrees with row $k$ at
coordinate $k$ — for *every* $k$.

> **Theorem (Diagonal Escape).** For any list of Boolean sequences indexed by
> the natural numbers, the diagonal-flip sequence differs from the $k$-th listed
> sequence at coordinate $k$. Consequently no such list can contain every
> Boolean sequence.

The diagonal jump is a fugitive that no countable catalogue can hold. Whatever
list you propose, it is missing — it was engineered to differ from every entry
you wrote down.

There is a finite echo of the same idea. On a square $n \times n$ table of
yes/no values, flipping the diagonal produces a length-$n$ verdict pattern that
matches none of the $n$ rows:

> **Theorem (Finite Diagonal).** For any $n \times n$ Boolean table, the
> complemented diagonal differs from every one of the $n$ rows, so $n$ rows can
> never realize all $2^n$ possible patterns.

But notice what this finite version does *not* say. It does not say the table
is hard to compute or impossible to know. It only says $n$ rows cannot cover
$2^n$ patterns — a counting fact, visible to the naked eye. The real force of
diagonalization is reserved for the *infinite* arena, where it proves that no
enumeration, however clever, can be complete.

This is the second sharp line: **counting finite objects gives you big numbers;
escaping an infinite catalogue requires diagonalization.** They are different
tools for different jobs, and confusing them is how paradoxes get manufactured.

## The honest scoreboard

It is worth being candid about a modelling choice, because honesty is where
this story separates itself from hype. Our oracles are allowed a third
option — they may answer "yes," "no," or **"I don't know."** Throughout, an "I
don't know" is scored as *wrong*. Abstention earns no partial credit.

That choice matters. Under it, the constant "I don't know" oracle scores zero,
and the adversary above can defeat any fixed oracle completely. A different
scoring rule — one that rewards honest abstention, or penalizes confident
errors more than admitted ignorance — would tell a different quantitative
story. The finite counterexample would survive unchanged; the exact percentages
would not. Stating the scoreboard out loud is part of the mathematics, not a
footnote to it.

## Where the boundary really lies

Step back and the landscape resolves into a clean hierarchy of claims, each
one sharply delimited:

- **Fix the truth, keep it short — omniscience is free.** A finite bounded
  language always has a perfect oracle, and that oracle is just a table.
- **Demand one oracle for all truths — omniscience is impossible.** An adversary
  can always redefine truth to make your fixed oracle wrong everywhere.
- **Try to catalogue all infinite truth-behaviours — you always miss one.** The
  diagonal jump escapes every countable list.
- **On finite square tables — the diagonal still escapes, but only as counting.**
  The deep noncomputable content lives strictly in the infinite case.

The moral is not that knowledge is impossible, nor that it is free. It is that
the words we use to frame a promise — *for a fixed truth* versus *for every
truth*, *finite* versus *infinite*, *exists* versus *can be found* — carry the
entire weight of the claim. Shift one word and a triviality becomes an
impossibility.

## Why this matters beyond the blackboard

These distinctions are not academic pedantry. They are exactly the confusions
that surround modern claims about prediction machines. When a system promises to
answer any question correctly, ask: *for a fixed notion of truth, or for every
possible one?* When it promises to have "seen everything," ask: *a finite corpus,
or an unbounded stream?* When it boasts 95% accuracy, ask: *on which benchmark,
under which scoring of "I don't know"?*

A finite lookup table can be 100% accurate and still be useless, because you can
neither build nor search it. A single fixed predictor can never be robust
against an adversary free to redefine the target. And no countable body of
knowledge, however vast, can enumerate everything — some truth is always
diagonalized out of reach.

The century-old diagonal argument, it turns out, is not a dusty relic. It is a
compass. It tells you precisely where the easy promises end and the impossible
ones begin — and, quietly, it reminds us that the most important mathematics
often lives not in the theorems themselves, but in the exact words that state
them.
