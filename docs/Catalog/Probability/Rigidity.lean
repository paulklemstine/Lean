/-
# Mod-`p` rigidity of the parity-weighted exponent counter

Conjecture A says the counter `permCoeff S T : ZMod p → ℚ` is nonzero somewhere.  This file
proves a complementary *rigidity* statement in the opposite regime: once the matrix is large
enough that the `π`-adic depth of the minor exceeds the ramification index,

  `p - 1 ≤ n(n-1)/2`,

the whole counter is **constant modulo `p`**.

The mechanism is the following chain.

1. `ParityGap.pi_pow_dvd_det_zpow` gives `π ^ (n(n-1)/2) ∣ det (ζ ^ (S j · T k))` in
   `ℤ[ζ_p] = ℤ[X]/(Φ_p)`, hence `π ^ (p-1) ∣ det` under the hypothesis.
2. Writing `det = mk (∑_r c_r X^{r.val})` with `c_r = permCoeffZ S T r ∈ ℤ` the Leibniz
   expansion, divisibility by `π ^ m` in the quotient turns into divisibility of the mod-`p`
   reduction by `(X - 1) ^ m`, because `Φ_p ≡ (X-1)^{p-1} (mod p)`
   (`ParityGap.X_sub_one_pow_eq_geom_sum`).
3. A polynomial of degree `< p` over `𝔽_p` divisible by `(X-1)^{p-1} = 1 + X + ⋯ + X^{p-1}` is a
   *constant multiple of that geometric sum*, so all of its coefficients coincide.

Main results:

* `ParityGap.X_sub_one_pow_eq_geom_sum` — `(X-1)^{p-1} = ∑_{i<p} X^i` over `𝔽_p`;
* `ParityGap.permCoeffZ_congr_of_pi_depth` — the rigidity theorem;
* `ParityGap.full_support_or_large_gap` — the resulting dichotomy: in the rigid regime either the
  counter is supported on *every* residue, or the parity gap is at least `p`;
* `ParityGap.large_support_or_large_gap` — the general support-versus-height dichotomy, valid for
  all `n`: the counter is either supported on more than `min (n(n-1)/2) (p-1)` residues, or it
  takes a value of absolute value at least `p`.
-/

import Mathlib
import Catalog.Probability.ParityGap.Valuation
import Catalog.Probability.ParityGap.GapQuantitative

open Polynomial Finset PrimeUncertainty

namespace ParityGap

variable {p : ℕ} [hp : Fact p.Prime] {n : ℕ}

/-! ## The cyclotomic polynomial modulo `p` -/

/-- Over `𝔽_p` the cyclotomic polynomial `Φ_p = 1 + X + ⋯ + X^{p-1}` is `(X - 1)^{p-1}`. -/
theorem X_sub_one_pow_eq_geom_sum :
    ((X : (ZMod p)[X]) - 1) ^ (p - 1) = ∑ i ∈ range p, X ^ i := by
  have hp0 : 0 < p := hp.out.pos
  have h1 : ((X : (ZMod p)[X]) - 1) ^ (p - 1) * (X - 1) = (∑ i ∈ range p, X ^ i) * (X - 1) := by
    rw [← pow_succ, Nat.sub_add_cancel hp0, sub_pow_char, one_pow, geom_sum_mul]
  have hne : (X : (ZMod p)[X]) - 1 ≠ 0 := by
    intro h
    have := congrArg (fun q => Polynomial.coeff q 1) h
    simp [Polynomial.coeff_one] at this
  exact mul_right_cancel₀ hne h1

/-- The mod-`p` reduction of the integral cyclotomic polynomial. -/
theorem map_cyclotomic_int_eq :
    (cyclotomic p ℤ).map (Int.castRingHom (ZMod p)) = ((X : (ZMod p)[X]) - 1) ^ (p - 1) := by
  rw [map_cyclotomic, cyclotomic_prime, X_sub_one_pow_eq_geom_sum]

/-! ## Transferring `π`-divisibility to the reduced polynomial ring -/

omit hp in
/-- `π = ζ - 1` is the class of `X - 1`. -/
theorem pi_eq_mk : pi p = AdjoinRoot.mk (cyclotomic p ℤ) ((X : ℤ[X]) - 1) := by
  rw [pi, zeta, ← AdjoinRoot.mk_X]
  simp

