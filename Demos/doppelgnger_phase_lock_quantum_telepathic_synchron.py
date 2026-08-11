"""Greedy image-collapse construction of a universal locking word."""

from __future__ import annotations

from typing import Dict, FrozenSet, List, Optional, Sequence, Tuple

Agent = List[List[int]]
Pair = Tuple[int, int]


def drive(agent: Agent, word: Sequence[int], s: int) -> int:
    """State reached from ``s`` after observing the stimulus word ``word``."""
    for i in word:
        s = agent[s][i]
    return s


def image(agent: Agent, word: Sequence[int], states: FrozenSet[int]) -> FrozenSet[int]:
    """The states still distinguishable after ``word``, starting from ``states``."""
    return frozenset(drive(agent, word, s) for s in states)


def greedy_locking_word(
    agent: Agent, merges: Optional[Dict[Pair, List[int]]]
) -> Optional[List[int]]:
    """Build one universal locking word from a table of pairwise merging words.

    This is the constructive content of the Synchronization Theorem.  The *rank* of
    the word built so far -- the size of the surviving image of the state space --
    is a potential function that starts at ``|S|`` and can never increase.  While
    the image contains two distinct states, we append a shortest word merging that
    particular pair; since two previously distinct states become identified and no
    new states can be created, the image strictly shrinks.  At most ``|S| - 1``
    rounds therefore occur, each appending at most ``L`` stimuli, where ``L`` is the
    longest shortest pairwise merge.  The returned word has length at most
    ``(|S| - 1) * L``, and unconditionally at most ``(|S| - 1) * |S|^2``, since a
    pigeonhole argument in the pair system bounds every shortest merge by ``|S|^2``.

    ``merges`` is the table produced by the backward pair-system search; ``None``
    means some pair never merges, so no locking word exists.

    Complexity.  At most ``|S| - 1`` iterations, each recomputing an image in
    ``O(|S| * |v|)`` steps, i.e. ``O(|S|^4)`` overall; output length ``O(|S|^3)``.
    """
    if merges is None:
        return None
    surviving: FrozenSet[int] = frozenset(range(len(agent)))
    word: List[int] = []
    while len(surviving) > 1:
        s, t = sorted(surviving)[:2]
        v = merges[(s, t)]
        word.extend(v)
        surviving = image(agent, v, surviving)
    return word


"""Exact minimal phase-lock time by breadth-first search in the subset lattice."""

from __future__ import annotations

from collections import deque
from typing import FrozenSet, List, Optional, Tuple

Agent = List[List[int]]


def minimal_locking_word(agent: Agent) -> Optional[List[int]]:
    """Shortest stimulus word that drives every internal state to a common state.

    Method.  A word ``w`` is determined, as far as locking is concerned, only by the
    image ``drive(w, S)`` it produces.  So we search the *subset lattice* ``2^S``:
    the start node is the full state space ``S``, each stimulus ``i`` sends a subset
    ``A`` to ``{delta(s, i) : s in A}``, and the goal is any singleton.  Breadth-first
    search therefore returns a shortest locking word, and reports failure exactly when
    no singleton is reachable -- which by the Synchronization Theorem happens precisely
    when some pair of states is unmergeable.

    Note that images only shrink, so the search never revisits a larger subset; the
    reachable portion of the lattice is usually far smaller than ``2^|S|``.

    Complexity.  ``O(|I| * 2^{|S|})`` in the worst case, with ``O(2^{|S|})`` space.
    The exponential dependence is expected: deciding whether a locking word of a
    given length exists is NP-hard, even though deciding mere *existence* of one is
    polynomial via the pair system.  In practice this is comfortable for
    ``|S| <= 20``, which suffices to certify the extremal values ``4`` and ``9`` for
    the three- and four-state agents of the extremal family.
    """
    n = len(agent)
    m = len(agent[0])
    start: FrozenSet[int] = frozenset(range(n))
    if len(start) <= 1:
        return []
    seen = {start}
    queue: deque = deque([(start, [])])
    while queue:
        subset, word = queue.popleft()
        for i in range(m):
            nxt = frozenset(agent[s][i] for s in subset)
            if len(nxt) == 1:
                return word + [i]
            if nxt not in seen:
                seen.add(nxt)
                queue.append((nxt, word + [i]))
    return None


def rank_profile(agent: Agent, word: List[int]) -> List[int]:
    """The rank descent curve: number of distinguishable states after each prefix."""
    surviving: FrozenSet[int] = frozenset(range(len(agent)))
    profile = [len(surviving)]
    for i in word:
        surviving = frozenset(agent[s][i] for s in surviving)
        profile.append(len(surviving))
    return profile


"""Pairwise merge table via backward breadth-first search in the pair system."""

from __future__ import annotations

from collections import deque
from typing import Dict, List, Optional, Tuple

Agent = List[List[int]]
Pair = Tuple[int, int]


def pairwise_merge_words(agent: Agent) -> Optional[Dict[Pair, List[int]]]:
    """Shortest merging word for every unordered pair of internal states.

    Returns a dictionary sending each unordered pair ``(s, t)`` with ``s <= t`` to a
    shortest stimulus word ``v`` with ``drive(v, s) == drive(v, t)``, or ``None`` if
    some pair can never be merged -- in which case, by the Synchronization Theorem,
    the agent design admits no phase-lock at all.

    Method.  Form the *pair system* on ``S x S`` with transitions
    ``(s, t) --i--> (delta(s,i), delta(t,i))``.  Merging ``(s, t)`` is exactly
    reaching the diagonal.  A breadth-first search run *backwards* from the whole
    diagonal simultaneously computes shortest merging words for every pair in one
    sweep.

    Complexity.  ``O(|I| * |S|^2)`` time and ``O(|S|^2)`` space for the search; the
    stored words add ``O(|S|^4)`` in the worst case, since each of the ``O(|S|^2)``
    pairs may require a word of length ``O(|S|^2)``.
    """
    n = len(agent)
    m = len(agent[0])

    def key(s: int, t: int) -> Pair:
        return (s, t) if s <= t else (t, s)

    # Predecessor lists in the pair system, indexed by target pair.
    preds: Dict[Pair, List[Tuple[Pair, int]]] = {}
    for s in range(n):
        for t in range(s, n):
            for i in range(m):
                preds.setdefault(key(agent[s][i], agent[t][i]), []).append((key(s, t), i))

    best: Dict[Pair, List[int]] = {(s, s): [] for s in range(n)}
    queue: deque = deque(best.keys())
    while queue:
        cur = queue.popleft()
        for src, i in preds.get(cur, []):
            if src not in best:
                best[src] = [i] + best[cur]
                queue.append(src)

    if any(key(s, t) not in best for s in range(n) for t in range(s, n)):
        return None
    return best


"""Assemble PACKAGE.json from the project's prose, code, and formal sources."""

from __future__ import annotations

import json
import os
from typing import Any, Dict, List

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS = os.path.join(ROOT, "assets")

LEAN_DIR = "Catalog/Applications/DoppelgangerPhaseLock"
LEAN_ORDER = [
    "Core.lean",
    "Finite.lean",
    "Boundary.lean",
    "Contraction.lean",
    "Counting.lean",
    "Topology.lean",
    "Structure.lean",
    "Decidability.lean",
    "Sharpness.lean",
]


def read(path: str) -> str:
    with open(os.path.join(ROOT, path), encoding="utf-8") as fh:
        return fh.read()


def asset(name: str) -> str:
    with open(os.path.join(ASSETS, name), encoding="utf-8") as fh:
        return fh.read()


lean_files = [f"{LEAN_DIR}/{name}" for name in LEAN_ORDER]
lean_proofs = "\n\n".join(
    f"/- ===================================================================\n"
    f"   FILE: {path}\n"
    f"   =================================================================== -/\n\n"
    + read(path)
    for path in lean_files
)

FUTURE_DIRECTIONS = """# Future Directions — Doppelgänger Phase-Lock

Derived from the analysis and adversarial review of the results established in this
cycle (core theory, finite synchronization, boundaries, contraction, counting,
topology, structure, decidability). Each conjecture below is falsifiable in the exact
sense that it is a precise statement whose negation is also a precise statement, and
each is stated in the vocabulary already developed.

---

## C1 — Quadratic phase-lock time (Černý conjecture, agent form)

**Statement.** For every finite agent `δ : S → I → S` that admits phase-lock, there is
a locking word of length at most `(|S| - 1)²`.

**Status.** We proved the cubic bound `(|S|-1)·|S|²` and verified the quadratic value
exactly on the Černý agents with 3 and 4 states (minimal lock times 4 and 9). This is
the classical Černý conjecture, open since 1964.

**The key insight is** that our cubic bound decomposes as *(number of greedy merge
steps) × (cost of one pairwise merge)*, and both factors are simultaneously extremal
only if the pair automaton has a Hamiltonian-like shortest-merge structure that the
image-collapsing process must repeatedly rebuild — a tension that a potential function
on the lattice of reachable image sets should be able to exploit.

**Why now?** With rank, the ideal structure of locking words, and a certified
exhaustive search procedure already available, one can now systematically verify
candidate potential functions on all agents up to 5–6 states before attempting a
general proof, and the greedy-collapse proof is written so that only the "cost of one
merge step" lemma has to be replaced.

---

## C2 — Order rigidity beyond linear orders

**Statement.** Let `S` be a finite lattice and let every stimulus act as a lattice
homomorphism. Then phase-lock is equivalent to the mergeability of `⊥` and `⊤`, and the
phase-lock time is at most `height(S) · |S|` rather than `|S|³`.

**Status.** Proved for linear orders and monotone (not necessarily homomorphic)
transitions, with a quadratic bound. The lattice case is open; the monotone squeezing
argument uses linearity only through `le_antisymm`-style trapping between `⊥` and `⊤`,
but a genuine lattice needs a chain-decomposition argument.

**The key insight is** that for order-preserving dynamics the whole state space is
squeezed between the images of the two extreme states, so *one* merge does the work of
`|S| - 1` merges — the greedy loop of the general theorem collapses to a single step.

**Why now?** The proof of order rigidity is three lines once monotonicity of the drive
map is available, so the lattice generalization is a low-risk, high-reward extension
that would also immediately sharpen the composition bound.

---

## Further avenues

* **Probabilistic environments.** Replace the uniform block counting with general
  stationary or Markovian stimulus sources and determine the exact phase-lock time
  distribution.
* **Approximate phase-lock.** Quantify partial synchronization by the rank profile of a
  random word, obtaining a rank-descent curve interpolating between `|S|` and `1`.
* **Noisy channels.** Allow the two agents to observe slightly different streams (rare
  discrepancies) and determine the maximal discrepancy rate consistent with recurrent
  phase-lock.
* **Continuous state spaces.** Identify the correct generalization of rank for
  measurable dynamics and connect to random dynamical systems and synchronization by
  common noise.
* **Compositional bounds.** Parallel composition gives an additive bound on locking
  times; determine when it is tight, and whether coarse-graining can strictly reduce
  the lock time.
"""

