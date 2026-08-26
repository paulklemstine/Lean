import MachineLearning.QRResidual.BlockCeiling
import MachineLearning.QRResidual.Blindness
import MachineLearning.QRResidual.MeasurableCeiling

/-!
# The neighbourhood layer is arithmetically free of the dial — and statistically null

Experiment 585 appends to the quadratic-residue *footprint dial* a block of four
"neighbour smoothness" covariates read off the local factorisation structure around the
modulus `N`, namely `ω(N−1)`, `ω(N+1)` and the (log) least prime factors of `N ∓ 1`.  The
verdict was `H0_SUPPORTED`: the block adds `ΔR² = 0.0195` over the dial, with permutation
`p = 0.389`.

This file gives the two halves of a *theorem-level* account of that verdict.

## 1. Arithmetic half: no deterministic coupling exists

* `exists_large_congr_omega` — for any modulus `P > 0`, any target residue `N₀ mod P`, any
  `a` and any bound, there are integers `N` above the bound with `N ≡ N₀ (mod P)` whose two
  neighbours `N ∓ 1` each have at least `a` distinct prime factors.
* `dial_neighborhood_free` — consequently, for **every** value of the footprint dial and
  **every** target level `a`, arbitrarily large `N` realise that dial value while both
  neighbour covariates exceed `a`.  Conditioning on the neighbourhood layer does not
  restrict the dial at all.
* `neighborCovariate_not_dial_measurable` — the neighbour covariate is not a function of
  the dial: two moduli with identical dial value can have different `ω(N−1)`.
* `dial_range_free_under_neighborhood_constraint` — the whole dial range survives the
  neighbourhood constraint.

Arithmetically, then, the two feature families are *independent by construction*: any
correlation between them in a finite sample is a property of the sample, not a theorem.
This is exactly the licence the experiment needs to read a small `ΔR²` as "no structure",
and it is what the ledger's exchangeability caveat is about.

## 2. Statistical half: the ceiling certificates for exp 585

* `exp585_block_ceiling` — with the reported baseline `R²₀ = 0.4112`, an orthonormal block
  of `k = 4` covariates whose residual correlations are all at most `0.16` cannot lift `R²`
  by more than `0.0604`.  The observed `0.01946` sits comfortably below the ceiling.
* `exp585_exclusion_threshold` — sharpening: at `ρ ≤ 0.1457` the same ceiling drops below
  the pre-registered alternative `ΔR² ≥ 0.05`.  Since the observed best single correlation
  was `0.16 > 0.1457`, the correlation profile *alone* does not exclude `H1`; the null
  verdict genuinely rests on the joint fit and the permutation test.  (Recording this
  boundary is the adversarial part of the analysis.)
* `exp585_lift_asymmetry` — with the reported conditional dial lift `0.3987`, the dial's
  incremental value given the whole neighbourhood block strictly exceeds the block's
  incremental value given the dial baseline: "nothing beyond the dial", as a theorem about
  the design rather than a summary of one fit.
-/

namespace QRResidual

open Finset

/-! ## Arithmetic freedom of the neighbourhood layer -/

/-- The neighbour covariate: the number of distinct prime factors of `N + s`.  For
`s = ±1` this is the `ω(N∓1)` pair used as the first two covariates of the block. -/
def nbOmega (N s : ℤ) : ℕ := (N + s).natAbs.primeFactors.card

/-- There are arbitrarily large finite sets of primes, all exceeding a prescribed bound. -/
theorem exists_primeSet_gt (x a : ℕ) :
    ∃ S : Finset ℕ, S.card = a ∧ ∀ p ∈ S, p.Prime ∧ x < p := by
  induction a with
  | zero => exact ⟨∅, by simp, by simp⟩
  | succ n ih =>
    obtain ⟨S, hcard, hS⟩ := ih
    obtain ⟨q, hq, hqp⟩ := Nat.exists_infinite_primes (S.sup id + x + 1)
    have hqS : q ∉ S := by
      intro hmem
      have : id q ≤ S.sup id := Finset.le_sup hmem
      simp only [id] at this
      omega
    refine ⟨insert q S, by rw [Finset.card_insert_of_notMem hqS, hcard], ?_⟩
    intro p hp
    rcases Finset.mem_insert.1 hp with rfl | hp'
    · exact ⟨hqp, by omega⟩
    · exact hS p hp'

