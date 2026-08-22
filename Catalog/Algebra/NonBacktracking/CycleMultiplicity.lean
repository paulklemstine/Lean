import Algebra.NonBacktracking.Girth
import Algebra.NonBacktracking.ReversalParity

/-!
# Every cycle contributes `2 · length` closed non-backtracking walks

A cycle of length `m` can be traversed starting at any of its `m` darts and in either of
the two directions, and all `2m` resulting cyclic dart words are different. Hence

`2 * m ≤ trace (B ^ m)`,

which sharpens `Hashimoto.one_le_trace_of_isCycle` and, at `m = girth G`, gives
`2 * girth G ≤ trace (B ^ girth G)`.

## Main results

* `Hashimoto.nbCycles_rotate` — the set of cyclic non-backtracking dart words is stable
  under rotation;
* `Hashimoto.nbCycles_revCycle` — and under reversal `c ↦ (c.map Dart.symm).reverse`;
* `Hashimoto.darts_mem_nbCycles_of_isCycle` — the dart list of a cycle is such a word;
* `Hashimoto.two_mul_length_le_trace_of_isCycle` — the `2m` bound;
* `Hashimoto.two_mul_girth_le_trace_hashimoto_pow_girth` — its girth form.
-/

open Finset SimpleGraph List

namespace Hashimoto

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V} [DecidableRel G.Adj]

/-! ## List lemmas -/

section ListLemmas

variable {α β : Type*}

