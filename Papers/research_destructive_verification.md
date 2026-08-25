# Destructive Verification: Verdicts with a Residual State

**Author:** Aristotle

**Date:** 2026-08-25

---

## Abstract

Verification is conventionally modelled as a predicate: a checker consumes an
object and returns a Boolean. This model silently assumes that the object
survives the check, an assumption violated by destructive material testing,
state-collapsing measurement, and single-use consumable certificates. We model
verification instead as a **state transition** $t : D \to \mathbb{B} \times D$
on a type $D$ of *dishes*, returning both a **verdict** and a **residual
dish**, and we use the model to separate — by theorems rather than by
stipulation — three notions the predicate model conflates: *nondestructive*
tests (the dish is returned unchanged), *reversible* tests (the residue map is
a bijection) and *repeatable* tests (re-running on the residue reproduces the
verdict).

We prove that nondestructiveness implies both reversibility and repeatability,
that no further implication holds (all three inclusions are strict, witnessed
by explicit two-element counterexamples), and that the separation persists at
the level of closure properties: tests form a monoid under sequential
composition in which certificates form a commutative, idempotent submonoid
whose induced order is inclusion of accepted sets, while repeatable tests are
not closed under composition at all. Counting gives $(2n)^n$ tests, $2^n \cdot
n!$ reversible tests, and only $2^n$ certificates on $n$ dishes.

Iterating a test on its own residue produces a *transcript*, and here the
theory becomes sharply quantitative. We prove **transcript rigidity**: a
transcript constant on its first $n = |D|$ entries is constant forever, and
this is sharp — for every $k$ there is a test on $k+2$ dishes whose transcript
first changes at step $k+1$. We characterise the realisable transcripts exactly:
a Boolean stream is the transcript of a test on at most $n$ dishes iff it is
eventually periodic with $\text{preperiod} + \text{period} \le n$, giving a
state-complexity duality with a strict hierarchy at every level. We prove that
every test stabilises — on a finite dish type some batch length $N > 0$ makes
the residue idempotent, and on the stabilised core the original residue map is a
bijection, so destruction is confined to the transient. Finally we prove that
**observational equivalence is decided by $n$ runs**: two dishes whose
transcripts agree on the first $n$ entries agree forever. The proof combines a
minimal-recurrence analysis of orbits with the Fine–Wilf periodicity lemma from
combinatorics on words, and improves both the naive quadratic bound $n^2$ from
product dynamics and the intermediate linear bound $2n$. No hardness label of
any kind is assigned to any class.

**Keywords:** destructive testing, state transition, verification, transcript,
eventual periodicity, Fine–Wilf periodicity lemma, transformation monoid,
state complexity, orbit combinatorics.

---

## 1. Introduction

### 1.1 The missing residue

Let $D$ be a set of objects and $P \subseteq D$ a property. The classical model
of verification is a function $D \to \mathbb{B}$, where $\mathbb{B} =
\{\text{true}, \text{false}\}$, ideally with $t^{-1}(\text{true}) = P$. Almost
the entire theoretical apparatus around verification — decidability,
complexity classes, proof systems, zero knowledge — is phrased over this model.

The model encodes a physical hypothesis that is rarely stated: *checking is
free with respect to the object*. After the check, the object is available,
unchanged, for another check. This is true of a mathematical proof and false of
almost everything else. Tensile testing severs the specimen. Sterility testing
consumes the sample. A projective quantum measurement collapses the state.
A one-time authentication token is spent by its own verification. A wine is
tasted, a seal is broken, a fuse is blown.

The failure is not that the predicate model gives wrong answers; it is that it
cannot pose the questions. "May I run this battery in the other order?" "How
many identical verdicts entitle me to stop testing?" "Does this test destroy
the property it is checking?" None of these is expressible about a function
$D \to \mathbb{B}$.

### 1.2 The model

We replace the predicate by a state transition. All of the content of the paper
follows from this single change of type.

> **Definition 1 (Test).** A **test** on a type $D$ of **dishes** is a function
> $$t : D \longrightarrow \mathbb{B} \times D.$$
> We write $v_t(d) = \pi_1(t(d))$ for the **verdict** and $r_t(d) = \pi_2(t(d))$
> for the **residue**, so that $t(d) = (v_t(d), r_t(d))$. Two tests are equal
> iff they agree on all verdicts and all residues.

The predicate model is recovered as the special case $r_t = \mathrm{id}$. The
point of the paper is to measure how special that case is.

### 1.3 Contributions and organisation

Section 2 defines the taxonomy and proves the implications that hold.
Section 3 proves that no others do. Section 4 develops sequential composition
and the monoid structure, including the commutation theorem for certificates
and its failure for destructive tests. Section 5 counts. Section 6 introduces
transcripts and proves rigidity and the sharp depth hierarchy. Section 7 proves
stabilisation. Section 8 gives the exact characterisation of realisable
transcripts. Section 9 proves the distinguishing bound. Section 10 discusses
applications; Section 11 discusses limitations and open problems.

Throughout, $n$ denotes $|D|$ when $D$ is finite, $f^{[k]}$ denotes the $k$-fold
iterate of $f : D \to D$ (with $f^{[0]} = \mathrm{id}$), and $\mathbb{B}$
denotes the Booleans.

---

## 2. The taxonomy

> **Definition 2.** Let $t$ be a test on $D$.
>
> - $t$ is **nondestructive** (a *certificate check*) if $r_t(d) = d$ for all
>   $d \in D$.
> - $t$ is **reversible** if $r_t : D \to D$ is a bijection.
> - $t$ is **repeatable** if $v_t(r_t(d)) = v_t(d)$ for all $d \in D$.
> - $t$ is **destructive** if it is not nondestructive.
> - $t$ **decides** a property $P \subseteq D$ if $v_t(d) = \text{true}
>   \iff d \in P$, for all $d$.

