/-
# The abelian ladder at degree 7: the cyclic septic subfield of `Q(ζ₂₉)`

This file formalises the *degree-7 rung* of the abelian splitting-type ladder.
Here the field is no longer a real cyclotomic subfield (`7 ∤ (f-1)/2` forces a
new construction): it is the unique cyclic degree-7 subfield of `Q(ζ₂₉)`, the
fixed field of the order-4 subgroup of `(Z/29)ˣ ≅ C₂₈`, i.e. the fixed field of
the group of *seventh powers*.

The experimental round that motivates the file recorded these predictions:

* `T(p) = 1` exactly when the discrete logarithm of `p` mod `29` vanishes
  modulo `7`, i.e. exactly when `p` is a seventh power mod `29`;
* the two type-densities are `1/7` and `6/7`, giving
  `H(T) = log₂ 7 - (6/7) log₂ 6 = 0.5917…` bits;
* the residue channel is *fully pinned*: the mutual information between the
  Frobenius class in `Gal` and the type equals `H(T)` exactly;
* the semiprime split-count follows `Bin(2, 1/7)`, i.e. the counts `(36, 12, 1)`
  out of `49`;
* the split-count channel has value `Is(7) = 0.1161`, while a *ledger* anchor
  `0.0103` was attributed (after the fact) to the OR channel `G(7)`.

## Main results

Generic machinery (any conductor `f`, any degree `q`):

* `AbelianLadder.powSub`, `AbelianLadder.powDeg` — the subgroup of `q`-th powers
  in `(Z/f)ˣ` and the residue degree in the fixed field of that subgroup;
* `AbelianLadder.powDeg_eq_one_iff`, `powDeg_dvd`, `powDeg_prime_dichotomy`,
  `powDeg_mul_mem` — the basic laws of that degree.

The degree-7 rung (`f = 29`, `q = 7`):

* `mem_powSub_29_seven` — `u` is a seventh power mod `29` iff `u⁴ = 1`
  (the two descriptions of the order-4 subgroup);
* `powDeg_29_prime_iff` — the arithmetic pinning law:
  `p` splits completely iff `p % 29 ∈ {1, 12, 17, 28}`;
* `uEnt_powDeg_29_eq_typeEntropy`, `typeEntropy_seven_bracket` — the two models
  agree and `0.5916 < H(T) < 0.5918`;
* `full_pinning_deg7` — the quartic coset class of `p mod 29` pins the type:
  conditional entropy `0`, mutual information `= H(T)`;
* `quartic_character_carries_no_information` — the orthogonal statement: the
  quartic character mod `29` (the `C₄`-component of `C₂₈`) says nothing about
  the degree-7 type;
* `splitCount_deg7` — the `Bin(2, 1/7)` law `(36, 12, 1)`.

The channels (any prime degree `q`, then `q = 7`):

* `uEnt_congr_fibers`, `condEnt_congr_fibers` — entropy depends only on the
  partition a read-out induces;
* `Ipair_eq_Isplit_prime` — at prime degree the split count is a *sufficient
  statistic* for the whole type pair: the `s`-projection is information-lossless;
