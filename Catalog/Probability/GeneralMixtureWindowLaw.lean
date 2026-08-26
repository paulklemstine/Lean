/-
  # The window law for arbitrary exponent heterogeneity

  `Probability.HarmonicBulkSteeperEdgeStrict` proves that the window-implied exponent of a
  *two-component* power-law kernel is strictly antitone in the window width.  Nothing in
  that proof used the number two: it used only that the kernel-to-power-law ratio is
  strictly convex in `log k`.  This file carries the argument out for an arbitrary finite
  positive combination of power laws

  `k ↦ ∑ i ∈ s, w i · k ^ (-e i)`,

  and shows that the antitone window law is a signature of *exponent heterogeneity as
  such*: it holds as soon as two of the exponents differ, with any number of components and
  any positive weights.

  * `genRatio_strict_log_convex` — strict convexity in the logarithmic index, from the
    two-power lemmas of `HarmonicBulkSteeperEdgeStrict` plus a strict sum comparison.
  * `genRatio_lt_of_crossed_strict` — strict no-return past a weak crossing.
  * `genHeadMass_strict_single_crossing` — a pure power law matching the mixture's head mass
    on a window reports strictly less head mass on every narrower window.
  * `gen_implied_exponent_strictAnti` — the window-implied exponent is strictly antitone.
  * `two_component_gen_implied_exponent_strictAnti` — the two-component theorem recovered as
    the instance `s = {0, 1}`, confirming the generalisation is faithful.
-/
import Mathlib
import Probability.HarmonicBulkSteeperEdgeStrict

open Finset

namespace HarmonicBulkSteeperEdge

variable {ι : Type*}

/-! ## A finite positive combination of power laws -/

/-- A finite positive combination of power-law kernels: weights `w i > 0` and exponents
`e i`. -/
noncomputable def genKernel (s : Finset ι) (w e : ι → ℝ) (k : ℕ) : ℝ :=
  ∑ i ∈ s, w i * pw (e i) k

/-- Head sum of a general mixture over the window `{1, …, m}`. -/
noncomputable def genHeadSum (s : Finset ι) (w e : ι → ℝ) (m : ℕ) : ℝ :=
  ∑ k ∈ Finset.Icc 1 m, genKernel s w e k

/-- Head mass of a general mixture: the fraction of the weight on `{1,…,n}` carried by
`{1,…,m}`. -/
noncomputable def genHeadMass (s : Finset ι) (w e : ι → ℝ) (n m : ℕ) : ℝ :=
  genHeadSum s w e m / genHeadSum s w e n

/-- Ratio of the general mixture to the pure power law with exponent `c`. -/
noncomputable def genRatio (s : Finset ι) (w e : ι → ℝ) (c : ℝ) (k : ℕ) : ℝ :=
  genKernel s w e k / pw c k

lemma genKernel_pos {s : Finset ι} {w e : ι → ℝ} (hs : s.Nonempty) (hw : ∀ i ∈ s, 0 < w i)
    {k : ℕ} (hk : 1 ≤ k) : 0 < genKernel s w e k :=
  Finset.sum_pos (fun i hi => mul_pos (hw i hi) (pw_pos hk)) hs

lemma genHeadSum_pos {s : Finset ι} {w e : ι → ℝ} (hs : s.Nonempty) (hw : ∀ i ∈ s, 0 < w i)
    {m : ℕ} (hm : 1 ≤ m) : 0 < genHeadSum s w e m :=
  Finset.sum_pos (fun k hk => genKernel_pos hs hw (Finset.mem_Icc.1 hk).1) ⟨1, by simp [hm]⟩

lemma genRatio_eq (s : Finset ι) (w e : ι → ℝ) (c : ℝ) {k : ℕ} (hk : 1 ≤ k) :
    genRatio s w e c k = ∑ i ∈ s, w i * (k : ℝ) ^ (c - e i) := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  rw [genRatio, genKernel, Finset.sum_div]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  rw [pw, pw, mul_div_assoc, ← Real.rpow_sub hk0]
  ring_nf

