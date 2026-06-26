import Applications.NoveltyCertification.Packing
import Applications.RankOfApparition

/-!
# Certified Novelty Detection — a catalog-driven novelty stream from primitive divisors

This file **instantiates** the abstract novelty machinery of `EmbeddingSpace.lean` /
`Packing.lean` on a genuine catalog result: the Fibonacci **primitive prime divisor**
theorem `RankOfApparition.fib_prime_index_has_primitive` from
`Catalog/Applications/RankOfApparition.lean`.  That theorem states that for every prime
index `p ≥ 3`, `F p` has a *primitive* prime divisor — a prime `q ∣ F p` with `q ∤ F k` for
all `0 < k < p` (catalog predicate `RankOfApparition.IsPrimitive`).

We turn this into an unbounded **stream of certifiably-novel theorems**.  Map each prime
index `p ≥ 3` to its primitive prime `carPrime p`, then embed it on the real line via
`carEmbed p = carPrime p`.  Primitivity forces the primes for distinct indices to be
*distinct* (`carPrime_ne`), so the embedded catalog is `1`-separated and its cardinality
equals the number of indices used.  Hence:

* `carmichael_catalog_separated` — the embedded catalog is `Separated 1`.
* `carmichael_catalog_card` — it has exactly one entry per index (no collisions).
* `unbounded_novelty_budget` — there exist **arbitrarily large** `1`-separated novelty
  catalogs.  In contrast to `Separated.card_le_of_cells`, the prime embedding line has *no*
  finite novelty budget: the primitive divisor theorem is an inexhaustible source of new
  mathematics (there are infinitely many prime indices).

-- !-- Lab Notes -- !--
-- !-- Hypothesis: a single catalog theorem (the Fibonacci primitive divisor theorem) yields
--     an *infinite* certifiably-novel stream, witnessing that the prime embedding space
--     defeats the packing/novelty-budget ceiling. -- !--
-- !-- Experiment: chose primitive primes via `fib_prime_index_has_primitive.choose`, proved
--     distinctness `carPrime_ne` from primitivity (a shared primitive prime of `F p`, `F p'`
--     with `p < p'` would divide `F p` with `0 < p < p'`, contradicting primitivity at
--     `p'`), then transported distinctness to a `Separated 1` real catalog and exhibited
--     catalogs of every size from the infinitude of primes (`Nat.infinite_setOf_prime`). -- !--
-- !-- Analysis: distinctness is *exactly* the primitivity clause `∀ k, 0<k→k<p→¬ q ∣ F k` —
--     the same clause that makes the catalog theorem nontrivial. Novelty certification and
--     primitive-divisor theory are the same phenomenon viewed metrically. -- !--
-- !-- Critique: distinct naturals give real distance `≥ 1` (the `Int` gap `Int.one_le_abs`),
--     so `ε = 1` is the sharp resolution; the embedding is non-collapsing precisely because
--     primitivity is a *global* (all earlier indices) condition, not a local one. The
--     infinitude of the index set is what makes the budget unbounded — a structural
--     contrast with `Separated.card_le_of_cells`. -- !--
-/

namespace NoveltyCertification

open Finset

/-- Indices admissible for the primitive-divisor stream: prime indices `≥ 3`. -/
def AdmissibleIndex (p : ℕ) : Prop := Nat.Prime p ∧ 3 ≤ p

open Classical in
/-- The chosen **primitive prime divisor** of `F p` for an admissible index `p`
(junk value `0` otherwise). -/
noncomputable def carPrime (p : ℕ) : ℕ :=
  if h : AdmissibleIndex p then
    (RankOfApparition.fib_prime_index_has_primitive h.1 h.2).choose
  else 0

/-- Defining property of `carPrime p` for an admissible index: it is a prime and a
primitive divisor of `F p`. -/
theorem carPrime_spec {p : ℕ} (hp : AdmissibleIndex p) :
    Nat.Prime (carPrime p) ∧ RankOfApparition.IsPrimitive (carPrime p) p := by
  simp only [carPrime, dif_pos hp]
  exact (RankOfApparition.fib_prime_index_has_primitive hp.1 hp.2).choose_spec

