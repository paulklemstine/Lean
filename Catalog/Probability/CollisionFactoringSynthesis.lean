import Mathlib
import Shared.ThreeSumFactorReveal
import Shared.BirthdayBoundHierarchy

/-!
# End-to-end collision factoring, and the two barriers it must pass

This file glues the two halves of the story together:

* the *reveal* lemma of `Catalog.Shared.ThreeSumFactorReveal`
  (a congruence mod `p` below `N` produces `p` by one gcd), and
* the *birthday bound* of `Catalog.Shared.BirthdayBoundHierarchy`
  (a collision is guaranteed exactly when the search space exceeds `p`),

and it isolates a second, independent obstruction that the naive "cost = number
of tuples" accounting hides.

**Barrier 1 (counting).**  A guaranteed `r`-SUM collision needs more than `p`
tuples, hence more than `√N` work at any arity `r`.

**Barrier 2 (amplitude).**  A collision is *useful* only if the two colliding
tuples have different integer sums.  All `r`-tuples drawn from `A ⊆ [1, M]` have
sums in `[r, rM]`, so at most `rM - r + 1` distinct sums exist.  If `r * M < p`
then *every* modular collision is trivial (`all_collisions_trivial_of_small`)
and the scheme cannot factor at all, no matter how many tuples are inspected.
Thus the entries themselves must be of size `≥ p / r`, and the useful search
space is capped by `r * M`, not by `|A| ^ r`.

The master theorem `rsum_factoring_success` shows that once both barriers are
passed the scheme provably outputs the factor `p`.

Main results:

* `useful_collision_of_sumset_card_lt` — a sumset larger than `p` contains a
  nontrivial modular collision.
* `rsum_factoring_success` — end-to-end: it outputs `gcd = p`.
* `all_collisions_trivial_of_small` — the amplitude barrier.
* `sumset_card_le_amplitude` — the useful search space is at most `r * M`.
* `rsum_needs_both_barriers` — a successful scheme must satisfy `p ≤ r * M`
  *and* inspect more than `√N` tuples.
-/

namespace CollisionFactoring

open Finset ThreeSumReveal BirthdayHierarchy

/-! ## Nontrivial collisions come from a large *sumset* -/

