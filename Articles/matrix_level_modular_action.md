# The Shape of Sliding: How a Single $2\times 2$ Matrix Explains Horocycles

## A parking-lot puzzle in the hyperbolic plane

Imagine you are standing in a strange landscape. It looks like the upper half of an ordinary sheet of paper — every point is a pair of coordinates $(x, y)$ with $y > 0$ — but distances behave oddly. Near the bottom edge, where $y$ is tiny, walking one centimetre on paper costs you an enormous amount of effort; high up, where $y$ is large, a centimetre is nearly free. The rule is that the cost of a small step $(dx, dy)$ is $\sqrt{dx^2 + dy^2}\,/\,y$.

This is the **hyperbolic upper half-plane** $\mathbb{H} = \{z \in \mathbb{C} : \operatorname{Im} z > 0\}$, one of the three model geometries of constant curvature and by far the most useful in modern mathematics: it is where modular forms live, where number theory meets dynamics, and where hyperbolic surfaces unfold.

Now ask a very concrete question. Which motions of this landscape are *rigid* — that is, preserve all distances — and, among those, which ones slide every point sideways while keeping it at exactly the same "altitude" $y$?

That is the question this article answers, and the answer is surprisingly rigid, surprisingly clean, and reachable with nothing more than $2 \times 2$ matrices.

## Matrices that move points

The rigid motions of the half-plane are described by matrices. Given a real $2 \times 2$ matrix
$$M = \begin{pmatrix} a & b \\ c & d \end{pmatrix},$$
we let it act on a complex number $z$ by the **Möbius rule**
$$M \cdot z = \frac{az + b}{cz + d}.$$

This is not an arbitrary formula. It is the unique way to get matrices to act on the plane so that *matrix multiplication is composition of motions*: if the denominator is nonzero,
$$(MN)\cdot z = M\cdot(N\cdot z).$$
So the algebra of matrices literally *is* the algebra of motions.

The formula also comes with a single, decisive computational identity. A direct computation shows that for real $a,b,c,d$,
$$\operatorname{Im}\!\left(\frac{az+b}{cz+d}\right) = \frac{(ad - bc)\,\operatorname{Im} z}{|cz + d|^2}.$$
Read this slowly, because everything below flows from it. The altitude of the image point equals the altitude of the original point, multiplied by $\det M$ and divided by $|cz+d|^2$. If $\det M = 1$ and $z$ is in the upper half-plane, the right-hand side is positive: the motion maps the half-plane to itself. That is why determinant-one matrices — the group $\mathrm{SL}_2(\mathbb{R})$ — are the natural symmetry group here.

## Sliding sideways: the translations

The simplest symmetry of the half-plane is horizontal sliding, $z \mapsto z + t$. As a matrix it is
$$T(t) = \begin{pmatrix} 1 & t \\ 0 & 1 \end{pmatrix},$$
since $\frac{1\cdot z + t}{0 \cdot z + 1} = z + t$. These matrices form a perfect copy of the additive real line inside the symmetry group:
$$T(s)\,T(t) = T(s+t), \qquad T(0) = I, \qquad T(t)^n = T(nt),$$
and $T(s) = T(t)$ forces $s = t$. So the translations are a *faithful one-parameter group*: a straight line of symmetries.

Two numbers attached to $T(t)$ deserve attention: $\det T(t) = 1$ and $\operatorname{tr} T(t) = 2$. Combined, they satisfy the **parabolic trace condition**
$$(\operatorname{tr} M)^2 = 4 \det M.$$

The quantity $(\operatorname{tr} M)^2 - 4\det M$ is the discriminant of the characteristic polynomial of $M$; it is the same discriminant that decides whether a quadratic has two real roots, one repeated root, or a complex-conjugate pair. And the roots of that polynomial control the *fixed points* of the motion. So the discriminant sorts every symmetry of the hyperbolic plane into exactly three species:

- **hyperbolic** ($\text{disc} > 0$): two fixed points on the boundary — the motion translates along a geodesic, like a river flowing between two banks;
- **parabolic** ($\text{disc} = 0$): a single fixed point on the boundary — the motion is a shear, an infinitesimal rotation about a point at infinity;
- **elliptic** ($\text{disc} < 0$): a fixed point inside the plane — an honest rotation.

Translations are parabolic. Their single fixed point is the point at infinity, the "cusp" you reach by walking straight up forever.

## Horocycles: the circles centred at infinity

Take a horizontal line $\operatorname{Im} z = c$ in the half-plane. What is it, geometrically? It is not a hyperbolic straight line (those are vertical rays and semicircles meeting the real axis at right angles). It is a **horocycle**: a "circle of infinite radius", the limit of larger and larger hyperbolic circles whose centres run off to the cusp at infinity.

