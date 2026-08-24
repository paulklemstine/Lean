# Two Cut Points, One Chain: How Far a Theory Can Trust Itself

## A theory that talks about itself

Gödel taught us that a sufficiently strong formal theory can talk about its own proofs. Inside such a theory there is a formula $\Box a$ — read "$a$ is provable" — which behaves according to a small and beautiful set of rules: if you can prove $a$, then you can prove that $a$ is provable; provability distributes over implication; provability is provably transitive; and, most striking of all, Löb's rule holds:
$$\Box(\Box a \to a) \to \Box a .$$
These rules make up the modal logic **GL**, the logic of provability. Löb's rule is the formal reason a consistent theory cannot prove its own consistency: setting $a = \bot$ turns it into "if the theory proves that its own consistency implies falsehood, it proves falsehood".

Now suppose the theory has *several* provability predicates at once — not one $\Box$ but a family $\Box_0, \Box_1, \Box_2, \dots$, one for each **tag** $i$. This is not exotic. A tag can be "provable in Peano arithmetic", another "provable in Peano arithmetic together with a large-cardinal-flavoured axiom", another "provable in a fragment with a bounded amount of induction", another "derivable by a proof of at most $10^6$ symbols". Each such notion satisfies the GL rules; they differ in what they can prove *about each other*.

Two numbers measure a tag. Both are extremely simple to state, and the interesting question is how they interact.

**The height.** Iterate the box on falsehood: $\Box_i\bot$, $\Box_i\Box_i\bot$, $\Box_i^3\bot$, …. In a consistent theory, $\Box_i \bot$ says "tag $i$ is inconsistent" and is not provable; but the *iterates* may become provable. The **inconsistency height** $H_i$ of a tag is the last iterate that is *not* provable: the theory proves $\Box_i^k\bot$ exactly when $k > H_i$. A tag with height $0$ is dead — the theory already proves $\Box_i\bot$. A tag with height $5$ can carry a chain of five nested "the theory below me thinks…" before the tower collapses.

**The reflection depth.** A theory that could always pass from "$a$ is provable at tag $i$" to "$a$" would be able to prove its own soundness, and Löb forbids that. But *partial* soundness is allowed. Call a formula's **box depth** the maximal nesting of boxes inside it: $p \to q$ has depth $0$, $\Box_0 p$ has depth $1$, $\Box_0(\Box_1 p \to \Box_0 \bot)$ has depth $2$. The **reflection depth** $\rho_i$ of a tag is the largest $r$ such that
$$\text{for every formula } a \text{ of box depth} < r:\quad \vdash \Box_i a \ \Longrightarrow\ \vdash a .$$
So $\rho_i = 0$ means the tag reflects nothing at all; $\rho_i = 3$ means the theory trusts $\Box_i$ on every statement with at most two layers of modality, and is caught out on some statement with three.

Height and depth are visibly different quantities. Height measures how tall a tower of self-reference the tag can support; depth measures how much of the tag's testimony the theory is willing to believe. The question this article is about is the obvious one:

> **Given the heights of all the tags, what are the possible reflection depths?**

The naive answer — *any depths you like, as long as $\rho_i \le H_i$* — turns out to be wrong, and wrong in a way that is far more interesting than a mere counterexample.

## Chains, tags, and two cut points

To make the question concrete we build theories out of finite pictures. Line up worlds $0, 1, 2, \dots, N$ in a chain, thought of as levels of a tower with $N$ on top and $0$ at the bottom. Each tag $i$ gets its own way of looking *downwards*: a relation $R_i$ that lets the world $m$ inspect certain worlds $n < m$. Each world also has a **valuation** telling us which atoms hold there. A formula $\Box_i a$ is true at $m$ when $a$ holds at every world $m$ can see at tag $i$; the **theory** of the picture consists of the formulas true at *every* world of the chain.

Two facts make this a legitimate laboratory rather than a toy.

**Every transitive picture is a GL theory.** If each $R_i$ is transitive, all the rules of provability logic — modus ponens, necessitation, distribution, transitivity, and Löb — hold for every tag, and the theory is consistent because $\bot$ fails at the bottom world. Nothing else is needed: the "no infinite ascending chains" condition that usually accompanies Löb's rule is free of charge here, since a box only ever looks strictly downwards along a finite chain.

**Provable boxes see only an image.** Define the **image** of a tag,
$$\mathrm{Im}_i \;=\; \{\,n : \text{some world } m \le N \text{ sees } n \text{ at tag } i\,\},$$
the set of worlds that are inspected by somebody. Then a single clean statement governs everything that follows:
$$\vdash \Box_i a \quad\Longleftrightarrow\quad a \text{ is true at every world of } \mathrm{Im}_i .$$
And $\vdash a$ means, of course, that $a$ is true at every world of the chain. So the reflection rule for tag $i$ says precisely: *no formula of small box depth can tell the image of tag $i$ apart from the whole chain.* Reflection depth is a measure of resolution — how sharp a modal microscope you need before the tag's field of view becomes distinguishable from the whole world.

