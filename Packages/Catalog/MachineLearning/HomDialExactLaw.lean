/-
# The exact law for homomorphic dials, and the absence of a semiprime bonus

Fourth cycle of the thread.  Cycles 1–2 computed the degree-five endpoints (`S₅`: one bit,
`A₅`: zero) and proved the general *inequality* `I(φ ; T) ≤ log₂ |G^ab|`
(`QuinticS5A5.abelianization_cap`).  Cycle 3 lifted the one-bit law to the whole symmetric
tower.  Here the inequality is upgraded to an **exact formula** under the only hypothesis the
examples ever used, and the formula is shown to be insensitive to how many primes the dial
multiplies together.

## Results

* `hom_fiber_card_eq`, `card_image_mul_card_ker_filter` — the fibres of a homomorphism on a
  finite group are equinumerous and there are `|image φ|` of them.
* `uEnt_hom_eq_logb_image` — `H(φ) = log₂ |image φ|`: a homomorphic dial is exactly uniform
  on its image, so it attains the maximum-entropy bound `uEnt_le_logb_card_image`.
* `hom_dial_exact_law` — **the exact law**: if the read-out `T` refines the dial
  (`T x = T y → φ x = φ y`, which is what "the splitting type determines the character" says),
  then `I(φ ; T) = log₂ |image φ|`, with no inequality left.
* `prodHom`, `image_prodHom`, `product_channel_no_bonus` — **no almost-prime bonus**: for the
  `k`-fold product dial `x ↦ φ(x₁)···φ(x_k)` on `k` independent Frobenius elements, with the
  tuple of types as read-out, the transmitted information is again `log₂ |image φ|`,
  independent of `k ≥ 1`.
* `sign_exact_law_five`, `product_no_bonus_five` — the degree-five instances: the `S₅` one-bit
  law and its semiprime version, recovered from the general theorems.
-/
import MachineLearning.SymmetricTowerOneBitLaw

namespace QuinticS5A5

open Finset Equiv CyclicTypeChannel

set_option maxRecDepth 100000

section HomDial

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]
  {M : Type*} [Group M] [DecidableEq M]

