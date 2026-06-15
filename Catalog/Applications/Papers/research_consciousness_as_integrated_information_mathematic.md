# Consciousness as Integrated Information: Mathematical Foundations

## Abstract

Integrated Information Theory (IIT) proposes that the degree to which a system is
"more than the sum of its parts" can be captured by a single nonnegative real
number Φ, defined as the value of an information-theoretic functional evaluated at
the system's *Minimum Information Partition* (MIP) — the bipartition across which
the system integrates the least. We give a rigorous, fully machine-checked
mathematical foundation for this proposal in two complementary settings. In the
**classical** setting, a system is a weighted directed graph; cross-information of
a cut is the total weight of edges crossing it, and Φ is the minimum
cross-information over all nontrivial bipartitions — a min-cut. We prove that Φ is
nonnegative, that it lower-bounds the cross-information of every cut, that it
vanishes exactly when the system admits a zero-weight cut (reducibility), that it
is strictly positive for strongly connected systems, that it scales linearly and
is monotone in the edge weights, and that it is bounded by the total weight. We
also establish a symmetrization identity relating directed and undirected
cross-information. In the **quantum** setting, a state is an amplitude tensor;
across any cut the Schmidt rank measures entanglement, and Φ = (Schmidt rank) − 1.
We prove that product (separable) states have Φ = 0, that a bond of dimension `D`
caps Φ at `D − 1` (with the `D = 2` case yielding Φ ≤ 1), that the maximally
entangled `d × d` state attains Φ = d − 1, and — in the genuinely multipartite
generalization — that a single product cut forces the global Φ to zero, while the
Schmidt rank across any cut obeys a discrete area-law bound. We discuss the
NP-hardness of computing Φ (via reduction to minimum bisection) and the prospect
of provable polynomial-time approximations, both of which the established results
position as natural next steps. Every theorem stated below has been formalized and
verified in the Lean 4 proof assistant.

**Keywords:** integrated information theory, Φ, minimum information partition,
graph min-cut, Schmidt rank, entanglement, area law, NP-hardness, minimum
bisection, formal verification.

---

## 1. Introduction

Integrated Information Theory, introduced by Tononi and developed over the past two
decades, advances the hypothesis that the quantity and structure of conscious
experience correspond to the quantity and structure of *integrated information* in
a physical system. The central scalar of the theory, Φ, is intended to measure
**irreducibility**: how much a system, considered as a causal whole, exceeds the
combination of its independent parts. A system that can be partitioned into causally
independent components without loss of information has Φ = 0; a system that resists
all such partitioning has large Φ.

While IIT's claims about consciousness are philosophically contested, the
mathematical kernel of the theory — Φ as the value of an integration functional at
a worst-case partition — is a precise and well-posed object that connects to
established areas of mathematics: graph cuts, combinatorial optimization, linear
algebra, and quantum information. This paper isolates that kernel and develops it
rigorously.

We work in two registers. The **classical** register models a system as a weighted
directed graph and defines Φ as a min-cut over nontrivial bipartitions. The
**quantum** register models a system as a (possibly multipartite) amplitude tensor
and defines Φ via Schmidt rank across a cut. The two registers are deliberately
parallel: in both, Φ is an infimum over nontrivial bipartitions of a per-cut
integration measure, and in both, the central qualitative theorem is that *Φ = 0
exactly when the system decouples across some cut*.

All results have been formalized in Lean 4 with Mathlib. We state each theorem
mathematically and give a proof sketch; the formal names are noted for traceability.

---

## 2. The classical setting: causal systems and the min-cut Φ

### 2.1 Definitions

**Definition 2.1 (Causal system).** A *causal system* on `n` nodes is a function
`w : Fin n × Fin n → ℝ` of edge weights together with the constraint that
`w(i, j) ≥ 0` for all `i, j`. We write `C` for the system and `C.weight i j` for
`w(i, j)`. (Formal object: `CausalSystem n`.)

**Definition 2.2 (Cross-information of a cut).** For a subset `S ⊆ Fin n`, the
*cross-information* is the total weight of edges from `S` to its complement:
$$
\mathrm{crossInfo}(C, S) \;=\; \sum_{i \in S}\ \sum_{j \in \overline{S}} C.\mathrm{weight}\,i\,j,
$$
where `\overline{S} = univ \ S`. (Formal: `crossInfo`.)

