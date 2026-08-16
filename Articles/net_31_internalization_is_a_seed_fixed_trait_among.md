# The Crutch and the Cure: Why Some Learners Never Let Go of the Signpost

There is an old teaching worry, familiar to anyone who has watched a student
work through a long calculation: has the student *learned* the method, or have
they learned to lean on the scaffolding? Take away the worked example pinned to
the wall, and you find out. Sometimes nothing changes. Sometimes everything
falls apart.

This article is about a mathematical model of exactly that moment — the moment
the signpost is removed — and about a small, sharp surprise that falls out of
it. The surprise is this: whether a learner leans on the signpost is *not* a
property of how much scaffolding it was given. It is a property of the learner.
Give it a wider signpost, a richer one, a more redundant one, and the learner
will succeed more often — but the ones that lean will still lean, at every
width, and they will lean *harder*.

Everything below is stated and proved as mathematics. The setting is a *gated
readout* with a *boundary block*: a piece of arithmetic small enough to write on
a napkin, and rigid enough that a whole family of empirical observations turns
out to be forced.

---

## The setup: a threshold, and a block of dimensions

Picture a machine that has to produce an answer. To produce it, the machine
needs a certain total amount of "drive" — call the amount it needs its
**demand**, written $d$. Some of this drive the machine generates internally:
call that its **base**, written $b$. The rest has to come from outside, from a
special marker in its input — a boundary token, a signpost, a full stop at the
end of a sentence.

That signpost is not a single number. It occupies a **block** of $k$ coordinates
$w_1, \dots, w_k$, and what the machine reads off it is the aggregate

$$\mathrm{drive}(w) \;=\; \sum_{i=1}^{k} w_i .$$

The machine answers correctly exactly when the total drive it can muster reaches
its demand. Writing the residual threshold as $\mathrm{thr} = d - b$, the
machine **survives** a configuration $w$ of the block precisely when

$$\mathrm{thr} \;\le\; \sum_{i=1}^{k} w_i .$$

That is the whole model of the readout. Now for the interesting part: what
happens when we vandalise the block.

There are four natural vandalisms, and each is a one-line piece of arithmetic:

- **Kill everything** ($\mathrm{zeroN}$): set every $w_i$ to zero. The drive
  becomes $0$.
- **Kill one coordinate** ($\mathrm{zero1}$ at position $j$): the drive becomes
  $\mathrm{drive}(w) - w_j$.
- **Flip one coordinate's sign** ($\mathrm{flip1}$ at $j$): the drive becomes
  $\mathrm{drive}(w) - 2w_j$. A flip costs exactly *twice* what a deletion
  costs, because the coordinate does not merely vanish, it changes sides.
- **Shrink the whole block** by a factor $c$: the drive becomes
  $c \cdot \mathrm{drive}(w)$.

Two words for the two outcomes of the harshest test. If killing the whole block
breaks the machine, the machine is **boundary-dependent**: it never internalised
the signpost. If killing the whole block changes nothing, the machine is
**self-sufficient**: it has internalised the signpost, and the signpost is now
decoration.

The first observation is embarrassingly simple, and it is the hinge of
everything: since $\mathrm{zeroN}$ drives the aggregate to $0$, the machine is
boundary-dependent if and only if $\mathrm{thr} > 0$, i.e. if and only if
$b < d$: **its base is smaller than its demand.** No mention of $k$ anywhere.
Hold that thought.

---

## The uniform block, and why sign flips are a $k = 2$ story

Suppose the $k$ coordinates all carry the same size $a > 0$ — the idealisation
of "$k$ equally weighted exclusive dimensions". Then the intact block delivers
$ka$; deleting one coordinate leaves $(k-1)a$; flipping one leaves $(k-2)a$.
Three exponents, $k$, $k-1$, $k-2$, and almost every phenomenon in this story is
the gap between them.

**Collective use.** If the threshold is met with one dimension to spare — that
is, if $\mathrm{thr} \le (k-1)a$ — then deleting *any single* coordinate is a
no-op, even for a machine that whole-block deletion destroys. A block of
$k \ge 2$ dimensions is not read coordinate by coordinate; it is read as a sum. Poke
one hole in it and nothing happens; remove it entirely and the answer path may
die. That combination — *single deletion free, total deletion fatal* — is
precisely what "used collectively" means, and here it is a theorem, not a
metaphor.

**Sign sensitivity is a width-two accident.** Look at the flip law. The machine
survives a flip exactly when $\mathrm{thr} \le (k-2)a$. At $k = 2$ the
right-hand side is *identically zero*, so surviving a flip is literally the same
condition as surviving whole-block deletion, namely $\mathrm{thr} \le 0$. In
other words:

> **At width two, sign sensitivity is an exact test for dependence.** A
> width-two machine is broken by a single sign flip if and only if it is
> boundary-dependent — no false positives, no false negatives.

