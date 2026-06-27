# The Hailstone Numbers: What We Can Prove About the World's Simplest Unsolved Problem

Pick a number. Any whole number bigger than zero. Now play a game with two rules:

- If your number is **even**, cut it in half.
- If your number is **odd**, triple it and add one.

Then repeat, forever, feeding each answer back into the machine.

Try it with $6$. Six is even, so we halve it to $3$. Three is odd, so we triple-and-add-one to get $10$. Ten halves to $5$. Five becomes $16$. Sixteen, being a clean power of two, then tumbles straight down: $16 \to 8 \to 4 \to 2 \to 1$. Once we hit $1$, we triple-and-add-one to get $4$, which falls back to $2$, then $1$ again — a little loop that never escapes.

Try a bigger one, say $27$. This time the number does not go quietly. It climbs to $82$, sinks, climbs again, and goes on a wild ride that peaks at $9232$ before finally — after **111 steps** — collapsing down to $1$. The numbers rise and fall like hailstones tossed up and down inside a storm cloud before they finally fall to earth. That image gave them their nickname: the **hailstone numbers**.

The **Collatz Conjecture** is the breathtakingly simple claim that *this always happens*. No matter which positive integer you start with, the hailstone eventually falls to $1$. Mathematicians have checked this by computer for every starting value up to roughly $2^{68}$ — that is over **295 quintillion** numbers — and not one has ever escaped. And yet, after more than eighty years, **nobody has been able to prove it.** The legendary mathematician Paul Erdős said of it: *"Mathematics may not be ready for such problems."* He offered a prize for a solution, but warned it might take generations.

## The map that runs the whole show

Strip away the storytelling and the entire universe of this problem is governed by a single function, which we'll call $T$. Given a positive whole number $n$,

$$
T(n) = \begin{cases} n/2 & \text{if } n \text{ is even}, \\ 3n + 1 & \text{if } n \text{ is odd}. \end{cases}
$$

The Collatz Conjecture is the statement that if you apply $T$ over and over — written $T(T(T(\cdots T(n))))$, or $T^{[k]}(n)$ for "$T$ applied $k$ times" — you will, for *every* starting $n$, eventually land on $1$.

What makes this so maddening is the tension baked into the two rules. The halving rule is a force of *destruction*: it shrinks numbers fast. The tripling rule is a force of *creation*: it makes them explode. A single step can roughly triple your number; a single step can roughly halve it. Whether a starting value falls or flies depends on the precise, unpredictable braid of even and odd steps it happens to encounter. There is no obvious reason the destroyers should always win in the end — and no obvious reason they shouldn't.

## What would it take to break the conjecture?

If the Collatz Conjecture were *false*, there would have to be a witness — some number that never reaches $1$. There are exactly two ways a hailstone could refuse to fall:

1. **It could fly off to infinity**, growing without bound forever.
2. **It could get trapped in a loop** — a cycle of numbers other than the familiar $1 \to 4 \to 2 \to 1$ — circling forever without ever touching $1$.

Nobody has found either. But "nobody has found one" is not a proof. The honest mathematical question is: *what can we prove for certain, right now, with no assumptions?* It turns out we can completely shut down certain escape routes. We can prove, unconditionally, that hailstones cannot misbehave in particular ways — and in doing so, we corner the conjecture, narrowing the space where any counterexample could possibly hide.

That is exactly what the results described here accomplish. Each one is a small, airtight, fully verified theorem about the map $T$. None of them solves Collatz. But together they form a precise dossier on what a rogue number is *not allowed* to do.

## Closing the first door: no number can stand still

The simplest possible loop is a loop of length one — a number that maps to itself. If some $n$ satisfied $T(n) = n$, it would be a **fixed point**: a hailstone frozen in midair, neither rising nor falling. Could such a number exist?

The first theorem says **no, never** (for positive $n$). The argument is so clean it fits in a sentence. Look at any positive number through the lens of its parity:

- If $n$ is **even**, then $T(n) = n/2$, which is *strictly smaller* than $n$. A number cannot equal something smaller than itself.
- If $n$ is **odd**, then $T(n) = 3n + 1$, which is *strictly larger* than $n$. A number cannot equal something larger than itself.

Either way, $T(n) \ne n$. There are no frozen hailstones. In the formal development this is the theorem **`T_no_fixed_point`**, and it rests on two even simpler facts that are proved first and used everywhere: **`T_lt_of_even`**, which says that an even step strictly *decreases* a positive number, and **`T_gt_of_odd`**, which says that an odd step strictly *increases* it. These two facts — "even shrinks, odd grows" — are the heartbeat of every result that follows.

## The trapdoor of pure halving

Here is a tempting daydream. The halving rule is the engine of descent. So what if a number could just... keep halving? If you only ever took even steps, you would plummet: $n \to n/2 \to n/4 \to n/8$, dividing by two at every turn. Could a counterexample to Collatz hide in a long, luxurious slide of nothing but halvings?

