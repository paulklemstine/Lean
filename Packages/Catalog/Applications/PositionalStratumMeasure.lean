/-
# Positional-stratum measure framework (GAP-L4)

A self-contained finite-measure framework for *positional strata* in one-shot
search / retrieval cost models.

The setting is elementary but the statements are the ones that carry the load:

* `positions M` — the ranked slots `1, …, M`;
* a *weight* `w : ℕ → ℝ`, the probability of the target sitting at a given slot;
* a *cost kernel* `c : ℕ → ℝ`, the number of probes charged when the target is resolved
  at that slot.  Two kernels matter: the **scan kernel** `c i = i` (sequential probing)
  and the **block-commitment kernel** (constant on each stratum), which is the one behind
  the certified law of `PositionalStratumCertifiedLaw`.

Main results.

* `rbar_identity` : the universal object,  `EC = P · r̄_R + (1 - P) · r̄_C`, an *exact*
  identity for every weight, every cost kernel and every stratum of nondegenerate mass.
* `theta_eq_one_of_uniform` / `uniform_of_forall_theta_eq_one` : the booking factor
  `Θ = r̄_R / (cell centre)` equals `1` on uniform cells, and if it equals `1` on
  *every* cell then the weight is uniform.  The single-cell converse is **false**:
  `theta_eq_one_not_uniform` is an explicit non-uniform witness with `Θ = 1`.
* `scan_cost_le_baseline` : the majorization / Chebyshev step — a descending (antitone)
  weight has expected scan cost at most the full-scan baseline `C₀ = (M+1)/2`.
* `exchange_inequality`, `sorted_le_of_antitone` : the rearrangement step.
* `exists_large_bucket`, `speedup_le_two_pow_kbits` : the `k_bits` (pigeonhole) branch.
* `master_inequality`, `master_inequality_of_filter` :
  `S ≤ min (1/(Λ·Θ·q̂)) (2^k/(Λ·Θ))`.
* `value_universality_fails` : the booked (uniform-cell) value law is **not** universal —
  off uniform cells the true speedup exceeds the booked one by an *unbounded* factor.
-/
import Mathlib

namespace PositionalStratum

open Finset

noncomputable section

/-! ## The finite positional space -/

/-- The ranked slots `1, …, M`. -/
def positions (M : ℕ) : Finset ℕ := Finset.Icc 1 M

/-- Total mass of a weight on a stratum. -/
def mass (R : Finset ℕ) (w : ℕ → ℝ) : ℝ := ∑ i ∈ R, w i

/-- Expected cost of the algorithm: cost kernel `c` averaged against the weight `w`. -/
def EC (M : ℕ) (c w : ℕ → ℝ) : ℝ := ∑ i ∈ positions M, c i * w i

/-- Conditional mean cost inside a stratum, `r̄_R`. -/
def rbar (R : Finset ℕ) (c w : ℕ → ℝ) : ℝ := (∑ i ∈ R, c i * w i) / mass R w

/-- The (unweighted) centre of a stratum for the cost kernel `c`. -/
def cellCentre (R : Finset ℕ) (c : ℕ → ℝ) : ℝ := (∑ i ∈ R, c i) / R.card

/-- The booking factor `Θ = r̄_R / centre(R)`: it measures how far the weight is from
uniform *inside* the stratum. -/
def Theta (R : Finset ℕ) (c w : ℕ → ℝ) : ℝ := rbar R c w / cellCentre R c

/-- The scan cost kernel: resolving at slot `i` costs `i` probes. -/
def scanCost (i : ℕ) : ℝ := (i : ℝ)

/-- The full-scan baseline cost `C₀ = (M+1)/2` (mean position under the uniform weight). -/
def baselineC0 (M : ℕ) : ℝ := ((M : ℝ) + 1) / 2

lemma mem_positions {M i : ℕ} : i ∈ positions M ↔ 1 ≤ i ∧ i ≤ M := by
  simp [positions]

