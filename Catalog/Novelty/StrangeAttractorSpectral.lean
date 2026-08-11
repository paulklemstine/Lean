import Novelty.StrangeAttractorEntropy

/-!
# Strange attractors as algebraic objects, VIII: the spectral form of the entropy

The previous files of this thread produced two apparently unrelated descriptions of a
symbolic attractor: an *analytic* one — the topological entropy
`entropy = lim log #(FinPath E n) / n`, obtained from Fekete's subadditivity lemma — and an
*algebraic* one — the transfer matrix `adjMatrix E`, whose powers count the finite paths.
This file closes the gap between them, which was Conjecture 1 of the previous cycle's
`FUTURE_DIRECTIONS.md`: **the entropy is the logarithm of a Perron eigenvalue of the
transfer matrix**, and that eigenvalue is an algebraic integer.

Main results:

* `PerronDatum` : a strictly positive eigenvector of the transfer matrix together with its
  eigenvalue — the Perron–Frobenius data of the graph, taken as a hypothesis rather than
  produced (Mathlib has no Perron–Frobenius theorem);
* `PerronDatum.pow_eigen` : the eigenvector equation propagates to all matrix powers;
* `PerronDatum.exists_bounds` : consequently the approximant counts are pinched between two
  constant multiples of `value ^ n` — the combinatorial heart of the argument;
* `entropy_eq_log_perron` : `entropy = log value`, for *every* Perron datum;
* `perron_value_unique` : hence the Perron eigenvalue is unique, a rigidity statement about
  the transfer matrix proved by a purely dynamical route;
* `one_le_perron_value`, `perron_value_le_card` : `1 ≤ value ≤ #V`;
* `perron_det_eq_zero`, `isIntegral_perron_value`, `isIntegral_exp_entropy` : the Perron
  value is a root of the characteristic polynomial of the (integral!) transfer matrix, hence
  an **algebraic integer**; so `exp (entropy)` is an algebraic integer for every symbolic
  attractor admitting Perron data;
* `perronLorenz`, `perronPruned` and the corollaries `perron_value_lorenz`,
  `perron_value_pruned` : the two Lorenz templates carry Perron data with values `2` and the
  golden ratio `φ`, recovering `entropy = log 2` and `entropy = log φ` from linear algebra
  alone, and showing that *no other* positive eigenvalue exists for them.
-/

namespace LorenzLimit

open Filter Topology

variable {V : Type*} [Fintype V] [DecidableEq V] {E : V → V → Bool}

/-! ## Perron data -/

/-- A **Perron datum** for the finite directed graph `E`: a strictly positive eigenvector of
the transfer matrix, together with its eigenvalue.  It is an explicit hypothesis for the
results of this file, so they apply to any graph for which one can be exhibited; for a
*primitive* graph one always exists, which is proved in
`Catalog/Novelty/StrangeAttractorPerronFrobenius.lean` (`exists_perronDatum`) and makes every
statement below hypothesis-free there. -/
structure PerronDatum (E : V → V → Bool) where
  /-- The eigenvalue. -/
  value : ℝ
  /-- The eigenvector. -/
  vector : V → ℝ
  /-- The eigenvector is strictly positive. -/
  vector_pos : ∀ i, 0 < vector i
  /-- The eigenvector equation `A v = value • v`. -/
  eigen : ∀ i, ∑ j, (adjMatrix E i j : ℝ) * vector j = value * vector i

namespace PerronDatum

variable (p : PerronDatum E)

