/-
# Uniform covers and conductor-independence of the whole subfield channel

`Bridges.CyclicSubfieldTypeChannel` transferred the entropy of a *single* periodic
read-out from the big exponent range `range n` down to `range m`.  The semiprime
type-pair channel lives on the two-dimensional box `box n = range n ×ˢ range n`, so
that argument does not apply directly.

This file isolates the right abstraction: a **uniform cover** `φ : s → t`, i.e. a
map all of whose fibres have the same cardinality `r > 0`.  For such a map every
read-out pulled back along `φ` has the same entropy, the same conditional entropy
and hence the same mutual information as downstairs:

* `card_fiber_of_uniform_cover`, `card_of_uniform_cover`;
* `uEnt_of_uniform_cover`, `condEnt_of_uniform_cover`, `mutInfo_of_uniform_cover`.

The reduction `redPair m : box (m * k) → box m`, `(a,b) ↦ (a mod m, b mod m)`, is a
uniform cover with `r = k²`.  Since the type pair and the product residue of a
semiprime only depend on the exponents mod `m`, this yields

* `Ipair_subfield` — the semiprime type-pair channel of the degree-`m` subfield is
  the intrinsic `C m` value `Ipair m`, at **every** conductor;
* `conductor13_pair_channel` — at conductor `13` the cubic semiprime channel is
  exactly `log₂ 3 - 10/9`, and `conductor13_pair_defect` — the pinning defect
  against the single-prime channel is exactly `4/9` bits, computed over the honest
  `144`-element box of exponent pairs mod `12`.
-/
import Bridges.CyclicCubicConductor13

namespace CyclicSubfield

open Finset hiding box
open CyclicTypeChannel

/-! ## 1. Uniform covers -/

variable {α α' β γ : Type*} [DecidableEq α'] [DecidableEq β] [DecidableEq γ]

