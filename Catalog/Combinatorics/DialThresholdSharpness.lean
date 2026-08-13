/-
# DIAL-THRESHOLD, cycle II: the amplification budget is *exact*

Companion to `Combinatorics.DialThresholdNoAmplification`.  There the master
bound

  `#{dial readings on a hint class} ≤ M* / gcd(M*, m)`

was proved.  A negative result of that shape is only as strong as its
sharpness: if the true budget were much smaller, the bound would be vacuous
book-keeping; if it were unattainable, the two-regime dichotomy could hide a
third regime.  This file closes that gap.

* `DialThreshold.card_image_resDial_eq` — **sharpness**.  For every conductor `M`
  and every hint modulus `m` there is a dial system with `M* = M` and a candidate
  set inside one hint class on which the dial vector takes *exactly*
  `M / gcd(M, m)` values.  So the master bound is an equality in the worst case:
  the amplification budget is exactly the overshoot index of the dial resolution
  over the hint, no more and no less.
* `DialThreshold.dial_independence` — **CRT independence**.  Two dials of coprime
  conductors `a, b` realize all `a·b` joint readings; resolutions multiply, which
  is what makes `M*` (and not `max_i cond_i`) the right invariant.
* `DialThreshold.chi4_not_hintComputable` — **Regime 2, universal form**.  For
  *every* odd hint modulus `m` (in particular `m = 135` of the experiment), the
  single Kronecker dial `(-4 | ·)` is not computable from the hint `p mod m`.
  The experiment's numeric witness is thus an instance of a theorem, not a
  coincidence of the chosen `N`.
* `DialThreshold.pinning_threshold` — the two barriers in one statement: a dial
  system that pins a candidate set needs both `K ≥ log₃ |Ω|` dials and conductor
  lcm `M* ≥ |Ω| · gcd(M*, m)`.
-/
import Mathlib
import Combinatorics.DialThresholdNoAmplification

namespace DialThreshold

open Finset

/-! ## 1. The resolution dial: a dial of maximal discriminating power -/

/-- The **resolution dial** of conductor `M`: it reads off the whole residue
`p mod M`.  No dial of conductor `M` can distinguish more. -/
def resDial (M : ℕ) (hM : 0 < M) : Dial where
  cond := M
  cond_pos := hM
  chi := fun n => (n % M : ℕ)
  periodic := fun n => by simp [Nat.add_mod_right]

@[simp] theorem resDial_chi (M : ℕ) (hM : 0 < M) (n : ℕ) :
    (resDial M hM).chi n = (n % M : ℕ) := rfl

@[simp] theorem condLcm_resDial (M : ℕ) (hM : 0 < M) : condLcm ![resDial M hM] = M := by
  simp [condLcm, resDial]

/-- Two candidates with the same resolution-dial reading are congruent mod `M`. -/
theorem resDial_inj_mod {M : ℕ} (hM : 0 < M) {x y : ℕ}
    (h : dialVec ![resDial M hM] x = dialVec ![resDial M hM] y) : x % M = y % M := by
  have h0 := congrFun h 0
  simp only [dialVec, Matrix.cons_val_zero, resDial_chi] at h0
  exact_mod_cast h0

/-! ## 2. Sharpness of the master bound -/

/-- `lcm(M, m) / m = M / gcd(M, m)`: the number of residues mod `M` that a hint
class mod `m` can still visit. -/
theorem lcm_div_eq (M m : ℕ) (hm : 0 < m) : Nat.lcm M m / m = M / Nat.gcd M m := by
  rcases Nat.eq_zero_or_pos M with rfl | hM
  · simp
  obtain ⟨g, hgdef⟩ : ∃ g, Nat.gcd M m = g := ⟨_, rfl⟩
  have hg : 0 < g := by rw [← hgdef]; exact Nat.gcd_pos_of_pos_left _ hM
  have hmul : g * Nat.lcm M m = M * m := by rw [← hgdef]; exact Nat.gcd_mul_lcm M m
  obtain ⟨t, ht⟩ : m ∣ Nat.lcm M m := Nat.dvd_lcm_right M m
  have h1 : g * t = M := by
    have h2 : g * (m * t) = M * m := by rw [← ht]; exact hmul
    have hm' : (g * t) * m = M * m := by ring_nf; ring_nf at h2; linarith
    exact Nat.eq_of_mul_eq_mul_right hm hm'
  rw [hgdef, ht, Nat.mul_div_cancel_left _ hm, ← h1, Nat.mul_div_cancel_left _ hg]