/-- The eigenvector equation propagates to every power of the transfer matrix:
`A ^ n v = value ^ n • v`. -/
theorem pow_eigen : ∀ (n : ℕ) (i : V),
    ∑ j, ((adjMatrix E ^ n) i j : ℝ) * p.vector j = p.value ^ n * p.vector i := by
  intro n
  induction n with
  | zero =>
      intro i
      simp [Matrix.one_apply, Finset.sum_ite_eq]
  | succ n ih =>
      intro i
      have hentry : ∀ j : V, ((adjMatrix E ^ (n + 1)) i j : ℝ)
          = ∑ k, ((adjMatrix E ^ n) i k : ℝ) * (adjMatrix E k j : ℝ) := by
        intro j
        rw [pow_succ, Matrix.mul_apply]
        push_cast
        ring
      calc ∑ j, ((adjMatrix E ^ (n + 1)) i j : ℝ) * p.vector j
          = ∑ j, ∑ k, ((adjMatrix E ^ n) i k : ℝ) * ((adjMatrix E k j : ℝ) * p.vector j) := by
            refine Finset.sum_congr rfl fun j _ => ?_
            rw [hentry j, Finset.sum_mul]
            exact Finset.sum_congr rfl fun k _ => by ring
        _ = ∑ k, ((adjMatrix E ^ n) i k : ℝ) * ∑ j, ((adjMatrix E k j : ℝ) * p.vector j) := by
            rw [Finset.sum_comm]
            exact Finset.sum_congr rfl fun k _ => by rw [Finset.mul_sum]
        _ = ∑ k, ((adjMatrix E ^ n) i k : ℝ) * (p.value * p.vector k) :=
            Finset.sum_congr rfl fun k _ => by rw [p.eigen k]
        _ = p.value * ∑ k, ((adjMatrix E ^ n) i k : ℝ) * p.vector k := by
            rw [Finset.mul_sum]
            exact Finset.sum_congr rfl fun k _ => by ring
        _ = p.value ^ (n + 1) * p.vector i := by rw [ih i]; ring

/-- Summing the eigenvector equation for `A ^ n` over all starting vertices. -/
theorem sum_pow_eigen (n : ℕ) :
    ∑ i, ∑ j, ((adjMatrix E ^ n) i j : ℝ) * p.vector j
      = p.value ^ n * ∑ i, p.vector i := by
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => p.pow_eigen n i

omit [DecidableEq V] in
/-- The eigenvalue of a Perron datum of a dead-end-free graph is positive. -/
theorem value_pos [Nonempty V] (h : NoDeadEnds E) : 0 < p.value := by
  obtain ⟨i⟩ := ‹Nonempty V›
  obtain ⟨j₀, hj₀⟩ := h i
  have hterm : (0 : ℝ) < (adjMatrix E i j₀ : ℝ) * p.vector j₀ := by
    have : adjMatrix E i j₀ = 1 := by simp [adjMatrix, hj₀]
    rw [this]
    simpa using p.vector_pos j₀
  have hnonneg : ∀ j ∈ (Finset.univ : Finset V), (0 : ℝ) ≤ (adjMatrix E i j : ℝ) * p.vector j :=
    fun j _ => mul_nonneg (by positivity) (p.vector_pos j).le
  have hsum : (0 : ℝ) < ∑ j, (adjMatrix E i j : ℝ) * p.vector j :=
    lt_of_lt_of_le hterm (Finset.single_le_sum hnonneg (Finset.mem_univ j₀))
  rw [p.eigen i] at hsum
  nlinarith [p.vector_pos i]

/-- **The counting bounds.**  A Perron datum pins the number of paths of length `n` between
two fixed multiples of `value ^ n`: the eigenvector's minimum and maximum are the only
constants involved. -/
theorem exists_bounds [Nonempty V] : ∃ a b : ℝ, 0 < a ∧ 0 < b ∧ ∀ n : ℕ,
    a * p.value ^ n ≤ (Fintype.card (FinPath E n) : ℝ) ∧
      (Fintype.card (FinPath E n) : ℝ) ≤ b * p.value ^ n := by
  obtain ⟨i₀, -, hmin⟩ :=
    Finset.exists_min_image (Finset.univ : Finset V) p.vector ⟨Classical.arbitrary V,
      Finset.mem_univ _⟩
  obtain ⟨i₁, -, hmax⟩ :=
    Finset.exists_max_image (Finset.univ : Finset V) p.vector ⟨Classical.arbitrary V,
      Finset.mem_univ _⟩
  set c := p.vector i₀ with hc
  set C := p.vector i₁ with hC
  have hcpos : 0 < c := p.vector_pos i₀
  have hCpos : 0 < C := p.vector_pos i₁
  have hS : 0 < ∑ i, p.vector i :=
    Finset.sum_pos (fun i _ => p.vector_pos i) ⟨Classical.arbitrary V, Finset.mem_univ _⟩
  refine ⟨(∑ i, p.vector i) / C, (∑ i, p.vector i) / c, by positivity, by positivity, ?_⟩
  intro n
  have hN : (Fintype.card (FinPath E n) : ℝ) = ∑ i, ∑ j, ((adjMatrix E ^ n) i j : ℝ) := by
    rw [card_finPath_eq_sum]
    push_cast
    rfl
  have hlow : c * (Fintype.card (FinPath E n) : ℝ) ≤ p.value ^ n * ∑ i, p.vector i := by
    rw [hN, ← p.sum_pow_eigen n, Finset.mul_sum]
    refine Finset.sum_le_sum fun i _ => ?_
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun j _ => ?_
    have h1 : c ≤ p.vector j := hmin j (Finset.mem_univ j)
    have h2 : (0 : ℝ) ≤ ((adjMatrix E ^ n) i j : ℝ) := by positivity
    nlinarith
  have hhigh : p.value ^ n * (∑ i, p.vector i) ≤ C * (Fintype.card (FinPath E n) : ℝ) := by
    rw [hN, ← p.sum_pow_eigen n, Finset.mul_sum]
    refine Finset.sum_le_sum fun i _ => ?_
    rw [Finset.mul_sum]
    refine Finset.sum_le_sum fun j _ => ?_
    have h1 : p.vector j ≤ C := hmax j (Finset.mem_univ j)
    have h2 : (0 : ℝ) ≤ ((adjMatrix E ^ n) i j : ℝ) := by positivity
    nlinarith
  constructor
  · rw [div_mul_eq_mul_div, div_le_iff₀ hCpos]
    nlinarith
  · rw [div_mul_eq_mul_div, le_div_iff₀ hcpos]
    nlinarith

