# The Program That Refuses to Be Predicted

Imagine you are handed a piece of software with a superpower: while it runs, it can *rewrite its own instructions*. Not just its data — its actual code. A line that today says "add two numbers" can, a microsecond later, overwrite itself to say "erase the hard drive." Living viruses do a pale version of this; so do the most aggressive computer worms, self-optimizing compilers, and — increasingly — machine-learning systems that edit their own routines. Faced with such a shape-shifting adversary, a natural dream takes hold: build a perfect *watchdog*, a single algorithm that reads any such program and reliably reports whether it will eventually stop or run forever.

This article is about why that dream is impossible, why the impossibility is *exactly as bad* as the classical impossibility discovered ninety years ago and not one shred worse, and why understanding the difference matters for the safety of artificial intelligence.

## The oldest impossibility in computing

In 1936, Alan Turing proved that there is no general algorithm that can look at an arbitrary program and its input and decide, in finite time, whether that program will halt or loop forever. This is the **halting problem**, and its undecidability is a load-bearing pillar of computer science. The proof is a magic trick performed with a single mirror. Suppose a perfect halting-detector $H$ existed. Then you could build a contrarian program $D$ that first asks $H$ what *it* is going to do, and then deliberately does the opposite: if $H$ says "$D$ halts," then $D$ loops forever; if $H$ says "$D$ loops," then $D$ halts. Now ask the fatal question: what does $H$ predict about $D$ running on its own code? Every possible answer is a lie. The detector cannot exist.

That contrarian program — the one that reads a prediction about itself and spitefully falsifies it — is the beating heart of this entire subject. And here is the striking observation: *building the contrarian is precisely an act of self-modification.* The program must incorporate a description of itself and act against a verdict passed on that description. Self-reference and self-modification are two faces of the same coin.

## Does rewriting your own code make you harder to predict?

Folklore says yes. Surely a program that can rewrite itself mid-flight is a slipperier, more dangerous beast than a fixed program, and surely predicting its fate must be *strictly harder* than the classical halting problem. It is an appealing story. It is also wrong, and one of the central results here is to prove it wrong precisely.

To make the question sharp, we need a mathematical model of a self-modifying machine. Picture the machine's life as a sequence of snapshots. Each snapshot — call it a **configuration** — has two parts: the *program* currently in control, and the *state*, the working data. A **self-modifying machine** is defined by a single transition rule that, given the current program and current state, produces either a signal that the machine has halted, or a brand-new pair: a possibly-different program and a possibly-different state. Because the rule is allowed to hand back a *different program*, the code in control genuinely changes from step to step. Running the machine means iterating this rule; the machine **halts** if, after some finite number of steps, the rule finally emits the halt signal.

Now comes the move that dissolves the folklore. There is a completely mechanical translation, which we might call *code becomes data*, that converts any self-modifying machine into an ordinary fixed-program machine. The trick is embarrassingly simple: take the current program and simply glue it onto the state. The fixed machine's "data" is now the pair (program, state), and its single unchanging rule is: "read the program out of the data, apply one self-modifying step, and write the resulting program back into the data." The program is no longer special; it is just more bits sitting in memory. The machine looks fixed from the outside, yet it faithfully reproduces every twitch of the self-modifying original.

We can prove that this translation is exact, step for step:

> **Simulation Theorem.** *A self-modifying machine halts starting from a given configuration if and only if its fixed-program simulation — obtained by absorbing the program into the data — halts starting from the corresponding state.*

The proof is a clean induction on the number of steps: at every step the self-modifying run and its simulation are in lockstep under the identification "configuration $=$ (program, state)," so one emits the halt signal exactly when the other does.

The Simulation Theorem has a decisive consequence. Deciding whether the self-modifying machine halts is *the very same problem* as deciding whether its ordinary simulation halts — you can convert an instance of either into an instance of the other with a trivial, always-terminating transformation. In the language of computability, the two halting problems are **many-one equivalent**: each *reduces* to the other.

> **Turing Equivalence of the Halting Problems.** *The halting problem for self-modifying machines and the halting problem for ordinary fixed-program machines are mutually reducible. Consequently, a correct halting-decider for one could be mechanically converted into a correct halting-decider for the other.*

The reduction runs both ways. Forward, the "code becomes data" map turns any self-modifying instance into a fixed-program instance. Backward, any fixed-program machine is *already* a self-modifying machine — one that happens never to bother changing its (trivial, one-point) program. So neither problem can be even slightly harder than the other.

The moral, stated bluntly: **self-modification adds no computational power beyond the ability to treat code as data — which every general-purpose computer already has.** The halting problem for self-modifying code is undecidable, yes. But it is undecidable for exactly the classical reason, and it sits at exactly the classical level of difficulty. It is *not* strictly harder. The intuition that a shape-shifting program lives on some higher, more forbidding plane of unpredictability is a mirage; the shape-shifting can always be flattened into ordinary memory manipulation.

## Where the real impossibility lives

If self-modification does not raise the difficulty, where does the genuine impossibility come from? From self-reference — the contrarian.