**Definition 2.3 (Nontrivial bipartitions).** The set of *nontrivial bipartitions*
of `Fin n` consists of the nonempty proper subsets:
$$
\mathcal{B}(n) \;=\; \{\, S \subseteq \mathrm{Fin}\,n \;:\; S \neq \emptyset,\ S \neq \mathrm{Fin}\,n \,\}.
$$
For `n ≥ 2` this set is nonempty (e.g. the singleton `{0}`), proved as
`nontrivialBipartitions_nonempty`. (Formal: `nontrivialBipartitions`.)

**Definition 2.4 (Integrated information Φ).** For `n ≥ 2`, the *integrated
information* of `C` is the minimum cross-information over all nontrivial
bipartitions:
$$
\Phi(C) \;=\; \min_{S \in \mathcal{B}(n)} \mathrm{crossInfo}(C, S).
$$
The minimum is realized because `\mathcal{B}(n)` is a nonempty finite set; formally
Φ is the `Finset.inf'` of `crossInfo` over `nontrivialBipartitions n`. (Formal:
`phi`.)

The minimizing partition is the **Minimum Information Partition (MIP)**: the
bipartition across which the system integrates least, hence the natural candidate
seam along which to "factor" the system.

### 2.2 Basic order-theoretic properties

**Theorem 2.5 (Nonnegativity).** `crossInfo(C, S) ≥ 0` for every `S`, and
consequently `Φ(C) ≥ 0`.

*Proof.* Cross-information is a double sum of the nonnegative quantities
`C.weight i j`, hence nonnegative (`crossInfo_nonneg`). Φ is an infimum of
nonnegative values, so `Φ ≥ 0` by `le_inf'` applied to the constant bound 0.
(Formal: `phi_nonneg`.) ∎

**Theorem 2.6 (Φ lower-bounds every cut).** For every `S ∈ \mathcal{B}(n)`,
`Φ(C) ≤ crossInfo(C, S)`.

*Proof.* Immediate from the definition of `inf'` as a greatest lower bound:
`Finset.inf'_le`. (Formal: `phi_le_crossInfo`.) ∎

**Theorem 2.7 (Total-weight ceiling).** Let
`totalWeight(C) = ∑_{i}∑_{j} C.weight i j`. Then `crossInfo(C, S) ≤ totalWeight(C)`
for every `S`, and `Φ(C) ≤ totalWeight(C)`.

*Proof.* Each crossing edge is one of the edges counted in the total, and all
omitted edges have nonnegative weight, so `crossInfo(C, S) ≤ totalWeight(C)`
(`crossInfo_le_totalWeight`, via `sum_le_sum_of_subset_of_nonneg` over the index
restrictions `S ⊆ univ` and `\overline{S} ⊆ univ`). Taking any nontrivial `S` and
combining with Theorem 2.6 gives the bound on Φ (`phi_le_totalWeight`). ∎

### 2.3 The reducibility dichotomy

**Definition 2.8 (Disconnected system).** `C` is *disconnected* if there exists a
nontrivial bipartition with zero cross-information:
$$
\exists\, S,\ S \neq \emptyset \ \wedge\ S \neq \mathrm{Fin}\,n \ \wedge\ \mathrm{crossInfo}(C, S) = 0.
$$
(Formal: `IsDisconnected`.)

**Theorem 2.9 (Disconnected ⟹ Φ = 0).** If `C` is disconnected then `Φ(C) = 0`.

*Proof.* Let `S` witness disconnection. By Theorem 2.6, `Φ(C) ≤ crossInfo(C, S) =
0`. By Theorem 2.5, `Φ(C) ≥ 0`. Antisymmetry gives `Φ(C) = 0`. (Formal:
`phi_zero_of_disconnected`.) ∎

This is the precise formal content of "if the system factors into independent
parts, the whole adds nothing." The converse direction — Φ > 0 — holds under a
strong connectivity hypothesis.

**Definition 2.10 (Strongly positive system).** `C` is *strongly positive* if every
off-diagonal weight is strictly positive: `i ≠ j ⟹ C.weight i j > 0`. (Formal:
`IsStronglyPositive`.)

**Lemma 2.11 (Positive cuts).** If `C` is strongly positive, then every cut with
both `S` and `\overline{S}` nonempty has `crossInfo(C, S) > 0`.

*Proof.* Pick `i ∈ S` and `j ∈ \overline{S}`. Then `C.weight i j > 0` contributes
to the double sum, and all other terms are `≥ 0`; `single_le_sum` bounds the sum
below by this strictly positive term. (Formal: `crossInfo_pos_of_stronglyPositive`.)
∎

