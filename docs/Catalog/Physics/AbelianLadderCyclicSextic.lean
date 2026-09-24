/-
# The abelian ladder at degree 6: the cyclic sextic field `Q(ζ₁₃)⁺`

This file formalises the *degree-6 rung* of the abelian splitting-type ladder:
the maximal real subfield `Q(ζ₁₃)⁺`, whose Galois group over `Q` is the sign
quotient `(Z/13)ˣ / {±1} ≅ C₆`.  It is the first rung whose degree is neither a
prime nor a prime power, so it is the first place where the CRT structure of the
Galois group `C₆ ≅ C₂ × C₃` becomes visible in the splitting-type channel.

The experimental round (FACT round-30 #3, "CYCLIC-SEXTIC") reported:

* types `{1, 2, 3, 6}` at rates `{1/6, 1/6, 1/3, 1/3}`;
* full pinning, `I(p mod 13 ; T) = H(T)`, with `H(T) = 1.9192` "exactly";
* semiprime channel `I(N mod 13 ; pair) = 1.4704`.

## Main results

* `realDeg_13_eq`, `realDeg_13_prime` — the arithmetic splitting law of
  `Q(ζ₁₃)⁺`: `p ≡ ±1` splits completely, `p ≡ ±5` has residue degree `2`,
  `p ≡ ±3, ±4` residue degree `3`, and `p ≡ ±2, ±6` is inert (degree `6`);
* `card_realDeg_13` — the rates `{2, 2, 4, 4}/12 = {1/6, 1/6, 1/3, 1/3}`
  (**confirmed**);
* `realDeg_13_eq_mul` — **the CRT factorisation of the Frobenius**: the residue
  degree in the sextic field is the product of the residue degrees in its
  quadratic subfield `Q(√13)` (fixed field of the squares) and its cyclic cubic
  subfield (fixed field of the cubes);
* `uEnt_realDeg_13_eq_typeEntropy` — the field-level entropy equals the abstract
  `C₆` entropy `typeEntropy 6 = 1/3 + log₂ 3`;
* `full_pinning_deg6` — full pinning (**confirmed**, as it must be by
  `Shared.AbelianLadderUniversality`);
* `sextic_information_splits` — the orthogonal decomposition
  `H(T₆) = I(T₆ ; T₂) + I(T₆ ; T₃)` with `I(T₆ ; T₂) = H(T₂) = 1` and
  `I(T₆ ; T₃) = H(T₃) = log₂ 3 - 2/3`, and `quadratic_cubic_independent`
  (`I(T₂ ; T₃) = 0`);
* `quadratic_subfield_does_not_pin` — neither subfield pins the sextic type: the
  quadratic subfield leaves exactly `H(T₃)` bits undetermined;
* `typeEntropy_six_bracket`, `reported_H_not_exact` — `H(T) = 1.91830…`; the
  reported `1.9192` is **not** the exact value (it overshoots by more than `8·10⁻⁴`);
* `Ipair_six_bracket`, `reported_Ipair_below_exact` — `I(pair) = log₂ 3 - 1/9 =
  1.47385…`; the reported `1.4704` is an under-estimate by more than `3·10⁻³`;
* `Isplit_six_eq`, `Isplit_six_bracket`, `Isplit_six_lt_Ipair_six` — the
  split-count channel at degree 6 is `log₂ 3 - (55/36) log₂ 5 + 19/9 = 0.14868…`,
  destroying about 90% of the type-pair information (second composite degree
  after `4`), and `Isplit_six_matches_prime_formula`: its value is given by the
  *prime-degree* closed form evaluated at `q = 6` — the split count is blind to
  the composite structure that the type pair sees.
-/
import Physics.AbelianLadderSexticCRT

namespace AbelianLadder

open Finset CyclicTypeChannel

set_option maxRecDepth 40000
set_option exponentiation.threshold 100000

/-! ## 1. Divisibility criteria for residue degrees -/

/-- The residue degree in `Q(ζ_f)⁺` divides `k` iff `p^k ≡ ±1 (mod f)`. -/
theorem realDeg_dvd_iff {f k : ℕ} {u : (ZMod f)ˣ} :
    realDeg f u ∣ k ↔ u ^ k = 1 ∨ u ^ k = -1 := by
  rw [realDeg, orderOf_dvd_iff_pow_eq_one, ← map_pow]
  exact (QuotientGroup.eq_one_iff _).trans mem_signSub

/-! ## 2. The splitting law of `Q(ζ₁₃)⁺` -/

/-- The predicted residue degree of a prime `p` in `Q(ζ₁₃)⁺`, as a function of
`p mod 13`. -/
def sexticType (r : ℕ) : ℕ :=
  if r = 1 ∨ r = 12 then 1
  else if r = 5 ∨ r = 8 then 2
  else if r = 3 ∨ r = 4 ∨ r = 9 ∨ r = 10 then 3
  else 6

private theorem sextic_table : ∀ u : (ZMod 13)ˣ, sexticType (u : ZMod 13).val =
    if u ^ 2 = 1 ∨ u ^ 2 = -1 then (if u ^ 3 = 1 ∨ u ^ 3 = -1 then 1 else 2)
    else (if u ^ 3 = 1 ∨ u ^ 3 = -1 then 3 else 6) := by decide

/-- **The splitting law of `Q(ζ₁₃)⁺`.** -/
theorem realDeg_13_eq (u : (ZMod 13)ˣ) : realDeg 13 u = sexticType (u : ZMod 13).val := by
  have h6 : realDeg 13 u ∣ 6 := realDeg_dvd_iff.2 (by revert u; decide)
  have h2 := realDeg_dvd_iff (k := 2) (u := u)
  have h3 := realDeg_dvd_iff (k := 3) (u := u)
  rw [sextic_table u]
  have hmem : realDeg 13 u ∈ Nat.divisors 6 := Nat.mem_divisors.2 ⟨h6, by norm_num⟩
  rw [show Nat.divisors 6 = {1, 2, 3, 6} from by decide] at hmem
  simp only [mem_insert, mem_singleton] at hmem
  rcases hmem with h | h | h | h <;> rw [h] at h2 h3 ⊢ <;> norm_num at h2 h3 <;> simp [h2, h3]

/-- The same law for a rational prime (or any integer coprime to `13`). -/
theorem realDeg_13_prime (p : ℕ) (hp : Nat.Coprime p 13) :
    realDeg 13 (ZMod.unitOfCoprime p hp) = sexticType (p % 13) := by
  rw [realDeg_13_eq]
  congr 1

theorem realDeg_13_funext : realDeg 13 = fun u : (ZMod 13)ˣ => sexticType (u : ZMod 13).val :=
  funext realDeg_13_eq

theorem card_units_13 : Fintype.card (ZMod 13)ˣ = 12 := by
  rw [ZMod.card_units_eq_totient]
  decide

/-- **The type rates `{1/6, 1/6, 1/3, 1/3}`**: out of the `12` Frobenius classes,
`2, 2, 4, 4` have residue degree `1, 2, 3, 6` respectively — exactly `φ(d)`
times the `12/6 = 2` classes above each element of `C₆`. -/
theorem card_realDeg_13 :
    #{u ∈ (univ : Finset (ZMod 13)ˣ) | realDeg 13 u = 1} = 2 ∧
    #{u ∈ (univ : Finset (ZMod 13)ˣ) | realDeg 13 u = 2} = 2 ∧
    #{u ∈ (univ : Finset (ZMod 13)ˣ) | realDeg 13 u = 3} = 4 ∧
    #{u ∈ (univ : Finset (ZMod 13)ˣ) | realDeg 13 u = 6} = 4 := by
  rw [realDeg_13_funext]
  decide

/-- The rates match the abstract `C₆` type-count law `#{T = d} = φ(d)`, scaled by
the kernel `{±1}` of order `2`. -/
theorem card_realDeg_13_eq_totient (d : ℕ) (hd : d ∣ 6) :
    #{u ∈ (univ : Finset (ZMod 13)ˣ) | realDeg 13 u = d} = 2 * Nat.totient d := by
  have hmem : d ∈ Nat.divisors 6 := Nat.mem_divisors.2 ⟨hd, by norm_num⟩
  rw [show Nat.divisors 6 = {1, 2, 3, 6} from by decide] at hmem
  simp only [mem_insert, mem_singleton] at hmem
  obtain ⟨h1, h2, h3, h4⟩ := card_realDeg_13
  rcases hmem with rfl | rfl | rfl | rfl
  · rw [h1]; decide
  · rw [h2]; decide
  · rw [h3]; decide
  · rw [h4]; decide

/-! ## 3. The quadratic and cubic subfields, and the CRT factorisation -/

/-- The squares mod `13` are the sixth roots of unity (fixed group of `Q(√13)`). -/
theorem mem_powSub_13_two {u : (ZMod 13)ˣ} : u ∈ powSub 13 2 ↔ u ^ 6 = 1 := by
  rw [mem_powSub]
  revert u
  decide

/-- The cubes mod `13` are the fourth roots of unity (fixed group of the cyclic
cubic subfield of `Q(ζ₁₃)`). -/
theorem mem_powSub_13_three {u : (ZMod 13)ˣ} : u ∈ powSub 13 3 ↔ u ^ 4 = 1 := by
  rw [mem_powSub]
  revert u
  decide

/-- Residue degree in the quadratic subfield `Q(√13)`. -/
theorem powDeg_13_two (u : (ZMod 13)ˣ) : powDeg 13 2 u = if u ^ 6 = 1 then 1 else 2 := by
  rcases powDeg_prime_dichotomy 13 Nat.prime_two u with h | h
  · rw [h, if_pos (mem_powSub_13_two.1 (powDeg_eq_one_iff.1 h))]
  · rw [h, if_neg]
    intro h6
    have := powDeg_eq_one_iff.2 (mem_powSub_13_two.2 h6)
    omega

/-- Residue degree in the cyclic cubic subfield of `Q(ζ₁₃)`. -/
theorem powDeg_13_three (u : (ZMod 13)ˣ) : powDeg 13 3 u = if u ^ 4 = 1 then 1 else 3 := by
  rcases powDeg_prime_dichotomy 13 Nat.prime_three u with h | h
  · rw [h, if_pos (mem_powSub_13_three.1 (powDeg_eq_one_iff.1 h))]
  · rw [h, if_neg]
    intro h4
    have := powDeg_eq_one_iff.2 (mem_powSub_13_three.2 h4)
    omega

/-- **CRT factorisation of the sextic Frobenius**: the residue degree of `p` in
`Q(ζ₁₃)⁺` is the product of its residue degrees in the quadratic subfield and in
the cubic subfield. -/
theorem realDeg_13_eq_mul (u : (ZMod 13)ˣ) :
    realDeg 13 u = powDeg 13 2 u * powDeg 13 3 u := by
  rw [realDeg_13_eq, powDeg_13_two, powDeg_13_three]
  revert u
  decide

/-- Conversely each subfield degree is read off from the sextic degree:
`T₂ = gcd(T₆, 2)` and `T₃ = gcd(T₆, 3)`. -/
theorem powDeg_13_eq_gcd (u : (ZMod 13)ˣ) :
    powDeg 13 2 u = Nat.gcd (realDeg 13 u) 2 ∧ powDeg 13 3 u = Nat.gcd (realDeg 13 u) 3 := by
  rw [realDeg_13_eq, powDeg_13_two, powDeg_13_three]
  revert u
  decide

/-! ## 4. Entropies -/

private theorem lb2 : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)

