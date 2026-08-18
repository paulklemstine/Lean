# The Arithmetic of Overlap: What Pairwise Statistics Can and Cannot Tell You

## A committee that keeps making the same mistake

Imagine you have trained twelve classifiers on the same dataset of a million
images. Each one is good: each misclassifies only $1\%$ of the images — ten
thousand mistakes apiece. You would like to know how many images the *committee*
gets wrong, in the weakest possible sense: how many images are misclassified by
**at least one** member.

There are two extreme answers, and they are very far apart.

If the twelve classifiers fail on completely different images — their errors are
perfectly *decorrelated* — the committee's total error support is
$12 \times 10{,}000 = 120{,}000$ images, a full $12\%$ of the data. That sounds
bad, but it is actually the *good* case: it means a majority vote will almost
always be right, because at most one member is ever wrong at a time.

If instead all twelve classifiers fail on exactly the same ten thousand images,
the committee's error support is only $10{,}000$ images, a mere $1\%$. That
sounds great, and it is a disaster: on those ten thousand images *every single
member is wrong*, and no amount of voting, averaging, or boosting will save you.

The number you can actually measure in practice sits between these poles. You
can measure each individual error rate $|A_i|$, where $A_i$ is the set of images
on which classifier $i$ fails. With a bit more effort you can measure every
*pairwise co-failure rate* $|A_i \cap A_j|$ — how often classifiers $i$ and $j$
are wrong together. These are the **first and second marginals** of the family
of error sets. The question this article is about is deceptively simple:

> **How much does the first- and second-order data tell you about the union
> $\left|\bigcup_i A_i\right|$?**

The answer turns out to be a complete, and completely satisfying, story. There
is an exact bookkeeping identity that converts pairwise data into union data
with a computable error term; the error term is a sum of squares, which is why
all the classical inequalities in this area are inequalities; and the families
on which the error term vanishes can be characterised exactly. But there is also
a hard limit: second-order data provably *cannot* determine the union, and no
cleverer argument will ever change that. Below we make all of this precise.

---

## One function to rule them all

The trick that unlocks everything is to stop thinking about sets and start
thinking about a single integer-valued function on the ground set.

Fix a finite ground set $\Omega$ (the samples) and a finite family
$A_1, \dots, A_k \subseteq \Omega$ (the bad events). Define the **multiplicity**

$$d(x) \;=\; \#\{\, i : x \in A_i \,\},$$

the number of family members that contain the point $x$. Write

$$U \;=\; \bigcup_{i} A_i$$

for the **cover** — the set of points hit at least once, equivalently
$\{x : d(x) \geq 1\}$.

Now observe two things. If you sum $d$ over the cover, you are counting each
pair $(i, x)$ with $x \in A_i$ exactly once, so

$$\boxed{\;\sum_{x \in U} d(x) \;=\; \sum_{i} |A_i|\;}$$

— the **first moment** of the multiplicity is the sum of the first marginals. If
instead you sum $d^2$, you are counting each triple $(i, j, x)$ with
$x \in A_i \cap A_j$ exactly once, so

$$\boxed{\;\sum_{x \in U} d(x)^2 \;=\; \sum_{i, j} |A_i \cap A_j|\;}$$

— the **second moment** of the multiplicity is the total pairwise-overlap mass,
summed over all ordered pairs including the diagonal. Peeling off the diagonal
terms $|A_i \cap A_i| = |A_i|$ and using the first identity gives the
off-diagonal version:

$$\sum_{i \neq j} |A_i \cap A_j| \;=\; \sum_{x \in U} d(x)\bigl(d(x) - 1\bigr).$$

That is the whole toolkit. Every classical inequality about unions and pairwise
intersections is now a statement about the first two moments of one function,
and can be derived by choosing a pointwise inequality for $d$ and summing it.
Let us do exactly that, three times.

---

## Inequality one: the union bound, with an exact error term

For any nonnegative integer $d$ we have the schoolbook identity
$2d = 1 + d^2 - (d-1)^2$. Summing this over $x \in U$ and substituting the two
moment identities produces something much stronger than an inequality — an
**exact identity**:

> **The Bonferroni Defect Identity.** For every finite family of finite sets,
> $$\sum_i |A_i| \;+\; \sum_{x \in U} \bigl(d(x) - 1\bigr)^2 \;=\; |U| \;+\; \sum_{i \neq j} |A_i \cap A_j|.$$

The middle term — call it the **irregularity** of the family — is a sum of
squares, hence nonnegative, and dropping it yields the classical *second
Bonferroni inequality*

