import Novelty.StrangeAttractorSpectral
import Novelty.StrangeAttractorMixing

/-!
# Strange attractors as algebraic objects, IX: periodic orbits grow at the rate of the entropy

Two invariants of a symbolic attractor have been computed in this thread: the entropy
(`entropy`, the exponential growth rate of the finite approximants, equal to `log` of the
Perron eigenvalue by `entropy_eq_log_perron`) and the periodic-orbit counts
(`Fintype.card (ClosedWalk E n) = trace (A ^ n)`).  They were related only by inequalities.
This file proves that for a **primitive** graph the two rates coincide:

`lim log #(closed walks of length n) / n = entropy`,

the finite-graph form of the classical statement that periodic orbits of a mixing subshift
of finite type grow exactly at the topological entropy.  The upper bound is the eigenvector
inequality `(A ^ n) i i ≤ value ^ n`; the lower bound is a primitivity argument: prefixing
and suffixing a walk of length `m` turns *any* path of length `q` into a closed walk of
length `q + 2m`, so `#V ^ 2 * trace (A ^ (q + 2 * m)) ≥ #(FinPath E q)`.

Consequences:

* `tendsto_log_card_closedWalk` : the periodic-orbit growth rate equals the entropy;
* `entropy_eq_of_conjugate` : hence the entropy of a primitive attractor is a **conjugacy
  invariant** — a gap left open by the previous cycle, where only the periodic-orbit counts
  were known to be invariant;
* `tendsto_log_card_closedWalk_lorenz`, `tendsto_log_card_closedWalk_pruned` : the closed
  walks of the Lorenz template grow like `2 ^ n` and those of the pruned template (the Lucas
  numbers) like `φ ^ n`;
* `primitive_iff_pow_pos` : primitivity of the graph is *equivalent* to eventual positivity
  of all entries of the powers of the transfer matrix, so the hypothesis behind mixing and
  the hypothesis of Perron–Frobenius are literally the same condition.
-/

namespace LorenzLimit

open Filter Topology

variable {V : Type*} [Fintype V] [DecidableEq V] {E : V → V → Bool}

/-! ## Primitivity in matrix form -/

/-- Primitivity, read on the transfer matrix: beyond some exponent every entry of every
power is at least `1`. -/
theorem exists_pow_pos_of_primitive (hP : Primitive E) :
    ∃ N : ℕ, 0 < N ∧ ∀ n, N ≤ n → ∀ u v : V, 1 ≤ (adjMatrix E ^ n) u v := by
  obtain ⟨N, hN, hwalk⟩ := hP
  refine ⟨N, hN, fun n hn u v => ?_⟩
  obtain ⟨w, hw0, hwn, hedge⟩ := hwalk n hn u v
  rw [adjMatrix_pow_apply]
  refine Fintype.card_pos_iff.mpr ⟨⟨fun k => w k.val, fun k => ?_, ?_, ?_⟩⟩
  · simpa using hedge k.val k.isLt
  · simpa using hw0
  · simpa using hwn

/-- The converse of `exists_pow_pos_of_primitive`: a matrix-positivity condition rebuilds
the walks, so primitivity is *exactly* eventual positivity of the powers of the transfer
matrix. -/
theorem primitive_of_pow_pos
    (h : ∃ N : ℕ, 0 < N ∧ ∀ n, N ≤ n → ∀ u v : V, 1 ≤ (adjMatrix E ^ n) u v) :
    Primitive E := by
  obtain ⟨N, hN, hpos⟩ := h
  refine ⟨N, hN, fun n hn u v => ?_⟩
  have hne : Nonempty (WalkBetween E n u v) := by
    rw [← Fintype.card_pos_iff, ← adjMatrix_pow_apply]
    exact hpos n hn u v
  obtain ⟨w, hedge, h0, hlast⟩ := hne.some
  refine ⟨fun k => if hk : k < n + 1 then w ⟨k, hk⟩ else v, ?_, ?_, ?_⟩
  · simpa using h0
  · simp only [dif_pos (Nat.lt_succ_self n)]
    simpa [Fin.last] using hlast
  · intro i hi
    have hstep := hedge ⟨i, hi⟩
    have h1 : i < n + 1 := by omega
    have h2 : i + 1 < n + 1 := by omega
    simpa [h1, h2, Fin.castSucc, Fin.succ, Fin.ext_iff] using hstep

