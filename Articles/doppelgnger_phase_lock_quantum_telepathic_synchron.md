# The Telepathy That Isn't: How Two Strangers End Up Thinking the Same Thought

## A thought experiment with no ghosts in it

Imagine two identical machines — call them doppelgängers — built to the same blueprint, shipped to opposite ends of the Earth, and switched on. Nobody tells them how they were configured at the factory; one might boot with its internal dials at one setting, the other somewhere entirely different. They have no radio, no wire, no shared clock. They cannot see each other and never will.

Now the world starts talking to both of them, and — this is the only thing they share — it says exactly the same thing to each. The same sequence of stimuli: a flash, a beep, a flash, a flash, a beep. Each machine reacts privately, updating its internal state according to the rule that its blueprint prescribes.

Here is the startling question. Can it happen that, after some finite stretch of this shared soundtrack, the two machines are provably in *identical* internal states — not approximately, not probably, but exactly — no matter how differently they started?

The answer is yes, and the phenomenon deserves a name: **phase-lock**. It looks like telepathy — two separated systems, with no communication channel between them, suddenly and verifiably agreeing. Stage magicians have made careers out of less.

But it is not telepathy, and the mathematics of exactly *why* it is not — of what phase-lock can and cannot do, when it must happen, how fast, and what makes it impossible — turns out to be a rich and surprisingly complete theory, touching everything from resetting a jammed industrial robot to one of combinatorics' most stubborn open problems.

## The setup, stripped bare

An **agent** is nothing more than a rule
$$\delta : S \times I \to S,$$
where $S$ is the set of possible internal states and $I$ is the alphabet of stimuli the environment can emit. Reading $\delta(s, i)$ as "if you are in state $s$ and you observe stimulus $i$, move to state $\delta(s,i)$" is the whole model. There is no randomness and no hidden memory: the agent is deterministic and reactive.

Feed the agent a finite stimulus word $w = i_1 i_2 \cdots i_n$ and it traces a path through $S$. Write $\mathrm{drive}(w, s)$ for where it ends up starting from $s$. Concatenation composes: $\mathrm{drive}(wv, s) = \mathrm{drive}(v, \mathrm{drive}(w, s))$.

Now the definitions that carry the whole subject:

- A word $w$ **locks** the agent if $\mathrm{drive}(w, s) = \mathrm{drive}(w, t)$ for *all* pairs of states $s, t$. One word, universal amnesia: after observing $w$, the agent's state tells you nothing about where it started.
- Two states $s, t$ are **mergeable** if *some* word (possibly depending on the pair) collapses them together.
- The agent design is **phase-locking** if a locking word exists at all.

Phase-lock is exactly the situation our two doppelgängers experience. If $w$ locks the agent, then feeding $w$ to two separated copies drives them into the same state whatever their unknown initial configurations, and they thereafter remain in lockstep forever. Nobody sent a message; the world simply told both of them the same story, and the story had the property of erasing their differences.

## First lesson: telepathy requires forgetting

Here is the cleanest thing the theory has to say, and it decides the whole flavour of the subject.

> **Reversibility obstruction.** Suppose every stimulus acts on the internal state space by an injective map — that is, from the agent's state *after* a stimulus you can always deduce the state *before*. Then, if the agent has at least two distinct states, no locking word exists. Phase-lock is flatly impossible.

The proof is one line. Injective maps compose to injective maps, so the whole word $w$ acts injectively; if $\mathrm{drive}(w,s) = \mathrm{drive}(w,t)$ then $s = t$. Two distinct states can never be merged.

Physicists will recognize the shape of this. Reversible dynamics — unitary evolution, Hamiltonian flow, anything that conserves information — preserves distinctions forever. Two systems evolving reversibly under the same driving remain exactly as distinguishable as they started. **Synchronization requires dissipation.** Telepathy is a consequence of forgetting, not of knowing.

