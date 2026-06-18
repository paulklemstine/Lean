# When Counting Forces Structure: Thresholds, Rigidity, and Dead-Ends in Finite Mathematics

## A physicist's eye on pure logic

Physicists have a favorite word for the moment a system changes its mind: *transition*. Heat water one degree at a time and almost nothing happens — until, at exactly 100°C, the liquid abruptly becomes vapor. Cool a magnet slowly and it sits there inert — until, at a precise temperature, it spontaneously picks a direction and becomes magnetic. The hallmark of a *phase transition* is that a tiny change in a control parameter triggers a dramatic, qualitative change in behavior. Around the critical point, the system is exquisitely sensitive; far from it, it is sleepy and predictable.

The tools physicists built to understand these transitions — renormalization, coarse-graining, fixed points, universality — were designed for atoms and fields. But the same *shape* of phenomenon shows up in places that have nothing to do with temperature. It shows up in pure mathematics, in the cold combinatorics of integers and finite maps, where a single extra element or a single extra unit of "size" can flip a system from "anything goes" to "this is forced."

This article tells the story of three crisp, fully proved mathematical facts that, taken together, sketch a miniature physics of discrete structure. Each one is a sharp threshold or a rigidity law. Each one says: *once a finite system crosses a certain line, it can no longer escape a particular kind of order.* And each one has been verified down to the last logical atom.

The three protagonists are:

1. **A pigeonhole threshold for divisibility** — you can pick numbers freely, until you can't.
2. **A rigidity law for Fibonacci numbers** — divisibility among Fibonacci numbers exactly mirrors divisibility among their positions.
3. **A "Garden of Eden" principle for finite dynamics** — in finite systems, being onto and being one-to-one are the same thing, and any process that only ever decreases must come to rest quickly.

Let us meet them one at a time.

## Act I: The pigeonhole threshold — freedom, then force

Here is a game. I give you the whole numbers from 1 to 200. Your job is to pick as many of them as you can while obeying a single rule: **no number you pick may divide another number you pick.** Pick 5 and you may not also pick 10, 15, 20, 100, and so on.

How many can you grab? You might fiddle for a while and then notice a beautiful trick: just take the top half, the numbers 101 through 200. None of these divides another, because if one number divides a strictly larger number, the larger one is at least twice as big — but the largest here is less than twice the smallest. So you can comfortably collect **100** numbers with no divisibility among them.

Can you do better? Can you find 101 numbers from 1 to 200 with no divisibility pair? The answer is a flat, provable **no**. And the reason is one of the most elegant arguments in all of mathematics.

Every positive integer can be written, in exactly one way, as an **odd number times a power of two**. Twelve is 3 × 4, so its "odd core" is 3. Forty is 5 × 8, so its odd core is 5. Seven is already odd, so its odd core is 7. This odd core is what mathematicians call the *odd part* of a number; formally, you keep dividing out factors of 2 until none remain.

Now count the odd numbers between 1 and 200: they are 1, 3, 5, …, 199 — exactly 100 of them. Every number you might pick has an odd part, and that odd part is one of these 100 values. If you try to pick 101 numbers, then by the **pigeonhole principle** — 101 pigeons, 100 holes — two of your numbers must share the same odd part. Say they are $a = c \cdot 2^j$ and $b = c \cdot 2^k$ with the same odd core $c$. Whichever has the smaller power of two divides the other. You have a divisibility pair, whether you wanted one or not.

The general theorem, proved exactly, reads:

> **Theorem (divisibility pigeonhole).** *Let $n \ge 1$. Any set $S$ of $n+1$ distinct integers, all drawn from the range $1$ to $2n$, must contain two distinct elements $a$ and $b$ with $a$ dividing $b$.*

This is a *phase transition* in the most literal combinatorial sense. With $n$ numbers, you are subcritical: you can dodge divisibility entirely (take the top half). Add one more — cross from $n$ to $n+1$ — and you are supercritical: divisibility is unavoidable. There is no gentle slope between the two regimes, no "mostly avoidable." The line is exact, and it is set by the number of odd holes available.

