/-
# CM-ECM-ORDER, cycle 2: character sums, the whole quartic-twist family, and the
quadratic-twist involution

Cycle 1 (`Novelty.CmEcmOrderShadow`) proved that the Gaussian CM curve
`y² = x³ + x` is supersingular exactly on the inert primes `p ≡ 3 (mod 4)`, by
the `x ↦ -x` sign involution applied to the `2`-point fibres.  This file redoes
the count with the *quadratic character sum*

  `charSum A B = ∑_{x ∈ 𝔽_p} χ(x³ + A x + B)`,  `#E = p + 1 + charSum A B`,

which upgrades the cycle-1 statement in two independent directions:

* **the whole family** `y² = x³ + A x` (every `A`, i.e. every quartic twist of
  the CM curve *and* the degenerate curve `A = 0`) is supersingular at every
  inert prime — the sign involution never used `A = 1`;
* **the quadratic-twist involution**: for a non-residue `u` the twist
  `(A, B) ↦ (u²A, u³B)` negates the trace, so the two orders sum to `2p + 2`.
  Together with the cycle-1 mod-4 law this pins the split-half order of the CM
  curve and its twist to complementary residues mod `8` in examples.

## Main results

* `CmEcmOrder.affine_card_charSum` / `CmEcmOrder.curveCard_charSum` — the exact
  character-sum formula for `ECMParity.curveCard`.
* `CmEcmOrder.charSum_zero_of_inert` — `χ(-1) = -1` kills every odd cubic sum.
* `CmEcmOrder.supersingular_inert_family` — **all** curves `y² = x³ + A x` have
  exactly `p + 1` points when `p ≡ 3 (mod 4)`; in particular supersingularity of
  the CM curve is a statement about the whole quartic twist family, not about
  the model `A = 1`.
* `CmEcmOrder.charSum_twist`, `CmEcmOrder.curveCard_twist_sum` — the quadratic
  twist relation `#E + #E^u = 2p + 2` for a non-residue `u`.
* `CmEcmOrder.cm_twist_sum`, `CmEcmOrder.cm_twist_five` — the CM specialisation
  and its explicit check at `p = 5` (`4 + 8 = 12`).
* `CmEcmOrder.cmTrace_split_mod_four` — on the split half `a_p ≡ 2 (mod 4)`,
  i.e. the Gauss parameter `a` in `a_p = ±2a`, `p = a² + b²`, is **odd** —
  obtained here without Jacobsthal sums, purely from `4 ∣ #E`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  If the cycle-1 inert count really comes from
  the odd symmetry `f(-x) = -f(x)` and nothing else, then (i) it must hold for
  every `A`, and (ii) the same reindexing trick with `x ↦ ux` must produce the
  classical twist law.  Both are testable by re-deriving the count as a
  character sum.
* **Experiment (Experimenter).**  Both survive.  `charSum_zero_of_inert` is two
  lines once `χ(-1) = -1`; `charSum_twist` needs only `χ(u³) = χ(u)`, which is
  `quadraticChar_sq_one`.  The degenerate member `A = 0` (the singular curve
  `y² = x³`) is included for free: the count `p + 1` holds there too, a useful
  sanity check that the argument is really about the involution and not about
  smoothness.
* **Analysis (Analyst).**  The twist law explains the empirical "`4 ∣ #E`
  universally" from a different angle: at a split prime, `#E + #E^u = 2p + 2 ≡ 4
  (mod 8)` and both summands are divisible by `4`, so exactly one of the two
  quartic-twist orbits is `≡ 0 (mod 8)`.  At `p = 5`: `4 + 8 = 12`.
* **Critique (Critic).**  Nothing here upgrades the *factoring* verdict.  The
  twist law is a linear relation between two orders and is itself a congruence
  statement in `p`; the trace, which is where all the arithmetic content sits,
  remains invisible from `N mod ℓ` — see `which_factor_bit_invisible` in cycle 1.
-/
import Mathlib
import Algebra.ECMParityCore
import Algebra.ECMParityMod4
import Novelty.CmEcmOrderShadow

namespace CmEcmOrder

open Finset ECMParity

variable {p : ℕ} [Fact p.Prime]

/-! ## 1. The character-sum formula -/

/-- The quadratic character sum of the cubic: `∑_x χ(x³ + A x + B) = -a_p`. -/
def charSum (A B : ZMod p) : ℤ := ∑ x : ZMod p, quadraticChar (ZMod p) (cubic A B x)

theorem ringChar_ne_two (hp : p ≠ 2) : ringChar (ZMod p) ≠ 2 := by
  rw [ZMod.ringChar_zmod_n]
  exact_mod_cast hp

/-- Exact affine count: `#{(x,y) : y² = x³ + Ax + B} = p + ∑_x χ(x³ + Ax + B)`. -/
theorem affine_card_charSum (hp : p ≠ 2) (A B : ZMod p) :
    ((affinePoints A B).card : ℤ) = (p : ℤ) + charSum A B := by
  classical
  have hchar : ringChar (ZMod p) ≠ 2 := ringChar_ne_two hp
  have h1 : (affinePoints A B).card
      = ∑ x : ZMod p, (univ.filter (fun y : ZMod p => y ^ 2 = cubic A B x)).card := by
    rw [affinePoints, card_filter, Fintype.sum_prod_type]
    exact Finset.sum_congr rfl (fun x _ => by rw [card_filter])
  have h2 : ∀ x : ZMod p, ((univ.filter (fun y : ZMod p => y ^ 2 = cubic A B x)).card : ℤ)
      = quadraticChar (ZMod p) (cubic A B x) + 1 := by
    intro x
    have h := quadraticChar_card_sqrts hchar (cubic A B x)
    simpa [Set.toFinset_setOf] using h
  calc ((affinePoints A B).card : ℤ)
      = ∑ x : ZMod p, ((univ.filter (fun y : ZMod p => y ^ 2 = cubic A B x)).card : ℤ) := by
        rw [h1]; push_cast; ring
    _ = ∑ x : ZMod p, (quadraticChar (ZMod p) (cubic A B x) + 1) :=
        Finset.sum_congr rfl (fun x _ => h2 x)
    _ = charSum A B + (Fintype.card (ZMod p) : ℤ) := by
        rw [Finset.sum_add_distrib, charSum]
        simp [Finset.card_univ]
    _ = (p : ℤ) + charSum A B := by rw [ZMod.card]; ring

