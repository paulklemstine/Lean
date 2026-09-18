import Mathlib
import Shared.ShorPeakCertificationRamp

/-!
# Where the ramp saturates, and how much of it is informative

*(FACT round-25 #1 — QUBIT-TRADE2, cycle 2; sharpening of
`Shared.ShorPeakCertificationRamp`.)*

Cycle 1 established the ramp `#certPeaks = 2⌊q/(2r)⌋ + 1` below saturation and
refuted the vertical wall.  Three questions were left open, and are answered
here.

1. **Where exactly does the ramp saturate?**  `certPeaks_eq_range_iff` gives an
   iff, and `wall_position_odd` converts it for odd periods: certification
   becomes *universal* exactly at `q = r(r-1)`, strictly below the folklore
   wall `q = r²`.  The wall is therefore not only soft, it is also misplaced.

2. **What does one register bit buy on the arithmetic side?**
   `card_certPeaks_two_mul` — doubling the register size doubles the number of
   certifying peaks, up to one peak:
   `2N(q) - 1 ≤ N(2q) ≤ 2N(q) + 1`.  This is the arithmetic twin of the
   sample-side law `1 - (1-P)^{2s} ≈ 2P`: *one register bit is worth one
   sample doubling* holds on both sides of the trade.

3. **How many certificates are informative?**  A certificate is usable only if
   its numerator is coprime to `r` (else the continued fraction returns a
   proper divisor of `r`).  `card_infoPeaks` computes that count exactly:
   twice the number of totatives of `r` in the initial segment
   `[1, ⌊q/(2r)⌋]`.  The informative ramp is thus the full ramp thinned by the
   local density of totatives — an *analytic-number-theoretic* factor entering
   a quantum resource trade-off.
-/

namespace ShorPeakRamp

open Finset

/-! ## 1. The exact saturation point -/

/-- **Saturation criterion.**  All peaks certify precisely when the two
certifying residue blocks `[0, B]` and `[r-B, r)` cover `[0, r)`, i.e. when
`r ≤ 2⌊q/(2r)⌋ + 1`. -/
theorem certPeaks_eq_range_iff (q r : ℕ) (hr : 0 < r) (hco : Nat.Coprime q r) :
    certPeaks q r = range r ↔ r ≤ 2 * (q / (2 * r)) + 1 := by
  set B := q / (2 * r) with hB
  have hiff : ∀ x : ℕ, 2 * r * x ≤ q ↔ x ≤ B := by
    intro x
    rw [hB, Nat.le_div_iff_mul_le (by omega)]
    constructor <;> intro h' <;> nlinarith
  constructor
  · intro hsat
    by_contra hcon
    push_neg at hcon
    have hlt : 2 * B < r := by omega
    have hcard : (certPeaks q r).card = 2 * B + 1 := card_certPeaks q r hr hco hlt
    rw [hsat, Finset.card_range] at hcard
    omega
  · intro hsat
    apply Finset.filter_true_of_mem
    intro j _
    have hmr : peakRes q r j < r := Nat.mod_lt _ hr
    rcases le_or_gt (peakRes q r j) B with h | h
    · exact Or.inl ((hiff _).mpr h)
    · exact Or.inr ((hiff _).mpr (by omega))

/-- **The wall is at `q = r(r-1)`, and it is a saturation point.**  For an odd
period `r` coprime to the register size, every peak certifies exactly when
`q ≥ r(r-1)` — strictly below the folklore threshold `q = r²`, and a
*saturation* of the ramp rather than the onset of possibility. -/
theorem wall_position_odd (q r : ℕ) (hr : 0 < r) (hodd : Odd r)
    (hco : Nat.Coprime q r) :
    certPeaks q r = range r ↔ r * (r - 1) ≤ q := by
  obtain ⟨k, hk⟩ := hodd
  rw [certPeaks_eq_range_iff q r hr hco]
  have hrk : r - 1 = 2 * k := by omega
  constructor
  · intro h
    have hkB : k ≤ q / (2 * r) := by omega
    have := (Nat.le_div_iff_mul_le (show 0 < 2 * r by omega)).mp hkB
    rw [hrk]
    nlinarith
  · intro h
    have hkB : k ≤ q / (2 * r) := by
      rw [Nat.le_div_iff_mul_le (show 0 < 2 * r by omega)]
      rw [hrk] at h
      nlinarith
    omega

