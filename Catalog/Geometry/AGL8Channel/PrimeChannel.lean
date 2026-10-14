import Geometry.AGL8Channel.Group

/-!
# The prime-level type channel of `AGL(1,8)`: `I₁ = h(1/7) = 0.5917` bits

`Geometry.AGL8Channel.Group` builds `AGL(1,8)` inside `Sym(𝔽₈)` together with its
abelianization readout `aglCoset : G → C₇` and its splitting-type readout
`aglType = cycleType`.  Here we evaluate the channel *exactly*, on the group itself (all 56
elements, uniform Chebotarev measure), with the finite Shannon calculus of
`Cryptography.NonabelianTypeChannel.Entropy`.

## Main results

* `mutualInfo_image_of_injOn` — transport of the channel calculus along an injective
  parametrisation (used to move from permutations to parameters `(e, b)`).
* `agl8_cap` — `H(coset) = log₂ 7`: the cap is `log₂ |G^ab| = log₂ 7 = 2.807…`, the largest
  of the catalog (via the catalog's `entropy_cosetReadout`).
* `agl8_prime_channel` — **`I(coset ; T) = log₂ 7 - (6/7) log₂ 6`**.
* `agl8_prime_channel_binary` — equivalently `I₁ = h(1/7)`, the binary entropy of the
  event "the coset is trivial": the cycle type of `AGL(1,8)` detects *only* whether the
  multiplier is `1`.
* `agl8_prime_loss` — the deficit `H(coset | T) = (6/7) log₂ 6`, through the catalog's
  `loss_eq`, and `agl8_loss_eq_totient_sum` — this is exactly the catalog's conjectured
  totient formula `aglLoss 8` (`Bridges.AffineFrobeniusLadderAGL7`), now confirmed on a
  genuine group at the first even-characteristic rung.
* `agl8_prime_bracket` — `0.59166 < I₁ < 0.59168`, and `agl8_prime_fraction` — the channel
  realises less than `21.1 %` of its cap.
* `affine_ladder_collapse` — **the ladder reversal**: going from `AGL(1,7)`
  (`|G^ab| = 6`, `I₁ = 1/3 + log₂ 3 = 1.918`) to `AGL(1,8)` (`|G^ab| = 7`) the cap grows but the
  channel drops by more than a factor of three.
-/

namespace AGL8

open Finset Real TypeChannel

/-! ## 0. Transport along an injective parametrisation -/

section Transport

variable {Ω' Ω α β : Type*} [DecidableEq Ω] [DecidableEq α] [DecidableEq β]

/-- The entropy of a readout on an injectively parametrised sample space can be computed
on the parameters. -/
lemma entropy_image_of_injOn (U : Finset Ω') (φ : Ω' → Ω) (hφ : Set.InjOn φ U)
    (f : Ω → α) : entropy (U.image φ) f = entropy U (f ∘ φ) := by
  unfold entropy prob fiber
  rw [image_image, card_image_of_injOn hφ]
  refine sum_congr rfl (fun a _ => ?_)
  rw [filter_image, card_image_of_injOn (hφ.mono (coe_subset.mpr (filter_subset _ _)))]
  rfl

/-- The mutual information transports along an injective parametrisation. -/
lemma mutualInfo_image_of_injOn (U : Finset Ω') (φ : Ω' → Ω) (hφ : Set.InjOn φ U)
    (f : Ω → α) (g : Ω → β) : mutualInfo (U.image φ) f g = mutualInfo U (f ∘ φ) (g ∘ φ) := by
  unfold mutualInfo
  rw [entropy_image_of_injOn U φ hφ, entropy_image_of_injOn U φ hφ,
    entropy_image_of_injOn U φ hφ]
  rfl

end Transport

/-! ## 1. Logarithm bookkeeping -/

/-- Every count occurring below is `2ⁱ 3ʲ 5ᵏ 7ˡ`. -/
lemma lb_decomp (n i j k l : ℕ) (h : n = 2 ^ i * 3 ^ j * 5 ^ k * 7 ^ l) :
    logb 2 (n : ℝ) = i + j * logb 2 3 + k * logb 2 5 + l * logb 2 7 := by
  rw [h]
  push_cast
  rw [logb_mul (by positivity) (by positivity), logb_mul (by positivity) (by positivity),
    logb_mul (by positivity) (by positivity), logb_pow, logb_pow, logb_pow, logb_pow,
    logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
  ring

/-- One summand of an entropy, rewritten as `p · (log₂ N - log₂ c)`. -/
lemma negTerm (c N : ℕ) (hc : 0 < c) (hN : 0 < N) :
    -((c : ℝ) / N * logb 2 ((c : ℝ) / N)) = (c : ℝ) / N * (logb 2 N - logb 2 c) := by
  rw [logb_div (by positivity) (by positivity)]
  ring

/-- Lower bounds `p/q < log₂ b` from `2^p < b^q`. -/
lemma lt_logb_of_pow {b p q : ℕ} (hq : 0 < q) (h : 2 ^ p < b ^ q) :
    (p : ℝ) / q < logb 2 b := by
  have hb : 0 < b := by
    rcases Nat.eq_zero_or_pos b with rfl | hb
    · simp [Nat.zero_pow hq] at h
    · exact hb
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hlt : ((2 : ℝ)) ^ p < ((b : ℝ)) ^ q := by exact_mod_cast h
  have hl : Real.log ((2 : ℝ) ^ p) < Real.log ((b : ℝ) ^ q) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at hl
  rw [logb, div_lt_div_iff₀ (by exact_mod_cast hq) h2]
  nlinarith

/-- Upper bounds `log₂ b < p/q` from `b^q < 2^p`. -/
lemma logb_lt_of_pow {b p q : ℕ} (hb : 0 < b) (hq : 0 < q) (h : b ^ q < 2 ^ p) :
    logb 2 b < (p : ℝ) / q := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hlt : ((b : ℝ)) ^ q < ((2 : ℝ)) ^ p := by exact_mod_cast h
  have hl : Real.log ((b : ℝ) ^ q) < Real.log ((2 : ℝ) ^ p) :=
    Real.log_lt_log (by positivity) hlt
  rw [Real.log_pow, Real.log_pow] at hl
  rw [logb, div_lt_div_iff₀ h2 (by exact_mod_cast hq)]
  nlinarith

lemma l3_gt : (1054 : ℝ) / 665 < logb 2 3 := by
  have := lt_logb_of_pow (b := 3) (p := 1054) (q := 665) (by norm_num) (by decide +kernel)
  exact_mod_cast this

lemma l3_lt : logb 2 3 < (485 : ℝ) / 306 := by
  have := logb_lt_of_pow (b := 3) (p := 485) (q := 306) (by norm_num) (by norm_num) (by decide +kernel)
  exact_mod_cast this

lemma l5_gt : (9297 : ℝ) / 4004 < logb 2 5 := by
  have := lt_logb_of_pow (b := 5) (p := 9297) (q := 4004) (by norm_num) (by decide +kernel)
  exact_mod_cast this

lemma l5_lt : logb 2 5 < (1493 : ℝ) / 643 := by
  have := logb_lt_of_pow (b := 5) (p := 1493) (q := 643) (by norm_num) (by norm_num) (by decide +kernel)
  exact_mod_cast this

lemma l7_gt : (6718 : ℝ) / 2393 < logb 2 7 := by
  have := lt_logb_of_pow (b := 7) (p := 6718) (q := 2393) (by norm_num) (by decide +kernel)
  exact_mod_cast this

lemma l7_lt : logb 2 7 < (1603 : ℝ) / 571 := by
  have := logb_lt_of_pow (b := 7) (p := 1603) (q := 571) (by norm_num) (by norm_num) (by decide +kernel)
  exact_mod_cast this

lemma l6_eq : logb 2 (6 : ℝ) = 1 + logb 2 3 := by
  have := lb_decomp 6 1 1 0 0 (by norm_num)
  push_cast at this; rw [this]; ring

/-! ## 2. The channel on the parameters -/

/-- The binary entropy function, in bits. -/
noncomputable def binEnt (p : ℝ) : ℝ := -(p * logb 2 p) - (1 - p) * logb 2 (1 - p)

lemma params_card : params.card = 56 := rfl

lemma aglCoset_comp : aglCoset ∘ affP = Prod.fst := by
  funext p; exact aglCoset_aff p.1 p.2

lemma aglType_comp : aglType ∘ affP = typeCode := by
  funext p; exact aglType_aff p.1 p.2

/-- The channel on the group equals the channel on the parameters `(e, b)`. -/
lemma agl8_channel_params :
    mutualInfo aglSet aglCoset aglType = mutualInfo params Prod.fst typeCode := by
  rw [aglSet, mutualInfo_image_of_injOn params affP aff_inj.injOn, aglCoset_comp,
    aglType_comp]

/-- **The cap.**  `H(coset) = log₂ 7`, from the catalog's Lagrange computation
`entropy_cosetReadout` applied to the derived-subgroup certificate. -/
theorem agl8_cap : entropy aglSet aglCoset = logb 2 7 := by
  rw [entropy_cosetReadout aglSet_isSubgroup transSet_isSubgroup aglDerived.subset
    aglCoset_isCosetReadout, aglCoset_image_card]
  norm_num

/-- The Chebotarev distribution of the three cycle types: `1 : 7 : 48`. -/
theorem agl8_type_entropy :
    entropy params typeCode = 6 / 7 * (logb 2 7 - 1 - logb 2 3) + 3 / 8
      + 1 / 56 * (3 + logb 2 7) := by
  rw [entropy_eq_sumList (A := [0, {2, 2, 2, 2}, {7}]) (L := [1, 7, 48]) (by decide)
    (by decide) (by decide), params_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 1 56 (by norm_num) (by norm_num), negTerm 7 56 (by norm_num) (by norm_num),
    negTerm 48 56 (by norm_num) (by norm_num), lb_decomp 56 3 0 0 1 (by norm_num),
    lb_decomp 1 0 0 0 0 (by norm_num), lb_decomp 7 0 0 0 1 (by norm_num),
    lb_decomp 48 4 1 0 0 (by norm_num)]
  push_cast
  ring

/-- The joint distribution of (coset, type): `(0,[1⁸])`, `(0,[2⁴])` and `(k,[1,7])`. -/
theorem agl8_joint_entropy :
    entropy params (pairObs Prod.fst typeCode) = 1 / 56 * (3 + logb 2 7) + 1 / 8 * 3
      + 6 / 7 * logb 2 7 := by
  rw [entropy_eq_sumList
    (A := [((0 : Fin 7), (0 : Multiset ℕ)), (0, {2, 2, 2, 2}), (1, {7}), (2, {7}), (3, {7}),
      (4, {7}), (5, {7}), (6, {7})]) (L := [1, 7, 8, 8, 8, 8, 8, 8]) (by decide)
    (by decide) (by decide), params_card]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil]
  rw [negTerm 1 56 (by norm_num) (by norm_num), negTerm 7 56 (by norm_num) (by norm_num),
    negTerm 8 56 (by norm_num) (by norm_num), lb_decomp 56 3 0 0 1 (by norm_num),
    lb_decomp 1 0 0 0 0 (by norm_num), lb_decomp 7 0 0 0 1 (by norm_num),
    lb_decomp 8 3 0 0 0 (by norm_num)]
  push_cast
  ring

/-! ## 3. The prime channel -/

/-- **THE `AGL(1,8)` PRIME CHANNEL.**  On the genuine group `AGL(1,8) ⊆ Sym(𝔽₈)`, with the
cycle type as splitting-type readout and the abelianization `G → C₇` as residue readout,

  `I(coset ; T) = log₂ 7 - (6/7) log₂ 6 = 0.5917…` bits. -/
theorem agl8_prime_channel :
    mutualInfo aglSet aglCoset aglType = logb 2 7 - 6 / 7 * logb 2 6 := by
  have hc : entropy params Prod.fst = logb 2 7 := by
    rw [← agl8_cap, aglSet, entropy_image_of_injOn params affP aff_inj.injOn, aglCoset_comp]
  rw [agl8_channel_params, mutualInfo, hc, agl8_type_entropy, agl8_joint_entropy, l6_eq]
  ring

/-- **The detector form.**  `I₁ = h(1/7)`: the cycle type of `AGL(1,8)` reveals exactly
one binary event — "is the multiplier trivial?" — which has probability `1/7`. -/
theorem agl8_prime_channel_binary :
    mutualInfo aglSet aglCoset aglType = binEnt (1 / 7) := by
  rw [agl8_prime_channel, binEnt]
  have h1 : logb 2 (1 / 7 : ℝ) = - logb 2 7 := by
    rw [one_div, logb_inv]
  have h2 : logb 2 (1 - 1 / 7 : ℝ) = logb 2 6 - logb 2 7 := by
    rw [show (1 - 1 / 7 : ℝ) = 6 / 7 by norm_num, logb_div (by norm_num) (by norm_num)]
  rw [h1, h2]
  ring

/-- **The loss column.**  Through the catalog's `loss_eq`, the deficit of the cap is the
conditional entropy `H(coset | T) = (6/7) log₂ 6`: all six non-trivial cosets share the
single cycle type `[1,7]` and are completely merged. -/
theorem agl8_prime_loss :
    condEntropy aglSet aglCoset aglType = 6 / 7 * logb 2 6 := by
  have h := loss_eq aglSet_isSubgroup transSet_isSubgroup aglDerived.subset
    aglCoset_isCosetReadout aglType
  rw [aglCoset_image_card, agl8_prime_channel] at h
  rw [← h]
  push_cast
  ring

/-- **The catalog's totient formula holds at `q = 8`.**  `Bridges.AffineFrobeniusLadderAGL7`
conjectured that the loss of `AGL(1,q)` is
`aglLoss q = ∑_{d ∣ q-1, d>1} (φ(d)/(q-1)) log₂ φ(d)` (checked there at `q = 5, 7` on
`ℕ`-coded models).  We state that sum verbatim at `q = 8` (the module itself is not imported:
its import chain currently mixes the `Catalog.`-prefixed and unprefixed module conventions)
and show it equals the loss of the genuine permutation group. -/
theorem agl8_loss_eq_totient_sum :
    condEntropy aglSet aglCoset aglType =
      ∑ d ∈ (Nat.divisors (8 - 1)).erase 1,
        ((Nat.totient d : ℝ) / ((8 : ℝ) - 1)) * logb 2 (Nat.totient d : ℝ) := by
  rw [agl8_prime_loss]
  have hd : (Nat.divisors (8 - 1)).erase 1 = ({7} : Finset ℕ) := by decide
  rw [hd, sum_singleton, show Nat.totient 7 = 6 from by decide]
  norm_num

/-- Numerical bracket: `0.59166 < I₁ < 0.59168`. -/
theorem agl8_prime_bracket :
    (0.59166 : ℝ) < mutualInfo aglSet aglCoset aglType ∧
      mutualInfo aglSet aglCoset aglType < 0.59168 := by
  rw [agl8_prime_channel, l6_eq]
  have := l3_gt; have := l3_lt; have := l7_gt; have := l7_lt
  constructor <;> linarith

/-- **Cap fraction.**  The prime channel realises strictly between `21.07 %` and `21.08 %`
of the `log₂ 7` cap. -/
theorem agl8_prime_fraction :
    (0.2107 : ℝ) < mutualInfo aglSet aglCoset aglType / entropy aglSet aglCoset ∧
      mutualInfo aglSet aglCoset aglType / entropy aglSet aglCoset < 0.2108 := by
  rw [agl8_prime_channel, agl8_cap, l6_eq]
  have := l3_gt; have := l3_lt; have := l7_gt; have := l7_lt
  have hp : (0 : ℝ) < logb 2 7 := by linarith
  constructor
  · rw [lt_div_iff₀ hp]; linarith
  · rw [div_lt_iff₀ hp]; linarith

/-- **The affine-ladder collapse.**  The catalog's `abelianization_law_degree_seven`
(`Bridges.AffineFrobeniusLadderAGL7`) gives `AGL(1,7)` — abelianization `C₆`, cap `log₂ 6` —
the channel `1/3 + log₂ 3 > 1.91` bits.  `AGL(1,8)` has the strictly larger cap `log₂ 7` but
transmits less than a third of that.  Channel size is *anti*-correlated with the cap along the
affine ladder. -/
theorem affine_ladder_collapse :
    logb 2 6 < entropy aglSet aglCoset ∧
    3 * mutualInfo aglSet aglCoset aglType < 1 / 3 + logb 2 3 := by
  rw [agl8_cap, agl8_prime_channel, l6_eq]
  have := l3_gt; have := l3_lt; have := l7_gt; have := l7_lt
  constructor <;> linarith

end AGL8