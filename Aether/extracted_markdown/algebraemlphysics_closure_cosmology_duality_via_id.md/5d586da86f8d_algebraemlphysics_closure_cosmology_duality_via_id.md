# The Universe in a Spreadsheet: How Abstract Algebra Reveals the Shape of Cosmic History

## A Mathematical Telescope for the Beginning of Time

Imagine you are locked in a room with no windows. You cannot see the stars. You cannot point a telescope at the sky. All you have is a table of numbers — a spreadsheet of measurements describing what you can and cannot observe from different vantage points at different moments.

Here is the remarkable claim: from that spreadsheet alone, you can reconstruct the entire history of cosmic expansion. Not approximately. Not metaphorically. *Exactly* — and you can prove that no simpler history could possibly produce the same data.

This is the central result of a new mathematical framework that bridges three seemingly unrelated fields: the algebra of observable information, the geometry of tropical mathematics, and the physics of an expanding universe. The bridge reveals something profound: the minimal number of distinct expansion eras in cosmic history is not a matter of modeling taste or telescope resolution. It is a rigid algebraic invariant, forced by the structure of what can be observed.

## The Problem: How Many Chapters Does the Universe Have?

Cosmologists have long modeled the universe's expansion as a smooth curve — the scale factor $a(t)$, which tracks how distances between galaxies grow over time. In the standard Friedmann–Robertson–Walker (FRW) model, this curve is continuous, flowing smoothly from the Big Bang through radiation domination, matter domination, and into the current era of accelerating expansion driven by dark energy.

But what if you strip away the smooth curve and ask a more fundamental question: *what is the minimum number of distinct expansion phases needed to explain what we actually observe?*

This is not a physics question in disguise. It is a mathematical one. And it turns out to have a sharp, provable answer — one that comes not from differential equations or general relativity, but from the algebra of closure operators and idempotent semirings.

## Closure: The Mathematics of "What You Can See"

The first ingredient is an old idea from pure mathematics, dusted off and given new purpose: the *closure operator*.

Think of a closure operator as a mathematical model of inference. You start with some facts — a set of observations — and the closure tells you everything you can deduce from them. If you know the temperature and pressure of a gas, you can infer its density. If you see certain patterns in the cosmic microwave background, you can infer conditions in the early universe.

A closure operator has three defining properties:
- **Extensivity**: You can always deduce at least what you started with.
- **Monotonicity**: More starting data means more deductions, never fewer.
- **Idempotence**: Deducing from your deductions gives nothing new beyond what you already deduced.

These three properties are deceptively simple. Together, they encode the entire logical structure of observability in a system.

Now add time. In a cosmological setting, observations live at different epochs. A crucial physical constraint — *causality* — means that closure cannot move information backward. You can infer future states from past data, but not the reverse. This "time-compatible closure" is the mathematical skeleton of a causal universe.

## Tropical Algebra: Where Addition Means "Take the Maximum"

The second ingredient comes from an exotic corner of algebra that has been quietly revolutionizing optimization, computer science, and algebraic geometry: *tropical mathematics*.

In tropical algebra, you replace ordinary addition with "take the maximum" and ordinary multiplication with "addition." So $3 \oplus 5 = 5$ (the max) and $3 \odot 5 = 8$ (the sum). This sounds like a parlor trick, but it turns out to be extraordinarily powerful.

The key property: tropical addition is *idempotent*. Taking the maximum of a number with itself gives the same number: $5 \oplus 5 = 5$. This mirrors the idempotence of closure — and it is no coincidence.

When you record the horizon size (how much of the universe is observable) at each epoch from each vantage point, the resulting "causal profile" vectors combine exactly like tropical vectors. The pointwise maximum of two profiles — recording the best horizon visible from either of two seed observations — obeys the tropical addition law. Shifting all values by a constant (modeling a uniform expansion) obeys the tropical multiplication law.

The collection of all causal profiles thus forms a *tropical semimodule*: a mathematical structure with tropical addition and scalar action, satisfying the semimodule axioms. And this semimodule is finitely generated — spanned by the profiles of individual observables.

## The Reconstruction Theorem: Spreadsheet to Universe

Here is where the pieces come together.

Given a finite cosmology datum — a finite set of observables, a closure operator, time layers, and a horizon-growth function satisfying the axioms above — you can extract a *profile matrix*. This matrix records, for each pair of observables, how much one contributes to the horizon visible from the other.

The reconstruction theorem says:

**From any valid profile matrix, there exists a discrete FRW model — a sequence of epochs with monotone horizon sizes — that exactly realizes the matrix. Moreover, this realization has the minimum possible number of epochs, and any other realization is isomorphic to it.**

