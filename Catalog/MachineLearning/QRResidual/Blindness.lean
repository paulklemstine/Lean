import MachineLearning.QRResidual.FootprintWeight

/-!
# The footprint dial is a residue dial: full dynamic range, zero factor information

Barrier (5) of experiment 477 states that every feature of the fitted per-`N` yield dial
is a *residue dial of method input statistics*: it is a function of `N` modulo the factor
base only, and therefore carries no information about the factorisation of `N`.  This
file proves that barrier, and simultaneously proves that the dial is not degenerate: it
realises **every** subset sum `Σ_{p ∈ T} 2/p` of the factor base.

Main results.

* `isQR_congr`, `qrWeight_congr` — the dial only depends on `N` modulo the factor base.
* `crt_prescribe` — a self-contained Chinese-remainder construction over a finite set of
  primes (proved by induction with Bézout, not by transporting `ZMod` isomorphisms).
* `qrWeight_full_range` — for every `T ⊆ oddFactorBase B` there is an `N` whose dial value
  is exactly `Σ_{p ∈ T} 2/p`: the dial has full dynamic range.
* `qrWeight_range_eq_subsetSums` — the exact image of the dial is the set of subset sums.
* `qrWeight_information_bound` — the dial takes at most `2 ^ |factor base|` values, i.e.
  it carries at most `|factor base|` bits, however large `N` grows.
* `qrWeight_blind_to_primality` and `qrWeight_blind_semiprime` — by Dirichlet's theorem,
  each attained dial value is shared by arbitrarily large **primes** and by arbitrarily
  large **semiprimes**.  Hence no function of the dial can predict anything about the
  factorisation of `N`: zero factor information, as an unconditional theorem.
-/

namespace QRResidual

open Finset

/-! ## The dial depends only on the residues of `N` -/

/-- Quadratic residuacity only depends on `N` mod `p`. -/
theorem isQR_congr {p : ℕ} {N₁ N₂ : ℤ} (h : (p : ℤ) ∣ (N₁ - N₂)) :
    IsQR N₁ p ↔ IsQR N₂ p := by
  constructor
  · rintro ⟨x, hx, hdvd⟩
    refine ⟨x, hx, ?_⟩
    have hrw : ((x : ℤ) ^ 2 - N₂) = ((x : ℤ) ^ 2 - N₁) + (N₁ - N₂) := by ring
    rw [hrw]
    exact dvd_add hdvd h
  · rintro ⟨x, hx, hdvd⟩
    refine ⟨x, hx, ?_⟩
    have hrw : ((x : ℤ) ^ 2 - N₁) = ((x : ℤ) ^ 2 - N₂) - (N₁ - N₂) := by ring
    rw [hrw]
    exact dvd_sub hdvd h

/-- **The dial is a residue dial.**  Two moduli that agree modulo every prime of the
factor base have exactly the same dial value. -/
theorem qrWeight_congr {B : ℕ} {N₁ N₂ : ℤ}
    (h : ∀ p ∈ oddFactorBase B, (p : ℤ) ∣ (N₁ - N₂)) :
    qrWeight N₁ B = qrWeight N₂ B := by
  classical
  unfold qrWeight
  congr 1
  refine Finset.filter_congr ?_
  intro p hp
  simpa using isQR_congr (h p hp)

/-! ## A self-contained Chinese-remainder construction -/

