# Counting Sheets: How Many Points Sit Above a Point?

## A question you can ask about any map

Take a map $f$ from one space $E$ to another space $X$ — think of $E$ as a landscape floating above the ground $X$, with $f$ the "drop a plumb line" function that tells you which spot on the ground each point of the landscape sits over. Now stand at a point $x$ on the ground and look up. How many points of the landscape are directly above you?

Call that number the **sheet number**, written $\mathrm{sh}_f(x)$: the number of solutions of the equation $f(e) = x$. It is the most naive invariant imaginable. And yet, for a very natural class of maps, it turns out to be astonishingly rigid: it cannot change as you walk around, it cannot jump up, it cannot jump down, and if it is ever zero on a connected patch of ground then it is zero everywhere on that patch.

This article is about that rigidity, about the geometric mechanism behind it — a "stack of sheets" hovering over the ground — and about a technical improvement that makes the mechanism usable in practice: the ability to build the stack **inside a region you choose in advance**, rather than inside whatever region the abstract theory happens to hand you.

## Coverings: the landscape is a stack of copies

The maps for which the sheet number behaves are the *covering maps*. The definition is a picture rather than a formula.

A point $x$ of the base is **evenly covered** by $f$ if there is an open neighbourhood $U$ of $x$ and a discrete index set $I$ — an unstructured set of labels — together with a homeomorphism
$$f^{-1}(U) \;\cong\; U \times I$$
that is compatible with $f$: under the identification, $f$ becomes the projection $(y, i) \mapsto y$. In words: over the small region $U$, the part of the landscape lying above $U$ is nothing but a disjoint union of $|I|$ separate copies of $U$ stacked one on top of the other, and $f$ just flattens the stack.

A map is a **covering map on a set $S$** if every point of $S$ is evenly covered in this sense. The world's favourite example: wrap the real line onto the circle by $t \mapsto (\cos t, \sin t)$. Above any small arc of the circle you find infinitely many separate arcs of the line, one for each full turn — an infinite stack, but a perfectly orderly one. Another: the $n$-th power map $z \mapsto z^n$ on the unit circle, whose stack over any small arc has exactly $n$ sheets. Another, and the one that motivates this work: the projection of a piecewise-linear object onto a piecewise-linear base, where over each open region the object breaks into finitely many affine slabs that project down isomorphically.

The key point of the picture is that it is *local*. It says nothing about the map globally; it constrains only what happens over each small region separately. Everything below is an exercise in converting that purely local information into global statements.

## The first miracle: the count cannot wobble

Suppose $f$ is a covering map on $S$ and $x \in S$. Then $x$ has a neighbourhood $U$ over which the landscape is a stack of $|I|$ copies. But every point $y \in U$ enjoys *the same* trivialisation — the same $U$, the same $I$ works verbatim for $y$ as it does for $x$. So being evenly covered with a given fibre is an **open condition** on the base point, and the fibre over $y$ has exactly as many points as the fibre over $x$: both are in bijection with $I$.

Hence:

> **Local constancy.** If $f$ is a covering map on $S$ and $x \in S$, then $\mathrm{sh}_f(y) = \mathrm{sh}_f(x)$ for all $y$ in some neighbourhood of $x$. In particular $\mathrm{sh}_f$ is locally constant on $S$.

A locally constant function on a connected set is constant. And here the connectivity needed is the weakest possible kind — *preconnectedness*, meaning the set cannot be split by two open sets meeting it in disjoint nonempty pieces (a preconnected set can be empty; a connected set cannot). So:

> **Constancy.** If $f$ is a covering map on a preconnected set $S$, then $\mathrm{sh}_f$ is constant on $S$: the number of points above $x$ is the same for every $x \in S$.

This one statement contains a great deal of classical mathematics. It is why a degree-$n$ covering of a connected space has exactly $n$ points over every point; it is why the number of sheets is a well-defined invariant at all; it is the engine behind counting arguments for polynomial equations, for lattices, for branched covers away from their branch locus.

There is a bookkeeping subtlety worth flagging, because it is not a defect but a feature. The sheet number is defined as a *natural number*, using the convention that an infinite set and the empty set both get the value $0$. So $\mathrm{sh}_f(x) = 0$ means "the fibre is empty or infinite". For the line wrapping onto the circle, every sheet number is $0$ in this convention, and the constancy theorem is still true, just uninformative. Whenever the fibres are finite and nonempty, the number is the honest count. To handle the empty/infinite distinction properly, one tracks the *emptiness* of the fibre separately, which is exactly what the dichotomy below does.

## Semicontinuity, and why it is not a red herring

Two weaker-looking consequences deserve their own names, because they are the shapes in which the result usually gets applied.

