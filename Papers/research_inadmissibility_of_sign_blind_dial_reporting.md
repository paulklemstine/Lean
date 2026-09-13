# Inadmissibility of Sign-Blind Variance-Share Reporting

### The exact invariant content, ambiguity amplitude, and one-bit repair of the augmentation increment

**Author:** Aristotle
**Date:** 2026-09-12

---

## Abstract

For a finite weighted population with a base predictor $x$ (the *footprint*), a
candidate predictor $z$ (the *feature*), and a target $y$ (the *rate*), the
*augmentation increment* $\Delta R^2$ measures the additional share of the target's
variance explained when $z$ is adjoined to a model already containing $x$. Reporting
protocols overwhelmingly publish variance shares $R^2(x,y)$, $R^2(z,y)$, $R^2(x,z)$,
which are squares of the corresponding correlations and therefore *sign-blind*. We
determine exactly how much of the increment survives this loss.

We prove: (i) **no** function of the three variance shares returns $\Delta R^2$ on all
finite populations, and the failure already occurs on populations supported on four
keys; (ii) the set of witnessing configurations contains an open set of moment space,
so the failure is robust, not an algebraic accident; (iii) the ambiguity is *quantised* —
two populations with identical readings either report the same increment or increments
differing by exactly $A = 4\sqrt{R^2(x,y)R^2(z,y)R^2(x,z)}/(1-R^2(x,z))$, with no
intermediate possibility; (iv) $A$ vanishes precisely when one of the three readings is
zero, a nowhere-dense condition; (v) within an explicit two-parameter family the
concealable share of target variance has greatest value $16/17$, attained at the
irrational parameter pair $b=1$, $u=\sqrt5$; (vi) universally, matched pairs with
opposite sign satisfy $A \le 2\sqrt{R^2(x,z)}/(1+\sqrt{R^2(x,z)}) < 1$, a ceiling derived
from Cauchy–Schwarz via the nonnegativity of the correlation Gram determinant; and
(vii) the defect is exactly one bit deep: logging the sign of the correlation triple
product $P = \rho_{xy}\rho_{xz}\rho_{zy}$ restores a complete, explicit predictor
$\Delta R^2 = (c + ae - 2s\sqrt{ace})/(1-e)$.

The structural mechanism is a group-theoretic one. The increment is invariant under
rescalings of the target and the feature, hence is a function on a quotient of moment
space coordinatised by the three signed correlations; the variance shares are the
invariants of the *even* sign-change subgroup, and the surviving $\mathbb{Z}/2$ is
precisely the sign of $P$.

**Keywords:** partial correlation, suppression, variance share, sign invariants,
Gram determinant, incremental validity, moment geometry.

---

## 1. Introduction

### 1.1 The reporting question

Let a finite population be given, and let $y$ be a numerical target attached to its
members. Suppose a base predictor $x$ has already been fitted, explaining a share
$R^2(x,y)$ of the target's variance. A second predictor $z$ is proposed. The decision
turns on the *augmentation increment*

$$\Delta R^2 \;=\; R^2\big(\{x,z\},y\big) - R^2(x,y),$$

the incremental share attributable to $z$ once $x$ is in the model. In applied
literature this is *incremental validity*; in model selection it is the quantity an
$F$-test for a nested model targets.

The tension that motivates this paper is that decision-makers rarely see raw moments.
They see a dashboard: three variance shares,

$$a = R^2(x,y), \qquad c = R^2(z,y), \qquad e = R^2(x,z),$$

each a squared correlation, each in $[0,1]$, each blind to sign. The question is
whether that triple determines $\Delta R^2$. We show it does not, quantify exactly how
badly, and identify the minimal repair.

### 1.2 Why one might expect it to work, and why it fails

A single-predictor variance share is genuinely sign-free: reversing the direction of a
variable does not change how much it explains. The augmentation increment is different
because it is a *comparison*. The classical partial-correlation identity, restated and
proved below, gives

$$\Delta R^2 = \frac{(\rho_{zy} - \rho_{xy}\rho_{xz})^2}{1 - \rho_{xz}^2}.$$

The numerator subtracts the association the footprint already supplies from the
association the feature exhibits. Whether the two terms cancel or reinforce is a
question of sign, and it is exactly the signs that squaring destroys. The classical
phenomenon of **suppression** — a predictor with near-zero marginal association that
becomes powerful after partialling — is the applied face of this algebra.

### 1.3 Contributions and organisation

Section 2 fixes definitions. Section 3 establishes the increment's exact invariant
content: the partial-correlation form, the dashboard form with the triple product $P$,
and the identity $P^2 = ace$, which pins $|P|$ and isolates the missing datum as one
sign. Section 4 constructs an explicit two-parameter family of dashboard-identical
population pairs with divergent increments and proves the impossibility theorem and its
open-set upgrade. Section 5 proves the rigidity dichotomy and the vanishing criterion.
Section 6 establishes the family's exact ceiling $16/17$ and the universal ceiling
$2\sqrt e/(1+\sqrt e)$. Section 7 gives the one-bit repair and the invariance statements
that explain it. Section 8 discusses algorithms and applications; Section 9 lists open
problems.

---

## 2. Setting and definitions

### 2.1 Populations and weighted moments

**Definition 2.1 (Population).** A *population* is a finite index set $I$ of *keys*
together with a weight vector $p : I \to \mathbb{R}$ with $p_i \ge 0$ and
$\sum_{i \in I} p_i = 1$. A *feature* is any function $f : I \to \mathbb{R}$.

**Definition 2.2 (Weighted inner product and moments).** For features $f, g$ set

