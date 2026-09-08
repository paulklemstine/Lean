# The Detector That Can Only Miss

## Why a coarse label can invent independence, but can never hide a dependence

Somewhere in a large system there is a table. It has one row per setting of
some dial — a routing rule, a feature flag, a cache policy, a treatment arm —
and one column per outcome. Someone reads that table and writes a sentence:
*"in this context, the dial does not affect the outcome."* And on the strength
of that sentence, the dial is removed, or ignored, or hard-coded, or shipped.

Everything hangs on whether the sentence is true. And here is the
uncomfortable part: almost nobody reads the true table. What they read is a
*labelled* table. The dial has 40,000 possible settings and a 16-bit
identifier; two settings share an identifier and get pooled into one row. The
logging pipeline truncates a string. A hash collides. An older schema had four
categories where the new one has nine, and the rebuild silently folded three
of them together. Every real measurement table is a *merged* table: some rows
that ought to be distinct have been added together.

So the honest question is not "is the table right?" but "**in which direction
can the table be wrong?**"

The result described here answers that question, and the answer is as good as
one could hope for: **the error has a fixed sign.** A merged table can report
independence where the truth is dependence. It can never report dependence
where the truth is independence. Merging is a detector that can only *miss*.
It cannot cry wolf.

---

## Measuring "does the dial matter?"

Fix three quantities: the dial $X$, the response $Y$, and the context $Z$ —
the circumstances under which the measurement was taken (the region, the hour,
the device class). The number everybody actually wants is the **conditional
mutual information**
$$I(X;Y \mid Z),$$
the amount of information, in bits, that the dial carries about the response
*once the context is already known*. If it is zero, the dial is irrelevant in
every context. If it is a full bit, the dial determines an entire binary
outcome that the context alone could not have predicted.

The reason to condition on $Z$ rather than ignore it is not fastidiousness; it
is that the conditional and unconditional readings are genuinely different
numbers, and neither one controls the other. Two tiny examples make this
vivid, and they will be useful again later.

**The parity population.** Let $X$ and $Y$ be independent fair coins and let
the context be their parity, $Z = X \oplus Y$. Look at $X$ and $Y$ alone and
you see nothing at all: $I(X;Y) = 0$ bits, two independent coins. Now fix the
context. If $Z = 0$ you know $X = Y$; if $Z = 1$ you know $X \neq Y$. In
either context the dial determines the response exactly:
$$I(X;Y) = 0 \text{ bits}, \qquad I(X;Y \mid Z) = 1 \text{ bit}.$$
A perfectly clean single-dial table reads "no effect" while the truth,
context by context, is "total effect."

**The copy population.** Now let $X = Y = Z$, a single fair coin observed
three times. The single-dial table screams dependence: $I(X;Y) = 1$ bit. But
once you know the context you already know both the dial and the response, and
there is nothing left to learn:
$$I(X;Y) = 1 \text{ bit}, \qquad I(X;Y \mid Z) = 0 \text{ bits}.$$

So the two readings are logically independent: neither bounds the other. Any
guarantee about conditional tables has to be proved conditionally. That is
what makes the main theorem worth proving rather than quoting.

---

## The one-sidedness theorem

A **label merge** is a function $f$ from the true dial alphabet to a coarser
one. Applying it produces the merged table you actually see: the weight of the
merged row $u$ is the sum of the weights of all true rows $x$ with $f(x) = u$.
The set of true rows collapsing to $u$ is called the **fiber** over $u$.

> **Theorem (Conditional Data-Processing Inequality).** For every label merge
> $f$ and every joint weight on dial $\times$ response $\times$ context,
> $$I(f(X); Y \mid Z) \;\le\; I(X; Y \mid Z),$$
> with equality whenever $f$ is injective.

Read that as an audit statement and it becomes:

> **Corollary (One-sided error).** A conditional *dependence* reported off a
> merged table is never a false positive: if the merged reading is positive,
> the true reading is positive. Conversely, if the true population really is
> conditionally independent, every merged reading of it is conditionally
> independent too.

Every collision artifact in every such table is a **false negative**. Not
sometimes. Always.

And the negative half of the guarantee is sharp — merging really can destroy
everything. Take the parity population above, whose true reading is one full
bit, and apply the most brutal merge imaginable: send every dial setting to a
single label. The merged table has one row. Its reading is exactly $0$ bits. A
reported conditional independence can therefore be a pure artifact of the
encoding, with no trace of the truth left in the table.

