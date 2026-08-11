import Physics.AdjacencyDegree.Moments

/-!
# Adjacency-degree moments are degree-decorated caterpillar homomorphism counts

A general word in `A` and `D` can be normalised (since `D` is diagonal) to a *caterpillar word*

`W(a) = D^{a₀} A D^{a₁} A ⋯ A D^{aₙ}`,

and its scalar moment `𝟏ᵀ W(a) 𝟏` is a sum over all walks `p₀ p₁ ⋯ pₙ` of length `n` of the
degree decoration `∏ᵢ d(pᵢ)^{aᵢ}`.

Main results:

* `AdjDeg.moment_catMat` : the moment of a caterpillar word equals the decorated walk sum;
* `AdjDeg.moment_catMat_eq_decorated_hom_count` : rewritten as a *homomorphism count*, i.e. a
  sum over graph homomorphisms from the path `Pₙ` (the caterpillar spine) weighted by the
  degree decoration;
* `AdjDeg.catMat_zero_exponents` : with trivial decoration one recovers `Aⁿ`, so pure walk
  counts are the undecorated specialisation.
-/

namespace AdjDeg

open Matrix Finset

variable {V : Type*} [Fintype V] [DecidableEq V]
variable (G : SimpleGraph V) [DecidableRel G.Adj]

/-- The caterpillar word `D^{a₀} A D^{a₁} A ⋯ A D^{aₙ}`. -/
def catMat : (n : ℕ) → (Fin (n + 1) → ℕ) → Matrix V V ℝ
  | 0, a => degMatrix G ^ a 0
  | (n + 1), a => degMatrix G ^ a 0 * G.adjMatrix ℝ * catMat n (fun i => a i.succ)

/-- The degree-decorated weight of a vertex tuple: the product of adjacency indicators along
the spine times the degree decoration. -/
def catWeight (n : ℕ) (a : Fin (n + 1) → ℕ) (p : Fin (n + 1) → V) : ℝ :=
  (∏ i : Fin n, (G.adjMatrix ℝ) (p i.castSucc) (p i.succ)) *
    ∏ i : Fin (n + 1), (G.degree (p i) : ℝ) ^ a i

omit [DecidableEq V] in
/-- Splitting a sum over tuples according to the first coordinate. -/
lemma sum_pi_fin_succ {M : Type*} [AddCommMonoid M] (n : ℕ) (F : (Fin (n + 1) → V) → M) :
    ∑ r : Fin (n + 1) → V, F r = ∑ w : V, ∑ q : Fin n → V, F (Fin.cons w q) := by
  have h1 : ∑ w : V, ∑ q : Fin n → V, F (Fin.cons w q)
      = ∑ x : V × (Fin n → V), F (Fin.cons x.1 x.2) :=
    (Fintype.sum_prod_type (f := fun x : V × (Fin n → V) => F (Fin.cons x.1 x.2))).symm
  rw [h1]
  exact (Fintype.sum_equiv (Fin.consEquiv fun _ => V)
    (fun x : V × (Fin n → V) => F (Fin.cons x.1 x.2)) F fun _ => rfl).symm

omit [DecidableEq V] in
/-- Peeling the first two vertices off a decorated weight. -/
lemma catWeight_cons_cons (n : ℕ) (a : Fin (n + 2) → ℕ) (u w : V) (q : Fin n → V) :
    catWeight G (n + 1) a (Fin.cons u (Fin.cons w q))
      = (G.degree u : ℝ) ^ a 0 * ((G.adjMatrix ℝ) u w *
          catWeight G n (fun i => a i.succ) (Fin.cons w q)) := by
  set s : Fin (n + 1) → V := Fin.cons w q with hs
  set t : Fin (n + 2) → V := Fin.cons u s with ht
  have hadj : (∏ i : Fin (n + 1), (G.adjMatrix ℝ) (t i.castSucc) (t i.succ))
      = (G.adjMatrix ℝ) u w * ∏ i : Fin n, (G.adjMatrix ℝ) (s i.castSucc) (s i.succ) := by
    rw [Fin.prod_univ_succ]
    congr 1
  have hdeg : (∏ i : Fin (n + 2), (G.degree (t i) : ℝ) ^ a i)
      = (G.degree u : ℝ) ^ a 0 * ∏ i : Fin (n + 1), (G.degree (s i) : ℝ) ^ a i.succ := by
    rw [Fin.prod_univ_succ]
    congr 1
  unfold catWeight
  rw [hadj, hdeg]
  ring