/-- **Primitivity is matrix positivity.**  The combinatorial hypothesis behind mixing and
behind Perron–Frobenius is one and the same condition. -/
theorem primitive_iff_pow_pos :
    Primitive E ↔ ∃ N : ℕ, 0 < N ∧ ∀ n, N ≤ n → ∀ u v : V, 1 ≤ (adjMatrix E ^ n) u v :=
  ⟨exists_pow_pos_of_primitive, primitive_of_pow_pos⟩

/-! ## The upper bound: diagonal entries are at most `value ^ n` -/

/-- The diagonal entries of the powers of the transfer matrix are bounded by the powers of
the Perron value. -/
theorem diag_le_perron_pow (p : PerronDatum E) (n : ℕ) (i : V) :
    ((adjMatrix E ^ n) i i : ℝ) ≤ p.value ^ n := by
  have h1 : ((adjMatrix E ^ n) i i : ℝ) * p.vector i
      ≤ ∑ j, ((adjMatrix E ^ n) i j : ℝ) * p.vector j :=
    Finset.single_le_sum (f := fun j => ((adjMatrix E ^ n) i j : ℝ) * p.vector j)
      (fun j _ => mul_nonneg (by positivity) (p.vector_pos j).le) (Finset.mem_univ i)
  rw [p.pow_eigen n i] at h1
  have hv := p.vector_pos i
  nlinarith

/-- The number of closed walks of length `n` is at most `#V * value ^ n`. -/
theorem card_closedWalk_le_perron_pow (p : PerronDatum E) (n : ℕ) :
    (Fintype.card (ClosedWalk E n) : ℝ) ≤ Fintype.card V * p.value ^ n := by
  have htrace : (Fintype.card (ClosedWalk E n) : ℝ) = ∑ i, ((adjMatrix E ^ n) i i : ℝ) := by
    rw [card_closedWalk_eq_trace, Matrix.trace]
    push_cast
    rfl
  rw [htrace]
  calc ∑ i, ((adjMatrix E ^ n) i i : ℝ) ≤ ∑ _i : V, p.value ^ n :=
        Finset.sum_le_sum fun i _ => diag_le_perron_pow p n i
    _ = Fintype.card V * p.value ^ n := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]

/-! ## The lower bound: primitivity turns paths into closed walks -/

