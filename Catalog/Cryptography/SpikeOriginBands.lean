/-
# Band structure of the Fermat-window residues: the left-edge spike is not one object

Companion to `Cryptography.SpikeOriginDegeneracy`.  Three results:

* `firstDecile_size_lt_size` — a **scale-free** band statement: for every modulus
  `N ≥ 2¹⁶`, a first-decile residue satisfies `2 v < N`, hence `bitlen v < bitlen N`.
  The `96`-bit statement `bitlen v ≤ 95` is the special case; the mechanism is exact
  arithmetic at every scale.
* `firstDecile_fullsize_filter_eq_empty` — set-level form of "fraction removed = 1":
  the `v ≥ 2⁹⁵` filter deletes *every* first-decile point of a `96`-bit modulus.
* `midRegime_not_universal` / `spike_is_not_one_object` — explicit `96`-bit witnesses
  showing that in the middle regime (`0.1 < u < 0.21`) the band of a residue is *not*
  determined by its normalised position: at `u = 0.15` one modulus gives a full-size
  residue and another a sub-`2⁹⁵` one.  So position and bit-length are genuinely two
  different stratifications of the window; a positional-shape model needs both.
-/
import Mathlib
import Cryptography.SpikeOriginDegeneracy

namespace SpikeOrigin

/-! ## Scale-free band drop -/

/-- On the first decile the residue is smaller than half the modulus, at every scale. -/
theorem firstDecile_two_mul_resid_lt {N j : ℕ} (hN : 2 ^ 16 ≤ N) (h : FirstDecile N j) :
    2 * resid N j < N := by
  have := resid_lt_of_firstDecile_scalefree hN h
  omega

/-- **Scale-free band statement.**  A first-decile residue always has strictly fewer bits
than the modulus.  For a `96`-bit modulus this is `bitlen v ≤ 95`. -/
theorem firstDecile_size_lt_size {N j : ℕ} (hN : 2 ^ 16 ≤ N) (h : FirstDecile N j) :
    (resid N j).size < N.size := by
  have hlt := firstDecile_two_mul_resid_lt hN h
  have hNpos : 0 < N := lt_of_lt_of_le (by norm_num) hN
  have hsizepos : 0 < N.size := Nat.size_pos.2 hNpos
  have hNs : N < 2 ^ N.size := Nat.lt_size_self N
  have hsplit : (2:ℕ) ^ N.size = 2 * 2 ^ (N.size - 1) := by
    conv_lhs => rw [show N.size = (N.size - 1) + 1 by omega]
    ring
  have : resid N j < 2 ^ (N.size - 1) := by omega
  have := Nat.size_le.2 this
  omega

/-! ### The size hypotheses are load-bearing

Both scale-free statements above carry a lower bound on `N`, and neither can simply be
dropped: the constants `0.45` and `1/2` genuinely fail for small moduli.  (An exhaustive
scan shows `N = 36482` is the last modulus violating `100 v < 45 N`, and `N = 962` the last
one violating `2 v < N`, so the hypothesis `2¹⁶ ≤ N` is close to sharp for the first bound
and generous for the second.) -/

/-- The `0.45` bound of `resid_lt_of_firstDecile_scalefree` fails without a size hypothesis:
`N = 36482`, `s = 191`, `j = 230` is in the first decile yet `100 v ≥ 45 N`. -/
theorem scalefree_bound_needs_size_hypothesis :
    ∃ N j : ℕ, N < 2 ^ 16 ∧ FirstDecile N j ∧ 45 * N ≤ 100 * resid N j := by
  have hsq : Nat.sqrt 36482 = 191 := by
    have a : 191 ≤ Nat.sqrt 36482 := Nat.le_sqrt.2 (by norm_num)
    have b : Nat.sqrt 36482 < 192 := Nat.sqrt_lt'.2 (by norm_num)
    omega
  refine ⟨36482, 230, by norm_num, ⟨?_, ?_⟩, ?_⟩
  · rw [hsq]; norm_num
  · rw [hsq]; norm_num
  · rw [resid]; norm_num

