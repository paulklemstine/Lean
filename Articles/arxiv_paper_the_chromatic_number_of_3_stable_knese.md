# The Geometry of Keeping Apart: Coloring Stable Kneser Graphs

## A circle, a spacing rule, and an unavoidable palette

Imagine $n$ seats arranged around a circular table. We select $k$ seats, but with a strict distancing rule: every two selected seats must be separated, in either direction around the circle, by at least $s$ steps. Now imagine that each legal selection is a vertex of a graph. Two vertices are joined when the corresponding selections are disjoint.

The coloring question is deceptively simple: how many colors are needed so that disjoint selections never receive the same color?

This construction is a stable Kneser graph. It combines three familiar ideas—subsets, circular spacing, and graph coloring—in a way that creates a remarkably rigid numerical answer. If $[n]=\{1,2,\ldots,n\}$ and the cyclic distance between $i$ and $j$ is

$$
d_n(i,j)=\min\{|i-j|,\,n-|i-j|\},
$$

then a $k$-element set $A\subseteq[n]$ is called cyclically $s$-stable when $d_n(i,j)\ge s$ for all distinct $i,j\in A$. The stable Kneser graph has these sets as its vertices, with an edge between $A$ and $B$ exactly when $A\cap B=\varnothing$.

The central prediction is that, whenever $n\ge sk$, the chromatic number should be

$$
\chi=n-sk+s.
$$

This formula is striking because the graph can have an enormous number of vertices, yet its optimal number of colors is a short linear expression. The work described here establishes that prediction in two important regimes: for $s=3$ when $n$ is sufficiently large relative to $k$, and for the complete diagonal case $k=s=3$, where every $n\ge9$ is covered. Thus, for cyclically $3$-stable triples,

$$
\chi=n-6.
$$

## Why the proposed number of colors is always enough

The upper bound contains the cleanest idea in the story. Let

$$
q=n-sk+s=n-s(k-1).
$$

Give every stable set $A$ the color of its least element, $\min A$. Why are there only $q$ possible colors?

Write the elements of $A$ in increasing order as

$$
a_1<a_2<\cdots<a_k.
$$

Stability forces each ordinary gap to satisfy $a_{r+1}-a_r\ge s$. Consequently,

$$
a_k\ge a_1+s(k-1).
$$

Since $a_k\le n$, we obtain $a_1\le n-s(k-1)=q$. So the least element always lies among the first $q$ labels.

Why is this a proper coloring? Two sets with the same least element contain that common label. They therefore intersect and cannot be adjacent. In one stroke, an arithmetic spacing rule turns into a graph coloring:

$$
\chi\le n-sk+s.
$$

This argument is canonical, efficient, and completely explicit. Given a stable set, one reads its smallest label and is done. No search through the graph is required.

The elegance of this upper bound also clarifies the real difficulty. The hard part is not constructing a coloring. It is proving that no cleverer coloring can use fewer colors.

## Color classes become intersecting families

Suppose we have any proper coloring. Every color class is a family of stable $k$-sets in which no two members are disjoint. In the language of extremal set theory, every color class is an intersecting family.

That translation is the bridge at the heart of the argument:

> A lower bound for the number of colors can be obtained by understanding how large and how structured an intersecting family of cyclically stable sets can be.

The simplest intersecting family is a star: fix a label $x$ and take every stable $k$-set containing $x$. All members meet at $x$. Stars explain the least-element coloring, whose fibers are contained in stars centered at their least labels.

But not every intersecting family has a common point. A family can be intersecting while its total intersection is empty. These non-star families are subtler. The classical Hilton–Milner phenomenon says, roughly, that such families pay a size penalty. In the stable circular setting, one needs a version sensitive not only to intersection but also to forbidden short gaps.

The large-$n$ proof for $s=3$ develops precisely this kind of stable Hilton–Milner control. Its role is structural rather than merely numerical. A color class that behaves like a star is governed by a center. A class with no common center must fit a much tighter exceptional pattern and is too small, or too constrained, to let an undersized palette cover every vertex. When $n$ is sufficiently large compared with $k$, these alternatives force at least $n-3k+3$ colors. Combined with the least-element coloring, this gives

$$
\chi=n-3k+3.
$$

The phrase “sufficiently large” is important: the argument is asymptotic in $n$ for each fixed $k$. The separate triple theorem removes that qualification when $k=3$.

## The exact triple case

When $k=s=3$, a legal vertex is a triple of labels with at least two unselected labels between consecutive selected labels around the circle. Such a triple exists exactly from $n=9$ onward. The general formula predicts $n-6$ colors.

The exact theorem states:

> For every integer $n\ge9$, the graph whose vertices are cyclically $3$-stable triples in $[n]$, with disjointness as adjacency, has chromatic number $n-6$.

