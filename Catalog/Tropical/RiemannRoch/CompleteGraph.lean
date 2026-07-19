/-
Copyright (c) 2026. Released under Apache 2.0 license.

# Complete graphs in Baker–Norine divisor theory

For the complete graph `Kₙ`, this file computes the vertex degrees, canonical
 divisor, total degree, and genus.  It also isolates the exact logical role of
Riemann–Roch in the canonical-rank calculation.

The canonical divisor uses the standard convention `K(v) = val(v) - 2`.
Consequently `K_{Kₙ}(v) = n - 3`, rather than `n - 2`.  Moreover, the
Baker–Norine rank `r(D)` and the dimension `ℓ(D) = r(D) + 1` are different
normalizations.  With the rank convention of `Tropical.RiemannRoch.Rank`, one
has `r(0) = 0` and Riemann–Roch predicts `r(K) = g - 1`.

## Main results

* `rank_zero` computes the rank of the zero divisor on every nonempty graph.
* `completeGraph_canonical_apply` computes `K_{Kₙ}(v) = n - 3`.
* `completeGraph_genus` computes `g(Kₙ) = (n-1)(n-2)/2`.
* `canonical_rank_of_riemannRoch` derives `r(K)=g-1` without confusing rank
  with dimension.
* `completeGraph_three_data` through `completeGraph_six_data` give the requested
  small cases, conditional only in their rank component on the full
  Riemann–Roch identity.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): (1) complete-graph firing is controlled by the
root lattice of type A; (2) the critical group of `Kₙ` has order `n^(n-2)`;
(3) sorted reduced divisors are parking functions; (4) their rank statistic is
complemented by the canonical involution; (5) this involution yields
Riemann–Roch; (6) the canonical rank is `g-1`; and (7) the same parking-function
model links chip-firing to spanning trees and the permutohedral fan.  The last
five claims form the high-impact structural hierarchy, while (6) is its first
numerical consequence.

Experiment (Experimenter): direct calculation gives valency `n-1`, hence the
standard canonical coefficient `n-3`, total canonical degree `n(n-3)`, and
genus `(n-1)(n-2)/2`.  The cases `n=3,4,5,6` therefore have `(g,K(v),deg K,
r(K)) = (1,0,0,0), (3,1,4,2), (6,2,10,5), (10,3,18,9)`, where the last entry
uses Riemann–Roch.

Analysis (Analyst): the apparent contradiction in the motivating calculation
comes from two independent normalization slips.  First, the graph canonical
divisor is `sum_v (deg(v)-2)v`, not `sum_v (deg(v)-1)v`.  Second, the displayed
Riemann–Roch equation is the rank equation for `r`, although the symbol `ℓ`
often denotes `r+1`.  Substituting `D=K` correctly gives
`r(K)-r(0)=deg(K)+1-g=(2g-2)+1-g=g-1`; since `r(0)=0`, this is `r(K)=g-1`.

Critique (Critic): the structural formulas below do not pretend to prove the
full Baker–Norine theorem.  The canonical-rank theorem explicitly takes the
Riemann–Roch identity as a hypothesis, preventing circularity.  The zero-rank
calculation is unconditional and its upper bound is witnessed by a one-chip
effective divisor.  Empty complete graphs are excluded exactly where a vertex
or the rank of zero requires one.

Synthesis (Principal Investigator): the corrected convention removes the
contradiction, the numerical layer is unconditional, and the remaining deep
step is cleanly exposed as the parking-function form of Riemann–Roch.
-- !-- Lab Notes -- !--
-/

import Tropical.RiemannRoch.Rank

open Finset BigOperators

namespace BakerNorine

variable {G : FinGraph}

/-
The zero divisor is effective.
-/
lemma zero_linEquivEffective : LinEquivEffective (0 : Divisor G) := by
  use 0;
  exact ⟨ fun _ => by norm_num, linEquiv_refl _ ⟩

