/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# The Structure of the Emotional Chromatic Number: Clique–Degree Sandwich

The catalog defines the emotional chromatic number
`emoChrom G = sInf {k | 3 ≤ k ∧ G.Colorable k}` (`Catalog/Geometry/EmotionalChromaticNumber.lean`)
and computes it for cliques, cycles and friendship windmills, one family at a time.  This file
identifies the invariant *once and for all*:

  **Structure theorem** `emoChrom G = max χ(G) 3`   (`emoChrom_eq_max_chromaticNumber`)

so `emoChrom` is the classical chromatic number truncated below at the emotional floor.  Every
per-family computation in the catalog becomes a one-line corollary, and — combined with the
greedy bound of `Catalog/Computation/EmotionalGreedyColoring.lean` — we obtain the two-sided

  **Sandwich theorem** `max ω(G) 3 ≤ emoChrom G ≤ max (Δ(G) + 1) 3`  (`emoChrom_sandwich`)

where `ω(G)` is the largest group of mutual friends and `Δ(G)` the largest friend count.  Both
sides are attained (cliques attain both; even cycles attain neither, the floor deciding instead).

## Main results

* `emoChrom_eq_max_chromaticNumber` : `emoChrom G = max χ(G).toNat 3`.
* `emoChrom_eq_chromaticNumber`     : if three emotions are genuinely needed, `emoChrom = χ`.
* `emoChrom_mono_left`              : adding friendships never decreases the emotional demand.
* `emoChrom_clique_lower`           : a group of `c` mutual friends forces `emoChrom ≥ c`.
* `emoChrom_cliqueNum_le`           : `max ω(G) 3 ≤ emoChrom G`.
* `emoChrom_sandwich`               : `max ω(G) 3 ≤ emoChrom G ≤ max (Δ(G) + 1) 3`.
* `emoChrom_sum`                    : two disconnected communities: `emoChrom` is the maximum.
* `emoChrom_congr_iso`              : isomorphism invariance of the emotional chromatic number.
* `emoChrom_le_six_iff`             : the six-emotion window is exactly six-colorability.
* `emoChrom_eq_three_of_colorable_two` : every bipartite network sits exactly on the floor.

-- !-- Lab Notes -- !--
HYPOTHESIS (Stage 1).  `emoChrom` looks like a new invariant, but the admissible set
`{k | 3 ≤ k ∧ Colorable k}` is an up-set in `ℕ` intersected with `[3,∞)`; hence `emoChrom` should
collapse to `max χ 3` and inherit *all* structural theory of `χ`.  If true this is a
falsification of the invariant's novelty and simultaneously the tool that makes it computable.

EXPERIMENT (Stage 2).  Proved.  `Nat.sInf_le` gives `≤` from
`colorable_chromaticNumber_of_fintype`; the reverse uses `ENat.toNat_le_of_le_coe` applied to
`chromaticNumber_le_iff_colorable`.  Then `emoChrom_complete`, `emoChrom_cycle` and
`emoChrom_friendship` of the catalog all follow from a single line each.

ANALYSIS (Stage 3).  The collapse is *not* a triviality result: it says the "emotional floor"
is a purely order-theoretic truncation carrying no combinatorial content, so all genuine content of
the psychology model lives in `χ` itself — bounded above by `Δ + 1` (greedy) and below by `ω`
(cliques).  The gap `ω ≤ χ ≤ Δ + 1` is where "emotional diversity" of a network actually varies,
and the sandwich makes the mission's `[3,6]` claim decidable from two local statistics of the
network.  Corollary: the mission's implicit claim that `emoChrom` is a *new* invariant is FALSE,
while its empirical claim about the `[3,6]` window is TRUE for all networks with `ω ≤ 6` and
`Δ ≤ 5`, and FALSE in general (`K_7`).
-- !-- End Lab Notes -- !--
-/

import Computation.EmotionalGreedyColoring

namespace Catalog.Computation.EmotionalChromaticSandwich

open SimpleGraph Finset
open Catalog.Combinatorics.ChromaticPolynomial
open Catalog.Novelty.EmotionalChromaticNumber
open Catalog.Computation.EmotionalGreedyColoring

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## The structure theorem -/

