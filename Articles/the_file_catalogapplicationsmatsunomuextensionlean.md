# The Secret Arithmetic of Supersingular Curves

## When a curve refuses to simplify

Some of the deepest questions in number theory begin with an object as innocent as
a curve of the form
$$y^2 = x^3 + ax + b.$$
These are the *elliptic curves*, and despite the simplicity of their equations they
carry an astonishing amount of arithmetic information. Fermat's Last Theorem, the
security of modern cryptography, and some of the most celebrated conjectures in
mathematics all revolve around them.

To understand a curve, number theorists look at it "one prime at a time." Pick a
prime number $p$ — say $2$, $3$, $5$, $7$ — and reduce the curve modulo $p$, turning
its infinitely many rational points into a finite geometric object over a finite
field. For most primes the reduction is *ordinary*: it behaves tamely, and the tools
of Iwasawa theory describe how the arithmetic grows as you climb an infinite tower of
number fields built on top of $p$. But for a sparse, mysterious set of primes the
reduction is **supersingular**, and everything becomes harder. The clean single
invariant of the ordinary case splinters into a *pair* of intertwined invariants,
traditionally decorated with the symbols $\sharp$ (sharp) and $\flat$ (flat).

This article is about a small but sturdy piece of the supersingular story: the exact
arithmetic that controls how the sharp and flat invariants **grow** as you climb the
tower. It turns out that this growth is governed by a recurrence that most people
first meet as a recreational curiosity — a cousin of the Fibonacci numbers called the
**Jacobsthal sequence** — and that the whole pattern extends, with a single elegant
substitution, from the prime $2$ to every supersingular prime at once.

## Two ladders climbing a tower

Imagine climbing an infinite ladder. At the $n$-th rung you record two numbers: the
*degree* of the flat invariant and the degree of the sharp invariant. These degrees
measure how complicated the arithmetic has become by level $n$ of the tower. For a
supersingular curve at the prime $p$ they are given by remarkably clean sums:
$$\mathrm{flatDeg}_p(n) = \sum_{i=0}^{n-1} p^{2i}
   = 1 + p^2 + p^4 + \cdots + p^{2(n-1)},$$
$$\mathrm{sharpDeg}_p(n) = \sum_{i=0}^{n-1} p^{2i+1}
   = p + p^3 + p^5 + \cdots + p^{2n-1}.$$
In words: the flat degree counts in "base $p^2$" using only even powers of $p$, and
the sharp degree does the same with the odd powers. Every rung adds one more term.

The first thing to notice is how tightly the two ladders are bound together. Factor a
single $p$ out of every term of the sharp sum, and you get the flat sum back exactly:

> **The sharp/flat ratio.** For every prime $p$ and every level $n$,
> $$\mathrm{sharpDeg}_p(n) = p \cdot \mathrm{flatDeg}_p(n).$$

The sharp invariant is not an independent companion to the flat one — it is a perfect
$p$-fold scaling of it. Two ladders, but a single rhythm.

The second thing to notice is that the flat degree has a closed form with no
subtraction and no fractions hiding a division. Multiplying the geometric sum by
$p^2 - 1$ telescopes it into a single power:

> **The base-$p^2$ closed form.** For every prime $p$ and every level $n$,
> $$(p^2 - 1)\,\mathrm{flatDeg}_p(n) + 1 = p^{2n}.$$

This is the honest engine of growth. It says the flat degree is exactly
$(p^{2n} - 1)/(p^2 - 1)$, the number you would write as a string of $n$ ones in base
$p^2$. The arithmetic complexity of the tower doubles its "digit length" in base $p^2$
with every step.

## Enter Jacobsthal

Where do these degrees come from? To answer that we need the recurrence that
supersingular reduction secretly obeys. Define a sequence $q_0, q_1, q_2, \dots$ by
starting with
$$q_0 = 0, \qquad q_1 = 1,$$
and thereafter following the rule
$$q_{n+2} = (p-1)\,q_{n+1} + p\,q_n.$$
When $p = 2$ this is exactly the classical Jacobsthal recurrence
$q_{n+2} = q_{n+1} + 2q_n$, producing the sequence
$0, 1, 1, 3, 5, 11, 21, 43, 85, \dots$ — a well-known relative of Fibonacci in which
each term is the previous term plus *twice* the one before. For a general $p$ we call
$q_n$ the **generalised Jacobsthal sequence**, and it is the arithmetic heartbeat of
the supersingular tower.

Recurrences like this are solved by their *characteristic roots*, and here the roots
are strikingly simple: $p$ and $-1$. This immediately yields a closed form.

> **The Jacobsthal closed form.** For every prime $p$ and every $n \ge 0$,
> $$(p+1)\,q_n = p^n - (-1)^n.$$

