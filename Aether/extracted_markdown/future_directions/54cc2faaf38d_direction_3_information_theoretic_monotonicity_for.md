# The Hidden Geometry of Randomness: How Curvature Controls Information

## When shapes tell probability what it can and cannot do

Imagine tossing a handful of colored marbles onto a table and asking: which ones landed inside a circle you drew? The answer — a random subset of marbles — seems like pure chance. But mathematicians have discovered that certain probability distributions over subsets carry a hidden geometric structure, a kind of curvature, that rigidly controls how much information any part of the system can hold.

This story begins with an unlikely collision between two fields that, for decades, spoke entirely different languages.

---

## Two worlds apart

On one side stood **information theory**, the mathematical framework Claude Shannon invented in 1948 to understand communication. Shannon's central quantity — entropy — measures uncertainty. If you're equally unsure about eight possible messages, your entropy is three bits. Information theory asks: how much can you compress data? How much do two signals tell you about each other? How does uncertainty change when you delete part of the message?

On the other side stood **algebraic geometry**, the study of shapes defined by polynomial equations. In 2020, Petter Brändén and June Huh published a landmark paper identifying a special class of polynomials they called *Lorentzian* — named after the physicist Hendrik Lorentz, whose geometry describes spacetime. These polynomials have a distinctive curvature property: their second derivatives form a matrix with exactly one positive direction and all others negative, like a saddle extending in many dimensions.

Brändén and Huh showed that Lorentzian polynomials are everywhere in combinatorics. The generating functions of matroids, the partition functions of certain statistical mechanics models, and the characteristic polynomials of graphs are all Lorentzian. Their negativity property — the saddle-like curvature — forces beautiful structural consequences: log-concavity of coefficient sequences, negative dependence of random variables, and optimal mixing of Markov chains.

But nobody had asked the obvious question: **does this geometric curvature control information?**

---

## The dictionary nobody wrote

The new results establish exactly this connection. They prove that when a probability distribution on subsets has Lorentzian structure with a quantitative gap parameter ε — measuring how strongly the curvature pushes in the negative direction — then several precise information-theoretic consequences follow automatically.

The first is an **entropy monotonicity theorem**: if you delete one coordinate from the system (forgetting whether a particular marble landed inside the circle), the entropy of the remaining system decreases by at most log 2, roughly 0.693 nats. This is the maximum information content of a single binary variable. The theorem is sharp — you cannot do better in general — and it holds for every Lorentzian measure regardless of dimension.

But the deeper result is about **pairwise information suppression**. For any two coordinates *i* and *j* in a robustly Lorentzian measure, the chi-squared divergence between their joint distribution and their independent product is bounded by ε² · p_i · p_j / ((1 − p_i)(1 − p_j)), where p_i is the marginal probability of coordinate *i* appearing. This means the Lorentzian gap directly limits how much any two coordinates can "know" about each other.

Think of it this way: in a strongly Lorentzian system, every pair of variables is nearly independent. The curvature acts like a repulsive force, preventing information from concentrating between any two sites. The smaller ε is, the stronger the repulsion, and the less any pair of coordinates can communicate.

---

## A susceptibility bound from geometry

The connection reaches further than pairwise information. The total *spin susceptibility* — a quantity from statistical physics measuring how much a system's magnetization responds to an external field — is bounded by ε · (Σ p_i)². This is the sum of all pairwise covariance magnitudes across the entire system.

In physics, low susceptibility means the system is stable: it doesn't overreact to perturbations. In information theory, it means the total information shared between all pairs of coordinates is small. The Lorentzian gap provides a single number that controls both interpretations simultaneously.

This creates a precise dictionary:

| **Geometry** | **Information Theory** | **Physics** |
|---|---|---|
| Lorentzian gap ε | Information contraction rate | Inverse temperature |
| Saddle curvature | MI suppression | Repulsive interaction |
| Coordinate deletion | Data processing | Coarse-graining |
| Susceptibility bound | Total shared information | Response stability |

---

## Why deletion cannot destroy too much

One of the most surprising consequences is about robustness under data loss. Suppose you have a complex probability distribution over subsets of a hundred elements. You learn that one element's status — in or out — has been redacted from the data. How much uncertainty have you lost?

