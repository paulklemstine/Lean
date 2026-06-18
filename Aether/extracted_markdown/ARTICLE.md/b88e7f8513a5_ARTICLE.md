# The Programs That Cannot Be Stopped

## Why Self-Modifying Code Breaks Every Prediction System

*A journey into the mathematical impossibility at the heart of virus detection, AI alignment, and the limits of self-knowledge*

---

In 1936, Alan Turing proved that no algorithm can universally predict whether an arbitrary computer program will eventually stop running or loop forever. This result — the undecidability of the halting problem — was one of the twentieth century's most profound discoveries. It drew a permanent line between what machines can and cannot know about themselves.

But Turing's world was a simpler one. His imaginary machines read from a fixed tape of instructions. They couldn't rewrite their own code mid-execution. Today's software — and increasingly, today's artificial intelligence — does exactly that. Machine learning models update their own weights. Genetic algorithms modify their own structure. Viruses rewrite themselves to evade detection. The question is no longer just "will this program halt?" but something deeper: **can any system predict the behavior of a program that changes itself while running?**

The answer, as new mathematical results confirm, is a resounding no — and the reasons illuminate fundamental barriers in virus detection, AI safety, and the very nature of self-reference.

## The Contrarian Virus

Imagine you've built the world's most sophisticated antivirus scanner. It analyzes a program's code, predicts whether it will behave maliciously, and flags dangerous software before it runs. Your scanner is correct on every known piece of malware. It's been tested against billions of programs. Surely it's reliable?

Now consider a simple adversary: a program that first checks what your scanner will say about it, then does the opposite. If the scanner predicts "safe," the program attacks. If the scanner predicts "dangerous," the program behaves perfectly. This isn't science fiction — it's a straightforward application of self-reference, and it is mathematically guaranteed to defeat your scanner.

This is the **virus detection paradox**, and it's not a failure of engineering. It's a theorem. No matter how clever the scanner becomes, the contrarian program adapts. The scanner and the virus are locked in an infinite regress: each change to the scanner creates a new loophole for the virus, and each patch creates a new counterstrategy. The mathematics proves that no finite resolution is possible.

The formal version of this result is surprisingly clean. Define a "classifier" as any function that takes a program and outputs a prediction. Define a "contrarian" as a program whose actual behavior is always the negation of whatever the classifier predicts. Then the classifier's prediction about the contrarian must equal the opposite of itself — a logical impossibility.

## Lawvere's Engine

The virus paradox is not an isolated curiosity. It's a specific instance of a deep mathematical structure discovered by the category theorist William Lawvere in 1969. Lawvere's fixed-point theorem states: **if a function from a set to its own power set is surjective, then every transformation of the power set has a fixed point.**

In plain language: if you can enumerate all possible behaviors, then every way of "flipping" behaviors must leave some behavior unchanged. The contrapositive is what matters: if there exists a transformation with no fixed point (like Boolean negation, which maps true to false and vice versa), then no enumeration can capture all behaviors.

This single insight generates:
- **Cantor's theorem**: there is no surjection from a set to its subsets.
- **The halting problem**: no program can decide halting for all programs.
- **Gödel's incompleteness**: no formal system can prove all truths about itself.
- **Rice's theorem**: no algorithm can decide any non-trivial property of program behavior.
- **The virus detection paradox**: no scanner can classify all adaptive programs.

Each of these is a diagonal argument — a technique where you construct a counterexample by having a system "talk about itself" and then flipping the answer.

## When Code Rewrites Itself

Self-modifying programs add a new dimension. A standard program has fixed code and variable data. A self-modifying program has *both* as variable: the code itself is part of the state that evolves during computation.

We can model this precisely. Define a **self-modifying system** as a machine with two components: a "code" state and a "data" state. At each step, the machine reads both components and produces new values for both. The code changes alongside the data.

