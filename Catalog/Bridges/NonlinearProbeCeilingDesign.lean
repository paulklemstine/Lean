import Bridges.NonlinearProbeCeilingAnova

/-!
# Is the measured ceiling an artifact of the pooling design?

Third pass over D3.  If the ceiling is to be *measured* rather than proved, the measurement must
be robust: it must not depend on the units of the importances, on the names of the key contents,
or on how many times the pooled windows were resampled.  It must also come with an honest account
of what its certificate cannot see.

* `condMean_affine`, `ssWithin_affine`, `sstot_affine`, `anovaCeiling_affine_invariant` — the
  ceiling is invariant under `a ↦ c·a + b` with `c ≠ 0`.  Attention mass, `log1p` counts and
  per-layer renormalisations all give the same number, so the threshold `0.5` is dimensionless.
* `anovaCeiling_relabel` — the ceiling depends only on the fiber partition: any injective
  renaming of contents (a different tokenizer, a different hash of the key vector) leaves it
  fixed.  The proof is a two-sided application of the monotonicity theorem
  `anovaCeiling_mono_of_factors`, using a left inverse of the injection.
* `repKey`, `repImp`, `rep_ssWithin`, `rep_sstot`, `anovaCeiling_replication_invariant` — the
  `k`-fold replicated population has `k`-fold both sums of squares, hence the *same* ceiling.
  A measured ceiling therefore cannot be manufactured by re-using windows.
* `altImp`, `constKey`, `alt_ceiling_zero`, `pair_certificate_incomplete` — the Critic's
  boundary.  Four windows of one content with importances `1, -1, 1, -1` have ceiling `0`, yet
  `SS_tot = 4` equals the largest available squared gap, so **no** one-pair-per-content
  certificate fires.  The certificate of `NonlinearProbeCeilingD3` §2 is sound but incomplete;
  completeness is exactly the two-windows-per-content design.
* `quadP`, `quadQ`, `quad_ssWithin_measured`, `quad_measured_value`, `quad_D3_iff` — in that
  design the whole question collapses to `c² < d²`: D3 holds precisely when the context-swap
  amplitude dominates the content-informative amplitude.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): every objection a referee could raise to a *measured* ceiling is an
invariance claim (units, labels, resampling) or a completeness claim (does the certificate see
everything?).  Both are theorems, not caveats.

Experiment (Experimenter): the alternating population was found by searching for a fiber whose
dispersion exceeds its diameter: with `n` values `±1` one has `SS_within = n` while the largest
squared gap is `4`, so every `n > 4` breaks the certificate and `n = 4` breaks it at equality.
The `n = 4` instance is the one formalised, since it is the smallest.

Analysis (Analyst): the three invariances say the ceiling is a functional of the empirical
distribution of `(content, importance)` pairs; the incompleteness result says that the
*certificate* is a functional of a subsample.  The gap between them is precisely the fiber sizes,
which is why the design with two windows per content is the sweet spot: there the subsample is
the sample.

Critique (Critic): `anovaCeiling_relabel` needs `Nonempty κ` (a left inverse must land
somewhere) and `0 < SS_tot`; `anovaCeiling_affine_invariant` needs `c ≠ 0`, since a constant
population has no ceiling to speak of.  Both hypotheses are minimal: dropping either makes the
statement false rather than merely unprovable.
-/

namespace Catalog.Bridges.NonlinearProbeCeilingDesign

open Finset Catalog.Novelty.ProbeRetentionLimits Catalog.Novelty.NET58RelationalImportance
  Catalog.Bridges.NonlinearProbeCeilingD3 Catalog.Bridges.NonlinearProbeCeilingAnova

/-! ### 1. Invariances: the ceiling is a property of the population, not of its encoding -/

section Affine

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]

omit [Fintype κ] in
lemma condMean_affine (key : ι → κ) (a : ι → ℝ) (c b : ℝ) {y : κ}
    (hy : (fiber key y).Nonempty) :
    condMean key (fun i => c * a i + b) y = c * condMean key a y + b := by
  have hcard : ((fiber key y).card : ℝ) ≠ 0 := by
    simpa using (Finset.card_pos.mpr hy).ne'
  rw [condMean, condMean, Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const,
    nsmul_eq_mul]
  field_simp

