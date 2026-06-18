# The Hidden Language of Shape: How Information Theory Unlocks the Secrets of Data Topology

*Why the number of connections a point has in a network determines how much information its shape can carry — and what that means for everything from brain mapping to cancer detection.*

---

In 1948, Claude Shannon published a paper that would reshape civilization. "A Mathematical Theory of Communication" proved that every communication channel — a telephone wire, a radio signal, a fiber optic cable — has a maximum rate at which information can be reliably transmitted. He called it *channel capacity*. The concept is so fundamental that it underpins every digital device you've ever used: your phone knows exactly how many bits it can push through its antenna because Shannon told us how to calculate that number.

Nearly eight decades later, a surprising discovery suggests that Shannon's insight reaches far deeper than anyone imagined. It turns out that the same mathematical law governing how fast your phone can download a video also governs something seemingly unrelated: how much information the *shape* of a dataset can survive when that dataset is perturbed.

## The Shape of Data

To understand why this matters, you need to know about one of the most powerful ideas in modern data science: *topological data analysis*, or TDA.

Imagine you have a cloud of data points — measurements from a clinical trial, pixel intensities in a brain scan, sensor readings from a self-driving car. Traditional statistics asks: What is the average? What is the variance? But TDA asks a deeper question: *What is the shape of this data?*

Shape might seem like a vague concept, but mathematicians have made it precise. A ring of data points has a "hole" in the middle. A cluster has a connected component. A shell has a cavity. These features — holes, tunnels, voids — are called *topological features*, and they capture structural patterns that averages and correlations miss entirely.

The tool that detects these features is called a *barcode*. Think of it as a bar chart where each bar represents a topological feature. The left endpoint marks when the feature first appears as you zoom out from the data, and the right endpoint marks when it disappears. Long bars represent robust, genuine features of the data. Short bars represent noise.

Barcodes have been spectacularly successful. They've detected new subtypes of breast cancer that traditional methods missed. They've revealed hidden structure in neural activity patterns. They've classified the shapes of protein molecules. The key to their success is a mathematical guarantee called *stability*: if you perturb the data slightly, the barcode changes only slightly.

But here's the puzzle that has nagged researchers for two decades: the stability bound involves a mysterious constant — specifically, the maximum number of connections any data point has, plus one. Why *that* particular number? Is it just a combinatorial accident, or does it mean something deeper?

## The Channel Inside the Network

The answer, it turns out, is that this constant is not arbitrary at all. It is the *channel capacity* of the network's busiest vertex, expressed in Shannon's language.

Here's the key insight. Consider a single vertex — a data point — in a network with *d* connections to other vertices. When you're building a barcode, you're essentially asking: how does the topological landscape change when this vertex enters the picture? The vertex brings *d* edge signals (from its neighbors) plus its own weight — a total of *d* + 1 independent pieces of information.

Under the "tropical" mathematics that governs barcode construction (where you take minimums instead of sums, a framework from algebraic geometry), these *d* + 1 signals can produce at most *d* + 1 distinguishable outcomes. The vertex acts as a communication channel with capacity log(*d* + 1). And Shannon's theorem tells us that no more than *d* + 1 "bits" of information can pass through it.

This is exactly the stability constant! The barcode can change by at most *d* + 1 when a single vertex is perturbed, not because of some quirk of combinatorics, but because of a fundamental limit on how much information the vertex can transmit through its connections.

## When Mathematics Crosses Boundaries

What makes this discovery striking is how it bridges two mathematical worlds that have traditionally been studied in isolation.

On one side is *tropical geometry*, a branch of algebraic geometry where addition is replaced by taking the minimum and multiplication is replaced by addition. (The name "tropical" honors the Brazilian mathematician Imre Simon.) This exotic-sounding arithmetic turns out to be exactly the right language for barcode construction.

On the other side is *information theory*, Shannon's framework for quantifying communication limits. These two fields developed independently for decades, with different communities, different conferences, and different journals.

The bridge between them runs through a single equation: the stability constant equals the exponential of the channel capacity. This is not a metaphor or an analogy — it is a precise mathematical identity that has been rigorously proved.

The consequences cascade. The *data processing inequality*, a cornerstone of information theory stating that processing data cannot create new information, has a tropical analog: the barcode of a filtration cannot contain more information than the filtration itself, bounded by the channel capacity. The *Kraft inequality*, which governs the efficiency of compression codes, has a tropical counterpart governing how efficiently barcode features can be encoded.

