import Physics.AdjacencyDegree.EdgeStatistics

/-!
# Moment rigidity determines all degree-decorated walk statistics

`EdgeStatistics.lean` shows that the moments of the words `D^i A D^j` determine the joint
degree distribution of the edges.  Here we prove the *full caterpillar version* of that
statement, which is the exact rigidity content of the phrase "the moments are
degree-decorated caterpillar homomorphism counts".

For a walk `p₀ ~ p₁ ~ ⋯ ~ p_n` and arbitrary weight functions `f₀, …, f_n : ℕ → ℝ` of the
degree, put

`walkStat(f) = ∑_{p} (∏ᵢ A_{pᵢ pᵢ₊₁}) ∏ᵢ fᵢ(d(pᵢ))`.

Main results:

* `AdjDeg.catWord` / `AdjDeg.wordMatrix_catWord` : caterpillar words are honest words in the
  alphabet `{A, D}`;
* `AdjDeg.walkStat_poly_eq_sum_coeff` : a *polynomially* decorated walk statistic is a finite
  linear combination of caterpillar moments, the coefficients being products of polynomial
  coefficients indexed by `Fintype.piFinset`;
* `AdjDeg.walkStat_eq_of_wordMoment_eq` : moment equality transfers to **arbitrary** decorated
  walk statistics (Lagrange interpolation in every spine slot simultaneously);
* `AdjDeg.degWalkCount_eq_of_wordMoment_eq` : consequently, for every length `n` and every
  prescribed degree pattern `b : Fin (n+1) → ℕ`, the number of walks whose degree sequence is
  exactly `b` is a moment invariant.  For `n = 1` this is the joint degree distribution
  (`degreePairCount`), for `n = 0` the degree distribution.
-/

namespace AdjDeg

open Matrix Finset Polynomial

variable {V : Type*} [Fintype V] [DecidableEq V]
variable {W : Type*} [Fintype W] [DecidableEq W]
variable (G : SimpleGraph V) [DecidableRel G.Adj]
variable (G' : SimpleGraph W) [DecidableRel G'.Adj]

/-! ## Caterpillar words -/

/-- The word `D^{a₀} A D^{a₁} A ⋯ A D^{aₙ}` in the alphabet `{A, D}`. -/
def catWord : (n : ℕ) → (Fin (n + 1) → ℕ) → List Letter
  | 0, a => List.replicate (a 0) Letter.deg
  | (n + 1), a =>
      List.replicate (a 0) Letter.deg ++ Letter.adj :: catWord n (fun i => a i.succ)

lemma wordMatrix_append (w₁ w₂ : List Letter) :
    wordMatrix G (w₁ ++ w₂) = wordMatrix G w₁ * wordMatrix G w₂ := by
  simp [wordMatrix, List.map_append, List.prod_append]

lemma wordMatrix_replicate_deg (k : ℕ) :
    wordMatrix G (List.replicate k Letter.deg) = degMatrix G ^ k := by
  simp [wordMatrix, letterMatrix, List.map_replicate, List.prod_replicate]

/-- The matrix of a caterpillar word is the caterpillar matrix. -/
lemma wordMatrix_catWord :
    ∀ (n : ℕ) (a : Fin (n + 1) → ℕ), wordMatrix G (catWord n a) = catMat G n a := by
  intro n
  induction n with
  | zero => intro a; rw [catWord, wordMatrix_replicate_deg]; rfl
  | succ n ih =>
      intro a
      have hstep : catMat G (n + 1) a
          = degMatrix G ^ a 0 * G.adjMatrix ℝ * catMat G n (fun i => a i.succ) := rfl
      rw [catWord, wordMatrix_append, wordMatrix_replicate_deg, wordMatrix_cons,
        ih (fun i => a i.succ), hstep]
      simp [letterMatrix, mul_assoc]

/-- Caterpillar moments are word moments. -/
lemma moment_catMat_eq_wordMoment (n : ℕ) (a : Fin (n + 1) → ℕ) :
    moment (catMat G n a) = wordMoment G (catWord n a) := by
  rw [wordMoment, wordMatrix_catWord]

/-! ## Decorated walk statistics -/

/-- The walk statistic with an arbitrary degree decoration in every spine slot. -/
def walkStat (n : ℕ) (f : Fin (n + 1) → ℕ → ℝ) : ℝ :=
  ∑ p : Fin (n + 1) → V,
    (∏ i : Fin n, (G.adjMatrix ℝ) (p i.castSucc) (p i.succ)) *
      ∏ i : Fin (n + 1), f i (G.degree (p i))

