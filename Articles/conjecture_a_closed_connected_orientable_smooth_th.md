# The Shape of Four Dimensions: Three Conjectures, Three Verdicts

## A tour of the fourth dimension

Four-dimensional geometry is where our intuition goes to fail. In three dimensions we can hold a knot in our hands, spin a torus in our head, and see at a glance that a sphere has no hole. In four, almost every such reflex is wrong. Spheres can be knotted. Objects can be turned inside out. And some perfectly ordinary three-dimensional worlds — closed, smooth, orientable universes — simply *cannot* be fitted inside four-dimensional space at all, no matter how cleverly one folds them.

This article is a report from three small expeditions into that country. Each began with a precise conjecture. One turned out to be true but with the wrong sharpness constant; one turned out to be false, and interestingly so, with the truth being exactly the *opposite* extremal statement; one turned out to have a clean, completely computable algebraic heart. Together they form a lesson about how four-dimensional questions behave: the geometry is hard, but a surprising amount of it collapses, under the right change of variables, into a single algebraic identity in one variable.

---

## Expedition 1: how rigid is a twist?

Start with the most beautiful object in four-dimensional geometry: the **Hopf fibration**.

Take the unit sphere in four-dimensional space. Because four real dimensions are the same as two complex ones, a point of that sphere is a pair of complex numbers $p = (z, w)$ with $|z|^2 + |w|^2 = 1$. Now multiply both coordinates by the same phase, a complex number $u$ of modulus one: $u \cdot (z,w) = (uz, uw)$. As $u$ runs once around the unit circle, the point $p$ traces out a circle inside the three-sphere. These circles — the **Hopf fibres** — fill the three-sphere completely, no two of them meeting, and every pair of them is *linked*, like two rings of a chain that cannot be pulled apart.

The magic is what happens when you collapse each circle to a point. The three-sphere, sliced into circles, becomes an ordinary two-sphere. The recipe is explicit: send
$$p = (z,w) \;\longmapsto\; H(p) = \bigl(2\operatorname{Re}(z\bar w),\; 2\operatorname{Im}(z\bar w),\; |z|^2 - |w|^2\bigr) \in \mathbb{R}^3 ,$$
a point of the unit two-sphere. Two points of the three-sphere have the same image exactly when they differ by a phase, that is, when they lie on the same fibre. That is a **rigidity** statement: the shadow determines the fibre exactly.

Rigidity statements are cheap; *quantitative* rigidity statements are what one actually wants. Suppose two points $p$ and $q$ of the three-sphere have shadows that are merely *close* — say $\|H(p) - H(q)\| \le \varepsilon$. Must $p$ be close to the fibre through $q$? And how close?

The natural guess, and the original conjecture, was a square-root law: there is a universal constant $C$ with
$$\operatorname{dist}(p, \text{fibre of } q) \le C\sqrt{\varepsilon},$$
and the exponent $\tfrac12$ is the best possible. Square roots are what one expects when a map degenerates quadratically, and the Hopf map is built from quadratic expressions, so the guess is a reasonable one.

It is also, it turns out, too pessimistic — and the reason is a single exact identity.

Write $t = |\langle p, q\rangle|$ for the modulus of the Hermitian inner product $\langle p, q \rangle = z\bar z' + w \bar w'$ of the two unit vectors. Two computations, each a polynomial identity in the eight real coordinates, give:

* the squared distance between the shadows is $\;\|H(p)-H(q)\|^2 = 4(1 - t^2)$;
* the squared distance from $p$ to the entire circle through $q$ is $\;m = 2 - 2t$, and this minimum is genuinely attained, at the phase $u = \langle p,q\rangle / |\langle p,q\rangle|$.

Eliminate $t$ between the two, and everything reduces to one line:

> **The Hopf Distance Identity.** For any two unit vectors $p, q$ in $\mathbb{C}^2$, with $D$ the distance between their Hopf shadows and $m$ the squared distance from $p$ to the Hopf fibre through $q$,
> $$D^2 = m\,(4 - m).$$

Nothing more is needed. Since $m$ is a squared distance between points on a unit sphere sharing an ambient origin, it never exceeds $2$; hence $4 - m \ge 2$ and $D^2 \ge 2m$. Taking square roots:

> **Sharp Linear Stability.** If the Hopf shadows of two unit vectors are at distance at most $\varepsilon$, then some phase rotation of the second lies within $\varepsilon/\sqrt2$ of the first. The constant $1/\sqrt2$ cannot be lowered, and the exponent $1$ cannot be raised.

So the conjecture was *true* — a linear bound is stronger than a square-root bound for small $\varepsilon$, so the conjectured $C\sqrt{\varepsilon}$ holds, indeed with $C = 1$ — but its sharpness clause was *false*. Rigidity of Hopf fibres is Lipschitz, not merely Hölder.