end PerronDatum

/-! ## The entropy is the logarithm of the Perron value -/

/-- An affine sequence divided by `n` converges to its slope. -/
theorem tendsto_affine_div (a L : ℝ) :
    Tendsto (fun n : ℕ => (a + n * L) / n) atTop (𝓝 L) := by
  have h0 : Tendsto (fun n : ℕ => a / n) atTop (𝓝 0) :=
    tendsto_const_div_atTop_nhds_zero_nat a
  have h1 : Tendsto (fun n : ℕ => a / n + L) atTop (𝓝 (0 + L)) := h0.add tendsto_const_nhds
  rw [zero_add] at h1
  refine h1.congr' ?_
  filter_upwards [eventually_gt_atTop 0] with n hn
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  field_simp

/-- The approximant growth rate of a graph carrying a Perron datum is `log value`. -/
theorem tendsto_logCount_perron [Nonempty V] (h : NoDeadEnds E) (p : PerronDatum E) :
    Tendsto (fun n : ℕ => logCount E n / n) atTop (𝓝 (Real.log p.value)) := by
  obtain ⟨a, b, ha, hb, hab⟩ := p.exists_bounds
  have hr : 0 < p.value := p.value_pos h
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le'
    (tendsto_affine_div (Real.log a) (Real.log p.value))
    (tendsto_affine_div (Real.log b) (Real.log p.value)) ?_ ?_
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hnR : (0 : ℝ) < n := by exact_mod_cast hn
    have h1 : Real.log (a * p.value ^ n) ≤ Real.log (Fintype.card (FinPath E n)) :=
      Real.log_le_log (by positivity) (hab n).1
    rw [Real.log_mul (ne_of_gt ha) (by positivity), Real.log_pow] at h1
    have h2 : Real.log a + (n : ℝ) * Real.log p.value ≤ logCount E n := by
      rw [logCount]; linarith
    gcongr
  · filter_upwards [eventually_gt_atTop 0] with n hn
    have hnR : (0 : ℝ) < n := by exact_mod_cast hn
    have hpos : (0 : ℝ) < Fintype.card (FinPath E n) := by
      have := finPath_card_pos h n
      exact_mod_cast this
    have h1 : Real.log (Fintype.card (FinPath E n)) ≤ Real.log (b * p.value ^ n) :=
      Real.log_le_log hpos (hab n).2
    rw [Real.log_mul (ne_of_gt hb) (by positivity), Real.log_pow] at h1
    have h2 : logCount E n ≤ Real.log b + (n : ℝ) * Real.log p.value := by
      rw [logCount]; linarith
    gcongr

/-- **The spectral form of the entropy** (Conjecture 1 of the previous cycle).  For every
finite directed graph without dead ends carrying a Perron datum, the topological entropy of
the inverse-limit attractor is the logarithm of the Perron eigenvalue of its transfer
matrix.  The analytic invariant is thus computed by linear algebra. -/
theorem entropy_eq_log_perron [Nonempty V] (h : NoDeadEnds E) (p : PerronDatum E) :
    entropy h = Real.log p.value :=
  tendsto_nhds_unique (tendsto_entropy h) (tendsto_logCount_perron h p)