lemma card_positions (M : ℕ) : (positions M).card = M := by
  simp [positions]

/-- Gauss sum over the positional space. -/
lemma sum_positions (M : ℕ) : ∑ i ∈ positions M, (i : ℝ) = (M : ℝ) * ((M : ℝ) + 1) / 2 := by
  induction M with
  | zero => simp [positions]
  | succ n ih =>
      have h : positions (n + 1) = insert (n + 1) (positions n) := by
        ext i
        simp only [mem_positions, Finset.mem_insert]
        omega
      rw [h, Finset.sum_insert (by simp [mem_positions]), ih]
      push_cast
      ring

/-! ## The r̄-identity : the universal object -/

/-- The complementary mass is `1 - P`. -/
lemma mass_compl {M : ℕ} {w : ℕ → ℝ} {R : Finset ℕ} (hR : R ⊆ positions M)
    (htot : mass (positions M) w = 1) :
    mass (positions M \ R) w = 1 - mass R w := by
  have h := Finset.sum_sdiff (f := w) hR
  simp only [mass] at *
  linarith [h, htot]

/-- **r̄-identity.**  For any stratum `R` of the positional space, any cost kernel and any
normalised weight with nondegenerate strata, the expected cost splits *exactly* as
`EC = P · r̄_R + (1 - P) · r̄_C`.  No uniformity and no shape assumption is used. -/
theorem rbar_identity {M : ℕ} {c w : ℕ → ℝ} {R : Finset ℕ} (hR : R ⊆ positions M)
    (htot : mass (positions M) w = 1)
    (hP : mass R w ≠ 0) (hQ : mass (positions M \ R) w ≠ 0) :
    EC M c w = mass R w * rbar R c w + (1 - mass R w) * rbar (positions M \ R) c w := by
  have hsplit : (∑ i ∈ positions M \ R, c i * w i) + ∑ i ∈ R, c i * w i
      = ∑ i ∈ positions M, c i * w i := Finset.sum_sdiff hR
  have hmass : mass (positions M \ R) w = 1 - mass R w := mass_compl hR htot
  rw [rbar, rbar, mul_div_cancel₀ _ hP, ← hmass, mul_div_cancel₀ _ hQ, EC]
  linarith [hsplit]

/-! ## The booking factor `Θ` : uniformity detection -/

/-- On a stratum where the weight is constant, the conditional mean cost is exactly the
cell centre: `Θ = 1`. -/
theorem theta_eq_one_of_uniform {R : Finset ℕ} {c : ℕ → ℝ} {a : ℝ} (hR : R.Nonempty)
    (ha : a ≠ 0) (hc : cellCentre R c ≠ 0) :
    Theta R c (fun _ => a) = 1 := by
  have hcard : (R.card : ℝ) ≠ 0 := by
    have : R.card ≠ 0 := Finset.card_ne_zero_of_mem hR.choose_spec
    exact_mod_cast this
  have hmass : mass R (fun _ => a) = R.card * a := by
    simp [mass, Finset.sum_const, nsmul_eq_mul]
  have hmne : mass R (fun _ => a) ≠ 0 := by
    rw [hmass]; exact mul_ne_zero hcard ha
  have hrbar : rbar R c (fun _ => a) = cellCentre R c := by
    rw [rbar, hmass, ← Finset.sum_mul, cellCentre]
    field_simp
  rw [Theta, hrbar, div_self hc]

