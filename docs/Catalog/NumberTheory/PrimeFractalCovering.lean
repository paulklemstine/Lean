import Catalog.NumberTheory.PrimeFractalRefined

/-!
# Robustness of the box dimension: grid boxes versus arbitrary covers

`NumberTheory.PrimeFractalBoxDimension` computes the box dimension of the prime
fractal with *grid* boxes `[k/m, (k+1)/m)`.  A critic may object that the value
of a "dimension" must not depend on that choice.  It does not: an interval of
length `1/m` meets at most two grid boxes, so any cover of `S` by `K` intervals
of length `1/m` satisfies `boxCountSet S m ≤ 2 K`.

Consequently the dimension-`1` lower bound survives verbatim for the
covering-number definition of the Minkowski dimension
(`primeFractal_cover_card_ge`): however cleverly one covers the primes by
intervals of length `1/m`, one needs `m^{1-o(1)}` of them.
-/

namespace PrimeFractal

open Filter Topology

/-- Two consecutive grid indices are all that an interval of length `1/m` can meet. -/
theorem boxCountSet_le_two_mul_cover {S : Set ℝ} {m : ℕ} {I : Set ℝ} (hIfin : I.Finite)
    (hcov : S ⊆ ⋃ c ∈ I, Set.Icc c (c + 1 / (m : ℝ))) :
    boxCountSet S m ≤ 2 * I.ncard := by
  classical
  set g : ℝ × ℕ → ℕ := fun q => ⌊(m : ℝ) * q.1⌋₊ + q.2 with hg
  have hfinprod : (I ×ˢ ({0, 1} : Set ℕ)).Finite := hIfin.prod (Set.toFinite _)
  have hsub : (fun x => ⌊(m : ℝ) * x⌋₊) '' S ⊆ g '' (I ×ˢ ({0, 1} : Set ℕ)) := by
    rintro k ⟨x, hx, rfl⟩
    obtain ⟨t, ht, hxt⟩ := Set.mem_iUnion₂.mp (hcov hx)
    obtain ⟨hc1, hc2⟩ := hxt
    rcases Nat.eq_zero_or_pos m with hm0 | hmpos
    · refine ⟨(t, 0), ⟨ht, by simp⟩, ?_⟩
      simp [hg, hm0]
    · have hm0' : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hmpos
      have hlow : (m : ℝ) * t ≤ (m : ℝ) * x := by nlinarith
      have hhigh : (m : ℝ) * x ≤ (m : ℝ) * t + 1 := by
        have : (m : ℝ) * x ≤ (m : ℝ) * (t + 1 / (m : ℝ)) := by nlinarith
        calc (m : ℝ) * x ≤ (m : ℝ) * (t + 1 / (m : ℝ)) := this
          _ = (m : ℝ) * t + 1 := by field_simp
      have h1 : ⌊(m : ℝ) * t⌋₊ ≤ ⌊(m : ℝ) * x⌋₊ := Nat.floor_le_floor hlow
      have h2 : ⌊(m : ℝ) * x⌋₊ ≤ ⌊(m : ℝ) * t⌋₊ + 1 := by
        have hstep : ⌊(m : ℝ) * x⌋₊ ≤ ⌊(m : ℝ) * t + 1⌋₊ := Nat.floor_le_floor hhigh
        rcases le_or_gt 0 ((m : ℝ) * t) with hpos | hneg
        · rwa [Nat.floor_add_one hpos] at hstep
        · have : ⌊(m : ℝ) * t + 1⌋₊ = 0 := by
            apply Nat.floor_eq_zero.mpr
            linarith
          omega
      refine ⟨(t, ⌊(m : ℝ) * x⌋₊ - ⌊(m : ℝ) * t⌋₊), ⟨ht, ?_⟩, ?_⟩
      · have : ⌊(m : ℝ) * x⌋₊ - ⌊(m : ℝ) * t⌋₊ = 0 ∨ ⌊(m : ℝ) * x⌋₊ - ⌊(m : ℝ) * t⌋₊ = 1 := by
          omega
        rcases this with h | h <;> simp [h]
      · simp only [hg]
        omega
  have hfinimg : (g '' (I ×ˢ ({0, 1} : Set ℕ))).Finite := hfinprod.image _
  calc boxCountSet S m ≤ (g '' (I ×ˢ ({0, 1} : Set ℕ))).ncard :=
        Set.ncard_le_ncard hsub hfinimg
    _ ≤ (I ×ˢ ({0, 1} : Set ℕ)).ncard := Set.ncard_image_le hfinprod
    _ = I.ncard * ({0, 1} : Set ℕ).ncard := Set.ncard_prod
    _ = 2 * I.ncard := by
        rw [Set.ncard_pair (by norm_num)]
        ring

