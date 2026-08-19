/-
# The `π`-adic depth of a DFT minor

Chebotarev's theorem says the integral DFT minor `det (ζ^{a_i b_j})` is nonzero.  This file
proves a complementary *upper* bound on how large it can be `π`-adically, where `π = ζ - 1`
is the ramified prime of `ℤ[ζ_p]`:

  `π ^ (0 + 1 + ⋯ + (n-1))  ∣  det (ζ ^ (a_i b_j))`.

The proof is a Taylor expansion of each row at `ζ^{a_i} = 1 + u_i` (`u_i ≡ 0 mod π`) combined
with the alternating property of the determinant: expanding the rows multilinearly, a term
survives only when the chosen Taylor orders `k_1, …, k_n` are pairwise distinct, and then the
term carries `u_1^{k_1} ⋯ u_n^{k_n}`, of `π`-order `∑ k_i ≥ 0 + 1 + ⋯ + (n-1)`.

Together with `ParityGap.det_zetaPow_ne_zero` this pins the `π`-adic order of a DFT minor into
the window `[n(n-1)/2, ∞)`, and it explains why Chebotarev's theorem cannot be proved by
reducing the determinant modulo `p`: as soon as `n(n-1)/2 ≥ p - 1`, the whole minor is divisible
by `p`.

Main results: `ParityGap.pi_pow_dvd_det_zetaPow`, `ParityGap.pi_pow_dvd_det_zpow`.
-/

import Mathlib
import Catalog.Probability.ParityGap.Chebotarev

open Finset Matrix

namespace ParityGap

/-- A finset of `k` natural numbers has sum at least `0 + 1 + ⋯ + (k-1)`. -/
theorem sum_range_card_le_sum (s : Finset ℕ) : ∑ i ∈ range s.card, i ≤ ∑ x ∈ s, x := by
  classical
  set e : ℕ ↪ ℤ := ⟨fun x => (x : ℤ), fun x y h => by simpa using h⟩ with he
  set t : Finset ℤ := s.map e with ht
  have hcard : t.card = s.card := by rw [ht, Finset.card_map]
  have h := Finset.sum_range_le_sum (s := t) (c := 0) (by
    intro x hx
    rw [ht, Finset.mem_map] at hx
    obtain ⟨y, -, rfl⟩ := hx
    simp [he])
  rw [hcard] at h
  have hsum : ∑ x ∈ t, x = ((∑ x ∈ s, x : ℕ) : ℤ) := by
    rw [ht, Finset.sum_map]
    simp [he]
  rw [hsum] at h
  simp only [zero_add] at h
  have hfin : ((∑ i ∈ range s.card, i : ℕ) : ℤ) ≤ ((∑ x ∈ s, x : ℕ) : ℤ) := by
    calc ((∑ i ∈ range s.card, i : ℕ) : ℤ) = ∑ i ∈ range s.card, (i : ℤ) := by push_cast; ring
      _ ≤ _ := h
  exact_mod_cast hfin

