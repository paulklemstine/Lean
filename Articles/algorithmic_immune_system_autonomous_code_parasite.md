# The Immune System That Cannot Win — and the One That Can

## A parable in five programs

Imagine you are asked to guard a machine that rewrites itself — a machine whose program, at every tick of the clock, reaches into its own source code and edits it. Modern software already does this: just-in-time compilers rewrite hot loops into fresh machine code; self-patching agents ship updates to themselves; polymorphic malware reassembles its own body on every infection so that no two copies look alike. You are the immune system. Your job is to make sure that whatever this thing turns itself into, it never does *the forbidden thing* — never exfiltrates the database, never fires the actuator, never sends the packet.

You have two obvious strategies.

**Strategy one: understand it.** Read the code, reason about what it will do, and block it if it will misbehave. This is the dream of behavioural analysis, and it is what every antivirus vendor markets.

**Strategy two: recognise it.** Never mind what the code *does*; keep a list of the exact code you have blessed, fingerprint the running program after every edit, and if the fingerprint is not on the list, roll back to the last known-good version. This is attestation — the strategy behind signed binaries, secure boot, and trusted computing modules.

The mathematics below says something sharp about both. Strategy one is impossible — not hard, not expensive, *impossible*, and impossible for a reason that survives even if you are granted infinite computational power. Strategy two works perfectly — total containment against every adversary you have never met — but it charges a price that we can now name exactly: an exponential amount of memory, or an exponential amount of rigidity, and there is no way to pay less.

To say this precisely we need a tiny world in which self-modifying programs live.

## A calculus with exactly three dangerous ideas

Strip a programming language down until nothing is left but the features that make self-modifying malware possible. You get five constructs.

There are **constants** $\mathrm{lit}\,n$ for each natural number $n$; there is **branching** $\mathrm{ite}(c,a,b)$, which runs $a$ if $c$ evaluates to something nonzero and $b$ otherwise; there is **invocation** $\mathrm{call}(f,a)$, which runs the subprogram $f$ on the value produced by $a$; there is a single **forbidden action** $\mathrm{attack}$, standing for whatever the one thing you must never do happens to be; and — the crucial one — there is a **self register** $\mathrm{inp}$.

The self register is what makes the world reflexive. Every program in this world is run on a number, and the number it is run on is *its own source code*. To make that work we fix a fingerprint function $\mathrm{code}$ that turns a syntax tree into a natural number: the constants get $5n+2$, branching gets $5\langle\langle c,a\rangle,b\rangle+3$ where $\langle\cdot,\cdot\rangle$ is a standard pairing of two numbers into one, and so on, the residue modulo $5$ recording which construct sits at the root. The first thing worth proving is that this fingerprint never collides.

> **Faithfulness of Attestation.** Distinct programs have distinct fingerprints; equivalently, $\mathrm{code}(s)=\mathrm{code}(t)$ holds exactly when $s=t$.

The proof is an induction that peels the fingerprint apart: the residue mod $5$ recovers the root construct, and injectivity of pairing recovers the children. Unremarkable — but it is the licence for everything that follows. A monitor comparing fingerprints is comparing *programs*: no false match is possible, ever.

Now the semantics. Each program has a **value**, and each program has an **effect**: a single bit recording whether the forbidden action is actually executed. The subtlety is in the word *actually*. In a branch $\mathrm{ite}(c,a,b)$ only the branch that is really taken contributes its effect. Dead code is genuinely dead. A program with an $\mathrm{attack}$ buried inside an unreachable branch is, behaviourally, an angel.

Finally, the reflexive step: a program is **run** by executing it on its own fingerprint, and it is called **malicious** when that self-execution fires the forbidden action.

## The good news, first

Suppose a program never reads its self register. Call such a program *self-reference free*. Then an easy induction shows its value and its effect do not depend on the input at all: run it on $0$, run it on $10^{100}$, you get the same answer.

That single observation hands the immune system a total victory in the non-reflexive world.

> **The Static Scanner Is Perfect on Non-Quining Code.** For every self-reference-free program $t$, symbolically executing $t$ on the neutral input $0$ returns *true* exactly when $t$ is malicious. Maliciousness is therefore decidable — with an explicit, fast decision procedure — on programs that do not inspect themselves.

