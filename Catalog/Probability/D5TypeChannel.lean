import Mathlib
import Probability.D5TypeChannelCore

/-!
# THE-D5-DIAL-IS-MEASURED: the D5 splitting-type channel at conductor `m* = 320`

## Research context (FACT round-33 #3, paper 118, 448 experiments, assessment v228)

For a quintic field `K` with Galois group `D₅` (the dihedral group of order 10),
the splitting type `T(p)` of an unramified prime is read off from its Frobenius
class: `1⁵` (identity, density `1/10`), `5` (the four rotations, density `4/10`),
`1·2²` (the five reflections, density `5/10`).  The experiment measured, at the
verified conductor `m* = 320 = 2⁶·5`:

* prime channel:     `I(p mod 320 ; T) = 1.0054` bits (`z = +338`);
* semiprime channel: `I(N mod 320 ; (T(p),T(q))) = 1.0054` bits;
* `H(T) = 1.3517`, within-class entropy `H(T | p mod 320) = 0.3463`.

## What is proved here

The residue `p mod m` only sees Frobenius through the abelian quotient of the
compositum `K(ζ_m)` (class field theory / Chebotarev), and the abelianisation of
`D₅` is `C₂`.  Using the general engine of `Probability.D5TypeChannelCore` we
prove that in the Chebotarev model the dial reads **exactly one bit**, for the
prime *and* for the semiprime channel:

* `d5Type_eq_orderOf` — the splitting type is the order of Frobenius
  (`1, 5, 2`), a faithful encoding of the cycle types `1⁵, 5, 1·2²`;
* `d5Sign_mul`, `d5_hom_factors_through_sign` — `d5Sign` is a character and
  *every* homomorphism of `D₅` to a commutative group factors through it
  (the abelianisation of `D₅` is `C₂`);
* `d5_typeEntropy` — `H(T) = 1/5 + (log₂ 5)/2 ≈ 1.36096`;
* `d5_mutInfo` — `I(σ ; T) = 1`, and `d5_condEnt`:
  within-class entropy `(log₂ 5)/2 - 4/5 ≈ 0.36096`;
* `d5_abelian_dial_quantized` — **quantisation**: for *every* abelian read-out
  of Frobenius the channel carries either `0` or exactly `1` bit;
* `d5_pair_mutInfo` — the semiprime type-pair channel also carries exactly `1`
  bit, although `H(pair) = 2·H(T) ≈ 2.72`;
* `d5_dial_universal`, `d5_dial_pair_universal` — for every balanced residue
  model at every conductor whose quotient character is the sign;
* `chiM10_balanced`, `d5_dial_prime_320`, `d5_dial_semiprime_320`,
  `d5_dial_prime_eq_semiprime_320` — the concrete conductor `320` with the
  quadratic character of `ℚ(√-10)` (the quadratic subfield of the Galois closure of
  `x⁵ - 5x + 12`), and `d5_dial_prime_320_chi5` for `ℚ(√5)`;
* `d5_measurement_vs_theory` — the recorded numbers against the exact values:
  the measured `H(T)` and within-class entropy lie *below* theory (plug-in
  entropy estimators are biased downward) and the measured `I` lies `0.0054`
  *above* the exact value `1` (plug-in mutual information is biased upward).
-/

open Finset DihedralGroup CyclicTypeChannel Catalog.Probability.D5TypeChannelCore

namespace Catalog.Probability.D5TypeChannel

/-- The dihedral group of order 10, the Galois group of a `D₅`-quintic. -/
abbrev D5 := DihedralGroup 5

/-- The splitting type of a Frobenius element, encoded by the length of its
longest cycle on the five roots: `1` for the identity (`1⁵`), `5` for the four
rotations (`5`), `2` for the five reflections (`1·2²`). -/
def d5Type : D5 → ℕ
  | r i => if i = 0 then 1 else 5
  | sr _ => 2

/-- The quadratic (sign) character `D₅ → C₂`: rotations `↦ 0`, reflections `↦ 1`.
It is the Frobenius in the quadratic subfield of the Galois closure. -/
def d5Sign : D5 → ZMod 2
  | r _ => 0
  | sr _ => 1