Informally: nondestructive means *nothing happened to the dish*; reversible
means *something happened but no information was lost*; repeatable means *the
answer is stable under re-asking*. These are three genuinely different
demands — reversibility is about the residue map alone, repeatability couples
the residue map to the verdict, and nondestructiveness is a statement about the
residue map alone but a far stronger one.

> **Theorem 3 (Certificates are reversible).** If $t$ is nondestructive then
> $t$ is reversible.
>
> *Proof.* $r_t = \mathrm{id}_D$, which is a bijection. $\square$

> **Theorem 4 (Certificates are repeatable, in the strong sense).** If $t$ is
> nondestructive then for every $k \in \mathbb{N}$ and every $d \in D$,
> $$v_t\big(r_t^{[k]}(d)\big) = v_t(d).$$
> In particular $t$ is repeatable.
>
> *Proof.* Induction on $k$. For $k = 0$ this is trivial. For the step,
> $r_t^{[k+1]}(d) = r_t^{[k]}(r_t(d)) = r_t^{[k]}(d)$ since $r_t(d) = d$, and
> the induction hypothesis applies. $\square$

Theorem 4 is strictly stronger than repeatability, and the gap is exactly what
Sections 6–9 exploit: repeatability constrains one re-run, and it happens to
propagate, but only because the argument can be iterated.

> **Theorem 5 (Repeatability propagates along orbits).** If $t$ is repeatable
> then $v_t(r_t^{[k]}(d)) = v_t(d)$ for all $k$ and $d$.
>
> *Proof.* Induction on $k$, using $r_t^{[k+1]}(d) = r_t(r_t^{[k]}(d))$ and
> applying repeatability at the point $r_t^{[k]}(d)$, then the induction
> hypothesis. $\square$

The following result is the first genuinely informative interaction between the
verdict and the residue. It says that destruction is not forbidden by
repeatability but is *constrained* by it.

> **Theorem 6 (A repeatable test preserves what it decides).** Let $t$ be
> repeatable and suppose $t$ decides $P$. Then for every dish $d$,
> $$P(r_t(d)) \iff P(d).$$
>
> *Proof.* $P(r_t(d)) \iff v_t(r_t(d)) = \text{true} \iff v_t(d) = \text{true}
> \iff P(d)$, using the deciding hypothesis twice and repeatability once.
> $\square$

By contrast a nondestructive test preserves *every* property, not merely the
one it decides — which is a precise way of saying it does nothing at all.

---

## 3. Strictness: no further implication holds

Two dishes suffice to refute every implication not proved above. Take
$D = \mathbb{B}$ and define three tests.

$$\textbf{flip}(d) = (\text{true},\, \lnot d), \qquad
\textbf{readflip}(d) = (d,\, \lnot d), \qquad
\textbf{burn}(d) = (\text{true},\, \text{false}).$$

> **Proposition 7.** $\textbf{flip}$ is reversible and repeatable but
> destructive.
>
> *Proof.* Its residue is negation, an involution, hence a bijection; its
> verdict is constantly true, hence repeatable; and $r(\text{true}) =
> \text{false} \ne \text{true}$, hence destructive. $\square$

> **Proposition 8.** $\textbf{readflip}$ is reversible but not repeatable.
>
> *Proof.* Its residue is negation, a bijection. But $v(r(\text{true})) =
> v(\text{false}) = \text{false} \ne \text{true} = v(\text{true})$. $\square$

> **Proposition 9.** $\textbf{burn}$ is repeatable but not reversible (and is
> destructive).
>
> *Proof.* Its verdict is constant, hence repeatable. Its residue is constant,
> so it identifies $\text{true}$ and $\text{false}$ and is not injective.
> $\square$

> **Theorem 10 (Strict taxonomy).** On a two-element dish type:
> there is a reversible non-repeatable test; there is a repeatable
> non-reversible test; and there is a test that is both reversible and
> repeatable yet destructive. Hence none of the three classes is contained in
> another beyond the containments of Theorems 3 and 4.

The interpretation of Proposition 8 is worth stating: $\textbf{readflip}$ loses
no information whatsoever, and yet its second run contradicts its first. This is
the crisp combinatorial shadow of a measurement that is unitary — nothing lost —
but disturbing. Conversely, $\textbf{burn}$ is repeatable *precisely because*
its destruction is total and uniform: the answer is stable because it no longer
depends on anything.

---

## 4. Sequential composition: the verification monoid

Verification in practice is a battery. In the state-transition model,
composition is forced: run the first test, feed its residue to the second,
conjoin the verdicts.

> **Definition 11 (Sequential composition).** For tests $t_1, t_2$ on $D$,
> $$(t_1 \cdot t_2)(d) = \big(v_{t_1}(d) \wedge v_{t_2}(r_{t_1}(d)),\;
> r_{t_2}(r_{t_1}(d))\big).$$
> The **trivial certificate** is $\mathbf{1}(d) = (\text{true}, d)$.

Thus $v_{t_1 \cdot t_2} = v_{t_1} \wedge (v_{t_2} \circ r_{t_1})$ and
$r_{t_1 \cdot t_2} = r_{t_2} \circ r_{t_1}$.

> **Theorem 12 (Monoid).** $(\mathrm{Test}(D), \cdot, \mathbf{1})$ is a monoid:
> composition is associative and $\mathbf{1}$ is a two-sided identity.
>
> *Proof sketch.* Compare verdicts and residues separately. Residues compose as
> $r_{t_3} \circ r_{t_2} \circ r_{t_1}$ under either bracketing. Verdicts are
> $v_1(d) \wedge v_2(r_1 d) \wedge v_3(r_2 r_1 d)$ under either bracketing, by
> associativity of $\wedge$. The unit laws are immediate from $v_{\mathbf 1} =
> \text{true}$ and $r_{\mathbf 1} = \mathrm{id}$. $\square$

