# Numbers That Spell Themselves: The Curious World of Orderly Friedman Numbers

## A puzzle hiding in plain digits

Look at the number $2592$. It seems ordinary — a four-digit integer you might
find on a bus timetable or a price tag. But pause on its digits: $2$, $5$, $9$,
$2$. Now try to build the number back out of *exactly those digits, in exactly
that order*, using only arithmetic:

$$2592 = 2^5 \cdot 9^2.$$

Read the right-hand side left to right: $2$, then $5$, then $9$, then $2$. The
same digits, in the same sequence, glued together with an exponent, a
multiplication, and another exponent — and out pops the original number. The
number, in a very literal sense, *spells itself*.

This is the magic at the heart of **orderly Friedman numbers**, the subject of
this article. They are a rare and beautiful breed of integer that can be
reconstructed from its own digits, used once each, **kept in their natural
reading order**, combined only with addition, multiplication, exponentiation,
parentheses, and the occasional minus sign.

## From Friedman numbers to orderly ones

The story starts with a slightly looser idea, introduced by the mathematician
Erich Friedman. A **Friedman number** is an integer you can rebuild from its own
digits — each digit used exactly once — with the usual operations, *in any
order you like*. The first Friedman number is $25 = 5^2$: take the digits $2$
and $5$, allow yourself to shuffle them, and write $5^2$. Reordering is fine, so
$25$ qualifies. Other early examples include $121 = 11^2$ and $126 = 6 \cdot 21$.

Friedman numbers are already surprisingly common — once integers get large
enough, a positive fraction of them turn out to be Friedman numbers. But there
is a stricter, more elegant cousin. What if you are **forbidden from
rearranging** the digits? What if you must use them strictly in the order they
appear, most significant digit first, exactly as you would read the number
aloud?

A number that passes this stricter test is called an **orderly Friedman number**
(sometimes "nice" or "good" Friedman numbers; catalogued in the Online
Encyclopedia of Integer Sequences as A080035). The orderliness condition is a
real constraint: $25 = 5^2$ does *not* count as orderly, because the expression
$5^2$ reads its digits as $5, 2$ — the reverse of the number's own $2, 5$. To be
orderly you must respect the reading order.

Here are the first orderly Friedman numbers:

$$127,\; 343,\; 736,\; 1285,\; 2187,\; 2502,\; 2592,\; 2737,\; 3125,\; 3685,\; 3864,\; 3972,\; 4096,\; 6455,\; 11264,\; 11664,\; 12850,\; 13825,\; 14641, \dots$$

Each one is a little riddle. Let us solve a few.

## Five worked riddles

**$127 = -1 + 2^7$.** Read the right side: digit $1$ (negated), then $2$, then
$7$ — the digits $1, 2, 7$ in order. The leading minus sign is allowed; it acts
on the first digit, not on the order. And indeed $-1 + 128 = 127$.

**$343 = (3 + 4)^3$.** The digits $3, 4, 3$ appear left to right; $(3+4)^3 =
7^3 = 343$. A perfect cube that rebuilds itself.

**$736 = 7 + 3^6$.** Digits $7, 3, 6$ in order; $7 + 729 = 736$.

**$1285 = (1 + 2^8)\cdot 5$.** Here is a cautionary tale. The "obvious" guess
$1 \cdot 2^8 + 5$ gives $256 + 5 = 261$, not $1285$ — a near miss that fools the
eye. The genuine reading-order expression is $(1 + 2^8)\cdot 5 = 257 \cdot 5 =
1285$. Same digits $1, 2, 8, 5$, same order, correct value. The lesson:
orderliness is unforgiving, and you must check, not guess.

**$2592 = 2^5 \cdot 9^2$.** Our opening example, and arguably the most charming
of all. It is sometimes called a "narcissistic" identity because the equation
$2592 = 2^5 9^2$ uses each digit of $2592$ once, in place.

These five are not folklore — each has been verified as an exact integer
identity, digit order included. They are the anchors of everything that follows.

## How do you teach a computer what "in order" means?

To study these numbers rigorously — and to *prove* statements about them rather
than merely collect examples — we need a precise language for "an expression
built from digits." The trick is to treat an arithmetic expression not as a
string of symbols but as a **tree**.

A digit expression is one of three things:

- a **single digit literal** $d$ (a leaf of the tree),
- a **negation** $-e$ of a smaller expression $e$, or
- a **binary combination** $\ell \mathbin{\mathrm{op}} r$ of two smaller
  expressions $\ell$ and $r$, where the operation $\mathrm{op}$ is one of
  addition, multiplication, or exponentiation.

For instance, $2^5 \cdot 9^2$ is the tree "multiply $(2^5)$ by $(9^2)$", whose
leaves, read left to right, are $2, 5, 9, 2$.

Two simple measurements of such a tree drive the whole theory:

- The **digit sequence** of an expression is the list of its leaves read left to
  right. For $2^5 \cdot 9^2$ it is $[2, 5, 9, 2]$.
- The **leaf count** is just how many digits the tree uses. Here it is $4$.

The value of a tree is computed in the obvious way: a digit evaluates to itself,
a negation flips the sign, and a binary node applies its operation. One small
technical choice: exponentiation uses the whole-number part of its exponent, so
that everything stays inside the integers and there are no awkward fractional
powers to worry about.

