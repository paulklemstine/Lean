# The Mathematics of Forgetting: How Every Transformation Has an Entropy Price

*When a function throws away information, how much does it lose? A new theory reveals that the answer connects abstract algebra to the physics of heat.*

---

In 1961, the physicist Rolf Landauer made a startling claim: erasing a single bit of information — flipping a switch from "1" to "unknown" — must release a tiny but unavoidable burst of heat. It was a bridge between the abstract world of information and the concrete world of thermodynamics, and for decades, physicists debated whether it was really true. In 2012, a team of French scientists finally confirmed it experimentally, trapping a microscopic bead in a double-welled potential and watching it dissipate exactly the predicted amount of energy when forced to "forget."

But Landauer's insight raised a deeper question. We know that erasing a bit costs energy. But what about the vast landscape of operations *between* total preservation and total erasure? When a function maps ten inputs to five outputs, or when a database query drops half its columns, or when a neural network's activation function crushes negative numbers to zero — how much information, exactly, has been destroyed?

A new mathematical framework provides a precise, universal answer. It is called **functorial entropy**, and it reveals that every function between finite sets carries a hidden number — a measure of its information destruction — that connects pure mathematics to physics, computer science, and data engineering in surprisingly concrete ways.

## The Fibers of a Function

To understand functorial entropy, you need to understand **fibers**. Consider a simple function that maps the numbers {1, 2, 3, 4, 5, 6} to their remainders when divided by 3. The number 1 maps to 1. The number 2 maps to 2. The number 3 maps to 0. And so on: 4 maps to 1, 5 maps to 2, 6 maps to 0.

Now look at the function from the output side. The output "0" has two inputs that map to it: 3 and 6. The output "1" also has two inputs: 1 and 4. And "2" has two inputs: 2 and 5. These sets of inputs that all land on the same output are called **fibers** — they are the "threads" that the function weaves together.

An injective function — one that never maps two different inputs to the same output — has fibers that are all singletons: each output has exactly one input. No information is lost. A constant function, which maps every input to the same output, has a single gigantic fiber containing everything. All information is destroyed.

Most functions live somewhere in between, and their fibers tell the story of exactly how they forget.

## Measuring the Forgetting

The functorial entropy of a function $f$ is defined by looking at the sizes of its fibers. If $f$ maps a set of $n$ elements to some codomain, and the fiber over an output $b$ has size $k_b$, then the entropy is:

$$H(f) = \sum_b \frac{k_b}{n} \cdot \ln(k_b)$$

Each fiber of size 1 contributes nothing — no information was lost there. Each fiber of size 2 contributes $\frac{2}{n} \cdot \ln 2$ — those two inputs have been merged, and $\ln 2$ measures the "cost" of that merge. Larger fibers contribute more, and the contributions grow logarithmically.

The name "functorial" comes from category theory, the branch of mathematics that studies the structure of mathematical structures themselves. In category theory, a **functor** is a mapping between categories that preserves their structural relationships. The key idea is that every functor acts like a function on objects, potentially identifying objects that were originally distinct. The entropy measures this identification.

## The Zero Theorem

The central result of the theory is what might be called the **Zero Theorem**: the functorial entropy of a function is zero if and only if the function is injective.

This statement has two directions, and they carry very different mathematical weight. The "easy" direction says: if a function is injective, then every fiber has size 0 or 1, so every term in the sum is zero, so the entropy is zero. That is nearly tautological.

The "hard" direction is where the mathematics bites. Suppose the entropy is zero. Each term in the sum is non-negative — fiber sizes are at least 1 (for nonempty fibers), so $\ln(k_b) \geq 0$, and the coefficient $k_b/n$ is positive. A sum of non-negative terms can only be zero if every term is zero. For a nonempty fiber, $k_b/n > 0$, so $\ln(k_b) = 0$, so $k_b = 1$.

The argument has a beautiful structure: it uses the non-negativity of the entropy (which comes from the concavity of the logarithm) to force a discrete, algebraic conclusion (injectivity) from a continuous, analytic hypothesis (zero entropy). The analytic and algebraic worlds shake hands.

## The Uniform Fiber Formula

When a function has particularly clean structure — when every nonempty fiber has the same size $k$ — the entropy simplifies dramatically. Instead of summing over all fibers, you get a single, elegant formula:

$$H(f) = \ln(k)$$

This is the categorified version of the classical Shannon formula. If you have a uniformly distributed random variable taking $n$ values, its entropy is $\ln(n)$. The functorial entropy says: when a function uniformly collapses $k$ inputs to each output, the information loss is $\ln(k)$, regardless of the total size of the domain.

