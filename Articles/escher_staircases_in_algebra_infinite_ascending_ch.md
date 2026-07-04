# Escher Staircases in Algebra: Infinite Ascending Chains That Loop Back

## An impossible staircase, drawn in ideals

In one of M. C. Escher's most famous lithographs, a stone staircase rises
along the top of a building. Monks trudge up it, step after step, and yet —
impossibly — after climbing forever they arrive exactly where they began. The
picture is a visual paradox: every local step goes *up*, but the global loop
returns to its own starting point.

Algebra has its own version of this impossible architecture, and it is not a
trick of the eye. It lives in the world of *ideals* — the special subsets of a
ring that behave like "generalized multiples." Picture an infinite tower of
nested ideals,
$$
I_0 \subsetneq I_1 \subsetneq I_2 \subsetneq I_3 \subsetneq \cdots,
$$
each strictly larger than the last, ascending forever with no top. Now ask a
strange question: what do *all* of these ideals have in common? Their common
part — the intersection $\bigcap_n I_n$, or in the language of the ideal
lattice, the *infimum* $\bigwedge_n I_n$ — is the largest thing sitting inside
every rung at once. And here is the paradox: for the staircases we build below,
that common part is exactly the bottom rung $I_0$. Climb forever, and the meet
of everything you ever reach is the single point where you started.

We call such a tower an **Escher staircase**. This article tells the story of
what these staircases are, why they exist, the one ring where they are
impossible, and how counting them turns into a brand-new numerical fingerprint
for rings — a measure of just how far a ring is from being "tame."

## The tame rings and the wild ones

To appreciate the paradox you have to know why it *shouldn't* happen. A ring is
called **Noetherian** — after Emmy Noether, who made the idea central to modern
algebra — if it satisfies the **ascending chain condition**: every ascending
chain of ideals eventually stops growing. Formally, if
$I_0 \subseteq I_1 \subseteq I_2 \subseteq \cdots$, then from some point on all
the ideals are equal. In a Noetherian ring you simply cannot build an infinite
staircase; every climb hits a ceiling.

Noetherian rings are the tame, well-behaved rings, and almost every ring a
student meets is Noetherian: the integers $\mathbb{Z}$, any field, the
polynomial ring $k[x]$ in one variable, and — by the celebrated **Hilbert Basis
Theorem** — the polynomial ring $k[x_1, \dots, x_n]$ in *any finite* number of
variables. In all of these, staircases are impossible.

An Escher staircase is precisely the fingerprint of a ring that is *not* tame.
The central bridge of this whole subject is a clean equivalence:

> **The Staircase Criterion.** A commutative ring admits an Escher staircase if
> and only if it is *not* Noetherian.

In words: an infinite strictly ascending chain of ideals is *exactly* the
obstruction to the ascending chain condition — no more, no less. The proof is a
short but satisfying piece of order theory. Saying "every ascending chain
stabilizes" is the same as saying the relation "strictly larger" on ideals is
*well-founded* (it has no infinite descending run when you turn it around), and
a strictly ascending sequence $I_0 < I_1 < I_2 < \cdots$ is exactly a witness
that it is *not*. One direction packages a staircase into a violation of
well-foundedness; the other pulls a staircase out of any such violation. The
Staircase Criterion turns a subtle finiteness property into a single, concrete,
climbable object.

## Building a staircase you can see

Abstract existence is one thing; a staircase you can point at is another. Here
is the cleanest one, living in the ring
$$
\mathbb{Z}^{\mathbb{N}} = \{\, f : \mathbb{N} \to \mathbb{Z} \,\},
$$
the ring of all infinite integer sequences $f = (f_0, f_1, f_2, \dots)$, added
and multiplied slot by slot. This is a genuinely infinite gadget — it is *not*
Noetherian — and it hides a beautiful staircase.

For each level $n$, define the ideal of sequences that switch off from position
$n$ onward:
$$
S_n = \{\, f : f_k = 0 \text{ for all } k \ge n \,\}.
$$
So $S_1$ is sequences supported only at slot $0$; $S_2$ at slots $0,1$; and so
on. Each $S_n$ really is an ideal: if two sequences both vanish past $n$, so
does their sum, and multiplying by *any* sequence keeps them vanishing there.

These ideals climb strictly. To see that $S_n$ is genuinely smaller than
$S_{n+1}$, look at the "spike" sequence $e_n$ that is $1$ in slot $n$ and $0$
everywhere else. It vanishes past $n+1$, so $e_n \in S_{n+1}$; but its value at
slot $n$ is $1 \ne 0$, so $e_n \notin S_n$. One explicit witness at every level
proves the whole tower is strict:
$$
S_0 \subsetneq S_1 \subsetneq S_2 \subsetneq \cdots.
$$

Now watch it loop back. The very bottom rung, $S_0$, is the set of sequences
that vanish from slot $0$ onward — that is, the sequences that are zero
*everywhere*. So $S_0 = \{0\}$, the zero ideal. And what is the common part of
the whole infinite tower? A sequence lying in *every* $S_n$ must vanish past
every threshold — again forcing it to be zero everywhere. Hence
$$
\bigwedge_{n} S_n = \{0\} = S_0.
$$
There it is: an infinite tower whose every step strictly ascends, yet the meet
of the entire tower is the single bottom rung — the zero element, which of
course also sits quietly inside every rung above. Escher's monks, rendered in
ideals.

## The one ring where the staircase is impossible

