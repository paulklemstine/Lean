# The Hidden Geometry of Randomness: How Curvature Controls Information

*When mathematicians discovered that a shape-like property of probability distributions controls how much two random variables can "know" about each other, they opened a door between geometry and information theory that nobody knew existed.*

---

## The Puzzle of Perfect Repulsion

Imagine you're organizing a dinner party with six tables, and you need to seat exactly three guests at each table from a pool of six friends. You want to be fair, so you choose the seating uniformly at random from all possible arrangements. Simple enough.

But something remarkable happens when you look at the correlations. If Alice is seated at a table, it slightly *decreases* the probability that Bob is also at that table. This isn't because Alice and Bob dislike each other — it's a mathematical inevitability. With a fixed number of seats, including one person mechanically excludes others. The friends are *negatively dependent*: knowing where one sits tells you something — but not too much — about where the others sit.

This kind of negative dependence shows up everywhere: in the electrons repelling each other in a quantum dot, in the diversified recommendations of a streaming algorithm, in the way a balanced portfolio distributes risk across sectors. For decades, mathematicians have known that negative dependence is powerful but struggled to quantify exactly *how powerful*. How much information does one coordinate really leak about another? How much does the system's uncertainty decrease when you observe part of it?

Now, a new mathematical framework provides precise, certified answers — by revealing that negative dependence is secretly a statement about *geometry*.

## From Polynomials to Curvature

The story begins with an unlikely protagonist: the *generating polynomial*.

Every probability distribution on subsets of a finite set can be encoded as a polynomial. If you're selecting subsets of {1, 2, 3, 4, 5, 6} with certain probabilities, you can write a polynomial where each term corresponds to a possible subset, with its coefficient being the probability. For the uniform matroid (selecting exactly 3 items from 6), this polynomial has twenty terms, all with equal coefficients.

In 2020, Petter Brändén and June Huh proved a stunning theorem: certain natural probability distributions have generating polynomials that satisfy a geometric condition called *Lorentzian signature*. The name comes from Einstein's theory of relativity, where spacetime has a distinctive geometric signature — one direction (time) behaves differently from the others (space). A Lorentzian polynomial has exactly one "positive direction" in its curvature landscape, while all other directions curve negatively.

This might sound abstract, but the consequences are concrete. A Lorentzian polynomial is like a mountain with a single ridgeline: you can go up along the ridge, but every other direction slopes downward. In probability terms, this means the distribution has a single dominant trend (the average set size), while all fluctuations around that trend are suppressed.

## The Gap That Changes Everything

The new insight goes further. It's not just that the curvature is negative — it's *quantifiably* negative, with a measurable gap.

Think of it this way: if a mountain has gentle slopes, a hiker might wander far from the ridge. But if the slopes are steep — if there's a large gap between the ridge height and the surrounding terrain — the hiker is confined to a narrow band around the ridge. The steeper the slopes, the stronger the confinement.

For probability distributions, this "gap" parameter ε measures how strongly the distribution resists correlations between coordinates. A small ε means strong repulsion — the coordinates are nearly independent. A large ε means the repulsion is weak, and correlations can develop.

The central discovery is that this geometric gap directly controls *information-theoretic* quantities: entropy, mutual information, and susceptibility. The translation works like this:

- **Lorentzian gap** becomes an **information contraction coefficient**
- **Negative curvature** becomes **pairwise information suppression**
- **Geometric steepness** becomes **entropy stability under projection**

This is not a metaphor. It is a precise mathematical dictionary, backed by rigorous theorems.

## Bounding What Variables Can Know About Each Other

The most striking result concerns *mutual information* — the standard measure of how much two random variables share in common. If you flip two independent coins, the mutual information is zero: knowing one tells you nothing about the other. If you flip the same coin twice, the mutual information is maximal: they're identical.

For a robustly Lorentzian distribution with gap ε, the mutual information between any two coordinate indicators — "is item *i* selected?" and "is item *j* selected?" — is bounded above by a quantity that depends only on ε and the marginal probabilities. Specifically, the bound goes through a *chi-squared divergence*, which measures how far the joint distribution of the pair deviates from independence.

The mathematical chain is elegant:

1. The Lorentzian gap bounds the covariance: |Cov(Xᵢ, Xⱼ)| ≤ ε · pᵢ · pⱼ
2. The covariance bounds the chi-squared divergence: χ² = Cov² / (variance₁ · variance₂)
3. The chi-squared divergence bounds the mutual information: I ≤ χ²

Each step is a different kind of mathematical inequality, and each was proved with a different technique. But they compose into a single pipeline: **geometry → algebra → information theory**.

## The Susceptibility Theorem

In statistical physics, *susceptibility* measures how a system responds to external perturbations. If you apply a small magnetic field to a collection of spins, the susceptibility tells you how much the average magnetization changes. In an anti-ferromagnet — where neighboring spins prefer to point in opposite directions — the susceptibility is small, because the system resists being pushed in any one direction.

