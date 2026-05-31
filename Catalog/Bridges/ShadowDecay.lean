/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.
-/
import Mathlib

/-!
# Shadow Decay Profiles for Algebraic Circuit Lower Bounds

This file introduces the **shadow decay profile** as a new complexity invariant
for multivariate polynomials, connecting algebraic circuit complexity to the
combinatorial geometry of polynomial supports.

## Main Definitions

* `ShadowDecay.totalDeg` — Total degree of a multi-index.
* `ShadowDecay.kthShadow` — The k-th downward shadow of a finite support set.
* `ShadowDecay.shadowProfile` — The shadow profile `k ↦ |Shadow_k(S)|`.
* `ShadowDecay.degreeSimplex` — The set of multi-indices with total degree ≤ d.
* `ShadowDecay.circuitShadowEnvelope` — Upper envelope for circuit-bounded supports.
* `ShadowDecay.HasSlowShadowDecay` — Predicate for supports with slow shadow decay.
* `ShadowDecay.elemSymmSupport` — Support of elementary symmetric polynomials.

## Main Results

* `ShadowDecay.kthShadow_subset_degreeSimplex` — Shadows stay inside lower-degree simplices.
* `ShadowDecay.shadowProfile_le_degreeSimplex_card` — Shadow profile bounded by simplex size.
* `ShadowDecay.kthShadow_elemSymm_eq` — Exact shadow characterization for elem. symm. supports.
* `ShadowDecay.shadowProfile_elemSymm` — Exact shadow profile for elementary symmetric supports.

## Cross-Domain Connections

This development bridges:
- **Algebraic complexity theory**: circuit lower bounds via support invariants
- **Extremal combinatorics**: shadow phenomena for set families (Kruskal–Katona)
- **Discrete convex geometry**: Newton polytope contraction under differentiation
- **Geometric complexity theory**: combinatorial front-end to orbit-closure methods
-/

open Finset BigOperators

namespace ShadowDecay

variable {n : ℕ}

/-! ## Total Degree for Multi-indices -/

/-- Total degree of a multi-index `m : Fin n → ℕ`. -/
def totalDeg (m : Fin n → ℕ) : ℕ := ∑ i, m i

theorem totalDeg_le_of_le {m₁ m₂ : Fin n → ℕ} (h : ∀ i, m₁ i ≤ m₂ i) :
    totalDeg m₁ ≤ totalDeg m₂ :=
  Finset.sum_le_sum fun i _ => h i

/-- If `β ≤ α` pointwise, then `totalDeg β + ∑(α - β) = totalDeg α`. -/
theorem totalDeg_add_diff {α β : Fin n → ℕ} (hle : ∀ i, β i ≤ α i) :
    totalDeg β + ∑ i : Fin n, (α i - β i) = totalDeg α := by
  unfold totalDeg
  rw [← Finset.sum_add_distrib]
  exact Finset.sum_congr rfl fun i _ => Nat.add_sub_cancel' (hle i)

/-! ## Degree Simplex -/

/-- The **degree-d simplex**: all multi-indices in `(Fin n → ℕ)` with total degree ≤ d. -/
def degreeSimplex (n d : ℕ) : Finset (Fin n → ℕ) :=
  (Fintype.piFinset (fun _ => Finset.range (d + 1))).filter
    (fun m => totalDeg m ≤ d)

theorem mem_degreeSimplex_iff {n d : ℕ} {m : Fin n → ℕ} :
    m ∈ degreeSimplex n d ↔ totalDeg m ≤ d := by
  simp only [degreeSimplex, mem_filter, Fintype.mem_piFinset]
  constructor
  · exact fun ⟨_, h2⟩ => h2
  · intro h
    refine ⟨fun i => ?_, h⟩
    simp only [mem_range]
    have : m i ≤ totalDeg m :=
      Finset.single_le_sum (fun j _ => Nat.zero_le _) (mem_univ i)
    omega

/-! ## k-th Shadow Definition -/