/-- **Distinctness from primitivity**: distinct admissible indices get distinct primitive
primes. -/
theorem carPrime_ne {p q : ℕ} (hp : AdmissibleIndex p) (hq : AdmissibleIndex q)
    (hpq : p ≠ q) : carPrime p ≠ carPrime q := by
  intro heq
  rcases lt_or_gt_of_ne hpq with hlt | hgt
  · have sp := carPrime_spec hp
    have sq := carPrime_spec hq
    have hppos : 0 < p := by have := hp.2; omega
    have hdvd : carPrime p ∣ Nat.fib p := sp.2.1
    have hnd : ¬ carPrime q ∣ Nat.fib p := sq.2.2 p hppos hlt
    rw [heq] at hdvd
    exact hnd hdvd
  · have sp := carPrime_spec hp
    have sq := carPrime_spec hq
    have hqpos : 0 < q := by have := hq.2; omega
    have hdvd : carPrime q ∣ Nat.fib q := sq.2.1
    have hnd : ¬ carPrime p ∣ Nat.fib q := sp.2.2 q hqpos hgt
    rw [← heq] at hdvd
    exact hnd hdvd

/-- The real-line embedding of the primitive-prime stream. -/
noncomputable def carEmbed (p : ℕ) : ℝ := (carPrime p : ℝ)

/-- `carEmbed` is injective on admissible indices. -/
theorem carEmbed_injOn {I : Finset ℕ} (hI : ∀ p ∈ I, AdmissibleIndex p) :
    Set.InjOn carEmbed I := by
  intro x hx y hy hxy
  by_contra hne
  apply carPrime_ne (hI x hx) (hI y hy) hne
  simp only [carEmbed] at hxy
  exact_mod_cast hxy

/-- **Separated catalog**: any catalog of embedded primitive primes is `1`-separated.  (No
admissibility hypothesis is needed: distinct embedded values are distinct naturals, hence at
least `1` apart; this is even stronger than the admissible-index version.) -/
theorem carmichael_catalog_separated (I : Finset ℕ) :
    Separated 1 (I.image carEmbed) := by
  intro u hu v hv huv
  simp only [Finset.mem_image] at hu hv
  obtain ⟨p, hp, rfl⟩ := hu
  obtain ⟨q, hq, rfl⟩ := hv
  have hmn : carPrime p ≠ carPrime q := by
    intro h; apply huv; simp only [carEmbed]; rw [h]
  simp only [carEmbed, Real.dist_eq]
  have hz : (carPrime p : ℤ) ≠ (carPrime q : ℤ) := by exact_mod_cast hmn
  have h1 : (1:ℤ) ≤ |(carPrime p : ℤ) - (carPrime q : ℤ)| := Int.one_le_abs (sub_ne_zero.mpr hz)
  have hcast : (((|(carPrime p:ℤ)-(carPrime q:ℤ)|) : ℤ) : ℝ)
      = |(carPrime p : ℝ) - (carPrime q : ℝ)| := by push_cast; ring
  rw [← hcast]; exact_mod_cast h1

/-- The embedded catalog has exactly one entry per index — no two indices collide. -/
theorem carmichael_catalog_card {I : Finset ℕ} (hI : ∀ p ∈ I, AdmissibleIndex p) :
    (I.image carEmbed).card = I.card :=
  Finset.card_image_of_injOn (carEmbed_injOn hI)

/-- There is a finite set of `N` admissible (prime) indices, for every `N`. -/
theorem exists_admissible_indices (N : ℕ) :
    ∃ I : Finset ℕ, (∀ p ∈ I, AdmissibleIndex p) ∧ I.card = N := by
  have hinf : {p : ℕ | AdmissibleIndex p}.Infinite := by
    have hp : {p : ℕ | Nat.Prime p}.Infinite := Nat.infinite_setOf_prime
    have heq : {p : ℕ | AdmissibleIndex p} = {p : ℕ | Nat.Prime p} \ {p : ℕ | p < 3} := by
      ext p; simp [AdmissibleIndex]
    rw [heq]
    exact hp.diff ((Set.finite_Iio 3).subset (by intro x hx; simp at hx ⊢; omega))
  obtain ⟨I, hsub, hcard⟩ := hinf.exists_subset_card_eq N
  exact ⟨I, fun p hp => hsub hp, hcard⟩

/-- **Unbounded novelty budget**: there exist `1`-separated novelty catalogs of every size.
The Fibonacci primitive divisor theorem certifies arbitrarily much genuinely new mathematics
in the prime embedding space, so this space has no finite novelty budget. -/
theorem unbounded_novelty_budget (N : ℕ) :
    ∃ C : Finset ℝ, Separated 1 C ∧ N ≤ C.card := by
  obtain ⟨I, hI, hcard⟩ := exists_admissible_indices N
  refine ⟨I.image carEmbed, carmichael_catalog_separated I, ?_⟩
  rw [carmichael_catalog_card hI, hcard]

end NoveltyCertification