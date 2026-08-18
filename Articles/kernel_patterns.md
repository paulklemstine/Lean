# The Shape of Sameness

## How the pattern of repeats inside a list of numbers becomes a complete invariant, counts itself with the Bell numbers, and quietly encodes Fermat's Last Theorem

### A puzzle about anonymous data

Suppose I show you a list of five items and refuse to tell you what they are. All I let you know is which positions carry *the same* item:

$$(\ast, \ast, \ast, \ast, \ast), \qquad \text{positions } 1 \text{ and } 4 \text{ agree}, \quad \text{positions } 2 \text{ and } 5 \text{ agree}, \quad \text{position } 3 \text{ is alone}.$$

You cannot recover my list. The items themselves have been erased. But you have not learned *nothing* — you have learned exactly the part of the list that survives renaming its entries. Call this residue the **equality pattern**, or the **kernel**, of the list.

This little idea turns out to be the exact answer to a natural question, and the answer has an unexpectedly rich life. Here is the question:

> Two lists of the same length, with entries drawn from the same finite pool of symbols. When can one be turned into the other by consistently renaming the symbols?

The answer is a theorem you can state in a sentence, and it is the theme of everything below.

**Completeness Theorem.** *Let $f$ and $g$ be two $n$-tuples with entries in a finite set $B$. There exists a permutation $\sigma$ of $B$ with $\sigma \circ f = g$ if and only if $f$ and $g$ have the same equality pattern: $f_i = f_j \iff g_i = g_j$ for all $i, j$.*

One direction is obvious: a permutation is injective, so it cannot merge two distinct entries or split one entry into two, and the pattern is untouched. The other direction is the content. Given two tuples with identical patterns, you build the renaming directly: send each value taken by $f$ to the value $g$ takes at the same position. The matching patterns are exactly what makes this well-defined and injective, and since $B$ is finite, a bijection between two subsets of $B$ of equal size always extends to a permutation of all of $B$. Finiteness is doing real work here; over an infinite alphabet you would need to compare the sizes of the complements.

So the equality pattern is a **complete invariant**: it is not merely preserved by renaming, it distinguishes tuples that renaming cannot connect. Complete invariants are the gold standard in classification problems — the Jordan form for matrices up to conjugacy, the genus for closed orientable surfaces — and this is a particularly clean one.

### Making the invariant concrete

An "equality pattern" is really an equivalence relation on the set of positions $\{1, \dots, n\}$, and equivalently a partition of the positions into blocks. That is elegant but abstract, and abstract objects are hard to store, compare, and count. There is a beautiful trick that makes the pattern into an ordinary tuple of numbers.

**Definition (canonical form).** For a tuple $f$, define
$$\mathrm{canon}(f)_i \;=\; \min\{\, j : f_j = f_i \,\},$$
the *earliest* position carrying the same entry as position $i$.

The tuple $(\text{blue}, \text{red}, \text{green}, \text{blue}, \text{red})$ becomes $(1,2,3,1,2)$. The tuple $(7,7,4,7,4)$ becomes $(1,1,3,1,3)$. Each block of the partition is labelled by its own smallest element. These labelled tuples are exactly what combinatorialists call *restricted growth strings*, and they satisfy a crisp package of properties, each of which can be checked directly from the definition:

- $f_{\mathrm{canon}(f)_i} = f_i$: the representative really lies in the block.
- $f_i = f_j$ precisely when $\mathrm{canon}(f)_i = \mathrm{canon}(f)_j$: no information is lost.
- $\mathrm{canon}$ is **idempotent**: applying it to a canonical form returns that form unchanged. Canonical forms are exactly the fixed points.
- $\mathrm{canon}(\sigma \circ f) = \mathrm{canon}(f)$ for any injective renaming $\sigma$ — in particular for any permutation of the alphabet.
- If $f$ has all entries distinct, then $\mathrm{canon}(f) = (1, 2, \dots, n)$, the *discrete* pattern.

Combining the last few facts with the Completeness Theorem: **two tuples over a finite alphabet lie in the same renaming-orbit if and only if their canonical forms are literally equal.** Classification has been reduced to comparing two lists of integers — a linear-time test, no group theory at runtime.

### Counting the patterns: the Bell numbers appear

