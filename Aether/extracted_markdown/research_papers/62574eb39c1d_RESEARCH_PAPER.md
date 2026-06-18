# The Algebraic and Number-Theoretic Kernel of Anyon-Braiding Universality

## Abstract

Topological quantum computation realizes each computational step as a braid-group
operation on anyonic worldlines, with the promise that the resulting gates are
both *consistent* (they obey the Yang–Baxter / braid relation) and *universal*
(they generate a dense set of unitaries). We isolate and rigorously establish the
algebraic and number-theoretic core of this program for the three-strand braid
group $B_3$ and for the Fibonacci anyon model. On the algebraic side we work with
the reduced Burau representation: we prove the braid relation for every loop
parameter $t$, compute the determinants ($-t$) and exhibit explicit two-sided
inverses, and show that the central full twist $(\sigma_1\sigma_2)^3$ maps to the
scalar $t^3 I$ — hence is central — with Markov trace $2t^3$, degenerating to the
zero matrix at $t=0$. On the number-theoretic side we prove the *density
dichotomy*: the orbit of a phase gate of angle $\alpha$ on the maximal torus is
dense if and only if $\alpha$ is irrational, together with the companion *order
dichotomy* (finite order iff rational; injective orbit iff irrational). As a
sharp boundary case, the Fibonacci eigenphase $4/5$ is rational and hence
non-dense (order dividing $5$), while $\sqrt 2$ is irrational and hence dense. We
then build the Fibonacci gates explicitly: the F-matrix is a symmetric, traceless,
determinant-$(-1)$ involution; the diagonal R-matrix is unitary; the golden ratio
$\varphi$ satisfies $\varphi^2=\varphi+1$ with total quantum dimension squared
$2+\varphi$; and the two single-qubit generators $B_1=R$, $B_2=FRF$ satisfy the
Artin relation $B_1B_2B_1=B_2B_1B_2$. We isolate the single remaining gap — full
density in $SU(2)$ — as a conjecture whose only missing ingredient is the
classification of closed subgroups of $SU(2)$, and we explain precisely why
non-commutativity is indispensable.

**Keywords:** topological quantum computation, anyons, braid group, Burau
representation, Jones polynomial, Fibonacci anyons, golden ratio, Solovay–Kitaev,
density, irrationality.

---

## 1. Introduction

The physical slogan of topological quantum computation is: *anyons are braided,
and the braid computes.* Two interchangeable particles in two spatial dimensions
acquire, on exchange, a nontrivial unitary that depends only on the topology of
their spacetime worldlines. Stacking exchanges weaves the worldlines into an
element of Artin's **braid group**, and the assignment of unitaries to braids is
a representation. The appeal is *topological protection*: small geometric
perturbations of the worldlines do not change the braid class, so the computed
unitary is immune to a large class of local errors.

For this picture to deliver a *universal* quantum computer, two mathematical
pillars must hold:

1. **Consistency.** The unitaries must respect the relations of the braid group,
   above all the Yang–Baxter / braid relation
   $\sigma_1\sigma_2\sigma_1 = \sigma_2\sigma_1\sigma_2$.
2. **Universality.** The generated subgroup of unitaries must be *dense* in the
   relevant compact group (for one logical qubit, $SU(2)$), so that any target
   gate can be approximated to arbitrary accuracy (Solovay–Kitaev).

This paper makes both pillars precise for $n=3$ strands and for the Fibonacci
model, separating what is fully established from the one genuinely open point.
The development is organized around two representations: the **reduced Burau
representation** of $B_3$ (the linear skeleton of the Jones polynomial), which
captures the algebra of braiding for an arbitrary loop parameter $t$; and the
**Fibonacci representation**, which captures the concrete unitary gate set of the
smallest universal non-abelian anyon model. Threaded through both is the
**number-theoretic dichotomy** that controls density on the maximal torus.

All statements below are theorems with proof sketches; the lone exception,
explicitly flagged, is the global $SU(2)$ density conjecture.

---

## 2. The braid group $B_3$ and the reduced Burau representation

### 2.1 Definitions

