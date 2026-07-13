# One Rule for Every Number System

## The counters that count differently

Look at an old-fashioned car odometer. Six little wheels, each showing a digit
from $0$ to $9$. Drive one mile and the rightmost wheel clicks forward. When it
passes $9$ it snaps back to $0$ and nudges its neighbor. This is base ten, and
it is so familiar we forget it is a *choice*. There is nothing sacred about the
number ten. We could build a wheel that runs $0$ through $1$ (binary), or $0$
through $F$ (hexadecimal), and everything would still work.

Now imagine a stranger machine. Its rightmost wheel has only **one** position.
The next wheel has **two**. The next has **three**, then **four**, and so on,
each wheel a little taller than the last. It looks like a mistake — a counter
built by someone who could not decide on a base. Yet this lopsided device, the
*factorial number system* or **factoradic**, is one of the most useful counters
in all of combinatorics. It is how computers list every possible shuffle of a
deck, how they turn a whole permutation into a single ordinary number and back
again.

For a long time these two machines — the tidy base-ten odometer and the
ragged factoradic — were taught as separate curiosities. This article is about a
single, clean idea that reveals them to be the **same machine wearing different
clothes**. Once you see the common rule, the deepest facts about ordinary
numerals and the deepest facts about factoradics turn out to be one theorem,
stated once and specialized twice.

## The mixed-radix idea

Here is the unifying picture. Instead of fixing a single base, hand the machine
a whole *list* of bases, one per wheel:

$$ b_0,\; b_1,\; b_2,\; b_3,\; \dots $$

Wheel $i$ shows a digit somewhere in $0, 1, \dots, b_i - 1$. This is called a
**mixed-radix** system, and it contains both of our machines as special cases:

- Choose every base the same, $b_i = N$, and you get ordinary base-$N$ numerals.
- Choose the bases to grow, $b_i = i + 1$, so wheel $0$ has one slot, wheel $1$
  has two, wheel $2$ has three — and you get the factoradic.

The crucial quantity is the **running product**, the total number of distinct
readings the first $k$ wheels can show:

$$ P_k \;=\; b_0 \cdot b_1 \cdots b_{k-1} \;=\; \prod_{i<k} b_i . $$

For base $N$ this product is $N^k$, exactly the count of $k$-digit strings. For
the factoradic something magical happens. The running product telescopes:

$$ \prod_{i<k} (i+1) \;=\; 1 \cdot 2 \cdot 3 \cdots k \;=\; k! . $$

That one line — *the product of the growing bases is a factorial* — is the hinge
on which the whole story turns. It says the factoradic's place values are
precisely the factorials, and it quietly promises that the factoradic will count
exactly the same things factorials always count: arrangements, orderings,
shuffles.

## What a mixed-radix numeral is worth

To read a mixed-radix numeral, weight each digit by the product of all the bases
below it. A digit sequence $c_0, c_1, c_2, \dots$ has **value**

$$ \operatorname{value}(c, k) \;=\; \sum_{i<k} c_i \left( \prod_{j<i} b_j \right) . $$

In base ten the weights are $1, 10, 100, \dots$; in base two they are
$1, 2, 4, 8, \dots$; in the factoradic they are $1, 1, 2, 6, 24, \dots$ — the
factorials again. A digit sequence is called **valid** if every digit fits its
wheel, $c_i < b_i$.

Three facts hold for *any* choice of bases at once, and they are the entire
theory:

1. **Nothing overflows.** Every valid numeral of length $k$ has value strictly
   less than the running product: $\operatorname{value}(c, k) < P_k$. The
   biggest the wheels can show is one turn short of clicking the $(k{+}1)$-th
   wheel.

2. **Everything can be written (existence).** Every whole number $n$ below $P_k$
   *is* the value of some valid length-$k$ numeral — the one you get by the
   schoolbook algorithm of repeated division. Formally, extract the $i$-th digit
   as
   $$ \operatorname{digit}(n)_i \;=\; \left\lfloor \frac{n}{\prod_{j<i} b_j} \right\rfloor \bmod b_i, $$
   and evaluating these digits gives back $n$ exactly.

3. **There is only one way (uniqueness).** If two valid numerals have the same
   value, they are identical digit by digit. No number has two different honest
   representations.

Existence and uniqueness are the yin and yang of every place-value system, and
here they are proved once, in full generality, with no assumption about which
bases were chosen.

## The single bijection behind it all

Combine existence and uniqueness and you get something clean enough to state in
one breath. Let $\prod_{i<k}\{0,\dots,b_i-1\}$ denote the set of all valid digit
tuples of length $k$. Then there is a **perfect one-to-one correspondence**