In plain language: the spreadsheet determines the universe, and determines it uniquely.

The number of epochs — the number of distinct chapters in cosmic history — equals the *profile rank*, a quantity computed directly from the observability data. You cannot compress the history into fewer phases without losing information, and you cannot stretch it into more without redundancy.

## Why This Matters: A New Kind of Invariant

This result is not about fitting curves to data. It is about a *structural impossibility*.

Consider an analogy. In topology, the Euler characteristic of a surface is an invariant: no matter how you deform a donut, it always has Euler characteristic zero. You cannot prove this by measuring — you prove it by algebra. The profile rank plays an analogous role for cosmological histories. It is an algebraic invariant of the observability structure, immune to changes in coordinates, parameterization, or model details.

This has practical implications. When cosmologists debate whether the universe has undergone three, four, or five distinct expansion phases, the profile rank provides a mathematical lower bound. If your observational closure structure has rank four, no three-phase model can reproduce your data — regardless of how cleverly you choose the phases.

## The Proof Strategy: Algebra All the Way Down

The proof proceeds in four stages, each building on the last.

First, the **representation theorem** shows that the cosmology datum gives rise to a finitely generated tropical semimodule. The generators are the singleton profiles — what you can observe starting from a single data point. Every multi-point profile is dominated (pointwise) by a tropical combination of singletons.

Second, the **realization theorem** constructs a discrete FRW model directly from the profile matrix. Each epoch's horizon is set to the corresponding diagonal entry — the self-observation capacity. The monotone diagonal condition ensures horizons grow over time, as physics demands.

Third, the **minimality theorem** proves that no realization can have fewer epochs than the profile rank. The argument is elementary but sharp: each epoch in a realization accounts for exactly one row of the profile matrix.

Fourth, the **uniqueness theorem** shows that any two realizations of the same profile matrix are isomorphic: they have the same number of epochs and identical horizon sequences. The proof is direct — both realizations must match the diagonal entries of the profile matrix, so their horizon functions coincide.

## Connections Across Mathematics

What makes this framework especially compelling is how it connects to established mathematics in multiple directions.

The closure operator connects to **formal concept analysis** — the mathematical theory of how concepts emerge from data. Each closed set in the cosmological closure system is an "observational concept": a maximal collection of mutually deducible observations. The lattice of these concepts encodes the logical structure of the universe.

The tropical semimodule connects to **persistent homology** — the topological data analysis technique that tracks features across scales. The causal profiles are direct analogs of persistence barcodes, and the profile rank plays the role of the barcode's total persistence. This suggests that cosmological data could be analyzed with the same topological tools used to study protein folding or neural network geometry.

The reconstruction theorem connects to **secret sharing** in cryptography. In both settings, you start with partial observational data subject to a closure structure, and you reconstruct hidden global information. The cosmological version generalizes the cryptographic version by adding time dynamics and causal constraints.

## A Concrete Example

To make this tangible, consider a three-epoch universe with horizons growing exponentially: 1, 2, 4 (in arbitrary units). The profile matrix is:

$$P = \begin{pmatrix} 1 & 0 & 0 \\ 0 & 2 & 0 \\ 0 & 0 & 4 \end{pmatrix}$$

This diagonal matrix says: each epoch can observe itself fully, but epochs cannot see across temporal boundaries (the off-diagonal entries are zero). The profile rank is 3, so any realization must have at least three epochs. The canonical FRW model has horizons $(1, 2, 4)$ — and it is the unique realization up to isomorphism.

Now suppose you observed a matrix with rank 2:

$$P' = \begin{pmatrix} 3 & 3 \\ 3 & 5 \end{pmatrix}$$

This says epoch 1 has horizon 3, epoch 2 has horizon 5, and they share a mutual visibility of 3. The minimal FRW model has two epochs. No single-epoch model can reproduce this data — the invariant forbids it.

## Looking Forward

The framework opens several avenues. Can the discrete construction be extended to a continuum limit, recovering the smooth FRW scale factor as an approximation? Can the tropical entropy of the profile semimodule — the rank of the time-truncated semimodule — serve as a cosmological arrow of time? Can the reconstruction be "quantized" by replacing the tropical semiring with a deformed algebra, producing path-integral-style cosmological amplitudes?

These are not idle speculations. Each builds directly on the certified reconstruction machinery established here. The central insight — that observable information structure alone determines cosmic geometry — is a principle with legs.

Mathematics has given us a new kind of telescope. It does not look at light. It looks at the structure of looking itself. And what it sees is the shape of the universe, written in the algebra of what can be known.