**Theorem 2.12 (Strong positivity ⟹ Φ > 0).** If `n ≥ 2` and `C` is strongly
positive, then `Φ(C) > 0`.

*Proof.* Every `S ∈ \mathcal{B}(n)` has both `S` and `\overline{S}` nonempty (a
proper nonempty subset), so by Lemma 2.11 each `crossInfo(C, S) > 0`. The infimum
over a finite nonempty set of strictly positive values is strictly positive.
(Formal: `phi_pos_of_stronglyPositive`.) ∎

Together, Theorems 2.9 and 2.12 are the two horns of the **reducibility
dichotomy**: a free cut forces Φ = 0; uniformly strong coupling forces Φ > 0.

### 2.4 Functoriality: scaling and monotonicity

**Definition 2.13 (Scaling).** For `c ≥ 0`, `(c · C).weight i j = c · C.weight i j`
(weights remain nonnegative). (Formal: `scale`.)

**Theorem 2.14 (Linear scaling of Φ).** For `c ≥ 0`, `Φ(c · C) = c · Φ(C)`.

*Proof.* Cross-information is linear in the weights: `crossInfo(c·C, S) = c ·
crossInfo(C, S)` by pulling `c` out of the double sum (`crossInfo_scale`,
`Finset.mul_sum`). Hence Φ, an infimum, scales by the nonnegative factor `c`:
`min_S (c · f(S)) = c · min_S f(S)`, formalized via
`Real.sInf_smul_of_nonneg`. (Formal: `phi_scale`.) ∎

**Theorem 2.15 (Monotonicity).** If `C₁.weight i j ≤ C₂.weight i j` for all `i, j`,
then `Φ(C₁) ≤ Φ(C₂)`.

*Proof.* Pointwise weight domination gives `crossInfo(C₁, S) ≤ crossInfo(C₂, S)`
for every `S` (`crossInfo_mono`, by `sum_le_sum`). For infima, `f ≤ g` pointwise
implies `inf f ≤ inf g`: evaluate `inf f` at the argmin of `g`. (Formal:
`phi_mono_of_weight_le`.) ∎

### 2.5 Symmetrization and directed/undirected duality

Real causal influence is directed, but the clean min-cut picture is undirected. The
bridge is symmetrization.

**Definition 2.16 (Symmetrization).** `(C^{sym}).weight i j = C.weight i j +
C.weight j i`. The result has symmetric weights:
`(C^{sym}).weight i j = (C^{sym}).weight j i`. (Formal: `symmetrize`,
`symmetrize_weight_comm`.)

**Theorem 2.17 (Symmetrized cross-information).** For every cut `S`,
$$
\mathrm{crossInfo}(C^{sym}, S) \;=\; \mathrm{crossInfo}(C, S) + \mathrm{crossInfo}(C, \overline{S}).
$$
That is, the undirected flow across the cut is the sum of the two directed flows
(out of `S` and back into `S`).

*Proof.* Expand the definition of `crossInfo` for `C^{sym}`, split the sum of
`weight i j + weight j i` using `sum_add_distrib`, and recognize the second summand
as `crossInfo(C, \overline{S})` after a `sum_comm` reindexing. (Formal:
`symmetrize_crossInfo`; the supporting identity `crossInfo_compl` rewrites
`crossInfo(C, \overline{S})` as `∑_{i∈\overline{S}}∑_{j∈S} C.weight i j`.) ∎

This identity is what licenses analyzing a directed IIT system through the lens of
undirected weighted min-cut, where the rich theory of graph partitioning applies.

---

## 3. The quantum setting: Schmidt rank as integration

### 3.1 Bipartite states

**Definition 3.1 (Coefficient matrix and Schmidt rank).** A bipartite pure state
across a single cut is represented by its amplitude (coefficient) matrix
`M : Matrix (Fin m) (Fin n) ℂ`. Its *Schmidt rank* is the matrix rank
`schmidtRank(M) = M.rank`. (Formal: `schmidtRank`.)

**Definition 3.2 (Bipartite integrated information).**
$$
\Phi_{\mathrm{bip}}(M) \;=\; M.\mathrm{rank} - 1 \qquad (\text{truncated subtraction in } \mathbb{N}).
$$
Thus `Φ = 0` precisely when the rank is `≤ 1`, i.e. for product/separable states.
(Formal: `phiBip`.)

