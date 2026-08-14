import Mathlib
import Tropical.PlusOneWilliamsCore
import Tropical.FactorLocationBarriers

/-!
# PLUSONE-SMOOTH-NULL: the Williams `p + 1` weakness is invisible from `N`

This file formalises the *null* half of the round-16 experiment
`PLUSONE-SMOOTH-NULL` (paper 64), the `p + 1` sibling of the `p - 1`/ECM
self-hint programme. The measured phenomenon:

* the two classes genuinely differ — the `p + 1` method factors the `PLUSONE`
  class 24/40 and the `GENERAL` class 0/40 (positive control);
* yet every `N`-computable statistic tested is blind: mutual information
  `I(N mod ℓ ; ℓ ∣ p+1) ≈ 0` for `ℓ = 3, 5, 7, 11, 13`, while the *symmetric*
  control `I(N mod ℓ ; ℓ ∣ p+1 ∨ ℓ ∣ q+1)` is visible (0.2996 at `ℓ = 3`);
* the discriminant gate `(D | p) = -1` predicts success exactly, but its
  `N`-computable shadow `(D | N) = (D | p)(D | q)` predicts nothing.

The theorems below explain all four observations structurally.

## The mathematical content

* `no_locator_of_collision` — the abstract barrier: any `N`-computable
  statistic that *collides* on two admissible instances with opposite class
  labels cannot locate the class. All invisibility results are instances.
* `plusOne_divisibility_invisible`, `williams_gate_invisible` — **the two grand
  invisibility theorems.** Even the very rich statistic
  `N ↦ (N mod 60060, bitlength N)` — which subsumes `N mod ℓ` for every
  `ℓ ∈ {2,3,5,7,11,13}` and hence every Jacobi symbol `(d | N)` whose square
  class is supported there, together with the bit length used to match the
  experimental pairs — fails to decide either `3 ∣ p + 1` or the base-3
  discriminant gate `(5 | p) = -1`. The witness is the *matched pair*
  `N = 359 · 5849` versus `N' = 397 · 5743`: same residue `57751 mod 60060`,
  same 22-bit length, factors of matched bit lengths (9 and 13), yet opposite
  labels for **both** predicates simultaneously.
* `residue_cannot_locate_plusOne`, `residue_cannot_locate_gate` — the per-`ℓ`
  corollaries measured in the experiment.
* `mod_three_reveals_xor`, `symmetric_plusOne_visible_mod_three` — **the
  dichotomy.** `N mod 3` *does* determine the symmetric predicate
  "exactly one of `p, q` is `≡ -1 mod 3`"; what it cannot do is say *which*.
* `jacobiSym_semiprime_split`, `jacobi_gate_product_uninformative` — the same
  dichotomy in the character channel: `(D | N)` is the product of the two
  local characters, so the split `((D|p), (D|q)) = (-1, +1)` is confounded with
  `(+1, -1)`, and `(D|N) = +1` is consistent with `(D|p) = -1`.
* `williams_splits`, `williams_example_seven` — the positive control: the
  classical method provably returns the factor when the gate holds, and does so
  on the explicit instance `N = 91`, base `P = 3`, `M = 8`.
* `williams_output_below_tropical_corner` — the returned factor is the divisor
  on the lower side of the tropical corner `√N` of `FactorLocationBarriers`.
-/

namespace PlusOneSmoothNull

open PlusOneWilliams

/-! ## 1. Admissible instances and the abstract barrier -/

/-- An admissible experimental instance: `N = p·q` with `p < q` both prime, so
that "the smaller factor" is well defined. -/
def AdmissiblePair (p q : ℕ) : Prop := p.Prime ∧ q.Prime ∧ p < q

/-- **The abstract invisibility barrier.** If an `N`-computable statistic
`stat` takes the same value on two admissible instances carrying opposite
class labels, then no predicate of the statistic can decide the class. -/
theorem no_locator_of_collision {α : Type*} (stat : ℕ → α) (S : ℕ → Prop)
    {p q p' q' : ℕ} (h : AdmissiblePair p q) (h' : AdmissiblePair p' q')
    (heq : stat (p * q) = stat (p' * q')) (hS : S p) (hS' : ¬ S p') :
    ¬ ∃ f : α → Prop, ∀ x y : ℕ, AdmissiblePair x y → (f (stat (x * y)) ↔ S x) := by
  rintro ⟨f, hf⟩
  have h1 : f (stat (p * q)) := (hf p q h).mpr hS
  rw [heq] at h1
  exact hS' ((hf p' q' h').mp h1)

