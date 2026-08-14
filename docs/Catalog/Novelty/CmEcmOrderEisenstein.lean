/-
# CM-ECM-ORDER, cycle 3: the Eisenstein mirror `y² = x³ + 1` and the exact
`j = 0` dichotomy

Cycles 1–2 settled the Gaussian CM curve `y² = x³ + x` (`End = ℤ[i]`, `D = −4`):
supersingular exactly on `p ≡ 3 (mod 4)`, with `4 ∣ #E` universally.  This file
carries out the mirror analysis at the other class-number-one CM discriminant
reachable with elementary tools, `D = −3`, i.e. the family `y² = x³ + B`
(`End = ℤ[ζ₃]`, Eisenstein):

* the *inert* half `p ≡ 2 (mod 3)`: the cube map is a bijection of `𝔽_p`, so the
  character sum collapses to `∑_t χ(t + B) = 0` and **every** curve of the family
  has exactly `p + 1` points;
* the *split* half `p ≡ 1 (mod 3)`: the cube root of unity `ζ` acts on the curve
  by `(x, y) ↦ (ζx, y)` with only `(0, ±1)` and `∞` fixed, so `3 ∣ #E`; since
  `p + 1 ≡ 2 (mod 3)` this forces `a_p ≠ 0`.

The structure of the argument is *exactly* the cycle-1 structure with `2 ↔ 3`:
a divisibility coming from an automorphism replaces all of CM theory, and the
ordinarity of the split half is a corollary of that divisibility.  The free
`ℤ/3`-action counting lemma `Finset.card_dvd_three_of_free_cycle` is proved here
from scratch (the `ℤ/2` analogue `ECMParity.card_even_of_free_involution` was
already in the catalog).

## Main results

* `Finset.card_dvd_three_of_free_cycle` — a fixed-point-free order-`3` symmetry
  of a finite set forces `3 ∣` its cardinality.
* `CmEcmOrder.charSum_zero_of_eisenstein_inert`,
  `CmEcmOrder.supersingular_eisenstein_family` — for `p ≡ 2 (mod 3)` every curve
  `y² = x³ + B` has `p + 1` points.
* `CmEcmOrder.three_dvd_eisCard` — for `p ≡ 1 (mod 3)`, `3 ∣ #E(𝔽_p)` for
  `y² = x³ + 1`, via the free action of `⟨ζ₃⟩` off the `x = 0` fibre.
* `CmEcmOrder.eisTrace_eq_zero_iff` — **the exact `j = 0` dichotomy**: for
  `p ∉ {2, 3}`, `a_p = 0 ↔ p ≡ 2 (mod 3)`.
* `CmEcmOrder.cm_dichotomies_independent` — the two CM families cut the primes
  along *independent* congruences: at `p ≡ 7 (mod 12)` the Gaussian curve is
  ordinary while the Eisenstein curve is supersingular, and at `p ≡ 3 (mod 4)`,
  `p ≡ 1 (mod 3)` the reverse.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  If the cycle-1 dichotomy really is "an
  automorphism forces `ℓ ∣ #E`, and `p + 1 ≢ 0 (mod ℓ)` on the split half", then
  the same two-line scheme must work verbatim at `ℓ = 3` for `j = 0`.  Prediction:
  `3 ∣ #E(y² = x³ + 1)` for every `p ≡ 1 (mod 3)`.
* **Experiment (Experimenter).**  Confirmed and formalised.  The `ℤ/3`-orbit
  count needed a new combinatorial lemma (strong induction removing one
  three-element orbit at a time); the fixed points are exactly `(0, ±1)` and the
  point at infinity, giving `#E ≡ 3 ≡ 0 (mod 3)`.
* **Analysis (Analyst).**  Two independent mechanisms produce the same shape of
  result: rational `2`-torsion at `D = −4` and a rational `3`-isogeny/inflection
  point at `D = −3`.  In both cases the residue shadow visible from `N` is only
  the abelian one (`p ± 1`); the split-half trace stays hidden.
* **Critique (Critic).**  `p = 3` must be excluded at `D = −3` (the curve is not
  ordinary/supersingular in the usual sense there and `3 ∣ p`), just as `p = 2`
  was excluded at `D = −4`; both exclusions are explicit hypotheses.