$$\sum_i |A_i| \;\leq\; \Bigl|\bigcup_i A_i\Bigr| \;+\; \sum_{i \neq j} |A_i \cap A_j|.$$

But the identity says much more than the inequality. It tells you *exactly* what
you lose. The Bonferroni slack is the total squared deviation of the
multiplicity function from the value $1$. In particular:

> **Rigidity of the union bound.** Equality holds in the second Bonferroni
> inequality if and only if $d(x) = 1$ for every covered point $x$ — that is, if
> and only if the family is **pairwise disjoint**.

For the ensemble-learning reader: *the union bound is lossless precisely when no
two members of your ensemble ever fail on the same sample.* Every bit of slack
in the union bound is literally a sum of squared over-coverages.

Sharpening the pointwise inequality sharpens the theorem. The classical
statement of the second Bonferroni inequality is stronger by a factor of two on
the correction term, because it sums over *unordered* pairs $i < j$. That
version also comes with an exact defect:

> **The Sharp Bonferroni Defect Identity.**
> $$2\sum_i |A_i| \;+\; \sum_{x \in U} \bigl(d(x) - 1\bigr)\bigl(d(x) - 2\bigr) \;=\; 2|U| \;+\; \sum_{i \neq j} |A_i \cap A_j|,$$
> hence $\displaystyle \sum_i |A_i| - \sum_{i<j} |A_i \cap A_j| \le \Bigl|\bigcup_i A_i\Bigr|$,
> with equality **if and only if no point is covered three or more times**.

The defect has changed shape in an illuminating way. It is no longer the squared
distance of $d$ from the single value $1$, but the *second factorial deviation*
$(d-1)(d-2)$, which vanishes on the whole interval $\{1, 2\}$ and is positive
outside it. So the extremal class has widened from "pairwise disjoint" to
"multiplicity at most two". The sharp union-bound correction is exactly lossless
for ensembles in which no sample is misclassified by three or more members;
beyond that regime it over-counts, by a quantity you can now compute.

---

## Inequality two: how many samples are contested?

Here is a second, differently flavoured question. Let

$$D \;=\; \{\, x \in U : d(x) \geq 2 \,\}$$

be the set of **double collisions** — the samples on which at least two members
fail simultaneously. These are the genuinely dangerous samples: a single
dissenting classifier is outvoted, but a coalition of two is the seed of a
correlated failure. How large can $D$ be, given only the pairwise data?

Apply the pointwise inequality $2 \le d(d-1)$, valid whenever $d \ge 2$, and sum
over $D$; then extend the sum to all of $U$, which only helps because the
summand is nonnegative:

> **The Double-Collision Bound.**
> $$2\,|D| \;\leq\; \sum_{i \neq j} |A_i \cap A_j|,$$
> with equality **if and only if no point is covered three or more times**.

Notice that this is the *same* extremal class as for the sharp Bonferroni
inequality. That is not a coincidence — the two inequalities are equivalent
reformulations of each other, and the whole second-order layer of the theory has
exactly one extremal family type: multiplicity-$\le 2$ covers. A family whose
pairwise co-failure mass is small can have only a few contested samples, and the
bound is exactly right unless three members conspire somewhere.

---

## Inequality three: Cauchy–Schwarz beats Bonferroni

The Bonferroni route throws away information: it compares $d$ to the fixed
number $1$. If your family is far from a partition — if the typical multiplicity
is $5$, say — comparing to $1$ is wasteful. The natural fix is to compare $d$ to
*its own average*, which is what Cauchy–Schwarz does.

The mechanism is the **Lagrange identity**: for any finite set $S$ and any
function $f : S \to \mathbb{Z}$,

$$2\Bigl(|S| \sum_{x \in S} f(x)^2 - \Bigl(\sum_{x\in S} f(x)\Bigr)^{\!2}\Bigr) \;=\; \sum_{x \in S}\sum_{y \in S}\bigl(f(x) - f(y)\bigr)^2 .$$

The right-hand side is manifestly nonnegative, so the left-hand side is too.
Applying this with $S = U$ and $f = d$, and substituting the two moment
identities, gives:

> **The Second-Moment (Cauchy–Schwarz) Bound.**
> $$\Bigl(\sum_i |A_i|\Bigr)^{\!2} \;\leq\; \Bigl|\bigcup_i A_i\Bigr| \cdot \sum_{i,j} |A_i \cap A_j|,$$
> with equality **if and only if the multiplicity function is constant on the
> cover** — that is, if and only if the family is a *regular cover*.

Three inequalities, three extremal classes, each strictly larger than the last:
*pairwise disjoint* $\subset$ *multiplicity at most two* — and, orthogonally,
*perfectly regular*. The bound to reach for depends on which of these your data
is closest to.