/-- If all entries of `A ^ m` are positive, then every entry of `A ^ q` is dominated by
every diagonal entry of `A ^ (m + q + m)`: prefix and suffix the path by walks of length
`m`. -/
theorem entry_le_diag_of_pow_pos {m : ℕ} (hm : ∀ u v : V, 1 ≤ (adjMatrix E ^ m) u v)
    (q : ℕ) (i j k : V) :
    (adjMatrix E ^ q) j k ≤ (adjMatrix E ^ (m + q + m)) i i := by
  have hpow : adjMatrix E ^ (m + q + m)
      = adjMatrix E ^ m * (adjMatrix E ^ q * adjMatrix E ^ m) := by
    rw [← pow_add, ← pow_add, add_assoc]
  have h1 : (adjMatrix E ^ q) j k ≤ (adjMatrix E ^ q * adjMatrix E ^ m) j i := by
    rw [Matrix.mul_apply]
    refine le_trans (Nat.le_mul_of_pos_right _ (hm k i)) ?_
    exact Finset.single_le_sum
      (f := fun k' => (adjMatrix E ^ q) j k' * (adjMatrix E ^ m) k' i)
      (fun _ _ => Nat.zero_le _) (Finset.mem_univ k)
  have h2 : (adjMatrix E ^ q * adjMatrix E ^ m) j i
      ≤ (adjMatrix E ^ m) i j * ((adjMatrix E ^ q * adjMatrix E ^ m) j i) :=
    Nat.le_mul_of_pos_left _ (hm i j)
  have h3 : (adjMatrix E ^ m) i j * ((adjMatrix E ^ q * adjMatrix E ^ m) j i)
      ≤ (adjMatrix E ^ (m + q + m)) i i := by
    rw [hpow, Matrix.mul_apply]
    exact Finset.single_le_sum
      (f := fun j' => (adjMatrix E ^ m) i j' * ((adjMatrix E ^ q * adjMatrix E ^ m) j' i))
      (fun _ _ => Nat.zero_le _) (Finset.mem_univ j)
  exact h1.trans (h2.trans h3)

/-- Consequently `#V ^ 2` closed walks of length `q + 2m` account for all paths of
length `q`. -/
theorem card_finPath_le_card_closedWalk [Nonempty V] {m : ℕ}
    (hm : ∀ u v : V, 1 ≤ (adjMatrix E ^ m) u v) (q : ℕ) :
    Fintype.card (FinPath E q)
      ≤ Fintype.card V * Fintype.card V * Fintype.card (ClosedWalk E (m + q + m)) := by
  classical
  obtain ⟨i⟩ := ‹Nonempty V›
  have hdiag : (adjMatrix E ^ (m + q + m)) i i ≤ Fintype.card (ClosedWalk E (m + q + m)) := by
    rw [card_closedWalk_eq_trace, Matrix.trace]
    exact Finset.single_le_sum (f := fun i' => (adjMatrix E ^ (m + q + m)) i' i')
      (fun _ _ => Nat.zero_le _) (Finset.mem_univ i)
  calc Fintype.card (FinPath E q) = ∑ j : V, ∑ k : V, (adjMatrix E ^ q) j k :=
        card_finPath_eq_sum q
    _ ≤ ∑ _j : V, ∑ _k : V, (adjMatrix E ^ (m + q + m)) i i :=
        Finset.sum_le_sum fun j _ =>
          Finset.sum_le_sum fun k _ => entry_le_diag_of_pow_pos hm q i j k
    _ = Fintype.card V * Fintype.card V * (adjMatrix E ^ (m + q + m)) i i := by
        simp [Finset.sum_const, Finset.card_univ, mul_assoc]
    _ ≤ Fintype.card V * Fintype.card V * Fintype.card (ClosedWalk E (m + q + m)) := by
        exact Nat.mul_le_mul_left _ hdiag

/-! ## The periodic-orbit growth rate -/

/-- **Periodic orbits grow at the rate of the entropy.**  For a primitive dead-end-free
graph carrying a Perron datum, the number of closed walks of length `n` — equivalently, by
`card_periodic_eq_card_closedWalk`, the number of `n`-periodic points of the attractor —
grows exactly like `exp (n * entropy)`. -/
theorem tendsto_log_card_closedWalk [Nonempty V] (h : NoDeadEnds E) (hP : Primitive E)
    (p : PerronDatum E) :
    Tendsto (fun n : ℕ => Real.log (Fintype.card (ClosedWalk E n)) / n) atTop
      (𝓝 (entropy h)) := by
  obtain ⟨m, hm0, hm⟩ := exists_pow_pos_of_primitive hP
  obtain ⟨a, b, ha, _, hab⟩ := p.exists_bounds
  have hr : 0 < p.value := p.value_pos h
  have hVpos : (0 : ℝ) < Fintype.card V := by
    have : 0 < Fintype.card V := Fintype.card_pos
    exact_mod_cast this
  set a' : ℝ := a / (Fintype.card V * Fintype.card V * p.value ^ (2 * m)) with ha'
  have ha'pos : 0 < a' := by
    have : (0 : ℝ) < p.value ^ (2 * m) := by positivity
    rw [ha']
    positivity
  -- lower bound on the closed-walk counts
  have hlower : ∀ n : ℕ, 2 * m ≤ n →
      a' * p.value ^ n ≤ (Fintype.card (ClosedWalk E n) : ℝ) := by
    intro n hn
    obtain ⟨q, rfl⟩ : ∃ q, n = m + q + m := ⟨n - 2 * m, by omega⟩
    have hcount := card_finPath_le_card_closedWalk (hm m le_rfl) q
    have hcountR : (Fintype.card (FinPath E q) : ℝ)
        ≤ Fintype.card V * Fintype.card V * (Fintype.card (ClosedWalk E (m + q + m)) : ℝ) := by
      exact_mod_cast hcount
    have hlow := (hab q).1
    have hsplit : p.value ^ (m + q + m) = p.value ^ q * p.value ^ (2 * m) := by
      rw [← pow_add]
      ring_nf
    have hstep1 : a * p.value ^ q * p.value ^ (2 * m)
        ≤ (Fintype.card (FinPath E q) : ℝ) * p.value ^ (2 * m) :=
      mul_le_mul_of_nonneg_right hlow (pow_pos hr (2 * m)).le
    have hstep2 : (Fintype.card (FinPath E q) : ℝ) * p.value ^ (2 * m)
        ≤ (Fintype.card V * Fintype.card V
            * (Fintype.card (ClosedWalk E (m + q + m)) : ℝ)) * p.value ^ (2 * m) :=
      mul_le_mul_of_nonneg_right hcountR (pow_pos hr (2 * m)).le
    rw [ha', hsplit, div_mul_eq_mul_div, div_le_iff₀ (by positivity)]
    nlinarith [hstep1, hstep2]
  -- upper bound
  have hupper : ∀ n : ℕ, (Fintype.card (ClosedWalk E n) : ℝ) ≤ Fintype.card V * p.value ^ n :=
    card_closedWalk_le_perron_pow p
  rw [entropy_eq_log_perron h p]
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le'
    (tendsto_affine_div (Real.log a') (Real.log p.value))
    (tendsto_affine_div (Real.log (Fintype.card V)) (Real.log p.value)) ?_ ?_
  · filter_upwards [eventually_ge_atTop (2 * m), eventually_gt_atTop 0] with n hn hn0
    have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
    have h1 : Real.log (a' * p.value ^ n) ≤ Real.log (Fintype.card (ClosedWalk E n)) :=
      Real.log_le_log (by positivity) (hlower n hn)
    rw [Real.log_mul (ne_of_gt ha'pos) (by positivity), Real.log_pow] at h1
    gcongr
  · filter_upwards [eventually_ge_atTop (2 * m), eventually_gt_atTop 0] with n hn hn0
    have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
    have hpos : (0 : ℝ) < Fintype.card (ClosedWalk E n) :=
      lt_of_lt_of_le (by positivity) (hlower n hn)
    have h1 : Real.log (Fintype.card (ClosedWalk E n))
        ≤ Real.log (Fintype.card V * p.value ^ n) := Real.log_le_log hpos (hupper n)
    rw [Real.log_mul (ne_of_gt hVpos) (by positivity), Real.log_pow] at h1
    gcongr

/-- **The entropy of a primitive attractor is a conjugacy invariant.**  Conjugate systems
have the same periodic-orbit counts (previous cycle), and by
`tendsto_log_card_closedWalk` those counts determine the entropy. -/
theorem entropy_eq_of_conjugate {W : Type*} [Fintype W] [DecidableEq W] [Nonempty V]
    [Nonempty W] {F : W → W → Bool} (hE : NoDeadEnds E) (hF : NoDeadEnds F)
    (hPE : Primitive E) (hPF : Primitive F) (pE : PerronDatum E) (pF : PerronDatum F)
    (hconj : IsConjugate E F) : entropy hE = entropy hF := by
  refine tendsto_nhds_unique (tendsto_log_card_closedWalk hE hPE pE)
    ((tendsto_log_card_closedWalk hF hPF pF).congr' ?_)
  filter_upwards [eventually_gt_atTop 0] with n hn
  rw [card_closedWalk_eq_of_conjugate hconj hn]

/-- **Spectral rigidity.**  Conjugate primitive attractors have the same Perron value. -/
theorem perron_value_eq_of_conjugate {W : Type*} [Fintype W] [DecidableEq W] [Nonempty V]
    [Nonempty W] {F : W → W → Bool} (hE : NoDeadEnds E) (hF : NoDeadEnds F)
    (hPE : Primitive E) (hPF : Primitive F) (pE : PerronDatum E) (pF : PerronDatum F)
    (hconj : IsConjugate E F) : pE.value = pF.value := by
  have hlog : Real.log pE.value = Real.log pF.value := by
    rw [← entropy_eq_log_perron hE pE, ← entropy_eq_log_perron hF pF]
    exact entropy_eq_of_conjugate hE hF hPE hPF pE pF hconj
  exact Real.log_injOn_pos (Set.mem_Ioi.mpr (pE.value_pos hE)) (Set.mem_Ioi.mpr (pF.value_pos hF))
    hlog

/-! ## The two templates -/

/-- The closed walks of the Lorenz template grow at rate `log 2`. -/
theorem tendsto_log_card_closedWalk_lorenz :
    Tendsto (fun n : ℕ => Real.log (Fintype.card (ClosedWalk lorenzTemplate n)) / n) atTop
      (𝓝 (Real.log 2)) := by
  have := tendsto_log_card_closedWalk (Branching.noDeadEnds branching_lorenzTemplate)
    primitive_lorenzTemplate perronLorenz
  rwa [entropy_lorenz_spectral] at this

/-- The closed walks of the pruned template — the Lucas numbers — grow at rate `log φ`. -/
theorem tendsto_log_card_closedWalk_pruned :
    Tendsto (fun n : ℕ => Real.log (Fintype.card (ClosedWalk prunedTemplate n)) / n) atTop
      (𝓝 (Real.log Real.goldenRatio)) := by
  have := tendsto_log_card_closedWalk noDeadEnds_prunedTemplate
    primitive_prunedTemplate perronPruned
  rwa [entropy_pruned_spectral] at this

end LorenzLimit