A paradox is most striking against a place where it cannot happen. Consider the
**$p$-adic integers** $\mathbb{Z}_p$, a cornerstone of number theory obtained by
completing the integers with respect to a prime $p$. The $p$-adic integers form
a *discrete valuation ring*: a particularly rigid kind of principal ideal
domain in which the ideals are perfectly ordered like a single ladder,
$$
\mathbb{Z}_p \supsetneq (p) \supsetneq (p^2) \supsetneq (p^3) \supsetneq \cdots,
$$
and nothing else. Every ideal is a power of the single prime $p$. Because it is
a principal ideal domain, $\mathbb{Z}_p$ is Noetherian, and so — by the
Staircase Criterion — it admits **no** Escher staircase whatsoever. Every
ascending chain of ideals in $\mathbb{Z}_p$ grinds to a halt. Here the monks
reach a genuine top step and can climb no further. The contrast with
$\mathbb{Z}^{\mathbb{N}}$ is the whole point: staircases are a property of
wildness, and $\mathbb{Z}_p$ is tame.

## A cautionary tale: the staircase that runs the wrong way

The subject comes with a built-in trap worth flagging, because it is exactly the
kind of mistake that *feels* right. A tempting first guess for an Escher
staircase lives in $\mathrm{Int}(\mathbb{Z})$, the ring of *integer-valued
polynomials* — polynomials with rational coefficients, like
$\binom{x}{2} = \tfrac{x(x-1)}{2}$, that nonetheless send every integer to an
integer. One is tempted to set
$$
I_n = \{\, f : f(\mathbb{Z}) \subseteq 2^n \mathbb{Z} \,\},
$$
the polynomials whose values are all divisible by $2^n$, and call it a
staircase. But this chain runs the *wrong way*. Since $2^{n+1}\mathbb{Z}
\subseteq 2^n\mathbb{Z}$, a polynomial divisible everywhere by $2^{n+1}$ is
certainly divisible by $2^n$, so $I_{n+1} \subseteq I_n$. The chain
*descends*, not ascends — it is not an Escher staircase at all. This is a real
and easy inclusion to get backwards, and it is a reminder that the direction of
the arrows is the entire content of the concept. The honest infinite-height
witnesses are the ones above (and below), whose rungs genuinely grow.

## From paradox to invariant: the Escher height

The most exciting turn in this story is that Escher staircases are not just a
curiosity — counting them yields a *new numerical invariant* of a ring. The
binary distinction "Noetherian versus not" is coarse: it lumps together rings
that fail the chain condition mildly with rings that fail it wildly. The
**Escher height** refines it into a graded scale. Loosely, it is the length of
the *longest* strictly ascending chain of ideals a ring can support. A ring with
no staircase has Escher height $0$; a ring with staircases has positive, often
infinite, height, and the exact value measures *how many independent directions*
the ideals can grow in.

Polynomial rings make the invariant vivid, and reveal a sharp finite/infinite
dichotomy. With **finitely many** variables — $k[x_1, \dots, x_n]$ over a field
$k$ — the Hilbert Basis Theorem guarantees the ascending chain condition, so
there is no staircase at all. But with **countably many** variables the picture
flips completely. In the ring $k[x_0, x_1, x_2, \dots]$ there is an explicit
staircase built from the variables themselves:
$$
V_n = \langle x_0, x_1, \dots, x_{n-1} \rangle,
$$
the ideal generated by the first $n$ variables. Each rung strictly contains the
last, because the next variable $x_n$ is genuinely *new*: it cannot be written
as a combination of $x_0, \dots, x_{n-1}$ with polynomial coefficients.

How do you *prove* a variable is missing from an ideal? With a wonderfully
concrete trick. Suppose, for contradiction, $x_n$ did lie in $\langle x_0,
\dots, x_{n-1}\rangle$. Apply the "evaluation" homomorphism that sends
$x_0, \dots, x_{n-1}$ all to $0$ but leaves $x_n$ untouched. This map kills
every generator of the ideal, so it must kill anything inside the ideal — in
particular it would send $x_n$ to $0$. But by construction it sends $x_n$ to
$x_n$, which is not zero. Contradiction. The variable is missing, the inclusion
is strict, and the tower climbs forever. And once again it loops back: the
bottom rung $V_0 = \langle \varnothing \rangle$ is the zero ideal, and the meet
of the whole tower collapses to $\{0\} = V_0$.

So the "Escher height" of a polynomial ring over a field tracks the number of
variables: it is $0$ when there are finitely many, and infinite when there are
infinitely many. The impossible staircase becomes possible exactly when you have
infinitely many independent directions to climb in.

## Why it matters

There is a real conceptual payoff here. Non-Noetherian rings are the untamed
frontier of commutative algebra — they show up in the study of infinite-variable
polynomial systems, rings of integer-valued and continuous functions, and the
ring of *all* algebraic integers (numbers like $\sqrt{2}$ and $\sqrt[3]{5}$ and
their kin), which is famously non-Noetherian and therefore must contain a
staircase of its own. For decades the standard tool for such rings was a single
yes/no question: is it Noetherian? The Escher height promises a *ruler* instead
of a switch — a way to say not just *that* a ring fails the chain condition, but
*how badly*, along how many independent axes of growth.

The name is not merely decorative. Escher's staircase is a picture of local
monotonicity coexisting with global return, and that is exactly the mathematical
content: each step is a strict inclusion, yet the whole tower meets in its own
first step. The loop-back is automatic for any ascending chain — the meet of a
rising tower is always its floor — but drawn out in the concrete examples of
infinite sequences and infinite-variable polynomials, it becomes a genuine piece
of architecture you can climb.

Some staircases really do loop back to where they began. In algebra, you can not
only draw them — you can measure exactly how tall they are allowed to be.
