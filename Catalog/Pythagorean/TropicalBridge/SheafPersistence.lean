/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Sheaf-Theoretic Tropical Persistence

This file develops the theory that tropical persistence data on finite graph
filtrations is the decategorified trace of a constructible sheaf on the
threshold parameter line.

## Main Results

* `activeVerts_eq_of_sameCritGap` — constructibility of the tropical kernel sheaf
* `tropEvtProfile_eq_cumSheafJump` — event profile = cumulative sheaf jumps
* `sheafEvtProfile_stability` — stability from sheaf interleaving
* `activeEulerChar_const_between_critical` — cross-domain: Euler char is constructible

## References

* Cohen-Steiner, Edelsbrunner, Harer, "Stability of Persistence Diagrams" (2007)
* Curry, "Sheaves, Cosheaves and Applications" (2014)
-/

import Mathlib

open Finset BigOperators Classical

set_option linter.unusedSectionVars false

noncomputable section

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Core Definitions -/

/-- Vertex filtration: entrance-time function. -/
abbrev VFilt (V : Type*) := V → ℝ

/-- Active vertices at time t. -/
def activeVerts (f : VFilt V) (t : ℝ) : Finset V :=
  Finset.univ.filter (fun v => f v ≤ t)

/-- Tropical event profile at time t: cumulative degree-weighted count. -/
def tropEvtProfile (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ) : ℤ :=
  ∑ v ∈ activeVerts f t, (↑(G.degree v) + 1 : ℤ)

/-! ## Critical Values and the Constructible Sheaf -/

/-- The **critical values** of a vertex filtration: the finite set of entrance times. -/
def critVals (f : VFilt V) : Finset ℝ :=
  Finset.univ.image f

/-- Two thresholds lie in the **same critical gap** if s ≤ t and no critical value
    lies in (s, t]. -/
def sameCritGap (crit : Finset ℝ) (s t : ℝ) : Prop :=
  s ≤ t ∧ ∀ c ∈ crit, ¬(s < c ∧ c ≤ t)

/-- The **sheaf jump** at a critical value `c`: the total degree-weighted
    contribution of all vertices whose entrance time equals `c`. -/
def sheafJump (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (c : ℝ) : ℤ :=
  ∑ v ∈ Finset.univ.filter (fun v => f v = c), (↑(G.degree v) + 1 : ℤ)

/-- The **sheaf event profile**: cumulative sum of sheaf jumps up to threshold `t`. -/
def sheafEvtProfile (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ) : ℤ :=
  ∑ c ∈ (critVals f).filter (fun c => c ≤ t), sheafJump G f c

/-! ## The Tropical Rank Sheaf -/

/-- The **tropical rank sheaf**: a constructible presheaf on the threshold line. -/
structure TropRankSheaf (V : Type*) [Fintype V] [DecidableEq V] where
  /-- The underlying graph -/
  graph : SimpleGraph V
  /-- Decidability of adjacency -/
  [decAdj : DecidableRel graph.Adj]
  /-- The vertex filtration -/
  filt : VFilt V
  /-- Rank at each threshold -/
  rankAt : ℝ → ℤ
  /-- The critical set -/
  critical : Finset ℝ
  /-- Rank is monotone -/
  mono : Monotone rankAt
  /-- Rank is locally constant off critical values -/
  locConst : ∀ {s t : ℝ}, sameCritGap critical s t → rankAt s = rankAt t

attribute [instance] TropRankSheaf.decAdj

/-- Construct a tropical rank sheaf from a graph and filtration. -/
def mkTropRankSheaf (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) : TropRankSheaf V where
  graph := G
  filt := f
  rankAt := tropEvtProfile G f
  critical := critVals f
  mono := by
    intro s t hst
    apply Finset.sum_le_sum_of_subset_of_nonneg
    · intro v hv; simp [activeVerts] at hv ⊢; linarith
    · intros; positivity
  locConst := by
    intro s t ⟨hst, hgap⟩
    unfold tropEvtProfile; congr 1; ext v
    simp only [activeVerts, mem_filter, mem_univ, true_and]
    constructor
    · exact fun hv => le_trans hv hst
    · intro hv; by_contra h; push_neg at h
      exact hgap (f v) (mem_image.mpr ⟨v, mem_univ v, rfl⟩) ⟨h, hv⟩

/-! ## Theorem 1: Constructibility -/

/-- **Constructibility of the tropical kernel sheaf.**
    The active vertex set is constant on each interval between consecutive
    critical values. This is the fundamental constructibility property: the
    "sheaf stalks" are locally constant away from the singular support. -/
theorem activeVerts_eq_of_sameCritGap
    (f : VFilt V) {s t : ℝ}
    (hgap : sameCritGap (critVals f) s t) :
    activeVerts f s = activeVerts f t := by
  ext v
  simp only [activeVerts, mem_filter, mem_univ, true_and]
  constructor
  · exact fun hv => le_trans hv hgap.1
  · intro hv; by_contra h; push_neg at h
    exact hgap.2 (f v) (mem_image.mpr ⟨v, mem_univ v, rfl⟩) ⟨h, hv⟩

/-- The event profile is constant between critical values. -/
theorem tropEvtProfile_const_between_critical
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) {s t : ℝ}
    (hgap : sameCritGap (critVals f) s t) :
    tropEvtProfile G f s = tropEvtProfile G f t := by
  unfold tropEvtProfile
  rw [activeVerts_eq_of_sameCritGap f hgap]

