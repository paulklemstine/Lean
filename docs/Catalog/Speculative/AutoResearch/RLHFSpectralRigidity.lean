import NumberTheory.RLHFTemperatureLimits

/-!
# Spectral rigidity of RLHF: the free-energy curve determines the reward spectrum

This file settles Conjecture 5 of `FUTURE_DIRECTIONS.md`: the whole temperature curve
`β ↦ V(β) = β log Z(β)` of a KL-regularized RLHF problem determines the *reward spectrum*
of the model, i.e. the reference mass carried by each reward value.

The bridge is a classical algebraic fact used twice, in two independent proofs:

* `RLHF.exp_sum_uniqueness` — real exponentials `t ↦ exp (v t)` with distinct rates `v` are
  linearly independent.  This is **Dedekind's theorem on independence of characters**
  (`linearIndependent_monoidHom`) applied to the monoid `Multiplicative ℝ`.
* `RLHF.exp_sum_uniqueness_pos` — the same conclusion from the hypothesis on the *half line*
  `t > 0` only, which is what the physics gives us (`β > 0`).  Dedekind's argument does not
  see a half line, so we prove this by a peeling induction: divide by the dominant
  exponential and let `t → ∞`, which kills every subdominant rate.

Main results (all `sorry`-free):

* `RLHF.rewardMass` — the reference mass `∑_{y : r y = v} p y` of the reward value `v`.
* `RLHF.partition_eq_rewardMass_sum` — the partition function is the *Dirichlet-type
  exponential sum* of the reward spectrum: `Z(β) = ∑_v m(v) e^{v/β}`.
* `RLHF.spectral_rigidity` — equal partition functions at all `β > 0` force equal reward
  spectra, even across different response spaces.
* `RLHF.freeEnergy_rigidity` — the same conclusion from equality of the free-energy curves.
* `RLHF.rewardMax_eq_of_freeEnergy_eq` — in particular the reward ceiling is determined.
* `RLHF.vonMangoldt_spectral_rigidity` — arithmetic instantiation: any reward model on
  `{1, …, N}` with the same free-energy curve as the von Mangoldt reward has, for every
  value `v`, exactly as many responses of value `v`; the alignment curve therefore encodes
  the whole multiset `{Λ(1), …, Λ(N)}`, i.e. the counts `#{p^k ≤ N}` for each prime `p`.
-/

namespace RLHF

open Finset Filter Topology

/-! ## 1. Independence of real exponentials -/

/-- The character `t ↦ exp (v t)` of the additive group of reals, viewed as a monoid
homomorphism `Multiplicative ℝ →* ℝ`. -/
noncomputable def expChar (v : ℝ) : Multiplicative ℝ →* ℝ where
  toFun := fun t => Real.exp (v * Multiplicative.toAdd t)
  map_one' := by simp
  map_mul' := by
    intro a b
    show Real.exp (v * (Multiplicative.toAdd a + Multiplicative.toAdd b)) = _
    rw [mul_add, Real.exp_add]

theorem expChar_injective : Function.Injective expChar := by
  intro a b h
  have : Real.exp (a * 1) = Real.exp (b * 1) :=
    congrArg (fun f => f (Multiplicative.ofAdd (1 : ℝ))) h
  simpa using Real.exp_injective this