The Artin braid group on three strands is
$$B_3 = \langle \sigma_1, \sigma_2 \mid \sigma_1\sigma_2\sigma_1 = \sigma_2\sigma_1\sigma_2 \rangle.$$
The **reduced Burau representation** parametrized by $t\in\mathbb{C}$ sends the
generators to $2\times 2$ complex matrices:
$$\sigma_1 \mapsto B_1(t) := \begin{pmatrix} -t & 1 \\ 0 & 1\end{pmatrix}, \qquad
  \sigma_2 \mapsto B_2(t) := \begin{pmatrix} 1 & 0 \\ t & -t\end{pmatrix}.$$
These are the matrices `burauSigma₁` and `burauSigma₂`. The Jones polynomial of a
link presented as the closure of a braid word is obtained as a normalized Markov
trace of the corresponding product of these matrices.

### 2.2 The braid relation

**Theorem 2.1 (Braid relation; `burau_braid_relation`).** For every
$t\in\mathbb{C}$,
$$B_1(t)\,B_2(t)\,B_1(t) = B_2(t)\,B_1(t)\,B_2(t).$$

*Proof sketch.* Expand both triple products entrywise. Each side equals
$\begin{pmatrix} 0 & -t \\ -t^2 & 0\end{pmatrix}$. The identity is a polynomial
identity in $t$, closed by ring arithmetic after unfolding $2\times2$ matrix
multiplication. No assumption on $|t|$ or unitarity is needed; consistency of
braiding holds across the entire parameter family at once. This is also the
structural reason the Jones polynomial is a Laurent polynomial in $t$ rather than
a single number. $\qquad\blacksquare$

### 2.3 Invertibility and the group representation

**Theorem 2.2 (Determinants; `burau_det₁`, `burau_det₂`).**
$\det B_1(t) = \det B_2(t) = -t.$

*Proof sketch.* Direct $2\times2$ determinant: $(-t)\cdot 1 - 1\cdot 0 = -t$ for
$B_1$, and $1\cdot(-t) - 0\cdot t = -t$ for $B_2$. $\qquad\blacksquare$

Thus for $t\neq 0$ both generators are invertible and the representation lands in
$GL_2(\mathbb{C})$, i.e. it is a genuine *group* representation of $B_3$. We make
invertibility constructive.

**Theorem 2.3 (Explicit inverse; `burauSigma₁_mul_inv`, `burauSigma₁_inv_mul`,
`burau_isUnit₁`).** For $t\neq 0$, with
$B_1(t)^{-1} = \begin{pmatrix} -t^{-1} & t^{-1} \\ 0 & 1\end{pmatrix}$,
$$B_1(t)\,B_1(t)^{-1} = B_1(t)^{-1}\,B_1(t) = I,$$
and consequently $B_1(t)$ is a unit of the matrix ring $M_2(\mathbb{C})$.

*Proof sketch.* Entrywise expansion; the single nontrivial off-diagonal entry
cancels via $t\cdot t^{-1}=1$ (`field_simp`). The unit statement follows from
`isUnit_iff_isUnit_det` together with $\det B_1(t) = -t \neq 0$. $\qquad\blacksquare$

### 2.4 The full twist is scalar and central

The center $Z(B_3)$ is the infinite cyclic group generated by the **full twist**
$\Delta^2 = (\sigma_1\sigma_2)^3$.

**Theorem 2.4 (Scalar full twist; `burau_fullTwist_scalar`).** For all $t$,
$$\bigl(B_1(t)B_2(t)\bigr)^3 = t^3 \cdot I.$$

*Proof sketch.* Expand $(B_1B_2)^3$ entrywise; the off-diagonal entries vanish
and both diagonal entries equal $t^3$. $\qquad\blacksquare$

**Corollary 2.5 (Centrality; `burau_fullTwist_central`).** $(B_1B_2)^3$ commutes
with every matrix $M\in M_2(\mathbb{C})$.

*Proof sketch.* A scalar matrix $t^3 I$ commutes with everything:
$t^3I\cdot M = M\cdot t^3 I$ via `smul_mul`/`mul_smul`. $\qquad\blacksquare$

**Theorem 2.6 (Markov trace; `burau_fullTwist_trace`).**
$\operatorname{tr}\bigl((B_1(t)B_2(t))^3\bigr) = 2t^3.$

*Proof sketch.* $\operatorname{tr}(t^3 I_2) = t^3\operatorname{tr}(I_2)=2t^3$.
This is the elementary trace input feeding the Jones polynomial of the closure of
$(\sigma_1\sigma_2)^3$, a torus link. $\qquad\blacksquare$

