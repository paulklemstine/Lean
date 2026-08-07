# The Arithmetic of Near Misses

## How a factor of four, a rule modulo eight, and a coding-theory dictionary explain when a quadratic equation has *no* integer solutions

---

### Equations that almost have solutions

Ask a computer to solve
$$x_1^2 + x_2^2 + x_3^2 - x_1 - x_2 - x_3 = -1$$
in integers and it will grind away forever, because there are no solutions. Ask it *why* there are none and it will have nothing to say. The equation is not obviously impossible: the left-hand side is a perfectly ordinary polynomial, it takes negative values over the real numbers, and nothing about it screams contradiction.

The reason is a near miss. Complete the square on each variable:
$$\sum_{i=1}^{3}\left(x_i - \tfrac12\right)^2 = -1 + \tfrac34 = -\tfrac14 .$$
A sum of three squares can't be negative, so we are done — but notice how *close* the equation came to being solvable. Push the constant from $-1$ to $-3/4$ and the equation becomes $\sum (x_i - 1/2)^2 = 0$, still unsolvable but only barely: no integer point sits exactly at $(\tfrac12,\tfrac12,\tfrac12)$. The genuinely interesting question is: **how close can an integer point get?**

That question has a name. Rewrite the equation geometrically. The expression $\sum(x_i - t_i)^2$ measures the squared distance from an integer point $x$ to a fixed target $t$. Solving $\sum (x_i - t_i)^2 = c$ in integers means finding a lattice point at squared distance exactly $c$ from $t$. The smallest achievable value — the squared distance from $t$ to its nearest integer point — is a number we will call the **spectral gap** at $t$, written $\mu(t)$. Every value $c$ below $\mu(t)$ gives an equation with no integer solutions at all.

This article is about how to compute, bound, and understand $\mu(t)$ — not just for the round metric $\sum x_i^2$, but for an arbitrary positive definite quadratic form on the integer lattice. Three surprises await: a universal factor of $1/4$ that cannot be improved, a law modulo $8$ that doubles the gap for special targets, and a dictionary that turns the whole story into binary coding theory.

---

### The stage: forms, lattices, and two minima

Fix a dimension $n$ and a symmetric $n \times n$ matrix $B$ with rational entries which is **positive definite**: $Q(x) = x^{\mathsf T} B x > 0$ for every nonzero rational vector $x$. The function $Q$ is a *quadratic form*; the lattice is $L = \mathbb{Z}^n$, sitting inside $\mathbb{Q}^n$. Think of $Q$ as a distorted notion of squared length — ellipsoids instead of spheres.

Two numbers govern everything.

The **minimal lattice energy** $\lambda_1$ is the smallest value $Q$ takes at a nonzero lattice point:
$$\lambda_1 = \min_{m \in \mathbb{Z}^n,\; m \neq 0} Q(m).$$
It is the *packing* invariant: nonzero lattice points cannot be shorter than this, so balls of $Q$-radius $\sqrt{\lambda_1}/2$ around lattice points never overlap.

The **spectral gap** at a rational target $t$ is
$$\mu(t) = \min_{m \in \mathbb{Z}^n} Q(t - m),$$
the energy of the best possible integer approximation to $t$. It is the *covering* invariant when maximised over $t$. And it is exactly the threshold below which the non-homogeneous equation $Q(x - t) = c$ has no integral solution.

The original guess one might make — that the spectral gap is at least the minimal lattice energy, $\mu \geq \lambda_1$ — is simply false, and dramatically so. It is off by a factor of four, and the correct statement is far more interesting than the guess.

---

### The factor of four, and why it is exactly four

Here is the first main result.

> **Torsion Gap Theorem.** Let $r \geq 2$ be an integer and let $t$ be an *$r$-torsion shift*: a rational vector with $rt \in \mathbb{Z}^n$ but $t \notin \mathbb{Z}^n$. Then for every lattice point $m$,
> $$Q(t - m) \;\geq\; \frac{\lambda_1}{r^2}.$$

The proof is three lines and requires no reduction theory whatsoever. Write $rt = v \in \mathbb{Z}^n$. Then $t - m = \frac{1}{r}(v - rm)$, and since $Q$ is homogeneous of degree two,
$$Q(t - m) = \frac{1}{r^2}\,Q(v - r m).$$
The vector $v - rm$ is an *integer* vector, and it is nonzero — if it vanished then $t = m$ would be a lattice point, contradicting $t \notin \mathbb{Z}^n$. So $Q(v - rm) \geq \lambda_1$ by definition of the minimal lattice energy, and we are done.