/-- Projective version: `#E(𝔽_p) = p + 1 + ∑_x χ(x³ + Ax + B)`. -/
theorem curveCard_charSum (hp : p ≠ 2) (A B : ZMod p) :
    ((curveCard A B : ℕ) : ℤ) = (p : ℤ) + 1 + charSum A B := by
  rw [curveCard]
  push_cast
  rw [affine_card_charSum hp]
  ring

/-! ## 2. Inert primes: the sign involution kills the whole family -/

/-- For `p ≡ 3 (mod 4)` the character sum of *any* odd cubic `x³ + A x` vanishes. -/
theorem charSum_zero_of_inert (hp3 : p % 4 = 3) (A : ZMod p) : charSum A (0 : ZMod p) = 0 := by
  have hneg : quadraticChar (ZMod p) (-1) = -1 :=
    quadraticChar_neg_one_iff_not_isSquare.2 (not_isSquare_neg_one hp3)
  have hodd : ∀ x : ZMod p, quadraticChar (ZMod p) (cubic A 0 (-x))
      = - quadraticChar (ZMod p) (cubic A 0 x) := by
    intro x
    have hcube : cubic A (0 : ZMod p) (-x) = (-1) * cubic A 0 x := by rw [cubic, cubic]; ring
    rw [hcube, map_mul, hneg, neg_one_mul]
  have hflip : charSum A (0 : ZMod p) = - charSum A 0 := by
    calc charSum A (0 : ZMod p)
        = ∑ x : ZMod p, quadraticChar (ZMod p) (cubic A 0 (-x)) := by
          rw [charSum]
          exact (Equiv.sum_comp (Equiv.neg (ZMod p))
            (fun x => quadraticChar (ZMod p) (cubic A 0 x))).symm
      _ = ∑ x : ZMod p, - quadraticChar (ZMod p) (cubic A 0 x) :=
          Finset.sum_congr rfl (fun x _ => hodd x)
      _ = - charSum A 0 := by rw [charSum, Finset.sum_neg_distrib]
  linarith