/-- The Frobenius-type entropy of `Q(ζ₁₃)⁺`, computed over the `12` classes. -/
theorem uEnt_realDeg_13 :
    uEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) = 1 / 3 + Real.logb 2 3 := by
  rw [realDeg_13_funext, uEnt_eq_countSum _ _ (↑[2, 2, 4, 4] : Multiset ℕ) (by decide),
    card_univ, card_units_13]
  norm_num [lb2, lb_4, lb_12]
  ring

/-- **The field model and the abstract `C₆` model agree.** -/
theorem uEnt_realDeg_13_eq_typeEntropy :
    uEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) = typeEntropy 6 := by
  rw [uEnt_realDeg_13, typeEntropy_val_6]
  ring

/-- Entropy of the type in the quadratic subfield `Q(√13)`: exactly one bit. -/
theorem uEnt_powDeg_13_two : uEnt (univ : Finset (ZMod 13)ˣ) (powDeg 13 2) = 1 := by
  rw [funext powDeg_13_two, uEnt_eq_countSum _ _ (↑[6, 6] : Multiset ℕ) (by decide),
    card_univ, card_units_13]
  norm_num [lb_12, lb_6]
  ring

/-- Entropy of the type in the cubic subfield: `log₂ 3 - 2/3`. -/
theorem uEnt_powDeg_13_three :
    uEnt (univ : Finset (ZMod 13)ˣ) (powDeg 13 3) = Real.logb 2 3 - 2 / 3 := by
  rw [funext powDeg_13_three, uEnt_eq_countSum _ _ (↑[4, 8] : Multiset ℕ) (by decide),
    card_univ, card_units_13]
  norm_num [lb_4, lb_8, lb_12]
  ring