The constant cannot be improved, and this is where the theory becomes sharp rather than merely true.

> **Rigidity.** For an $r$-torsion shift $t$, the bound is *attained* — that is, $\mu(t) = \lambda_1/r^2$ — **if and only if** $t \equiv w/r \pmod{\mathbb{Z}^n}$ for some lattice vector $w$ realising the minimum, $Q(w) = \lambda_1$.

So the metric quantity $\mu$ is not a blunt instrument: it detects the shortest vectors of the lattice exactly. Halve a shortest vector, and you land at a point whose distance to the lattice is precisely a quarter of the minimal energy. Land anywhere else among the $2$-torsion points, and you are strictly further away.

There is even a gap in the gaps. If $\lambda_2$ is any lower bound for the values $Q$ takes above $\lambda_1$, then a *non-extremal* $r$-torsion shift satisfies $\mu(t) \geq \lambda_2/r^2$. The spectrum of spectral gaps at $r$-torsion shifts has a hole: no value lies strictly between $\lambda_1/r^2$ and $\lambda_2/r^2$.

None of this depends on how we chose coordinates. Changing the lattice basis by a unimodular integer matrix $U$ replaces $B$ by the congruent matrix $U^{\mathsf T} B U$, and one checks that $Q_{U^{\mathsf T}BU}(x) = Q_B(Ux)$; since $m \mapsto Um$ permutes $\mathbb{Z}^n$, both $\lambda_1$ and $\mu$ are unchanged. Lattice reduction — replacing a bad basis by a good one — is therefore a legitimate way to *compute* these quantities, which is exactly what makes them tractable in practice.

---

### From gaps to unsolvability

Return to Diophantine equations. The general non-homogeneous quadratic is
$$F(x) = Q(x) + \ell(x) + c, \qquad \ell(x) = \textstyle\sum_i b_i x_i .$$
Completing the square means finding a rational $s$ with $2\,\mathrm{Bil}(s,\,\cdot\,) = \ell$, where $\mathrm{Bil}$ is the symmetric bilinear form attached to $B$; then
$$F(x) = Q(x + s) + \bigl(c - Q(s)\bigr).$$
The classical, purely real obstruction now says $F(x) \geq c - Q(s)$, so $F = 0$ is unsolvable whenever $c > Q(s)$. That is the textbook criterion, and it throws away all the arithmetic.

The arithmetic sharpens it. Restricting $x$ to the lattice, $Q(x+s) \geq \mu(-s)$ by the very definition of the spectral gap, so
$$F(x) \;\geq\; \mu(-s) + c - Q(s) \qquad \text{for all } x \in \mathbb{Z}^n,$$
and $F = 0$ is unsolvable as soon as $c > Q(s) - \mu(-s)$. **The improvement over the classical criterion is exactly the spectral gap $\mu(-s)$.** In the case singled out by the Torsion Gap Theorem — where $-s$ is the $r$-torsion point $v/r$ of a shortest vector — we have $\mu(-s) = \lambda_1/r^2 = Q(s)$ exactly, and the test becomes: no integral solution once $c > 0$.

Our opening example is the case $B = I$, $n = 3$, with $s = -\tfrac12(1,1,1)$. Here $Q(s) = 3/4$, and the spectral gap at $-s = (\tfrac12,\tfrac12,\tfrac12)$ — the deep hole of $\mathbb{Z}^3$ — is also $3/4$. The classical bound rejects only $c > 3/4$; the arithmetic rejects every $c > 0$. And in fact the arithmetic says considerably more, as we now see.

---

### Modulo eight: why the gap sometimes doubles

Take the *deep hole* of $\mathbb{Z}^n$, the target $t = (\tfrac12, \ldots, \tfrac12)$ furthest from all lattice points. Its spectral gap is $n/4$: the nearest integer points are the $2^n$ vertices of the surrounding cube, each at squared distance $n \cdot (1/2)^2$. What are the *other* attained values?

Multiply through by $4$. The value $\sum_i (\tfrac12 - m_i)^2$ equals $\frac14 \sum_i (1 - 2m_i)^2$, a sum of $n$ **odd** squares divided by four. Every odd square is $\equiv 1 \pmod 8$, because $(2m-1)^2 = 8\binom{m}{2} + 1$. So the sum is $\equiv n \pmod 8$, and

