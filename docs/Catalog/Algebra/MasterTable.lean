/-
# FACT round-34 #1 — MASTER-TABLE: every type-channel value in one document (paper 119)

**Verdict: THE-FRAMEWORK-IS-COMPLETE** — in the precise sense that every entry of
the degree-`3…6` master table below is a machine-checked closed form, and every
entry of the cyclic root-count and dihedral columns is an *instance of a general
law valid for all degrees* (no enumeration), which also re-derives the previously
enumerated catalog values independently.

Write `L = log₂ 3`, `L₅ = log₂ 5`.  Source: uniformly random Frobenius.

| degree | `H(T)` cyclic `C_n` | `H(#roots)` cyclic | `I_pair` cyclic | `H(T)` dihedral `D_n` | `H(T ∣ rotSign)` | `I(rotSign;T)` |
|---|---|---|---|---|---|---|
| 3 | `L - 2/3` | `L - 2/3` (lossless) | `L - 10/9` | `2/3 + L/2` | `L/2 - 1/3` | `1` |
| 4 | `3/2` | `2 - 3L/4` (lossy) | `5/4` | `11/4 - 5L₅/8` | `3/2 - 3L/8` | `5/4 + 3L/8 - 5L₅/8` |
| 5 | `L₅ - 8/5` | `L₅ - 8/5` (lossless) | `L₅ + 12L/25 - 72/25` | `1/5 + L₅/2` | `L₅/2 - 4/5` | `1` |
| 6 | `1/3 + L` | `1 + L - 5L₅/6` (lossy) | `L - 1/9` | `3L/4` | `1 + L/2 - 5L₅/12` | `L/4 + 5L₅/12 - 1` |

General laws behind the columns (all in `Algebra.MasterTable.*`):
* cyclic root count: `H = pinEnt n` for all `n` (`rootCountEntropy_eq_pinEnt`), lossless
  **iff `n` is prime** (`rootCount_lossless_iff_prime`);
* dihedral type: `H = 1 + pinEnt(n)/2` for odd `n` (`typeEntropyDn_odd`), closed form
  for even `n` (`typeEntropyDn_even`);
* dihedral dial: `I(rotSign ; T) = 1` exactly for odd `n` (`mutInfo_rotSign_odd`),
  `H(T | rotSign) = pinEnt(n)/2 + 1/2` for even `n` (`condEnt_rotSign_even`);
* parity law: `I(rotSign ; T) = 1 ↔ n odd` for `n ≥ 3` (`mutInfo_rotSign_eq_one_iff`),
  via the chain rule and the symmetry `I(g ; k) = I(k ; g)` (`mutInfo_comm`);
* bridge: the dihedral rotation fibre is the cyclic root-count channel
  (`rotFibre_eq_rootCountEntropy`);
* limit: `pinEnt n → 0`, so the abelian share of the dihedral type information
  tends to `1` along odd degrees (`abelian_saturation_odd`).
-/
import Algebra.MasterTable.Asymptotic
import Algebra.MasterTable.ChainRule
import Shared.CyclicTypeChannelCRT
import Shared.CyclicTypeChannelCap

namespace MasterTable

open CyclicTypeChannel D6TypeChannel DihedralGroup Finset

/-! ## Pinning entropies of the table degrees -/

theorem pinEnt_three : pinEnt 3 = Real.logb 2 3 - 2 / 3 := by
  rw [pinEnt]
  norm_num [lb_two]

theorem pinEnt_four : pinEnt 4 = 2 - 3 / 4 * Real.logb 2 3 := by
  rw [pinEnt]
  norm_num [lb_4]

theorem pinEnt_five : pinEnt 5 = Real.logb 2 5 - 8 / 5 := by
  rw [pinEnt]
  norm_num [lb_4]

theorem pinEnt_six : pinEnt 6 = 1 + Real.logb 2 3 - 5 / 6 * Real.logb 2 5 := by
  rw [pinEnt]
  norm_num [lb_6]

/-- The dihedral dial as `H(T) - H(T | rotSign)`. -/
lemma mutInfo_rotSign_eq {n : ℕ} [NeZero n] :
    mutInfo (univ : Finset (DihedralGroup n)) fixCount rotSign
      = typeEntropyDn n - condEnt (univ : Finset (DihedralGroup n)) fixCount rotSign := rfl

/-! ## The four rows -/

/-- **Degree 3** (`C₃`: cyclic cubic fields; `D₃ = S₃`: `x³ - a`). -/
theorem row_degree_three :
    typeEntropy 3 = Real.logb 2 3 - 2 / 3 ∧
    rootCountEntropy 3 = Real.logb 2 3 - 2 / 3 ∧
    Ipair 3 = Real.logb 2 3 - 10 / 9 ∧
    typeEntropyDn 3 = 2 / 3 + Real.logb 2 3 / 2 ∧
    condEnt (univ : Finset (DihedralGroup 3)) fixCount rotSign = Real.logb 2 3 / 2 - 1 / 3 ∧
    mutInfo (univ : Finset (DihedralGroup 3)) fixCount rotSign = 1 := by
  have hT : typeEntropy 3 = Real.logb 2 3 - 2 / 3 := by rw [typeEntropy_val_3]; ring
  refine ⟨hT, by rw [rootCountEntropy_prime Nat.prime_three, hT],
    by rw [Ipair_val_3]; ring, typeEntropyDn_three, ?_, mutInfo_rotSign_odd (by decide) le_rfl⟩
  rw [condEnt_rotSign_odd (by decide), pinEnt_three]
  ring

