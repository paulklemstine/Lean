# When Blurry Vision Beats Sharp Eyes: The Hidden Speed Limit of Repetition

## A puzzle in three disguises

Imagine three people staring at the same machine.

The first is a *physicist* watching a deterministic system evolve: a chemical mixture, a population of cells, a planet sweeping along its orbit. She does not see the full microscopic state — only a coarse readout, a dial, a color, a temperature band. She wants to know: *how long until the dial repeats itself?*

The second is a *cryptographer* feeding inputs into a one-way function, hoping to provoke a **collision** — two different inputs that the world cannot tell apart. Collisions are the cracks through which attacks slip. He wants to know: *how many tries before a collision is guaranteed?*

The third is an *engineer* compressing a stream of sensor data. The raw signal is enormous, but she only logs a summary — a category, a bucket, a label. She wants to know: *how many genuinely distinct summaries can the stream ever produce?*

These three people think they are working on three different problems. They are not. They are all asking the same question, and there is a single, clean, provable answer. This article is about that answer — a small theorem with a surprisingly long reach. It says, in one sentence:

> **If you watch a deterministic process through a coarse lens with $k$ possible readings, it must show you a repeat within $k$ steps — no matter how complicated the process underneath.**

That is the whole idea. The rest is understanding *why it is true*, *why it cannot be improved*, and *why blurriness — usually a defect — turns out to be a guarantee.*

---

## The setup: states, maps, and the lens

Let us fix the vocabulary, because precision is what lets a single statement serve three masters.

We have a finite collection of **states**, which mathematicians write as a finite set $\alpha$. Think of $\alpha$ as *everything that could be true about the machine at one instant* — every microscopic configuration.

The machine is **deterministic**: from each state there is exactly one next state. That rule is a function
$$f : \alpha \to \alpha,$$
and running the machine for $n$ steps from a starting state $x$ means applying $f$ over and over. We write this $n$-fold application as $f^{[n]}(x)$, so that $f^{[0]}(x) = x$, $f^{[1]}(x) = f(x)$, $f^{[2]}(x) = f(f(x))$, and so on. The sequence
$$x,\; f(x),\; f^{[2]}(x),\; f^{[3]}(x),\; \dots$$
is the **trajectory** — the machine's life story.

Now comes the lens. We do not observe states directly. Instead we group states into **classes** — bundles of states we cannot tell apart. Two states $a$ and $b$ might be *microscopically different* yet *observationally identical*: same temperature band, same hash output, same logged category. This "indistinguishability" is an **equivalence relation**, written $\rho$, and it carves $\alpha$ into disjoint classes. The collection of classes is the **quotient**, written $\alpha/\rho$, and its size — the number of distinct readings the lens can ever produce — is the single most important number in the story:
$$k = |\alpha/\rho|.$$

When two states $a$ and $b$ land in the same class, we say they are **$\rho$-related** and write $a \sim b$. The lens cannot distinguish them.

There is a small but vital bookkeeping fact that makes the lens trustworthy. In the formal development this is the lemma named `quotient_eq_implies_rel`:

> **If two states have the same class label, then they are genuinely indistinguishable.** Formally, if the class of $a$ equals the class of $b$, then $a \sim b$.

This sounds like a tautology, and morally it is — but it is the bridge that lets us pass from "the dial reads the same" (an equality of labels) to "the underlying states are related" (a statement about the world). Every collision we detect through the lens is a *real* indistinguishability, not an artifact of sloppy labeling.

---

## The heart of the matter: a pigeon, a hole, and an inevitable repeat

Here is the central theorem, the engine that drives everything. In the formal development it is called `exists_iterate_rel_of_card_quotient`, and stated plainly it reads:

> **Bounded-horizon collision.** For any deterministic map $f$ on a finite set $\alpha$ observed through a lens with $k = |\alpha/\rho|$ classes, and from *any* starting point $x$, there exist two times $m$ and $n$ with
> $$0 \le m < n \le k$$
> such that $f^{[m]}(x) \sim f^{[n]}(x)$.

