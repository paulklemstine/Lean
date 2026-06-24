# The Shape of a Shadow: Why Twisting a Set System Never Leaves a Gap

## A puzzle about counting

Imagine you have a small collection of objects laid out on a table — say, two coins, a penny and a nickel. Now play a game. Pick any subset of those coins to *flip over*: you may flip none of them, flip just the penny, flip just the nickel, or flip both. Each choice transforms the table into a new configuration. If you keep track of how many coins end up "heads," you discover something quietly remarkable: across all four possible flips, the number of heads takes every value from $0$ to $2$, and the counts come out as $1, 2, 1$.

That little sequence $1, 2, 1$ is not random. It is the second row of Pascal's triangle, $\binom{2}{0}, \binom{2}{1}, \binom{2}{2}$. And the deeper fact — the one this article is about — is that *no matter how you set up the game*, the sequence you get is always a full, gap-free row of Pascal's triangle. There is never a hole in the middle. You never find that the table can show $0$ heads or $2$ heads but somehow never exactly $1$.

This is a toy version of a question that mathematicians have argued about in the theory of **delta-matroids** and **ribbon graphs** — objects that sit at the crossroads of combinatorics, topology, and the algebra of knots and surfaces. The question is about *interpolation*: when you twist a structured object in every possible way and record a numerical "fingerprint" of each twist, does the fingerprint vary smoothly through a contiguous range, or can it skip values? The surprising resolution is that at the most fundamental level, **the answer is always "smoothly, with no gaps"** — and that the famous counterexamples where gaps *do* appear must therefore be blaming the wrong culprit.

## Set systems, feasible sets, and the symmetric exchange axiom

To tell the story properly we need three ingredients, each of which can be described in plain language.

First, a **ground set** $E$. This is just a finite collection of "coordinates" — the coins on the table, the edges of a graph, the columns of a matrix. In our running example $E = \{0, 1\}$, a set of two elements.

Second, a **set system** $D$: a family of subsets of $E$, each of which we call a **feasible set**. You should think of the feasible sets as the "allowed configurations." For instance, on the ground set $\{0,1\}$ we might take the family
$$D = \{\,\varnothing,\ \{0\},\ \{1\},\ \{0,1\}\,\},$$
which simply declares *every* subset feasible. This is the combinatorial analogue of a perfectly symmetric, unconstrained system — sometimes called a uniform delta-matroid.

Third, the rule that turns an arbitrary set system into a **delta-matroid**: **Bouchet's symmetric exchange axiom**. In words, it says that the feasible sets are "interchangeable" in a controlled, local way. Formally, for any two feasible sets $F$ and $G$ and any element $x$ in their symmetric difference $F \triangle G$ (the elements in exactly one of them), there is an element $y$ in $F \triangle G$ — possibly equal to $x$ — such that the set $F \triangle \{x, y\}$ obtained by toggling $x$ and $y$ is again feasible. This single axiom is the delta-matroid generalization of the familiar exchange axiom from the theory of matroids, and it is exactly what makes delta-matroids behave like geometric objects rather than arbitrary lists of sets. In our example, the full powerset trivially satisfies it, so $D$ above is a genuine delta-matroid.

## The twist: flipping the table

The "flip the coins" move has a precise name and a precise definition. Given a subset $A \subseteq E$ — the coins you choose to flip — the **twist** of the set system $D$ by $A$ is the new set system
$$D * A = \{\, F \triangle A \ : \ F \in D \,\},$$
where $\triangle$ is again symmetric difference. Each feasible set $F$ is replaced by $F \triangle A$: every coordinate inside $A$ gets toggled (in goes out, out comes in), every coordinate outside $A$ is left alone. Twisting is the central operation in the theory; it is also known as the *partial dual* or *partial Petrie dual* in the topology of ribbon graphs, where it corresponds to physically re-gluing ribbons of a surface.

Two facts about twisting are worth savoring. The first is that twisting is an **involution-rich, reversible** operation: twist by $A$ and then by $A$ again, and you are back where you started, because $(F \triangle A) \triangle A = F$. The whole collection of twists forms a group acting on set systems. The second, and more important, fact is a **closure theorem**:

> **Closure under twisting.** If $D$ satisfies Bouchet's symmetric exchange axiom, then so does every twist $D * A$. Delta-matroids are closed under the twist operation.

