# Obstruction Spectra for Minor-Closed Matroid Classes: Duality, Antichains, and Spectral Bounds

## Abstract

We develop a rigorous framework for studying matroid minor theory through **obstruction spectra** — rank-graded distributions of excluded minors for minor-closed classes. Working directly with Mathlib's matroid library, we formalize the notions of minor ideal, excluded minor, and obstruction set, and prove several structural theorems:

1. **Duality preserves the minor relation** (`isMinor_dual`): if N ≤ₘ M then N✶ ≤ₘ M✶.
2. **Dual involution** (`dualIdeal_dualIdeal`): the dual of a minor ideal is a minor ideal, and dualing twice recovers the original.
3. **Dual Palindromy Theorem** (`dual_palindromy`): for self-dual minor ideals, M is an excluded minor if and only if M✶ is an excluded minor.
4. **Antichain Theorem** (`obstructionSet_antichain`): the obstruction set is an antichain in the minor order.
5. **Dual Generation Theorem** (`dualIdeal_generated`): dualizing commutes with ideal generation.
6. **Spectral bounds**: the spectrum at any rank is bounded by the total count; intersection spectra are sub-additive; and the spectrum partitions the total count.

All results are machine-verified in Lean 4 with Mathlib, building on the existing `Matroid.IsMinor` infrastructure.

## 1. Introduction

### 1.1 Background

The theory of matroid minors, inspired by the Robertson-Seymour graph minor theorem, studies which classes of matroids can be characterized by finitely many excluded minors. A **minor-closed class** (or **minor ideal**) is a collection of matroids closed under deletion and contraction. The **excluded minors** for such a class are the minimal matroids not in the class — "minimal" in the sense that all proper minors belong to the class.

The Robertson-Seymour theorem establishes that every minor-closed class of graphs has finitely many excluded minors. The Geelen-Gerards-Whittle (GGW) conjecture extends this to GF(q)-representable matroids. These results are qualitative: they assert finiteness without describing the structure of the excluded minor set.

### 1.2 Contribution

We introduce the **obstruction spectrum** — the function σ : ℕ∞ → ℕ that counts excluded minors at each rank — and prove structural theorems about this invariant. Our main contributions:

- **Dual Palindromy**: For self-dual ideals, σ is palindromic (excluded minors come in dual pairs).
- **Antichain Structure**: The obstruction set is an antichain, placing fundamental constraints on possible spectra.
- **Sub-additive Intersection Bound**: σ(I ∩ J)(r) ≤ σ(I)(r) + σ(J)(r), linking spectral complexity to lattice operations.
- **Spectral Partition**: The spectrum partitions the total obstruction count by rank.

### 1.3 Related Work

Matroid minor theory has a vast literature. Tutte's excluded minor characterizations (graphic matroids: {U₂,₄, F₇, F₇*, M*(K₅), M*(K₃,₃)}; binary matroids: {U₂,₄}) are classical. Geelen, Gerards, and Whittle's program for GF(q)-representable matroids is ongoing. Our spectral viewpoint is new: rather than computing specific excluded minor sets, we study structural properties of the obstruction set as a whole.

The connection between matroid duality and excluded minor structure has been noted informally (e.g., the excluded minors for graphic matroids are closed under duality since graphic matroids form a self-dual class). Our Dual Palindromy Theorem gives this observation a precise, general formulation.

## 2. Definitions

### 2.1 Matroids and Minors

We work with Mathlib's `Matroid α` — a structure on a type `α` with a ground set `E`, base predicate `IsBase`, and independence predicate `Indep`. The minor relation `Matroid.IsMinor` is defined by:

```
N.IsMinor M ↔ ∃ C D, N = (M.contract C).delete D
```

Key properties used: transitivity (`IsMinor.trans`), reflexivity (`IsMinor.refl`), and the dual identities:
- `(M.contract C)✶ = M✶.delete C`
- `(M.delete D)✶ = M✶.contract D`

### 2.2 Minor Ideals