The next theorem, **`all_even_descent`**, pins down exactly what such a slide does. It says: *if the first $k$ numbers in an orbit are all even* — that is, $n, T(n), T^{[2]}(n), \ldots, T^{[k-1]}(n)$ are every one of them even — *then after those $k$ steps you have divided by two exactly $k$ times:*

$$
T^{[k]}(n) = \frac{n}{2^k}.
$$

It is the formal version of the obvious-sounding claim "$k$ halvings divide by $2^k$," but stated and proved with full rigor by induction: each new even step turns "divided by $2^k$" into "divided by $2^{k+1}$," and the powers of two stack up cleanly. The reason this matters is that it converts a *dynamical* statement (a run of even steps) into a single, exact *arithmetic* formula. And that formula is a weapon, as we're about to see.

## Closing the big door: every loop must contain an odd number

Now we come to the centerpiece. Suppose, for contradiction, that a rogue cycle exists: a positive number $n$ that returns to itself after exactly $p$ steps, with $p \ge 1$. In symbols, $T^{[p]}(n) = n$, and $p$ is the length of the loop. This is precisely the kind of "trapped hailstone" that could doom the conjecture.

The theorem **`periodic_has_odd`** proves something every such loop must obey: **it has to contain at least one odd number.** You cannot build a Collatz cycle out of even numbers alone.

Why? Here the two earlier results snap together like puzzle pieces. Suppose, toward a contradiction, that *every* number in the loop were even — all $p$ of the values $n, T(n), \ldots, T^{[p-1]}(n)$. Then `all_even_descent` applies with $k = p$, and it tells us exactly where the orbit lands after a full lap:

$$
T^{[p]}(n) = \frac{n}{2^p}.
$$

But this is a loop, so by assumption $T^{[p]}(n) = n$. Putting these together gives

$$
n = \frac{n}{2^p}.
$$

And that is absurd. Since the loop length $p$ is at least $1$, the divisor $2^p$ is at least $2$, so $n / 2^p$ is *strictly smaller* than $n$ (for any positive $n$). A positive number simply cannot equal a strictly smaller number. The all-even assumption detonates. Therefore some step in the loop must have been odd. $\blacksquare$

It is a beautiful little argument, and it carries real weight. It tells us that any hypothetical counterexample-cycle is forced to repeatedly visit the *expanding* odd rule. A loop cannot quietly coast downhill forever on halvings; it is obligated, again and again, to invoke the very rule that makes numbers explode. The destroyer and the creator must take turns. This is one of the structural constraints that has, for decades, made it so hard for anyone to build a rogue cycle on paper — and these theorems prove, with certainty, that the easiest constructions are impossible.

## Why chase a problem you can't solve?

You might reasonably ask: if Collatz is so far out of reach, why prove these careful little theorems at all? Three reasons.

**First, certainty.** "We checked $2^{68}$ numbers and none escaped" is powerful evidence, but it is not a guarantee — the very next number could, in principle, misbehave. A theorem like `periodic_has_odd` is different in kind. It is true for *all* numbers at once, including the infinitely many no computer will ever reach. It is a permanent fact about the structure of the problem, not a survey of examples.

**Second, the conjecture connects to deep mathematics.** The behavior of $T$ has been studied through the lens of **stopping times** (how many steps until a number first drops below its starting value), through **ergodic theory** (which treats the long-run statistics of orbits the way physics treats a gas of particles), and through **$p$-adic dynamics**, where the doubling and halving become natural operations in an exotic number system built around the prime $2$. In that $2$-adic world, the count of how many times you can halve a number is exactly its "$2$-adic valuation," and the whole tripling-and-halving dance becomes a clean shift operation. Tantalizingly, related "$3n+1$"-style problems *have* been proven undecidable, hinting that Collatz may sit on the knife's edge between order and chaos.

**Third, partial progress is real progress.** Mathematicians have proven that *almost all* numbers (in a precise density sense) do eventually drop below their starting value — a celebrated result of Terence Tao shows Collatz orbits attain "almost bounded values almost everywhere." Each unconditional obstruction, like the ones here, fences off another region where a counterexample could live. The dream is to fence off the entire plane, leaving the rogue number nowhere to stand.

## The shape of the unknown

What is so humbling about Collatz is the gulf between how easy it is to *state* and how impossible it is to *crack*. You can explain the rules to a child in thirty seconds. You can verify any single number by hand. And yet the global question — *does every hailstone fall?* — has resisted the full force of modern mathematics.

The theorems gathered here don't close that gulf. What they do is map its edges with absolute precision. There are no frozen hailstones: no number maps to itself. A pure free-fall of halvings divides cleanly by a power of two and cannot circle back. And every conceivable loop, no matter how long or how cleverly arranged, is forced to climb at least once through the explosive odd rule. These are not guesses or computer surveys. They are certainties, and they hold for every one of the infinitely many numbers there are.

Somewhere out past $2^{68}$, in the unlit reaches of the number line, the hailstones keep falling. We still cannot prove that they all do. But we know, now and forever, several precise ways in which they cannot refuse. And in mathematics, knowing exactly what *cannot* happen is often the first step toward proving what must.
