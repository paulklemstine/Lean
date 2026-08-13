# Exact Bond Dimension of Periodic Combs, and the Limits of Tensor-Train De-Quantization of Order Finding

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

De-quantization — the classical emulation of a quantum algorithm under the
structural hypotheses the quantum algorithm implicitly requires — has repeatedly
dissolved claimed exponential speedups in linear algebra and machine learning.
The common mechanism is low rank: quantum algorithms whose inputs admit low-rank
descriptions can be emulated by randomized classical sketching. This paper asks
whether the same mechanism applies to the central state of quantum order
finding, the *periodic comb*
$|\mathrm{comb}\rangle = \sum_{x<n,\ x\equiv x_0 (r)} |x\rangle$, and answers with
an exact formula.

Writing the register dimension as a bipartite cut $n = PQ$ and reshaping the
amplitude vector into a $P \times Q$ matrix, we prove that the Schmidt rank —
equivalently the minimal matrix-product-state bond dimension across the cut — is
exactly
$$\operatorname{rank} = \min\!\left(P, \frac{r}{\gcd(r,Q)}\right)\qquad (0 < r \le Q),$$
independent of the offset $x_0$. On a binary register with $r = 2^t m$ and $m$
odd this becomes the **odd-part law** $\min(2^a, m)$: the power-of-two part of the
period is entirely free, the odd part is entirely rigid. In particular the comb
is a product state across a binary cut if and only if its period is a power of
two, and at a balanced cut a comb of period $2^a - 1$ on $L = 2a$ qubits forces
bond dimension $\ge 2^{L/2} - 1$.

For the *exact* (divisible) case $n = mr$ we compute the bond dimension of the
Fourier-transformed comb as well, obtaining $\min(P, m/\gcd(m,Q))$ — the same
law with the period replaced by the co-period — and deduce a **complementarity
theorem**: the product of the bond dimensions before and after the transform is
at most $P = n/Q$, so at a balanced cut at least one side has bond dimension
$\le n^{1/4}$. Tensor-train emulation of the Fourier transform is therefore
provably efficient exactly when $r \mid n$ — a hypothesis that a binary register
with odd order can never satisfy. The de-quantization boundary is thus located
precisely at a divisibility relation, and quantum order finding lies on the
hard side of it.

**Keywords:** de-quantization, matrix product states, tensor trains, bond
dimension, Schmidt rank, Dirac comb, quantum Fourier transform, order finding.

---

## 1. Introduction

### 1.1 De-quantization and the low-rank hypothesis

A recurring pattern in quantum algorithmics is this. A quantum algorithm is
advertised as exponentially faster than any classical competitor; closer
inspection reveals that its input model presupposes strong structure — most
often that the relevant matrix or state has low rank or low "effective"
dimension; and a classical randomized algorithm exploiting the same structure
achieves comparable asymptotic performance, killing the exponential separation.
The literature refers to this as *de-quantization*.

Three quantum-algorithmic templates are typically named as candidates:

1. **Bounded-entanglement simulation.** An $n$-qubit state whose entanglement
   entropy across every cut is at most $S_{\max}$ admits a matrix-product-state
   representation with bond dimension $D = O(e^{S_{\max}})$, reducing storage
   from $O(2^n)$ to $O(n D^2 d)$ for local dimension $d$.
2. **Low-rank matrix inversion.** A symmetric positive-definite matrix $A$ of
   numerical rank $\rho \ll N$ can be inverted classically by randomized
   sketching in time polynomial in $\rho$ and logarithmic in $N$, bypassing
   quantum phase estimation.
3. **Tensor-train Fourier emulation.** If a state admits a low-rank tensor-train
   representation, the quantum Fourier transform can be applied classically by
   alternating contractions of core tensors with local phase operators, in
   $O(nD^2)$ operations, with singular-value truncation between sweeps.

Templates 1 and 2 are conditional statements whose hypotheses are transparent.
Template 3 is the interesting one for cryptography, because the quantum Fourier
transform is the one component of quantum order finding that has no obvious
classical analogue: it aggregates $\Theta(n)$ amplitudes coherently in
$\mathrm{polylog}(n)$ gates, evading the linear-aggregation cost that every
classical method pays.

The question this paper settles is therefore the natural one:

> **Question.** Does the state on which order finding applies the Fourier
> transform admit a low-rank tensor-train representation?

If it did, template 3 would apply, and order finding — hence integer
factoring by the standard reduction — would be classically emulable. We show
that it does not, and we compute exactly how badly it fails.

### 1.2 Contributions

* **An exact rank formula** for the reshaped periodic comb across an arbitrary
  bipartite cut (Theorem 4.4), with matching explicit constructions on both
  sides: an exact two-core factorization for the upper bound, and an explicit
  permuted identity submatrix for the lower bound.
* **An operational reading**: the minimal tensor-train bond dimension across the
  cut equals that rank exactly, with an if-and-only-if characterization
  (Theorem 4.6).
* **The odd-part law** for binary registers (Theorem 5.2), the associated
  product-state dichotomy (Theorem 5.3), and an exponential lower bound at the
  balanced cut (Theorem 5.5).
