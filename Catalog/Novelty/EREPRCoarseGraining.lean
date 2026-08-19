import Novelty.EREPRUltrametricSpacetime

/-!
# Coarse-graining of emergent spacetime: an entanglement renormalisation flow

This file closes conjecture **C4** of `FUTURE_DIRECTIONS.md`: *coarse-graining is
a metric contraction*.

Given a geometry `G : BulkGraph V` (a finite weighted graph of "areas", the
discrete spatial slice of the toy AdS/CFT model of
`Catalog/Novelty/EmergentGeometryEntropyCone.lean`) and a map `π : V → W`
merging bulk cells, the **pushforward geometry** `pushGraph π G` assigns to a
pair of distinct coarse cells the total area joining their fibres.

The main results are:

* `cutWeight_pushGraph` — surfaces of the coarse geometry are exactly the
  `π`-invariant surfaces of the fine one, *with the same area*.  This is the
  engine of the whole file.
* `pushGraph_comp` — coarse-graining is functorial: `π` followed by `ρ` is
  `ρ ∘ π` on the nose (an equality of weighted graphs, not merely of cut
  functions).
* `throat_le_throat_pushGraph`, `cap_le_cap_pushGraph` — merging cells can only
  *widen* Einstein–Rosen throats, since the coarse geometry minimises the cut
  over a smaller family of surfaces.
* `bridgeDist_pushGraph_le`, `lipschitzWith_one_pushGraph` — hence the emergent
  distance can only *shrink*: `π` is a `1`-Lipschitz map of the emergent
  ultrametric spaces.  Coarse-graining a holographic state brings the emergent
  spacetime closer together; this is the RG flow of the model.
* `entropy_le_entropy_pushModel` — coarse-graining a holographic model cannot
  decrease a Ryu–Takayanagi entropy: the fine minimal surfaces that split a
  fibre have no coarse counterpart.
* `cap_pushGraph_eq_of_lift`, `entropy_pushModel_eq_of_lift` — conversely,
  nothing moves when a minimal surface survives the merging, i.e. when it is
  constant on the fibres of `π`.  Together with the strict example below this
  isolates the exact mechanism of the renormalisation jump: only surfaces that
  split a fibre can be lost.
* `rgExample_cap_lt_pushGraph_cap` — the contraction is **strict** in general:
  an explicit four-cell geometry (a path with a thin waist) whose throat jumps
  from at most `1` to exactly `5` when the two waist cells are merged, so the
  emergent distance strictly drops.

## Lab notes

**HYPOTHESIS.**  Merging boundary degrees of freedom is a monotone operation on
emergent geometry: `cap` is non-decreasing and `bridgeDist` non-increasing.

**EXPERIMENT.**  Formalised `pushGraph` and proved the fibrewise identity
`cutWeight (pushGraph π G) σ = cutWeight G (σ ∘ π)`; every coarse cut pulls back
to a fine cut of equal area, but not conversely — precisely the cuts that split
a fibre have no coarse counterpart.  The one-line consequence is the inequality
`cap G u v ≤ cap (pushGraph π G) (π u) (π v)`.

**ANALYSIS.**  The asymmetry ("a smaller family of competitors") is the entire
content: no positivity or submodularity is used, so the result survives for any
real weights that make `pushGraph π G` a legal geometry.  Functoriality
(`pushGraph_comp`) needed one observation: for `c ≠ d` the fibres `ρ⁻¹ c` and
`ρ⁻¹ d` are disjoint, so the diagonal correction `if a = b then 0` in the
definition of `pushGraph` is never triggered — which is exactly why the
composite is an equality rather than an inequality.

**CRITIQUE.**  Could the contraction be vacuous (an equality always)?  No:
`rgExample_cap_lt_pushGraph_cap` exhibits a geometry where the min cut strictly
increases, because the unique cheap surface separated the two merged cells.  The
lower bound there is proved by exhausting the coarse surfaces, not by `decide`
on reals.
-/

noncomputable section

namespace EmergentGeometry

open Finset

variable {V W X : Type*} [Fintype V] [Fintype W] [Fintype X]
  [DecidableEq V] [DecidableEq W] [DecidableEq X]

/-! ## The pushforward geometry -/

/-- The fibre of `π` over a coarse cell. -/
def fib (π : V → W) (a : W) : Finset V := {x | π x = a}

