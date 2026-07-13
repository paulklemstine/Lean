/-
# An Infinite Pachner Theorem for Locally Finite Triangulations of the Line

Pachner's theorem states that any two triangulations of a piecewise-linear
manifold are related by a finite sequence of *bistellar moves* (Pachner moves).
Its *infinite* analogue asks: if `S` and `T` are two **locally finite**
triangulations of a manifold `M`, are they related by a *locally finite*
sequence of bistellar moves?

This file develops the one–dimensional case (`M = ℝ`) completely and rigorously.
A locally finite triangulation of the real line is encoded by its vertex set
`V ⊆ ℝ`: a set that meets every bounded interval in a finite set and is
unbounded above and below.  In dimension one there are exactly two Pachner
moves:

* the `0`-move (**subdivision**): insert a new vertex into an edge;
* the `1`-move (**weld**): delete a vertex, merging its two incident edges.

We build a chain of results culminating in the *infinite Pachner theorem* for
the line.

## Main results

* `subdiv_iff_weld`      — every subdivision is the inverse of a weld (reversibility).
* `move_symm`            — the bistellar-move relation is symmetric.
* `move_preserves_isTri` — a bistellar move sends a triangulation to a triangulation.
* `pachner_equivalence`  — Pachner-equivalence is an equivalence relation.
* `symmDiff_finite_move` — **finite Pachner**: vertex sets with finite symmetric
                           difference are joined by a finite sequence of moves.
* `infinite_pachner`     — **infinite Pachner (dimension 1)**: any two locally
                           finite triangulations of `ℝ` are joined by a locally
                           finite (window-stabilizing) sequence of finite blocks
                           of bistellar moves.

## References

* U. Pachner, *P.L. homeomorphic manifolds are equivalent by elementary
  shellings*, European J. Combin. 12 (1991).
-/

import Mathlib

open Set

namespace InfinitePachner

/-! ## Triangulations of the line and bistellar moves -/

/-- A locally finite triangulation of the real line, encoded by its vertex set:
it meets every bounded interval in a finite set and is unbounded in both
directions. -/
def IsTri (V : Set ℝ) : Prop :=
  (∀ a b : ℝ, (V ∩ Set.Icc a b).Finite) ∧
  (∀ x : ℝ, ∃ y ∈ V, x < y) ∧
  (∀ x : ℝ, ∃ y ∈ V, y < x)

/-- The `0`-move (subdivision): insert a new vertex. -/
def Subdiv (S T : Set ℝ) : Prop := ∃ x, x ∉ S ∧ T = insert x S

/-- The `1`-move (weld): delete an existing vertex. -/
def Weld (S T : Set ℝ) : Prop := ∃ x, x ∈ S ∧ T = S \ {x}

/-- A bistellar (Pachner) move: a subdivision or a weld. -/
def Move (S T : Set ℝ) : Prop := Subdiv S T ∨ Weld S T

/-- Pachner-equivalence: the reflexive–transitive closure of the move relation. -/
def Pachner (S T : Set ℝ) : Prop := Relation.ReflTransGen Move S T

/-! ## Reversibility and symmetry -/

/-- A subdivision is exactly the inverse of a weld. -/
theorem subdiv_iff_weld (S T : Set ℝ) : Subdiv S T ↔ Weld T S := by
  constructor
  · rintro ⟨x, hx, rfl⟩
    exact ⟨x, Set.mem_insert x S, by rw [insert_diff_self_of_notMem hx]⟩
  · rintro ⟨x, hx, rfl⟩
    refine ⟨x, by simp, ?_⟩
    rw [insert_diff_singleton, insert_eq_self.2 hx]

/-- The bistellar-move relation is symmetric: every move can be undone. -/
theorem move_symm {S T : Set ℝ} (h : Move S T) : Move T S := by
  rcases h with h | h
  · exact Or.inr ((subdiv_iff_weld S T).1 h)
  · exact Or.inl ((subdiv_iff_weld T S).2 h)

/-! ## Moves preserve triangulations -/