/-! ## 2. The two grand invisibility theorems

The statistic is `N ↦ (N % 60060, Nat.size N)`; since
`60060 = 2² · 3 · 5 · 7 · 11 · 13`, it determines `N mod ℓ` for every prime
`ℓ ≤ 13` (hence all five mutual informations measured in the experiment) and
every Jacobi symbol `(d | N)` for `d` a product of `-1, 2, 3, 5, 7, 11, 13`,
as well as the bit length used to match the experimental pairs. -/

/-- The colliding matched pair used for both barriers. -/
theorem matched_pair_collision :
    ((359 * 5849) % 60060, Nat.size (359 * 5849))
      = ((397 * 5743) % 60060, Nat.size (397 * 5743)) := by
  refine Prod.ext ?_ ?_
  · norm_num
  · decide

theorem admissible_359_5849 : AdmissiblePair 359 5849 :=
  ⟨by norm_num, by norm_num, by norm_num⟩

theorem admissible_397_5743 : AdmissiblePair 397 5743 :=
  ⟨by norm_num, by norm_num, by norm_num⟩

/-- **Grand invisibility, `+1`-divisibility channel.** No predicate of
`(N mod 60060, bitlength N)` decides whether the *smaller* prime factor
satisfies `3 ∣ p + 1`. -/
theorem plusOne_divisibility_invisible :
    ¬ ∃ f : ℕ × ℕ → Prop, ∀ x y : ℕ, AdmissiblePair x y →
      (f ((x * y) % 60060, Nat.size (x * y)) ↔ 3 ∣ x + 1) := by
  refine no_locator_of_collision (fun N => (N % 60060, Nat.size N)) (fun x => 3 ∣ x + 1)
    admissible_359_5849 admissible_397_5743 matched_pair_collision (by norm_num) (by norm_num)

/-- **Grand invisibility, character channel.** No predicate of
`(N mod 60060, bitlength N)` decides the base-3 Williams gate `(5 | p) = -1`
for the smaller prime factor — even though (by
`PlusOneWilliams.lucasV_eq_two_of_nonsquare_disc`) that gate is exactly the
condition under which the method succeeds. Note the same collision witnesses
serve both barriers, with the two labels swapped. -/
theorem williams_gate_invisible :
    ¬ ∃ f : ℕ × ℕ → Prop, ∀ x y : ℕ, AdmissiblePair x y →
      (f ((x * y) % 60060, Nat.size (x * y)) ↔ jacobiSym 5 x = -1) := by
  refine no_locator_of_collision (fun N => (N % 60060, Nat.size N))
    (fun x => jacobiSym 5 x = -1) admissible_397_5743 admissible_359_5849
    matched_pair_collision.symm (by norm_num) (by norm_num)

/-- Per-`ℓ` corollary (`ℓ = 3, 5, 7, 11, 13` are all divisors of `60060`):
the residue `N mod ℓ` cannot locate the `+1`-divisibility of the smaller
factor. This is the vanishing mutual information measured in the experiment. -/
theorem residue_cannot_locate_plusOne (l : ℕ) (hl : l ∣ 60060) :
    ¬ ∃ f : ℕ → Prop, ∀ x y : ℕ, AdmissiblePair x y → (f ((x * y) % l) ↔ 3 ∣ x + 1) := by
  rintro ⟨f, hf⟩
  refine plusOne_divisibility_invisible ⟨fun z => f (z.1 % l), fun x y hxy => ?_⟩
  simpa [Nat.mod_mod_of_dvd _ hl] using hf x y hxy

/-- Per-`ℓ` corollary for the discriminant gate. -/
theorem residue_cannot_locate_gate (l : ℕ) (hl : l ∣ 60060) :
    ¬ ∃ f : ℕ → Prop, ∀ x y : ℕ, AdmissiblePair x y → (f ((x * y) % l) ↔ jacobiSym 5 x = -1) := by
  rintro ⟨f, hf⟩
  refine williams_gate_invisible ⟨fun z => f (z.1 % l), fun x y hxy => ?_⟩
  simpa [Nat.mod_mod_of_dvd _ hl] using hf x y hxy

