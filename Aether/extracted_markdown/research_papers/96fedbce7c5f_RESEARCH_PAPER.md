# Multi-Cut Integrated Information of Tensor Network States

## Abstract

We give an exact, computable, and machine-verified formalization of the central
quantity of Tononi's Integrated Information Theory (IIT) — the integrated
information **Φ** — for quantum states represented as tensor networks. The
construction proceeds in two layers. At the level of a single bipartition, we
identify the cost of a cut with the **Schmidt rank** of the bipartite coefficient
matrix and define the single-cut integrated information `Φ_cut(M) = rank(M) − 1`,
which vanishes exactly for product (unentangled) states. At the level of an
*n*-party system, we package the Schmidt rank across every non-trivial
bipartition as *cut data* and define the **multi-cut integrated information**
`Φ = min over non-trivial cuts A of (rank(A) − 1)`, the quantum incarnation of
IIT's Minimum Information Partition (MIP). We prove the IIT structural laws as
theorems in this setting: Φ is the greatest lower bound of the per-cut landscape;
a realizing MIP always exists; Φ = 0 if and only if the state is a product across
some cut (reducibility); and Φ is monotone in the Schmidt-rank data. The central
result is a **bond-dimension theorem with tightness**: if the Schmidt rank across
every cut is bounded by a bond dimension *D* then Φ ≤ *D* − 1, and this bound is
attained — with equality — by the maximally entangled network whose Schmidt rank
is *D* across every cut. The explicit bond-dimension-2 case (Φ ≤ 1) follows as a
corollary, and the extremal value matches the single-cut integrated information of
the identity (maximally entangled) coefficient matrix. All results have been
formally verified.

**Keywords:** integrated information theory, tensor networks, Schmidt rank,
matrix product states, bond dimension, quantum entanglement, minimum information
partition.

---

## 1. Introduction

Integrated Information Theory (IIT), developed by Giulio Tononi and collaborators,
proposes that the degree to which a system is *unified* — irreducible to the sum of
its parts — is captured by a scalar quantity Φ. Among IIT's defining moves is the
**Minimum Information Partition** (MIP): Φ is the *minimum*, over all ways of
partitioning the system, of the information lost when the partition is enforced. A
system is integrated to the extent that *no* partition is cheap.

While IIT is usually framed for classical causal networks, the MIP construction is
agnostic to the substrate: it requires only (i) a notion of "system," (ii) a
family of "cuts," and (iii) a per-cut cost. Quantum information theory supplies a
canonical instance of all three. A multipartite pure state is a tensor of complex
amplitudes; a cut is a bipartition of the parties; and the natural per-cut cost is
the **Schmidt rank**, the rank of the coefficient matrix obtained by reshaping the
amplitude tensor across the cut. The Schmidt rank is the exact algebraic signature
of bipartite entanglement: it equals 1 precisely for product states and grows with
entanglement.

This paper formalizes IIT in that quantum, **tensor-network** setting and proves
its structural theorems. The development synthesizes two strands:

- a **single-cut** layer, in which the bipartite integrated information of a
  coefficient matrix *M* is `Φ_cut(M) = rank(M) − 1`; and
- a **multi-cut** layer, in which the integrated information of an *n*-party state
  is the minimum of `rank(A) − 1` over all non-trivial bipartitions *A*.

The single-cut layer fixes the calibration (product states have Φ = 0) and the
extremal anchor (the maximally entangled state). The multi-cut layer recovers the
MIP and the full IIT structure. The capstone is a tight bound relating Φ to the
**bond dimension** *D* — the controlling resource of tensor-network
representations such as matrix product states (MPS).

All statements below are theorems that have been verified by a formal proof
assistant; the proof sketches indicate the mathematical content, not the formal
scripts.

---

## 2. The single-cut layer: Schmidt-rank integrated information

### 2.0 Preliminaries and notation

We work with finite-dimensional complex Hilbert spaces. An *n*-party pure state
lives in a tensor product `H = H_1 ⊗ ··· ⊗ H_n`, with `H_i ≅ ℂ^{d_i}`; a choice of
product basis lets us write the state as an amplitude tensor
`T : (i_1, …, i_n) ↦ T_{i_1···i_n}` of complex numbers. A **bipartition** (cut) is a
partition of the party set `{1, …, n}` into a non-empty proper subset *A* and its
complement *A^c*. Reshaping *T* across the cut groups the *A*-indices into a single
row index and the *A^c*-indices into a single column index, producing the
**coefficient matrix** *M_A*.

