# The Identity That Can Only Be Kept by a Subgroup

## A formula that knows too much

There is a formula in mathematics that keeps turning up in places that seem to have nothing to do with each other: in the theory of heat flow, in crystallography, in the fast algorithms that compress your photographs, in the number theory behind modular forms. It is called **Poisson summation**, and in its most compact form it says something almost paradoxical: *the total of a function over a lattice equals the total of its frequency profile over the dual lattice.*

Add up a function at the integers, and you learn the same thing as adding up its Fourier transform at the integers. Sample in space, and the answer is a sum in frequency. This is why sampling theory works. It is why a signal sampled too coarsely folds high frequencies down onto low ones — the aliasing you hear in a badly recorded cymbal is Poisson summation making its presence felt.

The formula's usual home is the infinite world of the real line. But it has a perfectly good finite version, and it is the finite version that this article is about. Set aside analysis, set aside convergence, and something surprising becomes visible: the Poisson identity is not merely *true* for lattices and subgroups. It is true *only* for them. The identity is so rigid that it recognizes subgroups, and nothing else.

That is the theorem we will meet: **an exact converse to Poisson summation, and with it, an exact census of every set that can satisfy the identity.**

## The finite stage

Let $G$ be a finite abelian group — think of the clock group $\mathbb{Z}/n$ of integers modulo $n$, or a product of several such clocks. A **character** of $G$ is a way of turning the group into rotations of the circle: a function $\psi \colon G \to \mathbb{C}$ with $|\psi(x)| = 1$ and

$$\psi(x + y) = \psi(x)\,\psi(y).$$

For $G = \mathbb{Z}/n$ the characters are the familiar pure tones $\psi_k(x) = e^{2\pi i k x / n}$, one for each frequency $k = 0, 1, \dots, n-1$. In general the set of all characters, written $\widehat{G}$ and called the **dual group**, is itself a group of exactly the same size as $G$, under pointwise multiplication.

The **Fourier transform** of a function $f \colon G \to \mathbb{C}$ is its correlation with each pure tone,

$$\widehat{f}(\psi) = \sum_{x \in G} \overline{\psi(x)}\, f(x),$$

and Fourier analysis on $G$ is nothing more than the linear algebra of the **character table**: the $|G| \times |G|$ matrix whose entry in row $x$ and column $\psi$ is the complex number $\psi(x)$, always of absolute value $1$.

Now take a subgroup $H \leq G$. Its **annihilator** $H^{\perp}$ is the set of characters that cannot see $H$ at all:

$$H^{\perp} = \{\psi \in \widehat{G} : \psi(x) = 1 \text{ for every } x \in H\}.$$

Poisson summation, in this finite world, reads:

$$|G| \sum_{x \in H} f(x) \;=\; |H| \sum_{\psi \in H^{\perp}} \widehat{f}(\psi) \qquad \text{for every } f \colon G \to \mathbb{C}.$$

Sum over a subgroup on the left; sum over its annihilator on the right. Both sides are perfectly finite. Nothing converges or diverges; nothing is estimated.

## The question nobody asks

The identity above is a *theorem about subgroups*. So here is a question that, once posed, is hard to unask.

Suppose we forget about subgroups altogether. Take any subset $S \subseteq G$ and any subset $T \subseteq \widehat{G}$ — no structural assumptions whatsoever, just two piles of elements — and ask whether

$$|G| \sum_{x \in S} f(x) \;=\; |S| \sum_{\psi \in T} \widehat{f}(\psi)$$

happens to hold for *every* function $f$. Call such a $(S,T)$ a **Poisson pair**.

Poisson summation says that $(H, H^{\perp})$ is always a Poisson pair. Is there anything else? A pair of clever, ragged, structureless sets that accidentally satisfies the same balance?

The answer is a flat no, and the proof is short enough to sketch in full.

## Only two test functions matter

The Poisson condition is a statement about *all* functions $f$, of which there are infinitely many. The first move is to notice that almost all of them are redundant.

