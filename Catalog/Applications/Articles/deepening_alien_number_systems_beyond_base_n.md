# Alien Number Systems: Beyond Base-Ten, Beyond Base-Anything

## A counting machine that changes its mind at every step

Imagine an odometer. The familiar one in a car has a row of wheels, each marked
$0$ through $9$. When the rightmost wheel ticks past $9$ it rolls over to $0$ and
nudges its neighbor. Every wheel is identical, every wheel counts to ten, and the
whole device quietly implements what we call **base ten**.

Now imagine an odometer built by an alien engineer who never heard of the number
ten — or of any single, privileged base at all. On this machine the first wheel
counts only to $2$. The second wheel counts to $3$. The third to $4$, the fourth
to $5$, and so on, each wheel a little larger than the last. When the first wheel
overflows it bumps the second; when the second overflows it bumps the third. The
device still counts perfectly: it ticks through the integers $0, 1, 2, 3, \dots$
in exact order, never skipping, never repeating. But no two of its wheels agree on
how high to count.

This is not a thought experiment without a payoff. The "alien" odometer with wheels
of size $2, 3, 4, 5, \dots$ is the **factorial number system**, and it is one of
the most useful counting schemes in all of combinatorics — it is, among other
things, the natural way to number the shufflings of a deck of cards. And it is just
one member of a vast family of **mixed-radix** (variable-base) systems, in which
each position is allowed to carry its own, completely independent base. This article
is about that family: what it is, why it works, and the single clean law from which
all of its magic flows.

## What a positional system really promises

Before we go alien, let us be honest about what ordinary base ten actually promises.
When you write the numeral $723$, you are making a claim:

$$ 723 = 3 + 10\cdot 2 + 10\cdot 10 \cdot 7. $$

Read right to left, the digits are $3, 2, 7$ — units, tens, hundreds. The deeper
promise of a positional system is twofold. First, **every** number can be written
this way (existence). Second, every number can be written this way in exactly **one**
way using valid digits (uniqueness). Existence without uniqueness would be useless:
if $723$ and $1623$ could both name the same quantity, arithmetic would collapse.
Uniqueness is the property that makes a numeral an *identity*, not merely a *hint*.

The remarkable fact — the central result of this work — is that existence and
uniqueness do **not** require all the wheels to be the same size. They require only
that each digit stays below its own wheel's limit. The uniformity of base ten is a
convenience, not a necessity. Strip it away and the machine keeps working.

## The setup: a list of bases and a Horner sum

Let us write down the alien system precisely. The system is specified not by a single
number but by a **list of bases**, least significant first:

$$ bs = [b_0, b_1, b_2, \dots, b_{k-1}]. $$

A **digit list** is another list of the same length,

$$ ds = [d_0, d_1, \dots, d_{k-1}], $$

and the *value* it names is computed by the nested, "Horner" recipe

$$ \mathrm{mval}(bs, ds) \;=\; d_0 + b_0\big(d_1 + b_1\big(d_2 + b_2(\cdots)\big)\big). $$

For ordinary base ten with $bs = [10, 10, 10]$ and $ds = [3, 2, 7]$ this unwinds to
$3 + 10(2 + 10\cdot 7) = 723$, exactly as promised. For the alien factorial machine
with $bs = [2, 3, 4]$ and digits $ds = [0, 2, 0]$ it gives
$0 + 2(2 + 3\cdot 0) = 4$.

Going the other direction — from a number back to its digits — is the *greedy*
extraction every schoolchild knows, generalized. To find the digits of $n$ you
divide by the first base, keep the remainder as the first digit, and recurse on the
quotient with the *remaining* bases:

$$ \mathrm{mdigits}([b_0, b_1, \dots], n) \;=\; (n \bmod b_0) \;::\; \mathrm{mdigits}([b_1, \dots],\ \lfloor n / b_0\rfloor). $$

That single line is the entire encoding algorithm. Notice it never needs the bases to
be equal; it simply consumes them one at a time.

## The capacity of an alien base is a product