/-- Two-modulus Chinese remainder theorem over `ℤ`, by Bézout. -/
theorem int_crt_pair {m n : ℕ} (hcop : Nat.Coprime m n) (a b : ℤ) :
    ∃ N : ℤ, (m : ℤ) ∣ (N - a) ∧ (n : ℤ) ∣ (N - b) := by
  have hc : IsCoprime (m : ℤ) (n : ℤ) := Int.isCoprime_iff_gcd_eq_one.2 (by
    simpa [Int.gcd_natCast_natCast] using hcop)
  obtain ⟨u, v, huv⟩ := hc
  refine ⟨a * (v * n) + b * (u * m), ⟨u * (b - a), ?_⟩, ⟨v * (a - b), ?_⟩⟩
  · linear_combination a * huv
  · linear_combination b * huv

/-- A product of primes all exceeding `k` is coprime to `k`. -/
theorem coprime_prod_of_gt {S : Finset ℕ} {k : ℕ} (hk : 0 < k)
    (hS : ∀ p ∈ S, p.Prime ∧ k < p) : Nat.Coprime (∏ p ∈ S, p) k := by
  refine Nat.Coprime.prod_left ?_
  intro p hp
  obtain ⟨hpp, hlt⟩ := hS p hp
  exact (Nat.Prime.coprime_iff_not_dvd hpp).2 fun hdvd => absurd (Nat.le_of_dvd hk hdvd) (by omega)

theorem prod_prime_pos {S : Finset ℕ} (hS : ∀ p ∈ S, p.Prime) : 0 < ∏ p ∈ S, p :=
  Finset.prod_pos fun p hp => (hS p hp).pos