The framework proves that robust Lorentzian distributions behave exactly like anti-ferromagnets. The *spin susceptibility* — defined as the total magnitude of all pairwise covariances — is bounded by ε · n², where n is the number of coordinates. This means the system's total correlation budget is limited: you can't have strong correlations everywhere.

This has a beautiful physical interpretation. The Lorentzian gap acts as a *repulsive curvature*, preventing the distribution from developing long-range order. Each pair of coordinates might be slightly correlated, but the total amount of correlation across the entire system is controlled. It's as if the geometry of the distribution imposes a tax on correlations: the more you concentrate correlation between one pair, the less is available for others.

## Entropy That Survives Deletion

Perhaps the most practically important result concerns *projection stability*. Suppose you have a probability distribution on subsets of six items, and you decide to ignore one item — say, you delete coordinate 3 from every subset. How much entropy do you lose?

For an arbitrary distribution, the answer could be catastrophic: you might lose almost all your entropy. But for robustly Lorentzian distributions, the entropy loss is bounded. The gap parameter ε guarantees that deleting any single coordinate reduces entropy by at most a logarithmic amount.

This has immediate implications for data privacy. If a database uses a negatively dependent selection mechanism, then removing one attribute from the released data preserves most of the uncertainty in the remaining attributes. The deletion acts as a mild privacy mechanism, and the Lorentzian gap provides a certified guarantee of how much uncertainty is retained.

## A New Dictionary Between Geometry and Information

What makes this work revolutionary is not any single theorem but the *dictionary* it establishes. For decades, mathematicians have studied Lorentzian polynomials from a geometric perspective and Shannon entropy from an information-theoretic perspective. These were different worlds, with different techniques and different intuitions.

The new framework shows they are shadows of the same structure. When you look at a Lorentzian distribution through geometric eyes, you see curvature. When you look at it through information-theoretic eyes, you see entropy bounds. When you look at it through the lens of physics, you see anti-ferromagnetic susceptibility. They're all the same phenomenon, viewed from different angles.

The Fisher information bound — which says that the total system response (diagonal variance plus off-diagonal susceptibility) is bounded by a quantity determined by the Lorentzian gap — is the clearest expression of this unity. It connects:

- **Geometry:** the curvature gap of the generating polynomial
- **Information theory:** the total mutual information budget
- **Statistical mechanics:** the magnetic susceptibility
- **Communication complexity:** the information cost of distributed protocols

## Why This Matters Beyond Pure Mathematics

The implications extend far beyond the blackboard. In machine learning, negatively dependent distributions are used for *diverse sampling* — selecting a representative subset from a large dataset. The new bounds provide certified guarantees that such samples are robust to perturbation and that removing features doesn't destroy too much structure.

In cryptography and differential privacy, the entropy retention theorem provides a new tool for analyzing privacy mechanisms. If a mechanism samples subsets according to a Lorentzian distribution, the gap parameter directly certifies how much privacy is preserved when coordinates are revealed or deleted.

In statistical mechanics and materials science, the susceptibility bounds provide a rigorous framework for understanding why certain repulsive systems resist ordering. The Lorentzian gap is a new order parameter that quantifies the strength of anti-ferromagnetic coupling.

And in communication complexity — the study of how much information must be exchanged to solve distributed problems — the mutual information bounds provide tight constraints on the cost of protocols that operate on negatively dependent inputs.

## The Road Ahead

The framework opens several tantalizing directions. Can the entropy bounds be sharpened from logarithmic to constant? Is there a Shearer-type inequality that decomposes entropy across arbitrary coverings, with corrections controlled by the Lorentzian gap? Can the geometric-information dictionary be extended to continuous distributions, or to distributions with more complex dependence structures?

Computational experiments suggest that the true behavior is even better than the proved bounds. For uniform matroid distributions, the mutual information between coordinate pairs appears to scale as log(1 + 1/ε) rather than the proved 1/ε bound. If this logarithmic scaling can be established, it would tighten the dictionary further and open connections to coding theory and channel capacity.

The deepest question is whether this is the beginning of a new field: *discrete Hodge-information theory*, where algebraic negativity statements systematically imply information-theoretic inequalities. The results so far suggest that wherever negative dependence appears — in matroids, determinantal point processes, strongly Rayleigh distributions, and beyond — there is a hidden information geometry waiting to be uncovered.

What started as a curiosity about dinner party seating has become a window into the deep structure of randomness itself. The message is clear: geometry doesn't just constrain shape. It constrains information. And the curvature of a probability distribution — measured by its Lorentzian gap — determines exactly how much any part of the system can know about any other part.

That is not merely a theorem. It is a new way of seeing.
