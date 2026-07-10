# The General Conic Classification of Morphogenesis: Turing Patterns as Algebraic Varieties

## Abstract

We develop a coordinate-free, algebraic-geometric classification of near-onset
Turing patterns. Reaction–diffusion systems produce spatial patterns whose local
morphology, near the threshold of instability, is governed by a leading quadratic
form $q(x,y) = ax^2 + bxy + cy^2$; the observable morphology is the level set
$\{q = k\}$. We prove that the entire spot/labyrinth dichotomy of morphogenesis is
controlled by a single rotation-invariant quantity, the **discriminant**
$\Delta = b^2 - 4ac$, and that this holds with the cross term $bxy$ present, i.e.
for anisotropic patterns in arbitrary orientation. Specifically: when $a>0$ and
$\Delta < 0$ (positive-definite form) the level set is compact — a *spot* — with an
explicit disc bound of squared radius $4k(a+c)/(4ac-b^2)$; when $a>0$ and
$\Delta > 0$ (indefinite form) the level set is unbounded — a *labyrinth* — and we
exhibit an explicit escaping one-parameter family. We upgrade the bounded (spot)
case to a genuine topological statement — the level set is compact via
Heine–Borel — and deduce that spot and labyrinth level sets, even at equal
thresholds, are never the same subset of the plane. On the mode-counting side we
sharpen the "modes = degree" correspondence into a compositional law: via the
Chebyshev identity $\cos(n\theta) = T_n(\cos\theta)$, a product of an $m$-mode and
an $n$-mode has degree *exactly* $m+n$, and a two-mode superposition with nonzero
top harmonic has degree *exactly* the top mode number. Together these results
recast anisotropic morphogenesis as discriminant geometry with an exact,
additive degree calculus.

**Keywords.** Turing patterns, reaction–diffusion, morphogenesis, conic sections,
discriminant, quadratic forms, positive-definite forms, compactness, Heine–Borel,
Chebyshev polynomials, Fourier modes, algebraic varieties.

---

## 1. Introduction

Alan Turing's 1952 theory of morphogenesis proposed that stable spatial
patterns — spots, stripes, spirals, labyrinths — arise spontaneously in
reaction–diffusion systems through a diffusion-driven instability. The patterns
are solutions to nonlinear partial differential equations of the form
$$\partial_t u = D\,\Delta u + f(u),$$
where $u$ is a vector of morphogen concentrations, $D$ a diagonal matrix of
diffusion coefficients, and $f$ the reaction kinetics. Such equations are
analytically intractable in general, and much of the theory proceeds by linear
stability analysis around a homogeneous steady state followed by numerical
simulation.

This paper pursues a different route. Near the onset of the Turing instability,
the emergent pattern is dominated by a small number of critical Fourier modes, and
its local morphology is captured by a **leading quadratic form**. We show that the
qualitative geometry of the resulting pattern is completely determined by classical
invariants of that form — the discriminant of a conic and the degree of a
polynomial — thereby recasting the morphology problem as a problem in real
algebraic geometry. This translation is exact, coordinate-free, and stable under
the natural operations (multiplication and superposition) by which modes combine.

Our contributions are:

1. A **discriminant dichotomy** for anisotropic (cross-term) quadratic forms:
   positive-definite forms give bounded (spot) level sets with an explicit radius,
   indefinite forms give unbounded (labyrinth) level sets with an explicit escaping
   family (Theorems 3.2 and 4.1).
2. A **topological upgrade**: the spot level set is not merely bounded but
   *compact* (Theorem 3.3), lifting the metric dichotomy to a Heine–Borel
   invariant.
3. A **separation theorem** (Theorem 6.1): spot and labyrinth level sets at the
   same threshold are never equal as subsets of the plane.
4. An **exact compositional degree calculus** for modes: products multiply degree
   (Theorem 5.1) and superpositions are degree-stable (Theorem 5.2).

---

## 2. Definitions and setup

Throughout, coordinates $(x,y)$ range over the real plane $\mathbb{R}^2$, and all
constants are real.

