# The Number That Refuses to Change

## A counting problem hidden inside algebra

Take a polynomial, say $f(X) = X^2 - 2$. How many roots does it have? Over the
real numbers there are two, $+\sqrt 2$ and $-\sqrt 2$, and they are genuinely
*different* numbers. That little phrase — "genuinely different" — turns out to
be one of the most subtle ideas in all of algebra. In the friendly world of
ordinary numbers, a polynomial of degree $n$ has exactly $n$ roots (counted
with multiplicity), and almost always they are all distinct. But mathematics has
a stranger country, the world of **characteristic $p$**, where polynomials can
hide their roots inside one another, where a degree-$8$ polynomial can secretly
have a single root repeated eight times, and where the very notion of "how many
different solutions are there?" becomes a deep invariant of the algebra itself.

This article is about one number attached to such a polynomial — call it
$m_f$, the count of *truly distinct* roots — and a small, sharp theorem: this
number is astonishingly stable. You can deform the surrounding algebraic world
in a particular drastic way, watch the degree of the polynomial collapse, watch
roots fuse and vanish, and yet $m_f$ does not so much as flinch. It is a quantity
that refuses to change.

## Characteristic $p$: where arithmetic loops around

To appreciate the puzzle, you need to meet the worlds where it lives. Ordinarily
we count $1, 2, 3, \dots$ forever. But fix a prime number $p$ and imagine an
arithmetic that loops back to zero after $p$ steps: $1 + 1 + \dots + 1$ ($p$
times) equals $0$. This is **characteristic $p$**, and it is not a curiosity —
it is the native language of coding theory, cryptography, and modern number
theory. The simplest example is clock arithmetic on $p$ hours; richer examples
are *function fields* such as $\mathbb{F}_p(t)$, the field of fractions of
polynomials in a variable $t$ with coefficients taken modulo $p$.

In characteristic $p$ something spooky happens to algebra. The "freshman's
dream" comes true:
$$(a + b)^p = a^p + b^p.$$
Every cross term in the binomial expansion is divisible by $p$, so it vanishes.
This single identity is the engine behind everything that follows. It means the
map $a \mapsto a^p$, called the **Frobenius**, is a perfectly behaved
arithmetic operation — and it lets polynomials disguise themselves.

## Separable, inseparable, and the disguise

Consider $f(X) = X^p - t$ over the field $K = \mathbb{F}_p(t)$. Its degree is
$p$, so you might expect $p$ different roots. In fact it has only **one**. If
$\theta$ is any root, so $\theta^p = t$, then the freshman's dream gives
$$X^p - t = X^p - \theta^p = (X - \theta)^p.$$
The polynomial is a perfect $p$-th power of a single linear factor. All $p$
"roots" are the same number $\theta$, stacked $p$ deep. A polynomial like this,
whose roots secretly collapse onto fewer distinct values, is called
**inseparable**. When all roots are distinct — the situation we are used to —
the polynomial is **separable**.

This is where our hero enters. For an irreducible polynomial $f$ in
characteristic $p$, there is a clean structural fact: you can always write
$$f(X) = g\big(X^{p^e}\big)$$
for some separable polynomial $g$ and some exponent $e \ge 0$. The substitution
$X \mapsto X^{p^e}$ is the "disguise"; peeling it off reveals the honest,
separable core $g$. We then define
$$m_f \;=\; \deg g \;=\; \text{(the number of genuinely distinct roots of } f\text{)}.$$
The full degree splits as $\deg f = m_f \cdot p^e$. The factor $m_f$ is the
**separable part** of the degree, and the factor $p^e$ — always a power of the
prime — is the **inseparable part**, a measure of how deeply the roots are
stacked. For $X^p - t$ we have $g(Y) = Y - t$, so $m_f = 1$ and $p^e = p$: one
distinct root, hidden $p$ deep.

There is a fast way to compute $m_f$ by hand: look at the exponents appearing in
$f$, find the largest power of $p$ that divides *all* of them, call it $p^e$, and
then $m_f = \deg f / p^e$. For $f = X^4 + tX^2 + t$ in characteristic $2$, the
exponents are $4, 2, 0$; the largest power of $2$ dividing all of them is $2^1$,
so $m_f = 4/2 = 2$. This polynomial has two distinct roots, each doubled.

## The drastic deformation: purely inseparable base change

Now for the deformation. We are going to *enlarge the field of coefficients* in a
specially violent way. A **purely inseparable extension** $N/K$ is one built
entirely out of the inseparable phenomenon: every new element it adds is a
$p^k$-th root of something already present. The canonical move is to adjoin
$t^{1/p}$ — a $p$-th root of $t$ — turning $K = \mathbb{F}_p(t)$ into
$N = \mathbb{F}_p(u)$ with $u^p = t$.

What does this do to our polynomials? It hands them *new raw material* for their
disguises. Over $K$, the polynomial $X^p - t$ could not be simplified. But over
$N$, where $u = t^{1/p}$ now exists, we have $X^p - t = X^p - u^p = (X - u)^p$,
and the root $u$ is an honest element of $N$. The minimal polynomial of $\theta$
— the simplest equation it satisfies — *collapses from degree $p$ to degree $1$*.
The extension $K(\theta)/K$ had degree $p$; the extension $N(\theta)/N$ has
degree $1$, because $\theta$ was secretly already living in $N$ all along.