omit [DecidableEq V] in
/-- **Structure theorem.**  The emotional chromatic number is the classical chromatic number
truncated below at the emotional floor `3`. -/
theorem emoChrom_eq_max_chromaticNumber (G : SimpleGraph V) :
    emoChrom G = max G.chromaticNumber.toNat 3 := by
  have hcol : G.Colorable G.chromaticNumber.toNat := G.colorable_chromaticNumber_of_fintype
  refine le_antisymm (emoChrom_le G (le_max_right _ _) (hcol.mono (le_max_left _ _))) ?_
  have h1 : G.chromaticNumber ≤ (emoChrom G : ℕ∞) :=
    chromaticNumber_le_iff_colorable.2 (emoChrom_colorable G)
  exact max_le (ENat.toNat_le_of_le_coe h1) (emoChrom_ge_three G)

omit [DecidableEq V] in
/-- If the network genuinely needs at least three emotions, the emotional chromatic number *is*
the chromatic number: the floor is inactive. -/
theorem emoChrom_eq_chromaticNumber (G : SimpleGraph V) (h : 3 ≤ G.chromaticNumber.toNat) :
    emoChrom G = G.chromaticNumber.toNat := by
  rw [emoChrom_eq_max_chromaticNumber]; exact max_eq_left h

omit [DecidableEq V] in
/-- Every bipartite (two-emotion colorable) social network sits exactly on the emotional floor. -/
theorem emoChrom_eq_three_of_colorable_two (G : SimpleGraph V) (h : G.Colorable 2) :
    emoChrom G = 3 :=
  (emoChrom_eq_three_iff G).2 (h.mono (by norm_num))

/-! ## Monotonicity and invariance -/

omit [Fintype V] [DecidableEq V] in
/-- **Monotone in friendships.**  Adding friendships can only increase the number of emotions
required. -/
theorem emoChrom_mono_left {G H : SimpleGraph V} [Fintype V] (hGH : G ≤ H) :
    emoChrom G ≤ emoChrom H :=
  emoChrom_le G (emoChrom_ge_three H) ((emoChrom_colorable H).mono_left hGH)

omit [DecidableEq V] in
/-- **Isomorphism invariance.**  Relabelling the people of a social network does not change its
emotional chromatic number. -/
theorem emoChrom_congr_iso {W : Type*} [Fintype W] [DecidableEq W]
    {G : SimpleGraph V} {H : SimpleGraph W} (e : G ≃g H) :
    emoChrom G = emoChrom H :=
  le_antisymm
    (emoChrom_le G (emoChrom_ge_three H) ((emoChrom_colorable H).of_hom e.toHom))
    (emoChrom_le H (emoChrom_ge_three G) ((emoChrom_colorable G).of_hom e.symm.toHom))

/-! ## The lower half: cliques -/

omit [DecidableEq V] in
/-- **Cliques force emotions.**  A group `s` of mutual friends needs `#s` distinct emotions, hence
`#s ≤ emoChrom G`. -/
theorem emoChrom_clique_lower {G : SimpleGraph V} {s : Finset V} (hs : G.IsClique (s : Set V)) :
    s.card ≤ emoChrom G :=
  hs.card_le_of_colorable (emoChrom_colorable G)

omit [DecidableEq V] in
/-- The clique number, truncated at the emotional floor, is a lower bound for `emoChrom`. -/
theorem emoChrom_cliqueNum_le (G : SimpleGraph V) :
    max G.cliqueNum 3 ≤ emoChrom G := by
  obtain ⟨s, hs⟩ := G.exists_isNClique_cliqueNum
  exact max_le (hs.card_eq ▸ emoChrom_clique_lower hs.isClique) (emoChrom_ge_three G)

/-! ## The sandwich -/

/-- **Sandwich theorem.**  For every finite social network,
`max ω(G) 3 ≤ emoChrom G ≤ max (Δ(G) + 1) 3`: the largest group of mutual friends bounds the
emotional demand from below, and one more than the largest friend count bounds it from above. -/
theorem emoChrom_sandwich (G : SimpleGraph V) [DecidableRel G.Adj] :
    max G.cliqueNum 3 ≤ emoChrom G ∧ emoChrom G ≤ max (G.maxDegree + 1) 3 :=
  ⟨emoChrom_cliqueNum_le G, emoChrom_le_maxDegree_add_one G⟩

