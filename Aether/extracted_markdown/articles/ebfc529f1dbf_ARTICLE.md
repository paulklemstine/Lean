# Dreaming in Three Colors: A Logic Where Contradictions Live and the Sky Doesn't Fall

Imagine you are asleep, and in the dream you are standing in a doorway that is, at the same time, *open* and *closed*. You walk through it anyway. The dream does not crash. The world does not dissolve into a meaningless smear in which every statement is simultaneously true. You simply note the impossible door, shrug in the way only dreamers can, and continue.

This is a perfectly ordinary experience — and it is also a scandal for classical logic.

Classical logic has a rule, beloved since Aristotle and weaponized in the Middle Ages, called *ex contradictione quodlibet*: "from a contradiction, anything follows." Latin scholars liked to dramatize it. Grant me that 0 = 1, and I will prove that you are the Pope. The argument is short and airtight, and that is exactly the problem. It means a single contradiction anywhere in your beliefs is a logical nuclear weapon: it doesn't just blow up the contradiction, it blows up *everything*. Once you believe one impossible thing, classical logic forces you to believe all things.

Most of the time, we never notice. We keep our beliefs tidy enough to avoid contradictions. But "most of the time" is doing heavy lifting. Real databases hold conflicting records. Legal codes contain clauses that contradict each other. Scientists held contradictory theories of light for decades and still made the right predictions. And every night, billions of human brains run on dream logic, hosting impossible objects without exploding into nonsense.

So here is a question worth taking seriously: **can we build a rigorous, mathematical logic in which a contradiction is just a fact you note and step around — not a bomb that destroys reasoning?**

The answer is yes, and this article is the story of one such logic, worked out down to the last detail and checked for absolute correctness. It is called the **Logic of Paradox**, and it has exactly three colors.

## Three colors instead of two

Classical logic paints every statement one of two colors: **true** or **false**. The Logic of Paradox — first proposed by the philosopher Graham Priest in 1979 — adds a third.

- **ff** — *false only*. The statement is plain false, nothing more.
- **tt** — *true only*. The statement is plain true, nothing more.
- **bb** — *both*. The statement is true **and** false at once. This is the dream door. We call such a value a **glut**: an impossible object the logic is willing to hold in its hand.

Two of these colors — **tt** and **bb** — count as "good enough to act on." We say they are **designated**: if a statement is true-only or both-true-and-false, you may assert it, build on it, walk through it. Only pure falsehood, **ff**, is undesignated. In a slogan: *a glut is still assertible, because part of it is true.*

That single design decision — letting "both" be a usable answer — is the whole revolution. Everything else flows from how the three colors combine.

The combination rules are beautifully simple if you lay the colors out on a ruler, ordered from least-true to most-true:

```
   ff   <   bb   <   tt
 (false) (both) (true)
```

- **AND** (conjunction) takes the *minimum* — the more-false of its two inputs. "Open AND closed" is only as true as its weaker half.
- **OR** (disjunction) takes the *maximum* — the more-true of its inputs.
- **NOT** (negation) flips the two ends, **ff ↔ tt**, but it *fixes the middle*: the negation of a glut is still a glut. This is the deep move. If a door is both open and closed, then "the door is not open" is *also* both true and false. Impossibility, once admitted, is stable under denial.

That is the entire engine. Three colors, a ruler, min, max, and a flip that leaves the middle alone. From here, every surprising result is forced.

## The laws survive, but the explosions don't

Here is the first delightful shock. You might assume that a logic tolerant of contradictions must *abandon* the great classical laws — the Law of Excluded Middle ("either P or not-P") and the Law of Non-Contradiction ("not both P and not-P"). It does not. Both laws survive completely intact.

**The Law of Excluded Middle holds.** Take any statement P and form "P or not-P." Whatever color P has, this disjunction always comes out designated. If P is true-only, the disjunction is true. If P is false-only, then not-P is true, so the disjunction is true. And if P is the glut **bb**? Then not-P is also **bb**, and "bb or bb" is **bb** — which is designated. Every single case lands on an assertible value. The law never fails.

**The Law of Non-Contradiction holds too.** "Not both P and not-P" is also designated for every coloring of P. Even at the glut: "P and not-P" becomes "bb and bb," which is **bb**; negating it gives **bb** again — still designated. So even the principle that forbids contradictions is, itself, *upheld*.