Now that patterns are concrete objects, we can ask how many there are. Let $P_n$ denote the set of patterns of length $n$ — equivalently, the fixed points of $\mathrm{canon}$ among all tuples of length $n$. Enumerating them for small $n$ gives

$$|P_0|, |P_1|, |P_2|, |P_3|, |P_4|, |P_5| \;=\; 1,\; 1,\; 2,\; 5,\; 15,\; 52.$$

Anyone who has spent time with combinatorics will recognise these instantly: the **Bell numbers**, the sequence counting the ways to partition a set. Their standard recursive definition is
$$B_{n+1} \;=\; \sum_{i=0}^{n} \binom{n}{i} B_{n-i},$$
which says: choose which of the remaining $n$ points share a block with a distinguished point, then partition what is left.

That these two sequences coincide is not a coincidence, and it is not merely a numerical check for small $n$. It holds in every arity:

**Enumeration Theorem.** *For every $n$, the number of equality patterns of an $n$-tuple equals the Bell number $B_n$. More generally, for every finite index set $I$, the number of equivalence relations on $I$ is $B_{|I|}$.*

The proof is a chain of four reductions, each of which is a bijection you can hold in your head. First, a pattern is the same data as an equivalence relation on positions (read off from which positions get the same label). Second, this count only depends on the size of the index set, not on what the index set is. Third — the crucial step — an equivalence relation on a set with one distinguished extra point $\star$ is the same thing as *a choice of which ordinary points share $\star$'s block*, together with *an equivalence relation on everything left over*. Fourth, grouping those choices by how many points join $\star$ turns the third step into precisely the binomial recursion above, and strong induction closes the loop.

The pattern-counting picture immediately gives an **orbit count**. Recall that patterns classify tuples up to renaming, so counting orbits is counting realisable patterns:

**Orbit-Counting Theorem.** *Let $B$ be a finite alphabet with $|B| \ge n$. The symmetric group of $B$, acting on $n$-tuples over $B$ by renaming entries, has exactly $B_n$ orbits.*

The hypothesis $|B| \ge n$ is sharp, and pleasantly so. A tuple of length $n$ over an alphabet of $m < n$ letters cannot have all its entries distinct, so the discrete pattern is unreachable; more precisely, the reachable patterns are exactly those with at most $m$ blocks, and the orbit count drops to a truncated sum. Writing $S(n,k)$ for the number of patterns of length $n$ with exactly $k$ blocks, we get the clean statement that the number of orbits over any finite alphabet $B$ is
$$\sum_{k \le |B|} S(n,k),$$
which is strictly less than $B_n$ exactly when $|B| < n$.

### The Stirling triangle, from scratch

Those refined counts $S(n,k)$ are, of course, the **Stirling numbers of the second kind** — but here they arrive with a purely combinatorial definition: the number of length-$n$ patterns with exactly $k$ blocks. Everything classical about them can be re-derived from that definition, and the derivations are short.

The engine is a single case split. Take a pattern of length $n+1$ with $k+1$ blocks and look at the last position. Either it is a block all by itself — delete it, and you are left with a pattern of length $n$ with $k$ blocks — or it joins one of the $k+1$ existing blocks, which can happen in $k+1$ ways. Hence

$$S(n+1, k+1) \;=\; S(n, k) \;+\; (k+1)\, S(n, k+1),$$

and by definition $\sum_k S(n,k) = B_n$: the rows of the triangle sum to the Bell numbers.

From the recursion, closed forms tumble out by induction. Splitting $n+1$ positions into exactly two nonempty blocks amounts to choosing the block containing position $1$, any of the $2^n - 1$ proper choices, so
$$S(n+1, 2) = 2^n - 1.$$
A pattern of length $n+1$ with $n$ blocks merges exactly one pair of positions and leaves the rest alone, so
$$S(n+1, n) = \binom{n+1}{2},$$
and one step further down the diagonal,
$$S(n+2, n) = \binom{n+2}{3} + 3\binom{n+2}{4}.$$
The columns obey inclusion–exclusion formulas which the recursion proves by induction:
$$6\,S(n,3) = 3^n - 3\cdot 2^n + 3, \qquad 24\, S(n,4) = 4^n - 4\cdot 3^n + 6 \cdot 2^n - 4,$$
$$120\, S(n,5) = 5^n - 5\cdot 4^n + 10\cdot 3^n - 10 \cdot 2^n + 5.$$
Summing the resulting rows gives Bell numbers far past the reach of brute-force enumeration: the sixth row $(0,1,31,90,65,15,1)$ sums to $B_6 = 203$, the seventh to $B_7 = 877$, and the eighth $(0,1,127,966,1701,1050,266,28,1)$ to $B_8 = 4140$.

