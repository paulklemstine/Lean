import Geometry.AGL8Channel.PrimeChannel

/-!
# The semiprime type channel of `AGL(1,8)`: `I₂ = 0.1141` bits, `4.06 %` of the cap

A semiprime `N = p q` presents two independent Frobenius elements `(x, y) ∈ G × G`
(Chebotarev: uniform on the 3136 ordered pairs).  The residue of `N` sees the
abelianization coset of the *product* `xy`, and the splitting experiment reads off the
*unordered* pair of cycle types `{T x, T y}` (one cannot tell which factor is which).

## Main results

* `semi_channel_params` — transport of the channel to the parameter square.
* `agl8_semiprime_channel` — **`I(coset(xy) ; {Tx, Ty}) = log₂ 7 - (78/49) log₂ 6 + (30/49) log₂ 5`**.
* `agl8_semiprime_ordered` — the *ordered* readout `(Tx, Ty)` gives exactly the same value:
  forgetting the order of the factors costs nothing here.
* `agl8_semiprime_bracket` — `0.11409 < I₂ < 0.11412`.
* `agl8_semiprime_fraction` — `I₂` realises strictly between `4.06 %` and `4.07 %` of the
  `log₂ 7` cap.
* `agl8_chain` — the full consistency chain `0 < I₂ < I₁ < cap`, with
  `agl8_pairing_loses_four_fifths` — pairing destroys more than `4/5` of the prime channel.
-/

namespace AGL8

open Finset Real TypeChannel

/-! ## 1. The semiprime sample space and readouts -/

/-- The three cycle types, as values of `typeCode`. -/
abbrev t0 : Multiset ℕ := 0
/-- The cycle type `[2⁴]` of a non-trivial translation. -/
abbrev t2 : Multiset ℕ := {2, 2, 2, 2}
/-- The cycle type `[1,7]` of an element with non-trivial multiplier. -/
abbrev t7 : Multiset ℕ := {7}

/-- The residue readout of a semiprime: the abelianization coset of the product `xy`. -/
def semiCoset (z : Equiv.Perm (Fin 8) × Equiv.Perm (Fin 8)) : Fin 7 := aglCoset (z.1 * z.2)

/-- The unordered pair of splitting types `{T x, T y}`. -/
def semiType (z : Equiv.Perm (Fin 8) × Equiv.Perm (Fin 8)) : Sym2 (Multiset ℕ) :=
  s(aglType z.1, aglType z.2)

/-- The ordered pair of splitting types `(T x, T y)`. -/
def semiTypeOrd (z : Equiv.Perm (Fin 8) × Equiv.Perm (Fin 8)) : Multiset ℕ × Multiset ℕ :=
  (aglType z.1, aglType z.2)

/-- The parametrisation of `G × G`. -/
def affPP (z : (Fin 7 × Fin 8) × (Fin 7 × Fin 8)) : Equiv.Perm (Fin 8) × Equiv.Perm (Fin 8) :=
  (affP z.1, affP z.2)

lemma affPP_inj : Function.Injective affPP := by
  rintro ⟨z1, z2⟩ ⟨w1, w2⟩ h
  simp only [affPP, Prod.mk.injEq] at h
  rw [aff_inj h.1, aff_inj h.2]

lemma pairSpace_eq : aglSet ×ˢ aglSet = (params ×ˢ params).image affPP := by
  ext ⟨σ, τ⟩
  simp only [mem_product, aglSet, mem_image, affPP, params, mem_univ, true_and, Prod.mk.injEq,
    Prod.exists]
  constructor
  · rintro ⟨⟨e, b, h1⟩, ⟨e', b', h2⟩⟩
    exact ⟨e, b, e', b', h1, h2⟩
  · rintro ⟨e, b, e', b', h1, h2⟩
    exact ⟨⟨e, b, h1⟩, ⟨e', b', h2⟩⟩

lemma pairParams_card : (params ×ˢ params).card = 3136 := by
  rw [card_product, params_card]

/-- Coverage hypotheses on the parameter square, checked coordinate-wise. -/
lemma cover_of_forall {β : Type*} (f : (Fin 7 × Fin 8) × (Fin 7 × Fin 8) → β) (A : List β)
    (h : ∀ e e' : Fin 7, ∀ b b' : Fin 8, f ((e, b), (e', b')) ∈ A) :
    ∀ w ∈ params ×ˢ params, f w ∈ A := by
  rintro ⟨⟨e, b⟩, ⟨e', b'⟩⟩ _
  exact h e e' b b'

