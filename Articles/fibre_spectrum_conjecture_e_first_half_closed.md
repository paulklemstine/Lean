# The Shape of a Symmetry, Read Off From Its Coincidences

## A counting problem with a hidden skeleton

Take a set $X$ with $n$ elements and a group $G$ of symmetries acting on it — think of the eight symmetries of a square acting on its four corners, or all $24$ shufflings of four cards. Now stop looking at single points and look instead at *lists*. A $k$-tuple is an ordered list $f = (f_1, \dots, f_k)$ of points of $X$, repetitions allowed. There are $n^k$ of them, and the group acts on them all at once, moving $(f_1,\dots,f_k)$ to $(g\cdot f_1, \dots, g\cdot f_k)$.

The natural question is: **how many essentially different lists are there?** That is, how many orbits does $G$ have on $X^k$? Write this number $\#(X^k/G)$. As $k$ grows, this sequence
$$1,\; \#(X/G),\; \#(X^2/G),\; \#(X^3/G),\; \dots$$
is one of the oldest and richest invariants attached to a permutation group. For the symmetric group $S_4$ on four points it begins $1, 1, 2, 5, 15$ — the Bell numbers. For the dihedral group of the square it begins $1, 1, 3, 10, 36$. For the alternating group $A_4$: $1, 1, 2, 6, 22$.

Those sequences look unrelated. This article is about the discovery that they are not: each of them is the image, under one fixed and completely universal transformation, of a *short, monotone* list of integers — a list no longer than $n+1$ entries. The whole infinite tower of orbit counts is a shadow of that short list. We call it the **fibre spectrum** of the action.

## Coincidence patterns

Here is the key move. A tuple carries a piece of purely combinatorial information that no symmetry can destroy: the record of *which of its entries coincide*.

Take $X = \{a,b,c\}$ and the tuple $(a, b, a, a)$. Its *coincidence pattern* is the partition of the index set $\{1,2,3,4\}$ into blocks of positions holding the same value: $\{1,3,4\},\{2\}$. Applying any symmetry $g$ turns the tuple into $(g a, g b, g a, g a)$, which has exactly the same pattern, because $g$ is a bijection: it can move values around, but it can never make two equal entries unequal, nor two unequal entries equal.

So every orbit of tuples has a well-defined pattern, and we get a map
$$\pi:\; X^k/G \longrightarrow \{\text{set partitions of } \{1,\dots,k\}\}.$$
The set partitions of a $k$-element set are counted by the **Bell number** $B_k$: $B_0=1$, $B_1=1$, $B_2=2$, $B_3=5$, $B_4=15$, $B_5=52$, growing faster than any exponential but far slower than $k!$.

The map $\pi$ organises the orbits into $B_k$ **fibres**, one over each pattern $P$. Write $m_P$ for the size of the fibre over $P$: the number of orbits of tuples whose coincidence pattern is exactly $P$. Three facts about these numbers are immediate once one thinks about them, and together they already say something:

- **The fibres partition the orbits:** $\displaystyle \#(X^k/G) = \sum_P m_P$, the sum ranging over all $B_k$ patterns.
- **No fibre is empty** (as long as $k \le n$, so that there are enough points to realise every pattern): $m_P \ge 1$ for every $P$.
- **Every fibre is a singleton exactly when the action is $k$-transitive**, i.e. when $G$ can carry any $k$ distinct points to any other $k$ distinct points.

Put together, these give the **Bell floor**: for $k \le n$ one always has $\#(X^k/G) \ge B_k$, with equality precisely for the $k$-transitive actions. The Bell numbers appear as the exact minimum of a group-theoretic counting problem, and $k$-transitivity is characterised as the case of maximal degeneracy. Check it against the numbers above: $S_4$ on four points is $4$-transitive, and indeed its orbit counts $1,1,2,5,15$ *are* the Bell numbers. $A_4$ is only $2$-transitive, and its count $6$ at $k=3$ exceeds $B_3 = 5$ by exactly one.

That was the state of the story. The obvious next question is: what are the numbers $m_P$? A priori there are $B_k$ of them, an explosively growing family of independent unknowns — one per pattern, $52$ of them at $k=5$, $4{,}213{,}597$ at $k=15$.

## The rank collapse

They are not independent at all. In fact almost all of them are equal, and here is why.

Let $P$ be a pattern with $r$ blocks; call $r$ the **rank** of $P$. Choose one representative index in each block — say the smallest, so the blocks get *leaders* $i_1 < i_2 < \dots < i_r$. Now do two things to a tuple:

- **Shrink.** Given a $k$-tuple $f$ with pattern exactly $P$, keep only the entries at the leader positions: $\mathrm{sh}(f) = (f_{i_1}, \dots, f_{i_r})$. Because $f$'s coincidences are *exactly* those prescribed by $P$, distinct blocks carry distinct values, so $\mathrm{sh}(f)$ is an **injective** $r$-tuple.
- **Grow.** Given any injective $r$-tuple $h$, build the $k$-tuple that puts $h_j$ at every index of the $j$-th block. Its pattern is exactly $P$.

