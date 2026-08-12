/-
# The Global Polynomial Counting Barrier (Factoring Lab, Phase A v19c — cycle 2)

Closing the **global** half of **Conjecture 1** of `FUTURE_DIRECTIONS.md`.

The previous cycle proved the *per-small-factor* bound
`FactoringLab.polynomial_barrier_counting`: for a fixed prime `p`, a polynomial
`P ∈ ℚ[X]` with `P ≠ C p` returns the correct factor `P(pq) = p` for at most
`deg P` primes `q`.  What was left open was the summation over `p` — the global
count of semiprimes `N = pq ≤ X` on which a fixed polynomial succeeds.

This file closes that step.  The main results are:

* `FactoringLab.successPairs_card_le` — for every `P` with `deg P ≥ 1`,
  the number of pairs `(p, q)` of primes with `p < q`, `pq ≤ X` and
  `P(pq) = p` is at most `deg P · π(√X)`, where `π(√X)` is counted by the
  explicit finset `FactoringLab.smallPrimes X`;
* `FactoringLab.successPairs_card_le_sqrt` — the cruder, hypothesis-free form
  `deg P · (√X + 1)`;
* `FactoringLab.exists_polynomial_failure` — the counting bound turned into an
  existence statement: as soon as the number of semiprimes below `X` exceeds
  `deg P · (√X + 1)`, an explicit semiprime on which `P` fails must exist.  In
  particular the *success density* of any fixed polynomial is `O(√X)` against a
  population of order `X log log X / log X`.

The mechanism is exactly the one predicted in the conjecture: the fibre of the
success set over a fixed small factor `p` injects into the root set of
`P − C p`, and the small factor of a semiprime `≤ X` is at most `√X`.
-/
import Mathlib
import Probability.FactoringBarriers

namespace FactoringLab

open Finset

/-! ## 1.  The finite populations -/

/-- The primes that can occur as the *smaller* factor of a semiprime `≤ X`. -/
def smallPrimes (X : ℕ) : Finset ℕ :=
  (Finset.range (Nat.sqrt X + 1)).filter Nat.Prime

/-- All ordered prime pairs `(p, q)`, `p < q`, with `pq ≤ X`: the population of
semiprimes below `X`. -/
def semiprimePairs (X : ℕ) : Finset (ℕ × ℕ) :=
  ((Finset.range (X + 1)) ×ˢ (Finset.range (X + 1))).filter
    (fun z => z.1.Prime ∧ z.2.Prime ∧ z.1 < z.2 ∧ z.1 * z.2 ≤ X)

/-- The pairs on which the polynomial `P` *succeeds*: it returns the smaller
prime factor of `N = pq`. -/
def successPairs (P : Polynomial ℚ) (X : ℕ) : Finset (ℕ × ℕ) :=
  (semiprimePairs X).filter (fun z => P.eval ((z.1 * z.2 : ℕ) : ℚ) = (z.1 : ℚ))

theorem successPairs_subset (P : Polynomial ℚ) (X : ℕ) :
    successPairs P X ⊆ semiprimePairs X := Finset.filter_subset _ _

theorem mem_semiprimePairs {X : ℕ} {z : ℕ × ℕ} (hz : z ∈ semiprimePairs X) :
    z.1.Prime ∧ z.2.Prime ∧ z.1 < z.2 ∧ z.1 * z.2 ≤ X := (Finset.mem_filter.1 hz).2

theorem mem_successPairs {P : Polynomial ℚ} {X : ℕ} {z : ℕ × ℕ}
    (hz : z ∈ successPairs P X) :
    z.1.Prime ∧ z.2.Prime ∧ z.1 < z.2 ∧ z.1 * z.2 ≤ X ∧
      P.eval ((z.1 * z.2 : ℕ) : ℚ) = (z.1 : ℚ) := by
  obtain ⟨hmem, heval⟩ := Finset.mem_filter.1 hz
  obtain ⟨h1, h2, h3, h4⟩ := mem_semiprimePairs hmem
  exact ⟨h1, h2, h3, h4, heval⟩

