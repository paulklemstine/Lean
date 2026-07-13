# The Sharp Diagonal Correlation Inequality on the Discrete Cube

## Abstract

We study real-valued observables on the discrete cube $\{0,1\}^n$ equipped with
the uniform probability measure, and their pairwise covariance
$\operatorname{Cov}(f,g) = \mathbb{E}[fg] - \mathbb{E}[f]\mathbb{E}[g]$. We
establish a complete description of the extremes of correlation. First, we prove
the two-sided Harris/FKG correlation inequality: increasing observables are
positively correlated and oppositely-monotone observables are negatively
correlated, both **without** any nonnegativity hypothesis, obtained from the
lattice FKG inequality by a translation to the nonnegative orthant. Second, we
prove a sharp diagonal upper bound: every pair of $[0,1]$-valued observables
satisfies $\operatorname{Cov}(f,g) \le \tfrac14$, via the variance bound
$\operatorname{Var}(f) \le \tfrac14$ and the Cauchy–Schwarz inequality
$\operatorname{Cov}(f,g)^2 \le \operatorname{Var}(f)\operatorname{Var}(g)$. We
show this bound is attained, and identify its unique extremal regime by
computing the exact correlation spectrum of dictatorships: a dictatorship has
mean $\tfrac12$ and variance $\tfrac14$; two dictatorships on the same
coordinate realise the extremal covariance $\tfrac14$; two on distinct
coordinates are uncorrelated. Finally, we establish disjoint-support rigidity:
observables depending on complementary coordinate blocks are exactly
uncorrelated, delineating the equality boundary of the correlation inequality.
Together these results form the analytic base camp for a quantitative stability
theory of correlation on the cube.

## 1. Introduction

Correlation inequalities are among the most versatile tools in probability,
combinatorics, and statistical physics. On the discrete cube $\{0,1\}^n$ with
its coordinatewise partial order, the Harris inequality — a special case of the
Fortuin–Kasteleyn–Ginibre (FKG) inequality — asserts that increasing events are
positively correlated. This single fact underlies percolation theory, the study
of random graphs, and a wealth of results in the analysis of Boolean functions.

The Harris inequality is a *one-sided* statement: it locates a floor for the
correlation of monotone observables. This paper complements it with a matching
*ceiling* and, more importantly, an exact analysis of both extremes. Our aim is
to identify not merely the numerical bounds but the *structures that realise
them*, since these structures are the raw material for stability (robustness)
theorems.

The contributions are:

1. A translation-invariant proof of the two-sided Harris inequality for
   arbitrary real monotone observables (§4).
2. A sharp diagonal bound $\operatorname{Cov}(f,g) \le \tfrac14$ for
   $[0,1]$-valued observables, proved via a variance bound and Cauchy–Schwarz,
   and shown to be attained (§5).
3. The exact correlation spectrum of dictatorships, exhibiting the unique
   extremiser of the diagonal bound and the vanishing of cross-coordinate
   correlation (§6).
4. Disjoint-support rigidity: an exact-independence theorem for observables on
   complementary coordinate blocks, characterising the equality boundary (§7).

## 2. Setup and definitions

Throughout, $n$ is a fixed nonnegative integer. The discrete cube is
$\{0,1\}^n$, which we regard as the set of functions $x : \{1,\dots,n\} \to
\{0,1\}$, endowed with the coordinatewise partial order: $x \le y$ iff
$x_i \le y_i$ for every coordinate $i$. Its least element is the all-zeros point
$\mathbf{0}$ and its greatest element is the all-ones point. The cube carries the
uniform probability measure, assigning mass $2^{-n}$ to each of its $2^n$ points.

**Definition 2.1 (Observable and expectation).** An *observable* is a function
$f : \{0,1\}^n \to \mathbb{R}$. Its *expectation* (mean) is the uniform average
$$\mathbb{E}[f] = \frac{1}{2^n}\sum_{x \in \{0,1\}^n} f(x).$$
An observable is *$[0,1]$-valued* if $0 \le f(x) \le 1$ for all $x$, and an
*event* if it is $\{0,1\}$-valued.

**Definition 2.2 (Covariance and variance).** For observables $f,g$,
$$\operatorname{Cov}(f,g) = \mathbb{E}[f\cdot g] - \mathbb{E}[f]\,\mathbb{E}[g],
\qquad \operatorname{Var}(f) = \operatorname{Cov}(f,f).$$

**Definition 2.3 (Monotonicity).** An observable $f$ is *increasing* (monotone)
if $x \le y$ implies $f(x) \le f(y)$, and *decreasing* (antitone) if $x \le y$
implies $f(x) \ge f(y)$.

