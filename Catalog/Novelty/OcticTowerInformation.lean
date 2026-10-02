import Novelty.OcticCyclicRung

/-!
# The octic tower: how much each subfield knows about the octic type

`Novelty.OcticCyclicRung` proves full pinning for `Q(ζ₁₇)⁺`.  The field sits at
the top of the tower

`Q ⊂ Q(√17) ⊂ K₄ ⊂ Q(ζ₁₇)⁺`   (degrees `1, 2, 4, 8`),

and the Frobenius of `p` in the degree-`2^j` layer is the class of `u = p mod 17`
modulo the kernel of `u ↦ u^{16/2^j}`; so the layer-`j` observable is simply
`u ^ (16 / 2^j)`: `u⁸` (the Legendre symbol, Euler's criterion), `u⁴` (the
quartic layer) and `u²` (the octic layer, the sign class).

Main results.

* `realDeg_17_eq_octicTypeU` — a decidable closed form of the octic residue
  degree via the `±1`-criterion: `1` iff `u = ±1`, `2` iff `u² = ±1`, `4` iff
  `u⁴ = ±1`, else `8`.
* `octic_splitting_law` — the splitting law in congruence form: for `p ∤ 17`,
  the residue degree of `p` in `Q(ζ₁₇)⁺` is `1` for `p ≡ ±1`, `2` for `p ≡ ±4`,
  `4` for `p ≡ ±2, ±8` and `8` otherwise (mod 17).
* `octic_tower_information` — **the tower filtration**
  `I(T ; Frob₂) = 1`, `I(T ; Frob₄) = 3/2`, `I(T ; Frob₈) = 7/4`: the octic type
  learns exactly `H(T_{2^j}) = 2 - 2^{1-j}` bits from the degree-`2^j` layer —
  the entropy of that layer's own type.
* `legendre_does_not_pin_octic` — the quadratic character is informative but
  strictly not pinning: `H(T | Legendre) = 3/4 > 0`.
-/

namespace OcticCyclic

open Finset CyclicTypeChannel AbelianLadder

/-- Numerical values of `log₂` at the powers of two that occur in the octic tower. -/
theorem logb_two_vals :
    Real.logb 2 (1 : ℝ) = 0 ∧ Real.logb 2 (2 : ℝ) = 1 ∧ Real.logb 2 (4 : ℝ) = 2 ∧
      Real.logb 2 (8 : ℝ) = 3 ∧ Real.logb 2 (16 : ℝ) = 4 :=
  ⟨Real.logb_one, Real.logb_self_eq_one (by norm_num), lb_4, lb_8, lb_16⟩

/-! ## 1. A decidable closed form of the octic residue degree -/

/-- The octic splitting type, computed by the `±1`-criterion. -/
def octicTypeU (u : (ZMod 17)ˣ) : ℕ :=
  if u = 1 ∨ u = -1 then 1 else if u ^ 2 = 1 ∨ u ^ 2 = -1 then 2
  else if u ^ 4 = 1 ∨ u ^ 4 = -1 then 4 else 8

/-- **The octic residue degree in closed form.** -/
theorem realDeg_17_eq_octicTypeU (u : (ZMod 17)ˣ) : realDeg 17 u = octicTypeU u := by
  have hmem := realDeg_17_mem u
  have hd : ∀ d, realDeg 17 u ∣ d ↔ u ^ d = 1 ∨ u ^ d = -1 := fun d => realDeg_dvd_iff
  simp only [mem_insert, mem_singleton] at hmem
  unfold octicTypeU
  split_ifs with h1 h2 h4
  · exact realDeg_eq_one_iff.2 h1
  · have h2' := (hd 2).2 h2
    have h1' : ¬ realDeg 17 u ∣ 1 := fun h => h1 (by simpa using (hd 1).1 h)
    rcases hmem with h | h | h | h <;> simp only [h] at h1' h2' ⊢ <;> omega
  · have h4' := (hd 4).2 h4
    have h2' : ¬ realDeg 17 u ∣ 2 := fun h => h2 ((hd 2).1 h)
    rcases hmem with h | h | h | h <;> simp only [h] at h2' h4' ⊢ <;> omega
  · have h4' : ¬ realDeg 17 u ∣ 4 := fun h => h4 ((hd 4).1 h)
    rcases hmem with h | h | h | h <;> simp only [h] at h4' ⊢ <;> omega

