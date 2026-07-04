# The Ghost in the Center: How a Symmetry Group Can Vanish Without Disappearing

## A puzzle about counting

Here is a question that sounds like it should have a boring answer. Take the equation
$$a^2 = 1.$$
How many solutions does it have? Over the ordinary real numbers, or the complex numbers, the answer is obvious: two, namely $a = 1$ and $a = -1$. Over the rational numbers, still two. It feels like a law of nature: a quadratic equation has (at most) two roots, and this one has exactly two.

But mathematics has a habit of quietly breaking laws of nature when you are not looking. Suppose we work in a number system where $1 + 1 = 0$ — that is, where $2 = 0$. Such systems really exist; they are the arithmetic of characteristic two, the same arithmetic that underlies the parity bits in your computer and the error-correcting codes in every hard drive. In that world, $-1$ and $+1$ are the *same number*. The equation $a^2 = 1$ suddenly has only **one** solution.

And yet, something is not right. The equation didn't get simpler. If we rewrite it, we find
$$a^2 - 1 = (a-1)(a+1) = (a-1)(a-1) = (a-1)^2,$$
because $+1$ and $-1$ coincide. So in characteristic two the equation $a^2 = 1$ is really
$$(a-1)^2 = 0.$$
There is still one root, $a = 1$ — but it is a *double* root. The second solution didn't leave the room; it collapsed onto the first one and became invisible. If you only count points, you see one solution. If you measure the equation's true algebraic weight, you still find two. The missing solution has become a ghost: present in the structure, absent from the head count.

This article is about a place deep in the theory of symmetry where exactly this ghost appears, and about a theorem that pins down precisely what it is and why it matters.

## Symmetries of symmetries

Modern geometry and physics are organized around **groups** — collections of transformations that preserve some structure. Rotations of a sphere form a group. The symmetries of a crystal form a group. The internal symmetries that govern the fundamental particles of physics form groups. The most important continuous groups, the ones that appear again and again, are the **reductive groups**: matrix groups like the rotation groups, the special linear groups, and their relatives.

Two of the most famous small examples are close cousins:

- $\mathrm{SL}_2$, the group of $2\times 2$ matrices with determinant $1$.
- $\mathrm{PGL}_2$, the group of $2\times 2$ invertible matrices where we agree to ignore overall scaling — a matrix and any nonzero multiple of it count as the same transformation.

These two are almost the same group, but not quite. There is a natural map
$$\pi\colon \mathrm{SL}_2 \longrightarrow \mathrm{PGL}_2$$
that sends a determinant-one matrix to its class "up to scaling." This map is a **covering**: $\mathrm{SL}_2$ sits above $\mathrm{PGL}_2$ like a double-decker, and the exact amount of redundancy is captured by the *kernel* of $\pi$ — the matrices in $\mathrm{SL}_2$ that $\pi$ sends to the identity. Those are precisely the scalar matrices $a\cdot I$ (a number $a$ times the identity matrix) that still have determinant one. The determinant of $a\cdot I$ is $a^2$, so the condition is
$$a^2 = 1.$$

There it is again — our quadratic. The kernel of the covering map is the group of square roots of unity, written $\mu_2$. In ordinary arithmetic it has two elements, $\pm I$. In characteristic two it has one element with a ghost attached. This kernel is the group-theoretic fingerprint of how much bigger $\mathrm{SL}_2$ is than $\mathrm{PGL}_2$; it is what topologists would call the fundamental group of $\mathrm{PGL}_2$.

$\mathrm{SL}_2$ is the *simply connected cover* — the universal, "unwound" version of the $\mathrm{PGL}_2$ family. The theme of this article is that the kernel $\mu_2$, this innocuous-looking group of square roots of one, is exactly the object that shows up when we ask a subtle question about symmetries.

## Regular unipotent elements: the most generic shear