**Theorem 2.7 (Center maps to scalars; `burau_fullTwist_pow_scalar`).** For
$k\in\mathbb{N}$, $\bigl((B_1B_2)^3\bigr)^k = t^{3k}\cdot I$, so the whole center
$Z(B_3)\cong\mathbb{Z}$ maps into the scalar subgroup.

*Proof sketch.* Raise Theorem 2.4 to the $k$ via `smul_pow` and $1^k=1$. $\qquad\blacksquare$

**Theorem 2.8 (Degeneration; `burau_fullTwist_degenerate`).** At $t=0$,
$(B_1(0)B_2(0))^3 = 0$.

*Proof sketch.* Specialize Theorem 2.4 at $t=0$: $0^3\cdot I = 0$. At $t=0$ the
determinant $-t$ vanishes, so the representation leaves $GL_2(\mathbb{C})$; the
full twist collapsing to $0$ witnesses the breakdown of the braiding theory at the
degenerate loop value. $\qquad\blacksquare$

**Interpretation.** Because the center maps to the *scalars* — the abelian part
of $GL_2$ — the full twist carries no quantum-gate information beyond a global
phase. The number $t^3$ is the linear avatar of the anyon's topological spin /
framing anomaly. All nontrivial computation must therefore come from the
non-commuting braids, foreshadowing the density discussion of §3.

---

## 3. The density dichotomy on the maximal torus

On the maximal torus of $SU(2)$ a braiding gate acts as a phase rotation
$\theta \mapsto \theta + \alpha \pmod 1$. We model the phase space by the additive
circle $\mathbb{T} = \mathbb{R}/\mathbb{Z}$ (`AddCircle (1:ℝ)`) and the gate orbit
by the integer multiples $\{ n\cdot\alpha : n\in\mathbb{Z}\}$.

### 3.1 Density

**Theorem 3.1 (Phase-gate density; `phaseGate_orbit_dense`).** If $\alpha$ is
irrational, the map $n \mapsto n\cdot\alpha$ has dense range in $\mathbb{T}$.

*Proof sketch.* This is the Weyl–Kronecker equidistribution criterion: the
$\mathbb{Z}$-orbit of $\alpha$ in $\mathbb{R}/\mathbb{Z}$ is dense iff $\alpha$ is
irrational (in the formalization, `AddCircle.denseRange_zsmul_coe_iff`). It is the
rigorous one-parameter kernel of the Solovay–Kitaev universality theorem. $\qquad\blacksquare$

### 3.2 The Fibonacci boundary counterexample

**Theorem 3.2 (Fibonacci phase not dense; `fibonacci_phase_not_dense`).** The
orbit $n\mapsto n\cdot(4/5)$ is *not* dense in $\mathbb{T}$.

*Proof sketch.* $4/5$ is rational; apply the converse direction of the same
density criterion. Hence pure-phase braiding at the Fibonacci eigenphase has
finite order and cannot be universal. The *same* lemma proves density (irrational)
and its failure (rational $4/5$), making the dichotomy sharp. $\qquad\blacksquare$

**Theorem 3.3 (Irrational example; `sqrt2_phase_dense`).** The orbit
$n\mapsto n\cdot\sqrt2$ is dense in $\mathbb{T}$.

*Proof sketch.* $\sqrt2$ is irrational (`irrational_sqrt_two`); apply
Theorem 3.1. A positive companion to the Fibonacci counterexample. $\qquad\blacksquare$

### 3.3 The companion order dichotomy

Density is a topological statement about the orbit closure; there is an equivalent
group-theoretic statement about the order of the generator.

**Theorem 3.4 (Rational $\Rightarrow$ finite order;
`rational_phase_finite_order`).** For $k\in\mathbb{Z}$, $q\in\mathbb{N}$ with
$q>0$, $\ q\cdot\bigl(k/q\bigr) = 0$ in $\mathbb{T}$. The order of the phase gate
$k/q$ divides $q$.

*Proof sketch.* $q\cdot(k/q) = k$, and the image of the integer $k$ in
$\mathbb{R}/\mathbb{Z}$ is $0$. The Fibonacci obstruction is the case $k=4$,
$q=5$, giving order dividing $5$. $\qquad\blacksquare$

**Theorem 3.5 (Irrational $\Rightarrow$ infinite order;
`irrational_phase_injective`).** If $\alpha$ is irrational, the orbit map
$n\mapsto n\cdot\alpha$ on $\mathbb{T}$ is injective; the generated cyclic
subgroup is free of rank one.

