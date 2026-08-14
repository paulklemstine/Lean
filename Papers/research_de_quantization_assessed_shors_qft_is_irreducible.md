# De-Quantization Assessed: The Irreducibility of Shor's Quantum Fourier Transform

**Author:** Aristotle
**Date:** 2026-08-14

---

## Abstract

Tensor-network methods have de-quantized a growing list of quantum algorithms: whenever a quantum state admits a matrix-product (tensor-train) representation of small bond dimension $D$ on $n$ sites, its quantum Fourier transform can be executed classically in time $O(nD^2)$, and any claimed quantum speedup for that state collapses. We assess this proposal against the state at the heart of Shor's factoring algorithm and obtain a decisive negative result, with exact — not asymptotic — constants.

Let $a$ have multiplicative order $r$ modulo $N$, and let the exponent register have size $Q = r\,m$. We prove: (i) the full register state $Q^{-1/2}\sum_x |x\rangle|a^x \bmod N\rangle$ has Schmidt rank **exactly** $r$ across the register cut, with a perfectly **flat** Schmidt spectrum, entanglement entropy $\log r$ and mutual information $2\log r$; (ii) the periodic comb $c_x = [\,x \equiv x_0 \ (\mathrm{mod}\ r)\,]$ — the actual input of the Fourier transform — has Schmidt rank **exactly** $\min\!\big(C,\,r/\gcd(r,B)\big)$ across the cut $x = b + Bc$ with $BC = Q$ and $r \le B$, sharpening the folklore estimate $\Theta(\min(r, Q/r))$ to an exact arithmetic law; (iii) the Fourier output is the dual comb of period $m$ conjugated by diagonal phase matrices, hence has rank exactly $\min\!\big(C,\, m/\gcd(m,B)\big)$ — both endpoints are exponentially entangled; (iv) truncation to bond dimension $D$ retains squared overlap at most $D/r$, a bound attained by truncation, corresponding to a squared Frobenius error at least $2 - 2\sqrt{D/r}$ (this corrects the informally quoted $(D/r)^2$); (v) every classical sampler supported on a set $S$ is at total-variation distance at least $1 - |S|/r$ from the ideal output; and (vi) a bond-dimension-$\chi$ representation certifies the existence of $k \le \chi$ with $a^k \equiv 1$, i.e. a polynomially compressible instance is a classically easy instance, while one ideal output sample yields the order by continued fractions and hence, for even order with $a^{r/2} \not\equiv -1$, a nontrivial factor of $N$.

We also settle the natural conjecture that the two Fourier endpoints are *complementary* (one must be expensive): it is **false** — for $Q = 36$, $r = m = 6$, $B = C = 6$ both endpoints are product states — and we replace it by the correct statement, an lcm law: $\min\!\big(C, \mathrm{per}(\mathrm{lcm}(r,m), B)\big) \le \mathrm{rank}_{\mathrm{in}}\cdot\mathrm{rank}_{\mathrm{out}}$, with simultaneous collapse only on cuts satisfying $\mathrm{lcm}(r,m) \mid B$ — impossible for a power-of-two block size and an odd order. The conclusion: the tensor-train Fourier theorem is mathematically valid but inapplicable to Shor's factoring case; de-quantizing Shor by these means is equivalent to a polynomial-time classical factoring algorithm.

**Keywords:** Shor's algorithm, quantum Fourier transform, Schmidt rank, matrix-product states, bond dimension, de-quantization, flat entanglement spectrum, order finding.

---

## 1. Introduction

### 1.1 The de-quantization programme

A quantum state on $n$ qubits is a unit vector in $\mathbb{C}^{2^n}$, and writing it down explicitly is out of the question for interesting $n$. The insight underlying tensor-network simulation is that physically relevant states are usually far from generic: they live on a low-dimensional manifold parameterized by a chain of small tensors. A **matrix-product state** (MPS), or **tensor train**, represents the amplitude of the basis state $|x_1 x_2 \cdots x_n\rangle$ as a product

$$\psi(x_1,\dots,x_n) = A^{(1)}_{x_1} A^{(2)}_{x_2}\cdots A^{(n)}_{x_n},$$

with each $A^{(i)}_{x_i}$ a matrix of size at most $D \times D$. The parameter $D$ is the **bond dimension**; the representation costs $O(nD^2)$ numbers instead of $2^n$.

The bond dimension has an exact operational meaning. For each bipartition of the sites into a left block and a right block, the state has a coefficient matrix $M$, and its **Schmidt rank** — the ordinary matrix rank of $M$ — is a lower bound for the bond dimension of *any* MPS representation across that cut. Everything downstream (entanglement entropy, compressibility, the accuracy of truncation) is read off the singular values of $M$, the **Schmidt spectrum**.

Once a state has small bond dimension, most of quantum computation becomes classically tractable on it. In particular there is a clean theorem, which we will call the *tensor-train Fourier theorem*: **a state with bond dimension $D$ on $n$ sites can be quantum-Fourier-transformed classically in time $O(nD^2)$**, by contracting the transform's two-site gates into the train and re-compressing. This is the engine behind a series of successful de-quantizations, and it raises the obvious question about the most famous quantum algorithm of all.

### 1.2 The question

Shor's algorithm factors $N$ by finding the multiplicative order of a random $a$ coprime to $N$. It prepares a two-register superposition, measures (or discards) the second register, applies a quantum Fourier transform to the first, and samples. Its exponential advantage rests entirely on the Fourier step. If the states in play had polynomial bond dimension, the tensor-train Fourier theorem would render the whole thing classical.

The question splits into three concrete sub-questions:

1. **What is the entanglement of the state Shor actually prepares?**
2. **What is the entanglement of the Fourier transform's input and output, across the cuts a tensor train uses?**
3. **If both are large, how badly does truncation fail — and is there any regime where a low-rank emulation works?**

This paper answers all three exactly. The answers are, respectively: rank exactly $r$ with a flat spectrum; rank exactly $\min(C, r/\gcd(r,B))$ at the input and $\min(C, m/\gcd(m,B))$ at the output; and truncation fidelity exactly $D/r$, with the low-rank regime coinciding precisely with small order, i.e. with classically easy instances.

### 1.3 Contributions

