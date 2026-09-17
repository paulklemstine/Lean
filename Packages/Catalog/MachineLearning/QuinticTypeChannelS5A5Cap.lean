/-
# The abelianization cap: a maximum-entropy bound and the general seal

Second cycle on the `S₅` / `A₅` quintic endpoints of
`MachineLearning.QuinticTypeChannelS5A5`.  There the one-bit law of `S₅` and the zero of `A₅`
were computed by hand from the group structure.  Here we isolate the *general mechanism*, and
in doing so we add a piece of missing entropy infrastructure to the catalog.

## Results

* `uEnt_le_logb_card_image` — **the maximum-entropy bound**: for any read-out `g` on a finite
  box, `H(g) ≤ log₂ #(values of g)`.  The catalog only had the weaker `uEnt_le_logb_card`
  (`H(g) ≤ log₂ |box|`).  The proof is the log-sum inequality, obtained from
  `log x ≤ x - 1` term by term, and is the standard concavity argument in elementary form.
* `abelianization_cap` — **the general abelianization law**: for a finite group `G`, any
  homomorphism `φ : G →* M` into an abelian group and *any* read-out `T`,
  `I(φ ; T) ≤ log₂ |G^ab|`.  Everything a residue dial can hear is bounded by the
  abelianization, with no arithmetic input at all.
* `alternating_abelianization_trivial` — `|A₅^ab| = 1`, proved from the perfection engine
  `alternating_hom_trivial` of the first file.
* `alternating_seal_of_cap` — the `A₅` seal again, now as a one-line corollary of the general
  cap: every abelian dial on `A₅` has `I(φ ; T) = 0`, for every `T`.
* `S5_condEnt_type_given_sign`, `S5_type_not_pinned` — the residual: the `S₅` splitting type
  keeps `H(T | sign) = 2/5 + (17/40) log₂ 3 + (5/24) log₂ 5 = 1.5573…` bits that no residue
  can reach; the channel is genuinely lossy in the other direction.
* `S5_typeEntropy_gt_F20`, `S5_typeEntropy_gt_A5` — the `S₅` type entropy is the largest in
  the quintic row measured so far, strictly above the `F₂₀` value `11/10 + (log₂ 5)/4` of
  `Bridges.QuinticTypeChannelF20` and above the `A₅` value.
-/
import MachineLearning.QuinticTypeChannelS5A5
import Shared.CyclicTypeChannelNonneg

namespace QuinticS5A5

open Finset Equiv CyclicTypeChannel

set_option maxRecDepth 100000

/-! ## 1. The maximum-entropy bound -/

