/-
# Symbolic constraints as a submodular lattice over the RLHF free energy

Third file of the neurosymbolic RLHF thread (see
`Speculative/AutoResearch/NeuroSymbolicRLHFObjective.lean`,
`MachineLearning/RLHFHilbertIsometry.lean` and
`MachineLearning/RLHFFreeEnergyDuality.lean`).

The *neurosymbolic* part of "neurosymbolic RLHF" is a hard symbolic filter: a
logical rule set restricts the admissible responses to a subset `S` of the
output space.  This file studies the induced *constrained free energy*

  `F_S(β, r) = β log ∑_{i ∈ S} ref i · exp(r i / β)`,

which we prove is exactly the optimal value of the InstructGPT objective over
policies supported in `S`.  The results bridge information theory with the
combinatorics of the Boolean lattice of constraint sets:

* **Level 0 — variational principle on a constraint set**
  (`rlhfObj_le_constrainedFreeEnergy`, `rlhfObj_constrainedGibbs`):
  `F_S` is attained, exactly, by the `S`-conditioned Gibbs policy.
* **Level 1 — commutation** (`constrainedGibbs_eq_conditional`): aligning and
  then applying the symbolic filter gives the same policy as applying the
  filter and then aligning.  Symbolic filtering and RLHF commute.
* **Level 2 — lattice structure**: `S ↦ F_S(β, r)` is *monotone*
  (`constrainedFreeEnergy_mono`) and *submodular*
  (`constrainedFreeEnergy_submodular`) on the Boolean lattice of constraint
  sets.  Submodularity is the diminishing-returns law of symbolic constraints:
  relaxing a rule helps least when other rules are already relaxed.
* **Level 3 — price of symbolic alignment**
  (`constrainedFreeEnergy_ge_sub`): the value lost by imposing the rule set `S`
  is at most `oscil r - β log ref(S)`, i.e. reward spread plus a
  `β`-weighted log-mass penalty for the pruned probability.

No `sorry`, no `native_decide`.
-/
import MachineLearning.RLHFFreeEnergyDuality

open Finset Real BigOperators

noncomputable section

namespace NeuroSymbolicRLHF

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-! ## Constrained partition function and free energy -/

/-- Partition function restricted to the symbolically admissible set `S`. -/
def constrainedZ (β : ℝ) (ref r : ι → ℝ) (S : Finset ι) : ℝ :=
  ∑ i ∈ S, ref i * Real.exp (r i / β)

/-- Free energy of the RLHF objective restricted to policies supported in `S`. -/
def constrainedFreeEnergy (β : ℝ) (ref r : ι → ℝ) (S : Finset ι) : ℝ :=
  β * Real.log (constrainedZ β ref r S)

/-- The `S`-conditioned Gibbs policy: the exponentially tilted policy
renormalised over the admissible set. -/
def constrainedGibbs (β : ℝ) (ref r : ι → ℝ) (S : Finset ι) : ι → ℝ :=
  fun i => if i ∈ S then ref i * Real.exp (r i / β) / constrainedZ β ref r S else 0

omit [DecidableEq ι] in
theorem constrainedZ_pos {β : ℝ} {ref r : ι → ℝ} {S : Finset ι} (href : IsPosProb ref)
    (hS : S.Nonempty) : 0 < constrainedZ β ref r S := by
  refine Finset.sum_pos (fun i _ => mul_pos (href.pos i) (Real.exp_pos _)) hS

omit [DecidableEq ι] in
theorem constrainedZ_le_of_subset {β : ℝ} {ref r : ι → ℝ} {S T : Finset ι}
    (href : IsPosProb ref) (hST : S ⊆ T) :
    constrainedZ β ref r S ≤ constrainedZ β ref r T :=
  Finset.sum_le_sum_of_subset_of_nonneg hST
    fun i _ _ => mul_nonneg (href.pos i).le (Real.exp_pos _).le

/-! ## Level 0: the constrained variational principle -/

