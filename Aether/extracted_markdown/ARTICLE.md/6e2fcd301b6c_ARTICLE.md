# The Hidden Prism Inside Your Data

## How mathematicians discovered that shapes have an arithmetic heartbeat — and that listening to one prime at a time reveals what looking at the whole picture misses

---

Imagine you are trying to compare two mountains. Not real mountains — mathematical ones. You have two complex datasets, perhaps representing the shape of a protein or the topology of a brain network, and you want to know: *how similar are they?*

For the past two decades, mathematicians have had a powerful tool for this. It is called *persistent homology*, and it works by building a kind of topological fingerprint of a dataset — a record of when holes, tunnels, and cavities appear and disappear as you zoom in and out. These fingerprints, called *barcodes*, can be compared numerically. Two similar shapes produce similar barcodes, and this similarity is provably robust: small perturbations of the data cause only small changes in the barcode. This is the celebrated *stability theorem* of topological data analysis, and it is the reason the field works at all.

But there has always been a gap in the theory — a blind spot hiding in plain sight.

## The Torsion Problem

Most of the stability machinery was built for data analyzed over *fields* — number systems like the real numbers or rational numbers where you can always divide. In these settings, the algebra is clean and the theory is elegant. But when you compute homology over the *integers*, something richer and stranger happens. You get *torsion*.

Torsion is the algebraic analogue of a twist. Think of a Möbius strip: if you trace a path around it twice, you return to the start — but a single traversal does not close up. This "twisting" shows up in integer homology as elements that are killed by multiplication by some integer. An element of order 2, for instance, doubles to zero. An element of order 6 repeats after six steps.

The crucial observation, known since the 19th century, is that torsion decomposes by primes. An element of order 6 splits into a piece of order 2 and a piece of order 3. An element of order 12 splits into a piece of order 4 (which is 2²) and a piece of order 3. This is not a coincidence — it is a theorem, part of the fundamental structure theorem for finitely generated abelian groups. Every torsion element can be uniquely decomposed into *p-primary* components, one for each prime p.

What nobody had done, until now, was to exploit this decomposition systematically inside persistence theory.

## Arithmetic Optics

The breakthrough begins with a surprisingly simple question: *what happens if we look at persistence through one prime at a time?*

The answer requires a construction from commutative algebra called *localization*. Localization at a prime p is a process that zooms in on the p-primary part of an algebraic structure while making everything else invisible. Mathematically, it is achieved by allowing division by all integers not divisible by p. The integers 3, 7, 11 all become invertible — you can divide by them freely. But 2, 4, 8 remain stubbornly non-invertible if p = 2.

The effect on torsion is surgical. After localizing at 2, all 3-torsion vanishes. All 5-torsion vanishes. All 7-torsion vanishes. What remains is exactly the 2-primary torsion — elements of order 2, 4, 8, 16, and so on — plus the torsion-free part, which is now a module over the localized ring.

Now here is the key insight. Persistence modules — the sequences of groups that encode how topological features evolve across a filtration — can be localized *level by level*. At each index in the filtration, you take the group at that level and localize it. The structure maps between levels induce structure maps between the localized groups. You get a new persistence module, the *localized persistence module*, and it carries exactly the p-primary channel of the original torsion information.

## The Three Theorems

The new theory rests on three interlocking results.

**The first theorem** says that localization preserves interleavings. An *interleaving* is the formal way mathematicians measure the distance between two persistence modules. If two modules are δ-interleaved — meaning they can be connected by maps that commute up to a shift of δ — then their localizations at any prime p are also δ-interleaved. The key ingredient is that localization preserves injectivity of maps. If a map between groups is injective (one-to-one), then the induced map between their localizations is also injective. This is the algebraic property known as *flatness*, and it is what makes the whole machine work.

**The second theorem** identifies the torsion births. In a persistence module, the *birth index* of p-torsion is the first filtration index where an element of order p appears. The theorem states that this is exactly the same as the birth index of *any* torsion in the localized module. After localizing at p, the only torsion that survives is p-primary torsion. So detecting "some torsion appeared" in the localized module is the same as detecting "p-torsion appeared" in the original. This is not a tautology — it requires showing that the quotient construction used in localization neither creates spurious torsion nor destroys genuine p-torsion.

