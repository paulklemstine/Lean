# The Hidden Mathematics of Musical Harmony

## Why Can't Two Singers Move in Parallel to a Perfect Fifth?

For five centuries, music students have memorized a seemingly arbitrary rule: when writing counterpoint — the art of combining independent melodic lines — you must never approach a perfect fifth or octave by "parallel" or "similar" motion, where both voices move in the same direction. You can approach a third or a sixth however you like, but fifths and octaves? Only by contrary motion (voices moving in opposite directions) or oblique motion (one voice holding still).

Generations of composers from Palestrina to Bach obeyed this rule. But *why*? Music theorists have offered acoustic explanations, aesthetic arguments, and appeals to tradition. What no one had done — until now — was reveal the precise mathematical structure that these rules create.

It turns out that the rules of counterpoint define a remarkably elegant algebraic object: a directed graph with a stunning structural property. And that property connects music theory to abstract algebra, combinatorics, and even a miniature version of Ramsey theory.

## Six Magic Numbers

In Western music, pitch is organized into 12 semitones per octave. When two voices sound simultaneously, they create a "vertical interval" measured in semitones. But not all intervals are created equal. In the tradition codified by Johann Joseph Fux in his 1725 treatise *Gradus ad Parnassum*, only six intervals are considered consonant in two-voice first-species counterpoint:

- **Unison** (0 semitones) — perfect consonance
- **Minor third** (3 semitones) — imperfect consonance
- **Major third** (4 semitones) — imperfect consonance
- **Perfect fifth** (7 semitones) — perfect consonance
- **Minor sixth** (8 semitones) — imperfect consonance
- **Major sixth** (9 semitones) — imperfect consonance

These six numbers — 0, 3, 4, 7, 8, 9 — are the vertices of our graph. And the classification into "perfect" (0 and 7) and "imperfect" (3, 4, 8, 9) is the key to everything that follows.

## The Perfect Fourth Anomaly

Here is the first surprise. In everyday music theory, the perfect fourth (5 semitones) is considered consonant. It sounds just as "pure" as a perfect fifth. In fact, it IS the complement of the fifth: if you invert a fifth (going down instead of up within an octave), you get a fourth. Their semitone values sum to 12: 7 + 5 = 12.

Yet in two-voice counterpoint, the fourth is treated as *dissonant*. This breaks a symmetry you might expect: that if an interval is consonant, its complement should be too.

The mathematics confirms this asymmetry is real and irreducible. The imperfect consonances *do* pair up nicely under complementation: minor third (3) pairs with major sixth (9), major third (4) pairs with minor sixth (8). Each pair sums to 12. But the perfect fifth's complement, the perfect fourth, falls outside the consonant set entirely.

This is not a bug in the theory — it's a feature. The perfect fourth's exclusion is what gives the system its distinctive asymmetric structure.

## Target-Only Dependence: A Surprising Discovery

Now for the central discovery. When two voices move from one consonant interval to another, there are four types of motion: parallel (both move the same amount), similar (same direction, different amounts), contrary (opposite directions), and oblique (one holds still).

The rules say: you can approach an imperfect consonance (third or sixth) by *any* of the four motion types. But you can approach a perfect consonance (unison or fifth) only by contrary or oblique motion. Parallel and similar motion to perfect consonances are forbidden.

Here is what's remarkable: **the set of allowed motions depends only on the target interval's classification, not on where you're coming from.** Whether you're approaching a fifth from a third, a sixth, a unison, or another fifth, the allowed motions are always the same two: contrary and oblique. And whether you're approaching a third from anywhere at all, all four motions are allowed.

In mathematical language, the "hom-set" (the set of valid transitions) is completely determined by the target. The source is irrelevant. This is an extraordinarily strong structural property — it means the counterpoint category has a "fiber structure" over the two-element set {perfect, imperfect}.

## The Numbers Tell a Story

This target-only dependence leads to precise arithmetic:

- **Receptivity of perfect consonances**: 2 (out of 4 motion types)
- **Receptivity of imperfect consonances**: 4 (all motion types)
- **Total receptivity**: 2×2 + 4×4 = 20 (out of 24 maximum)
- **Restriction factor**: 20/24 = 5/6

So counterpoint rules block exactly 1/6 of all possible motions. That single fraction — 5/6 — captures the entire "tightness" of first-species counterpoint rules.

When we count labeled transitions (specifying source, target, and motion type), there are 6 × 6 × 4 = 144 possibilities. Exactly 120 are valid, and 24 are forbidden. The formula is clean: 6 sources × (4 imperfect targets × 4 motions + 2 perfect targets × 2 motions) = 6 × 20 = 120.

## The Complete Graph and the Ramsey Property

Despite all these restrictions on *how* you move between intervals, the transition graph on *which* intervals can follow which is **complete**: every consonant interval can follow every other. This is because contrary and oblique motion are always available. The rules restrict the path you take, not the destination you can reach.

This has a beautiful consequence for counterpoint sequences. The number of valid first-species counterpoint sequences of length *n* is exactly 6^*n* — the same as if there were no rules at all, because the constraint is on motion types, not on interval transitions.

Even more surprising is a Ramsey-theoretic property of the consonant intervals. Define two intervals as "adjacent" if their semitone values sum (mod 12) to another consonant interval. Then: **among any three distinct consonant intervals, at least one pair is adjacent.** There is no "dissonance triangle" — no three-element set where every pair sums to a dissonance. This is a miniature Ramsey theorem hiding inside music theory.

## The Rigidity of Consonance

The consonant interval set {0, 3, 4, 7, 8, 9} has another remarkable property: it is *rigid* under transposition. The only value you can add to every element (mod 12) and still land entirely within the consonant set is zero. No nonzero transposition preserves consonance.

This means the consonant intervals are, in a precise algebraic sense, "maximally asymmetric" within the 12-tone universe. They cannot be mapped onto themselves by any nontrivial symmetry of the chromatic scale.

Yet the complement involution — swapping minor thirds with major sixths and major thirds with minor sixths — *is* a symmetry, and its fixed points are exactly the perfect consonances. The dichotomy between perfect and imperfect consonances is not just a musical convention; it's a mathematical invariant of the consonance set.

## Consonances Don't Add Up

One final theorem reveals why harmony can never be "simple." The consonant intervals are *not* closed under addition mod 12. A minor third plus a minor third gives 6 semitones — the tritone, traditionally called "the devil in music," the most dissonant interval. A perfect fifth plus a perfect fifth gives 2 semitones, a major second, also dissonant. Out of 36 ordered pairs, only 23 sum to another consonance.

This non-closure is the mathematical reason why harmonic analysis is hard: you cannot stay within the world of consonances just by stacking them. Dissonance inevitably emerges from consonance, and the composer's art lies in managing this emergence.

## A Bridge Between Worlds

What began as a question about music pedagogy — why can't you write parallel fifths? — has revealed connections to:

- **Category theory**: The voice leadings form a category with a fiber structure over {perfect, imperfect}
- **Order theory**: The consonant intervals form a complete directed graph (total preorder)
- **Combinatorics**: Exact counting of valid transitions yields the restriction factor 5/6
- **Ramsey theory**: The consonance adjacency graph has no 3-element independent set
- **Abstract algebra**: The consonance set has trivial stabilizer and is not a subgroup

These connections are not metaphors. They are precise mathematical theorems, each proved with complete rigor. The rules that Fux wrote down three centuries ago, that every music student memorizes, encode a mathematical structure of unexpected depth and beauty.

The next time you hear a Bach fugue, listen for the moment when two voices approach a perfect fifth. Notice how they always arrive from opposite directions, never traveling in parallel. It's not just a rule — it's a theorem.

---

*This research builds on the theory of Pythagorean harmonic ratios and voice leading cost functions, extending static consonance analysis to the dynamic category of permitted transitions.*