These two operations are mutually inverse, and both commute with the group action, so they descend to orbits. The conclusion is the **Rank Collapse Theorem**:

> **Theorem (Rank collapse).** For every pattern $P$ of $\{1,\dots,k\}$,
> $$m_P = t_{\operatorname{rank} P},$$
> where $t_r$ denotes the number of $G$-orbits of *injective* $r$-tuples.

The multiplicity of a fibre does not depend on the pattern — only on how many blocks it has. Note the striking absence of hypotheses: no relation between $k$ and $n$ is needed. If $k$ exceeds $n$, both sides simply vanish for high ranks, and the identity still holds.

The numbers $t_0, t_1, t_2, \dots$ are the **fibre spectrum**. There are at most $n+1$ interesting ones, because $t_r = 0$ as soon as $r > n$: there are no injective tuples longer than the set. And $t_0 = 1$ always, the empty tuple being alone.

For the dihedral group of the square, $n = 4$ and the spectrum is
$$(t_0,t_1,t_2,t_3,t_4) = (1,\,1,\,2,\,3,\,3).$$
Five numbers. From them, as we will now see, *every* orbit count follows.

## From five numbers to the whole tower

Group the $B_k$ patterns by rank. The number of patterns of $\{1,\dots,k\}$ with exactly $r$ blocks is the **Stirling number of the second kind** $S(k,r)$ — the familiar triangle
$$\begin{array}{c|cccccc} k\backslash r & 0&1&2&3&4&5\\\hline 0&1\\ 1&0&1\\ 2&0&1&1\\ 3&0&1&3&1\\ 4&0&1&7&6&1\\ 5&0&1&15&25&10&1\end{array}$$
whose rows sum to the Bell numbers. Summing the rank collapse over all patterns gives the central formula:

> **Theorem (Spectral expansion).** For every $k \ge 0$,
> $$\#(X^k/G) \;=\; \sum_{r=0}^{k} S(k,r)\, t_r .$$

For the square: $\#(X^3/G) = S(3,1)t_1 + S(3,2)t_2 + S(3,3)t_3 = 1\cdot 1 + 3\cdot 2 + 1 \cdot 3 = 10$. And $\#(X^4/G) = 1\cdot 1 + 7 \cdot 2 + 6 \cdot 3 + 1 \cdot 3 = 36$. Exactly the numbers we started with.

Two immediate dividends. First, taking the trivial group — no symmetry at all — makes the orbit count $n^k$ and makes $t_r$ the number of injective $r$-tuples, that is the falling factorial $n^{\underline r} = n(n-1)\cdots(n-r+1)$. The theorem degenerates into the classical change of basis between ordinary powers and falling factorials,
$$n^k = \sum_{r=0}^{k} S(k,r)\, n^{\underline r},$$
here obtained not as a combinatorial identity in its own right but as the most symmetry-free instance of a statement about group actions. Second, taking the action of a group so transitive that all $t_r$ equal $1$ recovers the row-sum identity $B_k = \sum_r S(k,r)$ — the Bell floor is not an extra ingredient but the case "all spectral values $=1$" of the same formula.

## The spectrum is a complete invariant

Because $S(k,k) = 1$ — the only pattern with $k$ blocks is the fully discrete one — the expansion is *triangular*:
$$\#(X^k/G) = \underbrace{\sum_{r<k} S(k,r) t_r}_{\text{lower spectrum}} \;+\; t_k .$$
So the transformation can be run backwards over the integers, without division: knowing the orbit counts, one peels off $t_0$, then $t_1$, then $t_2$, and so on. This gives a rigidity statement:

> **Theorem (Rigidity).** Two finite group actions have the same orbit counts on $k$-tuples for every $k$ if and only if they have the same fibre spectrum.

One monotone sequence of at most $n+1$ integers thus carries *exactly* as much information as the entire infinite tower of tuple-orbit counts. It is a lossless compression, and it is optimal in an evident sense — the entries are genuinely independent data in general.

Monotonicity is worth a sentence of its own. Take an orbit of injective $r$-tuples; if $r + 1 \le n$, it can always be prolonged by an unused point to an orbit of injective $(r+1)$-tuples, and forgetting the last coordinate sends the latter onto the former. Hence

$$1 = t_0 \le t_1 \le t_2 \le \cdots \le t_n .$$

The spectrum begins with a run of $1$s — exactly as long as the action's degree of transitivity — and then climbs.

## One fibre decides everything

Here is where the picture becomes sharp. Since $t_r = 1$ says precisely that all injective $r$-tuples are in one orbit, we have $t_r = 1 \iff$ the action is $r$-transitive. Combining with monotonicity:

