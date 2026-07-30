# The Geometry of a Recipe

## When the same dish has more than one route

A recipe looks like a list, but anyone who cooks knows that it behaves more like a landscape. There are crossroads: butter or oil, walnuts or no walnuts, one chile or two. There are reversible moves, detours, and changes that can be made in either order. Two cooks may begin with the same batter, make different choices, and nevertheless arrive at dishes with the same observable flavor.

This suggests a geometric question. Instead of asking only whether two recipes produce the same dish, can we study the *space of ways* to move between recipes?

To make that question precise, separate a recipe into two kinds of data. Its **core** is the observable feature we care about—here, a flavor profile. Its **optional data** records choices that our simplified flavor measurement does not distinguish. A recipe is therefore a pair

$$
(c,o),
$$

where $c$ is the core and $o$ is an optional assignment. The flavor map simply forgets the optional data:

$$
F(c,o)=c.
$$

For a fixed dish $d$, the **flavor fiber** is the collection of all recipes measured as $d$:

$$
F^{-1}(d)=\{(c,o):F(c,o)=d\}.
$$

The first result is simple but decisive: this fiber is in one-to-one correspondence with the possible optional data. Every recipe in the fiber has core $d$, so it is determined by its optional part; conversely, every optional assignment $o$ creates the recipe $(d,o)$. Thus the hidden choices are not merely associated with the fiber—they completely describe it.

That observation turns recipe variation into combinatorics and then into geometry.

## The cookie with two faces

Imagine that a cookie recipe has one optional binary choice: nuts or no nuts. Suppose, for the purpose of the model, that both versions have the same measured core flavor. The optional state is then a Boolean value, either $0$ or $1$. Because the fiber is exactly the optional state space, there are precisely two recipes over the chosen flavor.

If we regard those two recipes as isolated possibilities, with no permitted transformation between them, their shape is the zero-dimensional sphere $S^0$: two separate points. This description requires an important qualification. The two-point topology comes from treating the alternatives as a discrete subspace. If “add or remove nuts” is admitted as an edge, the resulting object is an interval, which is connected and contractible. Topology depends not just on the recipes one lists, but on which substitutions one allows.

Now give the cook $n$ independent yes-or-no choices. A recipe is a binary vector

$$
r=(r_1,\ldots,r_n)\in\{0,1\}^n.
$$

There are $2^n$ such vectors, so every fixed-flavor fiber has exactly $2^n$ recipe states. Geometrically, these states are the vertices of an $n$-dimensional cube. One choice gives two endpoints of a line segment. Two choices give four corners of a square. Three choices give eight corners of an ordinary cube. The familiar explosion of recipe variants is just the exponential growth of cubical vertices.

## Cooking methods as paths

A state is not yet a method. To model action, label the optional choices by $1,\ldots,n$. A **toggle** at coordinate $i$ reverses the $i$th choice and leaves all others unchanged. A **method** is a finite list

$$
p=[i_1,i_2,\ldots,i_k],
$$

executed from left to right. It is a path through the cube’s vertices.

A long method may contain much less information than its length suggests. Toggle the same ingredient twice, and the second action undoes the first. Toggle ingredient $i$ and then ingredient $j$, and the endpoint is the same as toggling $j$ and then $i$. What survives is only parity: for each coordinate, was it toggled an odd or an even number of times?

Define the **signature** $\sigma(p)\in\{0,1\}^n$ by

$$
\sigma(p)_j=
\begin{cases}
1,&\text{if }j\text{ occurs an odd number of times in }p,\\
0,&\text{if }j\text{ occurs an even number of times in }p.
\end{cases}
$$

The Endpoint Theorem says that following $p$ from recipe $r$ produces

$$
\operatorname{follow}(r,p)=r\oplus\sigma(p),
$$

where $\oplus$ denotes coordinatewise exclusive-or. In ordinary words, a choice changes exactly when the method mentions it an odd number of times.

The proof follows the method one step at a time. The empty method has zero signature and changes nothing. Adding one toggle flips the relevant coordinate in both the executed recipe and the signature. Induction then gives the formula for every finite list.

This formula is a complete classification of endpoints. For a fixed starting recipe $r$, two methods $p$ and $q$ finish at the same recipe exactly when

$$
\sigma(p)=\sigma(q).
$$

