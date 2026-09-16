/-
# The abelianization law at degree five: the Frobenius field `F₂₀ = AGL(1,5)`

The splitting-type channel of the catalog (`Shared.CyclicTypeChannel`) has so far been
developed over *abelian* Galois groups, where the splitting type of an unramified prime
is a function of a residue class and the channel is fully pinned
(`CyclicSubfield.subfield_full_pinning`).  This file opens the first genuinely
**non-abelian degree-five** object: the splitting field of `x⁵ - 2`, whose Galois group is
the Frobenius group

  `F₂₀ = AGL(1,5) = {x ↦ a x + b : a ∈ 𝔽₅ˣ, b ∈ 𝔽₅}`,

acting on the five roots.  Its abelianization is `C₄ = Gal(ℚ(ζ₅)/ℚ)`, read off by the
residue `p mod 5`, so `F₂₀` is the program's first `C₄`-abelianization object.

## The model

Under Chebotarev the Frobenius of an unramified prime is uniform on the 20 group elements.
We encode the group element `x ↦ a x + b` as the number `5 * e + b ∈ range 20`, where
`e ∈ {0,1,2,3}` is the **`C₄` valuation** of the multiplier, i.e. the discrete logarithm
of `a` to the base `2` in `𝔽₅ˣ`:

| `e` | `a = 2^e mod 5` | cycle type of `x ↦ a x + b` on the 5 roots |
|-----|------------------|--------------------------------------------|
| `0` | `1`              | `[1,1,1,1,1]` if `b = 0`, otherwise `[5]`   |
| `1` | `2`              | `[1,4]` (one fixed point, one 4-cycle)      |
| `2` | `4`              | `[1,2,2]` (one fixed point, two 2-cycles)   |
| `3` | `3`              | `[1,4]`                                     |

So `qDial x = x / 5` is the abelianization read-out (`p mod 5` in the `C₄` valuation) and
`qType x` is the splitting type of `x⁵ - 2 mod p`, coded by the natural numbers
`1, 5, 14, 122` for `[1,1,1,1,1]`, `[5]`, `[1,4]`, `[1,2,2]`.  The *coset labelling*
`V(2) = 1, V(4) = 2, V(3) = 3` matters: see `Bridges.QuinticTypeChannelF20Pair` for the
swapped-label object, which is **indistinguishable at the prime level** and yet carries a
different semiprime pair law.

## Results

* `uEnt_eq_logb_of_uniform_fibers`, `condEnt_eq_sum_merged`, `dial_gap_eq_merge_entropy` —
  the general **merged-coset law**: for any type/dial pair whose dial is uniform inside each
  type fibre, the gap between the dial entropy `H(D)` and the transmitted information
  `I(T ; D)` is exactly `∑_t P(t) · log₂ k(t)`, the entropy of the cosets that the type `t`
  cannot tell apart.
* `quinticTypeEntropy_val` — `H(T) = 11/10 + (log₂ 5)/4 = 1.6804…` bits of quintic
  splitting entropy.
* `quinticDialEntropy_val` — the quartic dial carries exactly `2` bits.
* `quintic_merge_gap` — the merged-coset sum for `F₂₀` is exactly `1/2`: only the type
  `[1,4]`, of probability `1/2`, merges two cosets.
* `abelianization_law_degree_five` — **the law**: `I(p mod 5 ; T) = 3/2` exactly, the
  transcendental `log₂ 5` cancelling between `H(T)` and `H(T | p mod 5)`.
* `quintic_condEnt_type_dial` — the residual `H(T | p mod 5) = (log₂ 5)/4 - 2/5`, the part
  of the quintic type that no residue can see.
* `quintic_type_not_pinned`, `quintic_dial_not_refined_by_type` — the channel is genuinely
  two-sided lossy: unlike every abelian object in the catalog it is *not* fully pinned, and
  the type does not determine the coset either.
* `control_C5_*` — the abelian control `C₅ = ℚ(ζ₁₁)⁺` run through the same machinery:
  `I = H(T) = log₂ 5 - 8/5` with a `log₂ 10` dial, loss `13/5`.
-/
import Shared.CyclicTypeChannel
import Bridges.CyclicSubfieldTypeChannel
import NumberTheory.CharacterOneBit

namespace QuinticF20

