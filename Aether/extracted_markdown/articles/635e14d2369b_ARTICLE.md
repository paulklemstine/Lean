# The Hidden Architecture of Arithmetic

## How Two Simple Functions Explain Why Multiplication Works

---

There is a mystery at the heart of multiplication that most of us learned to take for granted in third grade. When you multiply 3 by 4 to get 12, you are performing an operation that seems irreducibly two-dimensional: it takes *two* numbers as input and produces *one* as output. No matter how you slice it, multiplication appears to require knowing both factors simultaneously.

But what if that isn't true?

In the late 1950s, Soviet mathematician Andrey Kolmogorov made a discovery so surprising that it briefly turned the mathematics of his era on its head. He proved that *every* continuous function of multiple variables—no matter how complicated—can be broken down into simple one-variable functions, stitched together with nothing more exotic than addition. A surface in three-dimensional space, a weather prediction depending on temperature and humidity and wind speed, the gravitational force between two masses—all of them, Kolmogorov showed, are secretly built from one-dimensional building blocks.

The theorem was beautiful but maddening. Kolmogorov proved these one-dimensional building blocks *existed*, but he couldn't tell you what they looked like. For decades, mathematicians knew the decomposition was possible in principle but had no practical way to construct it. The building blocks were exotic, highly irregular functions—mathematical objects you could prove existed but never write down.

Now, new research reveals that for a surprising number of important functions, the building blocks aren't exotic at all. They are two of the most familiar functions in all of mathematics: the exponential and the logarithm.

## The Exp-Log Universe

The exponential function—the one that turns addition into multiplication—and the logarithm—its mirror image, which turns multiplication into addition—are arguably the two most important functions in science. They describe radioactive decay, compound interest, the decibel scale, earthquake magnitudes, and the way our ears perceive sound. Together, they form what researchers call the EML (exponential-minus-logarithm) function class.

The new result is startlingly simple. Take multiplication: *x* × *y*. For any two positive numbers, this equals:

> exp(log *x* + log *y*)

Read that carefully. The logarithm converts each number into a single-variable function. Addition combines them. The exponential converts back. Three steps, each involving only one variable at a time (except the addition, which is trivially simple). Kolmogorov's decomposition, for multiplication, uses nothing more than `log` as the inner function and `exp` as the outer function.

This isn't just a curiosity. It means multiplication—the operation that builds areas from lengths, combines probabilities, scales physical forces—has a one-term Kolmogorov-Arnold decomposition. Kolmogorov's general theorem says you might need as many as five terms (2*n* + 1 for dimension *n* = 2). Multiplication needs just one. The exponential-logarithm pair is spectacularly efficient.

## The Power of One

The surprise deepens when you realize how far the exp-log decomposition reaches. Powers? *x*^*n* = exp(*n* · log *x*). Geometric means? √(*xy*) = exp(½ log *x* + ½ log *y*). Division? *x*/*y* = exp(log *x* − log *y*).

Each of these is a one-term decomposition. Each uses only the logarithm to "read" the input variables and the exponential to "write" the output. The coefficient in front of the logarithm—whether it's 1, *n*, ½, or −1—determines which operation you get. It's as if the logarithm is a universal language for expressing numerical relationships, and the exponential is the universal decoder.

This is remarkable for several reasons. First, it means these fundamental operations are *maximally simple* in the Kolmogorov-Arnold sense. You cannot decompose a bivariate function into fewer than one term. Multiplication, powers, means, and division all achieve this theoretical minimum.

Second, it reveals a hidden unity. These operations look very different when you learn them in school. Multiplication is repeated addition. Powers are repeated multiplication. Division is the inverse of multiplication. Square roots require a whole new concept. But viewed through the Kolmogorov-Arnold lens, they are all the same thing: exp composed with a linear combination of logs. The *only* difference between multiplication and taking a square root is the coefficient ½ versus 1 in front of the logarithm.

## Crossing Into Information Theory

Perhaps the most surprising consequence appears when you cross into a completely different domain: information theory.

The Kullback-Leibler divergence—a fundamental measure of how different two probability distributions are—has an integrand of the form *p* · log(*p*/*q*). This is exactly the kind of expression that decomposes via the exp-log framework. Specifically:

