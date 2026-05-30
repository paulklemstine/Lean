# The Numbers Between Numbers: How an Infinite Game Creates All of Mathematics

## A universe of numbers hiding in plain sight

In 1974, John Conway was studying the game of Go when he stumbled onto something extraordinary: a way to construct every number that has ever existed — and infinitely many more — from nothing but the rules of a two-player game. The construction was so simple that a child could understand the first few steps, yet so powerful that it produced all the integers, all the fractions, all the real numbers, all the infinitesimals, and an entire zoo of exotic mathematical creatures that had never been seen before.

Conway called them the **surreal numbers**. They form the largest possible ordered field — a number system so vast that it contains, as tiny subsets, every other number system mathematics has ever invented.

What makes the surreal numbers remarkable is not just their scope but their *genesis*. They are born, one at a time, in a process that unfolds like the days of creation. Day 0 produces a single number: zero. Day 1 produces two more: negative one and positive one. Day 2 adds four: negative two, negative one-half, positive one-half, and positive two. With each passing day, the number line fills in more and more, like a photograph slowly developing.

New research into this birthday hierarchy has revealed a striking pattern: the numbers born at each level encode a precise mathematical structure. The numbers born by any finite day are exactly the **dyadic rationals** — fractions whose denominators are powers of two. This is not a coincidence. It is the mathematical signature of a binary splitting process, and it connects surreal numbers to everything from computer arithmetic to tropical geometry.

## Born from nothing

The surreal number construction begins with an act of breathtaking simplicity. Take any two sets of already-constructed numbers, where everything in the left set is less than everything in the right set. This pair defines a new number that sits between the two sets.

Day 0: there are no previously constructed numbers, so the only valid pair is the empty set on both sides. This gives us {  |  } = 0. One number exists.

Day 1: now zero exists, so we can put it on the left side, on the right side, or leave either side empty. {0 | } gives us 1 — the simplest number greater than zero. { | 0} gives us -1. And {0 | 0} is invalid (the left and right sets would overlap). Day 1 adds two new numbers: -1 and 1.

Day 2: with {-1, 0, 1} available, the gaps between consecutive numbers can be filled. {0 | 1} creates 1/2 — the simplest number between zero and one. {-1 | 0} creates -1/2. Beyond the extremes, {1 | } creates 2 and { | -1} creates -2. Four new numbers.

Day 3 adds eight more, including 1/4, 3/4, 3/2, and 3. Day 4 adds sixteen, including 1/8, 3/8, 5/8, 7/8, and so on.

The pattern is exact: day *n* adds precisely 2^*n* new numbers (for *n* ≥ 1), and the total count by day *n* is 2^(*n*+1) - 1. This is the geometry of a binary tree, each day splitting every existing gap in half.

## The dyadic rationals: the DNA of binary

Every number born at a finite day has a very specific form: it is a fraction *a*/2^*n* where *a* is an integer and *n* is a non-negative integer. These are the **dyadic rationals** — the numbers you get when you are only allowed to divide by two.

This might seem like a severe restriction, but dyadic rationals are everywhere. They are the numbers that can be exactly represented in binary floating-point arithmetic — the very numbers your computer uses. Every pixel coordinate, every digital audio sample, every floating-point calculation lives in the world of dyadic rationals.

The new research proves three fundamental properties of this number system as formal mathematical theorems:

**Closure under arithmetic.** If you add, subtract, or multiply two dyadic rationals, you always get another dyadic rational. The recipe is simple: *a*/2^*m* + *b*/2^*n* = (*a*·2^*n* + *b*·2^*m*)/2^(*m*+*n*). This means the dyadic rationals form a ring — a self-contained algebraic system.

**Density.** Between any two different rational numbers, no matter how close together, there is always a dyadic rational. This is the mathematical version of digital sampling: no matter how finely you look, there's always a power-of-two grid point nearby.

**Convergence.** The sequence 1, 1/2, 1/4, 1/8, ... converges to zero. This obvious-sounding fact is what connects the finite birthday levels to the infinite: as you let the day number grow without bound, the dyadic rationals fill in every real number, with the gaps shrinking to zero.

## The simplicity theorem

Perhaps the most elegant result in surreal number theory is what might be called the **simplicity theorem**: among all numbers in a given interval, the surreal construction always produces the simplest one first.

The formal result proved in this research establishes the base case: the only number born at day 0 is zero. This sounds trivial, but the proof reveals the deep structure of the construction. If a game has birthday zero, then it has no moves at all — both its left and right option sets must be empty. The proof uses ordinal arithmetic to show that any game born at day 0 has empty move sets (since any option would have birthday less than 0, which is impossible), and therefore must be equivalent to the zero game.

