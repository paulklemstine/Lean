# When a Fourteen-Sided Number Becomes a Perfect Fourth Power

## A counting puzzle with a surprise ending

Some of the oldest questions in mathematics begin with shapes made of dots.
Arrange pebbles in a triangle and you get the *triangular numbers*
$1, 3, 6, 10, \dots$. Arrange them in a square and you get the *square numbers*
$1, 4, 9, 16, \dots$. Keep going—pentagons, hexagons, and beyond—and you obtain
the **polygonal numbers**, a family that the Greeks already studied and that has
never stopped surprising people.

This article is about one particular member of that family: the
**fourteen-sided** numbers, or *tetradecagonal* numbers. The $n$-th one is

$$P_{14}(n) = 6n^2 - 5n.$$

The first few (for $n = 1, 2, 3, 4, \dots$) are $1, 14, 39, 76, \dots$. Nothing
about them looks special. And yet they hide a beautiful secret. We are going to
ask a deceptively simple question:

> **Which fourteen-gonal numbers are perfect fourth powers?**

A perfect fourth power is a number of the form $t^4$: $0, 1, 16, 81, 256, 625,
\dots$. So we want every integer $n$ for which $6n^2 - 5n$ equals some $t^4$.
Writing it as one equation, we are hunting for all integer solutions of

$$6n^2 - 5n = t^4.$$

You might guess there are infinitely many. You might guess there are none beyond
the trivial $0$ and $1$. Both guesses are wrong, and the truth is far more
charming.

## The complete answer

Here is the entire solution set. There are exactly **five** integer pairs
$(n, t)$ that work:

$$(n,t) \in \{(0,0),\ (1,1),\ (1,-1),\ (-2000,70),\ (-2000,-70)\}.$$

The first three are gentle: $P_{14}(0) = 0 = 0^4$ and $P_{14}(1) = 6 - 5 = 1 =
(\pm 1)^4$. But the last pair is astonishing. Plug in $n = -2000$:

$$P_{14}(-2000) = 6\cdot(-2000)^2 - 5\cdot(-2000) = 24{,}000{,}000 + 10{,}000 =
24{,}010{,}000,$$

and sure enough,

$$70^4 = 70^2 \cdot 70^2 = 4900 \cdot 4900 = 24{,}010{,}000.$$

A single, enormous, isolated coincidence—an integer two thousand steps out into
the negatives where the polygonal number lands *exactly* on the fourth power
$70^4$. After that, nothing. The list is complete: there is no sixth solution,
no matter how far you search. Proving that "nothing else works, ever" is the real
mathematical drama, and it turns on an idea called **descent**.

## Turning a product into a tug-of-war

The secret is to factor. Notice that

$$6n^2 - 5n = n\,(6n - 5).$$

So our equation becomes

$$n\,(6n - 5) = t^4.$$

Now comes the key observation. Ask: do the two factors $n$ and $6n - 5$ share any
common divisor? Suppose a prime $p$ divides both. Then $p$ divides their
combination $6\cdot n - (6n - 5) = 5$. So the *only* prime that could ever be
shared is $5$. Everything hinges on this one prime.

This splits the world into two clean cases.

**Case 1: $5$ does not divide $n$.** Then $n$ and $6n - 5$ have no common factor
at all—they are *coprime*. And here is the magic of coprimality: when two
coprime integers multiply to a perfect fourth power, **each of them must itself
be a fourth power**, up to sign. (Think of it as the prime factorizations not
being allowed to mix: every prime's exponent in the product is a multiple of
four, and because the two factors share no primes, every prime's exponent in
*each* factor is already a multiple of four.) So in this case

$$n = \pm a^4 \quad\text{and}\quad 6n - 5 = \pm b^4$$

for some integers $a, b$. Substituting the first into the second collapses two
unknowns into one tight relationship—a single equation in $a$ and $b$ with no
$n$ left in sight.

**Case 2: $5$ divides $n$.** Write $n = 5m$. A short computation gives

$$P_{14}(5m) = 6\cdot 25 m^2 - 25 m = 25\,m\,(6m - 1),$$

so $t^4 = 25\,m\,(6m-1)$. Since $5$ divides $t^4$, it must divide $t$ itself, so
write $t = 5s$. Dividing through by $625$ leaves