INTERACTIVE_LAYOUT = r"""
# Doppelgänger Phase-Lock — a guided tour

> Two identical machines. Different rooms. No wire, no radio, no shared clock. Their
> internal configurations are unknown and may differ completely. The world then plays
> them **the same soundtrack**. Can they end up in exactly the same internal state?

The answer is yes — and this page is about exactly when, exactly how fast, and exactly
why it is *not* telepathy. Work through it in order: every idea is built up from the one
before, and the interactive pieces are there for you to break.

---

## 1. The model, in one line

An **agent** is a rule

$$\delta : S \times I \longrightarrow S$$

where $S$ is the set of internal states and $I$ is the alphabet of stimuli the
environment can emit. Reading $\delta(s,i)$ as *"in state $s$, on observing $i$, move to
state $\delta(s,i)$"* is the entire model — deterministic, reactive, no hidden memory.

Feed the agent a finite word $w = i_1 i_2 \cdots i_n$ and write $\mathrm{drive}(w,s)$ for
where it lands starting from $s$. The three definitions that carry the whole subject:

- $w$ **locks** the agent if $\mathrm{drive}(w,s) = \mathrm{drive}(w,t)$ for **all** $s,t$.
  One word, universal amnesia.
- $(s,t)$ is **mergeable** if *some* word — possibly depending on the pair — collapses them.
- the design is **phase-locking** if a locking word exists at all.

<details>
<summary><strong>Why this is exactly the doppelgänger question</strong></summary>

Two separated copies of $\delta$, in unknown states $s$ and $t$, both fed $w$, end in
states $\mathrm{drive}(w,s)$ and $\mathrm{drive}(w,t)$. A locking word forces these to
agree for **every** pair of unknown starting states — which is precisely the claim that
the two doppelgängers are provably in the same state. And once they agree they agree
forever, because both continue to react identically to identical input.

This is the same object that engineers call a **reset sequence**: a fixed command string
that returns a device to a known configuration without any sensor reading its current
state. Everything below therefore has a completely un-mystical second reading.
</details>

---

## 2. Play with it first

Before any theorem, get your hands dirty. Below is a live laboratory. Pick a preset, or
rewire the transition table cell by cell, and watch the coloured markers — one per
possible initial state — merge as information is destroyed.

Three things to try:

1. **The extremal 3-state agent.** Press *Load shortest word* and step through $baab$.
   Notice the rank goes $3 \to 2 \to 2 \to 2 \to 1$: two of the four stimuli buy nothing
   at all in rank, they merely *position* states for the collapse.
2. **The parity agent.** One bit, one stimulus that flips it. The verdict turns red.
   No word will ever lock it, and the rank curve is flat forever.
3. **A random 5-state agent.** Reload a few times. Most random designs lock; the ones
   that don't fail for a reason the panel will tell you.

{{interactive_demo:0}}

<details>
<summary><strong>What the "rank" really is, and why it can only go down</strong></summary>

The **rank** of a word $w$ is the number of distinct values of $\mathrm{drive}(w,\cdot)$ —
the number of internal states still distinguishable to an observer who knows the stimulus
history but not the initial state.

It starts at $|S|$ and is **antitone**: $\mathrm{rank}(wv) \le \mathrm{rank}(w)$, because
the image of a composite map is the image of an image, and images never grow. So rank is
a monotone potential function, an entropy-like count of surviving information about the
past. Locking words are exactly the rank-one words.

This single observation is the skeleton of every positive result on this page.
</details>

---

## 3. The first law: telepathy requires forgetting

Here is the cleanest thing in the whole theory, and it sets the flavour of everything
else.

> **Reversibility Obstruction.** If every stimulus acts injectively on the state space —
> so that from the state *after* an observation you can always recover the state
> *before* — and the agent has at least two states, then **no locking word exists**.

<details>
<summary><strong>Proof (one line)</strong></summary>

A composition of injections is an injection, so $\mathrm{drive}(w,\cdot)$ is injective for
every word $w$. If $\mathrm{drive}(w,s) = \mathrm{drive}(w,t)$ then $s=t$. Two distinct
states can never be merged. $\blacksquare$
</details>

Injectivity per stimulus is the discrete shadow of
[reversible dynamics](https://en.wikipedia.org/wiki/Reversible_computing) — unitary
evolution, Hamiltonian flow, anything that conserves information. So:

> **Synchronization requires dissipation.** A system that never forgets can never come
> into agreement with a differently-initialized copy of itself.

Two toy agents make the point vivid. The **parity agent** (one bit, flipped by every
stimulus) is perfectly reversible and never locks. The **copy agent** (one bit,
overwritten by whatever it observes) forgets everything at once and locks after a single
shared observation. Same state space; the difference between eternal isolation and
instant communion is the difference between remembering and forgetting.

---

## 4. The main theorem: local agreement bootstraps to global agreement

Merging *one* pair of states is a modest, local ability. Merging *all* states with a
*single universal* word is an extravagant, global one. On a finite state space they are
the same thing.

> **Synchronization Theorem.** Let $S$ be finite and nonempty. The agent is phase-locking
> **if and only if** every individual pair of states is mergeable. Quantitatively: if
> every pair merges within $L$ stimuli, a single universal locking word of length at most
> $(|S|-1)\,L$ exists.

The proof is a greedy collapse, and it is genuinely beautiful.

<details>
<summary><strong>Proof sketch: greedy image collapse</strong></summary>

Track the image of the whole state space under the word built so far — the surviving
distinguishable states. It starts as all of $S$.

*While it contains two distinct elements*, grab a word merging those two and append it.
Two previously distinct states become identified, and nothing new can be created, so the
image **strictly shrinks** (if $f(s)=f(t)$ with $s\neq t$ both in $A$, then
$f(A) = f(A\setminus\{s\})$, hence $|f(A)| < |A|$).

Each round costs at most $L$ stimuli and buys at least one unit of collapse, so at most
$|S|-1$ rounds occur. When the image is a single point, that point is the locked state.
$\blacksquare$
</details>

A second, independent pigeonhole argument removes the parameter $L$ entirely: watch the
*pair* of doppelgängers as one system on $S \times S$, which has $|S|^2$ configurations.
Any merging word longer than $|S|^2$ revisits a pair-configuration, and the loop between
the repetitions can be excised. Hence:

> **Unconditional bound.** A finite agent that phase-locks at all does so within
> $(|S|-1)\,|S|^2$ stimuli.

And because a locking word must be *short*, the search for one can be confined to a
finite set: **whether two identical machines can be synchronized is an algorithmically
decidable property of their blueprint.**

Here is the decision procedure, in two parts. First the pairwise merge table, computed in
a single backwards sweep:

{{algorithm:0}}

Then the greedy collapse that turns pairwise merges into one universal word:

{{algorithm:1}}

<details>
<summary><strong>Complexity, and why the exact optimum is harder</strong></summary>

The pair-system sweep is $O(|I|\,|S|^2)$; the greedy loop runs at most $|S|-1$ times.
Deciding *existence* of a locking word is therefore polynomial. But finding the
**shortest** one is NP-hard, and the exact algorithm below searches the subset lattice
$2^S$ — exponential in $|S|$, though comfortable up to about twenty states.

{{algorithm:2}}
</details>

---

## 5. The boundaries: three things phase-lock cannot do

Positive theorems alone would misrepresent the subject.

### Finiteness is not decoration

Consider the **countdown agent** on the natural numbers: one stimulus, $s \mapsto s-1$,
with $0$ absorbing. Every pair merges — watch $\max(s,t)$ steps and both counters are
pinned at $0$. Yet **no single word locks everything**: a word of length $n$ leaves the
states $n+1$ and $0$ sitting at $1$ and $0$, still distinct. Unbounded memory lets states
be arbitrarily far out of phase, and no fixed experiment catches up with all of them.

### No signalling

Model the two agents honestly as one product system in which each receives its *own*
local stimulus. The joint evolution factors perfectly, so:

> **No-Signalling Theorem.** Agent 2's internal state is a function of agent 2's own
> initial state and agent 2's own stimulus stream *alone*. Changing agent 1's initial
> state, or agent 1's entire stimulus history, changes nothing whatsoever at agent 2.

Phase-lock is therefore **not a channel**. It is a *shared-cause* correlation — one common
signal, two identical mechanisms, one common outcome — exactly the classical explanation
of correlated outcomes with a common past.

### The shared stream is the whole mechanism

Feed two copy agents *different* stimuli and they remain permanently out of phase, however
long they watch, even though a single shared stimulus would have locked them instantly.

All of these — plus everything above — are demonstrated numerically here:

{{demo:0}}

---

## 6. Is telepathy typical? A zero–one law

Existence of a locking word says nothing about whether a *blind* environment would ever
produce one. Two answers, and both are emphatic.

**Counting.** Locking words form a two-sided **ideal**: if $w$ locks, so does $uwv$ for
any $u,v$. Once telepathy is achieved, no amount of extra noise before or after can
destroy it. So chop a stream into blocks of the locking word's length $L$; it locks as
soon as *one* block matches. A failing stream must dodge the locking block every single
time, giving a failure fraction of at most

$$\left(1 - \frac{1}{q}\right)^{m}, \qquad q = |I|^{L},$$

over $m$ blocks — geometric decay to zero.

**Topology.** Give the space of infinite stimulus streams its Cantor topology, and let the
**lock set** be those streams some finite prefix of which locks. Then:

> **Zero–One Law.** The lock set is always **open** — locking is decided by a finite
> prefix, so it survives small perturbations. If the agent phase-locks at all, the lock
> set is **dense** — any finite record of observations can be continued into a locking
> stream, so *no experiment can be spoiled beyond repair*. Hence: either empty, or open
> and dense with nowhere-dense complement. There is no thin-but-nonempty regime.

<details>
<summary><strong>Why the law cannot be strengthened</strong></summary>

Could the lock set be *everything*? No. For the extremal three-state agent the constant
"rotate forever" stream never locks, because rotation is a bijection and bijections
preserve distinctions. So the lock set is open and dense but **neither closed nor
everything** — telepathy is generic, but not guaranteed. That single exceptional stream is
the entire content of "nowhere dense".
</details>

Explore both facts at once below. Slide $p$, the probability that the environment emits
the *reversible* rotation rather than the *dissipative* collapse, and watch the phase-lock
time distribution stretch out as you starve the agents of the one stimulus that destroys
information — approaching, in the limit $p \to 1$, the exceptional stream along which they
never lock at all. Note also what happens at $p = 0$: with only the collapse, the agents
jam. Synchronization needs *both* kinds of stimulus.

{{interactive_demo:1}}

And the same phenomena as static plots:

{{visualization:2}}

---

## 7. A mechanism: contraction

Combinatorics says *when*. Here is *why*, when the state space carries a metric.

Suppose every stimulus is a uniform $k$-contraction with $k<1$:
$d(\delta(s,i),\delta(t,i)) \le k\, d(s,t)$. Then for every word,

$$d\bigl(\mathrm{drive}(w,s), \mathrm{drive}(w,t)\bigr) \le k^{|w|}\, d(s,t),$$

*independently of which stimuli occurred*. The gap collapses exponentially along every
possible stream. And if the state space is **quantized** — distinct states at least
$\varepsilon$ apart — and bounded by diameter $D$, then shrinking below $\varepsilon$
forces exact equality: there is an $N$ depending only on $k,\varepsilon,D$ such that
*every* word of length $\ge N$ locks. On a finite metric space both hypotheses are free.

<details>
<summary><strong>A perfect example: the self-synchronizing shift register</strong></summary>

Let the internal state be the record of the last $r$ stimuli, so
$\delta(s,i) = ((s \ll 1)\,|\,i) \bmod 2^r$. Put $d(s,t) = 2^{-L}$ where $L$ is the length
of the longest common suffix. Every stimulus is then an *exact* $\tfrac12$-contraction:
after one shared observation the registers agree in one more low bit. Distinct states are
$2^{-(r-1)}$ apart and the diameter is $1$, so the theory predicts locking after exactly
$r$ stimuli — and indeed every word of length $r$ locks.

This is precisely how a
[self-synchronizing code](https://en.wikipedia.org/wiki/Self-synchronizing_code) lets a
receiver recover frame alignment after corruption, with no handshake.
</details>

But contraction is **strictly stronger** than phase-lock. An agent with even one
*bijective* stimulus admits no contractive metric at all: iterate that stimulus around its
finite orbit and you return where you started, having supposedly shrunk every distance by
$k^m < 1$ — so all distances vanish. The extremal three-state agent has a rotation, hence
no contractive metric, yet it phase-locks. The analytic explanation covers a strict subset
of the phenomenon, and the hard extremal question lives entirely in the rest.

---

## 8. Structure: how designs combine

Phase-lock behaves well under the operations an engineer actually performs.

| operation | effect on phase-lock |
|---|---|
| **parallel composition** — two subsystems watching the same environment | preserved; locking times **add**: $w_1$ locks the first and $w_2$ the second $\Rightarrow$ $w_1w_2$ locks the pair |
| **coarse-graining** — pass to a surjective homomorphic image | preserved; every locking word of the fine model locks the coarse one |
| **relabelling** — the agent reacts to $i'$ as it would to $g(i')$ | functorial: $w$ locks the relabelled agent iff $g(w)$ locks the original |
| **monotone dynamics on a linear order** | **order rigidity**: locking the two *extremes* locks everything; bound drops from cubic to $|S|^2$ |

<details>
<summary><strong>Order rigidity, proved</strong></summary>

Suppose $S$ is linearly ordered with least element $\bot$ and greatest $\top$, and every
stimulus is order-preserving. Then $\mathrm{drive}(w,\cdot)$ is monotone, so for any $x$,

$$\mathrm{drive}(w,\bot) \;\le\; \mathrm{drive}(w,x) \;\le\; \mathrm{drive}(w,\top).$$

If the two outer terms are equal, $\mathrm{drive}(w,x)$ is squeezed to their common value —
for *every* $x$ simultaneously. So a word locks iff it merges $\bot$ and $\top$. **One**
merge does the work of $|S|-1$ merges, and the greedy loop collapses to a single step,
giving a quadratic bound. $\blacksquare$

Whether this survives from linear orders to general lattices is open, and is one of the
two headline questions of the subject.
</details>

---

## 9. The extremal question: a 1964 mystery

We proved $(|S|-1)|S|^2$, roughly $n^3$. The suspected truth is $(n-1)^2$, conjectured by
Ján Černý in 1964 and open ever since — one of the best-known unsolved problems in
combinatorics. His extremal family is disarmingly simple: states in a circle, one stimulus
rotating everything one step, one stimulus collapsing state $0$ onto state $1$. Rotate to
line a state up with the collapsing position, collapse, repeat.

Exhaustive search settles the small cases exactly: the shortest locking word of the
three-state agent is $baab$ (length $4 = 2^2$), of the four-state agent $baaabaaab$
(length $9 = 3^2$), and the pattern $(n-1)^2$ holds exactly for every $n$ up to $12$.

{{visualization:1}}

{{demo:1}}

<details>
<summary><strong>Where the cubic bound loses — and how a proof might go</strong></summary>

Our bound factors as

$$\underbrace{(n-1)}_{\text{number of greedy merge steps}} \times \underbrace{n^2}_{\text{worst cost of one merge}},$$

and both factors are extremal *simultaneously* only if the pair system has a
longest-shortest-merge structure that the collapsing process must rebuild from scratch
every round. In Černý's own agents this emphatically fails: each merge used by the optimal
word costs about $n$, not $n^2$, because after each collapse the surviving image is
*already positioned* for the next one.

A potential function on the lattice of reachable image sets that captures this
amortization is the natural line of attack — and order rigidity (§8) shows that when the
state space carries enough order structure, exactly such an amortization can be made
rigorous.
</details>

Finally, watch the information itself drain away. Each blue trace is the rank descent
along a random stimulus stream; the red trace is the descent along an optimal locking word.
Notice how the optimal word spends most of its length at *constant* rank, doing positioning
work that pays off only at the collapse steps.

{{visualization:0}}

---

## 10. Why any of this matters

Strip away the doppelgänger framing and this is the theory of **blind resetting**. A
robotic arm has drifted into an unknown internal state; you have no sensor to read it and
no wish to open the housing. Is there a fixed command sequence that returns it to a known
configuration *whatever* state it is in? That is a locking word, and the theory says: yes,
provided every pair of states is individually reconcilable; and the sequence is short; and
you can decide the question at design time.

The same shape appears in
[self-synchronizing codes](https://en.wikipedia.org/wiki/Self-synchronizing_code), in
sensorless part orienters that shake components on a vibrating tray into a common
alignment, in homing sequences for conformance testing, and in distributed systems seeking
a common state without a coordinator.

The negative results matter just as much. Reversibility kills it, so an
information-conserving design cannot be rescued by cleverness in the driving sequence.
Unbounded memory kills the bootstrap, so the finite-state discipline is doing real work.
And no-signalling means the phenomenon, however uncanny from outside, can never be turned
into a covert channel.

Which is the honest moral. There is no ghost in the machine and no message in the ether.
Two identical mechanisms, listening to the same world, forget their differences at the same
rate and in the same way — and forgetting, done in perfect unison, is indistinguishable
from telepathy.
"""

