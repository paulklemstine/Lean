# The Lattice of Witnesses to Rainbow Forest Obstructions

## Abstract

An edge-colored graph admits a *total rainbow forest* of size $t$ — a set of $t$
edges that is simultaneously acyclic and rainbow (all colors distinct) — exactly
when two associated matroids, the graphic matroid $M_1$ and the partition matroid
$M_2$ of colors, share a common independent set of size $t$. By matroid
intersection duality, no such common independent set exists precisely when some
subset $A$ of the edge set $E$ certifies a failure of the **Rainbow Forest
Inequality**, $r_1(A) + r_2(E \setminus A) < t$, where $r_i$ is the rank function
of $M_i$. A natural conjecture asserts that for a minimal obstruction this
certifying subset $A$ is unique. We investigate this claim abstractly at the
level of matroid rank functions and reach a contrarian but precise verdict. The
uniqueness conjecture is **false**: we exhibit a two-element ground set with both
matroids equal to the uniform matroid $U_{1,2}$ for which two distinct subsets
attain the minimum. In its place we establish the correct structural theorem. The
objective $g(A) = r_1(A) + r_2(E \setminus A)$ is submodular; its minimizers are
closed under intersection and union and hence form a lattice; and consequently
there exist a *unique least* and a *unique greatest* witnessing subset. We also
show that the standard edge-deletion notion of minimality cannot restore
uniqueness, because the intersection number is monotone under deletion. All
results are derived from the four matroid rank axioms alone, with no reliance on
a pre-existing matroid theory.

**Keywords.** rainbow forest, matroid intersection, submodularity, rank function,
lattice of minimizers, weak duality, uniform matroid, combinatorial optimization.

---

## 1. Introduction

### 1.1 Rainbow forests and obstructions

Let $G = (V, E)$ be a graph whose edges are colored by a map
$c : E \to \{1, \dots, k\}$. A **total rainbow forest** is a set $I \subseteq E$
that is both a *forest* (contains no cycle) and *rainbow* (the coloring $c$ is
injective on $I$). Total rainbow forests package two independence demands that
recur throughout combinatorial optimization: a *structural* demand (acyclicity,
i.e. graphic independence) and a *diversity* demand (distinct colors, i.e.
one representative per color class). The basic algorithmic question is to find a
total rainbow forest of maximum size, or to certify that none of a given size $t$
exists.

Both demands are instances of the same abstraction. The forests of $G$ are the
independent sets of the **graphic matroid** $M_1$; the rainbow sets are the
independent sets of the **partition matroid** $M_2$ whose blocks are the color
classes. A total rainbow forest is thus exactly a *common independent set* of
$M_1$ and $M_2$, and the maximum-size problem is precisely **matroid
intersection**. This paper studies the *dual* side: the structure of the subsets
that certify impossibility.

### 1.2 The uniqueness conjecture

The research direction motivating this work proposed the following claim. If $G$
is a *minimal obstruction* to total rainbow forests of size $t$ — meaning no such
forest exists, but the instance is minimal in some appropriate sense — then the
certifying subset $A$ with $r_1(A) + r_2(E \setminus A) < t$ is **unique**: the
Rainbow Forest Inequality fails strictly for that subset and for no other.

We show this is false and identify the correct replacement: a full lattice
structure on the certifying subsets, with canonical least and greatest members.
The entire development is carried out at the level of abstract rank functions, so
the results apply to *any* pair of matroids on a common ground set, not merely
the graphic/partition pair.

### 1.3 Contributions

1. **The Rainbow Forest Inequality (weak duality), Theorem 3.1.** Every common
   independent set $I$ satisfies $|I| \le g(A)$ for every subset $A$, where
   $g(A) = r_1(A) + r_2(E \setminus A)$. No hypothesis on $A$ is required.
2. **Obstruction from a single witness, Theorem 3.2.** A single subset $A$ with
   $g(A) < t$ forbids every total rainbow forest of size $t$.
3. **Submodularity of the objective, Theorem 4.1.** $g$ is submodular.
4. **Lattice of witnesses, Theorems 4.2 and 4.3.** The minimizers of $g$ are
   closed under intersection and union.
5. **Least and greatest witnesses, Theorems 4.4 and 4.5.** There exist a unique
   smallest and a unique largest minimizing subset.
6. **Refutation of uniqueness, Theorems 5.1 and 5.2.** With both matroids equal to
   $U_{1,2}$ on a two-element ground set, the minimum is attained by two distinct
   subsets.
