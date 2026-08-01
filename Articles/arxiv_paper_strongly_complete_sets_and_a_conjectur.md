# When One Missing Number Breaks Everything

## The difference between abundance and resilience in additive number theory

Imagine a box containing infinitely many numbered tiles. You may select any finite collection of distinct tiles and add their labels. If, beyond some threshold, every whole number can be made in this way, the collection is called **complete**. Completeness sounds like abundance: eventually, there are no gaps in what the tiles can produce.

But abundance is not the same as resilience. What if an adversary removes a handful of tiles before play begins? A set is called **strongly complete** when it remains complete after *every* finite deletion. Strong completeness therefore asks a more demanding question. It is not merely whether the set can represent all sufficiently large numbers, but whether its representational power is distributed broadly enough to survive finitely many losses.

This distinction is central to modern investigations of subset sums. It also reveals a striking elementary obstruction: a complete set can owe half of its expressive power to a single indispensable number.

## Distinct subset sums

Let $A$ be a set of nonnegative integers. A number $n$ is a **distinct subset sum from $A$** if there is a finite set $S\subseteq A$ such that

$$
n=\sum_{a\in S}a.
$$

Because $S$ is a set rather than a list, no summand may be used twice. The set $A$ is **complete** if there is a threshold $N$ such that every integer $n\ge N$ is a distinct subset sum from $A$.

The set $A$ is **strongly complete** if, for every finite set $F$ of integers, the surviving set $A\setminus F$ is complete. The threshold is allowed to depend on what was deleted. This is important: strong completeness promises eventual recovery, not uniform immunity at every scale.

The empty deletion immediately gives the first basic fact:

**Strong completeness implies completeness.** If $A$ survives every finite deletion, it survives deleting nothing at all.

The converse is the interesting question—and it fails in the cleanest possible way.

## A set that looks rich but has a single point of failure

Consider

$$
E=\{n\in\mathbb N:n\text{ is even}\}\cup\{1\}.
$$

Thus $E$ contains every even nonnegative integer and one odd integer, namely $1$. This set is complete. If $n$ is even, represent it with the one-element set $\{n\}$. If $n$ is odd, then

$$
n=1+(n-1),
$$

and $n-1$ is even. For odd $n\ge 3$, the summands $1$ and $n-1$ are distinct members of $E$. The remaining tiny cases cause no problem: $0$ is the empty sum or the singleton sum using $0$, and $1$ represents itself. Hence every nonnegative integer is representable; the completeness threshold can be taken to be $0$.

Now remove the single tile $1$. Every survivor is even. A sum of finitely many even numbers is even, so no odd number can ever be represented. There are arbitrarily large odd numbers. Therefore the surviving set is not complete.

We have proved the article’s central warning:

**Completeness does not imply strong completeness.** The set of all even integers together with $1$ is complete, yet deleting $1$ destroys completeness.

This example is small, but the mechanism is broad. The set has enormous numerical supply—one tile at every even scale—but almost no diversity modulo $2$. Every odd target routes through a single gateway. Remove that gateway and an entire residue class disappears.

The lesson resembles fault tolerance in engineered systems. A network may have huge total capacity and still be fragile if all traffic of one kind must pass through one bridge. A database may have many copies of most records and only one copy of a crucial index. Raw quantity does not guarantee robustness; what matters is whether essential functions are redundantly distributed.

## Why finite changes are the right scale

Strong completeness is defined through finite deletions, and this finiteness creates an elegant stability principle. Two sets have **finite symmetric difference** if they disagree at only finitely many integers. In symbols, the disagreement set is

$$
(A\setminus B)\cup(B\setminus A).
$$

The fundamental stability theorem says:

**Finite-Perturbation Invariance.** If $A$ and $B$ differ in only finitely many elements, then $A$ is strongly complete if and only if $B$ is strongly complete.

To see why, suppose $A$ is strongly complete and $A$ differs only finitely from $B$. Let an adversary remove a finite set $G$ from $B$. Focus on the common core $A\cap B$. To reach that core from $A$, delete both $G$ and the finitely many elements of $A$ that are absent from $B$. Strong completeness of $A$ says that what remains is complete. This remainder lies inside $B\setminus G$. Any superset of a complete set is complete, because the old subset-sum representations are still available. Thus $B\setminus G$ is complete. Reversing the roles of $A$ and $B$ proves the converse.

This theorem says that strong completeness is a property of the infinite tail, not of finitely many local choices. Adding a finite collection cannot manufacture true resilience, and deleting finitely many elements from an already resilient set cannot destroy it.

Two useful consequences make this precise.

**Finite-Deletion Closure.** If $A$ is strongly complete and $F$ is finite, then $A\setminus F$ is strongly complete.

Indeed, a later finite deletion $G$ produces