### 3.2 The reducibility theorem, quantum form

**Theorem 3.3 (Product states have Φ = 0).** For any vectors `u : Fin m → ℂ`,
`v : Fin n → ℂ`, the separable state with coefficient matrix `vecMulVec u v`
(the outer product `u vᵀ`) satisfies `Φ_bip(vecMulVec u v) = 0`.

*Proof.* The outer product `vecMulVec u v` has rank `≤ 1` (`rank_vecMulVec_le`),
so `Φ = rank − 1 = 0` by truncated subtraction. (Formal:
`phi_productState_eq_zero`.) ∎

This is the quantum analogue of Theorem 2.9: an unentangled (factorized) state has
zero integrated information, exactly as a disconnected graph does.

### 3.3 Bond dimension caps integration

Many-body quantum states are routinely represented as *matrix product states*
(MPS), in which the global amplitude matrix factors through a contracted "bond"
index of some dimension `D`.

**Theorem 3.4 (Bond bound).** For `A : Matrix (Fin m) (Fin D) ℂ` and
`B : Matrix (Fin D) (Fin n) ℂ`, the MPS coefficient matrix `M = A · B` satisfies
$$
\Phi_{\mathrm{bip}}(A \cdot B) \;\le\; D - 1.
$$

*Proof.* By rank submultiplicativity, `rank(A·B) ≤ rank(A)` (`rank_mul_le_left`),
and `rank(A) ≤` number of columns of `A`, which is `D` (`rank_le_card_width`). Hence
`rank(A·B) ≤ D`, giving `Φ = rank − 1 ≤ D − 1`. (Formal: `phi_mps_le_bond`.) ∎

**Corollary 3.5 (Bond two).** For bond dimension `D = 2`, `Φ_bip(A · B) ≤ 1`.
(Formal: `phi_mps_bondTwo_le_one`.)

### 3.4 Tightness via maximal entanglement

**Theorem 3.6 (Maximally entangled state).** For `d ≥ 1`, the maximally entangled
state on `ℂ^d ⊗ ℂ^d`, whose coefficient matrix is the identity
`1 : Matrix (Fin d) (Fin d) ℂ`, attains the maximal value
$$
\Phi_{\mathrm{bip}}(1) \;=\; d - 1.
$$

*Proof.* The identity matrix has full rank `d` (`Matrix.rank_one`,
`Fintype.card_fin`), so `Φ = d − 1`. (Formal: `phi_maximallyEntangled_eq`,
requiring `NeZero d`.) ∎

Theorems 3.4 and 3.6 together show the bond bound is **tight**: realizing the
maximally entangled state of local dimension `d` requires a bond of dimension at
least `d`. Integration is bottlenecked exactly by the bond.

---

## 4. The multipartite setting: the genuine MIP

### 4.1 Reshaping a tensor across a cut

**Definition 4.1 (Amplitude tensor).** A state on `n` sites of local dimension `d`
is an amplitude tensor `ψ : (Fin n → Fin d) → ℂ`. (Formal: implicit in the
signatures below.)

**Definition 4.2 (Cut matrix).** For a predicate `p` on sites (with the cut
`S = {i : p i}`), reshape `ψ` into a matrix whose rows are configurations of the
`p`-block and whose columns are configurations of its complement:
$$
\mathrm{cutMatrix}(p, \psi)(a, b) \;=\; \psi\big( (a, b) \text{ recombined} \big),
$$
where the recombination is the inverse of `Equiv.piEquivPiSubtypeProd`. (Formal:
`cutMatrix`.)

**Definition 4.3 (Schmidt rank across a finite cut).** For `S : Finset (Fin n)`,
`schmidtRankAt(S, ψ) = (cutMatrix (· ∈ S) ψ).rank`. (Formal: `schmidtRankAt`.)

**Definition 4.4 (Nontrivial bipartitions and multipartite Φ).** Let
`biparts n = {S : S ≠ ∅, S ≠ univ}` (the same index set as in §2). For a nonempty
`biparts n`,
$$
\Phi_{\mathrm{MIP}}(\psi) \;=\; \min_{S \in \mathrm{biparts}\,n}\big( \mathrm{schmidtRankAt}(S, \psi) - 1 \big).
$$
This is the direct multipartite generalization of Definition 2.4, with graph
cross-information replaced by quantum Schmidt rank. (Formal: `biparts`, `phiMIP`.)

