# The Three Speeds of Computation: How the Shape of a Type Reveals the Speed of a Program

Every computer program, at its heart, is a machine for transforming information. But here's something remarkable that computer scientists have only recently begun to understand: the *shape* of the information a program handles predicts — with mathematical certainty — how quickly its complexity can explode.

Imagine you're designing a system to manage a city's traffic lights. Each light can be red, yellow, or green: three choices. Add a second intersection and you have two independent sets of three choices. A third intersection, a fourth. The number of possible traffic configurations grows steadily — three, six, nine, twelve. One new intersection, three new states. It's a calm, linear progression. A city planner can sleep soundly knowing that doubling the intersections merely doubles the work.

Now imagine something different. You're configuring a network of switches, each of which can be on or off. Two switches give you four combinations. Three give you eight. Four give you sixteen. Each new switch *doubles* the total — and suddenly a modest network of thirty switches yields over a billion configurations. This is exponential growth, the kind that breaks brute-force approaches and forces engineers toward clever shortcuts.

But there is a third speed. A rarer, more terrifying one.

Consider a program that doesn't just process data but accepts *other programs* as input — a plugin system, a callback architecture, a higher-order function. When you allow programs to take programs as arguments, the number of possible behaviors doesn't merely double with each new layer. It *squares*. And squaring an already exponential quantity produces something that grows faster than anything human intuition can comfortably grasp: double-exponential growth. At depth three, you might have a trillion possibilities. At depth five, more than atoms in the observable universe.

These three speeds — linear, exponential, and double-exponential — are not arbitrary categories invented for convenience. They are the *only* growth rates that arise from three fundamental ways of combining information. And a new mathematical theorem, called the Growth Regime Trichotomy, proves this with the finality of a geometric proof.

---

## The Algebra of Information

The key insight comes from type theory, a branch of mathematics that studies the *structure* of data. In this framework, every piece of information has a "type" — a blueprint describing what shape it takes. There are exactly three ways to build complex types from simpler ones, and each corresponds to a familiar pattern of combination:

**Choices (Sum Types).** When you face an either/or decision — this *or* that — you're working with a sum. A traffic light is red *or* yellow *or* green. An HTTP response is success *or* failure. The total number of possibilities is the *sum* of the individual options. Three colors plus three colors gives six. Sum types grow by addition.

**Pairs (Product Types).** When you bundle information together — this *and* that — you're working with a product. A point in the plane is an x-coordinate *and* a y-coordinate. A record in a database is a name *and* an address *and* a phone number. The total number of possibilities is the *product* of the individual options. Three choices times three choices gives nine. Product types grow by multiplication.

**Functions (Arrow Types).** When you describe a transformation — for every input, produce an output — you're working with an arrow. A lookup table that maps each of three keys to one of three values is a function. How many such functions exist? For each key, there are three independent choices, giving 3 × 3 × 3 = 27 possibilities. Arrow types grow by exponentiation.

These three operations — addition, multiplication, and exponentiation — form a nested hierarchy. Addition is the gentlest: combining sums upon sums produces linear growth. Multiplication is more aggressive: combining products upon products produces exponential growth. And exponentiation is the most violent: nesting functions within functions produces growth that escapes the exponential regime entirely.

The Growth Regime Trichotomy proves that these are the *only* three speeds. No matter how cleverly you combine these three building blocks, the resulting complexity falls into exactly one of three categories. There are no intermediate speeds — nothing between exponential and double-exponential, nothing between linear and exponential. The shape of a type is a speed certificate.

---

## The Engine of Explosion

What makes function types so dangerous? The answer lies in a subtle mathematical detail — a "+1" that appears in the complexity formula and acts as a kind of ratchet.

When you compute the complexity of a product type A × B, the formula is straightforward: complexity(A) × complexity(B). Products multiply. When you compute the complexity of a sum type A + B, it's even simpler: complexity(A) + complexity(B). Sums add.

But for a function type A → B, the formula contains an extra term: (complexity(A) + 1) × (complexity(B) + 1). That innocent-looking "+1" changes everything.

Without the +1, the function type formula would give complexity(A) × complexity(B) — identical to products. Functions and products would be indistinguishable in terms of growth. The type system would know only two speeds, not three.

The +1 acts as what mathematicians call a *regularization*. It prevents the formula from collapsing to a simpler form. It ensures that each layer of function nesting doesn't merely multiply the complexity but *inflates the base* before multiplying. And when you inflate and then square, inflate and then square, repeatedly, you get double-exponential growth.

Consider the "balanced arrow tree" — a type built by repeatedly nesting functions symmetrically:

- Depth 0: the base type. Complexity = 1.
- Depth 1: base → base. Complexity = (1+1) × (1+1) = 4.
- Depth 2: (base → base) → (base → base). Complexity = (4+1)² = 25.
- Depth 3: Complexity = (25+1)² = 676.
- Depth 4: Complexity = (676+1)² = 458,329.
- Depth 5: Complexity = (458,329+1)² ≈ 2.1 × 10¹¹.

Each step squares plus one, then squares again. By depth 10, the number exceeds 10^600 — a quantity so large that writing it out digit by digit would fill a book. The mathematical theorem proves that this growth is always at least 2^(2^n), a tower of exponentials two levels high.

---

## Arrow Dominance: Why Functions Are Always Worst

