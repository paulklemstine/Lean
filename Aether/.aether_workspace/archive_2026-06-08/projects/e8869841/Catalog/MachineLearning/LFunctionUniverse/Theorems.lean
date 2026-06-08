/-
# Countability, Enumeration, and Complexity Theorems for Discrete L-Data

This file contains the main theorems establishing that the universe of
finite-description L-data is countable, effectively encodable, and
admits finite complexity strata.

## Main Results

1. `countable_FiniteDescriptionLData` — countability of L-data.
2. `countable_FinitelyRamifiedLData` — countability of simplified variant.
3. `finite_bounded_descriptionLength` — finiteness of bounded-complexity strata.
4. `surj_enumerateLData` — enumeration completeness.
-/

import Speculative.LFunctionUniverse.Defs

open Set Function

/-! ## Injection into a Sigma Type

The key proof technique is to construct an injection from `FiniteDescriptionLData Γ α`
into a sigma type of countable components. -/

/-- Injection from `FiniteDescriptionLData` into a sigma/product type. -/
def FiniteDescriptionLData.toSigma (x : FiniteDescriptionLData Γ α) :
    (d : ℕ) × (c : ℕ) × Γ × DiscreteEulerFactor α d ×
    (n : ℕ) × (Fin n → ℕ) × (Fin n → DiscreteEulerFactor α d) :=
  ⟨x.degree, x.conductor, x.rootNumber, x.unramifiedTemplate,
   x.numBadPrimes, x.badPrimeList, x.ramifiedFactors⟩

/-
The injection `toSigma` is injective.
-/
theorem FiniteDescriptionLData.toSigma_injective :
    Injective (@FiniteDescriptionLData.toSigma Γ α) := by
  intro x y hxy;
  cases x ; cases y ; simp_all +decide [ FiniteDescriptionLData.toSigma ];
  cases hxy ; aesop

/-
**Main Theorem 1**: The type of finite-description L-data over countable types
    is countable.
-/
theorem countable_FiniteDescriptionLData
    {Γ α : Type*}
    [Countable Γ] [Countable α] :
    Countable (FiniteDescriptionLData Γ α) := by
  exact ( FiniteDescriptionLData.toSigma_injective.countable )

/-- Injection from `FinitelyRamifiedLData` into a sigma/product type. -/
def FinitelyRamifiedLData.toSigma (x : FinitelyRamifiedLData Γ α) :
    (d : ℕ) × (c : ℕ) × Γ × DiscreteEulerFactor α d ×
    (n : ℕ) × (Fin n → DiscreteEulerFactor α d) :=
  ⟨x.degree, x.conductor, x.rootNumber, x.unramifiedTemplate,
   x.numRamified, x.ramifiedFactor⟩

/-
The injection for `FinitelyRamifiedLData` is injective.
-/
theorem FinitelyRamifiedLData.toSigma_injective :
    Injective (@FinitelyRamifiedLData.toSigma Γ α) := by
  intro x y hxy;
  injection hxy;
  cases x ; cases y ; aesop

/-
**Main Theorem 2**: Finitely ramified L-data over countable types is countable.
-/
theorem countable_FinitelyRamifiedLData
    {Γ α : Type*}
    [Countable Γ] [Countable α] :
    Countable (FinitelyRamifiedLData Γ α) := by
  convert @FinitelyRamifiedLData.toSigma_injective Γ α |> fun h => h.countable

/-! ## Description Length Bounds and Finiteness -/

/-
For any bound `B`, there are only finitely many triples of naturals
    with components summing to at most `B`.
-/
theorem finite_nat_tuples_bounded (B : ℕ) :
    Set.Finite {t : ℕ × ℕ × ℕ | t.1 + t.2.1 + t.2.2 + 1 ≤ B} := by
  exact Set.finite_iff_bddAbove.mpr ⟨ ⟨ B, B, B ⟩, by rintro ⟨ a, b, c ⟩ ( h : a + b + c + 1 ≤ B ) ; exact ⟨ by linarith, by linarith, by linarith ⟩ ⟩

/-
**Main Theorem 3**: For any bound `B`, there are only finitely many
    finite-description L-data with description length at most `B`,
    when the coefficient and root number types are finite.
