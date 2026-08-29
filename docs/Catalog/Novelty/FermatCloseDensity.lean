import Novelty.OracleRealizationGap

/-!
# Sparsity of the Fermat-close population: the hit rate is a population artefact

The round-74 measurement reports a sensor hit rate of `0.2053` at threshold `B = 22758` on a
laboratory population of semiprimes, and flags as an honest limit that this rate reflects the
population's size-ratio coupling rather than a property of semiprimes at large.

This file proves that limit.  For a *fixed* threshold `B`, the integers `N ≤ X` admitting a
Fermat-close factorisation (`N = pq` with `p, q` odd, `p ≤ q` and `gap p q ≤ B`) number at most

`(⌊√X⌋ + B + 1) · (⌊√(2B(⌊√X⌋+B))⌋ + 1)`,

which is of order `√B · X^{3/4}` — density `O(√B · X^{-1/4}) → 0`.  A fixed hit rate of `0.2053`
is therefore impossible in the limit: it is a feature of the finite lab population.

## Main results

* `closeSet_subset_image` : every Fermat-close `N ≤ X` is a difference of squares `a² - h²` with
  `a ≤ ⌊√X⌋ + B` and `h ≤ ⌊√(2B(⌊√X⌋+B))⌋`;
* `closeSet_ncard_le` : hence the explicit counting bound above;
* `closeSet_ncard_le_three_quarter` : the same bound in `X^{1/2} · X^{1/4}` shape, via
  submultiplicativity of `Nat.sqrt`;
* `sqrt_mul_le` : `⌊√(uv)⌋ ≤ (⌊√u⌋+1)(⌊√v⌋+1)`, the auxiliary submultiplicativity.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the observed hit rate cannot persist: Fermat-close integers are
governed by two free parameters `(a, h)` with `h` of size at most `√(2Ba)`, so they occupy a
`X^{3/4}`-sized slice of `[1, X]` — a vanishing density.

Experiment (Experimenter): `ComputationalEvidence.md` counts Fermat-close semiprimes below
`10^4, 10^5, 10^6` for `B ∈ {1, 4, 16}` and records the shrinking empirical density.

Analysis (Analyst): the counting is entirely structural — the parametrisation `N = a² - h²` is
injective, and the gap constraint bounds `h` by `√(2Ba)`.  No sieve or analytic input is needed,
which is why the bound is unconditional and explicit.

Critique (Critic): the bound counts *all* differences of squares with odd factors, hence a
superset of semiprimes — that only strengthens it.  It is stated with `Set.ncard`, which is
`0` for infinite sets, so the enclosing finite superset is exhibited explicitly to make the
statement non-vacuous.
-/

namespace OracleRealizationGap

open Finset

/-- The Fermat-close population up to `X` at threshold `B`. -/
def closeSet (X B : ℕ) : Set ℕ :=
  {N | N ≤ X ∧ ∃ p q : ℕ, Odd p ∧ Odd q ∧ p ≤ q ∧ N = p * q ∧ gap p q ≤ B}

/-- The enclosing box of Fermat parameters `(a, h)`. -/
def closeBox (X B : ℕ) : Finset (ℕ × ℕ) :=
  Finset.range (Nat.sqrt X + B + 1) ×ˢ Finset.range (Nat.sqrt (2 * B * (Nat.sqrt X + B)) + 1)

