/-
Copyright (c) 2026. Released under Apache 2.0 license.
-/
import Bridges.VertexSplitting

/-!
# Exact splitting numbers for the smallest obstructions

This file complements `Bridges.VertexSplitting`, where the general theory of the vertex
splitting operation of *Hardness of Vertex Splitting: Cographs, Chordal Graphs, and Beyond*
is developed, with **exact** values of the splitting number for the smallest obstructions of
each of the three target classes studied there.

Main results:

* `isChordal_of_unitIntervalRep`: unit interval graphs are chordal (so the unit-interval
  splitting number always dominates the chordal one).
* `cograph_split_pathP4_exact`: the cograph splitting number of `P₄` is exactly one, and the
  single split can be taken exclusive.
* `chordal_split_cycleC4_exact`: the chordal splitting number of `C₄` is exactly one.
* `unitInterval_split_starK13_exact`: the unit-interval splitting number of the claw `K_{1,3}`
  is exactly one.
* `unitInterval_split_starK14_exact`: the unit-interval splitting number of `K_{1,4}` is also
  exactly one.  In particular the guess that `K_{1,n}` needs `n - 2` splits is false already
  for `n = 4`: pairing the leaves shows `⌈n/2⌉ - 1` splits suffice.
* `card_ge_of_split_clawFree_star` and `unitInterval_split_star_exact`: for every `n ≥ 1` the
  unit-interval splitting number of the star `K_{1,n}` is exactly `⌈n/2⌉ - 1`, by an exclusive
  splitting into `⌈n/2⌉` disjoint short paths, and a matching counting lower bound valid for
  every claw-free target.
-/

namespace VertexSplitting

open SimpleGraph

/-! ## Unit interval graphs are chordal -/

/-- **Unit interval graphs are chordal.**  Along an induced cycle of length at least four,
consider a vertex `c i` whose point `p (c i)` is leftmost.  Its two cycle neighbours lie in
`[p (c i), p (c i) + 1]`, hence within distance one of each other, hence adjacent — contradicting
that the cycle is induced. -/
theorem isChordal_of_unitIntervalRep {W : Type*} {H : SimpleGraph W}
    (h : HasUnitIntervalRep H) : IsChordal H := by
  obtain ⟨p, hp⟩ := h
  rintro ⟨k, hk, c, hinj, hc⟩
  haveI : NeZero k := ⟨by omega⟩
  have hzero : ∀ n : ℕ, 0 < n → n < k → ((n : ℕ) : ZMod k) ≠ 0 := by
    intro n hn hnk hcontra
    rw [ZMod.natCast_eq_zero_iff] at hcontra
    exact absurd (Nat.le_of_dvd hn hcontra) (by omega)
  have h1 : (1 : ZMod k) ≠ 0 := by
    have := hzero 1 (by omega) (by omega); simpa using this
  have h2 : (2 : ZMod k) ≠ 0 := by
    have := hzero 2 (by omega) (by omega); simpa using this
  have h3 : (3 : ZMod k) ≠ 0 := by
    have := hzero 3 (by omega) (by omega); simpa using this
  obtain ⟨i, -, hmin⟩ := Finset.exists_min_image (Finset.univ : Finset (ZMod k))
    (fun i => p (c i)) ⟨0, Finset.mem_univ 0⟩
  have hadj1 : H.Adj (c i) (c (i + 1)) := (hc i (i + 1)).mpr (Or.inl rfl)
  have hadj2 : H.Adj (c i) (c (i - 1)) := (hc i (i - 1)).mpr (Or.inr (by ring))
  have hb1 := ((hp _ _).mp hadj1).2
  have hb2 := ((hp _ _).mp hadj2).2
  rw [abs_le] at hb1 hb2
  have hm1 := hmin (i + 1) (Finset.mem_univ _)
  have hm2 := hmin (i - 1) (Finset.mem_univ _)
  simp only at hm1 hm2
  have hne : c (i - 1) ≠ c (i + 1) := by
    intro hcc
    exact h2 (by linear_combination -hinj hcc)
  have hadj3 : H.Adj (c (i - 1)) (c (i + 1)) :=
    (hp _ _).mpr ⟨hne, abs_le.mpr ⟨by linarith, by linarith⟩⟩
  rcases (hc (i - 1) (i + 1)).mp hadj3 with heq | heq
  · exact h1 (by linear_combination heq)
  · exact h3 (by linear_combination -heq)

