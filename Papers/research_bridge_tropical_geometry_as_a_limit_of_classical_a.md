# Tropical Geometry as a Limit of Classical Algebraic Geometry: Tropicalization, the Corner Locus, and Tropical Bézout

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Novelty (bridge between non-Archimedean algebraic geometry and tropical/min-plus geometry)

---

## Abstract

We develop the bridge connecting classical algebraic geometry over a
non-Archimedean valued field $K$ to tropical geometry over the min-plus
semiring. Working with an additive valuation $v : K \to \mathbb{R} \cup
\{+\infty\}$, we tropicalize a multivariate polynomial $f$ term by term and
attach to it a piecewise-linear, concave function $\mathrm{trop}(f)$ whose
non-smooth seams form the **corner locus** (the tropical hypersurface). Our
central identity is the compatibility of tropicalization with the valuation: the
valuation of a classical monomial term equals its tropicalized value. From it,
together with a sharpened ultrametric "unique minimum wins" lemma, we obtain the
**forward inclusion** $\mathrm{Trop}(V(f)) \subseteq \mathrm{cornerLocus}
(\mathrm{trop}\, f)$ unconditionally, and the full **fundamental theorem of
tropical geometry** (Kapranov, hypersurface case) under an explicit lifting
hypothesis. We then prove a **tropical Bézout theorem** in one variable: a
degree-$d$ tropical polynomial has exactly $d$ roots counted with multiplicity,
where multiplicities are slope drops of a concave broken line, and these roots
are the valuations of the classical roots. We close with the **Maslov
dequantization** picture realizing tropicalization as a zero-temperature limit,
quantitative dequantization rates, and conjectural higher-dimensional Bézout.

---

## 1. Introduction

Tropical geometry replaces the field operations $(+, \times)$ by the min-plus
operations $(\min, +)$, turning algebraic varieties into piecewise-linear
polyhedral complexes. The miracle is that these "shadows" retain a great deal of
the classical geometry: intersection numbers, degrees, genus, and more. The
organizing principle, due to Kapranov, Einsiedler–Kapranov–Lind, and others, is
the **fundamental theorem of tropical geometry**, which identifies the
valuation-image of a classical variety with a purely combinatorial object — the
corner locus of a tropical polynomial.

This paper formalizes the hypersurface case of that bridge and its
one-dimensional Bézout corollary. Our contributions are:

1. A clean min-plus setup over an additive valuation $v : K \to \mathbb{R} \cup
   \{\infty\}$ (Section 2), with tropicalized monomials, the tropical polynomial
   function, and the corner locus defined combinatorially.
2. The **bridge identity** $v(c_a x^a) = \mathrm{tropMonomial}(a)$
   (Theorem 3.1), the compatibility of tropicalization with the valuation.
3. A sharpened ultrametric lemma: a strictly unique smallest term controls the
   valuation of a sum (Theorem 3.2).
4. The **forward inclusion** of the fundamental theorem, proved unconditionally
   (Theorem 4.1), and the **full equality** under a lifting hypothesis
   (Theorem 4.2).
5. **Tropical Bézout** in one variable (Theorem 5.1) with multiplicities as
   slope drops (Theorem 5.2) and the identification of tropical roots with
   valuations of classical roots (Theorem 5.3).
6. The **Maslov dequantization** limit (Section 6) realizing tropicalization as
   $t \to \infty$.

---

## 2. Setup: valued fields, tropicalization, and the corner locus

Throughout, $K$ is a field equipped with an **additive valuation** valued in
$\mathbb{R} \cup \{+\infty\} = \mathbb{R} \cup \{\top\}$, written
$v : K \to \mathbb{R}\cup\{\infty\}$. By definition $v$ satisfies

- $v(0) = +\infty$ and $v(1) = 0$;
- **multiplicativity**: $v(xy) = v(x) + v(y)$;
- the **non-Archimedean (ultrametric) inequality**:
  $\min(v(x), v(y)) \le v(x + y)$.

We use the **min-plus** convention: tropical addition is $\min$, tropical
multiplication is $+$, the tropical zero is $\top = +\infty$, and the tropical
one is $0$.

