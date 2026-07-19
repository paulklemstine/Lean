# Memory Editing: When Forgetting Is a Mathematical Operation

Memory is usually described as a container. Experiences arrive, the container fills, and forgetting is what happens when some contents leak away. That picture is intuitive, but it misses something important: memories are not simply stored. They are *combined*. A morning conversation changes the meaning of an afternoon event; a sequence of clicks becomes a browsing history; a stream of sensor readings is compressed into the internal state of a device. The order matters, and the way pieces join matters.

Algebra offers a sharper picture. It treats an experience history as a finite word assembled from an alphabet of elementary events. The alphabet might consist of sights and sounds, database actions, network packets, or symbols typed at a keyboard. The empty history is allowed, and two histories can be concatenated. Under concatenation, all finite histories form a **free monoid**: a system with an associative composition rule and a neutral element, the empty stream.

A compositional memory sends each stream to a representation in another monoid. If $M$ is the set of streams, $R$ is the representation space, and $m:M\to R$ is the memory map, compositionality means

$$
m(xy)=m(x)m(y), \qquad m(1_M)=1_R.
$$

In words, remembering two successive histories is the same as combining their separate memories, and remembering nothing produces the neutral memory. This simple law covers finite-state controllers, rolling summaries, feature accumulators, event filters, and many data-processing pipelines.

Once memory is expressed this way, forgetting stops being a vague failure. It becomes an exact mathematical operation.

## A finite mind must merge stories

Suppose the experience alphabet contains at least one symbol. Then there are infinitely many distinct streams: the empty stream, a one-symbol stream, a two-symbol stream, and so on. Now suppose the representation space $R$ has only finitely many states. No map from an infinite set into a finite set can remain one-to-one. Therefore there must be distinct streams $x\ne y$ with

$$
m(x)=m(y).
$$

This is the **Finite-Memory Loss Theorem**: every compositional memory with finitely many states identifies at least two different experience streams.

The theorem is elementary, but its message is broad. Loss is not necessarily caused by a bad encoding or a careless designer. If arbitrarily long histories must fit into finitely many states, collision is unavoidable. A thermostat, an embedded controller, or a bounded user model must eventually treat different pasts as equivalent.

The theorem does not say which histories collide, how soon they collide, or whether the lost distinctions matter for a task. Those are design questions. It says something prior to design: finite capacity makes perfect recall impossible.

## Indistinguishability has structure

Call two streams **observationally indistinguishable** when they receive the same memory:

$$
x\sim_m y \quad\text{if and only if}\quad m(x)=m(y).
$$

This is more than an arbitrary clustering. It respects concatenation. If $x\sim_m y$ and $u\sim_m v$, then

$$
m(xu)=m(x)m(u)=m(y)m(v)=m(yv),
$$

so $xu\sim_m yv$. Equivalent pasts remain equivalent when placed in equivalent contexts. Algebraists call such an equivalence relation a **congruence**.

This matters in practice. A random grouping of histories may break as soon as new events are appended. A congruence is stable under composition, so it supports reliable downstream reasoning. If a system has forgotten the difference between two histories, no continuation processed through the same compositional rule can retroactively recover that distinction from the current memory state alone.

The finite-memory theorem now takes a stronger form: finite compositional memory necessarily creates a nontrivial congruence class, meaning that at least one equivalence class contains two genuinely different streams.

## The language of total erasure

Some streams are not merely confused with other nonempty streams; they disappear all the way to the neutral representation. Define the **erased language**

$$
E_m=\{x\in M:m(x)=1_R\}.
$$

The empty stream belongs to $E_m$, because $m(1_M)=1_R$. Moreover, if $x,y\in E_m$, then

$$
m(xy)=m(x)m(y)=1_R1_R=1_R,
$$

so $xy\in E_m$. Thus the completely erased streams form a **submonoid**: they contain the empty stream and are closed under concatenation.

This closure law gives information loss a grammar. If two episodes are each invisible to memory, their concatenation is invisible too. In a logging system, a class of ignored housekeeping events stays ignored when batched. In a privacy filter, sequences made solely from fully suppressed events remain suppressed. In a cognitive metaphor, combining two episodes that leave no trace still leaves no trace—provided the memory mechanism is compositional in the stated sense.

Notice the distinction between erasure and indistinguishability. The erased language records streams equivalent to the empty stream. The full congruence records every pair of streams that memory cannot distinguish. Erasure is one distinguished equivalence class; forgetting as a whole is the entire partition.

## Quotients: the world after distinctions are removed

Imagine taking all streams and declaring indistinguishable ones to be the same object. The resulting collection of equivalence classes is the **quotient memory algebra**, written $M/{\sim_m}$. Its elements are not individual histories but observable histories: each element gathers every stream that produces one memory state.

The **Observable Quotient Theorem** says that this quotient is structurally identical to the part of $R$ actually reached by the memory map:

$$
M/{\sim_m}\cong \operatorname{im}(m).
$$

