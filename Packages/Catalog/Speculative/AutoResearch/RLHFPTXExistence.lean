import Algebra.RLHFTiltTorsorPTX

/-!
# Existence of the PPO-ptx aligned policy

`Algebra.RLHFTiltTorsorPTX` proves that the RLHF+PTX objective

```
J(q) = 𝔼_q[r] − β · KL(q ‖ p) + γ · 𝔼_{x∼d}[log q x]
```

is strictly concave, hence has at most one strictly positive maximizer
(`RLHF.ptx_maximizer_unique`).  Unlike the pure RLHF objective it has **no closed-form
maximizer**: the stationarity condition `r y − β(log(q y / p y) + 1) + γ d y / q y = λ` is
transcendental, so the Gibbs formula is unavailable and existence must be proved by a genuine
variational argument.

That argument is carried out here:

* `RLHF.isCompact_simplexSlice` — the `ε`-interior slice of the probability simplex is compact
  (closed subset of a product of compact intervals);
* `RLHF.continuousOn_objectivePTX` — `J` is continuous there (`log` is safe away from `0`);
* `RLHF.objectivePTX_le_of_small` — **boundary repulsion**: with a fully supported pretraining
  distribution the PTX term drives `J → −∞` as any coordinate approaches `0`;
* `RLHF.exists_ptx_maximizer` — hence `J` attains a global maximum over *all* strictly positive
  policies, and
* `RLHF.existsUnique_ptx_maximizer` — combining with strict concavity, the PPO-ptx aligned
  policy **exists and is unique**.

Cross-domain content: a compactness/topology argument (extreme value theorem on a slice of the
simplex) is combined with the algebraic convexity theory of §3 of the previous file.
All results are `sorry`-free.
-/

namespace RLHF

open Finset Set

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]

/-! ## 1. The `ε`-slice of the simplex is compact -/

/-- The slice of the probability simplex consisting of policies with all masses `≥ ε`. -/
def simplexSlice (Ω : Type*) [Fintype Ω] (ε : ℝ) : Set (Ω → ℝ) :=
  {q | (∀ y, ε ≤ q y) ∧ ∑ y, q y = 1}

omit [Nonempty Ω] in
theorem isPosDist_of_mem_simplexSlice {ε : ℝ} (hε : 0 < ε) {q : Ω → ℝ}
    (hq : q ∈ simplexSlice Ω ε) : IsPosDist q :=
  ⟨fun y => lt_of_lt_of_le hε (hq.1 y), hq.2⟩

omit [Nonempty Ω] in
theorem mem_simplexSlice_le_one {ε : ℝ} (hε : 0 < ε) {q : Ω → ℝ}
    (hq : q ∈ simplexSlice Ω ε) (y : Ω) : q y ≤ 1 := by
  have hnn : ∀ z ∈ (univ : Finset Ω), 0 ≤ q z := fun z _ => le_trans hε.le (hq.1 z)
  have := Finset.single_le_sum hnn (mem_univ y)
  rwa [hq.2] at this

omit [Nonempty Ω] in
theorem isCompact_simplexSlice {ε : ℝ} (hε : 0 < ε) : IsCompact (simplexSlice Ω ε) := by
  have hsub : simplexSlice Ω ε ⊆ Set.univ.pi (fun _ : Ω => Set.Icc ε 1) := by
    intro q hq y _
    exact ⟨hq.1 y, mem_simplexSlice_le_one hε hq y⟩
  have hclosed : IsClosed (simplexSlice Ω ε) := by
    have h1 : IsClosed {q : Ω → ℝ | ∀ y, ε ≤ q y} := by
      have : {q : Ω → ℝ | ∀ y, ε ≤ q y} = ⋂ y : Ω, {q : Ω → ℝ | ε ≤ q y} := by
        ext q; simp [Set.mem_iInter]
      rw [this]
      exact isClosed_iInter fun y => isClosed_le continuous_const (continuous_apply y)
    have h2 : IsClosed {q : Ω → ℝ | ∑ y, q y = 1} :=
      isClosed_eq (continuous_finset_sum univ fun y _ => continuous_apply y) continuous_const
    exact h1.inter h2
  exact IsCompact.of_isClosed_subset (isCompact_univ_pi fun _ => isCompact_Icc) hclosed hsub

