# When Numbers Shine: How Treating Integers Like Light Reveals Hidden Mathematical Truths

*A new machine-verified theory treats numbers as light sources on a line, and the resulting interference patterns expose the secret structure of prime numbers*

---

## The Experiment That Changed How We See Numbers

Imagine stretching a number line across a dark room and placing tiny light bulbs at each integer position. Now squint, and watch the light blur and interfere. What would you see?

It sounds like a thought experiment from a physics class, but a team of mathematicians and AI proof assistants has turned this question into a rigorous mathematical framework — and the results are startling. By treating finite sets of integers as optical diffraction gratings, they've uncovered a new algebraic structure that connects wave optics, prime numbers, and data compression. Every result has been machine-verified by a computer proof assistant, leaving no room for error.

## Young's Experiment, but with Integers

The story begins with the simplest possible experiment: light up just two numbers.

Place "photons" at positions 0 and 5 on the number line. In the diffraction framework, each number emits a wave: a spinning complex exponential e^{2πinθ}, where θ plays the role of the viewing angle. The two waves combine, and the resulting intensity pattern is:

**I(θ) = 2 + 2cos(10πθ)**

Anyone who has taken a physics class will recognize this: it's the formula for Young's double-slit experiment, the foundational demonstration of wave interference. The "fringe spacing" — the distance between bright bands — is determined entirely by the gap between the two numbers (5, in this case). Move both numbers by 100 positions? The fringes don't change. It's the gap that matters, not where you put the bulbs.

This deceptively simple observation turns out to be a theorem with profound implications. The research team formally proved it in Lean 4, a computer proof language: **the diffraction pattern of any integer set is invariant under translation.** The pattern sees only differences, never absolute positions.

## The Autocorrelation: A Number Set's Fingerprint

Here's where things get deep. The diffraction pattern of a set S turns out to be completely determined by a single function: the *autocorrelation*.

The autocorrelation c(d) counts how many pairs of elements in S differ by exactly d. For the set {0, 1, 3}:
- c(0) = 3 (three elements paired with themselves)
- c(1) = 1 (only 1-0)
- c(2) = 1 (only 3-1)  
- c(3) = 1 (only 3-0)

Every nonzero difference appears exactly once! This makes {0, 1, 3} a **Sidon set** — named after the Hungarian mathematician Simon Sidon who studied them in the 1930s. In diffraction terms, a Sidon set produces "white light": the intensity is spread as evenly as possible across all frequencies. No particular frequency is amplified.

Contrast this with {0, 1, 2, 3}, an arithmetic progression. Here c(1) = 3: the difference 1 appears three times (1-0, 2-1, 3-2). The autocorrelation is peaked, and the diffraction pattern acts like a *laser* — energy is concentrated at specific frequencies.

"Sidon sets are the anti-lasers of number theory," explains the research paper. "They refuse to amplify any particular pattern."

## Light Primes and Dark Primes

The research team then turned their attention to the prime numbers — and discovered a remarkable split.

Primes come in two flavors, based on their remainder when divided by 4. The *light primes* — 5, 13, 17, 29, 37, 41, ... — leave remainder 1. The *dark primes* — 3, 7, 11, 19, 23, 31, ... — leave remainder 3. (The number 2 is the unique "twilight prime," belonging to neither camp.)

This isn't just a naming convention. The light primes have a special property that dates back to Fermat: each one can be written as a sum of two squares. We can write 5 = 1² + 2², 13 = 2² + 3², and so on. Dark primes cannot.

The reason is algebraic. In the Gaussian integers ℤ[i] — numbers of the form a + bi, where i = √(-1) — light primes *split* into two conjugate factors: 5 = (2+i)(2-i). Each factor is a "photon" in the number-theoretic sense. Dark primes stay whole — they are inert, opaque, *dark*.

When the team computed the diffraction fingerprints of small prime sets, the results were striking:

The first four **light primes** {5, 13, 17, 29} had nearly flat autocorrelation — only one repeated difference. They behaved almost like a Sidon set, spreading their interference energy uniformly.

The first four **dark primes** {3, 7, 11, 19} were different. They had two repeated differences, producing a more peaked, coherent diffraction pattern — more like a laser than white light.

## The Light Primes Hypothesis

Based on these observations, the team proposes what they call the **Light Primes Hypothesis**:

> The primes p ≡ 1 (mod 4) produce diffraction patterns that are asymptotically flatter than those of primes p ≡ 3 (mod 4). This flatness — a consequence of their splitting in the Gaussian integers — is the algebraic source of compressive structure in number theory.

In plain English: light primes are nature's best spreaders of additive information. Because they split into conjugate pairs in ℤ[i], their differences are distributed more uniformly, making their diffraction patterns flatter and their structure harder to compress — but paradoxically, it is this very property that makes them useful for *compressing other things*.

The connection to data compression is real. A set with a spiked diffraction pattern (lots of repeated differences) has strong additive structure — think arithmetic progressions. Such structure is compressible. A set with a flat pattern (Sidon-like) is maximally incompressible. The light primes sit at the sweet spot: structured enough to be useful, random enough to avoid redundancy.

## The Phase Problem

The team also proved a beautiful symmetry theorem: **a set and its mirror image produce identical diffraction patterns.** You cannot tell {1, 3, 7} apart from {-7, -3, -1} by their fringes alone.

This is the mathematical heart of one of the great unsolved problems in structural science: the *crystallographic phase problem*. When X-rays diffract off a crystal, scientists can measure the intensity |F(θ)|² — but not the complex amplitude F(θ) itself. The lost phase information means the crystal structure cannot be uniquely reconstructed from diffraction data alone.

The integers, it turns out, have exactly the same problem. Two different sets with the same autocorrelation — called *homometric* sets — produce identical diffraction. The research team proved that homometricity is a genuine equivalence relation and that homometric sets always have the same size.

## Machine-Verified Truth

What makes this work unusual in mathematics is the level of certainty. Every theorem — all 26 of them — has been formally verified by the Lean 4 proof assistant. This isn't a matter of trusting a referee's judgment or a human mathematician's claim. The computer has checked every logical step, from axioms to conclusion.

"The oracle was consulted and concurs," the team writes, referring to their AI-powered theorem-proving assistant. In an age where mathematical papers can contain subtle errors that go undetected for years, machine verification provides an absolute guarantee.

## The New Algebra

What the team has built is more than a collection of theorems. It's a new algebraic framework — a *diffraction algebra* — where:

- **Objects** are finite sets of integers (gratings)
- **Morphisms** are translations, reflections, and dilations (optical symmetries)
- **The invariant** is the autocorrelation (the diffraction fingerprint)
- **Extremes** range from Sidon sets (white light) to arithmetic progressions (lasers)
- **The key question** is: what can the diffraction pattern tell us about the original set?

This framework bridges four fields that rarely talk to each other: wave optics, additive combinatorics, crystallography, and analytic number theory. The exponential sums that drive the Hardy-Littlewood circle method — the most powerful tool in additive number theory — are precisely the diffraction amplitudes of number sets. The major and minor arcs of the circle method are nothing but bright and dark fringes.

## What's Next

The team is now investigating whether the Light Primes Hypothesis connects to one of the deepest conjectures in mathematics: Montgomery's pair correlation conjecture, which predicts that the statistical spacing of prime numbers matches the spacing of eigenvalues of random matrices (the GUE distribution from quantum mechanics).

If true, the prime diffraction pattern would approach that of a random set — which is asymptotically Sidon. The light primes, being the "purer" half of the primes, might approach this limit faster.

For now, the 26 machine-verified theorems stand as a foundation. The numbers are shining, and their interference patterns are telling us something about the deepest structure of arithmetic. We just have to learn to read the fringes.

---

*The complete Lean 4 formalization, including all 26 machine-verified theorems, is available in the project repository.*