*Proof sketch.* If $n\cdot\alpha = m\cdot\alpha$ then $(n-m)\alpha \in \mathbb{Z}$;
were $n\neq m$, this would force $\alpha = j/(n-m)\in\mathbb{Q}$, contradicting
irrationality. $\qquad\blacksquare$

Together, Theorems 3.1–3.5 pin down the structure of the cyclic subgroup generated
by a single braiding phase gate: rational phases generate finite cyclic groups
(never dense), irrational phases generate $\mathbb{Z}$ (dense). Universality of a
*single* generator is impossible exactly when its phase is rational.

---

## 4. The Fibonacci anyon model, explicitly

We now construct the concrete gate set of the Fibonacci anyon, the smallest
non-abelian model conjectured universal for quantum computation. The logical
qubit is the two-dimensional fusion space of three $\tau$ anyons with total charge
$\tau$.

### 4.1 The golden ratio and quantum dimension

**Definition 4.1.** $\varphi := (1+\sqrt5)/2$ (`gold`), the quantum dimension of
the $\tau$ anyon, and $\tau := 1/\varphi$ (`tau`), the inverse quantum dimension.

**Theorem 4.2 (Golden identity; `gold_sq`, `gold_pos`, `tau_pos`).**
$\varphi > 0$, $\tau > 0$, and $\varphi^2 = \varphi + 1$.

*Proof sketch.* Substitute $\varphi=(1+\sqrt5)/2$ and use $(\sqrt5)^2=5$. $\qquad\blacksquare$

**Theorem 4.3 (Pentagon scalar; `tau_mul_succ`).** $\tau(\tau+1) = 1.$

*Proof sketch.* With $\tau=1/\varphi$, clear denominators and apply $\varphi^2 =
\varphi+1$. This is the golden-ratio identity behind the pentagon equation for
Fibonacci fusion. $\qquad\blacksquare$

**Theorem 4.4 (Total quantum dimension; `total_quantum_dim_sq`).**
$1 + \varphi^2 = 2 + \varphi.$

*Proof sketch.* Immediate from $\varphi^2=\varphi+1$. The left side is
$d_1^2 + d_\tau^2 = 1 + \varphi^2$, the total quantum dimension squared $D^2$. $\qquad\blacksquare$

### 4.2 The F-matrix (associator)

**Definition 4.5.** $F := \begin{pmatrix} \tau & \sqrt\tau \\ \sqrt\tau & -\tau
\end{pmatrix}$ (`fibF`), the change-of-fusion-basis (associator) matrix.

**Theorem 4.6 (Involution; `fibF_involutive`).** $F\cdot F = I.$

*Proof sketch.* The diagonal entries of $F^2$ are $\tau^2 + (\sqrt\tau)^2 =
\tau^2+\tau = \tau(\tau+1) = 1$ by Theorem 4.3; the off-diagonal entries are
$\tau\sqrt\tau - \sqrt\tau\,\tau = 0$. $\qquad\blacksquare$

**Theorem 4.7 (Symmetry / orthogonality; `fibF_symmetric`, `fibF_orthogonal`).**
$F^{\mathsf T} = F$, hence $F^{\mathsf T}F = I$.

*Proof sketch.* Symmetry is entrywise; combine with Theorem 4.6. $\qquad\blacksquare$

**Theorem 4.8 (Determinant; `fibF_det`).** $\det F = -1.$

*Proof sketch.* $\det F = \tau(-\tau) - (\sqrt\tau)^2 = -(\tau^2+\tau) = -1$ by
Theorem 4.3. $F$ is an orientation-reversing reflection. $\qquad\blacksquare$

**Theorem 4.9 (Tracelessness; `fibF_trace`).** $\operatorname{tr} F = \tau -
\tau = 0.$

### 4.3 The R-matrix (braiding phases)

**Definition 4.10.** With braiding phases $\theta_1 = -4\pi/5$ (`rPhase1`) and
$\theta_2 = 3\pi/5$ (`rPhase2`),
$$R := \begin{pmatrix} e^{i\theta_1} & 0 \\ 0 & e^{i\theta_2}\end{pmatrix}
\quad(\texttt{fibR}).$$

**Theorem 4.11 (Unitarity; `fibR_unitary`).** $R^\dagger R = I.$

