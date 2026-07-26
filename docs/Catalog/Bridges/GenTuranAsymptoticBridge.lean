/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Bridge: Generalized Turán counting (extremal combinatorics) ↔ Landau asymptotics (analysis)

The generalized Turán problem asks for the maximum number of copies of a fixed graph `H`
inside an `n`-vertex host graph that avoids a forbidden subgraph `F`.  For `H = K_{a,b}` and
`F = K_{3,b+1}` (with `3 ≤ a ≤ b`) the maximum is `Θ(n^3)`; the *upper* half of this statement
is a Kővári–Sós–Turán-style double count, reproduced here self-containedly as
`KabCopies_cubic_of_K3tFree`.

This file is a **connector**: it re-expresses that purely combinatorial cardinality bound as a
statement in the language of *asymptotic analysis*, using Mathlib's `Asymptotics.IsBigO` and
`Filter.Tendsto`.  Concretely, for any sequence `G : ∀ n, SimpleGraph (Fin n)` of
`K_{3,b+1}`-free graphs:

* `genTuran_KabCopies_isBigO` : the count `n ↦ #{copies of K_{a,b} in Gₙ}` is `O(n^3)` in the
  Landau sense (`=O[atTop]`).  The Landau constant is the *combinatorial* constant
  `C(b, a-3)` — the bridge carries the extremal constant into the analytic statement.
* `genTuran_density_tendsto_zero` : the normalized "copy density" `#copies / n^{a+b}` tends to
  `0`.  Since a labelled `K_{a,b}` lives on `a+b ≥ 6` vertices while the count is only cubic,
  the fraction of vertex placements realizing a copy vanishes — a probabilistic/analytic
  reading of the same extremal fact.

The two named results genuinely *consume* the combinatorial theorem `KabCopies_cubic_of_K3tFree`
as a black box, so the file is a faithful bridge rather than a restatement.

## Catalog connections
* `Generalized Turán number` / `Alon–Shikhelman`: `KabCopies` is the counting object.
* `Kővári–Sós–Turán theorem`: `cnbhd_card_le` is the common-neighborhood cap that drives the
  double count.
* `Complete bipartite graphs`: both the counted graph `K_{a,b}` and the forbidden `K_{3,b+1}`.
-/
import Mathlib

open Finset

namespace GenTuranK3t

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## The combinatorial core (self-contained upper bound)

The material in this section reproduces the elementary `O(n^3)` upper bound for
`ex(n, K_{a,b}, K_{3,t})`, so that the asymptotic bridge below is self-contained. -/

/-- Common neighborhood of a finite set `S` of vertices: all vertices adjacent to every vertex
of `S`. -/
def cnbhd (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) : Finset V :=
  univ.filter (fun w => ∀ u ∈ S, G.Adj u w)

@[simp] lemma mem_cnbhd (G : SimpleGraph V) [DecidableRel G.Adj] (S : Finset V) (w : V) :
    w ∈ cnbhd G S ↔ ∀ u ∈ S, G.Adj u w := by
  simp [cnbhd]

/-- The common neighborhood is antitone in the set: adding constraints removes neighbors. -/
lemma cnbhd_antitone (G : SimpleGraph V) [DecidableRel G.Adj] {S T : Finset V} (h : S ⊆ T) :
    cnbhd G T ⊆ cnbhd G S := by
  intro w hw
  simp only [mem_cnbhd] at *
  exact fun u hu => hw u (h hu)

/-- The set of labelled copies of `K_{a,b}` in `G`: pairs `(A, B)` of disjoint vertex sets of
sizes `a` and `b` with every `A`–`B` edge present. -/
def KabCopies (G : SimpleGraph V) [DecidableRel G.Adj] (a b : ℕ) : Finset (Finset V × Finset V) :=
  (univ.powersetCard a ×ˢ univ.powersetCard b).filter
    (fun p => Disjoint p.1 p.2 ∧ ∀ u ∈ p.1, ∀ v ∈ p.2, G.Adj u v)

lemma mem_KabCopies (G : SimpleGraph V) [DecidableRel G.Adj] {a b : ℕ}
    {p : Finset V × Finset V} :
    p ∈ KabCopies G a b ↔
      p.1.card = a ∧ p.2.card = b ∧ Disjoint p.1 p.2 ∧ ∀ u ∈ p.1, ∀ v ∈ p.2, G.Adj u v := by
  simp only [KabCopies, mem_filter, mem_product, mem_powersetCard, subset_univ, true_and]
  tauto