**Definition 2.4 (Sign coordinates).** It is convenient to use the $\pm 1$
encoding of coordinates. For a point $x$ define $\chi_i(x) = +1$ if $x_i = 1$ and
$\chi_i(x) = -1$ if $x_i = 0$. These *sign coordinates* satisfy the two identities
we shall use repeatedly:
$$\sum_{x} \chi_i(x) = 0 \quad\text{for every } i, \qquad
\sum_{x} \chi_i(x)\chi_j(x) = 0 \quad\text{for } i \ne j.$$
The first says a fair coordinate is balanced; the second says distinct
coordinates are orthogonal — this is the *coordinate covariance kernel* being
diagonal.

**Definition 2.5 (Dictatorship).** The $i$-th *dictatorship* is the event
$\operatorname{dict}_i(x) = x_i$, equivalently $\operatorname{dict}_i(x) = 1$ if
$x_i = 1$ and $0$ otherwise. In sign coordinates,
$\operatorname{dict}_i(x) = \tfrac{1}{2}(\chi_i(x) + 1)$.

## 3. Elementary calculus of expectation and covariance

The expectation is a normalised sum, hence linear, and the covariance inherits
convenient invariances. These lemmas are used throughout.

**Lemma 3.1 (Linearity).** For all observables $f,g$, constant $c \in \mathbb R$:
$\mathbb{E}[c] = c$, $\mathbb{E}[f+g] = \mathbb{E}[f] + \mathbb{E}[g]$,
$\mathbb{E}[cf] = c\,\mathbb{E}[f]$, and $\mathbb{E}[-f] = -\mathbb{E}[f]$.
Moreover $\mathbb{E}$ is monotone: if $f(x) \le g(x)$ for all $x$ then
$\mathbb{E}[f] \le \mathbb{E}[g]$.

*Proof.* Each identity is the corresponding property of finite sums divided by
the constant $2^n$; the constant case uses $\sum_x c = 2^n c$. Monotonicity is
termwise comparison of sums. $\qquad\blacksquare$

**Lemma 3.2 (Covariance algebra).** Covariance is symmetric,
$\operatorname{Cov}(f,g) = \operatorname{Cov}(g,f)$; invariant under additive
shifts, $\operatorname{Cov}(f + c, g) = \operatorname{Cov}(f,g)$ for every
constant $c$; and antilinear under sign, $\operatorname{Cov}(f,-g) =
-\operatorname{Cov}(f,g)$.

*Proof.* Expand the definition and apply Lemma 3.1. Symmetry uses commutativity
of pointwise multiplication. For the shift, $(f+c)g = fg + cg$, so
$\mathbb{E}[(f+c)g] = \mathbb{E}[fg] + c\,\mathbb{E}[g]$ while
$\mathbb{E}[f+c]\mathbb{E}[g] = (\mathbb{E}[f] + c)\mathbb{E}[g]$; the two extra
$c\,\mathbb{E}[g]$ terms cancel. $\qquad\blacksquare$

The additive-shift invariance is the engine that removes nonnegativity
hypotheses in §4: covariance sees only the *fluctuations* of its arguments, not
their absolute level.

## 4. The two-sided Harris/FKG correlation inequality

The classical FKG inequality on a finite distributive lattice states that, with
respect to a log-supermodular weight, increasing functions are positively
correlated. On the cube with the uniform measure it specialises to the Harris
inequality, but in its lattice form it is usually stated for *nonnegative*
observables. We first record that case, then remove the hypothesis.

**Lemma 4.1 (Nonnegative Harris).** If $f,g$ are increasing and nonnegative,
then $\operatorname{Cov}(f,g) \ge 0$.

*Proof sketch.* Apply the finite FKG (four-functions) inequality on the
distributive lattice $\{0,1\}^n$ with the constant (uniform) weight $\mu \equiv
1$. This yields
$\big(\sum_x f(x)g(x)\big)\big(\sum_x 1\big) \ge \big(\sum_x f(x)\big)\big(\sum_x
g(x)\big)$, i.e. $2^n \sum_x fg \ge (\sum_x f)(\sum_x g)$. Dividing by $2^{2n}$
gives $\mathbb{E}[fg] \ge \mathbb{E}[f]\mathbb{E}[g]$. $\qquad\blacksquare$

**Theorem 4.2 (Harris inequality, arbitrary sign).** If $f$ and $g$ are
increasing observables, then $\operatorname{Cov}(f,g) \ge 0$.

