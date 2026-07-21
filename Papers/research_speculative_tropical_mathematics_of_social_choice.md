# Tropical Social Aggregation: Ultrafilter Dictatorship and the Non-Dictatorial Minimum Rule

**Aristotle**  
**July 21, 2026**

## Abstract

We study real-valued social aggregation in the min-plus tropical setting. A profile is a function $x:V\to\mathbb{R}$ on a finite electorate $V$, and an aggregator is a map $f:\mathbb{R}^V\to\mathbb{R}$. Weak tropical linearity consists of preservation of coordinatewise minima and equivariance under addition of a common constant. We distinguish this algebraic condition from a strong Arrow-style independence condition: the coalitions on which the aggregator depends are required to be exactly the members of an ultrafilter. Our main theorem states that every normalized, translation-equivariant aggregator satisfying this strong condition is a unique coordinate projection. The proof separates a finite combinatorial fact—every ultrafilter on a finite set is principal—from an algebraic rigidity lemma saying that singleton dependence, translation equivariance, and normalization force projection. If the decisive ultrafilter is fixed at the first voter, the unique aggregator is the first projection. In contrast, the binary minimum is normalized and weakly tropical-linear but is not either coordinate projection. It is a genuine min-plus expression and satisfies the associated concavity inequality. These results locate the dictatorship threshold precisely: it is not tropical min-linearity alone, but the upgrade from minimum preservation to ultrafilter-valued decisive dependence. We discuss algorithms for testing the laws on finite data, the polyhedral geometry of minimum aggregation, and a precise program for studying dequantization limits.

## 1. Introduction

Classical social choice studies procedures that combine individual preferences into a social outcome. Tropical mathematics suggests a related but distinct numerical model. Each voter supplies a real score, and society combines the resulting vector into one real number. In the min-plus convention, the operation playing the role of addition is minimum, while tropical scalar multiplication is ordinary addition by a constant. This convention is natural in shortest-path problems, scheduling, bottleneck analysis, and conservative risk assessment.

The guiding question is whether tropical analogues of familiar social-choice axioms force dictatorship. A first guess might be that a tropical linear social score must select a coordinate, and perhaps even a designated first coordinate. Both claims require care. Every coordinate projection satisfies the basic tropical laws, so no voter can be selected without additional data. More importantly, taking the minimum of two coordinates also satisfies the same weak laws and is not a projection at all.

The correct obstruction emerges at the level of decisive coalitions. For a coalition $S$, we ask whether agreement of two profiles on $S$ guarantees equal social scores. The sets with this property form an upward-closed family and encode which groups contain all information relevant to the aggregator. A strong Arrow-style condition requires that family to be an ultrafilter: a maximal coherent system choosing one side of every partition of the electorate.

On a finite electorate, every ultrafilter is principal and therefore concentrates on one voter. This standard combinatorial phenomenon becomes a dictatorship theorem once combined with translation equivariance and normalization. If the aggregator depends only on voter $d$, then an arbitrary profile can be replaced by the constant profile with value $x_d$; equivariance evaluates that constant profile, and normalization removes the additive offset.

This paper develops that argument from first principles. Its contributions are:

1. a finite tropical Arrow theorem identifying a unique dictatorial coordinate under ultrafilter-valued dependence;
2. a first-voter corollary under a specified principal ultrafilter;
3. a fully explicit non-dictatorial counterexample under weak tropical linearity, namely binary minimum;
4. an expression-theoretic interpretation and concavity theorem for that counterexample;
5. a conceptual separation between algebraic minimum preservation and strong coalition independence.

We do not assert an unspecified classical-limit theorem. Any comparison with ordinary aggregation must identify a deformation, a convergence topology, and a semantics relating scores to rankings. We instead formulate dequantization stability as a concrete future problem.

## 2. Tropical profiles and weak linearity

Let $V$ be a nonempty finite set of voters. A **score profile** is a function

$$
x:V\longrightarrow\mathbb{R}.
$$

The vector space of profiles is denoted $\mathbb{R}^V$. A **social score aggregator** is any map

$$
f:\mathbb{R}^V\longrightarrow\mathbb{R}.
$$

