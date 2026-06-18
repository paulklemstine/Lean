# The Shape of Compressibility: How Geometry Reveals Hidden Order in Data

## A surprising connection between stretching, squeezing, and the fundamental limits of information

---

Imagine you're handed a list of a thousand temperature readings from a weather station. The numbers might look arbitrary — 72.3, 68.1, 75.6, 71.0 — but there's a hidden regularity. Every reading falls in a narrow band, and the precision is fixed at one decimal place. Without even looking at the data's statistical distribution, you can already guarantee that it compresses efficiently. The geometric *shape* of the data tells you something profound about its information content.

This insight — that the spatial arrangement of numbers reveals their compressibility — sits at an unexpected crossroads between geometry, information theory, and the foundations of computation. Recent mathematical work has made this connection precise, establishing theorems that convert geometric structure into certified bounds on how much a dataset can be compressed.

The key concept is disarmingly simple: **affine encodability**.

## The Ruler and the Grid

Think of an affine transformation as the simplest possible adjustment you can make to a dataset: stretch it by some factor, then shift it. If you have temperatures in Fahrenheit and want Celsius, you multiply by 5/9 and subtract a constant. That's an affine transformation. It's a ruler laid alongside your data, scaled and positioned to fit.

Now comes the crucial question: after this stretching and shifting, do all your data points land exactly on the marks of a bounded integer grid?

If the answer is yes — if there exist a scale factor and an offset that map every value in your dataset to a whole number between 0 and some maximum — then something remarkable follows. You've just discovered that your data has a hidden lattice structure. And that structure is a *compressibility certificate*.

Here's why. If every data point maps to an integer between 0 and 2^k − 1 (that is, a number expressible in k binary digits), then each point needs at most k bits to describe. A dataset of n points needs at most n × k bits for the values, plus a small overhead for recording the scale factor, offset, and bit budget. The total description is dramatically shorter than what you'd need to write down the raw numbers.

This isn't a clever trick — it's a mathematical theorem. And it holds regardless of what compression algorithm you eventually choose to use.

## From Stretching to Certainty

What makes this result genuinely surprising is its universality. Most compression results depend on statistical assumptions — you need to know the probability distribution of your data, or assume it follows some model. The affine encodability approach needs none of that. It's purely geometric: if the data fits a grid after a simple linear adjustment, the compression bound follows as a mathematical certainty.

Consider the analogy of a jigsaw puzzle. If someone hands you a thousand puzzle pieces and you discover they all fit perfectly into a 10 × 100 grid, you've learned something fundamental about the puzzle's complexity — regardless of what picture is painted on the pieces. The geometry of how the pieces arrange themselves constrains the information they can carry.

The mathematical pipeline works like this:

**Step 1: Geometric test.** Check whether there exists an affine transformation (scale and shift) that maps all data values to integers within a bounded range.

**Step 2: Code length bound.** If the test passes with bit budget k, then the entire dataset of n points can be described in at most (n + 1) × k bits.

**Step 3: Entropy bound.** The dataset lives in a combinatorial space of at most (2^k)^n possible configurations. Its information entropy is therefore at most n × k bits.

Each step follows inevitably from the previous one. The geometric structure at the front end cascades through to the information-theoretic consequences at the back end.

## Order Doesn't Matter

One of the most elegant properties of affine encodability is that it doesn't care about the order of your data. Scramble the list however you like — sort it, reverse it, shuffle it randomly — and the affine encodability property is unchanged. The compression bound depends on the *collection* of values, not their arrangement.

This might seem obvious, but it's mathematically significant. Many real-world data structures carry order-dependent information — time series, sequences, sorted arrays. Affine encodability strips away this sequential structure and looks at the underlying geometry of the value set. It's asking: "What is the intrinsic complexity of these numbers, independent of how they're presented?"

The formal theorem states that if a dataset is affine encodable with bit budget k, then any permutation of that dataset is also affine encodable with the same bit budget. The proof is surprisingly clean: affine encodability is defined by a condition on *membership* — does each value satisfy the grid constraint? — and membership doesn't change under permutation.

## The Distinct Values Principle

There's another theorem hiding in the geometry. If a dataset is affine encodable with bit budget k, then it can contain at most 2^k distinct values. This follows because the affine map sends distinct data values to distinct grid points (since it has a positive scale factor, making it injective), and there are only 2^k grid points available.

This "distinct values bound" connects affine encodability to classical counting arguments in information theory. It's the geometric shadow of the pigeonhole principle: if you only have 2^k slots on the grid, you can't fit more than 2^k different values.

The beauty is that this bound is tight. A dataset with exactly 2^k evenly-spaced values achieves it perfectly — the identity transformation (scale = 1, offset = 0) places each value on its own grid point. Any additional distinct value would require expanding the grid, increasing k.

## Real-World Resonance

The applications of this framework extend far beyond abstract mathematics.

