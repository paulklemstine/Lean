# Dividing by Zero, Safely: Where Total Arithmetic Keeps Its Promises

## The oldest forbidden move in mathematics

Every schoolchild learns the rule: *you cannot divide by zero*. Every programmer learns it again, the hard way, when a division instruction traps and a process dies. And every engineer who has ever written arithmetic that must **never** crash — a flight controller, a signal processor, a cryptographic routine that must not branch on secret data — has wished for a number system in which the rule simply did not exist.

Such systems exist. The simplest and most famous is the **transreal line**: take the real numbers $\mathbb{R}$, glue on two signed infinities $+\infty$ and $-\infty$, and add one more element, called **nullity** and written $\Phi$, whose job is to absorb every expression that has no defensible value at all. Then declare arithmetic *total*: every pair of elements has a sum, a product, and a quotient, no exceptions, no traps, no undefined behaviour. In particular

$$\frac{1}{0} = +\infty, \qquad \frac{-1}{0} = -\infty, \qquad \frac{0}{0} = \Phi .$$

It looks like cheating. The interesting question is: *how much* of a cheat is it? If you prove a theorem the ordinary way, about ordinary real numbers, and then run the same formula through the total system, do you get the same answer? And if the answer changes, exactly when and by how much?

This article gives a complete and, I think, rather beautiful answer. There is a precise dividing line — a *guard* — separating the formulas that transfer perfectly from the formulas that break. The guard is the obvious one, "never divide by something that can be zero", but the point is that it turns out to be **exactly right**, in four independent senses: algebraic, topological, rigidity-theoretic, and structural. And on the far side of the line the failure is not chaos: it obeys a clean trichotomy, and one of its three branches unexpectedly still works.

## Building the four-constructor world

Write $\mathbb{T}$ for the carrier. Its elements come in exactly four shapes: a finite element $\mathrm{fin}\,x$ for each real $x$, the two infinities $+\infty$ and $-\infty$, and the single exceptional element $\Phi$.

Addition is what you would guess: finites add as reals; adding a finite to an infinity leaves the infinity alone; $(+\infty) + (+\infty) = +\infty$; and the indeterminate form collapses,
$$(+\infty) + (-\infty) = \Phi.$$
Nullity is contagious: $\Phi + a = a + \Phi = \Phi$ for every $a$. Negation swaps the infinities and fixes $\Phi$.

Multiplication follows the sign rules — $\mathrm{fin}\,x \cdot (+\infty)$ is $+\infty$ when $x > 0$ and $-\infty$ when $x < 0$ — with the other indeterminate form collapsing as well,
$$0 \cdot (\pm\infty) = \Phi .$$

Division is defined, as it always should be, as multiplication by a reciprocal, and the reciprocal is total: $1/0 = +\infty$, $1/(\pm\infty) = 0$, $1/\Phi = \Phi$. Unwinding this gives the *division trichotomy*, the single most important fact about the system:

> **The division boundary.** For every real $x$,
> $$\frac{\mathrm{fin}\,x}{\mathrm{fin}\,0} = \begin{cases} +\infty & x > 0,\\ -\infty & x < 0, \\ \Phi & x = 0.\end{cases}$$

So the quotient does not merely become "undefined" at a vanishing denominator; it lands on a specific exceptional element, chosen by the *sign of the numerator*. That determinacy is what makes the whole analysis possible.

Everything else is conservative. For all reals $x, y$,
$$\mathrm{fin}\,x + \mathrm{fin}\,y = \mathrm{fin}(x+y), \qquad \mathrm{fin}\,x \cdot \mathrm{fin}\,y = \mathrm{fin}(xy),$$
and — the key clause —
$$\frac{\mathrm{fin}\,x}{\mathrm{fin}\,y} = \mathrm{fin}\!\left(\frac{x}{y}\right) \quad \text{whenever } y \neq 0 .$$

That last line, *exact conservativity of guarded division*, is where the guard is born.

## The guard is not a choice — it is forced, four times over

You might object that "denominator nonzero" is an arbitrary hypothesis, tacked on to make theorems come out. It is not. Here are four independent characterisations, each computed inside $\mathbb{T}$ itself, and each returning the same answer.

**1. Algebra: guarded denominators are precisely the units.** An element $a \in \mathbb{T}$ has a multiplicative inverse — i.e. there exists $b$ with $a \cdot b = 1$ — *if and only if* $a = \mathrm{fin}\,x$ for some nonzero real $x$. The infinities are not invertible (their products with finites are again infinite or nullity, never $1$), and $\Phi$ absorbs everything. Similarly, $a$ has an additive inverse if and only if $a$ is finite: the finite fragment is exactly the additive-group part of $\mathbb{T}$. So the guard is not a side condition imposed from outside; it is the unit group of the arithmetic, read off from the multiplication table.

