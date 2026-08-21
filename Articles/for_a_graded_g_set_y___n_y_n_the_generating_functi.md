# The Shape of Symmetry, One Grade at a Time

## How counting orbits turns into a single rational function

Imagine a tower of rooms. Room $0$ is empty. Room $1$ holds one object, room $2$ holds two, room $3$ holds three, and so on forever. In each room a group of symmetries acts — shuffling the objects around, permuting them, rotating them, relabelling them. Now ask a question that sounds innocuous:

> In room $n$, how many *essentially different* ways are there to point at $r$ distinct objects?

"Essentially different" means: up to the symmetry available in that room. If the symmetry group can carry one choice of $r$ objects onto another, the two choices are the same choice as far as the room is concerned. Call the answer $t_r(Y_n)$ — the number of orbits of ordered $r$-tuples of distinct elements.

You now have an infinite sequence of integers, one per room:
$$t_r(Y_0),\; t_r(Y_1),\; t_r(Y_2),\; t_r(Y_3),\;\dots$$

The claim this article is about is that this sequence, wild as it looks, is almost never wild at all. Package it into a single formal object, the **Hilbert series**
$$H_r(q) \;=\; \sum_{n \ge 0} t_r(Y_n)\, q^n,$$
and — provided the rooms eventually become symmetric enough — this infinite series collapses to a *rational function*: a ratio of two polynomials, with the denominator not merely rational but of a very specific shape, a power of $(1-q)$. Even more sharply: eventual $r$-transitivity forces the denominator all the way down to a single factor $1-q$.

That is the story. Getting there involves a beautiful three-way dictionary between group actions, finite differences, and power series, and it ends with a precise account of exactly how much symmetry buys you.

---

## What "enough symmetry" means

The relevant notion of "symmetric enough" is old and precise. A group $G$ acting on a set $Y$ is called **$r$-transitive** if, given any two ordered lists $(y_1,\dots,y_r)$ and $(z_1,\dots,z_r)$ of $r$ distinct elements of $Y$, there is a group element $g$ with $g\cdot y_i = z_i$ for every $i$ — and if such lists exist at all. One-transitivity is ordinary transitivity: any point can be moved to any other. Two-transitivity says any ordered pair of distinct points can be moved to any other ordered pair. And so on.

The symmetric group $S_n$ acting on $\{1,\dots,n\}$ is $r$-transitive for every $r \le n$: you can send any list of $r$ distinct labels to any other, simply because you are allowed to permute arbitrarily. At the opposite extreme, the trivial group acting on $\{1,\dots,n\}$ moves nothing, so no two distinct lists are ever identified.

Here is the reformulation that drives everything:

> **$r$-transitivity is exactly the statement $t_r(Y) = 1$.**

If the group can move any $r$-tuple of distinct elements to any other, and at least one such tuple exists, then there is precisely one orbit. Conversely, one orbit means precisely that. The qualitative notion "enough symmetry" and the quantitative counter $t_r$ are the same thing, viewed from two sides. That single observation is the hinge on which the whole theorem swings, because it converts a statement about group actions into a statement about a sequence of integers being eventually equal to $1$.

---

## From sequences to series, and back

Suppose you have a sequence $a_0, a_1, a_2, \dots$ of rational numbers and you want to know when its generating function $\sum_n a_n q^n$ is a rational function whose denominator is a power of $1-q$. There is a clean, entirely elementary answer, and it involves the humblest operator in mathematics: the **forward difference**
$$(\Delta a)(n) \;=\; a(n+1) - a(n).$$

The forward difference is the discrete cousin of the derivative. Applying it to a constant sequence gives zero. Applying it to a linear sequence gives a constant. Applying it twice to a quadratic gives a constant, three times gives zero. In general, $\Delta^{r+1}$ annihilates every polynomial of degree at most $r$ — precisely the way the $(r+1)$-st derivative does.

Now watch what multiplication by $1-q$ does to a generating function. If $A(q) = \sum_n a_n q^n$, then
$$(1-q)\,A(q) \;=\; a_0 \;+\; \sum_{n \ge 0}\bigl(a_{n+1}-a_n\bigr) q^{n+1} \;=\; a_0 \;+\; q\sum_{n\ge0} (\Delta a)(n)\, q^n.$$