/-- **Uniqueness of the Perron value.**  Two positive eigenvectors of the transfer matrix
have the same eigenvalue — the dynamical proof of the uniqueness half of Perron–Frobenius. -/
theorem perron_value_unique [Nonempty V] (h : NoDeadEnds E) (p q : PerronDatum E) :
    p.value = q.value := by
  have hlog : Real.log p.value = Real.log q.value := by
    rw [← entropy_eq_log_perron h p, ← entropy_eq_log_perron h q]
  exact Real.log_injOn_pos (Set.mem_Ioi.mpr (p.value_pos h)) (Set.mem_Ioi.mpr (q.value_pos h)) hlog

omit [DecidableEq V] in
/-- The Perron value of a dead-end-free graph is at least `1`. -/
theorem one_le_perron_value [Nonempty V] (h : NoDeadEnds E) (p : PerronDatum E) :
    1 ≤ p.value := by
  obtain ⟨i₀, -, hmin⟩ :=
    Finset.exists_min_image (Finset.univ : Finset V) p.vector ⟨Classical.arbitrary V,
      Finset.mem_univ _⟩
  obtain ⟨j₀, hj₀⟩ := h i₀
  have hterm : p.vector j₀ ≤ ∑ j, (adjMatrix E i₀ j : ℝ) * p.vector j := by
    have hA : adjMatrix E i₀ j₀ = 1 := by simp [adjMatrix, hj₀]
    have hnonneg : ∀ j ∈ (Finset.univ : Finset V),
        (0 : ℝ) ≤ (adjMatrix E i₀ j : ℝ) * p.vector j :=
      fun j _ => mul_nonneg (by positivity) (p.vector_pos j).le
    have := Finset.single_le_sum hnonneg (Finset.mem_univ j₀)
    rwa [hA, Nat.cast_one, one_mul] at this
  rw [p.eigen i₀] at hterm
  have h1 : p.vector i₀ ≤ p.vector j₀ := hmin j₀ (Finset.mem_univ j₀)
  have h2 : 0 < p.vector i₀ := p.vector_pos i₀
  nlinarith

/-- The Perron value is at most the number of vertices: the entropy bound `log #V` in
spectral form. -/
theorem perron_value_le_card [Nonempty V] (h : NoDeadEnds E) (p : PerronDatum E) :
    p.value ≤ Fintype.card V := by
  have hlog : Real.log p.value ≤ Real.log (Fintype.card V) := by
    rw [← entropy_eq_log_perron h p]
    exact entropy_le_log_card h
  have hVpos : (0 : ℝ) < Fintype.card V := by
    have : 0 < Fintype.card V := Fintype.card_pos
    exact_mod_cast this
  exact (Real.log_le_log_iff (p.value_pos h) hVpos).mp hlog

/-! ## The Perron value is an algebraic integer -/

/-- The Perron value is an eigenvalue in the linear-algebra sense: the matrix
`value • 1 - A` is singular. -/
theorem perron_det_eq_zero [Nonempty V] (p : PerronDatum E) :
    (Matrix.scalar V p.value - (adjMatrix E).map (fun n : ℕ => (n : ℝ))).det = 0 := by
  rw [← Matrix.exists_mulVec_eq_zero_iff]
  refine ⟨p.vector, ?_, ?_⟩
  · intro hv
    have h0 := p.vector_pos (Classical.arbitrary V)
    rw [hv] at h0
    simp at h0
  · funext i
    have hsplit : ∑ j, ((if i = j then p.value else 0) - (adjMatrix E i j : ℝ)) * p.vector j
        = (∑ j, (if i = j then p.value else 0) * p.vector j)
          - ∑ j, (adjMatrix E i j : ℝ) * p.vector j := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl fun j _ => by ring
    have hdiag : (∑ j, (if i = j then p.value else 0) * p.vector j) = p.value * p.vector i := by
      simp
    simp only [Matrix.mulVec, dotProduct, Matrix.sub_apply, Matrix.scalar_apply,
      Matrix.diagonal_apply, Matrix.map_apply, Pi.zero_apply]
    rw [hsplit, hdiag, p.eigen i, sub_self]

