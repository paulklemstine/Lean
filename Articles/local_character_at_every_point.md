# The Line That No Sequence Can Reach

## A journey to the strangest number line ever built

Imagine a number line so rich that it contains every real number, every infinite ordinal, every infinitesimal you can dream up — and infinitely many more besides. Imagine that on this line, you can add, subtract, multiply, and divide exactly as you always have. It is ordered, it is dense (between any two of its points sits a third), and it forms a perfectly respectable algebraic object: an ordered field.

Then imagine trying to do calculus on it.

You cannot. Not because the tools are hard to build, but because the very first tool — the idea of a sequence closing in on a limit — dies on arrival. This article is about *why*, and about how precisely we can measure the failure.

The object in question is the **surreal number line**, discovered by John Conway in the 1970s while he was thinking about the endgames of Go. It has become one of the most beautiful structures in mathematics: a single ordered field that swallows the reals, the ordinals, and the hyperreals whole. What we will show is that this same generosity makes it topologically untouchable at every single one of its points.

---

## 1. Building numbers out of nothing

Conway's construction is famously minimal. A surreal number is a pair of sets of previously-constructed surreal numbers,
$$x = \{\, L \mid R \,\},$$
subject to the single requirement that no member of $L$ is greater than or equal to any member of $R$. The number $x$ is then, morally, "the simplest number strictly between $L$ and $R$."

Start with nothing at all: $\{\,\mid\,\} = 0$. On the next day you get $\{0 \mid\,\} = 1$ and $\{\,\mid 0\} = -1$. Iterating, you get every dyadic rational, then (at the first infinite stage) every real number, then $\omega = \{0, 1, 2, 3, \ldots \mid\,\}$, then $\omega + 1$, then $\omega/2$, then $\sqrt{\omega}$, and — crucially for us —
$$\varepsilon = \left\{\, 0 \;\middle|\; 1, \tfrac12, \tfrac14, \tfrac18, \ldots \right\},$$
a number greater than zero but smaller than every positive real. An honest infinitesimal, sitting in an honest field.

The rule "$x$ is the simplest thing strictly between $L$ and $R$" is called a **Conway cut**, and it is the only tool we will really need. It is astonishingly powerful, because $L$ and $R$ are allowed to be *any* sets — of any size whatsoever.

---

## 2. The engine: nothing small is close enough to zero

Here is the first result, and everything else in this story follows from it.

> **Theorem (Coinitiality Failure).** Let $(r_i)_{i \in I}$ be *any* family of positive surreal numbers, indexed by *any* set $I$ — countable, uncountable, of cardinality $\beth_{17}$, it makes no difference. Then there is a positive surreal $y$ with
> $$0 < y < r_i \quad \text{for every } i \in I.$$

The proof is a single line, and it is the whole reason surreal numbers behave the way they do. Form the Conway cut
$$y = \{\, 0 \mid r_1, r_2, r_3, \ldots \,\} = \{\, 0 \mid (r_i)_{i \in I} \,\}.$$
This is a legitimate surreal number, because every member of the left set ($0$) is strictly below every member of the right set (each $r_i$ is positive). And by the defining property of a cut, $y$ is strictly above everything on the left and strictly below everything on the right. Done.

Take a moment to appreciate how violent this is. In the real numbers, the sequence $1, \tfrac12, \tfrac14, \ldots$ *is* coinitial in the positives: nothing squeezes underneath all of it except $0$ itself. That single fact is what makes $\epsilon$-$\delta$ analysis work; it is why "for all $\epsilon > 0$" can be replaced by "for all $1/n$." On the surreal line no such family exists at *any* size. The positive surreals have no small "bottom" — they descend forever, past every set you can name.

---

## 3. The topology, and the meaning of "character"

Give the surreal line its **order topology**: declare the open intervals
$$(a, b) = \{ z : a < z < b \}$$
to be a basis of open sets, exactly as one does on $\mathbb{R}$. A *neighbourhood* of a point $c$ is any set containing an open interval around $c$.

