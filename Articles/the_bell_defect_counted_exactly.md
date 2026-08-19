# The Bell Defect, Counted Exactly

## How a single number measures everything a symmetry group fails to do

Take a deck of cards and shuffle it. Almost every shuffle moves almost every card,
but occasionally a card returns to its original position. Count the fixed cards.
Repeat for every possible shuffle in your repertoire, and average. That average —
the mean number of things a symmetry leaves alone — is one of the oldest and most
useful quantities in algebra. It is the content of *Burnside's lemma*, the workhorse
behind every count of "how many necklaces can I make with three red and four blue
beads, up to rotation".

Burnside's lemma says something clean:

$$\frac{1}{|G|}\sum_{g \in G} |X^g| = \text{number of orbits},$$

where $G$ is a finite group of symmetries acting on a finite set $X$, and $X^g$ is
the set of points that the symmetry $g$ leaves fixed. Average the fixed-point count,
get the number of essentially different configurations.

But what happens if, instead of averaging $|X^g|$, you average its *square*? Its
*cube*? Its $k$-th power? These higher **moments**

$$M_k \;=\; \sum_{g \in G} |X^g|^k$$

turn out to be far richer than the first one — and this article is about a precise,
exact accounting of exactly *how* rich. The punchline is a formula that turns a
seemingly analytic quantity (a moment) into a piece of pure bookkeeping about
partitions, and in doing so converts a vague notion — "how badly does this symmetry
group fail to mix things up?" — into an integer that can be computed, bounded,
and proved to behave monotonically.

---

## From moments to tuples

The first move is old and irresistible. Since $|X^g|^k$ counts the $k$-tuples
$(x_1,\dots,x_k)$ of points all of which $g$ fixes, applying Burnside's lemma not to
$X$ but to the set $X^k$ of $k$-tuples gives

$$M_k \;=\; |G| \cdot \#\bigl(X^k / G\bigr).$$

The $k$-th moment is nothing but the number of orbits of $k$-tuples, scaled by the
group order. So all the information is in a counting problem: *how many essentially
different $k$-tuples of points does this symmetry group admit?*

Now comes the observation that organizes everything. A $k$-tuple carries a piece of
information that no symmetry can destroy: the **pattern of coincidences** among its
coordinates. In the tuple $(a, b, a, c)$, coordinates $1$ and $3$ agree and the others
are distinct; applying any symmetry $g$ produces $(ga, gb, ga, gc)$, which has *exactly
the same* pattern, because symmetries are injective. Formally, a **pattern** on
$\{1,\dots,k\}$ is a set partition: the blocks record which coordinates carry equal
entries. The tuple $(a,b,a,c)$ has pattern $\{1,3\}\,|\,\{2\}\,|\,\{4\}$.

Patterns are invariant along orbits, so there is a well-defined map

$$\text{orbits of } k\text{-tuples} \;\longrightarrow\; \text{patterns on } \{1,\dots,k\},$$

sending each orbit to the coincidence pattern of any of its members. And as long as
$X$ has at least $k$ points, *every* pattern is achieved: pick distinct points and
glue coordinates together according to the desired blocks. The map is onto.

The number of patterns on a $k$-element set is the **Bell number** $B_k$:
$B_1 = 1$, $B_2 = 2$, $B_3 = 5$, $B_4 = 15$, $B_5 = 52$, $B_6 = 203$, and so on. A
surjection from orbits onto patterns therefore forces

$$\#(X^k/G) \;\ge\; B_k, \qquad\text{that is}\qquad \boxed{\;M_k \;\ge\; B_k \cdot |G|\;}$$

whenever $k \le |X|$. Call this the **Bell floor**. Every finite group action, no matter
how symmetric, has at least $B_k$ orbits of $k$-tuples — one for each way that
coordinates can coincide.

## The defect

The gap between a moment and its Bell floor is the object of this story:

$$D_k \;=\; M_k - B_k\,|G| \;=\; \sum_{g \in G} |X^g|^k \;-\; B_k\,|G| \;\ge\; 0.$$

We call it the **Bell defect**. When is it zero? Exactly when the orbit-to-pattern map
is a bijection — when the coincidence pattern is the *only* invariant of a $k$-tuple, so
that any two tuples with the same pattern are related by a symmetry. Restricting to
tuples of *distinct* points, that says: any injective $k$-tuple can be carried to any
other by an element of $G$. That is precisely the classical notion of
**$k$-transitivity**. So:

