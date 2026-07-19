# The Program That Rewrites Itself—and the Question It Still Cannot Answer

A conventional computer program seems like a recipe carved in stone. Its instructions sit in one place, its data in another, and execution consists of applying the fixed recipe to changing data. Self-modifying software breaks that picture. While running, it may replace an instruction, splice in a newly generated routine, or treat its own current text as material for the next step. Computer viruses have long used such techniques to change their signatures. Just-in-time compilers rewrite executable code for speed. Adaptive agents can synthesize plans, tools, or even successor policies as they work.

This makes self-modifying computation sound like a fundamentally stronger species of machine. If a program can change the rules while the game is being played, perhaps predicting it is harder than predicting an ordinary program. That intuition contains a truth—but also a trap.

The truth is that no general algorithm can predict whether every such computation will terminate. The trap is the stronger claim that rewriting makes this termination problem strictly more undecidable than the classical halting problem. It does not. Effective self-modification changes the organization of computation, but not its ultimate computability power. A fixed program can simulate the changing one by carrying the current code as part of its data.

That distinction matters. It tells us exactly where the mystery lies: not in mystical code that escapes computation, but in the old, unavoidable self-reference of universal computation itself.

## A machine with a moving rulebook

Model a self-modifying machine by two sets. Let $P$ be the set of possible program texts and $S$ the set of ordinary runtime states. A configuration is a pair $(p,s)\in P\times S$. One effective transition takes the current configuration either to a new pair $(p',s')$ or to a distinguished halted outcome. Crucially, $p'$ need not equal $p$; the transition may rewrite the program.

Starting from $(p_0,s_0)$, repeated transitions produce a run

$$
(p_0,s_0),(p_1,s_1),(p_2,s_2),\ldots
$$

until a halt occurs, if one ever does. The machine *halts* when some finite number of steps reaches the halted outcome. It *runs perpetually* when every finite stage remains defined.

At first sight, an ordinary fixed-program machine seems unable to imitate this moving rulebook. But the difference disappears once we enlarge the ordinary state. Instead of regarding $p$ as the simulator’s own program, regard $(p,s)$ as its data. The simulator itself is fixed. At each step it reads the stored code $p$, applies the self-modifying transition rule, and stores the resulting pair $(p',s')$.

This gives the central simulation theorem.

**Exact Simulation Theorem.** For every effective self-modifying machine on configurations $P\times S$, there is a fixed-program machine whose state space is $P\times S$ and whose run agrees step for step with the self-modifying run. A configuration halts in the self-modifying machine if and only if the corresponding state halts in the fixed-program simulation.

The converse is immediate: an ordinary machine is a self-modifying machine whose program component has only one possible value and therefore never genuinely changes. Thus each model can encode the other’s halting question.

**Computability-Equivalence Theorem.** The halting problem for effective self-modifying machines and the classical halting problem are mutually reducible. Consequently, self-modifying halting is not strictly harder in computability degree than classical halting.

This result does not say that rewriting is useless. A mutable program may be shorter, faster, more adaptive, or harder to inspect. It says only that if “harder” means the existence or nonexistence of an algorithm that always answers correctly, rewriting alone adds no new level of impossibility.

## The prediction barrier

Suppose there were a total prediction algorithm $D$. Given the code $c$ of any program and a fixed input $x$, it would return $1$ exactly when $c$ eventually halts on $x$, and $0$ otherwise. Because programs can manipulate program descriptions, one can construct a diagonal program that consults such predictions and acts against them: on its own description, it continues when predicted to halt and halts when predicted to continue. Either answer contradicts the promised correctness of $D$.

**Universal Termination Impossibility Theorem.** For every fixed input $x$, no total computable Boolean function on program codes returns $1$ exactly for the programs that halt on $x$.

Through exact simulation, this barrier transfers directly to self-modifying systems. No universal observer can inspect an arbitrary mutable configuration and always decide whether its future contains a halt. The source of impossibility is not that the code changes unpredictably in a physical sense. Even perfectly deterministic rewriting has the problem. The obstruction comes from universal interpretation and self-reference.

There is, however, an important positive boundary. For a chosen step limit $N$, simulation can decide whether the machine halts within $N$ steps. Run it for $N$ transitions; if a halt appears, answer yes, and otherwise answer no. This bounded question is decidable because it asks about a finite trace. What cannot be decided in general is whether some successful stopping time exists anywhere beyond every finite horizon.

## Why watching forever is not a practical monitor