/-- **Supersingularity of the entire quartic-twist family.**  For every inert
prime `p ≡ 3 (mod 4)` and every `A`, the curve `y² = x³ + A x` has exactly
`p + 1` points.  (Cycle 1's `cmCard_inert` is the case `A = 1`.) -/
theorem supersingular_inert_family (hp3 : p % 4 = 3) (A : ZMod p) : curveCard A 0 = p + 1 := by
  have hp2 : p ≠ 2 := by omega
  have h := curveCard_charSum hp2 A (0 : ZMod p)
  rw [charSum_zero_of_inert hp3 A, add_zero] at h
  exact_mod_cast h

/-- Consistency with cycle 1: the CM curve is the member `A = 1`. -/
theorem cmCard_eq_family : cmCard p = curveCard (1 : ZMod p) 0 := rfl

/-! ## 3. The quadratic twist involution -/

/-- `χ(u³) = χ(u)` for `u ≠ 0`. -/
theorem quadraticChar_cube {u : ZMod p} (hu : u ≠ 0) :
    quadraticChar (ZMod p) (u ^ 3) = quadraticChar (ZMod p) u := by
  have hsq : quadraticChar (ZMod p) u ^ 2 = 1 := quadraticChar_sq_one hu
  calc quadraticChar (ZMod p) (u ^ 3) = quadraticChar (ZMod p) u ^ 3 := by rw [map_pow]
    _ = quadraticChar (ZMod p) u * quadraticChar (ZMod p) u ^ 2 := by ring
    _ = quadraticChar (ZMod p) u := by rw [hsq, mul_one]

/-- **The twist law for character sums**: `S(u²A, u³B) = χ(u) · S(A, B)`. -/
theorem charSum_twist {u : ZMod p} (hu : u ≠ 0) (A B : ZMod p) :
    charSum (u ^ 2 * A) (u ^ 3 * B) = quadraticChar (ZMod p) u * charSum A B := by
  have hstep : ∀ x : ZMod p,
      quadraticChar (ZMod p) (cubic (u ^ 2 * A) (u ^ 3 * B) (u * x))
        = quadraticChar (ZMod p) u * quadraticChar (ZMod p) (cubic A B x) := by
    intro x
    have hval : cubic (u ^ 2 * A) (u ^ 3 * B) (u * x) = u ^ 3 * cubic A B x := by
      rw [cubic, cubic]; ring
    rw [hval, map_mul, quadraticChar_cube hu]
  calc charSum (u ^ 2 * A) (u ^ 3 * B)
      = ∑ x : ZMod p, quadraticChar (ZMod p) (cubic (u ^ 2 * A) (u ^ 3 * B) (u * x)) := by
        rw [charSum]
        exact (Equiv.sum_comp (Equiv.mulLeft₀ u hu)
          (fun x => quadraticChar (ZMod p) (cubic (u ^ 2 * A) (u ^ 3 * B) x))).symm
    _ = ∑ x : ZMod p, quadraticChar (ZMod p) u * quadraticChar (ZMod p) (cubic A B x) :=
        Finset.sum_congr rfl (fun x _ => hstep x)
    _ = quadraticChar (ZMod p) u * charSum A B := by rw [charSum, Finset.mul_sum]

/-- **The quadratic twist relation.**  For a non-residue `u`, the curve and its
quadratic twist have complementary orders: `#E + #E^u = 2p + 2`. -/
theorem curveCard_twist_sum (hp : p ≠ 2) {u : ZMod p} (hu : ¬ IsSquare u) (A B : ZMod p) :
    curveCard A B + curveCard (u ^ 2 * A) (u ^ 3 * B) = 2 * p + 2 := by
  have hu0 : u ≠ 0 := by
    rintro rfl
    exact hu ⟨0, by ring⟩
  have hchi : quadraticChar (ZMod p) u = -1 := quadraticChar_neg_one_iff_not_isSquare.2 hu
  have h1 := curveCard_charSum hp A B
  have h2 := curveCard_charSum hp (u ^ 2 * A) (u ^ 3 * B)
  rw [charSum_twist hu0 A B, hchi] at h2
  have : ((curveCard A B + curveCard (u ^ 2 * A) (u ^ 3 * B) : ℕ) : ℤ) = ((2 * p + 2 : ℕ) : ℤ) := by
    push_cast
    push_cast at h1 h2
    linarith
  exact_mod_cast this

/-- The CM specialisation: the Gaussian curve and its quadratic twist
`y² = x³ + u²x` have orders summing to `2p + 2`. -/
theorem cm_twist_sum (hp : p ≠ 2) {u : ZMod p} (hu : ¬ IsSquare u) :
    cmCard p + curveCard (u ^ 2 * 1 : ZMod p) 0 = 2 * p + 2 := by
  have h := curveCard_twist_sum hp hu (1 : ZMod p) 0
  rwa [mul_zero] at h

/-- Explicit check at the split prime `p = 5`: `#E = 4`, the twist by the
non-residue `u = 2` has `8` points, and `4 + 8 = 12 = 2·5 + 2`. -/
theorem cm_twist_five :
    cmCard 5 = 4 ∧ curveCard (4 : ZMod 5) 0 = 8 ∧ cmCard 5 + curveCard (4 : ZMod 5) 0 = 2 * 5 + 2 :=
  ⟨by decide, by decide, by decide⟩

/-! ## 4. The split half: the Gauss parameter is odd -/

/-- On the split half the trace satisfies `a_p ≡ 2 (mod 4)`.  Since `a_p = ±2a`
with `p = a² + b²` (Gauss 1801), this says that the parameter `a` is **odd** —
here derived from the mod-`4` point count alone, with no Jacobsthal sums. -/
theorem cmTrace_split_mod_four (hp1 : p % 4 = 1) : cmTrace p % 4 = 2 := by
  obtain ⟨k, hk⟩ := four_dvd_cmCard_split hp1
  have hp4 : (p : ℤ) % 4 = 1 := by
    have : ((p % 4 : ℕ) : ℤ) = ((1 : ℕ) : ℤ) := by rw [hp1]
    push_cast at this
    omega
  have hc : (cmCard p : ℤ) = 4 * k := by exact_mod_cast hk
  rw [cmTrace, hc]
  omega

end CmEcmOrder