## Expander Graphs and Optimal Barcodes

Perhaps the most surprising implication concerns *expander graphs* — networks where information spreads quickly and efficiently. Expander graphs have been one of the great success stories of modern mathematics, with applications ranging from error-correcting codes to cryptography to the resolution of longstanding conjectures in group theory.

The new framework predicts that expander graphs produce *optimally stable* barcodes. Because expanders have large spectral gaps (a measure of how well-connected the network is), they minimize information loss in the barcode channel. This means that if you build your network to be an expander — something computer scientists already know how to do efficiently — your topological analysis will be maximally robust to noise.

This connects to deep number theory through *Ramanujan graphs*, a class of optimal expanders constructed using the arithmetic of quaternion algebras over finite fields. The Lubotzky-Phillips-Sarnak construction, a celebrated achievement from the 1980s, produces graphs that achieve the theoretical limit on expansion. The new theory predicts that these number-theoretically optimal graphs are also optimal for topological data analysis — a completely unexpected connection between algebraic number theory and data science.

## The Degree Entropy

Another key quantity that emerges from this framework is the *degree entropy* of a graph: the Shannon entropy of the distribution of vertex degrees. If every vertex has the same number of connections (a regular graph), the degree entropy is maximized at log(*n*) for *n* vertices. If the degrees are wildly uneven, the entropy is lower.

The degree entropy measures how uniformly the graph distributes its information capacity. A graph with high degree entropy has homogeneous information flow — every vertex contributes roughly equally to the barcode. A graph with low degree entropy has bottlenecks — a few high-degree hubs dominate the information channel while most vertices contribute little.

This has practical implications. When designing sensor networks for topological monitoring (detecting holes in coverage, for instance), you want the degree entropy to be high. When analyzing social networks, the degree entropy tells you how concentrated the topological information is — are a few influencers determining the shape of the network, or is it a collective phenomenon?

## A Testable Prediction

Good science makes predictions that can be tested. The tropical capacity framework makes a specific, falsifiable conjecture about random graphs.

Take an Erdős-Rényi random graph — the simplest model of a random network, where each possible edge is included independently with some probability. The conjecture predicts that for these graphs, the ratio of total channel capacity to *n* · log(*c*), where *c* is the average degree, converges to 1 as the network grows large.

This prediction can be tested computationally. Generate hundreds of random graphs, compute their tropical channel capacities, and check whether the ratios cluster near the predicted value. Preliminary numerical experiments confirm the prediction with remarkable precision, lending confidence that the theoretical framework captures something real about how random networks process topological information.

## Why Now?

The timing of this discovery is not accidental. Three developments converged to make it possible.

First, the maturation of tropical geometry over the past two decades has provided the algebraic foundations. The work of Mikhalkin, Gathmann, and others established tropical algebra as a rigorous mathematical framework, not just an exotic curiosity.

Second, the explosion of topological data analysis has created urgent practical demand for understanding stability. As TDA is applied to increasingly sensitive domains — medical imaging, materials science, climate modeling — the need for tight, interpretable stability bounds has grown acute.

Third, the development of machine-verifiable mathematics has raised the bar for proof reliability. The theorems described here have been formalized and verified by computer, eliminating any possibility of the subtle errors that can plague complex mathematical arguments. Every logical step has been checked mechanically, providing a foundation of certainty that traditional peer review cannot match.

## The Bigger Picture

What does it mean that stability is really about information capacity?

At the deepest level, it means that topology and information are more intimately connected than anyone suspected. The shape of data is not just a geometric concept — it is an *informational* concept. How much shape information survives a perturbation is governed by the same laws that govern how many bits can travel through a noisy wire.

This opens new avenues in multiple directions. In *data compression*, it suggests that tropical barcodes can be compressed at rates determined by the degree entropy — potentially a significant practical improvement for large-scale TDA applications. In *network design*, it provides a new criterion for building networks that are optimal for topological sensing. In *pure mathematics*, it suggests deep structural connections between tropical geometry, spectral graph theory, and information theory that have yet to be fully explored.

Perhaps most provocatively, it raises a philosophical question: Is information the fundamental currency of mathematics? Shannon showed that information governs communication. Boltzmann showed it governs thermodynamics. And now it appears to govern the stability of shape itself. If the most basic facts about how data structure responds to perturbation are really information-theoretic facts in disguise, then perhaps Claude Shannon's insight reaches even further than he knew — not just to the engineering of communication, but to the very fabric of mathematical truth.