> **The Bell floor is attained if and only if the action is $k$-transitive.**

The symmetric group on $n$ letters is $n$-transitive; the alternating group is
$(n-2)$-transitive; the Mathieu group $M_{24}$ is famously $5$-transitive. For those
actions the moment sits exactly on the floor. For everyone else there is a strictly
positive defect, and the question becomes: *what does the defect count?*

## The exact count: fibres over patterns

Since $M_k/|G|$ is the number of orbits and $B_k$ is the number of patterns, and every
pattern is hit at least once, the excess is simply the total overcounting in the fibres.
Write $m_P$ for the number of orbits of $k$-tuples whose pattern is $P$ — the *fibre
multiplicity* of $P$. Then

$$\boxed{\;D_k \;=\; |G| \cdot \sum_{P} \bigl(m_P - 1\bigr)\;}$$

the sum running over all $B_k$ patterns on $\{1,\dots,k\}$. The defect is $|G|$ times
the number of *extra* orbits per pattern, and it vanishes exactly when every fibre is a
singleton. This is the accounting the title promises: the defect, counted exactly.

The formula would be a curiosity if the multiplicities $m_P$ were wild. They are not.
Here is the structural miracle: **the multiplicity depends only on the number of blocks.**
If $P$ has $r$ blocks, then an orbit of $k$-tuples with pattern $P$ is the same thing as
an orbit of *injective* $r$-tuples — collapse each block to a single coordinate, and no
information is lost. Writing

$$t_r \;=\; \text{number of } G\text{-orbits of injective } r\text{-tuples of points},$$

we get the **rank collapse** $m_P = t_{r}$ whenever $P$ has $r$ blocks. The vector
$(t_0, t_1, t_2, \dots)$ — the **fibre spectrum** — is a single sequence of integers
that determines every multiplicity at once. Its first entries are familiar: $t_0 = 1$
(there is one empty tuple), and $t_1$ is the number of orbits of points, the quantity
computed by Burnside's lemma.

Counting the patterns with $r$ blocks gives the **Stirling number of the second kind**
$S(k,r)$, and $B_k = \sum_r S(k,r)$. Substituting the rank collapse into the fibre
formula turns the defect into a finite sum:

$$D_k \;=\; |G|\,\sum_{r=0}^{k} S(k,r)\,\bigl(t_r - 1\bigr), \qquad
\#(X^k/G) \;=\; \sum_{r=0}^{k} S(k,r)\, t_r .$$

Every moment of the fixed-point family is the Stirling transform of the fibre spectrum.
The analysis has evaporated; only combinatorics remains.

A concrete example. Let the cyclic group of order $4$ act on itself by translation. Its
spectrum is $(t_0,t_1,t_2,t_3,t_4) = (1,1,3,6,6)$: transitive on points, but the three
"distances" between two distinct points give three orbits of pairs. The formula predicts
$D_3 = 4\cdot\bigl(S(3,1)\cdot 0 + S(3,2)\cdot 2 + S(3,3)\cdot 5\bigr) = 4(0 + 6 + 5) = 44$,
and indeed $M_3 = 4^3 = 64$ while $B_3|G| = 5\cdot 4 = 20$, giving $64 - 20 = 44$. Exactly.

## Grading by blocks: the whole transitivity hierarchy in one place

The rank collapse suggests a refinement that turns out to be the key to the entire
subject. The fibres of the orbit-to-pattern map do not all say the same thing: those
sitting over patterns with $j$ blocks talk about $j$-tuples. So one can ask the
vanishing question *one block-number at a time*.

> **Block-graded criterion.** Fix $1 \le j \le k \le |X|$. Every fibre over a pattern
> with exactly $j$ blocks is a singleton **if and only if** the action is $j$-transitive.

Read that carefully: the level-$k$ data alone — the orbits of $k$-tuples, sorted by
coincidence pattern — resolves the entire transitivity hierarchy up to level $k$. Slice
by $j$ blocks and you read off whether the action is $j$-transitive. One number, the
$k$-th moment, cannot do this; the graded fibre data can.

The proof needs one small but genuinely necessary ingredient: for every $j$ with
$1 \le j \le k$ there really *is* a pattern with $j$ blocks. That is obvious once you
write one down — merge the last $k-j+1$ coordinates into a single block and keep the
first $j-1$ apart — and it says that the Stirling triangle has no interior zeros,
$S(k,j) \ge 1$ for $1 \le j \le k$. Together with the boundary values $S(k,k) = 1$
(only the all-distinct pattern has $k$ blocks), $S(k,1) = 1$ (only the all-equal
pattern has one), and $S(k,0) = 0$ for $k \ge 1$, one gets the tail identity

