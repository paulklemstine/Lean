# Beyond Power Series: How Mathematicians Tamed the Infinite Hierarchy of Growth

## A world where "infinity" comes in many sizes

Ask a calculus student which grows faster, $x^{100}$ or $e^{x}$, and after a moment's
thought they will tell you: the exponential wins. Not just eventually — overwhelmingly,
crushingly, for all time once $x$ is large enough. This is one of the first genuinely
surprising facts in analysis. A polynomial with an exponent of one hundred, or one
million, or a googol, still loses the race to a humble $e^{x}$.

But why stop there? If $e^{x}$ beats every power of $x$, then $e^{e^{x}}$ — the
exponential of the exponential — beats every power of $e^{x}$. And $\log x$, the
inverse of the exponential, grows so slowly that it loses to *every* positive power of
$x$, even $x^{0.0001}$. We have stumbled into an entire **hierarchy of growth rates**, a
ladder whose rungs are the iterated exponentials and logarithms:

$$\cdots \;\prec\; \log\log x \;\prec\; \log x \;\prec\; x \;\prec\; e^{x} \;\prec\; e^{e^{x}} \;\prec\; \cdots$$

where $\prec$ means "is utterly dwarfed by." Each rung is a *tower height*. The number $x$
itself sits at height $0$; $e^{x}$ is at height $1$; $e^{e^{x}}$ at height $2$; $\log x$
at height $-1$; and so on, stretching to infinity in both directions.

Ordinary mathematics has a beautiful language for describing functions near a point or
near infinity: the **power series**, the Taylor expansions that turn $\sin x$, $e^{x}$,
and countless others into infinite polynomials. But power series are blind to this
hierarchy. A power series can only ever express things in terms of powers of a single
variable — it cannot, even in principle, write down "$e^{x}$ as compared to $x$." The
tower of growth rates lives in a blind spot.

This article is about the language that *can* see the whole tower. It is called a
**transseries**, and it is one of the most elegant ideas in modern asymptotic analysis.
We will build it from scratch, see why it behaves like a number system, and arrive at a
single clean theorem that captures its deepest property: that the operation "substitute
$e^{x}$ for $x$" is not a mere trick of notation but a genuine, structure-preserving
symmetry of the entire universe of growth.

## What a transseries is

Imagine you want to describe the asymptotic behavior of a complicated function — say, how
fast it grows as $x \to \infty$. A power series would offer you building blocks like
$1, x, x^{2}, x^{3}, \dots$ A transseries hands you a vastly richer toolbox. Its building
blocks are **transmonomials**: formal products that may mix every rung of the tower at
once, with arbitrary real exponents,

$$ (e^{e^{x}})^{a_{2}} \cdot (e^{x})^{a_{1}} \cdot x^{a_{0}} \cdot (\log x)^{a_{-1}} \cdot (\log\log x)^{a_{-2}} \cdots $$

Here each $a_{h}$ is a real number, and only finitely many of them are allowed to be
nonzero. A transmonomial is therefore completely described by the list of its exponents,
one for each tower height $h \in \mathbb{Z}$. Mathematically this is a **finitely
supported function** from the integers to the reals, written $\mathbb{Z} \to_{f} \mathbb{R}$:
it assigns a real exponent to each height, with all but finitely many being zero.

A full **transseries** is then a (possibly infinite) sum of such transmonomials, each
multiplied by a real coefficient, arranged so that the terms get asymptotically smaller
and smaller. Just as $1 + x + x^{2} + \cdots$ is an infinite sum of powers, a transseries
might look like

$$ e^{x} + 3x^{2} - 7 + \tfrac{1}{2}\,\frac{1}{\log x} + \cdots $$

with the dominant term $e^{x}$ first, then smaller and smaller contributions trailing
behind. The precise bookkeeping that makes "smaller and smaller" rigorous — even when
there are infinitely many terms — is supplied by a classical construction called a **Hahn
series**, which guarantees the terms are *well-ordered* by size so that addition and
multiplication make sense.

The punchline of the construction is worth stating loudly:

> **The transseries form a field.** You can add them, subtract them, multiply them, and —
> crucially — divide by any nonzero one, exactly as you can with ordinary numbers.

This is what makes transseries a genuine *number system for growth rates*, not just a
notation.

## Comparing growth: the order that runs the show

The soul of the whole construction is how we compare two transmonomials. Which is bigger,
$x^{1000}$ or $e^{x}$? The rule is intuitive and matches the tower picture exactly:
**look at the highest tower height where the two differ; whoever has the larger exponent
there wins.** Tower height trumps everything below it.

