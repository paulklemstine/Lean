import Mathlib

/-!
# Sign-blind deviation readouts: what the MA-1 effectivity sweep can and cannot see

Experiment 566 (paper 213) regresses the arithmetic-progression deviation readout

  `D(m) = max_a |π(x;m,a) − E| / √E`,   secondary `χ²(m) = Σ_a (π(x;m,a) − E)²/E`

on the quadratic-character L-mass `P(m) = Σ_χ |L(1,χ)|`, and records a pre-registered
null (`R² = 0.0187` at `x = 2^26`, `R² = 0.0785` at `x = 2^28`, both far below the
`0.5` bar).  Two methodological items in the ledger are *mathematical* statements, not
statistics, and this file proves them.

1. **The within-modulus permutation control is vacuous.**  Both registered readouts are
   symmetric functions of the residue-class counts.  Consequently the permutation
   p-value of either readout is *exactly* `1` for every count field, whatever the
   arithmetic: the control can never reject.  (`maxDev_comp_perm`, `chiSq_comp_perm`,
   `permPValue_eq_one_of_invariant`, `permutation_control_vacuous`.)

2. **The readout is sign-blind, and sign-blindness is a genuine loss.**  The signed
   character alignment `align c χ = Σ_a c a · χ(a)` is *not* a function of the
   permutation-invariant readouts.  For every prime `p ≡ 3 (mod 4)` we exhibit two
   count fields on `ZMod p` — one the negation-reflection of the other — with *identical*
   `maxDev` and `χ²` but with alignments of opposite sign and of maximal size `p − 1`.
   (`align_comp_of_odd`, `quadraticChar_comp_neg`, `signblind_misses_alignment`.)

Item 2 is the formal content of the paper's prominent scoping caveat: the recorded null
bounds the *magnitude* route only; a signed character-alignment analysis is a strictly
finer instrument, and cannot be inferred from the recorded statistics.

Nothing here is asymptotic or model-dependent: all statements are exact identities about
finite count fields.
-/

namespace Ma1Effectivity

open Finset

variable {ι : Type*} [Fintype ι]

/-! ## The two registered readouts, and the signed alignment -/

