# The Hidden Cost of Forgetting: How Mathematicians Measure What Computers Lose

Every time you take a photograph, something is lost. The three-dimensional world — with its infinite gradations of light, its textures, its depth — gets flattened into a grid of colored pixels. Some information survives. Most doesn't. And here's what's strange: until recently, mathematicians had no rigorous way to measure *exactly* how much.

That changed with a concept called **functorial entropy** — a mathematical framework that precisely quantifies how much information any process destroys. The theory yields a startling result: the amount of information a function loses is entirely determined by its "fiber structure" — the pattern of how inputs collapse onto outputs. And this number is *exactly zero* if and only if the process is perfectly reversible.

## The Fiber of a Function

Imagine you run a daycare and you need to sort children into groups by birth month. January babies go in one room, February babies in another, and so on. Some months might have five children, others only one. These groups — the collections of inputs that all land on the same output — are called **fibers**.

The fibers tell you everything about information loss. If every group has exactly one child, you haven't lost any information: you can reconstruct who's who from the grouping alone. But the moment two children share a month, you've created ambiguity. Their individual identities are, from the perspective of the grouping function, indistinguishable.

Functorial entropy captures this with elegant precision. For each element in the domain, you measure the size of its fiber — how many other elements map to the same output — take the logarithm, and average over all elements. The result is a single non-negative number: zero means no information was lost, and larger values mean more was destroyed.

## The Zero Characterization: A Perfect Detector

The central theorem of the theory — called the **Zero Characterization Theorem** — states something that sounds simple but is surprisingly deep:

> *A function has zero entropy if and only if it is injective.*

An injective function (also called "one-to-one") is one where different inputs always produce different outputs. No information is lost because you can always trace back from the output to find the unique input that produced it.

The theorem says this is the *only* way to achieve zero entropy. There is no clever trick, no encoding scheme, no mathematical sleight of hand that can give you zero information loss without full injectivity. If even two inputs map to the same output — anywhere — the entropy is strictly positive.

What makes this theorem deep rather than obvious is the direction of the proof. It's easy to see that injective functions have zero entropy (every fiber has size one, and log(1) = 0). The hard part is the converse: proving that zero entropy *forces* injectivity. This requires showing that the sum of logarithms of fiber sizes can only vanish if every single fiber has size exactly one — exploiting the strict positivity of logarithms for arguments greater than one.

## The Arrow of Information

Perhaps the most beautiful result in the theory is the **Composition Monotonicity Theorem**, also known as the functorial version of the Data Processing Inequality:

> *If you apply one function after another, the total entropy can only increase or stay the same. It can never decrease.*

Think of it this way: if you take a photograph and then photocopy it, the photocopy cannot contain *more* information than the photograph. Each processing step is a one-way valve for information — it can flow out but never back in.

Mathematically, this says that for any functions f and g, the entropy of their composition g∘f is at least as large as the entropy of f alone. The proof is elegant: composing with g can only *merge* fibers together, making them larger. Since larger fibers mean larger logarithms, the average can only go up.

This has profound implications for data pipelines. Whether you're processing genetic sequences, compressing video, or training a neural network, each step in your pipeline is provably losing information. The monotonicity theorem gives you a tool to track exactly how much is lost at each stage and identify which steps are the most destructive.

## Landauer's Ghost

In 1961, the physicist Rolf Landauer made a revolutionary claim: erasing information has a minimum energy cost. Specifically, erasing one bit of information at temperature T requires at least k_B·T·ln(2) joules of energy, where k_B is Boltzmann's constant. This is the **Landauer limit** — a fundamental bridge between information theory and thermodynamics.

Functorial entropy provides the exact mathematical link. The **Landauer Cost** of a function — defined as the total log-fiber-size summed over all inputs — equals the entropy times the number of inputs. The **Landauer Zero Theorem** then states:

> *A computation has zero thermodynamic cost if and only if it is reversible.*

This is not a metaphor or an analogy. It is a precise mathematical equivalence. The algebraic property of injectivity (a function-theoretic concept) is identical to the physical property of thermodynamic reversibility (an energy concept). The bridge between them is entropy.

At room temperature (300 K), erasing a single bit costs at least 2.87 × 10⁻²¹ joules — an almost inconceivably small amount. But in a modern processor performing billions of operations per second, these costs add up. The theory tells us that any irreversible computation — any function that's not injective — must pay this price. There is no workaround.

## The Pipeline Principle

Combine the composition monotonicity theorem with the Landauer cost, and you get a powerful principle for analyzing real-world computation:

> *In any multi-stage data pipeline, information is monotonically destroyed, and each stage of destruction has a thermodynamic cost.*

Consider a simple example: a three-stage pipeline that takes numbers from 0 to 23, reduces them modulo 12, then modulo 6, then modulo 3. The entropy at each stage is:

- After mod 12: H = log(2) ≈ 0.693
- After mod 6: H = log(4) ≈ 1.386
- After mod 3: H = log(8) ≈ 2.079

Each stage doubles the fiber sizes, adding exactly log(2) to the entropy. The pipeline loses information uniformly and predictably, and the total Landauer cost grows proportionally.

## The Constant Function: Maximum Destruction

At the opposite extreme from injective functions sits the constant function — the function that maps everything to a single output. Its entropy is log(n), where n is the size of the domain. This is the maximum possible entropy, and the theorem proves it rigorously: no function can have entropy greater than log(n).

The constant function represents total information destruction. Every input becomes indistinguishable from every other input. All structure is erased. And the Landauer cost of this annihilation is exactly n·log(n) — the maximum possible thermodynamic price.

## Privacy by Entropy

One unexpected application of functorial entropy is in **data privacy**. The practice of k-anonymity — ensuring that each record in a database is indistinguishable from at least k-1 others — is precisely a condition on fiber sizes. A k-anonymous transformation is one where every fiber has size at least k, which means the entropy is at least log(k).

This reframes privacy as an entropy problem. Want stronger privacy? Increase the entropy by coarsening the grouping. Want to know the minimum information loss required for a given privacy guarantee? The entropy formula tells you exactly. And the composition monotonicity theorem guarantees that adding more anonymization layers can only strengthen the guarantee, never weaken it.

## An Open Question

The theory raises a tantalizing conjecture about **superadditivity**: when you compose a surjective function f with another function g, is the entropy of the composition always at least the *sum* of their individual entropies?

If true, this would mean that the information cost of a pipeline isn't just monotonically increasing — it's growing *faster* than the sum of individual costs. Each stage would amplify the information loss of previous stages. Computational tests on small domains confirm the conjecture, but a proof remains elusive.

## What It Means

Functorial entropy sits at a remarkable crossroads. It is simultaneously a theorem about algebra (injectivity), a theorem about information (entropy), and a theorem about physics (thermodynamic cost). The same number — the average log-fiber-size — captures all three perspectives.

This is the kind of unification that drives mathematics forward. When apparently different domains turn out to be measuring the same thing, it usually means there's a deeper structure waiting to be discovered. The fiber structure of a function, it turns out, is not just a curiosity of combinatorics. It is a fundamental invariant that connects the abstract world of pure mathematics to the physical world of energy, heat, and irreversibility.

The next time you compress a file, hash a password, or scroll through a feed curated by an algorithm, remember: every one of those operations is destroying information. And now, for the first time, we know exactly how to measure the cost.
