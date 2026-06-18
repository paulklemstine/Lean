# The Algebraic Microscope: How Prime Numbers Reveal Hidden Structure in Shape Data

## A new mathematical framework borrows from number theory to decompose shape signals into independent "prime channels"

---

When mathematicians study the shape of data — the loops, voids, and tunnels hidden in a cloud of points — they rely on a tool called *persistent homology*. Born in the early 2000s, this technique tracks how topological features appear and disappear as you gradually expand a lens around each data point, like watching shapes emerge from fog. The resulting "barcode" of birth and death times has become indispensable in fields from neuroscience to materials science.

But persistent homology has a dirty secret. The standard version works over fields — number systems like the rationals or modular arithmetic where every nonzero number has an inverse. When the underlying algebra involves integers instead of fields, the story gets richer but also messier. Integer-valued homology carries *torsion*: elements that vanish when multiplied by some integer. Think of clock arithmetic: on a 12-hour clock, multiplying 4 by 3 gives 12, which wraps back to zero. This kind of annihilation contains genuine geometric information — about non-orientable surfaces, about the subtle twisting of bundles — but it has resisted the clean stability guarantees that make field-valued persistence so useful.

Now, a new mathematical framework shows that this torsion information is not merely richer than its field-valued cousin. It decomposes into independent *prime channels*, each of which can be isolated and analyzed separately, just as a prism splits white light into its constituent colors.

## The Problem with Torsion

To understand why this matters, consider what happens when you compute the homology of a topological space using integer coefficients instead of rationals. The result is a finitely generated abelian group — a mathematical object that looks like:

$$\mathbb{Z}^r \oplus \mathbb{Z}/n_1\mathbb{Z} \oplus \mathbb{Z}/n_2\mathbb{Z} \oplus \cdots$$

The first part, $\mathbb{Z}^r$, is the "free" part — it counts the number of independent loops, voids, or higher-dimensional cavities. The remaining pieces are torsion: cyclic groups that encode subtle twisting information invisible to field-valued homology.

When you track these groups across a filtration — the gradual expansion that defines persistence — you get a persistence module over the integers. The torsion elements are born and die at specific filtration indices, and these birth times contain real topological information. But proving that these birth times are *stable* — that small perturbations of the input lead to small changes in the birth data — has been challenging precisely because torsion doesn't decompose as cleanly as free modules.

The key realization is that every integer factors uniquely into primes, and this factorization propagates to the torsion structure. A torsion element killed by 12 secretly decomposes into a 4-torsion piece (the 2-primary part) and a 3-torsion piece (the 3-primary part). These pieces live in different "channels" and behave independently.

## The Algebraic Microscope

The new framework formalizes this intuition through a construction borrowed from commutative algebra: *localization at a prime*. Localization is one of the most powerful tools in modern algebra, and yet it has never been systematically applied to persistence theory.

Here is the idea. Given a persistence module $F$ — a sequence of abelian groups connected by maps — and a prime number $p$, we construct a new persistence module $L_p(F)$ by replacing each group with its *p-primary subgroup*: the collection of elements killed by some power of $p$. This is the algebraic equivalent of looking at the data through a filter that passes only the $p$-frequency component of the torsion signal.

The construction is functorial: it respects the structure maps of the persistence module, and injective maps between groups restrict to injective maps on the $p$-primary subgroups. This functoriality is not a technicality — it is the engine that makes the entire framework work.

## Three Fundamental Theorems

The framework establishes three core results that together show primewise torsion stability is not ad hoc but structurally inevitable.

**Theorem 1: Localization preserves interleavings.** An *interleaving* is the standard notion of approximate equivalence in persistence theory. Two persistence modules are $\delta$-interleaved if there exist maps between them that shift indices by $\delta$ and approximately invert each other. The first theorem states that if $F$ and $G$ are $\delta$-interleaved, then their localizations $L_p(F)$ and $L_p(G)$ are also $\delta$-interleaved — with the *same* shift parameter $\delta$. Localization never inflates the distance between persistence modules.

**Theorem 2: Birth set identification.** The $p$-torsion birth set of $F$ — the filtration indices where $p$-torsion first appears — equals the global torsion birth set of the localized module $L_p(F)$. In other words, looking at $p$-torsion in the original module is *exactly the same* as looking at all torsion after localizing at $p$. This converts a prime-filtered invariant into an ordinary torsion invariant via base change.