/-! ## `P₄`: one split makes a cograph -/

/-- The graph obtained from `P₄ = 0-1-2-3` by splitting the vertex `1` into `1` (keeping the
neighbour `0`) and `4` (keeping the neighbour `2`).  It is the disjoint union of an edge and a
path on three vertices. -/
def splitP4 : SimpleGraph (Fin 5) :=
  SimpleGraph.fromRel (fun i j => (i = 0 ∧ j = 1) ∨ (i = 4 ∧ j = 2) ∨ (i = 2 ∧ j = 3))

instance : DecidableRel splitP4.Adj := fun _ _ => by
  unfold splitP4 SimpleGraph.fromRel
  infer_instance

/-- The origin map of `splitP4`: the new vertex `4` is a copy of `1`. -/
def splitMapP4 : Fin 5 → Fin 4 := ![0, 1, 2, 3, 1]

theorem isSplit_splitP4 : IsSplit pathP4 splitP4 splitMapP4 := by
  constructor <;> decide

theorem isExclusive_splitP4 : IsExclusive splitP4 splitMapP4 := by
  unfold IsExclusive
  decide

theorem isCograph_splitP4 : IsCograph splitP4 := by
  unfold IsCograph HasInducedP4
  decide

/-- **The cograph splitting number of `P₄` is exactly one**: one (exclusive) split suffices, and
no splitting into a cograph can avoid creating a new vertex. -/
theorem cograph_split_pathP4_exact :
    (∃ (H : SimpleGraph (Fin 5)) (f : Fin 5 → Fin 4),
        IsSplit pathP4 H f ∧ IsExclusive H f ∧ IsCograph H) ∧
      ∀ (W : Type) (_ : Fintype W) (H : SimpleGraph W) (f : W → Fin 4),
        IsSplit pathP4 H f → IsCograph H → 4 < Fintype.card W := by
  refine ⟨⟨splitP4, splitMapP4, isSplit_splitP4, isExclusive_splitP4, isCograph_splitP4⟩, ?_⟩
  intro W _ H f hsplit hH
  simpa using card_lt_of_split_cograph hsplit hH not_isCograph_pathP4

/-! ## `C₄`: one split makes a chordal graph -/

/-- The path on five vertices `0-1-2-3-4`. -/
def pathP5 : SimpleGraph (Fin 5) :=
  SimpleGraph.fromRel (fun i j => (i : ℕ) + 1 = (j : ℕ))

instance : DecidableRel pathP5.Adj := fun _ _ => by
  unfold pathP5 SimpleGraph.fromRel
  infer_instance

/-- `P₅` is a unit interval graph: place the `i`-th vertex at `i`. -/
theorem hasUnitIntervalRep_pathP5 : HasUnitIntervalRep pathP5 := by
  refine ⟨fun i => (i : ℕ), ?_⟩
  intro x y
  fin_cases x <;> fin_cases y <;>
    simp [pathP5, SimpleGraph.fromRel, abs_le] <;> norm_num

theorem isChordal_pathP5 : IsChordal pathP5 :=
  isChordal_of_unitIntervalRep hasUnitIntervalRep_pathP5

/-- Splitting the vertex `0` of the four-cycle `0-1-2-3-0` unfolds it into the path
`0-1-2-3-4`, where `4` is the second copy of `0`. -/
def splitMapC4 : Fin 5 → ZMod 4 := ![0, 1, 2, 3, 0]

theorem isSplit_pathP5_cycleC4 : IsSplit cycleC4 pathP5 splitMapC4 := by
  constructor <;> decide

theorem isExclusive_pathP5_cycleC4 : IsExclusive pathP5 splitMapC4 := by
  unfold IsExclusive
  decide

