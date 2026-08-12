/-
# The knot–number bridge IX: the factor-degree multiset determines the knot

Conjecture `C3` of `FUTURE_DIRECTIONS.md` predicted that the degree multiset
`D_N = {φ(d) : d ∣ N, d > 1}` of the irreducible factors of `A_N` is injective on odd
*squarefree* `N` but **not** injective in general.  A search over all odd `N < 60000` found
no collision at all (`ComputationalEvidence.md` §5), and this file explains why: the
conjecture was right about injectivity but wrong about its scope.  The reason is Gauss'
identity `∑_{d ∣ N} φ(d) = N`, which makes the *sum* of the degree multiset equal to
`N - 1 = deg A_N`, so `N` is recovered from `D_N` by a single addition:

* `Bridges.AlexanderTorus.sum_degree_multiset` : `(D_N).sum = N - 1`;
* `Bridges.AlexanderTorus.degree_multiset_recovers` : `N = (D_N).sum + 1` for `N > 0`;
* `Bridges.AlexanderTorus.degree_multiset_injective` : `D_M = D_N → M = N` for `M, N > 0`
  — no squarefreeness and no oddness needed;
* `Bridges.AlexanderTorus.alexander_factor_degrees_determine_knot` : for odd `M, N > 1`,
  the torus knots `T(2,M)` and `T(2,N)` have the same multiset of Alexander-factor degrees
  iff `M = N`.

So `C3` is resolved: the positive half holds in far greater generality than conjectured, and
the predicted counterexample does not exist.  (The collision `φ(9) = φ(7) = 6` at `N = 63`
is a repeat *inside* one multiset, which is harmless — it costs the *symmetry-breaking*
information, not the value of `N`.)
-/
import Bridges.AlexanderKnotNumberBridgeII

namespace Bridges.AlexanderTorus

open Polynomial Finset

/-- The multiset of degrees of the irreducible factors of `A_N`, indexed by the nontrivial
divisors of `N`. -/
def degreeMultiset (N : ℕ) : Multiset ℕ := (N.divisors.erase 1).val.map Nat.totient

/-- The degrees add up to `deg A_N = N - 1` (Gauss' totient identity). -/
theorem sum_degree_multiset {N : ℕ} (hpos : 0 < N) : (degreeMultiset N).sum = N - 1 :=
  sum_totient_erase_one hpos

/-- `N` is recovered from the degree multiset by a single addition. -/
theorem degree_multiset_recovers {N : ℕ} (hpos : 0 < N) : (degreeMultiset N).sum + 1 = N := by
  rw [sum_degree_multiset hpos]
  omega

/-- **The degree multiset determines `N`.**  No squarefreeness, and no oddness, is needed:
the predicted counterexample of `C3` cannot exist. -/
theorem degree_multiset_injective {M N : ℕ} (hM : 0 < M) (hN : 0 < N)
    (h : degreeMultiset M = degreeMultiset N) : M = N := by
  have h1 := degree_multiset_recovers hM
  have h2 := degree_multiset_recovers hN
  rw [h] at h1
  omega

/-- Knot-theoretic form: two torus knots `T(2,M)`, `T(2,N)` have the same multiset of
Alexander-factor degrees iff they are the same knot. -/
theorem alexander_factor_degrees_determine_knot {M N : ℕ} (hM : Odd M) (hN : Odd N)
    (hM1 : 1 < M) (hN1 : 1 < N) :
    (∃ s t : Multiset ℤ[X],
        (∀ f ∈ s, Irreducible f) ∧ s.prod = alexander M ∧
        s.map Polynomial.natDegree = degreeMultiset M ∧
        (∀ f ∈ t, Irreducible f) ∧ t.prod = alexander N ∧
        t.map Polynomial.natDegree = degreeMultiset N ∧
        s.map Polynomial.natDegree = t.map Polynomial.natDegree) ↔ M = N := by
  constructor
  · rintro ⟨s, t, -, -, hsD, -, -, htD, hst⟩
    exact degree_multiset_injective (by omega) (by omega) (hsD ▸ htD ▸ hst)
  · rintro rfl
    obtain ⟨s, hirr, hprod, -, hdeg⟩ := alexander_factorization_multiset hM hM1
    exact ⟨s, s, hirr, hprod, hdeg, hirr, hprod, hdeg, rfl⟩

/-- The number of irreducible factors of `A_N` is `τ(N) - 1`, and the degree multiset has
that many entries. -/
theorem card_degree_multiset (N : ℕ) :
    Multiset.card (degreeMultiset N) = N.divisors.card - 1 := by
  rw [degreeMultiset, Multiset.card_map]
  rcases Nat.eq_zero_or_pos N with rfl | hpos
  · simp
  · rw [← Finset.card_def, Finset.card_erase_of_mem (Nat.one_mem_divisors.2 hpos.ne')]

end Bridges.AlexanderTorus