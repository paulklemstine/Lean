import Cryptography.DegreeTenCyclotomic.Channel

/-!
# The tower `ℚ ⊂ ℚ(ζ₁₁)⁺ ⊂ ℚ(ζ₁₁)`: real subfield, CRT splitting and the tower bit

* `entropy_prod_indep` — entropy is additive for independent readouts on a product space.
* `deg10_crt_split` — `C₁₀ = C₂ × C₅` makes the type entropy split additively.
* `deg5_real_entropy`, `deg5_real_full_pinning` — the degree-5 real subfield is also fully
  pinned by `p mod 11`, with `H(T⁺) = log₂ 5 − 8/5`.
* `tower_bit` — `H(T | T⁺) = 1` bit exactly.
-/

namespace DegreeTen

open TypeChannel Finset Real

set_option maxRecDepth 4000000

/-! ### Entropy of independent readouts on a product sample space -/

section Product

variable {Ω₁ Ω₂ α β : Type*} [DecidableEq α] [DecidableEq β]

/-- **Additivity of entropy for independent readouts.**  On a product sample space
`S₁ × S₂` (independent uniform coordinates), the joint readout `(f(x), g(y))` has entropy
`H(f) + H(g)`. -/
theorem entropy_prod_indep (S₁ : Finset Ω₁) (S₂ : Finset Ω₂) (f : Ω₁ → α) (g : Ω₂ → β)
    (h1 : S₁.Nonempty) (h2 : S₂.Nonempty) :
    entropy (S₁ ×ˢ S₂) (fun q => (f q.1, g q.2)) = entropy S₁ f + entropy S₂ g := by
  set F : Ω₁ × Ω₂ → α × β := fun q => (f q.1, g q.2) with hF
  have hfib : ∀ a b, fiber (S₁ ×ˢ S₂) F (a, b) = fiber S₁ f a ×ˢ fiber S₂ g b := by
    intro a b; ext ⟨x, y⟩
    simp only [fiber, hF, mem_filter, mem_product, Prod.mk.injEq]
    tauto
  have hprob : ∀ a b, prob (S₁ ×ˢ S₂) F (a, b) = prob S₁ f a * prob S₂ g b := by
    intro a b
    simp only [prob, hfib, card_product, Nat.cast_mul]
    rw [div_mul_div_comm]
  have himg : (S₁ ×ˢ S₂).image F ⊆ S₁.image f ×ˢ S₂.image g := by
    intro x hx
    obtain ⟨⟨u, v⟩, huv, rfl⟩ := mem_image.mp hx
    obtain ⟨hu, hv⟩ := mem_product.mp huv
    exact mem_product.mpr ⟨mem_image_of_mem _ hu, mem_image_of_mem _ hv⟩
  have hterm : ∀ a ∈ S₁.image f, ∀ b ∈ S₂.image g,
      -(prob (S₁ ×ˢ S₂) F (a, b) * logb 2 (prob (S₁ ×ˢ S₂) F (a, b))) =
        prob S₂ g b * (-(prob S₁ f a * logb 2 (prob S₁ f a))) +
          prob S₁ f a * (-(prob S₂ g b * logb 2 (prob S₂ g b))) := by
    intro a ha b hb
    rw [hprob, Real.logb_mul (prob_pos_of_mem ha).ne' (prob_pos_of_mem hb).ne']
    ring
  rw [entropy_eq_sum_of_subset himg, Finset.sum_product]
  rw [Finset.sum_congr rfl (fun a ha => Finset.sum_congr rfl (fun b hb => hterm a ha b hb))]
  simp only [Finset.sum_add_distrib, ← Finset.sum_mul, ← Finset.mul_sum]
  rw [sum_prob h2, sum_prob h1]
  unfold entropy
  ring

end Product

/-! ### The tower `ℚ ⊂ ℚ(ζ₁₁)⁺ ⊂ ℚ(ζ₁₁)` and the CRT splitting `C₁₀ = C₂ × C₅` -/

/-- Frobenius type in the maximal real subfield `ℚ(ζ₁₁)⁺` (degree 5): the order of the image
of `p` in `(ℤ/11)ˣ/{±1}`, computed as `ord(p²)` (squaring identifies the quotient with the
subgroup of squares). -/
def plusType (g : U11) : ℕ := frobType (g ^ 2)

/-- Squaring has kernel exactly `{±1}`: it realises `(ℤ/11)ˣ/{±1}` faithfully. -/
theorem sq_eq_sq_iff (g h : U11) : g ^ 2 = h ^ 2 ↔ g = h ∨ g = -h := by
  revert g h; decide

/-- The `C₂` factor `{±1}`: Frobenius in `ℚ(√−11)`. -/
def S2 : Finset U11 := {1, -1}

/-- The `C₅` factor: the squares, `Gal(ℚ(ζ₁₁)/ℚ(√−11))`. -/
def S5 : Finset U11 := univ.image (· ^ 2)

/-- CRT coordinates `g ↦ (g⁵, g²) ∈ C₂ × C₅`. -/
def crt (g : U11) : U11 × U11 := (g ^ 5, g ^ 2)

lemma crt_injective : Function.Injective crt := by decide

lemma crt_image : univ.image crt = S2 ×ˢ S5 := by decide

