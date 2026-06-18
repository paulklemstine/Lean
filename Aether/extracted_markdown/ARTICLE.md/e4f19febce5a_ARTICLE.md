# The Secret Mathematics of Forbidden Fifths

**Why a 300-year-old rule of musical composition hides a deep mathematical structure — and what it tells us about the architecture of beauty.**

---

## The Rule Every Composer Learns First

In 1725, the Austrian theorist Johann Joseph Fux published *Gradus ad Parnassum* — "Steps to Parnassus" — a treatise on musical composition that would become the standard textbook for two centuries. Haydn studied it. Mozart studied it. Beethoven studied it. Its central lesson is deceptively simple: when two melodic lines move together, they must not arrive at a perfect fifth or an octave by moving in the same direction.

The rule is called the prohibition on *parallel fifths*, and generations of music students have memorized it, cursed it, and eventually internalized it. But almost no one has asked the deeper question: *what kind of mathematical object does this rule create?*

It turns out that when you take the six consonant intervals of classical counterpoint, connect them with every voice leading that Fux's rules permit, and study the resulting network, you discover something surprising. The structure has a precise, quantifiable asymmetry. Perfect consonances act as bottlenecks. The network is strongly connected but not freely navigable. And the constraints exhibit a beautiful rigidity that echoes through the entire space of possible musical textures.

This is the story of how counterpoint became a theorem.

---

## Six Intervals, Infinite Music

First, the basics. In the Western chromatic scale, there are twelve semitones in an octave. When two voices sing simultaneously, the distance between their pitches — measured in semitones — determines the *interval* between them. Some intervals sound stable and resolved; these are the *consonances*. Others sound tense and unstable; these are the *dissonances*.

Classical counterpoint recognizes exactly six consonant intervals (modulo the octave):

| Semitones | Name | Type |
|-----------|------|------|
| 0 | Unison / Octave | Perfect |
| 3 | Minor third | Imperfect |
| 4 | Major third | Imperfect |
| 7 | Perfect fifth | Perfect |
| 8 | Minor sixth | Imperfect |
| 9 | Major sixth | Imperfect |

The crucial distinction is between **perfect** consonances (unison and fifth) and **imperfect** ones (thirds and sixths). This isn't just an aesthetic classification — it's a structural fault line that shapes the entire theory.

---

## The Counterpoint Quiver

Imagine the six consonant intervals as cities on a map. A *voice leading* is a route between two cities: it specifies how much each voice — the bass and the soprano — moves to get from one interval to another.

For example, if two voices are a perfect fifth apart (7 semitones), and the bass rises by 2 semitones while the soprano rises by 3, the new interval is 7 + 3 − 2 = 8 semitones — a minor sixth. That's a valid move: a consonance led to a consonance, and since the target (minor sixth) is imperfect, the parallel-motion restriction doesn't apply.

But if both voices rise by 2 semitones from a major third (4 semitones), the new interval is still 4 + 2 − 2 = 4 — a major third. Both voices moved the same amount, but since the target is imperfect, this parallel motion is permitted. (Parallel thirds are a staple of folk music.)

Now try this: both voices rise by 2 semitones from a fifth (7 semitones). The new interval is 7 + 2 − 2 = 7 — still a perfect fifth. Both voices moved the same amount, arriving at a perfect consonance by parallel motion. *This is forbidden.* Fux's rule kicks in, and this edge is deleted from our map.

The resulting directed graph — what mathematicians call a *quiver* — is the **Counterpoint Quiver**. Its vertices are the six consonant intervals. Its edges are the permitted voice leadings. And its structure encodes the deep logic of Western polyphonic music.

---

## Every Destination Is Reachable

The first discovery is reassuring: the Counterpoint Quiver is **strongly connected**. From any consonant interval, you can reach any other consonant interval in a single permitted step. No interval is isolated. No consonance is a dead end.

This means that a composer working within Fux's rules always has options. No matter where the voices currently sit, there is at least one legal move to any desired destination. The proof is constructive: for any two consonant intervals *i* and *j*, you can always find a voice leading where the bass stays put and the soprano moves by exactly *j* − *i* semitones. Since only one voice moves, the motion isn't parallel, so it's never forbidden. When *i* = *j*, the identity (no motion at all) serves as a self-loop.

Music theorists have long known this intuitively — you can always "get there from here" — but the formal proof reveals *why*: the mere existence of contrary and oblique motion provides an escape from every possible position.

---

## The Bottleneck Theorem

Here the story gets interesting. While every consonant interval is reachable, they are not all equally accessible.

Consider self-loops: voice leadings that start and end at the same interval. A self-loop at an imperfect consonance like the minor third (3 semitones) can be achieved by *any* motion where bass and soprano move by the same relative amount — and there are 12 such motions in the chromatic scale (one for each transposition level). Even parallel motion is fine, because the target is imperfect.

But a self-loop at a perfect consonance like the perfect fifth is different. The only permitted self-loop is the *identity* — both voices staying still. Every other motion that preserves the interval would be parallel motion into a perfect consonance, which is forbidden. So where imperfect consonances enjoy 12 self-loops, perfect consonances are pinched down to exactly 1.