The modular arithmetic function "remainder mod 3" on {1,...,6} has uniform fibers of size 2, so its entropy is $\ln 2 \approx 0.693$. A function mapping 12 elements uniformly to 4 outputs has fibers of size 3 and entropy $\ln 3 \approx 1.099$.

## The Landauer Bridge

Here is where the theory leaps from mathematics into physics.

Landauer's principle says that erasing one bit of information at temperature $T$ requires dissipating at least $kT \ln 2$ joules of energy, where $k$ is Boltzmann's constant. The functorial entropy generalizes this: the minimum energy cost of performing a computation $f$ is $kT \cdot H(f)$.

This creates a precise bridge:

- **H(f) = 0**: The computation is reversible. No heat is produced. You can run it forward and backward with no thermodynamic penalty. This is the domain of quantum computing and reversible logic.
  
- **H(f) > 0**: The computation is irreversible. Information has been destroyed, and thermodynamics demands a payment in heat. The amount is proportional to the entropy, and nothing in the universe can reduce it below $kT \cdot H(f)$.

At room temperature (300 K), $kT \approx 4.14 \times 10^{-21}$ joules. Erasing 8 bits (256 states down to 1) costs at least $kT \cdot \ln(256) = kT \cdot 8 \ln 2 \approx 2.30 \times 10^{-20}$ joules. Modern computers dissipate millions of times more than this, but the Landauer limit is a hard physical floor — and as computing approaches nanoscale and quantum regimes, it becomes increasingly relevant.

## The Information Channel

The theory naturally gives rise to a new mathematical structure: the **information channel**. An information channel is a function paired with its entropy — a morphism that "knows" how much information it destroys. You can compose channels, forming an algebra of information loss.

A channel is called **lossless** when its entropy is zero, which happens precisely when its underlying function is injective. The language invites computation to think of every operation not just as a transformation of data, but as a process with a measurable information cost.

## Applications: Hash Functions, Databases, and Neural Networks

The theory is not merely abstract. Consider a hash function that maps 1,000 keys to 100 buckets. A good hash (say, $x \bmod 100$) distributes keys uniformly, giving entropy $\ln(10) \approx 2.30$ — each bucket contains 10 keys, and that 10-fold collapse is the unavoidable cost of hashing. A poorly designed hash that clusters keys might have entropy 3.87 — nearly 70% more information destroyed, and the extra collisions that result are a direct measure of its failure.

In databases, a query like `SELECT department FROM employees` is a projection — a function from rows to department values. Its functorial entropy measures exactly how much information the query throws away. A projection to a unique key has entropy zero. A projection to a low-cardinality column has high entropy. Database engineers intuitively know this; functorial entropy makes it precise.

Neural networks offer perhaps the most surprising application. Each activation function is a map from inputs to outputs, and its functorial entropy quantifies the information bottleneck it creates. The identity function (used in skip connections) has zero entropy — it preserves everything. ReLU, which maps all negative values to zero, has significant entropy. The sign function, which collapses all values to {-1, 0, 1}, has enormous entropy. The information-theoretic properties of neural architectures are written in the entropies of their layers.

## The Composition Conjecture

One tantalizing open question remains. When you compose two functions — first applying $f$, then $g$ — does the information loss always increase? More precisely, if $f$ is surjective (every output has at least one input), is $H(g \circ f) \geq H(g)$?

Intuitively, this should be true: passing data through a surjective function before applying $g$ should only increase the total information destruction. Computational experiments confirm the conjecture for all tested cases, but a rigorous proof remains elusive. The difficulty lies in the nonlinearity of the logarithm: the fibers of $g \circ f$ are unions of fibers of $f$, but the entropy of the union is not simply the sum of the entropies.

## What It All Means

Functorial entropy reveals that information loss is not a vague, qualitative concept but a precise, quantitative invariant. Every function — whether it is a mathematical transformation, a physical process, a database query, or a neural network layer — carries a specific entropy that measures its information destruction.

The theory connects category theory (the study of mathematical structure) to information theory (the study of communication) to thermodynamics (the study of energy and heat). It suggests that entropy is not just a property of probability distributions, as Shannon originally formulated it, but a fundamental property of *maps* — of the relationships between mathematical objects.

In a world increasingly concerned with data, privacy, and the limits of computation, understanding the precise mathematics of forgetting is not merely an intellectual exercise. It is a lens through which we can see the deep structure of every process that transforms information — and the unavoidable price that information destruction demands from the physical universe.

The mathematics of forgetting turns out to be unforgettable.
