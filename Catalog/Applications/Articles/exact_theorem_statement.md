# The Hidden Architecture of Mathematical Machines

## When Machines Dream in Algebra

Somewhere between the sweeping abstractions of pure mathematics and the gritty engineering of artificial intelligence lies a question that has quietly haunted researchers for decades: *What, exactly, makes one mathematical system more expressive than another?*

Consider two music synthesizers. One can produce sine waves, square waves, and saw-tooth waves. The other can produce only sine waves—but it can combine them in arbitrary ways: adding them, multiplying them, feeding one into another. Which synthesizer is more powerful? The answer isn't obvious. The second machine, despite starting with less, might generate everything the first can produce and more, simply through its ability to compose.

This is not just an analogy. It is, at its core, a mathematical question about **closure**—the idea that combining elements from a starting set can generate an entire universe of new objects. And a team of researchers has just established a result that transforms how we understand these generative universes: a precise, machine-verified duality between the things you start with and the worlds they create.

## The Closure Problem

The concept of closure is one of mathematics' most powerful organizing ideas, though most people encounter it without realizing it.

Take the integers. Start with the number 1. Add it to itself: you get 2. Add again: 3, 4, 5, and so on. You have "closed" the set {1} under addition to generate all positive integers. Now allow subtraction too, and you generate all integers. Allow division, and you leap into the rationals. Each operation you permit expands the universe you can reach.

The same principle operates in far more exotic settings. In algebraic geometry, polynomials generate algebraic varieties—the curved surfaces and twisted shapes that underpin much of modern mathematics. In logic, axioms generate theorems. In machine learning, a set of basic functions, combined through addition, multiplication, and composition, generates an entire class of models—the functions a neural network can represent.

This last example is the setting for the new result. The researchers studied what they call **Expressive Model Logic** (EML): a framework where you start with a set of basic real-valued functions and systematically build new ones through four operations—using constants, adding functions pointwise, multiplying them pointwise, and composing them (plugging one function into another). The set of all functions you can build this way is the **EML closure** of your starting set.

## An Ancient Pattern, Reimagined

The EML closure turns out to satisfy three fundamental properties that mathematicians have studied since the early twentieth century:

**Extensivity**: Your starting functions are always in the closure. (You can always do nothing.)

**Monotonicity**: If you start with more functions, you get a bigger closure. (More ingredients, more recipes.)

**Idempotence**: Closing something that's already closed does nothing. (Once you've generated everything you can, applying the process again adds nothing new.)

These three properties define what mathematicians call a **closure operator**—a concept that unifies an astonishing range of mathematical structures. The convex hull in geometry is a closure operator: given a set of points, it generates the smallest convex shape containing them. The algebraic closure in field theory is one too: given a field, it generates the smallest field where every polynomial has a root. Topological closure, linear span, radical of an ideal—all closure operators.

What the researchers proved is that EML closure isn't just *analogous* to these classical constructions—it's an instance of the same abstract structure. And this unlocks a remarkable theorem.

## The Duality

Here is the key insight, expressed without any technical machinery:

> **Every question about what a model class can express is secretly a question about what generates it, and vice versa.**

More precisely: there is a perfect mathematical correspondence—a **Galois connection**—between sets of generator functions and the closed classes they produce. The connection says:

*The closure of A is contained in a closed class C if and only if A is contained in C.*

Read that again. It's almost tautological, yet it encodes something profound. It means that checking whether one expressive class fits inside another reduces to checking a simple set inclusion on their generators. No need to reason about the infinite cascade of additions, multiplications, and compositions that the closure produces. The duality compresses an infinite process into a finite check.

This result was strengthened into a **Galois insertion**—an even tighter correspondence that guarantees the closure map and the inclusion of closed sets are not merely related but are essentially inverse operations on the appropriate mathematical objects.

## Why Galois?

The name honors Évariste Galois, the tragic French mathematician who died in a duel at age 20 in 1832, having revolutionized algebra the night before his death. Galois discovered that the solvability of polynomial equations is governed by a correspondence between subgroups of a symmetry group and intermediate fields—what we now call a Galois connection.

The same pattern appears everywhere. In formal concept analysis, a branch of applied mathematics developed in the 1980s, Galois connections link objects to their attributes, generating a lattice of "concepts" that organizes knowledge. In computer science, abstract interpretation uses Galois connections to relate concrete program behaviors to their abstract approximations, enabling automated program verification.

