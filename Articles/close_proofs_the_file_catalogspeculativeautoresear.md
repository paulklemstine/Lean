# One Rule to Count Them All: How the Factorial Number System Is Just an Ordinary Positional System in Disguise

## A tale of two number systems

Every child learns to count in base ten. The number $2{,}025$ means
$2\cdot 10^3 + 0\cdot 10^2 + 2\cdot 10^1 + 5\cdot 10^0$. Computers prefer
base two, cryptographers sometimes reach for base sixteen, and the ancient
Babylonians famously used base sixty (which is why an hour still has sixty
minutes). In all of these systems a single number — the *base* — governs the
whole scheme: each place is worth the base times the place to its right.

But there is a stranger, more beautiful way to write numbers, one where the
"base" changes as you move from one digit to the next. It is called the
**factorial number system**, or *factoradic*, and it looks like this. Instead
of powers of ten, the place values are the **factorials**
$$0! = 1,\quad 1! = 1,\quad 2! = 2,\quad 3! = 6,\quad 4! = 24,\quad 5! = 120,\ \dots$$
A factoradic number is a string of digits $c_{k-1}\,\cdots\,c_2\,c_1\,c_0$ whose
value is
$$c_{k-1}\cdot (k-1)! + \cdots + c_2\cdot 2! + c_1\cdot 1! + c_0\cdot 0!.$$
The twist is in the rules for the digits. In base ten every digit runs from $0$
to $9$. In the factorial system the *allowed range grows*: the digit in place
$i$ may be any integer from $0$ up to $i$. So the units digit ($i=0$) must be
$0$; the next digit ($i=1$) may be $0$ or $1$; the next ($i=2$) may be $0$,
$1$, or $2$; and so on.

Try it. The number $17{,}\text{decimal}$ becomes $2\,2\,1\,0$ in factoradic,
because
$$2\cdot 3! + 2\cdot 2! + 1\cdot 1! + 0\cdot 0! = 12 + 4 + 1 + 0 = 17.$$
It works, and — remarkably — **it works uniquely**: every whole number has
exactly one factoradic representation, just as it has exactly one representation
in base ten.

This is not a curiosity for its own sake. The factorial number system is the
natural language of *permutations*. If you want to list all the ways to shuffle
a deck, or to jump straight to the ten-billionth arrangement of a set without
generating the ten billion before it, the factoradic digits are precisely the
instructions you need. It is the engine behind ranking and unranking
permutations, behind the *Lehmer code*, and behind fast combinatorial
generation.

## The question that ties them together

Here is the puzzle at the heart of this article. Base ten, base two, base
sixty — these all obey one fixed rule. The factorial system changes its rule at
every step. They look like different animals. **Are they?**

The answer is a clean and satisfying *no*. Both are instances of a single,
more general construction, and once you see that construction, the good
behaviour of *all* of them — the fact that every number has exactly one
representation — falls out of **one theorem, proved once**.

## The unifying idea: mixed-radix systems

Forget about a single base. Instead, hand yourself an entire *sequence* of
bases, one for each place:
$$b_0,\ b_1,\ b_2,\ b_3,\ \dots$$
The place values are no longer powers of a fixed number. Instead, each place is
worth the running product of all the bases below it:
$$P_0 = 1,\qquad P_1 = b_0,\qquad P_2 = b_0 b_1,\qquad P_i = b_0 b_1 \cdots b_{i-1}.$$
A digit string $c_0, c_1, \dots, c_{k-1}$ now stands for the number
$$\text{value} = \sum_{i=0}^{k-1} c_i\, P_i
     = c_0\, P_0 + c_1\, P_1 + \cdots + c_{k-1}\, P_{k-1}.$$
And a representation is **valid** when each digit stays below its *local* base:
$$0 \le c_i < b_i \quad\text{for every } i.$$
This is the **mixed-radix number system**. It is the honest generalization of
everything above:

* Choose every base to be the same number $N$ — that is, $b_i = N$ for all $i$.
  Then the running product is $P_i = N^i$, the digit rule is $0 \le c_i < N$,
  and you have recovered **ordinary base $N$**.
* Choose the bases to be $b_i = i+1$ — that is, $b_0=1,\ b_1=2,\ b_2=3,\dots$.
  Then the running product is
  $$P_i = 1\cdot 2\cdot 3\cdots i = i!,$$
  and the digit rule "$c_i < b_i = i+1$" is exactly "$c_i \le i$". You have
  recovered the **factorial number system**.

