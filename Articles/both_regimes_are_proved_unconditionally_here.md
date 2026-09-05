# The Curve That Knows What Day It Is

## How a single congruence modulo 12 decides the shape of a whole family of elliptic curves — and why summing over the family sometimes makes the arithmetic vanish entirely

---

### A question with two answers

Take a prime number $p$ — say $13$ — and consider the equation

$$y^2 = x^3 - 3x$$

where $x$ and $y$ are allowed to range only over the $13$ residues $0, 1, 2, \dots, 12$, with all arithmetic done modulo $13$. This is an *elliptic curve over a finite field*: a finite set of points that, remarkably, carries the structure of an abelian group. You can *add* two points on it and get a third. This group law is the engine behind a large share of modern public-key cryptography.

Now ask a very simple question about that group: **how many of its elements are their own negatives?** In group language: how many points $P$ satisfy $P + P = 0$? These are the *2-torsion* points, and they always form a subgroup.

For $p = 13$ the answer is $4$. For $p = 17$ the answer is $2$. For $p = 11$ it is $4$ again; for $p = 19$, back to $2$.

$$13, 11 \longrightarrow 4 \qquad\qquad 17, 19 \longrightarrow 2$$

There is no third possibility, and the pattern is not random. Reduce each prime modulo $12$:

$$13 \equiv 1, \quad 11 \equiv 11, \quad 17 \equiv 5, \quad 19 \equiv 7 \pmod{12}.$$

The primes congruent to $\pm 1$ modulo $12$ give a 2-torsion group of order four. The primes congruent to $5$ or $7$ give order two. Always. Forever. For every prime in the universe other than $2$ and $3$.

This article is about that dichotomy: why it happens, how far it generalises, and — the genuinely surprising part — what happens when you stop looking at one curve at a time and start *adding up* over an entire family of them. Sometimes the arithmetic survives the summation. Sometimes it evaporates completely, and a hard number-theoretic distinction collapses into a soft combinatorial identity. Knowing which is which turns out to be the real content.

---

### Where the number four comes from

The 2-torsion of an elliptic curve is unusually transparent, because you can *see* it.

A curve in the form $y^2 = f(x)$ carries a symmetry: $(x, y) \mapsto (x, -y)$. This map is exactly negation in the group law, and there is one extra point, the "point at infinity" $\mathcal{O}$, which serves as the group's identity element. So a point equals its own negative precisely when $y = -y$, that is, when $y = 0$ (we are in odd characteristic, so $2 \neq 0$ and we may divide by it). The 2-torsion points are therefore:

- the point at infinity $\mathcal{O}$, always present;
- every point $(x, 0)$ where $f(x) = 0$.

So counting 2-torsion is *exactly* counting roots of the cubic $f$. For our family $f(x) = x^3 - cx$ with $c \neq 0$, and this factors immediately:

$$x^3 - cx = x\,(x^2 - c).$$

The root $x = 0$ is always there. The other two roots exist if and only if $c$ has a square root modulo $p$ — and then there are exactly two of them, $\pm s$ with $s^2 = c$, distinct because $s \neq 0$ and $s \neq -s$ in odd characteristic. If $c$ is a *non-square*, the quadratic $x^2 - c$ has no roots at all; in fact it is irreducible, an honest quadratic that only splits after you adjoin $\sqrt{c}$.

This is the whole mechanism, and it gives the dichotomy in one line:

> **Fibre-count theorem.** Let $p$ be an odd prime and $c \neq 0$ in $\mathbb{F}_p$. The 2-torsion subgroup of $E_c : y^2 = x^3 - cx$ over $\mathbb{F}_p$ has order $4$ if $c$ is a square, and order $2$ if $c$ is not.

And in the first case one can say more than "order four". A group of order four in which *every* element satisfies $P + P = 0$ cannot be cyclic — a cyclic group of order four has an element of order four. So it must be the **Klein four-group** $\mathbb{Z}/2 \times \mathbb{Z}/2$, the smallest non-cyclic group, the symmetry group of a rectangle. Its four elements here are

$$\mathcal{O}, \quad (0, 0), \quad (s, 0), \quad (-s, 0).$$

In the non-square case the 2-torsion is just $\{\mathcal{O}, (0,0)\}$, a copy of $\mathbb{Z}/2$.

This is not merely a counting statement; it is a statement about the *shape* of the group, and it has a consequence you get for free. Lagrange's theorem says the order of a subgroup divides the order of the group. So:

> **Divisibility corollary.** For any odd prime $p$ and any $c \neq 0$: the number of points on $E_c$ over $\mathbb{F}_p$ is even. If moreover $c$ is a square modulo $p$, that number is divisible by $4$.