package: Dict[str, Any] = {
    "title": "Doppelgänger Phase-Lock: Synchronizing Two Separated Identical Agents",
    "domain": "Applications",
    "description": (
        "A complete theory of when two spatially separated, structurally identical "
        "deterministic agents driven by the same stimulus stream reach exactly the same "
        "internal state: pairwise mergeability implies a universal locking word within "
        "(|S|-1)|S|² stimuli on a finite state space, while reversibility, unbounded "
        "memory, or unshared stimuli make synchronization impossible, and the "
        "correlation provably carries no signal."
    ),
    "authors": ["Aristotle"],
    "date": "2026-08-11",
    "key_results": [
        "Synchronization Theorem: for a finite internal state space, a universal locking "
        "stimulus word exists if and only if every individual pair of states is "
        "mergeable, with locking time at most (|S|-1)L when pairs merge within L "
        "stimuli, and unconditionally at most (|S|-1)|S|² stimuli",
        "Reversibility obstruction: if every stimulus acts injectively on the state "
        "space, no locking word exists once the agent has two distinct states — "
        "synchronization requires dissipative, information-destroying dynamics",
        "No-signalling theorem: in the product system each agent's internal state depends "
        "only on its own initial state and its own stimuli, so phase-lock is a "
        "shared-cause correlation and never a communication channel",
        "Topological zero–one law: the set of infinite stimulus streams along which the "
        "agents synchronize is always open, and is dense whenever synchronization is "
        "possible at all, hence either empty or open and dense with nowhere-dense "
        "complement — and this is sharp, since a phase-locking agent can still admit "
        "non-locking streams",
        "Order rigidity and exact extremal values: for monotone agents on a linearly "
        "ordered state space, locking the two extreme states locks every state, lowering "
        "the bound to |S|²; and the three- and four-state rotate-and-collapse agents have "
        "minimal phase-lock times exactly 4 and 9, the conjectured extremal value (n-1)²",
    ],
    "keywords": [
        "synchronizing word",
        "reset sequence",
        "deterministic automaton",
        "Černý conjecture",
        "transition monoid",
        "contraction mapping",
        "zero-one law",
        "no-signalling",
    ],
    "article": read("ARTICLE.md"),
    "research_paper": read("RESEARCH_PAPER.md"),
    "research_paper_tex": read("RESEARCH_PAPER.tex"),
    "demo": read("demo.py"),
    "demos": [
        {
            "name": "Complete Numerical Tour of Doppelgänger Phase-Lock",
            "description": (
                "A ten-part numerical demonstration covering the entire theory. It traces "
                "the rank descent of a locking word and animates two separated agents "
                "coming into phase; constructs a universal locking word greedily from the "
                "table of pairwise merges and checks it against the theoretical bound "
                "(|S|-1)L; compares the proved cubic bound with the greedy construction "
                "and the exact optimum computed by breadth-first search; certifies the "
                "extremal values (n-1)² by brute-force enumeration of every shorter word; "
                "exhibits the reversibility obstruction by contrasting the parity agent "
                "(never locks) with the copy agent (locks in one step); shows pairwise "
                "mergeability without global locking on the infinite-state countdown "
                "agent; verifies no-signalling numerically and shows that differing "
                "stimulus streams destroy synchronization entirely; measures the "
                "geometric decay of the failure fraction under blind random driving "
                "against the proved bound (1-1/q)^m; exhibits an exact one-half "
                "contraction on a shift-register state space where quantization forces "
                "exact locking after precisely the predicted number of stimuli; and "
                "confirms order rigidity on monotone chains."
            ),
            "code": read("demo.py"),
        },
        {
            "name": "Extremal Phase-Lock Times and the Source of the Cubic Slack",
            "description": (
                "A focused computational study of the extremal question. It computes exact "
                "phase-lock times for the rotate-and-collapse family up to twelve states, "
                "confirming the value (n-1)² in every case and showing the proved cubic "
                "bound to be loose by a factor growing linearly in n; certifies by "
                "exhaustive enumeration that no shorter word can lock the small members of "
                "the family; surveys thousands of random two-stimulus designs to show that "
                "typical agents are lockable and lock far faster than the worst case, so "
                "extremal behaviour is rare and delicately engineered; and finally "
                "decomposes the cubic bound into its two factors — the number of greedy "
                "merge steps and the worst cost of a single pairwise merge — measuring "
                "each separately to localize exactly where the proof loses, which is the "
                "amortization that a proof of the quadratic conjecture would have to "
                "capture."
            ),
            "code": asset("demo_extremal.py"),
        },
    ],
    "algorithms": [
        {
            "name": "Pairwise Merge Table by Backward Breadth-First Search in the Pair System",
            "description": (
                "Computes, for every unordered pair of internal states, a shortest stimulus "
                "word that merges them — or reports that some pair can never be merged, "
                "which by the Synchronization Theorem certifies that the agent design admits "
                "no phase-lock whatsoever. The mathematical foundation is the pair system on "
                "S × S with transitions (s,t) → (δ(s,i), δ(t,i)): merging a pair is exactly "
                "reaching the diagonal, so a single breadth-first search run backwards from "
                "the entire diagonal solves all |S|²/2 shortest-path problems in one sweep. "
                "Combined with the pigeonhole argument in the pair system, this also proves "
                "that every mergeable pair merges within |S|² stimuli. Time complexity is "
                "O(|I| · |S|²) with O(|S|²) space for the search itself. This is the first "
                "half of the polynomial-time decision procedure for phase-lockability, and "
                "the source of the merging words consumed by the greedy collapse."
            ),
            "pseudocode": (
                "INPUT   finite state set S, stimulus alphabet I, transition table delta\n"
                "OUTPUT  best[(s,t)] = shortest word merging s and t, or FAIL\n"
                "\n"
                "1.  for each unordered pair (s,t) and each stimulus i:\n"
                "2.      tgt <- unordered pair (delta(s,i), delta(t,i))\n"
                "3.      append ((s,t), i) to preds[tgt]           // reverse edges\n"
                "\n"
                "4.  best <- { (s,s) -> empty word : s in S }      // the diagonal\n"
                "5.  Q <- queue containing all diagonal pairs\n"
                "6.  while Q not empty:\n"
                "7.      cur <- dequeue(Q)\n"
                "8.      for each (src, i) in preds[cur]:\n"
                "9.          if src not in best:\n"
                "10.             best[src] <- i prefixed to best[cur]\n"
                "11.             enqueue(Q, src)\n"
                "\n"
                "12. if some unordered pair is missing from best:\n"
                "13.     return FAIL          // that pair is unmergeable: no phase-lock\n"
                "14. return best"
            ),
            "code": asset("algo_pairwise_merge.py"),
        },
        {
            "name": "Greedy Image-Collapse Construction of a Universal Locking Word",
            "description": (
                "Turns a table of pairwise merging words into a single universal locking "
                "word, and is the constructive content of the Synchronization Theorem. The "
                "governing quantity is the rank — the size of the image of the state space "
                "under the word built so far — which begins at |S|, can never increase "
                "(images do not grow under further maps), and equals 1 exactly when the word "
                "locks. While the surviving image contains two distinct states, the "
                "algorithm appends a shortest word merging that pair; since the two become "
                "identified and no new states can appear, the image strictly shrinks. Hence "
                "at most |S| − 1 rounds occur, each contributing at most L stimuli, giving "
                "output length at most (|S| − 1)·L, and unconditionally at most "
                "(|S| − 1)·|S|² once the pigeonhole bound L ≤ |S|² is invoked. Time "
                "complexity O(|S|⁴) for the image recomputations, output length O(|S|³). "
                "Whether the true worst case is instead the conjectured (|S| − 1)² is the "
                "central open problem of the subject."
            ),
            "pseudocode": (
                "INPUT   agent delta on state set S; table best of pairwise merging words\n"
                "OUTPUT  a word w with drive(w, s) equal for all s, or FAIL\n"
                "\n"
                "1.  if best = FAIL: return FAIL        // some pair never merges\n"
                "2.  surviving <- S                     // the image so far; rank = |S|\n"
                "3.  w <- empty word\n"
                "4.  while |surviving| > 1:\n"
                "5.      choose distinct s, t in surviving\n"
                "6.      v <- best[(s,t)]               // shortest merge for this pair\n"
                "7.      w <- w concatenated with v\n"
                "8.      surviving <- { drive(v, x) : x in surviving }\n"
                "9.      // rank strictly decreased: s and t now coincide\n"
                "10. return w                           // rank is 1: the word locks"
            ),
            "code": asset("algo_greedy_collapse.py"),
        },
        {
            "name": "Exact Minimal Phase-Lock Time by Search in the Subset Lattice",
            "description": (
                "Computes the exact shortest locking word, rather than the O(|S|³) word "
                "returned by the greedy construction. The key observation is that, as far as "
                "locking is concerned, a word is determined entirely by the image it "
                "produces; so the search space is the lattice of subsets of S, with the full "
                "state space as the start node, each stimulus acting as a monotone "
                "contraction of subsets, and any singleton as a goal. Breadth-first search "
                "therefore returns a shortest locking word and reports failure exactly when "
                "no singleton is reachable. Worst-case complexity is O(|I| · 2^|S|) time and "
                "space, and this exponential dependence is expected, since deciding whether "
                "a locking word of a given length exists is NP-hard even though deciding "
                "mere existence is polynomial via the pair system. In practice the reachable "
                "portion of the lattice is far smaller than 2^|S|, and the procedure "
                "comfortably certifies extremal values for twenty or more states — enough to "
                "confirm the exact values 4 and 9 for the three- and four-state extremal "
                "agents, and the pattern (n−1)² well beyond. The companion routine returns "
                "the full rank-descent profile of a word, the monotone potential that drives "
                "every positive result in the theory."
            ),
            "pseudocode": (
                "INPUT   agent delta on state set S with alphabet I\n"
                "OUTPUT  a shortest word w with |image(w)| = 1, or NONE\n"
                "\n"
                "1.  start <- S\n"
                "2.  if |start| <= 1: return empty word\n"
                "3.  seen <- { start };  Q <- queue containing (start, empty word)\n"
                "4.  while Q not empty:\n"
                "5.      (A, w) <- dequeue(Q)\n"
                "6.      for each stimulus i in I:\n"
                "7.          B <- { delta(s, i) : s in A }        // rank never increases\n"
                "8.          if |B| = 1: return w followed by i   // shortest locking word\n"
                "9.          if B not in seen:\n"
                "10.             insert B into seen\n"
                "11.             enqueue(Q, (B, w followed by i))\n"
                "12. return NONE                                  // not phase-locking"
            ),
            "code": asset("algo_minimal_lock.py"),
        },
    ],
    "visualizations": [
        {
            "name": "Rank Descent: How Distinguishability Is Destroyed",
            "description": (
                "For the rotate-and-collapse agents with 4, 6 and 8 states, this figure "
                "overlays forty rank-descent curves under blind random driving with the "
                "descent along an optimal locking word. The rank — the number of internal "
                "states still distinguishable — starts at |S|, is antitone, and reaching 1 "
                "is exactly phase-lock. The optimal word's curve reveals the strategy: long "
                "stretches at constant rank, in which the reversible rotation merely "
                "positions states, punctuated by the collapses that actually destroy "
                "information."
            ),
            "code": asset("viz_rank_descent.py"),
        },
        {
            "name": "Phase-Lock Time: Proved Bound, Greedy Construction, Exact Optimum",
            "description": (
                "Plots, as a function of the number of internal states, the proved "
                "unconditional bound (n−1)n², the length produced by the greedy "
                "image-collapse construction, and the exact minimum obtained by search in "
                "the subset lattice, against the conjectured extremal value (n−1)². The "
                "exact minima land on the quadratic in every case, and a companion panel "
                "shows the ratio of the proved bound to the truth growing linearly in n — a "
                "direct picture of the gap that the long-standing extremal conjecture asks "
                "us to close."
            ),
            "code": asset("viz_lock_time.py"),
        },
        {
            "name": "Genericity of Synchronization and the Exceptional Streams",
            "description": (
                "Two panels quantifying how typical phase-lock is. The left panel compares "
                "the measured fraction of uniformly random stimulus streams that fail to "
                "lock with the proved bound (1 − 1/q)^m, where q = |I|^L is the number of "
                "blocks of the locking word's length; both decay geometrically. The right "
                "panel makes the topological zero–one law visible: as the probability of "
                "emitting the reversible rotation approaches one, the median phase-lock time "
                "diverges and the fraction of streams still unlocked rises to one, "
                "approaching the single exceptional stream along which a phase-locking agent "
                "never synchronizes at all."
            ),
            "code": asset("viz_genericity.py"),
        },
    ],
    "interactive_demos": [
        {
            "title": "The Phase-Lock Laboratory: Rewire an Agent and Watch It Synchronize",
            "description": (
                "A complete, self-contained laboratory for the theory. Choose from presets — "
                "the rotate-and-collapse extremal agents with three to five states, the "
                "reversible parity agent, the amnesiac copy agent, a contractive shift "
                "register, a monotone chain, or a fresh random design — or rewire any cell "
                "of the transition table by hand. Two circular state diagrams show the two "
                "separated doppelgängers, with one coloured marker per possible initial "
                "state; the markers visibly merge as information is destroyed. A live panel "
                "runs the full decision procedure: it computes the shortest merging word for "
                "every pair by backward search in the pair system, declares the design "
                "phase-locking or not (and names an unmergeable pair, flagging when the "
                "reason is that every stimulus is invertible), builds a universal locking "
                "word greedily, and finds the exact optimum by searching the subset lattice, "
                "comparing all of these to the proved bound (|S|−1)|S|². Load either word "
                "onto the stimulus tape and step or play through it while the rank-descent "
                "chart tracks the surviving distinguishable states in real time. The single "
                "most instructive experiment: switch to the parity agent and watch the rank "
                "curve stay flat forever — reversible agents can never synchronize."
            ),
            "html": asset("widget_lab.html"),
        },
        {
            "title": "The Zero–One Law: Is Telepathy Typical, and When Does It Fail?",
            "description": (
                "An experimental probe of how generic synchronization really is. The "
                "three-state extremal agent is driven by a random stimulus stream that emits "
                "the reversible rotation with probability p and the dissipative collapse "
                "with probability 1 − p. Run thousands of trials at any p and read off the "
                "mean, median and 95th percentile phase-lock time together with a live "
                "histogram, in which the theoretical minimum (n−1)² = 4 is highlighted. "
                "Sliding p towards 1 starves the agents of the only stimulus that destroys "
                "information and the distribution stretches without bound, approaching the "
                "exceptional constant stream along which the agents never lock — the "
                "nowhere-dense failure set made visible. Sliding p to 0 jams them the other "
                "way, since without rotation two of the states can never be brought "
                "together, demonstrating that synchronization needs both a positioning "
                "stimulus and a dissipative one. A second panel plots the proved block bound "
                "(1 − 1/16)^m against the number of observed blocks, and a live animation "
                "traces a single stream, showing the surviving state set shrink until the "
                "rank reaches one and the lock becomes permanent."
            ),
            "html": asset("widget_zeroone.html"),
        },
    ],
    "interactive_layout": INTERACTIVE_LAYOUT,
    "lean_proofs": lean_proofs,
    "future_directions": FUTURE_DIRECTIONS,
    "modules": {
        "demo": read("demo.py"),
        "demo_extremal": asset("demo_extremal.py"),
        "algo_pairwise_merge": asset("algo_pairwise_merge.py"),
        "algo_greedy_collapse": asset("algo_greedy_collapse.py"),
        "algo_minimal_lock": asset("algo_minimal_lock.py"),
        "viz_rank_descent": asset("viz_rank_descent.py"),
        "viz_lock_time": asset("viz_lock_time.py"),
        "viz_genericity": asset("viz_genericity.py"),
    },
    "lean_files": lean_files,
}