/-! ## 2. Continuity of the PTX objective on the slice -/

omit [Nonempty Ω] in
theorem continuousOn_objectivePTX {β γ ε : ℝ} {r p d : Ω → ℝ} (hp : IsPosDist p) (hε : 0 < ε) :
    ContinuousOn (objectivePTX β γ r p d) (simplexSlice Ω ε) := by
  have hne : ∀ (y : Ω), ∀ q ∈ simplexSlice Ω ε, q y ≠ 0 := fun y q hq =>
    ne_of_gt (lt_of_lt_of_le hε (hq.1 y))
  have hcont : ContinuousOn
      (fun q : Ω → ℝ => ∑ y, (q y * r y - β * (q y * Real.log (q y / p y))
        + γ * (d y * Real.log (q y)))) (simplexSlice Ω ε) := by
    refine continuousOn_finset_sum univ (fun y _ => ?_)
    have hqy : ContinuousOn (fun q : Ω → ℝ => q y) (simplexSlice Ω ε) :=
      (continuous_apply y).continuousOn
    have hlogq : ContinuousOn (fun q : Ω → ℝ => Real.log (q y)) (simplexSlice Ω ε) :=
      hqy.log (fun q hq => hne y q hq)
    have hlogdiv : ContinuousOn (fun q : Ω → ℝ => Real.log (q y / p y)) (simplexSlice Ω ε) :=
      (hqy.div_const _).log (fun q hq => div_ne_zero (hne y q hq) (ne_of_gt (hp.1 y)))
    exact ((hqy.mul continuousOn_const).sub
      (continuousOn_const.mul (hqy.mul hlogdiv))).add
      (continuousOn_const.mul (continuousOn_const.mul hlogq))
  refine hcont.congr (fun q _ => ?_)
  exact objectivePTX_eq_sum (β := β) (γ := γ) (r := r) (p := p) (d := d) (q := q)

/-! ## 3. Boundary repulsion: the PTX term blows up at the faces of the simplex -/

/-- The maximum of the reward model over the (finite, nonempty) response space. -/
noncomputable def rewardSup (r : Ω → ℝ) : ℝ := univ.sup' univ_nonempty r

theorem le_rewardSup (r : Ω → ℝ) (y : Ω) : r y ≤ rewardSup r :=
  Finset.le_sup' r (mem_univ y)

theorem expectation_le_rewardSup {q r : Ω → ℝ} (hq : IsDist q) :
    ∑ y, q y * r y ≤ rewardSup r := by
  have hterm : ∀ y ∈ (univ : Finset Ω), q y * r y ≤ q y * rewardSup r :=
    fun y _ => mul_le_mul_of_nonneg_left (le_rewardSup r y) (hq.1 y)
  have := Finset.sum_le_sum hterm
  rwa [← Finset.sum_mul, hq.2, one_mul] at this

