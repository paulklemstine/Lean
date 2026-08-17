import MachineLearning.HyperAwareness11D.Equivariance

/-!
# Hyper-Awareness V: the parity dividend — every 11-dimensional layer has an invariant percept

Dimension `11` is *odd*, and this file extracts the structural dividend that odd parity pays
to an 11-dimensional perception architecture:

> **Every** linear perception layer on `ℝ¹¹` — with no assumption whatsoever on its weights —
> possesses a nonzero percept direction that it merely rescales.

Equivalently, every `11 × 11` real weight matrix has a real eigenvalue.  This is a genuinely
cross-domain statement: the algebra of the characteristic polynomial meets the topology of
the real line (the intermediate value theorem), and the conclusion fails in even dimensions.

## Main results

* `HyperAwareness11D.exists_real_root_of_odd_natDegree` — a monic real polynomial of odd
  degree has a real root (proved from the asymptotics of polynomials plus the intermediate
  value theorem; Mathlib has no `IsRealClosed ℝ` instance).
* `HyperAwareness11D.exists_real_eigenvector_of_odd` — every real square matrix of odd size
  has a real eigenvalue with a nonzero eigenvector.
* `HyperAwareness11D.exists_invariant_percept_11` — the 11-dimensional statement for
  `linLayer`.
* `HyperAwareness11D.rotation_has_no_invariant_percept` — the *boundary*: in dimension `2`
  the quarter-turn layer has no invariant percept direction, so the result above is a genuine
  consequence of the oddness of `11` and not a formal triviality.
-/

namespace HyperAwareness11D

open Polynomial Filter Topology

noncomputable section

/-! ## A monic real polynomial of odd degree has a root -/

/-- A monic real polynomial of odd degree has a real root.  Proof: it tends to `+∞` at `+∞`
and (by oddness of the degree) to `-∞` at `-∞`, so the intermediate value theorem applies. -/
theorem exists_real_root_of_odd_natDegree {p : ℝ[X]} (hmonic : p.Monic)
    (hodd : Odd p.natDegree) : ∃ t : ℝ, p.eval t = 0 := by
  have hdeg0 : p.natDegree ≠ 0 := by
    rcases hodd with ⟨k, hk⟩; omega
  have hdeg : 0 < p.degree := by
    rw [Polynomial.degree_eq_natDegree hmonic.ne_zero]
    exact_mod_cast Nat.pos_of_ne_zero hdeg0
  have h1 : Tendsto (fun x => p.eval x) atTop atTop :=
    p.tendsto_atTop_of_leadingCoeff_nonneg hdeg (by simp [hmonic.leadingCoeff])
  obtain ⟨b, hb⟩ := (h1.eventually_ge_atTop 1).exists
  set q : ℝ[X] := p.comp (-X) with hq
  have hqnd : q.natDegree = p.natDegree := by
    simp [hq, Polynomial.natDegree_comp]
  have hqlead : q.leadingCoeff = -1 := by
    rw [hq, Polynomial.leadingCoeff_comp (by simp)]
    simp [hmonic.leadingCoeff, hodd.neg_one_pow]
  have hqdeg : 0 < q.degree := by
    rw [Polynomial.degree_eq_natDegree (fun h => by simp [h] at hqlead), hqnd]
    exact_mod_cast Nat.pos_of_ne_zero hdeg0
  have h2 : Tendsto (fun x => q.eval x) atTop atBot :=
    q.tendsto_atBot_of_leadingCoeff_nonpos hqdeg (by rw [hqlead]; norm_num)
  obtain ⟨c, hc⟩ := (h2.eventually_le_atBot (-1)).exists
  have hcval : p.eval (-c) ≤ -1 := by simpa [hq, Polynomial.eval_comp] using hc
  have hcont : ContinuousOn (fun x => p.eval x) (Set.uIcc (-c) b) :=
    p.continuous_aeval.continuousOn
  have hiv := intermediate_value_uIcc hcont
  have h0 : (0:ℝ) ∈ Set.uIcc (p.eval (-c)) (p.eval b) := by
    rw [Set.mem_uIcc]; left; constructor <;> linarith
  obtain ⟨t, -, ht⟩ := hiv h0
  exact ⟨t, ht⟩

/-! ## Real eigenvalues in odd dimension -/

