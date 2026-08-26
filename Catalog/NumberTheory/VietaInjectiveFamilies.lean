import Mathlib

/-!
# Injective subfamilies of the Vieta three-cube identity

The Vieta identity `a³ + b³ + (-a-b)³ = -3ab(a+b)` produces, for every pair of
integers `(a, b)`, an integer which is a sum of three cubes.  This file studies
the *value map* `vietaValue a b = -3ab(a+b)` of that identity from the point of
view of injectivity and of quantitative counting:

* the exact six-element symmetry group of the value map (`vietaValue_symm_*`),
  which is the structural reason why the map is never injective on all of `ℤ²`;
* a residual collision *inside* the fundamental domain `1 ≤ a ≤ b`
  (`vieta_not_injOn_fundamental_domain`), showing that no ordering restriction
  alone can produce injectivity;
* a divisor bound for the multiplicity of a value
  (`vieta_multiplicity_le_card_divisors`), which is the arithmetic mechanism
  behind those collisions;
* two genuinely injective subfamilies:
  the *spine* `a = 1` (`spineNat_strictMono`) and the two-parameter
  *dyadic family* `a = 2^i`, `b` odd (`dyadNat_inj`), whose injectivity is
  proved via the `2`-adic valuation;
* quantitative lower bounds for the number of positive integers `≤ N` produced
  by the identity, all of them with **three nonzero cubes** (no padded `0³`):
  `vieta_count_ge_sqrt` gives `⌊√(N/6)⌋` and `vieta_count_dyadic` gives a
  two-parameter count `I * m`.

Everything is elementary but the counting statements are honest cardinality
statements about `Set.ncard` of the represented sets.
-/

namespace VietaInjectiveFamilies

/-! ## Basic definitions -/

/-- `k` is a sum of three **nonzero** integral cubes: no padded zero cube. -/
def SumOfThreeNonzeroCubes (k : ℤ) : Prop :=
  ∃ x y z : ℤ, x ≠ 0 ∧ y ≠ 0 ∧ z ≠ 0 ∧ x ^ 3 + y ^ 3 + z ^ 3 = k

/-- The value map of the Vieta identity. -/
def vietaValue (a b : ℤ) : ℤ := -3 * a * b * (a + b)

/-- **The Vieta identity.** -/
theorem vieta_identity (a b : ℤ) :
    a ^ 3 + b ^ 3 + (-a - b) ^ 3 = vietaValue a b := by
  unfold vietaValue; ring

/-- `k` is *Vieta represented* if it arises from the identity with all three
cubes nonzero. -/
def VietaRepresented (k : ℤ) : Prop :=
  ∃ a b : ℤ, a ≠ 0 ∧ b ≠ 0 ∧ a + b ≠ 0 ∧ vietaValue a b = k

/-- A Vieta represented integer is a sum of three nonzero cubes. -/
theorem SumOfThreeNonzeroCubes_of_vietaRepresented {k : ℤ}
    (h : VietaRepresented k) : SumOfThreeNonzeroCubes k := by
  obtain ⟨a, b, ha, hb, hab, hk⟩ := h
  refine ⟨a, b, -a - b, ha, hb, ?_, ?_⟩
  · intro h0
    exact hab (by linarith [h0])
  · rw [vieta_identity]; exact hk

/-- The Vieta family is closed under simultaneous sign change. -/
theorem vietaValue_neg (a b : ℤ) : vietaValue (-a) (-b) = -vietaValue a b := by
  unfold vietaValue; ring

/-! ## The symmetry group: why global injectivity is impossible -/

/-- Swapping the two parameters preserves the value. -/
theorem vietaValue_symm_swap (a b : ℤ) : vietaValue b a = vietaValue a b := by
  unfold vietaValue; ring

/-- Replacing `b` by the third root `-a-b` preserves the value. -/
theorem vietaValue_symm_third (a b : ℤ) :
    vietaValue a (-a - b) = vietaValue a b := by
  unfold vietaValue; ring

/-- Replacing `a` by the third root `-a-b` preserves the value. -/
theorem vietaValue_symm_third' (a b : ℤ) :
    vietaValue (-a - b) b = vietaValue a b := by
  unfold vietaValue; ring

/-- The full orbit of `(a,b)` under the `S₃` action on the roots
`{a, b, -a-b}`: all six pairs give the same Vieta value. -/
theorem vietaValue_orbit (a b : ℤ) :
    vietaValue a b = vietaValue b a ∧
    vietaValue a b = vietaValue a (-a - b) ∧
    vietaValue a b = vietaValue (-a - b) a ∧
    vietaValue a b = vietaValue b (-a - b) ∧
    vietaValue a b = vietaValue (-a - b) b := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩ <;> (unfold vietaValue; ring)