/-- Field-level agreement with the abstract rungs `C₂` and `C₃`. -/
theorem uEnt_subfields_13_eq_typeEntropy :
    uEnt (univ : Finset (ZMod 13)ˣ) (powDeg 13 2) = typeEntropy 2 ∧
      uEnt (univ : Finset (ZMod 13)ˣ) (powDeg 13 3) = typeEntropy 3 := by
  rw [uEnt_powDeg_13_two, uEnt_powDeg_13_three, typeEntropy_val_2, typeEntropy_val_3]
  constructor <;> ring

/-- **Additivity at the field level**: `H(T₆) = H(T₂) + H(T₃)` for the sextic
field and its quadratic and cubic subfields. -/
theorem uEnt_realDeg_13_additive :
    uEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13)
      = uEnt (univ : Finset (ZMod 13)ˣ) (powDeg 13 2)
        + uEnt (univ : Finset (ZMod 13)ˣ) (powDeg 13 3) := by
  rw [uEnt_realDeg_13, uEnt_powDeg_13_two, uEnt_powDeg_13_three]
  ring

/-! ## 5. Pinning, and how the information is distributed -/

/-- **Full pinning at degree 6**: the sign class of `p mod 13` determines the
residue degree in `Q(ζ₁₃)⁺`, so the conditional entropy vanishes and the mutual
information equals `H(T) = typeEntropy 6`. -/
theorem full_pinning_deg6 :
    condEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) (signClass 13) = 0 ∧
      mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (signClass 13) = typeEntropy 6 := by
  have hcond : condEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) (signClass 13) = 0 := by
    refine condEnt_eq_zero_of_determines fun u _ v _ huv => ?_
    rcases signClass_eq_iff huv.symm with h | h
    · rw [h]
    · rw [h, realDeg_neg]
  refine ⟨hcond, ?_⟩
  rw [mutInfo, hcond, sub_zero, uEnt_realDeg_13_eq_typeEntropy]