-/
import Mathlib
import Algebra.ECMParityCore
import Algebra.ECMParityMod4
import Novelty.CmEcmOrderShadow
import Novelty.CmEcmOrderTwists

open Finset

/-! ## 0. Free `ℤ/3` actions on finite sets -/

/-- **Orbit counting for an order-`3` symmetry.**  If `σ` cubes to the identity,
maps `s` into itself and has no fixed point in `s`, then `3 ∣ #s`. -/
theorem Finset.card_dvd_three_of_free_cycle {α : Type*} [DecidableEq α] (σ : α → α)
    (hσ : ∀ a, σ (σ (σ a)) = a) (s : Finset α)
    (hmem : ∀ a ∈ s, σ a ∈ s) (hfree : ∀ a ∈ s, σ a ≠ a) : 3 ∣ s.card := by
  have hinj : Function.Injective σ := by
    intro x y h
    have h2 : σ (σ (σ x)) = σ (σ (σ y)) := by rw [show σ x = σ y from h]
    rwa [hσ, hσ] at h2
  induction s using Finset.strongInduction with
  | _ s ih =>
    rcases s.eq_empty_or_nonempty with rfl | ⟨a, ha⟩
    · simp
    · have h1 : σ a ∈ s := hmem a ha
      have h2 : σ (σ a) ∈ s := hmem _ h1
      have hne1 : σ a ≠ a := hfree a ha
      have hne3 : σ (σ a) ≠ σ a := hfree _ h1
      have hne2 : σ (σ a) ≠ a := by
        intro h
        apply hne1
        have := congrArg σ h
        rw [hσ] at this
        exact this.symm
      set O : Finset α := {a, σ a, σ (σ a)} with hO
      have hOs : O ⊆ s := by
        intro b hb
        rw [hO] at hb
        simp only [mem_insert, mem_singleton] at hb
        rcases hb with rfl | rfl | rfl
        · exact ha
        · exact h1
        · exact h2
      have hOcard : O.card = 3 := by
        rw [hO, card_insert_of_notMem (by simp [Ne.symm hne1, Ne.symm hne2]),
          card_insert_of_notMem (by simp [Ne.symm hne3])]
        simp
      set t : Finset α := s \ O with ht
      have htsub : t ⊂ s := by
        rw [ht]
        refine ⟨sdiff_subset, ?_⟩
        intro hsub
        have : a ∈ s \ O := hsub ha
        rw [mem_sdiff] at this
        exact this.2 (by rw [hO]; simp)
      have htcard : t.card + 3 = s.card := by
        rw [ht, ← hOcard]
        exact card_sdiff_add_card_eq_card hOs
      have htmem : ∀ b ∈ t, σ b ∈ t := by
        intro b hb
        rw [ht, mem_sdiff] at hb ⊢
        obtain ⟨hbs, hbO⟩ := hb
        refine ⟨hmem b hbs, ?_⟩
        rw [hO] at hbO ⊢
        simp only [mem_insert, mem_singleton] at hbO ⊢
        push_neg at hbO ⊢
        obtain ⟨hb1, hb2, hb3⟩ := hbO
        refine ⟨?_, ?_, ?_⟩
        · intro h
          apply hb3
          have := congrArg (fun z => σ (σ z)) h
          simp only at this
          rwa [hσ] at this
        · exact fun h => hb1 (hinj h)
        · exact fun h => hb2 (hinj h)
      have htfree : ∀ b ∈ t, σ b ≠ b := by
        intro b hb
        rw [ht, mem_sdiff] at hb
        exact hfree b hb.1
      have := ih t htsub htmem htfree
      omega

namespace CmEcmOrder

open ECMParity

variable {p : ℕ} [Fact p.Prime]

/-! ## 1. The Eisenstein family `y² = x³ + B` -/

/-- The point count of the Eisenstein CM curve `y² = x³ + 1`. -/
def eisCard (p : ℕ) [Fact p.Prime] : ℕ := ECMParity.curveCard (0 : ZMod p) 1

/-- The trace of Frobenius of `y² = x³ + 1`. -/
def eisTrace (p : ℕ) [Fact p.Prime] : ℤ := (p : ℤ) + 1 - (eisCard p : ℤ)

theorem cubic_zero_eq (B x : ZMod p) : cubic (0 : ZMod p) B x = x ^ 3 + B := by
  rw [cubic]; ring