/-- **Sharpness of the master bound.**  With the resolution dial of conductor `M`
and the candidate set consisting of *all* residues below `lcm(M, m)` in the hint
class `p ≡ r (mod m)`, the dial vector takes exactly `M / gcd(M, m)` values.
Combined with `card_image_dialVec_le`, the amplification budget
`M*/gcd(M*, m)` is attained: it is the true, not merely an upper, bound. -/
theorem card_image_resDial_eq (M m r : ℕ) (hM : 0 < M) (hm : 0 < m) :
    (((range (Nat.lcm M m)).filter (fun x => x % m = r % m)).image
        (dialVec ![resDial M hM])).card = M / Nat.gcd M m := by
  classical
  set L := Nat.lcm M m with hL
  set Ω := (range L).filter (fun x => x % m = r % m) with hΩ
  have hmL : m ∣ L := Nat.dvd_lcm_right M m
  have hcardΩ : Ω.card = L / m :=
    card_filter_range_mod hm hmL (Nat.mod_lt _ hm)
  have hinj : Set.InjOn (dialVec ![resDial M hM]) Ω := by
    intro x hx y hy hxy
    simp only [hΩ, coe_filter, Set.mem_setOf_eq, mem_range] at hx hy
    have h1 : x ≡ y [MOD M] := resDial_inj_mod hM hxy
    have h2 : x ≡ y [MOD m] := hx.2.trans hy.2.symm
    have h3 : x ≡ y [MOD L] := Nat.mod_lcm h1 h2
    have hxy' : x % L = y % L := h3
    rwa [Nat.mod_eq_of_lt hx.1, Nat.mod_eq_of_lt hy.1] at hxy'
  rw [Finset.card_image_of_injOn hinj, hcardΩ, hL, lcm_div_eq M m hm]

/-- **The budget is exactly right.**  For every conductor `M` and hint modulus
`m` there is a dial system with conductor lcm `M` and a candidate set inside a
single hint class realizing the master bound with equality. -/
theorem master_bound_attained (M m r : ℕ) (hM : 0 < M) (hm : 0 < m) :
    ∃ (Ds : Fin 1 → Dial) (Ω : Finset ℕ),
      condLcm Ds = M ∧ (∀ p ∈ Ω, p % m = r % m) ∧
      (Ω.image (dialVec Ds)).card = condLcm Ds / Nat.gcd (condLcm Ds) m := by
  refine ⟨![resDial M hM], (range (Nat.lcm M m)).filter (fun x => x % m = r % m),
    condLcm_resDial M hM, ?_, ?_⟩
  · intro p hp
    exact (mem_filter.1 hp).2
  · rw [condLcm_resDial]
    exact card_image_resDial_eq M m r hM hm

/-! ## 3. CRT independence: coprime conductors multiply the resolution -/

