# The Secret Mathematics of Music: Why Parallel Fifths Are Forbidden

*How a 300-year-old composition rule reveals deep algebraic structure hiding in every Bach chorale*

---

## A Rule Every Musician Learns — and Nobody Fully Understood

If you've ever taken a music composition class, you know the rule. It's drilled into you with the ferocity of a military command: **never write parallel fifths**. Two voices singing a perfect fifth apart, then both moving up by the same amount to another perfect fifth? Absolutely forbidden. The same goes for parallel octaves, parallel unisons. Generations of composition students have lost points on homework assignments for this transgression.

The rule goes back to Johann Joseph Fux's 1725 treatise *Gradus ad Parnassum* — "Steps to Parnassus" — the single most influential textbook in the history of Western music. Beethoven studied from it. Mozart studied from it. Haydn taught from it. Its rules of "species counterpoint" governed how two or more melodic lines could weave together, and at the foundation of those rules sat this strange prohibition: you can move in parallel to an imperfect consonance (a third or a sixth), but you must *never* move in parallel to a perfect consonance (a fifth or an octave).

For three centuries, the explanation has been aesthetic. Parallel fifths sound "hollow." They erase the independence of voices. They collapse two melodic lines into one. All of this is true. But it turns out there is something deeper going on — something that can be stated with the precision of pure mathematics.

The parallel-fifths rule is not merely a stylistic preference. It is a *structural bottleneck* in the algebra of consonance.

---

## Consonance as a Map

To see why, we need to think about musical intervals the way a mathematician does. In the standard Western tuning system — twelve equally spaced notes per octave, the system that governs everything from piano keys to guitar frets — every interval between two notes can be described by a single number from 0 to 11, representing the distance in semitones modulo 12.

Not all intervals are created equal. Of the twelve possible intervals, only six are considered consonant in classical counterpoint:

| Interval | Semitones | Type |
|----------|-----------|------|
| Unison | 0 | Perfect |
| Minor third | 3 | Imperfect |
| Major third | 4 | Imperfect |
| Perfect fifth | 7 | Perfect |
| Minor sixth | 8 | Imperfect |
| Major sixth | 9 | Imperfect |

These six intervals are the *vertices* of our mathematical story. They're the legal states — the places where two voices are allowed to rest together. The dramatic question is: how can they *move*?

---

## The Voice-Leading Graph

Imagine two singers: a bass and a soprano. At any moment, they're singing notes some consonant interval apart. When they move to the next beat, each singer can shift up or down by any number of semitones. The combination of "how much the bass moves" and "how much the soprano moves" is called a *voice leading*.

A voice leading transforms one interval into another. If the soprano and bass are a perfect fifth apart, and the soprano goes up 2 semitones while the bass goes up 1, the interval changes from 5+2-1 = 6... wait, that's a tritone. That's dissonant. That voice leading would be forbidden.

The counterpoint system can be visualized as a directed graph — a network of arrows. The six consonant intervals are the nodes. An arrow from one interval to another exists for every voice leading that takes you between them *legally* — meaning the result is consonant, and you haven't committed the sin of parallel motion into a perfect consonance.

This graph has astonishing structure.

---

## The Connectivity Miracle

The first surprise: **the graph is strongly connected**. From any consonant interval, you can reach any other consonant interval in a single legal move. There are no dead ends, no isolated islands.

This is not obvious. The parallel-motion prohibition is a severe constraint. You might expect it to cut some connections entirely — perhaps making it impossible to reach a perfect fifth from a unison without going through intermediate intervals. But no. For every pair of consonant intervals, there always exists at least one permitted voice leading connecting them directly.

The proof is elegant: if two intervals differ, you can always find a *canonical voice leading* where the bass voice stays still and only the soprano moves. Such a motion is never parallel (since one voice is stationary), so it's always legal. The only edge case is staying on the same interval — and even there, both voices can simply hold their notes (the identity, or "no motion" voice leading).

Music has no walls. Every consonance can reach every other consonance. The graph is a single interconnected web.

---

## The Bottleneck: Counting Self-Loops

The second surprise is where things get truly interesting. Count how many *self-loops* each interval has — how many legal voice leadings take an interval back to itself.

For an **imperfect** consonance (a third or a sixth), every one of the 12 possible parallel motions is legal, because parallel motion into an imperfect consonance is permitted. Combine that with all the non-parallel motions, and imperfect consonances enjoy maximal flexibility.

For a **perfect** consonance (a unison or a fifth), all 11 parallel motions are forbidden. The only self-loop is the identity — both voices standing still. Where an imperfect consonance has 12 self-loops, a perfect consonance has exactly 1.