/-- Every Fermat-close `N ≤ X` is a difference of two squares taken from the parameter box. -/
theorem closeSet_subset_image (X B : ℕ) :
    closeSet X B ⊆ ↑((closeBox X B).image fun x => x.1 ^ 2 - x.2 ^ 2) := by
  rintro N ⟨hNX, p, q, hpo, hqo, hpq, rfl, hgap⟩
  have hs : Nat.sqrt (p * q) + gap p q = mid p q := sqrt_add_gap hpo hqo hpq
  have hsX : Nat.sqrt (p * q) ≤ Nat.sqrt X := Nat.sqrt_le_sqrt hNX
  have hmA : mid p q ≤ Nat.sqrt X + B := by omega
  have hmsq : (mid p q) ^ 2 = p * q + ((q - p) / 2) ^ 2 := mid_sq hpo hqo hpq
  have hsle : (Nat.sqrt (p * q)) ^ 2 ≤ p * q := Nat.sqrt_le' _
  -- the half-difference is bounded by `√(2B(√X+B))`
  have hhsq : ((q - p) / 2) ^ 2 ≤ 2 * B * (Nat.sqrt X + B) := by
    have hmle : mid p q ≤ Nat.sqrt (p * q) + B := by omega
    have hexp : (mid p q) ^ 2 ≤ (Nat.sqrt (p * q) + B) ^ 2 := Nat.pow_le_pow_left hmle 2
    have hkey : (Nat.sqrt (p * q) + B) ^ 2
        = (Nat.sqrt (p * q)) ^ 2 + (2 * B * Nat.sqrt (p * q) + B ^ 2) := by ring
    have hbnd : 2 * B * Nat.sqrt (p * q) + B ^ 2 ≤ 2 * B * (Nat.sqrt X + B) := by
      have : 2 * B * Nat.sqrt (p * q) ≤ 2 * B * Nat.sqrt X :=
        Nat.mul_le_mul_left _ hsX
      nlinarith [Nat.zero_le B]
    omega
  have hhle : (q - p) / 2 ≤ Nat.sqrt (2 * B * (Nat.sqrt X + B)) := Nat.le_sqrt'.2 hhsq
  refine Finset.mem_coe.2 (Finset.mem_image.2 ⟨(mid p q, (q - p) / 2), ?_, ?_⟩)
  · refine Finset.mem_product.2 ⟨Finset.mem_range.2 (by omega), Finset.mem_range.2 (by omega)⟩
  · simp only
    omega

/-- **Counting bound.**  For fixed threshold `B` the Fermat-close integers below `X` number at
most `(⌊√X⌋ + B + 1)·(⌊√(2B(⌊√X⌋+B))⌋ + 1)`, of order `√B · X^{3/4}`. -/
theorem closeSet_ncard_le (X B : ℕ) :
    (closeSet X B).ncard ≤
      (Nat.sqrt X + B + 1) * (Nat.sqrt (2 * B * (Nat.sqrt X + B)) + 1) := by
  classical
  have hsub := closeSet_subset_image X B
  have hfin : ((closeBox X B).image fun x => x.1 ^ 2 - x.2 ^ 2 : Finset ℕ).card
      ≤ (Nat.sqrt X + B + 1) * (Nat.sqrt (2 * B * (Nat.sqrt X + B)) + 1) := by
    refine le_trans (Finset.card_image_le) ?_
    simp [closeBox, Finset.card_product]
  refine le_trans (Set.ncard_le_ncard hsub (Finset.finite_toSet _)) ?_
  rw [Set.ncard_coe_finset]
  exact hfin

/-- Submultiplicativity of the integer square root. -/
theorem sqrt_mul_le (u v : ℕ) : Nat.sqrt (u * v) ≤ (Nat.sqrt u + 1) * (Nat.sqrt v + 1) := by
  have hu : u < (Nat.sqrt u + 1) ^ 2 := Nat.lt_succ_sqrt' u
  have hv : v < (Nat.sqrt v + 1) ^ 2 := Nat.lt_succ_sqrt' v
  have : u * v < ((Nat.sqrt u + 1) * (Nat.sqrt v + 1)) ^ 2 := by
    calc u * v < (Nat.sqrt u + 1) ^ 2 * (Nat.sqrt v + 1) ^ 2 := by
          exact Nat.mul_lt_mul_of_lt_of_lt hu hv
      _ = ((Nat.sqrt u + 1) * (Nat.sqrt v + 1)) ^ 2 := by ring
  exact Nat.le_of_lt_succ (Nat.lt_succ_of_lt (Nat.sqrt_lt'.2 this))

/-- The counting bound in `X^{1/2} · X^{1/4}` shape: the second factor is a square root of a
square root, exhibiting the `X^{3/4}` growth explicitly. -/
theorem closeSet_ncard_le_three_quarter (X B : ℕ) :
    (closeSet X B).ncard ≤
      (Nat.sqrt X + B + 1) *
        ((Nat.sqrt (2 * B) + 1) * (Nat.sqrt (Nat.sqrt X + B) + 1) + 1) := by
  refine le_trans (closeSet_ncard_le X B) ?_
  exact Nat.mul_le_mul_left _ (by
    have := sqrt_mul_le (2 * B) (Nat.sqrt X + B)
    omega)

end OracleRealizationGap