/-- **Degree 4** (`C₄`: cyclic quartic fields; `D₄`: `x⁴ - a`). -/
theorem row_degree_four :
    typeEntropy 4 = 3 / 2 ∧
    rootCountEntropy 4 = 2 - 3 / 4 * Real.logb 2 3 ∧
    Ipair 4 = 5 / 4 ∧
    typeEntropyDn 4 = 11 / 4 - 5 / 8 * Real.logb 2 5 ∧
    condEnt (univ : Finset (DihedralGroup 4)) fixCount rotSign = 3 / 2 - 3 / 8 * Real.logb 2 3 ∧
    mutInfo (univ : Finset (DihedralGroup 4)) fixCount rotSign
      = 5 / 4 + 3 / 8 * Real.logb 2 3 - 5 / 8 * Real.logb 2 5 := by
  have hC : condEnt (univ : Finset (DihedralGroup 4)) fixCount rotSign
      = 3 / 2 - 3 / 8 * Real.logb 2 3 := by
    rw [condEnt_rotSign_even (by decide), pinEnt_four]
    ring
  refine ⟨typeEntropy_val_4, by rw [rootCountEntropy_eq_pinEnt (by norm_num), pinEnt_four],
    Ipair_val_4, typeEntropyDn_four, hC, ?_⟩
  rw [mutInfo_rotSign_eq, typeEntropyDn_four, hC]
  ring

/-- **Degree 5** (`C₅`: cyclic quintic fields; `D₅`: dihedral quintics). -/
theorem row_degree_five :
    typeEntropy 5 = Real.logb 2 5 - 8 / 5 ∧
    rootCountEntropy 5 = Real.logb 2 5 - 8 / 5 ∧
    Ipair 5 = Real.logb 2 5 + 12 / 25 * Real.logb 2 3 - 72 / 25 ∧
    typeEntropyDn 5 = 1 / 5 + Real.logb 2 5 / 2 ∧
    condEnt (univ : Finset (DihedralGroup 5)) fixCount rotSign = Real.logb 2 5 / 2 - 4 / 5 ∧
    mutInfo (univ : Finset (DihedralGroup 5)) fixCount rotSign = 1 := by
  have hT : typeEntropy 5 = Real.logb 2 5 - 8 / 5 := by rw [typeEntropy_val_5]; ring
  refine ⟨hT, by rw [rootCountEntropy_prime (by norm_num), hT],
    by rw [Ipair_val_5]; ring, typeEntropyDn_five, ?_,
    mutInfo_rotSign_odd (by decide) (by norm_num)⟩
  rw [condEnt_rotSign_odd (by decide), pinEnt_five]
  ring

/-- **Degree 6** (`C₆`: cyclic sextic fields; `D₆`: `x⁶ - a`, paper 122). -/
theorem row_degree_six :
    typeEntropy 6 = 1 / 3 + Real.logb 2 3 ∧
    rootCountEntropy 6 = 1 + Real.logb 2 3 - 5 / 6 * Real.logb 2 5 ∧
    Ipair 6 = Real.logb 2 3 - 1 / 9 ∧
    typeEntropyDn 6 = 3 / 4 * Real.logb 2 3 ∧
    condEnt (univ : Finset (DihedralGroup 6)) fixCount rotSign
      = 1 + Real.logb 2 3 / 2 - 5 / 12 * Real.logb 2 5 ∧
    mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign
      = Real.logb 2 3 / 4 + 5 / 12 * Real.logb 2 5 - 1 := by
  have hC : condEnt (univ : Finset (DihedralGroup 6)) fixCount rotSign
      = 1 + Real.logb 2 3 / 2 - 5 / 12 * Real.logb 2 5 := by
    rw [condEnt_rotSign_even (by decide), pinEnt_six]
    ring
  refine ⟨by rw [typeEntropy_val_6]; ring,
    by rw [rootCountEntropy_eq_pinEnt (by norm_num), pinEnt_six],
    by rw [Ipair_val_6]; ring, typeEntropyDn_six_val, hC, ?_⟩
  rw [mutInfo_rotSign_eq, typeEntropyDn_six_val, hC]
  ring

/-! ## Independent re-derivation of the enumerated catalog entries -/