/-! ## Strict log-convexity for an arbitrary heterogeneous mixture -/

/-- The logarithmic weight realising an intermediate index as a convex combination. -/
lemma exists_log_weight {i j l : ℕ} (hi : 1 ≤ i) (hij : i < j) (hjl : j < l) :
    ∃ lam : ℝ, 0 < lam ∧ lam < 1 ∧
      Real.log (j:ℝ) = lam * Real.log (i:ℝ) + (1 - lam) * Real.log (l:ℝ) := by
  have hj : 1 ≤ j := by omega
  have hl : 1 ≤ l := by omega
  have hx : (0:ℝ) < (i:ℝ) := by exact_mod_cast hi
  have hy : (0:ℝ) < (j:ℝ) := by exact_mod_cast hj
  have hxy : (i:ℝ) < (j:ℝ) := by exact_mod_cast hij
  have hyz : (j:ℝ) < (l:ℝ) := by exact_mod_cast hjl
  have h12 : Real.log (i:ℝ) < Real.log (j:ℝ) := Real.log_lt_log hx hxy
  have h23 : Real.log (j:ℝ) < Real.log (l:ℝ) := Real.log_lt_log hy hyz
  have hden : 0 < Real.log (l:ℝ) - Real.log (i:ℝ) := by linarith
  refine ⟨(Real.log (l:ℝ) - Real.log (j:ℝ)) / (Real.log (l:ℝ) - Real.log (i:ℝ)),
    div_pos (by linarith) hden, ?_, ?_⟩
  · rw [div_lt_one hden]; linarith
  · field_simp
    ring

/-- **Strict log-convexity for arbitrary heterogeneity.**  As soon as two exponents differ,
the mixture-to-power-law ratio is strictly convex in `log k`. -/
lemma genRatio_strict_log_convex {s : Finset ι} {w e : ι → ℝ} {c : ℝ}
    (hw : ∀ i ∈ s, 0 < w i) {p q : ι} (hp : p ∈ s) (hq : q ∈ s) (hpq : e p ≠ e q)
    {i j l : ℕ} (hi : 1 ≤ i) (hij : i < j) (hjl : j < l) :
    ∃ lam : ℝ, 0 < lam ∧ lam < 1 ∧
      genRatio s w e c j < lam * genRatio s w e c i + (1 - lam) * genRatio s w e c l := by
  have hj : 1 ≤ j := by omega
  have hl : 1 ≤ l := by omega
  have hx : (0:ℝ) < (i:ℝ) := by exact_mod_cast hi
  have hy : (0:ℝ) < (j:ℝ) := by exact_mod_cast hj
  have hz : (0:ℝ) < (l:ℝ) := by exact_mod_cast hl
  have hxz : (i:ℝ) ≠ (l:ℝ) := by
    have : (i:ℝ) < (l:ℝ) := by exact_mod_cast lt_trans hij hjl
    exact ne_of_lt this
  obtain ⟨lam, hlam0, hlam1, hcomb⟩ := exists_log_weight hi hij hjl
  -- some component has an exponent different from `c`
  have hex : ∃ i₀ ∈ s, c - e i₀ ≠ 0 := by
    by_cases hcp : c - e p = 0
    · refine ⟨q, hq, ?_⟩
      intro hcq
      exact hpq (by linarith [sub_eq_zero.1 hcp, sub_eq_zero.1 hcq])
    · exact ⟨p, hp, hcp⟩
  obtain ⟨i₀, hi₀s, hi₀⟩ := hex
  refine ⟨lam, hlam0, hlam1, ?_⟩
  rw [genRatio_eq s w e c hi, genRatio_eq s w e c hj, genRatio_eq s w e c hl]
  have hle : ∀ t ∈ s, w t * (j:ℝ) ^ (c - e t)
      ≤ w t * (lam * (i:ℝ) ^ (c - e t) + (1 - lam) * (l:ℝ) ^ (c - e t)) := by
    intro t ht
    exact mul_le_mul_of_nonneg_left
      (rpow_log_convex (c - e t) hx hy hz hlam0 hlam1 hcomb) (hw t ht).le
  have hlt : w i₀ * (j:ℝ) ^ (c - e i₀)
      < w i₀ * (lam * (i:ℝ) ^ (c - e i₀) + (1 - lam) * (l:ℝ) ^ (c - e i₀)) :=
    mul_lt_mul_of_pos_left
      (rpow_log_strictConvex hi₀ hx hy hz hxz hlam0 hlam1 hcomb) (hw i₀ hi₀s)
  have hsum := Finset.sum_lt_sum hle ⟨i₀, hi₀s, hlt⟩
  have hsplit : ∑ t ∈ s, w t * (lam * (i:ℝ) ^ (c - e t) + (1 - lam) * (l:ℝ) ^ (c - e t))
      = lam * ∑ t ∈ s, w t * (i:ℝ) ^ (c - e t)
        + (1 - lam) * ∑ t ∈ s, w t * (l:ℝ) ^ (c - e t) := by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl (fun t _ => by ring)
  rw [hsplit] at hsum
  exact hsum