/-- **The Perron value is an algebraic integer.**  It is a root of the characteristic
polynomial of the integral transfer matrix, which is monic. -/
theorem isIntegral_perron_value [Nonempty V] (p : PerronDatum E) :
    IsIntegral ℤ p.value := by
  refine ⟨((adjMatrix E).map (fun n : ℕ => (n : ℤ))).charpoly, Matrix.charpoly_monic _, ?_⟩
  have hmap : ((adjMatrix E).map (fun n : ℕ => (n : ℤ))).map (Int.castRingHom ℝ)
      = (adjMatrix E).map (fun n : ℕ => (n : ℝ)) := by
    rw [Matrix.map_map]
    ext i j
    simp
  rw [Polynomial.eval₂_eq_eval_map]
  have halg : (algebraMap ℤ ℝ) = Int.castRingHom ℝ := rfl
  rw [halg, ← Matrix.charpoly_map, Matrix.eval_charpoly, hmap]
  exact perron_det_eq_zero p

/-- **`exp` of the entropy is an algebraic integer.**  The topological entropy of a symbolic
attractor carrying Perron data is the logarithm of an algebraic integer — an arithmetic
constraint on a dynamical invariant. -/
theorem isIntegral_exp_entropy [Nonempty V] (h : NoDeadEnds E) (p : PerronDatum E) :
    IsIntegral ℤ (Real.exp (entropy h)) := by
  rw [entropy_eq_log_perron h p, Real.exp_log (p.value_pos h)]
  exact isIntegral_perron_value p

/-! ## The two Lorenz templates, spectrally -/

section Templates

open Real

/-- The Perron datum of the Lorenz template: the constant eigenvector with eigenvalue `2`. -/
def perronLorenz : PerronDatum lorenzTemplate where
  value := 2
  vector := fun _ => 1
  vector_pos := fun _ => one_pos
  eigen := by
    intro i
    simp [adjMatrix, lorenzTemplate]

/-- The Perron datum of the pruned template: the eigenvector `(φ, 1)` with eigenvalue the
golden ratio. -/
noncomputable def perronPruned : PerronDatum prunedTemplate where
  value := goldenRatio
  vector := fun b => if b then 1 else goldenRatio
  vector_pos := by
    intro i
    cases i with
    | false => simpa using goldenRatio_pos
    | true => norm_num
  eigen := by
    intro i
    have hsq : (goldenRatio : ℝ) ^ 2 = goldenRatio + 1 := goldenRatio_sq
    cases i with
    | false =>
        simp [adjMatrix, prunedTemplate]
        nlinarith
    | true =>
        simp [adjMatrix, prunedTemplate]

/-- The Lorenz template's entropy, computed spectrally: `log 2` is the logarithm of the
Perron eigenvalue of the two-vertex complete graph. -/
theorem entropy_lorenz_spectral :
    entropy (Branching.noDeadEnds branching_lorenzTemplate) = Real.log 2 :=
  entropy_eq_log_perron _ perronLorenz

/-- The pruned template's entropy, computed spectrally: `log φ` is the logarithm of the
Perron eigenvalue of the Fibonacci graph. -/
theorem entropy_pruned_spectral :
    entropy noDeadEnds_prunedTemplate = Real.log goldenRatio :=
  entropy_eq_log_perron _ perronPruned

/-- **Rigidity for the Lorenz template.**  `2` is the *only* eigenvalue of its transfer
matrix admitting a strictly positive eigenvector. -/
theorem perron_value_lorenz (p : PerronDatum lorenzTemplate) : p.value = 2 :=
  perron_value_unique (Branching.noDeadEnds branching_lorenzTemplate) p perronLorenz

/-- **Rigidity for the pruned template.**  Its only positive eigenvalue is the golden
ratio. -/
theorem perron_value_pruned (p : PerronDatum prunedTemplate) : p.value = goldenRatio :=
  perron_value_unique noDeadEnds_prunedTemplate p perronPruned

/-- The golden ratio is a Perron value strictly below `2`. -/
theorem goldenRatio_lt_two : (goldenRatio : ℝ) < 2 := by
  have h5 : Real.sqrt 5 < 3 := by
    rw [show (3 : ℝ) = Real.sqrt 9 by
      rw [show (9 : ℝ) = 3 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)]]
    exact Real.sqrt_lt_sqrt (by norm_num) (by norm_num)
  unfold Real.goldenRatio
  linarith

/-- The two templates are separated spectrally: their Perron values differ, which by
`entropy_eq_log_perron` re-proves that their entropies — hence the attractors themselves —
are different. -/
theorem perron_value_lorenz_ne_pruned : perronLorenz.value ≠ perronPruned.value := by
  intro hEq
  have h1 : perronLorenz.value = (2 : ℝ) := rfl
  have h2 : perronPruned.value = goldenRatio := rfl
  rw [h1, h2] at hEq
  have := goldenRatio_lt_two
  linarith

end Templates

end LorenzLimit