/-- The splitting type as a function of the residue `r = p mod 17`. -/
def octicTypeRes (r : ℕ) : ℕ :=
  if r = 1 ∨ r = 16 then 1 else if r = 4 ∨ r = 13 then 2
  else if r = 2 ∨ r = 8 ∨ r = 9 ∨ r = 15 then 4 else 8

theorem octicTypeU_unitOfCoprime_table :
    ∀ r < 17, ∀ h : Nat.Coprime r 17, octicTypeU (ZMod.unitOfCoprime r h) = octicTypeRes r := by
  decide

/-- **The octic splitting law.**  For a natural number `p` coprime to `17`, the
residue degree of `p` in `Q(ζ₁₇)⁺` is `1` if `p ≡ ±1`, `2` if `p ≡ ±4`, `4` if
`p ≡ ±2, ±8`, and `8` if `p ≡ ±3, ±5, ±6, ±7 (mod 17)`. -/
theorem octic_splitting_law (p : ℕ) (hp : Nat.Coprime p 17) :
    realDeg 17 (ZMod.unitOfCoprime p hp) = octicTypeRes (p % 17) := by
  have hr : Nat.Coprime (p % 17) 17 := by
    rw [Nat.Coprime, ← Nat.gcd_rec, Nat.gcd_comm]; exact hp
  have heq : ZMod.unitOfCoprime p hp = ZMod.unitOfCoprime (p % 17) hr := by
    ext; simp [ZMod.natCast_mod]
  rw [heq, realDeg_17_eq_octicTypeU,
    octicTypeU_unitOfCoprime_table _ (Nat.mod_lt _ (by norm_num)) hr]

/-- Concrete primes: `103 ≡ 1` splits completely, `13 ≡ -4` has degree `2`,
`2` has degree `4`, and `3` (a primitive root) is inert of degree `8`. -/
theorem octic_examples :
    realDeg 17 (ZMod.unitOfCoprime 103 (by norm_num)) = 1 ∧
    realDeg 17 (ZMod.unitOfCoprime 13 (by norm_num)) = 2 ∧
    realDeg 17 (ZMod.unitOfCoprime 2 (by norm_num)) = 4 ∧
    realDeg 17 (ZMod.unitOfCoprime 3 (by norm_num)) = 8 := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> rw [octic_splitting_law] <;> decide

/-! ## 2. The tower filtration -/

/-- The Frobenius of the degree-`2^j` layer, as the observable `u ^ (16 / 2^j)`. -/
def layerObs (e : ℕ) (u : (ZMod 17)ˣ) : ZMod 17 := ((u ^ e : (ZMod 17)ˣ) : ZMod 17)

theorem realDeg_17_funext : realDeg 17 = octicTypeU := funext realDeg_17_eq_octicTypeU

theorem card_univ_units_17 : (univ : Finset (ZMod 17)ˣ).card = 16 := by decide

/-- **The quadratic layer: `H(T | Legendre) = 3/4`.**  On the eight squares the
type is spread as `{1 : 2, 2 : 2, 4 : 4}` (`3/2` bits), on the eight non-squares it
is constantly `8`. -/
theorem condEnt_layer_two :
    condEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 8) = 3 / 4 := by
  obtain ⟨-, -, h4, h8, -⟩ := logb_two_vals
  rw [realDeg_17_funext, condEnt,
    show (univ : Finset (ZMod 17)ˣ).image (layerObs 8) = {1, 16} from by decide,
    sum_pair (by decide), card_univ_units_17,
    uEnt_eq_countSum _ _ {2, 2, 4} (by decide), uEnt_eq_countSum _ _ {8} (by decide),
    show #{x ∈ (univ : Finset (ZMod 17)ˣ) | layerObs 8 x = 1} = 8 from by decide,
    show #{x ∈ (univ : Finset (ZMod 17)ˣ) | layerObs 8 x = 16} = 8 from by decide]
  simp [h4, h8]
  norm_num

/-- **The quartic layer: `H(T | Frob₄) = 1/4`.**  Only the fibre `u⁴ = 1`
(`u ∈ {±1, ±4}`, types `1, 1, 2, 2`) carries residual uncertainty. -/
theorem condEnt_layer_four :
    condEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 4) = 1 / 4 := by
  obtain ⟨-, -, h4, -, -⟩ := logb_two_vals
  rw [realDeg_17_funext, condEnt,
    show (univ : Finset (ZMod 17)ˣ).image (layerObs 4) = {1, 4, 13, 16} from by decide,
    sum_insert (by decide), sum_insert (by decide), sum_pair (by decide), card_univ_units_17,
    uEnt_eq_countSum _ _ {2, 2} (by decide), uEnt_eq_countSum _ _ {4} (by decide),
    uEnt_eq_countSum _ _ {4} (by decide), uEnt_eq_countSum _ _ {4} (by decide),
    show #{x ∈ (univ : Finset (ZMod 17)ˣ) | layerObs 4 x = 1} = 4 from by decide,
    show #{x ∈ (univ : Finset (ZMod 17)ˣ) | layerObs 4 x = 4} = 4 from by decide,
    show #{x ∈ (univ : Finset (ZMod 17)ˣ) | layerObs 4 x = 13} = 4 from by decide,
    show #{x ∈ (univ : Finset (ZMod 17)ˣ) | layerObs 4 x = 16} = 4 from by decide]
  simp [h4]
  norm_num

/-- **The octic layer pins:** `u²` determines `u` up to sign, hence the type. -/
theorem condEnt_layer_eight :
    condEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 2) = 0 := by
  refine condEnt_eq_zero_of_determines fun u _ v _ huv => ?_
  have hsq : (u ^ 2 : (ZMod 17)ˣ) = v ^ 2 := Units.ext huv
  have hv : v = u ∨ v = -u := by
    revert u v; decide
  rcases hv with rfl | rfl
  · rfl
  · exact (realDeg_neg u).symm

