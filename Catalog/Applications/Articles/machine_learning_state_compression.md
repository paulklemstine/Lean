# When AI Forgets: The Mathematics of Compressing Memory

## The Problem of Too Many States

Imagine a self-driving car's computer, processing sensor data sixty times per second. At each tick, the system updates its internal state—a snapshot of everything it "remembers" about the road, the weather, other vehicles, its own speed. The number of possible internal states is staggering: even a modest neural network might cycle through billions of configurations.

Now imagine you need to verify that this system is safe. You need to check every possible loop the computer's memory could get stuck in—every repeating pattern of states the system could cycle through forever. With billions of states, that task is practically impossible.

So engineers do something clever: they compress. They build a smaller model—a simplified version of the system with far fewer states—and verify *that* instead. If the small model is safe, they argue, the big one should be too.

But here's the terrifying question: *how do you know the compression didn't throw away something critical?*

## A Bridge Between Two Worlds

This question sits at the intersection of two fields that rarely talk to each other. On one side, there's **dynamical systems theory**, the branch of mathematics that studies how systems evolve over time. On the other side, there's **machine learning**, where neural networks learn compressed representations of complex data.

For decades, mathematicians have studied a concept called *semiconjugacy*—a precise way of saying that two dynamical systems are related by an encoding map. If you have a big system with states updated by some rule *f*, and a small system with states updated by rule *g*, and an encoder *e* that maps big states to small states, then semiconjugacy means that encoding first and then updating gives you the same answer as updating first and then encoding.

In symbols: *e(f(x)) = g(e(x))* for every state *x*.

This is exactly what a well-trained neural network encoder does. It compresses a high-dimensional state into a low-dimensional one while preserving the temporal structure—the way the system evolves over time. The mathematics of the 19th century and the engineering of the 21st century are describing the same thing.

## The Memory Compression Theorems

A team of researchers has now proved a suite of theorems that make this connection precise and quantitative. Their results answer three fundamental questions about what happens to repeating patterns—cycles, loops, periodic orbits—when you compress a system.

### Theorem 1: Compression Cannot Create False Memories

The first result is reassuring: if a state *x* in the big system returns to itself after *n* steps (it has period *n*), then its compressed image *e(x)* also returns to itself after *n* steps in the small system. The compressed system inherits the periodicity exactly.

Moreover, the actual period of the compressed point must *divide* the original period. If a neuron in your brain fires in a pattern that repeats every 12 milliseconds, and you compress the model, the compressed version might show a period of 12, 6, 4, 3, 2, or 1—but never 7 or 5 or 13. The compressed system can simplify rhythms but cannot fabricate new ones.

This is the **period divisibility theorem**: compression can only reduce or preserve cycle lengths, never inflate them.

### Theorem 2: Compressed Memories Are Real

The second result goes in the other direction. Suppose you've built your compressed model and you observe a repeating pattern in it. Is that pattern real—does it correspond to an actual repeating behavior of the original system?

The answer is yes, under one natural condition: the encoder must be surjective, meaning every compressed state actually corresponds to some real state. (If your compression scheme can produce "hallucinated" states that don't correspond to anything real, all bets are off.)

Under surjectivity, the theorem guarantees that every periodic orbit in the compressed system lifts to a genuine periodic orbit in the original system. The memory loop you see in the small model is not a compression artifact—it reflects real recurrent behavior of the full system.

This is the **periodic orbit lifting theorem**: compressed attractors certify real attractors.

### Theorem 3: Memory Requires Space

The third result is perhaps the most surprising. It provides a hard lower bound on how small your compressed model can be.

If the compressed system contains a state that cycles with exact period *n*—meaning it returns to itself after *n* steps but not sooner—then the compressed state space must contain at least *n* states.

Think about what this means. If your original system has a memory loop of length 100, and compression preserves that loop exactly, then your compressed model needs at least 100 states just to accommodate that one loop. You cannot cheat the information theory: periodic memory of length *n* requires storage for at least *n* distinct states.

This is the **capacity lower bound theorem**: exact recurrent memory requires proportional latent capacity.

## Why This Matters Beyond Mathematics

These theorems are not merely abstract exercises. They have immediate implications for several practical domains.

**Safety verification of AI systems.** When engineers verify that a neural controller avoids dangerous states, they typically work with a simplified abstract model. The lifting theorem guarantees that if the abstract model has no dangerous cycles, neither does the real system (under semiconjugacy). This transforms an informal engineering practice into a mathematically certified procedure.

**Understanding biological neural circuits.** Neuroscientists have long known that the brain compresses sensory information into compact internal representations. The period divisibility theorem tells us exactly how this compression interacts with neural oscillations—the rhythmic firing patterns that are thought to underlie memory, attention, and consciousness. Compression can simplify rhythms but cannot create rhythms that weren't there in the raw signal.

**Designing efficient hardware.** The capacity lower bound tells chip designers the minimum number of states their compressed hardware implementation needs to faithfully reproduce the behavior of a larger system. It's an information-theoretic floor that no clever engineering can bypass.

**Automata minimization.** In computer science, the problem of finding the smallest finite-state machine that behaves identically to a given one is a classical problem. These theorems extend the theory to approximate quotients—cases where the small machine doesn't behave identically but preserves essential periodic structure.

## The Deeper Pattern

There is something philosophically striking about these results. They show that *memory has geometry*.

A repeating cycle of length *n* is, in some sense, a circle with *n* points on it. When you compress, you can fold the circle into a smaller circle (whose circumference divides the original), but you cannot unfold it into a larger one. You can project a circle onto a point, collapsing all memory, but you cannot project it onto a different, incompatible circle.

This is reminiscent of deep results in topology: continuous maps between circles have integer degrees, and the degree constrains what the map can do to winding numbers. The period divisibility theorem is the finite, discrete analogue of this topological principle.

It also connects to information theory's core insight: compression is constrained by structure. Shannon showed that you cannot compress a signal below its entropy without losing information. These theorems show that you cannot compress a dynamical system below the complexity of its periodic orbits without losing temporal structure.

## What Comes Next

The results established here are the foundation of a larger program. Several natural extensions are already within reach.

First, the theory should extend to *pre-periodic* points—states that eventually fall into a cycle but aren't themselves on one. These represent transient behaviors, and understanding how they compress is important for bounding how long transient dynamics can last in compressed models.

Second, counting the number of distinct cycles before and after compression should yield entropy-like lower bounds on the size of the compressed system. This would connect semiconjugacy theory to Shannon entropy and topological entropy.

Third, there are tantalizing connections to circuit complexity. If a compressed system must faithfully reproduce a cycle of length *n*, then any circuit implementing the compression must have sufficient depth or gate count. This suggests that dynamical memory complexity and computational complexity are two faces of the same coin.

## The Bottom Line

When we compress a dynamical system—whether it's a neural network, a biological brain, or an industrial controller—we are not performing an arbitrary lossy operation. We are performing a quotient, governed by rigid mathematical laws.

These laws guarantee that compression cannot fabricate periodic memories that don't exist, that observed compressed memories are real, and that faithful compression of long-period behavior demands proportionally large state spaces.

In a world increasingly dependent on AI systems whose internal representations we don't fully understand, these guarantees matter. They are the beginning of a mathematical theory that can certify not just what a compressed model *says*, but what it *remembers*—and whether those memories are real.
