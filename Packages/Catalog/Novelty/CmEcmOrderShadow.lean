/-
# CM-ECM-ORDER: the ECM order of the Gaussian CM curve `y² = x³ + x`
collapses to `p + 1` on the inert half — a residue shadow with no
which-factor content

This file formalises the *structural skeleton* behind experiment 402
(assessment v178, "CM-ECM-ORDER"): the empirical finding that for the CM curve

  `E : y² = x³ + x`  (End = ℤ[i], Gauss 1801)

the trace `a_p` vanishes **exactly** on the inert primes `p ≡ 3 (mod 4)`, that
`4 ∣ #E(𝔽_p)` for *every* odd prime, and that the resulting "residue shadow"
carried by `#E` is nothing but the abelian `p + 1` channel (Williams 1982),
hence carries no which-factor information about a semiprime `N = pq`.

Everything is built on the existing catalog development `Algebra.ECMParityCore`
/ `Algebra.ECMParityMod4` (the `ECMParity.curveCard` point count of
`y² = x³ + A x + B` over `ZMod p`); nothing is re-invented.

## Main results

* `CmEcmOrder.cmCard_inert` — **supersingularity on the inert half**: if
  `p ≡ 3 (mod 4)` then `#E(𝔽_p) = p + 1`, i.e. `a_p = 0` (`cmTrace_inert`).
  Proved by the `x ↦ -x` sign involution: `f(-x) = -f(x)` and `-1` is a
  non-residue, so exactly one of `x`, `-x` contributes two points.
* `CmEcmOrder.four_dvd_cmCard` — **universal `4 ∣ #E`** for every odd prime:
  on the split half via the full rational `2`-torsion `{0, ±i}` of `x³ + x`,
  on the inert half because `4 ∣ p + 1`.
* `CmEcmOrder.cmCard_ne_split`, `CmEcmOrder.cmTrace_eq_zero_iff` — **the CM
  dichotomy is exact**: `a_p = 0 ↔ p ≡ 3 (mod 4)`.  The ordinarity of the split
  half is *derived* from the mod-4 count: `4 ∣ #E` while `p + 1 ≡ 2 (mod 4)`.
* `CmEcmOrder.cm_shadow_is_congruence`, `CmEcmOrder.cmCard_dvd_iff_mod` — the
  shadow on the inert half is a **congruence condition on `p mod 4ℓ`**.
* `CmEcmOrder.symmetric_shadow_live` — the **positive** part: `p, q ≡ 3 (mod 4)`
  and `pq ≡ 5 (mod 12)` forces `3 ∣ #E(𝔽_p)` or `3 ∣ #E(𝔽_q)`; the symmetric
  bit really is visible from `N mod 12`.
* `CmEcmOrder.which_factor_bit_invisible` — the **null**: two semiprimes with
  the same residue `N mod 12`, both with the symmetric event true, whose
  *least-factor* bit disagrees.  The asymmetric (which-factor) channel is empty.
* `CmEcmOrder.symmetric_shadow_partial` — and even the symmetric bit is only
  partially determined: `N ≡ 1 (mod 12)` is compatible with both truth values.
* `CmEcmOrder.cm_stage1_eq_plusOne`, `CmEcmOrder.cm_smooth_iff_plusOne_smooth` —
  on the inert half ECM stage 1 on this curve *is* the `p + 1` method.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Experiment 402 reports `a_p = 0` on 2027/2027
  inert primes and `4 ∣ #E` on 1000/1000 samples.  Both should be theorems, and
  the second should hold on *both* halves for different reasons — an exact
  statement, not a statistical one.
* **Experiment (Experimenter).**  The inert half needs only the sign involution
  (no Jacobsthal sums, no Gauss reciprocity): with `-1` a non-residue exactly
  one of `f(x)`, `f(-x) = -f(x)` is a square, so the `x`-fibres pair up to two
  points per `{x, -x}` pair, giving `#affine = 1 + (p - 1) = p`.  The split half
  needs the `2`-torsion count already in `Algebra.ECMParityMod4`
  (`four_dvd_curveCard_of_three_roots`), applied to the roots `0, i, -i`.