> **Theorem (Top-fibre criterion).** For $k \le n$, the action is $k$-transitive if and only if the *single* fibre over the fully discrete pattern is a singleton. Moreover, in that case all $B_k$ fibres are automatically singletons.

The original criterion required testing all $B_k$ fibres; now one suffices — and the reason is structural, not computational. Because multiplicities depend only on rank, and rank is bounded by $k$, and the spectrum is monotone, the top fibre dominates them all: $m_P = t_{\operatorname{rank}P} \le t_k$, so $t_k = 1$ forces every $m_P = 1$.

## An arithmetic obstruction, and a strict Bell defect

The final chapter of the story leaves combinatorics and uses only the *size* of the group. Fix any injective $k$-tuple $u$. If the action is $k$-transitive, the map $g \mapsto g \cdot u$ hits every injective $k$-tuple, of which there are $n^{\underline k} = n(n-1)\cdots(n-k+1)$. A surjection cannot shrink cardinality, and by the orbit–stabiliser theorem the orbit length divides the group order:

> **Theorem (Order bound).** If the action is $k$-transitive with $k \le n$, then $n^{\underline k}$ divides $|G|$; in particular $n^{\underline k} \le |G|$.

Read in reverse this is an obstruction with teeth. Suppose $|G| < n^{\underline k}$ — a comparison of two integers, requiring no knowledge of the group's internal structure. Then the action cannot be $k$-transitive, so $t_k \ne 1$, and since $t_k \ge 1$ always,
$$t_k \ge 2 .$$
Feeding this back through the spectral expansion, and using $t_r \ge 1$ for all $r \le k$, one gets a *quantitative* violation of the Bell floor:

> **Theorem (Strict Bell defect).** If $k \le n$ and $|G| < n^{\underline k}$, then
> $$\#(X^k/G) \ge B_k + 1 .$$

And because Burnside's lemma applied to the diagonal action on $X^k$ reads $\sum_{g \in G} |\mathrm{Fix}(g)|^k = |G| \cdot \#(X^k/G)$, where $\mathrm{Fix}(g)$ is the set of points fixed by $g$, the defect becomes a statement about the *moments of the fixed-point statistic* of the group:
$$\sum_{g \in G} |\mathrm{Fix}(g)|^k \;\ge\; (B_k + 1)\,|G| .$$

Think of what that means. Pick a random element of $G$ and count how many points it leaves alone; this is a random variable. Its $k$-th moment is a genuinely analytic quantity, and we have just bounded it strictly from below by comparing two integers, $|G|$ and a falling factorial. More precisely, the exact statement is
$$\frac{1}{|G|}\sum_{g\in G} |\mathrm{Fix}(g)|^k = B_k + \sum_{r=0}^{k} S(k,r)\,(t_r - 1),$$
a formula that displays the excess over the Bell value as a rank-by-rank sum of *defects of transitivity*, each weighted by the number of patterns of that rank. Every failure of $r$-transitivity pushes the moment up by $S(k,r)$ times its own size.

For the dihedral group of the square, with $k = 4$: $B_4 = 15$, spectrum $(1,1,2,3,3)$, defects $(0,0,1,2,2)$, weights $S(4,\cdot) = (0,1,7,6,1)$, giving $15 + (7\cdot 1 + 6 \cdot 2 + 1 \cdot 2) = 36$ — and indeed the fourth moment of the fixed-point count over the eight symmetries of the square is $288 = 36 \cdot 8$.

## Why it matters

Three morals.

**Coincidence is an invariant.** The only feature of a tuple that a symmetry group can never alter is the pattern of its repetitions. Fibering an orbit problem over that invariant is a strategy, not a trick, and it applies wherever a group acts on configurations: colourings, words, sequences of measurements, states of a physical system with indistinguishable components.

**Transitivity is a spectrum, not a yes/no.** Classical group theory grades actions by "is it $2$-transitive? $3$-transitive?", which is the question of how long the initial run of $1$s in the spectrum is. The rest of the spectrum measures the failure quantitatively, and the theorems above show that this quantitative measure is precisely what controls the tuple-orbit counts and the fixed-point moments.

**Compression.** An infinite sequence of counts, one per tuple length, is equivalent to at most $n+1$ monotone integers. The compression map is the universal Stirling transform; it does not know about $G$ at all. All the group-theoretic content sits in the short vector — and, remarkably, that vector can be pinned down, entry by entry, by nothing more than triangular back-substitution over the natural numbers.

Two non-isomorphic groups can of course share a spectrum: the Klein four-group and the cyclic group of order $4$, both acting regularly on four points, have the same spectrum $(1,1,3,6,6)$ and hence identical orbit counts $1,1,4,16,64$ for tuples of every length. Whatever it is that the fibre spectrum sees, it is not the isomorphism type of the group — it is something coarser, and understanding exactly what it is remains the most inviting open question in this circle of ideas.