The same fibre-counting yields two more classical facts with no extra work. Counting how many tuples over an alphabet of size $m$ realise a given pattern with $k$ blocks — you must choose $k$ distinct letters in order, so $m(m-1)\cdots(m-k+1)$ ways — and summing over patterns gives the **falling-factorial expansion**
$$m^n \;=\; \sum_{k} S(n,k)\, m^{\underline{k}},$$
the identity converting ordinary powers into falling powers. Restricting to patterns with exactly $k$ blocks and alphabets of size exactly $k$ gives the count of surjections: there are $k!\, S(n,k)$ surjective maps from an $n$-set onto a $k$-set, and in particular $n!$ surjections from an $n$-set onto itself.

### Growth, and a congruence out of nowhere

Two structural theorems about Bell numbers fall out of the pattern picture.

**Super-multiplicativity.** *$B_m B_n \le B_{m+n}$, with strict inequality whenever $m, n \ge 1$.*

The proof is a picture. Given a partition of a set $A$ and a partition of a disjoint set $C$, lay them side by side: you get a partition of $A \cup C$ in which no block straddles the two halves. This is an injection from pairs of partitions to partitions of the union, giving the inequality. It is never surjective when both sides are nonempty, because the partition with a single all-encompassing block certainly straddles — hence strictness. Already $B_2 B_2 = 4 < 15 = B_4$. Iterating gives $B_n^k \le B_{nk}$, so $2^k \le B_{2k}$: the Bell numbers outrun every exponential. Monotonicity comes from the same style of argument: appending a new singleton block embeds the patterns of length $n$ into those of length $n+1$, and the all-in-one-block pattern is never in the image once $n \ge 1$, so $B_n < B_{n+1}$ for $n \ge 1$.

And then there is a genuine surprise — a number-theoretic congruence proved by pure symmetry.

**Touchard's Congruence.** *For every prime $p$ and every $n \ge 0$,*
$$B_{p+n} \;\equiv\; B_{n+1} + B_n \pmod{p}.$$

Here is the whole argument. Index a set by $\mathbb{Z}/p$ together with $n$ extra points. The cyclic group $\mathbb{Z}/p$ acts by rotating the first part and fixing the extras, hence acts on the $B_{p+n}$ partitions of the whole index set. For a group of prime order $p$, the size of any set it acts on is congruent mod $p$ to the number of fixed points, because every non-fixed orbit has exactly $p$ elements. So we only need to count the *rotation-invariant* partitions — and these are easy to classify. Look at the block containing the point $0$ of the cyclic part. If that block contains any other cyclic point, then rotating and chaining forces the entire cyclic part into one single block, and what remains is a partition of the $n$ extra points together with that one distinguished extra block — that is, a partition of an $(n+1)$-element set, and there are $B_{n+1}$ of those. Otherwise every cyclic point is its own singleton block, and all that remains is an arbitrary partition of the $n$ extras: $B_n$ of those. Adding gives $B_{n+1} + B_n$, and the congruence follows.

Setting $n = 0$ gives the classical **$B_p \equiv 2 \pmod p$** for every prime $p$; for instance $B_7 = 877 = 7 \cdot 125 + 2$. Taking $p = 5, n = 3$ gives $B_8 \equiv B_4 + B_3 = 15 + 5 = 20 \equiv 0$, so $5 \mid B_8$ — and indeed $4140 = 5 \cdot 828$, exactly as the Stirling-row computation independently produced.

### Which patterns can a Pythagorean triple have?

So far the story is pure combinatorics. Here is the turn: patterns are a *filter* you can apply to any Diophantine equation. Given an equation in $n$ unknowns, ask which of the $B_n$ patterns are realised by its solutions. Call the set of realised patterns the **kernel spectrum** of the equation. It is a finite, purely combinatorial invariant of an infinite arithmetic object.

Start with triples, where there are $B_3 = 5$ patterns: all three equal; first two equal; first and third equal; last two equal; all distinct. Now impose $a^2 + b^2 = c^2$ over the natural numbers.

