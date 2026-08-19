# Counting Necklaces Backwards: How Orbit Counts Remember Their Symmetries

## A question about shadows

Imagine you are handed a bead-stringing machine. It takes $n$ beads, each of one of $|X|$ possible colours, and produces a necklace — but a necklace is only "new" if it cannot be rotated, reflected, or otherwise shuffled into one you already have. The rules for what counts as "the same" are encoded in a symmetry group $G$ acting on the set $X$ of colours (or of positions, or of anything else you like).

The machine has an output counter. For each $n$ it tells you a single number: how many genuinely distinct necklaces of length $n$ there are. Call these numbers $N_0, N_1, N_2, \dots$. They are the *orbit counts* of the group acting diagonally on $n$-tuples, and packaged as a generating function

$$N(t) \;=\; \sum_{n \ge 0} N_n\, t^n$$

they are one of the oldest and most useful objects in combinatorics.

You never get to see the machine's internals. You cannot inspect the group, its multiplication table, or how the symmetries move colours around. You only see the sequence of counts.

Here is the question this article is about: **how much of the hidden symmetry can you reconstruct from the counter alone?**

The answer turns out to be startlingly precise. You can recover exactly one thing — a probability distribution — you can recover it from only finitely many counts, and there is an explicit, terminating algorithm that does it. Anything beyond that distribution is provably invisible, and we can exhibit the exact blind spot.

## Burnside's lemma, viewed sideways

The bridge between the two worlds is a nineteenth-century observation usually attributed to Burnside (and, more accurately, to Cauchy and Frobenius). For a finite group $G$ acting on a finite set $X$, write

$$X^g \;=\; \{x \in X : g \cdot x = x\}$$

for the set of points fixed by the group element $g$. Burnside's lemma says the number of orbits equals the average number of fixed points. Applied not to $X$ itself but to the set of $n$-tuples $X^{\times n}$ — where $g$ acts on a tuple coordinatewise, and where an element fixes a tuple precisely when it fixes every entry — it gives

$$|G| \cdot N_n \;=\; \sum_{g \in G} |X^g|^{\,n}.$$

Stare at the right-hand side. It is a **power sum**. If you sort the group elements by how many points they fix — say $\rho(v)$ is the fraction of group elements fixing exactly $v$ points — then dividing by $|G|$ turns Burnside's lemma into

$$N_n \;=\; \sum_{v=0}^{|X|} \rho(v)\, v^{\,n}.$$

That is to say: **the orbit count $N_n$ is the $n$-th moment of the fixed-point distribution $\rho$.**

The distribution $\rho$ deserves a name of its own. It is a genuine probability measure: it is nonnegative, it lives on the finitely many possible values $\{0, 1, \dots, |X|\}$, and its total mass is $1$ — a fact we get for free by taking $n = 0$ in the identity above, since there is exactly one orbit of empty tuples. Equivalently, $\rho$ is the *normalised* form of the **fixed-point $q$-series**

$$\Phi(q) \;=\; \sum_{g \in G} q^{\,|X^g|},$$

a polynomial that records, coefficient by coefficient, how many group elements fix how many points. The identity $\Phi \leftrightarrow \rho$ is nothing but dividing by $|G|$.

So the question "what do orbit counts remember?" has become a **moment problem**, and moment problems are something mathematicians know how to solve.

## The Molien picture

Before solving it, it is worth seeing the generating-function shape that Burnside's identity forces. Summing the geometric series $\sum_n a^n t^n = 1/(1 - at)$ term by term gives

$$|G| \cdot N(t) \;=\; \sum_{g \in G} \frac{1}{1 - |X^g|\, t}.$$

This is a *Molien-type formula*: exactly the same shape as Molien's classical series for invariants of a linear group, with fixed-point counts playing the role of eigenvalue data. In particular $N(t)$ is a rational function of $t$ whose poles sit at the reciprocals $1/|X^g|$ of the fixed-point counts, and whose residues encode how many elements fix each number of points. Clearing denominators, $\prod_{g}(1 - |X^g| t) \cdot |G| N(t)$ is an honest polynomial.