/-- **Boundary repulsion.**  If the pretraining distribution has full support (masses at least
`δ > 0`) and a policy puts mass below `ε` somewhere, its PTX objective is at most
`sup r + γ δ log ε`, which tends to `−∞` as `ε → 0`. -/
theorem objectivePTX_le_of_small {β γ δ ε : ℝ} {r p d q : Ω → ℝ} (hβ : 0 < β) (hγ : 0 < γ)
    (hp : IsPosDist p) (hq : IsPosDist q) (hd : ∀ y, δ ≤ d y) (hδ : 0 < δ)
    (hε : 0 < ε) (hε1 : ε ≤ 1) {y₀ : Ω} (hy₀ : q y₀ < ε) :
    objectivePTX β γ r p d q ≤ rewardSup r + γ * δ * Real.log ε := by
  classical
  have hqd : IsDist q := hq.isDist
  have hq1 : ∀ y, q y ≤ 1 := by
    intro y
    have hnn : ∀ z ∈ (univ : Finset Ω), 0 ≤ q z := fun z _ => (hq.1 z).le
    have := Finset.single_le_sum hnn (mem_univ y)
    rwa [hq.2] at this
  -- the reward term
  have hrew : ∑ y, q y * r y ≤ rewardSup r := expectation_le_rewardSup hqd
  -- the KL term is nonnegative, so `−β KL ≤ 0`
  have hkl : 0 ≤ klDiv q p := kl_nonneg hqd hp
  -- every PTX summand is `≤ 0`, and the one at `y₀` is `≤ γ δ log ε`
  have hlogle : ∀ y, Real.log (q y) ≤ 0 := fun y => Real.log_nonpos (hq.1 y).le (hq1 y)
  have hy₀mem : y₀ ∈ (univ : Finset Ω) := mem_univ _
  have hhead : d y₀ * Real.log (q y₀) ≤ δ * Real.log ε := by
    have hlt : Real.log (q y₀) ≤ Real.log ε := Real.log_le_log (hq.1 y₀) hy₀.le
    have hdy : 0 < d y₀ := lt_of_lt_of_le hδ (hd y₀)
    have h1 : d y₀ * Real.log (q y₀) ≤ d y₀ * Real.log ε :=
      mul_le_mul_of_nonneg_left hlt hdy.le
    have hlogε : Real.log ε ≤ 0 := Real.log_nonpos hε.le hε1
    have h2 : d y₀ * Real.log ε ≤ δ * Real.log ε :=
      mul_le_mul_of_nonpos_right (hd y₀) hlogε
    linarith
  have htail : ∑ y ∈ univ.erase y₀, d y * Real.log (q y) ≤ 0 :=
    Finset.sum_nonpos (fun y _ =>
      mul_nonpos_of_nonneg_of_nonpos (le_trans hδ.le (hd y)) (hlogle y))
  have hsum : ∑ y, d y * Real.log (q y) ≤ δ * Real.log ε := by
    rw [← Finset.add_sum_erase _ (fun y => d y * Real.log (q y)) hy₀mem]
    linarith
  have hptx : γ * ∑ y, d y * Real.log (q y) ≤ γ * (δ * Real.log ε) :=
    mul_le_mul_of_nonneg_left hsum hγ.le
  unfold objectivePTX objective
  nlinarith [hkl, hrew, hptx, mul_nonneg hβ.le hkl]

/-! ## 4. Existence of the maximizer -/

/-- The uniform policy on a finite nonempty response space. -/
noncomputable def uniformPolicy (Ω : Type*) [Fintype Ω] : Ω → ℝ :=
  fun _ => 1 / (Fintype.card Ω : ℝ)

theorem uniformPolicy_isPosDist : IsPosDist (uniformPolicy Ω) := by
  have hcard : (0 : ℝ) < (Fintype.card Ω : ℝ) := by
    exact_mod_cast Fintype.card_pos
  refine ⟨fun y => div_pos one_pos hcard, ?_⟩
  simp only [uniformPolicy, Finset.sum_const, card_univ, nsmul_eq_mul]
  field_simp

