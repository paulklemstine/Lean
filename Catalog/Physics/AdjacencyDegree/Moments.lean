import Physics.AdjacencyDegree.Basic

/-!
# Scalar moments of adjacency-degree words

For a word `w` in the two letters `A` (adjacency matrix) and `D` (degree matrix) we study the
scalar moment `𝟏ᵀ w(A_G, D_G) 𝟏`.  These are exactly the numbers appearing in the "principal"
form of McKay's theorem.

Main results:

* `AdjDeg.wordMatrix_iso` / `AdjDeg.wordMoment_iso` : all moments are isomorphism invariants
  (the easy but indispensable half of any determination theorem);
* `AdjDeg.moment_degMatrix_pow` : the pure `D`-moments are the degree power sums;
* `AdjDeg.moment_adjMatrix_pow` : the pure `A`-moments count walks;
* `AdjDeg.moment_degMatrix_mul_adjMatrix_mul_degMatrix` : the first genuinely
  "degree-decorated" moment `𝟏ᵀ D A D 𝟏 = ∑_{u ~ v} d_u d_v`.
-/

namespace AdjDeg

open Matrix Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The scalar moment `𝟏ᵀ X 𝟏`. -/
def moment (X : Matrix V V ℝ) : ℝ := (1 : V → ℝ) ᵥ* X ⬝ᵥ (1 : V → ℝ)

omit [DecidableEq V] in
lemma moment_eq_sum (X : Matrix V V ℝ) : moment X = ∑ v, ∑ u, X u v := by
  simp [moment, Matrix.vecMul, dotProduct]

omit [DecidableEq V] in
lemma moment_eq_sum' (X : Matrix V V ℝ) : moment X = ∑ u, ∑ v, X u v := by
  rw [moment_eq_sum, Finset.sum_comm]