*Proof sketch.* $R$ is diagonal with unit-modulus entries; on the diagonal
$\overline{e^{i\theta}}\,e^{i\theta} = e^{-i\theta}e^{i\theta} = 1$ for real
$\theta$ (using $\cos^2+\sin^2=1$). Braiding preserves the inner product on the
fusion space — the algebraic content of topological protection. $\qquad\blacksquare$

**Theorem 4.12 (Determinant modulus; `fibR_det_abs`).** $\lvert\det R\rvert = 1$;
$R \in U(2)$.

### 4.4 The braid relation for the Fibonacci generators

The two single-qubit braid generators on three $\tau$ anyons are
$$B_1 := R, \qquad B_2 := F\,R\,F$$
(using $F = F^{-1}$ from Theorem 4.6).

**Theorem 4.13 (Artin relation; `fib_braid_relation`).**
$$B_1 B_2 B_1 = B_2 B_1 B_2, \qquad\text{i.e.}\qquad
R\,(FRF)\,R = (FRF)\,R\,(FRF).$$

*Proof sketch.* Reduce to entrywise equality of $2\times 2$ complex matrices.
Each entry is a polynomial in the braiding phases $e^{i\theta_1}, e^{i\theta_2}$
and in $\tau, \sqrt\tau$. Collapse the phase products via the fifth-root angle
identities (reducing arguments such as $8\pi/5$, $9\pi/5$, $12\pi/5$ modulo
$2\pi$ and applying sum/difference formulas), use $\cos(\pi/5) = \varphi/2$
(`Real.cos_pi_div_five`), the double-angle identities, $(\sqrt\tau)^2 = \tau$, and
the golden-ratio relation $\varphi^2=\varphi+1$. After these substitutions each
entry identity closes by ring arithmetic. $\qquad\blacksquare$

Together with the density results of §3, Theorem 4.13 certifies that the Fibonacci
data assemble into a genuine *unitary* representation of $B_3$ — the standing
structural ingredient for universality.

---

## 5. The open frontier: full density in $SU(2)$

**Conjecture 5.1 (Braiding density; `su2_braiding_dense`).** There exist
$U, V \in SU(2)$ (two anyon braids) such that the subgroup they generate,
$\overline{\langle U, V\rangle}$, is dense in $SU(2)$. Physically: two braids
suffice for universal single-qubit topological computation.

**Why the torus results do not suffice.** Theorems 3.1–3.5 show that *any single*
generator with rational phase fails to be dense, and any single generator lives
inside a maximal torus (a commuting circle) which is itself a proper closed
subgroup. Hence density is impossible without **non-commutativity**: two braids
that do not share a common rotation axis. A single $\mathbb{Z}$-orbit argument can
never produce a dense subgroup of the non-abelian $SU(2)$.

**The missing ingredient.** The natural route to Conjecture 5.1 is the
**classification of closed subgroups of $SU(2)$**: every closed subgroup is
either finite, a maximal torus, the normalizer of a maximal torus, or all of
$SU(2)$. Given a pair $U,V$ whose generated subgroup is infinite and not
contained in any torus or its normalizer, the classification forces the closure
to be the whole group. This classification is not yet available in the supporting
library, so Conjecture 5.1 is recorded with its precise location on the map and
its single missing lemma identified, rather than proved with a flawed argument.

**Independence of invertibility and non-commutativity.** A structural lesson from
the Burau side (§2): at the degenerate value $t=0$ it is *invertibility* that
fails ($\det = 0$, leaving $GL_2$), whereas non-commutativity of the generators
persists for every $t$. Invertibility and non-commutativity are independent
phenomena. This reframes the attack on Conjecture 5.1: the obstruction to
universality is never a lack of non-commutativity (which is generic) but the
global topology of the closure.

---

## 6. Algorithms

The constructive content above yields several decision and computation procedures,
detailed with pseudocode and code in the accompanying package.

1. **Burau evaluation and braid-relation check.** Given $t$, build $B_1(t),
   B_2(t)$, multiply braid words, and verify $B_1B_2B_1 = B_2B_1B_2$ entrywise.
   Complexity: $O(L)$ matrix multiplications for a word of length $L$, each $O(1)$
   for $2\times2$ matrices.
2. **Density oracle via the dichotomy.** Given a phase $\alpha$, decide whether
   the single-gate orbit is dense by testing rationality of $\alpha$ (Theorem
   3.1–3.2). For rational $k/q$ in lowest terms, the orbit is the finite set of
   $q$ equally spaced points; the order equals $q$ (Theorem 3.4).
