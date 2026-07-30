import Mathlib

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
trivial intersection, and the Noetherian obstruction supplied by the usual
ascending-chain condition.  They first establish the phenomenon for all
integer-valued functions and then transfer it to the actual ring `Int(ℤ)` of
integer-valued rational polynomials.

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
namespace Catalog.Novelty.EscherStaircase

/-! ## The filtration inside the actual ring of integer-valued polynomials -/

/-- The subring of rational polynomials taking integer values at every integer. -/
def IntValuedPolynomial : Subring (Polynomial ℚ) where
  carrier := {p | ∀ z : ℤ, ∃ a : ℤ, p.eval (z : ℚ) = (a : ℚ)}
  zero_mem' := fun _ => ⟨0, by simp⟩
  one_mem' := fun _ => ⟨1, by simp⟩
  add_mem' := by
    rintro p q hp hq z
    obtain ⟨a, ha⟩ := hp z
    obtain ⟨b, hb⟩ := hq z
    exact ⟨a + b, by simp [ha, hb]⟩
  mul_mem' := by
    rintro p q hp hq z
    obtain ⟨a, ha⟩ := hp z
    obtain ⟨b, hb⟩ := hq z
    exact ⟨a * b, by simp [ha, hb]⟩
  neg_mem' := by
    rintro p hp z
    obtain ⟨a, ha⟩ := hp z
    exact ⟨-a, by simp [ha]⟩

abbrev IntZ := IntValuedPolynomial

noncomputable section

/-- The integer represented by the rational value of an integer-valued polynomial. -/
def IntZ.integerValue (p : IntZ) (z : ℤ) : ℤ := Classical.choose (p.2 z)

lemma IntZ.coe_integerValue (p : IntZ) (z : ℤ) :
    p.1.eval (z : ℚ) = (IntZ.integerValue p z : ℚ) :=
  Classical.choose_spec (p.2 z)

/-- Evaluation of an integer-valued polynomial at an integer, as a ring map to `ℤ`. -/
def IntZ.evalRingHom (z : ℤ) : IntZ →+* ℤ where
  toFun p := IntZ.integerValue p z
  map_one' := by
    apply (Int.cast_injective : Function.Injective (fun x : ℤ => (x : ℚ)))
    rw [← IntZ.coe_integerValue]
    simp
  map_zero' := by
    apply (Int.cast_injective : Function.Injective (fun x : ℤ => (x : ℚ)))
    rw [← IntZ.coe_integerValue]
    simp
  map_add' p q := by
    apply (Int.cast_injective : Function.Injective (fun x : ℤ => (x : ℚ)))
    rw [Int.cast_add, ← IntZ.coe_integerValue p z,
      ← IntZ.coe_integerValue q z, ← IntZ.coe_integerValue (p + q) z]
    simp
  map_mul' p q := by
    apply (Int.cast_injective : Function.Injective (fun x : ℤ => (x : ℚ)))
    rw [Int.cast_mul, ← IntZ.coe_integerValue p z,
      ← IntZ.coe_integerValue q z, ← IntZ.coe_integerValue (p * q) z]
    simp

lemma IntZ.evalRingHom_apply (p : IntZ) (z : ℤ) :
    IntZ.evalRingHom z p = IntZ.integerValue p z := rfl

/-- The ideal of integer-valued polynomials whose values are divisible by `2^n`. -/
def intZDivisibilityIdeal (n : ℕ) : Ideal IntZ :=
  ⨅ z : ℤ, Ideal.comap (IntZ.evalRingHom z) (Ideal.span {(2 : ℤ) ^ n})

lemma mem_intZDivisibilityIdeal_iff (p : IntZ) (n : ℕ) :
    p ∈ intZDivisibilityIdeal n ↔
      ∀ z : ℤ, (2 : ℤ) ^ n ∣ IntZ.integerValue p z := by
  simp [intZDivisibilityIdeal, Ideal.mem_span_singleton, IntZ.evalRingHom_apply]

/-- The actual integer-valued-polynomial filtration reverses containment. -/
theorem intZDivisibilityIdeal_antitone : Antitone intZDivisibilityIdeal := by
  intro m n hmn p hp
  rw [mem_intZDivisibilityIdeal_iff] at hp ⊢
  exact fun z => dvd_trans (pow_dvd_pow (2 : ℤ) hmn) (hp z)