/-- **Every real square matrix of odd size has a real eigenvalue.** -/
theorem exists_real_eigenvector_of_odd {m : ℕ} (hm : Odd m) (M : Matrix (Fin m) (Fin m) ℝ) :
    ∃ (a : ℝ) (v : Fin m → ℝ), v ≠ 0 ∧ M.mulVec v = a • v := by
  have hmonic : M.charpoly.Monic := M.charpoly_monic
  have hdeg : M.charpoly.natDegree = m := by
    rw [Matrix.charpoly_natDegree_eq_dim, Fintype.card_fin]
  obtain ⟨t, ht⟩ := exists_real_root_of_odd_natDegree hmonic (by rw [hdeg]; exact hm)
  have hdet : (Matrix.scalar (Fin m) t - M).det = 0 := by
    rw [← Matrix.eval_charpoly]; exact ht
  obtain ⟨v, hv, hmv⟩ := Matrix.exists_mulVec_eq_zero_iff.mpr hdet
  refine ⟨t, v, hv, ?_⟩
  rw [Matrix.sub_mulVec] at hmv
  have hs : (Matrix.scalar (Fin m) t).mulVec v = t • v := by
    funext i
    simp [Matrix.scalar, Matrix.mulVec_diagonal]
  rw [hs] at hmv
  funext i
  have hi := congrFun hmv i
  simp only [Pi.sub_apply, Pi.zero_apply, Pi.smul_apply, smul_eq_mul] at hi
  show M.mulVec v i = t * v i
  linarith

/-- Linear perception layers are matrix-vector products. -/
lemma linLayer_eq_mulVec {m : ℕ} (M : Matrix (Fin m) (Fin m) ℝ) (x : Fin m → ℝ) :
    linLayer M x = M.mulVec x := by
  funext i
  simp [linLayer, Matrix.mulVec, dotProduct]

/-- **Invariant percept in dimension 11.**  Every linear perception layer on `ℝ¹¹` has a
nonzero percept direction which it only rescales.  No hypothesis on the weights is needed;
the reason is that `11` is odd. -/
theorem exists_invariant_percept_11 (M : Fin 11 → Fin 11 → ℝ) :
    ∃ (a : ℝ) (v : Fin 11 → ℝ), v ≠ 0 ∧ linLayer M v = a • v := by
  obtain ⟨a, v, hv, hmv⟩ := exists_real_eigenvector_of_odd (by decide) (M : Matrix _ _ ℝ)
  exact ⟨a, v, hv, by rw [linLayer_eq_mulVec]; exact hmv⟩

/-- An injective 11-dimensional linear layer has an invariant percept with nonzero gain. -/
theorem exists_invariant_percept_ne_zero_11 (M : Fin 11 → Fin 11 → ℝ)
    (hinj : Function.Injective (linLayer M)) :
    ∃ (a : ℝ) (v : Fin 11 → ℝ), v ≠ 0 ∧ a ≠ 0 ∧ linLayer M v = a • v := by
  obtain ⟨a, v, hv, hmv⟩ := exists_invariant_percept_11 M
  refine ⟨a, v, hv, ?_, hmv⟩
  intro ha
  apply hv
  have h0 : linLayer M v = linLayer M 0 := by
    rw [hmv, ha]
    funext i
    simp [linLayer]
  exact hinj h0

/-! ## The boundary: parity is essential -/

/-- The quarter-turn layer on `ℝ²`. -/
def rot2 : Fin 2 → Fin 2 → ℝ := ![![0, -1], ![1, 0]]

/-- **Parity is essential.**  In the even dimension `2` the quarter-turn layer has *no*
invariant percept direction; the 11-dimensional theorem above genuinely uses oddness. -/
theorem rotation_has_no_invariant_percept :
    ¬ ∃ (a : ℝ) (v : Fin 2 → ℝ), v ≠ 0 ∧ linLayer rot2 v = a • v := by
  rintro ⟨a, v, hv, hmv⟩
  have h0 := congrFun hmv 0
  have h1 := congrFun hmv 1
  simp [linLayer, rot2, Fin.sum_univ_succ] at h0 h1
  -- `-v 1 = a * v 0` and `v 0 = a * v 1`, hence `(1 + a²) * v 0 = 0` and likewise for `v 1`
  have hv0 : v 0 = 0 := by nlinarith [sq_nonneg a, sq_nonneg (v 0), sq_nonneg (v 1)]
  have hv1 : v 1 = 0 := by nlinarith [sq_nonneg a, sq_nonneg (v 0), sq_nonneg (v 1)]
  apply hv
  funext i
  fin_cases i
  · simpa using hv0
  · simpa using hv1

end

end HyperAwareness11D