Safety engineers often want the complementary guarantee: certify that a system will continue safely forever. Define a configuration to be *perpetually nonhalting* when its run is defined after every finite number of steps. Formally,

$$
\operatorname{Safe}(p,s)\quad\Longleftrightarrow\quad
\forall n\in\mathbb N,\ \text{the run from $(p,s)$ survives $n$ steps}.
$$

This is exactly the negation of eventual halting:

$$
\operatorname{Safe}(p,s)\quad\Longleftrightarrow\quad
\neg\operatorname{Halts}(p,s).
$$

That innocent equivalence has severe consequences.

**No Exact Perpetual-Safety Monitor Theorem.** For any self-modifying machine whose fixed-state simulation has undecidable halting, there is no total Boolean monitor that accepts exactly the perpetually nonhalting configurations.

If such a monitor existed, negating its answer would decide halting for the simulator. The monitor cannot escape the problem merely by changing the label from “will halt” to “will remain safe.”

The asymmetry between stopping and continuing is sharper still. A finite trace can certify halting: simply exhibit the step at which it occurs. But perpetual continuation has no final witness. For a universal programming system and a fixed input, the set of codes that run forever is not even recursively enumerable. In other words, there is no procedure that can list all and only the perpetual executions, eventually listing each one.

**Nonenumerability of Perpetual Execution.** For every fixed input $x$, the collection of program codes whose computation on $x$ never halts is not recursively enumerable.

This does not prohibit useful safety certificates. It says that no finite-certificate regime can be both complete and applicable to every safe program in a universal system. Sound methods must leave some safe cases uncertified; complete-looking methods must sometimes be wrong or fail to terminate.

## The virus paradox

A virus detector is often imagined as a classifier of files, but the deepest malware properties are behavioral. A program may unpack itself, generate fresh code, delay an action, or perform a harmful operation only after an arbitrary computation finishes. Signature matching concerns syntax; “eventually performs behavior $B$” concerns semantics.

Call a property *extensional* if it depends only on the partial input-output behavior computed by a program, not on spelling, layout, or implementation. Call it *nontrivial* if at least one computable behavior has the property and at least one computable behavior lacks it.

**Semantic Classification Impossibility Theorem.** No computable classifier decides exactly whether an arbitrary program has a given nontrivial extensional property of its partial input-output behavior.

The reason is a reduction: if two behaviors lie on opposite sides of the property, an alleged classifier can be used to distinguish whether a chosen computation halts by arranging for the resulting program to behave like one side before or after that event. Exact semantic classification would therefore solve the halting problem.

This is the virus paradox in its cleanest mathematical form. A detector can recognize signatures, enforce a restricted language, analyze bounded traces, demand certificates, or tolerate error. What it cannot do is exactly classify every program by any nontrivial property determined solely by what that program computes.

## Alignment under self-revision

The same boundary appears in adaptive artificial systems. Consider the demand: “Accept exactly those agents for which every future self-rewrite preserves a specified behavior.” If this is an unrestricted, extensional claim over universal computations, then an exact total evaluator runs into the same impossibility. An agent can postpone a decisive action until another computation halts; deciding the future behavior would decide that computation’s fate.

This is not a claim that alignment is hopeless. It is a map of where guarantees can live. One may restrict the language so all programs terminate, impose finite horizons, use conservative type systems, require proof-carrying updates, sandbox effects, or accept probabilistic and incomplete judgments. Each approach gives up universality, completeness, or both in exchange for tractable assurance.

The exact simulation theorem also warns against blaming self-modification for too much. Mutable code can amplify practical opacity and create enormous complexity overhead, yet it does not by itself leap to a higher computability degree. The promising hierarchies are quantitative: time, space, communication, rewrite count, and certificate size. Two models may compute the same functions while differing dramatically in the resources required.

## The enduring lesson

The program that rewrites itself cannot outrun mathematics. Its changing text can be folded into the state of a fixed interpreter, making its termination problem equivalent to the classical one. But equivalence is not escape. The classical halting barrier remains: no general termination predictor exists, no exact monitor recognizes all and only perpetual executions, perpetual execution cannot be completely listed, and no algorithm exactly decides every nontrivial semantic behavior.

The practical message is neither complacency nor despair. It is architectural clarity. Finite behavior can be simulated. Restricted systems can be certified. Conservative monitors can be sound. Statistical detectors can be useful. But a universal, total, exact oracle for the unbounded future is not an engineering feature waiting to be invented. It is a logical contradiction waiting to be exposed.