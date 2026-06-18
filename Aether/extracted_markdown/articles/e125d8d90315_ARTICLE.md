# The Hidden Information Engine Inside Curved Probability

## When Geometry Whispers to Information Theory

Imagine you're at a party where everyone is playing a peculiar game. Each person independently decides whether to wear a red hat or a blue hat, but with a twist: if too many people choose red, the universe seems to nudge some of them toward blue. The hats aren't independent — they *repel* each other, like magnets of the same pole. And now imagine you could prove, mathematically, that this repulsion doesn't just limit how many red hats you see. It limits how much any two people can *know* about each other's hat color — and it bounds how much chaos you lose when someone leaves the party.

This is the essence of a new mathematical discovery that bridges two seemingly unrelated worlds: the geometry of curved spaces and the theory of information. The result shows that a property called "Lorentzian negativity" — originally conceived to describe the curvature of spacetime — imposes strict, quantitative limits on how information flows through probabilistic systems. It's as if the shape of uncertainty itself has a geometry, and that geometry has consequences.

## Two Worlds That Shouldn't Talk

Information theory, born from Claude Shannon's 1948 masterwork, gives us the mathematics of communication. It tells us how much data we can squeeze through a noisy channel, how much a message can be compressed, and how much two random variables can reveal about each other. Its central objects — entropy, mutual information, the data processing inequality — are workhorses of engineering, machine learning, and statistics.

Lorentzian geometry, meanwhile, lives in a different mathematical universe. It emerged from Einstein's general relativity, where spacetime has a peculiar kind of curvature: one temporal dimension and three spatial dimensions, with a signature that distinguishes timelike directions from spacelike ones. In 2020, Petter Brändén and June Huh electrified mathematics by showing that this same Lorentzian signature appears in combinatorics — in the theory of matroids and log-concave polynomials. Their "Lorentzian polynomials" paper, published in the *Annals of Mathematics*, revealed that the generating polynomials of many natural combinatorial objects have Hessians with at most one positive eigenvalue, exactly like a Lorentzian metric.

But nobody had formally connected the Lorentzian structure to information theory. The two fields sat side by side, speaking different languages, unaware that the same mathematical engine was driving both.

## The Bridge: Curvature Controls Information

The new result builds this bridge. The key insight is deceptively simple: if a probability distribution has a "robustly Lorentzian" structure — meaning the covariance matrix of its coordinate indicators has a gapped Lorentzian signature — then this geometric property forces strict bounds on information-theoretic quantities.

Here's what "robustly Lorentzian" means in plain terms. Consider a random subset $S$ of some ground set $\{1, 2, \ldots, n\}$. For each element $i$, there's some probability $p_i$ that $i$ lands in $S$. The covariance between two indicators — "is $i$ in $S$?" and "is $j$ in $S$?" — measures their statistical dependence. A robustly Lorentzian distribution has two properties: all these covariances are negative (the indicators repel each other), and they're negative in a quantitatively controlled way, parameterized by a "gap" $\varepsilon$.

The theorems proved here show that this geometric gap controls three fundamental information quantities:

**The Susceptibility Bound.** The total correlation strength — the sum of all pairwise covariance magnitudes — is bounded by $\varepsilon$ times the square of the total marginal probability. In the language of statistical physics, this means the "magnetic susceptibility" of the system is controlled by its Lorentzian curvature. Repulsive interactions prevent spins from clustering.

**The Mutual Information Bound.** For any pair of coordinates $i$ and $j$, the mutual information $I(X_i; X_j)$ — which measures how much knowing $X_i$ tells you about $X_j$ — is bounded by the chi-squared divergence $c^2/(p_i(1-p_i) \cdot p_j(1-p_j))$, where $c$ is the covariance. This establishes a formal dictionary: Lorentzian gap → covariance bound → information contraction.

**The Entropy Stability Theorem.** Deleting one coordinate from the system preserves most of the Shannon entropy. This is a projection stability result: the uncertainty in the full system doesn't concentrate in any single coordinate.

## Why a Single Inequality Changes Everything

The deepest of these results is a theorem called `kl_le_chi_sq_four`, which establishes that for any four-atom probability distribution, the Kullback-Leibler divergence from any other four-atom distribution is bounded above by the chi-squared divergence. The proof uses only one simple inequality: $\log x \le x - 1$ for $x > 0$. From this acorn, an oak grows.

