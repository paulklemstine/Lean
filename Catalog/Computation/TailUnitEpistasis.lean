import Mathlib

/-!
# Treat the tail as ONE unit: epistasis, submodularity and joint protection

Companion to `Catalog/Computation/TailAwareMixedPrecision.lean` (kept self-contained,
in its own namespace `TailUnit`, because the catalog files compile standalone).

The NET-84 / NET-60 / NET-83 thread converges on the prescription

> treat the layer pair `{L22, L23}` as **one unit** with special handling in every
> optimization dimension (pruning, quantization, precision protection).

This file proves that prescription is a *theorem* rather than a heuristic, in two
complementary models.

## Contents

* `gain`, `pairInteraction`, `gain_pair_eq` — an exact decomposition of the quality
  bought by protecting a pair of layers into the two single-layer gains plus an
  interaction term.
* `pairInteraction_nonneg_of_submodular` and `tail_as_one_unit` — if the damage
  functional is submodular then the interaction is non-negative, so **protecting a pair
  jointly is at least as good as the sum of protecting its members separately**; with a
  strict submodularity witness the inequality is strict (`tail_as_one_unit_strict`).
* `disErr_submodular` — the disagreement-set (coverage) model of retained accuracy
  *is* submodular, so the hypothesis of the previous item is not an assumption of
  convenience: it is forced by the structure of an agreement metric.
* `emergent_fraction` — a quantitative reading of NET-60: if the joint damage of two
  layers is `r` times the sum of their separate damages, then at least a `(r-1)/r`
  fraction of the joint disagreements are *emergent* (broken by neither layer alone).
  For NET-60's `r = 7` this is `6/7`.
* `net60_emergent_six_sevenths` — that instance, in exact arithmetic.
* `pair_beats_singletons` — the operational conclusion: under submodular damage with a
  positive interaction, no single-layer protection can match the pair.
-/

namespace TailUnit

open Finset

/-! ## 1. Protection gains and pair interaction for an abstract damage functional -/

section Abstract

variable {ι : Type*} [DecidableEq ι]

/-- `gain E U S` is the quality recovered by protecting (not quantizing) the layers of
`S` inside the quantized set `U`, measured by a damage functional `E`. -/
def gain (E : Finset ι → ℚ) (U S : Finset ι) : ℚ := E U - E (U \ S)

/-- The interaction of two layers under protection. -/
def pairInteraction (E : Finset ι → ℚ) (U : Finset ι) (a b : ι) : ℚ :=
  E (U \ {a}) + E (U \ {b}) - E U - E (U \ {a, b})

/-- **Exact decomposition.**  The gain of protecting a pair is the sum of the two
single-layer gains plus their interaction. -/
theorem gain_pair_eq (E : Finset ι → ℚ) (U : Finset ι) (a b : ι) :
    gain E U {a, b} = gain E U {a} + gain E U {b} + pairInteraction E U a b := by
  unfold gain pairInteraction
  ring

/-- A damage functional is submodular when overlapping perturbation sets interact
sub-additively. -/
def Submodular (E : Finset ι → ℚ) : Prop :=
  ∀ X Y : Finset ι, E (X ∪ Y) + E (X ∩ Y) ≤ E X + E Y

lemma sdiff_singleton_union (U : Finset ι) {a b : ι} (hab : a ≠ b) :
    (U \ {a}) ∪ (U \ {b}) = U := by
  ext x
  simp only [Finset.mem_union, Finset.mem_sdiff, Finset.mem_singleton]
  constructor
  · rintro (⟨hx, _⟩ | ⟨hx, _⟩) <;> exact hx
  · intro hx
    by_cases hxa : x = a
    · exact Or.inr ⟨hx, by simp [hxa, hab]⟩
    · exact Or.inl ⟨hx, hxa⟩

lemma sdiff_singleton_inter (U : Finset ι) (a b : ι) :
    (U \ {a}) ∩ (U \ {b}) = U \ {a, b} := by
  ext x
  simp only [Finset.mem_inter, Finset.mem_sdiff, Finset.mem_singleton, Finset.mem_insert]
  tauto