Two toy agents make this vivid. The **parity agent** has a single bit of memory and one stimulus, which flips the bit. It is perfectly reversible, so two parity doppelgängers that start out of phase stay out of phase for eternity, however long the world shouts at them. The **copy agent** also has a single bit, but its stimuli come in two flavours, "become $0$" and "become $1$"; it simply overwrites its memory with what it observes. It phase-locks after exactly one shared stimulus. The difference between eternal isolation and instant communion is precisely the difference between remembering and forgetting.

## Second lesson: pairwise agreement is total agreement

The deepest structural fact in the subject is a bootstrapping phenomenon. Merging *one* pair of states is a local, modest ability. Merging *all* states at once with a *single universal* word is a global, extravagant one. On a finite state space they are the same thing.

> **Synchronization Theorem.** Let the state space $S$ be finite and nonempty. The agent is phase-locking if and only if every individual pair of states is mergeable. Quantitatively: if every pair can be merged by a word of length at most $L$, then a single universal locking word of length at most $(|S| - 1)\,L$ exists.

The proof is a greedy collapse, and it is genuinely beautiful. Track the *image* of the whole state space under the word you have built so far — the set of states still reachable, which is a measure of how much distinguishing information survives. It starts at all of $S$. As long as it contains two distinct elements, grab a word that merges those two; appending it strictly shrinks the image, because two things that were separate have become one and nothing new can be created. Each of these steps costs at most $L$ stimuli and buys at least one unit of collapse, and you need at most $|S| - 1$ of them before the image is a single point. That single point is the locked state.

The image size deserves its own name: the **rank** of a word is the number of distinct states still distinguishable after it. Rank never increases as you append more stimuli — the agent can only lose information, never regain it — and the locking words are exactly the rank-one words. The entire theory is a story about a monotonically decreasing quantity being driven to its floor.

A second pigeonhole argument removes the dependence on $L$ altogether. Watch the *pair* of doppelgängers as a single system on the state space $S \times S$, which has $|S|^2$ configurations. If a merging word is longer than $|S|^2$, some pair-configuration repeats along the way, and the loop between the two repetitions can simply be cut out. So any mergeable pair merges within $|S|^2$ stimuli, and combining the two bounds:

> **Unconditional bound.** A finite agent that phase-locks at all does so within $(|S| - 1)\,|S|^2$ stimuli.

This has a consequence that would please an engineer: since a locking word, if one exists, must be short, you can find it by exhaustive search over a finite set of candidates. **Whether two identical machines can be telepathically synchronized is an algorithmically decidable property of their blueprint.** You can run the check.

## Third lesson: the finite hypothesis is not decoration

Mathematicians are trained to distrust hypotheses they cannot see failing. Here is the failure.

Consider the **countdown agent** whose states are the natural numbers $0, 1, 2, \dots$ and whose single stimulus decrements the counter, with $0$ absorbing. Take any two counters, say $17$ and $4$: watch for $17$ shared stimuli and both are pinned at $0$. Every pair is mergeable. And yet no single word locks everything: a word of length $n$ has left the states $n+1$ and $0$ sitting at $1$ and $0$ respectively, still distinct. Whatever finite word you propose, there is a pair of initial states that outlasts it.

So pairwise telepathy does *not* imply universal telepathy when memory is unbounded. The Synchronization Theorem genuinely needs finiteness. Unlimited memory buys the agent the ability to be, in effect, arbitrarily far out of phase — and no fixed experiment can catch up with all of it.

## Fourth lesson: no signalling

Now for the part that dissolves the mystical framing entirely.

Model the two separated agents honestly as one product system on $S \times S$, where each copy is driven by its own local stimulus. The joint evolution factors perfectly: the first coordinate depends only on the first coordinate's initial state and the first coordinate's stimuli, and likewise for the second. From which:

> **No-Signalling Theorem.** In the joint system, agent 2's internal state is a function of agent 2's own initial state and agent 2's own stimulus stream alone. Changing agent 1's initial state, or agent 1's stimuli, changes nothing whatsoever at agent 2.