$$\langle f, g\rangle \;=\; \sum_{i\in I} p_i\, f_i\, g_i, \qquad
\mu(f) \;=\; \langle f, \mathbf 1\rangle,$$

$$\operatorname{cov}(f,g) \;=\; \langle f,g\rangle - \mu(f)\mu(g), \qquad
\operatorname{var}(f) = \operatorname{cov}(f,f).$$

**Definition 2.3 (Variance share and signed correlation).** For features with positive
variance,

$$R^2(f,g) \;=\; \frac{\operatorname{cov}(f,g)^2}{\operatorname{var}(f)\operatorname{var}(g)},
\qquad
\rho_{fg} \;=\; \frac{\operatorname{cov}(f,g)}{\sqrt{\operatorname{var}(f)\operatorname{var}(g)}}.$$

**Proposition 2.4 (A reading is a squared correlation).** $R^2(f,g) = \rho_{fg}^2$.
Consequently two populations whose correlations differ only by a sign present identical
readings: the map from signed correlations to readings discards exactly the sign bits.

*Proof.* Immediate from the definitions, using $\sqrt{v}^2 = v$ for $v>0$. $\square$

### 2.2 Regression residual, partialled feature, and the increment

**Definition 2.5 (Residual).** A feature $r$ is a *residual of $y$ on $x$* if
$y_i = a + b x_i + r_i$ for scalars $a,b$ and $r$ is centred and orthogonal to the
footprint:

$$\langle r, \mathbf 1 \rangle = 0, \qquad \langle x, r\rangle = 0 .$$

Such $r$ exists and is unique whenever $\operatorname{var}(x)>0$, with
$b = \operatorname{cov}(x,y)/\operatorname{var}(x)$.

**Definition 2.6 (Partialled feature).** A feature $\tilde z$ is *$z$ partialled on
$x$* if $\langle \tilde z, \mathbf 1\rangle = 0$, $\langle x, \tilde z\rangle = 0$, and
$z - \tilde z$ lies in the span of $\mathbf 1$ and $x$. Explicitly,
$\tilde z = (z - \mu(z)) - \frac{\operatorname{cov}(x,z)}{\operatorname{var}(x)}(x - \mu(x))$.
Its energy is

$$\langle \tilde z, \tilde z\rangle = \operatorname{var}(z) - \frac{\operatorname{cov}(x,z)^2}{\operatorname{var}(x)}. \tag{2.1}$$

We call the population *nondegenerate at $z$* when this energy is strictly positive,
i.e. when $z$ is not an affine function of $x$.

**Definition 2.7 (Augmentation increment).** With $r$ and $\tilde z$ as above and
$\langle \tilde z,\tilde z\rangle>0$, the *partial gain* and the *increment* are

$$\operatorname{pgain} \;=\; \frac{\langle r, \tilde z\rangle^2}{\langle \tilde z,\tilde z\rangle},
\qquad
\Delta R^2 \;=\; \frac{\operatorname{pgain}}{\operatorname{var}(y)} .$$

This is the standard incremental variance share: $\operatorname{pgain}$ is the length of
the projection of the residual onto the partialled feature, and dividing by
$\operatorname{var}(y)$ expresses it as a share.

**Lemma 2.8 (Five-moment form).** Under the above hypotheses,

$$\Delta R^2 \;=\;
\frac{\Big(\operatorname{cov}(z,y) - \dfrac{\operatorname{cov}(x,z)\operatorname{cov}(x,y)}{\operatorname{var}(x)}\Big)^{2}}
{\Big(\operatorname{var}(z) - \dfrac{\operatorname{cov}(x,z)^{2}}{\operatorname{var}(x)}\Big)\operatorname{var}(y)} .
\tag{2.2}$$

*Proof sketch.* Expand $\langle r,\tilde z\rangle$ using $r = (y-\mu(y)) - b(x-\mu(x))$
and the orthogonality defining $\tilde z$; the cross terms produce exactly
$\operatorname{cov}(z,y) - \operatorname{cov}(x,z)\operatorname{cov}(x,y)/\operatorname{var}(x)$.
Combine with (2.1). $\square$

Thus the increment depends only on the five second moments
$\operatorname{var}(x), \operatorname{var}(y), \operatorname{var}(z),
\operatorname{cov}(x,y), \operatorname{cov}(x,z), \operatorname{cov}(z,y)$ — six
quantities, of which the increment uses the scale-free combinations below.

**Definition 2.9 (Dashboard).** The *dashboard* (or *dial*) of a population relative to
$(x,z,y)$ is the triple $(a,c,e) = (R^2(x,y), R^2(z,y), R^2(x,z))$. A *sign-blind
predictor* is a function $F : \mathbb{R}^3 \to \mathbb{R}$ with
$\Delta R^2 = F(a,c,e)$ for every population and every admissible $(x,z,y,r,\tilde z)$.

---

## 3. The exact invariant content of the increment

### 3.1 Nondegeneracy

**Theorem 3.1 (Collinearity reading is strictly sub-unit).** If
$\operatorname{var}(x) > 0$, $\operatorname{var}(z)>0$ and the partialled energy (2.1)
is positive, then $R^2(x,z) < 1$.

*Proof.* Multiplying the positive partialled energy by $\operatorname{var}(x) > 0$ gives
$\operatorname{var}(x)\operatorname{var}(z) - \operatorname{cov}(x,z)^2 > 0$, which is
exactly $R^2(x,z) < 1$ after dividing by the positive product of variances. $\square$

All denominators $1 - e$ below are therefore strictly positive.

