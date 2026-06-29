# The Hidden Geometry of AI Pruning

## How an obscure branch of tropical mathematics reveals which parts of a neural network actually matter

---

Imagine you've hired twenty advisors to help you make decisions. Each one gives you a number—their assessment of a situation—and you always go with the highest. After watching them for a while, you notice something: advisor number seven never wins. Every time she speaks up, someone else has already given a higher number. She's not wrong, exactly. She's just perpetually outbid.

Should you fire her?

The answer might seem obvious: yes, of course. But consider: maybe she's never outbid because she happens to agree with advisor twelve, and twelve is always slightly more enthusiastic. If you fire twelve instead, suddenly seven becomes essential. The question of who matters isn't about individual performance—it's about *collective redundancy*. And making the wrong cut could change your decisions entirely.

This is precisely the problem facing anyone who wants to shrink an artificial intelligence system. Modern neural networks have millions or billions of parameters, and a growing body of evidence suggests that many of them are doing nothing useful. But which ones? Cut the wrong weights and the network's behavior changes. Cut the right ones and you get an identical system that's smaller, faster, and cheaper to run.

A new mathematical framework, drawing on a surprising corner of algebra called *tropical geometry*, has cracked this problem open—at least for an important class of neural networks. The result is not an approximation, not a heuristic, not a "works pretty well in practice" engineering trick. It is a *theorem*: a mathematical guarantee that certain components of a network can be removed with zero change to its outputs. Period. Full stop. Provably.

---

## The Algebra of Maximums

To understand how, we need to take a detour through one of mathematics' stranger neighborhoods.

Ordinary algebra concerns itself with addition and multiplication. Tropical algebra replaces these operations with something that sounds absurd: instead of adding numbers, you take their maximum. Instead of multiplying them, you add them. So in this upside-down world, "2 plus 3" equals 3 (the larger of the two), and "2 times 3" equals 5 (their ordinary sum).

This isn't mathematical whimsy. Tropical algebra, named after the Brazilian mathematician Imre Simon (with a nod to tropical latitudes), turns out to be a powerful lens for studying optimization, combinatorics, and—crucially—the geometry of piecewise-linear functions.

Why does this matter for AI? Because the most popular activation function in deep learning, the ReLU (Rectified Linear Unit), computes exactly `max(x, 0)`. A neural network built from ReLU activations doesn't compute smooth curves—it computes *piecewise-linear* functions, surfaces made of flat facets joined at angles like a crystal. And the mathematics of such functions is precisely the mathematics of tropical polynomials.

A tropical polynomial in this context is simply a collection of linear formulas, evaluated by taking the maximum:

> f(x) = max(formula₁(x), formula₂(x), ..., formulaₖ(x))

Each formula is an *affine template*—a straight-line recipe like "2 times the first input plus 3 times the second input minus 1." The tropical polynomial picks the highest-scoring template at each point, creating a piecewise-linear landscape.

This is exactly what a single layer of a ReLU network computes. The connection is not metaphorical. It is a mathematical identity.

---

## The Pruning Theorem

Here's the key insight. Suppose one of those templates—call it template A—always scores lower than template B at every data point you care about. Then template A never wins the maximum. Removing it changes nothing.

But there's a subtlety that took careful mathematical work to resolve. What does "always lower" really mean?

The obvious definition—A scores less than or equal to B at every point—turns out to be *wrong* for pruning. The reason is almost paradoxical. Two templates can score identically at every data point while being completely different mathematical formulas. Under the "less than or equal" rule, each one dominates the other, and both get removed. Now your pruned network is missing essential pieces.

The correct definition uses *strict* domination: template A is redundant if there exists a template B that scores at least as high at every data point, and *strictly* higher at some data point. This prevents the mutual-annihilation problem. If A and B score identically everywhere, neither strictly dominates the other, and both survive.

With this definition in hand, the theorem states:

> **Canonical Pruning Preservation.** Removing all strictly dominated templates from a tropical polynomial does not change its value at any point in the domain.

The proof works by chasing chains. Suppose you remove template A because it's dominated by B. Now suppose B is also dominated by some template C. Does A's removal still preserve the output? Yes, because at any point, A's score is below B's, which is below C's. If C survives (is not dominated), then C's score is at least as high as A's was, so the maximum doesn't change. And strict domination is *acyclic*—you can't have A dominated by B dominated by C dominated by A, because that would require A ≤ B ≤ C ≤ A everywhere (so they're all equal) yet A < B somewhere (contradicting equality). In a finite set with an acyclic dominance relation, every chain leads to an undominated survivor.