Feed the identity a **Dirac delta**: the function $\delta_a$ that is $1$ at a single point $a$ and $0$ everywhere else. Its Fourier transform is the single row of the character table at $a$, conjugated: $\widehat{\delta_a}(\psi) = \overline{\psi(a)}$. The left side of the Poisson identity collapses to $|G|$ if $a \in S$ and to $0$ otherwise, and the identity becomes

$$|S| \sum_{\psi \in T} \overline{\psi(a)} \;=\; |G| \cdot \begin{cases} 1 & a \in S \\ 0 & a \notin S.\end{cases}$$

Because the deltas span the space of all functions, this family of $|G|$ equations is not merely necessary — it is **equivalent** to the original analytic-looking statement. The Poisson identity is a finite statement about the character table in disguise.

Now feed it the opposite kind of test function: a **pure tone** $\psi_0$ itself. Its Fourier transform is a delta on the dual side, and the identity turns into

$$\sum_{x \in S} \psi_0(x) \;=\; |S| \cdot \begin{cases} 1 & \psi_0 \in T \\ 0 & \psi_0 \notin T.\end{cases}$$

Two dual probes, two clean statements. Neither uses anything about $S$ or $T$ other than the numbers in the character table.

## The one hard step: a triangle that cannot bulge

Everything now turns on a single elementary fact, the equality case of the triangle inequality:

> **If $n$ complex numbers, each of absolute value exactly $1$, add up to $n$, then every one of them is $1$.**

Why? Each number contributes at most $1$ to the real part of the sum. If the total real part reaches $n$, no summand can have spared a fraction: every real part is exactly $1$, and since the modulus is $1$, the imaginary part must vanish. Unit vectors can only sum to full length if they all point the same way. It is the geometric statement that a rope of $n$ unit segments spans a distance of $n$ only when it is pulled straight.

Apply this to the character test. If $\psi_0 \in T$, then $\sum_{x \in S} \psi_0(x) = |S|$ — a sum of $|S|$ unimodular numbers reaching the value $|S|$. So $\psi_0(x) = 1$ for *every* $x \in S$. Conversely if $\psi_0$ is trivial on all of $S$, then the sum is $|S| \neq 0$, so $\psi_0$ must lie in $T$. We have proved:

$$\psi \in T \iff \psi(x) = 1 \text{ for all } x \in S.$$

The same argument run through the delta test gives the mirror-image statement:

$$a \in S \iff \psi(a) = 1 \text{ for all } \psi \in T.$$

And now the game is over. The second line says that $S$ is precisely the set of elements annihilated by every character in $T$ — and that set is *automatically a subgroup*, because if $\psi(a) = 1$ and $\psi(b) = 1$ then $\psi(a+b) = \psi(a)\psi(b) = 1$, and $\psi(-a) = \overline{\psi(a)} = 1$. The subgroup structure was never assumed. It was *manufactured* by the identity.

> **Converse of Poisson Summation.** Let $S \subseteq G$ be nonempty and $T \subseteq \widehat{G}$. If $|G| \sum_{x\in S} f(x) = |S| \sum_{\psi \in T} \widehat{f}(\psi)$ for every $f$, then $S$ is a subgroup $H$ of $G$ and $T$ is exactly its annihilator $H^{\perp}$.

Combined with classical Poisson summation, this is a complete classification: **the nonempty Poisson pairs of $G$ are precisely the pairs $(H, H^{\perp})$ with $H$ a subgroup.** (The empty set is a genuine, and the only other, solution: both sides of the identity are then $0$ no matter what $T$ is. So "nonempty" cannot be dropped, but nothing else needs to be added.)

## Free theorems fall out

Rigidity results have a pleasant habit of producing famous corollaries as by-products.

**Lagrange's theorem.** Put $a = 0$ into the delta identity. Every character satisfies $\psi(0)=1$, so the left side is $|S|\cdot|T|$ and the right side is $|G|$. So any nonempty Poisson pair obeys the **area identity**

$$|S| \cdot |T| = |G|,$$

and in particular $|S|$ divides $|G|$. Since the nonempty Poisson sets are exactly the subgroups, we have just derived Lagrange's theorem — the order of a subgroup divides the order of the group — out of an analytic-looking summation formula. No cosets were counted.