/-- `K_{3,t}`-freeness, stated via the actual bipartite subgraph: there is no pair of disjoint
vertex sets of sizes `3` and `t` with all cross edges present. -/
def K3tFree (G : SimpleGraph V) [DecidableRel G.Adj] (t : ℕ) : Prop :=
  ¬ ∃ A B : Finset V, A.card = 3 ∧ B.card = t ∧ Disjoint A B ∧ ∀ u ∈ A, ∀ v ∈ B, G.Adj u v

/-- The common-neighborhood reformulation: every triple has at most `t-1` common neighbors. -/
def CNbound (G : SimpleGraph V) [DecidableRel G.Adj] (t : ℕ) : Prop :=
  ∀ S : Finset V, S.card = 3 → (cnbhd G S).card ≤ t - 1

/-- Equivalence of the two formulations of `K_{3,t}`-freeness (for `t ≥ 1`). -/
theorem K3tFree_iff_CNbound (G : SimpleGraph V) [DecidableRel G.Adj] {t : ℕ} (ht : 1 ≤ t) :
    K3tFree G t ↔ CNbound G t := by
  constructor
  · intro hfree S hS
    by_contra hcon
    push_neg at hcon
    have ht' : t ≤ (cnbhd G S).card := by omega
    obtain ⟨B, hBsub, hBcard⟩ := Finset.exists_subset_card_eq ht'
    refine hfree ⟨S, B, hS, hBcard, ?_, ?_⟩
    · rw [Finset.disjoint_left]
      intro a haS haB
      exact G.irrefl ((mem_cnbhd G S a).1 (hBsub haB) a haS)
    · intro u hu v hv
      exact (mem_cnbhd G S v).1 (hBsub hv) u hu
  · intro hcn ⟨A, B, hA, hB, _hdisj, hcomp⟩
    have hBsub : B ⊆ cnbhd G A := by
      intro v hv; rw [mem_cnbhd]; intro u hu; exact hcomp u hu v hv
    have h1 : t ≤ (cnbhd G A).card := by rw [← hB]; exact card_le_card hBsub
    have h2 := hcn A hA
    omega

/-- A triple's common neighborhood, and more generally any set of size `≥ 3`, is capped at
`t-1` neighbors under the common-neighborhood bound. -/
lemma cnbhd_card_le (G : SimpleGraph V) [DecidableRel G.Adj] {t : ℕ} (hcn : CNbound G t)
    {B : Finset V} (hB : 3 ≤ B.card) : (cnbhd G B).card ≤ t - 1 := by
  obtain ⟨S, hSB, hScard⟩ := Finset.exists_subset_card_eq hB
  calc (cnbhd G B).card ≤ (cnbhd G S).card := card_le_card (cnbhd_antitone G hSB)
    _ ≤ t - 1 := hcn S hScard

/-- Filtering size-`n` subsets of `univ` by `⊆ T` recovers the size-`n` subsets of `T`. -/
lemma powersetCard_filter_subset (n : ℕ) (T : Finset V) :
    (univ.powersetCard n).filter (fun S => S ⊆ T) = T.powersetCard n := by
  ext S
  simp only [mem_filter, mem_powersetCard, subset_univ, true_and]
  tauto

