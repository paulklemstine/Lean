# The Hidden Numbers Inside Games

## How a 50-Year-Old Theory of Surreal Numbers Reveals Deep Connections Between Games, Fractions, and Infinity

In 1974, the mathematician John Horton Conway invented an entirely new number system while analyzing board games. He called them *surreal numbers*, and they turned out to be the largest possible ordered field — containing every real number, every infinite number, and infinitely many numbers between any two reals. What Conway discovered was that the simple act of playing a game encodes a number, and numbers arise naturally from the structure of games.

Now, half a century later, new research reveals that the "birthday" of each surreal number — the day it's born in Conway's construction — is governed by a simple but profound arithmetic principle rooted in the prime number 2. The connection bridges three seemingly unrelated fields: game theory, number theory, and analysis.

## Born on Day Zero

Conway's construction begins with nothing. On Day 0, there is only one game: the empty game, where neither player has any moves. This game *is* the number zero. It's not just "like" zero — in Conway's framework, games and numbers are the same thing.

On Day 1, a player can use zero as an option. This creates three new games: one is the number 1, another is −1, and the third is a peculiar object called "star" that behaves like zero in arithmetic but isn't zero as a game. By Day 2, the system has seven distinct values: −2, −1, −½, 0, ½, 1, and 2.

Notice that ½ appears on Day 2. Not Day 1, not Day 3 — exactly Day 2. This isn't a coincidence. It's the first hint of a deep pattern.

## The Birthday Principle

The key insight of the new research concerns *dyadic rationals* — fractions whose denominators are powers of 2. Numbers like ¾ (which equals 3/4 = 3/2²), ⅜ (3/2³), and 7/16 (7/2⁴) are all dyadic. Every integer is dyadic too, with denominator 2⁰ = 1.

The Birthday–Denomination Principle states: **A dyadic rational m/2ⁿ, where m is odd, cannot be simplified to any fraction with a smaller power-of-2 denominator.** The number 3/8 cannot be rewritten as anything over 4 or 2 or 1. Its "complexity" is irreducibly tied to 8 = 2³.

This principle has a game-theoretic interpretation. When Conway constructs surreal numbers, the birthday of m/2ⁿ (with m odd) is exactly n. The fraction 3/8 is born on Day 3. The number 5/16 is born on Day 4. The denominator's relationship to powers of 2 — what number theorists call the "2-adic valuation" — precisely determines the construction day.

The proof of this principle is elegant and uses a contradiction argument. If 3/8 could be rewritten as a/4 for some integer a, then cross-multiplying gives 3 × 4 = a × 8, or 12 = 8a, which forces a = 3/2 — not an integer. More deeply, the equation 3 = a × 2 would require 2 to divide 3, which it doesn't. The oddness of the numerator creates an absolute obstruction.

## Two Dimensions of Game Complexity

Games have more structure than just their birthday. Consider chess: it was "born" at some point in history (its birthday), but individual games of chess vary enormously in strategic depth — some end in four moves, others last hundreds.

The research introduces a new concept called *game depth* that captures this second dimension. While birthday measures *when* a game is constructed, game depth measures *how long* the game can last. A game's depth is the length of the longest possible play sequence.

These two measures — birthday and depth — are mathematically independent. A game can have a high birthday but low depth (like a surreal number, which is "deep" in the construction hierarchy but has a simple game tree) or a low birthday but high depth (like certain positions in combinatorial games).

Combining birthday and depth into a single two-dimensional measure creates what the researchers call *game complexity*. This pair (birthday, depth) provides much finer discrimination between games than either axis alone, like using both latitude and longitude instead of just one coordinate to locate a point on Earth.

A surprising theorem: game complexity is perfectly preserved under negation. Taking the negative of a game — swapping the two players' roles — leaves both the birthday and the depth unchanged. This is intuitive for birthday (swapping players doesn't change when a game was constructed) but less obvious for depth (swapping players preserves the length of the longest game).

## A Subring of Fractions

The dyadic rationals — all fractions with power-of-2 denominators — form what mathematicians call a *subring* of the rationals. This means they're closed under addition, subtraction, and multiplication. Add two dyadics and you get a dyadic. Multiply two dyadics and you get a dyadic.

This algebraic closure is exactly what you'd expect from the surreal construction. If two surreal numbers are born by some finite day, their sum and product are also surreal numbers (born by a slightly later day). The birthday hierarchy respects arithmetic.

The research also establishes a *valuation* property: the dyadic valuation — measuring denominator complexity — behaves like a metric. The complexity of a sum is bounded by the sum of complexities. Adding 3/8 (complexity 3) and 5/16 (complexity 4) gives something of complexity at most 7. This bound comes from the fact that the denominator of a sum divides the product of the original denominators.

This subadditive property connects surreal birthday arithmetic to the theory of *p-adic numbers*, a cornerstone of modern number theory used in everything from the proof of Fermat's Last Theorem to cryptographic protocols. The dyadic valuation on surreal numbers is, in a precise sense, the 2-adic valuation restricted to the surreal subfield.

## Filling Every Gap

One of the most beautiful properties of the surreal number system is its density: between any two distinct rational numbers, there is always a dyadic rational. This means the surreal birthday hierarchy eventually "fills in" every gap in the number line.

This density theorem has a constructive proof. Given two rationals a < b, choose n large enough that 1/2ⁿ is smaller than the gap b − a. Then the dyadic rational ⌊a · 2ⁿ⌋ + 1)/2ⁿ falls strictly between a and b. The number was always there, waiting to be born on day n.

The counting mirrors this density. The surreal hierarchy grows exponentially: day 0 has 1 value, day 1 has 3, day 2 has 7, day 3 has 15, and in general, day n has 2ⁿ⁺¹ − 1 distinct surreal values. Each new day produces as many new surreals as all previous days combined, plus one.

## The Infinite Horizon

At "day ω" — the first infinite birthday — the surreal construction has produced exactly the dyadic rationals ℤ[1/2]. Every fraction with a power-of-2 denominator has been born, but numbers like 1/3 have not.

The research states a precise conjecture: the surreal numbers born by day ω form a field that is *order-isomorphic* to the dyadic rationals with their usual ordering. Every dyadic rational can be realized as a numeric game whose birthday equals its dyadic valuation.

If proved, this conjecture would establish the first complete, machine-verified correspondence between Conway's game-theoretic construction and classical number theory. The birthday function would be formally identified as the 2-adic valuation — a bridge between two major branches of mathematics that Conway intuited but never rigorously axiomatized.

## Why It Matters

The connection between game birthdays and 2-adic valuations isn't merely elegant — it's structurally deep. The birthday filtration (the tower of sets of games born by each day) is a *directed system* closed under addition, negation, and natural ordinal sum. This means the surreal number field has a natural "complexity stratification" that respects all arithmetic operations.

This stratification could have implications far beyond pure mathematics. In computational game theory, understanding the birthday of a game position gives an upper bound on the computation needed to evaluate it. In cryptography, the subadditive property of the dyadic valuation connects to the security analysis of lattice-based schemes that rely on the arithmetic of ℤ[1/2].

Conway's surreal numbers began as a playful construction — numbers emerging from games, infinity from simplicity. Fifty years later, they continue to reveal unexpected mathematical depth. The birthday of a number, it turns out, is not just a label for when it was created. It's a window into the number's fundamental arithmetic nature.