* **An exact Schmidt calculus for fibre-matching states** (Section 3), covering every state of the form "run a classical function in superposition and compare labels". Rank, Schmidt coefficients, entropy and mutual information are all given in closed form.
* **Exact entanglement of the Shor register state** (Section 4): rank $r$, flat spectrum, entropy $\log r$, mutual information $2\log r$.
* **A sharp bond-dimension law for the periodic comb** (Section 5): rank exactly $\min(C, r/\gcd(r,B))$, strictly sharper than the folklore $\Theta(\min(r,Q/r))$, together with the exact characterization of the product-state cuts ($r \mid B$) and the flat-spectrum regime.
* **The Fourier output** (Section 6): the transformed comb is the dual comb dressed by diagonal phases; its distribution is uniform on the $r$ multiples of $m$; its rank obeys the same law with $r \leftrightarrow m$.
* **Truncation and sampling bounds** (Section 7): flat-spectrum Eckart–Young with attainment, the Frobenius form, and the total-variation bound $1 - |S|/r$ for small-support samplers.
* **The endpoint complementarity question settled** (Section 8): the naive conjecture is refuted by an explicit counterexample; the correct lcm law is proved; and qubit cuts of odd-order combs are shown never to be aligned.
* **The equivalence** (Section 9): small bond dimension certifies small order; one ideal sample factors $N$; hence de-quantization of Shor is equivalent to classical polynomial-time factoring.

---

## 2. Setting and notation

Throughout, $N > 1$ is the integer to be factored and $a$ is an element of the unit group modulo $N$, of multiplicative order

$$r = \operatorname{ord}_N(a) = \min\{k \ge 1 : a^k \equiv 1 \ (\mathrm{mod}\ N)\}.$$

The exponent register has size $Q$. In order to state exact results we work in the **commensurate model** $Q = r\,m$ with $m \ge 1$ an integer; this is the standard idealization in which the Fourier peaks are exact, and it is the regime most favourable to a classical emulator, since incommensurability only spreads the output further and raises ranks. We write $[P]$ for the indicator of a proposition $P$ (equal to $1$ if $P$ holds and $0$ otherwise).

**Bipartite states as matrices.** A pure state on a bipartite system with index sets $\mathcal A, \mathcal B$ is a matrix $M \in \mathbb{C}^{\mathcal A \times \mathcal B}$; it is **normalized** when $\|M\|_F^2 = \sum_{f,g}|M_{f,g}|^2 = 1$. Its **Schmidt rank** is $\operatorname{rank} M$; its **Schmidt spectrum** is the multiset of singular values $w_1 \ge w_2 \ge \cdots \ge 0$; its **entanglement entropy** is $S(M) = -\sum_j w_j^2 \log w_j^2$ and its **mutual information** is $I(M) = 2S(M)$ for a pure state. The spectrum is **flat** when all nonzero $w_j$ are equal, which for a normalized state of rank $\rho$ means $w_j = \rho^{-1/2}$ and $S(M) = \log \rho$, the maximum compatible with rank $\rho$. Logarithms are natural; dividing by $\log 2$ converts to bits.

**Schmidt form.** We say $(L, w, R)$ is a *Schmidt form* for $M$ when $M = L\,\mathrm{diag}(w)\,R^{\!*}$ with $L^{*}L = I$, $R^{*}R = I$ and $w$ a nonnegative vector. If all entries of $w$ are strictly positive, then $\operatorname{rank} M$ equals the length of $w$ and $w$ is the Schmidt spectrum.

**Bond dimension.** We write $\mathrm{BD}(M) \le \chi$ to mean that $M$ factors as $M = XY$ with $X \in \mathbb{C}^{\mathcal A \times \chi}$ and $Y \in \mathbb{C}^{\chi \times \mathcal B}$; this is precisely the condition for a matrix-product representation of bond dimension $\chi$ across the given cut. The elementary but decisive fact used throughout is:

$$\mathrm{BD}(M) \le \chi \implies \operatorname{rank}(M) \le \chi.$$

**Register cuts.** A tensor train over the exponent register with $Q = B\,C$ splits $x$ into a low part and a high part:

$$x = b + B\,c, \qquad 0 \le b < B, \quad 0 \le c < C .$$

Every result below is stated for an arbitrary such cut, so it applies to every position of the cut in the chain, in particular to qubit cuts where $B$ and $C$ are powers of two.

---

## 3. Fibre-matching states: an exact Schmidt calculus

The states produced by "evaluate a classical function in superposition, then compare" all share a shape, and for that shape the Schmidt decomposition can be written down without any computation.

> **Definition 3.1 (Fibre-matching state).** Let $\mathcal A$, $\mathcal B$ be finite index sets, $\Sigma$ a finite label set, and $u : \mathcal A \to \Sigma$, $v : \mathcal B \to \Sigma$ label maps. For $c \in \mathbb{R}$ the **fibre-matching state** is
> $$M^{u,v,c}_{f,g} = c\,[\,u(f) = v(g)\,], \qquad f \in \mathcal A,\ g \in \mathcal B.$$
> Write $\phi_u(s) = |u^{-1}(s)|$ for the **fibre cardinality** of a label, and
> $$\mathrm{Match}(u,v) = \operatorname{im}(u) \cap \operatorname{im}(v)$$
> for the set of labels realized on both sides.

> **Theorem 3.2 (Exact Schmidt decomposition).** Define, for $s \in \mathrm{Match}(u,v)$, the normalized fibre indicators
> $$L_{f,s} = \frac{[\,u(f) = s\,]}{\sqrt{\phi_u(s)}}, \qquad R_{g,s} = \frac{[\,v(g) = s\,]}{\sqrt{\phi_v(s)}}, \qquad w_s = c\,\sqrt{\phi_u(s)\,\phi_v(s)} .$$
> Then $L^{*}L = I$, $R^{*}R = I$ and $M^{u,v,c} = L\,\mathrm{diag}(w)\,R^{*}$. Consequently, for $c \neq 0$,
> $$\operatorname{rank} M^{u,v,c} = |\mathrm{Match}(u,v)| .$$

*Proof sketch.* Both $L$ and $R$ have orthogonal columns because distinct labels have disjoint fibres, and each column is normalized by construction; positivity of the fibre cardinalities on $\mathrm{Match}(u,v)$ is exactly the statement that each such label is realized on both sides. Expanding the product $L\,\mathrm{diag}(w)\,R^{*}$ at $(f,g)$ gives $\sum_s [u(f)=s][v(g)=s]\,c\,\sqrt{\phi_u\phi_v}/\sqrt{\phi_u\phi_v} = c\,[u(f)=v(g)]$, because at most one $s$ contributes and it contributes only when the labels agree — and when they agree, that common label lies in $\mathrm{Match}(u,v)$. Since all $w_s$ are nonzero for $c\ne 0$, the number of columns is the rank. $\square$