/-
On a nonempty graph, the Baker–Norine rank of the zero divisor is zero.
-/
theorem rank_zero [Nonempty G.V] : rank (0 : Divisor G) = 0 := by
  by_contra h_neq;
  obtain ⟨n, hn⟩ : ∃ n : ℕ, n > 0 ∧ SatisfiesRank (0 : Divisor G) n := by
    unfold rank at h_neq;
    split_ifs at h_neq;
    · simp +zetaDelta at *;
      obtain ⟨ n, hn ⟩ := exists_lt_of_lt_csSup ( show { n : ℕ | SatisfiesRank 0 n }.Nonempty from Set.nonempty_iff_ne_empty.mpr <| by aesop_cat ) <| Nat.pos_of_ne_zero h_neq; use n; aesop;
    · exact False.elim <| ‹¬LinEquivEffective 0› <| zero_linEquivEffective;
  obtain ⟨F, hF⟩ : ∃ F : Divisor G, Effective F ∧ deg F = n := by
    exact exists_effective_deg n;
  have := hn.2 F hF.1 hF.2; obtain ⟨ F', hF', hF'' ⟩ := this; have := LinEquivEffective.deg_nonneg ⟨ F', hF', hF'' ⟩ ; simp_all +decide ;
  unfold subDiv at this; simp_all +decide [ deg ] ;

/-- The loopless complete graph on `n` labelled vertices. -/
def completeGraph (n : ℕ) : FinGraph where
  V := Fin n
  adj := fun v w => if v = w then 0 else 1
  adj_symm := by
    intro v w
    rcases eq_or_ne v w with h | h
    · simp [h]
    · simp [h, h.symm]
  adj_loopless := by intro v; simp

/-
Every vertex of `Kₙ` has valency `n-1`.
-/
theorem completeGraph_vertexDeg {n : ℕ} (hn : 0 < n) (v : (completeGraph n).V) :
    vertexDeg (completeGraph n) v = (n : ℤ) - 1 := by
  unfold vertexDeg;
  unfold completeGraph;
  simp +decide [ Finset.sum_ite, Finset.filter_ne ];
  rw [ Nat.cast_pred hn ]

/-
The standard canonical divisor of `Kₙ` has coefficient `n-3` at each vertex.
-/
theorem completeGraph_canonical_apply {n : ℕ} (hn : 0 < n)
    (v : (completeGraph n).V) :
    canonical (completeGraph n) v = (n : ℤ) - 3 := by
  convert congr_arg ( fun x : ℤ => x - 2 ) ( completeGraph_vertexDeg hn v ) using 1 ; ring

/-
The sum of all vertex valencies of `Kₙ` is `n(n-1)`.
-/
theorem completeGraph_totalEdges {n : ℕ} (hn : 0 < n) :
    totalEdges (completeGraph n) = (n : ℤ) * ((n : ℤ) - 1) := by
  unfold totalEdges; simp +decide [completeGraph_vertexDeg hn]; ring;
  erw [ Fintype.card_fin ] ; ring

/-
The genus (cyclomatic number) of `Kₙ` is `(n-1)(n-2)/2`.
-/
theorem completeGraph_genus {n : ℕ} (hn : 0 < n) :
    genus (completeGraph n) = ((n : ℤ) - 1) * ((n : ℤ) - 2) / 2 := by
  unfold genus;
  convert congr_arg ( fun x : ℤ => x / 2 - n + 1 ) ( completeGraph_totalEdges hn ) using 1 ; ring;
  · congr;
    convert Fintype.card_fin n;
  · grind

/-
The canonical degree of `Kₙ` is `n(n-3) = 2g-2`.
-/
theorem completeGraph_canonical_degree {n : ℕ} (hn : 0 < n) :
    deg (canonical (completeGraph n)) = (n : ℤ) * ((n : ℤ) - 3) := by
  unfold deg canonical; simp +decide [completeGraph_vertexDeg hn]; ring;
  erw [ Fintype.card_fin ] ; ring

/-- The Baker–Norine Riemann–Roch identity, packaged as a graph property. -/
def RiemannRochProperty (G : FinGraph) : Prop :=
  ∀ D : Divisor G,
    rank D - rank (subDiv (canonical G) D) = deg D - genus G + 1

/-
Riemann–Roch implies that the canonical divisor has rank `g-1`.
This argument also records explicitly that `r(0)=0`.
-/
theorem canonical_rank_of_riemannRoch [Nonempty G.V]
    (hRR : RiemannRochProperty G) :
    rank (canonical G) = genus G - 1 := by
  convert hRR ( canonical G ) using 1;
  · rw [ show subDiv ( canonical G ) ( canonical G ) = 0 from funext fun _ => sub_self _, rank_zero ] ; norm_num;
  · rw [ deg_canonical ] ; ring

