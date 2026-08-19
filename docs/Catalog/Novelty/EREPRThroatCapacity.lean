import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EREPRBridge

/-!
# Throat capacity of an Einstein–Rosen bridge and the `I ≤ 2 E_W` bound

This file adds a genuinely *geometric* observable to the min-cut model of
`Novelty.EmergentGeometryEntropyCone`: the **throat capacity**

  `throat G A B = min { area(σ) : σ ⊇ A, σ ∩ B = ∅ }`,

the smallest bulk surface that has to be cut in order to disconnect the bulk
region `A` from the bulk region `B`.  Unlike the entropy `S(A)` this is *not*
constrained to be homologous to a boundary region: it measures the cross-section
of the Einstein–Rosen bridge joining `A` to `B` (the discrete analogue of the
entanglement wedge cross-section `E_W`).

Main results:

* `cutWeight_eq_zero_of_closed`, `weight_eq_zero_of_cutWeight_eq_zero`:
  a bulk surface has zero area iff no positive-weight edge crosses it.
* `throat_pos_iff_bulkPath` : **the throat capacity of a pair of cells is
  positive exactly when an Einstein–Rosen bridge joins them.**  Geometric
  connectivity is detected by a single real number.
* `mutualInfo_le_two_throat` : **`I(A:B) ≤ 2 · throat(A,B)`**, the toy-model
  form of the holographic inequality `I(A:B) ≤ 2 E_W(A:B)`: entanglement between
  two boundary regions is bounded by the cross-section of the bridge that
  connects them.  Its combinatorial engine is the new pointwise Boolean
  inequality `sepBit_split`.
* `throat_le_entropy`, `throat_sandwich` : `I(A:B)/2 ≤ throat(A,B) ≤ min(S A, S B)`.
* `ER_EPR_throat` : positive mutual information of two boundary cells forces a
  positive-capacity Einstein–Rosen bridge between them — ER = EPR with a
  quantitative bound, strengthening `bridge_of_mutualInfo_pos`.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer).  In holography the entanglement wedge cross-section
`E_W` obeys `E_W ≥ I/2`.  If the slogan "ER=EPR" is to have content beyond mere
connectivity, the *width* of the bridge should bound the *amount* of
entanglement, not just its (non)vanishing.

EXPERIMENT (Experimenter).  We defined `throat` as an unconstrained min-cut and
looked for a recombination of Boolean regions realising the bound.  The winning
combination splits the minimal surface `g` of `A ∪ B` along the minimal
separating surface `σ`: `X = σ ∧ g` is homologous to `A`, `Y = ¬σ ∧ g` to `B`.
The needed pointwise fact is `sepBit_split`, i.e.
`sep(a∧b) + sep(¬a∧b) ≤ sep(b) + 2 sep(a)`, a 16-case Boolean identity; note the
factor `2` is necessary (take `a₁ = true, a₂ = false, b₁ = b₂ = true`, where the
left side is `2` and `sep b = 0`).

ANALYSIS (Analyst).  The bound is *tight*: for a single throat of weight `w`
between two boundary cells one has `throat = w` and `I = 2w`.  Combined with
`throat ≤ min(S A, S B)` we obtain a two-sided sandwich, so in the toy model the
bridge cross-section is squeezed between half the mutual information and the
entropies of its two mouths.

CRITIQUE (Critic).  `throat` is a `dite` over a possibly empty family; all
statements that use its minimality carry the disjointness hypothesis that makes
the family nonempty, and none of them is vacuous (`pairModel_throat` exhibits a
model where every hypothesis holds and the value is nonzero).
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Surfaces separating two bulk regions -/

private lemma bool_true_of_ne_false {b : Bool} (h : ¬ b = false) : b = true := by
  cases b
  · exact absurd rfl h
  · rfl

private lemma bool_false_of_ne_true {b : Bool} (h : ¬ b = true) : b = false := by
  cases b
  · rfl
  · exact absurd rfl h

