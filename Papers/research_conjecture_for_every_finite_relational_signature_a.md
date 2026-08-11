# The Analogy Distance: An Attained Metric on Finite Probabilistic Transition Systems

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

We develop a quantitative theory of *approximate structural analogy* between finite
probabilistic transition systems and show that it is governed by a genuine, attained
metric. An $\varepsilon$-approximate structural analogy between two systems is a
bijection of world sets preserving atomic truth probabilities exactly and matching the
transported one-step kernels to within total variation $\varepsilon$. Our results are of
four kinds.

*Transport.* Along an $\varepsilon$-approximate analogy, the truth probability of any
modal formula of depth $d$ moves by at most $1-(1-\varepsilon)^d$. This geometric
modulus is attained for every depth and every $\varepsilon\in[0,1]$ by an explicit
two-state leaking family. The natural linear guess $d\varepsilon$ is a valid upper bound
(Bernoulli) but is *never* attained for $d\ge 2$ and $0<\varepsilon<1$, while agreeing
with the true modulus to first order, the discrepancy being at most
$\tfrac{d(d-1)}{2}\varepsilon^2$.

*Metric structure.* Approximate analogies form a groupoid graded by total variation:
identities are exact, inverses preserve the defect, and composition adds defects.
Defining $d(M,N)$ as the least admissible defect, we prove that the infimum is
**attained** — the optimisation ranges over the finitely many atom-preserving renamings —
so that an $\varepsilon$-approximate analogy exists precisely when $d(M,N)\le\varepsilon$.
The function $d$ takes values in $[0,1]$, satisfies the metric axioms, and has zero set
exactly the isomorphism relation; hence it is a genuine metric on isomorphism classes of
finite probabilistic systems on a fixed world set.

*Optimal continuity.* Combining the two, the map sending a system to its vector of
depth-$d$ truth probabilities is uniformly continuous for the analogy metric with modulus
$\omega_d(x)=1-(1-x)^d$, computed along the optimal renaming; the modulus is attained,
since the extremal family satisfies $d(\mathrm{exact},\mathrm{leaky}(\varepsilon))
=\varepsilon$.

*Resolution.* We delimit the observational cost of recovering structure. Modal
truth-probability equivalence is strictly coarser than structural analogy: two
deterministic two-world systems are modally identical yet at analogy distance $1$, and
adding graded (counting) modalities does not separate them, since counting is blind on
deterministic systems. Conversely, in nominal systems the naming bijection is forced and
$\eta$-agreement on the depth-one fragment already yields an $(n\eta/2)$-approximate
analogy, with the dimension factor $n/2$ optimal.

**Keywords.** probabilistic transition system, total variation distance, approximate
bisimulation, modal logic, structural analogy, metric groupoid, semantic holonomy,
Hennessy–Milner theorem.

---

## 1. Introduction

### 1.1 Motivation

Analogical transfer — reasoning about one system by reasoning about another that
resembles it — is ubiquitous and, in its exact form, well understood: if two structures
are isomorphic then every structural statement true of one is true of the other. What is
much less clear is the *approximate* case, which is the only case that arises in
practice. Two models are rarely renamings of each other; they are renamings of each other
up to a small perturbation of the transition probabilities. The questions are then:

1. How much does a small structural discrepancy corrupt a conclusion reached by $d$ steps
   of reasoning?
2. Is "nearly a renaming of" a metric notion, and if so is the optimal renaming ever
   realised, or only approached?
3. How much observational power is needed to reconstruct structure from behaviour?

This paper answers all three for finite probabilistic transition systems observed through
a real-valued modal language. The answers are, respectively: the error accumulates
geometrically and saturates; yes, and the optimum is attained by an explicit renaming;
and the answer depends sharply on the language, with a precise Lipschitz constant in the
favourable case and a genuine obstruction in the unfavourable one.

### 1.2 Overview of results

Section 2 fixes the framework. Section 3 establishes the transport theorem and its
sharpness. Section 4 develops the groupoid of approximate analogies. Section 5 — the
principal new contribution — constructs the analogy distance, proves attainment and the
metric axioms, identifies its zero set with isomorphism, and derives the optimal modulus
of continuity, together with an exact computation on the extremal family. Section 6 turns
to networks and semantic holonomy. Section 7 treats the resolution question: the negative
result on graded modalities and the sharp approximate Hennessy–Milner theorem in the
nominal case. Section 8 gives algorithms and complexity, Section 9 applications, and
Section 10 discussion and open problems.

---

## 2. Probabilistic modal structures

Throughout, $S$ is a finite nonempty set of *worlds* and $\iota$ an index set of *atomic
propositions*.

**Definition 2.1 (Probabilistic modal structure).** A *probabilistic modal structure*
$M$ on $S$ consists of

* a **transition kernel** $M.\mathrm{step} : S\times S\to\mathbb{R}$ with
  $M.\mathrm{step}(s,t)\ge 0$ for all $s,t$ and $\sum_{t\in S} M.\mathrm{step}(s,t)=1$
  for all $s$; and
* a **valuation** $M.\mathrm{val} : \iota\times S\to\mathbb{R}$ with
  $0\le M.\mathrm{val}(p,s)\le 1$ for all $p,s$.

We write $M(s,t)$ for $M.\mathrm{step}(s,t)$ and $V_M(p,s)$ for $M.\mathrm{val}(p,s)$.
Allowing $V_M$ to take intermediate values costs nothing and includes the classical
two-valued case.

**Definition 2.2 (Formulas and depth).** The set of *probabilistic modal formulas* over
$\iota$ is generated by
$$\varphi \;::=\; p \;\mid\; \neg\varphi \;\mid\; \varphi\wedge\psi \;\mid\; \bigcirc\varphi
\qquad (p\in\iota).$$
The *modal depth* is defined by $\operatorname{depth}(p)=0$,
$\operatorname{depth}(\neg\varphi)=\operatorname{depth}(\varphi)$,
$\operatorname{depth}(\varphi\wedge\psi)=\max(\operatorname{depth}\varphi,\operatorname{depth}\psi)$,
and $\operatorname{depth}(\bigcirc\varphi)=\operatorname{depth}(\varphi)+1$. We write
$\bigcirc^d\varphi$ for the $d$-fold application of $\bigcirc$; note
$\operatorname{depth}(\bigcirc^d\varphi)=d+\operatorname{depth}(\varphi)$.