We work with polynomials $f \in K[x_1, \dots, x_n]$ (formally $f \in
\mathrm{MvPolynomial}(\mathrm{Fin}\,n,\,K)$), each a finite sum
$f = \sum_{a \in \mathrm{supp}(f)} c_a\, x^a$ over exponent vectors
$a = (a_1,\dots,a_n) \in \mathbb{N}^n$, with coefficient $c_a = f.\mathrm{coeff}(a)$
and monomial $x^a = \prod_i x_i^{a_i}$.

**Definition 2.1 (linear form).** For an exponent $a \in \mathbb{N}^n$ and a
tropical point $w \in \mathbb{R}^n$,
$$
\langle a, w\rangle \;=\; \mathrm{linForm}(a, w) \;=\; \sum_{i} a_i\, w_i .
$$

**Definition 2.2 (tropicalized monomial).** For $f$, an exponent $a$, and a
point $w$,
$$
\mathrm{tropMonomial}(f, a, w) \;=\; v(c_a) + \langle a, w\rangle \;\in\;
\mathbb{R}\cup\{\infty\}.
$$
This is the min-plus value $v(c_a) \odot w^{\odot a}$ of the $a$-th term.

**Definition 2.3 (tropical polynomial function).** The tropicalization of $f$,
evaluated at $w$, is the minimum (infimum over the finite support) of the
tropicalized monomials:
$$
\mathrm{tropPolyValue}(f, w) \;=\; \min_{a \in \mathrm{supp}(f)}
\mathrm{tropMonomial}(f, a, w).
$$
As a function of $w$ this is a minimum of finitely many affine functions, hence
**piecewise-linear and concave**.

**Definition 2.4 (corner locus / tropical hypersurface).** A point $w \in
\mathbb{R}^n$ is a **corner point** of $\mathrm{trop}(f)$ if the defining minimum
is attained at (at least) two distinct exponents: there exist $a \ne b$ in
$\mathrm{supp}(f)$ with
$$
\mathrm{tropMonomial}(f,a,w) = \mathrm{tropMonomial}(f,b,w)
= \min_{c \in \mathrm{supp}(f)} \mathrm{tropMonomial}(f,c,w).
$$
The set of all corner points is the **tropical hypersurface**
$\mathrm{cornerLocus}(\mathrm{trop}\,f) = \{ w : \mathrm{IsCornerPoint}(f, w)\}$.

**Definition 2.5 (torus, tropicalization map, $\mathrm{Trop}(V(f))$).** A
classical point $x \in K^n$ lies in the **torus** $(K^\times)^n$ if every
coordinate is nonzero, $\mathrm{InTorus}(x) := \forall i,\, x_i \ne 0$. For such
$x$ each $v(x_i)$ is finite, and the **tropicalization map** is
$$
\mathrm{tropicalize}(x) \;=\; \big(v(x_1), \dots, v(x_n)\big) \in \mathbb{R}^n .
$$
The **classical zero set in the torus** is
$$
\mathrm{classicalZeroSet}(f) = \{ x : \mathrm{InTorus}(x) \wedge f(x) = 0 \},
$$
and its tropical shadow is
$$
\mathrm{Trop}(V(f)) \;=\; \mathrm{tropicalize}\big(\mathrm{classicalZeroSet}(f)\big)
\subseteq \mathbb{R}^n .
$$

**Lemma 2.6 (finiteness on the torus).** If $x \ne 0$ then $v(x) \ne \infty$;
consequently for a torus point $x$ and each $i$, the real number
$\mathrm{tropicalize}(x)_i$ coerces back to the valuation,
$(\mathrm{tropicalize}(x)_i : \mathbb{R}\cup\{\infty\}) = v(x_i)$.
*(In Lean: `valuation_ne_top`, `coe_untop_valuation`.)* This is what lets us pass
freely between $v(x_i) \in \mathbb{R}\cup\{\infty\}$ and the real coordinates of
the tropical point.

---

## 3. The bridge identity and the ultrametric core

### 3.1 Compatibility of tropicalization with the valuation

**Theorem 3.1 (bridge identity, `tropMonomial_eq_valuation_term`).**
For any $f$, any exponent $a$, and any torus point $x$,
$$
v\!\left(c_a \cdot \prod_i x_i^{a_i}\right) \;=\;
\mathrm{tropMonomial}\big(f, a, \mathrm{tropicalize}(x)\big)
\;=\; v(c_a) + \sum_i a_i\, v(x_i).
$$

