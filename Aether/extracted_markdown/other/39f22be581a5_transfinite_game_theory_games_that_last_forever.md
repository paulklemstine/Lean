# Games That Never End: When Infinity Enters the Arena

*How mathematicians proved that even in games lasting forever, someone must win*

---

## The Longest Game Ever Played

Imagine a game of chess, but with a twist: it never ends. Two players sit across from each other, making moves forever — not for an hour, not for a year, but literally for eternity. At each turn, a player picks a number, any natural number. The first player picks, then the second, then the first again, on and on without end. The result is an infinite sequence of numbers stretching out to infinity. Before the game began, someone wrote down a rule: certain infinite sequences count as "winning" for Player I, and everything else counts as winning for Player II.

Here's the question that has captivated mathematicians for nearly a century: **Must one of the players have a winning strategy?**

This isn't an idle puzzle. The answer touches the deepest foundations of mathematics, connects to the largest objects conceivable in set theory, and reveals a surprising truth about the nature of mathematical proof itself.

## The Zermelo Revolution

The story begins in 1913, when Ernst Zermelo — one of the founders of modern set theory — proved something remarkable about chess. In any finite two-player game with perfect information (no hidden cards, no dice), one player must have a winning strategy, or both players can force a draw. This is Zermelo's theorem, and its proof is beautifully simple: work backwards from the end. If the game lasts at most *n* moves, examine all possible positions at move *n*, then *n-1*, and so on, determining at each step which player can guarantee a win.

But what happens when there is no "last move"? When the game has no endpoint, Zermelo's backward induction has nowhere to start. The game tree isn't just large — it's infinite in depth. You can't work backwards from a position that doesn't exist.

## The Gale-Stewart Breakthrough

In 1953, David Gale and F.M. Stewart confronted this challenge head-on. They studied what are now called *Gale-Stewart games*: two players alternate choosing natural numbers forever, producing an infinite sequence. A predetermined set *A* of "winning sequences" decides the outcome.

Gale and Stewart proved something stunning: if the winning set *A* is "open" — meaning that whenever Player I is destined to win, this is already determined after finitely many moves — then the game is *determined*. One player must have a winning strategy.

The proof introduces a beautiful concept called a *quasistrategy*: instead of prescribing a single move at each position, it narrows the game tree, eliminating bad options while preserving all of the opponent's options. Think of it as pruning a bonsai — you cut away branches that lead to defeat, but you never restrict what your opponent can do. If the pruned tree still contains winning plays through every possible opponent response, you've found a winning strategy.

But Gale and Stewart also discovered something disturbing: using the Axiom of Choice — a standard assumption in mathematics that asserts every collection of nonempty sets has a "choice function" — they could construct a game that is *not* determined. Neither player has a winning strategy. The game is fundamentally undecidable.

## The Axiom of Determinacy: A Bold Alternative

This paradox spawned a radical proposal. What if, instead of the Axiom of Choice, we adopted a different axiom? In 1962, Jan Mycielski and Hugo Steinhaus proposed the **Axiom of Determinacy (AD)**: *every* Gale-Stewart game is determined. No exceptions, no undecidable games. For every possible set of winning conditions, one player must have a strategy that guarantees victory.

AD contradicts the full Axiom of Choice — you can't have both. But AD is consistent with a weaker version called "Dependent Choice," which suffices for most of analysis. And AD has breathtaking consequences:

**Every set of real numbers is measurable.** The pathological "non-measurable sets" that plague measure theory — the Vitali sets, the Bernstein sets — simply cannot exist under AD. This alone makes AD an attractive axiom for analysts.

**The Wadge hierarchy is well-ordered.** Sets of real numbers fall into a beautiful linear hierarchy based on topological complexity. Under AD, this hierarchy is as well-behaved as the ordinal numbers — a structure of stunning regularity.

**Perfect dichotomy.** Under AD, for every game, *exactly* one player has a winning strategy. There are no draws, no ambiguities. The mathematical universe becomes cleaner and more decisive.

## The Bridge to Large Cardinals

Perhaps the most profound discovery in this area is the connection between determinacy and *large cardinal axioms* — axioms asserting the existence of sets so enormous they dwarf the ordinary infinite.

Donald Martin proved in 1975 that every *Borel* game is determined — not just open games, but games at every finite level of the topological hierarchy. His proof required no large cardinal assumptions; it works in standard set theory (ZFC).

But as you climb higher in complexity — from Borel to analytic to projective — the strength of axioms required increases in lockstep with large cardinal axioms:

- **Open determinacy** (Σ⁰₁): Provable in ZF alone. No extra axioms needed.
- **Analytic determinacy** (Σ¹₁): Equivalent to the existence of "sharps" — certain model-theoretic objects — for all reals. Proved by Harrington and Martin in 1985.
- **Projective determinacy**: Follows from the existence of infinitely many *Woodin cardinals*, objects so large that each one implies the consistency of everything below it.
- **Full AD**: Consistent relative to the existence of infinitely many Woodin cardinals with a measurable cardinal above them all.

This correspondence is not a coincidence — it reflects a deep structural connection between the complexity of definable sets of real numbers and the size of the set-theoretic universe needed to analyze them.

## Transfinite Games: Beyond Infinity

Recent work pushes further: what about games that last not just ω (countably infinite) moves, but *transfinitely* many? Games indexed by ordinal numbers — where players make moves not just at positions 1, 2, 3, ... but at positions ω, ω+1, ω·2, and beyond?

These transfinite games open new mathematical territory. A position in such a game is no longer just a finite sequence of moves — it's a function defined on ordinals. The game tree has depth measured not by natural numbers but by ordinals, the mathematical yardstick for "how deep does this well-ordering go?"

The ordinal rank of a game tree — the supremum of successor ranks of its children — provides a precise measure of game complexity. This rank is strictly monotone: every child has rank strictly less than its parent. This simple fact ensures that any analysis proceeding from children to parents must terminate, even when the tree itself is infinite.

The conjecture driving current research is that the consistency strength for determinacy of games of ordinal length ω·n requires exactly (n-1) Woodin cardinals. Each additional "factor of ω" in game length demands one more large cardinal in the set-theoretic universe. If true, this would establish a precise linear correspondence between two seemingly unrelated quantities: combinatorial game length and logical axiomatic strength.

## Why It Matters

Transfinite game theory isn't just abstract mathematics. The ideas permeate computer science (where games model reactive systems and verification problems), economics (where infinite horizon games model ongoing strategic interactions), and logic (where determinacy connects to definability and descriptive set theory).

The Wadge hierarchy, made well-behaved by AD, classifies computational complexity in a way that aligns with topological complexity. Continuous reductions between games — where one game can be "simulated" by another via a continuous function — create a preorder on mathematical complexity itself.

And the connection to large cardinals reveals something philosophically profound: the question "who wins this game?" is entangled with the question "how large is the mathematical universe?" These seem like completely different questions — one about strategy, one about ontology — yet they are mathematically inseparable.

## The View from Infinity

Standing at the intersection of game theory, topology, set theory, and logic, transfinite game theory reveals mathematics at its most interconnected. A simple question — "must someone win?" — leads to the deepest questions about what mathematical objects can exist, how complex sets of real numbers can be, and what axioms our mathematical universe should obey.

The games never end. Neither, it seems, do the mathematical discoveries they inspire.

---

*The research described in this article develops rigorous mathematical structures for infinite and transfinite games, proves determinacy results for clopen games, and formalizes the relationship between the Axiom of Determinacy, the Wadge hierarchy, and large cardinal axioms.*
