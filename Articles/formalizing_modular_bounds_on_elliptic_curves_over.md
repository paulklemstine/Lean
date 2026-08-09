# Counting Points on Curves, One Square at a Time

## How a two-line trick with square roots yields exact laws for elliptic curves over finite fields

There is a question so simple that a curious high-school student can pose it, and so deep that a version of it carries a million-dollar prize: *how many solutions does an equation have?*

Take the equation
$$y^2 = x^3 + ax + b.$$
Over the real numbers this is the familiar elliptic curve — a smooth, looping shape that shows up in cryptography, in the proof of Fermat's Last Theorem, and on the wall of every number theory department. Over the real numbers it has infinitely many points, so asking "how many?" is not interesting.

But now change the arithmetic. Instead of real numbers, work modulo a prime $p$: the numbers are $0, 1, 2, \dots, p-1$, addition and multiplication wrap around, and every nonzero number has a reciprocal. This finite world is called $\mathbb{F}_p$. Now the curve has only finitely many points, and the question becomes sharp and beautiful. If we also throw in one extra "point at infinity" — the standard convention that turns the solution set into a group — we write $\#E(\mathbb{F}_p)$ for the total count.

How many points are there? The answer, remarkably, is *almost* always $p+1$. Not exactly: there is a wobble. And the entire modern theory of elliptic curves is, in one form or another, the study of that wobble.

This article is about a way of getting at the wobble with bare hands. No cohomology, no Riemann–Roch, no Weil conjectures — just the humble observation that a number modulo $p$ has either two square roots, or one, or none.

---

## The one trick

Fix a prime $p > 2$ and define the **quadratic character** $\chi$ on $\mathbb{F}_p$:
$$\chi(c) = \begin{cases} +1 & \text{if } c \text{ is a nonzero square modulo } p, \\ 0 & \text{if } c = 0, \\ -1 & \text{if } c \text{ is not a square modulo } p.\end{cases}$$

The entire subject rests on a single sentence: **the number of $y$ with $y^2 = c$ is exactly $\chi(c) + 1$.** If $c$ is a nonzero square there are two roots ($\chi+1 = 2$); if $c = 0$ there is one ($0+1=1$); if $c$ is a nonsquare there are none ($-1+1=0$). One formula, all three cases.

Now count the points of $y^2 = x^3 + ax + b$ by sweeping through the $x$'s. For each of the $p$ values of $x$, the number of matching $y$'s is $\chi(x^3+ax+b) + 1$. Add them up and add the point at infinity:

> **The Counting Formula.** For every $a, b \in \mathbb{F}_p$,
> $$\#E(\mathbb{F}_p) = p + 1 + S(a,b), \qquad \text{where } S(a,b) = \sum_{x \in \mathbb{F}_p} \chi(x^3+ax+b).$$

That is the whole derivation. The quantity $S(a,b)$ — a **character sum** — *is* the wobble. Number theorists prefer to record it with a sign flip and call it the **trace of Frobenius**:
$$a(a,b) = p + 1 - \#E(\mathbb{F}_p) = -S(a,b).$$

Every question about point counts is now a question about $S$. And $S$ is a sum of $p$ numbers, each $+1$, $0$, or $-1$. If those signs were random coin flips, the sum would typically be around $\sqrt{p}$ in size. The famous theorem of Hasse says this heuristic is *exactly right*: $|a(a,b)| \le 2\sqrt{p}$, always. What follows are the parts of that story you can prove from the one trick alone — and, it turns out, that is a surprising amount.

---

## Curves that never wobble

Sometimes the wobble is not small; it is *zero*, and provably so, for structural reasons.

Consider the curves with no linear term, $y^2 = x^3 + b$. Here
$$S(0,b) = \sum_x \chi(x^3 + b).$$
Suppose $p \equiv 2 \pmod 3$. Then cubing, $x \mapsto x^3$, is a **bijection** of $\mathbb{F}_p$: the nonzero elements form a cyclic group of order $p-1$, which is not divisible by $3$, so raising to the third power is invertible on it (and $0 \mapsto 0$). So as $x$ runs over the field, $x^3$ runs over the field too, and the sum collapses:
$$S(0,b) = \sum_t \chi(t + b) = \sum_u \chi(u) = 0,$$
the last step because exactly half the nonzero residues are squares and half are not.