This ratio — 12 to 1 — is a precise quantitative measure of how much the parallel-motion rule constrains musical flow. A composer approaching a perfect consonance has dramatically fewer options than one approaching an imperfect consonance. The mathematics confirms what every composition student feels in their bones: perfect consonances are bottlenecks.

---

## Broken Symmetries: Why the Bass Matters

There's a beautiful symmetry you might expect to hold in this system. If two notes are an interval of *i* apart, then *swapping* which note is on top gives you an interval of *-i* (modulo 12). You might hope that this swap — reversing which voice is the bass and which is the soprano — would preserve consonance. After all, a fifth is a fifth whether you're counting up from the bass or down from the soprano.

It doesn't.

The perfect fifth is 7 semitones. Its swap — 12 minus 7 — is 5 semitones, which is the perfect fourth. And the perfect fourth, in species counterpoint, is *dissonant*. This is one of the most notoriously counterintuitive facts in music theory: the perfect fourth, despite its acoustic purity, is treated as a dissonance when it appears above the bass voice.

The mathematics captures this precisely. The involution that maps each interval *i* to *-i* (in modular arithmetic, to *12 - i*) does not preserve the set of consonant intervals. The number 7 is consonant; the number 5 is not. The system is fundamentally asymmetric with respect to voice exchange.

This is not a bug in the formalization — it's a feature of the music. Counterpoint is written from the bass up. The bass voice is privileged. Swap the voices and the rules change. The mathematics of modular arithmetic reveals that this asymmetry is not a cultural accident but an algebraic necessity, given the specific intervals that Western music designates as consonant.

---

## The Composability Failure

Perhaps the most profound result is the most negative one. In mathematics, one of the most basic things you can ask about a system of transformations is whether they *compose*: if move A is legal and move B is legal, is doing A followed by B also legal?

The answer for counterpoint is **no**.

Two individually valid voice leadings can combine into a forbidden one. You can make a legal move to a perfect fifth, and from that fifth make another legal move — but the *composite* of those two moves, applied directly, might constitute parallel motion into a perfect consonance. Each step is fine; the combination is not.

This is a deep structural fact. In the language of abstract algebra, the permitted voice leadings do *not* form a category. They form something weaker — a directed graph, a quiver — but they lack the closure under composition that would make them a category. The parallel-motion prohibition is not a "categorical" constraint; it's an inherently *local* rule that can be satisfied step-by-step but violated globally.

This explains something about the art of counterpoint that composers know intuitively: you can't plan a counterpoint by stringing together locally good moves. You have to think about the trajectory as a whole. The mathematics tells us why: the space of legal moves has the topology of a graph, not a category.

---

## Beyond Twelve Notes

One of the most striking aspects of this mathematical framework is that it's not limited to the standard twelve-note system. The entire theory can be parameterized by any number *n* — any equal temperament. A 19-note-per-octave system (used in some Renaissance music) or a 31-note system (used by some modern composers) would have its own consonant intervals, its own perfect consonances, and its own counterpoint graph.

The framework defines a *Counterpoint System* abstractly: a set of consonant intervals in the cyclic group of order *n*, a subset of perfect consonances, and the rule that parallel motion into perfect consonances is forbidden. The structural theorems — connectivity, the bottleneck phenomenon, the failure of composability — can potentially be stated and investigated at this level of generality.

This opens up a genuinely new research direction. What happens to the counterpoint graph in 19-TET? In 31-TET? Which tuning systems produce graphs with the richest connectivity? Which produce the most severe bottlenecks? The mathematics provides a language for asking — and answering — these questions with precision.

---

## The Sound of Structure

Three centuries after Fux wrote his treatise, we can finally see the rules of counterpoint for what they are: not arbitrary restrictions imposed by tradition, but reflections of deep algebraic structure in the space of consonant intervals.

The parallel-fifths prohibition creates a bottleneck that forces composers toward variety. The connectivity of the voice-leading graph ensures that this variety is always achievable — no interval is ever truly stuck. The failure of composability means that good counterpoint requires global planning, not just local correctness. And the voice-swap asymmetry explains why the bass voice has always occupied a privileged position in musical texture.

These are not metaphors. They are theorems — proved with the same rigor that mathematicians use to study prime numbers or geometric spaces. The notes on the page are numbers. The rules of composition are algebraic constraints. And the beauty of a Bach fugue is, in part, the sound of a path winding through a graph that is both constrained and free, bottlenecked and connected, local and global all at once.

Music is mathematics made audible. Now, at last, we can hear what the math is saying.
