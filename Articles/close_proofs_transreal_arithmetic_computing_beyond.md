# Dividing by Zero, Safely: A Tour of Transreal Arithmetic

## The forbidden operation

Every child who has ever poked at a pocket calculator eventually types the
same mischievous thing: a number, a division sign, a zero, and the equals key.
The machine flinches. `ERROR`, it says, or `NaN`, or it simply refuses. Somewhere
along the way we are all told the same commandment: *thou shalt not divide by
zero.*

The prohibition is not arbitrary. In ordinary arithmetic, division is the
undoing of multiplication: to say $6 / 2 = 3$ is to say $3 \times 2 = 6$. Ask
for $1 / 0$ and you are asking for a number that, multiplied by zero, gives one.
No such number exists, because *everything* multiplied by zero gives zero. The
question has no answer, and mathematics, being honest, declines to invent one.

But engineers, physicists, and computer scientists cannot always afford to
decline. A control program that halts the instant a sensor reads zero is a
liability. A spreadsheet that corrupts an entire column because one cell divided
by an empty one is a nuisance. And so a recurring dream keeps returning to
mathematics: what if division by zero were simply *allowed*? Not as a mistake,
not as an exception to be trapped, but as an ordinary operation with an ordinary
answer — an answer that never crashes, never throws, and never leaves a gap in a
formula?

This article is about one of the most complete realizations of that dream:
**transreal arithmetic**. It is a number system, invented and championed most
famously by James Anderson, in which *every* arithmetic expression has a value —
including $1/0$, including $0/0$, including $\infty - \infty$. Nothing is ever
undefined. The price of this total safety is subtle and beautiful: some of the
most familiar laws of algebra quietly stop being true. Understanding exactly
which laws break, and what new structure rises in their place, is the real
story.

## Three new numbers

The transreal numbers, written $\mathbb{T}$, are the ordinary real numbers with
three new symbols added:

$$\mathbb{T} = \mathbb{R} \cup \{\, -\infty,\ \Phi,\ +\infty \,\}.$$

Two of the newcomers are old friends dressed up: $+\infty$ (positive infinity)
and $-\infty$ (negative infinity). The genuinely new one is $\Phi$, pronounced
"nullity." It is the value the system assigns to the questions that even
infinity cannot answer.

The definitions are chosen so that division is always legal:

$$\frac{1}{0} = +\infty, \qquad \frac{-1}{0} = -\infty, \qquad \frac{0}{0} = \Phi.$$

That last equation is the heart of the matter. The expression $0/0$ is the most
notorious of all: unlike $1/0$, which "wants" to be enormous, $0/0$ points
nowhere at all. Any number times zero is zero, so *every* number is an equally
good candidate for $0/0$ — which is to say none is. Transreal arithmetic refuses
to pick a favorite and instead hands you $\Phi$, a brand-new object whose entire
job is to mean "no consistent answer here."

Once $\Phi$ exists, the rest of the system is forced. Nullity is *contagious*:
touch it with any operation and the result is nullity again.

$$\Phi + t = \Phi, \qquad \Phi \times t = \Phi, \qquad -\Phi = \Phi, \qquad \frac{1}{\Phi} = \Phi \qquad \text{for every } t \in \mathbb{T}.$$

This is exactly the behavior of the `NaN` ("not a number") that lurks inside
every floating-point chip in every computer you own. The resemblance is not a
coincidence: the international standard for computer arithmetic quietly
implements a close cousin of the transreal idea, precisely so that a single bad
division does not bring a calculation to its knees.

## The arithmetic of the edges

To make the system total, we must say what happens at the two infinite edges.
The rules are the ones your calculus instructor would recognize as the
"determinate forms":

- Adding a finite number to an infinity leaves the infinity unchanged:
  $(+\infty) + 5 = +\infty$.
- Like infinities reinforce: $(+\infty) + (+\infty) = +\infty$.
- **Opposite infinities cancel into nullity:** $(+\infty) + (-\infty) = \Phi$.
- A positive number scales an infinity; a negative number flips it:
  $2 \times (+\infty) = +\infty$, $\ (-3) \times (+\infty) = -\infty$.
- **Zero times an infinity is nullity:** $0 \times (+\infty) = \Phi$.