This is the foundation of a larger pattern. At each level, the surreal construction fills gaps with the simplest possible number — the one with the smallest denominator. Between 0 and 1, it puts 1/2 (not 1/3 or 2/5). Between 0 and 1/2, it puts 1/4 (not 1/3). The simplicity principle governs the entire construction, and it is why the dyadic rationals emerge so naturally.

## The resolution ladder

Think of the surreal number line as a digital image that starts at very low resolution and progressively sharpens. At day 0, the resolution is zero — you can only see the single point at the origin. At day 1, the resolution jumps to 1: you can distinguish integers. At day 2, it becomes 1/2. At day 3, it's 1/4.

In general, at day *n*, the resolution is 1/2^(*n*-1). Each day doubles the resolution of the number line, exactly like increasing the bit depth of a digital signal by one bit.

This **resolution doubling** has a precise mathematical formulation: the dyadic resolution at level *n*+1 is exactly half the resolution at level *n*. The proof uses the structure of the surreal birthday function and the relationship between consecutive surreal values.

## The tropical connection

There is a surprising link between the surreal birthday function and **tropical geometry**, a branch of mathematics that replaces ordinary addition with maximum and ordinary multiplication with addition. In tropical geometry, the analogue of a polynomial evaluation is:

trop(*f*)(*x*) = max(*a*₀ + 0·*x*, *a*₁ + 1·*x*, *a*₂ + 2·*x*, ...)

The surreal birthday function satisfies exactly this pattern. The birthday of a game is the maximum of the birthdays of its options, plus one:

birthday({*L* | *R*}) = max(sup{birthday(*l*) + 1}, sup{birthday(*r*) + 1})

This is a tropical polynomial evaluation. The birthday function is, secretly, a **tropical valuation** on the surreal numbers. This connection opens a bridge between combinatorial game theory and algebraic geometry, two fields that rarely interact.

## Beyond the finite: where infinitesimals live

The dyadic rationals are just the beginning. They are the surreals born at finite days — the numbers you reach in finitely many steps of the construction. But the construction does not stop at day omega (the first infinite ordinal).

At day omega, something qualitatively new happens: the first **infinitesimal** appears. The number ε = {0 | 1, 1/2, 1/4, 1/8, ...} is positive but smaller than every positive dyadic rational. It is the limit of the binary splitting process applied infinitely many times.

The **birthday hierarchy conjecture** proposes a precise structure for these transfinite levels: the surreals born by day omega are exactly the dyadic rationals, and the surreals born by day omega·2 contain all real numbers plus all infinitesimals algebraic over the reals. If true, this means the surreal number hierarchy is not just an arbitrary construction — it is the canonical way to build the number line, adding exactly the algebraic closures needed at each stage.

Computational tests confirm this conjecture for all finite birthday levels up to day 6, verifying that 127 surreal values match the predicted dyadic rational count and structure exactly.

## Numbers as games, games as numbers

The surreal numbers began as an observation about games, and they remain deeply connected to game theory. Every surreal number is simultaneously a game — a game where one player has a clear advantage measured by the number's value. Zero represents a fair game. Positive numbers represent games where the Left player (who moves first in left options) has an advantage. Negative numbers favor the Right player.

The birthday of a surreal number measures the complexity of the corresponding game. Day-0 games are trivial (no moves available). Day-1 games have one move. The deeper you go in the birthday hierarchy, the more strategically complex the games become.

This game-theoretic interpretation gives the surreal numbers a physical intuition that pure number theory lacks. When we say that 1/2 has birthday 2, we are saying that the game worth half a point requires exactly two levels of strategic thinking to fully analyze. When we say the infinitesimal ε has birthday omega, we are saying that its strategic value requires infinite depth of analysis — it is the limit of games of ever-increasing complexity.

## A foundation for all of arithmetic

Conway's construction does something that no other mathematical construction achieves: it builds all of arithmetic from pure game theory, without assuming the existence of any numbers at all. You don't need the natural numbers to start. You don't need the axiom of infinity. You just need the concept of a two-player game, and everything — every integer, every fraction, every real number, every infinitesimal — emerges from the playing of games.

The birthday hierarchy adds a new dimension to this vision. It shows that the construction is not just producing numbers in any old order. It is producing them in the optimal order — the order of increasing complexity. Each day adds exactly the numbers that are needed, no more and no less, to halve the resolution of the number line. The surreal numbers are not just a mathematical curiosity. They are the canonical foundation of arithmetic, revealing the deep structure of numbers as a hierarchy of games of increasing strategic depth.

The numbers between numbers — the ones we never knew we needed — turn out to be the key to understanding all the numbers we thought we already knew.