But at $k = 3$ the flip threshold is $a > 0$, and any machine whose residual
demand is at most one coordinate's worth, $\mathrm{thr} \le a$, sails through
every flip — *even if it is boundary-dependent*. So flip-freedom at width three
carries no information at all about internalisation. One can exhibit a single
family that does both at once: a dependent machine at width two that no flip
survives, and a dependent machine at width three that every flip survives.

A dramatic-sounding empirical fact — "sign flips cost 7–25% at width two and
exactly nothing at width three" — thus dissolves into the observation that the
polynomial $k - 2$ has a root at $2$.

**A staircase of severity.** The four vandalisms are totally ordered. On a
uniform block with $a \ge 0$ and $k \ge 2$: surviving whole-block deletion
implies surviving a flip, which implies surviving a single deletion, which
implies surviving the intact control. So the empirical patterns can only ever be
a staircase; you will never see a flip hit without also seeing a whole-block
hit. The model forbids it.

---

## The headline: internalisation is a trait of the learner, not of the width

Now let the machine be trained. A **seed** — one training run, one learner — is
summarised by four width-independent numbers: its base $b$, the drive $g \ge 0$
that each boundary dimension contributes, its demand $d$, and an integer $s$,
its **separation requirement**: the number of exclusive dimensions it needs
before it can tell the boundary apart from everything else at all.

Trained at width $k$, the seed becomes the readout with threshold $d - b$
reading a uniform block of $k$ coordinates of size $g$. It **cures** — learns
the task — at width $k$ when two independent things happen:

$$s \le k \qquad\text{(it can resolve the boundary)} \qquad\text{and}\qquad d \le b + kg \qquad\text{(it has enough drive)}.$$

Two conditions, two quite different characters: a *resolution* condition and a
*capacity* condition. Both are monotone in $k$, so **curing is monotone in the
width**: a seed that cures at some width cures at every larger width. Width sets
the probability of a cure.

And now the punchline. Boundary dependence of this trained readout says
$d - b > 0$, i.e. $b < d$ — a statement in which $k$ does not appear. Therefore:

> **Internalisation is width-invariant.** For any seed and any two widths $k$
> and $m$, the seed is boundary-dependent at width $k$ if and only if it is
> boundary-dependent at width $m$.

For a whole family of seeds, the set of dependent ones is *literally the same
set* at every width. Width decides who learns; the seed decides who leans. This
is why an experimental campaign that trains the same learners at two different
widths and finds the *same* four dependent learners at both is not observing a
coincidence — it is observing a rigidity.

**Leaning gets worse.** How badly does a dependent machine need its signpost?
Define its **retention** at width $k$ — how much of the required drive survives
whole-block deletion — as

$$\rho(k) \;=\; \frac{b}{b + kg}.$$

If $g = 0$ (a seed that takes nothing from the boundary at all), retention is
$1$ at every width: perfect internalisation, flat in $k$. But if $b > 0$ and
$g > 0$, then $\rho$ is *strictly decreasing* in $k$, always below $1$, and
tends to $0$. Widen the signpost and the dependent learner does not wean itself
— it leans harder, until asymptotically its answer is *all* signpost. This is
the exact shape of the observed pattern in which the same learners lose 3%, then
9%, then 10% as the width grows.

But the decay has a speed limit. Since $k\rho(k) \to b/g$, retention decays
*harmonically*, like $b/(gk)$ — and the series $\sum_k \rho(k)$ therefore
diverges. Any mechanism that would make retention collapse geometrically is
incompatible with the model. Dependence deepens, but slowly.

---

## Why you cannot predict who will lean

Here is the observation that makes the model earn its second parameter. In the
experiments, the width-one behaviour of a learner — whether it fails, half
learns, or learns the task with a single boundary dimension — tells you
*nothing* about whether it will lean on the boundary at the widths where it does
succeed. Failures at width one turn up on both sides of the ledger.

That is not a lament about noisy data; in this model it is a theorem. Because
curing needs *both* resolution ($s \le k$) and capacity ($d \le b + kg$), the
width-one outcome and the internalisation trait are logically independent: all
four combinations occur. Explicitly, one can write down two learners that are
indistinguishable at width one — both fail — both of which cure at width two,
and one of which is boundary-dependent at *every* width while the other is
self-sufficient at *every* width. Take $b = 1, g = 1, d = 3, s = 1$ for the
first: it fails at width one for lack of drive ($1 + 1 < 3$), cures at width two
($1 + 2 \ge 3$), and has $b < d$ forever. Take $b = 2, g = 1, d = 1, s = 2$ for
the second: it fails at width one for lack of *resolution*, cures at width two,
and has $d \le b$ forever. Same width-one report, opposite traits, permanently.

Delete the resolution parameter and this pair evaporates: in a capacity-only
model, self-sufficiency ($d \le b$) would force curing at width one. So the data
*force* the second parameter. The absence of a predictor is evidence about
structure.

---

## The other half of the story: why a block can carry an answer at all

