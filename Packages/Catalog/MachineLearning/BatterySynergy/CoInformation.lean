/-
# BATTERY-SYNERGY, part V: co-information — the exact law of dial dependence

Round-27 #1 (paper 91, verdict *SYNERGY-AND-OVERLAP*) refutes the pre-stated
*coprime-conductor additivity* hypothesis in **both** directions:

| battery | `I(joint)` | `I₁ + I₂` | `Δ` |
|---|---|---|---|
| `S₃a@31 × S₃b@23` | `2.1314` | `2.0024` | `+0.129`  synergy |
| `A₄@9 × D₄@8` | `1.9125` | `1.9076` | `+0.005`  near-additive |
| `S₃a@23 × S₃b@23` (shared disc `−23`) | `1.0104` | `2.0024` | `−0.992`  overlap |

The stated mechanism is that the additivity argument "treated dial labels as
independent draws": both dials read the *same* underlying population, so their
readings are correlated, and the correlation has two competing components.

This file proves that this mechanism is an exact theorem, not a heuristic.  For
two dials read against a label `L` on a finite population, define the
**pair synergy**

`Δ(L; f, g) = I(L ; (f,g)) − I(L ; f) − I(L ; g)`.

Then (`BatterySynergy.pairSynergy_eq_condMI_sub_readMI`)

`Δ(L; f, g) = I(f ; g | L) − I(f ; g)`,

the *co-information* identity: synergy is exactly the excess of the
label-conditional dependence of the two dials over their unconditional
dependence.  Everything in the paper-91 table follows:

* `condMI_nonneg` — conditional dependence is nonnegative (proved from the data
  processing inequality of part I, not assumed);
* `pairSynergy_ge_neg_readMI` — **overlap is bounded by the shared channel**:
  `I₁ + I₂ − I(joint) ≤ I(f ; g)`.  Two `−23` cubics can overlap by `0.992`
  bits only because their readings share that much information;
* `pairSynergy_nonneg_of_reads_independent` — genuinely independent readings can
  only *synergize*; additivity is then a knife edge, and the observed `+0.129`
  is the generic outcome;
* `additive_iff_condMI_eq_readMI` — exact additivity holds **iff** the two forms
  of dependence cancel exactly.  Additivity is a measure-zero coincidence, which
  is why the hypothesis "coprime conductors ⇒ additive" failed at the first pair;
* `pairSynergy_ge_neg_min` — overlap never exceeds the smaller marginal;
* `pairSynergy_eq_neg_of_refines` — **"same subfield = same dial"**: if one dial
  is a post-processing of the other, the overlap is the *entire* marginal of the
  redundant dial, `Δ = −I(L ; g)`;
* `synergy_pair_eq_pairSynergyb` — the bridge to `BatterySynergy.synergy` of
  part II, so the two-dial rows of the paper-91 table are literally this
  quantity.

No numerical input, no `native_decide`, no new axioms.
-/
import Mathlib
import MachineLearning.BatterySynergy.Capacity

namespace BatterySynergy

open TraceBattery Finset

variable {Ω : Type*} [Fintype Ω] {α β Λ : Type*} {ι : Type*}

/-! ## 1. The joint reading of two dials and the triple statistic -/

/-- The joint reading of two dials. -/
def pair (f : Ω → α) (g : Ω → β) : Ω → α × β := fun x => (f x, g x)