> **Theorem 13 (Closure).** Certificates are closed under composition, and so
> are reversible tests.
>
> *Proof.* If $r_1 = r_2 = \mathrm{id}$ then $r_2 \circ r_1 = \mathrm{id}$. If
> $r_1, r_2$ are bijections so is $r_2 \circ r_1$. $\square$

The next theorem is the sharpest form of the separation, and the reason the
predicate model can afford to be silent about order.

> **Theorem 14 (Certificates commute).** If $t_1, t_2$ are nondestructive then
> $t_1 \cdot t_2 = t_2 \cdot t_1$, as tests: equal verdicts on every dish and
> equal residues on every dish.
>
> *Proof.* Residues: both sides have residue $\mathrm{id}$. Verdicts: since
> $r_1(d) = r_2(d) = d$, the composite verdicts are $v_1(d) \wedge v_2(d)$ and
> $v_2(d) \wedge v_1(d)$, equal by commutativity of $\wedge$. $\square$

> **Theorem 15 (Destructive tests do not commute).** There exist tests
> $t_1, t_2$ on a two-element dish type with $t_1$ nondestructive, $t_2$
> destructive, and $t_1 \cdot t_2 \ne t_2 \cdot t_1$. Moreover the two
> composites differ *in the verdict*, not merely in the residue.
>
> *Proof.* Let $t_1(d) = (d, d)$ be the certificate that reports the dish and
> $t_2 = \textbf{burn}$. Then $(t_1 \cdot t_2)(\text{true})$ has verdict
> $\text{true} \wedge \text{true} = \text{true}$, while
> $(t_2 \cdot t_1)(\text{true})$ has verdict $\text{true} \wedge
> v_{t_1}(\text{false}) = \text{false}$. $\square$

Since the two composites differ in the verdict function alone, the order of a
battery containing a destructive test is *observable to the verifier*, not
merely to a bookkeeper tracking the specimen. A battery of $m$ tests can
therefore exhibit up to $m!$ distinct behaviours; a battery of certificates
exhibits exactly one.

### 4.1 The algebra of certificates

Restricted to certificates, the monoid degenerates to a familiar object.

> **Theorem 16 (Certificates form a Boolean semilattice).** For nondestructive
> $c, c_1, c_2$:
> 1. $c \cdot c = c$ (idempotence);
> 2. $v_{c_1 \cdot c_2}(d) = v_{c_1}(d) \wedge v_{c_2}(d)$ (composition is
>    pointwise conjunction);
> 3. $c_1 \cdot c_2 = c_1 \iff \{d : v_{c_1}(d)\} \subseteq
>    \{d : v_{c_2}(d)\}$ (the induced absorption order is inclusion of
>    accepted sets).
>
> *Proof sketch.* (1) and (2) are immediate from $r = \mathrm{id}$ and Theorem
> 14's computation. For (3): if $c_1 \cdot c_2 = c_1$ then evaluating verdicts
> at an accepted $d$ gives $v_{c_1}(d) \wedge v_{c_2}(d) = v_{c_1}(d) =
> \text{true}$, forcing $v_{c_2}(d) = \text{true}$. Conversely, inclusion makes
> the conjunction collapse to $v_{c_1}$ pointwise, and both residues are the
> identity. $\square$

So the certificate sub-poset is exactly the Boolean lattice $2^D$ with
$\mathbf 1$ on top, and the verification monoid is a genuinely non-commutative
extension of it. Idempotence is a clean dividing line:

> **Theorem 17 (Destruction breaks idempotence).** There is a destructive test
> $t$ with $t \cdot t \ne t$; indeed $\textbf{readflip} \cdot \textbf{readflip}$
> and $\textbf{readflip}$ differ in verdict at $\text{true}$.

### 4.2 Reversibility equals restorability

Reversibility was defined as a property of the residue map. It has an exact
algebraic characterisation inside the monoid.

> **Theorem 18 (Reversible $=$ restorable).** Let $D$ be finite and $t$ a test.
> Then $t$ is reversible if and only if there exists a test $u$ with
> $t \cdot u$ nondestructive.
>
> *Proof.* ($\Rightarrow$) If $r_t$ is a bijection with inverse $g$, take
> $u(d) = (\text{true}, g(d))$; then $r_{t \cdot u} = g \circ r_t =
> \mathrm{id}$. ($\Leftarrow$) If $r_u \circ r_t = \mathrm{id}$ then $r_t$ is
> injective, and an injective self-map of a finite set is a bijection.
> $\square$

Thus "no information lost" and "can be undone by a follow-up test" are the same
condition. The burn test is not restorable by any follow-up whatsoever; the flip
test is restorable, though not by itself.

### 4.3 Repeatability is not compositional

The final closure result is a negative one, and it is what makes repeatability
a genuinely different kind of property from the other two.

> **Theorem 19 (Repeatable tests are not closed under composition).** There
> exist repeatable tests $t_1, t_2$ on a two-element dish type — with $t_1$ even
> a certificate — such that $t_1 \cdot t_2$ is not repeatable.
>
> *Proof.* Let $t_1(d) = (d,d)$ (a certificate, hence repeatable) and
> $t_2 = \textbf{flip}$ (repeatable by Proposition 7). Their composite has
> verdict $v(d) = d \wedge \text{true} = d$ and residue $r(d) = \lnot d$, i.e.
> it is $\textbf{readflip}$, which is not repeatable by Proposition 8.
> $\square$

Certificates form a submonoid; reversible tests form a submonoid (indeed a
group-like part, by Theorem 18); repeatable tests form neither. This is a
closure-property separation, strictly finer than the pointwise separation of
Section 3.

---

## 5. Counting