The gate model explains the sign-flip marker and the seed-fixed trait, but it
does not explain why a block of $k$ dimensions can carry information, nor why
the word *exclusive* matters. For that we need arithmetic, and the arithmetic is
the Chinese Remainder Theorem.

Model each exclusive dimension by a **modulus** $m_i \ge 2$, with the moduli
pairwise coprime — that is what exclusivity buys: the dimensions overlap in no
information. Say the surviving dimensions $S$ **resolve** the answer range
$[0, A)$ if the residues $x \bmod m_i$, for $i \in S$, determine $x$ uniquely
within that range: whenever $0 \le x, y < A$ and every surviving modulus divides
$x - y$, then $x = y$.

Then:

- **Capacity (the Chinese Remainder Theorem, read as an ablation statement).**
  A pairwise coprime block resolves every range below its capacity
  $\prod_{i \in S} m_i$. The proof is one line: the product divides $x - y$, and
  $|x - y| < A \le \prod m_i$, so $x = y$.
- **Width is capacity.** Since each modulus is at least $2$, a block of $k$
  dimensions has capacity at least $2^k$; deleting one dimension leaves at least
  $2^{k-1}$.
- **Single deletion is a no-op — again.** Consequently, if the answer range fits
  inside the *single-drop margin* $A \le 2^{k-1}$, then removing any one
  dimension still resolves.
- **Total deletion is fatal.** With no dimensions left, the empty block resolves
  a range if and only if that range has at most one element: $A \le 1$.

Put these together for $k \ge 2$ and a genuine answer range
$2 \le A \le 2^{k-1}$, and you get the mechanism claim in a single statement: the intact
block resolves; *every* single-dimension deletion is a no-op; and whole-block
deletion is fatal. Collective use, now for a completely different reason —
arithmetic redundancy rather than an additive threshold.

Is this configuration a lucky choice of moduli? No. The **Fermat numbers**
$F_i = 2^{2^i} + 1$ — $3, 5, 17, 257, 65537, \dots$ — are pairwise coprime and
all exceed $2$, so $\{F_0, \dots, F_{k-1}\}$ is a legitimate $k$-dimensional
exclusive block for every $k$. The mechanism is realised at every width.

Two honest caveats complete the picture, and both matter for anyone who wants to
turn "at least three exclusive dimensions" into an engineering rule.

**The redundancy is relative to the answer range.** The moduli $(2, 3, 5)$
resolve the range $A = 30$ exactly — but delete the modulus $5$ and resolution
dies: $0$ and $6$ become indistinguishable modulo $2$ and $3$. Three exclusive
dimensions buy a free deletion only up to the margin $2^{k-1}$; run the block at
its capacity limit and the redundancy is gone. A design rule of the form "three
exclusive dimensions and you are safe" needs the margin clause, or per-instance
verification.

**Sign flips are always free at this layer.** Negating any subset of the moduli
changes nothing whatsoever, since divisibility is blind to sign. So the observed
sign sensitivity at width two *cannot* be a capacity effect. It has to live in
the additive gate — exactly where the $k-2$ law puts it. The two layers are not
rival explanations; they explain different observations, and each rules itself
out of the other's territory.

---

## What the model can, and cannot, recover

One last question an experimenter should ask: is the battery of vandalisms
*complete*? Does poking the machine in these ways pin down what is inside it?

At the level of the block, yes. The intact drive together with the $k$
single-coordinate deletion readings determines every coordinate exactly: if two
blocks agree on the control and on all $k$ deletions, they are equal. And the
flip readings are then redundant, being an exact affine function of the
deletions,

$$\mathrm{drive}(\mathrm{flip}_j w) \;=\; 2\,\mathrm{drive}(\mathrm{zero}_j w) - \mathrm{drive}(w),$$

which is why flip arms carry information only through the *gate* — through
whether a threshold is crossed — and never through the block itself.

At the level of the learner, one reading suffices for the whole profile: two
seeds with positive base that agree on retention at a single positive width
agree at *every* width. That is a hard, falsifiable prediction. Two learners
that match at one width and diverge at another would kill this model outright.

---

## The shape of the lesson

Strip away the machinery and three sentences remain.

*Width sets the probability of learning; the learner sets whether learning is
internalised.* The first is a monotone condition in $k$; the second is a
comparison $b < d$ in which $k$ does not appear.

*Redundancy is real but bounded.* Both layers — the additive gate with its
margin $(k-1)a$, and the arithmetic block with its margin $2^{k-1}$ — make
single-point damage free and total damage fatal, and both make that guarantee
only up to an explicit margin.

*Some diagnostics are accidents of the width you happen to be testing.* Sign
sensitivity is a perfect dependence test at width two and pure noise at width
three, for the same reason that $k-2$ vanishes at $k = 2$ — and for no deeper
reason at all.

The scaffolding metaphor holds to the end. You cannot tell from a student's
first stumbling attempt whether they will eventually own the method or merely
lean on the worked example forever. You have to take the example off the wall.
And if you make the example *bigger and clearer*, more students will pass — but
the ones who lean will lean all the harder.
