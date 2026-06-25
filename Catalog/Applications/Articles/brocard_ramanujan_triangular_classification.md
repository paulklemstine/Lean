# Counting Dots: How a Triangle Hides Inside a Factorial

## A puzzle that looks easy and isn't

Some of the most stubborn problems in mathematics can be stated to a curious
child. Here is one of them.

Take a whole number $n$, and form its **factorial**
$$n! = 1 \cdot 2 \cdot 3 \cdots n,$$
the product of all the whole numbers up to $n$. Now add $1$. The question is
disarmingly simple:

> When is $n! + 1$ a perfect square?

A perfect square is a number like $1, 4, 9, 16, 25, \dots$ — a number that is
some integer multiplied by itself. So we are hunting for whole numbers $n$ and
$m$ with
$$n! + 1 = m^2.$$

Let us try a few values. For $n = 4$ we get $4! + 1 = 24 + 1 = 25 = 5^2$. A hit!
For $n = 5$ we get $5! + 1 = 120 + 1 = 121 = 11^2$. Another hit. Press on, and
the trail goes cold until $n = 7$, where $7! + 1 = 5040 + 1 = 5041 = 71^2$. A
third hit.

And then... nothing. People have checked, by computer, every $n$ up to numbers
with more than a billion digits. Not a single new solution has turned up. The
three solutions
$$(n, m) = (4, 5), \quad (5, 11), \quad (7, 71)$$
seem to be the whole story. The values $n = 4, 5, 7$ are called the **Brown
numbers**, and the equation $n! + 1 = m^2$ is **Brocard's problem**, posed by
Henri Brocard in 1876 and independently raised by the legendary Srinivasa
Ramanujan in 1913.

To this day, *nobody knows how to prove* that there are no other solutions. It is
one of those rare problems that is easy to state, almost certainly has a simple
answer ("just those three"), and yet resists every attempt at a proof. The aim
of this article is not to claim a solution — that would be a sensation — but to
show you a beautiful way of *re-seeing* the problem through the geometry of dots
arranged in triangles.

## Triangles made of dots

Long before algebra, the Pythagoreans drew numbers as patterns of pebbles. Stack
pebbles in rows of $1, 2, 3, \dots, y$ and you get a triangle. The total number
of pebbles is the **$y$-th triangular number**:
$$T_y = 1 + 2 + 3 + \cdots + y = \frac{y(y+1)}{2}.$$

The first few are
$$T_0 = 0,\quad T_1 = 1,\quad T_2 = 3,\quad T_3 = 6,\quad T_4 = 10,\quad T_5 = 15,\quad \dots$$
Picture $T_4 = 10$: a row of $4$, then $3$, then $2$, then $1$ — the classic
ten-pin bowling rack. These are among the oldest "shapes" in mathematics, the
two-dimensional cousins of the square numbers.

Triangular and square numbers have a famous, ancient relationship. If you take a
triangular number, multiply it by $8$, and add $1$, you *always* get a perfect
square:
$$8 T_y + 1 = (2y + 1)^2.$$

Try it. With $y = 3$: $8 \cdot 6 + 1 = 49 = 7^2$, and indeed $2 \cdot 3 + 1 = 7$.
With $y = 5$: $8 \cdot 15 + 1 = 121 = 11^2$, and $2 \cdot 5 + 1 = 11$. This is not
a coincidence; it is an identity, true for every $y$, and it is the secret engine
of everything that follows. Geometrically, eight copies of a triangle, plus a
single extra dot in the centre, reassemble exactly into a square of odd side.

What is remarkable is that this works *in reverse* too. The number $8T_y + 1$ is
not just *some* square — the construction can be run backwards to give a complete
test:

> **A whole number $t$ is triangular if and only if $8t + 1$ is a perfect
> square.**

So triangularity, a geometric property about stacking pebbles, is detected by a
single arithmetic test: multiply by eight, add one, and ask "is this a square?"
This is the kind of clean, two-way street — geometry on one side, arithmetic on
the other — that mathematicians treasure.

## The bridge to Brocard

Here is where the two stories collide. Brocard's problem asks when $n! + 1$ is a
square. The triangular test says $8t + 1$ is a square exactly when $t$ is
triangular. These look like the same shape of question — and they are.

Watch what happens. For $n \ge 4$, the factorial $n!$ is always divisible by $8$
(because the product $1\cdot 2 \cdots n$ contains the factors $2$ and $4$, whose
product is already $8$). So we may form $n!/8$. Setting $t = n!/8$, the
triangular test reads: $8 \cdot (n!/8) + 1 = n! + 1$ is a square exactly when
$n!/8$ is triangular. We have arrived at a perfect dictionary:

> **For $n \ge 2$, the number $n!/8$ is a triangular number if and only if
> $n! + 1$ is a perfect square.**

In other words, *the Brown numbers are precisely the values of $n$ for which a
factorial-eighth lands on a triangle of dots.* Brocard's problem, an equation
about squares and factorials, becomes a question about figurate geometry: when
does dividing a factorial by eight give you a number of pebbles that you can
arrange into a perfect triangle?

This is more than a cosmetic rephrasing. It tells us *where* the solutions live
and *what* they look like. Let us translate the three known Brown numbers into
this language.

- For $n = 4$: $\ 4!/8 = 24/8 = 3 = T_2$. The triangle of side $2$.
- For $n = 5$: $\ 5!/8 = 120/8 = 15 = T_5$. The triangle of side $5$.
- For $n = 7$: $\ 7!/8 = 5040/8 = 630 = T_{35}$. The triangle of side $35$.