The engine of the proof, the assignment of each number to its odd core, behaves like a *coarse-graining* operator. It throws away the powers of two — the "high-frequency detail" — and keeps only the odd skeleton. Two numbers that look different at fine resolution become identical after coarse-graining precisely when one is a power-of-two multiple of the other. The phase transition is then just a counting statement about the coarse-grained world: there are only so many skeletons to go around.

## Act II: Fibonacci rigidity — a perfect mirror

The Fibonacci numbers need little introduction: 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, and onward, each the sum of the two before it. They appear in sunflowers, pinecones, and the proportions of seashells, and they hide a startling internal discipline.

Look at which Fibonacci numbers divide which. The 3rd Fibonacci number is 2, and it divides exactly the *even-indexed* Fibonacci numbers: $F_6 = 8$, $F_9 = 34$, $F_{12} = 144$ — the ones whose position is a multiple of 3. The 4th Fibonacci number is 3, and it divides $F_8 = 21$, $F_{12} = 144$ — the positions that are multiples of 4. A pattern is screaming at us: **a Fibonacci number divides another exactly when its position divides the other's position.**

The first half of this is an old and lovely fact:

> **Theorem (index divisibility implies Fibonacci divisibility).** *If $m$ divides $n$, then $F_m$ divides $F_n$.*

So $F_3 = 2$ divides every third Fibonacci number, $F_5 = 5$ divides every fifth, and so on. The sequence is what number theorists call a *divisibility sequence*: the divisibility structure of the indices is faithfully copied upward into the values.

But the truly remarkable claim is the *converse*, and it comes with a subtle catch. The full statement is:

> **Theorem (Fibonacci divisibility, both ways).** *For any index $m \ge 3$, the Fibonacci number $F_m$ divides $F_n$ **if and only if** $m$ divides $n$.*

Read that carefully and notice the condition $m \ge 3$. It is not decoration — it marks another phase boundary. Why must we exclude $m = 1$ and $m = 2$? Because $F_1 = F_2 = 1$, and 1 divides *everything*. So $F_1$ and $F_2$ divide every Fibonacci number whatsoever, even though 1 and 2 certainly do not divide every index. The clean mirror law shatters at the very bottom of the sequence and snaps perfectly into place at $m = 3$ and stays true forever after. Once again: below a threshold, chaos; at and above it, rigid order.

The proof of the hard direction rests on a jewel of number theory: the greatest common divisor of two Fibonacci numbers is itself a Fibonacci number, and it is the one whose index is the gcd of the two original indices. In symbols, $\gcd(F_m, F_n) = F_{\gcd(m,n)}$. Now suppose $F_m$ divides $F_n$. Then $F_m$ equals $\gcd(F_m, F_n) = F_{\gcd(m,n)}$. For $m \ge 3$ the Fibonacci numbers are strictly increasing, so equal Fibonacci values force equal indices: $m = \gcd(m,n)$, which is exactly the statement that $m$ divides $n$. The whole argument turns on *strict monotonicity above the threshold* — the same structural fact that makes $m \ge 3$ necessary.

This rigidity is more than a curiosity. It means the divisibility lattice of the integers is embedded, perfectly and without loss, inside the Fibonacci sequence. Questions about when one index divides another become questions about when one Fibonacci number divides another, and vice versa. It is a dictionary between two worlds that agree on every entry — provided you start reading at the third word.

## Act III: The Garden of Eden — dead-ends and bounded descent

The third story leaves arithmetic for *dynamics*: the study of systems that evolve step by step. Picture a finite set of possible states and a rule $F$ that, given the current state, produces the next one. Apply $F$ again and again and you trace an *orbit* through the states.

Some states might be **Garden-of-Eden states** — a haunting term borrowed from the theory of cellular automata. A Garden-of-Eden state is one that can appear only at the very beginning of time: it has *no predecessor*. No state, fed into the rule $F$, ever produces it. You can start there, but you can never return there, and the system can never arrive there on its own. Formally, a state $y$ is a Garden of Eden for $F$ if $F(x) \neq y$ for every $x$.

When do such unreachable states exist? The answer is disarmingly simple and completely general:

> **Theorem (Garden of Eden iff not onto).** *A rule $F$ has a Garden-of-Eden state if and only if $F$ is not surjective — that is, if and only if some state is never produced as an output.*

This is almost a tautology once you see it, and that is its strength: a Garden-of-Eden state *is* exactly a value that the map misses. The content lies in what happens on **finite** systems, where surjectivity and injectivity become locked together. On a finite set, a map that hits every state must do so without collisions, and a map that never collides must hit every state. This is the finite shadow of the celebrated **Moore–Myhill Garden-of-Eden theorem** of cellular-automata theory, which connects "every configuration is reachable" with "distinct starting configurations stay distinguishable." The finite version proved here states that surjectivity implies injectivity on finite types — no reachable-but-blurred dynamics, no information quietly destroyed while still covering every state.

The last result adds a notion of *energy* that only ever decreases. Suppose the states carry an order — think of it as height, or cost, or potential — and the rule $F$ never moves uphill: $F(x) \le x$ always. Such *descending* maps model relaxation, optimization, simplification: every step makes the configuration no larger. Two things follow.

> **Theorem (descent forms a descending chain).** *If $F$ never increases, then iterating it produces a non-increasing sequence: $F^{n+1}(x) \le F^{n}(x)$ for every step $n$ and every start $x$.*

Each step sits at or below the previous one. The orbit slides monotonically downhill. But it cannot slide forever in a finite world, and here is the punchline, with an explicit speed limit:

> **Theorem (bounded descent stabilization).** *On a finite ordered set $P$ with a monotone, never-increasing rule $F$, every orbit reaches a fixed point within at most $|P|$ steps — where $|P|$ is the total number of states. Concretely, for every starting state $x$ there is some step $n \le |P|$ at which $F^{n}(x) = F^{n+1}(x)$: the system has stopped moving.*

The proof is a pigeonhole argument in disguise — the same instinct that drove Act I. If the orbit kept strictly descending for more than $|P|$ steps, it would visit more than $|P|$ distinct states, which is impossible because there are only $|P|$ of them. So it must repeat; and because it only ever descends, the only way to repeat is to *stop*. The descent has reached the bottom of its valley.

This is the discrete echo of a renormalization flow. A renormalization flow is a rule that, applied over and over, carries a system toward a **fixed point** — a configuration unchanged by further coarse-graining, the place where the system's essential character is laid bare. Here the descending map *is* such a flow, the fixed point is the stable state at the bottom, and the theorem guarantees not only that we reach it but that we reach it *fast* — in no more steps than there are states. There is no possibility of endless wandering, no chaotic refusal to settle. Finiteness plus monotonic descent equals guaranteed, bounded convergence.

## The shape they share

Step back and the three acts rhyme.

The **pigeonhole threshold** is a sharp critical line: $n$ numbers are free, $n+1$ are forced. The control parameter is the size of your selection; the order parameter is the inevitability of a divisibility pair; the transition is instantaneous at the boundary set by the number of odd cores.

The **Fibonacci mirror** is also a threshold law, with its phase boundary at the index $m = 3$. Below it, the divisibility correspondence collapses because $F_1 = F_2 = 1$ divides everything; at and above it, strict monotonicity restores a flawless one-to-one mirror between index divisibility and Fibonacci divisibility.

The **Garden of Eden and bounded descent** give us the dynamical picture: dead-end states appear exactly when the dynamics fail to be onto, surjectivity and injectivity fuse on finite systems, and any downhill flow settles into a fixed point within a number of steps you can name in advance.

Each result is a statement about how, in finite or discrete settings, *counting forces structure*. Cross a line in size, or in index, or in the number of available states, and the system loses its freedom. The mechanisms differ — odd cores, gcd identities, the pigeonhole principle on orbits — but the music is the same: there is a critical point, and on the far side of it, order is not a possibility but a certainty.

That is the promise of importing a physicist's vocabulary into pure mathematics. Thresholds, coarse-graining, fixed points, and universality are not just metaphors here. They are precise descriptions of how finite systems behave near their critical lines — and, in the three theorems above, they are not conjectures or analogies but established, airtight facts. Counting, it turns out, is destiny.
