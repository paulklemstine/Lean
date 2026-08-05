# The Shape of a Dictator

### What happens to Arrow's theorem when you change the arithmetic

---

## 1. A voting rule that refuses to be a person

Kenneth Arrow's impossibility theorem is the most famous negative result in the
social sciences, and its modern proof has an almost algebraic flavour. Start with
a voting rule satisfying a handful of innocuous-looking fairness conditions. Ask
which coalitions of voters are *decisive* — which groups, by agreeing among
themselves, already determine the outcome no matter what anybody else says. Then
discover that this family of decisive coalitions is not merely some collection of
subsets: it is an **ultrafilter**. For a finite electorate an ultrafilter is a
very rigid object — always the family of all coalitions containing one fixed
individual. That individual is the dictator.

Stripped to its combinatorial skeleton, Arrow's theorem says: *the axioms force
the decisive coalitions to be an ultrafilter, and on a finite electorate an
ultrafilter is a person.*

This article is about keeping the skeleton and changing the arithmetic underneath
it. Instead of profiles of *rankings*, take profiles of *scores* — a real number
$x_i$ for each voter, with lower meaning more critical. And instead of asking a
rule to respect the Boolean operations "and" and "or", ask it to respect an
exotic but well-studied arithmetic: the **tropical semiring**, in which
"addition" means taking the minimum and "multiplication" means ordinary addition.

The result is a small, complete, slightly surprising theory. Arrow's dictator
survives — but only as one point of a continuum. Around it lies a polyhedral
landscape of legitimate, non-dictatorial rules, and one can measure exactly how
far each is from being a person.

---

## 2. The arithmetic where minimum is addition

Tropical mathematics rests on a single act of vandalism against ordinary
algebra. Take the real numbers and declare:

$$a \oplus b = \min(a,b), \qquad a \odot b = a + b.$$

Everything you expect of a semiring holds: both operations are associative and
commutative, $\odot$ distributes over $\oplus$, the number $0$ is the unit for
$\odot$, and $+\infty$ is neutral for $\oplus$. What is lost is subtraction. What
is gained is a linear algebra of *piecewise-linear* objects: a "tropical linear
form" is $\min_{i \in S}(x_i + \delta_i)$, whose graph is a fan of hyperplane
pieces glued along creases. Tropical geometry is the geometry of such creases,
and it is the natural home for optimization, scheduling, discrete event systems,
and — as we shall see — for very deep neural networks, whose $\mathrm{ReLU}$
layers make them tropical rational functions in disguise.

Tropical arithmetic also has a physical pedigree. If you take ordinary positive
arithmetic and conjugate it by a logarithm at temperature $\varepsilon$,

$$a \oplus_\varepsilon b := -\varepsilon\log\!\left(e^{-a/\varepsilon} + e^{-b/\varepsilon}\right),$$

then as $\varepsilon \downarrow 0$ you get exactly $\min(a,b)$. This is *Maslov
dequantization*: the tropical world is the zero-temperature limit of the ordinary
world, in the sense in which classical mechanics is the $\hbar \to 0$ limit of
quantum mechanics. Machine learners know the formula as "softmin"; physicists
know it as the free energy of a system with energy levels $a_i$.

---

## 3. Three axioms for a social score

Fix a finite electorate. A **profile** is a vector $x = (x_i)$ of real scores,
one per voter. An **aggregator** is any function $F$ turning a profile into a
single social score. We impose exactly three conditions.

**Tropical additivity.** Merge two profiles by taking the worse of each voter's
two scores; the merger's social score is the worse of the two social scores:
$$F(x \wedge y) = \min\bigl(F(x), F(y)\bigr),$$
where $(x\wedge y)_i = \min(x_i,y_i)$. This is the tropical analogue of
*linearity*. Socially: criticism composes.