Those two boldfaced rules — $\infty - \infty = \Phi$ and $0 \times \infty = \Phi$
— are the transreal system's way of confessing that some questions are genuinely
indeterminate. Instead of crashing, it writes down $\Phi$ and marches on. The
crucial promise is kept: **every expression has a value.** There are no error
states, no exceptions, no forbidden inputs. A formula in transreal arithmetic is
a total function; it always returns.

## What breaks: the quiet death of the ring axioms

Here is where the story turns. The ordinary real numbers are what algebraists
call a *field*: addition and multiplication interlock through a short list of
laws — associativity, commutativity, the existence of negatives and reciprocals,
and the distributive law $a(b+c) = ab + ac$ that binds the two operations
together. These laws are the bedrock on which all of algebra is built. Adding
three new numbers to make arithmetic total shatters that bedrock in three
precise places.

**1. Infinity has no opposite.** In the reals, every number $x$ has a partner
$-x$ that cancels it: $x + (-x) = 0$. Not so for infinity. Add anything at all to
$+\infty$ and you never get back to zero:

$$(+\infty) + t \in \{\, +\infty,\ \Phi \,\} \quad \text{for every } t \in \mathbb{T}.$$

Adding a finite number, or $+\infty$ itself, gives $+\infty$; adding $-\infty$ or
$\Phi$ gives $\Phi$. Zero is never among the outcomes. So the equation
$(+\infty) + t = 0$ has *no solution*, and the transreals are no longer a group
under addition. The most basic algebraic move — "subtract from both sides" —
loses its guarantee.

**2. Zero stops annihilating.** In any ring, $0 \times x = 0$, always. This is
the law that makes zero *zero*. In the transreals it fails at the edges:

$$0 \times (+\infty) = \Phi \neq 0.$$

Multiplying by zero no longer reliably erases what it touches.

**3. The distributive law fails.** This is the deepest break, because
distributivity is the single law linking addition to multiplication. Watch it
collapse with concrete numbers. Take $a = +\infty$, $b = 1$, $c = -\infty$. On
one side,

$$a \times (b + c) = (+\infty) \times \big(1 + (-\infty)\big) = (+\infty) \times (-\infty) = -\infty.$$

On the other side,

$$a \times b + a \times c = (+\infty)\times 1 + (+\infty)\times(-\infty) = (+\infty) + (-\infty) = \Phi.$$

One route gives $-\infty$; the other gives $\Phi$. They disagree. The
distributive law — the rule every schoolchild uses to expand brackets — is
simply false in transreal arithmetic. You may not, in general, "multiply out."

Put together, these three failures are decisive: **the transreal numbers are not
a ring, not a field, and not even a group.** The comforting scaffolding of
ordinary algebra does not survive contact with total division.

## What survives: the wheel next door