So the three Brown numbers correspond to triangular indices $2, 5, 35$. The
factorial $7!$, divided by eight, is exactly the number of pebbles in a triangle
$35$ rows tall — a fact you could, in principle, verify by stacking $630$ marbles
in your living room.

And the square roots come along for free. Because $8T_y + 1 = (2y+1)^2$, the
square root $m$ in $n! + 1 = m^2$ is always the *odd* number $m = 2y + 1$:
- $y = 2 \Rightarrow m = 5$ (and indeed $4! + 1 = 25 = 5^2$),
- $y = 5 \Rightarrow m = 11$ (and $5! + 1 = 121 = 11^2$),
- $y = 35 \Rightarrow m = 71$ (and $7! + 1 = 5041 = 71^2$).

The index map is exactly $y \mapsto 2y + 1$. The geometry even predicts that the
square root must be odd: since $n!$ is even for $n \ge 2$, the number
$m^2 = n! + 1$ is odd, so $m$ itself is odd. The geometric picture and the
arithmetic constraint agree perfectly.

## Why the square root is always odd

It is worth dwelling on the small fact that $m$ must be odd, because it shows how
the geometry forces the arithmetic. Suppose $n \ge 2$ and $n! + 1 = m^2$. The
factorial $n!$ is a product that includes the factor $2$, so it is even. Adding
$1$ makes $m^2$ odd. But an even number squared is even and an odd number squared
is odd, so $m^2$ being odd forces $m$ to be odd. Write $m = 2y + 1$. Then
$$m^2 = (2y+1)^2 = 8T_y + 1,$$
and comparing with $m^2 = n! + 1$ gives $n! = 8T_y$ — the triangular witness,
with its index $y = (m-1)/2$ handed to us directly. There is no slack: every
Brown solution *is* a triangular factorial-eighth, and conversely.

## A wall, and a controlled experiment

If the dictionary is exact, why can't we just finish the problem? Because turning
"is $n!/8$ triangular?" into a yes/no answer for *all* $n$ at once is exactly as
hard as Brocard's original question. The translation is a genuine insight — it
gives the solutions a face and a name — but it does not, by itself, slay the
beast. No elementary obstruction is known that rules out a fourth Brown number,
and that is precisely why the conjecture has survived for nearly 150 years.

What we *can* do, rigorously and completely, is two things. First, we can prove
the dictionary itself — the equivalence between triangular factorial-eighths and
factorial successors that are squares — as an unconditional theorem, with no
loopholes. Second, we can carry out a *controlled experiment*: check directly
that there are no new Brown numbers in a chosen range. A careful search confirms
that for every $n$ from $8$ all the way to $50$, the number $n! + 1$ is never a
perfect square — equivalently, $n!/8$ is never triangular. The factorials in this
range are already astronomically large (recall $50!$ has $65$ digits), and not
one of them slips through.

This matters for an honest reason: it shows the equivalence is not an empty
statement. Both sides of the dictionary have *real* examples ($n = 4, 5, 7$) and
*real* non-examples ($n = 8, \dots, 50$). The bridge connects two living
mathematical worlds, not two empty rooms.

## Detectors, rigidity, and the road ahead

Once you see that "multiply by $8$, add $1$" detects triangular numbers, a
mischievous question appears: is $8$ special? Could "multiply by $7$, add $2$" or
some other rule $a t + b$ also detect triangularity by the square test? The
conjecture is that the pair $(a, b) = (8, 1)$ is the *unique* linear
square-detector of triangular numbers — a rigidity statement that says the
discriminant identity $8T_y + 1 = (2y+1)^2$ is the only one of its kind. This is
checkable by a finite search over small candidates and is a tempting target.

Two more avenues use classical number theory to attack Brocard from the side.
One leans on **Wilson's theorem**, which says that for a prime $p$ the factorial
$(p-1)!$ leaves remainder $p - 1$ on division by $p$ — equivalently
$(p-1)! + 1$ is divisible by $p$. If $n = p - 1$ and $n! + 1 = m^2$, then $p$
divides $m^2$, so $p$ divides $m$, forcing $m \ge p$ and $m^2 \ge p^2$. Comparing
$m^2 = (p-1)! + 1$ against $p^2$ gives a growth inequality one can hope to push to
a contradiction for large primes. Another avenue factors $n! = (m-1)(m+1)$ and
observes that $m - 1$ and $m + 1$ are two numbers differing by $2$, so their
greatest common divisor is at most $2$; the factorial must split into two
near-equal, almost-coprime pieces, which grows arithmetically implausible as the
prime content of $n!$ swells. These heuristics make density-zero expectations
believable, even where a full proof remains out of reach.

## Why this is beautiful

Brocard's problem is a reminder that mathematics is not a finished encyclopedia
but a living landscape with unexplored valleys right next to well-trodden paths.
A question a child can ask — *when is one more than a factorial a perfect square?*
— has stood unanswered since the age of steam trains.

But the triangular viewpoint gives us something real: a new pair of eyes. By
recognizing that $8T_y + 1 = (2y+1)^2$, an identity the Pythagoreans could have
drawn in sand, we convert a problem about factorials and squares into one about
pebbles arranged in triangles. The three Brown numbers stop being a random list
and become three specific triangles — of sides $2$, $5$, and $35$ — hidden
inside the factorials $4!$, $5!$, and $7!$.

We have not caught the fourth triangle. Perhaps it does not exist; almost
everyone believes it does not. But now we know exactly what it would have to look
like: a perfect triangle of dots, sitting quietly inside a factorial divided by
eight, waiting — if it is there at all — to be found.