/-- **The sextic information splits orthogonally.**  The sextic type carries
exactly one bit about the quadratic subfield and exactly `log₂ 3 - 2/3` bits about
the cubic subfield, and these two pieces add up to the whole of `H(T₆)`. -/
theorem sextic_information_splits :
    mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 2) = 1 ∧
    mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 3) = Real.logb 2 3 - 2 / 3 ∧
    mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 2)
      + mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 3)
      = uEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) := by
  have h2 : mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 2) = 1 := by
    rw [mutInfo_eq_uEnt_of_determines (fun x _ y _ hxy => by
      rw [(powDeg_13_eq_gcd x).1, (powDeg_13_eq_gcd y).1, hxy]), uEnt_powDeg_13_two]
  have h3 : mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 3)
      = Real.logb 2 3 - 2 / 3 := by
    rw [mutInfo_eq_uEnt_of_determines (fun x _ y _ hxy => by
      rw [(powDeg_13_eq_gcd x).2, (powDeg_13_eq_gcd y).2, hxy]), uEnt_powDeg_13_three]
  refine ⟨h2, h3, ?_⟩
  rw [h2, h3, uEnt_realDeg_13]
  ring

/-- The joint quadratic–cubic read-out induces the same partition as the sextic
type (the CRT recoding is injective). -/
theorem uEnt_pair_subfields_13 :
    uEnt (univ : Finset (ZMod 13)ˣ) (fun u => (powDeg 13 2 u, powDeg 13 3 u))
      = uEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) := by
  refine uEnt_congr_fibers fun x _ y _ => ?_
  rw [realDeg_13_eq, realDeg_13_eq, powDeg_13_two, powDeg_13_two, powDeg_13_three,
    powDeg_13_three]
  revert x y
  decide

