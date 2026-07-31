# Inverse Stereographic Tropical Lift: Rigidity, Degree Collapse, and Compactness

**Aristotle**  
**July 31, 2026**

## Abstract

We study a one-dimensional max-plus analogue of stereographic projection. The finite tropical projective line is the quotient of $\mathbb{R}^2$ by diagonal translation and is canonically parametrized by the coordinate difference $x=x_1-x_0$. In this coordinate, the proposed pole construction is the tropical rational expression

$$
S(x)=\max(2x,x)-\max(x,0).
$$

Although this expression has a quadratic-over-linear presentation, it simplifies globally to $S(x)=x$. More generally, moving the finite pole to $p\in\mathbb{R}$ gives

$$
S_p(x)=\max(2x,x+p)-\max(x,p),
$$

and every member of this family is again the identity. Thus finite pole position disappears after projective normalization. The resulting map is a homeomorphism from the finite tropical projective line to $\mathbb{R}$, but its intrinsic minimal degree cannot be two because it has a linear presentation. Under the compactified convention, the tropical projective line is modeled by the extended real line and is compact; consequently, no homeomorphism to $\mathbb{R}$ exists. We give elementary proofs, branch-evaluation algorithms, numerical diagnostics, and implications for intrinsic tropical rational degree and higher-dimensional constructions.

## 1. Introduction

Tropical geometry replaces ordinary arithmetic by an idempotent semiring operation. In the max-plus convention,

$$
a\oplus b=\max(a,b),\qquad a\odot b=a+b.
$$

Repeated tropical multiplication turns a variable $x$ into an ordinary integer multiple: the tropical square $x\odot x$ is $2x$. Tropical polynomials are consequently maxima of affine functions. Their graphs are piecewise linear, and their breakpoints record changes in the dominant monomial.

Stereographic projection, by contrast, is a classical geometric construction in which a chosen pole sends a sphere minus that pole to an affine plane. In dimension one, classical fractional-linear or Möbius transformations provide the relevant coordinate changes. This motivates a tropical question: can a pole construction define a tropical rational homeomorphism from a tropical projective line to a tropical affine line, and does it have a meaningful degree-two character?

Two issues must be separated. First, “the tropical projective line” may refer either to a quotient formed solely from finite coordinates or to a compactified object admitting infinite coordinates. These spaces have different topology. Second, the syntactic degree of a difference of tropical polynomials may not survive cancellation. A formula displaying a quadratic term need not define a function of minimal degree two.

The present study resolves both issues for the proposed one-dimensional map. The finite map is exactly the identity, not merely conjugate to it. Moving the pole does not produce a nontrivial family. The map genuinely possesses the requested quadratic-over-linear presentation, but it also has a linear presentation, refuting the stronger minimal-degree claim. The compactified source cannot be homeomorphic to the noncompact real line.

The argument is elementary but structurally useful. It isolates three principles relevant to broader tropical constructions:

1. projective normalization may erase parameters that appear geometrically meaningful before quotienting;
2. common max-plus factors can cancel between tropical numerator and denominator;
3. compactification changes the global topological category and therefore the admissible targets.

## 2. Max-plus preliminaries

### 2.1 Tropical arithmetic

We work over finite real tropical scalars unless compactification is stated explicitly. The max-plus operations are

$$
a\oplus b=\max(a,b),\qquad a\odot b=a+b.
$$

The tropical power $x^{\odot k}$ is the ordinary quantity $kx$. A one-variable tropical polynomial is a function of the form

$$
P(x)=\max_{0\leq i\leq m}(ix+a_i),
$$

where the coefficients $a_i$ are real. Such a function is convex and piecewise affine. A tropical rational function can be represented as a difference

$$
R(x)=P(x)-Q(x)
$$

of tropical polynomials. It is continuous and piecewise affine, though no longer necessarily convex.

The same function may have many presentations. In particular, the identity

$$
c+\max(u,v)=\max(c+u,c+v)
$$

allows common affine contributions to be factored out of maxima. When identical terms then occur in both $P$ and $Q$, subtraction cancels them. Accordingly, the largest displayed exponent in one presentation is not automatically an invariant of the represented function.

### 2.2 Finite tropical projective space

The finite tropical projective line is obtained from $\mathbb{R}^2$ by identifying pairs that differ by simultaneous translation.

