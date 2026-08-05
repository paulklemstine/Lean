/-
# Consequences of the species / exponential-generating-series bridge

Building on `Bridges.SpeciesAnalyticBridge`, we exploit the fact that
`egf : Species → ℚ⟦X⟧` turns `+`, `*` and the derivative of species into the
corresponding operations on power series, and that it is injective on counting
sequences.  This lets one transfer facts in both directions:

* combinatorics ⟹ analysis: the species `E^k` of `k`-colourings gives
  `exp(X)^k = exp(kX)`;
* analysis ⟹ combinatorics: the Leibniz rule for formal power series gives
  the combinatorial product rule for the derivative of a species.
-/
import Bridges.SpeciesAnalyticBridge

noncomputable section

namespace SpeciesEGF

open scoped BigOperators
open PowerSeries

namespace Species

variable (F G : Species)

/-! ## Powers of a species -/

/-- The `k`-th power of a species. -/
def pow (F : Species) : ℕ → Species
  | 0 => one
  | (k + 1) => F.mul (F.pow k)

@[simp] theorem pow_zero : F.pow 0 = one := rfl

@[simp] theorem pow_succ (k : ℕ) : F.pow (k + 1) = F.mul (F.pow k) := rfl

/-- The exponential generating series of a power of a species is the corresponding
power of its exponential generating series. -/
theorem egf_pow (k : ℕ) : (F.pow k).egf = F.egf ^ k := by
  induction k with
  | zero => simp [egf_one]
  | succ k ih => rw [pow_succ, egf_mul, ih, pow_succ']

/-- An `E^k`-structure on `A` is a partition of `A` into `k` (possibly empty) labelled
blocks, i.e. a function `A → Fin k`; there are `kⁿ` of them. -/
theorem card_set_pow (k n : ℕ) : (set.pow k).card n = k ^ n := by
  induction k generalizing n with
  | zero =>
      match n with
      | 0 => simp
      | (n + 1) => simp
  | succ k ih =>
      rw [pow_succ, card_mul]
      have : ∀ j ∈ Finset.range (n + 1),
          n.choose j * set.card j * (set.pow k).card (n - j) = 1 ^ j * k ^ (n - j) * n.choose j := by
        intro j _
        rw [card_set, ih]
        ring
      rw [Finset.sum_congr rfl this]
      have h := add_pow (1 : ℕ) k n
      simp only [Nat.cast_id] at h
      rw [← h]
      ring

/-- **`exp(X)^k = ∑ kⁿ Xⁿ/n!`**: read off from the species of `k`-colourings. -/
theorem coeff_exp_pow (k n : ℕ) :
    coeff n ((PowerSeries.exp ℚ) ^ k) = (k : ℚ) ^ n / n.factorial := by
  have h := congrArg (coeff n) (egf_pow set k)
  rw [egf_set] at h
  rw [← h, coeff_egf, card_set_pow]
  push_cast
  ring

/-- **`exp(X)^k = exp(kX)`**, obtained from the combinatorics of colourings. -/
theorem exp_pow_eq_rescale (k : ℕ) :
    (PowerSeries.exp ℚ) ^ k = PowerSeries.rescale (k : ℚ) (PowerSeries.exp ℚ) := by
  ext n
  rw [coeff_exp_pow, PowerSeries.coeff_rescale, PowerSeries.coeff_exp]
  simp [div_eq_mul_inv]

/-! ## Transfer from analysis back to combinatorics -/

/-- **Leibniz rule for species**, deduced from the Leibniz rule for formal power series:
the derivative of a product of species counts as the sum of the two "partial derivative"
species. -/
theorem card_deriv_mul (n : ℕ) :
    (F.mul G).deriv.card n = (F.deriv.mul G).card n + (F.mul G.deriv).card n := by
  have h : (F.mul G).deriv.egf = ((F.deriv.mul G).add (F.mul G.deriv)).egf := by
    rw [egf_deriv, egf_add, egf_mul, egf_mul, egf_mul, egf_deriv, egf_deriv,
      Derivation.leibniz]
    simp [smul_eq_mul]
    ring
  have h2 := (egf_eq_iff _ _).1 h n
  rwa [card_add] at h2

/-- Commutativity of the species product at the level of counting sequences,
obtained from commutativity of `ℚ⟦X⟧`. -/
theorem card_mul_comm (n : ℕ) : (F.mul G).card n = (G.mul F).card n := by
  refine (egf_eq_iff _ _).1 ?_ n
  rw [egf_mul, egf_mul, mul_comm]

/-- The species `1` is a unit for the product, at the level of counting sequences. -/
theorem card_mul_one (n : ℕ) : (F.mul one).card n = F.card n := by
  refine (egf_eq_iff _ _).1 ?_ n
  rw [egf_mul, egf_one, mul_one]

/-- Associativity of the species product at the level of counting sequences. -/
theorem card_mul_assoc (H : Species) (n : ℕ) :
    ((F.mul G).mul H).card n = (F.mul (G.mul H)).card n := by
  refine (egf_eq_iff _ _).1 ?_ n
  rw [egf_mul, egf_mul, egf_mul, egf_mul, mul_assoc]

/-! ## Concrete counting identities -/

/-- Vandermonde-style identity coming from `E^j · E^k = E^(j+k)`. -/
theorem sum_choose_mul_pow (j k n : ℕ) :
    ∑ i ∈ Finset.range (n + 1), n.choose i * j ^ i * k ^ (n - i) = (j + k) ^ n := by
  have h : ((set.pow j).mul (set.pow k)).card n = (j + k) ^ n := by
    have : ((set.pow j).mul (set.pow k)).egf = (set.pow (j + k)).egf := by
      rw [egf_mul, egf_pow, egf_pow, egf_pow, pow_add]
    rw [(egf_eq_iff _ _).1 this n, card_set_pow]
  rw [card_mul] at h
  rw [← h]
  refine Finset.sum_congr rfl fun i _ => ?_
  rw [card_set_pow, card_set_pow]

/-- The number of pairs (subset, permutation of the subset) of an `n`-set,
i.e. the number of partial injections counted by `E · S`. -/
theorem card_set_mul_perm (n : ℕ) :
    (set.mul perm).card n = ∑ k ∈ Finset.range (n + 1), n.choose k * (n - k).factorial := by
  rw [card_mul]
  refine Finset.sum_congr rfl fun k _ => ?_
  rw [card_set, card_perm]
  ring

/-- Pointing twice: `X · (X · F')' ` counts `F`-structures with two marked points
(with repetition allowed), i.e. `n²`-many for each `F`-structure. -/
theorem card_pointing_pointing (n : ℕ) :
    (sing.mul (sing.mul F.deriv).deriv).card n = n * (n * F.card n) := by
  rw [card_pointing, card_pointing]

/-! ## Every counting sequence comes from a species -/

/-- The "structureless" species with a prescribed number of structures on each finite
set: `a n` structures on an `n`-element set. -/
def ofSequence (a : ℕ → ℕ) : Species where
  obj A := Fin (a (Nat.card A))
  map e x := Fin.cast (congrArg a (Nat.card_congr e)) x
  map_refl _ := Fin.ext rfl
  map_trans _ _ _ := Fin.ext rfl
  finite _ _ := inferInstance

@[simp] theorem card_ofSequence (a : ℕ → ℕ) (n : ℕ) : (ofSequence a).card n = a n := by
  have h : Nat.card (Fin n) = n := by simp
  rw [card]
  show Nat.card (Fin (a (Nat.card (Fin n)))) = a n
  rw [h, Nat.card_eq_fintype_card, Fintype.card_fin]

/-- **The counting sequences of species are exactly the sequences of natural numbers**:
the invariant `Species.card` is surjective. -/
theorem exists_species_card (a : ℕ → ℕ) : ∃ F : Species, ∀ n, F.card n = a n :=
  ⟨ofSequence a, card_ofSequence a⟩

/-- Consequently every power series with coefficients `a n / n!`, `a n : ℕ`, is the
exponential generating series of a species. -/
theorem exists_species_egf (a : ℕ → ℕ) :
    ∃ F : Species, F.egf = PowerSeries.mk fun n => (a n : ℚ) / n.factorial := by
  refine ⟨ofSequence a, ?_⟩
  ext n
  rw [coeff_egf, card_ofSequence, PowerSeries.coeff_mk]

end Species

end SpeciesEGF