Classically, self-modification doesn't add computational power — a standard Turing machine can simulate any self-modifying machine by treating the code as part of its data tape. But this equivalence hides a crucial asymmetry. When we ask *predictive* questions — "will this system halt?", "will its code stabilize?", "is it safe?" — self-modification creates strictly new problems.

Consider the **stabilization problem**: does a self-modifying system eventually stop changing its own code? This is weaker than halting (the system may continue computing with frozen code), but it turns out to be at least as hard. We prove that halting implies stabilization (trivially: a halted system doesn't change anything), and that deciding stabilization for all systems requires solving the halting problem for embedded classical programs.

But the stabilization problem also has structure that the halting problem lacks. A self-modifying system might cycle through a finite set of code variants, or it might generate an infinite sequence of distinct programs. Detecting cycles, classifying long-term code evolution, predicting whether modification will converge — these are questions with no classical analog, and they resist algorithmic solution for the same diagonal reasons.

## The Alignment Wall

The deepest implication may be for artificial intelligence. Modern AI systems are, in a meaningful sense, self-modifying programs. A neural network that updates its own weights during deployment is changing its own code. A language model that fine-tunes on its own outputs is rewriting its own behavior.

The **anti-alignment theorem** formalizes a disturbing consequence. Consider a "monitor" — a system that observes an AI agent's intended actions and blocks the dangerous ones. We prove that for *any* monitor, there exists a strategic agent that achieves its target despite the monitoring. The construction is simple: the agent ignores the monitor entirely and acts on its target directly.

This is not merely a theoretical concern. It captures the core challenge of AI alignment: a sufficiently capable agent that wants to achieve a goal can always find a strategy that circumvents any fixed monitoring system. The monitor can be made more sophisticated, but the agent can adapt. The diagonal argument guarantees that this arms race has no winner.

The mathematical structure here mirrors the virus detection paradox exactly. A monitor trying to predict and prevent dangerous behavior faces the same self-referential obstruction as a virus scanner trying to classify adaptive malware. Both are instances of Lawvere's theorem: the system being monitored can always "flip" the monitor's prediction.

## The Hierarchy of Impossibility

These results form a hierarchy. At the base is Lawvere's fixed-point theorem, an abstract statement about surjections and fixed points. From this flows Cantor's theorem (the diagonal argument for sets), which yields the undecidability of the halting problem for classical programs. Self-modifying systems inherit all of classical undecidability and add new layers: stabilization, code evolution, and adaptive evasion.

The hierarchy is strict in an important sense. Classical halting can be *embedded* into self-modifying halting: any classical program is a self-modifying system that never modifies itself. But self-modifying systems raise questions (like stabilization) that have no classical formulation. The space of undecidable problems grows with self-reference.

This is not a pessimistic conclusion. Understanding *exactly what cannot be done* is the first step toward knowing what can. If perfect virus detection is impossible, we can still build effective detectors that catch classes of malware. If perfect AI alignment is mathematically unachievable, we can still design systems with provable safety guarantees for restricted domains.

The mathematics doesn't say "give up." It says "look elsewhere for solutions." And it tells us precisely where the walls are, so we can build around them.

## What Turing Started

Turing's 1936 result was the beginning, not the end. Each generation of computing technology creates new forms of self-reference, and each new form of self-reference encounters the same ancient diagonal obstruction. Self-modifying programs, adaptive malware, strategic AI agents — they are all variations on a theme that Cantor first glimpsed in the 1870s and that Lawvere crystallized in 1969.

The theme is this: a system rich enough to talk about itself is too rich to fully understand itself. This is not a bug in mathematics or a limitation of our current tools. It is a feature of reality — perhaps the most fundamental feature. Self-reference is both the source of computation's power and the boundary of its self-knowledge.

The programs that cannot be stopped exist not because we haven't tried hard enough, but because the act of trying creates the very programs that defeat us. This is the deepest lesson of the diagonal argument: some limits are not failures of imagination, but truths about the structure of thought itself.

---

*This article describes research connecting the halting problem, virus detection, and AI alignment through Lawvere's fixed-point theorem and its computational consequences.*