* **Analysis (Analyst).**  The two halves *combine*: `4 ∣ #E` on the split half
  is incompatible with `#E = p + 1 ≡ 2 (mod 4)`, so ordinarity of the split half
  is a corollary of a mod-4 count — no CM theory, no Deuring, no Gauss.  This is
  the cheapest known proof that `y² = x³ + x` is supersingular exactly at
  `p ≡ 3 (mod 4)`.
* **Critique (Critic).**  Does the residue shadow have factoring content?  No:
  on the inert half `#E = p + 1` verbatim, so the divisibility event is the
  congruence `p ≡ -1 (mod ℓ)` — visible only through `N mod 4ℓ`, and only
  symmetrically.  `which_factor_bit_invisible` exhibits the collision
  `77 ≡ 209 (mod 12)` with opposite least-factor bits; the barrier-2 loss of the
  which-factor bit is thus a theorem, not a statistic.
-/
import Mathlib
import Algebra.ECMParityCore
import Algebra.ECMParityMod4
import Novelty.IsSmooth

namespace CmEcmOrder

open Finset ECMParity

/-! ## 0. The curve and its order -/

variable {p : ℕ} [Fact p.Prime]

/-- The projective point count `#E(𝔽_p)` of the Gaussian CM curve `y² = x³ + x`. -/
def cmCard (p : ℕ) [Fact p.Prime] : ℕ := ECMParity.curveCard (1 : ZMod p) 0

/-- The trace of Frobenius `a_p = p + 1 - #E(𝔽_p)` of `y² = x³ + x`. -/
def cmTrace (p : ℕ) [Fact p.Prime] : ℤ := (p : ℤ) + 1 - (cmCard p : ℤ)

theorem cubic_one_zero (x : ZMod p) : cubic (1 : ZMod p) 0 x = x * (x ^ 2 + 1) := by
  rw [cubic]; ring

/-- The curve `y² = x³ + x` is separable in every odd characteristic. -/
theorem disc_ne_zero (hp : p ≠ 2) : disc (1 : ZMod p) 0 ≠ 0 := by
  have hp' : p.Prime := Fact.out
  intro h
  rw [disc] at h
  have h4 : ((4 : ℕ) : ZMod p) = 0 := by push_cast; linear_combination -h
  rw [ZMod.natCast_eq_zero_iff] at h4
  have h2 : p ∣ 2 ^ 2 := by simpa using h4
  exact hp ((Nat.prime_dvd_prime_iff_eq hp' Nat.prime_two).1 (hp'.dvd_of_dvd_pow h2))

/-! ## 1. The inert half: `a_p = 0` -/

section Inert

variable (hp3 : p % 4 = 3)
include hp3

omit [Fact (Nat.Prime p)] in
theorem p_ne_two : p ≠ 2 := by omega

/-- On the inert half `-1` is a non-residue (this *is* inertness of `p` in `ℤ[i]`). -/
theorem not_isSquare_neg_one : ¬ IsSquare (-1 : ZMod p) := by
  intro h
  exact (ZMod.exists_sq_eq_neg_one_iff.1 h) hp3

/-- `c ⬝ (-c)` is never a square when `-1` is not: the sign involution flips the
quadratic character. -/
theorem not_isSquare_mul_neg {c : ZMod p} (hc : c ≠ 0) : ¬ IsSquare (c * -c) := by
  rintro ⟨s, hs⟩
  refine not_isSquare_neg_one hp3 ⟨s / c, ?_⟩
  rw [div_mul_div_comm, eq_div_iff (mul_ne_zero hc hc)]
  linear_combination hs

/-- Away from `0` the cubic `x³ + x` has no zeros on the inert half. -/
theorem cubic_ne_zero {x : ZMod p} (hx : x ≠ 0) : cubic (1 : ZMod p) 0 x ≠ 0 := by
  rw [cubic_one_zero]
  intro h
  rcases mul_eq_zero.1 h with h' | h'
  · exact hx h'
  · exact not_isSquare_neg_one hp3 ⟨x, by linear_combination -h'⟩