omit [Fintype W] [DecidableEq V] in
@[simp] lemma mem_fib {π : V → W} {a : W} {x : V} : x ∈ fib π a ↔ π x = a := by
  simp [fib]

omit [Fintype X] [DecidableEq V] in
/-- Summing fibrewise over a fibre of a further coarse-graining. -/
lemma sum_fib_comp (π : V → W) (ρ : W → X) (c : X) (F : V → ℝ) :
    ∑ a ∈ fib ρ c, ∑ x ∈ fib π a, F x = ∑ x ∈ fib (ρ ∘ π) c, F x := by
  simp only [fib]
  rw [Finset.sum_fiberwise_eq_sum_filter univ ({w | ρ w = c} : Finset W) π F]
  apply sum_congr _ (fun _ _ => rfl)
  ext x; simp

omit [DecidableEq V] in
/-- Summing fibrewise over all fibres recovers the sum. -/
lemma sum_fib_univ (π : V → W) (F : V → ℝ) :
    ∑ a, ∑ x ∈ fib π a, F x = ∑ x, F x :=
  Finset.sum_fiberwise univ π F

/-- **Coarse-graining of a geometry.**  Merging the cells of each fibre of
`π : V → W`, the area joining two distinct coarse cells is the total area
joining their fibres. -/
def pushGraph (π : V → W) (G : BulkGraph V) : BulkGraph W where
  weight a b := if a = b then 0 else ∑ x ∈ fib π a, ∑ y ∈ fib π b, G.weight x y
  weight_symm a b := by
    rcases eq_or_ne a b with rfl | hab
    · simp
    · rw [if_neg hab, if_neg hab.symm, Finset.sum_comm]
      exact sum_congr rfl fun x _ => sum_congr rfl fun y _ => G.weight_symm y x
  weight_nonneg a b := by
    rcases eq_or_ne a b with rfl | hab
    · simp
    · rw [if_neg hab]
      exact sum_nonneg fun x _ => sum_nonneg fun y _ => G.weight_nonneg x y

omit [DecidableEq V] in
lemma pushGraph_weight_of_ne (π : V → W) (G : BulkGraph V) {a b : W} (hab : a ≠ b) :
    (pushGraph π G).weight a b = ∑ x ∈ fib π a, ∑ y ∈ fib π b, G.weight x y := by
  simp [pushGraph, hab]

omit [DecidableEq V] in
/-- **Coarse surfaces are exactly the `π`-invariant fine surfaces, and they have
the same area.**  This is the technical engine of the file. -/
theorem cutWeight_pushGraph (π : V → W) (G : BulkGraph V) (σ : Region W) :
    cutWeight (pushGraph π G) σ = cutWeight G (fun x => σ (π x)) := by
  have key : ∀ a b : W,
      (sepBit (σ a) (σ b) : ℝ) * (pushGraph π G).weight a b
        = ∑ x ∈ fib π a, ∑ y ∈ fib π b, (sepBit (σ (π x)) (σ (π y)) : ℝ) * G.weight x y := by
    intro a b
    rcases eq_or_ne a b with rfl | hab
    · refine Eq.trans (by simp) (sum_eq_zero fun x hx => sum_eq_zero fun y hy => ?_).symm
      rw [mem_fib] at hx hy
      simp [hx, hy, sepBit]
    · rw [pushGraph_weight_of_ne π G hab, Finset.mul_sum]
      refine sum_congr rfl fun x hx => ?_
      rw [Finset.mul_sum]
      refine sum_congr rfl fun y hy => ?_
      rw [mem_fib] at hx hy
      rw [hx, hy]
  have step : ∀ a : W, ∑ b, (sepBit (σ a) (σ b) : ℝ) * (pushGraph π G).weight a b
      = ∑ x ∈ fib π a, ∑ y, (sepBit (σ (π x)) (σ (π y)) : ℝ) * G.weight x y := by
    intro a
    calc ∑ b, (sepBit (σ a) (σ b) : ℝ) * (pushGraph π G).weight a b
        = ∑ b, ∑ x ∈ fib π a, ∑ y ∈ fib π b,
            (sepBit (σ (π x)) (σ (π y)) : ℝ) * G.weight x y := sum_congr rfl fun b _ => key a b
      _ = ∑ x ∈ fib π a, ∑ b, ∑ y ∈ fib π b,
            (sepBit (σ (π x)) (σ (π y)) : ℝ) * G.weight x y := Finset.sum_comm
      _ = ∑ x ∈ fib π a, ∑ y, (sepBit (σ (π x)) (σ (π y)) : ℝ) * G.weight x y :=
            sum_congr rfl fun x _ => sum_fib_univ π _
  rw [cutWeight, cutWeight]
  congr 1
  calc ∑ a, ∑ b, (sepBit (σ a) (σ b) : ℝ) * (pushGraph π G).weight a b
      = ∑ a, ∑ x ∈ fib π a, ∑ y, (sepBit (σ (π x)) (σ (π y)) : ℝ) * G.weight x y :=
        sum_congr rfl fun a _ => step a
    _ = ∑ x, ∑ y, (sepBit (σ (π x)) (σ (π y)) : ℝ) * G.weight x y := sum_fib_univ π _

