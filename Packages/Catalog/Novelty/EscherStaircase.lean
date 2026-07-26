import Mathlib
import Catalog.Cryptography.NoetherianCertification

/-!
# Divisibility staircases and the ascending-chain obstruction

For an integer-valued function `f : ℤ → ℤ`, let `D n` consist of the functions
whose values are all divisible by `2^n`.  The proposed example was described as
an ascending chain.  Its containment direction is in fact the reverse:
`D (n+1) < D n`.  The chain is strictly descending and has zero intersection.

This distinction is structural.  Requiring merely that zero belong to every
ideal adds no condition at all, since every ideal contains zero.  If instead an
“Escher staircase” means an infinite strictly ascending chain, the usual
ascending-chain condition rules it out in every Noetherian ring, including
finite-variable polynomial rings and discrete valuation rings.

The results below isolate both facts: a strict divisibility filtration with
trivial intersection, and the Noetherian obstruction imported from the existing
ascending-chain certification theory.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Divisibility by increasing powers of two might produce
an infinite ascending ideal staircase, and a dimension-like height might measure
its length.  Bolder variants predicted such a staircase in every non-Noetherian
ring and assigned finite-variable polynomial rings a height equal to dimension.

Experiment (Experimenter): The containment arrows were tested directly using
constant functions.  Divisibility by `2^(n+1)` implies divisibility by `2^n`,
while the constant function `2^n` witnesses strictness.  Divisibility by every
power forces every value to vanish.

Analysis (Analyst): The advertised family is a separated descending filtration,
not an ascending chain.  Moreover, common membership of the zero polynomial is
a universal property of ideals and therefore cannot create a loop.  Krull
height concerns chains of prime ideals, whereas the proposed staircase concerns
arbitrary ideals; these are different invariants.

Critique (Critic): The polynomial-ring and discrete-valuation-ring claims were
checked against the ascending-chain condition.  Both classes are Noetherian in
the stated finite-variable setting, so neither admits an infinite strict
ascending ideal chain.  No claim about the full ring of integer-valued
polynomials is inferred from the larger function ring without an explicit
transfer argument.

Synthesis (Principal Investigator): The surviving phenomenon is reformulated as
a strict, separated divisibility filtration.  The false ascending interpretation
is replaced by a general theorem excluding infinite strict ascent in Noetherian
rings.
-- !-- Lab Notes -- !--
-/

namespace Catalog.Novelty.EscherStaircase

/-- The ideal of integer-valued functions pointwise divisible by `2^n`. -/
def divisibilityIdeal (n : ℕ) : Ideal (ℤ → ℤ) where
  carrier := {f | ∀ z, (2 : ℤ) ^ n ∣ f z}
  zero_mem' := fun _ => dvd_zero _
  add_mem' := fun hf hg z => dvd_add (hf z) (hg z)
  smul_mem' := by
    intro a f hf z
    exact dvd_mul_of_dvd_right (hf z) (a z)

/-
Increasing the exponent reverses containment of the divisibility ideals.
-/
lemma divisibilityIdeal_antitone : Antitone divisibilityIdeal := by
  exact fun m n hmn => fun f hf => fun z => dvd_trans ( pow_dvd_pow _ hmn ) ( hf z )

/-
The constant function `2^n` lies on level `n`.
-/
lemma pow_two_mem_divisibilityIdeal (n : ℕ) :
    (fun _ : ℤ => (2 : ℤ) ^ n) ∈ divisibilityIdeal n := by
  exact fun _ => dvd_rfl

/-
The constant function `2^n` does not lie on the next level.
-/
lemma pow_two_not_mem_next_divisibilityIdeal (n : ℕ) :
    (fun _ : ℤ => (2 : ℤ) ^ n) ∉ divisibilityIdeal (n + 1) := by
  norm_num [ divisibilityIdeal ];
  exact_mod_cast Nat.not_dvd_of_pos_of_lt ( pow_pos ( by decide ) _ ) ( pow_lt_pow_right₀ ( by decide ) ( Nat.lt_succ_self _ ) )

/-
The powers-of-two filtration is strictly descending at every step.
-/
theorem divisibilityIdeal_strictly_descends (n : ℕ) :
    divisibilityIdeal (n + 1) < divisibilityIdeal n := by
  refine' lt_of_le_of_ne _ _;
  · exact divisibilityIdeal_antitone n.le_succ;
  · exact fun h => pow_two_not_mem_next_divisibilityIdeal n ( h ▸ pow_two_mem_divisibilityIdeal n )

/-
An integer divisible by every power of two is zero.
-/
lemma eq_zero_of_two_pow_dvd_all {x : ℤ} (h : ∀ n : ℕ, (2 : ℤ) ^ n ∣ x) : x = 0 := by
  contrapose! h;
  -- Let $n$ be a natural number such that $2^n > |x|$.
  obtain ⟨n, hn⟩ : ∃ n : ℕ, 2 ^ n > |x| := by
    exact pow_unbounded_of_one_lt _ one_lt_two;
  exact ⟨ n, fun h' => hn.not_ge <| Int.le_of_dvd ( abs_pos.mpr h ) <| by simpa using h' ⟩

/-
The intersection of all levels of the divisibility filtration is zero.
-/
theorem iInf_divisibilityIdeal_eq_bot :
    ⨅ n : ℕ, divisibilityIdeal n = ⊥ := by
  ext f;
  simp +decide [ divisibilityIdeal ];
  exact ⟨ fun h => funext fun z => eq_zero_of_two_pow_dvd_all fun n => h n z, fun h => by simp +decide [ h ] ⟩

/-
Membership in every level characterizes the zero function.
-/
theorem mem_all_divisibilityIdeals_iff (f : ℤ → ℤ) :
    (∀ n : ℕ, f ∈ divisibilityIdeal n) ↔ f = 0 := by
  constructor <;> intro h <;> simp_all +decide [ funext_iff, divisibilityIdeal ];
  exact fun z => eq_zero_of_two_pow_dvd_all fun n => h n z

/-- In a Noetherian ring, no infinite strictly ascending ideal chain exists.
This specializes the existing catalog theorem to the ideal order and records the
precise obstruction to the proposed ascending staircase. -/
theorem no_escher_ascent_in_noetherian_ring {R : Type*} [CommRing R]
    [IsNoetherianRing R] (chain : ℕ → Ideal R) (hmono : Monotone chain) :
    ¬ ∀ n, chain n < chain (n + 1) := by
  intro hstrict
  obtain ⟨N, hN⟩ := (monotone_stabilizes_iff_noetherian.mpr
    (inferInstance : IsNoetherian R R)) ⟨chain, hmono⟩
  have heq : chain N = chain (N + 1) := hN (N + 1) (Nat.le_succ N)
  exact (hstrict N).ne heq

/-
Finite-variable polynomial rings over a field admit no infinite strict
ascending chain of ideals.  Thus Krull dimension cannot be identified with the
length of such a chain.
-/
theorem no_escher_ascent_in_finite_polynomial_ring
    (k : Type*) [Field k] (m : ℕ)
    (chain : ℕ → Ideal (MvPolynomial (Fin m) k)) (hmono : Monotone chain) :
    ¬ ∀ n, chain n < chain (n + 1) := by
  convert no_escher_ascent_in_noetherian_ring chain hmono

end Catalog.Novelty.EscherStaircase