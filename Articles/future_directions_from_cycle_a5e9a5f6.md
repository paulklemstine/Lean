# When Averaging Breaks: A Sharp Boundary in Symmetry and Cohomology

Averaging is one of mathematics’ most reliable ways to turn disorder into symmetry. If a finite group rearranges an object, one often adds all its translates and divides by the number of group elements. The result is invariant: every rearrangement merely permutes the terms in the sum. This elementary maneuver lies behind constructions in geometry, representation theory, number theory, and physics. It can build symmetric metrics, invariant projections, and canonical solutions to equations that initially have no preferred answer.

But division is doing essential work. What happens when the number of symmetries becomes zero in the arithmetic of the coefficients?

There is a remarkably small counterexample that exposes the exact fault line. For every prime number $p$, take the cyclic group of order $p$ and coefficients in the field $\mathbb{F}_p$. Let the group act trivially, and assign to each group element its own coordinate in $\mathbb{F}_p$. This coordinate function satisfies the cocycle equation—the algebraic rule describing a displacement compatible with composition—but it cannot arise from a change of origin. In cohomological language, it is a cocycle that is not a coboundary.

This example proves something stronger than the failure of one familiar proof. It shows that the hypothesis permitting division by the group order is genuinely necessary. When the characteristic of the field divides that order, averaging can fail in the most direct possible way.

## Symmetry with a memory of displacement

Suppose a finite group $G$ acts linearly on a vector space $V$. A function $c:G\to V$ is called a **degree-one cocycle** if

$$
c(gh)=c(g)+g\cdot c(h)
$$

for all $g,h\in G$. The equation says that the displacement associated with doing $h$ and then $g$ consists of the displacement caused by $g$, plus the displacement caused by $h$ transported through the action of $g$.

This rule appears naturally whenever a linear action is enlarged to an affine action. Given $c$, define

$$
g\star v=g\cdot v+c(g).
$$

The cocycle equation is exactly the condition that $(gh)\star v=g\star(h\star v)$. Thus a cocycle records the translational part of an affine symmetry.

Some cocycles are superficial. If there is a vector $v\in V$ such that

$$
c(g)=v-g\cdot v
$$

for every $g\in G$, then $c$ is called a **coboundary**. Translating the origin by $v$ removes the affine displacement and leaves a purely linear action. Consequently, the question “Is every cocycle a coboundary?” asks whether every compatible affine displacement can be erased by choosing a better origin.

When the group is finite and its size is invertible in the coefficient field, the answer is yes. Indeed, from a cocycle $c$ one can form the average

$$
v=\frac{1}{|G|}\sum_{h\in G}c(h).
$$

Reindexing the sum by multiplication and using the cocycle identity yields $c(g)=v-g\cdot v$ (up to the equivalent sign convention obtained by choosing $-v$). This is the **finite-group averaging theorem in degree one**: if $|G|$ can be divided by in the coefficient field, every degree-one cocycle is a coboundary.

The natural temptation is to believe that division is merely a convenience and that a more ingenious argument might prove the same conclusion without it. The cyclic prime-order example decisively rules this out.

## The smallest possible obstruction

Fix a prime $p$. Let

$$
G=\mathbb{Z}/p\mathbb{Z}
$$

but write its operation multiplicatively, so that the group product corresponds to addition of residues. Let

$$
V=\mathbb{F}_p=\mathbb{Z}/p\mathbb{Z},
$$

and let every $g\in G$ act trivially on $V$:

$$
g\cdot x=x.
$$

Now define $c:G\to V$ by taking the underlying residue coordinate. If $g$ corresponds to $a\in\mathbb{F}_p$ and $h$ corresponds to $b\in\mathbb{F}_p$, then $gh$ corresponds to $a+b$. Therefore

$$
c(gh)=a+b=c(g)+c(h)=c(g)+g\cdot c(h).
$$

So $c$ is a degree-one cocycle.

Could it be a coboundary? For the trivial action, every candidate coboundary has the form

$$
v-g\cdot v=v-v=0.
$$

Thus every coboundary is the zero function. But the coordinate cocycle is not zero: the group element corresponding to $1$ is sent to $1$. Hence $c$ is not a coboundary.

This proves the central result:

> **Prime-characteristic sharpness theorem.** For every prime $p$, the cyclic group of order $p$, acting trivially on the one-dimensional field $\mathbb{F}_p$, admits a degree-one cocycle that is not a coboundary. At the same time, its group order satisfies $|G|=p=0$ in $\mathbb{F}_p$.

The three ingredients fit together perfectly: the group has $p$ elements, the field has characteristic $p$, and the cocycle is the identity coordinate. There is no exceptional prime and no large or complicated construction. The obstruction occurs uniformly for $p=2,3,5,7$, and every prime thereafter.

