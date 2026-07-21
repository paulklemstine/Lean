# When Voting Rules Enter the Tropics

## The algebraic border between compromise and dictatorship

Imagine a committee trying to turn many numerical opinions into one social score. Each voter assigns a real number to an option: perhaps a cost, a level of disapproval, a risk estimate, or a priority. The committee then applies a rule

$$
f:\mathbb{R}^V\longrightarrow\mathbb{R},
$$

where $V$ is the finite set of voters and a profile $x\in\mathbb{R}^V$ records the score $x_i$ supplied by voter $i$.

At first this looks like ordinary averaging. Tropical mathematics changes the basic arithmetic. In the min-plus convention, “addition” means taking a minimum, while adding an ordinary constant plays the role of tropical scalar multiplication. This is not an exotic game with symbols. Minimum-based systems appear whenever the bottleneck, cheapest route, earliest arrival, weakest link, or most cautious assessment controls an outcome. Scheduling, shortest-path algorithms, logistics, risk aggregation, and discrete-event systems all naturally speak this language.

The surprising question is political as well as algebraic: when does a tropical aggregation rule have to be a dictatorship, simply repeating one voter’s score? And when can several voters genuinely matter?

The answer reveals a sharp boundary. Two innocent-looking tropical laws allow a non-dictatorial rule. Dictatorship appears only after independence is strengthened into a precise theory of decisive coalitions.

## The tropical rules of the game

Given two profiles $x$ and $y$, define their coordinatewise minimum by

$$
(x\wedge y)_i=\min(x_i,y_i).
$$

An aggregator $f$ will be called **weakly tropical-linear** when it obeys two laws.

First, it preserves coordinatewise minima:

$$
f(x\wedge y)=\min\{f(x),f(y)\}.
$$

Second, it is equivariant under common translations:

$$
f(x+c\mathbf{1})=f(x)+c,
$$

where $\mathbf{1}$ is the all-ones profile. If every voter raises a score by the same amount, society’s score rises by exactly that amount. This is a natural tropical version of Pareto consistency: common shifts in the scale are respected.

We also impose **normalization**,

$$
f(0)=0.
$$

Normalization merely chooses an origin. Without it, a projection could be followed by an arbitrary additive offset.

The obvious dictatorial rules are the coordinate projections. For a chosen voter $d$,

$$
p_d(x)=x_d.
$$

Every projection preserves coordinatewise minima, commutes with common translations, and is normalized. Already this corrects one tempting but false slogan: the first voter is not inherently unique. Every voter supplies an equally valid projection unless some additional structure singles one out.

## Coalitions that contain all the information

To express strong independence, we ask which coalitions determine the social score. For a set $S\subseteq V$, say that $f$ **depends only on $S$** if any two profiles agreeing on $S$ receive the same social score. In symbols, whenever

$$
x_i=y_i\quad\text{for every }i\in S,
$$

we require $f(x)=f(y)$.

Such sets are information-sufficient coalitions. If $S$ determines the result, then every larger coalition does too. A dictatorship $p_d$ depends only on precisely those coalitions containing $d$.

The decisive-coalition principle used here requires these sufficient coalitions to form an **ultrafilter**. An ultrafilter $\mathcal U$ on $V$ is a family of subsets satisfying four rules: it contains $V$ but not the empty set; it is closed under intersections; it is upward closed; and, for every $S\subseteq V$, exactly one of $S$ and its complement $V\setminus S$ belongs to $\mathcal U$. The last condition makes the family maximally decisive: every proposed division of the electorate has a chosen side.

An aggregator is **strongly Arrow-compatible** with $\mathcal U$ when

$$
S\in\mathcal U
\quad\Longleftrightarrow\quad
f\text{ depends only on }S.
$$

This is much stronger than preserving minima. It does not merely constrain numerical outputs; it organizes all coalitions carrying enough information into a coherent, maximally decisive system.

## The finite tropical Arrow theorem

Here is the central result.

**Finite Tropical Arrow Theorem.** *Let $V$ be a finite electorate. Suppose $f:\mathbb{R}^V\to\mathbb{R}$ is normalized and translation-equivariant. If the coalitions on which $f$ depends are exactly the members of an ultrafilter on $V$, then there is a unique voter $d\in V$ such that*

$$
f(x)=x_d\qquad\text{for every profile }x.
$$

*In particular, adding preservation of coordinatewise minima does not change the conclusion.*

The proof has two clean steps. The first is combinatorial. Every ultrafilter on a finite set is **principal**: there is a unique voter $d$ such that

$$
S\in\mathcal U\quad\Longleftrightarrow\quad d\in S.
$$

Why? Intersect all members of the ultrafilter. Finiteness ensures that this remains a member and is nonempty. It cannot contain two distinct voters, because the ultrafilter must choose between a singleton containing one of them and its complement. Thus one voter survives as the common point of every decisive coalition.