*Proof sketch.* If $c_a = 0$ both sides are $+\infty$. Otherwise, use Lemma 2.6
to write $v(x_i) = \mathrm{tropicalize}(x)_i$ as a real number. By
multiplicativity of $v$ applied across the finite product (a straightforward
induction over the index set),
$$
v\Big(\prod_i x_i^{a_i}\Big) = \sum_i a_i\, v(x_i).
$$
Multiplying the coefficient back in and using $v(c_a x^a) = v(c_a) +
v(x^a)$ gives $v(c_a) + \sum_i a_i v(x_i)$, which is exactly
$\mathrm{tropMonomial}(f,a,\mathrm{tropicalize}(x))$ after unfolding $\langle a,
\cdot\rangle$ and matching the natural-number scalar multiplication with real
multiplication. $\square$

This identity is the literal bridge: the *classical* valuation of a term equals
its *tropical* value. Everything else is a consequence of it plus the ultrametric
inequality.

### 3.2 The ultrametric "unique minimum wins" lemma

**Theorem 3.2 (`addval_sum_eq_of_unique_min`).** Let $s$ be a finite index set,
$g : s \to K$, and $j \in s$. If $v(g_j) < v(g_i)$ for every $i \in s \setminus
\{j\}$, then
$$
v\!\left(\sum_{i \in s} g_i\right) \;=\; v(g_j).
$$

*Proof sketch.* Strong induction on $|s|$. Split off $g_j$: $\sum_{i} g_i = g_j +
\sum_{i \ne j} g_i$. By the inductive control on the remaining sum, $v(\sum_{i\ne
j} g_i) \ge \min_{i \ne j} v(g_i) > v(g_j)$, where the first step is the
ultrametric inequality applied repeatedly and the second is the strict-minimum
hypothesis. When two summands have distinct valuations, the ultrametric
inequality is an *equality* at the smaller one: $v(a + b) = \min(v(a),v(b))$
whenever $v(a) \ne v(b)$. Applying this to $g_j$ and the tail yields $v(\sum_i
g_i) = v(g_j)$. $\square$

This is the additive-valuation analogue of the classical "domination" principle
$v\big(\sum g_i\big) = \min_i v(g_i)$ when the minimum is uniquely attained — the
*no cancellation* phenomenon that makes non-Archimedean analysis rigid.

---

## 4. The fundamental theorem of tropical geometry (hypersurface case)

### 4.1 Forward inclusion (unconditional)

**Theorem 4.1 (`TropV_subset_tropicalHypersurface`).** For every polynomial $f$,
$$
\mathrm{Trop}(V(f)) \;\subseteq\; \mathrm{cornerLocus}(\mathrm{trop}\,f).
$$
Equivalently: if $x$ is a torus point with $f(x) = 0$, then
$\mathrm{tropicalize}(x)$ is a corner point of $\mathrm{trop}(f)$.

*Proof sketch.* Write $w = \mathrm{tropicalize}(x)$ and let $a^\star \in
\mathrm{supp}(f)$ attain the minimum $\mathrm{tropPolyValue}(f, w) = \min_a
\mathrm{tropMonomial}(f, a, w)$ (the support is finite and nonempty since
$f(x)=0$ presupposes $f \ne 0$ in the nontrivial case). By the bridge identity
(Theorem 3.1), each term's valuation $v(c_a x^a)$ equals
$\mathrm{tropMonomial}(f, a, w)$. Suppose, for contradiction, that the minimum
were attained at the *single* exponent $a^\star$, i.e. $v(c_{a^\star}
x^{a^\star}) < v(c_a x^a)$ for all other $a$ in the support. Then Theorem 3.2
applies to the sum $f(x) = \sum_a c_a x^a$, giving
$$
v(f(x)) = v(c_{a^\star} x^{a^\star}) < \infty,
$$
so $f(x) \ne 0$ — contradicting $f(x) = 0$ (which forces $v(f(x)) = \infty$).
Hence the minimum is attained at two distinct exponents, i.e. $w$ is a corner
point. $\square$

The argument uses *only* multiplicativity, the ultrametric inequality, and the
fact that $v$ detects zero. No algebraic closure, no genericity, no lifting.

### 4.2 The full equality (with lifting)