**Definition 2.3 (Truth-probability semantics).** For a structure $M$ define
$\llbracket\cdot\rrbracket_M : \mathrm{Form}\to (S\to\mathbb{R})$ by
$$\llbracket p\rrbracket_M(s)=V_M(p,s),\qquad
\llbracket \neg\varphi\rrbracket_M(s)=1-\llbracket\varphi\rrbracket_M(s),$$
$$\llbracket \varphi\wedge\psi\rrbracket_M(s)=\min\bigl(\llbracket\varphi\rrbracket_M(s),\llbracket\psi\rrbracket_M(s)\bigr),\qquad
\llbracket \bigcirc\varphi\rrbracket_M(s)=\sum_{t\in S} M(s,t)\,\llbracket\varphi\rrbracket_M(t).$$

**Lemma 2.4.** For every $\varphi$ and $s$, $0\le\llbracket\varphi\rrbracket_M(s)\le 1$.

*Proof sketch.* Induction on $\varphi$. Atoms are in $[0,1]$ by hypothesis; negation and
min preserve $[0,1]$; and for $\bigcirc\varphi$, nonnegativity is immediate from
nonnegativity of the kernel, while
$\sum_t M(s,t)\llbracket\varphi\rrbracket_M(t)\le\sum_t M(s,t)\cdot 1=1$ by stochasticity.
$\square$

Thus $\llbracket\varphi\rrbracket_M$ is a genuine vector of probabilities, and the
modality is the one-step expectation operator of the kernel.

---

## 3. Approximate structural analogies and transport

### 3.1 The overlap defect

**Definition 3.1.** For $P,Q:S\to\mathbb{R}$ the *overlap defect* is
$$\mathrm{od}(P,Q) \;=\; 1-\sum_{t\in S}\min(P_t,Q_t).$$

**Lemma 3.2 (Overlap defect is total variation).** If $\sum_t P_t=\sum_t Q_t=1$ then
$$\mathrm{od}(P,Q)=\tfrac12\sum_{t\in S}|P_t-Q_t|.$$

*Proof sketch.* Pointwise, $|a-b|=a+b-2\min(a,b)$: check the two cases $a\le b$ and
$b\le a$. Summing and using $\sum P=\sum Q=1$ gives
$\sum_t|P_t-Q_t| = 2-2\sum_t\min(P_t,Q_t)=2\,\mathrm{od}(P,Q)$. $\square$

**Lemma 3.3.** For probability vectors $P,Q,R$: (i) $0\le\mathrm{od}(P,Q)\le 1$;
(ii) $\mathrm{od}(P,R)\le\mathrm{od}(P,Q)+\mathrm{od}(Q,R)$; (iii) $\mathrm{od}(P,Q)=0$
iff $P=Q$; (iv) $\mathrm{od}(P,Q)=\mathrm{od}(Q,P)$.

*Proof sketch.* (i) $\sum_t\min(P_t,Q_t)\le\sum_t P_t=1$ gives nonnegativity, and
nonnegativity of the minima gives the upper bound. (ii) By Lemma 3.2 it is the triangle
inequality for the $\ell^1$ norm applied termwise. (iii) By Lemma 3.2, vanishing forces
$\sum_t|P_t-Q_t|=0$, and a sum of nonnegative terms vanishes only if each does.
(iv) $\min$ is symmetric. $\square$

### 3.2 Approximate analogies

**Definition 3.4 ($\varepsilon$-approximate structural analogy).** Let $M$ be a structure
on $S$, $N$ a structure on $S'$, and $\varepsilon\in\mathbb{R}$. An
*$\varepsilon$-approximate structural analogy* $A:M\to N$ consists of a bijection
$f:S\to S'$ such that

1. **(atoms)** $V_N(p,f(s))=V_M(p,s)$ for all $p\in\iota$, $s\in S$; and
2. **(defect)** $\mathrm{od}\bigl(M(s,\cdot),\,N(f(s),f(\cdot))\bigr)\le\varepsilon$ for
   all $s\in S$.

Note that $t\mapsto N(f(s),f(t))$ is again a probability vector, since $f$ is a
bijection. Condition 2 says: after renaming, every row of the kernel of $M$ is within
total variation $\varepsilon$ of the corresponding row of $N$.

A $0$-approximate analogy is an **isomorphism** of probabilistic modal structures: by
Lemma 3.3(iii) the kernels then agree exactly after renaming.

### 3.3 The one-step estimate

The engine of the transport theorem is the following elementary inequality, which
quantifies how much a one-step expectation can move when both the measure and the
observable are perturbed.

**Lemma 3.5 (One-step estimate).** Let $P$ be a probability vector on $S$, $Q$ a
nonnegative vector, and $g,g':S\to\mathbb{R}$ with $g\le 1$ and $g'\ge 0$ pointwise.
Suppose $g(t)-g'(t)\le\delta$ for all $t$, with $\delta\le 1$, and
$\mathrm{od}(P,Q)\le\varepsilon$. Then
$$\sum_t P_t g(t)-\sum_t Q_t g'(t)\;\le\;\delta+\varepsilon(1-\delta).$$