/-- A constant integer, viewed as an integer-valued rational polynomial. -/
def IntZ.constant (a : ℤ) : IntZ :=
  ⟨Polynomial.C (a : ℚ), fun _ => ⟨a, by simp⟩⟩

lemma IntZ.integerValue_constant (a : ℤ) (z : ℤ) :
    IntZ.integerValue (IntZ.constant a) z = a := by
  apply (Int.cast_injective : Function.Injective (fun x : ℤ => (x : ℚ)))
  rw [← IntZ.coe_integerValue]
  simp [IntZ.constant]

lemma intZ_two_pow_mem (n : ℕ) :
    IntZ.constant ((2 : ℤ) ^ n) ∈ intZDivisibilityIdeal n := by
  rw [mem_intZDivisibilityIdeal_iff]
  intro z
  rw [IntZ.integerValue_constant]

lemma intZ_two_pow_not_mem_next (n : ℕ) :
    IntZ.constant ((2 : ℤ) ^ n) ∉ intZDivisibilityIdeal (n + 1) := by
  rw [mem_intZDivisibilityIdeal_iff]
  push_neg
  refine ⟨0, ?_⟩
  rw [IntZ.integerValue_constant]
  exact_mod_cast Nat.not_dvd_of_pos_of_lt (pow_pos (by decide) n)
    (pow_lt_pow_right₀ (by decide) (Nat.lt_succ_self n))

/-- At every level, the ideal at the next exponent is strictly smaller. -/
theorem intZDivisibilityIdeal_strictly_descends (n : ℕ) :
    intZDivisibilityIdeal (n + 1) < intZDivisibilityIdeal n := by
  refine lt_of_le_of_ne (intZDivisibilityIdeal_antitone n.le_succ) ?_
  intro h
  exact intZ_two_pow_not_mem_next n (h ▸ intZ_two_pow_mem n)

lemma IntZ.eq_zero_of_integerValue_eq_zero (p : IntZ)
    (h : ∀ z : ℤ, IntZ.integerValue p z = 0) : p = 0 := by
  apply Subtype.ext
  apply Polynomial.eq_zero_of_infinite_isRoot
  have hrange : Set.range (fun z : ℤ => (z : ℚ)) ⊆ {x | p.1.IsRoot x} := by
    rintro x ⟨z, rfl⟩
    change p.1.eval (z : ℚ) = 0
    rw [IntZ.coe_integerValue, h]
    simp
  exact (Set.infinite_range_of_injective
    (Int.cast_injective : Function.Injective (fun z : ℤ => (z : ℚ)))).mono hrange

/-- The filtration in `Int(ℤ)` never stabilizes.  This is the valid
“infinite-height” conclusion, with the containment direction corrected. -/
theorem intZDivisibilityIdeal_never_stabilizes :
    ¬ ∃ N : ℕ, ∀ n, N ≤ n →
      intZDivisibilityIdeal n = intZDivisibilityIdeal N := by
  rintro ⟨N, hN⟩
  have heq : intZDivisibilityIdeal (N + 1) = intZDivisibilityIdeal N :=
    hN (N + 1) N.le_succ
  exact (intZDivisibilityIdeal_strictly_descends N).ne heq

/-- The intersection of all levels in `Int(ℤ)` is the zero ideal. -/
theorem iInf_intZDivisibilityIdeal_eq_bot :
    ⨅ n : ℕ, intZDivisibilityIdeal n = ⊥ := by
  apply le_antisymm
  · intro p hp
    rw [Ideal.mem_bot]
    apply IntZ.eq_zero_of_integerValue_eq_zero
    intro z
    apply eq_zero_of_two_pow_dvd_all
    intro n
    exact (mem_intZDivisibilityIdeal_iff p n).mp
      (show p ∈ intZDivisibilityIdeal n from (Ideal.mem_iInf.mp hp) n) z
  · exact bot_le

/-- Membership in every level of the actual `Int(ℤ)` filtration characterizes zero. -/
theorem mem_all_intZDivisibilityIdeals_iff (p : IntZ) :
    (∀ n : ℕ, p ∈ intZDivisibilityIdeal n) ↔ p = 0 := by
  rw [← Ideal.mem_iInf]
  rw [iInf_intZDivisibilityIdeal_eq_bot, Ideal.mem_bot]

end

end Catalog.Novelty.EscherStaircase