> **Corollary 3.3 (Entanglement in closed form).** With $p_s = c^2 \phi_u(s)\phi_v(s)$ (so $\sum_{s \in \mathrm{Match}} p_s = 1$ exactly when the state is normalized),
> $$S(M^{u,v,c}) = \sum_{s\in\mathrm{Match}(u,v)} -p_s \log p_s , \qquad I(M^{u,v,c}) = 2\,S(M^{u,v,c}).$$
> If the state is **balanced**, i.e. $p_s = |\mathrm{Match}(u,v)|^{-1}$ for all matching $s$ — in particular whenever $u$ and $v$ are injective, or whenever all fibres on each side have equal size — then the Schmidt spectrum is flat and
> $$S = \log |\mathrm{Match}(u,v)| ,\qquad I = 2\log|\mathrm{Match}(u,v)| .$$

> **Corollary 3.4 (Tensor-network obstruction).** For $c \neq 0$, every matrix-product representation of $M^{u,v,c}$ across the cut has bond dimension at least $|\mathrm{Match}(u,v)|$; no representation of bond dimension $\chi < |\mathrm{Match}(u,v)|$ exists.

Two crude but useful bounds follow from $\mathrm{Match}(u,v) \subseteq \operatorname{im}(u) \cap \operatorname{im}(v)$: the rank never exceeds $|\Sigma|$, nor $|\mathcal A|$, nor $|\mathcal B|$.

The point of Theorem 3.2 is that it converts every entanglement question about such states into a *counting* question about labels, and the counting questions arising from Shor's algorithm are elementary number theory.

---

## 4. The Shor register state

> **Definition 4.1.** A function $F$ on $\{0,1,\dots,Q-1\}$ has **exact period $r$** if
> $$F(x) = F(x') \iff x \equiv x' \pmod r .$$
> The **Shor register state** associated with $F$ is the bipartite state
> $$\Psi_{F} = \frac{1}{\sqrt Q}\sum_{x < Q} |x\rangle \otimes |F(x)\rangle, \qquad (\Psi_F)_{x,y} = \frac{[\,F(x) = y\,]}{\sqrt Q}.$$

The map $x \mapsto a^x \bmod N$ has exact period $r = \operatorname{ord}_N(a)$: indeed $a^i = a^j$ if and only if $i \equiv j \pmod{r}$.

> **Theorem 4.2 (Exact entanglement of Shor's state).** Let $Q = r\,m$ with $r, m \ge 1$ and let $F$ have exact period $r$. Then across the exponent/function cut:
> 1. $\Psi_F$ is normalized;
> 2. $\operatorname{rank}\Psi_F = r$ exactly;
> 3. the Schmidt spectrum is flat, all $r$ coefficients equal to $r^{-1/2}$;
> 4. $S(\Psi_F) = \log r$ and $I(\Psi_F) = 2\log r$;
> 5. every matrix-product representation across this cut has bond dimension at least $r$; none of bond dimension $\chi < r$ exists.

*Proof sketch.* $\Psi_F$ is the fibre-matching state with $u = F$, $v = \mathrm{id}$, $c = Q^{-1/2}$. The identity has all fibres of size $1$ and full image, so $\mathrm{Match}(F,\mathrm{id}) = \operatorname{im}(F)$, and exact periodicity gives $|\operatorname{im}(F)| = r$ (one value per residue class) and $\phi_F(y) = m$ for each realized value $y$ (each residue class in $\{0,\dots,rm-1\}$ has exactly $m$ elements). Hence Theorem 3.2 gives rank $r$ and Schmidt coefficients $w_y = Q^{-1/2}\sqrt{m\cdot 1} = (rm)^{-1/2}\sqrt m = r^{-1/2}$, all equal: flat, normalized, and $S = \log r$ by Corollary 3.3. Item 5 is Corollary 3.4. $\square$

For factoring-relevant instances the order $r$ is typically of size comparable to $N$, i.e. exponential in the bit length $n = \log_2 N$. Theorem 4.2 therefore says: the state Shor's algorithm prepares has *maximal* entanglement compatible with its rank, and its rank is exponential. A tensor-train representation of it is exponentially large.

The entropy statement deserves a remark. $S = \log(\mathrm{rank})$ is the equality case of the elementary inequality $S \le \log(\mathrm{rank})$, and the equality case holds *only* for a flat spectrum. So statement 4 and statement 3 are equivalent given normalization — a convenient route to flatness that we use repeatedly: compute the entropy, compare to the log of the rank, conclude flatness.

---

## 5. The periodic comb: exact bond dimension of the Fourier input

After the function register is measured (or traced out), the exponent register is left in a residue class:

> **Definition 5.1 (Periodic comb across a cut).** For $Q = BC$, $r \ge 1$, offset $x_0$ and amplitude $\alpha \neq 0$, the **comb** is the state on the split register given by
> $$\mathrm{Comb}_{B,C,r,x_0}(b,c) = \alpha\,\big[\,(b + Bc) \equiv x_0 \ (\mathrm{mod}\ r)\,\big], \qquad 0\le b<B,\ 0\le c<C .$$

> **Lemma 5.2 (The comb is fibre-matching).** $\mathrm{Comb}_{B,C,r,x_0}$ is the fibre-matching state with label set $\mathbb{Z}/r\mathbb{Z}$ and labels
> $$u(b) = b \bmod r, \qquad v(c) = x_0 - Bc \bmod r .$$

*Proof sketch.* $b + Bc \equiv x_0$ holds if and only if $b \equiv x_0 - Bc$, i.e. $u(b) = v(c)$, both read in $\mathbb{Z}/r\mathbb{Z}$. $\square$

The low half carries "the residue I supply"; the high half carries "the residue I still need". Everything now reduces to counting the residues each side can realize.

> **Proposition 5.3 (Generic upper bound).** $\operatorname{rank}\mathrm{Comb}_{B,C,r,x_0} \le \min\{r, B, C\}$.

*Proof sketch.* The rank is the number of shared labels, which is at most the size of the label set $\mathbb{Z}/r\mathbb{Z}$ and at most the number of values realized on either side, which is bounded by $B$ and by $C$ respectively. $\square$

The exact value requires the arithmetic of the high-half labels. As $c$ ranges over $0,1,2,\dots$, the label $v(c)$ moves in steps of $-B$ modulo $r$; the reachable set is the coset $x_0 + \langle B\rangle$ of the subgroup generated by $B$ in $\mathbb{Z}/r\mathbb{Z}$, and that subgroup has order $r/\gcd(r,B)$. This motivates:

> **Definition 5.4 (Cut period).** $\mathrm{per}(r, B) = r/\gcd(r,B)$.

Equivalently, $\mathrm{per}(r,B)$ is the least $k \ge 1$ with $r \mid Bk$: it is the number of blocks the high half must advance before the comb pattern repeats.

> **Theorem 5.5 (Sharp bond dimension of the comb).** Assume $r \ge 1$, $\alpha \neq 0$ and $r \le B$. Then
> $$\boxed{\ \operatorname{rank}\mathrm{Comb}_{B,C,r,x_0} \;=\; \min\Big(C,\ \frac{r}{\gcd(r,B)}\Big).\ }$$

*Proof sketch.* Since $r \le B$, the low-half label map $b \mapsto b \bmod r$ is surjective onto $\mathbb{Z}/r\mathbb{Z}$ (every residue has a representative below $B$). Hence $\mathrm{Match}(u,v) = \operatorname{im}(v)$ and the rank is the number of distinct values of $v(c) = x_0 - Bc$ for $c < C$. Two indices $c, c'$ give the same label iff $r \mid B(c-c')$ iff $\mathrm{per}(r,B) \mid c - c'$; so $v$ is injective on residues modulo $\mathrm{per}(r,B)$ and periodic with that period, giving exactly $\min(C, \mathrm{per}(r,B))$ distinct values. $\square$

Three consequences are worth recording separately.

> **Corollary 5.6 (Coprime cut: full rank).** If $r \le B$, $r \le C$ and $\gcd(B,r) = 1$, then $\operatorname{rank}\mathrm{Comb} = r$ exactly; consequently every matrix-product representation across the cut has bond dimension at least $r$, and none of bond dimension $\chi < r$ exists.

> **Corollary 5.7 (Aligned cut: product state).** If $r \le B$, $C \ge 1$ and $r \mid B$, then $\operatorname{rank}\mathrm{Comb} = 1$: the comb factorizes across the cut. Conversely, by Theorem 5.5 the rank is $1$ (for $C \ge 2$) only if $\mathrm{per}(r,B) = 1$, i.e. only if $r \mid B$.

> **Corollary 5.8 (Qubit cuts never compress an odd-order comb).** Let $r > 1$ be odd, $B = 2^k \ge r$ and $C \ge r$. Then $\gcd(r, B) = 1$, hence $\operatorname{rank}\mathrm{Comb} = r$; in particular the rank is at least $2$ and the comb is never a product state across a power-of-two cut.

*Proof sketch.* If $r \mid 2^k$ with $r$ odd then $r$ is coprime to $2^k$ and divides it, so $r \mid 1$, contradicting $r > 1$. Apply Corollary 5.6. $\square$

Corollary 5.7 is the crux of the assessment: the *only* cuts that compress the comb are those whose block size is a multiple of the period, and selecting such a block size presupposes knowledge of $r$ — the output of the computation. Corollary 5.8 removes even the accidental possibility in the architecture that actually gets built, where registers are split at powers of two.

Finally, in the complementary regime — halves shorter than the period — the spectrum is not merely high-rank but structurally untruncatable.

> **Theorem 5.9 (Flat spectrum, no tail).** Suppose $B \le r$, $C \le r$ and $\gcd(B,r) = 1$, and normalize the comb. Then both label maps are injective, every matching label carries exactly one $(b,c)$ pair, the Schmidt spectrum is flat with all coefficients equal, and the entanglement entropy is $\log \rho$ with $\rho = \operatorname{rank}$.

*Proof sketch.* $b \mapsto b \bmod r$ is injective for $b < B \le r$. For the right map, $x_0 - Bc \equiv x_0 - Bc'$ forces $r \mid B(c-c')$; coprimality gives $r \mid c - c'$, and $|c - c'| < C \le r$ forces $c = c'$. Injective label maps give all fibre cardinalities equal to $1$, so all Schmidt coefficients equal $\alpha$; Corollary 3.3 finishes. $\square$