/-- **THE OCTIC TOWER FILTRATION.**  The information the degree-`2^j` layer of
`Q ⊂ Q(√17) ⊂ K₄ ⊂ Q(ζ₁₇)⁺` carries about the octic splitting type is exactly
`1, 3/2, 7/4` bits — i.e. `typeEntropy (2^j) = 2 - 2^{1-j}`, the entropy of the
layer's *own* type.  Each layer adds exactly the entropy increment of the
two-power ladder, and the top layer reaches full pinning. -/
theorem octic_tower_information :
    mutInfo (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 8) = typeEntropy 2 ∧
    mutInfo (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 4) = typeEntropy 4 ∧
    mutInfo (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 2) = typeEntropy 8 := by
  have e1 := typeEntropy_two_pow 1
  have e2 := typeEntropy_two_pow 2
  have e3 := typeEntropy_two_pow 3
  norm_num at e1 e2 e3
  refine ⟨?_, ?_, ?_⟩
  · rw [mutInfo, octic_entropy, condEnt_layer_two, e1]; norm_num
  · rw [mutInfo, octic_entropy, condEnt_layer_four, e2]; norm_num
  · rw [mutInfo, octic_entropy, condEnt_layer_eight, e3]; norm_num

/-- **The Legendre symbol is informative but does not pin.**  It carries exactly
one bit about the octic type, strictly less than `H(T) = 7/4`. -/
theorem legendre_does_not_pin_octic :
    0 < condEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 8) ∧
      mutInfo (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 8) = 1 ∧
      mutInfo (univ : Finset (ZMod 17)ˣ) (realDeg 17) (layerObs 8) <
        uEnt (univ : Finset (ZMod 17)ˣ) (realDeg 17) := by
  rw [mutInfo, condEnt_layer_two, octic_entropy]
  norm_num

/-! ## 3. The semiprime channel at the octic rung -/

/-- **The octic semiprime channel, assembled from the catalog.**  In the `C₈`
exponent model the unordered type pair of `N = p q` carries exactly `21/16`
bits about `N mod 17` (`Ipair_val_8`); the ordered pair carries the same amount
(`Ipair_eq_IpairOrd`: the *which-factor* increment is exactly `0`, against the
reported `0.0002`); the channel exceeds the one-bit binary cap; and the reported
`1.3097` is again a slight under-estimate, within `0.003` of the exact value. -/
theorem octic_semiprime_channel :
    Ipair 8 = 21 / 16 ∧ Ipair 8 = IpairOrd 8 ∧ 1 < Ipair 8 ∧
      (1.3097 : ℝ) < Ipair 8 ∧ Ipair 8 - 1.3097 < 0.003 := by
  refine ⟨Ipair_val_8, Ipair_eq_IpairOrd 8, one_lt_Ipair_eight, ?_, ?_⟩ <;>
    rw [Ipair_val_8] <;> norm_num

end OcticCyclic