**Translation equivariance.** Adding the same constant $c$ to everybody's score
adds $c$ to the social score, $F(x + c\mathbf 1) = F(x) + c$. This is
equivariance under tropical *scalar multiplication*: the rule measures relative,
not absolute, magnitudes, so $F$ is well defined on tropical projective space,
where profiles are identified up to a global shift.

**Normalization.** $F(\mathbf 0) = 0$: unanimous indifference gives indifference.

That is all. Notice what is *not* assumed: no anonymity, no continuity, no
monotonicity, no independence of irrelevant alternatives. Monotonicity comes
free: if $x \le y$ coordinatewise then $x \wedge y = x$, so
$F(x) = \min(F(x), F(y)) \le F(y)$.

---

## 4. Probing the rule with a dip

Here is the trick that unlocks everything. To interrogate an unknown aggregator,
poke it one voter at a time. Let $d_i(t)$ be the **dip profile**: score $t$ for
voter $i$, score $0$ for everybody else, and set $\varphi_i(t) = F(d_i(t))$ for
$t \le 0$. Monotonicity gives $t \le \varphi_i(t) \le 0$.

Now merge a dip with a constant profile at level $s$, where $t \le s \le 0$.
Coordinatewise, $d_i(t) \wedge s\mathbf 1$ has $t$ at $i$ and $s$ elsewhere —
precisely the dip $d_i(t-s)$ shifted up by $s$. The two axioms turn this into a
functional equation of startling rigidity:

$$\min\bigl(\varphi_i(t),\,s\bigr) \;=\; s + \varphi_i(t-s), \qquad t \le s \le 0.$$

Call voter $i$ **active** if some dip at $i$ moves the outcome, i.e.
$\varphi_i(t) < 0$ for some $t \le 0$. The functional equation forces a complete
dichotomy: if $i$ is inactive then $\varphi_i \equiv 0$, and no dip at $i$ ever
registers; if $i$ is active then there is a single constant $\delta_i \ge 0$ with
$\varphi_i(u) = \min(u + \delta_i, 0)$ for all $u \le 0$. So each voter is
described by exactly one number, a **threshold weight** $\delta_i \in [0,\infty]$
with $\infty$ meaning "inactive": voter $i$ is heard only once their score drops
more than $\delta_i$ below the crowd.

The second half of the argument reassembles a general profile from dips. Choose
$K$ larger than every $x_i$ and let $y^{(i)}$ have $x_i$ at voter $i$ and $K$
elsewhere. Then $x = \bigwedge_i y^{(i)}$, each $y^{(i)}$ is a translated dip, and
iterated tropical additivity transfers the minimum outside $F$. Evaluating each
term with the dip formula and letting $K$ absorb the irrelevant branches gives
the theorem.

> **Representation Theorem.** *Let $F$ be a normalized, translation-equivariant,
> minimum-preserving aggregator on a finite nonempty electorate. Then there is a
> nonempty coalition $S$ of voters and weights $\delta_i \ge 0$ for $i \in S$
> with $\min_{i\in S}\delta_i = 0$, such that*
> $$F(x) = \min_{i \in S}\ (x_i + \delta_i) \qquad \text{for every profile } x.$$
> *Moreover $S$ is exactly the set of active voters, and both $S$ and the weights
> $\delta$ are uniquely determined by $F$.*

Uniqueness is a one-line consequence of the dip calculus: any representation
predicts $F(d_i(t)) = \min(t+\delta_i, 0)$ if $i \in S$ and $0$ otherwise, so
pushing $t$ far enough down reads off both the membership and the weight.

Every rule satisfying the three axioms is therefore a **tropical linear form**:
a weighted minimum — the exact tropical counterpart of the fact that a linear
functional on $\mathbb{R}^n$ is a weighted sum, except that tropical linearity
forces the "coefficients" to be *additive offsets*.

---

## 5. The conjecture that was almost true

It is tempting to guess that the axioms force something simpler: that $F$ must be
a plain minimum of coordinates, $F(x) = \min_{i\in S} x_i$, with no weights at
all — a rule that can only ever *report somebody's score*. The guess is false,
and the counterexample is embarrassingly small. On two voters, set