/-- **The chordal splitting number of `C₄` is exactly one**: unfolding the cycle into a path is
an exclusive single split producing a chordal (indeed unit interval) graph, and at least one
split is necessary. -/
theorem chordal_split_cycleC4_exact :
    (∃ (H : SimpleGraph (Fin 5)) (f : Fin 5 → ZMod 4),
        IsSplit cycleC4 H f ∧ IsExclusive H f ∧ IsChordal H ∧ HasUnitIntervalRep H) ∧
      ∀ (W : Type) (_ : Fintype W) (H : SimpleGraph W) (f : W → ZMod 4),
        IsSplit cycleC4 H f → IsChordal H → 4 < Fintype.card W := by
  refine ⟨⟨pathP5, splitMapC4, isSplit_pathP5_cycleC4, isExclusive_pathP5_cycleC4,
    isChordal_pathP5, hasUnitIntervalRep_pathP5⟩, ?_⟩
  intro W _ H f hsplit hH
  simpa using card_lt_of_split_chordal hsplit hH not_isChordal_cycleC4

/-! ## Stars: one split makes `K_{1,3}` and `K_{1,4}` unit interval graphs -/

/-- Splitting the centre of the claw `K_{1,3}` into the vertex `0` (keeping the leaves `1, 2`)
and the vertex `4` (keeping the leaf `3`) gives the disjoint union of `P₃` and an edge. -/
def splitK13 : SimpleGraph (Fin 5) :=
  SimpleGraph.fromRel (fun i j => (i = 0 ∧ (j = 1 ∨ j = 2)) ∨ (i = 4 ∧ j = 3))

instance : DecidableRel splitK13.Adj := fun _ _ => by
  unfold splitK13 SimpleGraph.fromRel
  infer_instance

/-- The origin map of `splitK13`: the new vertex `4` is a second copy of the centre `0`. -/
def splitMapK13 : Fin 5 → Fin 4 := ![0, 1, 2, 3, 0]

theorem isSplit_splitK13 : IsSplit starK13 splitK13 splitMapK13 := by
  constructor <;> decide

theorem isExclusive_splitK13 : IsExclusive splitK13 splitMapK13 := by
  unfold IsExclusive
  decide

/-- `splitK13` is a unit interval graph: place `1, 0, 2` at `0, 1, 2` and `4, 3` at `10, 11`. -/
theorem hasUnitIntervalRep_splitK13 : HasUnitIntervalRep splitK13 := by
  refine ⟨![1, 0, 2, 11, 10], ?_⟩
  intro x y
  fin_cases x <;> fin_cases y <;>
    simp [splitK13, SimpleGraph.fromRel, abs_le] <;> norm_num

/-- **The unit-interval splitting number of the claw is exactly one.** -/
theorem unitInterval_split_starK13_exact :
    (∃ (H : SimpleGraph (Fin 5)) (f : Fin 5 → Fin 4),
        IsSplit starK13 H f ∧ IsExclusive H f ∧ HasUnitIntervalRep H) ∧
      ∀ (W : Type) (_ : Fintype W) (H : SimpleGraph W) (f : W → Fin 4),
        IsSplit starK13 H f → HasUnitIntervalRep H → 4 < Fintype.card W := by
  refine ⟨⟨splitK13, splitMapK13, isSplit_splitK13, isExclusive_splitK13,
    hasUnitIntervalRep_splitK13⟩, ?_⟩
  intro W _ H f hsplit hH
  exact card_lt_of_split_unitInterval_starK13 hsplit hH

/-- The star `K_{1,4}` with centre `0` and leaves `1, 2, 3, 4`. -/
def starK14 : SimpleGraph (Fin 5) := SimpleGraph.fromRel (fun i j => i = 0 ∧ j ≠ 0)

instance : DecidableRel starK14.Adj := fun _ _ => by
  unfold starK14 SimpleGraph.fromRel
  infer_instance

theorem hasInducedClaw_starK14 : HasInducedClaw starK14 :=
  ⟨0, 1, 2, 3, by decide, by decide, by decide, by decide, by decide, by decide,
    by decide, by decide, by decide⟩

