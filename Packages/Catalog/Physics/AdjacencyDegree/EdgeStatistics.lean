import Physics.AdjacencyDegree.DegreeRecovery

/-!
# Moment rigidity determines the degree-pair edge statistics

The words `D^i A D^j` are the shortest genuinely decorated caterpillars, and their moments are
`∑_{u ~ v} d_u^i d_v^j`.  Interpolating in both slots simultaneously turns these numbers into
the *joint degree distribution* of the graph: for every pair `(a, b)` the number of ordered
adjacent pairs of degrees `(a, b)` is determined by the adjacency-degree moments.

Main results:

* `AdjDeg.moment_degPow_adj_degPow` : `𝟏ᵀ D^i A D^j 𝟏 = ∑_{u,v} d_u^i A_{uv} d_v^j`;
* `AdjDeg.edgeStat_eq_sum_coeff` : the bilinear statistic `∑_{u,v} A_{uv} q(d_u) r(d_v)` is a
  finite combination of those moments;
* `AdjDeg.degreePairCount_eq_of_wordMoment_eq` : equal moments imply equal joint degree
  distributions.
-/

namespace AdjDeg

open Matrix Finset Polynomial

variable {V : Type*} [Fintype V] [DecidableEq V]
variable {W : Type*} [Fintype W] [DecidableEq W]
variable (G : SimpleGraph V) [DecidableRel G.Adj]
variable (G' : SimpleGraph W) [DecidableRel G'.Adj]

/-- The decorated edge statistic attached to a pair of polynomial decorations. -/
def edgeStat (q r : ℝ[X]) : ℝ :=
  ∑ u, ∑ v, (G.adjMatrix ℝ) u v * q.eval (G.degree u : ℝ) * r.eval (G.degree v : ℝ)