$$\sum_{r=2}^{k} S(k,r) \;=\; B_k - 1,$$

which will do real work in a moment.

## Is the spectrum a finer invariant than the moments?

Here the story takes an unexpected turn. It is tempting to believe the fibre spectrum
$(t_r)$ is strictly more informative than the moments $M_k$ — after all, it splits one
number into many. That belief is *half right, and half wrong*, and the split is sharp.

**Wrong against the whole family of moments.** For two actions of groups of the *same
order*, the moments $M_j$ for all $j \le k$ agree if and only if the spectra $t_r$ for
all $r \le k$ agree. The reason is linear algebra: the Stirling expansion
$M_j/|G| = \sum_r S(j,r) t_r$ expresses the moments as the image of the spectrum under
the Stirling matrix, which is triangular with $S(j,j) = 1$ on the diagonal. A
unitriangular matrix is invertible over the integers, so the transform can be undone,
term by term, by induction on $j$. Spectrum and moment sequence are the *same*
invariant, in different clothing.

**Right against a single moment.** One moment, on its own, is genuinely blind. Consider
a group of order $4$ and two of its actions: the regular action on its own four
elements, and the trivial action on a two-point set. The first has $|X^g| = 4$ for the
identity and $0$ otherwise, so $M_2 = 16$. The second has $|X^g| = 2$ for all four
elements, so $M_2 = 4 \cdot 4 = 16$. Identical second moments. But the first action is
transitive ($t_1 = 1$) and the second has two orbits of points ($t_1 = 2$). The spectra
differ at the very first entry.

What separates them, of course, is the *first* moment: $4$ versus $8$. That is the
equivalence theorem doing its job. The moral is precise and slightly surprising: the
grading, not the spectrum, is the source of new information. What the spectrum buys you
is not more data but *better organized* data — data in which the transitivity hierarchy
is legible.

## The defect propagates, and by how much

If an action fails to be $2$-transitive, it certainly fails to be $k$-transitive for
every $k \ge 2$. That is soft. The interesting question is *quantitative*: does a small
failure at level $2$ force a large failure at level $k$?

It does, and one can pin down the constant. The spectrum is nondecreasing,
$t_1 \le t_2 \le \cdots$ (a coarser tuple length can only have fewer orbits), so in the
Stirling expansion of $D_k$ every term with $r \ge 2$ contributes at least $t_2 - 1$,
and there are $B_k - 1$ such terms by the tail identity. Writing
$a = t_1 - 1$ and $b = t_2 - 1$, one has $D_2 = |G|(a+b)$ and
$D_k \ge |G|\bigl(a + (B_k-1)b\bigr)$, whence

$$B_k \cdot D_2 \;\le\; 2\, D_k \qquad (2 \le k \le |X|).$$

The step from the naive constant $B_k - 1$ to the sharp $B_k$ is exactly the inequality
$a \le b$, which trades the deficient weight $S(k,1) = 1$ on the first coordinate against
the surplus weight $B_k - 1$ on the rest. Since $B_k$ grows superexponentially — $B_{10}$
is already $115\,975$ — even a single unit of failure at level $2$ blows up dramatically
by level $10$.

Is $B_k/2$ the best possible constant? For the *linear relaxation* — treat the spectrum
as an arbitrary nondecreasing sequence — yes: equality holds along the ray where the
spectrum is constant, $t_1 = t_2 = \cdots = t_k$. But here is the twist. That extremal
ray is *not realized by any actual group action*. For $3 \le k \le |X|$, a constant
spectrum forces $D_2 = 0$, so the inequality degenerates to $0 \le 0$ on the ray. The
reason is a small, pretty piece of orbit combinatorics: if $X$ has at least three points
and exactly two orbits of points, then there are at least three orbits of ordered pairs
of distinct points — two "cross" orbits, plus one inside whichever orbit is not a
singleton — so $t_1 = 2$ forces $t_2 \ge 3$. Combined with a multiplicative constraint
below, $t_1 = t_2$ forces $t_1 = 1$. The true propagation constant for genuinely
non-$2$-transitive actions is therefore *strictly larger* than $B_k/2$, and determining
it exactly is an open problem.

## Two more structural laws