* `IOR`, `condEnt_or_eq_condEnt_split_prime`, `IOR_prime` — the OR ("at least
  one factor splits") channel, whose conditional entropy coincides with that of
  the split count, so the two channels differ exactly by their unconditional
  entropies (`Isplit_sub_IOR_prime`);
* `IOR_le_Isplit_prime` — data processing: the OR channel never exceeds the
  split-count channel;
* `Isplit_seven_value` / `Isplit_seven_bracket` — `Is(7) = 0.11410…`, which
  **falsifies** the reported `0.1161` (`Isplit_seven_lt_reported`), and which is
  the value the round-50 anchor `0.116` actually sits next to
  (`anchor_116_closer_to_deg7`);
* `IOR_seven_value` / `IOR_seven_bracket` — `G(7) = 0.01030…`, which
  **confirms** the ledger disclosure that the anchor `0.0103` is the OR channel.
-/
import Shared.AbelianLadderSplitChannel

namespace AbelianLadder

open Finset CyclicTypeChannel

set_option exponentiation.threshold 100000
set_option maxRecDepth 40000

/-! ## 1. Power-residue quotients of a cyclotomic Galois group -/

/-- The subgroup of `q`-th powers inside `(Z/f)ˣ`.  Its fixed field is the
degree-`gcd(q, φ(f))` cyclic subfield of `Q(ζ_f)` when `(Z/f)ˣ` is cyclic. -/
def powSub (f q : ℕ) : Subgroup (ZMod f)ˣ := (powMonoidHom q : (ZMod f)ˣ →* (ZMod f)ˣ).range

theorem mem_powSub {f q : ℕ} {u : (ZMod f)ˣ} : u ∈ powSub f q ↔ ∃ v : (ZMod f)ˣ, v ^ q = u := by
  simp [powSub, MonoidHom.mem_range, powMonoidHom]

/-- The **residue degree in the `q`-th power subfield**: the order of the Frobenius
class of `u` in the quotient `(Z/f)ˣ / ((Z/f)ˣ)^q`. -/
noncomputable def powDeg (f q : ℕ) (u : (ZMod f)ˣ) : ℕ :=
  orderOf (QuotientGroup.mk' (powSub f q) u)

/-- Complete splitting is exactly the `q`-th power condition. -/
theorem powDeg_eq_one_iff {f q : ℕ} {u : (ZMod f)ˣ} : powDeg f q u = 1 ↔ u ∈ powSub f q := by
  rw [powDeg, orderOf_eq_one_iff]
  exact QuotientGroup.eq_one_iff u

/-- The residue degree always divides `q`. -/
theorem powDeg_dvd (f q : ℕ) (u : (ZMod f)ˣ) : powDeg f q u ∣ q := by
  refine orderOf_dvd_of_pow_eq_one ?_
  rw [← map_pow]
  exact (QuotientGroup.eq_one_iff _).2 (mem_powSub.2 ⟨u, rfl⟩)

/-- **Prime-degree dichotomy**: for prime `q` every unit is either totally split
or of full residue degree `q`. -/
theorem powDeg_prime_dichotomy {q : ℕ} (f : ℕ) (hq : q.Prime) (u : (ZMod f)ˣ) :
    powDeg f q u = 1 ∨ powDeg f q u = q :=
  hq.eq_one_or_self_of_dvd _ (powDeg_dvd f q u)

/-- The residue degree is a class function on the cosets of the `q`-th powers. -/
theorem powDeg_mul_mem {f q : ℕ} {u h : (ZMod f)ˣ} (hh : h ∈ powSub f q) :
    powDeg f q (u * h) = powDeg f q u := by
  have h1 : (QuotientGroup.mk' (powSub f q)) (u * h) = (QuotientGroup.mk' (powSub f q)) u :=
    (QuotientGroup.mk'_eq_mk' _).2 ⟨h⁻¹, inv_mem hh, by group⟩
  rw [powDeg, powDeg, h1]

/-! ## 2. The degree-7 rung: conductor `29` -/

theorem card_units_29 : Fintype.card (ZMod 29)ˣ = 28 := by
  rw [ZMod.card_units_eq_totient]
  decide

/-- **The two faces of the order-4 subgroup.** A unit mod `29` is a seventh power
iff it is a fourth root of unity; this is the arithmetic content of
`C₂₈ / C₄ ≅ C₇`. -/
theorem mem_powSub_29_seven {u : (ZMod 29)ˣ} : u ∈ powSub 29 7 ↔ u ^ 4 = 1 := by
  rw [mem_powSub]
  constructor
  · rintro ⟨v, rfl⟩
    rw [← pow_mul, show 7 * 4 = 28 from rfl, ← card_units_29]
    exact pow_card_eq_one
  · intro h
    refine ⟨u ^ 3, ?_⟩
    rw [← pow_mul, show 3 * 7 = 4 * 5 + 1 from rfl, pow_add, pow_mul, h, one_pow, one_mul, pow_one]

theorem powDeg_29_eq_one_iff {u : (ZMod 29)ˣ} : powDeg 29 7 u = 1 ↔ u ^ 4 = 1 :=
  powDeg_eq_one_iff.trans mem_powSub_29_seven

/-- Every prime is either totally split or inert-of-degree-7 in the septic
subfield of `Q(ζ₂₉)`. -/
theorem powDeg_29_eq_one_or_seven (u : (ZMod 29)ˣ) : powDeg 29 7 u = 1 ∨ powDeg 29 7 u = 7 :=
  powDeg_prime_dichotomy 29 (by norm_num) u

/-- Comparing a natural number to a residue inside `ZMod 29`. -/
private theorem natCast_eq_iff_mod29 {p r : ℕ} (hr : r < 29) :
    ((p : ZMod 29) = ((r : ℕ) : ZMod 29)) ↔ p % 29 = r := by
  rw [← ZMod.natCast_mod p 29]
  constructor
  · intro h
    have hv := congrArg ZMod.val h
    rwa [ZMod.val_cast_of_lt (Nat.mod_lt _ (by norm_num)), ZMod.val_cast_of_lt hr] at hv
  · intro h; rw [h]

/-- The fourth roots of unity mod `29`. -/
theorem pow_four_eq_one_iff :
    ∀ x : ZMod 29, x ^ 4 = 1 ↔ x = 1 ∨ x = 12 ∨ x = 17 ∨ x = 28 := by decide

/-- **The degree-7 splitting criterion for a prime `p`.**  `p` splits completely
in the septic subfield of `Q(ζ₂₉)` — equivalently its discrete logarithm mod `29`
is divisible by `7` — iff `p % 29 ∈ {1, 12, 17, 28}`. -/
theorem powDeg_29_prime_iff {p : ℕ} (hp : Nat.Coprime p 29) :
    powDeg 29 7 (ZMod.unitOfCoprime p hp) = 1 ↔
      p % 29 = 1 ∨ p % 29 = 12 ∨ p % 29 = 17 ∨ p % 29 = 28 := by
  have hval : ((ZMod.unitOfCoprime p hp : (ZMod 29)ˣ) : ZMod 29) = (p : ZMod 29) := rfl
  rw [powDeg_29_eq_one_iff, Units.ext_iff, Units.val_pow_eq_pow_val, hval, Units.val_one,
    pow_four_eq_one_iff (p : ZMod 29)]
  have h1 : ((p : ZMod 29) = 1) ↔ p % 29 = 1 := by
    rw [show (1 : ZMod 29) = ((1 : ℕ) : ZMod 29) by norm_num]
    exact natCast_eq_iff_mod29 (by norm_num)
  have h12 : ((p : ZMod 29) = 12) ↔ p % 29 = 12 := by
    rw [show (12 : ZMod 29) = ((12 : ℕ) : ZMod 29) by norm_num]
    exact natCast_eq_iff_mod29 (by norm_num)
  have h17 : ((p : ZMod 29) = 17) ↔ p % 29 = 17 := by
    rw [show (17 : ZMod 29) = ((17 : ℕ) : ZMod 29) by norm_num]
    exact natCast_eq_iff_mod29 (by norm_num)
  have h28 : ((p : ZMod 29) = 28) ↔ p % 29 = 28 := by
    rw [show (28 : ZMod 29) = ((28 : ℕ) : ZMod 29) by norm_num]
    exact natCast_eq_iff_mod29 (by norm_num)
  rw [h1, h12, h17, h28]

/-- `41 ≡ 12 (mod 29)` is a seventh power: it splits completely. -/
theorem powDeg_29_fortyone (h : Nat.Coprime 41 29 := by decide) :
    powDeg 29 7 (ZMod.unitOfCoprime 41 h) = 1 := by
  rw [powDeg_29_prime_iff]; right; left; rfl

/-- `2` is not a seventh power mod `29`: it is inert of degree `7`. -/
theorem powDeg_29_two (h : Nat.Coprime 2 29 := by decide) :
    powDeg 29 7 (ZMod.unitOfCoprime 2 h) = 7 := by
  rcases powDeg_29_eq_one_or_seven (ZMod.unitOfCoprime 2 h) with h1 | h1
  · rw [powDeg_29_prime_iff] at h1; omega
  · exact h1

/-! ## 3. The degree-7 type entropy -/

theorem card_univ_units_29 : (univ : Finset (ZMod 29)ˣ).card = 28 := by
  rw [Finset.card_univ, card_units_29]

/-- Exactly four of the `28` Frobenius classes split completely: density `1/7`. -/
theorem card_filter_powDeg_29 :
    #{u ∈ (univ : Finset (ZMod 29)ˣ) | powDeg 29 7 u = 1} = 4 := by
  have hset : {u ∈ (univ : Finset (ZMod 29)ˣ) | powDeg 29 7 u = 1}
      = {u ∈ (univ : Finset (ZMod 29)ˣ) | u ^ 4 = 1} :=
    Finset.filter_congr fun u _ => by simp [powDeg_29_eq_one_iff]
  rw [hset]
  decide

/-- **The Frobenius-type entropy computed inside `(Z/29)ˣ`.** -/
theorem uEnt_powDeg_29 :
    uEnt (univ : Finset (ZMod 29)ˣ) (powDeg 29 7) = binEnt 28 4 := by
  have h := uEnt_binary (s := (univ : Finset (ZMod 29)ˣ)) (g := powDeg 29 7)
    (v := 1) (w := 7) (by norm_num) (fun u _ => powDeg_29_eq_one_or_seven u)
  rw [h, card_filter_powDeg_29, card_univ_units_29]

/-- **The two models agree.**  The entropy of the degree-7 Frobenius type over the
`28` residue classes mod `29` equals the abstract `C₇` type entropy. -/
theorem uEnt_powDeg_29_eq_typeEntropy :
    uEnt (univ : Finset (ZMod 29)ˣ) (powDeg 29 7) = typeEntropy 7 := by
  rw [uEnt_powDeg_29, typeEntropy_prime_eq_binEnt (by norm_num),
    show (28 : ℕ) = 4 * 7 from rfl, show (4 : ℕ) = 4 * 1 from rfl,
    binEnt_scale (by norm_num) (by norm_num) (by norm_num)]

/-- The degree-7 rung: `H(T) = log₂ 7 - (6/7) log₂ 6`. -/
theorem typeEntropy_seven_eq :
    typeEntropy 7 = Real.logb 2 7 - (6 / 7 : ℝ) * Real.logb 2 6 := by
  rw [typeEntropy_prime_formula (by norm_num)]
  norm_num

/-- `7 · H(T) = log₂ (7⁷ / 6⁶)`. -/
theorem seven_mul_typeEntropy :
    7 * typeEntropy 7 = Real.logb 2 ((7 : ℝ) ^ 7 / (6 : ℝ) ^ 6) := by
  rw [typeEntropy_seven_eq, Real.logb_div (by positivity) (by positivity),
    Real.logb_pow, Real.logb_pow]
  ring

/-- **The degree-7 entropy bracket**: `0.5916 < H(T) < 0.5918` bits.  The
witnesses are the integer inequalities `2⁸²⁸³ · 6¹²⁰⁰⁰ < 7¹⁴⁰⁰⁰` and
`7¹⁴⁰⁰⁰ < 2⁸²⁸⁴ · 6¹²⁰⁰⁰`. -/
theorem typeEntropy_seven_bracket :
    0.5916 < typeEntropy 7 ∧ typeEntropy 7 < 0.5918 := by
  set R : ℝ := (7 : ℝ) ^ 7 / (6 : ℝ) ^ 6 with hR
  have hR0 : 0 < R := by rw [hR]; positivity
  have hlog : Real.logb 2 R = 7 * typeEntropy 7 := seven_mul_typeEntropy.symm
  have hlow : (2 : ℝ) ^ 8283 < R ^ 2000 := by
    have hpow : R ^ 2000 = (7 : ℝ) ^ 14000 / (6 : ℝ) ^ 12000 := by
      rw [hR, div_pow, ← pow_mul, ← pow_mul]
    rw [hpow, lt_div_iff₀ (by positivity)]
    have hnat : (2 : ℕ) ^ 8283 * 6 ^ 12000 < 7 ^ 14000 := by norm_num
    calc (2 : ℝ) ^ 8283 * (6 : ℝ) ^ 12000 = ((2 ^ 8283 * 6 ^ 12000 : ℕ) : ℝ) := by push_cast; ring
      _ < ((7 ^ 14000 : ℕ) : ℝ) := by exact_mod_cast hnat
      _ = (7 : ℝ) ^ 14000 := by push_cast; ring
  have hhigh : R ^ 2000 < (2 : ℝ) ^ 8284 := by
    have hpow : R ^ 2000 = (7 : ℝ) ^ 14000 / (6 : ℝ) ^ 12000 := by
      rw [hR, div_pow, ← pow_mul, ← pow_mul]
    rw [hpow, div_lt_iff₀ (by positivity)]
    have hnat : (7 : ℕ) ^ 14000 < 2 ^ 8284 * 6 ^ 12000 := by norm_num
    calc (7 : ℝ) ^ 14000 = ((7 ^ 14000 : ℕ) : ℝ) := by push_cast; ring
      _ < ((2 ^ 8284 * 6 ^ 12000 : ℕ) : ℝ) := by exact_mod_cast hnat
      _ = (2 : ℝ) ^ 8284 * (6 : ℝ) ^ 12000 := by push_cast; ring
  have h1 : (8283 : ℝ) < 2000 * Real.logb 2 R := by
    have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hlow
    rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num)] at h
    push_cast at h
    linarith
  have h2 : 2000 * Real.logb 2 R < (8284 : ℝ) := by
    have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hhigh
    rw [Real.logb_pow, Real.logb_pow, Real.logb_self_eq_one (by norm_num)] at h
    push_cast at h
    linarith
  rw [hlog] at h1 h2
  constructor <;> [linarith; linarith]