/-- Coarse-graining along the identity changes no area. -/
theorem cutWeight_pushGraph_id (G : BulkGraph V) (f : Region V) :
    cutWeight (pushGraph id G) f = cutWeight G f :=
  cutWeight_pushGraph id G f

omit [DecidableEq V] in
/-- **Functoriality of coarse-graining**: two successive mergings give exactly
the geometry obtained by merging along the composite. -/
theorem pushGraph_comp (π : V → W) (ρ : W → X) (G : BulkGraph V) :
    pushGraph ρ (pushGraph π G) = pushGraph (ρ ∘ π) G := by
  have hw : ∀ c d : X,
      (pushGraph ρ (pushGraph π G)).weight c d = (pushGraph (ρ ∘ π) G).weight c d := by
    intro c d
    rcases eq_or_ne c d with rfl | hcd
    · simp [pushGraph]
    rw [pushGraph_weight_of_ne _ _ hcd, pushGraph_weight_of_ne _ _ hcd]
    calc ∑ a ∈ fib ρ c, ∑ b ∈ fib ρ d, (pushGraph π G).weight a b
        = ∑ a ∈ fib ρ c, ∑ x ∈ fib π a, ∑ y ∈ fib (ρ ∘ π) d, G.weight x y := by
          refine sum_congr rfl fun a ha => ?_
          calc ∑ b ∈ fib ρ d, (pushGraph π G).weight a b
              = ∑ b ∈ fib ρ d, ∑ x ∈ fib π a, ∑ y ∈ fib π b, G.weight x y := by
                refine sum_congr rfl fun b hb => ?_
                refine pushGraph_weight_of_ne π G ?_
                rw [mem_fib] at ha hb
                rintro rfl
                exact hcd (ha ▸ hb ▸ rfl)
            _ = ∑ x ∈ fib π a, ∑ b ∈ fib ρ d, ∑ y ∈ fib π b, G.weight x y := Finset.sum_comm
            _ = ∑ x ∈ fib π a, ∑ y ∈ fib (ρ ∘ π) d, G.weight x y :=
                sum_congr rfl fun x _ => sum_fib_comp π ρ d _
      _ = ∑ x ∈ fib (ρ ∘ π) c, ∑ y ∈ fib (ρ ∘ π) d, G.weight x y := sum_fib_comp π ρ c _
  have hfun : (pushGraph ρ (pushGraph π G)).weight = (pushGraph (ρ ∘ π) G).weight := by
    funext c d; exact hw c d
  cases hA : pushGraph ρ (pushGraph π G) with
  | mk w1 s1 n1 =>
    cases hB : pushGraph (ρ ∘ π) G with
    | mk w2 s2 n2 =>
      rw [hA, hB] at hfun
      subst hfun
      rfl

/-! ## Throats widen and distances contract -/

/-- Shrinking the two regions cannot increase the throat between them. -/
theorem throat_mono_region (G : BulkGraph V) {A B A' B' : Region V}
    (hA : ∀ v, A' v = true → A v = true) (hB : ∀ v, B' v = true → B v = true)
    (hAB : Disj A B) : throat G A' B' ≤ throat G A B := by
  obtain ⟨σ, hσ, hval⟩ := exists_min_throat_surface G hAB
  rw [hval]
  exact throat_le_of_separates ⟨fun v hv => hσ.1 v (hA v hv), fun v hv => hσ.2 v (hB v hv)⟩

