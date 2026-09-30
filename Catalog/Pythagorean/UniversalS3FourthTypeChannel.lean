module

public import Mathlib
public import Pythagorean.UniversalS3RootCount

/-!
# UNIVERSAL-S3-FOURTH (paper 115): the type-channel law for every pure cubic `x³ - c`

The round-32 measurements report `I(p mod 3 ; T) = 1.0000` for four pure cubics, the fourth
being `x³ - 7` (discriminant `-27·7² = -1323`).  Here `T` is the splitting type of the cubic
mod `p`, read off from its root count `0 / 1 / 3`.  This file proves the arithmetic behind the
measurement, uniformly in `c`, so the four fields do not have to be checked one at a time.

* `rootSet_three_card_eq_one_iff` — **field-level law**: over any finite field `𝔽_q` and any
  `c ≠ 0`, `x³ = c` has exactly one solution **iff** `3 ∤ q - 1`.  This holds in every
  characteristic, including `3`.
* `rootSet_three_split` — if `3 ∣ q - 1`, the root count is `0` or `3` (never `1`).
* `irreducible_iff_rootSet_empty` — root count `0` means the inert type: `X³ - c` is
  irreducible.
* `cubeType` — the type channel `p ↦ #{x ∈ 𝔽_p : x³ = c}`.
* `typeChannel_law` — **the law**: for a prime `p ∤ 3c`, `T(p) = 1 ↔ p ≡ 2 (mod 3)`.
* `typeDecode_cubeType` — a single decoder `typeDecode` (`1 ↦ 2`, anything else `↦ 1`)
  recovers `p mod 3` from `T(p)` for **every** `c` and every unramified `p`.  So the channel
  is noiseless, and the same decoder works for all pure cubic fields ("four fields, one
  answer").
* `four_fields_one_answer` — the decoder statement for `c = 2, 3, 5, 7` at once.
* `ramified_seven_breaks_law`, `ramified_three_breaks_law` — the hypothesis `p ∤ 3c` cannot be
  dropped: at `p = 7` and at `p = 3` the cubic `x³ - 7` has exactly one root, but
  `7 ≡ 1` and `3 ≡ 0 (mod 3)`.
* `card_split_constants`, `card_inert_constants` — **Chebotarev in the constant aspect**:
  when `3 ∣ q - 1`, exactly `(q-1)/3` of the nonzero `c` give three roots and `2(q-1)/3` give
  none.  These are the proportions `1 : 2` of the identity and the 3-cycles inside
  `A₃ ⊂ S₃`.
* `rootSet_prime_card_eq_one_iff` — the same law for `x^ℓ - c` and every prime `ℓ`:
  exactly one root iff `ℓ ∤ q - 1`.
* `quintic_type_does_not_pin_residue` — why `ℓ = 3` is special: for `x⁵ - 2` the primes `7`
  and `13` both give one root, but `7 ≢ 13 (mod 5)`.  The type recovers only `[p ≡ 1 mod ℓ]`,
  which is all of `p mod ℓ` only when `ℓ = 3`.
* `not_pure_cubic_counterexample` — the law belongs to *pure* cubics, not to all `S₃` cubics.
  For `x³ - x - 1` (discriminant `-23`) there is exactly one root mod `5` and exactly one root
  mod `7`, yet `5 ≢ 7 (mod 3)`.

-- !-- Lab Notes -- !--
Experiment (`ComputationalEvidence.md`, primes `p < 1000`, unramified):
  `x³-7`: joint counts `(p mod 3, T)`: `(2,1): 87, (1,0): 54, (1,3): 25`; there are no other
  cells, so `H(p mod 3 | T) = 0`.  Ramified: `p = 3 (T=1)`, `p = 7 (T=1, p ≡ 1)`.
  Explicit data proved below: `T(13) = 0`, `T(19) = 3` (roots `4, 6, 9`), `T(5) = 1`.
-/

@[expose] public section

namespace UniversalS3Fourth

open Finset UniversalS3Test

instance fact_prime_three : Fact (Nat.Prime 3) := ⟨Nat.prime_three⟩

section Field

variable {F : Type*} [Field F] [Fintype F] [DecidableEq F]

/-- **Split fields.** If `3 ∣ q - 1` and `c ≠ 0`, then `x³ = c` has `0` or `3` solutions. -/
theorem rootSet_three_split {c : F} (hc : c ≠ 0) (hd : 3 ∣ Fintype.card F - 1) :
    (rootSet 3 c).card = 0 ∨ (rootSet 3 c).card = 3 := by
  rcases rootSet_card_dichotomy (n := 3) (by norm_num) hc with h | h
  · exact Or.inl h
  · exact Or.inr (h.trans (rootSet_one_card_of_dvd hd))

/-- **Field-level type-channel law.** For `c ≠ 0`, the equation `x³ = c` has exactly one
solution in `𝔽_q` iff `3 ∤ q - 1`. -/
theorem rootSet_three_card_eq_one_iff {c : F} (hc : c ≠ 0) :
    (rootSet 3 c).card = 1 ↔ ¬ 3 ∣ Fintype.card F - 1 := by
  constructor
  · intro h hd
    rcases rootSet_three_split hc hd with h' | h' <;> omega
  · intro hd
    exact rootSet_card_eq_one_of_coprime (by norm_num)
      ((Nat.Prime.coprime_iff_not_dvd Nat.prime_three).mpr hd) c

/-- **Inert type.** `X³ - c` is irreducible over `F` iff it has no root in `F`. -/
theorem irreducible_iff_rootSet_empty (c : F) :
    Irreducible (Polynomial.X ^ 3 - Polynomial.C c) ↔ (rootSet 3 c).card = 0 := by
  have hdeg : (Polynomial.X ^ 3 - Polynomial.C c : Polynomial F).natDegree = 3 :=
    Polynomial.natDegree_X_pow_sub_C
  have hne : (Polynomial.X ^ 3 - Polynomial.C c : Polynomial F) ≠ 0 :=
    Polynomial.X_pow_sub_C_ne_zero (by norm_num) c
  rw [Polynomial.irreducible_iff_roots_eq_zero_of_degree_le_three (by omega) (by omega),
    card_eq_zero, eq_empty_iff_forall_notMem, Multiset.eq_zero_iff_forall_notMem]
  constructor
  · intro h x hx
    apply h x
    rw [Polynomial.mem_roots hne, Polynomial.IsRoot, Polynomial.eval_sub, Polynomial.eval_pow,
      Polynomial.eval_X, Polynomial.eval_C, (mem_rootSet_iff 3 c x).mp hx, sub_self]
  · intro h x hx
    apply h x
    rw [mem_rootSet_iff]
    rw [Polynomial.mem_roots hne, Polynomial.IsRoot, Polynomial.eval_sub, Polynomial.eval_pow,
      Polynomial.eval_X, Polynomial.eval_C] at hx
    exact sub_eq_zero.mp hx

/-- **Chebotarev in the constant aspect (split part).** If `3 ∣ q - 1`, exactly `(q - 1)/3`
nonzero constants `c` give three roots of `x³ - c`. -/
theorem card_split_constants (hd : 3 ∣ Fintype.card F - 1) :
    3 * ((univ.erase (0 : F)).filter (fun c => (rootSet 3 c).card = 3)).card
      = Fintype.card F - 1 := by
  rw [← sum_rootSet_card_units (F := F) (by norm_num : (3 : ℕ) ≠ 0)]
  have key : ∀ c ∈ univ.erase (0 : F),
      (rootSet 3 c).card = if (rootSet 3 c).card = 3 then 3 else 0 := by
    intro c hc
    rcases rootSet_three_split (mem_erase.mp hc).1 hd with h | h <;> simp [h]
  rw [sum_congr rfl key, ← sum_filter, sum_const, smul_eq_mul, mul_comm]

/-- **Chebotarev in the constant aspect (inert part).** If `3 ∣ q - 1`, exactly
`2(q - 1)/3` nonzero constants `c` give no root, i.e. an irreducible `x³ - c`. -/
theorem card_inert_constants (hd : 3 ∣ Fintype.card F - 1) :
    3 * ((univ.erase (0 : F)).filter (fun c => (rootSet 3 c).card = 0)).card
      = 2 * (Fintype.card F - 1) := by
  have hsplit := card_split_constants hd
  have hpart := card_filter_add_card_filter_not (s := univ.erase (0 : F))
    (fun c => (rootSet 3 c).card = 3)
  have hsame : (univ.erase (0 : F)).filter (fun c => ¬ (rootSet 3 c).card = 3)
      = (univ.erase (0 : F)).filter (fun c => (rootSet 3 c).card = 0) := by
    refine filter_congr (fun c hc => ?_)
    rcases rootSet_three_split (mem_erase.mp hc).1 hd with h | h <;> simp [h]
  rw [hsame, card_erase_of_mem (mem_univ _), card_univ] at hpart
  omega

end Field

/-! ## The type channel over the primes -/

/-- The **type channel** of the pure cubic `x³ - c`: the number of roots mod `p`
(`0` = inert, `1` = type `(1)(2)`, `3` = split).  Set to `0` for non-prime `p`. -/
noncomputable def cubeType (c : ℤ) (p : ℕ) : ℕ :=
  if hp : p.Prime then
    haveI := Fact.mk hp
    (rootSet 3 (c : ZMod p)).card
  else 0

/-- The universal decoder: type `1` means `p ≡ 2 (mod 3)`, any other type means
`p ≡ 1 (mod 3)`. -/
def typeDecode (t : ℕ) : ℕ := if t = 1 then 2 else 1

/-- Unramified primes: `p ∤ 3c` gives `p ≠ 3` and `c ≢ 0 (mod p)`. -/
lemma unramified_facts {c : ℤ} {p : ℕ} (hp : p.Prime) (hram : ¬ (p : ℤ) ∣ 3 * c) :
    p % 3 ≠ 0 ∧ (c : ZMod p) ≠ 0 := by
  constructor
  · intro h0
    have h3 : 3 ∣ p := Nat.dvd_of_mod_eq_zero h0
    have hp3 : p = 3 := ((Nat.prime_dvd_prime_iff_eq Nat.prime_three hp).mp h3).symm
    apply hram
    subst hp3
    exact Dvd.intro c rfl
  · intro hc
    apply hram
    rw [ZMod.intCast_zmod_eq_zero_iff_dvd] at hc
    exact Dvd.dvd.mul_left hc 3

/-- **The type-channel law.** For every integer `c` and every prime `p ∤ 3c`, the cubic
`x³ - c` has exactly one root mod `p` iff `p ≡ 2 (mod 3)`. -/
theorem typeChannel_law (c : ℤ) {p : ℕ} (hp : p.Prime) (hram : ¬ (p : ℤ) ∣ 3 * c) :
    cubeType c p = 1 ↔ p % 3 = 2 := by
  haveI := Fact.mk hp
  obtain ⟨h3, hc⟩ := unramified_facts hp hram
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  rw [cubeType, dif_pos hp, rootSet_three_card_eq_one_iff hc, hcard]
  have hp2 := hp.two_le
  omega

/-- The unramified root counts lie in `{0, 1, 3}`, and `0, 3` occur only when `p ≡ 1 (mod 3)`. -/
theorem cubeType_alphabet (c : ℤ) {p : ℕ} (hp : p.Prime) (hram : ¬ (p : ℤ) ∣ 3 * c) :
    (cubeType c p = 1 ∧ p % 3 = 2) ∨ ((cubeType c p = 0 ∨ cubeType c p = 3) ∧ p % 3 = 1) := by
  haveI := Fact.mk hp
  obtain ⟨h3, hc⟩ := unramified_facts hp hram
  have hp2 := hp.two_le
  by_cases h2 : p % 3 = 2
  · exact Or.inl ⟨(typeChannel_law c hp hram).mpr h2, h2⟩
  · right
    refine ⟨?_, by omega⟩
    have hd : 3 ∣ Fintype.card (ZMod p) - 1 := by rw [ZMod.card]; omega
    unfold cubeType
    rw [dif_pos hp]
    exact rootSet_three_split hc hd

/-- **Noiseless channel.** One decoder recovers `p mod 3` from the type, for every `c` and
every unramified prime.  In other words `H(p mod 3 | T) = 0`. -/
theorem typeDecode_cubeType (c : ℤ) {p : ℕ} (hp : p.Prime) (hram : ¬ (p : ℤ) ∣ 3 * c) :
    typeDecode (cubeType c p) = p % 3 := by
  rcases cubeType_alphabet c hp hram with ⟨h1, h2⟩ | ⟨h0 | h0, h1⟩
  · rw [h1, h2]; rfl
  · rw [h0, h1]; rfl
  · rw [h0, h1]; rfl

/-- **Four fields, one answer.** For `c ∈ {2, 3, 5, 7}` the same decoder works at every
unramified prime. -/
theorem four_fields_one_answer :
    ∀ c ∈ ({2, 3, 5, 7} : Finset ℤ), ∀ p : ℕ, p.Prime → ¬ (p : ℤ) ∣ 3 * c →
      typeDecode (cubeType c p) = p % 3 :=
  fun c _ _ hp hram => typeDecode_cubeType c hp hram

/-- The fourth field: `x³ - 7` obeys the law at every prime `p ∉ {3, 7}`. -/
theorem seven_typeChannel_law {p : ℕ} (hp : p.Prime) (h3 : p ≠ 3) (h7 : p ≠ 7) :
    cubeType 7 p = 1 ↔ p % 3 = 2 := by
  apply typeChannel_law 7 hp
  intro hdvd
  have hdvd' : (p : ℤ) ∣ 21 := by simpa using hdvd
  have hn : p ∣ 21 := by exact_mod_cast hdvd'
  have hle : p ≤ 21 := Nat.le_of_dvd (by norm_num) hn
  interval_cases p <;> simp_all (config := {decide := true})

/-! ## Explicit data for `x³ - 7` -/

instance fact_prime_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩
instance fact_prime_seven : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance fact_prime_thirteen : Fact (Nat.Prime 13) := ⟨by norm_num⟩
instance fact_prime_nineteen : Fact (Nat.Prime 19) := ⟨by norm_num⟩

lemma cubeType_eq (c : ℤ) (p : ℕ) [hp : Fact p.Prime] :
    cubeType c p = (rootSet 3 (c : ZMod p)).card := by
  rw [cubeType, dif_pos hp.out]

/-- `x³ - 7` is inert mod `13`: `7` is not a cube mod `13` (cubes: `±1, ±5`). -/
theorem seven_inert_13 : cubeType 7 13 = 0 := by
  rw [cubeType_eq]
  decide

/-- `x³ - 7` splits mod `19`, with roots `4, 6, 9`. -/
theorem seven_split_19 : cubeType 7 19 = 3 := by
  rw [cubeType_eq]
  apply le_antisymm (rootSet_card_le (by norm_num) _)
  have hsub : ({4, 6, 9} : Finset (ZMod 19)) ⊆ rootSet 3 ((7 : ℤ) : ZMod 19) := by
    intro x hx
    rw [mem_rootSet_iff]
    simp only [mem_insert, mem_singleton] at hx
    rcases hx with rfl | rfl | rfl <;> decide
  exact (card_le_card hsub).trans' (by decide)

/-- `x³ - 7` has exactly one root mod `5`, as the law predicts (`5 ≡ 2 mod 3`). -/
theorem seven_one_root_5 : cubeType 7 5 = 1 :=
  (seven_typeChannel_law (by norm_num) (by norm_num) (by norm_num)).mpr (by norm_num)

/-- Both inert and split types occur at primes `≡ 1 (mod 3)`, so the type carries strictly more
than `p mod 3`: the channel `T → p mod 3` loses information. -/
theorem seven_type_finer_than_residue :
    13 % 3 = 19 % 3 ∧ cubeType 7 13 ≠ cubeType 7 19 := by
  rw [seven_inert_13, seven_split_19]; decide

/-- **Boundary (ramified prime 7).** `x³ - 7 ≡ x³` mod `7` has the single root `0`, yet
`7 ≡ 1 (mod 3)`: the law fails at `p ∣ c`. -/
theorem ramified_seven_breaks_law : cubeType 7 7 = 1 ∧ 7 % 3 = 1 := by
  rw [cubeType_eq]
  exact ⟨by decide, by norm_num⟩

/-- **Boundary (ramified prime 3).** `x³ - 7 ≡ (x - 1)³` mod `3` has the single root `1`, yet
`3 ≡ 0 (mod 3)`. -/
theorem ramified_three_breaks_law : cubeType 7 3 = 1 ∧ 3 % 3 = 0 := by
  rw [cubeType_eq]
  exact ⟨by decide, by norm_num⟩

/-! ## Every prime exponent, and why `ℓ = 3` is special -/

/-- **Kummer type-channel law for every prime exponent.** For a prime `ℓ` and `c ≠ 0`,
`x^ℓ = c` has exactly one solution in `𝔽_q` iff `ℓ ∤ q - 1`. -/
theorem rootSet_prime_card_eq_one_iff {ℓ : ℕ} [hℓ : Fact ℓ.Prime] {F : Type*} [Field F]
    [Fintype F] [DecidableEq F] {c : F} (hc : c ≠ 0) :
    (rootSet ℓ c).card = 1 ↔ ¬ ℓ ∣ Fintype.card F - 1 := by
  constructor
  · intro h hd
    rcases rootSet_card_dichotomy hℓ.out.ne_zero hc with h' | h'
    · omega
    · rw [rootSet_one_card_of_dvd hd] at h'
      exact hℓ.out.one_lt.ne' (h'.symm.trans h)
  · intro hd
    exact rootSet_card_eq_one_of_coprime hℓ.out.ne_zero
      ((Nat.Prime.coprime_iff_not_dvd hℓ.out).mpr hd) c