How many distinct numbers can a $k$-wheel machine display before it rolls all the way
over? An ordinary base-$b$ odometer with $k$ wheels cycles after $b^k$ steps. The
alien generalization is beautiful and inevitable: a machine with wheels of sizes
$b_0, b_1, \dots, b_{k-1}$ cycles after

$$ \text{capacity} \;=\; b_0 \cdot b_1 \cdots b_{k-1} \;=\; \prod_{i} b_i $$

steps — the **product** of all the bases. The uniform power $b^k$ is just the special
case where every factor is the same. For the factorial machine $[2, 3, 4, \dots, k+1]$
the product telescopes:
$$ 2 \cdot 3 \cdot 4 \cdots (k+1) = (k+1)!, $$
which is why it is called the *factorial* number system. With $k$ wheels it counts
exactly through the $(k+1)!$ arrangements of $k+1$ objects — a hint of the deep link
to permutations we will return to.

## The master law

Everything in this story rests on a single identity, and it is worth stating in plain
words. **Encode a number, then decode it, and you recover the number reduced modulo the
machine's capacity.** Formally, for any list of bases $bs$ and any number $n$:

$$ \boxed{\ \mathrm{mval}\big(bs,\ \mathrm{mdigits}(bs, n)\big) \;=\; n \bmod \textstyle\prod_i b_i.\ } $$

This is the **master reconstruction law**. It says the encode–decode round trip is the
identity *as long as you stay inside the machine's range*, and that beyond the range the
machine simply wraps around — exactly like a real odometer. The proof is a short
induction on the list of bases, and at its heart sits a single elementary fact about
remainders: $n \bmod (b \cdot m) = (n \bmod b) + b\big((\lfloor n/b\rfloor) \bmod m\big)$,
the way a remainder modulo a product splits into a low part and a high part. Peel off
one wheel and the rest follows by recursion. No heavy machinery, no clever trick — just
the arithmetic of division, applied honestly.

From this one law, the two halves of the positional-system promise drop out.

**Existence.** If $n$ is below the capacity, then $n \bmod \prod_i b_i = n$, so decoding
and re-encoding returns $n$ on the nose:

$$ n < \prod_i b_i \;\implies\; \mathrm{mval}\big(bs,\ \mathrm{mdigits}(bs, n)\big) = n. $$

Every number in range *has* a digit representation, and the greedy algorithm finds it.

**Validity.** The digits the greedy algorithm produces are always legal: each digit
$d_i = (\cdots) \bmod b_i$ is, by the very definition of remainder, strictly smaller than
its wheel's base $b_i$ (provided every base is positive). So the machine never produces an
illegal numeral.

## Uniqueness: the other direction

Existence tells us every number has *a* representation. Uniqueness tells us it has only
*one*. To prove it we run the round trip backwards: start from a *valid* digit list, form
its value, then re-extract the digits and check we get back exactly what we started with.

Two facts make this work. The first is a bound: a valid digit list — one in which every
$d_i < b_i$ — names a value strictly below the capacity,

$$ d_i < b_i \text{ for all } i \;\implies\; \mathrm{mval}(bs, ds) < \prod_i b_i. $$

This is the alien generalization of the obvious schoolbook fact that a three-digit
decimal number is at most $999 < 1000$. The largest possible digits are
$d_i = b_i - 1$, and the Horner sum of those maximal digits comes to exactly
$\prod_i b_i - 1$, one short of the capacity — the odometer reading just before it rolls
over.

The second fact is the **uniqueness theorem** itself: extracting digits from the value of
a valid digit list returns the original list unchanged,

$$ d_i < b_i \text{ for all } i \;\implies\; \mathrm{mdigits}\big(bs,\ \mathrm{mval}(bs, ds)\big) = ds. $$

Combined with existence, this says encoding and decoding are perfect mutual inverses on
the legal range. There is exactly one valid numeral per number, and exactly one number per
valid numeral.

## The crowning bijection