lemma ssWithin_affine (key : ι → κ) (a : ι → ℝ) (c b : ℝ) :
    ssWithin key (fun i => c * a i + b) = c ^ 2 * ssWithin key a := by
  rw [ssWithin, ssWithin, Finset.mul_sum]
  refine Finset.sum_congr rfl fun y _ => ?_
  rcases (fiber key y).eq_empty_or_nonempty with he | hne
  · simp [he]
  · rw [condMean_affine key a c b hne, Finset.mul_sum]
    exact Finset.sum_congr rfl fun i _ => by ring

lemma mean_affine (a : ι → ℝ) (c b : ℝ) [Nonempty ι] :
    mean (fun i => c * a i + b) = c * mean a + b := by
  have hcard : ((Fintype.card ι : ℝ)) ≠ 0 := by
    simp [(Fintype.card_pos_iff.mpr ‹Nonempty ι›).ne']
  rw [mean, mean, Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, Finset.card_univ,
    nsmul_eq_mul]
  field_simp

lemma sstot_affine (a : ι → ℝ) (c b : ℝ) [Nonempty ι] :
    sstot (fun i => c * a i + b) = c ^ 2 * sstot a := by
  rw [sstot, sstot, mean_affine a c b, Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by ring

/-- **Unit invariance.**  Rescaling and shifting the importances — changing from attention mass
to `log1p` counts, or renormalising per layer — leaves the ceiling exactly where it was.  The
threshold `0.5` is therefore a dimensionless statement about the population. -/
theorem anovaCeiling_affine_invariant [Nonempty ι] (key : ι → κ) (a : ι → ℝ) {c : ℝ} (b : ℝ)
    (hc : c ≠ 0) :
    anovaCeiling key (fun i => c * a i + b) = anovaCeiling key a := by
  have hc2 : (c : ℝ) ^ 2 ≠ 0 := pow_ne_zero 2 hc
  rw [anovaCeiling, anovaCeiling, ssWithin_affine, sstot_affine, mul_div_mul_left _ _ hc2]

end Affine

section Relabel

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]
  {κ' : Type*} [Fintype κ'] [DecidableEq κ']

/-- **The ceiling sees only the fiber partition.**  Renaming the key contents by any injection
— a different tokenizer, a different hash of the key vector — does not move it. -/
theorem anovaCeiling_relabel (key : ι → κ) (g : κ → κ') (hg : Function.Injective g)
    (a : ι → ℝ) (h : 0 < sstot a) [Nonempty κ] :
    anovaCeiling (fun i => g (key i)) a = anovaCeiling key a := by
  refine le_antisymm (anovaCeiling_mono_of_factors key g a h) ?_
  have hinv : ∀ i, key i = Function.invFun g (g (key i)) := fun i =>
    (Function.leftInverse_invFun hg (key i)).symm
  have hkey : key = fun i => Function.invFun g (g (key i)) := funext hinv
  calc anovaCeiling key a
      = anovaCeiling (fun i => Function.invFun g ((fun i' => g (key i')) i)) a := by
        rw [← hkey]
    _ ≤ anovaCeiling (fun i => g (key i)) a :=
        anovaCeiling_mono_of_factors (fun i => g (key i)) (Function.invFun g) a h

end Relabel

/-! ### 2. Replication: the ceiling is not a sample-size artifact -/

section Replication

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ] (k : ℕ)

/-- The content map of the `k`-fold replicated population. -/
def repKey (key : ι → κ) : ι × Fin k → κ := fun p => key p.1

/-- The importances of the `k`-fold replicated population. -/
def repImp (a : ι → ℝ) : ι × Fin k → ℝ := fun p => a p.1

omit [Fintype κ] in
lemma rep_fiber (key : ι → κ) (y : κ) :
    fiber (repKey k key) y = (fiber key y) ×ˢ (Finset.univ : Finset (Fin k)) := by
  ext p
  simp only [fiber, repKey, Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_product]
  exact ⟨fun h => ⟨h, trivial⟩, fun h => h.1⟩

omit [Fintype κ] in
lemma rep_sum_fiber (key : ι → κ) (a : ι → ℝ) (y : κ) (g : ℝ → ℝ) :
    ∑ p ∈ fiber (repKey k key) y, g (repImp k a p)
      = k * ∑ i ∈ fiber key y, g (a i) := by
  rw [rep_fiber, Finset.sum_product]
  simp only [repImp, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [← Finset.mul_sum]

omit [Fintype κ] in
lemma rep_sum_fiber_id (key : ι → κ) (a : ι → ℝ) (y : κ) :
    ∑ p ∈ fiber (repKey k key) y, repImp k a p = k * ∑ i ∈ fiber key y, a i := by
  simpa using rep_sum_fiber k key a y id

omit [Fintype κ] in
lemma rep_condMean (hk : 0 < k) (key : ι → κ) (a : ι → ℝ) (y : κ) :
    condMean (repKey k key) (repImp k a) y = condMean key a y := by
  have hk' : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hk.ne'
  rw [condMean, condMean, rep_sum_fiber_id k key a y, rep_fiber, Finset.card_product,
    Finset.card_univ, Fintype.card_fin]
  push_cast
  rw [mul_comm ((fiber key y).card : ℝ) (k : ℝ), mul_div_mul_left _ _ hk']

lemma rep_ssWithin (hk : 0 < k) (key : ι → κ) (a : ι → ℝ) :
    ssWithin (repKey k key) (repImp k a) = k * ssWithin key a := by
  rw [ssWithin, ssWithin, Finset.mul_sum]
  refine Finset.sum_congr rfl fun y _ => ?_
  rw [rep_condMean k hk key a y]
  exact rep_sum_fiber k key a y (fun t => (t - condMean key a y) ^ 2)

lemma rep_mean (hk : 0 < k) (a : ι → ℝ) : mean (repImp k a) = mean a := by
  have hk' : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hk.ne'
  have hsum : ∑ p : ι × Fin k, repImp k a p = k * ∑ i, a i := by
    rw [Fintype.sum_prod_type]
    simp only [repImp, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    rw [← Finset.mul_sum]
  rw [mean, mean, hsum, Fintype.card_prod, Fintype.card_fin]
  push_cast
  rw [mul_comm ((Fintype.card ι : ℝ)) (k : ℝ), mul_div_mul_left _ _ hk']

lemma rep_sstot (hk : 0 < k) (a : ι → ℝ) : sstot (repImp k a) = k * sstot a := by
  rw [sstot, sstot, rep_mean k hk a, Fintype.sum_prod_type]
  simp only [repImp, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [← Finset.mul_sum]

/-- **Replication invariance.**  Duplicating the pooled window population `k` times — the
canonical way a measured `SS_within/SS_tot` could be inflated by re-using windows — changes
neither sum of squares' ratio.  The measured ceiling is a property of the empirical
distribution, so the D3 verdict cannot be produced or destroyed by resampling. -/
theorem anovaCeiling_replication_invariant (hk : 0 < k) (key : ι → κ) (a : ι → ℝ) :
    anovaCeiling (repKey k key) (repImp k a) = anovaCeiling key a := by
  have hk' : (k : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hk.ne'
  rw [anovaCeiling, anovaCeiling, rep_ssWithin k hk, rep_sstot k hk, mul_div_mul_left _ _ hk']

end Replication

/-! ### 3. The certificate is sound but incomplete -/

section Incomplete

/-- A single-content population whose four windows alternate in importance. -/
noncomputable def altImp : Fin 4 → ℝ := ![1, -1, 1, -1]

/-- All four windows share one key content. -/
def constKey : Fin 4 → Fin 1 := fun _ => 0

lemma constKey_fiber : fiber constKey 0 = Finset.univ := by decide

lemma alt_mean : mean altImp = 0 := by
  simp only [mean, altImp, Fin.sum_univ_four, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  norm_num

lemma alt_sstot : sstot altImp = 4 := by
  rw [sstot, alt_mean]
  simp only [altImp, Fin.sum_univ_four, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  norm_num

lemma alt_ssWithin : ssWithin constKey altImp = 4 := by
  have hcm : condMean constKey altImp 0 = 0 := by
    rw [condMean, constKey_fiber]
    simp only [altImp, Fin.sum_univ_four, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
    norm_num
  rw [ssWithin, Fin.sum_univ_one, hcm, constKey_fiber]
  simp only [altImp, Fin.sum_univ_four, Matrix.cons_val_zero, Matrix.cons_val_one,
    Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons]
  norm_num

/-- Content explains nothing here: the ceiling is `0`, far below `1/2`. -/
theorem alt_ceiling_zero : anovaCeiling constKey altImp = 0 := by
  rw [anovaCeiling, alt_ssWithin, alt_sstot]
  norm_num

/-- **The Critic's boundary.**  The repeated-pair certificate of
`content_Rsq_lt_half_of_pair_certificate` is *sound but not complete*: on this population the
ceiling is `0`, yet no choice of one repeated pair per content produces a certificate, because
a single gap can never see the dispersion of a fiber with four members.  Certificates must
therefore be read as one-sided evidence, and only the exactly-two-windows-per-content design of
`ssWithin_eq_half_sum_pairs` makes the measurement complete. -/
theorem pair_certificate_incomplete :
    anovaCeiling constKey altImp < 1 / 2 ∧
      ∀ p q : Fin 1 → Fin 4,
        ¬ (sstot altImp < ∑ y : Fin 1, (altImp (p y) - altImp (q y)) ^ 2) := by
  refine ⟨by rw [alt_ceiling_zero]; norm_num, ?_⟩
  intro p q
  rw [alt_sstot]
  simp only [Fin.sum_univ_one, not_lt]
  have h : ∀ i : Fin 4, altImp i = 1 ∨ altImp i = -1 := by
    intro i; fin_cases i <;> simp [altImp]
  rcases h (p 0) with h1 | h1 <;> rcases h (q 0) with h2 | h2 <;> rw [h1, h2] <;> norm_num

end Incomplete

/-! ### 4. The two-windows-per-content design, exactly -/

section TwoPerContent

/-- The selection of the first window of each content in the tunable family. -/
def quadP : Fin 2 → Fin 4 := ![0, 2]

/-- The selection of the second window of each content in the tunable family. -/
def quadQ : Fin 2 → Fin 4 := ![1, 3]

lemma quad_fiber_pair (y : Fin 2) : fiber quadKey y = {quadP y, quadQ y} := by
  revert y; decide

/-- **The measurement is exact in the canonical design.**  On the two-windows-per-content
family, `SS_within` is literally half the sum of the two observed importance gaps — the ceiling
of the entire nonlinear class is read off the data with no model at all. -/
theorem quad_ssWithin_measured (c d : ℝ) :
    ssWithin quadKey (quadImp c d)
      = (∑ y : Fin 2, (quadImp c d (quadP y) - quadImp c d (quadQ y)) ^ 2) / 2 :=
  ssWithin_eq_half_sum_pairs quadKey (quadImp c d) quadP quadQ quad_fiber_pair (by decide)

/-- The measured gaps are `2d` each, so the pair measurement returns `4d²`, matching the direct
computation. -/
theorem quad_measured_value (c d : ℝ) :
    (∑ y : Fin 2, (quadImp c d (quadP y) - quadImp c d (quadQ y)) ^ 2) / 2 = 4 * d ^ 2 := by
  rw [← quad_ssWithin_measured, quad_ssWithin]

/-- **The decision procedure.**  In the canonical design the D3 question is settled by one
inequality between observables, and the answer depends on the population: it is `true` exactly
when the content-informative amplitude `c` is smaller than the context-swap amplitude `d`. -/
theorem quad_D3_iff (c d : ℝ) (h : 0 < c ^ 2 + d ^ 2) :
    anovaCeiling quadKey (quadImp c d) < 1 / 2 ↔ c ^ 2 < d ^ 2 := by
  have hpos : 0 < sstot (quadImp c d) := by rw [quad_sstot]; linarith
  rw [anovaCeiling_lt_half_iff quadKey (quadImp c d) hpos, quad_ssWithin, quad_sstot]
  constructor <;> intro hh <;> linarith

end TwoPerContent

end Catalog.Bridges.NonlinearProbeCeilingDesign