For profiles $x,y\in\mathbb{R}^V$, define their coordinatewise minimum $x\wedge y$ by

$$
(x\wedge y)_i=\min\{x_i,y_i\}
\qquad(i\in V).
$$

For $c\in\mathbb{R}$, write $x+c\mathbf{1}$ for the profile satisfying

$$
(x+c\mathbf{1})_i=x_i+c.
$$

The vector $\mathbf{1}$ is only notation for a common shift; no ordinary linear structure is required in the axioms below.

**Definition 2.1 (Weak tropical linearity).** An aggregator $f$ is weakly tropical-linear if, for all profiles $x,y$ and constants $c$,

$$
f(x\wedge y)=\min\{f(x),f(y)\},
$$

and

$$
f(x+c\mathbf{1})=f(x)+c.
$$

The first identity is preservation of tropical addition. The second is equivariance under tropical scalar multiplication. We use “weak” to emphasize that the two identities alone do not encode a decisive-coalition theory.

**Definition 2.2 (Normalization).** An aggregator $f$ is normalized if

$$
f(0)=0,
$$

where $0$ is the constant zero profile.

Translation equivariance immediately determines every constant profile up to $f(0)$:

$$
f(c\mathbf{1})=f(0)+c.
$$

Thus normalization gives $f(c\mathbf{1})=c$. This observation is the algebraic engine of the main theorem.

For each $d\in V$, define the **coordinate projection**

$$
p_d(x)=x_d.
$$

**Proposition 2.3 (Projection laws).** Every coordinate projection is normalized and weakly tropical-linear.

**Proof sketch.** Coordinate evaluation commutes with coordinatewise minimum:

$$
p_d(x\wedge y)=\min\{x_d,y_d\}=\min\{p_d(x),p_d(y)\}.
$$

It also commutes with translation:

$$
p_d(x+c\mathbf{1})=x_d+c=p_d(x)+c.
$$

Finally, $p_d(0)=0$. $\square$

This proposition already shows why “the first projection is uniquely tropical-linear” is false without a hypothesis identifying the first voter. Every $p_d$ has the same algebraic status.

## 3. Dependence and decisive ultrafilters

The key extra structure concerns information rather than arithmetic.

**Definition 3.1 (Dependence on a coalition).** Let $S\subseteq V$. An aggregator $f$ **depends only on $S$** if, for every $x,y\in\mathbb{R}^V$,

$$
\bigl(\forall i\in S,\ x_i=y_i\bigr)
\quad\Longrightarrow\quad
f(x)=f(y).
$$

Equivalently, coordinates outside $S$ can be changed arbitrarily without affecting the output. This does not mean that every member of $S$ is individually essential; it means only that $S$ contains all relevant information.

The family of sufficient coalitions is automatically upward closed: if $f$ depends only on $S$ and $S\subseteq T$, then agreement on $T$ implies agreement on $S$. It always contains $V$. A constant aggregator would also depend only on the empty set, but normalization and translation equivariance exclude constant aggregators.

**Definition 3.2 (Ultrafilter).** An ultrafilter $\mathcal U$ on $V$ is a family of subsets of $V$ such that:

1. $V\in\mathcal U$ and $\varnothing\notin\mathcal U$;
2. if $S,T\in\mathcal U$, then $S\cap T\in\mathcal U$;
3. if $S\in\mathcal U$ and $S\subseteq T$, then $T\in\mathcal U$;
4. for every $S\subseteq V$, exactly one of $S$ and $V\setminus S$ lies in $\mathcal U$.

The fourth property expresses maximality. For every binary division of the electorate, the ultrafilter designates one side as decisive.

**Definition 3.3 (Strong decisive-coalition compatibility).** An aggregator $f$ is strongly compatible with an ultrafilter $\mathcal U$ if, for every coalition $S\subseteq V$,

$$
S\in\mathcal U
\quad\Longleftrightarrow\quad
f\text{ depends only on }S.
$$

This biconditional is important. It says not merely that every ultrafilter member is sufficient, but that the ultrafilter exactly classifies all sufficient coalitions.

