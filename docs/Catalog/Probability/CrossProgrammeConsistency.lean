/-
# CROSS-PROGRAMME-CONSISTENCY (FACT round 31, paper 107)

Paper 107 cross-checks eight recorded information quantities (marginal, joint and
battery trace informations, in bits) across papers 80–106.  A numerical audit of
recordings can only ever *fail to find* an inconsistency; this file supplies the
**necessary consistency laws** that any family of such recordings must satisfy, so
that "ALL-CHECKS-PASS" becomes a statement with mathematical content.

Everything is built on the finitary Shannon calculus of the catalog:
`TraceBattery.H` (`Combinatorics.TraceBatteryEntropy`) and
`BatterySynergy.MI` (`MachineLearning.BatterySynergy.MutualInformation`).

Main results.

* `cap_mono`, `cap_le_label`, `cap_empty` — the capacity of a sub-battery
  `S ↦ I(L ; F|_S)` is a monotone set function, vanishing on `∅`, capped by the
  label entropy.
* `cap_insert_le`, `cap_union_le` — the **incremental capacity law** (proved by
  Finset induction): enlarging a battery by the dials of `T` raises its capacity by
  at most `Σ_{i ∈ T} H(Fᵢ)`.
* `cap_lattice_consistency` — the headline sandwich: for `S ⊆ T`,
  `0 ≤ cap S ≤ cap T ≤ min (H L) (cap S + Σ_{i ∈ T \ S} H(Fᵢ))`.
* `synergy_eq_interaction` — the synergy `I(L;f,g) - I(L;f) - I(L;g)` equals the
  interaction information `I(f;g | L) - I(f;g)`.
* `synergy_sandwich` — `-min(I(L;f), I(L;g)) ≤ Syn ≤ min(H(f|L), H(g|L))`.
* `xor_synergy_sharp` — the upper bound is attained (XOR battery), so the synergy
  sandwich cannot be improved in general.
* `entropy_column_obstruction` / `joint_column_is_not_entropy` — **Critic finding**:
  the joint column of the paper-107 table (2.1314 > 1.0012 + 1.0012) is
  super-additive, which is impossible for joint *entropies* (subadditivity); the
  recorded joints can only be trace *informations*, where synergy is allowed.
* `cap_not_submodular` — the capacity set function is monotone but **not**
  submodular: the XOR battery has second difference `log 2 > 0`.
-/
import Mathlib
import Combinatorics.TraceBatteryEntropy
import MachineLearning.BatterySynergy.MutualInformation

namespace CrossProgrammeConsistency

open TraceBattery BatterySynergy Finset

variable {Ω : Type*} [Fintype Ω] {Λ α β : Type*} {ι : Type*}

/-! ## 1. Sub-batteries and their capacity -/

/-- The joint reading of the dials in `S` of the battery `F`. -/
def sub (F : ι → Ω → α) (S : Finset ι) : Ω → (S → α) := fun x i => F i x

/-- The trace capacity (in nats) of the sub-battery `S` against the label `L`. -/
noncomputable def cap (L : Ω → Λ) (F : ι → Ω → α) (S : Finset ι) : ℝ := MI L (sub F S)

/-- **Monotonicity.**  A larger battery never carries less information. -/
theorem cap_mono (L : Ω → Λ) (F : ι → Ω → α) {S T : Finset ι} (hST : S ⊆ T) :
    cap L F S ≤ cap L F T := by
  have h : sub F S = (fun (v : T → α) (i : S) => v ⟨i, hST i.2⟩) ∘ sub F T := rfl
  unfold cap
  rw [h]
  exact MI_comp_le L (sub F T) _

/-- The capacity is capped by the label entropy. -/
theorem cap_le_label (L : Ω → Λ) (F : ι → Ω → α) (S : Finset ι) :
    cap L F S ≤ H L := MI_le_label_entropy L _

/-- The capacity is nonnegative. -/
theorem cap_nonneg (L : Ω → Λ) (F : ι → Ω → α) (S : Finset ι) :
    0 ≤ cap L F S := MI_nonneg L _