$$m\,(6m - 1) = 25\,s^4.$$

And now history rhymes: $m$ and $6m - 1$ are *again coprime* (any common divisor
would divide $6m - (6m - 1) = 1$, so there is none). The same descent machinery
applies one level down. The structure is self-similar—the equation contains a
smaller copy of itself.

## Two doors, and a quadrant that is bricked shut

After this reduction every solution must walk through exactly one of two doors,
with no overlap and nothing missed:

- the **coprime door** ($5 \nmid n$), where $n$ and $6n - 5$ are each $\pm$ a
  fourth power; or
- the **divisible door** ($5 \mid n$), where $n = 5m$, $t = 5s$, and
  $m(6m - 1) = 25 s^4$.

Inside each door, the chase ends at a famous kind of obstacle: a **Thue
equation**, a polynomial equation in two variables that—by a deep theorem of
Axel Thue from 1909—can have only finitely many integer solutions. Concretely
the coprime positive branch becomes

$$6a^4 - b^4 = 5,$$

whose only humble solution is $a = b = 1$, returning us to $n = 1$. The
divisible branch descends to

$$e^4 - 150\,c^4 = 1,$$

whose nonnegative solutions are $c = 0$ (giving $n = 0$) and $c = 2$, $e = 7$
(giving the spectacular $n = -2000$, since $7^4 - 150\cdot 2^4 = 2401 - 2400 =
1$).

There is one more delicious twist that explains *why* the big solution sits where
it does. Look at the coprime door when $n$ is **negative**. There the relation
becomes

$$b^4 - 6a^4 = 5,$$

and this equation is *impossible*—not just hard, but flatly, provably
impossible. The reason is a parity-style argument modulo $16$. A fourth power,
when divided by $16$, can only leave a remainder of $0$ or $1$. (Even numbers to
the fourth are divisible by $16$; odd numbers to the fourth always leave
remainder $1$.) So $b^4 - 6a^4$ modulo $16$ can only land in the set
$\{0, 1, 10, 11\}$. The number $5$ is not in that set. The door is bricked shut.
**Every** solution with $n < 0$ that is not divisible by $5$ is eliminated in a
single stroke.

Why does the *positive* coprime door not suffer the same fate? Because there the
equation is $6a^4 - b^4 = 5$, and $5 = 6 - 1$ is perfectly attainable—the tiny
solution $a = b = 1$ slips right through. The asymmetry between $+5$ and $-5$
modulo $16$ is the hinge on which the whole classification turns.

## The moral of the story

Step back and admire the shape of the argument. We started with a quadratic
expression set equal to a fourth power—two curves that have no business meeting
more than a handful of times—and we did not solve it by brute force or by luck.
We solved it by *listening to the arithmetic*:

1. **Factor** the polygonal number as a product, $n(6n - 5)$.
2. **Find the only shared prime**, which is $5$, splitting the problem into a
   coprime case and a divisible case.
3. **Exploit coprimality** to force each factor to be a fourth power.
4. **Descend**: the divisible case contains a smaller copy of itself.
5. **Close the doors** with a finiteness theorem and a single elegant
   congruence modulo $16$.

The payoff is a complete and certain census: the fourteen-gonal fourth powers
are exactly $0$, $1$, and $24{,}010{,}000$—no more, no less, forever.

This is a microcosm of modern number theory. The same strategy—factor, isolate
the dangerous prime, force fourth powers by coprimality, descend, and finish with
congruences and finiteness—reaches across an enormous landscape of Diophantine
problems, from the polygonal-number questions that gave us this puzzle to the
celebrated curves at the heart of the field. And it suggests bolder questions
still. Is the *largest* solution **always** divisible by the prime hiding in the
linear term—as $-2000$ is divisible by $5$? Does every polygonal order, for every
power $d \ge 3$, admit only finitely many such coincidences? These are not idle
musings; the machinery above turns them into precise, testable conjectures.

A pile of pebbles arranged in a fourteen-sided shape, two thousand steps into the
negative numbers, lining up perfectly with a fourth power. It sounds like an
accident. It is, in fact, the inevitable verdict of arithmetic—and that is the
quiet wonder of the subject.