This is not obvious — the symmetric exchange axiom is a delicate condition, and one might worry that scrambling the feasible sets could break it. But it survives every twist. In our concrete example, once we know the full powerset on $\{0,1\}$ is a delta-matroid, the closure theorem immediately certifies that *every* twist of it — for instance, the twist by $\{0\}$ — is a delta-matroid too, without any further checking. The class of delta-matroids is a closed world under twisting; the twist group permutes its members.

## The fingerprint: a partial-twuality polynomial

Now we attach numbers. Fix a single feasible set $F \subseteq E$ and watch what happens to its *size* as we twist by every possible $A$. The natural bookkeeping device is a polynomial. For each integer $k$, define the coefficient
$$\mathrm{ptCoeff}(E, F, k) \ = \ \#\{\, A \subseteq E \ : \ |F \triangle A| = k \,\},$$
the number of twists that send $F$ to a set of exactly $k$ elements. Packaging these coefficients as a polynomial in a formal variable $z$ gives the **partial-twuality polynomial**
$$P_{E,F}(z) \ = \ \sum_{k \ge 0} \mathrm{ptCoeff}(E, F, k)\, z^k.$$

The polynomial records the *spectrum* of twisted sizes together with their multiplicities. The question of **interpolation** asks: as $k$ runs through the values where $\mathrm{ptCoeff}(E,F,k)$ is positive, do those values form an unbroken interval $\{lo, lo+1, \dots, hi\}$, or are there gaps — degrees in the middle of the range with a coefficient of zero? A polynomial whose support is a contiguous interval is called **interpolating**. The Gross–Mansour–Tucker *interpolating conjecture*, and its later analysis by Yan and Jin, is precisely a question about when such polynomials interpolate. Yan and Jin found genuine counterexamples among general ribbon graphs — polynomials that *do* skip values — but also proved interpolation holds in many structured situations. So the natural worry was that the twist operation itself might be capable of manufacturing gaps.

## The spectrum is always complete

Here is the heart of the matter. Fix the feasible set $F \subseteq E$ and ask: what sizes can $F \triangle A$ possibly have, as $A$ ranges over *all* subsets of $E$?

> **Spectrum theorem.** For any $F \subseteq E$, the set of attained sizes is exactly the full range:
> $$\{\, |F \triangle A| \ : \ A \subseteq E \,\} \ = \ \{0, 1, 2, \dots, |E|\}.$$

The proof is a small gem of bijective reasoning. The map $A \mapsto F \triangle A$ is a *bijection* of the powerset of $E$ to itself — its inverse is the same operation, $B \mapsto F \triangle B$, because $F \triangle (F \triangle A) = A$. So as $A$ sweeps over all subsets, the twisted set $B = F \triangle A$ *also* sweeps over all subsets of $E$, hitting each exactly once. Therefore the sizes $|F \triangle A|$ are precisely the sizes $|B|$ of arbitrary subsets $B \subseteq E$ — and those obviously run through every value from $0$ (the empty set) to $|E|$ (all of $E$), with nothing missing. Concretely, to realize a target size $k$ you choose any $k$-element subset $B \subseteq E$ and twist by $A = F \triangle B$; this lands $F$ exactly on $B$.

From this single observation everything cascades.

> **Positivity criterion.** A coefficient is nonzero precisely when its degree is in range:
> $$\mathrm{ptCoeff}(E, F, k) > 0 \quad\Longleftrightarrow\quad k \le |E|.$$

Because every value in $\{0,\dots,|E|\}$ is attained, and no twist can ever exceed the ground set's size (a twisted set is still a subset of $E$), the support of the polynomial is the entire interval $[0, |E|]$ — no more, no less.

> **Interpolation theorem.** The partial-twuality polynomial of a single feasible set is *always interpolating*, with support exactly the full interval $[0, |E|]$.

There is no structure to impose, no hypothesis to check beyond $F \subseteq E$. The single-feasible-set polynomial interpolates unconditionally.

We can say even more about its exact shape. Counting the twists that achieve size $k$ is the same as counting $k$-element subsets $B$, since $A \mapsto F \triangle A$ is a size-preserving-in-count bijection onto the powerset. Hence
$$\mathrm{ptCoeff}(E, F, k) = \binom{|E|}{k}, \qquad P_{E,F}(z) = (1+z)^{|E|}.$$
The fingerprint of a single feasible set is *always* a complete row of Pascal's triangle, raised through the binomial theorem. For $|E| = 2$ that row is $1, 2, 1$ — exactly the coin-flip count we started with — and our worked example confirms it: on $E = \{0,1\}$ with $F = \{0\}$, the coefficients on degrees $0, 1, 2$ are $1, 2, 1$.