/-- **Independence of exponentials (Dedekind).**  If a finite real combination of the
characters `t ↦ exp (v t)`, with distinct rates `v`, vanishes identically, all coefficients
vanish. -/
theorem exp_sum_uniqueness (S : Finset ℝ) (c : ℝ → ℝ)
    (h : ∀ t : ℝ, ∑ v ∈ S, c v * Real.exp (v * t) = 0) : ∀ v ∈ S, c v = 0 := by
  have hli : LinearIndependent ℝ (fun v : ℝ => (expChar v : Multiplicative ℝ → ℝ)) :=
    (linearIndependent_monoidHom (Multiplicative ℝ) ℝ).comp expChar expChar_injective
  rw [linearIndependent_iff'] at hli
  refine hli S c ?_
  funext t
  simpa [expChar] using h (Multiplicative.toAdd t)

/-- **Independence of exponentials on a half line.**  The same conclusion as
`exp_sum_uniqueness`, but assuming the identity only for `t > 0`.  Proved by peeling off the
dominant rate: after dividing by `exp (M t)` with `M` the largest rate, every other term
decays as `t → ∞`. -/
theorem exp_sum_uniqueness_pos : ∀ (S : Finset ℝ) (c : ℝ → ℝ),
    (∀ t : ℝ, 0 < t → ∑ v ∈ S, c v * Real.exp (v * t) = 0) → ∀ v ∈ S, c v = 0 := by
  intro S
  induction S using Finset.strongInduction with
  | _ S ih =>
    intro c h
    rcases S.eq_empty_or_nonempty with rfl | hne
    · simp
    · set M := S.max' hne with hM
      have hMmem : M ∈ S := S.max'_mem hne
      have hG : Tendsto (fun t : ℝ => ∑ v ∈ S, c v * Real.exp ((v - M) * t)) atTop (𝓝 (c M)) := by
        have key : Tendsto (fun t : ℝ => ∑ v ∈ S, c v * Real.exp ((v - M) * t)) atTop
            (𝓝 (∑ v ∈ S, if v = M then c M else 0)) := by
          refine tendsto_finset_sum _ (fun v hv => ?_)
          by_cases hvM : v = M
          · subst hvM; simp
          · have hlt : v - M < 0 := by
              have h1 : v ≤ M := S.le_max' v hv
              have : v < M := lt_of_le_of_ne h1 hvM
              linarith
            simp only [hvM, if_false]
            have hb : Tendsto (fun t : ℝ => (v - M) * t) atTop atBot := by
              have h2 : Tendsto (fun t : ℝ => (M - v) * t) atTop atTop :=
                Filter.Tendsto.const_mul_atTop (by linarith) tendsto_id
              exact (tendsto_neg_atTop_atBot.comp h2).congr (fun t => by simp [Function.comp]; ring)
            have hexp : Tendsto (fun t : ℝ => Real.exp ((v - M) * t)) atTop (𝓝 0) :=
              Real.tendsto_exp_atBot.comp hb
            simpa using hexp.const_mul (c v)
        rw [Finset.sum_ite_eq' S M (fun _ => c M), if_pos hMmem] at key
        exact key
      have hzero : Tendsto (fun t : ℝ => ∑ v ∈ S, c v * Real.exp ((v - M) * t)) atTop (𝓝 0) := by
        refine Tendsto.congr' ?_ tendsto_const_nhds
        filter_upwards [eventually_gt_atTop (0 : ℝ)] with t ht
        have hsum := h t ht
        have hrw : ∑ v ∈ S, c v * Real.exp ((v - M) * t)
            = Real.exp (-(M * t)) * ∑ v ∈ S, c v * Real.exp (v * t) := by
          rw [Finset.mul_sum]
          refine Finset.sum_congr rfl (fun v _ => ?_)
          rw [sub_mul, Real.exp_sub, Real.exp_neg]
          field_simp
        rw [hrw, hsum, mul_zero]
      have hcM : c M = 0 := tendsto_nhds_unique hG hzero
      intro v hv
      by_cases hvM : v = M
      · rw [hvM]; exact hcM
      · refine ih (S.erase M) (Finset.erase_ssubset hMmem) c ?_ v (Finset.mem_erase.2 ⟨hvM, hv⟩)
        intro t ht
        have hsum := h t ht
        rw [← Finset.sum_erase_add S _ hMmem, hcM, zero_mul, add_zero] at hsum
        exact hsum

/-! ## 2. The reward spectrum of an RLHF problem -/

variable {Ω : Type*} [Fintype Ω]

/-- The **reward spectrum**: `rewardMass r p v` is the reference mass carried by the level
set `{y : r y = v}` of the reward model. -/
noncomputable def rewardMass (r p : Ω → ℝ) (v : ℝ) : ℝ :=
  ∑ y ∈ univ.filter (fun y => r y = v), p y

theorem rewardMass_eq_zero {r p : Ω → ℝ} {v : ℝ} (hv : v ∉ image r univ) :
    rewardMass r p v = 0 := by
  have hempty : (univ.filter (fun y => r y = v)) = ∅ :=
    Finset.filter_false_of_mem (fun y _ h => hv (Finset.mem_image.2 ⟨y, Finset.mem_univ y, h⟩))
  rw [rewardMass, hempty, Finset.sum_empty]

/-- The partition function is the exponential sum of the reward spectrum. -/
theorem partition_eq_rewardMass_sum {r p : Ω → ℝ} (t : ℝ) :
    ∑ y, p y * Real.exp (r y * t)
      = ∑ v ∈ image r univ, rewardMass r p v * Real.exp (v * t) := by
  rw [← Finset.sum_fiberwise_of_maps_to (g := r) (fun y _ => Finset.mem_image_of_mem r
    (Finset.mem_univ y)) (fun y => p y * Real.exp (r y * t))]
  refine Finset.sum_congr rfl (fun v _ => ?_)
  rw [rewardMass, Finset.sum_mul]
  refine Finset.sum_congr rfl (fun y hy => ?_)
  rw [(Finset.mem_filter.1 hy).2]

theorem sum_exp_eq_rewardMass_sum {r p : Ω → ℝ} {S : Finset ℝ} (hS : image r univ ⊆ S) (t : ℝ) :
    ∑ y, p y * Real.exp (r y * t) = ∑ v ∈ S, rewardMass r p v * Real.exp (v * t) := by
  rw [partition_eq_rewardMass_sum t]
  refine Finset.sum_subset hS (fun v _ hv => ?_)
  rw [rewardMass_eq_zero hv, zero_mul]

theorem partition_eq_sum_exp (β : ℝ) (r p : Ω → ℝ) :
    partition β r p = ∑ y, p y * Real.exp (r y * β⁻¹) := by
  unfold partition
  exact Finset.sum_congr rfl (fun y _ => by rw [div_eq_mul_inv])

/-! ## 3. Spectral rigidity -/

/-- **Spectral rigidity of the partition function.**  Two RLHF problems — possibly on
*different* response spaces, with different reward models and different reference policies —
whose partition functions agree at every positive temperature have the *same reward
spectrum*: every reward value carries the same reference mass in both problems. -/
theorem spectral_rigidity {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Fintype Ω₂]
    {r₁ p₁ : Ω₁ → ℝ} {r₂ p₂ : Ω₂ → ℝ}
    (h : ∀ β : ℝ, 0 < β → partition β r₁ p₁ = partition β r₂ p₂) :
    ∀ v : ℝ, rewardMass r₁ p₁ v = rewardMass r₂ p₂ v := by
  set S : Finset ℝ := image r₁ univ ∪ image r₂ univ with hSdef
  have hS₁ : image r₁ univ ⊆ S := Finset.subset_union_left
  have hS₂ : image r₂ univ ⊆ S := Finset.subset_union_right
  set c : ℝ → ℝ := fun v => rewardMass r₁ p₁ v - rewardMass r₂ p₂ v with hc
  have hvanish : ∀ t : ℝ, 0 < t → ∑ v ∈ S, c v * Real.exp (v * t) = 0 := by
    intro t ht
    have hinv : (t⁻¹ : ℝ)⁻¹ = t := inv_inv t
    have hkey := h t⁻¹ (by positivity)
    rw [partition_eq_sum_exp, partition_eq_sum_exp, hinv,
      sum_exp_eq_rewardMass_sum hS₁ t, sum_exp_eq_rewardMass_sum hS₂ t] at hkey
    have : ∑ v ∈ S, c v * Real.exp (v * t)
        = (∑ v ∈ S, rewardMass r₁ p₁ v * Real.exp (v * t))
          - ∑ v ∈ S, rewardMass r₂ p₂ v * Real.exp (v * t) := by
      rw [← Finset.sum_sub_distrib]
      exact Finset.sum_congr rfl (fun v _ => by rw [hc]; ring)
    rw [this, hkey, sub_self]
  have hzero := exp_sum_uniqueness_pos S c hvanish
  intro v
  by_cases hv : v ∈ S
  · have := hzero v hv
    rw [hc] at this
    simp only at this
    linarith
  · have h1 : v ∉ image r₁ univ := fun hmem => hv (hS₁ hmem)
    have h2 : v ∉ image r₂ univ := fun hmem => hv (hS₂ hmem)
    rw [rewardMass_eq_zero h1, rewardMass_eq_zero h2]

/-- **Rigidity of the free-energy curve.**  If two RLHF problems have the same optimal value
`V(β) = β log Z(β)` at every positive KL coefficient, then they have the same reward
spectrum.  By the Gibbs variational principle this says: the alignment value curve is a
complete invariant of the pair (reward model, reference policy) up to relabelling. -/
theorem freeEnergy_rigidity {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Fintype Ω₂] [Nonempty Ω₁]
    [Nonempty Ω₂] {r₁ p₁ : Ω₁ → ℝ} {r₂ p₂ : Ω₂ → ℝ} (hp₁ : IsPosDist p₁) (hp₂ : IsPosDist p₂)
    (h : ∀ β : ℝ, 0 < β → freeEnergy β r₁ p₁ = freeEnergy β r₂ p₂) :
    ∀ v : ℝ, rewardMass r₁ p₁ v = rewardMass r₂ p₂ v := by
  refine spectral_rigidity (fun β hβ => ?_)
  have hZ₁ := partition_pos (β := β) (r := r₁) hp₁
  have hZ₂ := partition_pos (β := β) (r := r₂) hp₂
  have hlog : Real.log (partition β r₁ p₁) = Real.log (partition β r₂ p₂) := by
    have := h β hβ
    unfold freeEnergy at this
    exact mul_left_cancel₀ (ne_of_gt hβ) this
  calc partition β r₁ p₁ = Real.exp (Real.log (partition β r₁ p₁)) := (Real.exp_log hZ₁).symm
    _ = Real.exp (Real.log (partition β r₂ p₂)) := by rw [hlog]
    _ = partition β r₂ p₂ := Real.exp_log hZ₂

theorem rewardMass_pos_of_mem {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) {v : ℝ}
    (hv : v ∈ image r univ) : 0 < rewardMass r p v := by
  obtain ⟨y, -, hy⟩ := Finset.mem_image.1 hv
  refine Finset.sum_pos' (fun z _ => (hp z).le) ⟨y, Finset.mem_filter.2 ⟨Finset.mem_univ y, hy⟩,
    hp y⟩

/-- The support of the reward spectrum is the set of attained reward values. -/
theorem mem_image_iff_rewardMass_ne_zero {r p : Ω → ℝ} (hp : ∀ y, 0 < p y) {v : ℝ} :
    v ∈ image r univ ↔ rewardMass r p v ≠ 0 :=
  ⟨fun hv => ne_of_gt (rewardMass_pos_of_mem hp hv),
    fun hne => by by_contra hv; exact hne (rewardMass_eq_zero hv)⟩

/-- **The reward ceiling is spectrally determined.**  Equal free-energy curves force equal
maximal rewards.  (This upgrades the zero-temperature limit theorem from a computation of
`V(0⁺)` to an inverse statement.) -/
theorem rewardMax_eq_of_freeEnergy_eq {Ω₁ Ω₂ : Type*} [Fintype Ω₁] [Fintype Ω₂] [Nonempty Ω₁]
    [Nonempty Ω₂] {r₁ p₁ : Ω₁ → ℝ} {r₂ p₂ : Ω₂ → ℝ} (hp₁ : IsPosDist p₁) (hp₂ : IsPosDist p₂)
    (h : ∀ β : ℝ, 0 < β → freeEnergy β r₁ p₁ = freeEnergy β r₂ p₂) :
    rewardMax r₁ = rewardMax r₂ := by
  have hmass := freeEnergy_rigidity hp₁ hp₂ h
  have himg : ∀ v : ℝ, v ∈ image r₁ univ ↔ v ∈ image r₂ univ := by
    intro v
    rw [mem_image_iff_rewardMass_ne_zero hp₁.1, mem_image_iff_rewardMass_ne_zero hp₂.1, hmass v]
  refine le_antisymm ?_ ?_
  · obtain ⟨y, hy⟩ := exists_rewardMax r₁
    have : rewardMax r₁ ∈ image r₂ univ :=
      (himg _).1 (Finset.mem_image.2 ⟨y, Finset.mem_univ y, hy⟩)
    obtain ⟨z, -, hz⟩ := Finset.mem_image.1 this
    rw [← hz]
    exact le_rewardMax r₂ z
  · obtain ⟨y, hy⟩ := exists_rewardMax r₂
    have : rewardMax r₂ ∈ image r₁ univ :=
      (himg _).2 (Finset.mem_image.2 ⟨y, Finset.mem_univ y, hy⟩)
    obtain ⟨z, -, hz⟩ := Finset.mem_image.1 this
    rw [← hz]
    exact le_rewardMax r₁ z

/-! ## 4. Arithmetic instantiation: the von Mangoldt spectrum -/

/-- Under a uniform reference the reward spectrum is the normalized level-set count. -/
theorem rewardMass_unifRef {N : ℕ} (r : Fin N → ℝ) (v : ℝ) :
    rewardMass r (unifRef N) v = ((univ.filter (fun i : Fin N => r i = v)).card : ℝ) / N := by
  rw [rewardMass]
  unfold unifRef
  rw [Finset.sum_const, nsmul_eq_mul]
  ring

/-- **Rigidity of the von Mangoldt alignment curve.**  If a reward model `r` on the response
space `{1, …, N}` with the uniform SFT reference produces the same RLHF value curve as the
von Mangoldt reward, then it has exactly the same level-set counts.  In particular the curve
`β ↦ V(β)` knows, for every prime `p`, how many prime powers `p^k ≤ N` there are: alignment
value data determines the arithmetic of the response space. -/
theorem vonMangoldt_spectral_rigidity {N : ℕ} (hN : 0 < N) (r : Fin N → ℝ)
    (h : ∀ β : ℝ, 0 < β →
      haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
      freeEnergy β (vonMangoldtReward N) (unifRef N) = freeEnergy β r (unifRef N)) :
    ∀ v : ℝ, (univ.filter (fun i : Fin N => vonMangoldtReward N i = v)).card
      = (univ.filter (fun i : Fin N => r i = v)).card := by
  haveI : Nonempty (Fin N) := Fin.pos_iff_nonempty.mp hN
  have hp := unifRef_isPosDist hN
  have hmass := freeEnergy_rigidity hp hp h
  intro v
  have := hmass v
  rw [rewardMass_unifRef, rewardMass_unifRef] at this
  have hNR : (0 : ℝ) < (N : ℝ) := by exact_mod_cast hN
  have hcard : ((univ.filter (fun i : Fin N => vonMangoldtReward N i = v)).card : ℝ)
      = ((univ.filter (fun i : Fin N => r i = v)).card : ℝ) := by
    field_simp at this
    exact this
  exact_mod_cast hcard

end RLHF