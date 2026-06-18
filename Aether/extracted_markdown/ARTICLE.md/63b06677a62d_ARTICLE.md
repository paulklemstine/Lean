# The Staircase With No Bottom Step: How Infinite Counting Proves Things Stop

## A puzzle that should be impossible

Imagine a malicious genie hands you the following game. You hold a giant number — say, written in an exotic shorthand — and at every turn the genie *increases* one part of it while decreasing another. The number jumps around wildly. Sometimes it balloons to astronomical size. Yet the genie promises you that, no matter how cleverly it plays, the game will end after finitely many moves with the number reaching zero.

Your instinct screams that this is a trick. If the number can grow, how can you ever be sure it must eventually hit zero? A process that keeps getting bigger looks like it could run forever.

And yet the genie is telling the truth. There is a single, beautiful idea behind why — an idea that mathematicians have been polishing for a century, and which sits at the crossroads of three seemingly unrelated questions: *How do we count past infinity? When does a computer program halt? And how fast can a function possibly grow?*

This article tells the story of how those three questions are really the same question, wearing three costumes.

## Counting past infinity

Children learn to count: 1, 2, 3, and so on. The "and so on" hides something profound. After every natural number there is always a next one, so the natural numbers never finish. But what if you imagine a point *after all of them*? Mathematicians call that point **ω** (the Greek letter omega). It is the first **infinite ordinal** — a number that comes after every finite number at once.

Counting does not stop there. After ω comes ω + 1, then ω + 2, marching off again. After all of *those* comes ω + ω, which we write ω·2. Keep stacking and you reach ω·3, ω·4, eventually ω·ω = ω², then ω³, and after the entire tower of powers, ω^ω. Push further still and you can form ω raised to ω raised to ω, an infinite tower of exponents. The ordinal sitting at the very top of *that* construction — the limit of ω, ω^ω, ω^(ω^ω), and so on — has a name: **ε₀** ("epsilon-nought"). It is the smallest ordinal you cannot reach by any finite combination of addition, multiplication, and exponentiation starting from ω.

Every ordinal below ε₀ has a unique tidy fingerprint called its **Cantor normal form**: a finite sum of terms, each a power of ω with a whole-number coefficient, written in decreasing order of exponent. For example,

> ω² · 3 + ω · 5 + 7

is a perfectly good ordinal below ε₀, and *every* ordinal below ε₀ looks like this, where the exponents are themselves smaller ordinals written the same way. Because the description is finite and follows strict rules, a computer can store these ordinals exactly and compare any two of them. This computable catalogue of ordinals is the stage on which our whole story plays out.

## The one magic property

Ordinals below ε₀ have one property that makes them worth their weight in gold: **they are well-ordered**. This means there is no infinite strictly decreasing sequence. You cannot find ordinals

> a₀ > a₁ > a₂ > a₃ > ⋯

that keep going down forever. Eventually any descending chain must stop, and the only place it can stop is at zero.

This is obvious for the ordinary counting numbers — you cannot keep subtracting from a pile of pebbles forever. The miracle is that it remains true even for the wild infinite ordinals, where a single "step down" can swap an enormous term for an even more enormous spray of smaller terms. The first formal result in our work states this precisely:

> **No infinite descent.** For any sequence of ordinal notations a₀, a₁, a₂, … below ε₀, it is impossible that every term is strictly smaller than the one before it.

That is the whole engine. Everything else is a consequence.

## From "no infinite descent" to "every program halts"

Here is where the costume change begins. Forget ordinals for a moment and think about any process at all — a board game, an algorithm shuffling data, a chemical reaction, the genie's number game. The process has *states*, and a rule that turns each state into the next one. We ask the eternal question: **does it stop?**

The classical trick of the trade is to attach to every state a *measure of progress* — a quantity that strictly decreases at every step. If your measure is an ordinary counting number, you are done: it cannot decrease forever, so the process must halt. But ordinary numbers are often too crude. Some processes get genuinely more complicated before they get simpler, and no whole-number tally captures that.

The breakthrough is to let the measure be an **ordinal below ε₀** instead of a plain number. Now the measure is allowed to be infinite, and it can decrease in subtle ways — trading one big term for many smaller ones — while still, by well-ordering, being unable to decrease forever. We prove this as a single reusable theorem:

> **Termination by ordinal measure.** Suppose every state x is assigned an ordinal μ(x) below ε₀, and suppose the process's step rule strictly decreases this ordinal whenever it is not already zero. Then, starting from any state, after finitely many steps the measure reaches zero.

Read that again, because it is the heart of everything. It says termination is *not* a special miracle to be re-proved from scratch for every new process. It is **one theorem**, applied to different measure maps. The only creative work left in any particular case is to invent the right ordinal yardstick and check that each step nudges it downward. The well-ordering does all the heavy lifting.

There is an especially clean special case, where the "state" simply *is* an ordinal notation and the process drives it down directly:

> **Self-descent.** If a rule takes every nonzero ordinal notation to a strictly smaller one, then iterating the rule from any starting point reaches zero in finitely many steps.

This is the genie's game laid bare. The genie's number, properly decoded, *is* an ordinal below ε₀. Each move, however much it seems to enlarge the number on the surface, secretly decreases its ordinal value. And ordinals cannot fall forever. The genie cannot lie.