/-- `Forall₂` is compatible with concatenation. -/
lemma forall₂_append {R : α → β → Prop} {l₁ l₃ : List α} {l₂ l₄ : List β}
    (h : Forall₂ R l₁ l₂) (h' : Forall₂ R l₃ l₄) : Forall₂ R (l₁ ++ l₃) (l₂ ++ l₄) := by
  induction h with
  | nil => simpa using h'
  | cons hab _ ih => exact List.Forall₂.cons hab ih

/-- `Forall₂` survives a simultaneous rotation by one. -/
lemma forall₂_rotate_one {R : α → β → Prop} {l₁ : List α} {l₂ : List β} (h : Forall₂ R l₁ l₂) :
    Forall₂ R (l₁.rotate 1) (l₂.rotate 1) := by
  cases h with
  | nil => simp
  | cons hab ht =>
      simpa [List.rotate_cons_succ] using
        forall₂_append ht (List.Forall₂.cons hab List.Forall₂.nil)

/-- `Forall₂` survives a simultaneous rotation. -/
lemma forall₂_rotate {R : α → β → Prop} {l₁ : List α} {l₂ : List β} (h : Forall₂ R l₁ l₂)
    (i : ℕ) : Forall₂ R (l₁.rotate i) (l₂.rotate i) := by
  induction i with
  | zero => simpa using h
  | succ k ih =>
      have h1 := forall₂_rotate_one ih
      rwa [List.rotate_rotate, List.rotate_rotate] at h1

/-- The head of a rotated list. -/
lemma getElem_zero_rotate {l : List α} {i : ℕ} (hi : i < l.length)
    (h : 0 < (l.rotate i).length) : (l.rotate i)[0] = l[i] := by
  have h1 := List.getElem_rotate l i 0 h
  simpa [Nat.mod_eq_of_lt hi] using h1

/-- Distinct rotations of a list without repetitions are distinct. -/
lemma rotate_injOn_of_nodup {l : List α} (hnd : l.Nodup) {i j : ℕ} (hi : i < l.length)
    (hj : j < l.length) (h : l.rotate i = l.rotate j) : i = j := by
  have hlen : 0 < (l.rotate i).length := by
    rw [List.length_rotate]; omega
  have hlen' : 0 < (l.rotate j).length := by
    rw [List.length_rotate]; omega
  have h1 : (l.rotate i)[0] = l[i] := getElem_zero_rotate hi hlen
  have h2 : (l.rotate j)[0] = l[j] := getElem_zero_rotate hj hlen'
  have h3 : l[i] = l[j] := by rw [← h1, ← h2]; congr 1
  exact hnd.getElem_inj_iff.1 h3

end ListLemmas

/-! ## Rotation and reversal of cyclic dart words -/

/-- **Rotation invariance.** Rotating a cyclically non-backtracking dart word gives another
one: the same closed walk read from a different root. -/
theorem nbCycles_rotate {n : ℕ} (hn : 1 ≤ n) {c : List G.Dart} (hc : c ∈ nbCycles G n)
    (i : ℕ) : c.rotate i ∈ nbCycles G n := by
  rw [mem_nbCycles_iff_forall₂ G hn] at hc ⊢
  refine ⟨by rw [List.length_rotate]; exact hc.1, ?_⟩
  have h1 := forall₂_rotate hc.2 i
  rwa [List.rotate_rotate, Nat.add_comm 1 i, ← List.rotate_rotate] at h1

variable (G) in
/-- Reversal of a cyclic dart word: reverse the order and flip every dart. -/
def revCycle (c : List G.Dart) : List G.Dart := (c.map SimpleGraph.Dart.symm).reverse

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
@[simp] lemma length_revCycle (c : List G.Dart) : (revCycle G c).length = c.length := by
  simp [revCycle]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
lemma mem_revCycle_iff {c : List G.Dart} {d : G.Dart} :
    d ∈ revCycle G c ↔ d.symm ∈ c := by
  constructor
  · intro h
    simp only [revCycle, List.mem_reverse, List.mem_map] at h
    obtain ⟨e, he, rfl⟩ := h
    rwa [SimpleGraph.Dart.symm_symm]
  · intro h
    simp only [revCycle, List.mem_reverse, List.mem_map]
    exact ⟨d.symm, h, SimpleGraph.Dart.symm_symm d⟩

/-- **Reversal invariance.** Reversing a cyclically non-backtracking dart word gives
another one: the same closed walk traversed backwards. -/
theorem nbCycles_revCycle {n : ℕ} (hn : 1 ≤ n) {c : List G.Dart} (hc : c ∈ nbCycles G n) :
    revCycle G c ∈ nbCycles G n := by
  rw [mem_nbCycles hn] at hc ⊢
  obtain ⟨hlen, hchain, hseam⟩ := hc
  refine ⟨by rw [length_revCycle]; exact hlen, ?_, ?_⟩
  · rw [revCycle, List.isChain_reverse, List.isChain_map]
    exact hchain.imp fun a b hab => nbAdj_symm_symm.2 hab
  · intro x hx y hy
    rw [revCycle, List.getLast?_reverse, List.head?_map] at hx
    rw [revCycle, List.head?_reverse, List.getLast?_map] at hy
    obtain ⟨d₀, hd₀, rfl⟩ : ∃ d, c.head? = some d ∧ d.symm = x := by
      rcases hh : c.head? with _ | d
      · rw [hh] at hx; simp at hx
      · rw [hh] at hx; exact ⟨d, rfl, by simpa using hx⟩
    obtain ⟨dl, hdl, rfl⟩ : ∃ d, c.getLast? = some d ∧ d.symm = y := by
      rcases hh : c.getLast? with _ | d
      · rw [hh] at hy; simp at hy
      · rw [hh] at hy; exact ⟨d, rfl, by simpa using hy⟩
    exact nbAdj_symm_symm.2 (hseam dl hdl d₀ hd₀)

/-! ## The dart word of a cycle -/

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- The first dart of a walk starts at its source. -/
lemma head_darts_fst {u v : V} (p : G.Walk u v) (h : p.darts ≠ []) :
    (p.darts.head h).toProd.1 = u := by
  cases p with
  | nil => simp at h
  | cons hadj q => simp

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- The last dart of a walk ends at its target. -/
lemma getLast_darts_snd {u v : V} (p : G.Walk u v) (h : p.darts ≠ []) :
    (p.darts.getLast h).toProd.2 = v := by
  induction p with
  | nil => simp at h
  | @cons a b c hadj q ih =>
      cases q with
      | nil => simp
      | cons hadj' q' =>
          have hne : (SimpleGraph.Walk.cons hadj' q').darts ≠ [] := by simp
          rw [show (SimpleGraph.Walk.cons hadj (SimpleGraph.Walk.cons hadj' q')).darts.getLast h
              = (SimpleGraph.Walk.cons hadj' q').darts.getLast hne from List.getLast_cons hne]
          exact ih hne

/-- **The dart list of a cycle is a cyclic non-backtracking word.** -/
theorem darts_mem_nbCycles_of_isCycle {v : V} (p : G.Walk v v) (hp : p.IsCycle) :
    p.darts ∈ nbCycles G p.length := by
  have h3 : 3 ≤ p.length := hp.three_le_length
  have hlen : p.darts.length = p.length := p.length_darts
  have hedges : (p.darts.map SimpleGraph.Dart.edge).Nodup := hp.isTrail.edges_nodup
  have hne : p.darts ≠ [] := by
    intro h
    rw [h] at hlen
    simp at hlen
    omega
  rw [mem_nbCycles (by omega)]
  refine ⟨hlen, ?_, ?_⟩
  · -- consecutive darts are composable and do not backtrack
    rw [List.isChain_iff_getElem]
    intro i hi
    have hcomp : p.darts[i].toProd.2 = p.darts[i + 1].toProd.1 :=
      (List.isChain_iff_getElem.1 p.isChain_dartAdj_darts) i hi
    refine ⟨hcomp, ?_⟩
    intro hback
    have hedge : p.darts[i].edge = p.darts[i + 1].edge := by
      show Sym2.mk (p.darts[i].toProd.1, p.darts[i].toProd.2) =
        Sym2.mk (p.darts[i + 1].toProd.1, p.darts[i + 1].toProd.2)
      rw [hcomp, hback]
      exact Sym2.eq_swap
    have hmap : (p.darts.map SimpleGraph.Dart.edge)[i]'(by simpa using by omega) =
        (p.darts.map SimpleGraph.Dart.edge)[i + 1]'(by simpa using hi) := by
      simpa using hedge
    have := hedges.getElem_inj_iff.1 hmap
    omega
  · -- the seam
    intro x hx y hy
    have hxl : x = p.darts.getLast hne := by
      rw [List.getLast?_eq_some_getLast hne] at hx
      simpa using hx.symm
    have hyh : y = p.darts.head hne := by
      rw [List.head?_eq_some_head hne] at hy
      simpa using hy.symm
    subst hxl
    subst hyh
    have hxs : (p.darts.getLast hne).toProd.2 = v := getLast_darts_snd p hne
    have hyf : (p.darts.head hne).toProd.1 = v := head_darts_fst p hne
    refine ⟨by rw [hxs, hyf], ?_⟩
    intro hback
    -- otherwise the first and last edges coincide, contradicting nodup edges
    have hedge : (p.darts.head hne).edge = (p.darts.getLast hne).edge := by
      show Sym2.mk ((p.darts.head hne).toProd.1, (p.darts.head hne).toProd.2) =
        Sym2.mk ((p.darts.getLast hne).toProd.1, (p.darts.getLast hne).toProd.2)
      rw [hyf, hback, hxs]
      exact Sym2.eq_swap
    have hhead : p.darts.head hne = p.darts[0]'(by rw [hlen]; omega) := by
      rw [List.head_eq_getElem]
    have hlast : p.darts.getLast hne =
        p.darts[p.darts.length - 1]'(by rw [hlen]; omega) := by
      rw [List.getLast_eq_getElem]
    rw [hhead, hlast] at hedge
    have hmap : (p.darts.map SimpleGraph.Dart.edge)[0]'(by simp [hlen]; omega) =
        (p.darts.map SimpleGraph.Dart.edge)[p.darts.length - 1]'(by simp [hlen]; omega) := by
      simpa using hedge
    have := hedges.getElem_inj_iff.1 hmap
    omega

/-! ## The `2m` lower bound -/

/-- **Each cycle contributes `2 · length` rooted closed non-backtracking walks.** A cycle of
length `m` can be rooted at any of its `m` darts and traversed in either direction, and the
`2m` resulting cyclic dart words are pairwise distinct. -/
theorem two_mul_length_le_trace_of_isCycle {v : V} (p : G.Walk v v) (hp : p.IsCycle) :
    2 * p.length ≤ (hashimoto G ^ p.length).trace := by
  classical
  have h3 : 3 ≤ p.length := hp.three_le_length
  set m := p.length with hm
  set cw := p.darts with hc
  have hclen : cw.length = m := p.length_darts
  have hedges : (cw.map SimpleGraph.Dart.edge).Nodup := hp.isTrail.edges_nodup
  have hcnd : cw.Nodup := hedges.of_map _
  have hrnd : (revCycle G cw).Nodup := by
    rw [revCycle, List.nodup_reverse]
    exact hcnd.map fun a b hab => by
      simpa using congrArg SimpleGraph.Dart.symm hab
  have hrlen : (revCycle G cw).length = m := by rw [length_revCycle, hclen]
  have hmemc : cw ∈ nbCycles G m := darts_mem_nbCycles_of_isCycle p hp
  have hmemr : revCycle G cw ∈ nbCycles G m := nbCycles_revCycle (by omega) hmemc
  -- the two families of rotations
  have hdisj_elem : ∀ d ∈ cw, d ∉ revCycle G cw := by
    intro d hd hmem
    rw [mem_revCycle_iff] at hmem
    have hne : d ≠ d.symm := by
      intro h
      have := d.adj.ne
      rw [SimpleGraph.Dart.ext_iff, Prod.ext_iff] at h
      exact this h.1
    exact hne (List.inj_on_of_nodup_map hedges hd hmem (SimpleGraph.Dart.edge_symm d).symm)
  set S₁ : Finset (List G.Dart) := (Finset.range m).image (fun i => cw.rotate i) with hS₁
  set S₂ : Finset (List G.Dart) := (Finset.range m).image (fun i => (revCycle G cw).rotate i)
    with hS₂
  have hS₁card : S₁.card = m := by
    rw [hS₁, Finset.card_image_of_injOn, Finset.card_range]
    intro i hi j hj hij
    exact rotate_injOn_of_nodup hcnd (by rw [hclen]; simpa using hi)
      (by rw [hclen]; simpa using hj) hij
  have hS₂card : S₂.card = m := by
    rw [hS₂, Finset.card_image_of_injOn, Finset.card_range]
    intro i hi j hj hij
    exact rotate_injOn_of_nodup hrnd (by rw [hrlen]; simpa using hi)
      (by rw [hrlen]; simpa using hj) hij
  have hdisj : Disjoint S₁ S₂ := by
    rw [Finset.disjoint_left]
    intro l hl₁ hl₂
    rw [hS₁, Finset.mem_image] at hl₁
    rw [hS₂, Finset.mem_image] at hl₂
    obtain ⟨i, hi, rfl⟩ := hl₁
    obtain ⟨j, hj, hji⟩ := hl₂
    rw [Finset.mem_range] at hi hj
    have hi' : i < cw.length := by rw [hclen]; exact hi
    have hj' : j < (revCycle G cw).length := by rw [hrlen]; exact hj
    have hpos : 0 < (cw.rotate i).length := by rw [List.length_rotate, hclen]; omega
    have hpos' : 0 < ((revCycle G cw).rotate j).length := by
      rw [List.length_rotate, hrlen]; omega
    have h1 : (cw.rotate i)[0] = cw[i] := getElem_zero_rotate hi' hpos
    have h2 : ((revCycle G cw).rotate j)[0] = (revCycle G cw)[j] := getElem_zero_rotate hj' hpos'
    have h3' : (revCycle G cw)[j] = cw[i] := by
      rw [← h1, ← h2]
      simp only [hji]
    exact hdisj_elem cw[i] (List.getElem_mem hi') (h3' ▸ List.getElem_mem hj')
  have hsub : S₁ ∪ S₂ ⊆ nbCycles G m := by
    intro l hl
    rw [Finset.mem_union] at hl
    rcases hl with hl | hl
    · rw [hS₁, Finset.mem_image] at hl
      obtain ⟨i, _, rfl⟩ := hl
      exact nbCycles_rotate (by omega) hmemc i
    · rw [hS₂, Finset.mem_image] at hl
      obtain ⟨i, _, rfl⟩ := hl
      exact nbCycles_rotate (by omega) hmemr i
  have hcard : (S₁ ∪ S₂).card = 2 * m := by
    rw [Finset.card_union_of_disjoint hdisj, hS₁card, hS₂card]
    omega
  calc 2 * m = (S₁ ∪ S₂).card := hcard.symm
    _ ≤ (nbCycles G m).card := Finset.card_le_card hsub
    _ = (hashimoto G ^ m).trace := (trace_hashimoto_pow_eq_card_nbCycles G (by omega)).symm

/-- **Girth form.** A graph with a cycle satisfies `2 · girth ≤ trace (B ^ girth)`. -/
theorem two_mul_girth_le_trace_hashimoto_pow_girth (hG : ¬ G.IsAcyclic) :
    2 * G.girth ≤ (hashimoto G ^ G.girth).trace := by
  obtain ⟨a, q, hq, hlen⟩ := exists_girth_eq_length.2 hG
  rw [hlen]
  exact two_mul_length_le_trace_of_isCycle q hq

end Hashimoto