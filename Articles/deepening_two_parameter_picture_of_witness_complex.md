# The Smallest Worlds That Can Hold a Witness

## How downward closure turns a complicated universe into an intrinsic certificate

A mathematical witness is a small object that certifies a larger claim. A route through a network witnesses connectivity. A handful of active features can witness a classifier’s decision. A simplex can witness that a point lies in a convex hull. Yet there is a subtle difference between finding a witness and packaging it in a structure that preserves all the rules of the surrounding world.

For simplicial complexes, that rule is *downward closure*. A face is a finite set of vertices, and whenever a face is present, every subset of it must be present too. If the triangle with vertices $a,b,c$ belongs to a complex, then its three edges, its three vertices, and the empty face belong as well. One cannot retain the triangle while discarding its boundary.

This simple requirement creates a precise notion of witness complexity. Given one or more designated faces, how many faces must a valid downward-closed certificate contain? A crude answer might depend on the total number of vertices in the ambient complex. The sharper answer does not. It depends only on two intrinsic parameters: the number of requested witnesses and the size of their supports.

The central result is concise. If at most $q$ designated faces are requested and each contains at most $m$ vertices, then there is a downward-closed certificate containing all of them with at most

$$
q2^m
$$

faces. The bound is independent of the size of the ambient vertex set. Better still, the construction is canonical, and for a single witness its exponential dependence is exact.

## One face carries its whole shadow

Take a face $w$. Its *principal certificate* is the family of every subset of $w$:

$$
\mathcal P(w)=\{s:s\subseteq w\}.
$$

This is simply the power set of $w$, viewed as a simplicial complex. It is downward closed: if $s\subseteq w$ and $t\subseteq s$, then $t\subseteq w$. It contains $w$ itself. Most importantly, it is unavoidable.

**Principal Certificate Theorem.** If $K$ is any downward-closed family and $w\in K$, then $\mathcal P(w)\subseteq K$. Consequently, $\mathcal P(w)$ is the unique least downward-closed family containing $w$.

The proof is almost visual. Every member of $\mathcal P(w)$ is a subset of $w$. Downward closure forces every such subset into $K$. Nothing smaller can contain $w$ while respecting the rule.

This gives an exact count. If $|w|=r$, then choosing a subset means independently deciding, for each of the $r$ vertices, whether to include it. There are therefore

$$
|\mathcal P(w)|=2^r
$$

faces. Any downward-closed certificate containing $w$ must have at least $2^r$ faces, while the principal certificate has exactly that many.

The exponential is not waste introduced by a loose estimate. It is the true cost of retaining a face of width $r$ in a downward-closed universe.

This observation changes how one should interpret “small.” A face with $100$ vertices requires an enormous certificate even if it sits in an ambient universe containing only those vertices. Conversely, a face with $5$ vertices requires only $32$ faces even if the ambient universe has a billion vertices. Support width, not ambient scale, controls the local burden.

## Many witnesses, one generated world

Now suppose the designated faces form a finite family $W$. Their canonical family certificate is

$$
\mathcal C(W)=\bigcup_{w\in W}\mathcal P(w).
$$

In words, take each witness together with its entire downward shadow, then merge the shadows. This union remains downward closed, because every subset of a face in one shadow remains in that same shadow. It contains every requested witness, since $w\in\mathcal P(w)$.

It is also the least possible certificate.

**Family Minimality Theorem.** If $K$ is downward closed and $W\subseteq K$, then $\mathcal C(W)\subseteq K$. Thus $\mathcal C(W)$ is the unique least downward-closed family containing all faces in $W$.

Indeed, each individual witness forces its principal certificate into $K$, so their union is forced as well. This theorem is more than a convenient construction: it identifies the exact object whose size is the witness complexity of $W$.

Suppose now that $|W|\le q$ and every $w\in W$ has $|w|\le m$. Each principal shadow has at most $2^m$ faces. The size of a union is at most the sum of the sizes, so

$$
|\mathcal C(W)|
\le \sum_{w\in W}2^{|w|}
\le |W|2^m
\le q2^m.
$$

This proves the **Two-Parameter Witness Theorem**: at most $q$ witnesses of width at most $m$ admit a downward-closed certificate with at most $q2^m$ faces.

The estimate is deliberately universal. It assumes nothing about how the witnesses overlap. In practice, overlap can make the certificate much smaller. Every principal certificate contains the empty face, for example, so even disjoint nonempty witnesses share at least one face. If two witnesses share many vertices, then their shadows overlap in an entire power set.

For two faces $u$ and $v$, inclusion–exclusion gives the exact formula

$$
|\mathcal P(u)\cup\mathcal P(v)|
=2^{|u|}+2^{|v|}-2^{|u\cap v|}.
$$

The overlap term is itself exponential in the intersection width. This is the first hint that a richer theory can replace the coarse parameters $q$ and $m$ with an overlap profile.

## The ambient complex disappears—but remains available

Often the witnesses already live in a large ambient simplicial complex $A$. The canonical certificate does not escape it.