> **Lower semicontinuity.** If $f$ is a covering map on $S$ and $x \in S$, then for every $n < \mathrm{sh}_f(x)$ we have $n < \mathrm{sh}_f(y)$ for all $y$ near $x$. The count cannot suddenly drop.

> **Upper semicontinuity.** Symmetrically, for every $n > \mathrm{sh}_f(x)$ we have $n > \mathrm{sh}_f(y)$ nearby. The count cannot suddenly jump.

> **Continuity.** Both together: $\mathrm{sh}_f$ is continuous at $x$, where the natural numbers carry the discrete topology.

Why bother, when constancy is stronger than all three? Because semicontinuity is the *stable* half of the statement — it survives in situations where constancy fails. Away from the covering locus, fibre counts genuinely do jump: a double root of a polynomial splits into two simple roots under perturbation (lower semicontinuity survives; upper fails), and a branch point of a branched cover has fewer preimages than its neighbours. The theorems above locate exactly where the two one-sided estimates hold *simultaneously*: on the covering locus, and there the two squeeze the function to a constant. Stating the semicontinuity package explicitly makes it usable as the local input to a global argument in which the covering hypothesis holds only on part of the base.

## The dichotomy: all or nothing

Here is the statement that repairs the "$0$ means empty or infinite" ambiguity, and which is more useful than it looks.

> **Dichotomy.** Let $f$ be a covering map on a preconnected set $S$. Then either the fibre $f^{-1}(y)$ is empty for **every** $y \in S$, or it is nonempty for **every** $y \in S$.

The proof is the same idea one level up. Under an even covering $f^{-1}(U) \cong U \times I$, the fibre over $y \in U$ is in bijection with $I$; so the fibre over $y$ is nonempty precisely when $I$ is nonempty, and this is a condition that does not depend on $y$ at all. Therefore the *truth value* of the proposition "the fibre over $y$ is nonempty" is a locally constant function of $y$ on $S$, and a locally constant function on a preconnected set is constant. If $S$ is empty the first alternative holds vacuously; otherwise pick a base point and read off which of the two alternatives its fibre selects.

The consequence is the familiar one: **a covering map over a connected base is surjective as soon as it hits a single point**. There is no such thing as a covering that covers half of a connected space. This is a genuinely global conclusion pulled out of purely local hypotheses, and it is the reason lifting arguments — path lifting, monodromy, the classification of covers — get off the ground at all.

## From abstract stacks to concrete sheets

So far the trivialisation $f^{-1}(U) \cong U \times I$ has been used as a black box: an abstract homeomorphism, existing somewhere, over some neighbourhood $U$ produced by the definition. For computation, and for gluing local pictures into global ones, one wants something far more concrete: an explicit list of *sheets*, each an honest open piece of the landscape, each carrying its own inverse function.

That is what a **sheet system** provides.

> **Definition.** Let $V \subseteq X$ and let $\iota$ be an index set. A *sheet system* for $f$ over $V$ indexed by $\iota$ is a family of partial homeomorphisms $\varphi_i : E \rightharpoonup X$ (for $i \in \iota$), each defined on an open source $\Sigma_i \subseteq E$ and mapping it homeomorphically onto an open target, such that:
> 1. every target is exactly $V$: $\varphi_i(\Sigma_i) = V$ for all $i$;
> 2. every chart is a restriction of $f$: $\varphi_i = f$ on $\Sigma_i$;
> 3. the sheets are pairwise disjoint: $\Sigma_i \cap \Sigma_j = \emptyset$ for $i \ne j$;
> 4. the sheets exhaust the preimage: $\bigcup_i \Sigma_i = f^{-1}(V)$.

This is the stack of sheets made explicit. Each $\Sigma_i$ is a single sheet; $f$ carries it homeomorphically onto the whole of $V$; distinct sheets never touch; nothing above $V$ is left out. From these four axioms everything one wants follows immediately and constructively:

- $f$ is **injective on each sheet** (it agrees there with a homeomorphism);
- $f$ maps **each sheet onto all of $V$** (apply the inverse chart $\varphi_i^{-1}$ to a point of $V$);
- **openness is detected sheet by sheet**: for $W \subseteq V$, the set $W$ is open in $X$ if and only if $f^{-1}(W) \cap \Sigma_i$ is open in $E$, for any one index $i$ — the inverse chart converts open subsets of $V$ into open subsets of the sheet and back;
- if $V$ is open, then **every point of $V$ is evenly covered**, with fibre the index set $\iota$; consequently $\mathrm{sh}_f(y) = |\iota|$ for every $y \in V$.

And there is a payoff in the other direction: the last item can be sharpened so that the index type carries no topology whatsoever. A sheet system over an open $V$ exhibits each $y \in V$ as evenly covered *by its own fibre* $f^{-1}(y)$. Whatever the labels $\iota$ were, they can be forgotten and replaced by the intrinsic set of points above $y$, given the discrete topology. Nothing about the labelling was ever geometrically meaningful.