The EML duality extends this pattern into the world of function classes and expressive power. It says that the universe of model classes has an inherent algebraic structure—a lattice, in fact—where every class has a canonical position, and the relationships between classes are governed by clean algebraic laws.

## The Moore Family

A consequence of the duality is that EML-closed classes form what mathematicians call a **Moore family**: any intersection of closed classes is again closed. This might sound like a technicality, but it has sweeping consequences.

It means the closed classes form a **complete lattice**—a mathematical structure where any collection of classes has both a greatest common subclass (their intersection) and a smallest common superclass (the closure of their union). This lattice is the taxonomy of expressive power: a periodic table for model classes, where each element has a definite position relative to every other.

In practical terms, this means:
- You can always find the **most specific** model class that contains two given classes (take the closure of their union).
- You can always find the **most general** model class that both classes share (take their intersection).
- These operations satisfy all the algebraic laws of a lattice, enabling systematic reasoning about expressivity.

## The Core: What Must Be There

The researchers also defined and studied the **EML core** of a class—the intersection of all generator sets whose closure contains that class. Think of it as the essential content, the functions that *must* be present in any generating set for the class.

They proved that the core is always contained in the original class (nothing extraneous sneaks in) and that it's monotone (larger classes have larger cores). They also showed that the core is always contained in the "minimal generators" intersection—the functions common to all sets whose closure *equals* the class—establishing a precise hierarchy:

*Core ⊆ Minimal Generators ⊆ Class*

This hierarchy separates three levels of "necessity" for membership in a model class. A function in the core is universally necessary. A function in the minimal generators is necessary for exact generation. A function merely in the class might be derivable from simpler ingredients.

## Real-World Reverberations

Why should anyone outside pure mathematics care about Galois connections for function classes?

**Model compression.** Modern neural networks have millions of parameters, but often their expressive power can be characterized by a much smaller generating set. The Galois duality provides a mathematical framework for finding these generators—the essential "atoms" of expressivity from which everything else can be derived. Compress the generators, and you compress the model.

**Architecture search.** When designing neural networks, engineers choose activation functions, layer structures, and composition patterns. The closure operator framework says: two architectures are expressively equivalent if and only if they generate the same closed class. This gives a rigorous criterion for comparing architectures without exhaustive empirical testing.

**Interpretability.** Understanding what a model *can* express is a prerequisite for understanding what it *does* express. The lattice of closed classes provides a roadmap of expressive possibilities, while the core operator identifies the irreducible building blocks.

**Learning theory.** The complexity of learning a function class is intimately related to its algebraic structure. Closure dimension—the minimum number of generators needed—is an EML analogue of VC dimension, the classic measure of learning complexity. The Moore family structure enables systematic study of how expressive complexity relates to learnability.

## A Larger Canvas

The result sits at a confluence of ideas that span centuries. Galois' original connection between groups and fields. The lattice theory developed by Birkhoff and Ore in the 1930s and 40s. The abstract interpretation framework of Cousot and Cousot in the 1970s. The formal concept analysis of Wille in the 1980s. And now, the expressive model logic framework for understanding modern function approximation.

What makes this synthesis remarkable is not just that it connects these ideas but that it does so through a single, clean algebraic structure. The Galois insertion between generators and closed classes is not an approximation or an analogy—it is an exact mathematical fact, verified down to the foundational axioms of mathematics.

This is the kind of result that changes how researchers think about a field. Before, the expressive power of function classes was studied case by case, architecture by architecture. Now there is a universal framework: a closure system with canonical invariants, a lattice with algebraic structure, a duality that converts between syntax and semantics.

The periodic table didn't just classify elements—it predicted new ones. The Galois duality for EML may do the same for model classes: not just organizing what we know, but revealing what we haven't yet imagined.

## What Comes Next

The immediate frontier is rich. Can we compute closure dimensions for specific function classes—polynomials, rational functions, compositions of ReLUs? Can we prove an EML analogue of the Nullstellensatz, connecting zero sets of generators to zero sets of the closure? Can we build practical algorithms that exploit the lattice structure for architecture search and model compression?

Each of these questions is now well-posed within the closure-theoretic framework. The hard work of establishing the foundations has been done. What remains is exploration—and that, as any mathematician will tell you, is the best part.
