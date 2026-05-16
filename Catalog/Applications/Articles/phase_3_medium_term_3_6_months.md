# When Music Meets Information Theory: The Hidden Mathematics of Chord Progressions

## The Composer's Dilemma

Imagine you are a composer working on a film score. The director wants a lush orchestral arrangement, but the budget allows only three instruments. How do you choose which notes to keep and which to sacrifice? Every musician who has ever arranged a symphony for guitar knows this problem intuitively: you must compress the harmonic information while preserving what matters most.

It turns out this everyday musical challenge is, at its mathematical core, the same problem that engineers face when compressing digital images, that neuroscientists encounter when modeling how brains process sensory data, and that climate scientists grapple with when reducing terabytes of atmospheric simulations to manageable summaries.

The connection is not merely a loose analogy. A team of mathematicians has now proved — with absolute mathematical certainty — that the centuries-old art of voice-leading (the craft of moving smoothly between chords) obeys the same precise laws as Claude Shannon's 1959 theory of lossy data compression. The result opens a startling new window onto the deep geometry shared by music, information, and optimization.

## Shannon's Beautiful Tradeoff

In 1948, Claude Shannon invented information theory and changed the world. His key insight: every communication channel has a maximum rate at which information can be reliably transmitted. Exceed that rate, and errors become inevitable.

A decade later, Shannon tackled a subtler problem. What if you don't need perfect reproduction? When you compress a photograph, some loss of detail is acceptable. The question becomes: how much information must you transmit to keep the distortion below a given threshold?

Shannon's answer was a function called R(D) — the rate-distortion function. For any acceptable distortion level D, R(D) tells you the minimum number of bits per symbol required. Below R(D), faithful-enough reproduction is impossible. Above it, you're wasting bandwidth.

For nearly seven decades, R(D) has been the cornerstone of data compression theory. JPEG images, MP3 audio, streaming video — all operate near their respective rate-distortion limits. But R(D) was always studied for signals: sequences of numbers, pixels, samples.

What about structures that aren't signals at all — like musical chords?

## The Geometry of Smooth Motion

Musicians have known for centuries that some chord transitions sound smooth while others sound jarring. When a C major chord (C-E-G) moves to an F major chord (F-A-C), the smoothest path has each voice move by the smallest possible amount: C stays on C, E drops to C and rises to F, G rises to A. Wait — that can't be right. Actually, voice-leading is more subtle: you assign each note in the first chord to a note in the second chord, and the "cost" is the total distance all voices travel.

This is, mathematically, an assignment problem. Given two collections of pitches, find the matching that minimizes total displacement. The minimum cost defines a distance between chords.

In 2006, the music theorist Dmitri Tymoczko showed that voice-leading distances organize chords into a beautiful geometric space — a kind of musical landscape where nearby points are smoothly connected chords and faraway points are jarring jumps.

But Tymoczko's geometry was informal. No one had proved that it satisfies the precise axioms of a mathematical distance function. The new work does exactly this. The researchers proved that voice-leading cost satisfies the triangle inequality: the cost of going from chord A to chord C directly is never more than the cost of going from A to B and then B to C. This seemingly obvious fact requires a careful proof involving permutation composition and absolute value estimates.

With the triangle inequality in hand, voice-leading distances form what mathematicians call a Lawvere metric space — a categorical structure invented by the logician William Lawvere in 1973 to unify the concepts of distance, order, and logical implication. Music, it turns out, lives naturally in Lawvere's abstract framework.

## The Bridge Theorem

Now comes the surprise.

The researchers proved that any finite collection of chords, equipped with a probability distribution and voice-leading distance, automatically generates a well-defined rate-distortion problem. This means Shannon's compression theory applies directly to music.

Think of it this way. Suppose you have a repertoire of 100 chord voicings used in a particular musical style, and you know how frequently each one appears. Now suppose you want to "compress" this repertoire to a smaller set of prototype chords — perhaps just 10 — while minimizing the average voice-leading distance from each original chord to its nearest prototype.

How much information about the original chord must you retain? The rate-distortion function R(D) gives the exact answer. And the researchers proved that R(D) is not merely well-defined but actually *attained*: there exists an optimal compression scheme that achieves the theoretical minimum.