/-- The bulk region `f` separates `A` from `B`: it contains all of `A` and none
of `B`. -/
def Separates (A B f : Region V) : Prop :=
  (∀ v, A v = true → f v = true) ∧ (∀ v, B v = true → f v = false)

instance (A B f : Region V) : Decidable (Separates A B f) := by
  unfold Separates; infer_instance

/-- The finite family of bulk regions separating `A` from `B`. -/
def sepSet (A B : Region V) : Finset (Region V) :=
  univ.filter (fun f => Separates A B f)

lemma mem_sepSet {A B f : Region V} : f ∈ sepSet A B ↔ Separates A B f := by
  simp [sepSet]

/-- `A` and `B` are disjoint regions. -/
def Disj (A B : Region V) : Prop := ∀ v, A v = true → B v = false

omit [Fintype V] [DecidableEq V] in
/-- Disjointness of Boolean regions is symmetric. -/
lemma Disj.symm {A B : Region V} (h : Disj A B) : Disj B A := fun v hv =>
  bool_false_of_ne_true fun hA => by rw [h v hA] at hv; exact Bool.noConfusion hv

lemma sepSet_nonempty {A B : Region V} (h : Disj A B) : (sepSet A B).Nonempty :=
  ⟨A, mem_sepSet.2 ⟨fun _ hv => hv, fun v hv => h.symm v hv⟩⟩

/-- **Throat capacity**: the area of the smallest bulk surface separating `A`
from `B`.  This is the cross-section of the Einstein–Rosen bridge joining the
two regions. -/
def throat (G : BulkGraph V) (A B : Region V) : ℝ :=
  if h : (sepSet A B).Nonempty then (sepSet A B).inf' h (cutWeight G) else 0

lemma throat_le_of_separates {G : BulkGraph V} {A B f : Region V}
    (hf : Separates A B f) : throat G A B ≤ cutWeight G f := by
  have hne : (sepSet A B).Nonempty := ⟨f, mem_sepSet.2 hf⟩
  rw [throat, dif_pos hne]
  exact inf'_le _ (mem_sepSet.2 hf)

lemma exists_min_throat_surface (G : BulkGraph V) {A B : Region V} (h : Disj A B) :
    ∃ f, Separates A B f ∧ throat G A B = cutWeight G f := by
  obtain ⟨f, hf, hval⟩ := exists_mem_eq_inf' (sepSet_nonempty h) (cutWeight G)
  exact ⟨f, mem_sepSet.1 hf, by rw [throat, dif_pos (sepSet_nonempty h)]; exact hval⟩

lemma throat_nonneg (G : BulkGraph V) (A B : Region V) : 0 ≤ throat G A B := by
  rw [throat]
  split
  · rename_i h
    obtain ⟨f, hf, hval⟩ := exists_mem_eq_inf' h (cutWeight G)
    rw [hval]
    exact cutWeight_nonneg _ _
  · exact le_refl 0

/-- The throat capacity is symmetric: complementing a separating surface
exchanges the two sides without changing its area. -/
lemma throat_comm (G : BulkGraph V) (A B : Region V) :
    throat G A B = throat G B A := by
  have key : ∀ X Y : Region V, Disj X Y → throat G Y X ≤ throat G X Y := by
    intro X Y hXY
    obtain ⟨f, hf, hval⟩ := exists_min_throat_surface G hXY
    have hsep : Separates Y X (fun v => !(f v)) := by
      refine ⟨fun v hv => ?_, fun v hv => ?_⟩
      · show (!(f v)) = true
        rw [hf.2 v hv]; rfl
      · show (!(f v)) = false
        rw [hf.1 v hv]; rfl
    calc throat G Y X ≤ cutWeight G (fun v => !(f v)) := throat_le_of_separates hsep
      _ = cutWeight G f := cutWeight_compl _ _
      _ = throat G X Y := hval.symm
  by_cases hAB : Disj A B
  · exact le_antisymm (key B A hAB.symm) (key A B hAB)
  · have h1 : ¬ (sepSet A B).Nonempty := by
      rintro ⟨f, hf⟩
      obtain ⟨h1, h2⟩ := mem_sepSet.1 hf
      exact hAB fun v hv => bool_false_of_ne_true fun hBv => by
        have e1 := h1 v hv
        have e2 := h2 v hBv
        rw [e1] at e2
        exact Bool.noConfusion e2
    have h2 : ¬ (sepSet B A).Nonempty := by
      rintro ⟨f, hf⟩
      obtain ⟨h1, h2⟩ := mem_sepSet.1 hf
      exact hAB fun v hv => bool_false_of_ne_true fun hBv => by
        have e1 := h1 v hBv
        have e2 := h2 v hv
        rw [e1] at e2
        exact Bool.noConfusion e2
    rw [throat, throat, dif_neg h1, dif_neg h2]

