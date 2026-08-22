/-
# The character captures exactly one bit

Let `K/ℚ` be a number field with Galois closure of group `G`, and let `T` be the splitting-type
read-out of an unramified prime (equivalently, the cycle type of its Frobenius class).  When the
abelianization `G^ab` is `C₂`, the *only* information about `T` that is visible in a residue
`p mod |disc|` is the value of the quadratic character attached to the discriminant — a single
binary read-out.  The claim of this file is that the number of bits so obtained is **exactly one**,
never more and never less, and that the arithmetic of `G` never enters.

The `S₃` example `x³ + x + 1` (`disc = -31`) is the running case:

| class     | type    | density |
|-----------|---------|---------|
| identity  | `1 1 1` | `1/6`   |
| transposition | `1 2` | `1/2` |
| `3`-cycle | `3`     | `1/3`   |

with `H(T) = 2/3 + (log₂ 3)/2 = 1.4591…`, `H(T | sign) = (log₂ 3)/2 - 1/3 = 0.4591…`, and
therefore `I(T ; sign) = 1` on the nose.

Everything is proved inside the counting-entropy framework of
`Catalog.Shared.CyclicTypeChannel` (`uEnt`, `condEnt`, `mutInfo`), which is the uniform
(Chebotarev) measure on the finite group `G`.  The main results are:

* `condEnt_eq_joint_sub` — the **chain rule** `H(g | k) = H(g, k) - H(k)`;
* `mutInfo_comm` — **symmetry** of mutual information, `I(g ; k) = I(k ; g)`;
* `uEnt_eq_one_of_balanced` — a balanced binary read-out carries exactly one bit;
* `mutInfo_le_uEnt_right` — the **cap**: no read-out can extract more than `H(k)` from `k`;
* `mutInfo_eq_one_of_refines_balanced` — **the theorem**: if the type refines a balanced binary
  character, the channel carries exactly one bit;
* `mutInfo_character_eq_one` — the group form: a surjective character `χ : G →* C` with `|C| = 2`
  through which the type factors gives exactly one bit, for *every* finite `G`;
* `uEnt_pos_of_ne`, `condEnt_pos_of_fiber_ne` — strict positivity, which keeps the theorem honest:
  a read-out that leaves a fibre mixed falls strictly below the ceiling;
* `mutInfo_cycleType_sign_eq_one` — the same one bit for *every* symmetric group;
* `S3.mutInfo_splitType_sign_eq_one`, together with the exact values
  `S3.uEnt_splitType`, `S3.condEnt_splitType_sign`, the paper's decomposition
  `H(T | sign) = (1/2)·H(1/3, 2/3)` and the numerical brackets
  `1.4591 < H(T) < 1.4594`, `0.4591 < H(T | sign) < 0.4594`;
* `S3.exists_mixed_type_same_sign` — mixed-type residues are forced by the theory, and
  `S3.mutInfo_splitsCompletely_sign_lt_one` — the coarser "splits completely?" read-out loses.

The residual `H(T | sign) = (log₂ 3)/2 - 1/3 > 0` is the formal statement that the non-abelian part
of `S₃` is invisible from any residue: the character sees one bit and the rest is locked.
-/
import Catalog.Shared.CyclicTypeChannel

namespace CyclicTypeChannel

open Finset

variable {α β γ : Type*}

/-! ## 1. The chain rule and the symmetry of mutual information

The counting entropies of `Catalog.Shared.CyclicTypeChannel` satisfy the full Shannon calculus.
The two facts we need — the chain rule and the symmetry `I(g;k) = I(k;g)` — are proved here from
scratch; symmetry is what converts the (hard) statement "the type tells you the character" into
the (easy) statement "the character is a function of the type". -/

section ChainRule

variable [DecidableEq β] [DecidableEq γ] {s : Finset α} {g : α → β} {k : α → γ}

/-- A read-out that is constant on `s` carries no entropy. -/
lemma uEnt_eq_zero_of_const (hconst : ∀ x ∈ s, ∀ y ∈ s, g x = g y) : uEnt s g = 0 := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hfib : ∀ a ∈ s, {x ∈ s | g x = g a} = s := by
    intro a ha
    apply Finset.filter_true_of_mem
    intro x hx
    exact hconst x hx a ha
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have : ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
      = (s.card : ℝ) * Real.logb 2 (s.card : ℝ) := by
    rw [Finset.sum_congr rfl (fun a ha => by rw [hfib a ha])]
    simp [Finset.sum_const, nsmul_eq_mul]
  rw [uEnt, this]
  field_simp
  ring