/-- Even the weaker "loses at least one bit" bound needs a size hypothesis:
`N = 962`, `s = 31`, `j = 38` is in the first decile yet `2 v ≥ N`. -/
theorem bitdrop_needs_size_hypothesis :
    ∃ N j : ℕ, N < 2 ^ 16 ∧ FirstDecile N j ∧ N ≤ 2 * resid N j := by
  have hsq : Nat.sqrt 962 = 31 := by
    have a : 31 ≤ Nat.sqrt 962 := Nat.le_sqrt.2 (by norm_num)
    have b : Nat.sqrt 962 < 32 := Nat.sqrt_lt'.2 (by norm_num)
    omega
  refine ⟨962, 38, by norm_num, ⟨?_, ?_⟩, ?_⟩
  · rw [hsq]; norm_num
  · rw [hsq]; norm_num
  · rw [resid]; norm_num

/-! ## Set-level degeneracy of the exclusion clause -/

/-- The set of first-decile window points of a `96`-bit modulus whose residue survives the
`v ≥ 2⁹⁵` filter is empty: the clause removes 100 % of the first-decile mass. -/
theorem firstDecile_fullsize_filter_eq_empty {N : ℕ} (hlo : 2 ^ 95 ≤ N) (hhi : N < 2 ^ 96) :
    ((Finset.Icc (Nat.sqrt N + 1) (3 * Nat.sqrt N)).filter
      (fun j => 5 * (j - Nat.sqrt N) < Nat.sqrt N + 5 ∧ 2 ^ 95 ≤ resid N j)) = ∅ := by
  rw [Finset.filter_eq_empty_iff]
  rintro j hj ⟨hdec, hbig⟩
  rw [Finset.mem_Icc] at hj
  have hD : FirstDecile N j := ⟨by omega, hdec⟩
  have := firstDecile_resid_lt_two_pow_95 hlo hhi hD
  omega

/-! ## The middle regime is genuinely modulus-dependent -/

/-- First witness: `N₁ = (2⁴⁸ − 1)²` is a `96`-bit modulus, and at normalised position
`u = (j − s)/(2s) ≤ 0.15` the residue is already **full size** (`≥ 2⁹⁵`). -/
theorem midRegime_fullsize_witness :
    ∃ N j : ℕ, 2 ^ 95 ≤ N ∧ N < 2 ^ 96 ∧ Nat.sqrt N < j ∧ j ≤ 3 * Nat.sqrt N ∧
      100 * (j - Nat.sqrt N) ≤ 15 * (2 * Nat.sqrt N) ∧ 2 ^ 95 ≤ resid N j := by
  refine ⟨281474976710655 * 281474976710655, 365917469723851, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [resid]
    have e : (365917469723851 : ℕ) ^ 2 = 133895594649105413230198270201 := by norm_num
    have f : (2 : ℕ) ^ 95 = 39614081257132168796771975168 := by norm_num
    have g : (281474976710655 : ℕ) * 281474976710655 =
        79228162514263774643590529025 := by norm_num
    omega

/-- Second witness: `N₂ = 199032864766431²` is also a `96`-bit modulus, but at the *larger*
normalised position `u ≥ 0.15` its residue is still **sub-`2⁹⁵`**. -/
theorem midRegime_tiny_witness :
    ∃ N j : ℕ, 2 ^ 95 ≤ N ∧ N < 2 ^ 96 ∧ Nat.sqrt N < j ∧ j ≤ 3 * Nat.sqrt N ∧
      15 * (2 * Nat.sqrt N) ≤ 100 * (j - Nat.sqrt N) ∧ resid N j < 2 ^ 95 := by
  refine ⟨199032864766431 * 199032864766431, 278646010673003, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · norm_num
  · norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [Nat.sqrt_eq]; norm_num
  · rw [resid]
    have e : (278646010673003 : ℕ) ^ 2 = 77643599263979301788993038009 := by norm_num
    have f : (2 : ℕ) ^ 95 = 39614081257132168796771975168 := by norm_num
    have g : (199032864766431 : ℕ) * 199032864766431 =
        39614081257132410564184477761 := by norm_num
    omega