/-- **Why `ℓ = 3` is special.** For `x⁵ - 2` the type does not pin down `p mod 5`: at
`p = 7` and `p = 13` (residues `2` and `3` mod `5`) there is exactly one root both times.  The
type sees only whether `p ≡ 1 (mod 5)`.  For `ℓ = 3` the unit group `(ℤ/3)ˣ` has two
elements, so that one bit is all of `p mod 3`. -/
theorem quintic_type_does_not_pin_residue :
    (rootSet 5 (2 : ZMod 7)).card = 1 ∧ (rootSet 5 (2 : ZMod 13)).card = 1 ∧ 7 % 5 ≠ 13 % 5 :=
  ⟨quintic_one_root (by norm_num), quintic_one_root (by norm_num), by norm_num⟩

/-! ## The law is about pure cubics, not about `S₃` -/

/-- **Counterexample to "every `S₃` cubic obeys the `p mod 3` law".** The cubic `x³ - x - 1`
(discriminant `-23`, Galois group `S₃`) has exactly one root mod `5` (`x = 2`) and exactly one
root mod `7` (`x = 5`), but `5 ≡ 2` and `7 ≡ 1 (mod 3)`.  For a general cubic the type
determines `(disc / p)`, not `p mod 3`.  The pure cubics are exactly the case where
`disc = -27c²`, so that `(disc / p) = (-3 / p)` is determined by `p mod 3`. -/
theorem not_pure_cubic_counterexample :
    ((univ : Finset (ZMod 5)).filter (fun x => x ^ 3 - x - 1 = 0)).card = 1 ∧
    ((univ : Finset (ZMod 7)).filter (fun x => x ^ 3 - x - 1 = 0)).card = 1 ∧
    5 % 3 ≠ 7 % 3 := by
  refine ⟨by decide, by decide, by norm_num⟩

end UniversalS3Fourth

end