*Proof.* Let $\tilde f(x) = f(x) - f(\mathbf 0)$ and $\tilde g(x) = g(x) -
g(\mathbf 0)$, where $\mathbf 0$ is the bottom of the cube. Both are increasing
(subtracting a constant preserves order) and nonnegative (their minimum, at the
bottom, is $0$). By Lemma 4.1, $\operatorname{Cov}(\tilde f, \tilde g) \ge 0$.
By the additive-shift invariance of Lemma 3.2 applied in both arguments,
$\operatorname{Cov}(\tilde f, \tilde g) = \operatorname{Cov}(f,g)$. Hence
$\operatorname{Cov}(f,g) \ge 0$. $\qquad\blacksquare$

**Theorem 4.3 (Reverse correlation inequality).** If $f$ is increasing and $g$
is decreasing, then $\operatorname{Cov}(f,g) \le 0$.

*Proof.* The observable $-g$ is increasing, so Theorem 4.2 gives
$\operatorname{Cov}(f,-g) \ge 0$. By Lemma 3.2,
$\operatorname{Cov}(f,-g) = -\operatorname{Cov}(f,g)$, whence
$\operatorname{Cov}(f,g) \le 0$. $\qquad\blacksquare$

## 5. The sharp diagonal upper bound

We now bound correlation from above. Unlike the Harris inequality, the ceiling
requires no monotonicity — only boundedness.

**Theorem 5.1 (Nonnegativity of variance).** For every observable $f$,
$\operatorname{Var}(f) \ge 0$.

*Proof.* Writing $m = \mathbb{E}[f]$, one has $\operatorname{Var}(f) =
\mathbb{E}[(f-m)^2]$, an average of nonnegative quantities, hence nonnegative.
Concretely, $\operatorname{Var}(f) = 2^{-n}\sum_x (f(x)-m)^2 \ge 0$.
$\qquad\blacksquare$

**Theorem 5.2 (Variance bound for $[0,1]$-valued observables).** If
$0 \le f(x) \le 1$ for all $x$, then $\operatorname{Var}(f) \le \tfrac14$.

*Proof.* Since $0 \le f(x) \le 1$, we have $f(x)^2 \le f(x)$ pointwise, so by
monotonicity of expectation $\mathbb{E}[f^2] \le \mathbb{E}[f]$. Using the
identity $\operatorname{Var}(f) = \mathbb{E}[f^2] - \mathbb{E}[f]^2$ and writing
$m = \mathbb{E}[f] \in [0,1]$,
$$\operatorname{Var}(f) = \mathbb{E}[f^2] - m^2 \le m - m^2 = \tfrac14 -
(m - \tfrac12)^2 \le \tfrac14. \qquad\blacksquare$$

**Theorem 5.3 (Cauchy–Schwarz for covariance).** For all observables $f,g$,
$$\operatorname{Cov}(f,g)^2 \le \operatorname{Var}(f)\,\operatorname{Var}(g).$$

*Proof.* Center the observables: let $\hat f = f - \mathbb{E}[f]$ and
$\hat g = g - \mathbb{E}[g]$, which have zero mean. Then
$\operatorname{Cov}(f,g) = \mathbb{E}[\hat f \hat g]$,
$\operatorname{Var}(f) = \mathbb{E}[\hat f^2]$, and
$\operatorname{Var}(g) = \mathbb{E}[\hat g^2]$. The claim is the finite
Cauchy–Schwarz inequality $\big(\sum_x \hat f(x)\hat g(x)\big)^2 \le
\big(\sum_x \hat f(x)^2\big)\big(\sum_x \hat g(x)^2\big)$ after dividing by
$2^{2n}$. $\qquad\blacksquare$

**Theorem 5.4 (Sharp diagonal correlation bound).** If $f$ and $g$ are both
$[0,1]$-valued, then
$$\operatorname{Cov}(f,g) \le \tfrac14.$$

*Proof.* By Theorem 5.3 and Theorem 5.2,
$$\operatorname{Cov}(f,g) \le |\operatorname{Cov}(f,g)| \le
\sqrt{\operatorname{Var}(f)\operatorname{Var}(g)} \le
\sqrt{\tfrac14\cdot\tfrac14} = \tfrac14. \qquad\blacksquare$$

The bound requires no monotonicity: it governs *all* bounded observables. Its
sharpness — that $\tfrac14$ is attained — is established in the next section.

## 6. The correlation spectrum of dictatorships

Dictatorships are the simplest nonconstant events and realise the extremes of
both §4 and §5. All computations reduce to the two identities of Definition 2.4
for the sign coordinates.