**Multiplying the series by $1-q$ is differencing the sequence.** That single identity, verified by matching coefficients, is the entire engine. Iterate it $k$ times and you obtain:

> **The Rationality Criterion.** For a sequence $a$ of rational numbers and an integer $k \ge 0$, the product $(1-q)^k \sum_n a_n q^n$ is a *polynomial* if and only if the $k$-th forward difference $\Delta^k a$ vanishes for all sufficiently large $n$.

Both directions are honest. Forward: if $\Delta^k a$ dies eventually, its generating function is a polynomial, and unwinding the identity $k$ times assembles a polynomial numerator. Backward: if $X\cdot \varphi$ is a polynomial then so is $\varphi$ (just shift the coefficients), and peeling off one factor of $1-q$ at a time reduces $k$ to $0$.

There is nothing analytic here — no radius of convergence, no worry about whether the series converges. Everything happens in the ring of formal power series, where $1-q$ is invertible (its inverse is $1+q+q^2+\cdots$), so the equation "$(1-q)^k A(q) = P(q)$ for a polynomial $P$" genuinely does exhibit $A$ as the honest quotient $P(q)/(1-q)^k$.

---

## The main theorem, in one line

Now combine the two halves.

Suppose the grades of our tower are eventually $r$-transitive: there is some threshold $N$ such that for every $n \ge N$, the group acting on room $n$ is $r$-transitive on that room's elements. By the hinge observation, $t_r(Y_n) = 1$ for all $n \ge N$. So the sequence $t_r(Y_\bullet)$ is *eventually constant*. A constant sequence is killed by a single application of $\Delta$. By the Rationality Criterion with $k = 1$:

> **Main Theorem.** If a graded $G$-set is eventually $r$-transitive, then
> $$(1-q)\sum_{n\ge0} t_r(Y_n)\,q^n \;=\; P(q)$$
> for some polynomial $P$. In particular $\sum_n t_r(Y_n) q^n$ is a rational function whose denominator divides $(1-q)^{r+1}$.

Multiplying by the harmless extra factor $(1-q)^r$ recovers the $(1-q)^{r+1}$ form; the content is that the true denominator is the *single* factor $1-q$. Transitivity is a strong hypothesis, and this is its dividend: a simple pole and nothing more.

The numerator $P$ is not arbitrary. There is a rigid constraint on it:

> **Residue Theorem.** With $P$ as above, $P(1) = 1$.

Why? Because the coefficients of $P$ telescope. The constant coefficient is $t_r(Y_0)$ and the coefficient of $q^{n+1}$ is the difference $t_r(Y_{n+1}) - t_r(Y_n)$; summing them all collapses to the eventual value of the sequence, which is $1$ by transitivity. Analytically this says the pole of $H_r$ at $q = 1$ is simple with residue $-1$. Combinatorially it says: however irregular the low grades are, the numerator's coefficients must sum to exactly one orbit. The numerator is a complete record of the "defect region" — the finitely many grades where transitivity has not yet kicked in — and $P(1)=1$ is the single global law it must obey.

In the cleanest possible situation, where the grades below the threshold are so small that they carry no $r$-tuple of distinct elements at all, the numerator is forced to be a monomial:

> **Exact Form.** If every grade $n \ge N$ is $r$-transitive and every grade $n < N$ contains no injective $r$-tuple, then
> $$\sum_{n\ge0} t_r(Y_n)\,q^n \;=\; \frac{q^N}{1-q}.$$

---

## The example everyone should have in mind

Take room $n$ to be the set $\{1,\dots,n\}$ with the full symmetric group $S_n$ acting. Fix $r$. For $n < r$ there simply is no list of $r$ distinct elements: the room is too small, and $t_r = 0$. For $n \ge r$ the symmetric group is $r$-transitive, so $t_r = 1$. The sequence is
$$0,0,\dots,0,1,1,1,\dots$$
with the switch flipping at $n = r$, and the Hilbert series is exactly
$$\sum_{n\ge0} t_r(Y_n)\,q^n \;=\; q^r + q^{r+1} + q^{r+2} + \cdots \;=\; \frac{q^r}{1-q}.$$