/-- **Independence of coprime dials.**  Two resolution dials with coprime
conductors `a, b` realize all `a·b` joint readings on `range (a*b)`.  Hence the
resolution of a dial *system* is governed by the conductor lcm, and dials with
coprime conductors genuinely compound. -/
theorem dial_independence {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (hab : Nat.Coprime a b) :
    ((range (a * b)).image (dialVec ![resDial a ha, resDial b hb])).card = a * b := by
  classical
  have hinj : Set.InjOn (dialVec ![resDial a ha, resDial b hb]) (range (a * b)) := by
    intro x hx y hy hxy
    simp only [coe_range, Set.mem_Iio] at hx hy
    have h0 := congrFun hxy 0
    have h1 := congrFun hxy 1
    simp only [dialVec, Matrix.cons_val_zero, Matrix.cons_val_one,
      resDial_chi] at h0 h1
    have hA : x ≡ y [MOD a] := by exact_mod_cast h0
    have hB : x ≡ y [MOD b] := by exact_mod_cast h1
    have hAB : x ≡ y [MOD a * b] := (Nat.modEq_and_modEq_iff_modEq_mul hab).1 ⟨hA, hB⟩
    have hxy' : x % (a * b) = y % (a * b) := hAB
    rwa [Nat.mod_eq_of_lt hx, Nat.mod_eq_of_lt hy] at hxy'
  rw [Finset.card_image_of_injOn hinj, card_range]

/-- The conductor lcm of two coprime-conductor dials is the product: the
resolution multiplies. -/
theorem condLcm_pair (d₁ d₂ : Dial) : condLcm ![d₁, d₂] = Nat.lcm d₁.cond d₂.cond := by
  have h : (univ : Finset (Fin 2)) = {0, 1} := rfl
  rw [condLcm, h, Finset.lcm_insert, Finset.lcm_singleton]
  simp [normalize, lcm_eq_nat_lcm]

theorem condLcm_coprime {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (hab : Nat.Coprime a b) :
    condLcm ![resDial a ha, resDial b hb] = a * b := by
  rw [condLcm_pair]
  simpa [resDial] using Nat.Coprime.lcm_eq_mul hab

/-! ## 4. Regime 2 in universal form: the `(-4 | ·)` dial is never hint-computable
for an odd hint modulus -/

/-- The Kronecker dial `(-4 | ·)` is the quadratic character mod `4` on odd
candidates. -/
theorem jacobiSym_neg_four {n : ℕ} (hn : Odd n) : jacobiSym (-4) n = ZMod.χ₄ n := by
  have hcop : Nat.Coprime 2 n :=
    (Nat.prime_two.coprime_iff_not_dvd).mpr (by simpa [Nat.odd_iff, Nat.two_dvd_ne_zero] using hn)
  have hg : Int.gcd 2 (n : ℤ) = 1 := by
    rw [show ((2 : ℤ)) = ((2 : ℕ) : ℤ) by norm_num, Int.gcd_natCast_natCast]
    exact hcop
  have h2 : jacobiSym 2 n ^ 2 = 1 := jacobiSym.sq_one hg
  have h : ((-4 : ℤ)) = (-1) * (2 * 2) := by norm_num
  rw [h, jacobiSym.mul_left, jacobiSym.mul_left, jacobiSym.at_neg_one hn,
    show jacobiSym 2 n * jacobiSym 2 n = jacobiSym 2 n ^ 2 by ring, h2, mul_one]

/-- **The character flip.**  Shifting an odd candidate by twice an odd modulus
flips the quadratic character mod `4`.  This is the arithmetic heart of Regime 2:
an odd hint modulus can never see the `4`-adic digit of `p`. -/
theorem chi4_flip {r m : ℕ} (hr : Odd r) (hm : Odd m) :
    ZMod.χ₄ (r : ℕ) ≠ ZMod.χ₄ ((r + 2 * m : ℕ)) := by
  have hr2 : r % 2 = 1 := Nat.odd_iff.1 hr
  have hm2 : m % 2 = 1 := Nat.odd_iff.1 hm
  rw [ZMod.χ₄_nat_eq_if_mod_four, ZMod.χ₄_nat_eq_if_mod_four]
  have hcase : r % 4 = 1 ∨ r % 4 = 3 := by omega
  rcases hcase with h | h
  · have h1 : (r + 2 * m) % 4 = 3 := by omega
    have h2 : (r + 2 * m) % 2 = 1 := by omega
    simp [h, h1, h2, hr2]
  · have h1 : (r + 2 * m) % 4 = 1 := by omega
    have h2 : (r + 2 * m) % 2 = 1 := by omega
    simp [h, h1, h2, hr2]

/-- The single-dial system carrying the Kronecker symbol `(-4 | ·)`. -/
def chi4Dials : Fin 1 → Dial := ![kron (-4) (by norm_num)]

/-- **Regime 2, universal form.**  For every odd hint modulus `m`, the Kronecker
dial `(-4 | ·)` separates two candidates of the hint class `p ≡ 1 (mod m)`,
namely `1` and `1 + 2m`. -/
theorem chi4_separates {m : ℕ} (hm : Odd m) :
    (1 : ℕ) % m = (1 + 2 * m) % m ∧ dialVec chi4Dials 1 ≠ dialVec chi4Dials (1 + 2 * m) := by
  refine ⟨by simp, ?_⟩
  intro h
  have h0 := congrFun h 0
  have hodd1 : Odd (1 : ℕ) := ⟨0, by norm_num⟩
  have hoddb : Odd (1 + 2 * m) := ⟨m, by ring⟩
  rw [show dialVec chi4Dials 1 0 = jacobiSym (-4) 1 from kron_apply_odd (by norm_num) hodd1,
      show dialVec chi4Dials (1 + 2 * m) 0 = jacobiSym (-4) (1 + 2 * m) from
        kron_apply_odd (by norm_num) hoddb] at h0
  rw [jacobiSym_neg_four hodd1, jacobiSym_neg_four hoddb] at h0
  exact chi4_flip hodd1 hm h0

/-- **The hint cannot evaluate the dial.**  For every odd hint modulus `m`, the
Kronecker dial `(-4 | ·)` is not a function of `p mod m`: the experiment's
`m = 135` non-computability is a special case. -/
theorem chi4_not_hintComputable {m : ℕ} (hm : Odd m) :
    ¬ HintComputable m (dialVec chi4Dials) :=
  not_hintComputable_of_separates chi4Dials (chi4_separates hm).1 (chi4_separates hm).2

/-- Consequently the conductor lcm of the `(-4 | ·)` dial never divides an odd
hint modulus — the pinning dial must reach beyond the hint (barrier 6). -/
theorem chi4_conductor_beyond_hint {m : ℕ} (hm : Odd m) : ¬ condLcm chi4Dials ∣ m :=
  pinning_forces_not_dvd chi4Dials (chi4_separates hm).1 (chi4_separates hm).2

/-- The experiment's Regime-2 modulus `m = 135` is an instance. -/
theorem chi4_not_hintComputable_135 : ¬ HintComputable 135 (dialVec chi4Dials) :=
  chi4_not_hintComputable (by decide)

/-! ## 5. Sharpened capacity: `2^K`, not `3^K`, for nonvanishing dials -/

/-- **Sharpened capacity barrier.**  On candidates where the dials never vanish
(for Kronecker dials: candidates coprime to all the discriminants, which is the
generic case for a prime `p`), `K` dials cannot separate more than `2^K`
candidates. -/
theorem dial_capacity_pm_one {K : ℕ} (Ds : Fin K → Dial) (Ω : Finset ℕ)
    (hsign : ∀ (i : Fin K), ∀ p ∈ Ω, (Ds i).chi p ∈ ({-1, 1} : Finset ℤ))
    (hcard : 2 ^ K < Ω.card) :
    ∃ p ∈ Ω, ∃ q ∈ Ω, p ≠ q ∧ dialVec Ds p = dialVec Ds q := by
  classical
  set B : Finset (Fin K → ℤ) := Fintype.piFinset (fun _ => ({-1, 1} : Finset ℤ)) with hB
  have hBcard : B.card = 2 ^ K := by
    rw [hB, Fintype.card_piFinset]
    simp
  have hmaps : Set.MapsTo (dialVec Ds) ↑Ω ↑B := by
    intro p hp
    simp only [hB, Finset.mem_coe, Fintype.mem_piFinset]
    exact fun i => hsign i p hp
  exact Finset.exists_ne_map_eq_of_card_lt_of_maps_to (by rw [hBcard]; exact hcard) hmaps

/-- A Kronecker dial is `±1` at every odd candidate coprime to the
discriminant. -/
theorem kron_pm_one {D : ℤ} (hD : D ≠ 0) {n : ℕ} (hn : Odd n) (hcop : Int.gcd D (n : ℤ) = 1) :
    (kron D hD).chi n ∈ ({-1, 1} : Finset ℤ) := by
  rw [kron_apply_odd hD hn]
  rcases jacobiSym.eq_one_or_neg_one hcop with h | h <;> simp [h]

/-! ## 6. The two barriers in one statement -/

/-- **Pinning threshold.**  If a system of `K` sign dials pins down every
candidate of a hint class, then `|Ω| ≤ 3^K` (information barrier: `K = Ω(log|Ω|)`
dials are needed) *and* `|Ω| ≤ M*/gcd(M*, m) ≤ M*` (arithmetic barrier: the
conductor lcm must overshoot the hint by the candidate count).  With
`|Ω| ≈ N^{1/4}/log N` candidates in a Coppersmith class, both are violated by
any dial family of bounded conductor. -/
theorem pinning_threshold {K : ℕ} (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ} (hm : 0 < m)
    (hΩ : ∀ p ∈ Ω, p % m = r % m)
    (hsign : ∀ (i : Fin K) (p : ℕ), (Ds i).chi p ∈ ({-1, 0, 1} : Finset ℤ))
    (hinj : Set.InjOn (dialVec Ds) Ω) :
    Ω.card ≤ 3 ^ K ∧ Ω.card ≤ condLcm Ds / Nat.gcd (condLcm Ds) m ∧ Ω.card ≤ condLcm Ds := by
  have hbound : Ω.card ≤ condLcm Ds / Nat.gcd (condLcm Ds) m :=
    card_le_of_dialVec_injOn Ds Ω hm hΩ hinj
  refine ⟨?_, hbound, hbound.trans (Nat.div_le_self _ _)⟩
  by_contra hlt
  push_neg at hlt
  obtain ⟨p, hp, q, hq, hpq, heq⟩ := dial_capacity Ds Ω hsign hlt
  exact hpq (hinj hp hq heq)

end DialThreshold