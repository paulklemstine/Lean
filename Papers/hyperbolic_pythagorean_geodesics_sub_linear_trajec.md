# The Tree of Right Triangles, Drawn in Curved Space

*A guided tour. Read straight through for the story; open the folded sections when you want the proofs.*

---

## 1. Start with something you already know

Three whole numbers with $a^2 + b^2 = c^2$. Everyone meets $(3,4,5)$; most people meet $(5,12,13)$; and then the supply seems to run out. It does not. There are infinitely many **primitive** Pythagorean triples — those with $\gcd(a,b,c)=1$ — and they are not scattered at random. They form a perfect ternary family tree.

The rule is due to B. Berggren (1934). Write a triple as a column vector and hit it with any of three fixed integer matrices:

$$B_1 = \begin{pmatrix}1&-2&2\\2&-1&2\\2&-2&3\end{pmatrix},\qquad
B_2 = \begin{pmatrix}1&2&2\\2&1&2\\2&2&3\end{pmatrix},\qquad
B_3 = \begin{pmatrix}-1&2&2\\-2&1&2\\-2&2&3\end{pmatrix}.$$

Each produces another primitive triple. Start at $(3,4,5)$, iterate, and you obtain **every** primitive triple, each exactly once.

<details>
<summary><b>Why does the tree contain everything, exactly once?</b> (click to expand)</summary>