## The relative trivialisation theorem

The abstract definition of "evenly covered" hands you a neighbourhood $U$. It does not let you *choose* it. If you have already committed to working inside some open region $U_0$ of the base — because that is where your object is defined, or where your other hypotheses hold — you need the trivialisation to live inside $U_0$, and the definition gives you no such guarantee.

The fix is the technical heart of the story, and it is pleasingly simple once the sheet-system language is in place.

> **Restriction of sheet systems.** Let $S$ be a sheet system for $f$ over $V$ indexed by $\iota$, and let $W \subseteq X$ be open. Then there is a sheet system for $f$ over $W \cap V$, indexed by the *same* set $\iota$, whose $i$-th sheet is $\Sigma_i \cap f^{-1}(W)$.

Concretely, each chart $\varphi_i$ is composed with the identity homeomorphism of $W$ regarded as a partial map — the effect being to cut the source down by $f^{-1}(W)$ and the target down by $W$. The four axioms survive the cut: targets become $W \cap V$; the charts still agree with $f$; disjointness is inherited by subsets; and the union of the trimmed sources is $\left(\bigcup_i \Sigma_i\right) \cap f^{-1}(W) = f^{-1}(V) \cap f^{-1}(W) = f^{-1}(W \cap V)$. Note the striking feature: **the index set does not change**. Shrinking the base does not lose or duplicate sheets; the stack over a smaller region is the same stack, viewed over less ground.

Combining restriction with an explicit construction of sheets out of an abstract even covering — one takes the trivialising homeomorphism $H : f^{-1}(U) \to U \times I$ and defines the $i$-th chart to be $f$ restricted to the slice $\{e : H(e)_2 = i\}$, with inverse $y \mapsto H^{-1}(y, i)$ — gives the main theorem.

> **Relative trivialisation.** Let $U \subseteq X$ be open and suppose $f$ is a covering map on $U$. Then for every $x \in U$ there is an open set $V$ with $x \in V \subseteq U$ and a sheet system for $f$ over $V$ indexed by the fibre $f^{-1}(x)$.

Everything is now inside $U$, as demanded, and the indexing is intrinsic: the sheets over $V$ are labelled by the points above $x$, one sheet per point, exactly as the picture insists.

Running the argument backwards yields a characterisation that dispenses with the abstract definition altogether.

> **Characterisation.** For open $U \subseteq X$, the map $f$ is a covering map on $U$ if and only if every $x \in U$ has an open neighbourhood $V \subseteq U$ over which $f$ admits a sheet system (with an arbitrary index set, carrying no topology).

One direction is the relative trivialisation theorem; the other is the observation that a sheet system over an open set exhibits its points as evenly covered by their own fibres. The value of the characterisation is that it is *checkable*: to certify that a map is a covering over a region, you exhibit, around each point, a finite or infinite list of open pieces upstairs, each mapping homeomorphically down, disjoint, exhausting the preimage. That is a description a computer can hold, and a description a piecewise-linear or combinatorial construction can supply directly.

## Where this bites

The setting that motivated the relative form is piecewise-linear and tropical geometry, where the natural objects are polyhedral complexes and the natural maps are affine on each cell. There, "evenly covered" is not an abstract hypothesis but a combinatorial one: over the interior of a cell of the base, the preimage decomposes into the cells above it, each mapping affinely and bijectively down. The sheets are the cells; the sheet system is the cell structure. The relative form matters because the region one cares about is dictated in advance — the complement of a codimension-one skeleton, the interior of a chamber, the locus where a tropical polynomial attains a unique maximum — and one needs the trivialisation to respect that choice.

With the relative theorem in hand, the chain of implications is short and mechanical. A polyhedral map that is affine and bijective on each cell over a chamber is a covering over that chamber; therefore its fibre count is constant on the chamber; therefore, by the dichotomy, either it misses the chamber entirely or it hits every point of it. Fibre counts, degrees, and surjectivity statements all become consequences of a single local check, region by region.

## The shape of the idea

Strip away the topology and the story is one sentence long: *a locally constant integer on a connected set is a constant*. Everything else is the work of arranging for a fibre count to be locally constant, and of making the local picture concrete enough to compute with.

That arrangement is worth its price. The abstract definition of a covering asserts the existence of a trivialisation somewhere; the sheet-system reformulation names its pieces, lets them be cut down to any open region without loss, and shows they can always be labelled by the intrinsic fibre. What was a hypothesis to be assumed becomes a structure to be exhibited — and, once exhibited, it forces the count above every point to be the same, and forces "covers something" to mean "covers everything".