/-- **Coarse-graining widens throats.**  A surface of the coarse geometry pulls
back to a surface of the fine geometry of the same area, so the fine geometry
minimises over a larger family. -/
theorem throat_le_throat_pushGraph (π : V → W) (G : BulkGraph V) {A B : Region W}
    (hAB : Disj A B) :
    throat G (fun x => A (π x)) (fun x => B (π x)) ≤ throat (pushGraph π G) A B := by
  obtain ⟨σ, hσ, hval⟩ := exists_min_throat_surface (pushGraph π G) hAB
  rw [hval, cutWeight_pushGraph]
  exact throat_le_of_separates ⟨fun v hv => hσ.1 _ hv, fun v hv => hσ.2 _ hv⟩

/-- **Coarse-graining widens the Einstein–Rosen bridge between two cells.** -/
theorem cap_le_cap_pushGraph (π : V → W) (G : BulkGraph V) {u v : V} (h : π u ≠ π v) :
    cap G u v ≤ cap (pushGraph π G) (π u) (π v) := by
  refine le_trans ?_ (throat_le_throat_pushGraph π G (single_disj h))
  have hdisj : Disj (fun x => single (π u) (π x)) (fun x => single (π v) (π x)) := by
    intro x hx
    simp only [single, decide_eq_true_eq] at hx
    simp only [single, decide_eq_false_iff_not]
    rw [hx]
    exact h
  refine throat_mono_region G ?_ ?_ hdisj
  · intro x hx
    simp only [single, decide_eq_true_eq] at hx
    simp [single, hx]
  · intro x hx
    simp only [single, decide_eq_true_eq] at hx
    simp [single, hx]

/-- **Coarse-graining is a metric contraction.**  Merging bulk cells can only
bring the emergent spacetime closer together. -/
theorem bridgeDist_pushGraph_le (π : V → W) (G : BulkGraph V) (u v : V) :
    bridgeDist (pushGraph π G) (π u) (π v) ≤ bridgeDist G u v := by
  rcases eq_or_ne (π u) (π v) with h | h
  · rw [h]
    simpa using bridgeDist_nonneg G u v
  · have huv : u ≠ v := fun huv => h (by rw [huv])
    rw [bridgeDist_of_ne h, bridgeDist_of_ne huv]
    exact Real.exp_le_exp.2 (by linarith [cap_le_cap_pushGraph π G h])

/-- The coarse-graining map, viewed as a map of emergent metric spaces. -/
def pushMap (π : V → W) (G : BulkGraph V) : BridgeSpace G → BridgeSpace (pushGraph π G) :=
  fun u => π u

/-- **The renormalisation-group map is `1`-Lipschitz**: coarse-graining is a
morphism of emergent ultrametric spaces. -/
theorem lipschitzWith_one_pushGraph (π : V → W) (G : BulkGraph V) :
    LipschitzWith 1 (pushMap π G) := by
  refine LipschitzWith.of_dist_le_mul fun u v => ?_
  have h := bridgeDist_pushGraph_le π G u v
  simpa [pushMap, dist] using h

/-- **When a minimal surface survives the merging, nothing changes.**  If some
minimal `u`–`v` surface of `G` is constant on the fibres of `π` (i.e. is pulled
back from a coarse surface `τ`), then the throat is unchanged.  This is the easy
half of the characterisation of the renormalisation jump. -/
theorem cap_pushGraph_eq_of_lift (π : V → W) (G : BulkGraph V) {u v : V} (h : π u ≠ π v)
    (τ : Region W) (hu : τ (π u) = true) (hv : τ (π v) = false)
    (hmin : cutWeight G (fun x => τ (π x)) = cap G u v) :
    cap (pushGraph π G) (π u) (π v) = cap G u v := by
  refine le_antisymm ?_ (cap_le_cap_pushGraph π G h)
  have hsep : Separates (single (π u)) (single (π v)) τ := by
    constructor
    · intro w hw
      simp only [single, decide_eq_true_eq] at hw
      rw [hw]; exact hu
    · intro w hw
      simp only [single, decide_eq_true_eq] at hw
      rw [hw]; exact hv
  calc cap (pushGraph π G) (π u) (π v) ≤ cutWeight (pushGraph π G) τ :=
        throat_le_of_separates hsep
    _ = cutWeight G (fun x => τ (π x)) := cutWeight_pushGraph π G τ
    _ = cap G u v := hmin

