import MachineLearning.SemitotalDomination.Approximation

/-!
# The half-disk packing constant is `3`

The analysis of the algorithm loses a factor `5` because a dominator can own five pairwise
non-adjacent vertices spread all around it.  In a BFS-layered execution a dominator only sees
vertices "on one side", which suggests the smaller constant `3`.  This file proves the
corresponding geometric statement:

> a closed **half**-disk of radius `1` contains no `4` points that are pairwise at distance `> 1`,

in the rotation-invariant form `card_le_three_of_pairwise_far_halfplane`, together with the
graph-theoretic consequence `card_le_three_of_indep_in_closed_half_nbhd`: in a unit disk graph, a
closed neighbourhood intersected with a half-plane contains at most `3` pairwise non-adjacent
vertices.  The bound is attained by `{1, i, -1}` (`exists_three_pairwise_far_in_half_disk`).

-- !-- Lab Notes -- !--
## Hypothesis
The `5` of the approximation ratio is a *full-disk* constant; a layered algorithm should only pay
the *half-disk* constant `3`.

## Experimental outcome
`{1, i, -1}` is `1`-separated (pairwise distances `√2, √2, 2`) inside the upper half-disk, and
adding a fourth point always creates a pair at distance `≤ 1`: with four arguments in `[0, π]`
some consecutive gap is at most `60°`.

## Insights
* The proof is the same angular pigeonhole as for the full disk, but the argument range shrinks
  from `2π` (cyclic, needing the wrap-around case) to `π` (linear, no wrap-around) — which is why
  the half-disk proof is strictly shorter than the disk proof.
* Turning `3` into an improved approximation ratio additionally requires showing that the greedy
  BFS set owned by a dominator lies in a half-plane; that step is *not* proved here and is
  Conjecture 3 of `FUTURE_DIRECTIONS.md`.
-/

namespace SemitotalDomination

open Complex Real Finset

/-- Among four complex numbers in the closed upper half-plane, two distinct ones subtend an angle
of at most `60°` at the origin. -/
theorem exists_close_args_half (z : Fin 4 → ℂ) (hz : ∀ i, 0 ≤ (z i).im) :
    ∃ i j, i ≠ j ∧ (1 : ℝ) / 2 ≤ Real.cos ((z i).arg - (z j).arg) := by
  classical
  have hpi := Real.pi_pos
  have harg0 : ∀ i, 0 ≤ (z i).arg := fun i => Complex.arg_nonneg_iff.mpr (hz i)
  have hargpi : ∀ i, (z i).arg ≤ π := fun i => Complex.arg_le_pi _
  set θ : Fin 4 → ℝ := fun i => (z i).arg with hθ
  by_cases hinj : Function.Injective θ
  · set σ := Tuple.sort θ with hσ
    set f := θ ∘ σ with hf
    have hstrict : StrictMono f :=
      (Tuple.monotone_sort θ).strictMono_of_injective (hinj.comp σ.injective)
    have key : ∀ i j : Fin 4, i ≠ j → f i - f j ≤ π / 3 → 0 ≤ f i - f j →
        ∃ i' j' : Fin 4, i' ≠ j' ∧ (1 : ℝ) / 2 ≤ Real.cos ((z i').arg - (z j').arg) := by
      intro i j hij h1 h0
      refine ⟨σ i, σ j, fun h => hij (σ.injective h), ?_⟩
      have := Real.cos_le_cos_of_nonneg_of_le_pi h0 (by linarith) h1
      rwa [Real.cos_pi_div_three] at this
    by_cases h1 : f 1 - f 0 ≤ π / 3
    · exact key 1 0 (by decide) h1 (by linarith [hstrict (show (0 : Fin 4) < 1 by decide)])
    by_cases h2 : f 2 - f 1 ≤ π / 3
    · exact key 2 1 (by decide) h2 (by linarith [hstrict (show (1 : Fin 4) < 2 by decide)])
    by_cases h3 : f 3 - f 2 ≤ π / 3
    · exact key 3 2 (by decide) h3 (by linarith [hstrict (show (2 : Fin 4) < 3 by decide)])
    push_neg at h1 h2 h3
    exfalso
    have hub : f 3 ≤ π := hargpi (σ 3)
    have hlb : 0 ≤ f 0 := harg0 (σ 0)
    linarith
  · rw [Function.not_injective_iff] at hinj
    obtain ⟨a, b, hab, hne⟩ := hinj
    have harg : (z a).arg = (z b).arg := hab
    exact ⟨a, b, hne, by rw [harg, sub_self, Real.cos_zero]; norm_num⟩

/-- **Half-disk packing lemma.**  A closed half-disk of radius `1` contains no `4` points that
are pairwise at distance greater than `1`. -/
theorem no_four_pairwise_far_in_unit_half_disk (p : Fin 4 → ℂ)
    (hb : ∀ i, ‖p i‖ ≤ 1) (him : ∀ i, 0 ≤ (p i).im)
    (hs : ∀ i j, i ≠ j → 1 < dist (p i) (p j)) : False := by
  obtain ⟨i, j, hij, hcos⟩ := exists_close_args_half p him
  have hle := dist_le_one_of_cos_ge _ _ (hb i) (hb j) hcos
  rw [← dist_eq_norm] at hle
  exact absurd hle (not_le.mpr (hs i j hij))