This is a *lexicographic* order — the same principle that alphabetizes a dictionary, where
the first differing letter decides the ordering, except here the "letters" are exponents
read from the top of the tower downward. In the formal model the comparison is decided at
the most significant differing height, and three facts pin it down completely. We state
them in plain language and then exactly as they are proved.

**Higher towers always win (`mono_lt_mono_of_height`).** If height $h$ is strictly below
height $h'$, then any transmonomial at height $h$ is dominated by any transmonomial at
height $h'$ that has a positive exponent — no matter how large the lower exponent is.
Formally, writing $\mathrm{mono}(h,a)$ for the transmonomial $(\text{level }h)^{a}$:
$$ h < h' \ \text{ and } \ 0 < a' \ \Longrightarrow\ \mathrm{mono}(h,a) < \mathrm{mono}(h',a'). $$

**Within a height, the bigger exponent wins (`mono_lt_mono_same`).** At a fixed tower
height the comparison reduces to ordinary comparison of exponents:
$$ a < a' \ \Longrightarrow\ \mathrm{mono}(h,a) < \mathrm{mono}(h,a'). $$

**Exp beats every power (`exp_dominates_pow`).** Combining the two, the single most
characteristic fact of the whole theory drops out as a special case. With $\mathrm{mono}(0,a)$
the transmonomial $x^{a}$ and $\mathrm{mono}(1,1)$ the transmonomial $e^{x}$,
$$ \mathrm{mono}(0,a) < \mathrm{mono}(1,1) \quad \text{for *every* real number } a. $$

That last line deserves a pause. No power-series valuation can express it. A power series
measures size by a single integer exponent; it can compare $x^{2}$ to $x^{3}$ but has no
slot for a quantity that beats $x^{a}$ for *all* $a$ at once. The transseries order has
exactly such a slot, and $e^{x}$ lives in it. This is the precise sense in which
transseries go *beyond* power series.

These are not merely formal games. They are anchored in honest real analysis. It is a
classical theorem that every polynomial is eventually negligible against the exponential —
$x^{n}$ is "little-o" of $e^{x}$ as $x \to \infty$ (`isLittleO_pow_exp`) — and that every
power of $e^{x}$ is in turn negligible against $e^{e^{x}}$ (`isLittleO_expPow_expExp`).
The formal order on transmonomials is a faithful mirror of these analytic facts.

## When two expansions are the same

Here is a question that sounds philosophical but has a crisp answer. Suppose two
transseries "agree to all orders" — meaning their difference is asymptotically smaller
than *every* transmonomial, smaller than $x^{-1000}$, smaller than $(\log x)^{-1000}$,
smaller than anything you can name. Must they be the same transseries?

The answer is **yes**, and it is the **asymptotic comparison theorem**
(`agreeToAllOrders_iff_eq`):

> Two transseries agree to all orders **if and only if** they are equal.

Define *agreement to all orders* precisely (`AgreeToAllOrders`): the difference $a - b$
has a valuation strictly above every transmonomial $g$. The valuation of a transseries is
the size of its leading (largest) term; the only way for it to exceed *every* transmonomial
is for there to be no leading term at all — that is, for the transseries to be exactly
zero. So $a - b = 0$, hence $a = b$. Turned around, this says something practically
important: a transseries is **uniquely determined by its asymptotic expansion**. If you
know how a function behaves to every order in this rich language, you know the function's
expansion completely. There is no hidden "beyond all orders" ghost that two different
expansions could share — a phenomenon that genuinely haunts cruder asymptotic frameworks.

This uniqueness is what makes transseries trustworthy as a computational tool: you can
manipulate the expansions term by term, confident that the formal object you produce
pins down a unique answer.

## The headline: substituting $e^{x}$ for $x$ is a symmetry

Now to the centerpiece. There is a natural operation one wants to perform on growth:
**replace the variable $x$ everywhere by $e^{x}$.** Intuitively this "climbs the tower"
by one rung. Under it,

$$ x \;\mapsto\; e^{x}, \qquad e^{x} \;\mapsto\; e^{e^{x}}, \qquad \log x \;\mapsto\; x, $$

and a constant like $7$ stays $7$. Every tower height $h$ is bumped up to $h+1$, while
the real-number coefficients are untouched. Call this operation **exp-substitution**.

The remarkable claim — and the heart of the formalized work — is that exp-substitution is
not a vague heuristic but a bona fide **ring homomorphism** of the transseries field
(`expShift`). That means it respects all the arithmetic at once:
$$ \mathrm{expShift}(u + v) = \mathrm{expShift}(u) + \mathrm{expShift}(v), \qquad \mathrm{expShift}(u \cdot v) = \mathrm{expShift}(u) \cdot \mathrm{expShift}(v). $$
You can substitute $e^{x}$ for $x$ before or after you add and multiply, and you get the
same answer. The whole asymptotic universe is carried onto itself without tearing.