**Definition 2.1 (Leading quadratic form).** A *leading quadratic form* is a
homogeneous degree-two polynomial
$$q(x,y) = a\,x^2 + b\,x\,y + c\,y^2,$$
with real coefficients $a, b, c$. The coefficient $b$ of the cross term $xy$
encodes anisotropy: $b \neq 0$ corresponds to a pattern whose principal axes are
not aligned with the coordinate axes.

**Definition 2.2 (Pattern level set).** For a threshold $k \in \mathbb{R}$, the
*level set* of $q$ at $k$ is
$$V_k(q) = \{(x,y) \in \mathbb{R}^2 : q(x,y) = k\}.$$
This is the morphological trace of the pattern — the locus where the morphogen
concentration equals a fixed value. Geometrically $V_k(q)$ is a conic section.

**Definition 2.3 (Discriminant).** The *discriminant* of $q$ is
$$\Delta = b^2 - 4ac.$$
It is invariant under rotation of the coordinate frame. Its sign classifies the
conic: $\Delta < 0$ (with $a>0$) gives an ellipse, $\Delta > 0$ a hyperbola,
$\Delta = 0$ a parabola/degenerate case.

**Definition 2.4 (Positive-definite / indefinite).** The form $q$ is *positive
definite* if $q(x,y) > 0$ for all $(x,y) \neq (0,0)$; equivalently $a > 0$ and
$\Delta < 0$. It is *indefinite* if it takes both positive and negative values;
for $a>0$ this is equivalent to $\Delta > 0$.

**Definition 2.5 (Spot and labyrinth).** A level set $V_k(q)$ is a **spot** if it
is bounded (contained in some disc), and a **labyrinth** if it is unbounded
(contains points of arbitrarily large norm).

**Definition 2.6 (Fourier mode / Chebyshev encoding).** An *$n$-mode* is the
angular function $\theta \mapsto \cos(n\theta)$. By the classical Chebyshev
identity,
$$\cos(n\theta) = T_n(\cos\theta),$$
where $T_n \in \mathbb{R}[X]$ is the Chebyshev polynomial of the first kind, of
degree exactly $n$. Under the substitution $X = \cos\theta$, every mode is a real
polynomial, and its *mode number* equals its *polynomial degree*.

---

## 3. Positive-definite forms: spots are compact

The spot regime rests on the algebraic fact that a positive-(semi)definite form
never goes negative. The proof is the classical "completing the square."

**Theorem 3.1 (Positive semidefiniteness).** *If $a > 0$ and $b^2 \le 4ac$, then*
$$a\,x^2 + b\,x\,y + c\,y^2 \ge 0 \qquad \text{for all } (x,y).$$

*Proof sketch.* Multiply by $4a > 0$ and complete the square:
$$4a\,q(x,y) = (2ax + by)^2 + (4ac - b^2)\,y^2.$$
Both terms on the right are non-negative (the first is a square, the second is a
non-negative coefficient times a square because $4ac - b^2 \ge 0$). Hence
$4a\,q \ge 0$, and dividing by $4a > 0$ gives $q \ge 0$. $\qquad\blacksquare$

The identity $4a\,q = (2ax+by)^2 + (4ac-b^2)y^2$ is the engine of the whole spot
analysis. It is manifestly independent of any coordinate alignment.

**Theorem 3.2 (Spots are bounded).** *Let $a > 0$ and $b^2 < 4ac$ (positive
definite). Then for every threshold $k$, the level set $V_k(q)$ is contained in the
disc of squared radius*
$$R = \frac{4k(a+c)}{4ac - b^2}.$$
*That is, every $(x,y)$ with $q(x,y) = k$ satisfies $x^2 + y^2 \le R$.*

*Proof sketch.* Positive definiteness forces $c > 0$ (take $x$ so that the
$x$-terms vanish) and $4ac - b^2 > 0$. Completing the square in two symmetric ways
yields
$$(4ac - b^2)\,y^2 \le 4a\,k, \qquad (4ac - b^2)\,x^2 \le 4c\,k,$$
using $(2ax+by)^2 \ge 0$ and $(bx + 2cy)^2 \ge 0$ respectively. Adding the two
bounds and dividing by $4ac - b^2 > 0$ gives
$x^2 + y^2 \le 4k(a+c)/(4ac-b^2) = R$. $\qquad\blacksquare$

