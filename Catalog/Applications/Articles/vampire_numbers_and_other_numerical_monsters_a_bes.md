# Vampire Numbers and Other Numerical Monsters: The Curious Case of the Narcissists

## A bestiary of arithmetic creatures

Numbers, like animals, come in species. Some are familiar and domestic — the
primes, the squares, the powers of two that hum quietly inside every computer.
But wander a little off the beaten path and you find stranger creatures: numbers
that devour their own digits, numbers that hide in the dark, numbers that are
made of two perfectly ordinary numbers stitched together. Mathematicians, with a
mixture of mischief and seriousness, have given them monstrous names: vampire
numbers, ghost numbers, zombie numbers.

This article is about one of the most vain and self-absorbed monsters in the
whole menagerie — a creature so obsessed with itself that it can only be built
out of its own reflection. Meet the **narcissistic number**.

## The number that builds itself from its own digits

Take the number **153**. Look at its three digits: 1, 5, and 3. Now cube each of
them — that is, raise each to the third power, because 153 has three digits:

$$1^3 + 5^3 + 3^3 = 1 + 125 + 27 = 153.$$

The number reassembles itself perfectly. Its digits, each lifted to the power of
how many digits there are, add up to exactly the number you started with. It is
as if 153 looked into a mirror, took itself apart digit by digit, raised each
piece to a power, and found that the pieces snapped back together into the same
number. That is pure mathematical narcissism, and so we call such numbers
**narcissistic** (they also go by the more dignified name *Armstrong numbers*,
after the amateur mathematician Michael Armstrong who popularized them).

The formal rule is simple and unforgiving. A number $n$ is narcissistic if, when
you write it in ordinary base ten, the sum of its digits each raised to the power
*equal to the count of digits* gives you $n$ back exactly. Write $d$ for the
number of digits and $a_1, a_2, \dots, a_d$ for the digits themselves; then $n$
is narcissistic precisely when

$$n = a_1^{\,d} + a_2^{\,d} + \cdots + a_d^{\,d}.$$

The power changes with the size of the number. For a three-digit number you cube;
for a four-digit number you raise to the fourth power; for a ten-digit number you
raise to the tenth. This shifting exponent is the secret of the whole story, as
we will see.

The single-digit numbers are narcissistic in a trivial way: $1 = 1^1$, $2 = 2^1$,
and so on up to $9$. They are the babies of the species. The first genuinely
surprising specimens are the three-digit ones. There are exactly four of them:

$$153, \quad 370, \quad 371, \quad 407.$$

Let us verify a couple by hand, because the delight is in the checking:

$$3^3 + 7^3 + 0^3 = 27 + 343 + 0 = 370,$$
$$3^3 + 7^3 + 1^3 = 27 + 343 + 1 = 371,$$
$$4^3 + 0^3 + 7^3 = 64 + 0 + 343 = 407.$$

Three of these — 370, 371, 407 — sit almost next to each other, like a small
family of monsters huddled together on the number line. Then the trail goes cold
for a while, and the next narcissistic numbers appear with four digits (1634,
8208, 9474), then five, and so on.

## The big question: do they ever stop?

Here is where a child's game turns into real mathematics. The narcissistic
numbers seem to thin out as you climb higher. Three digits gave us four of them.
The higher you go, the rarer they become. A natural and slightly eerie question
presents itself:

> **Is the list of narcissistic numbers finite, or does it go on forever?**

Most number-theoretic species are infinite. There are infinitely many primes,
infinitely many squares, infinitely many numbers whose digit sum is a fixed
value. Infinity is the default expectation. So it would be strange — almost
unsettling — if the narcissistic numbers simply *ran out* at some point and never
appeared again, no matter how far you searched.

And yet that is exactly what happens. **The narcissistic numbers are finite.**
There is a largest one, beyond which the species is extinct. It is a striking
fact, and the reason for it is a beautiful piece of reasoning about the tug-of-war
between two ways a number can grow.

## A race between two giants

To see why the narcissists must die out, we stage a race between two quantities,
both depending on $d$, the number of digits.

**Contestant one: how big a $d$-digit number can be.** A number with $d$ digits is
at least $10^{d-1}$ (the smallest $d$-digit number is a 1 followed by $d-1$
zeros). So if $n$ has $d$ digits, then $n \ge 10^{d-1}$. This is the floor under
our number — it cannot be smaller than this.

**Contestant two: how big the digit-power sum can be.** Each digit is at most 9,
and there are $d$ of them, each raised to the power $d$. So the sum of the
digit-powers can be no larger than

$$\underbrace{9^d + 9^d + \cdots + 9^d}_{d \text{ times}} = d \cdot 9^{\,d}.$$

This is the ceiling on the narcissistic recipe — the most the digits can possibly
manufacture.

Now, a narcissistic number is one where the recipe (contestant two) produces
exactly the number itself (which is at least contestant one). For a narcissistic
number to exist with $d$ digits, the ceiling must at least reach the floor:

$$d \cdot 9^{\,d} \;\ge\; 10^{\,d-1}.$$