The **Schmidt decomposition** writes the state across the cut as
`Σ_k s_k |a_k⟩_A |b_k⟩_{A^c}` with orthonormal `|a_k⟩, |b_k⟩` and Schmidt
coefficients `s_k > 0`. The number of non-zero `s_k` is the **Schmidt rank**, and a
standard fact of linear algebra is that it equals `rank(M_A)`. The Schmidt rank is
basis-independent and is the canonical discrete entanglement measure across the
cut: it is 1 exactly for product states and is invariant under local unitaries.

Throughout, `rank` denotes matrix rank, and natural-number subtraction `a − b` is
truncated (`= 0` when `b ≥ a`); this convention is what makes `Φ = rank − 1`
vanish cleanly on product states without special-casing.

### 2.1 Definitions

Let a bipartite pure state, reshaped across a fixed cut, be represented by its
**coefficient matrix** *M* ∈ ℂ^{m×n}: rows index the configurations of one side of
the cut, columns the configurations of the other.

**Definition 2.1 (Schmidt rank).** The Schmidt rank of the state is
`schmidtRank(M) := rank(M)`, the matrix rank of the coefficient matrix.

**Definition 2.2 (single-cut integrated information).**
`Φ_cut(M) := rank(M) − 1` (natural-number truncated subtraction).

The "−1" calibrates a product state to Φ_cut = 0. Because rank is a non-negative
integer, Φ_cut is a non-negative integer, and `Φ_cut(M) = 0` exactly when
`rank(M) ≤ 1`.

### 2.2 Results

**Theorem 2.3 (product states are reducible).** For any vectors *u* ∈ ℂ^m,
*v* ∈ ℂ^n, the outer-product coefficient matrix `uvᵀ = vecMulVec(u, v)` satisfies
`Φ_cut(uvᵀ) = 0`.

*Proof sketch.* An outer product has rank at most 1 (`rank_vecMulVec_le`), so
`rank − 1 = 0` by truncated subtraction. ∎

This is the algebraic statement that a separable bipartite state carries no
integrated information.

**Theorem 2.4 (bond bounds single-cut Φ).** For any *A* ∈ ℂ^{m×D},
*B* ∈ ℂ^{D×n}, the MPS-style product `M = A·B` satisfies `Φ_cut(A·B) ≤ D − 1`.

*Proof sketch.* Rank is submultiplicative and bounded by the inner dimension:
`rank(A·B) ≤ rank(A) ≤ #columns(A) = D` (via `rank_mul_le_left` and
`rank_le_card_width`). Subtract 1. ∎

**Corollary 2.5 (bond dimension 2).** For *A* ∈ ℂ^{m×2}, *B* ∈ ℂ^{2×n},
`Φ_cut(A·B) ≤ 1`.

**Theorem 2.6 (maximally entangled extremal).** For *d* ≥ 1, the identity
coefficient matrix `I_d` (the maximally entangled state on *d*⊗*d*, i.e.
`Σ_i |i⟩|i⟩`) satisfies `Φ_cut(I_d) = d − 1`.

*Proof sketch.* The identity has full rank `d` (`Matrix.rank_one`), so
`rank − 1 = d − 1`. ∎

Theorems 2.4 and 2.6 together show the bond bound is *tight*: bond dimension
*D = d* is exactly what is needed to realize the maximally entangled *d*⊗*d*
state.

---

## 3. The multi-cut layer: the Minimum Information Partition

### 3.1 Cuts

Fix an *n*-party system with parties indexed by `Fin n`.

**Definition 3.1 (cuts).** The set of non-trivial bipartitions is
`cuts(n) := { A ⊆ Fin n : A ≠ ∅ and A ≠ Fin n }`. Each *A* encodes the cut
separating *A* from its complement. (Note *A* and its complement encode the same
physical cut; including both is harmless, as the per-cut value is symmetric in the
constructions of interest and the minimum is unaffected.)

**Lemma 3.2 (cuts exist).** If *n* ≥ 2 then `cuts(n)` is non-empty; e.g. the
singleton `{0}` is a non-empty proper subset.

*Proof sketch.* `{0}` is non-empty, and if it equaled the universe then
`Fin n` would have cardinality 1, contradicting *n* ≥ 2. ∎

### 3.2 Cut data and Φ