> **Theorem 20 (Census).** Let $|D| = n$. Then:
> 1. there are exactly $(2n)^n$ tests on $D$;
> 2. there are exactly $2^n$ nondestructive tests;
> 3. there are exactly $2^n \cdot n!$ reversible tests.
>
> *Proof.* (1) A test is a function $D \to \mathbb{B} \times D$ and
> $|\mathbb{B} \times D| = 2n$. (2) The map sending a certificate to its verdict
> function is a bijection onto $D \to \mathbb{B}$: the residue is determined
> (it is the identity), and every verdict function arises. (3) The map sending
> a reversible test to the pair (verdict function, residue permutation) is a
> bijection onto $(D \to \mathbb{B}) \times \mathfrak{S}_D$. $\square$

> **Corollary 21.** For $n \ge 2$, $2^n < (2n)^n$, with ratio $n^n$. The
> certificates are an exponentially small minority of tests, and they are
> exactly the slice of the reversible tests on which the permutation is
> trivial.

The census is not merely decorative: it says the classical predicate model
parameterises $2^n$ of $(2n)^n$ possible verification behaviours, and the
remaining structure — the residue permutation, and beyond it the non-injective
residue maps — is where every phenomenon in the rest of this paper lives.

---

## 6. Transcripts, rigidity, and destruction depth

Because a test returns a dish, it can be re-run on its own output. The
observable produced is a Boolean stream.

> **Definition 22 (Transcript).** The **transcript** of a test $t$ on a dish
> $d$ is
> $$T_{t,d}(k) = v_t\big(r_t^{[k]}(d)\big), \qquad k \in \mathbb{N}.$$

> **Proposition 23.** $t$ is repeatable $\iff$ every transcript of $t$ is
> constant.
>
> *Proof.* ($\Rightarrow$) Theorem 5. ($\Leftarrow$) Take $k = 1$ at an
> arbitrary dish. $\square$

So the three classes are already visible in transcript terms; the question is
how *fast* they become visible. The engine is a finiteness lemma about orbits.

> **Lemma 24 (Orbit lemma).** Let $D$ be finite with $|D| = n$, let
> $f : D \to D$ and $d \in D$. Then for every $m \in \mathbb{N}$ there is
> $j < n$ with $f^{[m]}(d) = f^{[j]}(d)$.
>
> *Proof sketch.* Among $f^{[0]}(d), \ldots, f^{[n]}(d)$ — that is $n+1$
> values — two coincide, giving a recurrence $f^{[i+p]}(d) = f^{[i]}(d)$ with
> $p > 0$ and $i + p \le n$. Then $f^{[i]}(d)$ is a periodic point of period
> $p$, so for $m \ge i$ we may reduce the excess modulo $p$: $f^{[m]}(d) =
> f^{[\,i + ((m-i) \bmod p)\,]}(d)$, and $i + ((m-i) \bmod p) < i + p \le n$.
> For $m < i$ take $j = m$. $\square$

> **Theorem 25 (Transcript rigidity).** Let $|D| = n$, let $t$ be a test and
> $d$ a dish. If $T_{t,d}(j) = T_{t,d}(0)$ for all $j < n$, then
> $T_{t,d}(m) = T_{t,d}(0)$ for all $m$.
>
> *Proof.* Given $m$, Lemma 24 supplies $j < n$ with $r_t^{[m]}(d) =
> r_t^{[j]}(d)$; apply $v_t$ and use the hypothesis at $j$. $\square$

Contrapositively: if a transcript ever changes, it changes within the first $n$
runs. Define the **destruction depth** of $(t,d)$ to be the least $m$ with
$T_{t,d}(m) \ne T_{t,d}(0)$, or $\infty$ if none exists. Theorem 25 says the
depth is either infinite or $< n$. The bound is attained at every value below
$n$.

> **Definition 26 (Fuse test).** For $k \in \mathbb{N}$ define the test
> $\textbf{fuse}_k$ on the dish type $\{0, 1, \ldots, k+1\}$ by
> $$\textbf{fuse}_k(j) = \big(\,[\,j \le k\,],\; \min(j+1,\, k+1)\,\big).$$
> The dish advances one notch per run and sticks at the last notch, where the
> verdict flips: a burning fuse.

> **Lemma 27.** $T_{\textbf{fuse}_k,\,0}(m) = [\,m \le k\,]$ for all $m$.
>
> *Proof.* By induction, the $m$-th iterate of the residue map applied to $0$
> is $\min(m, k+1)$; the verdict at position $\min(m,k+1)$ is $[\min(m,k+1) \le
> k]$, which equals $[m \le k]$. $\square$

> **Theorem 28 (Sharp depth hierarchy).** For every $k$ there is a test on
> $n = k+2$ dishes and a dish $d$ with
> $$T(j) = T(0) \text{ for all } j \le k = n - 2, \qquad T(n-1) \ne T(0).$$
> Combined with Theorem 25: on $n$ dishes, every destruction depth $< n$ is
> realised and no depth $\ge n$ is. The horizon $n$ is exact.

An immediate operational corollary concerns *batches*. Write $t^{\langle m
\rangle}$ for the test "run $t$ exactly $m$ times, accepting iff every run
accepted"; formally $t^{\langle 0 \rangle} = \mathbf 1$ and $t^{\langle m+1
\rangle} = t^{\langle m \rangle} \cdot t$. Then $r_{t^{\langle m \rangle}} =
r_t^{[m]}$ and $v_{t^{\langle m \rangle}}(d) = \text{true}$ iff $T_{t,d}(j) =
\text{true}$ for all $j < m$.

> **Theorem 29 (Finite testing certifies infinite testing).** Let $|D| = n$. If
> $v_{t^{\langle n \rangle}}(d) = \text{true}$ then
> $v_{t^{\langle m \rangle}}(d) = \text{true}$ for every $m$.
>
> *Proof.* Immediate from the batch verdict formula and Lemma 24. $\square$
>
> By Theorem 28 the constant $n$ cannot be replaced by $n-1$.

---

## 7. Stabilisation: destruction is confined to the transient

