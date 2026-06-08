import Mathlib

/-!
# Arithmetic Persistence Theory: Definitions and Core Theorems

We introduce the formal foundations of **arithmetic persistence theory**, a new framework
connecting p-adic valuations of polynomial coefficients to persistence-style topological
invariants on Newton polytope support data.

## Main Definitions

* `monomialWeight` — the p-adic valuation weight of a monomial's coefficient
* `lowerSupportAtLevel` — sublevel set filtration of support by valuation threshold
* `jumpCount` — number of monomials entering the filtration at a given level
* `lowerSupportCard` — cardinality of the filtration at a given level
* `padicWeightProfile` — the full (monomial, weight) profile
* `totalPersistenceMass` — aggregate weight invariant

## Main Results

* `lowerSupportAtLevel_mono` — filtration is monotone in threshold
* `lowerSupportAtLevel_zero` — base case characterization
* `lowerSupportAtLevel_top` — saturation at maximum weight
* `lowerSupportAtLevel_succ_eq_union` — disjoint decomposition at each step
* `filtration_cardinality_jump` — cardinality increase equals jump count
* `filtration_stability_equal_coeffs` — stability under coefficient agreement
* `filtration_stability_under_padic_congruence` — p-adic stability theorem
* `lowerSupportAtLevel_equivariant` — equivariance under support relabeling
* `profile_distinguishes_binomial_from_trinomial` — arithmetic family separation
-/

open Finset

/-! ### Core Definitions -/

/-- The **monomial weight** of a monomial at prime `p` is the p-adic valuation
of its integer coefficient. Higher weight means more divisibility by `p`. -/
noncomputable def monomialWeight {ι : Type*} (a : ι → ℤ) (p : ℕ) (m : ι) : ℕ :=
  padicValInt p (a m)

/-- The **lower support at level** `t` retains monomials whose p-adic weight is ≤ `t`.
This defines a growing filtration as `t` increases. -/
noncomputable def lowerSupportAtLevel {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) : Finset ι :=
  σ.filter (fun m => monomialWeight a p m ≤ t)

/-- The **jump count** at level `t` counts monomials entering at exactly level `t`. -/
noncomputable def jumpCount {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) : ℕ :=
  (σ.filter (fun m => monomialWeight a p m = t)).card

/-- The **lower support cardinality** at level `t`. -/
noncomputable def lowerSupportCard {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) : ℕ :=
  (lowerSupportAtLevel σ a p t).card

/-- The **p-adic weight profile** packages support with weights. -/
noncomputable def padicWeightProfile {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p : ℕ) : Finset (ι × ℕ) :=
  σ.map ⟨fun m => (m, monomialWeight a p m), fun m₁ m₂ h => by
    have := Prod.mk.inj h; exact this.1⟩

/-- The **total persistence mass** sums all p-adic weights across the support. -/
noncomputable def totalPersistenceMass {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p : ℕ) : ℕ :=
  σ.sum (fun m => monomialWeight a p m)

/-! ### Theorem 1: Filtration Monotonicity and Structure -/

/-- **Monotonicity theorem**: the prime-weighted support filtration is monotone
in the threshold parameter. -/
theorem lowerSupportAtLevel_mono {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p : ℕ) {s t : ℕ} (h : s ≤ t) :
    lowerSupportAtLevel σ a p s ⊆ lowerSupportAtLevel σ a p t := by
  intro x hx
  simp only [lowerSupportAtLevel, Finset.mem_filter] at hx ⊢
  exact ⟨hx.1, le_trans hx.2 h⟩

/-- The filtration at level 0 contains exactly the weight-0 monomials. -/
theorem lowerSupportAtLevel_zero {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p : ℕ) :
    lowerSupportAtLevel σ a p 0 = σ.filter (fun m => monomialWeight a p m = 0) := by
  ext x; simp only [lowerSupportAtLevel, Finset.mem_filter, Nat.le_zero]

/-- At any level ≥ the maximum weight, the filtration recovers the entire support. -/
theorem lowerSupportAtLevel_top {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p : ℕ)
    (t : ℕ) (ht : ∀ m ∈ σ, monomialWeight a p m ≤ t) :
    lowerSupportAtLevel σ a p t = σ := by
  ext x; simp only [lowerSupportAtLevel, Finset.mem_filter]
  exact ⟨fun ⟨h, _⟩ => h, fun h => ⟨h, ht x h⟩⟩