/-- **Strict no-return** for a general heterogeneous mixture. -/
lemma genRatio_lt_of_crossed_strict {s : Finset ι} {w e : ι → ℝ} {c theta : ℝ}
    (hw : ∀ i ∈ s, 0 < w i) {p q : ι} (hp : p ∈ s) (hq : q ∈ s) (hpq : e p ≠ e q)
    {k₁ k₀ k : ℕ} (hk₁ : 1 ≤ k₁) (h₁₀ : k₁ < k₀) (h₀k : k₀ < k)
    (hlow : genRatio s w e c k₁ ≤ theta) (hhigh : theta ≤ genRatio s w e c k₀) :
    theta < genRatio s w e c k := by
  obtain ⟨lam, hlam0, hlam1, hconv⟩ :=
    genRatio_strict_log_convex (c := c) hw hp hq hpq hk₁ h₁₀ h₀k
  nlinarith [mul_le_mul_of_nonneg_left hlow hlam0.le]

/-! ## The window law -/

/-- **Strict single-crossing for a general mixture.**  If a pure power law with exponent `c`
matches the head mass of a heterogeneous mixture on the window `{1, …, m₂}`, it reports
strictly less head mass on every narrower window. -/
theorem genHeadMass_strict_single_crossing {s : Finset ι} {w e : ι → ℝ} {c : ℝ}
    (hw : ∀ i ∈ s, 0 < w i) {p q : ι} (hp : p ∈ s) (hq : q ∈ s) (hpq : e p ≠ e q)
    {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁) (h₁₂ : m₁ < m₂) (h₂n : m₂ < n)
    (hmatch : headMass c n m₂ = genHeadMass s w e n m₂) :
    headMass c n m₁ < genHeadMass s w e n m₁ := by
  have hs : s.Nonempty := ⟨p, hp⟩
  have hPn : 0 < headSum c n := headSum_pos (by omega)
  have hQn : 0 < genHeadSum s w e n := genHeadSum_pos hs hw (by omega)
  set theta : ℝ := genHeadSum s w e n / headSum c n with htheta
  set d : ℕ → ℝ := fun k => genKernel s w e k - theta * pw c k with hd
  have hT : ∀ m : ℕ, ∑ k ∈ Finset.Icc 1 m, d k
      = genHeadSum s w e m - theta * headSum c m := by
    intro m
    simp [hd, genHeadSum, headSum, Finset.sum_sub_distrib, Finset.mul_sum]
  have hsign : ∀ k : ℕ, 1 ≤ k → d k = pw c k * (genRatio s w e c k - theta) := by
    intro k hk
    have hpk : (0:ℝ) < pw c k := pw_pos hk
    simp only [hd, genRatio]
    field_simp
  have hTn : ∑ k ∈ Finset.Icc 1 n, d k = 0 := by
    rw [hT, htheta]
    field_simp
    ring
  have hTm₂ : ∑ k ∈ Finset.Icc 1 m₂, d k = 0 := by
    rw [hT, htheta]
    have hQm₂ : genHeadSum s w e m₂
        = (genHeadSum s w e n / headSum c n) * headSum c m₂ := by
      have hm := hmatch
      rw [headMass, genHeadMass, div_eq_div_iff (ne_of_gt hPn) (ne_of_gt hQn)] at hm
      field_simp
      linarith [hm]
    rw [hQm₂]
    ring
  have hA : ∀ k₁ k₀ : ℕ, 1 ≤ k₁ → k₁ < k₀ → k₀ ≤ m₂ → d k₁ ≤ 0 → d k₀ < 0 := by
    intro k₁ k₀ hk1 h10 h0m hle
    by_contra hcon
    push_neg at hcon
    have hlow : genRatio s w e c k₁ ≤ theta := by
      have hpk : (0:ℝ) < pw c k₁ := pw_pos hk1
      have hsg := hsign k₁ hk1
      nlinarith [hle, hsg]
    have hhigh : theta ≤ genRatio s w e c k₀ := by
      have hpk : (0:ℝ) < pw c k₀ := pw_pos (by omega)
      have hsg := hsign k₀ (by omega)
      nlinarith [hcon, hsg]
    have htail : ∀ k ∈ Finset.Ioc m₂ n, 0 < d k := by
      intro k hk
      have hkgt : m₂ < k := (Finset.mem_Ioc.1 hk).1
      have hkone : 1 ≤ k := by omega
      have hratio : theta < genRatio s w e c k :=
        genRatio_lt_of_crossed_strict hw hp hq hpq hk1 h10 (by omega) hlow hhigh
      have hpk : (0:ℝ) < pw c k := pw_pos hkone
      have hsg := hsign k hkone
      nlinarith [hratio, hsg]
    have hpos : 0 < ∑ k ∈ Finset.Ioc m₂ n, d k := Finset.sum_pos htail ⟨n, by simp [h₂n]⟩
    have hsplit : ∑ k ∈ Finset.Icc 1 n, d k
        = ∑ k ∈ Finset.Icc 1 m₂, d k + ∑ k ∈ Finset.Ioc m₂ n, d k := sum_Icc_split d h₂n.le
    rw [hTn, hTm₂] at hsplit
    linarith
  have hkey : 0 < ∑ k ∈ Finset.Icc 1 m₁, d k := by
    by_cases hall : ∀ k ∈ Finset.Icc 1 m₁, 0 < d k
    · exact Finset.sum_pos hall ⟨1, by simp [hm₁]⟩
    · push_neg at hall
      obtain ⟨k₁, hk₁mem, hk₁le⟩ := hall
      have hk₁1 : 1 ≤ k₁ := (Finset.mem_Icc.1 hk₁mem).1
      have hk₁m : k₁ ≤ m₁ := (Finset.mem_Icc.1 hk₁mem).2
      have hneg : ∀ k ∈ Finset.Ioc m₁ m₂, d k < 0 := by
        intro k hk
        have hk1 : m₁ < k := (Finset.mem_Ioc.1 hk).1
        have hk2 : k ≤ m₂ := (Finset.mem_Ioc.1 hk).2
        exact hA k₁ k hk₁1 (by omega) hk2 hk₁le
      have hsum : ∑ k ∈ Finset.Ioc m₁ m₂, d k < 0 :=
        Finset.sum_neg hneg ⟨m₂, by simp [h₁₂]⟩
      have hsplit : ∑ k ∈ Finset.Icc 1 m₂, d k
          = ∑ k ∈ Finset.Icc 1 m₁, d k + ∑ k ∈ Finset.Ioc m₁ m₂, d k := sum_Icc_split d h₁₂.le
      rw [hTm₂] at hsplit
      linarith
  rw [hT] at hkey
  have hthP : theta * headSum c n = genHeadSum s w e n := by
    rw [htheta]; field_simp
  have hkey' : theta * headSum c m₁ < genHeadSum s w e m₁ := by linarith
  have hprod : theta * headSum c m₁ * headSum c n = headSum c m₁ * genHeadSum s w e n := by
    rw [← hthP]; ring
  rw [headMass, genHeadMass, div_lt_div_iff₀ hPn hQn]
  linarith [mul_lt_mul_of_pos_right hkey' hPn, hprod]

/-- **Universal antitone window law.**  For *any* finite positive combination of power laws
with at least two distinct exponents, the window-implied exponent is strictly antitone in
the window width.  Exponent heterogeneity as such — not the number of components — is what
produces a steeper-than-bulk left edge. -/
theorem gen_implied_exponent_strictAnti {s : Finset ι} {w e : ι → ℝ} {c₁ c₂ : ℝ}
    (hw : ∀ i ∈ s, 0 < w i) {p q : ι} (hp : p ∈ s) (hq : q ∈ s) (hpq : e p ≠ e q)
    {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁) (h₁₂ : m₁ < m₂) (h₂n : m₂ < n)
    (h₁ : headMass c₁ n m₁ = genHeadMass s w e n m₁)
    (h₂ : headMass c₂ n m₂ = genHeadMass s w e n m₂) :
    c₂ < c₁ := by
  by_contra hcon
  push_neg at hcon
  have hmono : headMass c₁ n m₁ ≤ headMass c₂ n m₁ :=
    headMass_le_of_exponent_le hcon hm₁ (by omega)
  have hstrict : headMass c₂ n m₁ < genHeadMass s w e n m₁ :=
    genHeadMass_strict_single_crossing hw hp hq hpq hm₁ h₁₂ h₂n h₂
  rw [h₁] at hmono
  linarith

/-- The two-component law is the instance `s = {0, 1}` of the general law: with weights
`1 - w` and `w` and exponents `a < b`, the general kernel *is* the bulk × edge mixture. -/
lemma genKernel_two_component (w a b : ℝ) (k : ℕ) :
    genKernel ({0, 1} : Finset ℕ) (fun i => if i = 0 then 1 - w else w)
      (fun i => if i = 0 then a else b) k = mix w a b k := by
  rw [genKernel, mix]
  simp

/-- **The two-component window law as an instance of the general one.**  Recovering
`implied_exponent_strictAnti` from `gen_implied_exponent_strictAnti` confirms that the
generalisation is faithful. -/
theorem two_component_gen_implied_exponent_strictAnti {w a b c₁ c₂ : ℝ} (hw0 : 0 < w)
    (hw1 : w < 1) (hab : a < b) {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁) (h₁₂ : m₁ < m₂) (h₂n : m₂ < n)
    (h₁ : headMass c₁ n m₁ = mixHeadMass w a b n m₁)
    (h₂ : headMass c₂ n m₂ = mixHeadMass w a b n m₂) :
    c₂ < c₁ := by
  have hsum : ∀ m : ℕ, genHeadSum ({0, 1} : Finset ℕ) (fun i => if i = 0 then 1 - w else w)
      (fun i => if i = 0 then a else b) m = mixHeadSum w a b m := by
    intro m
    rw [genHeadSum, mixHeadSum]
    exact Finset.sum_congr rfl (fun k _ => genKernel_two_component w a b k)
  have hmass : ∀ m : ℕ, genHeadMass ({0, 1} : Finset ℕ) (fun i => if i = 0 then 1 - w else w)
      (fun i => if i = 0 then a else b) n m = mixHeadMass w a b n m := by
    intro m
    rw [genHeadMass, mixHeadMass, hsum, hsum]
  refine gen_implied_exponent_strictAnti (s := ({0, 1} : Finset ℕ))
    (w := fun i => if i = 0 then 1 - w else w)
    (e := fun i => if i = 0 then a else b) ?_ (p := 0) (q := 1)
    (by simp) (by simp) ?_ hm₁ h₁₂ h₂n ?_ ?_
  · intro i hi
    have hi' : i = 0 ∨ i = 1 := by simpa using hi
    rcases hi' with h | h
    · subst h
      have hpos : (0:ℝ) < 1 - w := by linarith
      simpa using hpos
    · subst h
      simpa using hw0
  · simpa using ne_of_lt hab
  · rw [hmass]; exact h₁
  · rw [hmass]; exact h₂

end HarmonicBulkSteeperEdge