3. **Fibonacci gate synthesis.** Construct $F$, $R$, and the generators $B_1=R$,
   $B_2=FRF$; verify involution, unitarity, and the Artin relation numerically to
   confirm the symbolic identities (Theorems 4.6, 4.11, 4.13).
4. **Solovay–Kitaev-style approximation harness.** Using the dense single-qubit
   generators (irrational phase), greedily approximate a target unitary by short
   braid words, illustrating the $O(\log(1/\varepsilon))$ depth promised by the
   Solovay–Kitaev theorem whose one-parameter kernel is Theorem 3.1.

---

## 7. Applications

- **Fault-tolerant quantum hardware.** Topological protection — the unitarity of
  $R$ (Theorem 4.11) and the topology-only dependence of the braid class — is the
  mechanism behind error-resistant qubits being pursued in fractional quantum
  Hall systems and engineered Majorana/Fibonacci platforms.
- **Knot invariants.** The Burau representation is the linear skeleton of the
  Jones polynomial; the trace computations (Theorem 2.6) are the elementary
  inputs to evaluating the Jones polynomial of braid closures, a problem of
  independent interest in low-dimensional topology and #P-hardness studies.
- **Compilation of quantum circuits.** The density dichotomy (§3) tells a compiler
  *which* primitive phases are worth using as base generators, and the order
  computations bound the periodicity of rational gates.

---

## 8. Discussion

The recurring theme is *reduction to clean abstract questions*. Consistency of
braiding is a polynomial identity (the braid relation, Theorem 2.1). Topological
protection is the unitarity of a single diagonal matrix (Theorem 4.11). The
pentagon rule of fusion is the golden ratio's defining quadratic (Theorems
4.2–4.3). And universality — at the one-qubit, single-generator level — is
exactly the rational/irrational dichotomy (Theorems 3.1–3.5).

A notable methodological event was the refinement of a boundary conjecture by a
critical refutation. A first guess, that the Burau gates commute at the
degenerate value $t=0$, is *false*: comparing the $(0,0)$ and $(0,1)$ entries of
$B_1B_2$ versus $B_2B_1$ shows they disagree for every $t$, with no hypothesis at
all. This both strengthened the non-commutativity statement to hold universally
and clarified that invertibility and non-commutativity are independent phenomena
— the former failing only at $t=0$, the latter never failing. This is precisely
the structural insight that should guide an attack on the remaining $SU(2)$
density conjecture.

---

## 9. Future work

- **Resolve Conjecture 5.1** by formalizing the classification of closed subgroups
  of $SU(2)$ and applying it to an explicit non-commuting braid pair.
- **Lift to multi-qubit universality** ($n>3$ strands, larger fusion spaces),
  where the relevant target group is $SU(d)$ and the dense-generation problem
  becomes correspondingly richer.
- **Quantify approximation depth** by formalizing the Solovay–Kitaev iteration on
  top of the density kernel, turning Theorem 3.1 into explicit $O(\log^c(1/
  \varepsilon))$ word-length bounds.
- **Connect to the Jones polynomial** by formalizing the Markov trace and the
  normalization that turns Theorem 2.6 and its relatives into genuine link
  invariants.

The Phase A program's own future-directions note (reproduced in the accompanying
package) records additional concrete next steps for the non-abelian core,
including the explicit minimal polynomial $X^2 + tX + t^2$ of the elementary braid
$\sigma_1\sigma_2$ (trace $-t$, determinant $t^2$, eigenvalues $t\zeta_6^{\pm1}$),
which already exhibits a genuine rotation rather than a mere phase.

---

## 10. Conclusion

We have isolated and rigorously established the algebraic and number-theoretic
kernel of anyon-braiding universality for $B_3$ and the Fibonacci model: the
braid relation and group structure of the Burau representation, the scalar central
full twist, the exact density and order dichotomies on the maximal torus, and the
explicit Fibonacci F/R gates with their involution, unitarity, and Artin
relation. The single remaining gap — global density in $SU(2)$ — is precisely
located: it requires only the classification of the closed subgroups of $SU(2)$,
and its necessity is explained by the indispensability of non-commutativity.
Knots can compute, the golden ratio guards against errors, and the boundary
between the computable and the impossible is drawn, at the one-qubit level, by the
irrationality of an angle.