/-- **Covering form of the lower bound.**  For every `ε > 0`, eventually in `m`: any
finite family of intervals of length `1/m` covering the prime fractal has at least
`m ^ (1 - ε)` members.  The box dimension `1` is therefore not an artefact of the grid. -/
theorem primeFractal_cover_card_ge {ε : ℝ} (hε : 0 < ε) :
    ∀ᶠ m : ℕ in atTop, ∀ I : Set ℝ, I.Finite →
      primeFractal ⊆ (⋃ c ∈ I, Set.Icc c (c + 1 / (m : ℝ))) →
      1 - ε ≤ Real.log I.ncard / Real.log m := by
  have hsmall : Tendsto (fun m : ℕ =>
      (Real.log 32) * (1 / Real.log m) + 4 * (Real.log (Real.log m) / Real.log m))
      atTop (𝓝 0) := by
    have ha := tendsto_inv_log.const_mul (Real.log 32)
    have hb := tendsto_log_log_div_log.const_mul (4 : ℝ)
    simpa using ha.add hb
  filter_upwards [eventually_boxCount_ge, eventually_two_le_log, eventually_ge_atTop 1,
    hsmall.eventually (gt_mem_nhds hε)] with m hge hL2 hm1 hsm
  intro I hIfin hcov
  have hL0 : 0 < Real.log m := by linarith
  have hm0 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm1
  -- transfer the grid lower bound to the cover
  have hbox : boxCount m ≤ 2 * I.ncard := by
    rw [boxCount_eq_boxCountSet]
    exact boxCountSet_le_two_mul_cover hIfin hcov
  have hbox' : (boxCount m : ℝ) ≤ 2 * (I.ncard : ℝ) := by exact_mod_cast hbox
  have hbc1 : (1 : ℝ) ≤ (boxCount m : ℝ) := by exact_mod_cast one_le_boxCount m
  have hIpos : (0 : ℝ) < (I.ncard : ℝ) := by linarith
  -- lower bound for `log (boxCount m)`
  have hpos : (0 : ℝ) < (m : ℝ) / (16 * (Real.log m) ^ 4) := by positivity
  have hlog := Real.log_le_log hpos hge
  have hexp : Real.log ((m : ℝ) / (16 * (Real.log m) ^ 4))
      = Real.log m - Real.log 16 - 4 * Real.log (Real.log m) := by
    rw [Real.log_div (ne_of_gt hm0) (by positivity),
      Real.log_mul (by norm_num) (by positivity), Real.log_pow]
    push_cast
    ring
  rw [hexp] at hlog
  have hlogI : Real.log (boxCount m) ≤ Real.log 2 + Real.log I.ncard := by
    have h := Real.log_le_log (by linarith) hbox'
    rwa [Real.log_mul (by norm_num) (ne_of_gt hIpos)] at h
  have hlog32 : Real.log 32 = Real.log 16 + Real.log 2 := by
    rw [← Real.log_mul (by norm_num) (by norm_num)]
    norm_num
  have hkey : Real.log m - Real.log 32 - 4 * Real.log (Real.log m) ≤ Real.log I.ncard := by
    rw [hlog32]
    linarith [hlog, hlogI]
  rw [le_div_iff₀ hL0]
  have hsm' : Real.log 32 * (1 / Real.log m) + 4 * (Real.log (Real.log m) / Real.log m) < ε :=
    hsm
  have hmul : Real.log 32 + 4 * Real.log (Real.log m) < ε * Real.log m := by
    have h1 : Real.log 32 * (1 / Real.log m) = Real.log 32 / Real.log m := by ring
    have h2 : (Real.log 32 + 4 * Real.log (Real.log m)) / Real.log m < ε := by
      rw [add_div]
      rw [h1] at hsm'
      have : 4 * (Real.log (Real.log m) / Real.log m)
          = 4 * Real.log (Real.log m) / Real.log m := by ring
      linarith [hsm', this.le, this.ge]
    rw [div_lt_iff₀ hL0] at h2
    linarith
  linarith [hkey, hmul]

end PrimeFractal