Horocycles are the level sets of the altitude function $\operatorname{Im} z$, and they foliate the half-plane: every point lies on exactly one of them. A horizontal translation slides each horocycle along itself. Does anything *else* do that?

Here is the first main theorem, and it is beautifully sharp.

> **Theorem (Horocycle rigidity).** Let $M$ be a real $2\times2$ matrix with $\det M = 1$. Then $M$ preserves the altitude of every point of the upper half-plane — $\operatorname{Im}(M \cdot z) = \operatorname{Im} z$ for all $z$ with $\operatorname{Im} z > 0$ — **if and only if** $M = \pm T(t)$ for some real $t$.

Nothing else works. The whole three-dimensional group of hyperbolic symmetries collapses, under this one requirement, to a single line of translations (doubled by the harmless sign $\pm$, which acts trivially in the Möbius formula since $M$ and $-M$ give the same motion).

The proof is a small marvel of leverage. Assume $M$ preserves altitude. Apply the imaginary-part law with $\det M = 1$: for every $z$ in the half-plane,
$$\frac{\operatorname{Im} z}{|cz+d|^2} = \operatorname{Im} z, \quad\text{hence}\quad |cz+d|^2 = 1 .$$
Now feed in two purely imaginary test points $z = i$ and $z = 2i$. Since $|c(iy) + d|^2 = d^2 + c^2y^2$, the two conditions read
$$d^2 + c^2 = 1, \qquad d^2 + 4c^2 = 1.$$
Subtracting gives $3c^2 = 0$, so $c = 0$, and then $d^2 = 1$, so $d = \pm 1$. Determinant one now forces $ad = 1$, hence $a = d = \pm 1$, and $M = \pm \begin{pmatrix}1 & \pm b\\ 0 & 1\end{pmatrix}$. Two well-chosen sample points destroy every alternative.

**An immediate corollary:** since $T(t)$ has trace $2$, any determinant-one matrix that preserves all horocycles at infinity satisfies $(\operatorname{tr} M)^2 = 4\det M$. *Horocycle preservation implies parabolicity.*

## The converse fails — and the counterexample is one line

It is tempting to hope for the reverse: "parabolic means horocycle-preserving". It does not.

Consider
$$N = \begin{pmatrix} 1 & 0 \\ 1 & 1 \end{pmatrix}.$$
Its determinant is $1$ and its trace is $2$, so $(\operatorname{tr} N)^2 = 4 = 4\det N$: it is parabolic, by the book. But watch what it does to the point $z = i$, which sits at altitude $1$. Here $c = 1$, $d = 1$, so $|ci + d|^2 = 1 + 1 = 2$, and the imaginary-part law gives
$$\operatorname{Im}(N \cdot i) = \frac{1 \cdot 1}{2} = \frac{1}{2}.$$
The altitude has been halved. $N$ is parabolic, yet it wrecks the horocycle foliation at infinity.

The resolution is that $N$ is parabolic *about a different cusp*: its fixed point is $0$, not $\infty$. It preserves horocycles perfectly well — the ones tangent to the real axis at the origin. So the correct statement needs a guard.

> **Theorem (Guarded converse).** If $\det M = 1$, $(\operatorname{tr} M)^2 = 4\det M$, and additionally $c = 0$ (so that $M$ fixes the cusp $\infty$), then $M$ preserves every horocycle $\operatorname{Im} z = \text{const}$.

Together the two theorems give the exact dictionary:
$$\text{preserves all horocycles at } \infty \iff \text{parabolic } \textbf{and} \text{ fixes } \infty \iff M = \pm T(t),$$
with the counterexample $N$ certifying that the middle clause cannot be weakened.

And nothing is lost, because every parabolic is a translation in disguise:

> **Theorem (Conjugacy classification).** Every real determinant-one matrix with trace $2$ that is not the identity can be written $M = P\,T(s)\,P^{-1}$ for some determinant-one real $P$ and some $s \neq 0$.

The construction is explicit. If $c = 0$ already, $M$ *is* $T(b)$. If $c \neq 0$, the change of basis
$$P = \begin{pmatrix} -(a-1)/c & 1 \\ -1 & 0 \end{pmatrix}, \qquad s = -c$$
does the job. In particular, when $c \neq 0$ the matrix $M$ fixes the real point $x_0 = (a-d)/(2c)$ — a single boundary point, exactly as the parabolic species demands.

## Turning the half-plane into a disc