lemma semiCoset_comp : semiCoset ∘ affPP = fun z => z.1.1 + z.2.1 := by
  funext z
  simp only [Function.comp, semiCoset, affPP, affP]
  rw [aff_mul, aglCoset_aff]

lemma semiType_comp : semiType ∘ affPP = fun z => s(typeCode z.1, typeCode z.2) := by
  funext z
  simp only [Function.comp, semiType, affPP, affP, aglType_aff]

lemma semiTypeOrd_comp : semiTypeOrd ∘ affPP = fun z => (typeCode z.1, typeCode z.2) := by
  funext z
  simp only [Function.comp, semiTypeOrd, affPP, affP, aglType_aff]

/-- The semiprime channel on `G × G` equals the channel on the parameter square. -/
lemma semi_channel_params :
    mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType =
      mutualInfo (params ×ˢ params) (fun z => z.1.1 + z.2.1)
        (fun z => s(typeCode z.1, typeCode z.2)) := by
  rw [pairSpace_eq, mutualInfo_image_of_injOn _ affPP affPP_inj.injOn, semiCoset_comp,
    semiType_comp]

lemma semi_channel_params_ord :
    mutualInfo (aglSet ×ˢ aglSet) semiCoset semiTypeOrd =
      mutualInfo (params ×ˢ params) (fun z => z.1.1 + z.2.1)
        (fun z => (typeCode z.1, typeCode z.2)) := by
  rw [pairSpace_eq, mutualInfo_image_of_injOn _ affPP affPP_inj.injOn, semiCoset_comp,
    semiTypeOrd_comp]

/-! ## 2. The three entropies -/

set_option maxHeartbeats 2000000 in
/-- The product coset is uniform on `C₇`: `H = log₂ 7`. -/
lemma semi_coset_entropy :
    entropy (params ×ˢ params) (fun z => z.1.1 + z.2.1) = logb 2 7 := by
  rw [entropy_eq_sumList (A := [(0 : Fin 7), 1, 2, 3, 4, 5, 6])
    (L := [448, 448, 448, 448, 448, 448, 448]) (by decide +kernel) (cover_of_forall _ _ (by decide +kernel)) (by decide +kernel),
    pairParams_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 448 3136 (by norm_num) (by norm_num), lb_decomp 448 6 0 0 1 (by norm_num),
    lb_decomp 3136 6 0 0 2 (by norm_num)]
  push_cast
  ring

set_option maxHeartbeats 2000000 in
/-- The unordered type pair: counts `1 : 14 : 49 : 96 : 672 : 2304`. -/
lemma semi_type_entropy :
    entropy (params ×ˢ params) (fun z => s(typeCode z.1, typeCode z.2)) =
      1 / 3136 * (6 + 2 * logb 2 7) + 14 / 3136 * (5 + logb 2 7)
      + 49 / 3136 * 6 + 96 / 3136 * (1 - logb 2 3 + 2 * logb 2 7)
      + 672 / 3136 * (1 - logb 2 3 + logb 2 7) + 2304 / 3136 * (2 * logb 2 7 - 2 - 2 * logb 2 3)
      := by
  rw [entropy_eq_sumList (A := [s(t0, t0), s(t0, t2), s(t2, t2), s(t0, t7), s(t2, t7), s(t7, t7)])
    (L := [1, 14, 49, 96, 672, 2304]) (by decide +kernel) (cover_of_forall _ _ (by decide +kernel)) (by decide +kernel),
    pairParams_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 1 3136 (by norm_num) (by norm_num), negTerm 14 3136 (by norm_num) (by norm_num),
    negTerm 49 3136 (by norm_num) (by norm_num), negTerm 96 3136 (by norm_num) (by norm_num),
    negTerm 672 3136 (by norm_num) (by norm_num), negTerm 2304 3136 (by norm_num) (by norm_num),
    lb_decomp 3136 6 0 0 2 (by norm_num), lb_decomp 1 0 0 0 0 (by norm_num),
    lb_decomp 14 1 0 0 1 (by norm_num), lb_decomp 49 0 0 0 2 (by norm_num),
    lb_decomp 96 5 1 0 0 (by norm_num), lb_decomp 672 5 1 0 1 (by norm_num),
    lb_decomp 2304 8 2 0 0 (by norm_num)]
  push_cast
  ring