/-- A bistellar move sends a triangulation to a triangulation. -/
theorem move_preserves_isTri {S T : Set ℝ} (hS : IsTri S) (h : Move S T) :
    IsTri T := by
  obtain ⟨hLF, hUp, hDn⟩ := hS
  rcases h with ⟨x, hx, rfl⟩ | ⟨x, hx, rfl⟩
  · refine ⟨?_, ?_, ?_⟩
    · intro a b
      apply Set.Finite.subset ((hLF a b).insert x)
      intro y hy
      rcases hy with ⟨hyi, hyIcc⟩
      rcases hyi with h | h
      · exact Or.inl h
      · exact Or.inr ⟨h, hyIcc⟩
    · intro z; obtain ⟨y, hy, hyz⟩ := hUp z; exact ⟨y, Or.inr hy, hyz⟩
    · intro z; obtain ⟨y, hy, hyz⟩ := hDn z; exact ⟨y, Or.inr hy, hyz⟩
  · refine ⟨?_, ?_, ?_⟩
    · intro a b
      exact Set.Finite.subset (hLF a b) (fun y hy => ⟨hy.1.1, hy.2⟩)
    · intro z
      obtain ⟨y1, hy1, hy1z⟩ := hUp z
      obtain ⟨y2, hy2, hy12⟩ := hUp y1
      by_cases hxe : y2 = x
      · refine ⟨y1, ⟨hy1, ?_⟩, hy1z⟩
        intro hc; rw [Set.mem_singleton_iff] at hc
        rw [hc, ← hxe] at hy12; exact absurd hy12 (lt_irrefl _)
      · exact ⟨y2, ⟨hy2, by simp [hxe]⟩, lt_trans hy1z hy12⟩
    · intro z
      obtain ⟨y1, hy1, hy1z⟩ := hDn z
      obtain ⟨y2, hy2, hy12⟩ := hDn y1
      by_cases hxe : y2 = x
      · refine ⟨y1, ⟨hy1, ?_⟩, hy1z⟩
        intro hc; rw [Set.mem_singleton_iff] at hc
        rw [hc, ← hxe] at hy12; exact absurd hy12 (lt_irrefl _)
      · exact ⟨y2, ⟨hy2, by simp [hxe]⟩, lt_trans hy12 hy1z⟩

/-! ## Pachner-equivalence is an equivalence relation -/

theorem pachner_refl (S : Set ℝ) : Pachner S S := Relation.ReflTransGen.refl

theorem pachner_trans {S T U : Set ℝ} (h₁ : Pachner S T) (h₂ : Pachner T U) :
    Pachner S U := Relation.ReflTransGen.trans h₁ h₂

/-- Pachner-equivalence is symmetric (uses symmetry of a single move). -/
theorem pachner_symm {S T : Set ℝ} (h : Pachner S T) : Pachner T S := by
  induction h with
  | refl => exact Relation.ReflTransGen.refl
  | tail _ hbc ih =>
      exact Relation.ReflTransGen.trans
        (Relation.ReflTransGen.single (move_symm hbc)) ih

/-- Pachner-equivalence is an equivalence relation. -/
theorem pachner_equivalence : Equivalence Pachner :=
  ⟨pachner_refl, fun h => pachner_symm h, fun h₁ h₂ => pachner_trans h₁ h₂⟩

/-! ## Local finiteness of symmetric differences -/

/-- If `S` and `T` are locally finite (meet every bounded interval finitely),
so does their symmetric difference. -/
theorem locallyFinite_symmDiff {S T : Set ℝ}
    (hS : ∀ a b : ℝ, (S ∩ Set.Icc a b).Finite)
    (hT : ∀ a b : ℝ, (T ∩ Set.Icc a b).Finite) (a b : ℝ) :
    (((S \ T) ∪ (T \ S)) ∩ Set.Icc a b).Finite := by
  apply Set.Finite.subset ((hS a b).union (hT a b))
  intro x hx
  rcases hx with ⟨hu, hIcc⟩
  rcases hu with h | h
  · exact Or.inl ⟨h.1, hIcc⟩
  · exact Or.inr ⟨h.1, hIcc⟩

/-! ## Finite Pachner theorem -/

