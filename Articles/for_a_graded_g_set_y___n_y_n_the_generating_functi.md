# The Partition Function of Symmetry

## How counting "how symmetric" a growing family of objects is produces a rational function with a single pole

### Symmetry, graded by size

Physicists have a habit that mathematicians have learned to imitate: when you have infinitely many things to count, don't count them one at a time. Pack them into a single generating function — a formal series
$$Z(q) \;=\; \sum_{n \ge 0} a_n\, q^n$$
whose coefficients are the counts and whose variable $q$ is a bookkeeping device. In statistical mechanics $Z$ is the partition function, $q$ is a fugacity, and the analytic behaviour of $Z$ — where it converges, where it blows up, how strong the blow-up is — encodes the collective behaviour of the system. Poles are phase transitions. The order of a pole is the strength of the transition.

This article is about a partition function whose coefficients count *symmetry* rather than energy, and about a theorem which says that this partition function is astonishingly tame: it is always a rational function of $q$, and its only singularity is a single, simple pole at $q = 1$.

Here is the setup. Let $G$ be a group — think of it as a collection of allowed transformations. Let $Y_0, Y_1, Y_2, \dots$ be a sequence of sets, each carrying an action of $G$: for every $g \in G$ and every $y \in Y_n$ there is a transformed element $g \cdot y \in Y_n$, compatibly with composition in $G$. We call the disjoint union $Y = \bigsqcup_n Y_n$ a **graded $G$-set**, and $Y_n$ its **grade $n$**. The index $n$ is meant to be a size, a level, a particle number — whatever a physicist would call a quantum number.

The examples are everywhere: $G$ the symmetries of a crystal acting on the set of configurations with $n$ defects; $G$ the group of a gauge theory acting on states with $n$ excitations; $G = \mathbb{Z}$ acting by translation on the residues modulo $n$; $G$ acting trivially, i.e. not at all, on a set of $n$ labelled positions. In every case there is a natural question: *how symmetric is grade $n$?*

### Measuring symmetry with tuples

There is a beautiful and classical way to make "how symmetric" precise, and it belongs to Camille Jordan and Émile Mathieu rather than to any physicist. Fix an integer $r \ge 0$. An **injective $r$-tuple** in a set $Y$ is a list $(y_1, \dots, y_r)$ of $r$ *distinct* elements of $Y$. The group $G$ acts on injective $r$-tuples entrywise: $g \cdot (y_1,\dots,y_r) = (g y_1, \dots, g y_r)$. This action is well defined because a group element is a bijection, so it cannot collapse distinct entries.

Now define
$$t_r(Y) \;=\; \#\{\text{$G$-orbits of injective $r$-tuples in $Y$}\}.$$

This single number measures the $r$-th order symmetry of the action. The extreme case is worth spelling out. We say $G$ acts **$r$-transitively** on $Y$ if there is at least one injective $r$-tuple, and any injective $r$-tuple can be carried to any other by some group element. In other words: pick any $r$ distinct points and any other $r$ distinct points; there is a symmetry taking the first list to the second, in order.

**Transitivity Criterion.** *For every group $G$ acting on a set $Y$ and every $r \ge 0$, one has $t_r(Y) = 1$ if and only if $G$ acts $r$-transitively on $Y$.*

The proof is short: $t_r(Y) = 1$ says the orbit space is a one-point set, which says simultaneously that there is at least one tuple and that all tuples are equivalent. But the criterion is what turns a qualitative notion — "very symmetric" — into a number we can put into a generating function.

At the other extreme, if $G$ does nothing at all, every injective $r$-tuple is its own orbit, and $t_r(Y)$ is simply the number of injective $r$-tuples, namely the descending factorial
$$|Y|^{\underline{r}} \;=\; |Y|\,(|Y|-1)\cdots(|Y|-r+1).$$
And in general, since orbits partition the tuples, there is a universal ceiling:

**Growth Bound.** *For a finite $G$-set $Y$, $\;t_r(Y) \le |Y|^{\underline{r}}$.*

So $t_r$ lives between $1$ (maximal symmetry) and $|Y|^{\underline r}$ (no symmetry). It is a genuine order parameter.

### The partition function of transitivity

For a graded $G$-set $Y = \bigsqcup_n Y_n$ we now form
$$Z_r(q) \;=\; \sum_{n \ge 0} t_r(Y_n)\, q^n,$$
which we might call the **transitivity partition function** at order $r$. The main result of this work concerns families that become highly symmetric once you go far enough up the grading — a very common situation, since large systems often acquire symmetries that small ones cannot support. Call the graded $G$-set **eventually $r$-transitive** if there is an index $N$ such that $G$ acts $r$-transitively on $Y_n$ for every $n \ge N$.

**Rationality Theorem.** *If a graded $G$-set is eventually $r$-transitive from index $N$ on, then*
$$(1-q)^{r+1} \, Z_r(q)$$
*is a polynomial in $q$. Equivalently, $Z_r(q) = Q(q)/(1-q)^{r+1}$ for a polynomial $Q$ with integer coefficients, of degree at most $N + r$.*

