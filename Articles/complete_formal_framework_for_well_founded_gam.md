# The Games That Never End — And the Numbers That Measure Them

## How mathematicians discovered that infinite games and counting numbers are secretly the same thing

*By the Harmonic Research Team*

---

In the summer of 1935, a young German mathematician named Gerhard Gentzen sat in his office in Göttingen, wrestling with one of the deepest questions in the foundations of mathematics. He wanted to prove that ordinary arithmetic — the mathematics of addition, multiplication, and the counting numbers — was free of contradictions. To do so, he needed to reach beyond the finite and grasp something called ε₀, a number so large that raising infinity to the power of itself, over and over again, still cannot reach it.

What Gentzen discovered was remarkable: this single number, ε₀, marks the exact boundary of what arithmetic can prove about its own consistency. Below ε₀, everything is provably well-ordered. At ε₀ and beyond, arithmetic loses its grip.

Nearly a century later, researchers have found that Gentzen's mysterious number arises naturally from something far more concrete: games.

## Every Game Has a Number

Consider any game where two players alternate turns and every play must eventually end — no infinite loops allowed. Chess (on a finite board with the 50-move rule) qualifies, as do checkers, Go, and thousands of abstract strategy games studied by mathematicians.

Every position in such a game has a natural "depth number" — a measure of how far the game can possibly continue from that point. A position where no moves are available has depth 0. A position where every move leads to depth 0 has depth 1. And so on, building upward.

For finite games, these depth numbers are ordinary counting numbers: 0, 1, 2, 3, and so forth. But when mathematicians began studying infinite games — games on infinite boards, with infinitely many possible moves — they discovered that the depth numbers must extend beyond all finite numbers into the *transfinite*.

The first transfinite number, denoted ω (omega), is the depth of a game position that can lead to positions of depth 0, 1, 2, 3, or any finite number, but where every play eventually terminates. Imagine a game where one player chooses any finite number *n*, and then both players play a game of depth *n*. The depth of this starting position is ω — larger than any finite number, but still well-defined.

From ω, the hierarchy continues: ω + 1, ω + 2, ..., ω·2, ..., ω², ..., ω^ω, ..., building through ever more elaborate transfinite ordinals. Each one measures the depth of some specific game position.

## The Universal Realization Theorem

The first major result of our research establishes something that might seem obvious but is surprisingly deep: *every* ordinal number can be realized as the depth of some game position. Not just the small ones, or the countable ones, but *every* ordinal in the entire transfinite hierarchy.

The proof is constructive. Given any ordinal α, we build the *canonical game* on α: positions are the ordinals up to α, and from any position β, a player can move to any position γ less than β. The depth of position β in this canonical game is exactly β.

This means that ordinal numbers and game values are *the same thing*, viewed from two different angles. Ordinals arise from the abstract theory of well-ordered sets; game values arise from the concrete theory of combinatorial games. The Bridge Theorem, as we call it, shows these are not merely analogous — they are identical.

## Strategic Depth: When Choices Don't Matter

Not all games of the same depth are equally interesting. Consider two games, both with depth ω:

In the first game, at every position, the player must make a genuine choice between two or more moves, each leading to radically different continuations. This is a game rich in strategy.

In the second game, at every position, there is exactly one available move. The player has no choice at all — the game plays itself. This game has depth ω (it runs for ω steps), but its *strategic depth* is zero.

We formalized this distinction through the concept of *forced positions* — positions where at most one move is available. A game is "strategically trivial" if every position is forced. Such games have well-defined depth (which can be any ordinal) but no genuine strategic content.

The depth spectrum of a position — the set of all depths achievable by positions reachable from it — provides a richer picture of the game's internal structure. We proved that the depth spectrum is always bounded by the game value, establishing a fundamental constraint on what game structures are possible.

## The ε₀ Connection

This brings us back to Gentzen's number ε₀. In the ordinal hierarchy, ε₀ is defined by an extraordinary property: it is the smallest number that satisfies the equation ω^ε₀ = ε₀. Raising omega to the power of ε₀ gives back ε₀ itself — a fixed point of exponentiation.

To understand how large this is, consider: ω^ω is already enormous, being the supremum of ω, ω², ω³, and so on. Then ω^(ω^ω) is vastly larger. Then ω^(ω^(ω^ω)) is larger still. Keep stacking these towers forever, and the limit of the whole process is ε₀.

Our formalization proves three key properties of ε₀:

1. **Fixed Point**: ω^ε₀ = ε₀ — exponentiation by omega leaves ε₀ unchanged.
2. **Positivity**: ε₀ > 0 — it's strictly above zero.
3. **Minimality**: ε₀ is the *smallest* ordinal with this fixed-point property.

In game-theoretic terms, ε₀ represents a game whose depth hierarchy is so rich that its own complexity structure reproduces itself under the natural "power" operation on games. This self-similarity is what connects it to Gentzen's proof theory: a mathematical system that can describe its own consistency must be able to reason about ordinals up to ε₀, and ε₀'s self-referential property is precisely what makes this possible.

## Games That Preserve Structure

The final piece of our framework concerns *game embeddings* — structure-preserving maps between games. When one game can be embedded into another (with all moves and their structure perfectly preserved), the embedded game's values are guaranteed to be preserved.

This might sound technical, but it captures a profound insight: game complexity is an *invariant* of the game's logical structure, not an artifact of how we happen to represent it. Two games that are structurally identical — even if their positions look completely different — must have the same game values at corresponding positions.

This invariance property is what makes game values useful as a complexity measure. They don't depend on surface features of the game; they capture the deep combinatorial structure.

## The ω^ω Supremum

One striking result bridges the finite and infinite: the supremum of the family ω^1, ω^2, ω^3, ... (games whose depth is a single power of omega) is exactly ω^ω. This might seem like mere arithmetic, but it reveals the hierarchical structure of game complexity.

Each level ω^n represents games that require *n* nested layers of infinite choice. The supremum ω^ω represents games that require *infinitely many* nested layers — a qualitative jump from any finite number of layers. This stratification continues: ω^(ω^ω), ω^(ω^(ω^ω)), and so on, until reaching ε₀ where the hierarchy becomes self-referential.

## Looking Forward

The framework we've established opens several avenues for future research. The most tantalizing is the connection to program termination: every well-founded game corresponds to a computation that must halt, and the game value measures the complexity of proving that it halts. The ε₀ barrier, then, isn't just a curiosity of number theory — it's a fundamental limit on what simple computational reasoning can establish about program behavior.

Another direction involves *infinite chess* — chess played on an infinite board with infinitely many pieces. Recent work by Evans and Hamkins has shown that specific infinite chess positions achieve game values of ω, ω², and even ω^n for any natural number n. Our formalization provides the theoretical infrastructure needed to verify such claims rigorously.

Perhaps most intriguingly, the Bridge Theorem suggests that game theory and order theory are not separate subjects but two perspectives on the same mathematics. Any result about well-ordered sets translates automatically into a result about game complexity, and vice versa. This kind of unexpected unification — where two seemingly different mathematical worlds turn out to be one — is the deepest form of mathematical discovery.

Gentzen, working in 1935 without the benefit of game theory, arrived at ε₀ through pure logic. That the same number emerges naturally from the theory of games suggests something fundamental about the structure of mathematical reasoning itself. When we play a game, count its depth, and find ε₀ staring back at us, we are glimpsing the same mathematical truth that Gentzen saw — the boundary where mathematics can no longer fully comprehend its own foundations.

---

*This research was conducted using formal mathematical verification to ensure the correctness of all results. The complete proofs are available in the project repository.*