/-- The fibre of a pulled-back read-out is `r` times the downstairs fibre. -/
theorem card_fiber_of_uniform_cover {s : Finset α} {t : Finset α'} {φ : α → α'} {r : ℕ}
    (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r)
    (h' : α' → β) (v : β) :
    #{x ∈ s | h' (φ x) = v} = r * #{y ∈ t | h' y = v} := by
  classical
  have hsplit : {x ∈ s | h' (φ x) = v}
      = ({y ∈ t | h' y = v}).biUnion (fun y => {x ∈ s | φ x = y}) := by
    ext x
    simp only [mem_filter, mem_biUnion]
    constructor
    · rintro ⟨hx, hv⟩
      exact ⟨φ x, ⟨hmaps x hx, hv⟩, hx, rfl⟩
    · rintro ⟨y, ⟨_, hv⟩, hx, rfl⟩
      exact ⟨hx, hv⟩
  have hdisj : ∀ y ∈ {y ∈ t | h' y = v}, ∀ z ∈ {y ∈ t | h' y = v}, y ≠ z →
      Disjoint {x ∈ s | φ x = y} {x ∈ s | φ x = z} := by
    intro y _ z _ hyz
    refine Finset.disjoint_left.2 fun x hx hx' => ?_
    simp only [mem_filter] at hx hx'
    exact hyz (hx.2 ▸ hx'.2 ▸ rfl)
  rw [hsplit, Finset.card_biUnion hdisj]
  rw [Finset.sum_congr rfl (fun y hy => hfib y (mem_filter.1 hy).1)]
  simp [Nat.mul_comm]

/-- The total sizes are in the ratio `r`. -/
theorem card_of_uniform_cover {s : Finset α} {t : Finset α'} {φ : α → α'} {r : ℕ}
    (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r) :
    s.card = r * t.card := by
  classical
  have h := card_fiber_of_uniform_cover (β := Unit) hmaps hfib (fun _ => ()) ()
  simpa using h

/-- Downstairs values are all attained: a uniform cover with `r > 0` is onto. -/
theorem surj_of_uniform_cover {s : Finset α} {t : Finset α'} {φ : α → α'} {r : ℕ}
    (hr : 0 < r) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r) {y : α'} (hy : y ∈ t) :
    ∃ x ∈ s, φ x = y := by
  have : 0 < #{x ∈ s | φ x = y} := by rw [hfib y hy]; exact hr
  obtain ⟨x, hx⟩ := Finset.card_pos.1 this
  exact ⟨x, (mem_filter.1 hx).1, (mem_filter.1 hx).2⟩

/-- **Entropy is invariant under uniform covers.** -/
theorem uEnt_of_uniform_cover {s : Finset α} {t : Finset α'} {φ : α → α'} {r : ℕ}
    (hr : 0 < r) (ht : t.Nonempty)
    (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r)
    (h' : α' → β) :
    uEnt s (h' ∘ φ) = uEnt t h' := by
  classical
  obtain ⟨y₀, hy₀⟩ := ht
  obtain ⟨x₀, hx₀, -⟩ := surj_of_uniform_cover hr hfib hy₀
  have hs : s.Nonempty := ⟨x₀, hx₀⟩
  have himg : s.image (h' ∘ φ) = t.image h' := by
    apply Finset.Subset.antisymm
    · intro v hv
      obtain ⟨x, hx, rfl⟩ := mem_image.1 hv
      exact mem_image.2 ⟨φ x, hmaps x hx, rfl⟩
    · intro v hv
      obtain ⟨y, hy, rfl⟩ := mem_image.1 hv
      obtain ⟨x, hx, hxy⟩ := surj_of_uniform_cover hr hfib hy
      exact mem_image.2 ⟨x, hx, by simp [Function.comp, hxy]⟩
  have hcards := card_of_uniform_cover hmaps hfib
  have hrR : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr
  rw [uEnt_eq_shannon hs, uEnt_eq_shannon ⟨y₀, hy₀⟩, himg]
  refine Finset.sum_congr rfl fun v _ => ?_
  have hfibv := card_fiber_of_uniform_cover hmaps hfib h' v
  have hprob : (#{x ∈ s | (h' ∘ φ) x = v} : ℝ) / (s.card : ℝ)
      = (#{y ∈ t | h' y = v} : ℝ) / (t.card : ℝ) := by
    have : {x ∈ s | (h' ∘ φ) x = v} = {x ∈ s | h' (φ x) = v} := rfl
    rw [this, hfibv, hcards]
    push_cast
    rw [mul_div_mul_left _ _ (ne_of_gt hrR)]
  rw [hprob]

/-- **Conditional entropy is invariant under uniform covers.** -/
theorem condEnt_of_uniform_cover {s : Finset α} {t : Finset α'} {φ : α → α'} {r : ℕ}
    (hr : 0 < r) (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r)
    (h' : α' → β) (k' : α' → γ) :
    condEnt s (h' ∘ φ) (k' ∘ φ) = condEnt t h' k' := by
  classical
  have hcards := card_of_uniform_cover hmaps hfib
  have hrR : (0 : ℝ) < (r : ℝ) := by exact_mod_cast hr
  have himg : s.image (k' ∘ φ) = t.image k' := by
    apply Finset.Subset.antisymm
    · intro v hv
      obtain ⟨x, hx, rfl⟩ := mem_image.1 hv
      exact mem_image.2 ⟨φ x, hmaps x hx, rfl⟩
    · intro v hv
      obtain ⟨y, hy, rfl⟩ := mem_image.1 hv
      obtain ⟨x, hx, hxy⟩ := surj_of_uniform_cover hr hfib hy
      exact mem_image.2 ⟨x, hx, by simp [Function.comp, hxy]⟩
  rw [condEnt, condEnt, himg]
  refine Finset.sum_congr rfl fun c hc => ?_
  -- the restricted cover
  have hmaps' : ∀ x ∈ {x ∈ s | (k' ∘ φ) x = c}, φ x ∈ {y ∈ t | k' y = c} := by
    intro x hx
    simp only [mem_filter, Function.comp] at hx ⊢
    exact ⟨hmaps x hx.1, hx.2⟩
  have hfib' : ∀ y ∈ {y ∈ t | k' y = c}, #{x ∈ {x ∈ s | (k' ∘ φ) x = c} | φ x = y} = r := by
    intro y hy
    simp only [mem_filter] at hy
    have hset : {x ∈ {x ∈ s | (k' ∘ φ) x = c} | φ x = y} = {x ∈ s | φ x = y} := by
      ext x
      simp only [mem_filter, Function.comp]
      constructor
      · rintro ⟨⟨hx, -⟩, hxy⟩; exact ⟨hx, hxy⟩
      · rintro ⟨hx, hxy⟩; exact ⟨⟨hx, by rw [hxy, hy.2]⟩, hxy⟩
    rw [hset, hfib y hy.1]
  have htc : ({y ∈ t | k' y = c}).Nonempty := by
    obtain ⟨y, hy, rfl⟩ := mem_image.1 hc
    exact ⟨y, mem_filter.2 ⟨hy, rfl⟩⟩
  have hEnt := uEnt_of_uniform_cover hr htc hmaps' hfib' h'
  have hweight : (#{x ∈ s | (k' ∘ φ) x = c} : ℝ) / (s.card : ℝ)
      = (#{y ∈ t | k' y = c} : ℝ) / (t.card : ℝ) := by
    have hcf : #{x ∈ s | (k' ∘ φ) x = c} = r * #{y ∈ t | k' y = c} :=
      card_fiber_of_uniform_cover hmaps hfib k' c
    rw [hcf, hcards]
    push_cast
    rw [mul_div_mul_left _ _ (ne_of_gt hrR)]
  rw [hweight, hEnt]

/-- **Mutual information is invariant under uniform covers.** -/
theorem mutInfo_of_uniform_cover {s : Finset α} {t : Finset α'} {φ : α → α'} {r : ℕ}
    (hr : 0 < r) (ht : t.Nonempty)
    (hmaps : ∀ x ∈ s, φ x ∈ t) (hfib : ∀ y ∈ t, #{x ∈ s | φ x = y} = r)
    (h' : α' → β) (k' : α' → γ) :
    mutInfo s (h' ∘ φ) (k' ∘ φ) = mutInfo t h' k' := by
  rw [mutInfo, mutInfo, uEnt_of_uniform_cover hr ht hmaps hfib h',
    condEnt_of_uniform_cover hr hmaps hfib h' k']

/-! ## 2. The pair reduction is a uniform cover -/

/-- Reduction of a pair of Frobenius exponents to the subfield. -/
def redPair (m : ℕ) (x : ℕ × ℕ) : ℕ × ℕ := (x.1 % m, x.2 % m)

/-- The one-dimensional fibre of `a ↦ a mod m` over a residue `y < m` inside
`range (m * k)` has exactly `k` elements. -/
theorem card_fiber_mod {m k y : ℕ} (hm : 0 < m) (hy : y < m) :
    #{a ∈ range (m * k) | a % m = y} = k := by
  have hper : ModPeriodic m (fun a => a % m) := by
    intro a; simp [Nat.mod_mod_of_dvd]
  have h := card_fiber_of_modPeriodic (k := k) hm hper y
  have hsmall : #{a ∈ range m | a % m = y} = 1 := by
    have : {a ∈ range m | a % m = y} = {y} := by
      ext a
      simp only [mem_filter, mem_range, mem_singleton]
      constructor
      · rintro ⟨ha, rfl⟩; exact (Nat.mod_eq_of_lt ha).symm
      · rintro rfl; exact ⟨hy, Nat.mod_eq_of_lt hy⟩
    rw [this, card_singleton]
  rw [h, hsmall, Nat.mul_one]

/-- `redPair m` maps the big box into the small box. -/
theorem redPair_maps {m k : ℕ} (hm : 0 < m) :
    ∀ x ∈ box (m * k), redPair m x ∈ box m := by
  intro x _
  simp only [box, Finset.mem_product, mem_range, redPair]
  exact ⟨Nat.mod_lt _ hm, Nat.mod_lt _ hm⟩

/-- **`redPair m` is a uniform cover of the small box with fibre size `k²`.** -/
theorem redPair_fib {m k : ℕ} (hm : 0 < m) :
    ∀ y ∈ box m, #{x ∈ box (m * k) | redPair m x = y} = k * k := by
  intro y hy
  simp only [box, Finset.mem_product, mem_range] at hy
  have hset : {x ∈ box (m * k) | redPair m x = y}
      = {a ∈ range (m * k) | a % m = y.1} ×ˢ {b ∈ range (m * k) | b % m = y.2} := by
    ext x
    simp only [box, mem_filter, Finset.mem_product, mem_range, redPair, Prod.ext_iff]
    tauto
  rw [hset, Finset.card_product, card_fiber_mod hm hy.1, card_fiber_mod hm hy.2]

/-- The unordered type pair of a semiprime only depends on the exponents mod `m`. -/
theorem typePair_comp_redPair (m : ℕ) : typePair m ∘ redPair m = typePair m := by
  funext x
  simp [Function.comp, typePair, redPair, ordType_mod]

/-- The residue of the semiprime only depends on the exponents mod `m`. -/
theorem prodRes_comp_redPair (m : ℕ) : prodRes m ∘ redPair m = prodRes m := by
  funext x
  simp [Function.comp, prodRes, redPair, Nat.add_mod]

/-! ## 3. Conductor-independence of the semiprime pair channel -/

/-- **The subfield semiprime channel is conductor-independent.**  For a cyclic
extension of degree `n = m * k`, the type-pair channel of the degree-`m` subfield,
computed over the full `n²`-element box of exponent pairs, equals the intrinsic
`C m` value `Ipair m`. -/
theorem Ipair_subfield {m k : ℕ} (hm : 0 < m) (hk : 0 < k) :
    mutInfo (box (m * k)) (typePair m) (prodRes m) = Ipair m := by
  have hb : (box m).Nonempty := by
    refine ⟨(0, 0), ?_⟩
    simp only [box, Finset.mem_product, mem_range]
    exact ⟨hm, hm⟩
  have h := mutInfo_of_uniform_cover (s := box (m * k)) (t := box m) (φ := redPair m)
    (r := k * k) (by positivity) hb (redPair_maps hm) (redPair_fib hm)
    (typePair m) (prodRes m)
  rw [typePair_comp_redPair, prodRes_comp_redPair] at h
  exact h

/-- The divisor form. -/
theorem Ipair_subfield_of_dvd {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (hmn : m ∣ n) :
    mutInfo (box n) (typePair m) (prodRes m) = Ipair m := by
  obtain ⟨k, rfl⟩ := hmn
  have hk : 0 < k := by
    rcases Nat.eq_zero_or_pos k with rfl | hk
    · simp at hn
    · exact hk
  exact Ipair_subfield hm hk

/-- **The conductor-13 cubic semiprime channel.**  Over the honest `144`-element
box of exponent pairs of `Q(ζ₁₃)`, the cubic type-pair channel is exactly
`log₂ 3 - 10/9 = 0.473851…`. -/
theorem conductor13_pair_channel :
    mutInfo (box 12) (typePair 3) (prodRes 3) = Real.logb 2 3 - 10 / 9 := by
  rw [show (12 : ℕ) = 3 * 4 by norm_num, Ipair_subfield (by norm_num) (by norm_num),
    CyclicCubic13.Ipair_three_eq]

/-- **The conductor-13 pairing defect, in situ.**  Comparing the fully pinned
single-prime cubic channel with the semiprime pair channel — both computed at
conductor `13` — the loss is exactly `4/9` bits. -/
theorem conductor13_pair_defect :
    uEnt (range 12) (ordType 3) - mutInfo (box 12) (typePair 3) (prodRes 3) = 4 / 9 := by
  rw [CyclicCubic13.conductor13_entropy, conductor13_pair_channel]
  ring

/-- The cubic pair channel is conductor-independent: conductors `7`, `13`, `19`
all give the same value. -/
theorem cubic_pair_channel_all_conductors {f : ℕ} (hf : f.Prime) (h3 : 3 ∣ f - 1) :
    mutInfo (box (f - 1)) (typePair 3) (prodRes 3) = Real.logb 2 3 - 10 / 9 := by
  have hpos : 0 < f - 1 := by
    have := hf.two_le
    rcases Nat.eq_zero_or_pos (f - 1) with h | h
    · omega
    · exact h
  rw [Ipair_subfield_of_dvd (by norm_num) hpos h3, CyclicCubic13.Ipair_three_eq]

end CyclicSubfield