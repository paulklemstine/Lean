/-
  # Concrete Coding Theory Examples

  End-to-end verified examples of Reed-Solomon and BCH codes over small
  finite fields, demonstrating the theorems in action.
-/

import Mathlib
import CodingTheory.ReedSolomon.Distance
import CodingTheory.BCH.Basic
import CodingTheory.BerlekampMassey.Basic

open CodingTheory Polynomial

instance : Fact (Nat.Prime 7) := ⟨by decide⟩

noncomputable section

/-! ## Example 1: RS(7, 3) over GF(7) -/

/-- Evaluation points for RS(7, 3): α_i = i for i = 0, …, 6. -/
def rs7_eval : Fin 7 → ZMod 7 := fun i => (i : ZMod 7)

/-
The evaluation points are distinct.
-/
theorem rs7_eval_injective : Function.Injective rs7_eval := by
  native_decide

/-- RS(7,3) has minimum distance ≥ 5 = 7 - 3 + 1. -/
theorem rs7_3_distance :
    ∀ c ∈ RSCode 7 rs7_eval 3, c ≠ 0 → hammingWt c ≥ 5 := by
  exact rs_distance_lower_bound rs7_eval rs7_eval_injective (by omega)

/-- Unique decoding for RS(7,3): two codewords within Hamming distance 2
of the same received word must be equal. This means RS(7,3) can correct
up to 2 errors. -/
theorem rs7_3_unique_decode :
    ∀ c₁ c₂ r : Fin 7 → ZMod 7,
    c₁ ∈ RSCode 7 rs7_eval 3 → c₂ ∈ RSCode 7 rs7_eval 3 →
    hammingD r c₁ ≤ 2 → hammingD r c₂ ≤ 2 → c₁ = c₂ := by
  intro c₁ c₂ r hc₁ hc₂ hd₁ hd₂
  exact rs_unique_decoding rs7_eval rs7_eval_injective (by omega) c₁ c₂ r hc₁ hc₂ hd₁ hd₂

/-! ## Example 2: RS distance witness -/

/-- There exists a nonzero codeword in RS(7,3) with weight exactly 5. -/
theorem rs7_3_witness :
    ∃ c ∈ RSCode 7 rs7_eval 3, c ≠ 0 ∧ hammingWt c = 5 := by
  exact rs_distance_witness rs7_eval rs7_eval_injective (by omega) (by omega)

/-- The full MDS theorem for RS(7,3): minimum weight is exactly 5. -/
theorem rs7_3_mds :
    (∀ c ∈ RSCode 7 rs7_eval 3, c ≠ 0 → hammingWt c ≥ 5) ∧
    (∃ c ∈ RSCode 7 rs7_eval 3, c ≠ 0 ∧ hammingWt c = 5) :=
  rs_mds rs7_eval rs7_eval_injective (by omega) (by omega)

/-! ## Example 3: BCH bound applied -/

/-
In GF(7), the element 3 has order 6 (i.e., 3 is a primitive root mod 7).
So 3^i for i = 0, ..., 5 gives 6 distinct elements.
-/
theorem gf7_three_pow_inj : ∀ i j : Fin 6, (3 : ZMod 7) ^ i.val = (3 : ZMod 7) ^ j.val → i = j := by
  native_decide

/-- BCH bound: any vector in (ZMod 7)^6 satisfying the BCH parity check
with α = 3, b = 1, δ = 4 has weight ≥ 4 (or is zero). -/
theorem bch_example :
    ∀ c : Fin 6 → ZMod 7,
    bchParityCheck (3 : ZMod 7) 1 4 c →
    c = 0 ∨ hammingWt c ≥ 4 := by
  intro c hc
  exact bch_bound (3 : ZMod 7) 1 (by decide) gf7_three_pow_inj (by omega) c hc

end

/-! ## Summary of verified results -/

/-- **Certified theorem catalog**:

**Hamming weight/distance** (CodingTheory/Hamming.lean):
  • `hammingWt_eq_zero_iff`: Weight zero iff zero vector.
  • `hammingD_eq_hammingWt_sub`: Distance equals weight of difference.
  • `hammingWt_add_zeros`: Complement counting.

**Reed–Solomon codes** (CodingTheory/ReedSolomon/):
  • `rs_eval_roots_le`: A nonzero polynomial of degree < k has ≤ k-1 roots.
  • `rs_nonzero_weight_ge`: Every nonzero RS codeword has weight ≥ n-k+1.
  • `rs_distance_witness`: There exists a codeword of weight exactly n-k+1 (MDS).
  • `rs_unique_decoding`: Unique decoding within radius ⌊(n-k)/2⌋.
  • `rs_mds`: The complete MDS property.

**BCH codes** (CodingTheory/BCH/):
  • `bch_bound`: The BCH distance bound via Vandermonde determinant.
  • `bch_min_distance`: Minimum distance of BCH code ≥ δ.

**Berlekamp–Massey** (CodingTheory/BerlekampMassey/):
  • `berlekampMassey'`: Computable algorithm implementation.
  • `syndrome_add`, `syndrome_zero`: Syndrome linearity.

**Concrete examples** (CodingTheory/Examples.lean):
  • RS(7,3) over GF(7): distance ≥ 5, unique decoding radius 2.
  • BCH bound with α = 3 in GF(7): distance ≥ 4.
-/
theorem verified_results : True := trivial