/-- A statistic with values in a subsingleton type has zero entropy. -/
theorem H_eq_zero_of_subsingleton {γ : Type*} [Subsingleton γ] (f : Ω → γ) : H f = 0 := by
  refine le_antisymm ?_ (H_nonneg f)
  have hcard : (img f).card ≤ 1 := Finset.card_le_one.2 fun a _ b _ => Subsingleton.elim a b
  have hle := H_le_log_card_img f
  interval_cases h : (img f).card
  · simpa using hle
  · simpa using hle

/-- The empty battery carries no information. -/
theorem cap_empty (L : Ω → Λ) (F : ι → Ω → α) : cap L F ∅ = 0 := by
  refine le_antisymm ?_ (cap_nonneg L F ∅)
  have : Subsingleton ((∅ : Finset ι) → α) :=
    ⟨fun u v => funext fun i => absurd i.2 (Finset.notMem_empty _)⟩
  calc cap L F ∅ ≤ H (sub F ∅) := MI_le_stat_entropy L _
    _ = 0 := H_eq_zero_of_subsingleton _

/-! ## 2. The incremental capacity law -/

/-- **Adding one dial** raises the capacity by at most that dial's entropy. -/
theorem cap_insert_le [DecidableEq ι] (L : Ω → Λ) (F : ι → Ω → α) (S : Finset ι) (j : ι) :
    cap L F (insert j S) ≤ cap L F S + H (F j) := by
  classical
  let u : (S → α) × α → (↥(insert j S) → α) :=
    fun p i => if h : (i : ι) ∈ S then p.1 ⟨i, h⟩ else p.2
  have hu : sub F (insert j S) = u ∘ (fun x => (sub F S x, F j x)) := by
    funext x i
    obtain ⟨i, hi⟩ := i
    by_cases h : i ∈ S
    · simp [u, sub, h]
    · have : i = j := by
        rcases Finset.mem_insert.1 hi with h' | h'
        · exact h'
        · exact absurd h' h
      subst this
      simp [u, sub, h]
  calc cap L F (insert j S) = MI L (u ∘ (fun x => (sub F S x, F j x))) := by
        rw [cap, hu]
    _ ≤ MI L (fun x => (sub F S x, F j x)) := MI_comp_le L _ u
    _ ≤ MI L (sub F S) + H (F j) := MI_pair_le_add_H L (sub F S) (F j)
    _ = cap L F S + H (F j) := rfl

/-- **Incremental capacity law.**  Adjoining the dials of `T` to a battery `S`
raises its capacity by at most `Σ_{i ∈ T} H(Fᵢ)`. -/
theorem cap_union_le [DecidableEq ι] (L : Ω → Λ) (F : ι → Ω → α) (S T : Finset ι) :
    cap L F (S ∪ T) ≤ cap L F S + ∑ i ∈ T, H (F i) := by
  induction T using Finset.induction_on with
  | empty => simp
  | insert j T hj ih =>
    rw [Finset.union_insert, Finset.sum_insert hj]
    have := cap_insert_le L F (S ∪ T) j
    linarith

/-- The capacity of a battery is at most the sum of its dial entropies. -/
theorem cap_le_sum_H [DecidableEq ι] (L : Ω → Λ) (F : ι → Ω → α) (T : Finset ι) :
    cap L F T ≤ ∑ i ∈ T, H (F i) := by
  have := cap_union_le L F ∅ T
  rw [Finset.empty_union, cap_empty] at this
  linarith

/-- **Capacity-lattice consistency.**  For nested batteries `S ⊆ T` every recording
of their capacities must obey
`0 ≤ cap S ≤ cap T ≤ min (H L) (cap S + Σ_{i ∈ T \ S} H(Fᵢ))`. -/
theorem cap_lattice_consistency [DecidableEq ι] (L : Ω → Λ) (F : ι → Ω → α)
    {S T : Finset ι} (hST : S ⊆ T) :
    0 ≤ cap L F S ∧ cap L F S ≤ cap L F T ∧
      cap L F T ≤ min (H L) (cap L F S + ∑ i ∈ T \ S, H (F i)) := by
  refine ⟨cap_nonneg L F S, cap_mono L F hST, le_min (cap_le_label L F T) ?_⟩
  have h := cap_union_le L F S (T \ S)
  rwa [Finset.union_sdiff_of_subset hST] at h

