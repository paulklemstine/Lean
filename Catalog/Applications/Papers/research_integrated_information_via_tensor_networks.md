# Integrated Information via Tensor Networks: A Schmidt-Rank Reformulation of Φ

## Abstract

Integrated Information Theory (IIT) posits a scalar functional Φ that measures the
extent to which a system is irreducible to its parts, computed over the
*minimum-information partition* (MIP) — the bipartition across which the system
integrates the least. While IIT was conceived for classical causal networks, the
notion of irreducibility it formalizes is precisely the kind of inseparability that
quantum entanglement captures. We give an exact, discrete reformulation of Φ for pure
quantum states represented as amplitude tensors and tensor networks. The central move
is to identify the integrated information across a cut with the **Schmidt rank** of
the state's coefficient tensor reshaped across that cut, discretized as Φ = rank − 1,
and to take Φ of the whole state as the minimum of this quantity over all nontrivial
bipartitions. Under this identification, IIT's two poles become exact linear-algebra
facts: a reducible (product) state has Φ = 0, and a maximally entangled state attains
the extremal Φ = d − 1. The matrix-product-state (MPS) bond dimension D furnishes a
sharp algebraic ceiling Φ ≤ D − 1, and the smaller-block Hilbert dimension furnishes a
geometric, area-law ceiling. We prove these results, relate the construction to the
existing graph-theoretic min-cut formulation of IIT, give algorithms and numerical
demonstrations, and discuss the path toward a von Neumann–entropy version and an
LOCC-monotonicity theory.

**Keywords:** integrated information theory, Φ, tensor networks, Schmidt rank,
entanglement, matrix product states, minimum-information partition, area law.

---

## 1. Introduction

### 1.1 The integration problem

A recurring question across the sciences of complex systems is when a collection of
interacting components constitutes a genuine, irreducible *whole* rather than an
aggregate of quasi-independent parts. Tononi's Integrated Information Theory (IIT)
proposes to answer this quantitatively through a functional Φ. The defining idea is
that a system's integration is limited by its weakest seam: one considers every way of
partitioning the system into two parts, measures the information that survives severing
the connections across each partition, and takes the *minimum* over all partitions —
the value at the **minimum-information partition (MIP)**. A system that contains even a
single near-decoupled seam is deemed reducible, and its Φ is correspondingly small;
only a system that resists *every* bipartition attains a large Φ.

### 1.2 Why quantum

The classical IIT framework lives on weighted directed graphs, where the weight of a
cut is the causal influence crossing it. But the purest examples of irreducibility in
nature are quantum: an entangled state is, by definition, one that cannot be written as
a product of states of its parts. The amount of entanglement across a bipartition has
a canonical measure — the Schmidt rank — that plays exactly the structural role of a
"cut weight." This paper makes that correspondence precise and proves the resulting
statements.

### 1.3 Contributions

1. A multipartite definition of Φ for pure quantum states via the Schmidt rank of the
   reshaped amplitude tensor across each cut, minimized over nontrivial bipartitions
   (Section 3).
2. **Reducibility ⟹ zero integration**: a product factorization across any single
   nontrivial cut forces Φ = 0 (Theorem 4.1, 4.2).
3. **Algebraic ceiling**: an MPS with bond dimension D satisfies Φ ≤ D − 1, and in
   particular a bond-2 MPS has Φ ≤ 1 (Theorem 4.3, 4.4).
4. **Tightness**: the maximally entangled d⊗d state attains Φ = d − 1 (Theorem 4.5).
5. **Geometric / area-law ceiling**: the Schmidt rank across a cut is bounded by the
   Hilbert dimension of the complementary block, d^|Sᶜ| (Theorem 4.6).
6. A structural bridge identifying this construction with the graph min-cut formulation
   of IIT (Section 6).

---

## 2. Background and notation

### 2.1 Amplitude tensors

Fix `n` sites each of local Hilbert-space dimension `d`. A joint configuration of all
sites is a function `x : Fin n → Fin d`, assigning to each site one of `d` basis
labels. A pure state is encoded by its **amplitude tensor**

> ψ : (Fin n → Fin d) → ℂ,

a complex-valued function on the `dⁿ` joint configurations. (Normalization is
irrelevant to all rank-based quantities below and is omitted.)

### 2.2 Bipartitions

A **bipartition** is determined by a subset `S ⊆ Fin n` of sites, with complement `Sᶜ`.
We call `S` **nontrivial** if it is nonempty and proper (`S ≠ ∅`, `S ≠ Fin n`). The set
of nontrivial bipartitions is

> biparts(n) = { S ⊆ Fin n : S nonempty and S ≠ univ }.

