# When Geometry Speaks in Information: The Hidden Dictionary Between Shape and Uncertainty

## A mathematical breakthrough reveals that an obscure geometric property of probability distributions secretly controls how much information coordinates can share

---

Imagine you're selecting a committee of five people from a group of twenty. Each person is either on the committee or not — a simple binary choice. But the choices aren't independent. If Alice is selected, it slightly reduces Bob's chances, because there are only five seats. This subtle push-and-pull between coordinates creates an intricate web of dependencies that mathematicians have struggled to quantify for decades.

Now imagine you learn that one person — say, Charlie — was *not* selected. How much does this revelation change your uncertainty about the remaining committee? Surprisingly, a new mathematical result proves that for a broad and important class of probability distributions, learning about one coordinate can never destroy too much of your total uncertainty. The entropy — a precise measure of uncertainty — drops by at most a single bit.

This might sound like a technical curiosity. But the proof reveals something far deeper: a hidden dictionary connecting the *geometry* of probability distributions to the *information* they encode. It turns out that a property called "Lorentzian negativity," borrowed from the mathematics of spacetime in Einstein's relativity, secretly governs how information flows through combinatorial systems. And that discovery opens doors to applications ranging from data privacy to statistical physics to the fundamental limits of communication.

---

## The Two Worlds That Shouldn't Talk to Each Other

For most of the twentieth century, two branches of mathematics developed in splendid isolation.

On one side: **information theory**, born from Claude Shannon's 1948 masterwork. Shannon showed that uncertainty can be measured precisely by a quantity called entropy, and that the flow of information obeys ironclad mathematical laws. His framework became the backbone of the digital age — every compressed image, every encrypted message, every error-correcting code owes its existence to Shannon's insights.

On the other side: **algebraic geometry**, the study of shapes defined by polynomial equations. This ancient discipline, stretching from Descartes through the towering abstractions of Alexander Grothendieck, seems about as far from telecommunications engineering as mathematics can get. Yet it harbors deep structural truths about how quantities relate to one another.

In 2020, a landmark paper by Petter Brändén and June Huh introduced **Lorentzian polynomials** — a class of multivariate polynomials whose internal geometry mimics the causal structure of spacetime. The name isn't accidental: just as Einstein's Lorentzian metric distinguishes time from space through a signature with exactly one positive direction, a Lorentzian polynomial has a Hessian matrix with exactly one positive eigenvalue. Everything else curves the "wrong" way — negatively.

This geometric property turned out to have extraordinary consequences. Distributions whose generating polynomials are Lorentzian automatically satisfy **negative dependence**: knowing that one coordinate is "on" makes other coordinates slightly more likely to be "off." This explained why random spanning trees, random matchings, and uniform matroid bases all share a family resemblance — they're all secretly Lorentzian.

But here's what nobody had proved: does this geometric negativity also control *information*?

---

## The Breakthrough: Geometry Controls Information

The new results establish precisely this connection, through four interlinked theorems that together form a dictionary between geometric and information-theoretic concepts.

### Theorem 1: You Can't Destroy Too Much Uncertainty

The first result addresses what happens when you "forget" one coordinate — when you project a probability distribution from *n* dimensions down to *n* − 1. In information-theoretic language, this is a **data processing** step: you're feeding the distribution through a channel that discards one bit of input.

The classical data processing inequality says that entropy can only decrease under such operations. But the new theorem gives a *lower* bound: for any probability distribution on subsets, the entropy after deleting one coordinate is at least the original entropy minus log 2 (about 0.693 nats, or exactly one bit). And the proof reveals *why*: deletion merges pairs of outcomes that differ only in the deleted coordinate, and the concavity of entropy limits how much uncertainty each merge can absorb.

This means that in committee-selection problems, learning whether one specific person was chosen or not can never eliminate more than one bit of your uncertainty about the full committee. The remaining *n* − 1 coordinates still carry almost all the information.

### Theorem 2: Coordinates Can't Share Too Much Information

The second theorem is more surprising. It bounds the **mutual information** between any two coordinates — a precise measure of how much knowing one coordinate tells you about another.

For a distribution that is "robustly Lorentzian" with gap parameter ε (meaning the geometric negativity is quantitatively strong), the mutual information between coordinates *i* and *j* is at most 1/(1 − ε)². The proof works through an elegant chain: Lorentzian negativity bounds covariance, covariance bounds the chi-squared divergence between the joint and product distributions, and chi-squared divergence bounds mutual information.

In plain terms: if the distribution has strong negative dependence (large gap), then no two coordinates can be highly correlated. Information is, in a precise sense, *spread out* across the system rather than concentrated in pairs.

### Theorem 3: Clustering Is Suppressed

The third theorem bridges to **statistical physics**. In a system of interacting particles, the **susceptibility** measures how strongly the system responds to an external field — it's the sum of all pairwise correlations. High susceptibility means particles cluster together; low susceptibility means they repel.

