# When Music Meets Compression: The Hidden Geometry of Chords

## The Puzzle of the Shortest Path Between Two Chords

Imagine you're sitting at a piano, your fingers resting on a C major chord — C, E, G. Now you want to move to an F major chord — F, A, C. How should your fingers travel?

A pianist knows instinctively: move each finger the smallest possible distance. The C stays (or goes up to the new C), the E slides up to F, the G reaches up to A. This "voice leading" — the art of connecting chords through minimal motion — has been the backbone of Western harmony for five centuries, from Palestrina to the Beatles.

But here's the surprise: this musical instinct is actually a deep mathematical principle. And it connects, through an unexpected chain of ideas, to one of the most powerful theories in modern engineering — the mathematics of lossy data compression.

## The Compression Problem You Didn't Know You Had

Every time you stream a song, make a video call, or send a photo, your device performs a small miracle: it throws away most of the data while keeping what matters. A three-minute song at CD quality contains about 30 megabytes of information, but a streaming service sends you perhaps 3 megabytes. The missing 90% isn't random — it's the parts your ears won't notice.

This is lossy compression, and it's governed by a beautiful mathematical framework called rate-distortion theory, developed by Claude Shannon in the 1950s. Shannon showed that for any source of information, there exists a fundamental trade-off curve — called R(D) — that tells you exactly how many bits per symbol you need if you're willing to tolerate a given level of distortion D.

Below this curve, compression is impossible. Above it, it's achievable. The curve itself is the boundary of the possible.

What nobody expected is that this same mathematical structure would appear in music theory.

## Voice Leading as Optimal Transport

The key insight begins with a reconceptualization of what a chord really is. Instead of thinking of a chord as a static object — a set of pitches — think of it as a point in a high-dimensional space. A three-voice chord lives in a three-dimensional integer lattice, where each axis represents the pitch of one voice.

Now voice leading becomes geometry: moving from one chord to another is tracing a path through this space. The "cost" of a voice leading — the total distance your fingers travel — is literally a distance in this mathematical space.

But there's a subtlety. Voices can be reassigned: the soprano note doesn't have to stay in the soprano. You might achieve a smoother voice leading by crossing voices, letting the soprano descend below the alto. So the true "distance" between two chords isn't just the sum of pitch movements — it's the *minimum* such sum over all possible voice assignments. Mathematically, this is an optimal transport problem: you're finding the cheapest way to ship pitch material from one chord to another.

This observation, long known to music theorists, turns out to be the tip of a much larger iceberg.

## The Triangle Inequality: When Math Confirms Musical Intuition

One of the foundational results in the new theory is almost embarrassingly simple to state: the optimal voice-leading distance satisfies the triangle inequality. If you want to go from chord A to chord C, you can never do better than the total cost of going from A to B and then from B to C.

In mathematical terms, the space of all n-voice chords, equipped with optimal voice-leading distance, is a genuine metric space — a Lawvere metric space, to use the categorical term. This means it has all the geometric structure you'd want: distances are symmetric, the distance from any chord to itself is zero, and detours never help.

This isn't just a mathematical curiosity. It means voice-leading distances can be computed, compared, and optimized with all the tools of metric geometry. And it opens the door to the rate-distortion connection.

## The Bridge: Compressing a Musical Vocabulary

Here's where the two stories merge. Imagine a composer working with a vocabulary of six chords — say, the triads C, Dm, Em, F, G, Am that form the backbone of countless pop songs. Each chord appears with some frequency: C and G are common (they're the tonic and dominant), while Em and Am appear less often.

Now suppose you want to compress this harmonic vocabulary. You're writing a simplified arrangement — maybe for a beginning pianist — and you can only use three distinct chords. Which three should you choose, and which original chords should be mapped to which simplified chord?

This is exactly a rate-distortion problem. The "source" is the original chord vocabulary with its frequency distribution. The "distortion" is the voice-leading cost of replacing one chord with another. The "rate" is the logarithm of how many distinct chords you use.

The rate-distortion function R(D) tells you the fundamental limit: for a given average voice-leading distortion D, what is the minimum number of bits (distinct symbols) you need?

## A Tropical Geometry of Sound

