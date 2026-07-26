/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Necessary-threshold cubic upper bound for ex(n, K_{a,b}, K_{3,t})

This file formalizes the *upper* half of the generalized Turán statement
`ex(n, K_{a,b}, K_{3,t}) = Θ(n^3)`:

For every `K_{3,t}`-free graph `G` on a finite vertex set, the number of copies of the
complete bipartite graph `K_{a,b}` (with `3 ≤ a` and `3 ≤ b`) is at most
`C(n,3) · C(t-1, b) · C(t-1, a-3)`, hence `O(n^3)`.

The argument is a Kővári–Sós–Turán-style double count anchored on a 3-element "core":
every copy of `K_{a,b}` contains a copy of the `3`-side of `K_{3,t}` inside its `a`-side, and
`K_{3,t}`-freeness caps every triple's common neighborhood at `t-1`.  This is the elementary
direction that holds *uniformly at the conjectured necessary threshold* `t = b+1`, for every
parity of `b` (the parity subtlety in the literature lives entirely in the matching cubic
*lower-bound* construction).

## Catalog connections
* `Alon-Shikhelman generalized Turán numbers`: `KabCopies` is exactly the counting object whose
  maximum over `K_{3,t}`-free graphs is `ex(n, K_{a,b}, K_{3,t})`.
* `Kővári-Sós-Turán theorem`: `cnbhd_card_le` is the common-neighborhood cap that powers the
  classical KST counting argument, here lifted from edges to `K_{a,b}`-copies.
* `Janzer-Longbrake-Yepremyan theorem for ex(n,K_{a,b},K_{3,t})`: `KabCopies_cubic_of_K3tFree`
  is the `O(n^3)` upper bound matching their `Θ(n^3)` result.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): For `K_{3,t}`-free `G`, the number of `K_{a,b}` copies is `O(n^3)`,
  and crucially the *upper* bound needs only `t ≥ b+1` regardless of the parity of `b`.
Experiment (Experimenter): Formalized copies as disjoint complete-bipartite pairs `(A,B)`.
  Built a double count: anchor on a triple `S ⊆ A`; `K_{3,t}`-freeness gives `|N(S)| ≤ t-1`
  (so `B` lives in a set of size `≤ t-1`), and `|N(B)| ≤ t-1` (so `A \ S` lives in a set of
  size `≤ t-1`).  The map `(A,B) ↦ (A\S, B)` is injective on the `S`-fiber.
Analysis (Analyst): The "3" in `n^3` is forced — it is exactly the `3` of `K_{3,t}` — while the
  remaining `a+b-3` vertices are each pinned into a bounded common neighborhood.  The hypotheses
  `3 ≤ a` (to extract a triple from `A`) and `3 ≤ b` (to cap `N(B)`) are the genuine load.
Critique (Critic): `t ≥ b+1` is *not* used by the bound itself (`C(t-1,b)` simply vanishes when
  `b > t-1`); it is the threshold at which the matching lower bound becomes possible, so we keep
  it only in the headline `KabCopies_cubic_of_K3tFree`.  No theorem is vacuous: the count is a
  genuine `Finset.card`, and `K3tFree_iff_CNbound` ties the abstract cap to the honest
  subgraph-freeness definition.
Synthesis (PI): A clean, parity-uniform `O(n^3)` upper bound at the necessary threshold.
-/
import Mathlib

open Finset

namespace GenTuranK3t

variable {V : Type*} [Fintype V] [DecidableEq V]

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
contains `S` are at most `C(t-1, b) · C(t-1, a-3)` in number.  The proof injects such a copy
`(A, B)` to the pair `(A \ S, B)`, where `B` ranges over the (size `≤ t-1`) common
neighborhood of `S` and `A \ S` over the (size `≤ t-1`) common neighborhood of `B`. -/
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
sum, over all triples `S`, the copies whose `a`-side contains `S` — because each `a`-side has
`C(a,3) ≥ 1` triples. -/
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

/-- **Cubic upper bound, stated for `K_{3,t}`-free graphs at the necessary threshold.**
If `G` is `K_{3,t}`-free with `t ≥ b + 1` (the conjectured necessary threshold), then the
number of copies of `K_{a,b}` is `O(n^3)`: it is bounded by `C · n^3` with
`C = C(t-1,b) · C(t-1,a-3)` depending only on `a, b, t`. -/
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

end GenTuranK3t