/-- Splitting the centre of `K_{1,4}` into `0` (keeping the leaves `1, 2`) and `5` (keeping the
leaves `3, 4`) gives the disjoint union of two paths on three vertices. -/
def splitK14 : SimpleGraph (Fin 6) :=
  SimpleGraph.fromRel (fun i j => (i = 0 ∧ (j = 1 ∨ j = 2)) ∨ (i = 5 ∧ (j = 3 ∨ j = 4)))

instance : DecidableRel splitK14.Adj := fun _ _ => by
  unfold splitK14 SimpleGraph.fromRel
  infer_instance

/-- The origin map of `splitK14`: the new vertex `5` is a second copy of the centre `0`. -/
def splitMapK14 : Fin 6 → Fin 5 := ![0, 1, 2, 3, 4, 0]

theorem isSplit_splitK14 : IsSplit starK14 splitK14 splitMapK14 := by
  constructor <;> decide

theorem isExclusive_splitK14 : IsExclusive splitK14 splitMapK14 := by
  unfold IsExclusive
  decide

/-- `splitK14` is a unit interval graph: place `1, 0, 2` at `0, 1, 2` and `3, 5, 4` at
`10, 11, 12`. -/
theorem hasUnitIntervalRep_splitK14 : HasUnitIntervalRep splitK14 := by
  refine ⟨![1, 0, 2, 10, 12, 11], ?_⟩
  intro x y
  fin_cases x <;> fin_cases y <;>
    simp [splitK14, SimpleGraph.fromRel, abs_le] <;> norm_num

/-- **The unit-interval splitting number of `K_{1,4}` is exactly one.**  Pairing up the leaves
turns the star into two disjoint copies of `P₃` with a single split, so the star `K_{1,n}` does
*not* require `n - 2` splits. -/
theorem unitInterval_split_starK14_exact :
    (∃ (H : SimpleGraph (Fin 6)) (f : Fin 6 → Fin 5),
        IsSplit starK14 H f ∧ IsExclusive H f ∧ HasUnitIntervalRep H) ∧
      ∀ (W : Type) (_ : Fintype W) (H : SimpleGraph W) (f : W → Fin 5),
        IsSplit starK14 H f → HasUnitIntervalRep H → 5 < Fintype.card W := by
  refine ⟨⟨splitK14, splitMapK14, isSplit_splitK14, isExclusive_splitK14,
    hasUnitIntervalRep_splitK14⟩, ?_⟩
  intro W _ H f hsplit hH
  simpa using card_lt_of_split_unitInterval hsplit hH hasInducedClaw_starK14

/-! ## A general lower bound for stars

The claw `K_{1,3}` is the smallest obstruction to being a unit interval graph, and a star
`K_{1,n}` contains many of them.  Since claw-free graphs let every copy of the centre keep at
most two leaves, at least `⌈n/2⌉` copies of the centre are needed.
-/

/-- The star `K_{1,n}`: the centre is the vertex `0` and the leaves are `1, …, n`. -/
def starGraph (n : ℕ) : SimpleGraph (Fin (n + 1)) :=
  SimpleGraph.fromRel (fun i j => i = 0 ∧ j ≠ 0)

theorem starGraph_adj_ne_zero {n : ℕ} {u v : Fin (n + 1)} (h : (starGraph n).Adj u v) :
    u = 0 ∨ v = 0 := by
  rw [starGraph, SimpleGraph.fromRel_adj] at h
  rcases h.2 with ⟨h1, -⟩ | ⟨h1, -⟩
  · exact Or.inl h1
  · exact Or.inr h1

theorem starGraph_adj_zero {n : ℕ} {v : Fin (n + 1)} (hv : v ≠ 0) :
    (starGraph n).Adj 0 v := by
  rw [starGraph, SimpleGraph.fromRel_adj]
  exact ⟨Ne.symm hv, Or.inl ⟨rfl, hv⟩⟩