7. **Minimality does not help, Proposition 6.1 (discussion).** Under
   edge-deletion minimality, obstructions are downward closed, so the only
   edge-minimal obstruction is degenerate.

---

## 2. Preliminaries: matroid rank functions

We work with a finite ground type $\alpha$ with decidable equality; all sets are
finite subsets ("finsets") of $\alpha$. A *ground set* is a distinguished finset
$E$. We deliberately axiomatize matroids by their rank functions rather than
importing an external theory, keeping the development self-contained.

**Definition 2.1 (Matroid rank function).** A function
$r : \mathcal{P}_{\text{fin}}(\alpha) \to \mathbb{N}$ is a **matroid rank
function** if it satisfies the four axioms:

- **(R0) Normalization.** $r(\varnothing) = 0$.
- **(R1) Monotonicity.** $X \subseteq Y \implies r(X) \le r(Y)$.
- **(R2) Unit increase.** $r(X \cup \{e\}) \le r(X) + 1$ for every element $e$.
- **(R3) Submodularity.** $r(X \cup Y) + r(X \cap Y) \le r(X) + r(Y)$ for all
  $X, Y$.

Elements not in the intended ground set behave as *loops* (they may be adjoined
without ever increasing rank), so restricting attention to subsets of a fixed
$E$ loses nothing.

**Lemma 2.2 (Rank is bounded by cardinality).** For every finset $X$,
$r(X) \le |X|$.

*Proof.* Induct on $X$. The empty case is (R0). For the inductive step, if
$x \notin X$ then (R2) gives $r(X \cup \{x\}) \le r(X) + 1 \le |X| + 1 = |X \cup
\{x\}|$. $\qquad\blacksquare$

**Definition 2.3 (Independence).** A finset $I$ is **independent** (for $r$) if
$r(I) = |I|$.

**Lemma 2.4 (Hereditary property).** If $I$ is independent and $J \subseteq I$,
then $J$ is independent.

*Proof.* By Lemma 2.2, $r(J) \le |J|$. For the reverse bound, a standard
telescoping using (R2) shows $r(I) \le r(J) + |I \setminus J|$ for any
$J \subseteq I$ (adjoin the elements of $I \setminus J$ one at a time, each
raising rank by at most $1$). Since $I$ is independent, $|I| = r(I) \le r(J) + |I
\setminus J|$, and $|I| = |J| + |I \setminus J|$, so $|J| \le r(J)$. Combining,
$r(J) = |J|$. $\qquad\blacksquare$

The telescoping bound $r(Y) \le r(X) + |Y \setminus X|$ for $X \subseteq Y$ used
above is itself proved by induction on $|Y \setminus X|$, adjoining one element at
a time via (R2).

---

## 3. The Rainbow Forest Inequality

Fix a ground set $E$ and two matroid rank functions $r_1, r_2$ on $\alpha$. The
central object is the **matroid intersection objective**.

**Definition 3.0.** For $A \subseteq E$, define
$$g(A) = r_1(A) + r_2(E \setminus A).$$

**Theorem 3.1 (Rainbow Forest Inequality; weak duality).** Let $I \subseteq E$ be
a common independent set, i.e. $I$ is independent for both $r_1$ and $r_2$. Then
for *every* subset $A$,
$$|I| \le g(A) = r_1(A) + r_2(E \setminus A).$$

*Proof.* Partition $I$ by $A$: write $I = (I \cap A) \sqcup (I \setminus A)$, so
$$|I| = |I \cap A| + |I \setminus A|. \tag{$\ast$}$$
Since $I \cap A \subseteq I$ and $I$ is $r_1$-independent, Lemma 2.4 gives
$r_1(I \cap A) = |I \cap A|$; by monotonicity (R1), $|I \cap A| = r_1(I \cap A)
\le r_1(A)$. Since $I \setminus A \subseteq I$ and $I$ is $r_2$-independent, Lemma
2.4 gives $r_2(I \setminus A) = |I \setminus A|$; and $I \setminus A \subseteq E
\setminus A$ (because $I \subseteq E$), so by (R1),
$|I \setminus A| = r_2(I \setminus A) \le r_2(E \setminus A)$. Substituting both
bounds into $(\ast)$ yields $|I| \le r_1(A) + r_2(E \setminus A) = g(A)$.
$\qquad\blacksquare$