And in a genuinely analytic form, valid on the whole open unit disc:

**Analytic Form.** *Under the same hypothesis, for every real $q$ with $|q| < 1$ the series $Z_r(q)$ converges absolutely and*
$$Z_r(q) \;=\; \sum_{n < N} t_r(Y_n)\, q^n \;+\; \frac{q^N}{1-q}.$$
*Consequently $(1-q)\,Z_r(q) = (1-q)\sum_{n<N} t_r(Y_n) q^n + q^N$ is a polynomial expression in $q$.*

Read that formula as a physicist would. The finite sum is the *transient*: whatever irregular, low-symmetry behaviour the small grades exhibit, it contributes a polynomial and nothing more. The term $q^N/(1-q)$ is the *bulk*: once the system is $r$-transitive it contributes exactly $1$ to every coefficient forever, and an infinite string of $1$'s is precisely a simple pole at $q=1$ with residue $-1$. The partition function has one phase transition, at the critical fugacity $q = 1$, and it is of the mildest possible kind. Nothing else can happen. No other singularity, no essential singularity, no natural boundary.

### The engine: a single power of $1-q$ is one difference

Why should this be true, and why does the exponent $r+1$ appear? The mechanism is a piece of nineteenth-century calculus dressed in modern clothes. For a sequence $a = (a_n)$ define its **forward difference**
$$(\Delta a)_n \;=\; a_{n+1} - a_n,$$
the discrete derivative. Then a two-line computation on coefficients gives the identity that drives everything:

**Difference Identity.** *For any integer sequence $a$, in the ring of formal power series,*
$$(1-q)\sum_{n\ge 0} a_n q^n \;=\; a_0 \;+\; q\sum_{n \ge 0} (\Delta a)_n q^n .$$

Multiplying by $1-q$ trades a power of the denominator for one differentiation. Iterate it $s$ times and you obtain a clean coefficient formula:

**Coefficient Formula.** *For all $s, n \ge 0$, the coefficient of $q^{n+s}$ in $(1-q)^s \sum_k a_k q^k$ equals $(\Delta^s a)_n$.*

That is the whole theory in one line. A power series is a polynomial exactly when its coefficients eventually vanish. So:

**Exact Criterion.** *$(1-q)^s \sum_n a_n q^n$ is a polynomial if and only if the $s$-th forward difference $\Delta^s a$ vanishes from some index onwards.*

Both directions hold, and that "if and only if" is the reason the theory is sharp rather than merely sufficient. Rationality with denominator $(1-q)^s$ is not an analytic accident: it is *literally the same statement* as the vanishing of a column in the difference table of the coefficients.

From here the Rationality Theorem is immediate. Eventual $r$-transitivity says $t_r(Y_n) = 1$ for all $n \ge N$; a sequence that is eventually constant has $\Delta a$ eventually zero, so even $(1-q)^1$ clears the denominator, and a fortiori $(1-q)^{r+1}$ does. More generally the same argument proves the ambient statement:

**Polynomial Coefficient Theorem.** *If $a_n = P(n)$ for all $n \ge N$, where $P$ is a polynomial of degree at most $r$, then $(1-q)^{r+1}\sum_n a_n q^n$ is a polynomial of degree at most $N + r$.*

This is because the $(r+1)$-st difference annihilates any polynomial of degree $\le r$ — the discrete analogue of "differentiate a cubic four times and you get zero".

### Why $r+1$, and not less

An exponent bound that can never be attained is a weak theorem. This one is attained, and there is a clean model that shows it. Take the binomial sequence $b_n = \binom{n+r}{r}$. Its generating function is exactly
$$\sum_{n \ge 0}\binom{n+r}{r} q^n \;=\; \frac{1}{(1-q)^{r+1}},$$
and the reason, in the language above, is that differencing a binomial coefficient lowers the top index by one, so $\Delta^r b$ is the constant sequence $1$ and $\Delta^{r+1} b = 0$ — but $\Delta^{s} b$ for $s \le r$ is a sequence of positive numbers that never dies. By the Exact Criterion, $(1-q)^s \sum_n b_n q^n$ fails to be a polynomial for every $s \le r$. The exponent $r+1$ is optimal.

Better still, this extremal behaviour is realised by an honest graded $G$-set. Take $G$ arbitrary, take $Y_n$ to be a set of $n$ labelled points, and let $G$ act **trivially** — the maximally unsymmetric family. Then $t_r(Y_n) = n^{\underline r} = n(n-1)\cdots(n-r+1)$, a polynomial in $n$ of degree exactly $r$; its $r$-th difference is the constant $r!$ and its $(r+1)$-st difference vanishes. So the denominator is exactly $(1-q)^{r+1}$: no smaller power suffices. And, for $r \ge 1$, this family is never eventually $r$-transitive, so the two regimes — maximal symmetry and no symmetry — are genuinely disjoint, and the hypothesis of the Rationality Theorem is not vacuous.

