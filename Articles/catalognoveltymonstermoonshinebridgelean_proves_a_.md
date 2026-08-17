# Moonshine Without the Moon

## What survives when you strip the magic out of one of mathematics' strangest coincidences

In 1978 the mathematician John McKay noticed something that should not have happened. He was reading about two subjects that had nothing to do with each other. On one side was the **Monster**, the largest of the sporadic finite simple groups — a symmetry group so vast that writing out its size takes 54 digits, roughly $8 \times 10^{53}$. On the other side was the **$j$-function**, a classical object from nineteenth-century complex analysis whose expansion begins

$$j(q) = \frac{1}{q} + 744 + 196884\,q + 21493760\,q^2 + \cdots.$$

McKay knew that the Monster's smallest nontrivial irreducible representation has dimension $196883$. And $196884 = 196883 + 1$.

That single arithmetic accident grew into the theory of **monstrous moonshine**: the Monster acts on an infinite graded space, and for each element $g$ of the group one forms a generating function
$$T_g(q) = \sum_{n} \operatorname{tr}(g \mid V_n)\, q^{n},$$
recording the trace of $g$ on each graded piece. Miraculously, each of these $194$ series (one for each conjugacy class) is a highly structured modular function. The average of all of them, $\frac{1}{|M|}\sum_g T_g$, is essentially the $j$-function itself.

This article is about a question that sits underneath all of that romance. **How much of the moonshine picture is really about the Monster and modular forms — and how much of it is a general fact about groups acting on things, true for the symmetries of a triangle just as much as for the Monster?**

The answer, it turns out, is: a surprising amount is general. And what is general can be pushed much further than the classical picture suggests. Below is a tour of a hierarchy of exact identities, an inequality governed by the Bell numbers, a criterion that reads a deep permutation-group property off a single integer, a theorem saying that finitely many averages pin down an entire distribution, and finally a precise diagnosis of *why* the most seductive version of the moonshine slogan — "multiply all the series together" — cannot work.

---

## Traces you can count on your fingers

Start with the simplest possible model of a graded group action. Let $G$ be a finite group acting on a finite set $X$ — think of the rotations of a cube acting on its six faces. Instead of a trace of a matrix, use the most primitive trace there is: the number of things $g$ leaves alone,
$$|X^g| = \#\{x \in X : g\cdot x = x\}.$$
This *is* a trace: it is the character of the permutation representation. If the action is graded — a set $X_n$ for each $n \ge 0$ — then each element $g$ gets its own generating function
$$T_g(q) = \sum_{n \ge 0} |X_n^g|\, q^n,$$
a stripped-down, purely combinatorial McKay–Thompson series.

Two facts are immediate and both are structural rather than accidental. First, $T_g$ depends only on the conjugacy class of $g$: conjugate elements have bijective fixed-point sets, coefficient by coefficient. So these element-indexed series genuinely descend to class functions, exactly as in moonshine. Second, their average is meaningful. Burnside's orbit-counting lemma says
$$\sum_{g \in G} |X^g| = |G| \cdot |X/G|,$$
and applying it in each grade gives the *moonshine average* in its most elementary incarnation:
$$\sum_{g \in G} T_g(q) = |G| \cdot O(q), \qquad O(q) = \sum_{n\ge 0} |X_n/G|\, q^n.$$
The average of all the trace series is the orbit-counting series. That is the shadow, in this toy world, of "the average of the McKay–Thompson series is the $j$-function".

## Higher moments: a whole hierarchy nobody averages over

Burnside's lemma is a statement about the *first* moment. What about the second, the third, the $k$-th? Here is the identity that organizes everything that follows.

> **Moment Hierarchy.** For a finite group $G$ acting on a finite set $X$ and every $k \ge 0$,
> $$\sum_{g\in G} |X^g|^{k} \;=\; |G| \cdot \#\bigl(X^{k}/G\bigr),$$
> where $X^k$ is the set of $k$-tuples of elements of $X$ with $G$ acting diagonally.

The proof is a single observation plus Burnside. An element $g$ fixes a $k$-tuple exactly when it fixes each coordinate, so the fixed points of $g$ on $X^k$ are the $k$-tuples of fixed points of $g$ on $X$: $|(X^k)^g| = |X^g|^k$. Now apply Burnside to $X^k$.

At $k=1$ this is Burnside. At $k=2$ it is the classical statement that $\frac{1}{|G|}\sum_g|X^g|^2$ is the **rank** of the permutation action — the number of orbits on ordered pairs. Beyond that, the hierarchy is a ladder of integers, each rung an exact count, and it is the ladder we will climb.

Two things are worth knowing right away. The rungs grow at least geometrically: $|X/G|^k \le \#(X^k/G)$, because tuples of orbit representatives already give distinct orbits. And the inequality is astonishingly rigid at $k=2$: equality $|X/G|^2 = \#(X^2/G)$ holds **if and only if the group acts trivially**, fixing every point. A single equation between two orbit counts detects triviality of the action.

## Bell numbers appear from nowhere