Phase-lock is therefore *not a channel*. Nothing that happens at one agent is detectable at the other. What looks like telepathy is a **shared-cause correlation**: two identical mechanisms, driven by one common signal, funnelled into one common state. It is the same reason two identical clocks set running by the same starting pistol agree — except that here the agreement is achieved *despite* different starts, which is why it feels so much more magical than it is.

And the shared cause is indispensable. Feed two copy agents *different* stimulus streams and they remain permanently out of phase, however long they watch. Identical stimuli are not a convenience of the model; they are the entire mechanism.

## Fifth lesson: telepathy is generic

Existence of a locking word is one thing. Would a real environment, blindly emitting stimuli with no intention of synchronizing anybody, ever produce one?

Almost surely, and fast. Suppose $u$ is a locking word of length $L$. Locking words form a two-sided *ideal*: if $w$ locks, then $uwv$ locks for any $u, v$. Once telepathy has been achieved, no amount of additional noise, before or after, can destroy it. So chop a long stimulus stream into blocks of length $L$; the stream locks as soon as *one* block happens to equal $u$. A stream that fails must dodge $u$ in every single block. Counting, with $q = |I|^L$ possible blocks:
$$\frac{\#\{\text{failing streams of } m \text{ blocks}\}}{q^m} \le \left(1 - \frac{1}{q}\right)^{m},$$
which decays geometrically to zero. Under blind environmental driving, doppelgänger phase-lock happens with asymptotic probability one.

The topological version of the same fact is sharper and prettier. Give the space of infinite stimulus streams its natural (Cantor) topology and let the **lock set** be the streams along which some finite prefix locks. Then:

> **Zero–One Law.** The lock set is always open: locking is decided by a finite prefix, so it survives any sufficiently small perturbation of the stream. And if the agent is phase-locking at all, the lock set is dense: *any* finite record of past observations can be extended into a stream that synchronizes the agents. Hence the lock set is either empty — for a non-locking design — or open and dense, its complement nowhere dense. There is no intermediate "thin but nonempty" regime.

Density says something operationally lovely: no experiment can ever be spoiled beyond repair. Whatever the environment has done so far, a continuation that locks the doppelgängers is still available.

But the law cannot be strengthened, and there is an explicit witness. For the three-state agent described in the next section, the constant stimulus stream "rotate, rotate, rotate, …" never locks, because rotation is a bijection and bijections preserve distinctions. So the lock set is open and dense but *neither closed nor everything*. Telepathy is generic; it is not guaranteed.

## The extremal question, and a 1964 mystery

We proved a bound of $(|S|-1)|S|^2$ on the phase-lock time, roughly $n^3$ for $n$ states. Is that the truth?

Almost certainly not. The suspected truth is $(n-1)^2$, and the suspicion is over sixty years old. It is due to Ján Černý, who in 1964 exhibited, for each $n$, an agent achieving exactly $(n-1)^2$ and conjectured that nothing does worse. The agent is disarmingly simple: states $0, 1, \dots, n-1$ arranged in a circle; stimulus "$a$" rotates every state one step forward; stimulus "$b$" collapses state $0$ onto state $1$ and leaves everything else alone. Rotate to line a state up with the collapsing position, collapse, repeat.

Exhaustive certified search settles the small cases exactly. For $n = 3$ the shortest locking word is $baab$, of length $4 = (3-1)^2$ — and no word of length $3$ or fewer works. For $n = 4$ the shortest is $baaabaaab$, of length $9 = (4-1)^2$, with nothing shorter succeeding. Direct search extends the pattern: for every $n$ up to $12$, the shortest locking word of Černý's agent has length exactly $(n-1)^2$ — always landing precisely on the conjectured quadratic, always comfortably below the proved cubic.

Closing the gap between $n^3$ and $(n-1)^2$ in general is the **Černý conjecture**, and it remains open after six decades. It is one of the most famous unsolved problems in combinatorics, and in the language of this article it asks something absurdly concrete: *when two identical machines can be telepathically synchronized at all, how long must the world talk to them?*

## Where the answer is already known

Two special situations resolve completely.

**Contractive agents.** Suppose the state space carries a metric and every stimulus is a uniform $k$-contraction with $k < 1$: any two states are pulled a factor $k$ closer by each observation. Then after a word of length $n$,
$$d(\mathrm{drive}(w,s), \mathrm{drive}(w,t)) \le k^{n}\, d(s,t),$$
*regardless of which stimuli occurred*. The doppelgänger gap collapses exponentially along every possible stream. And if the state space is *quantized* — distinct states separated by at least $\varepsilon$ — and bounded by diameter $D$, then exponential shrinking below $\varepsilon$ forces exact equality: there is an $N$, depending only on $k$, $\varepsilon$, $D$, such that *every* word of length $\ge N$ is a locking word. On a finite metric space both hypotheses are automatic, so every contractive finite agent phase-locks.

This is the analytic mechanism behind the combinatorial phenomenon, and it is the same mathematics that makes a room full of independent thermostats, all reading the same thermometer, converge to the same setting.

But contraction is *strictly stronger* than phase-lock. An agent possessing even one reversible stimulus can never be contractive in any metric: iterate that stimulus around its finite orbit and you return to where you started, having supposedly shrunk all distances by $k^m < 1$ — so all distances are zero and the space is a point. Černý's three-state agent has a rotation, hence admits no contractive metric, yet it phase-locks. The analytic explanation covers a strict subset of the phenomenon.

**Monotone agents.** Suppose the state space is linearly ordered and every stimulus acts as an order-preserving map. Then order does the work of combinatorics: since every state is squeezed between the bottom and top elements, and drive preserves order, once the images of $\bot$ and $\top$ coincide *everything* is trapped between them and hence equal.

> **Order rigidity.** For a monotone agent, a word locks all states if and only if it merges the two extreme states. Consequently such an agent is phase-locking iff $\bot$ and $\top$ are mergeable, and the phase-lock time drops from cubic to $|S|^2$.

One merge does the work of $|S| - 1$ merges; the greedy loop collapses to a single step. Whether this survives the passage from linear orders to general lattices is open, and a natural next target.

## The calculus of designs

Phase-lock behaves well under the operations an engineer actually performs. *Compose two subsystems* that watch the same environment and locking times add: if $w_1$ locks the first and $w_2$ locks the second, then $w_1 w_2$ locks the pair. *Coarse-grain* a design — pass to a surjective homomorphic image, a lumped or simplified description — and every locking word of the fine model still locks the coarse one; you cannot lose synchronizability by simplifying. *Re-encode the environment*, so the agent reacts to a new symbol $i'$ exactly as it would to $g(i')$, and a word in the new alphabet locks precisely when its translation does. The theory is functorial in the sensory interface.

## Why any of this matters

Strip away the doppelgänger framing and this is the theory of **resetting**. A robotic arm on a factory floor has drifted into an unknown internal state; you have no sensor to read it and no wish to open the housing. Is there a fixed sequence of commands that returns it to a known configuration *whatever* state it is in? That is precisely a locking word, and the Synchronization Theorem says: yes, provided every pair of states is individually reconcilable — and you can find such a sequence, and it is not long, and there is an algorithm to decide the question in advance.

The same shape appears in the self-synchronizing codes that let a digital receiver recover from a corrupted bitstream without a handshake; in part orienters that shake components on a vibrating tray into a common alignment with no sensing at all; and in distributed systems seeking a common state without a coordinator.

And the negative results matter just as much. Reversibility kills it — so if your design conserves information, no amount of cleverness in the driving sequence will help. Unbounded memory kills the bootstrap — so the finite-state discipline is doing real work. And no-signalling means the phenomenon, however uncanny it looks from outside, can never be turned into a covert channel.

Which is, in the end, the honest moral. There is no ghost in the machine and no message in the ether. Two identical mechanisms, listening to the same world, forget their differences at the same rate and in the same way — and forgetting, done in perfect unison, is indistinguishable from telepathy.