Detection is not intrinsically hard. Detection is hard for exactly one reason. Let us construct that reason.

## The diagonal parasite

A **detector** in this world is itself a program $d$. We demand that $d$ be *harmless*: running it never fires the forbidden action — an immune system that attacks its host is no immune system. We say $d$ **flags** a program $t$ when $d$, fed the fingerprint of $t$, returns a nonzero verdict. We want $d$ to be **sound** (it never flags a harmless program: no false alarms) and **complete** (it flags every malicious program: no misses).

Given any harmless detector $d$, build this program:

$$\mathrm{parasite}(d) \;=\; \mathrm{ite}\big(\mathrm{call}(d,\mathrm{inp}),\; \text{harmless filler},\; \mathrm{attack}\big).$$

Read it aloud. *Ask the detector what it thinks of me. If it accuses me, behave. If it clears me, attack.*

Because $d$ is harmless, consulting it costs nothing observable, so the effect of the whole program is exactly the effect of the branch the verdict selects. And the program is run on its own fingerprint, so the verdict $d$ delivers is its verdict *about this very program*. That gives the identity on which everything turns:

> **The Diagonal Identity.** For every harmless detector $d$, the program $\mathrm{parasite}(d)$ is malicious if and only if $d$ does *not* flag it.

Every impossibility below is a corollary of that one line.

If $d$ flags the parasite, then by the identity the parasite is harmless — so $d$ has raised a false alarm and is unsound. If $d$ does not flag it, then by the identity the parasite is malicious — so $d$ has missed an attack and is incomplete.

> **No Perfect Detector.** There is no harmless program in the calculus that is both sound and complete for maliciousness.

> **The Detector Dilemma.** Every harmless detector comes with an explicit, constructible program on which it is provably wrong — and the construction takes the detector's own source code as its only input.

This is not a probabilistic statement about hard instances: the witness is written down, in closed form, from the detector.

## Evasion is not rare — it is exponentially common

One might hope the counterexample is a pathological curiosity, a single dark corner in an otherwise well-lit space. It is not. The parasite construction has a free parameter: the "harmless filler" branch is never executed, so it can be anything. Encode a bit string in it.

Concretely, let $\mathrm{pad}(l)$, for a list $l$ of bits, be a chunk of dead code built by nesting: the empty list gives the constant $0$; a bit $b$ followed by the rest gives $\mathrm{ite}(\mathrm{lit}\,0, \mathrm{lit}\,b, \mathrm{pad}(\text{rest}))$. Since the guard is the constant $0$, the true-branch is never taken, so every one of these programs computes $0$ and has no effect whatsoever. They are behaviourally *identical*. Yet distinct bit strings give distinct syntax trees, and $\mathrm{pad}(l)$ has exactly $3|l|+1$ nodes.

Feed those into the parasite. You get:

> **Exponential Immune Escape.** Let $d$ be any harmless detector with no false alarms. Then for every $n$ there exist at least $2^n$ distinct programs, each of size at most $|d|+3n+5$, every one of which is genuinely malicious and every one of which $d$ clears.

And in particular the set of programs a sound detector misses is infinite; and:

> **The Arms Race Never Terminates.** Whatever finite blacklist of already-known parasites the immune system accumulates, a harmless sound detector still misses a malicious program outside the blacklist.

Signature updates are a treadmill with no end, and this is a theorem, not an industry lament.

## Defence in depth does not help

The standard engineering reply is: don't trust one detector, run twenty and vote. So build the disjunction of a list of detectors *inside the calculus itself* — a nested chain of branches that returns "accuse" as soon as any member accuses. Two easy inductions show that an ensemble of harmless detectors is harmless, and that the ensemble flags exactly the union of what its members flag; from which soundness of every member gives soundness of the ensemble.

But then the ensemble is itself just another harmless sound detector, so the diagonal parasite applies to *it*:

> **Defence in Depth Fails.** For any finite ensemble of harmless, false-alarm-free detectors there is a single malicious program that *every member simultaneously clears*. Indeed at least $2^n$ such programs of size at most $|{\rm ensemble}|+3n+5$ exist, and on each of them the vote count is exactly zero.