$$ \{0, 1, \dots, P_k - 1\} \;\longleftrightarrow\; \prod_{i<k} \{0, 1, \dots, b_i - 1\}. $$

In one direction you *read* a number's digits; in the other you *evaluate* a tuple
of digits into a number. Existence says the reading map hits every tuple;
uniqueness says no two numbers read the same. The two operations are exact
inverses. This correspondence is the structural heart of positional notation —
the precise sense in which "a number" and "its string of digits" are two names
for one object.

A pleasant subtlety: the correspondence needs **no** assumption that the bases
are positive. If some wheel has zero slots ($b_i = 0$), then the running product
is zero and *both* sides of the correspondence are empty — the statement holds
vacuously and gracefully, with no special case to carve out.

Counting the two sides gives a bonus identity. The right-hand set obviously has
$b_0 \cdot b_1 \cdots b_{k-1}$ elements, so

$$ \#\Big(\prod_{i<k} \{0,\dots,b_i-1\}\Big) \;=\; \prod_{i<k} b_i . $$

The running product, introduced as a bound, turns out to *be* the number of valid
digit tuples. This is a purely combinatorial reading of the very quantity that
governed the arithmetic.

## Two famous systems fall out for free

Now specialize the one theorem.

**Ordinary numerals.** Set every base to $N$. The bijection becomes

$$ \{0, 1, \dots, N^k - 1\} \;\longleftrightarrow\; \{0,\dots,N-1\}^k, $$

which is exactly the statement that every number below $N^k$ has a unique string
of $k$ base-$N$ digits, and every string of $k$ digits names a number. The
familiar uniqueness and existence of decimal, binary, and hexadecimal notation
are not separate theorems — they are this one, with the bases held constant.

**Factoradics.** Set $b_i = i + 1$. Using the hinge identity $P_k = k!$, the
bijection becomes

$$ \{0, 1, \dots, k! - 1\} \;\longleftrightarrow\; \{0\} \times \{0,1\} \times \{0,1,2\} \times \cdots \times \{0,\dots,k{-}1\}. $$

Every number below $k!$ has exactly one factoradic representation, and the count
of valid factoradic tuples is exactly

$$ \#\big(\text{length-}k\text{ factoradic tuples}\big) \;=\; k! . $$

That last equation is a small marvel. On the left is a combinatorial count; on
the right is the factorial, the number of ways to arrange $k$ objects. The
factoradic tuples are, quite literally, in bijection with a set of size $k!$ —
which is why the factoradic is the natural address system for permutations.

## Why this matters

The payoff is not just tidiness, though tidiness in mathematics is a form of
truth. It is **leverage**. A single, carefully stated theorem about mixed-radix
systems now does the work of an entire shelf of special cases. Prove existence
and uniqueness once, and you have simultaneously proved them for binary, for
decimal, for hexadecimal, for the factoradic, and for every exotic mixed base a
clock ($60, 60, 24, 7, \dots$) or a calendar might use.

The factoradic side has real teeth. Because factoradic tuples correspond exactly
to the numbers $0$ through $k! - 1$, and separately to the $k!$ possible
orderings of $k$ items, the factoradic becomes a dictionary between a plain
counter and the world of permutations. Software that must enumerate arrangements
— scheduling, testing, cryptographic shuffles, the ranking and unranking of
combinatorial objects — leans on exactly this correspondence. Turning a
permutation into a single number (its *rank*) and back (its *unranking*) is the
factoradic bijection in action.

And there is a broader lesson, the kind mathematicians live for. Two objects that
look unrelated — a uniform odometer and a ragged factorial counter — are revealed
to be **the same object seen from two angles** once you find the right vantage
point. The right vantage point here is the mixed-radix system, and the telescope
that brings the factoradic into focus is the humble identity
$1 \cdot 2 \cdots k = k!$. Find the general pattern, prove it once, and watch the
special cases rain down. That is not just good bookkeeping; it is the whole game.

## Where it goes next

The correspondence between factoradic tuples and the numbers below $k!$ is the
first rung of a taller ladder. Those same tuples also encode *permutations*
through their Lehmer codes, so composing the two correspondences yields an
explicit dictionary $\{0,\dots,k!-1\} \leftrightarrow \{\text{arrangements of }k\text{ items}\}$
— a direct, computable ranking of permutations. Beyond that lie the *dynamics* of
these counters: the click-and-carry of "add one" on a digit tuple should
correspond precisely to $n \mapsto n+1$ on the number it names, turning the static
bijection into a moving one, and the natural size order on numbers should match
the dictionary order on their digits. Each of these is another face of the same
unifying idea — that underneath every way of writing numbers there is, in the
end, just one rule.
