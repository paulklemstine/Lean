/-! # CatalogBuild.MachineLearning.Neural.NeuralFactorSearch

Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 8
-/

import Mathlib

/-- The fundamental algebraic identity: `4k² - 1 = (2k - 1)(2k + 1)`. -/
theorem four_k_sq_sub_one_eq (k : ℤ) : 4 * k ^ 2 - 1 = (2 * k - 1) * (2 * k + 1) := by
  ring



/-- [Section: # CatalogBuild.MachineLearning.Neural.NeuralFactorSearch
Auto-generated from theorem catalog database.
Domain: MachineLearning/Neural
Declarations: 8] -/
theorem iof_soundness (N : ℕ) (k : ℤ) (d : ℕ)
    (hd_eq : d = Int.gcd (4 * k ^ 2 - 1) (↑N))
    (hd_gt : 1 < d)
    (hd_lt : d < N) :
    d ∣ N ∧ 1 < d ∧ d < N := by
  exact ⟨ hd_eq ▸ Int.natCast_dvd_natCast.mp ( Int.gcd_dvd_right _ _ ), hd_gt, hd_lt ⟩



theorem iof_factor_exists (p : ℕ) (hp : Nat.Prime p) (hp_odd : p ≠ 2) :
    ∃ k : ℤ, 0 < k ∧ k < p ∧ (↑p : ℤ) ∣ (4 * k ^ 2 - 1) := by
  -- By Fermat's Little Theorem, there exists an integer `k` such that `2k ≡ 1 (mod p)`.
  have h_k : ∃ k : ℤ, 2 * k ≡ 1 [ZMOD p] ∧ 0 < k ∧ k < p := by
    exact ⟨ ( p + 1 ) / 2, by rw [ mul_comm, Int.ediv_mul_cancel ( even_iff_two_dvd.mp <| by simpa [ parity_simps ] using hp.odd_of_ne_two hp_odd ) ] ; norm_num [ Int.ModEq ], by linarith [ show 0 < ( p + 1 ) / 2 from Nat.div_pos ( by linarith [ hp.two_le ] ) zero_lt_two ], by linarith [ show ( p + 1 ) / 2 < p from Nat.div_lt_of_lt_mul <| by linarith [ hp.two_le ] ] ⟩;
  obtain ⟨ k, hk₁, hk₂, hk₃ ⟩ := h_k; exact ⟨ k, hk₂, hk₃, by convert hk₁.symm.dvd.mul_left ( 2 * k + 1 ) using 1; ring ⟩ ;



theorem iof_gcd_nontrivial (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (k : ℤ) (hdvd : (↑p : ℤ) ∣ (4 * k ^ 2 - 1)) :
    1 < Int.gcd (4 * k ^ 2 - 1) (↑(p * q)) := by
  refine' lt_of_lt_of_le hp.one_lt _;
  exact Nat.le_of_dvd ( Nat.pos_of_ne_zero ( mt Int.gcd_eq_zero_iff.mp ( by aesop ) ) ) ( Nat.dvd_gcd ( Int.natAbs_dvd_natAbs.mpr hdvd ) ( dvd_mul_right _ _ ) )



theorem residues_2k_minus_one (p : ℕ) (hp : Nat.Prime p) (hp_odd : p ≠ 2) :
    ∃! r : ZMod p, (2 : ZMod p) * r = 1 := by
  -- Let's choose the unique solution $r \equiv 2^{-1} \pmod{p}$ to $2r \equiv 1 \pmod{p}$.
  obtain ⟨r, hr⟩ : ∃ r : ZMod p, 2 * r = 1 := by
    haveI := Fact.mk hp; exact ⟨ 2⁻¹, mul_inv_cancel₀ ( by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two <| lt_of_le_of_ne hp.two_le <| Ne.symm hp_odd ) ⟩ ;
  exact ⟨ r, hr, fun x hx => by haveI := Fact.mk hp; exact mul_left_cancel₀ ( show ( 2 : ZMod p ) ≠ 0 by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two <| lt_of_le_of_ne hp.two_le <| Ne.symm hp_odd ) <| by haveI := Fact.mk hp; linear_combination hx - hr ⟩



theorem residues_2k_plus_one (p : ℕ) (hp : Nat.Prime p) (hp_odd : p ≠ 2) :
    ∃! r : ZMod p, (2 : ZMod p) * r = -1 := by
  obtain ⟨r, hr⟩ : ∃ r : ZMod p, (2 : ZMod p) * r = -1 := by
    haveI := Fact.mk hp;
    exact ⟨ -1 / 2, mul_div_cancel₀ _ ( by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two ( lt_of_le_of_ne hp.two_le ( Ne.symm hp_odd ) ) ) ⟩;
  haveI := Fact.mk hp; exact ⟨ r, hr, by intros s hs; exact mul_left_cancel₀ ( show ( 2 : ZMod p ) ≠ 0 from by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt ( by norm_num ) ( lt_of_le_of_ne hp.two_le hp_odd.symm ) ) <| by linear_combination hs - hr ⟩ ;



theorem iof_hit_count_mod_p (p : ℕ) (hp : Nat.Prime p) (hp_odd : p ≠ 2) :
    haveI : Fact (Nat.Prime p) := ⟨hp⟩
    (Finset.univ.filter (fun k : ZMod p => (2 : ZMod p) * k = 1 ∨ (2 : ZMod p) * k = -1)).card = 2 := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  -- Let $r_1$ be the unique element in $\mathbb{Z}/p\mathbb{Z}$ such that $2r_1 = 1$, and let $r_2$ be the unique element in $\mathbb{Z}/p\mathbb{Z}$ such that $2r_2 = -1$.
  obtain ⟨r1, hr1⟩ : ∃ r1 : ZMod p, 2 * r1 = 1 := by
    exact ⟨ 2⁻¹, mul_inv_cancel₀ ( by erw [ Ne.eq_def, ZMod.natCast_eq_zero_iff ] ; exact Nat.not_dvd_of_pos_of_lt Nat.zero_lt_two ( lt_of_le_of_ne hp.two_le ( Ne.symm hp_odd ) ) ) ⟩
  obtain ⟨r2, hr2⟩ : ∃ r2 : ZMod p, 2 * r2 = -1 := by
    exact ⟨ -r1, by linear_combination' -hr1 ⟩;
  have h_roots : ∀ k : ZMod p, 2 * k = 1 ∨ 2 * k = -1 ↔ k = r1 ∨ k = r2 := by
    grind +ring;
  rw [ Finset.card_eq_two ];
  refine' ⟨ r1, r2, _, _ ⟩ <;> simp_all +decide [ Finset.ext_iff ];
  grind



/-- The IOF loss function depends only on the neuron positions and hyperparameters,
not on the factorization of N. This means gradient descent cannot guide the
search toward valid k values any better than uniform random sampling. -/
theorem iof_loss_independent_of_factors
    (p q p' q' : ℕ) (_hp : Nat.Prime p) (_hq : Nat.Prime q)
    (_hp' : Nat.Prime p') (_hq' : Nat.Prime q')
    (k : ℝ) (freq mass phase : ℝ) (epoch : ℕ) :
    let spatial_loss := mass * (k - (0.5 + 0.49 * Real.sin (↑epoch * freq + phase))) ^ 2
    let iof_loss := 0.15 * Real.cos (k * 1e12 * Real.pi)
    let loss := spatial_loss + iof_loss
    -- The loss for N = p*q equals the loss for N' = p'*q'
    -- because N does not appear in the loss function at all
    (fun N : ℕ => loss) (p * q) = (fun N : ℕ => loss) (p' * q') := by
  simp