Seen this way, the reconstruction question is: *can you hear the poles and residues of a rational function from finitely many of its Taylor coefficients?*

## The rigidity theorem

Yes — and you need remarkably few.

> **Rigidity Theorem.** Let $G$ act on $X$ and $H$ act on $Y$, both finite. If the orbit counts agree in every degree $n \le \max(|X|, |Y|)$, then the two normalised fixed-point distributions are *identical*: $\rho_{G,X}(v) = \rho_{H,Y}(v)$ for every $v$. Conversely, if the distributions agree, then all the orbit counts agree, in every degree.

The proof is Lagrange interpolation, not group theory, and it is worth a moment. Both distributions live on the same finite set of nodes $S = \{0, 1, \dots, \max(|X|,|Y|)\}$, which has $|S| = \max(|X|,|Y|) + 1$ elements. Let $w(v) = \rho_{G,X}(v) - \rho_{H,Y}(v)$ be the difference — a *signed* weight on those nodes. The hypothesis says exactly that

$$\sum_{v \in S} w(v)\, v^{\,n} \;=\; 0 \qquad \text{for } n = 0, 1, \dots, |S| - 1.$$

Now fix a node $u$ and let $L_u$ be the Lagrange basis polynomial: the unique polynomial of degree $< |S|$ that equals $1$ at $u$ and $0$ at all other nodes. Then

$$w(u) \;=\; \sum_{v \in S} w(v)\, L_u(v),$$

and expanding $L_u$ in powers of $v$ writes the right-hand side as a linear combination of the vanishing power sums. So $w(u) = 0$. Every node, every weight — all zero.

That single argument, "$|S|$ vanishing power sums on $|S|$ distinct nodes force the weights to vanish", is the entire engine. Everything else is bookkeeping.

An immediate corollary is a **dichotomy** with no middle ground: for two actions of groups of the *same order*, either the fixed-point $q$-series coincide exactly, or the orbit-counting sequences already disagree at some degree $n \le \max(|X|,|Y|)$. Agreement on the first $\max(|X|,|Y|)+1$ coefficients is agreement forever. There is no pair of actions that mimics the other for a long time and then diverges late.

## Two boundaries, and why they are real

Rigidity theorems are only as interesting as their sharp edges, and this one has two, both of which are theorems rather than gaps.

**First: normalisation cannot be removed.** The orbit counts recover the *distribution* $\rho$, not the raw $q$-series $\Phi$. The reason is embarrassingly simple: Burnside's lemma divides by $|G|$, so the group order is invisible. Concretely, take the trivial group acting on a two-element set, and take the group of order $2$ acting trivially on the same two-element set. Every orbit count is $2^n$ in both cases. The distributions agree — both are the point mass at $v = 2$. But the $q$-series are $q^2$ and $2q^2$ respectively. They differ, and no amount of counting orbits will tell them apart.

**Second: the number of coefficients is genuinely needed.** One might hope $\max(|X|,|Y|)+1$ is a lazy bound. It is not, and the obstruction is a Vandermonde phenomenon. On the four nodes $\{0, 1, 2, 3\}$ the signed weight vector $(1, -3, 3, -1)$ — the alternating binomial coefficients — kills the power sums for $n = 0, 1, 2$:

$$1 - 3 + 3 - 1 = 0, \qquad 0 - 3 + 6 - 3 = 0, \qquad 0 - 3 + 12 - 9 = 0,$$

but at $n = 3$ it gives $0 - 3 + 24 - 27 = -6 \ne 0$. Three moments are not enough to see a difference supported on four nodes; the fourth catches it. Knowing $|S| - 1$ moments is genuinely not enough.

## From uniqueness to an algorithm

Uniqueness theorems tell you the answer exists. They do not hand it to you. The newer half of this story does: the reconstruction can be carried out, explicitly, in two quite different ways.

