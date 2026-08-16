import Mathlib

/-!
# Emergent geometry from entanglement: the min-cut entropy cone

This file develops, from scratch, the mathematics behind the slogan
*"spacetime geometry is built out of entanglement"* in a finite, fully rigorous
setting.

A **bulk geometry** is a finite weighted graph (symmetric, nonnegative weights):
this is the discrete stand-in for a spatial slice of an asymptotically AdS
geometry, the weight of an edge playing the role of the area of the surface
element separating two bulk cells.  Some vertices are declared **boundary**
vertices; these carry the CFT degrees of freedom.

The **entanglement entropy** of a boundary region `A` is the *min-cut*
(Ryu–Takayanagi) prescription: the minimum cut weight over all bulk regions
whose boundary trace is exactly `A`.

The main results proved here are the *holographic entropy inequalities* of this
model, obtained from purely combinatorial (Boolean) pointwise inequalities on
separation indicators:

* `entropy_subadditive`         : `S(A ∪ B) ≤ S(A) + S(B)`
* `entropy_strong_subadditive`  : `S(A∪B) + S(B∪C) ≥ S(A∪B∪C) + S(B)`
* `entropy_monogamy` (**MMI**)  : `S(A∪B)+S(B∪C)+S(A∪C) ≥ S(A)+S(B)+S(C)+S(A∪B∪C)`
* `entropy_complement`          : purity, `S(A) = S(bdry \ A)`

The key technical engine is `cutWeight_comb`: a family of cuts dominates another
family as soon as the corresponding Boolean separation indicators do so
pointwise.  Strong subadditivity comes from submodularity of the cut function
(`sepBit_submodular`), and monogamy from a *minority/union* recombination of
three cuts, whose 64-case Boolean verification is `sepBit_mmi`.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V]

/-! ## Boolean separation indicators -/

/-- The separation indicator of two Boolean values: `1` if they differ. -/
def sepBit (a b : Bool) : ℕ := if a = b then 0 else 1

@[simp] lemma sepBit_self (a : Bool) : sepBit a a = 0 := by simp [sepBit]

lemma sepBit_comm (a b : Bool) : sepBit a b = sepBit b a := by
  cases a <;> cases b <;> rfl

lemma sepBit_not (a b : Bool) : sepBit (!a) (!b) = sepBit a b := by
  cases a <;> cases b <;> rfl

/-- **Submodularity at the level of a single pair of cells.** -/
lemma sepBit_submodular (a₁ a₂ b₁ b₂ : Bool) :
    sepBit (a₁ && a₂) (b₁ && b₂) + sepBit (a₁ || a₂) (b₁ || b₂)
      ≤ sepBit a₁ b₁ + sepBit a₂ b₂ := by
  revert a₁ a₂ b₁ b₂; decide

/-- **The monogamy recombination inequality at the level of a single pair of
cells.**  The three "minority" regions (in exactly two of the three cuts) and
the union region together separate any given pair of bulk cells at most as often
as the three original cuts do.  This is the combinatorial heart of monogamy of
mutual information; it is a genuine 64-case Boolean fact, and it *fails* if the
minority regions are replaced by the naive pairwise intersections. -/
lemma sepBit_mmi (a₁ a₂ a₃ b₁ b₂ b₃ : Bool) :
    sepBit (a₁ && a₂ && !a₃) (b₁ && b₂ && !b₃)
      + sepBit (a₁ && a₃ && !a₂) (b₁ && b₃ && !b₂)
      + sepBit (a₂ && a₃ && !a₁) (b₂ && b₃ && !b₁)
      + sepBit (a₁ || a₂ || a₃) (b₁ || b₂ || b₃)
      ≤ sepBit a₁ b₁ + sepBit a₂ b₂ + sepBit a₃ b₃ := by
  revert a₁ a₂ a₃ b₁ b₂ b₃; decide

/-- The naive pairwise-intersection recombination *fails* pointwise: this is why
monogamy needs the minority regions. -/
lemma sepBit_naive_mmi_fails :
    ¬ (∀ a₁ a₂ a₃ b₁ b₂ b₃ : Bool,
        sepBit (a₁ && a₂) (b₁ && b₂) + sepBit (a₁ && a₃) (b₁ && b₃)
          + sepBit (a₂ && a₃) (b₂ && b₃)
          + sepBit (a₁ || a₂ || a₃) (b₁ || b₂ || b₃)
          ≤ sepBit a₁ b₁ + sepBit a₂ b₂ + sepBit a₃ b₃) := by
  intro h
  have := h true true true false false false
  simp [sepBit] at this