This is the anisotropic generalization of the axis-aligned ellipse bound: the
disc radius is written entirely in terms of $a,b,c,k$, with the cross term $b$
fully present, and is valid for an ellipse in any orientation.

**Theorem 3.3 (Spots are compact).** *Under the same hypotheses ($a>0$,
$b^2 < 4ac$), the level set $V_k(q)$ is a compact subset of $\mathbb{R}^2$.*

*Proof sketch.* The set is **closed** because it is the preimage of the point
$\{k\}$ under the continuous map $(x,y) \mapsto a x^2 + b x y + c y^2$ — a level
set of a continuous function contains all its limit points. It is **bounded** by
Theorem 3.2, contained in the closed ball of radius $\sqrt{R}$ about the origin. By
the Heine–Borel theorem, a subset of $\mathbb{R}^2$ that is both closed and bounded
is compact. $\qquad\blacksquare$

Theorem 3.3 is the qualitative heart of the paper: it promotes the spot property
from a metric statement (boundedness) to a topological invariant (compactness),
unlocking the standard consequences — attainment of extrema, sequential
compactness, and the availability of Morse-theoretic tools on the level set.

---

## 4. Indefinite forms: labyrinths are unbounded

**Theorem 4.1 (Labyrinths are unbounded).** *Let $a > 0$ and $\Delta = b^2 - 4ac
> 0$ (indefinite). Then for every threshold $k$ and every bound $R$, the level set
$V_k(q)$ contains a point $(x,y)$ with $x^2 + y^2 > R$.*

*Proof sketch.* Complete the square in the indefinite direction:
$$4a\,q(x,y) = (2ax + by)^2 - \Delta\,y^2.$$
Fix a large ordinate $y = s$; we solve $q(x,s) = k$ for $x$. The condition becomes
$(2ax + bs)^2 = \Delta s^2 + 4ak =: W$. Choosing
$$s = \sqrt{|R| + \left|\tfrac{4ak}{\Delta}\right| + 1}$$
makes $W > 0$ (since $\Delta > 0$ dominates for large $s$), so we may set
$$x = \frac{\sqrt{W} - b s}{2a},$$
giving a genuine point of $V_k(q)$. By construction $s^2 > R$, hence
$x^2 + y^2 \ge y^2 = s^2 > R$. As $R \to \infty$, these points escape to infinity
along the two arms of the hyperbola. $\qquad\blacksquare$

The witness is fully explicit — a one-parameter family $s \mapsto \big((\sqrt{\Delta
s^2 + 4ak} - bs)/(2a),\, s\big)$ — which is the algebraic signature of a
space-filling labyrinth, valid in any orientation.

---

## 5. Modes and degree: an exact compositional calculus

The Chebyshev encoding of Definition 2.6 turns mode arithmetic into polynomial
arithmetic. We record two exact laws.

**Theorem 5.1 (Products multiply degree).** *For all $m, n \in \mathbb{N}$ there is
a real polynomial $P$ of degree exactly $m+n$ with*
$$P(\cos\theta) = \cos(m\theta)\,\cos(n\theta) \qquad \text{for all } \theta.$$

*Proof sketch.* Take $P = T_m \cdot T_n$, the product of Chebyshev polynomials.
Each $T_j$ is nonzero and has degree exactly $j$ (it takes the value $1$ at
$\theta = 0$, so it cannot be the zero polynomial). Degree is additive under
multiplication of nonzero polynomials, so $\deg(T_m T_n) = m + n$. Evaluating at
$X = \cos\theta$ and using $T_j(\cos\theta) = \cos(j\theta)$ gives the identity.
$\qquad\blacksquare$

Thus mode interference (multiplication) corresponds precisely to degree addition:
a triple wave times a double wave is a quintic, no more and no less.

**Theorem 5.2 (Superposition is degree-stable).** *Let $m < n$ and let $\alpha,
\beta \in \mathbb{R}$ with $\beta \neq 0$. Then there is a real polynomial $P$ of
degree exactly $n$ with*
$$P(\cos\theta) = \alpha\,\cos(m\theta) + \beta\,\cos(n\theta) \qquad \text{for all }
\theta.$$

