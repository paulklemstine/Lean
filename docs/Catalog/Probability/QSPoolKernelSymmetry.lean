import Mathlib
import Shared.QSRelationPoolRandom

/-!
# Why the two factors of two cancel: they are the same `2`

`Catalog.Shared.QSRelationPoolRandom` proves the numerical cancellation that
explains the measured random-equivalence of the quadratic-sieve relation pool:
only `(p-1)/2` residues `N` admit a relation modulo `p`, but each admissible one
is hit by `2` residues `x` per period, so the expected number of hits per period
is exactly `1`, as for a random integer sequence.

This file identifies the *structural* reason.  Both factors of `2` are the order
of the kernel of the squaring endomorphism of `(ZMod p)ˣ`, i.e. the group
`{1, -1}`:

* the fibre of the squaring map is a coset of `{±1}`, which is why an admissible
  prime hits twice (`sqrt_set_eq_pair`, `rootCount_eq_card_ker`);
* the image of the squaring map has index `|{±1}| = 2`, which is why only half
  the residues are admissible (`card_ker_mul_card_admissible`).

So the "quadratic-character constraint" and the "doubled hit density" are two
faces of the single `Z/2` symmetry `x ↦ -x` of the sieve polynomial `x^2 - N`,
and their product is forced to be `1` by the orbit–stabiliser identity.  No
amount of extra scale can create a discrepancy: the cancellation is an identity,
not an asymptotic.

Main results:

* `neg_ne_self_of_ne_zero` — the `Z/2` action `x ↦ -x` on roots is free.
* `sqrt_set_eq_pair` — a fibre of squaring is exactly `{x, -x}`.
* `card_ker_sq` — the kernel of `u ↦ u^2` on `(ZMod p)ˣ` has order `2`.
* `rootCount_eq_card_ker` — the local hit count of an admissible modulus is the
  kernel order.
* `card_ker_mul_card_admissible` — kernel order times number of admissible
  residues is `|(ZMod p)ˣ|`: the exact orbit–stabiliser cancellation.
* `pool_expected_hits_eq_random` — final form: the pool's expected hit count per
  period equals the random model's, exactly, at every prime.
-/

namespace QSPoolKernel

open Finset QSRelationPool

variable {p : ℕ} [Fact p.Prime]

/-- For odd `p`, negation acts freely on the nonzero elements of `ZMod p`. -/
theorem neg_ne_self_of_ne_zero (hp : p ≠ 2) {x : ZMod p} (hx : x ≠ 0) : -x ≠ x := by
  intro h
  have h2 : (2 : ZMod p) * x = 0 := by
    have : x + x = 0 := by
      calc x + x = -x + x := by rw [h]
        _ = 0 := by ring
    linear_combination this
  rcases mul_eq_zero.1 h2 with h3 | h3
  · have hdvd : (p : ℕ) ∣ 2 := (ZMod.natCast_eq_zero_iff 2 p).1 (by exact_mod_cast h3)
    have hple : p ≤ 2 := Nat.le_of_dvd (by norm_num) hdvd
    have := (Fact.out (p := p.Prime)).two_le
    omega
  · exact hx h3

/-- **The fibre of squaring is a `{±1}`-coset.**  If `x^2 = a ≠ 0` then the set of
square roots of `a` is exactly `{x, -x}`, a free orbit of the `Z/2` symmetry of
the sieve polynomial. -/
theorem sqrt_set_eq_pair {a x : ZMod p} (hx : x ^ 2 = a) :
    {y : ZMod p | y ^ 2 = a} = {x, -x} := by
  ext y
  simp only [Set.mem_setOf_eq, Set.mem_insert_iff, Set.mem_singleton_iff]
  constructor
  · intro hy
    have h : (y - x) * (y + x) = 0 := by
      have : y ^ 2 - x ^ 2 = 0 := by rw [hy, hx]; ring
      linear_combination this
    rcases mul_eq_zero.1 h with h1 | h1
    · left; linear_combination h1
    · right; linear_combination h1
  · rintro (rfl | rfl)
    · exact hx
    · rw [← hx]; ring