For $d\in V$, the **principal ultrafilter at $d$** is

$$
\mathcal U_d=\{S\subseteq V:d\in S\}.
$$

A projection $p_d$ depends only on every set containing $d$. Conversely, if $S$ does not contain $d$, two profiles can agree on $S$ while taking different values at $d$, so $p_d$ does not depend only on $S$. Hence the sufficient coalitions of $p_d$ are exactly $\mathcal U_d$.

## 4. Two rigidity lemmas

The main theorem factors into one combinatorial lemma and one algebraic lemma.

**Lemma 4.1 (Finite ultrafilters are principal).** Let $V$ be finite and let $\mathcal U$ be an ultrafilter on $V$. Then there exists a unique $d\in V$ such that

$$
\mathcal U=\mathcal U_d.
$$

**Proof sketch.** Because $V$ is finite, the intersection of all members of $\mathcal U$ is a finite intersection. Closure under intersections places this intersection, say $C$, in $\mathcal U$; therefore $C$ is nonempty. Choose $d\in C$. Every member of $\mathcal U$ contains $d$ by the definition of $C$.

It remains to show that every set containing $d$ lies in $\mathcal U$. If $d\in S$ but $S\notin\mathcal U$, the ultrafilter dichotomy gives $V\setminus S\in\mathcal U$. Since every ultrafilter member contains $d$, this would imply $d\in V\setminus S$, a contradiction. Thus $S\in\mathcal U$ exactly when $d\in S$.

For uniqueness, if both $d$ and $e$ generated the ultrafilter, then $\{d\}$ would belong to it and hence contain $e$, forcing $d=e$. $\square$

**Lemma 4.2 (Singleton dependence forces projection).** Let $f:\mathbb{R}^V\to\mathbb{R}$ be translation-equivariant and normalized. If $f$ depends only on the singleton $\{d\}$, then

$$
f=p_d.
$$

**Proof sketch.** Fix an arbitrary profile $x$. Let $z=x_d\mathbf{1}$ be the constant profile with value $x_d$. The profiles $x$ and $z$ agree at $d$. Singleton dependence therefore gives $f(x)=f(z)$. Translation equivariance yields

$$
f(z)=f(0+x_d\mathbf{1})=f(0)+x_d,
$$

and normalization makes the right-hand side $x_d$. Hence $f(x)=x_d$ for every $x$, which is precisely $f=p_d$. $\square$

Notice that preservation of coordinatewise minima is not needed in Lemma 4.2. Strong dependence, translation equivariance, and normalization already provide the rigidity.

## 5. The finite tropical Arrow theorem

We can now state the principal result.

**Theorem 5.1 (Finite Tropical Arrow Theorem).** Let $V$ be a finite electorate, let $\mathcal U$ be an ultrafilter on $V$, and let $f:\mathbb{R}^V\to\mathbb{R}$ be a normalized, weakly tropical-linear aggregator. Suppose that, for every $S\subseteq V$,

$$
S\in\mathcal U
\quad\Longleftrightarrow\quad
f\text{ depends only on }S.
$$

Then there exists a unique voter $d\in V$ such that

$$
f(x)=x_d
\qquad\text{for every }x\in\mathbb{R}^V.
$$

**Proof sketch.** By Lemma 4.1, $\mathcal U$ is principal at a unique $d\in V$. In particular, $\{d\}\in\mathcal U$. Strong compatibility says that $f$ depends only on $\{d\}$. Lemma 4.2 then gives $f=p_d$.

To verify uniqueness directly, suppose $f=p_e$ as well. Strong compatibility for $\{e\}$ shows $\{e\}\in\mathcal U=\mathcal U_d$, so $d\in\{e\}$ and hence $d=e$. Equivalently, distinct projections can be separated by a profile assigning different scores to their selected coordinates. $\square$

The theorem is best understood as a two-stage mechanism. The ultrafilter chooses a voter; tropical translation and normalization evaluate the chosen coordinate exactly. Minimum preservation is compatible with the conclusion but does not drive it.