with open(os.path.join(ROOT, "PACKAGE.json"), "w", encoding="utf-8") as fh:
    json.dump(package, fh, ensure_ascii=False, indent=2)

print("PACKAGE.json written")


"""
Extremal phase-lock times: how long must the world talk to two identical agents?
================================================================================

An agent is a transition rule delta : S x I -> S on a finite internal state space.
A stimulus word LOCKS the agent when it drives every internal state to one and the
same state, so that two separated copies of the agent end up in identical internal
states however they were initialized.  The *phase-lock time* of a design is the
length of its shortest locking word.

The general theory proves an upper bound of (|S| - 1) * |S|^2 on the phase-lock time
of any lockable design.  The conjectured truth is (|S| - 1)^2, attained by the
extremal family

    states 0, 1, ..., n-1;   stimulus a : s -> s + 1 (mod n);
                             stimulus b : 0 -> 1, s -> s otherwise.

This script measures phase-lock times exactly, three ways:

  * exact minimum by breadth-first search in the subset lattice 2^S;
  * brute-force certification (for small n) that literally no shorter word locks;
  * a randomized survey of phase-lock times over random agent designs, showing that
    the extremal family really is extremal in practice and that typical designs lock
    far faster than the worst case.

Self-contained: standard library only.
"""

from __future__ import annotations