/-! ## 4. Full pinning: the quartic coset class determines the type -/

/-- The fourth roots of unity mod `29` — the group of seventh powers. -/
def quartRoots : Finset (ZMod 29)ˣ := {u ∈ (univ : Finset (ZMod 29)ˣ) | u ^ 4 = 1}

theorem one_mem_quartRoots : (1 : (ZMod 29)ˣ) ∈ quartRoots := by decide

theorem quartRoots_pow {h : (ZMod 29)ˣ} (hh : h ∈ quartRoots) : h ^ 4 = 1 :=
  (Finset.mem_filter.1 hh).2

/-- The **quartic class** of a unit: its coset modulo the seventh powers, i.e.
exactly the datum of the Frobenius class in the septic subfield. -/
def quartClass (u : (ZMod 29)ˣ) : Finset (ZMod 29)ˣ := quartRoots.image (fun h => u * h)

theorem self_mem_quartClass (u : (ZMod 29)ˣ) : u ∈ quartClass u :=
  Finset.mem_image.2 ⟨1, one_mem_quartRoots, mul_one u⟩

theorem quartClass_eq_imp {u v : (ZMod 29)ˣ} (h : quartClass u = quartClass v) :
    ∃ w ∈ quartRoots, v = u * w := by
  have hv : v ∈ quartClass u := by rw [h]; exact self_mem_quartClass v
  obtain ⟨w, hw, hwv⟩ := Finset.mem_image.1 hv
  exact ⟨w, hw, hwv.symm⟩

