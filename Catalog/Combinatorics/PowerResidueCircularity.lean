/-
# The higher-power reciprocity channel is not a residue dial — and buys nothing

Formal companion to `39_PowerResidue_Circularity.md` (experiment KPOWER, #374),
building on `Combinatorics.PowerResidueCriterion` (the `k`-th power criterion)
and on `Combinatorics.DialThresholdNoAmplification` (the `Dial` calculus).

**The question.**  The quadratic channel of the free-witness programme is a
*dial*: `p ↦ (D | p)` is periodic in `p`, of conductor `4|D|`
(`DialThreshold.kron`), and therefore — by the DIAL-THRESHOLD dichotomy — either
hint-computable or informative, never both.  Cubic and quartic residue symbols
are supposed to *escape* this: cubic residuacity of `2` is governed by
`4p = A² + 27B²`, which is not a congruence condition on `p`.  Does the escape
give the attacker anything?

**What is proved here.**

* `PowerResidueEscape.quadratic_two_is_dial`,
  `PowerResidueEscape.legendre_eq_kron` — the quadratic channel really *is* a
  dial: quadratic residuacity of `2` is read off `p % 8`, and for every base the
  Legendre symbol is the reading of the catalog's Kronecker dial.
* `PowerResidueEscape.cubic_two_not_periodic`,
  `PowerResidueEscape.cubic_two_not_dial` — the cubic channel is **not** a dial
  of any conductor dividing `720720 = lcm(1,…,16)`.  Witness pair:
  `43` and `720763 = 43 + 720720`, both `≡ 1 (mod 3)`, with `2` a cube mod `43`
  (`20³ ≡ 2`) and a non-cube mod `720763` (`2^240254 ≡ 632375 ≢ 1`).  In
  particular (`cubic_two_not_periodic_of_le`) no modulus `M ≤ 16` decides cubic
  residuacity of `2`.
* `PowerResidueEscape.quartic_two_not_dial` — the same for the quartic channel,
  witnessed by `137` and `720857 = 137 + 720720` (`96769⁴ ≡ 2 (mod 720857)`,
  while `2^34 ≡ 136 ≢ 1 (mod 137)`).
* `PowerResidueEscape.escape_but_no_gain` — the punchline, assembling the two
  halves: the cubic channel escapes every `720720`-conductor dial, yet its
  fingerprints obey *exactly* the quadratic capacity bound `2 ^ K`
  (`PowerResidue.card_le_two_pow_of_injOn`), so pinning `C` candidates still
  costs `K ≥ log₂ C` symbols.  Escape from periodicity ≠ extra information.
* `PowerResidueEscape.cubic_bit_needs_the_exponent` — circularity, in the form
  the experiment states it: the residue of `p` modulo the full dial modulus
  `720720` does **not** determine the cubic bit, so the only route to the bit is
  the exponent `(p-1)/3` — which presupposes `p`.

## Lab notes (real data from the KPOWER runs)

*Escape witnesses* (`p ≡ q mod 720720`, both `≡ 1 mod 3`, opposite cubic bits):

| p | p mod 720720 | 2^((p-1)/3) mod p | 2 a cube mod p? |
|---|---|---|---|
| 43 | 43 | 1 | yes (20³ = 8000 = 186·43 + 2) |
| 720763 | 43 | 632375 | no |

*Quartic witnesses* (`p ≡ q mod 720720`, both `≡ 1 mod 4`):

| p | 2^((p-1)/4) mod p | 2 a fourth power mod p? |
|---|---|---|
| 137 | 136 | no |
| 720857 | 1 | yes (96769⁴ ≡ 2) |

*Leakage saturation* (bases `2,3,5,7,11`; the 68 primes `p ∈ [1000,2000]` with
`p ≡ 1 mod 3`):

| fingerprint | distinct values | capacity |
|---|---|---|
| full quadratic symbols `a^((p-1)/2) mod p` | 68 / 68 | — (values live in `ZMod p`, i.e. already encode `p`) |
| full cubic symbols `a^((p-1)/3) mod p` | 68 / 68 | — (same artefact) |
| quadratic residuacity **bits** | 31 / 68 | `2⁵ = 32` |
| cubic residuacity **bits** | 23 / 68 | `2⁵ = 32` |

The "68/68 distinct" of the experiment is the circularity in numerical form: the
symbol's *value* lives in `ZMod p` and therefore carries `p` itself.  The
`p`-independent read-out — the residuacity bit — saturates at `2^K` for cubic
exactly as for quadratic, which is `PowerResidue.card_le_two_pow_of_injOn`.
-/
import Mathlib
import Combinatorics.PowerResidueCriterion
import Combinatorics.DialThresholdNoAmplification

namespace PowerResidueEscape

open PowerResidue

set_option exponentiation.threshold 1000000
set_option maxRecDepth 40000

/-! ## 1. The quadratic channel *is* a dial -/

/-- For every nonzero base the Legendre symbol at an odd prime is the reading of
the catalog's Kronecker dial `DialThreshold.kron`, whose conductor is `4|D|`. -/
theorem legendre_eq_kron (D : ℤ) (hD : D ≠ 0) {p : ℕ} [Fact p.Prime] (hodd : Odd p) :
    legendreSym p D = (DialThreshold.kron D hD).chi p := by
  rw [DialThreshold.kron_apply_odd hD hodd, jacobiSym.legendreSym.to_jacobiSym]

/-- **The quadratic channel is periodic.**  Quadratic residuacity of `2` at an
odd prime is decided by `p % 8`: two odd primes in the same class mod `8` have
the same quadratic bit. -/
theorem quadratic_two_is_dial {p q : ℕ} (hp : p.Prime) (hq : q.Prime) (hp2 : p ≠ 2)
    (hq2 : q ≠ 2) (h : p % 8 = q % 8) :
    (IsPowerResidue 2 p 2 ↔ IsPowerResidue 2 q 2) := by
  haveI : Fact p.Prime := ⟨hp⟩
  haveI : Fact q.Prime := ⟨hq⟩
  have hp' : IsPowerResidue 2 p 2 ↔ IsSquare ((2 : ℕ) : ZMod p) := isPowerResidue_two_iff
  have hq' : IsPowerResidue 2 q 2 ↔ IsSquare ((2 : ℕ) : ZMod q) := isPowerResidue_two_iff
  rw [hp', hq']
  have e1 : IsSquare (((2 : ℕ) : ZMod p)) ↔ p % 8 = 1 ∨ p % 8 = 7 := by
    rw [Nat.cast_ofNat]; exact ZMod.exists_sq_eq_two_iff hp2
  have e2 : IsSquare (((2 : ℕ) : ZMod q)) ↔ q % 8 = 1 ∨ q % 8 = 7 := by
    rw [Nat.cast_ofNat]; exact ZMod.exists_sq_eq_two_iff hq2
  rw [e1, e2, h]

/-- The quadratic bit of `2` is literally the reading of an explicit dial of
conductor `8`. -/
theorem quadratic_two_dial_exists :
    ∃ d : DialThreshold.Dial, d.cond = 8 ∧
      ∀ p : ℕ, p.Prime → p ≠ 2 → (IsPowerResidue 2 p 2 ↔ d.chi p = 1) := by
  refine ⟨{ cond := 8
            cond_pos := by norm_num
            chi := fun n => if n % 8 = 1 ∨ n % 8 = 7 then 1 else 0
            periodic := fun n => by simp [Nat.add_mod_right] }, rfl, ?_⟩
  intro p hp hp2
  haveI : Fact p.Prime := ⟨hp⟩
  have hiff : IsPowerResidue 2 p 2 ↔ p % 8 = 1 ∨ p % 8 = 7 := by
    rw [isPowerResidue_two_iff, Nat.cast_ofNat]; exact ZMod.exists_sq_eq_two_iff hp2
  by_cases h : p % 8 = 1 ∨ p % 8 = 7 <;> simp [hiff, h]

/-! ## 2. Escape witnesses: explicit primes with equal residues and opposite
cubic (resp. quartic) bits -/

theorem prime_43 : Nat.Prime 43 := by norm_num
theorem prime_720763 : Nat.Prime 720763 := by norm_num
theorem prime_137 : Nat.Prime 137 := by norm_num
theorem prime_720857 : Nat.Prime 720857 := by norm_num

/-- `2` is a cube modulo `43`: indeed `20³ = 8000 = 186·43 + 2`. -/
theorem cubic_residue_two_43 : IsPowerResidue 3 43 2 := ⟨20, by decide⟩

/-- `2` is **not** a cube modulo `720763`, because
`2^((720763-1)/3) = 2^240254 ≡ 632375 ≢ 1`. -/
theorem not_cubic_residue_two_720763 : ¬ IsPowerResidue 3 720763 2 := by
  haveI : Fact (Nat.Prime 720763) := ⟨prime_720763⟩
  haveI : Fact (1 < 720763) := ⟨by norm_num⟩
  rw [isPowerResidue_iff_pow (by norm_num) (by norm_num)]
  have h2 : ((2 : ℕ) : ZMod 720763) ^ 240254 = (((2 ^ 240254 : ℕ)) : ZMod 720763) := by
    push_cast; ring
  have h3 : (2 ^ 240254 : ℕ) % 720763 = 632375 := by decide +kernel
  have h4 : (((2 ^ 240254 : ℕ)) : ZMod 720763) = ((632375 : ℕ) : ZMod 720763) := by
    conv_lhs => rw [← ZMod.natCast_mod, h3]
  have hexp : (720763 - 1) / 3 = 240254 := by norm_num
  rw [hexp, h2, h4]
  intro h
  have := congrArg ZMod.val h
  rw [ZMod.val_natCast_of_lt (by norm_num), ZMod.val_one] at this
  omega

/-- `2` is a fourth power modulo `720857`: `96769⁴ ≡ 2`. -/
theorem quartic_residue_two_720857 : IsPowerResidue 4 720857 2 := by
  refine ⟨((96769 : ℕ) : ZMod 720857), ?_⟩
  have h1 : ((96769 : ℕ) : ZMod 720857) ^ 4 = (((96769 ^ 4 : ℕ)) : ZMod 720857) := by
    push_cast; ring
  have h3 : (96769 ^ 4 : ℕ) % 720857 = 2 := by norm_num
  rw [h1]
  conv_lhs => rw [← ZMod.natCast_mod, h3]

/-- `2` is **not** a fourth power modulo `137`, because `2^34 ≡ 136 ≢ 1`. -/
theorem not_quartic_residue_two_137 : ¬ IsPowerResidue 4 137 2 := by
  haveI : Fact (Nat.Prime 137) := ⟨prime_137⟩
  rw [isPowerResidue_iff_pow (by norm_num) (by norm_num)]
  haveI : Fact (1 < 137) := ⟨by norm_num⟩
  have hexp : (137 - 1) / 4 = 34 := by norm_num
  have h2 : ((2 : ℕ) : ZMod 137) ^ 34 = (((2 ^ 34 : ℕ)) : ZMod 137) := by push_cast; ring
  have h3 : (2 ^ 34 : ℕ) % 137 = 136 := by norm_num
  have h4 : (((2 ^ 34 : ℕ)) : ZMod 137) = ((136 : ℕ) : ZMod 137) := by
    conv_lhs => rw [← ZMod.natCast_mod, h3]
  rw [hexp, h2, h4]
  intro h
  have := congrArg ZMod.val h
  rw [ZMod.val_natCast_of_lt (by norm_num), ZMod.val_one] at this
  omega

/-! ## 3. The cubic channel escapes every dial of conductor dividing `720720` -/

/-- The two cubic witnesses are congruent modulo every divisor of `720720`. -/
theorem witness_congr {M : ℕ} (hM : M ∣ 720720) : (43 : ℕ) % M = 720763 % M := by
  have : (43 : ℕ) ≡ 720763 [MOD M] :=
    (Nat.modEq_iff_dvd' (by norm_num)).mpr (by simpa using hM)
  exact this

/-- The two quartic witnesses are congruent modulo every divisor of `720720`. -/
theorem witness_congr' {M : ℕ} (hM : M ∣ 720720) : (137 : ℕ) % M = 720857 % M := by
  have : (137 : ℕ) ≡ 720857 [MOD M] :=
    (Nat.modEq_iff_dvd' (by norm_num)).mpr (by simpa using hM)
  exact this

/-- **Cubic residuacity is not a congruence condition** for any modulus dividing
`720720 = lcm(1,…,16)`: knowing `p % M` never decides whether `2` is a cube mod
`p`, even after restricting to `p ≡ 1 (mod 3)` where the symbol is defined. -/
theorem cubic_two_not_periodic {M : ℕ} (hM : M ∣ 720720) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p % 3 = 1 → q % 3 = 1 → p % M = q % M →
        (IsPowerResidue 3 p 2 ↔ IsPowerResidue 3 q 2) := by
  intro H
  exact not_cubic_residue_two_720763
    ((H 43 720763 prime_43 prime_720763 (by norm_num) (by norm_num)
      (witness_congr hM)).mp cubic_residue_two_43)

/-- In particular no modulus `M ≤ 16` decides the cubic bit. -/
theorem cubic_two_not_periodic_of_le {M : ℕ} (hM0 : 0 < M) (hM : M ≤ 16) :
    ¬ ∀ p q : ℕ, p.Prime → q.Prime → p % 3 = 1 → q % 3 = 1 → p % M = q % M →
        (IsPowerResidue 3 p 2 ↔ IsPowerResidue 3 q 2) := by
  apply cubic_two_not_periodic
  interval_cases M <;> norm_num

/-- **No dial reads the cubic bit.**  For every residue dial whose conductor
divides `720720` and every target reading `c`, the dial fails to decide cubic
residuacity of `2`.  Contrast `quadratic_two_dial_exists`: the quadratic bit is
the reading of a conductor-`8` dial. -/
theorem cubic_two_not_dial (d : DialThreshold.Dial) (hd : d.cond ∣ 720720) (c : ℤ) :
    ¬ ∀ p : ℕ, p.Prime → p % 3 = 1 → (IsPowerResidue 3 p 2 ↔ d.chi p = c) := by
  intro H
  have hchi : d.chi 43 = d.chi 720763 := d.chi_congr hd (witness_congr dvd_rfl)
  have h1 : d.chi 43 = c := (H 43 prime_43 (by norm_num)).mp cubic_residue_two_43
  exact not_cubic_residue_two_720763
    ((H 720763 prime_720763 (by norm_num)).mpr (by rw [← hchi, h1]))

/-- The quartic channel escapes the same way, witnessed by `137` and `720857`. -/
theorem quartic_two_not_dial (d : DialThreshold.Dial) (hd : d.cond ∣ 720720) (c : ℤ) :
    ¬ ∀ p : ℕ, p.Prime → p % 4 = 1 → (IsPowerResidue 4 p 2 ↔ d.chi p = c) := by
  intro H
  have hchi : d.chi 137 = d.chi 720857 := d.chi_congr hd (witness_congr' dvd_rfl)
  have h1 : d.chi 720857 = c := (H 720857 prime_720857 (by norm_num)).mp quartic_residue_two_720857
  exact not_quartic_residue_two_137
    ((H 137 prime_137 (by norm_num)).mpr (by rw [hchi, h1]))

/-- **Circularity.**  Even the *finest* dial modulus in play, the full
`720720 = lcm(1,…,16)`, leaves the cubic bit undetermined: there are two primes
with the same residue mod `720720` and opposite bits.  Hence the bit is not
recoverable from congruence data; the only available route is the Euler-style
exponentiation `2^((p-1)/3)`, which presupposes `p` itself. -/
theorem cubic_bit_needs_the_exponent :
    ∃ p q : ℕ, p.Prime ∧ q.Prime ∧ p % 3 = 1 ∧ q % 3 = 1 ∧ p % 720720 = q % 720720 ∧
      IsPowerResidue 3 p 2 ∧ ¬ IsPowerResidue 3 q 2 :=
  ⟨43, 720763, prime_43, prime_720763, by norm_num, by norm_num, witness_congr dvd_rfl,
    cubic_residue_two_43, not_cubic_residue_two_720763⟩

/-! ## 4. Escape without gain -/

open scoped Classical in
/-- **The verdict of KPOWER, formalised.**  Both halves at once:

1. *Escape*: the cubic residuacity bit of `2` is not the reading of any residue
   dial of conductor dividing `720720` — the higher-power channel genuinely
   leaves the quadratic (periodic) world.
2. *No gain*: for every exponent `k`, in particular `k = 3` and `k = 4`, a
   length-`K` residuacity fingerprint separates at most `2 ^ K` candidates —
   exactly the quadratic capacity.  Escaping periodicity does not raise the
   information rate. -/
theorem escape_but_no_gain (K : ℕ) :
    (∀ d : DialThreshold.Dial, d.cond ∣ 720720 → ∀ c : ℤ,
        ¬ ∀ p : ℕ, p.Prime → p % 3 = 1 → (IsPowerResidue 3 p 2 ↔ d.chi p = c)) ∧
    (∀ (k : ℕ) (bases : Fin K → ℕ) (S : Finset ℕ),
        Set.InjOn (resVec k bases) S → S.card ≤ 2 ^ K ∧ Nat.log 2 S.card ≤ K) := by
  refine ⟨fun d hd c => cubic_two_not_dial d hd c, fun k bases S hinj => ?_⟩
  exact ⟨card_le_two_pow_of_injOn hinj, log_le_of_separating hinj⟩

end PowerResidueEscape