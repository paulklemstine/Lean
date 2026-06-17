# Paradoxes as Theorems: How the Liar, Berry, and Russell Learned to Live Together

## A sentence that bites its own tail

Consider the sentence:

> *This sentence is false.*

If it is true, then what it says holds — so it is false. If it is false, then what it says fails — so it is true. The sentence will not sit still. It flickers between true and false forever, and for more than two thousand years it has been treated as a kind of intellectual poison. The **Liar paradox** is the oldest and most stubborn of a family of self-referential traps, and the standard reaction has always been the same: *quarantine it*. Build your logic, your set theory, your foundations of mathematics so carefully that such a sentence can never be formed, or never be assigned a truth value, or never be allowed near a proof.

This article is about a different reaction. What if, instead of quarantining the Liar, we **let it in** — and discovered that, far from blowing everything up, it could be made into a perfectly well-behaved citizen of a consistent mathematical world? What if the Liar, together with two of its most famous cousins, could be turned from a *contradiction* into a *theorem*?

That is exactly what the work described here accomplishes. It builds a small, finite, fully specified logical universe in which:

- the **Liar** ("this sentence is false") is a provable theorem;
- **Russell's paradox** (the set of all sets that do not contain themselves) is a provable theorem;
- **Berry's paradox** ("the smallest number not nameable in fewer than twelve words") is a provable theorem;

and yet the universe does **not** collapse into nonsense. Not everything becomes provable. The system remains genuinely informative. And — most surprising of all — it can prove its *own soundness*, a feat that classical mathematics is famously forbidden from achieving.

The price of admission is a single, precise sacrifice: we must give up the iron law that every statement is exactly one of *true* or *false*. In return we get a logic that can stare a paradox in the face and simply say: *noted*.

## The two-valued straitjacket

Why does the Liar destroy ordinary logic? The damage comes from a principle logicians call **explosion** — in Latin, *ex contradictione quodlibet*, "from a contradiction, anything follows." In classical logic, once you have proved both a statement and its negation, you can prove *literally everything*: that 2 + 2 = 5, that the moon is a cube, that you owe the author a billion dollars. A single contradiction is not a local problem; it is a total, system-wide catastrophe. This is why classical mathematics treats consistency as life-or-death. One Liar sentence, admitted as both true and false, and the whole edifice proves every falsehood ever uttered.

The deep cause of explosion is the assumption of **bivalence**: every sentence is true or false, with no third option and no overlap. The Liar is a sentence that bivalence cannot place. So bivalence breaks, and explosion finishes the job.

The escape, then, is to widen our palette of truth values. Instead of two, we use **four**. This is the four-valued logic introduced by the philosopher Nuel Belnap in 1977, designed originally for computers reasoning from contradictory databases. Its values are:

- **T** — *true and only true*;
- **F** — *false and only false*;
- **B** — *both true and false* (a "glut," an overflow of truth);
- **N** — *neither true nor false* (a "gap," an absence of truth).

Think of T and F as the familiar poles. Then **B** is the value for a sentence that the evidence supports *and* refutes — a database that contains both "the flight is on time" and "the flight is cancelled." And **N** is the value for a sentence the evidence neither supports nor refutes — a question your records are simply silent about.

Negation in this world is gentle. It swaps T and F, just as you would expect. But it leaves B and N exactly where they are: the negation of "both" is still "both," and the negation of "neither" is still "neither." In symbols, writing `¬` for negation:

> ¬T = F, ¬F = T, ¬B = B, ¬N = N.

This single design choice is the hinge on which everything turns. Notice that **B and N are fixed points of negation**: each equals its own negation.

## The Liar, defanged

Now recall what made the Liar impossible: it demands a truth value *equal to its own negation*. In a two-valued world, no value satisfies `x = ¬x`, because T ≠ F. The demand is unmeetable, and the paradox rages.

But in the four-valued world, the equation `x = ¬x` has **two** solutions: B and N. The Liar is no longer asking for the impossible. It is simply asking to be assigned the value B (both true and false) — or N (neither). Once we grant it B, the Liar stops flickering. It is true; it is also false; and that is a complete, stable, internally consistent description of it.