/-- The `2`-torsion is rational only at `x = 0`: the root set of `x³ + x` is `{0}`. -/
theorem rootSet_inert : rootSet (1 : ZMod p) 0 = {0} := by
  ext x
  simp only [rootSet, mem_filter, mem_univ, true_and, mem_singleton]
  constructor
  · intro hx
    by_contra hx0
    exact cubic_ne_zero hp3 hx0 hx
  · rintro rfl
    simp [cubic]

/-- **The sign flip.**  For `x ≠ 0` exactly one of `x`, `-x` carries two points. -/
theorem sqSet_flip {x : ZMod p} (hx : x ≠ 0) :
    x ∈ sqSet (1 : ZMod p) 0 ↔ -x ∉ sqSet (1 : ZMod p) 0 := by
  have hfx : cubic (1 : ZMod p) 0 x ≠ 0 := cubic_ne_zero hp3 hx
  have hneg : cubic (1 : ZMod p) 0 (-x) = -cubic (1 : ZMod p) 0 x := by rw [cubic, cubic]; ring
  have hfnx : cubic (1 : ZMod p) 0 (-x) ≠ 0 := by rw [hneg]; simpa using hfx
  have hkey : IsSquare (cubic (1 : ZMod p) 0 x) ↔ ¬ IsSquare (cubic (1 : ZMod p) 0 (-x)) := by
    refine isSquare_iff_not_of_mul_not_isSquare hfx hfnx ?_
    rw [hneg]
    exact not_isSquare_mul_neg hp3 hfx
  rw [mem_sqSet, mem_sqSet]
  constructor
  · rintro ⟨-, hsq⟩ ⟨-, hsq'⟩
    exact (hkey.1 hsq) hsq'
  · intro h
    exact ⟨hfx, hkey.2 (fun hs => h ⟨hfnx, hs⟩)⟩

/-- Half of the nonzero `x` carry two points: `2 · #sqSet = p - 1`. -/
theorem sqSet_card_inert : 2 * (sqSet (1 : ZMod p) 0).card = p - 1 := by
  classical
  set T := sqSet (1 : ZMod p) 0 with hT
  set U := (univ : Finset (ZMod p)).erase 0 with hU
  have hTU : T ⊆ U := by
    intro x hx
    rw [hU, mem_erase]
    refine ⟨?_, mem_univ x⟩
    rintro rfl
    rw [hT, mem_sqSet] at hx
    exact hx.1 (by simp [cubic])
  have hcardU : U.card = p - 1 := by
    rw [hU, card_erase_of_mem (mem_univ _), card_univ, ZMod.card]
  have hbij : (U \ T).card = T.card := by
    refine (Finset.card_bij (fun x _ => -x) ?_ ?_ ?_).symm
    · intro x hx
      have hx0 : x ≠ 0 := by
        have := hTU hx
        rw [hU, mem_erase] at this
        exact this.1
      rw [mem_sdiff, hU, mem_erase]
      exact ⟨⟨by simpa using hx0, mem_univ _⟩, (sqSet_flip hp3 hx0).1 hx⟩
    · intro x _ y _ h
      simpa using h
    · intro y hy
      rw [mem_sdiff, hU, mem_erase] at hy
      obtain ⟨⟨hy0, -⟩, hyT⟩ := hy
      have hny0 : -y ≠ 0 := by simpa using hy0
      have hmem : -y ∈ T := by
        have := (sqSet_flip hp3 hny0)
        rw [neg_neg] at this
        exact this.2 hyT
      exact ⟨-y, hmem, by ring⟩
  have hsplit : (U \ T).card + T.card = U.card := card_sdiff_add_card_eq_card hTU
  omega

/-- **Supersingularity on the inert half.**  For `p ≡ 3 (mod 4)` the Gaussian CM
curve has exactly `p + 1` points: `#E(𝔽_p) = p + 1`. -/
theorem cmCard_inert : cmCard p = p + 1 := by
  have hp2 : p ≠ 2 := p_ne_two hp3
  have hroot : (rootSet (1 : ZMod p) 0).card = 1 := by
    rw [rootSet_inert hp3, card_singleton]
  have hsq := sqSet_card_inert hp3
  have := curveCard_eq (A := (1 : ZMod p)) (B := 0) hp2
  rw [cmCard, this, hroot]
  omega

