# The Hidden Physics of Learning: Why Training a Neural Network Is Like Zooming Out on the Universe

## A tale of two telescopes

Imagine you are a physicist staring at a cup of coffee. Up close, you see a roiling
chaos of molecules, each one jittering billions of times a second. But step back,
and that frenzy melts away. What survives is calm: a smooth temperature, a slow
swirl, a single number that tells you how hot your drink is. The microscopic storm
does not vanish — you simply stop caring about it. The fast, frantic details
average out, and only the slow, large-scale behavior remains.

Physicists have a name for this act of zooming out: the **renormalization group**,
or RG. It is one of the deepest ideas of the twentieth century, and it earned
Kenneth Wilson the 1982 Nobel Prize. The renormalization group is the mathematics
of *coarse-graining* — of repeatedly throwing away fine detail and asking what is
left. Each time you "zoom out," some degrees of freedom get **integrated out**:
the fast wiggles, the high-frequency noise, the irrelevant. What persists across
scales is what physicists call **relevant** — the few quantities that actually
govern the world you observe.

Now picture something that seems to have nothing to do with coffee: a neural
network learning to recognize cats. It starts as a tangle of millions of random
numbers. You feed it examples, nudge the numbers a little, feed it more examples,
nudge again. Thousands of tiny corrections later, it works. We call this *training*,
and to most people it looks like brute-force trial and error.

This article is about a startling claim, now made fully precise and machine-checked:
**training a neural network is itself a renormalization-group flow.** Every step of
learning is an act of zooming out. The network is quietly integrating out its own
high-frequency modes, exactly as a physicist integrates out the jitter of
molecules — and the mathematics is, line for line, the same.

## The shape of learning

To see why, we need one ingredient from the theory of neural networks: the
**Neural Tangent Kernel**, or NTK.

When a very wide network trains, something beautiful happens. Although the network
is wildly nonlinear, in this regime its learning dynamics become *linear* and
predictable. The whole behavior is controlled by a single matrix, the NTK Gram
matrix, written `Θ = JᵀJ`, where `J` collects the network's sensitivities (its
gradients) to each training example. This matrix is the network's fingerprint: it
encodes how strongly the model couples one data point to another.

The error the network still makes — the gap between its predictions and the truth —
is called the **residual**, written `r`. Each step of gradient descent updates the
residual by a simple rule:

> `r_{k+1} = (I − η Θ) r_k`,

where `η` is the learning rate. In words: take the current error, transform it by
the matrix `I − η Θ`, and that is your error after one more step of training.

This looks like an intimidating matrix equation. But matrices like `Θ` have a secret
skeleton: their **eigenvectors** and **eigenvalues**. Every symmetric matrix can be
rotated into a special coordinate system — its eigenbasis — in which it does nothing
but stretch each axis by a fixed amount. Those stretch factors are the eigenvalues,
which we will call `λ₁, λ₂, λ₃, …`. In this magic coordinate system the tangled
matrix recurrence falls apart into a set of completely independent one-dimensional
problems. Each one is called a **mode**.

And a single mode obeys the simplest equation in all of mathematics. If `vᵢ` is the
amount of error living in mode `i`, then after one training step it becomes

> `(1 − η λᵢ) · vᵢ`.

That number `1 − η λᵢ` is so important it deserves a name. We call it the **gain** of
mode `i`:

> **gain** `gᵢ = 1 − η λᵢ`.

Every training step simply multiplies each mode by its gain. That's it. The
inscrutable process of "learning" reduces, in the right coordinates, to a list of
numbers being multiplied by other numbers.

## The renormalization step

Here is where physics walks in the door. Define a single operation — call it the
**RG step** — that takes the error vector and rescales each mode `i` by its gain `gᵢ`:

> `rgStep(v)ᵢ = gᵢ · vᵢ = (1 − η λᵢ) · vᵢ`.

This is exactly one step of training, written in the eigenbasis. But it is *also*
exactly the structure of a renormalization-group transformation: a diagonal flow
that rescales each degree of freedom by a fixed factor. The gain `gᵢ` plays the role
that an "RG eigenvalue" plays in physics. The act of training and the act of
coarse-graining are the same act.