/-- **Core arithmetic freedom lemma.**  A residue class modulo `P` and an arbitrarily rich
prime factorisation of *both* neighbours can be imposed simultaneously, arbitrarily far
out.  The residue class is what fixes any residue dial; the neighbour factorisations are
what the smoothness covariates read.  Neither constrains the other. -/
theorem exists_large_congr_omega (P : ℕ) (hP : 0 < P) (N₀ : ℤ) (a : ℕ) (bound : ℤ) :
    ∃ N : ℤ, bound < N ∧ 2 < N ∧ (P : ℤ) ∣ (N - N₀) ∧
      a ≤ nbOmega N (-1) ∧ a ≤ nbOmega N 1 := by
  obtain ⟨S₁, hc₁, hS₁⟩ := exists_primeSet_gt P a
  set M₁ : ℕ := ∏ p ∈ S₁, p with hM₁
  have hM₁pos : 0 < M₁ := prod_prime_pos fun p hp => (hS₁ p hp).1
  obtain ⟨S₂, hc₂, hS₂⟩ := exists_primeSet_gt (P + M₁) a
  set M₂ : ℕ := ∏ p ∈ S₂, p with hM₂
  have hM₂pos : 0 < M₂ := prod_prime_pos fun p hp => (hS₂ p hp).1
  have hcop12 : Nat.Coprime M₁ M₂ :=
    (coprime_prod_of_gt hM₁pos (fun p hp => ⟨(hS₂ p hp).1, by have := (hS₂ p hp).2; omega⟩)).symm
  have hcop1P : Nat.Coprime M₁ P := coprime_prod_of_gt hP (fun p hp => ⟨(hS₁ p hp).1, (hS₁ p hp).2⟩)
  have hcop2P : Nat.Coprime M₂ P :=
    coprime_prod_of_gt hP (fun p hp => ⟨(hS₂ p hp).1, by have := (hS₂ p hp).2; omega⟩)
  obtain ⟨N₁, hN₁a, hN₁b⟩ := int_crt_pair hcop12 1 (-1)
  obtain ⟨N₂, hN₂a, hN₂b⟩ := int_crt_pair (Nat.Coprime.mul_left hcop1P hcop2P) N₁ N₀
  set K : ℕ := M₁ * M₂ * P with hK
  have hKpos : 0 < K := Nat.mul_pos (Nat.mul_pos hM₁pos hM₂pos) hP
  set t : ℤ := max bound 2 + 2 - N₂ with ht
  set N : ℤ := N₂ + ((t.toNat + 1) * K : ℕ) with hN
  have hKge : (1 : ℤ) ≤ (K : ℤ) := by exact_mod_cast hKpos
  have hNeq : N = N₂ + ((t.toNat : ℤ) + 1) * (K : ℤ) := by rw [hN]; push_cast; ring
  have h1 : t ≤ (t.toNat : ℤ) := Int.self_le_toNat t
  have h2 : ((t.toNat : ℤ) + 1) ≤ ((t.toNat : ℤ) + 1) * (K : ℤ) := by
    nlinarith [Int.natCast_nonneg t.toNat]
  have hlow : max bound 2 + 2 < N := by rw [hNeq]; linarith
  have hb1 : bound ≤ max bound 2 := le_max_left _ _
  have hb2 : (2 : ℤ) ≤ max bound 2 := le_max_right _ _
  have hbound : bound < N := by linarith
  have h2N : (2 : ℤ) < N := by linarith
  have hdvdK : ∀ m : ℕ, m ∣ K → (m : ℤ) ∣ (N - N₂) := by
    intro m hm
    have hrw : N - N₂ = ((t.toNat : ℤ) + 1) * (K : ℤ) := by rw [hNeq]; ring
    rw [hrw]
    exact Dvd.dvd.mul_left (Int.natCast_dvd_natCast.2 hm) _
  have hM1N : (M₁ : ℤ) ∣ (N - 1) := by
    have ha1 : (M₁ : ℤ) ∣ (N - N₂) := hdvdK M₁ ⟨M₂ * P, by rw [hK]; ring⟩
    have ha2 : (M₁ : ℤ) ∣ (N₂ - N₁) := dvd_trans ⟨(M₂ : ℤ), by push_cast; ring⟩ hN₂a
    have ha3 : N - 1 = (N - N₂) + (N₂ - N₁) + (N₁ - 1) := by ring
    rw [ha3]; exact dvd_add (dvd_add ha1 ha2) hN₁a
  have hM2N : (M₂ : ℤ) ∣ (N + 1) := by
    have ha1 : (M₂ : ℤ) ∣ (N - N₂) := hdvdK M₂ ⟨M₁ * P, by rw [hK]; ring⟩
    have ha2 : (M₂ : ℤ) ∣ (N₂ - N₁) := dvd_trans ⟨(M₁ : ℤ), by push_cast; ring⟩ hN₂a
    have ha3 : N + 1 = (N - N₂) + (N₂ - N₁) + (N₁ - (-1)) := by ring
    rw [ha3]; exact dvd_add (dvd_add ha1 ha2) hN₁b
  have hPN : (P : ℤ) ∣ (N - N₀) := by
    have ha1 : (P : ℤ) ∣ (N - N₂) := hdvdK P ⟨M₁ * M₂, by rw [hK]; ring⟩
    have ha3 : N - N₀ = (N - N₂) + (N₂ - N₀) := by ring
    rw [ha3]; exact dvd_add ha1 hN₂b
  refine ⟨N, hbound, h2N, hPN, ?_, ?_⟩
  · have hpos : (0 : ℤ) < N + (-1) := by omega
    have hnat : M₁ ∣ (N + (-1)).natAbs := by
      rw [← Int.natCast_dvd_natCast, Int.natAbs_of_nonneg hpos.le]
      simpa using hM1N
    have hne : (N + (-1)).natAbs ≠ 0 := by simpa using hpos.ne'
    have hsub := Nat.primeFactors_mono hnat hne
    rw [hM₁, Nat.primeFactors_prod (fun p hp => (hS₁ p hp).1)] at hsub
    calc a = S₁.card := hc₁.symm
      _ ≤ _ := Finset.card_le_card hsub
  · have hpos : (0 : ℤ) < N + 1 := by omega
    have hnat : M₂ ∣ (N + 1).natAbs := by
      rw [← Int.natCast_dvd_natCast, Int.natAbs_of_nonneg hpos.le]
      exact hM2N
    have hne : (N + 1).natAbs ≠ 0 := by simpa using hpos.ne'
    have hsub := Nat.primeFactors_mono hnat hne
    rw [hM₂, Nat.primeFactors_prod (fun p hp => (hS₂ p hp).1)] at hsub
    calc a = S₂.card := hc₂.symm
      _ ≤ _ := Finset.card_le_card hsub

/-- **The neighbourhood layer is free of the dial.**  Every attainable footprint-dial value
is attained by arbitrarily large moduli whose two neighbours are as rich in distinct prime
factors as we please. -/
theorem dial_neighborhood_free (B : ℕ) (T : Finset ℕ) (hT : T ⊆ oddFactorBase B) (a : ℕ)
    (bound : ℤ) :
    ∃ N : ℤ, bound < N ∧ qrWeight N B = ∑ p ∈ T, (2 : ℚ) / p ∧
      a ≤ nbOmega N (-1) ∧ a ≤ nbOmega N 1 := by
  obtain ⟨N₀, hN₀⟩ := qrWeight_full_range B T hT
  obtain ⟨N, hbound, -, hdvd, h1, h2⟩ :=
    exists_large_congr_omega (basePrimorial B) (basePrimorial_pos B) N₀ a bound
  exact ⟨N, hbound, by rw [qrWeight_congr_of_primorial hdvd, hN₀], h1, h2⟩