**Definition 3.3 (cut data).** The *cut data* of an *n*-party tensor network state
is a structure `S` consisting of:
- a function `rank : (subsets of Fin n) → ℕ`, the Schmidt rank across each cut; and
- a positivity guarantee `rank_pos : ∀ A, 1 ≤ rank(A)` (a non-zero pure state has
  Schmidt rank at least 1 across every cut).

**Definition 3.4 (multi-cut integrated information).** For *n* ≥ 2,
`Φ(S) := min over A ∈ cuts(n) of (rank(A) − 1)`,
the minimum of a finite non-empty set (non-empty by Lemma 3.2). This is the
quantum/Schmidt-rank instance of IIT's MIP.

### 3.3 Structural theorems

**Theorem 3.5 (per-cut lower bound).** For every cut *A* ∈ cuts(n),
`Φ(S) ≤ rank(A) − 1`.

*Proof sketch.* Φ is the minimum of the image, so it is ≤ any image element
(`Finset.min'_le`). ∎

**Theorem 3.6 (the MIP exists).** There is a cut *A* ∈ cuts(n) with
`rank(A) − 1 = Φ(S)`.

*Proof sketch.* The minimum of a finite non-empty set is attained
(`Finset.min'_mem`); pull back the witness through the image (`Finset.mem_image`). ∎

The realizing cut *A* is the Minimum Information Partition: the weakest seam of the
system.

**Theorem 3.7 (greatest lower bound).** If *c* ∈ ℕ satisfies `c ≤ rank(A) − 1`
for every cut *A* ∈ cuts(n), then `c ≤ Φ(S)`.

*Proof sketch.* Any common lower bound of a finite set is below its minimum
(`Finset.le_min'`). ∎

Theorems 3.5 and 3.7 together characterize Φ as the *greatest lower bound* of the
per-cut integrated-information landscape — an exact infimum that is also attained.

**Theorem 3.8 (reducibility characterization).**
`Φ(S) = 0` if and only if there exists a cut *A* ∈ cuts(n) with `rank(A) = 1`.

*Proof sketch.* ( ⇒ ) By Theorem 3.6 the MIP cut *A* has `rank(A) − 1 = 0`; with
`rank(A) ≥ 1` this forces `rank(A) = 1`. ( ⇐ ) If some cut has `rank(A) = 1`, then
by Theorem 3.5 `Φ ≤ rank(A) − 1 = 0`, and Φ ≥ 0. ∎

This is the precise dividing line: a tensor network is reducible (Φ = 0) exactly
when it is a **product state across some bipartition**, mirroring IIT's axiom that
a reducible system has no integrated information.

**Theorem 3.9 (monotonicity).** If cut data *S* and *T* satisfy
`S.rank(A) ≤ T.rank(A)` for every cut *A*, then `Φ(S) ≤ Φ(T)`.

*Proof sketch.* Let *A* realize the MIP of *T* (Theorem 3.6). Then
`Φ(S) ≤ S.rank(A) − 1 ≤ T.rank(A) − 1 = Φ(T)` by Theorem 3.5 and the pointwise
hypothesis. ∎

Integration is monotone in entanglement: lowering Schmidt rank cannot raise Φ.

### 3.4 The bond-dimension theorem and tightness

**Theorem 3.10 (bond-dimension bound).** If there is a bond dimension *D* with
`rank(A) ≤ D` for every cut *A* ∈ cuts(n), then `Φ(S) ≤ D − 1`.

*Proof sketch.* Apply the hypothesis at the MIP cut *A* (Theorem 3.6):
`Φ(S) = rank(A) − 1 ≤ D − 1`. ∎

**Corollary 3.11 (bond dimension 2 — the test case).** If `rank(A) ≤ 2` for every
cut (e.g. a bond-dimension-2 MPS), then `Φ(S) ≤ 1`.

**Definition 3.12 (constant / maximally entangled cut data).** For *D* ≥ 1, let
`constCutData(D)` be the cut data with `rank(A) = D` for every cut. This is the
maximally entangled network at bond dimension *D*: Schmidt rank *D* across every
bipartition.

**Theorem 3.13 (constant value).** For the constant-rank-*D* network,
`Φ(constCutData(D)) = D − 1`.

*Proof sketch.* The image of `A ↦ rank(A) − 1` is the singleton `{D − 1}`, whose
minimum is `D − 1`. ∎