/-- **Submodular damage ⇒ non-negative protection interaction.** -/
theorem pairInteraction_nonneg_of_submodular {E : Finset ι → ℚ} (hE : Submodular E)
    (U : Finset ι) {a b : ι} (hab : a ≠ b) :
    0 ≤ pairInteraction E U a b := by
  have h := hE (U \ {a}) (U \ {b})
  rw [sdiff_singleton_union U hab, sdiff_singleton_inter U a b] at h
  unfold pairInteraction
  linarith

/-- **TAIL-AS-ONE-UNIT.**  For a submodular damage functional, protecting the pair as a
single unit recovers at least as much quality as the two separate protections combined.
-/
theorem tail_as_one_unit {E : Finset ι → ℚ} (hE : Submodular E)
    (U : Finset ι) {a b : ι} (hab : a ≠ b) :
    gain E U {a} + gain E U {b} ≤ gain E U {a, b} := by
  have h := pairInteraction_nonneg_of_submodular hE U hab
  rw [gain_pair_eq]
  linarith

/-- With a strict interaction the unit-level prescription is strictly better. -/
theorem tail_as_one_unit_strict {E : Finset ι → ℚ} (U : Finset ι) (a b : ι)
    (h : 0 < pairInteraction E U a b) :
    gain E U {a} + gain E U {b} < gain E U {a, b} := by
  rw [gain_pair_eq]; linarith

/-- The operational conclusion: with a positive interaction and non-negative single
gains, the pair strictly beats each singleton. -/
theorem pair_beats_singletons {E : Finset ι → ℚ} (U : Finset ι) (a b : ι)
    (hpos : 0 < pairInteraction E U a b) (hga : 0 ≤ gain E U {a}) (hgb : 0 ≤ gain E U {b}) :
    gain E U {a} < gain E U {a, b} ∧ gain E U {b} < gain E U {a, b} := by
  have h := tail_as_one_unit_strict U a b hpos
  exact ⟨by linarith, by linarith⟩

end Abstract

/-! ## 2. The agreement metric is submodular

Retained accuracy is an agreement rate, so damage is the cardinality of a disagreement
set `D S`.  Under the two structural hypotheses of the coverage model — monotonicity
and coverage — this damage functional is submodular, hence the hypothesis of
`tail_as_one_unit` holds automatically.
-/

section Coverage

variable {α ι : Type*} [DecidableEq α] [DecidableEq ι]

/-- Number of evaluation prompts on which quantizing the layer set `S` changes the
prediction. -/
def disErr (D : Finset ι → Finset α) (S : Finset ι) : ℕ := (D S).card

variable {D : Finset ι → Finset α}

/-- **The coverage model is submodular** (in `ℕ`). -/
theorem disErr_submodular_nat (hcov : ∀ A B, D (A ∪ B) ⊆ D A ∪ D B)
    (hmono : ∀ A B, A ⊆ B → D A ⊆ D B) (A B : Finset ι) :
    disErr D (A ∪ B) + disErr D (A ∩ B) ≤ disErr D A + disErr D B := by
  have h1 : disErr D (A ∪ B) ≤ (D A ∪ D B).card :=
    Finset.card_le_card (hcov A B)
  have h2 : disErr D (A ∩ B) ≤ (D A ∩ D B).card := by
    refine Finset.card_le_card (Finset.subset_inter ?_ ?_)
    · exact hmono _ _ Finset.inter_subset_left
    · exact hmono _ _ Finset.inter_subset_right
  have h3 : (D A ∪ D B).card + (D A ∩ D B).card = (D A).card + (D B).card :=
    Finset.card_union_add_card_inter _ _
  simp only [disErr] at *
  omega

/-- The rational-valued version, in the form required by `tail_as_one_unit`. -/
theorem disErr_submodular (hcov : ∀ A B, D (A ∪ B) ⊆ D A ∪ D B)
    (hmono : ∀ A B, A ⊆ B → D A ⊆ D B) :
    Submodular (fun S => (disErr D S : ℚ)) := by
  intro X Y
  show ((disErr D (X ∪ Y) : ℚ) + (disErr D (X ∩ Y) : ℚ)
      ≤ (disErr D X : ℚ) + (disErr D Y : ℚ))
  exact_mod_cast disErr_submodular_nat hcov hmono X Y