/-- Auxiliary induction: if the symmetric difference of `S` and `T` is finite
with `n` elements, then `S` and `T` are joined by a finite sequence of moves. -/
theorem symmDiff_card_move :
    ∀ (n : ℕ) (S T : Set ℝ), ((S \ T) ∪ (T \ S)).Finite →
      ((S \ T) ∪ (T \ S)).ncard = n → Pachner S T := by
  intro n
  induction n with
  | zero =>
    intro S T hfin hcard
    have hempty : (S \ T) ∪ (T \ S) = ∅ := (Set.ncard_eq_zero hfin).1 hcard
    have hST : S = T := by
      rw [Set.union_empty_iff, Set.diff_eq_empty, Set.diff_eq_empty] at hempty
      exact Set.Subset.antisymm hempty.1 hempty.2
    rw [hST]; exact Relation.ReflTransGen.refl
  | succ m ih =>
    intro S T hfin hcard
    have hne : ((S \ T) ∪ (T \ S)).Nonempty := by
      rw [← Set.ncard_pos hfin, hcard]; omega
    obtain ⟨x, hx⟩ := hne
    rcases hx with hx | hx
    · refine Relation.ReflTransGen.trans
        (Relation.ReflTransGen.single (Or.inr ⟨x, hx.1, rfl⟩ : Move S (S \ {x}))) ?_
      have hDeq : ((S \ {x}) \ T) ∪ (T \ (S \ {x})) = ((S \ T) ∪ (T \ S)) \ {x} := by
        ext y
        simp only [Set.mem_union, Set.mem_diff, Set.mem_singleton_iff]
        by_cases hy : y = x <;> simp_all
      refine ih (S \ {x}) T (by rw [hDeq]; exact hfin.diff) ?_
      rw [hDeq, Set.ncard_diff_singleton_of_mem (Set.mem_union_left _ hx), hcard]
      omega
    · refine Relation.ReflTransGen.trans
        (Relation.ReflTransGen.single (Or.inl ⟨x, hx.2, rfl⟩ : Move S (insert x S))) ?_
      have hDeq : ((insert x S) \ T) ∪ (T \ (insert x S)) = ((S \ T) ∪ (T \ S)) \ {x} := by
        ext y
        simp only [Set.mem_union, Set.mem_diff, Set.mem_insert_iff, Set.mem_singleton_iff]
        by_cases hy : y = x <;> simp_all
      refine ih (insert x S) T (by rw [hDeq]; exact hfin.diff) ?_
      rw [hDeq, Set.ncard_diff_singleton_of_mem (Set.mem_union_right _ hx), hcard]
      omega

/-- **Finite Pachner theorem (dimension 1).**  Two vertex sets whose symmetric
difference is finite are related by a finite sequence of bistellar moves. -/
theorem symmDiff_finite_move {S T : Set ℝ} (h : ((S \ T) ∪ (T \ S)).Finite) :
    Pachner S T :=
  symmDiff_card_move _ S T h rfl

/-! ## Infinite Pachner theorem -/

/-- The `n`-th milestone triangulation: agrees with `T` on the open window
`(-n, n)` and with `S` outside it.  At `n = 0` the window is empty, so
`milestone S T 0 = S`. -/
noncomputable def milestone (S T : Set ℝ) (n : ℕ) : Set ℝ :=
  (S \ Set.Ioo (-(n : ℝ)) n) ∪ (T ∩ Set.Ioo (-(n : ℝ)) n)

/-- Membership characterization of a milestone. -/
theorem mem_milestone (S T : Set ℝ) (k : ℕ) (y : ℝ) :
    y ∈ milestone S T k ↔
      (y ∈ S ∧ y ∉ Set.Ioo (-(k:ℝ)) k) ∨ (y ∈ T ∧ y ∈ Set.Ioo (-(k:ℝ)) k) := by
  simp only [milestone, Set.mem_union, Set.mem_diff, Set.mem_inter_iff]

/-- Every milestone is contained in the union of the two vertex sets. -/
theorem milestone_subset_union (S T : Set ℝ) (k : ℕ) : milestone S T k ⊆ S ∪ T := by
  intro y hy; rw [mem_milestone] at hy
  rcases hy with ⟨h, _⟩ | ⟨h, _⟩
  · exact Or.inl h
  · exact Or.inr h

/-- Consecutive milestones differ only inside a bounded window, hence have finite
symmetric difference (using local finiteness of `S` and `T`). -/
theorem milestone_symmDiff_finite {S T : Set ℝ}
    (hS : ∀ a b : ℝ, (S ∩ Set.Icc a b).Finite)
    (hT : ∀ a b : ℝ, (T ∩ Set.Icc a b).Finite) (n : ℕ) :
    ((milestone S T n \ milestone S T (n + 1)) ∪
      (milestone S T (n + 1) \ milestone S T n)).Finite := by
  apply Set.Finite.subset ((hS (-((n:ℝ)+1)) ((n:ℝ)+1)).union (hT (-((n:ℝ)+1)) ((n:ℝ)+1)))
  have ecast : ((n+1:ℕ):ℝ) = (n:ℝ)+1 := by push_cast; ring
  have hwinsub : Set.Ioo (-(n:ℝ)) (n:ℝ) ⊆ Set.Ioo (-((n:ℝ)+1)) ((n:ℝ)+1) := by
    apply Set.Ioo_subset_Ioo <;> linarith [Nat.cast_nonneg (α := ℝ) n]
  intro y hy
  have hST : y ∈ S ∨ y ∈ T := by
    rcases hy with ⟨h1, _⟩ | ⟨h1, _⟩ <;> exact milestone_subset_union S T _ h1
  have hwin : y ∈ Set.Ioo (-((n:ℝ)+1)) ((n:ℝ)+1) := by
    by_contra hno
    have houtn : y ∉ Set.Ioo (-(n:ℝ)) (n:ℝ) := fun h => hno (hwinsub h)
    have hout1 : y ∉ Set.Ioo (-((n+1:ℕ):ℝ)) ((n+1:ℕ):ℝ) := by rw [ecast]; exact hno
    have hagree : y ∈ milestone S T n ↔ y ∈ milestone S T (n+1) := by
      rw [mem_milestone, mem_milestone]
      constructor
      · rintro (⟨hyS, _⟩ | ⟨_, hin⟩)
        · exact Or.inl ⟨hyS, hout1⟩
        · exact absurd hin houtn
      · rintro (⟨hyS, _⟩ | ⟨_, hin⟩)
        · exact Or.inl ⟨hyS, houtn⟩
        · exact absurd hin hout1
    rcases hy with ⟨h1, h2⟩ | ⟨h1, h2⟩
    · exact h2 (hagree.1 h1)
    · exact h2 (hagree.2 h1)
  have hwin' : y ∈ Set.Icc (-((n:ℝ)+1)) ((n:ℝ)+1) := Set.Ioo_subset_Icc_self hwin
  rcases hST with h | h
  · exact Or.inl ⟨h, hwin'⟩
  · exact Or.inr ⟨h, hwin'⟩