> **Theorem (First supersingular family).** If $p \equiv 2 \pmod 3$, then for *every* $b$, the curve $y^2 = x^3 + b$ has exactly $p+1$ points over $\mathbb{F}_p$. In particular $3 \mid \#E(\mathbb{F}_p)$, since $p + 1 \equiv 0 \pmod 3$.

Not "approximately $p+1$"; exactly. Every single one of the $p$ curves in the family, no exceptions. And a divisibility invariant comes along free: the point count is always a multiple of $3$.

The second family is the mirror image. Consider $y^2 = x^3 + ax$, whose right-hand side is an *odd* function: replacing $x$ by $-x$ negates it. Suppose $p \equiv 3 \pmod 4$, so that $-1$ is not a square modulo $p$ and $\chi(-1) = -1$. Then $\chi$ of the negated input is the negative of $\chi$ of the input, so summing over $x$ and over $-x$ gives $S(a,0) = -S(a,0)$, forcing $S(a,0)=0$.

> **Theorem (Second supersingular family).** If $p \equiv 3 \pmod 4$, then for *every* $a$, the curve $y^2 = x^3 + ax$ has exactly $p+1$ points over $\mathbb{F}_p$. In particular $4 \mid \#E(\mathbb{F}_p)$.

These are what algebraic geometers call *supersingular* curves, normally introduced through the theory of formal groups or endomorphism rings. Here they fall out of a change of variables.

By contrast, take $p = 13$, which is $1 \bmod 3$ and $1 \bmod 4$. The curve $y^2 = x^3+1$ has $12$ points; $y^2 = x^3+2$ has $19$. The wobble is alive and well.

---

## Even or odd? Ask the cubic

Here is a second kind of law: not the exact count, but its parity.

Look again at the counting formula. Each term $\chi(x^3+ax+b)$ is $\pm 1$ when the cubic is nonzero at $x$, and $0$ when it vanishes. Modulo $2$, a $\pm1$ is the same as a $1$. So, modulo $2$, the character sum counts the $x$'s at which the cubic does *not* vanish. Rearranging:
$$\#E(\mathbb{F}_p) \equiv 1 + \#\{x : x^3+ax+b = 0\} \pmod 2.$$

That is already a clean statement, but the punchline requires one more ingredient, which is a small gem in its own right.

> **The 0/1/3 dichotomy.** For a nonsingular curve — meaning $4a^3 + 27b^2 \ne 0$, the condition that the cubic has no repeated root — the number of roots of $x^3+ax+b$ in $\mathbb{F}_p$ is $0$, $1$, or $3$. Never $2$.

Why? Suppose $r \ne s$ are both roots. Subtracting the two equations and dividing by $r-s$ pins down the coefficients completely: $a = -(r^2+rs+s^2)$ and $b = rs(r+s)$. With those values the cubic factors as
$$x^3+ax+b = (x-r)(x-s)\bigl(x + r + s\bigr),$$
so a *third* root $-(r+s)$ appears automatically, and nonsingularity forces it to differ from the other two. Two roots always drag a third one along.

Combining the two facts, the parity of the count is decided by whether the cubic has a root at all:

> **Theorem (2-torsion criterion).** For a nonsingular curve, $\#E(\mathbb{F}_p)$ is even if and only if $x^3+ax+b$ has a root in $\mathbb{F}_p$.

The geometry behind this is that a root $r$ of the cubic corresponds to the point $(r,0)$ on the curve, which is its own negative — an element of order $2$ in the group. Lagrange's theorem then says the group order is even. What the elementary argument adds is the converse, and the fact that the whole thing is visible in a character sum.

And the nonsingularity hypothesis is not decorative. Over $\mathbb{F}_5$, take the *singular* cubic $x^3+2x+2 = (x-1)^2(x+2)$: its discriminant vanishes, it has exactly two distinct roots — the forbidden number — and the corresponding equation has $7$ solutions, an odd count. Remove the hypothesis and the theorem dies immediately.

---

