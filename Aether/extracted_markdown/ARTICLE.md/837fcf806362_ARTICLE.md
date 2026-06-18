# The Arrow of Information: How Functions Forget

## Every computation destroys information — and mathematics can tell you exactly how much

In 1961, physicist Rolf Landauer made a startling claim: erasing a single bit of information must dissipate a tiny amount of heat into the universe. This wasn't speculation — it was thermodynamics, as inescapable as the second law itself. Every time your computer clears a memory register, the universe gets a little warmer.

For decades, Landauer's principle remained a curiosity of theoretical physics. But hidden within it lies a deep mathematical truth about the nature of computation itself — one that connects information theory, category theory, and thermodynamics into a single, elegant framework.

## The Fibers of a Function

Consider the simplest possible computation: a function that takes an input and produces an output. A thermostat reads a temperature (say, 68°F, 72°F, or 85°F) and outputs a command: "heat," "nothing," or "cool."

Now ask: given the output "heat," can you recover the input? If the thermostat turns on heating for any temperature below 70°F, then many different inputs — 32°F, 50°F, 68°F — all produce the same output. The set of all inputs that map to a given output is called a **fiber**. The fiber over "heat" contains every temperature that triggers heating.

Here is the key insight: **the sizes of these fibers tell you exactly how much information the function destroys**.

If every fiber has exactly one element — meaning each output came from exactly one input — the function is *injective*. No information is lost. You can run the computation backward. This is the mathematical essence of reversible computing.

But if some fibers are large (many inputs produce the same output), information is being compressed. The larger the fibers, the more information vanishes, the more entropy increases, the more heat the universe must absorb.

## Measuring the Damage

We can quantify this precisely. For a function *f* from a finite set *A* to a finite set *B*, define the **fiber entropy**:

> H(f) = Σ n_b · log(n_b)

where n_b is the size of the fiber over each output b, and the sum runs over all possible outputs. When every fiber has size 1 (the function is injective), each term is 1 · log(1) = 0, so H(f) = 0. No information lost. When a single fiber swallows everything (a constant function), H(f) = |A| · log(|A|) — maximum information destruction.

This formula looks suspiciously like Shannon's entropy, and that's no coincidence. Shannon entropy measures the uncertainty in a probability distribution; fiber entropy measures the uncertainty introduced by a computation. They're the same mathematics viewed from different angles.

## The Monotonicity Theorem

The deepest result in this theory is almost poetic in its simplicity:

> **If you compose two functions, you can only destroy more information, never less.**

Formally: H(g ∘ f) ≥ H(f). Composing f with any function g can only increase the fiber entropy. This is because composition merges fibers — if two inputs already map to the same intermediate value, they certainly map to the same final output. But g might also merge different intermediate values, collapsing more fibers together.

The mathematical proof relies on a beautiful analytic fact: the function x · log(x) is **superadditive** on the nonneg reals. That means (a + b) · log(a + b) ≥ a · log(a) + b · log(b). When fibers merge, the merged fiber's contribution to the entropy exceeds the sum of the individual contributions. Information destruction is irreversible — it compounds.

This is, in essence, the data processing inequality of information theory, transplanted into the world of pure functions. In information theory, processing a signal can never increase its mutual information with the source. In our framework, composing functions can never decrease their fiber entropy. Same principle, different clothing.

## The Entropy Defect

If composing with g always increases entropy, we can measure *by how much*. The **entropy defect** δ(f, g) = H(g ∘ f) − H(f) captures the additional information destroyed by applying g after f. The monotonicity theorem guarantees δ is always nonneg.

The entropy defect satisfies a remarkable chain rule. If you compose three functions f, g, and h, the total information lost decomposes cleanly:

> δ(f, h∘g) = δ(g∘f, h) + δ(f, g)

The loss from composing with h∘g equals the loss from first applying g (measured relative to f), plus the loss from then applying h (measured relative to g∘f). Information destruction is additive along the composition chain.

When is the defect zero? Exactly when g is bijective — a one-to-one correspondence that merely relabels outputs without merging any fibers. Bijective functions are informationally transparent: they transform data without destroying it. This is why reversible computing is thermodynamically free.

## Three Flavors of Entropy

The fiber entropy using logarithms is the most information-theoretically natural, but it's not the only option. Two variations reveal different aspects of the same phenomenon:

**Collision entropy** replaces x · log(x) with x², giving H₂(f) = Σ n_b². This measures the probability that two randomly chosen inputs produce the same output. It satisfies the same monotonicity property — H₂(g ∘ f) ≥ H₂(f) — but the proof uses only elementary algebra: (a + b)² ≥ a² + b². No calculus required.

**Tropical entropy** goes further, replacing the sum with a maximum: H_trop(f) = max n_b, the size of the largest fiber. In the tropical semiring — where addition becomes maximum and multiplication becomes addition — this is the natural entropy. Monotonicity still holds: merging fibers can only increase the maximum.

These three entropies form a hierarchy. The tropical entropy captures the worst-case information loss; the collision entropy captures the average pairwise collision rate; the fiber entropy captures the full information-theoretic cost. All three increase under composition. All three vanish for injective functions.

## From Functions to Physics

Landauer's principle now emerges as a corollary. Every physical computation implements some function from input states to output states. The fiber entropy of that function measures the information destroyed. By the monotonicity theorem, chaining computations can only increase the total destruction. And every bit of destroyed information, as Landauer showed, costs kT·ln(2) joules of dissipated heat.

The only escape is reversibility. If every step of your computation is bijective — every function has defect zero — then no information is destroyed, no heat is dissipated, and the computation is thermodynamically free. This is why quantum computing, which operates via unitary (and hence bijective) transformations, holds the promise of energy-efficient computation at scale.

## The View from Category Theory

There's an even more abstract perspective. Functions between finite sets form a *category* — objects are sets, morphisms are functions, and composition is the usual function composition. The fiber entropy is a *functor* from this category to the ordered real numbers: it assigns a number to each morphism, and composition can only increase it.

This functorial viewpoint suggests that information loss is not just a property of individual computations, but a structural feature of the category of finite sets itself. Any time you map between finite structures, you're navigating a landscape where information can flow in only one direction: toward destruction.

The entropy defect, with its chain rule, behaves like a cocycle in cohomology — a measure of obstruction that decomposes additively along compositions. This hints at deeper connections between information theory and algebraic topology that remain largely unexplored.

## What Comes Next

The monotonicity theorem settles the question for post-composition: composing on the right always increases entropy. But what about pre-composition? If f : A → B and h : C → A, how does H(f ∘ h) relate to H(f)?

For surjective h, the fibers of f ∘ h are enlargements of the fibers of f (each element of a fiber of f is replaced by its own fiber under h). This suggests H(f ∘ h) ≥ H(f) when h is surjective, but the precise relationship depends on h's fiber structure.

And beyond finite sets, what happens in the continuous case? If f is a smooth map between manifolds, can we define a "fiber entropy" using the volumes of fibers? The monotonicity theorem would then become a statement about the measure-theoretic structure of smooth compositions — a new kind of inequality in geometric measure theory.

These questions sit at the intersection of information theory, algebraic topology, and mathematical physics. They suggest that the simple observation — functions forget, and forgetting compounds — may be the surface of something much deeper. The mathematics of information loss is just beginning.

---

*The research described in this article establishes a complete mathematical theory of information loss in finite computations, proving that composition can only increase entropy, that bijective transformations preserve information perfectly, and that information destruction decomposes additively along computation chains.*
