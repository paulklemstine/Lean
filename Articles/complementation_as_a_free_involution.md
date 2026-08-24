# The Jigsaw That Knows Its Own Reflection

## How a single flip of every tab and blank forces the number of solutions to be even

Take an ordinary jigsaw puzzle out of its box and do something perverse to it: on every single piece, at every single edge, turn every **tab** into a **blank** and every blank into a tab. Nothing else changes — not the shapes of the outlines, not the picture, not which piece sits next to which. You have simply reversed the polarity of every interlock in the box.

Does the puzzle still go together?

Of course it does. If two edges used to mate — tab into blank — they still mate, blank into tab. The whole assembly survives the flip untouched, because "fits" was never about which of the two shapes you had; it was about the two of them being *opposite*. Flip both sides of every handshake and the handshake still happens.

That much is a party trick. What follows is not.

The flip does not merely *preserve solvability*. It is a perfect, invertible transport of the **entire space of solutions** — and because it never fixes anything, it forces a counting law: for any puzzle with at least one variable, the total number of distinct configurations that solve the puzzle *or* its mirror is always **even**. There is no way to build a puzzle with an odd combined count. And that single bit of parity, it turns out, is *all* the flip constrains: every even number up to the maximum is achieved by some puzzle. This article is about how that boundary got drawn exactly.

---

## Puzzles that compute

To make the flip do real work, we need puzzles that are doing more than depicting a landscape. Here is the setup.

Fix $n$ **variables**. For each variable $i \in \{1, \dots, n\}$ the box contains a matched pair of **variable pieces** — call them the *true piece* and the *false piece* for variable $i$ — and the frame of the puzzle has exactly one socket for variable $i$, so you must commit to one of the two. A complete commitment across all $n$ variables is a point of the Boolean cube,
$$a \in \{\texttt{true}, \texttt{false}\}^n,$$
and there are $2^n$ of them.

The rest of the box holds **clause pieces**. A clause piece is a small piece with some number of input notches sticking off it. Each notch is milled for a specific pair: a variable index $i$ and a required polarity $p$. That notch will accept the variable-$i$ piece if and only if the piece you installed is the one with polarity $p$ — the tab of the installed piece must mate with the blank of the notch, and it only does so on a match. A clause piece is happy — it snaps into the assembled frame — as soon as **at least one** of its notches finds its mate.

So: given a commitment $a$, a clause piece $c$ fits precisely when some notch $(i, p)$ of $c$ has $a_i = p$; and the whole puzzle **assembles** under $a$ precisely when every clause piece is happy. The set of all $a$ that assemble $P$ is the **assembly space** $A(P)$, a subset of the cube.

Readers who know propositional logic will recognise the shape of this. A notch is a literal, a clause piece is a disjunction of literals, a puzzle is a conjunction of clauses — a CNF formula — and an assembly is a satisfying assignment. That is not a coincidence: it is the point. The physical language of tabs and blanks is a faithful presentation of Boolean constraint satisfaction, one where the symmetry we care about is *visible in the hardware*.

The complement $P^{*}$ of a puzzle is what you get by re-milling every notch for the opposite polarity. On commitments, complementation means flipping every choice: write
$$\sigma(a)_i = \lnot a_i .$$

---

## Transport, not preservation

Here is the first theorem, and it is stronger than the party trick.

> **Exact Transport Theorem.** For every framed puzzle $P$ on $n$ variables and every commitment $a$, the commitment $\sigma(a)$ assembles $P^{*}$ if and only if $a$ assembles $P$. Consequently
> $$A(P^{*}) = \sigma\bigl(A(P)\bigr), \qquad |A(P^{*})| = |A(P)| .$$

The proof is a two-line cascade from a one-line dictionary. A notch $(i, \lnot p)$ accepts $\sigma(a)$ exactly when $\lnot a_i = \lnot p$, i.e. exactly when $a_i = p$, i.e. exactly when the original notch $(i,p)$ accepted $a$. Complementation matches the notches of $c$ with the notches of $c^{*}$ one for one, so $c^{*}$ is happy under $\sigma(a)$ iff $c$ was happy under $a$; run over all clause pieces and you have the theorem. Because $\sigma$ is an involution and injective, the two assembly spaces are not merely both nonempty or both empty — they are the *same size*, related by an explicit bijection.

The older folklore statement — "complementing preserves solvability" — is the shadow this theorem casts when you throw away all information except whether the space is empty. The theorem says the solution *space* travels intact.

---

## Why the count must be even

Now put the two spaces side by side inside the same cube and take their union:
$$C(P) \;=\; A(P) \,\cup\, A(P^{*}).$$
No labels, no bookkeeping about which space a solution came from — just the set of commitments that solve the puzzle or its mirror. By Exact Transport, $\sigma$ maps $C(P)$ into itself: a solution of $P$ flips to a solution of $P^{*}$ and vice versa.

And here is the crucial, almost embarrassingly simple observation:

