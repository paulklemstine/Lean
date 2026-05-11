# The Hidden Algebra of Learning: How a Century-Old Idea About Languages Unlocked a New Theory of Artificial Intelligence

## When Machines Learn, They're Really Just Forgetting

Imagine you're trying to teach a child to recognize cats. You show her a hundred photographs — tabbies, Siamese, Maine Coons, some dogs thrown in for contrast. After a while, she gets it. But here's the curious thing: she doesn't memorize all hundred pictures. She extracts some essential pattern that lets her recognize cats she's never seen before.

For decades, mathematicians have struggled with a deceptively simple question: *How much does a learning algorithm really need to remember?* The answer, it turns out, has been hiding in plain sight — not in the statistics of machine learning, but in a branch of abstract algebra that was developed to understand something completely different: the structure of human language.

## A Theorem Born in the Wrong Century

In 1957, two mathematicians named Anil Nerode and John Myhill independently proved a beautiful theorem about what makes a language "simple." Not English or French — they were thinking about formal languages, the kind that computers process. Their insight was elegant: a language can be recognized by a finite machine (like a simple computer chip) if and only if a certain natural equivalence relation on strings has only finitely many equivalence classes.

The idea is intuitive once you see it. Take any two strings of characters. If no continuation of those strings can ever distinguish them — if appending any suffix to both either puts both in the language or neither — then the strings are effectively the same from the language's perspective. The Myhill-Nerode theorem says: count these equivalence classes. If the count is finite, you can build a finite machine to recognize the language. If it's infinite, you can't. End of story.

This theorem didn't just classify languages. It *explained* what recognition means at its deepest level. Recognition is quotient finiteness — the collapse of infinite variation into finite distinguishability.

Now, nearly seventy years later, a team of researchers has shown that the same algebraic principle governs something far more ambitious: the learnability of artificial neural networks.

## The Three Faces of Learnability

In machine learning, the question of what can be learned has three traditional answers, each from a different mathematical tradition.

The **combinatorial answer** comes from VC theory, named after Vladimir Vapnik and Alexey Chervonenkis. They defined a number — the VC dimension — that measures how many data points a hypothesis class can "shatter," meaning it can produce every possible labeling. A class with finite VC dimension can be learned from finite data. One with infinite VC dimension cannot.

The **algorithmic answer** comes from sample compression theory. A hypothesis class is learnable if you can always compress your training data down to a small "core" set, plus a finite recipe, from which you can reconstruct a classifier that works on the full dataset. The smaller the compression, the better the generalization.

The **algebraic answer** — the new one — says: define an equivalence relation on inputs, where two inputs are "equivalent" if no hypothesis in your class can tell them apart. If this equivalence has finitely many classes, you can learn. If it doesn't, you can't.

What the new research proves is that these three answers are the same.

## Indistinguishability Is Everything

The key insight is almost philosophical: *what you can't distinguish, you can't learn about.*

Consider a neural network trained to classify images. The network processes an image through successive layers, each performing mathematical transformations. At the end, it outputs a label: cat or dog, spam or not-spam, tumor or healthy tissue.

Now imagine two images that produce identical outputs for *every* possible setting of the network's parameters. No matter how you train the network, no matter what weights you choose, these two images always get the same label. From the network's perspective, they are invisible twins — forever indistinguishable.

The new theory groups all inputs into equivalence classes based on this indistinguishability relation. The resulting mathematical object — the *classification quotient* — turns out to control everything about the network's learning capacity.

## The Quotient Controls Everything

The central theorem has a startling directness. If the classification quotient has *N* equivalence classes, then:

1. **The VC dimension is at most *N*.** You cannot shatter a set larger than the number of equivalence classes, because distinct elements of a shattered set must land in distinct classes. (If two elements shared a class, you could never assign them different labels — contradicting shattering.)

2. **There exists a compression scheme of size at most *N*.** Given any training set, you can select at most *N* representative examples — one per equivalence class — and from those, reconstruct a classifier that works on the entire training set.

The proof of the first claim is beautifully simple. A shattered set must inject into the quotient (distinct points get distinct classes, as we argued above). An injection from a finite set into a finite type means the domain has at most as many elements as the codomain. Therefore, shattered sets can't be larger than the quotient.

The compression claim follows from the factorization property: every hypothesis in the class is constant on equivalence classes. So knowing the label of one representative per class determines all labels. You only need one point per class — at most *N* total.

## The Tropical Connection

But why "tropical"? The name comes from a branch of mathematics called tropical geometry, which replaces ordinary arithmetic with a strange variant where addition means "take the maximum" and multiplication means "add." This sounds bizarre, but it captures the geometry of piecewise-linear functions — exactly the kind of functions that neural networks with ReLU activations compute.

