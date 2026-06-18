# Future Directions: Fourier Analysis on Finite Groups

## Synthesis

The formal development of Fourier analysis via `FiniteCharacterBasis` establishes a certified bridge between representation theory, signal processing, quantum mechanics, and additive combinatorics. The three pillars — Parseval's identity, the convolution theorem, and the finite uncertainty principle — are now machine-verified in full generality for any finite abelian group. This creates a solid foundation for five interconnected research directions: (1) characterizing the extremizers of the uncertainty principle, which connects algebraic structure to information-theoretic limits; (2) extending the spectral framework to non-abelian groups, which requires moving from characters to matrix-valued representations; (3) formalizing the FFT and connecting algorithmic efficiency to algebraic structure; (4) building certified spectral methods for additive combinatorics, starting with Roth-type theorems; and (5) developing finite quantum mechanics as a certified testing ground for quantum information protocols. Each direction builds directly on the current formalization and opens new domain bridges.

---

## Direction 1: Extremizers of the Finite Uncertainty Principle

**Conjecture:** For any finite abelian group $G$ and character basis $B$, equality in the uncertainty principle $|\text{supp}(f)| \cdot |\text{supp}(\hat{f})| = |G|$ holds if and only if $f$ is, up to translation by a group element, modulation by a character, and scalar multiplication, the indicator function of a subgroup of $G$.

**Test:** Exhaustive computation on all finite abelian groups of order $\leq 36$. For each group:
1. Enumerate all subgroups and their indicators.
2. Verify that each subgroup indicator (and its translates/modulations) achieves equality.
3. Search for any function achieving equality that is NOT of this form, by sampling random support sets and optimizing coefficients.

A single counterexample (a non-subgroup-indicator extremizer) would falsify the conjecture. The test is computationally feasible for groups up to order ~30.

**Impact:** A proof would give a complete structural characterization of uncertainty extremizers, analogous to the Gaussian extremizers of the continuous Heisenberg inequality. It would connect the uncertainty principle directly to subgroup structure, with implications for coding theory (optimal codes correspond to subgroup indicators) and compressed sensing (extremizers define the hardest signals to recover).

**Catalog References:** `Algebra/FourierAnalysis/Theorems.lean` — `uncertainty_principle_finite_abelian`

**Proof Strategy:** The forward direction (subgroup indicators achieve equality) follows from the structure of Fourier transforms of subgroup indicators. The reverse direction (only these achieve equality) likely requires analyzing when equality holds in the Cauchy-Schwarz step of the Donoho–Stark argument: this forces $|f|$ to be constant on its support, and $|\hat{f}|$ to be constant on its support. Combined with the multiplicativity of characters, this should force $f$ to be a translated/modulated subgroup indicator.

**Domain Bridges:** Coding theory ↔ Algebraic combinatorics ↔ Quantum information

**Lineage:** Donoho–Stark (1989), Tao (2005) "An uncertainty principle for cyclic groups of prime order"

**Ambition:** ★★★★☆ — Deep but tractable for abelian groups; becomes a grand challenge for non-abelian groups.

---

## Direction 2: Non-Abelian Fourier Analysis via Matrix Representations

**Conjecture:** The `FiniteCharacterBasis` framework can be generalized to a `FiniteRepresentationBasis` for arbitrary finite groups, where characters are replaced by matrix-valued irreducible representations, and Parseval's identity becomes $\sum_\rho d_\rho \text{tr}(\hat{f}(\rho) \hat{h}(\rho)^*) = |G| \sum_g f(g) \overline{h(g)}$, where $d_\rho$ is the dimension of representation $\rho$.

**Test:**
1. Formalize the `FiniteRepresentationBasis` structure for the symmetric group $S_3$ and the dihedral group $D_4$.
2. Verify Parseval's identity numerically for these groups.
3. Attempt to prove a non-abelian uncertainty principle: $\sum_\rho d_\rho \cdot \text{rank}(\hat{f}(\rho)) \geq |G| / |\text{supp}(f)|$.

Failure would manifest as either: (a) the representation basis axioms being too restrictive for non-abelian groups, or (b) the non-abelian uncertainty principle being false.

**Impact:** Would extend the entire Fourier infrastructure to non-abelian groups, enabling formal analysis of the symmetric group (relevant to quantum computing and computational complexity) and crystallographic groups (relevant to physics).

**Catalog References:** `Algebra/FourierAnalysis/Defs.lean` — `FiniteCharacterBasis`

**Proof Strategy:** Replace scalar characters with matrix representations $\rho : G \to GL(V_\rho)$. The orthogonality relations become Schur orthogonality: $\sum_g \rho_{ij}(g) \overline{\sigma_{kl}(g)} = (|G|/d_\rho) \delta_{\rho\sigma} \delta_{ik} \delta_{jl}$. The Fourier transform becomes $\hat{f}(\rho) = \sum_g f(g) \rho(g)$, a matrix for each representation.

**Domain Bridges:** Representation theory ↔ Quantum computing ↔ Computational complexity (cf. Fourier analysis on $S_n$ in the graph isomorphism problem)

**Lineage:** Serre, *Linear Representations of Finite Groups*; Diaconis, *Group Representations in Probability and Statistics*

**Ambition:** ★★★★★ — Grand challenge: requires building matrix representation infrastructure from scratch.

---

## Direction 3: Certified FFT Correctness

**Conjecture:** The Cooley–Tukey FFT algorithm, when applied to $\mathbb{Z}/n\mathbb{Z}$ with $n = 2^k$, computes exactly the same function as the quadratic DFT defined by `fourierTransform`, and does so in $O(n \log n)$ operations.