/-- The joint read-out does not care about the order of its two components. -/
lemma uEnt_joint_comm (s : Finset α) (g : α → β) (k : α → γ) :
    uEnt s (fun a => (g a, k a)) = uEnt s (fun a => (k a, g a)) := by
  classical
  have : ∀ a : α, {x ∈ s | (g x, k x) = (g a, k a)} = {x ∈ s | (k x, g x) = (k a, g a)} := by
    intro a
    apply Finset.filter_congr
    intro x _
    simp [Prod.ext_iff, and_comm]
  simp only [uEnt, this]

/-- **The chain rule** `H(g | k) = H(g, k) - H(k)`.  This is the identity that makes the counting
entropy of `uEnt` a genuine Shannon entropy rather than an ad-hoc average. -/
theorem condEnt_eq_joint_sub (hs : s.Nonempty) (g : α → β) (k : α → γ) :
    condEnt s g k = uEnt s (fun a => (g a, k a)) - uEnt s k := by
  classical
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  -- each conditional term is a difference of two sums over the fibre
  have hterm : ∀ c ∈ s.image k,
      ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} g
        = ((#{x ∈ s | k x = c} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
          - (∑ a ∈ {x ∈ s | k x = c},
              Real.logb 2 (#{x ∈ s | (g x, k x) = (g a, k a)} : ℝ)) / s.card := by
    intro c hc
    obtain ⟨a₀, ha₀, rfl⟩ := mem_image.1 hc
    set t : Finset α := {x ∈ s | k x = k a₀} with ht
    have htne : t.Nonempty := ⟨a₀, by simp [ht, ha₀]⟩
    have hn : (0 : ℝ) < t.card := by exact_mod_cast card_pos.2 htne
    -- inner fibres of `g` inside `t` are the joint fibres inside `s`
    have hfib : ∀ a ∈ t, {x ∈ t | g x = g a} = {x ∈ s | (g x, k x) = (g a, k a)} := by
      intro a ha
      have hka : k a = k a₀ := by simpa [ht] using (mem_filter.1 ha).2
      ext x
      simp only [ht, mem_filter, Prod.ext_iff]
      constructor
      · rintro ⟨⟨hxs, hxk⟩, hxg⟩; exact ⟨hxs, hxg, by rw [hxk, hka]⟩
      · rintro ⟨hxs, hxg, hxk⟩; exact ⟨⟨hxs, by rw [hxk, hka]⟩, hxg⟩
    have hn' : (t.card : ℝ) ≠ 0 := ne_of_gt hn
    have hN' : ((s.card : ℝ)) ≠ 0 := ne_of_gt hN
    rw [uEnt, Finset.sum_congr rfl (fun a ha => by rw [hfib a ha])]
    field_simp
  rw [condEnt, Finset.sum_congr rfl hterm, Finset.sum_sub_distrib]
  -- the first part reassembles into the `k`-entropy sum, the second into the joint sum
  have h1 : ∑ c ∈ s.image k,
      ((#{x ∈ s | k x = c} : ℝ) / s.card) * Real.logb 2 (#{x ∈ s | k x = c} : ℝ)
      = (∑ a ∈ s, Real.logb 2 (#{x ∈ s | k x = k a} : ℝ)) / s.card := by
    rw [sum_logb_fiber, Finset.sum_div]
    exact Finset.sum_congr rfl fun v _ => by ring
  have h2 : ∑ c ∈ s.image k,
      (∑ a ∈ {x ∈ s | k x = c},
        Real.logb 2 (#{x ∈ s | (g x, k x) = (g a, k a)} : ℝ)) / s.card
      = (∑ a ∈ s, Real.logb 2 (#{x ∈ s | (g x, k x) = (g a, k a)} : ℝ)) / s.card := by
    rw [← Finset.sum_div]
    congr 1
    exact Finset.sum_fiberwise_of_maps_to (fun x hx => mem_image_of_mem k hx) _
  rw [h1, h2, uEnt, uEnt]
  ring

/-- **Symmetry of mutual information.** -/
theorem mutInfo_comm (hs : s.Nonempty) (g : α → β) (k : α → γ) :
    mutInfo s g k = mutInfo s k g := by
  rw [mutInfo, mutInfo, condEnt_eq_joint_sub hs g k, condEnt_eq_joint_sub hs k g,
    uEnt_joint_comm s k g]
  ring

/-- Conditional entropy is non-negative. -/
theorem condEnt_nonneg (s : Finset α) (g : α → β) (k : α → γ) : 0 ≤ condEnt s g k := by
  refine Finset.sum_nonneg fun c _ => ?_
  have h₁ : (0 : ℝ) ≤ (#{x ∈ s | k x = c} : ℝ) / s.card := by positivity
  exact mul_nonneg h₁ (uEnt_nonneg _ _)

/-- **The cap.**  A read-out can never reveal more about `k` than `k` itself contains:
`I(g ; k) ≤ H(k)`.  For a balanced binary character this is the one-bit ceiling. -/
theorem mutInfo_le_uEnt_right (hs : s.Nonempty) (g : α → β) (k : α → γ) :
    mutInfo s g k ≤ uEnt s k := by
  rw [mutInfo_comm hs, mutInfo]
  linarith [condEnt_nonneg s k g]

/-- Mutual information is bounded by the entropy of the read-out itself. -/
theorem mutInfo_le_uEnt_left (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k ≤ uEnt s g := by
  rw [mutInfo]
  linarith [condEnt_nonneg s g k]

end ChainRule

/-! ## 2. Balanced binary read-outs and the one-bit theorem -/

section OneBit

variable [DecidableEq β] [DecidableEq γ] {s : Finset α} {g : α → β} {k : α → γ}

/-- **A balanced binary read-out carries exactly one bit.**  "Balanced" is expressed without
mentioning the two values: every fibre is exactly half of `s`. -/
theorem uEnt_eq_one_of_balanced (hs : s.Nonempty)
    (hbal : ∀ a ∈ s, 2 * #{x ∈ s | k x = k a} = s.card) : uEnt s k = 1 := by
  classical
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hterm : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | k x = k a} : ℝ)
      = Real.logb 2 (s.card : ℝ) - 1 := by
    intro a ha
    have h : (#{x ∈ s | k x = k a} : ℝ) = (s.card : ℝ) / 2 := by
      have := hbal a ha
      have : (2 : ℝ) * (#{x ∈ s | k x = k a} : ℝ) = (s.card : ℝ) := by exact_mod_cast this
      linarith
    rw [h, Real.logb_div (ne_of_gt hN) (by norm_num),
      Real.logb_self_eq_one (by norm_num : (1 : ℝ) < 2)]
  rw [uEnt, Finset.sum_congr rfl hterm]
  rw [Finset.sum_const, nsmul_eq_mul]
  field_simp
  ring

/-- If the read-out `g` refines `k` on `s` (equal `g`-values force equal `k`-values), then
knowing `g` determines `k`: `H(k | g) = 0`. -/
theorem condEnt_eq_zero_of_refines
    (href : ∀ x ∈ s, ∀ y ∈ s, g x = g y → k x = k y) : condEnt s k g = 0 := by
  classical
  refine Finset.sum_eq_zero fun v hv => ?_
  have : uEnt {x ∈ s | g x = v} k = 0 := by
    refine uEnt_eq_zero_of_const fun x hx y hy => ?_
    simp only [mem_filter] at hx hy
    exact href x hx.1 y hy.1 (by rw [hx.2, hy.2])
  rw [this, mul_zero]

/-- **The character captures exactly one bit.**

If the read-out `g` refines a balanced binary read-out `k`, then the channel from `g` to `k`
transmits exactly one bit — independently of how rich `g` itself is. -/
theorem mutInfo_eq_one_of_refines_balanced (hs : s.Nonempty)
    (href : ∀ x ∈ s, ∀ y ∈ s, g x = g y → k x = k y)
    (hbal : ∀ a ∈ s, 2 * #{x ∈ s | k x = k a} = s.card) :
    mutInfo s g k = 1 := by
  rw [mutInfo_comm hs, mutInfo, condEnt_eq_zero_of_refines href, sub_zero,
    uEnt_eq_one_of_balanced hs hbal]

/-- **The locked residual.**  Under the same hypotheses the conditional entropy of the type given
the character is exactly `H(T) - 1`: whatever the type knows beyond one bit stays hidden. -/
theorem condEnt_eq_uEnt_sub_one (hs : s.Nonempty)
    (href : ∀ x ∈ s, ∀ y ∈ s, g x = g y → k x = k y)
    (hbal : ∀ a ∈ s, 2 * #{x ∈ s | k x = k a} = s.card) :
    condEnt s g k = uEnt s g - 1 := by
  have h := mutInfo_eq_one_of_refines_balanced hs href hbal
  rw [mutInfo] at h
  linarith

end OneBit

/-! ## 2b. Strict positivity: when a read-out really does hide something -/

section StrictPos

variable [DecidableEq β] [DecidableEq γ] {s t : Finset α} {g : α → β} {k : α → γ}

/-- **A non-constant read-out has strictly positive entropy.**  This is the quantitative form of
"the fibres are proper subsets": every fibre misses one of the two witnesses, so every fibre
logarithm is at most `log₂ (|t| - 1)`. -/
theorem uEnt_pos_of_ne {x y : α} (hx : x ∈ t) (hy : y ∈ t) (hne : k x ≠ k y) : 0 < uEnt t k := by
  classical
  have hxy : x ≠ y := fun h => hne (by rw [h])
  have hN2 : 2 ≤ t.card := Finset.one_lt_card.2 ⟨x, hx, y, hy, hxy⟩
  have hN : (0 : ℝ) < t.card := by
    have : 0 < t.card := by omega
    exact_mod_cast this
  have hNm : (0 : ℝ) < (t.card : ℝ) - 1 := by
    have : (2 : ℝ) ≤ (t.card : ℝ) := by exact_mod_cast hN2
    linarith
  have hterm : ∀ a ∈ t, Real.logb 2 (#{z ∈ t | k z = k a} : ℝ)
      ≤ Real.logb 2 ((t.card : ℝ) - 1) := by
    intro a ha
    have hlt : #{z ∈ t | k z = k a} < t.card := by
      by_cases hax : k a = k x
      · refine Finset.card_lt_card ⟨Finset.filter_subset _ _, fun hsub => ?_⟩
        have : y ∈ {z ∈ t | k z = k a} := hsub hy
        rw [Finset.mem_filter] at this
        exact hne (by rw [← hax, this.2])
      · refine Finset.card_lt_card ⟨Finset.filter_subset _ _, fun hsub => ?_⟩
        have : x ∈ {z ∈ t | k z = k a} := hsub hx
        rw [Finset.mem_filter] at this
        exact hax this.2.symm
    have hpos : (0 : ℝ) < (#{z ∈ t | k z = k a} : ℝ) := by
      exact_mod_cast fiber_card_pos ha
    have hle : (#{z ∈ t | k z = k a} : ℝ) ≤ (t.card : ℝ) - 1 := by
      have : (#{z ∈ t | k z = k a} : ℕ) + 1 ≤ t.card := hlt
      have : ((#{z ∈ t | k z = k a} : ℕ) : ℝ) + 1 ≤ (t.card : ℝ) := by exact_mod_cast this
      linarith
    exact Real.logb_le_logb_of_le (by norm_num) hpos hle
  have hsum : (∑ a ∈ t, Real.logb 2 (#{z ∈ t | k z = k a} : ℝ))
      ≤ (t.card : ℝ) * Real.logb 2 ((t.card : ℝ) - 1) := by
    calc (∑ a ∈ t, Real.logb 2 (#{z ∈ t | k z = k a} : ℝ))
        ≤ ∑ _a ∈ t, Real.logb 2 ((t.card : ℝ) - 1) := Finset.sum_le_sum hterm
      _ = (t.card : ℝ) * Real.logb 2 ((t.card : ℝ) - 1) := by
          simp [Finset.sum_const, nsmul_eq_mul]
  have hstrict : Real.logb 2 ((t.card : ℝ) - 1) < Real.logb 2 (t.card : ℝ) :=
    Real.logb_lt_logb (by norm_num) hNm (by linarith)
  rw [uEnt, sub_pos, div_lt_iff₀ hN]
  calc (∑ a ∈ t, Real.logb 2 (#{z ∈ t | k z = k a} : ℝ))
      ≤ (t.card : ℝ) * Real.logb 2 ((t.card : ℝ) - 1) := hsum
    _ < Real.logb 2 (t.card : ℝ) * (t.card : ℝ) := by nlinarith [hstrict, hN]

/-- **A conditioning variable that leaves a fibre mixed has strictly positive conditional
entropy.**  This is what makes the one-bit theorem non-vacuous: without the refinement hypothesis
the mutual information genuinely drops below the ceiling. -/
theorem condEnt_pos_of_fiber_ne {x y : α} (hx : x ∈ s) (hy : y ∈ s)
    (hg : g x = g y) (hk : k x ≠ k y) : 0 < condEnt s k g := by
  classical
  have hsne : s.Nonempty := ⟨x, hx⟩
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hsne
  refine Finset.sum_pos' (fun c _ => ?_) ⟨g x, mem_image_of_mem g hx, ?_⟩
  · exact mul_nonneg (by positivity) (uEnt_nonneg _ _)
  · have hxmem : x ∈ {z ∈ s | g z = g x} := by simp [hx]
    have hymem : y ∈ {z ∈ s | g z = g x} := by simp [hy, hg]
    have hw : (0 : ℝ) < (#{z ∈ s | g z = g x} : ℝ) / s.card := by
      have : (0 : ℝ) < (#{z ∈ s | g z = g x} : ℝ) := by
        exact_mod_cast Finset.card_pos.2 ⟨x, hxmem⟩
      positivity
    exact mul_pos hw (uEnt_pos_of_ne hxmem hymem hk)

end StrictPos

/-! ## 3. The group form: `G^ab = C₂` gives exactly one bit

Chebotarev makes the Frobenius class equidistributed in `G`, so the uniform counting measure on
`G` *is* the density measure on primes.  A residue `p mod |disc|` sees the Frobenius only through
the abelian quotient; when that quotient has order two, the visible datum is a single surjective
character `χ : G →* C` with `|C| = 2`, and the splitting type determines it. -/

section GroupForm

/-- The canonical map to the abelianization is surjective. -/
theorem abelianization_of_surjective {G : Type*} [Group G] :
    Function.Surjective (Abelianization.of : G → Abelianization G) := by
  intro x
  induction x using QuotientGroup.induction_on with
  | H g => exact ⟨g, rfl⟩

variable {G C : Type*} [Group G] [Fintype G] [Group C] [Fintype C] [DecidableEq C]

/-- Every fibre of a surjective character onto a two-element group is exactly half of the group. -/
theorem card_fiber_character (χ : G →* C) (hsurj : Function.Surjective χ)
    (hC : Fintype.card C = 2) (a : G) :
    2 * #{x : G | χ x = χ a} = Fintype.card G := by
  classical
  have hsum : Fintype.card G = ∑ c : C, #{x : G | χ x = c} :=
    Finset.card_eq_sum_card_fiberwise (fun x _ => Finset.mem_univ (χ x))
  have hconst : ∀ c : C, #{x : G | χ x = c} = #{x : G | χ x = χ a} :=
    fun c => MonoidHom.card_fiber_eq_of_mem_range χ (hsurj c) ⟨a, rfl⟩
  rw [hsum, Finset.sum_congr rfl fun c _ => hconst c, Finset.sum_const, Finset.card_univ, hC,
    smul_eq_mul]

/-- **`G^ab = C₂` ⟹ exactly one bit.**  For any finite group `G`, any surjective character
`χ : G →* C` onto a two-element group, and any splitting-type read-out `T` through which `χ`
factors, the type/character channel carries exactly one bit.  Nothing about `G` beyond the
existence of the index-two kernel is used — this is the promised uniformity over all `S₃`, `S₄`
and `S₅` fields. -/
theorem mutInfo_character_eq_one {β : Type*} [DecidableEq β] (T : G → β) (χ : G →* C)
    (hsurj : Function.Surjective χ) (hC : Fintype.card C = 2)
    (f : β → C) (hf : ∀ x : G, χ x = f (T x)) :
    mutInfo (univ : Finset G) T (fun x => χ x) = 1 := by
  classical
  have hne : (univ : Finset G).Nonempty := univ_nonempty
  refine mutInfo_eq_one_of_refines_balanced hne (fun x _ y _ hxy => ?_) (fun a _ => ?_)
  · rw [hf x, hf y, hxy]
  · rw [Finset.card_univ]
    exact card_fiber_character χ hsurj hC a

/-- The same statement with the abelianization in place of an abstract character: if `G^ab` has
order two and the type read-out determines the image in `G^ab`, the channel is one bit. -/
theorem mutInfo_abelianization_eq_one {β : Type*} [DecidableEq β]
    [Fintype (Abelianization G)] [DecidableEq (Abelianization G)]
    (T : G → β) (hC : Fintype.card (Abelianization G) = 2)
    (f : β → Abelianization G) (hf : ∀ x : G, Abelianization.of x = f (T x)) :
    mutInfo (univ : Finset G) T (fun x => Abelianization.of x) = 1 :=
  mutInfo_character_eq_one T (Abelianization.of) abelianization_of_surjective hC f hf

end GroupForm

/-! ## 4. Every symmetric group: the cycle type sees the sign, and nothing else abelian

`S_n^ab = C₂` for `n ≥ 2`, and the cycle type determines the sign through the universal formula
`sign σ = (-1) ^ (|σ| + #cycles)`.  Hence the type/character channel of *every* symmetric group is
exactly one bit — the uniform statement behind the `S₃`, `S₄` and `S₅` measurements. -/

section Symmetric

open Equiv Equiv.Perm

/-- **One bit for every symmetric group.**  For any finite set with at least two points, the
mutual information between the cycle type of a uniformly random permutation and its sign is
exactly one bit. -/
theorem mutInfo_cycleType_sign_eq_one (α : Type*) [DecidableEq α] [Fintype α] [Nontrivial α] :
    mutInfo (univ : Finset (Perm α)) Equiv.Perm.cycleType (fun σ => Equiv.Perm.sign σ) = 1 :=
  mutInfo_character_eq_one _ Equiv.Perm.sign (sign_surjective α) (by simp)
    (fun t => (-1) ^ (t.sum + t.card)) (fun σ => sign_of_cycleType σ)

/-- The sign read-out of a permutation carries exactly one bit. -/
theorem uEnt_sign_eq_one (α : Type*) [DecidableEq α] [Fintype α] [Nontrivial α] :
    uEnt (univ : Finset (Perm α)) (fun σ => Equiv.Perm.sign σ) = 1 := by
  refine uEnt_eq_one_of_balanced univ_nonempty (fun a _ => ?_)
  rw [Finset.card_univ]
  exact card_fiber_character Equiv.Perm.sign (sign_surjective α) (by simp) a

/-- **The one-bit ceiling.**  *No* read-out of a permutation — however fine — can extract more
than one bit about its sign.  Combined with `mutInfo_cycleType_sign_eq_one`, the cycle type is
already optimal: it saturates the ceiling. -/
theorem mutInfo_sign_le_one {β : Type*} [DecidableEq β] (α : Type*) [DecidableEq α] [Fintype α]
    [Nontrivial α] (g : Perm α → β) :
    mutInfo (univ : Finset (Perm α)) g (fun σ => Equiv.Perm.sign σ) ≤ 1 := by
  have h := mutInfo_le_uEnt_right (s := (univ : Finset (Perm α))) univ_nonempty g
    (fun σ => Equiv.Perm.sign σ)
  rwa [uEnt_sign_eq_one α] at h

end Symmetric

/-! ## 5. The cubic field `x³ + x + 1` (`disc = -31`, `G = S₃`)

The splitting type of an unramified prime in `ℚ[x]/(x³+x+1)` is the cycle type of its Frobenius,
padded with fixed points so that it is a genuine partition of `3`: `{1,1,1}`, `{2,1}` or `{3}`,
i.e. the paper's `'111'`, `'12'`, `'3'`, with Chebotarev densities `1/6`, `1/2`, `1/3`. -/

namespace S3

open Equiv Equiv.Perm

/-- The **splitting type** of a prime with Frobenius class `σ`: the cycle type of `σ` padded by
fixed points, hence a partition of `3` — `{1,1,1}`, `{2,1}` or `{3}`. -/
def splitType (σ : Perm (Fin 3)) : Multiset ℕ :=
  σ.cycleType + Multiset.replicate (3 - σ.support.card) 1

/-- The three splitting types actually occurring are `'111'`, `'12'` and `'3'`. -/
theorem image_splitType :
    (univ : Finset (Perm (Fin 3))).image splitType = {{1, 1, 1}, {2, 1}, {3}} := by decide

/-- The Chebotarev counts: `1` identity, `3` transpositions, `2` three-cycles out of `6`. -/
theorem splitType_counts :
    #{σ : Perm (Fin 3) | splitType σ = {1, 1, 1}} = 1 ∧
      #{σ : Perm (Fin 3) | splitType σ = {2, 1}} = 3 ∧
      #{σ : Perm (Fin 3) | splitType σ = {3}} = 2 := by decide

/-- The quadratic character `(-31 | p)` as a function of the splitting type: a prime is
"odd" exactly when it has type `'12'`. -/
def signOfType (t : Multiset ℕ) : ℤˣ := if t = {2, 1} then -1 else 1

/-- **The character is a function of the type.**  This is the only arithmetic input: the Legendre
symbol `(-31 | p)` is determined by the splitting type of `p`. -/
theorem sign_eq_signOfType (σ : Perm (Fin 3)) :
    Equiv.Perm.sign σ = signOfType (splitType σ) := by
  revert σ; decide

/-- **The character captures exactly one bit** for `x³ + x + 1`. -/
theorem mutInfo_splitType_sign_eq_one :
    mutInfo (univ : Finset (Perm (Fin 3))) splitType (fun σ => Equiv.Perm.sign σ) = 1 :=
  mutInfo_character_eq_one _ Equiv.Perm.sign (sign_surjective (Fin 3)) (by simp)
    signOfType sign_eq_signOfType

/-! ### Exact values of the two entropies -/

/-- **`H(T) = 2/3 + (log₂ 3)/2 = 1.4591…`**, the Chebotarev entropy of the splitting type. -/
theorem uEnt_splitType :
    uEnt (univ : Finset (Perm (Fin 3))) splitType = 2 / 3 + Real.logb 2 3 / 2 := by
  have hcount : ((univ : Finset (Perm (Fin 3))).image splitType).val.map
      (fun v => (#{x ∈ (univ : Finset (Perm (Fin 3))) | splitType x = v} : ℕ))
      = ({1, 3, 2} : Multiset ℕ) := by decide
  have hcard6 : Fintype.card (Perm (Fin 3)) = 6 := by decide
  have hcard : (#(univ : Finset (Perm (Fin 3))) : ℝ) = 6 := by
    norm_num [Finset.card_univ, hcard6]
  rw [uEnt_eq_countSum _ _ _ hcount, hcard]
  have h1 : Real.logb 2 (1 : ℝ) = 0 := Real.logb_one
  have h2 : Real.logb 2 (2 : ℝ) = 1 := Real.logb_self_eq_one (by norm_num)
  simp only [Multiset.insert_eq_cons, Multiset.map_cons, Multiset.sum_cons, Multiset.map_singleton,
    Multiset.sum_singleton, Nat.cast_one, Nat.cast_ofNat]
  rw [h1, h2, CyclicTypeChannel.lb_6]
  ring

/-- **`H(T | (-31|·)) = (log₂ 3)/2 - 1/3 = 0.4591…`** — the entropy the character cannot reach. -/
theorem condEnt_splitType_sign :
    condEnt (univ : Finset (Perm (Fin 3))) splitType (fun σ => Equiv.Perm.sign σ)
      = Real.logb 2 3 / 2 - 1 / 3 := by
  have h := mutInfo_splitType_sign_eq_one
  rw [mutInfo, uEnt_splitType] at h
  linarith

/-! ### Numerical brackets

`3 ^ 53 > 2 ^ 84` and `3 ^ 41 < 2 ^ 65` pin `log₂ 3` to four decimals, which is what turns the
exact formulas into the measured numbers `1.4591…` and `0.4591…`. -/

/-- `log₂ 3 > 84/53`, i.e. `3 ^ 53 > 2 ^ 84`. -/
theorem lb_three_gt_sharp : (84 : ℝ) / 53 < Real.logb 2 3 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((2 : ℝ) ^ (84 : ℕ)) < Real.log ((3 : ℝ) ^ (53 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, lt_div_iff₀ h2]
  push_cast at h
  linarith

/-- `log₂ 3 < 65/41`, i.e. `3 ^ 41 < 2 ^ 65`. -/
theorem lb_three_lt_sharp : Real.logb 2 3 < (65 : ℝ) / 41 := by
  have h2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have h : Real.log ((3 : ℝ) ^ (41 : ℕ)) < Real.log ((2 : ℝ) ^ (65 : ℕ)) :=
    Real.log_lt_log (by positivity) (by norm_num)
  rw [Real.log_pow, Real.log_pow] at h
  rw [Real.logb, div_lt_iff₀ h2]
  push_cast at h
  linarith

/-- **The measured value `H(T) = 1.4591…`.** -/
theorem uEnt_splitType_bracket :
    1.4591 < uEnt (univ : Finset (Perm (Fin 3))) splitType ∧
      uEnt (univ : Finset (Perm (Fin 3))) splitType < 1.4594 := by
  rw [uEnt_splitType]
  refine ⟨?_, ?_⟩
  · have := lb_three_gt_sharp; norm_num; linarith
  · have := lb_three_lt_sharp; norm_num; linarith

/-- **The measured value `H(T | sign) = 0.4591…`** — the locked, non-abelian residual. -/
theorem condEnt_splitType_sign_bracket :
    0.4591 < condEnt (univ : Finset (Perm (Fin 3))) splitType (fun σ => Equiv.Perm.sign σ) ∧
      condEnt (univ : Finset (Perm (Fin 3))) splitType (fun σ => Equiv.Perm.sign σ) < 0.4594 := by
  rw [condEnt_splitType_sign]
  refine ⟨?_, ?_⟩
  · have := lb_three_gt_sharp; norm_num; linarith
  · have := lb_three_lt_sharp; norm_num; linarith

/-- **The non-abelian lock.**  The residual entropy is strictly positive: the splitting type is
*not* a function of the character, so no residue can determine it. -/
theorem condEnt_splitType_sign_pos :
    0 < condEnt (univ : Finset (Perm (Fin 3))) splitType (fun σ => Equiv.Perm.sign σ) :=
  lt_trans (by norm_num) condEnt_splitType_sign_bracket.1

/-- **One bit out of `1.4591` bits.**  The channel is strictly lossy: the character transmits
exactly one bit and the type carries strictly more. -/
theorem mutInfo_lt_uEnt_splitType :
    mutInfo (univ : Finset (Perm (Fin 3))) splitType (fun σ => Equiv.Perm.sign σ)
      < uEnt (univ : Finset (Perm (Fin 3))) splitType := by
  rw [mutInfo]
  linarith [condEnt_splitType_sign_pos]

/-! ### Mixed-type residues: why the character *must* leave classes mixed -/

/-- **Mixed-type residues are forced.**  The even class of `S₃` contains two different splitting
types, so a residue that fixes the character still leaves the type undetermined — exactly the
"mixed-type residues" observed in the numerical scan. -/
theorem exists_mixed_type_same_sign :
    ∃ σ τ : Perm (Fin 3), Equiv.Perm.sign σ = Equiv.Perm.sign τ ∧ splitType σ ≠ splitType τ := by
  decide

/-- The within-even split is `1 : 2`: one identity class element against two three-cycles. -/
theorem even_class_counts :
    #{σ : Perm (Fin 3) | Equiv.Perm.sign σ = 1 ∧ splitType σ = {1, 1, 1}} = 1 ∧
      #{σ : Perm (Fin 3) | Equiv.Perm.sign σ = 1 ∧ splitType σ = {3}} = 2 := by decide

/-- **The paper's decomposition** `H(T | sign) = (1/2) · H(1/3, 2/3)`: the odd half of the group is
pure (type `'12'`) and contributes nothing, while the even half splits `1 : 2` and contributes
`H(1/3, 2/3) = log₂ 3 - 2/3`. -/
theorem condEnt_eq_half_binary_entropy :
    condEnt (univ : Finset (Perm (Fin 3))) splitType (fun σ => Equiv.Perm.sign σ)
      = (1 / 2) * (Real.logb 2 3 - 2 / 3) := by
  rw [condEnt_splitType_sign]; ring

/-! ### The type is *needed*: a coarser read-out falls strictly below the ceiling -/

/-- The coarse read-out "does `p` split completely?", i.e. does the cubic have three roots
mod `p`. -/
def splitsCompletely (σ : Perm (Fin 3)) : Bool := decide (splitType σ = ({1, 1, 1} : Multiset ℕ))

/-- A transposition and a three-cycle are indistinguishable to the coarse read-out but have
opposite characters, so the coarse read-out leaves a mixed fibre. -/
theorem splitsCompletely_mixed_fibre :
    splitsCompletely (Equiv.swap 0 1) = splitsCompletely (Equiv.swap 0 1 * Equiv.swap 1 2) ∧
      Equiv.Perm.sign (Equiv.swap (0 : Fin 3) 1)
        ≠ Equiv.Perm.sign (Equiv.swap (0 : Fin 3) 1 * Equiv.swap 1 2) := by decide

/-- **The one-bit ceiling is not free.**  Replacing the full splitting type by the yes/no read-out
"does `p` split completely?" strictly loses information about the character: the channel drops
below one bit.  So `mutInfo_splitType_sign_eq_one` really is a statement about the type, not an
artefact of the framework. -/
theorem mutInfo_splitsCompletely_sign_lt_one :
    mutInfo (univ : Finset (Perm (Fin 3))) splitsCompletely (fun σ => Equiv.Perm.sign σ) < 1 := by
  have hpos : 0 < condEnt (univ : Finset (Perm (Fin 3))) (fun σ => Equiv.Perm.sign σ)
      splitsCompletely :=
    condEnt_pos_of_fiber_ne (x := Equiv.swap 0 1) (y := Equiv.swap 0 1 * Equiv.swap 1 2)
      (mem_univ _) (mem_univ _) splitsCompletely_mixed_fibre.1 splitsCompletely_mixed_fibre.2
  rw [mutInfo_comm univ_nonempty, mutInfo, uEnt_sign_eq_one (Fin 3)]
  linarith

/-- The full splitting type strictly beats its "splits completely?" coarsening. -/
theorem mutInfo_splitsCompletely_lt_splitType :
    mutInfo (univ : Finset (Perm (Fin 3))) splitsCompletely (fun σ => Equiv.Perm.sign σ)
      < mutInfo (univ : Finset (Perm (Fin 3))) splitType (fun σ => Equiv.Perm.sign σ) := by
  rw [mutInfo_splitType_sign_eq_one]
  exact mutInfo_splitsCompletely_sign_lt_one

end S3

end CyclicTypeChannel