* **A support-only lower bound** (Theorem 6.2): any matrix whose *support* is a
  comb has rank at least the reduced period, whatever nonzero amplitudes it
  carries. This decouples the hardness from the specific $0/1$ values and is what
  makes the theory applicable to the phase-decorated output of the Fourier
  transform.
* **The transform law and complementarity theorem** (Theorems 7.3 and 7.5):
  the Fourier transform inverts the period, and the product of the two bond
  dimensions is at most $n/Q$.
* **Localization of the de-quantization boundary** at the divisibility $r \mid
  n$ (Section 8).
* **A zero-count law for the transformed truncated comb** (Proposition 10.1):
  on a binary register with odd period, the transform vanishes at exactly
  $\gcd(n,J) - 1$ frequencies, where $J$ is the number of teeth; full support
  holds iff $J$ is odd. This corrects the natural "never vanishes" guess, whose
  smallest counterexample is $n = 16$, $r = 5$, $x_0 = 0$. The rank of the
  transform is at most the tooth count $J$, with equality when $J \le \min(P,Q)$
  (Proposition 10.2).
* **Two precise conjectures** (Section 10) that would extend exact-rank hardness
  to approximate-rank hardness.

---

## 2. Setting and definitions

Throughout, $n$ denotes the dimension of a quantum register (for qubits,
$n = 2^L$), and states are unnormalized vectors in $\mathbb{C}^n$; normalization
never affects rank.

**Definition 2.1 (Bipartite cut and reshape).** A *cut* of the register is a
factorization $n = PQ$ with $P, Q \ge 1$. Every index $x \in \{0,\dots,n-1\}$
decomposes uniquely as $x = pQ + q$ with $0 \le p < P$, $0 \le q < Q$; equivalently
$p = \lfloor x/Q \rfloor$ and $q = x \bmod Q$. Given a state
$|\psi\rangle = \sum_x \psi(x)|x\rangle$, its *reshape* across the cut is the
matrix $\Psi \in \mathbb{C}^{P \times Q}$ with $\Psi[p,q] = \psi(pQ + q)$.

For a qubit register split after $a$ of $L$ qubits, $P = 2^a$, $Q = 2^b$,
$a+b = L$, and this is exactly the standard left/right splitting used by every
matrix-product-state construction.

**Definition 2.2 (Bond dimension).** A matrix $M \in \mathbb{C}^{P\times Q}$
*has bond $D$*, written $\mathrm{HasBond}(M, D)$, if there exist
$A \in \mathbb{C}^{P \times D}$ and $B \in \mathbb{C}^{D\times Q}$ with $M = AB$.
The *minimal bond dimension* of $M$ is the least such $D$.

**Proposition 2.3 (Bond dimension equals rank).**
$\mathrm{HasBond}(M,D)$ holds if and only if $D \ge \operatorname{rank} M$.

*Proof sketch.* If $M = AB$ with inner index of size $D$, then
$\operatorname{rank} M \le \operatorname{rank} A \le D$. Conversely, a rank
factorization gives $D = \operatorname{rank} M$, and any larger $D$ is obtained
by padding both cores with zero columns/rows — a routine verification that the
padded product agrees with the original, since the added terms contribute zero
to every entry. $\square$

Proposition 2.3 is the reason the whole paper is a computation of ranks: the
Schmidt rank across a cut *is* the minimal bond dimension there, so a lower
bound on rank is an unconditional lower bound on the memory and time of any
tensor-train method that materializes the state.

**Definition 2.4 (Periodic comb).** For $r \ge 1$ and an offset $x_0$, the
*comb of period $r$* in a register of dimension $n = PQ$ is the state
$$|\mathrm{comb}\rangle = \sum_{\substack{0 \le x < n\\ x \equiv x_0 \ (\mathrm{mod}\ r)}} |x\rangle,$$
whose reshape across the cut is the $0/1$ matrix
$$M[p,q] = \begin{cases}1,& (pQ+q)\bmod r = x_0 \bmod r,\\ 0,&\text{otherwise.}\end{cases}$$

That the reshape is faithful — that $M[\lfloor x/Q\rfloor, x \bmod Q]$ really is
the amplitude at $x$ — follows from $\lfloor x/Q\rfloor \cdot Q + (x \bmod Q) = x$.

**Definition 2.5 (Reduced period).** For $r \ge 1$ and $Q \ge 1$ put
$g = \gcd(r,Q)$ and
$$s(r,Q) \;=\; \frac{r}{\gcd(r,Q)}.$$
Then $s \cdot g = r$ and $s \ge 1$; $s$ is the order of the cyclic subgroup
$\langle Q\rangle \le \mathbb{Z}/r\mathbb{Z}$.

### 2.1 Why the comb is the state that matters

