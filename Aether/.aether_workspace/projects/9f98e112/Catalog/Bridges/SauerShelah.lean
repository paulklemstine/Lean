import Mathlib

/-! # CatalogBuild.Bridges.SauerShelah

Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12
-/

noncomputable section

/-- The restriction of a family to a subset S -/
def restrictFamily {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (S : Finset α) : Finset (Finset α) :=
  F.image (· ∩ S)

/-- [Section: # CatalogBuild.Bridges.SauerShelah
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12] -/
theorem restrictFamily_idempotent {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (S : Finset α) :
    restrictFamily (restrictFamily F S) S = restrictFamily F S := by
  ext; simp +decide [ restrictFamily ]

/-- [Section: # CatalogBuild.Bridges.SauerShelah
Auto-generated from theorem catalog database.
Domain: Bridges
Declarations: 12] -/
theorem restrictFamily_card_le_pow {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (S : Finset α) :
    (restrictFamily F S).card ≤ 2 ^ S.card := by
  convert Finset.card_le_card ( show F.image ( · ∩ S ) ⊆ S.powerset from ?_ ) using 1;
  · rw [ Finset.card_powerset ];
  · grind

theorem restrict_empty {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (hF : F.Nonempty) :
    restrictFamily F ∅ = {∅} := by
  unfold restrictFamily; aesop;

/-- A family F shatters S if every subset of S appears as a restriction -/
def Shatters' {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (S : Finset α) : Prop :=
  S.powerset ⊆ restrictFamily F S

theorem shatters_mono' {α : Type*} [DecidableEq α]
    {F G : Finset (Finset α)} (h : F ⊆ G) {S : Finset α}
    (hF : Shatters' F S) : Shatters' G S := by
  exact Set.Subset.trans hF ( Finset.image_subset_image h )

theorem shatters_empty' {α : Type*} [DecidableEq α]
    (F : Finset (Finset α)) (hF : F.Nonempty) :
    Shatters' F ∅ := by
  simp +decide [ Shatters' ];
  exact Finset.mem_image.2 ⟨ hF.choose, hF.choose_spec, by simp +decide ⟩

/-- Sum of binomial coefficients up to d -/
def binomialSum (n d : ℕ) : ℕ :=
  ∑ i ∈ Finset.range (d + 1), n.choose i

theorem binomialSum_zero (n : ℕ) : binomialSum n 0 = 1 := by
  simp [binomialSum]

theorem binomialSum_full (n : ℕ) : binomialSum n n = 2 ^ n := by
  rw [ ← Nat.sum_range_choose, binomialSum ]

theorem binomialSum_mono_d {n d₁ d₂ : ℕ} (h : d₁ ≤ d₂) :
    binomialSum n d₁ ≤ binomialSum n d₂ := by
  exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( by linarith ) )

theorem binomialSum_le_pow (n d : ℕ) : binomialSum n d ≤ 2 ^ n := by
  -- We can prove this inequality using the fact that the sum of binomial coefficients up to $d$ is less than or equal to the sum of binomial coefficients up to $n$.
  have h_binom_sum : ∑ i ∈ Finset.range (d + 1), Nat.choose n i ≤ ∑ i ∈ Finset.range (n + 1), Nat.choose n i := by
    by_cases h : d ≤ n;
    · exact Finset.sum_le_sum_of_subset ( Finset.range_mono ( Nat.succ_le_succ h ) );
    · rw [ Finset.sum_subset ( Finset.range_mono ( Nat.succ_le_succ ( le_of_not_ge h ) ) ) fun x hx₁ hx₂ => by rw [ Nat.choose_eq_zero_of_lt ] ; aesop ];
  rw [ ← Nat.sum_range_choose ] ; exact h_binom_sum

end