/-- **Core fiber bound.** For a fixed triple `S`, the copies of `K_{a,b}` whose `a`-side
contains `S` are at most `C(t-1, b) · C(t-1, a-3)` in number. -/
lemma fiber_bound (G : SimpleGraph V) [DecidableRel G.Adj] {a b t : ℕ} (hcn : CNbound G t)
    (hb : 3 ≤ b) {S : Finset V} (hS : S.card = 3) :
    ((KabCopies G a b).filter (fun p => S ⊆ p.1)).card
      ≤ (t - 1).choose b * (t - 1).choose (a - 3) := by
  classical
  set D : Finset (Finset V × Finset V) :=
    (cnbhd G S).powersetCard b |>.biUnion
      (fun B => ((cnbhd G B).powersetCard (a - 3)).image (fun R => (R, B))) with hD
  have hmaps : Set.MapsTo (fun p : Finset V × Finset V => (p.1 \ S, p.2))
      ((KabCopies G a b).filter (fun p => S ⊆ p.1)) D := by
    intro p hp
    simp only [mem_coe, mem_filter, mem_KabCopies] at hp
    obtain ⟨⟨hp1, hp2, _hdisj, hcomp⟩, hSsub⟩ := hp
    show (p.1 \ S, p.2) ∈ D
    rw [hD]
    apply Finset.mem_biUnion.mpr
    refine ⟨p.2, ?_, ?_⟩
    · rw [mem_powersetCard]
      refine ⟨?_, hp2⟩
      intro v hv; rw [mem_cnbhd]; intro u hu; exact hcomp u (hSsub hu) v hv
    · apply Finset.mem_image.mpr
      refine ⟨p.1 \ S, ?_, rfl⟩
      rw [mem_powersetCard]
      refine ⟨?_, ?_⟩
      · intro w hw
        rw [mem_sdiff] at hw
        rw [mem_cnbhd]; intro v hv; exact (hcomp w hw.1 v hv).symm
      · rw [card_sdiff_of_subset hSsub, hp1, hS]
  have hinj : Set.InjOn (fun p : Finset V × Finset V => (p.1 \ S, p.2))
      ((KabCopies G a b).filter (fun p => S ⊆ p.1)) := by
    intro p hp q hq hpq
    simp only [mem_coe, mem_filter] at hp hq
    simp only [Prod.mk.injEq] at hpq
    obtain ⟨hpd, hpq2⟩ := hpq
    have hps : S ⊆ p.1 := hp.2
    have hqs : S ⊆ q.1 := hq.2
    have e1 : p.1 = q.1 := by
      rw [← Finset.sdiff_union_of_subset hps, ← Finset.sdiff_union_of_subset hqs, hpd]
    exact Prod.ext e1 hpq2
  calc ((KabCopies G a b).filter (fun p => S ⊆ p.1)).card
      ≤ D.card := Finset.card_le_card_of_injOn _ hmaps hinj
    _ ≤ ∑ B ∈ (cnbhd G S).powersetCard b,
          (((cnbhd G B).powersetCard (a - 3)).image (fun R => (R, B))).card := by
          rw [hD]; exact Finset.card_biUnion_le
    _ ≤ ∑ B ∈ (cnbhd G S).powersetCard b, ((cnbhd G B).powersetCard (a - 3)).card := by
          apply Finset.sum_le_sum; intro B _; exact Finset.card_image_le
    _ ≤ ∑ B ∈ (cnbhd G S).powersetCard b, (t - 1).choose (a - 3) := by
          apply Finset.sum_le_sum; intro B hB
          rw [mem_powersetCard] at hB
          rw [card_powersetCard]
          exact Nat.choose_le_choose _ (cnbhd_card_le G hcn (by rw [hB.2]; exact hb))
    _ = ((cnbhd G S).powersetCard b).card * (t - 1).choose (a - 3) := by
          rw [Finset.sum_const, smul_eq_mul]
    _ = (cnbhd G S).card.choose b * (t - 1).choose (a - 3) := by rw [card_powersetCard]
    _ ≤ (t - 1).choose b * (t - 1).choose (a - 3) := by
          apply Nat.mul_le_mul_right
          exact Nat.choose_le_choose _ (cnbhd_card_le G hcn (by rw [hS]))