/-! ## Monotonicity in the amount of entanglement -/

omit [DecidableEq V] in
/-- Areas are monotone in the geometry. -/
theorem cutWeight_mono {G H : BulkGraph V} (h : ∀ x y, G.weight x y ≤ H.weight x y)
    (f : Region V) : cutWeight G f ≤ cutWeight H f := by
  rw [cutWeight, cutWeight]
  refine div_le_div_of_nonneg_right ?_ (by norm_num) |>.trans_eq rfl
  refine sum_le_sum fun x _ => sum_le_sum fun y _ => ?_
  exact mul_le_mul_of_nonneg_left (h x y) (by positivity)

/-- **More entanglement means a wider bridge.**  Throat capacities are monotone
in the areas of the geometry. -/
theorem throat_mono {G H : BulkGraph V} (h : ∀ x y, G.weight x y ≤ H.weight x y)
    {A B : Region V} (hAB : Disj A B) : throat G A B ≤ throat H A B := by
  obtain ⟨σ, hσ, hval⟩ := exists_min_throat_surface H hAB
  rw [hval]
  exact le_trans (throat_le_of_separates hσ) (cutWeight_mono h σ)

/-! ## Zero-area surfaces and bulk connectivity -/

omit [DecidableEq V] in
/-- A bulk surface whose two sides are joined by no positive weight has zero
area. -/
lemma cutWeight_eq_zero_of_closed (G : BulkGraph V) (f : Region V)
    (h : ∀ x y, f x = true → f y = false → G.weight x y = 0) :
    cutWeight G f = 0 := by
  have hterm : ∀ x y : V, (sepBit (f x) (f y) : ℝ) * G.weight x y = 0 := by
    intro x y
    cases hx : f x <;> cases hy : f y
    · simp [sepBit]
    · rw [(G.weight_symm x y).trans (h y x hy hx)]; ring
    · rw [h x y hx hy]; ring
    · simp [sepBit]
  simp [cutWeight, hterm]

omit [DecidableEq V] in
/-- Conversely, if a bulk surface has zero area then no positive weight crosses
it. -/
lemma weight_eq_zero_of_cutWeight_eq_zero {G : BulkGraph V} {f : Region V}
    (h : cutWeight G f = 0) {x y : V} (hx : f x = true) (hy : f y = false) :
    G.weight x y = 0 := by
  have hnn : ∀ u ∈ (univ : Finset V), (0:ℝ) ≤ ∑ v, (sepBit (f u) (f v) : ℝ) * G.weight u v :=
    fun u _ => sum_nonneg fun v _ => mul_nonneg (by positivity) (G.weight_nonneg u v)
  have hsum : ∑ u, ∑ v, (sepBit (f u) (f v) : ℝ) * G.weight u v = 0 := by
    have := h
    rw [cutWeight, div_eq_zero_iff] at this
    rcases this with h' | h'
    · exact h'
    · norm_num at h'
  have hx' := (sum_eq_zero_iff_of_nonneg hnn).1 hsum x (mem_univ x)
  have hnn2 : ∀ v ∈ (univ : Finset V), (0:ℝ) ≤ (sepBit (f x) (f v) : ℝ) * G.weight x v :=
    fun v _ => mul_nonneg (by positivity) (G.weight_nonneg x v)
  have := (sum_eq_zero_iff_of_nonneg hnn2).1 hx' y (mem_univ y)
  rw [hx, hy] at this
  simpa [sepBit] using this