### 3.2 Partial-correlation form

**Theorem 3.2 (Scale-free form of the increment).** Under the standing hypotheses,

$$\Delta R^2 \;=\; \frac{\big(\rho_{zy} - \rho_{xy}\rho_{xz}\big)^{2}}{1 - \rho_{xz}^{2}} .
\tag{3.1}$$

In particular $\Delta R^2$ is a function of the three signed correlations alone and is
invariant under rescaling of $x$, $y$ or $z$.

*Proof sketch.* Write $s_x = \sqrt{\operatorname{var}(x)}$ and similarly $s_y, s_z$, and
substitute $\operatorname{cov}(x,y) = \rho_{xy}s_xs_y$ etc. into (2.2). Numerator and
denominator each carry a factor $s_x^2 s_y^2 s_z^2$; cancelling it (legitimate, since the
partialled energy is nonzero) leaves (3.1). $\square$

The right-hand side is the square of the *partial correlation* of $z$ and $y$ given $x$.
Equation (3.1) is the precise sense in which the increment "depends on signed second
moments": the numerator is a signed difference.

### 3.3 The triple product and dashboard coordinates

**Definition 3.3 (Correlation triple product).**
$P \;=\; \rho_{xy}\,\rho_{xz}\,\rho_{zy}$.

**Theorem 3.4 (Dashboard form).** With $a,c,e$ the three readings,

$$\Delta R^2 \;=\; \frac{c + a\,e - 2P}{1 - e}. \tag{3.2}$$

*Proof.* Expand the numerator of (3.1):
$\rho_{zy}^2 - 2\rho_{xy}\rho_{xz}\rho_{zy} + \rho_{xy}^2\rho_{xz}^2 = c - 2P + ae$,
and $1 - \rho_{xz}^2 = 1 - e$ by Proposition 2.4. $\square$

**Theorem 3.5 (The dashboard pins $|P|$).** $P^{2} = a\,c\,e$.

*Proof.* $P^2 = \rho_{xy}^2\rho_{xz}^2\rho_{zy}^2 = R^2(x,y)R^2(x,z)R^2(z,y)$. $\square$

Theorems 3.4 and 3.5 together are the conceptual core of the paper. The increment is a
function of the dashboard *plus one number*, and that number is determined by the
dashboard up to sign. Hence:

**Corollary 3.6 (One bit suffices).** If two populations (possibly on different key sets
with different weights) agree on the three readings and their triple products have the
same sign — formally, $P\,P' \ge 0$ — then they report the same increment.

*Proof.* $P^2 = ace = a'c'e' = P'^2$ and $PP'\ge0$ force $P = P'$: equal squares give
$P = \pm P'$, and the negative branch combined with $PP' \ge 0$ forces $P = P' = 0$.
Now apply (3.2) twice. $\square$

The remaining sections show the bit is also *necessary*, measure the harm of omitting
it, and bound that harm.

---

## 4. Impossibility, and its robustness

### 4.1 The four-key stage

Fix four keys with the uniform weight $p \equiv 1/4$. Take

$$x = (1,2,3,4) \quad(\text{the footprint}), \qquad z = (1,1,0,0) \quad(\text{the feature}).$$

Then $\operatorname{var}(x) = 5/4$, $\operatorname{var}(z)=1/4$,
$\operatorname{cov}(x,z) = -1/2$, so $R^2(x,z) = 4/5$ and the partialled feature is

$$\tilde z = \big(-\tfrac1{10},\, \tfrac3{10},\, -\tfrac3{10},\, \tfrac1{10}\big),
\qquad \langle \tilde z,\tilde z\rangle = \tfrac1{20}.$$

The space of centred features orthogonal to $x$ is two-dimensional; besides $\tilde z$ it
contains

$$\varepsilon = (1,-1,-1,1),$$

which is centred, orthogonal to $x$, and orthogonal to $\tilde z$. So
$\{\tilde z, \varepsilon\}$ is an orthogonal basis of the residual plane — the exact
degree of freedom a target has once its footprint component is fixed.

### 4.2 The two-parameter family

**Definition 4.1.** For real $b$ and $u>0$ define two targets on the four-key stage:

$$y_B(b,u) \;=\; b\,x + \Big(u + \tfrac{5b^2}{u}\Big)\varepsilon, \qquad
y_C(b,u) \;=\; b\,x + \Big(u - \tfrac{5b^2}{u}\Big)\varepsilon + 20b\,\tilde z .$$

Their residuals on $x$ are the $\varepsilon$/$\tilde z$ parts,
$r_B = (u + 5b^2/u)\varepsilon$ and $r_C = (u - 5b^2/u)\varepsilon + 20b\,\tilde z$.

**Theorem 4.2 (The family is dashboard-identical with flipped sign).** For all $b$ and
all $u \ne 0$:

1. $\operatorname{var}(y_B) = \operatorname{var}(y_C) = \dfrac{5b^2u^2 + 4(u^2+5b^2)^2}{4u^2}$;
2. $\operatorname{cov}(x, y_B) = \operatorname{cov}(x,y_C) = \tfrac54 b$;
3. $\operatorname{cov}(z,y_B) = -\tfrac b2 = -\operatorname{cov}(z,y_C)$;
4. consequently $R^2(x,y_B) = R^2(x,y_C)$ and $R^2(z,y_B) = R^2(z,y_C)$, while the two
   signed feature covariances are exact negatives.

