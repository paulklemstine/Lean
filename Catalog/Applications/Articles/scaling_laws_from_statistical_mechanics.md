# Divisibility Bridges: From Fibonacci Lattices to Gardens of Eden

Mathematics is full of secret bridges. You set out studying one thing — the
Fibonacci numbers, say, those rabbits-and-sunflowers integers everyone meets in
school — and you find yourself, a few steps later, standing in a completely
different country: the theory of unavoidable coincidences, or the strange world
of states that can exist but can never be *created*. This article is a tour of
three such bridges, all of them built on a single deceptively simple idea:
**when a map respects structure, the structure tells you what the map must do.**

Each statement below has been verified down to the last logical atom by a proof
assistant, so you can take every claim here as literally true — not "true in
spirit," not "true for the examples we checked," but provably, mechanically
true. But the proofs are not the point. The point is the ideas, and they are
beautiful.

---

## A lattice hidden in the Fibonacci numbers

Start with the Fibonacci sequence:

$$1,\ 1,\ 2,\ 3,\ 5,\ 8,\ 13,\ 21,\ 34,\ 55,\ 89,\ 144,\ \dots$$

Each number is the sum of the two before it. Write $F_n$ for the $n$-th
Fibonacci number, so $F_1 = 1$, $F_2 = 1$, $F_3 = 2$, $F_4 = 3$, $F_5 = 5$, and
so on.

Now ask a question that sounds like idle curiosity: **when does one Fibonacci
number divide another?** Look at $F_{12} = 144$. Its divisors among the
Fibonacci numbers are $F_2 = 1$, $F_3 = 2$, $F_4 = 3$, $F_6 = 8$. Notice the
indices: $2, 3, 4, 6$. Those are exactly the divisors of $12$. That is not a
coincidence. It is a theorem.

**The Fibonacci divisibility law.** *If $m$ divides $n$, then $F_m$ divides
$F_n$.* In symbols, $m \mid n \implies F_m \mid F_n$.

So because $4 \mid 12$, we get $F_4 = 3$ divides $F_{12} = 144$ — and indeed
$144 = 3 \times 48$. Because $6 \mid 12$, $F_6 = 8$ divides $144 = 8 \times 18$.
The Fibonacci sequence faithfully *copies the divisibility structure of the
integers into itself.*

But here is the truly striking part. For indices that are at least $3$, the
arrow runs both ways:

**The Fibonacci divisibility equivalence.** *For $m \ge 3$, $F_m$ divides $F_n$
if and only if $m$ divides $n$.* In symbols, for $m \ge 3$,
$$F_m \mid F_n \iff m \mid n.$$

This is a perfect dictionary. Divisibility among the *positions* is exactly
divisibility among the *values*. If you want to know whether $34 = F_9$ divides
some gigantic Fibonacci number $F_n$, you do not need to compute $F_n$ at all —
you just ask whether $9$ divides $n$. The arithmetic of a sequence that grows
exponentially is governed entirely by the humble arithmetic of its index set.

Why $m \ge 3$? Because of a small accident at the bottom of the sequence:
$F_1 = F_2 = 1$, and $1$ divides everything. So $F_2 = 1$ "divides" every
Fibonacci number even though $2$ does not divide every index. Once you climb
past that degenerate ledge — once $F_m \ge 2$ — the dictionary becomes exact.

The engine behind the equivalence is one of the prettiest identities in
elementary number theory: the *greatest common divisor* of two Fibonacci numbers
is itself a Fibonacci number, and its index is the gcd of the original indices:
$$\gcd(F_m, F_n) = F_{\gcd(m,n)}.$$
From here the equivalence almost proves itself. If $F_m \mid F_n$, then
$\gcd(F_m, F_n) = F_m$, so $F_{\gcd(m,n)} = F_m$. Since the Fibonacci numbers are
strictly increasing from index $3$ onward, equal values force equal indices:
$\gcd(m,n) = m$, which is just another way of saying $m \mid n$. The whole
proof is a single squeeze.

---

## The pigeonhole with teeth

The next bridge takes us from Fibonacci numbers to a classic puzzle — but a
version with sharper edges than the textbook one.

Everyone knows the **pigeonhole principle**: if you put $n+1$ pigeons into $n$
boxes, some box holds two pigeons. It is the most innocent statement in all of
mathematics, and also one of the most powerful, because the trick is always in
*choosing the boxes.* Here is a famous application that looks impossible until
you see the right boxes.

**The divisibility pigeonhole.** *Choose any $n+1$ different whole numbers from
the range $1, 2, 3, \dots, 2n$. Then two of your chosen numbers must be in a
divisibility relationship: one divides the other.*

Try it. Take $n = 4$, so the range is $1$ through $8$, and pick five numbers.
Say you try to be clever and avoid divisibility: $\{4, 5, 6, 7, 8\}$. Foiled —
$4 \mid 8$. Try $\{3, 4, 5, 7, 8\}$. Again foiled — $4 \mid 8$. Try
$\{3, 5, 6, 7, 8\}$ — but $3 \mid 6$. No matter how you choose, the trap always
springs. **It is genuinely impossible to pick five numbers from $1$–$8$ with no
divisibility pair.** With only four numbers you *can* dodge it
($\{5, 6, 7, 8\}$ has no divisor pair), so the threshold $n+1$ is exactly sharp.

What are the magic boxes? Every positive integer can be written *uniquely* as an
odd number times a power of two:
$$x = (\text{odd part of } x)\times 2^{k}.$$
For instance $40 = 5 \times 2^3$, $12 = 3 \times 2^2$, $7 = 7 \times 2^0$. Call
the odd factor the **odd part** of $x$. (In the formal development it is defined
by literally dividing out every factor of two:
$\mathrm{oddPart}(x) = x / 2^{v_2(x)}$, where $v_2(x)$ counts the twos in $x$.)