/-- The **k-th shadow** of a finite set `S` of multi-indices.
`β ∈ kthShadow S k` iff there exists `α ∈ S` with `β ≤ α` (pointwise)
and the total degree drop `∑ᵢ (α i - β i) = k`. -/
def kthShadow (S : Finset (Fin n → ℕ)) (k : ℕ) : Finset (Fin n → ℕ) :=
  S.biUnion (fun α =>
    (degreeSimplex n (totalDeg α)).filter (fun β =>
      (∀ i, β i ≤ α i) ∧ ∑ i, (α i - β i) = k))

theorem mem_kthShadow_iff {S : Finset (Fin n → ℕ)} {k : ℕ} {β : Fin n → ℕ} :
    β ∈ kthShadow S k ↔ ∃ α ∈ S, (∀ i, β i ≤ α i) ∧ ∑ i, (α i - β i) = k := by
  simp only [kthShadow, mem_biUnion, mem_filter]
  constructor
  · rintro ⟨α, hα, _, hle, hsum⟩
    exact ⟨α, hα, hle, hsum⟩
  · rintro ⟨α, hα, hle, hsum⟩
    refine ⟨α, hα, ?_, hle, hsum⟩
    rw [mem_degreeSimplex_iff]
    exact totalDeg_le_of_le hle

/-! ## Basic Shadow Properties -/

/-- The 0-th shadow of `S` is `S` itself. -/
theorem kthShadow_zero (S : Finset (Fin n → ℕ)) :
    kthShadow S 0 = S := by
  ext β
  rw [mem_kthShadow_iff]
  constructor
  · rintro ⟨α, hα, hle, hsum⟩
    have heq : β = α := by
      ext i
      have hi : α i - β i = 0 := by
        by_contra h
        have hpos : 0 < α i - β i := Nat.pos_of_ne_zero h
        have key := Finset.single_le_sum (f := fun j => α j - β j)
          (fun j _ => Nat.zero_le _) (Finset.mem_univ i)
        simp only at key; linarith
      have := hle i; omega
    rw [heq]; exact hα
  · intro hβ
    exact ⟨β, hβ, fun _ => le_refl _, by simp⟩

/-- The shadow is monotone in the support set. -/
theorem kthShadow_mono {S₁ S₂ : Finset (Fin n → ℕ)} (h : S₁ ⊆ S₂) (k : ℕ) :
    kthShadow S₁ k ⊆ kthShadow S₂ k := by
  intro β hβ
  rw [mem_kthShadow_iff] at hβ ⊢
  obtain ⟨α, hα, hle, hsum⟩ := hβ
  exact ⟨α, h hα, hle, hsum⟩

/-- The k-th shadow of the empty set is empty. -/
@[simp]
theorem kthShadow_empty (k : ℕ) :
    kthShadow (∅ : Finset (Fin n → ℕ)) k = ∅ := by
  simp [kthShadow]

/-! ## Shadow Profile -/

/-- The **shadow profile** of a finite support set: the cardinality of the k-th shadow. -/
def shadowProfile (S : Finset (Fin n → ℕ)) (k : ℕ) : ℕ :=
  (kthShadow S k).card

/-- Shadow profile at 0 equals the size of S. -/
theorem shadowProfile_zero (S : Finset (Fin n → ℕ)) :
    shadowProfile S 0 = S.card := by
  simp [shadowProfile, kthShadow_zero]

/-! ## Circuit Shadow Envelope -/

/-- The **circuit shadow envelope**: an upper bound on shadow profile for supports
generated by circuits of size `s` and degree `d`. -/
def circuitShadowEnvelope (n d s k : ℕ) : ℕ :=
  s * Nat.choose (n + d - k) n

/-! ## Slow Shadow Decay Predicate -/