This is the conceptual heart of the theory. The observable memory is not merely *like* a compressed version of experience. It is exactly the stream algebra after all invisible distinctions have been identified. Every reachable representation corresponds to one indistinguishability class, and composition agrees on both sides.

The theorem also avoids a common mistake. The codomain $R$ may contain states that no experience stream ever produces. Those states are irrelevant to actual memory behavior. The correct observable algebra is the image $\operatorname{im}(m)$, not necessarily all of $R$.

Combining the previous results yields a single picture. For any inhabited experience alphabet and any finite compositional representation, distinct streams collide; the streams erased to neutrality form a submonoid; and the reachable memory states are precisely the quotient of streams by observational indistinguishability.

## Targeted forgetting as deletion

General memory maps can compress in complicated ways. A particularly transparent policy decides, symbol by symbol, what to retain. Let

$$
r:\alpha\to\{\text{retain},\text{erase}\}
$$

be a policy on the alphabet $\alpha$. Define $T_r$ on streams by keeping each retained symbol, deleting each rejected symbol, and preserving the order of what remains. For example, if $r$ keeps $a$ and $c$ but rejects $b$, then

$$
T_r(abcbac)=acac.
$$

Deletion commutes with concatenation, so $T_r$ is itself a compositional memory map. Every rejected single symbol is completely erased:

$$
r(a)=\text{erase}\quad\Longrightarrow\quad T_r(a)=1.
$$

By closure of the erased language, any stream made entirely of rejected symbols is also erased. Mixed streams collapse to their retained subsequences.

The quotient theorem now says that histories are grouped according to the output visible after deletion. But targeted forgetting has an even more powerful property: it is universal among all compositional maps that honor the same identifications.

## The universal property of a forgetting policy

Suppose $g:M\to S$ is another compositional map. Assume that whenever targeted forgetting identifies two streams, $g$ also identifies them:

$$
T_r(x)=T_r(y)\quad\Longrightarrow\quad g(x)=g(y).
$$

Then the **Universal Targeted-Forgetting Theorem** states that there exists a unique compositional map

$$
\bar g:M/{\sim_{T_r}}\to S
$$

such that

$$
g=\bar g\circ q,
$$

where $q$ sends each stream to its equivalence class.

In plain language, any process that ignores at least the distinctions removed by the policy can operate directly on the edited memory, with no need to revisit the original stream. The factor map $\bar g$ is forced: on an equivalence class $[x]$, it must return $g(x)$. The assumption guarantees that this value does not depend on which representative $x$ is chosen. Existence follows from that well-defined rule, and uniqueness follows because every quotient class comes from some stream.

This universal property turns a deletion filter into an interface contract. Downstream analytics, controllers, or privacy-preserving computations can be moved after the forgetting step exactly when they are insensitive to everything the policy deletes.

## Why the quotient viewpoint matters

Consider privacy engineering. A raw event stream may contain both operational events and personal identifiers. A targeted policy removes the identifiers. The quotient is then the mathematical space of histories visible under that policy. A downstream statistic factors through the quotient precisely when changing only deleted information cannot change the statistic. This is a clean criterion for compatibility between a privacy policy and an analysis.

In databases, event sourcing, and distributed systems, finite summaries are unavoidable. The collision theorem warns that a bounded state cannot serve as a perfect audit trail. The congruence records exactly which histories have become observationally interchangeable. The submonoid of total erasure identifies sequences that can be inserted without affecting state. Such sequences may represent no-ops, ignored traffic, or intentionally redacted events.

In cognitive science, the framework is deliberately idealized: human memory is neither deterministic nor perfectly compositional. Yet the algebra separates three ideas often blurred together—capacity limits, complete erasure, and equivalence under observation. It suggests precise questions for richer models: How large are collision classes? Which continuations preserve or reveal distinctions? How should approximate rather than exact equality be measured?

In machine learning, a recurrent model compresses a growing sequence into a fixed-size state. Real-valued states are not finite in the mathematical sense, but digital implementations have bounded precision, and practical representations often identify many inputs. The quotient language asks what distinctions survive in the state and whether a downstream task depends only on those distinctions.

## Forgetting as design, not defect

The most useful conclusion is not that all memory fails. It is that every memory defines a world of observables. Finite memory must merge some stories. Compositionality ensures that these mergers fit together coherently. Completely invisible stories form a compositional family. And the surviving memory algebra is exactly the quotient obtained by removing distinctions the memory cannot see.

Targeted forgetting makes the principle constructive. Choose the symbols to suppress; delete them; and obtain a quotient through which every compatible downstream computation factors uniquely. Forgetting is then not an accidental hole in a record. It is a controlled transformation of the space of possible histories.

A memory does not merely store less than experience. It redraws the boundaries of sameness. Algebra tells us where those boundaries come from, how they behave when experiences concatenate, and when another computation can safely live on the edited side. In that sense, forgetting is not the absence of a mathematical operation. Forgetting *is* the operation.