import itertools
import random
from collections import deque
from statistics import mean
from typing import Dict, FrozenSet, List, Optional, Tuple

Agent = List[List[int]]


# ---------------------------------------------------------------------------


def cerny_agent(n: int) -> Agent:
    """The extremal family: stimulus 0 rotates, stimulus 1 collapses state 0 onto 1."""
    return [[(s + 1) % n, (1 if s == 0 else s)] for s in range(n)]


def random_agent(n: int, m: int, rng: random.Random) -> Agent:
    return [[rng.randrange(n) for _ in range(m)] for _ in range(n)]


def locks(agent: Agent, word: Tuple[int, ...]) -> bool:
    surviving: FrozenSet[int] = frozenset(range(len(agent)))
    for i in word:
        surviving = frozenset(agent[s][i] for s in surviving)
    return len(surviving) == 1


def minimal_lock_time(agent: Agent) -> Optional[int]:
    """Exact phase-lock time by breadth-first search over reachable image sets."""
    n, m = len(agent), len(agent[0])
    start: FrozenSet[int] = frozenset(range(n))
    if len(start) <= 1:
        return 0
    seen = {start}
    queue: deque = deque([(start, 0)])
    while queue:
        subset, d = queue.popleft()
        for i in range(m):
            nxt = frozenset(agent[s][i] for s in subset)
            if len(nxt) == 1:
                return d + 1
            if nxt not in seen:
                seen.add(nxt)
                queue.append((nxt, d + 1))
    return None


def optimal_word(agent: Agent) -> Optional[List[int]]:
    n, m = len(agent), len(agent[0])
    start: FrozenSet[int] = frozenset(range(n))
    seen = {start}
    queue: deque = deque([(start, [])])
    while queue:
        subset, w = queue.popleft()
        for i in range(m):
            nxt = frozenset(agent[s][i] for s in subset)
            if len(nxt) == 1:
                return w + [i]
            if nxt not in seen:
                seen.add(nxt)
                queue.append((nxt, w + [i]))
    return None


def brute_force_certificate(agent: Agent, claimed: int) -> bool:
    """Confirm by exhaustive enumeration that no word shorter than `claimed` locks."""
    m = len(agent[0])
    return not any(
        locks(agent, w)
        for k in range(claimed)
        for w in itertools.product(range(m), repeat=k)
    )


# ---------------------------------------------------------------------------


def part_1_extremal_family() -> None:
    print("=" * 78)
    print("1.  Exact phase-lock times of the extremal family")
    print("=" * 78)
    print(f"{'n':>3} {'exact minimum':>15} {'(n-1)^2':>9} {'proved bound':>14}"
          f" {'slack factor':>13}")
    print("-" * 60)
    for n in range(2, 13):
        agent = cerny_agent(n)
        t = minimal_lock_time(agent)
        assert t is not None
        bound = (n - 1) * n * n
        print(f"{n:>3} {t:>15} {(n - 1) ** 2:>9} {bound:>14} {bound / t:>13.2f}")
    print("\n  The exact minimum equals (n-1)^2 in every case: the extremal family sits")
    print("  exactly on the conjectured quadratic, and the proved cubic bound is loose")
    print("  by a factor growing linearly in n.")


def part_2_certificates() -> None:
    print()
    print("=" * 78)
    print("2.  Brute-force certificates: no shorter word can possibly lock")
    print("=" * 78)
    for n in (2, 3, 4):
        agent = cerny_agent(n)
        t = minimal_lock_time(agent)
        w = optimal_word(agent)
        assert t is not None and w is not None
        total = sum(2 ** k for k in range(t))
        ok = brute_force_certificate(agent, t)
        print(f"   n = {n}:  optimal word {''.join('ab'[i] for i in w):<12}"
              f" length {t:>2};  all {total:>4} shorter words checked, none locks: {ok}")


def part_3_random_survey() -> None:
    print()
    print("=" * 78)
    print("3.  Randomized survey: typical designs lock far faster than the worst case")
    print("=" * 78)
    rng = random.Random(31415)
    trials = 4000
    print(f"{'n':>3} {'lockable':>10} {'mean time':>11} {'max seen':>10}"
          f" {'(n-1)^2':>9} {'proved bound':>14}")
    print("-" * 62)
    for n in range(2, 10):
        times: List[int] = []
        lockable = 0
        for _ in range(trials):
            t = minimal_lock_time(random_agent(n, 2, rng))
            if t is not None:
                lockable += 1
                times.append(t)
        print(f"{n:>3} {100 * lockable / trials:>9.1f}% {mean(times):>11.2f}"
              f" {max(times):>10} {(n - 1) ** 2:>9} {(n - 1) * n * n:>14}")
    print("\n  Random two-stimulus designs are lockable most of the time, and when they")
    print("  are, they lock in a number of stimuli that grows far more slowly than the")
    print("  worst case: extremal behaviour is rare and delicately engineered.")


def part_4_where_the_slack_is() -> None:
    print()
    print("=" * 78)
    print("4.  Where the cubic bound loses: merge cost versus merge count")
    print("=" * 78)
    print("  The proved bound factors as (number of greedy merge steps) x (cost of one")
    print("  pairwise merge) = (n-1) x n^2.  On the extremal family the two factors are")
    print("  never simultaneously extremal:")
    print()
    print(f"{'n':>3} {'merge steps':>13} {'worst merge':>13} {'product':>9}"
          f" {'true optimum':>14}")
    print("-" * 56)
    for n in range(3, 10):
        agent = cerny_agent(n)
        merges = pairwise_merge_lengths(agent)
        worst = max(merges.values())
        steps = n - 1
        t = minimal_lock_time(agent)
        assert t is not None
        print(f"{n:>3} {steps:>13} {worst:>13} {steps * worst:>9} {t:>14}")
    print("\n  The worst single merge costs n(n-1)/2 -- about half of the n^2 allowed by")
    print("  the pigeonhole bound -- and the merges cannot all be worst-case at once: after")
    print("  each collapse the surviving image is already well positioned for the next.")
    print("  Even the product of the two measured factors overshoots the true optimum by")
    print("  a factor of about n/2.  Making that amortization rigorous is exactly what a")
    print("  proof of the quadratic conjecture would require.")


def pairwise_merge_lengths(agent: Agent) -> Dict[Tuple[int, int], int]:
    n, m = len(agent), len(agent[0])

    def key(s: int, t: int) -> Tuple[int, int]:
        return (s, t) if s <= t else (t, s)

    preds: Dict[Tuple[int, int], List[Tuple[Tuple[int, int], int]]] = {}
    for s in range(n):
        for t in range(s, n):
            for i in range(m):
                preds.setdefault(key(agent[s][i], agent[t][i]), []).append((key(s, t), i))
    dist: Dict[Tuple[int, int], int] = {(s, s): 0 for s in range(n)}
    queue: deque = deque(dist.keys())
    while queue:
        cur = queue.popleft()
        for src, _ in preds.get(cur, []):
            if src not in dist:
                dist[src] = dist[cur] + 1
                queue.append(src)
    return {p: d for p, d in dist.items() if p[0] != p[1]}