/-- **Θ ≡ 1 on every cell forces uniformity.**  If the conditional mean of the scan kernel
agrees with the cell centre for *every* stratum, then the weight is constant on the
positional space.  This is the precise sense in which "`Θ ≡ 1` iff uniform" holds. -/
theorem uniform_of_forall_theta_eq_one {M : ℕ} {w : ℕ → ℝ} (hw : ∀ i, 0 ≤ w i)
    (h : ∀ R ⊆ positions M, R.Nonempty → mass R w ≠ 0 →
      rbar R scanCost w = cellCentre R scanCost) :
    ∀ i ∈ positions M, ∀ j ∈ positions M, w i = w j := by
  intro i hi j hj
  rcases eq_or_ne i j with rfl | hij
  · rfl
  by_cases hmass : w i + w j = 0
  · have hi0 : w i = 0 := le_antisymm (by linarith [hw j]) (hw i)
    have hj0 : w j = 0 := le_antisymm (by linarith [hw i]) (hw j)
    rw [hi0, hj0]
  · have hsub : ({i, j} : Finset ℕ) ⊆ positions M := by
      intro x hx
      simp only [Finset.mem_insert, Finset.mem_singleton] at hx
      rcases hx with rfl | rfl <;> assumption
    have hne : ({i, j} : Finset ℕ).Nonempty := ⟨i, by simp⟩
    have hm : mass ({i, j} : Finset ℕ) w = w i + w j := by
      simp [mass, Finset.sum_pair hij]
    have hmne : mass ({i, j} : Finset ℕ) w ≠ 0 := by rw [hm]; exact hmass
    have hkey := h {i, j} hsub hne hmne
    have hcard : (({i, j} : Finset ℕ).card : ℝ) = 2 := by
      rw [Finset.card_pair hij]; norm_num
    rw [rbar, hm, cellCentre, hcard, Finset.sum_pair hij, Finset.sum_pair hij] at hkey
    simp only [scanCost] at hkey
    have h2 : ((i : ℝ) * w i + (j : ℝ) * w j) * 2 = ((i : ℝ) + j) * (w i + w j) := by
      field_simp at hkey
      linarith [hkey]
    have hij' : (i : ℝ) ≠ (j : ℝ) := by exact_mod_cast hij
    have hz : ((i : ℝ) - j) * (w i - w j) = 0 := by nlinarith [h2]
    rcases mul_eq_zero.mp hz with h1 | h1
    · exact absurd (by linarith : (i : ℝ) = j) hij'
    · linarith

/-- **The single-cell converse is false.**  `Θ = 1` on one stratum does *not* force
uniformity: a symmetric two-atom weight on `{1,2,3}` has conditional mean equal to the
cell centre while being wildly non-uniform.  So the booking factor is only a *complete*
uniformity certificate when it is required on all cells simultaneously. -/
theorem theta_eq_one_not_uniform :
    ∃ w : ℕ → ℝ, (∀ i, 0 ≤ w i) ∧ mass (positions 3) w = 1 ∧
      rbar (positions 3) scanCost w = cellCentre (positions 3) scanCost ∧
      w 1 ≠ w 2 := by
  have h3 : positions 3 = ({1, 2, 3} : Finset ℕ) := by decide
  refine ⟨fun i => if i = 1 then (1 : ℝ) / 2 else if i = 3 then 1 / 2 else 0, ?_, ?_, ?_, ?_⟩
  · intro i; dsimp only; split_ifs <;> norm_num
  · rw [mass, h3]; norm_num
  · rw [rbar, cellCentre, mass, h3]
    norm_num [scanCost]
  · norm_num

/-! ## Majorization : the descending weight beats the baseline -/

/-- A weight that is antitone on the positional space antivaries with the slot index. -/
lemma antivaryOn_of_antitone {M : ℕ} {w : ℕ → ℝ}
    (hanti : ∀ i ∈ positions M, ∀ j ∈ positions M, i ≤ j → w j ≤ w i) :
    AntivaryOn (fun i : ℕ => (i : ℝ)) w (positions M) := by
  intro i hi j hj hlt
  by_contra hcon
  push_neg at hcon
  have hij : i ≤ j := by exact_mod_cast hcon.le
  have := hanti i (Finset.mem_coe.mp hi) j (Finset.mem_coe.mp hj) hij
  linarith [hlt, this]

