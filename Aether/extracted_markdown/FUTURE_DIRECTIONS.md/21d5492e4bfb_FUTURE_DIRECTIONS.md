# Future Directions: Mathematical Foundations of Integrated Information Theory

The file `Foundations.lean` establishes the rigorous core of Tononi's Integrated
Information Theory (IIT) as a theorem of finite information geometry: integrated
information `Φ` is the value of the **Minimum Information Partition (MIP)**, it is
attained, it is nonnegative, and — the headline dichotomy — it vanishes *iff* the
system factorizes across some cut. The effective information of a cut was identified
with the Kullback–Leibler divergence between the joint distribution and the product of
its marginals, and we proved Gibbs' inequality and its equality case from scratch.

Below are five concrete, falsifiable directions that extend this foundation. Each is
stated so that a future cycle can turn it into a Lean theorem (or refute it with a
counterexample).

## 1. Subadditivity / data-processing for the effective information

**Conjecture.** Coarse-graining a part of the system (applying a stochastic map to
`X`) cannot increase the effective information of a cut: if `T : X → X'` is a
deterministic or stochastic relabelling and `j'` is the pushforward joint
distribution, then `crossInfo j' ≤ crossInfo j`.

The key insight is that the cross-cut effective information is a KL divergence, and KL
divergence is monotone under the application of any Markov kernel to both arguments
(the data-processing inequality); since the product-of-marginals structure is preserved
by acting on a single part, monotonicity descends directly to `crossInfo`. **Why now?**
We already have `klDivFin` with its nonnegativity and equality case in hand, and
`prodMarginal` commutes with single-part pushforwards by `Finset.sum` reindexing — the
only missing lemma is the log-sum inequality, which is provable by the same
`Real.log_le_sub_one_of_pos` technique used for `klDivFin_term_le`.

## 2. Exact `Φ` for the symmetric binary channel and a strict-monotonicity law

**Conjecture.** For two bits with `P(0,0) = P(1,1) = (1+r)/4`, `P(0,1) = P(1,0) =
(1-r)/4` (correlation `r ∈ [0,1]`), the single-cut `Φ` equals the binary mutual
information `Φ(r) = ((1+r)/2)·log(1+r) + ((1-r)/2)·log(1-r)`, and `Φ` is strictly
increasing in `r` on `[0,1]` with `Φ(0) = 0`, `Φ(1) = log 2`.

The key insight is that for a one-cut system `Φ` collapses to a single `crossInfo`,
which for this family is a one-parameter analytic function whose derivative is
`(1/2)·log((1+r)/(1-r)) ≥ 0`, vanishing only at `r = 0`. **Why now?** Our worked
examples already pin down the two endpoints (`r = 0` gives `Φ = 0`, the correlated case
`r = 1` gives `Φ > 0`); turning the qualitative dichotomy into a closed-form
monotone curve is the natural quantitative sharpening and needs only `Real.log`
calculus that Mathlib supports.

## 3. The MIP is a genuine bipartition invariant, not an artifact of labelling

**Conjecture.** Relabelling the elements of the system (an automorphism of the index
set that respects the cut structure) leaves `Φ` invariant, and more strongly, `Φ`
depends only on the *unordered* family of cut values, so two systems with the same
multiset `{EI c}` have equal `Φ`.

The key insight is that `Phi` is defined as `Finset.inf'` over `univ`, and `inf'` is
invariant under any bijection of the index type and depends only on the image multiset;
hence `Φ` is a symmetric function of the cut-effective-informations. **Why now?** We have
`Phi`, `Phi_le`, and `exists_mip` as the complete order-theoretic interface; the
invariance statements are immediate corollaries of `Finset.inf'` congruence lemmas and
would cleanly justify calling `Φ` an intrinsic property of the system.

## 4. A spectral / additivity law for independent composite systems

**Conjecture.** If a system is the independent product of two subsystems `A` and `B`
(the global joint factorizes as `j_A ⊗ j_B`), then the global minimum information
partition is achieved by the cut separating `A` from `B`, and `Φ_global = 0`; moreover
for *weakly* coupled systems `Φ_global ≤ min(Φ_A, Φ_B) + coupling`, a perturbative
bound.

The key insight is that an exact product structure exhibits a zero-cost cut, so by our
`Phi_eq_zero_iff` the global `Φ` must vanish — independence is the algebraic signature of
disintegration. **Why now?** `Phi_eq_zero_iff` and `crossInfo_eq_zero_iff_reducible`
together already make the exact-product case a one-line corollary; the perturbative
bound is the first genuinely new analytic content and motivates building a
`crossInfo`-continuity lemma in the joint distribution.

## 5. From bipartitions to the full IIT partition lattice (`Finpartition`)

**Conjecture.** Replacing the single bipartition by the full lattice of set partitions
(`Finpartition (Finset.univ)`), define `Φ` as the minimum over *all* nontrivial
partitions of a partition-indexed effective information; then `Φ` is monotone-decreasing
as the partition lattice is enlarged, and the MIP is always a *bipartition* (the
minimizing partition has exactly two blocks).

The key insight is that any multi-block partition's effective information dominates that
of the coarsest bipartition refining it, by the chain rule for KL divergence, so the
infimum over the whole lattice is realized on bipartitions — exactly IIT's empirical
"the MIP is a cut" heuristic, here as a theorem. **Why now?** Our `Phi_antitone_cuts`
already proves monotonicity of `inf'` under enlarging the cut family, which is the
lattice-monotonicity half; Mathlib's `Finpartition` API supplies the partition lattice,
so the remaining work is the chain-rule decomposition of `klDivFin`, a finite-sum
identity well within reach of the techniques used here.