A simple pole at $q=1$, numerator $q^r$, and indeed $P(1) = 1$. The "defect region" is the block of grades $0,\dots,r-1$ that are too small to be interesting, and the numerator $q^r$ records exactly where the interesting behaviour begins.

---

## What happens when you remove the symmetry

Is the exponent $r+1$ in the general statement mere slack? No. Keep the very same rooms — $\{1,\dots,n\}$ again — but replace the symmetric group by the *trivial* group. Nothing moves. Every ordered list of $r$ distinct elements is its own orbit, so
$$t_r(Y_n) \;=\; n(n-1)(n-2)\cdots(n-r+1) \;=\; r!\binom{n}{r},$$
the falling factorial. This is a polynomial in $n$ of degree exactly $r$, and its generating function is
$$\sum_{n\ge0} r!\binom{n}{r} q^n \;=\; \frac{r!\, q^r}{(1-q)^{r+1}}.$$

Here the pole at $q=1$ has order exactly $r+1$ — no smaller power of $1-q$ clears the series. The reason is Pascal's rule read backwards: differencing $\binom{n}{r}$ gives $\binom{n}{r-1}$, so it takes exactly $r$ differences to reach the constant sequence $1$ and one more to reach zero. After only $r$ differences you are left with the constant $1$, which never dies, so $(1-q)^r$ leaves a genuine pole behind.

So the two families sit at the two extremes of the same picture, with *identical underlying sets*:

| Rooms | Group | $t_r(Y_n)$ | Hilbert series | Pole order |
|---|---|---|---|---|
| $\{1,\dots,n\}$ | $S_n$ | $0$ then $1$ | $q^r/(1-q)$ | $1$ |
| $\{1,\dots,n\}$ | trivial | $r!\binom{n}{r}$ | $r!\,q^r/(1-q)^{r+1}$ | $r+1$ |

It is not the size of the rooms that determines the pole order. It is the symmetry. Transitivity collapses the denominator from $(1-q)^{r+1}$ all the way to $1-q$, and the bound $r+1$ is exactly right for the general case where transitivity is absent.

---

## A complete dictionary

Once you see the difference operator at work, a much finer statement falls out. The number of differences it takes to annihilate a sequence is a measure of its complexity, and Newton's classical forward-difference formula reconstructs the sequence from those differences. If $\Delta^k a$ vanishes from index $N$ onwards, then for every $n \ge N$,
$$a(n) \;=\; \sum_{j=0}^{k-1} (\Delta^j a)(N)\,\binom{n-N}{j}.$$

This is the discrete Taylor expansion: the iterated differences at the base point play the role of derivatives, and the binomial coefficients play the role of the monomials $x^j/j!$. It is proved by induction on $k$ using the hockey-stick identity $\sum_{i<m}\binom{i}{j} = \binom{m}{j+1}$, which is the discrete fundamental theorem of calculus.

Combining it with the Rationality Criterion produces a genuine three-way equivalence:

> **Classification.** For a rational sequence $a$ and an integer $k \ge 0$, the following are equivalent:
> 1. $(1-q)^k \sum_n a_n q^n$ is a polynomial;
> 2. $\Delta^k a$ vanishes for all large $n$;
> 3. beyond some index, $a$ is a rational linear combination of the $k$ shifted binomial functions $\binom{n-N}{0},\dots,\binom{n-N}{k-1}$.

And since those binomial functions are exactly a basis for polynomials of degree $< k$, one gets the polished form: **the denominator $(1-q)^{r+1}$ suffices precisely when the sequence is eventually a polynomial in $n$ of degree at most $r$.** The universal example is $\binom{n}{r}$, whose generating function is exactly $q^r/(1-q)^{r+1}$ — proved not by any clever manipulation but purely from Pascal's rule $\Delta\binom{\cdot}{r+1} = \binom{\cdot}{r}$, iterated.

The exponent in the denominator is therefore not a technical artefact. It is a *measurement*: it tells you the polynomial degree of the orbit-counting sequence, and hence how far the tower is from being transitive.