/-- Rotation-invariant form: at most `3` pairwise `1`-separated points in the intersection of the
closed unit disk around `c` with a closed half-plane through `c` with unit normal direction `u`. -/
theorem card_le_three_of_pairwise_far_halfplane (c u : ℂ) (hu : ‖u‖ = 1) (T : Finset ℂ)
    (hb : ∀ x ∈ T, dist x c ≤ 1)
    (hhalf : ∀ x ∈ T, 0 ≤ ((x - c) * (starRingEnd ℂ) u).im)
    (hs : ∀ x ∈ T, ∀ y ∈ T, x ≠ y → 1 < dist x y) : T.card ≤ 3 := by
  classical
  by_contra hcon
  push_neg at hcon
  obtain ⟨t, htT, htc⟩ := Finset.exists_subset_card_eq (show 4 ≤ T.card by omega)
  have e : Fin 4 ≃ t := (t.equivFin.trans (finCongr htc)).symm
  have hnu : ‖(starRingEnd ℂ) u‖ = 1 := by rwa [RCLike.norm_conj]
  refine no_four_pairwise_far_in_unit_half_disk
    (fun i => ((e i : ℂ) - c) * (starRingEnd ℂ) u) ?_ ?_ ?_
  · intro i
    rw [norm_mul, hnu, mul_one, ← dist_eq_norm]
    exact hb _ (htT (e i).2)
  · intro i
    exact hhalf _ (htT (e i).2)
  · intro i j hij
    have hne : ((e i : ℂ)) ≠ ((e j : ℂ)) := fun hc => hij (e.injective (Subtype.ext hc))
    have hdist : dist (((e i : ℂ) - c) * (starRingEnd ℂ) u) (((e j : ℂ) - c) * (starRingEnd ℂ) u)
        = dist ((e i : ℂ)) ((e j : ℂ)) := by
      rw [dist_eq_norm, dist_eq_norm, ← sub_mul, norm_mul, hnu, mul_one]
      ring_nf
    rw [hdist]
    exact hs _ (htT (e i).2) _ (htT (e j).2) hne

/-- **Sharpness**: `1, i, -1` are three pairwise `1`-separated points of the closed upper unit
half-disk, so the constant `3` is optimal. -/
theorem exists_three_pairwise_far_in_half_disk :
    ∃ p : Fin 3 → ℂ, Function.Injective p ∧ (∀ i, dist (p i) 0 ≤ 1) ∧ (∀ i, 0 ≤ (p i).im) ∧
      ∀ i j, i ≠ j → 1 < dist (p i) (p j) := by
  have hsqrt2 : (1 : ℝ) < Real.sqrt 2 := by
    have h2 : Real.sqrt 1 < Real.sqrt 2 := by apply Real.sqrt_lt_sqrt <;> norm_num
    simpa using h2
  have hd1 : dist (1 : ℂ) I = Real.sqrt 2 := by rw [Complex.dist_eq_re_im]; norm_num
  have hd2 : dist (I : ℂ) (-1) = Real.sqrt 2 := by rw [Complex.dist_eq_re_im]; norm_num
  have hd3 : dist (1 : ℂ) (-1) = 2 := by rw [Complex.dist_eq_re_im]; norm_num
  set p : Fin 3 → ℂ := ![1, I, -1] with hp
  have hfar : ∀ i j : Fin 3, i ≠ j → 1 < dist (p i) (p j) := by
    intro i j hij
    fin_cases i <;> fin_cases j <;> simp_all [dist_comm]
  refine ⟨p, ?_, ?_, ?_, hfar⟩
  · intro i j hij
    by_contra hne
    have hcon := hfar i j hne
    rw [hij] at hcon
    simp only [dist_self] at hcon
    linarith
  · intro i; fin_cases i <;> simp [hp]
  · intro i; fin_cases i <;> simp [hp]

variable {V : Type*} [Fintype V] [DecidableEq V] {G : SimpleGraph V}

omit [Fintype V] in
/-- **Half-neighbourhood packing bound.**  In a unit disk graph, at most `3` pairwise
non-adjacent vertices of the closed neighbourhood of `d` can lie in a half-plane through `d`. -/
theorem card_le_three_of_indep_in_closed_half_nbhd (rep : UnitDiskRep G) (d : V) (u : ℂ)
    (hu : ‖u‖ = 1) {I : Finset V} (hI : G.IsIndepSet (I : Set V))
    (hd : ∀ x ∈ I, x = d ∨ G.Adj d x)
    (hhalf : ∀ x ∈ I, 0 ≤ ((rep.pos x - rep.pos d) * (starRingEnd ℂ) u).im) :
    I.card ≤ 3 := by
  classical
  rw [isIndepSet_iff] at hI
  have hinj : Set.InjOn rep.pos I := by
    intro x hx y hy hxy
    by_contra hne
    have hgt := rep.one_lt_dist hne (hI x (Finset.mem_coe.mp hx) y (Finset.mem_coe.mp hy))
    rw [hxy] at hgt
    simp only [dist_self] at hgt
    linarith
  have hcard : (I.image rep.pos).card = I.card := Finset.card_image_of_injOn hinj
  rw [← hcard]
  refine card_le_three_of_pairwise_far_halfplane (rep.pos d) u hu _ ?_ ?_ ?_
  · intro p hp
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hp
    rcases hd x hx with rfl | hadj
    · simp
    · rw [dist_comm]; exact rep.dist_le_one hadj
  · intro p hp
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hp
    exact hhalf x hx
  · intro p hp q hq hpq
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.mp hp
    obtain ⟨y, hy, rfl⟩ := Finset.mem_image.mp hq
    have hxy : x ≠ y := by rintro rfl; exact hpq rfl
    exact rep.one_lt_dist hxy (hI x hx y hy)

end SemitotalDomination