Here is the punchline. The left side grows like $9^d$; the right side grows like
$10^d$. Ten beats nine. As $d$ marches upward, the $10^{d-1}$ floor eventually
sprints away and leaves $d \cdot 9^d$ hopelessly behind — the extra factor of $d$
is no match for the relentless gap between $9^d$ and $10^d$. Past a certain
number of digits, the ceiling can never reach the floor, and so **no narcissistic
number of that length can exist.**

The crossover is concrete. One can show, by a clean induction, that for every
$d \ge 61$,

$$d \cdot 9^{\,d} \;<\; 10^{\,d-1}.$$

In words: once a number has 61 or more digits, the most its digit-powers can ever
build is strictly less than the smallest number of that length. The recipe can
never catch up. Therefore **every narcissistic number has at most 60 digits**, or
equivalently,

$$n \text{ narcissistic} \;\Longrightarrow\; n < 10^{60}.$$

That is the headline theorem, and it is exactly what has been established with
full rigor: a hard, finite ceiling on the entire species. Below $10^{60}$ there
may be many monsters; above it, there is not a single one, ever.

## How sharp is the ceiling?

The bound of $10^{60}$ is honest but generous. It says "the monsters are extinct
beyond 60 digits," and that is provably true. But where does the *last* monster
actually live?

The answer, found by exhaustive search, is one of the great curiosities of
recreational number theory. The largest narcissistic number is

$$115\,132\,219\,018\,763\,992\,565\,095\,597\,973\,971\,522\,401,$$

a 39-digit colossus. Every digit of this enormous number, raised to the 39th
power, summed together, returns the number itself. After it — nothing. The
species has exactly 88 members in base ten, and this 39-digit titan is the last
of its line. (Proving the *sharp* bound of 39 digits, rather than the safe 60,
is a natural next challenge: the same race argument can be tightened, since the
true crossover where $10^{d-1}$ overtakes $d \cdot 9^d$ happens earlier than
$d = 61$.)

There is something almost poignant about a number being the very last of its
kind. The narcissistic numbers begin with the humble 1, parade through the
elegant trio 370, 371, 407, climb through ever-rarer specimens, and finally
terminate forever at a 39-digit monument to self-reference.

## Why this is more than a parlor trick

It is tempting to file narcissistic numbers under "amusing but pointless." That
would be a mistake, and the reason illuminates a deep theme in mathematics.

The narcissistic property is a **digit-combinatorial** property: it depends not on
the arithmetic structure of a number (its prime factors, its divisors) but on the
*symbols we use to write it down*. Change the base from ten to two and you get an
entirely different population of monsters. Properties like this sit at a strange
crossroads. They are trivial to *state* — a ten-year-old understands the rule for
153 — yet they are often shockingly hard to *analyze*. They are the bridge in our
bestiary's domain: a meeting point between elementary arithmetic and genuine
combinatorial difficulty.

The narcissistic numbers happen to yield to analysis, and beautifully so, because
the exponential race between $9^d$ and $10^d$ is clean enough to settle the
finiteness question outright. But their cousins are not always so cooperative.
Consider the **vampire numbers**, the creatures that gave this bestiary its name.
A vampire number is an even-digit number $v$ that can be written as a product
$v = x \times y$, where the two "fangs" $x$ and $y$ together use exactly the same
digits as $v$ itself. The smallest is

$$1260 = 21 \times 60,$$

where the fangs 21 and 60 reuse precisely the digits 1, 2, 6, 0 of 1260. To hunt
vampire numbers efficiently, you would essentially need to factor numbers and
juggle their digit permutations at the same time — a task believed to be as
genuinely hard as factoring large integers, the very problem on which much of
modern cryptography rests. The same easy-to-state, hard-to-analyze flavor runs
through the **ghost numbers** (products whose factors share *no* digit with the
result, which become vanishingly rare as numbers grow) and the **zombie numbers**
(numbers with multiple factorizations of conflicting character).

So the narcissistic numbers are a kind of gift: a monster we can fully tame. We
can prove, with absolute certainty, that the species is finite, that it lives
entirely below $10^{60}$, and we can exhibit named specimens — 1, 153, 370, 371,
407 — and check each one exactly. They are a proof of concept for a whole
philosophy: that the playful "creatures" of recreational mathematics can be
captured with the full machinery of rigorous proof, and that doing so reveals
real structure underneath the whimsy.

## The shape of the argument, in one breath

If you remember one thing, let it be the race. A narcissistic number must
simultaneously be *large because it has many digits* and *small because its
digit-powers cannot exceed $d \cdot 9^d$*. These two demands are compatible only
for small $d$. The floor $10^{d-1}$ rises faster than the ceiling $d \cdot 9^d$,
and once it pulls ahead — provably, from 61 digits on — the narcissistic numbers
cannot exist. The species is finite, bounded, and, in the end, mortal.

It is a small theorem about a frivolous-sounding object, and that is precisely
what makes it lovely. The monsters of arithmetic are not just curiosities to be
collected. Each one is a tiny laboratory in which the eternal tension between the
*additive* and *multiplicative* lives of numbers — between how we write them and
how they are built — plays out in miniature. The narcissist, vain to the last,
turns out to have taught us something true.
