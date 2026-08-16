import Mathlib
import Novelty.EmergentGeometryEntropyCone
import Novelty.EREqualsEPR

/-!
# ER = EPR: bulk bridges are exactly boundary entanglement

Building on `Novelty.EmergentGeometryEntropyCone` (min-cut / Ryu–Takayanagi
entropies of a finite bulk geometry) and on `Novelty.EREqualsEPR` (the two-qubit
toy model), this file proves the two halves of the ER=EPR correspondence in the
toy setting:

* **Geometry from entanglement** (`weight_eq_half_mutualInfo`,
  `bulk_weights_determined_by_mutualInfo`): in a model without hidden bulk cells
  every edge weight — i.e. the entire bulk metric — is recovered from
  two-point mutual informations, `w(u,v) = I(u:v)/2`.
* **Entanglement forces a bridge** (`mutualInfo_eq_zero_of_no_bridge`,
  `bridge_of_mutualInfo_pos`): two boundary regions with positive mutual
  information *must* be joined by a positive-weight bulk path, an
  Einstein–Rosen bridge; conversely disconnected regions are unentangled
  (their entropies are exactly additive).
* **EPR ⟺ ER for a qubit pair** (`ER_EPR_correspondence`): a real two-qubit
  pure state is entangled if and only if the associated one-throat geometry,
  whose throat weight is the concurrence, contains a bulk bridge between the
  two boundary qubits.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V : Type*} [Fintype V] [DecidableEq V]

/-! ## Boundary regions consisting of one or two cells -/

/-- The one-cell boundary region `{u}`. -/
def single (u : V) : Region V := fun x => decide (x = u)

omit [Fintype V] in
@[simp] lemma single_apply (u x : V) : single u x = decide (x = u) := rfl

/-- A model has no hidden bulk cells when every cell is a boundary cell. -/
def NoBulk (M : HoloModel V) : Prop := ∀ v, M.bdry v = true

lemma entropy_of_noBulk {M : HoloModel V} (h : NoBulk M) (A : Region V) :
    entropy M A = cutWeight M.toBulkGraph A := by
  refine le_antisymm (entropy_le_of_admissible (fun v _ => rfl)) ?_
  obtain ⟨f, hf, hval⟩ := exists_minimal_surface M A
  have : f = A := funext fun v => hf v (h v)
  rw [hval, this]

/-- A Boolean two-point identity: the separation indicators of two disjoint
singletons and of their union differ exactly by the "crossing" indicator. -/
lemma sepBit_two_point (a b c d : Bool) (hab : (a && b) = false) (hcd : (c && d) = false) :
    sepBit a c + sepBit b d
      = sepBit (a || b) (c || d) + (if ((a && d) || (b && c)) = true then 2 else 0) := by
  revert a b c d; decide