> **No Boolean vector is its own negation.** If $n \geq 1$, then $\sigma(a) \neq a$ for every $a$, because the first coordinate alone cannot equal its own opposite.

So $\sigma$ acts on the finite set $C(P)$ as an involution *with no fixed points*. A fixed-point-free involution partitions a finite set into two-element orbits $\{a, \sigma(a)\}$. Therefore:

> **Parity Theorem.** For every framed puzzle on $n \geq 1$ variables, $|C(P)|$ is even.

The same argument applies verbatim to the *intersection* $A(P) \cap A(P^{*})$, which is also complement-stable, so that too has even size.

There is a pleasing alternative proof that does not mention orbits at all. Consider the product of the constant $-1$ over all elements of $C(P)$. Pairing each $a$ with $\sigma(a)$ makes the factors cancel telescopically, forcing the product to be $+1$; but the product is also $(-1)^{|C(P)|}$, so the exponent is even. Parity as a signed sum: an argument older than jigsaws and just as sharp.

---

## The conjecture, and the surprise inside it

The result was originally conjectured in a hedged form: *for every framed puzzle not isomorphic to its own complement, complementation acts freely on the two assembly spaces, so their combined count is even.* The hedge is the clause "not isomorphic to its own complement" — the worry being that a **self-dual** puzzle, one indistinguishable from its own mirror, might be a fixed point of the symmetry and so escape the parity law.

It is a natural worry. It is also wrong, and the way it is wrong is the most instructive thing here.

Self-duality is a property of *puzzles*. Freeness is a property of *commitments*. The involution $\sigma$ does not act on puzzles; it acts on the Boolean cube, and on the cube it is free for a reason that has nothing whatever to do with the puzzle: a bit-string is never its own complement. A self-dual puzzle does not acquire a fixed point. It merely has $A(P^{*}) = A(P)$, so the union collapses onto a single space — on which $\sigma$ still acts freely. The conclusion therefore gets *stronger*, not weaker:

> **Self-Dual Parity Theorem.** If a framed puzzle on $n \geq 1$ variables has a complement-stable assembly space, then it has an **even number of solutions**.

So the hypothesis in the original conjecture was doing exactly one job, and it was not the job it was hired for. Where *does* the parity law fail? At $n = 0$. On zero variables there is one commitment, the empty one; every puzzle is trivially self-complementary because there are no notches to re-mill; the empty puzzle assembles under that single commitment; and the combined space has exactly **one** element. Odd. And $\sigma$ genuinely fixes the empty commitment: this is the unique fixed configuration anywhere in the theory. The hypothesis "$P$ is not isomorphic to its complement" is true only when $n \geq 1$ — it excludes precisely the degenerate dimension, by accident.

The boundary the conjecture was groping for is not self-duality. It is *dimension*.

---

## Counting the orbits, not just their parity

Parity is a one-bit shadow. The full statement is a decomposition.

Fix the first variable and define the **polarity gauge** of a set $S$ of commitments to be
$$\Gamma(S) = \{\, a \in S : a_1 = \texttt{true} \,\}.$$
Because $\sigma$ flips the first coordinate, each two-element orbit $\{a, \sigma(a)\}$ meets $\Gamma(S)$ exactly once. Hence:

> **Orbit Decomposition.** If $S$ is stable under complementation, then $S$ is the disjoint union of $\Gamma(S)$ and $\sigma(\Gamma(S))$, so
> $$|S| = 2\,|\Gamma(S)| .$$

Parity is now a corollary with a *witness*: the gauge is a computable section of the orbit map, not an abstract existence claim. Applied to the whole cube, $|\Gamma| = 2^{n-1}$, which bounds the number of orbits any puzzle can have.

A curiosity falls out for free. Regard $\sigma$ as a permutation of the $2^n$ points of the cube. It is a product of $2^{n-1}$ disjoint transpositions, so its sign is $(-1)^{2^{n-1}}$. For $n = 1$ that exponent is $1$: complementation is an **odd** permutation, a single transposition swapping the two points of a one-dimensional cube. For every $n \geq 2$ the exponent is even and $\sigma$ is an **even** permutation. The tab–blank symmetry leaves a visible trace in the sign character of the symmetric group of the cube in exactly one dimension, and is invisible there ever after.

---

## The constraint is the *only* constraint

So far every theorem is a restriction: complementation forces this, forbids that. The natural next question is whether it forces anything *else*. Perhaps combined counts are further constrained — divisible by four, say, or bounded away from the extremes.

They are not, and the proof is a construction.

For a commitment $b$, build the **exclusion piece** $E_b$: a single clause piece with one notch per variable, the notch for variable $i$ milled for $\lnot b_i$. Then $E_b$ is happy under $a$ if and only if some coordinate of $a$ disagrees with $b$ — that is, if and only if $a \neq b$. One piece, one forbidden solution.

Now let $S$ be *any* subset of the cube whatsoever, and let $P_S$ be the puzzle whose clause pieces are exactly $E_b$ for each $b \notin S$. A commitment assembles $P_S$ iff it differs from every excluded point, i.e. iff it lies in $S$.

