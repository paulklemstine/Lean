# The Galois/Frobenius Side Channel in Integer Factoring: An Abelianization Cap, an Exact Symmetry Wall, and a Frobenius One-Time Pad

**Aristotle**

*2026-10-16*

---

## Abstract

Let $N = pq$ be a product of two unknown primes, and let $K/\mathbb{Q}$ be a fixed finite Galois extension with group $G$. The Frobenius elements $\sigma_p, \sigma_q \in G$ determine how $p$ and $q$ split in $K$ and in its subfields. Part of the Frobenius of $N$ can be computed from $N$ alone: its image in the abelianization $G/G'$, which by class field theory is determined by a congruence class of $N$. This "Galois/Frobenius side channel" is a candidate attack primitive distinct from the classical families (congruences of squares, group orders, smoothness/index calculus, algebraic/complex-multiplication methods). We model Frobenius elements via the Chebotarev density theorem as uniform random group elements and work in the exact finite Shannon calculus. In this model we show that the channel is closed in three independent ways.

1. **The abelianization cap.** The residue class of a Frobenius element shares at most $\log_2[G:G']$ bits with any readout of it, and this remains true after arbitrary post-processing of either side. For $S_4$ quartic fields, with five splitting types, the cap is one bit. For perfect groups it is zero.
2. **The symmetry wall.** Whenever readout-preserving symmetries act transitively on the values of a hidden label, the label is exactly uniform and the readout carries *exactly* zero bits about it. Consequently, in every finite group, every swap-invariant readout of a semiprime carries exactly $0$ of the $1$ bit that says which factor carries which splitting type. For $m+1$ factors it carries exactly $0$ of $\log_2(m+1)$ bits. The residue of $N$ and every class function of $\sigma_p\sigma_q$ are swap-invariant, even in non-abelian groups.
3. **The Frobenius one-time pad.** In any finite group, abelian or not, suppose $\sigma_p$ is uniform on an arbitrary candidate set $A \subseteq G$ and $\sigma_q$ is uniform on $G$. Then every readout of $\sigma_p\sigma_q$ is independent of every readout of $\sigma_p$, so the posterior equals the prior. This strengthens the earlier "no pruning" observation, which concerned supports only, to a statement about distributions.

Combining these yields a *semiprime ledger*. The residue of $N$ is uniform on $G/G'$, carries exactly zero bits about the splitting type of either factor alone, carries the same information about the ordered and the unordered pair of types, and never exceeds $\log_2[G:G']$ bits. For $S_4$ it carries exactly $1$ bit about the unordered pair of types; for $D_4$ it carries $\tfrac{39}{16}-\tfrac34\log_2 3+\tfrac{5}{64}\log_2 5 \approx 1.430$ bits. All information in the channel is purely synergistic. We describe the algorithms that evaluate these channels exactly, and we isolate the conjunction of properties that any surviving method in this family must have.

---

## 1. Introduction

The security of RSA-type cryptosystems rests on the presumed hardness of recovering $p$ and $q$ from $N = pq$. Known sub-exponential and special-purpose factoring algorithms fall into four broad families:

- **congruences of squares**: Dixon's method, the quadratic sieve, the number field sieve;
- **group orders**: Pollard's $p-1$, Williams' $p+1$, Lenstra's elliptic curve method;
- **smoothness and index calculus**: relation collection plus linear algebra;
- **algebraic and complex-multiplication structure**: methods exploiting special endomorphism rings or class groups attached to $N$.

A natural fifth idea comes from algebraic number theory. Every prime $p$ unramified in a Galois extension $K/\mathbb{Q}$ has a Frobenius conjugacy class in $G = \mathrm{Gal}(K/\mathbb{Q})$. That class governs the splitting type of $p$ in every subfield of $K$, which is the factorisation pattern of a defining polynomial modulo $p$. If some of $\sigma_p$ could be read from $N$, then each field $K$ would deliver some bits about $p$. With enough fields, those bits might narrow $p$ down. We call this the **Galois/Frobenius side channel**.