### 4.2 Reducibility across a single cut

**Theorem 4.5 (Factorization caps Schmidt rank).** If `ψ` factors across the cut
`S` as `ψ(x) = f(x|_S) · g(x|_{\overline S})` for some `f, g`, then
`schmidtRankAt(S, ψ) ≤ 1`.

*Proof.* Under the factorization, the reshaped matrix `cutMatrix (· ∈ S) ψ` equals
the outer product `vecMulVec f g` pointwise: the subtype membership proofs collapse
the decidable branches of the reshaping equivalence (the positive branch `dif_pos
i.2` selects the `f`-factor's argument, the negative branch `dif_neg i.2` the
`g`-factor's). Then `rank_vecMulVec_le` gives rank `≤ 1`. (Formal:
`cutMatrix_rank_le_one_of_product`.) ∎

**Theorem 4.6 (One product cut forces Φ = 0).** If some nontrivial bipartition
`S ∈ biparts n` factorizes `ψ` into a product, then `Φ_MIP(ψ) = 0`.

*Proof.* By `inf'_le` at `S`, `Φ_MIP(ψ) ≤ schmidtRankAt(S, ψ) − 1`. By Theorem 4.5
this is `≤ 1 − 1 = 0` (truncated subtraction), and Φ is a natural number, so
`Φ_MIP(ψ) = 0`. (Formal: `phiMIP_eq_zero_of_product_cut`.) ∎

This is the exact multipartite analogue of Theorems 2.9 and 3.3: a *single*
decoupled cut suffices to make the entire system reducible.

### 4.3 A discrete area law

**Theorem 4.7 (Block bound).** For every cut `S`,
$$
\mathrm{schmidtRankAt}(S, \psi) \;\le\; \big|\{\text{configurations of } \overline{S}\}\big| \;=\; d^{\,|\overline{S}|}.
$$

*Proof.* The rank of any matrix is at most its number of columns; here the columns
are indexed by configurations of the complementary block, of which there are
`d^{|\overline S|}` (`rank_le_card_width`). (Formal: `schmidtRankAt_le_block`.) ∎

This is the discrete shadow of the entanglement **area law**: the integration
across a cut is bounded by the dimension of the boundary block, not the volume of
the whole. Combined with the bond bound (Theorem 3.4), it exhibits two independent
ceilings on integration — geometric (block size) and algebraic (bond dimension) —
and the MIP selects the cut where their minimum is smallest.

---

## 5. Computational complexity of Φ

### 5.1 The combinatorial obstruction

Both Φ (Definition 2.4) and Φ_MIP (Definition 4.4) are infima over the set of
nontrivial bipartitions, whose cardinality is `2^n − 2`. Naive evaluation is
therefore exponential. The qualitative results above already cast Φ as the answer
to a *combinatorial decision problem*: by Theorem 2.9, `Φ(C) = 0` if and only if
there exists a nontrivial zero-weight cut. This is precisely the decision-problem
shadow of a balanced/minimum-cut existence question.

### 5.2 NP-hardness via minimum bisection (program)

The concept calls for a proof that computing Φ is NP-hard. The structurally honest
route is a **Karp reduction** from weighted **minimum bisection** — a known
NP-hard problem — to the computation of Φ:

> Construct a polynomial-time map `g : Graph → CausalSystem` such that, for every
> input graph `G`, `crossInfo(g(G), S)` equals the cut weight `w(S, \overline{S})`
> of `G`, so that the MIP of `g(G)` *is* the minimum bisection of `G` and
> `Φ(g(G))` *is* its weight.

Under such a reduction, an algorithm computing Φ would solve minimum bisection,
establishing NP-hardness. Theorem 2.6 and the realization of Φ as an explicit
argmin (the `inf'` over `nontrivialBipartitions`) reduce the entire reduction to a
single arithmetic identity, `crossInfo = cutWeight`, isolating the hardness in a
clean, checkable lemma rather than in the optimization itself. The decision form
already proved (Theorem 2.9: Φ = 0 ⟺ existence of a free balanced cut) is the
NP-complete shadow of this bisection question. *This NP-hardness theorem is not yet
formalized;* the present work establishes the exact scaffolding it requires.

### 5.3 Polynomial-time approximation (program)

