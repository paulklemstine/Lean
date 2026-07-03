# When Shuffles Must Agree: A Hidden Bridge Between Card Tricks and Extremal Mathematics

Imagine two people are each handed the same deck of cards and asked to shuffle it. When they lay their decks side by side and compare position by position — top card against top card, second card against second card, and so on — how often will they find a match? Sometimes a card lands in exactly the same slot in both shuffles. Sometimes no card matches at all. That second, matchless situation has a memorable name in mathematics: a *derangement*, a rearrangement that leaves nothing in its original place.

This simple picture — comparing two shuffles slot by slot — turns out to be the doorway into one of the most elegant chapters of modern combinatorics: the theory of **intersecting families of permutations**. It is a story about how many shuffles you can collect into a club with the rule that *every two members must agree somewhere*, and it connects card tricks, seating charts, coding theory, and a beautiful principle discovered by Michel Deza and Péter Frankl in 1977. This article tells that story from the ground up, and it reveals a single clean idea — what we will call the **fixed-point bridge** — that makes the whole subject snap into focus.

## Permutations, agreements, and derangements

A **permutation** of $n$ objects is just a way of rearranging them. We can think of it as a function $\sigma$ that takes a position $i \in \{0, 1, \dots, n-1\}$ and returns the object $\sigma(i)$ sitting there. Two permutations $\sigma$ and $\tau$ **agree at position $i$** when they place the same object there, that is, when $\sigma(i) = \tau(i)$. The collection of all such matching positions is their **agreement set**.

For example, with three positions, the shuffle that reads $(1,2,3)$ — cycling everything forward — and the shuffle that reads $(1,3,2)$ — a single swap — disagree everywhere: no card sits in the same slot in both. They are, relative to one another, a derangement. But the "do nothing" shuffle agrees with *any* other shuffle exactly at that other shuffle's fixed points.

A **derangement** is a permutation with no fixed point at all: nothing stays put. Derangements are the permutations of maximum disagreement, and they are the natural villains of our story. If two shuffles never agree anywhere, the permutation that transforms one into the other is a derangement.

## The central trick: the fixed-point bridge

Here is the observation that organizes everything. Suppose we want to know where $\sigma$ and $\tau$ agree. Instead of comparing them directly, form a single new permutation, the **quotient** $\sigma^{-1}\tau$ — first undo $\sigma$, then apply $\tau$. Then the following is true at every single position $i$:

$$\sigma(i) = \tau(i) \quad\Longleftrightarrow\quad (\sigma^{-1}\tau)(i) = i.$$

In words: **$\sigma$ and $\tau$ agree at position $i$ precisely when the quotient $\sigma^{-1}\tau$ fixes $i$.** This is the fixed-point bridge. It is almost trivial to check — apply $\sigma^{-1}$ to both sides of $\sigma(i) = \tau(i)$ — yet it is astonishingly powerful, because it converts a statement about *two* permutations into a statement about the fixed points of a *single* derived permutation.

The consequences cascade immediately. The agreement set of $\sigma$ and $\tau$ is *exactly* the fixed-point set of $\sigma^{-1}\tau$. The **number** of agreements is therefore

$$\#\{\text{agreements of } \sigma, \tau\} = n - \big|\operatorname{support}(\sigma^{-1}\tau)\big|,$$

where the *support* of a permutation is the set of points it actually moves. Two shuffles agree a lot exactly when their quotient moves few things; they agree nowhere exactly when their quotient is a derangement.

## Clubs of shuffles that always agree

Now we can pose the extremal question that drives the field. Call a family $F$ of permutations **intersecting** if every two of its members agree in at least one position. How large can such a family be?

Through the fixed-point bridge, this dresses up in group-theoretic clothing: **a family is intersecting if and only if, for every pair of members, the quotient $\sigma^{-1}\tau$ has a fixed point — that is, no quotient is a derangement.** The entire set-theoretic bookkeeping of "which positions match" evaporates, replaced by the single clean condition "avoid derangements among your quotients."

There is an obvious way to build a large intersecting family: **fix a position.** Take all the shuffles that leave, say, the top card exactly where it started. Any two of them agree at that position by construction, so the family is intersecting. How big is it? A shuffle of $n$ cards that pins one card in place is just a shuffle of the remaining $n-1$ cards, so there are $(n-1)!$ of them. Deza and Frankl proved in 1977 that you cannot do any better: **no intersecting family of permutations of $n$ objects has more than $(n-1)!$ members**, and the position-fixing families are the extremal examples.

## Raising the bar: agreeing in many places