The theorem proves that for robustly Lorentzian measures, susceptibility is bounded by *n* · (1/4 + (*n* − 1) · ε), where *n* is the number of coordinates. This means the per-particle response χ/*n* remains controlled even as the system grows. Lorentzian negativity acts as a mathematical repulsive force, preventing the runaway clustering that characterizes phase transitions in ferromagnetic systems.

### Theorem 4: The Chi-Squared Bound

Underlying all these results is a clean analytic inequality: if two binary variables have marginal probabilities in the interval [ε, 1 − ε] and covariance bounded by ε, then their chi-squared divergence from independence is at most 1/(1 − ε)². This converts algebraic control (bounded covariance) into information-theoretic control (bounded divergence) through a calculation that balances numerator and denominator using the geometry of the marginal constraints.

---

## Why One Positive Eigenvalue Changes Everything

To understand why Lorentzian geometry is relevant, imagine a probability distribution as a landscape. Each point represents a possible subset of coordinates, and the height represents probability. The Hessian matrix of the log-generating polynomial measures the curvature of this landscape at each point.

A Lorentzian Hessian has exactly one direction where the landscape curves upward (like the top of a hill), and all other directions curve downward (like the inside of a bowl). This "one positive, all negative" signature means that the distribution is highly constrained: it can concentrate probability along one direction, but it must spread it out in all others.

This is exactly the geometric content of negative dependence. If you push probability toward subsets containing coordinate *i*, the Lorentzian constraint forces probability away from subsets containing coordinate *j*. The coordinates are in competition, geometrically forced to anticorrelate.

The new insight is that this competition doesn't just control probabilities — it controls *information*. The same curvature that prevents probability from concentrating also prevents mutual information from concentrating, entropy from collapsing under projection, and susceptibility from diverging. The geometry speaks in information.

---

## Applications: From Privacy to Particle Physics

The practical implications span multiple fields.

**Data Privacy.** When a database releases information about a random subset of records, deleting one record (to protect an individual's privacy) can destroy at most one bit of the released information. For negatively dependent release mechanisms, this provides a formal guarantee that individual deletions have bounded impact — a mathematical foundation for privacy-preserving data analysis.

**Communication Complexity.** If two parties each learn one coordinate of a Lorentzian distribution, the maximum information they can extract about each other's coordinate is bounded by the mutual information bound. This limits the power of any communication protocol built on such distributions, with implications for distributed computing and cryptographic protocols.

**Sampling Algorithms.** Many computational tasks require generating random samples from complex distributions. The bounded susceptibility theorem implies that natural Markov chain algorithms (like Glauber dynamics) mix rapidly on Lorentzian distributions, because the bounded correlations prevent the formation of bottlenecks in the state space.

**Statistical Mechanics.** In models of repulsive particles (electrons in a crystal, trees in a forest competing for resources, phone calls on a network avoiding interference), the susceptibility bound provides a rigorous guarantee that the system cannot undergo certain types of phase transitions. The mathematical repulsion built into the Lorentzian structure prevents the collective behavior that drives critical phenomena.

---

## A New Mathematical Landscape

What makes this work intellectually distinctive is not any single theorem, but the *dictionary* it establishes. Before this work, Lorentzian polynomials and Shannon entropy lived in different mathematical universes. Now we know they're connected by precise, quantitative bridges:

| **Geometric Concept** | **Information Concept** |
|---|---|
| Lorentzian gap (spectral margin) | Information contraction rate |
| Negative Hessian eigenvalues | Pairwise information suppression |
| Projection (deleting a variable) | Data processing (discarding a channel) |
| Susceptibility (curvature sum) | Total correlation strength |

This dictionary is not a metaphor — it's a collection of proved inequalities with explicit constants. And like all good dictionaries, it lets you translate problems from one language to another, potentially transforming hard questions in one domain into tractable ones in another.

---

## The Road Ahead

Several tantalizing questions remain open. Is the log 2 bound on entropy loss tight, or can Lorentzian negativity give something sharper? The numerical evidence suggests that for balanced matroids (rank roughly *n*/2), the actual entropy loss is significantly below log 2, hinting at a tighter bound that incorporates the rank.

Even more provocatively: does the mutual information bound improve from the proved 1/(1 − ε)² to something logarithmic in 1/ε? Computational experiments on matroid distributions suggest the actual scaling might be logarithmic — far tighter than what's currently proved. If confirmed, this would indicate that Lorentzian negativity is an even more powerful information-theoretic constraint than currently understood.

And the deepest question: does this dictionary extend to continuous settings? Lorentzian polynomials are discrete objects, but information theory knows no such boundary. If the Lorentzian-information dictionary generalizes to continuous measures on manifolds, it could reveal unexpected connections between differential geometry and information geometry — two fields that have developed largely independently despite sharing a name.

What's already clear is that the geometry of probability distributions carries far more information-theoretic content than anyone previously suspected. The signature of a Hessian matrix — a seemingly arcane algebraic property — turns out to govern the most fundamental aspects of how uncertainty, information, and correlation behave in combinatorial systems. In mathematics, the deepest truths often hide in plain sight, waiting for someone to read the right dictionary.