/-- A support `S` has **slow shadow decay** relative to bound `B` if for all `k`,
the shadow profile exceeds `B k`. This captures the property of explicit hard
polynomials whose shadows decay slowly — violating circuit-forced envelopes. -/
def HasSlowShadowDecay (S : Finset (Fin n → ℕ)) (B : ℕ → ℕ) : Prop :=
  ∀ k, B k ≤ shadowProfile S k

/-! ## Theorem: Shadow Containment in Degree Simplex -/

/-- **Newton polytope contraction under shadowing.**
If every element of `S` has total degree ≤ `d`, then every element of
`kthShadow S k` has total degree ≤ `d - k`. -/
theorem kthShadow_totalDeg_le
    {d k : ℕ} {S : Finset (Fin n → ℕ)}
    (hdeg : ∀ m ∈ S, totalDeg m ≤ d)
    {β : Fin n → ℕ} (hβ : β ∈ kthShadow S k) :
    totalDeg β ≤ d - k := by
  rw [mem_kthShadow_iff] at hβ
  obtain ⟨α, hα, hle, hsum⟩ := hβ
  have hdα : totalDeg α ≤ d := hdeg α hα
  have hkey : totalDeg β + k = totalDeg α := by
    have := totalDeg_add_diff hle
    linarith
  omega

/-- **Newton polytope contraction under shadowing (set version).**
Shadows stay inside lower-degree simplices. -/
theorem kthShadow_subset_degreeSimplex
    {d k : ℕ} {S : Finset (Fin n → ℕ)}
    (hdeg : ∀ m ∈ S, totalDeg m ≤ d) :
    kthShadow S k ⊆ degreeSimplex n (d - k) := by
  intro β hβ
  rw [mem_degreeSimplex_iff]
  exact kthShadow_totalDeg_le hdeg hβ

/-- **Shadow profile bounded by simplex size.** -/
theorem shadowProfile_le_degreeSimplex_card
    {d k : ℕ} {S : Finset (Fin n → ℕ)}
    (hdeg : ∀ m ∈ S, totalDeg m ≤ d) :
    shadowProfile S k ≤ (degreeSimplex n (d - k)).card :=
  Finset.card_le_card (kthShadow_subset_degreeSimplex hdeg)

/-! ## Shadow Profile Monotonicity -/

/-- Shadow profile is monotone in the support. -/
theorem shadowProfile_mono {S₁ S₂ : Finset (Fin n → ℕ)} (h : S₁ ⊆ S₂) (k : ℕ) :
    shadowProfile S₁ k ≤ shadowProfile S₂ k :=
  Finset.card_le_card (kthShadow_mono h k)

/-! ## Shadow Profile Subadditivity -/

/-- Shadow profile is subadditive under union. -/
theorem shadowProfile_union_le (S₁ S₂ : Finset (Fin n → ℕ)) (k : ℕ) :
    shadowProfile (S₁ ∪ S₂) k ≤ shadowProfile S₁ k + shadowProfile S₂ k := by
  unfold shadowProfile
  have hsub : kthShadow (S₁ ∪ S₂) k ⊆ kthShadow S₁ k ∪ kthShadow S₂ k := by
    intro β hβ
    rw [mem_kthShadow_iff] at hβ
    obtain ⟨α, hα, hle, hsum⟩ := hβ
    rw [Finset.mem_union] at hα
    rw [Finset.mem_union]
    cases hα with
    | inl h => left; rw [mem_kthShadow_iff]; exact ⟨α, h, hle, hsum⟩
    | inr h => right; rw [mem_kthShadow_iff]; exact ⟨α, h, hle, hsum⟩
  exact le_trans (Finset.card_le_card hsub) (Finset.card_union_le _ _)

/-! ## Elementary Symmetric Support -/

/-- The **support of the elementary symmetric polynomial** `e_r(x_1, ..., x_n)`.
This consists of all 0-1 vectors with exactly `r` ones, corresponding to
all `r`-element subsets of `{1, ..., n}`. -/
def elemSymmSupport (n r : ℕ) : Finset (Fin n → ℕ) :=
  ((Finset.univ : Finset (Fin n)).powersetCard r).image
    (fun S i => if i ∈ S then 1 else 0)