In words: watch the machine for at most $k$ steps, and you are *guaranteed* to see the lens repeat a reading. Not "usually." Not "on average." Always.

Why is this true? The proof is one of the oldest and most beautiful arguments in mathematics: the **pigeonhole principle**. If you have more pigeons than holes, some hole holds two pigeons.

Look at the first $k+1$ snapshots of the trajectory as seen through the lens:
$$\overline{f^{[0]}(x)},\; \overline{f^{[1]}(x)},\; \dots,\; \overline{f^{[k]}(x)},$$
where the bar means "the class of." That is $k+1$ readings. But the lens has only $k$ distinct readings to give. So two of those $k+1$ snapshots — say at times $m$ and $n$ with $m < n$ — must produce the *same* class. By the bridge lemma above, the underlying states are then $\rho$-related: $f^{[m]}(x) \sim f^{[n]}(x)$. And since both indices live among $\{0, 1, \dots, k\}$, the later one satisfies $n \le k$. Done.

In the formal development this counting step is isolated as `exists_lt_lt_iterate_quotient_eq` — "$k+1$ pigeons into $k$ holes forces a repeated class" — and the main theorem simply feeds that repeated class through the bridge lemma to convert "same label" into "genuinely related."

What makes this argument so powerful is what it *does not* require. It does not care whether $f$ is reversible, smooth, random-looking, or cryptographically hardened. It does not care how astronomically large the hidden state set $\alpha$ is. The only quantity that controls the waiting time is $k$, the resolution of the lens. **Coarse lens, fast guaranteed repeat. Fine lens, slow guaranteed repeat.** The microscopic machinery is irrelevant.

---

## Why blurriness is a feature, not a bug

We are trained to think of blur as loss. A blurry photo is a worse photo. But here blur is exactly what *creates* the guarantee.

Suppose the lens were perfect — every state its own class, so $k = |\alpha|$. Then the bound says a repeat is guaranteed within $|\alpha|$ steps, which for a deterministic map is true but enormous and nearly useless when $\alpha$ is huge. Now squint. Coarsen the lens so that $k$ is tiny. Suddenly the guarantee is *strong*: a repeat within a handful of steps. The blurrier you look, the sooner you are promised to see the same thing twice.

This inverts the usual intuition and is the conceptual payload of the theorem. **Resolution is a budget you spend on patience.** If you can tolerate a coarse view, the universe rewards you with a fast, certain recurrence.

---

## The three disguises, unmasked

Now we can return to our three observers and watch the single theorem dissolve all three of their problems.

### The engineer: state compression with a ceiling

The engineer logs class labels, not raw states. A natural question: *across an entire run, how many genuinely distinct labels can she ever record?* Define the **observable orbit count** as the number of distinct classes the trajectory visits in its first $N+1$ steps. In the formal development the trajectory-of-labels is the function `quotientObservableTrace`, the set of labels it hits is `observableOrbitSet`, and its size is `observableOrbitCount`.

The theorem `eml_observable_orbit_bound` then says the obvious-once-stated but practically decisive fact:

> **The observable orbit count never exceeds $k$.** No matter how long you run the machine, the number of distinct readings is at most the number of available readings.

For the engineer this is a hard ceiling on log complexity. Her summary stream, however long, lives in a space of size at most $k$. She can size her buffers, her dictionaries, her dedup tables to exactly $k$ and never overflow. The **observable diameter** (`quotientObservableDiameter`), defined as one less than the observable orbit count, measures how "spread out" a single run is, and it too is capped by $k - 1$. Compression has a provable budget.

### The cryptographer: a collision certificate

The cryptographer wants two distinguishable-by-no-one inputs. Read the central theorem again with his vocabulary: $f$ is his iterated function, the lens $\rho$ is "produces the same observable digest," and a $\rho$-related pair $f^{[m]}(x) \sim f^{[n]}(x)$ *is* a collision. The theorem hands him a **collision certificate**: he is guaranteed a collision within $k$ iterations, and he knows exactly where to look.