/-- The squaring endomorphism of the unit group. -/
noncomputable def sqUnits (p : ℕ) [Fact p.Prime] : (ZMod p)ˣ →* (ZMod p)ˣ :=
  powMonoidHom 2

theorem mem_ker_sqUnits_iff {u : (ZMod p)ˣ} :
    u ∈ MonoidHom.ker (sqUnits p) ↔ u = 1 ∨ u = -1 := by
  constructor
  · intro hu
    have hu' : (u : ZMod p) ^ 2 = 1 := by
      have := MonoidHom.mem_ker.1 hu
      simpa [sqUnits, powMonoidHom] using congrArg (fun v : (ZMod p)ˣ => (v : ZMod p)) this
    have h : ((u : ZMod p) - 1) * ((u : ZMod p) + 1) = 0 := by linear_combination hu'
    rcases mul_eq_zero.1 h with h1 | h1
    · left
      apply Units.ext
      have : (u : ZMod p) = 1 := by linear_combination h1
      simpa using this
    · right
      apply Units.ext
      have : (u : ZMod p) = -1 := by linear_combination h1
      simpa using this
  · rintro (rfl | rfl) <;> simp [MonoidHom.mem_ker, sqUnits, powMonoidHom]

/-- **The kernel of squaring has order `2`** for odd `p`: it is `{1, -1}`. -/
theorem card_ker_sqUnits (hp : p ≠ 2) :
    Nat.card (MonoidHom.ker (sqUnits p)) = 2 := by
  have hcoe : ((MonoidHom.ker (sqUnits p) : Subgroup (ZMod p)ˣ) : Set (ZMod p)ˣ)
      = {1, -1} := by
    ext u
    simpa using mem_ker_sqUnits_iff (p := p) (u := u)
  have hp2 : 2 < p := lt_of_le_of_ne (Fact.out (p := p.Prime)).two_le (Ne.symm hp)
  haveI : Fact (2 < p) := ⟨hp2⟩
  have hne : (1 : (ZMod p)ˣ) ≠ -1 := by
    intro h
    have h1 : (1 : ZMod p) = -1 := by
      simpa using congrArg (fun v : (ZMod p)ˣ => (v : ZMod p)) h
    exact (ZMod.neg_one_ne_one (n := p)) h1.symm
  calc Nat.card (MonoidHom.ker (sqUnits p))
      = Nat.card ({1, -1} : Set (ZMod p)ˣ) := Nat.card_congr (Equiv.setCongr hcoe)
    _ = 2 := by rw [Nat.card_coe_set_eq, Set.ncard_pair hne]

/-- **The local hit count of an admissible modulus is the kernel order.** -/
theorem rootCount_eq_card_ker (hp : p ≠ 2) {a : ZMod p} (ha : a ≠ 0)
    (hsq : IsSquare a) :
    rootCount p a = Nat.card (MonoidHom.ker (sqUnits p)) := by
  rw [card_ker_sqUnits hp, root_count_of_isSquare hp ha hsq]

/-- **Orbit–stabiliser cancellation.**  The order of the kernel `{±1}` times the
number of admissible residues is the order of the whole unit group: the factor
`2` lost by the quadratic-character constraint is *the same* `2` gained by the
doubled hit density. -/
theorem card_ker_mul_card_admissible (hp : p ≠ 2) :
    Nat.card (MonoidHom.ker (sqUnits p)) * (admissible p).card
      = Fintype.card (ZMod p)ˣ := by
  have hcards : Fintype.card (ZMod p)ˣ = p - 1 := by
    rw [ZMod.card_units_eq_totient, Nat.totient_prime (Fact.out (p := p.Prime))]
  rw [card_ker_sqUnits hp, hcards]
  exact relation_pool_random_equivalent hp

/-- **Final form.**  Averaged over the residue of `N`, the number of `x` per
period with `p ∣ x^2 - N` is exactly `1`, the value for a random integer
sequence: the quadratic-sieve relation pool is random-equivalent at every prime,
exactly, with no error term to shrink with scale. -/
theorem pool_expected_hits_eq_random (hp : p ≠ 2) :
    ∑ a : ZMod p, rootCount p a = Fintype.card (ZMod p) := by
  rw [ZMod.card]
  exact expected_hits_eq_one hp

end QSPoolKernel