Quantum order finding, given $N$ and a base $y$ coprime to $N$, prepares
$n^{-1/2}\sum_{x<n} |x\rangle|y^x \bmod N\rangle$ on a register of dimension
$n = 2^L$, measures the second register, and thereby collapses the first onto
$$\sum_{\substack{x < n\\ x \equiv x_0\ (\mathrm{mod}\ r)}}|x\rangle,$$
where $r = \mathrm{ord}_N(y)$ and $x_0$ is the least exponent consistent with
the observed value. The Fourier transform is then applied to *this* state.
Everything downstream — the peaked frequency distribution, the
continued-fraction recovery of $r$ — is a consequence of the transform of the
comb. Hence: the compressibility of order finding by tensor trains is exactly
the compressibility of the comb.

---

## 3. Two elementary rank tools

The lower bounds all pass through the following two lemmas, which replace the
usual appeal to submatrix reindexing (valid only for bijections) by explicit
selection matrices, allowing *arbitrary* index maps.

**Lemma 3.1 (Identity submatrix bound).** Let
$A \in \mathbb{C}^{P\times Q}$ and let $f : \{0,\dots,k-1\}\to\{0,\dots,P-1\}$,
$g : \{0,\dots,k-1\}\to\{0,\dots,Q-1\}$ be arbitrary maps such that
$A[f(i), g(j)] = \delta_{ij}$. Then $\operatorname{rank} A \ge k$.

*Proof sketch.* Let $E \in \mathbb{C}^{k\times P}$ have $E[i,p] = [p = f(i)]$ and
$F \in \mathbb{C}^{Q\times k}$ have $F[q,j] = [q = g(j)]$. Then
$(EA)[i,q] = A[f(i),q]$ and $(XF)[i,j] = X[i,g(j)]$, so
$E(AF) = I_k$. Rank is submultiplicative, so
$k = \operatorname{rank} I_k \le \operatorname{rank}(AF) \le \operatorname{rank} A$.
Note that $f$ and $g$ need not be injective; injectivity is forced a posteriori
by the delta condition. $\square$

**Lemma 3.2 (Diagonal submatrix bound).** The same conclusion holds under the
weaker hypothesis that $A[f(i),g(i)] \ne 0$ for all $i$ and $A[f(i),g(j)] = 0$
for $i \ne j$: rescale the rows of the selector $E$ by $A[f(i),g(i)]^{-1}$.

**Lemma 3.3 (Phases are free).** If $d \in (\mathbb{C}^\times)^P$ and
$e \in (\mathbb{C}^\times)^Q$, then
$\operatorname{rank}\big(\mathrm{diag}(d)\, X\, \mathrm{diag}(e)\big) = \operatorname{rank} X$.

*Proof sketch.* Submultiplicativity of rank gives $\le$; conjugating back by
$\mathrm{diag}(d^{-1})$ and $\mathrm{diag}(e^{-1})$ recovers $X$ and gives $\ge$.
$\square$

Lemma 3.3 has a direct algorithmic meaning: the local single-qubit phase gates
that a tensor-train emulation of the Fourier transform applies to individual
core tensors cannot change any bond dimension. Whatever hardness we exhibit is
therefore invariant under exactly the operations the emulation is allowed to
perform for free.

---

## 4. The exact bond dimension of a comb

### 4.1 Upper bound: an explicit two-core tensor train

The left block communicates with the right block only through the residue
$pQ \bmod r$. Moreover, every such residue is a multiple of $g = \gcd(r,Q)$, so
the traffic across the cut is confined to a set of size $s = r/g$.

**Definition 4.1 (Reduced cores).** Fix $r \ge 1$, $Q \ge 1$, $s = s(r,Q)$,
$g = \gcd(r,Q)$. Define
$$A[p,c] = \big[\,pQ \bmod r = c\,g\,\big], \qquad c \in \{0,\dots,s-1\},$$
$$B[c,q] = \big[\,(cg + q) \bmod r = x_0 \bmod r\,\big].$$

**Theorem 4.2 (Exact factorization).** For every $P, Q, x_0$ and $r \ge 1$,
$M = AB$. Hence $\operatorname{rank} M \le s(r,Q) = r/\gcd(r,Q)$.

*Proof sketch.* Fix $p$. Since $g \mid pQ \bmod r$ (because $g \mid Q$ and
$g \mid r$), there is exactly one $c$ with $pQ \bmod r = cg$, and $c < s$ because
$pQ \bmod r < r = sg$. So the sum $\sum_c A[p,c]B[c,q]$ has a single surviving
term, equal to $[\,(pQ \bmod r + q)\bmod r = x_0 \bmod r\,]$, which equals
$M[p,q]$ by $(u \bmod r + q)\bmod r = (u+q)\bmod r$. $\square$

Taking $g = 1$ recovers the cruder bound $\operatorname{rank} M \le r$ with the
"unreduced" cores $A[p,c] = [pQ \bmod r = c]$, $B[c,q] = [(c+q)\bmod r = x_0 \bmod r]$.

### 4.2 Lower bound: an explicit delta submatrix

**Lemma 4.3 (Arithmetic heart).** Let $r \ge 1$ and set $k = \min(P, s(r,Q))$.
For $i, j < k$ define
$$f(i) = i, \qquad g_{\mathrm{col}}(j) = \big(x_0 + (r - (jQ \bmod r))\big) \bmod r .$$
Then, provided $r \le Q$ so that $g_{\mathrm{col}}(j) < Q$ is a legal column
index,
$$\big(f(i)\,Q + g_{\mathrm{col}}(j)\big) \equiv x_0 \pmod r \iff i = j .$$