/-- **Lower bound for stars.**  If a splitting of the star `K_{1,n}` produces a claw-free graph,
then the result has at least `n + ⌈n/2⌉` vertices: every copy of the centre can keep at most two
leaves, so at least `⌈n/2⌉` copies of the centre are needed, on top of the `n` leaves. -/
theorem card_ge_of_split_clawFree_star {n : ℕ} {W : Type*} [Fintype W]
    {H : SimpleGraph W} {f : W → Fin (n + 1)} (h : IsSplit (starGraph n) H f)
    (hclaw : ¬ HasInducedClaw H) : n + (n + 1) / 2 ≤ Fintype.card W := by
  classical
  have key : ∀ v : Fin (n + 1), ∃ x y : W, v ≠ 0 → (f x = 0 ∧ f y = v ∧ H.Adj x y) := by
    intro v
    by_cases hv : v = 0
    · obtain ⟨x, -⟩ := h.surj 0
      exact ⟨x, x, fun hc => absurd hv hc⟩
    · obtain ⟨x, y, hx, hy, hxy⟩ := h.cover 0 v (starGraph_adj_zero hv)
      exact ⟨x, y, fun _ => ⟨hx, hy, hxy⟩⟩
  choose X Y hXY using key
  set S : Finset (Fin (n + 1)) := Finset.univ.filter (fun v => v ≠ 0) with hSdef
  set C : Finset W := Finset.univ.filter (fun x => f x = 0) with hCdef
  set L : Finset W := Finset.univ.filter (fun x => ¬ f x = 0) with hLdef
  have hScard : S.card = n := by
    have : S = Finset.univ.erase (0 : Fin (n + 1)) := by
      ext v; simp [hSdef, Finset.mem_erase]
    rw [this, Finset.card_erase_of_mem (Finset.mem_univ _), Finset.card_univ, Fintype.card_fin]
    omega
  have hsum : C.card + L.card = Fintype.card W := by
    rw [hCdef, hLdef, Finset.card_filter_add_card_filter_not, Finset.card_univ]
  have hLcard : n ≤ L.card := by
    rw [← hScard]
    refine Finset.card_le_card_of_surjOn f ?_
    intro v hv
    simp only [hSdef, Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_univ, true_and] at hv
    obtain ⟨x, hx⟩ := h.surj v
    exact ⟨x, by simp [hLdef, hx, hv], hx⟩
  have hfib : ∀ c ∈ S.image X, (S.filter (fun v => X v = c)).card ≤ 2 := by
    intro c _
    by_contra hlt
    push_neg at hlt
    obtain ⟨a, b, d, ha, hb, hd, hab, had, hbd⟩ := Finset.two_lt_card_iff.mp hlt
    simp only [Finset.mem_filter, hSdef, Finset.mem_univ, true_and] at ha hb hd
    obtain ⟨ha0, haX⟩ := ha
    obtain ⟨hb0, hbX⟩ := hb
    obtain ⟨hd0, hdX⟩ := hd
    obtain ⟨-, hYa, hadja⟩ := hXY a ha0
    obtain ⟨-, hYb, hadjb⟩ := hXY b hb0
    obtain ⟨-, hYd, hadjd⟩ := hXY d hd0
    have hne : ∀ u v : Fin (n + 1), u ≠ v → f (Y u) = u → f (Y v) = v → Y u ≠ Y v := by
      intro u v huv hu hv hcc
      exact huv (by rw [← hu, ← hv, hcc])
    have hnadj : ∀ u v : Fin (n + 1), u ≠ 0 → v ≠ 0 → f (Y u) = u → f (Y v) = v →
        ¬ H.Adj (Y u) (Y v) := by
      intro u v hu0 hv0 hu hv hcc
      rcases starGraph_adj_ne_zero (h.adj_proj _ _ hcc) with hz | hz
      · exact hu0 (by rw [← hu, hz])
      · exact hv0 (by rw [← hv, hz])
    refine hclaw ⟨c, Y a, Y b, Y d, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · exact haX ▸ hadja
    · exact hbX ▸ hadjb
    · exact hdX ▸ hadjd
    · exact hne a b hab hYa hYb
    · exact hne a d had hYa hYd
    · exact hne b d hbd hYb hYd
    · exact hnadj a b ha0 hb0 hYa hYb
    · exact hnadj a d ha0 hd0 hYa hYd
    · exact hnadj b d hb0 hd0 hYb hYd
  have hSle : S.card ≤ 2 * (S.image X).card := Finset.card_le_mul_card_image S 2 hfib
  have himg : S.image X ⊆ C := by
    intro c hc
    obtain ⟨v, hv, rfl⟩ := Finset.mem_image.mp hc
    simp only [Finset.mem_filter, hSdef, Finset.mem_univ, true_and] at hv
    simp [hCdef, (hXY v hv).1]
  have hCle : (S.image X).card ≤ C.card := Finset.card_le_card himg
  omega