omit [DecidableEq ι] in
/-- Any policy supported in the admissible set scores at most the constrained
free energy. -/
theorem rlhfObj_le_constrainedFreeEnergy {β : ℝ} (hβ : 0 < β) {ref r p : ι → ℝ}
    {S : Finset ι} (href : IsPosProb ref) (hp : IsProb p) (hsupp : ∀ i ∉ S, p i = 0)
    (hS : S.Nonempty) :
    rlhfObj β ref r p ≤ constrainedFreeEnergy β ref r S := by
  set W := constrainedZ β ref r S with hW
  have hWpos : 0 < W := constrainedZ_pos href hS
  set w : ι → ℝ := fun i => ref i * Real.exp (r i / β) with hw
  have hwpos : ∀ i, 0 < w i := fun i => mul_pos (href.pos i) (Real.exp_pos _)
  -- mass on the admissible set is one
  have hpS : ∑ i ∈ S, p i = 1 := by
    rw [← hp.sum_one]
    exact Finset.sum_subset (Finset.subset_univ S) fun i _ hiS => hsupp i hiS
  -- Gibbs inequality on `S` against the normalised tilted measure
  have hgibbs : 0 ≤ ∑ i ∈ S, p i * Real.log (p i / (w i / W)) := by
    have hterm : ∀ i ∈ S, p i - w i / W ≤ p i * Real.log (p i / (w i / W)) := by
      intro i _
      exact term_le _ _ (hp.nonneg i) (div_pos (hwpos i) hWpos)
    have hsum := Finset.sum_le_sum hterm
    have hleft : ∑ i ∈ S, (p i - w i / W) = 0 := by
      have hWsum : ∑ i ∈ S, w i = W := rfl
      rw [Finset.sum_sub_distrib, hpS, ← Finset.sum_div, hWsum, div_self hWpos.ne', sub_self]
    linarith [hleft ▸ hsum]
  -- rewrite the objective as a KL against the tilted measure
  have hkl : klDivFin p ref = ∑ i ∈ S, p i * Real.log (p i / ref i) := by
    simp only [klDivFin]
    refine (Finset.sum_subset (Finset.subset_univ S) fun i _ hiS => ?_).symm
    simp [hsupp i hiS]
  have hrew : ∑ i, p i * r i = ∑ i ∈ S, p i * r i := by
    refine (Finset.sum_subset (Finset.subset_univ S) fun i _ hiS => ?_).symm
    simp [hsupp i hiS]
  have hsplit : ∀ i ∈ S, p i * Real.log (p i / (w i / W))
      = p i * Real.log (p i / ref i) - p i * (r i / β) + p i * Real.log W := by
    intro i _
    rcases eq_or_lt_of_le (hp.nonneg i) with h | h
    · simp [← h]
    · have h1 : p i / (w i / W) = (p i / ref i) * (Real.exp (-(r i / β)) * W) := by
        simp only [hw]
        rw [Real.exp_neg]
        field_simp
      rw [h1, Real.log_mul (div_pos h (href.pos i)).ne'
          (mul_pos (Real.exp_pos _) hWpos).ne',
        Real.log_mul (Real.exp_pos _).ne' hWpos.ne', Real.log_exp]
      ring
  have hcalc : ∑ i ∈ S, p i * Real.log (p i / (w i / W))
      = klDivFin p ref - (∑ i ∈ S, p i * r i) / β + Real.log W := by
    rw [Finset.sum_congr rfl hsplit, Finset.sum_add_distrib, Finset.sum_sub_distrib,
      ← Finset.sum_mul, hpS, one_mul, hkl]
    congr 1
    congr 1
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun i _ => by ring
  rw [hcalc] at hgibbs
  simp only [rlhfObj, constrainedFreeEnergy, ← hW, hrew]
  have hmul : β * (klDivFin p ref - (∑ i ∈ S, p i * r i) / β + Real.log W) ≥ 0 :=
    mul_nonneg hβ.le hgibbs
  have hexp : β * (klDivFin p ref - (∑ i ∈ S, p i * r i) / β + Real.log W)
      = β * klDivFin p ref - (∑ i ∈ S, p i * r i) + β * Real.log W := by
    field_simp
  linarith [hexp ▸ hmul]

theorem constrainedGibbs_isProb {β : ℝ} {ref r : ι → ℝ} {S : Finset ι} (href : IsPosProb ref)
    (hS : S.Nonempty) : IsProb (constrainedGibbs β ref r S) := by
  have hWpos : 0 < constrainedZ β ref r S := constrainedZ_pos href hS
  refine ⟨fun i => ?_, ?_⟩
  · simp only [constrainedGibbs]
    split
    · exact (div_pos (mul_pos (href.pos i) (Real.exp_pos _)) hWpos).le
    · exact le_rfl
  · simp only [constrainedGibbs]
    rw [Finset.sum_ite_mem, Finset.univ_inter, ← Finset.sum_div]
    exact div_self hWpos.ne'

/-- **The constrained optimum is attained** by the `S`-conditioned Gibbs
policy: the bound of `rlhfObj_le_constrainedFreeEnergy` is exact. -/
theorem rlhfObj_constrainedGibbs {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} {S : Finset ι}
    (href : IsPosProb ref) (hS : S.Nonempty) :
    rlhfObj β ref r (constrainedGibbs β ref r S) = constrainedFreeEnergy β ref r S := by
  have hWpos : 0 < constrainedZ β ref r S := constrainedZ_pos href hS
  have hqval : ∀ i ∈ S, constrainedGibbs β ref r S i
      = ref i * Real.exp (r i / β) / constrainedZ β ref r S := by
    intro i hi
    simp [constrainedGibbs, hi]
  have hqzero : ∀ i ∉ S, constrainedGibbs β ref r S i = 0 := by
    intro i hi
    simp [constrainedGibbs, hi]
  have hqsum : ∑ i ∈ S, constrainedGibbs β ref r S i = 1 := by
    rw [← (constrainedGibbs_isProb (β := β) (r := r) href hS).sum_one]
    exact Finset.sum_subset (Finset.subset_univ S) fun i _ hiS => hqzero i hiS
  have hrew : ∑ i, constrainedGibbs β ref r S i * r i
      = ∑ i ∈ S, constrainedGibbs β ref r S i * r i :=
    (Finset.sum_subset (Finset.subset_univ S) fun i _ hiS => by simp [hqzero i hiS]).symm
  have hkl : klDivFin (constrainedGibbs β ref r S) ref
      = ∑ i ∈ S, constrainedGibbs β ref r S i
          * Real.log (constrainedGibbs β ref r S i / ref i) := by
    simp only [klDivFin]
    refine (Finset.sum_subset (Finset.subset_univ S) fun i _ hiS => ?_).symm
    simp [hqzero i hiS]
  have hlog : ∀ i ∈ S, constrainedGibbs β ref r S i
        * Real.log (constrainedGibbs β ref r S i / ref i)
      = constrainedGibbs β ref r S i * (r i / β)
        - constrainedGibbs β ref r S i * Real.log (constrainedZ β ref r S) := by
    intro i hi
    have hri : ref i ≠ 0 := (href.pos i).ne'
    have hqi : constrainedGibbs β ref r S i / ref i
        = Real.exp (r i / β) / constrainedZ β ref r S := by
      rw [hqval i hi]
      field_simp
    rw [hqi, Real.log_div (Real.exp_pos _).ne' hWpos.ne', Real.log_exp]
    ring
  have hklval : klDivFin (constrainedGibbs β ref r S) ref
      = (∑ i ∈ S, constrainedGibbs β ref r S i * r i) / β
        - Real.log (constrainedZ β ref r S) := by
    rw [hkl, Finset.sum_congr rfl hlog, Finset.sum_sub_distrib, ← Finset.sum_mul, hqsum, one_mul]
    congr 1
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun i _ => by ring
  simp only [rlhfObj, constrainedFreeEnergy, hrew, hklval]
  field_simp
  ring

/-! ## Level 1: symbolic filtering commutes with alignment -/

/-- **Commutation of alignment and symbolic filtering.**  Conditioning the
aligned policy on the admissible set returns exactly the policy obtained by
aligning inside the constraint. -/
theorem constrainedGibbs_eq_conditional {β : ℝ} {ref r : ι → ℝ} {S : Finset ι}
    (href : IsPosProb ref) [Nonempty ι] (hS : S.Nonempty) (i : ι) (hi : i ∈ S) :
    constrainedGibbs β ref r S i
      = gibbs β ref r i / (∑ j ∈ S, gibbs β ref r j) := by
  have hZpos : 0 < tiltZ β ref r := tiltZ_pos href
  have hWpos : 0 < constrainedZ β ref r S := constrainedZ_pos href hS
  have hden : ∑ j ∈ S, gibbs β ref r j = constrainedZ β ref r S / tiltZ β ref r := by
    simp only [gibbs, constrainedZ, Finset.sum_div]
  rw [hden]
  simp only [constrainedGibbs, gibbs, hi, if_pos]
  field_simp

/-! ## Level 2: monotonicity and submodularity over the constraint lattice -/

omit [DecidableEq ι] in
/-- Relaxing the symbolic constraints can only increase the attainable value. -/
theorem constrainedFreeEnergy_mono {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} {S T : Finset ι}
    (href : IsPosProb ref) (hS : S.Nonempty) (hST : S ⊆ T) :
    constrainedFreeEnergy β ref r S ≤ constrainedFreeEnergy β ref r T := by
  have h1 : 0 < constrainedZ β ref r S := constrainedZ_pos href hS
  have h2 : constrainedZ β ref r S ≤ constrainedZ β ref r T :=
    constrainedZ_le_of_subset href hST
  exact mul_le_mul_of_nonneg_left (Real.log_le_log h1 h2) hβ.le

/-- **Submodularity of symbolic constraints (diminishing returns).**
`S ↦ F_S` is a submodular set function on the Boolean lattice of admissible
sets: `F_{S∪T} + F_{S∩T} ≤ F_S + F_T`. -/
theorem constrainedFreeEnergy_submodular {β : ℝ} (hβ : 0 < β) {ref r : ι → ℝ} {S T : Finset ι}
    (href : IsPosProb ref) (hST : (S ∩ T).Nonempty) :
    constrainedFreeEnergy β ref r (S ∪ T) + constrainedFreeEnergy β ref r (S ∩ T)
      ≤ constrainedFreeEnergy β ref r S + constrainedFreeEnergy β ref r T := by
  have hIpos : 0 < constrainedZ β ref r (S ∩ T) := constrainedZ_pos href hST
  have hSpos : 0 < constrainedZ β ref r S :=
    constrainedZ_pos href (hST.mono Finset.inter_subset_left)
  have hTpos : 0 < constrainedZ β ref r T :=
    constrainedZ_pos href (hST.mono Finset.inter_subset_right)
  have hUpos : 0 < constrainedZ β ref r (S ∪ T) :=
    constrainedZ_pos href (hST.mono (Finset.inter_subset_union))
  -- modularity of the partition function
  have hmod : constrainedZ β ref r (S ∪ T) + constrainedZ β ref r (S ∩ T)
      = constrainedZ β ref r S + constrainedZ β ref r T := by
    simpa [constrainedZ] using
      Finset.sum_union_inter (s₁ := S) (s₂ := T) (f := fun i => ref i * Real.exp (r i / β))
  have hIS : constrainedZ β ref r (S ∩ T) ≤ constrainedZ β ref r S :=
    constrainedZ_le_of_subset href Finset.inter_subset_left
  have hIT : constrainedZ β ref r (S ∩ T) ≤ constrainedZ β ref r T :=
    constrainedZ_le_of_subset href Finset.inter_subset_right
  -- the key inequality `Z_{S∪T} Z_{S∩T} ≤ Z_S Z_T`
  have hprod : constrainedZ β ref r (S ∪ T) * constrainedZ β ref r (S ∩ T)
      ≤ constrainedZ β ref r S * constrainedZ β ref r T := by
    nlinarith [hIS, hIT, hmod]
  have hlog := Real.log_le_log (by positivity) hprod
  rw [Real.log_mul hUpos.ne' hIpos.ne', Real.log_mul hSpos.ne' hTpos.ne'] at hlog
  simp only [constrainedFreeEnergy]
  nlinarith [mul_le_mul_of_nonneg_left hlog hβ.le]

/-! ## Level 3: the price of symbolic alignment -/

omit [DecidableEq ι] in
/-- **Price of a symbolic rule set.**  Imposing the constraint `S` costs at most
`oscil r - β log ref(S)`: the reward spread plus a `β`-weighted penalty for the
probability mass pruned by the symbolic rules.  With `S = univ` the bound is
`oscil r`, and it degrades logarithmically as the rules prune more mass. -/
theorem constrainedFreeEnergy_ge_sub {β : ℝ} (hβ : 0 < β) [Nonempty ι] {ref r : ι → ℝ}
    {S : Finset ι} (href : IsPosProb ref) (hS : S.Nonempty) :
    freeEnergy β ref r - constrainedFreeEnergy β ref r S
      ≤ oscil r - β * Real.log (∑ i ∈ S, ref i) := by
  set Mx := univ.sup' univ_nonempty r with hMx
  set mn := univ.inf' univ_nonempty r with hmn
  set m := ∑ i ∈ S, ref i with hm
  have hmpos : 0 < m := Finset.sum_pos (fun i _ => href.pos i) hS
  -- upper bound on the unconstrained free energy
  have hup : freeEnergy β ref r ≤ Mx := freeEnergy_le_max hβ href
  -- lower bound on the constrained free energy
  have hZlow : m * Real.exp (mn / β) ≤ constrainedZ β ref r S := by
    have : ∀ i ∈ S, ref i * Real.exp (mn / β) ≤ ref i * Real.exp (r i / β) := by
      intro i _
      refine mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr ?_) (href.pos i).le
      gcongr
      exact inf'_univ_le r i
    calc m * Real.exp (mn / β) = ∑ i ∈ S, ref i * Real.exp (mn / β) := by
          rw [hm, Finset.sum_mul]
      _ ≤ constrainedZ β ref r S := Finset.sum_le_sum this
  have hlow : β * Real.log m + mn ≤ constrainedFreeEnergy β ref r S := by
    have hpos : 0 < m * Real.exp (mn / β) := by positivity
    have hlog := Real.log_le_log hpos hZlow
    rw [Real.log_mul hmpos.ne' (Real.exp_pos _).ne', Real.log_exp] at hlog
    have := mul_le_mul_of_nonneg_left hlog hβ.le
    have hexp : β * (Real.log m + mn / β) = β * Real.log m + mn := by field_simp
    simp only [constrainedFreeEnergy]
    linarith [hexp ▸ this]
  simp only [oscil, ← hMx, ← hmn]
  linarith

end NeuroSymbolicRLHF