/-- Constructibility certificate: every filtration yields a rank sheaf. -/
theorem rankSheaf_exists
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) :
    ∃ S : TropRankSheaf V,
      S.graph = G ∧ S.filt = f ∧ S.critical = critVals f :=
  ⟨mkTropRankSheaf G f, rfl, rfl, rfl⟩

/-! ## Theorem 2: Event Profile = Cumulative Sheaf Jumps -/

/-- The active vertices decompose as the disjoint union of fibers over critical values. -/
theorem activeVerts_eq_biUnion
    (f : VFilt V) (t : ℝ) :
    activeVerts f t =
      ((critVals f).filter (fun c => c ≤ t)).biUnion
        (fun c => Finset.univ.filter (fun v => f v = c)) := by
  ext v
  simp only [activeVerts, mem_filter, mem_univ, true_and,
             mem_biUnion, critVals, mem_image]
  constructor
  · intro hv; exact ⟨f v, ⟨⟨v, rfl⟩, hv⟩, rfl⟩
  · intro ⟨c, ⟨_, hc_le⟩, hfv⟩; rw [hfv]; exact hc_le

/-- The fibers at distinct critical values are disjoint. -/
theorem fibers_pairwiseDisjoint (f : VFilt V) (S : Finset ℝ) :
    (S : Set ℝ).PairwiseDisjoint
      (fun c => Finset.univ.filter (fun v => f v = c)) := by
  intro c₁ _ c₂ _ hne
  simp only [Function.onFun, Finset.disjoint_filter]
  intro v _ h₁ h₂
  exact hne (h₁ ▸ h₂)

/-- **Event profile recovery theorem.**
    The tropical event profile equals the cumulative sum of sheaf jumps.
    This identifies the persistence observable as the trace of a constructible sheaf. -/
theorem tropEvtProfile_eq_cumSheafJump
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ) :
    tropEvtProfile G f t = sheafEvtProfile G f t := by
  unfold tropEvtProfile sheafEvtProfile sheafJump
  rw [activeVerts_eq_biUnion f t]
  rw [Finset.sum_biUnion (fibers_pairwiseDisjoint f _)]

/-- The sheaf event profile equals the rank of the constructed sheaf. -/
theorem sheafEvtProfile_eq_rankSheaf
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ) :
    sheafEvtProfile G f t = (mkTropRankSheaf G f).rankAt t := by
  rw [← tropEvtProfile_eq_cumSheafJump]; rfl

/-! ## Theorem 3: Sheaf-Theoretic Stability -/

/-- Active vertices grow monotonically. -/
theorem activeVerts_mono (f : VFilt V) {s t : ℝ} (hst : s ≤ t) :
    activeVerts f s ⊆ activeVerts f t := by
  intro v hv; simp [activeVerts] at hv ⊢; linarith

/-- Monotonicity of the event profile. -/
theorem tropEvtProfile_mono
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) {s t : ℝ} (hst : s ≤ t) :
    tropEvtProfile G f s ≤ tropEvtProfile G f t := by
  apply Finset.sum_le_sum_of_subset_of_nonneg (activeVerts_mono f hst)
  intros; positivity

/-- For ε-close filtrations, active set at t under f ⊆ active set at t+ε under g. -/
theorem activeVerts_subset_close
    (f g : VFilt V) (t ε : ℝ)
    (hclose : ∀ v, |f v - g v| ≤ ε) :
    activeVerts f t ⊆ activeVerts g (t + ε) := by
  intro v hv
  simp [activeVerts] at hv ⊢
  have := abs_le.mp (hclose v); linarith

/-- Interleaving of event profiles for ε-close filtrations. -/
theorem tropEvtProfile_interleaved
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f g : VFilt V) (ε : ℝ)
    (hclose : ∀ v, |f v - g v| ≤ ε) (t : ℝ) :
    tropEvtProfile G f t ≤ tropEvtProfile G g (t + ε) := by
  apply Finset.sum_le_sum_of_subset_of_nonneg (activeVerts_subset_close f g t ε hclose)
  intros; positivity

/-- **Sheaf-theoretic stability.**
    ε-close filtrations have ε-interleaved sheaf event profiles.
    Stability emerges from functoriality of the sheaf construction. -/