**2. Topology: the guard is the continuity locus of division.** To speak of continuity we need a topology on $\mathbb{T}$, and there is a canonical one. Take the two-point compactification $[-\infty, +\infty]$ of the line — that is, the real line with its two *ends* glued on as genuine limit points — and add $\Phi$ as a **disjoint isolated point**. This gives a **compact Hausdorff** space in which $\mathbb{R}$ sits as an open subset (an open embedding), $\pm\infty$ are the honest limits of $x \to \pm\infty$, and $\{\Phi\}$ is an open singleton. That $\Phi$ is isolated is not a design quirk but a statement of fact about the arithmetic: nullity is never the limit of finite values along any arithmetic law, so it should be a limit of nothing.

In that topology one can ask where the *binary* division map $(a,b) \mapsto a/b$ is continuous. The answer, on the finite square, is exactly the guard: division is continuous at every pair $(\mathrm{fin}\,x, \mathrm{fin}\,y)$ with $y \neq 0$, and at **no** pair $(\mathrm{fin}\,x, \mathrm{fin}\,0)$, whatever the numerator $x$. Algebra and topology compute the same set.

**3. Rigidity: the failure is off by exactly one value, at exactly one point.** Consider the humblest unguarded formula imaginable: $x \mapsto x/x$. Away from the origin it is the constant $1$. At the origin, total arithmetic is compelled to return $0/0 = \Phi$. Now ask: is there *any* value $v \in \mathbb{T}$ we could have put at the origin instead that would make the function continuous? Yes, and only one:

> **Rigidity.** For every topology on $\mathbb{T}$ in which points are closed, the function equal to $1$ off the origin and to $v$ at the origin is continuous **if and only if** $v = 1$.

The proof is a single line of general topology: the punctured line is dense, so a continuous map that is constantly $1$ on it must be $1$ everywhere. And the arithmetic returns $\Phi \neq 1$. So the guarded transfer principle fails by *one point and one value* — the sharpest possible statement of an obstruction. Note also how strong the hypothesis is: this holds for **every** T₁ topology, not just the natural one. No clever re-topologisation can rescue $x/x$.

**4. Structure: total arithmetic and continuity are simply incompatible.** The same trade-off appears away from division. Addition on $\mathbb{T}$ is not jointly continuous at $(+\infty, -\infty)$: along the path $t \mapsto (t, -t)$ the sums are constantly $0$, yet the limit point is assigned $\Phi$. Multiplication is not jointly continuous at $(0, +\infty)$: along $t \mapsto (1/t, t)$ the products are constantly $1$, yet the limit point is assigned $\Phi$. And distributivity fails too: $(+\infty)\cdot(1 + 0) = +\infty$ while $(+\infty)\cdot 1 + (+\infty)\cdot 0 = (+\infty) + \Phi = \Phi$. The carrier is compact and Hausdorff and its arithmetic is total — and the price, exactly, is joint continuity at the indeterminate forms.

## The transfer principle

Now we can state the main theorem. Fix a parameter space $X$ (think: the real line, or a space of inputs) and consider *formulas* built from continuous real functions of the parameter by the four moves: composition with a continuous real function, addition, multiplication, and division. Call such a formula **guarded** if all of its ingredient functions are continuous and **every denominator subformula is nowhere zero**.

> **Guarded Transfer Principle.** Every guarded formula, evaluated with *total* transreal arithmetic, agrees with its ordinary real evaluation read inside the finite fragment:
> $$\mathrm{Eval}_{\mathbb{T}}(e)(x) = \mathrm{fin}\big(\mathrm{Eval}_{\mathbb{R}}(e)(x)\big) \quad \text{for all } x,$$
> and is therefore a continuous map from $X$ into the compact Hausdorff carrier $\mathbb{T}$. The exceptional elements $\pm\infty$ and $\Phi$ are unreachable.

The proof is a structural induction on the formula whose only interesting step is division, discharged by exact conservativity. What makes the theorem worth stating is its two companions.

> **Faithfulness.** Two guarded formulas have the same transreal semantics if and only if they have the same real semantics.

So transfer is not merely *sound* — it is *exactly conservative*. You cannot prove anything new by moving into the transreals, and you cannot lose anything either. An identity like $\frac{e^x}{1+e^x} + \frac{1}{1+e^x} = 1$ (both denominators are nowhere zero, being at least $1$) holds in the transreals precisely because it holds in the reals.

> **Functoriality.** Guardedness is preserved by continuous reparametrisation: if $g : Y \to X$ is continuous and $e$ is guarded, then $e$ pulled back along $g$ is guarded.

So a single guarded identity transfers to every continuous family of instances at once.

And the sharpness:

> **Sharpness.** Delete only the nowhere-vanishing clause, and the conclusion dies — the self-division formula $x/x$ is otherwise perfectly well-behaved (both atoms are the continuous identity) yet its transreal evaluation is discontinuous, and it is discontinuous for **every** T₁ topology on the four-constructor carrier.

There is also a stronger negative result specific to reciprocals. In the natural topology, the map $y \mapsto 1/y$ patched with an arbitrary value $v$ at the origin is discontinuous *for every choice of $v$*. The reason is a two-sided squeeze: near the origin the reciprocal takes arbitrarily large positive **and** arbitrarily large negative values, so any neighbourhood of the patch value must contain both, and no point of $\mathbb{T}$ — finite, infinite, or null — has such a neighbourhood. Enlarging the number system does not fix the reciprocal. The guard is a necessity, not a convenience.