The reverse inclusion requires lifting a corner of the tropical polynomial back
to an honest classical solution. This is possible over a sufficiently rich valued
field (e.g. algebraically closed with surjective valuation, such as the Puiseux
series field $\mathbb{C}\{\{t\}\}$ or $\mathbb{C}_p$). We encapsulate exactly
what is needed as a hypothesis.

**Lifting hypothesis (H).** For every corner point $w \in
\mathrm{cornerLocus}(\mathrm{trop}\,f)$ there exists a torus point $x$ with
$f(x) = 0$ and $\mathrm{tropicalize}(x) = w$.

**Theorem 4.2 (`kapranov_fundamental_theorem`).** Under hypothesis (H),
$$
\mathrm{Trop}(V(f)) \;=\; \mathrm{cornerLocus}(\mathrm{trop}\,f).
$$

*Proof sketch.* The inclusion $\subseteq$ is Theorem 4.1. The inclusion
$\supseteq$ is exactly hypothesis (H): each corner point is realized as the
tropicalization of a classical solution. $\square$

The content of the genuine Kapranov theorem is precisely the verification of (H);
isolating it as a hypothesis cleanly separates the soft, ultrametric direction
(proved here in full generality) from the hard, field-theoretic direction.

---

## 5. Tropical Bézout in one variable

Specialize to $n = 1$. A degree-$d$ tropical polynomial is a minimum of $d+1$
affine functions with integer slopes $0, 1, \dots, d$:
$$
T(w) \;=\; \min_{0 \le k \le d} \big( c_k + k\, w \big), \qquad w \in \mathbb{R},
$$
where $c_k = v(\text{coefficient of } x^k)$ (with $c_k = +\infty$ for absent
terms; the leading and constant terms are assumed present so the extreme slopes
$d$ and $0$ occur). The graph of $T$ is a **concave** piecewise-linear curve.

**Definition 5.1 (tropical root and multiplicity).** A point $w_0$ is a
**tropical root** of $T$ if it is a corner (the minimum is attained at $\ge 2$
indices). Its **multiplicity** is the *slope drop*
$$
\mathrm{mult}(w_0) \;=\; \mathrm{slope}^-(w_0) - \mathrm{slope}^+(w_0),
$$
the difference between the slope of $T$ just left of $w_0$ and just right of
$w_0$. Concavity guarantees $\mathrm{slope}^-(w_0) \ge \mathrm{slope}^+(w_0)$, so
multiplicities are nonnegative integers.

**Theorem 5.2 (slope drop = multiplicity, `slope_drop_eq_mult`).** At each
tropical root, the local multiplicity defined combinatorially (number of "extra"
indices achieving the minimum, in the sense of how the minimizing index set
jumps) equals the slope drop $\mathrm{slope}^-(w_0) - \mathrm{slope}^+(w_0)$.

*Proof sketch.* For a concave minimum of affine pieces, immediately to the left
of $w_0$ the minimizing line has some slope $k^-$ and to the right slope $k^+$.
Since lines are ordered by slope along a concave lower envelope, the indices
achieving the minimum at $w_0$ are exactly those with slope in $[k^+, k^-]$, and
the drop $k^- - k^+$ counts them with the correct multiplicity. $\square$

**Theorem 5.3 (tropical Bézout, `tropical_bezout`, `tropical_bezout_sum_mult`).**
A degree-$d$ tropical polynomial $T$ has exactly $d$ roots counted with
multiplicity:
$$
\sum_{\text{tropical roots } w_0} \mathrm{mult}(w_0) \;=\; d .
$$

*Proof sketch.* The slope of $T$ as $w \to -\infty$ is $d$ (the steepest line
$c_d + d w$ dominates the minimum for very negative $w$), and as $w \to +\infty$
it is $0$ (the line $c_0$ dominates). The slope is a nonincreasing step function
of $w$ (concavity), changing only at corners, where it decreases by exactly
$\mathrm{mult}(w_0)$ (Theorem 5.2). The total decrease equals the difference of
the asymptotic slopes:
$$
\sum_{w_0} \mathrm{mult}(w_0) = \mathrm{slope}(-\infty) - \mathrm{slope}(+\infty)
= d - 0 = d. \qquad \square
$$
This is a **conservation law**: the degree is a boundary quantity (difference of
asymptotic slopes) fixed by the support alone, requiring no genericity.

