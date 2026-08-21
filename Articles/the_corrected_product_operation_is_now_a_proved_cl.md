# The Group Hiding Inside a Broken Multiplication

## A pole that refuses to behave

Some of the most consequential functions in mathematics are written as *$q$-series*: infinite expansions in a variable $q$ that begin with a single pole and then run off into an infinite tail of integers. The most famous of them all is the modular function

$$J(q) \;=\; q^{-1} + 196884\,q + 21493760\,q^{2} + 864299970\,q^{3} + \cdots$$

whose coefficients famously turned out to encode the dimensions of representations of the Monster, the largest sporadic finite simple group. The expansion of $J$ is not arbitrary: it is *normalized*. There is exactly one pole term, it is $q^{-1}$, and its coefficient is exactly $1$. Everything below $q^{-1}$ vanishes. This normalization is not cosmetic; it is what makes such expansions canonical objects, comparable across different groups, different modular curves, different corners of the theory.

Now try the most natural thing a mathematician can do with two objects of the same kind: multiply them.

$$\bigl(q^{-1} + a_0 + a_1 q + \cdots\bigr)\bigl(q^{-1} + b_0 + b_1 q + \cdots\bigr) \;=\; q^{-2} + (a_0 + b_0)q^{-1} + \cdots$$

The product opens with $q^{-2}$. It is not normalized. Multiply three normalized series and you get a pole of order three; multiply $m$ of them and the pole has order $m$. The class of normalized series, so carefully cut out, is destroyed by its own multiplication. Call this the **pole-order obstruction**: normalized $q$-series are not closed under multiplication, and the failure is not subtle or occasional — it is total. The product of two normalized series is *never* normalized, no matter which two you take.

This article is about what happens when you refuse to accept that as the end of the story.

## The unique repair

The defect is one unit of pole order, and there is an obvious candidate cure: put the missing $q$ back. Define the **corrected product** of two normalized series by

$$f \star g \;=\; q\, f\, g.$$

Multiply out and the offending $q^{-2}$ becomes $q^{-1}$, with coefficient $1 \cdot 1 = 1$, and nothing below it survives. So $f \star g$ is normalized again. That is the **closure theorem**, and everything in this article grows out of it.

Before building on it, one should ask whether the repair is a fudge. It is not — it is forced. If $f$ and $g$ are normalized, then $q^{m} f g$ is normalized *if and only if* $m = 1$. The pole orders simply add: $q^m fg$ has a pole of order $2 - m$, and only $m = 1$ lands on the required order $1$. There is one monomial correction, and $\star$ is it. The operation is not a choice; it is the unique way to keep the multiplication and keep the normalization.

## A hidden change of coordinates

Once you have a closed operation, you want to know what kind of algebra it is. Here the answer is best seen through a change of coordinates that is almost too simple to notice.

A Laurent series $f$ is normalized precisely when it can be written

$$f \;=\; q^{-1} u, \qquad u = 1 + u_1 q + u_2 q^{2} + \cdots$$

for an ordinary power series $u$ whose constant term is $1$. Such power series are called **one-units**; they form a group under ordinary multiplication (their inverses are again power series with constant term $1$, computed by the usual geometric expansion). The correspondence is a bijection: $u = qf$ recovers the one-unit from the series, and $f = q^{-1} u$ goes back.

Now watch what the corrected product does in these coordinates. If $f = q^{-1}u$ and $g = q^{-1}v$, then

$$f \star g \;=\; q \cdot q^{-1}u \cdot q^{-1}v \;=\; q^{-1}(uv).$$

The corrected product is *ordinary multiplication of one-units*, wearing a disguise. That single line unlocks everything:

> **Structure theorem.** Under the corrected product, the normalized $q$-series form a commutative group, with identity element $q^{-1}$, with the inverse of $f$ given by $q^{-2}f^{-1}$, and this group is isomorphic to the group $1 + q\,\mathbb{C}[[q]]$ of one-unit power series via $f \mapsto qf$.

