# The Program That Reads Its Own Verdict

## Self-modifying code, diagonal traps, and the mathematics of forgetting

A computer program ordinarily looks like a list of instructions and a changing store of data. Self-modifying software erases that boundary. Its current program can become data, be inspected, rewritten, and returned as the next program. That ability appears in just-in-time compilation, adaptive optimization, evolutionary software, malware, and systems that update their own policies while running. It invites a powerful fantasy: perhaps a sufficiently sophisticated guardian could inspect every such program and say, before execution, whether it will eventually stop.

Mathematics rules out that guardian. The obstacle is not a shortage of ingenuity or computing power. It is a logical feedback loop. Whenever a system is expressive enough to represent universal computation, a proposed universal termination predictor can be fed into a program that reacts to its own prediction. The program then arranges to stop exactly when it was predicted not to stop, and to continue exactly when it was predicted to stop.

The same pattern has another, more surprising face. A finite memory compressing an unlimited stream of experiences must forget distinctions. Those lost distinctions form an algebraic equivalence relation, and the observable memory is exactly the space of streams after indistinguishable histories have been identified. Thus self-reference explains why perfect prediction fails, while quotienting explains what finite observation can preserve.

## A machine whose program is part of its state

Let $P$ be a set of programs and $S$ a set of ordinary states. A **self-modifying machine** has a one-step rule

$$
T:P\times S\longrightarrow (P\times S)\cup\{\mathsf{halt}\}.
$$

From a configuration $(p,s)$, the rule either halts or returns a new configuration $(p',s')$. The crucial point is that $p'$ need not equal $p$. Running for $n$ steps means repeatedly applying $T$ until either $n$ transitions have occurred or the halt signal appears. The machine halts from $(p,s)$ when some finite run reaches that signal.

At first, this model seems stronger than an ordinary fixed-program machine. Yet there is a simple simulation theorem.

**Simulation Theorem.** Every self-modifying machine can be simulated step for step by a fixed-program machine whose ordinary state is the pair $P\times S$. For every starting configuration and every number $n$ of steps, both runs have exactly the same outcome. Consequently, the self-modifying machine halts if and only if its fixed-program simulation halts.

The proof is almost disarmingly simple. The simulator stores the current program beside the ordinary state. Whenever the original transition produces $(p',s')$, the simulator replaces its stored pair by that same pair. Induction on $n$ proves equality of the finite runs. Self-modification changes how a computation is organized, but not which partial computations can exist: code can be treated as data.

This equivalence has two edges. It prevents mysticism—rewritable code does not transcend ordinary computability—but it also imports every classical impossibility into the self-modifying setting.

## Building a termination trap

Choose a universal programming language whose programs are encoded by natural numbers. For a code $c$, input $x$, and time budget $t$, let $E_t(c,x)$ be a bounded evaluator. It returns an output if $c$ finishes on $x$ within the available search, and otherwise reports “not yet.” Each bounded query is finite and executable.

Fix an input $x$. Construct a machine with configuration $(c,t)$ that performs the following transition:

1. evaluate $E_t(c,x)$;
2. halt if an output has appeared;
3. otherwise replace $t$ by $t+1$ and continue.

This machine happens not to rewrite $c$, but that is a feature, not a weakness: a machine that leaves its program unchanged is a special case of a self-modifying machine. The construction therefore establishes a lower bound for the entire class.

**Bounded-Run Characterization.** Starting at counter $s$, the monitor halts within $N$ transitions if and only if there is an integer $i$ with $0\le i<N$ for which $E_{s+i}(c,x)$ has produced an output.

The proof follows the first transition. If the evaluator succeeds at $s$, the machine halts immediately, corresponding to $i=0$. Otherwise the counter advances to $s+1$, and induction handles the remaining $N-1$ transitions.

**Universal-Monitor Theorem.** Starting from $(c,0)$, the monitor halts if and only if program $c$ eventually halts on input $x$.

One direction extracts a successful bounded evaluation from a finite halting run. The other chooses a sufficiently large budget after the underlying computation has finished. The monitor therefore reproduces the universal halting set exactly.

It follows that no computable predicate decides whether this explicit machine halts for every code $c$. By the simulation theorem, no such predicate decides the halting of its fixed-program encoding either. Self-modification is neither an escape from the halting problem nor a source of a worse kind of undecidability: it carries precisely the classical obstruction.

There is an important asymmetry. Halting is **semidecidable**: run the computation, and if it stops, the finite trace is a certificate. Nonhalting is not semidecidable for a universal machine. No general process can always produce a finite certificate for programs that run forever. Security tools feel this asymmetry in practice: a sandbox can witness a malicious action that happens, but finite observation cannot certify that an unseen action will never happen.

## The diagonal mirror

Why does every proposed decider fail? The cleanest explanation begins with a fixed-point principle.

**Lawvere Fixed-Point Theorem.** Let $A$ and $B$ be sets, and suppose $g:A\to B^A$ is surjective, where $B^A$ is the set of all functions from $A$ to $B$. Then every function $f:B\to B$ has a fixed point: some $b\in B$ satisfies $f(b)=b$.