**The third theorem** is the payoff. It rederives the primewise torsion stability theorem — the statement that p-torsion birth sets of interleaved modules are close to each other — as a formal consequence of the first two. The proof is beautifully transparent: localize both modules, observe that the interleaving is preserved, apply ordinary torsion stability to the localized modules, and translate back using the birth-set identification. What was previously a standalone theorem requiring its own bespoke proof becomes a three-line corollary of a general machine.

## Why This Matters

The significance is not just that we have a new proof of an old theorem. The significance is that we have a *functor* — a systematic, compositional, and universal construction that can be applied to any persistence module over the integers. This changes the character of primewise stability from an observation to an inevitability.

Consider the analogy with light. White light contains all frequencies. A prism separates it into component colors. Each color can be analyzed independently — the red channel carries information that the blue channel does not, and vice versa. The localization functor is the algebraic prism for persistence modules. It separates the torsion information into independent prime channels, each of which can be analyzed with the full power of ordinary persistence theory.

This analogy is not merely poetic. The mathematics of spectral decomposition — whether of light, sound, or quantum states — rests on the same algebraic principle: a structured object can be decomposed into simpler components along a natural parameter (frequency, prime, eigenvalue), and the components can be studied and compared independently.

## The Improvement Conjecture

But the most provocative implication of the new theory is not preservation — it is *improvement*. The third theorem says that localization preserves the interleaving parameter δ: if two modules are δ-interleaved, their localizations are also δ-interleaved. But could the localized modules sometimes be interleaved at a *smaller* parameter?

Intuitively, this should happen when the original interleaving is "obstructed" by torsion at primes other than p. If the maps witnessing the interleaving have to accommodate 3-torsion and 5-torsion and 7-torsion simultaneously, they may be forced to use a larger shift than any single prime channel requires. Localizing removes these cross-prime obstructions and could reveal a tighter alignment.

The theory formalizes this as a *witness improvement criterion*: given an interleaving witness that additionally provides tighter interleaving data for the localized modules, the primewise torsion birth sets are close at the improved bound. Computational experiments search for examples where this improvement is strict, probing the conjecture that localization can genuinely sharpen the measurement of similarity between persistence modules.

## A New Kind of Microscope

The implications extend beyond pure mathematics. In computational topology, where persistence modules are computed from point clouds, images, and networks, the localization functor provides a new kind of analytical tool. Instead of computing a single barcode and hoping it captures all relevant features, one can compute prime-channel barcodes — one for each small prime — and obtain a richer, more discriminating fingerprint.

This is especially relevant for data arising from manifolds with torsion in their homology. Lens spaces, projective spaces, and many quotient constructions produce torsion at specific primes. By localizing at those primes, one can isolate exactly the topological features of interest while suppressing algebraic noise from other sources.

The approach also opens connections to number theory. The decomposition of torsion information by primes is formally analogous to the local-global principle in arithmetic: understand a problem prime by prime, then assemble the global picture. The persistence module is the global object; its localizations are the local factors. The birth-set identification theorem is the persistence-theoretic analogue of the statement that the rational structure of an abelian group is determined by its local behavior at each prime.

## Looking Forward

The localization functor is just the beginning. Behind it lies a richer theory involving *derived functors* — the higher-order algebraic invariants that measure the failure of localization to be exact in more general settings. For persistence modules over the integers, localization is exact (because the localized ring is flat), so no higher invariants appear. But for persistence modules over more general rings, or for operations beyond localization, derived functors would detect subtler phenomena.

There are also computational frontiers. The algorithms for prime-channel barcode computation need to be optimized for large-scale datasets. The connection to Smith normal form — the standard algorithm for computing integer homology — suggests that primewise decomposition could be integrated directly into existing computational pipelines with modest overhead.

Most tantalizingly, the theory suggests that persistence modules over the integers are not merely harder to analyze than their field-valued counterparts — they are *richer*. The extra structure that comes from working over ℤ rather than ℚ or 𝔽ₚ is not a bug to be worked around. It is a feature to be exploited. And the algebraic prism of localization is the tool that makes this exploitation systematic, principled, and computationally effective.

The mountains have an arithmetic heartbeat. We are just learning to listen.
