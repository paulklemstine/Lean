# Playing Chess Against God: How Long Can a Mortal Survive?

*Imagine a game where your opponent can see infinitely far ahead. You can only plan a few moves at a time. How long can you possibly last?*

---

In the summer of 1936, Alan Turing imagined a machine that could compute anything computable. That machine — now bearing his name — transformed mathematics, spawned computer science, and ultimately gave us the digital age. But Turing's machine had a limitation: it could only run for a finite number of steps. What if you removed that limitation?

In the decades since, mathematicians have explored "supertask" computation — machines that can perform infinitely many operations. These aren't science fiction: they are precise mathematical objects with well-defined properties. The most influential is the *Infinite Time Turing Machine* (ITTM), conceived by Joel David Hamkins and Andy Lewis in 2000. An ITTM can compute through all the natural numbers and keep going — through ω steps, through ω² steps, through ordinal after ordinal of transfinite time.

Now imagine pitting a finite being against such a machine in a game. You — *Mortal* — can think ahead only finitely many steps. Your opponent — *Eternity* — has the power of transfinite computation. How long can you survive?

## The Survival Question

This question might seem hopeless. Surely an opponent with infinite computational power would crush a finite player immediately? The answer turns out to be surprisingly subtle — and it reveals deep connections between game theory, computability theory, and the arithmetic of infinity.

The key insight is this: Mortal doesn't need to play a single fixed strategy. Mortal can *choose* a strategy before the game begins, and different games allow different choices. For any specific number of rounds — say, a million — Mortal can pick a strategy tailored to survive that many rounds. For two million rounds, Mortal picks a different strategy. For a billion, yet another.

No single strategy works forever. But the *collection* of all these finite strategies has a remarkable property: its supremum — the limit of all achievable survival durations — is ω, the first infinite ordinal.

## What Is ω, Really?

Ordinal numbers are the mathematician's way of counting beyond infinity. The natural numbers 0, 1, 2, 3, ... go on forever, but they never reach infinity. The ordinal ω is what comes *after* all of them — the first number bigger than every natural number.

It might seem like a technicality, but ω has a concrete meaning in our game. Saying that Mortal's survival ordinal is ω means: *for any finite number n, Mortal has a strategy that survives at least n rounds*. No strategy works for infinitely many rounds, but there is no finite limit either.

Think of it like running. You might not be able to run forever, but if someone challenges you to run a mile, you can do it. Ten miles? You can train for that too. A marathon? A hundred marathons? For any finite distance, you can (in principle) find a way. The supremum of all finite distances is infinite — even though no single run is.

## The Sharp Dichotomy

The most striking result in this theory is the *sharp dichotomy theorem*. It says: for any player in this kind of game, exactly one of two things is true:

1. **There exists a finite ceiling**: some number k such that Mortal cannot survive more than k rounds, no matter what strategy is chosen. In this case, the survival ordinal is just a finite number — less than ω.

2. **No finite ceiling exists**: for every n, there is a strategy surviving n rounds. In this case, the survival ordinal is *at least* ω.

There is nothing in between. You either have a hard cap or you don't. If you don't, you've broken through to infinity.

This is not a vague philosophical claim. It is a precisely stated and rigorously proven mathematical theorem. The proof uses the structure of *survival profiles* — mathematical objects that encode which survival durations are achievable — and shows that the downward-closure property forces a binary outcome.

## Nondeterminism: The Power of Choice

The story doesn't end at ω. What happens if Mortal gets to make *nondeterministic* choices — essentially, if Mortal can hedge bets?

In the simplest model, sequential composition lets Mortal play one strategy after another. If Mortal plays a strategy that survives a rounds, then switches to one that survives b rounds, the total survival is a + b. Composing k full strategies gives another full strategy — and the survival ordinal remains ω.

But something more interesting happens with *family profiles*: Mortal gets to pick from an indexed collection of strategies. The ascending family — where strategy k can survive k rounds — illustrates this beautifully. No individual strategy achieves ω, but the family as a whole does, because for any target n, Mortal just picks strategy n.

Going deeper, *nested families* stack this construction. Level 0 is a single full profile. Level 1 is a family of full profiles. Level 2 is a family of families. Each level is still full — every nested family can survive any finite number of rounds — and each has survival ordinal at least ω.

The nesting depth corresponds to levels of the *Infinite Time Turing Machine hierarchy*. An ITTM at level d performs ω^d computation steps. The same ordinals appear in the survival hierarchy: d levels of nondeterministic composition correspond to ω^d survival.

## The ITTM Connection

This correspondence is the deepest result in the theory. It says: the computational power of transfinite machines is mirrored by the survival power of nondeterministic strategies.

An Infinite Time Turing Machine runs through the ordinal numbers. At each successor step, it operates like a normal Turing machine. At *limit* steps — when infinitely many previous steps have accumulated — it takes a special action: each cell of the tape is set to the limit superior of its previous values.

These limit transitions are the machine's "infinite power moves." One limit transition gives it ω computation steps. Two give it ω·2. And d levels of limit transitions give it ω^d steps.

The survival hierarchy parallels this exactly. Mortal with no nondeterminism is like a standard Turing machine: finite computation, finite survival. Mortal with one level of nondeterministic choice (a family of strategies) is like an ITTM with one limit transition: survival ordinal ω. Each additional level of nesting adds another limit transition.

## What Mortal Cannot Do

There are hard limits. No amount of *countable* nondeterminism lets Mortal reach ω₁, the first uncountable ordinal. The hierarchy is strict: k levels of nondeterminism give ω^k, never more. And without nondeterminism, any single bounded strategy gives only finitely many rounds.

These boundaries are as important as the achievements. They tell us where the walls are in the landscape of transfinite computation.

## Why It Matters

This theory connects three fundamental areas of mathematics:

**Game theory** asks: in a two-player game, who can win, and how? The Mortal-Eternity framework adds a new dimension — asymmetric computational power — and shows how game-theoretic outcomes are governed by ordinal arithmetic.

**Computability theory** asks: what can be computed, and how fast? The ITTM connection shows that survival ordinals are a natural measure of transfinite computational complexity.

**Set theory** provides the ordinal numbers that serve as the currency of both game values and computation lengths. The sharp dichotomy theorem is a statement in the spirit of descriptive set theory — a clean structural result about definable objects.

But perhaps the most captivating aspect is the philosophical one. In the game against Eternity, Mortal cannot win. But Mortal need not lose quickly. By choosing strategies wisely — by exploiting the full range of finite computation — Mortal can delay death for transfinitely long.

The game against death is unwinnable. But it can be played with extraordinary skill. And the mathematics of that skill turns out to be exactly the mathematics of infinity itself.

---

*The author's research on asymmetric computation games introduces the survival profile framework and proves sharp ordinal bounds connecting game theory to Infinite Time Turing Machines. The results are formalized as machine-verified mathematical proofs.*
