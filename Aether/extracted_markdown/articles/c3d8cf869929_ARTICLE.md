# Playing Against Infinity: How a Mortal Player Can Outlast Eternity

*How long can a finite being survive against an opponent with infinite resources? The answer lies in a beautiful trick called the diagonal argument—and it takes us far beyond the infinite.*

---

When we think about games, we usually imagine them ending. Chess matches conclude with checkmate or a draw. Soccer games end with a whistle. Even marathon Monopoly sessions eventually terminate when someone flips the board.

But mathematicians have long wondered: what happens when a game has no time limit? What if two players could potentially play *forever*?

The answer opens a door into one of the most mind-bending corners of mathematics—a place where infinity comes in sizes, where you can count past the uncountable, and where a mortal player with limited foresight can force a game to last longer than you might ever imagine possible.

## The Setup: Mortal vs. Eternity

Imagine two players sitting across from each other. One is **Mortal**—a clever strategist, but fundamentally limited. Mortal can plan ahead, but must commit to a complete game plan before the first move. The other is **Eternity**—an opponent with unlimited computational power, who can respond to any situation with any natural number.

Here's how the game works: At each round, Eternity issues a challenge—any natural number it chooses. Mortal's pre-committed strategy determines the response. If the strategy runs out of responses, the game ends and Mortal loses.

The question is deceptively simple: *How many rounds can Mortal guarantee to survive?*

If Mortal picks a simple strategy—say, "always respond with zero"—then the game lasts exactly one round regardless of what Eternity does. A strategy that goes five levels deep survives exactly five rounds. Nothing surprising so far.

But here's where it gets interesting.

## The Diagonal Trick

What if Mortal's strategy is smarter? Instead of committing to a fixed depth, what if Mortal says: "Whatever number Eternity picks first, I'll have a response that survives *at least that many* additional rounds"?

This is possible! Mortal constructs what mathematicians call a **diagonal strategy**: Eternity picks a number n on the first move. Mortal's strategy then branches into a sub-strategy of depth n. If Eternity picks 3, Mortal can survive 3 more rounds. If Eternity picks a million, Mortal survives a million more rounds.

The remarkable consequence: there is no finite number of rounds that captures how long this game can last. For any number you name—a trillion, a googol, Graham's number—Mortal's diagonal strategy can survive at least that many rounds. The game's potential duration isn't any finite number at all.

It's *omega*—the first infinite ordinal.

## Beyond Infinity: Ordinal Numbers

To understand what "omega" means here, we need one of the great inventions of 19th-century mathematics: Georg Cantor's **ordinal numbers**.

Ordinary counting goes 1, 2, 3, ... and never stops. But Cantor asked: what comes *after* all the natural numbers? His answer: omega (ω), the first infinite ordinal. It's not the biggest number—it's what you get when you've "completed" the process of counting through all natural numbers.

But the counting doesn't stop at omega. After ω comes ω + 1, then ω + 2, and so on. Eventually, you reach ω + ω, which is ω · 2. Keep going: ω · 3, ω · 4, ... and the limit of all those is ω · ω, written ω².

This is exactly the landscape of the Mortal-Eternity game. The diagonal strategy achieves omega. But can Mortal do better?

## Stacking Infinities

The key insight is **composition**: you can stack diagonal strategies on top of each other.

First, build a strategy of depth ω (the diagonal trick). Then build another copy. Then a third. Stack n copies together, and you get a strategy of depth ω · n—omega times n.

But here's the clever part. You don't have to commit to a fixed number of copies. Use the diagonal trick *again*: let Eternity's first choice determine how many omega-length strategies to stack!

If Eternity picks 1, stack one copy (depth ω). If it picks 5, stack five copies (depth ω · 5). If it picks a billion, stack a billion copies.

The result? A strategy whose depth is the supremum of ω · 1, ω · 2, ω · 3, ... which is ω · ω = ω². Omega squared.

Mortal has achieved a game whose potential duration is the square of infinity.

## The Pattern of Transcendence

This is not the end. The same trick works again and again. Stack ω² strategies using the diagonal argument, and you get ω³. Stack those, and you get ω⁴. The pattern continues: ω⁵, ω⁶, ω⁷...

Each level uses the same fundamental insight: *the diagonal argument turns a family of strategies indexed by natural numbers into a strategy whose value is the supremum of the family*. Since the supremum of all ω^n · k (for k = 1, 2, 3, ...) is ω^(n+1), each application of the diagonal trick bumps us up one level in the ordinal hierarchy.

This is not just a mathematical curiosity. It reveals something deep about the structure of computation itself.

## Connections to Computing Beyond Time

In 2000, logicians Joel David Hamkins and Andy Lewis introduced the **Infinite Time Turing Machine**—a theoretical computer that can run for transfinitely many steps. Like an ordinary computer, it reads and writes symbols on a tape. But at step ω (after all finite steps are complete), it takes the limit of its tape contents and keeps computing.

The connection to our game is direct: each round of the Mortal-Eternity game corresponds to one step of computation. A strategy tree of rank ω corresponds to a computation that reaches the first limit stage. A tree of rank ω² corresponds to a computation that reaches ω · ω steps.

The ordinal rank of a strategy tree is *exactly* the computation time of the corresponding transfinite process. The diagonal argument that lets Mortal survive ω rounds is the same diagonal argument that lets a transfinite computer surpass finite computation.

## What Mortal Can Never Achieve

For all of Mortal's cleverness, there are limits. Every strategy tree is built from natural-number branching, which means its rank is a countable ordinal. Mortal can never reach the first *uncountable* ordinal, ω₁.

Moreover, Mortal's strategy tree is well-founded—every play through it eventually terminates. The transfinite ranks measure the *potential* of the tree (the longest possible play), not the guaranteed outcome. Against an adversarial Eternity that deliberately minimizes game length, Mortal's guaranteed survival is much shorter.

This gap between potential and guarantee is itself a deep mathematical phenomenon, connected to the distinction between open and closed games in descriptive set theory.

## The Universal Question

An intriguing conjecture remains open: can Mortal achieve *every* countable ordinal, or only those in a specific family?

The constructions we've verified—ranks of n, ω, ω · n, ω²—follow a regular pattern. The general construction for ω^n and beyond exists in principle. But the conjecture that every ordinal below ω^ω is achievable requires a different kind of argument: one that decodes ordinals in Cantor Normal Form and builds the corresponding strategy tree.

If true, this would mean that the Mortal-Eternity game captures the full richness of countable ordinal arithmetic—every ordinal corresponds to a specific game strategy. If false, the "gaps" would reveal new structure in the ordinal hierarchy itself.

## The Deeper Lesson

What makes the Mortal-Eternity game profound is not its technical complexity but its conceptual clarity. A finite being, faced with an infinite adversary, can exploit the *structure* of infinity itself—using diagonal arguments to transcend any fixed bound.

This is the essence of Cantor's original insight about the infinite: infinity is not a single monolithic concept but a richly structured landscape, with different levels, operations, and relationships. The Mortal-Eternity game makes this structure tangible and concrete.

In a sense, Mortal's strategy mirrors our own situation as finite beings trying to understand an infinite universe. We can never grasp infinity directly, but by encoding it—in mathematics, in computation, in game strategies—we can navigate its structure with surprising precision.

The infinite is not the enemy of the finite. It is, in the hands of a clever player, an inexhaustible resource.

---

*This article is based on research formalizing transfinite game theory using ordinal analysis and strategy tree constructions, with connections to infinite time computation and game-theoretic values.*