*Proof sketch.* Modulo $r$ the left-hand quantity equals
$iQ + x_0 - jQ = x_0 + (i-j)Q$, so the congruence holds iff
$(i-j)Q \equiv 0 \pmod r$, i.e. iff $s \mid i - j$ (since the order of $Q$ in
$\mathbb{Z}/r$ is $s = r/\gcd(r,Q)$). As $|i - j| < k \le s$, this forces
$i = j$. $\square$

**Theorem 4.4 (Exact rank of the comb).** For $0 < r \le Q$ and any $P, x_0$,
$$\operatorname{rank} M \;=\; \min\!\left(P,\ \frac{r}{\gcd(r,Q)}\right).$$

*Proof.* The upper bound is $\operatorname{rank} M \le \min(P, s)$ by
Theorem 4.2 together with the trivial bound $\operatorname{rank} M \le P$. The
lower bound is Lemma 3.1 applied to the index maps of Lemma 4.3, whose delta
condition gives $M[f(i), g_{\mathrm{col}}(j)] = \delta_{ij}$ and hence
$\operatorname{rank} M \ge \min(P,s)$. $\square$

Two sanity checks confirm that neither term in the minimum is decorative. With
$P = 4$, $Q = 16$, $r = 5$ the rank is $4 = \min(4,5)$, not $5$: the $P$ is
needed. And $r \le Q$ is needed: if $Q$ is smaller than the period, some residue
classes are empty in the right block and the count of nonzero rows drops.

### 4.3 The coprime special case

**Corollary 4.5.** If $\gcd(Q,r) = 1$ and $r \le P$, $r \le Q$, then
$\operatorname{rank} M = r$ exactly. In particular the comb is a product state
across the cut ($\operatorname{rank} = 1$) if and only if $r = 1$.

Conversely, at the other extreme, if $r \mid Q$ then every row of $M$ is the same
indicator vector and $\operatorname{rank} M \le 1$: the comb is unentangled
across that cut regardless of how large $r$ is. The coprimality hypothesis in
Corollary 4.5 is thus load-bearing, and Theorem 4.4 is the single formula that
interpolates between the two extremes ($g = 1$ and $s = 1$ respectively).

**Theorem 4.6 (Operational form).** For $0 < r \le Q$, a tensor-train
representation of the comb across the cut with bond index of size $D$ exists if
and only if $D \ge \min(P, r/\gcd(r,Q))$.

*Proof.* Combine Theorem 4.4 with Proposition 2.3; for the constructive
direction use the cores of Definition 4.1 when $s \le P$, and the trivial
factorization $M = I_P M$ when $P \le s$. $\square$

---

## 5. Binary registers: the odd-part law

Qubit registers make $Q$ a power of two, which collapses the gcd to the $2$-part
of the period.

**Lemma 5.1.** If $m$ is odd and $t \le b$ then $\gcd(2^t m, 2^b) = 2^t$, and
hence $s(2^t m, 2^b) = m$.

*Proof sketch.* Write $2^b = 2^t 2^{b-t}$ and pull out the common factor:
$\gcd(2^t m, 2^t 2^{b-t}) = 2^t \gcd(m, 2^{b-t}) = 2^t$ since $m$ is odd.
$\square$

**Theorem 5.2 (Odd-part law).** Consider the binary cut $2^a \otimes 2^b$ and a
comb of period $r = 2^t m$ with $m$ odd, $t \le b$ and $r \le 2^b$. Then
$$\operatorname{rank} M \;=\; \min\!\left(2^a,\ m\right).$$
The power-of-two part of the period contributes nothing to the bond dimension;
the odd part contributes everything.

*Proof.* Theorem 4.4 with Lemma 5.1. $\square$

**Theorem 5.3 (Product-state dichotomy).** Under the hypotheses of Theorem 5.2
with at least one qubit on the left ($a \ge 1$), the comb is a product state
across the cut if and only if $m = 1$, i.e. if and only if the period is a pure
power of two.

*Proof.* $\min(2^a, m) = 1$ with $2^a \ge 2$ forces $m = 1$; conversely $m=1$
gives rank $1$. $\square$

**Theorem 5.4 (Sharp de-quantization barrier).** Any tensor-train / matrix
product state representation of the comb across the binary cut has bond
dimension $D \ge \min(2^a, m)$, with $m$ the odd part of the period.

**Theorem 5.5 (Exponential barrier at the balanced cut).** On $L = 2a$ qubits
split down the middle ($P = Q = 2^a$), the comb of period $r = 2^a - 1$ requires
bond dimension
$$D \;\ge\; 2^a - 1 \;=\; 2^{L/2} - 1 .$$

*Proof.* $\gcd(2^a - 1, 2^a) = 1$ since consecutive integers are coprime, so the
reduced period is $2^a - 1$, and $\min(2^a, 2^a - 1) = 2^a - 1$. Apply Theorem
4.4 and Proposition 2.3. $\square$