-/
theorem finite_bounded_descriptionLength
    [Fintype Γ] [Fintype α]
    (B : ℕ) :
    Set.Finite {x : FiniteDescriptionLData Γ α | descriptionLength x ≤ B} := by
  -- Since `descriptionLength x = x.degree + x.conductor + x.numBadPrimes + x.maxBadPrime + 1 ≤ B`, all four global parameters (degree, conductor, numBadPrimes, maxBadPrime) are bounded by B.
  have h_bounded : ∀ x : FiniteDescriptionLData Γ α, descriptionLength x ≤ B → x.degree ≤ B ∧ x.conductor ≤ B ∧ x.numBadPrimes ≤ B ∧ x.maxBadPrime ≤ B := by
    unfold descriptionLength at *; omega;
  -- For fixed d, c, n, with d,c,n ≤ B, the type {x : FiniteDescriptionLData Γ α | x.degree = d ∧ x.conductor = c ∧ x.numBadPrimes = n ∧ ∀ i, x.badPrimeList i ≤ B} is finite.
  have h_finite_subtype (d c n : ℕ) (hd : d ≤ B) (hc : c ≤ B) (hn : n ≤ B) :
    Set.Finite {x : FiniteDescriptionLData Γ α | x.degree = d ∧ x.conductor = c ∧ x.numBadPrimes = n ∧ ∀ i, x.badPrimeList i ≤ B} := by
      have h_finite : Set.Finite {x : Γ × (DiscreteEulerFactor α d) × (Fin n → ℕ) × (Fin n → DiscreteEulerFactor α d) | ∀ i, x.2.2.1 i ≤ B} := by
        have h_finite : Set.Finite {x : Fin n → ℕ | ∀ i, x i ≤ B} := by
          exact Set.finite_iff_bddAbove.mpr ⟨ fun _ => B, fun x hx => hx ⟩;
        exact Set.Finite.subset ( Set.Finite.prod ( Set.toFinite ( Set.univ : Set Γ ) ) ( Set.Finite.prod ( Set.toFinite ( Set.univ : Set ( DiscreteEulerFactor α d ) ) ) ( h_finite.prod ( Set.toFinite ( Set.univ : Set ( Fin n → DiscreteEulerFactor α d ) ) ) ) ) ) fun x hx => by aesop;
      refine Set.Finite.subset ( h_finite.image fun x => FiniteDescriptionLData.mk d c x.1 x.2.1 n x.2.2.1 x.2.2.2 ) ?_ ; intro x ; aesop;
  refine' Set.Finite.subset ( Set.Finite.biUnion ( Set.finite_Iic B ) fun d hd => Set.Finite.biUnion ( Set.finite_Iic B ) fun c hc => Set.Finite.biUnion ( Set.finite_Iic B ) fun n hn => h_finite_subtype d c n hd hc hn ) _;
  intro x hx; specialize h_bounded x hx; simp_all +decide [ Set.subset_def ] ;
  unfold FiniteDescriptionLData.maxBadPrime at h_bounded;
  split_ifs at h_bounded <;> simp_all +decide [ Finset.sup'_le_iff ];
  exact fun i => False.elim <| Fin.elim0 <| Fin.castLE ( by simp +decide [ * ] ) i

/-! ## Effective Enumeration -/

/-- `Encodable` instance for `FiniteDescriptionLData`. -/
noncomputable instance encodable_FiniteDescriptionLData
    [Encodable Γ] [Encodable α] :
    Encodable (FiniteDescriptionLData Γ α) := by
  have : Countable (FiniteDescriptionLData Γ α) := countable_FiniteDescriptionLData
  exact Encodable.ofCountable _

/-- Canonical enumeration of finite-description L-data. -/
noncomputable def enumerateLData [Encodable Γ] [Encodable α] :
    ℕ → Option (FiniteDescriptionLData Γ α) :=
  Encodable.decode

/-
**Main Theorem 4**: Every L-datum appears in the canonical enumeration.
-/
theorem surj_enumerateLData
    [Encodable Γ] [Encodable α]
    (x : FiniteDescriptionLData Γ α) :
    ∃ n, enumerateLData n = some x := by
  -- By definition of `enumerateLData`, there exists an `n` such that `Encodable.decode n = some x`.
  obtain ⟨n, hn⟩ : ∃ n, Encodable.decode n = some x := by
    have h_enum : ∀ x : FiniteDescriptionLData Γ α, ∃ n, Encodable.decode n = some x := by
      intro x
      use Encodable.encode x
      simp [Encodable.encodek]
    exact h_enum x;
  -- Since `Encodable.decode n = some x`, we can conclude that `enumerateLData n = some x` by definition.
  use n
  exact hn

/-! ## Cross-Domain: Information-Theoretic Stratification -/

/-
Description length bounds the degree.
-/
theorem degree_le_of_descriptionLength_le
    (x : FiniteDescriptionLData Γ α) (B : ℕ) (h : descriptionLength x ≤ B) :
    x.degree ≤ B := by
  exact le_trans ( by unfold descriptionLength; omega ) h

/-
Description length bounds the conductor.
-/
theorem conductor_le_of_descriptionLength_le
    (x : FiniteDescriptionLData Γ α) (B : ℕ) (h : descriptionLength x ≤ B) :
    x.conductor ≤ B := by
  unfold descriptionLength at h; linarith;

/-
Description length bounds the number of bad primes.
-/
theorem numBadPrimes_le_of_descriptionLength_le
    (x : FiniteDescriptionLData Γ α) (B : ℕ) (h : descriptionLength x ≤ B) :
    x.numBadPrimes ≤ B := by
  unfold descriptionLength at h; linarith;

/-
Monotonicity of the complexity filtration.
-/
theorem descriptionLength_stratum_mono (B₁ B₂ : ℕ) (h : B₁ ≤ B₂) :
    {x : FiniteDescriptionLData Γ α | descriptionLength x ≤ B₁} ⊆
    {x : FiniteDescriptionLData Γ α | descriptionLength x ≤ B₂} := by
  exact fun x hx => le_trans hx h

/-
The full L-data type is the union of its finite complexity strata.
-/
theorem ldata_eq_union_strata :
    (Set.univ : Set (FiniteDescriptionLData Γ α)) =
    ⋃ B : ℕ, {x | descriptionLength x ≤ B} := by
  exact Set.ext fun x => ⟨ fun _ => Set.mem_iUnion.2 ⟨ descriptionLength x, by simp +decide ⟩, fun _ => trivial ⟩