section MaxEntropy

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- **The maximum-entropy bound.**  A read-out with `m` distinct values has entropy at most
`log₂ m`, with the uniform distribution as the only extremal case.  Proof: the log-sum
inequality `∑ f_v log f_v ≥ N log (N/m)`, obtained from `log x ≤ x - 1` term by term. -/
theorem uEnt_le_logb_card_image (s : Finset α) (g : α → β) :
    uEnt s g ≤ Real.logb 2 ((s.image g).card : ℝ) := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hN : (0 : ℝ) < (s.card : ℝ) := by exact_mod_cast card_pos.2 hs
  have hm : (0 : ℝ) < ((s.image g).card : ℝ) := by exact_mod_cast card_pos.2 (hs.image g)
  have hfpos : ∀ v ∈ s.image g, (0 : ℝ) < ((#{x ∈ s | g x = v} : ℕ) : ℝ) := by
    intro v hv
    obtain ⟨a, ha, rfl⟩ := mem_image.1 hv
    exact_mod_cast fiber_card_pos ha
  have hsumf : ∑ v ∈ s.image g, ((#{x ∈ s | g x = v} : ℕ) : ℝ) = (s.card : ℝ) := by
    have := sum_fiber_card s g
    exact_mod_cast congrArg (fun k : ℕ => (k : ℝ)) this
  -- the log-sum inequality, term by term
  have key : ∀ v ∈ s.image g,
      ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log (s.card : ℝ)
        - ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log ((s.image g).card : ℝ)
        - ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log ((#{x ∈ s | g x = v} : ℕ) : ℝ)
        ≤ (s.card : ℝ) / ((s.image g).card : ℝ) - ((#{x ∈ s | g x = v} : ℕ) : ℝ) := by
    intro v hv
    have hf := hfpos v hv
    have h1 : Real.log ((s.card : ℝ) / (((s.image g).card : ℝ) * ((#{x ∈ s | g x = v} : ℕ) : ℝ)))
        ≤ (s.card : ℝ) / (((s.image g).card : ℝ) * ((#{x ∈ s | g x = v} : ℕ) : ℝ)) - 1 :=
      Real.log_le_sub_one_of_pos (by positivity)
    rw [Real.log_div (ne_of_gt hN) (by positivity),
      Real.log_mul (ne_of_gt hm) (ne_of_gt hf)] at h1
    have h2 := mul_le_mul_of_nonneg_left h1 hf.le
    have h3 : ((#{x ∈ s | g x = v} : ℕ) : ℝ) *
        ((s.card : ℝ) / (((s.image g).card : ℝ) * ((#{x ∈ s | g x = v} : ℕ) : ℝ)) - 1)
        = (s.card : ℝ) / ((s.image g).card : ℝ) - ((#{x ∈ s | g x = v} : ℕ) : ℝ) := by
      field_simp
    rw [h3] at h2
    nlinarith [h2]
  have hsum := Finset.sum_le_sum key
  have hL : ∑ v ∈ s.image g,
      (((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log (s.card : ℝ)
        - ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log ((s.image g).card : ℝ)
        - ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log ((#{x ∈ s | g x = v} : ℕ) : ℝ))
      = (s.card : ℝ) * Real.log (s.card : ℝ)
        - (s.card : ℝ) * Real.log ((s.image g).card : ℝ)
        - ∑ v ∈ s.image g,
            ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log ((#{x ∈ s | g x = v} : ℕ) : ℝ) := by
    rw [Finset.sum_sub_distrib, Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.sum_mul,
      hsumf]
  have hR : ∑ _v ∈ s.image g,
      ((s.card : ℝ) / ((s.image g).card : ℝ)) = (s.card : ℝ) := by
    rw [Finset.sum_const, nsmul_eq_mul]
    field_simp
  have hsum' : (s.card : ℝ) * Real.log (s.card : ℝ)
      - (s.card : ℝ) * Real.log ((s.image g).card : ℝ)
      ≤ ∑ v ∈ s.image g,
          ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log ((#{x ∈ s | g x = v} : ℕ) : ℝ) := by
    rw [hL, Finset.sum_sub_distrib, hR, hsumf] at hsum
    linarith
  -- convert from `log` to `logb` and finish
  have hconv : ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
      = (∑ v ∈ s.image g,
          ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log ((#{x ∈ s | g x = v} : ℕ) : ℝ))
        / Real.log 2 := by
    rw [sum_logb_fiber s g, Finset.sum_div]
    exact Finset.sum_congr rfl fun v _ => by rw [Real.logb, mul_div_assoc]
  set S := ∑ v ∈ s.image g,
    ((#{x ∈ s | g x = v} : ℕ) : ℝ) * Real.log ((#{x ∈ s | g x = v} : ℕ) : ℝ) with hSdef
  have hdiv : Real.log (s.card : ℝ) - Real.log ((s.image g).card : ℝ) ≤ S / (s.card : ℝ) := by
    rw [le_div_iff₀ hN]
    nlinarith [hsum']
  have hgoal : Real.log (s.card : ℝ) - S / (s.card : ℝ)
      ≤ Real.log ((s.image g).card : ℝ) := by linarith
  rw [uEnt, hconv, Real.logb, Real.logb]
  have heq : Real.log (s.card : ℝ) / Real.log 2 - S / Real.log 2 / (s.card : ℝ)
      = (Real.log (s.card : ℝ) - S / (s.card : ℝ)) / Real.log 2 := by
    field_simp
  rw [heq]
  gcongr

/-- The information a read-out can receive is capped by the logarithm of its number of
values. -/
theorem mutInfo_le_logb_card_image (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k ≤ Real.logb 2 ((s.image g).card : ℝ) :=
  le_trans (by rw [mutInfo]; linarith [condEnt_nonneg s g k]) (uEnt_le_logb_card_image s g)

end MaxEntropy

/-! ## 2. The general abelianization cap -/

/-- **The abelianization cap.**  For a finite group `G`, a homomorphism `φ` of `G` into an
abelian group and an arbitrary read-out `T` of the Frobenius, the information the dial `φ`
receives from `T` is at most `log₂ |G^ab|`.  Everything a residue class can hear about the
splitting behaviour is bounded by the abelianization — and by nothing else. -/
theorem abelianization_cap {G : Type*} [Group G] [Fintype G] [DecidableEq G]
    {M : Type*} [CommGroup M] [DecidableEq M] {β : Type*} [DecidableEq β]
    (φ : G →* M) (T : G → β) :
    mutInfo (univ : Finset G) (fun g => φ g) T
      ≤ Real.logb 2 (Nat.card (Abelianization G) : ℝ) := by
  classical
  letI : Fintype (Abelianization G) := Fintype.ofFinite _
  have hsub : (univ : Finset G).image (fun g => φ g)
      ⊆ (univ : Finset (Abelianization G)).image (fun a => Abelianization.lift φ a) := by
    intro x hx
    obtain ⟨g, _, rfl⟩ := mem_image.1 hx
    exact mem_image.2 ⟨Abelianization.of g, mem_univ _, by simp⟩
  have hcard : (((univ : Finset G).image (fun g => φ g)).card : ℝ)
      ≤ (Nat.card (Abelianization G) : ℝ) := by
    have h1 := Finset.card_le_card hsub
    have h2 := Finset.card_image_le (s := (univ : Finset (Abelianization G)))
      (f := fun a => Abelianization.lift φ a)
    have h3 : (univ : Finset (Abelianization G)).card = Nat.card (Abelianization G) := by
      rw [Finset.card_univ, Nat.card_eq_fintype_card]
    have : ((univ : Finset G).image (fun g => φ g)).card ≤ Nat.card (Abelianization G) := by
      omega
    exact_mod_cast this
  refine le_trans (mutInfo_le_logb_card_image _ _ T) ?_
  have hpos : (0 : ℝ) < (((univ : Finset G).image (fun g => φ g)).card : ℝ) := by
    have : ((univ : Finset G).image (fun g => φ g)).Nonempty :=
      ⟨φ 1, mem_image.2 ⟨1, mem_univ _, rfl⟩⟩
    exact_mod_cast card_pos.2 this
  exact Real.logb_le_logb_of_le (by norm_num) hpos hcard

/-- **`A₅` is perfect**, in the form `|A₅^ab| = 1`: the abelianization is the trivial group. -/
theorem alternating_abelianization_trivial :
    Nat.card (Abelianization (alternatingGroup (Fin 5))) = 1 := by
  have hsub : ∀ x : Abelianization (alternatingGroup (Fin 5)), x = 1 := by
    intro x
    obtain ⟨g, rfl⟩ := Quotient.exists_rep x
    exact alternating_hom_trivial Abelianization.of g
  have : Subsingleton (Abelianization (alternatingGroup (Fin 5))) :=
    ⟨fun a b => by rw [hsub a, hsub b]⟩
  exact Nat.card_eq_one_iff_unique.2 ⟨this, ⟨1⟩⟩

/-- **The `A₅` seal as a corollary of the general cap.**  Since `|A₅^ab| = 1`, every abelian
dial of `A₅` has mutual information exactly zero with every read-out of the Frobenius. -/
theorem alternating_seal_of_cap {M : Type*} [CommGroup M] [DecidableEq M]
    {β : Type*} [DecidableEq β] (φ : alternatingGroup (Fin 5) →* M)
    (T : alternatingGroup (Fin 5) → β) :
    mutInfo (univ : Finset (alternatingGroup (Fin 5))) (fun g => φ g) T = 0 := by
  have hle := abelianization_cap φ T
  rw [alternating_abelianization_trivial] at hle
  simp only [Nat.cast_one, Real.logb_one] at hle
  exact le_antisymm hle (mutInfo_nonneg _ _ _)

/-! ## 3. The residual of the `S₅` channel -/

lemma S5box_nonempty : S5box.Nonempty := ⟨1, by simp [S5box]⟩

/-- Mutual information is symmetric, so the splitting type also receives exactly one bit. -/
theorem S5_mutInfo_type_sign : mutInfo S5box qType signDial = 1 := by
  rw [mutInfo_comm S5box_nonempty, abelianization_law_S5]

/-- **The residual.**  `H(T | sign) = 2/5 + (17/40) log₂ 3 + (5/24) log₂ 5`: the part of the
`S₅` splitting type that no residue class can ever see. -/
theorem S5_condEnt_type_given_sign :
    condEnt S5box qType signDial
      = 2 / 5 + 17 / 40 * Real.logb 2 3 + 5 / 24 * Real.logb 2 5 := by
  have h := S5_mutInfo_type_sign
  rw [mutInfo, S5_typeEntropy] at h
  linarith

theorem S5_condEnt_bracket :
    1.5573 < condEnt S5box qType signDial ∧ condEnt S5box qType signDial < 1.5574 := by
  rw [S5_condEnt_type_given_sign]
  refine ⟨?_, ?_⟩
  · nlinarith [lb3_lower, lb5_lower]
  · nlinarith [lb3_upper, lb5_upper]

/-- **The `S₅` type channel is not pinned**: more than one and a half bits of the splitting
type are invisible from any residue. -/
theorem S5_type_not_pinned : 0 < condEnt S5box qType signDial := by
  have := S5_condEnt_bracket.1
  linarith

/-! ## 4. The quintic row: `S₅` is the top of the entropy column -/

/-- The `S₅` splitting entropy strictly exceeds the `F₂₀` splitting entropy
`11/10 + (log₂ 5)/4` of `Bridges.QuinticTypeChannelF20`. -/
theorem S5_typeEntropy_gt_F20 :
    uEnt QuinticF20.qFrob QuinticF20.qType < uEnt S5box qType := by
  rw [QuinticF20.quinticTypeEntropy_val, S5_typeEntropy]
  nlinarith [lb3_lower, lb5_lower, lb5_upper]

/-- The `S₅` splitting entropy strictly exceeds the `A₅` one. -/
theorem S5_typeEntropy_gt_A5 : uEnt A5box qType < uEnt S5box qType := A5_typeEntropy_lt_S5

end QuinticS5A5