/-- If the class of `f` is divisible by `π ^ m` (with `m ≤ p - 1`), then the mod-`p` reduction of
`f` is divisible by `(X - 1) ^ m`. -/
theorem X_sub_one_pow_dvd_of_pi_pow_dvd {m : ℕ} (hm : m ≤ p - 1) (f : ℤ[X])
    (h : pi p ^ m ∣ AdjoinRoot.mk (cyclotomic p ℤ) f) :
    ((X : (ZMod p)[X]) - 1) ^ m ∣ f.map (Int.castRingHom (ZMod p)) := by
  obtain ⟨y, hy⟩ := h
  obtain ⟨g, rfl⟩ := AdjoinRoot.mk_surjective y
  have hz : AdjoinRoot.mk (cyclotomic p ℤ) (f - ((X : ℤ[X]) - 1) ^ m * g) = 0 := by
    rw [map_sub, hy, pi_eq_mk]
    simp
  rw [AdjoinRoot.mk_eq_zero] at hz
  obtain ⟨h', hh'⟩ := hz
  have hmap := congrArg (fun q : ℤ[X] => q.map (Int.castRingHom (ZMod p))) hh'
  simp only [Polynomial.map_sub, Polynomial.map_mul, Polynomial.map_pow, Polynomial.map_sub,
    Polynomial.map_X, Polynomial.map_one, map_cyclotomic_int_eq] at hmap
  have : f.map (Int.castRingHom (ZMod p))
      = ((X : (ZMod p)[X]) - 1) ^ (p - 1) * h'.map (Int.castRingHom (ZMod p))
        + ((X : (ZMod p)[X]) - 1) ^ m * g.map (Int.castRingHom (ZMod p)) := by
    linear_combination hmap
  rw [this]
  exact dvd_add (Dvd.dvd.mul_right (pow_dvd_pow _ hm) _) (Dvd.dvd.mul_right dvd_rfl _)