If the ring laws die, is there any algebraic order left, or is it all chaos? The
answer is one of the loveliest surprises in the subject. When mathematicians
sat down to ask *what structure can possibly host a total division operation*,
they arrived — independently of Anderson's transreals — at a notion called a
**wheel**. The name is a pun: the symbol for the structure, $\odot$, looks like a
wheel, and the archetypal wheel is the number line bent into a circle so that
$+\infty$ and $-\infty$ meet at a single point $\infty = 1/0$, with one extra
"hub" element $\bot$ (the wheel's version of nullity) sitting at the center.

A wheel keeps *modified* versions of the broken laws. In a ring one writes
$0x = 0$; a wheel only promises the weaker, always-true statement

$$(x + y)\,z + 0\,z = x\,z + y\,z,$$

where the extra term $0z$ is precisely the correction that bookkeeps the places
where an ordinary ring would have divided by zero. A wheel also equips division
with an honest algebraic identity: reciprocal is an *involution*, meaning
$1/(1/x) = x$ for **every** element without exception. Wheels are, in a precise
sense, the most general algebraic structures in which you can divide by anything
at all and still reason systematically.

So a natural question is whether the transreals simply *are* a wheel. Here the
investigation delivers a sharp and instructive verdict: **they are not, and the
reason is illuminating.** Two fingerprints distinguish them.

First, wheels bend the two infinities into one, so in a wheel adding infinity to
itself lands on the hub: $\infty + \infty = \bot$. The transreals, by contrast,
keep their infinities *signed* and *directed*, so

$$(+\infty) + (+\infty) = +\infty, \qquad \text{not } \Phi.$$

Transreal arithmetic remembers which way infinity points; a wheel deliberately
forgets.

Second, in a wheel reciprocal is a perfect involution. In the transreals it is
*almost* one but not quite. Running the reciprocal twice returns the original
number for finite values, for zero ($1/(1/0) = 1/\infty = 0$), and for $+\infty$
($1/(1/\infty) = 1/0 = +\infty$) — but it *fails* at negative infinity:

$$\frac{1}{\,1/(-\infty)\,} = \frac{1}{0} = +\infty \neq -\infty.$$

Because $1/(-\infty) = 0$ and $1/0 = +\infty$, the trip back loses the minus
sign. Reciprocal is total, but the sign of infinity leaks away — the very price
of insisting on signed infinities.

The picture that emerges is therefore richer than "transreals = wheel." The
wheel is the pristine, symmetric algebraic ideal of total division: it obeys
clean laws but forgets the direction of infinity. The transreals are a more
*physical*, direction-aware system: they remember whether a quantity blew up
toward $+\infty$ or $-\infty$, which is exactly what a scientist tracking an
overflow wants — but that memory is precisely what forces them to break the
wheel's clean involution and the ring's clean distributivity. The two systems
are two different, principled answers to the same dream, and seeing exactly where
they diverge tells you what each one is really *for*.

## What survives from analysis

Algebra is not the only thing at stake. Does calculus — limits, continuity, the
theorems that make the real line so powerful — survive the move to $\mathbb{T}$?

Geometrically, the transreal line is easy to picture. Strip away nullity and you
are left with $\mathbb{R} \cup \{-\infty, +\infty\}$, the *extended real line*,
which is just the closed interval $[-\infty, +\infty]$ — a compact segment with
two capped ends, exactly the setting in which calculus teachers already draw
limits "to infinity." Nullity $\Phi$ then sits off to the side as an **isolated
point**, disconnected from everything else. So the whole system looks like a
tidy segment with one lonely dot floating beside it:

$$\mathbb{T} \;\cong\; [-\infty, +\infty] \ \sqcup\ \{\Phi\}.$$

This shape explains at a glance which analytic facts survive and which do not.
On the segment $[-\infty,+\infty]$, the classical results carry over: it is
compact, so a continuous real-valued function attains a maximum and a minimum,
and the intermediate value theorem holds because the segment is connected. But
the moment $\Phi$ enters, connectedness is lost — you cannot walk continuously
from an ordinary number to nullity — so any theorem that relies on the number
system being all-of-one-piece must be restricted away from $\Phi$.

The arithmetic operations themselves are continuous *exactly where you would
hope and nowhere you shouldn't be*. Addition is continuous everywhere except at
the clash points where opposite infinities meet; multiplication is continuous
except where zero meets an infinity. And at precisely those discontinuities the
system returns $\Phi$. In other words, **nullity is the value transreal
arithmetic assigns to the classical indeterminate forms $\infty - \infty$ and
$0 \times \infty$** — the very expressions that a first calculus course flags as
"you must do more work here." The transreals do not resolve those
indeterminacies; they *name* them, honestly and totally, and let computation
continue.

## Why bother?

If total division costs us the distributive law, why pursue it at all? Because
totality is worth a great deal in exactly the places where mathematics meets
machinery.

A total arithmetic never faults. There is no input for which the machine must
stop and ask a human what to do. This is the same instinct that led computer
hardware to adopt infinities and `NaN`: a long numerical simulation should not
be destroyed because one intermediate quantity briefly overflowed or one
denominator briefly vanished. If the anomaly is genuinely fatal, $\Phi$
propagates all the way to the answer and flags it; if it was transient, the
computation flows around it. Total arithmetic turns a class of runtime crashes
into ordinary, inspectable data.

There is a philosophical dividend too. By building a *complete* and internally
consistent system in which $1/0$ has a value, transreal arithmetic sharpens our
understanding of *why* ordinary mathematics forbids the operation. The
prohibition, it turns out, is not a law of nature but a design choice: we forbid
division by zero in the reals because we want to keep the field axioms, and the
two desires are incompatible. Transreal arithmetic makes the trade explicit. You
may have totality, or you may have the ring laws, but you may not have both. Once
that is understood, "you cannot divide by zero" transforms from a mysterious
taboo into a precise engineering decision — one you are now free to make
differently, with your eyes open, whenever the application demands it.

That is the quiet radicalism of the idea. It does not so much break the rule
against dividing by zero as *reveal the rule for what it is*: one option among
several, chosen for good reasons, but not the only coherent way to count.