/-! ## 2. One register bit doubles the certifying set -/

/-- **One bit is one doubling, arithmetic side.**  Doubling the register size
doubles the number of certifying peaks up to one peak.  (`r` odd keeps `2q`
coprime to `r`; the hypothesis `h` says the doubled configuration is still
below saturation.) -/
theorem card_certPeaks_two_mul (q r : ℕ) (hr : 0 < r) (hodd : Odd r)
    (hco : Nat.Coprime q r) (h : 2 * (2 * q / (2 * r)) < r) :
    2 * (certPeaks q r).card - 1 ≤ (certPeaks (2 * q) r).card ∧
      (certPeaks (2 * q) r).card ≤ 2 * (certPeaks q r).card + 1 := by
  set B := q / (2 * r) with hB
  set C := 2 * q / (2 * r) with hC
  have hr2 : 0 < 2 * r := by omega
  -- `2B ≤ C`
  have hBq : 2 * r * B ≤ q := by
    have := Nat.div_mul_le_self q (2 * r)
    calc 2 * r * B = B * (2 * r) := by ring
      _ ≤ q := by rw [hB]; exact this
  have h2BC : 2 * B ≤ C := by
    rw [hC, Nat.le_div_iff_mul_le hr2]
    nlinarith
  -- `C ≤ 2B + 1`
  have hCq : 2 * r * C ≤ 2 * q := by
    have := Nat.div_mul_le_self (2 * q) (2 * r)
    calc 2 * r * C = C * (2 * r) := by ring
      _ ≤ 2 * q := by rw [hC]; exact this
  have hqB : q < 2 * r * (B + 1) := by
    have hdm : 2 * r * B + q % (2 * r) = q := by rw [hB]; exact Nat.div_add_mod q (2 * r)
    have hmodlt : q % (2 * r) < 2 * r := Nat.mod_lt _ hr2
    nlinarith
  have hC2B : C ≤ 2 * B + 1 := by nlinarith
  have hBlt : 2 * B < r := by omega
  have hco2 : Nat.Coprime (2 * q) r := by
    have h2 : Nat.Coprime 2 r := Nat.coprime_two_left.mpr hodd
    exact Nat.Coprime.mul_left h2 hco
  have hcard1 : (certPeaks q r).card = 2 * B + 1 := card_certPeaks q r hr hco hBlt
  have hcard2 : (certPeaks (2 * q) r).card = 2 * C + 1 := card_certPeaks (2 * q) r hr hco2 h
  omega

/-! ## 3. The informative sub-ramp -/

/-- The certificates that determine the period exactly: those whose numerator
is coprime to `r`, so that the continued-fraction denominator is `r` itself
rather than a proper divisor. -/
def infoPeaks (q r : ℕ) : Finset ℕ := (certPeaks q r).filter (fun j => Nat.Coprime j r)

/-- The totatives of `r` in the head block `[1, B]`. -/
def headTotatives (r B : ℕ) : Finset ℕ := (Icc 1 B).filter (fun m => Nat.Coprime m r)

/-- The peak-to-residue bijection preserves the gcd with `r`. -/
theorem gcd_peakRes (q r j : ℕ) (hco : Nat.Coprime q r) :
    Nat.gcd (peakRes q r j) r = Nat.gcd j r := by
  have h1 : Nat.gcd r (j * q) = Nat.gcd (j * q % r) r := Nat.gcd_rec r (j * q)
  have h2 : Nat.gcd (j * q) r = Nat.gcd j r := Nat.Coprime.gcd_mul_right_cancel j hco
  rw [peakRes, ← h1, Nat.gcd_comm r (j * q), h2]