$$W(x_0, x_1) = \min\bigl(x_0,\ x_1 + 1\bigr).$$

One checks directly that $W$ preserves coordinatewise minima, commutes with
diagonal shifts, and vanishes at the origin. But $W(1,-1) = \min(1, 0) = 0$ — a
number *nobody submitted*. No minimum of coordinate projections can do that,
since such a minimum always returns one of its inputs. Tropical weights are
genuinely permitted; the classification above is sharp, and the naive statement
is a strict overreach. What restores it is a fourth axiom, natural in social
choice and invisible in algebra:

> **Selectivity.** For every profile, the social score equals *some* individual
> score: $\forall x\ \exists i,\ F(x) = x_i$.

> **Corrected Classification.** *A selective tropical aggregator has all weights
> zero, hence is exactly a minimum of coordinate projections,
> $F(x) = \min_{i\in S} x_i$, over its unique support $S$.*

The tropical axioms alone give weighted minima; adding "the verdict must be
somebody's verdict" collapses the weights to zero. The weight $\delta_i$ measures
exactly how far the rule will speak in a voice that is nobody's.

---

## 6. Where Arrow reappears

Now bring in the notion that carries the classical proof. A coalition $C$ is a
**dependence set** for $F$ if the scores of its members already pin down the
outcome: whenever two profiles agree on $C$, they receive the same social score.
For a weighted minimum with support $S$ the answer is immediate and complete.

> **Dependence Theorem.** *The dependence sets of $F(x)=\min_{i\in S}(x_i+\delta_i)$
> are exactly the coalitions containing $S$. In other words, the family of
> decisive coalitions is the principal filter generated by the tropical support.*

One direction is obvious (if $C \supseteq S$ the formula only reads coordinates
in $C$); the other is the dip calculus again — if some $i \in S$ is missing from
$C$, a deep enough dip at $i$ changes the outcome while leaving $C$ untouched.
Principal filters are exactly the objects Arrow's argument produces, and now the
classical dichotomy becomes a statement about the *size* of $S$:

> **Tropical Arrow Theorem.** *For a normalized tropical aggregator, these are
> equivalent: (1) the decisive coalitions satisfy the ultrafilter dichotomy —
> every coalition is decisive or its complement is; (2) the aggregator is a
> dictatorship, $F(x) = x_{i_0}$; (3) the support $S$ is a singleton.*

The proof of $(1)\Rightarrow(3)$ is charming: if $S$ contained distinct voters
$a \ne b$, test the ultrafilter condition on $C = \{b\}^{\complement}$. Since
$b \in S \not\subseteq C$, $C$ is not decisive; since $a \in S \not\subseteq
\{b\}$, neither is its complement. So $S$ is a singleton, and normalization
forces its weight to be $0$.

The upshot is a tropical restatement of Arrow's phenomenon: *dictatorship is not
an accident of ranking-based frameworks; it is the statement that the support of
a tropical linear form has one element.* Said that way, the whole spectrum is
visible. Support of size $1$: dictator. Support of size $2$ with a nonzero
weight: our $W$ above, a perfectly legal non-dictatorial rule. Support of size
$n$ with all weights zero: the unanimity rule $\min_i x_i$ — forced by symmetry:

> **Anonymity Theorem.** *If a normalized tropical aggregator is invariant under
> relabelling the electorate, then its support is everybody and all its weights
> vanish; that is, $F(x) = \min_i x_i$. In particular an anonymous tropical rule
> is never a dictatorship once there are at least two voters.*

---

## 7. How undemocratic is a rule? An exact answer

Here is where the tropical framework earns its keep. Classically, "anonymity is
incompatible with dictatorship" is qualitative; here it becomes a *measurement*.