*Proof sketch.* All four items are direct evaluations of four-term sums, using
$\langle \varepsilon,\varepsilon\rangle = 1$, $\langle\varepsilon,\tilde z\rangle=0$,
$\langle \tilde z,\tilde z\rangle = 1/20$, $\operatorname{cov}(z,\varepsilon) = 0$,
$\operatorname{cov}(x,z) = -1/2$ and $\operatorname{cov}(z,\tilde z) = \langle\tilde z,\tilde z\rangle = 1/20$.
For instance $\operatorname{cov}(z,y_B) = b\operatorname{cov}(x,z) = -b/2$ while
$\operatorname{cov}(z,y_C) = -b/2 + 20b\cdot\tfrac1{20} = +b/2$.
The $\pm 5b^2/u$ shift in the $\varepsilon$
coefficient is calibrated so that the extra energy $ (20b)^2/20 = 20b^2$ carried by
$y_C$ along $\tilde z$ is exactly offset:
$(u+5b^2/u)^2 - (u-5b^2/u)^2 = 20b^2$. The coefficient $20b$ is calibrated so that the
feature covariance changes from $-b/2$ to $+b/2$. $\square$

**Theorem 4.3 (Divergent increments).** For $u>0$,

$$\Delta R^2(y_B) = 0, \qquad
\Delta R^2(y_C) \;=\; \frac{80\,b^{2}u^{2}}{5b^{2}u^{2} + 4\,(u^{2}+5b^{2})^{2}} .
\tag{4.1}$$

*Proof sketch.* $\langle r_B, \tilde z\rangle = 0$ because $r_B$ is a multiple of
$\varepsilon \perp \tilde z$; hence the partial gain vanishes. For $y_C$,
$\langle r_C,\tilde z\rangle = 20b\langle \tilde z,\tilde z\rangle = b$, so the partial
gain is $b^2/(1/20) = 20b^2$; dividing by the variance in Theorem 4.2(1) gives (4.1).
Equivalently, one may route the computation through the five-moment formula (2.2) with
$\operatorname{cov}(z,y_C)=b/2$. $\square$

**Base point.** At $(b,u) = (1/10, 1/2)$ the two targets are

$$y_B = (0.7,\,-0.4,\,-0.3,\,1.0), \qquad y_C = (0.3,\,0.4,\,-0.7,\,1.0),$$

with common variance $0.3725$, readings

$$a = \tfrac5{149}\approx 0.0336,\quad c = \tfrac4{149}\approx 0.0268,\quad e = \tfrac45,$$

and increments $0$ and $80/149 \approx 0.5369$.

### 4.3 The impossibility theorem

**Theorem 4.4 (Inadmissibility of sign-blind reporting).** There is no function
$F:\mathbb{R}^3\to\mathbb{R}$ such that for every finite population and every admissible
configuration $(x,y,z,r,\tilde z)$ with $\operatorname{var}(x),\operatorname{var}(y),
\operatorname{var}(z), \langle\tilde z,\tilde z\rangle > 0$ one has
$\Delta R^2 = F\big(R^2(x,y), R^2(z,y), R^2(x,z)\big)$. The statement already fails when
restricted to populations on four keys.

*Proof.* Suppose $F$ existed. Apply it to $y_B$ and $y_C$ at the base point. By Theorem
4.2 the arguments are identical; by Theorem 4.3 the required values are $0$ and
$80/149 \ne 0$. Contradiction. $\square$

### 4.4 An open set of counterexamples

A single pair might conceivably live on a thin set. It does not.

**Theorem 4.5 (Uniform gap on a box).** If $|b - 1/10| < 1/100$ and $|u - 1/2| < 1/100$
then $\Delta R^2(y_C) - \Delta R^2(y_B) \ge 1/3$.

*Proof sketch.* By (4.1) the claim reduces to the polynomial inequality
$240\,b^2u^2 \ge 5b^2u^2 + 4(u^2+5b^2)^2$ on the box. On the box,
$u^2+5b^2 < 0.3206$, so the right-hand side is below
$5b^2u^2 + 4(0.3206)^2 < 0.4126$, while $b^2u^2 > (0.09)^2(0.49)^2$ gives
$240b^2u^2 > 0.4667$. $\square$

**Theorem 4.6 (The witness set contains an open set).** There is an open set
$V \subseteq \mathbb{R}^2$ containing $(1/10, 1/2)$ — the Euclidean ball of radius
$1/100$ — such that for every $(b,u) \in V$: both members of the pair are legitimate
populations with positive target variance; their three readings agree exactly; their
signed feature covariances are exact negatives; the suppressed member has increment
exactly $0$; and the active member has increment at least $1/3$.

**Theorem 4.7 (The ball is genuinely spread in moment space).** The readings are not
constant on $V$: the footprint reading

$$R^2(x, y_B(b,u)) \;=\; \frac{5b^2u^2}{5b^2u^2 + 4(u^2+5b^2)^2}$$

takes different values at different points of $V$, so $V$ is not a single moment
configuration presented in different coordinates. Consequently the set of *readings* at
which sign-blind prediction fails has nonempty interior.

Together, Theorems 4.4–4.7 upgrade the impossibility from a point obstruction to an
obstruction over an open region of moment space — the "robust family" the problem calls
for.

---

## 5. Rigidity: the ambiguity is a two-point set

Impossibility alone leaves open the shape of the ambiguity. One might expect the set of
increments compatible with a reading to be an interval. It is not: it has at most two
elements, and their separation is an explicit function of the reading.

**Theorem 5.1 (Ambiguity dichotomy).** Let two finite populations — possibly with
different key sets and different weight vectors — each satisfy the standing
nondegeneracy hypotheses, and suppose they agree on all three readings:
$a = a'$, $c = c'$, $e = e'$. Then either