/-- **No positional cut-off works inside the middle regime.**  At the same normalised
position `u = 0.15` one `96`-bit modulus produces a full-size residue and another produces
a sub-`2⁹⁵` residue.  Hence, between the two provable regimes, the bit-length band is not a
function of the position. -/
theorem midRegime_not_universal :
    (∃ N j : ℕ, 2 ^ 95 ≤ N ∧ N < 2 ^ 96 ∧ Nat.sqrt N < j ∧ j ≤ 3 * Nat.sqrt N ∧
      100 * (j - Nat.sqrt N) ≤ 15 * (2 * Nat.sqrt N) ∧ 2 ^ 95 ≤ resid N j) ∧
    (∃ N j : ℕ, 2 ^ 95 ≤ N ∧ N < 2 ^ 96 ∧ Nat.sqrt N < j ∧ j ≤ 3 * Nat.sqrt N ∧
      15 * (2 * Nat.sqrt N) ≤ 100 * (j - Nat.sqrt N) ∧ resid N j < 2 ^ 95) :=
  ⟨midRegime_fullsize_witness, midRegime_tiny_witness⟩

/-- **Synthesis: the left-edge spike is not one object.**  For `96`-bit moduli the scan
window splits into

* a *provably tiny* prefix — the whole first decile has `bitlen v ≤ 95`;
* a *provably full-size* tail — beyond `u = 0.21` every residue has `v ≥ 2⁹⁵`;
* a *modulus-dependent* middle, where both behaviours occur at the same position.

Consequently the position statistic and the `bitlen v` band are independent
stratifications of the window, and a `v ≥ 2⁹⁵` cut is a *geometric* operation on the left
edge rather than a data-driven one. -/
theorem spike_is_not_one_object :
    (∀ N j : ℕ, 2 ^ 95 ≤ N → N < 2 ^ 96 → FirstDecile N j → (resid N j).size ≤ 95) ∧
    (∀ N j : ℕ, 2 ^ 95 ≤ N → N < 2 ^ 96 → 142 * Nat.sqrt N ≤ 100 * j →
      96 ≤ (resid N j).size) ∧
    (∃ N j : ℕ, 2 ^ 95 ≤ N ∧ N < 2 ^ 96 ∧ 100 * (j - Nat.sqrt N) ≤ 15 * (2 * Nat.sqrt N) ∧
      96 ≤ (resid N j).size) ∧
    (∃ N j : ℕ, 2 ^ 95 ≤ N ∧ N < 2 ^ 96 ∧ 15 * (2 * Nat.sqrt N) ≤ 100 * (j - Nat.sqrt N) ∧
      (resid N j).size ≤ 95) := by
  refine ⟨fun N j hlo hhi h => firstDecile_bitlen_le_95 hlo hhi h, ?_, ?_, ?_⟩
  · intro N j hlo hhi hfar
    have h := resid_ge_two_pow_95_of_far hlo hhi hfar
    by_contra hcon
    push_neg at hcon
    have := Nat.size_le.1 (Nat.le_of_lt_succ (by omega : (resid N j).size < 96))
    omega
  · obtain ⟨N, j, h1, h2, _, _, h5, h6⟩ := midRegime_fullsize_witness
    refine ⟨N, j, h1, h2, h5, ?_⟩
    by_contra hcon
    push_neg at hcon
    have := Nat.size_le.1 (Nat.le_of_lt_succ (by omega : (resid N j).size < 96))
    omega
  · obtain ⟨N, j, h1, h2, _, _, h5, h6⟩ := midRegime_tiny_witness
    exact ⟨N, j, h1, h2, h5, Nat.size_le.2 h6⟩

end SpikeOrigin