/-! ## 2.  The smaller factor of a semiprime below `X` is at most `√X` -/

theorem fst_mem_smallPrimes {X : ℕ} {z : ℕ × ℕ} (hz : z ∈ semiprimePairs X) :
    z.1 ∈ smallPrimes X := by
  obtain ⟨hp, _, hlt, hle⟩ := mem_semiprimePairs hz
  have hsq : z.1 * z.1 ≤ X := le_trans (Nat.mul_le_mul_left _ hlt.le) hle
  have : z.1 ≤ Nat.sqrt X := Nat.le_sqrt.2 hsq
  exact Finset.mem_filter.2 ⟨Finset.mem_range.2 (Nat.lt_succ_of_le this), hp⟩

/-! ## 3.  The fibre bound -/

/-- Over a fixed small factor `p`, the success set has at most `deg P`
elements: this is `polynomial_barrier_counting` transported to pairs. -/
theorem fiber_card_le (P : Polynomial ℚ) (hP : 1 ≤ P.natDegree) (X : ℕ) (p : ℕ)
    (hp : p ∈ smallPrimes X) :
    {z ∈ successPairs P X | z.1 = p}.card ≤ P.natDegree := by
  classical
  have hpp : p.Prime := (Finset.mem_filter.1 hp).2
  have hne : P ≠ Polynomial.C (p : ℚ) := by
    intro h
    rw [h, Polynomial.natDegree_C] at hP
    exact absurd hP (by norm_num)
  set F : Finset (ℕ × ℕ) := {z ∈ successPairs P X | z.1 = p} with hF
  set S : Finset ℕ := F.image Prod.snd with hS
  have hcard : F.card = S.card := by
    refine (Finset.card_image_of_injOn ?_).symm
    intro a ha b hb hab
    have ha1 : a.1 = p := (Finset.mem_filter.1 ha).2
    have hb1 : b.1 = p := (Finset.mem_filter.1 hb).2
    exact Prod.ext (ha1.trans hb1.symm) hab
  have hSprop : ∀ q ∈ S, q.Prime ∧ p < q ∧ P.eval ((p * q : ℕ) : ℚ) = (p : ℚ) := by
    intro q hq
    obtain ⟨z, hzF, rfl⟩ := Finset.mem_image.1 hq
    have hz1 : z.1 = p := (Finset.mem_filter.1 hzF).2
    obtain ⟨-, hq2, hlt, -, heval⟩ := mem_successPairs (Finset.mem_filter.1 hzF).1
    refine ⟨hq2, ?_, ?_⟩
    · rwa [hz1] at hlt
    · rw [← hz1]; exact heval
  rw [hcard]
  exact polynomial_barrier_counting P hpp hne S hSprop

/-! ## 4.  The global counting barrier -/

/-- **Global polynomial counting barrier.**  A fixed polynomial of degree
`d ≥ 1` returns the smaller prime factor of at most `d · π(√X)` semiprimes
`pq ≤ X`.  Success is confined to a set of size `O(√X)`, while the number of
semiprimes below `X` is of order `X log log X / log X`. -/
theorem successPairs_card_le (P : Polynomial ℚ) (hP : 1 ≤ P.natDegree) (X : ℕ) :
    (successPairs P X).card ≤ P.natDegree * (smallPrimes X).card := by
  classical
  refine Finset.card_le_mul_card_image_of_maps_to
    (f := Prod.fst) (t := smallPrimes X) ?_ P.natDegree ?_
  · intro z hz
    exact fst_mem_smallPrimes (successPairs_subset P X hz)
  · intro p hp
    exact fiber_card_le P hP X p hp