/-! ## 3. The dichotomy: the symmetric predicate *is* visible mod 3 -/

/-- **The `+1` divisibility dichotomy.** For primes `p, q ≠ 3`, the residue
`N mod 3` decides *exactly one* bit: whether an odd number of the two factors
is `≡ -1 mod 3`. It is a symmetric function of `(p, q)`, which is why the
symmetric control has high mutual information while the asymmetric label
"which factor" has none. -/
theorem mod_three_reveals_xor (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hp3 : p ≠ 3)
    (hq3 : q ≠ 3) :
    (p * q) % 3 = 2 ↔ Xor' (3 ∣ p + 1) (3 ∣ q + 1) := by
  have hp0 : p % 3 ≠ 0 := fun h =>
    hp3 ((Nat.prime_dvd_prime_iff_eq Nat.prime_three hp).mp (Nat.dvd_of_mod_eq_zero h)).symm
  have hq0 : q % 3 ≠ 0 := fun h =>
    hq3 ((Nat.prime_dvd_prime_iff_eq Nat.prime_three hq).mp (Nat.dvd_of_mod_eq_zero h)).symm
  have hmul : (p * q) % 3 = (p % 3) * (q % 3) % 3 := Nat.mul_mod p q 3
  have hxor : Xor' (3 ∣ p + 1) (3 ∣ q + 1) ↔ Xor' (p % 3 = 2) (q % 3 = 2) := by
    unfold Xor'; omega
  rw [hxor, hmul]
  have h1 : p % 3 = 1 ∨ p % 3 = 2 := by omega
  have h2 : q % 3 = 1 ∨ q % 3 = 2 := by omega
  rcases h1 with e1 | e1 <;> rcases h2 with e2 | e2 <;> rw [e1, e2] <;> simp [Xor']

/-- The visible symmetric control: a *single* residue test on `N` decides the
symmetric `+1`-divisibility predicate. Contrast with
`residue_cannot_locate_plusOne`. -/
theorem symmetric_plusOne_visible_mod_three :
    ∃ f : ℕ → Prop, ∀ x y : ℕ, AdmissiblePair x y → x ≠ 3 → y ≠ 3 →
      (f ((x * y) % 3) ↔ Xor' (3 ∣ x + 1) (3 ∣ y + 1)) := by
  refine ⟨fun r => r = 2, fun x y hxy hx3 hy3 => ?_⟩
  exact mod_three_reveals_xor x y hxy.1 hxy.2.1 hx3 hy3

/-- If `N ≡ 2 mod 3` then *some* factor is `≡ -1 mod 3`: the symmetric
existential statement is `N`-computable. -/
theorem mod_three_reveals_some_factor (p q : ℕ) (hp : p.Prime) (hq : q.Prime) (hp3 : p ≠ 3)
    (hq3 : q ≠ 3) (h : (p * q) % 3 = 2) : 3 ∣ p + 1 ∨ 3 ∣ q + 1 := by
  rcases (mod_three_reveals_xor p q hp hq hp3 hq3).mp h with ⟨h1, _⟩ | ⟨h2, _⟩
  · exact Or.inl h1
  · exact Or.inr h2

/-! ## 4. The character channel: `(D | N)` is a symmetric product -/

/-- The `N`-computable character is the *product* of the two local characters:
`(D | N) = (D | p)(D | q)`. -/
theorem jacobiSym_semiprime_split (D : ℤ) (p q : ℕ) [Fact p.Prime] [Fact q.Prime] :
    jacobiSym D (p * q) = legendreSym p D * legendreSym q D := by
  haveI : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
  haveI : NeZero q := ⟨(Fact.out : q.Prime).ne_zero⟩
  rw [jacobiSym.mul_right, ← jacobiSym.legendreSym.to_jacobiSym,
    ← jacobiSym.legendreSym.to_jacobiSym]

/-- **The character split is uncomputable from `N`.** The value `(5 | N) = +1`
occurs both when both local characters are `-1` (so the base-3 Williams gate
holds at the smaller factor) and when both are `+1` (gate fails): the product
carries no information about the split. -/
theorem jacobi_gate_product_uninformative :
    jacobiSym 5 (3 * 7) = 1 ∧ jacobiSym 5 3 = -1 ∧
    jacobiSym 5 (11 * 19) = 1 ∧ jacobiSym 5 11 = 1 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num⟩

/-- Consequently no predicate of `(5 | N)` decides the gate at the smaller
factor. -/
theorem jacobi_of_N_cannot_locate_gate :
    ¬ ∃ f : ℤ → Prop, ∀ x y : ℕ, AdmissiblePair x y →
      (f (jacobiSym 5 (x * y)) ↔ jacobiSym 5 x = -1) := by
  refine no_locator_of_collision (fun N => jacobiSym 5 N) (fun x => jacobiSym 5 x = -1)
    (⟨by norm_num, by norm_num, by norm_num⟩ : AdmissiblePair 3 7)
    (⟨by norm_num, by norm_num, by norm_num⟩ : AdmissiblePair 11 19) ?_ (by norm_num) (by norm_num)
  norm_num

/-! ## 5. Positive control: the classical method really does split -/

/-- **The positive control.** If the discriminant gate holds at `p`, the
exponent `M` is a multiple of `p + 1`, and `q` does not accidentally divide
`V_M - 2`, then the Williams gcd returns the factor `p` exactly. -/
theorem williams_splits {p q : ℕ} [Fact p.Prime] (hq : q.Prime) (hp2 : p ≠ 2) (P : ℤ)
    (hD : legendreSym p (P ^ 2 - 4) = -1) {M : ℕ} (hM : (p + 1) ∣ M)
    (hqV : ¬ (q : ℤ) ∣ lucasV P M - 2) :
    Int.gcd (lucasV P M - 2) ((p * q : ℕ) : ℤ) = p :=
  williams_gcd_eq_factor Fact.out hq (dvd_lucasV_sub_two p hp2 P hD hM) hqV

/-- **Capstone positive control.** If `p + 1` is `B`-powersmooth and the
discriminant gate is closed at `p`, then the classical 1982 algorithm with the
standard exponent `M = lcm(1, …, B)` splits `N = p q`. Both hypotheses are
properties of the hidden factor, not of `N`; by
`plusOne_divisibility_invisible` and `williams_gate_invisible` neither is
readable from `N`. -/
theorem williams_splits_of_powersmooth {p q : ℕ} [Fact p.Prime] (hq : q.Prime) (hp2 : p ≠ 2)
    (P : ℤ) (hD : legendreSym p (P ^ 2 - 4) = -1) (B : ℕ)
    (hsm : ∀ l : ℕ, l.Prime → l ^ ((p + 1).factorization l) ≤ B)
    (hqV : ¬ (q : ℤ) ∣ lucasV P (lcmUpTo B) - 2) :
    Int.gcd (lucasV P (lcmUpTo B) - 2) ((p * q : ℕ) : ℤ) = p :=
  williams_splits hq hp2 P hD (dvd_lcmUpTo_of_powersmooth (Nat.succ_ne_zero p) hsm) hqV

/-- The predicate `jacobiSym 5 p = -1` used in `williams_gate_invisible` *is*
the base-3 discriminant gate: for a prime `p` it says exactly that
`D = 3² - 4 = 5` is a non-residue mod `p`. -/
theorem gate_iff_jacobi (p : ℕ) [Fact p.Prime] :
    jacobiSym 5 p = -1 ↔ ¬ IsSquare ((3 : ZMod p) ^ 2 - 4) := by
  have hcast : ((5 : ℤ) : ZMod p) = (3 : ZMod p) ^ 2 - 4 := by push_cast; ring
  rw [← jacobiSym.legendreSym.to_jacobiSym, legendreSym.eq_neg_one_iff, hcast]

/-- The gate predicate really drives the method: whenever `jacobiSym 5 p = -1`
and `(p + 1) ∣ M`, the base-3 Lucas sequence hits `2` mod `p`. -/
theorem williams_base_three_succeeds (p : ℕ) [Fact p.Prime] (hp2 : p ≠ 2)
    (hgate : jacobiSym 5 p = -1) {M : ℕ} (hM : (p + 1) ∣ M) :
    lucasV (3 : ZMod p) M = 2 :=
  lucasV_eq_two_of_nonsquare_disc p hp2 3 ((gate_iff_jacobi p).mp hgate) hM

/-- Explicit instance of the positive control: `p = 7` has `p + 1 = 8`, the
base `P = 3` has discriminant `D = 5` with `(5 | 7) = -1`, and the method
splits `N = 91 = 7 · 13` at exponent `M = 8`. -/
theorem williams_example_seven : Int.gcd (lucasV (3 : ℤ) 8 - 2) ((7 * 13 : ℕ) : ℤ) = 7 := by
  decide

private theorem fact_prime_seven : Fact (Nat.Prime 7) := ⟨by norm_num⟩

attribute [local instance] fact_prime_seven

/-- The gate really is the mechanism in the explicit instance: `(D | 7) = -1`
for `D = 3² - 4 = 5`, and `7 ∣ V₈(3) - 2`. -/
theorem williams_example_gate : legendreSym 7 ((3 : ℤ) ^ 2 - 4) = -1 ∧
    (7 : ℤ) ∣ lucasV (3 : ℤ) 8 - 2 := by
  constructor
  · rw [legendreSym.eq_neg_one_iff]
    decide
  · decide

/-- **Gate necessity, explicit.** At `p = 11` the base-3 discriminant `5` *is*
a square (`4² = 5 mod 11`), and correspondingly `V₁₂ = 3² - 2 = 7 ≢ 2`: the
`p + 1` congruence genuinely fails when the gate is open, matching
`PlusOneWilliams.lucasV_p_add_one_of_square_disc`. -/
theorem gate_failure_example :
    IsSquare ((3 : ZMod 11) ^ 2 - 4) ∧ lucasV (3 : ZMod 11) 12 = (3 : ZMod 11) ^ 2 - 2 ∧
      lucasV (3 : ZMod 11) 12 ≠ 2 := by
  refine ⟨by decide, by decide, by decide⟩

/-- Integer shadow of the same failure: the Williams gcd at `p = 11` returns
nothing, because `11 ∤ V₁₂(3) - 2`. -/
theorem gate_failure_example_int : ¬ ((11 : ℤ) ∣ lucasV (3 : ℤ) 12 - 2) := by decide

/-- Bases `P = 3` and `P = 7` are gated by the *same* character: their
discriminants `5` and `45 = 5 · 3²` lie in one square class, so away from
`p = 3` the two bases succeed on exactly the same primes. This is the
experimental coincidence `P = 3 : 11/40` and `P = 7 : 11/40` *on the same
instances*. -/
theorem bases_three_and_seven_same_gate (p : ℕ) [Fact p.Prime] (hp3 : p ≠ 3) :
    legendreSym p ((3 : ℤ) ^ 2 - 4) = legendreSym p ((7 : ℤ) ^ 2 - 4) := by
  have h3 : ((3 : ℤ) ^ 2 - 4) = 5 := by norm_num
  have h7 : ((7 : ℤ) ^ 2 - 4) = 45 := by norm_num
  rw [h3, h7, legendreSym_fortyfive_eq_five p hp3]

/-! ## 6. Tropical corner: the returned factor lies below `√N` -/

/-- The factor returned by a successful Williams run is the divisor on the
lower side of the tropical corner `√N` of the divisor hyperbola
(`FactorLocationBarriers.divisor_pair_straddles_corner`): the method locates a
lattice point in the window `[1, √N]` that no `N`-statistic could point to. -/
theorem williams_output_below_tropical_corner {p q : ℕ} [Fact p.Prime] (hq : q.Prime)
    (hpq : p ≤ q) (hp2 : p ≠ 2) (P : ℤ) (hD : legendreSym p (P ^ 2 - 4) = -1) {M : ℕ}
    (hM : (p + 1) ∣ M) (hqV : ¬ (q : ℤ) ∣ lucasV P M - 2) :
    Int.gcd (lucasV P M - 2) ((p * q : ℕ) : ℤ) = p ∧ p ≤ Nat.sqrt (p * q) := by
  have hp : p.Prime := Fact.out
  refine ⟨williams_splits hq hp2 P hD hM hqV, ?_⟩
  have hN : p * q ≠ 0 := Nat.mul_ne_zero hp.ne_zero hq.ne_zero
  have hd : p ∣ p * q := Dvd.intro q rfl
  have h := (FactorLocationBarriers.divisor_pair_straddles_corner (p * q) p hN hd).1
  rwa [Nat.mul_div_cancel_left q hp.pos, min_eq_left hpq] at h

end PlusOneSmoothNull