> **Deep-hole spectrum.** The set of values attained by $\sum_i (x_i - \tfrac12)^2$ on $\mathbb{Z}^n$ is contained in $\tfrac{n}{4} + 2\mathbb{Z}_{\geq 0}$.

Consecutive attained values therefore differ by at least $2$ — not $1/4$, which is all integrality would give — and both $n/4$ and $n/4 + 2$ actually occur. Equivalently: the equation $\sum_i (2x_i - 1)^2 = N$ is unsolvable unless $N \equiv n \pmod 8$ and $N \geq n$.

Why $8$? This looked, at first, like an accident of the round form. It is not. The explanation is a classical notion given a new role.

> **Definition.** A lattice vector $v$ is a **characteristic vector** of the integral form $Q$ if the functional $u \mapsto \mathrm{Bil}(v, u) + Q(u)$ is even for every lattice vector $u$.

For $\mathbb{Z}^n$ with the standard form, the all-ones vector $w = (1,\ldots,1)$ is characteristic, because $\mathrm{Bil}(w,u) + Q(u) = \sum_i u_i(1 + u_i)$ is a sum of products of consecutive integers. And the mod-$8$ law turns out to be *exactly equivalent* to being characteristic:

> **Characteristic Vector Criterion.** For a symmetric integral form $Q$ and a lattice vector $v$, the following are equivalent:
> 1. $v$ is a characteristic vector;
> 2. $Q(v + 2u) \equiv Q(v) \pmod 8$ for every lattice vector $u$.

The proof is a single expansion. Because $Q$ is quadratic,
$$Q(v + 2u) = Q(v) + 4\bigl(\mathrm{Bil}(v,u) + Q(u)\bigr),$$
and $8 \mid 4T$ if and only if $2 \mid T$. Both implications fall out at once. The equivalence is sharp in the strongest possible sense: a *non*-characteristic $v$ produces some value $\equiv Q(v) + 4 \pmod 8$, which halves the gap from $2$ down to $1$.

The consequence for the non-homogeneous form is immediate: at the half point $v/2$ of a characteristic vector $v$, every attained value of $Q(x - v/2)$ lies in $\tfrac{Q(v)}{4} + 2\mathbb{Z}$, and hence **distinct attained values differ by at least $2$**. "Gap two in the shifted spectrum" and "the shift is half a characteristic vector" are the same statement. The deep hole of $\mathbb{Z}^n$ is just the case $v = (1,\ldots,1)$.

It is worth pausing over the coincidence of constants. The factor $4$ in the expansion $Q(v+2u) = Q(v) + 4(\cdots)$ is the same $4$ as in the spectral gap $\lambda_1/4$: both come from the index of $2L$ in $L$. But the two theorems are logically independent — one is a statement about real distances, the other about $2$-adic congruences. They happen to be driven by the same doubling.

---

### A dictionary with coding theory

Which values can the spectral gap take? For $\mathbb{Z}^n$ restricted to the $2$-torsion targets — the points $t$ with $2t \in \mathbb{Z}^n$ but $t \notin \mathbb{Z}^n$ — there is a complete answer, and it is a translation of covering geometry into binary codes.

Each such class has a unique representative whose coordinates are $0$ or $\tfrac12$. Write $s$ for the set of coordinates equal to $\tfrac12$; the number $|s|$ is the **Hamming weight** of the class regarded as a vector in $\mathbb{F}_2^n$.

> **Gap Spectrum Theorem.** For $\mathbb{Z}^n$ with the standard form, the spectral gap at a $2$-torsion shift of Hamming weight $k$ is exactly $k/4$. Consequently the set of spectral gaps at $2$-torsion shifts is precisely
> $$\left\{\tfrac{k}{4} \;:\; 1 \leq k \leq n\right\}.$$

The mechanism is additivity: the standard form splits over the coordinates, each half-integral coordinate contributes at least $1/4$ and each integral one at least $0$, and both bounds are attained at the *same* lattice point. The Hamming-weight-$1$ classes are the extremal ones from the rigidity theorem (gap $\lambda_1/4 = 1/4$); the weight-$n$ class is the deep hole (gap $n/4$).