/-- The triple statistic `(label, first reading, second reading)`. -/
def tri (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : Ω → Λ × α × β := fun x => (L x, f x, g x)

omit [Fintype Ω] in
theorem tri_eq_pr (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : tri L f g = pr L (pair f g) := rfl

omit [Fintype Ω] in
theorem pr_eq_pair (L : Ω → Λ) (f : Ω → α) : pr L f = pair L f := rfl

/-! ## 2. Pair synergy, conditional dependence, and the reading dependence -/

/-- The **pair synergy** in nats: the excess of the joint capacity of two dials
over the additive prediction.  Positive = synergy, negative = overlap. -/
noncomputable def pairSynergy (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : ℝ :=
  MI L (pair f g) - MI L f - MI L g

/-- The **overlap** of two dials: the amount by which the additive prediction
overshoots the true joint capacity.  This is `+0.992` bits for the two `−23`
cubics and `−0.129` bits for the `31 × 23` pair. -/
noncomputable def overlap (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : ℝ :=
  -pairSynergy L f g

/-- The **label-conditional dependence** `I(f ; g | L)` of the two readings. -/
noncomputable def condMI (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : ℝ :=
  H (pr L f) + H (pr L g) - H (tri L f g) - H L

/-- The **unconditional dependence** `I(f ; g)` of the two readings: the shared
channel of the two dials.  For two cubics of the same discriminant this is the
common quadratic character. -/
noncomputable def readMI (f : Ω → α) (g : Ω → β) : ℝ := MI f g

theorem readMI_eq (f : Ω → α) (g : Ω → β) : readMI f g = H f + H g - H (pair f g) :=
  MI_eq f g

theorem readMI_nonneg (f : Ω → α) (g : Ω → β) : 0 ≤ readMI f g := MI_nonneg f g

/-- Pair synergy in **bits** — the unit of the paper-91 table. -/
noncomputable def pairSynergyb (L : Ω → Λ) (f : Ω → α) (g : Ω → β) : ℝ :=
  pairSynergy L f g / Real.log 2

/-! ## 3. The co-information identity -/

/-- **Co-information identity.**  The synergy of two dials is exactly the excess
of their label-conditional dependence over their unconditional dependence:

`I(L ; (f,g)) − I(L ; f) − I(L ; g) = I(f ; g | L) − I(f ; g)`.

This is the quantitative form of the paper-91 mechanism: the additivity argument
treats the two readings as independent draws, i.e. sets both dependence terms to
zero; in a real battery both are nonzero and their difference has either sign. -/
theorem pairSynergy_eq_condMI_sub_readMI (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    pairSynergy L f g = condMI L f g - readMI f g := by
  simp only [pairSynergy, condMI, readMI, MI_eq, tri_eq_pr, pr_eq_pair]
  ring

/-! ## 4. Nonnegativity of the conditional dependence -/

/-- `H(g, (L, f)) = H(L, f, g)`: reshuffling the components of a statistic does
not change its partition. -/
theorem H_swap_tri [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    H (pr g (pr L f)) = H (tri L f g) := by
  refine H_eq_of_same_fibers _ _ fun x y => ?_
  simp only [pr, tri, Prod.mk.injEq]
  constructor
  · rintro ⟨hg, hL, hf⟩; exact ⟨hL, hf, hg⟩
  · rintro ⟨hL, hf, hg⟩; exact ⟨hg, hL, hf⟩

theorem H_swap_pr [Nonempty Ω] (L : Ω → Λ) (g : Ω → β) : H (pr g L) = H (pr L g) := by
  refine H_eq_of_same_fibers _ _ fun x y => ?_
  simp only [pr, Prod.mk.injEq]
  exact ⟨fun h => ⟨h.2, h.1⟩, fun h => ⟨h.2, h.1⟩⟩

/-- The conditional dependence as a drop in conditional entropy:
`I(f ; g | L) = H(g | L) − H(g | (L,f))`. -/
theorem condMI_eq_condH_sub [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    condMI L f g = condH g L - condH g (pr L f) := by
  simp only [condMI, condH, H_swap_tri L f g, H_swap_pr L g]
  ring

/-- **Conditional dependence is nonnegative.**  Learning the first reading can
only reduce the residual uncertainty of the second one inside a label class.
Proved from the data processing inequality of part I. -/
theorem condMI_nonneg [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    0 ≤ condMI L f g := by
  have hdpi : condH g (pr L f) ≤ condH g (Prod.fst ∘ pr L f) :=
    condH_comp_le g (pr L f) Prod.fst
  have hcoe : (Prod.fst ∘ pr L f) = L := rfl
  rw [hcoe] at hdpi
  rw [condMI_eq_condH_sub L f g]
  linarith

/-- The conditional dependence is symmetric in the two dials. -/
theorem condMI_comm [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    condMI L f g = condMI L g f := by
  have h : H (tri L f g) = H (tri L g f) := by
    refine H_eq_of_same_fibers _ _ fun x y => ?_
    simp only [tri, Prod.mk.injEq]
    constructor
    · rintro ⟨hL, hf, hg⟩; exact ⟨hL, hg, hf⟩
    · rintro ⟨hL, hg, hf⟩; exact ⟨hL, hf, hg⟩
  simp only [condMI, h]
  ring

/-- The conditional dependence is bounded by the entropy of either reading. -/
theorem condMI_le_H_right [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    condMI L f g ≤ H g := by
  rw [condMI_eq_condH_sub L f g]
  have h1 : condH g L ≤ H g := condH_le_label g L
  have h2 : 0 ≤ condH g (pr L f) := condH_nonneg g (pr L f)
  linarith

theorem condMI_le_H_left [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    condMI L f g ≤ H f := by
  rw [condMI_comm]
  exact condMI_le_H_right L g f

/-! ## 5. The two directions of the refutation -/

/-- **Overlap is bounded by the shared channel.**  The amount by which the
additive prediction overshoots is at most the mutual information of the two
readings themselves.  Two cubics of discriminant `−23` can overlap by `0.992`
bits only because their readings share at least that much. -/
theorem overlap_le_readMI [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    overlap L f g ≤ readMI f g := by
  have h := condMI_nonneg L f g
  rw [overlap, pairSynergy_eq_condMI_sub_readMI]
  linarith

theorem pairSynergy_ge_neg_readMI [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    -readMI f g ≤ pairSynergy L f g := by
  have := overlap_le_readMI L f g
  rw [overlap] at this
  linarith

/-- **Independent dials can only synergize.**  If the two readings are
unconditionally independent — the situation the coprime-conductor hypothesis
assumed — then the battery is *super*-additive, never sub-additive.  Additivity
would require the readings to be conditionally independent as well. -/
theorem pairSynergy_nonneg_of_reads_independent [Nonempty Ω] (L : Ω → Λ) (f : Ω → α)
    (g : Ω → β) (h : readMI f g = 0) : 0 ≤ pairSynergy L f g := by
  have := condMI_nonneg L f g
  rw [pairSynergy_eq_condMI_sub_readMI, h]
  linarith

/-- **Additivity is a knife edge.**  The additive prediction is exact precisely
when the conditional and unconditional dependences of the two readings coincide.
Nothing about coprimality of the conductors forces this coincidence: it is one
linear equation on the joint law. -/
theorem additive_iff_condMI_eq_readMI (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    pairSynergy L f g = 0 ↔ condMI L f g = readMI f g := by
  rw [pairSynergy_eq_condMI_sub_readMI, sub_eq_zero]

/-- Synergy is capped by the conditional dependence, hence by the smaller of the
two reading entropies. -/
theorem pairSynergy_le_min_read_entropy [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    pairSynergy L f g ≤ min (H f) (H g) := by
  have h0 := readMI_nonneg f g
  have h1 := condMI_le_H_left L f g
  have h2 := condMI_le_H_right L f g
  rw [pairSynergy_eq_condMI_sub_readMI, le_min_iff]
  constructor <;> linarith

/-! ## 6. Monotonicity: overlap never exceeds the smaller marginal -/

theorem MI_le_MI_pair_left (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    MI L f ≤ MI L (pair f g) := by
  have h : (Prod.fst ∘ pair f g) = f := rfl
  have := MI_comp_le L (pair f g) (Prod.fst (β := β))
  rwa [h] at this

theorem MI_le_MI_pair_right (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    MI L g ≤ MI L (pair f g) := by
  have h : (Prod.snd ∘ pair f g) = g := rfl
  have := MI_comp_le L (pair f g) (Prod.snd (α := α))
  rwa [h] at this

/-- **Overlap never exceeds the smaller marginal.**  The joint capacity is at
least the larger of the two marginals, so the deficit `I₁ + I₂ − I(joint)` is at
most `min (I₁, I₂)`.  In the paper-91 table the two `−23` cubics have
`I₁ = I₂ = 1.0012` and overlap `0.992`: they realise `99.1 %` of this bound. -/
theorem pairSynergy_ge_neg_min (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    -min (MI L f) (MI L g) ≤ pairSynergy L f g := by
  rcases le_total (MI L f) (MI L g) with h | h
  · have := MI_le_MI_pair_right L f g
    rw [pairSynergy, min_eq_left h]
    linarith
  · have := MI_le_MI_pair_left L f g
    rw [pairSynergy, min_eq_right h]
    linarith

theorem overlap_le_min (L : Ω → Λ) (f : Ω → α) (g : Ω → β) :
    overlap L f g ≤ min (MI L f) (MI L g) := by
  have := pairSynergy_ge_neg_min L f g
  rw [overlap]
  linarith

/-! ## 7. "Same subfield = same dial": total overlap -/

/-- **A redundant dial contributes nothing.**  If the second reading is a
post-processing of the first — the algebraic situation of two cubic fields
sharing their quadratic resolvent — the joint capacity equals the first
marginal, so the overlap is the *whole* of the second marginal. -/
theorem pairSynergy_eq_neg_of_refines [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) (g : Ω → β)
    (u : α → β) (hu : g = u ∘ f) : pairSynergy L f g = -MI L g := by
  have hfib : ∀ x y, pair f g x = pair f g y ↔ f x = f y := by
    intro x y
    simp only [pair, Prod.mk.injEq, hu, Function.comp_apply]
    exact ⟨fun h => h.1, fun h => ⟨h, congrArg u h⟩⟩
  have hjoint : MI L (pair f g) = MI L f := MI_eq_of_same_fibers L _ _ hfib
  rw [pairSynergy, hjoint]
  ring

/-- The comonotone extreme: two copies of the same dial.  The battery of a dial
with itself carries exactly what the dial carries, and the overlap is the full
marginal — the exact form of "same subfield = same dial". -/
theorem overlap_self [Nonempty Ω] (L : Ω → Λ) (f : Ω → α) :
    overlap L f f = MI L f := by
  have h := pairSynergy_eq_neg_of_refines L f f id rfl
  rw [overlap, h, neg_neg]

/-- **The overlap bound of §5 is attained.**  When the two dials are equal and
the label is the reading itself, the overlap equals the shared channel exactly:
`overlap = I(f ; g) = H f`.  So no bound better than `overlap ≤ I(f ; g)` is
available. -/
theorem overlap_eq_readMI_of_self_label [Nonempty Ω] (f : Ω → α) :
    overlap f f f = readMI f f ∧ readMI f f = H f := by
  have hdet : ∀ x y : Ω, f x = f y → f x = f y := fun _ _ h => h
  have hMI : MI f f = H f := MI_eq_label_entropy_of_determines f f hdet
  refine ⟨?_, hMI⟩
  rw [overlap_self f f, readMI, hMI]

/-! ## 8. Bridge to the battery formalism of part II -/

section Bridge

variable [DecidableEq ι] [Nonempty Ω]

omit [Fintype Ω] [DecidableEq ι] [Nonempty Ω] in
theorem joint_single_fiber (d : ι → Dial Ω) (i : ι) (x y : Ω) :
    joint d {i} x = joint d {i} y ↔ (d i).read x = (d i).read y := by
  constructor
  · intro h
    exact congrFun h ⟨i, Finset.mem_singleton_self i⟩
  · intro h
    funext k
    obtain ⟨k, hk⟩ := k
    rw [Finset.mem_singleton] at hk
    subst hk
    exact h

omit [Fintype Ω] [Nonempty Ω] in
theorem joint_pair_fiber (d : ι → Dial Ω) (i j : ι) (x y : Ω) :
    joint d {i, j} x = joint d {i, j} y ↔
      pair (d i).read (d j).read x = pair (d i).read (d j).read y := by
  constructor
  · intro h
    have hi : (d i).read x = (d i).read y :=
      congrFun h ⟨i, Finset.mem_insert_self i {j}⟩
    have hj : (d j).read x = (d j).read y :=
      congrFun h ⟨j, Finset.mem_insert_of_mem (Finset.mem_singleton_self j)⟩
    simp [pair, hi, hj]
  · intro h
    simp only [pair, Prod.mk.injEq] at h
    funext k
    obtain ⟨k, hk⟩ := k
    rw [Finset.mem_insert, Finset.mem_singleton] at hk
    rcases hk with rfl | rfl
    · exact h.1
    · exact h.2

omit [DecidableEq ι] in
theorem info_singleton_eq (d : ι → Dial Ω) (L : Ω → Λ) (i : ι) :
    info d L {i} = MIb L (d i).read := by
  rw [info, MIb, MIb, MI_eq_of_same_fibers L (joint d {i}) (d i).read (joint_single_fiber d i)]

theorem info_pair_eq (d : ι → Dial Ω) (L : Ω → Λ) (i j : ι) :
    info d L {i, j} = MIb L (pair (d i).read (d j).read) := by
  rw [info, MIb, MIb,
    MI_eq_of_same_fibers L (joint d {i, j}) _ (joint_pair_fiber d i j)]

/-- **The paper-91 rows are exactly the pair synergy.**  For two distinct dials
of a battery, the `synergy` of part II coincides with `pairSynergyb` of the two
readings, so the co-information identity applies verbatim to the measured table
entries. -/
theorem synergy_pair_eq_pairSynergyb (d : ι → Dial Ω) (L : Ω → Λ) {i j : ι} (hij : i ≠ j) :
    synergy d L {i, j} = pairSynergyb L (d i).read (d j).read := by
  rw [synergy, Finset.sum_insert (by simpa using hij), Finset.sum_singleton,
    info_pair_eq, info_singleton_eq, info_singleton_eq, pairSynergyb, pairSynergy, MIb, MIb, MIb]
  ring

/-- **The co-information law for a two-dial sub-battery**, in bits: the measured
`Δ` of the paper-91 table is the conditional dependence minus the unconditional
dependence of the two dial readings. -/
theorem synergy_pair_eq_coinfo (d : ι → Dial Ω) (L : Ω → Λ) {i j : ι} (hij : i ≠ j) :
    synergy d L {i, j}
      = (condMI L (d i).read (d j).read - readMI (d i).read (d j).read) / Real.log 2 := by
  rw [synergy_pair_eq_pairSynergyb d L hij, pairSynergyb,
    pairSynergy_eq_condMI_sub_readMI]

/-- **Neither additive nor comonotone, in bits.**  A two-dial sub-battery obeys
the two-sided law

`− min (I₁, I₂) ≤ Δ ≤ min (Hb read₁, Hb read₂)`,

and the left edge is attained exactly by redundant dials.  This is the abstract
shape of the paper-91 table: `+0.129`, `+0.005`, `−0.992` against marginals
`1.0012`. -/
theorem synergy_pair_two_sided (d : ι → Dial Ω) (L : Ω → Λ) {i j : ι} (hij : i ≠ j) :
    -min (info d L {i}) (info d L {j}) ≤ synergy d L {i, j} ∧
      synergy d L {i, j} ≤ min (Hb (d i).read) (Hb (d j).read) := by
  have hlog := log_two_pos
  constructor
  · rw [synergy_pair_eq_pairSynergyb d L hij, info_singleton_eq, info_singleton_eq,
      pairSynergyb, MIb, MIb, min_div_div_right hlog.le, ← neg_div]
    exact (div_le_div_iff_of_pos_right hlog).mpr (pairSynergy_ge_neg_min L _ _)
  · rw [synergy_pair_eq_pairSynergyb d L hij, pairSynergyb, Hb, Hb,
      min_div_div_right hlog.le]
    exact (div_le_div_iff_of_pos_right hlog).mpr (pairSynergy_le_min_read_entropy L _ _)

end Bridge

end BatterySynergy