### The linear formula

Assemble the *moment matrix* on the nodes $0, 1, \dots, N$ (where $N = |X|$), whose $(n, j)$ entry is $j^{\,n}$. This is the transpose of the Vandermonde matrix of the nodes, and since the nodes $0, 1, \dots, N$ are distinct rational numbers, it is invertible. Call its inverse $C = C^{(N)}$ — a fixed rational matrix that depends on **nothing but the number $N$**.

> **Reconstruction Theorem.** For every value $v \le |X|$,
> $$\rho_{G,X}(v) \;=\; \sum_{n=0}^{|X|} C^{(|X|)}_{v,n} \cdot N_n.$$

Read that carefully. The coefficients do not depend on the group, on the action, or even on $|G|$. They are universal constants of the size of $X$. Feed in the first $|X|+1$ orbit counts, apply one fixed matrix, and out comes the entire fixed-point distribution. Rigidity is not just true; it is a linear map, and we know its matrix.

For instance, with $N = 2$ the inverse moment matrix on $\{0,1,2\}$ is

$$C^{(2)} \;=\; \begin{pmatrix} 1 & -\tfrac{3}{2} & \tfrac{1}{2} \\[2pt] 0 & 2 & -1 \\[2pt] 0 & -\tfrac{1}{2} & \tfrac{1}{2}\end{pmatrix},$$

so for any action on a two-element set, $\rho(2) = \tfrac{1}{2}(N_2 - N_1)$ — the fraction of group elements acting trivially is half the gap between the second and first orbit counts. For the two-element permutation group acting on two points, $N_1 = 1$ and $N_2 = 2$, giving $\rho(2) = 1/2$: exactly one of the two elements (the identity) acts trivially. Correct.

### The peeling recursion

The second method is more revealing about *why* the information is there. Suppose you want $\rho(m)$ for some $1 \le m \le |X|$, and you already know all the densities above $m$. Subtract their contributions from the $n$-th orbit count and divide by $m^n$:

$$P_m(n) \;=\; \frac{N_n - \sum_{v > m} \rho(v)\, v^{\,n}}{m^{\,n}} \;=\; \sum_{v \le m} \rho(v) \left(\frac{v}{m}\right)^{\! n}.$$

Every term with $v < m$ has ratio $v/m < 1$, so it decays geometrically; the term $v = m$ contributes exactly $\rho(m)$. Hence

$$\rho(m) \;=\; \lim_{n \to \infty} P_m(n).$$

This is the familiar principle that a positive combination of exponentials is eventually dominated by its largest base — the same principle that makes the leading term of an asymptotic expansion readable. Run it from the top down: get $\rho(|X|)$ first (where nothing needs subtracting), then $\rho(|X| - 1)$, and so on. The final value $\rho(0)$ needs no limit at all: it is forced by total mass, $\rho(0) = 1 - \sum_{v \ge 1} \rho(v)$.

The topmost peeling step has a pretty interpretation of its own. Taking $m = |X|$, nothing needs subtracting and we get

$$\frac{N_n}{|X|^{\,n}} \;\longrightarrow\; \frac{|K|}{|G|},$$

where $K$ is the *kernel* of the action — the set of elements that move nothing, i.e. those fixing all $|X|$ points. So the exponential growth rate of the orbit count is $|X|$, and the constant in front of $|X|^n$ is precisely the fraction of the group that acts trivially. As a special case, $N_n = |X|^n$ for all $n$ exactly when the action is trivial — and, remarkably, the single coefficient $n = 1$ already decides this.

### Limits you can actually finish

A limit is not an algorithm. But this one is, for two reasons that fit together beautifully.

First, the convergence rate is explicit. If the weights are nonnegative with total mass at most $1$ below $m$ — which they are, being probabilities — then

$$\bigl|P_m(n) - \rho(m)\bigr| \;\le\; \left(\frac{m-1}{m}\right)^{\! n}.$$

