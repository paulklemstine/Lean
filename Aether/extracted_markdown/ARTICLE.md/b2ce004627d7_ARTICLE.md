# The Mathematics of Compression: How a Simple Idea About Fixed Points Could Revolutionize Information Theory

## The Paradox of the Perfect ZIP File

Imagine compressing a file on your computer. The ZIP algorithm chews through your data, spitting out a smaller version. You compress it again — maybe it shrinks a little more. Again — barely any change. One more time — nothing. The file just sits there, stubbornly refusing to get any smaller.

You have just witnessed one of the deepest ideas in mathematics, hiding in plain sight on your desktop.

That final, irreducible file — the one that refuses to shrink — is a *fixed point*. It is a mathematical object that, when you apply the compression operation to it, comes out unchanged. And a new body of mathematical research reveals that this simple observation — that compression has fixed points, and those fixed points are exactly the incompressible objects — is not just a cute analogy. It is a precise theorem with far-reaching consequences for how we understand information, complexity, and the very nature of mathematical structure.

## The Idea That Connects Everything

The story begins with a concept that mathematicians call a *closure operator*. It sounds abstract, but the idea is beautifully simple: a closure operator is any process that, when you apply it to something, gives you a "canonical" or "simplified" version — and applying it again changes nothing.

Rounding a number to the nearest integer is a closure operator. Sorting a list is a closure operator. Taking the convex hull of a set of points is a closure operator. Even the act of summarizing a paragraph into its key idea is, in spirit, a closure operator.

What makes these processes special is a trio of properties. First, the output is never "less" than the input — it captures at least as much information (this is called *extensivity*). Second, the process respects order — if you start with something smaller, you end up with something smaller (*monotonicity*). And third — the magic property — doing it twice is the same as doing it once (*idempotence*).

That third property, idempotence, is the key to everything. It means the process converges in a single step. There is no gradual relaxation, no slow convergence. One application and you are at the fixed point. Done.

## Compression as a Mathematical Operation

Here is where the new research makes its breakthrough. The mathematicians proved, with complete rigor, that *any* closure operator automatically gives you a compression scheme — and not just any compression scheme, but an optimal one within its class.

The theorem works like this. Given a closure operator acting on some collection of objects, every object gets mapped to its "canonical representative" — the fixed point it converges to. Objects that map to the same canonical representative are, from the closure's perspective, interchangeable. They carry the same essential information.

Now, if you want to describe or encode these objects efficiently, you only need to encode the canonical representatives. The full set of objects is partitioned into equivalence classes, and each class has exactly one fixed point serving as its label. Any "closure-respecting" code — one that assigns the same codeword to equivalent objects — must factor through these canonical representatives.

This is not just an observation. It is a *theorem*: any description length function that respects the closure structure can be decomposed as a function on fixed points composed with the closure map. The canonical representative is not merely *a* good choice for compression. It is *the* choice — the unique minimal description within each equivalence class.

## The Incompressibility Theorem

Perhaps the most striking result concerns what it means for an object to be *incompressible*.

In classical information theory, a string of bits is called "Kolmogorov random" or "incompressible" if no shorter program can produce it. This is a deep and beautiful concept, but it suffers from a fatal practical flaw: Kolmogorov complexity is *uncomputable*. You can never know for certain whether a given string is truly incompressible, because that would require checking every possible program — an infinite search.

The new research sidesteps this barrier entirely. Instead of asking about all possible programs, it asks about all possible closure operators with a *strict descent* property: closures that genuinely shorten every object they change.

The theorem states: under the strict descent condition, an object has zero "deficiency" — meaning the closure cannot shorten it at all — if and only if it is already a fixed point.

In other words, *fixed points are exactly the incompressible objects*. Not approximately. Not asymptotically. Exactly.

This gives us a computable, verifiable notion of incompressibility. You do not need to search through all programs. You just need to check whether the closure operator leaves your object unchanged. If it does, the object is incompressible — it is already in its canonical form.

## The Tropical Connection

The researchers then demonstrated this principle in one of the most elegant settings in modern mathematics: *tropical geometry*.

Tropical mathematics replaces ordinary addition with the "min" operation and ordinary multiplication with addition. This seemingly bizarre substitution turns out to be extraordinarily powerful, with applications ranging from optimization to algebraic geometry to the theory of neural networks.

In tropical geometry, a natural operation is *normalization*: given a vector of numbers, subtract the minimum value from every entry. The result is a vector where the smallest entry is zero and all others are nonneg.

This normalization is a closure operator. Apply it twice, and you get the same result as applying it once — because the minimum of the normalized vector is already zero, so subtracting it again changes nothing. The fixed points are precisely the vectors that are already normalized: nonneg with at least one zero coordinate.

The researchers proved this rigorously and then showed something more: two vectors normalize to the same result if and only if they differ by a global constant shift. In other words, tropical normalization selects the unique canonical representative from each equivalence class of vectors that represent "the same tropical point."

This is compression in its purest geometric form. The redundant information — the global offset — is stripped away, leaving only the essential shape. And the fixed points — the normalized vectors — are the incompressible objects: they cannot be simplified further because they already carry no redundant offset.

## Why This Matters

The significance of these results extends far beyond pure mathematics.

**In data science and machine learning**, the Minimum Description Length (MDL) principle is a cornerstone of model selection: choose the model that provides the shortest description of the data. The new theorems show that MDL-optimal descriptions arise naturally from closure operators, giving a rigorous foundation for what has often been treated as a heuristic.

**In computer science**, abstract interpretation — a technique for analyzing programs by computing approximate answers — is fundamentally a closure operator. The new results say that abstract interpretation is literally a compression scheme: it produces canonical representatives that are optimal descriptions within their equivalence class. This could lead to new algorithms for program optimization and verification.

**In physics**, the second law of thermodynamics says that entropy never decreases — systems always evolve toward states of maximum disorder. The closure deficiency (the gap between an object's complexity and its canonical representative's complexity) plays an analogous role: it is always nonneg, and it reaches zero exactly at equilibrium — exactly at the fixed points. This suggests deep connections between compression, entropy, and the arrow of time.

**In the theory of neural networks**, recent work has shown that ReLU networks — the workhorses of modern deep learning — have an intimate connection to tropical geometry. The tropical normalization theorem could provide new tools for understanding when neural network weights are in "canonical form" and when they contain redundant parameters that can be compressed away.

## The Bigger Picture

What makes this research program truly remarkable is its *universality*. The same mathematical structure — closure operators, fixed points, canonical representatives — appears everywhere: in algebra, in geometry, in computation, in physics, in information theory. The theorems proved here are not about any specific compression algorithm or any specific type of data. They are about the *abstract structure of compression itself*.

The dream that drives this work is audacious: to build a complete mathematical theory where complexity, compression, and canonical form are three faces of the same concept. Where Kolmogorov randomness is not an uncomputable ideal but a theorem about fixed points. Where the minimum description length is not a heuristic but a consequence of universal algebra. Where tropical geometry provides the concrete playground where these abstract ideas become visible and tractable.

We are not there yet. The full bridge between closure-theoretic compression and classical Kolmogorov complexity remains conjectural, though the conditional theorems established here make the path mathematically precise. The oracle-relative versions — where compression is performed with the help of an external information source — are the natural next step.

But the foundation is now in place: a suite of rigorously proved theorems showing that compression is fundamentally about the passage from objects to their fixed points under idempotent dynamics, and that the incompressible objects are exactly those that have already reached their canonical form.

It is a beautiful idea — and one that was, perhaps, hiding in your desktop all along, every time you right-clicked a file and chose "Compress."