/-! ## Coarse-graining a holographic model raises entropies -/

/-- Coarse-graining of a holographic model: the geometry is pushed forward and a
coarse cell is a boundary cell as soon as one of the cells it absorbs is. -/
def pushModel (π : V → W) (M : HoloModel V) : HoloModel W where
  toBulkGraph := pushGraph π M.toBulkGraph
  bdry a := decide (∃ x ∈ fib π a, M.bdry x = true)

omit [DecidableEq V] in
@[simp] lemma pushModel_toBulkGraph (π : V → W) (M : HoloModel V) :
    (pushModel π M).toBulkGraph = pushGraph π M.toBulkGraph := rfl

omit [DecidableEq V] in
lemma pushModel_bdry_of_bdry (π : V → W) (M : HoloModel V) {x : V} (hx : M.bdry x = true) :
    (pushModel π M).bdry (π x) = true := by
  simp only [pushModel, decide_eq_true_eq]
  exact ⟨x, by simp, hx⟩

/-- **Coarse-graining cannot decrease the Ryu–Takayanagi entropy.**  Merging
boundary cells destroys the fine minimal surfaces that split a fibre, so the
coarse model minimises the area over a smaller family. -/
theorem entropy_le_entropy_pushModel (π : V → W) (M : HoloModel V) (A : Region W) :
    entropy M (fun x => A (π x)) ≤ entropy (pushModel π M) A := by
  obtain ⟨σ, hσ, hval⟩ := exists_minimal_surface (pushModel π M) A
  rw [hval, pushModel_toBulkGraph, cutWeight_pushGraph]
  refine entropy_le_of_admissible (M := M) (A := fun x => A (π x)) (f := fun x => σ (π x)) ?_
  intro x hx
  exact hσ (π x) (pushModel_bdry_of_bdry π M hx)

/-- **Entropy is unchanged when a minimal surface survives the merging.**  The
easy half of the rigidity statement for Ryu–Takayanagi entropies under
coarse-graining. -/
theorem entropy_pushModel_eq_of_lift (π : V → W) (M : HoloModel V) (A τ : Region W)
    (hadm : Admissible M (fun x => A (π x)) (fun x => τ (π x)))
    (hmin : cutWeight M.toBulkGraph (fun x => τ (π x)) = entropy M (fun x => A (π x))) :
    entropy (pushModel π M) A = entropy M (fun x => A (π x)) := by
  refine le_antisymm ?_ (entropy_le_entropy_pushModel π M A)
  have hadm' : Admissible (pushModel π M) A τ := by
    intro a ha
    simp only [pushModel, decide_eq_true_eq] at ha
    obtain ⟨x, hx, hbx⟩ := ha
    rw [mem_fib] at hx
    rw [← hx]
    exact hadm x hbx
  calc entropy (pushModel π M) A ≤ cutWeight (pushModel π M).toBulkGraph τ :=
        entropy_le_of_admissible hadm'
    _ = cutWeight M.toBulkGraph (fun x => τ (π x)) := by
        rw [pushModel_toBulkGraph, cutWeight_pushGraph]
    _ = entropy M (fun x => A (π x)) := hmin

/-! ## The contraction is strict: a thin waist that disappears -/

/-- The area of a surface in a three-cell geometry, as a sum over the three
unordered pairs. -/
lemma cutWeight_fin3 (G : BulkGraph (Fin 3)) (σ : Region (Fin 3)) :
    cutWeight G σ = (sepBit (σ 0) (σ 1) : ℝ) * G.weight 0 1
      + (sepBit (σ 0) (σ 2) : ℝ) * G.weight 0 2
      + (sepBit (σ 1) (σ 2) : ℝ) * G.weight 1 2 := by
  have h10 : G.weight 1 0 = G.weight 0 1 := G.weight_symm 1 0
  have h20 : G.weight 2 0 = G.weight 0 2 := G.weight_symm 2 0
  have h21 : G.weight 2 1 = G.weight 1 2 := G.weight_symm 2 1
  simp only [cutWeight, Fin.sum_univ_three, sepBit_self, h10, h20, h21,
    sepBit_comm (σ 1) (σ 0), sepBit_comm (σ 2) (σ 0), sepBit_comm (σ 2) (σ 1),
    Nat.cast_zero, zero_mul, zero_add, add_zero]
  ring

