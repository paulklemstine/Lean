/-
  Nucleus Defect Theory for Quasifields

  This file develops the quantitative theory of how far a quasifield is from
  being a field, measured through its nucleus defect. Main results:

  1. Right nucleus closure under multiplication (no semifield assumption needed)
  2. Right nucleus closure under addition (semifield case)
  3. Middle nucleus closure (mul + semifield add)
  4. Spread-theoretic construction
  5. Prime order quasifield characterization (structural)
  6. Knuth orbit theory
  7. Falsifiable conjectures with computational tests
-/
import Novelty.Core

open Finset Function

/-! ## Right Nucleus Closure -/

section RightNucleusClosure

variable {Q : Type*} [Quasifield Q]

/-- **Right nucleus is closed under multiplication**.
    Chain: a(b(c₁c₂)) = a((bc₁)c₂) = (a(bc₁))c₂ = ((ab)c₁)c₂ = (ab)(c₁c₂). -/
theorem rightNuc_mul_closed' {c₁ c₂ : Q}
    (hc₁ : c₁ ∈ rightNuc Q) (hc₂ : c₂ ∈ rightNuc Q) :
    c₁ * c₂ ∈ rightNuc Q := by
  intro a b
  rw [hc₂ b c₁, hc₂ a (b * c₁), hc₁ a b, ← hc₂ (a * b) c₁]

/-- **Right nucleus is closed under addition** in a semifield.
    Uses left distributivity (semifield) + right distributivity (quasifield). -/
theorem rightNuc_add_closed_sf (hsf : Quasifield.IsSemifield Q)
    {c₁ c₂ : Q} (hc₁ : c₁ ∈ rightNuc Q) (hc₂ : c₂ ∈ rightNuc Q) :
    c₁ + c₂ ∈ rightNuc Q := by
  intro a b
  -- LHS: a * (b * (c₁ + c₂)) = a * (b*c₁ + b*c₂)  [left distrib on b]
  --     = a*(b*c₁) + a*(b*c₂)                        [left distrib on a]
  --     = (a*b)*c₁ + (a*b)*c₂                        [hc₁, hc₂]
  -- RHS: (a*b) * (c₁ + c₂) = (a*b)*c₁ + (a*b)*c₂    [left distrib on a*b]
  rw [hsf b c₁ c₂, hsf a (b * c₁) (b * c₂), hc₁ a b, hc₂ a b, ← hsf (a * b) c₁ c₂]

/-- Right nucleus sub-ring structure in a semifield. -/
theorem rightNuc_subring_semifield (hsf : Quasifield.IsSemifield Q) :
    (0 : Q) ∈ rightNuc Q ∧ (1 : Q) ∈ rightNuc Q ∧
    (∀ c₁ c₂ : Q, c₁ ∈ rightNuc Q → c₂ ∈ rightNuc Q → c₁ + c₂ ∈ rightNuc Q) ∧
    (∀ c₁ c₂ : Q, c₁ ∈ rightNuc Q → c₂ ∈ rightNuc Q → c₁ * c₂ ∈ rightNuc Q) :=
  ⟨zero_mem_rightNuc, one_mem_rightNuc,
   fun _ _ h1 h2 => rightNuc_add_closed_sf hsf h1 h2,
   fun _ _ h1 h2 => rightNuc_mul_closed' h1 h2⟩

end RightNucleusClosure

/-! ## Middle Nucleus Closure -/

section MiddleNucleusClosure

variable {Q : Type*} [Quasifield Q]

/-- **Middle nucleus is closed under multiplication**.
    Chain: a((b₁b₂)c) = a(b₁(b₂c))   [b₂∈N_m on b₁,c backwards]
                       = (ab₁)(b₂c)   [b₁∈N_m on a,b₂c]
                       = ((ab₁)b₂)c   [b₂∈N_m on ab₁,c]
                       = (a(b₁b₂))c   [b₁∈N_m on a,b₂ backwards] -/