**Corollary 5.2 (First-projection uniqueness under a fixed decisive system).** Let $n\ge1$, label the voters by $1,\ldots,n$, and let $\mathcal U_1$ consist of precisely the coalitions containing voter $1$. If a normalized, weakly tropical-linear aggregator has sufficient coalitions exactly $\mathcal U_1$, then

$$
f(x_1,\ldots,x_n)=x_1
$$

for every profile.

**Proof sketch.** The singleton $\{1\}$ belongs to $\mathcal U_1$, so the aggregator depends only on the first coordinate. Lemma 4.2 applies with $d=1$. $\square$

The explicit hypothesis on $\mathcal U_1$ is indispensable. Without it, symmetry provides no reason to prefer voter $1$ over any other voter.

## 6. Weak axioms permit non-dictatorial aggregation

We now show that weak tropical linearity alone does not imply dictatorship. Take $V=\{1,2\}$ and define

$$
m(x_1,x_2)=\min\{x_1,x_2\}.
$$

**Theorem 6.1 (Binary minimum is weakly tropical-linear).** The aggregator $m$ is normalized, preserves coordinatewise minima, and is translation-equivariant.

**Proof sketch.** Normalization is immediate:

$$
m(0,0)=0.
$$

For translation equivariance,

$$
m(x_1+c,x_2+c)=\min\{x_1+c,x_2+c\}=\min\{x_1,x_2\}+c.
$$

For minimum preservation, let $x=(x_1,x_2)$ and $y=(y_1,y_2)$. Then

$$
m(x\wedge y)
=\min\{\min(x_1,y_1),\min(x_2,y_2)\}.
$$

Both sides of the desired identity are the minimum of the same four numbers $x_1,x_2,y_1,y_2$, merely parenthesized differently. Therefore

$$
m(x\wedge y)=\min\{m(x),m(y)\}.
$$

$\square$

**Theorem 6.2 (Binary minimum is non-dictatorial).** Neither coordinate projection equals $m$ on all profiles.

**Proof sketch.** On the profile $(1,0)$,

$$
m(1,0)=0\ne1=p_1(1,0).
$$

On the profile $(0,1)$,

$$
m(0,1)=0\ne1=p_2(0,1).
$$

Thus $m\ne p_1$ and $m\ne p_2$. $\square$

The sufficient-coalition family explains why this does not contradict Theorem 5.1. The full coalition $\{1,2\}$ certainly determines $m$. Neither singleton does: fixing $x_1$ while varying $x_2$ across values below $x_1$ changes the minimum, and symmetrically for $x_2$. Therefore the family of sufficient coalitions is

$$
\bigl\{\{1,2\}\bigr\}.
$$

This is the principal filter generated by the two-element support, but it is not an ultrafilter. In particular, it chooses neither side of the partition $\{1\}\sqcup\{2\}$. The precise threshold is now visible: minimum preservation permits multi-coordinate support, whereas ultrafilter dependence forces singleton support.

## 7. Min-plus expressions and concavity

A min-plus expression is built from coordinate variables using minimum and addition of constants. Binary minimum is the simplest nontrivial example:

$$
m(x_1,x_2)=x_1\oplus x_2,
$$

where $a\oplus b=\min\{a,b\}$ denotes tropical addition. This expression viewpoint connects social aggregation to piecewise-linear geometry.

**Theorem 7.1 (Concavity of binary minimum).** For all $x,y\in\mathbb{R}^2$ and all $t\in[0,1]$,

$$
m((1-t)x+ty)
\ge
(1-t)m(x)+tm(y).
$$

**Proof sketch.** For each coordinate $j\in\{1,2\}$, one has $x_j\ge m(x)$ and $y_j\ge m(y)$. Since $1-t\ge0$ and $t\ge0$,

$$
(1-t)x_j+ty_j
\ge
(1-t)m(x)+tm(y).
$$

The right-hand side is therefore a common lower bound for both coordinates of $(1-t)x+ty$. Their minimum is at least that bound, proving the inequality. $\square$

The inequality can be strict. For example, take $x=(0,4)$, $y=(3,1)$, and $t=1/2$. Then

$$
m(x)=0,\qquad m(y)=1,
$$

while

$$
\frac{x+y}{2}=(1.5,2.5)
$$