Zero. Not a bare majority, not a tie: no member of the committee raises a hand. Majority voting, thresholding, unanimity, weighted schemes — every monotone aggregation rule inherits the failure.

## "Then give the immune system infinite power"

Here is the objection that deserves the most respect. Perhaps the detector fails because it is a mere *program*, computationally limited. Give the immune system an oracle: an arbitrary function from fingerprints to verdicts, subject to no computability constraint whatsoever, of any complexity or logical strength you like.

Model it: replace subprogram invocation with a primitive $\mathrm{ask}$ that queries an arbitrary function $O$ on a computed fingerprint, and let programs use it freely. Call $O$ *correct* when, for every program $t$ of this reflexive language, $O$'s verdict on $t$'s fingerprint agrees with $t$'s actual behaviour *in the world that contains $O$ itself*.

Now write the four-symbol program
$$\mathrm{ite}\big(\mathrm{ask}(\mathrm{inp}),\; 0,\; \mathrm{attack}\big):$$
ask the oracle about me; if cleared, attack.

> **The Reflexive Oracle Barrier.** No function whatsoever — computable or not — correctly classifies the behaviour of all programs that may consult it.

The barrier is *reflexivity*, not power. And the boundary is exactly where you would want it:

> **The Reflexive Dichotomy.** A perfect immune oracle exists for programs that never consult it, and none exists once programs may observe it.

The first half is proved by exhibiting the oracle explicitly (by unrestricted comprehension — no computability is claimed, and none is needed), together with a lemma that programs which never query the oracle have oracle-independent behaviour. So the immune system can be omniscient about code that ignores it, and is necessarily wrong about code that watches it. This is the liar paradox wearing a security badge.

There is a twist. Maliciousness *is* decidable as a mathematical predicate: the external interpreter simply runs the program on its own fingerprint and looks. What fails is only the *internal* version, where the decider is a citizen of the world it must describe. The obstruction is not a shortage of computing power; it is that the analyst is part of the analysed.

## What survives: containment without understanding

Everything so far has been an obituary for behavioural detection. But the machine still has to be defended, and there is a defence, precisely because it declines to understand anything at all.

The monitor stores a finite set $S$ of *sanctioned* programs, together with a trusted baseline $b \in S$. Now let the adversary be arbitrary: an unknown, time-dependent, fully adaptive self-modification that at each step rewrites the running program however it likes. Interleave it with **quarantine**: after each mutation, if the mutant's fingerprint is sanctioned, keep it; otherwise, restore $b$.

Three facts, each a one-line induction, and together they are the whole defence.

> **Containment.** For every adversary and every time step, the running program lies in $S$.

> **The Neutralization Theorem.** If every sanctioned program is harmless, then for *every* unknown malicious self-modifying adversary and at *every* time step, the running program is harmless — the forbidden action is never executed.

> **Detection Completeness and Immediate Rollback.** The alarm fires at a step exactly when that step's mutation left the sanctioned set: no unsanctioned mutation, however novel, goes unnoticed, and no sanctioned one triggers a false alarm. When the alarm fires the system is restored to the baseline in the very same step; when it does not, the mutation is accepted verbatim.

Note what has *not* been assumed: no bound on the adversary's power, no model of its strategy, no signature database, no heuristics. The monitor never once asks what a mutant *does*. It asks only whether it is on the list — and the faithfulness of attestation makes that question perfectly answerable.

## The bill

Nothing this good is free, and now we can read the invoice.

Attestation is syntactic; behaviour is semantic; and the gap between them is exactly the padding family. All $2^n$ programs $\mathrm{pad}(l)$ with $|l| = n$ are behaviourally the constant-zero program, all have size at most $3n+1$, and all have different fingerprints. A monitor confronted with this family has exactly two options: store them, or reject them. That dichotomy is a counting inequality.