Now here is the key observation: in the range $1$ to $2n$, the only possible odd
parts are the odd numbers $1, 3, 5, \dots, 2n-1$ — and there are exactly $n$ of
them. Those are our $n$ boxes. We are dropping $n+1$ chosen numbers into $n$
boxes labelled by odd parts. By the pigeonhole principle, **two chosen numbers
share the same odd part.** Say they are
$$a = q \cdot 2^{i}, \qquad b = q \cdot 2^{j}, \qquad q \text{ odd}.$$
Whichever exponent is smaller, that number divides the other: if $i \le j$ then
$a \mid b$. The divisibility pair was forced into existence the moment you chose
one number too many.

This is the pigeonhole principle "with teeth": the boxes are not handed to you,
they are *constructed* from the multiplicative anatomy of the integers, and the
same odd-part decomposition that powered the Fibonacci dictionary reappears
here to power a counting bound. That reappearance is the bridge.

---

## Gardens of Eden

The third bridge carries us furthest from where we started — into the theory of
dynamical systems, where states evolve in time according to a fixed rule.

Imagine any process that turns one state of the world into the next: a cellular
automaton ticking forward, a sorting network shuffling toward order, a piece of
software updating its memory. Mathematically it is just a function $F$ from a
set of states to itself. Apply it once, twice, three times; write $F^{[n]}$ for
"$F$ applied $n$ times."

Some states have a peculiar property: **nothing maps to them.** No matter what
state you start in, one tick of the rule never produces *this* state. Such a
state can exist as a starting configuration, but it can never be *created* by
the dynamics. Borrowing a phrase from the theory of cellular automata, we call
it a **Garden of Eden** — a configuration you can be in, but can never return
to, a paradise from which there is exit but no entrance.

Formally, $y$ is a Garden of Eden for $F$ if $F(x) \ne y$ for every state $x$.
The first theorem is a clean dichotomy:

**Gardens exist exactly when the rule loses information.** *There is a Garden of
Eden if and only if $F$ is not surjective* — that is, if and only if some state
is never an output. In one line of symbols:
$$(\exists\,y,\ y \text{ is a Garden of Eden}) \iff F \text{ is not onto.}$$

This is almost a tautology once you stare at it — "no preimage" and "not onto"
are two phrasings of the same fact — and that clarity is exactly the point: it
pins down precisely *when* unreachable states appear. They appear precisely when
the rule is not invertible, when it collapses distinct states together and
thereby orphans others.

The really interesting behaviour shows up when the state space is **finite** and
the rule is **monotone and descending**. "Descending" means the rule never
increases anything: $F(x) \le x$ for every state, with respect to some ordering
(think of "energy that only ever decreases," or "disorder that only ever gets
sorted"). "Monotone" means it respects the order: bigger inputs give bigger-or-
equal outputs. Many real systems are like this — physical relaxations, greedy
optimizers, error-correcting decoders all push downhill.

For such systems we get a guarantee with a sharp clock on it.

**The finite descent principle.** *If the state space has $N$ elements and $F$
is monotone and descending, then starting from any state, the orbit reaches a
fixed point in at most $N$ steps.* That is, for every starting state $x$ there is
some $n \le N$ with $F^{[n]}(x) = F^{[n+1]}(x)$ — the process has settled and
will never move again.

Why must it stop so soon? Because each step strictly drops you down the order
until you can drop no further (this is the little lemma that the iterates of a
descending map form a descending chain: $F^{[n+1]}(x) \le F^{[n]}(x)$, always).
A strictly decreasing chain in a set of $N$ elements can have at most $N$
distinct entries, so within $N$ steps two consecutive states must coincide — and
once two consecutive states coincide, the system is frozen forever. The size of
the world is a hard deadline on how long change can last.

These two facts join into a complete picture of finite, downhill dynamics. If
such a rule fails to be onto, then — combining the dichotomy with the descent
principle — it has genuine Gardens of Eden lying *outside its eventual image*:
configurations that are not just hard to reach but **permanently unreachable**,
no matter how long you run the system. And on finite configuration spaces this
sharpens into a finite echo of a deep theorem from the theory of cellular
automata, the **Moore–Myhill** correspondence between surjectivity and
injectivity: for a map on a finite set, *being onto forces being one-to-one.* A
rule on finitely many states cannot create new outputs without first collapsing
old inputs; reachability and reversibility are two sides of one coin.

---

## What the three bridges have in common

Step back and look at the trip we just took. We went from a recurrence about
rabbits, to a puzzle about picking numbers from a hat, to the deep structure of
how finite systems evolve in time. Three different subjects — and yet the same
single idea carried us across every bridge.

**Structure-preserving maps are governed by the structure they preserve.**

- The Fibonacci sequence preserves divisibility, so its internal arithmetic is a
  perfect copy of the arithmetic of the integers: $F_m \mid F_n \iff m \mid n$.
- The odd-part map preserves multiplicative anatomy, so dropping too many numbers
  into too few "odd-part boxes" forces a divisibility pair into existence.
- A monotone descending rule preserves order, so on a finite world it must run
  out of room and freeze, and if it loses information it must leave Gardens of
  Eden behind.

In each case we never had to compute the thing we were asking about. We did not
calculate giant Fibonacci numbers; we did not search through subsets of
integers; we did not simulate dynamical systems for a long time. We reasoned
about *the map's respect for structure* and let the structure deliver the
answer. That is the deepest lesson the bridges teach: the most powerful way to
understand a transformation is often not to run it, but to ask what it keeps
fixed — and let the invariants do the work.

The bridges are open. Walk across them whenever you like.