The mathematical structure of R(D) reveals something remarkable: it has the geometry of tropical mathematics — a world where addition is replaced by taking minimums and multiplication is replaced by addition. In this tropical world, the rate-distortion curve is built from straight-line segments, each representing a different compression regime.

At low distortion (high fidelity), you need nearly all your original chords. As you allow more distortion, chords that are close together in voice-leading space begin to merge. The transitions between these regimes — the "corners" of the R(D) curve — correspond to changes in the optimal compression strategy.

Through Lagrangian duality, each tangent line to R(D) corresponds to a specific tradeoff parameter. The entire curve is the supremum of these affine functions — a tropical polynomial in the distortion variable. This means R(D) is not just a theoretical limit but a computationally tractable object, computable exactly for finite chord vocabularies.

## What the Numbers Say

For a typical pop/rock triad vocabulary ({C, Dm, Em, F, G, Am} with weights reflecting tonal music norms), the rate-distortion curve tells a vivid story:

- At zero distortion, you need about 2.46 bits per chord (the full entropy of the vocabulary).
- At 2 semitones average distortion, you need only about 1.1 bits — roughly half the information.
- At 5 semitones distortion, just 0.37 bits suffice — you're essentially down to two effective chords.
- At 10 semitones, the rate drops to near zero — a single chord can represent everything.

These numbers have musical meaning. A distortion of 2 semitones is roughly the difference between C major and D minor — a gentle harmonic substitution. A distortion of 5 semitones is more like replacing C major with F major — a bigger but still recognizable change. The R(D) curve quantifies exactly how these substitutions trade off against information content.

## A New Lens on Musical Style

Different musical styles have different harmonic vocabularies and different chord frequency distributions. A classical sonata emphasizes I-IV-V progressions; a jazz standard uses more varied harmony with seventh chords and substitutions; a minimalist piece might use just two or three chords.

Each style produces its own R(D) curve — a "fingerprint" of its harmonic structure. Styles with rich, spread-out harmonic vocabularies have steep R(D) curves (you need many bits to capture the variety). Styles with concentrated vocabulary have flatter curves (compression is easier because there's less variety to preserve).

This opens a quantitative approach to questions that music theorists have long discussed qualitatively: How harmonically complex is a given style? How much information does a chord progression actually carry? What is lost when a complex piece is simplified?

## The Bigger Picture

The connection between voice leading and rate-distortion theory is not an accident. It reflects a deep structural principle: **distortion, in the information-theoretic sense, is a generalization of distance in the geometric sense.**

When Shannon defined distortion as the expected cost of replacing a source symbol with a reproduction symbol, he was implicitly defining a transport problem. The rate-distortion function is the solution to this transport problem under an information-rate constraint. Voice-leading cost is a natural transport cost on the space of chords.

This perspective suggests a much broader program. Any domain with a natural notion of distance — molecular configurations in chemistry, circuit designs in engineering, protein structures in biology — should admit a rate-distortion theory. The fundamental question is always the same: how much information do you need to preserve a given level of structural fidelity?

## From Art to Algorithm

The mathematical framework doesn't just provide theoretical insights — it gives practical algorithms. The Blahut-Arimoto algorithm, a workhorse of information theory since the 1970s, can compute R(D) curves for any finite distortion system. Applied to voice-leading distortion, it produces exact rate-distortion curves for chord vocabularies of any size.

These algorithms could find applications in automatic music arrangement (finding optimal simplifications of complex harmonies), music information retrieval (comparing harmonic styles quantitatively), and generative music systems (sampling from rate-distortion optimal distributions to produce harmonically coherent sequences at a desired complexity level).

## What This Means

Mathematics has a remarkable capacity to reveal hidden connections between apparently unrelated domains. The link between musical voice leading and data compression theory is a striking example.

At its core, the message is simple but profound: **the art of smooth harmonic movement and the science of efficient information encoding are governed by the same mathematical laws.** The pianist's instinct for minimal motion and the engineer's algorithm for optimal compression are two expressions of a single underlying principle — the geometry of structured distortion.

This is not the end of a story but the beginning. The tropical geometry of R(D) curves, the categorical structure of voice-leading as a Lawvere metric space, the functorial bridge between musical transformation and information theory — these are the first chapters of a much larger mathematical narrative, one that promises to unite geometry, algebra, and information in ways we are only beginning to understand.