/-
Specialization of canonical rank to a nonempty complete graph.
-/
theorem completeGraph_canonical_rank {n : ℕ} (hn : 0 < n)
    (hRR : RiemannRochProperty (completeGraph n)) :
    rank (canonical (completeGraph n)) =
      ((n : ℤ) - 1) * ((n : ℤ) - 2) / 2 - 1 := by
  convert canonical_rank_of_riemannRoch hRR using 1;
  · rw [ completeGraph_genus hn ];
  · exact ⟨ ⟨ 0, hn ⟩ ⟩

/-
Requested data for `K₃`: genus 1, canonical coefficient 0, degree 0,
and canonical rank 0 under Riemann–Roch.
-/
theorem completeGraph_three_data (hRR : RiemannRochProperty (completeGraph 3)) :
    genus (completeGraph 3) = 1 ∧
    canonical (completeGraph 3) = (0 : Divisor (completeGraph 3)) ∧
    deg (canonical (completeGraph 3)) = 0 ∧
    rank (canonical (completeGraph 3)) = 0 := by
  refine' ⟨ _, _, _, _ ⟩;
  · rw [completeGraph_genus (by norm_num)]
    norm_num;
  · exact funext fun x => completeGraph_canonical_apply ( by decide ) x ▸ by norm_num;
  · convert completeGraph_canonical_degree ( by decide : 0 < 3 ) using 1;
  · convert completeGraph_canonical_rank ( show 0 < 3 by decide ) hRR using 1

/-
Requested data for `K₄`: genus 3, constant canonical coefficient 1,
degree 4, and canonical rank 2 under Riemann–Roch.
-/
theorem completeGraph_four_data (hRR : RiemannRochProperty (completeGraph 4)) :
    genus (completeGraph 4) = 3 ∧
    canonical (completeGraph 4) = (fun _ => 1) ∧
    deg (canonical (completeGraph 4)) = 4 ∧
    rank (canonical (completeGraph 4)) = 2 := by
  refine' ⟨ _, _, _, _ ⟩;
  · rw [completeGraph_genus (by norm_num)]
    norm_num;
  · exact funext fun x => completeGraph_canonical_apply ( by decide ) x ▸ by norm_num;
  · convert completeGraph_canonical_degree ( by decide : 0 < 4 ) using 1;
  · convert completeGraph_canonical_rank ( show 0 < 4 by decide ) hRR using 1

/-
Requested data for `K₅`: genus 6, constant canonical coefficient 2,
degree 10, and canonical rank 5 under Riemann–Roch.
-/
theorem completeGraph_five_data (hRR : RiemannRochProperty (completeGraph 5)) :
    genus (completeGraph 5) = 6 ∧
    canonical (completeGraph 5) = (fun _ => 2) ∧
    deg (canonical (completeGraph 5)) = 10 ∧
    rank (canonical (completeGraph 5)) = 5 := by
  constructor;
  · rw [completeGraph_genus (by norm_num)]
    norm_num;
  · refine' ⟨ _, _, _ ⟩;
    · exact funext fun x => completeGraph_canonical_apply ( by decide ) x ▸ by norm_num;
    · convert completeGraph_canonical_degree ( by decide : 0 < 5 ) using 1;
    · convert completeGraph_canonical_rank ( show 0 < 5 by decide ) hRR using 1

/-
Requested data for `K₆`: genus 10, constant canonical coefficient 3,
degree 18, and canonical rank 9 under Riemann–Roch.
-/
theorem completeGraph_six_data (hRR : RiemannRochProperty (completeGraph 6)) :
    genus (completeGraph 6) = 10 ∧
    canonical (completeGraph 6) = (fun _ => 3) ∧
    deg (canonical (completeGraph 6)) = 18 ∧
    rank (canonical (completeGraph 6)) = 9 := by
  refine' ⟨ _, _, _, _ ⟩;
  · rw [completeGraph_genus (by norm_num)]
    norm_num;
  · exact funext fun x => completeGraph_canonical_apply ( by decide ) x ▸ by norm_num;
  · convert completeGraph_canonical_degree ( by decide : 0 < 6 ) using 1;
  · convert completeGraph_canonical_rank ( show 0 < 6 by decide ) hRR using 1

end BakerNorine