**Biduality.** Because each side of a Poisson pair determines the other (both are read off the character table by the membership criteria above), the annihilator of the annihilator of a subgroup is the subgroup itself: $H^{\perp\perp} = H$. This is the finite shadow of Pontryagin duality, obtained here as a corollary rather than as an input.

**Uniqueness.** If $(S,T)$ and $(S,T')$ are both Poisson pairs with $S$ nonempty, then $T = T'$; likewise the primal side is determined by the dual side. A Poisson identity has no wiggle room in either direction.

## Poisson pairs are rectangles

The two membership criteria have a purely combinatorial reformulation that is, in a way, the cleanest form of the theorem. Look at the character table as a giant grid of unimodular numbers, rows indexed by group elements, columns by characters. Call a pair of subsets $S \times T$ an **all-ones rectangle** if $\psi(x) = 1$ for every $x \in S$ and every $\psi \in T$ — that is, if the block of the table cut out by those rows and columns is filled entirely with $1$s.

> **Rectangle Bound.** Every all-ones rectangle in the character table has area at most $|G|$: if $\psi(x)=1$ for all $x \in S$, $\psi \in T$, then $|S|\,|T| \le |G|$.

> **Rectangle Criterion.** For nonempty $S$, the pair $(S,T)$ satisfies the Poisson identity if and only if $S \times T$ is an all-ones rectangle of area *exactly* $|G|$.

So Poisson summation is a statement about the largest monochromatic blocks in the character table. The analysis has completely evaporated: what remains is a question one could pose to a first-year student holding a multiplication table. The character table of a finite abelian group has maximal all-ones rectangles, they all have the same area $|G|$, and each of them is a subgroup paired with its annihilator.

## Counting the solutions

Once you know what the solutions look like, you can count them. The map that sends a Poisson pair $(S,T)$ to the subgroup $\{a \in G : \psi(a)=1 \text{ for all } \psi \in T\}$ is a **bijection** from the set of nonempty Poisson pairs onto the set of subgroups of $G$; its inverse sends a subgroup $H$ to the pair $(H, H^{\perp})$. Hence:

> **Enumeration.** The number of nonempty Poisson pairs of $G$ equals the number of subgroups of $G$.

The analytic question — *for how many pairs of sets does Poisson summation hold?* — has a purely algebraic answer, and one that can be looked up in any group theory text.

Two consequences are worth spelling out. If $|G|$ is a **prime** $p$, the group has only the two trivial subgroups, so there are exactly two nonempty Poisson pairs:

$$(\{0\},\ \widehat{G}) \qquad \text{and} \qquad (G,\ \{0\}).$$

The first is the statement that a single sample determines the average of the Fourier transform; the second that the sum of a function is its Fourier transform at frequency zero. In a group of prime order, those two banal identities are *all* the Poisson identities there are. Nothing in between is possible, and the reason is Lagrange: the area identity $|S|\,|T| = p$ forces $|S| \in \{1, p\}$.

For the cyclic group $\mathbb{Z}/n$, subgroups correspond exactly to divisors of $n$, so the number of Poisson pairs is $\sigma_0(n)$, the divisor-counting function. In this case everything is explicit: the character $\psi_k$ is trivial at $x$ precisely when $n \mid kx$, so the whole classification reduces to an arithmetic condition on integers. Brute-force enumeration over all $2^n \cdot 2^n$ pairs of subsets of $\mathbb{Z}/n$ confirms it:

| $n$ | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| Poisson pairs | 1 | 2 | 2 | 3 | 2 | 4 |
| $\sigma_0(n)$ | 1 | 2 | 2 | 3 | 2 | 4 |

For $n = 6$, the four pairs correspond to the subgroups $\{0\}$, $\{0,3\}$, $\{0,2,4\}$ and $\mathbb{Z}/6$ — of sizes $1, 2, 3, 6$, paired with dual sides of sizes $6, 3, 2, 1$. The area identity $|S|\,|T| = 6$ holds on the nose in every case.

## Where the rigidity ends

Any theorem this sharp invites the question of how far it can be pushed, and there the story becomes more interesting still.

Cosets, not just subgroups, satisfy a Poisson identity — but at the price of a phase. For a coset $a + H$,

$$|G| \sum_{x \in a+H} f(x) = |H| \sum_{\psi \in H^{\perp}} \psi(a)\,\widehat{f}(\psi),$$

with the twisting weight $\psi \mapsto \psi(a)$. One can ask for the converse of *this*: which sets $S$, character sets $T$, and weight functions $w$ satisfy $|G| \sum_{x \in S} f(x) = |S| \sum_{\psi \in T} w(\psi)\widehat{f}(\psi)$?

The answer draws a very clean line. **If the weights are required to be unimodular, rigidity survives intact**: $S$ must be a coset $a+H$, $T$ must be $H^{\perp}$, and the weight is forced to be exactly the phase $w(\psi) = \psi(a)$. **If the unimodularity requirement is dropped, the theorem collapses entirely**: *every* nonempty subset $S$ whatsoever satisfies a twisted Poisson identity, with $T$ the full dual group and the weights simply read off from the Fourier transform of the indicator function of $S$. An explicit witness of the collapse is $S = \{0,1\} \subseteq \mathbb{Z}/3$, which is not a coset of anything (its size does not divide $3$), yet carries a perfectly valid twisted identity.

Unimodularity, in other words, is not a technical convenience introduced to make a proof work. It is *precisely* the dividing line between the rigid regime and the vacuous one — which is exactly what the triangle-inequality argument at the heart of the proof would lead you to expect, since that argument is about unit vectors and nothing else.

## Why it matters

There is a broader lesson here, and it is one that recurs across mathematics: **extremal identities encode structure**. An inequality that is usually strict, when it is forced to be an equality, pins down its input completely. Sums of unit vectors that reach their maximum length must be aligned; sets whose Fourier transforms are maximally concentrated must be cosets; pairs of sets that satisfy Poisson summation must be subgroups and annihilators.

The same rigidity principle, applied one level up, resolves a companion problem. The **uncertainty principle** for finite groups says that a nonzero function cannot be concentrated in both space and frequency at once:

$$|\operatorname{supp} f| \cdot |\operatorname{supp} \widehat{f}| \;\ge\; |G|.$$

Which functions achieve equality? The answer, again complete: exactly the functions of the form

$$f = c\,\psi_1 \cdot \mathbf{1}_{a+H},$$

a nonzero constant $c$ times a character $\psi_1$ times the indicator of a coset $a+H$. The extremals are a single orbit of the natural symmetry group of the problem — scaling, translation, modulation — acting on subgroup indicators. And the reason is the same all-ones rectangle: running the uncertainty chain of inequalities backwards forces the magnitudes of $f$ and $\widehat{f}$ to be flat on their supports, and the phases then carve out a maximal-area all-ones block of the character table, which the converse of Poisson summation converts into a subgroup.

This is the practical face of the result too. The uncertainty inequality is the theoretical backstop of compressed sensing: a sparse signal cannot hide, because sparsity in one domain forces spread in the other. The equality case tells you the *only* signals for which the backstop is tight — the ones an algorithm has no hope of distinguishing better than the bound allows. Knowing the extremals exactly is knowing precisely where the worst case lives.

## The shape of the argument

Step back and the proof has a pleasing minimalism. Not a single estimate is made. No inequality is used except the triangle inequality, and it is used only in its equality case. The infinitude of test functions is reduced to two families — deltas and pure tones — that between them see everything. And what remains is a question about a table of unit-modulus numbers, answered by the observation that unit vectors summing to full length must all point the same way.

Poisson summation is often presented as an analytic miracle: a bridge between space and frequency, between counting and oscillating. What the converse reveals is that the miracle is entirely algebraic. The identity does not merely happen to hold for subgroups. It holds for subgroups *and for nothing else*, and if you write it down for an arbitrary pair of sets and insist that it be true, the sets have no choice but to become a subgroup and its annihilator.