/-- **The quadratic and cubic Frobenius types are independent**: zero mutual
information between the two subfields. -/
theorem quadratic_cubic_independent :
    mutInfo (univ : Finset (ZMod 13)ˣ) (powDeg 13 2) (powDeg 13 3) = 0 := by
  rw [mutInfo_eq_symm_form, uEnt_pair_subfields_13, uEnt_realDeg_13_additive]
  ring

/-- **Neither subfield alone pins the sextic type.**  Conditioning on the
quadratic type leaves exactly `H(T₃) = log₂ 3 - 2/3 > 0` bits, and conditioning on
the cubic type leaves exactly `H(T₂) = 1` bit. -/
theorem quadratic_subfield_does_not_pin :
    condEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 2) = Real.logb 2 3 - 2 / 3 ∧
    condEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 3) = 1 ∧
    0 < condEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 2) := by
  obtain ⟨h2, h3, -⟩ := sextic_information_splits
  have e2 : condEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 2)
      = uEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13)
        - mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 2) := by
    rw [mutInfo]; ring
  have e3 : condEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 3)
      = uEnt (univ : Finset (ZMod 13)ˣ) (realDeg 13)
        - mutInfo (univ : Finset (ZMod 13)ˣ) (realDeg 13) (powDeg 13 3) := by
    rw [mutInfo]; ring
  have hl := lb_three_gt
  refine ⟨?_, ?_, ?_⟩
  · rw [e2, h2, uEnt_realDeg_13]; ring
  · rw [e3, h3, uEnt_realDeg_13]; ring
  · rw [e2, h2, uEnt_realDeg_13]; linarith

/-- The abstract counterpart: the `C₆` type channel splits orthogonally into its
`C₂` and `C₃` components (instance of `orthogonal_split_of_coprime`). -/
theorem orthogonal_split_six :
    mutInfo (range 6) (ordType 6) (ordType 2) = 1 ∧
    mutInfo (range 6) (ordType 6) (ordType 3) = Real.logb 2 3 - 2 / 3 ∧
    mutInfo (range 6) (ordType 2) (ordType 3) = 0 := by
  obtain ⟨h1, h2, h3⟩ := orthogonal_split_of_coprime (m := 2) (n := 3) (by norm_num)
    (by norm_num) (by norm_num)
  refine ⟨?_, ?_, h3⟩
  · rw [h1, typeEntropy_val_2]
  · rw [h2, typeEntropy_val_3]; ring

/-! ## 6. Numerical certificates -/

private theorem lt_logb_of_pow {x a b : ℕ} (hb : 0 < b) (h : 2 ^ a < x ^ b) :
    (a : ℝ) / b < Real.logb 2 x := by
  have hR : ((2 : ℝ) ^ a) < (x : ℝ) ^ b := by exact_mod_cast h
  have hlt := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
  rw [Real.logb_pow, Real.logb_pow, lb2] at hlt
  rw [div_lt_iff₀ (by exact_mod_cast hb)]
  linarith

private theorem logb_lt_of_pow {x a b : ℕ} (hx : 0 < x) (hb : 0 < b) (h : x ^ b < 2 ^ a) :
    Real.logb 2 x < (a : ℝ) / b := by
  have hR : (x : ℝ) ^ b < ((2 : ℝ) ^ a) := by exact_mod_cast h
  have hx' : (0 : ℝ) < x := by exact_mod_cast hx
  have hlt := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
  rw [Real.logb_pow, Real.logb_pow, lb2] at hlt
  rw [lt_div_iff₀ (by exact_mod_cast hb)]
  linarith

