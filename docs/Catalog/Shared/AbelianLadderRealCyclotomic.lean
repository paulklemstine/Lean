/-
# The abelian ladder at degree 11: full pinning in the real cyclotomic tower

This file formalises the *degree-11 rung* of the abelian splitting-type ladder,
i.e. the maximal real subfield `Q(ζ₂₃)⁺`, whose Galois group over `Q` is the
cyclic group of prime order `11`.

The experimental round that motivates the file recorded four predictions:

* `T(p) = 1` exactly when the discrete logarithm of `p` vanishes modulo `11`
  (equivalently, in arithmetic form, exactly when `p ≡ ±1 (mod 23)`);
* the two type-densities are `1/11` and `10/11`, giving
  `H(T) = log₂ 11 - (10/11) log₂ 10 = 0.4394…` bits;
* the residue channel is *fully pinned*: the mutual information between the
  Frobenius class and the type equals `H(T)` exactly, every conditional
  distribution being degenerate;
* the semiprime split-count follows `Bin(2, 1/11)`, i.e. the counts
  `(100, 20, 1)` out of `121`.

Everything below is proved for a general prime degree wherever the proof is not
genuinely specific to `23`, and specialised to degree `11` at the end.

The main results are

* `binEnt_scale` — the counting entropy depends only on the *ratio* of the fibre
  counts (a scale invariance that makes the `C₁₁`-model and the `(Z/23)ˣ`-model
  literally the same number);
* `uEnt_binary` — the closed form of a two-valued counting entropy;
* `typeEntropy_prime_eq_binEnt` — `H(T) = binEnt q 1` for every prime degree `q`;
* `realDeg_eq_one_iff`, `realDeg_23_eq_one_or_eleven`, `realDeg_23_prime_iff` —
  the arithmetic pinning law: the residue degree of `p` in `Q(ζ₂₃)⁺` is `1` if
  `p ≡ ±1 (mod 23)` and `11` otherwise;
* `uEnt_realDeg_23` and `typeEntropy_eleven_eq` — the two entropies agree, with
  the numerical bracket `0.4394 < H(T) < 0.4396` (`typeEntropy_eleven_bracket`);
* `full_pinning_deg11` — the sign class of `p mod 23` pins the type exactly:
  `I(class ; T) = H(T)` with vanishing conditional entropy;
* `quadratic_character_carries_no_information` — the orthogonal statement: the
  quadratic character mod `23` carries *zero* information about the degree-11
  type;
* `card_splitCount_*` — the `Bin(2, 1/q)` law for the semiprime split count,
  giving `(100, 20, 1)` at `q = 11`.
-/
import Shared.CyclicTypeChannelPrime

namespace AbelianLadder

open Finset CyclicTypeChannel

set_option exponentiation.threshold 100000
set_option maxRecDepth 100000

/-! ## 1. Binary counting entropy -/

/-- The counting entropy of a two-valued read-out with fibre sizes `m` and
`N - m` inside a set of size `N`. -/
noncomputable def binEnt (N m : ℕ) : ℝ :=
  Real.logb 2 N - ((m : ℝ) * Real.logb 2 m + ((N : ℝ) - m) * Real.logb 2 ((N : ℝ) - m)) / N