**Definition.** A *minor ideal* on type α is a predicate `pred : Matroid α → Prop` satisfying:
```
∀ M N, pred M → N.IsMinor M → pred N
```

### 2.3 Excluded Minors

**Definition.** A matroid M is an *excluded minor* for ideal I if:
1. `¬I.pred M` (M is not in the ideal)
2. For all N with `N.IsMinor M` and `¬M.IsMinor N` (proper minors), `I.pred N`.

### 2.4 The Dual Ideal

**Definition.** The *dual ideal* `I.dualIdeal` is defined by `I.dualIdeal.pred M ↔ I.pred M✶`.

### 2.5 The Obstruction Spectrum

**Definition.** For a finitary obstruction system `F` (a minor ideal with an explicit finite set of excluded minors), the *obstruction spectrum* is:
```
F.spectrum r = |{M ∈ F.obstructions | M.eRank = r}|
```

## 3. Main Results

### 3.1 Duality Preserves the Minor Relation

**Theorem (isMinor_dual).** If N ≤ₘ M then N✶ ≤ₘ M✶.

*Proof.* If N = (M / C) \ D, then N✶ = ((M / C) \ D)✶ = (M / C)✶ / D = (M✶ \ C) / D. This is a minor of M✶ because deletion and contraction each produce minors, and the minor relation is transitive. □

This also gives `isMinor_dual_iff`: N✶ ≤ₘ M✶ ↔ N ≤ₘ M.

### 3.2 Dual Involution

**Theorem (dualIdeal_dualIdeal).** I.dualIdeal.dualIdeal = I.

*Proof.* By extensionality: I.dualIdeal.dualIdeal.pred M = I.dualIdeal.pred M✶ = I.pred M✶✶ = I.pred M, using M✶✶ = M. □

### 3.3 Dual Palindromy

**Theorem (dual_palindromy).** If I is self-dual (I = I.dualIdeal), then M is an excluded minor for I iff M✶ is.

*Proof.* Self-duality gives I.pred M ↔ I.pred M✶ for all M. For the forward direction: if M is excluded, then ¬I.pred M, hence ¬I.pred M✶ by the contrapositive of the backward direction of self-duality. For the proper-minor condition: if N ≤ₘ M✶ and ¬(M✶ ≤ₘ N), then by `isMinor_dual_iff`, N✶ ≤ₘ M and ¬(M ≤ₘ N✶). Since M is excluded, I.pred N✶, hence I.pred N by self-duality. □

### 3.4 Antichain Theorem

**Theorem (obstructionSet_antichain).** If M and N are both excluded minors for I and M ≤ₘ N, then N ≤ₘ M.

*Proof.* Suppose M ≤ₘ N and ¬(N ≤ₘ M). Then M is a proper minor of N. Since N is excluded, I.pred M. But M is excluded, so ¬I.pred M. Contradiction. □

**Corollary.** The obstruction set is an antichain: no excluded minor is a proper minor of another.

### 3.5 Dual Generation

**Theorem (dualIdeal_generated).** (generated S).dualIdeal = generated (S✶).

*Proof.* By extensionality: (generated S).dualIdeal.pred M ↔ ∃ N ∈ S, M✶ ≤ₘ N ↔ ∃ N ∈ S, M ≤ₘ N✶ (by `isMinor_dual_iff`) ↔ ∃ K ∈ S✶, M ≤ₘ K (with K = N✶). □

### 3.6 Spectral Bounds

**Theorem (spectrum_le_total).** F.spectrum r ≤ F.totalObstructions.

*Proof.* The filter of a finset has cardinality at most the original finset. □

**Theorem (spectrum_sum_eq_total).** If ranks covers all occurring ranks, then ∑ᵣ F.spectrum r = F.totalObstructions.

*Proof.* This is the partition identity: the obstructions finset decomposes as a disjoint union of fibers indexed by rank. □

**Theorem (spectrum_inf_le_add).** Under the natural embedding hypothesis, Fᵢₙf.spectrum r ≤ F₁.spectrum r + F₂.spectrum r.

