# Alien Number Systems: Counting the Way the Universe Might

## A thought experiment

Imagine a civilization that never invented the ten fingers we count on, and never
settled on a "base" the way we settled on base ten. They might write numbers in a
way that looks utterly foreign — yet, if their system is any good, it must obey one
unbreakable rule: **every number must have exactly one spelling.** No ambiguity. The
string of symbols you write down must point to one, and only one, quantity.

This single requirement — *uniqueness of representation* — is the quiet hero behind
every counting system humans have ever used, and behind a surprising number of
beautiful ones we rarely think about. This article is about one of the most elegant
"alien" systems hiding in plain sight: the **factorial number system**, also called
*factoradic*. Along the way we will see why uniqueness is not obvious, how to prove it
cleanly, and why this strange way of writing numbers turns out to be the natural
language of *shuffling a deck of cards*.

## What "base ten" really means

When you write the number $3{,}721$ in ordinary decimal, you are secretly writing a
sum:

$$3721 = 3 \cdot 1000 + 7 \cdot 100 + 2 \cdot 10 + 1 \cdot 1.$$

The "place values" $1, 10, 100, 1000, \dots$ are the powers of ten, and each digit is
allowed to be anything from $0$ to $9$. That bound — *digits stay below the base* — is
what makes decimal work. If we allowed a digit to reach $10$, we would have two ways to
write the same number (a "$10$" in one column equals a "$1$" in the next), and
uniqueness would collapse.

Binary does the same trick with powers of two and digits $\{0,1\}$. Hexadecimal uses
powers of sixteen with sixteen possible digits. These are all **base-$N$** systems:
one fixed base, repeated forever.

But who said the base has to stay the same in every column?

## A system where the base keeps changing

The factorial number system throws out the idea of a fixed base. Instead, the place
values are the **factorials**:

$$0! = 1, \quad 1! = 1, \quad 2! = 2, \quad 3! = 6, \quad 4! = 24, \quad 5! = 120, \dots$$

Recall that $k! = 1 \cdot 2 \cdot 3 \cdots k$ is the product of the first $k$ positive
integers. The genius is in the digit rule. In position $i$ (counting from zero), the
digit $c_i$ is allowed to range only up to $i$:

$$c_0 \le 0, \quad c_1 \le 1, \quad c_2 \le 2, \quad c_3 \le 3, \dots$$

So the very first digit is always $0$ (it can be at most $0$), the next is $0$ or $1$,
the next is $0$, $1$, or $2$, and so on. The "base" effectively grows by one at every
step. A factoradic value is the sum

$$\text{value} = \sum_{i=0}^{k-1} c_i \cdot i!$$

Let us decode an example. Take the digit string $(c_3, c_2, c_1, c_0) = (4, 0, 1, 0)$ —
wait, that breaks the rule, since $c_3 \le 3$. Let's use a legal one: $(3, 0, 1, 0)$.
Then

$$3 \cdot 3! + 0 \cdot 2! + 1 \cdot 1! + 0 \cdot 0! = 3 \cdot 6 + 0 + 1 + 0 = 19.$$

So $19$ is written "$3010$" in factoradic. Try another: the digits $(2,1,0)$ across
positions $2,1,0$ give $2 \cdot 2 + 1 \cdot 1 + 0 = 5$.

Here is the remarkable fact that makes this a *real* number system and not just a curiosity:

> **Every natural number has exactly one factoradic representation.**

The digit string of length $k$ can represent precisely the numbers from $0$ up to
$k! - 1$, and no two different legal strings ever collide.

## Why uniqueness is the whole ballgame

It is tempting to wave this away as "obvious." It is not. The place values $i!$ are
irregular — they jump from $1$ to $1$ to $2$ to $6$ to $24$ — and the digit bounds
change at every step. Why should the sums never clash?

The key is a beautiful self-balancing identity. The largest number you can build using
only the bottom $k$ digits is achieved by maxing out every digit:

$$\sum_{i=0}^{k-1} i \cdot i! = k! - 1.$$

This is a small gem worth savoring. It says the maximum length-$k$ factoradic value is
exactly *one less* than the next place value $k!$. In our formalization this appears as
the estimate

$$\text{(value of a valid length-}k\text{ string)} < k!.$$

Think about what this guarantees. Suppose you have a long factoradic string and you
want to read off the *top* digit $c_k$, the one multiplying $k!$. The entire rest of the
number — everything below position $k$ — is strictly smaller than $k!$. So it can never
"spill over" and disturb the top digit. To recover $c_k$, you just divide by $k!$ and
take the integer part; to recover everything below, you take the remainder modulo $k!$.
In symbols, for a valid length-$(k{+}1)$ string:

$$\left\lfloor \frac{\text{value}}{k!} \right\rfloor = c_k, \qquad
  \text{value} \bmod k! = (\text{value of the bottom } k \text{ digits}).$$

These two facts — *divide to get the top digit, take the remainder to get the rest* —
are exactly how you read any positional number. They are the splitting identities that
make the whole system tick. And because dividing and remaindering give a single,
unambiguous answer every time, the representation peeled off this way is forced to be
unique. Peel the top digit, recurse on the remainder, and you have read the number with
no choices to make. No choices means no ambiguity.