Second, the answer is not an arbitrary real number. Each density is a fraction with denominator dividing $|G|$: $\rho(m) = \#\{g : |X^g| = m\}/|G|$. A rational with known denominator is determined by any approximation good to within half a unit after scaling. Therefore:

> **Exact Finite Reconstruction.** As soon as $n$ is large enough that $\left(\frac{m-1}{m}\right)^{n} \cdot 2|G| < 1$, the integer nearest to $|G| \cdot P_m(n)$ is *exactly* the number of group elements fixing exactly $m$ points.

And such an $n$ always exists, because $(m-1)/m < 1$. The limit terminates. For $m = 1$ the error term is $0^n$ and $n = 1$ suffices immediately; for larger $m$ the required $n$ grows like $m \log |G|$. The asymptotic statement has become a finite computation with a stopping rule.

## The blind spot, exactly located

We now know precisely what orbit counts see: the fixed-point distribution, nothing less. What do they *not* see?

Consider a group acting on itself by left multiplication — the *regular* action, the most symmetric action a group has. Here the identity fixes everything and every other element fixes nothing at all, so the fixed-point $q$-series is $q^{|G|} + (|G|-1)$ and the orbit counts are $N_{n+1} = |G|^n$. Every one of these depends on $|G|$ *and nothing else*.

The consequence is stark. The cyclic group $\mathbb{Z}/4$ and the Klein four-group $\mathbb{Z}/2 \times \mathbb{Z}/2$, each acting on itself, have **identical fixed-point $q$-series and identical orbit counts in every single degree** — yet they are not isomorphic. So the rigidity theorem is optimal in the strongest possible sense: it determines the fixed-point distribution, and it can never be upgraded to determine the group. This is a theorem about the limits of the invariant, not a shortfall of the proof.

The mirror image is equally clean. If you know in advance that the two actions come from *one and the same group*, the normalisation ambiguity evaporates and rigidity upgrades from densities to raw counts: agreement of the first $\max(|X|,|Y|)+1$ orbit counts is *equivalent* to the multisets $\{|X^g|\}$ and $\{|Y^g|\}$ being equal.

## Why it matters

Three threads come together here.

**Combinatorics.** Pólya-style enumeration always runs "forwards": you know the group, you compute the counting series. This is the inverse problem, and it says the forward map is injective on the right invariant, with an explicit inverse. If you have empirical counts of equivalence classes — of necklaces, of chemical isomers, of colourings, of configurations in a physical model — you can extract the symmetry statistics of the hidden group without ever seeing it, and you need only as many data points as the underlying set has elements, plus one.

**Analysis.** The theorem is really a statement about the classical moment problem on a finite grid, and it inherits the moment problem's characteristic behaviour: uniqueness from finitely many moments, an ill-conditioned but explicit inversion (the Vandermonde matrix is famously ill-conditioned, which is exactly why the peeling recursion, with its clean geometric error bound and exact rounding step, is the better computational route), and a sharp boundary given by a signed weight vector.

**Invariant theory.** The Molien shape $\sum_g (1 - |X^g|t)^{-1}$ is a combinatorial echo of Molien's series for rings of invariants, and the story above works gradewise for graded families of finite sets — the combinatorial shadow of the graded modules that appear in moonshine-type correspondences. Two such graded families over groups of the same order have matching fixed-point $q$-series in every grade if and only if they have matching orbit counts in every grade.

## The shape of the answer

Strip away the machinery and the picture is simple, and, I think, rather beautiful. A group action casts two shadows: a $q$-series recording how the group's elements are distributed by their number of fixed points, and a counting sequence recording how many orbits appear on tuples. Burnside's lemma says the second shadow is the sequence of moments of the first. Because the first shadow is a probability measure on a finite grid, moments determine it — with an explicit matrix, with a geometrically convergent recursion, and with a rounding step that makes the recursion terminate.

What is lost is exactly one bit of scale (the group order) and exactly all of the group's internal structure. What survives is a probability distribution. Between those two facts there is no room left for anything else.