/-- Elements of `elemSymmSupport` are 0-1 vectors. -/
theorem elemSymmSupport_binary {m : Fin n → ℕ} (hm : m ∈ elemSymmSupport n r) :
    ∀ i, m i = 0 ∨ m i = 1 := by
  simp only [elemSymmSupport, mem_image, mem_powersetCard] at hm
  obtain ⟨S, _, rfl⟩ := hm
  intro i
  by_cases hi : i ∈ S <;> simp [hi]

/-
The total degree of any element of `elemSymmSupport n r` is `r`.
-/
theorem totalDeg_elemSymmSupport {m : Fin n → ℕ} (hm : m ∈ elemSymmSupport n r) :
    totalDeg m = r := by
  unfold elemSymmSupport at hm;
  simp +zetaDelta at *;
  rcases hm with ⟨ a, rfl, rfl ⟩ ; simp +decide [ totalDeg, Finset.sum_ite ] ;

/-
The cardinality of `elemSymmSupport n r` equals `C(n, r)`.
-/
theorem elemSymmSupport_card (hr : r ≤ n) :
    (elemSymmSupport n r).card = Nat.choose n r := by
  convert Finset.card_powersetCard r ( Finset.univ : Finset ( Fin n ) );
  · convert Finset.card_image_of_injOn _;
    intro S hS T hT h_eq; ext i; replace h_eq := congr_fun h_eq i; aesop;
  · simp +decide [ Finset.card_univ ]

/-! ## Theorem: Elementary Symmetric Shadow Characterization -/

/-
**The k-th shadow of elementary symmetric support is contained in
the lower-degree elementary symmetric support.**
-/
theorem kthShadow_elemSymm_subset (hk : k ≤ r) (hr : r ≤ n) :
    kthShadow (elemSymmSupport n r) k ⊆ elemSymmSupport n (r - k) := by
  intro β hβ
  obtain ⟨α, hαS, hαβ⟩ := (mem_kthShadow_iff.mp hβ)
  have hα_indicator : ∃ S : Finset (Fin n), S.card = r ∧ α = fun i => if i ∈ S then 1 else 0 := by
    unfold elemSymmSupport at hαS; aesop;
  obtain ⟨S, hS_card, hα_eq⟩ := hα_indicator
  have hβ_indicator : ∃ T : Finset (Fin n), T.card = r - k ∧ β = fun i => if i ∈ T then 1 else 0 := by
    -- Since β ≤ α pointwise and α is 0-1, β is also 0-1. The sum β is r - k.
    have hβ_binary : ∀ i, β i = 0 ∨ β i = 1 := by
      grind
    have hβ_sum : ∑ i, β i = r - k := by
      have hβ_sum : ∑ i, α i = r := by
        simp_all +decide [ Finset.sum_ite ]
      have hβ_sum_eq : ∑ i, β i = ∑ i, α i - ∑ i, (α i - β i) := by
        exact eq_tsub_of_add_eq ( by rw [ ← Finset.sum_add_distrib ] ; exact Finset.sum_congr rfl fun _ _ => by rw [ Nat.add_sub_of_le ( hαβ.1 _ ) ] ) ;
      rw [hβ_sum_eq, hβ_sum, hαβ.right];
    exact ⟨ Finset.univ.filter fun i => β i = 1, by rw [ ← hβ_sum, Finset.card_filter ] ; exact Finset.sum_congr rfl fun i hi => by cases hβ_binary i <;> aesop, funext fun i => by cases hβ_binary i <;> aesop ⟩ ;
  obtain ⟨T, hT_card, hβ_eq⟩ := hβ_indicator
  have hT_subset : T ⊆ S := by
    intro i hi; specialize hαβ; have := hαβ.1 i; aesop;
  have hT_indicator : β ∈ elemSymmSupport n (r - k) := by
    exact hβ_eq ▸ Finset.mem_image.mpr ⟨ T, Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ T, hT_card ⟩, rfl ⟩
  exact hT_indicator