The two systems that looked so different are simply two settings of the same
dial. This is the *bridge*: the factorial system is the mixed-radix system with
bases $b_i = i+1$, no more and no less. Concretely, the running product of the
bases $1,2,3,\dots,i$ really is the factorial,
$$\prod_{j=0}^{i-1}(j+1) = i!,$$
so the place values match; and the digit constraint $c_i < i+1$ is literally
the same statement as $c_i \le i$, so the "valid strings" of the two systems are
the same strings. Every factoradic number is a mixed-radix number, and vice
versa.

## The theorem that does all the work

The prize is a single **uniqueness theorem**, stated once for the general
system:

> **Uniqueness of mixed-radix representations.** Fix any sequence of bases
> $b_0, b_1, b_2, \dots$. If two valid digit strings $c$ and $d$ of length $k$
> have the same value — that is,
> $$\sum_{i<k} c_i\, P_i = \sum_{i<k} d_i\, P_i \quad\text{with}\quad c_i < b_i,\ d_i < b_i$$
> — then they are the *same string*: $c_i = d_i$ for every $i < k$.

Why is it true? The argument is short and elegant, and it rests on one
estimate: **a valid string of length $k$ can never reach the next place value.**
Formally, if $c_i < b_i$ for all $i<k$, then
$$\sum_{i<k} c_i\, P_i \ <\ P_k = b_0 b_1 \cdots b_{k-1}.$$
This is the mixed-radix version of the everyday fact that a three-digit decimal
number is at most $999$, which is less than $1000$. Once you have it, uniqueness
follows by peeling digits off the top. Divide the common value by $P_{k-1}$: the
"tail" $\sum_{i<k-1} c_i P_i$ is too small to contribute (that is exactly the
estimate), so the division isolates the top digit and forces
$c_{k-1} = d_{k-1}$. Subtract it off and repeat on what remains. Each step nails
one more digit, and after $k$ steps the two strings are shown to be identical.

The beauty is that **this proof never mentions a specific base**. It uses only
the running product and the digit bound. So the moment you set $b_i = i+1$, the
very same theorem tells you that *factoradic representations are unique* — the
classical fact about the factorial number system — as an immediate corollary.
And setting $b_i = N$ gives you the uniqueness of ordinary base-$N$ numerals in
the same breath. One proof, many number systems.

There is a companion result going the other way, guaranteeing that the general
system is not just consistent but *complete*: **every** number $n$ below the top
place value $P_k$ actually has a representation. You can compute its digits
directly, by repeated division and remainder:
$$c_i = \left\lfloor \frac{n}{P_i} \right\rfloor \bmod b_i.$$
Feed those digits back into the value formula and you recover $n$ exactly.
Together, uniqueness and existence say that a mixed-radix system with $k$ places
is a *perfect dictionary* — a one-to-one correspondence between the numbers
$0, 1, \dots, P_k - 1$ and the valid digit strings of length $k$.

## Why this matters

At first glance, showing that the factorial system "is really" a mixed-radix
system might seem like tidying up. But this kind of unification is exactly how
mathematics gains power. A theorem proved about a *family* is worth far more than
the same theorem proved about a single member, because it applies to members you
haven't even thought about yet.

The mixed-radix framework is genuinely useful in the wild:

* **Combinatorics and algorithms.** The factorial system is the standard tool
  for *ranking* and *unranking* permutations — turning a shuffle into a number
  and back. This is how software can pick "the $10^9$-th permutation" instantly.
  The digit-extraction formula above is that algorithm.
* **Odometers and calendars.** Any counting device whose wheels have different
  sizes — days within months, months within years, seconds/minutes/hours — is a
  mixed-radix odometer. The running-product place values are exactly how you
  convert such a reading to a single count.
* **Coding and hashing.** Mixed-radix encodings pack tuples drawn from
  differently sized alphabets into a single integer with no wasted space,
  precisely because the representation is *unique* and *complete*.

And there is a lesson in the *structure* of the argument itself. The
re-derivation of factoradic uniqueness leans **only** on the general theorem and
the two bridge facts (place values match, digit rules match). It does not quietly
reuse the old, special-case proof. That independence is what makes the
generalization real rather than cosmetic: the abstract theory genuinely *stands
on its own* and *contains* the classical result as one of its shadows.

## The bigger picture

Numbers do not care how we write them. Base ten is a historical accident of
having ten fingers; base two an accident of transistors being easiest to build
with two states. What the mixed-radix viewpoint reveals is that *all* positional
notations — the familiar, the exotic, and the ones nobody has named yet — are
points in one continuous landscape, governed by one law: **the place values are
the running products of the bases, and a digit must stay below its own base.**
From that single law, the guarantee we most want from any notation — that it
names each number once and only once — flows automatically.

The factorial number system, so useful and so odd-looking, turns out not to be
an exception to the rules of ordinary arithmetic. It is one of those rules,
written down for a base that refuses to sit still.