$$\Delta R^2 = \Delta R'^2, \qquad\text{or}\qquad
\big|\Delta R^2 - \Delta R'^2\big| \;=\; A \;:=\; \frac{4\sqrt{a\,c\,e}}{1-e}.$$

No intermediate value is possible.

*Proof.* By Theorem 3.5 and the equality of readings, $P^2 = P'^2$, so $P' = P$ or
$P' = -P$. In the first case (3.2) gives equal increments. In the second, subtracting
the two instances of (3.2) gives

$$\Delta R^2 - \Delta R'^2 = \frac{(c+ae-2P) - (c+ae+2P)}{1-e} = \frac{-4P}{1-e},$$

and $|P| = \sqrt{ace}$ by Theorem 3.5 while $1-e>0$ by Theorem 3.1. $\square$

**Theorem 5.2 (When is the dashboard admissible?).** Under the standing hypotheses,
$A = 0$ if and only if at least one of $a$, $c$, $e$ is zero.

*Proof.* $1 - e > 0$, so $A = 0$ iff $\sqrt{ace} = 0$ iff $ace = 0$ (all three factors
being nonnegative), iff one factor vanishes. $\square$

Since $\{(a,c,e) : ace = 0\}$ is a union of three coordinate planes, it has empty
interior: **sign-blind reporting is harmless only on a nowhere-dense set of readings.**
At every other reading the two admissible increments are genuinely distinct, and the
dashboard cannot say which is the truth — but it *can* print $A$, which is a sharp,
computable error bar of the form "the answer is $t$ or $t + A$".

*Consistency check.* At the base point $a = 5/149$, $c = 4/149$, $e = 4/5$:
$\sqrt{ace} = \sqrt{16/149^2} = 4/149$, so $A = (16/149)/(1/5) = 80/149$, exactly the
observed gap between $0$ and $80/149$.

---

## 6. How much can be concealed?

### 6.1 The family's exact ceiling

**Theorem 6.1 (Family ceiling).** For all real $b$ and all $u > 0$,

$$\Delta R^2(y_C) - \Delta R^2(y_B) \;=\;
\frac{80b^2u^2}{5b^2u^2+4(u^2+5b^2)^2} \;\le\; \frac{16}{17}.$$

*Proof.* Clearing the positive denominator, the claim is
$17\cdot 80\,b^2u^2 \le 16\big(5b^2u^2 + 4(u^2+5b^2)^2\big)$, i.e.
$1360 b^2u^2 \le 80b^2u^2 + 64(u^2+5b^2)^2$, i.e.
$64(u^2+5b^2)^2 - 1280b^2u^2 \ge 0$. Since
$(u^2+5b^2)^2 - 20b^2u^2 = (u^2-5b^2)^2$, the left side is $64(u^2-5b^2)^2 \ge 0$.
$\square$

**Theorem 6.2 (Attainment and sharpness).** At $b = 1$, $u = \sqrt 5$ the two members of
the pair agree on every reading and

$$\Delta R^2(y_C) - \Delta R^2(y_B) = \frac{80\cdot 5}{25 + 4\cdot 100} = \frac{400}{425} = \frac{16}{17}.$$

Hence $16/17$ is the greatest element of the set of concealable shares realised by the
family: it is attained and never exceeded.

The maximiser is exactly the vanishing locus $u = \sqrt5\,b$ of the perfect square in
the proof of Theorem 6.1 — an irrational ray in parameter space. At this point, two
four-key populations present identical sign-blind readings, and one of them attributes
$16/17 \approx 94.1\%$ of its target's variance to the new feature while the other
attributes exactly nothing.

### 6.2 A universal ceiling

Theorem 6.1 concerns one family. What of arbitrary populations? The amplitude formula
$A = 4\sqrt{ace}/(1-e)$ is, as a function of three independent numbers in $[0,1)$,
unbounded: let $a,c,e \to 1$. The resolution is that the three readings of a
*sign-ambiguous* configuration are not independent, because the configuration must be
realisable with *both* signs of $P$, and correlation structures are constrained by
positive semidefiniteness.

**Theorem 6.3 (No model explains more than everything).** Under the standing hypotheses
with $\langle r,r\rangle > 0$,

$$R^2(x,y) + \Delta R^2 \;\le\; 1 .$$

*Proof.* Since $r$ is centred and orthogonal to $x$, the decomposition $y = a+bx+r$ is
orthogonal, giving $\operatorname{var}(y) = b^2\operatorname{var}(x) + \langle r,r\rangle$
and $R^2(x,y) = b^2\operatorname{var}(x)/\operatorname{var}(y)$. By Cauchy–Schwarz,
$\langle r,\tilde z\rangle^2 \le \langle r,r\rangle\langle\tilde z,\tilde z\rangle$, so
$\Delta R^2 \le \langle r,r\rangle/\operatorname{var}(y)$. Add. $\square$

**Theorem 6.4 (Gram inequality in dashboard coordinates).** Under the same hypotheses,

$$1 - a - e - c + 2P \;\ge\; 0 . \tag{6.1}$$

*Proof.* Substituting (3.2) into Theorem 6.3 gives
$(c + ae - 2P)/(1-e) \le 1 - a$; multiplying by $1 - e > 0$ and rearranging yields
$c + ae - 2P \le 1 - a - e + ae$, i.e. (6.1). $\square$

Inequality (6.1) is precisely the nonnegativity of the determinant of the $3\times3$
correlation matrix of $(x,y,z)$, whose value is $1 - \rho_{xy}^2 - \rho_{xz}^2 -
\rho_{zy}^2 + 2\rho_{xy}\rho_{xz}\rho_{zy}$. Note that it is *derived* here from
Cauchy–Schwarz rather than assumed.