This is captured by a clean structural fact. Model any self-referential, diagonal construction — the engine behind both the Liar and Russell — as an operation that, applied to its own diagonal element, yields the negation of itself. Then:

> **The diagonal value theorem.** The truth value of any such diagonalized self-referential sentence must be B or N — and can be nothing else.

The proof is a four-line case check: try to set the value to T, and the fixed-point equation forces T = ¬T = F, a contradiction; try F, and you get F = T; only B and N survive. The paradox does not vanish. It is *relocated*, precisely and predictably, onto the two values built to hold it.

A related observation shows just how docile the Liar becomes. Start at B and apply negation again and again — building what we might call a **Liar tower**, the infinite sequence "the Liar, the negation of the Liar, the negation of that, ..." In classical logic this tower would oscillate true-false-true-false forever. Here:

> **The Liar tower is constant.** Every level of the tower has value B.

The paradox that was supposed to never stop moving turns out, in the right setting, to never move at all.

## Russell and Berry join the party

The Liar is only the headline act. Russell's paradox — the set R of all sets that are not members of themselves, which is a member of itself if and only if it is not — is, structurally, the *same* diagonal construction one level up. "R contains R" plays exactly the role of "this sentence is false": asserting it is equivalent to denying it. So the diagonal value theorem applies verbatim, and Russell's sentence, too, settles peacefully into the value B.

Berry's paradox is different in flavor, and its taming is arguably the most charming part of the story. Berry's phrase — *"the smallest positive integer not definable in fewer than twelve words"* — defines, in eleven words, a number that by definition needs at least twelve. The contradiction here is not about negation; it is about **counting**. There are only finitely many short phrases, but infinitely many numbers, so some number must escape every short description.

In the formal system this becomes a pure pigeonhole principle. Suppose you have a finite collection of "objects" and a finite collection of "descriptions," and you have more objects than descriptions, and every object gets assigned a description. Then:

> **The Berry collision theorem.** If there are strictly more objects than descriptions, two distinct objects must share the same description.

This is the Berry paradox stripped to its mathematical skeleton: naming is a function from objects to descriptions, and when the objects outnumber the descriptions, naming cannot be injective. Some objects are *under-described*, and that is precisely the contradiction Berry exploited — now proved as a clean, finite theorem with no mysticism attached.