**Theorem 3.14 (tightness — headline).** The maximally entangled network attains
the bond bound: `Φ(constCutData(D)) = D − 1`, certifying that the bound of
Theorem 3.10 is sharp. Moreover this multi-cut value matches the single-cut
integrated information of the identity coefficient matrix,
`Φ_cut(I_D) = D − 1` (Theorem 2.6).

*Proof sketch.* The bound (Theorem 3.10) gives `Φ ≤ D − 1`; the constant
evaluation (Theorem 3.13) gives equality; and the single-cut identity matches via
Theorem 2.6, anchoring the multi-cut extremal value to the single-cut anchor. ∎

Theorems 3.10 and 3.14 jointly answer the question *"how much can a bond-D network
integrate?"*: the maximum is exactly *D* − 1, achieved by the maximally entangled
network and not exceeded by any.

---

## 4. Algorithms

The definitions are directly computable from a numerical amplitude tensor. Two
algorithms suffice.

### 4.1 Single-cut Schmidt rank

Given an amplitude tensor *T* over *n* parties and a cut *A*, reshape *T* into the
matrix *M_A* whose rows are indexed by the configurations of *A* and columns by the
complement, then compute `rank(M_A)` (numerically, the number of singular values
above a tolerance, or exactly via Gaussian elimination). The single-cut integrated
information is `rank(M_A) − 1`. Complexity: reshaping is O(size of tensor); the rank
of an *r*×*c* matrix is O(min(r,c)·r·c) by elimination.

### 4.2 Multi-cut Φ (MIP search)

Enumerate the non-trivial bipartitions *A* (it suffices to enumerate one
representative per cut, e.g. subsets containing party 0, halving the work),
compute `rank(M_A) − 1` for each, and return the minimum together with a realizing
cut (the MIP). With *n* parties there are 2^{n−1} − 1 representative cuts; for each,
the dominant cost is the rank computation. Complexity: O(2^n · poly(tensor size)) —
exponential in the number of parties, as expected for a partition-minimizing
quantity, but entirely tractable for the small systems of interest.

---

## 5. Worked examples

Let `d_i` denote local (per-party) dimensions; below all parties are qubits
(`d = 2`).

- **Product state** `|0⟩|0⟩`: coefficient matrix has a single non-zero entry,
  rank 1, so Φ_cut = 0. As an *n*-party product state, every cut has rank 1, so
  Φ = 0 (Theorem 3.8).
- **Bell state** `(|00⟩ + |11⟩)/√2`: coefficient matrix `I_2`, rank 2,
  Φ = 2 − 1 = 1 — the bond-dimension-2 maximum (Corollary 3.11, Theorem 2.6).
- **GHZ_3** `(|000⟩ + |111⟩)/√2`: Schmidt rank 2 across all three single-party
  cuts, so Φ = 1 — uniformly maximally integrated at bond dimension 2.
- **W_3** `(|001⟩ + |010⟩ + |100⟩)/√3`: also Schmidt rank 2 across every cut, so
  Φ = 1; its entanglement is distributed differently from GHZ (a distinction the
  rank-based Φ does not resolve, motivating Section 7).
- **Bell ⊗ idle qubit** `(|00⟩ + |11⟩) ⊗ |0⟩`: the cut isolating the idle qubit has
  Schmidt rank 1, so Φ = 0 (Theorem 3.8) — the MIP finds the fault line.
- **Maximally entangled at bond D**: Schmidt rank *D* across every cut gives
  Φ = *D* − 1 exactly (Theorem 3.14).

The accompanying `demo.py` reproduces each of these numerically.

---

## 6. Applications and discussion

**Computability and rigor.** By identifying the per-cut IIT cost with matrix rank,
Φ becomes a quantity that any linear-algebra routine computes immediately and that
a proof assistant can reason about exactly. The structural laws of IIT — existence
of the MIP, reducibility, monotonicity — become theorems rather than postulates.

**A three-way bridge.** The formalization aligns three vocabularies:
consciousness theory (MIP, reducible system, integration ceiling), quantum
information (worst-case Schmidt rank, product state, entanglement monotone), and
tensor-network representation theory (bond dimension as the controlling resource).
The MIP *is* the worst-case Schmidt rank; a reducible state *is* a product state;
the integration ceiling *is* the bond dimension.

**Bond dimension as an architectural ceiling.** Theorems 3.10 and 3.14 give a
clean, sharp statement: the representational capacity of a tensor network (its bond
dimension) is exactly the ceiling on its integrated information, and the ceiling is
achievable. This is a precise version of the tensor-network folklore that bond
dimension limits entanglement, recast as a two-sided (bound + tightness) result.