The bound requires no hypothesis on $A$; it holds for all $A$ simultaneously.
Taking the minimum over $A$ gives the weak-duality half of the matroid
intersection theorem: $\max_I |I| \le \min_A g(A)$.

**Theorem 3.2 (A single witness blocks all forests of a given size).** Suppose
some subset $A$ satisfies $g(A) < t$. Then there is no common independent set
$I \subseteq E$ with $|I| \ge t$.

*Proof.* If such an $I$ existed, Theorem 3.1 would give $t \le |I| \le g(A) < t$,
a contradiction. $\qquad\blacksquare$

Theorem 3.2 is the operational heart of the "obstruction" concept: a *single*
cut $A$ with small $g(A)$ is a complete, checkable certificate that no total
rainbow forest of size $t$ exists. We call any such $A$ a **witness** (to the
obstruction at level $t$).

---

## 4. Submodularity and the lattice of witnesses

### 4.1 Submodularity of the objective

**Theorem 4.1 (Submodularity of $g$).** For all $A, B \subseteq E$,
$$g(A \cup B) + g(A \cap B) \le g(A) + g(B).$$

*Proof.* Apply (R3) to $r_1$ with the pair $(A, B)$:
$$r_1(A \cup B) + r_1(A \cap B) \le r_1(A) + r_1(B).$$
Apply (R3) to $r_2$ with the pair $(E \setminus A, E \setminus B)$:
$$r_2\big((E\setminus A) \cup (E\setminus B)\big) + r_2\big((E\setminus A) \cap
(E\setminus B)\big) \le r_2(E\setminus A) + r_2(E\setminus B).$$
By De Morgan's laws on the ground set,
$(E\setminus A) \cap (E\setminus B) = E \setminus (A \cup B)$ and
$(E\setminus A) \cup (E\setminus B) = E \setminus (A \cap B)$. Substituting, the
second inequality becomes
$$r_2(E\setminus (A\cap B)) + r_2(E\setminus (A\cup B)) \le r_2(E\setminus A) +
r_2(E\setminus B).$$
Adding this to the $r_1$ inequality and regrouping the four terms into
$g(A\cup B) + g(A\cap B)$ on the left and $g(A) + g(B)$ on the right completes the
proof. $\qquad\blacksquare$

### 4.2 Minimizers form a lattice

**Definition 4.0 (Minimizer).** A subset $A \subseteq E$ is a **minimizer** of
$g$ if $g(A) \le g(B)$ for every $B \subseteq E$.

Since $\mathcal{P}(E)$ is finite and nonempty, a minimizer always exists (the
minimum of a natural-valued function over a finite nonempty domain is attained).
Let $m = \min_{B \subseteq E} g(B)$ denote the minimum value; the minimizers are
exactly the subsets with $g(A) = m$.

**Theorem 4.2 (Closure under intersection).** If $A$ and $B$ are minimizers, then
so is $A \cap B$.

*Proof.* By Theorem 4.1, $g(A \cup B) + g(A \cap B) \le g(A) + g(B) = m + m =
2m$. Both $g(A \cup B) \ge m$ and $g(A \cap B) \ge m$ by minimality of $m$. A sum
of two quantities each at least $m$ that is at most $2m$ forces both to equal $m$.
In particular $g(A \cap B) = m$, so $A \cap B$ is a minimizer. $\qquad\blacksquare$

**Theorem 4.3 (Closure under union).** If $A$ and $B$ are minimizers, then so is
$A \cup B$.

*Proof.* Identical to Theorem 4.2: the same inequality forces $g(A \cup B) = m$.
$\qquad\blacksquare$

Theorems 4.2 and 4.3 say the family
$\mathcal{M} = \{A \subseteq E : g(A) = m\}$ of witnesses of minimum value is a
**sublattice** of the Boolean lattice $(\mathcal{P}(E), \cap, \cup)$.

### 4.3 Least and greatest witnesses

**Theorem 4.4 (Unique least witness).** There is a unique minimizer $A_{\min}$
contained in every minimizer.

*Proof.* Among the finitely many minimizers, choose one, $A_0$, of minimum
cardinality. For any minimizer $A$, Theorem 4.2 makes $A_0 \cap A$ a minimizer,
and $A_0 \cap A \subseteq A_0$ gives $|A_0 \cap A| \le |A_0|$. Minimality of
$|A_0|$ forces $|A_0 \cap A| = |A_0|$, whence $A_0 \cap A = A_0$, i.e.
$A_0 \subseteq A$. Thus $A_{\min} = A_0$ is contained in every minimizer.
Uniqueness is automatic: any two minimizers each contained in all others must
contain each other, so are equal. $\qquad\blacksquare$