/-- The type multiplies across the CRT splitting: `ord(g) = ord(g⁵) · ord(g²)`. -/
lemma frobType_crt (g : U11) : frobType g = frobType (g ^ 5) * frobType (g ^ 2) := by
  revert g; decide

/-- **CRT additivity of type entropy.**  `H(T) = H(T | C₂-factor) + H(T | C₅-factor)`:
the degree-ten type entropy is the sum of the type entropies of the two prime-degree
layers `ℚ(√−11)` and the quintic layer. -/
theorem deg10_crt_split :
    entropy (univ : Finset U11) frobType = entropy S2 frobType + entropy S5 frobType := by
  have h1 : entropy (univ : Finset U11) frobType =
      entropy (univ : Finset U11) (fun g => (fun q : ℕ × ℕ => q.1 * q.2)
        ((fun q : U11 × U11 => (frobType q.1, frobType q.2)) (crt g))) :=
    entropy_congr (fun g _ => frobType_crt g)
  have hinj : Set.InjOn (fun q : ℕ × ℕ => q.1 * q.2)
      ((univ : Finset U11).image (fun g => (fun q : U11 × U11 => (frobType q.1, frobType q.2))
        (crt g)) : Set (ℕ × ℕ)) := by
    rw [Finset.coe_image]
    rintro _ ⟨x, -, rfl⟩ _ ⟨y, -, rfl⟩ hxy
    revert x y; decide
  rw [h1, entropy_comp_of_injOn hinj]
  rw [← entropy_image_of_injOn (crt_injective.injOn) (fun q : U11 × U11 =>
    (frobType q.1, frobType q.2)), crt_image]
  exact entropy_prod_indep S2 S5 frobType frobType ⟨1, by decide⟩ ⟨1, by decide⟩

theorem S2_type_entropy : entropy S2 frobType = 1 := by
  have hcard : S2.card = 2 := by decide
  rw [entropy_eq_sumList (A := [1, 2]) (L := [1, 1]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 2 (by norm_num) (by norm_num), logb2_two, Real.logb_one]
  ring

theorem S5_type_entropy : entropy S5 frobType = logb 2 5 - 8/5 := by
  have hcard : S5.card = 5 := by decide
  rw [entropy_eq_sumList (A := [1, 5]) (L := [1, 4]) (by decide) (by decide) (by decide), hcard]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
  rw [neg_prob_logb_real 1 5 (by norm_num) (by norm_num),
    neg_prob_logb_real 4 5 (by norm_num) (by norm_num), logb2_four, Real.logb_one]
  ring

/-- **Type entropy of the degree-5 real subfield**: `H(T⁺) = log₂ 5 − 8/5 ≈ 0.7219`. -/
theorem deg5_real_entropy : entropy (univ : Finset U11) plusType = logb 2 5 - 8/5 := by
  rw [entropy_eq_sumList (A := [1, 5]) (L := [2, 8]) (by decide) (by decide) (by decide),
    U11_card]
  simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat]
  rw [neg_prob_logb_real 2 10 (by norm_num) (by norm_num),
    neg_prob_logb_real 8 10 (by norm_num) (by norm_num), logb2_five_ten, logb2_two, logb2_eight]
  ring

/-- **Full pinning in the real subfield** (degree 5, conductor 11): the same residue
`p mod 11` reads the real-subfield type completely. -/
theorem deg5_real_full_pinning :
    mutualInfo (univ : Finset U11) resid plusType = logb 2 5 - 8/5 := by
  rw [(abelian_full_pinning resid_injective plusType).1, deg5_real_entropy]

/-- **The tower bit.**  Passing from the real subfield to the full cyclotomic field adds
exactly one bit of type information: `H(T | T⁺) = 1 = log₂ [ℚ(ζ₁₁) : ℚ(ζ₁₁)⁺]`. -/
theorem tower_bit : condEntropy (univ : Finset U11) frobType plusType = 1 := by
  have hj : entropy (univ : Finset U11) (pairObs plusType frobType) = logb 2 5 - 3/5 := by
    rw [entropy_eq_sumList (A := [(1, 1), (1, 2), (5, 5), (5, 10)]) (L := [1, 1, 4, 4])
      (by decide) (by decide) (by decide), U11_card]
    simp only [List.map, List.sum_cons, List.sum_nil, Nat.cast_ofNat, Nat.cast_one]
    rw [neg_prob_logb_real 1 10 (by norm_num) (by norm_num),
      neg_prob_logb_real 4 10 (by norm_num) (by norm_num), logb2_five_ten, logb2_four,
      Real.logb_one]
    ring
  rw [condEntropy, hj, deg5_real_entropy]
  ring

/-- The CRT split, evaluated: `log₂ 5 − 3/5 = 1 + (log₂ 5 − 8/5)`; the real-subfield entropy
is exactly the `C₅`-layer entropy. -/
theorem deg10_crt_values :
    entropy (univ : Finset U11) frobType = 1 + entropy (univ : Finset U11) plusType ∧
      entropy (univ : Finset U11) plusType = entropy S5 frobType := by
  rw [deg10_crt_split, S2_type_entropy, S5_type_entropy, deg5_real_entropy]
  exact ⟨rfl, rfl⟩

end DegreeTen