The two roots leave their fingerprints in plain sight: $p^n$ from the root $p$, and
the alternating $(-1)^n$ from the root $-1$. Dividing by $p+1$ recovers $q_n$ itself.

A beautiful consequence falls out with almost no work. Add two consecutive Jacobsthal
numbers and the alternating signs cancel:

> **Consecutive numbers sum to a power.** For every prime $p$ and every $n \ge 0$,
> $$q_n + q_{n+1} = p^n.$$

At $p = 2$ this is the familiar $1 + 3 = 4$, $3 + 5 = 8$, $5 + 11 = 16$: neighbouring
Jacobsthal numbers always add up to a power of two. The general statement says the
same magic happens in every base.

## The bridge

We now have two independent-looking stories. On one side, a recurrence — the
generalised Jacobsthal numbers — with a clean closed form. On the other, a pair of
degree sequences measuring the growth of arithmetic invariants along a tower. The
punchline of this work is that they are the *same story*, joined by a single identity.

> **The bridge.** For every prime $p$ and every level $n$,
> $$q_{2n} = (p-1)\,\mathrm{flatDeg}_p(n).$$

The proof is a one-line miracle of factoring. Start from the Jacobsthal closed form
at the even index $2n$:
$$(p+1)\,q_{2n} = p^{2n} - (-1)^{2n} = p^{2n} - 1.$$
Now recall the closed form for the degree: $p^{2n} - 1 = (p^2 - 1)\,\mathrm{flatDeg}_p(n)$.
Since $p^2 - 1 = (p+1)(p-1)$, the two expressions match after cancelling the common
factor $p + 1$, leaving exactly $q_{2n} = (p-1)\,\mathrm{flatDeg}_p(n)$.

The whole argument turns on the elementary factorisation $p^2 - 1 = (p+1)(p-1)$. The
$p+1$ is the denominator in the Jacobsthal closed form; the $p-1$ is the extra factor
that reappears on the degree side. This is why the *even-indexed* Jacobsthal numbers,
and only the even-indexed ones, encode the growth of the flat invariant.

## Why $p = 2$ was hiding the general truth

For a long time this arithmetic was understood only at the prime $2$, through the
classical Jacobsthal sequence. At $p = 2$ the bridge reads
$$q_{2n} = (2-1)\cdot \mathrm{flatDeg}_2(n) = \mathrm{flatDeg}_2(n),$$
because the factor $p - 1$ equals $1$ and quietly disappears. The even Jacobsthal
numbers $J_{2n} = 0, 1, 5, 21, 85, \dots$ *are* the flat degrees $1, 5, 21, 85, \dots$
(counting from level $1$), with no correction at all.

That coincidence was a trap. It made the formula look like a special fact about the
number $2$, when in reality the number $2$ was concealing a factor of $p - 1$ that is
invisible precisely because $2 - 1 = 1$. Restoring the factor reveals the true, prime-
independent law. The role once played by base $4 = 2^2$ is now played by base $p^2$;
the role once played by the ordinary Jacobsthal recurrence is now played by
$q_{n+2} = (p-1)q_{n+1} + p q_n$; and the once-mysterious identification of even
Jacobsthal numbers with flat degrees becomes a transparent statement about the
factorisation of $p^2 - 1$.

## The bigger picture

Why should anyone outside the guild of Iwasawa theorists care? Because this is a
miniature of how mathematics actually advances. A pattern is discovered in one special
case. It looks like an accident of that case. Then someone strips away the accidental
simplifications, and the pattern turns out to be a shadow of a far more general truth
that was there all along.

Here the special case was the prime $2$, and the "accident" was the harmless factor
$p - 1 = 1$. The general truth is that the sharp and flat invariants of *every*
supersingular curve grow according to the same base-$p^2$ arithmetic, tied to a
two-parameter Jacobsthal recurrence, with the sharp degree always exactly $p$ times
the flat degree and the even Jacobsthal numbers always exactly $(p-1)$ times the flat
degree.

The scaffold this builds is deliberately elementary — geometric sums, a linear
recurrence, and the schoolbook factorisation of $p^2 - 1$ — but it is load-bearing.
It is the arithmetic skeleton on which the heavier machinery of supersingular Iwasawa
theory hangs: the sharp and flat $L$-functions, the local twist weights that appear
when you deform a curve, and the conjectural laws that predict how the flat and sharp
invariants behave under those deformations. By pinning down the skeleton exactly, and
for every prime at once, we make those larger conjectures precise enough to state,
test, and eventually prove.

Sometimes the most valuable thing a piece of mathematics can do is take a formula
that looked like a coincidence and show that it never was.
