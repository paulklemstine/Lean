import Cryptography.DegreeTenCyclotomic.Cyclotomic11
import Cryptography.TypeChannelMilestone.UnifiedLaw
import Cryptography.NonabelianTypeChannel.LogValues

/-!
# Full pinning at degree ten (paper 141, exp 473), in exact closed form

Uses the catalog type-channel calculus (`TypeChannel.entropy`, `mutualInfo`,
`unified_type_channel_law`).

* `cyclic_type_fiber_card`, `cyclic_type_entropy` — Chebotarev densities `φ(d)/n` and the
  closed-form type entropy of every cyclic field.
* `abelian_full_pinning` — for every finite abelian Galois group and separating residue
  readout: `I = H(T)`, `H(T | residue) = 0`, `log₂|A| − I = H(residue | T)`.
* `deg10_type_counts` — multiplicities `1,1,4,4` of `T ∈ {1,2,5,10}`.
* `deg10_type_entropy`, `deg10_full_pinning` — `I(p mod 11 ; T) = H(T) = log₂ 5 − 3/5`.
* `deg10_residue_given_type` — the loss `H(p mod 11 | T) = 8/5` bits exactly.
-/

namespace DegreeTen

open TypeChannel Finset Real

set_option maxRecDepth 4000000

/-! ### The general cyclic (cyclotomic) type law -/

section Cyclic

variable {G : Type*} [Group G] [Fintype G] [IsCyclic G]

/-- **Chebotarev densities of a cyclic field.**  In a cyclic Galois group of order `n`, the
Frobenius type `ord = d` (for `d ∣ n`) is carried by exactly `φ(d)` elements. -/
theorem cyclic_type_fiber_card {d : ℕ} (hd : d ∣ Fintype.card G) :
    (fiber (univ : Finset G) orderOf d).card = d.totient := by
  rw [← IsCyclic.card_orderOf_eq_totient hd]
  rfl

/-- **Closed-form type entropy of a cyclic field**:
`H(T) = − Σ_{d ∣ n} (φ(d)/n) log₂ (φ(d)/n)`. -/
theorem cyclic_type_entropy :
    entropy (univ : Finset G) orderOf =
      ∑ d ∈ (Fintype.card G).divisors,
        -(((d.totient : ℝ) / Fintype.card G) * logb 2 ((d.totient : ℝ) / Fintype.card G)) := by
  have hsub : (univ : Finset G).image orderOf ⊆ (Fintype.card G).divisors := by
    intro d hd
    obtain ⟨g, -, rfl⟩ := mem_image.mp hd
    exact Nat.mem_divisors.mpr ⟨orderOf_dvd_card, Fintype.card_ne_zero⟩
  rw [entropy_eq_sum_of_subset hsub]
  refine Finset.sum_congr rfl (fun d hd => ?_)
  have hfib := cyclic_type_fiber_card (G := G) (Nat.dvd_of_mem_divisors hd)
  simp only [prob, hfib, card_univ]

end Cyclic

/-! ### Full pinning for every abelian field -/

section Abelian

variable {A : Type*} [CommGroup A] [Fintype A] [DecidableEq A] {τ : Type*} [DecidableEq τ]

omit [DecidableEq A] in
lemma univ_isSubgroupFinset : IsSubgroupFinset (univ : Finset A) :=
  ⟨mem_univ _, fun _ _ _ _ => mem_univ _, fun _ _ => mem_univ _⟩

omit [DecidableEq A] in
lemma abelian_isDerived : IsDerivedFinset (univ : Finset A) {1} :=
  ⟨subset_univ _, fun a _ b _ => by simp [mul_comm a b],
    fun n hn => ⟨1, mem_univ _, 1, mem_univ _, by simpa using hn⟩⟩

omit [DecidableEq A] in
lemma abelian_isCosetReadout {κ : Type*} [DecidableEq κ] {c : A → κ}
    (hc : Function.Injective c) : IsCosetReadout (univ : Finset A) {1} c := by
  intro a _ b _
  simp only [mem_singleton, mul_inv_eq_one]
  exact hc.eq_iff