With this vocabulary, the central definition becomes crisp. An integer $n$ is an
**orderly Friedman number** when there exists a digit-expression tree such that

1. it uses **at least two** digits (so trivial one-digit "expressions" don't
   count),
2. its digit sequence is **exactly the digits of $n$ in reading order**, and
3. it **evaluates to $n$**.

The ordinary (non-orderly) Friedman property relaxes condition (2) to: the digit
sequence is a **permutation** of the digits of $n$. The only difference between
the two notions is whether you are allowed to shuffle. This makes precise an
intuition that should feel obvious: **every orderly Friedman number is a Friedman
number**, because "the exact order" is a special case of "some order." Order is a
tax, never a discount.

## A first law: leaves and length agree

The very first thing one proves in this language is reassuringly down to earth.
The number of digit-leaves in a tree is *exactly* the length of its digit
sequence:

$$\text{leaf count}(e) = \text{length of the digit sequence of } e.$$

This sounds like a tautology, but it must be proven by induction over the
three ways a tree can be built — and once proven, it becomes the workhorse that
connects "how many digits the expression uses" to "how many digits the number
has." Closely related, every expression has at least one leaf, so the leaf count
is always at least $1$. These twin facts are the bookkeeping that lets us reason
about *sizes*.

One immediate consequence: because an orderly Friedman number's expression must
have at least two leaves, and those leaves are exactly the number's digits in
order, **an orderly Friedman number must have at least two digits** — it is at
least $10$. The smallest one that actually exists is $127$; there are, in fact,
none with exactly two digits, which is why the sequence leaps straight to the
hundreds.

## Pinning down the smallest cases

Why are there no two-digit orderly Friedman numbers? The answer reveals the
flavour of the whole subject. A two-digit number $n = \overline{ab}$ would need
an expression using exactly the digits $a$ and $b$, in that order. With only two
leaves, the tree is tightly constrained: you combine "plus or minus $a$" with
"plus or minus $b$" using a single operation, and you may flip the sign of the
whole thing.

To make this airtight, the formalization isolates the notion of a value being
**reachable from two ordered digits** $a$ and $b$: a value $v$ is reachable if it
equals
$$\pm\big((\pm a) + (\pm b)\big), \quad \pm\big((\pm a) \cdot (\pm b)\big), \quad \text{or}\quad \pm\big((\pm a)^{(\pm b)}\big),$$
where the exponent is again taken as a whole number. Two clean facts make this
notion usable. First, **any** way of combining a $\pm a$ and a $\pm b$ with one
operation lands inside this reachable set — nothing escapes. Second, the reachable
set is **closed under negation**: if $v$ is reachable, so is $-v$. Together they
show that the only values a two-leaf tree (with leaves $a$ then $b$) can produce
are exactly the reachable ones. Checking that none of them equals the two-digit
number $\overline{ab}$ is then a finite, mechanical search over the few hundred
possibilities — and it always comes up empty.

This is the engine that powers a deeper structural result: **an expression with a
single leaf evaluates to plus or minus that single digit, and its digit sequence
is just that one digit.** It is the base case of an inductive ladder. Build it
once, and you can climb to statements about two leaves, then three, then the
whole hierarchy. The two-digit impossibility is the first rung; the same style of
argument, pushed further, is how one would eventually chart the entire sequence.

## Why "in order" is hard — and beautiful

There is something philosophically satisfying about the orderliness constraint.
A Friedman number gets to rearrange its digits like loose Scrabble tiles. An
orderly Friedman number must accept its digits as they are, in the sequence fate
dealt them, and find arithmetic that respects that sequence. It is the difference
between an anagram and a found poem.

This is why orderly Friedman numbers are **rarer** than ordinary ones. Among the
ordinary Friedman numbers below any large bound, only a thinning fraction survive
the order test. The proven implication — orderly implies Friedman — gives one
direction for free. The conjecture that the *ratio* of orderly to ordinary
Friedman numbers shrinks to zero (an "order penalty") is one of the open
questions this work sets up but does not yet settle.

Other tantalizing leads remain. Is the sequence infinite? Almost certainly —
the powers of $5$ look like a promising infinite family, since $3125 = 5^5 =
(3\cdot 1 + 2)^5$ shows $5^5$ rebuilding itself in order. Does the phenomenon
persist in other bases, not just base ten? The size argument (an orderly number
must be at least as large as its base) carries over directly; whether *examples*
always exist in every base is open. And can one "grow" new orderly numbers from
old by prepending neutral digit blocks? These are the frontiers.

## The takeaway

Orderly Friedman numbers sit at a delightful crossroads of recreational
puzzle and serious structure. On the surface they are party tricks: $2592 = 2^5
9^2$, $127 = -1 + 2^7$, $343 = (3+4)^3$. Underneath, they demand a careful theory
of expressions-as-trees, a precise bookkeeping of digit order, and inductive
arguments that bottom out in finite, checkable searches.

The deepest lesson is about *constraint as creativity*. Forbidding rearrangement
does not impoverish the problem — it sharpens it, turning a loose collection of
coincidences into a structured sequence with laws, base cases, and conjectures of
its own. The next time you see a four-digit number, try reading its digits in
order and asking whether they can be made to add up — quite literally — to
themselves. Most of the time they cannot. But every so often, a number quietly
spells its own name.