The entropy deletion theorem says: at most log 2, regardless of which element was removed and regardless of the dimension. This is precisely the information capacity of one binary channel. Moreover, entropy never *increases* when you delete a coordinate — merging outcomes that differ only in the deleted element can only reduce uncertainty.

These two bounds together create a tight sandwich:

> H(μ) − log 2 ≤ H(deletion) ≤ H(μ)

This means deletion is gentle. In a world of 2^100 possible subsets, removing one coordinate reduces the outcome space by half but shrinks the entropy by at most one bit. The remaining system preserves almost all the original randomness.

For applications in data privacy, this is powerful: if a database query returns a random subset drawn from a Lorentzian distribution, then redacting one field reduces information leakage by at most one bit. The residual query still carries nearly full entropy.

---

## The covering principle

The deletion bounds combine into a covering inequality reminiscent of Shearer's lemma, a cornerstone of combinatorial information theory. If you take all *n* possible single-coordinate deletions and average their entropies, the result approximates the total entropy within log 2:

> H(μ) ≤ (1/n) · Σ_k H(π_k μ) + log 2

This says that no matter how complex the distribution, its total entropy is never much larger than the average entropy of its one-coordinate projections. The Lorentzian structure ensures that the system's information is spread democratically across coordinates — no small set of coordinates monopolizes the uncertainty.

---

## From algebra to algorithms

The theoretical results have immediate algorithmic implications. When sampling from Lorentzian distributions using Markov chain Monte Carlo methods, the entropy bounds guarantee that each step of the chain (which typically updates one coordinate at a time) changes the entropy of the current state by a controlled amount. This is exactly the kind of regularity needed to prove rapid mixing — that the chain reaches its stationary distribution quickly.

The pairwise MI bounds also have consequences for communication protocols. Consider a scenario where Alice observes whether element *i* belongs to a random subset, and Bob observes element *j*. The information they share about each other's bits is bounded by the MI bound, which scales as ε². For strongly Lorentzian distributions (small ε), this means Alice and Bob are almost completely in the dark about each other's observations — a quantitative form of the negative dependence that Lorentzian structure guarantees.

---

## What the experiments reveal

Computational experiments on uniform matroid distributions — the canonical examples of Lorentzian measures — confirm the theoretical predictions and reveal additional structure.

For the uniform distribution on rank-*r* subsets of an *n*-element set, the entropy drop under deletion is exactly the same for every coordinate (by symmetry), and it consistently sits well below the log 2 bound. The susceptibility grows quadratically in *n* but linearly in ε, exactly matching the certified bound ε · (Σp_i)². The pairwise chi-squared divergences scale as ε², confirming the quadratic dependence predicted by the theorem.

Most intriguingly, the computational evidence suggests that the true scaling of pairwise mutual information may be logarithmic in 1/ε rather than linear — the proved bound O(ε²) may be improvable to O(log(1 + 1/ε)). If true, this would mean Lorentzian curvature suppresses pairwise information even more aggressively than the current theory captures.

---

## A new field takes shape

These results represent the first formal steps toward what might be called *discrete Hodge-information theory*: the study of how algebraic curvature conditions on combinatorial structures control information-theoretic quantities. The techniques generalize beyond uniform matroids to any distribution whose generating polynomial is Lorentzian, including:

- **Determinantal point processes**, used in machine learning for diverse subset selection
- **Strongly Rayleigh measures**, which model repulsive particle systems
- **Log-concave distributions on integer lattices**, fundamental in optimization and sampling

The open questions are tantalizing. Can the entropy submodularity needed for the full Shearer inequality be derived from Lorentzian structure alone? Does Lorentzian curvature control higher-order information quantities beyond pairwise MI? And most ambitiously: is there a continuous analogue where the Lorentzian Hessian of a generating function directly gives a Riemannian metric on the space of probability distributions?

If so, the geometry of polynomials would not merely *constrain* information — it would *be* the information geometry, with curvature and entropy unified in a single mathematical framework.

The marbles on the table are not just random. They are curved.