There is no hidden ambiguity. A three-page sequence of substitutions and a three-step shortcut have the same endpoint precisely when their coordinate parities agree.

## Squares, backtracking, and loops

The cube already contains elementary geometry. Consider two distinct choices $i$ and $j$. The methods $[i,j]$ and $[j,i]$ trace different two-edge routes around a square, yet they meet at the opposite corner. This is the **commuting-square law**:

$$
\operatorname{follow}(r,[i,j])=
\operatorname{follow}(r,[j,i]).
$$

Meanwhile, doing the same substitution twice is immediate backtracking:

$$
\operatorname{follow}(r,[i,i])=r.
$$

These laws resemble everyday kitchen reasoning. Sweeten, then thicken; or thicken, then sweeten. In the independent-choice model, order does not affect the final assignment. Add nuts, then remove nuts: one returns to the starting state.

A **loop** is any method that ends where it began. The loop criterion is exact: a method is a loop if and only if every coordinate is toggled an even number of times, equivalently

$$
\sigma(p)=0.
$$

There is also a universal way to manufacture a loop. Perform any method and then perform its list of toggles in reverse order. If

$$
p=[i_1,\ldots,i_k],
$$

then concatenate it with

$$
p^{\mathrm{rev}}=[i_k,\ldots,i_1].
$$

Every toggle appears twice in the combined method, and the endpoint returns to the initial recipe. This is a precise version of retracing one’s culinary steps.

## What the model establishes—and what it does not

The cubical picture proves several concrete facts: fixed-flavor recipes are classified by optional assignments; $n$ binary choices produce $2^n$ states; method endpoints are classified by parity signatures; independent substitutions commute; repeated substitutions cancel; and loops are exactly the even-parity methods.

It does not, by itself, prove that an empirical space of real recipes has a particular homotopy type. Nor does a sequence with repeated stages automatically create a nontrivial topological loop. The full cube, with all its edges and higher-dimensional faces, is contractible: every apparent route can ultimately be filled in. To obtain a genuine circle with an integer winding number, one must specify a cyclic substitution graph and a rule for when paths count as equivalent. To infer topology from a hundred cookie recipes, one must also declare a flavor metric, a tolerance threshold, and a rule for building edges or simplices from data.

Those cautions are not defects. They reveal the scientific value of the framework: it forces vague comparisons to become explicit modeling choices.

## From pantry constraints to data science

Real kitchens rarely offer fully independent choices. Allergies may forbid nuts. Vegan constraints may link butter and eggs. Ingredient availability can remove vertices. Flavor preservation may allow some edges but not others. Such restrictions carve a subcomplex out of the cube, and that subcomplex can have disconnected regions or unfilled cycles.

This opens practical possibilities. A meal-planning system could identify whether two admissible recipes lie in the same connected component—whether one can transform into the other without violating constraints. A substitution engine could search for a shortest method. A dataset of measured flavor vectors could be grouped into tolerance neighborhoods, producing a complex whose persistent features describe robust families of alternatives rather than accidental similarities.

The parity signature also gives an efficient algorithm. To predict a method’s endpoint, there is no need to preserve its whole history. Scan the list once, flipping one bit per substitution. The result uses $O(n)$ memory for $n$ choices and $O(k)$ time for a method of length $k$. Two methods can then be compared by their signatures rather than replayed from scratch.

There is even a shortest summary of any method. Write down, once each, precisely the choices whose signature bits are $1$. This compact list has the same effect as the original instructions, and no equivalent method can be shorter: every choice that changes between the start and finish must be touched at least once. A tangled cooking history can therefore be reduced to a canonical shopping-list-like set of net changes. The reduction does not preserve the experience of the route—timing and order may matter outside the model—but it perfectly preserves the modeled endpoint.

The geometry becomes richer when binary decisions are replaced by multi-state choices: mild, medium, or hot; dairy, coconut, or broth; raw, toasted, or caramelized. The state count becomes a product of coordinate sizes, and substitutions act by cyclic changes or permutations rather than Boolean parity.

The enduring idea is that a dish is not only an endpoint. Around it lies a structured space of variants, and between those variants lie methods whose algebra records cancellation, independence, and return. In the simplest model, the pantry becomes a cube and cooking becomes motion through it. That is already enough to turn “What can I substitute?” into a precise geometric question—and to show that the route through a recipe can be as mathematically meaningful as the plate at the end.