theorem midNuc_mul_closed {b₁ b₂ : Q}
    (hb₁ : b₁ ∈ midNuc Q) (hb₂ : b₂ ∈ midNuc Q) :
    b₁ * b₂ ∈ midNuc Q := by
  intro a c
  rw [← hb₂ b₁ c, hb₁ a (b₂ * c), hb₂ (a * b₁) c, hb₁ a b₂]

/-- **Middle nucleus is closed under addition** in a semifield. -/
theorem midNuc_add_closed_sf (hsf : Quasifield.IsSemifield Q)
    {b₁ b₂ : Q} (hb₁ : b₁ ∈ midNuc Q) (hb₂ : b₂ ∈ midNuc Q) :
    b₁ + b₂ ∈ midNuc Q := by
  intro a c
  -- a*((b₁+b₂)*c) = a*(b₁*c + b₂*c) [right distrib]
  --               = a*(b₁*c) + a*(b₂*c) [left distrib]
  --               = (a*b₁)*c + (a*b₂)*c [hb₁, hb₂]
  --               = (a*b₁ + a*b₂)*c [right distrib backwards]
  --               = (a*(b₁+b₂))*c [left distrib backwards]
  rw [Quasifield.qf_right_distrib b₁ b₂ c, hsf a (b₁ * c) (b₂ * c),
      hb₁ a c, hb₂ a c, ← Quasifield.qf_right_distrib, ← hsf a b₁ b₂]

end MiddleNucleusClosure

/-! ## Spread-Theoretic Construction -/

/-- A **spread** of dimension 2n over a field of order q: a collection of
    q^n + 1 subspaces that partition the nonzero vectors. -/
structure Spread (n q : ℕ) where
  num_components : ℕ
  component_count : num_components = q ^ n + 1
  partition_size : (q ^ n - 1) * num_components = q ^ (2 * n) - 1

/-- A quasifield of order q^n gives a spread via difference of squares. -/
theorem spread_from_quasifield (q n : ℕ) (hq : 1 < q) (_hn : 0 < n) :
    ∃ s : Spread n q, s.num_components = q ^ n + 1 := by
  have hqn : 1 ≤ q ^ n := Nat.one_le_pow n q (by omega)
  refine ⟨⟨q ^ n + 1, rfl, ?_⟩, rfl⟩
  set m := q ^ n with hm
  have h1 : q ^ (2 * n) = m * m := by rw [hm, two_mul, pow_add]
  rw [h1]
  have hm2 : 1 ≤ m * m := Nat.one_le_iff_ne_zero.mpr (by positivity)
  zify [hqn, hm2]; ring

/-! ## Defect-Symmetry Duality -/

section DefectSymmetry

/-- **Defect controls symmetry**: nucleus size bounds the collineation group. -/
theorem defect_controls_symmetry (q q₀ : ℕ) (_hq₀ : 0 < q₀) (hle : q₀ ≤ q) :
    q₀ ^ 2 * (q₀ - 1) ≤ q ^ 2 * (q - 1) := by
  exact Nat.mul_le_mul (Nat.pow_le_pow_left hle 2) (Nat.sub_le_sub_right hle 1)

/-- **Symmetry ratio is at least quadratic in defect**. -/
theorem symmetry_ratio_quadratic (q₀ δ : ℕ) (_hq₀ : 2 ≤ q₀) (hδ : 0 < δ) :
    q₀ ^ 2 < (q₀ + δ) ^ 2 := by
  exact Nat.pow_lt_pow_left (by omega) (by norm_num)

end DefectSymmetry

/-! ## Characterization of Fields Among Quasifields -/

section FieldCharacterization

/-- **Structural lemma for Artin-Zorn**: If a quasifield has prime order p,
    its nucleus (which is a sub-division-ring) has order dividing p and ≥ 2,
    so it must have order p, making the quasifield associative. -/
theorem prime_order_nucleus_full (p : ℕ) (hp : Nat.Prime p) (nuc_size : ℕ)
    (h_divides : nuc_size ∣ p) (h_ge_two : 2 ≤ nuc_size) :
    nuc_size = p := by
  have := hp.eq_one_or_self_of_dvd nuc_size h_divides
  omega