/-! ## Bulk geometries and cuts -/

/-- A finite bulk geometry: a symmetric, nonnegatively weighted graph on `V`. -/
structure BulkGraph (V : Type*) [Fintype V] where
  /-- Area element assigned to the pair `(u,v)` of bulk cells. -/
  weight : V → V → ℝ
  weight_symm : ∀ u v, weight u v = weight v u
  weight_nonneg : ∀ u v, 0 ≤ weight u v

/-- A bulk region is a Boolean subset of the bulk cells. -/
abbrev Region (V : Type*) := V → Bool

/-- The area (total cut weight) of the surface bounding a bulk region. -/
def cutWeight (G : BulkGraph V) (f : Region V) : ℝ :=
  (∑ u, ∑ v, (sepBit (f u) (f v) : ℝ) * G.weight u v) / 2

lemma cutWeight_nonneg (G : BulkGraph V) (f : Region V) : 0 ≤ cutWeight G f := by
  apply div_nonneg _ (by norm_num)
  exact sum_nonneg fun u _ => sum_nonneg fun v _ =>
    mul_nonneg (by positivity) (G.weight_nonneg u v)

@[simp] lemma cutWeight_const (G : BulkGraph V) (b : Bool) :
    cutWeight G (fun _ => b) = 0 := by
  simp [cutWeight]

/-- Complementary regions have the same bounding area. -/
lemma cutWeight_compl (G : BulkGraph V) (f : Region V) :
    cutWeight G (fun v => !(f v)) = cutWeight G f := by
  simp [cutWeight, sepBit_not]

/-- **Recombination principle.**  If a family of regions `H` separates each pair
of bulk cells at most as often as the family `F` does, then the total area of
the `H`-surfaces is at most the total area of the `F`-surfaces. -/
lemma cutWeight_comb (G : BulkGraph V) {m n : ℕ} (F : Fin m → Region V)
    (H : Fin n → Region V)
    (h : ∀ u v : V, G.weight u v ≠ 0 →
      ∑ i, sepBit (H i u) (H i v) ≤ ∑ j, sepBit (F j u) (F j v)) :
    ∑ i, cutWeight G (H i) ≤ ∑ j, cutWeight G (F j) := by
  have key : ∀ u v : V,
      (∑ i, (sepBit (H i u) (H i v) : ℝ)) * G.weight u v
        ≤ (∑ j, (sepBit (F j u) (F j v) : ℝ)) * G.weight u v := by
    intro u v
    rcases eq_or_ne (G.weight u v) 0 with hw | hw
    · simp [hw]
    refine mul_le_mul_of_nonneg_right ?_ (G.weight_nonneg u v)
    exact_mod_cast (Nat.cast_le (α := ℝ)).2 (h u v hw)
  have expand : ∀ {k : ℕ} (K : Fin k → Region V),
      ∑ i, cutWeight G (K i)
        = (∑ u, ∑ v, (∑ i, (sepBit (K i u) (K i v) : ℝ)) * G.weight u v) / 2 := by
    intro k K
    simp only [cutWeight]
    rw [← sum_div]
    congr 1
    rw [sum_comm]
    refine sum_congr rfl fun u _ => ?_
    rw [sum_comm]
    refine sum_congr rfl fun v _ => ?_
    rw [sum_mul]
  rw [expand F, expand H]
  have : ∑ u, ∑ v, (∑ i, (sepBit (H i u) (H i v) : ℝ)) * G.weight u v
      ≤ ∑ u, ∑ v, (∑ j, (sepBit (F j u) (F j v) : ℝ)) * G.weight u v :=
    sum_le_sum fun u _ => sum_le_sum fun v _ => key u v
  linarith

/-- Submodularity of the cut function of a weighted graph. -/
theorem cutWeight_submodular (G : BulkGraph V) (f g : Region V) :
    cutWeight G (fun v => f v && g v) + cutWeight G (fun v => f v || g v)
      ≤ cutWeight G f + cutWeight G g := by
  have := cutWeight_comb G ![f, g] ![fun v => f v && g v, fun v => f v || g v]
    (by
      intro u v _
      simp only [Fin.sum_univ_two, Matrix.cons_val_zero, Matrix.cons_val_one]
      exact sepBit_submodular (f u) (g u) (f v) (g v))
  simpa [Fin.sum_univ_two] using this