## Beyond the guard: a trichotomy, and one surprise

If the guard is sufficient but the failure is so total, is unguarded division simply hopeless? No — and this is the most interesting part of the story. Suppose the denominator $g$ vanishes at a point $x_0$ but is nonzero on a punctured neighbourhood (an *isolated zero*), and let $f$ be the numerator. Exactly three regimes occur.

**Regime 1 — $0/0$: always breaks.** If $f(x_0) = g(x_0) = 0$, the quotient equals $\Phi$ at $x_0$ but is finite nearby. Since $\{\Phi\}$ is open, a continuous map's $\Phi$-fibre would have to be open too, and the fibre here is the single point $x_0$. Discontinuous. Remarkably, this argument needs no regularity of $f$ and $g$ at all — no continuity, no measurability. It is pure topology: the isolation of nullity.

**Regime 2 — one-signed pole: transfers!** If $f(x_0) > 0$ and $g > 0$ on a punctured neighbourhood, then the quotient *is* continuous at $x_0$, taking the value $+\infty$. Both one-sided limits are $+\infty$, and $+\infty$ is a genuine point of the compact carrier, so the function is continuous *into the four-constructor space*. The cleanest example:
$$x \longmapsto \frac{1}{x^2}$$
is a continuous map from the whole real line into $\mathbb{T}$, with value $+\infty$ at the origin. The transreal carrier really does absorb even-order poles. This is why the failure of the unguarded principle must be phrased as a *generic*, not a *universal*, failure.

There is a wrinkle here worth savouring. The system decides $1/0 = +\infty$, not $-\infty$, and that convention breaks the sign symmetry. If the denominator has constant sign but approaches zero *from below* — think of $1/(-x^2)$ — then both one-sided limits are $-\infty$, whereas the arithmetic, which sees only that the denominator *equals* zero and that the numerator is positive, returns $+\infty$. The result is discontinuous. Continuity in regime 2 therefore requires the denominator to be positive near the pole: the total arithmetic cannot remember from which side its denominator vanished. A striking consequence: $1/(-x^2)$ and $(-1)/x^2$ are the same real function away from the origin, but the total system evaluates them at the origin to $+\infty$ and $-\infty$ respectively, and only the second is continuous. Past the guard, the answer depends on how you wrote the formula — and the guard is exactly the condition that makes that dependence vanish.

**Regime 3 — sign-changing pole: breaks.** If $f(x_0) > 0$ and $g$ changes sign at $x_0$, the right-hand limit is $+\infty$ and the left-hand limit is $-\infty$. In a Hausdorff space a function cannot converge to two different points, so the quotient is discontinuous. The archetype is $x \mapsto 1/x$ at the origin — the very first "singularity" anyone meets.

Put the trichotomy next to the guard and the picture snaps into focus. The nowhere-vanishing guard is *sufficient* and cannot be weakened as a syntactic condition — but it is not *necessary*. What is necessary and sufficient, at an isolated denominator zero, is: the numerator is nonzero there, and the denominator is *positive* on a punctured neighbourhood. Odd-order poles and coincident zeros are the enemy; positive even-order poles are friends.

## Why this matters outside pure analysis

The motivation is not idle. Total arithmetic is exactly what you want in code that must not branch.

In elliptic-curve cryptography, points are usually stored in *projective* coordinates $(X : Y : Z)$ precisely to avoid the division $x = X/Z$ — a division that becomes $0/0$ or $c/0$ at the point at infinity, the group identity. Implementations that convert to affine coordinates by dividing must special-case $Z = 0$, and a special case is a *branch*, and a branch on secret-dependent data is a timing side channel. The whole "complete addition formulas" industry exists to eliminate such branches. A total arithmetic that returns a well-defined exceptional element instead of trapping looks like the perfect answer.

The results above say precisely what that answer buys you and what it does not. Inside the guarded fragment — nowhere-vanishing denominators, which is exactly what a formula proven to avoid the identity point provides — the totalisation is *invisible*: same values, same theorems, in both directions, with continuity preserved. That is a genuine licence to reason in the ordinary way and implement branch-free. Outside it, totality is real but continuity is gone, and the discontinuity is not a technicality: it survives *every* T₁ topology, it cannot be patched by any value, and it comes with a sign-dependent trichotomy that a careful implementer must respect. A positive one-signed pole degrades gracefully; a sign-changing pole or a $0/0$ does not, and an approximate computation near such a point can return either infinity, or nullity, on the basis of floating-point noise.

The moral is a pleasing one. Dividing by zero is not forbidden. It is merely *expensive*, and the price is stated exactly: you may have totality, or you may have continuity, but at $0/0$, at $\infty - \infty$, and at $0 \cdot \infty$, you may not have both. Stay on the guarded side and you pay nothing at all.