**Relation to classical IIT.** In the original (classical, causal-network)
formulation, the per-cut cost is an *effective information* computed from the
system's transition probabilities, and Φ is the minimum of that cost over
partitions. The present work keeps the outer structure of IIT verbatim — a minimum
over bipartitions, a realizing MIP, a reducibility threshold — but instantiates the
per-cut cost with the Schmidt rank of a quantum state. The two theories therefore
share a skeleton; what differs is the substrate-specific cost functional. This
modularity is deliberate: the structural theorems of Section 3 (existence of the
MIP, greatest-lower-bound, monotonicity) depend only on the cost being a
non-negative integer attached to each cut, not on its quantum origin, and so they
transfer to any cost functional one might substitute.

**Caveats.** The model uses Schmidt *rank* (a coarse, integer-valued entanglement
measure) rather than entanglement *entropy*; it treats pure states; and it takes
the cut data as given rather than deriving it from a single global amplitude
tensor. These are deliberate simplifications that make the exact theory tractable
and are precisely the points addressed by the future directions below. The work
makes no claim about whether Φ measures consciousness; it formalizes the
mathematical core of IIT in the quantum setting.

---

## 7. Future directions

**1. Schmidt rank from genuine coefficient matrices, not abstract cut data.** The
present `CutData` records the Schmidt rank across each cut as an abstract function.
The next step is to *derive* `rank(A)` from a single underlying amplitude tensor by
reshaping it across the cut *A* into a coefficient matrix *M_A*, with
`rank(A) := rank(M_A)`, reusing the single-cut `Φ_cut(M_A)` as the per-cut value.
The key insight is that the consistency constraint "all *M_A* arise from one global
tensor" is exactly what makes IIT's MIP non-trivial — the cuts are not independent,
so the minimum is constrained by the shared tensor. This is feasible now because
the ambient library already provides matrix rank, outer products, and rank
submultiplicativity, and the single-cut anchors are proved; the reshaping layer is
pure bookkeeping over `Fin` products.

**2. Strict monotonicity and the entanglement order.** Monotonicity (Theorem 3.9)
shows Φ is monotone in the Schmidt-rank data. Conjecture: if `S.rank ≤ T.rank`
pointwise and the inequality is strict *at the MIP cut of T*, then Φ(S) < Φ(T). The
key insight is that only the minimizing cut controls Φ, so strictness must be
located there rather than globally — a falsifiable refinement, since a
counterexample is any *S* that lowers a non-MIP cut while leaving the MIP cut fixed.
This is within reach because the MIP realizer (Theorem 3.6) gives direct access to
the controlling cut.

**3. Subadditivity of Φ under tensoring of networks.** Given two networks
*S₁, S₂*, their independent composite has, across each cut, Schmidt rank equal to
the product of the per-component ranks. Conjecture:
`Φ(S₁ ⊗ S₂) + 1 ≤ (Φ(S₁) + 1)(Φ(S₂) + 1)`, i.e. integrated information is
submultiplicative in rank and the "+1" shift linearizes it. The key insight is that
composing systems multiplies Schmidt ranks per cut, but the MIP of the composite
may pick a *different* cut than either factor's MIP, forcing an inequality rather
than equality. This is feasible now because Φ is defined over the cut lattice
`subsets of Fin n`, and the product network's cut lattice is the product of the
factor lattices.

Further natural continuations include replacing Schmidt rank with entanglement
entropy (a continuous Φ), extending from pure states to mixed states via the
convex-roof construction, and distinguishing entanglement *structure* (e.g. GHZ vs
W, which share the same rank-based Φ) through higher-order or category-theoretic
invariants of the tensor network.

---

## 8. Conclusion

We have formalized the mathematical core of Integrated Information Theory for
quantum tensor-network states, defining a multi-cut integrated information Φ as the
minimum Schmidt-rank deficit over all non-trivial bipartitions and proving the IIT
structural laws — greatest-lower-bound characterization, existence of the Minimum
Information Partition, reducibility (Φ = 0 iff product across some cut), and
monotonicity — as theorems. The headline result is a sharp bond-dimension theorem:
integrated information is bounded by *D* − 1 for bond dimension *D*, and this bound
is exactly attained by the maximally entangled network, matching the single-cut
identity-matrix anchor. The construction renders Φ computable and rigorous and
binds together consciousness theory, quantum information, and tensor-network
representation theory in a single, verified framework.