Both halves of "sharp" have concrete witnesses. The constant $1/\sqrt2$ is achieved by the pair $p = (1,0)$, $q = (0,1)$: orthogonal vectors, whose shadows are the north and south poles, at distance $2$, while every phase rotation of $q$ stays at distance exactly $\sqrt2$ from $p$. The exponent cannot be improved because of a family of *near*-fibre configurations: taking $q_x = (1-x, \sqrt{1-(1-x)^2})$ against $p = (1,0)$ gives $D^2 = 8x - 4x^2$ and $m = 2x$, so $m/D^2 \to 1/4$ as $x \to 0$. Any claim $m \le C^2 D^{2\alpha}$ with $\alpha > 1$ dies on this family, because $x$ beats $x^{\alpha}$ near zero.

There is a pleasing moral in those two numbers. For nearby points the true ratio $m/D^2$ is $1/4$; only at the antipodal extreme does it rise to $1/2$. The worst case for the constant and the worst case for the exponent live at opposite ends of the sphere.

## The identity was never about dimension four

Look again at the derivation: the coordinates never appeared. Everything came from the Hermitian inner product and the single scalar $t = |\langle p, q\rangle|$. So the whole story lifts, verbatim, to the unit sphere of *any* complex inner product space.

Define, for unit vectors $p$ and $q$,
$$d_{\mathrm{ph}}(p,q) = \sqrt{2 - 2|\langle p, q\rangle|}.$$
Then $d_{\mathrm{ph}}(p,q)$ is exactly $\min_{|u| = 1}\|p - u q\|$ — the minimum is attained, and no phase does better. This quantity is a genuine metric: it is symmetric, non-negative, vanishes precisely when $p$ and $q$ lie on the same circle orbit, and satisfies the triangle inequality, proved by the elegant device of composing optimal phases (if $u$ is optimal for $(p,q)$ and $v$ for $(q,r)$, then $uv$ is an admissible competitor for $(p,r)$). In other words, it is the natural distance on complex projective space — the space of complex *lines* — measured as a chord rather than along a great circle.

And the identity survives intact: with $m = d_{\mathrm{ph}}(p,q)^2$,
$$m\,(4 - m) = 2\bigl(2 - 2|\langle p, q\rangle|^2\bigr),$$
whose right-hand side is the squared chordal distance between the two lines. Hence the same sharp conclusion: *if two complex lines are within $\varepsilon$ of each other, representatives can be aligned to within $\varepsilon/\sqrt2$.* The Hopf picture in dimension four was only the two-dimensional shadow of a dimension-free fact about the Cauchy–Schwarz defect of a Hermitian form.

---

## Expedition 2: the torus that maximizes

Inside the three-sphere sits a famous surface: the **Clifford torus**, the set of points with $|z| = |w| = 1/\sqrt2$. It is flat, it is minimal, it divides the three-sphere into two congruent solid doughnuts, and it is the preimage under the Hopf map of the equator of the two-sphere. It is the standard example of everything.

It also has a reputation for being extremal, and the conjecture under test made that reputation precise: among tori in the three-sphere invariant under the diagonal circle action and separating the two coordinate circles, the Clifford torus should *uniquely minimize area*.

The natural test family is transparent. For $0 < r < 1$ put
$$T_r = \{(z,w) : |z| = r,\; |w| = \sqrt{1-r^2}\},$$
a flat torus, invariant under the diagonal phase action, and separating the coordinate circle $\{|z|=1\}$ from the coordinate circle $\{|w|=1\}$ (the first has $|z| = 1 > r$, the second $|z| = 0 < r$). The Clifford torus is the member $r = \sqrt2/2$.

Compute the area honestly, from the parametrization $(s,t)\mapsto (re^{is}, \sqrt{1-r^2}\,e^{it})$. Its two tangent directions are orthogonal, of lengths $r$ and $\sqrt{1-r^2}$; the first fundamental form is $E = r^2$, $F = 0$, $G = 1-r^2$; and integrating $\sqrt{EG - F^2}$ over the square $[0,2\pi]^2$ gives

> **Area Formula.** $\operatorname{Area}(T_r) = 4\pi^2\, r\sqrt{1-r^2}$.

Now everything is a one-variable exercise, and the verdict is immediate. By the arithmetic–geometric mean inequality, $r\sqrt{1-r^2} \le \tfrac12$, with equality exactly at $r^2 = \tfrac12$. So the Clifford torus has area $2\pi^2$ and is the **unique maximizer** in the family. Meanwhile, thin tori are arbitrarily short: as $r \to 0$ the area tends to $0$, so the infimum over the family is zero and no minimizer exists at all. Concretely, $r = 0.5$ gives area $\approx 17.09$, $r = 0.1$ gives $\approx 3.93$, and $r = 0.01$ gives $\approx 0.39$ — against the Clifford value $2\pi^2 \approx 19.74$.

> **Refutation.** The Clifford torus does not minimize area among Hopf-invariant tori separating the coordinate circles; it uniquely maximizes it, and the minimization problem has no solution.