Why is this true, and why is it not obvious? Building such a map requires checking that
the height-shift on the underlying exponent-vectors **preserves dominance** — that it
keeps the all-important comparison order intact. This is the load-bearing lemma
(`shift_lt_iff`):

$$ \mathrm{shift}(x) < \mathrm{shift}(y) \iff x < y. $$

In words: bumping every tower height up by one never changes which transmonomial is
bigger. The reason is beautifully simple once you see it. A lexicographic comparison is
decided at the *first* (most significant) height where two exponent-lists differ. Shifting
all heights by a fixed amount is just relabeling the heights by a monotone bijection — it
slides the whole list rigidly up the tower. Relabeling cannot change *which* position is
the first point of difference, only its name; so the winner of the comparison is unchanged.
The shift is therefore an **order isomorphism** of the value group, which is exactly the
condition needed to upgrade it to a field homomorphism.

From this single structural fact, the concrete behavior follows cleanly. On a one-term
transseries the shift raises the tower height by one (`shift_mono`, `expShift_term`):
$$ \mathrm{expShift}\big((\text{level }h)^{a}\big) = (\text{level } h{+}1)^{a}. $$
Specializing $h$ recovers the intuitive dictionary, now as proved theorems:

- **`expShift_var`:** $\ \mathrm{expShift}(x) = e^{x}$ — *the headline fact*, the precise
  statement that the formal automorphism really is the exp-substitution.
- **`expShift_exp`:** $\ \mathrm{expShift}(e^{x}) = e^{e^{x}}$.
- **`expShift_log`:** $\ \mathrm{expShift}(\log x) = x$.
- **`expShift_C`:** $\ \mathrm{expShift}(r) = r$ for every real constant $r$ — the map
  fixes the scalar field $\mathbb{R}$, as any honest substitution should.

And the map is **injective** (`expShift_injective`): distinct transseries are sent to
distinct transseries. It is an embedding of the asymptotic universe into itself, climbing
the tower by one floor without ever collapsing two growth rates into one.

A small worry deserves an honest answer: is "exp-substitution is a homomorphism" merely a
restatement of some off-the-shelf machinery? No. The entire content is the verification
that the height-shift preserves the dominance order — the genuine combinatorial lemma
`shift_lt_iff` about how lexicographic comparisons behave under relabeling. The payoff
$\mathrm{expShift}(x) = e^{x}$ then certifies that the abstract map is the operation we
actually care about, and $\mathrm{expShift}(r) = r$ certifies it is a nontrivial field
endomorphism rather than something degenerate.

## Why this matters

It is tempting to file all this under "abstract nonsense," but transseries are intensely
practical. They are the natural home for the asymptotics of solutions to differential
equations, for the WKB approximations of physics, for the resurgent expansions that appear
in quantum field theory, and for the computer-algebra routines that decide limits of
wild-looking expressions like
$$ \lim_{x\to\infty}\Big( e^{x}\sqrt{x} \,-\, e^{x + 1/\log x} \Big). $$
A symbolic engine that "knows" the transseries field can settle such limits mechanically,
because every term lands at a definite rung of the tower and the dominance order decides
the outcome. The asymptotic comparison theorem is the guarantee that the engine's answer
is the only possible one. The exp-substitution homomorphism is the structural fact that
lets such engines change variables — climbing or descending the tower — without corrupting
the arithmetic.

There is also a deeper resonance. The fact that climbing the tower is a *symmetry* hints
at a hidden group acting on the universe of growth rates: applying exp-substitution
repeatedly walks you up the ladder, and its inverse (substituting $\log x$ for $x$) walks
you back down. The transseries field carries an action of the integers by these tower
translations, and the orbits are precisely the towers themselves. The humble observation
that $e^{x}$ beats every power has blossomed into a rich algebraic structure with its own
symmetries — a number system not for counting, but for the very speeds at which things grow.

## The view from the top

We began with a calculus parlor trick and ended with a field, an order, a uniqueness
theorem, and a symmetry. The thread connecting them is the single decision to take the
hierarchy of growth rates *seriously* — to treat $e^{x}$, $\log x$, and their iterates not
as functions to be evaluated but as formal objects to be computed with. Once you do, the
asymptotic world reveals an arithmetic as clean as that of the rationals, an order as
sharp as the dictionary's, and a symmetry that turns the act of exponentiating into a
motion of the whole universe.

Transseries are the language in which "$e^{x}$ grows faster than any polynomial" stops
being a punchline and becomes the first theorem of a theory. And as we have seen, that
theory is not only beautiful — it is exactly precise, down to the statement that
substituting $e^{x}$ for $x$ is a faithful symmetry of everything that grows.