Now for the surprise. Fix $k$ and ask: how small can $\#(X^k/G)$ possibly be? Even with the biggest imaginable group — the full symmetric group on $X$, which can rearrange points however it wishes — you can never merge two $k$-tuples that *disagree about which of their coordinates are equal*. The tuple $(x, x, y)$ and the tuple $(x,y,z)$ with $x,y,z$ distinct will never be in the same orbit, because group elements are bijections and bijections preserve coincidences.

So every orbit of $k$-tuples carries an invariant: the **kernel pattern**, the partition of the index set $\{1,\dots,k\}$ into blocks of coordinates that hold the same value. A convenient way to encode it is as the map sending each index $i$ to the *smallest* index $j$ with $f(j) = f(i)$; the resulting functions $p$ are exactly the *restricted growth functions*, satisfying $p(i)\le i$ and $p\circ p = p$. They are in canonical bijection with the set partitions of a $k$-element set, and the number of them is the $k$-th **Bell number**:
$$B_0,B_1,B_2,B_3,B_4,B_5,\dots = 1,\,1,\,2,\,5,\,15,\,52,\dots$$

Every pattern actually occurs, as long as $X$ has at least $k$ points: any partial assignment of distinct values extends to an injective tuple. This gives the universal floor.

> **Bell Floor.** If $k \le |X|$ then $B_k \le \#(X^k/G)$, and therefore, for every finite group action,
> $$B_k \cdot |G| \;\le\; \sum_{g \in G} |X^g|^{k}.$$

For $k=1$ this is $|G| \le \sum_g |X^g|$, the trivial half of Burnside ($B_1 = 1$). For $k=2$ it says the rank of a permutation action is at least $2$. For $k=5$ it says the fifth moment of the fixed-point function is at least $52\,|G|$.

## The floor is reached exactly at $k$-transitivity

Inequalities are interesting when you know their equality case, and here the equality case is a famous property. Recall that an action is **$k$-transitive** if any injective $k$-tuple can be carried to any other injective $k$-tuple by some group element — you can send any $k$ distinct points, in order, to any other $k$ distinct points, in order. This is the classical measure of how strongly a permutation group mixes its points; $2$-transitive groups have been classified, and the only $5$-transitive groups other than symmetric and alternating groups are two of the sporadic Mathieu groups.

> **Bell Criterion.** Let $G$ act on a finite set $X$ with $k \le |X|$. Then
> $$\sum_{g \in G} |X^g|^{k} = B_k \cdot |G| \quad \Longleftrightarrow \quad \#(X^k/G) = B_k \quad\Longleftrightarrow\quad \text{the action is } k\text{-transitive}.$$

The proof is a study of the map "orbit of a tuple $\mapsto$ its kernel pattern". Surjectivity is the extension argument above and holds always. Injectivity says: two tuples with the same coincidence pattern are in the same orbit. If the action is $k$-transitive, that follows by extending the two tuples, restricted to one representative per block, to injective tuples and moving one to the other. Conversely if the map is injective then in particular all injective tuples (which share the trivial pattern) are in one orbit — which is $k$-transitivity verbatim. Comparing cardinalities of the source and target of a surjection turns "injective" into "$\#(X^k/G) = B_k$", and the moment hierarchy converts that into a statement about a single sum of $k$-th powers.

So one integer — the $k$-th moment of the trace family — decides a purely group-theoretic property. That is a genuine bridge: character-theoretic data on one side, permutation-group structure on the other, enumerative combinatorics (Bell numbers) as the exchange rate.

Two sanity checks make it concrete. The full symmetric group $S_n$ is $k$-transitive for every $k \le n$, so
$$\sum_{\sigma \in S_n} |\mathrm{fix}(\sigma)|^{k} = B_k \cdot n! \qquad (k \le n),$$
which is the classical Bell-number formula for the moments of the number of fixed points of a random permutation. And because a $(k+1)$-transitive action is $k$-transitive, extremality of one moment forces extremality of every lower one: the hierarchy is monotone.

## How far above the floor are you? The Bell defect, counted exactly

If the moment is not minimal, its excess is not a vague error term; it counts something. For each pattern $P$ of $\{1,\dots,k\}$ let $m_P$ be the number of orbits of $k$-tuples having kernel pattern $P$ — the size of the fibre of the orbit-to-pattern map. Then $\sum_P m_P = \#(X^k/G)$ and each $m_P \ge 1$. Hence:

> **Bell Defect Formula.** For $k \le |X|$,
> $$D_k \;=\; \sum_{g\in G} |X^g|^{k} - B_k\,|G| \;=\; |G| \sum_{P} (m_P - 1),$$
> the sum being over the $B_k$ patterns. The defect vanishes precisely when every fibre is a singleton, i.e. exactly for $k$-transitive actions.

The failure of transitivity is thus *localized*: it tells you which coincidence patterns split into several orbits, and by how much.

## Finitely many averages know everything (about the averages)

Moonshine-style data comes as a family of series indexed by group elements. A natural question: how much of that family is recoverable from the moments alone? The answer is clean.