What, then, is true? Differentiating the reduced functional gives
$$\frac{d}{dr}\operatorname{Area}(T_r) = 4\pi^2\,\frac{1 - 2r^2}{\sqrt{1-r^2}},$$
which vanishes exactly at $r = \sqrt2/2$. So the Clifford parameter is the unique *critical point* of area in the family — criticality is the correct variational property, and it is precisely the statement that the Clifford torus is a minimal surface. The celebrated extremality results for the Clifford torus are all *constrained*: minimal among minimal tori, or minimal for the Willmore energy. Strip the constraint away and the extremum flips sign. This is a healthy reminder that "the Clifford torus is extremal" is a sentence that means nothing until the variational class is named.

---

## Expedition 3: which three-dimensional worlds fit inside four?

The third expedition tackles the deepest of the three questions. A closed, connected, orientable three-manifold is a compact three-dimensional universe without boundary. Which ones can be placed, smoothly and without self-intersection, inside the four-sphere?

Not all of them: the three-dimensional projective space cannot, and neither can most lens spaces. Understanding exactly which do is a famous open problem. The conjecture under test proposes the right shape for an answer: an embedded three-manifold $Y \subset S^4$ splits the four-sphere into two compact pieces $X_1$ and $X_2$ glued along $Y$, and the correct criterion should couple the intersection pairings of the two pieces with the linking form of $Y$, rather than testing them separately.

One half of that package is purely algebraic, and is entirely provable. Classically, an embedding forces the **linking form** of $Y$ — a symmetric pairing $\ell$ on the torsion of the first homology, valued in $\mathbb{Q}/\mathbb{Z}$ — to be *metabolic*: there must exist a subgroup $H$ equal to its own annihilator, $H = H^{\perp}$. Such an $H$ is called a metabolizer, and it is the algebraic shadow of "half the homology dies in $X_1$".

For lens spaces this becomes completely computable. The lens space $L(n,q)$ has first homology $\mathbb{Z}/n$, and its linking form is the cyclic form
$$\ell_{n,q}(x, y) = \frac{q\,x\,y}{n} \bmod 1, \qquad \gcd(q,n) = 1.$$
The subgroups of $\mathbb{Z}/n$ are the divisor subgroups $H_d = \langle d\rangle$, one for each $d \mid n$. A short computation, using only that $q$ is invertible modulo $n$, shows that the annihilator of $H_d$ is $H_{n/d}$: the linking form pairs a subgroup with its complementary divisor. Therefore $H_d$ is a metabolizer exactly when $d = n/d$, that is when $n = d^2$. Since every subgroup is of this form, the criterion is complete:

> **Metabolizer Criterion.** For $\gcd(q,n) = 1$, the cyclic linking form $\ell_{n,q}$ admits a metabolizer if and only if $n$ is a perfect square.

Note what has vanished: the second lens parameter $q$. The finer arithmetic of the lens space is invisible to this test; the linking form sees only the order of the homology, and only up to squares.

The consequences are immediate and concrete. Since $3$ is not a perfect square, no metabolizer exists for $L(3,q)$, and therefore $L(3,q)$ — the quotient of the three-sphere by a free action of $\mathbb{Z}/3$ — does not embed smoothly in the four-sphere, for any $q$. The same argument disposes of $L(6,q)$, $L(5,q)$, $L(7,q)$, $L(8,q)$, and every lens space whose homology has non-square order. On the other hand $L(4,q)$ *passes* the test, with metabolizer $H_2$; and $L(9,q)$ passes with $H_3$. So the obstruction is real but incomplete — exactly the sort of thing that shows why the conjecture insists on *coupling* the linking form with the intersection pairings.

There is a companion criterion, a classical square-order shadow: if $Y$ embeds in the four-sphere, its first homology must split as a direct double $G \oplus G$. A finite abelian group of that shape has order $|G|^2$, a perfect square, so this too rules out $\mathbb{Z}/3$ — and it is genuinely stronger than metabolicity, since $\mathbb{Z}/4$ has square order and a metabolizer, but is not isomorphic to any $G \oplus G$. Two obstructions, one arithmetic in flavour and one structural, agreeing on the easy cases and diverging exactly where the interesting cases live.

---

## What the three expeditions have in common

Three questions about four-dimensional geometry; three answers that came from reducing a geometric problem to one algebraic variable.

For the Hopf fibration, the variable was $t = |\langle p,q\rangle|$, the Cauchy–Schwarz defect of a Hermitian pairing, and the entire quantitative rigidity theory was the identity $D^2 = m(4-m)$. For the Clifford torus, the variable was the radius $r$, and the entire variational problem was the function $4\pi^2 r\sqrt{1-r^2}$ — whose maximum, once written down, made the conjecture's failure obvious. For lens-space embeddings, the variable was a divisor $d$ of $n$, and the entire obstruction was the equation $d = n/d$.

That is the recurring pattern, and it is worth stating as a piece of practical advice: in four-dimensional geometry, before believing an extremality claim or a modulus of continuity, find the symmetry that reduces the problem to one variable, and then simply look at the resulting function. Two of these three conjectures turned out to be wrong in their sharpness clause or wrong outright — and in each case the counterexample was not exotic. It was sitting in plain sight, one line of calculus away.