The clean way to see it is to change coordinates. By [Euclid's parametrization](https://en.wikipedia.org/wiki/Pythagorean_triple#Generating_a_triple), every primitive triple is
$$(a,b,c) = (m^2-n^2,\ 2mn,\ m^2+n^2)$$
for a unique **Euclid seed** $(m,n)$: integers with $0<n<m$, $\gcd(m,n)=1$, and $m+n$ odd. In these coordinates the three matrices become three affine maps,
$$B_1(m,n)=(2m-n,\,m),\qquad B_2(m,n)=(2m+n,\,m),\qquad B_3(m,n)=(m+2n,\,n),$$
each of which preserves seedhood (positivity and $n'<m'$ are immediate; parity survives because the coordinate sum changes by an even amount; coprimality survives because any common divisor of $2m\mp n$ and $m$ divides $n$).

Completeness comes from an explicit *inverse*. Given a seed $(M,N)$ other than the root $(2,1)$, look at where the slope $N/M$ sits relative to $1/3$ and $1/2$:

| slope $N/M$ | last move was | parent |
|---|---|---|
| $(0,\tfrac13)$ | $B_3$ | $(M-2N,\ N)$ |
| $(\tfrac13,\tfrac12)$ | $B_2$ | $(N,\ M-2N)$ |
| $(\tfrac12,1)$ | $B_1$ | $(N,\ 2N-M)$ |

The parent map sends seeds to seeds and strictly decreases $M$, so iterating terminates — at the root, since $M=2N$ forces $(2,1)$ by coprimality and $M=3N$ is impossible for a seed. Uniqueness of the depth follows the same way, so the Berggren graph really is a tree and "depth" is a well-defined function.
</details>

Here is the descent algorithm, exactly as described above:

{{algorithm:0}}

---

## 2. Now put the tree somewhere curved

The [Poincaré upper half-plane](https://en.wikipedia.org/wiki/Poincar%C3%A9_half-plane_model) $\mathbb H$ is the set of complex numbers with positive imaginary part, given the metric $ds = |dz|/\operatorname{Im}z$. Distances blow up as you approach the real axis, so the boundary is infinitely far away: this is the standard model of the hyperbolic plane.

Send each seed to
$$z(m,n) \;=\; \frac{n+i}{m} \;=\; \underbrace{\frac{n}{m}}_{\text{shape}} + \; i\,\underbrace{\frac{1}{m}}_{\text{size}},$$
and take $i$ as the origin. Real part = the slope of the triangle; imaginary part = one over the scale.

Now compute the distance from the origin. The half-plane metric gives $\cosh d(z,w) = 1 + |z-w|^2/(2\operatorname{Im}z\operatorname{Im}w)$, and putting $z=i$, $w=(n+i)/m$ produces something that has no business being true:

> **Exact Distance Formula.** $\displaystyle \cosh d_{\mathbb H}\big(i,\,z(m,n)\big) = \frac{m^2+n^2+1}{2m} = \frac{c+1}{2m}$, where $c=m^2+n^2$ is the hypotenuse.

The hypotenuse of the *triangle* appears in the numerator of a hyperbolic cosine of a *distance*. Everything below is downstream of this identity.

**Explore it yourself.** Click any node in the disk below; walk the tree with the branch buttons; watch the numbers.

{{interactive_demo:0}}

Two things to try:
- Press **B₃** repeatedly from the root. The seeds are $(2,1), (4,1), (6,1), (8,1), \ldots$ — slope going to zero, residual going to zero, distance creeping outward like $\log$.
- Press **B₁** repeatedly. The seeds are $(2,1),(3,2),(4,3),(5,4),\ldots$ — the *left spine*. The depth counter climbs, but the distance barely moves. Hold that thought; it is the point of §6.

---

## 3. Everything sits on a logarithmic filament

Because $\cosh d \approx \tfrac12 e^d$ and the seed conditions force $\sqrt{c/2} < m < \sqrt c$, the distance formula immediately pins the radius:

> **Logarithmic Trajectory Theorem.** For every seed,
> $$\tfrac12\log c \;\le\; d_{\mathbb H}\big(i, z(m,n)\big) \;\le\; \tfrac12\log\!\big(2(c+1)\big).$$

The lower bound has **no additive slack at all**; the upper bound exceeds it by less than $\tfrac12\log 2 = 0.34657$ plus $1/(2c)$.

<details>
<summary><b>The two-line proof</b></summary>

Since $\cosh$ increases on $[0,\infty)$, an inequality $d \ge \tfrac12\log c$ is equivalent to $\cosh d \ge \cosh(\tfrac12\log c) = \frac{c+1}{2\sqrt c}$. By the distance formula this says $\frac{c+1}{2m} \ge \frac{c+1}{2\sqrt c}$, i.e. $m \le \sqrt c$ — which is just $m^2 \le m^2+n^2$. For the upper bound, $e^d \le 2\cosh d$ gives $d \le \log\frac{c+1}{m}$, and $n<m$ forces $n^2+1\le m^2$, hence $m^2 \ge (c+1)/2$ and $\frac{c+1}{m} \le \sqrt{2(c+1)}$.
</details>

So a triple with a hundred-digit hypotenuse is only about $115$ units of hyperbolic distance from $(3,4,5)$. Every node, however deep, lives on a thin logarithmic filament.

The left panel below shows the tree in the Poincaré disk with the hyperbolic spheres drawn in; the right panel plots slope against $\log$ of the hypotenuse, which by the theorem is *twice the hyperbolic radius*.

{{visualization:0}}

---

## 4. Reading the shape off the geometry

The interesting quantity is the leftover. Define the **residual**
$$\rho(m,n) \;=\; d_{\mathbb H}\big(i,z(m,n)\big) - \tfrac12\log c \;\in\; \big[0,\ \tfrac12\log 2\big).$$

What is it? Write $t = n/m$ for the slope.

> **Slope Model.** $\rho(m,n) = \tfrac12\log(1+t^2) + \mathrm{gap}$, where the gap is non-negative and
> $$\frac{n^2}{c^2+n^2} \;\le\; \mathrm{gap} \;\le\; \frac{n^2}{c(c-1)}.$$

So the residual is a function of the triangle's **shape alone**, up to an error of size $n^2/c^2$. And $t\mapsto\tfrac12\log(1+t^2)$ maps $(0,1)$ onto $(0,\tfrac12\log 2)$ — the trajectory window is exactly the image of the slope interval, not an artifact of sloppy estimation.

<details>
<summary><b>Where the sharp two-sided bound comes from — an identity, then a factorisation</b></summary>

Set $S = \sqrt{(c+1)^2 - 4m^2}$, which by the distance formula is exactly $2m\sinh d$. Since $\rho - \tfrac12\log(1+t^2) = d + \log m - \log c$ and $e^d = \cosh d + \sinh d = \frac{(c+1)+S}{2m}$, we get an *identity*:
$$\exp(\mathrm{gap}) = \frac{(c+1)+S}{2c}, \qquad\text{so}\qquad \exp(\mathrm{gap}) - 1 = \frac{S-(c-1)}{2c}.$$

That last numerator is a difference of two nearly equal quantities — numerically hopeless, algebraically trivial:
$$\big(S-(c-1)\big)\big(S+(c-1)\big) = S^2 - (c-1)^2 = (c+1)^2 - 4m^2 - (c-1)^2 = 4(c-m^2) = 4n^2.$$
So $S-(c-1) = \dfrac{4n^2}{S+(c-1)}$, a *quotient*, with no cancellation left. Since $c-1 \le S \le c+1$ we get $2(c-1)\le S+(c-1)\le 2c$, and dividing by $2c$ gives the two bounds. They differ by the factor $(c+1)/(c-1)$.
</details>

At the seed $(4,1)$ this bracket reads $0.003448 \le \mathrm{gap} \le 0.003676$, and the truth is $0.0036555\ldots$. The naive $O(1/c)$ estimate would have said only $\le 0.0588$.

{{visualization:1}}

The algorithm that computes all of this, with the certified interval:

{{algorithm:1}}

---

## 5. Which way does each branch push you?

Each Berggren move takes a node to a child. Does the residual rise or fall?

For the slope model this is one line of algebra: $B_1$ sends $t\mapsto 1/(2-t)$, and $1/(2-t)-t = (1-t)^2/(2-t) \ge 0$, so the slope — and hence the residual — rises. $B_3$ sends $t\mapsto t/(1+2t)\le t$, so it falls. And $B_2$ sends $t\mapsto 1/(2+t)$, which is below $t$ exactly when $t^2+2t-1\ge0$, i.e. when

$$t \;\ge\; \sqrt2 - 1 = 0.4142135\ldots$$

But the model is only accurate to $O(n^2/c^2)$, and near the threshold the differences we are comparing are of that same order. Does the monotonicity survive for the **exact** hyperbolic residual? It does, in every single case:

> **Branch Monotonicity.** For every Euclid seed, $\rho(m,n) \le \rho(B_1(m,n))$ and $\rho(B_3(m,n)) \le \rho(m,n)$ — unconditionally, no side hypotheses.
>
> **The $B_2$ Dichotomy.** $\rho(B_2(m,n)) \le \rho(m,n)$ if $m^2 < 2mn+n^2$, and $\rho(m,n) \le \rho(B_2(m,n))$ if $m^2 > 2mn+n^2$. Equality is impossible for a seed. So the exact geometry always agrees with the slope heuristic.

<details>
<summary><b>The proof machine, and where it breaks</b></summary>

Two elementary tools. First, $\log x \ge 1 - 1/x$, which for $A,B>0$ reads $\frac{A-B}{A} \le \log\frac AB$; applied to $A = c\,m'^2$ and $B = m^2c'$ this bounds a slope-model difference *below* by $\frac{A-B}{2A}$. Second, the sharp one-sided sandwich $\rho - \rho_{\mathrm{as}} \le \frac{n^2+1}{c(c+1)}$, which follows from the exact gap identity and one application of $\sqrt{1-x}\le 1-x/2$. Whenever the first beats the second, the exact inequality follows.

In each branch $A - B$ factors beautifully:

| branch | $A - B$ |
|---|---|
| $B_1$ | $-(m-n)^2\,(m^2+2mn-n^2)$ |
| $B_2$ | $\pm(2mn+n^2-m^2)(m+n)^2$ |
| $B_3$ | $4n^3(m+n)$ |

so everything reduces to a polynomial inequality in $m,n$ with $0<n<m$. Substituting $n=a+1$, $m=a+b+2$ (which encodes the constraint exactly) makes the $B_1$ and $B_3$ inequalities **coefficient-positive**, hence guard-free.

For $B_2$ the machine covers $m^2 < 2mn+n^2$ and $m^2 \ge 2mn+n^2+2$, leaving exactly the locus $m^2 = 2mn+n^2+1$, that is
$$(m-n)^2 = 2n^2+1,$$
a [Pell equation](https://en.wikipedia.org/wiki/Pell%27s_equation) with solutions $(5,2), (29,12), (169,70), (985,408), \ldots$ On that locus the certificate collapses to
$$mn\big(28n^4-96n^2-34\big) + \big(12n^6-30n^4-50n^2-8\big) \;\ge\; 0,$$
whose two brackets turn non-negative *exactly* at $n=2$. Over the reals this is **false** — it fails near $(m,n)=(3.8,1.48)$ — so the argument must invoke arithmetic: the Pell equation forces $n\ge2$, because $n=1$ would need $m^2=2m+2$. At $(5,2)$ the two sides are $42250$ and $42630$: a margin of nine parts in a thousand.
</details>

The oracle that predicts all three directions using only integer arithmetic:

{{algorithm:2}}

And a focused numerical study of the threshold and its Pell boundary layer:

{{demo:1}}

Notice, in the widget of §2, that the middle spine $(2,1)\to(5,2)\to(12,5)\to(29,12)\to\cdots$ consists of consecutive [Pell numbers](https://en.wikipedia.org/wiki/Pell_number), and that its *alternate* members $(5,2), (29,12), (169,70)$ are precisely the boundary layer. The delicate case is not an accident of the proof; it is a spine of the tree.

---

## 6. The factoring dream

Here is why one might care beyond aesthetics. Euler's factoring method rests on a classical observation:

> **Euler splitting.** If $N$ is odd and $N = a^2+b^2 = c^2+d^2$ with both representations primitive and $\{a,b\}\ne\{c,d\}$, then
> $$\gcd(N,\,ac+bd)\cdot\gcd(N,\,ad+bc) = N,$$
> with both factors strictly between $1$ and $N$. If $N=pq$ is a semiprime, the two factors are exactly $p$ and $q$.

<details>
<summary><b>Proof sketch</b></summary>

The identity $(ac+bd)(ad+bc) = (a^2+b^2)cd + (c^2+d^2)ab = N(ab+cd)$ shows $N$ divides the product. Writing $g=\gcd(N,ac+bd)$ and $h=\gcd(N,ad+bc)$, a common prime of $g$ and $h$ would divide both the sum and difference $(a\pm b)(c\pm d)$, contradicting primitivity and oddness; hence $\gcd(g,h)=1$, and $gh\mid N$, $N\mid gh$. Non-triviality follows from $0<ac+bd<2N$ with equality to $N$ only when the representations coincide.
</details>

Two *distinct nodes of the Berggren tree with the same hypotenuse* are exactly such a pair. And collisions are common — for every $j$ the seeds $(20j+9,\,10j+2)$ and $(20j+7,\,10j+6)$ share the hypotenuse $500j^2+400j+85$.

Try it — enter any odd number, or generate a random semiprime:

{{interactive_demo:1}}

The plan writes itself. Colliding nodes lie within $2\log 2$ of one another's distance sphere. Every node is only $\tfrac12\log N$ from the origin. Walk out along a short geodesic, find the collision, factor $N$. Path length $O(\log N)$ — sub-linear, wonderful.

---

## 7. Why it cannot work

Count the haystack.

> **Ball Volume Growth.** The number of tree nodes inside the hyperbolic ball of radius $R$ about the origin is between $e^{2R}/300$ and $4e^{2R}$.

<details>
<summary><b>The sieve behind the lower bound</b></summary>

The upper bound is easy: $d\le R$ forces $c\le e^{2R}$, hence $m,n\le e^R$, and the nodes inject into a square lattice box.

The lower bound is the work, because one must exhibit quadratically many *coprime* pairs of opposite parity. Take the box $\{m$ even, $2K<m\le4K\}\times\{n$ odd, $1\le n\le 2K\}$ — $K^2$ pairs, all automatically of opposite parity with $n<m$. A pair is bad if some odd $d\ge3$ divides both; the count of such $m$'s is at most $K/d+1$, likewise for $n$. Summing over odd $d$ and using the telescoping estimates $\sum_{i<n}(2i+3)^{-2}\le\tfrac14$ and $\sum_{i<n}(2i+3)^{-1}\le\sqrt{2n+1}-1$ leaves at least $K^2/4$ good pairs for $K\ge 256$. Every survivor has $\cosh d = \tfrac m2 + \tfrac{n^2+1}{2m} \le 3K + \tfrac1{4K} \le \cosh(\log K+2)$, so all lie in the ball of radius $R = \log K + 2$; and $e^{2R} = e^4K^2 \le 55K^2$.
</details>

Now put the two together. The ball guaranteed to contain a collision for $N$ has radius $R \approx \tfrac12\log N + \log 2$, so it contains $\Theta(e^{2R}) = \Theta(N)$ nodes. **The search region is as large as the number you are trying to factor.** Short geodesics — exponentially many of them.

There is a second, independent obstruction. One might hope the *combinatorial depth* is also $O(\log N)$. It is not: the left spine $(k+2,k+1)$ reaches depth $k$ with hypotenuse only $2k^2+6k+5$, so depth there is $\Theta(\sqrt c)$ while distance is $\Theta(\log c)$. In the other direction depth *does* control distance, since a node at depth $k$ has $m\le 2\cdot3^k$ and hence $2d \le \log 32 + k\log 9$. Distance $\lesssim$ depth, no reverse.

{{visualization:2}}

The one surviving form of "$O(\log N)$": for every target $N$ there *is* a node of hypotenuse $\ge N$ at depth $\lfloor\log_2 N\rfloor$, along the middle spine. **Reaching** size $N$ is logarithmically cheap. **Finding a particular node** of size $N$ is not.

The factoring routine, and the honest complexity accounting:

{{algorithm:3}}

---

## 8. The whole picture at once

Run everything end to end — the conjugation identities, the distance formula, the trajectory law, the residual and its certified gap, the branch dichotomy, the tree structure, the volume growth, and the collision factorisation:

{{demo:0}}

---

## 9. What we are left with

Strip away the failed algorithm and what remains is arguably more interesting than what was sought. A purely combinatorial object — a ternary tree of integer triples — carries a metric geometry in which:

- every node's position is known **exactly**, by a closed formula;
- the radial coordinate is $\tfrac12\log(\text{hypotenuse})$, to within $\tfrac12\log 2$;
- the residual is a function of the triangle's **shape** alone, to within $n^2/c^2$, computable both ways;
- each generator moves you in a determined direction, decided by the single quadratic threshold $\sqrt2-1$;
- the tree is genuinely a tree, with an explicit descent reading the slope against $1/3$ and $1/2$;
- and the node density at radius $R$ is $\Theta(e^{2R})$ — the exact volume growth rate of the hyperbolic plane itself.

That last point deserves the final word. The hyperbolic plane's area grows like $e^{2R}$; that is the defining signature of negative curvature. The Berggren tree, placed inside it, has exactly the same growth rate. Empirically the constant is $\frac{\pi+2}{4\pi^2} = 0.130237\ldots$, which the disc-area heuristic predicts to five digits: the ball condition $d\le R$ is the Euclidean disc $(m-\cosh R)^2+n^2\le\sinh^2R$, whose intersection with the wedge $0<n<m$ has rescaled area $\tfrac\pi4+\tfrac12$, and Euclid seeds have density $4/\pi^2$ among integer pairs. Proving that asymptotic, with an error term, is open.

The tree of Pythagorean triples is not merely embeddable in the hyperbolic plane; it is, in a precise density sense, a uniformly distributed net in it. The arithmetic and the geometry have the same volume.

Which is why no clever walk will save you. You cannot outrun the curvature you are standing in.

---

### Further reading

- [Pythagorean triple](https://en.wikipedia.org/wiki/Pythagorean_triple) — Euclid's parametrization and the tree of primitive triples.
- [Poincaré half-plane model](https://en.wikipedia.org/wiki/Poincar%C3%A9_half-plane_model) — the metric, its geodesics, and the distance formula used throughout.
- [Pell's equation](https://en.wikipedia.org/wiki/Pell%27s_equation) — the source of the boundary layer $(m-n)^2 = 2n^2+1$.
- [Fermat's theorem on sums of two squares](https://en.wikipedia.org/wiki/Fermat%27s_theorem_on_sums_of_two_squares) — which integers carry a node at all.
- [Euler's factorization method](https://en.wikipedia.org/wiki/Euler%27s_factorization_method) — turning two representations into a splitting.
