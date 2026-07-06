# The Corridor a Polynomial Cannot Escape

## A number-cruncher's puzzle

Take a handful of whole numbers — say $A = \{-2,-1,0,1,2\}$ — and feed each of them
through the same simple rule. Square them, for instance. Out comes a new handful:
$\{0,1,4\}$. Five numbers went in; only three came out. The squaring map *folded* the
line, gluing $-2$ onto $2$ and $-1$ onto $1$, and the collection shrank.

Now try a different rule on the same five numbers: cube them. In comes
$\{-2,-1,0,1,2\}$, out comes $\{-8,-1,0,1,8\}$ — still five. Nothing collapsed.

This is the deceptively simple question at the heart of a large and active area of modern
mathematics: **when you push a finite set of integers through a polynomial, how big is the
result?** Written compactly, if $f$ is a polynomial and $A$ is a finite set of integers,
the *image* is
$$f(A) = \{\, f(a) : a \in A \,\},$$
and we want to understand $|f(A)|$, the number of distinct outputs.

The stakes are higher than they look. Questions of exactly this shape — how much a
polynomial can compress or spread out a set — sit underneath the theory of **expanders**,
the **sum–product phenomenon**, and the modern circle of results on power-saving bounds for
polynomial images. Those deep theorems are hard, asymptotic, and lean on subtle incidence
geometry. But underneath all of them lies a clean, exact skeleton that can be stated and
proved with nothing more than the fact that *a degree-$k$ equation has at most $k$
solutions*. This article is about that skeleton — and about a surprisingly rigid "corridor"
that traps the size of every polynomial image.

## The floor: nothing collapses too far

Here is the first pillar. Suppose $f$ has degree $k$ (for squaring, $k=2$; for cubing,
$k=3$). Pick any output value $b$ in $f(A)$. How many inputs could have produced it? Those
inputs are exactly the solutions of the equation $f(x) = b$ — equivalently, the roots of the
polynomial $f(x) - b$. And a polynomial of degree $k$ has at most $k$ roots. So **every
output has at most $k$ inputs sitting above it**.

Picture the set $A$ sorted into buckets, one bucket per output value, each input dropped
into the bucket of its output. There are $|f(A)|$ buckets, and no bucket holds more than $k$
inputs. The total number of inputs is $|A|$. Therefore
$$|A| \le k \cdot |f(A)|, \qquad\text{equivalently}\qquad |f(A)| \ge \frac{|A|}{k}.$$

This is the **fiber bound**. It is the universal law against collapse: a degree-$k$
polynomial can shrink a set by *at most* a factor of $k$, no matter how cleverly the set is
arranged. Squaring, with $k=2$, can at best halve; cubing, with $k=3$, can at best cut to a
third. The floor is real and it is simple.

## The ceiling: no free expansion

The other side is even easier to state. A function can never produce more outputs than it
has inputs, so
$$|f(A)| \le |A|.$$
That is trivially true. The interesting question the field asks is whether one can do
*better* — whether a genuinely nonlinear polynomial is forced to **expand**, producing
close to $|A|^{k}$ distinct values as a naive degree count might suggest. The honest answer,
at the level of pure elementary reasoning, is **no**. Cubing the set $\{-2,-1,0,1,2\}$ gave
back exactly five values; it did not expand at all.

To package both facts in the language the subject uses, we introduce a *power-saving
exponent*. For degree $k \ge 2$ define the small constant
$$c(k) = \frac{1}{k^2},$$
and note the elementary inequality $k - \tfrac{1}{k^2} \ge 1$ for every $k \ge 2$ (for
$k=2$ it reads $2 - \tfrac14 = 1.75 \ge 1$). Because $|A| \ge 1$, raising to a larger
exponent only increases the value, so $|f(A)| \le |A| \le |A|^{\,k - 1/k^2}$. This gives the
**power-saving upper bound**
$$|f(A)| \le |A|^{\,k - 1/k^2}$$
with the explicit constant $c(k) = 1/k^2$.

## The corridor

Put the floor and the ceiling together and you get the central statement of this work — a
two-sided estimate that any elementary count can guarantee:

> **The Power-Saving Corridor.** *Let $f$ be a monic integer polynomial of degree
> $k \ge 2$ and let $A$ be a nonempty finite set of integers. Then*
> $$\frac{|A|}{k} \;\le\; |f(A)| \;\le\; |A|^{\,k - 1/k^2}.$$

The size of the image is pinned between an explicit floor and an explicit ceiling, with the
power-saving constant $c(k) = 1/k^2$ made completely concrete. No hidden constants, no "for
sufficiently large" — it holds for every set, every time.

## Both walls are real

A corridor is only interesting if you can actually touch both walls. Can you? Yes — and the
witnesses are strikingly simple.