/-- **Existence of a PPO-ptx maximizer.**  With a strictly positive KL coefficient, a strictly
positive PTX coefficient and a fully supported pretraining distribution, the RLHF+PTX objective
attains a global maximum over the strictly positive policies. -/
theorem exists_ptx_maximizer {β γ δ : ℝ} {r p d : Ω → ℝ} (hβ : 0 < β) (hγ : 0 < γ)
    (hp : IsPosDist p) (hd : ∀ y, δ ≤ d y) (hδ : 0 < δ) :
    ∃ q, IsPosDist q ∧ ∀ q', IsPosDist q' → objectivePTX β γ r p d q' ≤ objectivePTX β γ r p d q := by
  classical
  set u : Ω → ℝ := uniformPolicy Ω with hu
  have hud : IsPosDist u := uniformPolicy_isPosDist
  set Ju := objectivePTX β γ r p d u with hJu
  have hcard : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  -- choose `ε` small enough that every policy leaving the slice is worse than the uniform one
  set ε : ℝ := min (1 / (Fintype.card Ω : ℝ))
    (min 1 (Real.exp ((Ju - rewardSup r - 1) / (γ * δ)))) with hε_def
  have hεpos : 0 < ε := by
    refine lt_min (by positivity) (lt_min one_pos (Real.exp_pos _))
  have hε1 : ε ≤ 1 := le_trans (min_le_right _ _) (min_le_left _ _)
  have hεu : ε ≤ 1 / (Fintype.card Ω : ℝ) := min_le_left _ _
  have hγδ : 0 < γ * δ := mul_pos hγ hδ
  have hεexp : ε ≤ Real.exp ((Ju - rewardSup r - 1) / (γ * δ)) :=
    le_trans (min_le_right _ _) (min_le_right _ _)
  have hlogε : Real.log ε ≤ (Ju - rewardSup r - 1) / (γ * δ) := by
    have := Real.log_le_log hεpos hεexp
    rwa [Real.log_exp] at this
  have hcut : rewardSup r + γ * δ * Real.log ε ≤ Ju - 1 := by
    have := mul_le_mul_of_nonneg_left hlogε hγδ.le
    rw [mul_div_cancel₀ _ (ne_of_gt hγδ)] at this
    linarith
  -- the uniform policy lies in the slice
  have humem : u ∈ simplexSlice Ω ε := ⟨fun y => hεu, hud.2⟩
  -- extreme value theorem on the compact slice
  obtain ⟨q₀, hq₀mem, hq₀max⟩ :=
    (isCompact_simplexSlice (Ω := Ω) hεpos).exists_isMaxOn ⟨u, humem⟩
      (continuousOn_objectivePTX (ε := ε) (β := β) (γ := γ) (r := r) (p := p) (d := d) hp hεpos)
  refine ⟨q₀, isPosDist_of_mem_simplexSlice hεpos hq₀mem, fun q' hq' => ?_⟩
  have hJu_le : Ju ≤ objectivePTX β γ r p d q₀ := hq₀max humem
  by_cases hin : q' ∈ simplexSlice Ω ε
  · exact hq₀max hin
  · -- `q'` leaves the slice, so some coordinate is `< ε` and boundary repulsion applies
    have hsmall : ∃ y₀, q' y₀ < ε := by
      by_contra hc
      push_neg at hc
      exact hin ⟨fun y => hc y, hq'.2⟩
    obtain ⟨y₀, hy₀⟩ := hsmall
    have := objectivePTX_le_of_small (β := β) (γ := γ) (δ := δ) (ε := ε) (r := r) (p := p)
      (d := d) (q := q') hβ hγ hp hq' hd hδ hεpos hε1 hy₀
    linarith

/-- **The PPO-ptx aligned policy exists and is unique.**  This is the PTX counterpart of the
Gibbs variational principle: the closed-form maximizer disappears, but existence (compactness
plus boundary repulsion) and uniqueness (strict concavity) both survive. -/
theorem existsUnique_ptx_maximizer {β γ δ : ℝ} {r p d : Ω → ℝ} (hβ : 0 < β) (hγ : 0 < γ)
    (hp : IsPosDist p) (hd : ∀ y, δ ≤ d y) (hδ : 0 < δ) :
    ∃! q, IsPosDist q ∧
      ∀ q', IsPosDist q' → objectivePTX β γ r p d q' ≤ objectivePTX β γ r p d q := by
  obtain ⟨q, hqpos, hqmax⟩ := exists_ptx_maximizer hβ hγ hp hd hδ
  refine ⟨q, ⟨hqpos, hqmax⟩, ?_⟩
  rintro q' ⟨hq'pos, hq'max⟩
  exact ptx_maximizer_unique (β := β) (γ := γ) (r := r) (p := p) (d := d) hβ hγ.le hp
    (fun y => le_trans hδ.le (hd y)) hq'pos hqpos hq'max hqmax

end RLHF