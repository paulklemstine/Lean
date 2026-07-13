# When Counting Meets Cancellation: The Hidden Symmetry of Shuffled Cards

## A tale of two numbers that turn out to be one

Imagine two mathematicians working in different buildings, each with a formula for computing the very same list of integers. The first mathematician counts things. Her formula only ever adds — every quantity she writes down is a plain, honest, non‑negative number, and the final answer is a straightforward tally. The second mathematician calculates alternating sums. His formula is full of plus and minus signs that fight each other; enormous positive terms are chased by enormous negative terms, and only after a delicate cascade of cancellation does a small, tidy number survive.

When they compare notes, they find that their lists agree — entry for entry, forever. The counter's tallies and the calculator's near‑miraculous cancellations produce identical sequences of numbers.

That coincidence is not a coincidence. It is a shadow of one of the most beautiful bridges in modern geometry, the **Hirzebruch–Riemann–Roch philosophy**, which says that a quantity computed by *counting dimensions* must equal a quantity computed as an *Euler characteristic* — an alternating sum. This article tells the story of one clean, fully worked‑out instance of that bridge, where the numbers being counted are among the oldest in combinatorics: the **Eulerian numbers**.

## The numbers that count descents

Take the numbers $1, 2, 3$ and shuffle them into all six possible orders:

$$123,\quad 132,\quad 213,\quad 231,\quad 312,\quad 321.$$

In each shuffle, count how many times a bigger number is immediately followed by a smaller one — a **descent**. The arrangement $123$ has none. The arrangement $132$ has one descent (the step from $3$ down to $2$). Working through all six, exactly one arrangement has zero descents, four have exactly one descent, and one has two descents. Those counts — $1, 4, 1$ — are the **Eulerian numbers** for $n = 3$, written

$$\left\langle 3, 0\right\rangle = 1, \qquad \left\langle 3, 1\right\rangle = 4, \qquad \left\langle 3, 2\right\rangle = 1.$$

In general, $\langle n, k\rangle$ counts the permutations of $\{1, 2, \dots, n\}$ with exactly $k$ descents. These numbers have been studied since Euler in the eighteenth century. They obey a simple rule that lets you build each row from the one above it, just like Pascal's triangle:

$$\left\langle n+1, k \right\rangle = (k+1)\left\langle n, k\right\rangle + (n+1-k)\left\langle n, k-1\right\rangle.$$

From this single recurrence a whole world unfolds. Three facts stand out immediately, and each is elementary enough to check by hand yet points toward something much deeper.

**They are palindromes.** Read a row of Eulerian numbers forwards or backwards and you see the same thing: $1, 4, 1$ is its own mirror image, and $1, 11, 11, 1$ (the row for $n = 4$) is too. Formally,

$$\left\langle n, k\right\rangle = \left\langle n, \, n-1-k\right\rangle.$$

This is not obvious from the descent definition — why should permutations with few descents be exactly as common as permutations with many? — but it falls out of the recurrence, and, as we will see, it is the fingerprint of a hidden geometric symmetry.

**They add up to a factorial.** Sum any row and you get $n!$:

$$\sum_{k=0}^{n-1} \left\langle n, k\right\rangle = n!.$$

For $n = 3$ this is $1 + 4 + 1 = 6 = 3!$. That is no surprise once you remember that every one of the $n!$ permutations has *some* number of descents, so sorting them by descent count and adding the piles back up must return the whole deck.

**They rebuild the powers.** Here is a more surprising identity, due to Worpitzky in 1883. For every whole number $m$,

$$m^n = \sum_{k=0}^{n-1} \left\langle n, k\right\rangle \binom{m+k}{n}.$$

Try $n = 3$, $m = 2$: the right side is $1\cdot\binom{2}{3} + 4\cdot\binom{3}{3} + 1\cdot\binom{4}{3} = 0 + 4 + 4 = 8 = 2^3$. The Eulerian numbers are precisely the coefficients that translate the "power basis" $m^n$ into the "binomial basis" $\binom{m+k}{n}$. This translation dictionary will turn out to be the engine of the whole story.

## A polyhedron made of shuffles

Where does the geometry come in? Take the six permutations of $\{1,2,3\}$ and treat each as a point in space — the permutation $abc$ becomes the point with coordinates $(a, b, c)$. The six points are the corners of a hexagon (a flat slice of three‑dimensional space). This shape is the **permutohedron**, and its higher‑dimensional cousins — built from all $n!$ permutations of $\{1, \dots, n\}$ — are among the most symmetric polyhedra in mathematics.

The permutohedron is more than a pretty shape. It encodes a *variety* — a geometric space, in the sense of algebraic geometry — called the **permutohedral variety** $X_n$, of dimension $n-1$. And attached to any such variety is an algebraic gadget that measures its shape at every scale: its **cohomology ring**, here called the **Chow ring** $A^\bullet(B_n)$. Think of the Chow ring as a tower of vector spaces, one for each dimension $k$, and the single most important thing about it is the *list of dimensions of those floors*:

$$\dim A^0, \ \dim A^1, \ \dots, \ \dim A^{n-1}.$$

This list is called the **Hilbert function**, and packaging it into a polynomial

$$\mathrm{Hilb}(t) = \sum_{k} (\dim A^k)\, t^k$$

gives the **Hilbert series**. It is a census of the geometric space, floor by floor.