/-- The splitting type *is* the order of Frobenius. -/
theorem d5Type_eq_orderOf (g : D5) : d5Type g = orderOf g := by
  cases g with
  | r i =>
    rw [orderOf_r]
    fin_cases i <;> simp [d5Type]; all_goals decide
  | sr i => rw [orderOf_sr]; rfl

/-- `d5Sign` is a group homomorphism to `(ZMod 2, +)`. -/
theorem d5Sign_mul (a b : D5) : d5Sign (a * b) = d5Sign a + d5Sign b := by
  cases a <;> cases b <;> simp [d5Sign]
  decide

/-- **The abelianisation of `D₅` is `C₂`.**  Every homomorphism from `D₅` to a
commutative group kills the rotations and hence factors through `d5Sign`. -/
theorem d5_hom_factors_through_sign {M : Type*} [CommGroup M] (φ : D5 →* M) :
    ∀ g : D5, φ g = if d5Sign g = 0 then 1 else φ (sr 0) := by
  have hs2 : φ (sr 0) * φ (sr 0) = 1 := by
    rw [← map_mul, sr_mul_sr, sub_self, ← one_def, map_one]
  have hconj : φ (r (-1)) = φ (r 1) := by
    have : r (-1 : ZMod 5) = sr 0 * r 1 * sr 0 := by simp [sr_mul_r, sr_mul_sr]
    rw [this, map_mul, map_mul, mul_comm (φ (sr 0)) (φ (r 1)), mul_assoc, hs2, mul_one]
  have hsq : φ (r 1) * φ (r 1) = 1 := by
    nth_rewrite 1 [← hconj]
    rw [← map_mul, r_mul_r, neg_add_cancel, ← one_def, map_one]
  have h5 : φ (r 1) ^ 5 = 1 := by
    rw [← map_pow, r_one_pow]
    have : ((5 : ℕ) : ZMod 5) = 0 := by decide
    rw [this, ← one_def, map_one]
  have hr1 : φ (r 1) = 1 := by
    have : φ (r 1) ^ 5 = φ (r 1) * (φ (r 1) * φ (r 1)) * (φ (r 1) * φ (r 1)) := by
      rw [pow_succ, pow_succ, pow_succ, pow_succ, pow_one]; simp only [mul_assoc]
    rw [this, hsq, mul_one, mul_one] at h5
    exact h5
  have hr : ∀ i : ZMod 5, φ (r i) = 1 := by
    intro i
    have : r i = r 1 ^ i.val := by rw [r_one_pow, ZMod.natCast_zmod_val]
    rw [this, map_pow, hr1, one_pow]
  intro g
  cases g with
  | r i => simp [d5Sign, hr i]
  | sr i =>
    have : sr i = sr 0 * r i := by simp [sr_mul_r]
    rw [this, map_mul, hr i, mul_one]
    simp [d5Sign]

lemma card_D5 : (univ : Finset D5).card = 10 := by
  rw [card_univ, DihedralGroup.card]

/-! ## The exact entropies of the `D₅` type channel -/

/-- `H(T) = 1/5 + (log₂ 5)/2 ≈ 1.36096` bits (densities `1/10, 4/10, 5/10`). -/
theorem d5_typeEntropy : uEnt univ d5Type = 1 / 5 + Real.logb 2 5 / 2 := by
  have h : ((univ : Finset D5).image d5Type).val.map
      (fun v => #{x ∈ univ | d5Type x = v}) = {1, 4, 5} := by decide
  rw [uEnt_eq_countSum _ _ _ h, card_D5]
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton,
    Multiset.sum_cons, Multiset.sum_singleton]
  push_cast
  rw [lb_4, lb_10, Real.logb_one]
  ring

/-- The sign character is a fair coin: `H(σ) = 1`. -/
theorem d5_signEntropy : uEnt univ d5Sign = 1 := by
  have h : ((univ : Finset D5).image d5Sign).val.map
      (fun v => #{x ∈ univ | d5Sign x = v}) = {5, 5} := by decide
  rw [uEnt_eq_countSum _ _ _ h, card_D5]
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton,
    Multiset.sum_cons, Multiset.sum_singleton]
  push_cast
  rw [lb_10]
  ring