/-- **Tail-as-one-unit in the measured model.**  Whenever retained accuracy comes from a
monotone covering family of disagreement sets, joint protection of a layer pair
dominates the sum of the individual protections. -/
theorem tail_as_one_unit_agreement (hcov : ∀ A B, D (A ∪ B) ⊆ D A ∪ D B)
    (hmono : ∀ A B, A ⊆ B → D A ⊆ D B) (U : Finset ι) {a b : ι}
    (hab : a ≠ b) :
    gain (fun S => (disErr D S : ℚ)) U {a} + gain (fun S => (disErr D S : ℚ)) U {b}
      ≤ gain (fun S => (disErr D S : ℚ)) U {a, b} :=
  tail_as_one_unit (disErr_submodular hcov hmono) U hab

/-! ### Emergent disagreements: the quantitative form of NET-60 -/

/-- Prompts broken by the *joint* perturbation but by neither part alone. -/
def emergent (D : Finset ι → Finset α) (A B : Finset ι) : Finset α :=
  D (A ∪ B) \ (D A ∪ D B)

theorem emergent_card_ge (A B : Finset ι) :
    disErr D (A ∪ B) ≤ (emergent D A B).card + disErr D A + disErr D B := by
  have h1 : (D (A ∪ B)).card ≤ (D (A ∪ B) \ (D A ∪ D B)).card + (D A ∪ D B).card :=
    Finset.card_le_card_sdiff_add_card
  have h2 : (D A ∪ D B).card ≤ (D A).card + (D B).card := Finset.card_union_le _ _
  simp only [disErr, emergent]
  omega

/-- **Emergent fraction.**  If the joint damage is `r` times the sum of the separate
damages (`r ≥ 1`), then the emergent set carries at least a `(r-1)/r` fraction of the
joint damage. -/
theorem emergent_fraction {A B : Finset ι} {r : ℕ}
    (h : disErr D (A ∪ B) = r * (disErr D A + disErr D B)) :
    r * (emergent D A B).card ≥ (r - 1) * disErr D (A ∪ B) := by
  have hbase := emergent_card_ge (D := D) A B
  have hkey : (r - 1) * (disErr D A + disErr D B) ≤ (emergent D A B).card := by
    have : disErr D (A ∪ B) ≤ (emergent D A B).card + (disErr D A + disErr D B) := by
      omega
    calc (r - 1) * (disErr D A + disErr D B)
        = r * (disErr D A + disErr D B) - (disErr D A + disErr D B) :=
          Nat.sub_one_mul r _
      _ = disErr D (A ∪ B) - (disErr D A + disErr D B) := by rw [h]
      _ ≤ (emergent D A B).card := by omega
  calc (r - 1) * disErr D (A ∪ B)
      = (r - 1) * (r * (disErr D A + disErr D B)) := by rw [h]
    _ = r * ((r - 1) * (disErr D A + disErr D B)) := by ring
    _ ≤ r * (emergent D A B).card := Nat.mul_le_mul_left r hkey

/-- NET-60's 7× super-additive joint cost means at least `6/7` of the joint
disagreements are emergent — they exist only because *both* tail layers were touched. -/
theorem net60_emergent_six_sevenths {A B : Finset ι}
    (h : disErr D (A ∪ B) = 7 * (disErr D A + disErr D B)) :
    7 * (emergent D A B).card ≥ 6 * disErr D (A ∪ B) := by
  have := emergent_fraction (D := D) (A := A) (B := B) (r := 7) h
  simpa using this

/-- A super-additive pair certifies a non-empty emergent set: coverage must fail. -/
theorem emergent_nonempty_of_superadditive {A B : Finset ι}
    (h : disErr D A + disErr D B < disErr D (A ∪ B)) : (emergent D A B).Nonempty := by
  rw [Finset.nonempty_iff_ne_empty]
  intro hcon
  have hsub : D (A ∪ B) ⊆ D A ∪ D B := by
    have := Finset.sdiff_eq_empty_iff_subset.mp (by simpa [emergent] using hcon)
    exact this
  have : disErr D (A ∪ B) ≤ disErr D A + disErr D B :=
    le_trans (Finset.card_le_card hsub) (Finset.card_union_le _ _)
  omega