**Theorem 6.5 (Algebraic amplitude ceiling).** Let $a,c \ge 0$ and $0 \le e < 1$ satisfy
the Gram inequality with the unfavourable sign,

$$2\sqrt{a\,e\,c} \;\le\; 1 - a - e - c,$$

Then

$$\frac{4\sqrt{aec}}{1-e} \;\le\; \frac{2\sqrt e}{1+\sqrt e}.$$

*Proof.* Put $\alpha = \sqrt a$, $\gamma = \sqrt c$, $\eta = \sqrt e \in [0,1)$, so that
$\sqrt{aec} = \alpha\gamma\eta$. The hypothesis reads
$2\alpha\gamma\eta \le 1 - \alpha^2 - \eta^2 - \gamma^2$. By AM–GM,
$2\alpha\gamma \le \alpha^2 + \gamma^2$, hence

$$2\alpha\gamma(1+\eta) = 2\alpha\gamma + 2\alpha\gamma\eta
\le (\alpha^2+\gamma^2) + \big(1 - \alpha^2 - \gamma^2 - \eta^2\big) = 1 - \eta^2 = 1-e.$$

Therefore $4\alpha\gamma\eta(1+\eta) \le 2\eta(1-e)$, which upon dividing by
$(1-e)(1+\eta) > 0$ is exactly the claim. $\square$

**Theorem 6.6 (Ceiling is strictly below one).** For $0 \le e < 1$,
$\dfrac{2\sqrt e}{1+\sqrt e} < 1$.

*Proof.* $\sqrt e < 1$, so $2\sqrt e < 1 + \sqrt e$. $\square$

**Theorem 6.7 (Universal ceiling for sign-blind misattribution).** Let two finite
populations satisfy the standing hypotheses, agree on all three readings, and have
opposite triple products, $P' = -P$. Then

$$\big|\Delta R^2 - \Delta R'^2\big| \;\le\; \frac{2\sqrt{e}}{1+\sqrt{e}} \;<\; 1,
\qquad e = R^2(x,z).$$

*Proof.* Both populations satisfy (6.1); with equal readings and opposite $P$, the two
instances read $1 - a - e - c + 2P \ge 0$ and $1 - a - e - c - 2P \ge 0$, so
$2|P| \le 1 - a - e - c$. Since $|P| = \sqrt{ace}$, Theorem 6.5 applies, and by Theorem
5.1 the left-hand side is either $0$ or $4\sqrt{ace}/(1-e)$. Theorem 6.6 gives
strictness. $\square$

**Interpretation.** The maximum damage sign-blindness can do is controlled by the
footprint–feature collinearity reading alone. Near-orthogonal features
($e \approx 0$) are almost safe to report sign-blind; heavily collinear features are
where the ambiguity concentrates. And a strictly positive share of variance is always
beyond reach of the ambiguity.

**Corollary 6.8 (The family sits just below the ceiling).** The four-key family has
$e = R^2(x,z) = 4/5$, for which the ceiling is

$$\frac{2\sqrt{4/5}}{1+\sqrt{4/5}} = \frac{4}{2+\sqrt5} \approx 0.94427,$$

and the family's peak concealable share is $16/17 \approx 0.94118$. Thus
$16/17 < 4/(2+\sqrt5)$: the explicit construction realises $99.7\%$ of the theoretical
maximum at its collinearity level.

---

## 7. The repair: exactly one bit

### 7.1 Invariance and the group-theoretic picture

**Theorem 7.1 (Unit invariance).** For any nonzero $\lambda$:

1. replacing the feature $z$ by $\lambda z$ replaces $\tilde z$ by $\lambda\tilde z$ and
   leaves the partial gain unchanged;
2. replacing the target $y$ by $\lambda y$ multiplies its residual by $\lambda$ and its
   variance by $\lambda^2$, leaving $\Delta R^2$ unchanged.

*Proof.* (1) $\langle r, \lambda\tilde z\rangle^2/\langle\lambda\tilde z,\lambda\tilde z\rangle
= \lambda^2\langle r,\tilde z\rangle^2/(\lambda^2\langle\tilde z,\tilde z\rangle)$. (2) is
the same cancellation applied to the numerator and $\operatorname{var}(y)$. $\square$

Hence $\Delta R^2$ is a function on the quotient of moment space by the reparametrisation
group $(\mathbb{R}^\times)^3$ acting by unit changes; Theorem 3.2 says the three signed
correlations are coordinates on that quotient. The subgroup of *sign* changes,
$\{\pm1\}^3$, acts on $(\rho_{xy},\rho_{xz},\rho_{zy})$; the orbit invariants of the full
sign group are the three squares $(a,c,e)$ — i.e. the dashboard — while $\Delta R^2$ is
invariant only under the *even* subgroup (flip two signs at a time). The quotient of the
full group by the even subgroup is $\mathbb{Z}/2$, and its generator is detected by the
sign of $P$. This is the structural explanation of why the loss is one bit — not three.

### 7.2 The repaired dashboard

**Definition 7.2 (Sign bit and repaired dial).** Put $s = +1$ if $P \ge 0$ and $s = -1$
otherwise, and define

$$G(a,c,e,s) \;=\; \frac{c + a\,e - 2\,s\sqrt{a\,e\,c}}{1-e}.$$

**Theorem 7.3 (Correctness of the repaired dashboard).** Under the standing hypotheses,