open Finset CyclicTypeChannel

set_option maxRecDepth 100000
set_option exponentiation.threshold 400

/-! ## 0. Logarithm bookkeeping -/

lemma lbq_20 : Real.logb 2 (20 : ℝ) = 2 + Real.logb 2 5 := by
  rw [show (20 : ℝ) = 4 * 5 by norm_num, Real.logb_mul (by norm_num) (by norm_num), lb_4]

lemma lbq_10 : Real.logb 2 (10 : ℝ) = 1 + Real.logb 2 5 := lb_10

/-- A sharp lower bound: `log₂ 5 > 339/146`, i.e. `5 ^ 146 > 2 ^ 339`. -/
lemma lbq_five_gt : (339 : ℝ) / 146 < Real.logb 2 5 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (2 : ℕ) ^ (339 : ℕ) < (5 : ℕ) ^ (146 : ℕ) := by decide
  have hlt : ((2 : ℝ)) ^ (339 : ℕ) < ((5 : ℝ)) ^ (146 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((2 : ℝ) ^ (339 : ℕ)) < Real.log ((5 : ℝ) ^ (146 : ℕ)) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- A sharp upper bound: `log₂ 5 < 137/59`, i.e. `5 ^ 59 < 2 ^ 137`. -/
lemma lbq_five_lt : Real.logb 2 5 < (137 : ℝ) / 59 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hnat : (5 : ℕ) ^ (59 : ℕ) < (2 : ℕ) ^ (137 : ℕ) := by decide
  have hlt : ((5 : ℝ)) ^ (59 : ℕ) < ((2 : ℝ)) ^ (137 : ℕ) := by exact_mod_cast hnat
  have h : Real.log ((5 : ℝ) ^ (59 : ℕ)) < Real.log ((2 : ℝ) ^ (137 : ℕ)) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-! ## 1. The general merged-coset law

These three lemmas are stated for an arbitrary finite "Chebotarev box" `s` with a type
read-out `T` and a dial read-out `D`.  They isolate the mechanism behind the abelianization
law: the only thing that governs the gap between the dial's entropy and the information the
type transmits is *how many dial classes each type value merges*. -/

section MergeLaw

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- A read-out all of whose fibres have the same size `c` has entropy `log₂ (|s| / c)`,
i.e. the logarithm of the number of fibres. -/
theorem uEnt_eq_logb_of_uniform_fibers {s : Finset α} {g : α → β} {c : ℕ}
    (hs : s.Nonempty) (h : ∀ a ∈ s, #{x ∈ s | g x = g a} = c) :
    uEnt s g = Real.logb 2 (s.card : ℝ) - Real.logb 2 (c : ℝ) := by
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hsum : ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
      = (s.card : ℝ) * Real.logb 2 (c : ℝ) := by
    rw [Finset.sum_congr rfl (fun a ha => by rw [h a ha])]
    simp [Finset.sum_const, nsmul_eq_mul]
  rw [uEnt, hsum, mul_comm, mul_div_assoc, div_self (ne_of_gt hN), mul_one]

/-- **The merged-coset conditional entropy.**  If, inside every type fibre, all dial classes
that occur have the same size `c t`, then

  `H(D | T) = ∑_t P(t) · (log₂ |T⁻¹(t)| - log₂ c t)`,

and the bracket is exactly `log₂` of the number of cosets merged by the type value `t`. -/
theorem condEnt_eq_sum_merged {s : Finset α} (T : α → β) (D : α → γ) (c : β → ℕ)
    (h : ∀ t ∈ s.image T, ∀ a ∈ ({x ∈ s | T x = t} : Finset α),
        #{x ∈ ({y ∈ s | T y = t} : Finset α) | D x = D a} = c t) :
    condEnt s D T = ∑ t ∈ s.image T,
      ((#{x ∈ s | T x = t} : ℝ) / s.card) *
        (Real.logb 2 (#{x ∈ s | T x = t} : ℝ) - Real.logb 2 (c t : ℝ)) := by
  refine Finset.sum_congr rfl fun t ht => ?_
  obtain ⟨a₀, ha₀, rfl⟩ := mem_image.1 ht
  have hne : ({x ∈ s | T x = T a₀} : Finset α).Nonempty := ⟨a₀, by simp [ha₀]⟩
  rw [uEnt_eq_logb_of_uniform_fibers hne (h _ ht)]

/-- **The abelianization law in general form.**  The gap between the dial entropy `H(D)` and
the information `I(T ; D)` that the splitting type transmits about the dial is exactly the
entropy of the cosets that the type merges.  Nothing about the group enters; only the
merging pattern does. -/
theorem dial_gap_eq_merge_entropy {s : Finset α} (hs : s.Nonempty) (T : α → β) (D : α → γ)
    (c : β → ℕ)
    (h : ∀ t ∈ s.image T, ∀ a ∈ ({x ∈ s | T x = t} : Finset α),
        #{x ∈ ({y ∈ s | T y = t} : Finset α) | D x = D a} = c t) :
    uEnt s D - mutInfo s T D = ∑ t ∈ s.image T,
      ((#{x ∈ s | T x = t} : ℝ) / s.card) *
        (Real.logb 2 (#{x ∈ s | T x = t} : ℝ) - Real.logb 2 (c t : ℝ)) := by
  rw [mutInfo_comm hs, mutInfo, sub_sub_cancel, condEnt_eq_sum_merged T D c h]

end MergeLaw

/-! ## 2. The `F₂₀` Frobenius box -/

/-- The 20 Frobenius classes of the splitting field of `x⁵ - 2`, encoded as `5 * e + b`. -/
def qFrob : Finset ℕ := range 20

/-- The abelianization read-out: the `C₄` valuation `e` of the multiplier `a = 2^e`,
equivalently the residue `p mod 5` transported to `ℤ/4` by the discrete logarithm. -/
def qDial (x : ℕ) : ℕ := x / 5

/-- The splitting type of `x⁵ - 2` at the Frobenius class `x`, coded by
`1 = [1,1,1,1,1]`, `5 = [5]`, `14 = [1,4]`, `122 = [1,2,2]`. -/
def qType (x : ℕ) : ℕ :=
  if x / 5 = 0 then (if x % 5 = 0 then 1 else 5) else if x / 5 = 2 then 122 else 14

/-- The size of the dial classes inside each type fibre: the fibre of `[1,1,1,1,1]` is a
single element, that of `[5]` is four elements of one coset, and the fibres of `[1,4]` and
`[1,2,2]` meet each coset they touch in five elements. -/
def qMergeSize (t : ℕ) : ℕ := if t = 1 then 1 else if t = 5 then 4 else 5

lemma qFrob_nonempty : qFrob.Nonempty := ⟨0, by decide⟩

lemma qFrob_card : qFrob.card = 20 := by decide

/-- The four quintic splitting types actually occurring. -/
lemma qType_image : qFrob.image qType = ({1, 5, 14, 122} : Finset ℕ) := by decide

/-- The four class sizes `1 : 4 : 10 : 5` — the Chebotarev densities of the four types. -/
lemma qType_fiber_1 : #{x ∈ qFrob | qType x = 1} = 1 := by decide
lemma qType_fiber_5 : #{x ∈ qFrob | qType x = 5} = 4 := by decide
lemma qType_fiber_14 : #{x ∈ qFrob | qType x = 14} = 10 := by decide
lemma qType_fiber_122 : #{x ∈ qFrob | qType x = 122} = 5 := by decide

/-- The quartic dial is equidistributed: each of the four cosets has five Frobenius
classes. -/
lemma qDial_uniform : ∀ a ∈ qFrob, #{x ∈ qFrob | qDial x = qDial a} = 5 := by decide

/-- **The merging pattern.**  Inside each type fibre every occurring dial class has the same
size `qMergeSize t`.  This is the combinatorial input of the abelianization law. -/
lemma qDial_uniform_in_type_fibers :
    ∀ t ∈ qFrob.image qType, ∀ a ∈ ({x ∈ qFrob | qType x = t} : Finset ℕ),
      #{x ∈ ({y ∈ qFrob | qType y = t} : Finset ℕ) | qDial x = qDial a} = qMergeSize t := by
  decide

/-! ## 3. The prime-level channel -/

/-- **The quintic splitting entropy.**  `H(T) = 11/10 + (log₂ 5)/4 = 1.68048…` bits, the
entropy of the Chebotarev distribution `(1/20, 4/20, 10/20, 5/20)` on the four types. -/
theorem quinticTypeEntropy_val :
    uEnt qFrob qType = 11 / 10 + (1 / 4) * Real.logb 2 5 := by
  have h : (qFrob.image qType).val.map (fun v => (#{x ∈ qFrob | qType x = v} : ℕ))
      = (↑[1, 4, 5, 10] : Multiset ℕ) := by decide
  rw [uEnt_eq_countSum _ _ _ h, qFrob_card]
  norm_num [lbq_20, lbq_10, lb_4]
  ring

/-- **The quartic dial carries exactly two bits**: `H(p mod 5) = log₂ 4 = 2`. -/
theorem quinticDialEntropy_val : uEnt qFrob qDial = 2 := by
  rw [uEnt_eq_logb_of_uniform_fibers qFrob_nonempty qDial_uniform, qFrob_card]
  norm_num [lbq_20]

/-- **The merged-coset sum of `F₂₀` is exactly one half.**  Only the type `[1,4]` merges
cosets — the two order-4 classes `{2, 3}` — and it does so with probability `1/2`. -/
theorem quintic_merge_gap :
    ∑ t ∈ qFrob.image qType,
      ((#{x ∈ qFrob | qType x = t} : ℝ) / qFrob.card) *
        (Real.logb 2 (#{x ∈ qFrob | qType x = t} : ℝ) - Real.logb 2 (qMergeSize t : ℝ))
      = 1 / 2 := by
  rw [qType_image]
  rw [show ({1, 5, 14, 122} : Finset ℕ) = insert 1 (insert 5 (insert 14 {122})) from rfl]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [qType_fiber_1, qType_fiber_5, qType_fiber_14, qType_fiber_122, qFrob_card]
  norm_num [qMergeSize, lbq_10, lb_4]

/-- **THE ABELIANIZATION LAW AT DEGREE FIVE.**

For the Frobenius field `F₂₀ = AGL(1,5)` of `x⁵ - 2`, the splitting type of an unramified
prime transmits exactly `3/2` bits about its abelianization class `p mod 5`:

  `I(p mod 5 ; T) = 2 - 1/2 = 3/2`,

the two bits of the quartic dial minus the half bit that the type `[1,4]` loses by merging
the two order-4 cosets.  The transcendental `log₂ 5` present in both `H(T)` and
`H(T | p mod 5)` cancels exactly. -/
theorem abelianization_law_degree_five : mutInfo qFrob qType qDial = 3 / 2 := by
  have h := dial_gap_eq_merge_entropy qFrob_nonempty qType qDial qMergeSize
    qDial_uniform_in_type_fibers
  rw [quinticDialEntropy_val, quintic_merge_gap] at h
  linarith

/-- The residual entropy of the quintic type given the residue:
`H(T | p mod 5) = (log₂ 5)/4 - 2/5 = 0.1805…`.  It is exactly the `[1^5] / [5]` ambiguity
inside the principal coset, weighted by `1/4`. -/
theorem quintic_condEnt_type_dial :
    condEnt qFrob qType qDial = (1 / 4) * Real.logb 2 5 - 2 / 5 := by
  have h : mutInfo qFrob qType qDial = uEnt qFrob qType - condEnt qFrob qType qDial := rfl
  rw [abelianization_law_degree_five, quinticTypeEntropy_val] at h
  linarith

/-- The half-bit the type cannot see: `H(p mod 5 | T) = 1/2`, the entropy of the two order-4
cosets merged by the type `[1,4]`. -/
theorem quintic_condEnt_dial_type : condEnt qFrob qDial qType = 1 / 2 := by
  have h : mutInfo qFrob qDial qType = uEnt qFrob qDial - condEnt qFrob qDial qType := rfl
  rw [← mutInfo_comm qFrob_nonempty, abelianization_law_degree_five,
    quinticDialEntropy_val] at h
  linarith

/-- **The channel is not pinned.**  Unlike every abelian object of the catalog — where
`I = H(T)` (`CyclicSubfield.subfield_full_pinning`) — the residue leaves a strictly positive
residual at degree five, because `log₂ 5 > 8/5`. -/
theorem quintic_type_not_pinned : mutInfo qFrob qType qDial < uEnt qFrob qType := by
  rw [abelianization_law_degree_five, quinticTypeEntropy_val]
  have := lb_five_gt
  linarith

/-- **The type does not determine the coset either.**  The two-sidedness of the loss is what
makes `F₂₀` a genuine non-abelian object: the type merges the two order-4 cosets. -/
theorem quintic_dial_not_refined_by_type : mutInfo qFrob qType qDial < uEnt qFrob qDial := by
  rw [abelianization_law_degree_five, quinticDialEntropy_val]
  norm_num

/-- The exact statement of the law table's `F₂₀` row: entropy, dial, transmitted
information and loss, all four at once. -/
theorem quintic_law_table :
    uEnt qFrob qType = 11 / 10 + (1 / 4) * Real.logb 2 5 ∧
    uEnt qFrob qDial = 2 ∧
    mutInfo qFrob qType qDial = 3 / 2 ∧
    uEnt qFrob qDial - mutInfo qFrob qType qDial = 1 / 2 :=
  ⟨quinticTypeEntropy_val, quinticDialEntropy_val, abelianization_law_degree_five, by
    rw [quinticDialEntropy_val, abelianization_law_degree_five]; norm_num⟩

/-- Numerical bracket for the quintic splitting entropy: `1.6804 < H(T) < 1.6806`. -/
theorem quinticTypeEntropy_bracket :
    (1.6804 : ℝ) < uEnt qFrob qType ∧ uEnt qFrob qType < 1.6806 := by
  rw [quinticTypeEntropy_val]
  constructor
  · have := lbq_five_gt; linarith
  · have := lbq_five_lt; linarith

/-! ## 4. The abelian control: `C₅ = ℚ(ζ₁₁)⁺`

The same pipeline applied to the degree-5 *abelian* field, the real subfield of `ℚ(ζ₁₁)`.
Here the dial is the full residue `p mod 11` (a `log₂ 10` dial) and the channel is pinned:
all of `H(T)` gets through, and the loss is the whole remaining `13/5` bits. -/

/-- The control's type entropy: `H(T) = log₂ 5 - 8/5 = 0.7219…`. -/
theorem control_C5_typeEntropy : typeEntropy 5 = Real.logb 2 5 - 8 / 5 := by
  have h := CyclicSubfield.typeEntropy_prime_formula (q := 5) (by norm_num)
  norm_num [lb_4] at h
  linarith [h]

/-- The control is **fully pinned**: the residue `p mod 11` determines the splitting type in
`ℚ(ζ₁₁)⁺`, so `I = H(T) = log₂ 5 - 8/5`. -/
theorem control_C5_pinned :
    mutInfo (range 10) (ordType 5) id = Real.logb 2 5 - 8 / 5 := by
  rw [CyclicSubfield.subfield_full_pinning (m := 5) (n := 10) (by norm_num) (by norm_num)
    (by norm_num), control_C5_typeEntropy]

/-- The control's dial is the full unit group: `H(p mod 11) = log₂ 10`. -/
theorem control_C5_dial : uEnt (range 10) id = 1 + Real.logb 2 5 := by
  have huniform : ∀ a ∈ range 10, #{x ∈ range 10 | id x = id a} = 1 := by decide
  rw [uEnt_eq_logb_of_uniform_fibers ⟨0, by decide⟩ huniform]
  norm_num [lbq_10]

/-- **The control row of the law table.**  The `C₅` loss is `13/5 = 2.6` bits: everything
the dial knows beyond the type, and the channel is saturated at `H(T)`. -/
theorem control_C5_loss :
    uEnt (range 10) id - mutInfo (range 10) (ordType 5) id = 13 / 5 := by
  rw [control_C5_dial, control_C5_pinned]; ring

/-- **The contrast that makes the law a law.**  Both fields have degree 5 and both obey
`I(dial ; T) = H(dial) - (merged-coset entropy)`; but the abelian control loses everything
the type already tells it (`13/5`), while the non-abelian `F₂₀` loses exactly the half bit
of the two merged order-4 cosets.  In particular the `F₂₀` channel transmits strictly more
than the `C₅` one. -/
theorem quintic_beats_control :
    mutInfo (range 10) (ordType 5) id < mutInfo qFrob qType qDial := by
  rw [control_C5_pinned, abelianization_law_degree_five]
  have := lb_five_lt
  linarith

end QuinticF20