/-- The sign is a deterministic read-out of the splitting type. -/
def signOfType (t : ℕ) : ZMod 2 := if t = 2 then 1 else 0

lemma d5Sign_eq_signOfType (g : D5) : d5Sign g = signOfType (d5Type g) := by
  revert g; decide

/-- **The quadratic shadow carries exactly one bit about the splitting type.** -/
theorem d5_mutInfo : mutInfo univ d5Type d5Sign = 1 := by
  rw [mutInfo_of_function univ d5Type d5Sign signOfType fun g _ => d5Sign_eq_signOfType g,
    d5_signEntropy]

/-- Exact within-class entropy `H(T | σ) = (log₂ 5)/2 - 4/5 ≈ 0.36096`: the residual
uncertainty `1⁵` vs `5` among the split-in-`k` primes. -/
theorem d5_condEnt : condEnt univ d5Type d5Sign = Real.logb 2 5 / 2 - 4 / 5 := by
  have h := d5_mutInfo
  rw [mutInfo, d5_typeEntropy] at h
  linarith

/-- The lift of a value `m` along the sign: `0 ↦ 1`, `1 ↦ m`. -/
def signLift {M : Type*} [One M] (m : M) (e : ZMod 2) : M := if e = 0 then 1 else m

/-- **Quantisation of the abelian dial.**  For *every* homomorphism `φ` from `D₅`
to a commutative group, the read-out `φ(Frob)` carries either no information or
exactly one bit about the splitting type. -/
theorem d5_abelian_dial_quantized {M : Type*} [CommGroup M] [DecidableEq M] (φ : D5 →* M) :
    mutInfo univ d5Type φ = 0 ∨ mutInfo univ d5Type φ = 1 := by
  have hf := d5_hom_factors_through_sign φ
  by_cases hs : φ (sr 0) = 1
  · left
    rw [mutInfo_congr (k' := fun _ => (1 : M)) (fun _ _ => rfl)
      (fun g _ => by rw [hf g]; split_ifs <;> simp [hs]), mutInfo_const]
  · right
    have hinj : Set.InjOn (signLift (φ (sr 0))) (d5Sign '' ↑(univ : Finset D5)) := by
      intro a _ b _ hab
      fin_cases a <;> fin_cases b <;>
        first
        | rfl
        | (exfalso; apply hs; simp [signLift] at hab; first | exact hab | exact hab.symm)
    rw [mutInfo_congr (k' := signLift (φ (sr 0)) ∘ d5Sign) (fun _ _ => rfl) (fun g _ => hf g),
      mutInfo, condEnt_cond_injOn hinj, ← mutInfo, d5_mutInfo]

/-! ## The semiprime (type-pair) channel -/

/-- The type pair `(T(p), T(q))` of a semiprime `N = p·q`. -/
def pairType (x : D5 × D5) : ℕ × ℕ := (d5Type x.1, d5Type x.2)

/-- The quadratic shadow of `N = p·q`: `σ(p) + σ(q)`, i.e. the Kronecker symbol of
`N` for the quadratic subfield. -/
def pairSign (x : D5 × D5) : ZMod 2 := d5Sign x.1 + d5Sign x.2

/-- `H(T(p), T(q)) = 2·H(T) ≈ 2.72` bits. -/
theorem d5_pair_typeEntropy : uEnt univ pairType = 2 * (1 / 5 + Real.logb 2 5 / 2) := by
  rw [← univ_product_univ]
  have := uEnt_prod (univ_nonempty (α := D5)) (univ_nonempty (α := D5)) d5Type d5Type
  rw [show (pairType : D5 × D5 → ℕ × ℕ) = fun x => (d5Type x.1, d5Type x.2) from rfl, this,
    d5_typeEntropy]
  ring

theorem d5_pairSignEntropy : uEnt univ pairSign = 1 := by
  have h : ((univ : Finset (D5 × D5)).image pairSign).val.map
      (fun v => #{x ∈ univ | pairSign x = v}) = {50, 50} := by decide +kernel
  have hc : (univ : Finset (D5 × D5)).card = 100 := by
    rw [card_univ, Fintype.card_prod, ← card_univ, card_D5]
  rw [uEnt_eq_countSum _ _ _ h, hc]
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.map_singleton,
    Multiset.sum_cons, Multiset.sum_singleton]
  push_cast
  rw [lb_100, show (50 : ℝ) = 2 * 25 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    lb_25, Real.logb_self_eq_one (by norm_num)]
  ring

/-- **The semiprime pair channel also carries exactly one bit**, even though the
pair itself carries `2·H(T) ≈ 2.72` bits. -/
theorem d5_pair_mutInfo : mutInfo univ pairType pairSign = 1 := by
  rw [mutInfo_of_function univ pairType pairSign (fun t => signOfType t.1 + signOfType t.2)
    (fun x _ => by simp [pairSign, pairType, d5Sign_eq_signOfType]), d5_pairSignEntropy]

/-- Within-class entropy of the pair channel: `2·H(T) - 1`. -/
theorem d5_pair_condEnt : condEnt univ pairType pairSign = Real.logb 2 5 - 3 / 5 := by
  have h := d5_pair_mutInfo
  rw [mutInfo, d5_pair_typeEntropy] at h
  linarith

/-! ## The dial at an arbitrary conductor, and at `m* = 320` -/

/-- **The D5 dial reads exactly one bit, at every conductor.**  In the Chebotarev
model — `(p mod m, Frob_p)` uniform on the fibre product over the sign quotient,
with a balanced quadratic residue character `χ` — the residue carries exactly one
bit about the splitting type, independently of `m`, `U` and `K`. -/
theorem d5_dial_universal {A : Type*} [DecidableEq A] (U : Finset A) (χ : A → ZMod 2) (K : ℕ)
    (hK : 0 < K) (hbal : ∀ e : ZMod 2, #{a ∈ U | χ a = e} = K) :
    mutInfo (fibreProd U χ d5Sign) (d5Type ∘ Prod.snd) Prod.fst = 1 := by
  rw [fibreProd_mutInfo U χ d5Sign d5Type K hK fun g => hbal _, d5_mutInfo]

/-- The semiprime version: `(N mod m, Frob_p, Frob_q)` uniform on the fibre product
over `σ(p) + σ(q)` (for a multiplicative character, `N = p·q` is uniform on the
`χ`-class `σ(p) + σ(q)` given the two Frobenius elements). -/
theorem d5_dial_pair_universal {A : Type*} [DecidableEq A] (U : Finset A) (χ : A → ZMod 2)
    (K : ℕ) (hK : 0 < K) (hbal : ∀ e : ZMod 2, #{a ∈ U | χ a = e} = K) :
    mutInfo (fibreProd U χ pairSign) (pairType ∘ Prod.snd) Prod.fst = 1 := by
  rw [fibreProd_mutInfo U χ pairSign pairType K hK fun g => hbal _, d5_pair_mutInfo]

/-- The reduced residues modulo the conductor `m* = 320 = 2⁶·5`. -/
def U320 : Finset ℕ := (range 320).filter (fun a => Nat.Coprime a 320)

/-- The quadratic character of `ℚ(√5)` (conductor `5 ∣ 320`), written additively:
`0` on the squares `±1 mod 5`, `1` on the non-squares `±2 mod 5`. -/
def chi5 (a : ℕ) : ZMod 2 := if a % 5 = 1 ∨ a % 5 = 4 then 0 else 1

/-- Dirichlet balance at `m* = 320`: each value of `χ₅` is taken by exactly
`64 = φ(320)/2` reduced residues. -/
theorem chi5_balanced : ∀ e : ZMod 2, #{a ∈ U320 | chi5 a = e} = 64 := by
  intro e
  fin_cases e <;> decide +kernel

/-- The quadratic character of `ℚ(√-10)` (conductor `40 ∣ 320`), written additively:
`0` exactly on the residues `1, 7, 9, 11, 13, 19, 23, 37 (mod 40)`.  This is the
quadratic subfield of the Galois closure of the classical `D₅` quintic
`x⁵ - 5x + 12` (discriminant `2¹²·5⁶`); see `ComputationalEvidence.md`. -/
def chiM10 (a : ℕ) : ZMod 2 :=
  if a % 40 = 1 ∨ a % 40 = 7 ∨ a % 40 = 9 ∨ a % 40 = 11 ∨ a % 40 = 13 ∨ a % 40 = 19 ∨
    a % 40 = 23 ∨ a % 40 = 37 then 0 else 1

/-- Dirichlet balance for `χ₋₁₀` at `m* = 320`. -/
theorem chiM10_balanced : ∀ e : ZMod 2, #{a ∈ U320 | chiM10 a = e} = 64 := by
  intro e
  fin_cases e <;> decide +kernel

/-- **THE-D5-DIAL-IS-MEASURED (prime channel)**: `I(p mod 320 ; T) = 1` bit, for the
`D₅` field with quadratic subfield `ℚ(√-10)`. -/
theorem d5_dial_prime_320 :
    mutInfo (fibreProd U320 chiM10 d5Sign) (d5Type ∘ Prod.snd) Prod.fst = 1 :=
  d5_dial_universal U320 chiM10 64 (by norm_num) chiM10_balanced

/-- **THE-D5-DIAL-IS-MEASURED (semiprime channel)**: `I(N mod 320 ; pair) = 1` bit. -/
theorem d5_dial_semiprime_320 :
    mutInfo (fibreProd U320 chiM10 pairSign) (pairType ∘ Prod.snd) Prod.fst = 1 :=
  d5_dial_pair_universal U320 chiM10 64 (by norm_num) chiM10_balanced

/-- The observed coincidence `1.0054 = 1.0054` of the two channels is exact in the
model. -/
theorem d5_dial_prime_eq_semiprime_320 :
    mutInfo (fibreProd U320 chiM10 d5Sign) (d5Type ∘ Prod.snd) Prod.fst
      = mutInfo (fibreProd U320 chiM10 pairSign) (pairType ∘ Prod.snd) Prod.fst := by
  rw [d5_dial_prime_320, d5_dial_semiprime_320]

/-- The value does not depend on *which* quadratic subfield the `D₅` field has:
with the character of `ℚ(√5)` the dial at `320` also reads exactly one bit. -/
theorem d5_dial_prime_320_chi5 :
    mutInfo (fibreProd U320 chi5 d5Sign) (d5Type ∘ Prod.snd) Prod.fst = 1 :=
  d5_dial_universal U320 chi5 64 (by norm_num) chi5_balanced

/-! ## The recorded numbers against theory -/

/-- `log₂ 5 > 202/87`, i.e. `2²⁰² < 5⁸⁷`. -/
lemma lb_five_gt_fine : (202 : ℝ) / 87 < Real.logb 2 5 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2 : ℝ) ^ (202 : ℕ)) < Real.log ((5 : ℝ) ^ (87 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 5 < 137/59`, i.e. `5⁵⁹ < 2¹³⁷`. -/
lemma lb_five_lt_fine : Real.logb 2 5 < (137 : ℝ) / 59 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((5 : ℝ) ^ (59 : ℕ)) < Real.log ((2 : ℝ) ^ (137 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-- **Measurement versus theory.**  With the exact values `H(T) ≈ 1.36096`,
`H(T | residue) ≈ 0.36096`, `I = 1`:
* the measured `H(T) = 1.3517` is below theory by between `0.0092` and `0.0094`;
* the measured within-class entropy `0.3463` is below theory by between
  `0.0146` and `0.0148`;
* the measured `I = 1.0054` equals `1.3517 - 0.3463` and exceeds the exact value by
  `0.0054`, i.e. by `0.54 %`. -/
theorem d5_measurement_vs_theory :
    (0.0092 : ℝ) < uEnt univ d5Type - 1.3517 ∧ uEnt univ d5Type - 1.3517 < 0.0094 ∧
    (0.0146 : ℝ) < condEnt univ d5Type d5Sign - 0.3463 ∧
      condEnt univ d5Type d5Sign - 0.3463 < 0.0148 ∧
    (1.0054 : ℝ) = 1.3517 - 0.3463 ∧ (1.0054 : ℝ) - mutInfo univ d5Type d5Sign = 0.0054 := by
  have h1 := lb_five_gt_fine
  have h2 := lb_five_lt_fine
  rw [d5_typeEntropy, d5_condEnt, d5_mutInfo]
  refine ⟨by linarith, by linarith, by linarith, by linarith, by norm_num, by norm_num⟩

end Catalog.Probability.D5TypeChannel