This existence theorem is deeper than it sounds. It relies on a topological argument: the space of all possible compression schemes (stochastic channels) is compact (roughly, it has no "edges" where things fall off), and the information measure is continuous, so the minimum must be achieved somewhere. The researchers formalized this entire argument with machine-checked mathematical certainty.

## The Tropical Connection

The most unexpected part of the story involves tropical mathematics — a branch of algebra where addition is replaced by taking the minimum and multiplication is replaced by ordinary addition. This "min-plus" arithmetic sounds strange, but it arises naturally in optimization, scheduling, and computational geometry.

The researchers proved that the rate-distortion function R(D) has a hidden tropical structure. Specifically, R(D) is bounded below by a family of affine functions — straight lines in the (D, R) plane — indexed by a Lagrange multiplier. The supremum of these affine functions forms a "tropical envelope" of R(D).

Why does this matter? Because it turns R(D) from an abstract optimization problem into a concrete, computable object. Instead of searching over all possible compression schemes (an infinite-dimensional optimization), you can sweep through a one-parameter family of Lagrange multipliers and read off R(D) from their envelope. This is exactly what the Blahut-Arimoto algorithm does in practice, and the tropical perspective explains *why* it works.

The connection to tropical geometry runs deeper. Under a sign change, the supremum of affine functions becomes a minimum of affine functions — precisely a tropical polynomial. The rate-distortion curve is, in disguise, a tropical hypersurface. This suggests that the entire apparatus of tropical algebraic geometry — Newton polytopes, tropical varieties, Maslov dequantization — might have information-theoretic meaning.

## A New Kind of Distance

One of the key mathematical contributions is the joint convexity of the Kullback-Leibler divergence — a fundamental measure of the "distance" between probability distributions. The researchers proved that if you mix two pairs of distributions, the KL divergence of the mixture is at most the weighted average of the individual divergences.

This fact, known informally for decades, had never been formally verified with machine-checked certainty for the finite discrete case. The proof uses the convexity of the function x·log(x) and a clever application of Jensen's inequality via weighted averages.

The joint convexity of KL divergence is the engine that drives the convexity of the rate-distortion function, which in turn guarantees that the Blahut-Arimoto algorithm converges to the global optimum. It is a single mathematical fact with cascading consequences across information theory, statistics, and machine learning.

## What It All Means

The bridge between music theory, information theory, and tropical geometry is more than a curiosity. It suggests a new way of thinking about structured data compression.

Traditional compression theory treats data as sequences of symbols. But music, language, images, and scientific data all have *structure* — relationships between parts that matter as much as the parts themselves. Voice-leading is a paradigm case: the "meaning" of a chord progression lies not in the individual chords but in the smooth connections between them.

By formalizing voice-leading as a rate-distortion problem, the researchers have created a template for structured compression. The same framework could apply to:

- **Natural language processing**: compressing sentences while preserving semantic relationships
- **Molecular biology**: compressing protein structures while preserving functional motifs
- **Neural network compression**: reducing model size while preserving learned representations
- **Climate science**: compressing simulation data while preserving dynamical structure

In each case, the "voice-leading cost" would be replaced by a domain-specific distance that captures the relevant structure, and the rate-distortion theory would provide guaranteed bounds on how much compression is possible.

## The Road Ahead

The researchers have identified several concrete next steps. The most immediate is proving the full convexity of the rate-distortion function — establishing that R(D) is not just monotone but genuinely bowl-shaped, which would unlock the full power of convex optimization for computing it.

Further ahead lies the tantalizing possibility of a categorical adjunction between distortion systems and metric spaces — a precise mathematical sense in which information compression and geometric distance are "dual" to each other. If such an adjunction exists, it would realize a vision that goes back to Lawvere's 1973 paper: that logic, metric geometry, and enriched category theory are aspects of the same underlying structure.

For musicians, the practical implications are immediate: given any corpus of music with voice-leading annotations, one can now compute the theoretically optimal harmonic simplification at any desired level of fidelity. For mathematicians, the message is broader: the intuitions that composers have developed over centuries of practice encode genuine mathematical structure, and that structure connects to some of the deepest ideas in modern mathematics.

The boundary between art and mathematics has always been more porous than either side acknowledges. This work makes that boundary a little more transparent — and finds, on both sides, the same beautiful geometry.