An immediate consequence, and the engine of the whole story: **reflection depth is monotone in the image**. If $\mathrm{Im}_i \subseteq \mathrm{Im}_j$, then every reflection rule valid for $i$ is valid for $j$, because the hypothesis "$a$ holds throughout $\mathrm{Im}_j$" is the stronger one. Two tags with *equal* images obey literally the same reflection rules. Contrapositively: **to give two tags different reflection depths, you must give them incomparable fields of view.**

## The conjecture, and why it fails

The most natural class of pictures makes each tag's accessibility a *truncation*: fix a number $c_i$, and let tag $i$ inspect everything below $m$ whenever $m \le c_i$, and nothing at all from higher worlds. This is a picture of a tag whose self-referential power runs out at level $c_i$. Add an arbitrary valuation on the chain and you have a two-parameter family: the truncation vector controls the tags, the valuation controls the atoms.

For these pictures the height is immediate: $H_i = \min(N, c_i)$, with the valuation contributing nothing. Meanwhile the reflection depth is very sensitive to the valuation. If every tag sees the whole chain and the atoms are true exactly at the worlds below some cut point $t$, the reflection depth of every tag is exactly $N - t$: the distance from the top of the chain to the place where the valuation changes. That is a lovely little theorem in its own right, and it suggested the conjecture:

> *The height is the distance from the top to where a tag's accessibility stops; the reflection depth is the distance from the top to where the valuation stops being constant. Two independent cut points of the same chain — so heights and depths should be freely choosable, subject only to $\rho_i \le H_i$.*

The conjecture is **false**, and the reason is structural. In a truncated picture, the image of tag $i$ is the initial segment $[0, \min(N,c_i))$. Initial segments are *nested*: any two of them are comparable. By the monotonicity principle, the reflection depths must then be monotone in the heights — and two tags of equal height, having literally the same image, must have literally the same reflection depth, no matter which valuation you choose. This is **rigidity**, and it kills the conjecture at once: ask for two tags of height $2$ with reflection depths $1$ and $0$, a request that obeys $\rho_i \le H_i$ on the nose, and no truncated picture with any valuation can grant it.