There is a second model of hyperbolic geometry, and it is the one everyone has seen: Escher's *Circle Limit* prints, with angels and devils shrinking as they crowd toward the rim of a disc. The bridge between the two models is a single fractional-linear map, the **Cayley transform**
$$C(z) = \frac{1 + iz}{1 - iz}.$$

It carries the upper half-plane onto the open unit disc. To see it, put $z = iy$ with $y>0$: then $C(iy) = (1-y)/(1+y)$, a real number strictly between $-1$ and $1$. In general, if $\operatorname{Im} z > 0$ then $|C(z)| < 1$; the boundary of the half-plane, the real line, is carried to the unit circle, and the cusp $\infty$ goes to the boundary point $-1$.

Because Möbius actions compose like matrices, the Cayley transform is itself a matrix:
$$K = \begin{pmatrix} i & 1 \\ -i & 1 \end{pmatrix}, \qquad K\cdot z = \frac{iz+1}{-iz+1} = C(z), \qquad \det K = 2i \neq 0.$$

And now the central algebraic fact of the story, which one verifies by multiplying out two $2 \times 2$ matrices:

> **Theorem (Intertwining identity).** For every real $t$,
> $$K\,T(t) = P(t)\,K, \qquad\text{where}\qquad P(t) = \begin{pmatrix} 1 + \tfrac{it}{2} & \tfrac{it}{2} \\[2pt] -\tfrac{it}{2} & 1 - \tfrac{it}{2}\end{pmatrix}.$$

In words: sliding sideways in the half-plane and then transferring to the disc is *the same motion* as transferring first and then applying $P(t)$. Translated back to points, this says
$$C(z + t) = P(t)\cdot C(z).$$

The disc-side matrices $P(t)$ are as well-behaved as their half-plane counterparts. They satisfy $\det P(t) = 1$, $\operatorname{tr} P(t) = 2$ (so again $(\operatorname{tr})^2 = 4\det$: still parabolic — conjugation cannot change the discriminant), they compose additively $P(s)P(t) = P(s+t)$, and their entries have the symmetric shape
$$\overline{P(t)_{11}} = P(t)_{22}, \qquad \overline{P(t)_{12}} = P(t)_{21},$$
which is exactly the defining condition of the group $\mathrm{SU}(1,1)$ — the disc's version of $\mathrm{SL}_2(\mathbb{R})$. Their single fixed point is $-1$, the image of the cusp: $P(t)\cdot(-1) = -1$, and for $t \neq 0$ there is no other.

## Altitude, translated to the disc

If translations preserve altitude in the half-plane, the matrices $P(t)$ must preserve *something* on the disc. What?

Define the **disc horocycle function**
$$h(w) = \frac{1 - |w|^2}{|w + 1|^2}.$$
The numerator measures how deep $w$ sits inside the disc; the denominator measures how far it is from the special boundary point $-1$. The level sets of $h$ are precisely the circles inside the disc that are tangent to the unit circle at $-1$ — the classic picture of horocycles in Escher's disc.

> **Theorem (Horocycle dictionary).** For every $z$ in the domain of the Cayley transform,
> $$h(C(z)) = \operatorname{Im} z.$$

Not proportional to, not asymptotic to — *exactly equal*. The Cayley transform converts altitude into tangency-depth on the nose. Consequently, the half-plane horocycles $\operatorname{Im} z = c$ correspond one-for-one to the disc horocycles $h(w) = c$, and horocycle rigidity transfers verbatim:

> **Corollary.** $h(P(t) \cdot w) = h(w)$ for every $w$ in the closed unit disc; and $P(t)$ maps the open unit disc to itself.

The proof of the invariance rests on a single algebraic identity that deserves to be highlighted, because it is the engine of the whole disc-side picture. Writing $\nu = \left(1+\tfrac{it}{2}\right)w + \tfrac{it}{2}$ for the numerator and $\delta = -\tfrac{it}{2}w + \left(1 - \tfrac{it}{2}\right)$ for the denominator of $P(t)\cdot w$, one has the twin identities
$$\nu + \delta = w + 1, \qquad |\delta|^2 - |\nu|^2 = 1 - |w|^2 .$$
The first says the "affine sum" is untouched — this handles the denominator of $h$. The second is the $\mathrm{SU}(1,1)$ pseudo-norm invariance — this handles the numerator. Divide one by the other and horocycle invariance falls out; take the second alone and you learn that the open disc is preserved. Two lines of algebra, and the geometry follows.

## The elliptic mirror image