set_option maxHeartbeats 2000000 in
/-- The joint (product coset, unordered type pair): 22 cells. -/
lemma semi_joint_entropy :
    entropy (params ×ˢ params) (pairObs (fun z => z.1.1 + z.2.1)
        (fun z => s(typeCode z.1, typeCode z.2))) =
      1 / 3136 * (6 + 2 * logb 2 7) + 14 / 3136 * (5 + logb 2 7)
      + 96 / 3136 * (2 + 2 * logb 2 7) + 49 / 3136 * 6
      + 672 / 3136 * (2 + logb 2 7) + 384 / 3136 * (-1 - logb 2 3 + 2 * logb 2 7)
      + 1920 / 3136 * (2 * logb 2 7 - logb 2 5) := by
  rw [entropy_eq_sumList
    (A := [((0 : Fin 7), s(t0, t0)), ((0 : Fin 7), s(t0, t2)), ((1 : Fin 7), s(t0, t7)),
      ((2 : Fin 7), s(t0, t7)), ((3 : Fin 7), s(t0, t7)), ((4 : Fin 7), s(t0, t7)),
      ((5 : Fin 7), s(t0, t7)), ((6 : Fin 7), s(t0, t7)), ((0 : Fin 7), s(t2, t2)),
      ((1 : Fin 7), s(t2, t7)), ((2 : Fin 7), s(t2, t7)), ((3 : Fin 7), s(t2, t7)),
      ((4 : Fin 7), s(t2, t7)), ((5 : Fin 7), s(t2, t7)), ((6 : Fin 7), s(t2, t7)),
      ((0 : Fin 7), s(t7, t7)), ((1 : Fin 7), s(t7, t7)), ((2 : Fin 7), s(t7, t7)),
      ((3 : Fin 7), s(t7, t7)), ((4 : Fin 7), s(t7, t7)), ((5 : Fin 7), s(t7, t7)),
      ((6 : Fin 7), s(t7, t7))])
    (L := [1, 14, 16, 16, 16, 16, 16, 16, 49, 112, 112, 112, 112, 112, 112, 384, 320, 320, 320,
      320, 320, 320]) (by decide +kernel) (cover_of_forall _ _ (by decide +kernel)) (by decide +kernel), pairParams_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 1 3136 (by norm_num) (by norm_num), negTerm 14 3136 (by norm_num) (by norm_num),
    negTerm 16 3136 (by norm_num) (by norm_num), negTerm 49 3136 (by norm_num) (by norm_num),
    negTerm 112 3136 (by norm_num) (by norm_num), negTerm 384 3136 (by norm_num) (by norm_num),
    negTerm 320 3136 (by norm_num) (by norm_num),
    lb_decomp 3136 6 0 0 2 (by norm_num), lb_decomp 1 0 0 0 0 (by norm_num),
    lb_decomp 14 1 0 0 1 (by norm_num), lb_decomp 16 4 0 0 0 (by norm_num),
    lb_decomp 49 0 0 0 2 (by norm_num), lb_decomp 112 4 0 0 1 (by norm_num),
    lb_decomp 384 7 1 0 0 (by norm_num), lb_decomp 320 6 0 1 0 (by norm_num)]
  push_cast
  ring

/-! ## 3. The semiprime channel -/

/-- **THE `AGL(1,8)` SEMIPRIME CHANNEL.**  Over all `56² = 3136` ordered pairs of elements of
the genuine group `AGL(1,8)`, the unordered pair of cycle types carries

  `I(coset(xy) ; {Tx, Ty}) = log₂ 7 - (78/49) log₂ 6 + (30/49) log₂ 5 = 0.1141…`

bits about the abelianization coset of the product. -/
theorem agl8_semiprime_channel :
    mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType =
      logb 2 7 - 78 / 49 * logb 2 6 + 30 / 49 * logb 2 5 := by
  rw [semi_channel_params, mutualInfo, semi_coset_entropy, semi_type_entropy,
    semi_joint_entropy, l6_eq]
  ring

