# When Music Meets Information Theory: The Hidden Mathematics of Moving Between Chords

## The Art of Smooth Transitions

Every musician knows the feeling: you're playing a C major chord, and you need to get to an F major chord. Your fingers could leap wildly across the keyboard — or they could glide, each finger moving the minimum distance to its new position. The second approach sounds better. It's smoother, more connected, more *musical*.

This principle — that the best chord transitions minimize total finger movement — has been the unspoken law of Western harmony for centuries. Bach followed it. Beethoven followed it. Every competent music student learns it. But here's what nobody realized until recently: this simple musical rule is actually a deep mathematical theorem in disguise, connecting three fields that were never supposed to talk to each other.

The mathematics of smooth chord transitions turns out to be identical to the mathematics of data compression and the mathematics of abstract distance.

## Compression, Distortion, and the Art of Forgetting

In 1959, Claude Shannon — the father of information theory — solved one of the most elegant problems in mathematics. Imagine you have a noisy photograph, and you need to transmit it over a limited channel. You can't send every pixel perfectly; you have to accept some distortion. Shannon's question was: *what is the minimum amount of information you need to transmit so that the received image is within a given level of distortion from the original?*

The answer is called the *rate-distortion function*, R(D). It's a curve that tells you the fundamental tradeoff between quality and compression. At D = 0 (no distortion allowed), you need to transmit everything. As D grows (you tolerate more distortion), you can compress more aggressively. The curve R(D) descends gracefully from the source entropy down to zero.

For sixty years, this was a theorem about data. About JPEG compression, about video streaming, about lossy audio codecs. Nobody thought to ask: what if the "data" is a chord, and the "distortion" is how badly you butcher the voice-leading?

## Chords as Data Points, Voice-Leading as Distortion

Consider a repertoire of chords — say, the four chords that dominate a pop song: C major, A minor, F major, G major. Each chord is a collection of three pitches. A voice-leading between two chords is an assignment: soprano goes from this note to that note, alto goes from here to there, and so on. The *cost* of a voice-leading is the total displacement — how far the voices have to move, measured in semitones.

Now suppose these chords appear in a song with certain frequencies: C major appears 40% of the time, and the others each appear 20% of the time. If you wanted to simplify this harmonic language — reduce four chord types to two, say — which two chords should you keep? And how much voice-leading distortion do you incur?

This is *exactly* Shannon's rate-distortion problem. The source is the distribution over chords. The reproduction alphabet is the set of prototypes. The distortion measure is voice-leading distance. And R(D) tells you: for a given budget of harmonic simplification, what is the minimum amount of harmonic information you must preserve?

## A Triangle Inequality Written in Counterpoint

The key mathematical insight — and the one that makes the whole bridge work — is that voice-leading distance satisfies a *triangle inequality*. If you're going from a C major chord to a G major chord, the direct voice-leading is never more expensive than going through an intermediate chord:

> d(C, G) ≤ d(C, F) + d(F, G)

This is not obvious. It required a careful proof using the absolute value triangle inequality and a reindexing argument over permutations. But once you have it, voice-leading distance becomes what mathematicians call a *metric*, and specifically a *Lawvere metric* — a concept from category theory that generalizes distance to settings where symmetry may fail.

The triangle inequality isn't just an abstract nicety. It guarantees that the voice-leading distance matrix is *consistent*: shortest paths through intermediate chords never beat direct paths. It means you can do optimization, search for nearest neighbors, and build efficient algorithms — all with mathematical guarantees.

## The Existence Theorem: Optimal Compression Always Exists

Here's the central theorem, and it's a surprising one. Take any finite collection of voicings — triads, seventh chords, jazz voicings, Messiaen chords, anything — with any probability distribution over them. Take any finite set of prototypes. Define distortion as voice-leading distance. Then:

**For any feasible distortion level D, there exists an optimal compression scheme that minimizes the rate while staying within the distortion budget.**