/-- The two-point cut combination of a weighted graph isolates a single edge:
`cut({u}) + cut({v}) - cut({u,v}) = 2 w(u,v)`. -/
theorem cutWeight_pair_combination (G : BulkGraph V) {u v : V} (huv : u ≠ v) :
    cutWeight G (single u) + cutWeight G (single v)
        - cutWeight G (fun x => single u x || single v x)
      = 2 * G.weight u v := by
  have hvu : v ≠ u := Ne.symm huv
  have expand : ∀ (f g h : Region V),
      cutWeight G f + cutWeight G g - cutWeight G h
        = (∑ x, ∑ y, ((sepBit (f x) (f y) : ℝ) + sepBit (g x) (g y)
            - sepBit (h x) (h y)) * G.weight x y) / 2 := by
    intro f g h
    simp only [cutWeight]
    rw [← add_div, ← sub_div]
    congr 1
    rw [← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun x _ => ?_
    rw [← Finset.sum_add_distrib, ← Finset.sum_sub_distrib]
    refine Finset.sum_congr rfl fun y _ => ?_
    ring
  have key : ∀ x y : V,
      ((sepBit (single u x) (single u y) : ℝ) + sepBit (single v x) (single v y)
        - sepBit (single u x || single v x) (single u y || single v y))
      = (if (x = u ∧ y = v) ∨ (x = v ∧ y = u) then 2 else 0) := by
    intro x y
    have hx : (single u x && single v x) = false := by
      simp only [single, Bool.and_eq_false_iff, decide_eq_false_iff_not]
      by_cases h : x = u
      · exact Or.inr (fun h' => huv (h ▸ h'))
      · exact Or.inl h
    have hy : (single u y && single v y) = false := by
      simp only [single, Bool.and_eq_false_iff, decide_eq_false_iff_not]
      by_cases h : y = u
      · exact Or.inr (fun h' => huv (h ▸ h'))
      · exact Or.inl h
    have h := sepBit_two_point (single u x) (single v x) (single u y) (single v y) hx hy
    have hR : (if ((single u x && single v y) || (single v x && single u y)) = true
        then (2:ℝ) else 0) = (if (x = u ∧ y = v) ∨ (x = v ∧ y = u) then 2 else 0) := by
      congr 1
      simp [single, Bool.or_eq_true, Bool.and_eq_true]
    have h' : ((sepBit (single u x) (single u y) : ℝ) + sepBit (single v x) (single v y))
        = sepBit (single u x || single v x) (single u y || single v y)
          + (if ((single u x && single v y) || (single v x && single u y)) = true
              then (2:ℝ) else 0) := by
      exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) h
    rw [← hR]
    linarith [h']
  rw [expand]
  have hcongr : ∀ x : V, ∑ y, ((sepBit (single u x) (single u y) : ℝ)
        + sepBit (single v x) (single v y)
        - sepBit (single u x || single v x) (single u y || single v y)) * G.weight x y
      = ∑ y, (if (x = u ∧ y = v) ∨ (x = v ∧ y = u) then (2:ℝ) else 0) * G.weight x y := by
    intro x
    exact Finset.sum_congr rfl fun y _ => by rw [key x y]
  rw [Finset.sum_congr rfl fun x _ => hcongr x]
  have inner : ∀ x : V,
      ∑ y, (if (x = u ∧ y = v) ∨ (x = v ∧ y = u) then (2:ℝ) else 0) * G.weight x y
      = (if x = u then 2 * G.weight u v else 0) + (if x = v then 2 * G.weight v u else 0) := by
    intro x
    by_cases hxu : x = u
    · have hxv : ¬ (x = v) := fun h => huv (hxu ▸ h)
      have step : ∀ y : V,
          (if (x = u ∧ y = v) ∨ (x = v ∧ y = u) then (2:ℝ) else 0) * G.weight x y
          = if y = v then 2 * G.weight u v else 0 := by
        intro y
        by_cases hy : y = v
        · simp [hxu, hy]
        · simp [hxu, hy, huv]
      rw [Finset.sum_congr rfl fun y _ => step y]
      simp [hxu, huv]
    · by_cases hxv : x = v
      · have step : ∀ y : V,
            (if (x = u ∧ y = v) ∨ (x = v ∧ y = u) then (2:ℝ) else 0) * G.weight x y
            = if y = u then 2 * G.weight v u else 0 := by
          intro y
          by_cases hy : y = u
          · simp [hxv, hy]
          · simp [hxv, hy, hvu]
        rw [Finset.sum_congr rfl fun y _ => step y]
        simp [hxv, hvu]
      · simp [hxu, hxv]
  rw [Finset.sum_congr rfl fun x _ => inner x, Finset.sum_add_distrib,
    Finset.sum_ite_eq' Finset.univ u (fun _ => 2 * G.weight u v),
    Finset.sum_ite_eq' Finset.univ v (fun _ => 2 * G.weight v u)]
  simp [G.weight_symm v u]

/-- **Reconstruction of the bulk metric from entanglement.**  In a model with no
hidden bulk cells, each edge weight of the emergent geometry is one half of the
mutual information of the two corresponding boundary cells. -/
theorem weight_eq_half_mutualInfo {M : HoloModel V} (h : NoBulk M) {u v : V}
    (huv : u ≠ v) :
    M.weight u v = mutualInfo M (single u) (single v) / 2 := by
  have h1 := cutWeight_pair_combination M.toBulkGraph huv
  simp only [mutualInfo, entropy_of_noBulk h]
  linarith

/-- **Rigidity**: two bulk geometries on the same boundary that produce the same
two-point mutual informations are the same geometry (off the diagonal). -/
theorem bulk_weights_determined_by_mutualInfo {M N : HoloModel V}
    (hM : NoBulk M) (hN : NoBulk N)
    (h : ∀ u v : V, mutualInfo M (single u) (single v)
      = mutualInfo N (single u) (single v)) :
    ∀ u v : V, u ≠ v → M.weight u v = N.weight u v := by
  intro u v huv
  rw [weight_eq_half_mutualInfo hM huv, weight_eq_half_mutualInfo hN huv, h]

/-! ## Bulk connectivity: Einstein–Rosen bridges -/

/-- Two bulk cells are adjacent when the geometry assigns them positive area. -/
def BulkAdj (G : BulkGraph V) (u v : V) : Prop := 0 < G.weight u v

/-- A bulk bridge: a chain of positive-area steps from `u` to `v`. -/
def BulkPath (G : BulkGraph V) : V → V → Prop := Relation.ReflTransGen (BulkAdj G)

/-- If a set of cells `U` is not joined to its complement by any positive
weight, then entropies of boundary regions inside `U` and outside `U` are
exactly additive: no entanglement across a geometric disconnection. -/
theorem entropy_additive_of_split {M : HoloModel V} {U : Region V}
    (hU : ∀ x y, U x = true → U y = false → M.weight x y = 0)
    (A B : Region V) (hA : ∀ v, A v = true → U v = true)
    (hB : ∀ v, B v = true → U v = false) :
    entropy M (fun v => A v || B v) = entropy M A + entropy M B := by
  refine le_antisymm (entropy_subadditive M A B) ?_
  obtain ⟨f, hf, hval⟩ := exists_minimal_surface M (fun v => A v || B v)
  have hUsym : ∀ x y, M.weight x y ≠ 0 → U y = U x := by
    intro x y hw
    by_contra hne
    cases hx : U x with
    | true =>
      have hy : U y = false := by
        cases hy' : U y with
        | true => exact absurd (hy'.trans hx.symm) hne
        | false => rfl
      exact hw (hU x y hx hy)
    | false =>
      have hy : U y = true := by
        cases hy' : U y with
        | true => rfl
        | false => exact absurd (hy'.trans hx.symm) hne
      exact hw ((M.weight_symm x y).trans (hU y x hy hx))
  have hfA : Admissible M A (fun v => f v && U v) := by
    intro v hv
    show (f v && U v) = A v
    rw [hf v hv]
    have h1 := hA v
    have h2 := hB v
    cases hAv : A v <;> cases hBv : B v <;> simp_all
  have hfB : Admissible M B (fun v => f v && !(U v)) := by
    intro v hv
    show (f v && !(U v)) = B v
    rw [hf v hv]
    have h1 := hA v
    have h2 := hB v
    cases hAv : A v <;> cases hBv : B v <;> simp_all
  have key : cutWeight M.toBulkGraph (fun v => f v && U v)
      + cutWeight M.toBulkGraph (fun v => f v && !(U v))
      ≤ cutWeight M.toBulkGraph f := by
    have hcomb := cutWeight_comb M.toBulkGraph ![f]
      ![fun v => f v && U v, fun v => f v && !(U v)]
      (by
        intro x y hw
        have hxy := hUsym x y hw
        simp only [Fin.sum_univ_two, Fin.sum_univ_one, Matrix.cons_val_zero,
          Matrix.cons_val_one]
        cases hx : U x <;> rw [hx] at hxy <;> simp [hxy])
    simpa [Fin.sum_univ_two, Fin.sum_univ_one] using hcomb
  have e1 := entropy_le_of_admissible hfA
  have e2 := entropy_le_of_admissible hfB
  rw [hval]
  linarith

/-- **No bridge ⟹ no entanglement.** -/
theorem mutualInfo_eq_zero_of_no_bridge {M : HoloModel V} (A B : Region V)
    (h : ∀ u v, A u = true → B v = true → ¬ BulkPath M.toBulkGraph u v) :
    mutualInfo M A B = 0 := by
  classical
  set U : Region V :=
    fun x => if ∃ a, A a = true ∧ BulkPath M.toBulkGraph a x then true else false with hUdef
  have hUclosed : ∀ x y, U x = true → U y = false → M.weight x y = 0 := by
    intro x y hx hy
    by_contra hw
    have hpos : 0 < M.weight x y :=
      lt_of_le_of_ne (M.weight_nonneg x y) (Ne.symm hw)
    have hPx : ∃ a, A a = true ∧ BulkPath M.toBulkGraph a x := by
      by_contra hcon
      rw [hUdef] at hx
      simp [hcon] at hx
    have hPy : ¬ ∃ b, A b = true ∧ BulkPath M.toBulkGraph b y := by
      intro hcon
      rw [hUdef] at hy
      simp [hcon] at hy
    obtain ⟨a, ha, hpath⟩ := hPx
    exact hPy ⟨a, ha, hpath.tail hpos⟩
  have hAU : ∀ v, A v = true → U v = true := by
    intro v hv
    rw [hUdef]
    exact if_pos ⟨v, hv, Relation.ReflTransGen.refl⟩
  have hBU : ∀ v, B v = true → U v = false := by
    intro v hv
    rw [hUdef]
    refine if_neg ?_
    rintro ⟨a, ha, hpath⟩
    exact h a v ha hv hpath
  have hadd := entropy_additive_of_split hUclosed A B hAU hBU
  simp only [mutualInfo, hadd]
  ring

/-- **ER = EPR, geometric half.**  Positive mutual information between two
boundary regions forces the existence of a microscopic Einstein–Rosen bridge:
a positive-area bulk path joining a cell of `A` to a cell of `B`. -/
theorem bridge_of_mutualInfo_pos {M : HoloModel V} (A B : Region V)
    (h : 0 < mutualInfo M A B) :
    ∃ u v, A u = true ∧ B v = true ∧ BulkPath M.toBulkGraph u v := by
  by_contra hcon
  push_neg at hcon
  have : mutualInfo M A B = 0 :=
    mutualInfo_eq_zero_of_no_bridge A B (fun u v hu hv => hcon u v hu hv)
  linarith

/-! ## The single-throat geometry of a qubit pair -/

/-- The two-cell geometry with a single throat of weight `w`. -/
def pairModel (w : ℝ) (hw : 0 ≤ w) : HoloModel (Fin 2) where
  weight := fun u v => if u = v then 0 else w
  weight_symm := by
    intro u v
    by_cases h : u = v
    · simp [h]
    · simp [h, Ne.symm h]
  weight_nonneg := by
    intro u v
    by_cases h : u = v <;> simp [h, hw]
  bdry := fun _ => true

lemma pairModel_noBulk (w : ℝ) (hw : 0 ≤ w) : NoBulk (pairModel w hw) := fun _ => rfl

/-- The mutual information of the two ends of a throat is twice its weight. -/
theorem pairModel_mutualInfo (w : ℝ) (hw : 0 ≤ w) :
    mutualInfo (pairModel w hw) (single 0) (single 1) = 2 * w := by
  have h := weight_eq_half_mutualInfo (pairModel_noBulk w hw)
    (u := (0 : Fin 2)) (v := (1 : Fin 2)) (by decide)
  have hw' : (pairModel w hw).weight 0 1 = w := by simp [pairModel]
  rw [hw'] at h
  linarith

/-- A throat of positive weight is a bridge, and conversely. -/
theorem pairModel_bridge_iff (w : ℝ) (hw : 0 ≤ w) :
    BulkPath (pairModel w hw).toBulkGraph 0 1 ↔ 0 < w := by
  constructor
  · intro hp
    rcases Relation.ReflTransGen.cases_tail hp with hcon | ⟨c, _, hstep⟩
    · exact absurd hcon (by decide)
    · have hs : (0:ℝ) < (if c = (1 : Fin 2) then 0 else w) := hstep
      by_cases hc : c = (1 : Fin 2)
      · simp [hc] at hs
      · simpa [hc] using hs
  · intro hpos
    exact Relation.ReflTransGen.single (by simpa [BulkAdj, pairModel] using hpos)

/-! ## Two-qubit states: entanglement is a bridge -/

open EmergentSpacetime

/-- A real `2 × 2` coefficient matrix of vanishing determinant is a product
state: rank-one factorisation of an unentangled pure state. -/
theorem isProduct_of_det_eq_zero {ψ : TwoQubitState} (h : Matrix.det ψ = 0) :
    IsProduct ψ := by
  rw [Matrix.det_fin_two] at h
  by_cases h00 : ψ 0 0 = 0
  · by_cases h01 : ψ 0 1 = 0
    · exact ⟨![0, 1], ![ψ 1 0, ψ 1 1], by
        intro i j; fin_cases i <;> fin_cases j <;> simp [h00, h01]⟩
    · have h10 : ψ 1 0 = 0 := by
        rw [h00] at h
        have hz : ψ 0 1 * ψ 1 0 = 0 := by linarith
        rcases mul_eq_zero.1 hz with h' | h'
        · exact absurd h' h01
        · exact h'
      exact ⟨![ψ 0 1, ψ 1 1], ![0, 1], by
        intro i j; fin_cases i <;> fin_cases j <;> simp [h00, h10]⟩
  · refine ⟨![1, ψ 1 0 / ψ 0 0], ![ψ 0 0, ψ 0 1], ?_⟩
    intro i j
    fin_cases i <;> fin_cases j <;> simp [h00]
    all_goals (field_simp; nlinarith [h])

lemma concurrence_nonneg (ψ : TwoQubitState) : 0 ≤ concurrence ψ := by
  simp [concurrence]

/-- Entanglement of a real two-qubit pure state is equivalent to positivity of
its concurrence. -/
theorem entangled_iff_concurrence_pos (ψ : TwoQubitState) :
    ¬ IsProduct ψ ↔ 0 < concurrence ψ := by
  constructor
  · intro hnp
    rcases lt_or_eq_of_le (concurrence_nonneg ψ) with h | h
    · exact h
    · exact absurd (isProduct_of_det_eq_zero (by
        have : |entanglementDet ψ| = 0 := by
          simp only [concurrence] at h; linarith
        simpa [entanglementDet, abs_eq_zero] using this)) hnp
  · intro hpos hp
    have := product_entanglementDet_zero hp
    simp [concurrence, this] at hpos

/-- **ER = EPR in the toy model.**  A real two-qubit pure state is entangled if
and only if the associated single-throat geometry, whose throat weight is the
concurrence of the state, contains an Einstein–Rosen bridge between the two
boundary qubits — equivalently, if and only if those two boundary cells have
positive mutual information. -/
theorem ER_EPR_correspondence (ψ : TwoQubitState) :
    (¬ IsProduct ψ)
      ↔ BulkPath (pairModel (concurrence ψ) (concurrence_nonneg ψ)).toBulkGraph 0 1 := by
  rw [entangled_iff_concurrence_pos ψ,
    pairModel_bridge_iff (concurrence ψ) (concurrence_nonneg ψ)]

/-- The quantitative form: the mutual information carried by the emergent
throat equals twice the concurrence of the state, and is positive exactly for
entangled states. -/
theorem ER_EPR_quantitative (ψ : TwoQubitState) :
    mutualInfo (pairModel (concurrence ψ) (concurrence_nonneg ψ)) (single 0) (single 1)
        = 2 * concurrence ψ ∧
      ((¬ IsProduct ψ) ↔
        0 < mutualInfo (pairModel (concurrence ψ) (concurrence_nonneg ψ))
          (single 0) (single 1)) := by
  refine ⟨pairModel_mutualInfo _ _, ?_⟩
  rw [pairModel_mutualInfo, entangled_iff_concurrence_pos]
  constructor <;> intro h <;> linarith

end EmergentGeometry