The second step is algebraic. Since the singleton $\{d\}$ is decisive, $f$ depends only on coordinate $d$. Compare an arbitrary profile $x$ with the constant profile $x_d\mathbf{1}$. They agree at $d$, so

$$
f(x)=f(x_d\mathbf{1}).
$$

Translation equivariance and normalization give

$$
f(x_d\mathbf{1})=f(0)+x_d=x_d.
$$

Therefore $f=p_d$. Uniqueness follows because two distinct coordinate projections disagree on a profile that separates their coordinates.

If the ultrafilter is fixed in advance to the coalitions containing the first voter, then $d$ is the first voter and the social score is exactly the first coordinate. This is the correct sense in which the first projection is unique: not by symmetry, but because the decisive structure explicitly selects it.

## The escape hatch: minimum aggregation

What happens if we retain the tropical algebra but abandon ultrafilter decisiveness? With two voters, consider

$$
m(x_1,x_2)=\min(x_1,x_2).
$$

This rule is normalized. It respects common translations because

$$
\min(x_1+c,x_2+c)=\min(x_1,x_2)+c.
$$

It also preserves coordinatewise minima. Taking the minimum within each coordinate and then across coordinates is the same as taking the minimum of all four numbers, regardless of the order in which the operations are performed.

Yet $m$ is not a projection. At $(0,1)$ it equals $0$, disagreeing with the second projection; at $(1,0)$ it again equals $0$, disagreeing with the first projection. Thus:

**Non-Dictatorial Tropical Aggregation Theorem.** *The binary minimum is a normalized, weakly tropical-linear social score, but it is not the projection onto either voter.*

This is more than a counterexample. It identifies exactly what weak tropical axioms fail to encode. The minimum depends only on the full coalition $\{1,2\}$, but not on either singleton. Its sufficient coalitions therefore do not form an ultrafilter. Algebraic minimum preservation is not the same thing as Arrow-style independence.

## A geometric bonus: concavity

The minimum rule is also a genuine min-plus expression, built by tropical addition from the two coordinate variables. That grants it a familiar geometric property.

**Concavity Theorem.** *For profiles $x,y\in\mathbb{R}^2$ and $0\le t\le1$,*

$$
m((1-t)x+ty)\ge(1-t)m(x)+tm(y).
$$

The proof follows from two elementary inequalities. Each coordinate of $(1-t)x+ty$ is at least $(1-t)m(x)+tm(y)$, because $x_i\ge m(x)$ and $y_i\ge m(y)$. Taking the minimum over the two coordinates preserves that lower bound.

Geometrically, the graph of $m(x_1,x_2)$ consists of two flat planes meeting along the wall $x_1=x_2$. On one side voter $1$ supplies the minimum; on the other, voter $2$ does. The wall is where decisiveness changes hands. This small picture hints at a broader polyhedral theory in which regions of score space are labeled by the coalitions currently controlling a tropical expression.

## What this says—and what it does not

The lesson is not that tropical voting evades every impossibility theorem. Rather, it separates two notions too easily conflated.

Weak tropical linearity is an algebraic condition. It says that the aggregator respects minima and common changes of scale. Under those rules, compromise-like multi-voter mechanisms exist; binary minimum is the simplest.

Strong decisive-coalition independence is combinatorial. It says that all sufficient coalitions form an ultrafilter. On a finite electorate, that condition selects one voter, and normalization plus translation equivariance turns selection into exact projection.

No automatic “classical limit” should be inferred from this alone. Connecting tropical and ordinary aggregation requires a specified deformation, such as logarithmic dequantization, a topology of convergence, and a semantics translating numerical scores into rankings. Without those choices, the phrase “reduces to the classical theorem” is ambiguous. A promising precise question is whether families of ordinary positive linear aggregators whose dependence systems stabilize as ultrafilters can converge only to tropical projections.

## A map of the frontier

Several avenues now become visible. One may seek to classify all finite normalized aggregators preserving minima and translations. A natural conjecture is that each is a finite minimum of selected coordinates, with a unique irredundant support. If so, the sufficient coalitions would form the principal filter generated by that support, becoming an ultrafilter exactly when the support has one voter. That would make dictatorship not merely one endpoint, but a one-element-support phase of a complete tropical classification.

The geometry also invites exploration. Min-plus expressions divide projective score space into polyhedral chambers according to which coordinates or monomials attain the minimum. Those chambers could provide a visual atlas of social decisiveness: moving across a wall changes the controlling coalition.

Tropical mathematics therefore does not erase the conflict between fairness and decisiveness. It sharpens it. Minimum-based algebra permits collective rules, but maximal coalition independence collapses them to a single coordinate. Between those poles lies a rich landscape of supports, filters, and polyhedral regions—a mathematical territory where the architecture of a voting rule can be seen as both algebra and geometry.