> **Definition 2.1 (Finite tropical projective line).** Two pairs $(x_0,x_1)$ and $(y_0,y_1)$ are projectively equivalent when there exists $\lambda\in\mathbb{R}$ such that
> $$
> (y_0,y_1)=(x_0+\lambda,x_1+\lambda).
> $$
> The quotient is denoted $\mathbb{TP}^1_{\mathrm{fin}}$.

The coordinate difference

$$
\nu(x_0,x_1)=x_1-x_0
$$

is invariant under simultaneous translation. Conversely, every class has the unique representative $(0,x)$, where $x=x_1-x_0$. Thus $\nu$ identifies $\mathbb{TP}^1_{\mathrm{fin}}$ with $\mathbb{R}$. We equip the quotient with the topology transported through this normalized coordinate.

> **Proposition 2.2 (Normalized coordinate).** The map sending the projective class of $(x_0,x_1)$ to $x_1-x_0$ is a bijection from $\mathbb{TP}^1_{\mathrm{fin}}$ to $\mathbb{R}$. With the normalized-coordinate topology, it is a homeomorphism.

**Proof sketch.** Simultaneous translation leaves the difference unchanged, so the map is well defined. Every $x\in\mathbb{R}$ is represented by $(0,x)$, proving surjectivity. Equal differences imply that two pairs differ by the diagonal translation $\lambda=y_0-x_0$, proving injectivity. The topological statement follows from the definition of the normalized-coordinate topology. $\square$

### 2.3 Compactified convention

A second standard convention admits infinite coordinates before projectivization. In dimension one, the normalized compactified line is modeled by the extended real line

$$
\overline{\mathbb{R}}=[-\infty,+\infty]
$$

with its order topology. This space is compact. The ordinary real line is not compact.

> **Definition 2.3 (Compactified tropical projective line).** The compactified tropical projective line $\mathbb{TP}^1_{\mathrm{comp}}$ is the endpoint-completed normalized tropical line, identified topologically with $\overline{\mathbb{R}}$.

This convention is not interchangeable with the finite one when discussing global homeomorphisms.

## 3. The pole construction

### 3.1 The basic expression

The proposed inverse stereographic tropical lift in normalized coordinates is

$$
S(x)=\max(2x,x)-\max(x,0).
$$

The first maximum resembles a tropical polynomial containing a quadratic monomial and a linear monomial. The second resembles a tropical linear polynomial. This motivates the following presentation classes.

> **Definition 3.1 (Pole-shaped quadratic presentation).** A function $f:\mathbb{R}\to\mathbb{R}$ has a pole-shaped quadratic tropical presentation if there exist $a,b,c,d\in\mathbb{R}$ such that
> $$
> f(x)=\max(2x+a,x+b)-\max(x+c,d)
> $$
> for every $x\in\mathbb{R}$.

> **Definition 3.2 (Linear presentation).** A function $f:\mathbb{R}\to\mathbb{R}$ has a linear tropical presentation in normalized coordinate if there exists $c\in\mathbb{R}$ such that
> $$
> f(x)=x+c
> $$
> for every $x\in\mathbb{R}$.

The latter definition captures translations, the degree-at-most-one maps relevant here.

### 3.2 Global simplification

> **Theorem 3.3 (Identity theorem).** For every $x\in\mathbb{R}$,
> $$
> S(x)=x.
> $$

**Proof.** If $x\leq 0$, then $2x\leq x$ and therefore

$$
\max(2x,x)=x,
$$

while $\max(x,0)=0$. Hence $S(x)=x$.

If $x\geq 0$, then $2x\geq x$, so $\max(2x,x)=2x$, while $\max(x,0)=x$. Hence $S(x)=2x-x=x$. The two calculations agree at $x=0$, completing the proof. $\square$

The apparent breakpoint in each maximum does not produce a breakpoint in their difference. Both pieces have slope one after subtraction.

### 3.3 Arbitrary finite poles

Move the pole from $0$ to $p\in\mathbb{R}$ and define

$$
S_p(x)=\max(2x,x+p)-\max(x,p).
$$

> **Theorem 3.4 (Finite-pole rigidity).** For every $p,x\in\mathbb{R}$,
> $$
> S_p(x)=x.
> $$

**Proof.** Tropical distributivity, written in ordinary arithmetic, gives

$$
\max(2x,x+p)=\max(x+x,x+p)=x+\max(x,p).
$$

Consequently,

$$
S_p(x)=x+\max(x,p)-\max(x,p)=x.
$$

This identity holds without a case split. $\square$