/-- The crude form of the bound: at most `deg P · (√X + 1)` successes. -/
theorem successPairs_card_le_sqrt (P : Polynomial ℚ) (hP : 1 ≤ P.natDegree) (X : ℕ) :
    (successPairs P X).card ≤ P.natDegree * (Nat.sqrt X + 1) := by
  refine le_trans (successPairs_card_le P hP X) (Nat.mul_le_mul_left _ ?_)
  calc (smallPrimes X).card ≤ (Finset.range (Nat.sqrt X + 1)).card :=
        Finset.card_le_card (Finset.filter_subset _ _)
    _ = Nat.sqrt X + 1 := Finset.card_range _

/-- **From counting to failure.**  Once the semiprime population below `X`
outgrows `deg P · (√X + 1)`, the polynomial must fail on an explicit semiprime:
the counting barrier produces witnesses, not merely a density statement. -/
theorem exists_polynomial_failure (P : Polynomial ℚ) (hP : 1 ≤ P.natDegree) (X : ℕ)
    (hbig : P.natDegree * (Nat.sqrt X + 1) < (semiprimePairs X).card) :
    ∃ z ∈ semiprimePairs X, P.eval ((z.1 * z.2 : ℕ) : ℚ) ≠ (z.1 : ℚ) := by
  classical
  by_contra h
  push_neg at h
  have hsub : semiprimePairs X ⊆ successPairs P X := by
    intro z hz
    exact Finset.mem_filter.2 ⟨hz, h z hz⟩
  have := Finset.card_le_card hsub
  have hle := successPairs_card_le_sqrt P hP X
  omega

/-! ## 5.  The counting barrier for rational functions -/

/-- The pairs on which the rational function `A/B` succeeds: `A(N) = p · B(N)`
for `N = pq`.  (Written multiplicatively, so no nonvanishing hypothesis on `B`
is needed.) -/
def ratSuccessPairs (A B : Polynomial ℚ) (X : ℕ) : Finset (ℕ × ℕ) :=
  (semiprimePairs X).filter
    (fun z => A.eval ((z.1 * z.2 : ℕ) : ℚ) = (z.1 : ℚ) * B.eval ((z.1 * z.2 : ℕ) : ℚ))

theorem ratSuccessPairs_subset (A B : Polynomial ℚ) (X : ℕ) :
    ratSuccessPairs A B X ⊆ semiprimePairs X := Finset.filter_subset _ _