**Sensor networks.** IoT temperature sensors typically produce readings in a narrow range with fixed precision. A thermometer reading 20.1°C, 20.2°C, ..., 20.7°C has values that differ by multiples of 0.1°C. Multiplying by 10 maps everything to integers in {201, 202, ..., 207}, a grid of size 7. With k = 3 bits, you can represent each reading, achieving compression ratios of 70% or more compared to raw 12-bit ADC output.

**Financial data.** Stock prices move in discrete ticks. If prices range from $100.25 to $100.45 in penny increments, they form a grid of 21 values — representable with k = 5 bits per price. The affine structure of tick-based pricing is a formal compressibility certificate.

**Image compression.** Smooth gradients in images have low affine distortion — the pixel values change linearly across the patch. Noisy regions have high affine distortion. This geometric distinction precisely classifies which image patches are easy to compress and which are hard, providing a theoretical foundation for techniques used in JPEG and modern codecs.

**Scientific instruments.** Calibrated instruments produce data with known affine relationships to physical quantities. A thermistor whose resistance R relates to temperature T by R = 1000 + 4T produces data that is affine encodable by construction. The calibration equation is the compression certificate.

## A New Kind of Invariant

What's truly novel here is not any single theorem but the *concept* itself. Affine distortion — the minimum bit budget needed for affine encoding — is a new kind of data invariant. It's not a statistical measure like mean or variance. It's not an information-theoretic quantity like Shannon entropy. It's geometric, yet it has direct implications for both statistics and information theory.

This invariant sits at a crossroads that mathematicians have been circling for decades. In one direction, it connects to additive combinatorics — the study of arithmetic structure in finite sets. A dataset with low affine distortion has values that lie on a coarse arithmetic grid, echoing the structural theorems of Freiman and Ruzsa about sets with small sumsets. In another direction, it connects to algorithmic complexity theory — the study of the shortest programs that produce a given output.

The bridge between these fields runs through the compression pipeline. Geometric structure (affine encodability) produces short descriptions (compression), which bound algorithmic complexity (Kolmogorov complexity), which constrains information content (entropy). Each link in this chain is a theorem, and together they create a pathway from pure geometry to the foundations of information.

## The Monotonicity Principle

One more theorem deserves attention. Affine encodability is *monotone* in the bit budget: if a dataset is encodable with k bits, it's automatically encodable with k + 1 bits, k + 2 bits, and so on. This is intuitive — a larger grid always contains the smaller one — but it has a deep structural consequence.

It means that the minimum bit budget, k_min, is a well-defined single number characterizing each dataset's affine complexity. This number captures the dataset's *intrinsic resolution* — the finest grid that its structure requires. Doubling the grid size doesn't help if the data already fits the original grid; the compression bound is determined by the tightest fit.

This monotonicity also means that affine encodability defines a filtration on datasets: for each k, the class of k-bit affine encodable datasets forms a nested sequence of ever-larger families. This hierarchical structure is reminiscent of approximation theory, where functions are classified by how well they can be approximated at each resolution level.

## Looking Ahead

The theorems established so far are the beginning of a larger program. The natural next steps push in several exciting directions.

What happens when the data *almost* lands on a grid? An approximate version of affine encodability, allowing small errors between data values and their nearest grid points, would connect to the vast theory of quantization — the mathematical study of approximating continuous signals with discrete ones. The error tolerance becomes a parameter trading off compression ratio against reconstruction fidelity, exactly the framework underlying every modern audio and video codec.

What about higher dimensions? A cloud of points in 3D space might be affine-encodable after a linear transformation (rotation, scaling, shearing) maps it to an integer lattice. This connects to lattice theory, crystallography, and dimensionality reduction — the geometric toolkit behind modern machine learning.

And what about the connection to model selection? In statistical learning theory, the Minimum Description Length (MDL) principle selects models that provide the shortest total description of both the model and the data given the model. Affine encodability provides a geometric criterion for when the "affine model class" wins the MDL competition: datasets with low affine distortion are precisely those for which the affine model gives short descriptions. This transforms an abstract information-theoretic principle into a concrete geometric test.

## The Deeper Lesson

Behind all the theorems and applications lies a philosophical point. We tend to think of geometry and information as separate domains — shapes on one side, bits on the other. But the mathematics says they're deeply intertwined. The spatial structure of a dataset determines its information content. The arrangement of numbers on a line constrains how many bits you need to describe them. Shape *is* information.

This isn't entirely new. Claude Shannon's foundational 1948 paper already hinted at geometric interpretations of information, and the field of information geometry has explored curvature and distance in probability spaces for decades. But the affine encodability framework makes the connection startlingly concrete. It says: measure the distortion of the simplest possible geometric transformation, and you get a compression bound. No statistical model required. No distributional assumptions needed. Just geometry.

That directness is what makes it powerful — and what makes it feel like the beginning of something larger. If the simplest geometric invariant (affine distortion) already yields compression certificates, what might more sophisticated geometric measures reveal? The mathematics of shape has barely begun to speak the language of information. The conversation is just getting started.