The upper bound is immediate from the least-element rule. The lower bound requires showing that fewer than $n-6$ intersecting families cannot cover all legal triples. Triples are special enough that their cyclic gap patterns can be analyzed completely. If a triple is written around the circle, its three gaps are positive integers, each at least $3$, whose sum is $n$. This gap encoding converts geometric placement into arithmetic composition.

The lower-bound analysis tracks what a color class can do across these gap patterns. Star-like classes concentrate around one label. Non-star classes must intersect one another through a restricted web of alternatives. The stable Hilton–Milner principle limits those alternatives, and the resulting count prevents a cover by only $n-7$ intersecting families. Hence the explicit $n-6$-coloring is optimal for every admissible $n$.

At $n=9$, there are only three stable triples: $\{1,4,7\}$, $\{2,5,8\}$, and $\{3,6,9\}$. They are pairwise disjoint, so the graph is a triangle and needs $3=n-6$ colors. Larger circles introduce many more triples, but the same linear law persists.

## A topological shadow

There is another way to view the lower bound. Disjointness graphs carry a natural two-sided structure: one may think of choosing collections on a “positive” side and a “negative” side, with every set on one side disjoint from every set on the other. These configurations assemble into a topological object often called a box complex.

A proper coloring with $m$ colors induces a map from this complex into a standard space of dimension tied to $m$. If the stable Kneser graph’s complex has a sufficiently strong antipodal obstruction, such a map cannot exist when $m$ is too small. The topology then certifies a chromatic lower bound.

The topological approach is not an unrelated trick. Both it and the arithmetic coloring are driven by the same cyclic gap data. The least-element coloring filters vertices by an initial segment of $[n]$. The topological obstruction records how disjoint stable sets move through that filtration. One promising idea is that these are dual descriptions of a single certificate: arithmetic gives the coloring, topology explains why the palette cannot shrink.

This perspective also helps explain why odd stability is difficult. For even $s$, antipodal and parity structures align more readily with the circle. At $s=3$, that symmetry no longer does all the work. The stable Hilton–Milner route supplies the missing combinatorial rigidity.

## Computation as a microscope

Small examples can be explored directly. First generate every $k$-subset of $[n]$. Retain only those whose sorted cyclic gaps are all at least $s$. Join two retained sets if they are disjoint. The least-element coloring can then be checked edge by edge.

To confirm optimality in small cases, one can run an exact coloring search. Try to assign $m$ colors by processing highly constrained vertices first; whenever a partial assignment gives adjacent vertices the same color, backtrack. Testing successive values of $m$ reveals the chromatic number.

This computation is not the proof of the general theorem—the search grows exponentially—but it makes the structure visible. For $n=9$, $k=s=3$, the triangle appears immediately. For subsequent values, the number of vertices rises, while the optimal palette follows $n-6$. A gap-profile table offers another view: it groups stable sets by the cyclic distances between consecutive chosen labels, showing how the geometry of the circle organizes the graph.

## Why this family matters

Stable Kneser graphs sit at a crossroads. They are graph-coloring problems, but their vertices are constrained set systems. They are finite and explicit, but their lower bounds invite topology. They have immediate algorithms, but exact optimality depends on structural theorems.

The spacing condition also resonates beyond pure graph theory. Circular schedules require repeated events to remain separated. Frequency allocation forbids nearby channels. Coding theory asks for words or supports with prescribed distances. In each setting, one tries to select well-separated configurations and then partition them so that incompatible configurations receive different labels.

The formula $n-sk+s$ says that the cost of coloring is controlled by the circle’s unused freedom after accommodating $k-1$ mandatory gaps of length $s$. The term $n-s(k-1)$ is exactly what remains for the first selected point. The upper bound sees this directly. The lower bound says that this simple accounting is not merely convenient—it is unavoidable.

## The road ahead

The broad conjecture remains that the equality

$$
\chi=n-sk+s
$$

holds for every $s\ge2$, $k\ge1$, and $n\ge sk$. The newly understood $3$-stable regimes point toward several next steps.

One is a full classification of the largest non-star intersecting families of stable sets. Another is rigidity: perhaps every optimal coloring, after rotating the circle and renaming colors, must resemble the least-element coloring together with a controlled collection of Hilton–Milner-type exceptions. A quantitative version would ask what necessarily goes wrong when one uses fewer than the predicted number of colors: must some color contain many disjoint pairs, and can their density be bounded?

The most ambitious synthesis would identify an explicit certificate that is simultaneously combinatorial and topological. Such a certificate could turn the transparent upper coloring into the organizing principle for the lower bound as well.

The charm of the problem lies in this tension. The winning coloring is visible at a glance: color by the first chosen seat. Proving that nothing better exists requires a deep account of how separated sets can intersect. Around a simple circle, arithmetic gaps, extremal families, graph coloring, and topology all meet—and the palette records their agreement.