A **neighbourhood basis at $c$** is a collection $\mathcal{B}$ of neighbourhoods of $c$ that is *cofinal downward*: every neighbourhood of $c$ contains some member of $\mathcal{B}$. On the real line, $\{(c - 1/n,\, c + 1/n) : n \in \mathbb{N}\}$ is a neighbourhood basis, and it is countable. A space in which every point has a countable neighbourhood basis is called **first countable**, and the **character** of a point is the smallest size of a neighbourhood basis there. First countability is the invisible hypothesis underneath almost all of elementary analysis: it is what makes sequences an adequate language for continuity, closure, and compactness.

Now watch what the coinitiality theorem does to it.

> **Theorem (No small basis at zero).** Let $(B_i)_{i \in I}$ be any family of neighbourhoods of $0$, indexed by any set. Then there is a neighbourhood $s$ of $0$ that contains **none** of the $B_i$.

*Proof sketch.* Each $B_i$, being a neighbourhood of $0$, contains an interval $(\ell_i, r_i)$ with $\ell_i < 0 < r_i$. Apply coinitiality failure to the family of positive surreals $(r_i)$: there is $y > 0$ with $y < r_i$ for every $i$. Now consider the neighbourhood
$$s = (-y,\, y).$$
For each $i$, the number $y$ itself lies in $(\ell_i, r_i) \subseteq B_i$, because $\ell_i < 0 < y < r_i$. But $y \notin s$, since $s$ stops strictly short of $y$. So $B_i \not\subseteq s$. $\square$

That is a complete proof of a genuinely striking fact, and it fits in a paragraph. No family of neighbourhoods of $0$, of any size, is a basis: you can always slide a thinner interval underneath the whole collection at once.

---

## 4. Every point is as bad as zero

So far the argument is anchored at $0$, where the Conway cut $\{0 \mid \cdots\}$ lives naturally. What about $\pi$? What about $\omega - \sqrt{\varepsilon}$?

Here the algebra rescues us. Because the surreal order is dense — between $x < y$ sits the cut $\{x \mid y\}$ — addition is *jointly continuous* for the order topology. (The verification is the familiar interval-splitting argument: if $a + b < u$, choose $0 < e < u - a - b$ by density and split the slack as $(a+e) + (b + (u - a - b - e))$.) Together with continuity of negation, this makes the surreal line a **topological group**: a group in which the operations respect the topology.

And in a topological group, translation
$$T_c : x \longmapsto x + c$$
is a homeomorphism. It is a bijection, it and its inverse are continuous, so it carries the local structure at $0$ perfectly onto the local structure at $c$. Neighbourhoods map to neighbourhoods; bases map to bases; character is preserved exactly.

> **Theorem (Local character at every point).** Let $c$ be any surreal number and let $(B_i)_{i \in I}$ be any family of neighbourhoods of $c$, indexed by any set. Then there is a neighbourhood of $c$ containing none of the $B_i$.

*Proof.* Translate by $-c$. The images $T_{-c}(B_i)$ are neighbourhoods of $0$. Find a neighbourhood $s$ of $0$ containing none of them, and pull it back: $T_{-c}^{-1}(s)$ is a neighbourhood of $c$, and if it contained some $B_i$, its image $s$ would contain $T_{-c}(B_i)$. Contradiction. $\square$

The consequences cascade immediately:

- **No point has a countable neighbourhood basis.** The surreal line is nowhere first countable — and hence not second countable either.
- **No point has a neighbourhood basis of any set size at all.** This is stronger than uncountability: the character of every surreal is not merely bigger than $\aleph_0$, it is bigger than every cardinal. It is a proper class.
- **The surreal line is not metrizable.** Every metric space is first countable, via the balls of radius $1/n$. No metric, on any target, can induce the order topology on the surreals.

That last point deserves emphasis. It is not that we have failed to find a good distance function on the surreals. It is that no such function can exist, no matter how clever, because metrizability would hand us countable bases we have just proved do not exist.