/-- The unit-interval version of the previous bound: turning `K_{1,n}` into a unit interval
graph requires at least `⌈n/2⌉ - 1` splits. -/
theorem card_ge_of_split_unitInterval_star {n : ℕ} {W : Type*} [Fintype W]
    {H : SimpleGraph W} {f : W → Fin (n + 1)} (h : IsSplit (starGraph n) H f)
    (hH : HasUnitIntervalRep H) : n + (n + 1) / 2 ≤ Fintype.card W :=
  card_ge_of_split_clawFree_star h (not_hasInducedClaw_of_unitIntervalRep hH)

/-! ### The matching upper bound for stars

Pairing up the leaves gives a splitting of `K_{1,n}` into `⌈n/2⌉` disjoint paths (`P₃`s, and one
`P₂` if `n` is odd), which is a unit interval graph.  Together with
`card_ge_of_split_clawFree_star` this determines the unit-interval splitting number of every
star exactly.
-/

/-- The disjoint union of `m` stars with at most two leaves each: the leaf `i` is attached to the
centre copy `⌊i/2⌋`. -/
def starSplitGraph (n m : ℕ) : SimpleGraph (Fin n ⊕ Fin m) :=
  SimpleGraph.fromRel (fun a b =>
    match a, b with
    | Sum.inl i, Sum.inr j => (i : ℕ) / 2 = (j : ℕ)
    | _, _ => False)

/-- The origin map: the leaf `i` comes from the leaf `i + 1` of the star, every centre copy comes
from the centre `0`. -/
def starSplitMap (n m : ℕ) : Fin n ⊕ Fin m → Fin (n + 1) :=
  Sum.elim Fin.succ (fun _ => 0)

theorem starGraph_adj_iff {n : ℕ} {u v : Fin (n + 1)} :
    (starGraph n).Adj u v ↔ (u = 0 ∧ v ≠ 0) ∨ (v = 0 ∧ u ≠ 0) := by
  rw [starGraph, SimpleGraph.fromRel_adj]
  constructor
  · rintro ⟨-, ⟨h1, h2⟩ | ⟨h1, h2⟩⟩
    · exact Or.inl ⟨h1, h2⟩
    · exact Or.inr ⟨h1, h2⟩
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · exact ⟨by simp [h1, Ne.symm h2], Or.inl ⟨h1, h2⟩⟩
    · exact ⟨by simp [h1]; exact h2, Or.inr ⟨h1, h2⟩⟩