/-- The trace of Frobenius vanishes on the inert half: `a_p = 0`. -/
theorem cmTrace_inert : cmTrace p = 0 := by
  rw [cmTrace, cmCard_inert hp3]
  push_cast
  ring

end Inert

/-! ## 2. The split half: full `2`-torsion, hence `4 ∣ #E` and `a_p ≠ 0` -/

section Split

variable (hp1 : p % 4 = 1)
include hp1

omit [Fact (Nat.Prime p)] in
theorem p_ne_two_split : p ≠ 2 := by omega

/-- On the split half `x³ + x` has the three roots `0, i, -i`, so `4 ∣ #E(𝔽_p)`. -/
theorem four_dvd_cmCard_split : 4 ∣ cmCard p := by
  obtain ⟨i, hi⟩ : IsSquare (-1 : ZMod p) :=
    ZMod.exists_sq_eq_neg_one_iff.2 (by omega)
  have hp2 : p ≠ 2 := p_ne_two_split hp1
  have hi0 : i ≠ 0 := by
    rintro rfl
    have h1 : (1 : ZMod p) = 0 := by linear_combination -hi
    exact one_ne_zero h1
  have h0 : cubic (1 : ZMod p) 0 (0 : ZMod p) = 0 := by simp [cubic]
  have hii : cubic (1 : ZMod p) 0 i = 0 := by
    rw [cubic_one_zero]
    have : i ^ 2 + 1 = 0 := by linear_combination -hi
    rw [this, mul_zero]
  exact four_dvd_curveCard_of_three_roots (a := (0 : ZMod p)) hp2 (disc_ne_zero hp2) h0 hii
    (Ne.symm hi0)

/-- **Ordinarity of the split half.**  For `p ≡ 1 (mod 4)` the count is *not*
`p + 1`: `4 ∣ #E` while `p + 1 ≡ 2 (mod 4)`. -/
theorem cmCard_ne_split : cmCard p ≠ p + 1 := by
  intro h
  obtain ⟨k, hk⟩ := four_dvd_cmCard_split hp1
  omega

/-- Equivalently `a_p ≠ 0` on the split half. -/
theorem cmTrace_ne_zero_split : cmTrace p ≠ 0 := by
  intro h
  apply cmCard_ne_split hp1
  have : (cmCard p : ℤ) = (p : ℤ) + 1 := by rw [cmTrace] at h; linarith
  exact_mod_cast this

end Split

/-! ## 3. The exact CM dichotomy -/