set_option maxHeartbeats 2000000 in
/-- The ordered type pair: counts `1 : 7 : 7 : 49 : 48 : 48 : 336 : 336 : 2304`. -/
lemma semi_type_entropy_ord :
    entropy (params ×ˢ params) (fun z => (typeCode z.1, typeCode z.2)) =
      1 / 3136 * (6 + 2 * logb 2 7) + 14 / 3136 * (6 + logb 2 7)
      + 49 / 3136 * 6 + 96 / 3136 * (2 - logb 2 3 + 2 * logb 2 7)
      + 672 / 3136 * (2 - logb 2 3 + logb 2 7) + 2304 / 3136 * (2 * logb 2 7 - 2 - 2 * logb 2 3)
      := by
  rw [entropy_eq_sumList (A := [(t0, t0), (t0, t2), (t2, t0), (t2, t2), (t0, t7), (t7, t0),
      (t2, t7), (t7, t2), (t7, t7)])
    (L := [1, 7, 7, 49, 48, 48, 336, 336, 2304]) (by decide +kernel) (cover_of_forall _ _ (by decide +kernel)) (by decide +kernel),
    pairParams_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 1 3136 (by norm_num) (by norm_num), negTerm 7 3136 (by norm_num) (by norm_num),
    negTerm 49 3136 (by norm_num) (by norm_num), negTerm 48 3136 (by norm_num) (by norm_num),
    negTerm 336 3136 (by norm_num) (by norm_num), negTerm 2304 3136 (by norm_num) (by norm_num),
    lb_decomp 3136 6 0 0 2 (by norm_num), lb_decomp 1 0 0 0 0 (by norm_num),
    lb_decomp 7 0 0 0 1 (by norm_num), lb_decomp 49 0 0 0 2 (by norm_num),
    lb_decomp 48 4 1 0 0 (by norm_num), lb_decomp 336 4 1 0 1 (by norm_num),
    lb_decomp 2304 8 2 0 0 (by norm_num)]
  push_cast
  ring

set_option maxHeartbeats 2000000 in
/-- The joint (product coset, ordered type pair): 35 cells. -/
lemma semi_joint_entropy_ord :
    entropy (params ×ˢ params) (pairObs (fun z => z.1.1 + z.2.1)
        (fun z => (typeCode z.1, typeCode z.2))) =
      1 / 3136 * (6 + 2 * logb 2 7) + 14 / 3136 * (6 + logb 2 7)
      + 96 / 3136 * (3 + 2 * logb 2 7) + 49 / 3136 * 6
      + 672 / 3136 * (3 + logb 2 7) + 384 / 3136 * (-1 - logb 2 3 + 2 * logb 2 7)
      + 1920 / 3136 * (2 * logb 2 7 - logb 2 5) := by
  rw [entropy_eq_sumList
    (A := [((0 : Fin 7), (t0, t0)), ((0 : Fin 7), (t0, t2)), ((1 : Fin 7), (t0, t7)),
      ((2 : Fin 7), (t0, t7)), ((3 : Fin 7), (t0, t7)), ((4 : Fin 7), (t0, t7)),
      ((5 : Fin 7), (t0, t7)), ((6 : Fin 7), (t0, t7)), ((0 : Fin 7), (t2, t0)),
      ((0 : Fin 7), (t2, t2)), ((1 : Fin 7), (t2, t7)), ((2 : Fin 7), (t2, t7)),
      ((3 : Fin 7), (t2, t7)), ((4 : Fin 7), (t2, t7)), ((5 : Fin 7), (t2, t7)),
      ((6 : Fin 7), (t2, t7)), ((1 : Fin 7), (t7, t0)), ((2 : Fin 7), (t7, t0)),
      ((3 : Fin 7), (t7, t0)), ((4 : Fin 7), (t7, t0)), ((5 : Fin 7), (t7, t0)),
      ((6 : Fin 7), (t7, t0)), ((1 : Fin 7), (t7, t2)), ((2 : Fin 7), (t7, t2)),
      ((3 : Fin 7), (t7, t2)), ((4 : Fin 7), (t7, t2)), ((5 : Fin 7), (t7, t2)),
      ((6 : Fin 7), (t7, t2)), ((0 : Fin 7), (t7, t7)), ((1 : Fin 7), (t7, t7)),
      ((2 : Fin 7), (t7, t7)), ((3 : Fin 7), (t7, t7)), ((4 : Fin 7), (t7, t7)),
      ((5 : Fin 7), (t7, t7)), ((6 : Fin 7), (t7, t7))])
    (L := [1, 7, 8, 8, 8, 8, 8, 8, 7, 49, 56, 56, 56, 56, 56, 56, 8, 8, 8, 8, 8, 8, 56, 56, 56,
      56, 56, 56, 384, 320, 320, 320, 320, 320, 320]) (by decide +kernel) (cover_of_forall _ _ (by decide +kernel))
    (by decide +kernel), pairParams_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 1 3136 (by norm_num) (by norm_num), negTerm 7 3136 (by norm_num) (by norm_num),
    negTerm 8 3136 (by norm_num) (by norm_num), negTerm 49 3136 (by norm_num) (by norm_num),
    negTerm 56 3136 (by norm_num) (by norm_num), negTerm 384 3136 (by norm_num) (by norm_num),
    negTerm 320 3136 (by norm_num) (by norm_num),
    lb_decomp 3136 6 0 0 2 (by norm_num), lb_decomp 1 0 0 0 0 (by norm_num),
    lb_decomp 7 0 0 0 1 (by norm_num), lb_decomp 8 3 0 0 0 (by norm_num),
    lb_decomp 49 0 0 0 2 (by norm_num), lb_decomp 56 3 0 0 1 (by norm_num),
    lb_decomp 384 7 1 0 0 (by norm_num), lb_decomp 320 6 0 1 0 (by norm_num)]
  push_cast
  ring