Why is the inequality true? The proof is a piece of bookkeeping that turns out
to be exact, and the bookkeeping is more interesting than the inequality.

---

## Where the missing bits went

Define, for a block $S$ of rows carrying weights $w$, the **fiber deficit**
$$D(S, w) \;=\; \sum_{x \in S} w(x)\,\log_2 \frac{\sum_{x' \in S} w(x')}{w(x)}
\;\ge\; 0,$$
the entropy destroyed by pooling the block into a single label. It is zero
exactly when at most one row of the block carries weight, and large when the
block spreads its weight evenly over many rows.

Now compare two ways of computing a fiber's deficit. You can pool the fiber
*after* summing over responses — that is the deficit of its row totals, one
number per context. Or you can pool it *within each response column* and add
up — the sliced deficits. Concavity of entropy says the sliced version is
always the smaller one. And the difference between the two is precisely the
information the merge destroyed:

> **Theorem (Exact accounting).** For every merge $f$,
> $$I(X;Y\mid Z) - I(f(X);Y\mid Z)
> = \sum_{\text{contexts } z}\ \sum_{\text{fibers } u}
> \Big[\underbrace{D\big(\text{fiber } u,\ \text{row totals in } z\big)}_{\text{pool then slice}}
> - \underbrace{\textstyle\sum_{\text{responses } y} D\big(\text{fiber } u,\ \text{column } y \text{ in } z\big)}_{\text{slice then pool}}\Big].$$

Each bracket is nonnegative, which *is* the data-processing inequality. But
the identity says much more than the inequality: every lost bit has a return
address. A discrepancy is not a diffuse fog over the table; it is attributable
to a specific pair (context, fiber). Turn the identity around and you get a
one-cell detection rule: a single context and a single fiber with a positive
bracket already forces the whole merged reading strictly below the truth.

---

## Exactly which collisions are invisible

Pushed to its conclusion, the accounting classifies the harmless collisions
completely.

> **Theorem (Classification of invisible collisions).** A merged conditional
> reading equals the true one **if and only if** every fiber of the merge is a
> *product block* in every context that gives it positive weight: each cell of
> the fiber equals its row total times its column total, divided by the
> fiber's total. Otherwise the merged reading is *strictly* below the truth.

Stripped of formalism, "product block" means: **the dial settings pooled
together have the same normalised response profile.** If two routing rules
that got merged really do produce the same distribution of outcomes in that
context, then pooling them loses nothing — they were conditionally
interchangeable to begin with, and no measurement could have separated them.
If their profiles differ anywhere, in any context, the merge is *guaranteed*
to under-report.

That is a satisfying dichotomy. There is no grey zone of merges that
accidentally cancel out. Either the collision is between settings that are
genuinely indistinguishable in that context — in which case the table is
exactly right — or it is between distinguishable settings, and the table
undercounts, provably.

---

## An error bar you can compute without the truth

A sign guarantee tells you which way you are wrong. It does not tell you by
how much. The natural worry is that the true reading might be one bit or ten
bits above what you measured, and you would have no way to know.

You do have a way to know, and it is cheap.

For each context, compare the entropy of the dial's row totals before the
merge with the entropy after. The difference — call it the **label entropy
destroyed** in that context — is a property of the encoding and the marginal
dial counts *only*. It never looks at how the dial and the response co-vary.
An auditor can compute it from the label scheme and a histogram.

> **Theorem (Observable error bar).**
> $$0 \;\le\; I(X;Y\mid Z) - I(f(X);Y\mid Z)
> \;\le\; \sum_{\text{contexts } z} \big[\text{label entropy destroyed in } z\big].$$

So every reported conditional value comes bracketed between two computable
numbers: the reading itself is a floor for the truth, and the reading plus the
label-entropy loss is a ceiling. And the ceiling is attained — on the parity
population with the total-collapse merge, the merge destroys exactly one bit
of label entropy and exactly one bit of conditional information. The bound
cannot be improved in general.

The bracket has an immediately practical corollary, and it is stronger than
the injective case everyone knows:

> **Corollary (Exactness without injectivity).** If a merge destroys no label
> entropy in any context — that is, if it never pools two dial settings that
> both actually occur in the same context — then the merged conditional
> reading is *exact*.

Your encoding is allowed to collide wildly, as long as the colliding settings
never show up together. A hash collision between two rules that live in
different regions costs you nothing at all.

---

## Bugs compose the right way

