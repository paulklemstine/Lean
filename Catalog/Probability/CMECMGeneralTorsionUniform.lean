/-
# CM-ECM-GENERAL: the curve-uniform torsion-silence principle and the
# monotone dilution family

This module closes two of the next-cycle sub-conjectures left open by
`Probability.CMECMGeneralSilentSet`:

* **C6 (`⊇` half), curve-uniformly.**  `CMECMGeneralJ0` proved `3 ∣ #E_{j0}(𝔽_p)`
  from an explicit fixed-point-free order-three self-map of the point set, using
  the `p`-group fixed-point congruence — an argument that only works because `3`
  is prime.  Here we remove that restriction:
  `card_dvd_card_of_free_iterate` shows that *any* self-map `f` of a finite type
  with `f^[n] = id` and no `k`-periodic point for `0 < k < n` forces
  `n ∣ #α`, for every `n ≥ 1`.  This is the counting shadow of a free
  `ℤ/n`-action, obtained from the orbit decomposition of the cyclic subgroup
  `⟨f⟩ ≤ Perm α`.  Combined with `empMI_of_const` it yields the
  **torsion-silence principle** `free_torsion_channel_silent`: a rational
  `n`-torsion point (in the shape of a free order-`n` translation on every
  reduction) makes the ECM-order channel `[n ∣ #E(𝔽_p)]` carry *exactly* zero
  bits, on every finite sample and against every class statistic — with no
  hypothesis on `n`, on the curve, or on its CM field.  The `j = 0` situation of
  the round-17 experiment (`n = 3`, and `n = 6` via `CMECMGeneralTorsionSix`) is
  the special case; the mechanism is curve-uniform.

* **C7: dilution is a monotone family.**  `union_dilution` says a single
  class-blind admixture cannot raise the normalised conditional variation, and
  `union_dilution_sharp` realises every factor `c ∈ (0,1)`.  Here we prove that
  the whole family is monotone in the class-blind mass `b`
  (`eta2_add_const_antitone`, strictly in `eta2_add_const_strictAnti`), that no
  achievable dilution factor exceeds `1` (`dilution_factor_le_one`), that every
  achievable factor is positive (`dilution_factor_pos`), and finally that the
  achievable set is *exactly* the half-open interval:
  `dilution_factor_range : {c | DilutionFactor c} = Set.Ioc 0 1`.
  So the experimental law "CM shadow ≤ inert-class channel" is exactly as strong
  as it can be: the inequality is universal, and no constant `< 1` improves it.

## Lab notes

* The order-three map of `CMECMGeneralJ0` is recovered as the case `n = 3` of
  `card_dvd_card_of_free_iterate` (see `three_dvd_card_of_free_order_three'`),
  where the missing freeness at `k = 2` follows from freeness at `k = 1`.
* Measured instances of the dilution factor from the experiment:
  `ℓ = 9`: `0.0120 / 0.0174 ≈ 0.69`; `ℓ = 5`: `0.0030 / 0.0032 ≈ 0.94`; the
  `ℚ(i)` control `ℓ = 3`: `0.0048 / 0.0143 ≈ 0.34`.  All three lie in `(0,1)`,
  and `dilution_factor_range` says each is realised by an honest channel.
-/

import Mathlib
import Probability.CMECMGeneralJ0
import Probability.CMECMGeneralInformation
import Probability.CMECMGeneralSilentSet

open Finset Function MulAction

namespace CMECMGeneralUniform

open CMECMGeneralInfo

/-! ## 1. Free iterates: `n ∣ #α` for every `n`, not just for primes -/

/-- **Free-iterate counting lemma.**  If a finite type carries a self-map `f`
with `f^[n] = id` whose proper iterates `f^[k]`, `0 < k < n`, have no fixed
point at all, then `n ∣ #α`.