## Not a fluke of triviality

A skeptic might object that this is too clean to be meaningful — perhaps the polynomial is always just a single term, and "interpolation" is vacuous. It is not.

> **Nontriviality.** Whenever the ground set $E$ is nonempty, the support of the polynomial contains at least two distinct degrees — namely $0$ and $|E|$.

So the polynomial is never a lonely monomial; it genuinely spreads its mass across a real interval of degrees, and the claim that there are no internal gaps has actual content. For a two-element ground set, the support $\{0, 1, 2\}$ has three degrees, all populated.

There is one more structural surprise, and it explains *why* this fingerprint deserves to be called an invariant.

> **Twist invariance.** Replacing the base feasible set $F$ by any twist $F \triangle B$ does not change a single coefficient of the polynomial. That is, $\mathrm{ptCoeff}(E, F \triangle B, k) = \mathrm{ptCoeff}(E, F, k)$ for all $B \subseteq E$ and all $k$.

The reason is again a clean bijection: twisting the base by $B$ merely relabels the index $A \mapsto B \triangle A$ over which we are counting, and relabeling does not change a count. So the polynomial does not really belong to $F$ alone — it belongs to the entire *twist orbit* of $F$, the family of all sets reachable from $F$ by twisting. It is a true invariant of the orbit, exactly as the Gross–Mansour–Tucker framework demands.

## Where the gaps really come from

Now we can return to the puzzle that motivated the whole subject. If the partial-twuality polynomial of a single feasible set is *always* the gap-free binomial $(1+z)^{|E|}$, then the twist operation by itself is *incapable* of producing a gap. Twisting is contiguity-preserving at the atomic level.

So where do the genuine counterexamples — the ribbon graphs whose polynomials skip values — get their gaps? The answer, sharpened by these results, is that the gaps are an **emergent, collective phenomenon**. They arise only when a delta-matroid has *several* feasible sets that interact, and when the full polynomial superimposes the contributions of all of them. Each feasible set on its own contributes a complete, gap-free binomial spectrum. But when you sum these spectra with the weighting prescribed by the wider theory — for instance, by the *width* of a delta-matroid, the spread between its largest and smallest feasible sets — parity obstructions and arithmetic cancellations between the pieces can conspire to empty out a degree in the middle. The hole is never in any one shadow; it appears only in the overlap.

This reframing turns a confusing landscape into a clear research program. We now know exactly where *not* to look for the source of gaps (the twist mechanism, which is innocent) and exactly where to look (the combination of multiple feasible sets, especially their parities). It suggests crisp conjectures: that a delta-matroid's *width* polynomial interpolates if and only if all its feasible sets share one parity; that **binary** delta-matroids — those representable by a symmetric matrix over the two-element field $\mathrm{GF}(2)$ — never have gaps, because pivoting over $\mathrm{GF}(2)$ moves rank by single steps and so preserves contiguity; and that the *loop-complementation* operation, which together with twisting generates the full six-element "twuality group," likewise preserves interpolation because it too acts by single-coordinate moves.

## Why it matters beyond the table

It is tempting to dismiss all this as combinatorial bookkeeping, but delta-matroids and their twists are a genuine bridge between distant fields. Ribbon graphs encode the topology of surfaces with boundary; their partial duals are how topologists slide between a graph drawn on a sphere, a torus, or a Klein bottle. The same polynomials reappear in the study of the **Bollobás–Riordan polynomial** and in knot theory, where twisting models the recombination of strands. In each setting, "interpolation" is a statement about *continuity of complexity*: as you deform the object through its symmetry group, does its complexity vary smoothly, or can it jump?

The lesson of the spectrum theorem is reassuring and clarifying. At the level of a single feasible set, complexity is perfectly continuous — every intermediate size is realized, the fingerprint is always a full row of Pascal's triangle, and the twist group merely permutes a fixed, gap-free spectrum. Any roughness in the landscape — any jump, any hole — is not a property of the twisting motion but of the *chorus* of feasible sets singing together. The coins on the table never lie. It is only when many tables are overlaid that a shadow can fall in the gap.
