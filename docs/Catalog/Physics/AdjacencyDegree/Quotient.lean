import Physics.AdjacencyDegree.Equitable
import Physics.AdjacencyDegree.Moments

/-!
# Moments are computed on the colour-refinement quotient

This is the structural heart of the "moment rigidity lies inside colour refinement" statement.
If `c` is an equitable colouring of `G` with quotient matrix `B` (numbers of neighbours in each
class) and class degrees `Δ`, then for every word `w` in `A` and `D`

`𝟏ᵀ w(A_G, D_G) 𝟏 = ∑_κ |κ| · (w(B, Δ) 𝟏)_κ`.

Consequently two graphs carrying equitable colourings with the same class sizes and the same
quotient data have *identical* adjacency-degree moments, whether or not they are isomorphic.

Main results:

* `AdjDeg.wordMatrix_mulVec_ones_eq_quot` : the vector `w(A,D)𝟏` is the pullback of the
  quotient vector `w(B,Δ)𝟏`;
* `AdjDeg.wordMoment_eq_quot` : the moment is the class-size weighted quotient moment;
* `AdjDeg.wordMoment_eq_of_quot_eq` : equal quotient data implies equal moments.
-/

namespace AdjDeg

open Matrix Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable {C : Type*} [Fintype C] [DecidableEq C]
variable (G : SimpleGraph V) [DecidableRel G.Adj] (c : V → C) (rep : C → V)

/-- The size of a colour class. -/
def classSize : C → ℝ := fun κ => ((Finset.univ.filter fun v : V => c v = κ).card : ℝ)

/-- The number of neighbours in class `λ` of the chosen representative of class `κ`. -/
def quotCount : C → C → ℕ := fun κ lam =>
  ((G.neighborFinset (rep κ)).filter fun w => c w = lam).card

/-- The quotient adjacency matrix. -/
def quotAdj : Matrix C C ℝ := Matrix.of fun κ lam => (quotCount G c rep κ lam : ℝ)

/-- The quotient degree matrix. -/
def quotDeg : Matrix C C ℝ := Matrix.diagonal fun κ => (G.degree (rep κ) : ℝ)

/-- The quotient matrix of a letter. -/
def quotLetterMatrix : Letter → Matrix C C ℝ
  | Letter.adj => quotAdj G c rep
  | Letter.deg => quotDeg G rep

/-- The quotient matrix of a word. -/
def quotWordMatrix (w : List Letter) : Matrix C C ℝ :=
  (w.map (quotLetterMatrix G c rep)).prod

omit [DecidableEq V] in
@[simp] lemma quotWordMatrix_nil : quotWordMatrix G c rep [] = 1 := rfl

omit [DecidableEq V] in
@[simp] lemma quotWordMatrix_cons (l : Letter) (w : List Letter) :
    quotWordMatrix G c rep (l :: w)
      = quotLetterMatrix G c rep l * quotWordMatrix G c rep w := by
  simp [quotWordMatrix]

/-- **The word vector is a pullback from the quotient.** -/
theorem wordMatrix_mulVec_ones_eq_quot (hc : IsEquitable G c)
    (hrep : ∀ v : V, c (rep (c v)) = c v) (w : List Letter) (v : V) :
    (wordMatrix G w *ᵥ (1 : V → ℝ)) v
      = (quotWordMatrix G c rep w *ᵥ (1 : C → ℝ)) (c v) := by
  induction w generalizing v with
  | nil => simp [Matrix.one_mulVec]
  | cons l w ih =>
      rw [wordMatrix_cons, ← Matrix.mulVec_mulVec, quotWordMatrix_cons, ← Matrix.mulVec_mulVec]
      set f : V → ℝ := wordMatrix G w *ᵥ (1 : V → ℝ) with hf
      set g : C → ℝ := quotWordMatrix G c rep w *ᵥ (1 : C → ℝ) with hg
      cases l with
      | adj =>
          have hleft : (letterMatrix G Letter.adj *ᵥ f) v
              = ∑ lam : C, (((G.neighborFinset v).filter fun x => c x = lam).card : ℝ) * g lam := by
            rw [letterMatrix, SimpleGraph.adjMatrix_mulVec_apply]
            rw [Finset.sum_congr rfl (fun x _ => ih x)]
            exact sum_fiber_color c (G.neighborFinset v) g
          have hright : (quotLetterMatrix G c rep Letter.adj *ᵥ g) (c v)
              = ∑ lam : C,
                  (((G.neighborFinset (rep (c v))).filter fun x => c x = lam).card : ℝ) * g lam := by
            simp [quotLetterMatrix, quotAdj, quotCount, Matrix.mulVec, dotProduct]
          rw [hleft, hright]
          exact Finset.sum_congr rfl fun lam _ => by
            rw [hc v (rep (c v)) (hrep v).symm lam]
      | deg =>
          have hdeg : G.degree v = G.degree (rep (c v)) :=
            degree_eq_of_equitable G hc (hrep v).symm
          rw [letterMatrix, degMatrix_mulVec, quotLetterMatrix, quotDeg,
            Matrix.mulVec_diagonal, ih v, hdeg]

/-- **The moment is the class-size weighted quotient moment.** -/
theorem wordMoment_eq_quot (hc : IsEquitable G c)
    (hrep : ∀ v : V, c (rep (c v)) = c v) (w : List Letter) :
    wordMoment G w
      = ∑ κ : C, classSize c κ * (quotWordMatrix G c rep w *ᵥ (1 : C → ℝ)) κ := by
  rw [wordMoment, moment_eq_sum_mulVec]
  rw [Finset.sum_congr rfl
    (fun v (_ : v ∈ Finset.univ) => wordMatrix_mulVec_ones_eq_quot G c rep hc hrep w v)]
  rw [sum_fiber_color c Finset.univ (quotWordMatrix G c rep w *ᵥ (1 : C → ℝ))]
  rfl

/-- **Equal quotient data implies equal moments.** -/
theorem wordMoment_eq_of_quot_eq {W : Type*} [Fintype W] [DecidableEq W]
    (G' : SimpleGraph W) [DecidableRel G'.Adj] (c' : W → C) (rep' : C → W)
    (hc : IsEquitable G c) (hrep : ∀ v : V, c (rep (c v)) = c v)
    (hc' : IsEquitable G' c') (hrep' : ∀ v : W, c' (rep' (c' v)) = c' v)
    (hsize : ∀ κ : C, classSize c κ = classSize c' κ)
    (hadj : quotAdj G c rep = quotAdj G' c' rep')
    (hdeg : ∀ κ : C, (G.degree (rep κ) : ℝ) = (G'.degree (rep' κ) : ℝ))
    (w : List Letter) :
    wordMoment G w = wordMoment G' w := by
  have hquot : quotWordMatrix G c rep w = quotWordMatrix G' c' rep' w := by
    have hletter : ∀ l : Letter,
        quotLetterMatrix G c rep l = quotLetterMatrix G' c' rep' l := by
      intro l
      cases l with
      | adj => exact hadj
      | deg =>
          show quotDeg G rep = quotDeg G' rep'
          unfold quotDeg
          congr 1
          funext κ
          exact hdeg κ
    unfold quotWordMatrix
    congr 1
    exact List.map_congr_left fun l _ => hletter l
  rw [wordMoment_eq_quot G c rep hc hrep w, wordMoment_eq_quot G' c' rep' hc' hrep' w, hquot]
  exact Finset.sum_congr rfl fun κ _ => by rw [hsize κ]

end AdjDeg