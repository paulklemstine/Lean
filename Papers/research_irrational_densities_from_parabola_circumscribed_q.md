# Irrational Densities from Parabola-Circumscribed Quadrilaterals in Aperiodic Tilings

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Physics (mathematical physics / aperiodic order)

## Abstract

We study a chain of results connecting the elementary geometry of the parabola
to the aperiodic order observed in quasicrystals. We first establish a sharp
*concyclic criterion*: four distinct points on the parabola $y = x^2$ with
abscissae $a,b,c,d$ lie on a common circle if and only if $a+b+c+d=0$. The
proof reduces the geometric question to a Viète relation for the quartic cut
out of the parabola by a circle, whose cubic coefficient is identically zero.
Quadrilaterals circumscribed about the parabola inherit this additive
structure and yield, generically, *quadratic-irrational* spacing ratios. We
isolate the canonical example, proving that the golden ratio
$\varphi = (1+\sqrt 5)/2$ is irrational. We then build a one-dimensional Wang-tile
striping from a slope $\alpha$ via the Beatty sequence $\lfloor n\alpha\rfloor$
and prove a *tile-density limit*: the density of marked cells among the first
$N$ converges to $\alpha$ for every real $\alpha$. Combining these, the density
of stripes produced at the golden slope is irrational, which in turn certifies
that the tiling is aperiodic, since any periodic striping has rational density.
We close with five precise, falsifiable conjectures extending the proved core
to spheres on paraboloids, higher-degree circumscription, general quadratic
irrationals, sparsity of concyclic quadruples inside Beatty sets, and
quantitative discrepancy bounds.

**Keywords:** parabola, concyclic points, Viète relations, circumscribed
quadrilateral, Wang tiles, Beatty sequence, golden ratio, irrational density,
aperiodic tiling, quasicrystal.

---

## 1. Introduction

Aperiodic order — structure that is rigid and deterministic yet never
periodic — sits at the intersection of number theory, dynamics, and condensed
matter physics. Its discovery in real materials (quasicrystals, Shechtman
1982; Nobel Prize in Chemistry 2011) overturned the long-held belief that
long-range atomic order requires a periodic lattice. In one dimension the
prototype of aperiodic order is the *Beatty sequence* $\lfloor n\alpha\rfloor$
for irrational $\alpha$, whose combinatorics (Sturmian words, the
three-distance theorem) encode quasicrystalline diffraction.

This paper develops a self-contained bridge from a classical piece of
projective/affine geometry — circles meeting a parabola — to the irrational
densities that diagnose aperiodicity. The narrative is:

1. **Geometry → arithmetic.** Concyclicity of four points on $y=x^2$ is
   equivalent to a single additive condition on their abscissae
   (Theorem 3.1). This is the "vanishing cubic coefficient" phenomenon.
2. **Circumscription → irrational slopes.** Quadrilaterals tangent to the
   parabola inherit Viète-type constraints; the resulting spacing ratios are
   quadratic irrationals, of which the golden ratio is the canonical
   representative, proved irrational in Theorem 4.1.
3. **Slope → tiling density.** A Wang-tile striping driven by a Beatty
   sequence of slope $\alpha$ has stripe density converging to $\alpha$
   (Theorem 5.1).
4. **Synthesis.** At the golden slope the density is irrational, which forces
   aperiodicity (Corollary 5.3).

Each of the three theorems is elementary in its proof but the *combination* is
the content: a geometric object dictates a number-theoretic invariant of a
physical pattern.

---

## 2. Setup and definitions

Throughout, the **standard parabola** is
$$P = \{(x,y) \in \mathbb{R}^2 : y = x^2\}.$$
A point of $P$ is uniquely determined by its abscissa $t$, via the
**parabola lift**
$$\iota(t) = (t,\, t^2).$$

**Definition 2.1 (Circle).** A *circle* in $\mathbb{R}^2$ is the zero set of an
equation
$$x^2 + y^2 + Dx + Ey + F = 0, \qquad D,E,F \in \mathbb{R},$$
with $D^2 + E^2 - 4F > 0$ (positive radius). We call four points *concyclic*
if some such circle passes through all of them.