This is the elegant paradox at the heart of the Logic of Paradox: **the law of non-contradiction is valid, and yet contradictions are satisfiable.** How can both be true? Because there is a razor-sharp distinction the logic insists on — the distinction between a *law* and an *inference*.

A **law** is a single statement that always comes out true. "Not both P and not-P" is such a statement; it is always designated. But an **inference** is a *license to move* from premises to a conclusion: "given these, you may conclude that." And it is the explosive inference — *from a contradiction, conclude anything* — that the Logic of Paradox quietly kills.

**Explosion fails.** Suppose you believe P, and you also believe not-P. In classical logic you are now entitled to conclude any statement Q whatsoever. Here you are not. The reason is a concrete countermodel: color P with the glut **bb** and color some unrelated Q with **ff**. Then P is designated (it's a glut, partly true), not-P is designated (still a glut), but Q is plainly false. The premises are all assertible; the conclusion is not. The inference is broken — exactly as we wanted. The dream door does not make you the Pope.

This is what it means for a logic to be **paraconsistent**: it can carry a contradiction locally without that contradiction leaking out to poison everything. The bomb has been defused, but the laws are still on the books.

## Even modus ponens gives way

If you have studied any logic, you know *modus ponens*: from "P" and "if P then Q," conclude "Q." It feels untouchable, the very heartbeat of reasoning. In the Logic of Paradox, with implication defined the usual way as "not-P or Q," even this falters — and the failure is instructive.

Color P with the glut **bb** and Q with **ff**. Then P is designated. What about "if P then Q," i.e. "not-P or Q"? Not-P is **bb**, Q is **ff**, and "bb or ff" takes the maximum, which is **bb** — designated. So both premises are assertible. Yet Q is **ff**, undesignated. Modus ponens, applied through a glut, does not deliver its conclusion.

The lesson is not that reasoning is hopeless. It is that *material implication* — implication built out of "or" and "not" — is too weak to carry inference across an impossible object. The contradiction has to be paid for somewhere, and here the price is the reliability of this one inference rule. (Designing a stronger, glut-proof conditional is one of the live frontiers of the field.)

## When you stop dreaming, classical logic returns

A logic that *only* tolerated chaos would be useless. The real test is whether it knows how to behave when there is nothing to tolerate. The Logic of Paradox passes beautifully.

Call a situation a **glut-free valuation** if no atomic statement is colored **bb** — every basic fact is plainly true or plainly false, no impossible doors anywhere. The claim is that in any such situation, *no compound statement can become a glut either*. You cannot manufacture an impossible object out of ordinary ones: min of two non-gluts is a non-glut, max of two non-gluts is a non-glut, and the negation of a non-glut is a non-glut. By a clean induction over how formulas are built, gluts simply never appear.

And the moment gluts are absent, the third color is dead weight, and the logic snaps back to ordinary two-valued reasoning. In particular, **no statement and its negation are ever both designated** in a glut-free world: contradiction becomes genuinely impossible again, and full classical logic is restored. The Logic of Paradox is not a rival to classical logic — it is a *strict superset* that contains classical logic as the special case where nobody is dreaming.

## The real prize: a logic that can change its mind

So far the Logic of Paradox is tolerant but a little timid: by refusing the explosive inference, it also refuses some inferences we'd genuinely like to keep. Priest's refinement — the **minimally-inconsistent** version, often written **LPm** — is where the story becomes genuinely deep, because it introduces something almost no classical system can do: **the ability to retract a conclusion in the light of new evidence.**

The idea is this. When you reason from a set of beliefs, you should not assume the world is *more* paradoxical than your beliefs actually force it to be. Among all the colorings that make your premises assertible, prefer the ones with the *fewest gluts*. Believe in as few impossible objects as you can get away with. Only conclusions that hold across all these **minimally paradoxical** pictures count as genuine consequences.

This sounds like a small bookkeeping tweak. It has a spectacular effect.

Start with two beliefs: **P**, and **if P then Q**. What are the least-paradoxical ways to make both assertible? You can keep everything glut-free: make P true-only and Q true-only. No gluts needed. And across all such minimal pictures, Q comes out true. So from {P, if P then Q}, the minimal logic *does* conclude Q. Modus ponens is recovered, exactly when no contradiction forces us off the rails. Good.

Now add one more belief to the pile: **not-P**. You now hold P and not-P simultaneously — an outright contradiction. To make *both* P and not-P assertible, the logic is *forced* to color P with the glut **bb**; there is no glut-free escape this time, because the contradiction is now baked into the premises. And once P is **bb**, the implication "if P then Q" reads "not-P or Q" = "bb or Q," which is already designated *no matter what color Q has.* Q is off the hook. There is now a perfectly minimal picture in which Q is false. So Q is **no longer a consequence.**

Read that again, because it is the whole point. With the beliefs {P, if P then Q}, the logic concludes **Q**. Add the new information **not-P**, and the logic *withdraws* that conclusion. **Q is retracted.**

This property has a name: **non-monotonicity**. Classical logic is *monotone* — adding premises can only ever add conclusions, never remove them. Once proved, always proved; classical reasoning can never take anything back. But human reasoning, scientific reasoning, legal reasoning, and the reasoning of any robot that has to survive in a messy world are all relentlessly non-monotone. We conclude "the bird flies," then learn "the bird is a penguin," and we *retract*. The minimally-inconsistent Logic of Paradox captures this withdrawal precisely, and — crucially — it does so *as a consequence of how it handles contradictions*, not as a bolt-on. Contradiction tolerance and the ability to change your mind turn out to be two faces of the same coin.

## A hidden bridge to tropical mathematics

There is a final twist, and it reaches across to a corner of mathematics that looks, at first glance, utterly unrelated.

Look again at the combination rules: **AND is min, OR is max.** Replace ordinary addition and multiplication of numbers with **max and min**, and you have stepped into what mathematicians call **tropical** (or **min-plus / max-plus**) algebra — the strange arithmetic where "adding" two things means taking the larger and "multiplying" means taking the smaller. Tropical algebra is not a curiosity; it is the native language of shortest-path problems, scheduling, optimization, and the geometry of networks.

The three truth values, under OR-as-max and AND-as-min, form precisely such a structure: a **commutative idempotent semiring**. "Idempotent" means combining something with itself changes nothing — "P or P" is just P, "P and P" is just P — which is exactly the law that makes tropical arithmetic tick (max of a number with itself is that number). Pure falsehood **ff** plays the role of zero (the identity for OR); pure truth **tt** plays the role of one (the identity for AND); and the two distribute over each other just as multiplication distributes over addition.

There is even more structure. The set of *designated* values, **{bb, tt}**, behaves like a **prime filter** — a notion algebraists prize. A conjunction is designated exactly when *both* parts are; a disjunction is designated exactly when *at least one* part is. These are precisely the defining conditions of a prime filter, and they are the algebraic shadow of the everyday rules "an AND is assertible only if both halves are" and "an OR is assertible if either half is."

Why does this matter? Because it means questions about *paraconsistent belief* — when is a tangle of partly-contradictory statements collectively assertible? — can be translated into questions about *solving min-max systems*, the very systems tropical mathematics was built to solve. The logic of dreams and the algebra of shortest paths turn out to be the same mathematics wearing two costumes. A theorem about stable states of a tropical system becomes a theorem about stable belief states under repeated revision; an eigenvalue in min-plus algebra becomes a fixed point of an iterated reasoner. Two fields that grew up in different centuries, for entirely different reasons, meet on a chain of three colors.

## Why build such a thing?

It would be easy to file all this under "philosophical entertainment." That would be a mistake.

Every system that must reason from real, human-supplied information eventually meets a contradiction it cannot simply delete: a sensor that disagrees with another sensor, a regulation that conflicts with another regulation, a knowledge base assembled from sources that were never asked to agree. A classical reasoner, confronted with such a contradiction, is in principle entitled to conclude *anything* — which is to say, it has stopped being a reasoner at all. The Logic of Paradox offers a disciplined alternative: localize the contradiction, keep the lights on everywhere else, prefer the least-paradoxical reading of what you've been told, and stand ready to take back any conclusion the moment new evidence forces a contradiction into the open.

That is not a description of a broken logic. It is a description of *thinking* — careful, revisable, contradiction-surviving thinking, of the kind we do every waking hour and every dreaming night.

The dream door is both open and closed. You walk through it. The world holds together. Now we know, exactly and provably, why it can.