/-
**Every element of `elemSymmSupport n (r - k)` arises as a shadow element.**
-/
theorem elemSymm_subset_kthShadow (hk : k ≤ r) (hr : r ≤ n) :
    elemSymmSupport n (r - k) ⊆ kthShadow (elemSymmSupport n r) k := by
  intro m hm
  obtain ⟨T, hT⟩ : ∃ T : Finset (Fin n), T.card = r - k ∧ ∀ i, m i = if i ∈ T then 1 else 0 := by
    unfold elemSymmSupport at hm; aesop;
  -- Since $r \leq n$ and $k \leq r$, we have $r - k \leq n$. We can find a set $S$ with $T \subseteq S \subseteq \text{Fin } n$ and $|S| = r$.
  obtain ⟨S, hS⟩ : ∃ S : Finset (Fin n), T ⊆ S ∧ S.card = r := by
    have h_card : Finset.card (Finset.univ \ T) ≥ k := by
      simp_all +decide [ Finset.card_sdiff ];
      omega;
    obtain ⟨ S, hS ⟩ := Finset.exists_subset_card_eq h_card;
    use T ∪ S; simp_all +decide [ Finset.subset_iff ] ;
    rw [ Finset.card_union_of_disjoint ( Finset.disjoint_left.mpr fun x hxT hxS => hS.1 hxS hxT ), hT.1, hS.2, Nat.sub_add_cancel hk ];
  refine' Finset.mem_biUnion.mpr ⟨ fun i => if i ∈ S then 1 else 0, _, _ ⟩ <;> simp_all +decide [ Finset.subset_iff ];
  · exact Finset.mem_image.mpr ⟨ S, Finset.mem_powersetCard.mpr ⟨ Finset.subset_univ _, hS.2 ⟩, by aesop ⟩;
  · refine' ⟨ _, _, _ ⟩;
    · simp_all +decide [ degreeSimplex, totalDeg ];
      grind;
    · grind;
    · zify [ hT.1, hS.2 ];
      rw [ Finset.sum_congr rfl fun x hx => by rw [ Nat.cast_sub ] ; split_ifs <;> simp_all +decide [ Finset.subset_iff ] ] ; simp +decide [ *, Finset.sum_ite ]

/-- **Exact shadow theorem for elementary symmetric supports.**
The k-th shadow of `elemSymmSupport n r` equals `elemSymmSupport n (r - k)`.

This is the combinatorial heart of the shadow decay framework: taking shadows
of multilinear supports corresponds exactly to taking lower shadows of uniform
set families, connecting algebraic circuit complexity to classical Kruskal–Katona
type extremal combinatorics. -/
theorem kthShadow_elemSymm_eq (hk : k ≤ r) (hr : r ≤ n) :
    kthShadow (elemSymmSupport n r) k = elemSymmSupport n (r - k) :=
  Finset.Subset.antisymm
    (kthShadow_elemSymm_subset hk hr)
    (elemSymm_subset_kthShadow hk hr)

/-- **Exact shadow profile for elementary symmetric polynomials.**
`|Shadow_k(supp(e_r))| = C(n, r - k)`.

This gives a complete, computable calibration family for the shadow decay
framework and provides a benchmark against which circuit envelopes can be tested. -/
theorem shadowProfile_elemSymm (hk : k ≤ r) (hr : r ≤ n) :
    shadowProfile (elemSymmSupport n r) k = Nat.choose n (r - k) := by
  simp only [shadowProfile, kthShadow_elemSymm_eq hk hr]
  exact elemSymmSupport_card (Nat.le_trans (Nat.sub_le r k) hr)

/-! ## Degree Simplex Lattice Point Count -/

