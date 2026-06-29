# The Kakeya Problem in the Finite-Field Model: Bush Counts, Incidences, and Sumset Growth

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty (Discrete geometry / Additive combinatorics)

## Abstract

The Kakeya conjecture asserts that a Besicovitch set in $\mathbb{R}^n$ — a set
containing a unit line segment in every direction — has Hausdorff dimension
$n$. While the conjecture is known in the plane (Davies's theorem, dimension
$2$) and partially in three dimensions (Wolff's bound, dimension $\geq 5/2$),
its general form remains one of the central open problems in harmonic analysis,
deeply entangled with restriction estimates for the Fourier transform and with
additive combinatorics through the Katz–Tao framework. This paper develops, and
states with full mathematical precision, a rigorously verified fragment of the
*finite-field model* of the Kakeya problem, the discrete setting of the
Wolff–Dvir–Katz–Tao program. We work in the plane $F^2$ over a finite field $F$
with $q$ elements and prove three things. First, the **bush** of all $q$ lines
through the origin has exactly $q^2 - q + 1$ points — the discrete analogue of
"a Kakeya set has full dimension." Second, two lines of distinct slope through
the origin meet in exactly one point, the **incidence engine** behind all
Kakeya lower bounds. Third, on the additive-combinatorics side, we prove the
iterated-sumset growth law $|kA| \geq \min(p,\, k(|A|-1)+1)$ for nonempty
$A \subseteq \mathbb{Z}/p$ (with $p$ prime) by induction from Cauchy–Davenport,
together with the saturation corollary that any $A$ with $|A| \geq 2$ generates
the whole group after $k \geq p-1$ additions. We give proof sketches,
algorithmic realizations, numerical evidence, and a discussion of how these
exactly-provable fragments map onto the broader Kakeya program.

## 1. Introduction

### 1.1 The continuous problem

In 1917 Sōichi Kakeya asked for the minimal area of a region in the plane
inside which a unit line segment can be continuously rotated through all
directions. Besicovitch (1928) proved the astonishing answer: the area can be
made arbitrarily small. A **Besicovitch set** (or **Kakeya set**) is a set
$K \subseteq \mathbb{R}^n$ containing a unit segment in every direction; such
sets can have Lebesgue measure zero.

The **Kakeya conjecture** sharpens the question from measure to dimension: every
Besicovitch set in $\mathbb{R}^n$ has Hausdorff dimension $n$. Known cases and
bounds include:

- **$n = 2$ (Davies, 1971):** every Besicovitch set in $\mathbb{R}^2$ has
  Hausdorff dimension exactly $2$.
- **$n = 3$ (Wolff, 1995):** every Besicovitch set in $\mathbb{R}^3$ has
  Hausdorff dimension at least $5/2$.
- **General $n$:** open; the best bounds combine geometric (Wolff hairbrush),
  arithmetic (Katz–Tao), and polynomial methods.

The problem is a hub. Via the **restriction conjecture**, Kakeya controls how
the Fourier transform of a measure supported on a curved surface can
concentrate; via the **Katz–Tao framework**, dimension bounds reduce to
quantitative **sum–difference** estimates in additive combinatorics.

### 1.2 The finite-field model

Because measure and Hausdorff dimension are analytically delicate, Wolff
proposed replacing $\mathbb{R}^n$ by $F^n$ for a finite field $F$ with $q$
elements. A *Kakeya set* in $F^n$ is a set containing a full line in every
direction; "dimension" is replaced by the exponent $\alpha$ in $|K| \gtrsim
q^{\alpha}$. The finite-field Kakeya conjecture — $|K| \gtrsim_n q^n$ — was
proved completely by Dvir (2008) via the polynomial method, and this discrete
model has been a decisive source of ideas for the continuous theory.

This paper isolates the cleanest exactly-provable fragments of the model:
the **through-origin pencil** (the bush) in $F^2$, the one-point incidence
property, and the additive-combinatorial growth law that powers Katz–Tao-style
reductions.

### 1.3 Contributions

1. An exact count of the through-origin bush: $|B| = q^2 - q + 1$
   (Theorem 3.4).
2. The one-point incidence lemma for distinct slopes (Theorem 3.5).
3. The discrete Kakeya lower bound: any through-origin Kakeya set has at least
   $q^2 - q + 1$ points (Theorem 3.6).
4. The iterated-sumset growth law $|kA| \geq \min(p, k(|A|-1)+1)$ in
   $\mathbb{Z}/p$ (Theorem 4.3), with the saturation corollary (Theorem 4.4).

All statements are formalized and machine-checked.

## 2. Preliminaries and Definitions

Throughout, $F$ denotes a finite field with $q = |F|$ elements; recall the
smallest field has $q = 2$. We write $F^2$ for the affine plane, a set of $q^2$
points. For the additive results, $p$ is a prime and $\mathbb{Z}/p$ the cyclic
group of order $p$, which is also the prime field $\mathbb{F}_p$.

**Definition 2.1 (Line through the origin).** For a slope $m \in F$, the line
through the origin of slope $m$ is
$$L_m = \{(x, m \cdot x) : x \in F\} \subseteq F^2.$$
Each $L_m$ has exactly $q$ points (the map $x \mapsto (x, mx)$ is injective),
and $(0,0) \in L_m$ for every $m$.

**Definition 2.2 (Bush).** The bush is the union of all lines through the
origin,
$$B = \bigcup_{m \in F} L_m \subseteq F^2.$$

**Definition 2.3 (Kakeya set, through-origin model).** A set $K \subseteq F^2$
is a *Kakeya set* (in the through-origin model) if it contains a full line of
every slope: $L_m \subseteq K$ for all $m \in F$.

**Definition 2.4 (Sumset and iterated sumset).** For $A, B \subseteq
\mathbb{Z}/p$, the sumset is $A + B = \{a + b : a \in A,\ b \in B\}$. The
iterated sumset $kA$ is defined recursively by
$$0A = \{0\}, \qquad (k+1)A = A + kA,$$
so that $1A = A$ and $kA = \underbrace{A + \cdots + A}_{k}$ for $k \geq 1$.

**Theorem 2.5 (Cauchy–Davenport).** For nonempty $A, B \subseteq \mathbb{Z}/p$
with $p$ prime,
$$|A + B| \geq \min\big(p,\ |A| + |B| - 1\big).$$

This classical result (Cauchy 1813, Davenport 1935) is the only external
ingredient of Section 4; everything else is derived from it.

## 3. The Bush in $F^2$

### 3.1 Set-theoretic characterization

**Theorem 3.1 (Bush characterization).** The bush is exactly the set of points
with nonzero first coordinate, together with the origin:
$$B = \{(a, b) \in F^2 : a \neq 0\} \cup \{(0,0)\}.$$

*Proof sketch.* ($\subseteq$) A point of $B$ has the form $(x, mx)$. If $x = 0$
it equals $(0,0)$; otherwise its first coordinate $x$ is nonzero. ($\supseteq$)
The origin lies on $L_0$. For a point $(a, b)$ with $a \neq 0$, set $m = b/a$,
which is well defined because $F$ is a field; then $b = m a$, so
$(a,b) \in L_m \subseteq B$. The decisive algebraic step is solving $m = b/a$,
which uses the existence of multiplicative inverses (verified by `field_simp` in
the formalization). $\qquad\blacksquare$

### 3.2 The omitted set and its count

**Lemma 3.2 (Bad set count).** The set of off-origin points on the vertical
axis,
$$\mathrm{Bad} = \{(0, b) : b \neq 0\} = \{(a,b) : a = 0 \text{ and } (a,b) \neq (0,0)\},$$
has exactly $q - 1$ points.

*Proof sketch.* The map $b \mapsto (0, b)$ is a bijection from
$(\mathbb{Z}/p)\setminus\{0\}$ — more precisely from $F \setminus \{0\}$, of
size $q - 1$ — onto $\mathrm{Bad}$. Counting the image of an injective map on
$F \setminus \{0\}$ gives $|\mathrm{Bad}| = q - 1$. $\qquad\blacksquare$

**Lemma 3.3 (Complement).** $\mathrm{Bad}$ is exactly the complement of $B$ in
$F^2$: a point fails to lie in the bush iff it lies on the vertical axis away
from the origin. This is the contrapositive packaging of Theorem 3.1.

### 3.3 The bush count

**Theorem 3.4 (Bush count).** $\displaystyle |B| = q^2 - q + 1.$

*Proof sketch.* By Lemma 3.3, $B = F^2 \setminus \mathrm{Bad}$, so
$|B| = |F^2| - |\mathrm{Bad}|$. Since $|F^2| = q^2$ (product of two copies of
$F$) and $|\mathrm{Bad}| = q - 1$ (Lemma 3.2),
$$|B| = q^2 - (q - 1) = q^2 - q + 1.$$
The natural-number arithmetic is exact for all $q \geq 1$; the rearrangement
$q^2 - q + 1 = (q^2 - (q-1))$ is handled with truncated-subtraction care
(`tsub_add_eq_add_tsub`, `card_univ_diff`). $\qquad\blacksquare$

The bush occupies a fraction $\frac{q^2 - q + 1}{q^2} = 1 - \frac1q + \frac1{q^2}$
of the plane, tending to $1$ as $q \to \infty$: the pencil of directions through
a single point already saturates the grid.

### 3.4 Incidences and the lower bound

**Theorem 3.5 (Incidence lemma).** If $m_1 \neq m_2$, then
$$L_{m_1} \cap L_{m_2} = \{(0,0)\}.$$

*Proof sketch.* A common point $(x, y)$ satisfies $y = m_1 x = m_2 x$, hence
$(m_1 - m_2) x = 0$. Since $m_1 - m_2 \neq 0$ and a field has no zero divisors,
$x = 0$, whence $y = 0$. Conversely $(0,0)$ lies on every line. $\qquad
\blacksquare$

**Theorem 3.6 (Kakeya lower bound, through-origin model).** Every Kakeya set
$K \subseteq F^2$ (Definition 2.3) satisfies
$$|K| \geq q^2 - q + 1.$$

*Proof sketch.* Since $L_m \subseteq K$ for all $m$, we have
$B = \bigcup_m L_m \subseteq K$, so $|K| \geq |B| = q^2 - q + 1$ by monotonicity
of cardinality and Theorem 3.4. $\qquad\blacksquare$

This is the discrete shadow of "a Kakeya set has full dimension": forcing a line
in every through-origin direction forces near-total occupancy of the plane. The
incidence lemma (Theorem 3.5) is the reusable engine that, via inclusion–
exclusion, drives sharper bounds over *all* affine directions (see Section 6).

## 4. The Additive Bridge: Sumset Growth in $\mathbb{Z}/p$

The Katz–Tao approach reduces Kakeya dimension bounds to growth estimates for
sumsets. We isolate the exactly-provable engine: iterated Cauchy–Davenport.

### 4.1 Nonemptiness

**Lemma 4.1 (Nonemptiness of iterated sumsets).** If $A \neq \emptyset$ then
$kA \neq \emptyset$ for all $k$.

*Proof sketch.* Induction on $k$: $0A = \{0\} \neq \emptyset$; if $kA$ is
nonempty then $A + kA$ is nonempty as a sumset of nonempty sets. $\qquad
\blacksquare$

### 4.2 The growth law

**Theorem 4.3 (Iterated sumset growth).** For nonempty $A \subseteq
\mathbb{Z}/p$ ($p$ prime) and every $k \geq 0$,
$$|kA| \geq \min\big(p,\ k(|A| - 1) + 1\big).$$

*Proof sketch.* Induction on $k$. For $k = 0$, $|0A| = |\{0\}| = 1 =
\min(p, 1)$. For the step, assume $|kA| \geq \min(p, k(|A|-1)+1)$. Applying
Cauchy–Davenport (Theorem 2.5) to $A + kA$,
$$|(k+1)A| = |A + kA| \geq \min\big(p,\ |A| + |kA| - 1\big).$$
If $|kA| \geq p$ then both sides are capped at $p$. Otherwise substitute the
inductive bound $|kA| \geq k(|A|-1)+1$:
$$|A| + |kA| - 1 \geq |A| + k(|A|-1) + 1 - 1 = (k+1)(|A|-1) + 1,$$
and taking $\min$ with $p$ on both sides preserves the inequality. The bookkeeping
with $\min$ and natural-number subtraction is discharged by case analysis
(`omega`). $\qquad\blacksquare$

**Sharpness.** For the arithmetic progression $A = \{0, 1, \dots, m-1\}$ with
$m = |A|$, one computes $kA = \{0, 1, \dots, k(m-1)\}$, of size exactly
$k(m-1) + 1$ as long as $k(m-1) < p$. Thus the bound is attained, and
arithmetic progressions are the extremal (slowest-growing) seeds. Saturation
occurs at $k = \lceil (p-1)/(|A|-1) \rceil$.

### 4.3 Saturation

**Theorem 4.4 (Saturation / generation).** If $|A| \geq 2$, then $kA =
\mathbb{Z}/p$ for all $k \geq p - 1$.

*Proof sketch.* With $|A| \geq 2$ we have $|A| - 1 \geq 1$, so for $k \geq p-1$,
$$k(|A|-1) + 1 \geq (p-1)\cdot 1 + 1 = p.$$
Then Theorem 4.3 gives $|kA| \geq \min(p, p) = p = |\mathbb{Z}/p|$, and a subset
of $\mathbb{Z}/p$ with $p$ elements is the whole group. $\qquad\blacksquare$

**Non-vacuity.** The hypothesis $|A| \geq 2$ is essential. For a singleton
$A = \{a\}$, $kA = \{ka\}$ remains a single point forever; the formula correctly
predicts $\min(p, k\cdot 0 + 1) = 1$. The proof uses genuine induction and
Cauchy–Davenport, not exhaustive decision.

This is the additive analogue of the geometric saturation in Section 3: just as
the bush of directions floods the plane, two additive seeds flood the group.

## 5. Algorithms and Numerical Evidence

We summarize three algorithmic realizations (full code in the accompanying
demo); each both *illustrates* and *empirically certifies* a theorem.

- **Bush enumeration.** For a prime $q = p$, build $L_m$ for each slope and take
  the union; verify $|B| = q^2 - q + 1$ and that the complement is exactly the
  $q-1$ off-origin vertical-axis points. Complexity $O(q^2)$ points generated.
- **Pairwise incidence check.** For all pairs $m_1 \neq m_2$, verify
  $L_{m_1} \cap L_{m_2} = \{(0,0)\}$. Complexity $O(q^2 \cdot q) = O(q^3)$
  intersection work, or $O(q^2)$ pairs each $O(q)$.
- **Iterated sumset growth.** Compute $kA$ by repeated pointwise addition modulo
  $p$ and compare $|kA|$ against $\min(p, k(|A|-1)+1)$, confirming the bound and
  its tightness for arithmetic progressions. Each step is $O(p \cdot |A|)$.

Representative values: over $\mathbb{F}_q$, the bush counts are
$q=2 \to 3$, $q=3 \to 7$, $q=5 \to 21$, $q=7 \to 43$, $q=11 \to 111$, matching
$q^2 - q + 1$ exactly. For $A = \{0,1,2\} \subseteq \mathbb{Z}/11$
($|A|=3$), the sizes $|kA|$ are $3, 5, 7, 9, 11, 11, \dots$, matching
$\min(11, 2k+1)$ and saturating at $k = 5 = \lceil 10/2 \rceil$.

## 6. Applications and Connections

- **Restriction estimates.** Kakeya lower bounds are the geometric input to
  restriction/Bochner–Riesz estimates for the Fourier transform; the discrete
  bush count is the toy version of "tubes pointing in all directions overlap
  little, hence cover much."
- **Katz–Tao reduction.** Dimension bounds reduce to sum–difference estimates;
  Theorem 4.3 is the clean iterated-growth engine, and the incidence lemma
  (Theorem 3.5) supplies the geometric counting that converts arithmetic growth
  into size bounds.
- **Polynomial method (Dvir).** The finite-field line API of Section 3 is the
  natural substrate for the vanishing-polynomial argument that resolves the
  finite-field Kakeya conjecture in all dimensions.

## 7. Discussion and Future Work

The fragments proved here are exact and complete within their scope, but they
are deliberately the *cleanest* corner of the model. The through-origin pencil
avoids the inclusion–exclusion subtleties of general affine directions; the
sumset law lives in the prime cyclic group where Cauchy–Davenport is sharp. The
natural next steps sharpen and extend these:

1. **Sharp 2D bound $q(q+1)/2$.** A Kakeya set containing a line in every one
   of the $q+1$ affine directions (not only through the origin) should have at
   least $q(q+1)/2$ points, via a Bonferroni bound $\sum |L_i| - \sum_{i<j}
   |L_i \cap L_j| = q^2 - \binom{q}{2}$, with the pairwise term supplied by the
   incidence lemma.
2. **Dvir bound in $F_q^n$.** Every Kakeya set has at least
   $\binom{q+n-1}{n} \geq q^n/n!$ points, via a vanishing low-degree
   polynomial — a finite linear-algebra fact rather than analysis.
3. **Exact saturation threshold $\lceil (p-1)/(|A|-1)\rceil$.** The growth law
   gives the universal lower bound; APs achieve equality, so the AP threshold is
   minimal over all seeds.
4. **Katz–Tao sum–difference $\Rightarrow$ discrete dimension bound.** A
   sum–difference estimate $|A+A| + |A-A| \gtrsim |A|^{1+\varepsilon}$ for a
   discrete Kakeya configuration's slope set upgrades the trivial $q^{3/2}$
   count toward Wolff's $5/2$ in the $F_q^3$ model.

## 8. Conclusion

The Kakeya problem asks how thin a set can be while still pointing everywhere.
Even where the continuous conjecture remains open, the finite-field model yields
exact, fully provable answers: the through-origin bush has precisely
$q^2 - q + 1$ points, distinct directions cross exactly once, any Kakeya set
inherits the full bush, and additively, sumsets in $\mathbb{Z}/p$ grow at the
sharp rate $\min(p,\, k(|A|-1)+1)$ until they fill the group. Together these
give a self-contained, exact miniature of the geometry and the arithmetic that
animate the full conjecture.

## References (classical, for orientation only)

- A. Besicovitch, *On Kakeya's problem and a similar one*, 1928.
- R. Davies, *Some remarks on the Kakeya problem*, 1971.
- T. Wolff, *An improved bound for Kakeya type maximal functions*, 1995.
- N. Katz, T. Tao, *New bounds for Kakeya problems*, 2002.
- Z. Dvir, *On the size of Kakeya sets in finite fields*, 2008.
- A. Cauchy (1813), H. Davenport (1935): the Cauchy–Davenport inequality.