$$\Delta R^2 \;=\; G\big(R^2(x,y),\, R^2(z,y),\, R^2(x,z),\, s\big).$$

*Proof.* By Theorem 3.5, $\sqrt{ace} = |P|$, and $s|P| = P$ by definition of $s$.
Substitute into (3.2). $\square$

**Theorem 7.4 (Existence of a complete predictor with one extra bit).** There exists
$G : \mathbb{R}^4 \to \mathbb{R}$ such that for every finite population and admissible
configuration, $\Delta R^2 = G(a, c, e, s)$ — in exact contrast with Theorem 4.4, which
shows no function of $(a,c,e)$ alone suffices.

Theorems 4.4 and 7.4 sandwich the defect: **sign-blind reporting is inadmissible, and
its inadmissibility is exactly one bit deep.**

**Verification on the base pair.** Both members feed $G$ the arguments
$a = 5/149$, $c = 4/149$, $e = 4/5$, with $\sqrt{ace} = 4/149$. The suppressed target
has $\rho_{xy}>0$, $\rho_{xz}<0$, $\rho_{zy}<0$, so $s = +1$ and
$G = (4/149 + 4/149 - 8/149)/(1/5) = 0$. The active target has $\rho_{zy}>0$, so
$s = -1$ and $G = (4/149+4/149+8/149)\cdot 5 = 80/149$. Both correct.

---

## 8. Algorithms, diagnostics and applications

### 8.1 The ambiguity-annotated report

The results yield a drop-in upgrade for any reporting pipeline, at negligible cost.

> **Algorithm (Ambiguity-annotated augmentation report).**
> *Input:* weights $p$, features $x, z$, target $y$.
> 1. Compute the six second moments and the three readings $a, c, e$.
> 2. If $e = 1$, report *degenerate* (the feature is an affine function of the footprint).
> 3. Compute $|P| = \sqrt{ace}$ and the amplitude $A = 4|P|/(1-e)$.
> 4. Compute the signed correlations and $s = \operatorname{sign}(\rho_{xy}\rho_{xz}\rho_{zy})$.
> 5. Report the true increment $\Delta R^2 = (c+ae-2s|P|)/(1-e)$, the amplitude $A$, the
>    *other* value a sign-blind reader could not exclude, $(c+ae+2s|P|)/(1-e)$, and the
>    universal ceiling $2\sqrt e/(1+\sqrt e)$.

Each step is $O(n)$ for a population of $n$ keys plus $O(1)$ arithmetic, so the
annotation is free relative to computing the readings in the first place. The output
tells the reader not only the increment but exactly how much a sign-blind reader would
be at risk of misattributing.

### 8.2 Auditing an existing sign-blind report

Given only a legacy dashboard $(a,c,e)$ one can still act:

* compute $A = 4\sqrt{ace}/(1-e)$ and the two admissible increments
  $t_\pm = (c+ae \mp 2\sqrt{ace})/(1-e)$;
* if $A$ is below the decision threshold, the legacy report is *certified*: no sign
  information could change the decision;
* if $A$ exceeds it, the report is *indeterminate* and the underlying signs must be
  retrieved. Theorem 5.2 says the certified case requires one of the readings to be
  (numerically) negligible, so certification is the exception.

### 8.3 Constructing adversarial pairs

The family of Definition 4.1 gives a constructive generator of dashboard-identical pairs
with prescribed gap: choose the target gap $g \in (0, 16/17]$ and solve (4.1) for
parameters. This is useful for stress-testing analytics pipelines and for teaching: the
$\varepsilon$/$\tilde z$ decomposition of the residual plane makes plain that the
reporting collapse is a two-dimensional geometry problem, not an artefact of large
dimension.

### 8.4 Where this bites in practice

* **Feature selection and incremental validity.** A screening rule of the form "drop
  candidate features with $R^2(z,y) < \tau$ and $R^2(x,z) > \theta$" is exactly the rule
  the family defeats: the base pair has $c \approx 0.027$ and $e = 0.8$, and one member
  of the pair would contribute $54\%$ of target variance.
* **Meta-analysis and secondary reporting.** Published correlation tables often give
  magnitudes or $R^2$ values; Theorem 4.4 says the increment simply cannot be recovered
  from them, and Theorem 5.1 says the resulting uncertainty is a two-point set of known
  spread.
* **Automated dashboards and data catalogues.** Storing the sign bit costs one bit per
  triple. Theorem 7.4 says that is the entire fix; no raw data retention is needed.
* **Model governance.** Theorem 6.7 gives a *worst case* an auditor can quote without
  any sign information: the misattribution is at most $2\sqrt{e}/(1+\sqrt e)$, computable
  from the collinearity reading alone.

---

## 9. Discussion and future directions

### 9.1 What the results say together

The four statements — impossibility (Thm 4.4), openness (Thms 4.5–4.7), rigidity
(Thm 5.1), and repair (Thm 7.4) — form a complete description of the information
content of a sign-blind report. The first says the map from readings to increments is
not a function; the second says the multivaluedness is not confined to a thin set; the
third says the multivalued map has fibres of cardinality exactly two, with an explicit
separation; the fourth says the two-element fibres are resolved by a single bit. The
ceilings (Thms 6.1, 6.2, 6.7) measure the worst case both inside a concrete family and
universally.

### 9.2 A comment on the derivation of the Gram inequality

It is worth stressing the logical route in Section 6. The positive-semidefiniteness of a
correlation matrix is usually invoked as a structural fact. Here it is obtained as a
corollary of the statement "a model cannot explain more than the whole variance", which
in turn is Cauchy–Schwarz applied to the residual and partialled feature. The economy is
pleasant: one inequality about projections generates both the interpretive bound
$R^2 + \Delta R^2 \le 1$ and the geometric constraint that makes the universal ceiling
possible.