> **Moments Determine the Distribution.** Let $a$ and $b$ be integer-valued functions on finite index sets, both bounded above by $N$. If $\sum_i a(i)^k = \sum_j b(j)^k$ for every $k \le N$, then $a$ and $b$ have the same *multiset* of values. The range $k \le N$ is sharp: $(0,2)$ and $(1,1)$ agree for $k=0,1$ but have different distributions.

The mechanism is linear algebra: a power sum $\sum_i a(i)^k$ equals $\sum_{v=0}^{N} c_v v^k$ where $c_v$ counts indices with $a(i) = v$. The matrix $(v^k)_{0 \le k,v \le N}$ is a Vandermonde matrix with distinct nodes $0,1,\dots,N$, hence invertible over the rationals, so the counting vector $c$ is determined.

Translated back into the moonshine setting, with $\lvert X\rvert,\lvert Y\rvert \le N$:

> Two finite $G$-actions have the **same trace distribution** — the same multiset $\{|X^g| : g \in G\}$ — if and only if they have the same number of orbits on $k$-tuples for all $k \le N$ (equivalently, for all $k$).

Consequences cascade. The number of fixed-point-free elements, the total number of orbits, and — combining with the Bell criterion — the entire $k$-transitivity spectrum of the action are all invariants of the trace distribution.

But there is a hard limit, and it is worth stating because it is the honest counterweight to moonshine mysticism. **The trace distribution is not a complete invariant of an action.** Take the Klein four-group $V = S_2 \times S_2$ and let it act on a two-point set through its first factor, and separately through its second factor. Swapping factors is a bijection of the group matching up fixed-point counts, so the two actions have identical trace distributions and identical orbit counts on $k$-tuples for every $k$. Yet they are not isomorphic as $G$-sets: the element $(\text{swap}, 1)$ moves every point in the first action and fixes every point in the second. No amount of moment data can tell them apart.

## Why you cannot multiply all the moonshine series together

Finally, the reason this whole investigation began. A tempting slogan says: take all $194$ McKay–Thompson series of the Monster, multiply them, and out comes a single modular object encoding the whole group. It is a beautiful idea, and it is false for a very concrete reason — which is worth making precise rather than waving away.

Each McKay–Thompson series is normalized so that its expansion at the cusp starts with $q^{-1}$: it has a simple pole. Orders add under multiplication. Therefore:

> **Pole-Order Obstruction.** A product of $m$ series each of order exactly $-1$ has order exactly $-m$. A product of $194$ normalized series has a pole of order $194$; it is never holomorphic at the cusp. Multiplying by $q^{m}$ restores order $0$.

Is the pole the *only* obstruction? Yes — and completely so.

> **Renormalized products realize everything.** For every $m \ge 1$, a Laurent series $F$ equals a renormalized product $q^m \prod_{i=1}^m f_i$ of $m$ normalized series if and only if $F$ has order exactly $0$ at the cusp. Moreover such a factorization is never unique — flipping the sign of two factors gives another one — so the renormalized product cannot be inverted.

That non-uniqueness is not an accident of an example. It is a theorem about symmetry:

> **No unlabeled aggregate is faithful.** Let $m \ge 2$ and let $A$ be any aggregation rule taking a family of $m$ series to a single series with $A(f\circ\sigma) = A(f)$ for every permutation $\sigma$ of the labels. Then $A$ is not injective.

The proof is two lines: feed $A$ a family whose first two entries differ and compare it with its transposition. Since multiplication is commutative, "multiply all the series" is such an $A$, so it necessarily forgets. Information loss is caused by *symmetry itself*, not by any special feature of multiplication.

And the dichotomy is genuine, because faithful aggregates do exist — they just have to remember labels. Interleave the coefficients: place the $i$-th series' $n$-th coefficient in position $mn+i$ of a single series. This aggregate is injective; every member can be read back off by extracting the right arithmetic progression of coefficients. By the theorem above, it therefore cannot be permutation-invariant. You may have a single scalar object that remembers the whole family, or one that treats the labels as interchangeable, but not both.

---

## What the tour shows

Strip away the modular forms, the vertex operator algebras and the $54$-digit group, and a robust skeleton of moonshine remains. Element-indexed trace series exist for any graded finite group action; they are class functions; their average is the orbit-counting series. Their higher moments form an exact hierarchy of orbit counts on tuples. That hierarchy has a universal floor given by the Bell numbers, attained exactly at $k$-transitivity, with the excess counted exactly by the fibres of a natural map from orbits to set partitions. The whole trace distribution is determined by finitely many moments and no fewer — and yet it does not determine the action.

Meanwhile, the parts of the moonshine slogan that fail, fail for reasons one can name: an additive pole order that no amount of cleverness will cancel, and the commutativity of multiplication, which erases labels as a matter of logic.

There is something bracing about this. The Monster's coincidence with the $j$-function remains as mysterious as ever; nothing here explains it. But it says that the *shape* of moonshine — traces indexed by group elements, averaged into a canonical object, with moments reading off structure — is not exotic at all. It is the shape of counting orbits, and it is available every time a finite group acts on anything.