For a general diagonal form $Q(x) = \sum_i a_i x_i^2$ with $a_i > 0$ the same argument gives a *weighted* Hamming weight: the gap at the class supported on $s$ is $\bigl(\sum_{i \in s} a_i\bigr)/4$, the whole spectrum is $\{(\sum_{i \in s}a_i)/4 : s \neq \emptyset\}$, and its two extremes are exactly the packing invariant $\lambda_1/4 = (\min_i a_i)/4$ and the covering invariant $(\sum_i a_i)/4$. A single formula interpolates between the two classical constants of lattice geometry.

This also settles how far the packing–covering inequality is from an equality. From the Torsion Gap Theorem, the squared covering radius of any positive definite lattice is at least $\lambda_1/4$. For $\mathbb{Z}^n$ it equals $n/4$, so the ratio grows without bound: the half of a shortest vector is a hole, but for $n \geq 2$ it is very far from being the deepest one.

---

### Counting solutions, and a conjecture that was wrong

Finally, not how *small* the values are, but how *many* solutions each value has. Let $r_t(c)$ be the number of lattice points $m$ with $Q(t - m) = c$; the generating function $\sum_c r_t(c)q^c$ is the shifted theta series.

If $2t$ is a lattice vector $v$ and $t$ itself is not, the reflection $m \mapsto v - m$ is an involution of $\mathbb{Z}^n$ that preserves $Q(t - \cdot)$ and has **no fixed points** (a fixed point would force $t = v/2$ to be a lattice point). Pairing solutions off:

> **Even Multiplicity Theorem.** If $2t \in \mathbb{Z}^n$ and $t \notin \mathbb{Z}^n$, then every coefficient $r_t(c)$ of the shifted theta series is even.

It is tempting to conjecture the converse: all coefficients even should force $2t$ into the lattice. In rank one this is a theorem — if $2t \notin \mathbb{Z}$, then $(t-m)^2 = (t-m')^2$ with $m \neq m'$ would force $m + m' = 2t$, so every value has exactly one solution and the coefficient at $c = t^2$ is $1$.

In rank two the conjecture is **false**. Take $t = (\tfrac12, \tfrac13)$ in $\mathbb{Z}^2$. Then $2t = (1, \tfrac23) \notin \mathbb{Z}^2$, yet the *partial* reflection $(m_1, m_2) \mapsto (1 - m_1, m_2)$ is a fixed-point-free involution preserving $(m_1 - \tfrac12)^2 + (m_2 - \tfrac13)^2$. Every coefficient is even. The theta series factors over the coordinates, $\theta_t = \prod_i \theta_{t_i}$, and a single even factor annihilates the whole product modulo $2$.

The corrected statement is coordinatewise, and it is exact for every positive diagonal form:

> **Parity Criterion.** For $Q(x) = \sum a_i x_i^2$ with $a_i > 0$, all coefficients of the shifted theta series at $t$ are even **if and only if** some single coordinate $t_i$ is half-integral, i.e. $t_i \in \mathbb{Z} + \tfrac12$.

Sufficiency is the partial flip above. Necessity is a *minimal shell* count: if no coordinate is half-integral then rounding each $t_i$ to its nearest integer produces the *unique* nearest lattice point, so the bottom coefficient is $1$ — odd. And a shadow of this survives for an arbitrary form: if the bottom coefficient is even, the nearest lattice point to $t$ cannot be unique.

---

### What the picture looks like from above

Start with a naive-sounding question — when does a shifted quadratic equation have no integer solutions? — and three independent structures fall out.

**An archimedean one.** Distance to the lattice at an $r$-torsion point is at least $\lambda_1/r^2$, with equality precisely at halves (or $r$-ths) of shortest vectors. This turns "complete the square and use positivity" into a strictly sharper unsolvability test, improved by exactly the gap.

**A $2$-adic one.** At the half of a characteristic vector, all attained values are congruent modulo $2$ after subtracting $Q(v)/4$ — and being characteristic is *equivalent* to that congruence, not merely sufficient for it. Sums of odd squares modulo $8$ are the special case of the round form.

**A combinatorial one.** On the $2$-torsion targets of a diagonal lattice, the geometric invariant $\mu$ *is* the weighted Hamming weight function of binary coding theory, divided by four, running from the packing constant at weight one to the covering constant at full weight.

Three different kinds of mathematics — metric geometry, congruences, and combinatorics of $\mathbb{F}_2^n$ — describing the same set of near misses. That is what it means for a Diophantine problem to be understood.