omit [DecidableEq G] in
/-- All fibres of a homomorphism have the size of the kernel. -/
theorem hom_fiber_card_eq (φ : G →* M) (a : G) :
    (#{x ∈ (univ : Finset G) | φ x = φ a} : ℕ) = (#{x ∈ (univ : Finset G) | φ x = 1} : ℕ) := by
  classical
  refine Finset.card_nbij' (fun x => a⁻¹ * x) (fun x => a * x) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hx ⊢
    rw [map_mul, map_inv, hx, inv_mul_cancel]
  · intro x hx
    simp only [Finset.coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hx ⊢
    rw [map_mul, hx, mul_one]
  · intro x _
    simp
  · intro x _
    simp

omit [DecidableEq G] in
/-- The group is partitioned into `|image φ|` fibres, each of the size of the kernel. -/
theorem card_image_mul_card_ker_filter (φ : G →* M) :
    ((univ : Finset G).image (fun g => φ g)).card * (#{x ∈ (univ : Finset G) | φ x = 1} : ℕ)
      = Fintype.card G := by
  classical
  have hpart := Finset.card_eq_sum_card_fiberwise
    (f := fun g : G => φ g) (s := (univ : Finset G))
    (t := (univ : Finset G).image (fun g => φ g)) (fun x _ => mem_image_of_mem _ (mem_univ x))
  have hconst : ∀ v ∈ (univ : Finset G).image (fun g => φ g),
      (#{x ∈ (univ : Finset G) | φ x = v} : ℕ) = (#{x ∈ (univ : Finset G) | φ x = 1} : ℕ) := by
    intro v hv
    obtain ⟨a, _, rfl⟩ := mem_image.1 hv
    exact hom_fiber_card_eq φ a
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, smul_eq_mul] at hpart
  rw [← hpart, Finset.card_univ]

omit [DecidableEq G] in
/-- **A homomorphic dial is uniform on its image**: `H(φ) = log₂ |image φ|`, so it saturates
the maximum-entropy bound. -/
theorem uEnt_hom_eq_logb_image (φ : G →* M) :
    uEnt (univ : Finset G) (fun g => φ g)
      = Real.logb 2 (((univ : Finset G).image (fun g => φ g)).card : ℝ) := by
  classical
  have hker : 0 < (#{x ∈ (univ : Finset G) | φ x = 1} : ℕ) :=
    card_pos.2 ⟨1, by simp⟩
  have himg : 0 < ((univ : Finset G).image (fun g => φ g)).card :=
    card_pos.2 ⟨φ 1, mem_image.2 ⟨1, mem_univ _, rfl⟩⟩
  have h := QuinticF20.uEnt_eq_logb_of_uniform_fibers (s := (univ : Finset G))
    (g := fun g => φ g) (c := (#{x ∈ (univ : Finset G) | φ x = 1} : ℕ))
    ⟨1, mem_univ _⟩ (fun a _ => hom_fiber_card_eq φ a)
  have hcard : (Fintype.card G : ℕ)
      = ((univ : Finset G).image (fun g => φ g)).card
        * (#{x ∈ (univ : Finset G) | φ x = 1} : ℕ) := (card_image_mul_card_ker_filter φ).symm
  rw [h, Finset.card_univ, hcard]
  push_cast
  rw [Real.logb_mul (by positivity) (by positivity)]
  ring

omit [DecidableEq G] in
/-- **The exact law for homomorphic dials.**  If the read-out `T` refines the dial `φ` — the
formal content of "the splitting type determines the character" — then the information
transmitted is exactly `log₂ |image φ|`. -/
theorem hom_dial_exact_law {β : Type*} [DecidableEq β] (φ : G →* M) (T : G → β)
    (hT : ∀ x y : G, T x = T y → φ x = φ y) :
    mutInfo (univ : Finset G) (fun g => φ g) T
      = Real.logb 2 (((univ : Finset G).image (fun g => φ g)).card : ℝ) := by
  rw [mutInfo_eq_uEnt_of_factors (fun x _ y _ h => hT x y h), uEnt_hom_eq_logb_image]

end HomDial

/-! ## The `k`-fold (almost-prime) channel -/

section Product

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]
  {M : Type*} [CommGroup M] [DecidableEq M]

/-- The dial of a `k`-almost-prime: the product of the dials of its `k` prime factors. -/
def prodHom (φ : G →* M) (k : ℕ) : (Fin k → G) →* M where
  toFun x := ∏ i, φ (x i)
  map_one' := by simp
  map_mul' a b := by simp [Finset.prod_mul_distrib]

omit [Fintype G] [DecidableEq G] [DecidableEq M] in
@[simp] lemma prodHom_apply (φ : G →* M) (k : ℕ) (x : Fin k → G) :
    prodHom φ k x = ∏ i, φ (x i) := rfl

omit [DecidableEq G] in
/-- The product dial has the same image as the single dial, for every `k ≥ 1`. -/
theorem image_prodHom (φ : G →* M) {k : ℕ} (hk : 0 < k) :
    (univ : Finset (Fin k → G)).image (fun x => prodHom φ k x)
      = (univ : Finset G).image (fun g => φ g) := by
  classical
  ext v
  simp only [mem_image, mem_univ, true_and]
  constructor
  · rintro ⟨x, rfl⟩
    have hmem : (∏ i, φ (x i)) ∈ φ.range :=
      Subgroup.prod_mem φ.range fun i _ => MonoidHom.mem_range.2 ⟨x i, rfl⟩
    obtain ⟨g, hg⟩ := hmem
    exact ⟨g, hg⟩
  · rintro ⟨g, rfl⟩
    refine ⟨fun i => if i = (⟨0, hk⟩ : Fin k) then g else 1, ?_⟩
    rw [prodHom_apply, Finset.prod_eq_single (⟨0, hk⟩ : Fin k)]
    · simp
    · intro b _ hb
      simp [hb]
    · intro h
      simp at h

omit [DecidableEq G] in
/-- **No almost-prime bonus.**  If the type read-out refines the dial, then the `k`-fold
product channel transmits exactly the same `log₂ |image φ|` bits as a single prime, for every
`k ≥ 1`: multiplying primes together adds no abelian information. -/
theorem product_channel_no_bonus {β : Type*} [DecidableEq β] (φ : G →* M) (T : G → β)
    (hT : ∀ x y : G, T x = T y → φ x = φ y) {k : ℕ} (hk : 0 < k) :
    mutInfo (univ : Finset (Fin k → G)) (fun x => prodHom φ k x) (fun x i => T (x i))
      = mutInfo (univ : Finset G) (fun g => φ g) T := by
  classical
  have hT' : ∀ x y : Fin k → G, (fun i => T (x i)) = (fun i => T (y i)) →
      prodHom φ k x = prodHom φ k y := by
    intro x y h
    simp only [prodHom_apply]
    exact Finset.prod_congr rfl fun i _ => hT _ _ (congrFun h i)
  rw [hom_dial_exact_law (prodHom φ k) _ hT', hom_dial_exact_law φ T hT, image_prodHom φ hk]

end Product

/-! ## The degree-five instances -/

lemma image_sign_card_five :
    (((univ : Finset (Perm (Fin 5))).image (fun σ => Perm.sign σ)).card : ℕ) = 2 := by decide

/-- The `S₅` one-bit law, as the instance `|image sign| = 2` of the exact law. -/
theorem sign_exact_law_five :
    mutInfo (univ : Finset (Perm (Fin 5))) (fun σ => Perm.sign σ) (fun σ => σ.cycleType) = 1 := by
  rw [hom_dial_exact_law (Perm.sign : Perm (Fin 5) →* ℤˣ) (fun σ => σ.cycleType)
      (fun x y h => sign_of_cycleType_eq h), image_sign_card_five]
  norm_num

/-- The `S₅` semiprime channel again: `k` primes, still one bit. -/
theorem product_no_bonus_five {k : ℕ} (hk : 0 < k) :
    mutInfo (univ : Finset (Fin k → Perm (Fin 5)))
        (fun x => prodHom (Perm.sign : Perm (Fin 5) →* ℤˣ) k x) (fun x i => (x i).cycleType)
      = 1 := by
  rw [product_channel_no_bonus (Perm.sign : Perm (Fin 5) →* ℤˣ) (fun σ => σ.cycleType)
      (fun x y h => sign_of_cycleType_eq h) hk]
  exact sign_exact_law_five

end QuinticS5A5