## Two famous games the genie plays

This abstract engine is not a curiosity. Two of the most celebrated "surprisingly terminating" processes in mathematics are exactly the genie's game in disguise.

**The Goodstein sequences.** Take a number, say 4, and write it in "hereditary base 2" — meaning you write it as powers of 2, then rewrite the exponents as powers of 2, and so on, until only 2's appear. Now play this game: bump every 2 up to a 3, then subtract 1. Rewrite in hereditary base 3, bump every 3 to a 4, subtract 1, and continue, raising the base each round. The numbers that result are staggering — they rocket into the billions and far, far beyond almost immediately. Every shred of intuition says they explode to infinity. **They do not.** Every Goodstein sequence, no matter how titanic it grows, eventually crashes all the way back down to zero. The reason is precisely our engine: replace the ever-growing base by the symbol ω, and each Goodstein number becomes an ordinal below ε₀. Bumping the base leaves the ordinal unchanged; subtracting one strictly decreases it. So the ordinal descends, and by well-ordering it must hit zero — dragging the actual number down with it.

**The Hydra game.** Hercules battles a many-headed Hydra, drawn as a branching tree of necks and heads. Each time he chops a head, the Hydra grows *new* heads — sometimes a vast number of fresh ones sprouting from a lower node. It seems unwinnable; cutting one head spawns dozens. But assign each Hydra an ordinal rank below ε₀, built from the shape of its tree, and every chop — regrowth and all — strictly *lowers* that rank. By the same engine, the rank cannot descend forever, so Hercules always wins, against any Hydra, no matter how he chops. The monster's regrowth is sound and fury; the ordinal bookkeeping is destiny.

Both legends, so different on the surface, are the *same single theorem* applied to two different ordinal yardsticks. That unification is the quiet triumph here.

## The third costume: how fast can a function grow?

Our story has one more face, and it turns the whole thing inside out. The well-ordering of ordinals tells us processes *stop*. But it says nothing about *how long they take*. The answer to that question gives birth to some of the fastest-growing functions in all of mathematics: the **fast-growing hierarchy**.

The hierarchy is a family of functions Fₐ, one for each ordinal a, defined by climbing the ordinals:

- **Base.** F₀(n) = n + 1. The slowest possible nontrivial growth: just add one.
- **Successor step.** F_{a+1}(n) is F_a applied to n a total of n times over. In other words, take the previous function and iterate it n times.
- **Limit step.** At an infinite ordinal, you pick a "fundamental sequence" of smaller ordinals climbing up to it, and at input n you use the n-th one.

Watch what iteration does. F₀ adds one. Iterating addition gives doubling, so

> **F₁(n) = 2n.**

For instance F₁(3) = 6. Iterating doubling n times multiplies by 2 each time, giving

> **F₂(n) = n · 2ⁿ.**

For instance F₂(2) = 2 · 4 = 8. These are gentle. But the pattern is a slingshot. F₃ already grows like a tower of exponentials. By the time you reach F_ω — the first function indexed by an *infinite* ordinal — you have a function that outpaces every "primitive recursive" function, the entire class of functions built from ordinary loops. F_ω is essentially the Ackermann function, the textbook example of a computable function too fast to be tamed by simple iteration. And the climb continues all the way up to ε₀, where F_{ε₀} grows so fast that *no* proof system of ordinary arithmetic can prove it is even well-defined.

The crucial word is **effective**: despite their cosmic growth rates, these functions are completely computable. Given concrete inputs, a machine can grind out the exact answer. Our work pins this down with kernel-checked values — the machine confirms, with no hand-waving, that F₁(3) = 6 and F₂(2) = 8. Small numbers, but they certify that the entire towering hierarchy rests on solid, executable ground.

## Why the three faces are one

Step back and the unity snaps into focus.

- **Well-ordering** is the structural fact: ordinals below ε₀ cannot descend forever.
- **Termination** is its dynamical shadow: any process measured by such an ordinal must halt.
- **The fast-growing hierarchy** is its quantitative echo: it measures *how long* such descents can take, and the answer reaches functions of unimaginable size.

The same ε₀ that bounds the catalogue of ordinals also marks the exact frontier of what ordinary arithmetic can prove. Goodstein's theorem and the Hydra game are true, but — astonishingly — they cannot be proved using only the axioms of elementary number theory. To prove them you *need* the well-ordering of ε₀, which lives just beyond arithmetic's reach. That is why these innocent-looking games about numbers and monsters are landmarks in the foundations of mathematics: they are concrete, tangible facts whose truth secretly depends on counting past infinity.

## The reusable engine

Perhaps the most practical lesson is the most modest one. For decades, each of these terminating processes was proved to halt by its own dedicated, intricate argument. What this work makes vivid is that they need not be. There is one theorem — *strictly decrease an ordinal below ε₀ and you must reach the bottom* — and every individual result is a one-line application of it, given the right ordinal measure.

That is the spirit of good mathematics: not a museum of separate miracles, but a single engine that, once built, powers them all. The genie's game, Goodstein's exploding numbers, Hercules and his Hydra, the unfathomable Ackermann function — all turn on the same humble truth that a staircase descending through the ordinals, however strange its steps, has no infinite way down. Sooner or later, you reach the ground.