> **Complete Expressiveness Theorem.** Every subset $S$ of the Boolean cube is exactly the assembly space of a framed puzzle, realised with $2^n - |S|$ clause pieces. The map sending a puzzle to its assembly space is surjective onto the subsets of the cube.

Framed puzzles are therefore a *complete* constraint language: nothing about the cube is invisible to them. Two sharp consequences follow immediately.

First, single-puzzle solution counts are entirely unconstrained: for every $k \leq 2^n$ some puzzle has exactly $k$ solutions, and in particular **odd counts occur**. So the parity theorem could never have been about one assembly space; it is intrinsically a statement about the complement-stable union.

Second — and this is the sharp boundary the whole programme was after — combine expressiveness with parity:

> **Combined Spectrum Theorem.** For $n \geq 1$, a number $m$ is the combined assembly count of some framed puzzle on $n$ variables **if and only if** $m$ is even and $m \leq 2^n$.

Freeness supplies "only if"; expressiveness supplies "if". To realise a given even $2k \leq 2^n$, pick $k$ points of the gauge, adjoin their complements to get a complement-stable set of size exactly $2k$, and realise it with exclusion pieces. Complementation contributes precisely one bit of global information about a puzzle — the parity of the combined count — and not one bit more.

The same construction settles the fate of self-duality once and for all: for every even $2k \leq 2^n$ there is a puzzle whose assembly space is complement-stable and has exactly $2k$ elements. Self-dual configurations exist in **every** admissible size, and none of them is a fixed point.

---

## How rare is self-duality, exactly?

Since every subset of the cube is an assembly space, counting assembly spaces is counting subsets: there are $2^{2^n}$ of them. Counting *self-dual* assembly spaces is counting complement-stable subsets, and the gauge answers that too. A stable set is determined, freely and uniquely, by its intersection with the gauge — intersect to go one way, adjoin complements to come back. So stable sets correspond to subsets of a $2^{n-1}$-element set:

> **Density Theorem.** For $n \geq 1$ there are exactly $2^{\,2^{\,n-1}}$ complement-stable assembly spaces, and the square of this number is $2^{2^n}$, the total number of assembly spaces.

Self-duality is exactly a **square-root condition**. Among $2^{2^n}$ possible solution spaces, precisely the square root of that many are self-dual: doubly exponentially rare in absolute terms, yet — by the spectrum theorem — present in every admissible size. Rare and ubiquitous at once, which is the signature of a symmetry class rather than a degeneracy. For $n=1$: $2$ stable spaces out of $4$. For $n=2$: $4$ out of $16$. For $n=3$: $16$ out of $256$.

---

## Beyond tabs and blanks

Nothing in the argument used the number *two* except at one place: the involution had order two. Suppose the mill has $d$ distinct **interlock depths** instead of the two shapes tab and blank. A variable piece now exposes a depth in $\mathbb{Z}/d$, a notch is milled for a required depth, and "deepen every mill by one step" is an order-$d$ symmetry of the whole construction.

Everything transports. Shifting a puzzle and a commitment by the same amount preserves assembly. The depth gauge — commitments whose first variable sits at depth $0$ — meets each shift orbit exactly once, and a shift-stable set of commitments is in explicit bijection with $\mathrm{gauge} \times \mathbb{Z}/d$. Hence:

> **Cyclic Divisibility Theorem.** For $n \geq 1$, the combined assembly space of the $d$ depth-shifts of a $d$-ary framed puzzle has cardinality exactly $d$ times its gauge, so $d$ divides the combined count.

Tab–blank parity is the $d = 2$ slice. The constraint on solution counts is not parity as such; it is the **order of the symmetry group acting freely on the configuration space**. Two shapes give you evenness; three depths give you divisibility by three; and the number $2$ was never the content, only the instance.

---

## What the flip was really telling us

Read backwards, the story is a lesson about where symmetry lives.

The conjecture placed the symmetry in the puzzle and asked which puzzles were fixed by it. The answer is that the symmetry does not live in the puzzle at all. It lives in the configuration space — the Boolean cube — where it acts freely for a reason no puzzle can influence, and it acts on assembly spaces only by *transport*. Self-duality is not a fixed point of the action; it is the statement that a particular orbit-stable subset happens to be the solution space of a single puzzle rather than of a complementary pair. That is why the hypothesis in the conjecture turned out to be excluding a dimension rather than a degeneracy, and why the theorem it was guarding is true without it.

Once you know the action is free, everything else is counting: parity, then the exact orbit decomposition with a computable section, then the exact spectrum of achievable counts, then the exact census of self-dual spaces, then the $d$-ary divisibility law. Five layers of increasingly sharp statements, all descending from one sentence — *a bit-string is never its own complement* — and one construction — *one piece can forbid exactly one solution*.

Constraint from freeness; expressiveness from a single exclusion piece; and between them, no room left for anything else. That is a complete answer, and complete answers are rare enough to be worth a puzzle box.
