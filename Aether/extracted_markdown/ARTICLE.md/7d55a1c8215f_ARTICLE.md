# The Hidden Geometry of Musical Rules: When Bach Meets Abstract Algebra

*Why the rules your music teacher taught you are actually theorems in disguise*

---

## A Forbidden Motion

In 1725, the Austrian composer and theorist Johann Joseph Fux published *Gradus ad Parnassum* — "Steps to Parnassus" — a treatise on musical composition that would shape Western music for three centuries. Bach studied it. Mozart copied it out by hand. Beethoven used it to teach his own pupils. At the heart of this book lies a deceptively simple commandment: **thou shalt not move two voices in parallel to a perfect fifth or octave.**

Every music student learns this rule. Most accept it as an aesthetic preference, a stylistic convention inherited from the Renaissance. But what if it's something deeper? What if this rule — and the entire system of counterpoint it belongs to — is really a theorem about the geometry of musical intervals?

A new mathematical framework reveals that the answer is yes. By modeling counterpoint as a *directed graph* — a network of nodes and arrows — researchers have uncovered a rich algebraic structure hiding inside Fux's centuries-old rules. The results are surprising, precise, and beautiful.

## Intervals as Destinations

To understand the discovery, start with a simple idea: think of musical intervals not as sounds, but as *locations*. In Western music, there are twelve distinct pitch classes (the white and black keys within a single octave on a piano), so any interval between two voices can be described by a number from 0 to 11, counting the gap in semitones. The interval wraps around — just like a clock.

Not all intervals are created equal. Six of these twelve are considered **consonant** — they sound pleasing, stable, resolved. These are: the unison (0 semitones), the minor third (3), the major third (4), the perfect fifth (7), the minor sixth (8), and the major sixth (9). The other six — including the tritone (6), the major second (2), and the minor second (1) — are **dissonant**: tense, restless, demanding resolution.

Among the consonances, there's a further distinction. Two intervals are **perfect**: the unison (0) and the perfect fifth (7). The remaining four consonances — the thirds and sixths — are **imperfect**. This hierarchy is not arbitrary; it reflects the simplicity of the underlying frequency ratios. The perfect fifth corresponds to a frequency ratio of 3:2, one of the simplest ratios in nature. The thirds and sixths have more complex ratios (5:4, 6:5, 5:3, 8:5).

The key insight of the new framework is to treat these six consonant intervals as the **vertices** of a graph, and then ask: what are the legal *moves* between them?

## Voice Leadings as Arrows

When two voices move from one consonant interval to another, the motion is described by a **voice leading**: a pair of numbers specifying how many semitones the bass voice moves and how many semitones the soprano voice moves. If the bass drops by two semitones and the soprano rises by one, that's a voice leading of (−2, +1) — or equivalently, (10, 1) in our clock arithmetic modulo 12.

A voice leading is **permitted** if it satisfies the counterpoint rules: both the starting interval and the ending interval must be consonant, and if the ending interval is a *perfect* consonance, then the two voices must not move in parallel — that is, they can't both shift by the same amount.

The **Counterpoint Quiver** is the directed graph whose vertices are the six consonant intervals and whose arrows are all permitted voice leadings between them. Each arrow is labeled with the specific bass and soprano motions that produce it.

How many arrows does this graph have? The answer turns out to be illuminating.

## The Bottleneck of Perfection

The first major result is a precise count. Consider all the voice leadings arriving at a given consonant interval — every legal way to reach that destination from any consonant source.

For an **imperfect** consonance like the major third, there are exactly **72** incoming voice leadings. But for a **perfect** consonance like the perfect fifth, there are only **61** — a reduction of roughly 15%.

This asymmetry has a beautiful explanation. Look at the *self-loops*: voice leadings that start and end at the same interval. For an imperfect consonance, there are **12** self-loops — one for each possible parallel shift of both voices, plus every other kind of identical-source-and-target motion. But for a perfect consonance, there is exactly **1** self-loop: the identity, where neither voice moves at all.

Why? Because every non-trivial self-loop on a perfect consonance would be parallel motion into a perfect consonance — the one thing Fux forbids. The sole survivor is the identity: staying perfectly still.

This is the **bottleneck theorem**. Perfect consonances are harder to reach. They're scarcer destinations in the landscape of voice leadings. This scarcity is not a bug; it's a feature. It's what gives perfect consonances their gravitational weight in counterpoint. When you finally arrive at a perfect fifth, you feel it — because you had to work harder to get there.

## Everything Connects, But Nothing Composes

The second result is more surprising. Despite the bottleneck, the counterpoint quiver is **strongly connected**: between any two consonant intervals, at least one permitted voice leading exists. No interval is an island. You can always get from here to there.