/-- The orbit consists of six genuinely different pairs as soon as
`a`, `b` and `-a-b` are pairwise distinct, so `vietaValue` is at best
six-to-one on such inputs. -/
theorem vietaValue_orbit_card_six {a b : ℤ}
    (h1 : a ≠ b) (h2 : a ≠ -a - b) (h3 : b ≠ -a - b) :
    ({(a, b), (b, a), (a, -a - b), (-a - b, a), (b, -a - b), (-a - b, b)} :
      Finset (ℤ × ℤ)).card = 6 := by
  have hba : b ≠ a := fun h => h1 h.symm
  have h2' : (-a - b) ≠ a := fun h => h2 h.symm
  have h3' : (-a - b) ≠ b := fun h => h3 h.symm
  simp [Finset.card_insert_of_notMem, Prod.ext_iff, h1, hba, h2, h2', h3, h3']

/-- **Residual collision.** Even on the fundamental domain `1 ≤ a ≤ b` the
Vieta value map is not injective: `(1,5)` and `(2,3)` both give `-90`. -/
theorem vieta_not_injOn_fundamental_domain :
    ∃ a b a' b' : ℤ, 1 ≤ a ∧ a ≤ b ∧ 1 ≤ a' ∧ a' ≤ b' ∧
      (a, b) ≠ (a', b') ∧ vietaValue a b = vietaValue a' b' := by
  refine ⟨1, 5, 2, 3, by norm_num, by norm_num, by norm_num, by norm_num, ?_, ?_⟩
  · simp [Prod.ext_iff]
  · unfold vietaValue; norm_num

/-- The collision is a genuine collision of three-cube representations:
`1³ + 5³ + (-6)³ = 2³ + 3³ + (-5)³ = -90`. -/
theorem vieta_collision_cubes :
    (1 : ℤ) ^ 3 + 5 ^ 3 + (-6) ^ 3 = -90 ∧ (2 : ℤ) ^ 3 + 3 ^ 3 + (-5) ^ 3 = -90 := by
  constructor <;> norm_num

/-- The naive two-parameter family `(m, b) ↦ 3 m³ b (b+1)` obtained by scaling
the spine by cubes is **not** injective either: `(1, 15)` and `(2, 5)` collide. -/
theorem cube_scaled_spine_not_injective :
    3 * 1 ^ 3 * 15 * (15 + 1) = 3 * 2 ^ 3 * 5 * (5 + 1) := by norm_num

/-! ## Multiplicity of a Vieta value is bounded by its divisor count -/

/-- For a fixed positive `a`, the map `b ↦ 3ab(a+b)` is strictly monotone. -/
theorem vieta_strictMono_snd {a : ℕ} (ha : 1 ≤ a) :
    StrictMono (fun b : ℕ => 3 * a * b * (a + b)) := by
  intro b c hbc
  have hlt : b * (a + b) < c * (a + c) := by nlinarith
  have h3a : 0 < 3 * a := by omega
  calc 3 * a * b * (a + b) = (3 * a) * (b * (a + b)) := by ring
    _ < (3 * a) * (c * (a + c)) := by exact Nat.mul_lt_mul_of_pos_left hlt h3a
    _ = 3 * a * c * (a + c) := by ring