**Theorem 4.5 (Unique greatest witness).** There is a unique minimizer
$A_{\max}$ containing every minimizer.

*Proof.* Dually, choose a minimizer $A_0$ of *maximum* cardinality. For any
minimizer $A$, Theorem 4.3 makes $A \cup A_0$ a minimizer with $|A \cup A_0| \ge
|A_0|$; maximality forces $A \cup A_0 = A_0$, i.e. $A \subseteq A_0$. Hence
$A_{\max} = A_0$ contains every minimizer, and is unique. $\qquad\blacksquare$

Together, Theorems 4.4 and 4.5 constitute the **corrected form of the
conjecture**: not a single unique witness, but a lattice of witnesses with a
canonical smallest and largest member.

---

## 5. Refutation of the uniqueness conjecture

We now show the *original* uniqueness claim is false, at the smallest possible
scale. Recall the **uniform matroid** $U_{1,2}$: on a two-element ground set, a
set is independent iff it has at most one element. Its rank function is the
*indicator of non-emptiness*.

**Definition 5.0 (Indicator rank).** Define $\rho : \mathcal{P}_{\text{fin}}(\alpha)
\to \mathbb{N}$ by $\rho(A) = 0$ if $A = \varnothing$ and $\rho(A) = 1$
otherwise.

**Lemma 5.1 ($\rho$ is a matroid rank function).** $\rho$ satisfies (R0)–(R3).

*Proof.* (R0) is immediate. (R1) monotonicity: if $X \subseteq Y$ and $X$ is
nonempty then $Y$ is nonempty, so $\rho(X) \le \rho(Y)$ in all cases as both are
$0$ or $1$. (R2) unit increase: $\rho(X \cup \{e\}) \le 1 \le \rho(X) + 1$. (R3)
submodularity: check the finitely many cases on emptiness of $X, Y, X\cap Y,
X\cup Y$; in each the left side is at most the right side. $\qquad\blacksquare$

**Theorem 5.2 (Uniqueness fails).** There exist a ground set $E$, matroid rank
functions $r_1, r_2$, a target $t$, and two *distinct* subsets $A \ne B$ with
$A, B \subseteq E$ and
$$g(A) < t \quad\text{and}\quad g(B) < t.$$

*Proof.* Take $E = \{0, 1\}$, $r_1 = r_2 = \rho$, and $t = 2$. Compute $g$ on all
subsets (using $g(A) = \rho(A) + \rho(E \setminus A)$):
$$g(\varnothing) = 0 + 1 = 1,\quad g(\{0\}) = 1 + 1 = 2,\quad g(\{1\}) = 1 + 1 =
2,\quad g(\{0,1\}) = 1 + 0 = 1.$$
Both $A = \varnothing$ and $B = \{0,1\}$ satisfy $g = 1 < 2 = t$ and are distinct.
$\qquad\blacksquare$

**Theorem 5.3 (Minimizer non-uniqueness, sharpened).** In the same instance, the
two subsets $\varnothing$ and $\{0,1\}$ are *both minimizers* of $g$. Hence
uniqueness fails even at the exact minimum value $m = 1$.

*Proof.* From the table above, $\min_A g(A) = 1$, attained at exactly
$\varnothing$ and $\{0, 1\}$ (the singletons give $2$). Both are therefore
minimizers, and they are distinct. $\qquad\blacksquare$

This is fully consistent with the lattice theory of Section 4: here
$A_{\min} = \varnothing$ and $A_{\max} = \{0,1\}$, and the minimizer lattice is
the two-element chain $\{\varnothing, \{0,1\}\}$. The conjecture failed precisely
because it mistook a two-element lattice for a one-element one.

---

## 6. Discussion: why minimality cannot restore uniqueness

A natural rescue attempt is to demand a *minimal* obstruction, hoping that
tightness pins down a single witness. The most common formalization is
**edge-deletion minimality**: an obstruction $E$ is minimal if deleting any edge
destroys the obstruction (creates a rainbow forest of the target size).