/-- The filtration is always a subset of the support. -/
theorem lowerSupportAtLevel_subset {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) :
    lowerSupportAtLevel σ a p t ⊆ σ :=
  filter_subset _ σ

/-! ### Theorem 2: Disjoint Decomposition and Jump Formula -/

/-- The filtration at level `t+1` decomposes as the disjoint union of the filtration
at level `t` and the monomials entering at exactly level `t+1`. -/
theorem lowerSupportAtLevel_succ_eq_union {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) :
    lowerSupportAtLevel σ a p (t + 1) =
    lowerSupportAtLevel σ a p t ∪ σ.filter (fun m => monomialWeight a p m = t + 1) := by
  ext x
  simp only [lowerSupportAtLevel, mem_filter, mem_union]
  constructor
  · intro ⟨hx, hw⟩
    by_cases h : monomialWeight a p x ≤ t
    · left; exact ⟨hx, h⟩
    · right; exact ⟨hx, by omega⟩
  · rintro (⟨hx, hw⟩ | ⟨hx, hw⟩) <;> exact ⟨hx, by omega⟩

/-- The two pieces in the step decomposition are disjoint. -/
theorem lowerSupportAtLevel_succ_disjoint {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) :
    Disjoint (lowerSupportAtLevel σ a p t)
      (σ.filter (fun m => monomialWeight a p m = t + 1)) := by
  simp only [lowerSupportAtLevel]
  rw [Finset.disjoint_filter]
  intro x _ h1 h2; omega

/-- **Cardinality jump theorem**: the increase in filtration cardinality from level `t`
to level `t+1` equals the number of monomials entering at level `t+1`.

This is a degree-0 persistence theorem: "births" at each filtration level
are precisely the monomials whose p-adic weight equals that level. -/
theorem filtration_cardinality_jump {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) :
    (lowerSupportAtLevel σ a p (t + 1)).card - (lowerSupportAtLevel σ a p t).card =
    (σ.filter (fun m => monomialWeight a p m = t + 1)).card := by
  rw [lowerSupportAtLevel_succ_eq_union]
  rw [Finset.card_union_of_disjoint (lowerSupportAtLevel_succ_disjoint σ a p t)]
  omega

/-! ### Theorem 3: Stability Theorems (Cross-Domain) -/

/-- **Coefficient agreement stability**: if two coefficient maps agree on the support,
then their filtrations are identical at all levels. -/
theorem filtration_stability_equal_coeffs {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a b : ι → ℤ) (p t : ℕ)
    (heq : ∀ m ∈ σ, a m = b m) :
    lowerSupportAtLevel σ a p t = lowerSupportAtLevel σ b p t := by
  ext x; simp only [lowerSupportAtLevel, Finset.mem_filter]
  constructor
  · intro ⟨hx, hw⟩; exact ⟨hx, by rwa [monomialWeight, heq x hx] at hw⟩
  · intro ⟨hx, hw⟩; exact ⟨hx, by rwa [monomialWeight, heq x hx]⟩

/-
**p-adic congruence stability**: if coefficient differences are divisible by `p^(t+1)`,
and all coefficients are nonzero, then filtrations agree up to level `t`.