Suppose the electorate has $n$ voters and the support has size $k$. Relabelling
moves $S$ through its orbit, which is precisely the family of all $k$-element
coalitions, of size $\binom{n}{k}$ — any two coalitions of the same size are
exchanged by some permutation. Of those $\binom{n}{k}$ coalitions, how many are
decisive? By the Dependence Theorem a coalition is decisive iff it contains $S$,
and the only $k$-set containing the $k$-set $S$ is $S$ itself. Exactly one.

> **Anonymity Defect Theorem.** *Let $F$ be a normalized tropical aggregator on
> $n$ voters with irredundant support of size $k$. Among the $\binom{n}{k}$
> coalitions in the permutation orbit of its minimal decisive coalition, exactly
> one — the support itself — is decisive. Hence the proportion of that orbit on
> which $F$ fails to be decisive is exactly*
> $$1 - \frac{1}{\binom{n}{k}} .$$
> *Being an identity rather than an inequality, the bound is sharp.*

Read the extremes. A dictator has $k = 1$ and defect $1 - 1/n$: nearly the whole
orbit of individuals is powerless, which is exactly what "dictator" should mean
quantitatively. A rule with $k = n$ has orbit size $1$ and defect $0$: unanimity
is perfectly symmetric. In between, the defect peaks near $k = n/2$ — the most
"arbitrary" rules are those whose decisive coalition is half the electorate.

---

## 8. The map of decisiveness

A weighted minimum is piecewise linear, so it comes with a geometry. For each
voter $i$ in the support, the profiles at which $i$ attains the social score form
the **chamber**

$$\mathcal{C}_i = \{x : x_i + \delta_i \le x_j + \delta_j \text{ for all } j \in S\},$$

an intersection of half-spaces, hence a convex polyhedron. The chambers cover the
whole profile space; on $\mathcal{C}_i$ the rule is the affine map
$x \mapsto x_i + \delta_i$; two chambers meet exactly along the *wall*
$x_i + \delta_i = x_j + \delta_j$; and $F$, a minimum of affine functions, is
concave.

Label each profile $x$ by its **decisive coalition**
$$D(x) = \{i \in S : x_i + \delta_i = F(x)\}.$$
This is always nonempty, and $i \in D(x)$ exactly when $x$ lies in the chamber of
$i$. The closed cell of a label $T$ — where everyone in $T$ is decisive — is
$\bigcap_{i\in T}\mathcal{C}_i$, again a convex polyhedron. Four facts complete
the picture.

**The label really is decisive, locally.** Raise the scores of everybody outside
$D(x)$ and leave $D(x)$ untouched: the social score does not budge. The label is
a decisive coalition in the honest, operational sense.

**Every coalition occurs.** For any nonempty $T \subseteq S$ there is a profile
with $D(x) = T$ — take $x_i = -\delta_i$ for $i \in T$ and $x_i = 1-\delta_i$
otherwise. So the cells are labelled *precisely* by the nonempty subcoalitions of
the support, and the labelling reverses inclusion: bigger coalitions sit on
smaller faces, and the cell of a union of labels is the intersection of the
cells. The face lattice *is* the lattice of subcoalitions, upside down.

**Codimension counts agreement.** The cell labelled $T$ lies in an affine
subspace directed by $\{v : v \text{ constant on } T\}$, of dimension
$n - |T| + 1$, so it has codimension exactly $|T| - 1$. The walls containing it
are exactly the pairs $(i,j)$ with $i,j \in T$ — the edges of the complete graph
on $T$ — and the $|T|-1$ walls of a *star* $\{(i,i_0) : i \in T\}$ already cut
the cell out of the chamber of $i_0$. In matroid language, the cell of $T$ is the
flat of the graphic matroid of $K_S$ spanned by the edges of $K_T$, of rank
$|T|-1$, and a star is a basis of it. The geometry of social decisiveness is the
geometry of a graphic matroid.

**One voter suffices to switch the outcome.** Start at any profile in the chamber
of $i$. Change the score of the single voter $j$ to $x_i + \delta_i - \delta_j$:
you land exactly on the wall between the chambers of $i$ and $j$, where both are
decisive. Lower $j$'s score by any further $\varepsilon > 0$ and $j$ becomes the
*unique* decisive voter. Two top-dimensional cells are always joined by an
exchange of a single voter's score, mirroring the basis-exchange axiom of the
underlying matroid. No coalition needs to coordinate.