The richer and more modern version of the problem asks members to agree not just *somewhere* but in *many* places. A family is **$t$-intersecting** if every two of its members agree in at least $t$ positions. This is the permutation analogue of the celebrated **Complete Intersection Theorem** for sets, and it sits at the heart of work by Deza and Frankl and, more recently, sharp results of Kupavskii and collaborators.

The natural champion is the **prefix stabilizer**: fix the first $t$ positions all at once, and let everything else shuffle freely. Concretely, on $t + m$ points, take every permutation that leaves each of the first $t$ points untouched. Two such permutations automatically agree on all of positions $0, 1, \dots, t-1$, so the family is $t$-intersecting by design. And its size is exactly

$$|{\text{prefix stabilizer}}| = m! = (n - t)!,$$

because a permutation fixing the first $t$ points is nothing more than a permutation of the remaining $m = n - t$ points.

**This article's central mathematical result is a clean, constructive proof that this extremal family exists, is genuinely $t$-intersecting, and has exactly $(n-t)!$ members** — the lower-bound half of the permutation Complete Intersection Theorem. We state it precisely:

> **Theorem (Large extremal $t$-intersecting family).** For every $t \geq 0$ and $m \geq 0$, on the set of $t+m$ objects the family of all permutations fixing each of the first $t$ objects is $t$-intersecting and has exactly $m! = (n-t)!$ members, where $n = t + m$.

Taking $t = 1$ recovers the classical Deza–Frankl lower bound of $(n-1)!$ for ordinary intersecting families.

## How the counting really works

Why exactly $m!$? There is a slick way to see it that also explains why the same argument handles the edge cases $m = 0$ (only the identity remains, and $0! = 1$) and $t = 0$ (no constraint at all, and every one of the $(t+m)!$ permutations qualifies).

Encode "fixing the first $t$ points" as *preserving a labelling*. Paint the first $t$ objects with $t$ distinct colors, and paint all remaining $m$ objects with a single shared color. A permutation fixes the first $t$ points if and only if it never changes any object's color — it may only permute objects *within* a color class. The color classes here are $t$ singletons and one big block of size $m$. The number of color-preserving permutations is then the product of the factorials of the class sizes,

$$\underbrace{1! \cdot 1! \cdots 1!}_{t \text{ times}} \cdot \, m! = m!,$$

a special case of the general principle that the permutations preserving a partition number the product of the factorials of the block sizes. The only subtle point is checking that "preserves the coloring" is truly equivalent to "fixes the first $t$ points" — the forward direction is immediate, and the reverse uses that a permutation is a bijection, so a color-preserving map that keeps each of the $t$ special singletons in its own class must fix each of them individually.

## Why this matters beyond the parlor

The theory of intersecting permutations is not a curiosity. It is the permutation face of the **Erdős–Ko–Rado** and **Complete Intersection** theorems, cornerstones of extremal set theory with applications throughout computer science and information theory. Constraining how often codewords may agree is exactly the language of **error-correcting codes** and **permutation codes** used in flash memory and powerline communication. Seating and scheduling problems, where you want many arrangements that never fully conflict, wear the same mathematical uniform. And the fixed-point bridge — recasting "agreement" as "fixed points of a quotient" — is precisely the reformulation that lets powerful tools from the study of derangements and the representation theory of the symmetric group be brought to bear.

What makes the story satisfying is the compression. A messy-sounding extremal problem about matching positions across all pairs in a family becomes a crisp statement about avoiding derangements, and the extremal construction becomes a single vivid act: **pin down a prefix and let the rest run wild.** The count falls out of coloring.

## The horizon

The construction settles the *lower* bound — such a large family provably exists. The natural sequel is the matching *upper* bound: proving that once $n$ is large compared to $t$, no $t$-intersecting family can beat $(n-t)!$, and that the prefix stabilizer is essentially the *only* way to achieve it. Because the fixed-point bridge reduces this to understanding how rare permutations with many fixed points are inside the symmetric group, the remaining challenge is a clean counting-and-spectral estimate rather than an open-ended combinatorial hunt.

Beyond that lie tantalizing variants: replacing the strict rule with an *average* one, where a family is allowed if its typical pair disagrees only mildly; **cross-intersecting** pairs of families $A$ and $B$ where every member of one must agree with every member of the other, with a conjectured optimum of $((n-t)!)^2$; and the study of exactly which sets of agreement-counts can occur — the *fixed-point spectra* of the symmetric group. Each of these is unlocked by the same small, sharp idea: to understand when two shuffles agree, look at the fixed points of a single shuffle standing between them.