**Theorem 5.4 (roots are valuations of classical roots,
`tropPolyValue_linearFactor`).** If $f \in K[x]$ factors over the torus as
$f = c \prod_{j} (x - r_j)$ with $r_j \in K^\times$, then the tropical roots of
$\mathrm{trop}(f)$ are exactly the valuations $v(r_j)$, with multiplicities
matching. In particular the corner locus literally enumerates
$\{v(r_j)\}_j$.

*Proof sketch.* For a single linear factor $x - r$, the tropical polynomial is
$\min(v(1) + w,\ v(r)) = \min(w, v(r))$, whose unique corner is at $w = v(r)$
with slope drop $1 - 0 = 1$. Tropical multiplication of factors corresponds to
adding their tropical polynomials, whose corner sets (with multiplicity) are the
union; hence the tropical roots of $\mathrm{trop}(f)$ are $\{v(r_j)\}$ with the
right multiplicities. This matches Theorem 5.3 since $\deg f = d = $ number of
factors. $\square$

---

## 6. Tropicalization as a limit: Maslov dequantization

The slogan "tropical geometry is a limit of classical geometry" is made precise
by **Maslov dequantization**, a one-parameter family of semirings interpolating
between the classical real semiring and the tropical one.

**Definition 6.1 (dequantized addition).** For $t > 0$ define
$$
x \oplus_t y \;=\; \tfrac{1}{t}\,\log\!\big(e^{tx} + e^{ty}\big).
$$
Tropical multiplication $x \odot y = x + y$ is unchanged.

**Theorem 6.2 (dequantization limit, `tendsto_logAddExp_max`).** For all
$x, y \in \mathbb{R}$,
$$
\lim_{t \to \infty} \big(x \oplus_t y\big) \;=\; \min(-(-x), -(-y))
\;=\; \max(x, y),
$$
and in the min-convention (replacing $x \mapsto -x$) the limit is $\min(x,y)$.

*Proof sketch.* Factor out the dominant exponential: with $M = \max(x,y)$,
$$
x \oplus_t y = M + \tfrac{1}{t}\log\!\big(1 + e^{-t|x - y|}\big),
$$
and the correction term lies in $\big[0, \tfrac{\log 2}{t}\big]$, tending to $0$.
$\square$

**Theorem 6.3 (two-sided sandwich, `logAddExp_lower`, `logAddExp_upper`).** For
all $x, y$ and $t > 0$,
$$
\max(x, y) \;\le\; x \oplus_t y \;\le\; \max(x, y) + \frac{\log 2}{t},
$$
with monotonicity in each argument (`logAddExp_mono_left`).

**Conjecture 6.4 (sharp logarithmic rate).** For $x \ne y$ and $t > 0$,
$$
0 < (x \oplus_t y) - \max(x, y) \le \frac{\log 2}{t},
$$
the bound $\frac{\log 2}{t}$ attained only in the limit $x = y$, and the error is
strictly monotone decreasing in $t$. The overshoot is governed by the single
universal constant $\log 2$, so convergence is a sharp $\Theta(1/t)$ property of
the **semiring deformation**, not of the geometry.

Under this lens, tropicalization $f \mapsto \mathrm{trop}(f)$ is the $t \to
\infty$ (zero-temperature) limit of the classical operations, and the corner
locus is the limiting non-smooth locus of the smooth approximants.

---

## 7. Algorithms

Three computational primitives fall directly out of the theory; see `demo.py`
and the `algorithms` field of the package for full implementations.

1. **Tropical polynomial evaluation.** Given coefficients $c_a$ and a point $w$,
   compute $\min_a (c_a + \langle a, w\rangle)$ and report the minimizing
   index set. Complexity $O(|\mathrm{supp}(f)| \cdot n)$.

2. **Corner detection.** $w$ is a corner iff the minimizing index set has size
   $\ge 2$. Combined with evaluation this decides membership in the tropical
   hypersurface in $O(|\mathrm{supp}(f)| \cdot n)$.

3. **Tropical Bézout root counting (1D).** Sort terms by slope, compute the lower
   envelope of the lines $c_k + k w$, read off the breakpoints (roots) and slope
   drops (multiplicities), and verify the total is $d$. Complexity
   $O(d \log d)$ via an Andrew's-monotone-chain style lower-hull computation.