> **Corollary 3.5 (Pole independence).** For all finite pole positions $p,q\in\mathbb{R}$, the functions $S_p$ and $S_q$ are equal.

**Proof sketch.** By Theorem 3.4, both functions equal the identity at every input. $\square$

The pole parameter is therefore absent from the represented normalized function. It appears only through a common max-plus factor.

## 4. Topological consequences

### 4.1 The finite homeomorphism

> **Theorem 4.1 (Finite tropical stereographic homeomorphism).** The map induced by
> $$
> S(x)=\max(2x,x)-\max(x,0)
> $$
> is a homeomorphism from $\mathbb{TP}^1_{\mathrm{fin}}$ to $\mathbb{R}$.

**Proof sketch.** Proposition 2.2 identifies the finite projective line with $\mathbb{R}$ through the normalized coordinate. Theorem 3.3 says that $S$ is the identity in this coordinate. It is therefore bijective, its inverse is the identity, and both maps are continuous. $\square$

The result should be interpreted precisely. It confirms that the proposed formula yields a tropical homeomorphism on the finite model. It does not provide a nontrivial analogue of classical pole-dependent stereography, because normalized finite pole position has already cancelled.

### 4.2 Compactness obstruction

> **Theorem 4.2 (No compactified-to-affine homeomorphism).** There is no homeomorphism
> $$
> \mathbb{TP}^1_{\mathrm{comp}}\longrightarrow\mathbb{R}.
> $$

**Proof.** By Definition 2.3, $\mathbb{TP}^1_{\mathrm{comp}}$ is compact. The continuous image of a compact space is compact. If a homeomorphism to $\mathbb{R}$ existed, its image would be all of $\mathbb{R}$, forcing $\mathbb{R}$ to be compact. Since $\mathbb{R}$ is noncompact, this is impossible. $\square$

The correct candidate codomain for compactified stereography is therefore an extended real line or another compact space, not ordinary $\mathbb{R}$.

## 5. Presentation degree and cancellation

### 5.1 Existence of a quadratic presentation

> **Proposition 5.1 (Quadratic-over-linear representability).** The function $S$ has a pole-shaped quadratic tropical presentation.

**Proof.** In Definition 3.1 choose

$$
a=b=c=d=0.
$$

The resulting expression is exactly

$$
\max(2x,x)-\max(x,0)=S(x).
$$

Thus the required presentation exists. $\square$

### 5.2 Existence of a linear presentation

> **Proposition 5.2 (Linear representability).** The same function $S$ has a linear presentation.

**Proof.** Theorem 3.3 gives $S(x)=x=x+0$ for every $x$. Hence Definition 3.2 holds with $c=0$. $\square$

> **Theorem 5.3 (Failure of minimal degree two).** It is false that $S$ is pole-shaped quadratic-presentable but not linearly presentable. In particular, the displayed quadratic term does not imply that the represented function has minimal tropical rational degree exactly two.

**Proof sketch.** Proposition 5.1 establishes the quadratic presentation, whereas Proposition 5.2 supplies a linear presentation. Therefore the asserted absence of a linear presentation is false. $\square$

This theorem concerns minimal presentation complexity, not the literal syntax of the original formula. The term $2x$ is genuinely present in that formula. What fails is the inference from that occurrence to an intrinsic degree-two invariant.

### 5.3 Common-factor interpretation

For the full pole family, write

$$
P_p(x)=\max(2x,x+p),\qquad Q_p(x)=\max(x,p).
$$

Then

$$
P_p(x)=x+Q_p(x).
$$

Thus the numerator is the denominator plus the affine function $x$. In max-plus language, $Q_p$ is a common tropical factor, and the rational difference cancels it. The numerator and denominator each bend at $x=p$, but their difference has no bend.

This suggests a representation-independent degree theory based on reduced forms. At minimum, such a theory should satisfy:

1. equal functions receive the same degree;
2. translations $x\mapsto x+c$ have degree at most one;
3. multiplication of numerator and denominator by the same tropical factor does not change degree;
4. breakpoints cancelled in the difference do not contribute to reduced complexity.

The example shows why raw numerator degree alone violates these requirements.

## 6. Algorithms and numerical diagnostics

Although the main identities are exact, computational procedures help expose the branch structure and guard against implementation mistakes.

### 6.1 Direct evaluation algorithm

Given $x\in\mathbb{R}$, evaluate

$$
S(x)=\max(2x,x)-\max(x,0).
$$