/-- The vector `W(a) 𝟏` is the decorated walk sum with fixed starting vertex. -/
lemma catMat_mulVec_ones :
    ∀ (n : ℕ) (a : Fin (n + 1) → ℕ) (u : V),
      (catMat G n a *ᵥ (1 : V → ℝ)) u = ∑ q : Fin n → V, catWeight G n a (Fin.cons u q) := by
  intro n
  induction n with
  | zero =>
      intro a u
      have hpow : degMatrix G ^ a 0 = Matrix.diagonal fun v => (G.degree v : ℝ) ^ a 0 := by
        rw [degMatrix, Matrix.diagonal_pow]
        congr 1
      simp only [catMat, hpow, Matrix.mulVec_diagonal, Pi.one_apply, mul_one, catWeight,
        Finset.univ_unique, Finset.sum_singleton, Fin.prod_univ_zero, one_mul]
      rw [Fin.prod_univ_succ]
      simp only [Fin.prod_univ_zero, mul_one]
      rw [Fin.cons_zero]
  | succ n ih =>
      intro a u
      have hstep : catMat G (n + 1) a
          = degMatrix G ^ a 0 * G.adjMatrix ℝ * catMat G n (fun i => a i.succ) := rfl
      have hpow : degMatrix G ^ a 0 = Matrix.diagonal fun v => (G.degree v : ℝ) ^ a 0 := by
        rw [degMatrix, Matrix.diagonal_pow]
        congr 1
      have hmul : (catMat G (n + 1) a *ᵥ (1 : V → ℝ)) u
          = (G.degree u : ℝ) ^ a 0 *
              ∑ w, (G.adjMatrix ℝ) u w * (catMat G n (fun i => a i.succ) *ᵥ (1 : V → ℝ)) w := by
        rw [hstep, ← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec, hpow,
          Matrix.mulVec_diagonal]
        simp [Matrix.mulVec, dotProduct]
      rw [hmul, sum_pi_fin_succ]
      rw [Finset.mul_sum]
      refine Finset.sum_congr rfl fun w _ => ?_
      rw [ih (fun i => a i.succ) w, Finset.mul_sum, Finset.mul_sum]
      refine Finset.sum_congr rfl fun q _ => ?_
      rw [catWeight_cons_cons]

/-- **The moment of a caterpillar word is a degree-decorated walk sum.** -/
theorem moment_catMat (n : ℕ) (a : Fin (n + 1) → ℕ) :
    moment (catMat G n a) = ∑ p : Fin (n + 1) → V, catWeight G n a p := by
  rw [moment_eq_sum_mulVec, sum_pi_fin_succ]
  exact Finset.sum_congr rfl fun u _ => catMat_mulVec_ones G n a u

omit [DecidableEq V] in
/-- The decorated weight is supported on walks. -/
lemma catWeight_eq_ite (n : ℕ) (a : Fin (n + 1) → ℕ) (p : Fin (n + 1) → V) :
    catWeight G n a p
      = if ∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ)
          then ∏ i : Fin (n + 1), (G.degree (p i) : ℝ) ^ a i else 0 := by
  unfold catWeight
  have hb : (∏ i : Fin n, (G.adjMatrix ℝ) (p i.castSucc) (p i.succ))
      = ∏ i : Fin n, (if G.Adj (p i.castSucc) (p i.succ) then (1 : ℝ) else 0) :=
    Finset.prod_congr rfl fun i _ => by
      by_cases h : G.Adj (p i.castSucc) (p i.succ) <;> simp [h]
  rw [hb, Fintype.prod_boole]
  by_cases h : ∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ) <;> simp [h]

/-- **Moments as degree-decorated caterpillar homomorphism counts.**  The moment
`𝟏ᵀ D^{a₀} A ⋯ A D^{aₙ} 𝟏` is the sum, over all homomorphic images of the path with `n+1`
vertices (i.e. all walks of length `n`), of the degree decoration `∏ᵢ d(pᵢ)^{aᵢ}`. -/
theorem moment_catMat_eq_decorated_hom_count (n : ℕ) (a : Fin (n + 1) → ℕ) :
    moment (catMat G n a)
      = ∑ p ∈ Finset.univ.filter
            (fun p : Fin (n + 1) → V => ∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ)),
          ∏ i : Fin (n + 1), (G.degree (p i) : ℝ) ^ a i := by
  rw [moment_catMat, Finset.sum_filter]
  exact Finset.sum_congr rfl fun p _ => catWeight_eq_ite G n a p

/-- With trivial decoration the caterpillar word is just a power of the adjacency matrix. -/
lemma catMat_zero_exponents (n : ℕ) :
    catMat G n (fun _ => 0) = (G.adjMatrix ℝ) ^ n := by
  induction n with
  | zero => simp [catMat]
  | succ n ih =>
      have hstep : catMat G (n + 1) (fun _ => 0)
          = degMatrix G ^ 0 * G.adjMatrix ℝ * catMat G n (fun _ => 0) := rfl
      rw [hstep, ih]
      simp [pow_succ, pow_mul_comm']

/-- Undecorated specialisation: the number of walks of length `n`, counted by `𝟏ᵀ Aⁿ 𝟏`,
is the number of adjacency-preserving tuples. -/
theorem moment_adjMatrix_pow_eq_card_walk_tuples (n : ℕ) :
    moment ((G.adjMatrix ℝ) ^ n)
      = (Finset.univ.filter
          (fun p : Fin (n + 1) → V => ∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ))).card := by
  rw [← catMat_zero_exponents G n, moment_catMat_eq_decorated_hom_count]
  simp

end AdjDeg