import Mathlib
import Shared.CyclicTypeChannelProduct

/-!
# The type channel of a Chebotarev fibre product (FACT round-33 #3, paper 118)

This file supplies the general information-theoretic engine behind the
`THE-D5-DIAL-IS-MEASURED` experiment.  It is written on top of the counting
Shannon-entropy framework `CyclicTypeChannel.uEnt / condEnt / mutInfo` of the
catalog (`Shared.CyclicTypeChannel`).

## The model

Let `K/ℚ` be a Galois extension with group `G`, and let `m` be a conductor.
For primes `p ∤ m·disc K` the pair `(p mod m, Frob_p)` is, by Chebotarev applied to
the compositum `K(ζ_m)`, equidistributed on the *fibre product*

  `{(a, g) ∈ (ℤ/m)ˣ × G | χ a = σ g}`,

where `σ : G → Q` and `χ : (ℤ/m)ˣ → Q` are the two projections onto the common
quotient `Q = Gal((K ∩ ℚ(ζ_m))/ℚ)`.  We model this law as the uniform measure on
`fibreProd U χ σ` for an arbitrary finite residue set `U`, and we only assume that
the residue read-out is *balanced*: every `χ`-fibre met by `σ` has the same size
`K > 0` (Dirichlet's theorem for the abelian quotient).

## Main results

* `condEnt_eq_avg` — conditional entropy as an average over sample points.
* `uEnt_eq_of_proportional` — entropy only sees the *shape* of a count vector.
* `condEnt_eq_of_condUniform`, `mutInfo_eq_of_condUniform` — **conditional
  uniformity**: if refining a conditioning variable `c ∘ R` to `R` does not change
  the (normalised) type distribution on any cell, the refinement carries no extra
  information.
* `uEnt_cover`, `condEnt_cover`, `mutInfo_cover` — a balanced `K`-to-one cover
  is invisible to all entropies.
* `mutInfo_of_function` — the information that `T` shares with a deterministic
  read-out `φ ∘ T` is exactly the entropy of the read-out.
* `condEnt_const`, `mutInfo_const` — a constant read-out carries no information.
* `fibreProd_mutInfo` — **the residue only speaks through the common quotient**:
  `I(p mod m ; T) = I(σ(Frob) ; T)` computed on `G` alone, *independently of `m`,
  of `U`, and of the multiplicity `K`*.
-/

open Finset

namespace Catalog.Probability.D5TypeChannelCore

open CyclicTypeChannel

variable {α β γ δ G A : Type*}

section General

variable [DecidableEq β] [DecidableEq γ]

/-- Conditional entropy as the average, over the sample points, of the entropy of
the cell containing the point. -/
theorem condEnt_eq_avg (s : Finset α) (g : α → β) (k : α → γ) :
    condEnt s g k = (∑ x ∈ s, uEnt {y ∈ s | k y = k x} g) / s.card := by
  rw [Finset.sum_comp (fun c => uEnt {y ∈ s | k y = c} g) k, Finset.sum_div, condEnt]
  refine Finset.sum_congr rfl fun c _ => ?_
  rw [nsmul_eq_mul]
  ring

/-- **Entropy only sees the shape of the count vector.** Two non-empty sample sets
whose `g`-count vectors are proportional have the same `g`-entropy. -/
theorem uEnt_eq_of_proportional {S₁ S₂ : Finset α} {g : α → β} (h₁ : S₁.Nonempty)
    (h₂ : S₂.Nonempty)
    (h : ∀ t, #{x ∈ S₁ | g x = t} * S₂.card = #{x ∈ S₂ | g x = t} * S₁.card) :
    uEnt S₁ g = uEnt S₂ g := by
  have hN₁ : 0 < S₁.card := card_pos.2 h₁
  have hN₂ : 0 < S₂.card := card_pos.2 h₂
  have hpos : ∀ t, 0 < #{x ∈ S₁ | g x = t} ↔ 0 < #{x ∈ S₂ | g x = t} := by
    intro t
    constructor
    · intro ht
      by_contra h0
      have h2 : #{x ∈ S₂ | g x = t} = 0 := by omega
      have := h t
      rw [h2, zero_mul] at this
      exact absurd this (Nat.mul_pos ht hN₂).ne'
    · intro ht
      by_contra h0
      have h2 : #{x ∈ S₁ | g x = t} = 0 := by omega
      have := h t
      rw [h2, zero_mul] at this
      exact absurd this.symm (Nat.mul_pos ht hN₁).ne'
  have himg : S₁.image g = S₂.image g := by
    ext t
    have e : ∀ S : Finset α, t ∈ S.image g ↔ 0 < #{x ∈ S | g x = t} := by
      intro S
      rw [card_pos, mem_image, filter_nonempty_iff]
    rw [e, e, hpos]
  rw [uEnt_eq_shannon h₁, uEnt_eq_shannon h₂, himg]
  refine Finset.sum_congr rfl fun t _ => ?_
  have hr : (#{x ∈ S₁ | g x = t} : ℝ) / S₁.card = (#{x ∈ S₂ | g x = t} : ℝ) / S₂.card := by
    rw [div_eq_div_iff (by exact_mod_cast hN₁.ne') (by exact_mod_cast hN₂.ne')]
    exact_mod_cast h t
  rw [hr]

/-- **Conditional uniformity.** Suppose that on every cell of the refined
conditioning variable `R`, the `g`-count vector is proportional to the `g`-count
vector on the coarser cell of `c ∘ R`.  Then conditioning on `R` is no better than
conditioning on `c ∘ R`. -/
theorem condEnt_eq_of_condUniform [DecidableEq δ] (s : Finset α) (g : α → β) (R : α → γ)
    (c : γ → δ)
    (h : ∀ x ∈ s, ∀ t, #{y ∈ s | R y = R x ∧ g y = t} * #{y ∈ s | c (R y) = c (R x)}
      = #{y ∈ s | c (R y) = c (R x) ∧ g y = t} * #{y ∈ s | R y = R x}) :
    condEnt s g R = condEnt s g (c ∘ R) := by
  rw [condEnt_eq_avg, condEnt_eq_avg]
  congr 1
  refine Finset.sum_congr rfl fun x hx => ?_
  refine uEnt_eq_of_proportional ⟨x, by simp [hx]⟩ ⟨x, by simp [hx]⟩ fun t => ?_
  simp only [filter_filter, Function.comp]
  exact h x hx t

/-- Mutual-information form of `condEnt_eq_of_condUniform`. -/
theorem mutInfo_eq_of_condUniform [DecidableEq δ] (s : Finset α) (g : α → β) (R : α → γ)
    (c : γ → δ)
    (h : ∀ x ∈ s, ∀ t, #{y ∈ s | R y = R x ∧ g y = t} * #{y ∈ s | c (R y) = c (R x)}
      = #{y ∈ s | c (R y) = c (R x) ∧ g y = t} * #{y ∈ s | R y = R x}) :
    mutInfo s g R = mutInfo s g (c ∘ R) := by
  rw [mutInfo, mutInfo, condEnt_eq_of_condUniform s g R c h]

/-- A constant read-out carries no information: `H(g | const) = H(g)`. -/
theorem condEnt_const (s : Finset α) (g : α → β) (c₀ : γ) :
    condEnt s g (fun _ => c₀) = uEnt s g := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [condEnt, uEnt]
  have himg : s.image (fun _ => c₀) = {c₀} := image_const hs c₀
  have hN : (s.card : ℝ) ≠ 0 := by exact_mod_cast (card_pos.2 hs).ne'
  rw [condEnt, himg, sum_singleton]
  simp [hN]

/-- `I(g ; const) = 0`. -/
theorem mutInfo_const (s : Finset α) (g : α → β) (c₀ : γ) :
    mutInfo s g (fun _ => c₀) = 0 := by
  rw [mutInfo, condEnt_const, sub_self]

/-- **Information of a deterministic read-out.** If `k = φ ∘ g` on `s`, then
`I(g ; k) = H(k)`: all of the entropy of the read-out is information about `g`. -/
theorem mutInfo_of_function (s : Finset α) (g : α → β) (k : α → γ) (φ : β → γ)
    (hk : ∀ a ∈ s, k a = φ (g a)) : mutInfo s g k = uEnt s k := by
  rw [mutInfo_congr (fun _ _ => rfl) hk, uEnt_congr (g' := φ ∘ g) hk]
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [mutInfo, condEnt, uEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  set k' : α → γ := φ ∘ g with hk'
  change mutInfo s g k' = uEnt s k'
  -- the inner fibres of `g` inside a cell of `k'` are the global fibres of `g`
  have hfib : ∀ a ∈ s, {y ∈ {x ∈ s | k' x = k' a} | g y = g a} = {y ∈ s | g y = g a} := by
    intro a _
    ext y
    simp only [mem_filter, hk', Function.comp]
    constructor
    · rintro ⟨⟨hy, _⟩, h⟩; exact ⟨hy, h⟩
    · rintro ⟨hy, h⟩; exact ⟨⟨hy, by rw [h]⟩, h⟩
  have hcond : condEnt s g k' = (∑ c ∈ s.image k',
        (#{x ∈ s | k' x = c} : ℝ) * Real.logb 2 (#{x ∈ s | k' x = c} : ℝ)) / s.card
      - (∑ a ∈ s, Real.logb 2 (#{y ∈ s | g y = g a} : ℝ)) / s.card := by
    rw [condEnt]
    have hcell : ∀ c ∈ s.image k',
        ((#{x ∈ s | k' x = c} : ℝ) / s.card) * uEnt {x ∈ s | k' x = c} g
          = ((#{x ∈ s | k' x = c} : ℝ) * Real.logb 2 (#{x ∈ s | k' x = c} : ℝ)) / s.card
            - (∑ a ∈ {x ∈ s | k' x = c}, Real.logb 2 (#{y ∈ s | g y = g a} : ℝ)) / s.card := by
      intro c hc
      obtain ⟨a₀, ha₀, rfl⟩ := mem_image.1 hc
      have hC : (0 : ℝ) < (#{x ∈ s | k' x = k' a₀} : ℝ) := by
        exact_mod_cast fiber_card_pos ha₀
      rw [uEnt]
      have hsum : ∑ a ∈ {x ∈ s | k' x = k' a₀},
            Real.logb 2 (#{y ∈ {x ∈ s | k' x = k' a₀} | g y = g a} : ℝ)
          = ∑ a ∈ {x ∈ s | k' x = k' a₀}, Real.logb 2 (#{y ∈ s | g y = g a} : ℝ) := by
        refine Finset.sum_congr rfl fun a ha => ?_
        have ha' : k' a = k' a₀ := (mem_filter.1 ha).2
        have hs' : a ∈ s := (mem_filter.1 ha).1
        have : {x ∈ s | k' x = k' a₀} = {x ∈ s | k' x = k' a} := by rw [ha']
        rw [this, hfib a hs']
      rw [hsum]
      field_simp
    rw [Finset.sum_congr rfl hcell, Finset.sum_sub_distrib, ← Finset.sum_div, ← Finset.sum_div]
    congr 2
    exact Finset.sum_fiberwise_of_maps_to (fun a ha => mem_image_of_mem k' ha) _
  rw [mutInfo, hcond, uEnt, uEnt, sum_logb_fiber s k']
  ring

end General

/-! ## Balanced covers -/

section Cover

variable [DecidableEq G]

/-- Counting through a balanced `K`-to-one cover. -/
theorem card_filter_cover (s : Finset α) (u : Finset G) (π : α → G) (K : ℕ)
    (hmaps : ∀ x ∈ s, π x ∈ u) (hK : ∀ v ∈ u, #{x ∈ s | π x = v} = K) (P : G → Prop)
    [DecidablePred P] : #{x ∈ s | P (π x)} = K * #{v ∈ u | P v} := by
  rw [card_eq_sum_card_fiberwise (f := π) (t := u.filter P)]
  · rw [Finset.sum_congr rfl (g := fun _ => K), sum_const, smul_eq_mul, mul_comm]
    intro v hv
    have hPv : P v := (mem_filter.1 hv).2
    rw [filter_filter, ← hK v (mem_filter.1 hv).1]
    congr 1
    refine Finset.filter_congr fun x _ => ?_
    constructor
    · exact fun h => h.2
    · intro h; exact ⟨by rw [h]; exact hPv, h⟩
  · intro x hx
    simp only [coe_filter, Set.mem_setOf_eq] at hx ⊢
    exact ⟨hmaps x hx.1, hx.2⟩

/-- Summing through a balanced `K`-to-one cover. -/
theorem sum_cover (s : Finset α) (u : Finset G) (π : α → G) (K : ℕ)
    (hmaps : ∀ x ∈ s, π x ∈ u) (hK : ∀ v ∈ u, #{x ∈ s | π x = v} = K) (ψ : G → ℝ) :
    ∑ x ∈ s, ψ (π x) = K * ∑ v ∈ u, ψ v := by
  rw [← Finset.sum_fiberwise_of_maps_to hmaps, Finset.mul_sum]
  refine Finset.sum_congr rfl fun v hv => ?_
  rw [Finset.sum_congr rfl (g := fun _ => ψ v) (fun x hx => by rw [(mem_filter.1 hx).2]),
    sum_const, hK v hv, nsmul_eq_mul]

variable [DecidableEq β] [DecidableEq γ]

/-- **A balanced cover is invisible to entropy.** -/
theorem uEnt_cover (s : Finset α) (u : Finset G) (π : α → G) (K : ℕ) (hKpos : 0 < K)
    (hmaps : ∀ x ∈ s, π x ∈ u) (hK : ∀ v ∈ u, #{x ∈ s | π x = v} = K) (f : G → β) :
    uEnt s (f ∘ π) = uEnt u f := by
  have hcard : s.card = K * u.card := by
    have := card_filter_cover s u π K hmaps hK (fun _ => True)
    simpa using this
  rcases u.eq_empty_or_nonempty with rfl | hu
  · have : s.card = 0 := by simpa using hcard
    rw [card_eq_zero] at this
    subst this
    simp [uEnt]
  have hKr : (0 : ℝ) < K := by exact_mod_cast hKpos
  have hU : (0 : ℝ) < u.card := by exact_mod_cast card_pos.2 hu
  have hfib : ∀ x ∈ s, (#{y ∈ s | (f ∘ π) y = (f ∘ π) x} : ℝ)
      = K * (#{v ∈ u | f v = f (π x)} : ℝ) := by
    intro x _
    exact_mod_cast card_filter_cover s u π K hmaps hK (fun v => f v = f (π x))
  have hpos : ∀ v ∈ u, (0 : ℝ) < (#{w ∈ u | f w = f v} : ℝ) := by
    intro v hv; exact_mod_cast fiber_card_pos hv
  have hsum : ∑ x ∈ s, Real.logb 2 (#{y ∈ s | (f ∘ π) y = (f ∘ π) x} : ℝ)
      = K * ∑ v ∈ u, (Real.logb 2 K + Real.logb 2 (#{w ∈ u | f w = f v} : ℝ)) := by
    rw [Finset.sum_congr rfl fun x hx => by rw [hfib x hx]]
    rw [← sum_cover s u π K hmaps hK]
    refine Finset.sum_congr rfl fun x hx => ?_
    rw [Real.logb_mul hKr.ne' (hpos _ (hmaps x hx)).ne']
  rw [uEnt, uEnt, hsum, hcard, Finset.sum_add_distrib, sum_const, nsmul_eq_mul]
  push_cast
  rw [Real.logb_mul hKr.ne' hU.ne']
  field_simp
  ring

/-- **A balanced cover is invisible to conditional entropy.** -/
theorem condEnt_cover (s : Finset α) (u : Finset G) (π : α → G) (K : ℕ) (hKpos : 0 < K)
    (hmaps : ∀ x ∈ s, π x ∈ u) (hK : ∀ v ∈ u, #{x ∈ s | π x = v} = K) (f : G → β)
    (h : G → γ) : condEnt s (f ∘ π) (h ∘ π) = condEnt u f h := by
  have hcard : s.card = K * u.card := by
    have := card_filter_cover s u π K hmaps hK (fun _ => True)
    simpa using this
  have hcell : ∀ x ∈ s, uEnt {y ∈ s | (h ∘ π) y = (h ∘ π) x} (f ∘ π)
      = uEnt {v ∈ u | h v = h (π x)} f := by
    intro x _
    refine uEnt_cover _ _ π K hKpos ?_ ?_ f
    · intro y hy
      simp only [mem_filter, Function.comp] at hy ⊢
      exact ⟨hmaps y hy.1, hy.2⟩
    · intro v hv
      rw [filter_filter, ← hK v (mem_filter.1 hv).1]
      congr 1
      refine Finset.filter_congr fun y _ => ?_
      simp only [Function.comp]
      constructor
      · exact fun h => h.2
      · intro hy; exact ⟨by rw [hy]; exact (mem_filter.1 hv).2, hy⟩
  rw [condEnt_eq_avg, condEnt_eq_avg, Finset.sum_congr rfl hcell,
    sum_cover s u π K hmaps hK (fun v => uEnt {w ∈ u | h w = h v} f), hcard]
  rcases u.eq_empty_or_nonempty with rfl | hu
  · simp
  have hKr : (K : ℝ) ≠ 0 := by exact_mod_cast hKpos.ne'
  push_cast
  field_simp

/-- **A balanced cover is invisible to mutual information.** -/
theorem mutInfo_cover (s : Finset α) (u : Finset G) (π : α → G) (K : ℕ) (hKpos : 0 < K)
    (hmaps : ∀ x ∈ s, π x ∈ u) (hK : ∀ v ∈ u, #{x ∈ s | π x = v} = K) (f : G → β)
    (h : G → γ) : mutInfo s (f ∘ π) (h ∘ π) = mutInfo u f h := by
  rw [mutInfo, mutInfo, uEnt_cover s u π K hKpos hmaps hK, condEnt_cover s u π K hKpos hmaps hK]

end Cover

/-! ## The Chebotarev fibre product -/

section FibreProduct

variable [Fintype G] [DecidableEq G] [DecidableEq A] [DecidableEq δ]

/-- The support of the joint law of `(p mod m, Frob_p)`: residues `a ∈ U` and
Frobenius elements `g ∈ G` with the same image in the common quotient. -/
def fibreProd (U : Finset A) (χ : A → δ) (σ : G → δ) : Finset (A × G) :=
  (U ×ˢ univ).filter (fun x => χ x.1 = σ x.2)

omit [DecidableEq G] [DecidableEq A] in
lemma mem_fibreProd {U : Finset A} {χ : A → δ} {σ : G → δ} {x : A × G} :
    x ∈ fibreProd U χ σ ↔ x.1 ∈ U ∧ χ x.1 = σ x.2 := by
  simp [fibreProd]

variable [DecidableEq β]

/-- **The residue only speaks through the common quotient.**  For a balanced
residue read-out (every `χ`-fibre met by `σ` has the same size `K > 0`), the
information that the residue `p mod m` carries about the splitting type
`T(Frob_p)` equals the information that the quotient element `σ(Frob_p)` carries
about `T`, computed on the Galois group alone with its uniform (Chebotarev) law. -/
theorem fibreProd_mutInfo (U : Finset A) (χ : A → δ) (σ : G → δ) (T : G → β) (K : ℕ)
    (hKpos : 0 < K) (hbal : ∀ g : G, #{a ∈ U | χ a = σ g} = K) :
    mutInfo (fibreProd U χ σ) (T ∘ Prod.snd) Prod.fst = mutInfo univ T σ := by
  set s := fibreProd U χ σ with hs
  -- Step 1: the residue is conditionally uniform over its quotient class.
  have hstep1 : mutInfo s (T ∘ Prod.snd) Prod.fst = mutInfo s (T ∘ Prod.snd) (χ ∘ Prod.fst) := by
    refine mutInfo_eq_of_condUniform s _ Prod.fst χ fun x hx t => ?_
    obtain ⟨a, g⟩ := x
    have hx' := mem_fibreProd.1 hx
    -- counts on the fine cell `{a} × σ⁻¹(χ a)`
    have hfine : ∀ P : G → Prop, ∀ [DecidablePred P],
        #{y ∈ s | y.1 = a ∧ P y.2} = #{h ∈ (univ : Finset G) | σ h = χ a ∧ P h} := by
      intro P _
      refine Finset.card_bij (fun y _ => y.2) ?_ ?_ ?_
      · intro y hy
        simp only [mem_filter, hs, mem_fibreProd] at hy
        simp only [mem_filter, mem_univ, true_and]
        exact ⟨by rw [← hy.2.1, hy.1.2], hy.2.2⟩
      · intro y hy y' hy' he
        simp only [mem_filter] at hy hy'
        exact Prod.ext (hy.2.1.trans hy'.2.1.symm) he
      · intro h hh
        simp only [mem_filter, mem_univ, true_and] at hh
        refine ⟨(a, h), ?_, rfl⟩
        simp only [mem_filter, hs, mem_fibreProd]
        exact ⟨⟨hx'.1, hh.1.symm⟩, by first | rfl | trivial, hh.2⟩
    -- counts on the coarse cell `χ⁻¹(χ a) × σ⁻¹(χ a)`
    have hcoarse : ∀ P : G → Prop, ∀ [DecidablePred P],
        #{y ∈ s | χ y.1 = χ a ∧ P y.2}
          = K * #{h ∈ (univ : Finset G) | σ h = χ a ∧ P h} := by
      intro P _
      have hset : {y ∈ s | χ y.1 = χ a ∧ P y.2}
          = {a' ∈ U | χ a' = χ a} ×ˢ {h ∈ (univ : Finset G) | σ h = χ a ∧ P h} := by
        ext ⟨a', h⟩
        simp only [mem_filter, hs, mem_fibreProd, mem_product, mem_univ, true_and]
        constructor
        · rintro ⟨⟨h1, h2⟩, h3, h4⟩; exact ⟨⟨h1, h3⟩, h2 ▸ h3, h4⟩
        · rintro ⟨⟨h1, h3⟩, h2, h4⟩; exact ⟨⟨h1, h3.trans h2.symm⟩, h3, h4⟩
      rw [hset, card_product, hx'.2, hbal g]
    have e1 := hfine (fun h => T h = t)
    have e2 := hfine (fun _ => True)
    have e3 := hcoarse (fun h => T h = t)
    have e4 := hcoarse (fun _ => True)
    simp only [and_true] at e2 e4
    simp only [Function.comp]
    rw [e1, e2, e3, e4]
    ring
  -- Step 2: on the fibre product `χ ∘ fst = σ ∘ snd`.
  have hstep2 : mutInfo s (T ∘ Prod.snd) (χ ∘ Prod.fst) = mutInfo s (T ∘ Prod.snd) (σ ∘ Prod.snd) :=
    mutInfo_congr (fun _ _ => rfl) fun x hx => (mem_fibreProd.1 hx).2
  -- Step 3: the projection to `G` is a balanced `K`-to-one cover.
  have hstep3 : mutInfo s (T ∘ Prod.snd) (σ ∘ Prod.snd) = mutInfo univ T σ := by
    refine mutInfo_cover s univ Prod.snd K hKpos (fun _ _ => mem_univ _) (fun g _ => ?_) T σ
    rw [← hbal g]
    refine Finset.card_bij (fun y _ => y.1) ?_ ?_ ?_
    · intro y hy
      simp only [mem_filter, hs, mem_fibreProd] at hy
      simp only [mem_filter]
      exact ⟨hy.1.1, hy.2 ▸ hy.1.2⟩
    · intro y hy y' hy' he
      simp only [mem_filter] at hy hy'
      exact Prod.ext he (hy.2.trans hy'.2.symm)
    · intro a ha
      simp only [mem_filter] at ha
      refine ⟨(a, g), ?_, rfl⟩
      simp only [mem_filter, hs, mem_fibreProd]
      exact ⟨⟨ha.1, ha.2⟩, by first | rfl | trivial⟩
  rw [hstep1, hstep2, hstep3]

end FibreProduct

end Catalog.Probability.D5TypeChannelCore