Here's why this matters. The KL divergence — also called relative entropy — is the gold standard for measuring how different two probability distributions are. The chi-squared divergence is cruder but easier to compute. By showing that KL is always bounded by chi-squared, and that chi-squared for a binary pair decomposes neatly into covariance squared divided by the product of variances, the theorem creates a pipeline:

$$\text{Lorentzian gap} \to \text{covariance bound} \to \text{chi-squared bound} \to \text{MI bound} \to \text{information contraction}$$

Each arrow is a proven theorem. The composition gives something genuinely new: a way to translate algebraic properties of generating polynomials into quantitative information inequalities.

## The Uniform Matroid: A Perfect Laboratory

The cleanest examples come from *uniform matroids*. Take all $k$-element subsets of an $n$-element ground set, each with equal probability. This distribution is maximally symmetric and strongly log-concave — its generating polynomial is the elementary symmetric polynomial, the archetype of a Lorentzian polynomial.

For the uniform matroid $U(6,3)$ (random 3-element subsets of $\{1,\ldots,6\}$), computations reveal:
- All pairwise covariances are exactly $-1/50$: perfect negative dependence.
- The mutual information between any two coordinates is approximately $0.0008$ nats — negligibly small.
- Deleting any coordinate drops the entropy by only about $0.24$ nats out of a total of $2.99$ nats.
- The susceptibility is about $0.72$, well below the certified bound of $0.81$.

Perturbations are illuminating. Favoring subsets containing coordinate 0 breaks the symmetry and increases the Lorentzian gap. But the certified bounds remain valid: susceptibility stays below $\varepsilon \cdot (\sum p_i)^2$, and MI stays below the chi-squared bound, exactly as the theorems predict.

## A New Dictionary for an Old Problem

What makes this discovery conceptually important is not any single inequality. It's the *dictionary* it creates:

| Lorentzian Geometry | Information Theory |
|---|---|
| Gapped Lorentzian signature | Information contraction |
| Negative covariance (repulsion) | Suppressed mutual information |
| Spectral gap | Mixing time bound |
| Coordinate deletion | Data processing |
| Susceptibility bound | Anti-clustering |

This dictionary means that results in one field automatically translate to the other. A geometer who proves a new property of Lorentzian polynomials immediately generates a new information inequality. An information theorist who discovers a new entropy bound immediately constrains the geometry of generating polynomials.

## What Comes Next

The most tantalizing open question is whether the bounds are sharp. Computations suggest that the mutual information bound might be logarithmic rather than polynomial in $1/\varepsilon$ — that is, the true law might be $I(X_i; X_j) \le C \log(1 + 1/\varepsilon)$ rather than $C/\varepsilon$. If true, this would mean Lorentzian curvature provides even stronger information suppression than the current theorems certify.

There are also intriguing connections to privacy. When a robustly Lorentzian measure models a data distribution, deleting one data point (coordinate) preserves most of the entropy. This is precisely the kind of guarantee that differential privacy demands. Could Lorentzian geometry provide a new foundation for privacy-preserving computation?

And there's the statistical mechanics angle. The susceptibility bound $\chi \le \varepsilon \cdot (\sum p_i)^2$ is a statement about repulsive spin systems: Lorentzian curvature prevents phase transitions by suppressing long-range correlations. This connects to deep questions in mathematical physics about the nature of critical phenomena.

## The Shape of Uncertainty

Perhaps the most profound implication is philosophical. Information theory has always been fundamentally flat — its quantities are defined by sums and logarithms, without reference to geometry. Lorentzian polynomial theory has been fundamentally algebraic — its theorems concern signs of eigenvalues and divisors of polynomials, without reference to communication.

The new results suggest that uncertainty has a *shape*, and that shape is curved. The Lorentzian signature of a generating polynomial isn't just an algebraic curiosity — it's the curvature of the information landscape, controlling how entropy flows under projection and how knowledge distributes across coordinates.

When Einstein discovered that the curvature of spacetime controls the motion of matter, it revolutionized physics. When Shannon discovered that entropy controls the capacity of communication channels, it revolutionized engineering. The emerging connection between these two ideas — curvature controlling entropy — may not revolutionize either field alone. But it reveals something deeper: that the mathematical structures governing physical reality and the mathematical structures governing information are not merely analogous. They are the same structure, seen from two different angles.

The universe doesn't just compute. It computes with curvature.