The identity element is worth pausing over. There is no distinguished "$1$" among normalized $q$-series in any naive sense; the neutral element of $\star$ is the bare pole $q^{-1}$ itself. The set of normalized series has no intrinsic group structure — but it becomes one the moment you nominate $q^{-1}$ as the origin. That is exactly the relationship a *torsor* has to its group: the structure is there, waiting for a base point.

## Iterating the repair

Apply $\star$ to $f$ with itself, then again, then again. Each application inserts one factor of $q$, so the $n$-th iterate is

$$f^{\star n} \;=\; q^{\,n-1} f^{\,n},$$

which is precisely the correction predicted by the pole-order obstruction, applied $n-1$ times. There is nothing special about squares: the corrected product of $194$ normalized series — one for each conjugacy class of the Monster, say — is $q^{193}$ times their ordinary product.

Now the question that closure makes well posed at last: as you march along the orbit $f, f^{\star 2}, f^{\star 3}, \dots$, what do you see? Which numerical invariant of a normalized series tells two orbits apart?

## The first invariant, and why it is not enough

The first candidate is the constant term. Write $a_0(f)$ for the coefficient of $q^0$ in $f$. A one-line computation with the coordinates above shows that $a_0$ is *additive*:

$$a_0(f \star g) \;=\; a_0(f) + a_0(g), \qquad\text{hence}\qquad a_0\bigl(f^{\star n}\bigr) \;=\; n \, a_0(f).$$

So the constant term is a group homomorphism from the corrected-product group onto the additive group of complex numbers, and it is surjective: every complex number is the constant term of some normalized series. Along an orbit it grows *linearly*, which is already a striking rigidity statement — a multiplicative iteration producing an arithmetic progression.

But $a_0$ is not a complete invariant. The series $q^{-1} + q$ has vanishing constant term and is certainly not the identity $q^{-1}$. Its entire orbit is invisible to $a_0$. The first invariant sees a shadow of the group, not the group.

## The tower of invariants

The repair for *that* defect is a filtration. Say that a normalized series is **$k$-deep** if it agrees with the base point $q^{-1}$ through level $k$ — that is, if the coefficients of $q^{0}, q^{1}, \dots, q^{k-2}$ all vanish. Write $\mathrm{Deep}_k$ for the set of $k$-deep series. Every $\mathrm{Deep}_k$ is a subgroup under $\star$; the chain

$$\mathrm{Norm} = \mathrm{Deep}_1 \supseteq \mathrm{Deep}_2 \supseteq \mathrm{Deep}_3 \supseteq \cdots$$

descends. Define the level-$k$ invariant $c_k(f)$ to be the coefficient of $q^{k-1}$ in $f$. Then the following facts fit together into a clean picture.

* **Additivity at the threshold.** On the subgroup $\mathrm{Deep}_k$, the level-$k$ invariant is additive: $c_k(f\star g) = c_k(f) + c_k(g)$. Below the threshold the coefficients of a product interact nonlinearly; exactly at the threshold, the cross terms all involve a vanishing coefficient, and the multiplication linearizes.
* **The kernel is the next stage.** A $k$-deep series lies in $\mathrm{Deep}_{k+1}$ precisely when $c_k$ vanishes on it. So the level-$k$ invariant cuts out the next floor of the tower.
* **Every floor looks the same.** Consequently $\mathrm{Deep}_k/\mathrm{Deep}_{k+1} \cong (\mathbb{C},+)$ for every $k \ge 1$: all the graded pieces of the tower are isomorphic. No measurement made *inside* a single floor can tell you which floor you are on. What distinguishes series is their *position* in the tower.
* **The tower is strict and separated.** At every level the containment is proper — there is always a series that is $k$-deep but not $(k+1)$-deep — and a series lying on every floor is the base point $q^{-1}$ itself. The tower is infinite, and it separates points.
* **The invariants are complete and free.** Sending $f$ to the whole sequence $(c_1(f), c_2(f), c_3(f), \dots)$ is a *bijection* from normalized series onto all sequences of complex numbers. Any prescribed list of invariants is realized by exactly one series. This map is emphatically not a group isomorphism — for $f = g = q^{-1}+q$ the level-$2$ invariant of $f \star g$ is $1$ while both factors have level-$2$ invariant $0$ — which is precisely why the filtration is needed to make the individual coefficients into homomorphisms.