---

## 5. Sequences see nothing at all

There is a second, entirely independent route to the same conclusion, and it is even more vivid.

> **Theorem (Sequential discreteness).** A sequence $(f_n)$ of surreal numbers converges to $c$ if and only if it is *eventually constant* equal to $c$.

*Proof sketch.* One direction is trivial. For the other, suppose $f_n \to c$ but $f_n \neq c$ infinitely often. Define positive surreals
$$d_n = \begin{cases} 1 & \text{if } f_n = c, \\ |f_n - c| & \text{otherwise.}\end{cases}$$
Every $d_n$ is positive, so by coinitiality failure there is $y > 0$ with $y < d_n$ for all $n$. The interval $(c - y,\, c + y)$ is a neighbourhood of $c$, so by convergence $f_n$ lies inside it eventually. But for any such $n$ with $f_n \neq c$ we would have $|f_n - c| < y$ while $y < d_n = |f_n - c|$: a contradiction. So $f_n = c$ eventually. $\square$

In other words: as far as *sequences* can tell, the surreal line is a discrete space, a scatter of isolated points with nothing between them. Sequences perceive no accumulation, no limits, no structure.

And yet:

> **Theorem.** The surreal line is *not* discrete.

Indeed the order is dense, so any interval around $0$ contains points other than $0$, and $\{0\}$ is not open. So we have a space where sequences behave exactly as in a discrete space, but the space is emphatically not discrete. That gap *is* the failure of first countability — in a first countable space, sequential discreteness would force genuine discreteness. Two proofs, one phenomenon.

---

## 6. What the surreal line looks like from close up

Since sequences are useless, what *does* control local structure? The answer is beautiful: **archimedean classes**.

For a positive "scale" $d$, define the **monad of $c$ at scale $d$** to be
$$\mathrm{monad}(c, d) = \left\{\, z \;:\; |z - c| < d \cdot 2^{-n} \text{ for every } n \in \mathbb{N} \,\right\},$$
the set of points whose distance from $c$ is infinitesimal *relative to $d$*. (Here $2^{-n}$ means the surreal $\mathrm{powHalf}(n)$, the honest $n$-fold halving of $1$.)

These monads turn out to have remarkable properties:

- **They are clopen** — simultaneously open and closed. Each half of a monad is an up-set or down-set with no extremal element, and in an order topology that forces openness of the set and of its complement.
- **They are neighbourhoods.** $\mathrm{monad}(c,d) \subseteq (c - d,\, c + d)$, so shrinking $d$ shrinks the monad inside any prescribed interval. Hence **the monads form a neighbourhood basis of clopen sets at every point**: the surreal line is **zero-dimensional**.
- **At each fixed scale they partition the line.** Two monads of the same scale are either identical or disjoint — the relation "infinitesimally close relative to $d$" is an equivalence.

So the local topology of the surreal line is entirely governed by the archimedean hierarchy: to shrink a neighbourhood of $c$, you must change *archimedean scale*, and the scales are indexed by a proper class of orders of magnitude. That is precisely why no set-sized basis exists — a basis would have to meet every archimedean class, and there are too many.

Zero-dimensionality has a dramatic corollary. A continuous image of a connected space is connected; the surreal line has no connected subset with more than one point (any two distinct points are separated by a clopen partition, using the monad at scale $|x - y|$). Therefore:

> **Theorem.** Every continuous map from a connected space into the surreal line is constant. In particular, there is no nonconstant continuous curve $\mathbb{R} \to \mathbf{No}$.

You cannot draw a path along the surreal line. The line you were picturing does not exist.

---

## 7. And it is nowhere compact

One last hope: zero-dimensional, locally compact topological groups are wonderful objects. They carry Haar measure, they have Pontryagin duals, they are the arena of harmonic analysis over the $p$-adics — and the $p$-adic numbers are zero-dimensional too. Perhaps the surreals sit in the same family?

They do not.

> **Theorem.** No neighbourhood of any surreal number is compact. The surreal line is nowhere locally compact.