The period $2^a - 1$ is not adversarial exotica: it is precisely the magnitude
of order one expects for a generic base modulo a generic modulus, and being
coprime to the block size it is the worst case for compressibility.

**Numerical illustration.** For $P = Q = 8$ and $x_0 = 0$, the ranks for
$r = 1,\dots,8$ are $1, 1, 3, 1, 5, 3, 7, 1$ — exactly the odd parts of
$1,\dots,8$. An exhaustive check over all $1 \le P, Q, r \le 12$ and
$0 \le x_0 \le 3$ (6912 matrices) finds the rank always equal to the number of
distinct nonzero rows and, whenever $r \le Q$, equal to $\min(P, r/\gcd(r,Q))$,
with zero mismatches.

---

## 6. From values to support

The theorems so far concern the $0/1$ comb. The output of the Fourier transform
carries nonzero *phases* on a comb-shaped support, so we need a version of the
lower bound that sees only where the amplitudes are nonzero.

**Definition 6.1.** A matrix $N \in \mathbb{C}^{P\times Q}$ is *supported on the
comb $(r, x_0)$* if for all $p, q$:
$N[p,q] \ne 0 \iff (pQ + q) \bmod r = x_0 \bmod r$.

**Theorem 6.2 (Support-only lower bound).** If $0 < r \le Q$ and $N$ is supported
on the comb $(r,x_0)$, then
$\operatorname{rank} N \ge \min(P, r/\gcd(r,Q))$, whatever the nonzero values are.

*Proof.* Use the same index maps as Lemma 4.3. On the diagonal $i = j$ the
support condition holds, so $N[f(i), g_{\mathrm{col}}(i)] \ne 0$; off the
diagonal it fails, so those entries are $0$. Apply Lemma 3.2. $\square$

Theorem 6.2 is the technical bridge to everything in the next two sections, and
it is also the form in which the theory becomes conjecturally applicable to the
*truncated* comb's transform, whose amplitudes are Dirichlet kernels rather than
Kronecker deltas.

---

## 7. The Fourier transform of an exact comb

For this section assume the *divisible* (exact, non-truncated) case: the
register dimension factors as $n = mr$, so the comb
$\sum_{j<m}|x_0 + jr\rangle$ has exactly $m$ teeth and wraps the register
perfectly.

**Theorem 7.1 (Sharp-peak theorem).** Let $\zeta = e^{2\pi i/n}$ with $n = mr$.
Then the (unnormalized) discrete Fourier transform of the exact comb is
$$\Psi(k) \;=\; \sum_{j<m} \zeta^{(x_0 + jr)k} \;=\; \begin{cases} m\,\zeta^{x_0 k}, & m \mid k,\\ 0, & \text{otherwise.}\end{cases}$$

*Proof sketch.* Factor out $\zeta^{x_0 k}$ and evaluate the geometric sum
$\sum_{j<m}(\zeta^{rk})^{j}$. Since $\zeta^{r} = e^{2\pi i/m}$, the ratio is an
$m$-th root of unity, equal to $1$ exactly when $m \mid k$ (giving $m$) and
summing to $0$ otherwise. $\square$

**Corollary 7.2 (Support form).** $\Psi(k) \neq 0 \iff m \mid k$. The transform
of a comb of period $r$ is a comb of period $m = n/r$, decorated with phases.

**Theorem 7.3 (Transform rank law).** Reshape the transformed state across the
cut $n = PQ$, $\Psi[p,q] = \Psi(pQ+q)$. If $m \le Q$ then
$$\operatorname{rank}\Psi \;=\; \min\!\left(P,\ \frac{m}{\gcd(m,Q)}\right).$$

*Proof.* By Theorem 7.1,
$\Psi = \mathrm{diag}(d)\, M_m \,\mathrm{diag}(e)$ where $M_m$ is the $0/1$ comb
matrix of period $m$ and offset $0$, $d_p = m\,\zeta^{x_0 pQ}$ and
$e_q = \zeta^{x_0 q}$, all nonzero. Apply Lemma 3.3 and Theorem 4.4. (A second,
independent proof of the lower bound comes from Theorem 6.2 and Corollary 7.2,
and this is the argument that survives into the approximate setting where no
exact phase factorization is available.) $\square$

So the Fourier transform does not *preserve* bond dimension — it **inverts the
period**, $r \mapsto m = n/r$. Hard inputs become easy outputs and conversely.
That inversion is quantitatively rigid:

**Lemma 7.4.** If $Q > 0$ and $Q \mid rm$ then $Q \le \gcd(r,Q)\gcd(m,Q)$.

*Proof sketch.* $\gcd(Q, rm) \mid \gcd(Q,r)\gcd(Q,m)$, and $\gcd(Q,rm) = Q$
because $Q \mid rm$. $\square$

**Theorem 7.5 (Complementarity).** Let $n = rm = PQ$ with $Q > 0$, $r \le Q$ and
$m \le Q$. Then
$$\operatorname{rank}(M) \cdot \operatorname{rank}(\Psi) \;\le\; P \;=\; \frac{n}{Q}.$$