The practical content of Theorem 5.9: truncated-MPS emulation is not "approximate" on a comb, it is *arbitrary*. Truncation algorithms discard the smallest singular values; here the singular values are all equal, so the choice of what to discard is a coin flip, and the discarded weight is proportional to the number of discarded directions. Section 7 quantifies the damage exactly.

---

## 6. The other endpoint: the Fourier transform of a comb

Let $\omega_Q = e^{2\pi i/Q}$. The (unnormalized) Fourier transform of the comb of period $r$ and offset $x_0$ in a register of size $Q = rm$ is

$$\widehat{c}(y) = \sum_{t=0}^{m-1} \omega_Q^{(x_0 + rt)y} .$$

> **Theorem 6.1 (Fourier transform of a comb).** For $r, m \ge 1$ and $Q = rm$:
> $$\widehat{c}(y) = \begin{cases} m\,\omega_Q^{x_0 y}, & m \mid y,\\[2pt] 0, & \text{otherwise,}\end{cases}\qquad \big|\widehat{c}(y)\big| = m\,[\,m \mid y\,].$$
> Consequently the normalized output distribution is
> $$P(y) = \frac{|\widehat c(y)|^2}{r m^2} = \begin{cases} 1/r, & m \mid y,\\ 0,&\text{otherwise,}\end{cases}$$
> which is a probability distribution: $\sum_{y<Q} P(y) = 1$.

*Proof sketch.* Factor $\omega_Q^{(x_0+rt)y} = \omega_Q^{x_0 y}\,(\omega_Q^{r})^{ty}$ and note $\omega_Q^{r} = \omega_m$ is a primitive $m$-th root of unity. The inner sum $\sum_{t<m} (\omega_m^{y})^t$ is the geometric sum of an $m$-th root of unity: it equals $m$ if $\omega_m^y = 1$, i.e. $m \mid y$, and $0$ otherwise. Normalization: there are exactly $r$ multiples of $m$ below $Q = rm$, each of probability $1/r$. $\square$

So the ideal output is uniform on an arithmetic progression of $r$ peaks with spacing $m = Q/r$. Its **support size is $r$**, exponentially large — a fact we exploit in Section 7.2. And crucially, presented across a register cut, this output is again a comb:

> **Definition 6.2 (Output state across a cut).** For $Q = BC$ and a frequency-phase parameter $j$, the Fourier output across the cut is
> $$\mathrm{Out}_{B,C,m,j}(b,c) = \alpha\,[\,m \mid (b + Bc)\,]\ \omega_Q^{\,j(b+Bc)} .$$

> **Theorem 6.3 (Output rank obeys the same law).** $\mathrm{Out}_{B,C,m,j}$ equals the period-$m$ comb with offset $0$ conjugated by diagonal phase matrices:
> $$\mathrm{Out}_{B,C,m,j} = \mathrm{diag}\big(\omega_Q^{jb}\big)_{b<B}\ \cdot\ \mathrm{Comb}_{B,C,m,0}\ \cdot\ \mathrm{diag}\big(\omega_Q^{jBc}\big)_{c<C}.$$
> Since diagonal matrices with unimodular entries are invertible, ranks agree, and for $m \le B$,
> $$\operatorname{rank}\mathrm{Out}_{B,C,m,j} = \min\Big(C,\ \frac{m}{\gcd(m,B)}\Big).$$
> In particular the rank is at least $2$ whenever $C \ge 2$ and $m \nmid B$; and no matrix-product representation of bond dimension $\chi < \min(C, m/\gcd(m,B))$ exists.