**The defect only grows.** Comparing two tuple lengths $j \le k$, the Stirling triangle is
monotone along its columns: $S(j,s) \le S(k,s)$ for $1 \le j \le k$. One sees this by an
explicit injection of patterns — take a pattern of $\{1,\dots,j\}$ and attach every new
coordinate $j+1,\dots,k$ to the block containing $1$; the number of blocks is unchanged,
and distinct patterns stay distinct. Feeding this into the spectral formula gives

$$D_j \;\le\; D_k \qquad (j \le k \le |X|).$$

The Bell defect is a *monotone* obstruction: failure at a short length persists, with at
least the same magnitude, at every longer one.

**Intransitivity is quadratically expensive.** All the bounds above are linear in the
spectrum. There is a genuinely multiplicative one. If the action has $t_1$ orbits of
points, choose $r$ *pairwise distinct* orbits and pick one point from each: the result is
an injective $r$-tuple, and distinct choices of orbits give distinct orbits of tuples.
Hence the falling factorial embeds into the spectrum:

$$t_1(t_1-1)\cdots(t_1-r+1) \;\le\; t_r .$$

In particular $t_1(t_1-1) \le t_2$: an action with many point-orbits has *quadratically*
many pair-orbits. Feeding this back gives a lower bound for the defect in terms of the
orbit count alone,

$$D_k \;\ge\; |G|\Bigl[(t_1 - 1) + (B_k - 1)\bigl(t_1(t_1-1) - 1\bigr)\Bigr]
\qquad (2 \le k \le |X|),$$

so the defect grows at least quadratically in the failure of transitivity.

## Arithmetic can certify a defect without any counting

Finally, a bound from outside the combinatorics. If an action is $k$-transitive then the
injective $k$-tuples form a single orbit, and the orbit-stabiliser theorem says the length
of that orbit divides the group order. The number of injective $k$-tuples is the falling
factorial $|X|(|X|-1)\cdots(|X|-k+1)$, so:

> $k$-transitivity forces $|X|(|X|-1)\cdots(|X|-k+1)$ to **divide** $|G|$ — in particular
> to be at most $|G|$.

Contrapositively, if the group is simply too small, the defect must be strictly positive,
with an explicit quantitative floor: whenever $|G| < |X|(|X|-1)\cdots(|X|-k+1)$ and
$k \le |X|$, one gets $t_k \ge 2$, hence $\#(X^k/G) \ge B_k + 1$ and

$$M_k \;\ge\; (B_k + 1)\,|G|.$$

No orbit computation is needed — just comparing two integers. For instance, a group of
order $4$ acting on $4$ points cannot be $2$-transitive because $4 < 4\cdot 3 = 12$, so its
second moment must be at least $3 \cdot 4 = 12$; the true value, $16$, comfortably obeys.

## What the picture looks like from a distance

Start with a group acting on a set. Form the sequence of moments of its fixed-point
counts. Each moment is a count of orbits of tuples. Each orbit of tuples remembers a
coincidence pattern, and the fibres of that memory are governed by a single sequence of
integers, the orbit counts of injective tuples. The whole apparatus assembles into one
identity,

$$\sum_{g\in G} |X^g|^k \;=\; \Bigl(B_k + \sum_{P}(m_P - 1)\Bigr)\,|G|,$$

and the excess term is a nonnegative integer that vanishes exactly at $k$-transitivity,
grows with $k$, propagates from level $2$ upward with an explicit superexponential
constant, is bounded below by a quadratic function of the orbit count, and can be certified
positive by a divisibility test on $|G|$.

There is something satisfying about this. Transitivity properties of group actions are
usually treated as qualitative — an action either is or is not $5$-transitive, and the
finite list of highly transitive groups is one of the crown jewels of finite group theory.
The Bell defect makes the property quantitative without losing exactness: the defect is
never an estimate, always an integer count of something concrete, namely the extra orbits
per coincidence pattern. Between "perfectly mixing" and "not perfectly mixing" there is now
a graded scale, and the scale is made of Bell numbers.

Several natural questions remain wide open. What is the true propagation constant over
genuine group actions, once the fictitious extremal ray of the relaxation is removed?
Does the multiplicative hierarchy $t_{r+s} \ge t_r(t_s - r)$ hold in general, extending the
falling-factorial bound? Which integer sequences arise as fibre spectra of actual actions
— that is, what is the exact shape of the cone in which the spectrum lives? Each of these
is now a clean, finite, combinatorial question, which is the real dividend of trading a
sum over group elements for a sum over partitions.
