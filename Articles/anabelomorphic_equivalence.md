# When Two Number Systems Wear the Same Mask

## A story about hidden identity, arithmetic fingerprints, and the surprising rigidity of a single small group

Imagine you are handed two elaborate machines, each sealed inside an
opaque box. You cannot see the gears. You cannot read the labels. All
you are allowed to do is compare the *symmetries* of the two machines —
the ways each one can be shuffled without changing how it behaves. Now
comes the question that has quietly haunted number theory for a century:
**if two machines have exactly the same symmetries, must they be the
same machine?**

This is not an idle riddle. It is the beating heart of a program that
mathematicians call **anabelian geometry** — the study of how much of an
arithmetic object can be reconstructed from nothing but its abstract
group of symmetries. The dream, first articulated by Alexander
Grothendieck and pushed to spectacular heights in the work of Shinichi
Mochizuki, is that certain number systems are so rigid that their entire
structure is encoded in a single group. More recently, Kirti Joshi
introduced a provocative twist he calls **anabelomorphy**: the idea that
two genuinely *different* number systems can nonetheless be linked — can
"wear the same mask" — when their symmetry data line up. Different fields,
same shadow.

This article tells the story of one clean, complete corner of that vast
landscape. We will strip the problem down to its simplest honest core,
ask exactly when two number systems cast the same shadow, and discover
something both reassuring and subtle: at this level, the shadow is a
**perfect fingerprint** — but only if you know which feature of the
number system it is fingerprinting.

## The number systems: local fields and their residues

The number systems in our story are called **local fields**. You already
know one of them intimately: the real numbers, which arise by
"completing" the rationals so that every convergent-looking sequence
actually converges. But the rationals can be completed in infinitely
many *other* ways, one for each prime number $p$. Fix a prime $p$, decree
that a number is "small" exactly when it is divisible by a high power of
$p$, and complete the rationals in this strange new metric. You obtain
the field of **$p$-adic numbers** $\mathbb{Q}_p$ — a self-contained
universe of arithmetic where $p$ is the fundamental unit of smallness.

From $\mathbb{Q}_p$ one builds a whole tower of finite extensions, and
each such extension $K$ is a local field. Every local field comes with a
built-in "coarse-graining" operation: you can forget the infinitely fine
$p$-adic detail and keep only the leading behavior. What survives is a
finite field called the **residue field** $k_K$ — a miniature, finite
arithmetic world sitting at the boundary of the infinite one.

A finite field is determined completely by its size, and that size is
always a prime power $q = p^f$. Here $p$ is the **residue
characteristic** (the prime we started with) and $f$ is the **residue
degree** (how much bigger the residue field is than the smallest one).
So attached to every local field are two humble integers: a prime $p$ and
a positive integer $f$. We package them together and call the pair a
**residue datum** $(p, f)$.

## The symmetry object: the residue torus

Now we build the symmetry object we will actually compare. Inside the
finite residue field $k_K$ live its nonzero elements, and these can be
multiplied. The nonzero elements of a finite field form a group under
multiplication — we call it the **residue torus**, written
$k_K^{\times}$. It is the arithmetic engine of the residue world.

This little group is the ground-floor example of what the modern theory
of the Langlands program calls a **Langlands stack** for the group
$\mathrm{GL}(1)$: it is precisely the object whose characters (its
one-dimensional representations) index the simplest automorphic and
Galois data attached to the field. When people speak of comparing the
"$\mathrm{GL}(1)$ shadows" of two local fields, this residue torus is the
shadow they mean.

Two beautiful classical facts pin it down completely:

**Fact 1 (Cyclicity).** The residue torus $k_K^{\times}$ is *cyclic*:
there is a single element whose powers sweep out the entire group. A
finite field's multiplicative group is always a clock.

**Fact 2 (Size).** The residue torus has exactly
$$|k_K^{\times}| = p^f - 1$$
elements — one fewer than the residue field, because we threw away zero.

So the residue torus is, up to isomorphism, nothing more mysterious than
a clock with $p^f - 1$ hours on its face. Everything we will prove flows
from this single number.

## The central question: when do two shadows match?

Here is the definition at the center of our story.