/-- The general laws reproduce the catalog's enumerated (`decide`-based) values of
papers 118/122 at degrees `4` and `6`. -/
theorem general_laws_reproduce_catalog :
    rootCountEntropy 4 = uEnt (range 4) (rootCount 4 ∘ ordType 4) ∧
    rootCountEntropy 6 = uEnt (range 6) (rootCount 6 ∘ ordType 6) ∧
    typeEntropyDn 6 = typeEntropyD6 ∧
    (pinEnt 4 = 2 - 3 / 4 * Real.logb 2 3 ∧ uEnt (range 4) (rootCount 4 ∘ ordType 4)
      = 2 - 3 / 4 * Real.logb 2 3) ∧
    (typeEntropyDn 6 = 3 / 4 * Real.logb 2 3 ∧ typeEntropyD6 = 3 / 4 * Real.logb 2 3) :=
  ⟨rfl, rfl, rfl, ⟨pinEnt_four, rootCountEntropy_val_4⟩, ⟨typeEntropyDn_six_val, typeEntropy_D6⟩⟩

/-! ## The verdicts of the table -/

/-- **Root-count verdict**: lossless exactly at the prime degrees `3, 5` of the
table; strictly lossy at `4, 6`. -/
theorem verdict_rootCount :
    rootCountEntropy 3 = typeEntropy 3 ∧ rootCountEntropy 5 = typeEntropy 5 ∧
    rootCountEntropy 4 < typeEntropy 4 ∧ rootCountEntropy 6 < typeEntropy 6 :=
  ⟨rootCountEntropy_prime Nat.prime_three, rootCountEntropy_prime (by norm_num),
    rootCountEntropy_lt_typeEntropy (by norm_num) (by decide),
    rootCountEntropy_lt_typeEntropy (by norm_num) (by decide)⟩

/-- **Binary-cap verdict**: the semiprime pair channel stays below one bit at the
odd degrees `3, 5` and exceeds it at the even degrees `4, 6`. -/
theorem verdict_binary_cap :
    Ipair 3 < 1 ∧ Ipair 5 < 1 ∧ 1 < Ipair 4 ∧ 1 < Ipair 6 :=
  ⟨Ipair_three_lt_one, Ipair_five_lt_one, one_lt_Ipair_four, one_lt_Ipair_six⟩

/-- **Abelian-dial verdict**: the rotation character carries exactly one bit about
the dihedral type at odd degrees, and strictly less than one bit at degrees `4, 6`,
while leaving a strictly positive non-abelian residue at every table degree. -/
theorem verdict_abelian_dial :
    mutInfo (univ : Finset (DihedralGroup 3)) fixCount rotSign = 1 ∧
    mutInfo (univ : Finset (DihedralGroup 5)) fixCount rotSign = 1 ∧
    mutInfo (univ : Finset (DihedralGroup 4)) fixCount rotSign < 1 ∧
    mutInfo (univ : Finset (DihedralGroup 6)) fixCount rotSign < 1 ∧
    0 < condEnt (univ : Finset (DihedralGroup 3)) fixCount rotSign ∧
    0 < condEnt (univ : Finset (DihedralGroup 4)) fixCount rotSign ∧
    0 < condEnt (univ : Finset (DihedralGroup 5)) fixCount rotSign ∧
    0 < condEnt (univ : Finset (DihedralGroup 6)) fixCount rotSign := by
  obtain ⟨-, -, -, -, h3c, h3i⟩ := row_degree_three
  obtain ⟨-, -, -, -, h4c, h4i⟩ := row_degree_four
  obtain ⟨-, -, -, -, h5c, h5i⟩ := row_degree_five
  obtain ⟨-, -, -, -, h6c, h6i⟩ := row_degree_six
  have a := lb_three_gt
  have b := lb_three_lt
  have c := lb_five_gt
  have d := lb_five_lt
  refine ⟨h3i, h5i, ?_, ?_, ?_, ?_, ?_, ?_⟩
  · rw [h4i]; linarith
  · rw [h6i]; linarith
  · rw [h3c]; linarith
  · rw [h4c]; linarith
  · rw [h5c]; linarith
  · rw [h6c]; linarith

/-- **Dihedral dominates cyclic root count**: at every table degree the dihedral
type channel carries strictly more information than the cyclic root-count
channel of the same degree. -/
theorem verdict_dihedral_above_rootCount :
    rootCountEntropy 3 < typeEntropyDn 3 ∧ rootCountEntropy 4 < typeEntropyDn 4 ∧
    rootCountEntropy 5 < typeEntropyDn 5 ∧ rootCountEntropy 6 < typeEntropyDn 6 := by
  obtain ⟨-, r3, -, d3, -, -⟩ := row_degree_three
  obtain ⟨-, r4, -, d4, -, -⟩ := row_degree_four
  obtain ⟨-, r5, -, d5, -, -⟩ := row_degree_five
  obtain ⟨-, r6, -, d6, -, -⟩ := row_degree_six
  have a := lb_three_gt
  have b := lb_three_lt
  have c := lb_five_gt
  have d := lb_five_lt
  rw [r3, d3, r4, d4, r5, d5, r6, d6]
  refine ⟨?_, ?_, ?_, ?_⟩ <;> linarith

end MasterTable