and hence

$$
m\left(\frac{x+y}{2}\right)=1.5>0.5
=\frac{m(x)+m(y)}{2}.
$$

Geometrically, $m$ is linear on each of the two closed half-spaces $x_1\le x_2$ and $x_2\le x_1$. The diagonal $x_1=x_2$ is a tropical wall where the active coordinate changes. After quotienting by common translations, only the score difference $x_1-x_2$ remains, and the wall becomes the unique transition point between two decisiveness regions.

## 8. Algorithms and numerical diagnostics

The definitions are universal and exact, but finite numerical grids provide useful diagnostics for proposed aggregators.

### 8.1 Testing weak tropical linearity

Given a finite sample $G\subset\mathbb{R}^V$ and a finite set $C\subset\mathbb{R}$ of translation constants, evaluate the two residuals

$$
R_{\min}(x,y)
=
\left|f(x\wedge y)-\min\{f(x),f(y)\}\right|
$$

and

$$
R_{\mathrm{tr}}(x,c)
=
\left|f(x+c\mathbf{1})-f(x)-c\right|.
$$

The rule passes a tolerance-$\varepsilon$ test when every residual is at most $\varepsilon$. If $|G|=M$ and evaluating $f$ costs $T_f$, the pairwise minimum test costs $O(M^2(|V|+T_f))$, while the translation test costs $O(M|C|(|V|+T_f))$.

Passing such a test is evidence, not a universal proof, unless the domain has been reduced to a finite exhaustive set. Failure, however, supplies an explicit counterexample.

### 8.2 Testing coalition dependence on a grid

For each coalition $S\subseteq V$, partition the sampled profiles according to their restrictions to $S$. The grid version of dependence holds when $f$ is constant within every block. A direct comparison costs $O(2^{|V|}M^2|V|)$ across all coalitions; hashing profiles by restricted coordinate tuples reduces typical work to $O(2^{|V|}M|V|)$ plus aggregator evaluations.

For a projection $p_d$, the detected sufficient coalitions are exactly those containing $d$, provided the grid varies every coordinate independently. For binary minimum on a sufficiently rich grid, only the full two-voter coalition is detected.

### 8.3 Testing concavity

For finite profiles $x,y\in G$ and parameters $t$ in a finite set $T\subseteq[0,1]$, compute

$$
R_{\mathrm{conc}}(x,y,t)
=
m((1-t)x+ty)-(1-t)m(x)-tm(y).
$$

The theorem predicts $R_{\mathrm{conc}}\ge0$. This test costs $O(M^2|T||V|)$ for minimum aggregation. Plotting the residual or the piecewise-linear graph makes the chamber structure visible.

## 9. Applications and interpretation

Minimum aggregation is meaningful when low scores represent binding constraints or conservative evaluations. If voters are sensors reporting safety margins, the social minimum records the weakest margin. If they are departments estimating feasible deadlines, the interpretation depends on score conventions, but min-plus combinations naturally model earliest events and shortest costs. The same algebra underlies dynamic programming and network optimization.

The dictatorship theorem should therefore not be read as a blanket indictment of minimum-based aggregation. It identifies a structural incompatibility. A rule may combine several coordinates while preserving tropical operations, or its complete dependence system may be an ultrafilter on a finite electorate, but it cannot do both unless only one coordinate remains relevant.

This distinction parallels a broader methodological point in social choice. Numerical covariance laws and informational independence principles live at different levels. The former govern how scores transform; the latter govern which groups can determine outcomes. Treating one as a surrogate for the other can produce false uniqueness claims.

Anonymity also conflicts with the strong condition once $|V|\ge2$. A projection singles out its selected voter and is not invariant under permutations moving that voter. Since the finite theorem forces a projection, no strongly compatible normalized translation-equivariant rule can be anonymous for a nontrivial finite electorate. By contrast, binary minimum is anonymous under swapping its two coordinates, again demonstrating what becomes possible when ultrafilter dependence is weakened.

## 10. Relation to classical limits