/-- **Double count.** Every copy of `K_{a,b}` (with `3 ≤ a`) is counted at least once when we
sum, over all triples `S`, the copies whose `a`-side contains `S`. -/
lemma KabCopies_card_le_sum (G : SimpleGraph V) [DecidableRel G.Adj] {a b : ℕ} (ha : 3 ≤ a) :
    (KabCopies G a b).card
      ≤ ∑ S ∈ univ.powersetCard 3, ((KabCopies G a b).filter (fun p => S ⊆ p.1)).card := by
  calc (KabCopies G a b).card
      = ∑ _p ∈ KabCopies G a b, 1 := by rw [card_eq_sum_ones]
    _ ≤ ∑ p ∈ KabCopies G a b, p.1.card.choose 3 := by
          apply Finset.sum_le_sum; intro p hp
          rw [mem_KabCopies] at hp
          rw [hp.1]; exact Nat.choose_pos ha
    _ = ∑ p ∈ KabCopies G a b, ((univ.powersetCard 3).filter (· ⊆ p.1)).card := by
          apply Finset.sum_congr rfl; intro p _
          rw [powersetCard_filter_subset, card_powersetCard]
    _ = ∑ p ∈ KabCopies G a b, ∑ S ∈ univ.powersetCard 3, (if S ⊆ p.1 then 1 else 0) := by
          apply Finset.sum_congr rfl; intro p _; rw [Finset.card_filter]
    _ = ∑ S ∈ univ.powersetCard 3, ∑ p ∈ KabCopies G a b, (if S ⊆ p.1 then 1 else 0) :=
          Finset.sum_comm
    _ = ∑ S ∈ univ.powersetCard 3, ((KabCopies G a b).filter (fun p => S ⊆ p.1)).card := by
          apply Finset.sum_congr rfl; intro S _; rw [Finset.card_filter]

/-- **Main upper bound.** In any graph satisfying the common-neighborhood bound (i.e.
`K_{3,t}`-free), the number of copies of `K_{a,b}` with `3 ≤ a` and `3 ≤ b` is at most
`C(n,3) · C(t-1,b) · C(t-1,a-3)`. -/
theorem KabCopies_card_le (G : SimpleGraph V) [DecidableRel G.Adj] {a b t : ℕ}
    (ha : 3 ≤ a) (hb : 3 ≤ b) (hcn : CNbound G t) :
    (KabCopies G a b).card
      ≤ (Fintype.card V).choose 3 * ((t - 1).choose b * (t - 1).choose (a - 3)) := by
  calc (KabCopies G a b).card
      ≤ ∑ S ∈ univ.powersetCard 3, ((KabCopies G a b).filter (fun p => S ⊆ p.1)).card :=
        KabCopies_card_le_sum G ha
    _ ≤ ∑ S ∈ univ.powersetCard 3, (t - 1).choose b * (t - 1).choose (a - 3) := by
        apply Finset.sum_le_sum; intro S hS
        rw [mem_powersetCard] at hS
        exact fiber_bound G hcn hb hS.2
    _ = (univ.powersetCard 3 : Finset (Finset V)).card
          * ((t - 1).choose b * (t - 1).choose (a - 3)) := by
        rw [Finset.sum_const, smul_eq_mul]
    _ = (Fintype.card V).choose 3 * ((t - 1).choose b * (t - 1).choose (a - 3)) := by
        rw [card_powersetCard, card_univ]

/-- **Cubic upper bound for `K_{3,t}`-free graphs at the necessary threshold.**
If `G` is `K_{3,t}`-free with `t ≥ b + 1`, then the number of copies of `K_{a,b}` is `O(n^3)`. -/
theorem KabCopies_cubic_of_K3tFree (G : SimpleGraph V) [DecidableRel G.Adj] {a b t : ℕ}
    (ha : 3 ≤ a) (hb : 3 ≤ b) (hbt : b + 1 ≤ t) (hfree : K3tFree G t) :
    (KabCopies G a b).card
      ≤ ((t - 1).choose b * (t - 1).choose (a - 3)) * (Fintype.card V) ^ 3 := by
  have hcn : CNbound G t := (K3tFree_iff_CNbound G (by omega)).1 hfree
  calc (KabCopies G a b).card
      ≤ (Fintype.card V).choose 3 * ((t - 1).choose b * (t - 1).choose (a - 3)) :=
        KabCopies_card_le G ha hb hcn
    _ ≤ (Fintype.card V) ^ 3 * ((t - 1).choose b * (t - 1).choose (a - 3)) := by
        apply Nat.mul_le_mul_right; exact Nat.choose_le_pow (Fintype.card V) 3
    _ = ((t - 1).choose b * (t - 1).choose (a - 3)) * (Fintype.card V) ^ 3 := by ring

/-! ## The bridge to asymptotic analysis

We now carry the combinatorial cubic bound into the language of Landau `O`-notation and limits,
for arbitrary sequences of `K_{3,b+1}`-free graphs. -/

open Filter Asymptotics