/-- **Universal `4 ∣ #E`** for the Gaussian CM curve at every odd prime: on the
split half from the rational `2`-torsion, on the inert half from `4 ∣ p + 1`. -/
theorem four_dvd_cmCard (hp : p ≠ 2) : 4 ∣ cmCard p := by
  have hp' : p.Prime := Fact.out
  have hodd : p % 2 = 1 := Nat.odd_iff.1 (hp'.odd_of_ne_two hp)
  rcases (by omega : p % 4 = 1 ∨ p % 4 = 3) with h | h
  · exact four_dvd_cmCard_split h
  · rw [cmCard_inert h]; omega

/-- **The CM structure is exact**: for an odd prime, the trace of Frobenius of
`y² = x³ + x` vanishes *exactly* on the inert primes `p ≡ 3 (mod 4)`. -/
theorem cmTrace_eq_zero_iff (hp : p ≠ 2) : cmTrace p = 0 ↔ p % 4 = 3 := by
  have hp' : p.Prime := Fact.out
  have hodd : p % 2 = 1 := Nat.odd_iff.1 (hp'.odd_of_ne_two hp)
  constructor
  · intro h
    rcases (by omega : p % 4 = 1 ∨ p % 4 = 3) with h4 | h4
    · exact absurd h (cmTrace_ne_zero_split h4)
    · exact h4
  · exact cmTrace_inert

/-! ## 4. The residue shadow: a congruence condition on `p mod 4ℓ` -/

/-- On the inert half the divisibility `ℓ ∣ #E(𝔽_p)` *is* the `p + 1` condition
`p ≡ -1 (mod ℓ)`. -/
theorem cmCard_dvd_iff_mod (hp3 : p % 4 = 3) {l : ℕ} (hl : 2 ≤ l) :
    l ∣ cmCard p ↔ p % l = l - 1 := by
  rw [cmCard_inert hp3]
  have hlpos : 0 < l := by omega
  have hr : p % l < l := Nat.mod_lt _ hlpos
  have hkey : (p + 1) % l = (p % l + 1) % l := by
    rw [Nat.add_mod p 1 l, Nat.mod_eq_of_lt (by omega : 1 < l)]
  rw [Nat.dvd_iff_mod_eq_zero, hkey]
  constructor
  · intro h
    by_contra hne
    have hlt : p % l + 1 < l := by omega
    rw [Nat.mod_eq_of_lt hlt] at h
    omega
  · intro h
    have : p % l + 1 = l := by omega
    rw [this, Nat.mod_self]

/-- **The shadow is a congruence class.**  For two inert primes agreeing mod `4ℓ`
the events `ℓ ∣ #E` agree: all the information the elliptic order exposes is
already contained in `p mod 4ℓ`. -/
theorem cm_shadow_is_congruence {q : ℕ} [Fact q.Prime] (hp3 : p % 4 = 3) (hq3 : q % 4 = 3)
    {l : ℕ} (hl : 2 ≤ l) (h : p % (4 * l) = q % (4 * l)) :
    (l ∣ cmCard p ↔ l ∣ cmCard q) := by
  have hd : l ∣ 4 * l := ⟨4, by ring⟩
  have hpq : p % l = q % l := by
    calc p % l = p % (4 * l) % l := (Nat.mod_mod_of_dvd p hd).symm
      _ = q % (4 * l) % l := by rw [h]
      _ = q % l := Nat.mod_mod_of_dvd q hd
  rw [cmCard_dvd_iff_mod hp3 hl, cmCard_dvd_iff_mod hq3 hl, hpq]

/-! ## 5. The symmetric channel is live, the asymmetric one is empty -/

/-- Pure arithmetic behind the symmetric leak: two residues `≡ 3 (mod 4)` whose
product is `5 (mod 12)` cannot both avoid `11 (mod 12)`. -/
theorem mod_twelve_five_forces {a b : ℕ} (ha : a % 4 = 3) (hb : b % 4 = 3)
    (hab : (a * b) % 12 = 5) : a % 12 = 11 ∨ b % 12 = 11 := by
  have hmul : (a * b) % 12 = ((a % 12) * (b % 12)) % 12 := Nat.mul_mod a b 12
  have ha12 : a % 12 = 3 ∨ a % 12 = 7 ∨ a % 12 = 11 := by omega
  have hb12 : b % 12 = 3 ∨ b % 12 = 7 ∨ b % 12 = 11 := by omega
  rcases ha12 with h | h | h <;> rcases hb12 with h' | h' | h' <;>
    rw [h, h'] at hmul <;> omega

/-- **The symmetric residue shadow is live.**  If `N = pq` with `p, q ≡ 3 (mod 4)`
and `N ≡ 5 (mod 12)`, then `3` divides the CM order of one of the two factors.
This is the (weak, symmetric) positive signal reported by experiment 402. -/
theorem symmetric_shadow_live {q : ℕ} [Fact q.Prime] (hp3 : p % 4 = 3) (hq3 : q % 4 = 3)
    (hN : (p * q) % 12 = 5) : 3 ∣ cmCard p ∨ 3 ∣ cmCard q := by
  rw [cmCard_inert hp3, cmCard_inert hq3]
  rcases mod_twelve_five_forces hp3 hq3 hN with h | h
  · exact Or.inl (by omega)
  · exact Or.inr (by omega)

/-! ### Explicit inert primes -/

instance fact_prime_seven : Fact (Nat.Prime 7) := ⟨by norm_num⟩
instance fact_prime_eleven : Fact (Nat.Prime 11) := ⟨by norm_num⟩
instance fact_prime_nineteen : Fact (Nat.Prime 19) := ⟨by norm_num⟩
instance fact_prime_five : Fact (Nat.Prime 5) := ⟨by norm_num⟩

theorem cmCard_seven : cmCard 7 = 8 := by
  rw [cmCard_inert (by norm_num : 7 % 4 = 3)]

theorem cmCard_eleven : cmCard 11 = 12 := by
  rw [cmCard_inert (by norm_num : 11 % 4 = 3)]

theorem cmCard_nineteen : cmCard 19 = 20 := by
  rw [cmCard_inert (by norm_num : 19 % 4 = 3)]

theorem cmCard_twentythree : cmCard 23 = 24 := by
  rw [cmCard_inert (by norm_num : 23 % 4 = 3)]

/-- **The null (barrier 2): the which-factor bit is invisible.**  The semiprimes
`77 = 7 · 11` and `209 = 11 · 19` have the same residue mod `12`, and for both
the *symmetric* event "`3` divides the CM order of some factor" is true; but the
*asymmetric* bit "`3` divides the CM order of the least factor" disagrees.  No
function of `N mod 12` can therefore recover which factor carries the shadow. -/
theorem which_factor_bit_invisible :
    (7 * 11) % 12 = (11 * 19) % 12 ∧
      (3 ∣ cmCard 7 ∨ 3 ∣ cmCard 11) ∧ (3 ∣ cmCard 11 ∨ 3 ∣ cmCard 19) ∧
      ¬ (3 ∣ cmCard 7) ∧ (3 ∣ cmCard 11) := by
  refine ⟨by norm_num, ?_, ?_, ?_, ?_⟩ <;>
    simp only [cmCard_seven, cmCard_eleven, cmCard_nineteen] <;> omega

/-- **The symmetric channel is itself only partial.**  `133 = 7 · 19` and
`253 = 11 · 23` are congruent mod `12`, yet the symmetric event fails for the
first and holds for the second: `N mod 12` does not decide the shadow. -/
theorem symmetric_shadow_partial :
    (7 * 19) % 12 = (11 * 23) % 12 ∧
      ¬ (3 ∣ cmCard 7 ∨ 3 ∣ cmCard 19) ∧ (3 ∣ cmCard 11 ∨ 3 ∣ cmCard 23) := by
  refine ⟨by norm_num, ?_, ?_⟩ <;>
    simp only [cmCard_seven, cmCard_eleven, cmCard_nineteen, cmCard_twentythree] <;> omega

/-! ## 6. Stage 1 on the inert half *is* the `p + 1` method -/

/-- On the inert half the ECM stage-1 divisibility target of the CM curve is
literally the Williams `p + 1` target. -/
theorem cm_stage1_eq_plusOne (hp3 : p % 4 = 3) (M : ℕ) : cmCard p ∣ M ↔ (p + 1) ∣ M := by
  rw [cmCard_inert hp3]

/-- Consequently stage-1 smoothness of the CM order is smoothness of `p + 1`:
the channel closed at PLUSONE-SMOOTH-NULL. -/
theorem cm_smooth_iff_plusOne_smooth (hp3 : p % 4 = 3) (B : ℕ) :
    isSmooth B (cmCard p) ↔ isSmooth B (p + 1) := by
  rw [cmCard_inert hp3]

/-- On the **split** half the two channels genuinely differ: at `p = 5` the
`p + 1` target `6` is divisible by `3` while the CM order `#E(𝔽₅) = 4` is not.
So the CM curve neither refines nor is refined by the `p + 1` method — it simply
re-partitions the primes. -/
theorem split_breaks_plusOne_channel :
    cmCard 5 = 4 ∧ (3 ∣ 5 + 1) ∧ ¬ (3 ∣ cmCard 5) ∧ cmCard 5 ≠ 5 + 1 := by
  have h5 : cmCard 5 = 4 := by decide
  exact ⟨h5, by norm_num, by rw [h5]; decide, by rw [h5]; decide⟩

end CmEcmOrder