/-! ## 2. Inert primes `p ≡ 2 (mod 3)`: the cube map is a bijection -/

/-- For `p ≡ 2 (mod 3)` the cube map has the explicit inverse `x ↦ x^((2p-1)/3)`. -/
theorem cube_pow_inverse (hp3 : p % 3 = 2) (x : ZMod p) :
    (x ^ 3) ^ ((2 * p - 1) / 3) = x := by
  have hp' : p.Prime := Fact.out
  have hp2 : 2 ≤ p := hp'.two_le
  set k := (2 * p - 1) / 3 with hk
  have h3k : 3 * k = (p - 1) * 2 + 1 := by omega
  have hkpos : 0 < k := by omega
  rw [← pow_mul, h3k]
  by_cases hx : x = 0
  · subst hx
    rw [zero_pow (by omega)]
  · rw [pow_succ, pow_mul, ZMod.pow_card_sub_one_eq_one hx, one_pow, one_mul]

/-- The cube map is a bijection of `𝔽_p` when `p ≡ 2 (mod 3)`. -/
noncomputable def cubeEquiv (hp3 : p % 3 = 2) : ZMod p ≃ ZMod p :=
  Equiv.ofBijective (fun x : ZMod p => x ^ 3)
    (Finite.injective_iff_bijective.1 (by
      intro x y h
      have hx := cube_pow_inverse hp3 x
      have hy := cube_pow_inverse hp3 y
      rw [← hx, ← hy]
      simp only at h
      rw [h]))

/-- **Inert half of the `j = 0` family**: the character sum vanishes. -/
theorem charSum_zero_of_eisenstein_inert (hp : p ≠ 2) (hp3 : p % 3 = 2) (B : ZMod p) :
    charSum (0 : ZMod p) B = 0 := by
  have hchar : ringChar (ZMod p) ≠ 2 := ringChar_ne_two hp
  calc charSum (0 : ZMod p) B
      = ∑ x : ZMod p, quadraticChar (ZMod p) (x ^ 3 + B) := by
        rw [charSum]
        exact Finset.sum_congr rfl (fun x _ => by rw [cubic_zero_eq])
    _ = ∑ t : ZMod p, quadraticChar (ZMod p) (t + B) := by
        exact Equiv.sum_comp (cubeEquiv hp3) (fun t => quadraticChar (ZMod p) (t + B))
    _ = ∑ s : ZMod p, quadraticChar (ZMod p) s := by
        exact Equiv.sum_comp (Equiv.addRight B) (fun s => quadraticChar (ZMod p) s)
    _ = 0 := quadraticChar_sum_zero hchar

/-- **Supersingularity of the whole Eisenstein family.**  For `p ≡ 2 (mod 3)`
(and `p ≠ 2`) every curve `y² = x³ + B` has exactly `p + 1` points. -/
theorem supersingular_eisenstein_family (hp : p ≠ 2) (hp3 : p % 3 = 2) (B : ZMod p) :
    curveCard (0 : ZMod p) B = p + 1 := by
  have h := curveCard_charSum hp (0 : ZMod p) B
  rw [charSum_zero_of_eisenstein_inert hp hp3 B, add_zero] at h
  exact_mod_cast h

theorem eisCard_inert (hp : p ≠ 2) (hp3 : p % 3 = 2) : eisCard p = p + 1 :=
  supersingular_eisenstein_family hp hp3 1

/-! ## 3. Split primes `p ≡ 1 (mod 3)`: the automorphism `(x,y) ↦ (ζx, y)` -/