*Proof sketch.* Put $m_t=\min(P_t,Q_t)$ and $M_0=\sum_t m_t\ge 1-\varepsilon$. Split
$$\sum_t P_tg(t)-\sum_t Q_tg'(t)
=\underbrace{\sum_t m_t\bigl(g(t)-g'(t)\bigr)}_{\le\, M_0\delta}
+\underbrace{\sum_t (P_t-m_t)g(t)}_{\le\, 1-M_0}
-\underbrace{\sum_t (Q_t-m_t)g'(t)}_{\ge\,0}.$$
The first bound uses $m_t\ge0$ and the hypothesis; the second uses $g\le1$ together with
$\sum_t(P_t-m_t)=1-M_0$; the third uses $Q_t\ge m_t$ and $g'\ge0$. Adding,
the total is at most $M_0\delta+(1-M_0)$, which is $\le\delta+\varepsilon(1-\delta)$
because $1-M_0\le\varepsilon$ and $\delta\le1$. $\square$

Interpretation: on the shared mass $M_0$ the two expectations differ by at most $\delta$;
on the disagreeing mass $1-M_0\le\varepsilon$ one can only use the trivial bound $1$
afforded by the range $[0,1]$ of the observables. Hence the error map
$$\delta\;\longmapsto\;\delta+\varepsilon(1-\delta) = 1-(1-\varepsilon)(1-\delta).$$

### 3.4 The transport theorem

**Theorem 3.6 (Quantitative transport).** Let $0\le\varepsilon\le1$ and let $A:M\to N$ be
an $\varepsilon$-approximate structural analogy with underlying bijection $f$. Then for
every formula $\varphi$ and every $s\in S$,
$$\bigl|\llbracket\varphi\rrbracket_M(s)-\llbracket\varphi\rrbracket_N(f(s))\bigr|
\;\le\; 1-(1-\varepsilon)^{\operatorname{depth}\varphi}.$$

*Proof sketch.* Induction on $\varphi$.

*Atoms.* Both sides are equal by the atomic condition, and the bound is
$1-(1-\varepsilon)^0=0$.

*Negation.* The difference changes sign only; depth is unchanged.

*Conjunction.* Use $|\min(a,b)-\min(a',b')|\le\max(|a-a'|,|b-b'|)$ and the monotonicity
of $d\mapsto 1-(1-\varepsilon)^d$ (valid for $0\le\varepsilon\le1$) to lift both inductive
bounds to the depth $\max(\operatorname{depth}\varphi,\operatorname{depth}\psi)$.

*Modality.* Let $\delta=1-(1-\varepsilon)^{\operatorname{depth}\varphi}$, which lies in
$[0,1]$. Setting $P_t=M(s,t)$, $Q_t=N(f(s),f(t))$, $g(t)=\llbracket\varphi\rrbracket_M(t)$,
$g'(t)=\llbracket\varphi\rrbracket_N(f(t))$, reindexing the sum defining
$\llbracket\bigcirc\varphi\rrbracket_N(f(s))$ along the bijection $f$, and applying
Lemma 3.5 in both directions (the hypotheses are symmetric under swapping the roles of
$(P,g)$ and $(Q,g')$, using $\mathrm{od}(Q,P)=\mathrm{od}(P,Q)$) yields
$$\bigl|\llbracket\bigcirc\varphi\rrbracket_M(s)-\llbracket\bigcirc\varphi\rrbracket_N(f(s))\bigr|
\le\delta+\varepsilon(1-\delta) = 1-(1-\varepsilon)^{\operatorname{depth}\varphi+1}. \square$$

**Corollary 3.7 (Linear form).** Under the same hypotheses,
$\bigl|\llbracket\varphi\rrbracket_M(s)-\llbracket\varphi\rrbracket_N(f(s))\bigr|
\le \operatorname{depth}(\varphi)\cdot\varepsilon$.

*Proof sketch.* Bernoulli's inequality $(1+x)^d\ge 1+dx$ with $x=-\varepsilon\ge-1$ gives
$1-(1-\varepsilon)^d\le d\varepsilon$. $\square$

**Corollary 3.8 (Exact transport).** A $0$-approximate analogy preserves all truth
probabilities: $\llbracket\varphi\rrbracket_M(s)=\llbracket\varphi\rrbracket_N(f(s))$ for
all $\varphi,s$.

### 3.5 Sharpness

**Definition 3.9 (The extremal family).** On $S=\{\mathsf F,\mathsf T\}$ with a single
atom $a$ satisfying $V(a,\mathsf T)=1$, $V(a,\mathsf F)=0$:

* the **exact system** $E$ has $E(\mathsf T,\mathsf T)=E(\mathsf F,\mathsf F)=1$ (both
  worlds absorbing);
* the **leaky system** $L_\varepsilon$ ($0\le\varepsilon\le1$) has
  $L_\varepsilon(\mathsf T,\mathsf T)=1-\varepsilon$,
  $L_\varepsilon(\mathsf T,\mathsf F)=\varepsilon$, and
  $L_\varepsilon(\mathsf F,\mathsf F)=1$.

**Lemma 3.10.** The identity map is an $\varepsilon$-approximate analogy
$E\to L_\varepsilon$, and its one-step overlap defect at $\mathsf T$ is exactly
$\varepsilon$ (and $0$ at $\mathsf F$).

**Lemma 3.11.** $\llbracket\bigcirc^d a\rrbracket_E(\mathsf T)=1$ and
$\llbracket\bigcirc^d a\rrbracket_{L_\varepsilon}(\mathsf T)=(1-\varepsilon)^d$, while
$\llbracket\bigcirc^d a\rrbracket_{L_\varepsilon}(\mathsf F)=0$.

*Proof sketch.* Both by induction on $d$. In $L_\varepsilon$ the world $\mathsf F$ is
absorbing with $a$ false, so its value is $0$ at every depth; hence the recursion at
$\mathsf T$ reads $x_{d+1}=(1-\varepsilon)x_d$ with $x_0=1$. $\square$

**Theorem 3.12 (Attainment of the geometric modulus).** For every $\varepsilon\in[0,1]$
and every $d\ge0$,
$$\bigl|\llbracket\bigcirc^d a\rrbracket_E(\mathsf T)-\llbracket\bigcirc^d a\rrbracket_{L_\varepsilon}(\mathsf T)\bigr|
=1-(1-\varepsilon)^d,$$
so the bound of Theorem 3.6 is attained at every depth.

**Theorem 3.13 (The linear bound is never attained beyond depth one).** For
$0<\varepsilon<1$ and $d\ge2$,
$$1-(1-\varepsilon)^d\;<\;d\,\varepsilon .$$

*Proof sketch.* Induction on $d$. For $d=2$, $d\varepsilon-(1-(1-\varepsilon)^2)
=\varepsilon^2>0$. For the step, write
$1-(1-\varepsilon)^{d+1}=\bigl(1-(1-\varepsilon)^d\bigr)+\varepsilon(1-\varepsilon)^d$
and use the inductive strict inequality together with $(1-\varepsilon)^d<1$. $\square$

**Theorem 3.14 (First-order sharpness).** For $0\le\varepsilon\le1$ and all $d\ge 0$,
$$d\,\varepsilon-\frac{d(d-1)}{2}\varepsilon^2\;\le\;1-(1-\varepsilon)^d,$$
equivalently $d\varepsilon-\bigl(1-(1-\varepsilon)^d\bigr)\le\frac{d(d-1)}{2}\varepsilon^2$.

*Proof sketch.* Induction on $d$. With $a_d=1-(1-\varepsilon)^d$ one has
$a_{d+1}=a_d+\varepsilon(1-a_d)$; combining the inductive hypothesis with the crude upper
bound $a_d\le d\varepsilon$ of Corollary 3.7 gives the required quadratic estimate after
elementary algebra. $\square$

Thus the conjecture that the modulus is $d\varepsilon$ is *confirmed as a bound*,
*refuted as an equality*, and *vindicated to first order*: the two moduli have equal
derivatives at $\varepsilon=0$, with discrepancy $O(d^2\varepsilon^2)$.

---

## 4. The metric groupoid of approximate analogies

**Proposition 4.1 (Groupoid structure).** Let $M,N,K$ be probabilistic modal structures.

1. **(Reflexivity)** The identity bijection is a $0$-approximate analogy $M\to M$.
2. **(Weakening)** If $A:M\to N$ is an $\varepsilon$-analogy and $\varepsilon\le
   \varepsilon'$, then $A$ is an $\varepsilon'$-analogy.
3. **(Symmetry)** If $A:M\to N$ is an $\varepsilon$-analogy with bijection $f$, then
   $f^{-1}$ is an $\varepsilon$-analogy $N\to M$.
4. **(Composition)** If $A:M\to N$ is an $\varepsilon_1$-analogy with bijection $f$ and
   $B:N\to K$ an $\varepsilon_2$-analogy with bijection $g$, then $g\circ f$ is an
   $(\varepsilon_1+\varepsilon_2)$-analogy $M\to K$.

*Proof sketch.* (1) The defect is $\mathrm{od}(P,P)=0$. (2) Immediate. (3) Reindex the
defect sum along $f$ and use symmetry of $\min$. (4) The atomic condition composes. For
the defect, fix $s$ and set $P_t=M(s,t)$, $Q_t=N(f(s),f(t))$, $R_t=K(g f(s),g f(t))$.
Then $\mathrm{od}(P,Q)\le\varepsilon_1$ directly, and $\mathrm{od}(Q,R)\le\varepsilon_2$
after reindexing $B$'s defect at $f(s)$ along $f$; conclude by Lemma 3.3(ii). $\square$

Thus, writing $\mathrm{Hom}_\varepsilon(M,N)$ for the set of $\varepsilon$-approximate
analogies, we have a groupoid whose arrows carry an additive $[0,1]$-valued grading given
by total variation, with identities of grade $0$ and grade-preserving inversion.

**Corollary 4.2 (Composite transport).** If $\varepsilon_1,\varepsilon_2\ge0$ with
$\varepsilon_1+\varepsilon_2\le1$, then along the composite analogy
$$\bigl|\llbracket\varphi\rrbracket_M(s)-\llbracket\varphi\rrbracket_K(g(f(s)))\bigr|
\le 1-\bigl(1-(\varepsilon_1+\varepsilon_2)\bigr)^{\operatorname{depth}\varphi}.$$

**Corollary 4.3 (Two-step holonomy bound).** If $A:M\to N$ and $B:N\to M$ are
$\varepsilon$-analogies with $2\varepsilon\le1$, then for all $\varphi$ and $s$,
$$\bigl|\llbracket\varphi\rrbracket_M(s)-\llbracket\varphi\rrbracket_M(g(f(s)))\bigr|
\le 1-(1-2\varepsilon)^{\operatorname{depth}\varphi}.$$
In particular, if both are exact then
$\llbracket\varphi\rrbracket_M(s)=\llbracket\varphi\rrbracket_M(g(f(s)))$: exact loops have
trivial semantic holonomy.

---

## 5. The analogy distance

This section contains the principal new results.

Fix a finite nonempty world set $S$ and consider probabilistic modal structures on $S$
(so that renamings are permutations of $S$).

**Definition 5.1 (Atom-preserving renamings).** For structures $M,N$ on $S$ let
$$\mathrm{AtomPerm}(M,N)=\{\,f\in\mathrm{Sym}(S)\;:\;V_N(p,f(s))=V_M(p,s)\ \text{for all }p,s\,\}.$$
This is a finite set, and every approximate analogy $M\to N$ has its bijection in it.

**Definition 5.2 (Cost of a renaming).** For $f\in\mathrm{Sym}(S)$,
$$\mathrm{cost}_{M,N}(f)\;=\;\max_{s\in S}\;\mathrm{od}\bigl(M(s,\cdot),\,N(f(s),f(\cdot))\bigr),$$
the worst-case one-step overlap defect produced by $f$.

**Lemma 5.3.** $0\le\mathrm{cost}_{M,N}(f)\le1$ for every $f$, and $f$ underlies an
$\varepsilon$-approximate analogy $M\to N$ if and only if
$f\in\mathrm{AtomPerm}(M,N)$ and $\mathrm{cost}_{M,N}(f)\le\varepsilon$.

*Proof sketch.* The bounds are Lemma 3.3(i) applied at the maximising world (the maximum
over a finite nonempty set is attained), and the characterisation is Definition 3.4 read
componentwise. $\square$

**Definition 5.4 (Analogy distance).**
$$d(M,N)\;=\;\begin{cases}
\displaystyle\min_{f\in\mathrm{AtomPerm}(M,N)}\mathrm{cost}_{M,N}(f), & \mathrm{AtomPerm}(M,N)\neq\emptyset,\\[2mm]
1, & \text{otherwise.}
\end{cases}$$
The convention in the degenerate case is harmless: if there is no atom-preserving
renaming there is no approximate analogy of any defect, and $1$ is the maximum possible
defect.

**Theorem 5.5 (Range).** $d(M,N)\in[0,1]$ for all $M,N$.

*Proof sketch.* In the first case, a minimum of quantities in $[0,1]$ over a nonempty
finite set (Lemma 5.3); in the second case it is $1$ by fiat. $\square$

**Theorem 5.6 (Attainment).** Suppose $\mathrm{AtomPerm}(M,N)\neq\emptyset$. Then there
is $f^\star\in\mathrm{AtomPerm}(M,N)$ with $\mathrm{cost}_{M,N}(f^\star)=d(M,N)$, and
$f^\star$ is an honest $d(M,N)$-approximate structural analogy $M\to N$.

*Proof sketch.* The minimum in Definition 5.4 is over a nonempty finite set, so it is
attained at some $f^\star$; and by Lemma 5.3 the defect condition at every world is
$\mathrm{od}(M(s,\cdot),N(f^\star(s),f^\star(\cdot)))\le\mathrm{cost}_{M,N}(f^\star)=d(M,N)$.
$\square$

This is the crux: because the atomic condition rigidifies the search space to a finite
set of candidates, the infimum defining $d$ is a *minimum*. Immediately:

**Theorem 5.7 (Least admissible defect).** If $\mathrm{AtomPerm}(M,N)\neq\emptyset$ then
for every $\varepsilon\in\mathbb{R}$,
$$\exists\,\varepsilon\text{-approximate analogy } M\to N \iff d(M,N)\le\varepsilon.$$

*Proof sketch.* ($\Rightarrow$) Its bijection lies in $\mathrm{AtomPerm}(M,N)$ and has
cost $\le\varepsilon$, so the minimum is $\le\varepsilon$. ($\Leftarrow$) Take the optimal
analogy of Theorem 5.6 and weaken (Proposition 4.1(2)). $\square$

### 5.1 The metric axioms

**Theorem 5.8.** For all structures $M,N,K$ on $S$:

1. $d(M,M)=0$;
2. $d(M,N)=d(N,M)$;
3. if $\mathrm{AtomPerm}(M,N)$ and $\mathrm{AtomPerm}(N,K)$ are nonempty then
   $d(M,K)\le d(M,N)+d(N,K)$.

*Proof sketch.* Each axiom is a groupoid operation applied to optimal analogies.

(1) The identity is a $0$-analogy $M\to M$ (Proposition 4.1(1)), so $d(M,M)\le0$;
nonnegativity gives equality.

(2) If $\mathrm{AtomPerm}(M,N)\neq\emptyset$ then so is $\mathrm{AtomPerm}(N,M)$, via
$f\mapsto f^{-1}$. Inverting the optimal analogy $M\to N$ (Proposition 4.1(3)) gives an
analogy $N\to M$ of defect $d(M,N)$, so $d(N,M)\le d(M,N)$; symmetrically for the
converse. If $\mathrm{AtomPerm}(M,N)=\emptyset$ then also
$\mathrm{AtomPerm}(N,M)=\emptyset$ and both sides equal $1$.

(3) Compose the optimal analogies $M\to N$ and $N\to K$ (Proposition 4.1(4)): the result
is an analogy $M\to K$ of defect $d(M,N)+d(N,K)$, and Theorem 5.7 concludes. $\square$

### 5.2 The zero set is isomorphism

**Definition 5.9 (Isomorphism).** An *isomorphism* $M\to N$ is a permutation $f$ of $S$
with $V_N(p,f(s))=V_M(p,s)$ for all $p,s$ and $N(f(s),f(t))=M(s,t)$ for all $s,t$.

**Theorem 5.10.** Suppose $\mathrm{AtomPerm}(M,N)\neq\emptyset$. Then
$$d(M,N)=0\iff M\text{ and }N\text{ are isomorphic}.$$

*Proof sketch.* ($\Leftarrow$) An isomorphism has all overlap defects
$\mathrm{od}(P,P)=0$, hence is a $0$-analogy, hence $d(M,N)\le0$.

($\Rightarrow$) Let $f^\star$ be the optimal renaming of Theorem 5.6. Its defect at each
$s$ is at most $d(M,N)=0$ and at least $0$, so
$\mathrm{od}\bigl(M(s,\cdot),N(f^\star(s),f^\star(\cdot))\bigr)=0$. Both arguments are
probability vectors (the second because $f^\star$ is a bijection), so by Lemma 3.3(iii)
they are equal: $N(f^\star(s),f^\star(t))=M(s,t)$ for all $t$. Since $f^\star$ also
preserves atoms, it is an isomorphism. $\square$

Hence $d$ separates points modulo isomorphism, and:

**Corollary 5.11.** $d$ descends to a genuine $[0,1]$-valued metric on the set of
isomorphism classes of probabilistic modal structures on a fixed finite world set $S$.

### 5.3 The optimal modulus of continuity

**Theorem 5.12 (Optimal transport bound).** Suppose $\mathrm{AtomPerm}(M,N)\neq\emptyset$
and let $f^\star$ be the optimal renaming. Then for every $\varphi$ and $s$,
$$\bigl|\llbracket\varphi\rrbracket_M(s)-\llbracket\varphi\rrbracket_N(f^\star(s))\bigr|
\;\le\;1-\bigl(1-d(M,N)\bigr)^{\operatorname{depth}\varphi},$$
and consequently also $\le\operatorname{depth}(\varphi)\cdot d(M,N)$.

*Proof sketch.* Apply Theorem 3.6 to the optimal analogy of Theorem 5.6, whose defect is
$d(M,N)\in[0,1]$ by Theorem 5.5; the linear form follows from Corollary 3.7. $\square$

**Corollary 5.13.** If $d(M,N)=0$ then $M$ and $N$ are modally indistinguishable along
$f^\star$: $\llbracket\varphi\rrbracket_M(s)=\llbracket\varphi\rrbracket_N(f^\star(s))$ for
all $\varphi,s$.

Theorem 5.12 says the map
$$\Phi_d:\;M\;\longmapsto\;\bigl(\llbracket\varphi\rrbracket_M\bigr)_{\operatorname{depth}\varphi\le d}$$
is uniformly continuous for $d(\cdot,\cdot)$, with modulus $\omega_d(x)=1-(1-x)^d$ in the
supremum norm. The next result shows the modulus cannot be improved.

**Theorem 5.14 (Exact distance on the extremal family).** For the family of
Definition 3.9 and any $\varepsilon\in[0,1]$,
$$d\bigl(E,\,L_\varepsilon\bigr)=\varepsilon .$$

*Proof sketch.* ($\le$) The identity is an $\varepsilon$-analogy (Lemma 3.10).
($\ge$) The atomic valuation distinguishes the two worlds ($a$ has value $1$ at
$\mathsf T$ and $0$ at $\mathsf F$), so the only atom-preserving permutation of
$\{\mathsf F,\mathsf T\}$ is the identity: $\mathrm{AtomPerm}(E,L_\varepsilon)=\{\mathrm{id}\}$.
Hence $d(E,L_\varepsilon)=\mathrm{cost}(\mathrm{id})\ge
\mathrm{od}\bigl(E(\mathsf T,\cdot),L_\varepsilon(\mathsf T,\cdot)\bigr)=\varepsilon$ by
Lemma 3.10. $\square$

**Corollary 5.15 (The modulus is exact).** For every $\varepsilon\in[0,1]$ and $d\ge0$
there are structures at analogy distance $\varepsilon$ and a formula of depth $d$ whose
truth probabilities differ by exactly $1-(1-\varepsilon)^d$. Hence $\omega_d$ is the
modulus of continuity of $\Phi_d$, not merely an upper envelope.

*Proof sketch.* Combine Theorems 5.14 and 3.12. $\square$

---

## 6. Networks of analogies and semantic holonomy

Practical analogical reasoning traverses networks, not single arrows. Let
$M_0,M_1,\dots$ be structures on a common world set and let $A_i$ be an
$\varepsilon_i$-approximate analogy $M_i\to M_{i+1}$.

**Proposition 6.1 (Defects add along a path).** For each $k$ the composite of the first
$k$ arrows is an approximate analogy $M_0\to M_k$ of defect
$\sum_{i<k}\varepsilon_i$.

*Proof sketch.* Induction on $k$ using Proposition 4.1(1) for $k=0$ and Proposition
4.1(4) with weakening for the step. $\square$

**Theorem 6.2 (Network transport).** If $\varepsilon_i\ge0$ for all $i$ and
$\sum_{i<k}\varepsilon_i\le1$, then along the composite,
$$\bigl|\llbracket\varphi\rrbracket_{M_0}(s)-\llbracket\varphi\rrbracket_{M_k}(F_k(s))\bigr|
\le 1-\Bigl(1-\sum_{i<k}\varepsilon_i\Bigr)^{\operatorname{depth}\varphi},$$
where $F_k$ is the composite bijection.

**Definition 6.3 (Semantic holonomy).** A *cycle* is a chain with $M_k=M_0$. Its
composite bijection $F_k$ is then a permutation of the worlds of $M_0$, and the *semantic
holonomy* of the cycle at $\varphi$ and $s$ is
$\bigl|\llbracket\varphi\rrbracket_{M_0}(s)-\llbracket\varphi\rrbracket_{M_0}(F_k(s))\bigr|$.

**Theorem 6.4 (Holonomy bound).** For a cycle as above the semantic holonomy at any
$\varphi,s$ is at most $1-\bigl(1-\sum_{i<k}\varepsilon_i\bigr)^{\operatorname{depth}\varphi}$,
and at most $\operatorname{depth}(\varphi)\cdot\sum_{i<k}\varepsilon_i$.

**Theorem 6.5 (Exact cycles are coherent).** If every $\varepsilon_i=0$ then
$\llbracket\varphi\rrbracket_{M_0}(s)=\llbracket\varphi\rrbracket_{M_0}(F_k(s))$ for all
$\varphi,s$. Consequently, if $I:S\to\mathbb{R}$ is an *interpretation* that factors
through modal theories — i.e. $\llbracket\varphi\rrbracket_{M_0}(s)=
\llbracket\varphi\rrbracket_{M_0}(t)$ for all $\varphi$ implies $I(s)=I(t)$ — then
$I(s)=I(F_k(s))$ for every $s$: meanings are globally coherent around the loop.

*Proof sketch.* The bound of Theorem 6.4 is $0$ when the total defect is $0$; the second
statement applies the hypothesis on $I$ to the pair $(s,F_k(s))$. $\square$

**Remark 6.6 (Non-vacuity).** The bound is not empty. Consider two structures on
$\{\mathsf F,\mathsf T\}$ with a single atom true only at $\mathsf T$: in the first, every
world moves to $\mathsf T$ with probability $1$; in the second, every world moves to
$\mathsf F$. The identity is a $1$-approximate analogy in both directions (the kernels are
mutually singular), and the depth-one observation $\bigcirc a$ has value $1$ in the first
and $0$ in the second. A two-arrow loop of total defect $1$ therefore destroys all
depth-one information: the holonomy bound is attained at total defect $1$.

Theorem 6.5 is the qualitative form of a coherence principle: a finite network of exact
analogies admits a globally consistent assignment of meanings, and the obstruction to
this in the approximate case is bounded by the accumulated defect around a cycle basis of
the network graph.

---

## 7. Observational resolution

Transport (Theorem 3.6) says structure controls observation. This section asks the
converse and locates the exact threshold.

### 7.1 The resolution gap

**Definition 7.1.** On $\{\mathsf F,\mathsf T\}$ with all atoms identically $1$, let
$\mathrm{Id}$ be the system in which each world has a self-loop, and $\mathrm{Sw}$ the
system in which the two worlds swap.

**Theorem 7.2 (Resolution gap).** Every modal formula has the same truth probability at
every world of $\mathrm{Id}$ and of $\mathrm{Sw}$; yet there is no $\varepsilon$-approximate
structural analogy between them with $\varepsilon<1$, i.e. $d(\mathrm{Id},\mathrm{Sw})=1$.

*Proof sketch.* Since every atom has value $1$ everywhere, one shows by induction that
$\llbracket\varphi\rrbracket$ is a constant function of the world in both systems, with
the same constant, because the kernels are stochastic and the semantics of $\bigcirc$
averages a constant. For the second half: both permutations of a two-element set preserve
the (constant) atomic valuation, so $\mathrm{AtomPerm}=\mathrm{Sym}(\{\mathsf F,\mathsf T\})$;
for either choice of $f$ the transported kernel of $\mathrm{Sw}$ is again the swap kernel,
whose rows are mutually singular with those of $\mathrm{Id}$, giving overlap defect $1$ at
every world. $\square$

So truth-probability equivalence is *strictly coarser* than structural analogy: the
transport theorem admits no converse.

### 7.2 Counting does not help

One might hope to close the gap with **graded modalities**: formulas $\nabla_k\varphi$
read "at least $k$ successors of positive probability satisfy $\varphi$", interpreted
two-valued (an atom holds where its truth probability is positive). Graded truth is
invariant under exact structural analogies, so the language is sound for classification.
But it is too weak.

**Theorem 7.3 (Counting is blind on deterministic systems).** Let $M,N$ be systems with
deterministic kernels (each world has exactly one successor of positive probability) and
constant atomic valuations, on arbitrary finite nonempty world sets and with arbitrary
successor functions. Then every graded formula has the same truth value at every world of
$M$ and of $N$.

*Proof sketch.* Induction on the graded formula. Atoms and Booleans are immediate from
constancy. For $\nabla_k\varphi$: each world has exactly one positive-probability
successor, so the count of successors satisfying $\varphi$ is $1$ if $\varphi$ holds at
that successor and $0$ otherwise; by the inductive hypothesis $\varphi$ has a constant
truth value across both systems, so the count is the same everywhere and $\nabla_k\varphi$
holds uniformly or fails uniformly, identically in both systems. $\square$

**Corollary 7.4.** The pair $(\mathrm{Id},\mathrm{Sw})$ is graded-equivalent yet at
analogy distance $1$: no graded language classifies pointed structures up to isomorphism.

**Remark 7.5 (What does separate them).** The observation distinguishing $\mathrm{Id}$
from $\mathrm{Sw}$ is not a counting one but the self-reference predicate
"$M(s,s)>0$" — a fixed-point property, invariant under exact analogies but inexpressible
by counting modalities. The missing resolution is therefore a fixed-point phenomenon, not
a multiplicity one.

### 7.3 The nominal case: sharp approximate Hennessy–Milner

**Definition 7.6 (Nominal structure).** A structure $M$ on $S$ with atom set $\iota=S$ is
*nominal* for a bijection $\kappa$ if $V_M(u,v)=1$ when $v=\kappa(u)$ and $0$ otherwise:
each world carries its own name.

**Proposition 7.7 (The naming bijection is forced).** If $M$ is nominal for the identity
and $N$ is nominal for $\kappa$, then every approximate analogy $M\to N$, of any defect,
has underlying bijection exactly $\kappa$.

*Proof sketch.* Apply the atomic condition to the atom $s$ at the world $s$: it reads
$V_N(s,f(s))=V_M(s,s)=1$, and $V_N(s,\cdot)$ is $1$ only at $\kappa(s)$. $\square$

Consequently the quantitative statements below cannot be improved by choosing a cleverer
bijection. Note also that in a nominal structure the depth-one observations are exactly
the kernel entries: $\llbracket\bigcirc\, u\rrbracket_M(s)=M(s,u)$.

**Theorem 7.8 (Approximate Hennessy–Milner theorem, nominal case).** Let $M,N$ be nominal
structures on $n=|S|$ worlds (for the identity and for $\kappa$ respectively) and suppose
$$\bigl|\llbracket\bigcirc\,u\rrbracket_M(s)-\llbracket\bigcirc\,u\rrbracket_N(\kappa(s))\bigr|\le\eta
\qquad\text{for all }u,s .$$
Then $\kappa$ is an $\bigl(n\eta/2\bigr)$-approximate structural analogy $M\to N$; hence,
provided $n\eta/2\le 1$, for every formula $\varphi$ and world $s$,
$$\bigl|\llbracket\varphi\rrbracket_M(s)-\llbracket\varphi\rrbracket_N(\kappa(s))\bigr|
\le 1-\bigl(1-n\eta/2\bigr)^{\operatorname{depth}\varphi}
\;\le\;\operatorname{depth}(\varphi)\cdot \frac{n\eta}{2}.$$

*Proof sketch.* The hypothesis says every kernel entry moves by at most $\eta$; summing
over the $n$ entries of a row gives $\sum_u|M(s,u)-N(\kappa(s),\kappa(u))|\le n\eta$, and
by Lemma 3.2 the overlap defect of the row is half of this, i.e. at most $n\eta/2$. Then
apply Theorem 3.6 and Corollary 3.7. $\square$

**Theorem 7.9 (Optimality of the dimension factor).** For every $m\ge1$, writing $n=2m$,
and every $\eta$ with $0\le\eta\le 1/(2m)$, there exist nominal structures $U$ (uniform)
and $T$ (tilted) on $n$ worlds such that

1. $\bigl|\llbracket\bigcirc\,u\rrbracket_U(s)-\llbracket\bigcirc\,u\rrbracket_T(s)\bigr|=\eta$
   for **every** pair $(u,s)$; and
2. every $\varepsilon$-approximate analogy $U\to T$ satisfies $\varepsilon\ge n\eta/2$.

*Proof sketch.* Take the world set $\{+,-\}\times\{1,\dots,m\}$, let $U$ have the uniform
kernel $U(s,t)=1/n$, and let $T(s,t)=1/n+\eta$ if $t$ is in the positive half and
$1/n-\eta$ otherwise (the admissibility hypothesis keeps $T$ nonnegative; both rows sum to
$1$ since the two halves have equal size). Both are nominal for the identity, so depth-one
observations are the kernel entries and (1) is immediate. For (2), the naming bijection is
forced (Proposition 7.7), and the overlap defect of a row is
$\sum_{t\in-}\eta=m\eta=n\eta/2$, since the minimum of the two entries is the smaller,
namely the $T$-entry on the negative half and the common value $1/n$ on the positive
half. $\square$

**Corollary 7.10.** Recovery of a finite nominal probabilistic structure from its
depth-one observations is Lipschitz from the $\ell^\infty$ observation metric to the
analogy metric, with Lipschitz constant exactly $n/2$.

---

## 8. Algorithms and complexity

Let $n=|S|$ and let $\iota$ be finite with $|\iota|=a$.

**Algorithm A (Overlap defect / row distance).** Given rows $P,Q\in\mathbb{R}^n$, return
$1-\sum_t\min(P_t,Q_t)$. Cost $\Theta(n)$. By Lemma 3.2 this equals
$\tfrac12\|P-Q\|_1$; the $\min$ form is preferable numerically since it avoids
cancellation for nearly identical rows.

**Algorithm B (Cost of a renaming).** Given $M,N,f$, return
$\max_s \mathrm{od}(M(s,\cdot),N(f(s),f(\cdot)))$. Cost $\Theta(n^2)$.

**Algorithm C (Analogy distance by exhaustive search).** Enumerate $f\in\mathrm{Sym}(S)$;
discard $f$ unless it preserves atoms (an $O(an)$ test); evaluate Algorithm B and keep the
minimum, together with the argmin. Cost $O(n!\,(an+n^2))$ worst case. Correctness is
Theorem 5.6: the minimum over this finite set *is* the distance, and the argmin *is* an
optimal analogy. The output is exact, not approximate.

In practice the atomic filter is a strong pruning device. Its effect is exactly to
restrict $f$ to permutations respecting the partition of $S$ into *atomic types* (worlds
with identical atomic valuation vectors): if the types have sizes $n_1,\dots,n_r$ then
$|\mathrm{AtomPerm}(M,N)|$ is either $0$ or $\prod_i n_i!$. In the nominal case all types
are singletons and there is exactly one candidate, so the distance is computed in
$\Theta(n^2)$.

**Algorithm D (Type-refined search).** Compute atomic types of $M$ and of $N$; if their
multisets of type sizes differ, return $1$ (no analogy exists). Otherwise enumerate only
the type-respecting bijections. Cost $O\bigl(\prod_i n_i!\cdot n^2\bigr)$ — a dramatic
improvement whenever the valuation is informative.

**Algorithm E (Certified transport bound).** Given $M,N,\varphi$: compute $d(M,N)$ and
$f^\star$ by Algorithm C or D, evaluate $\llbracket\varphi\rrbracket$ in both systems by
dynamic programming over subformulas — $\Theta(|\varphi|\,n^2)$ for the modal cases and
$\Theta(|\varphi|\,n)$ otherwise — and report the observed discrepancy alongside the
certified bound $1-(1-d(M,N))^{\operatorname{depth}\varphi}$.

**Algorithm F (Network holonomy audit).** Given a finite graph of systems with an
analogy on each edge, compute a spanning tree and a cycle basis; for each basis cycle sum
the local defects and report the holonomy bound
$1-(1-\sum\varepsilon_i)^{d}$ at the depth of interest. A cycle with total defect $0$ is
certified coherent (Theorem 6.5); a cycle whose bound exceeds a tolerance is flagged.
Cost is dominated by the $O(|E|)$ distance computations.

**Remark 8.1 (Hardness caveat).** Exact minimisation over renamings contains graph
isomorphism as the special case $d=0$ with $0/1$ kernels, so no polynomial algorithm
should be expected in full generality. The practical route is the type refinement of
Algorithm D combined with standard isomorphism-style partition refinement using
row-distance invariants.

---

## 9. Applications

**Model reduction with certified error.** Replacing a system $M$ by a simplified
surrogate $N$ on the same world set, the analogy distance yields an *a priori* guarantee:
every property expressible at depth $d$ has its probability preserved to within
$1-(1-d(M,N))^d$. Because the modulus saturates at $1$ rather than growing linearly, the
guarantee remains informative for far larger $d$ than the naive linear budget suggests.

**Auditing analogical inference.** When an argument transfers reasoning across a chain of
models, Theorem 6.2 provides an error budget that is additive in the local defects and
geometric in the depth. Theorem 6.4 turns loops in the network into an auditable
diagnostic: a cycle with large accumulated defect is exactly a place where "the same"
object receives inconsistent meanings.

**Sensitivity of Markov-chain queries.** Depth-$d$ formulas encode finite-horizon
queries: $\bigcirc^d p$ is a horizon-$d$ reachability probability, and conjunction with
negation builds finite-horizon safety and until-like properties. The transport theorem is
then a perturbation bound for such queries under row-wise total-variation perturbation of
the kernel — with the sharp constant, since Theorem 3.12 exhibits a chain attaining it.

**System identification.** Theorem 7.8 bounds how well a kernel can be reconstructed from
finite-horizon observations, and Theorem 7.9 shows the reconstruction constant $n/2$ is
unavoidable: to estimate a kernel to total-variation accuracy $\varepsilon$ one needs
entrywise observational accuracy $2\varepsilon/n$. That is a concrete statement about the
sample complexity of behavioural identification.

**Limits of behavioural testing.** Theorem 7.2 is a cautionary result for any pipeline
that infers structure from black-box behaviour: without world-identifying observations,
distinct structures can be behaviourally identical at every horizon. Theorem 7.3 shows
that enriching the tester with counting power does not help; the informative enrichment
is self-reference.

---

## 10. Discussion and future work

### 10.1 What the results say

Three theses emerge.

*Compounding is geometric.* The correct modulus for depth-$d$ transport is
$1-(1-\varepsilon)^d$, not $d\varepsilon$. The two agree to first order but diverge
where it matters: the geometric modulus respects the fact that truth probabilities live
in $[0,1]$, so error saturates rather than accumulating without bound. Any analysis whose
error budget can exceed $1$ has lost information that the geometric bound retains.

*Approximate sameness is metric, and the optimum is realised.* The passage from
"there exists an $\varepsilon$-analogy" to "the least such $\varepsilon$" is not a
limiting construction: the atomic condition confines the optimisation to finitely many
candidates, so the infimum is a minimum, witnessed by an explicit renaming. The metric
axioms then follow formally from the groupoid structure of analogies, and the zero set is
exactly isomorphism — the coarsest possible identification consistent with calling $d$ a
metric.

*Sameness depends on the observational language.* Structural analogy and modal
truth-probability equivalence are genuinely different, and the difference is visible in
two worlds. Counting modalities do not bridge the gap; naming does, at depth one, with a
sharp constant $n/2$.

### 10.2 Limitations

The analogy distance as defined compares structures on a *common* world set via
permutations. Systems of different sizes require either padding or a relational
(coupling-based) generalisation. The distance is also a *worst-case over worlds*
quantity; an averaged or initial-distribution-weighted variant would be less brittle. The
metric is bounded by $1$, so it cannot distinguish "very different" from "maximally
different" — mutually singular kernels are all at distance $1$. Finally, exact computation
is isomorphism-hard in general.

### 10.3 Open problems

1. **Couplings rather than bijections.** Replace the renaming by a coupling of world
   sets, obtaining a Kantorovich-style analogy distance defined between systems of
   different sizes. Is the infimum still attained, and is the transport modulus still
   $1-(1-\varepsilon)^d$?
2. **A behavioural metric.** Define $\rho(M,N)=\sup_\varphi\sup_s|\llbracket\varphi
   \rrbracket_M(s)-\llbracket\varphi\rrbracket_N(\sigma(s))|$ over some canonical
   correspondence $\sigma$. Theorem 7.2 gives pairs with $\rho=0<d=1$. Characterise the
   pairs where $\rho$ and $d$ agree, and quantify the gap.
3. **Fixed-point observations.** Remark 7.5 suggests enriching the language with
   self-reference. What is the exact expressive threshold at which observational
   equivalence coincides with $d(M,N)=0$?
4. **Discounted and averaged moduli.** For a discount factor $\gamma$ the natural modulus
   should be $\sum_{k<d}\gamma^k\varepsilon(1-\varepsilon)^{k}$-like. Determine the exact
   modulus in the discounted setting and the corresponding extremal family.
5. **Networks beyond cycle bases.** Formulate a groupoid-cohomological obstruction whose
   vanishing is equivalent to global coherence of meanings across a network of
   approximate analogies, and relate its norm to the maximum holonomy over a cycle basis.
6. **Statistical estimation.** Given samples from two systems rather than their exact
   kernels, estimate $d(M,N)$ with confidence intervals; combine Theorem 7.9 with
   concentration for total variation to obtain sample-complexity bounds.

### 10.4 Summary of the main results

| Statement | Content |
|---|---|
| Transport | depth-$d$ error $\le 1-(1-\varepsilon)^d$ along an $\varepsilon$-analogy |
| Sharpness | attained by the two-state leaking family at every depth |
| Linear bound | $\le d\varepsilon$ always; strict for $d\ge2$; sharp to first order |
| Groupoid | identities exact, inverses isometric, composition additive |
| Attainment | the infimum defining $d(M,N)$ is a minimum, with an explicit optimal renaming |
| Metric | $d\in[0,1]$, symmetric, triangle inequality, zero set $=$ isomorphism |
| Optimal continuity | modulus $1-(1-d(M,N))^{d}$, attained since $d(E,L_\varepsilon)=\varepsilon$ |
| Networks | defects add along paths; exact cycles have trivial semantic holonomy |
| Resolution gap | modally identical pair at analogy distance $1$; counting does not help |
| Nominal recovery | depth-one $\eta$-agreement $\Rightarrow$ $(n\eta/2)$-analogy, constant optimal |