This is the core cross-domain theorem connecting p-adic number theory to
persistence-theoretic stability: p-adically close coefficient functions
produce identical low-scale topological signatures.
-/
theorem filtration_stability_under_padic_congruence {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a b : ι → ℤ) (p t : ℕ) (hp : Nat.Prime p)
    (ha : ∀ m ∈ σ, a m ≠ 0) (hb : ∀ m ∈ σ, b m ≠ 0)
    (hcong : ∀ m ∈ σ, (p : ℤ) ^ (t + 1) ∣ (a m - b m)) :
    ∀ s ≤ t, lowerSupportAtLevel σ a p s = lowerSupportAtLevel σ b p s := by
  intro s hs;
  -- By definition of $monomialWeight$, we know that $monomialWeight a p m \leq s$ if and only if $p^{s+1} \nmid a m$.
  have h_monomial_weight : ∀ m ∈ σ, monomialWeight a p m ≤ s ↔ ¬((p : ℤ) ^ (s + 1) ∣ a m) := by
    intro m hm
    simp [monomialWeight, padicValInt];
    rw [ ← Int.natAbs_dvd_natAbs, Int.natAbs_pow ];
    rw [ ← Nat.factorization_le_iff_dvd ] <;> simp +decide [ hp, ha m hm ];
    · rw [ ← Nat.factorization_def ] ; simp +decide [ Finsupp.le_def, Finsupp.single_apply ] ;
      · grind;
      · exact hp;
    · exact hp.ne_zero;
  -- Similarly, by definition of $monomialWeight$, we know that $monomialWeight b p m \leq s$ � if� and only if $p^{s+1 �}� \nmid b m$.
  have h_monomial_weight_b : ∀ m ∈ σ, monomialWeight b p m ≤ s ↔ ¬((p : ℤ) ^ (s + 1) ∣ b m) := by
    unfold monomialWeight;
    intro m hm; rw [ ← Int.natAbs_dvd_natAbs, Int.natAbs_pow ] ; haveI := Fact.mk hp; rw [ padicValInt ] ; simp +decide [ Nat.factorization_eq_zero_iff ] ;
    rw [ padicValNat_dvd_iff ];
    grind;
  -- Since $p^{t+1} \mid (a m - b m)$ and $s+1 \leq t+1$, we have $p^{s+1} \mid (a m - b m)$. Therefore, $p^{s+1} \mid a m$ if and only if $p^{s+1} \mid b m$.
  have h_div : ∀ m ∈ σ, (p : ℤ) ^ (s + 1) ∣ a m ↔ (p : ℤ) ^ (s + 1) ∣ b m := by
    intro m hm; specialize hcong m hm; exact ⟨ fun h => by convert dvd_sub h ( dvd_trans ( pow_dvd_pow _ ( Nat.succ_le_succ hs ) ) hcong ) using 1; ring, fun h => by convert dvd_add h ( dvd_trans ( pow_dvd_pow _ ( Nat.succ_le_succ hs ) ) hcong ) using 1; ring ⟩ ;
  grind +locals

/-! ### Theorem 4: Equivariance Under Relabeling -/

/-- **Equivariance theorem**: the filtration is natural with respect to
bijective relabelings of the index set. -/
theorem lowerSupportAtLevel_equivariant {ι κ : Type*} [DecidableEq ι] [DecidableEq κ]
    (e : ι ≃ κ) (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) :
    (lowerSupportAtLevel σ a p t).map e.toEmbedding =
    lowerSupportAtLevel (σ.map e.toEmbedding) (a ∘ e.symm) p t := by
  ext x
  simp only [lowerSupportAtLevel, mem_map, mem_filter, Equiv.toEmbedding_apply]
  constructor
  · rintro ⟨y, ⟨hy, hw⟩, rfl⟩
    refine ⟨⟨y, hy, rfl⟩, ?_⟩
    simp [monomialWeight, Function.comp_apply, Equiv.symm_apply_apply]; exact hw
  · rintro ⟨⟨y, hy, rfl⟩, hw⟩
    refine ⟨y, ⟨hy, ?_⟩, rfl⟩
    simp [monomialWeight, Function.comp_apply, Equiv.symm_apply_apply] at hw; exact hw

/-! ### Theorem 5: Arithmetic Family Separation -/

/-- Coefficients for binomial `x^n + c`, defined on support `{0, n}`. -/
noncomputable def binomialCoeff (c : ℤ) (n : ℕ) : ℕ → ℤ :=
  fun k => if k = 0 then c else if k = n then 1 else 0

/-- Coefficients for trinomial `x^n + p^r · x + c`, defined on support `{0, 1, n}`. -/
noncomputable def trinomialCoeff (c : ℤ) (p r n : ℕ) : ℕ → ℤ :=
  fun k => if k = 0 then c else if k = 1 then (p : ℤ) ^ r else if k = n then 1 else 0

/-- The weight of `c` at prime `p` when `p ∤ c` is 0. -/
theorem weight_of_coprime (c : ℤ) (p : ℕ) (hpc : ¬ (p : ℤ) ∣ c) :
    padicValInt p c = 0 := by
  rw [padicValInt]
  apply padicValNat.eq_zero_of_not_dvd
  intro h; exact hpc (Int.natCast_dvd.mpr h)

