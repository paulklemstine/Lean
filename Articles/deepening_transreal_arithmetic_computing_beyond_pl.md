# Computing Beyond Plus-and-Minus Infinity

## The rule that everyone breaks

Somewhere in the first weeks of learning arithmetic, a rule is handed down that
is never repealed: *you must not divide by zero.* It is one of the few genuine
taboos of mathematics, enforced with the same seriousness in a primary-school
classroom and in a graduate seminar. And for good reason. If we allowed
$1/0$ to be some ordinary number $c$, then $1 = 0 \cdot c = 0$, and the whole
edifice of arithmetic collapses into a single point.

But the taboo has a cost, and the cost is paid every day by the machines that
run our world. A spreadsheet, a control system, a piece of scientific code —
each is a long chain of arithmetic operations, and any one of them might, on the
wrong input, try to divide by zero. The mathematician's answer ("that
expression is simply undefined") is not an answer a computer can act on. The
program must *do something*: crash, throw an exception, or silently produce
nonsense. Engineers have spent decades building elaborate machinery — the
special values `NaN` ("not a number") and $\pm\infty$ of floating-point
arithmetic — precisely to keep a stray division from bringing down an aircraft's
flight computer.

This raises a genuinely interesting question. What if, instead of treating
division by zero as a forbidden act, we treated its result as *another number* —
a full citizen of an enlarged number system, with its own arithmetic rules?
Could we build a system in which **every** operation, including $1/0$ and even
$0/0$, always returns an answer, and in which the machine never has to stop?

The transreal numbers are exactly such a system. They enlarge the familiar real
line with three new symbols and lay down rules so total that no computation can
ever fail. The natural next question — and the subject of this article — is
brutally honest: *once you buy totality, what do you lose?* Which of the
beautiful laws of ordinary arithmetic survive the extension, and which ones
shatter? The answer turns out to be sharp, surprising, and beautiful.

## Three new numbers

Start with the ordinary real line $\mathbb{R}$ and adjoin three new symbols:

- $+\infty$ — positive infinity,
- $-\infty$ — negative infinity, and
- $\Phi$ — a value called **nullity**, which is what we shall let $0/0$ equal.

The resulting set,
$$\mathbb{T} = \mathbb{R} \cup \{+\infty,\ -\infty,\ \Phi\},$$
is the set of **transreal numbers**. The first two newcomers are familiar in
spirit from calculus. The third, nullity, is the crucial innovation. It is the
answer to those expressions that are not merely large but genuinely
*indeterminate*: $0/0$, and $+\infty + (-\infty)$, and $0 \cdot \infty$.

The single most important property of $\Phi$ is that **it is contagious**. Once
nullity enters a calculation, it never leaves. For every transreal $x$,
$$\Phi + x = \Phi, \qquad \Phi \cdot x = \Phi.$$
This is not an arbitrary choice; it is what makes the system honest. Nullity
means "this computation has gone irretrievably indeterminate," and no later
addition or multiplication can repair that. In programming terms, $\Phi$ is a
sticky error flag that propagates automatically to the final answer, so a single
poisoned step is always visible at the end.

With that principle in hand, we can write down the complete rules.

**Addition.** On ordinary reals, addition is unchanged. The infinities behave as
one expects — $+\infty$ plus any finite number is still $+\infty$, and likewise
for $-\infty$ — with one decisive exception:
$$(+\infty) + (-\infty) = \Phi.$$
The clash of opposing infinities is indeterminate, so it produces nullity. And,
as always, anything involving $\Phi$ yields $\Phi$.

**Multiplication.** Again ordinary on the reals. The product of two infinities
follows the sign rule you would guess: $(+\infty)\cdot(+\infty)=+\infty$,
$(+\infty)\cdot(-\infty)=-\infty$, and so on. A nonzero real times an infinity
is an infinity, its sign determined by the sign of the real. The subtle case is
zero:
$$0 \cdot (+\infty) = 0 \cdot (-\infty) = \Phi.$$
Multiplying zero by infinity is the classic indeterminate form, so it, too,
collapses to nullity.

**Negation.** Straightforward: $-(+\infty) = -\infty$, $-(-\infty)=+\infty$, and
$-\Phi = \Phi$.