/-- The moment of `D^i A D^j`. -/
theorem moment_degPow_adj_degPow (i j : ℕ) :
    moment (degMatrix G ^ i * G.adjMatrix ℝ * degMatrix G ^ j)
      = ∑ u, ∑ v, (G.adjMatrix ℝ) u v * (G.degree u : ℝ) ^ i * (G.degree v : ℝ) ^ j := by
  have hi : degMatrix G ^ i = Matrix.diagonal fun v => (G.degree v : ℝ) ^ i := by
    rw [degMatrix, Matrix.diagonal_pow]; congr 1
  have hj : degMatrix G ^ j = Matrix.diagonal fun v => (G.degree v : ℝ) ^ j := by
    rw [degMatrix, Matrix.diagonal_pow]; congr 1
  rw [moment_eq_sum', hi, hj]
  refine Finset.sum_congr rfl fun u _ => Finset.sum_congr rfl fun v _ => ?_
  simp only [Matrix.mul_apply, Matrix.diagonal_apply, ite_mul, zero_mul, mul_ite, mul_zero,
    Finset.sum_ite_eq, Finset.sum_ite_eq', Finset.mem_univ, if_true]
  ring

/-- `D^i A D^j` is the matrix of an adjacency-degree word. -/
lemma wordMatrix_degPow_adj_degPow (i j : ℕ) :
    wordMatrix G (List.replicate i Letter.deg ++ Letter.adj :: List.replicate j Letter.deg)
      = degMatrix G ^ i * G.adjMatrix ℝ * degMatrix G ^ j := by
  simp [wordMatrix, letterMatrix, List.map_append, List.map_replicate, List.prod_append,
    List.prod_replicate, mul_assoc]

omit [Fintype V] [DecidableEq V] [DecidableRel G.Adj] in
/-- Interchanging a double vertex sum with a double coefficient sum. -/
lemma sum_comm4 {α β : Type*} [Fintype α] [Fintype β] (s t : Finset ℕ)
    (F : α → β → ℕ → ℕ → ℝ) :
    ∑ u : α, ∑ v : β, ∑ i ∈ s, ∑ j ∈ t, F u v i j
      = ∑ i ∈ s, ∑ j ∈ t, ∑ u : α, ∑ v : β, F u v i j := by
  have step1 : ∀ u : α, ∑ v : β, ∑ i ∈ s, ∑ j ∈ t, F u v i j
      = ∑ i ∈ s, ∑ v : β, ∑ j ∈ t, F u v i j := fun _ => Finset.sum_comm
  simp_rw [step1]
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl fun i _ => ?_
  have step2 : ∀ u : α, ∑ v : β, ∑ j ∈ t, F u v i j
      = ∑ j ∈ t, ∑ v : β, F u v i j := fun _ => Finset.sum_comm
  simp_rw [step2]
  rw [Finset.sum_comm]

/-- The decorated edge statistic expands into moments of the words `D^i A D^j`. -/
theorem edgeStat_eq_sum_coeff (q r : ℝ[X]) :
    edgeStat G q r
      = ∑ i ∈ Finset.range (q.natDegree + 1), ∑ j ∈ Finset.range (r.natDegree + 1),
          q.coeff i * r.coeff j *
            moment (degMatrix G ^ i * G.adjMatrix ℝ * degMatrix G ^ j) := by
  simp only [moment_degPow_adj_degPow]
  rw [edgeStat]
  have hexp : ∀ u v : V,
      (G.adjMatrix ℝ) u v * q.eval (G.degree u : ℝ) * r.eval (G.degree v : ℝ)
        = ∑ i ∈ Finset.range (q.natDegree + 1), ∑ j ∈ Finset.range (r.natDegree + 1),
            (G.adjMatrix ℝ) u v * (q.coeff i * (G.degree u : ℝ) ^ i) *
              (r.coeff j * (G.degree v : ℝ) ^ j) := by
    intro u v
    rw [Polynomial.eval_eq_sum_range (p := q), Finset.mul_sum, Finset.sum_mul]
    refine Finset.sum_congr rfl fun i _ => ?_
    rw [Polynomial.eval_eq_sum_range (p := r), Finset.mul_sum]
  simp_rw [hexp]
  rw [sum_comm4 (α := V) (β := V) (Finset.range (q.natDegree + 1))
    (Finset.range (r.natDegree + 1))
    (fun u v i j => (G.adjMatrix ℝ) u v * (q.coeff i * (G.degree u : ℝ) ^ i) *
      (r.coeff j * (G.degree v : ℝ) ^ j))]
  refine Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun u _ => ?_
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun v _ => ?_
  ring

/-- Moment equality transfers to all decorated edge statistics. -/
theorem edgeStat_eq_of_wordMoment_eq
    (h : ∀ w : List Letter, wordMoment G w = wordMoment G' w) (q r : ℝ[X]) :
    edgeStat G q r = edgeStat G' q r := by
  have hmom : ∀ i j : ℕ,
      moment (degMatrix G ^ i * G.adjMatrix ℝ * degMatrix G ^ j)
        = moment (degMatrix G' ^ i * G'.adjMatrix ℝ * degMatrix G' ^ j) := by
    intro i j
    have := h (List.replicate i Letter.deg ++ Letter.adj :: List.replicate j Letter.deg)
    rwa [wordMoment, wordMoment, wordMatrix_degPow_adj_degPow,
      wordMatrix_degPow_adj_degPow] at this
  rw [edgeStat_eq_sum_coeff, edgeStat_eq_sum_coeff]
  exact Finset.sum_congr rfl fun i _ => Finset.sum_congr rfl fun j _ => by rw [hmom i j]

/-- The number of ordered adjacent pairs with prescribed degrees. -/
def degreePairCount (a b : ℕ) : ℕ :=
  (Finset.univ.filter
    fun p : V × V => G.Adj p.1 p.2 ∧ G.degree p.1 = a ∧ G.degree p.2 = b).card

omit [DecidableEq V] in
/-- Choosing Lagrange indicators in both slots turns the edge statistic into a degree-pair
count. -/
theorem edgeStat_basis_eq_degreePairCount {a b : ℕ} (ha : a < Fintype.card V)
    (hb : b < Fintype.card V) :
    edgeStat G (Lagrange.basis (Finset.range (Fintype.card V)) (fun j : ℕ => (j : ℝ)) a)
        (Lagrange.basis (Finset.range (Fintype.card V)) (fun j : ℕ => (j : ℝ)) b)
      = (degreePairCount G a b : ℝ) := by
  set n := Fintype.card V
  have hval : ∀ (d : ℕ) (hd : d < n) (u : V),
      (Lagrange.basis (Finset.range n) (fun j : ℕ => (j : ℝ)) d).eval (G.degree u : ℝ)
        = if G.degree u = d then (1 : ℝ) else 0 := by
    intro d hd u
    have hmem : G.degree u ∈ Finset.range n :=
      Finset.mem_range.mpr (G.degree_lt_card_verts u)
    by_cases hu : G.degree u = d
    · rw [hu, if_pos rfl]
      exact Lagrange.eval_basis_self (injOn_cast_range n) (Finset.mem_range.mpr hd)
    · rw [if_neg hu]
      exact Lagrange.eval_basis_of_ne (Ne.symm hu) hmem
  rw [edgeStat]
  simp only [hval a ha, hval b hb]
  have hterm : ∀ u v : V,
      (G.adjMatrix ℝ) u v * (if G.degree u = a then (1 : ℝ) else 0) *
          (if G.degree v = b then (1 : ℝ) else 0)
        = if (G.Adj u v ∧ G.degree u = a ∧ G.degree v = b) then (1 : ℝ) else 0 := by
    intro u v
    by_cases h1 : G.Adj u v <;> by_cases h2 : G.degree u = a <;> by_cases h3 : G.degree v = b <;>
      simp [SimpleGraph.adjMatrix_apply, h1, h2, h3]
  simp only [hterm]
  rw [degreePairCount, ← Finset.sum_product']
  rw [Finset.sum_boole]
  norm_num

/-- **Moment rigidity determines the joint degree distribution.** -/
theorem degreePairCount_eq_of_wordMoment_eq
    (h : ∀ w : List Letter, wordMoment G w = wordMoment G' w) (a b : ℕ) :
    degreePairCount G a b = degreePairCount G' a b := by
  have hcard : Fintype.card V = Fintype.card W := card_eq_of_wordMoment_eq G G' h
  by_cases ha : a < Fintype.card V
  · by_cases hb : b < Fintype.card V
    · have h1 := edgeStat_basis_eq_degreePairCount G ha hb
      have h2 := edgeStat_basis_eq_degreePairCount G' (hcard ▸ ha) (hcard ▸ hb)
      have h3 := edgeStat_eq_of_wordMoment_eq G G' h
        (Lagrange.basis (Finset.range (Fintype.card V)) (fun j : ℕ => (j : ℝ)) a)
        (Lagrange.basis (Finset.range (Fintype.card V)) (fun j : ℕ => (j : ℝ)) b)
      rw [← hcard] at h2
      rw [h1, h2] at h3
      exact_mod_cast h3
    · push_neg at hb
      have e1 : degreePairCount G a b = 0 := by
        rw [degreePairCount, Finset.card_eq_zero]
        refine Finset.filter_eq_empty_iff.mpr fun p _ => ?_
        have := G.degree_lt_card_verts p.2
        rintro ⟨-, -, h3⟩
        omega
      have e2 : degreePairCount G' a b = 0 := by
        rw [degreePairCount, Finset.card_eq_zero]
        refine Finset.filter_eq_empty_iff.mpr fun p _ => ?_
        have := G'.degree_lt_card_verts p.2
        rintro ⟨-, -, h3⟩
        omega
      rw [e1, e2]
  · push_neg at ha
    have e1 : degreePairCount G a b = 0 := by
      rw [degreePairCount, Finset.card_eq_zero]
      refine Finset.filter_eq_empty_iff.mpr fun p _ => ?_
      have := G.degree_lt_card_verts p.1
      rintro ⟨-, h2, -⟩
      omega
    have e2 : degreePairCount G' a b = 0 := by
      rw [degreePairCount, Finset.card_eq_zero]
      refine Finset.filter_eq_empty_iff.mpr fun p _ => ?_
      have := G'.degree_lt_card_verts p.1
      rintro ⟨-, h2, -⟩
      omega
    rw [e1, e2]

end AdjDeg