theorem sheafEvtProfile_stability
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f g : VFilt V) (ε : ℝ)
    (hclose : ∀ v, |f v - g v| ≤ ε) (t : ℝ) :
    sheafEvtProfile G f t ≤ sheafEvtProfile G g (t + ε) := by
  rw [← tropEvtProfile_eq_cumSheafJump, ← tropEvtProfile_eq_cumSheafJump]
  exact tropEvtProfile_interleaved G f g ε hclose t

/-- Symmetric interleaving. -/
theorem sheafEvtProfile_stability_symm
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f g : VFilt V) (ε : ℝ)
    (hclose : ∀ v, |f v - g v| ≤ ε) (t : ℝ) :
    sheafEvtProfile G g t ≤ sheafEvtProfile G f (t + ε) := by
  apply sheafEvtProfile_stability G g f ε
  intro v; rw [abs_sub_comm]; exact hclose v

/-- **Full sheaf stability:** both interleaving directions. -/
theorem sheafEvtProfile_stability_both
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f g : VFilt V) (ε : ℝ)
    (hclose : ∀ v, |f v - g v| ≤ ε) (t : ℝ) :
    sheafEvtProfile G f t ≤ sheafEvtProfile G g (t + ε) ∧
    sheafEvtProfile G g t ≤ sheafEvtProfile G f (t + ε) :=
  ⟨sheafEvtProfile_stability G f g ε hclose t,
   sheafEvtProfile_stability_symm G f g ε hclose t⟩

/-! ## Type-Valued Kernel Data Sheaf -/

/-- **Tropical kernel data** at threshold t: the subtype of active vertices. -/
def TropKernelData (f : VFilt V) (t : ℝ) : Type _ :=
  { v : V // f v ≤ t }

/-- Restriction map: inclusion of active sets (covariant). -/
def kernelRestriction (f : VFilt V) {s t : ℝ} (hst : s ≤ t) :
    TropKernelData f s → TropKernelData f t :=
  fun ⟨v, hv⟩ => ⟨v, le_trans hv hst⟩

/-- Restriction is the identity for s = t. -/
theorem kernelRestriction_id (f : VFilt V) (t : ℝ) :
    kernelRestriction f (le_refl t) = id := by
  ext ⟨v, hv⟩; rfl

/-- Restriction maps compose (functoriality). -/
theorem kernelRestriction_comp (f : VFilt V)
    {r s t : ℝ} (hrs : r ≤ s) (hst : s ≤ t) :
    kernelRestriction f (le_trans hrs hst) =
      kernelRestriction f hst ∘ kernelRestriction f hrs := by
  ext ⟨v, hv⟩; rfl

/-- **Constructibility of kernel data.**
    Between critical values, kernel data stalks are canonically equivalent. -/
def tropKernelData_equiv_of_sameCritGap
    (f : VFilt V) {s t : ℝ}
    (hgap : sameCritGap (critVals f) s t) :
    TropKernelData f s ≃ TropKernelData f t :=
  Equiv.subtypeEquiv (Equiv.refl V) (by
    intro v; simp only [Equiv.refl_apply]
    constructor
    · exact fun hv => le_trans hv hgap.1
    · intro hv; by_contra h; push_neg at h
      exact hgap.2 (f v) (mem_image.mpr ⟨v, mem_univ v, rfl⟩) ⟨h, hv⟩)

/-! ## Theorem 4: Cross-Domain Bridge — Euler Characteristic -/

/-- The **Euler characteristic** of the active subgraph at threshold t:
    `χ(t) = |active vertices| - |active edges|`. -/
def activeEulerChar (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ) : ℤ :=
  (activeVerts f t).card -
  ((G.edgeFinset.filter (fun e =>
    ∀ v ∈ e, v ∈ activeVerts f t)).card : ℤ)

/-- **Cross-domain bridge: the Euler characteristic is constructible.**
    The Euler characteristic is constant between critical values, connecting
    tropical persistence to combinatorial topology. -/
theorem activeEulerChar_const_between_critical
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) {s t : ℝ}
    (hgap : sameCritGap (critVals f) s t) :
    activeEulerChar G f s = activeEulerChar G f t := by
  unfold activeEulerChar
  rw [activeVerts_eq_of_sameCritGap f hgap]

/-! ## Sheaf Jump Properties -/