Once you have this picture, four facts follow — and each has been proved completely
and verified by machine, leaving no gap.

### Fact 1: The flow has a closed form

What happens if you train not once but `k` times? Each step multiplies a mode by its
gain, so after `k` steps you have multiplied by the gain `k` times:

> **After `k` steps, mode `i` equals `gᵢ^k · vᵢ`.**

Formally, iterating the RG step `k` times gives `(rgStep)^[k](v)ᵢ = (1 − η λᵢ)^k · vᵢ`.
This is the entire trajectory of training, written in one line. There is no mystery
left in *where* training goes: each mode marches along a geometric sequence,
shrinking (or growing) by a constant factor every step. This is the multi-mode
version of the classic NTK mode-decay law.

### Fact 2: The steps form a flow — a semigroup

In physics, coarse-graining has a consistency property: if you zoom out by a factor
of ten and then by another factor of ten, you have zoomed out by a factor of a
hundred. The order and grouping don't matter; what matters is the total amount of
zooming. Mathematicians call a family of operations with this property a
**one-parameter semigroup**.

Training has exactly this structure:

> **Coarse-graining to scale `k + m` equals first coarse-graining to scale `m`,
> then to scale `k`.**

In symbols, `(rgStep)^[k+m](v) = (rgStep)^[k]((rgStep)^[m](v))`. Training for `100`
steps is identical to training for `40` steps and then for `60` more. Obvious? Yes —
but its obviousness is the *point*. It certifies that the discrete steps of learning
genuinely assemble into a smooth, scale-by-scale flow, the defining feature of a
renormalization group.

### Fact 3: Fast modes get integrated out

Now for the heart of the matter — the precise meaning of "integrating out
high-frequency modes."

Consider two modes: a "fast" mode `i` with small gain (large eigenvalue) and a
"slow" mode `j` with larger gain (small eigenvalue). The fast mode shrinks more
quickly with every step. We can measure exactly how it fades relative to the slow
one by tracking the **ratio** of their amplitudes as training proceeds.

The result:

> **If `|gᵢ| < |gⱼ|` — if mode `i` contracts strictly faster than mode `j` — then
> the ratio of their amplitudes tends to zero.**

The fast mode does not merely shrink; it shrinks *into irrelevance compared to the
slow one*. After enough training, mode `i` is invisible next to mode `j`. This is
the renormalization group's signature move — the **separation of scales** — made
into a theorem. The high-frequency degrees of freedom are not deleted by hand; the
flow itself drives them to zero relative to the survivors. Training integrates out
its own ultraviolet detail.

The proof is satisfying in its simplicity. By the closed form (Fact 1), the ratio is

> `(|gᵢ| / |gⱼ|)^k · (|vᵢ| / |vⱼ|)`,

a constant times a geometric sequence whose base `|gᵢ|/|gⱼ|` is less than one. Such a
sequence races to zero. The grand physical slogan reduces to the humblest fact about
geometric series.

### Fact 4: The flow runs to a fixed point — and that fixed point is the kernel

Every renormalization-group flow runs *toward* something: a **fixed point**, a state
that no longer changes when you zoom out. In physics these fixed points classify the
universal behavior of matter — they are why utterly different materials boil and
freeze with the same critical exponents. What is the fixed point of training?

A residual `v` is unchanged by the RG step exactly when `gᵢ · vᵢ = vᵢ` for every
mode. As long as the learning rate is nonzero, a short calculation collapses this
to a single crisp condition:

> **A residual is a fixed point of training if and only if `λᵢ · vᵢ = 0` for every
> mode `i`.**

In other words, the error stops changing precisely when it lives entirely in the
directions the NTK cannot see — the **kernel** of the kernel matrix `Θ`. These are
the modes with eigenvalue zero, the directions in which the network has no
sensitivity and therefore nothing to learn. In RG language, this is the
**infrared (IR) fixed point** of the flow: the slow, surviving, "relevant" subspace
where the dynamics finally come to rest. Optimization dynamics and pure linear
algebra shake hands: *where training halts is exactly the null space of the kernel.*

### Fact 5: When everything contracts, the flow reaches zero