/-- Reflection symmetry of the totatives: `gcd (r - m) r = gcd m r`. -/
theorem gcd_reflect (r m : ℕ) (hm : m ≤ r) : Nat.gcd (r - m) r = Nat.gcd m r := by
  have e1 : Nat.gcd (r - m) (r - (r - m)) = Nat.gcd (r - m) r :=
    Nat.gcd_sub_self_right (by omega)
  have e2 : Nat.gcd m (r - m) = Nat.gcd m r := Nat.gcd_sub_self_right hm
  have e3 : r - (r - m) = m := by omega
  rw [e3] at e1
  rw [← e1, Nat.gcd_comm, e2]

/-- **The informative ramp.**  Below saturation the number of *informative*
certificates is exactly twice the number of totatives of `r` in `[1, ⌊q/(2r)⌋]`
— the full ramp thinned by the local density of totatives.  (Both head blocks
contribute equally, by the symmetry `m ↦ r - m` of the certifying residues.)
-/
theorem card_infoPeaks (q r : ℕ) (hr : 2 ≤ r) (hco : Nat.Coprime q r)
    (h : 2 * (q / (2 * r)) < r) :
    (infoPeaks q r).card = 2 * (headTotatives r (q / (2 * r))).card := by
  classical
  set B := q / (2 * r) with hB
  have hr0 : 0 < r := by omega
  have hiff : ∀ x : ℕ, 2 * r * x ≤ q ↔ x ≤ B := by
    intro x
    rw [hB, Nat.le_div_iff_mul_le (by omega)]
    constructor <;> intro h' <;> nlinarith
  -- residue description of the informative set
  set R : Finset ℕ :=
    (range r).filter (fun m => (m ≤ B ∨ r - m ≤ B) ∧ Nat.Coprime m r) with hR
  have hbij : (infoPeaks q r).card = R.card := by
    rcases Nat.lt_or_ge r 2 with hr1 | hr2
    · omega
    obtain ⟨a, -, ha⟩ := Nat.exists_mul_mod_eq_one_of_coprime hco hr2
    have ha' : a * q % r = 1 := by rw [Nat.mul_comm]; exact ha
    refine Finset.card_bij' (fun j _ => j * q % r) (fun m _ => m * a % r) ?_ ?_ ?_ ?_
    · intro j hj
      simp only [infoPeaks, certPeaks, hR, mem_filter, mem_range] at hj ⊢
      obtain ⟨⟨hjr, hcert⟩, hcop⟩ := hj
      refine ⟨Nat.mod_lt _ hr0, ?_, ?_⟩
      · rcases hcert with hc | hc
        · exact Or.inl ((hiff _).mp hc)
        · exact Or.inr ((hiff _).mp hc)
      · have := gcd_peakRes q r j hco
        unfold Nat.Coprime at hcop ⊢
        rw [peakRes] at this
        omega
    · intro m hm
      simp only [infoPeaks, certPeaks, hR, mem_filter, mem_range] at hm ⊢
      obtain ⟨hmr, hcert, hcop⟩ := hm
      have hkey : peakRes q r (m * a % r) = m := inv_key ha' hmr
      refine ⟨⟨Nat.mod_lt _ hr0, ?_⟩, ?_⟩
      · unfold CertRes
        rw [hkey]
        rcases hcert with hc | hc
        · exact Or.inl ((hiff _).mpr hc)
        · exact Or.inr ((hiff _).mpr hc)
      · have := gcd_peakRes q r (m * a % r) hco
        rw [hkey] at this
        unfold Nat.Coprime at hcop ⊢
        omega
    · intro j hj
      simp only [infoPeaks, certPeaks, mem_filter, mem_range] at hj
      exact inv_key ha hj.1.1
    · intro m hm
      simp only [hR, mem_filter, mem_range] at hm
      exact inv_key ha' hm.1
  -- and the residue set splits into two mirror blocks of totatives
  set A : Finset ℕ := (Icc 1 B).filter (fun m => Nat.Coprime m r) with hA
  set A' : Finset ℕ := (Icc (r - B) (r - 1)).filter (fun m => Nat.Coprime m r) with hA'
  have hsplit : R = A ∪ A' := by
    ext m
    simp only [hR, hA, hA', mem_filter, mem_range, mem_union, mem_Icc]
    constructor
    · rintro ⟨hmr, hcert, hcop⟩
      have hm0 : m ≠ 0 := by
        intro h0
        rw [h0] at hcop
        have hz : Nat.gcd 0 r = r := Nat.gcd_zero_left r
        unfold Nat.Coprime at hcop
        omega
      rcases hcert with hc | hc
      · exact Or.inl ⟨⟨by omega, hc⟩, hcop⟩
      · exact Or.inr ⟨⟨by omega, by omega⟩, hcop⟩
    · rintro (⟨⟨hm1, hmB⟩, hcop⟩ | ⟨⟨hm1, hm2⟩, hcop⟩)
      · exact ⟨by omega, Or.inl hmB, hcop⟩
      · exact ⟨by omega, Or.inr (by omega), hcop⟩
  have hcardA' : A'.card = A.card := by
    refine Finset.card_bij' (fun m _ => r - m) (fun m _ => r - m) ?_ ?_ ?_ ?_
    · intro m hm
      simp only [hA, hA', mem_filter, mem_Icc] at hm ⊢
      refine ⟨⟨by omega, by omega⟩, ?_⟩
      have := gcd_reflect r m (by omega)
      unfold Nat.Coprime at hm ⊢
      omega
    · intro m hm
      simp only [hA, hA', mem_filter, mem_Icc] at hm ⊢
      refine ⟨⟨by omega, by omega⟩, ?_⟩
      have := gcd_reflect r m (by omega)
      unfold Nat.Coprime at hm ⊢
      omega
    · intro m hm
      simp only [hA', mem_filter, mem_Icc] at hm
      show r - (r - m) = m
      omega
    · intro m hm
      simp only [hA, mem_filter, mem_Icc] at hm
      show r - (r - m) = m
      omega
  have hdisj : Disjoint A A' := by
    rw [Finset.disjoint_left]
    intro x hx hx2
    simp only [hA, mem_filter, mem_Icc] at hx
    simp only [hA', mem_filter, mem_Icc] at hx2
    omega
  rw [hbij, hsplit, Finset.card_union_of_disjoint hdisj, hcardA']
  have : headTotatives r B = A := by rw [hA, headTotatives]
  rw [this]
  ring

/-! ## 4. Lab notes: kernel-checked instances of the sharpened laws

Saturation point (`wall_position_odd`, `r(r-1)` versus the folklore `r²`):

| `r`  | `r(r-1)` | `r²` | `q = 256` saturated? | `q = 512` saturated? |
|------|----------|------|----------------------|----------------------|
| 21   |   420    | 441  | no  (13 of 21 peaks) | yes (21 of 21)       |
| 15   |   210    | 225  | yes (15 of 15)       | yes                  |

Informative sub-ramp (`card_infoPeaks`, count `= 2·#totatives ≤ ⌊q/2r⌋`):

| `r`  | `q`  | `B = ⌊q/2r⌋` | `#certPeaks` | `#infoPeaks` | `2·#totatives ≤ B` |
|------|------|--------------|--------------|--------------|--------------------|
| 21   | 256  |      6       |     13       |      8       |   2·|{1,2,4,5}| = 8 |
| 21   | 128  |      3       |      7       |      4       |   2·|{1,2}|    = 4 |
| 15   | 128  |      4       |      9       |      6       |   2·|{1,2,4}|  = 6 |
| 11   |  64  |      2       |      5       |      4       |   2·|{1,2}|    = 4 |

The thinning factor `#infoPeaks / #certPeaks` approaches `φ(r)/r`; at these
small sizes it is above it, because the head block `[1, B]` is biased towards
small — hence often coprime — residues. -/

example : (certPeaks 256 21) ≠ Finset.range 21 := by decide
example : (certPeaks 512 21) = Finset.range 21 := by decide
example : (certPeaks 256 15) = Finset.range 15 := by decide
example : (infoPeaks 256 21).card = 8 := by decide
example : (infoPeaks 128 21).card = 4 := by decide
example : (infoPeaks 128 15).card = 6 := by decide
example : (infoPeaks 64 11).card = 4 := by decide
example : (headTotatives 21 6).card = 4 := by decide
example : (headTotatives 15 4).card = 3 := by decide

end ShorPeakRamp