To see it, form the diagonal function $h(a)=f(g(a)(a))$. Surjectivity gives an $a_0$ with $g(a_0)=h$. Evaluating at $a_0$ yields

$$
g(a_0)(a_0)=h(a_0)=f(g(a_0)(a_0)),
$$

so $g(a_0)(a_0)$ is fixed by $f$.

Now take $B=\{0,1\}$ and let $f$ flip the bit. Since bit-flipping has no fixed point, no map $A\to\{0,1\}^A$ can be surjective. This is Cantor’s theorem in Boolean clothing: no collection can list all predicates about its own members. In power-set language, no map from $A$ onto all subsets of $A$ is surjective.

A universal termination table would try to do exactly what the theorem forbids. Its rows would represent programs and its columns inputs; each cell would contain a Boolean verdict. Diagonalization examines the cell in which a program is applied to its own code and flips the answer. The resulting behavior cannot be one of the listed rows.

This yields the **Diagonal Impossibility Theorem**: if an enumeration claims to cover every Boolean predicate on a set, then no total Boolean table can agree with every enumerated value on every argument. The contradiction is the same fixed-point-free flip seen in Cantor’s theorem. Halting undecidability is not an isolated trick—it is one expression of a general theorem about self-reference.

## Rewriters meet their fixed points

Self-reference also creates programs that resist semantic alteration.

**Behavioral Fixed-Point Theorem.** For every computable rewriting rule $M$ that maps program codes to program codes, there exists a code $c$ such that $M(c)$ and $c$ compute the same partial function.

The rewritten text need not be character-for-character identical. The claim is behavioral: on every input, both programs either diverge together or return the same result. This is the engine behind quines and recursion constructions. A computable transformer cannot change the behavior of every program; somewhere, the transformer encounters a semantic fixed point.

This does not say malware is immortal, nor that a particular defensive rewrite must fail. A defender may neutralize vast classes of programs. The theorem says only that no computable rewrite changes *every* possible program behavior in a universal language. Universal claims collide with self-reference.

## What finite memory must forget

A companion algebraic picture clarifies the limits of observation. Let $\Sigma$ be a nonempty alphabet of experiences. A finite stream is a word in $\Sigma^*$, including the empty word $\varepsilon$; concatenation makes $\Sigma^*$ a monoid. Let $R$ be a monoid of memory representations. A **compositional memory map** is a function

$$
m:\Sigma^*\longrightarrow R
$$

satisfying $m(uv)=m(u)m(v)$ and $m(\varepsilon)=1_R$.

If $R$ is finite, the infinite set $\Sigma^*$ cannot inject into it.

**Finite-Memory Loss Theorem.** For every compositional memory map from words over a nonempty alphabet into a finite representation monoid, there are distinct streams $u\ne v$ with $m(u)=m(v)$.

Thus finite memory necessarily merges histories. Define $u\sim v$ when $m(u)=m(v)$. This is not an arbitrary equivalence relation: concatenation respects it. If $u\sim v$ and $u'\sim v'$, then $uu'\sim vv'$. The streams mapped all the way to the neutral memory,

$$
K=\{u\in\Sigma^*:m(u)=1_R\},
$$

contain $\varepsilon$ and are closed under concatenation. They form a submonoid—the language of completely erased histories.

**Observable-Quotient Theorem.** The quotient monoid $\Sigma^*/\!\sim$ is isomorphic to the image $m(\Sigma^*)$. In plain language, the observable memory algebra is exactly the stream algebra after histories with the same memory have been identified.

The proof sends the equivalence class $[u]$ to $m(u)$. This is well defined because equivalent streams share a memory, injective because equality of memories is precisely the equivalence relation, surjective onto the image by definition, and compatible with concatenation because $m$ is compositional.

A particularly transparent memory filter chooses which symbols to retain. Given $r:\Sigma\to\{0,1\}$, delete every symbol with $r(a)=0$ and preserve every symbol with $r(a)=1$. Every deleted symbol belongs to $K$. More strongly, this filter has a universal property: any compositional observer that identifies every pair already identified by the filter factors uniquely through the quotient. The quotient is therefore not merely a convenient representation; it is the canonical algebra of everything that remains observable after targeted forgetting.

## The boundary, not the defeat

Together, these results draw a precise boundary around adaptive computation. Rewriting code can be simulated by carrying code as state. Universal termination remains undecidable. Halting can be witnessed; perpetual execution cannot generally be certified. Every computable code transformer has a behavioral fixed point. And every finite compositional observer of unbounded histories necessarily merges some distinct streams, with its surviving information described exactly by a quotient.

These are not reasons to abandon prediction, program analysis, sandboxing, or memory design. They explain why successful tools restrict their ambitions: bounded time, finite-state fragments, typed languages, conservative approximations, probabilistic forecasts, or domain-specific invariants. Within such boundaries, useful guarantees flourish.

The impossible object is the flawless oracle that handles every program in a universal world—including programs that read the oracle’s verdict and turn it against itself. The program in the mirror does not outrun mathematics. It reveals where mathematics says the mirror must crack.