Rigidity is not the only obstruction. There is a second, quantitative one, and it is delivered by an explicit formula. For tags $i$ and $j$ and a distance $s$, consider the **gap probe**
$$G_{i,j}^{s} \;=\; \Box_i^{\,s}\bigl(\Box_j\bot \to \Box_i\bot\bigr),$$
a formula of box depth exactly $s+1$. A short computation shows exactly where it is true: at a world $m$ if and only if $m$ is above the reach of tag $i$ (where all of $i$'s boxes are vacuous) or within $s$ steps of the reach of tag $j$. Consequently, if some tag $j$ is strictly lower than $i$, the probe with $s = H_i - H_j - 1$ is provably necessary at $i$ but is not a theorem — it fails at the world $H_i$. So

$$\textbf{height-gap inequality:}\qquad H_j < H_i \;\Longrightarrow\; \rho_i \le H_i - H_j .$$

*The presence of a lower tag caps the trust the theory can place in a higher one.* The mere existence of a shorter neighbour, whose collapse can be compared with your own, gives the theory a cheap way to catch you out. And the same probe at distance $s = 0$ — the depth-one formula $\Box_j\bot \to \Box_i\bot$ — shows the dual fact:

$$\textbf{low-tag collapse:}\qquad H_j < H_i \;\Longrightarrow\; \rho_j \le 1 .$$

A tag that is strictly below some other tag can be trusted about box-free statements and essentially nothing more. Putting the two together: any two tags with reflection depth $\ge 2$ must have exactly the same height. Deep trust lives only on the top floor.

## The bounds are exactly right

Negative results of this kind are only as interesting as their matching positive half, and here the match is perfect on a natural family. Take a truncation vector with just two values: some tags high, at height $N$, some low, at height $L$, where $1 \le L < N$. Then, with the *information-free* valuation in which no atom is ever true, the reflection depths are

$$\rho_{\text{high}} = N - L, \qquad \rho_{\text{low}} = 1,$$

and by the two inequalities above these are the largest values any valuation could give. So on two-valued height vectors the reflection-depth vector is not an independent parameter at all: it is a computable function of the height vector.

The positive half is proved by a *bounded bisimulation* — a finite-resolution version of the classical back-and-forth game. Under the flat valuation the worlds carry no information beyond their position, and the low tags freeze the visible horizon at $L$. The precise statement is that two worlds $m$ and $n$ satisfy the same formulas of box depth $\le k$ as soon as
$$\min(m, L+k) = \min(n, L+k).$$
Each box in a formula moves the horizon down by one; a formula of depth $k$ can therefore count only as far as $L + k$. The top world $N$ stays indistinguishable from $N-1$ until depth $N - L$ — which is exactly where the gap probe strikes. The two cut points of the original conjecture survive, but the second one is not the valuation: **it is the height of the lowest other tag.**

## Repairing the conjecture: widen the windows

If nested images are the culprit, the cure is to build pictures whose images are *not* nested. Replace truncation by a **window**: give tag $i$ a top cut $H_i$ and a bottom cut $b_i$, and let $m$ inspect $n < m$ only when $m \le H_i$ *and* $n \ge b_i$. Such relations are still transitive, hence still GL, and the image of tag $i$ is now an interval $[b_i, \min(N,H_i))$ rather than an initial segment. Intervals can overlap without one containing the other — and that is precisely the freedom that was missing.

Here is the decoupling picture, in full. Fix $h \ge 2$ and take the chain $0, 1, \dots, h+1$. Tag $0$ looks down from the worlds $m \le h$ and sees everything below; tag $1$ looks down from the worlds $m \le h+1$ but never sees the bottom world $0$. Let the atoms be true exactly at the world $0$. Then:

* both tags have inconsistency height exactly $h$ — their towers of nested consistency statements are indistinguishable;
* tag $1$ has reflection depth $0$: the box-free formula $\neg p$ is true throughout its field of view $[1, h+1)$, yet false at the bottom world, so it is necessary at tag $1$ without being a theorem;
* tag $0$ has reflection depth exactly $1$: its field of view $[0,h)$ contains both a world where $p$ holds and a world where it does not, so it cannot be fooled by any box-free formula; but the depth-one formula $\Box_0\bot \to \Box_1\bot$ is true everywhere it can see, and false at the top world $h+1$, where tag $0$ is already exhausted while tag $1$ is not.

Two tags, equal heights, different depths. The images $[0,h)$ and $[1, h+1)$ are incomparable, exactly as the abstract principle demands. So the phenomenon the conjecture wanted is real — it simply cannot be produced by valuations. **The second cut point has to belong to the tag, not to the atoms.**

## What the numbers say

Small cases can be enumerated exhaustively, and they tell the same story crisply. Fix two live tags and a truncation level $N = 2$. The naive conjecture permits $36$ pairs (heights, depths). Truncated pictures with an arbitrary valuation realize exactly $22$ of them; every single missing profile is blocked by one of the obstructions above — rigidity, monotonicity of depth in height, or the height-gap inequality. Allow window pictures on up to five worlds and the count rises to $32$: ten of the fourteen forbidden profiles reappear, including all six with two tags of height $2$ and unequal depths — precisely the profiles rigidity had banned.

## Why this matters

Strip away the modal machinery and the moral is about *comparison*. A single self-referential system is limited by Löb's theorem, but it is limited *predictably*: its trust in itself decays at a rate you can compute from where its own reasoning power runs out. Put several such systems in the same universe of discourse, able to speak about each other, and something new happens: **their trustworthiness becomes entangled**. A theory containing a strong tag and a weak one can compare the two collapse points, and that comparison is itself a short, low-complexity statement — the gap probe is nothing more than "if the weak one is inconsistent, so am I", boxed a few times. The mere availability of that comparison caps how much the theory can trust its strong tag, and it flattens its trust in the weak one to almost nothing.

The escape route is equally telling. The theory can only be blocked by comparisons it is able to *make*. Tags whose fields of view are nested are always comparable, and nested fields of view are exactly what you get if all your tags differ only in *how far up* they still function. Tags that differ in what they can see at the bottom — one blind to the base case, another blind to the ceiling — are genuinely incomparable, and then their trustworthiness can be dialled independently. In the language of the pictures: to decouple two tags you must arrange for each to see something the other cannot.

There is also a pleasing methodological point. Everything above — soundness of the pictures, the computation of heights, the rigidity theorem, the sharpness of the two-valued spectrum, the decoupling family — flows from two general lemmas. One is the image theorem, which converts every question about provable boxes into a question about a set of worlds. The other is the bounded-bisimulation transfer principle: if you can match worlds back and forth for $k$ rounds, no formula of box depth $k$ can tell them apart. Between them they replace a small zoo of ad hoc computations by two sentences, and they are what makes the exact spectra computable at all.

## Where it goes next

The obvious open question is whether the conjecture, freed from the class of truncated pictures, is true in full: given any prescription of heights $H_i$ and depths $\rho_i \le H_i$, is there *some* finite transitive multi-tag picture realizing it exactly? The numerical census says yes for almost all small profiles, and the abstract principle says what such a construction must do — engineer a ladder of modal types in which each tag's field of view is placed at the prescribed rung, with prescribed incomparabilities. That is no longer a question about provability at all. It is a packing problem about intervals.

And that, in the end, is the shape of the result: a question about how much a theory can trust its own reflections turns into a question about which sets of worlds can be images of each other's complements — self-reference reduced to combinatorics.