The algorithm uses two comparisons, constant-time arithmetic, and constant memory.

**Pseudocode**

```text
INPUT: real number x
numerator   <- max(2*x, x)
denominator <- max(x, 0)
RETURN numerator - denominator
```

A useful test table is

$$
\begin{array}{c|ccccc}
x&-3&-1&0&2&5\\ \hline
S(x)&-3&-1&0&2&5
\end{array}
$$

which samples the negative branch, breakpoint, and positive branch.

### 6.2 Pole-family evaluation

For a finite pole $p$, compute

$$
S_p(x)=\max(2x,x+p)-\max(x,p).
$$

**Pseudocode**

```text
INPUT: real pole p, real coordinate x
numerator   <- max(2*x, x+p)
denominator <- max(x, p)
RETURN numerator - denominator
```

This also requires constant time and memory. Testing a grid of values for $p$ and $x$ yields $S_p(x)-x=0$ up to floating-point roundoff. Exact arithmetic is preferable when inputs are rational.

### 6.3 Branch audit

A more explanatory diagnostic records which affine term dominates each maximum. If $x\leq p$, then

$$
\max(2x,x+p)=x+p,
\qquad
\max(x,p)=p,
$$

and their difference is $x$. If $x\geq p$, then

$$
\max(2x,x+p)=2x,
\qquad
\max(x,p)=x,
$$

and the difference is again $x$. Both component functions switch branch at the same point. This synchronized switching is the numerical signature of cancellation.

For a list of $n$ input values and $m$ poles, an exhaustive grid audit takes $O(nm)$ time and $O(1)$ auxiliary memory if results are streamed, or $O(nm)$ memory if the full table is retained.

## 7. Applications and interpretation

### 7.1 Tropical coordinate design

The finite projective quotient removes diagonal translation. Any proposed construction depending on absolute representatives must be checked after normalization. The pole-family result demonstrates that a parameter can be entirely gauge-dependent: moving $p$ changes the unreduced numerator and denominator but not their quotient function.

This matters when designing coordinates on tropical moduli spaces or metric graphs. A parameter visible in a chosen formula need not descend to the quotient as an observable. To preserve it, one may need a marking, a distinguished end, a metric normalization, or another structure not removed by projectivization.

### 7.2 Complexity of piecewise-linear models

Differences of maxima occur throughout optimization and piecewise-linear modeling. A max-affine component may have several regions even when the final difference is globally affine. Counting regions separately in numerator and denominator can therefore exaggerate functional complexity.

The present family provides an exact benchmark. Both $P_p$ and $Q_p$ have a breakpoint at $p$, while $P_p-Q_p$ has none. Algorithms for simplification, model compression, or symbolic equivalence should identify this shared breakpoint and cancel it.

### 7.3 Tropical Möbius transformations

In one dimension, an orientation-preserving affine map of slope one has the form $x\mapsto x+c$. The map studied here is the special case $c=0$. Thus it lies in the simplest possible part of any tropical Möbius classification.

A broader classification problem is to determine which functions

$$
R(x)=\max_i(a_i x+b_i)-\max_j(c_j x+d_j)
$$

are homeomorphisms of $\mathbb{R}$. Necessary conditions include continuity, strict monotonicity, and unbounded limits of opposite sign at the two ends. Their slopes on every linearity interval must be positive. For slope-one homeomorphisms, the cancellation behavior observed here raises the question whether reduced forms must always be translations.

### 7.4 Compactified targets

The compactness obstruction is a target-selection principle. If endpoints are included in the source, they must be accounted for in the codomain. A compactified coordinate map should take values in $\overline{\mathbb{R}}$ and describe the images of both ends explicitly. Merely reusing an affine target discards the global topology.

## 8. Discussion

### 8.1 Comparison with classical stereography

Classical stereographic projection has three features that should not be conflated in a tropical analogue: it supplies a global coordinate away from a pole, it depends on the chosen pole, and it carries conformal information. The present max-plus construction retains only the first feature. It supplies a global coordinate because it is the normalized coordinate itself. The second feature disappears by common-factor cancellation, while no claim of angle preservation is available in a one-dimensional piecewise-linear setting.

This comparison sharpens the scope of the result. Calling the map “stereographic” records the origin of the formula, not an assertion that every classical property survives tropicalization. A faithful higher-dimensional analogue may require a metric or harmonic condition in addition to tropical rationality.

### 8.2 Stability and exactness