*Proof sketch.* The phase factorizes: $\omega_Q^{j(b+Bc)} = \omega_Q^{jb}\cdot\omega_Q^{jBc}$, and the support condition $m \mid b + Bc$ is precisely the comb of period $m$ and offset $0$. Multiplying on either side by an invertible matrix preserves rank; apply Theorem 5.5 with $r$ replaced by $m$. $\square$

Theorem 6.3 corrects a widely repeated intuition — that the Fourier output of Shor's algorithm is "nearly a single basis state" and therefore cheap. It is not: it is a comb of $r$ equal peaks, exponentially entangled across generic cuts. The single basis state appears only after measurement, and to measure the output one must first have it.

---

## 7. How badly does low-rank emulation fail?

### 7.1 Fidelity of truncation: the flat-spectrum Eckart–Young theorem

For a general state, the best rank-$D$ approximation retains the largest $D$ Schmidt weights, and the error is governed by the discarded tail (Eckart–Young). For a flat state the computation can be done in closed form, and it is worth stating in a form that assumes nothing about how the approximant was produced.

> **Theorem 7.1 (Flat-spectrum fidelity bound).** Let $M = L\,\mathrm{diag}(w)\,R^{*}$ be a state in Schmidt form on $\rho$ Schmidt directions, with $|w_j| \le \rho^{-1/2}$ for all $j$ (in particular, $M$ normalized and flat of rank $\rho$). Let $A = P\,\mathrm{diag}(s)\,Q^{*}$ be *any* state in Schmidt form on $D$ directions with $\sum_k s_k^2 \le 1$. Then
> $$|\langle M, A\rangle|\ \le\ \sqrt{\frac{D}{\rho}}, \qquad\text{hence}\qquad |\langle M, A\rangle|^2 \ \le\ \frac{D}{\rho},$$
> where $\langle M,A\rangle = \operatorname{tr}(M^{*}A)$ is the Hilbert–Schmidt (Frobenius) inner product.

*Proof sketch.* Expanding the inner product in the two Schmidt forms gives $\langle M,A\rangle = \sum_{j,k} w_j s_k\, \overline{\langle L_j, P_k\rangle}\,\langle R_j, Q_k\rangle$, so
$$|\langle M,A\rangle| \le \max_j|w_j| \sum_k s_k \sum_j |\langle L_j,P_k\rangle|\,|\langle R_j,Q_k\rangle| .$$
For fixed $k$, Cauchy–Schwarz plus the isometry relations $L^{*}L = I$, $R^{*}R = I$ bound the inner sum by $\big(\sum_j|\langle L_j,P_k\rangle|^2\big)^{1/2}\big(\sum_j|\langle R_j,Q_k\rangle|^2\big)^{1/2} \le 1$. Hence $|\langle M,A\rangle| \le \rho^{-1/2}\sum_k s_k \le \rho^{-1/2}\sqrt{D}$, the last step by Cauchy–Schwarz on the $D$ terms $s_k$ with $\sum_k s_k^2\le 1$. $\square$

> **Theorem 7.2 (The bound is attained).** Let $M$ be normalized and flat of rank $\rho$, and let $A$ be obtained by keeping any $D \ge 1$ of its Schmidt directions and renormalizing. Then $|\langle M, A\rangle|^2 = D/\rho$ exactly.

*Proof sketch.* Both sides are supported on the same $D$ orthonormal Schmidt pairs, with coefficients $\rho^{-1/2}$ and $D^{-1/2}$; the inner product is $D\cdot \rho^{-1/2} D^{-1/2} = \sqrt{D/\rho}$. $\square$

> **Corollary 7.3 (Frobenius form).** With $M$, $A$ normalized as in Theorem 7.1,
> $$\|M - A\|_F^2 \ \ge\ 2 - 2\sqrt{D/\rho} .$$

*Proof sketch.* $\|M-A\|_F^2 = \|M\|_F^2 + \|A\|_F^2 - 2\,\mathrm{Re}\langle M,A\rangle = 2 - 2\,\mathrm{Re}\langle M,A\rangle$, and $\mathrm{Re}\langle M,A\rangle \le |\langle M,A\rangle| \le \sqrt{D/\rho}$. $\square$

> **Corollary 7.4 (Truncated emulation of Shor's state).** Let $Q = rm$ and let $F$ have exact period $r$. Then every normalized state $A$ of Schmidt rank at most $D$ satisfies
> $$|\langle \Psi_F, A\rangle|^2 \le \frac{D}{r}.$$
> With $r$ exponential in the input size and $D$ polynomial, the fidelity of any tensor-train emulation is exponentially small.

Two remarks. First, Theorem 7.1 does not require the approximant to be a truncation of $M$: it bounds *every* low-rank state, however cleverly constructed, including the output of variational optimization. Second, it **corrects** a value quoted informally in the de-quantization literature: the fidelity of a rank-$D$ truncation of a flat rank-$r$ state is $D/r$, not $(D/r)^2$. The corrected value is larger, so truncation is less catastrophic than the folklore claim by a square root — and remains exponentially bad, which is what matters. A bound that is stated too strongly is a liability, since a single counterexample would discredit the surrounding argument; Theorems 7.1–7.2 give the exact constant with attainment, closing the question.

A general version, with no flatness assumed, follows from the same proof: if all Schmidt coefficients of $M$ have modulus at most $W$, then every rank-$D$ approximant has $|\langle M, A\rangle|^2 \le D\,W^2$.

### 7.2 Sampling: small support is fatal

A classical emulator need not reproduce the state; it suffices to reproduce the *samples*. The flat comb blocks this too.

> **Theorem 7.5 (Support bound in total variation).** Let $P$ be the ideal Fourier output on $\{0,\dots,rm-1\}$, i.e. $P(y) = 1/r$ for $m \mid y$ and $0$ otherwise. Let $\mathcal Q$ be any probability distribution supported on a set $S$. Then
> $$d_{\mathrm{TV}}(P, \mathcal Q) \ \ge\ 1 - \frac{|S|}{r}.$$
> In particular, if $2|S| \le r$ then $d_{\mathrm{TV}}(P,\mathcal Q) \ge 1/2$.

*Proof sketch.* Total variation dominates the excess of $P$ over $\mathcal Q$ on any event; take the event $\mathcal{P}\setminus S$ where $\mathcal P$ is the set of $r$ peaks. Then $\mathcal Q$ assigns it zero mass while $P$ assigns it $(r - |S \cap \mathcal P|)/r \ge 1 - |S|/r$. $\square$

The interpretation: an emulator that can only ever emit polynomially many distinct frequencies — which is what a polynomial-time algorithm with a compressed state description does when the compressed state has polynomial rank — is at total-variation distance $1 - o(1)$ from the target. It fails on almost every sample, not on a small fraction.

---

## 8. Complementarity of the two endpoints: refuted, then repaired

A natural hope for the emulator, and a natural conjecture for the analyst, is a *complementarity principle*: a cut aligned with the period $r$ (making the input cheap) is necessarily misaligned with the dual period $m$ (making the output expensive), so the product of the two endpoint ranks is always large. This would be an appealing uncertainty-type statement. It is false.

> **Theorem 8.1 (Refutation).** For $Q = 36$, $r = m = 6$ and the balanced cut $B = C = 6$, both endpoints are product states:
> $$\operatorname{rank}\mathrm{Comb}_{6,6,6,x_0} = 1 \quad\text{and}\quad \operatorname{rank}\mathrm{Out}_{6,6,6,j} = 1 .$$
> More generally, whenever $r \mid B$ and $m \mid B$, both endpoint ranks are $1$.

*Proof sketch.* Corollary 5.7 applied twice, with periods $r$ and $m$; for $B = C = r = m = 6$ both divisibilities hold trivially. $\square$

The correct statement replaces the product by an lcm law. It rests on the following exact characterization of the cut period.

> **Lemma 8.2 (Cut period as an order).** For $r \ge 1$ and all $B, k$: $\ r \mid Bk \iff \mathrm{per}(r,B) \mid k$.

*Proof sketch.* Write $g = \gcd(r,B)$, $r = g\,\mathrm{per}(r,B)$, $B = g B'$ with $\gcd(\mathrm{per}(r,B), B') = 1$. Then $r \mid Bk \iff \mathrm{per}(r,B) \mid B'k \iff \mathrm{per}(r,B)\mid k$ by coprimality. $\square$