Rearranged, the second-moment bound is a **lower bound on the union**, and this
is where it earns its keep in applications. Suppose every set is large,
$|A_i| \geq m$, and every pairwise overlap is small, $|A_i \cap A_j| \leq t$ for
$i \neq j$. Then with $k$ sets:

> **Corrádi's Inequality.** $\displaystyle k\,m^2 \;\leq\; \Bigl|\bigcup_i A_i\Bigr| \cdot \bigl(m + (k-1)\,t\bigr)$, i.e.
> $$\Bigl|\bigcup_i A_i\Bigr| \;\geq\; \frac{k\,m^2}{m + (k-1)t}.$$

Read this as an ensemble statement: *$k$ hypotheses that each fail on at least
$m$ samples and pairwise co-fail on at most $t$ must jointly fail on at least
$km^2/(m + (k-1)t)$ distinct samples.* When $t = 0$ this reads $|U| \ge km$, the
disjoint case. When $t = m$ it reads $|U| \ge m$, the totally correlated case.
And — this is the punchline — the bound is *attained* at both ends: a disjoint
family of $m$-sets and a family of $k$ identical $m$-sets both achieve equality.
So no better bound can ever be written using only the numbers $(k, m, t)$.

Turned inside out, the same inequality bounds the *number of sets*. If the union
lives inside $N$ points and $Nt < m^2$ (the "design regime": sets large relative
to the ambient space, overlaps small), then

$$k\,(m^2 - Nt) \;\leq\; N\,(m - t), \qquad\text{i.e.}\qquad k \;\leq\; \frac{N(m-t)}{m^2 - Nt}.$$

Large, nearly disjoint sets cannot be numerous. This is the counting principle
behind Fisher's inequality in design theory and behind Plotkin-type bounds in
coding theory, and it falls out of the same two moment identities.

---

## Rigidity that survives noise

Exact characterisations of equality are elegant but brittle: real data is never
exactly extremal. So it is worth knowing that the rigidity statements are
*stable*. Define the **Cauchy–Schwarz gap**

$$g \;=\; \Bigl|\bigcup_i A_i\Bigr| \cdot \sum_{i,j}|A_i \cap A_j| \;-\; \Bigl(\sum_i |A_i|\Bigr)^{\!2} \;\;\geq\; 0 ,$$

a quantity computable from the marginals alone. Then, for any two covered points
$x, y$,

$$\bigl(d(x) - d(y)\bigr)^2 \;\leq\; g .$$

The *entire spread* of the multiplicity function is controlled by $\sqrt{g}$. An
ensemble whose second-order statistics are within $g$ of the Corrádi-extremal
profile has all its coverage multiplicities within $\sqrt{g}$ of each other: the
failure mass is uniformly spread, quantitatively, not just in the limit. And
because $g$ is an integer, a gap of *less than one* already forces exact
regularity — the rigidity is not merely stable, it is locally rigid with a hard
threshold.

---

## The hard limit: why it can never be an equality

Every result above is an inequality, and by now the reader should be wondering
whether that is a limitation of the method or of the information. Could some
cleverer function of the numbers $|A_i|$ and $|A_i \cap A_j|$ compute the union
exactly?

No. And the counterexample is small enough to fit in a sentence. Take the ground
set $\{0,1,2,3\}$ and compare:

- the **triangle** $\;A_0 = \{0,1\},\; A_1 = \{1,2\},\; A_2 = \{2,0\}$;
- the **sunflower** $\;B_0 = \{0,1\},\; B_1 = \{0,2\},\; B_2 = \{0,3\}$.

Both families consist of three sets of size $2$, and in both families every pair
of distinct sets meets in exactly $1$ point. The first- and second-order
marginal data are *identical*. But the triangle covers $3$ points and the
sunflower covers $4$.

> **Second-order indeterminacy.** There is no function $F$ of the first- and
> second-order marginals with $\bigl|\bigcup_i A_i\bigr| = F\bigl((|A_i|)_i, (|A_i \cap A_j|)_{i,j}\bigr)$
> for all families of three sets. Every Bonferroni-type statement is therefore
> necessarily an inequality.

The pair is instructive beyond the negative result. The triangle has
multiplicity $2$ at each of its three covered points: it is a *regular* cover,
so its Cauchy–Schwarz gap is $0$ and it attains Corrádi's bound exactly
($3 \cdot 2^2 = 12 = 3 \cdot (2 + 2 \cdot 1)$). The sunflower has multiplicity
profile $(3,1,1,1)$: gap $12$, Corrádi strictly slack
($12 < 4 \cdot 4 = 16$), and its double-collision bound is slack too — because
it has a point of multiplicity $3$, exactly as the tightness characterisation
predicts. Every prediction of the theory is visible in one four-point example.