omit [DecidableEq V] in
/-- A bulk region closed under positive-weight steps contains everything
reachable from it. -/
lemma mem_of_bulkPath {G : BulkGraph V} {f : Region V}
    (hcl : ∀ x y, f x = true → f y = false → G.weight x y = 0) {u v : V}
    (hp : BulkPath G u v) (hu : f u = true) : f v = true := by
  induction hp with
  | refl => exact hu
  | tail _ hstep ih =>
      rename_i b c _
      have hb : f b = true := ih
      by_contra hc
      have hc' : f c = false := bool_false_of_ne_true hc
      have := hcl b c hb hc'
      exact absurd this (ne_of_gt hstep)

/-- **A bridge is exactly a positive throat capacity.**  Two bulk cells are
joined by an Einstein–Rosen bridge if and only if the minimal surface separating
them has positive area. -/
theorem throat_pos_iff_bulkPath (G : BulkGraph V) {u v : V} (huv : u ≠ v) :
    0 < throat G (single u) (single v) ↔ BulkPath G u v := by
  have hdisj : Disj (single u) (single v) := by
    intro x hx
    simp only [single, decide_eq_true_eq] at hx ⊢
    simp [hx, huv]
  constructor
  · intro hpos
    by_contra hnp
    classical
    -- the set of cells reachable from `u` is a zero-area separating surface
    set R : Region V := fun x => if BulkPath G u x then true else false with hR
    have hRtrue : ∀ x, R x = true ↔ BulkPath G u x := by
      intro x
      by_cases h : BulkPath G u x <;> simp [hR, h]
    have hRu : R u = true := (hRtrue u).2 Relation.ReflTransGen.refl
    have hclosed : ∀ x y, R x = true → R y = false → G.weight x y = 0 := by
      intro x y hx hy
      by_contra hw
      have hpos' : 0 < G.weight x y := lt_of_le_of_ne (G.weight_nonneg x y) (Ne.symm hw)
      have hRy : R y = true := (hRtrue y).2 (((hRtrue x).1 hx).tail hpos')
      rw [hRy] at hy
      exact Bool.noConfusion hy
    have hsep : Separates (single u) (single v) R := by
      refine ⟨fun x hx => ?_, fun x hx => ?_⟩
      · simp only [single, decide_eq_true_eq] at hx
        rw [hx]; exact hRu
      · simp only [single, decide_eq_true_eq] at hx
        subst hx
        exact bool_false_of_ne_true fun h => hnp ((hRtrue x).1 h)
    have := throat_le_of_separates (G := G) hsep
    rw [cutWeight_eq_zero_of_closed G R hclosed] at this
    linarith
  · intro hpath
    rcases lt_or_eq_of_le (throat_nonneg G (single u) (single v)) with h | h
    · exact h
    · exfalso
      obtain ⟨f, hf, hval⟩ := exists_min_throat_surface G hdisj
      have hcut : cutWeight G f = 0 := by rw [← hval, ← h]
      have hfu : f u = true := hf.1 u (by simp [single])
      have hfv : f v = false := hf.2 v (by simp [single])
      have hcl : ∀ x y, f x = true → f y = false → G.weight x y = 0 :=
        fun x y hx hy => weight_eq_zero_of_cutWeight_eq_zero hcut hx hy
      rw [mem_of_bulkPath hcl hpath hfu] at hfv
      exact Bool.noConfusion hfv

/-! ## The bound `I(A:B) ≤ 2 · throat(A,B)` -/

/-- **Pointwise splitting inequality.**  Splitting a region `b` along a region
`a` costs at most the separations of `b` plus twice those of `a`.  The factor
`2` is sharp (`a₁ = true, a₂ = false, b₁ = b₂ = true`). -/
lemma sepBit_split (a₁ a₂ b₁ b₂ : Bool) :
    sepBit (a₁ && b₁) (a₂ && b₂) + sepBit (!a₁ && b₁) (!a₂ && b₂)
      ≤ sepBit b₁ b₂ + 2 * sepBit a₁ a₂ := by
  revert a₁ a₂ b₁ b₂; decide

omit [DecidableEq V] in
/-- Areas version of the splitting inequality: cutting a region `g` into its
parts inside and outside `σ` costs at most `area(g) + 2 · area(σ)`. -/
theorem cutWeight_split (G : BulkGraph V) (σ g : Region V) :
    cutWeight G (fun v => σ v && g v) + cutWeight G (fun v => !(σ v) && g v)
      ≤ cutWeight G g + 2 * cutWeight G σ := by
  have h := cutWeight_comb G ![g, σ, σ]
    ![fun v => σ v && g v, fun v => !(σ v) && g v]
    (by
      intro u v _
      simp only [Fin.sum_univ_two, Fin.sum_univ_three, Matrix.cons_val_zero,
        Matrix.cons_val_one, Matrix.head_cons, Matrix.cons_val_two, Matrix.tail_cons]
      have := sepBit_split (σ u) (σ v) (g u) (g v)
      omega)
  simpa [Fin.sum_univ_two, Fin.sum_univ_three, two_mul, add_assoc] using h

/-- **Entanglement is bounded by the width of the bridge.**  For disjoint
boundary regions, `I(A:B) ≤ 2 · throat(A,B)`: the toy-model version of the
holographic inequality `I(A:B) ≤ 2 E_W(A:B)`. -/
theorem mutualInfo_le_two_throat (M : HoloModel V) {A B : Region V} (hAB : Disj A B) :
    mutualInfo M A B ≤ 2 * throat M.toBulkGraph A B := by
  obtain ⟨σ, hσ, hσval⟩ := exists_min_throat_surface M.toBulkGraph hAB
  obtain ⟨g, hg, hgval⟩ := exists_minimal_surface M (fun v => A v || B v)
  have hX : Admissible M A (fun v => σ v && g v) := by
    intro v hv
    have hgv : g v = (A v || B v) := hg v hv
    show (σ v && g v) = A v
    rw [hgv]
    by_cases hA : A v = true
    · simp [hσ.1 v hA, hA]
    · have hA' : A v = false := bool_false_of_ne_true hA
      by_cases hB : B v = true
      · simp [hσ.2 v hB, hA']
      · have hB' : B v = false := bool_false_of_ne_true hB
        simp [hA', hB']
  have hY : Admissible M B (fun v => !(σ v) && g v) := by
    intro v hv
    have hgv : g v = (A v || B v) := hg v hv
    show (!(σ v) && g v) = B v
    rw [hgv]
    by_cases hA : A v = true
    · simp [hσ.1 v hA, hAB v hA]
    · have hA' : A v = false := bool_false_of_ne_true hA
      by_cases hB : B v = true
      · simp [hσ.2 v hB, hB]
      · have hB' : B v = false := bool_false_of_ne_true hB
        simp [hA', hB']
  have e1 := entropy_le_of_admissible hX
  have e2 := entropy_le_of_admissible hY
  have hsplit := cutWeight_split M.toBulkGraph σ g
  simp only [mutualInfo]
  rw [hgval, hσval]
  linarith

/-- The bridge is no wider than the entropy of either of its mouths. -/
theorem throat_le_entropy (M : HoloModel V) {A B : Region V}
    (hA : ∀ v, A v = true → M.bdry v = true) (hB : ∀ v, B v = true → M.bdry v = true)
    (hAB : Disj A B) :
    throat M.toBulkGraph A B ≤ entropy M A := by
  obtain ⟨f, hf, hval⟩ := exists_minimal_surface M A
  have hsep : Separates A B f := by
    refine ⟨fun v hv => ?_, fun v hv => ?_⟩
    · rw [hf v (hA v hv), hv]
    · rw [hf v (hB v hv)]
      exact hAB.symm v hv
  rw [hval]
  exact throat_le_of_separates hsep

/-- **The ER=EPR sandwich.**  Half the mutual information of two disjoint
boundary regions is at most the cross-section of the Einstein–Rosen bridge that
joins them, which in turn is at most the entropy of either mouth. -/
theorem throat_sandwich (M : HoloModel V) {A B : Region V}
    (hA : ∀ v, A v = true → M.bdry v = true) (hB : ∀ v, B v = true → M.bdry v = true)
    (hAB : Disj A B) :
    mutualInfo M A B / 2 ≤ throat M.toBulkGraph A B ∧
      throat M.toBulkGraph A B ≤ min (entropy M A) (entropy M B) := by
  have hBA : Disj B A := hAB.symm
  refine ⟨by have := mutualInfo_le_two_throat M hAB; linarith, le_min ?_ ?_⟩
  · exact throat_le_entropy M hA hB hAB
  · rw [throat_comm]
    exact throat_le_entropy M hB hA hBA

/-- **ER = EPR, quantitative form.**  Two entangled boundary cells are joined by
an Einstein–Rosen bridge whose cross-section is at least half their mutual
information. -/
theorem ER_EPR_throat (M : HoloModel V) {u v : V} (huv : u ≠ v)
    (h : 0 < mutualInfo M (single u) (single v)) :
    0 < throat M.toBulkGraph (single u) (single v) ∧
      BulkPath M.toBulkGraph u v ∧
      mutualInfo M (single u) (single v) / 2
        ≤ throat M.toBulkGraph (single u) (single v) := by
  have hdisj : Disj (single u) (single v) := by
    intro x hx
    simp only [single, decide_eq_true_eq] at hx ⊢
    simp [hx, huv]
  have hbound := mutualInfo_le_two_throat M hdisj
  have hpos : 0 < throat M.toBulkGraph (single u) (single v) := by linarith
  exact ⟨hpos, (throat_pos_iff_bulkPath M.toBulkGraph huv).1 hpos, by linarith⟩

/-! ## Sharpness: a single throat saturates the bound -/

/-- In the one-throat two-cell model the bridge cross-section is exactly the
throat weight, so the bound `I ≤ 2 · throat` is an equality. -/
theorem pairModel_throat (w : ℝ) (hw : 0 ≤ w) :
    throat (pairModel w hw).toBulkGraph (single 0) (single 1) = w ∧
      mutualInfo (pairModel w hw) (single 0) (single 1)
        = 2 * throat (pairModel w hw).toBulkGraph (single 0) (single 1) := by
  have hdisj : Disj (single (0 : Fin 2)) (single 1) := by
    intro x hx
    fin_cases x <;> simp_all [single]
  have hle : throat (pairModel w hw).toBulkGraph (single 0) (single 1) ≤ w := by
    have hsep : Separates (single (0 : Fin 2)) (single 1) (single 0) :=
      ⟨fun _ hv => hv, fun x hx => by fin_cases x <;> simp_all [single]⟩
    have := throat_le_of_separates (G := (pairModel w hw).toBulkGraph) hsep
    have hcut : cutWeight (pairModel w hw).toBulkGraph (single (0 : Fin 2)) = w := by
      simp [cutWeight, single, pairModel, Fin.sum_univ_two, sepBit]
    rwa [hcut] at this
  have hge : w ≤ throat (pairModel w hw).toBulkGraph (single 0) (single 1) := by
    have hI := pairModel_mutualInfo w hw
    have := mutualInfo_le_two_throat (pairModel w hw) hdisj
    rw [hI] at this
    linarith
  have heq : throat (pairModel w hw).toBulkGraph (single 0) (single 1) = w :=
    le_antisymm hle hge
  exact ⟨heq, by rw [heq, pairModel_mutualInfo w hw]⟩

end EmergentGeometry