*Proof.* By Theorems 4.4 and 7.3 the two ranks are at most $s(r,Q)$ and
$s(m,Q)$. Their product is
$$\frac{r}{\gcd(r,Q)}\cdot\frac{m}{\gcd(m,Q)} = \frac{rm}{\gcd(r,Q)\gcd(m,Q)} \le \frac{rm}{Q} = P,$$
using Lemma 7.4. $\square$

**Corollary 7.6.** At a balanced cut $P = Q = \sqrt n$, at least one of the two
bond dimensions is at most $n^{1/4}$: an exact comb cannot be
tensor-train-hard both in position space and in frequency space.

**Example.** $n = 12 = 3 \cdot 4$, cut $P = 3$, $Q = 4$, input period $r = 3$,
co-period $m = 4$. The input rank is $\min(3, 3/\gcd(3,4)) = 3$; the output rank
is $\min(3, 4/\gcd(4,4)) = 1$. Their product is $3 = P$, so the bound is
attained.

Theorem 7.5 is a rigorous, quantitative version of the "tensor-train Fourier
emulation" template — and it is *positive*: whenever the comb is exact, one side
of the transform is cheap and the transform can be pushed through classically at
cost governed by that cheap side.

---

## 8. Where de-quantization stops: the divisibility boundary

Theorem 7.5 requires $n = rm$, i.e. $r \mid n$. Quantum order finding runs on a
binary register, $n = 2^L$, and the order $r = \mathrm{ord}_N(y)$ is generically
odd (and in any case has a large odd part). An odd $r > 1$ never divides $2^L$.
The realized post-measurement state is therefore the **truncated** comb
$\{x < n : x \equiv x_0 \pmod r\}$, whose teeth stop at a ragged edge — precisely
the state analysed in Sections 4–5.

The consequences are sharp:

* By Theorem 5.2, the truncated comb has bond dimension $\min(2^a, m)$ with $m$
  the odd part of $r$; for a generic order this is exponential in $L$ at any
  reasonably balanced cut.
* By Theorem 5.4, *no* tensor-train representation escapes this: it is a
  statement about the state, not about a particular algorithm for building one.
* Since a tensor-train sweep costs $\Omega(D^2)$ per site, an emulation of the
  Fourier transform on this state costs $\Omega(m^2)$ per site.

Hence the de-quantization boundary is located exactly at the divisibility
relation $r \mid n$:

| | $r \mid n$ (exact comb) | $r \nmid n$ (truncated comb, the real case) |
|---|---|---|
| input bond dimension | $\min(P, r/\gcd(r,Q))$ | $\min(2^a, \text{odd part of } r)$ |
| output bond dimension | $\min(P, m/\gcd(m,Q))$ | $\min(P, J)$, $J$ = tooth count (Section 10) |
| product of the two | $\le n/Q$ (Theorem 7.5) | no such bound |
| classical emulation | efficient on the cheap side | $\Omega(m^2)$ per site |

There is a pleasing structural irony. The reason order finding needs a
continued-fraction post-processing step is exactly that $r \nmid n$: the measured
frequency is only an approximate multiple of $n/r$. The imperfection that
complicates the algorithm is the same imperfection that immunizes it against
tensor-train emulation.

It bears emphasis what is *not* claimed. Nothing here shows that factoring is
classically hard, nor that some de-quantization avoiding the comb entirely is
impossible. What is established is that the specific and much-discussed route —
represent the post-measurement state as a low-rank tensor train and sweep the
Fourier transform through it — is closed by an exact formula rather than by an
asymptotic hunch.

---

## 9. Algorithms

Three procedures follow directly from the theory and are worth stating
explicitly, since they are what one would actually run.

**Algorithm A (Exact bond dimension of a comb).** Input $P, Q, r, x_0$ with
$0 < r \le Q$. Output the exact Schmidt rank across the cut.
Compute $g \leftarrow \gcd(r,Q)$, $s \leftarrow r/g$, return $\min(P,s)$.
Cost: one Euclidean algorithm, $O(\log r)$ bit operations. This replaces an
$O(PQ\min(P,Q))$ Gaussian elimination on the reshaped matrix by a two-line
computation; the correctness is Theorem 4.4.

**Algorithm B (Exact rank-$s$ tensor train of a comb).** Input $P, Q, r, x_0$.
Output cores $A \in \{0,1\}^{P\times s}$, $B \in \{0,1\}^{s\times Q}$ with
$AB = M$. For each $p$ set $c \leftarrow (pQ \bmod r)/g$ and $A[p,c] \leftarrow 1$;
for each $c, q$ set $B[c,q] \leftarrow [(cg + q)\bmod r = x_0 \bmod r]$. Cost
$O(Ps + sQ)$ and, by Theorem 4.4, the bond $s$ is optimal whenever $s \le P$.