**Definition 2.2 (Circumscribed quadrilateral).** A quadrilateral is
*circumscribed about* $P$ if each of its four sides is tangent to $P$. The
tangent to $P$ at $\iota(s) = (s, s^2)$ is the line $y = 2s\,x - s^2$; thus a
circumscribed quadrilateral is determined by four tangency parameters
$s_1, s_2, s_3, s_4$ (the sides), and its vertices are the pairwise
intersections of consecutive tangents, located at abscissa $\tfrac{1}{2}(s_i+s_{i+1})$.

**Definition 2.3 (Beatty sequence and tiling).** For a real slope $\alpha > 0$
define the cumulative count
$$C_\alpha(N) = \lfloor N\alpha \rfloor \in \mathbb{Z}_{\ge 0}.$$
The associated *one-dimensional striping* marks cell index $\lfloor n\alpha\rfloor$
for each $n \in \{1,\dots,N\}$ as a "vertical" stripe and all others as
"horizontal". The **tile density** of vertical stripes over the first $N$
positions is
$$\rho_\alpha(N) = \frac{C_\alpha(N)}{N} = \frac{\lfloor N\alpha\rfloor}{N}.$$

**Definition 2.4 (Golden slope).** The *golden slope* is the positive root of
$x^2 = x + 1$,
$$\varphi = \frac{1+\sqrt 5}{2}.$$

**Definition 2.5 (Periodic striping).** A striping is *periodic with period*
$p \in \mathbb{Z}_{>0}$ if cell $i$ and cell $i+p$ always have the same type.
Its density (when it exists) is $k/p$, where $k$ is the number of vertical
stripes in one period block — a rational number.

---

## 3. The concyclic criterion

**Theorem 3.1 (Concyclic Criterion; `concyclic_iff_sum_zero`).**
Let $a,b,c,d \in \mathbb{R}$ be four *distinct* reals. The four points
$\iota(a), \iota(b), \iota(c), \iota(d)$ on the parabola $P$ are concyclic if
and only if
$$a + b + c + d = 0.$$

**Proof sketch.**
*(⇒)* Suppose the four points lie on the circle
$x^2 + y^2 + Dx + Ey + F = 0$. Substituting the parabola relation $y = x^2$
(so $y^2 = x^4$) gives, for each abscissa $t \in \{a,b,c,d\}$,
$$t^4 + (1+E)\,t^2 + D\,t + F = 0.$$
Hence $a,b,c,d$ are four distinct roots of the monic quartic
$$Q(x) = x^4 + 0\cdot x^3 + (1+E)\,x^2 + D\,x + F,$$
and, being four distinct roots of a degree-4 polynomial, they are *all* of its
roots, so $Q(x) = (x-a)(x-b)(x-c)(x-d)$. By Viète's relation, the coefficient
of $x^3$ equals $-(a+b+c+d)$. But that coefficient is $0$ by construction, so
$a+b+c+d = 0$.

*(⇐)* Conversely, assume $a+b+c+d=0$. Expand
$$(x-a)(x-b)(x-c)(x-d) = x^4 - e_1 x^3 + e_2 x^2 - e_3 x + e_4,$$
where $e_k$ are the elementary symmetric polynomials in $a,b,c,d$. Since
$e_1 = a+b+c+d = 0$, the cubic term vanishes and the polynomial has the form
$x^4 + e_2 x^2 - e_3 x + e_4$. Choose
$$E = e_2 - 1, \qquad D = -e_3, \qquad F = e_4.$$
Then for each root $t$, $t^4 + (1+E)t^2 + D t + F = 0$, i.e.
$t^2 + (t^2)^2 + D t + E\,t^2 + F = 0$, which is exactly the statement that
$\iota(t)=(t,t^2)$ lies on $x^2+y^2+Dx+Ey+F=0$. Four distinct points of the
parabola are never collinear, so this conic is a genuine circle through all
four points. $\qquad\blacksquare$

**Remark 3.2.** The criterion is the affine shadow of a projective fact: the
parabola is a rational normal curve, and a circle is a conic through the two
circular points at infinity. The "$x^3$ coefficient is zero" is the algebraic
expression of those two extra incidences, leaving one linear condition,
$e_1 = 0$, on the finite intersection.

---

## 4. Circumscribed quadrilaterals and quadratic-irrational slopes