/-
The number of lattice points in the degree-d simplex in n variables
equals `Nat.choose (n + d) n` (stars and bars).
-/
set_option maxHeartbeats 800000 in
theorem degreeSimplex_card :
    (degreeSimplex n d).card = Nat.choose (n + d) n := by
  have h_card : Finset.card (Finset.filter (fun m : Fin n → ℕ => ∑ i, m i ≤ d) (Finset.Iic (d • 1))) = Nat.choose (n + d) n := by
    have h_card : ∀ (n d : ℕ), Finset.card (Finset.filter (fun m : Fin n → ℕ => ∑ i, m i ≤ d) (Finset.Iic (d • 1))) = Nat.choose (n + d) n := by
      intros n d;
      induction' n with n ih generalizing d;
      · simp +zetaDelta at *;
        rfl;
      · -- For the inductive step, we can split the sum into two parts: one where the first element is 0 and one where it is at least 1.
        have h_split : Finset.filter (fun m : Fin (n + 1) → ℕ => ∑ i, m i ≤ d) (Finset.Iic (d • 1)) = Finset.biUnion (Finset.range (d + 1)) (fun k => Finset.image (fun m : Fin n → ℕ => Fin.cons k m) (Finset.filter (fun m : Fin n → ℕ => ∑ i, m i ≤ d - k) (Finset.Iic ((d - k) • 1)))) := by
          ext m; simp [Finset.mem_biUnion, Finset.mem_image];
          constructor;
          · intro hm;
            refine' ⟨ m 0, _, Fin.tail m, _, _ ⟩ <;> simp_all +decide [ Fin.sum_univ_succ ];
            · exact le_trans ( Nat.le_add_right _ _ ) hm.2;
            · exact ⟨ fun i => Nat.le_sub_of_add_le <| by linarith! [ hm.1 i.succ, Finset.single_le_sum ( fun a _ => Nat.zero_le ( m ( Fin.succ a ) ) ) ( Finset.mem_univ i ) ], Nat.le_sub_of_add_le <| by linarith! ⟩;
          · rintro ⟨ a, ha, b, hb, rfl ⟩ ; simp_all +decide [ Fin.sum_univ_succ ];
            exact ⟨ fun i => by cases i using Fin.inductionOn <;> [ exact ha; exact le_trans ( hb.1 _ ) ( by simp +decide [ Nat.sub_le ] ) ], by linarith [ Nat.sub_add_cancel ha ] ⟩;
        rw [ h_split, Finset.card_biUnion ];
        · rw [ Finset.sum_congr rfl fun _ _ => Finset.card_image_of_injective _ <| fun _ _ h => by simpa [ Fin.ext_iff ] using h ];
          rw [ Finset.sum_congr rfl fun x hx => ih _ ];
          exact Nat.recOn d ( by norm_num ) fun d ih => by simp_all +decide [ Nat.choose, add_comm, add_left_comm, add_assoc, Finset.sum_range_succ' ] ;
        · intros k hk l hl hkl; simp_all +decide [ Finset.disjoint_left ];
          intro a x hx₁ hx₂ hx₃ y hy₁ hy₂ hy₃; contrapose! hkl; aesop;
    exact h_card n d;
  convert h_card using 2;
  ext; simp [degreeSimplex];
  exact ⟨ fun h => ⟨ fun i => h.1 i, h.2 ⟩, fun h => ⟨ fun i => h.1 i, h.2 ⟩ ⟩

/-- **Shadow profile bounded by binomial coefficient.**
For any support S with all elements of total degree ≤ d:
`|Shadow_k(S)| ≤ C(n + (d - k), n)`. -/
theorem shadowProfile_le_simplexLatticeCount
    {d k : ℕ} {S : Finset (Fin n → ℕ)}
    (hdeg : ∀ m ∈ S, totalDeg m ≤ d) :
    shadowProfile S k ≤ Nat.choose (n + (d - k)) n := by
  calc shadowProfile S k
      ≤ (degreeSimplex n (d - k)).card :=
        shadowProfile_le_degreeSimplex_card hdeg
    _ = Nat.choose (n + (d - k)) n := degreeSimplex_card

end ShadowDecay