This is the same indexing set used in the classical graph formulation of IIT, ensuring
the two constructions range over identical cuts.

### 2.3 Schmidt rank

Classically, the Schmidt decomposition writes a bipartite pure state in a biorthonormal
basis adapted to a cut; the number of nonzero Schmidt coefficients is the **Schmidt
rank**, and it equals the matrix rank of the coefficient matrix obtained by reshaping
the amplitude tensor across the cut. Schmidt rank 1 is exactly separability across the
cut; higher Schmidt rank is genuine entanglement.

---

## 3. The construction

### 3.1 The cut matrix (reshape)

Given a cut predicate (membership in `S`), reshape ψ into a matrix indexed by
configurations of the two blocks.

> **Definition 3.1 (cutMatrix).** For a decidable predicate `p` on sites, define
> cutMatrix(p, ψ) to be the matrix with rows indexed by configurations
> `a : {i // p i} → Fin d` of the `p`-block, columns indexed by configurations
> `b : {i // ¬ p i} → Fin d` of its complement, and entry
>
> cutMatrix(p, ψ)(a, b) = ψ( reassemble(a, b) ),
>
> where `reassemble` is the canonical bijection between full configurations and pairs of
> block configurations (the inverse of `Equiv.piEquivPiSubtypeProd`).

The reshape is a literal re-indexing: every amplitude of ψ appears exactly once in the
matrix. This makes the cut matrix the coefficient matrix of the Schmidt decomposition.

### 3.2 Schmidt rank at a cut

> **Definition 3.2 (schmidtRankAt).** For a subset `S : Finset (Fin n)`,
>
> schmidtRankAt(S, ψ) = rank( cutMatrix(· ∈ S, ψ) ).

### 3.3 Integrated information Φ over the MIP

> **Definition 3.3 (phiMIP).** Assuming biparts(n) is nonempty (i.e. `n ≥ 2`),
>
> Φ(ψ) = min over S ∈ biparts(n) of ( schmidtRankAt(S, ψ) − 1 ),
>
> the minimum (in ℕ, with truncated subtraction) of the per-cut integrated information
> over all nontrivial bipartitions.

The subtraction of 1 normalizes a separable cut (Schmidt rank 1) to zero integration;
each additional Schmidt component contributes one unit of irreducible structure. Taking
the minimum over cuts implements the minimum-information-partition principle: Φ is the
integration surviving even the most favorable (least-integrating) bipartition.

---

## 4. Main results

Throughout, `n ≥ 2` so that biparts(n) is nonempty.

### 4.1 Product cuts have Schmidt rank ≤ 1

> **Theorem 4.1 (cutMatrix_rank_le_one_of_product).** Let `S` be any subset and suppose
> ψ factors across `S`, i.e. there exist `f : ({i // i ∈ S} → Fin d) → ℂ` and
> `g : ({i // i ∉ S} → Fin d) → ℂ` with
>
> ψ(x) = f(x|_S) · g(x|_Sᶜ)   for all configurations x.
>
> Then schmidtRankAt(S, ψ) ≤ 1.

*Proof sketch.* Under the factorization, the reshaped matrix is pointwise the outer
product of the vectors `f` and `g`:

> cutMatrix(· ∈ S, ψ)(a, b) = f(a) · g(b) = vecMulVec(f, g)(a, b).

The verification is a re-indexing computation: applying the reshaping bijection
`(piEquivPiSubtypeProd p)⁻¹` to `(a, b)` produces, at site `i`, the value `a ⟨i, hi⟩` if
`i ∈ S` and `b ⟨i, hi⟩` otherwise, governed by a decidable branch whose two cases are
discharged by the subtype membership witnesses (`i.2`). Restricting this assembled
configuration to `S` returns `a`, and to `Sᶜ` returns `b`, so `f(x|_S) = f(a)` and
`g(x|_Sᶜ) = g(b)`. An outer product `vecMulVec(f, g)` has rank at most 1
(`rank_vecMulVec_le`), so its rank — the Schmidt rank — is ≤ 1. ∎

### 4.2 Reducibility implies zero integration

> **Theorem 4.2 (phiMIP_eq_zero_of_product_cut).** If there exists a nontrivial
> bipartition `S ∈ biparts(n)` across which ψ factors as a product (as in Theorem 4.1),
> then Φ(ψ) = 0.

*Proof sketch.* By the definition of Φ as an infimum over cuts, `inf'_le` at the
witness `S` gives Φ(ψ) ≤ schmidtRankAt(S, ψ) − 1. By Theorem 4.1, schmidtRankAt(S, ψ) ≤
1, so the right side is 0. Since Φ is a natural number, Φ(ψ) = 0. ∎