We can now state the result that ties the ribbon. Let $\{0, 1, \dots, \prod_i b_i - 1\}$
be the numbers the machine can display, and let $\mathcal{D}$ be the set of all valid digit
lists (every $d_i < b_i$). The two round trips above say precisely that the maps

$$ n \;\longmapsto\; \mathrm{mdigits}(bs, n), \qquad ds \;\longmapsto\; \mathrm{mval}(bs, ds) $$

are inverse to one another. Therefore:

$$ \big\{\,0, 1, \dots, \textstyle\prod_i b_i - 1\,\big\} \;\;\cong\;\; \{\,\text{valid digit lists}\,\}. $$

This is a genuine, honest **bijection** — a perfect one-to-one correspondence between
numbers and their alien numerals. It is the single statement that contains the entire
theory: existence is the surjectivity, uniqueness is the injectivity, and the capacity
$\prod_i b_i$ is the size of both sets. Every classical fact about how we write numbers is
a shadow of this correspondence, cast by the special choice of equal bases.

## Old base ten, recovered as a special case

A good generalization should contain the thing it generalizes. Ours does, exactly. Take the
base list to be $k$ identical copies of $b$ — written $\mathrm{replicate}(k, b)$. Then the
product capacity collapses to a power,

$$ \prod_{i<k} b = b^k, $$

and the alien Horner sum becomes literally the standard base-$b$ evaluation used throughout
the established theory of digits: on a uniform base list, $\mathrm{mval}$ agrees value-for-value
with the classical "evaluate these digits in base $b$" function (as long as you supply at
least as many bases as digits). The alien framework does not *replace* ordinary base
arithmetic; it *contains* it as the slice where every wheel happens to be the same size. As a
consequence the classical positional-system theorem — every $n < b^k$ is reconstructed
exactly from its $k$ base-$b$ digits — falls out as the uniform instance of the master law.

## The factorial machine and the shuffling of cards

The most charismatic alien base is the factorial system $[2, 3, 4, \dots, k+1]$. Its capacity
is $(k+1)!$, and that number is no coincidence: $(k+1)!$ is the number of ways to arrange
$k+1$ distinct objects. The factorial digits of a number turn out to be its **Lehmer code** —
a compact record of how "out of order" a permutation is. Counting from $0$ to $(k+1)! - 1$ in
the factorial machine walks you, in perfect lexicographic order, through every shuffle of a
$(k+1)$-card deck. Want the millionth permutation of a list without generating the first
$999{,}999$? Write one million in the factorial machine and read off its Lehmer code. The
alien odometer is, quite literally, a permutation generator in disguise.

This is the practical face of the theory. Mixed-radix systems power efficient ranking and
unranking of combinatorial objects, clock-and-calendar arithmetic (seconds, minutes, hours,
days each carry their own base), residue-number systems in hardware, and the conversion
between "I want item number $n$" and "I want the configuration $(d_0, d_1, \dots)$" that lies
under any system enumerating structured possibilities.

## Why it matters

There is a quiet philosophical lesson here. We tend to think of base ten as fundamental — a
fact about numbers. It is not. It is a fact about *fingers*. The mathematics underneath is
indifferent to the choice: any list of positive bases at all, equal or not, gives a faithful,
gap-free, collision-free way of naming every number in its range. Uniformity buys
convenience and nothing more.

What the bijection guarantees is the thing we actually care about — that a numeral is a true
name, that decoding undoes encoding, that no quantity wears two badges and no badge sits on two
quantities. And it guarantees this for a whole continent of number systems most people never
knew existed: the factorial system, the primorial system built from the primes
$2, 3, 5, 7, 11, \dots$, the time-and-calendar systems, and infinitely many more. They are all
the same idea wearing different clothes. The single law

$$ \mathrm{mval}\big(bs,\ \mathrm{mdigits}(bs, n)\big) = n \bmod \prod_i b_i $$

is the engine, and the bijection between numbers and valid numerals is what it builds. Base ten
was never the point. The point was the round trip — and the round trip works for aliens too.