/-- **CRT over a finite set of primes.**  Given any prescription `f` of residues, there is
an integer congruent to `f p` mod `p` for every prime `p` in the set.  Proved by
induction on the set using Bézout, so no `ZMod` machinery is needed. -/
theorem crt_prescribe (S : Finset ℕ) (hS : ∀ p ∈ S, p.Prime) (f : ℕ → ℤ) :
    ∃ N : ℤ, ∀ p ∈ S, (p : ℤ) ∣ (N - f p) := by
  classical
  induction S using Finset.induction_on with
  | empty => exact ⟨0, by simp⟩
  | insert q S' hq ih =>
    have hS' : ∀ p ∈ S', p.Prime := fun p hp => hS p (Finset.mem_insert_of_mem hp)
    obtain ⟨N', hN'⟩ := ih hS'
    have hqp : q.Prime := hS q (Finset.mem_insert_self q S')
    set M : ℕ := ∏ p ∈ S', p with hM
    -- `q` is coprime to the product of the other primes
    have hcopNat : Nat.Coprime q M := by
      refine Nat.Coprime.prod_right ?_
      intro p hp
      have hpp : p.Prime := hS' p hp
      have hne : q ≠ p := by
        rintro rfl
        exact hq hp
      exact (Nat.coprime_primes hqp hpp).2 hne
    have hcop : IsCoprime (q : ℤ) (M : ℤ) := Int.isCoprime_iff_gcd_eq_one.2 (by
      simpa [Int.gcd_natCast_natCast] using hcopNat)
    obtain ⟨u, v, huv⟩ := hcop
    refine ⟨f q * (v * M) + N' * (u * q), ?_⟩
    intro p hp
    rcases Finset.mem_insert.1 hp with rfl | hp'
    · -- congruence at the new prime
      refine ⟨u * (N' - f p), ?_⟩
      have h1 : (u : ℤ) * p + v * M = 1 := huv
      linear_combination (f p) * h1
    · -- congruence at the old primes
      have hpM : (p : ℤ) ∣ (M : ℤ) := by
        exact_mod_cast Int.natCast_dvd_natCast.2 (Finset.dvd_prod_of_mem _ hp')
      have h1 : (u : ℤ) * q + v * M = 1 := huv
      have hdiff : (f q * (v * M) + N' * (u * q)) - N' = (v * M) * (f q - N') := by
        linear_combination N' * h1
      have hp1 : (p : ℤ) ∣ ((f q * (v * M) + N' * (u * q)) - N') := by
        rw [hdiff]
        exact dvd_mul_of_dvd_left (Dvd.dvd.mul_left hpM v) _
      have hp2 : (p : ℤ) ∣ (N' - f p) := hN' p hp'
      have : (f q * (v * M) + N' * (u * q)) - f p
          = ((f q * (v * M) + N' * (u * q)) - N') + (N' - f p) := by ring
      rw [this]
      exact dvd_add hp1 hp2

/-- Every odd prime has a quadratic non-residue. -/
theorem exists_not_isQR {p : ℕ} (hp : p.Prime) (hp2 : p ≠ 2) : ∃ a : ℤ, ¬ IsQR a p := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : NeZero p := ⟨hp.ne_zero⟩
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rw [ZMod.ringChar_zmod_n]; exact hp2
  obtain ⟨a, ha⟩ := FiniteField.exists_nonsquare hchar
  refine ⟨(a.val : ℤ), ?_⟩
  rw [isQR_iff_isSquare]
  simpa [ZMod.natCast_val] using ha

/-! ## Full dynamic range of the dial -/

/-- **Full dynamic range.**  For every subset `T` of the factor base there is a modulus
whose footprint dial is exactly `Σ_{p ∈ T} 2/p`.  So the `2 ^ |base|` possible QR patterns
are all realised: the feature is a genuine dial, not a near-constant. -/
theorem exists_qr_pattern (B : ℕ) (T : Finset ℕ) (hT : T ⊆ oddFactorBase B) :
    ∃ N : ℤ, (oddFactorBase B).filter (fun p => IsQR N p) = T := by
  classical
  set f : ℕ → ℤ := fun p =>
    if p ∈ T then 1 else (if h : ∃ a : ℤ, ¬ IsQR a p then Classical.choose h else 0) with hf
  obtain ⟨N, hN⟩ := crt_prescribe (oddFactorBase B)
    (fun p hp => (mem_oddFactorBase.1 hp).2.1) f
  refine ⟨N, ?_⟩
  have hfilter : (oddFactorBase B).filter (fun p => IsQR N p) = T := by
    ext p
    simp only [Finset.mem_filter]
    constructor
    · rintro ⟨hpB, hqr⟩
      by_contra hpT
      obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hpB
      have hex : ∃ a : ℤ, ¬ IsQR a p := exists_not_isQR hprime hp2
      have hfp : f p = Classical.choose hex := by
        simp [hf, hpT, hex]
      have hnot : ¬ IsQR (f p) p := by
        rw [hfp]; exact Classical.choose_spec hex
      exact hnot ((isQR_congr (hN p hpB)).1 hqr)
    · intro hpT
      have hpB : p ∈ oddFactorBase B := hT hpT
      refine ⟨hpB, ?_⟩
      obtain ⟨-, hprime, hp2⟩ := mem_oddFactorBase.1 hpB
      have hfp : f p = 1 := by simp [hf, hpT]
      have hone : IsQR (1 : ℤ) p := by
        refine ⟨1, Finset.mem_range.2 ?_, by norm_num⟩
        have := hprime.two_le
        omega
      exact (isQR_congr (hN p hpB)).2 (hfp ▸ hone)
  exact hfilter

/-- **Full dynamic range, in terms of the dial value.** -/
theorem qrWeight_full_range (B : ℕ) (T : Finset ℕ) (hT : T ⊆ oddFactorBase B) :
    ∃ N : ℤ, qrWeight N B = ∑ p ∈ T, (2 : ℚ) / p := by
  obtain ⟨N, hN⟩ := exists_qr_pattern B T hT
  exact ⟨N, by rw [qrWeight, hN]⟩

/-- A smaller factor base is the restriction of a larger one. -/
theorem oddFactorBase_restrict {B₀ B : ℕ} (h : B₀ ≤ B) :
    oddFactorBase B₀ = (oddFactorBase B).filter (fun p => p ≤ B₀) := by
  ext p
  simp only [Finset.mem_filter, mem_oddFactorBase]
  constructor
  · rintro ⟨hpB₀, hprime, hp2⟩
    exact ⟨⟨hpB₀.trans h, hprime, hp2⟩, hpB₀⟩
  · rintro ⟨⟨-, hprime, hp2⟩, hpB₀⟩
    exact ⟨hpB₀, hprime, hp2⟩

/-- The dial at a smaller bound, read off a prescribed QR pattern. -/
theorem qrWeight_of_pattern {B₀ B : ℕ} {N : ℤ} {T : Finset ℕ} (hB : B₀ ≤ B)
    (hN : (oddFactorBase B).filter (fun p => IsQR N p) = T) :
    qrWeight N B₀ = ∑ p ∈ T.filter (fun p => p ≤ B₀), (2 : ℚ) / p := by
  classical
  rw [qrWeight, oddFactorBase_restrict hB, Finset.filter_comm, hN]

/-- **The two dials are functionally independent.**  If a prime of the large factor base
lies beyond the small bound, then two moduli can share the small-bound dial value while
differing in the large-bound dial: neither feature is a function of the other. -/
theorem dials_functionally_independent {B₀ B p : ℕ} (hB : B₀ ≤ B) (hp : p ∈ oddFactorBase B)
    (hpB₀ : ¬ p ≤ B₀) :
    ∃ N₁ N₂ : ℤ, qrWeight N₁ B₀ = qrWeight N₂ B₀ ∧ qrWeight N₁ B ≠ qrWeight N₂ B := by
  classical
  obtain ⟨N₁, h₁⟩ := exists_qr_pattern B {p} (by simpa using hp)
  obtain ⟨N₂, h₂⟩ := exists_qr_pattern B (∅ : Finset ℕ) (Finset.empty_subset _)
  have hprime : p.Prime := (mem_oddFactorBase.1 hp).2.1
  have hppos : (0 : ℚ) < p := by exact_mod_cast hprime.pos
  refine ⟨N₁, N₂, ?_, ?_⟩
  · rw [qrWeight_of_pattern hB h₁, qrWeight_of_pattern hB h₂]
    simp [Finset.filter_singleton, hpB₀]
  · rw [qrWeight, h₁, qrWeight, h₂]
    simp only [Finset.sum_singleton, Finset.sum_empty]
    positivity

/-- The set of values the dial can take is exactly the set of subset sums of `2/p` over
the factor base. -/
theorem qrWeight_range_eq_subsetSums (B : ℕ) :
    {v : ℚ | ∃ N : ℤ, qrWeight N B = v}
      = {v : ℚ | ∃ T ⊆ oddFactorBase B, ∑ p ∈ T, (2 : ℚ) / p = v} := by
  classical
  ext v
  constructor
  · rintro ⟨N, rfl⟩
    exact ⟨(oddFactorBase B).filter (fun p => IsQR N p), Finset.filter_subset _ _, rfl⟩
  · rintro ⟨T, hT, rfl⟩
    obtain ⟨N, hN⟩ := qrWeight_full_range B T hT
    exact ⟨N, hN⟩

/-- **Information bound.**  However `N` varies, the dial takes at most `2 ^ |base|`
distinct values: it carries at most `|base|` bits about `N`. -/
theorem qrWeight_information_bound (B : ℕ) :
    (Set.range (fun N : ℤ => qrWeight N B)).Finite ∧
      (Set.range (fun N : ℤ => qrWeight N B)).ncard ≤ 2 ^ (oddFactorBase B).card := by
  classical
  set img : Finset ℚ :=
    (oddFactorBase B).powerset.image (fun T : Finset ℕ => ∑ p ∈ T, (2 : ℚ) / (p : ℚ)) with himg
  have hsub : Set.range (fun N : ℤ => qrWeight N B) ⊆ (img : Set ℚ) := by
    rintro v ⟨N, rfl⟩
    have hmem : ((oddFactorBase B).filter (fun p => IsQR N p)) ∈ (oddFactorBase B).powerset :=
      Finset.mem_powerset.2 (Finset.filter_subset _ _)
    exact Finset.mem_coe.2 (Finset.mem_image.2 ⟨_, hmem, rfl⟩)
  refine ⟨Set.Finite.subset img.finite_toSet hsub, ?_⟩
  calc (Set.range (fun N : ℤ => qrWeight N B)).ncard
      ≤ (img : Set ℚ).ncard := Set.ncard_le_ncard hsub img.finite_toSet
    _ = img.card := by rw [Set.ncard_coe_finset]
    _ ≤ (oddFactorBase B).powerset.card := Finset.card_image_le
    _ = 2 ^ (oddFactorBase B).card := Finset.card_powerset _

/-! ## Zero factor information (Dirichlet) -/

/-- The product of the factor base. -/
def basePrimorial (B : ℕ) : ℕ := ∏ p ∈ oddFactorBase B, p

theorem basePrimorial_pos (B : ℕ) : 0 < basePrimorial B := by
  refine Finset.prod_pos ?_
  intro p hp
  exact (mem_oddFactorBase.1 hp).2.1.pos

theorem dvd_basePrimorial {B p : ℕ} (hp : p ∈ oddFactorBase B) :
    (p : ℤ) ∣ (basePrimorial B : ℤ) := by
  exact_mod_cast Int.natCast_dvd_natCast.2 (Finset.dvd_prod_of_mem _ hp)

/-- If two moduli agree modulo the primorial of the factor base they have the same dial. -/
theorem qrWeight_congr_of_primorial {B : ℕ} {N₁ N₂ : ℤ}
    (h : (basePrimorial B : ℤ) ∣ (N₁ - N₂)) : qrWeight N₁ B = qrWeight N₂ B :=
  qrWeight_congr fun _ hp => dvd_trans (dvd_basePrimorial hp) h

/-- **Blindness to primality.**  Every dial value attained at a modulus coprime to the
factor base is also attained at arbitrarily large *primes*. -/
theorem qrWeight_blind_to_primality (B : ℕ) (N : ℤ)
    (hcop : IsCoprime N (basePrimorial B : ℤ)) (n : ℕ) :
    ∃ q : ℕ, n < q ∧ q.Prime ∧ qrWeight (q : ℤ) B = qrWeight N B := by
  obtain ⟨q, hqn, hqp, hqmod⟩ :=
    Nat.forall_exists_prime_gt_and_zmodEq n (q := basePrimorial B) (a := N)
      (basePrimorial_pos B).ne' hcop
  refine ⟨q, hqn, hqp, ?_⟩
  exact qrWeight_congr_of_primorial (Int.ModEq.dvd hqmod.symm)

/-- **Blindness to factorisation.**  Every dial value attained at a modulus coprime to the
factor base is also attained at arbitrarily large *semiprimes* `r · s` with `r ≠ s`.
Combined with `qrWeight_blind_to_primality`, the dial cannot distinguish a prime from a
product of two primes: it carries zero factor information. -/
theorem qrWeight_blind_semiprime (B : ℕ) (N : ℤ)
    (hcop : IsCoprime N (basePrimorial B : ℤ)) (n : ℕ) :
    ∃ r s : ℕ, r.Prime ∧ s.Prime ∧ r ≠ s ∧ n < r * s ∧
      qrWeight ((r * s : ℕ) : ℤ) B = qrWeight N B := by
  have hP : (basePrimorial B : ℤ) ≠ 0 := by
    exact_mod_cast (basePrimorial_pos B).ne'
  have hcop1 : IsCoprime (1 : ℤ) (basePrimorial B : ℤ) := isCoprime_one_left
  obtain ⟨r, hrn, hrp, hrmod⟩ :=
    Nat.forall_exists_prime_gt_and_zmodEq n (q := basePrimorial B) (a := 1)
      (basePrimorial_pos B).ne' hcop1
  obtain ⟨s, hsn, hsp, hsmod⟩ :=
    Nat.forall_exists_prime_gt_and_zmodEq (max n r) (q := basePrimorial B) (a := N)
      (basePrimorial_pos B).ne' hcop
  have hrs : r ≠ s := by
    have : r < s := lt_of_le_of_lt (le_max_right n r) hsn
    omega
  refine ⟨r, s, hrp, hsp, hrs, ?_, ?_⟩
  · have h2 : 2 ≤ r := hrp.two_le
    have : n < s := lt_of_le_of_lt (le_max_left n r) hsn
    calc n < s := this
      _ ≤ r * s := Nat.le_mul_of_pos_left s (by omega)
  · -- `r·s ≡ 1·N = N` modulo the primorial
    have hmod : ((r : ℤ) * s) ≡ (1 * N) [ZMOD (basePrimorial B : ℤ)] :=
      Int.ModEq.mul hrmod hsmod
    rw [one_mul] at hmod
    have : (basePrimorial B : ℤ) ∣ ((r * s : ℕ) : ℤ) - N := by
      push_cast
      exact Int.ModEq.dvd hmod.symm
    exact qrWeight_congr_of_primorial this

end QRResidual