> **Lemma 30 (Idempotent iterate).** For any self-map $f$ of a finite set there
> is $N > 0$ with $f^{[N]} \circ f^{[N]} = f^{[N]}$.
>
> *Proof sketch.* The sequence $(f^{[m]})_m$ of self-maps takes finitely many
> values, so $f^{[i]} = f^{[j]}$ for some $i < j$; put $p = j - i > 0$. Then
> $f^{[m+p]} = f^{[m]}$ for all $m \ge i$, hence $f^{[m + cp]} = f^{[m]}$ for
> all $c$ and all $m \ge i$. Take $N = p(i+1)$: then $N \ge i$ and
> $N + N = N + (i+1)p$, so $f^{[2N]} = f^{[N]}$. $\square$

> **Theorem 31 (Stabilisation).** For every test $t$ on a finite dish type
> there is a batch length $N > 0$ such that
> $$r_{t^{\langle N \rangle}} \circ r_{t^{\langle N \rangle}} =
> r_{t^{\langle N \rangle}}.$$
> Consequently $t^{\langle N \rangle}$ is nondestructive on its own image: every
> dish in the range of $r_{t^{\langle N \rangle}}$ is returned unchanged by the
> batch. Repeatable, indeed *nondestructive*, verification is always attainable
> at the cost of finitely many preparatory runs.

The strongest form of this concerns the original test, not the batch.

> **Theorem 32 (Reversibility on the core).** For every test $t$ on a finite
> dish type there is $N > 0$ such that $r_t$ restricts to a **bijection** of the
> stabilised core $C = \mathrm{range}(r_t^{[N]})$ onto itself.
>
> *Proof sketch.* Choose $N = M+1$ idempotent as in Lemma 30 and write
> $f = r_t$. Every $x \in C$ satisfies $f^{[N]}(x) = x$. Then: $f$ maps $C$
> into $C$ because $f$ commutes with its own iterates; $f$ is injective on $C$
> because $f^{[M]}$ is a left inverse there ($f^{[M]}(f(x)) = f^{[N]}(x) = x$);
> and $f$ is surjective onto $C$ because $f^{[M]}(x) \in C$ and
> $f(f^{[M]}(x)) = f^{[N]}(x) = x$. $\square$

Interpretation: **whatever a test destroys, it destroys on the way in.** Once
the dish space has settled onto its core, the same test is reversible there.
This is the mathematics of burn-in, break-in periods and pre-conditioning: run
the procedure enough times and the procedure stops costing anything.

---

## 8. Which verdict streams are realisable? A state-complexity duality

Theorem 25 says transcripts cannot be arbitrary. We now determine them exactly.

> **Theorem 33 (Analysis).** Let $|D| = n$. Every transcript $T_{t,d}$ is
> eventually periodic: there are $i \ge 0$ and $p > 0$ with $i + p \le n$ and
> $T_{t,d}(m + p) = T_{t,d}(m)$ for all $m \ge i$.
>
> *Proof.* Take the pigeonhole recurrence $r_t^{[i+p]}(d) = r_t^{[i]}(d)$ with
> $i + p \le n$ from Lemma 24's proof; a recurrence propagates forward
> ($f^{[m+p]}(d) = f^{[m]}(d)$ for all $m \ge i$, by writing $m + p = (m-i) +
> (i+p)$), and applying $v_t$ gives the claim. $\square$

The converse is completely explicit.

> **Definition 34 (Rho test).** Let $i \ge 0$, $p > 0$ and let $u : \mathbb{N}
> \to \mathbb{B}$. On the dish type $\{0, 1, \ldots, i+p-1\}$ define the **rho
> map**
> $$\rho(j) = \begin{cases} j + 1 & \text{if } j + 1 < i + p, \\ i &
> \text{otherwise,}\end{cases}$$
> — a tail $0 \to 1 \to \cdots \to i+p-1$ feeding back to position $i$, i.e. a
> transient of length $i$ followed by a cycle of length $p$ (the classical
> "$\rho$" shape) — and the **rho test** $\rho_u(j) = (u(j), \rho(j))$.

> **Theorem 35 (Synthesis).** If $u$ satisfies $u(m+p) = u(m)$ for all
> $m \ge i$, then $T_{\rho_u,\,0}(m) = u(m)$ for every $m$: the rho test on
> $i+p$ dishes realises $u$ exactly.
>
> *Proof sketch.* Let $\iota(m)$ be the position reached after $m$ steps from
> $0$; it satisfies $\iota(0) = 0$ and $\iota(m+1) = \iota(m)+1$ if that is
> $< i+p$, else $i$. One shows by induction that $\iota(m) < i+p$, that
> $m = \iota(m) + cp$ for some $c \ge 0$, and that either $\iota(m) = m$ or
> $\iota(m) \ge i$. In the first case $u(\iota(m)) = u(m)$ trivially; in the
> second, shifting the eventual periodicity by $c$ periods gives
> $u(\iota(m) + cp) = u(\iota(m))$, i.e. $u(m) = u(\iota(m))$. Since the
> transcript at step $m$ is $u(\iota(m))$, we are done. $\square$

> **Theorem 36 (State-complexity duality).** A Boolean stream $u$ is the
> transcript of some test on a dish type of size at most $n$ if and only if $u$
> is eventually periodic with $\text{preperiod} + \text{period} \le n$.
>
> *Proof.* Theorem 33 for one direction, Theorem 35 for the other. $\square$

Thus the number of dishes needed to realise a verification behaviour is exactly
the combinatorial complexity $i + p$ of its verdict stream. Two corollaries
locate the certificates and show the scale is strict.

> **Corollary 37 (Certificates at the bottom).** A stream is realisable on a
> one-dish type iff it is constant, i.e. iff $i = 0$ and $p = 1$. Constant
> transcripts are exactly complexity $1$, the minimum.