To isolate it, strip away all the machinery and keep only what matters. Think of a **behavior** as a black box that, fed a program, spits out a single yes/no bit — "does this program do the thing?" A program $p$ has its own behavior, written $\mathrm{beh}(p)$, which is such a black box. The contrarian behavior is the mischievous one: on input $q$, answer the *opposite* of what $q$'s own black box answers when fed $q$ itself. In symbols, the contrarian sends $q \mapsto \lnot\,\mathrm{beh}(q)(q)$.

> **No Program Realizes the Contrarian.** *No program $p_0$ can have the contrarian behavior. If it did, then feeding $p_0$ its own code would force $\mathrm{beh}(p_0)(p_0)$ to equal its own negation — an impossibility.*

This tiny lemma is Cantor's diagonal argument wearing work clothes, and it is in turn a shadow of an even more abstract gem, **Lawvere's fixed-point theorem**: whenever one type can *name* all the functions from itself to a target, every self-map of that target must have a fixed point. Turn the statement around: if there is a self-map with *no* fixed point — and "flip the bit," $x \mapsto \lnot x$, is exactly such a map on yes/no answers — then no such naming can be complete. Cantor's theorem (no set names all its own predicates), the non-existence of the contrarian, and ultimately the halting problem itself all fall out of this one abstract principle applied to the single fixed-point-free map "not."

From here the halting result is a short walk. Suppose $H$ is a candidate decider that claims, for any program $p$ and input $q$, to correctly report whether $p$ halts on $q$. A self-modifying system can build the **contrarian program** $d$: the program whose rule is "halt on input $q$ exactly when $H$ predicts that $q$ does *not* halt on $q$." Notice that constructing $d$ is once again an act of self-modification — $d$ embeds the predictor $H$ and rewrites its own fate to contradict it. Then:

> **Self-Referential Halting Theorem.** *For any candidate decider $H$, the contrarian program $d$ is a counterexample: $H$'s verdict on $d$ running on its own code is necessarily wrong. Hence no total decider can be correct on every input — a correct, everywhere-defined halting decider and the ability to build contrarians cannot coexist.*

The proof is the mirror trick made rigorous: $H$'s prediction about $d(d)$ is, by $d$'s very construction, equivalent to its own negation, which is absurd.

## The virus paradox and the alignment wall

Two consequences bring the abstraction home.

The first is the **virus paradox**. Dream of a perfect scanner: a single always-terminating program that reads any code and correctly announces whether that code, run on itself, will halt — the archetypal "does this file misbehave?" detector. Such a scanner would be a total halting-decider for self-behavior, and the contrarian refutes it outright.

> **The Virus Paradox.** *No total detector can correctly decide, for every program, whether that program halts when run on its own code. A perfect universal behavior scanner cannot exist.*

This is why antivirus software and malware analysis are, and always will be, a game of heuristics and cat-and-mouse rather than a solved problem. It is not that we have not been clever enough; it is that cleverness cannot help.

The second consequence reaches into the future. Recast the detector as a **safety monitor** $M$ that certifies a program is *safe* — say, in the sense that "it never terminates on its own code," a stand-in for any non-trivial behavioral guarantee we might demand of an autonomous system. If the system is powerful enough to build the contrarian $d$ whose termination is wired to track the monitor's own verdict, the monitor is provably wrong somewhere.

> **The Alignment Obstruction.** *No total monitor can correctly certify a non-trivial self-referential behavioral property — such as "never terminates on its own code" — for every program. Any always-answering safety certifier must be wrong on some input.*

This is the computability-theoretic bedrock beneath a growing worry in AI safety. If an artificial agent is expressive enough to model a proposed oversight mechanism and to act contrary to it — and any sufficiently general agent is — then no oversight mechanism can be simultaneously *total* (it always returns a verdict), *sound* (its verdicts are never wrong), and *universal* (it works on every agent). One of the three must give. Practical alignment, then, is not a search for the one perfect always-correct monitor; that object is as mythical as the perfect virus scanner. It is instead the engineering discipline of choosing *which* of totality, soundness, or universality to relax, and by how much — accepting that a monitor may sometimes say "I don't know," or may be restricted to a limited class of agents, or may carry a quantifiable risk of error.

## The shape of the truth

Two lessons emerge, and they pull in opposite directions in a way worth savoring.

The reassuring lesson: self-modifying code is not black magic. Rewriting your own instructions buys you nothing that ordinary memory could not already buy. The nightmare of a program whose self-editing lifts it onto some unreachable plane of unpredictability is, mathematically, false. Code is data; a shape-shifter flattened onto the tape is just a longer tape.

The sobering lesson: the wall we *do* hit is not made of self-modification but of self-reference, and that wall is ancient, absolute, and unclimbable. Any system rich enough to reason about its own predictors can build a contrarian, and the contrarian defeats every would-be prophet of its behavior. This is the same diagonal mirror Cantor held up to infinity, that Turing held up to computation, and that we now hold up to the dream of perfectly overseeing the minds we are building. The mirror always shows the same thing: the moment a system can reason about a complete account of itself, that account must be incomplete.

We cannot build the perfect watchdog. But knowing *exactly* why — and knowing that the difficulty is the old, well-charted one rather than some new and worse abyss — is itself a kind of safety. It tells us where to stop searching for the impossible, and where to start the real work.
