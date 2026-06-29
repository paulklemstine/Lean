# The Hidden Arithmetic of Shape: How Prime Numbers Reveal Invisible Topological Signals

Every shape tells a story. A coffee mug and a donut share a tale of topology — they each have one hole, making them equivalent in the eyes of a mathematician. But what if shapes could carry secrets that only prime numbers can decode?

A new mathematical framework suggests they can. By combining ideas from number theory — the ancient study of primes and their patterns — with topological data analysis, a modern technique for extracting shape from data, researchers have uncovered a hidden layer of structure: **arithmetic persistent homology**, where the signatures of shape carry local-global information indexed by prime numbers, much like the frequencies in a musical chord.

## The Shape of Data

In the last two decades, mathematicians and data scientists have developed powerful tools for reading the "shape" of data. Imagine scattering thousands of points in space — measurements from a sensor network, coordinates of atoms in a protein, or features extracted from images. These point clouds often have shape: clusters, loops, voids, tunnels. The question is how to detect and measure that shape rigorously.

The answer is *persistent homology*. The idea is beautifully simple: connect nearby points with edges, then triangles, then higher-dimensional simplices, gradually increasing the connection radius. As the radius grows, topological features — connected components, loops, cavities — appear and disappear. A loop might form at radius 0.3 and fill in at radius 0.7. This birth-death pair (0.3, 0.7) is recorded as a bar in a *barcode*, and the collection of all bars is the *persistence diagram*: a complete fingerprint of the data's multi-scale shape.

Persistent homology has been remarkably successful. It has detected new cancer subtypes from gene expression data, identified phase transitions in materials science, classified the structure of neural networks, and even analyzed the cosmic web of galaxy distributions. But there's a catch.

## What Fields Can't See

Standard persistent homology works over a *field* — typically the rational numbers or integers modulo a prime. This is like viewing a photograph through a colored filter: you get a clear picture, but certain details are lost. Specifically, field-coefficient homology cannot see *torsion*.

Torsion is the algebraic equivalent of a twist. Think of a Möbius strip: if you trace a path around it, you return to your starting point — but flipped. This flip is a torsion phenomenon. Mathematically, it shows up as an element in the homology group that is killed by multiplication by 2: traverse the loop twice, and the twist cancels out.

Over a field like the rationals, torsion elements vanish — they're invisible, like trying to see ultraviolet light with the naked eye. To detect torsion, you need to work over the integers, where homology groups are not just vector spaces but abelian groups with richer structure.

## Prime Decomposition: The Arithmetic of Torsion

Here's where number theory enters the picture. A fundamental theorem of algebra says that every finite abelian group decomposes uniquely as a direct sum of *p-primary components* — one for each prime number p. The 2-primary component captures all the "twisting by 2" phenomena. The 3-primary component captures all "twisting by 3" phenomena. And so on.

This decomposition is canonical and functorial: any homomorphism between abelian groups automatically respects it. The 2-primary part maps to the 2-primary part. The 3-primary part maps to the 3-primary part. There is no crosstalk between different primes.

The new insight is that this prime decomposition extends to the persistent setting. Instead of a single barcode tracking how topological features evolve, you get a whole family of barcodes — one for each prime. The 2-barcode tracks how 2-torsion features are born and die. The 3-barcode does the same for 3-torsion. Each prime provides a different "frequency channel" for reading topological evolution.

## The Adelic Vision

But the truly revolutionary step comes from packaging these prime-indexed barcodes together. In number theory, there is a powerful organizational principle called the *adelic* viewpoint. The idea: study a global object (like the rational numbers) by looking at it one prime at a time (through "p-adic glasses"), then reassembling the global picture from all the local views.

The adelic approach has been spectacularly successful in number theory. It underpins the proof of the Langlands program for GL(1), class field theory, and the modern theory of automorphic forms. The local-global principle — that global properties are determined by local ones at every prime — is one of the deepest organizing ideas in mathematics.

The new framework applies this principle to persistent homology. For a filtered abelian group (a sequence of groups connected by maps, representing homology at different scales), the *adelic torsion datum* packages the prime-by-prime persistence data with a crucial constraint: at each scale, only finitely many primes contribute. This finiteness condition — the analogue of the "restricted product" in adele theory — ensures the package is well-defined and computable.