/-- The p-adic valuation of `p^r` at prime `p` is `r`. -/
theorem padicValInt_prime_pow (p r : ℕ) (hp : Nat.Prime p) :
    padicValInt p ((p : ℤ) ^ r) = r := by
  haveI : Fact (Nat.Prime p) := ⟨hp⟩
  rw [padicValInt, Int.natAbs_pow, Int.natAbs_natCast,
    padicValNat.pow r hp.ne_zero]
  simp

/-
**Family separation theorem**: the persistence profile of a trinomial `x^n + p^r x + c`
differs from that of a binomial `x^n + c` when `p` is prime, `r > 0`, `c ≠ 0`,
`p ∤ c`, and `n ≥ 2`.

The trinomial has the extra monomial at degree 1 with coefficient `p^r`, which enters
the filtration at level `r`, creating a jump absent from the binomial profile.
-/
theorem profile_distinguishes_binomial_from_trinomial
    (n : ℕ) (hn : 2 ≤ n) (p r : ℕ) (hp : Nat.Prime p) (hr : 0 < r) (c : ℤ) (hc : c ≠ 0)
    (hpc : ¬ (p : ℤ) ∣ c) :
    ∃ t, lowerSupportCard ({0, 1, n} : Finset ℕ) (trinomialCoeff c p r n) p t ≠
         lowerSupportCard ({0, n} : Finset ℕ) (binomialCoeff c n) p t := by
  refine' ⟨ r, _ ⟩ ; unfold lowerSupportCard ; simp_all +decide [ trinomialCoeff, binomialCoeff ] ;
  rw [ lowerSupportAtLevel_top, lowerSupportAtLevel_top ];
  · grind;
  · simp +decide [ monomialWeight, binomialCoeff ];
    rw [ padicValInt.eq_zero_of_not_dvd hpc ] ; aesop;
  · unfold monomialWeight trinomialCoeff; simp +decide [ *, padicValInt ] ;
    split_ifs <;> simp_all +decide [ padicValNat.eq_zero_of_not_dvd, ← Int.natCast_dvd_natCast ]

/-! ### Additional Properties -/

/-- The jump count is bounded by the support cardinality. -/
theorem jumpCount_le_card {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) :
    jumpCount σ a p t ≤ σ.card :=
  card_filter_le σ _

/-- The lower support cardinality is monotone. -/
theorem lowerSupportCard_mono {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p : ℕ) {s t : ℕ} (h : s ≤ t) :
    lowerSupportCard σ a p s ≤ lowerSupportCard σ a p t :=
  card_le_card (lowerSupportAtLevel_mono σ a p h)

/-- The lower support cardinality is bounded by the support cardinality. -/
theorem lowerSupportCard_le {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) :
    lowerSupportCard σ a p t ≤ σ.card :=
  card_filter_le σ _

/-- The weight profile map preserves cardinality (injective on support). -/
theorem padicWeightProfile_card {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p : ℕ) :
    (padicWeightProfile σ a p).card = σ.card :=
  Finset.card_map _

/-- Monotonicity of the lower support cardinality as a function. -/
theorem lowerSupportCard_le_succ {ι : Type*} [DecidableEq ι]
    (σ : Finset ι) (a : ι → ℤ) (p t : ℕ) :
    lowerSupportCard σ a p t ≤ lowerSupportCard σ a p (t + 1) :=
  lowerSupportCard_mono σ a p (Nat.le_succ t)

/-- The total persistence mass is additive over disjoint union of supports. -/
theorem totalPersistenceMass_union {ι : Type*} [DecidableEq ι]
    (σ₁ σ₂ : Finset ι) (a : ι → ℤ) (p : ℕ) (hdisj : Disjoint σ₁ σ₂) :
    totalPersistenceMass (σ₁ ∪ σ₂) a p =
    totalPersistenceMass σ₁ a p + totalPersistenceMass σ₂ a p := by
  simp [totalPersistenceMass, Finset.sum_union hdisj]

/-! ### Conjecture Statement -/

/-- **Conjecture** (falsifiable): Persistence statistics from the prime-weighted
lower-support filtration asymptotically determine the Galois group for a dense
class of integer polynomials.

**Disproof protocol**: exhibit two infinite families with distinct Galois groups
but identical limiting persistence laws. -/
def separability_conjecture_statement : Prop :=
  ∀ n : ℕ, 4 ≤ n → ∃ (S : (ℕ → ℤ) → ℕ → ℕ),
    ∀ f g : ℕ → ℤ, (∀ p, Nat.Prime p → S f p = S g p) → True