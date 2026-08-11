import Physics.AdjacencyDegree.Caterpillar

/-!
# Moment rigidity recovers the degree distribution

The pure degree moments `𝟏ᵀ D^k 𝟏 = ∑_v d_v^k` are power sums of the degree sequence.
Because all degrees of a graph on `n` vertices lie in `{0, …, n-1}`, Lagrange interpolation
on those nodes converts the power sums into the individual degree multiplicities.  Hence

> two graphs with equal adjacency-degree moments have the *same degree distribution*,

which is the first non-trivial combinatorial consequence of moment rigidity, and the base
case of the colour-refinement hierarchy discussed in the paper.

Main results:

* `AdjDeg.sum_eval_eq_of_degree_moments_eq` : moment equality transfers to *all* polynomial
  test functions of the degree;
* `AdjDeg.degree_card_eq_of_degree_moments_eq` : equality of degree multiplicities;
* `AdjDeg.degree_card_eq_of_wordMoment_eq` : the same conclusion from equality of all
  adjacency-degree word moments.
-/

namespace AdjDeg

open Matrix Finset Polynomial

variable {V : Type*} [Fintype V] [DecidableEq V]
variable {W : Type*} [Fintype W] [DecidableEq W]
variable (G : SimpleGraph V) [DecidableRel G.Adj]
variable (G' : SimpleGraph W) [DecidableRel G'.Adj]

/-- Degree power sums are the pure `D`-moments. -/
lemma wordMoment_replicate_deg (k : ℕ) :
    wordMoment G (List.replicate k Letter.deg) = ∑ v, (G.degree v : ℝ) ^ k := by
  have : wordMatrix G (List.replicate k Letter.deg) = degMatrix G ^ k := by
    simp [wordMatrix, letterMatrix, List.map_replicate, List.prod_replicate]
  rw [wordMoment, this, moment_degMatrix_pow]

/-- Expanding a polynomial test function of an integer statistic into power sums. -/
lemma sum_eval_eq_sum_coeff {U : Type*} [Fintype U] (q : ℝ[X]) (d : U → ℕ) :
    ∑ u : U, q.eval (d u : ℝ)
      = ∑ i ∈ Finset.range (q.natDegree + 1), q.coeff i * ∑ u : U, (d u : ℝ) ^ i := by
  simp_rw [Polynomial.eval_eq_sum_range, Finset.mul_sum]
  rw [Finset.sum_comm]