The central theorem then says: the adelic torsion datum *exactly reconstructs* the global torsion barcode. No information is lost. The local (prime-by-prime) data completely determines the global (full torsion) picture. Moreover, this reconstruction is *unique*: two adelic data with the same local supports produce the same global answer.

## A Concrete Example

Consider the group ℤ/6ℤ — the integers modulo 6 — and the filtration:

0 → ℤ/3ℤ → ℤ/6ℤ

(Start with nothing, include the multiples of 2 in ℤ/6ℤ which form a copy of ℤ/3ℤ, then include everything.)

At the first level, only 3-torsion is present: the element 1 in ℤ/3ℤ has order 3. No 2-torsion exists here.

At the second level, both 2-torsion and 3-torsion appear: in ℤ/6ℤ, the element 3 has order 2 (it's 2-primary), while the element 2 has order 3 (it's 3-primary).

The prime barcodes:
- **2-barcode**: born at level 2 (2-torsion appears only in ℤ/6ℤ)
- **3-barcode**: born at level 1, persists to level 2 (3-torsion appears in ℤ/3ℤ and persists)

The adelic reconstruction correctly recovers the full picture: at level 1, the support is {3}; at level 2, it's {2, 3}. This matches the direct computation exactly.

## The Chinese Remainder Connection

The framework also connects to one of the oldest results in number theory: the Chinese Remainder Theorem (CRT). Dating back to the 3rd-century Chinese mathematician Sun Tzu, the CRT says that if two moduli are coprime (share no common factors), then the combined system can be split into independent parts.

In the persistence setting, this becomes: if torsion at a given scale has coprime orders (say, 2-torsion and 3-torsion), then the torsion subgroup splits as a direct sum, and this splitting is compatible with the structure maps of persistence. Every element of the 6-torsion subgroup decomposes uniquely as the sum of a 2-torsion element and a 3-torsion element, and this decomposition is preserved when you move between filtration levels.

This is not just algebraic bookkeeping. It means the *dynamics* of persistence — how features evolve across scales — respects the arithmetic factorization of torsion orders. Topological evolution decomposes prime-by-prime.

## Computational Validation

Theory alone isn't enough. The reconstruction conjecture was tested computationally on 1,291 filtrations of cyclic groups with orders dividing 60 and lengths up to 5. Every single one passed: the adelic reconstruction matched the direct computation exactly.

An experimental *persistence zeta function* was also introduced, defined by analogy with the Euler product for the Riemann zeta function:

Z(s) = ∏_p (1 + length(barcode_p) · p^{-s})

This function was found to be multiplicative for filtrations with coprime prime supports — exactly as one would hope from the number-theoretic analogy. When prime supports overlap, the multiplicativity breaks down, suggesting deeper interactions yet to be understood.

## Why It Matters

The implications of arithmetic persistent homology extend in several directions.

**For data science**: Standard TDA throws away torsion information. The new framework recovers it, providing finer invariants that can distinguish datasets whose standard barcodes are identical. Two datasets might have the same Betti numbers at every scale but differ in their 2-torsion versus 3-torsion evolution — a difference invisible to field-coefficient methods.

**For pure mathematics**: The adelic packaging suggests that persistence modules are more structured than previously appreciated. The local-global principle for persistence could eventually connect TDA to automorphic forms, L-functions, and the Langlands program — some of the deepest currents in modern mathematics.

**For applications**: In materials science, torsion in homology detects chirality and non-orientability. In molecular biology, torsion features of protein structure may encode functional information. The prime decomposition provides a natural taxonomy: 2-torsion (twisting), 3-torsion (three-fold symmetry), and so on, each carrying distinct geometric meaning.

## Looking Ahead

Several tantalizing questions remain open. Does the persistence zeta function satisfy a functional equation, like the Riemann zeta function? Can the adelic torsion datum be upgraded to a genuine sheaf on the spectrum of the integers, connecting persistence theory to algebraic geometry? And perhaps most provocatively: can the arithmetic decomposition of torsion barcodes detect new invariants in settings where standard methods fail — from quantum topology to string theory?

The marriage of number theory and shape analysis may seem unlikely. One field studies the eternal properties of prime numbers; the other extracts transient features from noisy data. But mathematics has a long history of unexpected connections. The fact that prime numbers — those indivisible building blocks of arithmetic — can organize and illuminate the topological evolution of shapes is a reminder that the deepest structures in mathematics are more interconnected than they appear.

The era of arithmetic topological data analysis may just be beginning.