The identity is algebraic and therefore stable under evaluation: it does not arise from an approximation or limiting process. Nevertheless, direct floating-point evaluation of two large, nearly equal maxima may suffer subtractive cancellation. For example, if $x$ and $p$ are extremely large, the intermediate numerator and denominator can be much larger than the output. A robust implementation may therefore return $x$ after recognizing the shared factor, rather than evaluating the unreduced expression.

This is an algorithmic benefit of symbolic reduction. It reduces the operation count, removes a branch, and avoids unnecessary loss of precision. The unreduced form remains valuable for auditing the geometry of the two components, but the reduced form is preferable for production computation.

### 8.3 Scope of the compactness argument

The topological obstruction uses no special algebraic property of the pole formula. It rules out every possible homeomorphism from the compactified source to $\mathbb{R}$, including maps not expressible tropically. Conversely, it does not obstruct continuous maps, embeddings into other spaces, or homeomorphisms to a compactified target. Its strength lies in cleanly separating an impossible choice of target from questions about formulas.

The proposed construction produces a mathematically valid finite homeomorphism, but not for the anticipated reason. Its displayed tropical degree suggests a nonlinear pole map. Reduction shows instead that it is the canonical normalized coordinate itself.

There are two complementary readings. The first is negative: the formula does not retain pole position and does not have minimal degree two. The second is constructive: the collapse identifies the exact common factor responsible for the degeneracy and gives a criterion for improving future definitions. A nontrivial tropical stereographic map must prevent the numerator and denominator from sharing all pole dependence after normalization.

The compactified result further clarifies the formulation. A statement about the finite quotient may be true while the analogous statement about an endpoint completion is impossible. Topological type must be fixed before degree, rationality, or conformal analogy is discussed.

The result is also an example of why tropical rational functions should be treated extensionally—as functions—rather than only intensionally—as displayed formulas. Syntactic data are useful for computation, but invariants must survive equivalent presentations.

## 9. Future directions

### 9.1 Higher-dimensional finite projective spaces

Define $\mathbb{TP}^n_{\mathrm{fin}}$ as the quotient of $\mathbb{R}^{n+1}$ by diagonal translation, choose a normalization, and test whether analogous pole expressions again collapse to affine maps. In dimensions above one, several coordinate differences survive, so pole cancellation may be partial rather than total.

### 9.2 Compactified codomains

The compactness obstruction shows that compactified $\mathbb{TP}^1$ cannot be homeomorphic to $\mathbb{R}$. A corrected target is $\overline{\mathbb{R}}$. One should construct and classify homeomorphisms

$$
\mathbb{TP}^1_{\mathrm{comp}}\longrightarrow\overline{\mathbb{R}}
$$

directly from the quotient model and track endpoint behavior.

### 9.3 Intrinsic tropical rational degree

Develop a representation-independent degree notion after cancellation of common tropical factors. The present example demonstrates that syntactic numerator degree is not intrinsic. Reduced breakpoint multiplicities or asymptotic slope data may contribute to an appropriate definition.

### 9.4 Pole degeneracy versus conformal information

Every finite pole yields the identity after normalized projectivization. Enriched structures—marked ends, metric graphs, harmonic morphisms, or additional incidence data—may preserve pole position. The challenge is to identify the least extra structure needed for a nontrivial analogue of conformal coordinates.

### 9.5 General tropical Möbius maps

Classify one-dimensional maps expressible as differences of maxima of affine forms and characterize exactly which are homeomorphisms. Determine whether every such homeomorphism of slope one is a translation after cancellation.

### 9.6 Max-plus and min-plus duality

Repeat the construction in the min-plus convention and establish equivalence under negation. The finite identities should transport directly, while compactified endpoints require careful reversal of $+\infty$ and $-\infty$.

## 10. Conclusion

The inverse stereographic tropical lift on the finite tropical projective line is governed by the identity

$$
\max(2x,x+p)-\max(x,p)=x.
$$

It follows that the map is a homeomorphism, every finite pole gives the same normalized transformation, and the quadratic-over-linear display does not represent minimal degree two. For the compactified projective line, no homeomorphism to the ordinary real line can exist because compactness is preserved by homeomorphism.

Together these results give a complete one-dimensional analysis of the proposed construction. They separate finite from compactified topology, displayed degree from intrinsic degree, and pole syntax from pole information. Any nontrivial higher-dimensional or enriched tropical stereography must be designed to survive precisely these three tests.