### 9.3 Future directions

*(carried forward from the research programme that produced these results)*

**What this cycle settled.** Starting from the five-moment formula for the increment and
an explicit suppression pair, the development establishes:

1. **Impossibility.** No function of the three variance shares $R^2(x,y)$, $R^2(z,y)$,
   $R^2(x,z)$ returns $\Delta R^2$ on all finite populations — already false on
   four-key populations.
2. **Robustness.** The witnesses contain a metric ball of parameters on which every pair
   has identical dial readings, exactly opposite signed covariances, and increments $0$
   and $\ge 1/3$; the readings genuinely vary over the ball, so the failure occupies an
   open region of moment space.
3. **Exact invariant content.** $\Delta R^2 = (\rho_{zy} - \rho_{xy}\rho_{xz})^2/(1-\rho_{xz}^2)$,
   rewritten as a function of the three readings plus the triple product
   $P = \rho_{xy}\rho_{xz}\rho_{zy}$, whose square is the product of the readings.
4. **Rigidity of the damage.** Two populations with equal readings agree, or differ by
   *exactly* $4\sqrt{R^2(x,y)R^2(z,y)R^2(x,z)}/(1-R^2(x,z))$.
5. **Amplitude.** Within the family the concealable share of rate variance has greatest
   value $16/17$, attained at $b=1$, $u=\sqrt5$.
6. **Repair.** One logged sign bit is sufficient, so the inadmissibility of sign-blind
   reporting is exactly one bit deep.
7. **Universal ceiling.** The base share plus increment never exceeds $1$ (weighted
   Cauchy–Schwarz); the Gram inequality
   $1 - R^2(x,y) - R^2(x,z) - R^2(z,y) + 2P \ge 0$ is *derived* rather than assumed; and
   for any two populations with identical dial readings and opposite triple-product signs
   the increments differ by at most $2\sqrt{R^2(x,z)}/(1+\sqrt{R^2(x,z)}) < 1$. So the
   misattribution a sign-blind dashboard can cause is capped by the footprint–feature
   collinearity reading alone; the explicit family sits just below this ceiling,
   $16/17 < 4/(2+\sqrt5)$.

The structural pattern: $\Delta R^2$ is a function on the quotient of moment space by
the reparametrisation group; the dial readings are the invariants of the *even* sign
subgroup, and the leftover $\mathbb{Z}/2$ is precisely the triple-product sign.

**Bold, testable conjectures for the next cycle.**

* **D1. Multi-feature sign cohomology.** For an augmentation by $k$ features at once, the
  analogue of the dashboard is the collection of pairwise variance shares, and the
  analogue of the missing datum should be the set of *cycle signs* of the correlation
  graph: the sign of $\rho_{i_1i_2}\rho_{i_2i_3}\cdots\rho_{i_mi_1}$ around each cycle.
  Conjecture: the missing information is exactly $H^1$ of the complete graph on $k+2$
  vertices with $\mathbb{Z}/2$ coefficients modulo the vertex-flip action, i.e.
  $\binom{k+1}{2}$ bits, and a spanning-tree's worth of signs suffices to determine all
  of them.
* **D2. Sharpness of the universal ceiling.** Is $2\sqrt e/(1+\sqrt e)$ attained for every
  $e \in (0,1)$ by some pair of populations, or only approached? The AM–GM step is tight
  when $a = c$, suggesting the extremal configuration has equal footprint and feature
  readings; a matching construction would make the ceiling an equality-characterised
  invariant of $e$.
* **D3. Statistical version.** Replace exact moments with sample moments from $n$ draws.
  How large must $n$ be before the sign of $P$ is determined with confidence $1-\delta$,
  and does the two-point rigidity persist as a bimodal posterior for the increment?
  Conjecture: the posterior for $\Delta R^2$ is asymptotically a two-component mixture
  with weights given by the sign posterior, with separation $A$.
* **D4. Which invariants pin the sign?** Are there natural additional population
  invariants — order statistics, monotonicity constraints, sign patterns of the raw
  features — that force $P > 0$? Any such condition would be a genuinely new constraint
  on admissible populations and would carve out a class on which sign-blind reporting is
  admissible after all.

---

## 10. Summary of principal results

| Result | Statement |
|---|---|
| Scale-free increment | $\Delta R^2 = (\rho_{zy}-\rho_{xy}\rho_{xz})^2/(1-\rho_{xz}^2)$ |
| Dashboard form | $\Delta R^2 = (c+ae-2P)/(1-e)$, $P = \rho_{xy}\rho_{xz}\rho_{zy}$ |
| Sign is the only loss | $P^2 = ace$ |
| Impossibility | No $F$ with $\Delta R^2 = F(a,c,e)$ on all finite populations |
| Robustness | Witnesses contain an open ball; gap $\ge 1/3$ throughout |
| Rigidity | Equal readings $\Rightarrow$ equal increments or gap exactly $4\sqrt{ace}/(1-e)$ |
| Admissibility criterion | Gap $=0$ iff $a = 0$ or $c = 0$ or $e = 0$ |
| Family ceiling | Greatest concealable share $16/17$, attained at $b=1,u=\sqrt5$ |
| Universal ceiling | Gap $\le 2\sqrt e/(1+\sqrt e) < 1$ |
| Repair | $\Delta R^2 = (c+ae-2s\sqrt{ace})/(1-e)$ with $s = \operatorname{sign} P$ |