**Algorithm C (Tensor-train emulation of the Fourier transform, with its own
cost certificate).** Given a state as a tensor train of bond dimension $D$,
alternately contract cores with local phase operators and re-truncate by
singular value decomposition, at cost $O(LD^3)$ overall. Before running it,
Algorithm A certifies the required $D$: for a comb input, $D = \min(P, s(r,Q))$,
so the emulation is efficient exactly when the reduced period is small. For a
binary register and an order with a large odd part, Algorithm A returns an
exponential $D$ and the emulation is refused rather than attempted — the cost
certificate is available before any linear algebra is done.

---

## 10. Open problems

Two questions remain. The first is settled here in corrected form, with one
residual case; the second is open. Both are stated so that they can be attacked
directly.

### 10.1 The transformed truncated comb: a corrected law

One naturally conjectures a *Dirichlet smearing* principle: that for $n = 2^L$
and odd $r \nmid n$ the transformed truncated comb
$$\Psi(k) = \sum_{\substack{x<n\\ x\equiv x_0\ (r)}} e^{2\pi i x k/n}$$
never vanishes, so that Theorem 6.2 immediately gives maximal Schmidt rank.
That statement is **false**, and the correct statement is an exact count.

**Proposition 10.1 (Zero-count law).** Let $n = 2^L$, let $r$ be odd, let
$x_0 < r$, and let $J = \#\{x < n : x \equiv x_0 \ (\mathrm{mod}\ r)\}$ be the
number of teeth. Then $\Psi(k) = 0$ for exactly $\gcd(n, J) - 1$ values of
$k \in \{0,\dots,n-1\}$, namely the nonzero multiples of $n/\gcd(n,J)$. In
particular the spectrum has full support if and only if $J$ is odd.

*Proof.* Write $\omega = e^{2\pi i/n}$ and $x_j = x_0 + jr$ for $j < J$. Then
$\Psi(k) = \omega^{x_0k}\sum_{j<J}(\omega^{rk})^j$. Since $r$ is odd and $n$ is a
power of two, $\gcd(r,n) = 1$, so $\omega^{rk} = 1$ iff $n \mid k$, i.e. iff
$k = 0$; and $\Psi(0) = J \ne 0$. For $k \ne 0$ the geometric sum equals
$(1-\omega^{rkJ})/(1-\omega^{rk})$, which vanishes iff $n \mid rkJ$, iff
$n \mid kJ$ (again because $\gcd(r,n)=1$), iff $(n/\gcd(n,J)) \mid k$. There are
$\gcd(n,J) - 1$ such $k$ in $\{1,\dots,n-1\}$. $\square$

The smallest counterexample to the naive guess is $n = 16$, $r = 5$, $x_0 = 0$:
here $J = 4$ and the transform vanishes at $k = 4, 8, 12$. Exhaustive
computation over $n = 2^L$ for $2 \le L \le 9$, odd $r \le 11$ and $x_0 \in\{0,1\}$
confirms the count $\gcd(n,J)-1$ in every case, with no exceptions.

The zeros are a vanishing fraction of the spectrum, and the intended conclusion
survives them. Expanding
$$\Psi[p,q] = \sum_{j<J} \omega^{x_j pQ}\cdot\omega^{x_j q}$$
exhibits the reshaped transform as a product $AB$ with $A[p,j] = \omega^{x_jpQ}$
of size $P \times J$ and $B[j,q] = \omega^{x_jq}$ of size $J \times Q$. Hence:

**Proposition 10.2 (Tooth bound and its saturation for few teeth).**
$\operatorname{rank}\Psi \le \min(P,Q,J)$ always. If moreover $J \le \min(P,Q)$,
then $\operatorname{rank}\Psi = J$ exactly.

*Proof sketch.* The inequality is the factorization above. For the equality,
$B$ is a Vandermonde matrix in the nodes $\omega^{x_j}$, which are distinct
because the $x_j$ are distinct residues mod $n$; and $A^{\mathsf T}$ is a
Vandermonde matrix in the nodes $\omega^{x_jQ}$, which are distinct because $r$
is odd and $P$ is a power of two, so the $x_j$ are distinct modulo $P = n/Q$ for
$j < J \le P$. Both factors therefore have rank $J$, and Sylvester's rank
inequality gives $\operatorname{rank}(AB) \ge \operatorname{rank}A +
\operatorname{rank}B - J = J$. $\square$

**Conjecture 1 (Saturation for many teeth).** With $n = 2^L$, $r$ odd, and a cut
$n = PQ$ with $P \le Q$: if $J \ge P$ then $\operatorname{rank}\Psi = P$, i.e. the
transformed truncated comb has *maximal* Schmidt rank.

*Evidence and heuristic.* Cauchy–Binet expands each $P \times P$ minor of
$AB$ as a sum, over $P$-subsets $S$ of the teeth, of products of two Vandermonde
determinants, each individually nonzero; the conjecture is that these terms do
not conspire to cancel. Exact computation — carried out in a finite field
containing a genuine element of order $n$, so that no floating-point tolerance is
involved — gives $\operatorname{rank}\Psi = \min(P,J)$ in every case tested for
$n = 16, 64, 256$, odd $r \le 13$, $x_0 \in \{0,1\}$. Proving the conjecture
would show that the tensor-train emulation of order finding is maximally
expensive on *both* sides of the transform, closing the escape route left open by
the complementarity theorem. (Note that floating-point rank estimation is
misleading here: for small $r$ the transformed comb has rapidly decaying singular
values and *appears* rank-deficient at tolerance $10^{-9}$ while being exactly of
full rank. This is exactly why the robustness question below is the substantive
one.)