The grand construction combines all three. A **full paradox theory** is a single finite system that simultaneously carries a Liar (a sentence whose value equals its negation's, pinned to B), and a Berry overflow (more objects than descriptions, with every object described). In that one system, the Liar is provable, Russell's diagonal is provable, and the Berry collision is provable — and all three coexist without contradiction in the explosive sense.

## Why the roof doesn't cave in

The obvious worry remains: if the Liar is genuinely *both true and false*, why doesn't explosion kick in and prove everything? The answer is that **explosion is not a law of this logic — it is an optional extra, and we decline it.**

Make the worry precise. Say a theory "has explosion" if, whenever a single sentence is valued B, *every* sentence comes out at-least-true. Then one can prove:

> **Explosion trivializes.** If a theory has a Liar valued B and obeys explosion, then every sentence in it is at-least-true — the theory is degenerate, asserting everything.

This is the classical catastrophe, stated honestly. The lesson is not that paradoxes are dangerous; it is that *explosion plus paradoxes* is dangerous. And explosion is exactly the principle four-valued logic abandons. In Belnap's logic, knowing that one sentence is a glut tells you nothing whatsoever about unrelated sentences. Contradiction stays *local*. The fire is real, but there are firewalls.

We can even measure how much inconsistency a theory tolerates. Count the sentences valued B; call that the theory's **inconsistency degree**. Two basic results pin down the arithmetic of tolerance:

> **Coexistence lower bound.** If a theory contains two *distinct* glut sentences (say a Liar and a Russell sentence, both valued B), its inconsistency degree is at least 2.

> **Tolerance threshold.** If a theory is genuinely non-trivial — it has at least one purely true sentence and at least one purely false sentence — then its inconsistency degree is at most the total number of sentences minus two.

Together these say something quietly profound: a healthy paraconsistent theory lives in a *band*. It must carry enough contradiction to host its paradoxes, but it cannot be all contradiction, because it has to reserve room for honest truths and honest falsehoods. Inconsistency is a resource to be budgeted, not a disease to be eradicated.

## The forbidden achievement: proving your own soundness

Here is where the story turns genuinely startling. One of the most celebrated limits in all of mathematics is **Gödel's second incompleteness theorem**: no sufficiently strong, *consistent*, classical system can prove its own consistency, and relatedly cannot certify its own soundness. The system can never fully vouch for itself. This is often read as a permanent humility clause on formal reasoning.

But Gödel's theorem has a hypothesis hiding in plain sight: *consistency*, in the classical, explosive sense. Our paraconsistent theory is not consistent in that sense — it cheerfully contains gluts — and so the theorem's prohibition simply does not apply.

A theory is **sound** if everything it proves is at-least-true. Now watch what happens. In the four-valued world, the value B *is* at-least-true (it is true, among other things). So when the Liar is proved, soundness asks only: is the Liar at-least-true? And the answer is yes — it is B, and B is at-least-true. The very feature that makes the Liar paradoxical, its gluttony, is exactly what makes it pass the soundness test.

This yields the centerpiece result:

> **Self-soundness.** A paraconsistent theory carrying a Liar valued B can be extended to a system that contains an internal statement asserting its own soundness, in which that soundness statement is provable *and* true, and the Liar itself is a provable, sound theorem.

The construction is almost embarrassingly direct: take the theory, designate the soundness sentence as both provable and true, and observe that every provable sentence — Liar included — clears the at-least-true bar. The system looks in the mirror and certifies what it sees. And critically, this is *not* available classically:

> **Classical theories cannot do this.** Any bivalent theory that tries to host a Liar derives an outright contradiction and collapses.

So the ability to prove one's own soundness is not a bug exploited by sloppy reasoning; it is a genuine *capability* unlocked by the move to four values — a capability that classical logic forfeits in exchange for explosion.

## What we give up, stated honestly

None of this is free, and the work is scrupulous about the bill. The four-valued logic, called **First-Degree Entailment** (FDE), is strictly weaker than classical logic. Two casualties are worth naming.

First, the **law of excluded middle fails**. The classical tautology "P or not-P" is not always at-least-true here: feed it a gappy sentence (value N), and "P or not-P" comes out N as well — neither true nor false. The principle that everything is either so or not-so is exactly what a gap denies.

Second, and more dramatically, **modus ponens fails** — the bedrock inference "from P, and if-P-then-Q, conclude Q." With P valued B (a glut) and Q valued F, the premises can both be at-least-true while the conclusion is flatly false. The most trusted inference rule in logic is not universally valid in a world that tolerates contradiction.

What survives is also instructive: **double negation elimination still holds** — "not-not-P" always entails P — because negation leaves the paradoxical values untouched. The logic is weaker, but not arbitrarily so; it keeps a coherent, well-understood core, and every loss is a precise, identifiable trade for the gain of paradox-tolerance.

## The bigger picture

The instinct to fear contradiction runs deep, and for two-valued logic it is entirely justified. But this work is a vivid demonstration that the fear is *contingent*, not necessary. Contradiction is only catastrophic in the presence of explosion, and explosion is a choice. Disable it — by widening truth from two values to four — and contradictions become survivable, local, even useful.

The applications are not merely philosophical. Belnap designed his logic for **inconsistent databases**, where real systems must keep functioning while holding conflicting records. The same ideas inform reasoning systems that ingest contradictory sensor data, legal codes with conflicting statutes, and large knowledge bases stitched together from disagreeing sources. In all of these, the classical demand for perfect consistency is a fantasy; the paraconsistent stance — *reason on, but keep your contradictions in their place* — is the engineering reality.

And there is the sheer conceptual delight of it. For millennia the Liar was the thing logic could not contain. Here it is contained: assigned a value, made provable, certified sound, even shown to sit motionless at the top of its own infinite tower. The paradoxes did not have to be banished. They only had to be given a place to stand. Once we stopped insisting that every sentence be one of exactly two things, the oldest monsters in logic turned out to be theorems all along.