Real pipelines do not merge once. They merge, then re-key, then aggregate
again, and each stage was written by a different team in a different year. If
the sign guarantee held for a single merge but not for a chain of them, it
would be of limited comfort.

It survives chaining, for a slightly pleasing structural reason: **merges
compose**. Applying merge $g$ to the output of merge $f$ produces exactly the
table you would have got by applying the single merge $g \circ f$ to the truth.
Chaining is not a new operation; it is the same operation with a different
label map. So the theorem applies again unchanged, and the readings decrease
monotonically along the chain:
$$I\big(g(f(X)); Y \mid Z\big) \;\le\; I\big(f(X); Y \mid Z\big) \;\le\; I(X;Y\mid Z).$$
Errors accumulate, but they accumulate with a fixed sign. A second bug can
never undo a first one and push the reading back above the truth.

Two more structural facts round out the picture. First, reporting only *part*
of a compound dial — you split a knob into two coordinates and log only the
first — is itself a label merge, so a sub-dial reading is always a lower bound
for the full-dial reading. Second, no reading can exceed the dial entropy that
survives:
$$I(X;Y\mid Z) \;\le\; H(X \mid Z).$$
A table with two merged rows cannot report more than one bit, no matter how
strong the underlying effect. Coarse tables are not just biased downward; they
are *capped*.

---

## Auditing conditionals with ordinary tables

The slice-by-slice definition of conditional information is fine as a
definition and awkward as an audit procedure: it demands the full three-way
table, which is exactly the artifact you distrust. There is a reformulation
that removes the problem.

> **Theorem (Chain rule).**
> $$I(X;Y\mid Z) \;=\; I\big(X;(Y,Z)\big) \;-\; I(X;Z).$$

Both terms on the right are *ordinary* two-variable readings: the dial against
the pair (response, context), and the dial against the context alone. A
conditional column can therefore be recomputed by an independent path from two
unconditional tables, giving a genuine cross-check rather than a re-run of the
same code. On the parity population the arithmetic is transparent:
$I(X;(Y,Z)) = 1$, $I(X;Z) = 0$, difference $1$ — matching the direct
computation.

Read the identity the other way and it becomes a diagnostic: a large reading
in the pair channel is *either* real conditional dependence *or* coupling
between the dial and the context, and never neither. If the pair channel is
loud but the conditional column is quiet, your dial is entangled with your
context, which is usually a story about how the data was collected rather than
about the system being measured.

---

## The boundary of the guarantee

It would be tempting to state the moral as "coarsening always loses
information, so all artifacts are conservative." That is *false*, and knowing
where it fails is what makes the true statement usable.

The guarantee lives on the **dial** axis. Merge the *context* variable instead
— pool two regions, aggregate two hours into one — and the sign guarantee
evaporates. On the parity population, collapsing the context takes a genuine
one-bit reading down to zero. On the copy population, collapsing the context
takes a genuine zero *up* to one full bit, manufacturing a dependence out of
nothing. Context merges are two-sided: they can fabricate as easily as they
can destroy.

The asymmetry is visible in the accounting identity. A dial merge subtracts
sliced deficits from marginal deficits *inside a fixed slice*, and concavity
of entropy fixes the sign. A context merge instead *recombines* slices, and
nothing constrains which way the recombination goes. One axis is protected by
a convexity argument; the other simply is not.

So the honest summary is narrow and strong at once: **for the dial you
measure, in the contexts you condition on, a reported dependence is real, a
reported independence is a maybe, and the gap between what you saw and what is
true is bounded by a number you can compute from your label scheme alone.**

---

## Why this is the right shape for an engineering guarantee

There is a general lesson lurking here about what makes a measurement
guarantee useful.

A guarantee of the form "the error is small" is fragile: it depends on
modelling assumptions and it degrades silently when they fail. A guarantee of
the form "the error has a known sign" is robust: it survives arbitrary
coarsening, arbitrary chaining, and arbitrarily bad label schemes, because it
does not depend on how bad they are. The medical analogue is a test with no
false positives: it may be insensitive, and you may not know how insensitive,
but a positive result is *proof*, and you can act on it immediately.

That is exactly the status these tables now have. Every "the dial matters
here" entry is trustworthy on its face. Every "the dial doesn't matter here"
entry is a hypothesis, one that comes with a computable error bar and a
precise, checkable criterion — same normalised response profile within each
fiber, in each context — for whether it can be believed.

Knowing the direction of your ignorance is not the same as removing it. But it
is the difference between a table you must re-derive and a table you can read.