/-- Sheaf jump is nonneg. -/
theorem sheafJump_nonneg (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (c : ℝ) :
    0 ≤ sheafJump G f c := by
  apply Finset.sum_nonneg; intros; positivity

/-- If no vertex enters at time c, the sheaf jump is zero. -/
theorem sheafJump_eq_zero_of_not_critical
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (c : ℝ)
    (hc : c ∉ critVals f) :
    sheafJump G f c = 0 := by
  unfold sheafJump
  have : Finset.univ.filter (fun v => f v = c) = ∅ := by
    rw [Finset.filter_eq_empty_iff]
    intro v _ hfv
    apply hc
    exact mem_image.mpr ⟨v, mem_univ v, hfv⟩
  rw [this]; simp

/-- The total of all sheaf jumps equals the total profile when all vertices are active. -/
theorem total_sheafJump_eq_total_profile
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ)
    (ht : ∀ v, f v ≤ t) :
    ∑ c ∈ critVals f, sheafJump G f c = tropEvtProfile G f t := by
  have hfilt : (critVals f).filter (fun c => c ≤ t) = critVals f := by
    rw [Finset.filter_eq_self]
    intro c hc
    obtain ⟨v, _, rfl⟩ := mem_image.mp hc
    exact ht v
  rw [tropEvtProfile_eq_cumSheafJump]
  unfold sheafEvtProfile; rw [hfilt]

/-- The event profile below all critical values is zero. -/
theorem tropEvtProfile_below_all_critical
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (t : ℝ)
    (ht : ∀ v, t < f v) :
    tropEvtProfile G f t = 0 := by
  unfold tropEvtProfile
  have : activeVerts f t = ∅ := by
    rw [Finset.eq_empty_iff_forall_notMem]
    intro v; simp [activeVerts]; linarith [ht v]
  rw [this]; simp

/-- The event profile jumps by exactly the sheaf jump when crossing a critical value,
    provided no other critical value is between s and c. -/
theorem tropEvtProfile_jump_at_critical
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) (c s : ℝ) (hsc : s < c)
    (hgap : ∀ v, f v ≤ s ∨ c ≤ f v) :
    tropEvtProfile G f c - tropEvtProfile G f s = sheafJump G f c := by
  unfold tropEvtProfile sheafJump
  have hactive_s_sub : activeVerts f s ⊆ activeVerts f c := by
    intro v hv; simp [activeVerts] at hv ⊢; linarith
  have hactive_c : activeVerts f c = activeVerts f s ∪ Finset.univ.filter (fun v => f v = c) := by
    ext v; simp only [activeVerts, mem_filter, mem_univ, true_and, mem_union]
    constructor
    · intro hv; cases hgap v with
      | inl h => left; exact h
      | inr h => right; exact le_antisymm hv h
    · intro hv; cases hv with
      | inl h => linarith
      | inr h => linarith
  have hdisj : Disjoint (activeVerts f s) (Finset.univ.filter (fun v => f v = c)) := by
    rw [Finset.disjoint_left]
    intro v hv hfv
    simp [activeVerts] at hv
    simp at hfv
    linarith
  rw [hactive_c, Finset.sum_union hdisj]
  ring

/-! ## Sheaf Profile Monotonicity -/

/-- The sheaf event profile is monotone. -/
theorem sheafEvtProfile_mono
    (G : SimpleGraph V) [DecidableRel G.Adj]
    (f : VFilt V) {s t : ℝ} (hst : s ≤ t) :
    sheafEvtProfile G f s ≤ sheafEvtProfile G f t := by
  rw [← tropEvtProfile_eq_cumSheafJump, ← tropEvtProfile_eq_cumSheafJump]
  exact tropEvtProfile_mono G f hst

/-! ## Path Graph Example -/

/-- The path graph on `Fin (n+1)`: vertex i is adjacent to vertex j iff |i-j| = 1. -/
def pathGr (n : ℕ) : SimpleGraph (Fin (n + 1)) where
  Adj i j := (i.val + 1 = j.val) ∨ (j.val + 1 = i.val)
  symm := by intro i j h; cases h with | inl h => exact Or.inr h | inr h => exact Or.inl h
  loopless := ⟨fun i h => by rcases h with h | h <;> omega⟩

instance pathGrDecAdj (n : ℕ) : DecidableRel (pathGr n).Adj := by
  intro i j; simp only [pathGr]; exact inferInstance

/-- Path filtration: vertex i enters at time i. -/
def pathFilt (n : ℕ) : VFilt (Fin (n + 1)) :=
  fun i => (i : ℝ)

/-- At threshold k, there are exactly k+1 active vertices in the path filtration
    (for k < n+1). -/
theorem activeVerts_pathFilt_card (n : ℕ) (k : Fin (n + 1)) :
    (activeVerts (pathFilt n) (k : ℝ)).card = k.val + 1 := by
  convert_to (Finset.Iic k).card = k.val + 1
  · congr 1
    ext i
    simp only [activeVerts, pathFilt, mem_filter, mem_univ, true_and, Finset.mem_Iic]
    constructor
    · intro h; exact Fin.val_le_of_le (by exact_mod_cast h)
    · intro h; exact_mod_cast h
  · simp [Fin.card_Iic]

end