In a tropical semiring, the equation *a + a = a* holds (the maximum of a number with itself is just the number). This *idempotent* property gives the algebra a rigidity that classical arithmetic lacks. When neural network computations are reinterpreted through this tropical lens, the evaluation of each layer becomes a tropical linear form, and the network's behavior is carved up by a *tropical evaluation fan* — a polyhedral structure where the activation patterns are constant.

The equivalence classes of the classification quotient correspond, in this tropical picture, to cells of the evaluation fan. The theorem then says: if the fan has finitely many cells (which it always does for finite-width networks), then the VC dimension is bounded and compression is possible.

This is not merely a reformulation. It's a *geometric explanation* of learnability. The network can learn because its computational geometry is piecewise-linear, and piecewise-linear geometry has only finitely many pieces.

## Why This Matters Beyond Mathematics

The implications for artificial intelligence are concrete and practical.

**Architecture certification.** Today, when engineers design a neural network, they estimate its learning capacity by counting parameters — the number of adjustable weights. But parameter count is a crude proxy. Two networks with the same number of parameters can have vastly different quotient sizes, and therefore vastly different effective capacities. The quotient provides a certificate of learnability that is algebraically exact, not merely statistical.

**Model compression.** The compression theorem gives a principled method for reducing model size. Instead of ad hoc pruning techniques that remove weights based on magnitude or gradient, the quotient identifies which data points are truly redundant — those that share an equivalence class with a retained representative. This is compression by algebra, not heuristics.

**Generalization guarantees.** Classical generalization bounds based on VC dimension tend to be loose. The quotient-based compression bound can be significantly tighter, because the compression size (the number of equivalence classes that actually appear in a sample) is often much smaller than the VC dimension itself.

**Interpretability.** The equivalence classes have a natural interpretation: they are the "concepts" that the network can distinguish. By examining the quotient, one can determine exactly what distinctions a given architecture is capable of making — and, equally importantly, what distinctions it is inherently blind to.

## The Automata-Theoretic Parallel

The analogy with automata theory runs deeper than metaphor. In the Myhill-Nerode theorem for formal languages, the finite quotient corresponds to the states of the minimal automaton. Each state represents a residual behavior — what the machine will do with remaining input.

In the new learning theory, each equivalence class represents a residual prediction — how the class will label an input regardless of which specific hypothesis is chosen. The quotient is the "minimal classifier" in exactly the same sense that the Myhill-Nerode quotient gives the minimal automaton.

This parallel suggests an entire program of research. Just as the Myhill-Nerode theorem led to algorithms for minimizing automata, the classification quotient theorem could lead to algorithms for minimizing neural architectures — finding the smallest network that computes the same classification function.

## What Comes Next

The forward direction — finite quotient implies finite VC dimension and compression — is now rigorously established. The converse direction, showing that finite VC dimension forces a finite quotient under structural hypotheses, is partially established for finite semirings and bounded-width operads.

The full converse, if true, would complete the circle: learnability, in any form, would be provably equivalent to algebraic finiteness. This would mean that every learnable hypothesis class admits a finite algebraic "explanation" — a quotient structure that encodes exactly what distinctions matter.

Beyond the converse, the tropical geometric perspective opens connections to Newton polytopes, regular subdivisions, and tropical convexity. There is a tantalizing possibility that the optimal compression size equals the VC dimension in a "canonical" regime — when the tropical evaluation fan has no redundant cells. If this equality holds, it would mean that the minimum amount of information you need to learn is exactly the maximum number of distinctions you can make — a perfect duality between capacity and compression.

## The Bigger Picture

For a century, learning theory and formal language theory developed in parallel, sharing intuitions but never truly merging. VC dimension and Myhill-Nerode quotients seemed to live in different mathematical worlds — one combinatorial, the other algebraic.

The tropical VC duality theorem bridges these worlds. It says that the combinatorial capacity of a learning system, the algebraic structure of its indistinguishability quotient, and the algorithmic efficiency of sample compression are three views of a single invariant. Change one, and you change them all.

This is not just a technical advance. It's a shift in perspective. It suggests that learnability is not fundamentally a statistical phenomenon — it is an algebraic one. The reason a finite neural network can learn is not that it has the right number of parameters, or that it was trained with the right algorithm, or that the data happened to be nice. It is that the algebra of its computation forces a finite quotient — a finite number of truly distinguishable inputs.

In the end, learning is forgetting. And the algebra tells you exactly how much.