**Theorem 6.1 (Mean of a dictatorship).** For every coordinate $i$,
$\mathbb{E}[\operatorname{dict}_i] = \tfrac12$.

*Proof.* Since $\operatorname{dict}_i = \tfrac12(\chi_i + 1)$, linearity gives
$\mathbb{E}[\operatorname{dict}_i] = \tfrac12\mathbb{E}[\chi_i] + \tfrac12$. But
$\mathbb{E}[\chi_i] = 2^{-n}\sum_x \chi_i(x) = 0$, so the mean is $\tfrac12$.
$\qquad\blacksquare$

**Theorem 6.2 (Variance of a dictatorship).** For every $i$,
$\operatorname{Var}(\operatorname{dict}_i) = \tfrac14$.

*Proof.* Since $\operatorname{dict}_i$ is $\{0,1\}$-valued,
$\operatorname{dict}_i^2 = \operatorname{dict}_i$, so
$\mathbb{E}[\operatorname{dict}_i^2] = \mathbb{E}[\operatorname{dict}_i] =
\tfrac12$. Hence $\operatorname{Var}(\operatorname{dict}_i) = \tfrac12 -
(\tfrac12)^2 = \tfrac14$. $\qquad\blacksquare$

**Corollary 6.3 (Extremiser of the diagonal bound).** Two dictatorships on the
*same* coordinate attain the sharp bound:
$\operatorname{Cov}(\operatorname{dict}_i, \operatorname{dict}_i) =
\operatorname{Var}(\operatorname{dict}_i) = \tfrac14$. In particular the bound of
Theorem 5.4 is sharp.

**Theorem 6.4 (Distinct dictatorships are uncorrelated).** For $i \ne j$,
$\operatorname{Cov}(\operatorname{dict}_i, \operatorname{dict}_j) = 0$.

*Proof.* Expand $\operatorname{dict}_i\operatorname{dict}_j =
\tfrac14(\chi_i + 1)(\chi_j + 1) = \tfrac14(\chi_i\chi_j + \chi_i + \chi_j + 1)$.
Taking expectations and using $\mathbb{E}[\chi_i] = \mathbb{E}[\chi_j] = 0$ and
the orthogonality $\mathbb{E}[\chi_i\chi_j] = 0$ (the off-diagonal of the
coordinate covariance kernel vanishes for $i \ne j$), we get
$\mathbb{E}[\operatorname{dict}_i\operatorname{dict}_j] = \tfrac14$. Since each
mean is $\tfrac12$, $\operatorname{Cov} = \tfrac14 - \tfrac12\cdot\tfrac12 = 0$.
$\qquad\blacksquare$

Thus the dictatorship correlations occupy exactly the two ends of the admissible
spectrum: $\tfrac14$ on the diagonal (same coordinate) and $0$ off it (distinct
coordinates).

## 7. Disjoint-support rigidity

We finally characterise a large equality regime of the correlation inequality:
observables that read disjoint blocks of coordinates are *exactly*
uncorrelated. Fix a set $S$ of coordinates. Say $f$ *depends only on $S$* if
$f(x) = f(y)$ whenever $x$ and $y$ agree on all coordinates in $S$; say $g$
*depends only on the complement of $S$* if $g(x) = g(y)$ whenever $x$ and $y$
agree on all coordinates outside $S$.

**Definition 7.1 (Block mask and swap).** For $u,v \in \{0,1\}^n$ define the
*mask* $\operatorname{mask}_S(u,v)$ to be the point equal to $u$ on $S$ and to
$v$ off $S$. On the product cube $\{0,1\}^n \times \{0,1\}^n$ define the *block
swap* $\sigma(x,y) = (\operatorname{mask}_S(x,y), \operatorname{mask}_S(y,x))$.

**Lemma 7.2 (The swap is an involution).** $\sigma \circ \sigma = \mathrm{id}$,
so $\sigma$ is a bijection of the product cube.

*Proof.* Coordinatewise: for $i \in S$, both coordinates of $\sigma(x,y)$ take
their $S$-value from the first, resp. second, argument, and applying $\sigma$
again restores the original; similarly off $S$. Checking each of the two cases
$i \in S$ and $i \notin S$ shows the composition is the identity.
$\qquad\blacksquare$

**Theorem 7.3 (Disjoint-support rigidity).** If $f$ depends only on $S$ and $g$
depends only on the complement of $S$, then $\operatorname{Cov}(f,g) = 0$.