This is genuinely cleaner than the way uniqueness is often argued. A common textbook
route proves there are exactly $k!$ legal strings, notices there are exactly $k!$ numbers
below $k!$, and concludes by counting that the map is a perfect matching. That works, but
it is *indirect*: it leans on a global counting argument. The splitting approach is
*local* and direct — it never counts anything. It simply shows that the digits can be
extracted, one at a time, by arithmetic, and arithmetic gives one answer.

## The punchline: this is the mathematics of shuffling

Why should anyone outside a puzzle column care about factoradics? Because they are the
hidden skeleton of **permutations** — the orderings of a list.

There are $n!$ ways to arrange $n$ distinct objects. That is the same $n!$ that bounds
the length-$n$ factoradic strings. This is no coincidence. Every arrangement of
$n$ cards corresponds to exactly one factoradic number between $0$ and $n! - 1$, via a
classical encoding called the **Lehmer code**.

Here is the idea. Take a shuffled deck and walk through it card by card. For each card,
count how many cards *after* it are smaller (an "inversion count"). The card in position
$i$ can have between $0$ and $i$ later cards smaller than it — which is *exactly* the
factoradic digit bound $c_i \le i$. The list of these counts is a legal factoradic
string, and the number it encodes is the arrangement's rank in alphabetical
(lexicographic) order.

So factoradics let you do something magical: assign every possible shuffle a unique
serial number from $0$ to $n! - 1$, and convert back and forth instantly. Want the
$1{,}000{,}000$th arrangement of a deck without listing the first $999{,}999$? Convert
$1{,}000{,}000$ to factoradic and read off the permutation. This "unranking" trick powers
combinatorial generators, randomized algorithms, and compression schemes that need to
enumerate orderings without storing them.

The uniqueness theorem we discussed is precisely what makes ranking and unranking
*invertible*: because each number has one factoradic spelling, and each factoradic
spelling names one arrangement, the correspondence between "numbers" and "shuffles" is a
flawless dictionary in both directions.

## A tour of the other aliens

Factoradics are one member of a whole zoo of non-base-$N$ systems, each with its own
uniqueness story:

- **Zeckendorf representation.** Write every number as a sum of *non-consecutive*
  Fibonacci numbers ($1, 2, 3, 5, 8, 13, \dots$). For example, $30 = 21 + 8 + 1$. The
  "no two adjacent Fibonaccis" rule plays the role of the digit bound, and it again
  forces a unique representation. This underlies the Fibonacci coding used in data
  compression, where it gives a self-delimiting code robust to bit errors.

- **Balanced ternary.** Use base three but with digits $\{-1, 0, +1\}$ instead of
  $\{0,1,2\}$. Now $5 = 9 - 3 - 1$, written with a negative digit. Balanced ternary
  needs no separate minus sign — negation just flips every digit — and it rounds with
  beautiful symmetry. Early Soviet computers (the Setun) ran on it.

- **Primorial and Cantor systems.** Replace factorials with products of primes, or with
  any growing sequence of "bases," and the same splitting machinery produces a working,
  unique positional system. Factoradics are the most famous instance of this general
  *mixed-radix* family.

What unites all of them is the lesson of this article: a number system is exactly a
choice of place values together with digit bounds that prevent overflow, and uniqueness
follows whenever you can *peel digits off by division and remainder*. The base does not
have to be constant. It does not even have to be a sequence of numbers you would expect.
It just has to balance.

## The dream of sub-logarithmic counting

There is a tantalizing frontier here. In base ten, a number $n$ needs about
$\log_{10} n$ digits; in any base-$N$ system, roughly $\log n$ digits. Factoradics are
slightly *more* compact for large numbers because their place values grow faster than
any fixed base — $k!$ eventually dwarfs $N^k$. This raises a dizzying question: could a
cleverly chosen "tower" of recursively defined bases represent numbers in *dramatically*
fewer digits — say, on the order of the iterated logarithm $\log^* n$, the absurdly
slow-growing function that counts how many times you must take a logarithm to drop $n$
below $1$?

Such a system would be a kind of holy grail for compression and coding theory: a way to
name astronomically large numbers in a handful of symbols. The factorial system is the
first real step off the base-$N$ island and toward that horizon — proof that the place
values can grow as fast as we dare, as long as the digit bounds keep the spelling
unique.

## The moral

We tend to think of "the number 19" as a fixed thing and "1, 9" as the obvious way to
write it. But $19$ is also "$3010$" in factoradic, "$201$" in base three, and a specific
shuffle of four cards. The numeral is not the number; it is a *language* for the number.
And like any language, what matters is that every sentence has exactly one meaning.

The factorial number system shows that this clarity survives even when we abandon our
most basic assumption — that the base stays the same. Change the place values, change
the digit rules, let the base climb with every column, and as long as each digit can be
recovered by a single division, the dictionary between numbers and their spellings stays
perfect. That robustness — uniqueness from nothing but division and remainder — is the
deep reason mathematics can imagine alien number systems at all, and trust that they
would still, unmistakably, be counting.