This is the **Bottleneck Theorem**: perfect consonances are categorically constrained. They admit a factor of 12 fewer self-loops than imperfect consonances. The mathematical structure doesn't just say "parallel fifths are forbidden" — it quantifies the *severity* of the restriction and reveals its structural signature.

---

## Composition Fails: The Non-Composability Theorem

Perhaps the most striking result is negative. In mathematics, a *category* is a collection of objects and morphisms (arrows between objects) that can be composed: if you have an arrow from A to B and another from B to C, their composition gives an arrow from A to C. Categories are the lingua franca of modern mathematics.

It would be elegant if permitted voice leadings formed a category — if chaining two legal moves always produced a legal move. But they don't.

The proof is by explicit counterexample. Consider two voice leadings, each individually permitted, whose composition produces parallel motion into a perfect fifth. The first move might approach a minor third by oblique motion (perfectly legal), and the second might approach a perfect fifth by oblique motion (also perfectly legal). But the net effect — the composition of the two — is parallel motion into a fifth, which is forbidden.

This **Non-Composability Theorem** has a deep musical interpretation: *counterpoint is fundamentally a local constraint*. You cannot determine the legality of a sequence of moves by checking each step in isolation. The interaction between successive moves creates emergent prohibitions. This is why counterpoint is hard to compose and hard to automate — the constraints are inherently non-compositional.

---

## The Bass Voice Is Special

There is one more asymmetry hiding in the structure. Consider the operation of *voice exchange*: swapping the bass and soprano, which maps each interval *i* to its complement −*i* (modulo 12). If consonance were a symmetric property — if it didn't matter which voice was on top — this operation would preserve the set of consonant intervals.

It doesn't.

The perfect fifth (7 semitones) maps to 12 − 7 = 5 semitones — the perfect fourth. And the perfect fourth is *not* consonant in first-species counterpoint. This is one of the most distinctive features of the Western musical system: the fourth is consonant when it's an upper interval (as in a 6/4 chord) but dissonant when it sits above the bass. Voice exchange breaks consonance.

Mathematically, the involution *i* ↦ −*i* on ℤ/12ℤ does not preserve the consonant set {0, 3, 4, 7, 8, 9}. The image of 7 is 5, and 5 is absent from the set. This **Voice-Swap Asymmetry** theorem formalizes the privileged role of the bass voice in counterpoint — a principle that music theorists have understood for centuries but never expressed in the language of modular arithmetic and set invariance.

---

## Counting the Constraints

The final result is a precise census. When you count all permitted voice leadings arriving at a perfect consonance from any consonant source, you find exactly 61. For an imperfect consonance, the count is 72. That's an 15% reduction — a quantitative measure of how much harder it is to approach a perfect consonance.

This number — 61 versus 72 — is not arbitrary. It emerges inevitably from the interplay of three mathematical facts: there are 12 possible transpositions, 6 consonant source intervals, and the parallel-motion restriction removes exactly one motion per perfect-consonance source pair. The arithmetic is elementary, but the musical consequence is profound: perfect consonances are compositional chokepoints, and the 15% tax on their accessibility shapes the statistical texture of all counterpoint written within these rules.

---

## Beyond Twelve Tones

The mathematical framework extends far beyond the familiar 12-note chromatic scale. By parameterizing the counterpoint system over ℤ/*n*ℤ for arbitrary *n*, the same structural theorems apply to microtonal systems: 19-tone equal temperament, 31-tone equal temperament, or any other division of the octave.

The key abstraction is the *CounterpointSystem*: a finite set of consonant intervals, a subset of "perfect" consonances, and the parallel-motion restriction. The connectivity theorem, the bottleneck theorem, and the non-composability theorem all hold at this level of generality, provided the system has at least one perfect and one imperfect consonance.

This suggests that the mathematical structure of counterpoint is not an accident of the 12-note system. It is a consequence of the *form* of the constraint — the prohibition on parallel motion into distinguished intervals — rather than the specific intervals chosen. Any musical system that draws a line between "perfect" and "imperfect" consonances and restricts parallel motion into the former will exhibit the same bottleneck, the same non-composability, and the same strong connectivity.

---

## Hearing the Theorems

The next time you listen to a Bach fugue or a Palestrina motet, pay attention to the moments where the voices converge on a perfect fifth or an octave. Notice how they approach obliquely — one voice moving while the other holds, or the voices moving in opposite directions. That careful avoidance of parallel motion is not just an aesthetic preference. It is a navigation through a precisely structured mathematical space, a space where perfect consonances are bottlenecks, where composition of moves is unreliable, and where the bass voice occupies a privileged, asymmetric position.

Three hundred years after Fux wrote his treatise, mathematics has finally caught up with what composers have always known by ear: the rules of counterpoint are not arbitrary. They are the signature of a deep, beautiful, and inevitably asymmetric structure — one that lives at the intersection of number theory, combinatorics, and the human perception of harmony.

The forbidden fifths were never just a rule. They were a theorem, waiting to be discovered.