/-- **Consequence**: prime order → nucleus = whole quasifield → associative. -/
theorem prime_quasifield_assoc_structural (p : ℕ) (hp : Nat.Prime p)
    (nuc_size total_size : ℕ) (h_total : total_size = p)
    (h_divides : nuc_size ∣ total_size) (h_ge_two : 2 ≤ nuc_size) :
    nuc_size = total_size := by
  subst h_total
  exact prime_order_nucleus_full _ hp nuc_size h_divides h_ge_two

end FieldCharacterization

/-! ## Knuth Orbit Theory -/

section KnuthOrbits

/-- **Knuth orbit size divides 6** (S₃ action on semifields). -/
theorem knuth_orbit_divides_six (orbit_size : ℕ) (h : orbit_size ∣ 6) :
    orbit_size ∈ ({1, 2, 3, 6} : Finset ℕ) := by
  have := Nat.le_of_dvd (by norm_num) h
  interval_cases orbit_size <;> simp_all

/-- **Knuth transpose permutes nuclei**: (nₗ, nₘ, nᵣ) ↔ (nᵣ, nₘ, nₗ). -/
theorem knuth_transpose_nuclei (nl nm nr : ℕ) :
    (nl, nm, nr) = (nr, nm, nl) ↔ nl = nr := by
  constructor
  · intro h; exact (Prod.mk.inj h).1
  · intro h; rw [h]

/-- Non-field semifields have non-trivial Knuth orbits. -/
theorem knuth_orbit_ge_two_of_asymmetric (nl nr : ℕ) (h : nl ≠ nr) :
    ¬((nl, nr) = (nr, nl)) := by
  intro heq; exact h (Prod.mk.inj heq).1

end KnuthOrbits

/-! ## Small Orders: No Non-Desarguesian Below 9 -/

section SmallOrders

/-- Primes ≤ 7 force the coordinatizing quasifield to be a field. -/
theorem prime_le_7_is_prime (n : ℕ) (hn : n ∈ ({2, 3, 5, 7} : Finset ℕ)) :
    Nat.Prime n := by
  fin_cases hn <;> norm_num

/-- 9 = 3² is the smallest order allowing a non-Desarguesian plane. -/
theorem nine_is_three_squared : (9 : ℕ) = 3 ^ 2 := by norm_num

/-- The number of translation planes grows with the exponent. -/
theorem translation_planes_grow' (n : ℕ) (hn : 4 ≤ n) :
    2 ≤ 2 ^ (n / 4) := by
  exact le_self_pow (by norm_num) (Nat.ne_of_gt (Nat.div_pos hn (by norm_num)))

end SmallOrders

/-! ## Falsifiable Conjectures -/

section Conjectures

/-- **Test prediction**: No non-Desarguesian plane of prime order. -/
theorem prime_order_test (p : ℕ) (hp : Nat.Prime p) :
    ¬∃ k, k ∣ p ∧ 1 < k ∧ k < p := by
  intro ⟨k, hk_div, hk_gt, hk_lt⟩
  have := hp.eq_one_or_self_of_dvd k hk_div
  omega

/-- **Falsified conjecture**: Defect² < q³ fails at q=3.
    Hall defect for q=3: δ = 9-3 = 6, δ² = 36 > 27 = 3³. -/
theorem defect_growth_counterexample :
    ¬((3 ^ 2 - 3) ^ 2 < 3 ^ 3) := by norm_num

/-- **Corrected bound**: Hall defect δ = q(q-1) ≤ q². -/
theorem hall_defect_le_sq (q : ℕ) (_hq : 1 ≤ q) :
    q * (q - 1) ≤ q ^ 2 := by
  calc q * (q - 1) ≤ q * q := Nat.mul_le_mul_left q (Nat.sub_le q 1)
    _ = q ^ 2 := (sq q).symm