The punchline of the classical theory is that this census *is* the Eulerian numbers:

$$\dim A^k(B_n) = \left\langle n, k\right\rangle, \qquad \mathrm{Hilb}(t) = \sum_{k=0}^{n-1} \left\langle n, k\right\rangle\, t^k.$$

Suddenly the three elementary facts from before acquire geometric souls. The palindrome property is **Poincaré duality** — the deep symmetry that pairs the $k$‑th floor of a nice geometric space with its $(n-1-k)$‑th floor, the same duality that makes a doughnut look the same whether you count holes from the inside or the outside. The row sum $n!$ is the **total dimension** of the Chow ring, and it equals the number of top‑dimensional cones in the fan of $X_n$ — the number of chambers the permutohedron's symmetry cuts space into. Counting descents, it turns out, is secretly measuring a polyhedron.

## The other formula: an Euler characteristic

Now meet the second mathematician, the one who works with cancellation. In algebraic geometry, one rarely measures a space by directly counting dimensions. Instead one computes an **Euler characteristic**: an alternating sum in which contributions from even and odd degrees are subtracted from one another. Euler characteristics are the natural output of the tools of the trade — sheaf cohomology, K‑theory, the Riemann–Roch machine — and they come with the plus‑and‑minus signs baked in.

For the permutohedral variety, the relevant K‑theoretic quantity is the **K‑polynomial of the tangent class** $T^{\mathbb{Z}}$, a bookkeeping device that records how the space bends and twists. Its degree‑$k$ coefficient is given by a classical inclusion–exclusion formula:

$$\big[T^{\mathbb{Z}}\big]_k = \sum_{j=0}^{k} (-1)^j \binom{n+1}{j}\,(k+1-j)^n.$$

Look at those alternating signs. For $n = 3$, $k = 1$ this reads

$$\binom{4}{0}\cdot 2^3 - \binom{4}{1}\cdot 1^3 = 8 - 4 = 4.$$

The formula throws up an $8$ and a $4$, subtracts, and lands on... $4$, which is exactly $\langle 3, 1\rangle$. For larger $n$ and $k$ the intermediate terms grow astronomically — enormous binomial coefficients multiplied by high powers — and yet the alternating sum always collapses back down to the small, non‑negative Eulerian number. Nothing about the formula makes it *look* like it should even be positive, let alone equal to a count of descents.

## The bridge: $P^K = \mathrm{Hilb}$

Here is the theorem at the heart of this work, stated plainly:

> **The counting formula and the cancellation formula give the same answer.** The K‑polynomial of the integral tangent class equals the Hilbert series of the Chow ring, coefficient by coefficient and as polynomials:
> $$\sum_{k}\left(\sum_{j=0}^{k}(-1)^j\binom{n+1}{j}(k+1-j)^n\right)t^k \;=\; \sum_{k}\left\langle n, k\right\rangle t^k.$$

This equality — abbreviated $P^K = \mathrm{Hilb}$ — is the concrete face of the Hirzebruch–Riemann–Roch principle for the Boolean matroid. On the left is a *genuine Euler characteristic*, an alternating sum with no manifest positivity. On the right is a *dimension count*, a tally that can never go negative. The theorem says these two utterly different computational recipes are one and the same. The cancellation is not accidental; it is *forced* by geometry, because both sides are legitimate measurements of the same space.

The proof is a small marvel of bootstrapping. One shows that the alternating K‑theoretic coefficients satisfy the very same triangle recurrence as the Eulerian numbers — an identity that, when unwound, is a statement about how binomial coefficients and powers interlock. Since two sequences that share a recurrence and share their starting values must be identical, the two formulas coincide. Every step is elementary; the wonder is that elementary steps chain together to certify a phenomenon that looks, at first sight, like magic.

## Why it matters

Why should anyone care that descents and alternating sums agree? Because this small, completely explicit example is a rehearsal for a vast and largely uncharted theory.

The Eulerian numbers here are the shadow of a much larger object: for *any* combinatorial structure called a **matroid** — an abstraction of the notion of independence that unifies graphs, vector configurations, and error‑correcting codes — there is a Chow ring, a Hilbert series, and a K‑theoretic tangent class. The general $P^K = \mathrm{Hilb}$ identity asserts that the counting side and the Euler‑characteristic side always agree. Matroids are notoriously wild; results that hold across all of them are rare and precious, and each one tends to unlock progress on long‑standing combinatorial conjectures. The Boolean matroid — the free matroid, the simplest one of all — is where the identity can be pinned down completely, checked to the last sign, and understood without a single loose end. It is the lighthouse by which the general theory can be navigated.

There is also a broader lesson, one that recurs throughout mathematics. A quantity that is *manifestly* non‑negative (a dimension, a count) and a quantity that is *manifestly* an alternating sum (an Euler characteristic) are two windows onto the same room. When you can prove they coincide, you win twice over: the counting side certifies that the alternating sum is positive, and the alternating side hands you a closed formula for the count. The palindrome of shuffled cards, the volume of a symmetric polyhedron, the twist of a geometric space, and a delicate near‑cancellation of astronomically large integers all turn out to be the same fact, seen from four directions.

That is the quiet power of a good bridge. It lets you cross from a country where a problem is hard to one where it is easy — and, having crossed, look back and understand both shores at once.