/-- A primitive cube root of unity exists in `𝔽_p` when `3 ∣ p - 1`. -/
theorem exists_primitive_cube_root (hp3 : p % 3 = 1) :
    ∃ z : ZMod p, z ^ 3 = 1 ∧ z ≠ 1 := by
  have hp' : p.Prime := Fact.out
  have hcard : Fintype.card (ZMod p)ˣ = p - 1 := ZMod.card_units_eq_totient p ▸
    (Nat.totient_prime hp')
  have hdvd : 3 ∣ Fintype.card (ZMod p)ˣ := by rw [hcard]; omega
  obtain ⟨g, hg⟩ := exists_prime_orderOf_dvd_card 3 hdvd
  refine ⟨(g : ZMod p), ?_, ?_⟩
  · have : g ^ 3 = 1 := by rw [← hg]; exact pow_orderOf_eq_one g
    calc ((g : ZMod p)) ^ 3 = ((g ^ 3 : (ZMod p)ˣ) : ZMod p) := by push_cast; ring
      _ = 1 := by rw [this]; simp
  · intro h
    have hg1 : g = 1 := Units.ext h
    rw [hg1, orderOf_one] at hg
    exact absurd hg.symm (by norm_num)

/-- **The `3`-divisibility on the split half.**  For `p ≡ 1 (mod 3)` (and `p ≠ 2`)
the Eisenstein curve `y² = x³ + 1` has order divisible by `3`: the cube-root
automorphism acts freely off the fibre `x = 0`, which contains exactly the two
points `(0, ±1)`, and the point at infinity is the third fixed point. -/
theorem three_dvd_eisCard (hp : p ≠ 2) (hp3 : p % 3 = 1) : 3 ∣ eisCard p := by
  classical
  obtain ⟨z, hz3, hz1⟩ := exists_primitive_cube_root hp3
  have hp2 : (2 : ZMod p) ≠ 0 := two_ne_zero_of_odd hp
  set S := affinePoints (0 : ZMod p) 1 with hS
  set S0 := S.filter (fun P : ZMod p × ZMod p => P.1 = 0) with hS0
  set S1 := S.filter (fun P : ZMod p × ZMod p => ¬ P.1 = 0) with hS1
  have hsplit : S0.card + S1.card = S.card := card_filter_add_card_filter_not _
  -- the fibre over `x = 0` consists of the two points `(0, ±1)`
  have hS0eq : S0 = {((0 : ZMod p), (1 : ZMod p)), ((0 : ZMod p), (-1 : ZMod p))} := by
    ext P
    obtain ⟨x, y⟩ := P
    simp only [hS0, hS, affinePoints, mem_filter, mem_univ, true_and, mem_insert,
      mem_singleton, Prod.mk.injEq]
    constructor
    · rintro ⟨hy, rfl⟩
      rw [cubic_zero_eq] at hy
      have hy1 : (y - 1) * (y + 1) = 0 := by
        have : y ^ 2 = 1 := by simpa using hy
        linear_combination this
      rcases mul_eq_zero.1 hy1 with h | h
      · exact Or.inl ⟨rfl, by linear_combination h⟩
      · exact Or.inr ⟨rfl, by linear_combination h⟩
    · rintro (⟨rfl, rfl⟩ | ⟨rfl, rfl⟩) <;>
        exact ⟨by rw [cubic_zero_eq]; ring, rfl⟩
  have hS0card : S0.card = 2 := by
    rw [hS0eq, card_insert_of_notMem (by
      simp only [mem_singleton, Prod.mk.injEq, not_and]
      intro _ h
      have : (2 : ZMod p) = 0 := by linear_combination h
      exact hp2 this), card_singleton]
  -- the cube-root automorphism acts freely on the rest
  set σ : ZMod p × ZMod p → ZMod p × ZMod p := fun P => (z * P.1, P.2) with hσdef
  have hσ3 : ∀ P, σ (σ (σ P)) = P := by
    intro P
    simp only [hσdef]
    have : z * (z * (z * P.1)) = P.1 := by
      calc z * (z * (z * P.1)) = z ^ 3 * P.1 := by ring
        _ = P.1 := by rw [hz3, one_mul]
    rw [this]
  have hmem : ∀ P ∈ S1, σ P ∈ S1 := by
    intro P hP
    simp only [hS1, hS, affinePoints, mem_filter, mem_univ, true_and] at hP ⊢
    obtain ⟨hcurve, hx0⟩ := hP
    constructor
    · simp only [hσdef, cubic_zero_eq] at hcurve ⊢
      calc P.2 ^ 2 = P.1 ^ 3 + 1 := hcurve
        _ = z ^ 3 * P.1 ^ 3 + 1 := by rw [hz3, one_mul]
        _ = (z * P.1) ^ 3 + 1 := by ring
    · simp only [hσdef]
      intro h
      rcases mul_eq_zero.1 h with h' | h'
      · rw [h', zero_pow (by norm_num)] at hz3
        exact zero_ne_one hz3
      · exact hx0 h'
  have hfree : ∀ P ∈ S1, σ P ≠ P := by
    intro P hP hcon
    simp only [hS1, hS, affinePoints, mem_filter, mem_univ, true_and] at hP
    obtain ⟨-, hx0⟩ := hP
    have hx : z * P.1 = P.1 := congrArg Prod.fst hcon
    have : (z - 1) * P.1 = 0 := by linear_combination hx
    rcases mul_eq_zero.1 this with h | h
    · exact hz1 (by linear_combination h)
    · exact hx0 h
  have h3 : 3 ∣ S1.card := Finset.card_dvd_three_of_free_cycle σ hσ3 S1 hmem hfree
  obtain ⟨m, hm⟩ := h3
  rw [eisCard, curveCard, ← hS]
  omega

/-- **Ordinarity of the split half at `j = 0`.**  For `p ≡ 1 (mod 3)` the count
is not `p + 1`, because `3 ∣ #E` while `p + 1 ≡ 2 (mod 3)`. -/
theorem eisCard_ne_split (hp : p ≠ 2) (hp3 : p % 3 = 1) : eisCard p ≠ p + 1 := by
  intro h
  obtain ⟨k, hk⟩ := three_dvd_eisCard hp hp3
  omega

/-- **The exact `j = 0` dichotomy**: for `p ∉ {2, 3}` the Eisenstein CM curve
`y² = x³ + 1` is supersingular exactly on the inert primes `p ≡ 2 (mod 3)`. -/
theorem eisTrace_eq_zero_iff (hp : p ≠ 2) (hp3 : p ≠ 3) : eisTrace p = 0 ↔ p % 3 = 2 := by
  have hp' : p.Prime := Fact.out
  have hmod : p % 3 = 1 ∨ p % 3 = 2 := by
    rcases Nat.eq_zero_or_pos (p % 3) with h | h
    · exact absurd (((Nat.prime_dvd_prime_iff_eq (by norm_num) hp').1
        (Nat.dvd_of_mod_eq_zero h)).symm) hp3
    · omega
  constructor
  · intro h
    rcases hmod with h3 | h3
    · exfalso
      apply eisCard_ne_split hp h3
      have : (eisCard p : ℤ) = (p : ℤ) + 1 := by rw [eisTrace] at h; linarith
      exact_mod_cast this
    · exact h3
  · intro h3
    rw [eisTrace, eisCard_inert hp h3]
    push_cast
    ring

/-! ## 4. The two CM dichotomies are independent -/

/-- The `D = −4` and `D = −3` dichotomies cut the primes along independent
congruences: `p = 5 ≡ 5 (mod 12)` is Gaussian-ordinary but
Eisenstein-supersingular, while `p = 7 ≡ 7 (mod 12)` is Gaussian-supersingular
but Eisenstein-ordinary.  Hence no single "CM shadow" governs all CM curves —
the visible congruence depends on the curve. -/
theorem cm_dichotomies_independent :
    cmTrace 5 ≠ 0 ∧ eisTrace 5 = 0 ∧ cmTrace 7 = 0 ∧ eisTrace 7 ≠ 0 := by
  refine ⟨cmTrace_ne_zero_split (by norm_num), ?_, cmTrace_inert (by norm_num), ?_⟩
  · norm_num [eisTrace, eisCard_inert (p := 5) (by norm_num) (by norm_num)]
  · intro h
    have h3 := (eisTrace_eq_zero_iff (by norm_num) (by norm_num)).1 h
    norm_num at h3

/-! ## 5. The Eisenstein null: even the *symmetric* channel is empty mod `15` -/

instance fact_prime_17 : Fact (Nat.Prime 17) := ⟨by norm_num⟩
instance fact_prime_29 : Fact (Nat.Prime 29) := ⟨by norm_num⟩
instance fact_prime_41 : Fact (Nat.Prime 41) := ⟨by norm_num⟩
instance fact_prime_47 : Fact (Nat.Prime 47) := ⟨by norm_num⟩
instance fact_prime_59 : Fact (Nat.Prime 59) := ⟨by norm_num⟩

theorem eisCard_11 : eisCard 11 = 12 := eisCard_inert (by norm_num) (by norm_num)
theorem eisCard_17 : eisCard 17 = 18 := eisCard_inert (by norm_num) (by norm_num)
theorem eisCard_23 : eisCard 23 = 24 := eisCard_inert (by norm_num) (by norm_num)
theorem eisCard_29 : eisCard 29 = 30 := eisCard_inert (by norm_num) (by norm_num)
theorem eisCard_47 : eisCard 47 = 48 := eisCard_inert (by norm_num) (by norm_num)
theorem eisCard_59 : eisCard 59 = 60 := eisCard_inert (by norm_num) (by norm_num)

/-- A semiprime built from two Eisenstein-inert primes prime to `5` lands in one of
the four residues `1, 4, 7, 13 (mod 15)`. -/
theorem eis_product_residues {a b : ℕ} (ha : a % 3 = 2) (hb : b % 3 = 2)
    (ha5 : a % 5 ≠ 0) (hb5 : b % 5 ≠ 0) :
    (a * b) % 15 = 1 ∨ (a * b) % 15 = 4 ∨ (a * b) % 15 = 7 ∨ (a * b) % 15 = 13 := by
  have hmul : (a * b) % 15 = ((a % 15) * (b % 15)) % 15 := Nat.mul_mod a b 15
  have ha15 : a % 15 = 2 ∨ a % 15 = 8 ∨ a % 15 = 11 ∨ a % 15 = 14 := by omega
  have hb15 : b % 15 = 2 ∨ b % 15 = 8 ∨ b % 15 = 11 ∨ b % 15 = 14 := by omega
  rcases ha15 with h | h | h | h <;> rcases hb15 with h' | h' | h' | h' <;>
    rw [h, h'] at hmul <;> omega

/-- **The Eisenstein null.**  For the `j = 0` curve at `ℓ = 5` even the symmetric
bit is invisible: each of the four possible residues `N mod 15` of a product of
two inert primes is realised both with and without the event
"`5` divides the order at some factor".  (Contrast
`CmEcmOrder.symmetric_shadow_live`, where the Gaussian curve at `ℓ = 3` *does*
leak the symmetric bit: there the inert residues mod `12` form a two-element
set, here the four inert residues mod `15` form a group coset closed under
multiplication by `−1`.) -/
theorem eis_symmetric_channel_dead :
    ((17 * 47) % 15 = (11 * 29) % 15 ∧ ¬ (5 ∣ eisCard 17 ∨ 5 ∣ eisCard 47) ∧
        (5 ∣ eisCard 11 ∨ 5 ∣ eisCard 29)) ∧
      ((17 * 23) % 15 = (29 * 59) % 15 ∧ ¬ (5 ∣ eisCard 17 ∨ 5 ∣ eisCard 23) ∧
        (5 ∣ eisCard 29 ∨ 5 ∣ eisCard 59)) ∧
      ((17 * 11) % 15 = (23 * 29) % 15 ∧ ¬ (5 ∣ eisCard 17 ∨ 5 ∣ eisCard 11) ∧
        (5 ∣ eisCard 23 ∨ 5 ∣ eisCard 29)) ∧
      ((23 * 11) % 15 = (17 * 29) % 15 ∧ ¬ (5 ∣ eisCard 23 ∨ 5 ∣ eisCard 11) ∧
        (5 ∣ eisCard 17 ∨ 5 ∣ eisCard 29)) := by
  refine ⟨⟨by norm_num, ?_, ?_⟩, ⟨by norm_num, ?_, ?_⟩, ⟨by norm_num, ?_, ?_⟩,
    ⟨by norm_num, ?_, ?_⟩⟩ <;>
    simp only [eisCard_11, eisCard_17, eisCard_23, eisCard_29, eisCard_47, eisCard_59] <;> omega

/-- **The which-factor bit is invisible for the Eisenstein family too.**
`319 = 11 · 29` and `1189 = 29 · 41` agree mod `15`, both satisfy the symmetric
event, and their least-factor bits disagree. -/
theorem eis_which_factor_bit_invisible :
    (11 * 29) % 15 = (29 * 41) % 15 ∧
      (5 ∣ eisCard 11 ∨ 5 ∣ eisCard 29) ∧ (5 ∣ eisCard 29 ∨ 5 ∣ eisCard 41) ∧
      ¬ (5 ∣ eisCard 11) ∧ (5 ∣ eisCard 29) := by
  have h41 : eisCard 41 = 42 := eisCard_inert (by norm_num) (by norm_num)
  refine ⟨by norm_num, ?_, ?_, ?_, ?_⟩ <;>
    simp only [eisCard_11, eisCard_29, h41] <;> omega

end CmEcmOrder