Between the extremes lies a rich middle. Let $G$ be the integers acting by translation on $Y_n = \mathbb{Z}/n\mathbb{Z}$, the cyclic grade. Every grade is $1$-transitive: you can translate any residue to any other. So at order $r=1$ the partition function has a simple pole and nothing more. But at order $r=2$ the situation changes, because a translation preserves the *difference* of a pair, and conversely two pairs with the same nonzero difference are translates of each other. Hence the orbits of injective pairs are in bijection with the nonzero residues, and
$$t_2(\mathbb{Z}/n\mathbb{Z}) \;=\; n - 1 .$$
The counts grow linearly, so the first difference is the constant $1$ and the second difference vanishes: the partition function $\sum_n t_2(Y_n) q^n$ has denominator exactly $(1-q)^2$ — a genuine double pole, strictly between the transitive regime's $(1-q)$ and the general bound $(1-q)^3$ for $r = 2$. The order of the pole is measuring exactly how far the family is from being doubly transitive.

### Symmetry cascades downward

One more structural fact makes the picture coherent. Suppose $G$ acts $r$-transitively on a finite set $Y$ and $k \le r$. Is $G$ also $k$-transitive? Yes:

**Descent Theorem.** *On a finite $G$-set, $r$-transitivity implies $k$-transitivity for every $k \le r$.*

The proof is a small extension argument: given two injective $k$-tuples, extend each to an injective $r$-tuple by adding $r-k$ further distinct points (possible because $r$-transitivity forces $|Y| \ge r$), use $r$-transitivity to map one extension to the other, and restrict back to the first $k$ coordinates. Consequently, if a graded $G$-set is eventually $r$-transitive, then *all* the counts $t_0, t_1, \dots, t_r$ are eventually $1$, and even the total partition function $\sum_n \big(\sum_{k \le r} t_k(Y_n)\big) q^n$ is rational with denominator dividing $(1-q)^{r+1}$ — the coefficients being eventually the constant $r+1$.

### Reading it as a trace over the group

There is a second, more physical way to see the coefficients, and it comes from Burnside's lemma, the orbit-counting principle. For a finite group $G$ acting on a finite set, the number of orbits is the average number of fixed points of the group elements. Applied to injective $r$-tuples:

**Fixed-Point Identity.** *For a finite group $G$ acting on a finite set $Y$,*
$$\sum_{g \in G} \#\mathrm{Fix}_r(g) \;=\; t_r(Y)\,|G|,$$
*where $\mathrm{Fix}_r(g)$ is the set of injective $r$-tuples fixed entrywise by $g$.*

This recasts the whole story as a *sum over the group* rather than over configurations — exactly the move from a configuration-space partition function to a character sum or a sum over sectors. Each group element $g$ contributes its number of frozen $r$-tuples; the total is the orbit count times the order of the group. And now $r$-transitivity has a strikingly simple fixed-point signature:

**Degeneracy at Transitivity.** *If $G$ acts $r$-transitively on $Y$, then $\sum_{g \in G} \#\mathrm{Fix}_r(g) = |G|$: the average number of fixed injective $r$-tuples per group element is exactly $1$.*

Only the identity's share survives, on average. Feeding this back into the generating function gives the fixed-point form of the main theorem: for a graded $G$-set with finite grades that is eventually $r$-transitive, the series
$$\sum_{n \ge 0}\Big(\sum_{g\in G} \#\mathrm{Fix}_r(g,\,Y_n)\Big) q^n$$
is again rational with denominator dividing $(1-q)^{r+1}$, the coefficients settling at the constant $|G|$.

### What the theorem is really saying

Strip away the machinery and the message is this. Symmetry, quantified by orbit counts of tuples and packaged into a generating function, cannot behave wildly. If a growing family of systems eventually acquires $r$-fold symmetry, then everything about the sequence of symmetry counts is captured by a finite amount of data — the transient values below the onset index $N$ — plus a universal tail. Analytically, this is one simple pole at $q=1$. Combinatorially, it is one column of zeros in a difference table. Physically, it is the statement that the approach to a symmetric phase is polynomial, never exotic.

And the converse direction gives the diagnostic that makes this useful in practice. Because the criterion is an equivalence, the *order of the pole at $q=1$* is an exact measurement: it is the least $s$ such that the $s$-th difference of the symmetry counts eventually vanishes. A simple pole means the family is eventually maximally symmetric at level $r$. A pole of order $s$ means the symmetry counts grow like a polynomial of degree $s-1$. A non-rational partition function — no pole order works — means the family never settles into any polynomial regime at all.

We began with an analogy between a fugacity expansion and a symmetry count. The analogy turns out to be more than decorative: in both cases the location and order of the singularity is where the physics lives. Here we can say exactly where the singularity is, exactly how strong it is, and exactly what it is counting. That is a rare degree of control, and it comes from a single identity — that multiplying by $1-q$ is the same thing as taking a difference.
