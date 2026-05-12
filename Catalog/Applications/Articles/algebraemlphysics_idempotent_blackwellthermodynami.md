# When Information Becomes Energy: A Hidden Unity in Mathematics

## The Strangest Coincidence in Science

Imagine you're a spy handler running two informants. One sends you grainy photographs; the other sends detailed written reports. How do you decide which source is more valuable?

Now imagine you're a physicist calculating how much useful work you can extract from a heat engine. And then imagine you're a logician studying which propositions can be derived from which axioms.

These three problems—comparing information sources, extracting work from engines, and reasoning about logical closure—seem to belong to entirely different universes. Yet a new mathematical result reveals they are, in a precise and provable sense, *the same problem wearing three different costumes*.

## The Rosetta Stone

In the 1950s, the statistician David Blackwell posed a deceptively simple question: when is one experiment more informative than another? His answer was elegant. Experiment A dominates experiment B if you can simulate B by processing A's data—by blurring, averaging, or otherwise degrading it. Think of it this way: a high-resolution camera dominates a low-resolution one, because you can always blur a sharp image to produce a fuzzy one, but you can never sharpen a truly blurry image into a crisp one.

This "garbling" relationship creates a natural ordering among experiments. The high-res camera sits above the low-res one, which sits above a camera with the lens cap on. Blackwell showed this ordering captures something fundamental: if experiment A dominates experiment B, then A is at least as useful as B for *every possible decision problem*—whether you're diagnosing a disease, navigating a spacecraft, or betting on a horse race.

For decades, Blackwell's ordering remained a statistical concept. Nobody expected it to show up in thermodynamics or abstract algebra. But that's exactly what happened.

## The Tropical Twist

The breakthrough comes from an unusual branch of mathematics called *tropical algebra*—a world where addition is replaced by taking the minimum, and multiplication is replaced by ordinary addition. The name "tropical" is a whimsical tribute to the Brazilian mathematician Imre Simon, though the mathematics is anything but whimsical.

In tropical algebra, the equation 3 + 5 = 3 (because min(3, 5) = 3) and 3 × 5 = 8 (because 3 + 5 = 8). It sounds like a prank, but this arithmetic naturally arises whenever you're optimizing costs, finding shortest paths, or computing minimum-energy configurations.

The key insight is to re-encode Blackwell's experiments as *tropical matrices*—grids of numbers where each entry represents the cost of a particular observation. Composing two experiments corresponds to tropical matrix multiplication: finding the cheapest path through an intermediate stage.

In this encoding, Blackwell's garbling—degrading an experiment by processing its output—becomes tropical matrix multiplication. And Blackwell's ordering—which experiment is more informative—becomes a factorization property of tropical matrices.

## The Three-Way Mirror

Here is where the magic happens. Consider three seemingly unrelated structures:

**Structure 1: Closure Systems.** In logic and algebra, a *closure operator* takes a set of facts and generates all their consequences. If you know "it's raining" and "rain implies wet streets," closure gives you "wet streets" for free. Weighted closure systems add costs: generating each fact has a price.

**Structure 2: Tropical Channels.** In the tropical encoding, an experiment becomes a cost matrix mapping states of the world to observable outcomes. The minimum cost of observing anything from state *a*—the *free energy* at that state—measures how cheaply you can learn about *a*.

**Structure 3: Free-Energy Profiles.** From each weighted closure system and each tropical channel, you can compute a *free-energy profile*: a function that records, for each state, the total cost of generating that state and then observing it through the channel.

The theorem proves that these three structures are locked in perfect correspondence:

- Every weighted closure system produces a canonical tropical channel.
- This channel faithfully encodes the closure system's structure: you can read off the weights and the logical implications directly from the cost matrix.
- The free-energy profile is monotone under garbling: degrading a channel can only increase the free energy at every state.
- Channels that are equivalent in Blackwell's sense—neither more informative than the other—produce identical free-energy profiles.

In other words, the theorem says: **the information ordering, the algebraic closure ordering, and the thermodynamic energy ordering are the same ordering, viewed through different mathematical lenses.**

## Why This Matters: The Second Law as an Information Theorem