/-- A polynomial over `𝔽_p` of degree `< p` divisible by `(X-1)^{p-1}` has all its coefficients
in degrees `< p` equal. -/
theorem coeff_eq_coeff_of_X_sub_one_pow_dvd (g : (ZMod p)[X]) (hdeg : g.natDegree < p)
    (hdvd : ((X : (ZMod p)[X]) - 1) ^ (p - 1) ∣ g) {a b : ℕ} (ha : a < p) (hb : b < p) :
    g.coeff a = g.coeff b := by
  obtain ⟨h, rfl⟩ := hdvd
  rcases eq_or_ne h 0 with rfl | hh
  · simp
  · have hXC : (X : (ZMod p)[X]) - 1 = X - C 1 := by simp
    have hmonic : (((X : (ZMod p)[X]) - 1) ^ (p - 1)).Monic := by
      rw [hXC]; exact (monic_X_sub_C (1 : ZMod p)).pow _
    have hdegmul : (((X : (ZMod p)[X]) - 1) ^ (p - 1) * h).natDegree
        = (p - 1) + h.natDegree := by
      rw [hmonic.natDegree_mul' hh]
      congr 1
      have : ((X : (ZMod p)[X]) - 1).natDegree = 1 := by
        simpa [Polynomial.C_1] using natDegree_X_sub_C (1 : ZMod p)
      rw [natDegree_pow, this, mul_one]
    have hh0 : h.natDegree = 0 := by
      rw [hdegmul] at hdeg
      have := hp.out.pos
      omega
    obtain ⟨c, rfl⟩ := Polynomial.natDegree_eq_zero.mp hh0
    rw [X_sub_one_pow_eq_geom_sum]
    have hco : ∀ k : ℕ, k < p → ((∑ i ∈ range p, (X : (ZMod p)[X]) ^ i) * C c).coeff k = c := by
      intro k hk
      rw [Polynomial.coeff_mul_C, Polynomial.finset_sum_coeff]
      simp [Polynomial.coeff_X_pow, hk]
    rw [hco a ha, hco b hb]

/-! ## The integral counter and its generating polynomial -/

/-- The integral form of the parity-weighted exponent counter. -/
noncomputable def permCoeffZ (S T : Fin n → ZMod p) (r : ZMod p) : ℤ :=
  ∑ σ ∈ univ.filter (fun σ : Equiv.Perm (Fin n) => permExp S T σ = r), (Equiv.Perm.sign σ : ℤ)

omit hp in
theorem permCoeffZ_cast (S T : Fin n → ZMod p) (r : ZMod p) :
    ((permCoeffZ S T r : ℤ) : ℚ) = permCoeff S T r := (permCoeff_eq_intCast S T r).symm

/-- The generating polynomial `∑_r c_r X^{r.val} ∈ ℤ[X]` of the counter. -/
noncomputable def counterPoly (S T : Fin n → ZMod p) : ℤ[X] :=
  ∑ r : ZMod p, C (permCoeffZ S T r) * X ^ (r.val)

theorem counterPoly_natDegree_lt (S T : Fin n → ZMod p) :
    (counterPoly S T).natDegree < p := by
  have hlt : ∀ r : ZMod p, (C (permCoeffZ S T r) * X ^ (r.val) : ℤ[X]).degree < (p : ℕ) := by
    intro r
    refine lt_of_le_of_lt (Polynomial.degree_C_mul_X_pow_le _ _) ?_
    exact_mod_cast Nat.cast_lt.mpr (ZMod.val_lt r)
  have hdeg : (counterPoly S T).degree < (p : ℕ) :=
    (Polynomial.degree_sum_le _ _).trans_lt
      (by
        refine (Finset.sup_lt_iff (by exact_mod_cast WithBot.bot_lt_coe _)).mpr ?_
        intro r _
        exact hlt r)
  rcases eq_or_ne (counterPoly S T) 0 with h0 | h0
  · rw [h0]
    simpa using hp.out.pos
  · exact (Polynomial.natDegree_lt_iff_degree_lt h0).mpr hdeg

theorem coeff_counterPoly (S T : Fin n → ZMod p) {k : ℕ} (hk : k < p) :
    (counterPoly S T).coeff k = permCoeffZ S T (k : ZMod p) := by
  classical
  rw [counterPoly, Polynomial.finset_sum_coeff]
  have hterm : ∀ r : ZMod p, (C (permCoeffZ S T r) * X ^ (r.val) : ℤ[X]).coeff k
      = if r = (k : ZMod p) then permCoeffZ S T r else 0 := by
    intro r
    rw [Polynomial.coeff_C_mul, Polynomial.coeff_X_pow]
    by_cases hr : r = (k : ZMod p)
    · subst hr
      simp [ZMod.val_natCast_of_lt hk]
    · have : r.val ≠ k := by
        intro hval
        apply hr
        rw [← hval, ZMod.natCast_val, ZMod.cast_id]
      simp [Ne.symm this, hr]
  rw [Finset.sum_congr rfl (fun r _ => hterm r), Finset.sum_ite_eq' univ ((k : ZMod p))]
  simp

/-- The minor is the class of the generating polynomial evaluated at `ζ`. -/
theorem det_zpow_eq_mk_counterPoly (S T : Fin n → ZMod p) :
    (Matrix.of fun j k : Fin n => zpow p (S j * T k)).det
      = AdjoinRoot.mk (cyclotomic p ℤ) (counterPoly S T) := by
  classical
  have hsplit : ∑ r : ZMod p, (permCoeffZ S T r) • zpow p r
      = ∑ σ : Equiv.Perm (Fin n), (Equiv.Perm.sign σ : ℤ) • zpow p (permExp S T σ) := by
    have hterm : ∀ r : ZMod p, (permCoeffZ S T r) • zpow p r
        = ∑ σ : Equiv.Perm (Fin n),
            if permExp S T σ = r then (Equiv.Perm.sign σ : ℤ) • zpow p r else 0 := by
      intro r
      rw [permCoeffZ, Finset.sum_filter, Finset.sum_smul]
      refine Finset.sum_congr rfl fun σ _ => ?_
      split_ifs <;> simp
    rw [Finset.sum_congr rfl fun r _ => hterm r, Finset.sum_comm]
    refine Finset.sum_congr rfl fun σ _ => ?_
    rw [Finset.sum_eq_single (permExp S T σ)]
    · simp
    · intro r _ hr; simp [Ne.symm hr]
    · intro h; exact absurd (Finset.mem_univ (permExp S T σ)) h
  rw [det_zetaPow_eq_sum_permCoeff, ← hsplit, counterPoly, map_sum]
  refine Finset.sum_congr rfl fun r _ => ?_
  rw [map_mul, map_pow, AdjoinRoot.mk_X, AdjoinRoot.mk_C, zpow, zsmul_eq_mul, ← zeta]
  simp

/-! ## Rigidity -/

/-- **Mod-`p` rigidity of the parity counter.**  If the `π`-adic depth `n(n-1)/2` of the minor
reaches the ramification index `p - 1`, the parity-weighted exponent counter is constant modulo
`p`: all of its values are congruent to each other. -/
theorem permCoeffZ_congr_of_pi_depth (hpn : p - 1 ≤ ∑ i ∈ range n, i) (S T : Fin n → ZMod p)
    (r r' : ZMod p) : (p : ℤ) ∣ permCoeffZ S T r - permCoeffZ S T r' := by
  have hdvd : pi p ^ (p - 1) ∣ AdjoinRoot.mk (cyclotomic p ℤ) (counterPoly S T) := by
    rw [← det_zpow_eq_mk_counterPoly]
    exact dvd_trans (pow_dvd_pow _ hpn) (pi_pow_dvd_det_zpow S T)
  have hred := X_sub_one_pow_dvd_of_pi_pow_dvd (le_refl (p - 1)) _ hdvd
  set g : (ZMod p)[X] := (counterPoly S T).map (Int.castRingHom (ZMod p)) with hg
  have hdeg : g.natDegree < p :=
    lt_of_le_of_lt (Polynomial.natDegree_map_le) (counterPoly_natDegree_lt S T)
  have hcoeff := coeff_eq_coeff_of_X_sub_one_pow_dvd g hdeg hred (ZMod.val_lt r) (ZMod.val_lt r')
  have hmapcoeff : ∀ s : ZMod p, g.coeff s.val = ((permCoeffZ S T s : ℤ) : ZMod p) := by
    intro s
    rw [hg, Polynomial.coeff_map, coeff_counterPoly S T (ZMod.val_lt s)]
    simp [ZMod.natCast_val, ZMod.cast_id]
  rw [hmapcoeff r, hmapcoeff r'] at hcoeff
  have : ((permCoeffZ S T r - permCoeffZ S T r' : ℤ) : ZMod p) = 0 := by
    push_cast
    rw [hcoeff]
    ring
  exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp this

/-- **Dichotomy in the rigid regime.**  If `p - 1 ≤ n(n-1)/2` and `S`, `T` are injective, then
either the counter is nonzero at *every* residue, or the parity gap is at least `p`: some residue
carries a parity excess of absolute value `≥ p`.  (Both alternatives are far stronger than the
bare nonvanishing supplied by Conjecture A.) -/
theorem full_support_or_large_gap (hpn : p - 1 ≤ ∑ i ∈ range n, i) (S T : Fin n → ZMod p)
    (hS : Function.Injective S) (hT : Function.Injective T) :
    (∀ r : ZMod p, permCoeffZ S T r ≠ 0) ∨ ∃ r : ZMod p, (p : ℤ) ≤ |permCoeffZ S T r| := by
  by_cases hall : ∀ r : ZMod p, permCoeffZ S T r ≠ 0
  · exact Or.inl hall
  · right
    push_neg at hall
    obtain ⟨r₀, hr₀⟩ := hall
    obtain ⟨r, hr⟩ := exists_permCoeff_ne_zero S T hS hT
    have hrZ : permCoeffZ S T r ≠ 0 := by
      intro h
      apply hr
      rw [← permCoeffZ_cast, h]
      simp
    have hdvd : (p : ℤ) ∣ permCoeffZ S T r := by
      have := permCoeffZ_congr_of_pi_depth hpn S T r r₀
      rwa [hr₀, sub_zero] at this
    exact ⟨r, Int.le_of_dvd (abs_pos.mpr hrZ) ((dvd_abs _ _).mpr hdvd)⟩

/-! ## Support versus height -/

/-- **Support-or-height dichotomy.**  Either every value of the parity-weighted counter is
divisible by `p`, or the counter is supported on more than `min (n(n-1)/2) (p-1)` residues.  The
`π`-adic depth of the minor is thus converted into a *lower bound on the support* through the
characteristic-`p` sparsity lemma. -/
theorem large_support_or_p_dvd (S T : Fin n → ZMod p) :
    (∀ r : ZMod p, (p : ℤ) ∣ permCoeffZ S T r) ∨
      min (∑ i ∈ range n, i) (p - 1) + 1 ≤
        (univ.filter (fun r : ZMod p => permCoeffZ S T r ≠ 0)).card := by
  classical
  set g : (ZMod p)[X] := (counterPoly S T).map (Int.castRingHom (ZMod p)) with hg
  have hcoeff : ∀ r : ZMod p, g.coeff r.val = ((permCoeffZ S T r : ℤ) : ZMod p) := by
    intro r
    rw [hg, Polynomial.coeff_map, coeff_counterPoly S T (ZMod.val_lt r)]
    simp [ZMod.natCast_val, ZMod.cast_id]
  by_cases hg0 : g = 0
  · left
    intro r
    have h0 : ((permCoeffZ S T r : ℤ) : ZMod p) = 0 := by rw [← hcoeff r, hg0]; simp
    exact (ZMod.intCast_zmod_eq_zero_iff_dvd _ p).mp h0
  · right
    set m : ℕ := min (∑ i ∈ range n, i) (p - 1) with hm
    have hdvdpi : pi p ^ m ∣ AdjoinRoot.mk (cyclotomic p ℤ) (counterPoly S T) := by
      rw [← det_zpow_eq_mk_counterPoly]
      exact dvd_trans (pow_dvd_pow _ (min_le_left _ _)) (pi_pow_dvd_det_zpow S T)
    have hdvd : ((X : (ZMod p)[X]) - 1) ^ m ∣ g :=
      X_sub_one_pow_dvd_of_pi_pow_dvd (min_le_right _ _) _ hdvdpi
    have hdeg : g.natDegree < p :=
      lt_of_le_of_lt Polynomial.natDegree_map_le (counterPoly_natDegree_lt S T)
    have hcard := lt_card_support_of_X_sub_one_pow_dvd m g hg0 hdeg hdvd
    have hsub : g.support.card ≤ (univ.filter (fun r : ZMod p => permCoeffZ S T r ≠ 0)).card := by
      refine Finset.card_le_card_of_injOn (fun k => (k : ZMod p)) ?_ ?_
      · intro k hk
        have hklt : k < p := lt_of_le_of_lt (Polynomial.le_natDegree_of_mem_supp k hk) hdeg
        have hne : g.coeff k ≠ 0 := Polynomial.mem_support_iff.mp hk
        refine Finset.mem_filter.mpr ⟨Finset.mem_univ _, ?_⟩
        intro hzero
        apply hne
        have hval : ((k : ZMod p)).val = k := ZMod.val_natCast_of_lt hklt
        rw [← hval, hcoeff ((k : ZMod p)), hzero]
        simp
      · intro a ha b hb hab
        have halt : a < p := lt_of_le_of_lt (Polynomial.le_natDegree_of_mem_supp a ha) hdeg
        have hblt : b < p := lt_of_le_of_lt (Polynomial.le_natDegree_of_mem_supp b hb) hdeg
        have hv := congrArg ZMod.val hab
        rwa [ZMod.val_natCast_of_lt halt, ZMod.val_natCast_of_lt hblt] at hv
    omega

/-- **Support-or-height for injective data.**  Combining the previous dichotomy with
Conjecture A: for injective `S, T` either the counter is supported on more than
`min (n(n-1)/2) (p-1)` residues, or some residue carries a parity excess of absolute value at
least `p`.  In words: the parity gap cannot be both narrow and shallow. -/
theorem large_support_or_large_gap (S T : Fin n → ZMod p) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    min (∑ i ∈ range n, i) (p - 1) + 1 ≤
        (univ.filter (fun r : ZMod p => permCoeffZ S T r ≠ 0)).card
      ∨ ∃ r : ZMod p, (p : ℤ) ≤ |permCoeffZ S T r| := by
  rcases large_support_or_p_dvd S T with hall | hcard
  · right
    obtain ⟨r, hr⟩ := exists_permCoeff_ne_zero S T hS hT
    have hrZ : permCoeffZ S T r ≠ 0 := by
      intro h
      apply hr
      rw [← permCoeffZ_cast, h]
      simp
    exact ⟨r, Int.le_of_dvd (abs_pos.mpr hrZ) ((dvd_abs _ _).mpr (hall r))⟩
  · exact Or.inl hcard

end ParityGap