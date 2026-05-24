# When Programs Shrink to Their Essence

## The Map That Remembers Only What Matters

Imagine you have two recipes for chocolate cake. One calls for sifting the flour three times; the other sifts twice and adds an extra fold. The cakes taste identical. A master baker, watching both processes, would say: "These are the same recipe." But how would you prove it?

Computer scientists face a version of this problem every day, at a scale that makes cake recipes look trivial. Modern software routinely contains millions of lines of code, and two programs written by different teams can look completely different on the page yet do exactly the same thing. Proving they're equivalent — that no possible input will ever produce a different output — is one of the deepest problems in the field.

For decades, mathematicians have had a beautiful tool for solving this problem in simple settings. If you want to prove that two text-processing programs accept exactly the same inputs, you can build the simplest possible machine (a "minimal automaton") that does what each program does, then check whether the two minimal machines are identical. This technique, rooted in a 1957 theorem by Anil Nerode, is one of the jewels of theoretical computer science. It works because every regular language has a unique minimal recognizer — a canonical form that strips away all irrelevant structural choices.

But there's a catch. Nerode's theorem only works for the simplest kind of programs: those that read their input one character at a time, from left to right, with a fixed amount of memory. Real programs are far more powerful. They call functions, pass other functions as arguments, and build complex data structures. For these higher-order programs, no comparable minimization theory has existed.

Until now.

## The Breakthrough: Finite-State Portraits of Higher-Order Programs

A new mathematical result establishes that every well-typed program in a fundamental programming language — the simply typed lambda calculus — possesses a canonical finite-state portrait. This portrait captures everything observable about the program's computational behavior up to any bounded depth, and it is unique: two programs that compute the same function will always produce the same portrait.

The key idea is deceptively simple. Take a program and watch what happens when you run it. At each step, the program transforms into a new state — a partially evaluated version of itself. After one step of computation, there might be several possible next states (because evaluation can proceed in different orders). After two steps, more states become reachable. After three steps, more still.

This branching tree of possibilities is called a *finite transition system* — an "FTS" for short. It's a map of everywhere the program can go within a fixed number of computational steps.

Here's the critical mathematical fact: for well-typed programs, this map is always finite. No matter how complex the program, there are only finitely many states reachable within any bounded number of steps. This was already known. What's new is what happens next.

## Shrinking the Map

The map contains redundancies. Some states in the FTS are, from a behavioral standpoint, indistinguishable — they lead to the same future possibilities, satisfy the same logical properties, and ultimately produce the same outputs. Mathematicians call two such states *bisimilar*: they simulate each other perfectly.

The new result shows three remarkable things about what happens when you collapse all bisimilar states into one:

**First, the collapsed map stabilizes.** As you increase the number of allowed computation steps, the transition system grows — but the *pattern* of the collapsed map eventually stops changing. Beyond a certain depth, adding more computational budget reveals no new behavioral distinctions. The finite portrait becomes permanent.

**Second, the size of the collapsed map is bounded by the program's type alone.** A program that takes a number and returns a number has one bound. A program that takes a function and returns a function has another, larger bound. But the bound depends only on the type structure, not on the specific program. This is like saying: there are only so many fundamentally different flavors a chocolate cake can have, regardless of how baroque the recipe.

**Third, programs that compute the same function produce the same collapsed map.** This is the crown jewel. If two programs are β-equivalent — the mathematical term for "they compute the same thing" — then their minimized finite-state portraits are identical. The portrait is a *semantic* object, determined by what the program does, not how it's written.

## The Nerode Connection

This three-part result is a higher-order generalization of the Myhill-Nerode theorem, one of the most important results in automata theory. In the classical setting, Nerode showed that every regular language has a unique minimal deterministic finite automaton (DFA). The number of states in this minimal DFA is a complete invariant: two DFAs recognize the same language if and only if their minimal versions are identical.

The new theorem does something analogous, but in a setting that's vastly more expressive. Instead of finite automata reading strings of characters, we have transition systems tracking the evaluation of higher-order programs — programs that manipulate other programs as data. Instead of string languages, we have computational behaviors. And instead of DFA minimization, we have bisimulation quotients.