> **Residue-anabelomorphic equivalence.** Two residue data $(p, f)$ and
> $(p', f')$ are *residue-anabelomorphic* when their residue tori are
> isomorphic as abstract groups — that is, when there is a
> structure-preserving one-to-one correspondence
> $$k^{\times} \;\cong\; (k')^{\times}$$
> between the two multiplicative groups.

This relation is the honest, abelian shadow of Joshi's anabelomorphy:
two number systems are linked when their $\mathrm{GL}(1)$ residue groups
match. Notice how little we are demanding — we do not ask that the fields
be equal, or even that they look alike. We ask only that these two small
groups be abstractly interchangeable, with the labels rubbed off.

The first thing to check is that this notion behaves like a genuine
notion of "sameness." And it does:

> **The equivalence-relation theorem.** Residue-anabelomorphic
> equivalence is an equivalence relation: every datum matches itself
> (reflexivity), if one matches a second then the second matches the
> first (symmetry), and matches chain together (transitivity).

The proof is exactly what your intuition wants: the identity map witnesses
reflexivity, inverting an isomorphism witnesses symmetry, and composing
two isomorphisms witnesses transitivity. Nothing exotic — but it means we
are entitled to think of residue-anabelomorphic data as forming clean,
well-defined families.

## The rigidity theorem: the shadow is a perfect fingerprint

Now the payoff. We asked whether matching shadows force matching
machines. Here is the answer, in the cleanest possible form.

> **Rigidity Theorem.** The residue tori of $(p, f)$ and $(p', f')$ are
> isomorphic *if and only if* the residue characteristics agree and the
> residue degrees agree:
> $$k^{\times} \cong (k')^{\times}
> \quad\Longleftrightarrow\quad
> p = p' \ \text{and}\ f = f'.$$

In words: **at the $\mathrm{GL}(1)$ level, the abstract group knows both
the prime and the residue degree, and nothing is lost.** The shadow is a
perfect fingerprint of the pair $(p, f)$.

Why is this true? The "if" direction is easy: identical data give
literally the same group. The "only if" direction is where the arithmetic
lives, and the argument is a small gem. Two finite cyclic groups are
isomorphic exactly when they have the same number of elements. So an
isomorphism of residue tori forces
$$p^f - 1 = p'^{f'} - 1,$$
and adding $1$ to both sides restores the clean prime-power equation
$$p^f = p'^{f'}.$$
Now comes the decisive fact: **a prime power determines its base and its
exponent uniquely.** There is no coincidence like $2^3 = 3^2$; the number
$8$ can only be $2^3$, never $q^e$ for any other prime $q$. So
$p^f = p'^{f'}$ leaves no wiggle room: $p = p'$ and $f = f'$.

One subtlety is worth savoring, because it explains why the argument has
to be routed so carefully. You might hope to read $p$ and $f$ directly
off the *torus size* $p^f - 1$. But that number is treacherous. When
$p = 2, f = 2$ the torus size is $2^2 - 1 = 3$, a prime that hides its
origins — you cannot tell it came from a prime power until you add $1$
back and factor $4 = 2^2$. The whole trick is to undo the "minus one,"
recover the pristine prime power $p^f$, and only then invoke uniqueness.
That single step — from $p^f - 1$ back to $p^f$ — is what turns a murky
number into a rigid fingerprint.

## The twist: degree is not the same as residue degree

Rigidity is comforting. But mathematics keeps its most interesting
lessons for the moment just after you feel comfortable. Here is ours.

A local field carries *two* notions of "size" relative to its base
$\mathbb{Q}_p$. One is the residue degree $f$ we have been discussing.
The other is the **ramification index** $e$, which measures how much the
notion of "smallness" gets stretched in passing from $\mathbb{Q}_p$ to
$K$. The **total degree** — the honest dimension of $K$ as a vector space
over $\mathbb{Q}_p$ — is the product
$$[K : \mathbb{Q}_p] = e \cdot f.$$

It is tempting to guess that the total degree is the "real" invariant and
that residue degree is just bookkeeping. The following result demolishes
that guess.

> **Degree Non-Rigidity Theorem.** Fixing the residue characteristic $p$
> and the *total degree* $e \cdot f$ does **not** force
> residue-anabelomorphic equivalence. Concretely, take $p = 2$ and total
> degree $2$. This can be realized in two genuinely different ways:
> - an **unramified** field with $(e, f) = (1, 2)$, and
> - a **totally ramified** field with $(e, f) = (2, 1)$.
>
> Both have total degree $e \cdot f = 2$ over $\mathbb{Q}_2$. Yet their
> residue tori have sizes $2^2 - 1 = 3$ and $2^1 - 1 = 1$ respectively —
> a three-element clock versus a one-element point. These groups are not
> isomorphic, so the two fields are **not** residue-anabelomorphic.

The moral is sharp and a little startling. **You can trade ramification
against residue degree, keeping the prime and the total degree perfectly
fixed, and the $\mathrm{GL}(1)$ shadow will nevertheless change.** The
residue torus is exquisitely sensitive to $f$ — and utterly blind to $e$.
The two fields above are, from the total-degree point of view,
indistinguishable twins; from the anabelomorphic point of view, they are
strangers. Residue degree is a *strictly finer* invariant than field
degree.

## Why it matters

Zoom back out. What we have found is a precise map of what the simplest
symmetry data can and cannot see. It **can** see, with perfect fidelity,
the residue characteristic and the residue degree — the "tame" arithmetic
of the field, the part governed by the finite residue world. It
**cannot** see ramification — the "wild" arithmetic, the part that lives
in the infinitely fine $p$-adic filigree.

This is exactly the kind of clean dividing line that a reconstruction
program dreams of. It says: the tame layer is completely nailed down, so
any remaining mystery in rebuilding a local field from its symmetries
must be concentrated in the wild, ramified part. It turns a vague dream —
"maybe the group remembers the field" — into a testable ledger of what is
remembered and what is forgotten.

And it gives Joshi's poetic idea of "different fields wearing the same
mask" a first rigorous instance and a first rigorous *limit*. At the
$\mathrm{GL}(1)$ residue level, no two different $(p, f)$ ever share a
mask — the fingerprint is perfect. But move up to the coarser
total-degree relation and masks reappear: the unramified and totally
ramified quadratic fields over $\mathbb{Q}_2$ are a matched pair in
degree, split apart in shadow.

Two small groups. A three-hour clock and a single point. From them, a
complete accounting of identity and disguise in the arithmetic of local
fields — and a clear signpost pointing to where the deeper mysteries of
reconstruction must lie.