**Kernel Spectrum of the Pythagorean Equation.** *A pattern of a triple is realised by a solution of $a^2 + b^2 = c^2$ in $\mathbb{N}$ if and only if it is not the pattern "$a = b$, with $c$ different". Exactly four of the five patterns occur.*

Four are realised, and cheaply: $(3,4,5)$ is all-distinct; $(0,1,1)$ has its last two entries equal; $(1,0,1)$ has its first and last equal; $(0,0,0)$ is the constant triple. The excluded one is the interesting case. If $a = b \neq 0$ then $2a^2 = c^2$, and the arithmetic obstruction is this:

**Square-Multiplier Lemma.** *If $k a^2 = c^2$ with $a \ne 0$, then $k$ is a perfect square.*

The proof is a descent: divide $a$ and $c$ by their greatest common divisor to get coprime $a', c'$ with $k a'^2 = c'^2$; then $a'^2$ divides $c'^2$ while being coprime to it, forcing $a' = 1$ and $k = c'^2$. Since $2$ is not a perfect square, $2a^2 = c^2$ has no solution with $a \ne 0$. So the Pythagorean cone is **kernel-deficient of defect one**: its spectrum has $B_3 - 1 = 4$ elements.

And here the invariant shows it is not vacuous, because the defect *depends on the dimension*. Consider $x_1^2 + \dots + x_k^2 = y^2$ and ask when all legs can be equal and nonzero. That is precisely $k a^2 = y^2$, so by the Square-Multiplier Lemma:

**Equal-Legs Criterion.** *The $k$-dimensional Pythagorean equation has a solution with all legs equal and nonzero if and only if $k$ is a perfect square.*

For $k = 2$ and $k = 3$: blocked. For $k = 4$: realised, by $1^2 + 1^2 + 1^2 + 1^2 = 2^2$. The missing pattern is not an artefact of the formalism; it reappears the moment the dimension becomes a square.

### Fermat's Last Theorem, restated as a counting problem

Push the exponent up. For $x^p + y^p = z^p$, define the spectrum exactly as before. Two facts organise everything.

First, the equal-legs pattern is blocked for *every* exponent $p \ge 2$, not just $p = 2$. If $a \ne 0$ and $2a^p = c^p$, compare the exponent of the prime $2$ on both sides: the left side has $2$-adic valuation $1 + p \cdot v_2(a)$, the right has $p \cdot v_2(c)$, so $p$ divides $1$ — impossible for $p \ge 2$. Second, the three "degenerate" patterns, in which some entry coincides with the hypotenuse or everything is zero, are realised for every $p$ by triples like $(0,1,1)$, $(1,0,1)$ and $(0,0,0)$.

That leaves exactly one pattern whose status is in doubt: the discrete pattern, all three entries distinct. And a short argument shows the discrete pattern is realised at exponent $p \ge 2$ **if and only if** the Fermat equation has a solution in strictly positive integers. (Positivity forces all three entries distinct, since the legs cannot be equal by the valuation argument and neither leg can equal the hypotenuse.) Therefore:

**Kernel-Theoretic Form of Fermat's Last Theorem.** *For every exponent $p \ge 2$, the equation $x^p + y^p = z^p$ realises exactly three of the five patterns of a triple if and only if it has no solution in positive integers, and exactly four otherwise.*

For $p = 2$ the count is four, witnessed by $(3,4,5)$. For $p \ge 3$ it is three — this is Fermat's Last Theorem, now phrased as the statement that a certain five-element set has a three-element subset. And at $p = 1$ the whole thing collapses: $1 + 1 = 2$ realises the equal-legs pattern, so all five patterns occur. The defect is a genuine phase transition in the exponent, switching on at $p = 2$ and switching from four to three at $p = 3$.

### Why this is worth the trouble

The moral is that "which coordinates agree" is a legitimate mathematical object, not a bookkeeping detail. It is the complete invariant for renaming symbols; it is computed by a one-line canonical form; its enumeration is the Bell numbers, refined by the Stirling triangle, obeying super-multiplicativity and Touchard's congruence; and, attached to a Diophantine equation, it produces a small, sharp, finite invariant that separates dimension $2$ from dimension $4$ and compresses Fermat's Last Theorem into a cardinality.

Erasing information is a strange way to learn something. But the part of a list that survives the erasure — the shape of its sameness — knows more than it lets on.
