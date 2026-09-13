# The Counterpoint That Could Not Climb: How a Frozen Bass Breaks a Musical Universe Into Four

## A rule book, turned into a machine

Somewhere around the year 1725, Johann Joseph Fux wrote down the rules of *first-species counterpoint*: two voices, note against note, moving in consonance. Sing only intervals that sound stable — unisons, thirds, fifths, sixths, octaves. Move each voice smoothly, by a step, not a leap. And never slide into a perfect consonance with both voices travelling in the same direction, because the resulting bare fifth or octave sounds like a hole in the texture.

These are aesthetic rules, three centuries old, taught to every composition student. But they are also, read literally, the transition rules of a finite-state machine. Each "state" is a pair of pitches sounding together. Each "move" is a legal progression from one such pair to the next. A piece of counterpoint is a path through the machine.

And once you have a machine, you can ask machine questions. The most basic one is: **is it connected?** Starting from any sonority, can you reach any other by a finite chain of legal moves? If yes, the system is *strongly connected* and the composer is free: no harmonic destination is closed off. If no, the state space fractures into islands, and some musical journeys are simply impossible — not stylistically discouraged, but mathematically forbidden.

This article is about a conjecture that the answer was yes, about the discovery that the answer is emphatically no, and about what the failure turns out to be measuring. The short version: the system shatters into **four** islands; **34 of the 49** ordered pairs of intervals are mutually unreachable; the humble unison can never, ever become an octave. And the culprit is not counterpoint. The culprit is a single, invisible modelling choice.

## The seven consonances and the ladder they form

Measure intervals in semitones, the smallest step on a piano. Within one octave, the classical consonances are exactly seven:

$$0 \ (\text{unison}),\quad 3 \ (\text{minor third}),\quad 4 \ (\text{major third}),\quad 7 \ (\text{perfect fifth}),\quad 8 \ (\text{minor sixth}),\quad 9 \ (\text{major sixth}),\quad 12 \ (\text{octave}).$$

Everything else — the second, the tritone, the seventh — is a dissonance and is excluded from the note-against-note style. So the consonances form a *ladder* of seven rungs embedded in the integers, and the interesting feature of that ladder is not its rungs but its **gaps**. Walking up, consecutive gaps are

$$0 \xrightarrow{\,3\,} 3 \xrightarrow{\,1\,} 4 \xrightarrow{\,3\,} 7 \xrightarrow{\,1\,} 8 \xrightarrow{\,1\,} 9 \xrightarrow{\,3\,} 12 .$$

Three gaps of size one — the thirds are adjacent, and the fifth, minor sixth and major sixth form a tight cluster. And three chasms of size three: below the minor third, between the major third and the fifth, and above the major sixth. Hold that pattern $3,1,3,1,1,3$ in mind. It is the whole story.

## Freezing the bass

To turn the seven intervals into seven *states*, you have to pick a representative sonority for each. The obvious, tidy choice is to put the lower voice at pitch $0$ and the upper voice at the interval: the unison is $(0,0)$, the minor third is $(0,3)$, the octave is $(0,12)$. Clean, canonical, and — as we shall see — fatal.

Now apply the rules. When is the move from $(0,s)$ to $(0,t)$ legal? Both sonorities are consonant by construction. Neither voice may leap, so each must move by at most a whole tone, two semitones. The lower voice does not move at all: it is pinned at $0$. Therefore the upper voice carries the entire burden, and the move is legal exactly when

$$|t - s| \le 2 .$$

(The prohibition on parallel perfect consonances never even fires: with one voice standing still, the two voices are not moving in the same direction, so no similar motion into a perfect interval can occur.)

Compare that bound of $2$ to the gap pattern $3,1,3,1,1,3$. Every gap of size $1$ can be crossed. Every gap of size $3$ cannot. The ladder snaps at three places, and the seven intervals fall into four blocks, which we call **registers**:

$$\{0\},\qquad \{3,4\},\qquad \{7,8,9\},\qquad \{12\}.$$

The unison, alone. The two thirds, which can trade places. The fifth–sixth cluster, internally mobile. The octave, alone.

## The complete invariant

Here is the sentence that does all the work:

> **Register Theorem.** For the seven canonical sonorities, a legal one-step motion from interval $i$ to interval $j$ exists **if and only if** $i$ and $j$ lie in the same register.