The trichotomy also establishes a dominance result: replacing any product or sum in a type with a function arrow can only make things worse. If you take a type built from products and sums and systematically replace every × and + with →, the resulting complexity is always at least as large.

This isn't obvious. You might think that some clever arrangement of products could be worse than the corresponding arrangement of arrows. But the mathematics rules this out. The +1 regularization ensures that (a+1)(b+1) is always at least as large as both a × b (the product case) and a + b (the sum case), as long as a and b are at least 1. And the complexity of every type is at least 1.

This result has practical implications. If you're analyzing a complex system and want a quick upper bound on its state-space complexity, you can "promote" every type constructor to an arrow. The resulting type gives a bound that's easy to compute (it depends only on the tree structure) and is guaranteed to be conservative.

---

## Three Colors on a Map

To visualize the trichotomy, imagine plotting every possible type on a chart. The horizontal axis measures the type's structural size (how many building blocks it uses), and the vertical axis measures its complexity (the tsb value), on a logarithmic scale.

The types separate into three distinct clouds:

**The green cloud** at the bottom contains sum-only types. Their complexity equals their leaf count — the number of atomic building blocks. Growth is linear. These are the easy cases.

**The yellow cloud** in the middle contains arrow-free types with products. Their complexity can grow exponentially in the type size, but never faster. These are the medium cases — challenging but within reach of exhaustive analysis for modestly sized types.

**The red cloud** at the top contains types with arrows. Their complexity can reach doubly exponential heights. These are the hard cases — the ones that break model checkers, overwhelm test suites, and force engineers toward abstraction.

The remarkable fact is that there are no types in between the clouds. Every type falls cleanly into one of the three regimes. The boundaries are sharp.

---

## Implications for Technology

This mathematical result has immediate consequences for anyone who builds software systems.

**For API designers:** The type of your API endpoint predicts the testing burden. An endpoint that returns a tagged union (sum type) of simple records is easy to test exhaustively. An endpoint that accepts a callback (function type) is exponentially harder. The trichotomy provides a principled way to estimate testing complexity from the type signature alone.

**For model checkers and verifiers:** Tools that explore all possible states of a system need to know how large the state space is. The trichotomy provides tight bounds. Linear-regime types are always feasible. Exponential-regime types require careful sizing. Double-exponential-regime types almost certainly require abstraction or approximation.

**For compiler writers:** Defunctionalization — the technique of replacing higher-order functions with data — is a well-known compiler optimization. The trichotomy explains *why* it works: it transforms arrow types into sum-of-product types, shifting the complexity from the double-exponential regime down to the exponential or even linear regime. The type structure tells the compiler exactly how much benefit to expect.

**For protocol designers:** When two systems communicate, the message type determines the protocol's state space. The trichotomy warns that protocols with callback mechanisms (arrows in the message type) face fundamentally different complexity challenges than protocols with structured data (products and sums).

---

## A Window into Deeper Mathematics

The Growth Regime Trichotomy is also a window into some of the deepest structures in mathematics.

The three growth rates — linear, exponential, double-exponential — mirror the first three levels of the Grzegorczyk hierarchy, a classification of computable functions developed in the 1950s by the Polish logician Andrzej Grzegorczyk. At level zero, functions grow linearly. At level two, exponentially. At level three, doubly exponentially. The correspondence between type constructors and hierarchy levels is not a coincidence — it reflects a fundamental connection between the algebra of types and the classification of computational complexity.

There is also a tantalizing connection to tropical geometry, a branch of mathematics that replaces ordinary addition with the maximum operation. Under the map φ(T) = log₂(complexity(T)), products become addition, sums become approximate maxima, and arrows become a "regularized" addition that preserves information that the tropical maximum discards. The +1 offset in the arrow formula is precisely the regularization that prevents the tropical structure from degenerating. This suggests that type systems carry a hidden geometric structure — the geometry of computational complexity.

---

## The No Intermediate Growth Conjecture

The trichotomy establishes three growth regimes, but it leaves open a tantalizing question: are there *really* no intermediate speeds?

More precisely: is there any type whose complexity grows faster than any exponential but slower than any double-exponential? Something like 2^(n^(3/2)), caught between the exponential and double-exponential worlds?

Computational experiments testing millions of types up to depth seven have found no such intermediates. Every type's complexity, when measured against its structural parameters, falls cleanly into one of the three bins. This "No Intermediate Growth Conjecture" remains unproven, but the evidence is overwhelming. If it holds, it means the three speeds of computation are not merely common patterns but the *only* patterns — a genuine trichotomy with no exceptions.

---

## Looking Forward

The Growth Regime Trichotomy is a beginning, not an end. The most exciting open question is what happens when you add more powerful type constructors — dependent types, inductive types, universe polymorphism. Each new constructor could potentially introduce a fourth speed, or a fifth, or an infinite hierarchy of speeds. Preliminary calculations suggest that dependent types (which generalize arrows) could produce triple-exponential growth, adding a fourth layer to the hierarchy.

If this pattern continues, then the full hierarchy of type constructors would mirror the full Grzegorczyk hierarchy — an infinite tower of growth rates, each generated by a specific kind of type constructor. Types would not merely *describe* data; they would *classify* the fundamental limits of computation.

The shapes of our abstractions, it turns out, are not arbitrary. They are maps of computational terrain, drawn by the deep structure of mathematics itself. Three building blocks. Three speeds. And a mathematical proof that there is nothing in between.