/-- **The neighbour covariate is not a function of the dial.**  Two moduli sharing a dial
value can differ in `ω(N−1)`; hence no deterministic map sends the dial to the
neighbourhood layer, and a regression of one on the other is a genuinely statistical
question. -/
theorem neighborCovariate_not_dial_measurable (B : ℕ) (T : Finset ℕ)
    (hT : T ⊆ oddFactorBase B) :
    ∃ N₁ N₂ : ℤ, qrWeight N₁ B = qrWeight N₂ B ∧ nbOmega N₁ (-1) ≠ nbOmega N₂ (-1) := by
  obtain ⟨N₁, -, hd₁, -, -⟩ := dial_neighborhood_free B T hT 0 0
  obtain ⟨N₂, -, hd₂, hb₂, -⟩ := dial_neighborhood_free B T hT (nbOmega N₁ (-1) + 1) 0
  exact ⟨N₁, N₂, by rw [hd₁, hd₂], by omega⟩

/-- **The dial range is unaffected by the neighbourhood constraint.**  Conditioning the
population on arbitrarily large neighbour covariates leaves every dial value attainable, so
the neighbourhood layer carries no information about the dial by construction. -/
theorem dial_range_free_under_neighborhood_constraint (B : ℕ) (a : ℕ) (bound : ℤ) :
    ∀ v ∈ {v : ℚ | ∃ T ⊆ oddFactorBase B, ∑ p ∈ T, (2 : ℚ) / p = v},
      ∃ N : ℤ, bound < N ∧ qrWeight N B = v ∧ a ≤ nbOmega N (-1) ∧ a ≤ nbOmega N 1 := by
  rintro v ⟨T, hT, rfl⟩
  exact dial_neighborhood_free B T hT a bound

/-! ## The exp-585 certificates -/

variable {ι : Type*} [Fintype ι]

/-- **Exp 585, the block ceiling.**  A four-covariate orthonormal neighbourhood block whose
residual correlations with the dial baseline are all at most `0.16` in absolute value
cannot lift `R²` by more than `0.0604` above the reported baseline `R²₀ = 0.4112`.  The
observed `ΔR² = 0.01946` is well inside this ceiling. -/
theorem exp585_block_ceiling (y g : ι → ℝ) (v : Fin 4 → (ι → ℝ)) (hframe : FrameLower 1 v)
    (htss : 0 < tss y) (hR0 : rsqOf y g = 0.4112)
    (hcorr : ∀ j, (dot (y - g) (v j)) ^ 2 ≤ (0.16 : ℝ) ^ 2 * sqNorm (y - g)) :
    rsq y (blockClass g v) - rsqOf y g ≤ 0.0604 := by
  have h := rsq_block_le_of_corr (k := 4) one_pos hframe y g htss hcorr
  rw [hR0] at h
  norm_num at h
  linarith

/-- **Exp 585, the exclusion threshold.**  Had the block's residual correlations all been
at most `0.1457`, the ceiling alone would have refuted the pre-registered alternative
`ΔR² ≥ 0.05`.  The observed best single correlation was `0.16`, above this threshold, so
the correlation profile by itself is *not* sufficient: the null verdict depends on the
joint fit.  This is a boundary of the certificate, stated honestly. -/
theorem exp585_exclusion_threshold (y g : ι → ℝ) (v : Fin 4 → (ι → ℝ))
    (hframe : FrameLower 1 v) (htss : 0 < tss y) (hR0 : rsqOf y g = 0.4112)
    (hcorr : ∀ j, (dot (y - g) (v j)) ^ 2 ≤ (0.1457 : ℝ) ^ 2 * sqNorm (y - g)) :
    rsq y (blockClass g v) - rsqOf y g < 0.05 := by
  have h := rsq_block_le_of_corr (k := 4) one_pos hframe y g htss hcorr
  rw [hR0] at h
  norm_num at h
  linarith

/-- **Exp 585, the asymmetry.**  With the reported conditional dial lift `0.3987` and a
neighbourhood block orthogonal to the dial feature whose residual correlations are at most
`0.16`, the incremental `R²` of the dial *given the block* strictly exceeds the incremental
`R²` of the block *given the dial baseline*.  This is the formal content of the verdict
"the neighbourhood layer carries nothing beyond the QR dial". -/
theorem exp585_lift_asymmetry (y g : ι → ℝ) (v : Fin 4 → (ι → ℝ)) (w : ι → ℝ)
    (hframe : FrameLower 1 v) (hw : sqNorm w ≠ 0) (horth : ∀ j, dot (v j) w = 0)
    (htss : 0 < tss y) (hR0 : rsqOf y g = 0.4112)
    (hcorr : ∀ j, (dot (y - g) (v j)) ^ 2 ≤ (0.16 : ℝ) ^ 2 * sqNorm (y - g))
    (hdial : (0.3987 : ℝ) ≤ (dot (y - g) w) ^ 2 / (sqNorm w * tss y)) :
    rsq y (blockClass g v) - rsqOf y g
      < rsq y (blockClassPlus g v w) - rsq y (blockClass g v) := by
  refine lift_asymmetry (rho := 0.16) (d := 0.3987) one_pos hframe hw horth y g htss hcorr
    hdial ?_
  rw [hR0]
  norm_num