The obstruction is elegant. Take the *upper half* of a monad,
$$U = \{\, z > c \;:\; z \in \mathrm{monad}(c,d) \,\},$$
the points just above $c$ and infinitesimally close to it at scale $d$. This set has **no least upper bound at all**. If a candidate $x$ lies in the monad, then $c + 2(x - c)$ is still in the monad (doubling an infinitesimal keeps it infinitesimal, since $d \cdot 2^{-(n+1)} + d \cdot 2^{-(n+1)} = d \cdot 2^{-n}$) and is bigger than $x$, so $x$ is not an upper bound. If $x$ lies outside the monad, so $x - c \ge d\cdot 2^{-n}$ for some $n$, then $c + d \cdot 2^{-(n+1)}$ is a strictly smaller upper bound, so $x$ is not the least one. Either way, no supremum.

But compactness in a linear order *forces* suprema to exist for nonempty closed subsets. Since $U$ sits inside any small enough neighbourhood of $c$, no such neighbourhood can be compact.

So the surreal line is a Hausdorff, zero-dimensional, totally separated topological group in which **no point has a compact neighbourhood, no point has a set-sized neighbourhood basis, no sequence converges nontrivially, and no metric exists**. Every classical local tool fails at every point simultaneously.

---

## 8. Why this matters

It would be easy to read this as a list of things the surreals cannot do. It is better read as a precise identification of *what replaces* the missing structure.

The theme is a dichotomy. On the surreal line, everything local is governed by the archimedean hierarchy — the classification of magnitudes into scales $1, \varepsilon, \varepsilon^2, \omega^{-\omega}, \ldots$, which the theory of Conway normal forms organizes by ordinals. Every neighbourhood basis must reach down through all of them. Since the ordinals form a proper class, no basis can be a set. That single sentence explains, at once, the failure of first countability, of metrizability, of local compactness, and the triviality of sequential convergence.

This is the pattern in *every* field of surreal-like generality. Fields with rich infinitesimal structure — the Levi-Civita field, the Hahn series fields, the hyperreals — all struggle with the order topology in related ways, and the surreals, being the universal such object, exhibit the pathology in its purest form. Anyone hoping to build analysis on such a field learns from these theorems that the sequence must be abandoned in favour of the *net* or the *filter*, and that the "distance" must be replaced by the *archimedean class*.

There is also a lesson about the limits of intuition. Everyone who first meets the surreals pictures a line — Conway's own pictures show a line. But a line, in any topological sense, is connected, and it is precisely connectedness that fails here first and worst. The surreal "line" is a totally disconnected dust, infinitely fine at every scale, with a hierarchy of granularity so tall that no set-indexed magnifying glass can see through it.

What survives is the algebra. The surreals remain a real-closed ordered field of extraordinary reach, and the topology, rather than being an obstacle, is a *measurement* of that reach: the character of every point is exactly a reflection of how many orders of magnitude the field contains. The failure of first countability is not a defect. It is the topology honestly reporting the size of the field.

---

## 9. Open horizons

Two questions stand out. The first is to pin down the character exactly: the conjecture is that at every point the character equals the cofinality of the class of all ordinals, which would make "character = $\mathbf{On}$" a theorem in the proper-class sense. The lower bound is exactly the coinitiality failure above; the upper bound needs the classification of archimedean scales via the Conway normal form $\omega^y$.

The second is a measure-theoretic obstruction: since no neighbourhood is compact, the usual construction of Haar measure cannot start. The conjecture is that no nontrivial translation-invariant countably additive Borel measure on the surreal line assigns finite nonzero mass to a clopen monad — that the surreal line supports no Haar-type integration theory at all. If true, it closes the door on harmonic analysis over $\mathbf{No}$ as firmly as the results above close the door on sequences.

Either way, the moral is the same. Conway built a number system so generous that it contains every ordered field you could reasonably want. The price of that generosity, paid in full at every single point, is that you cannot get close to anything.