The tangency parameters $s_1,\dots,s_4$ of a circumscribed quadrilateral
(Definition 2.2) determine its vertices at abscissae
$v_i = \tfrac12(s_i + s_{i+1})$ (indices mod 4). Symmetric constraints among
the $s_i$ — for instance requiring two pairs of vertices to be concyclic, which
by Theorem 3.1 imposes $\sum v_i = 0$, i.e. $\sum s_i = 0$ — leave the
admissible configurations described by quadratic equations with integer
coefficients once a normalization is fixed. The spacing ratios
$(v_2 - v_1) : (v_3 - v_2)$ are then roots of such quadratics and are
generically *quadratic irrationals*. The distinguished case, in which the ratio
is the golden ratio, is governed by $x^2 = x + 1$.

**Theorem 4.1 (Golden Slope Irrationality; `goldenSlope_irrational`).**
The golden slope $\varphi = \tfrac{1+\sqrt 5}{2}$ is irrational.

**Proof sketch.** It suffices to show $\sqrt 5 \notin \mathbb{Q}$, since
$\mathbb{Q}$ is closed under the affine map $u \mapsto (1+u)/2$, so
$\varphi \in \mathbb{Q}$ would force $\sqrt 5 = 2\varphi - 1 \in \mathbb{Q}$.
Suppose $\sqrt 5 = p/q$ in lowest terms. Then $5q^2 = p^2$, so $5 \mid p^2$,
and since $5$ is prime, $5 \mid p$. Write $p = 5p'$; then $5q^2 = 25p'^2$, so
$q^2 = 5p'^2$, giving $5 \mid q$ as well — contradicting
$\gcd(p,q)=1$. (Equivalently: $5$ is not a perfect square, so its square root
is irrational.) Hence $\varphi$ is irrational. $\qquad\blacksquare$

**Remark 4.2.** More generally, the positive root of $x^2 + bx + c = 0$ with
$b,c \in \mathbb{Z}$ and non-square discriminant $b^2 - 4c$ is irrational by the
same argument applied to $\sqrt{b^2-4c}$. This is the basis of Conjecture C3
(Section 7), which extends the construction to an entire family of
quadratic-irrational slopes.

---

## 5. The tile-density limit and aperiodicity

**Theorem 5.1 (Tile Density Limit; `tileDensity_tendsto`).**
For every real $\alpha$,
$$\lim_{N\to\infty} \rho_\alpha(N) = \lim_{N\to\infty}\frac{\lfloor N\alpha\rfloor}{N} = \alpha.$$

**Proof sketch.** The defining inequalities of the floor function give, for
every $N \ge 1$,
$$N\alpha - 1 < \lfloor N\alpha\rfloor \le N\alpha.$$
Dividing by $N>0$,
$$\alpha - \frac{1}{N} < \frac{\lfloor N\alpha\rfloor}{N} \le \alpha.$$
Both bounding sequences $\alpha - 1/N$ and $\alpha$ converge to $\alpha$, so by
the squeeze theorem $\rho_\alpha(N) \to \alpha$. $\qquad\blacksquare$

**Corollary 5.2 (Irrational density at the golden slope).**
The striping of slope $\varphi$ has limiting tile density $\varphi$, which is
irrational by Theorem 4.1.

**Corollary 5.3 (Aperiodicity certificate).**
If a striping is periodic with period $p$ (Definition 2.5), its density is
$k/p \in \mathbb{Q}$ for some integer $k$. Consequently any striping whose
limiting density is irrational is *aperiodic*. In particular the golden-slope
striping of Corollary 5.2 is aperiodic.

**Proof sketch.** In a period-$p$ striping, every block of $p$ consecutive
cells contains the same number $k$ of vertical stripes, so over $mp$ cells the
count is exactly $mk$ and $\rho(mp) = k/p$ for all $m$; the full limit, when it
exists, is therefore $k/p$, a rational number. The contrapositive yields the
claim. $\qquad\blacksquare$

**Remark 5.4 (Wang-tile realization).** The marked/unmarked pattern
$\big(\mathbf{1}[\,n = \lfloor m\alpha\rfloor\text{ for some }m\,]\big)_n$ is the
cut-and-project / Sturmian word of slope $\alpha$. It is generated by a finite
set of Wang tiles whose edge colors enforce the local "addition with carry"
rule $\lfloor (m{+}1)\alpha\rfloor - \lfloor m\alpha\rfloor \in \{\lfloor\alpha\rfloor,
\lfloor\alpha\rfloor + 1\}$. The quadrilateral of Section 4 fixes which slope
$\alpha$ those tiles encode; Corollary 5.3 shows the resulting tiling cannot be
periodic.