/-- **FULL PINNING AT DEGREE 7.** The quartic coset class of `p mod 29` — a
strictly coarser invariant than the residue itself, of only `7` values —
determines the residue degree in the septic subfield, so the conditional entropy
vanishes and the mutual information attains `H(T)` exactly. -/
theorem full_pinning_deg7 :
    condEnt (univ : Finset (ZMod 29)ˣ) (powDeg 29 7) quartClass = 0 ∧
      mutInfo (univ : Finset (ZMod 29)ˣ) (powDeg 29 7) quartClass = typeEntropy 7 := by
  have hcond : condEnt (univ : Finset (ZMod 29)ˣ) (powDeg 29 7) quartClass = 0 := by
    refine condEnt_eq_zero_of_determines fun u _ v _ huv => ?_
    obtain ⟨w, hw, rfl⟩ := quartClass_eq_imp huv
    exact (powDeg_mul_mem (mem_powSub_29_seven.2 (quartRoots_pow hw))).symm
  refine ⟨hcond, ?_⟩
  rw [mutInfo, hcond, sub_zero, uEnt_powDeg_29_eq_typeEntropy]

/-! ## 5. The orthogonal direction: the quartic character is uninformative -/

/-- The degree-7 type read-out in the exponent (discrete-logarithm) model: `a`
runs over `Z/28` and the septic type only sees `a mod 7`. -/
def septType (a : ℕ) : ℕ := ordType 7 (a % 7)

/-- The quartic character mod `29`: the discrete logarithm modulo `4`, i.e. the
`C₄`-component of `C₂₈ ≅ C₄ × C₇`. -/
def quartChar (a : ℕ) : ℕ := a % 4

theorem septType_binary (a : ℕ) : septType a = 1 ∨ septType a = 7 :=
  ordType_prime_binary (by norm_num) (Nat.mod_lt _ (by norm_num))