---

## What Survives Is What Matters

The pruning theorem tells us what we can safely remove. But the flip side is arguably more exciting: it tells us what *must* stay.

A template survives canonical pruning if and only if it's *not* strictly dominated. And the strongest survival guarantee comes from uniqueness: if a template is the *unique* winner at some data point—scoring strictly higher than every other template—then no other template can dominate it, because at that data point, the would-be dominator would have to score at least as high, which it can't.

These uniquely-winning templates are the *essential decision templates*. Each one has a witness: a specific input where it, and it alone, determines the network's output. This is a form of mathematical interpretability that goes far beyond the usual techniques of saliency maps and gradient analysis.

When you canonically prune a network and look at what remains, you're looking at the minimal set of linear rules the network actually uses. Each rule comes with a natural-language explanation: "At this kind of input, the network's decision is determined by this weighted combination of features." The pruned monomials are the noise—the architectural scaffolding that contributes nothing to the final computation.

---

## From Theory to Practice

The compression ratios achieved by tropical pruning depend on how much redundancy exists in the network. In experiments with random max-affine networks—the kind that arise from random weight initialization—pruning typically removes 10% to 40% of templates while preserving outputs exactly on the training domain.

But the real power lies in certification. Unlike magnitude pruning (removing small weights), lottery ticket approaches (searching for sparse subnetworks), or knowledge distillation (training a smaller student network), tropical pruning comes with a *guarantee*. The pruned network doesn't approximately match the original. It matches exactly, on every point in the certified domain.

This distinction matters enormously for safety-critical applications. If you're deploying a neural network to control a medical device, an autonomous vehicle, or a financial system, "approximately the same" is not good enough. You need to know that your compressed model makes *identical* decisions on every input in the operating domain. Tropical pruning provides this.

---

## The Bigger Picture

The connection between tropical geometry and neural networks is just beginning to be explored, and the implications extend far beyond compression.

The *tropical complexity* of a network—the number of templates that survive canonical pruning—is a new kind of invariant. It measures not how many parameters a network has, but how many distinct decision strategies it actually deploys. Two networks with very different architectures might have the same tropical complexity, meaning they're semantically equivalent in a precise mathematical sense.

This opens the door to a new theory of network comparison. Instead of comparing architectures by their structure (number of layers, width, activation functions), we could compare them by their tropical complexity: how many essential affine pieces does their decision surface actually need?

Looking further ahead, tropical pruning connects to deep questions in convex geometry. A tropical polynomial's upper envelope—the surface you see when you plot the maximum of all the templates—is a convex piecewise-linear function. Its structure is determined by a polytope, and canonicalization corresponds to finding the minimal representation of that polytope. This links neural network compression to classical problems about polyhedra that mathematicians have studied for centuries.

There's even a connection to logic. In the tropical world, taking the maximum of two values plays the role of logical OR: the output is "high" if at least one input is "high." Each template acts like a clause in a logical formula, and canonical pruning is a form of clause minimization—removing logical conditions that are implied by others. This suggests that tropical methods could eventually contribute to symbolic distillation: extracting human-readable logical rules from trained neural networks.

---

## A New Interface

For decades, the fields of algebraic geometry and machine learning have largely ignored each other. Algebraic geometers study abstract structures—varieties, schemes, sheaves—that seem impossibly removed from the practical concerns of training neural networks on data. Machine learning researchers, conversely, have focused on optimization, statistics, and scalability, with little interest in the kind of structural algebra that tropical geometry provides.

The pruning theorems established here represent a genuine interface between these worlds. They show that a fundamental operation in machine learning—deciding which parts of a trained network to keep—has a rigorous algebraic characterization. The "best" parts to keep aren't the ones with the largest weights or the highest gradients. They're the ones that tropical algebra identifies as structurally essential.

This is the kind of result that creates new fields rather than extending old ones. It suggests that behind the empirical successes of neural network compression lies a mathematical theory waiting to be fully developed—a theory where pruning is not a heuristic but a theorem, interpretation is not post-hoc but structural, and the complexity of a model is measured not by its size but by its semantic geometry.

The twenty advisors, it turns out, have a hidden geometric structure. Tropical algebra reveals it. And that revelation might just change how we think about artificial intelligence.
