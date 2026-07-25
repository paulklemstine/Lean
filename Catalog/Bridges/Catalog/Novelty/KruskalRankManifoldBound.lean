import Mathlib
import Novelty.CoverDichotomyCount

/-!
# Kruskal rank of manifold data and the Cover dichotomy bound

The *Kruskal rank* of a finite family of vectors `v : ι → V` is the largest `s`
such that **every** `s` of the vectors are linearly independent — a quantitative
"general position" invariant central to tensor decomposition and compressed
sensing. This file proves the linear-algebra engine behind the mission's claim

  *"`N` points in general position on a `d`-dimensional structure have Kruskal
  rank `s ≤ d + 1`"*

and threads it through Cover's counting function
(`Catalog.Novelty.CoverDichotomy`) to the **manifold-constrained dichotomy
bound** `C_F(N) ≤ C(N, d + M' + 1)`, with strict collapse below `2^N`.

## Main results

* `kruskalRankGe_le_finrank` — the engine: an `s`-family of independent vectors
  forces `s ≤ finrank`;
* `kruskalRank_le_finrank` / `kruskalRank_le_dim_succ` — the packaged invariant
  is bounded by the dimension; on a `(d+1)`-dimensional space it is `≤ d+1`;
* `coverCount_mono_right` — Cover's function is monotone in the parameter budget;
* `manifold_dichotomy_bound` / `manifold_dichotomy_collapse` — the Φ-separable
  dichotomy count is `≤ C(N, d+M'+1)`, and *strictly* below `2^N` once
  `N > d+M'+1`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the "general position" hypothesis in Cover's theorem
is exactly a *Kruskal rank* statement, and the intrinsic dimension `d` (not the
ambient `M`) caps that rank at `d+1`. Counter-intuitive corollary: enlarging the
ambient space `ℝ^M` around a fixed `d`-manifold cannot increase expressivity —
the bound is `M`-free.

EXPERIMENT (Experimenter): in `ℝ^{d+1}` any `d+2` vectors are dependent
(`finrank`-based), so no configuration attains Kruskal rank `d+2`; verified via
`LinearIndependent.fintype_card_le_finrank`. Cover's function is monotone in its
second slot (`#eval` table, ComputationalEvidence.md), so raising the budget from
`s+M'` to the worst case `d+M'+1` only weakens the bound — safe.

ANALYSIS (Analyst): the crux `kruskalRankGe_le_finrank` needs an *actual*
`s`-element subset to instantiate independence; `Finset.exists_subset_card_eq`
supplies it whenever `s ≤ card ι`. The `sSup` packaging requires the witness
`HasKruskalRankGe v 0` (empty family independent) for non-emptiness of the sup
set. The bridge combines `count_le_coverCount` with monotonicity and the strict
collapse `coverCount_lt_two_pow`.

CRITIQUE (Critic): is `kruskalRank` degenerate (always `0`)? No — the sup set is
downward-closed and contains genuine positive ranks for independent data; the
theorem bounds it *above* by `finrank`, the sharp geometric ceiling. The bridge
is non-vacuous: `coverCountSystem` (from the imported file) is a witnessing
dichotomy system, and the collapse theorem yields the concrete strict inequality
`count < 2^N`.
-- !-- end Lab Notes -- !--
-/

namespace Catalog.Novelty.KruskalRank

open Module Catalog.Novelty.CoverDichotomy

section LinearAlgebra

variable {K V ι : Type*} [Field K] [AddCommGroup V] [Module K V] [FiniteDimensional K V]
  [Fintype ι]

/-- `HasKruskalRankGe K v s`: every `s`-element subfamily of `v` is linearly
independent. The **Kruskal rank** is the largest such `s`. -/
def HasKruskalRankGe (K : Type*) [Field K] [AddCommGroup V] [Module K V]
    (v : ι → V) (s : ℕ) : Prop :=
  ∀ t : Finset ι, t.card = s → LinearIndependent K (fun i : t => v i)