def main() -> None:
    print(__doc__)
    part_1_extremal_family()
    part_2_certificates()
    part_3_random_survey()
    part_4_where_the_slack_is()


if __name__ == "__main__":
    main()


"""Visualization: how typical is phase-lock under blind environmental driving?

Left panel: the measured fraction of uniformly random stimulus streams that fail to
phase-lock the doppelganger pair, against the proved bound (1 - 1/q)^m with
q = |I|^L block values and m blocks of length L.  Both decay geometrically.

Right panel: the exceptional streams.  The extremal three-state agent phase-locks,
yet along the constant "rotate forever" stream it never does, because rotation is a
bijection and bijections preserve distinctions.  We plot the failure probability of a
stream that emits the rotation stimulus with probability p, showing the divergence of
the locking time as p approaches 1 -- the nowhere-dense set of exceptional streams
made visible.
"""

from __future__ import annotations

import random
from typing import FrozenSet, List

import matplotlib.pyplot as plt

Agent = List[List[int]]


def cerny_agent(n: int) -> Agent:
    return [[(s + 1) % n, (1 if s == 0 else s)] for s in range(n)]


def locks(agent: Agent, word: List[int]) -> bool:
    surviving: FrozenSet[int] = frozenset(range(len(agent)))
    for i in word:
        surviving = frozenset(agent[s][i] for s in surviving)
        if len(surviving) == 1:
            return True
    return len(surviving) == 1


def lock_time(agent: Agent, rng: random.Random, p_rotate: float, cap: int) -> int:
    """Number of stimuli until phase-lock, or `cap` if not locked within `cap`."""
    surviving: FrozenSet[int] = frozenset(range(len(agent)))
    for step in range(1, cap + 1):
        i = 0 if rng.random() < p_rotate else 1
        surviving = frozenset(agent[s][i] for s in surviving)
        if len(surviving) == 1:
            return step
    return cap