For anyone who has ever chosen an elliptic curve for cryptographic use, this is a familiar and slightly annoying fact: a curve with a lot of small torsion has a point count with small factors, which degrades the security of the discrete logarithm problem on it. The theorem above says exactly which members of this family to avoid — and it says it in terms of a congruence you can check in a fraction of a microsecond.

---

### Enter reciprocity

We have reduced an entirely geometric question — the shape of a torsion subgroup — to an entirely arithmetic one: *is $c$ a square modulo $p$?*

For $c = 3$ this is a question with a beautiful classical answer, supplied by Gauss's law of quadratic reciprocity together with its supplements. The law relates "is $q$ a square mod $p$?" to "is $p$ a square mod $q$?", and running it for $q = 3$ against the behaviour of $p$ modulo $4$ produces a clean verdict:

> **Reciprocity input.** For a prime $p \notin \{2, 3\}$, the number $3$ is a square modulo $p$ if and only if $p \equiv 1$ or $p \equiv 11 \pmod{12}$.

The four odd residue classes coprime to $12$ are $1, 5, 7, 11$. Two of them are split, two are not, in perfect balance — which, via Dirichlet's theorem on primes in arithmetic progressions, means that exactly half of all primes see a Klein four-group in this curve, and half do not.

Nothing here is special to the number $3$. The same argument runs verbatim for any nonzero parameter $a$, giving the *general two-regime law*: the 2-torsion of $y^2 = x^3 - ax$ is Klein four when $a$ is a square mod $p$ and cyclic of order two otherwise. Only the *reciprocity input* changes, and it changes to the classical supplementary laws:

| parameter $a$ | split classes |
|---|---|
| $a = 3$ | $p \equiv 1, 11 \pmod{12}$ |
| $a = 2$ | $p \equiv 1, 7 \pmod{8}$ |
| $a = -1$ | $p \equiv 1 \pmod{4}$ |

The last line is the oldest theorem in the table: $-1$ is a square modulo $p$ exactly when $p \equiv 1 \pmod 4$, which is Fermat's two-squares criterion in disguise.

---

### Twisting, and why it changes nothing

Here is the step that turns a statement about one curve into a statement about a family. For a nonzero $d$, consider the *quadratic twist family*

$$E_d : y^2 = x^3 - a d^2 x, \qquad d \in \mathbb{F}_p^{\times}.$$

These are genuinely different curves — different equations, different point sets, in general different point counts. But watch what happens to the split condition. We must ask whether $a d^2$ is a square. And $a d^2$ is a square if and only if $a$ is: multiply a square root of $a$ by $d$ to get one for $a d^2$, and divide by $d$ to go back. Squareness is blind to multiplication by a square.

So the *entire family* is split, or the entire family is non-split, in lockstep. The twisting parameter $d$ is invisible to the 2-torsion. Geometrically: the field you must adjoin to see all the 2-torsion is $\mathbb{Q}(\sqrt{a}\,)$ for every member of the family, one single quadratic field, independent of $d$.

This makes the summed statement immediate, and worth recording as the flagship:

> **Summed two-regime law.** Let $p$ be an odd prime and $a \neq 0$ in $\mathbb{F}_p$. Then
> $$\sum_{d \in \mathbb{F}_p^\times} \#E_d(\mathbb{F}_p)[2] \;=\; \begin{cases} 4\,(p-1) & \text{if } a \text{ is a square mod } p,\\[2pt] 2\,(p-1) & \text{otherwise.} \end{cases}$$
> In particular for $a = 3$ the sum is $4(p-1)$ when $p \equiv \pm 1 \pmod{12}$ and $2(p-1)$ when $p \equiv 5, 7 \pmod{12}$.

Concretely: at $p = 11$ the sum is $40$; at $p = 13$ it is $48$; at $p = 17$ it drops to $32$ despite $17 > 13$; at $p = 19$ it is $36$; at $p = 23$ it is $88$. The sequence lurches up and down as the primes cycle through the four classes mod $12$.

---

### The twist in the tale: when the arithmetic disappears

Everything so far has the same character: a global arithmetic invariant (a Legendre symbol) controls a local count, and summing over the family just multiplies by $p - 1$. The arithmetic *survives*.

Now run the same experiment one level up, at the prime $3$ instead of $2$, and for a different family — the celebrated $j = 0$ curves

$$C_b : y^2 = x^3 + b, \qquad b \in \mathbb{F}_p^\times.$$

The $x$-coordinates of the 3-torsion points are the roots of the **3-division polynomial**

$$\psi_3(x) = 3x^4 + 12 b x = 3x\,(x^3 + 4b).$$

Its roots are $x = 0$ together with the cube roots of $-4b$. And *now* the count depends violently on $p$ modulo $3$:

- If $p \equiv 2 \pmod 3$, then $\gcd(3, p-1) = 1$, so cubing is a bijection on $\mathbb{F}_p$ and every element has exactly one cube root. Each $C_b$ contributes exactly $\mathbf{2}$ roots.
- If $p \equiv 1 \pmod 3$, then $\mathbb{F}_p$ contains the primitive cube roots of unity, cubing is three-to-one on $\mathbb{F}_p^\times$, and $-4b$ has either $3$ cube roots or none. Individual curves contribute $\mathbf{4}$ or $\mathbf{1}$ — a wild oscillation as $b$ varies.

The individual counts could hardly be less uniform. And yet:

> **Regime-independence of the summed 3-division count.** For every prime $p \neq 2, 3$,
> $$\sum_{b \in \mathbb{F}_p^\times} \#\{x \in \mathbb{F}_p : \psi_3^{(b)}(x) = 0\} \;=\; 2\,(p-1),$$
> *regardless* of the residue of $p$ modulo $3$.

The arithmetic has vanished. Both regimes give the same answer.

Why? Because summation is not an averaging trick here — it is a *change of variables*. Write the total as a count of pairs $(b, x)$ with $b \neq 0$ and $x^3 = -4b$. For each nonzero $x$ there is precisely one such $b$, namely $b = -x^3/4$, and it is automatically nonzero. So the pairs are in bijection with $\mathbb{F}_p^\times$ itself, giving $p - 1$ of them. Add the $p-1$ copies of the ever-present root $x = 0$, one for each $b$, and the total is $2(p-1)$. The map $x \mapsto -x^3/4$ need not be a bijection for this to work — we are *fibering over $x$, not over $b$*, and from that side the count is trivial.

The contrast between the two computations is the real point of this story. Both are "sum over a family of a division-polynomial root count". One of them retains a genuine arithmetic invariant — the quadratic character of the parameter, hence a congruence modulo $12$ or $8$ or $4$. The other is a purely combinatorial identity in disguise, and the apparently deep dependence on $p \bmod 3$ cancels out exactly.

The structural reason is visible in the algebra. In the 2-torsion case, the family parameter $d$ enters the *coefficient* $ad^2$, whose squareness is a twist-invariant; the sum is $(p-1)$ copies of a single arithmetic number. In the 3-torsion case, the parameter $b$ enters as a pure translation of the cube, and the family sweeps out every value of $-4b$ exactly once; the sum sees the *total size of the image counted with multiplicity*, which is $p-1$ no matter how the fibres are distributed. Summing over a family is a lossy operation, and the question of *what it loses* is precisely the question of whether the family acts transitively on the relevant parameter.

---

### What to take away

Three ideas, each simple, together adding up to something with real content.

**First: torsion is visible.** The 2-torsion of a curve $y^2 = f(x)$ is the root set of $f$ plus a point at infinity, so a question about group structure is a question about factoring a cubic. In our family the cubic is $x(x^2 - c)$ and everything reduces to one Legendre symbol.

**Second: reciprocity converts that symbol into a congruence.** Whether $3$ is a square mod $p$ is not something you should have to test prime by prime; Gauss tells you it depends only on $p \bmod 12$. The result is a criterion you can evaluate by glancing at the last digits of $p$ in base $12$ — and, through Lagrange, a guaranteed factor of $4$ in the point count for half of all primes.

**Third: summing over a family can preserve arithmetic or destroy it, and you must check which.** The two-regime law survives summation because the split condition is twist-invariant. The 3-division count does *not* survive: it collapses to a regime-independent $2(p-1)$ because the family parameter sweeps the target set bijectively. A summed count is only as arithmetic as the invariant that the family fails to average away.

That last principle is a guide to where to look next. For higher $n$, the $n$-division polynomial of a curve no longer factors over a single quadratic field; it factors over the $n$-division field, whose Galois group is, for a generic curve, as large as $\mathrm{GL}_2(\mathbb{Z}/n)$ allows. One expects the summed fibre count over a twist family to be a function of the Frobenius conjugacy class of $p$ in that group alone — a genuinely non-abelian refinement of the mod-$12$ dichotomy, with the abelian cases $n = 2$ and $n = 3$ as the two anchors already understood. The mechanism identified here, that the twist parameter acts on the fibres by a bijection of $\mathbb{F}_p^\times$ and therefore only the isomorphism class of the splitting field survives, is exactly what should make such a statement provable.

And in the other direction there is a density question that is now completely isolated from the geometry: since the split condition is *exactly* a quadratic-character condition on the parameter $a$, the density of primes for which the twist family is split is exactly $1/2$, and the error term in that count is controlled by a single Dirichlet $L$-function rather than by anything about elliptic curves. The geometry has been drained out of the problem; what remains is analysis.

An equation, four residue classes, and a group with four elements. The curve really does know what day it is.