/-- The area of a surface in a four-cell geometry, as a sum over the six
unordered pairs. -/
lemma cutWeight_fin4 (G : BulkGraph (Fin 4)) (σ : Region (Fin 4)) :
    cutWeight G σ = (sepBit (σ 0) (σ 1) : ℝ) * G.weight 0 1
      + (sepBit (σ 0) (σ 2) : ℝ) * G.weight 0 2
      + (sepBit (σ 0) (σ 3) : ℝ) * G.weight 0 3
      + (sepBit (σ 1) (σ 2) : ℝ) * G.weight 1 2
      + (sepBit (σ 1) (σ 3) : ℝ) * G.weight 1 3
      + (sepBit (σ 2) (σ 3) : ℝ) * G.weight 2 3 := by
  have h10 : G.weight 1 0 = G.weight 0 1 := G.weight_symm 1 0
  have h20 : G.weight 2 0 = G.weight 0 2 := G.weight_symm 2 0
  have h30 : G.weight 3 0 = G.weight 0 3 := G.weight_symm 3 0
  have h21 : G.weight 2 1 = G.weight 1 2 := G.weight_symm 2 1
  have h31 : G.weight 3 1 = G.weight 1 3 := G.weight_symm 3 1
  have h32 : G.weight 3 2 = G.weight 2 3 := G.weight_symm 3 2
  simp only [cutWeight, Fin.sum_univ_four, sepBit_self, h10, h20, h30, h21, h31, h32,
    sepBit_comm (σ 1) (σ 0), sepBit_comm (σ 2) (σ 0), sepBit_comm (σ 3) (σ 0),
    sepBit_comm (σ 2) (σ 1), sepBit_comm (σ 3) (σ 1), sepBit_comm (σ 3) (σ 2),
    Nat.cast_zero, zero_mul, zero_add, add_zero]
  ring

/-- The area table of the example geometry: a path `0 — 1 — 2 — 3` with two
heavy edges of area `5` and a thin waist of area `1`. -/
def rgTable : Fin 4 → Fin 4 → ℝ := ![![0, 5, 0, 0], ![5, 0, 1, 0], ![0, 1, 0, 5], ![0, 0, 5, 0]]

/-- A four-cell geometry: a path `0 — 1 — 2 — 3` with a thin waist. -/
def rgExample : BulkGraph (Fin 4) where
  weight := rgTable
  weight_symm u v := by fin_cases u <;> fin_cases v <;> simp [rgTable]
  weight_nonneg u v := by fin_cases u <;> fin_cases v <;> norm_num [rgTable]

/-- The coarse-graining that merges the two waist cells `1` and `2`. -/
def rgMerge : Fin 4 → Fin 3 := ![0, 1, 1, 2]

lemma fib_rgMerge_zero : fib rgMerge 0 = {0} := by decide
lemma fib_rgMerge_one : fib rgMerge 1 = {1, 2} := by decide
lemma fib_rgMerge_two : fib rgMerge 2 = {3} := by decide

/-- Merging the waist cells fuses the two heavy edges into the coarse edge
`0 — 1`. -/
lemma rgPush_weight_01 : (pushGraph rgMerge rgExample).weight 0 1 = 5 := by
  rw [pushGraph_weight_of_ne _ _ (by decide : (0 : Fin 3) ≠ 1),
    fib_rgMerge_zero, fib_rgMerge_one]
  rw [Finset.sum_singleton, Finset.sum_pair (by decide : (1 : Fin 4) ≠ 2)]
  simp [rgExample, rgTable]

lemma rgPush_weight_02 : (pushGraph rgMerge rgExample).weight 0 2 = 0 := by
  rw [pushGraph_weight_of_ne _ _ (by decide : (0 : Fin 3) ≠ 2),
    fib_rgMerge_zero, fib_rgMerge_two]
  simp [rgExample, rgTable]