The connection runs deeper than analogy. In Nerode's theorem, the equivalence classes that define the minimal automaton are precisely the classes of strings that are indistinguishable by any continuation. In the new result, the equivalence classes are defined by modal logic: two states are equivalent if they satisfy exactly the same formulas in a temporal logic that can express statements like "it is possible to reach a state where property P holds." This behavioral equivalence — formalized as "bisimulation" — is the higher-order cousin of Nerode equivalence.

## What It Means

Why does this matter beyond pure mathematics?

**For programming language theory:** The result provides a rigorous foundation for comparing programs semantically rather than syntactically. Two programs that look different but behave the same will be recognized as equivalent by the minimization procedure. This has implications for compiler optimization (two code paths can be merged if their minimized FTS are identical), program verification (checking equivalence reduces to computing and comparing finite portraits), and software testing (canonical forms can serve as reference implementations).

**For complexity theory:** The type-indexed bound on the minimized FTS size creates a new kind of complexity measure. The "state complexity" of a type — how many distinguishable computational behaviors it permits — is a fundamental quantity that connects the structure of types to the structure of computation. This quantity has never been studied before.

**For mathematics:** The result bridges four fields that have developed largely independently: lambda calculus (the algebra of computation), automata theory (the geometry of finite machines), coalgebra (the abstract theory of systems and observations), and modal logic (the logic of possibility and necessity). The bisimulation quotient is simultaneously a coalgebraic construction, an automata-theoretic minimization, a logical invariant, and a computational normal form. Finding a single object that lives at the intersection of all four fields is rare.

## The Proof in Broad Strokes

The proof weaves together three mathematical threads.

The first thread is *König's Lemma for strongly normalizing terms*. In a well-typed program, every computation eventually terminates — this is the "strong normalization" property. Moreover, at each step, there are only finitely many possible next moves. A classical result in combinatorics (König's Lemma) says that a tree with finitely many branches at each node and no infinite paths must itself be finite. Applied to the computation tree of a typed program, this gives finiteness of the total reachable set — the states are bounded.

The second thread is *ascending chain stabilization*. The bounded state sets grow monotonically as the depth increases: more computation steps reveal more reachable states. But since the total reachable set is finite, this growth must eventually stop. After finitely many stages, the bounded state set equals the total reachable set, and all further increases in depth are vacuous. This is the stabilization result.

The third thread is *normal form canonicity*. Two β-equivalent well-typed programs share a unique normal form — an irreducible "answer" that both eventually produce. Normal forms have a trivial FTS (just one state, no transitions). The Church-Rosser property ensures that β-equivalent normal forms are syntactically identical. This identity of normal forms, combined with the behavioral equivalence results from earlier work in this program, yields the β-invariance of the minimized portrait.

## Looking Forward

The results proved here are a beginning, not an endpoint. The current type-uniform bound is likely not tight: the actual maximum number of behavioral equivalence classes for a given type is probably much smaller than the bound suggests. Computing this maximum exactly — the "state complexity" of each type — is an open problem whose answer would illuminate the combinatorial structure of higher-order computation.

More ambitiously, the theory should extend to richer type systems: polymorphism, dependent types, and recursive types. Each extension brings new challenges. Polymorphic programs can behave differently at different type instantiations. Dependent types create intricate connections between terms and types. Recursive types may produce infinite-state behaviors that require different minimization techniques.

The deepest open question is whether the minimized FTS is a *final coalgebra* in an appropriate category — the categorical formalization of "canonical form." If so, the entire theory would reduce to a statement about universal properties, connecting it to the deepest currents in mathematical logic and abstract algebra.

What began as a question about comparing programs has led to a new mathematical object — the canonical finite-state portrait of a typed computation — that sits at the crossroads of logic, algebra, combinatorics, and computation. Like all good mathematics, it reveals structure that was always there, hidden in plain sight, waiting for the right lens to bring it into focus.