Checking it is a matter of inspecting a $7 \times 7$ table, but its consequences are not tabular at all. The relation "same register" is an equivalence relation — reflexive, symmetric, transitive — so the legal-move relation inherits all three properties for free. It is reflexive: a sonority may legally repeat. It is symmetric: every legal move may be played backwards. And, most importantly, it is **transitive**: the composition of two legal moves is itself a single legal move.

Transitivity is the killer. Reachability normally means *there exists some finite chain*, and the point of allowing chains is that they take you places a single step cannot. Here they do not. Chaining legal moves gets you exactly nowhere new: the closure of the move relation under composition is the move relation itself. Formally:

> **Saturation Theorem.** Interval $j$ is reachable from interval $i$ by a finite chain of legal motions if and only if a *single* legal motion joins them — if and only if $i$ and $j$ share a register.

So we can count exactly. A register of size $k$ contributes $k^2$ ordered reachable pairs, giving

$$1^2 + 2^2 + 3^2 + 1^2 = 1 + 4 + 9 + 1 = 15$$

reachable ordered pairs out of $7 \times 7 = 49$. The remaining **34 ordered pairs are unreachable**. The conjecture that the system is strongly connected does not merely fail; it fails on a clear majority of pairs.

The cleanest single refutation, and the most musically striking, is this:

> **Counterexample.** Starting from a unison, no finite sequence of legal note-against-note motions ever arrives at an octave.

Unison sits in register $\{0\}$; the octave sits in register $\{12\}$; the register can never change; therefore no path exists. In fact both of these intervals are *totally isolated*: with the bass frozen, a unison can only ever be followed by another unison, forever, and likewise the octave. A two-voice exercise that starts in unison is condemned to remain in unison for all eternity. That is not counterpoint. That is a drone.

## The invariant is the best possible one

One might hope the register decomposition is an artifact of a clumsy choice of invariant — that some subtler quantity would explain more. It does not, and cannot:

> **Universality Theorem.** Every quantity that is preserved by legal one-step motions is a function of the register. That is, if $f$ assigns a value to each of the seven intervals and $f(i) = f(j)$ whenever a legal motion joins $i$ to $j$, then $f(i) = f(j)$ whenever $i$ and $j$ merely share a register.

So the register is the *finest* conserved quantity in the system: nothing is preserved that the register does not already explain, and no finer block decomposition exists. The four blocks are canonical, not chosen.

There is a pleasing categorical way to say it. Think of the seven intervals as objects and the legal motions as arrows. Because the relation is symmetric, every arrow is invertible: the structure is a **groupoid**. Because the two thirds are distinct but mutually reachable, it is not a partial order — the structure is not skeletal. Collapsing mutually reachable objects, the **skeleton has exactly four objects and no arrows between them**: the discrete four-object category. Strong connectivity would demand a skeleton with a single object. We have four. The failure is as total as it could be while retaining any structure at all.

## The sharp threshold: exactly a minor third

Why $2$? Because "stepwise" in first-species counterpoint means a melodic move of at most a whole tone. Suppose we relax it: let the melodic step width be a parameter $w$, so a motion from interval $i$ to interval $j$ is admitted when $|j - i| \le w$. What happens?

> **Threshold Theorem.** The seven consonances are strongly connected under width-$w$ motion **if and only if** $w \ge 3$.

A genuine phase transition, and a sharp one. At $w = 0, 1, 2$ the system is disconnected and the unison still cannot reach the octave. At $w = 3$ — the moment melodic leaps of a *minor third* become legal — the entire ladder links up into one component, and the path

$$0 \to 3 \to 4 \to 7 \to 8 \to 9 \to 12$$

walks the upper voice from unison to octave through every consonance in order. Widening further changes nothing qualitative; $3$ is the critical width.

The number $3$ is not a coincidence, and the phase transition is not really about music. It is an instance of a completely general fact about walking on a finite set of integers:

> **Gap Criterion.** Let $S$ be any finite set of integers, and join two of its elements whenever they differ by at most $w$. Then every element of $S$ is joined to every other by a finite path **if and only if** every pair of *consecutive* elements of $S$ differs by at most $w$.

The "only if" half is a cut argument: if two consecutive elements $x < y$ of $S$ satisfy $y - x > w$, then no point of $S$ lies strictly between them, so a hop of size at most $w$ starting at or below $x$ can never land above $x$ — the gap is an impassable wall, and everything reachable from $x$ stays on its side. The "if" half is an induction on distance: given $a < b$ in $S$ too far apart to hop directly, some element of $S$ must lie strictly between them (otherwise they were consecutive and the hypothesis is contradicted), and both halves are strictly shorter, so both are connected by induction.