/-- The exponent model reproduces the same entropy. -/
theorem uEnt_septType_range28 : uEnt (range 28) septType = binEnt 28 4 := by
  have h := uEnt_binary (s := range 28) (g := septType) (v := 1) (w := 7) (by norm_num)
    (fun a _ => septType_binary a)
  rw [h, card_range, show #{a ∈ range 28 | septType a = 1} = 4 from by decide]

/-- Each quartic-character fibre carries the *same* type distribution: one split
class against six inert ones. -/
theorem uEnt_quartChar_fibre {c : ℕ} (hc : c = 0 ∨ c = 1 ∨ c = 2 ∨ c = 3) :
    uEnt {a ∈ range 28 | quartChar a = c} septType = binEnt 7 1 := by
  have h := uEnt_binary (s := {a ∈ range 28 | quartChar a = c}) (g := septType)
    (v := 1) (w := 7) (by norm_num) (fun a _ => septType_binary a)
  rcases hc with rfl | rfl | rfl | rfl
  · rw [h, show (#{a ∈ range 28 | quartChar a = 0}) = 7 from by decide,
      show #{x ∈ {a ∈ range 28 | quartChar a = 0} | septType x = 1} = 1 from by decide]
  · rw [h, show (#{a ∈ range 28 | quartChar a = 1}) = 7 from by decide,
      show #{x ∈ {a ∈ range 28 | quartChar a = 1} | septType x = 1} = 1 from by decide]
  · rw [h, show (#{a ∈ range 28 | quartChar a = 2}) = 7 from by decide,
      show #{x ∈ {a ∈ range 28 | quartChar a = 2} | septType x = 1} = 1 from by decide]
  · rw [h, show (#{a ∈ range 28 | quartChar a = 3}) = 7 from by decide,
      show #{x ∈ {a ∈ range 28 | quartChar a = 3} | septType x = 1} = 1 from by decide]

/-- **Zero information from the quartic character.** The `C₄`-component of the
Frobenius (in particular the quadratic character mod `29`) says nothing at all
about splitting in the septic subfield: a CRT consequence of `gcd(4, 7) = 1`. -/
theorem quartic_character_carries_no_information :
    mutInfo (range 28) septType quartChar = 0 := by
  have himg : (range 28).image quartChar = {0, 1, 2, 3} := by decide
  have hcond : condEnt (range 28) septType quartChar = binEnt 7 1 := by
    rw [condEnt, himg,
      show ({0, 1, 2, 3} : Finset ℕ) = insert 0 (insert 1 (insert 2 {3})) from rfl,
      Finset.sum_insert (by decide), Finset.sum_insert (by decide),
      Finset.sum_insert (by decide), Finset.sum_singleton,
      uEnt_quartChar_fibre (Or.inl rfl), uEnt_quartChar_fibre (Or.inr (Or.inl rfl)),
      uEnt_quartChar_fibre (Or.inr (Or.inr (Or.inl rfl))),
      uEnt_quartChar_fibre (Or.inr (Or.inr (Or.inr rfl))),
      show (#{a ∈ range 28 | quartChar a = 0}) = 7 from by decide,
      show (#{a ∈ range 28 | quartChar a = 1}) = 7 from by decide,
      show (#{a ∈ range 28 | quartChar a = 2}) = 7 from by decide,
      show (#{a ∈ range 28 | quartChar a = 3}) = 7 from by decide, card_range]
    ring
  rw [mutInfo, hcond, uEnt_septType_range28,
    show (28 : ℕ) = 4 * 7 from rfl, show (4 : ℕ) = 4 * 1 from rfl,
    binEnt_scale (by norm_num) (by norm_num) (by norm_num), sub_self]

/-! ## 6. The semiprime split count at degree 7 -/

/-- **The `Bin(2, 1/7)` law at degree 7**: of the `49` exponent pairs, `36` have
no split factor, `12` have exactly one and `1` has two. -/
theorem splitCount_deg7 :
    #{x ∈ box 7 | sProj (typePair 7 x) = 0} = 36 ∧
    #{x ∈ box 7 | sProj (typePair 7 x) = 1} = 12 ∧
    #{x ∈ box 7 | sProj (typePair 7 x) = 2} = 1 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [card_splitCount_zero (by norm_num)]
  · rw [card_splitCount_one (by norm_num)]
  · rw [card_splitCount_two (by norm_num)]

/-! ## 7. Read-outs, coarsenings, and the two channels -/

/-- **Entropy sees only the partition.** Two read-outs that induce the same fibre
partition on `s` have the same counting entropy.  This strengthens
`CyclicTypeChannel.uEnt_comp_injOn`, which covers the special case of an
injective recoding `g' = f ∘ g`: here the two read-outs need not be related by
any map at all. -/
theorem uEnt_congr_fibers {α β β' : Type*} [DecidableEq β] [DecidableEq β'] {s : Finset α}
    {g : α → β} {g' : α → β'} (h : ∀ x ∈ s, ∀ y ∈ s, (g x = g y ↔ g' x = g' y)) :
    uEnt s g = uEnt s g' := by
  have hfib : ∀ a ∈ s, {x ∈ s | g x = g a} = {x ∈ s | g' x = g' a} := fun a ha =>
    Finset.filter_congr fun x hx => h x hx a ha
  rw [uEnt, uEnt, Finset.sum_congr rfl fun a ha => by rw [hfib a ha]]

/-- The conditional version: it is enough that the two read-outs induce the same
partition *inside each fibre* of the side channel. -/
theorem condEnt_congr_fibers {α β β' γ : Type*} [DecidableEq β] [DecidableEq β'] [DecidableEq γ]
    {s : Finset α} {g : α → β} {g' : α → β'} {k : α → γ}
    (h : ∀ x ∈ s, ∀ y ∈ s, k x = k y → (g x = g y ↔ g' x = g' y)) :
    condEnt s g k = condEnt s g' k := by
  refine Finset.sum_congr rfl fun c _ => ?_
  congr 1
  refine uEnt_congr_fibers fun x hx y hy => ?_
  simp only [Finset.mem_filter] at hx hy
  exact h x hx.1 y hy.1 (by rw [hx.2, hy.2])

/-- The type pair of a prime degree, in closed form. -/
theorem typePair_prime_cases {q a b : ℕ} (hq : q.Prime) (ha : a < q) (hb : b < q) :
    typePair q (a, b) = if a = 0 then (if b = 0 then (1, 1) else (1, q))
      else (if b = 0 then (1, q) else (q, q)) := by
  have h1 : ordType q a = if a = 0 then 1 else q := ordType_prime hq ha
  have h2 : ordType q b = if b = 0 then 1 else q := ordType_prime hq hb
  have hq1 : (1 : ℕ) ≤ q := hq.pos
  rcases eq_or_ne a 0 with rfl | ha0 <;> rcases eq_or_ne b 0 with rfl | hb0 <;>
    simp_all [typePair]

/-- **The split count is a sufficient statistic at prime degree.** The number of
split factors already determines the whole (unordered) type pair. -/
theorem typePair_eq_of_sProj_eq {q : ℕ} (hq : q.Prime) {x y : ℕ × ℕ} (hx : x ∈ box q)
    (hy : y ∈ box q) (h : sProj (typePair q x) = sProj (typePair q y)) :
    typePair q x = typePair q y := by
  obtain ⟨a, b⟩ := x
  obtain ⟨c, d⟩ := y
  rw [mem_box_iff] at hx hy
  rw [sProj_typePair_prime hq hx.1 hx.2, sProj_typePair_prime hq hy.1 hy.2] at h
  rw [typePair_prime_cases hq hx.1 hx.2, typePair_prime_cases hq hy.1 hy.2]
  by_cases ha : a = 0 <;> by_cases hb : b = 0 <;> by_cases hc : c = 0 <;> by_cases hd : d = 0 <;>
    simp_all

/-- **The `s`-projection is information-lossless at prime degree**: the type-pair
channel and the split-count channel carry exactly the same information. -/
theorem Ipair_eq_Isplit_prime {q : ℕ} (hq : q.Prime) : Ipair q = Isplit q := by
  have hiff : ∀ x ∈ box q, ∀ y ∈ box q,
      (typePair q x = typePair q y ↔ (sProj ∘ typePair q) x = (sProj ∘ typePair q) y) := by
    intro x hx y hy
    exact ⟨fun h => by simp [Function.comp_apply, h],
      fun h => typePair_eq_of_sProj_eq hq hx hy h⟩
  rw [Ipair, Isplit, mutInfo, mutInfo, uEnt_congr_fibers hiff,
    condEnt_congr_fibers fun x hx y hy _ => hiff x hx y hy]

/-- The **OR read-out**: `1` if at least one of the two prime factors splits
completely, `0` otherwise. -/
def oProj (t : ℕ × ℕ) : ℕ := min (sProj t) 1

/-- The **OR channel** `G = I(at least one factor splits ; N mod f)`. -/
noncomputable def IOR (n : ℕ) : ℝ := mutInfo (box n) (oProj ∘ typePair n) (prodRes n)

theorem oProj_eq_one_iff (t : ℕ × ℕ) : oProj t = 1 ↔ sProj t ≠ 0 := by
  rw [oProj]
  omega

theorem oProj_binary (t : ℕ × ℕ) : oProj t = 1 ∨ oProj t = 0 := by
  rw [oProj]; omega

theorem sProj_le_two (t : ℕ × ℕ) : sProj t ≤ 2 := by
  rw [sProj]
  split_ifs <;> omega

/-- `2q - 1` of the `q²` exponent pairs have at least one split factor. -/
theorem card_or_one {q : ℕ} (hq : q.Prime) :
    #{x ∈ box q | (oProj ∘ typePair q) x = 1} = 2 * q - 1 := by
  have hsplit : {x ∈ CyclicTypeChannel.box q | (oProj ∘ typePair q) x = 1}
      = {x ∈ CyclicTypeChannel.box q | sProj (typePair q x) = 1}
        ∪ {x ∈ CyclicTypeChannel.box q | sProj (typePair q x) = 2} := by
    ext x
    simp only [Finset.mem_union, mem_filter, Function.comp_apply, oProj_eq_one_iff]
    have hle := sProj_le_two (typePair q x)
    constructor
    · rintro ⟨hx, h⟩
      rcases (by omega : sProj (typePair q x) = 1 ∨ sProj (typePair q x) = 2) with h1 | h1
      exacts [Or.inl ⟨hx, h1⟩, Or.inr ⟨hx, h1⟩]
    · rintro (⟨hx, h⟩ | ⟨hx, h⟩) <;> exact ⟨hx, by omega⟩
  have hdisj : Disjoint {x ∈ CyclicTypeChannel.box q | sProj (typePair q x) = 1}
      {x ∈ CyclicTypeChannel.box q | sProj (typePair q x) = 2} := by
    rw [Finset.disjoint_left]
    intro x h1 h2
    simp only [mem_filter] at h1 h2
    omega
  have hq1 : 1 ≤ q := hq.pos
  rw [hsplit, Finset.card_union_of_disjoint hdisj, card_splitCount_one hq,
    card_splitCount_two hq]
  omega

/-- **The unconditional entropy of the OR read-out.** -/
theorem uEnt_or_prime {q : ℕ} (hq : q.Prime) :
    uEnt (box q) (oProj ∘ typePair q) = binEnt (q * q) (2 * q - 1) := by
  have h := uEnt_binary (s := box q) (g := oProj ∘ typePair q) (v := 1) (w := 0)
    (by norm_num) (fun x _ => oProj_binary _)
  rw [h, card_or_one hq, card_box]

/-- Inside one fibre of the product residue the split count takes at most one
nonzero value, so the OR read-out induces the *same* partition there. -/
theorem sProj_eq_of_oProj_eq_fiber {q : ℕ} (hq : q.Prime) {x y : ℕ × ℕ} (hx : x ∈ box q)
    (hy : y ∈ box q) (hk : prodRes q x = prodRes q y)
    (h : (oProj ∘ typePair q) x = (oProj ∘ typePair q) y) :
    (sProj ∘ typePair q) x = (sProj ∘ typePair q) y := by
  obtain ⟨a, b⟩ := x
  obtain ⟨c, d⟩ := y
  rw [mem_box_iff] at hx hy
  simp only [Function.comp_apply, oProj] at h
  have hs1 := sProj_typePair_prime hq hx.1 hx.2
  have hs2 := sProj_typePair_prime hq hy.1 hy.2
  simp only [Function.comp_apply, hs1, hs2] at h ⊢
  rcases eq_or_ne a 0 with rfl | ha <;> rcases eq_or_ne b 0 with rfl | hb <;>
    rcases eq_or_ne c 0 with rfl | hc <;> rcases eq_or_ne d 0 with rfl | hd <;>
    simp_all [prodRes, Nat.mod_eq_of_lt, hq.pos]
  omega

/-- **The conditional-entropy coincidence.** Conditioned on the residue of the
semiprime, the split count and the OR indicator carry the same uncertainty. -/
theorem condEnt_or_eq_condEnt_split_prime {q : ℕ} (hq : q.Prime) :
    condEnt (box q) (oProj ∘ typePair q) (prodRes q)
      = condEnt (box q) (sProj ∘ typePair q) (prodRes q) :=
  condEnt_congr_fibers fun x hx y hy hk =>
    ⟨fun h => sProj_eq_of_oProj_eq_fiber hq hx hy hk h, fun h => by
      simp only [Function.comp_apply, oProj] at *; rw [h]⟩

/-- **The two channels differ exactly by their unconditional entropies.** -/
theorem Isplit_sub_IOR_prime {q : ℕ} (hq : q.Prime) :
    Isplit q - IOR q
      = uEnt (box q) (sProj ∘ typePair q) - uEnt (box q) (oProj ∘ typePair q) := by
  rw [Isplit, IOR, mutInfo, mutInfo, condEnt_or_eq_condEnt_split_prime hq]
  ring

/-- **Data processing for the OR coarsening.**  Since the conditional entropies
coincide, the OR channel can never exceed the split-count channel — at *any*
prime degree. -/
theorem IOR_le_Isplit_prime {q : ℕ} (hq : q.Prime) : IOR q ≤ Isplit q := by
  have hcomp : (oProj ∘ typePair q) = (fun s => min s 1) ∘ (sProj ∘ typePair q) := rfl
  have hle : uEnt (CyclicTypeChannel.box q) (oProj ∘ typePair q)
      ≤ uEnt (CyclicTypeChannel.box q) (sProj ∘ typePair q) := by
    rw [hcomp]
    exact uEnt_comp_le _ _ _
  have hgap := Isplit_sub_IOR_prime hq
  linarith

/-- **The OR channel of a prime degree — a closed form.** -/
theorem IOR_prime {q : ℕ} (hq : q.Prime) :
    IOR q = binEnt (q * q) (2 * q - 1)
      - ((1 / (q : ℝ)) * binEnt q 1 + (((q : ℝ) - 1) / q) * binEnt q 2) := by
  rw [IOR, mutInfo, uEnt_or_prime hq, condEnt_or_eq_condEnt_split_prime hq,
    condEnt_splitCount_prime hq]

/-! ## 8. The degree-7 values of the two channels -/

private theorem lb7_49 : Real.logb 2 (49 : ℝ) = 2 * Real.logb 2 7 := by
  rw [show (49 : ℝ) = 7 ^ 2 by norm_num, Real.logb_pow]
  norm_num

private theorem lb7_36 : Real.logb 2 (36 : ℝ) = 2 + 2 * Real.logb 2 3 := by
  rw [show (36 : ℝ) = 2 ^ 2 * 3 ^ 2 by norm_num,
    Real.logb_mul (by norm_num) (by norm_num), Real.logb_pow, Real.logb_pow,
    Real.logb_self_eq_one (by norm_num)]
  ring

private theorem lb7_12 : Real.logb 2 (12 : ℝ) = 2 + Real.logb 2 3 := by
  rw [show (12 : ℝ) = 2 ^ 2 * 3 by norm_num,
    Real.logb_mul (by norm_num) (by norm_num), Real.logb_pow,
    Real.logb_self_eq_one (by norm_num)]
  ring

private theorem lb7_6 : Real.logb 2 (6 : ℝ) = 1 + Real.logb 2 3 := by
  rw [show (6 : ℝ) = 2 * 3 by norm_num, Real.logb_mul (by norm_num) (by norm_num),
    Real.logb_self_eq_one (by norm_num)]

/-- **The degree-7 split-count channel in closed form.** -/
theorem Isplit_seven_value :
    Isplit 7 = Real.logb 2 7
      + (30 * Real.logb 2 5 - 78 * Real.logb 2 3 - 78) / 49 := by
  rw [Isplit_prime (by norm_num), binEnt, binEnt]
  norm_num [lb7_49, lb7_36, lb7_12, lb7_6]
  ring

/-- **The degree-7 OR channel in closed form.** -/
theorem IOR_seven_value :
    IOR 7 = Real.logb 2 7
      + (30 * Real.logb 2 5 - 66 * Real.logb 2 3 - 13 * Real.logb 2 13 - 54) / 49 := by
  rw [IOR_prime (by norm_num), binEnt, binEnt, binEnt]
  norm_num [lb7_49, lb7_36, lb7_12, lb7_6]
  ring

/-- **A certified bracket for the degree-7 split-count channel.**  The witnesses
are the integer inequalities `2¹⁶⁷¹⁸ · 3¹⁵⁶⁰⁰ < 7⁹⁸⁰⁰ · 5⁶⁰⁰⁰` and
`7⁹⁸⁰⁰ · 5⁶⁰⁰⁰ < 2¹⁶⁷¹⁹ · 3¹⁵⁶⁰⁰`. -/
theorem Isplit_seven_bracket : 0.1140 < Isplit 7 ∧ Isplit 7 < 0.1142 := by
  set A : ℝ := 49 * Real.logb 2 7 + 30 * Real.logb 2 5 - 78 * Real.logb 2 3 with hA
  have hval : Isplit 7 = (A - 78) / 49 := by
    rw [Isplit_seven_value, hA]; ring
  have hlow : (16718 : ℝ) < 200 * A := by
    have hnat : (2 : ℕ) ^ 16718 * 3 ^ 15600 < 7 ^ 9800 * 5 ^ 6000 := by norm_num
    have hR : ((2 : ℝ) ^ 16718 * 3 ^ 15600) < ((7 : ℝ) ^ 9800 * 5 ^ 6000) := by
      calc ((2 : ℝ) ^ 16718 * 3 ^ 15600) = ((2 ^ 16718 * 3 ^ 15600 : ℕ) : ℝ) := by push_cast; ring
        _ < ((7 ^ 9800 * 5 ^ 6000 : ℕ) : ℝ) := by exact_mod_cast hnat
        _ = ((7 : ℝ) ^ 9800 * 5 ^ 6000) := by push_cast; ring
    have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
    rw [Real.logb_mul (by positivity) (by positivity),
      Real.logb_mul (by positivity) (by positivity),
      Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)] at h
    push_cast at h
    rw [hA]; linarith
  have hhigh : 200 * A < (16719 : ℝ) := by
    have hnat : (7 : ℕ) ^ 9800 * 5 ^ 6000 < 2 ^ 16719 * 3 ^ 15600 := by norm_num
    have hR : ((7 : ℝ) ^ 9800 * 5 ^ 6000) < ((2 : ℝ) ^ 16719 * 3 ^ 15600) := by
      calc ((7 : ℝ) ^ 9800 * 5 ^ 6000) = ((7 ^ 9800 * 5 ^ 6000 : ℕ) : ℝ) := by push_cast; ring
        _ < ((2 ^ 16719 * 3 ^ 15600 : ℕ) : ℝ) := by exact_mod_cast hnat
        _ = ((2 : ℝ) ^ 16719 * 3 ^ 15600) := by push_cast; ring
    have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
    rw [Real.logb_mul (by positivity) (by positivity),
      Real.logb_mul (by positivity) (by positivity),
      Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)] at h
    push_cast at h
    rw [hA]; linarith
  rw [hval]
  constructor <;> [linarith; linarith]

/-- **A certified bracket for the degree-7 OR channel.**  The witnesses are
`2¹⁶³⁵¹ · 3¹⁹⁸⁰⁰ · 13³⁹⁰⁰ < 7¹⁴⁷⁰⁰ · 5⁹⁰⁰⁰` and its companion. -/
theorem IOR_seven_bracket : 0.01027 < IOR 7 ∧ IOR 7 < 0.01035 := by
  set B : ℝ := 49 * Real.logb 2 7 + 30 * Real.logb 2 5 - 66 * Real.logb 2 3
    - 13 * Real.logb 2 13 with hB
  have hval : IOR 7 = (B - 54) / 49 := by
    rw [IOR_seven_value, hB]; ring
  have hlow : (16351 : ℝ) < 300 * B := by
    have hnat : (2 : ℕ) ^ 16351 * 3 ^ 19800 * 13 ^ 3900 < 7 ^ 14700 * 5 ^ 9000 := by norm_num
    have hR : ((2 : ℝ) ^ 16351 * 3 ^ 19800 * 13 ^ 3900) < ((7 : ℝ) ^ 14700 * 5 ^ 9000) := by
      calc ((2 : ℝ) ^ 16351 * 3 ^ 19800 * 13 ^ 3900)
          = ((2 ^ 16351 * 3 ^ 19800 * 13 ^ 3900 : ℕ) : ℝ) := by push_cast; ring
        _ < ((7 ^ 14700 * 5 ^ 9000 : ℕ) : ℝ) := by exact_mod_cast hnat
        _ = ((7 : ℝ) ^ 14700 * 5 ^ 9000) := by push_cast; ring
    have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
    rw [Real.logb_mul (by positivity) (by positivity),
      Real.logb_mul (by positivity) (by positivity),
      Real.logb_mul (by positivity) (by positivity),
      Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)] at h
    push_cast at h
    rw [hB]; linarith
  have hhigh : 300 * B < (16352 : ℝ) := by
    have hnat : (7 : ℕ) ^ 14700 * 5 ^ 9000 < 2 ^ 16352 * 3 ^ 19800 * 13 ^ 3900 := by norm_num
    have hR : ((7 : ℝ) ^ 14700 * 5 ^ 9000) < ((2 : ℝ) ^ 16352 * 3 ^ 19800 * 13 ^ 3900) := by
      calc ((7 : ℝ) ^ 14700 * 5 ^ 9000) = ((7 ^ 14700 * 5 ^ 9000 : ℕ) : ℝ) := by push_cast; ring
        _ < ((2 ^ 16352 * 3 ^ 19800 * 13 ^ 3900 : ℕ) : ℝ) := by exact_mod_cast hnat
        _ = ((2 : ℝ) ^ 16352 * 3 ^ 19800 * 13 ^ 3900) := by push_cast; ring
    have h := Real.logb_lt_logb (b := 2) (by norm_num) (by positivity) hR
    rw [Real.logb_mul (by positivity) (by positivity),
      Real.logb_mul (by positivity) (by positivity),
      Real.logb_mul (by positivity) (by positivity),
      Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow, Real.logb_pow,
      Real.logb_self_eq_one (by norm_num)] at h
    push_cast at h
    rw [hB]; linarith
  rw [hval]
  constructor <;> [linarith; linarith]

/-- **The reported figure `Is(7) = 0.1161` is not reproduced.** Under the
catalog's definition the split-count channel of the degree-7 rung is `0.11410…`,
short of the report by more than `0.0018` bits. -/
theorem Isplit_seven_lt_reported : Isplit 7 < 0.1161 ∧ 0.0018 < 0.1161 - Isplit 7 := by
  obtain ⟨_, h2⟩ := Isplit_seven_bracket
  constructor <;> linarith

/-- **The ledger disclosure is confirmed.** The anchor `0.0103` is the OR channel:
the degree-7 value of `G` agrees with it to better than `5 · 10⁻⁵`. -/
theorem IOR_seven_matches_ledger : |IOR 7 - 0.0103| < 0.00005 := by
  obtain ⟨h1, h2⟩ := IOR_seven_bracket
  rw [abs_lt]
  constructor <;> linarith

/-- The ladder is strictly decreasing between the two rungs computed so far. -/
theorem Isplit_eleven_lt_Isplit_seven : Isplit 11 < Isplit 7 := by
  obtain ⟨h1, _⟩ := Isplit_seven_bracket
  obtain ⟨_, h4⟩ := Isplit_eleven_bracket
  linarith

/-- **The misattributed anchor belongs to the degree-7 rung.**  The round-50
figure `0.116`, reported there as the degree-11 split channel, is more than
thirty times closer to the degree-7 value than to the degree-11 value. -/
theorem anchor_116_closer_to_deg7 : |Isplit 7 - 0.116| < |Isplit 11 - 0.116| := by
  obtain ⟨h1, h2⟩ := Isplit_seven_bracket
  obtain ⟨_, h4⟩ := Isplit_eleven_bracket
  have h7 : |Isplit 7 - 0.116| = 0.116 - Isplit 7 := by
    rw [abs_sub_comm]
    exact abs_of_pos (by linarith)
  have h11 : |Isplit 11 - 0.116| = 0.116 - Isplit 11 := by
    rw [abs_sub_comm]
    exact abs_of_pos (by linarith)
  rw [h7, h11]
  linarith

/-- **The OR coarsening is catastrophic.** Collapsing the split count to a single
bit destroys more than ninety percent of the channel: at degree 7 the split-count
channel is more than eleven times the OR channel. -/
theorem IOR_seven_lt_Isplit_seven : 11 * IOR 7 < Isplit 7 := by
  obtain ⟨_, h2⟩ := IOR_seven_bracket
  obtain ⟨h3, _⟩ := Isplit_seven_bracket
  linarith

end AbelianLadder