/-! ## 3. Synergy and interaction information -/

/-- The joint reading of two statistics. -/
def pair (f : Ω → α) (g : Ω → β) : Ω → α × β := fun x => (f x, g x)

/-- Synergy of two dials about a label. -/
noncomputable def Syn (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : ℝ :=
  MI L (pair f g) - MI L f - MI L g

/-- Mutual information between two dials. -/
noncomputable def dialMI (f : Ω → α) (g : Ω → β) : ℝ := H f + H g - H (pair f g)

/-- Conditional mutual information between two dials given the label. -/
noncomputable def condDialMI (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : ℝ :=
  H (pr L f) + H (pr L g) - H (pr L (pair f g)) - H L

/-- **Synergy is interaction information**:
`I(L; f,g) - I(L;f) - I(L;g) = I(f;g | L) - I(f;g)`. -/
theorem synergy_eq_interaction (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    Syn L f g = condDialMI L f g - dialMI f g := by
  unfold Syn condDialMI dialMI
  rw [MI_eq, MI_eq, MI_eq]
  ring

/-- `H(pr g L) = H(pr L g)`: the order of the coordinates is irrelevant. -/
theorem H_pr_swap (L : Ω → Λ) (g : Ω → β) : H (pr g L) = H (pr L g) := by
  have h : pr g L = Prod.swap ∘ pr L g := rfl
  rw [h, H_comp_eq_of_injective _ Prod.swap_injective]

/-- The two orders of a pair carry the same information. -/
theorem MI_pair_comm (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    MI L (pair f g) = MI L (pair g f) := by
  refine le_antisymm ?_ ?_
  · have h : pair f g = Prod.swap ∘ pair g f := rfl
    rw [h]; exact MI_comp_le L _ _
  · have h : pair g f = Prod.swap ∘ pair f g := rfl
    rw [h]; exact MI_comp_le L _ _

/-- The pair carries at least as much as either component. -/
theorem MI_le_pair_left (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : MI L f ≤ MI L (pair f g) := by
  have h : f = Prod.fst ∘ pair f g := rfl
  conv_lhs => rw [h]
  exact MI_comp_le L _ _

theorem MI_le_pair_right (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : MI L g ≤ MI L (pair f g) := by
  have h : g = Prod.snd ∘ pair f g := rfl
  conv_lhs => rw [h]
  exact MI_comp_le L _ _

/-- **Synergy sandwich.**
`-min(I(L;f), I(L;g)) ≤ Syn ≤ min(H(f|L), H(g|L))`,
where `H(g|L) = condH g L` is the residual entropy of the dial given the label. -/
theorem synergy_sandwich (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    -min (MI L f) (MI L g) ≤ Syn L f g ∧ Syn L f g ≤ min (condH f L) (condH g L) := by
  have h1 := MI_le_pair_left L f g
  have h2 := MI_le_pair_right L f g
  have hg : MI L (pair f g) ≤ MI L f + H g := MI_pair_le_add_H L f g
  have hf : MI L (pair f g) ≤ MI L g + H f := by
    rw [MI_pair_comm]; exact MI_pair_le_add_H L g f
  have ef : condH f L = H (pr L f) - H L := by rw [condH, H_pr_swap]
  have eg : condH g L = H (pr L g) - H L := by rw [condH, H_pr_swap]
  have mf := MI_eq L f
  have mg := MI_eq L g
  refine ⟨?_, le_min ?_ ?_⟩
  · unfold Syn
    rcases min_choice (MI L f) (MI L g) with h | h <;> rw [h] <;> linarith
  · unfold Syn; linarith
  · unfold Syn; linarith

/-! ## 4. Sharpness: the XOR battery -/

section Xor

/-- Label of the XOR battery. -/
def xorL : Bool × Bool → Bool := fun x => xor x.1 x.2

theorem cnt_eq_of_card {γ : Type*} [DecidableEq γ] (f : Bool × Bool → γ) (k : ℕ)
    (h : ∀ a ∈ img f, (Finset.univ.filter fun x => f x = a).card = k) :
    ∀ a ∈ img f, cnt f a = k := by
  intro a ha
  rw [cnt, fib_eq_filter]
  exact h a ha

theorem H_xorL : H xorL = Real.log 4 - Real.log 2 := by
  have := H_eq_log_sub_log_of_uniform xorL 2 (by norm_num)
    (cnt_eq_of_card _ 2 fun a _ => by cases a <;> decide)
  simpa using this

theorem H_fst : H (Prod.fst : Bool × Bool → Bool) = Real.log 4 - Real.log 2 := by
  have := H_eq_log_sub_log_of_uniform (Prod.fst : Bool × Bool → Bool) 2 (by norm_num)
    (cnt_eq_of_card _ 2 fun a _ => by cases a <;> decide)
  simpa using this

theorem H_snd : H (Prod.snd : Bool × Bool → Bool) = Real.log 4 - Real.log 2 := by
  have := H_eq_log_sub_log_of_uniform (Prod.snd : Bool × Bool → Bool) 2 (by norm_num)
    (cnt_eq_of_card _ 2 fun a _ => by cases a <;> decide)
  simpa using this

/-- An injective statistic on the four-point cube has entropy `log 4`. -/
theorem H_of_injective_cube {γ : Type*} (f : Bool × Bool → γ) (hf : Function.Injective f) :
    H f = Real.log 4 := by
  classical
  have := H_eq_log_sub_log_of_uniform f 1 (by norm_num) fun a ha => by
    obtain ⟨x, rfl⟩ := mem_img.1 ha
    rw [cnt, Finset.card_eq_one]
    refine ⟨x, Finset.ext fun y => ?_⟩
    simp only [mem_fib, Finset.mem_singleton]
    exact ⟨fun h => hf h, fun h => h ▸ rfl⟩
  simpa using this

theorem log_four : Real.log 4 = 2 * Real.log 2 := by
  rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring

/-- **The synergy sandwich is sharp.**  For the XOR battery each dial alone
carries no information about the label, the pair determines it, and the synergy
`log 2` meets the upper bound `min(H(f|L), H(g|L))` exactly. -/
theorem xor_synergy_sharp :
    MI xorL (Prod.fst : Bool × Bool → Bool) = 0 ∧
    MI xorL (Prod.snd : Bool × Bool → Bool) = 0 ∧
    MI xorL (pair (Prod.fst : Bool × Bool → Bool) Prod.snd) = Real.log 2 ∧
    Syn xorL (Prod.fst : Bool × Bool → Bool) Prod.snd = Real.log 2 ∧
    Syn xorL (Prod.fst : Bool × Bool → Bool) Prod.snd =
      min (condH (Prod.fst : Bool × Bool → Bool) xorL)
        (condH (Prod.snd : Bool × Bool → Bool) xorL) := by
  have hprf : H (pr xorL (Prod.fst : Bool × Bool → Bool)) = Real.log 4 :=
    H_of_injective_cube _ (by decide)
  have hprg : H (pr xorL (Prod.snd : Bool × Bool → Bool)) = Real.log 4 :=
    H_of_injective_cube _ (by decide)
  have h1 : MI xorL (Prod.fst : Bool × Bool → Bool) = 0 := by
    rw [MI_eq, H_xorL, H_fst, hprf, log_four]; ring
  have h2 : MI xorL (Prod.snd : Bool × Bool → Bool) = 0 := by
    rw [MI_eq, H_xorL, H_snd, hprg, log_four]; ring
  have h3 : MI xorL (pair (Prod.fst : Bool × Bool → Bool) Prod.snd) = Real.log 2 := by
    rw [MI_eq_label_entropy_of_determines xorL _ fun x y h => by
      simp only [pair, Prod.mk.injEq] at h; simp [xorL, h.1, h.2]]
    rw [H_xorL, log_four]; ring
  have h4 : Syn xorL (Prod.fst : Bool × Bool → Bool) Prod.snd = Real.log 2 := by
    rw [Syn, h1, h2, h3]; ring
  have cf : condH (Prod.fst : Bool × Bool → Bool) xorL = Real.log 2 := by
    rw [condH, H_pr_swap, hprf, H_xorL, log_four]; ring
  have cg : condH (Prod.snd : Bool × Bool → Bool) xorL = Real.log 2 := by
    rw [condH, H_pr_swap, hprg, H_xorL, log_four]; ring
  exact ⟨h1, h2, h3, h4, by rw [h4, cf, cg, min_self]⟩

end Xor

/-! ## 5. The Critic's obstruction: joints are informations, not entropies -/

/-- **Entropy-column obstruction.**  No pair of dials has marginal entropies
`a, b` (bits) and joint entropy `c > a + b`. -/
theorem entropy_column_obstruction (f : Ω → α) (g : Ω → β) {a b c : ℝ}
    (ha : Hb f = a) (hb : Hb g = b) (hc : Hb (pair f g) = c) : c ≤ a + b := by
  subst ha hb hc
  have h := H_pair_le f g
  rw [Hb, Hb, Hb, ← add_div]
  exact div_le_div_of_nonneg_right h (le_of_lt log_two_pos)

/-- Applied to the recorded paper-107 row `S₃a × S₃b`: the joint `2.1314` bits with
marginals `1.0012, 1.0012` bits cannot be a joint/marginal *entropy* triple. -/
theorem joint_column_is_not_entropy (f : Ω → α) (g : Ω → β) :
    ¬ (Hb f = 1.0012 ∧ Hb g = 1.0012 ∧ Hb (pair f g) = 2.1314) := by
  rintro ⟨ha, hb, hc⟩
  have := entropy_column_obstruction f g ha hb hc
  norm_num at this

/-- The same row *is* admissible as a trace-information triple: the synergy
sandwich only forces `max(marginals) ≤ joint`, i.e. `Syn ≥ -min`, and
`0.1290 = 2.1314 - 2.0024` bits of synergy must be funded by the residual dial
entropies `H(fᵢ | L)`.  Arithmetic of the recorded table (bits). -/
theorem recorded_table_passes_necessary_checks :
    -- marginal ≤ joint (monotonicity)
    (1.0012 : ℝ) ≤ 2.1314 ∧ (0.4733 : ℝ) ≤ 1.9125 ∧ (1.4342 : ℝ) ≤ 1.9125 ∧
    -- two-field joints ≤ four-field capacity (monotonicity)
    (2.1314 : ℝ) ≤ 8.2246 ∧ (1.9125 : ℝ) ≤ 8.2246 ∧
    -- four-field capacity ≤ joint label-entropy ceiling
    (8.2246 : ℝ) ≤ 9.5276 ∧
    -- synergy lower bound Syn ≥ -min
    -(1.0012 : ℝ) ≤ 2.1314 - 1.0012 - 1.0012 ∧ -(0.4733 : ℝ) ≤ 1.9125 - 0.4733 - 1.4342 ∧
    -- all spreads ≤ 0.0040
    |(1.0008 : ℝ) - 1.0012| ≤ 0.0040 ∧ |(1.4302 : ℝ) - 1.4342| ≤ 0.0040 := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, by norm_num, by norm_num,
    by norm_num, by norm_num, ?_, ?_⟩ <;>
  rw [abs_le] <;> constructor <;> norm_num

/-! ## 6. Multi-dial synergy budget -/

/-- A one-dial sub-battery carries exactly the information of that dial. -/
theorem cap_singleton (L : Ω → Λ) (F : ι → Ω → α) (i : ι) :
    cap L F {i} = MI L (F i) := by
  refine le_antisymm ?_ ?_
  · have h : sub F {i} = (fun (a : α) (_ : ({i} : Finset ι)) => a) ∘ F i := by
      funext x j
      obtain ⟨j, hj⟩ := j
      rw [Finset.mem_singleton] at hj
      subst hj
      rfl
    rw [cap, h]
    exact MI_comp_le L _ _
  · have h : F i = (fun v : ({i} : Finset ι) → α => v ⟨i, Finset.mem_singleton_self i⟩) ∘
        sub F {i} := rfl
    rw [cap]
    conv_lhs => rw [h]
    exact MI_comp_le L _ _

/-- Entropy of a dial splits as information about the label plus residual. -/
theorem H_eq_MI_add_condH (L : Ω → Λ) (f : Ω → α) : H f = MI L f + condH f L := by
  rw [MI_eq, condH, H_pr_swap]; ring

/-- **Battery synergy budget.**  The synergy of a whole battery, i.e. its capacity
minus the sum of its one-dial marginals, is funded by the residual dial entropies:
`cap T - Σᵢ I(L;Fᵢ) ≤ Σᵢ H(Fᵢ | L)`. -/
theorem battery_synergy_le [DecidableEq ι] (L : Ω → Λ) (F : ι → Ω → α) (T : Finset ι) :
    cap L F T - ∑ i ∈ T, cap L F {i} ≤ ∑ i ∈ T, condH (F i) L := by
  have h := cap_le_sum_H L F T
  have hs : ∑ i ∈ T, H (F i) = ∑ i ∈ T, cap L F {i} + ∑ i ∈ T, condH (F i) L := by
    rw [← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by rw [cap_singleton, H_eq_MI_add_condH L]
  linarith

/-- **Falsifiable prediction from the paper-92/107 battery row.**  Any battery whose
capacity is `8.2246` bits while its marginals add up to `3.9099` bits must have
residual dial entropies totalling at least `4.3147` bits. -/
theorem residual_entropy_forced [DecidableEq ι] (L : Ω → Λ) (F : ι → Ω → α) (T : Finset ι)
    (hcap : cap L F T / Real.log 2 = 8.2246)
    (hmarg : (∑ i ∈ T, cap L F {i}) / Real.log 2 = 3.9099) :
    4.3147 ≤ (∑ i ∈ T, condH (F i) L) / Real.log 2 := by
  have h := battery_synergy_le L F T
  have hl := log_two_pos
  rw [div_eq_iff hl.ne'] at hcap hmarg
  rw [le_div_iff₀ hl]
  linarith

/-! ## 7. Capacity is not submodular -/

/-- The XOR battery with two dials indexed by `Bool`: dial `true` reads the first
bit, dial `false` the second. -/
def xorBattery : Bool → Bool × Bool → Bool := fun b x => if b then x.1 else x.2

/-- **Capacity is monotone but not submodular.**  For the XOR battery the second
difference `cap {i,j} - cap {i} - cap {j} + cap ∅` equals `log 2 > 0`: the two dials
are complements, not substitutes, so greedy dial selection has no submodular
guarantee. -/
theorem cap_not_submodular :
    cap xorL xorBattery {true, false} - cap xorL xorBattery {true}
      - cap xorL xorBattery {false} + cap xorL xorBattery ∅ = Real.log 2 ∧
    0 < cap xorL xorBattery {true, false} - cap xorL xorBattery {true}
      - cap xorL xorBattery {false} + cap xorL xorBattery ∅ := by
  obtain ⟨h1, h2, -, -, -⟩ := xor_synergy_sharp
  have e1 : cap xorL xorBattery {true} = 0 := by
    rw [cap_singleton]; exact h1
  have e2 : cap xorL xorBattery {false} = 0 := by
    rw [cap_singleton]; exact h2
  have e12 : cap xorL xorBattery {true, false} = Real.log 2 := by
    rw [cap, MI_eq_label_entropy_of_determines xorL _ fun x y h => by
      have ht := congrFun h ⟨true, by simp⟩
      have hf := congrFun h ⟨false, by simp⟩
      simp only [sub, xorBattery, if_true, Bool.false_eq_true, if_false] at ht hf
      simp only [xorL, ht, hf]]
    rw [H_xorL, log_four]; ring
  have key : cap xorL xorBattery {true, false} - cap xorL xorBattery {true}
      - cap xorL xorBattery {false} + cap xorL xorBattery ∅ = Real.log 2 := by
    rw [e1, e2, e12, cap_empty]; ring
  exact ⟨key, key ▸ log_two_pos⟩

end CrossProgrammeConsistency