/-- **Multilinear Taylor bound for determinants.**  If every row of a matrix is a combination
`∑_k u_i^k • w_k` of fixed vectors `w_k` with coefficients that are powers of elements `u_i`
divisible by `t`, then the determinant is divisible by `t ^ (0 + 1 + ⋯ + (n-1))`. -/
theorem pow_dvd_det_of_rows_taylor {R : Type*} [CommRing R] (t : R) {n N : ℕ}
    (u : Fin n → R) (hu : ∀ i, t ∣ u i) (w : Fin N → (Fin n → R)) :
    t ^ (∑ i ∈ range n, i) ∣
      Matrix.detRowAlternating (fun i => ∑ k : Fin N, (u i) ^ (k : ℕ) • w k) := by
  classical
  have hexp : (Matrix.detRowAlternating : (Fin n → R) [⋀^Fin n]→ₗ[R] R)
        (fun i => ∑ k : Fin N, (u i) ^ (k : ℕ) • w k)
      = ∑ K : Fin n → Fin N,
          (Matrix.detRowAlternating : (Fin n → R) [⋀^Fin n]→ₗ[R] R)
            (fun i => (u i) ^ ((K i : ℕ)) • w (K i)) :=
    MultilinearMap.map_sum _ _
  rw [hexp]
  refine Finset.dvd_sum ?_
  intro K _
  have hval : (Matrix.detRowAlternating : (Fin n → R) [⋀^Fin n]→ₗ[R] R)
      (fun i => (u i) ^ ((K i : ℕ)) • w (K i))
      = (∏ i, (u i) ^ ((K i : ℕ))) • (Matrix.detRowAlternating : (Fin n → R) [⋀^Fin n]→ₗ[R] R)
          (fun i => w (K i)) :=
    MultilinearMap.map_smul_univ _ _ _
  rw [hval, smul_eq_mul]
  by_cases hinj : Function.Injective K
  · refine Dvd.dvd.mul_right ?_ _
    have h2 : (∏ i, t ^ ((K i : ℕ))) ∣ ∏ i, (u i) ^ ((K i : ℕ)) :=
      Finset.prod_dvd_prod_of_dvd _ _ (fun i _ => pow_dvd_pow_of_dvd (hu i) _)
    have h3 : (∏ i : Fin n, t ^ ((K i : ℕ))) = t ^ (∑ i, (K i : ℕ)) :=
      Finset.prod_pow_eq_pow_sum _ _ _
    have h4 : (∑ i ∈ range n, i) ≤ ∑ i, (K i : ℕ) := by
      have hinj' : Function.Injective (fun i : Fin n => (K i : ℕ)) :=
        fun x y hxy => hinj (Fin.ext hxy)
      have himg : (Finset.univ.image (fun i : Fin n => (K i : ℕ))).card = n := by
        rw [Finset.card_image_of_injective _ hinj']; simp
      have hs := sum_range_card_le_sum (Finset.univ.image (fun i : Fin n => (K i : ℕ)))
      rw [himg, Finset.sum_image (fun x _ y _ hxy => hinj' hxy)] at hs
      exact hs
    exact dvd_trans (pow_dvd_pow t h4) (h3 ▸ h2)
  · obtain ⟨i, j, hij, hne⟩ : ∃ i j, K i = K j ∧ i ≠ j := by
      rw [Function.not_injective_iff] at hinj
      obtain ⟨i, j, h1, h2⟩ := hinj
      exact ⟨i, j, h1, h2⟩
    have hzero : (Matrix.detRowAlternating : (Fin n → R) [⋀^Fin n]→ₗ[R] R)
        (fun i => w (K i)) = 0 :=
      AlternatingMap.map_eq_zero_of_eq _ _ (by rw [hij]) hne
    rw [hzero, mul_zero]
    exact dvd_zero _

variable {p : ℕ} [hp : Fact p.Prime] {n : ℕ}

omit hp in
/-- **The `π`-adic depth of an integral DFT minor.** -/
theorem pi_pow_dvd_det_zetaPow (a b : Fin n → ℕ) (hb : ∀ j, b j < p) :
    pi p ^ (∑ i ∈ range n, i) ∣ (Matrix.of fun i j : Fin n => zeta p ^ (a i * b j)).det := by
  classical
  set u : Fin n → CycRing p := fun i => zeta p ^ (a i) - 1 with hu
  have hudvd : ∀ i, pi p ∣ u i := by
    intro i
    have h := sub_dvd_pow_sub_pow (zeta p) 1 (a i)
    simpa [pi, hu] using h
  set w : Fin p → (Fin n → CycRing p) := fun k j => (((b j).choose (k : ℕ) : ℕ) : CycRing p)
    with hw
  have hrow : (fun i j : Fin n => zeta p ^ (a i * b j))
      = fun i => ∑ k : Fin p, (u i) ^ (k : ℕ) • w k := by
    funext i j
    have hexp : (u i + 1) ^ (b j) = ∑ k ∈ range (b j + 1),
        (u i) ^ k * (((b j).choose k : ℕ) : CycRing p) := by
      rw [add_pow]
      refine Finset.sum_congr rfl fun k _ => ?_
      rw [one_pow, mul_one]
    have hu1 : u i + 1 = zeta p ^ (a i) := by rw [hu]; ring
    have hext : ∑ k ∈ range (b j + 1), (u i) ^ k * (((b j).choose k : ℕ) : CycRing p)
        = ∑ k ∈ range p, (u i) ^ k * (((b j).choose k : ℕ) : CycRing p) := by
      have hsub : range (b j + 1) ⊆ range p := by
        intro x hx
        simp only [Finset.mem_range] at hx ⊢
        have := hb j
        omega
      refine Finset.sum_subset hsub ?_
      intro k hkp hk
      simp only [Finset.mem_range, not_lt] at hkp hk
      have hz : (b j).choose k = 0 := Nat.choose_eq_zero_of_lt (by omega)
      rw [hz]
      simp
    have hfin : ∑ k ∈ range p, (u i) ^ k * (((b j).choose k : ℕ) : CycRing p)
        = ∑ k : Fin p, (u i) ^ (k : ℕ) • w k j := by
      have hterm : ∀ k : Fin p, (u i) ^ (k : ℕ) • w k j
          = (u i) ^ (k : ℕ) * (((b j).choose (k : ℕ) : ℕ) : CycRing p) := by
        intro k
        simp [hw, smul_eq_mul]
      symm
      rw [Finset.sum_congr rfl (fun k _ => hterm k),
        Fin.sum_univ_eq_sum_range (fun k => (u i) ^ k * (((b j).choose k : ℕ) : CycRing p)) p]
    calc zeta p ^ (a i * b j) = (zeta p ^ (a i)) ^ (b j) := by rw [pow_mul]
      _ = (u i + 1) ^ (b j) := by rw [hu1]
      _ = ∑ k ∈ range (b j + 1), (u i) ^ k * (((b j).choose k : ℕ) : CycRing p) := hexp
      _ = ∑ k ∈ range p, (u i) ^ k * (((b j).choose k : ℕ) : CycRing p) := hext
      _ = ∑ k : Fin p, (u i) ^ (k : ℕ) • w k j := hfin
      _ = (∑ k : Fin p, (u i) ^ (k : ℕ) • w k) j := by simp
  have hdet : (Matrix.of fun i j : Fin n => zeta p ^ (a i * b j)).det
      = Matrix.detRowAlternating (fun i => ∑ k : Fin p, (u i) ^ (k : ℕ) • w k) := by
    rw [← hrow]
    rfl
  rw [hdet]
  exact pow_dvd_det_of_rows_taylor (pi p) u hudvd w

/-- The same bound for the minor written in terms of the character `zpow`. -/
theorem pi_pow_dvd_det_zpow (S T : Fin n → ZMod p) :
    pi p ^ (∑ i ∈ range n, i) ∣ (Matrix.of fun j k : Fin n => zpow p (S j * T k)).det := by
  have hcong : (Matrix.of fun j k : Fin n => zpow p (S j * T k))
      = Matrix.of fun j k : Fin n => zeta p ^ ((S j).val * (T k).val) := by
    funext j k
    exact zpow_mul_eq (S j) (T k)
  rw [hcong]
  exact pi_pow_dvd_det_zetaPow (fun j => (S j).val) (fun k => (T k).val)
    (fun k => ZMod.val_lt (T k))


/-! ## Exactness of the depth bound in the base case `n = 2` -/

/-- Divisibility by `π` is detected by the reduction `red : ℤ[ζ_p] → 𝔽_p`. -/
theorem red_eq_zero_of_pi_dvd {y : CycRing p} (h : pi p ∣ y) : red p y = 0 := by
  obtain ⟨z, rfl⟩ := h
  rw [map_mul, red_pi, zero_mul]

/-- `ζ^d - 1` has `π`-adic order exactly one for `0 < d < p`. -/
theorem pi_sq_not_dvd_zeta_pow_sub_one {d : ℕ} (hd : 0 < d) (hdp : d < p) :
    ¬ (pi p ^ 2 ∣ zeta p ^ d - 1) := by
  have hfac : zeta p ^ d - 1 = pi p * ∑ i ∈ range d, zeta p ^ i := by
    rw [pi, mul_comm]
    exact (geom_sum_mul (zeta p) d).symm
  intro hdvd
  rw [hfac, sq] at hdvd
  obtain ⟨z, hz⟩ := hdvd
  have hcancel : ∑ i ∈ range d, zeta p ^ i = pi p * z :=
    mul_left_cancel₀ (pi_ne_zero p) (by rw [hz]; ring)
  have hred : red p (∑ i ∈ range d, zeta p ^ i) = (d : ZMod p) := by
    simp [map_sum]
  rw [hcancel, red_eq_zero_of_pi_dvd ⟨z, rfl⟩] at hred
  have hne : ((d : ZMod p)) ≠ 0 := by
    rw [Ne, ZMod.natCast_eq_zero_iff]
    intro hdvd'
    have := Nat.le_of_dvd hd hdvd'
    omega
  exact hne hred.symm

/-- **The depth bound is exact for `n = 2`.**  For injective `S, T : Fin 2 → ZMod p` the
`2 × 2` minor has `π`-adic order exactly `1 = 2·1/2`, confirming the expected value
`n(n-1)/2` in the base case. -/
theorem pi_sq_not_dvd_det_two (S T : Fin 2 → ZMod p) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    ¬ (pi p ^ 2 ∣ (Matrix.of fun j k : Fin 2 => zpow p (S j * T k)).det) := by
  set B : ZMod p := S 0 * T 1 + S 1 * T 0 with hB
  set D : ZMod p := (S 0 - S 1) * (T 0 - T 1) with hD
  have hDne : D ≠ 0 := by
    have h0 : S 0 - S 1 ≠ 0 := sub_ne_zero.mpr (fun h => by simpa using hS h)
    have h1 : T 0 - T 1 ≠ 0 := sub_ne_zero.mpr (fun h => by simpa using hT h)
    exact mul_ne_zero h0 h1
  have hdet : (Matrix.of fun j k : Fin 2 => zpow p (S j * T k)).det
      = zpow p B * (zpow p D - 1) := by
    rw [Matrix.det_fin_two]
    have hsum : S 0 * T 0 + S 1 * T 1 = B + D := by rw [hB, hD]; ring
    simp only [Matrix.of_apply]
    have h1 : zpow p (S 0 * T 0) * zpow p (S 1 * T 1) = zpow p (B + D) := by
      rw [← zpow_add, hsum]
    have h2 : zpow p (S 0 * T 1) * zpow p (S 1 * T 0) = zpow p B := by
      rw [← zpow_add, hB]
    rw [h1, h2, zpow_add]
    ring
  intro hdvd
  rw [hdet] at hdvd
  -- `zpow p B` is a unit, so the divisibility passes to the second factor
  have hunit : IsUnit (zpow p B) := by
    refine IsUnit.of_mul_eq_one (zeta p ^ (p - B.val)) ?_
    rw [zpow, ← pow_add, Nat.add_sub_cancel' (le_of_lt (ZMod.val_lt B)), zeta_pow_p]
  have hdvd2 : pi p ^ 2 ∣ zpow p D - 1 := (IsUnit.dvd_mul_left hunit).mp hdvd
  have hDval : 0 < D.val := by
    rcases Nat.eq_zero_or_pos D.val with h | h
    · exact absurd ((ZMod.val_eq_zero D).mp h) hDne
    · exact h
  rw [zpow] at hdvd2
  exact pi_sq_not_dvd_zeta_pow_sub_one hDval (ZMod.val_lt D) hdvd2

/-- **Exact `π`-adic order of a `2 × 2` DFT minor.**  The lower bound of
`ParityGap.pi_pow_dvd_det_zpow` is attained: the order is exactly `n(n-1)/2 = 1`. -/
theorem pi_depth_det_two (S T : Fin 2 → ZMod p) (hS : Function.Injective S)
    (hT : Function.Injective T) :
    pi p ∣ (Matrix.of fun j k : Fin 2 => zpow p (S j * T k)).det ∧
      ¬ (pi p ^ 2 ∣ (Matrix.of fun j k : Fin 2 => zpow p (S j * T k)).det) := by
  refine ⟨?_, pi_sq_not_dvd_det_two S T hS hT⟩
  have h := pi_pow_dvd_det_zpow (p := p) S T (n := 2)
  have hsum : ∑ i ∈ range 2, i = 1 := by decide
  rwa [hsum, pow_one] at h

end ParityGap