$$
(A\setminus F)\setminus G=A\setminus(F\cup G),
$$

and $F\cup G$ is finite.

**Finite-Addition Reflection.** If $F$ is finite and $A\cup F$ is strongly complete, then $A$ was already strongly complete.

Given a finite deletion $G$ from $A$, delete $G\cup F$ from $A\cup F$. The resulting complete set sits inside $A\setminus G$, so $A\setminus G$ is complete as well. A finite patch can repair ordinary completeness—as adding $1$ repairs the even numbers—but it cannot create strong completeness.

That last contrast is especially revealing. Ordinary completeness may depend entirely on a finite patch. Strong completeness, by design, ignores all finite patches.

## The arithmetic fingerprint of fragility

The counterexample is governed by parity, but parity is only the simplest modular obstruction. If all but finitely many elements of a set lie in a proper additive pattern modulo some integer $m$, then finite deletion may expose that pattern and permanently exclude certain residue classes from subset sums.

For $E$, after deleting $1$, every available summand is $0$ modulo $2$, so every attainable sum is also $0$ modulo $2$. The missing odd numbers are not sporadic accidents; they form an infinite arithmetic progression.

This suggests a practical diagnostic. To test whether a complete set might fail to be strongly complete:

1. Search for a finite collection of exceptional elements carrying unusual residue classes.
2. Remove those exceptions.
3. Check whether the remaining elements generate all residues needed for large targets.
4. If one residue class is permanently excluded, strong completeness fails.

A numerical experiment makes the phenomenon visible. Truncate $E$ at a finite bound, enumerate all distinct subset sums up to a target, and compare the attainable numbers before and after deleting $1$. Before deletion, a long initial interval is filled. After deletion, the display becomes striped: every odd position is absent. The finite computation does not prove an infinite theorem by itself, but it faithfully illustrates the parity argument that does.

## Local density and global distribution

The broader study of strongly complete sets asks what positive conditions prevent such failures. Two themes naturally arise.

The first is **supply across scales**. Divide the positive integers into dyadic blocks

$$
(2^k,2^{k+1}].
$$

A lower bound on the number of set elements in each sufficiently large block says that fresh summands keep appearing at every scale. Such hypotheses help subset sums expand without leaving large numerical gaps.

The second is **distribution modulo one**. For a real number $\theta$, let $\|x\|$ denote the distance from $x$ to the nearest integer. A divergence condition of the form

$$
\sum_{a\in A}\|a\theta\|=\infty
$$

for every nonintegral $\theta$ rules out excessive arithmetic concentration. Intuitively, the multiples $a\theta$ cannot all drift too close to integers too efficiently. Scale density supplies enough pieces; distribution conditions prevent those pieces from aligning along a hidden arithmetic obstruction.

The elementary results here do not establish a dyadic or analytic criterion. Instead, they clarify why any successful criterion needs more than ordinary completeness. The set $E$ is already complete in the strongest everyday sense—it represents every target—yet it fails the robustness test because its odd behavior is concentrated in one element.

## A hierarchy of questions

The distinction between completeness and strong completeness organizes several natural research problems.

One may ask whether infinitely many representatives in each residue class are enough to prevent finite-deletion obstructions. A stronger version requires every residue class modulo every $m\ge2$ to contain infinitely many elements of $A$. Even then, subset sums involve interactions among magnitudes as well as residues, so modular richness may not tell the whole story.

Another route replaces dyadic intervals with ordered finite blocks. If each block contains enough elements and the subset-sum intervals created by successive blocks overlap appropriately, then representability can propagate from one scale to the next. Such a block theorem would separate the combinatorial engine from any particular choice of intervals.

There is also an algorithmic question. Given a finite window into an infinite set, how can one detect likely single points of failure? Dynamic programming can compute attainable subset sums, repeat the computation after selected deletions, and highlight residue classes that vanish. This is not a decision procedure for an arbitrary infinite set, but it is an effective microscope for conjectures.

## Robustness is a different kind of largeness

The central example overturns an easy intuition. A set can represent every nonnegative integer and still be structurally brittle. Completeness measures the reach of the system as it stands. Strong completeness measures whether that reach survives finite damage.

The finite-perturbation theorem then supplies the positive counterpart: once robustness is genuinely present, no finite edit can alter it. Strong completeness belongs to the tail of the set. It is indifferent to finitely many decorations, finitely many defects, and finitely many repairs.

That combination—a sharp counterexample and a clean invariance law—gives a useful conceptual map. It tells us what strong completeness is not, identifies modular concentration as a basic obstruction, and shows exactly why finite changes are mathematically inessential to the robust property. In additive number theory, as in networks and resilient computation, having enough components is only the beginning. The deeper question is whether the system still works after the exceptional components are gone.