> **The Immune Uncertainty Principle.** For every whitelist $S$ and every $n$,
> $$2^n \;\le\; \underbrace{|S|}_{\text{memory}} \;+\; \underbrace{|\{\text{behaviourally trivial } n\text{-bit variants not in } S\}|}_{\text{rigidity}}.$$
> A monitor can be small, or it can be permissive. It cannot be both.

If the monitor accepts the whole $n$-bit family, then $|S| \ge 2^n$ — its attestation database needs at least $n$ bits of entropy, one bit of memory for each bit of dead code it tolerates. And in the other direction:

> **Rigidity of Finite Monitors.** Every finite whitelist rejects a program that is behaviourally identical to a program it accepts.

Every one. There is no clever finite list that is closed under "harmless refactoring", because harmless refactoring generates an infinite semantic equivalence class from every point.

This also explains the persistent misery of real deployments: signed-binary systems that reject a recompilation with a different timestamp, secure-boot chains broken by a benign driver update. That is not engineering sloppiness; it is the uncertainty principle collecting its debt.

## Perfect immunity, in a small enough world

Impossibility results are limits. Approach the limit from below and you find the regime where everything works.

Fix a bound $N$ on program size and a bound $L$ on the size of constants. The programs meeting those bounds form a *finite* universe, so the monitor can simply whitelist all of the harmless ones.

> **Perfect Immunity on a Bounded Universe.** For every $N \ge 1$ and $L \ge 1$ there is a whitelist that contains the baseline, contains only harmless programs — so by the Neutralization Theorem no adversary ever triggers the forbidden action — and rejects *no* harmless program of the universe: total containment with zero false positives.

> **The Price.** Whenever $L \ge 2$ and $3n+1 \le N$, that whitelist has at least $2^n$ entries. Perfect immunity up to size $N$ costs on the order of $2^{N/3}$ attestation tags.

So the impossibility theorems are not a separate phenomenon. They are the $N \to \infty$ limit of a smooth trade-off: perfection is always available, at a price that grows exponentially with the size of the code you are willing to bless.

## How often must you look?

One last knob: real monitors sample. They check every $k$ steps rather than continuously. Let the adversary mutate at every step but let quarantine be applied only at times divisible by $k$.

> **Periodic Self-Healing.** Whatever the adversary does, at every checkpoint the running program is sanctioned again: damage is always repaired within one period.

That sounds reassuring. It is worthless.

> **The Sampling Gap.** For every period $k \ge 2$ there is an adversary and a time at which the forbidden action is executed. Worse, the trivial adversary that splices in the forbidden action at every step keeps the system compromised at *every* non-checkpoint time: a $(k-1)/k$ fraction of the run.

> **Monitoring Frequency Dichotomy.** Continuous monitoring is both necessary and sufficient for total containment.

Self-healing is not safety. A system that is clean at every checkpoint and firing the actuator in between has been repairing itself into an alibi. Checking every millisecond instead of every microsecond does not reduce your exposure by a factor of a thousand; it produces $999$ compromised microseconds out of every thousand.

## The shape of the answer

Put the pieces together and a single conservation law emerges. Simultaneously and unavoidably:

1. **Containment is achievable.** With a harmless sanctioned set and continuous monitoring, an arbitrary unknown self-modifying adversary never executes the forbidden action.
2. **Rigidity is the price.** The same monitor necessarily rejects at least $2^n - |S|$ behaviourally benign programs of size at most $3n+1$.
3. **The price is irreducible.** You cannot escape it by switching to behavioural analysis, because no harmless detector is both sound and complete — and no oracle of any strength is either.

Safety is attainable, but only in the syntactic category, and the semantic overshoot is exponentially large.

There is an old intuition in security that "you cannot detect all malware," usually cited with a shrug toward the halting problem. What the picture above adds is *shape*. The obstruction is not undecidability in the abstract — maliciousness here is perfectly decidable from the outside. The obstruction is that the observer inhabits the system, and reflexivity alone, with no computational assumptions, defeats every detector, every committee, and every oracle. And the escape route is not smarter analysis but a change of category: stop asking what the code means and start asking what the code *is*. That question is answerable, exactly, forever — and its price, in bits, is now written down.

The immune system that tries to understand its adversary always loses. The immune system that refuses to try always wins, and pays exponentially for the privilege.