### 10.2 Robustness

**Conjecture 2 (No $\varepsilon$-de-quantization).** Let $M$ be the
comb matrix with $r \le Q$ and $K = \min(P, r/\gcd(r,Q))$. Then for every matrix
$B$ of rank at most $D < K$,
$$\|M - B\|_F^2 \;\ge\; (K - D)\cdot \min_c\,(\mu_c\nu_c),$$
where $\mu_c$ is the number of left indices and $\nu_c$ the number of right
indices in residue class $c$. In particular, a matrix product state of bond
dimension $D = \mathrm{poly}(L)$ cannot approximate the qubit comb to relative
Frobenius error $o(1)$ when the odd part of $r$ is exponential.

*Heuristic.* The comb has an explicit singular value decomposition. It is a sum
of $K$ rank-one terms whose left factors are pairwise orthogonal indicator
vectors and whose right factors are likewise pairwise orthogonal indicators, so
its singular values are exactly $\sigma_c = \sqrt{\mu_c\nu_c}$ — no numerical
computation needed. The Eckart–Young theorem then converts the exact rank
statement into the stated approximation lower bound. This matters because every
de-quantization claim in the literature is approximate; exact-rank theorems do
not by themselves rule out $\varepsilon$-close low-rank surrogates, and
Conjecture 2 would.

---

## 11. Discussion and future work

**What the results say about the three de-quantization templates.**
Template 1 (bounded entanglement) is confirmed as the right frame and then
turned against the quantum-advantage-skeptical reading: the comb's entanglement
entropy across a balanced cut is $\log_2 \min(2^a, m)$, which is linear in $L$
for a generic order, so the hypothesis "$S_{\max}$ bounded" simply fails.
Template 3 (tensor-train Fourier emulation) is proved correct in the exact
regime — and Theorem 7.5 gives it a quantitative form stronger than usually
stated — while being shown inapplicable in the regime order finding occupies.
Template 2 (low-rank inversion) is untouched by these results, as it concerns a
different structural hypothesis.

**Sharpness.** Every hypothesis in the main theorem is used. Dropping $r \le Q$
breaks the lower bound (some residue classes become empty on the right);
dropping the $P$ from the minimum breaks the formula ($P=4$, $Q=16$, $r=5$);
dropping coprimality in Corollary 4.5 breaks the "rank $=r$" reading dramatically
($r \mid Q$ gives rank $1$). The general formula $\min(P, r/\gcd(r,Q))$ is the
unique statement consistent with all boundary cases.

**Directions.** Beyond the two conjectures: (i) extend the rank computation to
multi-cut matrix product states, where the relevant object is the vector of
ranks across all $L-1$ cuts and one expects the odd-part law to hold cutwise;
(ii) analyse *noisy* combs, where a small fraction of teeth is corrupted, using
the explicit singular value decomposition of Conjecture 2 as the unperturbed
reference; (iii) study which other quantum subroutines have inputs whose
compressibility is controlled by a purely arithmetic invariant, as the comb's is
by the odd part of its period; (iv) quantify how close a period must be to a
power of two before the comb becomes approximately compressible, which is the
natural interpolation between the two branches of the dichotomy.

---

## 12. Summary of results

1. **Bond dimension equals Schmidt rank.** A tensor train across a cut with
   inner index $D$ exists iff $D \ge \operatorname{rank}$ of the reshaped
   amplitude matrix.
2. **Exact rank of a periodic comb.** For $0 < r \le Q$,
   $\operatorname{rank} = \min(P, r/\gcd(r,Q))$, independent of the offset.
3. **Odd-part law.** Across a binary cut, the rank is $\min(2^a, m)$ where $m$ is
   the odd part of the period; the comb is a product state iff the period is a
   power of two.
4. **Exponential barrier.** On $L = 2a$ qubits at the balanced cut, the comb of
   period $2^a - 1$ forces bond dimension $\ge 2^{L/2}-1$.
5. **Support-only lower bound.** Any matrix supported exactly on a comb pattern
   has rank at least $\min(P, r/\gcd(r,Q))$, whatever its nonzero values.
6. **Phases are free.** Invertible diagonal rescalings on either side preserve
   rank, so local phase gates cannot alter bond dimension.
7. **Transform law.** For an exact comb in a register of size $n = mr$, the
   Fourier-transformed state has rank $\min(P, m/\gcd(m,Q))$: the period is
   inverted, $r \mapsto n/r$.
8. **Complementarity.** In the exact case the product of the input and output
   bond dimensions is at most $n/Q$; at a balanced cut one side is always
   $\le n^{1/4}$.
9. **The boundary.** All efficiency statements require $r \mid n$; a binary
   register with an order having a large odd part violates it, and there the
   tensor-train route is sealed at $\Omega(m^2)$ per site.
