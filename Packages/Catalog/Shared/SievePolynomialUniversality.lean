import Mathlib
import Catalog.Shared.QSRelationPoolRandom

/-!
# Universality of on-average random-equivalence for sieve polynomials

The exact cancellation of `Catalog.Shared.QSRelationPoolRandom` invites the
question: is the quadratic sieve special?  It is not.  This file isolates the
combinatorial skeleton of the phenomenon and shows it is *universal*: for **any**
sieve map `f` on residues (any polynomial, any degree, any modulus), the number
of `x` per period hitting a given target residue averages to exactly
`|domain| / |targets|`, the random-model value.  Averaged over the target, no
sieve polynomial can be better or worse than random.

What the individual polynomial controls is only the *distribution* of that hit
count across targets, and the file characterises exactly when the pool is
random-equivalent target-by-target rather than merely on average:

* `sum_fiber_card` — the averaging identity (universality).
* `pointwise_uniform_iff_bijective` — pointwise random-equivalence holds iff the
  sieve map is a bijection of residues.
* `sq_not_pointwise_uniform` — for `x ↦ x^2` mod an odd prime it fails: the
  hit count is the `2`/`0` dichotomy, never the constant `1`.
* `qs_average_hits_eq_random` — but on average over the modulus residue the
  quadratic sieve hits exactly once per period, like a random sequence.

The moral for the experiment: any measured deviation of the `x^2 - N` pool from
the random control must come from the *interaction across primes* for one fixed
`N`, never from the one-prime statistics, which are pinned by these identities.
-/

namespace SieveUniversality

open Finset

variable {α β : Type*} [Fintype α] [Fintype β] [DecidableEq β]

/-- The number of `x` in one period which the sieve map `f` sends to `b`. -/
def hitCount (f : α → β) (b : β) : ℕ := (Finset.univ.filter (fun x => f x = b)).card

/-- **Universality of the average hit count.**  Whatever the sieve map, the hit
counts sum to the size of one period; the mean hit count per target is exactly
`|α| / |β|`, the random-model prediction. -/
theorem sum_fiber_card (f : α → β) :
    ∑ b : β, hitCount f b = Fintype.card α := by
  have h := Finset.card_eq_sum_card_fiberwise
      (f := f) (s := (Finset.univ : Finset α)) (t := (Finset.univ : Finset β))
      (fun x _ => Finset.mem_univ (f x))
  simp only [hitCount, Fintype.card]
  exact h.symm

omit [Fintype β] in
/-- **Pointwise random-equivalence is exactly bijectivity.**  A sieve map hits
every target exactly once per period iff it is a bijection of residues; any
non-bijective sieve map (such as squaring) necessarily has a nontrivial
`0`/`≥2` dichotomy, which is what a quadratic-character constraint looks like. -/
theorem pointwise_uniform_iff_bijective (f : α → β) :
    (∀ b, hitCount f b = 1) ↔ Function.Bijective f := by
  classical
  constructor
  · intro h
    constructor
    · intro x y hxy
      have hcard : (Finset.univ.filter (fun z => f z = f x)).card = 1 := h (f x)
      obtain ⟨z, hz⟩ := Finset.card_eq_one.1 hcard
      have hx : x ∈ Finset.univ.filter (fun z => f z = f x) := by simp
      have hy : y ∈ Finset.univ.filter (fun z => f z = f x) := by simp [hxy]
      rw [hz] at hx hy
      simp only [Finset.mem_singleton] at hx hy
      rw [hx, hy]
    · intro b
      have hcard : (Finset.univ.filter (fun z => f z = b)).card = 1 := h b
      obtain ⟨z, hz⟩ := Finset.card_eq_one.1 hcard
      have : z ∈ Finset.univ.filter (fun w => f w = b) := by rw [hz]; simp
      exact ⟨z, (Finset.mem_filter.1 this).2⟩
  · rintro ⟨hinj, hsurj⟩ b
    obtain ⟨a, rfl⟩ := hsurj b
    have : Finset.univ.filter (fun z => f z = f a) = {a} := by
      ext z
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
      exact ⟨fun h => hinj h, fun h => by rw [h]⟩
    rw [hitCount, this, Finset.card_singleton]

/-! ## The quadratic sieve instance -/

variable {p : ℕ} [Fact p.Prime]

theorem hitCount_eq_rootCount (a : ZMod p) :
    hitCount (fun x : ZMod p => x ^ 2) a = QSRelationPool.rootCount p a := by
  classical
  simp [hitCount, QSRelationPool.rootCount, Set.toFinset_setOf]

/-- **The quadratic sieve is not pointwise random.**  Squaring mod an odd prime
is not a bijection, so the per-modulus hit count is never identically `1`: half
the residues are missed and the other half are hit twice. -/
theorem sq_not_pointwise_uniform (hp : p ≠ 2) :
    ¬ (∀ a : ZMod p, hitCount (fun x : ZMod p => x ^ 2) a = 1) := by
  intro h
  have hbij : Function.Bijective (fun x : ZMod p => x ^ 2) :=
    (pointwise_uniform_iff_bijective _).1 h
  have hp2 : 2 < p := lt_of_le_of_ne (Fact.out (p := p.Prime)).two_le (Ne.symm hp)
  haveI : Fact (2 < p) := ⟨hp2⟩
  have hne : (-1 : ZMod p) ≠ 1 := ZMod.neg_one_ne_one
  exact hne (hbij.1 (by ring))

/-- **But it is random on average.**  Averaged over the residue of `N`, the
quadratic-sieve map hits exactly once per period — the random-model value. -/
theorem qs_average_hits_eq_random (hp : p ≠ 2) :
    ∑ a : ZMod p, hitCount (fun x : ZMod p => x ^ 2) a = Fintype.card (ZMod p) := by
  rw [Finset.sum_congr rfl (fun a _ => hitCount_eq_rootCount a), ZMod.card]
  exact QSRelationPool.expected_hits_eq_one hp

end SieveUniversality