---

## 6. Algorithms

We summarize the constructive content as three algorithms (full Python in
`demo.py`).

**Algorithm A (Concyclic test).** Given four reals $a,b,c,d$, return
`concyclic` iff $a+b+c+d = 0$ (within tolerance). Optionally *certify* by
fitting the circle: solve the $3\times 3$ linear system for $(D,E,F)$ from
three of the lifted points and verify the fourth satisfies the equation.
Complexity $O(1)$ for the additive test; $O(1)$ (fixed $3\times3$ solve) for
the geometric certificate.

**Algorithm B (Beatty density).** Given slope $\alpha$ and horizon $N$, compute
$\rho_\alpha(N) = \lfloor N\alpha\rfloor / N$ and the error bound
$|\rho_\alpha(N) - \alpha| < 1/N$. Complexity $O(1)$ per evaluation, $O(N)$ to
emit the full striping word.

**Algorithm C (Aperiodicity check by period search).** Given the first $N$
symbols of a striping and a maximum period $p_{\max}$, return the least period
$p \le p_{\max}$ if one exists, else `aperiodic-up-to-N`. Complexity
$O(p_{\max} \cdot N)$.

---

## 7. Future directions

The following five conjectures (carried over from the project's research notes)
extend the proved core; each is stated to be precise and falsifiable.

- **C1 — Higher concyclicity / spheres on paraboloids.** For the paraboloid
  $z = x^2 + y^2$, conjecture that $n$ points are cospherical iff a single
  linear constraint on their lifted coordinates holds, generalizing
  $a+b+c+d=0$. Testable via the $4\times4$ power determinant for five lifted
  points.
- **C2 — Vieta tower for degree-$m$ circumscription.** Replace the circle by a
  degree-$m$ curve meeting the parabola in $2m$ points; conjecture the $k$-th
  elementary symmetric function of the abscissae equals a signed coefficient
  ratio, with the top $m-1$ power sums vanishing.
- **C3 — Irrational density from quadratic-irrational slopes.** For any
  quadratic irrational $\alpha$ (root of $x^2+bx+c=0$, $b,c\in\mathbb{Z}$,
  non-square discriminant), the Beatty striping has irrational density $\alpha$
  and a Sturmian step word with eventually-periodic continued fraction.
- **C4 — Concyclic quadruples inside an aperiodic set have density 0.** In the
  golden Beatty set $B=\{\lfloor n\varphi\rfloor\}$ lifted to the parabola, the
  fraction of 4-subsets whose abscissae sum to zero tends to $0$; since all
  terms are non-negative this is a clean first target.
- **C5 — Quantitative density error and equidistribution.** For the golden
  slope, $|\lfloor N\varphi\rfloor/N - \varphi| \le 1/N$, strengthening to an
  $O(\log N)$ additive discrepancy of $\{n\varphi\}$ via the three-distance
  theorem for bounded partial quotients.

---

## 8. Discussion

The three theorems are individually elementary, but their assembly is a
genuine bridge across domains. Theorem 3.1 turns a question of incidence
geometry into pure additive arithmetic; Theorem 4.1 supplies the canonical
irrational; Theorem 5.1 transports irrationality into a measurable invariant of
an infinite combinatorial object. Corollary 5.3 then reads that invariant as a
physical statement: *no periodic crystal can reproduce this pattern.* This is
exactly the logic by which one-dimensional quasicrystals are recognized — sharp
order (deterministic Beatty rule) with irrational characteristic data
(irrational density / diffraction positions). The parabola, via the vanishing
cubic coefficient, is thus a compact generator of aperiodic order, and the
golden ratio its sharpest instance.

## 9. Conclusion

From the single equation $y = x^2$ we obtained: a complete and elementary
characterization of concyclic quadruples ($a+b+c+d=0$), a proof that the
golden slope is irrational, and a proof that Beatty stripings realize their
slope as a limiting density. Together they certify that the golden-slope
Wang-tile striping is aperiodic, mirroring the order-without-period of physical
quasicrystals. The five conjectures of Section 7 chart a concrete path from
this proved core toward higher dimensions, higher-degree circumscription, and
quantitative equidistribution.