/-- **Chebyshev / majorization step.**  If the weight is antitone on the positional space
(heavier slots first — the descending arrangement) then the expected scan cost is at most
the full-scan baseline `C₀ = (M+1)/2`.  This is the inequality `C_sort ≤ C₀` of the master
chain. -/
theorem scan_cost_le_baseline {M : ℕ} (hM : 0 < M) {w : ℕ → ℝ}
    (hanti : ∀ i ∈ positions M, ∀ j ∈ positions M, i ≤ j → w j ≤ w i)
    (htot : mass (positions M) w = 1) :
    EC M scanCost w ≤ baselineC0 M := by
  have hav : AntivaryOn (fun i : ℕ => (i : ℝ)) w (positions M) := antivaryOn_of_antitone hanti
  have hcheb := hav.card_mul_sum_le_sum_mul_sum
  rw [card_positions, sum_positions] at hcheb
  simp only [mass] at htot
  rw [htot, mul_one] at hcheb
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  rw [EC, baselineC0]
  simp only [scanCost]
  nlinarith [hcheb, hMpos]

/-- **Exchange (rearrangement) step.**  Putting the heavier weight in the earlier slot never
increases the expected scan cost. -/
theorem exchange_inequality {i j : ℕ} {a b : ℝ} (hij : i ≤ j) (hab : b ≤ a) :
    (i : ℝ) * a + (j : ℝ) * b ≤ (i : ℝ) * b + (j : ℝ) * a := by
  have h1 : (0 : ℝ) ≤ (j : ℝ) - i := by
    have : (i : ℝ) ≤ j := by exact_mod_cast hij
    linarith
  nlinarith [h1, sub_nonneg.mpr hab]

/-- **Sorting optimality (rearrangement inequality).**  For a weight that is antitone on the
positional space, the identity arrangement minimises the expected scan cost among all
rearrangements of the weight by a permutation supported on the positional space. -/
theorem sorted_le_of_antitone {M : ℕ} {w : ℕ → ℝ}
    (hanti : ∀ i ∈ positions M, ∀ j ∈ positions M, i ≤ j → w j ≤ w i)
    {σ : Equiv.Perm ℕ} (hσ : {x | σ x ≠ x} ⊆ positions M) :
    EC M scanCost w ≤ ∑ i ∈ positions M, scanCost i * w (σ i) := by
  have hav : AntivaryOn (fun i : ℕ => (i : ℝ)) w (positions M) := antivaryOn_of_antitone hanti
  simpa [EC, scanCost] using hav.sum_mul_le_sum_mul_comp_perm hσ

/-! ## The `k_bits` branch : pigeonhole on the filter -/

/-- **Pigeonhole on a `k`-bit filter.**  Any assignment of the `M` slots to `2^k` buckets
leaves some bucket with at least `M / 2^k` slots; the worst-case cost of an algorithm that
must scan a whole bucket is therefore at least `M / 2^k`. -/
theorem exists_large_bucket (M k : ℕ) (h : ℕ → ℕ)
    (hmaps : ∀ i ∈ positions M, h i ∈ Finset.range (2 ^ k)) :
    ∃ b ∈ Finset.range (2 ^ k),
      (M : ℝ) / (2 ^ k) ≤ (({i ∈ positions M | h i = b} : Finset ℕ).card : ℝ) := by
  classical
  by_contra hcon
  push_neg at hcon
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have hmapsTo : ((positions M : Finset ℕ) : Set ℕ).MapsTo h (Finset.range (2 ^ k)) :=
    fun i hi => Finset.mem_coe.mpr (hmaps i (Finset.mem_coe.mp hi))
  have hcard : ∑ b ∈ Finset.range (2 ^ k), ({i ∈ positions M | h i = b} : Finset ℕ).card
      = (positions M).card := (Finset.card_eq_sum_card_fiberwise hmapsTo).symm
  have hsum : ((positions M).card : ℝ)
      = ∑ b ∈ Finset.range (2 ^ k), (({i ∈ positions M | h i = b} : Finset ℕ).card : ℝ) := by
    rw [← hcard]; push_cast; ring
  have hne : (Finset.range (2 ^ k)).Nonempty :=
    ⟨0, Finset.mem_range.mpr (pow_pos (by norm_num) k)⟩
  have hlt : ∑ b ∈ Finset.range (2 ^ k), (({i ∈ positions M | h i = b} : Finset ℕ).card : ℝ)
      < ∑ _b ∈ Finset.range (2 ^ k), (M : ℝ) / (2 ^ k) :=
    Finset.sum_lt_sum_of_nonempty hne (fun b hb => hcon b hb)
  rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul] at hlt
  rw [card_positions] at hsum
  have hfin : (M : ℝ) < (M : ℝ) := by
    calc (M : ℝ)
        = ∑ b ∈ Finset.range (2 ^ k),
            (({i ∈ positions M | h i = b} : Finset ℕ).card : ℝ) := hsum
      _ < ((2 ^ k : ℕ) : ℝ) * ((M : ℝ) / 2 ^ k) := hlt
      _ = (M : ℝ) := by push_cast; field_simp
  exact lt_irrefl _ hfin