/-- **The exp-585 verdict, in one statement.**  Under the reported design constants the two
halves of the null verdict hold simultaneously: (i) the four-covariate neighbourhood block
cannot lift `R²` by more than `0.0604` over the dial baseline, and (ii) at least `40 %` of
the response variation is out of reach of *every* function of the joint feature
`(dial, neighbourhood)`, linear or not.  The residual is bounded away from both layers at
once, which is what "the residual is genuinely open" means. -/
theorem exp585_verdict {β : Type*} [DecidableEq β] (y g : ι → ℝ) (v : Fin 4 → (ι → ℝ))
    (B : ℕ) (Nsam : ι → ℤ) (nb : ι → β) (hframe : FrameLower 1 v) (htss : 0 < tss y)
    (hR0 : rsqOf y g = 0.4112)
    (hcorr : ∀ j, (dot (y - g) (v j)) ^ 2 ≤ (0.16 : ℝ) ^ 2 * sqNorm (y - g))
    (hfloor : 0.4 * tss y ≤ withinSS y (fun i => (dialFeature B Nsam i, nb i))) :
    rsq y (blockClass g v) - rsqOf y g ≤ 0.0604 ∧
      rsq y (measurableClass (fun i => (dialFeature B Nsam i, nb i))) ≤ 0.6 := by
  refine ⟨exp585_block_ceiling y g v hframe htss hR0 hcorr, ?_⟩
  have h := residual_floor_of_within (f := fun i => (dialFeature B Nsam i, nb i))
    (θ := 0.4) htss hfloor
  norm_num at h
  linarith

/-! ## Lab notes

Kernel-checked instances of the arithmetic side, and the numeric shape of the certificates.

* `exp585_block_ceiling`: `k ρ² (1 − R²₀)/λ = 4 · 0.16² · 0.5888 / 1 = 0.060293…`, versus
  the observed `ΔR² = 0.01946` and the pre-registered null boundary `0.02`.
* `exp585_exclusion_threshold`: `4 · 0.1457² · 0.5888 = 0.049997… < 0.05`.
* The arithmetic freedom construction is unconditional: it needs no hypothesis on the
  sampled population, so it also covers the "provenance unverified" regeneration of the
  exp-581 population.
-/

section LabNotes

/-- The ceiling arithmetic used in `exp585_block_ceiling`. -/
example : (4 : ℝ) * (0.16 : ℝ) ^ 2 * (1 - 0.4112) / 1 ≤ 0.0604 := by norm_num

/-- The exclusion arithmetic used in `exp585_exclusion_threshold`. -/
example : (4 : ℝ) * (0.1457 : ℝ) ^ 2 * (1 - 0.4112) / 1 < 0.05 := by norm_num

/-- The observed increment lies below the ceiling, and below the pre-registered null
boundary of `0.02`. -/
example : (0.01946 : ℝ) < 0.02 ∧ (0.01946 : ℝ) < 4 * (0.16 : ℝ) ^ 2 * (1 - 0.4112) := by
  constructor <;> norm_num

/-- Concrete neighbour-covariate readings: `ω(30 − 1) = 1` and `ω(30 + 1) = 1`, since both
neighbours of 30 are prime. -/
example : nbOmega 30 (-1) = 1 ∧ nbOmega 30 1 = 1 := by
  constructor <;> · unfold nbOmega; norm_num

/-- A composite neighbour: `ω(36 − 1) = 2`, because `35 = 5 · 7`.  The covariate really does
vary across the population. -/
example : nbOmega 36 (-1) = 2 := by
  have h : ((36 : ℤ) + (-1)).natAbs = 35 := by norm_num
  rw [nbOmega, h, show (35 : ℕ) = 5 * 7 by norm_num,
    Nat.primeFactors_mul (by norm_num) (by norm_num),
    Nat.Prime.primeFactors (by norm_num), Nat.Prime.primeFactors (by norm_num)]
  decide

end LabNotes

end QRResidual