/-- **Bridge (combinatorics ↔ Landau asymptotics).** For fixed `3 ≤ a` and `3 ≤ b`, and any
sequence `G n` of `K_{3,b+1}`-free graphs on `Fin n`, the number of copies of `K_{a,b}` in `G n`
is `O(n^3)` in the sense of `Asymptotics.IsBigO`.  The Landau constant is the combinatorial
constant `C(b, a-3)` coming from the extremal double count. -/
theorem genTuran_KabCopies_isBigO {a b : ℕ} (ha : 3 ≤ a) (hb : 3 ≤ b)
    (G : ∀ n, SimpleGraph (Fin n)) [hG : ∀ n, DecidableRel (G n).Adj]
    (hfree : ∀ n, K3tFree (G n) (b + 1)) :
    (fun n : ℕ => ((KabCopies (G n) a b).card : ℝ))
      =O[atTop] (fun n : ℕ => (n : ℝ) ^ 3) := by
  refine Asymptotics.IsBigO.of_bound (b.choose (a - 3) : ℝ) ?_
  filter_upwards with n
  have hbound := KabCopies_cubic_of_K3tFree (G n) ha hb (le_refl (b + 1)) (hfree n)
  simp only [Nat.add_sub_cancel, Nat.choose_self, one_mul, Fintype.card_fin] at hbound
  have hcast : ((KabCopies (G n) a b).card : ℝ) ≤ (b.choose (a - 3) : ℝ) * (n : ℝ) ^ 3 := by
    have := (Nat.cast_le (α := ℝ)).2 hbound
    push_cast at this ⊢
    linarith [this]
  rw [Real.norm_natCast, Real.norm_eq_abs, abs_of_nonneg (by positivity)]
  exact hcast

/-- **Bridge corollary (combinatorics ↔ vanishing density).** A labelled copy of `K_{a,b}`
occupies `a + b ≥ 6` vertices, but under `K_{3,b+1}`-freeness the number of copies is only cubic.
Hence the normalized "copy density" `#copies / n^{a+b}` tends to `0`: asymptotically, almost no
placement of `a + b` vertices realizes a copy. -/
theorem genTuran_density_tendsto_zero {a b : ℕ} (ha : 3 ≤ a) (hb : 3 ≤ b)
    (G : ∀ n, SimpleGraph (Fin n)) [hG : ∀ n, DecidableRel (G n).Adj]
    (hfree : ∀ n, K3tFree (G n) (b + 1)) :
    Tendsto (fun n : ℕ => ((KabCopies (G n) a b).card : ℝ) / (n : ℝ) ^ (a + b))
      atTop (nhds 0) := by
  -- By the combinatorial bound, we have that $(KabCopies (G n) a b).card \leq C \cdot n^3$ for some constant $C$.
  obtain ⟨C, hC⟩ : ∃ C : ℝ, ∀ n, ((KabCopies (G n) a b).card : ℝ) ≤ C * (n : ℝ) ^ 3 := by
    use ( b.choose ( a - 3 ) : ℝ );
    intro n;
    convert KabCopies_cubic_of_K3tFree ( G n ) ha hb ( Nat.le_refl ( b + 1 ) ) ( hfree n ) using 1 ; norm_cast ; simp +decide [ mul_comm ];
  refine' squeeze_zero_norm' _ _;
  use fun n => C * ( n : ℝ ) ^ 3 / ( n : ℝ ) ^ ( a + b );
  · filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn using by rw [ Real.norm_of_nonneg ( by positivity ) ] ; gcongr ; aesop;
  · -- Simplify the expression inside the limit.
    suffices h_simp : Filter.Tendsto (fun n : ℕ => C / (n : ℝ) ^ (a + b - 3)) Filter.atTop (nhds 0) by
      refine h_simp.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with n hn; rw [ show ( n : ℝ ) ^ ( a + b ) = ( n : ℝ ) ^ ( a + b - 3 ) * ( n : ℝ ) ^ 3 by rw [ ← pow_add, Nat.sub_add_cancel ( by linarith ) ] ] ; rw [ mul_div_mul_right _ _ ( by positivity ) ] );
    exact tendsto_const_nhds.div_atTop ( Filter.tendsto_pow_atTop ( Nat.sub_ne_zero_of_lt ( by linarith ) ) |> Filter.Tendsto.comp <| tendsto_natCast_atTop_atTop )

end GenTuranK3t