omit [Fintype V] [DecidableEq V] in
/-- The adjacency factor is the indicator of being a walk. -/
lemma prod_adj_eq_ite (n : ℕ) (p : Fin (n + 1) → V) :
    (∏ i : Fin n, (G.adjMatrix ℝ) (p i.castSucc) (p i.succ))
      = if ∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ) then (1 : ℝ) else 0 := by
  have hb : (∏ i : Fin n, (G.adjMatrix ℝ) (p i.castSucc) (p i.succ))
      = ∏ i : Fin n, (if G.Adj (p i.castSucc) (p i.succ) then (1 : ℝ) else 0) :=
    Finset.prod_congr rfl fun i _ => by
      by_cases h : G.Adj (p i.castSucc) (p i.succ) <;> simp [h]
  rw [hb, Fintype.prod_boole]
  simp

/-- **Polynomially decorated walk statistics are finite combinations of caterpillar moments.**
Expanding each decoration into its coefficients turns the statistic into a sum over
multi-exponents `a : Fin (n+1) → ℕ` of caterpillar moments `𝟏ᵀ D^{a₀} A ⋯ A D^{aₙ} 𝟏`. -/
theorem walkStat_poly_eq_sum_coeff (n : ℕ) (q : Fin (n + 1) → ℝ[X]) :
    walkStat G n (fun i d => (q i).eval (d : ℝ))
      = ∑ a ∈ Fintype.piFinset (fun i : Fin (n + 1) => Finset.range ((q i).natDegree + 1)),
          (∏ i : Fin (n + 1), (q i).coeff (a i)) * moment (catMat G n a) := by
  have hmom : ∀ a : Fin (n + 1) → ℕ,
      moment (catMat G n a) = ∑ p : Fin (n + 1) → V, catWeight G n a p := fun a =>
    moment_catMat G n a
  simp_rw [hmom, Finset.mul_sum]
  rw [walkStat, Finset.sum_comm]
  refine Finset.sum_congr rfl fun p _ => ?_
  -- expand the product of decorations over the multi-index set
  have hq' : ∀ i : Fin (n + 1), (q i).eval (G.degree (p i) : ℝ)
      = ∑ k ∈ Finset.range ((q i).natDegree + 1),
          (q i).coeff k * (G.degree (p i) : ℝ) ^ k :=
    fun i => Polynomial.eval_eq_sum_range _
  have hexp : (∏ i : Fin (n + 1), (q i).eval (G.degree (p i) : ℝ))
      = ∑ a ∈ Fintype.piFinset (fun i : Fin (n + 1) => Finset.range ((q i).natDegree + 1)),
          ∏ i : Fin (n + 1), (q i).coeff (a i) * (G.degree (p i) : ℝ) ^ (a i) := by
    simp_rw [hq']
    rw [Finset.prod_univ_sum]
  rw [hexp, Finset.mul_sum]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [Finset.prod_mul_distrib, catWeight]
  ring

/-- Moment equality transfers to all polynomially decorated walk statistics. -/
theorem walkStat_poly_eq_of_wordMoment_eq
    (h : ∀ w : List Letter, wordMoment G w = wordMoment G' w) (n : ℕ) (q : Fin (n + 1) → ℝ[X]) :
    walkStat G n (fun i d => (q i).eval (d : ℝ))
      = walkStat G' n (fun i d => (q i).eval (d : ℝ)) := by
  rw [walkStat_poly_eq_sum_coeff, walkStat_poly_eq_sum_coeff]
  refine Finset.sum_congr rfl fun a _ => ?_
  rw [moment_catMat_eq_wordMoment, moment_catMat_eq_wordMoment, h]

/-- The interpolating polynomial of a weight function on the possible degrees `0, …, N-1`. -/
noncomputable def degInterp (N : ℕ) (g : ℕ → ℝ) : ℝ[X] :=
  Lagrange.interpolate (Finset.range N) (fun j : ℕ => (j : ℝ)) g

lemma eval_degInterp {N d : ℕ} (g : ℕ → ℝ) (hd : d < N) :
    (degInterp N g).eval (d : ℝ) = g d :=
  Lagrange.eval_interpolate_at_node g (injOn_cast_range N) (Finset.mem_range.mpr hd)

omit [DecidableEq V] in
/-- Replacing a decoration by its interpolating polynomial does not change the statistic. -/
lemma walkStat_congr_of_eval (n : ℕ) (f g : Fin (n + 1) → ℕ → ℝ)
    (hfg : ∀ (i : Fin (n + 1)) (v : V), f i (G.degree v) = g i (G.degree v)) :
    walkStat G n f = walkStat G n g := by
  refine Finset.sum_congr rfl fun p _ => ?_
  congr 1
  exact Finset.prod_congr rfl fun i _ => hfg i (p i)

/-- **Moment rigidity determines every degree-decorated walk statistic.**  If two graphs have
the same adjacency-degree word moments, then for every walk length `n` and *arbitrary* weight
functions of the degree at each position of the spine, the decorated walk sums agree. -/
theorem walkStat_eq_of_wordMoment_eq
    (h : ∀ w : List Letter, wordMoment G w = wordMoment G' w) (n : ℕ) (f : Fin (n + 1) → ℕ → ℝ) :
    walkStat G n f = walkStat G' n f := by
  set N := Fintype.card V with hN
  have hcard : Fintype.card V = Fintype.card W := card_eq_of_wordMoment_eq G G' h
  set q : Fin (n + 1) → ℝ[X] := fun i => degInterp N (f i) with hq
  have hG : walkStat G n f = walkStat G n (fun i d => (q i).eval (d : ℝ)) := by
    refine walkStat_congr_of_eval G n f _ fun i v => ?_
    rw [hq]
    exact (eval_degInterp (f i) (G.degree_lt_card_verts v)).symm
  have hG' : walkStat G' n f = walkStat G' n (fun i d => (q i).eval (d : ℝ)) := by
    refine walkStat_congr_of_eval G' n f _ fun i v => ?_
    rw [hq]
    refine (eval_degInterp (f i) ?_).symm
    rw [hN, hcard]
    exact G'.degree_lt_card_verts v
  rw [hG, hG', walkStat_poly_eq_of_wordMoment_eq G G' h]

/-! ## Degree-decorated walk counts -/

/-- The number of walks `p₀ ~ ⋯ ~ pₙ` whose degree sequence is exactly `b`. -/
def degWalkCount (n : ℕ) (b : Fin (n + 1) → ℕ) : ℕ :=
  (Finset.univ.filter fun p : Fin (n + 1) → V =>
      (∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ)) ∧ ∀ i : Fin (n + 1), G.degree (p i) = b i).card

omit [DecidableEq V] in
/-- The indicator decoration realises the decorated walk count. -/
lemma walkStat_indicator (n : ℕ) (b : Fin (n + 1) → ℕ) :
    walkStat G n (fun i d => if d = b i then (1 : ℝ) else 0) = (degWalkCount G n b : ℝ) := by
  rw [walkStat, degWalkCount]
  have hterm : ∀ p : Fin (n + 1) → V,
      (∏ i : Fin n, (G.adjMatrix ℝ) (p i.castSucc) (p i.succ)) *
          (∏ i : Fin (n + 1), if G.degree (p i) = b i then (1 : ℝ) else 0)
        = if ((∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ)) ∧
              ∀ i : Fin (n + 1), G.degree (p i) = b i) then (1 : ℝ) else 0 := by
    intro p
    rw [prod_adj_eq_ite, Fintype.prod_boole]
    by_cases h1 : ∀ i : Fin n, G.Adj (p i.castSucc) (p i.succ) <;>
      by_cases h2 : ∀ i : Fin (n + 1), G.degree (p i) = b i <;> simp [h1, h2]
  simp only [hterm]
  rw [Finset.sum_boole]

/-- **The degree-decorated caterpillar counts are moment invariants.**  Two graphs with equal
adjacency-degree word moments have, for every length `n` and every prescribed degree pattern
`b`, the same number of walks realising that pattern. -/
theorem degWalkCount_eq_of_wordMoment_eq
    (h : ∀ w : List Letter, wordMoment G w = wordMoment G' w) (n : ℕ) (b : Fin (n + 1) → ℕ) :
    degWalkCount G n b = degWalkCount G' n b := by
  have := walkStat_eq_of_wordMoment_eq G G' h n (fun i d => if d = b i then (1 : ℝ) else 0)
  rw [walkStat_indicator, walkStat_indicator] at this
  exact_mod_cast this

omit [DecidableEq V] in
/-- Specialisation `n = 0`: the degree distribution is recovered (compare
`degree_card_eq_of_wordMoment_eq`). -/
lemma degWalkCount_zero (d : ℕ) :
    degWalkCount G 0 (fun _ => d) = (Finset.univ.filter fun v : V => G.degree v = d).card := by
  rw [degWalkCount]
  refine Finset.card_bij' (fun p _ => p 0) (fun v _ => fun _ => v) (fun p hp => ?_)
    (fun v hv => ?_) (fun p hp => ?_) (fun v _ => rfl)
  · simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hp ⊢
    exact hp.2 0
  · simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hv ⊢
    exact ⟨fun i => i.elim0, fun _ => hv⟩
  · funext i
    have : i = 0 := Fin.fin_one_eq_zero i
    rw [this]

end AdjDeg