---

## 9. The classical limit

Why should anyone believe that tropical rules describe anything real? Because
they are the zero-temperature limit of rules that are entirely ordinary. Fix a
support $S$ and weights $\delta$, and for $\varepsilon > 0$ define the smooth,
strictly positive, real-analytic aggregator

$$F_\varepsilon(x) = -\varepsilon \log \sum_{i \in S} \exp\!\left(-\frac{x_i+\delta_i}{\varepsilon}\right).$$

This is a completely classical object — a free energy, a softmin, the
log-partition function of a Gibbs measure at temperature $\varepsilon$. Bounding
the sum below by its largest term and above by $|S|$ copies of it gives an
explicit two-sided estimate:

> **Dequantization Sandwich.** *For all $\varepsilon > 0$ and all profiles,*
> $$F(x) - \varepsilon \log |S| \ \le\ F_\varepsilon(x) \ \le\ F(x),
> \qquad F(x) = \min_{i\in S}(x_i+\delta_i).$$

Consequently $|F_\varepsilon(x) - F(x)| \le \varepsilon \log|S|$ *uniformly in
the profile*: the classical family converges to the tropical rule at a rate
depending only on the size of the support, not on the electorate's opinions.

And now the last surprise, which ties the analysis back to Arrow:

> **Exactness Theorem.** *The smoothed family agrees with its tropical limit —
> $F_\varepsilon = F$ for every temperature $\varepsilon > 0$ and every profile —
> if and only if $|S| = 1$, i.e. if and only if $F$ is a dictatorship.*

The proof is a single evaluation. At the profile $x_i = -\delta_i$ all tropical
monomials are zero, so $F(x) = 0$, while $F_\varepsilon(x) = -\varepsilon\log|S|$.
These agree iff $\log |S| = 0$.

Dictatorship is thus the *rigid* point of the theory: the unique rule surviving
the passage from classical to tropical arithmetic without deformation. Every
other legitimate aggregator carries a nonzero "entropy" $\varepsilon \log|S|$
measuring how far decisiveness is shared. A dictator is a rule with no entropy.

---

## 10. Why this is more than a pun

Three things make this bridge worth crossing.

First, it recasts Arrow's theorem as a statement about the *support of a linear
form*, a notion that transfers to any semiring. Ultrafilters, principal filters,
dictatorships, and coalition sizes all become facts about a single finite set
$S$. Once dictatorship is "the support has one element", the question "how far
from dictatorial?" has an answer with a number attached: $|S| = k$, defect
$1 - 1/\binom{n}{k}$, entropy $\log k$.

Second, the objects involved are exactly the objects of modern piecewise-linear
computation. A tropical linear form is a single $\min$-pooling unit; a network of
$\mathrm{ReLU}$s is a tropical rational function; the chamber complex above is
what the machine-learning literature calls the *linear region decomposition* of
such a network. The face lattice, the codimension formula $|T|-1$, and the
single-voter exchange law describe how that decomposition is organized, and the
softmin sandwich $0 \le F - F_\varepsilon \le \varepsilon \log|S|$ is the
standard smoothing bound used to make min-pooling differentiable.

Third, it makes the classical limit a *theorem* rather than a metaphor.
"Dictatorships are exactly the aggregators stable under dequantization" is a
checkable equivalence between an analytic property and a combinatorial one.
Traffic runs both ways: tropical algebra tells social choice how to measure its
impossibility, and social choice hands tropical geometry a family of polyhedral
complexes with an unexpectedly rich combinatorial labelling.

The dictator, it turns out, has a shape. It is a point: a support of size one, a
chamber that is everything, an entropy of zero, and a defect of $1 - 1/n$. All
the other rules are the rest of the polytope.