The same machinery, applied to a different family, produces a very different — and equally pretty — picture. Consider the matrices
$$S(a) = \begin{pmatrix} 1 & a \\ -a & 1 \end{pmatrix},$$
whose Möbius action is $z \mapsto \dfrac{z+a}{1-az}$: the "velocity addition" law
$$x \oplus y = \frac{x + y}{1 - xy}$$
familiar from the tangent addition formula, $\tan(\alpha+\beta) = (\tan\alpha + \tan\beta)/(1 - \tan\alpha\tan\beta)$, and from the hyperbolic analogue in special relativity.

Conjugating $S(a)$ by the Cayley matrix gives something startlingly simple:
$$K\,S(a) = R(a)\,K, \qquad R(a) = \begin{pmatrix} 1 + ia & 0 \\ 0 & 1 - ia\end{pmatrix}.$$
$R(a)$ is *diagonal*: its Möbius action is
$$R(a)\cdot w = \frac{1+ia}{1-ia}\, w = C(a)\, w,$$
plain multiplication by a complex number of modulus one. Conjugation preserves both trace and determinant, and indeed $\operatorname{tr} R(a) = \operatorname{tr} S(a) = 2$, $\det R(a) = \det S(a) = 1 + a^2$.

The consequence is a clean linearisation:
> **Theorem.** For all real $x, y$ with $xy \neq 1$,
> $$C(x \oplus y) = C(x)\,C(y).$$

The messy nonlinear addition $\oplus$ becomes ordinary multiplication of unit complex numbers. The Cayley transform is a group isomorphism from the "velocity line" onto the punctured unit circle: it is injective, it never takes the value $-1$, and every unimodular $w \neq -1$ is $C(x)$ for exactly one real $x$, namely $x = \operatorname{Re}\!\big(-i(w-1)/(w+1)\big)$.

Finally, the two families sit on opposite sides of the discriminant:
> **Theorem (Discriminant dichotomy).** $(\operatorname{tr} T(t))^2 - 4\det T(t) = 0$ for all $t$, while $(\operatorname{tr} S(a))^2 - 4\det S(a) = -4a^2 < 0$ whenever $a \neq 0$.

Translations are exactly parabolic; the velocity-addition matrices are strictly elliptic. In the disc, the first family shears every point along circles tangent to the boundary at $-1$, drifting forever toward that one cusp; the second spins the disc rigidly about its centre. Same transform, same two-by-two arithmetic, two utterly different destinies — and the sign of a single number, $(\operatorname{tr})^2 - 4\det$, tells you which one you are in.

## Why this matters

The results above are elementary in the technical sense — they involve no analysis heavier than the modulus of a complex number — but they are the load-bearing beams of a large edifice.

**Modular forms and number theory.** The translations $T(1)$ and their powers generate the periodicity $f(z+1) = f(z)$ built into every modular form's Fourier expansion. Horocycle rigidity is the statement that this periodicity is precisely a *cusp* phenomenon: the subgroup that preserves the altitude foliation is exactly the subgroup that fixes the cusp. The counterexample $N$ is a reminder that "parabolic" is a conjugacy-invariant condition while "preserves the horocycles at $\infty$" is not — the difference between a species and an individual.

**Dynamics.** The horocycle flow — pushing points along the level sets of $h$ — is one of the most studied dynamical systems in mathematics, the setting of Ratner's rigidity theorems and of deep equidistribution results connected to the Riemann zeta function. The dictionary $h(C(z)) = \operatorname{Im} z$ is exactly what lets one run that flow in whichever model is convenient.

**Relativity and hyperbolic trigonometry.** The linearisation $C(x\oplus y) = C(x)C(y)$ is the reason velocity addition, which looks awkward, is really a group law: composing two boosts is composing two rotations of a circle, which is just adding angles.

**Numerical geometry.** The disc model has a bounded picture but awkward formulas; the half-plane has clean formulas but unbounded pictures. The intertwining identity $KT(t) = P(t)K$ makes moving between them a matrix multiplication, with no ambiguity and no case analysis.

There is something satisfying about how little machinery all of this requires. Two test points $i$ and $2i$ pin down horocycle rigidity. Two $2\times2$ products establish the bridge between the disc and the half-plane. Two algebraic identities, $\nu + \delta = w+1$ and $|\delta|^2 - |\nu|^2 = 1 - |w|^2$, carry the invariance across. A single sign, that of $(\operatorname{tr})^2 - 4\det$, decides whether a motion drifts toward a cusp or spins around a centre.

That is the ideal that the hyperbolic plane keeps demonstrating: a geometry rich enough to host tilings, flows, and number theory, and yet transparent enough that the whole of it can be read off from the entries of a $2\times2$ matrix.