> **Theorem 38 (Strict hierarchy).** For $n \ge 1$ let $u_n(m) = [\,n \nmid
> m\,]$, the stream rejecting exactly at the multiples of $n$. Then $u_n$ is
> realisable on $n$ dishes but on no fewer.
>
> *Proof.* Realisability on $n$ dishes: $u_n$ has preperiod $0$ and period $n$.
> Non-realisability on $n-1$: suppose $u_n$ is eventually $p$-periodic from
> index $i$ with $i + p \le n - 1$. Evaluate at $m = ni \ge i$: since $n \mid
> ni$ we get $u_n(ni) = \text{false}$, hence $u_n(ni + p) = \text{false}$, hence
> $n \mid ni + p$, hence $n \mid p$, hence $p \ge n$ — contradicting
> $p \le n - 1$. $\square$

Each additional dish therefore buys a genuinely new verification behaviour.
A companion negative result completes the picture:

> **Theorem 39 (Certificates cannot simulate destruction).** There is a test on
> two dishes whose transcript from a suitable dish is matched by no
> nondestructive test whatsoever.
>
> *Proof.* Take $\textbf{fuse}_0$ on two dishes started at $0$: by Lemma 27 its
> transcript is $\text{true}, \text{false}, \text{false}, \ldots$, which is not
> constant. Every certificate has constant transcript by Theorem 4. $\square$

---

## 9. How many runs distinguish two dishes?

> **Definition 40.** Dishes $d, e$ are **observationally equivalent** for $t$ if
> $T_{t,d}(m) = T_{t,e}(m)$ for all $m$.

An observer who can only run $t$ and watch verdicts sees exactly the
transcript. How long must one watch?

**The naive bound.** Run $t$ on the pair simultaneously: this is a dynamical
system on $D \times D$ with $n^2$ states, and the pigeonhole principle over the
diagonal gives a bound of $n^2$ runs. Correct, and very wasteful.

**The linear bound.** The improvement is a genuine cross-domain import. The
state-transition side supplies eventual periodicity with $i + p \le n$ for each
of the two transcripts (Theorem 33). The word-combinatorial side supplies the
**Fine–Wilf periodicity lemma**: a finite word that has periods $p$ and $q$ and
length at least $p + q - \gcd(p,q)$ has period $\gcd(p,q)$.

> **Lemma 41 (Fine–Wilf for streams).** Let $s : \mathbb{N} \to \alpha$ be
> globally $p$-periodic ($s(m+p) = s(m)$ for all $m$) and $q$-periodic on the
> window $[0, p+q-\gcd(p,q))$. Then $s$ is globally $\gcd(p,q)$-periodic; in
> fact $s(m) = s(m \bmod \gcd(p,q))$ for all $m$.
>
> *Proof sketch.* Form the finite word $w$ of length $L = p + q - \gcd(p,q)$
> whose $j$-th letter is $s(j)$. The two hypotheses make $w$ have periods $p$
> and $q$, so Fine–Wilf gives it period $g = \gcd(p,q)$. Hence $s(k) = s(k
> \bmod g)$ for all $k < p$ by descending in steps of $g$ inside the window;
> combined with global $p$-periodicity ($s(m) = s(m \bmod p)$) and $g \mid p$,
> this gives the claim for all $m$. $\square$

> **Lemma 42 (Distinguishing engine).** Suppose $T_{t,d}$ is $p_1$-periodic from
> index $i_1$, $T_{t,e}$ is $p_2$-periodic from index $i_2$, and the two agree
> on all indices $j < T$ where
> $$T \;\ge\; \max(i_1,i_2) + p_1 + p_2 - \gcd(p_1,p_2).$$
> Then they agree at every index.
>
> *Proof sketch.* Shift both streams by $I = \max(i_1,i_2)$ so that they become
> globally periodic, with periods $p_1$ and $p_2$ respectively. On the window of
> agreement, each inherits the other's period; Lemma 41 applied twice shows both
> shifted streams are determined by their values on $[0, g)$ where $g =
> \gcd(p_1,p_2)$. Those values lie inside the window of agreement, so the two
> streams coincide everywhere above $I$; below $I$ they coincide by hypothesis.
> $\square$

Every distinguishing bound is now an estimate of the Fine–Wilf window. The
crude estimate $i_k + p_k \le n$ gives $\max(i_1,i_2) + p_1 + p_2 \le 2n$:

> **Theorem 43 (Linear bound).** If $T_{t,d}(j) = T_{t,e}(j)$ for all $j < 2n$,
> then $T_{t,d} = T_{t,e}$.

The constant halves once one uses *minimal* recurrences rather than pigeonhole
recurrences.

> **Lemma 44 (Minimal recurrence).** For $f : D \to D$ finite and $d \in D$
> there are $i \ge 0$, $p > 0$ with $f^{[i+p]}(d) = f^{[i]}(d)$ such that the
> points $f^{[0]}(d), \ldots, f^{[i+p-1]}(d)$ are pairwise distinct. Hence
> $i + p \le n$. Moreover $p$ divides every eventual period of the orbit: if
> $f^{[m+q]}(d) = f^{[m]}(d)$ for all $m \ge J$, then $p \mid q$.
>
> *Proof sketch.* Minimise $i+p$ over all recurrences; minimality forces the
> listed points to be distinct, and distinctness bounds $i+p$ by $|D|$. For
> divisibility: the shifted orbit $m \mapsto f^{[i+m]}(d)$ is genuinely
> $p$-periodic, so it is determined by residues mod $p$; choosing $M = i +
> p(J+1) \ge J$ one computes $f^{[M]}(d) = f^{[i]}(d)$ and $f^{[M+q]}(d) =
> f^{[\,i + (q \bmod p)\,]}(d)$, so the eventual period hypothesis yields
> $f^{[\,i + (q \bmod p)\,]}(d) = f^{[i]}(d)$. If $q \bmod p \ne 0$ this
> contradicts distinctness, since $i$ and $i + (q \bmod p)$ are distinct indices
> below $i+p$. $\square$