*Proof sketch.* Take $P = \alpha\,T_m + \beta\,T_n$. The top term $\beta\,T_n$ has
degree exactly $n$ (as $\beta \neq 0$), while $\alpha\,T_m$ has degree at most
$m < n$. When one summand strictly dominates the other in degree, the degree of the
sum equals the larger degree, so $\deg P = n$. The evaluation identity again
follows from $T_j(\cos\theta) = \cos(j\theta)$. $\qquad\blacksquare$

Hence in a superposition the *highest active mode* fixes the algebraic degree,
independently of the lower-mode amplitude $\alpha$. Together, Theorems 5.1 and 5.2
show the "modes = degree" correspondence is a genuine ring-homomorphism phenomenon,
not an artifact of single modes.

---

## 6. Capstone: spots and labyrinths are distinct varieties

**Theorem 6.1 (Discriminant morphological dichotomy).** *Let $q(x,y) = ax^2 + bxy +
cy^2$ be positive definite ($a>0$, $b^2 < 4ac$) and let $q'(x,y) = a'x^2 + b'xy +
c'y^2$ be indefinite ($a'>0$, $b'^2 - 4a'c' > 0$). Then for every threshold $k$,*
$$V_k(q) \neq V_k(q').$$
*A spot level set and a labyrinth level set are never the same subset of the plane.*

*Proof sketch.* By Theorem 3.2 there is a radius bound $R$ with $x^2 + y^2 \le R$
for all points of $V_k(q)$. By Theorem 4.1 the indefinite set $V_k(q')$ contains a
point $q^\star$ with $\|q^\star\|^2 > R$. If the two sets were equal, $q^\star$
would lie in $V_k(q)$ and hence satisfy $\|q^\star\|^2 \le R$, contradicting
$\|q^\star\|^2 > R$. Therefore $V_k(q) \neq V_k(q')$. $\qquad\blacksquare$

The proof is an honest confrontation between boundedness and escape to infinity: no
orientation, rescaling, or choice of threshold can identify a compact spot with an
unbounded labyrinth. The dichotomy is decided entirely by the sign of the
discriminant.

---

## 7. Algorithms

The results above are constructive and translate directly into decision procedures.

**Algorithm A (Discriminant classifier).** *Input:* coefficients $a, b, c$.
*Output:* the morphological type. Compute $\Delta = b^2 - 4ac$. If $a > 0$ and
$\Delta < 0$, return **spot (compact ellipse)** and the disc radius
$\sqrt{4k(a+c)/(4ac-b^2)}$. If $\Delta > 0$, return **labyrinth (unbounded
hyperbola)**. If $\Delta = 0$, return **degenerate (parabolic)**. Complexity:
$O(1)$.

**Algorithm B (Spot radius certificate).** *Input:* positive-definite $a,b,c$ and
threshold $k$. *Output:* an explicit disc containing $V_k(q)$. Return
$R = 4k(a+c)/(4ac - b^2)$; every solution point is certified to satisfy
$x^2 + y^2 \le R$. Complexity: $O(1)$.

**Algorithm C (Labyrinth escape sampler).** *Input:* indefinite $a,b,c$, threshold
$k$, target norm $R$. *Output:* a point on $V_k(q)$ with $x^2 + y^2 > R$. Set
$s = \sqrt{|R| + |4ak/\Delta| + 1}$, $W = \Delta s^2 + 4ak$, $x = (\sqrt{W} -
bs)/(2a)$, $y = s$. Complexity: $O(1)$.

**Algorithm D (Mode–degree calculator).** *Input:* a list of $(\text{mode},
\text{amplitude})$ pairs combined by products and sums. *Output:* the exact
polynomial degree of the resulting pattern, using the rules: product of modes
$m, n \mapsto m+n$; sum of modes with distinct top harmonic $\mapsto \max$ mode.
Complexity: linear in the number of terms.

---

## 8. Applications

- **Automatic morphology classification.** Given a fitted leading form from
  experimental or simulated concentration data, Algorithm A instantly reports
  whether the local pattern is a spot or a labyrinth, robustly to anisotropy and
  orientation.
- **Quantitative spot sizing.** The explicit radius $\sqrt{4k(a+c)/(4ac-b^2)}$
  provides an a priori bound on spot extent as a function of the pattern's
  coefficients and threshold — useful for validating simulations and for
  parameter estimation.
- **Complexity metering.** The exact degree calculus gives a rigorous, additive
  measure of pattern complexity: the polynomial degree counts effective modes and
  composes predictably under interference and superposition.
- **Stability screening.** Because the dichotomy is an open condition on
  $(a,b,c)$ (the strict inequalities $\Delta \lessgtr 0$ are open), a classified
  pattern retains its type under small perturbations, giving a robustness margin.

---

## 9. Discussion

The central methodological claim is that near-onset Turing morphology is
*discriminant geometry*. The discriminant $\Delta = b^2 - 4ac$ is the right
invariant precisely because it is rotation-invariant: none of our proofs assume the
coordinate frame is aligned with the pattern's principal axes, so every statement
survives an arbitrary rotation. This is essential, because physical patterns are
generically anisotropic and carry a nonzero cross term.

The compactness upgrade (Theorem 3.3) is more than aesthetic. Boundedness is a
metric accident; compactness is a topological invariant that brings the full
strength of Heine–Borel — and, downstream, Morse theory and Euler-characteristic
counting — to bear on the level set. This is what makes it plausible that discrete
"spot censuses" are topological quantities rather than numerical artifacts.

On the algebraic side, the exact degree laws (Theorems 5.1 and 5.2) demonstrate
that the mode–degree correspondence is compositional: it respects both the
multiplicative structure (interference) and the additive structure (superposition)
of patterns. This is the feature that lets one bootstrap from single modes to the
genuinely multi-mode patterns of real morphogenesis, and it is the precise input
that curve-counting formulas (Harnack, Plücker) require.

A limitation is that the analysis is *near onset*, where the leading quadratic form
dominates. The full nonlinear pattern involves higher-order corrections; we
conjecture (see below) that the discriminant sign is preserved by weakly nonlinear
saturation, but this is not yet established.

---

## 10. Future directions

**1. The degree–genus law for three-mode flowers.** A generic three-mode planar
pattern should be the real locus of a sextic curve whose smooth complex model has
genus $10$; Harnack's bound then caps the number of compact ovals (visible spots)
at $g + 1 = 11$, with hexagonal spot lattices realizing the extremal Harnack curve.
The insight is that mode count controls not just algebraic degree but the *genus*
of the complexified pattern, so spot combinatorics is governed by the topology of a
Riemann surface. The exact product/superposition degree laws proved here provide
precisely the degree input that Harnack and Plücker formulas need.

**2. Discriminant stability under nonlinear saturation.** For the full nonlinear
pattern near onset, we conjecture the sign of the discriminant of the *linearized*
leading form is preserved by the weakly nonlinear correction: a spot stays compact
and a labyrinth stays unbounded for all amplitudes below a computable saturation
threshold $A_c$. The dichotomy is an *open condition* on the coefficient vector, so
it persists under small deformation — and the amplitude expansion is such a
deformation. Our explicit radius and explicit escaping family are quantitative
enough to survive a controlled perturbation, turning a qualitative dichotomy into
an effective stability theorem.

**3. Compactness $\Rightarrow$ finite spot census.** Whenever the leading form is
positive definite, we conjecture the level set carries a finite, computable Euler
characteristic, with spot count equal to $1 + (\text{number of interior critical
values crossed})$, and the map from coefficient space to spot count is locally
constant away from the discriminant wall $\Delta = 0$. Upgrading boundedness to
compactness makes Morse theory available on the level set, so the discrete spot
census becomes a topological invariant rather than a numerical artifact.

---

## 11. Conclusion

We have shown that the qualitative morphology of near-onset Turing patterns is
governed by classical invariants of algebraic geometry. The sign of the
discriminant $\Delta = b^2 - 4ac$ decides, coordinate-freely, between compact spots
($\Delta < 0$) and unbounded labyrinths ($\Delta > 0$); the spot case is compact
in the full topological sense; the two morphologies are provably distinct as
subsets of the plane; and the number of active modes reads off as an exact
polynomial degree, additive under products and stable under superposition.
Morphogenesis, viewed through this lens, is discriminant geometry with an exact
degree calculus.