**Reciprocal.** This is where totality earns its keep. We define
$$\frac{1}{0} = +\infty, \qquad \frac{1}{+\infty} = \frac{1}{-\infty} = 0,
\qquad \frac{1}{\Phi} = \Phi,$$
and $1/a = a^{-1}$ for a nonzero real $a$. Division is then simply
"multiply by the reciprocal," and — crucially — it is now defined for *every*
pair of transreals. In particular $0/0$ becomes $0 \cdot (1/0) = 0 \cdot \infty
= \Phi$, which is exactly the meaning we wanted for nullity in the first place.
The definitions close the loop.

The upshot: in $\mathbb{T}$ there are no forbidden operations. Add, multiply,
negate, and take reciprocals as freely as you like; you will always land back
inside $\mathbb{T}$. A computation can never "fail to be defined."

## What survives

Totality is a strong demand, and one might fear it turns the number system into
a shapeless mush. The pleasant surprise is that a great deal of structure comes
through intact.

**The additive world is a commutative monoid.** Addition on $\mathbb{T}$ remains
commutative and associative, and $0$ remains a neutral element:
$$x + y = y + x, \qquad (x+y)+z = x+(y+z), \qquad 0 + x = x.$$
Every one of these holds for *all* transreals, singular values included. In the
language of algebra, $(\mathbb{T}, +, 0)$ is a **commutative monoid** — the same
kind of structure as the ordinary counting numbers under addition. What it is
*not* is a group: the number $+\infty$ has no additive inverse, because
$(+\infty)+(-\infty)=\Phi \neq 0$. The one law that must be sacrificed is
subtraction-to-zero, and it is sacrificed at precisely one place.

**The multiplicative world is a commutative monoid too.** The identical story
plays out for multiplication: it is commutative and associative, and $1$ is
neutral,
$$x \cdot y = y \cdot x, \qquad (x\cdot y)\cdot z = x\cdot(y\cdot z),
\qquad 1 \cdot x = x,$$
again for all transreals. So $(\mathbb{T}, \cdot, 1)$ is also a commutative
monoid.

**Negation is a perfect homomorphism.** Negation respects both operations, even
at the infinities:
$$-(x+y) = (-x) + (-y), \qquad -(x\cdot y) = (-x)\cdot y = x \cdot (-y),$$
and the two minus signs cancel, $(-x)\cdot(-y) = x\cdot y$. And negation is an
involution: negate twice and you return home, $-(-x) = x$, without exception.

**The real numbers embed faithfully.** The map sending a real $a$ to its copy
inside $\mathbb{T}$ preserves sums and products exactly — it is a homomorphism
for both structures. So $\mathbb{R}$ sits inside $\mathbb{T}$ as a genuine
sub-system, and all ordinary arithmetic is untouched; the three new numbers only
ever come into play when you actually reach for an infinity or a
zero-divided-by-zero.

The headline, then, is that transreal arithmetic is **exactly two commutative
monoids glued together**, one additive and one multiplicative. This is the
precise sense in which the ring axioms fail: what breaks the ring is the
distributive law and the existence of inverses, not commutativity or
associativity. The wreckage is structured, not total.

## Where it breaks — and the surprise inside the break

If everything survived, the story would be dull. It does not, and the way it
breaks is the most interesting part.

**The reciprocal is *almost* an involution.** In ordinary arithmetic,
reciprocation is its own inverse: $1/(1/a) = a$. One might hope the same holds in
$\mathbb{T}$, and it *nearly* does. Take the reciprocal twice, and you return to
where you started — **everywhere except at a single point.** For finite reals it
is clear; for $\Phi$ it is clear ($\Phi$ absorbs). At $+\infty$ it even works:
$1/(+\infty)=0$, and $1/0=+\infty$, so we return. But at $-\infty$ the chain goes
$$-\infty \;\xrightarrow{\ 1/\cdot\ }\; 0 \;\xrightarrow{\ 1/\cdot\ }\; +\infty,$$
and we have arrived at the *wrong* infinity. Both infinities have reciprocal
$0$, so $0$ cannot "remember" which one it came from; and the tie is broken in
favour of $+\infty$. The double reciprocal is therefore the identity precisely
when the input is not $-\infty$. This is a genuinely sharp statement: the entire
failure of the involution is concentrated at one single number.