/-- Consecutive milestones are joined by a finite sequence of bistellar moves. -/
theorem milestone_step {S T : Set ℝ}
    (hS : ∀ a b : ℝ, (S ∩ Set.Icc a b).Finite)
    (hT : ∀ a b : ℝ, (T ∩ Set.Icc a b).Finite) (n : ℕ) :
    Pachner (milestone S T n) (milestone S T (n + 1)) :=
  symmDiff_finite_move (milestone_symmDiff_finite hS hT n)

/-- On any fixed bounded window the milestones eventually equal `T`. -/
theorem milestone_stabilizes {S T : Set ℝ} (a b : ℝ) :
    ∃ N : ℕ, ∀ n ≥ N, milestone S T n ∩ Set.Icc a b = T ∩ Set.Icc a b := by
  refine ⟨⌈max |a| |b|⌉₊ + 1, ?_⟩
  intro n hn
  have key : max |a| |b| < (n:ℝ) := by
    have h1 : max |a| |b| ≤ (⌈max |a| |b|⌉₊ : ℝ) := Nat.le_ceil _
    have h2 : ((⌈max |a| |b|⌉₊ + 1 : ℕ) : ℝ) ≤ (n:ℝ) := by exact_mod_cast hn
    push_cast at h2; linarith
  have hb : b < n := lt_of_le_of_lt (le_trans (le_abs_self b) (le_max_right _ _)) key
  have ha : -(n:ℝ) < a := by
    have h3 : |a| < (n:ℝ) := lt_of_le_of_lt (le_max_left _ _) key
    have h4 : -|a| ≤ a := neg_abs_le a
    linarith
  ext y
  simp only [Set.mem_inter_iff, mem_milestone, Set.mem_Icc, Set.mem_Ioo]
  constructor
  · rintro ⟨hm, hy1, hy2⟩
    refine ⟨?_, hy1, hy2⟩
    rcases hm with ⟨_, hno⟩ | ⟨hT, _⟩
    · exact absurd ⟨by linarith, by linarith⟩ hno
    · exact hT
  · rintro ⟨hT, hy1, hy2⟩
    exact ⟨Or.inr ⟨hT, by constructor <;> linarith⟩, hy1, hy2⟩

/-- **Infinite Pachner theorem (dimension 1).**  Any two locally finite
triangulations `S`, `T` of the real line are joined by a locally finite sequence
of bistellar moves.  Concretely there is a sequence of triangulations
`g : ℕ → Set ℝ` starting at `S`, in which each consecutive pair is joined by a
*finite* block of bistellar moves, and which stabilizes to `T` on every bounded
window (the local-finiteness of the total move sequence). -/
theorem infinite_pachner {S T : Set ℝ} (hS : IsTri S) (hT : IsTri T) :
    ∃ g : ℕ → Set ℝ,
      g 0 = S ∧
      (∀ n, Pachner (g n) (g (n + 1))) ∧
      (∀ a b : ℝ, ∃ N : ℕ, ∀ n ≥ N, g n ∩ Set.Icc a b = T ∩ Set.Icc a b) := by
  refine ⟨milestone S T, by simp [milestone], ?_, ?_⟩
  · intro n; exact milestone_step hS.1 hT.1 n
  · intro a b; exact milestone_stabilizes a b

end InfinitePachner