lemma rgPush_weight_12 : (pushGraph rgMerge rgExample).weight 1 2 = 5 := by
  rw [pushGraph_weight_of_ne _ _ (by decide : (1 : Fin 3) ≠ 2),
    fib_rgMerge_one, fib_rgMerge_two]
  rw [Finset.sum_pair (by decide : (1 : Fin 4) ≠ 2)]
  simp [rgExample, rgTable]

/-- The thin waist gives a cheap surface: the throat of the fine geometry is at
most the area `1` of the waist. -/
theorem rgExample_cap_le_one : cap rgExample 0 3 ≤ 1 := by
  have h0 : (![true, true, false, false] : Region (Fin 4)) 0 = true := by decide
  have h1 : (![true, true, false, false] : Region (Fin 4)) 1 = true := by decide
  have h2 : (![true, true, false, false] : Region (Fin 4)) 2 = false := by decide
  have h3 : (![true, true, false, false] : Region (Fin 4)) 3 = false := by decide
  have w01 : rgExample.weight 0 1 = 5 := by simp [rgExample, rgTable]
  have w02 : rgExample.weight 0 2 = 0 := by simp [rgExample, rgTable]
  have w03 : rgExample.weight 0 3 = 0 := by simp [rgExample, rgTable]
  have w12 : rgExample.weight 1 2 = 1 := by simp [rgExample, rgTable]
  have w13 : rgExample.weight 1 3 = 0 := by simp [rgExample, rgTable]
  have w23 : rgExample.weight 2 3 = 5 := by simp [rgExample, rgTable]
  refine le_trans (throat_le_of_separates (G := rgExample) (A := single (0 : Fin 4))
    (B := single 3) (f := ![true, true, false, false]) ⟨by decide, by decide⟩) ?_
  rw [cutWeight_fin4, h0, h1, h2, h3, w01, w02, w03, w12, w13, w23]
  norm_num [sepBit]

/-- After merging the waist cells there is no cheap surface left: every coarse
surface separating the two ends has area exactly `5`. -/
theorem rgExample_pushGraph_cap_eq_five :
    cap (pushGraph rgMerge rgExample) 0 2 = 5 := by
  have hne : (0 : Fin 3) ≠ 2 := by decide
  have hcut : ∀ σ : Region (Fin 3), Separates (single 0) (single 2) σ →
      cutWeight (pushGraph rgMerge rgExample) σ = 5 := by
    intro σ hσ
    have h0 : σ 0 = true := hσ.1 0 (by simp [single])
    have h2 : σ 2 = false := hσ.2 2 (by simp [single])
    rw [cutWeight_fin3, rgPush_weight_01, rgPush_weight_02, rgPush_weight_12]
    cases σ 1 <;> simp [sepBit, h0, h2]
  obtain ⟨σ, hσ, hval⟩ :=
    exists_min_throat_surface (pushGraph rgMerge rgExample) (single_disj hne)
  rw [cap, hval, hcut σ hσ]

/-- **The renormalisation contraction is strict.**  Merging the two waist cells
of `rgExample` widens the throat to `5`, so the emergent distance drops
strictly: coarse-graining genuinely deforms the emergent geometry. -/
theorem rgExample_cap_lt_pushGraph_cap :
    cap rgExample 0 3 < cap (pushGraph rgMerge rgExample) (rgMerge 0) (rgMerge 3) ∧
      bridgeDist (pushGraph rgMerge rgExample) (rgMerge 0) (rgMerge 3)
        < bridgeDist rgExample 0 3 := by
  have hmap0 : rgMerge 0 = 0 := rfl
  have hmap3 : rgMerge 3 = 2 := rfl
  have hcap : cap (pushGraph rgMerge rgExample) (rgMerge 0) (rgMerge 3) = 5 := by
    rw [hmap0, hmap3, rgExample_pushGraph_cap_eq_five]
  have hlt : cap rgExample 0 3 < 5 := lt_of_le_of_lt rgExample_cap_le_one (by norm_num)
  refine ⟨by rw [hcap]; exact hlt, ?_⟩
  have hne3 : rgMerge 0 ≠ rgMerge 3 := by decide
  have hne : (0 : Fin 4) ≠ 3 := by decide
  rw [bridgeDist_of_ne hne3, bridgeDist_of_ne hne, hcap]
  exact Real.exp_lt_exp.2 (by linarith)

end EmergentGeometry