## A concrete walk around a clock

Imagine a clock with $p$ positions labeled $0,1,\ldots,p-1$. A group element means “advance by this many ticks,” with all arithmetic wrapping around after $p$. The cocycle $c$ simply reports the requested advance. Combining an advance of $a$ ticks with one of $b$ ticks produces an advance of $a+b$ ticks modulo $p$, which is precisely the cocycle law.

Changing the origin of the value space cannot erase this report, because the group does nothing to values: before and after the action, the chosen origin remains the same. The difference $v-g\cdot v$ is always zero. Yet a one-tick move still reports $1$. The memory of displacement survives every change of origin.

A short numerical table makes this visible. For $p=5$, the cocycle values are

$$
0,1,2,3,4.
$$

For example, the elements labeled $3$ and $4$ compose to the element labeled $2$, because $3+4\equiv2\pmod5$, and

$$
c(3\cdot4)=2\equiv3+4=c(3)+c(4)\pmod5.
$$

Meanwhile every coboundary is

$$
(0,0,0,0,0).
$$

No choice of $v$ changes that list. The nonzero cocycle is therefore unmistakable.

## Why division by the group order matters

In ordinary real or complex arithmetic, $p$ is nonzero and has an inverse. In characteristic $p$, however,

$$
p\cdot1=0.
$$

The averaging factor $1/p$ does not exist. Even more revealingly, the sum of the cocycle values contains no information capable of recovering a preferred center. The usual averaging construction collapses at exactly the same place where the nontrivial cohomology class appears.

The theorem should therefore be read as a sharpness statement. It does not merely say that averaging is unavailable. It says that its expected conclusion is false. Any theorem claiming that all degree-one cocycles vanish must exclude this modular configuration or impose some different hypothesis strong enough to defeat it.

There is also a useful geometric picture. The cocycle makes the affine line over $\mathbb{F}_p$ into a space on which the group acts by translations: the element labeled $a$ sends $x$ to $x+a$. A coboundary would correspond to a point fixed by every translation after a suitable choice of origin. But translation by $1$ fixes no point, since $x+1=x$ would imply $1=0$. The nonzero cohomology class is therefore the algebraic record of a fixed point that cannot exist.

This distinction—between a broken proof and a false conclusion—is crucial throughout mathematics. A proof can fail because its technique is clumsy, while the theorem remains true. Here the explicit cocycle settles the issue: no alternate proof can establish unconditional vanishing, because there is a genuine counterexample for every prime characteristic.

## From finite symmetries to infinite profinite ones

The example also serves as a guide for more advanced settings. A profinite group is an inverse limit of finite groups, an object that packages infinitely many compatible finite symmetries. Continuous cocycles with values in finite discrete modules often factor through finite quotients. This creates a natural strategy: descend the cocycle to a finite quotient, average there, and lift the resulting coboundary back.

The counterexample tells us exactly which quotients are safe. If every relevant finite quotient has order prime to the coefficient characteristic $\ell$, then its order is invertible in $\mathbb{F}_\ell$, and finite averaging can proceed. For a pro-prime-to-$\ell$ group, this suggests vanishing of first continuous cohomology with suitable finite $\ell$-primary coefficients.

By contrast, pro-$p$ groups possess finite quotients of order divisible by $p$. The cyclic group of order $p$ is the first such quotient, and its coordinate cocycle supplies a nonvanishing class. The finite example is therefore not an isolated curiosity; it is the local model for the obstruction that persists in infinite towers.

These distinctions matter in arithmetic geometry. Cohomology measures whether local symmetries glue globally, whether deformations are obstructed, and whether arithmetic objects admit canonical choices. In deformation theory, degree-one classes often describe infinitesimal deformations, while degree-two classes encode obstructions. In Selmer theory and Iwasawa theory, controlling cohomology over finite and profinite groups helps determine the size and structure of modules that track arithmetic information through infinite extensions.

## The lesson of the counterexample

The beauty of the construction lies in its economy. A one-dimensional vector space, a cyclic group, a trivial action, and the identity coordinate suffice. Each assumption can be seen directly, and each conclusion follows from one line of arithmetic:

$$
c(a+b)=a+b=c(a)+c(b).
$$

Yet this tiny mechanism draws a durable boundary. Prime-to-characteristic hypotheses in averaging theorems are not ceremonial technicalities. They separate a world where compatible affine displacements can always be centered from a world where displacement has irreducible memory.

Averaging succeeds when the number of symmetries can be divided away. When that number becomes zero, symmetry may carry information that no change of origin can erase. The cyclic coordinate cocycle is that information in its simplest form—and, because it exists for every prime, it marks the boundary with complete clarity.