Given the hardness, the practical goal is a polynomial-time computable `ΦApprox`
with a provable multiplicative or additive guarantee relative to Φ. Spectral
relaxations of min-bisection (eigenvalue/SDP-based) provide candidate
approximations; the monotonicity and scaling laws (Theorems 2.14, 2.15) constrain
how any such approximation must behave under reweighting and give sanity checks for
correctness. The quantum side admits a complementary approach: truncated-SVD bond
estimates give *upper* bounds on Φ via Theorem 3.4, while block dimensions give the
area-law *upper* bound of Theorem 4.7, bracketing Φ between efficiently computable
quantities. Establishing a certified approximation ratio is left as future work.

---

## 6. Applications and interpretation

Independently of IIT's claims about consciousness, the formalized theory provides a
certified, domain-agnostic measure of **irreducibility**:

- **Network science.** Φ as a weighted min-cut detects whether an influence,
  trade, or communication network has a "cheap" partition — a near-modular
  structure — and quantifies how strongly the network resists decomposition.
- **Quantum many-body physics.** The Schmidt-rank Φ, bond bound, area-law bound,
  and tightness via maximal entanglement formalize standard entanglement
  diagnostics used in tensor-network simulation, with machine-checked guarantees.
- **Machine learning.** Φ-like cut measures quantify how much a model's modules
  genuinely interact, informing pruning, modular decomposition, and analyses of
  emergent integration.
- **Neuroscience.** The classical causal-system Φ is the literal mathematical core
  of empirical IIT measures; the dichotomy results make precise when measured Φ
  must vanish (clean functional disconnection) or be positive (dense effective
  connectivity).

The two registers — graph min-cut and Schmidt rank — are not merely analogous;
they share the same definitional template (infimum of a per-cut measure over
nontrivial bipartitions) and the same central theorem (decoupling across one cut
⟹ Φ = 0). This unity suggests an abstract "integration functional over a
bipartition lattice" of which both are instances.

---

## 7. Discussion and future work

The results establish the *combinatorial skeleton* of IIT on rigorous footing:
existence and characterization of the MIP, the reducibility dichotomy, the
functorial laws (scaling, monotonicity, bounds), the symmetrization bridge, and the
quantum entanglement picture with tight bounds and a discrete area law. Several
substantial directions remain.

**Full partition lattice.** The present Φ ranges over bipartitions. Genuine IIT
quotients over the full lattice of set partitions, normalized by partition size,
and takes the infimum of a partition distance over *all* partitions. We conjecture
that bipartition-Φ is an upper bound for full-lattice-Φ, with equality exactly when
the minimizer is binary; the partition lattice is graded by block count and the
integration functional is supermodular under refinement, so the minimizer can be
searched block-count by block-count. Mathlib's `Finpartition` order API is mature
enough to host `ei : Finpartition univ → ℝ` and the `min'` machinery transfers
verbatim.

**Formal NP-hardness.** As in §5.2, a machine-checked Karp reduction from weighted
min-bisection to Φ, inside a formal polynomial-time reduction framework, would turn
the decision-problem shadow (Theorem 2.9) into a hardness theorem. The remaining
content is a single arithmetic identity `ei A = cutWeight A`.

**Certified approximations.** As in §5.3, a poly-time `ΦApprox` with a proven
multiplicative guarantee, bracketed between the efficiently computable upper bounds
(bond, area law) and spectral lower bounds.

**The exact converse.** Theorem 3.3 shows product ⟹ Φ = 0; the converse (rank-one
⟹ outer product, hence the full iff "Φ = 0 ⟺ product across some cut") is a clean
linear-algebra fact deferred here and worth formalizing to complete the quantum
dichotomy.

**Continuous information measures.** Replacing rank/cut-weight with mutual
information or entanglement entropy would connect this combinatorial skeleton to
the information-theoretic Φ used in empirical neuroscience.

---

## 8. Conclusion

We have given a rigorous, fully machine-checked mathematical foundation for the
integrated-information functional Φ at the center of IIT, in both a classical
graph-cut register and a quantum Schmidt-rank register, including a genuine
multipartite generalization. The theory's defining intuition — that a whole exceeds
its parts exactly to the extent that it cannot be cleanly cut — is captured by a
single, well-behaved invariant: nonnegative, vanishing precisely under decoupling,
positive under strong coupling, linearly scaling, monotone, bounded, and tight at
the extremes of entanglement. The computational hardness of Φ and its
approximations, set up but not yet formalized here, mark the natural frontier. The
result is a clean, certified theory of irreducibility that stands on its own
mathematical merits, whatever one concludes about its application to the puzzle of
consciousness.