def main() -> None:
    rng = random.Random(4242)
    agent = cerny_agent(3)
    L, q, trials = 4, 2 ** 4, 40000

    blocks = list(range(1, 17))
    bound = [(1 - 1 / q) ** m for m in blocks]
    measured = []
    for m in blocks:
        fails = sum(
            0 if locks(agent, [rng.randrange(2) for _ in range(L * m)]) else 1
            for _ in range(trials)
        )
        measured.append(fails / trials)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.semilogy(blocks, bound, "o--", color="#334488",
                 label=r"proved bound $(1 - 1/q)^m$, $q = |I|^L = 16$")
    ax1.semilogy(blocks, measured, "s-", color="#cc3311", label="measured failure fraction")
    ax1.set_xlabel(r"number of blocks $m$ (block length $L = 4$)")
    ax1.set_ylabel("fraction of streams that fail to lock")
    ax1.set_title("Blind driving locks the doppelgangers almost surely")
    ax1.legend()
    ax1.grid(alpha=0.3, which="both")

    ps = [i / 40 for i in range(41)]
    cap = 400
    med = []
    never = []
    for p in ps:
        times = [lock_time(agent, rng, p, cap) for _ in range(600)]
        times.sort()
        med.append(times[len(times) // 2])
        never.append(sum(1 for t in times if t >= cap) / len(times))

    ax2.plot(ps, med, "o-", color="#118844", label="median phase-lock time")
    ax2.set_xlabel(r"probability $p$ of emitting the reversible (rotate) stimulus")
    ax2.set_ylabel(f"stimuli until phase-lock (capped at {cap})")
    ax2.set_title("Approaching the exceptional stream: locking time diverges as $p \\to 1$")
    ax2.grid(alpha=0.3)
    ax2b = ax2.twinx()
    ax2b.plot(ps, never, "s--", color="#884499", alpha=0.7,
              label=f"fraction never locked within {cap}")
    ax2b.set_ylabel("fraction still unlocked")
    lines = ax2.get_lines() + ax2b.get_lines()
    ax2.legend(lines, [ln.get_label() for ln in lines], loc="upper left", fontsize=9)

    fig.tight_layout()
    fig.savefig("genericity.png", dpi=160)
    print("wrote genericity.png")


if __name__ == "__main__":
    main()


"""Visualization: phase-lock time -- proved bound, greedy construction, exact optimum.

Three curves as a function of the number of internal states n:

  * the proved unconditional upper bound (n - 1) * n^2;
  * the length of the word produced by the greedy image-collapse construction;
  * the exact minimal phase-lock time, computed by breadth-first search in the
    subset lattice;

together with the conjectured extremal value (n - 1)^2, which the exact minima match
on the extremal agent family.  The gap between the cubic bound and the quadratic
truth is the content of the long-standing extremal conjecture.
"""

from __future__ import annotations

from collections import deque
from typing import Dict, FrozenSet, List, Optional, Tuple

import matplotlib.pyplot as plt

Agent = List[List[int]]
Pair = Tuple[int, int]


def cerny_agent(n: int) -> Agent:
    return [[(s + 1) % n, (1 if s == 0 else s)] for s in range(n)]


def pairwise_merge_words(agent: Agent) -> Optional[Dict[Pair, List[int]]]:
    n, m = len(agent), len(agent[0])
    key = lambda s, t: (s, t) if s <= t else (t, s)  # noqa: E731
    preds: Dict[Pair, List[Tuple[Pair, int]]] = {}
    for s in range(n):
        for t in range(s, n):
            for i in range(m):
                preds.setdefault(key(agent[s][i], agent[t][i]), []).append((key(s, t), i))
    best: Dict[Pair, List[int]] = {(s, s): [] for s in range(n)}
    queue: deque = deque(best.keys())
    while queue:
        cur = queue.popleft()
        for src, i in preds.get(cur, []):
            if src not in best:
                best[src] = [i] + best[cur]
                queue.append(src)
    if any(key(s, t) not in best for s in range(n) for t in range(s, n)):
        return None
    return best


def greedy_length(agent: Agent) -> int:
    merges = pairwise_merge_words(agent)
    assert merges is not None
    surviving: FrozenSet[int] = frozenset(range(len(agent)))
    total = 0
    while len(surviving) > 1:
        s, t = sorted(surviving)[:2]
        v = merges[(s, t)]
        total += len(v)
        for i in v:
            surviving = frozenset(agent[x][i] for x in surviving)
    return total


def minimal_length(agent: Agent) -> int:
    n, m = len(agent), len(agent[0])
    start: FrozenSet[int] = frozenset(range(n))
    seen = {start}
    queue: deque = deque([(start, 0)])
    while queue:
        subset, d = queue.popleft()
        for i in range(m):
            nxt = frozenset(agent[s][i] for s in subset)
            if len(nxt) == 1:
                return d + 1
            if nxt not in seen:
                seen.add(nxt)
                queue.append((nxt, d + 1))
    raise RuntimeError("no locking word")


def main() -> None:
    ns = list(range(2, 12))
    cubic = [(n - 1) * n * n for n in ns]
    quad = [(n - 1) ** 2 for n in ns]
    greedy = [greedy_length(cerny_agent(n)) for n in ns]
    exact = [minimal_length(cerny_agent(n)) for n in ns]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.plot(ns, cubic, "o-", color="#334488", label=r"proved bound $(n-1)n^2$")
    ax1.plot(ns, greedy, "s-", color="#118844", label="greedy construction")
    ax1.plot(ns, exact, "^-", color="#cc3311", label="exact minimum")
    ax1.plot(ns, quad, "k--", lw=1.2, label=r"conjectured extremum $(n-1)^2$")
    ax1.set_xlabel("number of internal states $n$")
    ax1.set_ylabel("phase-lock time (stimuli)")
    ax1.set_title("Phase-lock time on the extremal agent family")
    ax1.legend()
    ax1.grid(alpha=0.3)

    ratio = [c / e for c, e in zip(cubic, exact)]
    ax2.plot(ns, ratio, "o-", color="#884499")
    ax2.set_xlabel("number of internal states $n$")
    ax2.set_ylabel("proved bound / exact minimum")
    ax2.set_title("The slack in the cubic bound grows linearly in $n$")
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("lock_time.png", dpi=160)
    print("wrote lock_time.png")
    for n, e, q in zip(ns, exact, quad):
        print(f"  n = {n:>2}:  exact minimum {e:>3}   (n-1)^2 = {q:>3}   match: {e == q}")


if __name__ == "__main__":
    main()


"""Visualization: rank descent -- how distinguishability is destroyed over time.

The *rank* of a stimulus word is the number of internal states still distinguishable
after the two doppelganger agents have observed it.  Rank starts at |S|, never
increases, and phase-lock is exactly the moment it reaches 1.  This figure plots the
rank descent curve for random stimulus streams driving the extremal agents, together
with the descent along an optimal locking word.
"""

from __future__ import annotations

import random
from typing import FrozenSet, List

import matplotlib.pyplot as plt

Agent = List[List[int]]


def cerny_agent(n: int) -> Agent:
    """Stimulus 0 rotates the internal state; stimulus 1 collapses state 0 onto 1."""
    return [[(s + 1) % n, (1 if s == 0 else s)] for s in range(n)]


def rank_profile(agent: Agent, word: List[int]) -> List[int]:
    surviving: FrozenSet[int] = frozenset(range(len(agent)))
    profile = [len(surviving)]
    for i in word:
        surviving = frozenset(agent[s][i] for s in surviving)
        profile.append(len(surviving))
    return profile


def optimal_word(n: int) -> List[int]:
    """The known optimal locking word b a^{n-2} b a^{n-2} ... of length (n-1)^2."""
    word: List[int] = []
    for _ in range(n - 1):
        word.append(1)
        word.extend([0] * (n - 2))
    return word[: (n - 1) ** 2]


def main() -> None:
    rng = random.Random(2026)
    sizes = [4, 6, 8]
    fig, axes = plt.subplots(1, len(sizes), figsize=(15, 4.4), sharey=False)

    for ax, n in zip(axes, sizes):
        agent = cerny_agent(n)
        horizon = 3 * (n - 1) ** 2

        for _ in range(40):
            word = [rng.randrange(2) for _ in range(horizon)]
            prof = rank_profile(agent, word)
            ax.step(range(len(prof)), prof, where="post", color="#7799cc", alpha=0.28, lw=1)

        opt = optimal_word(n)
        prof = rank_profile(agent, opt)
        ax.step(range(len(prof)), prof, where="post", color="#cc3311", lw=2.6,
                label=f"optimal word, length $(n-1)^2={len(opt)}$")

        ax.axhline(1, color="black", ls=":", lw=1)
        ax.set_title(f"$n = {n}$ states")
        ax.set_xlabel("stimuli observed")
        ax.set_ylabel("rank (states still distinguishable)")
        ax.set_ylim(0.5, n + 0.5)
        ax.set_yticks(range(1, n + 1))
        ax.legend(loc="upper right", fontsize=8)
        ax.grid(alpha=0.25)

    fig.suptitle("Rank descent: blind driving (blue) versus an optimal locking word (red).\n"
                 "Rank never increases; phase-lock is the moment it reaches 1.",
                 fontsize=11)
    fig.tight_layout(rect=(0, 0, 1, 0.90))
    fig.savefig("rank_descent.png", dpi=160)
    print("wrote rank_descent.png")


if __name__ == "__main__":
    main()


"""
Doppelganger Phase-Lock: numerical demonstrations.
==================================================

Two spatially separated but structurally identical deterministic agents observe the
same environmental stimulus stream.  An agent is a transition rule

    delta : S x I -> S

on a finite internal state space S with stimulus alphabet I.  A finite stimulus word
w LOCKS the agent when driving *every* internal state through w lands on one and the
same state; the two separated copies are then in identical internal states, however
they were initialized.

This script demonstrates, with concrete numbers:

  1. Basic driving, rank descent, and locking.
  2. The Synchronization Theorem: pairwise mergeability implies a universal locking
     word, constructed greedily, with length <= (|S| - 1) * L.
  3. The unconditional cubic bound (|S| - 1) * |S|^2 versus the true minimum.
  4. Exact minimal lock times of the Cerny agents: (n - 1)^2 for n = 2..7.
  5. The reversibility obstruction: injective-per-stimulus agents never lock.
  6. Failure of the theorem on an infinite state space (countdown agent).
  7. No-signalling in the product system, and the necessity of identical stimuli.
  8. Geometric decay of the failure fraction under blind random driving.
  9. The contractive mechanism: exponential collapse of the doppelganger gap.
 10. Order rigidity: monotone agents lock as soon as bottom and top merge.

Self-contained: standard library only.
"""

from __future__ import annotations

import itertools
import random
from collections import deque
from typing import Dict, FrozenSet, Iterable, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# Core: agents and driving
# ---------------------------------------------------------------------------

# An agent on n states with alphabet {0,...,m-1} is a table:
#   table[s][i] = next state from s on stimulus i
Agent = List[List[int]]


def drive(agent: Agent, word: Sequence[int], s: int) -> int:
    """State reached from `s` after observing the stimulus word `word` (left to right)."""
    for i in word:
        s = agent[s][i]
    return s


def drive_set(agent: Agent, word: Sequence[int], states: Iterable[int]) -> FrozenSet[int]:
    """Image of a set of states under the word: the states still distinguishable."""
    return frozenset(drive(agent, word, s) for s in states)


def rank(agent: Agent, word: Sequence[int]) -> int:
    """Number of internal states still distinguishable after observing `word`."""
    return len(drive_set(agent, word, range(len(agent))))


def locks(agent: Agent, word: Sequence[int]) -> bool:
    """Does `word` phase-lock the two separated copies from every pair of initial states?"""
    return rank(agent, word) == 1


def num_stimuli(agent: Agent) -> int:
    return len(agent[0])


# ---------------------------------------------------------------------------
# Pairwise merging: backwards BFS in the pair system S x S
# ---------------------------------------------------------------------------


def pairwise_merge_words(agent: Agent) -> Optional[Dict[Tuple[int, int], List[int]]]:
    """Shortest merging word for every unordered pair, or None if some pair never merges.

    Backwards breadth-first search from the diagonal in the pair system
    (s,t) --i--> (delta(s,i), delta(t,i)).  Time O(|I| * |S|^2).
    """
    n = len(agent)
    m = num_stimuli(agent)

    def key(s: int, t: int) -> Tuple[int, int]:
        return (s, t) if s <= t else (t, s)

    # forward predecessor map for the pair system
    preds: Dict[Tuple[int, int], List[Tuple[Tuple[int, int], int]]] = {}
    for s in range(n):
        for t in range(s, n):
            for i in range(m):
                tgt = key(agent[s][i], agent[t][i])
                preds.setdefault(tgt, []).append((key(s, t), i))

    best: Dict[Tuple[int, int], List[int]] = {(s, s): [] for s in range(n)}
    queue: deque = deque(best.keys())
    while queue:
        cur = queue.popleft()
        for src, i in preds.get(cur, []):
            if src not in best:
                best[src] = [i] + best[cur]
                queue.append(src)

    for s in range(n):
        for t in range(s, n):
            if key(s, t) not in best:
                return None
    return best


def greedy_locking_word(agent: Agent) -> Optional[List[int]]:
    """Construct a locking word by greedy image collapse, or None if none exists.

    Implements the proof of the Synchronization Theorem: while the surviving image
    contains two distinct states, append a shortest word merging them.  Each round
    strictly shrinks the image, so at most |S| - 1 rounds occur.
    """
    merges = pairwise_merge_words(agent)
    if merges is None:
        return None
    image = set(range(len(agent)))
    word: List[int] = []
    while len(image) > 1:
        s, t = sorted(image)[:2]
        v = merges[(s, t)]
        word.extend(v)
        image = set(drive_set(agent, v, image))
    return word


def minimal_locking_word(agent: Agent, max_len: int = 40) -> Optional[List[int]]:
    """Exact shortest locking word by BFS over the subset space 2^S."""
    n = len(agent)
    m = num_stimuli(agent)
    start = frozenset(range(n))
    if len(start) == 1:
        return []
    seen = {start}
    queue: deque = deque([(start, [])])
    while queue:
        subset, word = queue.popleft()
        if len(word) >= max_len:
            continue
        for i in range(m):
            nxt = frozenset(agent[s][i] for s in subset)
            if len(nxt) == 1:
                return word + [i]
            if nxt not in seen:
                seen.add(nxt)
                queue.append((nxt, word + [i]))
    return None


# ---------------------------------------------------------------------------
# The standard agent family
# ---------------------------------------------------------------------------


def cerny_agent(n: int) -> Agent:
    """Cerny's extremal agent: stimulus 0 rotates, stimulus 1 collapses state 0 onto 1."""
    return [[(s + 1) % n, (1 if s == 0 else s)] for s in range(n)]


def parity_agent() -> Agent:
    """One bit of memory; the single stimulus flips it.  Reversible, hence never locks."""
    return [[1], [0]]


def copy_agent() -> Agent:
    """One bit of memory overwritten by the observed stimulus.  Locks in one step."""
    return [[0, 1], [0, 1]]


def monotone_agent(n: int) -> Agent:
    """Order-preserving agent on the chain 0 < 1 < ... < n-1.

    Stimulus 0 pushes every state up by one (saturating at the top);
    stimulus 1 pushes every state down by one (saturating at the bottom).
    Both maps are monotone, so order rigidity applies.
    """
    return [[min(s + 1, n - 1), max(s - 1, 0)] for s in range(n)]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_1_basics() -> None:
    banner("1.  Driving, rank descent, and locking (three-state Cerny agent)")
    agent = cerny_agent(3)
    names = {0: "a (rotate)", 1: "b (collapse 0 -> 1)"}
    print("Transition table  delta(s, i):")
    for s in range(3):
        print(f"   state {s}:  a -> {agent[s][0]},   b -> {agent[s][1]}")

    word = [1, 0, 0, 1]  # b a a b
    print(f"\nThe word  baab = {word}.  Rank descent (surviving distinguishable states):")
    for k in range(len(word) + 1):
        prefix = word[:k]
        img = sorted(drive_set(agent, prefix, range(3)))
        label = "".join("ab"[i] for i in prefix) or "(empty)"
        print(f"   after {label:<6}  image = {img}   rank = {len(img)}")
    print(f"\n  locks?  {locks(agent, word)}   -- rank has reached 1: phase-lock achieved.")

    print("\nTwo separated doppelgangers starting in states 0 and 2:")
    s, t = 0, 2
    for k, i in enumerate(word, start=1):
        s, t = agent[s][i], agent[t][i]
        print(f"   stimulus {k} ({'ab'[i]}):  agent 1 in {s},  agent 2 in {t}"
              f"{'   <-- IN PHASE' if s == t else ''}")


def demo_2_synchronization_theorem() -> None:
    banner("2.  Synchronization Theorem: pairwise mergeability => a universal lock")
    agent = cerny_agent(4)
    merges = pairwise_merge_words(agent)
    assert merges is not None
    print("Shortest merging word for each pair of internal states (4-state Cerny agent):")
    L = 0
    for (s, t), w in sorted(merges.items()):
        if s == t:
            continue
        txt = "".join("ab"[i] for i in w)
        L = max(L, len(w))
        print(f"   pair ({s},{t}):  {txt:<8} (length {len(w)})")
    print(f"\n  L = max pairwise merge length = {L}")
    greedy = greedy_locking_word(agent)
    assert greedy is not None
    n = len(agent)
    print(f"  greedy universal locking word: {''.join('ab'[i] for i in greedy)}"
          f" (length {len(greedy)})")
    print(f"  theorem's guarantee:  length <= (|S| - 1) * L = {(n - 1) * L}"
          f"   -- satisfied: {len(greedy) <= (n - 1) * L}")
    print(f"  it really locks:      {locks(agent, greedy)}")


def demo_3_bounds() -> None:
    banner("3.  Cubic bound vs. greedy construction vs. true minimum")
    print(f"{'n':>3} {'cubic bound':>13} {'greedy length':>15} {'true minimum':>14}"
          f" {'(n-1)^2':>9}")
    print("-" * 60)
    for n in range(2, 8):
        agent = cerny_agent(n)
        cubic = (n - 1) * n * n
        greedy = greedy_locking_word(agent)
        exact = minimal_locking_word(agent)
        assert greedy is not None and exact is not None
        print(f"{n:>3} {cubic:>13} {len(greedy):>15} {len(exact):>14} {(n - 1) ** 2:>9}")
    print("\n  The true minimum matches (n-1)^2 exactly -- the conjectured extremal value,")
    print("  and far below the proved cubic upper bound.")


def demo_4_cerny_optimal_words() -> None:
    banner("4.  Exact optimal locking words for the Cerny agents")
    for n in range(2, 8):
        agent = cerny_agent(n)
        w = minimal_locking_word(agent)
        assert w is not None
        txt = "".join("ab"[i] for i in w)
        print(f"   n = {n}:  minimal lock time {len(w):>2} = (n-1)^2 = {(n - 1) ** 2:>2}"
              f"   optimal word  {txt}")
        if n <= 4:
            # brute-force certificate: literally no shorter word over {a,b} locks
            m = num_stimuli(agent)
            shorter = any(
                locks(agent, cand)
                for k in range(len(w))
                for cand in itertools.product(range(m), repeat=k)
            )
            print(f"            brute force over all {sum(m ** k for k in range(len(w)))}"
                  f" shorter words: any of them lock?  {shorter}")


def demo_5_reversibility_obstruction() -> None:
    banner("5.  Reversibility obstruction: information-preserving agents never lock")

    def all_stimuli_injective(agent: Agent) -> bool:
        n = len(agent)
        return all(len({agent[s][i] for s in range(n)}) == n for i in range(num_stimuli(agent)))

    for name, agent in [("parity agent", parity_agent()), ("copy agent", copy_agent()),
                        ("3-state Cerny agent", cerny_agent(3))]:
        inj = all_stimuli_injective(agent)
        w = minimal_locking_word(agent)
        status = "NEVER locks" if w is None else f"locks in {len(w)} stimuli"
        print(f"   {name:<22} every stimulus injective? {str(inj):<6}  -> {status}")
    print("\n  The parity agent is reversible: two copies out of phase stay out of phase")
    print("  forever.  The copy agent forgets everything at once and locks immediately.")
    print("  Synchronization requires dissipation.")


def demo_6_infinite_state_space() -> None:
    banner("6.  Finiteness is indispensable: the countdown agent on N")
    print("  States 0,1,2,...  one stimulus, s -> max(s-1, 0).")
    print("  Every PAIR merges (watch long enough and both counters hit 0):")
    for s, t in [(3, 7), (0, 5), (12, 12)]:
        k = max(s, t)
        print(f"     pair ({s},{t}): after {k} stimuli both are at"
              f" {max(s - k, 0)} and {max(t - k, 0)}")
    print("\n  Yet NO single word locks everything: a word of length n fails on (n+1, 0).")
    for n in [0, 1, 5, 100]:
        print(f"     candidate word of length {n:>3}:  state {n + 1} -> {max(n + 1 - n, 0)},"
              f"   state 0 -> 0    distinct: {max(n + 1 - n, 0) != 0}")
    print("\n  Pairwise telepathy does not imply universal telepathy with unbounded memory.")


def demo_7_no_signalling() -> None:
    banner("7.  No signalling, and the necessity of identical stimuli")
    agent = cerny_agent(3)
    m = num_stimuli(agent)
    rng = random.Random(20260811)

    print("  (a) Agent 2's state is a function of ITS OWN stimuli and initial state alone.")
    own_stream = [rng.randrange(m) for _ in range(12)]
    t0 = 2
    outcomes = set()
    for _ in range(6):
        other_stream = [rng.randrange(m) for _ in range(12)]
        s0 = rng.randrange(3)
        # joint word: agent 1 sees other_stream, agent 2 sees own_stream
        s, t = s0, t0
        for i1, i2 in zip(other_stream, own_stream):
            s, t = agent[s][i1], agent[t][i2]
        outcomes.add(t)
    print(f"      varying agent 1's initial state and entire stimulus stream 6 times,")
    print(f"      agent 2 always ends in state(s): {sorted(outcomes)}  -- a single value.")
    print("      Nothing at agent 1 is detectable at agent 2: phase-lock is not a channel.")

    print("\n  (b) With DIFFERENT streams, copy agents that lock instantly never lock at all.")
    cop = copy_agent()
    s, t = 1, 0
    for k in range(1, 6):
        s, t = cop[s][1], cop[t][0]  # agent 1 always sees stimulus 1, agent 2 stimulus 0
        print(f"      after {k} differing stimuli:  agent 1 in {s}, agent 2 in {t}"
              f"   in phase: {s == t}")
    print("\n  (c) With the SAME stream they lock immediately:")
    s, t = 1, 0
    s, t = cop[s][1], cop[t][1]
    print(f"      after 1 shared stimulus:   agent 1 in {s}, agent 2 in {t}"
          f"   in phase: {s == t}")


def demo_8_genericity() -> None:
    banner("8.  Blind driving locks the doppelgangers: geometric decay of failure")
    agent = cerny_agent(3)
    u = minimal_locking_word(agent)
    assert u is not None
    L = len(u)
    alphabet = num_stimuli(agent)
    q = alphabet ** L
    print(f"  Locking block u = {''.join('ab'[i] for i in u)} of length L = {L};"
          f"  q = |I|^L = {q} possible blocks.")
    print(f"\n  Theory: failure fraction after m blocks <= (1 - 1/q)^m = "
          f"({1 - 1 / q:.4f})^m")
    print(f"\n{'m blocks':>9} {'stimuli':>8} {'theory bound':>14} {'measured':>10}")
    print("-" * 46)
    rng = random.Random(11)
    trials = 20000
    for m_blocks in [1, 2, 4, 8, 16]:
        bound = (1 - 1 / q) ** m_blocks
        fails = 0
        length = L * m_blocks
        for _ in range(trials):
            word = [rng.randrange(alphabet) for _ in range(length)]
            if not locks(agent, word):
                fails += 1
        print(f"{m_blocks:>9} {length:>8} {bound:>14.6f} {fails / trials:>10.6f}")
    print("\n  The measured failure rate falls below the bound and decays geometrically:")
    print("  under blind environmental driving, phase-lock happens almost surely.")


def demo_9_contraction() -> None:
    banner("9.  The contractive mechanism: exponential collapse of the gap")
    # A shift register of width r: the internal state is the record of the last r
    # stimuli.  delta(s, i) = ((s << 1) | i) mod 2^r.  Equip the state space with the
    # ultrametric d(s,t) = 2^{-L(s,t)} where L is the length of the longest common
    # suffix (d = 0 when s = t).  Every stimulus is then an exact 1/2-contraction:
    # after one shared observation the two registers agree in one more low bit.
    r = 4
    n = 2 ** r
    agent: Agent = [[((s << 1) | i) % n for i in (0, 1)] for s in range(n)]

    def common_suffix(s: int, t: int) -> int:
        j = 0
        while j < r and (s >> j) % 2 == (t >> j) % 2:
            j += 1
        return j

    def dist(s: int, t: int) -> float:
        return 0.0 if s == t else 2.0 ** (-common_suffix(s, t))

    print(f"  A width-{r} shift register: the internal state records the last {r} stimuli,")
    print(f"  delta(s, i) = ((s << 1) | i) mod {n}.  Distance d(s,t) = 2^(-L) with L the")
    print("  length of the longest common suffix.  This is the state space of a")
    print("  self-synchronizing code.")

    worst = max(
        dist(agent[s][i], agent[t][i]) / dist(s, t)
        for i in (0, 1)
        for s in range(n)
        for t in range(n)
        if s != t
    )
    eps = min(dist(s, t) for s in range(n) for t in range(n) if s != t)
    diam = max(dist(s, t) for s in range(n) for t in range(n))
    print(f"\n  worst per-stimulus distance ratio k = {worst:.4f}   (a genuine contraction)")
    print(f"  quantization: distinct states are >= eps = {eps} apart; diameter D = {diam}")

    k = worst
    rng = random.Random(7)
    print(f"\n{'stimuli':>8} {'agent 1':>9} {'agent 2':>9} {'gap d':>10} {'bound k^n d0':>14}")
    print("-" * 56)
    s, t = 0b0101, 0b1010
    d0 = dist(s, t)
    for step in range(r + 2):
        print(f"{step:>8} {s:>{9}b} {t:>{9}b} {dist(s, t):>10.5f} {k ** step * d0:>14.5f}")
        i = rng.randrange(2)
        s, t = agent[s][i], agent[t][i]
    print("\n  The gap collapses geometrically regardless of WHICH stimuli occur.  Because")
    print(f"  distinct states are separated by at least {eps}, exponential shrinking forces")
    print("  EXACT equality after finitely many steps: quantization upgrades approximate")
    print("  agreement to genuine phase-lock, uniformly in the stream.")
    theory_N = 0
    while k ** theory_N * diam >= eps:
        theory_N += 1
    print(f"  theoretical uniform bound N with k^N * D < eps:  N = {theory_N}")
    w = minimal_locking_word(agent)
    assert w is not None
    print(f"  measured minimal lock time: {len(w)} stimuli -- and indeed EVERY word of")
    print(f"  length {r} locks: {all(locks(agent, c) for c in itertools.product((0, 1), repeat=r))}")


def demo_10_order_rigidity() -> None:
    banner("10.  Order rigidity: monotone agents lock when bottom meets top")
    for n in [4, 6, 9]:
        agent = monotone_agent(n)
        bot, top = 0, n - 1
        # find shortest word merging just the two extremes
        merges = pairwise_merge_words(agent)
        assert merges is not None
        v = merges[(bot, top)]
        print(f"\n  Chain of {n} states, stimuli 'up' and 'down' (both monotone).")
        print(f"    shortest word merging bottom and top: length {len(v)}"
              f"  -> {''.join('ud'[i] for i in v)}")
        print(f"    does that same word lock ALL states?  {locks(agent, v)}")
        exact = minimal_locking_word(agent)
        assert exact is not None
        print(f"    true minimal lock time {len(exact)} <= |S|^2 = {n * n}"
              f"   (general cubic bound would allow {(n - 1) * n * n})")
    print("\n  Order squeezes every state between the images of the two extremes, so one")
    print("  merge does the work of |S| - 1 merges and the greedy loop collapses to a")
    print("  single step -- lock time drops from cubic to quadratic.")


def main() -> None:
    print(__doc__)
    demo_1_basics()
    demo_2_synchronization_theorem()
    demo_3_bounds()
    demo_4_cerny_optimal_words()
    demo_5_reversibility_obstruction()
    demo_6_infinite_state_space()
    demo_7_no_signalling()
    demo_8_genericity()
    demo_9_contraction()
    demo_10_order_rigidity()
    print()
    print("=" * 74)
    print("All demonstrations complete.")
    print("=" * 74)


if __name__ == "__main__":
    main()