/-- The registered primary readout: the normalised maximal deviation of a count field `c`
from its expectation `E` over the residue classes. -/
noncomputable def maxDev [Nonempty ι] (c : ι → ℝ) (E : ℝ) : ℝ :=
  (univ.sup' univ_nonempty fun a => |c a - E|) / Real.sqrt E

/-- The registered secondary readout: the `χ²` statistic of a count field. -/
noncomputable def chiSq (c : ι → ℝ) (E : ℝ) : ℝ := (∑ a, (c a - E) ^ 2) / E

/-- The *signed* character alignment of a count field with a weight `w` (in practice a real
Dirichlet character).  This is the functional that the sign-blind readouts discard. -/
def align (c w : ι → ℝ) : ℝ := ∑ a, c a * w a

/-! ## Both readouts are permutation invariant -/

theorem maxDev_comp_perm [Nonempty ι] (c : ι → ℝ) (E : ℝ) (σ : Equiv.Perm ι) :
    maxDev (c ∘ σ) E = maxDev c E := by
  have key : (univ.sup' univ_nonempty fun a => |c (σ a) - E|)
      = univ.sup' univ_nonempty fun a => |c a - E| := by
    refine le_antisymm (Finset.sup'_le _ _ fun a _ => ?_) (Finset.sup'_le _ _ fun a _ => ?_)
    · exact Finset.le_sup' (fun a => |c a - E|) (mem_univ (σ a))
    · have := Finset.le_sup' (fun b => |c (σ b) - E|) (mem_univ (σ.symm a))
      simpa using this
  simpa [maxDev, Function.comp] using congrArg (fun t => t / Real.sqrt E) key

theorem chiSq_comp_perm (c : ι → ℝ) (E : ℝ) (σ : Equiv.Perm ι) :
    chiSq (c ∘ σ) E = chiSq c E := by
  have : ∑ a, (c (σ a) - E) ^ 2 = ∑ a, (c a - E) ^ 2 :=
    Fintype.sum_equiv σ _ _ (fun _ => rfl)
  simp [chiSq, Function.comp, this]

/-! ## Vacuity of the within-modulus permutation control -/

open scoped Classical in
/-- The one-sided permutation p-value of a statistic `T` on a count field `c`: the fraction
of relabelings of the residue classes whose statistic is at least the observed one. -/
noncomputable def permPValue (T : (ι → ℝ) → ℝ) (c : ι → ℝ) : ℝ :=
  ((univ.filter fun σ : Equiv.Perm ι => T c ≤ T (c ∘ σ)).card : ℝ) /
    (Fintype.card (Equiv.Perm ι) : ℝ)

/-- **The permutation control cannot reject.**  For any statistic invariant under
relabeling of the residue classes, the within-modulus permutation p-value is exactly `1`,
for every count field.  The test has power zero. -/
theorem permPValue_eq_one_of_invariant {T : (ι → ℝ) → ℝ}
    (hT : ∀ (c : ι → ℝ) (σ : Equiv.Perm ι), T (c ∘ σ) = T c) (c : ι → ℝ) :
    permPValue T c = 1 := by
  classical
  have hfilter : (univ.filter fun σ : Equiv.Perm ι => T c ≤ T (c ∘ σ)) = univ := by
    refine Finset.filter_true_of_mem fun σ _ => ?_
    rw [hT c σ]
  have hpos : (0 : ℝ) < (Fintype.card (Equiv.Perm ι) : ℝ) := by
    exact_mod_cast Fintype.card_pos (α := Equiv.Perm ι)
  rw [permPValue, hfilter, Finset.card_univ]
  field_simp

/-- The registered primary readout has a vacuous within-modulus permutation control. -/
theorem permutation_control_vacuous [Nonempty ι] (c : ι → ℝ) (E : ℝ) :
    permPValue (fun c => maxDev c E) c = 1 ∧ permPValue (fun c => chiSq c E) c = 1 :=
  ⟨permPValue_eq_one_of_invariant (fun c σ => maxDev_comp_perm c E σ) c,
   permPValue_eq_one_of_invariant (fun c σ => chiSq_comp_perm c E σ) c⟩

/-! ## Sign-blindness is a strict loss of information -/

/-- Reflecting a count field along an involution under which the weight is odd flips the
sign of the alignment. -/
theorem align_comp_of_odd (ν : Equiv.Perm ι) (w : ι → ℝ) (hw : ∀ a, w (ν a) = -w a)
    (c : ι → ℝ) : align (c ∘ ν) w = -align c w := by
  have h1 : ∑ a, c (ν a) * w a = ∑ a, -(c (ν a) * w (ν a)) := by
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [hw a]; ring
  have h2 : ∑ a, c (ν a) * w (ν a) = ∑ a, c a * w a :=
    Fintype.sum_equiv ν _ _ (fun _ => rfl)
  simp only [align, Function.comp]
  rw [h1, Finset.sum_neg_distrib, h2]

/-- **General separation.**  If a weight `w` is odd along a relabeling `ν` and the field `c`
has nonzero alignment, then `c` and its reflection `c ∘ ν` are indistinguishable by every
permutation-invariant readout yet carry opposite alignment. -/
theorem invariant_readout_blind_to_alignment {T : (ι → ℝ) → ℝ}
    (hT : ∀ (c : ι → ℝ) (σ : Equiv.Perm ι), T (c ∘ σ) = T c)
    (ν : Equiv.Perm ι) (w : ι → ℝ) (hw : ∀ a, w (ν a) = -w a) {c : ι → ℝ}
    (hc : align c w ≠ 0) :
    T (c ∘ ν) = T c ∧ align (c ∘ ν) w ≠ align c w := by
  refine ⟨hT c ν, ?_⟩
  rw [align_comp_of_odd ν w hw c]
  intro h
  exact hc (by linarith)

/-! ## The arithmetic instance: quadratic characters mod `p ≡ 3 (mod 4)` -/

variable (p : ℕ) [Fact p.Prime]

/-- The real-valued quadratic character mod `p`. -/
noncomputable def chiR (a : ZMod p) : ℝ := ((quadraticChar (ZMod p) a : ℤ) : ℝ)

theorem chiR_sq_one {a : ZMod p} (ha : a ≠ 0) : chiR p a ^ 2 = 1 := by
  have h : (quadraticChar (ZMod p) a) ^ 2 = 1 := quadraticChar_sq_one ha
  have : ((quadraticChar (ZMod p) a : ℤ) : ℝ) ^ 2 = ((1 : ℤ) : ℝ) := by
    exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) h
  simpa [chiR] using this

theorem chiR_zero : chiR p 0 = 0 := by simp [chiR]

theorem chiR_sum_zero (hp : p ≠ 2) : ∑ a : ZMod p, chiR p a = 0 := by
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rw [ZMod.ringChar_zmod_n]
    exact_mod_cast hp
  have h := quadraticChar_sum_zero (F := ZMod p) hchar
  have : ((∑ a : ZMod p, quadraticChar (ZMod p) a : ℤ) : ℝ) = ((0 : ℤ) : ℝ) := by
    exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) h
  simpa [chiR, Int.cast_sum] using this