Inside any such group live special elements. Among the most important are the **regular unipotent** elements. "Unipotent" means the element is a pure shear: all of its eigenvalues equal $1$, so it differs from the identity only by a nilpotent nudge. "Regular" means it is as generic as a unipotent element can be — it has the smallest possible symmetry, the fewest things commuting with it.

For $\mathrm{SL}_2$ there is essentially only one regular unipotent element, the single Jordan block
$$u = \begin{pmatrix} 1 & 1 \\ 0 & 1 \end{pmatrix}.$$
This is the transformation that fixes one direction and shears everything else along it. It is the archetype of a "maximally degenerate" symmetry, and understanding what commutes with it — its **centralizer** — is a basic structural question.

A direct computation, which we carry out below, shows that the matrices commuting with $u$ inside $\mathrm{SL}_2$ are exactly
$$\begin{pmatrix} a & b \\ 0 & a \end{pmatrix}, \qquad a^2 = 1.$$
They are upper-triangular with a constant diagonal $a$, and the determinant-one condition forces $a^2 = 1$. This centralizer is abelian and one-dimensional — a line's worth of shears $b$, together with the two-element sign choice $a=\pm1$. It is the smallest a centralizer can be, which is exactly what "regular" is supposed to mean.

## The question: which central symmetries fix the class?

Now for the real question. Consider the **center** of $\mathrm{SL}_2$ — the elements that commute with *everything*. A short computation shows the center is again $\mu_2$: the scalar matrices $a\cdot I$ with $a^2 = 1$. And here is a curious fact. Every central element commutes with everything, so in particular conjugating any element $g$ by a central element $z$ does nothing: $zgz^{-1} = g$. That means every central element fixes every conjugacy class. On the level of actual points, the center appears to stabilize the class of $u$ completely.

So one is tempted to say: the stabilizer of the regular unipotent class inside the center is the *whole* center. And on points, that is true. But it is the wrong answer — or rather, it is only the visible part of the answer.

The precise statement, the heart of this work, is the following.

> **Main Theorem (Stabilizer equals kernel).** Let $\pi\colon \mathrm{SL}_2 \to \mathrm{PGL}_2$ be the universal cover, with kernel $\ker\pi = \mu_2$. Let $u$ be the regular unipotent element. Then the stabilizer of the conjugacy class of $u$, taken inside the center of $\mathrm{SL}_2$, is exactly $\ker\pi = \mu_2$.

For the pair $\mathrm{SL}_2 \to \mathrm{PGL}_2$ the center *is* the kernel, so the stabilizer is the whole center — but the content of the theorem is *which* group this is: it is $\mu_2$, the square roots of unity, the fundamental group of $\mathrm{PGL}_2$. This is the unipotent analogue of a classical result of Steinberg, who described such stabilizers for *semisimple* (diagonalizable) elements. The theorem here says the same clean description — "the stabilizer is the kernel of the simply connected cover" — survives when we pass to the opposite extreme, the regular unipotents.

## Where the ghost lives

Now we can say what is really going on, and why the naive "it's the whole center" answer, while true on points, misses the essential structure.

The center, the kernel, and the stabilizer are all the same group $\mu_2$ — and $\mu_2$ is defined by the equation $a^2 = 1$. In ordinary characteristic, that equation cuts out two clean, separated points $\pm 1$. The group $\mu_2$ is then **étale**: it is a discrete two-point set, smooth and unremarkable, and everything about it is visible by counting.

In characteristic two, the very same equation becomes $(a-1)^2 = 0$. Now $\mu_2$ has a single point, $a = 1$, but that point is *fat*: it carries the algebraic weight of a double root. The group $\mu_2$ is no longer étale; it has become **infinitesimal**, a single non-reduced point. This is exactly the ghost from the opening. And it explains a phenomenon that would otherwise be baffling: the stabilizer of the regular unipotent class **fails to be smooth** in characteristic two, even though as a set of points it looks perfectly ordinary.