/-- `1054/665 < log₂ 3 < 485/306` (continued-fraction convergents). -/
theorem logb_three_fine : (1054 : ℝ) / 665 < Real.logb 2 3 ∧ Real.logb 2 3 < (485 : ℝ) / 306 := by
  have h1 := lt_logb_of_pow (x := 3) (a := 1054) (b := 665) (by norm_num) (by norm_num)
  have h2 := logb_lt_of_pow (x := 3) (a := 485) (b := 306) (by norm_num) (by norm_num)
    (by norm_num)
  push_cast at h1 h2
  exact ⟨h1, h2⟩

/-- `339/146 < log₂ 5 < 1493/643` (continued-fraction convergents). -/
theorem logb_five_fine : (339 : ℝ) / 146 < Real.logb 2 5 ∧ Real.logb 2 5 < (1493 : ℝ) / 643 := by
  have h1 := lt_logb_of_pow (x := 5) (a := 339) (b := 146) (by norm_num) (by norm_num)
  have h2 := logb_lt_of_pow (x := 5) (a := 1493) (b := 643) (by norm_num) (by norm_num)
    (by norm_num)
  push_cast at h1 h2
  exact ⟨h1, h2⟩

/-- `H(T₆) = 1.91830…`: the bracket `1.91829 < H(T) < 1.91831`. -/
theorem typeEntropy_six_bracket : 1.91829 < typeEntropy 6 ∧ typeEntropy 6 < 1.91831 := by
  obtain ⟨h1, h2⟩ := logb_three_fine
  rw [typeEntropy_val_6]
  constructor <;> norm_num <;> linarith

/-- **The reported `H(T) = 1.9192` is not exact**: the true value is smaller by
more than `8 · 10⁻⁴` bits. -/
theorem reported_H_not_exact : typeEntropy 6 + 0.0008 < 1.9192 := by
  linarith [typeEntropy_six_bracket.2]

/-- `I(N mod 13 ; pair) = log₂ 3 - 1/9 = 1.47385…`. -/
theorem Ipair_six_bracket : 1.47385 < Ipair 6 ∧ Ipair 6 < 1.47386 := by
  obtain ⟨h1, h2⟩ := logb_three_fine
  rw [Ipair_val_6]
  constructor <;> norm_num <;> linarith

/-- **The reported `1.4704` under-estimates the exact semiprime channel** by more
than `3 · 10⁻³` bits. -/
theorem reported_Ipair_below_exact : (1.4704 : ℝ) + 0.003 < Ipair 6 := by
  linarith [Ipair_six_bracket.1]

/-! ## 7. The split-count channel at degree 6 -/

private theorem lb36 : Real.logb 2 (36 : ℝ) = 2 + 2 * Real.logb 2 3 := lb_36

theorem uEnt_splitCount_six :
    uEnt (box 6) (sProj ∘ typePair 6)
      = 2 + 2 * Real.logb 2 3 - (10 + 60 * Real.logb 2 5) / 36 := by
  rw [uEnt_eq_countSum _ _ (↑[25, 10, 1] : Multiset ℕ) (by decide),
    show (box 6).card = 36 from by decide]
  norm_num [lb_36, lb_25, lb_10]
  ring

private theorem uEnt_split6_zero :
    uEnt {x ∈ box 6 | prodRes 6 x = 0} (sProj ∘ typePair 6)
      = 1 + Real.logb 2 3 - (5 / 6) * Real.logb 2 5 := by
  rw [uEnt_eq_countSum _ _ (↑[5, 1] : Multiset ℕ) (by decide),
    show ({x ∈ box 6 | prodRes 6 x = 0}).card = 6 from by decide]
  norm_num [lb_6]
  ring