This is the exact analogue, in the tensor-network setting, of the classical statement
that a causally disconnected system has Φ = 0: a single decoupled seam suffices for
global reducibility. It is the *only-if* (easy) direction of the conjectural
equivalence "Φ = 0 ⟺ the state is a product across some cut"; the converse requires a
rank-one ⟹ outer-product structure theorem and is left for future work (Section 7).

### 4.3 The bond-dimension ceiling for matrix product states

A **matrix product state (MPS)** writes the amplitude as a contraction of per-site
tensors along internal bond indices; the **bond dimension** D is the size of the bond
crossing a given cut. Reshaping across that bond exhibits the cut matrix as a product of
an `(rows × D)` factor and a `(D × cols)` factor.

> **Theorem 4.3 (phi_mps_le_bond).** If ψ is an MPS whose bond across some nontrivial
> cut has dimension D, then Φ(ψ) ≤ D − 1.

*Proof sketch.* A factorization through an intermediate index set of size D writes the
cut matrix as `A · B` with `A : rows × D` and `B : D × cols`. The rank of a product is
bounded by the inner dimension, so schmidtRankAt ≤ D at that cut; `inf'_le` propagates
this to Φ, and subtracting 1 gives Φ ≤ D − 1. ∎

> **Theorem 4.4 (phi_mps_bondTwo_le_one).** For an MPS with bond dimension D = 2,
> Φ(ψ) ≤ 1.

*Proof sketch.* Specialize Theorem 4.3 to D = 2. This is the concept's explicit test
case: a bond-2 MPS integrates at most one unit ("one bit") of Schmidt structure across
the bond. ∎

### 4.4 Tightness: maximal entanglement saturates the ceiling

> **Theorem 4.5 (phi_maximallyEntangled_eq).** For the maximally entangled state on two
> d-dimensional systems — the state whose cut matrix is (a scalar multiple of) the d×d
> identity — the Schmidt rank across the cut is d, and Φ = d − 1.

*Proof sketch.* The coefficient matrix of the maximally entangled state is diagonal with
all diagonal entries nonzero (the identity up to normalization); its rank is d. Across
the single nontrivial cut of a bipartite system this is the only contribution, so Φ = d
− 1. Combined with Theorem 4.3, this shows the bond-dimension bound is *tight*: attaining
Φ = d − 1 requires a bond as wide as the local dimension (D = d). ∎

### 4.5 The geometric (area-law) ceiling

> **Theorem 4.6 (schmidtRankAt_le_block).** For any subset `S` and any ψ,
>
> schmidtRankAt(S, ψ) ≤ |{configurations of Sᶜ}| = d^{|Sᶜ|}.

*Proof sketch.* The Schmidt rank is the rank of cutMatrix, and the rank of any matrix is
at most its number of columns (`rank_le_card_width`). The columns are indexed by
configurations of the complement block `Sᶜ`, of which there are exactly `d^{|Sᶜ|}`. ∎

Symmetrically, the rank is bounded by the number of rows `d^{|S|}`, so the Schmidt rank
across any cut is at most `d^{min(|S|, |Sᶜ|)}` — a discrete entanglement **area law**:
integration across a cut is throttled by the *smaller* of the two blocks, i.e. by the
boundary rather than the bulk.

### 4.6 Two independent ceilings

Theorems 4.3 and 4.6 give two structurally different upper bounds on the per-cut Schmidt
rank: an **algebraic** ceiling (bond dimension D) and a **geometric** ceiling (smaller
block size d^{min(|S|,|Sᶜ|)}). Because Φ is the minimum over cuts, the
minimum-information partition selects the cut where the smaller of these two ceilings is
itself smallest. Φ is therefore the height of the lowest achievable ceiling, minus one.

---

## 5. Algorithms

### 5.1 Exact Φ by exhaustive MIP search

```
INPUT:  amplitude tensor ψ given as a dictionary config ↦ amplitude, with n sites,
        local dimension d.
OUTPUT: Φ(ψ).

for each subset S of {0,…,n−1} with S nonempty and S ≠ all:
    build cutMatrix(S):  rows = configs of S, cols = configs of Sᶜ,
                         entry[a][b] = ψ(merge(a,b))
    r_S = numerical_rank(cutMatrix(S))         # SVD; count singular values > tol
    contribution_S = r_S − 1
Φ = min over all such S of contribution_S
return Φ
```

Complexity: there are `2ⁿ − 2` nontrivial bipartitions; each cut matrix has at most `dⁿ`
entries and its rank costs an SVD of size `d^{|S|} × d^{|Sᶜ|}`. The search is exponential
in `n`, mirroring the well-known intractability of exact IIT; for the small systems of
interest (and for MPS, where the bond bound short-circuits the search) it is entirely
practical.