This is the rigorous skeleton beneath the famous **birthday bound** and **Pollard's rho** family of attacks, where one searches for collisions by iterating a function and waiting for the trajectory to fold back on itself. The theorem says the fold *must* happen, and on a schedule governed by the size of the observable space. For a defender, this is a warning: *the size of your observable digest space is a hard speed limit on collision resistance.* You cannot hide behind a gigantic internal state if the world only sees $k$ outputs — a repeat is coming within $k$ steps. In the formal development this crypto-facing reading is recorded as a collision-certificate statement and, at higher resolution, as a `post_quantum_security_collision_upper_bound`.

### The physicist: recurrence under coarse observation

The physicist's deterministic system, observed through her finite dial, *must* return to a previously-seen reading within $k$ steps. This is a finite, constructive, worst-case cousin of the great recurrence theorems of dynamics — but stripped of probability and measure, reduced to pure counting. She does not need ergodicity or invariant measures; she needs only to count the dial's settings. The theorem `certified_robustness_via_quotient_compression` packages this as a universal guarantee: *every* coarse-grained deterministic observable is recurrent on a horizon of $k$, with a certificate she can check.

---

## How much can you compress? Two honest ratios

It is one thing to know a ceiling exists; it is another to measure how much you have squeezed. The theory carries two clean bookkeeping quantities.

The **collision entropy** (`quotientCollisionEntropy`) is the number of microscopic distinctions the lens throws away:
$$|\alpha| - k.$$
It is the information you deliberately discard by squinting. It is always nonnegative — you can only lose distinctions by blurring, never gain them — a fact recorded as `quotientCollisionEntropy_nonneg`.

The **compression ratio** (`orbitCompressionRatio`) is the fraction of resolution you keep:
$$\frac{k}{|\alpha|}.$$
The theorem `orbitCompressionRatio_le_one` certifies the sanity check that this ratio never exceeds $1$: the quotient can never have more classes than there are states. A ratio near $0$ means aggressive compression (and a fast recurrence guarantee); a ratio of exactly $1$ means the perfect, useless, microscope-sharp lens. Between those extremes lies every real engineering trade-off.

---

## Why the bound cannot be beaten

A skeptic might ask: is $k$ really necessary, or just convenient? Could a cleverer argument give a smaller horizon?

No — and the reason is a clean construction. Imagine a machine whose lens has exactly $k$ classes arranged in a single long cycle, where each step advances the dial by one notch and only wraps around after $k$ steps: readings $0, 1, 2, \dots, k-1, 0, 1, \dots$. The first repeat happens precisely at step $k$, not a moment sooner. So the horizon $k$ in the central theorem is **tight**: there is a system that uses every last one of its $k$ steps before folding back. The theorem is not merely true; it is the *best possible* statement of its kind.

---

## The deeper lesson

Strip away the three disguises and a single principle remains, almost philosophical in its simplicity:

> **Determinism plus finiteness equals inevitable repetition — and the rate of that repetition is set not by the complexity of the world, but by the resolution of your gaze.**

The hidden machine may be unfathomably intricate. It does not matter. The instant you commit to viewing it through a lens with $k$ settings, you have signed a contract: within $k$ steps, you *will* see a reading you have seen before. The cryptographer reads this contract as a vulnerability, the engineer as a budget, the physicist as a recurrence law. All three are right.

There is a quiet elegance in that. We usually fight blur, chase ever-finer resolution, treat coarse observation as the enemy of understanding. This little theorem turns the picture upside down. Sometimes the surest way to *guarantee* you will find what you are looking for — a collision, a recurrence, a bounded log — is to stop looking so closely. Blurry vision, it turns out, comes with a promise that sharp eyes can never make: *you will see it again, and soon.*