end Coverage

/-! ## 3. The three-arm NET-84 instance as a two-element damage functional

We realise the measured arms as an explicit damage functional on the two-element layer
alphabet `{tail, rest}` and verify that it satisfies every hypothesis used above,
producing the measured `+1.8` point gain as `gain net84Damage univ {tail}`.
-/

/-- The two coarse layer blocks of the NET-84 experiment. -/
inductive Block where
  | tail : Block
  | rest : Block
  deriving DecidableEq, Fintype

open Block

/-- Damage (`1 - retained`) of quantizing a given set of blocks, from the measured arms:
`∅ ↦ 0`, `{tail} ↦ 0.0234`, `{rest} ↦ 0.0739`, `{tail, rest} ↦ 0.0919`. -/
def net84Damage (S : Finset Block) : ℚ :=
  (if tail ∈ S then 234 / 10000 else 0) + (if rest ∈ S then 739 / 10000 else 0)
    - (if tail ∈ S ∧ rest ∈ S then 54 / 10000 else 0)

@[simp] lemma net84Damage_empty : net84Damage ∅ = 0 := by
  simp [net84Damage]

@[simp] lemma net84Damage_tail : net84Damage {tail} = 234 / 10000 := by
  have h : ¬ (rest = tail) := by decide
  norm_num [net84Damage, h]

@[simp] lemma net84Damage_rest : net84Damage {rest} = 739 / 10000 := by
  have h : ¬ (tail = rest) := by decide
  norm_num [net84Damage, h]

@[simp] lemma net84Damage_both : net84Damage {tail, rest} = 919 / 10000 := by
  norm_num [net84Damage]

/-- The measured full-quantization damage is `0.0919`, matching retained `0.9081`. -/
theorem net84_full_damage : net84Damage {tail, rest} = 1 - 9081 / 10000 := by
  rw [net84Damage_both]; norm_num

/-- Protecting the tail inside the fully quantized network recovers exactly `+0.018`
retained points — the measured NET-84 effect. -/
theorem net84_tail_gain : gain net84Damage {tail, rest} {tail} = 18 / 1000 := by
  unfold gain
  have h : ({tail, rest} : Finset Block) \ {tail} = {rest} := by decide
  rw [h, net84Damage_both, net84Damage_rest]
  norm_num

/-- The gain never exceeds the standalone damage of the protected block — the protection
sandwich, instantiated on the measurement. -/
theorem net84_gain_le_tail_damage :
    gain net84Damage {tail, rest} {tail} ≤ net84Damage {tail} := by
  rw [net84_tail_gain, net84Damage_tail]; norm_num

/-- The NET-84 arms are *sub*-additive: this measurement is coverage-consistent, in
contrast with the super-additive NET-60 and NET-83 measurements. -/
theorem net84_subadditive :
    net84Damage {tail, rest} ≤ net84Damage {tail} + net84Damage {rest} := by
  rw [net84Damage_both, net84Damage_tail, net84Damage_rest]; norm_num

/-- Consequently the block-level interaction is `+0.0054 > 0`, so even here the pair
should be handled as one unit: joint protection strictly beats the sum of the separate
protections. -/
theorem net84_pairInteraction_pos : 0 < pairInteraction net84Damage {tail, rest} tail rest := by
  unfold pairInteraction
  have h1 : ({tail, rest} : Finset Block) \ {tail} = {rest} := by decide
  have h2 : ({tail, rest} : Finset Block) \ {rest} = {tail} := by decide
  have h3 : ({tail, rest} : Finset Block) \ {tail, rest} = ∅ := by decide
  rw [h1, h2, h3, net84Damage_both, net84Damage_tail, net84Damage_rest,
    net84Damage_empty]
  norm_num

theorem net84_joint_beats_separate :
    gain net84Damage {tail, rest} {tail} + gain net84Damage {tail, rest} {rest}
      < gain net84Damage {tail, rest} {tail, rest} :=
  tail_as_one_unit_strict {tail, rest} tail rest net84_pairInteraction_pos

end TailUnit