**Test:**
1. Implement the radix-2 FFT in Lean 4 as a computable function.
2. Prove `fft n f = fourierTransform B f` where `B` is the standard character basis on `ZMod (2^k)`.
3. Verify the complexity bound by proving the recurrence $T(n) = 2T(n/2) + O(n)$ solves to $T(n) = O(n \log n)$.

The conjecture would be falsified if the FFT computes a different transform (e.g., with a different sign convention or normalization).

**Impact:** A formally verified FFT would be a landmark in certified algorithm design, with applications to verified signal processing, cryptographic implementations, and scientific computing.

**Catalog References:** `Algebra/FourierAnalysis/Defs.lean` — `fourierTransform`; `Algebra/FourierAnalysis/Theorems.lean` — `fourier_convolution`

**Proof Strategy:** Define the FFT recursively: split the input into even/odd indices, recursively transform each half, combine with twiddle factors. The correctness proof uses the factorization $\omega_n^{2k} = \omega_{n/2}^k$ and the periodicity of characters. The key lemma is that the DFT of a function on $\mathbb{Z}/2n\mathbb{Z}$ can be expressed in terms of two DFTs on $\mathbb{Z}/n\mathbb{Z}$.

**Domain Bridges:** Algorithm design ↔ Signal processing ↔ Verified computing

**Lineage:** Cooley & Tukey (1965); verified algorithms literature (e.g., CompCert)

**Ambition:** ★★★☆☆ — Solid extension, well-understood mathematically, main challenge is Lean infrastructure.

---

## Direction 4: Spectral Proof of Roth's Theorem in Formal Mathematics

**Conjecture:** Using the Fourier infrastructure on $\mathbb{Z}/n\mathbb{Z}$ (with $n$ prime), we can formally prove that any subset $A \subseteq \mathbb{Z}/n\mathbb{Z}$ with $|A| > n / (\log \log n)^C$ for some constant $C$ contains a nontrivial three-term arithmetic progression.

**Test:**
1. Formalize the counting lemma: the number of 3-APs in $A$ equals $\frac{1}{n} \sum_k \widehat{1_A}(k)^2 \overline{\widehat{1_A}(2k)}$.
2. Prove the density increment argument: if $A$ has no 3-APs, then $A$ has increased density on a long arithmetic progression.
3. Iterate to obtain the density bound.

Failure would mean: (a) the Fourier infrastructure is insufficient for the counting step, or (b) the density increment requires tools beyond what is currently formalized.

**Impact:** Would be the first formal proof of Roth's theorem, a cornerstone of additive combinatorics. Opens the door to formalizing the Green–Tao theorem and other deep results.

**Catalog References:** `Algebra/FourierAnalysis/Theorems.lean` — `parseval_finiteCharacterBasis`, `fourier_convolution`

**Proof Strategy:** Follow Roth's original argument via Fourier analysis:
1. Count 3-APs using the Fourier transform of $1_A$.
2. If $1_A$ has a large Fourier coefficient $\hat{1}_A(r)$ with $r \neq 0$, restrict to an arithmetic progression where $A$ has higher density.
3. If all non-trivial Fourier coefficients are small, the counting formula gives many 3-APs.
4. Iterate the density increment.

**Domain Bridges:** Additive combinatorics ↔ Analytic number theory ↔ Extremal combinatorics

**Lineage:** Roth (1953), Bourgain (1999), Sanders (2011)

**Ambition:** ★★★★★ — Grand challenge requiring substantial new infrastructure.

---

## Direction 5: Certified Finite Quantum Mechanics

**Conjecture:** The `FiniteCharacterBasis` framework, together with Parseval's identity, suffices to formalize a complete quantum mechanics on finite abelian groups, including: (a) unitary evolution via the Fourier transform, (b) the Born rule for position and momentum measurements, (c) quantum state tomography via character-basis measurements, and (d) the no-cloning theorem restricted to finite-dimensional systems.

**Test:**
1. Define quantum states as normalized functions $\psi : G \to \mathbb{C}$ with $\sum_g |\psi(g)|^2 = 1$.
2. Prove that the normalized Fourier transform $\tilde{\psi}(i) = \hat{\psi}(i) / \sqrt{|G|}$ is also normalized (unitarity).
3. Define position and momentum observables and prove the canonical commutation relation in its finite form.
4. Prove that the uncertainty principle for support sizes implies the entropic uncertainty principle $H(\text{position}) + H(\text{momentum}) \geq \log |G|$ where $H$ is the Shannon entropy.

Failure would mean: the entropic uncertainty principle requires tools beyond Parseval and the support-based uncertainty principle.

**Impact:** Creates a certified testing ground for quantum information protocols in finite dimensions. Every protocol tested on this finite model would have machine-verified guarantees.

**Catalog References:** `Algebra/FourierAnalysis/Theorems.lean` — `fourier_is_unitary_scaled`, `uncertainty_principle_finite_abelian`

**Proof Strategy:** The entropic uncertainty principle follows from the support-based one via the inequality $H(X) \leq \log |\text{supp}(X)|$, which holds for any discrete random variable. Combined with the uncertainty principle $|\text{supp}(\psi)| \cdot |\text{supp}(\tilde{\psi})| \geq |G|$, we get $H(\text{pos}) + H(\text{mom}) \geq H(\text{pos}) + \log(|G| / |\text{supp}(\psi)|) \geq \log |G|$.

**Domain Bridges:** Quantum information ↔ Information theory ↔ Representation theory ↔ Cryptography

**Lineage:** Maassen & Uffink (1988), Wehner & Winter (2010)

**Ambition:** ★★★★☆ — Deep and novel, requires building quantum information infrastructure.