omit [DecidableEq V] [DecidableEq W] in
/-- If all degree power sums agree, then all polynomial test functions of the degree agree. -/
theorem sum_eval_eq_of_degree_moments_eq
    (h : ∀ k : ℕ, ∑ v, (G.degree v : ℝ) ^ k = ∑ w, (G'.degree w : ℝ) ^ k) (q : ℝ[X]) :
    ∑ v, q.eval (G.degree v : ℝ) = ∑ w, q.eval (G'.degree w : ℝ) := by
  rw [sum_eval_eq_sum_coeff q (fun v => G.degree v), sum_eval_eq_sum_coeff q
    (fun w => G'.degree w)]
  exact Finset.sum_congr rfl fun i _ => by rw [h i]

/-- Nodes `0, 1, …, n-1` are pairwise distinct as real numbers. -/
lemma injOn_cast_range (n : ℕ) :
    Set.InjOn (fun j : ℕ => (j : ℝ)) (Finset.range n) :=
  fun _ _ _ _ hxy => Nat.cast_injective hxy

/-- Summing the `d`-th Lagrange indicator over the degrees counts the vertices of degree `d`. -/
lemma sum_eval_basis_eq_card {U : Type*} [Fintype U] [DecidableEq U]
    (H : SimpleGraph U) [DecidableRel H.Adj] (n d : ℕ) (hU : Fintype.card U = n) (hd : d < n) :
    ∑ u : U, (Lagrange.basis (Finset.range n) (fun j : ℕ => (j : ℝ)) d).eval (H.degree u : ℝ)
      = ((Finset.univ.filter fun u : U => H.degree u = d).card : ℝ) := by
  set q : ℝ[X] := Lagrange.basis (Finset.range n) (fun j : ℕ => (j : ℝ)) d with hq
  have hself : q.eval (d : ℝ) = 1 :=
    Lagrange.eval_basis_self (injOn_cast_range n) (Finset.mem_range.mpr hd)
  have hval : ∀ u : U, q.eval (H.degree u : ℝ) = if H.degree u = d then 1 else 0 := by
    intro u
    have hmem : H.degree u ∈ Finset.range n :=
      Finset.mem_range.mpr (hU ▸ H.degree_lt_card_verts u)
    by_cases hu : H.degree u = d
    · rw [hu, hself]
      simp
    · rw [Lagrange.eval_basis_of_ne (Ne.symm hu) hmem, if_neg hu]
  simp_rw [hval]
  rw [Finset.sum_ite, Finset.sum_const, Finset.sum_const]
  simp

/-- **Moment rigidity determines the degree distribution.** If two finite simple graphs have
the same degree power sums, then for every `d` they have the same number of vertices of
degree `d`. -/
theorem degree_card_eq_of_degree_moments_eq
    (h : ∀ k : ℕ, ∑ v, (G.degree v : ℝ) ^ k = ∑ w, (G'.degree w : ℝ) ^ k) (d : ℕ) :
    (Finset.univ.filter fun v : V => G.degree v = d).card
      = (Finset.univ.filter fun w : W => G'.degree w = d).card := by
  -- the two graphs have the same number of vertices (`k = 0`)
  have hcard : (Fintype.card V : ℝ) = (Fintype.card W : ℝ) := by
    have := h 0
    simpa [Finset.card_univ] using this
  have hcardN : Fintype.card V = Fintype.card W := by exact_mod_cast hcard
  set n := Fintype.card V with hn
  by_cases hd : d < n
  · -- interpolate the indicator of `d` on the nodes `0, …, n-1`
    have h1 := sum_eval_basis_eq_card G n d rfl hd
    have h2 := sum_eval_basis_eq_card G' n d hcardN.symm hd
    have h3 := sum_eval_eq_of_degree_moments_eq G G' h
      (Lagrange.basis (Finset.range n) (fun j : ℕ => (j : ℝ)) d)
    rw [h1, h2] at h3
    exact_mod_cast h3
  · -- large `d` cannot occur as a degree
    push_neg at hd
    have e1 : (Finset.univ.filter fun v : V => G.degree v = d) = ∅ := by
      refine Finset.filter_eq_empty_iff.mpr fun v _ => ?_
      have := G.degree_lt_card_verts v
      omega
    have e2 : (Finset.univ.filter fun w : W => G'.degree w = d) = ∅ := by
      refine Finset.filter_eq_empty_iff.mpr fun w _ => ?_
      have := G'.degree_lt_card_verts w
      omega
    rw [e1, e2]
    rfl

/-- **Word-moment version.** Graphs with the same adjacency-degree word moments have the same
degree distribution. -/
theorem degree_card_eq_of_wordMoment_eq
    (h : ∀ w : List Letter, wordMoment G w = wordMoment G' w) (d : ℕ) :
    (Finset.univ.filter fun v : V => G.degree v = d).card
      = (Finset.univ.filter fun w : W => G'.degree w = d).card := by
  refine degree_card_eq_of_degree_moments_eq G G' (fun k => ?_) d
  rw [← wordMoment_replicate_deg G k, ← wordMoment_replicate_deg G' k]
  exact h _

/-- Moment rigidity determines the number of vertices. -/
theorem card_eq_of_wordMoment_eq
    (h : ∀ w : List Letter, wordMoment G w = wordMoment G' w) :
    Fintype.card V = Fintype.card W := by
  have := h []
  simp only [wordMoment, wordMatrix_nil, moment_one] at this
  exact_mod_cast this

/-- Moment rigidity determines the number of edges. -/
theorem card_edges_eq_of_wordMoment_eq
    (h : ∀ w : List Letter, wordMoment G w = wordMoment G' w) :
    G.edgeFinset.card = G'.edgeFinset.card := by
  have := h [Letter.adj]
  simp only [wordMoment, wordMatrix_cons, wordMatrix_nil, mul_one, letterMatrix] at this
  rw [moment_adjMatrix, moment_adjMatrix] at this
  have h2 : (G.edgeFinset.card : ℝ) = (G'.edgeFinset.card : ℝ) := by linarith
  exact_mod_cast h2

end AdjDeg