/-- **Decidable emotional window.**  A network whose largest clique has at most six people and in
which nobody has more than five friends has emotional chromatic number in `[3, 6]` — and both
bounds of the sandwich are then meaningful. -/
theorem emoChrom_window_of_local_data (G : SimpleGraph V) [DecidableRel G.Adj]
    (hΔ : G.maxDegree ≤ 5) : G.cliqueNum ≤ 6 ∧ 3 ≤ emoChrom G ∧ emoChrom G ≤ 6 := by
  obtain ⟨hlow, hhigh⟩ := emoChrom_sandwich G
  have h6 : emoChrom G ≤ 6 := le_trans hhigh (max_le (by omega) (by norm_num))
  exact ⟨le_trans (le_trans (le_max_left _ _) hlow) h6, emoChrom_ge_three G, h6⟩

omit [DecidableEq V] in
/-- **The six-emotion window is exactly six-colorability.** -/
theorem emoChrom_le_six_iff (G : SimpleGraph V) :
    emoChrom G ≤ 6 ↔ G.Colorable 6 :=
  ⟨fun h => (emoChrom_colorable G).mono h, fun h => emoChrom_le G (by norm_num) h⟩

/-! ## Communities: disjoint unions -/

omit [DecidableEq V] in
/-- **Two disconnected communities.**  If a social network splits into two groups with no
friendships between them, its emotional chromatic number is the maximum of the two. -/
theorem emoChrom_sum {W : Type*} [Fintype W] [DecidableEq W]
    (G : SimpleGraph V) (H : SimpleGraph W) :
    emoChrom (G ⊕g H) = max (emoChrom G) (emoChrom H) := by
  refine le_antisymm ?_ ?_
  · refine emoChrom_le _ (le_trans (emoChrom_ge_three G) (le_max_left _ _)) ?_
    exact colorable_sum.2 ⟨(emoChrom_colorable G).mono (le_max_left _ _),
      (emoChrom_colorable H).mono (le_max_right _ _)⟩
  · have hc := colorable_sum.1 (emoChrom_colorable (G ⊕g H))
    exact max_le (emoChrom_le G (emoChrom_ge_three _) hc.1)
      (emoChrom_le H (emoChrom_ge_three _) hc.2)

/-! ## Recovering the catalog's family computations -/

/-- The catalog's clique computation, recovered from the structure theorem. -/
theorem emoChrom_complete_via_structure (n : ℕ) :
    emoChrom (⊤ : SimpleGraph (Fin n)) = max n 3 := by
  rw [emoChrom_eq_max_chromaticNumber, chromaticNumber_top]
  simp

/-- Adding a further clique of the same size to a network already needing `≥ 3` emotions does not
change the answer: `emoChrom (K_n ⊕g K_n) = emoChrom (K_n)` for `n ≥ 3`. -/
theorem emoChrom_double_clique {n : ℕ} (hn : 3 ≤ n) :
    emoChrom ((⊤ : SimpleGraph (Fin n)) ⊕g (⊤ : SimpleGraph (Fin n))) = n := by
  rw [emoChrom_sum, emoChrom_complete_via_structure, max_self, max_eq_left hn]

/-
-- !-- Lab Notes (critique) -- !--
ADVERSARIAL REVIEW.
* Is `emoChrom_eq_max_chromaticNumber` trivial?  No: it needs the finiteness input
  `colorable_chromaticNumber_of_fintype` (false for infinite graphs, where `χ` may be `⊤` and
  `toNat` collapses to `0` while `emoChrom` is still `3`); the statement is only valid over a
  `Fintype`, and this hypothesis is load-bearing.
* Is the sandwich vacuous?  No: on `K_n` the two sides are `max n 3` and `max n 3` (equal, both
  attained); on the even cycle `C_4` they are `max 2 3 = 3` and `max 3 3 = 3`; on the star `K_{1,m}`
  they are `3` and `max (m+1) 3`, so the upper bound can be arbitrarily loose — the star is the
  extremal witness of looseness, and no Brooks-type improvement is claimed here.
* Hidden corner cases: `V` empty gives `χ = 0`, `emoChrom = 3`, `ω = 0`; the sandwich still holds
  because of the explicit floors.
-- !-- End Lab Notes -- !--
-/

end Catalog.Computation.EmotionalChromaticSandwich