**Ambient Subcomplex Theorem.** Let $A$ be downward closed, let $W\subseteq A$, assume $|W|\le q$, and assume every $w\in W$ has $|w|\le m$. Then there exists a downward-closed family $K$ such that

$$
W\subseteq K\subseteq A
\qquad\text{and}\qquad
|K|\le q2^m.
$$

One simply takes $K=\mathcal C(W)$. Since $A$ is downward closed and contains each witness, family minimality places every required subset inside $A$.

This is a useful kind of independence. The bound forgets the ambient number of vertices, yet the resulting certificate retains a rigorous relationship to its environment. It is not an abstract replacement disconnected from the original complex; it is a genuine subcomplex.

Consider a data set represented by a huge combinatorial complex, where a face records a compatible collection of features. If a conclusion depends on three faces, each involving at most ten features, then the conclusion can be packaged inside a subcomplex with at most $3\cdot2^{10}=3072$ faces, regardless of whether the full feature vocabulary has one thousand or one billion entries. The certificate is controlled by what the explanation uses, not by everything the system could have used.

## Why width alone does not count a whole complex

A seductive mistake is to turn a local theorem into a global counting law. Since an edge has two vertices and its principal certificate has four faces—the empty face, two vertices, and the edge—one might guess that every width-two complex on $n$ vertices has around $2n$ faces, or even exactly $2n$ faces.

That is false.

Take four vertices and include every face of size at most two. This is the complete graph on four vertices, interpreted as a simplicial complex. It contains one empty face, four singleton faces, and six edges, for a total of

$$
1+4+\binom{4}{2}=11
$$

faces. But $2n=8$. Thus a width-two complex can already exceed the proposed count.

The lesson is structural. The theorem controls the subcomplex generated by a *specified family of witnesses*. It does not say that an arbitrary complex is small merely because each of its faces is narrow. There may be many maximal narrow faces. Here the six edges produce a much richer union than any single edge does.

Trees help explain why the false guess feels plausible. A tree on $n$ vertices has $n-1$ edges, so its clique complex has

$$
1+n+(n-1)=2n
$$

faces. The equality comes from the tree’s sparse edge count, not from width two alone. The complete graph exposes the missing hypothesis.

## An algorithm hiding in the theorem

The construction is immediately computational. To generate the certificate, enumerate every subset of every requested witness and insert it into a set. For a witness with $r$ vertices, bit masks from $0$ through $2^r-1$ provide a direct enumeration. If there are at most $q$ witnesses of width at most $m$, at most $q2^m$ subset-generation steps are needed, apart from the cost of representing each subset.

A second simplification comes before enumeration. If one witness $u$ is contained in another witness $v$, then $\mathcal P(u)\subseteq\mathcal P(v)$. The smaller witness contributes nothing new and may be deleted. Thus only inclusion-maximal witnesses matter. This antichain compression is an elementary consequence of the definitions and points toward sharper bounds based on the number of maximal witnesses rather than the raw input count.

The minimality theorem also makes the algorithm certifying in a strong mathematical sense. Its output is not merely *a* valid certificate. It is the least one under inclusion. Any other downward-closed family retaining the same witnesses must contain it.

## From combinatorics to explanations

The same pattern appears whenever structures are hereditary: retaining an object forces retention of all its subobjects. In topological data analysis, a high-dimensional simplex brings all of its faces. In database systems, a collection of attributes may bring all projected subcollections. In feature-interaction models, preserving a high-order interaction can require preserving every lower-order interaction. In each setting, the power-set cost $2^m$ is the natural shadow of hereditary closure.

The two parameters have distinct meanings. The number $q$ measures how many separate reasons or witnesses are being retained. The width $m$ measures the largest internal complexity of any one reason. The theorem says these costs combine linearly in $q$ and exponentially in $m$ before overlap is exploited.

That division suggests practical strategy. Reducing the number of witnesses gives a proportional gain. Reducing witness width by one can nearly halve the worst-case cost. Encouraging overlap can produce additional savings invisible to the basic bound.

## The next layer: geometry of overlap

The universal estimate $q2^m$ is a clean ceiling, not the final word. The exact size is

$$
\left|\bigcup_{w\in W}\mathcal P(w)\right|,
$$

and its behavior depends on the intersection pattern of the witnesses. Inclusion–exclusion expresses it through quantities such as

$$
2^{|w_1\cap\cdots\cap w_j|}.
$$

This opens several directions. One can seek bounds using pairwise intersection sizes, characterize families that come closest to the universal ceiling, or compress $W$ to its maximal antichain before measuring complexity. One can also transport the idea to independence complexes, where rank replaces face width and selected bases replace witness faces.

A particularly appealing geometric application begins with a simplex that captures a target point, as in Carathéodory-type phenomena. A simplex on at most $d+1$ vertices carries an exact principal certificate of $2^{d+1}$ faces. Once the geometric argument finds the simplex, the combinatorial argument packages it without reference to the size of the ambient configuration.

The broad principle is simple: a vast mathematical universe need not accompany a local explanation. Keep the witnesses, close downward, and count the shadow. The resulting world is canonical, minimal, and governed by the complexity of the evidence itself.