theorem isSplit_starSplitGraph {n m : ℕ} (hm : 0 < m) (hcov : ∀ i : Fin n, (i : ℕ) / 2 < m) :
    IsSplit (starGraph n) (starSplitGraph n m) (starSplitMap n m) where
  surj := by
    intro v
    rcases Fin.eq_zero_or_eq_succ v with rfl | ⟨i, rfl⟩
    · exact ⟨Sum.inr ⟨0, hm⟩, rfl⟩
    · exact ⟨Sum.inl i, rfl⟩
  fiber_indep := by
    rintro (i | j) (i' | j') hxy hadj <;>
      simp only [starSplitMap, Sum.elim_inl, Sum.elim_inr] at hxy
    · simp [starSplitGraph, SimpleGraph.fromRel_adj] at hadj
    · exact Fin.succ_ne_zero i hxy
    · exact Fin.succ_ne_zero i' hxy.symm
    · simp [starSplitGraph, SimpleGraph.fromRel_adj] at hadj
  adj_proj := by
    rintro (i | j) (i' | j') hadj <;>
      simp only [starSplitGraph, SimpleGraph.fromRel_adj, or_false,
        false_or, and_false] at hadj <;>
      simp only [starSplitMap, Sum.elim_inl, Sum.elim_inr] <;>
      [skip; skip] <;>
      first
        | exact (starGraph_adj_zero (Fin.succ_ne_zero i)).symm
        | exact starGraph_adj_zero (Fin.succ_ne_zero i')
  cover := by
    intro u v huv
    rcases starGraph_adj_iff.mp huv with ⟨rfl, hv⟩ | ⟨rfl, hu⟩
    · obtain ⟨i, rfl⟩ := Fin.eq_succ_of_ne_zero hv
      refine ⟨Sum.inr ⟨(i : ℕ) / 2, hcov i⟩, Sum.inl i, rfl, rfl, ?_⟩
      simp [starSplitGraph, SimpleGraph.fromRel_adj]
    · obtain ⟨i, rfl⟩ := Fin.eq_succ_of_ne_zero hu
      refine ⟨Sum.inl i, Sum.inr ⟨(i : ℕ) / 2, hcov i⟩, rfl, rfl, ?_⟩
      simp [starSplitGraph, SimpleGraph.fromRel_adj]

theorem isExclusive_starSplitGraph {n m : ℕ} :
    IsExclusive (starSplitGraph n m) (starSplitMap n m) := by
  rintro (i | j) (i' | j') (i'' | j'') hxy hne hxz hyz <;>
    simp only [starSplitGraph, SimpleGraph.fromRel_adj, or_false, false_or,
      and_false] at hxz hyz <;>
    simp_all [starSplitMap, Fin.ext_iff]

/-- The pairing construction is a unit interval graph: place the centre copy `j` at `4j + 1` and
its (at most two) leaves `2j` and `2j + 1` at `4j` and `4j + 2`. -/
theorem hasUnitIntervalRep_starSplitGraph (n m : ℕ) :
    HasUnitIntervalRep (starSplitGraph n m) := by
  have key : ∀ a b : ℤ, |(a : ℝ) - (b : ℝ)| ≤ 1 ↔ |a - b| ≤ 1 := by
    intro a b
    rw [← Int.cast_sub, ← Int.cast_abs]
    exact_mod_cast Iff.rfl
  refine ⟨fun x => ((Sum.elim (fun i : Fin n => 2 * (i : ℕ))
      (fun j : Fin m => 4 * (j : ℕ) + 1) x : ℤ) : ℝ), ?_⟩
  rintro (i | j) (i' | j') <;>
    simp only [starSplitGraph, SimpleGraph.fromRel_adj, Sum.elim_inl, Sum.elim_inr, reduceCtorEq,
      or_false, false_or, and_false, ne_eq, Sum.inl.injEq, Sum.inr.injEq,
      Fin.ext_iff, key, abs_le, not_false_eq_true, true_and, false_iff, not_and] <;>
    omega

/-- **The unit-interval splitting number of the star `K_{1,n}` is exactly `⌈n/2⌉ - 1`.**  The
pairing construction attains `n + ⌈n/2⌉` vertices, and no splitting into a unit interval graph
can do better.  In particular `K_{1,4}` needs only one split, not two. -/
theorem unitInterval_split_star_exact (n : ℕ) (hn : 0 < n) :
    (∃ (H : SimpleGraph (Fin n ⊕ Fin ((n + 1) / 2))) (f : Fin n ⊕ Fin ((n + 1) / 2) → Fin (n + 1)),
        IsSplit (starGraph n) H f ∧ IsExclusive H f ∧ HasUnitIntervalRep H ∧
          Fintype.card (Fin n ⊕ Fin ((n + 1) / 2)) = n + (n + 1) / 2) ∧
      ∀ (W : Type) (_ : Fintype W) (H : SimpleGraph W) (f : W → Fin (n + 1)),
        IsSplit (starGraph n) H f → HasUnitIntervalRep H → n + (n + 1) / 2 ≤ Fintype.card W := by
  refine ⟨⟨starSplitGraph n ((n + 1) / 2), starSplitMap n ((n + 1) / 2),
    isSplit_starSplitGraph (by omega) (fun i => by have := i.isLt; omega),
    isExclusive_starSplitGraph, hasUnitIntervalRep_starSplitGraph _ _, by simp⟩, ?_⟩
  intro W _ H f hsplit hH
  exact card_ge_of_split_unitInterval_star hsplit hH

end VertexSplitting