**Proposition 6.1 (Monotonicity under deletion).** The intersection number
$\nu(E) = \min_{A \subseteq E} g(A) = \max\{|I| : I \text{ common independent},\,
I \subseteq E\}$ is monotone nondecreasing under adding edges — equivalently,
deleting an edge cannot increase $\nu$.

*Sketch.* Any common independent set of $E \setminus \{e\}$ is a common
independent set of $E$, so the maximum over the larger ground set is at least the
maximum over the smaller. Dually, on the certificate side, restricting a witness
$A$ to a smaller ground set does not increase $g$.

**Consequence.** If $E$ is an obstruction at level $t$ (i.e. $\nu(E) < t$), then
every subgraph $E' \subseteq E$ also has $\nu(E') \le \nu(E) < t$ and is an
obstruction. Obstructions are therefore *downward closed*, and the only
edge-minimal obstruction is the empty ground set — a degenerate object carrying no
information. Edge-minimality thus cannot single out a unique witness; it deletes
the entire structure. The honest, robust invariant is the lattice of witnesses of
Section 4, not a mythical unique cut.

---

## 7. Algorithms

The theory is constructive and yields simple algorithms.

**Algorithm A (Certificate check).** Given $E$, rank oracles $r_1, r_2$, target
$t$, and a candidate witness $A$: return "obstruction certified" iff
$r_1(A) + r_2(E \setminus A) < t$. Correct by Theorem 3.2; cost is two rank
evaluations.

**Algorithm B (Brute-force minimizer enumeration).** Enumerate all $A \subseteq
E$, evaluate $g(A)$, record the minimum value $m$ and the family
$\mathcal{M} = \{A : g(A) = m\}$. Then $A_{\min} = \bigcap \mathcal{M}$ and
$A_{\max} = \bigcup \mathcal{M}$. Correct by Theorems 4.2–4.5. Cost $O(2^{|E|})$
rank evaluations — exponential, but a ground truth for small instances and a
direct check of the lattice property.

**Algorithm C (Lattice extremes without full enumeration).** Because
$\mathcal{M}$ is closed under $\cap$ and $\cup$, one can find $A_{\min}$ and
$A_{\max}$ far faster than full enumeration via submodular minimization: minimize
the submodular function $g$ (polynomial in $|E|$ with a rank oracle), then use the
closure structure to grow/shrink to the extreme minimizers. In the graphic /
partition setting, $g$ is exactly the matroid-intersection dual objective, so
polynomial matroid-intersection machinery applies.

---

## 8. Applications

- **Network design with diversity.** Selecting a spanning skeleton whose links
  use distinct frequency bands, vendors, or routes is a total-rainbow-forest
  problem. Theorem 3.2 provides succinct impossibility certificates, and the
  lattice of witnesses locates the *tightest* structural bottleneck ($A_{\min}$)
  and the *broadest* one ($A_{\max}$).
- **Scheduling with resource classes.** Jobs (edges) constrained by an acyclic
  precedence structure and by one-per-class resource limits map to the same
  intersection problem; witnesses identify the binding constraints.
- **Combinatorial optimization pedagogy.** The example of Section 5 is a minimal,
  memorable illustration that submodular minima need not be unique, while the
  extreme minimizers always are.

---

## 9. Future directions

- **Alternative minimality.** Is there a *color*-deletion or *contraction*-based
  notion of minimal obstruction under which the least and greatest witnesses
  coincide? Characterize the matroid pairs for which
  $A_{\min} = A_{\max}$.
- **Strong duality.** Formalize matroid intersection strong duality
  ($\max_I |I| = \min_A g(A)$) to upgrade Theorem 3.2 to an equivalence.
- **Counting witnesses.** The witness family is a distributive lattice; relate the
  number of minimizers to the structure of the tight sets (a Dilworth-type
  count).
- **Weighted version.** Extend $g$ and the lattice results to weighted matroid
  intersection.

---

## 10. Conclusion

Starting from the four rank axioms alone, we established the Rainbow Forest
Inequality as weak duality, showed a single witness blocks all forests of a given
size, and proved that the witnessing objective $g$ is submodular. The
submodularity forces the minimizers into a lattice with unique least and greatest
elements — the correct, provable form of the uniqueness conjecture. The original
conjecture, taken literally, is false, as a two-element uniform-matroid instance
demonstrates, and edge-minimality cannot repair it. The lasting object is not a
unique cut but a lattice of cuts, canonically bracketed by its smallest and
largest members.