/-- **The abelian full-pinning law, all degrees at once.**  For every finite abelian Galois
group (full cyclotomic, real subfield, or any abelian field), every separating residue
readout `c` and every splitting-type readout `T`:
* the residue pins the type: `I(c ; T) = H(T)`;
* per-class degeneracy: `H(T | c) = 0`;
* the loss is the residue uncertainty given the type: `log₂|A| − I = H(c | T)`. -/
theorem abelian_full_pinning {κ : Type*} [DecidableEq κ] {c : A → κ}
    (hc : Function.Injective c) (T : A → τ) :
    mutualInfo univ c T = entropy univ T ∧ condEntropy univ T c = 0 ∧
      logb 2 (Fintype.card A) - mutualInfo univ c T = condEntropy univ c T := by
  have hco := abelian_isCosetReadout (A := A) hc
  have law := unified_type_channel_law univ_isSubgroupFinset
    (show IsSubgroupFinset ({1} : Finset A) from
      ⟨mem_singleton_self _, by simp, by simp⟩) abelian_isDerived hco T
  have hpin := law.2.2.1 (fun a _ b _ => mul_comm a b)
  have himg : ((univ : Finset A).image c).card = Fintype.card A := by
    rw [card_image_of_injective _ hc, card_univ]
  refine ⟨hpin, ?_, ?_⟩
  · have := law.1; linarith
  · have := law.2.1; rw [himg] at this; linarith

end Abelian

/-! ### Degree ten: `ℚ(ζ₁₁)` -/

/-- The residue readout `p mod 11`, as a natural number in `[1, 10]`. -/
def resid (g : U11) : ℕ := (g : ZMod 11).val

lemma resid_injective : Function.Injective resid := by decide

lemma U11_card : (univ : Finset U11).card = 10 := by decide

/-- The four Frobenius types occur with multiplicities `1, 1, 4, 4` (densities
`1/10, 1/10, 4/10, 4/10`), and these are `φ(1), φ(2), φ(5), φ(10)`. -/
theorem deg10_type_counts :
    [1, 2, 5, 10].map (fun d => (fiber (univ : Finset U11) frobType d).card) = [1, 1, 4, 4] ∧
      [1, 2, 5, 10].map Nat.totient = [1, 1, 4, 4] := by
  constructor
  · decide
  · decide

lemma logb2_five_ten : logb 2 (10:ℝ) = 1 + logb 2 5 := by
  rw [show (10:ℝ) = 2 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), logb2_two]

lemma logb2_hundred : logb 2 (100:ℝ) = 2 + 2 * logb 2 5 := by
  rw [show (100:ℝ) = 4 * (5 * 5) by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_mul (by norm_num) (by norm_num), logb2_four]; ring

/-- **Type entropy at degree ten**: `H(T) = log₂ 5 − 3/5 ≈ 1.7219` bits. -/
theorem deg10_type_entropy : entropy (univ : Finset U11) frobType = logb 2 5 - 3/5 := by
  rw [entropy_eq_sumList (A := [1, 2, 5, 10]) (L := [1, 1, 4, 4]) (by decide) (by decide)
    (by decide), U11_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 10 (by norm_num) (by norm_num),
    neg_prob_logb_real 4 10 (by norm_num) (by norm_num), logb2_five_ten, logb2_four]
  simp only [Real.logb_one]
  ring

/-- **FULL-PINNING-AT-DEGREE-TEN.**  The residue `p mod 11` carries all of the Frobenius
type: `I(p mod 11 ; T) = H(T) = log₂ 5 − 3/5` exactly. -/
theorem deg10_full_pinning :
    mutualInfo (univ : Finset U11) resid frobType = entropy univ frobType ∧
      mutualInfo (univ : Finset U11) resid frobType = logb 2 5 - 3/5 := by
  have h := (abelian_full_pinning resid_injective frobType).1
  exact ⟨h, h.trans deg10_type_entropy⟩

/-- Per-class degeneracy: given the residue, the type is certain. -/
theorem deg10_per_class_degenerate : condEntropy (univ : Finset U11) frobType resid = 0 :=
  (abelian_full_pinning resid_injective frobType).2.1

/-- **The loss at degree ten is exactly `8/5` bits**: the type leaves `H(p mod 11 | T) = 8/5`
bits of the residue unresolved (the type is a lossy summary of the residue, never the
converse). -/
theorem deg10_residue_given_type : condEntropy (univ : Finset U11) resid frobType = 8/5 := by
  have h := (abelian_full_pinning resid_injective frobType).2.2
  have hc : (Fintype.card U11 : ℝ) = 10 := by
    rw [← card_univ, U11_card]; norm_num
  rw [hc, deg10_full_pinning.2, logb2_five_ten] at h
  linarith

/-- The general cyclic law reproduces the degree-ten value (independent cross-check). -/
theorem deg10_cyclic_law_crosscheck :
    entropy (univ : Finset U11) orderOf = logb 2 5 - 3/5 := by
  rw [← deg10_type_entropy]
  exact entropy_congr (fun g _ => frobType_eq_orderOf g)

end DegreeTen