Finally, the happy ending. Suppose every mode is genuinely contracting — every gain
satisfies `|gᵢ| < 1`. Then there is no surviving direction at all; the IR fixed point
is simply zero:

> **If every gain has `|gᵢ| < 1`, the entire residual converges to zero.**

The network's error is annihilated, mode by mode, all the way down. This is the
multi-mode generalization of the classical NTK convergence theorem, and it is the
guarantee that, in this regime, training *works*: a well-conditioned kernel drives
the error to nothing.

## Why this is more than a metaphor

People have long sensed a poetic resemblance between learning and coarse-graining.
Deep networks build hierarchies of features — edges, then textures, then objects —
much as physics builds hierarchies of scales. The phrase "neural networks perform
renormalization" has floated through the literature as an inspiring analogy.

What is new here is that the analogy is no longer a metaphor. It is a **dictionary**,
and every entry is a proved theorem:

| Renormalization group | Neural network training |
|---|---|
| RG step / coarse-graining | one gradient-descent step (`rgStep`) |
| RG eigenvalue | gain `gᵢ = 1 − η λᵢ` |
| scaling dimension | NTK eigenvalue `λᵢ` |
| irrelevant (UV) mode | fast-contracting, high-eigenvalue mode |
| relevant (IR) mode | slow-contracting, low-eigenvalue mode |
| separation of scales | fast/slow amplitude ratio → 0 |
| IR fixed point | kernel (null space) of the NTK |
| flow to the fixed point | convergence of the residual |

Each row is not a suggestive correspondence but an equality backed by a complete,
gap-free proof. The slogan "training integrates out high-frequency modes" has become
the exact statement that a fast mode's amplitude, divided by a slow mode's, tends to
zero. The slogan "training flows to a fixed point" has become the exact statement
that the resting state is the kernel of the NTK.

## What it means

Why should anyone outside a seminar room care? Because turning a metaphor into
mathematics changes what you can *do* with it.

First, it explains a famous empirical mystery: the **spectral bias** of neural
networks. Practitioners have long noticed that networks learn smooth, large-scale
structure first and fine detail last — they fit the low frequencies before the high
ones. In the RG picture this is not a quirk to be explained away; it is the
separation of scales, Fact 3, in disguise. High-frequency modes have large
eigenvalues, hence small gains, hence they are integrated out fastest — but their
*contribution* to the function is suppressed relative to the slow modes, so the
network's output is dominated by smooth structure until late in training. The order
in which a network learns is dictated by the spectrum of its kernel.

Second, it gives **convergence guarantees with a physical interpretation**. The
speed of training is set by the spread of the eigenvalues — the condition number of
the kernel. A kernel with a wide spectrum has both very fast and very slow modes;
the slow ones become the bottleneck, the "critical mode" that governs the long-time
approach to the fixed point, just as the slowest fluctuation governs a physical
system near a critical point.

Third, and most tantalizing, it imports half a century of physics intuition into
machine learning. Physicists have an enormous toolbox for analyzing RG flows: fixed
points, universality classes, relevant and irrelevant operators, scaling collapse.
If training is genuinely an RG flow, those tools may transfer. One can conjecture,
for instance, that the loss curve of training exhibits a **universal scaling
collapse** — that across different datasets and architectures, the rescaled loss
falls onto a single curve governed by a handful of slow modes, exactly as wildly
different fluids share the same critical exponents. The dictionary above is the
foundation on which such conjectures can finally be stated, and tested, precisely.

## The view from above

Step back — coarse-grain, if you like — and a single picture emerges. A neural
network learning is a system flowing downhill in a landscape of scales. The frantic,
high-frequency corrections of early training are the molecular jitter of the coffee
cup: real, but destined to average away. With each step the flow zooms out, integrates
out the fast modes, and reveals the slow, relevant structure underneath. It runs,
inexorably, to a fixed point — the quiet null space where the kernel goes blind and
there is nothing left to learn.

The remarkable thing is not that learning *resembles* this picture. It is that, in
the linearized regime, learning *is* this picture, down to the last equation, with
every step certified. The mathematics of how the universe looks different at
different scales turns out to be the same mathematics as how a machine comes to
understand the world. Two telescopes, pointed in opposite directions, see the same
flow.