So the answer to "which invariant distinguishes orbits?" begins to sharpen. The **depth** of $f$ — the first level $k$ at which $f$ differs from $q^{-1}$ — is well defined for every $f \ne q^{-1}$, and at that level the invariant $c_k(f)$ is nonzero and grows exactly linearly along the orbit:

$$c_k\bigl(f^{\star n}\bigr) \;=\; n\, c_k(f).$$

Better still, depth is *constant along orbits*: for $n \ne 0$, the iterate $f^{\star n}$ has exactly the same depth as $f$. The depth is the first genuine orbit invariant, and the first level invariant $c_k$ is what separates the individual iterates within an orbit.

## Nothing has finite order

The linear growth law has an immediate and rather dramatic consequence: the corrected-product group is **torsion-free**. If $f^{\star n} = q^{-1}$ for some $n \ge 1$ and $f \ne q^{-1}$, then at the depth $k$ of $f$ we would get $0 = n\,c_k(f)$ with $c_k(f) \ne 0$ — impossible in characteristic zero. So every non-trivial orbit is infinite, and distinct iterates never collide.

And in the other direction the group is **divisible**: every normalized series has an $n$-th corrected-product root, and by torsion-freeness that root is *unique*. The construction is completely explicit rather than abstract: substitute $qf - 1$ into the binomial series $(1+X)^{1/n} = \sum_d \binom{1/n}{d} X^d$, and rescale. Because $qf - 1$ has zero constant term, the substitution converges coefficientwise.

A torsion-free divisible abelian group is a vector space over the rationals. So there is no cyclic behaviour, no finite-order phenomenon, no exotic small orbit hiding anywhere in this world.

In fact the divisibility can be pushed all the way to complex exponents. Substituting $qf - 1$ into $(1+X)^{r}$ for arbitrary $r \in \mathbb{C}$ produces a normalized series $f^{\star r}$ satisfying

$$f^{\star(r+s)} = f^{\star r} \star f^{\star s}, \qquad f^{\star n} = \underbrace{f \star \cdots \star f}_{n},$$

so every discrete orbit is the restriction to the integers of a genuine **complex one-parameter subgroup** $r \mapsto f^{\star r}$. This map is injective whenever $f \ne q^{-1}$ — indeed at the depth $k$ one has $c_k(f^{\star r}) = r\,c_k(f)$, so the linear growth law holds for all complex "times", not just whole numbers. Every non-trivial orbit therefore contains a faithful copy of the additive group $\mathbb{C}$, and the discrete arithmetic progression $n \, c_k(f)$ is the shadow of a complex line.

## Above the depth: an exact binomial law

Linear growth is only the first floor. What does the level-$m$ invariant of $f^{\star n}$ do for $m$ *above* the depth?

Write the one-unit coordinate as $u = qf = 1 + w$, where $w$ has order at least $k$ (that is the definition of $k$-deep). Then $u^{n} = (1+w)^{n} = \sum_{d} \binom{n}{d} w^{d}$ by the ordinary binomial theorem. The key observation is about ranges: $w^{d}$ has order at least $dk$, so it contributes nothing at level $m$ once $d > m/k$. Consequently

$$\bigl[q^{m}\bigr] u^{n} \;=\; \sum_{d=0}^{\lfloor m/k \rfloor} \binom{n}{d}\,\bigl[q^{m}\bigr] w^{d},$$

and — the crucial point — the range of summation and the numbers $[q^m]w^d$ do not depend on $n$ at all. The infinite binomial series has collapsed to a *finite*, $n$-independent expansion.

Three consequences follow at once.

**Polynomial growth.** Every orbit invariant is a polynomial in the iteration count. For a $k$-deep series, the level-$m$ invariant of $f^{\star n}$ is a polynomial in $n$ of degree at most $\lfloor m/k \rfloor$. Depth controls growth: the deeper the series, the flatter its high-level invariants.