/-- **Order of the factors is irrelevant.**  The ordered readout `(Tx, Ty)` transmits exactly
as much as the unordered one: the extra bit of "which factor has which type" is independent
of the product coset. -/
theorem agl8_semiprime_ordered :
    mutualInfo (aglSet ×ˢ aglSet) semiCoset semiTypeOrd =
      mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType := by
  rw [agl8_semiprime_channel, semi_channel_params_ord, mutualInfo, semi_coset_entropy,
    semi_type_entropy_ord, semi_joint_entropy_ord, l6_eq]
  ring

/-- Numerical bracket: `0.11409 < I₂ < 0.11412`. -/
theorem agl8_semiprime_bracket :
    (0.11409 : ℝ) < mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType ∧
      mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType < 0.11412 := by
  rw [agl8_semiprime_channel, l6_eq]
  have := l3_gt; have := l3_lt; have := l5_gt; have := l5_lt; have := l7_gt; have := l7_lt
  constructor <;> linarith

/-- **Cap fraction.**  The semiprime channel realises strictly between `4.06 %` and `4.07 %`
of the `log₂ 7` cap — the smallest fraction in the catalog's table. -/
theorem agl8_semiprime_fraction :
    (0.0406 : ℝ) < mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType / entropy aglSet aglCoset ∧
      mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType / entropy aglSet aglCoset < 0.0407 := by
  rw [agl8_semiprime_channel, agl8_cap, l6_eq]
  have := l3_gt; have := l3_lt; have := l5_gt; have := l5_lt; have := l7_gt; have := l7_lt
  have hp : (0 : ℝ) < logb 2 7 := by linarith
  constructor
  · rw [lt_div_iff₀ hp]; linarith
  · rw [div_lt_iff₀ hp]; linarith

/-- **The consistency chain** `0 < I₂ < I₁ < cap` for `AGL(1,8)`. -/
theorem agl8_chain :
    0 < mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType ∧
    mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType < mutualInfo aglSet aglCoset aglType ∧
    mutualInfo aglSet aglCoset aglType < entropy aglSet aglCoset := by
  have h1 := agl8_semiprime_bracket
  have h2 := agl8_prime_bracket
  refine ⟨by linarith, by linarith, ?_⟩
  rw [agl8_cap]
  have := l7_gt
  linarith

/-- **Pairing destroys more than four fifths of the prime channel**: `5 I₂ < I₁`. -/
theorem agl8_pairing_loses_four_fifths :
    5 * mutualInfo (aglSet ×ˢ aglSet) semiCoset semiType < mutualInfo aglSet aglCoset aglType := by
  have h1 := agl8_semiprime_bracket
  have h2 := agl8_prime_bracket
  linarith

end AGL8