/-- **Two-valued entropy has a closed form.** If a read-out `g` takes only the two
values `v ≠ w` on `s`, its counting entropy is `binEnt |s| |g⁻¹(v)|`. -/
theorem uEnt_binary {α β : Type*} [DecidableEq β] {s : Finset α} {g : α → β} {v w : β}
    (hvw : v ≠ w) (hg : ∀ x ∈ s, g x = v ∨ g x = w) :
    uEnt s g = binEnt s.card (#{x ∈ s | g x = v}) := by
  classical
  set m : ℕ := #{x ∈ s | g x = v} with hm
  have hmle : m ≤ s.card := card_filter_le _ _
  -- the complementary fibre
  have hcompl : #{x ∈ s | ¬ g x = v} = s.card - m := by
    have := Finset.card_filter_add_card_filter_not (s := s) (p := fun x => g x = v)
    omega
  -- the fibre of a point where `g` takes the value `v`
  have hfib_v : ∀ a ∈ s, g a = v → #{x ∈ s | g x = g a} = m := by
    intro a _ ha; rw [ha]
  have hfib_w : ∀ a ∈ s, ¬ g a = v → #{x ∈ s | g x = g a} = s.card - m := by
    intro a ha hav
    have haw : g a = w := (hg a ha).resolve_left hav
    rw [haw, ← hcompl]
    refine congrArg _ (Finset.filter_congr ?_)
    intro x hx
    rcases hg x hx with h | h
    · simp [h, hvw]
    · simp [h, Ne.symm hvw]
  have hsplit : (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ))
      = (m : ℝ) * Real.logb 2 m + ((s.card : ℝ) - m) * Real.logb 2 ((s.card : ℝ) - m) := by
    rw [← Finset.sum_filter_add_sum_filter_not s (fun a => g a = v)
      (fun a => Real.logb 2 (#{x ∈ s | g x = g a} : ℝ))]
    have h1 : ∑ a ∈ {x ∈ s | g x = v}, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
        = (m : ℝ) * Real.logb 2 m := by
      rw [Finset.sum_congr rfl (fun a ha => by
        have ha' := Finset.mem_filter.1 ha
        rw [hfib_v a ha'.1 ha'.2])]
      simp [← hm]
    have h2 : ∑ a ∈ {x ∈ s | ¬ g x = v}, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
        = ((s.card : ℝ) - m) * Real.logb 2 ((s.card : ℝ) - m) := by
      rw [Finset.sum_congr rfl (fun a ha => by
        have ha' := Finset.mem_filter.1 ha
        rw [hfib_w a ha'.1 ha'.2])]
      rw [Finset.sum_const, hcompl, nsmul_eq_mul, Nat.cast_sub hmle]
    rw [h1, h2]
  rw [uEnt, binEnt, hsplit]

/-- **Scale invariance of the counting entropy.** Multiplying all fibre counts by
a positive constant does not change the entropy: only the ratios matter. -/
theorem binEnt_scale {N m c : ℕ} (hc : 0 < c) (hm : 0 < m) (hmN : m < N) :
    binEnt (c * N) (c * m) = binEnt N m := by
  have hc0 : (0 : ℝ) < c := by exact_mod_cast hc
  have hm0 : (0 : ℝ) < m := by exact_mod_cast hm
  have hN0 : (0 : ℝ) < N := by exact_mod_cast hm.trans hmN
  have hd0 : (0 : ℝ) < (N : ℝ) - m := by
    have : (m : ℝ) < N := by exact_mod_cast hmN
    linarith
  have hsub : ((c * N : ℕ) : ℝ) - ((c * m : ℕ) : ℝ) = (c : ℝ) * ((N : ℝ) - m) := by
    push_cast; ring
  rw [binEnt, binEnt, hsub]
  push_cast
  rw [Real.logb_mul (ne_of_gt hc0) (ne_of_gt hN0), Real.logb_mul (ne_of_gt hc0) (ne_of_gt hm0),
    Real.logb_mul (ne_of_gt hc0) (ne_of_gt hd0)]
  field_simp
  ring

/-- The closed form of `binEnt N 1`: one distinguished point against `N - 1`. -/
theorem binEnt_one (N : ℕ) :
    binEnt N 1 = Real.logb 2 N - ((N : ℝ) - 1) * Real.logb 2 ((N : ℝ) - 1) / N := by
  simp [binEnt]

/-! ## 2. The type channel of a prime cyclic degree -/

/-- For a prime degree the type read-out is two-valued: the identity class has
type `1`, everything else has type `q`. -/
theorem ordType_prime_binary {q a : ℕ} (hq : q.Prime) (ha : a < q) :
    ordType q a = 1 ∨ ordType q a = q := by
  rw [ordType_prime hq ha]
  split <;> simp

/-- The set of exponents of type `1` is the singleton `{0}`. -/
theorem filter_ordType_eq_one {q : ℕ} (hq : q.Prime) :
    {a ∈ range q | ordType q a = 1} = {0} := by
  ext a
  simp only [mem_filter, mem_range, mem_singleton]
  constructor
  · rintro ⟨ha, h1⟩
    by_contra h0
    rw [ordType_prime hq ha, if_neg h0] at h1
    exact hq.one_lt.ne' h1
  · rintro rfl
    exact ⟨hq.pos, ordType_zero hq.pos⟩

/-- **The type entropy of a prime degree is a binary entropy.** -/
theorem typeEntropy_prime_eq_binEnt {q : ℕ} (hq : q.Prime) :
    typeEntropy q = binEnt q 1 := by
  have h := uEnt_binary (s := range q) (g := ordType q) (v := 1) (w := q)
    (hq.one_lt.ne) (fun a ha => ordType_prime_binary hq (mem_range.1 ha))
  rw [typeEntropy, h, filter_ordType_eq_one hq, card_range, card_singleton]

/-- **The prime-degree type entropy in closed form**:
`H(T) = log₂ q - ((q-1)/q) · log₂ (q-1)`, i.e. the binary entropy of the
splitting density `1/q`. -/
theorem typeEntropy_prime_formula {q : ℕ} (hq : q.Prime) :
    typeEntropy q = Real.logb 2 q - ((q : ℝ) - 1) / q * Real.logb 2 ((q : ℝ) - 1) := by
  rw [typeEntropy_prime_eq_binEnt hq, binEnt_one]
  ring

/-- The degree-11 rung: `H(T) = log₂ 11 - (10/11) log₂ 10`. -/
theorem typeEntropy_eleven_eq :
    typeEntropy 11 = Real.logb 2 11 - (10 / 11 : ℝ) * Real.logb 2 10 := by
  rw [typeEntropy_prime_formula (by norm_num)]
  norm_num

/-! ### The numerical value `H(T) = 0.4394…` -/

/-- `11 · H(T) = log₂ (11¹¹ / 10¹⁰)`. -/
theorem eleven_mul_typeEntropy :
    11 * typeEntropy 11 = Real.logb 2 ((11 : ℝ) ^ 11 / (10 : ℝ) ^ 10) := by
  rw [typeEntropy_eleven_eq, Real.logb_div (by positivity) (by positivity),
    Real.logb_pow, Real.logb_pow]
  ring

private lemma logb_pow_lt {x y : ℝ} (hx : 0 < x) (h : x < y) :
    Real.logb 2 x < Real.logb 2 y :=
  Real.logb_lt_logb (by norm_num) hx h

/-- **The degree-11 entropy bracket**: `0.4394 < H(T) < 0.4396` bits.
The two witnesses are the exact integer inequalities
`2²⁴¹⁷ · 10⁵⁰⁰⁰ < 11⁵⁵⁰⁰` and `11²²⁰⁰ < 2⁹⁶⁷ · 10²⁰⁰⁰`. -/
theorem typeEntropy_eleven_bracket :
    0.4394 < typeEntropy 11 ∧ typeEntropy 11 < 0.4396 := by
  set R : ℝ := (11 : ℝ) ^ 11 / (10 : ℝ) ^ 10 with hR
  have hR0 : 0 < R := by rw [hR]; positivity
  have hlog : Real.logb 2 R = 11 * typeEntropy 11 := (eleven_mul_typeEntropy).symm
  -- lower bound : `2 ^ 2417 < R ^ 500`
  have hlow : (2 : ℝ) ^ 2417 < R ^ 500 := by
    have hpow : R ^ 500 = (11 : ℝ) ^ 5500 / (10 : ℝ) ^ 5000 := by
      rw [hR, div_pow, ← pow_mul, ← pow_mul]
    rw [hpow, lt_div_iff₀ (by positivity)]
    have hnat : (2 : ℕ) ^ 2417 * 10 ^ 5000 < 11 ^ 5500 := by norm_num
    calc (2 : ℝ) ^ 2417 * (10 : ℝ) ^ 5000
        = ((2 ^ 2417 * 10 ^ 5000 : ℕ) : ℝ) := by push_cast; ring
      _ < ((11 ^ 5500 : ℕ) : ℝ) := by exact_mod_cast hnat
      _ = (11 : ℝ) ^ 5500 := by push_cast; ring
  -- upper bound : `R ^ 200 < 2 ^ 967`
  have hhigh : R ^ 200 < (2 : ℝ) ^ 967 := by
    have hpow : R ^ 200 = (11 : ℝ) ^ 2200 / (10 : ℝ) ^ 2000 := by
      rw [hR, div_pow, ← pow_mul, ← pow_mul]
    rw [hpow, div_lt_iff₀ (by positivity)]
    have hnat : (11 : ℕ) ^ 2200 < 2 ^ 967 * 10 ^ 2000 := by norm_num
    calc (11 : ℝ) ^ 2200 = ((11 ^ 2200 : ℕ) : ℝ) := by push_cast; ring
      _ < ((2 ^ 967 * 10 ^ 2000 : ℕ) : ℝ) := by exact_mod_cast hnat
      _ = (2 : ℝ) ^ 967 * (10 : ℝ) ^ 2000 := by push_cast; ring
  have h1 : (2417 : ℝ) < 500 * Real.logb 2 R := by
    have h := logb_pow_lt (x := (2 : ℝ) ^ 2417) (y := R ^ 500) (by positivity) hlow
    rw [Real.logb_pow, Real.logb_pow] at h
    simpa using h
  have h2 : 200 * Real.logb 2 R < (967 : ℝ) := by
    have h := logb_pow_lt (x := R ^ 200) (y := (2 : ℝ) ^ 967) (by positivity) hhigh
    rw [Real.logb_pow, Real.logb_pow] at h
    simpa using h
  rw [hlog] at h1 h2
  constructor <;> [linarith; linarith]

/-! ## 3. The arithmetic of `Q(ζ_f)⁺`: the sign quotient -/

/-- The subgroup `{±1}` of `(Z/f)ˣ`: the decomposition subgroup of complex
conjugation, whose fixed field is the maximal real subfield `Q(ζ_f)⁺`. -/
def signSub (f : ℕ) : Subgroup (ZMod f)ˣ := Subgroup.zpowers (-1 : (ZMod f)ˣ)

@[simp] theorem mem_signSub {f : ℕ} {u : (ZMod f)ˣ} : u ∈ signSub f ↔ u = 1 ∨ u = -1 := by
  constructor
  · rintro ⟨k, rfl⟩
    have hsq : (-1 : (ZMod f)ˣ) ^ (2 : ℤ) = 1 := by
      rw [show (2 : ℤ) = ((2 : ℕ) : ℤ) from rfl, zpow_natCast]; simp
    rcases Int.even_or_odd k with ⟨m, hm⟩ | ⟨m, hm⟩
    · subst hm; left
      show (-1 : (ZMod f)ˣ) ^ (m + m) = 1
      rw [← two_mul, zpow_mul, hsq, one_zpow]
    · subst hm; right
      show (-1 : (ZMod f)ˣ) ^ (2 * m + 1) = -1
      rw [zpow_add, zpow_mul, hsq, one_zpow, one_mul, zpow_one]
  · rintro (rfl | rfl)
    · exact one_mem _
    · exact ⟨(1 : ℤ), zpow_one _⟩

/-- The **residue degree in the real cyclotomic field** `Q(ζ_f)⁺`: the order of
the Frobenius class of the unit `u` in the sign quotient `(Z/f)ˣ / {±1}`, which
is the Galois group of `Q(ζ_f)⁺ / Q`. -/
noncomputable def realDeg (f : ℕ) (u : (ZMod f)ˣ) : ℕ :=
  orderOf (QuotientGroup.mk' (signSub f) u)

/-- **Complete splitting in the real subfield is the `±1` condition.** -/
theorem realDeg_eq_one_iff {f : ℕ} {u : (ZMod f)ˣ} :
    realDeg f u = 1 ↔ u = 1 ∨ u = -1 := by
  rw [realDeg, orderOf_eq_one_iff]
  exact (QuotientGroup.eq_one_iff u).trans mem_signSub

/-- The residue degree is insensitive to the sign: `p` and `-p` have the same
Frobenius in `Q(ζ_f)⁺`. -/
theorem realDeg_neg {f : ℕ} (u : (ZMod f)ˣ) : realDeg f (-u) = realDeg f u := by
  have h1 : (QuotientGroup.mk' (signSub f)) (-1 : (ZMod f)ˣ) = 1 :=
    (QuotientGroup.eq_one_iff _).2 (mem_signSub.2 (Or.inr rfl))
  have h : (QuotientGroup.mk' (signSub f)) (-u) = (QuotientGroup.mk' (signSub f)) u := by
    rw [← neg_one_mul, map_mul, h1]
    exact one_mul ((QuotientGroup.mk' (signSub f)) u)
  rw [realDeg, realDeg, h]

/-! ### The degree-11 rung: `f = 23` -/

theorem card_units_23 : Nat.card (ZMod 23)ˣ = 22 := by
  rw [Nat.card_eq_fintype_card, ZMod.card_units_eq_totient]
  decide

theorem neg_one_ne_one_23 : (-1 : (ZMod 23)ˣ) ≠ 1 := by decide

theorem card_signSub_23 : Nat.card (signSub 23) = 2 := by
  rw [signSub, Nat.card_zpowers]
  exact orderOf_eq_prime (by simp) neg_one_ne_one_23

/-- **The Galois group of `Q(ζ₂₃)⁺` has order 11** — the eleventh rung of the
abelian ladder. -/
theorem card_quot_23 : Nat.card ((ZMod 23)ˣ ⧸ signSub 23) = 11 := by
  have h := Subgroup.card_eq_card_quotient_mul_card_subgroup (signSub 23)
  rw [card_units_23, card_signSub_23] at h
  omega

/-- **Prime-degree dichotomy at degree 11**: every prime is either totally split
or inert-of-degree-11 in `Q(ζ₂₃)⁺`. -/
theorem realDeg_23_eq_one_or_eleven (u : (ZMod 23)ˣ) :
    realDeg 23 u = 1 ∨ realDeg 23 u = 11 := by
  have hdvd : realDeg 23 u ∣ 11 := by
    rw [realDeg, ← card_quot_23]
    exact orderOf_dvd_natCard _
  have h11 : Nat.Prime 11 := by norm_num
  rcases (Nat.Prime.eq_one_or_self_of_dvd h11 _ hdvd) with h | h
  · exact Or.inl h
  · exact Or.inr h

/-- **The pinning law in arithmetic form.** The residue degree of a unit is `11`
unless the unit is `±1`. -/
theorem realDeg_23_eq_eleven_iff {u : (ZMod 23)ˣ} :
    realDeg 23 u = 11 ↔ u ≠ 1 ∧ u ≠ -1 := by
  constructor
  · intro h
    have : realDeg 23 u ≠ 1 := by omega
    have := (not_iff_not.2 realDeg_eq_one_iff).1 this
    push_neg at this
    exact this
  · intro h
    rcases realDeg_23_eq_one_or_eleven u with h1 | h1
    · exact absurd (realDeg_eq_one_iff.1 h1) (by tauto)
    · exact h1

/-- Comparing a natural number to a residue inside `ZMod 23`. -/
private theorem natCast_eq_iff_mod {p r : ℕ} (hr : r < 23) :
    ((p : ZMod 23) = ((r : ℕ) : ZMod 23)) ↔ p % 23 = r := by
  rw [← ZMod.natCast_mod p 23]
  constructor
  · intro h
    have hv := congrArg ZMod.val h
    rwa [ZMod.val_cast_of_lt (Nat.mod_lt _ (by norm_num)), ZMod.val_cast_of_lt hr] at hv
  · intro h; rw [h]

/-- **The degree-11 splitting criterion for a prime `p`**: `p` splits completely
in `Q(ζ₂₃)⁺` iff `p ≡ ±1 (mod 23)`, i.e. `p % 23 ∈ {1, 22}`. -/
theorem realDeg_23_prime_iff {p : ℕ} (hp : Nat.Coprime p 23) :
    realDeg 23 (ZMod.unitOfCoprime p hp) = 1 ↔ p % 23 = 1 ∨ p % 23 = 22 := by
  have hval : ((ZMod.unitOfCoprime p hp : (ZMod 23)ˣ) : ZMod 23) = (p : ZMod 23) := rfl
  rw [realDeg_eq_one_iff]
  have h1 : (ZMod.unitOfCoprime p hp = 1) ↔ p % 23 = 1 := by
    rw [Units.ext_iff, hval, show ((1 : (ZMod 23)ˣ) : ZMod 23) = ((1 : ℕ) : ZMod 23) from by
      norm_num]
    exact natCast_eq_iff_mod (by norm_num)
  have h2 : (ZMod.unitOfCoprime p hp = -1) ↔ p % 23 = 22 := by
    rw [Units.ext_iff, hval, show ((-1 : (ZMod 23)ˣ) : ZMod 23) = ((22 : ℕ) : ZMod 23) from by
      decide]
    exact natCast_eq_iff_mod (by norm_num)
  rw [h1, h2]

/-! ### Two concrete primes -/

/-- `47 ≡ 1 (mod 23)` splits completely in `Q(ζ₂₃)⁺`. -/
theorem realDeg_23_fortyseven (h : Nat.Coprime 47 23 := by decide) :
    realDeg 23 (ZMod.unitOfCoprime 47 h) = 1 := by
  rw [realDeg_23_prime_iff]; left; rfl

/-- `2` is not `±1 mod 23`, hence has full residue degree `11` in `Q(ζ₂₃)⁺`. -/
theorem realDeg_23_two (h : Nat.Coprime 2 23 := by decide) :
    realDeg 23 (ZMod.unitOfCoprime 2 h) = 11 := by
  rcases realDeg_23_eq_one_or_eleven (ZMod.unitOfCoprime 2 h) with h1 | h1
  · rw [realDeg_23_prime_iff] at h1; omega
  · exact h1

/-! ## 4. The entropy of the degree-11 Frobenius type -/

/-- The units of `ZMod 23` that split completely form the two-element set
`{1, -1}`. -/
theorem filter_realDeg_23_eq_one :
    {u : (ZMod 23)ˣ | realDeg 23 u = 1} = ({1, -1} : Set (ZMod 23)ˣ) := by
  ext u
  simp [realDeg_eq_one_iff]

theorem card_filter_realDeg_23 :
    #{u ∈ (univ : Finset (ZMod 23)ˣ) | realDeg 23 u = 1} = 2 := by
  have hset : {u ∈ (univ : Finset (ZMod 23)ˣ) | realDeg 23 u = 1} = ({1, -1} : Finset (ZMod 23)ˣ) := by
    ext u
    simp [realDeg_eq_one_iff]
  rw [hset, card_insert_of_notMem (by simpa using fun h => neg_one_ne_one_23 h.symm),
    card_singleton]

theorem card_univ_units_23 : (univ : Finset (ZMod 23)ˣ).card = 22 := by
  have := card_units_23
  rwa [Nat.card_eq_fintype_card, Fintype.card] at this

/-- **The Frobenius-type entropy computed inside `(Z/23)ˣ`.** -/
theorem uEnt_realDeg_23 :
    uEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) = binEnt 22 2 := by
  have h := uEnt_binary (s := (univ : Finset (ZMod 23)ˣ)) (g := realDeg 23)
    (v := 1) (w := 11) (by norm_num)
    (fun u _ => realDeg_23_eq_one_or_eleven u)
  rw [h, card_filter_realDeg_23, card_univ_units_23]

/-- **The two models agree.** The entropy of the degree-11 Frobenius type
computed over the 22 residue classes mod 23 equals the entropy of the abstract
`C₁₁` type channel: both are `binEnt 11 1 = 0.4394…`. -/
theorem uEnt_realDeg_23_eq_typeEntropy :
    uEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) = typeEntropy 11 := by
  rw [uEnt_realDeg_23, typeEntropy_prime_eq_binEnt (by norm_num),
    show (22 : ℕ) = 2 * 11 from rfl, show (2 : ℕ) = 2 * 1 from rfl,
    binEnt_scale (by norm_num) (by norm_num) (by norm_num)]

/-! ## 5. Full pinning: the sign class determines the type -/

/-- The **sign class** of a unit: the coarse invariant `{u, -u}` recording `p`
mod 23 only up to sign — exactly the datum of the Frobenius class in
`Gal(Q(ζ₂₃)⁺/Q)`. -/
def signClass (f : ℕ) (u : (ZMod f)ˣ) : Finset (ZMod f)ˣ := {u, -u}

theorem signClass_eq_iff {f : ℕ} {u v : (ZMod f)ˣ} (h : signClass f u = signClass f v) :
    v = u ∨ v = -u := by
  have : v ∈ signClass f u := by rw [h]; simp [signClass]
  simpa [signClass] using this

/-- A read-out that is constant on `s` has zero entropy. -/
theorem uEnt_eq_zero_of_const {α β : Type*} [DecidableEq β] {s : Finset α} {g : α → β}
    (h : ∀ x ∈ s, ∀ y ∈ s, g x = g y) : uEnt s g = 0 := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hfib : ∀ a ∈ s, {x ∈ s | g x = g a} = s := by
    intro a ha
    exact Finset.filter_true_of_mem (fun x hx => h x hx a ha)
  rw [uEnt, Finset.sum_congr rfl (fun a ha => by rw [hfib a ha])]
  rw [Finset.sum_const, nsmul_eq_mul]
  have hcard : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  field_simp
  ring

/-- **Pinning criterion.** If a side-channel `k` determines the read-out `g`, the
conditional entropy vanishes — every conditional law is degenerate. -/
theorem condEnt_eq_zero_of_determines {α β γ : Type*} [DecidableEq β] [DecidableEq γ]
    {s : Finset α} {g : α → β} {k : α → γ}
    (h : ∀ x ∈ s, ∀ y ∈ s, k x = k y → g x = g y) : condEnt s g k = 0 := by
  refine Finset.sum_eq_zero fun c _ => ?_
  have : uEnt {x ∈ s | k x = c} g = 0 := by
    refine uEnt_eq_zero_of_const fun x hx y hy => ?_
    simp only [mem_filter] at hx hy
    exact h x hx.1 y hy.1 (by rw [hx.2, hy.2])
  rw [this, mul_zero]

/-- **FULL PINNING AT DEGREE 11.** The sign class of `p mod 23` — a strictly
coarser invariant than the residue itself — already determines the residue
degree in `Q(ζ₂₃)⁺`, so the conditional entropy is `0` and the mutual
information attains the entropy `H(T)` exactly. -/
theorem full_pinning_deg11 :
    condEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) (signClass 23) = 0 ∧
      mutInfo (univ : Finset (ZMod 23)ˣ) (realDeg 23) (signClass 23) = typeEntropy 11 := by
  have hcond : condEnt (univ : Finset (ZMod 23)ˣ) (realDeg 23) (signClass 23) = 0 := by
    refine condEnt_eq_zero_of_determines fun u _ v _ huv => ?_
    rcases signClass_eq_iff huv.symm with h | h
    · rw [h]
    · rw [h, realDeg_neg]
  refine ⟨hcond, ?_⟩
  rw [mutInfo, hcond, sub_zero, uEnt_realDeg_23_eq_typeEntropy]

/-! ## 6. The orthogonal direction: the quadratic character is uninformative -/

/-- The degree-11 type read-out in the exponent (discrete-logarithm) model: `a`
runs over `Z/22`, and the real residue degree only sees `a mod 11`. -/
def realType (a : ℕ) : ℕ := ordType 11 (a % 11)

/-- The quadratic character mod 23, in the exponent model: the parity of the
discrete logarithm. -/
def qChar (a : ℕ) : ℕ := a % 2

theorem realType_binary (a : ℕ) : realType a = 1 ∨ realType a = 11 :=
  ordType_prime_binary (by norm_num) (Nat.mod_lt _ (by norm_num))

/-- The full exponent model reproduces the same entropy. -/
theorem uEnt_realType_range22 : uEnt (range 22) realType = binEnt 22 2 := by
  have h := uEnt_binary (s := range 22) (g := realType) (v := 1) (w := 11) (by norm_num)
    (fun a _ => realType_binary a)
  rw [h, card_range, show #{a ∈ range 22 | realType a = 1} = 2 from by decide]

/-- Each quadratic-character fibre carries the *same* type distribution: one
split class against ten inert classes. -/
theorem uEnt_qChar_fibre {c : ℕ} (hc : c = 0 ∨ c = 1) :
    uEnt {a ∈ range 22 | qChar a = c} realType = binEnt 11 1 := by
  have h := uEnt_binary (s := {a ∈ range 22 | qChar a = c}) (g := realType)
    (v := 1) (w := 11) (by norm_num) (fun a _ => realType_binary a)
  rcases hc with rfl | rfl
  · rw [h, show (#{a ∈ range 22 | qChar a = 0}) = 11 from by decide,
      show #{x ∈ {a ∈ range 22 | qChar a = 0} | realType x = 1} = 1 from by decide]
  · rw [h, show (#{a ∈ range 22 | qChar a = 1}) = 11 from by decide,
      show #{x ∈ {a ∈ range 22 | qChar a = 1} | realType x = 1} = 1 from by decide]

/-- **Zero information from the quadratic character.** Knowing whether `p` is a
quadratic residue mod 23 says nothing at all about its splitting behaviour in
`Q(ζ₂₃)⁺`: the two channels are exactly independent, a CRT consequence of
`gcd(2, 11) = 1`. -/
theorem quadratic_character_carries_no_information :
    mutInfo (range 22) realType qChar = 0 := by
  have himg : (range 22).image qChar = {0, 1} := by decide
  have hcond : condEnt (range 22) realType qChar = binEnt 11 1 := by
    rw [condEnt, himg]
    rw [show ({0, 1} : Finset ℕ) = insert 0 {1} from rfl, Finset.sum_insert (by decide),
      Finset.sum_singleton, uEnt_qChar_fibre (Or.inl rfl), uEnt_qChar_fibre (Or.inr rfl),
      show (#{a ∈ range 22 | qChar a = 0}) = 11 from by decide,
      show (#{a ∈ range 22 | qChar a = 1}) = 11 from by decide, card_range]
    ring
  rw [mutInfo, hcond, uEnt_realType_range22,
    show (22 : ℕ) = 2 * 11 from rfl, show (2 : ℕ) = 2 * 1 from rfl,
    binEnt_scale (by norm_num) (by norm_num) (by norm_num), sub_self]

/-! ## 7. The semiprime split count is `Bin(2, 1/q)` -/

/-- The nonzero exponents of a prime-degree model. -/
private def nz (q : ℕ) : Finset ℕ := {a ∈ range q | a ≠ 0}

private theorem card_nz {q : ℕ} (hq : 0 < q) : (nz q).card = q - 1 := by
  have : nz q = (range q).erase 0 := by
    ext a; simp [nz, Finset.mem_erase, and_comm]
  rw [this, Finset.card_erase_of_mem (mem_range.2 hq), card_range]

/-- The split count of a pair of exponents at prime degree. -/
theorem sProj_typePair_prime {q a b : ℕ} (hq : q.Prime) (ha : a < q) (hb : b < q) :
    sProj (typePair q (a, b)) = (if a = 0 then 1 else 0) + (if b = 0 then 1 else 0) := by
  have h1 : ordType q a = if a = 0 then 1 else q := ordType_prime hq ha
  have h2 : ordType q b = if b = 0 then 1 else q := ordType_prime hq hb
  have hq1 : q ≠ 1 := hq.one_lt.ne'
  rcases eq_or_ne a 0 with rfl | ha0
  · rcases eq_or_ne b 0 with rfl | hb0
    · simp [sProj, typePair, h1]
    · simp [sProj, typePair, h1, h2, hb0, hq1, hq.one_lt.le]
  · rcases eq_or_ne b 0 with rfl | hb0
    · simp [sProj, typePair, h1, h2, ha0, hq1, hq.one_lt.le]
    · simp [sProj, typePair, h1, h2, ha0, hb0, hq1]

/-- Both primes split: exactly one pair out of `q²`. -/
theorem card_splitCount_two {q : ℕ} (hq : q.Prime) :
    #{x ∈ box q | sProj (typePair q x) = 2} = 1 := by
  have : {x ∈ box q | sProj (typePair q x) = 2} = {((0 : ℕ), (0 : ℕ))} := by
    ext x
    obtain ⟨a, b⟩ := x
    simp only [mem_filter, mem_box_iff, mem_singleton, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨ha, hb⟩, h⟩
      rw [sProj_typePair_prime hq ha hb] at h
      split_ifs at h with hA hB hB <;> simp_all
    · rintro ⟨rfl, rfl⟩
      exact ⟨⟨hq.pos, hq.pos⟩, by rw [sProj_typePair_prime hq hq.pos hq.pos]; simp⟩
  rw [this, card_singleton]

/-- Exactly one of the two primes splits: `2(q-1)` pairs. -/
theorem card_splitCount_one {q : ℕ} (hq : q.Prime) :
    #{x ∈ box q | sProj (typePair q x) = 1} = 2 * (q - 1) := by
  have hsplit : {x ∈ box q | sProj (typePair q x) = 1}
      = ({(0 : ℕ)} ×ˢ nz q) ∪ (nz q ×ˢ {(0 : ℕ)}) := by
    ext x
    obtain ⟨a, b⟩ := x
    simp only [mem_filter, mem_box_iff, Finset.mem_union, Finset.mem_product, mem_singleton,
      nz, mem_filter, mem_range]
    constructor
    · rintro ⟨⟨ha, hb⟩, h⟩
      rw [sProj_typePair_prime hq ha hb] at h
      rcases eq_or_ne a 0 with rfl | ha0
      · rcases eq_or_ne b 0 with rfl | hb0
        · simp at h
        · exact Or.inl ⟨rfl, hb, hb0⟩
      · rcases eq_or_ne b 0 with rfl | hb0
        · exact Or.inr ⟨⟨ha, ha0⟩, rfl⟩
        · simp [ha0, hb0] at h
    · rintro (⟨rfl, hb, hb0⟩ | ⟨⟨ha, ha0⟩, rfl⟩)
      · exact ⟨⟨hq.pos, hb⟩, by rw [sProj_typePair_prime hq hq.pos hb]; simp [hb0]⟩
      · exact ⟨⟨ha, hq.pos⟩, by rw [sProj_typePair_prime hq ha hq.pos]; simp [ha0]⟩
  have hdisj : Disjoint ({(0 : ℕ)} ×ˢ nz q) (nz q ×ˢ {(0 : ℕ)}) := by
    rw [Finset.disjoint_left]
    rintro ⟨a, b⟩ h1 h2
    simp only [Finset.mem_product, mem_singleton, nz, mem_filter, mem_range] at h1 h2
    exact h1.2.2 h2.2
  rw [hsplit, Finset.card_union_of_disjoint hdisj, Finset.card_product, Finset.card_product,
    card_singleton, card_nz hq.pos]
  ring

/-- Neither prime splits: `(q-1)²` pairs. -/
theorem card_splitCount_zero {q : ℕ} (hq : q.Prime) :
    #{x ∈ box q | sProj (typePair q x) = 0} = (q - 1) * (q - 1) := by
  have hsplit : {x ∈ box q | sProj (typePair q x) = 0} = nz q ×ˢ nz q := by
    ext x
    obtain ⟨a, b⟩ := x
    simp only [mem_filter, mem_box_iff, Finset.mem_product, nz, mem_filter, mem_range]
    constructor
    · rintro ⟨⟨ha, hb⟩, h⟩
      rw [sProj_typePair_prime hq ha hb] at h
      refine ⟨⟨ha, ?_⟩, hb, ?_⟩ <;> · by_contra h0; simp [h0] at h
    · rintro ⟨⟨ha, ha0⟩, hb, hb0⟩
      exact ⟨⟨ha, hb⟩, by rw [sProj_typePair_prime hq ha hb]; simp [ha0, hb0]⟩
  rw [hsplit, Finset.card_product, card_nz hq.pos]

/-- **The `Bin(2, 1/11)` law at degree 11**: of the `121` exponent pairs,
`100` have no split factor, `20` have exactly one and `1` has two — the exact
binomial profile `(10², 2·10, 1)`. -/
theorem splitCount_deg11 :
    #{x ∈ box 11 | sProj (typePair 11 x) = 0} = 100 ∧
    #{x ∈ box 11 | sProj (typePair 11 x) = 1} = 20 ∧
    #{x ∈ box 11 | sProj (typePair 11 x) = 2} = 1 := by
  refine ⟨?_, ?_, ?_⟩
  · rw [card_splitCount_zero (by norm_num)]
  · rw [card_splitCount_one (by norm_num)]
  · rw [card_splitCount_two (by norm_num)]

/-- The three counts exhaust the `q²` pairs — the binomial law is complete. -/
theorem splitCount_total {q : ℕ} (hq : q.Prime) :
    #{x ∈ box q | sProj (typePair q x) = 0} + #{x ∈ box q | sProj (typePair q x) = 1}
      + #{x ∈ box q | sProj (typePair q x) = 2} = q * q := by
  rw [card_splitCount_zero hq, card_splitCount_one hq, card_splitCount_two hq]
  have h1 : 1 ≤ q := hq.pos
  cases' Nat.exists_eq_add_of_le h1 with k hk
  subst hk
  simp only [Nat.add_sub_cancel_left]
  ring

end AbelianLadder