**Exact leading term.** At level $jk$ the answer is even sharper. The top binomial weight is exactly the $j$-th power of the depth invariant, giving

$$c_{jk}\bigl(f^{\star n}\bigr) \;=\; \binom{n}{j} c_k(f)^{j} \;+\; \sum_{d<j} \binom{n}{d}\,(\text{weights independent of } n).$$

So the degree in $n$ is *exactly* $j$ whenever $c_k(f) \ne 0$. The case $j = 1$ is the linear law we already met; the case $j = 2$ says the level-$2k$ invariant grows quadratically:

$$c_{2k}\bigl(f^{\star n}\bigr) \;=\; n\,c_{2k}(f) + \binom{n}{2}\,c_k(f)^{2}.$$

**Finite determination.** Because a polynomial of degree at most $D$ is pinned down by $D+1$ values, the entire infinite orbit invariant at level $m$ is determined by the first $\lfloor m/k\rfloor + 1$ iterates. Two $k$-deep series whose level-$m$ invariants agree at $n = 0, 1, \dots, \lfloor m/k \rfloor$ agree there for *every* $n$. Infinitely many experiments collapse to finitely many, with the number governed only by the depth.

## Moonshine, iterated

It is pleasant to run the machine on real data. Take the modular function

$$J = q^{-1} + 196884\,q + 21493760\,q^{2} + 864299970\,q^{3} + \cdots$$

Its constant term vanishes, so $J$ is $2$-deep, with depth invariant $c_2(J) = 196884$. The theory then predicts, with no further computation:

* the coefficient of $q$ in $J^{\star n} = q^{\,n-1}J^{\,n}$ is exactly $196884\,n$;
* the coefficient of $q^{3}$ — level $4 = 2\cdot 2$, so the quadratic regime — is exactly

$$864299970\,n + \binom{n}{2}\cdot 196884^{2}.$$

For $n = 2$ this gives $2 \cdot 864299970 + 196884^{2} = 1728599940 + 38763309456 = 40491909396$, and $q\,J^{2}$ does indeed have $40491909396$ as its $q^{3}$-coefficient. The famous number $196884$ reappears squared, as the leading binomial weight of the second floor of the tower — an entirely structural prediction about how moonshine coefficients propagate under the corrected product.

## What the repair taught us

The story has a shape worth naming. A natural class of objects fails to be closed under a natural operation. The failure is measured by a single integer — one unit of pole order — and admits a unique monomial repair. The repaired operation is not merely well defined; it turns the class into a commutative group, indeed a rational vector space with complex one-parameter subgroups through every point, isomorphic to the one-units of the formal power series ring. And the question the closure makes well posed — *what distinguishes orbits?* — has a complete answer: an infinite tower of invariants, each floor a copy of $(\mathbb{C},+)$, with the depth as the first orbit invariant, linear growth exactly at the depth, and an exact finite binomial law above it that makes every orbit invariant a polynomial of computable degree, determined by finitely many iterates.

The moral is that an obstruction is often a piece of structure in disguise. The factor of $q$ you have to insert to keep normalized series normalized is not bookkeeping. It is the multiplication of a group that was there all along.

## Open ground

The finite-determination theorem converts an a priori infinite search into a single polynomial equation. Given $f$ of depth $k$ and a target $g$, asking whether $g = f^{\star n}$ for some $n$ becomes, at each level $m$, an equation $\sum_{d \le m/k} c_d \binom{n}{d} = c_m(g)$ whose coefficients do not depend on $n$. A non-constant polynomial has at most $\lfloor m/k\rfloor$ roots, so either that level already pins $n$ down to a finite list of candidates, or the level carries no information and one passes to the next — which, by strictness of the tower, is a genuinely smaller stage. This is the skeleton of an algorithm, and it suggests the natural conjecture: for normalized series with coefficients in a fixed number field, membership in a corrected-product orbit is decidable, with any witness $n$ bounded explicitly in terms of the depth and the first level at which the two series differ. Turning that skeleton into a theorem — with the termination argument and the effective bound both nailed down — is the obvious next step.