The visible part of the channel is the abelian part. Write $G'$ for the derived subgroup and $G^{\mathrm{ab}} = G/G'$. The fixed field $K^{G'}$ is the maximal abelian subextension. By the Kronecker–Weber theorem it lies in a cyclotomic field $\mathbb{Q}(\zeta_f)$, and the image of $\sigma_p$ in $G^{\mathrm{ab}}$ is a function of $p \bmod f$. Because the Artin map is a homomorphism, the coset $\sigma_p\sigma_q G'$ is a function of $N \bmod f$. We call this coset the **residue** of $N$. It is computable from $N$ without knowing $p$ or $q$.

This paper proves that the side channel yields no usable information, in three independent senses. Section 2 sets up the model. Section 3 proves the **abelianization cap**, together with its extension to all post-processings. Section 4 proves the **independence law** and the **Frobenius one-time pad**. Section 5 proves the abstract **symmetry wall** and derives the **which-factor walls** for two and for many factors. Section 6 assembles the **semiprime ledger** and evaluates it on $S_4$ and $D_4$. Section 7 describes exact algorithms. Section 8 discusses what remains open.

---

## 2. Setting

### 2.1 Finite Shannon calculus

Throughout, a **sample space** is a finite non-empty set $\Omega$ with the uniform probability measure. A **readout** is any function $f : \Omega \to \alpha$ into a set with decidable equality. For $a \in \alpha$, the **fibre** is $\Omega_{f=a} = \{\omega \in \Omega : f(\omega) = a\}$, and
$$\Pr[f = a] = \frac{|\Omega_{f=a}|}{|\Omega|}.$$

**Definition 2.1 (entropy, mutual information).** The (Shannon) **entropy** of $f$ is
$$H(f) = -\sum_{a \in f(\Omega)} \Pr[f=a]\,\log_2 \Pr[f=a].$$
For two readouts $f, g$, the **joint readout** is $(f,g)(\omega) = (f(\omega), g(\omega))$, and the **mutual information** is
$$I(f;g) = H(f) + H(g) - H(f,g).$$
For a third readout $u$, the **conditional mutual information** is
$$I(f;g \mid u) = \sum_{v} \Pr[u=v]\; I_{\Omega_{u=v}}(f;g),$$
where $I_{\Omega_{u=v}}$ is computed on the fibre with its own uniform measure.

We use the following standard facts freely: $0 \le I(f;g) \le \min(H(f), H(g))$; $I(f;g) = I(g;f)$; $H(f) \le \log_2|f(\Omega)|$, with equality iff $f$ is uniform on its image; and the **chain rule** $I(k;(u,w)) = I(k;u) + I(k;w\mid u)$. Mutual information depends only on the partitions of $\Omega$ induced by the readouts, so relabelling the values of a readout injectively does not change it.

### 2.2 The arithmetic model

Let $K/\mathbb{Q}$ be finite Galois with group $G$. Realise $G$ as a permutation group on the $n$ roots of a defining polynomial $F$ of some subfield. For an unramified prime $p$, the factorisation of $F \bmod p$ into irreducibles has degrees equal to the cycle lengths of $\sigma_p$. We call this multiset the **splitting type** $T(\sigma_p)$. More generally, a **type readout** is any function $T : G \to \tau$. The conjugacy class of $\sigma_p$, the **Artin symbol**, is the readout $g \mapsto [g]$.

**Definition 2.2 (coset readout).** Let $N \le G$ be a subgroup. A readout $c : G \to \kappa$ is a **coset readout** for $N$ if for all $g,h \in G$,
$$c(g) = c(h) \iff g^{-1}h \in N.$$
When $N = G'$ we call $c$ the **residue readout**: $c(\sigma_p)$ is the residue class of $p$ in the sense above.

**Modelling assumption (Chebotarev).** By the Chebotarev density theorem, the Frobenius of a random prime is equidistributed in $G$, in the sense that conjugacy class $C$ has density $|C|/|G|$. We model the Frobenius of an unknown prime as a **uniform random element of $G$**, and the Frobenius elements of distinct unknown primes as independent. All theorems below are exact statements in this model. How closely primes of a given size follow the model is a separate, effective-Chebotarev question (Section 8).

For a semiprime, the sample space is $G \times G$, with ordered pairs $(\sigma_p, \sigma_q)$, or a subset of it. The residue of $N$ is the readout $(x,y) \mapsto c(xy)$.

---

## 3. Data processing and the abelianization cap

**Theorem 3.1 (Data processing).** For readouts $f : \Omega \to \alpha$, $g : \Omega \to \beta$ and arbitrary functions $\psi : \alpha \to \gamma$, $\varphi : \beta \to \delta$,
$$I(\psi\circ f;\ \varphi \circ g) \;\le\; I(f;g).$$

*Proof sketch.* It suffices to treat one side, since the other follows by symmetry of $I$. First, $I(g; \psi\circ f) \le I(g; (\psi\circ f, f))$, because adding a coordinate to a readout cannot decrease mutual information; by the chain rule the difference is a conditional mutual information, which is non-negative. Second, $(\psi\circ f, f)$ and $f$ induce the same partition of $\Omega$, since $(\psi(f(\omega)), f(\omega)) = (\psi(f(\omega')), f(\omega'))$ iff $f(\omega)=f(\omega')$. Mutual information depends only on partitions, so $I(g;(\psi\circ f,f)) = I(g;f)$. $\square$

**Lemma 3.2 (Uniform residue).** Let $N \le G$ be finite groups and $c$ a coset readout for $N$. Under the uniform measure on $G$, every fibre of $c$ has exactly $|N|$ elements, and
$$H(c) = \log_2 |c(G)| = \log_2[G:N].$$

*Proof sketch.* The fibre of $c$ through $g$ is the coset $gN$, which has $|N|$ elements (Lagrange). A readout with equal-size fibres is uniform on its image, and its image has $|G|/|N|$ elements. $\square$

**Theorem 3.3 (The abelianization cap).** Let $G$ be a finite group, $G'$ its derived subgroup and $c$ the residue readout. For every type readout $T$ and all post-processings $\psi, \varphi$,
$$I(\psi\circ c;\ \varphi\circ T) \;\le\; I(c;T) \;\le\; \log_2[G:G'] = \log_2|G^{\mathrm{ab}}|.$$

*Proof sketch.* The first inequality is Theorem 3.1. For the second, $I(c;T) \le H(c)$, and $H(c) = \log_2[G:G']$ by Lemma 3.2. $\square$

This covers every coarsening of the residue, for example reduction of $N$ to a smaller modulus or any arithmetic function of the residue class. It also covers every coarsening of the type, for example "is $p$ split completely?" or "does $F$ have a root mod $p$?". None of them can beat $\log_2[G:G']$.

**Corollary 3.4 (Perfect groups leak nothing).** If $G$ is perfect ($G' = G$), then $I(\psi\circ c;\ \varphi\circ T) = 0$ for all $T, \psi, \varphi$.

*Proof sketch.* The cap is $\log_2 1 = 0$, and mutual information is non-negative. $\square$

**Proposition 3.5 (When the cap is attained).** $I(c;T) = \log_2[G:G']$ if and only if the residue is a function of the type on $G$: there is $\phi$ with $c(g) = \phi(T(g))$ for all $g\in G$.

*Proof sketch.* $I(c;T) = H(c) - H(c\mid T)$, and $H(c) = \log_2[G:G']$ by Lemma 3.2. So equality holds iff $H(c\mid T) = 0$, that is, iff $c$ is constant on every fibre of $T$. $\square$

Since $g h g^{-1} h^{-1} \in G'$, every coset of $G'$ is a union of conjugacy classes. Hence the Artin symbol always attains the cap. Table 1 shows exact values for the transitive groups of degree $\le 4$, comparing the quartic or cubic cycle type with the Artin symbol.

**Table 1.** Exact prime-level channel values, in bits, under the uniform model.

| $G$ | $\lvert G\rvert$ | $[G:G']$ | cap $\log_2[G:G']$ | $I(c;\ \text{cycle type})$ | $I(c;\ \text{Artin class})$ |
|---|---|---|---|---|---|
| $S_3$ | 6 | 2 | $1$ | $1$ | $1$ |
| $S_4$ | 24 | 2 | $1$ | $1$ | $1$ |
| $A_4$ | 12 | 3 | $\log_2 3 \approx 1.585$ | $\approx 0.918$ | $\log_2 3$ |
| $D_4$ | 8 | 4 | $2$ | $\approx 1.656$ | $2$ |
| $V_4$ | 4 | 4 | $2$ | $\approx 0.811$ | $2$ |
| $C_4$ | 4 | 4 | $2$ | $1.5$ | $2$ |

The cap values are $S_3 = 1$, $S_4 = 1$, $A_4 = \log_2 3$, $D_4 = V_4 = C_4 = 2$. In particular, an $S_4$ quartic field has five splitting types, $1^4$, $1^2 2$, $2^2$, $13$ and $4$. Even so, it transmits at most **one bit** through its residue channel, namely the sign of $\sigma_p$, which is the Legendre-type symbol attached to the discriminant.

---

## 4. The independence law and the Frobenius one-time pad

### 4.1 The independence law

**Lemma 4.1 (Independence law).** Let $f, g$ be readouts on $\Omega$.

(a) *(Probability form.)* If $\Pr[f=a, g=b] = \Pr[f=a]\Pr[g=b]$ for all $a \in f(\Omega)$ and $b \in g(\Omega)$, then $I(f;g) = 0$.

(b) *(Counting form.)* If for all such $a,b$
$$|\Omega_{f=a,\,g=b}|\cdot|\Omega| \;=\; |\Omega_{f=a}|\cdot|\Omega_{g=b}|,$$
then $I(f;g)=0$.

*Proof sketch.* (a) The image of $(f,g)$ lies in $f(\Omega)\times g(\Omega)$. Expand $H(f,g)$ as a double sum over this product and use $\log_2(xy) = \log_2 x + \log_2 y$; the marginal probabilities sum to $1$, so $H(f,g) = H(f) + H(g)$. (b) Divide by $|\Omega|^2$ to obtain (a). $\square$

The counting form makes independence a statement about integers. This is how one verifies exact zeros (Section 7).

### 4.2 The shear

**Lemma 4.2 (Shear count).** Let $G$ be a finite group, $A \subseteq G$, and $P, Q$ predicates on $G$. Then
$$\bigl|\{(x,y) \in A\times G : P(x) \wedge Q(xy)\}\bigr| \;=\; |\{x\in A : P(x)\}|\cdot|\{z\in G: Q(z)\}|.$$

*Proof sketch.* The map $(x,z) \mapsto (x, x^{-1}z)$ sends $\{x\in A: P(x)\}\times\{z\in G : Q(z)\}$ bijectively onto the left-hand set. Its inverse is $(x,y)\mapsto(x,xy)$; that both maps land in the right sets uses that $G$ is closed under products and inverses, and that $A \subseteq G$. $\square$

### 4.3 The one-time pad

**Theorem 4.3 (The Frobenius one-time pad).** Let $G$ be a finite group, abelian or not, and let $A\subseteq G$ be any non-empty candidate set. On the sample space $A\times G$, so that $\sigma_p$ is uniform on $A$ and $\sigma_q$ is independently uniform on $G$, let $F$ and $H$ be *arbitrary* readouts of $G$. Then
$$I\bigl(F(\sigma_p);\ H(\sigma_p\sigma_q)\bigr) = 0.$$

*Proof sketch.* Apply Lemma 4.2 three times. With $P = \{F = a\}$ and $Q = \{H = b\}$ it gives the joint cell; with $Q \equiv \mathrm{true}$ it gives the $F$-marginal; with $P\equiv\mathrm{true}$ it gives the $H$-marginal:
$$|\{F=a, H=b\}| = \alpha_a\beta_b,\qquad |\{F = a\}| = \alpha_a|G|,\qquad |\{H=b\}| = |A|\beta_b,$$
where $\alpha_a = |\{x\in A: F(x)=a\}|$ and $\beta_b = |\{z\in G: H(z)=b\}|$. Since $|A\times G| = |A||G|$, the counting form of Lemma 4.1 holds:
$$\alpha_a\beta_b\cdot|A||G| = \alpha_a|G|\cdot|A|\beta_b.\qquad\square$$

The readout $H$ may be the residue of $N$, the Artin symbol of $\sigma_p\sigma_q$, its cycle type, or the element $\sigma_p\sigma_q$ itself. The readout $F$ may be the splitting type of $p$, its residue class, or $\sigma_p$ itself. All channels are exactly zero.

**Corollary 4.4 (Posterior equals prior).** In the setting of Theorem 4.3, for every value $b$ of $H(\sigma_p\sigma_q)$ that occurs and every $a$,
$$\Pr\bigl[F(\sigma_p) = a \;\big|\; H(\sigma_p\sigma_q)=b\bigr] = \Pr\bigl[F(\sigma_p)=a\bigr].$$

*Proof sketch.* The cell counts factor, so the joint probability factors. Dividing by $\Pr[H = b] > 0$ gives the claim. $\square$

**Corollary 4.5 (No pruning).** For any target $\sigma \in G$ and any candidate $x \in A$, there is $y \in G$ with $xy = \sigma$, namely $y = x^{-1}\sigma$. Hence the set of $\sigma_p$ consistent with an observed $\sigma_p\sigma_q$ is all of $A$. Consequently it meets every conjugacy class that $A$ meets, so the Artin channel prunes no candidates.

This support statement was the earlier form of the result, and it settled negatively the conjecture that a non-abelian Artin-symbol channel might give the first residue-type channel with non-trivial pruning. Corollary 4.4 is strictly stronger. Not only does every candidate survive, but the relative weights of the candidates are unchanged.

**Proposition 4.6 (The pad breaks when the cofactor is revealed).** Under the hypotheses of Theorem 4.3,
$$I\bigl(\sigma_p;\ (\sigma_p\sigma_q, \sigma_q)\bigr) = \log_2|A|.$$

*Proof sketch.* The pair $(\sigma_p\sigma_q,\sigma_q)$ determines $\sigma_p = (\sigma_p\sigma_q)\sigma_q^{-1}$. So the mutual information equals $H(\sigma_p)$, and $H(\sigma_p) = \log_2|A|$ because each fibre of the first coordinate has exactly $|G|$ elements. $\square$

So the zero of Theorem 4.3 is a genuine independence phenomenon and not an entropy deficit: the information about $\sigma_p$ is present, and $\sigma_q$ acts as its key.

---

## 5. The symmetry wall

### 5.1 The abstract wall

**Definition 5.1 (Label transitivity).** Let $w : \Omega\to\alpha$ (the hidden **label**) and $k:\Omega\to\beta$ (the **readout**) be readouts. We say $w$ is **$k$-label-transitive** if for any two values $a, b \in w(\Omega)$ there is a bijection $\pi : \Omega\to\Omega$ such that

1. $k(\pi\omega) = k(\omega)$ for all $\omega$, so $\pi$ preserves the readout, and
2. $w(\pi\omega) = b \iff w(\omega) = a$, so $\pi$ carries the label class $a$ onto the label class $b$.

**Theorem 5.2 (The symmetry wall).** If $w$ is $k$-label-transitive, then
$$I(w;k) = 0 \qquad\text{and}\qquad H(w) = \log_2|w(\Omega)|.$$

*Proof sketch.* Fix a readout value $c$ and labels $a,b$, and let $\pi$ be as in Definition 5.1. Then $\pi$ maps the cell $\{w=a, k=c\}$ bijectively onto $\{w=b,k=c\}$, so all cells in a $k$-fibre have the same size. Thus, within each $k$-fibre, the label is uniform on $w(\Omega)$:
$$\Pr[w=a, k=c]\cdot|w(\Omega)| = \Pr[k=c].$$
Summing over $c$ gives $\Pr[w=a]\cdot|w(\Omega)| = 1$, so $w$ is uniform, which is the entropy claim. Combining the two identities gives $\Pr[w=a,k=c]=\Pr[w=a]\Pr[k=c]$, and Lemma 4.1(a) gives $I(w;k)=0$. $\square$

The zero here is **exact**; it is a consequence of symmetry, not an estimate.

### 5.2 Swap invariance of Galois readouts of $N$

**Definition 5.3.** A readout $H : G\to\kappa$ is a **class function** if $H(ghg^{-1}) = H(h)$ for all $g,h\in G$.

**Proposition 5.4 (The residue is a class function).** Every residue readout $c$ (a coset readout for $G'$) is a class function.

*Proof sketch.* $(ghg^{-1})^{-1}h$ is a commutator $g h^{-1} g^{-1} h$, so it lies in $G'$. $\square$

**Proposition 5.5 (Class functions of the product are swap-invariant).** If $H$ is a class function, then $H(yx) = H(xy)$ for all $x,y\in G$.

*Proof sketch.* $yx = x^{-1}(xy)x$. $\square$

Thus the residue of $N$, the Artin symbol of $\sigma_p\sigma_q$ and the cycle type of $\sigma_p\sigma_q$ are all symmetric under $p\leftrightarrow q$, even when $G$ is non-abelian. Any readout that is a function of $N$ is symmetric in the same way.

### 5.3 The which-factor wall

Let $T : G\to\tau$ be a type readout into a totally ordered set, and let $A \subseteq G$. Define the **asymmetric pair space**
$$\Omega_{A,T} = \{(x,y)\in A\times A : T(x)\neq T(y)\}$$
and the **which-factor bit** $b(x,y) = [\,T(x) < T(y)\,]$: does the first factor carry the smaller type?

**Theorem 5.6 (The which-factor wall).** Let $G$ be any group and $A\subseteq G$ any finite set. Let $k$ be any readout of $\Omega_{A,T}$ with $k(y,x) = k(x,y)$. Then
$$I(b;k) = 0,\qquad\text{and}\qquad H(b) = 1 \text{ whenever } \Omega_{A,T}\neq\varnothing.$$

*Proof sketch.* The swap $(x,y)\mapsto(y,x)$ is an involution of $\Omega_{A,T}$. It preserves $k$, and it flips $b$ because the types are distinct. Hence $b$ is $k$-label-transitive and Theorem 5.2 applies. Both values of $b$ occur when the space is non-empty, so $H(b) = \log_2 2 = 1$. $\square$

**Corollary 5.7 (Residue and Artin readouts hide the bit).** For a finite group $G$, a residue readout $c$ and a class function $H$, the readouts
$$\bigl(c(xy),\ \min(T x, T y),\ \max(T x,T y)\bigr)\quad\text{and}\quad\bigl(H(xy),\ \min(Tx,Ty),\ \max(Tx,Ty)\bigr)$$
both carry exactly zero bits about $b$ on $\Omega_{G,T}$. So even an adversary who knows the residue of $N$ (or the Artin class of its Frobenius) *and* the unordered pair of splitting types learns nothing about which factor is which.

*Proof sketch.* By Propositions 5.4–5.5 these readouts are swap-invariant. Apply Theorem 5.6. $\square$

**Proposition 5.8 (Non-vacuity).** The ordered readout $(T x, T y)$ satisfies $I(b;(Tx,Ty)) = H(b)$.

*Proof sketch.* $b$ is a function of $(Tx,Ty)$. $\square$

### 5.4 The multi-prime wall

For $N = p_0p_1\cdots p_m$, let
$$\Omega^{(m)}_{A,T} = \{x\in A^{m+1} : i\mapsto T(x_i) \text{ is injective}\}$$
be the tuples of candidate Frobenius elements with pairwise distinct types. The label $\mu(x)$ is the index $i$ at which $T(x_i)$ is smallest.

**Theorem 5.9 (The multi-prime wall).** Let $k$ be a readout of $\Omega^{(m)}_{A,T}$ that is invariant under exchanging any two coordinates. Then
$$I(\mu;k) = 0,\qquad\text{and}\qquad H(\mu) = \log_2(m+1)\text{ whenever }\Omega^{(m)}_{A,T}\neq\varnothing.$$

*Proof sketch.* Permuting coordinates by a permutation $s$ moves the minimal-type index $i$ to $s^{-1}(i)$. The transposition $(i\,j)$ preserves $k$ and the space, and carries the label class $i$ onto the label class $j$. So $\mu$ is $k$-label-transitive; Theorem 5.2 gives $I = 0$, and all $m+1$ indices occur. $\square$

Examples of admissible $k$ are the image of $\sigma_{p_0}\cdots\sigma_{p_m}$ in an abelian quotient, the multiset of splitting types, and any symmetric function of the factors. As in Proposition 5.8, the ordered tuple of types recovers the full $\log_2(m+1)$ bits.

---

## 6. The semiprime ledger

Now take the full semiprime sample space $G\times G$, so that $(\sigma_p,\sigma_q)$ is uniform, and the residue of $N$, $\rho(x,y) = c(xy)$.

**Theorem 6.1 (The residue of $N$ is uniform).** $H(\rho) = \log_2[G:G']$.

*Proof sketch.* By Lemma 4.2 with $A = G$, the fibre $\{c(xy) = c(g)\}$ has $|G|\cdot|gG'| = |G|\,|G'|$ elements. All fibres are equal, and the image of $\rho$ equals the image of $c$, which has $[G:G']$ elements. $\square$

**Theorem 6.2 (The semiprime abelianization cap).** For every readout $R$ of the ordered pair $(\sigma_p,\sigma_q)$,
$$I(\rho;R) \le \log_2[G:G'].$$

*Proof sketch.* $I(\rho;R)\le H(\rho)$, and $H(\rho) = \log_2[G:G']$ by Theorem 6.1. $\square$

**Theorem 6.3 (Pure synergy: the residue is blind to each factor).** For every readout $F$ of a single Frobenius element,
$$I\bigl(\rho;\ F(\sigma_p)\bigr) = 0 \qquad\text{and}\qquad I\bigl(\rho;\ F(\sigma_q)\bigr)=0.$$

*Proof sketch.* The first is Theorem 4.3 with $A = G$ and $H = c$. For the second, apply the swap bijection of $G\times G$. It exchanges $F(\sigma_p)$ and $F(\sigma_q)$, and it preserves $\rho$ by Propositions 5.4–5.5, since $c(yx)=c(xy)$. Mutual information is invariant under bijections of the sample space, so the second channel equals the first. $\square$

**Theorem 6.4 (Ordered equals unordered).** Let $\Omega_0\subseteq G\times G$ be closed under the swap, let $k$ be a swap-invariant readout on $\Omega_0$, and let $T$ be any type readout into a totally ordered set. Then
$$I\bigl(k;\ (T\sigma_p, T\sigma_q)\bigr) \;=\; I\bigl(k;\ \{T\sigma_p, T\sigma_q\}\bigr),$$
where $\{T\sigma_p, T\sigma_q\}$ denotes the unordered pair $(\min,\max)$.

*Proof sketch.* The ordered pair induces the same partition as (unordered pair, which-factor bit). By the chain rule,
$$I(k;\text{ordered}) = I(k;\text{unordered}) + I(k;\, b\mid\text{unordered}).$$
Fix a fibre $\{T\sigma_p,T\sigma_q\} = \{s_1,s_2\}$. If $s_1 = s_2$, the bit is constant on the fibre and the conditional term vanishes. If $s_1 < s_2$, the fibre is swap-closed, every element has distinct types, and the swap preserves $k$ and flips $b$. Theorem 5.2 on the fibre then gives zero. $\square$

**Corollary 6.5 (The residue never learns which factor is which).** For every finite group $G$, every class function $H$ (the residue of $N$, the Artin symbol, the cycle type of $\sigma_p\sigma_q$, …) and every type readout $T$,
$$I\bigl(H(\sigma_p\sigma_q);\ (T\sigma_p,T\sigma_q)\bigr) = I\bigl(H(\sigma_p\sigma_q);\ \{T\sigma_p,T\sigma_q\}\bigr).$$

This proves, uniformly and without evaluating any entropy, the equality of ordered and unordered channels that was previously checked case by case for $S_3, S_4, A_4, D_4, V_4, C_4$.

### 6.1 Two worked fields

**Theorem 6.6 ($S_4$: pure synergy in a five-type field).** Let $G = S_4$ act on four roots, $T$ the cycle type and $c$ the sign coset. On $S_4\times S_4$:
$$I(\rho;T\sigma_p) = 0,\quad I(\rho;T\sigma_q)=0,\quad I\bigl(\rho;\{T\sigma_p,T\sigma_q\}\bigr) = 1,\quad I(\rho;R)\le 1 \ \text{ for every readout } R.$$

**Theorem 6.7 ($D_4$: pure synergy above the binary ceiling).** Let $G = D_4\le S_4$ (order $8$, $G'$ the centre of order $2$), $T$ the quartic cycle type and $c$ the coset readout of $G'$. On $D_4\times D_4$:
$$I(\rho;T\sigma_p) = I(\rho;T\sigma_q) = 0,\qquad I\bigl(\rho;\{T\sigma_p,T\sigma_q\}\bigr) = \frac{39}{16} - \frac34\log_2 3 + \frac{5}{64}\log_2 5 \approx 1.430 > 1,$$
and $I(\rho;R) \le 2$ for every readout $R$.

*Proof sketch of 6.6–6.7.* The zeros are Theorem 6.3. The caps are Theorem 6.2 with $[S_4:A_4] = 2$ and $[D_4 : Z(D_4)] = 4$. The middle values are exact finite computations. Each requires the joint distribution of the residue and the unordered type pair over $576$ pairs (for $S_4$) or $64$ pairs (for $D_4$). For $D_4$ the inequality $>1$ uses $\log_2 3 < 2$ and $\log_2 5 > 2$. $\square$

The ledger can be summarised as follows. Every bit that the residue of $N$ reveals about the shape of the factorisation is **synergistic**: it is invisible to any reader of one factor, it says nothing about which factor carries which type, and in total it is at most $\log_2[G:G']$.

---

## 7. Algorithms

All quantities in this paper are exact functions of finite multisets of integers, and they can be evaluated exactly.

### 7.1 Exact channel evaluation

*Input:* a finite sample space $\Omega$ (listed explicitly) and readouts $f,g$.
1. Tabulate the counters $n_f(a) = |\Omega_{f=a}|$, $n_g(b)$ and $n_{fg}(a,b)$ in one pass.
2. Compute $H(f) = \log_2|\Omega| - \frac{1}{|\Omega|}\sum_a n_f(a)\log_2 n_f(a)$, and similarly $H(g)$ and $H(f,g)$.
3. Return $I = H(f)+H(g)-H(f,g)$.
4. *(Exact zero certificate.)* Check the integer identities $n_{fg}(a,b)\,|\Omega| = n_f(a)\,n_g(b)$ for all $a,b$. If all hold, then $I = 0$ exactly (Lemma 4.1(b)).

The cost is $O(|\Omega|)$ hash operations plus $O(|f(\Omega)|\cdot|g(\Omega)|)$ for the certificate.

### 7.2 Abelianization cap

*Input:* generators of a permutation group $G$.
1. Enumerate $G$ by breadth-first closure under the generators.
2. Generate $G'$ from all commutators $aba^{-1}b^{-1}$, again by closure.
3. Represent the residue readout by $c(g) = \min_{n\in G'} gn$, the lexicographically least element of $gG'$.
4. Return $\log_2(|G|/|G'|)$. Optionally evaluate $I(c;T)$ via 7.1 and test attainment via Proposition 3.5: is $c$ constant on the fibres of $T$?

For the small groups of interest this is instantaneous. For permutation groups in general, Schreier–Sims methods compute $|G|$ and $|G'|$ in polynomial time without enumeration.

### 7.3 Symmetry-wall certificate

*Input:* $\Omega$, label $w$, readout $k$, and a finite set $\Pi$ of candidate bijections of $\Omega$ (for example coordinate transpositions).
1. Keep the $\pi\in\Pi$ that map $\Omega$ to itself and preserve $k$.
2. Build the graph on $w(\Omega)$ with an edge $a \to b$ whenever some kept $\pi$ maps the class $w^{-1}(a)$ onto $w^{-1}(b)$.
3. If this graph is complete (every ordered pair is joined), conclude $I(w;k)=0$ and $H(w) = \log_2|w(\Omega)|$ by Theorem 5.2.

This certifies exact zeros without computing a single logarithm. It is how the which-factor and multi-prime walls generalise from finite tables to all groups.

### 7.4 Representative numbers

The following were obtained by direct enumeration with the procedures above, in the uniform model.

- **Pad.** In $S_4$, for random candidate sets $A$ with $|A|\in[2,9]$, the channels between {type of $\sigma_p$, $\sigma_p$} and {type, Artin class, residue, element} of $\sigma_p\sigma_q$ are all exactly zero, with every cell-count identity holding. Revealing $\sigma_q$ yields exactly $\log_2|A|$ bits.
- **Which-factor.** For $S_3, S_4, A_4, D_4$: $H(b) = 1$; residue + unordered types gives $0$; Artin + unordered types gives $0$; ordered types gives $1$.
- **Multi-prime.** In $S_4$ with $3$ factors ($5256$ tuples with distinct types), the label has $\log_2 3$ bits and the residue together with the multiset of types gives $0$.

---

## 8. Discussion

### 8.1 A fifth primitive, closed

The Galois/Frobenius side channel is structurally distinct from the four classical families. It uses neither quadratic relations, nor group orders, nor smoothness, nor special endomorphisms; it reads the splitting behaviour of the hidden factors. The results above close it in three logically independent ways:

| closure | type of statement | mechanism |
|---|---|---|
| Abelianization cap | upper bound | Lagrange: the residue is uniform on $[G:G']$ cosets |
| Which-factor / multi-prime wall | exact zero | label-transitive symmetry ($pq = qp$) |
| Frobenius one-time pad | exact independence | shear bijection $(x,y)\mapsto(x,xy)$ |

The cap limits *how much* any residue can say. The wall shows that the residue cannot say *which* factor is which. The pad shows that the full Frobenius of $N$ says nothing about the Frobenius of $p$ alone.

### 8.2 The seams

The closures have precise boundaries.

1. **The cap bounds the residue content, not the full type.** A readout that does not factor through the abelianization coset is bounded only by $H(T)$. A large non-abelian group with large $\log_2[G:G']$ *and* a positive gap between the ordered and unordered channels is not excluded in principle. Note, however, that Theorem 6.4 forbids such a gap for every swap-invariant readout.
2. **The wall's hypothesis is symmetry.** Every wall statement assumes the readout is swap-invariant, which every function of $N$ is. A readout of an *asymmetric side input* is untouched, but no such side input computable from $N$ is known.
3. **Distributional assumptions.** The model takes Frobenius elements to be exactly uniform and independent. For primes of a fixed large size this is an effective Chebotarev statement. Explicit error terms are known under the Generalized Riemann Hypothesis but are conjectural in general. The theorems are exact *in the model*, and transfer to actual primes only up to such error terms.

Accordingly, any new method in this family must, as a **conjunction**, supply a readout of $p$ that

- (i) does not factor through $G^{\mathrm{ab}}$,
- (ii) breaks the $p\leftrightarrow q$ symmetry, and
- (iii) yields more than $O(1)$ bits about which factor is which,

all computed from $N$ alone. By the one-time pad, condition (i) is not enough by itself: even the full non-abelian Frobenius of $N$ is independent of that of $p$.

### 8.3 Relation to the classical picture

The pad has a simple arithmetic shadow. When $G = (\mathbb{Z}/f\mathbb{Z})^\times$, the residue of $N$ is $N \bmod f$. Knowing $N \bmod f$ tells you nothing about $p \bmod f$ when $q \bmod f$ is uniform on the units, because multiplication by a uniform unit is a one-time pad. Theorem 4.3 says this familiar fact survives verbatim in every finite group, for every readout and every candidate set.

---

## 9. Future directions

1. **Multi-prime one-time pad with an abelian product readout.** For $N = p_1\cdots p_k$ with Frobenius elements i.i.d. uniform on $G$, the coset of $\sigma_1\cdots\sigma_k$ in $G^{\mathrm{ab}}$ should share exactly zero bits with every readout of any $k-1$ of the factors, and at most $\log_2[G:G']$ bits with any readout of all $k$. The shear $(x_1,\dots,x_k)\mapsto(x_1,\dots,x_{k-1},x_1\cdots x_k)$ is a bijection, so the pad should iterate by induction using Lemma 4.2 and Lemma 4.1(b).
2. **Semiprime completeness criterion.** For $(\sigma_p,\sigma_q)$ uniform on $G\times G$, conjecturally $I\bigl(c(\sigma_p\sigma_q);\{T\sigma_p,T\sigma_q\}\bigr) = \log_2[G:G']$ if and only if $T$ determines the abelianization coset, that is, $c = \phi\circ T$ on $G$. One direction follows from Theorem 6.4: if $c = \phi\circ T$, the residue of $N$ is a function of the ordered pair of cosets, and Theorem 6.4 transfers this to the unordered pair. The converse needs a fibrewise analysis of equality in $I\le H$. The values in Section 6 are consistent with the conjecture: $S_3$ and $S_4$ attain the cap, where the cycle type determines the sign, while $D_4$ ($\approx 1.430 < 2$) and $A_4$ fall short, where it does not.
3. **Effective transfer.** Quantify, under GRH-type effective Chebotarev bounds, the deviation of the true channel on primes of size $X$ from the model values. The aim is to show that the exact zeros become $o(1)$ uniformly in the readout.
4. **Beyond the abelianization.** Characterise the readouts that are not class functions of $\sigma_p\sigma_q$ yet are computable from $N$. Determine whether any of them can break condition (ii).

---

## Appendix: notation

| symbol | meaning |
|---|---|
| $G$, $G'$, $G^{\mathrm{ab}}$ | Galois group, derived subgroup, abelianization $G/G'$ |
| $\sigma_p$ | Frobenius element of $p$ (uniform on $G$ in the model) |
| $T$ | type readout (e.g. splitting type = cycle type) |
| $c$ | residue (coset) readout for $G'$ |
| $\rho(x,y) = c(xy)$ | residue of $N = pq$ |
| $H(\cdot)$, $I(\cdot;\cdot)$ | Shannon entropy, mutual information (bits) |
| $b$ | which-factor bit $[T\sigma_p < T\sigma_q]$ |
| $\mu$ | minimal-type index among $m+1$ factors |