/-- **Monogamy recombination for cut areas.**  Given three bulk regions, the
three minority regions together with their union have total area at most the
total area of the three original regions. -/
theorem cutWeight_mmi (G : BulkGraph V) (f g h : Region V) :
    cutWeight G (fun v => f v && g v && !(h v))
      + cutWeight G (fun v => f v && h v && !(g v))
      + cutWeight G (fun v => g v && h v && !(f v))
      + cutWeight G (fun v => f v || g v || h v)
      ≤ cutWeight G f + cutWeight G g + cutWeight G h := by
  have := cutWeight_comb G ![f, g, h]
    ![fun v => f v && g v && !(h v), fun v => f v && h v && !(g v),
      fun v => g v && h v && !(f v), fun v => f v || g v || h v]
    (by
      intro u v _
      simp only [Fin.sum_univ_three, Fin.sum_univ_four, Matrix.cons_val_zero,
        Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons,
        Matrix.cons_val_three]
      exact sepBit_mmi (f u) (g u) (h u) (f v) (g v) (h v))
  simpa [Fin.sum_univ_three, Fin.sum_univ_four, add_assoc] using this

/-! ## Holographic models and min-cut entropy -/

variable [DecidableEq V]

/-- A holographic model: a bulk geometry together with a distinguished set of
boundary cells carrying the quantum degrees of freedom. -/
structure HoloModel (V : Type*) [Fintype V] extends BulkGraph V where
  /-- The boundary cells. -/
  bdry : V → Bool

/-- A bulk region is *admissible* for the boundary region `A` when it is
homologous to `A`, i.e. its trace on the boundary is exactly `A`. -/
def Admissible (M : HoloModel V) (A f : Region V) : Prop :=
  ∀ v, M.bdry v = true → f v = A v

instance (M : HoloModel V) (A f : Region V) : Decidable (Admissible M A f) := by
  unfold Admissible; infer_instance

/-- The finite set of bulk regions homologous to `A`. -/
def admSet (M : HoloModel V) (A : Region V) : Finset (Region V) :=
  univ.filter (fun f => Admissible M A f)

lemma mem_admSet {M : HoloModel V} {A f : Region V} :
    f ∈ admSet M A ↔ Admissible M A f := by
  simp [admSet]

lemma admSet_nonempty (M : HoloModel V) (A : Region V) : (admSet M A).Nonempty :=
  ⟨A, mem_admSet.2 fun _ _ => rfl⟩

/-- **Ryu–Takayanagi entropy.**  The entanglement entropy of a boundary region
is the area of the minimal bulk surface homologous to it. -/
def entropy (M : HoloModel V) (A : Region V) : ℝ :=
  (admSet M A).inf' (admSet_nonempty M A) (cutWeight M.toBulkGraph)

lemma entropy_le_of_admissible {M : HoloModel V} {A f : Region V}
    (hf : Admissible M A f) : entropy M A ≤ cutWeight M.toBulkGraph f :=
  inf'_le _ (mem_admSet.2 hf)

lemma exists_minimal_surface (M : HoloModel V) (A : Region V) :
    ∃ f, Admissible M A f ∧ entropy M A = cutWeight M.toBulkGraph f := by
  obtain ⟨f, hf, hval⟩ := exists_mem_eq_inf' (admSet_nonempty M A) (cutWeight M.toBulkGraph)
  exact ⟨f, mem_admSet.1 hf, hval⟩

lemma entropy_nonneg (M : HoloModel V) (A : Region V) : 0 ≤ entropy M A := by
  obtain ⟨f, _, hval⟩ := exists_minimal_surface M A
  rw [hval]; exact cutWeight_nonneg _ _

/-- The empty boundary region has zero entropy. -/
@[simp] lemma entropy_empty (M : HoloModel V) : entropy M (fun _ => false) = 0 := by
  refine le_antisymm ?_ (entropy_nonneg _ _)
  simpa using entropy_le_of_admissible (M := M) (A := fun _ => false)
    (f := fun _ => false) (fun _ _ => rfl)

/-- The global state is pure: the entropy of the whole boundary vanishes. -/
@[simp] lemma entropy_full (M : HoloModel V) : entropy M M.bdry = 0 := by
  refine le_antisymm ?_ (entropy_nonneg _ _)
  have : Admissible M M.bdry (fun _ => true) := fun v hv => hv.symm
  simpa using entropy_le_of_admissible this