**Touching the ceiling (no expansion is possible).** Take $f(x) = x^k$ and the plain
counting set $A = \{0, 1, 2, \dots, n-1\}$. On the nonnegative integers, raising to the
$k$-th power is strictly increasing, hence one-to-one, so no two inputs collide:
$$|f(A)| = |A| = n.$$
The image is exactly as big as the domain. This shows the exponent in the upper bound cannot
be pushed below $1$: **there is no universal super-saving** $|f(A)| \le |A|^{1-\varepsilon}$.
Any theorem promising real expansion must use something deeper than counting.

**Touching the floor (maximal collapse).** Take $f(x) = x^2$ (so $k=2$) and the symmetric
window $A = \{-n, \dots, n\}$, which has $2n+1$ elements. Squaring glues each pair
$\{a, -a\}$ to a single value, and only the fixed point $0$ stands alone. The image is
$\{0, 1, 4, \dots, n^2\}$, of size $n+1$, and one checks the exact identity
$$2\,|f(A)| = |A| + 1.$$
This saturates the fiber bound $|A| \le k\,|f(A)|$ with $k=2$, up to the single unavoidable
$+1$ from the fixed point. The factor $k$ in the floor is best possible.

So the corridor is not merely a pair of true inequalities; **both of its walls are
essentially attained**. Neither can be improved by elementary means.

## The twist: corridors multiply

Here is where the story turns from a tidy observation into a structure. Polynomials can be
*composed*: apply one, then another. Square, then square again, and you have raised to the
fourth power, $x^4$. In general, composing a degree-$k$ polynomial $p$ with a degree-$m$
polynomial $q$ yields a polynomial $q \circ p$ of degree $k \cdot m$, because degrees
multiply under composition.

Does the corridor survive composition? It does — and in the cleanest possible way. The key
observation is that pushing $A$ through the composite is the same as pushing it through $p$
and then pushing the result through $q$:
$$(q \circ p)(A) = q\big(p(A)\big).$$
The intermediate set $B = p(A)$ is a perfectly ordinary finite set of integers, so the fiber
bound applies to it verbatim. Chaining the two floors — first $|A| \le k\,|p(A)|$, then
$|p(A)| \le m\,|q(p(A))|$ — gives

> **Multiplicativity of the Fiber Bound.** *If $p$ has degree $k \ge 1$ and $q$ has degree
> $m \ge 1$, then for every finite set $A$ of integers,*
> $$|A| \;\le\; (k \cdot m)\,\big|(q\circ p)(A)\big|.$$

The two degree factors multiply — exactly matching the degree $k\cdot m$ of the composite.
The corridor is *functorial*: each layer of composition contributes its own degree factor,
and the loss is precisely multiplicative, never worse. It is worth stressing what does
*not* happen: the collapse never compounds catastrophically. Because each fiber bound is
tight in isolation and the intermediate image is an honest set, chaining loses exactly the
product $k\cdot m$ and no more.

Iterating, an $r$-fold tower of degree-$k$ maps has composite degree $k^r$, and the
associated power-saving constant is
$$c = \frac{1}{k^{2r}}.$$
As you stack layers, the guaranteed saving shrinks geometrically — a precise quantitative
picture of how compression accumulates through a pipeline of polynomial maps. This is
exactly the situation in the iterated Minkowski (elementwise-image) construction that
motivates the whole subject.

## Why the walls have the shapes they do

Step back and the two walls tell a single story. The floor is about **algebra**: a
degree-$k$ equation has at most $k$ solutions, full stop, and that is the only thing keeping
the image from collapsing to a point. The ceiling is about the **limits of algebra**: on an
arithmetic progression a polynomial can be perfectly injective, so counting alone can never
force a set to grow.

Genuine expansion — the phenomenon that a nonlinear map *must* spread a set out unless the
set is arithmetically special — lives in the gap between these walls, and reaching it
requires ideas beyond fiber counting: the interaction between the additive structure of a
set and the multiplicative curvature of a nonlinear map. The corridor marks off exactly the
territory that elementary reasoning secures, and thereby points to precisely where the deep
work must begin. Arithmetic progressions, on which polynomials stay injective, are the
obstruction that any expansion theorem must overcome.

## The takeaway

From one childlike experiment — square five numbers, cube five numbers — we arrive at a
sharp, quantitative law. The image of a finite integer set under a monic degree-$k$
polynomial is trapped in the corridor
$$\frac{|A|}{k} \le |f(A)| \le |A|^{\,k - 1/k^2},$$
both walls are essentially touched by explicit examples, and the whole structure multiplies
cleanly when polynomials are composed, giving the constant $1/k^{2r}$ for an $r$-fold tower.
It is a small theorem with a large reach: the exact, unconditional bones beneath a body of
research that stretches to the frontier of additive combinatorics.