The failure of smoothness is not a defect of the theorem; it is the theorem's most interesting feature. The stabilizer is *always* the kernel $\mu_2$. What changes with the characteristic is the internal texture of that kernel:

- **Characteristic $\neq 2$:** $\mu_2$ is two separate points. The stabilizer is smooth (étale).
- **Characteristic $2$:** $\mu_2$ is one fat point, $(a-1)^2=0$. The stabilizer is non-smooth (infinitesimal).

The single arithmetic condition — does the characteristic divide the order of the fundamental group? — governs the entire transition. The general principle it points to is striking: the smoothness of these stabilizers is not controlled by the intricate geometry of the unipotent element at all, but by a simple divisibility question about the group's fundamental group.

## Why the diagonal must be constant, in one line

It is worth seeing why regularity forces such a rigid centralizer, because it makes the whole picture concrete. Write a general matrix $M = \begin{pmatrix} p & q \\ r & s\end{pmatrix}$ and impose $Mu = uM$ with $u = \begin{pmatrix}1&1\\0&1\end{pmatrix}$. Multiplying out,
$$Mu = \begin{pmatrix} p & p+q \\ r & r+s \end{pmatrix}, \qquad uM = \begin{pmatrix} p+r & q+s \\ r & s \end{pmatrix}.$$
Comparing the bottom-left entries gives $r = r$ (no information), but comparing the top-left entries gives $p = p + r$, hence $r = 0$. Comparing the bottom-right entries gives $r + s = s$, again $r = 0$. And comparing the top-right entries gives $p + q = q + s$, hence $p = s$: the diagonal is constant. So $M$ is upper triangular with equal diagonal entries. Adding the determinant-one condition $ps - qr = p^2 = 1$ gives $p^2 = 1$. This is the entire centralizer computation, and the appearance of $p^2 = 1$ — the defining equation of $\mu_2$ — is no accident: it is where the fundamental group of $\mathrm{PGL}_2$ enters.

To see that the *center* is even smaller, we impose commuting with the opposite shear $l = \begin{pmatrix}1&0\\1&1\end{pmatrix}$ as well. The same kind of one-line comparison forces the off-diagonal entries to vanish, leaving only the scalars $a\cdot I$. Determinant one then gives $a^2 = 1$ once more. The center is $\mu_2$, on the nose.

## Why this matters beyond $\mathrm{SL}_2$

It might look like an isolated curiosity about $2\times 2$ matrices. It is not. The pair $\mathrm{SL}_2 \to \mathrm{PGL}_2$ is the smallest member of an infinite family — the special linear groups $\mathrm{SL}_n$ covering the projective linear groups $\mathrm{PGL}_n$, and beyond them all the reductive groups that structure geometry, number theory, and physics. In each case there is a simply connected cover, a fundamental group sitting in its center, and regular unipotent elements. The mechanism illuminated here — the stabilizer of a regular class is exactly the fundamental group, and it degenerates from étale to infinitesimal exactly when the characteristic divides the group's order — is expected to hold across the whole family, with $\mu_2$ replaced by $\mu_p$ and characteristic two replaced by characteristic $p$.

This is the same theme that runs through the modern theory of algebraic groups in positive characteristic, where the "extra" infinitesimal structure — Frobenius kernels, non-reduced group schemes — is not pathology to be avoided but signal to be read. The phenomenon here is a laboratory-clean instance: a symmetry group that, in the "wrong" characteristic, does not disappear but *condenses*, hiding its full size inside a single non-reduced point.

The lesson is one that took mathematicians a long time to internalize and that the theorem above states with perfect economy. **Counting points is not the same as measuring structure.** A symmetry can be fully present — determining the geometry, controlling the smoothness, carrying its complete algebraic weight — while contributing only a single point to the census. The ghost of $a = -1$, hiding inside $a = 1$ when $2 = 0$, is not a bookkeeping error. It is the most honest thing in the room.