/-- Entropy only depends on a boundary region through its restriction to the
boundary. -/
lemma entropy_congr_bdry (M : HoloModel V) (A B : Region V)
    (h : ∀ v, M.bdry v = true → A v = B v) : entropy M A = entropy M B := by
  refine le_antisymm ?_ ?_
  · obtain ⟨f, hf, hval⟩ := exists_minimal_surface M B
    rw [hval]
    exact entropy_le_of_admissible fun v hv => (hf v hv).trans (h v hv).symm
  · obtain ⟨f, hf, hval⟩ := exists_minimal_surface M A
    rw [hval]
    exact entropy_le_of_admissible fun v hv => (hf v hv).trans (h v hv)

/-- **Purity / Araki–Lieb complementarity**: a region and its boundary
complement carry the same entropy. -/
theorem entropy_complement (M : HoloModel V) (A : Region V) :
    entropy M (fun v => M.bdry v && !(A v)) = entropy M A := by
  have main : ∀ B : Region V,
      entropy M (fun v => M.bdry v && !(B v)) ≤ entropy M B := by
    intro B
    obtain ⟨f, hf, hval⟩ := exists_minimal_surface M B
    have hadm : Admissible M (fun v => M.bdry v && !(B v)) (fun v => !(f v)) := by
      intro v hv
      show (!(f v)) = (M.bdry v && !(B v))
      simp [hf v hv, hv]
    calc entropy M (fun v => M.bdry v && !(B v))
        ≤ cutWeight M.toBulkGraph (fun v => !(f v)) := entropy_le_of_admissible hadm
      _ = cutWeight M.toBulkGraph f := cutWeight_compl _ _
      _ = entropy M B := hval.symm
  refine le_antisymm (main A) ?_
  have h2 := main (fun v => M.bdry v && !(A v))
  have : (fun v => M.bdry v && !(M.bdry v && !(A v))) = fun v => M.bdry v && A v := by
    funext v; cases M.bdry v <;> cases A v <;> rfl
  rw [this] at h2
  have h3 : entropy M (fun v => M.bdry v && A v) = entropy M A :=
    entropy_congr_bdry M _ A (fun v hv => by simp [hv])
  linarith

/-! ## The holographic entropy inequalities -/

/-- **Subadditivity**: `S(A ∪ B) ≤ S(A) + S(B)`. -/
theorem entropy_subadditive (M : HoloModel V) (A B : Region V) :
    entropy M (fun v => A v || B v) ≤ entropy M A + entropy M B := by
  obtain ⟨f, hf, hfval⟩ := exists_minimal_surface M A
  obtain ⟨g, hg, hgval⟩ := exists_minimal_surface M B
  have hadm : Admissible M (fun v => A v || B v) (fun v => f v || g v) := by
    intro v hv
    show (f v || g v) = (A v || B v)
    rw [hf v hv, hg v hv]
  have hsub := cutWeight_submodular M.toBulkGraph f g
  have hnn := cutWeight_nonneg M.toBulkGraph (fun v => f v && g v)
  have := entropy_le_of_admissible hadm
  rw [hfval, hgval]
  linarith

/-- **Strong subadditivity**: `S(A∪B) + S(B∪C) ≥ S(A∪B∪C) + S(B)` for disjoint
boundary regions `A` and `C`. -/
theorem entropy_strong_subadditive (M : HoloModel V) (A B C : Region V)
    (hAC : ∀ v, A v = true → C v = false) :
    entropy M (fun v => A v || B v || C v) + entropy M B
      ≤ entropy M (fun v => A v || B v) + entropy M (fun v => B v || C v) := by
  obtain ⟨f, hf, hfval⟩ := exists_minimal_surface M (fun v => A v || B v)
  obtain ⟨g, hg, hgval⟩ := exists_minimal_surface M (fun v => B v || C v)
  have hunion : Admissible M (fun v => A v || B v || C v) (fun v => f v || g v) := by
    intro v hv
    show (f v || g v) = (A v || B v || C v)
    rw [hf v hv, hg v hv]
    cases hA : A v <;> cases hB : B v <;> cases hC : C v <;> simp_all
  have hinter : Admissible M B (fun v => f v && g v) := by
    intro v hv
    show (f v && g v) = B v
    rw [hf v hv, hg v hv]
    cases hA : A v <;> cases hB : B v <;> cases hC : C v <;> simp_all
  have h1 := entropy_le_of_admissible hunion
  have h2 := entropy_le_of_admissible hinter
  have hsub := cutWeight_submodular M.toBulkGraph f g
  rw [hfval, hgval]
  linarith

