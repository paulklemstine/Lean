# The Shape of Numbers: How Persistence Theory Is Cracking Open Algebraic Geometry

*A new mathematical framework reveals that the hidden symmetries of algebraic surfaces can be detected by watching how slope data disappears under filtration.*

---

When you pour water into a landscape of mountains and valleys, the topology changes. Lakes form, merge, and eventually flood everything. The sequence of births and deaths of these topological features — tracked by a tool called *persistent homology* — has revolutionized data science, from analyzing the shape of protein molecules to mapping the cosmic web of galaxies.

Now, a surprising connection has emerged: the same persistence machinery, applied not to physical landscapes but to the arithmetic data of algebraic varieties, can classify some of the most fundamental objects in number theory.

## Slopes of Frobenius

Every algebraic variety defined over a finite field carries a hidden arithmetic fingerprint: the *slopes of Frobenius*. These are rational numbers that encode how the variety's cohomology — its shape, in a deep algebraic sense — interacts with the prime characteristic of the base field.

For a K3 surface, one of the most studied classes of algebraic surfaces, the Frobenius slopes form a sequence of 22 rational numbers between 0 and 2. This sequence, arranged in order, looks like a barcode — and that resemblance is not superficial.

The key insight of arithmetic persistence theory is this: **treat the sorted slope sequence as a filtration, and study what persists.**

## The Persistent Rank Function

Given a slope profile — say, the 22 Frobenius slopes of a K3 surface — the *persistent rank* at threshold $t$ simply counts how many slopes lie at or above $t$. As you raise the threshold from $-\infty$ to $+\infty$, this count drops from 22 to 0 in a series of steps.

This stepping-down behavior is guaranteed: the persistent rank function is always *antitone* (non-increasing). But the pattern of steps — where they occur, how large each drop is — carries rich arithmetic information.

For a strictly monotone profile (all slopes distinct), the rank at the $k$-th slope value equals exactly $n - k$, where $n$ is the total number of slopes. The jump locations are precisely the distinct slope values, and the jump count determines how many different slopes appear.

## Separation: The Complete Invariant Theorem

The central result of the new theory is a *separation theorem*: two sorted slope profiles are identical if and only if they produce the same persistent rank function.

The proof is beautifully concrete. Suppose two monotone profiles $\sigma$ and $\tau$ differ at some position $k$ — say $\sigma_k < \tau_k$. Setting the threshold to $\tau_k$, monotonicity forces every entry up to position $k$ in $\sigma$ to lie below the threshold (since $\sigma$ is non-decreasing and $\sigma_k < \tau_k$), while every entry from position $k$ onward in $\tau$ lies at or above it. The persistent ranks must therefore differ.

This means the persistent rank function is a *complete* invariant: it loses no information about the sorted slope data. No two distinct varieties with different slope profiles can produce the same persistence curve.

## The Tropical Defect

The functional equation of the zeta function of a smooth projective variety imposes a striking symmetry on its Frobenius slopes: they come in pairs summing to a constant (the *weight*). For K3 surfaces, this means the slopes should pair up to sum to 2.

The *tropical defect* quantifies any failure of this pairing. It sums the absolute deviations from perfect symmetry across all paired indices. A zero tropical defect is equivalent to Newton symmetry — the variety satisfies the expected functional equation constraints exactly.

The name "tropical" comes from the connection to tropical geometry, where the min-plus semiring replaces ordinary arithmetic. In the tropical world, the Newton polygon (whose slopes are our slope profile) becomes a piecewise-linear object, and its self-duality corresponds precisely to Newton symmetry. The defect measures how far the tropical Newton polygon deviates from self-duality.

## Heights and Jump Counts

For K3 surfaces, the *formal Brauer group height* $h$ is a fundamental invariant taking values in $\{1, 2, \ldots, 10, \infty\}$. The height $\infty$ case (supersingular surfaces) is the most exotic — the entire Newton polygon collapses to a single slope.

Arithmetic persistence theory connects height to jump structure: for a monotone slope profile, the number of distinct values (equivalently, the number of jumps in the persistent rank curve plus one) captures how many different Frobenius eigenvalue slopes appear. This is the *jump count theorem*:

$$\text{jumpCount}(\sigma) + 1 = \text{distinctCount}(\sigma)$$

For K3 surfaces, this count is directly related to the height. A height-1 surface (ordinary) has the maximum number of distinct slopes, while a supersingular surface has the minimum.

## The Arithmetic Persistence Signature

Packaging these invariants together yields the *arithmetic persistence signature*: a triple consisting of
- the **distinct count** (number of distinct slope values),
- the **total mass** (sum of all slopes, related to the degree of the L-function), and
- the **maximum multiplicity** (how concentrated the slopes are around one value).

This signature provides a coarse but computable first-pass classification. Two varieties with different signatures are guaranteed to be arithmetically distinct. The signature is shift-invariant: adding a constant to all slopes merely shifts the persistent rank curve without changing its shape.

## Towards a Complete Height Detector

The most exciting open direction is the *Height Refinement Conjecture*: for K3 surfaces with finite formal Brauer group height $h$, the persistent rank curve has exactly $2h + 1$ distinct slope values, and the pattern of jumps uniquely determines $h$.

This conjecture is *testable*. One can compute the Frobenius slopes of explicit K3 surfaces (for example, diagonal quartic surfaces $x_0^4 + x_1^4 + x_2^4 + x_3^4 = 0$) over small finite fields using Kedlaya's algorithm, then verify whether the jump pattern matches the known height from formal group computations.

If confirmed, this would give the first purely persistence-theoretic algorithm for computing formal group heights — transforming a subtle algebraic invariant into a simple counting problem on a step function.

## A New Bridge

What makes arithmetic persistence theory compelling is not just its results, but its position. It sits at the intersection of three mathematical worlds:

**Algebraic geometry** provides the objects (varieties, Newton polygons, Frobenius operators) and the deep structural theorems (Weil conjectures, functional equations).

**Topological data analysis** provides the conceptual framework (filtrations, persistence, barcodes) and the computational tools (algorithms for computing persistent homology at scale).

**Tropical geometry** provides the algebraic bridge (the min-plus semiring replaces derivatives with slopes, smooth curves with piecewise-linear objects, and analytic continuation with tropical convexity).

The persistent rank function lives naturally in all three worlds. In algebraic geometry, it encodes Newton polygon data. In TDA, it is a persistence curve. In tropical geometry, it is a rank function on the tropical semiring.

## The Road Ahead

The theorems established so far — antitonicity, separation, tropical defect characterization, jump-count height encoding — form the foundation layer. Five research directions beckon:

First, **height refinement**: upgrading the binary supersingular/ordinary classifier to a complete height detector. Second, **abelian varieties**: extending from surfaces to higher-dimensional varieties where the slope data is richer. Third, **motivic persistence**: connecting persistence invariants to motivic cohomology and the Grothendieck ring. Fourth, **arithmetic phase transitions**: studying how persistence signatures change as the prime varies, potentially linking to the Sato-Tate conjecture. Fifth, **computational certification**: building verified algorithms that produce cryptographic-grade proofs that a classification is correct.

Each direction is falsifiable by explicit computation. Each builds on the certified separation theorems as its foundational ingredient. And each could change how mathematicians think about the arithmetic of algebraic varieties — not as static invariants to be computed, but as dynamic persistence landscapes to be explored.

---

*The landscape of algebraic geometry is vast and varied. Arithmetic persistence theory suggests that, like the mountains and valleys revealed by rising water, the shape of this landscape can be understood through what persists — and what washes away.*