/-- **Engine.** If every `s`-subfamily is independent (and `s ≤ |ι|`, so such a
subfamily exists) then `s ≤ finrank K V`. This is the linear-algebra content of
"general position caps the Kruskal rank by the dimension". -/
theorem kruskalRankGe_le_finrank (v : ι → V) (s : ℕ)
    (hs : HasKruskalRankGe K v s) (hcard : s ≤ Fintype.card ι) :
    s ≤ Module.finrank K V := by
  obtain ⟨t0, _, ht0⟩ := Finset.exists_subset_card_eq (s := (Finset.univ : Finset ι))
    (by simpa using hcard)
  have hli : LinearIndependent K (fun i : t0 => v i) := hs t0 ht0
  have h := hli.fintype_card_le_finrank
  rwa [Fintype.card_coe, ht0] at h

/-- The **Kruskal rank** of a finite family: the largest size of a "uniformly
independent" subfamily (capped by the number of vectors). -/
noncomputable def kruskalRank (K : Type*) [Field K] [AddCommGroup V] [Module K V]
    (v : ι → V) : ℕ :=
  sSup {s | HasKruskalRankGe K v s ∧ s ≤ Fintype.card ι}

omit [FiniteDimensional K V] [Fintype ι] in
/-- The empty subfamily is (vacuously) independent, so every family has Kruskal
rank `≥ 0`; this makes the defining `sSup` set non-empty. -/
theorem hasKruskalRankGe_zero (v : ι → V) : HasKruskalRankGe K v 0 := by
  intro t ht
  rw [Finset.card_eq_zero] at ht
  subst ht
  exact linearIndependent_empty_type

/-- **The Kruskal rank is bounded by the dimension.** -/
theorem kruskalRank_le_finrank (v : ι → V) :
    kruskalRank K v ≤ Module.finrank K V := by
  refine csSup_le ⟨0, hasKruskalRankGe_zero v, Nat.zero_le _⟩ ?_
  rintro s ⟨hs, hcard⟩
  exact kruskalRankGe_le_finrank v s hs hcard

/-- **Mission specialization `s ≤ d + 1`.** On the `(d+1)`-dimensional
homogenization of a `d`-dimensional tangent/data structure, the Kruskal rank of
any point configuration in general position is at most `d + 1`. -/
theorem kruskalRank_le_dim_succ (v : ι → V) {d : ℕ}
    (hdim : Module.finrank K V = d + 1) :
    kruskalRank K v ≤ d + 1 := by
  rw [← hdim]; exact kruskalRank_le_finrank v

end LinearAlgebra

/-- **Monotonicity of Cover's function in the parameter budget.** A larger budget
never realizes fewer dichotomies. -/
theorem coverCount_mono_right (N : ℕ) {d d' : ℕ} (h : d ≤ d') :
    coverCount N d ≤ coverCount N d' := by
  unfold coverCount
  apply Nat.mul_le_mul_left
  exact Finset.sum_le_sum_of_subset (Finset.range_mono h)

/-- **Manifold-constrained dichotomy bound.** Whenever the effective parameter
budget `p` of a dichotomy system is at most `d + M' + 1` (the value forced by
Kruskal rank `s ≤ d+1` plus the `M'` classifier coordinates and one
homogenizing coordinate), the number of Φ-separable dichotomies is bounded by
Cover's counting function `C(N, d + M' + 1)`. -/
theorem manifold_dichotomy_bound (S : DichotomySystem)
    {N d M' p : ℕ} (hN : 1 ≤ N) (hp0 : 1 ≤ p) (hp : p ≤ d + M' + 1) :
    S.count N p ≤ coverCount N (d + M' + 1) :=
  le_trans (S.count_le_coverCount hN hp0) (coverCount_mono_right N hp)

/-- **Strict expressivity collapse on low-dimensional data.** If the sample size
exceeds the effective dimension `d + M' + 1`, then the Φ-separable dichotomy
count is *strictly* below the unconstrained `2^N`: the low-dimensional data
structure genuinely limits what the classifier family can shatter. -/
theorem manifold_dichotomy_collapse (S : DichotomySystem)
    {N d M' p : ℕ} (hp0 : 1 ≤ p) (hp : p ≤ d + M' + 1) (hN : d + M' + 1 < N) :
    S.count N p < 2 ^ N := by
  have h1 : S.count N p ≤ coverCount N (d + M' + 1) :=
    manifold_dichotomy_bound S (by omega) hp0 hp
  have h2 : coverCount N (d + M' + 1) < 2 ^ N := coverCount_lt_two_pow hN
  omega

end Catalog.Novelty.KruskalRank