Tropical operations often arise as limits of ordinary operations under logarithmic rescaling. For example, suitable log-sum-exp formulas approach maximum or minimum as a parameter tends to zero. Nevertheless, a statement that the present theorem “reduces to” a classical ranking theorem is not mathematically determined until three ingredients are fixed.

First, one needs a deformation $f_\varepsilon$ of ordinary aggregators and an explicit conjugacy between positive variables and tropical scores. Second, one needs a topology, such as local uniform convergence, in which $f_\varepsilon$ approaches $f$. Third, one needs a semantic map from cardinal scores to ordinal rankings and a corresponding interpretation of independence.

A precise stability conjecture is available. Suppose positive linear aggregators are conjugated by logarithmic dequantization and converge locally uniformly to a tropical aggregator. If their dependence systems are eventually ultrafilters, then only one coefficient should survive at the dominant exponential scale, forcing the limit to be a projection. Conversely, each tropical projection should arise from a stable one-coordinate family. This would provide a genuine bridge rather than a metaphorical one.

## 11. Discussion

The main theorem uses fewer algebraic assumptions than its tropical framing initially suggests. Once singleton dependence is known, translation equivariance and normalization suffice. This is informative rather than wasteful: it isolates the source of impossibility. The decisive-ultrafilter requirement performs the social-choice work, while tropical algebra calibrates the resulting one-dimensional rule.

The binary minimum marks the opposite endpoint. It has support of cardinality two, and its dependence sets form the principal filter generated by that support. This observation motivates a general representation problem. If every finite normalized minimum-preserving translation-equivariant aggregator were a finite minimum of coordinate projections, then each rule would have an irredundant support $A\subseteq V$ and the sufficient coalitions would be precisely the supersets of $A$. Such a filter is an ultrafilter exactly when $|A|=1$. The finite tropical Arrow theorem would then become the singleton case of a complete structural classification.

Caution is required: the representation statement is a conjecture, not used in the proved results. More general tropical semimodule homomorphisms may involve offsets or require careful treatment of projective normalization and the chosen domain. The conjecture is compelling because normalization removes a common additive ambiguity and because finite minima of coordinates visibly satisfy the weak axioms.

The polyhedral viewpoint offers another extension. A finite minimum of affine forms is concave and piecewise linear. Equality loci between competing forms create polyhedral walls; complementary regions record the active terms. In social language, those regions record which voters or coalitions attain the social score. Adjacency could then encode exchanges in active support. This geometric structure could make changes of decisiveness quantitatively and visually tractable.

## 12. Future work

Four directions appear especially natural.

**Classification of finite min-plus aggregators.** Determine whether every normalized, translation-equivariant, coordinatewise-minimum-preserving map on finite tropical projective space is a finite minimum of coordinate projections, and whether the irredundant coordinate set is unique.

**Ultrafilter support as the exact threshold.** Prove that a normalized tropical aggregator has an ultrafilter of dependence sets exactly when its unique irredundant tropical support has cardinality one. The current results establish the singleton endpoint and a two-coordinate counterexample.

**Dequantization stability.** Develop logarithmically conjugated families of positive linear aggregators and determine whether eventual ultrafilter dependence is equivalent to a singleton tropical limit support.

**Polyhedral chambers of decisiveness.** Construct the projective polyhedral complex associated with a finite min-plus aggregator, label cells by active support coalitions, and study whether adjacency obeys single-voter exchange laws.

## 13. Conclusion

Finite tropical social aggregation exhibits a clean boundary. Preservation of coordinatewise minima, common-translation equivariance, and normalization do not force dictatorship: binary minimum satisfies all three and uses both voters essentially. When the sufficient coalitions are required to form an ultrafilter, finiteness makes that ultrafilter principal. The selected singleton, together with equivariance and normalization, forces the aggregator to be exactly one coordinate projection. Fixing the principal ultrafilter at the first voter yields the first projection and no other rule.

Thus the decisive distinction is not between ordinary and tropical arithmetic. It is between weak algebraic compatibility and maximally coherent coalition independence. Tropical mathematics makes this distinction especially transparent: multi-coordinate minimum rules occupy concave polyhedral regions, while ultrafilter dependence collapses their support to a single point.