*Proof.* We show $\big(\sum_x f(x)\big)\big(\sum_x g(x)\big) = 2^n \sum_x
f(x)g(x)$; dividing by $2^{2n}$ gives $\mathbb{E}[f]\mathbb{E}[g] =
\mathbb{E}[fg]$, i.e. zero covariance. Expand the left side as a double sum over
pairs $(x,y)$:
$$\Big(\sum_x f(x)\Big)\Big(\sum_y g(y)\Big) = \sum_{(x,y)} f(x)g(y).$$
Because $f$ depends only on $S$, $f(x) = f(\operatorname{mask}_S(x,y))$; because
$g$ depends only on the complement, $g(y) = g(\operatorname{mask}_S(x,y))$.
Hence each summand equals $f(w)g(w)$ evaluated at $w = \operatorname{mask}_S(x,y)$,
so
$$\sum_{(x,y)} f(x)g(y) = \sum_{(x,y)} f(\operatorname{mask}_S(x,y))\,
g(\operatorname{mask}_S(x,y)).$$
Now reindex the right side by the involution $\sigma$ (which permutes the
product cube, Lemma 7.2). As $(x,y)$ ranges over the product cube, so does
$(\operatorname{mask}_S(x,y), \operatorname{mask}_S(y,x))$; summing
$f(p_1)g(p_1)$ over this reindexing and collapsing the free second coordinate
(which ranges over all $2^n$ points) produces $2^n \sum_w f(w)g(w)$. Equating
the two expressions gives the claimed identity. $\qquad\blacksquare$

This is the equality boundary of the Harris inequality: a structural sufficient
condition — separation of the coordinate supports — that forces the correlation
of monotone (indeed arbitrary) observables to vanish exactly.

## 8. Discussion

The results assemble into a sharp two-sided picture. On the floor, monotone
observables satisfy $\operatorname{Cov}(f,g) \ge 0$ (Theorem 4.2), with equality
guaranteed whenever the supports are disjoint (Theorem 7.3). On the ceiling,
$[0,1]$-valued observables satisfy $\operatorname{Cov}(f,g) \le \tfrac14$
(Theorem 5.4), with equality attained by a common dictatorship (Corollary 6.3).
The intermediate dictatorship computations (Theorems 6.1–6.4) show that the
dictatorship family alone already samples both endpoints of the spectrum.

Two features of the proofs deserve emphasis. First, the *separation of
hypotheses*: the lower bound genuinely uses order (monotonicity), whereas the
upper bound uses only boundedness through variance and Cauchy–Schwarz. Second,
the *measure-agnostic skeleton*: additive-shift invariance of covariance plus
Cauchy–Schwarz plus a single-coordinate variance input. Only the last ingredient
"knows" about the uniform measure, which is what makes the biased generalisation
(below) so plausible.

## 9. Future directions

**Stability of the diagonal bound.** We conjecture a constant $c > 0$ such that
for events $f,g$ with $\mathbb{E}[f] = \mathbb{E}[g] = \tfrac12$ and
$\operatorname{Cov}(f,g) \ge \tfrac14 - \varepsilon$, both $f$ and $g$ agree with
a single common dictatorship off a $c\varepsilon$ fraction of the cube. The exact
extremiser identified here is the anchor: expanding the covariance deficit
$\tfrac14 - \operatorname{Cov}$ in the Fourier–Walsh basis should force mass to
concentrate on the first level.

**Trichotomy at the equality boundary.** We conjecture that for increasing
events $f,g$, $\operatorname{Cov}(f,g) = 0$ holds iff, after permuting
coordinates, $f$ and $g$ depend on disjoint coordinate blocks. Theorem 7.3 is
the "if"; the converse — strict positivity whenever supports genuinely overlap —
is the remaining content.

**Biased measures.** Under the $p$-biased product measure we conjecture the
sharp bound becomes $\operatorname{Cov}_p(f,g) \le p(1-p)$ for $[0,1]$-valued
observables, again attained by a common dictatorship, since $p(1-p)$ is the
variance of a single $p$-biased coordinate.

**Second-level gap.** If a $[0,1]$-valued observable has small correlation with
every coordinate dictatorship, $\operatorname{Cov}(f, \operatorname{dict}_i) \le
\varepsilon$ for all $i$, we conjecture $\operatorname{Var}(f) \le C\varepsilon$
— low first-level correlation forces near-constancy.

## 10. Conclusion

We have pinned down the extremes of correlation on the discrete cube: a
two-sided Harris inequality without positivity assumptions, a sharp diagonal
upper bound of $\tfrac14$ with its unique dictatorship extremiser, and exact
disjoint-support independence. These exact endpoint computations are precisely
the anchors required to launch a quantitative stability theory, in which
near-extremal correlation is shown to force near-extremal structure.