/-- For `p ≡ 3 (mod 4)` the quadratic character is **odd**: `χ(−a) = −χ(a)`. -/
theorem chiR_comp_neg (hp3 : p % 4 = 3) (a : ZMod p) : chiR p (-a) = -chiR p a := by
  have hp : p ≠ 2 := by omega
  have hchar : ringChar (ZMod p) ≠ 2 := by
    rw [ZMod.ringChar_zmod_n]; exact_mod_cast hp
  have hcard : Fintype.card (ZMod p) = p := ZMod.card p
  have hneg : quadraticChar (ZMod p) (-1) = -1 := by
    rw [quadraticChar_neg_one hchar, hcard]
    exact ZMod.χ₄_nat_three_mod_four hp3
  have hmul : quadraticChar (ZMod p) (-a)
      = quadraticChar (ZMod p) (-1) * quadraticChar (ZMod p) a := by
    rw [← map_mul]; ring_nf
  have : ((quadraticChar (ZMod p) (-a) : ℤ) : ℝ)
      = -((quadraticChar (ZMod p) a : ℤ) : ℝ) := by
    rw [hmul, hneg]; push_cast; ring
  simpa [chiR] using this

/-- The reflection `a ↦ −a` of the residue classes. -/
def negPerm : Equiv.Perm (ZMod p) := Equiv.neg (ZMod p)

/-- The character-tilted count field `E + χ` has maximal alignment `p − 1` with `χ`. -/
theorem align_tilted_eq (hp : p ≠ 2) (E : ℝ) :
    align (fun a => E + chiR p a) (chiR p) = (p : ℝ) - 1 := by
  have hsplit : align (fun a => E + chiR p a) (chiR p)
      = E * (∑ a : ZMod p, chiR p a) + ∑ a : ZMod p, chiR p a ^ 2 := by
    simp only [align]
    rw [Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun a _ => by ring
  rw [hsplit, chiR_sum_zero p hp, mul_zero, zero_add]
  have hzero : (0 : ZMod p) ∈ (univ : Finset (ZMod p)) := mem_univ 0
  have hone : ∀ a ∈ (univ : Finset (ZMod p)).erase 0, chiR p a ^ 2 = 1 :=
    fun a ha => chiR_sq_one p (Finset.ne_of_mem_erase ha)
  have hcard : (univ : Finset (ZMod p)).card = p := by simp [ZMod.card]
  have hp1 : 1 ≤ p := Nat.one_le_iff_ne_zero.2 (Nat.Prime.pos (Fact.out (p := p.Prime))).ne'
  rw [← Finset.sum_erase_add univ _ hzero, Finset.sum_congr rfl hone, Finset.sum_const,
    Finset.card_erase_of_mem hzero, hcard, chiR_zero, nsmul_eq_mul, mul_one, Nat.cast_sub hp1]
  norm_num

/-- **The sweep's readouts cannot see character alignment.**  For every prime
`p ≡ 3 (mod 4)` and every expectation level `E`, there are two count fields on the residue
classes mod `p` with *identical* `maxDev` and `χ²` readouts whose signed alignments with
the quadratic character are exactly opposite and of maximal size `p − 1`.

This is the formal statement of the paper's SIGN-BLIND scoping caveat: the pre-registered
magnitude readout is a strictly coarser instrument than a signed character-alignment
analysis, so the recorded null bounds the magnitude route only. -/
theorem signblind_misses_alignment (hp3 : p % 4 = 3) (E : ℝ) :
    ∃ c₁ c₂ : ZMod p → ℝ,
      maxDev c₁ E = maxDev c₂ E ∧ chiSq c₁ E = chiSq c₂ E ∧
      align c₁ (chiR p) = ((p : ℝ) - 1) ∧ align c₂ (chiR p) = -((p : ℝ) - 1) ∧
      align c₁ (chiR p) ≠ align c₂ (chiR p) := by
  have hp : p ≠ 2 := by omega
  have hp3' : (3 : ℝ) ≤ (p : ℝ) := by
    have : 3 ≤ p := by
      rcases Nat.lt_or_ge p 3 with h | h
      · interval_cases p <;> omega
      · exact h
    exact_mod_cast this
  have hodd : ∀ a : ZMod p, chiR p (negPerm p a) = -chiR p a := by
    intro a; simpa [negPerm] using chiR_comp_neg p hp3 a
  set c : ZMod p → ℝ := fun a => E + chiR p a with hc
  have hval : align c (chiR p) = (p : ℝ) - 1 := align_tilted_eq p hp E
  have hrefl : align (c ∘ negPerm p) (chiR p) = -((p : ℝ) - 1) := by
    rw [align_comp_of_odd (negPerm p) (chiR p) hodd c, hval]
  refine ⟨c, c ∘ negPerm p, (maxDev_comp_perm c E (negPerm p)).symm,
    (chiSq_comp_perm c E (negPerm p)).symm, hval, hrefl, ?_⟩
  rw [hval, hrefl]
  intro h
  linarith

end Ma1Effectivity