### Is order three enough? Order seventeen?

The obvious escape route is to admit higher-order data. Perhaps triple
intersections $|A_i \cap A_j \cap A_\ell|$ would suffice? For the triangle and
the sunflower they do distinguish: the triple intersection is $\emptyset$ for
the triangle and $\{0\}$ for the sunflower. But this is an accident of
three sets. The general answer is a clean threshold theorem.

On the positive side, *complete* marginal data always determines the union: if
two families have $|\bigcap_{i \in T} A_i| = |\bigcap_{i \in T} B_i|$ for every
nonempty subfamily $T$, then their unions have equal size — this is just
inclusion–exclusion.

On the negative side, nothing less will do:

> **Marginal-Order Threshold.** For every $k \geq 1$ there are two families of
> $k$ subsets of a common finite ground set whose joint marginals
> $|\bigcap_{i \in T} A_i|$ agree for **every proper** subfamily $T$, whose
> top-order marginals ($T$ = everything) differ, and whose unions differ. Hence
> no functional of the marginals of order $< k$ can compute the union of $k$
> sets, while the marginals of all orders can. The threshold is exactly $k$.

The construction is a small piece of Möbius-inversion magic. Take the ground set
to be two labelled copies of every subset of $\{1, \dots, k\}$, that is
$\Omega = \mathcal{P}(\{1,\dots,k\}) \times \{\text{first}, \text{second}\}$, of
size $2^{k+1}$. Define

- the **plain family** $A_i = \{ (S, \text{first}) : i \in S \}$ — one copy of
  each subset containing $i$;
- the **parity family** $B_i = \{ (S, b) : i \in S,\ |S| \equiv k \bmod 2 \}$ —
  *two* copies of each subset containing $i$ whose size has the right parity.

Think of each family as assigning a *weight* $w(S)$ to each subset $S$: the
plain family has $w \equiv 1$, the parity family has
$w(S) = 1 + (-1)^{k - |S|}$. The difference is the perturbation
$\delta(S) = (-1)^{k-|S|}$, and the marginal of order $|T|$ is exactly the upper
sum $\sum_{S \supseteq T} w(S)$. The alternating binomial identity
$\sum_{j} (-1)^j \binom{n}{j} = 0$ for $n \geq 1$ says precisely that

$$\sum_{S \supseteq T} \delta(S) = 0 \quad\text{for every } T \neq \{1,\dots,k\},$$

so *every* marginal below the top order is unchanged by the perturbation. At the
top, $T$ = everything, the single term $\delta(\{1,\dots,k\}) = 1$ survives, and
the marginals differ ($1$ versus $2$). And the unions differ for a charmingly
crude reason: the plain family covers $2^k - 1$ points, an **odd** number, while
the parity family covers an **even** number of points, since its ground points
come in pairs. Parity alone separates them.

The perturbation $\delta$ is invisible below order $k$ and flips the parity of
the union. That is the whole proof.

---

## What this means for practice

Strip away the combinatorics and the message to a practitioner is threefold.

**First: pairwise correlation data is genuinely informative, and exactly how
informative is computable.** The defect identities say that the gap between what
you measure and what you want is a specific sum of squares. If you can estimate
the multiplicity profile — the histogram of "how many members fail here" — you
know the gap exactly, not just a bound on it.

**Second: the extremal cases are exactly the interpretable ones.** Your
union bound is lossless exactly when errors never co-occur. The correction term
is lossless exactly when no three members ever fail together. The second-moment
bound is lossless exactly when failure mass is spread perfectly evenly. These
are not technical conditions; they are the three qualitative regimes an ensemble
designer already thinks in, now with sharp mathematical content and,
via the stability theorem, robust to perturbation.

**Third: there is an information-theoretic wall, and you should stop trying to
climb it.** No amount of ingenuity extracts the union from second-order
statistics. If your $k$ hypotheses' joint failure structure matters, you need
data of order $k$ — a $k$-way interaction that is genuinely invisible to every
lower-order statistic. Diversity metrics built from pairwise disagreement rates,
however sophisticated, are provably blind to a real and constructible mode of
ensemble behaviour.

The four-point triangle-versus-sunflower example makes the wall concrete: two
ensembles, indistinguishable by every error rate and every pairwise correlation,
one of which is a perfectly balanced committee and the other of which has a
single catastrophic sample where everybody is wrong. Statistically identical.
Operationally worlds apart. That gap is not noise in your measurements — it is
the shape of the information you never collected.