So base change can be catastrophic for the **degree**. It can absorb the
inseparable stacking, partly or wholly, and shrink the polynomial dramatically.
Watch it happen at several depths:

- $f = X^2 + t$ in characteristic $2$: degree $2 \to 1$.
- $f = X^4 + tX^2 + t$: degree $4 \to 2$.
- $f = X^8 + t$, base-changed by adjoining $t^{1/4}$: degree $8 \to 2$.

In every one of these the raw degree falls. The total degree of an extension,
that most basic of invariants, is **not** preserved.

## The theorem: $m_f$ does not move

Here is the punchline. Through all of this destruction — degrees halving,
quartering, collapsing by factors of eight — the separable count $m_f$ stays
**exactly the same**.

> **Main Theorem.** Let $K$ be a field of characteristic $p > 0$, let $\theta$
> be any element algebraic over $K$, and let $N/K$ be *any* purely inseparable
> extension. Then the separable invariant of $\theta$ computed over $N$ equals
> the one computed over $K$:
> $$m_{f,\,N} \;=\; m_f.$$

Run the examples above through the theorem and you see it hold every time:

- $X^2 + t$: degree $2 \to 1$, but $m_f = 1 \to 1$.
- $X^4 + tX^2 + t$: degree $4 \to 2$, but $m_f = 2 \to 2$.
- $X^8 + t$: degree $8 \to 2$, but $m_f = 1 \to 1$.

The intuition is beautiful once you see it. The separable count $m_f$ is the
number of *distinct* roots, and the roots of a polynomial all live together in a
single fixed universe — the algebraic closure — regardless of which field we
declare to be the "coefficients." Purely inseparable base change can fuse the
copies of a root that were stacked on top of one another (that is what shrinks
the degree), but it can never *split* one root into two or *merge* two distinct
roots into one. The set of distinct roots is untouched. Counting them gives the
same answer before and after. The inseparable part $p^e$ is malleable clay; the
separable part $m_f$ is bedrock.

## Why anyone should care: an intrinsic criterion

This rigidity is not just pretty — it does real work. There is a natural
question about composite extensions: when does a field built from a separable
piece and an inseparable piece split *cleanly* as the product of its purely
inseparable part and its separable part? Criteria for this kind of splitting are
the bread and butter of the structure theory of fields. The trouble is that such
criteria are often stated using a particular enlarged field $N$, and one always
worries: does the answer depend on *which* $N$ I happened to choose?

The invariance of $m_f$ settles this. Several consequences follow almost for
free:

- **The purely inseparable case is detected by $m_f = 1$.** A simple extension
  $K(\theta)/K$ is purely inseparable — all stacking, no genuine branching —
  *exactly* when $m_f = 1$, i.e. when $f$ has a single distinct root.

- **The criterion is intrinsic.** Because $m_f = 1$ is the test, and $m_f$ does
  not depend on $N$, the statement "$N(\theta)/N$ is purely inseparable" holds if
  and only if "$K(\theta)/K$ is purely inseparable." Whether the base-changed
  extension is purely inseparable is decided by the *original* extension alone,
  with no reference to $N$ whatsoever. The choice of enlargement was a red
  herring; the geometry was intrinsic to $L/K$ from the start.

- **$m_f$ always divides the degree.** Since $\deg f = m_f \cdot p^e$, the
  separable count divides the full degree, and the quotient is a power of $p$ —
  the inseparable degree. This neatly partitions the degree into a rigid part and
  a malleable part.

- **For separable $\theta$, even the full degree is preserved.** If $\theta$ was
  separable to begin with (so $m_f = \deg f$, no stacking at all), there is
  nothing for the base change to absorb, and the degree $[N(\theta):N]$ equals
  $[K(\theta):K]$ on the nose. The degree only ever drops in the presence of
  genuine inseparability — and exactly by the inseparable factor that $N$ manages
  to absorb.

Put these together and a clean dichotomy emerges. The degree of a simple
extension splits into a *separable* part, which is rigid and survives any purely
inseparable enlargement, and an *inseparable* part, a power of $p$, which is soft
and can be eaten away. The two extreme values of $m_f$ — equal to $1$ (purely
inseparable) or equal to $\deg f$ (separable) — are the cases where the splitting
question is trivial; all the genuine content lives in the "mixed" middle, where
$1 < m_f < \deg f$. And because $m_f$ is intrinsic, that trichotomy belongs to
the extension $L/K$ itself, not to any auxiliary choice.

## The shape of an idea

There is a recurring pattern in mathematics that this little theorem embodies
perfectly: when something you care about seems to depend on an arbitrary choice,
look for the part of it that *doesn't*. The degree of an extension feels
fundamental, yet it wobbles under base change. Hidden inside it, though, is a
sturdier quantity — the count of distinct roots — that holds firm. By isolating
that quantity, you convert a fragile, choice-dependent statement into a robust,
intrinsic one.

It is the same instinct that leads physicists to conserved quantities and
topologists to invariants: don't track everything, track the thing that survives.
Here the thing that survives is a humble count — how many roots are *really*
different — and its refusal to change is what makes an entire family of
field-theoretic criteria well-posed. In the strange looping arithmetic of
characteristic $p$, where polynomials wear disguises and degrees melt away under
pressure, $m_f$ stands still. That stillness is the whole point.