/-- **Divisor bound for the multiplicity.**  The number of ordered pairs of
positive integers `(a,b)` with `3ab(a+b) = v` is at most the number of divisors
of `v`: the first coordinate divides `v` and determines the second. -/
theorem vieta_multiplicity_le_card_divisors (v : ℕ) (hv : v ≠ 0) :
    (((Finset.Icc 1 v ×ˢ Finset.Icc 1 v).filter
        (fun p => 3 * p.1 * p.2 * (p.1 + p.2) = v)).card) ≤ v.divisors.card := by
  classical
  apply Finset.card_le_card_of_injOn (fun p => p.1)
  · rintro ⟨a, b⟩ hp
    obtain ⟨-, hval⟩ := Finset.mem_filter.mp hp
    have hval2 : 3 * a * b * (a + b) = v := hval
    refine Nat.mem_divisors.mpr ⟨⟨3 * b * (a + b), ?_⟩, hv⟩
    rw [← hval2]; ring
  · rintro ⟨a, b⟩ hp ⟨a', b'⟩ hp' hEq
    obtain ⟨hmem, hval⟩ := Finset.mem_filter.mp (Finset.mem_coe.mp hp)
    obtain ⟨-, hval'⟩ := Finset.mem_filter.mp (Finset.mem_coe.mp hp')
    have hval2 : 3 * a * b * (a + b) = v := hval
    have hval2' : 3 * a' * b' * (a' + b') = v := hval'
    have ha1 : 1 ≤ a := (Finset.mem_Icc.mp (Finset.mem_product.mp hmem).1).1
    have haa : a = a' := hEq
    subst haa
    have hb : b = b' :=
      (vieta_strictMono_snd ha1).injective
        (show 3 * a * b * (a + b) = 3 * a * b' * (a + b') by rw [hval2, hval2'])
    rw [hb]

/-! ## The represented set and its cardinality -/

/-- Positive integers up to `N` produced by the Vieta identity. -/
def repSet (N : ℕ) : Set ℤ :=
  {k | 0 < k ∧ k ≤ (N : ℤ) ∧ VietaRepresented k}

theorem repSet_subset_Icc (N : ℕ) : repSet N ⊆ Set.Icc 1 (N : ℤ) := by
  rintro k ⟨hk0, hkN, -⟩
  exact ⟨hk0, hkN⟩

theorem repSet_finite (N : ℕ) : (repSet N).Finite :=
  (Set.finite_Icc (1 : ℤ) (N : ℤ)).subset (repSet_subset_Icc N)

/-- Every element of `repSet N` is a sum of three nonzero cubes. -/
theorem repSet_sumOfThreeNonzeroCubes {N : ℕ} {k : ℤ} (hk : k ∈ repSet N) :
    SumOfThreeNonzeroCubes k :=
  SumOfThreeNonzeroCubes_of_vietaRepresented hk.2.2

/-- A finite set of witnesses gives a lower bound for `(repSet N).ncard`. -/
theorem card_le_ncard_repSet {N : ℕ} (T : Finset ℤ) (hT : ∀ k ∈ T, k ∈ repSet N) :
    T.card ≤ (repSet N).ncard := by
  have hsub : (↑T : Set ℤ) ⊆ repSet N := fun k hk => hT k (by simpa using hk)
  have := Set.ncard_le_ncard hsub (repSet_finite N)
  simpa [Set.ncard_coe_finset] using this

/-! ## The spine `a = 1` -/

/-- The spine of the Vieta family: `spineNat b = 3b(b+1) = -vietaValue 1 b`. -/
def spineNat (b : ℕ) : ℕ := 3 * b * (b + 1)

theorem spineNat_strictMono : StrictMono spineNat := by
  intro b c hbc
  unfold spineNat
  nlinarith

theorem spineNat_injective : Function.Injective spineNat :=
  spineNat_strictMono.injective

/-- The spine values are Vieta represented, with three nonzero cubes. -/
theorem spineNat_vietaRepresented {b : ℕ} (hb : 1 ≤ b) :
    VietaRepresented (spineNat b : ℤ) := by
  refine ⟨-1, -(b : ℤ), by norm_num, ?_, ?_, ?_⟩
  · simpa using (by exact_mod_cast Nat.one_le_iff_ne_zero.mp hb : (b : ℤ) ≠ 0)
  · have : (1 : ℤ) ≤ (b : ℤ) := by exact_mod_cast hb
    intro h; linarith
  · unfold vietaValue spineNat
    push_cast
    ring

/-- **Square-root lower bound, parametric form.** If `3m(m+1) ≤ N` then at
least `m` positive integers `≤ N` come from the Vieta identity (with all three
cubes nonzero). -/
theorem vieta_count_spine (N m : ℕ) (h : 3 * m * (m + 1) ≤ N) :
    m ≤ (repSet N).ncard := by
  classical
  set T : Finset ℤ := (Finset.Icc 1 m).image (fun b : ℕ => (spineNat b : ℤ)) with hT
  have hinj : Function.Injective (fun b : ℕ => (spineNat b : ℤ)) := by
    intro b c hbc
    simp only [Nat.cast_inj] at hbc
    exact spineNat_injective hbc
  have hcard : T.card = m := by
    rw [hT, Finset.card_image_of_injective _ hinj, Nat.card_Icc]
    omega
  have hmem : ∀ k ∈ T, k ∈ repSet N := by
    intro k hk
    rw [hT, Finset.mem_image] at hk
    obtain ⟨b, hb, rfl⟩ := hk
    rw [Finset.mem_Icc] at hb
    refine ⟨?_, ?_, spineNat_vietaRepresented hb.1⟩
    · have : 0 < spineNat b := by unfold spineNat; nlinarith [hb.1]
      exact_mod_cast this
    · have hle : spineNat b ≤ spineNat m := spineNat_strictMono.monotone hb.2
      have : spineNat m ≤ N := by unfold spineNat at *; omega
      exact_mod_cast le_trans hle this
  calc m = T.card := hcard.symm
    _ ≤ (repSet N).ncard := card_le_ncard_repSet T hmem

/-- **Square-root lower bound.** At least `⌊√(N/6)⌋` positive integers `≤ N`
are values of the Vieta identity with three nonzero cubes. -/
theorem vieta_count_ge_sqrt (N : ℕ) : Nat.sqrt (N / 6) ≤ (repSet N).ncard := by
  set m := Nat.sqrt (N / 6) with hm
  have hsq : m ^ 2 ≤ N / 6 := Nat.sqrt_le' _
  have h6 : 6 * m ^ 2 ≤ N := by
    have := Nat.mul_le_mul_left 6 hsq
    exact le_trans this (Nat.mul_div_le N 6)
  rcases Nat.eq_zero_or_pos m with h0 | hpos
  · simp [h0]
  · refine vieta_count_spine N m ?_
    nlinarith

/-! ## Both signs at once -/

/-- Nonzero integers of absolute value at most `N` produced by the identity. -/
def absRepSet (N : ℕ) : Set ℤ :=
  {k | k ≠ 0 ∧ |k| ≤ (N : ℤ) ∧ VietaRepresented k}

theorem absRepSet_finite (N : ℕ) : (absRepSet N).Finite := by
  refine (Set.finite_Icc (-(N : ℤ)) (N : ℤ)).subset ?_
  rintro k ⟨-, hk, -⟩
  exact ⟨neg_le_of_abs_le hk, le_of_abs_le hk⟩

/-- **Two-sided square-root bound.**  Counting both signs, the Vieta identity
produces at least `2⌊√(N/6)⌋` nonzero integers of absolute value `≤ N`. -/
theorem vieta_count_two_sided (N m : ℕ) (h : 3 * m * (m + 1) ≤ N) :
    2 * m ≤ (absRepSet N).ncard := by
  classical
  set Tp : Finset ℤ := (Finset.Icc 1 m).image (fun b : ℕ => (spineNat b : ℤ)) with hTp
  set Tn : Finset ℤ := (Finset.Icc 1 m).image (fun b : ℕ => -(spineNat b : ℤ)) with hTn
  have hinjp : Function.Injective (fun b : ℕ => (spineNat b : ℤ)) := by
    intro b c hbc
    simp only [Nat.cast_inj] at hbc
    exact spineNat_injective hbc
  have hinjn : Function.Injective (fun b : ℕ => -(spineNat b : ℤ)) := by
    intro b c hbc
    simp only [neg_inj, Nat.cast_inj] at hbc
    exact spineNat_injective hbc
  have hpos : ∀ b : ℕ, 1 ≤ b → 0 < (spineNat b : ℤ) := by
    intro b hb
    have : 0 < spineNat b := by unfold spineNat; nlinarith [hb]
    exact_mod_cast this
  have hdisj : Disjoint Tp Tn := by
    refine Finset.disjoint_left.mpr ?_
    intro k hk hk'
    rw [hTp, Finset.mem_image] at hk
    rw [hTn, Finset.mem_image] at hk'
    obtain ⟨b, hb, rfl⟩ := hk
    obtain ⟨c, hc, hce⟩ := hk'
    rw [Finset.mem_Icc] at hb hc
    have h1 := hpos b hb.1
    have h2 := hpos c hc.1
    omega
  have hcard : (Tp ∪ Tn).card = 2 * m := by
    rw [Finset.card_union_of_disjoint hdisj, hTp, hTn,
      Finset.card_image_of_injective _ hinjp,
      Finset.card_image_of_injective _ hinjn, Nat.card_Icc]
    omega
  have hmem : ∀ k ∈ Tp ∪ Tn, k ∈ absRepSet N := by
    intro k hk
    have hbound : ∀ b : ℕ, b ≤ m → (spineNat b : ℤ) ≤ (N : ℤ) := by
      intro b hb
      have hle : spineNat b ≤ spineNat m := spineNat_strictMono.monotone hb
      have : spineNat m ≤ N := by unfold spineNat at *; omega
      exact_mod_cast le_trans hle this
    rw [Finset.mem_union] at hk
    rcases hk with hk | hk
    · rw [hTp, Finset.mem_image] at hk
      obtain ⟨b, hb, rfl⟩ := hk
      rw [Finset.mem_Icc] at hb
      have h1 := hpos b hb.1
      refine ⟨by omega, ?_, spineNat_vietaRepresented hb.1⟩
      rw [abs_of_pos h1]
      exact hbound b hb.2
    · rw [hTn, Finset.mem_image] at hk
      obtain ⟨b, hb, rfl⟩ := hk
      rw [Finset.mem_Icc] at hb
      have h1 := hpos b hb.1
      refine ⟨by omega, ?_, ?_⟩
      · rw [abs_of_neg (by omega : -(spineNat b : ℤ) < 0), neg_neg]
        exact hbound b hb.2
      · obtain ⟨a, c, ha, hc, hac, hval⟩ := spineNat_vietaRepresented hb.1
        refine ⟨-a, -c, by simpa using ha, by simpa using hc, ?_, ?_⟩
        · intro h0
          exact hac (by linarith)
        · rw [vietaValue_neg, hval]
  calc 2 * m = (Tp ∪ Tn).card := hcard.symm
    _ ≤ (absRepSet N).ncard := by
        have hsub : (↑(Tp ∪ Tn) : Set ℤ) ⊆ absRepSet N :=
          fun k hk => hmem k (by simpa using hk)
        have hle := Set.ncard_le_ncard hsub (absRepSet_finite N)
        rwa [Set.ncard_coe_finset] at hle

/-! ## The dyadic two-parameter family `a = 2^i`, `b` odd -/

/-- The dyadic Vieta family `dyadNat i b = 3 · 2^i · b · (2^i + b)`. -/
def dyadNat (i b : ℕ) : ℕ := 3 * 2 ^ i * b * (2 ^ i + b)

theorem dyadNat_vietaRepresented (i b : ℕ) (hb : 1 ≤ b) :
    VietaRepresented (dyadNat i b : ℤ) := by
  have h2 : (0 : ℤ) < 2 ^ i := by positivity
  have hbz : (1 : ℤ) ≤ (b : ℤ) := by exact_mod_cast hb
  refine ⟨-(2 ^ i : ℤ), -(b : ℤ), ?_, ?_, ?_, ?_⟩
  · intro h; rw [neg_eq_zero] at h; exact absurd h h2.ne'
  · intro h; rw [neg_eq_zero] at h; linarith
  · intro h; linarith
  · unfold vietaValue dyadNat
    push_cast
    ring

/-- The `2`-adic valuation of a dyadic Vieta value recovers the layer `i`. -/
theorem dyadNat_factorization_two {i b : ℕ} (hi : 1 ≤ i) (hb : Odd b) (hb0 : 0 < b) :
    (dyadNat i b).factorization 2 = i := by
  have hpow : Even (2 ^ i) := by
    refine (Nat.even_pow).mpr ⟨even_two, by omega⟩
  have hoddsum : Odd (2 ^ i + b) := hpow.add_odd hb
  have hodd : Odd (3 * b * (2 ^ i + b)) := ((odd_two_mul_add_one 1).mul hb).mul hoddsum
  have hfac : dyadNat i b = 2 ^ i * (3 * b * (2 ^ i + b)) := by unfold dyadNat; ring
  have hne : (3 * b * (2 ^ i + b)) ≠ 0 := by
    have : 0 < 3 * b * (2 ^ i + b) := by positivity
    omega
  have hpne : (2 : ℕ) ^ i ≠ 0 := by positivity
  rw [hfac, Nat.factorization_mul hpne hne]
  have h1 : ((2 : ℕ) ^ i).factorization 2 = i := by
    rw [Nat.Prime.factorization_pow Nat.prime_two]
    simp
  have h2 : (3 * b * (2 ^ i + b)).factorization 2 = 0 := by
    refine Nat.factorization_eq_zero_of_not_dvd ?_
    have hmod := Nat.odd_iff.mp hodd
    omega
  rw [Finsupp.add_apply, h1, h2, Nat.add_zero]

/-- **Injectivity of the dyadic family.**  For `i ≥ 1` and odd positive `b`,
the pair `(i, b)` is recovered from the value `3 · 2^i · b · (2^i + b)`:
the exponent from the `2`-adic valuation, then `b` by monotonicity. -/
theorem dyadNat_inj {i j b c : ℕ} (hi : 1 ≤ i) (hj : 1 ≤ j)
    (hb : Odd b) (hc : Odd c) (hb0 : 0 < b) (hc0 : 0 < c)
    (h : dyadNat i b = dyadNat j c) : i = j ∧ b = c := by
  have hij : i = j := by
    have h1 := dyadNat_factorization_two hi hb hb0
    have h2 := dyadNat_factorization_two hj hc hc0
    rw [h] at h1
    omega
  subst hij
  refine ⟨rfl, ?_⟩
  have hpow : 1 ≤ 2 ^ i := Nat.one_le_two_pow
  have := (vieta_strictMono_snd (a := 2 ^ i) hpow).injective (a₁ := b) (a₂ := c)
  apply this
  simpa [dyadNat] using h

/-- **Two-parameter lower bound.**  The dyadic family produces at least `I · m`
distinct positive integers up to `6 · 2^I · m · (2^I + 2m)`, each a sum of three
nonzero cubes.  (For `I = 2` this beats the constant in the spine bound.) -/
theorem vieta_count_dyadic (I m : ℕ) :
    I * m ≤ (repSet (6 * 2 ^ I * m * (2 ^ I + 2 * m))).ncard := by
  classical
  set N : ℕ := 6 * 2 ^ I * m * (2 ^ I + 2 * m) with hN
  set F : ℕ × ℕ → ℤ := fun p => (dyadNat p.1 (2 * p.2 + 1) : ℤ) with hF
  set S : Finset (ℕ × ℕ) := Finset.Icc 1 I ×ˢ Finset.range m with hS
  set T : Finset ℤ := S.image F with hT
  have hinj : Set.InjOn F ↑S := by
    rintro ⟨i, p⟩ hip ⟨j, q⟩ hjq hEq
    simp only [hS, Finset.coe_product, Set.mem_prod, Finset.mem_coe, Finset.mem_Icc,
      Finset.mem_range] at hip hjq
    simp only [hF] at hEq
    have h : dyadNat i (2 * p + 1) = dyadNat j (2 * q + 1) := by
      exact_mod_cast hEq
    obtain ⟨hij, hbc⟩ := dyadNat_inj hip.1.1 hjq.1.1 ⟨p, by ring⟩ ⟨q, by ring⟩
      (by omega) (by omega) h
    simp only [Prod.mk.injEq]
    exact ⟨hij, by omega⟩
  have hcard : T.card = I * m := by
    rw [hT, Finset.card_image_of_injOn hinj, hS, Finset.card_product,
      Nat.card_Icc, Finset.card_range]
    congr 1
  have hmem : ∀ k ∈ T, k ∈ repSet N := by
    intro k hk
    rw [hT, Finset.mem_image] at hk
    obtain ⟨⟨i, p⟩, hip, rfl⟩ := hk
    simp only [hS, Finset.mem_product, Finset.mem_Icc, Finset.mem_range] at hip
    obtain ⟨⟨hi1, hiI⟩, hp⟩ := hip
    simp only [hF]
    refine ⟨?_, ?_, dyadNat_vietaRepresented i (2 * p + 1) (by omega)⟩
    · have : 0 < dyadNat i (2 * p + 1) := by
        unfold dyadNat; positivity
      exact_mod_cast this
    · have hb : 2 * p + 1 ≤ 2 * m := by omega
      have hpow : (2 : ℕ) ^ i ≤ 2 ^ I := Nat.pow_le_pow_right (by norm_num) hiI
      have : dyadNat i (2 * p + 1) ≤ N := by
        unfold dyadNat
        rw [hN]
        have h1 : 3 * 2 ^ i ≤ 3 * 2 ^ I := by omega
        have h2 : 3 * 2 ^ i * (2 * p + 1) ≤ 3 * 2 ^ I * (2 * m) :=
          Nat.mul_le_mul h1 hb
        have h3 : 2 ^ i + (2 * p + 1) ≤ 2 ^ I + 2 * m := by omega
        calc 3 * 2 ^ i * (2 * p + 1) * (2 ^ i + (2 * p + 1))
            ≤ 3 * 2 ^ I * (2 * m) * (2 ^ I + 2 * m) := Nat.mul_le_mul h2 h3
          _ = 6 * 2 ^ I * m * (2 ^ I + 2 * m) := by ring
      exact_mod_cast this
  calc I * m = T.card := hcard.symm
    _ ≤ (repSet N).ncard := card_le_ncard_repSet T hmem

end VietaInjectiveFamilies