*Proof.* Each obstruction of the intersection belongs to at least one of the original obstruction sets, so the filter is contained in a union. □

## 4. The Minor Ideal Lattice

Minor ideals form a partially ordered set under inclusion. We define:
- `topIdeal`: all matroids (no excluded minors)
- `botIdeal`: no matroids
- `infIdeal I J`: the intersection

We prove:
- The top ideal has empty obstruction set.
- The top ideal is self-dual.
- An excluded minor for I that belongs to J cannot be an excluded minor for J.

## 5. Algorithms

### 5.1 Obstruction Spectrum Computation

Given an explicit finite set of excluded minors with their ranks:
1. Group excluded minors by rank.
2. Count each group.
3. The resulting histogram is the obstruction spectrum.

### 5.2 Palindromy Verification

To verify palindromy for a candidate self-dual ideal:
1. Compute the obstruction spectrum σ.
2. For each rank r in the support of σ, verify σ(r) = σ(n - r) where n is the ground set size.
3. If palindromy fails, the ideal is not self-dual.

## 6. Examples

### 6.1 Binary Matroids

The class of binary matroids (representable over GF(2)) has a single excluded minor: U₂,₄ (the uniform matroid of rank 2 on 4 elements). The obstruction spectrum is σ(2) = 1, zero elsewhere.

### 6.2 Graphic Matroids

The class of graphic matroids has 5 excluded minors: U₂,₄, F₇, F₇*, M*(K₅), M*(K₃,₃). This class is self-dual, and indeed F₇ and F₇* form a dual pair, while M*(K₅) and M*(K₃,₃) are self-dual. The palindromy theorem guarantees this pairing.

### 6.3 Regular Matroids

The class of regular matroids (representable over every field) is self-dual and has excluded minors {U₂,₄, F₇, F₇*}. Again, F₇ and F₇* form a dual pair.

## 7. Discussion

### 7.1 Spectral Rigidity Conjecture

We conjecture that for GF(q)-representable matroids with q prime, two distinct minor-closed classes with the same obstruction spectrum must differ only on matroids of bounded rank. If true, this would transform the GGW conjecture from a finiteness question into a classification problem with computable invariants.

### 7.2 Connection to Coding Theory

Self-dual codes over finite fields give rise to self-dual matroid classes. The palindromy theorem provides a structural constraint on the excluded minors for these classes. Understanding the spectral shape of code-derived matroid classes could yield new bounds in coding theory.

### 7.3 Growth Rate Connections

The Growth Rate Theorem for matroids (Geelen-Kabell-Kung-Whittle) establishes that for minor-closed classes not containing all rank-2 matroids, the maximum number of elements grows as O(r^c) for some constant c depending on the class. This growth rate should constrain the obstruction spectrum, but the precise relationship remains to be established.

## 8. Future Work

1. **Spectral Rigidity**: Prove or disprove that the obstruction spectrum uniquely determines a minor-closed class (up to equivalence).
2. **Growth Rate–Spectrum Connection**: Establish bounds on the spectrum in terms of the growth rate of the class.
3. **Computational Enumeration**: Develop algorithms to enumerate minor-closed classes with small obstruction spectra.
4. **Category-Theoretic Unification**: Connect the minor ideal lattice to the lattice of varieties in universal algebra.

## References

1. Robertson, N. and Seymour, P.D. "Graph Minors I–XXIII." Journal of Combinatorial Theory, Series B (1983–2004).
2. Geelen, J., Gerards, B., and Whittle, G. "Towards a matroid-minor structure theory." Combinatorics, Complexity, and Chance (2007).
3. Oxley, J. "Matroid Theory." Oxford University Press, 2nd edition (2011).
4. Tutte, W.T. "A homotopy theorem for matroids, I, II." Transactions of the American Mathematical Society (1958).
5. Whitney, H. "On the abstract properties of linear dependence." American Journal of Mathematics (1935).