Feed the consonance ladder into this criterion. Its consecutive gaps are $3,1,3,1,1,3$; the maximum is $3$; therefore the critical width is exactly $3$. The historical stepwise rule sets $w = 2$, one semitone short. **The system is disconnected by a single semitone.**

This also makes the result portable. Every tuning system has a consonance ladder, and every ladder has a largest consecutive gap, and that number — computable by inspection — is its critical melodic width. Quarter-tone systems, just-intonation subsets, the Bohlen–Pierce scale: each has its own critical width, and the theorem above hands it to you immediately.

## The bass was never supposed to be frozen

Now for the twist. Everything above is a theorem about *seven canonical sonorities with the lower voice pinned at zero*. Real counterpoint has two moving voices. Does the obstruction survive?

It does not. It evaporates.

> **Free-Bass Theorem.** In the full two-voice system, where both parts may move, all seven consonances are mutually reachable. Every consonance can be connected to every other by a finite chain of legal first-species motions.

The witness is a **contrary-motion spine**, one of the most characteristic gestures in counterpoint — the voices moving in opposite directions, opening the texture out like a fan:

$$(0,0) \to (-1,2) \to (-1,3) \to (-2,5) \to (-2,6) \to (-2,7) \to (-3,9).$$

Read off the vertical intervals of these six sonorities and their successor: $0, 3, 4, 7, 8, 9, 12$ — every consonance, in order, in a single legal passage. Each move is stepwise in both voices; each sonority is consonant; and the perfect consonances (the fifth at $(-2,5)$, the octave at $(-3,9)$) are approached by *contrary* motion, exactly as Fux demands. Since every legal motion may be played in retrograde, the spine can be walked in either direction, so any consonance connects to any other.

The point is subtle and worth stating plainly. Freezing the bass halves the available melodic motion: the interval can change by at most $2$ per move instead of $2 + 2 = 4$. That single lost semitone of interval mobility is the difference between a shattered state space and a connected one. **The obstruction is an artifact of the modelling choice, not a property of counterpoint.** The conjecture was false as stated and true in spirit; the frozen bass was hiding in plain sight.

## How far is the octave, exactly?

With both voices free, connectivity is restored — but at what cost? Here the answer is exact.

> **Distance Theorem.** With both voices free, a unison sonority can be joined to an octave sonority in exactly **three** legal motions, and no fewer.

The lower bound is a potential argument of the sort familiar from physics. Each voice moves by at most two semitones per step, so the vertical interval changes by at most $2 + 2 = 4$ semitones per step; hence after $n$ steps it has changed by at most $4n$. Unison and octave differ by $12$, so $4n \ge 12$, so $n \ge 3$ — and crucially this bound holds for *every* pair of sonorities realizing those intervals, not merely the canonical ones.

The upper bound is the maximally contrary path, both voices sprinting apart at full legal speed:

$$(0,0) \to (-2,2) \to (-4,4) \to (-6,6),$$

with intervals $0 \to 4 \to 8 \to 12$. Three steps, bound attained. As a by-product, the six-step spine used to prove connectivity is *not* geodesic: it visits every consonance, which is a different and more leisurely task than getting from unison to octave as fast as possible.

## What the failure was measuring

Strip the music away and a clean methodological lesson remains.

A conjecture about the reachability of a finite state machine turned out to be false, and the refutation took four ordered pairs' worth of effort to find — but the *interesting* content was not the refutation. It was the diagnosis. The state space was disconnected because an invariant existed. The invariant was the register. The register existed because the consonance ladder has gaps of size three while the frozen-bass dynamics can only move by two. And the dynamics could only move by two because one voice had been quietly nailed down in the act of choosing canonical representatives.

Every one of those steps turns a "no" into structure: a complete invariant, a sharp threshold at $w = 3$, a general gap criterion for arbitrary integer sets, a four-object discrete skeleton, and an exact distance of three in the repaired model. The refuted statement is replaced by a guarded one that is true, sharp, and considerably more informative than the original would have been had it been correct.

And the music? The music was right all along. Counterpoint students are not told to move the bass because a theorem requires it; they are told because a static bass sounds inert. It is quietly satisfying that the inertness is literally true: with the lower voice frozen, a unison is a prison, an octave is a prison, and the whole expressive universe collapses to four disconnected islands. Let the bass move — let the voices open outward in contrary motion — and the universe becomes whole, with the octave exactly three steps away.