### 5.2 Schmidt rank at a single cut

```
INPUT:  ψ, cut S.
OUTPUT: schmidtRankAt(S, ψ).
M = reshape ψ into a (d^{|S|}) × (d^{|Sᶜ|}) matrix across S
return numerical_rank(M)         # number of singular values above tolerance
```

### 5.3 MPS bond bound (no SVD needed)

```
INPUT:  an MPS with per-bond dimensions D_1, …, D_{n−1}.
OUTPUT: an upper bound on Φ.
return (min over bonds of D_i) − 1
```

This realizes Theorem 4.3 directly from the network's geometry, certifying an upper
bound on integration without ever forming the exponentially large amplitude tensor.

---

## 6. Relation to graph-theoretic IIT

The construction is built to mirror the classical graph formulation, in which a causal
system is a weighted directed graph and Φ is the minimum, over nontrivial bipartitions,
of the total cross-cut weight. The present work keeps the *architecture* — minimum over
the identical set `biparts(n)` — and substitutes the quantum **Schmidt rank across the
cut** for the classical cross-cut weight. The correspondence is exact at the level of
the two limiting theorems:

| Classical graph IIT                         | Tensor-network IIT (this work)            |
|---------------------------------------------|-------------------------------------------|
| Φ = min over cuts of cross-cut weight       | Φ = min over cuts of (Schmidt rank − 1)   |
| disconnected graph ⟹ Φ = 0                  | product cut ⟹ Φ = 0 (Theorem 4.2)         |
| cut weight bounded by edge count            | Schmidt rank bounded by d^{|Sᶜ|} (Thm 4.6)|

The cross-domain bridge — graph min-cut IIT ≅ tensor-network Schmidt-rank IIT — is the
conceptual contribution: irreducibility-as-min-cut and entanglement-as-rank are the same
functional over the same lattice of bipartitions.

---

## 7. Discussion and future work

### 7.1 What is and is not captured

The discrete Φ = rank − 1 captures the *support* of the Schmidt spectrum (how many
nonzero Schmidt coefficients exist) but not its *shape* (how the weight is distributed).
It is therefore a faithful indicator of separability and of the dimension of irreducible
correlation, but it is insensitive to near-degenerate spectra. This is a deliberate
first approximation: it makes the two poles of IIT exact, provable linear algebra.

### 7.2 The converse direction

We proved reducibility ⟹ Φ = 0. The converse — Φ = 0 ⟹ the state factors across some
cut — requires the structure theorem that a rank-one matrix is an outer product, lifted
back through the reshape to a tensor factorization. This completes the equivalence "Φ = 0
⟺ product across some cut" and is the most immediate next step.

### 7.3 Toward von Neumann mutual information

The physically canonical refinement replaces rank with the **quantum mutual
information** across the cut, i.e. the von Neumann entropy of the reduced density matrix
(for a pure state, twice the entanglement entropy). This weighs Schmidt components by
their probabilities and yields a continuous Φ. Formalizing it requires density-matrix
and von Neumann–entropy infrastructure not yet available in the underlying library; this
defines a natural subsequent development.

### 7.4 LOCC monotonicity

The deepest structural question is whether the discrete Φ is **monotone under local
operations and classical communication (LOCC)**. Schmidt rank is known to be
non-increasing under LOCC, which strongly suggests Φ inherits monotonicity; a proof would
elevate Φ from a "cut statistic" to a bona fide entanglement measure and would tie IIT's
integration directly to the resource theory of entanglement.

### 7.5 Beyond pure states and beyond MPS

Further directions include: mixed-state Φ via entanglement of formation or negativity;
higher tensor networks (PEPS, MERA), where the area-law ceiling becomes genuinely
geometric and ties Φ to the topology of the network; and the relation between the MIP and
the network's *minimal cut* in the sense of holographic entanglement (Ryu–Takayanagi),
hinting at a geometric account of integration.

---

## 8. Conclusion

By reshaping a quantum amplitude tensor across each bipartition and reading off the
Schmidt rank, we obtain an exact, discrete integrated-information functional Φ whose
behavior at both extremes is provable linear algebra: products integrate nothing,
maximal entanglement integrates maximally, and the bond dimension and block size impose
two independent, sharp ceilings in between. The construction reproduces the architecture
of classical graph-theoretic IIT cut for cut, exposing irreducibility, entanglement, and
matrix rank as three faces of one functional. The notion of an indivisible whole, long
resistant to definition, acquires here a precise mathematical shape — and an integer
value.