> *p* · log(*p*/*q*) = *p* · log *p* − *p* · (1 − eml(0, *q*))

where eml(0, *q*) = exp(0) − log(*q*) = 1 − log *q* is the EML operation applied with a zero first argument.

This means the KL divergence—the workhorse of machine learning, the foundation of variational inference, the information-theoretic measure at the heart of modern AI—is built from the same exp-log primitives as multiplication. The bridge between arithmetic and information theory runs through the EML function class.

## A Duality from Convex Analysis

There is an even deeper structural reason why exp and log play this privileged role. The Fenchel-Young inequality states that for any *x* and any positive *s*:

> *x* · *s* ≤ exp(*x*) + *s* · log(*s*) − *s*

This inequality is tight—it becomes an equality—when *x* = log *s*. In the language of convex analysis, exp and the entropy function *s* · log *s* − *s* are *convex conjugates*: each is the "shadow" of the other, connected by the Legendre transform.

This duality explains *why* exp and log are the natural building blocks. They are not arbitrary choices but are linked by the deepest structure in optimization theory. The Fenchel-Young inequality is the mathematical law that guarantees the efficiency of the EML decomposition.

## The Separation Property

For a Kolmogorov-Arnold decomposition to work, the inner functions must *separate points*: if two inputs are different, the inner function must map them to different values. Otherwise, the outer function cannot distinguish them, and the decomposition fails.

The logarithm separates all positive real numbers—it is injective on (0, ∞). This is a basic property, but it is also essential. Without injectivity, you cannot reconstruct the original function from its one-dimensional projections. The fact that log is injective, continuous, and unbounded on (0, ∞) makes it the ideal inner function for the EML-KA framework.

Exponential, meanwhile, is also injective—on all of ℝ. Together, they form a pair of bijections that "rotate" the positive reals into all of ℝ and back, preserving all the information needed for the Kolmogorov-Arnold reconstruction.

## The Conjecture

The proven results cover a wide swath of elementary operations. But what about more complex functions? Can *every* continuous function on the positive reals be decomposed using only exp and log as the inner functions?

The researchers formulate a precise conjecture: for every polynomial *p*(*x*, *y*) that is positive on (0, ∞)², the function log(*p*(*x*, *y*)) should have a finite EML-KA decomposition. As a specific test case: can log(*x*² + *y*²) be decomposed into three terms using exp-log inner and outer functions?

This is a question that can be tested computationally. If the conjecture is true, it would mean the exp-log pair is not just convenient but *universal* for a broad class of multivariate functions—far beyond the operations we learn in school.

## Why It Matters

At first glance, expressing multiplication as exp(log *x* + log *y*) might seem like a parlor trick—a round-trip through logarithmic space that ends where it started. But the implications ripple outward.

**For machine learning**: The Kolmogorov-Arnold theorem has recently inspired a new class of neural networks called KAN (Kolmogorov-Arnold Networks), where the activation functions are learned rather than fixed. The EML-KA results suggest that exp and log should be privileged activation functions—that networks using these specific nonlinearities might achieve better approximation with fewer parameters.

**For numerical computing**: Decomposing a bivariate function into univariate ones is the key to efficient computation on parallel hardware. If multiplication can be computed as a sum of one-dimensional lookups, that opens possibilities for analog computing and hardware acceleration.

**For understanding computation itself**: The result suggests that the reason exp and log are so fundamental to science is not merely historical convenience. These functions are *optimal* in a precise mathematical sense—they achieve the minimal possible Kolmogorov-Arnold decomposition for basic arithmetic.

## A New Lens on Old Mathematics

Kolmogorov's theorem was proved in 1957 as the answer to Hilbert's 13th problem, which asked whether certain equations could be solved using functions of only two variables. The answer—any number of variables can be reduced to one—was so counterintuitive that David Hilbert himself would have been astonished.

Nearly seventy years later, we are still mining the consequences. The connection to exp and log reveals that Kolmogorov's abstract existence theorem, for the most important functions in mathematics, collapses to something breathtakingly concrete: the operations you learned in high school algebra class, combined in just the right way.

The hidden architecture of arithmetic was there all along, waiting to be seen. It took the right question—not "how do we compute?" but "how simply can we decompose?"—to reveal it.

---

*The mathematical results described in this article have been formalized and verified with complete proofs. The key theorems—including the EML-KA decomposition of multiplication, power functions, geometric means, and the Fenchel-Young inequality—are established with full mathematical rigor.*
