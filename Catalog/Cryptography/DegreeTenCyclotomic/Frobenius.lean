import Mathlib

/-!
# Frobenius factor patterns of cyclotomic polynomials (all conductors)

Built on Mathlib's `Polynomial.natDegree_of_mem_normalizedFactors_cyclotomic`:

* `cyclotomic_factor_degree` — every irreducible factor of `Φₙ` over `𝔽_p` (`p ∤ n`) has
  degree `ord_n(p)`.
* `cyclotomic_factor_pattern` — the factor-degree multiset is `replicate (φ(n)/t) t`.
* `mulLeft_minimalPeriod`, `zpowers_index_mul_orderOf` — the group-side mirror: left
  multiplication by `g` has all cycles of length `ord(g)`, and `|G|/ord(g)` of them.
-/

open Polynomial UniqueFactorizationMonoid

namespace DegreeTen

/-- The Frobenius class of a prime `p ∤ n` in `Gal(ℚ(ζₙ)/ℚ) ≅ (ℤ/n)ˣ`: the residue `p mod n`. -/
def frobUnit (p n : ℕ) (h : p.Coprime n) : (ZMod n)ˣ := ZMod.unitOfCoprime p h

/-- **Factor-degree law over `𝔽_p`.**  Every irreducible factor of `Φₙ` in `𝔽_p[X]` has degree
equal to the order of the Frobenius class `p mod n`. -/
theorem cyclotomic_factor_degree (p n : ℕ) [Fact p.Prime] (h : p.Coprime n)
    {P : (ZMod p)[X]} (hP : P ∈ normalizedFactors (cyclotomic n (ZMod p))) :
    P.natDegree = orderOf (frobUnit p n h) := by
  have hK : Fintype.card (ZMod p) = p ^ 1 := by simp [ZMod.card]
  rw [natDegree_of_mem_normalizedFactors_cyclotomic hK h hP]
  congr 1
  ext
  simp [frobUnit]

/-- **The full factor-degree pattern.**  For `p ∤ n`, the multiset of degrees of the monic
irreducible factors of `Φₙ` over `𝔽_p` is `[t, t, …, t]` with `φ(n)/t` entries, where
`t = ord_n(p)`.  (For `n = 11`: `[1¹⁰]`, `[2⁵]`, `[5,5]`, `[10]`.) -/
theorem cyclotomic_factor_pattern (p n : ℕ) [Fact p.Prime] (h : p.Coprime n) :
    (normalizedFactors (cyclotomic n (ZMod p))).map natDegree =
      Multiset.replicate (n.totient / orderOf (frobUnit p n h)) (orderOf (frobUnit p n h)) := by
  set t := orderOf (frobUnit p n h) with ht
  set F := normalizedFactors (cyclotomic n (ZMod p)) with hF
  have hall : ∀ b ∈ F.map natDegree, b = t := by
    intro b hb
    obtain ⟨P, hP, rfl⟩ := Multiset.mem_map.mp hb
    exact cyclotomic_factor_degree p n h hP
  have hmap : F.map natDegree = Multiset.replicate F.card t := by
    rw [Multiset.eq_replicate]; exact ⟨by simp, hall⟩
  have hdeg : F.card * t = n.totient := by
    have hprod := prod_normalizedFactors (cyclotomic_ne_zero n (ZMod p))
    have H := natDegree_eq_of_degree_eq (degree_eq_degree_of_associated hprod)
    rw [natDegree_cyclotomic, natDegree_multiset_prod _ (zero_notMem_normalizedFactors _)] at H
    rw [← hF, hmap] at H
    simpa [Multiset.sum_replicate] using H
  have htpos : 0 < t := orderOf_pos _
  rw [hmap, ← hdeg, Nat.mul_div_cancel _ htpos]

/-- **Group-side mirror.**  In any finite group, left multiplication by `g` has every point
of exact period `ord(g)`: its cycles all have length `ord(g)`. -/
theorem mulLeft_minimalPeriod {G : Type*} [Group G] (g x : G) :
    Function.minimalPeriod (g * ·) x = orderOf g := by
  rw [orderOf, Function.minimalPeriod_eq_minimalPeriod_iff]
  intro m
  simp only [Function.IsPeriodicPt, Function.IsFixedPt]
  have key : ∀ y : G, (g * ·)^[m] y = g ^ m * y := by
    intro y
    induction m generalizing y with
    | zero => simp
    | succ k ih =>
      rw [Function.iterate_succ_apply', ih, pow_succ', mul_assoc]
  rw [key, key, mul_one]
  constructor
  · intro hx; simpa using hx
  · intro hg; rw [hg, one_mul]

/-- …and there are exactly `|G| / ord(g)` such cycles (cosets of `⟨g⟩`). -/
theorem zpowers_index_mul_orderOf {G : Type*} [Group G] (g : G) :
    (Subgroup.zpowers g).index * orderOf g = Nat.card G := by
  rw [← Nat.card_zpowers, Subgroup.index_mul_card]

end DegreeTen