**Reciprocal and negation almost commute.** One expects $1/(-x) = -(1/x)$, and
indeed this holds for every transreal *except zero*. At zero it fails
spectacularly, and the reason is a fascinating one that touches on a hidden
subtlety of the number line. We are used to thinking there is only one zero. But
the moment we declare $1/0 = +\infty$, we are implicitly treating that zero as a
$0^{+}$, an infinitesimally positive quantity approached from the right. Its
negation, $-0$, is then morally $0^{-}$, approached from the left, whose
reciprocal ought to be $-\infty$. And that is exactly what the arithmetic says:
$$\frac{1}{-0} = +\infty \quad\text{while}\quad -\frac{1}{0} = -\infty.$$
The two disagree. The single symbol "$0$" is quietly carrying a sign, and
reciprocation exposes it. This is not a defect to be patched; it is the system
truthfully reporting that the passage through zero to infinity is inherently
one-sided.

**Order becomes two-dimensional.** On the ordinary real line, of any two
distinct numbers one is larger. The transreals inherit a natural ordering,
$$-\infty \;<\; (\text{every real})\; <\; +\infty,$$
which places the two infinities exactly where intuition demands, as a bottom and
a top of the finite world. But where does $\Phi$ go? Nullity is not large, not
small, not in between. It is simply *not comparable* to anything — not to any
real, not to $+\infty$, not to $-\infty$, not even, in the strict sense, related
to itself by being greater or less. The order on $\mathbb{T}$ is therefore a
**partial** order but not a total one: there exist pairs of numbers, such as
$\Phi$ and $0$, for which neither is $\le$ the other. It is as though the number
line has sprouted an extra point floating off to the side, connected to nothing.

This has a striking consequence. The *extended* real line $[-\infty, +\infty]$,
beloved in analysis, has a greatest element $(+\infty)$ and a least element
$(-\infty)$; every quantity is trapped between them. The transreals do **not**.
Because $\Phi$ floats free and is comparable to nothing, there is *no* greatest
transreal and *no* least transreal: whatever candidate you name for the top,
$\Phi$ is not below it, so it is not really the top. By insisting on totality of
*arithmetic*, we have destroyed totality of *order*. That trade-off — a single,
crisp exchange of one kind of completeness for another — is perhaps the deepest
lesson of the whole construction.

## Why bother?

One might dismiss all this as a curiosity, a party trick for making $0/0$ into a
symbol. But the underlying motive is entirely practical, and it is the same
motive that gave floating-point arithmetic its $\pm\infty$ and its `NaN`. A
system in which every operation is total is a system in which a computation can
be *reasoned about as a whole*, without a thicket of special cases guarding every
division. Nullity, contagious by design, is a mathematically honest error flag:
if the final result of a long calculation is $\Phi$, you know for certain that
something indeterminate happened somewhere along the way, and if it is *not*
$\Phi$, you know that nothing did. That is a guarantee ordinary arithmetic, with
its undefined expressions and its exceptions, cannot give.

But the transreals also offer something for the pure mathematician: a laboratory
for studying *which axioms depend on which*. Ordinary arithmetic bundles
commutativity, associativity, distributivity, inverses, and a total order into
one seamless package, and it is easy to forget that these are logically distinct.
The transreals pull the package apart. They show, concretely, that you can keep
commutativity and associativity of both operations while giving up inverses; that
you can keep a faithful copy of the reals while adding points that break the ring
laws; that the price of a total arithmetic is a non-total order, with the damage
localized to exactly identifiable points — a single failed involution at
$-\infty$, a single sign ambiguity at $0$, a single incomparable value $\Phi$.

There is a slogan often attached to systems like this: *the transreals sit just
below the "wheel" axioms* — the fully algebraic account of division-by-zero
structures. What the results above make precise is *how far* below, and in which
directions. Each classical law that fails, fails at a named and isolated point,
and everything else goes through. That is not the behaviour of a broken theory.
It is the behaviour of a theory that has been pushed to its exact limit and is
reporting, faithfully, what lies on the other side of the oldest taboo in
arithmetic.