**Theorem 3: Primewise stability via localization.** Combining Theorems 1 and 2, we obtain a new proof that $p$-torsion birth sets are stable under interleavings — but now the proof goes through localization rather than direct argument. The architecture is transparent:
1. Localize the interleaving.
2. Apply ordinary torsion stability to the localized modules.
3. Translate back using the birth set identification.

This is not merely a re-derivation of a known result. It reveals *why* primewise stability holds: it is the image of ordinary stability under an exact base-change functor.

## Why Localization Changes Everything

The deeper significance goes beyond these three theorems. The framework opens the door to a phenomenon that has no analogue in field-valued persistence: *localization can sharpen interleaving witnesses*.

Consider two persistence modules that are $\delta$-interleaved. The interleaving parameter $\delta$ measures how far apart the modules are, but this global measurement lumps together contributions from all primes. After localizing at $p$, the $q$-torsion obstructions (for $q \neq p$) vanish entirely. If those obstructions were inflating the interleaving parameter, localization can reveal a smaller distance — a $\delta' < \delta$ — specific to the $p$-channel.

This is analogous to what happens in signal processing when you decompose a noisy signal into frequency bands. The noise in one band may be much less than the total noise. By analyzing each frequency independently, you can extract cleaner information from each channel than you could from the full signal.

## From White Light to a Spectrum

The analogy to spectral decomposition runs deeper than metaphor. In a finitely generated abelian group, the torsion subgroup decomposes as a direct sum of its $p$-primary components over all primes $p$:

$$A_{\text{tors}} = \bigoplus_p A[p^\infty]$$

This is the *primary decomposition theorem*, one of the foundational results of algebra. The new framework elevates this decomposition from a fact about individual groups to a principle about persistence modules: the global torsion birth set decomposes as a union over prime channels.

Each prime $p$ provides an independent "view" of the torsion dynamics. The 2-primary channel might detect the birth of non-orientability information at one filtration index, while the 3-primary channel detects a different kind of twisting at another. These channels are genuinely independent: one can have perfect stability (zero shift) while another has large instability.

## Connections Across Mathematics

The localization framework connects several mathematical domains that have traditionally been studied in isolation.

From **commutative algebra**, the framework imports the machinery of localization and flat base change — standard tools for studying local-to-global principles in algebraic geometry. Applying these tools to persistence modules is new and opens the possibility of importing other algebraic techniques: completion, reduction modulo prime powers, and eventually derived functors.

From **number theory**, the framework imports the philosophy that understanding behavior "one prime at a time" is the key to understanding global behavior. This is the philosophy behind the Hasse–Minkowski theorem, the study of $p$-adic numbers, and much of modern algebraic number theory. Transplanting this philosophy to topological data analysis creates what might be called *arithmetic topology*.

From **signal processing**, the framework borrows the idea that decomposing a signal into independent channels enables better analysis. The prime channels of torsion persistence are the algebraic analogue of frequency bands.

## Looking Forward

The framework suggests several immediate research directions. First, the witness improvement criterion — showing that localization can strictly reduce the interleaving parameter — is currently formalized as a conditional result. Finding explicit examples where strict improvement occurs would demonstrate the practical value of primewise analysis for computational topology.

Second, the framework naturally extends to *derived localization*, where higher Tor functors measure the failure of exactness for non-flat constructions. This would connect persistence theory to homological algebra in a deeper way, potentially yielding new invariants that measure the "cost" of localization.

Third, the prime decomposition of torsion births suggests new algorithms for topological data analysis. Instead of computing a single barcode, one could compute a *spectral barcode* — a collection of barcodes indexed by prime, each capturing an independent channel of topological information. This could enable more refined comparison of datasets and more sensitive detection of topological features.

The central message is simple but far-reaching: persistence modules over the integers are not merely richer than their field-valued counterparts because they contain torsion. They are richer because their torsion admits *primewise geometric optics* — a decomposition into independent channels, each isolable by localization, each carrying its own stability guarantee, and each potentially revealing structure invisible to the others. This is not just another theorem about torsion. It is the algebraic infrastructure that makes primewise phenomena inevitable, modular, and extensible — the beginning of arithmetic persistence theory.