omit [DecidableEq V] in
lemma moment_eq_sum_mulVec (X : Matrix V V ℝ) : moment X = ∑ u, (X *ᵥ (1 : V → ℝ)) u := by
  rw [moment_eq_sum']
  simp [Matrix.mulVec, dotProduct]

/-- Letters of the adjacency-degree alphabet. -/
inductive Letter
  | adj : Letter
  | deg : Letter
deriving DecidableEq

/-- The matrix attached to a letter. -/
def letterMatrix : Letter → Matrix V V ℝ
  | Letter.adj => G.adjMatrix ℝ
  | Letter.deg => degMatrix G

/-- The matrix `w(A_G, D_G)` attached to a word. -/
def wordMatrix (w : List Letter) : Matrix V V ℝ := (w.map (letterMatrix G)).prod

@[simp] lemma wordMatrix_nil : wordMatrix G [] = 1 := rfl

@[simp] lemma wordMatrix_cons (l : Letter) (w : List Letter) :
    wordMatrix G (l :: w) = letterMatrix G l * wordMatrix G w := by
  simp [wordMatrix]

lemma wordMatrix_mem_adjDegAlgebra (w : List Letter) : wordMatrix G w ∈ adjDegAlgebra G := by
  induction w with
  | nil => simp
  | cons l w ih =>
      rw [wordMatrix_cons]
      refine mul_mem ?_ ih
      cases l
      · exact adjMatrix_mem_adjDegAlgebra G
      · exact degMatrix_mem_adjDegAlgebra G

/-- The scalar moment of a word. -/
def wordMoment (w : List Letter) : ℝ := moment (wordMatrix G w)

/-! ## Isomorphism invariance -/

section Iso

variable {W : Type*} [Fintype W] [DecidableEq W]
variable (G' : SimpleGraph W) [DecidableRel G'.Adj]

lemma letterMatrix_iso (f : G ≃g G') (l : Letter) (u v : V) :
    letterMatrix G' l (f u) (f v) = letterMatrix G l u v := by
  cases l with
  | adj =>
      simp only [letterMatrix, SimpleGraph.adjMatrix_apply]
      by_cases h : G.Adj u v
      · simp [h, f.map_adj_iff.mpr h]
      · have : ¬ G'.Adj (f u) (f v) := fun hc => h (f.map_adj_iff.mp hc)
        simp [h, this]
  | deg =>
      simp only [letterMatrix, degMatrix_apply]
      by_cases h : u = v
      · subst h; simp [f.degree_eq u]
      · have hne : ¬ (f u = f v) := fun hc => h ((f : V ≃ W).injective hc)
        simp [h, hne]

/-- Word matrices are equivariant along a graph isomorphism. -/
theorem wordMatrix_iso (f : G ≃g G') (w : List Letter) (u v : V) :
    wordMatrix G' w (f u) (f v) = wordMatrix G w u v := by
  induction w generalizing u v with
  | nil =>
      simp only [wordMatrix_nil, Matrix.one_apply]
      by_cases h : u = v
      · simp [h]
      · have hne : ¬ (f u = f v) := fun hc => h ((f : V ≃ W).injective hc)
        simp [h, hne]
  | cons l w ih =>
      simp only [wordMatrix_cons, Matrix.mul_apply]
      rw [← Equiv.sum_comp (f : V ≃ W) (fun t => letterMatrix G' l (f u) t * wordMatrix G' w t (f v))]
      exact Finset.sum_congr rfl fun t _ =>
        congrArg₂ (· * ·) (letterMatrix_iso G G' f l u t) (ih t v)

/-- **All adjacency-degree moments are isomorphism invariants.** -/
theorem wordMoment_iso (f : G ≃g G') (w : List Letter) :
    wordMoment G' w = wordMoment G w := by
  simp only [wordMoment, moment_eq_sum']
  refine (Fintype.sum_equiv (f : V ≃ W) (fun u => ∑ v : V, wordMatrix G w u v)
    (fun u => ∑ v : W, wordMatrix G' w u v) fun u => ?_).symm
  exact (Fintype.sum_equiv (f : V ≃ W) (fun v => wordMatrix G w u v)
    (fun v => wordMatrix G' w (f u) v) fun v => (wordMatrix_iso G G' f w u v).symm)

end Iso

/-! ## Concrete moments -/

@[simp] lemma moment_one : moment (1 : Matrix V V ℝ) = (Fintype.card V : ℝ) := by
  rw [moment_eq_sum']
  simp [Matrix.one_apply, Finset.card_univ]

/-- Pure degree moments are the degree power sums. -/
theorem moment_degMatrix_pow (k : ℕ) :
    moment (degMatrix G ^ k) = ∑ v, (G.degree v : ℝ) ^ k := by
  have hpow : degMatrix G ^ k = Matrix.diagonal fun v => (G.degree v : ℝ) ^ k := by
    rw [degMatrix, Matrix.diagonal_pow]
    congr 1
  rw [hpow, moment_eq_sum']
  refine Finset.sum_congr rfl fun v _ => ?_
  simp [Matrix.diagonal_apply]

/-- Pure adjacency moments count walks. -/
theorem moment_adjMatrix_pow (k : ℕ) :
    moment ((G.adjMatrix ℝ) ^ k)
      = ∑ u, ∑ v, (Fintype.card {p : G.Walk u v // p.length = k} : ℝ) := by
  rw [moment_eq_sum']
  exact Finset.sum_congr rfl fun u _ => Finset.sum_congr rfl fun v _ =>
    G.adjMatrix_pow_apply_eq_card_walk k u v

omit [DecidableEq V] in
/-- The degree sum moment: `𝟏ᵀ A 𝟏 = ∑_v d_v = 2|E|`. -/
theorem moment_adjMatrix :
    moment (G.adjMatrix ℝ) = 2 * (G.edgeFinset.card : ℝ) := by
  rw [moment_eq_sum']
  have h : ∀ u : V, ∑ v, (G.adjMatrix ℝ) u v = (G.degree u : ℝ) := by
    intro u
    simp [SimpleGraph.adjMatrix_apply, SimpleGraph.degree,
      SimpleGraph.neighborFinset_eq_filter]
  simp only [h]
  have := SimpleGraph.sum_degrees_eq_twice_card_edges G
  have hcast : ((∑ v, G.degree v : ℕ) : ℝ) = ((2 * G.edgeFinset.card : ℕ) : ℝ) := by
    exact_mod_cast congrArg (fun n : ℕ => (n : ℝ)) this
  push_cast at hcast
  simp [hcast]

/-- The first genuinely degree-decorated moment. -/
theorem moment_degMatrix_mul_adjMatrix_mul_degMatrix :
    moment (degMatrix G * G.adjMatrix ℝ * degMatrix G)
      = ∑ u, ∑ v, (G.adjMatrix ℝ) u v * (G.degree u : ℝ) * (G.degree v : ℝ) := by
  rw [moment_eq_sum']
  refine Finset.sum_congr rfl fun u _ => Finset.sum_congr rfl fun v _ => ?_
  simp only [Matrix.mul_apply, degMatrix_apply, ite_mul, zero_mul, mul_ite, mul_zero,
    Finset.sum_ite_eq, Finset.sum_ite_eq', Finset.mem_univ, if_true]
  ring

end AdjDeg