The minimizer *exists*. It's not just an infimum that's never achieved; it's an actual minimum. You can, in principle, compute it. This is because the space of all possible compression schemes (stochastic channels from source chords to prototypes) forms a compact set in a finite-dimensional space, and the mutual information is a continuous function on this set. The extreme value theorem does the rest.

This means harmonic reduction isn't just an art — it has a mathematically optimal solution.

## The R(D) Curve: A Fingerprint of Musical Style

Different musical styles produce different R(D) curves. A composer who uses all chords equally (maximum entropy) has a high R(0) — you need many bits to describe the harmonic language faithfully. A minimalist who cycles between two chords has a low R(0) — the harmonic language is inherently simple.

But the shape of R(D) reveals more than just complexity. The *slope* of R(D) at different distortion levels tells you about the harmonic structure at different scales. A steep drop at low distortion means the chord vocabulary has clusters — groups of similar chords that can be merged cheaply. A gradual descent means the chords are spread out, each one distinctive.

When you compute R(D) curves for different musical styles — classical, pop, jazz, minimalist — you get visually distinct fingerprints. The curves cross each other, diverge, converge. Each crossing point corresponds to a distortion level at which two styles trade roles: below that level, one style needs more information to describe; above it, the other does.

## Tropical Geometry: The Crystal Structure of Compression

There's one more mathematical surprise hiding in this theory. The rate-distortion function R(D) is not just any curve — it's *convex*, which means it's the upper envelope of a family of straight lines. Each line corresponds to a particular trade-off parameter, and R(D) is the *supremum* (maximum) over all these lines.

In the language of tropical mathematics — where addition is replaced by taking maximums, and multiplication is replaced by addition — R(D) is a *tropical polynomial*. This connects harmonic compression to a branch of algebraic geometry that was developed for completely different reasons (studying degenerations of algebraic varieties, solving optimization problems, understanding the geometry of the reals).

The tropical perspective gives a certified lower bound on R(D): the *min-plus rate-distortion bound*, which states that R(D) ≥ H∞ - D, where H∞ is the min-entropy of the source distribution. This bound is computationally trivial to evaluate and provides a useful baseline for any compression scheme.

## What This Means: From Bach to Machine Learning

The unification of voice-leading, rate-distortion theory, and Lawvere metric spaces isn't just a mathematical curiosity. It opens concrete doors:

**For music theory**: Harmonic reduction — the process of simplifying a complex score to its structural skeleton — can now be formulated as a precise optimization problem with guaranteed solutions. The question "what are the essential harmonies in this piece?" has a mathematical answer, parameterized by how much simplification you're willing to tolerate.

**For music information retrieval**: Different musical styles can be compared quantitatively through their R(D) curves. This provides a principled, theory-grounded alternative to ad hoc similarity measures.

**For machine learning**: The voice-leading metric space provides a structured, mathematically certified distance for chord embeddings. Unlike arbitrary learned distances, this one satisfies the triangle inequality and has a clear musical interpretation. It could serve as an inductive bias for generative models of harmony.

**For information theory**: Music provides a rich, finite, concrete testbed for rate-distortion theory — a domain where you can literally hear the effect of compression. This is rarer than you might think.

**For mathematics**: The bridge between enriched category theory (Lawvere metrics) and information theory (rate-distortion) via a concrete musical domain suggests that similar bridges exist in other domains where structured transformations carry costs — robotics, linguistics, molecular biology.

## The Bigger Picture

What we've discovered is that compression, geometry, and musical transformation are the same object viewed from three sides. Shannon's theory tells us about the information-theoretic limit. Lawvere's theory tells us about the categorical structure. And voice-leading tells us about the concrete human experience.

The fact that these three perspectives converge on the same mathematics isn't an accident. It's a hint that there's a deeper unity lurking beneath the surface — a unified theory of structured compression that applies whenever you have objects, transformations between them, and costs for those transformations. Music is just the first place where we can see all three sides at once.

Bach didn't know about information theory. Shannon didn't think about counterpoint. Lawvere wasn't writing fugues. But the mathematics they each discovered — independently, for completely different reasons — turns out to be the same mathematics. And that, perhaps, is the deepest harmony of all.