---

## A second, entirely different route

There is another way to reach rationality that never mentions transitivity at all, and it comes from Burnside's orbit-counting lemma — the observation that the number of orbits of a finite group is the average number of fixed points:
$$\sum_{g \in G} \bigl|\mathrm{Fix}(g)\bigr| \;=\; t_r(Y)\cdot |G|,$$
where $\mathrm{Fix}(g)$ is the set of injective $r$-tuples left unchanged by $g$.

Suppose now that a *fixed* finite group $G$ acts on every room, and that for each individual group element $g$, the number of $r$-tuples it fixes grows eventually like a polynomial in $n$ of degree at most $r$. Then averaging over $g$ makes $t_r(Y_n)$ itself eventually polynomial of degree at most $r$ — a *sum* of polynomials of degree $\le r$, divided by the constant $|G|$ — and the Classification immediately gives denominator $(1-q)^{r+1}$.

This is a genuinely different hypothesis. Transitivity is a statement about the group being large; polynomial fixed-point growth is a statement about each element's fixed locus being tame. Neither implies the other, and both produce the same conclusion. Burnside's lemma is the bridge between them: it converts a group-theoretic average into a numerical sequence that the difference operator can chew on.

---

## Everything closes under sums and products

Rationality with poles only at $q = 1$ is not a fragile property. The set of formal power series $f$ for which $(1-q)^k f$ is a polynomial for *some* $k$ forms a **subring** of the ring of formal power series: it contains all polynomials, and it is closed under addition, negation, and multiplication. The proofs are one line each. For a sum, use $(1-q)^{k+\ell}(f+g) = (1-q)^\ell\bigl[(1-q)^k f\bigr] + (1-q)^k\bigl[(1-q)^\ell g\bigr]$; for a product, $(1-q)^{k+\ell}fg = \bigl[(1-q)^k f\bigr]\bigl[(1-q)^\ell g\bigr]$. Pole orders simply add.

The consequence for graded $G$-sets is immediate and pleasant: if two towers are eventually transitive at their respective levels, then the Cauchy product of their Hilbert series — the generating function you would attach to the graded product, where grade $n$ collects all pairs whose grades sum to $n$ — is again rational with a pole only at $q=1$, of order at most $2$. Rationality is a structural feature of the whole category, not an accident of individual examples.

Another closure property, this time downward. Transitivity is nested: an $r$-transitive action is automatically $s$-transitive for every $s \le r$, because you can restrict any $r$-tuple to its first $s$ entries and every $s$-tuple extends. (The one thing to check is that the underlying set is large enough to host $r$-tuples in the first place, which the existence of one such tuple guarantees.) Therefore eventual $r$-transitivity does not just make one Hilbert series rational — it makes the entire **profile** $H_0, H_1, \dots, H_r$ rational, each with a simple pole at $q=1$ and each with numerator satisfying $P(1)=1$. You get $r+1$ theorems for the price of one.

---

## Why this matters

Generating functions being rational is the combinatorialist's signal that something is finitely describable. A rational generating function with denominator a power of $1-q$ means the coefficient sequence eventually satisfies a linear recurrence with constant coefficients of a very special kind — indeed, it eventually *is* a polynomial. That is the shape of Hilbert functions in commutative algebra, of Ehrhart polynomials counting lattice points in dilated polytopes, of dimension counts in graded rings and modules. The theorem above says orbit counts in graded group actions join that family, and it identifies precisely what governs the pole order.

The most striking part is the dichotomy. Two towers can have literally the same rooms and differ only in how much symmetry each room carries, and the difference registers as the *order of a pole*. Symmetry is not a soft, qualitative property here; it is a number you can read off the denominator of a rational function. Full symmetry: order $1$. No symmetry: order $r+1$, no better. Everything in between is measured by the degree of the polynomial that the orbit counts eventually follow.

And the whole edifice rests on one identity a schoolchild could verify — that multiplying a power series by $1-q$ is the same as differencing its coefficients. From that, plus Pascal's rule, plus the observation that "transitive" means "one orbit", the entire theory unfolds.