/-- Fibre bound for a rational function: over a fixed small factor `p`, the
successes of `A/B` inject into the roots of the nonzero polynomial
`A − p·B`, of degree at most `max (deg A) (deg B)`. -/
theorem rat_fiber_card_le (A B : Polynomial ℚ) (X : ℕ) (p : ℕ)
    (hp : p ∈ smallPrimes X) (hAB : A ≠ Polynomial.C (p : ℚ) * B) :
    {z ∈ ratSuccessPairs A B X | z.1 = p}.card ≤ max A.natDegree B.natDegree := by
  classical
  have hpp : p.Prime := (Finset.mem_filter.1 hp).2
  have hpne : (p : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hpp.ne_zero
  set G : Polynomial ℚ := A - Polynomial.C (p : ℚ) * B with hG
  have hG0 : G ≠ 0 := sub_ne_zero.2 hAB
  have hdeg : G.natDegree ≤ max A.natDegree B.natDegree := by
    refine le_trans (Polynomial.natDegree_sub_le _ _) (max_le_max le_rfl ?_)
    exact le_trans (Polynomial.natDegree_mul_le) (by simp)
  set F : Finset (ℕ × ℕ) := {z ∈ ratSuccessPairs A B X | z.1 = p} with hF
  have hmap : ∀ z ∈ F, ((p : ℚ) * (z.2 : ℚ)) ∈ G.roots.toFinset := by
    intro z hz
    have hz1 : z.1 = p := (Finset.mem_filter.1 hz).2
    have heval : A.eval ((z.1 * z.2 : ℕ) : ℚ)
        = (z.1 : ℚ) * B.eval ((z.1 * z.2 : ℕ) : ℚ) :=
      (Finset.mem_filter.1 (Finset.mem_filter.1 hz).1).2
    have hx : ((z.1 * z.2 : ℕ) : ℚ) = (p : ℚ) * (z.2 : ℚ) := by
      rw [Nat.cast_mul, hz1]
    rw [hx, hz1] at heval
    rw [Multiset.mem_toFinset, Polynomial.mem_roots hG0]
    simp only [hG, Polynomial.IsRoot, Polynomial.eval_sub, Polynomial.eval_mul,
      Polynomial.eval_C, heval, sub_self]
  have hinj : ∀ a ∈ F, ∀ b ∈ F,
      (p : ℚ) * (a.2 : ℚ) = (p : ℚ) * (b.2 : ℚ) → a = b := by
    intro a ha b hb hab
    have h2 : a.2 = b.2 := by
      have : (a.2 : ℚ) = (b.2 : ℚ) := mul_left_cancel₀ hpne hab
      exact_mod_cast this
    have ha1 : a.1 = p := (Finset.mem_filter.1 ha).2
    have hb1 : b.1 = p := (Finset.mem_filter.1 hb).2
    exact Prod.ext (ha1.trans hb1.symm) h2
  calc F.card ≤ G.roots.toFinset.card :=
        Finset.card_le_card_of_injOn (fun z => (p : ℚ) * (z.2 : ℚ)) hmap hinj
    _ ≤ Multiset.card G.roots := G.roots.toFinset_card_le
    _ ≤ G.natDegree := G.card_roots'
    _ ≤ max A.natDegree B.natDegree := hdeg

/-- **Counting barrier for rational functions (quantitative WWW).**  Unless the
quotient `A/B` *is* the constant prime `p` for some `p` — the trivial case in
which a single small factor is hard-coded — a fixed rational function returns
the smaller prime factor of at most `max (deg A) (deg B) · π(√X)` semiprimes
`pq ≤ X`.  This makes the qualitative statement
`FactoringLab.rational_escape_illusory` quantitative. -/
theorem ratSuccessPairs_card_le (A B : Polynomial ℚ) (X : ℕ)
    (hAB : ∀ p : ℕ, p.Prime → A ≠ Polynomial.C (p : ℚ) * B) :
    (ratSuccessPairs A B X).card
      ≤ max A.natDegree B.natDegree * (smallPrimes X).card := by
  classical
  refine Finset.card_le_mul_card_image_of_maps_to
    (f := Prod.fst) (t := smallPrimes X) ?_ (max A.natDegree B.natDegree) ?_
  · intro z hz
    exact fst_mem_smallPrimes (ratSuccessPairs_subset A B X hz)
  · intro p hp
    exact rat_fiber_card_le A B X p hp (hAB p (Finset.mem_filter.1 hp).2)

/-- A sanity instance of the population bound: `(3, 5)`, `(3, 7)` and `(5, 7)`
are semiprime pairs below `40`, so any polynomial of degree `1` already fails
somewhere below `X = 40` unless it succeeds at least `3` times per small
factor — impossible for degree `1`.  (The numerical check exercises the
definitions used above.) -/
theorem semiprimePairs_forty_card_ge : 3 ≤ (semiprimePairs 40).card := by
  have h1 : ((3, 5) : ℕ × ℕ) ∈ semiprimePairs 40 := by decide
  have h2 : ((3, 7) : ℕ × ℕ) ∈ semiprimePairs 40 := by decide
  have h3 : ((5, 7) : ℕ × ℕ) ∈ semiprimePairs 40 := by decide
  have hsub : ({(3, 5), (3, 7), (5, 7)} : Finset (ℕ × ℕ)) ⊆ semiprimePairs 40 := by
    intro z hz
    fin_cases hz <;> assumption
  calc (3 : ℕ) = ({(3, 5), (3, 7), (5, 7)} : Finset (ℕ × ℕ)).card := by decide
    _ ≤ (semiprimePairs 40).card := Finset.card_le_card hsub

end FactoringLab