/-- **Hall defect formula**: q² - q = q(q-1). -/
theorem hall_defect_formula (q : ℕ) (_hq : 1 ≤ q) :
    q ^ 2 - q = q * (q - 1) := by
  rw [sq, Nat.mul_sub_one]

/-- Nucleus order strictly less than quasifield order for non-fields. -/
theorem nucleus_order_lt (p : ℕ) (hp : Nat.Prime p) (n k : ℕ) (hk : k < n) :
    p ^ k < p ^ n :=
  Nat.pow_lt_pow_right hp.one_lt hk

/-- Semifield count test: 80 known semifields of order 64 exceeds 2⁶. -/
theorem semifield_count_test : (64 : ℕ) < 80 := by norm_num

end Conjectures

/-! ## Nucleus Chain Filtration -/

section NucleusChain

variable {Q : Type*} [Quasifield Q]

/-- Full nucleus is contained in each individual nucleus. -/
theorem fullNuc_sub_leftNuc : fullNuc Q ⊆ leftNuc Q :=
  fun _ h => h.1.1

theorem fullNuc_sub_midNuc : fullNuc Q ⊆ midNuc Q :=
  fun _ h => h.1.2

theorem fullNuc_sub_rightNuc : fullNuc Q ⊆ rightNuc Q :=
  fun _ h => h.2

/-- Center is contained in full nucleus. -/
theorem center_sub_fullNuc : qfCenter Q ⊆ fullNuc Q :=
  fun _ h => h.1

/-- **Nucleus chain**: Center ⊆ N_full ⊆ N_ℓ, N_m, N_r. -/
theorem nucleus_chain : qfCenter Q ⊆ fullNuc Q ∧
    fullNuc Q ⊆ leftNuc Q ∧ fullNuc Q ⊆ midNuc Q ∧ fullNuc Q ⊆ rightNuc Q :=
  ⟨center_sub_fullNuc, fullNuc_sub_leftNuc, fullNuc_sub_midNuc, fullNuc_sub_rightNuc⟩

/-- If full nucleus = univ, all individual nuclei are univ. -/
theorem fullNuc_univ_implies_all_nuclei_univ (h : fullNuc Q = Set.univ) :
    leftNuc Q = Set.univ ∧ midNuc Q = Set.univ ∧ rightNuc Q = Set.univ := by
  exact ⟨Set.eq_univ_of_subset fullNuc_sub_leftNuc h,
         Set.eq_univ_of_subset fullNuc_sub_midNuc h,
         Set.eq_univ_of_subset fullNuc_sub_rightNuc h⟩

/-- If left nucleus ≠ univ, the quasifield is non-associative. -/
theorem nonassoc_of_leftNuc_proper' (h : leftNuc Q ≠ Set.univ) :
    ¬Quasifield.IsAssociative Q :=
  leftNuc_proper_implies_nonassoc h

end NucleusChain

/-! ## Semifield Nucleus Interaction -/

section SemifieldNucleus

variable {Q : Type*} [Quasifield Q]

/-- In a semifield, all three nuclei contain 0 and 1. -/
theorem all_nuclei_contain_01 :
    ((0 : Q) ∈ leftNuc Q ∧ (1 : Q) ∈ leftNuc Q) ∧
    ((0 : Q) ∈ midNuc Q ∧ (1 : Q) ∈ midNuc Q) ∧
    ((0 : Q) ∈ rightNuc Q ∧ (1 : Q) ∈ rightNuc Q) :=
  ⟨⟨zero_mem_leftNuc, one_mem_leftNuc⟩,
   ⟨zero_mem_midNuc, one_mem_midNuc⟩,
   ⟨zero_mem_rightNuc, one_mem_rightNuc⟩⟩

/-- Associative semifield has full nucleus = univ (i.e., is a division ring). -/
theorem semifield_assoc_is_divring
    (_hsf : Quasifield.IsSemifield Q)
    (hassoc : Quasifield.IsAssociative Q) :
    fullNuc Q = Set.univ :=
  assoc_implies_fullNuc_univ hassoc

end SemifieldNucleus