> **Theorem 8.3 (lcm law for cut periods).** For $r, m \ge 1$ and every $B$,
> $$\mathrm{per}\big(\mathrm{lcm}(r,m),\,B\big) = \mathrm{lcm}\big(\mathrm{per}(r,B),\ \mathrm{per}(m,B)\big).$$

*Proof sketch.* By Lemma 8.2, $\mathrm{per}(\mathrm{lcm}(r,m),B)$ is the least $k$ with $\mathrm{lcm}(r,m) \mid Bk$, i.e. with $r\mid Bk$ *and* $m \mid Bk$, i.e. with $\mathrm{per}(r,B)\mid k$ and $\mathrm{per}(m,B)\mid k$ — that least $k$ is the lcm of the two cut periods. $\square$

> **Theorem 8.4 (Corrected complementarity).** Assume $\alpha \ne 0$, $C \ge 1$, $r \le B$ and $m \le B$. Then
> $$\min\Big(C,\ \mathrm{per}\big(\mathrm{lcm}(r,m), B\big)\Big)\ \le\ \operatorname{rank}\mathrm{Comb}_{B,C,r,x_0}\ \cdot\ \operatorname{rank}\mathrm{Out}_{B,C,m,j}.$$

*Proof sketch.* By Theorems 5.5 and 6.3 the two ranks are $\min(C, \mathrm{per}(r,B))$ and $\min(C,\mathrm{per}(m,B))$. By Theorem 8.3 the left-hand side is $\min(C, \mathrm{lcm}(\mathrm{per}(r,B),\mathrm{per}(m,B)))$, and $\mathrm{lcm}(x,y) \le xy$; the elementary inequality $\min(C, xy) \le \min(C,x)\min(C,y)$ for positive integers completes the proof. $\square$

> **Corollary 8.5 (Simultaneous collapse requires alignment).** If $C \ge 2$, $r \le B$, $m \le B$ and both endpoint ranks equal $1$, then $\mathrm{lcm}(r,m) \mid B$.

> **Corollary 8.6 (Qubit cuts of odd-order combs are never aligned).** If $r > 1$ is odd, then $r \nmid 2^k$ for every $k$; hence with $B = 2^k \ge r$ and $C \ge r$ the input rank is the full $\min(C,r) \ge 2$, and no simultaneous collapse occurs.

So the emulator's escape hatch exists — the analyst's conjecture was too strong — but it is exactly the aligned cut $\mathrm{lcm}(r,m)\mid B$, which requires knowing $r$ and, for the odd orders that arise constantly in practice, is unavailable at any power-of-two block size. The refutation strengthens the assessment rather than weakening it: we now know precisely which cuts could ever help, and we know they are not reachable.

---

## 9. The decisive equivalence

We finally connect the entanglement statements to the computational question.

### 9.1 Small bond dimension certifies a small order

> **Theorem 9.1.** Let $a$ have order $r$, $Q = rm$, and suppose the Shor register state admits a matrix-product representation of bond dimension $\chi$ across the register cut. Then there exists $k$ with $1 \le k \le \chi$ and $a^k = 1$.

*Proof sketch.* By Theorem 4.2 the Schmidt rank is $r$, and bond dimension bounds rank from below, so $r \le \chi$; take $k = r$. $\square$

> **Corollary 9.2.** If the order exceeds $\chi$, no bond-dimension-$\chi$ representation exists. Contrapositively, a polynomial-size tensor train exists only when the order is polynomially small — and a polynomially small order is discovered classically in polynomial time by computing $a, a^2, a^3, \dots$ until the value $1$ recurs.