## Twins: the quadratic twist

Pick a nonsquare $d$ modulo $p$ and replace $(a,b)$ by $(ad^2, bd^3)$. Substituting $x \mapsto dx$ multiplies the cubic by $d^3$, and $\chi(d^3) = \chi(d)^3 = -1$, so every term of the character sum flips sign.

> **Theorem (Twisting).** If $\chi(d) = -1$, then $S(ad^2, bd^3) = -S(a,b)$; equivalently the traces are negatives of each other, and
> $$\#E(\mathbb{F}_p) + \#E^{d}(\mathbb{F}_p) = 2p+2.$$

A curve with unusually many points has a partner with exactly as many too few. Over $\mathbb{F}_5$, the curve $y^2 = x^3+x+1$ has $9$ points and its twist has $3$; and $9 + 3 = 12 = 2\cdot 5 + 2$. Excess and deficit are always in perfect balance.

---

## The average curve, and the exact variance

The twisting theorem pairs up curves with opposite wobble, and the pairing is essentially a bijection on the whole family. So the *average* wobble should vanish, and it does:
$$\sum_{a,b \in \mathbb{F}_p} a(a,b) = 0.$$
Equivalently, the $p^2$ short Weierstrass curves have, in total, exactly $p^2(p+1)$ points. The average curve has exactly $p+1$ points — not approximately, exactly.

The average is the boring statistic. The interesting one is the **variance**, and here the elementary method delivers something startlingly clean.

> **Theorem (Exact second moment).** For every odd prime power $q$,
> $$\sum_{a,b \in \mathbb{F}_q} a(a,b)^2 = q^3 - q^2.$$

Divide by the number of curves, $q^2$, and read it as a statement about a random curve: the mean square of the trace is exactly $q-1$. The heuristic "the wobble is about $\sqrt{q}$" is not a heuristic at all — it is an identity, with no error term whatsoever.

The proof is a two-step exchange of summation. Squaring the character sum turns it into a double sum over pairs $(x,y)$ of $\chi\bigl((x^3+ax+b)(y^3+ay+b)\bigr)$. Now sum over $b$ *first*. For fixed $x, y, a$, the argument is a quadratic in $b$: it is $(b+u)(b+v)$ with $u = x^3+ax$ and $v = y^3+ay$. And the character sum of a separable quadratic is completely elementary:
$$\sum_{b}\chi\bigl((b+u)(b+v)\bigr) = \begin{cases} q-1 & u = v,\\ -1 & u \ne v.\end{cases}$$
(For $u \ne v$, shift and rescale: the sum becomes $\sum_{t \ne 1}\chi(t)$, which is $0 - \chi(1) = -1$.)

So everything reduces to a *combinatorial* question: for how many pairs $(x,y)$ is $x^3+ax = y^3+ay$? Call this the **collision count** of the parameter $a$. Summing the collision counts over all $a$ — a short calculation using the factorization $x^3-y^3 + a(x-y) = (x-y)(x^2+xy+y^2+a)$ — produces the clean total $q^3-q^2$. Point counting on curves has become bookkeeping on collisions.

The immediate payoff is a form of Hasse's theorem on average. By Chebyshev's inequality, for any threshold $K > 0$,
$$K \cdot \#\{(a,b) : a(a,b)^2 \ge K\} \le q^3 - q^2.$$
Setting $K = 4q$ shows that at most a quarter of all curves could possibly violate the Hasse bound — and taking $K$ slightly larger shows that the fraction violating $|a| \ge \lambda\sqrt{q}$ is at most $1/\lambda^2$. The second moment also runs the other way: because the mean square is exactly $q-1$, *some* curve in the family must have $a(a,b)^2 \ge q-1$. Combined with Hasse's bound, the largest wobble in the family sits between $\sqrt{q-1}$ and $2\sqrt{q}$ — an interval of a single constant factor.

---

## Slicing thinner: the vertical moments

The second moment averaged over *all* $q^2$ curves. What if we freeze $a$ and average only over $b$ — a single vertical line through the family? The elementary method still answers, and the answer is now sensitive to arithmetic.