> **Lemma 45 (Orbit dichotomy).** Let $d, e$ have minimal recurrence data
> $(i_1,p_1)$ and $(i_2,p_2)$ under $f = r_t$. Exactly one of:
> 1. the orbits never meet ($f^{[a]}(d) \ne f^{[b]}(e)$ for all $a,b$), in which
>    case their point sets are disjoint and
>    $(i_1+p_1) + (i_2+p_2) \le n$; or
> 2. the orbits meet, in which case $p_1 = p_2$.
>
> *Proof sketch.* (1) The two orbits contribute $i_1+p_1$ and $i_2+p_2$ distinct
> dishes respectively (Lemma 44) and are disjoint, so their union has that many
> elements, at most $n$. (2) If $f^{[a]}(d) = f^{[b]}(e)$ then the orbits agree
> after a shift, so $p_1$ is an eventual period of the orbit of $e$ and $p_2$ is
> an eventual period of the orbit of $d$; the divisibility clause of Lemma 44
> gives $p_2 \mid p_1$ and $p_1 \mid p_2$. $\square$

> **Theorem 46 (Sharpened indistinguishability).** Let $|D| = n$. If
> $T_{t,d}(j) = T_{t,e}(j)$ for all $j < n$, then $T_{t,d}(m) = T_{t,e}(m)$ for
> all $m$. Equivalently, observational equivalence is decided by exactly $n$
> runs.
>
> *Proof.* Apply Lemma 42; it suffices to bound the window
> $W = \max(i_1,i_2) + p_1 + p_2 - \gcd(p_1,p_2)$ by $n$, using minimal
> recurrence data. In the disjoint case of Lemma 45,
> $(i_1+p_1)+(i_2+p_2) \le n$, and since $\max(i_1,i_2) \le i_1 + i_2$ and
> $\gcd \ge 1$ we get $W \le (i_1+p_1)+(i_2+p_2) \le n$. In the meeting case
> $p_1 = p_2 = p$ and $\gcd(p_1,p_2) = p$, so $W = \max(i_1,i_2) + p \le
> \max(i_1+p, i_2+p) \le n$ by Lemma 44. $\square$

So one number, $n$, governs both horizons: after $n$ runs a transcript can no
longer change its mind (Theorem 25), and after $n$ runs two dishes can no longer
part company (Theorem 46).

Delay is nevertheless real, and can be long.

> **Definition 47 (Clock test).** On five dishes $\{0,1,2,3,4\}$ let the residue
> map be the permutation with cycles $(0\;1)$ and $(2\;3\;4)$, and let the
> verdicts at positions $0,\dots,4$ be
> $\text{true},\text{false},\text{true},\text{false},\text{true}$.

> **Theorem 48 (Distinguishing delay).** For the clock test, dishes $0$ and $2$
> have transcripts agreeing at steps $0, 1, 2$ and disagreeing at step $3$.
>
> *Proof.* Direct computation: the transcript from $0$ is
> $(\text{t},\text{f},\text{t},\text{f},\dots)$ with period $2$, and from $2$ it
> is $(\text{t},\text{f},\text{t},\text{t},\dots)$ with period $3$. $\square$

The clock test is exactly the Fine–Wilf extremal configuration — periods $2$ and
$3$, coprime, so the required window is $2 + 3 - 1 = 4 = n - 1$.

---

## 10. Algorithms and computation

Everything above is effective on finite dish types, and the algorithms are
elementary but worth stating because they are what one would actually run.

**Classification.** Given a test as a table of $n$ pairs, decide
nondestructiveness by $n$ comparisons; reversibility by checking whether the
residue column is a permutation ($O(n)$ with a seen-array); repeatability by
$n$ verdict comparisons. Total $O(n)$.

**Transcript and destruction depth.** From a dish, iterate the residue map,
recording verdicts, until the first index at which the verdict differs from the
initial one, or until $n$ steps have elapsed. By Theorem 25 the answer after $n$
steps is definitive: depth is $\infty$. Complexity $O(n)$.

**Orbit decomposition (Brent / tortoise–hare, or a visited-array walk).** The
minimal recurrence $(i, p)$ of a dish is computed in $O(n)$ time and $O(n)$
space by walking the orbit with a first-visit timestamp array: the first
repeated dish encountered occurs at index $i + p$ and its first occurrence at
index $i$. This yields the exact state complexity $i+p$ of the transcript
(Theorem 36) and its eventual period $p$.

**Observational equivalence.** By Theorem 46, compare the first $n$ transcript
entries of the two dishes; $O(n)$ time, no fixed-point iteration needed. This
is asymptotically better than the standard partition-refinement (Hopcroft-style)
approach for this special case, precisely because the residue map is a
*deterministic self-map with a single letter*: the transition structure is a
functional graph, not an arbitrary automaton.

**Realisation.** Given a target eventually periodic stream $(i, p, \text{table})$,
the rho test on $i + p$ dishes realises it (Theorem 35) and no smaller dish type
does when $(i,p)$ is minimal; construction is $O(i+p)$.

**Census.** The counts $(2n)^n$, $2^n$, $2^n n!$ of Theorem 20 are directly
checkable by brute-force enumeration for $n \le 3$ and give a useful sanity test
of any implementation.

---

## 11. Applications

**Laboratory protocol design.** Theorems 14 and 15 formalise the standard
laboratory rule "do the nondestructive assays first" and explain why it is
*needed*: a battery containing a destructive test has an order-dependent
verdict, and up to $m!$ distinct behaviours for $m$ tests, while a battery of
certificates has exactly one. Theorem 18 says that a destructive step can be
tolerated in any position if and only if it admits a restoring follow-up, i.e.
iff it is reversible.

**Acceptance sampling and burn-in.** Theorem 29 is a stopping rule: for a
system with $n$ distinguishable states, $n$ consecutive passing runs certify
that all future runs pass, and $n-1$ do not suffice (Theorem 28). Theorems 31
and 32 formalise burn-in: after finitely many preparatory cycles the procedure
becomes non-destructive, indeed reversible, on the surviving state space.