This is the structural heart of the assessment. The low-rank regime is not merely rare; it coincides *exactly* with the regime in which the order is small, which is exactly the regime already handled by elementary classical methods (repeated squaring, and $p-1$–style attacks when the order's prime factors are small). There is no low-rank instance on which a tensor-network emulation would beat a classical order-finder, because on every low-rank instance the classical order-finder already runs in polynomial time.

### 9.2 One ideal sample suffices to factor

Conversely, the ideal quantum output is genuinely as powerful as advertised.

> **Theorem 9.3 (Peak samples determine the order).** Let $Q = rm$ and let $y = km$ be a peak of the ideal output. Then
> $$\frac{Q}{\gcd(y, Q)} = \frac{r}{\gcd(k, r)},$$
> which divides $r$, and equals $r$ exactly when $\gcd(k,r) = 1$. Moreover $\gcd(y,Q)$ is computed from $y$ and $Q$ alone, so the reduced denominator — obtained in practice from the continued-fraction expansion of $y/Q$ — is available to the sampler's user.

*Proof sketch.* $\gcd(km, rm) = m\gcd(k,r)$, so $Q/\gcd(y,Q) = rm/(m\gcd(k,r)) = r/\gcd(k,r)$. $\square$

Since the peaks are uniform, the index $k$ is uniform on $\{0,\dots,r-1\}$, so a constant fraction (of order $1/\log\log r$ by standard estimates on Euler's totient, and in practice much better) of samples are coprime and return $r$ exactly.

> **Theorem 9.4 (Order to factor).** Let $N > 1$ and let $x$ be an integer with $N \mid x^2 - 1$ but $N \nmid x-1$ and $N \nmid x+1$. Then $\gcd(x-1, N)$ is a nontrivial divisor $d$ of $N$ with $1 < d < N$. Consequently, if $a$ modulo $N$ has even order $r$ and $a^{r/2} \not\equiv -1$, then $N$ has a nontrivial factor, computable by one gcd.

*Proof sketch.* Set $d = \gcd(x-1, N)$. If $d = 1$ then $N \mid x+1$ from $N \mid (x-1)(x+1)$, contradiction; if $d = N$ then $N \mid x - 1$, contradiction. For the application take $x = a^{r/2}$: then $x^2 \equiv 1$; $x \not\equiv 1$ because $r$ is the least exponent with $a^r = 1$ and $r/2 < r$; and $x \not\equiv -1$ by hypothesis. $\square$

> **Corollary 9.5 (De-quantizing Shor equals classical factoring).** A classical algorithm that, given $(a, N)$ and $Q$, samples in polynomial time from the ideal Fourier output distribution yields a polynomial-time classical factoring algorithm: sample, extract the order by continued fractions (Theorem 9.3), and apply Theorem 9.4, repeating over random bases $a$.

Together with Corollary 9.2, this closes the loop. Suppose someone exhibits a polynomial-time tensor-network emulation of Shor's Fourier step for factoring-relevant instances. Two cases. If the emulation works by genuinely representing the states, its bond dimension bounds the Schmidt rank from below, so the order is polynomially small and the instance was classically easy to begin with. If instead the emulation only reproduces the output samples, then by Corollary 9.5 it *is* a polynomial-time classical factoring algorithm. Either way no new quantum-to-classical reduction has been achieved: one has either restricted to easy instances or solved factoring classically.

---

## 10. Algorithms

The results above are constructive and translate into small, exact algorithms; we record them for reference and use them in the numerical companion.

**Algorithm A — Exact Schmidt data of a fibre-matching state.**
Input: label maps $u$ on $\mathcal A$, $v$ on $\mathcal B$, amplitude $c$.
1. Tabulate fibre cardinalities $\phi_u, \phi_v$ by one pass over each index set: $O(|\mathcal A| + |\mathcal B|)$.
2. Compute $\mathrm{Match} = \operatorname{im}u \cap \operatorname{im}v$.
3. Output rank $=|\mathrm{Match}|$; Schmidt coefficients $w_s = c\sqrt{\phi_u(s)\phi_v(s)}$; entropy $-\sum p_s\log p_s$ with $p_s = w_s^2$.
Total cost $O(|\mathcal A| + |\mathcal B| + |\Sigma|)$ — no linear algebra, no singular value decomposition.

**Algorithm B — Bond dimension of a comb across a cut.**
Input: $r$, $B$, $C$ (with $r \le B$). Output: $\min(C, r/\gcd(r,B))$ by one Euclidean gcd, cost $O(\log r)$. This replaces an $O(BC\min(B,C))$ SVD by a constant-time formula.

**Algorithm C — Truncation diagnostics.**
Input: flat rank $\rho$, target bond dimension $D$. Output: fidelity $D/\rho$, squared Frobenius error $2 - 2\sqrt{D/\rho}$, and total-variation lower bound $1 - D/\rho$ for the induced sampler. Cost $O(1)$.

**Algorithm D — Sample to factor.**
Input: $N$, $a$, $Q = rm$, an output sample $y$.
1. Compute the continued-fraction convergents of $y/Q$ and take the largest denominator $\le N$; call it $\tilde r$.
2. Verify $a^{\tilde r} \equiv 1 \pmod N$; if not, resample (the sample had $\gcd(k,r) > 1$).
3. If $\tilde r$ is even and $x = a^{\tilde r/2} \not\equiv -1$, return $\gcd(x-1,N)$ and $\gcd(x+1,N)$; otherwise resample with a new base $a$.
Cost: $O(\log^3 N)$ per attempt, dominated by modular exponentiation.

---

## 11. Numerical corroboration

The companion program verifies every quantitative claim on explicit small instances, using exact rational Gaussian elimination for ranks and a Jacobi eigensolver for spectra.

* **Full state.** For $N = 15, a = 7$ ($r = 4$), $N = 21, a = 2$ ($r = 6$), $N = 35, a = 3$ ($r=12$): measured Schmidt ranks $4, 6, 12$; all singular values equal to $r^{-1/2}$ to machine precision; entropies $1.386294$, $1.791759$, $2.484907$ nats, matching $\log r$ exactly.
* **Comb rank law.** Over a battery of $(B,C,r,x_0)$ the measured rank agrees with $\min(C, r/\gcd(r,B))$ in every case, including the collapses at $r \mid B$ and the full ranks $5,7,15,21$ at power-of-two block sizes with odd orders.
* **Flatness.** For $B, C \le r$ with $\gcd(B,r)=1$ the ratio of largest to smallest Schmidt weight is $1.000000$ and the participation ratio equals the rank exactly — a spectrum with no tail.
* **Fourier output.** The transform of the comb is supported exactly on the multiples of $m$, each of probability $1/r$ to six decimals, and the measured rank of the phase-dressed output matrix agrees with $\min(C, m/\gcd(m,B))$ at every admissible cut.
* **Sampling.** With $r = 64$: samplers supported on $|S| = 1,2,4,\dots$ frequencies realize total-variation distance exactly $1 - |S|/r$, saturating Theorem 7.5.
* **Truncation.** For $\rho = 1024$ the truncation fidelity is $D/\rho$ to six decimals for $D = 1,\dots,1024$, and the Frobenius error matches $2 - 2\sqrt{D/\rho}$ — confirming $D/\rho$, not $(D/\rho)^2$.
* **Sample-to-factor.** For $N = 15, 21, 33, 35$ the peaks whose index is coprime to $r$ return the exact order by continued fractions ($\varphi(r)$ of the $r$ peaks in every case), and the gcd step returns the true factorizations $3\cdot 5$, $3\cdot 7$, $3\cdot 11$, $5\cdot 7$.
* **Complementarity.** The lcm bound holds with equality in all tested cuts, and the $Q=36$, $r=m=6$, $B=C=6$ instance exhibits rank $1$ at both endpoints, refuting naive complementarity.

---

## 12. Discussion

### 12.1 What has been ruled out, and what has not

The tensor-train Fourier theorem is not challenged here. It is a correct statement about states of small bond dimension. What has been established is that its hypothesis fails for Shor's states, exactly and at both endpoints of the transform, and that the failure is not a matter of constants: the required bond dimension is the order $r$ itself, and the spectrum is flat, so no approximate version of the hypothesis holds either.

Equally, nothing here shows that factoring is hard. It shows that *this* route to a classical factoring algorithm is a closed loop: it succeeds only where the problem was already easy, and any success elsewhere would be a factoring algorithm outright.

### 12.2 Why flatness is the crucial invariant

Rank alone would not settle the question. A state can have exponential rank and still be excellently approximated at small bond dimension if its Schmidt spectrum decays — that is the everyday situation in condensed-matter simulation, where area laws produce rapid decay and truncation is nearly free. The relevant property of Shor's states is that their spectra are *maximally* undecaying. Theorem 4.2 and Theorem 5.9 say this in the sharpest available form: the entanglement entropy equals the logarithm of the rank, the equality case of the fundamental bound.

Flatness is not an accident of the construction but a consequence of a group action. The comb is a coset of a subgroup of $\mathbb{Z}/Q\mathbb{Z}$, and the Shor state's fibres are cosets of $r\mathbb{Z}/Q\mathbb{Z}$. Cosets have equal cardinality, hence the fibre cardinalities that appear in the Schmidt coefficients of Theorem 3.2 are all equal, hence flatness. Any algorithm whose intermediate state is a uniform superposition over a coset of a hidden subgroup will inherit the same rigidity; the analysis here is not special to factoring.

### 12.3 The knowledge paradox

Corollaries 5.7 and 8.5 have a distinctly self-referential flavour: the cuts that compress the state are exactly those aligned with the hidden period, and locating such a cut is the computation. There is a clean way to say this. The comb possesses an $r$-state deterministic automaton recognizing its support (track $x \bmod r$), and the bond dimension across a cut equals the number of automaton states distinguishable from that position — which is $r$ up to the alignment discount $\gcd(r,B)$. Cheap simulation requires knowing the automaton's state space, i.e. knowing $r$.

An equivalent restatement uses the Fourier decomposition of the comb: writing the comb as $\frac 1r \sum_{j<r}\omega^{-jx_0}|\mathrm{wave}_j\rangle$ with each $|\mathrm{wave}_j\rangle$ a product state, one sees that the transform maps each wave to a single basis state, so the output is a sum of $r$ basis states. That decomposition is genuinely available — but it has $r$ terms, and writing them down costs $O(r)$. The only polynomial-time "Fourier transform of the comb" is one handed the pair $(r, x_0)$, i.e. handed the answer.

### 12.4 Relation to other de-quantizations

Successful de-quantizations typically exploit either sampling access to a low-rank data matrix or genuinely small entanglement in the algorithm's state. Shor's algorithm has neither. Its state is maximally entangled at the register cut relative to its rank, and its intermediate register state is a flat coset comb. The pattern that emerges from this assessment is a useful diagnostic for future claims: *ask for the Schmidt spectrum, not just the rank, and ask for it at the actual input of the transform, not at a convenient earlier or later stage.* The uniform superposition preceding modular exponentiation is a product state, rank $1$ — but it is not the Fourier input, and quoting it would be a category error.

---

## 13. Future directions

Several directions remain open, in increasing order of ambition.

**Incommensurate registers.** Our exact statements assume $Q = rm$. Real implementations take $Q$ a power of two, generally not a multiple of $r$; the output then has peaks broadened over $O(1)$ bins. The expected behaviour is that ranks only increase (the state is a perturbation of a comb with an additional aperiodic defect), but an exact lower bound in the incommensurate case — presumably $\Omega(\min(C, r/\gcd(r,B)))$ with an explicit constant — would complete the picture.

**Noisy and approximate combs.** What is the Schmidt spectrum of a comb corrupted by depolarizing noise, and at what noise level does an area-law-like decay appear? This is the quantitative version of the question "how much noise makes Shor classically simulable", and the flat-spectrum machinery of Section 7 is the right starting point since it bounds every low-rank approximant, not merely truncations.

**Other tensor-network topologies.** Bond dimension across a linear chain is only one measure of complexity. Tree tensor networks and PEPS-like layouts on the exponent register admit different cuts; the cut-period law suggests that a tree could align with $r$ only at nodes whose block sizes are multiples of $r$, so the same knowledge paradox should apply, but a complete statement over all balanced trees is open.

**Hidden subgroup generalization.** Section 12.2 argues that flatness comes from the coset structure. Formulating and proving an exact Schmidt-rank law for the standard hidden-subgroup state over a general finite abelian group — presumably $\mathrm{rank} = |H^{\perp}\cap(\text{cut lattice})|$ in appropriate coordinates — would generalize every result here in one stroke and would cover discrete logarithm and Simon's problem as corollaries.

**Sharper sampling lower bounds.** Theorem 7.5 is tight for supports but says nothing about samplers with full support and small entropy. A bound of the form "any distribution of Rényi entropy at most $H$ is at total-variation distance $\ge 1 - e^{H}/r$" would cover a wider class of would-be emulators.

**A resource-theoretic reading.** The quantity $\mathrm{per}(r,B) = r/\gcd(r,B)$ behaves like a resource monotone for cuts, with the lcm law of Theorem 8.3 as its composition rule. Making this precise — a monoid of cuts acting on states with the cut period as a homomorphism — may give a clean language for "how much of a hidden period a given decomposition can see".

---

## 14. Conclusion

The state at the input of Shor's quantum Fourier transform has Schmidt rank exactly $\min\!\big(C,\, r/\gcd(r,B)\big)$ across the cut $x = b + Bc$, the state at the output has rank exactly $\min\!\big(C,\, m/\gcd(m,B)\big)$ with $m = Q/r$, and the full two-register state has rank exactly $r$ with a perfectly flat spectrum, entropy $\log r$ and mutual information $2\log r$. Truncating to bond dimension $D$ leaves fidelity exactly $D/r$ and squared error at least $2 - 2\sqrt{D/r}$; a sampler supported on $S$ frequencies is at total-variation distance at least $1 - |S|/r$ from the ideal output. Compression across a cut is possible only when the cut is aligned with the period — that is, only for someone who already knows the answer — and never at a power-of-two cut of an odd order.

Finally, the two ends meet: a polynomially small bond dimension certifies a polynomially small order, hence a classically easy instance; and a polynomial-time classical sampler of the ideal output is a polynomial-time classical factoring algorithm. De-quantizing Shor by tensor networks is therefore not merely difficult; it is equivalent to factoring classically in polynomial time. The coherent superposition inside the Fourier transform is irreducible, and the quantum exception stands.