Following the same route, the vertical moment is $q\cdot(\text{collisions}(a)) - q^2$, so what is needed is the exact collision count. And the collision equation $x^2+xy+y^2 = -a$ is a **conic**. Counting points on a conic is a matter of completing the square: for each $x$ the equation is a quadratic in $y$ with discriminant $-3x^2 - 4a$, and every quadratic character sum of a quadratic polynomial can be evaluated in closed form. The number that emerges — inevitably — is $\chi(-3)$, the character of the discriminant of $x^2+xy+1$.

> **Theorem (Vertical second moments).** Let $q$ be a prime power with $\gcd(q,6)=1$. Then
> $$\sum_{b \in \mathbb{F}_q} a(0,b)^2 = q(q-1)\bigl(1 + \chi(-3)\bigr),$$
> and for $a \ne 0$,
> $$\sum_{b \in \mathbb{F}_q} a(a,b)^2 = q^2 - q\bigl(1 + \chi(-3) + \chi(-a/3)\bigr).$$

Both formulas are exact, with no error term. Summing the second over $a \ne 0$ and adding the first recovers $q^3 - q^2$, since $\sum_a \chi(-a/3) = 0$.

The first formula has a striking consequence. A sum of squares vanishes if and only if every term does, so:

> **Corollary.** The whole family $y^2 = x^3 + b$ is supersingular — every member has exactly $q+1$ points — **if and only if** $\chi(-3) = -1$.

That is an if-and-only-if, and it identifies an *analytic* condition (a character value) with a *combinatorial* one (cubing is a bijection). Chasing the same collision count in the opposite direction gives the bridge directly:

> **Theorem (Cubic/quadratic bridge).** Cubing is a bijection of $\mathbb{F}_q$ if and only if $-3$ is a nonsquare in $\mathbb{F}_q$.

Over a prime field, unwinding the group theory turns this into a classical statement:

> **Corollary (Supplementary reciprocity for $-3$).** For a prime $p > 3$, $-3$ is a nonsquare modulo $p$ if and only if $p \equiv 2 \pmod 3$.

This is a standard supplement to the law of quadratic reciprocity, and here it has been *derived by counting points on curves*. The logic ran: count collisions on a conic $\Rightarrow$ get the vertical moment $\Rightarrow$ read off when the trace vanishes identically $\Rightarrow$ conclude a reciprocity law. That is arithmetic geometry paying a debt back to elementary number theory.

---

## What the method cannot do — yet

There is one thing conspicuously missing: Hasse's bound itself, $a(a,b)^2 \le 4p$, for a *single specified* curve. The moments give it for almost all curves; exhaustive computation confirms it for every curve over $\mathbb{F}_5, \mathbb{F}_7, \mathbb{F}_{11}, \mathbb{F}_{13}$; but the character-sum toolkit as developed here does not produce a pointwise bound. That is not an accident: a genuine pointwise square-root cancellation for a cubic character sum is exactly the content of the Riemann Hypothesis for curves, and it is expected to be hard.

But the moment method points at a route. If the *fourth* moment $\sum_{a,b} a(a,b)^4$ could be computed exactly — and the same collision bookkeeping suggests it should be, with leading term $2q^5 - 3q^4$ — the Chebyshev bound would improve from $O(q^2/\lambda^2)$ to $O(q^2/\lambda^4)$, shrinking the exceptional set. Push far enough up the moment ladder, and the exceptional set becomes empty. Alternatively, since the trace over the extension field $\mathbb{F}_{q^n}$ satisfies the recursion $a_{n+1} = a_1 a_n - q a_{n-1}$, and Hasse's bound is equivalent to that recursion never producing a negative point count, one could hope to derive the recursion from moment identities over the tower of extensions rather than from the eigenvalues of Frobenius.

That is a real research program, and it is not finished. What *is* finished is the striking amount of exact structure that a single observation — that $\chi(c)+1$ counts square roots — can be made to yield: exact point counts for two infinite supersingular families, a parity criterion, a root dichotomy, a twisting symmetry, a vanishing first moment, an exactly evaluated second moment, its arithmetic refinement along vertical slices, and, as a byproduct, a reciprocity law.

Sometimes the deepest structures are the ones you can reach by counting carefully.