**Measurement models.** The read-and-flip test is a minimal combinatorial model
of a measurement that is information-preserving but disturbing; the burn test
models a measurement that is stable precisely because it is maximally
destructive. Theorem 6 — a repeatable test cannot destroy the property it
decides — is the combinatorial analogue of the statement that a repeatable
measurement projects onto an invariant subspace of the observable.

**Consumable credentials.** A single-use token is a test whose residue moves
irreversibly to a "spent" state. Theorem 38 quantifies the state cost of
implementing a prescribed usage pattern: realising a credential that accepts
exactly on a prescribed eventually periodic schedule requires exactly
$\text{preperiod} + \text{period}$ internal states, no more and no less.

**Testing of stateful systems.** Theorem 46 is a conformance-testing bound: to
decide whether two configurations of a single-input deterministic system with
$n$ states are output-equivalent, $n$ inputs suffice. Theorem 36 is the
corresponding synthesis result, characterising exactly which output behaviours
an $n$-state machine of this shape can exhibit.

---

## 12. Discussion, limitations, and open problems

**What is and is not claimed.** The development is purely structural. No
hardness label is attached to any of the three classes: we do not claim
destructive verification is harder, easier, more expressive in a complexity
sense, or cheaper. The claims are that the classes are distinct pointwise
(Theorem 10), distinct in closure properties (Theorems 13, 16, 19), distinct in
the behaviours they realise (Theorems 36, 39), and that the quantitative
horizons are exactly $n$ (Theorems 25, 28, 46).

**Modelling limitations.** The model is deterministic; a probabilistic test
would return a distribution over $\mathbb{B} \times D$ and the correct analogue
of transcript rigidity is not obvious. The model has a single test applied
repeatedly; a genuine adaptive adversary choosing which of several tests to run
next corresponds to a transition monoid on more than one generator, where
functional-graph arguments give way to general automaton theory and the linear
bounds are expected to degrade. Finally, the model is *free* — it assumes
nothing about the internal structure of dishes — whereas in applications dishes
carry algebraic or metric structure that would constrain admissible residue
maps.

**Two conjectures that failed.** It is worth recording what did not survive
scrutiny. The plausible conjecture that repeatable tests form a submonoid is
false (Theorem 19). The plausible conjecture that "$k$-repeatability for all
dishes" gives a strict hierarchy in $k$ is also false: it collapses at $k=1$,
by Theorem 5. The correct hierarchy is the *pointwise* one of Theorem 28,
indexed by destruction depth at a given dish rather than by a uniform
$k$-repeatability condition.

**The remaining gap.** Theorem 46 gives threshold $n$. Exhaustive enumeration
over small dish types indicates the true threshold is $n - 1$, and the clock
test of Definition 47 (with its coprime periods $2$ and $3$ on five dishes) is
exactly the extremal witness the Fine–Wilf analysis predicts.

> **Conjecture 1 (Sharp distinguishing threshold).** For every finite dish type
> with $n = |D| \ge 2$, every test $t$ and all dishes $d, e$: if $T_{t,d}(j) =
> T_{t,e}(j)$ for all $j < n-1$, then $T_{t,d} = T_{t,e}$. Equivalently, the
> maximal distinguishing delay is exactly $n - 2$.

The route is visible in the proof of Theorem 46. In the disjoint case the slack
is large: $(i_1+p_1) + (i_2+p_2) \le n$ already gives a window comfortably
below $n$, and one expects to shave a further unit from $\max(i_1,i_2) \le
\min(i_1+p_1, i_2+p_2) - 1$. In the meeting case the window is
$\max(i_1,i_2) + p$ with $\max(i_1,i_2) + p \le n$, and equality would require
one orbit to exhaust the whole dish space, which is incompatible with the other
orbit meeting it at a distinct preperiod. Making both estimates uniform is the
content of the conjecture.

**Further directions.** Beyond Conjecture 1: (i) extend to *cost-bearing*
tests, where the residue map is accompanied by a monotone cost and one asks for
the cheapest battery deciding a property; (ii) study the transformation monoid
generated by a finite set of tests, where the natural question becomes the
diameter of the reachable state set; (iii) characterise which *pairs* of streams
are simultaneously realisable on $n$ dishes, which is a two-orbit refinement of
Theorem 36 and is exactly what Conjecture 1 needs; (iv) develop the
probabilistic model and ask whether an analogue of transcript rigidity holds
with high probability after $O(n)$ runs.

---

## 13. Summary of results

| Result | Statement |
|---|---|
| Certificates are reversible and strongly repeatable | Theorems 3, 4 |
| Repeatability propagates along orbits | Theorem 5 |
| A repeatable test preserves the property it decides | Theorem 6 |
| Strict taxonomy on two dishes | Theorem 10 |
| Tests form a monoid; certificates and reversibles are submonoids | Theorems 12, 13 |
| Certificates commute; destructive tests do not | Theorems 14, 15 |
| Certificates form a Boolean semilattice ordered by acceptance | Theorem 16 |
| Reversible $=$ restorable | Theorem 18 |
| Repeatable tests are not closed under composition | Theorem 19 |
| Census: $(2n)^n$ tests, $2^n$ certificates, $2^n n!$ reversible | Theorem 20 |
| Transcript rigidity at horizon $n$ | Theorem 25 |
| Sharp destruction-depth hierarchy | Theorem 28 |
| $n$ passing runs certify all future runs | Theorem 29 |
| Stabilisation; reversibility on the core | Theorems 31, 32 |
| State-complexity duality for transcripts | Theorem 36 |
| Strict dish-count hierarchy | Theorem 38 |
| Certificates cannot simulate destruction | Theorem 39 |
| Observational equivalence decided by $n$ runs | Theorem 46 |
| Distinguishing delay of $3$ on five dishes | Theorem 48 |