This is the counting shadow of a free `ℤ/n`-action: the cyclic subgroup
`⟨f⟩ ≤ Perm α` has order exactly `n`, acts on `α` with trivial stabilisers, and
therefore splits `α` into orbits of size `n`.  Unlike the `p`-group argument of
`CMECMGeneralJ0.three_dvd_card_of_free_order_three`, no primality of `n` is
needed. -/
theorem card_dvd_card_of_free_iterate {α : Type*} [Fintype α] {n : ℕ} (hn : 0 < n)
    (f : α → α) (hfn : ∀ x, f^[n] x = x)
    (hfree : ∀ x, ∀ k, 0 < k → k < n → f^[k] x ≠ x) :
    n ∣ Fintype.card α := by
  classical
  rcases isEmpty_or_nonempty α with hα | hα
  · simp [Fintype.card_eq_zero]
  obtain ⟨x0⟩ := hα
  -- `f` is a permutation, with inverse `f^[n-1]`
  let g : Equiv.Perm α :=
    ⟨f, f^[n - 1], fun x => by
      have h1 : f^[n - 1] (f x) = f^[n] x := by
        rw [← Function.iterate_succ_apply f (n - 1) x]
        congr 1
        omega
      rw [h1, hfn],
     fun x => by
      have h1 : f (f^[n - 1] x) = f^[n] x := by
        rw [← Function.iterate_succ_apply' f (n - 1) x]
        congr 1
        omega
      rw [h1, hfn]⟩
  have hgapp : ∀ x, g x = f x := fun _ => rfl
  have hgk : ∀ (k : ℕ) (x : α), (g ^ k) x = f^[k] x := by
    intro k
    induction k with
    | zero => intro x; simp
    | succ m ih =>
        intro x
        rw [pow_succ, Equiv.Perm.mul_apply, ih, hgapp]
        exact (Function.iterate_succ_apply f m x).symm
  have hgn : g ^ n = 1 := by
    ext x; rw [hgk]; simpa using hfn x
  have horder : orderOf g = n := by
    have hdvd : orderOf g ∣ n := orderOf_dvd_of_pow_eq_one hgn
    have hle : orderOf g ≤ n := Nat.le_of_dvd hn hdvd
    rcases lt_or_eq_of_le hle with hlt | heq
    · exfalso
      have hpos : 0 < orderOf g := by
        rcases Nat.eq_zero_or_pos (orderOf g) with h0 | h
        · rw [h0] at hdvd; omega
        · exact h
      have hx : (g ^ orderOf g) x0 = x0 := by simp
      rw [hgk] at hx
      exact hfree x0 (orderOf g) hpos hlt hx
    · exact heq
  set G := Subgroup.zpowers g with hG
  haveI : Fintype G := Fintype.ofFinite G
  have hcardG : Fintype.card G = n := by
    rw [← Nat.card_eq_fintype_card, Nat.card_zpowers, horder]
  -- the action of `⟨g⟩` on `α` is free
  have hstab : ∀ x : α, MulAction.stabilizer G x = ⊥ := by
    intro x
    rw [Subgroup.eq_bot_iff_forall]
    rintro ⟨h, hmem⟩ hx
    obtain ⟨z, rfl⟩ := hmem
    have hsmul : (g ^ z) x = x := hx
    set k : ℕ := (z % (n : ℤ)).toNat with hk
    have hn' : (0 : ℤ) < (n : ℤ) := by exact_mod_cast hn
    have hmod0 : 0 ≤ z % (n : ℤ) := Int.emod_nonneg z (by omega)
    have hmodlt : z % (n : ℤ) < (n : ℤ) := Int.emod_lt_of_pos z hn'
    have hkz : (k : ℤ) = z % (n : ℤ) := Int.toNat_of_nonneg hmod0
    have hklt : k < n := by omega
    have hzz : g ^ z = g ^ (k : ℕ) := by
      rw [← zpow_natCast, zpow_eq_zpow_iff_modEq, horder, hkz]
      simp [Int.ModEq, Int.emod_emod_of_dvd]
    have hfix : f^[k] x = x := by rw [← hgk, ← hzz]; exact hsmul
    have hk0 : k = 0 := by
      by_contra hne
      exact hfree x k (Nat.pos_of_ne_zero hne) hklt hfix
    refine Subtype.ext ?_
    show g ^ z = 1
    rw [hzz, hk0, pow_zero]
  have hequiv := MulAction.selfEquivOrbitsQuotientProd (α := G) (β := α) hstab
  haveI : Fintype (Quotient (MulAction.orbitRel G α)) := Fintype.ofFinite _
  have hcard := Fintype.card_congr hequiv
  rw [Fintype.card_prod, hcardG] at hcard
  exact ⟨_, by rw [hcard]; ring⟩

/-- The order-three counting lemma of `CMECMGeneralJ0` is the case `n = 3`:
freeness of `f` alone already gives freeness of `f²`, because `f² x = x` forces
`f x = f³ x = x`. -/
theorem three_dvd_card_of_free_order_three' {α : Type*} [Fintype α]
    (f : α → α) (h3 : ∀ x, f (f (f x)) = x) (hfree : ∀ x, f x ≠ x) :
    3 ∣ Fintype.card α := by
  refine card_dvd_card_of_free_iterate (by norm_num) f (fun x => by
    simpa [Function.iterate_succ_apply] using h3 x) ?_
  intro x k hk0 hk3
  interval_cases k
  · simpa using hfree x
  · -- `f² x = x` would give `f x = f³ x = x`
    intro hc
    have hc' : f (f x) = x := by simpa [Function.iterate_succ_apply] using hc
    exact hfree x ((h3 x).symm.trans (congrArg f hc')).symm

/-! ## 2. The torsion-silence principle, curve-uniformly -/

section Silence

variable {Ω : Type*} [Fintype Ω] [Nonempty Ω]
variable {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- **Uniform divisibility ⟹ silence.**  A divisibility event that holds at every
sample point carries exactly zero bits about every class statistic. -/
theorem empMI_zero_of_uniform_dvd (card : Ω → ℕ) (n : ℕ)
    (hdvd : ∀ ω, n ∣ card ω) (c : Ω → κ) :
    empMI c (fun ω => decide (n ∣ card ω)) = 0 := by
  refine empMI_of_const c _ true (fun ω => ?_)
  simp [hdvd ω]

/-- **Torsion-silence principle (curve-uniform).**  Suppose every sample point
`ω` carries a finite point set `pts ω` equipped with a self-map `f ω` that is an
order-`n` translation acting without any periodic point of smaller period — the
shape of "reduction of a rational `n`-torsion point".  Then `n ∣ #pts ω` for
every `ω`, hence the ECM-order channel `[n ∣ #pts]` has *exactly* zero empirical
mutual information with every class statistic, on every finite sample.

For the round-17 curve `y² = x³ + 1` this is the case `n = 3` (the translation
`CMECMGeneral.step`) and, through `CMECMGeneralTorsionSix`, `n = 6`; but nothing
in the statement mentions the curve, its CM field, or the primality of `n`. -/
theorem free_torsion_channel_silent
    (pts : Ω → Type) [∀ ω, Fintype (pts ω)]
    {n : ℕ} (hn : 0 < n) (f : ∀ ω, pts ω → pts ω)
    (hfn : ∀ ω x, (f ω)^[n] x = x)
    (hfree : ∀ ω x, ∀ k, 0 < k → k < n → (f ω)^[k] x ≠ x)
    (c : Ω → κ) :
    empMI c (fun ω => decide (n ∣ Fintype.card (pts ω))) = 0 :=
  empMI_zero_of_uniform_dvd _ n
    (fun ω => card_dvd_card_of_free_iterate hn (f ω) (hfn ω) (hfree ω)) c

end Silence

/-! ## 3. The dilution family is monotone, and its factor set is exactly `(0,1]` -/

section DilutionFamily

variable {κ : Type*} [Fintype κ] {w a : κ → ℝ}

/-- **Monotonicity in the class-blind mass.**  Enlarging the class-blind
admixture can only dilute further, as long as the union base rate stays below
`1/2`. -/
theorem eta2_add_const_antitone (hw : ∀ k, 0 ≤ w k) (hsum : ∑ k, w k = 1)
    {b₁ b₂ : ℝ} (h01 : 0 ≤ b₁) (h12 : b₁ ≤ b₂)
    (hpos : 0 < wmean w a) (hhalf : wmean w a + b₂ ≤ 1 / 2) :
    eta2 w (fun k => a k + b₂) ≤ eta2 w (fun k => a k + b₁) := by
  have h1 : 0 < wmean w a + b₁ := by linarith
  have hden1 : 0 < (wmean w a + b₁) * (1 - (wmean w a + b₁)) := by
    have : wmean w a + b₁ ≤ 1 / 2 := by linarith
    nlinarith
  have hmono : (wmean w a + b₁) * (1 - (wmean w a + b₁))
      ≤ (wmean w a + b₂) * (1 - (wmean w a + b₂)) :=
    base_rate_mono (by linarith) hhalf
  unfold eta2
  rw [wmean_add_const hsum, wvar_add_const hsum, wmean_add_const hsum, wvar_add_const hsum]
  exact div_le_div_of_nonneg_left (wvar_nonneg hw) hden1 hmono

/-- The strict form: a strictly larger class-blind mass strictly dilutes a
nondegenerate channel. -/
theorem eta2_add_const_strictAnti (hsum : ∑ k, w k = 1)
    {b₁ b₂ : ℝ} (h01 : 0 ≤ b₁) (h12 : b₁ < b₂)
    (hpos : 0 < wmean w a) (hhalf : wmean w a + b₂ ≤ 1 / 2) (hvar : 0 < wvar w a) :
    eta2 w (fun k => a k + b₂) < eta2 w (fun k => a k + b₁) := by
  have h1 : 0 < wmean w a + b₁ := by linarith
  have hden1 : 0 < (wmean w a + b₁) * (1 - (wmean w a + b₁)) := by
    have : wmean w a + b₁ ≤ 1 / 2 := by linarith
    nlinarith
  have hmono : (wmean w a + b₁) * (1 - (wmean w a + b₁))
      < (wmean w a + b₂) * (1 - (wmean w a + b₂)) := by nlinarith
  unfold eta2
  rw [wmean_add_const hsum, wvar_add_const hsum, wmean_add_const hsum, wvar_add_const hsum]
  exact div_lt_div_of_pos_left hvar hden1 hmono

/-- A real number `c` is an **achievable dilution factor** when some honest
two-class channel (equal class weights, strictly positive and `< 1` conditional
probabilities, nondegenerate conditional variation, union base rate `≤ 1/2`)
loses exactly the factor `c` of its normalised conditional variation when a
class-blind admixture of mass `b ≥ 0` is added. -/
def DilutionFactor (c : ℝ) : Prop :=
  ∃ (a : Bool → ℝ) (b : ℝ),
    (∀ k, 0 < a k) ∧ (∀ k, a k + b < 1) ∧ 0 ≤ b ∧
    0 < wvar (fun _ : Bool => (1 : ℝ) / 2) a ∧
    0 < wmean (fun _ : Bool => (1 : ℝ) / 2) a ∧
    wmean (fun _ : Bool => (1 : ℝ) / 2) a + b ≤ 1 / 2 ∧
    eta2 (fun _ : Bool => (1 : ℝ) / 2) (fun k => a k + b)
      = c * eta2 (fun _ : Bool => (1 : ℝ) / 2) a

/-- Every achievable dilution factor is at most `1`: the union channel is never
stronger than the class channel it contains. -/
theorem dilution_factor_le_one {c : ℝ} (h : DilutionFactor c) : c ≤ 1 := by
  obtain ⟨a, b, hapos, halt, hb, hvar, hmpos, hhalf, hfac⟩ := h
  set w : Bool → ℝ := fun _ => (1 : ℝ) / 2 with hwdef
  have hwnn : ∀ k, 0 ≤ w k := by intro k; norm_num [hwdef]
  have hsum : ∑ k, w k = 1 := by simp [hwdef]
  have hden : 0 < wmean w a * (1 - wmean w a) := by
    have : wmean w a ≤ 1 / 2 := by linarith
    nlinarith
  have hetapos : 0 < eta2 w a := div_pos hvar hden
  have hle := union_dilution (w := w) (a := a) (b := b) hwnn hsum hb hmpos hhalf
  rw [hfac] at hle
  nlinarith

/-- Every achievable dilution factor is positive: an honest channel never loses
*all* of its conditional variation to a class-blind admixture. -/
theorem dilution_factor_pos {c : ℝ} (h : DilutionFactor c) : 0 < c := by
  obtain ⟨a, b, hapos, halt, hb, hvar, hmpos, hhalf, hfac⟩ := h
  set w : Bool → ℝ := fun _ => (1 : ℝ) / 2 with hwdef
  have hsum : ∑ k, w k = 1 := by simp [hwdef]
  have hden : 0 < wmean w a * (1 - wmean w a) := by
    have : wmean w a ≤ 1 / 2 := by linarith
    nlinarith
  have hdenU : 0 < (wmean w a + b) * (1 - (wmean w a + b)) := by
    have h1 : 0 < wmean w a + b := by linarith
    nlinarith
  have hetapos : 0 < eta2 w a := div_pos hvar hden
  have hetaU : 0 < eta2 w (fun k => a k + b) := by
    unfold eta2
    rw [wmean_add_const hsum, wvar_add_const hsum]
    exact div_pos hvar hdenU
  rw [hfac] at hetaU
  by_contra hcon
  push_neg at hcon
  nlinarith

/-- **The dilution factor set is exactly `(0,1]`.**  Combining the universal
bound (`union_dilution`), the strict positivity of the loss, and the sharpness
construction `union_dilution_sharp`, the achievable factors form precisely the
half-open unit interval: the experimental inequality "CM shadow ≤ inert-class
channel" is universal, and no constant `< 1` can replace `1`. -/
theorem dilution_factor_range : {c : ℝ | DilutionFactor c} = Set.Ioc 0 1 := by
  ext c
  constructor
  · intro h
    exact ⟨dilution_factor_pos h, dilution_factor_le_one h⟩
  · rintro ⟨hc0, hc1⟩
    rcases eq_or_lt_of_le hc1 with rfl | hlt
    · refine ⟨fun k => cond k (1 / 2 : ℝ) (1 / 4), 0, ?_, ?_, le_rfl, ?_, ?_, ?_, ?_⟩
      · intro k; cases k <;> norm_num
      · intro k; cases k <;> norm_num
      · rw [wvar_cond]; norm_num
      · rw [wmean_cond]; norm_num
      · rw [wmean_cond]; norm_num
      · simp
    · obtain ⟨a, b, h1, h2, h3, h4, h5, h6, h7⟩ := union_dilution_sharp hc0 hlt
      exact ⟨a, b, h1, h2, le_of_lt h3, h4, h5, le_of_eq h6, h7⟩

end DilutionFamily

end CMECMGeneralUniform