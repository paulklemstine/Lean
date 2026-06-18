# The Arithmetic Wall: Why Some Mathematical Fingerprints Can Never Be Enough

## A fundamental limit on what persistence can see in the world of numbers

Imagine you're an art detective trying to authenticate paintings. You have a set of tools — ultraviolet light, X-ray imaging, paint chip analysis — each giving you a particular kind of fingerprint. Some forgeries are easy to spot: the paint chemistry is wrong, the canvas is too new. But what if two paintings are made with identical materials, by equally skilled hands, and differ only in the artist's intent? At some point, your tools hit a wall. Not because they're poorly designed, but because the *kind* of information they capture has a fundamental ceiling.

Something remarkably similar happens in one of the most active frontiers of modern mathematics, where researchers are trying to use ideas from *topological data analysis* — a field that studies the "shape" of data — to crack open problems in *number theory*, the ancient study of prime numbers and their deep patterns.

## Barcodes for Primes

The central tool in topological data analysis is the **persistence barcode**. Think of it as a summary of the shapes hidden in data. If you imagine slowly inflating points in a point cloud until they start to merge, the barcode records when holes appear and when they fill in. Each "bar" in the barcode represents a feature — a loop, a cavity, a void — and the length of the bar tells you how persistent, how real, that feature is.

In the last decade, mathematicians have begun asking a daring question: what if you applied this shape-detection machinery not to physical data, but to the arithmetic of algebraic equations? Specifically, given an algebraic curve or surface defined by polynomial equations over the rational numbers, you can reduce those equations modulo each prime number *p*. This gives you, at every prime, a finite geometric object — a variety over a finite field. And finite geometric objects can be analyzed with persistent homology.

The dream is tantalizing: perhaps the collection of persistence barcodes at every prime — what we call a **primewise persistent encoding** — could capture deep arithmetic information about the original variety. Could it reconstruct the Hasse–Weil zeta function, the master generating function that encodes how many solutions the equations have over every finite field?

## The Wall

Our research reveals a sharp answer: **no, not if the encoding has bounded complexity**.

The result is both simple and devastating. A persistence barcode at a single prime is a finite combinatorial object. If each barcode uses at most *k* intervals and the endpoints are bounded by *D*, then the total number of possible barcodes is at most (D+1)^{2k}. This is a large number — for k = 3 and D = 10, it's about 1.77 million — but it's *fixed*.

Meanwhile, the arithmetic data you'd need to capture keeps growing. The Frobenius trace of an elliptic curve at prime *p* can be any integer between roughly −2√p and 2√p. As *p* grows, the range of possible traces grows without bound. So any bounded barcode encoding eventually runs out of slots: there must exist pairs of mathematically distinct objects that produce identical barcodes.

This is the **arithmetic universality barrier**. It's not a failure of any particular encoding scheme — it's a theorem about *all possible* bounded encodings simultaneously.

## The Pigeonhole Principle, Elevated

The mathematical engine behind the barrier is surprisingly elementary: the pigeonhole principle. If you have more pigeons than holes, some hole must contain at least two pigeons. But applying this principle in the right context yields non-obvious consequences.

Consider a family of 1,771,562 elliptic curves. If you encode each curve using a barcode with at most 3 intervals and endpoints up to 10, you have only 1,771,561 possible barcodes. Therefore, at least two curves in the family must receive the same barcode at any given prime. This collision is unavoidable — it's a mathematical certainty, independent of how cleverly you design the encoding.

The barrier extends to multiple primes. Using *n* primes with per-prime capacity *C* gives total capacity *C^n*. This grows exponentially, but the number of possible Frobenius polynomials grows even faster when the degree is large enough. For degree-*d* Frobenius data with coefficients in a range that grows with the primes, the polynomial count eventually overwhelms the barcode capacity.

## Refinement Can't Save You

One might hope that by using finer and finer encodings — more intervals, larger endpoint bounds — you could always stay ahead of the arithmetic data. Our refinement monotonicity theorem shows that increasing the bounds (k, D) does increase the capacity, and it does so monotonically. But the growth is polynomial-times-exponential in the parameters, while the Frobenius data has an independent exponential growth rate tied to the degree of the variety.

This means: to match the arithmetic complexity, your barcode complexity parameters must grow *with* the arithmetic parameters. There's no universal choice of (k, D) that works for all varieties of a given type. The encoding must scale.

## Products and Künneth

When you take the product of two varieties, the natural barcode is the concatenation of the individual barcodes. Our product capacity theorem shows that the capacity is multiplicative: it equals the product of the individual capacities. This is reminiscent of the Künneth theorem in algebraic topology, which describes the homology of products.

But this multiplicativity has a sharp consequence for the barrier. A product variety has Frobenius data that is determined by the Frobenius data of its factors. So if the factors' data already exceeds the barcode capacity, the product's data exceeds it even more dramatically. Products don't help; they make the problem worse.

## What This Means for the Field

The arithmetic universality barrier doesn't mean persistent homology is useless for number theory — far from it. What it means is that bounded-complexity encodings must be complemented by other data to achieve full reconstruction. The barrier tells you precisely what's missing: you need information that grows with the primes.

This suggests a research program: identify the *minimal additional data* beyond persistence that suffices for zeta function reconstruction. Our conjecture is that this additional data is exactly the Frobenius characteristic polynomial data — the eigenvalues of the Frobenius endomorphism acting on étale cohomology. If true, this would give a complete characterization: persistence barcodes capture the topological shadow of arithmetic, but the arithmetic content — the "sauce" that makes number theory rich — requires data that references the actual Frobenius action.

## The Bigger Picture

This work sits at the intersection of three major mathematical movements: the algebraization of topology (using algebraic structures to study shapes), the topologization of arithmetic (using shape-theoretic ideas to study numbers), and the rise of information-theoretic methods in pure mathematics (using counting arguments to establish impossibility results).

The barrier theorem is, at its core, an information-theoretic statement. It says that bounded channels (barcodes) cannot transmit unbounded information (arithmetic data). This is the same principle that governs communication systems, data compression, and cryptographic security — transplanted into the realm of algebraic geometry and number theory.

Perhaps most strikingly, the barrier provides a *positive* research direction. Instead of asking "can persistence do everything?", we can now ask the more refined question: "what, precisely, can persistence do?" The answer will likely involve a beautiful interplay between the topological content (captured by persistence) and the arithmetic content (captured by Frobenius) of algebraic varieties, mediated by the local-to-global philosophy that permeates modern number theory.

The wall is real. But walls, in mathematics, are often the most interesting places to stand. From the top, you can see in both directions.

---

*The research described here develops the mathematical framework of primewise persistent encodings and proves obstruction theorems establishing fundamental limits on what bounded-complexity persistence data can distinguish about arithmetic objects. The work combines ideas from topological data analysis, algebraic number theory, and combinatorics.*