private theorem uEnt_split6_ne {c : ℕ} (hc : c ∈ ({1, 2, 3, 4, 5} : Finset ℕ)) :
    uEnt {x ∈ box 6 | prodRes 6 x = c} (sProj ∘ typePair 6) = Real.logb 2 3 - 2 / 3 := by
  simp only [mem_insert, mem_singleton] at hc
  rcases hc with rfl | rfl | rfl | rfl | rfl <;>
  · rw [uEnt_eq_countSum _ _ (↑[4, 2] : Multiset ℕ) (by decide),
      show ({x ∈ box 6 | prodRes 6 x = _}).card = 6 from by decide]
    norm_num [lb2, lb_4, lb_6]
    ring

theorem condEnt_splitCount_six :
    condEnt (box 6) (sProj ∘ typePair 6) (prodRes 6)
      = (1 / 6) * (1 + Real.logb 2 3 - (5 / 6) * Real.logb 2 5)
        + (5 / 6) * (Real.logb 2 3 - 2 / 3) := by
  rw [condEnt, show (box 6).image (prodRes 6) = ({0, 1, 2, 3, 4, 5} : Finset ℕ) from by decide]
  rw [Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_insert (by decide),
    Finset.sum_insert (by decide), Finset.sum_insert (by decide), Finset.sum_singleton]
  rw [uEnt_split6_zero, uEnt_split6_ne (by decide), uEnt_split6_ne (by decide),
    uEnt_split6_ne (by decide), uEnt_split6_ne (by decide), uEnt_split6_ne (by decide),
    show (box 6).card = 36 from by decide,
    show #{x ∈ box 6 | prodRes 6 x = 0} = 6 from by decide,
    show #{x ∈ box 6 | prodRes 6 x = 1} = 6 from by decide,
    show #{x ∈ box 6 | prodRes 6 x = 2} = 6 from by decide,
    show #{x ∈ box 6 | prodRes 6 x = 3} = 6 from by decide,
    show #{x ∈ box 6 | prodRes 6 x = 4} = 6 from by decide,
    show #{x ∈ box 6 | prodRes 6 x = 5} = 6 from by decide]
  norm_num
  ring

/-- **The degree-6 split-count channel in closed form.** -/
theorem Isplit_six_eq : Isplit 6 = Real.logb 2 3 - (55 / 36) * Real.logb 2 5 + 19 / 9 := by
  rw [Isplit, mutInfo, uEnt_splitCount_six, condEnt_splitCount_six]
  ring

/-- `Isplit 6 = 0.14868…`. -/
theorem Isplit_six_bracket : 0.1486 < Isplit 6 ∧ Isplit 6 < 0.1488 := by
  obtain ⟨h1, h2⟩ := logb_three_fine
  obtain ⟨h3, h4⟩ := logb_five_fine
  rw [Isplit_six_eq]
  constructor <;> norm_num <;> linarith

/-- **Strict information loss at the second composite degree**: the split count
keeps less than `11%` of the type-pair information. -/
theorem Isplit_six_lt_Ipair_six : Isplit 6 < Ipair 6 ∧ Isplit 6 < 0.11 * Ipair 6 := by
  obtain ⟨h1, h2⟩ := Isplit_six_bracket
  obtain ⟨h3, h4⟩ := Ipair_six_bracket
  constructor <;> nlinarith

/-- **The split count is blind to compositeness**: `Isplit 6` is exactly the
prime-degree closed form of `Isplit_prime` evaluated at `q = 6`, although `6` is
not prime. -/
theorem Isplit_six_matches_prime_formula :
    Isplit 6 = Real.logb 2 (((6 : ℕ) : ℝ) ^ 2)
        - ((((6 : ℕ) : ℝ) - 1) ^ 2 * Real.logb 2 ((((6 : ℕ) : ℝ) - 1) ^ 2)
            + 2 * (((6 : ℕ) : ℝ) - 1) * Real.logb 2 (2 * (((6 : ℕ) : ℝ) - 1)))
          / ((6 : ℕ) : ℝ) ^ 2
        - ((1 / ((6 : ℕ) : ℝ)) * binEnt 6 1 + ((((6 : ℕ) : ℝ) - 1) / (6 : ℕ)) * binEnt 6 2) := by
  rw [Isplit_six_eq, binEnt, binEnt]
  norm_num [lb_36, lb_25, lb_10, lb_6, lb_4, lb2]
  ring

end AbelianLadder