---

## 8. Applications

- **Enumerative geometry.** Tropical curve counts (Mikhalkin's correspondence
  theorem) compute Gromov–Witten invariants by counting lattice paths and
  balanced graphs — a direct descendant of the corner-locus and Bézout pictures
  developed here.
- **Phylogenetics.** Spaces of evolutionary trees carry a natural tropical
  (min-plus) structure; tropical convexity and tropical linear algebra organize
  distance-based reconstruction.
- **Optimization and operations research.** Min-plus algebra is the algebra of
  shortest paths and scheduling; tropical polynomials model bottleneck and
  critical-path phenomena, and corner loci are decision boundaries.
- **Non-Archimedean / $p$-adic geometry.** Berkovich analytifications retract
  onto tropical skeleta; the forward inclusion proved here is the soft half of
  that retraction.
- **Symbolic computation and elimination.** Because corner loci are defined by
  finitely many linear comparisons, membership and intersection questions reduce
  to linear programming and polyhedral combinatorics, replacing Gröbner-basis
  computations over the base field by exact rational arithmetic on the Newton
  data. This is what makes tropical methods attractive for large, structured
  systems where classical elimination is infeasible.

A recurring theme across these applications is that the *combinatorial* shadow is
not merely a heuristic but a faithful invariant: by Theorem 4.2 the corner locus
remembers the variety up to the information visible to the valuation, and by
Theorem 5.3 it remembers intersection data exactly in the one-dimensional case.
The practical consequence is a transfer principle: prove a statement about the
piecewise-linear shadow — often a finite, decidable computation — and lift it to
a statement about the classical variety.

---

## 9. Discussion and future work

The forward inclusion (Theorem 4.1) is striking in its economy: it needs only
multiplicativity and the ultrametric inequality, and the entire proof reduces to
"a vanishing sum cannot have a unique smallest term." Isolating the lifting
hypothesis (H) cleanly factors the fundamental theorem into a universal soft
direction and a field-dependent hard direction.

Three concrete future directions, building directly on the machinery here:

1. **Quantitative dequantization is exactly logarithmic** (Conjecture 6.4):
   upgrade the two-sided sandwich and monotonicity to a sharp, strictly monotone
   $\Theta(1/t)$ rate governed by $\log 2$.

2. **Tropical Bézout as slope conservation in every dimension.** For a tropical
   polynomial in $n$ variables of degree $d$, the local multiplicities over the
   tropical hypersurface should sum to $d^n$, the classical Bézout number. The
   one-dimensional proof uses asymptotic slope differences with no genericity;
   the same $\inf'/\sup'$ asymptotic machinery should generalize over the
   Newton-polytope support.

3. **Corner locus = non-differentiability set.** For a univariate tropical
   polynomial, a point lies on the tropical hypersurface (minimum attained twice)
   iff $\mathrm{trop}(f)$ fails to be differentiable there, because a concave PL
   function is differentiable exactly where its one-sided slopes agree.

---

## 10. Summary of results

| Result | Statement | Status |
|---|---|---|
| `tropMonomial_eq_valuation_term` | $v(c_a x^a) = \mathrm{tropMonomial}(a, \mathrm{trop}\,x)$ | proved |
| `addval_sum_eq_of_unique_min` | unique smallest term controls $v(\sum)$ | proved |
| `TropV_subset_tropicalHypersurface` | $\mathrm{Trop}(V(f)) \subseteq \mathrm{cornerLocus}$ | proved (unconditional) |
| `kapranov_fundamental_theorem` | $\mathrm{Trop}(V(f)) = \mathrm{cornerLocus}$ | proved (under lifting (H)) |
| `tropical_bezout`, `tropical_bezout_sum_mult` | degree-$d$ poly has $d$ roots w/ mult. | proved |
| `slope_drop_eq_mult` | local multiplicity = slope drop | proved |
| `tropPolyValue_linearFactor` | tropical roots = valuations of classical roots | proved |
| `tendsto_logAddExp_max` | Maslov dequantization limit | proved |

These results jointly realize tropical geometry as a faithful, computable shadow
of classical algebraic geometry over a non-Archimedean field, and as its
zero-temperature limit.