/-- **Useful collision.**  If the set `T` of achieved sums has more than `p`
elements, two of them are distinct integers congruent modulo `p`. -/
theorem useful_collision_of_sumset_card_lt {p : ℕ} {T : Finset ℕ} (hp : 0 < p)
    (hT : p < T.card) : ∃ s ∈ T, ∃ t ∈ T, t < s ∧ p ∣ s - t := by
  obtain ⟨x, hx, y, hy, hne, hxy⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to (t := Finset.range p)
      (by simpa using hT) (f := fun n => n % p)
      (fun n _ => Finset.mem_range.mpr (Nat.mod_lt _ hp))
  rcases lt_or_gt_of_ne hne with h | h
  · exact ⟨y, hy, x, hx, h, (Nat.modEq_iff_dvd' h.le).mp hxy⟩
  · exact ⟨x, hx, y, hy, h, (Nat.modEq_iff_dvd' h.le).mp hxy.symm⟩

/-! ## The set of sums of `r`-tuples -/

/-- All integer sums achieved by `r`-tuples over `A`. -/
noncomputable def sumSet (r : ℕ) (A : Finset ℕ) : Finset ℕ :=
  (tupleSpace r A).image (fun u => ∑ i, u i)

theorem mem_sumSet_le {r M : ℕ} {A : Finset ℕ} (hA : ∀ a ∈ A, a ≤ M)
    {s : ℕ} (hs : s ∈ sumSet r A) : s ≤ r * M := by
  simp only [sumSet, Finset.mem_image] at hs
  obtain ⟨u, hu, rfl⟩ := hs
  have hu' : ∀ i : Fin r, u i ∈ A := by
    simpa [tupleSpace, Fintype.mem_piFinset] using hu
  calc ∑ i, u i ≤ ∑ _i : Fin r, M := Finset.sum_le_sum (fun i _ => hA _ (hu' i))
    _ = r * M := by simp

/-- **Amplitude barrier.**  The number of distinct sums produced by `r`-tuples
over `A ⊆ [1, M]` is at most `r * M`, no matter how big `|A| ^ r` is. -/
theorem sumset_card_le_amplitude {r M : ℕ} {A : Finset ℕ} (hA : ∀ a ∈ A, a ≤ M) :
    (sumSet r A).card ≤ r * M + 1 := by
  have hsub : sumSet r A ⊆ Finset.range (r * M + 1) := by
    intro s hs
    exact Finset.mem_range.mpr (Nat.lt_succ_of_le (mem_sumSet_le hA hs))
  simpa using Finset.card_le_card hsub

/-- **Every collision is trivial when the entries are small.**  If `r * M < p`
then any two `r`-tuples over `A ⊆ [1, M]` with congruent sums modulo `p` have
*equal* integer sums, so the collision carries no arithmetic information: the
gcd step returns `N` or `1`, never a factor. -/
theorem all_collisions_trivial_of_small {p r M : ℕ} {A : Finset ℕ}
    (hA : ∀ a ∈ A, a ≤ M) (hsmall : r * M < p)
    {u v : Fin r → ℕ} (hu : u ∈ tupleSpace r A) (hv : v ∈ tupleSpace r A)
    (hcong : (∑ i, u i) % p = (∑ i, v i) % p) :
    (∑ i, u i) = ∑ i, v i := by
  have hus : (∑ i, u i) ∈ sumSet r A := Finset.mem_image_of_mem _ hu
  have hvs : (∑ i, v i) ∈ sumSet r A := Finset.mem_image_of_mem _ hv
  have h1 := mem_sumSet_le hA hus
  have h2 := mem_sumSet_le hA hvs
  rcases lt_trichotomy (∑ i, u i) (∑ i, v i) with h | h | h
  · exfalso
    have hd : p ∣ (∑ i, v i) - ∑ i, u i := (Nat.modEq_iff_dvd' h.le).mp hcong
    have hpos : 0 < (∑ i, v i) - ∑ i, u i := Nat.sub_pos_of_lt h
    have := Nat.le_of_dvd hpos hd
    omega
  · exact h
  · exfalso
    have hd : p ∣ (∑ i, u i) - ∑ i, v i := (Nat.modEq_iff_dvd' h.le).mp hcong.symm
    have hpos : 0 < (∑ i, u i) - ∑ i, v i := Nat.sub_pos_of_lt h
    have := Nat.le_of_dvd hpos hd
    omega

/-! ## End-to-end success -/

/-- **Master theorem: `r`-SUM collision factoring works once both barriers are
passed.**  Let `N = p * q` with `p`, `q` prime, let `A` be a set of positive
integers bounded by `M` with `r * M < N`, and suppose the sumset of `r`-tuples
over `A` has more than `p` elements.  Then the search finds two tuple sums
`t < s` whose difference exposes `p`:  `gcd (s - t) N = p`. -/
theorem rsum_factoring_success {p q r M : ℕ} (hp : p.Prime) (hq : q.Prime)
    {A : Finset ℕ} (hA : ∀ a ∈ A, a ≤ M) (hMN : r * M < p * q)
    (hbig : p < (sumSet r A).card) :
    ∃ s ∈ sumSet r A, ∃ t ∈ sumSet r A, t < s ∧
      Nat.gcd (s - t) (p * q) = p := by
  obtain ⟨s, hs, t, ht, hts, hdvd⟩ :=
    useful_collision_of_sumset_card_lt hp.pos hbig
  refine ⟨s, hs, t, ht, hts, ?_⟩
  exact collision_gcd_reveal hp hq hts
    (lt_of_le_of_lt (mem_sumSet_le hA hs) hMN) hdvd

/-- Specialisation to 3SUM (`r = 3`): the sumset of triples exceeding `p`
suffices to factor `N = p * q`. -/
theorem threeSum_factoring_success {p q M : ℕ} (hp : p.Prime) (hq : q.Prime)
    {A : Finset ℕ} (hA : ∀ a ∈ A, a ≤ M) (hMN : 3 * M < p * q)
    (hbig : p < (sumSet 3 A).card) :
    ∃ s ∈ sumSet 3 A, ∃ t ∈ sumSet 3 A, t < s ∧
      Nat.gcd (s - t) (p * q) = p :=
  rsum_factoring_success hp hq hA hMN hbig

/-! ## The span barrier: structure never removes it -/

/-- **Span barrier (arity- and structure-free).**  If every value produced by a
scheme lies in an interval of length `p` (i.e. `L ≤ x < L + p`), then congruent
values are equal: no useful collision exists.  This holds for *any* collision
scheme — sumset, 3SUM, `r`-SUM, or an evaluation scheme such as singular moduli
— because it constrains only the numerical values, not how they are produced.
Consequently the values themselves must span a range of size at least `p`, and
for `q ≤ p` at least `√N`. -/
theorem span_barrier {p L : ℕ} {T : Finset ℕ}
    (hT : ∀ x ∈ T, L ≤ x ∧ x < L + p) :
    ∀ s ∈ T, ∀ t ∈ T, s % p = t % p → s = t := by
  intro s hs t ht hst
  obtain ⟨hs1, hs2⟩ := hT s hs
  obtain ⟨ht1, ht2⟩ := hT t ht
  rcases lt_trichotomy s t with h | h | h
  · have hd : p ∣ t - s := (Nat.modEq_iff_dvd' h.le).mp hst
    have := Nat.le_of_dvd (Nat.sub_pos_of_lt h) hd
    omega
  · exact h
  · have hd : p ∣ s - t := (Nat.modEq_iff_dvd' h.le).mp hst.symm
    have := Nat.le_of_dvd (Nat.sub_pos_of_lt h) hd
    omega

/-- Contrapositive form: a useful (factor-revealing) collision forces the value
range to be at least `p`, hence at least `√N` when `q ≤ p`. -/
theorem span_ge_of_useful_collision {p s t : ℕ} (hts : t < s)
    (hdvd : p ∣ s - t) : p ≤ s - t :=
  Nat.le_of_dvd (Nat.sub_pos_of_lt hts) hdvd

/-! ## Both barriers are necessary -/

/-- **The two barriers.**  If an `r`-SUM scheme over `A ⊆ [1, M]` can be
guaranteed to produce a *useful* collision modulo `p` (equivalently, its sumset
exceeds `p`), then

1. the amplitude bound `p < r * M + 1`, i.e. `p ≤ r * M`, must hold — the
   entries have to be of size at least `p / r`; and
2. the tuple count exceeds `√N` whenever `q ≤ p`, since `p ≤ |A| ^ r`.

Statement 2 shows the exponent improvement `p^{1/2} → p^{1/3}` never lowers the
total amount of inspected data below `√N`. -/
theorem rsum_needs_both_barriers {p q r M : ℕ} {A : Finset ℕ} (hqp : q ≤ p)
    (hA : ∀ a ∈ A, a ≤ M) (hbig : p < (sumSet r A).card) :
    p ≤ r * M ∧ Nat.sqrt (p * q) < A.card ^ r := by
  constructor
  · have := sumset_card_le_amplitude (r := r) hA
    omega
  · have hcard : (sumSet r A).card ≤ (tupleSpace r A).card :=
      Finset.card_image_le
    have : p < A.card ^ r := by
      have := card_tupleSpace r A
      omega
    exact tuple_scheme_cost_gt_sqrt hqp this

/-- **Quantitative corollary.**  A `3`-SUM scheme against `N = p * q` with
`q ≤ p` needs entries of size at least `p / 3` and inspects more than `√N`
triples: both of the two costs are `Ω(√N)`. -/
theorem threeSum_barriers {p q M : ℕ} {A : Finset ℕ} (hqp : q ≤ p)
    (hA : ∀ a ∈ A, a ≤ M) (hbig : p < (sumSet 3 A).card) :
    3 * M ≥ p ∧ Nat.sqrt (p * q) < A.card ^ 3 :=
  ⟨(rsum_needs_both_barriers hqp hA hbig).1, (rsum_needs_both_barriers hqp hA hbig).2⟩

end CollisionFactoring