/-- **Monogamy of mutual information (MMI)**, the characteristic holographic
inequality: for pairwise disjoint boundary regions,
`S(A∪B) + S(B∪C) + S(A∪C) ≥ S(A) + S(B) + S(C) + S(A∪B∪C)`. -/
theorem entropy_monogamy (M : HoloModel V) (A B C : Region V)
    (hAB : ∀ v, A v = true → B v = false)
    (hBC : ∀ v, B v = true → C v = false)
    (hAC : ∀ v, A v = true → C v = false) :
    entropy M A + entropy M B + entropy M C + entropy M (fun v => A v || B v || C v)
      ≤ entropy M (fun v => A v || B v) + entropy M (fun v => B v || C v)
        + entropy M (fun v => A v || C v) := by
  obtain ⟨f, hf, hfval⟩ := exists_minimal_surface M (fun v => A v || B v)
  obtain ⟨g, hg, hgval⟩ := exists_minimal_surface M (fun v => B v || C v)
  obtain ⟨h, hh, hhval⟩ := exists_minimal_surface M (fun v => A v || C v)
  have hA : Admissible M A (fun v => f v && h v && !(g v)) := by
    intro v hv
    show (f v && h v && !(g v)) = A v
    rw [hf v hv, hg v hv, hh v hv]
    cases hA' : A v <;> cases hB' : B v <;> cases hC' : C v <;> simp_all
  have hB : Admissible M B (fun v => f v && g v && !(h v)) := by
    intro v hv
    show (f v && g v && !(h v)) = B v
    rw [hf v hv, hg v hv, hh v hv]
    cases hA' : A v <;> cases hB' : B v <;> cases hC' : C v <;> simp_all
  have hC : Admissible M C (fun v => g v && h v && !(f v)) := by
    intro v hv
    show (g v && h v && !(f v)) = C v
    rw [hf v hv, hg v hv, hh v hv]
    cases hA' : A v <;> cases hB' : B v <;> cases hC' : C v <;> simp_all
  have hABC : Admissible M (fun v => A v || B v || C v) (fun v => f v || g v || h v) := by
    intro v hv
    show (f v || g v || h v) = (A v || B v || C v)
    rw [hf v hv, hg v hv, hh v hv]
    cases hA' : A v <;> cases hB' : B v <;> cases hC' : C v <;> simp_all
  have e1 := entropy_le_of_admissible hA
  have e2 := entropy_le_of_admissible hB
  have e3 := entropy_le_of_admissible hC
  have e4 := entropy_le_of_admissible hABC
  have key := cutWeight_mmi M.toBulkGraph f g h
  rw [hfval, hgval, hhval]
  linarith

/-! ## Mutual information -/

/-- Mutual information of two boundary regions. -/
def mutualInfo (M : HoloModel V) (A B : Region V) : ℝ :=
  entropy M A + entropy M B - entropy M (fun v => A v || B v)

lemma mutualInfo_nonneg (M : HoloModel V) (A B : Region V) :
    0 ≤ mutualInfo M A B := by
  have := entropy_subadditive M A B
  simp only [mutualInfo]
  linarith

lemma mutualInfo_comm (M : HoloModel V) (A B : Region V) :
    mutualInfo M A B = mutualInfo M B A := by
  simp only [mutualInfo]
  have : (fun v => A v || B v) = fun v => B v || A v := by
    funext v; exact Bool.or_comm _ _
  rw [this]; ring

/-- Tripartite information, `I₃ = I(A:B) + I(A:C) - I(A:B∪C)`. -/
def tripartiteInfo (M : HoloModel V) (A B C : Region V) : ℝ :=
  mutualInfo M A B + mutualInfo M A C - mutualInfo M A (fun v => B v || C v)

/-- **Monogamy of mutual information**, restated: `I(A:B∪C) ≥ I(A:B) + I(A:C)`,
i.e. the tripartite information of a holographic state is nonpositive.  This is
the inequality that distinguishes geometric (holographic) entanglement from
generic quantum entanglement. -/
theorem tripartiteInfo_nonpos (M : HoloModel V) (A B C : Region V)
    (hAB : ∀ v, A v = true → B v = false)
    (hBC : ∀ v, B v = true → C v = false)
    (hAC : ∀ v, A v = true → C v = false) :
    tripartiteInfo M A B C ≤ 0 := by
  have hmono := entropy_monogamy M A B C hAB hBC hAC
  have hassoc : (fun v => A v || (B v || C v)) = fun v => A v || B v || C v := by
    funext v; exact (Bool.or_assoc _ _ _).symm
  simp only [tripartiteInfo, mutualInfo, hassoc]
  linarith

end EmergentGeometry