The most striking consequence is thermodynamic. The second law of thermodynamics—that entropy never decreases, or equivalently, that free energy never increases in a closed system—has been one of physics' most robust and mysterious principles for over 150 years.

In the tropical setting, the second law becomes a theorem about information processing. When you garble a channel (blur an image, coarsen a measurement, aggregate data), the free energy at every state can only go up. This isn't an analogy or a metaphor. It's a mathematical identity: the garbling operation in information theory *is* the dissipation operation in thermodynamics, expressed in the tropical semiring.

This gives a new proof of why the second law is so robust. It's not just a statement about heat and molecules. It's a statement about information processing: any post-processing of observations can only destroy information, which shows up as increased free energy. The second law is, at its core, a theorem about the Blackwell ordering.

## Reconstruction: Reading the Blueprint

Perhaps the most practical consequence is the *reconstruction theorem*. It says that if you have a weighted closure system—a set of logical implications with costs—you can build a canonical channel from it, and this channel is unique up to Blackwell equivalence.

Think of it this way. Suppose you have a network of sensors monitoring a factory. Each sensor has a cost to operate and provides certain logical deductions about the factory's state. The theorem tells you there's a canonical "best representation" of this sensor network as a tropical channel, and two networks are informationally equivalent if and only if they produce the same free-energy profile.

This is immensely useful for system design. Instead of comparing networks sensor by sensor—a combinatorial nightmare—you compute their free-energy profiles and check if they match. If they do, the networks are equivalent for every possible purpose. If one profile dominates the other pointwise, you know exactly which network is more informative.

## From Theory to Algorithms

The mathematical theory comes with concrete algorithms. Given a weighted closure system:

1. **Compute the canonical channel**: for each state, determine which observations are feasible (in the closure of that state) and assign the state's weight as the cost. This takes quadratic time in the number of states.

2. **Compute the free-energy profile**: for each state, find the minimum observation cost and add the generator weight. This is a simple minimum-finding operation.

3. **Test Blackwell dominance**: given two channels, attempt to construct a garbling matrix by solving a tropical linear system. This determines whether one channel can simulate the other.

4. **Extract minimal channels**: remove redundant observations (those with identical cost profiles across all states) to get the most compact representation.

These algorithms are fast—polynomial in the size of the system—and produce certified results: the mathematical theorems guarantee their correctness.

## The Bigger Picture

This result sits at a crossroads of several major research programs.

In **information theory**, it opens a new chapter of tropical or "zero-temperature" information theory, where Shannon's probabilistic framework is replaced by deterministic min-plus optimization. This is natural for worst-case analysis, adversarial settings, and optimization problems.

In **thermodynamics**, it provides a new algebraic framework for understanding why certain physical processes are irreversible. The algebraic structure of closure systems—extensivity, monotonicity, idempotence—mirrors the structure of thermodynamic equilibration.

In **machine learning**, the closure system perspective offers a new way to think about feature selection and model compression. Features that are logically implied by others are redundant; the closure operator identifies exactly which features carry independent information. Compressing a model by removing redundant features is precisely a Blackwell garbling, and the free-energy profile quantifies the information lost.

In **decision theory**, the result extends Blackwell's classical framework to a deterministic, worst-case setting where tropical algebra is the natural calculus. This is relevant for robust decision-making under uncertainty, game theory, and mechanism design.

## A New Language for an Old Problem

Science has always progressed by finding unexpected connections between different fields. Newton connected falling apples and orbiting moons. Maxwell connected electricity and magnetism. Shannon connected communication and probability.

The connection between information, energy, and logical closure may be equally fundamental. It suggests that the flow of information, the extraction of useful work, and the derivation of logical consequences are all governed by the same abstract structure—a structure that can be computed, verified, and optimized.

We are only beginning to explore this territory. The finite theory established here is the first step. Extensions to infinite systems, quantum channels, stochastic processes, and continuous closure spaces beckon. Each extension promises new connections between fields that have traditionally developed in isolation.

The ancient dream of a unified science—a single mathematical language describing the deep structure of information, energy, and logic—may be closer than we think. And it speaks, unexpectedly, in the arithmetic where three plus five equals three.