The proof is elegant. For any two consonant intervals *i* and *j*, consider the **canonical voice leading**: the bass stays put, and the soprano moves by exactly *j − i* semitones. This motion is never parallel (since the bass doesn't move at all, while the soprano does — unless *i = j*, in which case the identity works). So the canonical voice leading is always permitted. Connectivity is guaranteed.

But here's the twist: even though individual voice leadings always exist, they **don't compose**. Take two perfectly legal moves and perform them in sequence, and the result may be illegal. Two permitted voice leadings can combine into a forbidden one.

This is the **non-composability theorem**, and it has a profound categorical interpretation. In mathematics, a *category* is a structure where you have objects, morphisms (arrows) between them, and the ability to compose morphisms. The counterpoint quiver has objects and morphisms — but composition fails. It is *not* a category. It's something looser: a quiver, a directed graph with no guarantee that paths compose to valid arrows.

This failure of composition is musically meaningful. It captures the fact that counterpoint is a *local* constraint system: each step must be legal, but legality is not transitive. A composer must check every beat, every transition, every moment independently. There are no shortcuts.

## The Asymmetry of Inversion

The fourth result formalizes something that every music student knows intuitively: **the bass voice is special**.

Consider the mathematical operation of *voice swapping*: take an interval *i* and replace it with *−i* (modulo 12). This is what happens when you exchange the roles of the soprano and bass. If the soprano was a perfect fifth above the bass, now the bass is a perfect fifth above the soprano — or equivalently, the soprano is a perfect *fourth* below.

Here's the key finding: this involution **does not preserve consonance**. The perfect fifth (7 semitones) maps to −7 ≡ 5 (mod 12), which is the *perfect fourth*. And the perfect fourth is not in our set of consonant intervals. It's dissonant in the context of first-species counterpoint.

This is not a mathematical accident. It reflects a deep asymmetry in tonal music: the bass voice defines the harmonic foundation. An interval that is consonant *above* the bass may be dissonant *below* it. The perfect fourth — that pillar of harmony when sounded between upper voices — becomes unstable and tense when the bass sits on top.

The mathematical formalization captures this asymmetry as a precise theorem: the function *i ↦ −i* on ℤ/12ℤ does not map the set {0, 3, 4, 7, 8, 9} into itself. The proof is a single computation: −7 = 5, and 5 ∉ {0, 3, 4, 7, 8, 9}.

## Beyond Twelve Tones

Perhaps the most exciting aspect of this framework is its generality. The mathematical structure — what the researchers call a **Counterpoint System** — is parameterized not just for the standard 12-tone equal temperament, but for *any* modular arithmetic. Want to study counterpoint in 19-tone equal temperament? In 31-tone? In an exotic microtonal system that divides the octave into 53 equal parts?

A Counterpoint System over ℤ/nℤ requires only four ingredients: a set of consonant intervals, a subset of perfect consonances, the rule that perfect consonances are consonant, and the rule that parallel motion into perfect consonances is forbidden. Given these axioms, the structural theorems — connectivity, non-composability, the bottleneck — can be investigated for any value of *n*.

This generalization suggests that the constraints of counterpoint are not just about the specific acoustics of Western music. They are about the *combinatorics of constraint*: what happens when you declare some destinations "special" and restrict how you can approach them. The resulting quiver, with its bottlenecks and connectivity and failure of composition, is a mathematical object that transcends any particular tuning system.

## A Bridge Between Worlds

This work sits at a remarkable crossroads. From one direction, it draws on **music theory** — the centuries-old tradition from Fux through Schenker to modern computational musicology. From another, it engages **order theory** and the study of partially ordered sets. From a third, it touches **category theory** — or rather, the fascinating boundary where categorical structure *almost* applies but ultimately fails.

The failure is the message. Counterpoint is not a category. It's something more nuanced, more constrained, more *musical*. The quiver of permitted voice leadings has just enough structure to be richly analyzable but too little to be tamed by the usual algebraic machinery. It's a mathematical object that demands its own theory.

And this theory, in turn, illuminates the music. When Bach avoided parallel fifths, he was — without knowing it — navigating a combinatorial bottleneck. When Palestrina resolved a sixth to a fifth, he was traversing an arrow in a directed graph. When Fux wrote down his rules, he was axiomatizing a constraint system whose structural properties would not be formally proved for another three centuries.

The rules of counterpoint are not arbitrary conventions. They are theorems — theorems about the geometry of consonance, the topology of voice leading, and the deep asymmetries that make music possible.

---

*The mathematical results described in this article formalize five principal theorems: the strong connectivity of the counterpoint quiver, the non-composability of permitted voice leadings, the bottleneck asymmetry between perfect and imperfect consonances (1 vs. 12 self-loops; 61 vs. 72 total incoming edges), the failure of voice-swap to preserve consonance, and the hom-set computations that quantify the 15% constraint imposed by perfection.*