/-- **`k_bits` branch, instantiated.**  If the algorithm must scan a full bucket of a
`k`-bit filter in the worst case, its speedup against a nonnegative baseline `C_desc` is at
most `C_desc · 2^k / M`. -/
theorem speedup_le_two_pow_kbits {M k : ℕ} {CA Cdesc : ℝ} (hM : 0 < M)
    (hCA : 0 < CA) (hCdesc : 0 ≤ Cdesc) (hbucket : (M : ℝ) / 2 ^ k ≤ CA) :
    Cdesc / CA ≤ Cdesc * 2 ^ k / M := by
  have hMpos : (0 : ℝ) < M := by exact_mod_cast hM
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  have hbucket' : (M : ℝ) ≤ CA * 2 ^ k := by
    rw [div_le_iff₀ hpow] at hbucket
    linarith
  rw [div_le_div_iff₀ hCA hMpos]
  nlinarith [hbucket', hCdesc, hpow]

/-! ## The master inequality -/

/-- **Master inequality (abstract chain).**  With bookings `Λ` (sort-to-descending cost
ratio), `Θ` (within-cell nonuniformity) and `q̂` (booked capture rate), any algorithm whose
cost dominates both booked lower bounds has speedup at most the *minimum* of the two
bounds: `S ≤ min (1/(Λ·Θ·q̂)) (2^k/(Λ·Θ))`. -/
theorem master_inequality {CA Cdesc lam th qhat twok : ℝ}
    (hCA : 0 < CA) (hlam : 0 < lam) (hth : 0 < th) (hq : 0 < qhat)
    (h1 : lam * th * qhat * Cdesc ≤ CA) (h2 : lam * th * Cdesc ≤ twok * CA) :
    Cdesc / CA ≤ min (1 / (lam * th * qhat)) (twok / (lam * th)) := by
  have hlt : 0 < lam * th * qhat := by positivity
  have hlt2 : 0 < lam * th := by positivity
  refine le_min ?_ ?_
  · rw [div_le_div_iff₀ hCA hlt]
    nlinarith [h1]
  · rw [div_le_div_iff₀ hCA hlt2]
    nlinarith [h2]

/-- **Master inequality from the filter.**  Combining the pigeonhole (`k_bits`) branch with
the booked `q̂` branch gives the unconditional two-sided cap.  Nothing here assumes
uniformity within cells: this is the sense in which the master inequality is
*unconditional*, while the *value* law (below) is not. -/
theorem master_inequality_of_filter {M k : ℕ} {CA Cdesc lam th qhat : ℝ}
    (hCA : 0 < CA) (hlam : 0 < lam) (hth : 0 < th) (hq : 0 < qhat)
    (h1 : lam * th * qhat * Cdesc ≤ CA)
    (hbucket : (M : ℝ) / 2 ^ k ≤ CA) (hbook : lam * th * Cdesc ≤ M) :
    Cdesc / CA ≤ min (1 / (lam * th * qhat)) ((2 : ℝ) ^ k / (lam * th)) := by
  have hpow : (0 : ℝ) < 2 ^ k := by positivity
  refine master_inequality hCA hlam hth hq h1 ?_
  have hbucket' : (M : ℝ) ≤ 2 ^ k * CA := by
    rw [div_le_iff₀ hpow] at hbucket
    linarith
  linarith [hbook, hbucket']

/-! ## Off uniform cells the *value* law is not universal -/

/-- Expected cost of a two-atom weight. -/
lemma EC_two_point {M a b : ℕ} {c : ℕ → ℝ} (hab : a ≠ b) (ha : a ∈ positions M)
    (hb : b ∈ positions M) (x y : ℝ) :
    EC M c (fun i => if i = a then x else if i = b then y else 0) = c a * x + c b * y := by
  classical
  rw [EC, Finset.sum_eq_add_of_mem a b ha hb hab ?_]
  · simp [hab.symm]
  · intro i _ hi
    simp [hi.1, hi.2]

/-- Mass of a two-atom weight on a stratum containing only the first atom. -/
lemma mass_two_point_left {a b : ℕ} {R : Finset ℕ} (ha : a ∈ R) (hb : b ∉ R) (x y : ℝ) :
    mass R (fun i => if i = a then x else if i = b then y else 0) = x := by
  classical
  rw [mass, Finset.sum_eq_single_of_mem a ha]
  · simp
  · intro i hiR hi
    have hib : i ≠ b := by rintro rfl; exact hb hiR
    simp [hi, hib]

/-- Mass of a two-atom weight on a stratum containing both atoms. -/
lemma mass_two_point_both {a b : ℕ} {R : Finset ℕ} (hab : a ≠ b) (ha : a ∈ R) (hb : b ∈ R)
    (x y : ℝ) :
    mass R (fun i => if i = a then x else if i = b then y else 0) = x + y := by
  classical
  rw [mass, Finset.sum_eq_add_of_mem a b ha hb hab ?_]
  · simp [hab.symm]
  · intro i _ hi
    simp [hi.1, hi.2]

/-- The booked (uniform-within-cell) expected scan cost for a head stratum of size `m`
inside `M` slots with capture probability `P`. -/
def bookedEC (M m : ℕ) (P : ℝ) : ℝ :=
  P * (((m : ℝ) + 1) / 2) + (1 - P) * ((m : ℝ) + ((M : ℝ) - m + 1) / 2)

/-- The adversarial witness family: all the captured mass sits at the very head of the
stratum and all the escaping mass at the very head of the complement. -/
def headWitness (m : ℕ) : ℕ → ℝ :=
  fun i => if i = 1 then 1 - 1 / (m : ℝ) else if i = m + 1 then 1 / (m : ℝ) else 0

lemma headWitness_eq (m : ℕ) :
    headWitness m
      = fun i => if i = 1 then 1 - 1 / (m : ℝ) else if i = m + 1 then 1 / (m : ℝ) else 0 := rfl

lemma headWitness_nonneg {m : ℕ} (hm : 1 ≤ m) (i : ℕ) : 0 ≤ headWitness m i := by
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  rw [headWitness]
  split_ifs
  · rw [sub_nonneg, div_le_one (by linarith)]
    linarith
  · positivity
  · exact le_rfl

/-- The witness realises the booked capture probability `P = 1 - 1/m` exactly. -/
lemma headWitness_mass_head {m : ℕ} (hm : 1 ≤ m) :
    mass (positions m) (headWitness m) = 1 - 1 / (m : ℝ) := by
  have hmem : (1 : ℕ) ∈ positions m := by rw [mem_positions]; omega
  have hnot : m + 1 ∉ positions m := by rw [mem_positions]; omega
  rw [headWitness_eq]
  exact mass_two_point_left hmem hnot _ _

lemma headWitness_mass_total {m : ℕ} (hm : 1 ≤ m) :
    mass (positions (2 * m)) (headWitness m) = 1 := by
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have h1 : (1 : ℕ) ∈ positions (2 * m) := by rw [mem_positions]; omega
  have h2 : m + 1 ∈ positions (2 * m) := by rw [mem_positions]; omega
  have hne : (1 : ℕ) ≠ m + 1 := by omega
  rw [headWitness_eq, mass_two_point_both hne h1 h2]
  field_simp
  ring

lemma headWitness_EC {m : ℕ} (hm : 1 ≤ m) :
    EC (2 * m) scanCost (headWitness m) = 2 := by
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hmpos : (0 : ℝ) < (m : ℝ) := by linarith
  have h1 : (1 : ℕ) ∈ positions (2 * m) := by rw [mem_positions]; omega
  have h2 : m + 1 ∈ positions (2 * m) := by rw [mem_positions]; omega
  have hne : (1 : ℕ) ≠ m + 1 := by omega
  rw [headWitness_eq, EC_two_point (c := scanCost) hne h1 h2]
  simp only [scanCost]
  push_cast
  field_simp
  ring

lemma headWitness_booked {m : ℕ} (hm : 1 ≤ m) :
    bookedEC (2 * m) m (1 - 1 / (m : ℝ)) = ((m : ℝ) + 3) / 2 := by
  have hmR : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hmpos : (0 : ℝ) < (m : ℝ) := by linarith
  rw [bookedEC]
  push_cast
  field_simp
  ring

/-- **Value-universality is false off uniform cells, and the failure is unbounded.**
For every bound `B` there is a positional-stratum instance — a head stratum of size `m`
inside `M = 2m` slots, honouring the booked capture probability `P` *exactly* — whose true
expected scan cost is smaller than the booked (uniform-cell) prediction by a factor
exceeding `B`.  Hence the booked *value* (speedup) law is not an upper bound off uniform
cells, even though the master inequality above stays valid. -/
theorem value_universality_fails (B : ℝ) :
    ∃ (M m : ℕ) (P : ℝ) (w : ℕ → ℝ), 0 < m ∧ m < M ∧ 0 < P ∧ P < 1 ∧
      (∀ i, 0 ≤ w i) ∧
      mass (positions m) w = P ∧
      mass (positions M) w = 1 ∧
      0 < EC M scanCost w ∧
      B * EC M scanCost w < bookedEC M m P := by
  classical
  obtain ⟨n, hn⟩ := exists_nat_gt (max B 1)
  set m : ℕ := 8 * n + 8 with hmdef
  have hm : 1 ≤ m := by omega
  have hmR : (8 : ℝ) ≤ (m : ℝ) := by
    have : (8 : ℕ) ≤ m := by omega
    exact_mod_cast this
  have hmpos : (0 : ℝ) < (m : ℝ) := by linarith
  have hEC := headWitness_EC hm
  have hbk := headWitness_booked hm
  refine ⟨2 * m, m, 1 - 1 / (m : ℝ), headWitness m, by omega, by omega, ?_, ?_,
    headWitness_nonneg hm, headWitness_mass_head hm, headWitness_mass_total hm, ?_, ?_⟩
  · rw [sub_pos, div_lt_one hmpos]; linarith
  · have : (0 : ℝ) < 1 / (m : ℝ) := by positivity
    linarith
  · rw [hEC]; norm_num
  · rw [hEC, hbk]
    have hBn : B < (n : ℝ) := lt_of_le_of_lt (le_max_left B 1) hn
    have hnm : (m : ℝ) = 8 * (n : ℝ) + 8 := by rw [hmdef]; push_cast; ring
    have hn0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
    rw [hnm]
    linarith

end

end PositionalStratum