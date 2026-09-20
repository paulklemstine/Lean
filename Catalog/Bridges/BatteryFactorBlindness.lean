/-
# BATTERY-SCALING, part III: factor-blindness is exact, at every number of dials

The round-27 #4 experiment reported a *which-factor wall*: the six-dial battery reads the
which-factor bit at `0.3594` against a permutation null of `0.3591` (`z = +0.11`), i.e. no
signal at all, exactly as at four dials.  This file proves the structural reason, and proves
it for a battery of *any* size:

  if some involution of the population preserves every dial reading but flips the binary
  which-factor label, then the joint reading of **every** sub-battery carries **exactly zero**
  information about that label.

So factor-blindness is not a small measured number: it is an identity, and the measured
`0.3594` is the sparse-table bias of a finite sample around the structural zero.

## Main results

* `TraceBattery.two_phi` — the cell identity `2 φ(N, m) = φ(N, 2m) + (2m/N) log 2`.
* `TraceBattery.H_bool_eq_log_two_of_flip` — a flipped binary statistic is perfectly balanced,
  so it carries exactly one bit.
* `TraceBattery.MI_eq_zero_of_flip_symmetry` — **factor blindness**: `I(C ; W) = 0` for every
  statistic `C` invariant under the flip involution.
* `TraceBattery.labelInfo_eq_zero_of_flip_symmetry` — the battery form: every sub-battery of a
  flip-invariant battery has zero which-factor capacity, at every `k`.
-/
import Mathlib
import Bridges.BatteryCapacityLaw

namespace TraceBattery

open Finset

variable {Ω : Type*} [Fintype Ω] {α : Type*}

/-! ## 1. Halving a cell -/

/-- Splitting a cell of size `2m` into two halves costs exactly one bit:
`2 φ(N, m) = φ(N, 2m) + (2m/N) log 2`. -/
theorem two_phi (N m : ℕ) : 2 * phi N m = phi N (2 * m) + ((2 * m : ℕ) : ℝ) / N * Real.log 2 := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simp [phi]
  rcases Nat.eq_zero_or_pos N with rfl | hN
  · simp [phi]
  have hmR : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hlog : Real.log ((2 * m : ℕ) : ℝ) = Real.log 2 + Real.log (m : ℝ) := by
    push_cast
    rw [Real.log_mul (by norm_num) (ne_of_gt hmR)]
  rw [phi, phi, hlog]
  push_cast
  ring

/-! ## 2. A flip involution -/

section Flip

variable {σ : Ω → Ω} {C : Ω → α} {W : Ω → Bool}

/-- The two halves of a cell cut by a flipped binary statistic have equal size. -/
theorem cnt_pair_true_eq_false (hinv : ∀ x, σ (σ x) = x) (hC : ∀ x, C (σ x) = C x)
    (hW : ∀ x, W (σ x) = !W x) (c : α) :
    cnt (fun x => (C x, W x)) (c, true) = cnt (fun x => (C x, W x)) (c, false) := by
  classical
  refine Finset.card_nbij' σ σ ?_ ?_ ?_ ?_
  · intro x hx
    simp only [Finset.mem_coe, mem_fib, Prod.mk.injEq] at hx ⊢
    exact ⟨by rw [hC x, hx.1], by rw [hW x, hx.2]; rfl⟩
  · intro x hx
    simp only [Finset.mem_coe, mem_fib, Prod.mk.injEq] at hx ⊢
    exact ⟨by rw [hC x, hx.1], by rw [hW x, hx.2]; rfl⟩
  · intro x _
    exact hinv x
  · intro x _
    exact hinv x

/-- The two halves of a cell cut by a binary statistic exhaust the cell. -/
theorem cnt_pair_add_eq_cnt (C : Ω → α) (W : Ω → Bool) (c : α) :
    cnt (fun x => (C x, W x)) (c, true) + cnt (fun x => (C x, W x)) (c, false) = cnt C c := by
  classical
  have h := Finset.card_filter_add_card_filter_not (s := fib C c) (p := fun x => W x = true)
  rw [cnt, cnt, cnt]
  rw [← h]
  congr 1
  · apply Finset.card_nbij' id id <;> intro x hx <;>
      simp only [Finset.mem_coe, mem_fib, Finset.mem_filter, Prod.mk.injEq, id] at hx ⊢ <;>
      tauto
  · apply Finset.card_nbij' id id <;> intro x hx <;>
      simp only [Finset.mem_coe, mem_fib, Finset.mem_filter, Prod.mk.injEq, id,
        Bool.not_eq_true] at hx ⊢ <;>
      tauto

/-- A flipped binary statistic takes both values. -/
theorem img_flip_eq_univ [Nonempty Ω] (hW : ∀ x, W (σ x) = !W x) :
    img W = (Finset.univ : Finset Bool) := by
  classical
  obtain ⟨x₀⟩ := ‹Nonempty Ω›
  refine Finset.eq_univ_of_forall fun b => ?_
  rcases Bool.eq_false_or_eq_true (W x₀) with h | h
  · rcases Bool.eq_false_or_eq_true b with rfl | rfl
    · exact mem_img.2 ⟨x₀, h⟩
    · exact mem_img.2 ⟨σ x₀, by rw [hW x₀, h]; rfl⟩
  · rcases Bool.eq_false_or_eq_true b with rfl | rfl
    · exact mem_img.2 ⟨σ x₀, by rw [hW x₀, h]; rfl⟩
    · exact mem_img.2 ⟨x₀, h⟩

/-- A statistic invariant under the flip involution, read jointly with the flipped bit,
carries exactly one bit more than the statistic alone. -/
theorem H_pair_eq_add_log_two [Nonempty Ω] (hinv : ∀ x, σ (σ x) = x) (hC : ∀ x, C (σ x) = C x)
    (hW : ∀ x, W (σ x) = !W x) :
    H (fun x => (C x, W x)) = H C + Real.log 2 := by
  classical
  have hNR : (0 : ℝ) < (Fintype.card Ω : ℝ) := by exact_mod_cast Fintype.card_pos
  have hcell : ∀ c : α,
      ∑ w ∈ img W, phi (Fintype.card Ω) (cnt (fun x => (C x, W x)) (c, w))
        = phi (Fintype.card Ω) (cnt C c) + (cnt C c : ℝ) / (Fintype.card Ω : ℝ) * Real.log 2 := by
    intro c
    have hbal := cnt_pair_true_eq_false hinv hC hW c
    have hsum := cnt_pair_add_eq_cnt C W c
    have hdouble : cnt C c = 2 * cnt (fun x => (C x, W x)) (c, true) := by omega
    rw [img_flip_eq_univ (σ := σ) hW, Fintype.sum_bool, hbal]
    have := two_phi (Fintype.card Ω) (cnt (fun x => (C x, W x)) (c, false))
    rw [hdouble, hbal]
    push_cast at this ⊢
    linarith [this]
  rw [H_pair_eq_sum_product C W, Finset.sum_congr rfl fun c _ => hcell c,
    Finset.sum_add_distrib, ← Finset.sum_mul, sum_prob C, one_mul, H_eq_sum_phi]

/-- A flipped binary statistic is balanced, hence carries exactly one bit (`log 2` nats). -/
theorem H_bool_eq_log_two [Nonempty Ω] (hinv : ∀ x, σ (σ x) = x) (hW : ∀ x, W (σ x) = !W x) :
    H W = Real.log 2 := by
  classical
  have hconst : ∀ x, (fun _ : Ω => ()) (σ x) = (fun _ : Ω => ()) x := fun _ => rfl
  have hpair := H_pair_eq_add_log_two (σ := σ) (C := fun _ : Ω => ()) (W := W) hinv hconst hW
  have h1 : H (fun x => ((fun _ : Ω => ()) x, W x)) = H W := by
    have hfun : (fun x => ((fun _ : Ω => ()) x, W x)) = (fun b : Bool => ((), b)) ∘ W := rfl
    rw [hfun]
    exact H_comp_eq_of_injective W (fun b₁ b₂ h => congrArg Prod.snd h)
  rw [h1, H_const_eq_zero (Ω := Ω) ()] at hpair
  linarith

/-- **Factor blindness.**  If an involution of the population preserves the reading `C` and
flips the binary label `W`, then `C` carries exactly zero information about `W` — however
many dials `C` bundles together. -/
theorem MI_eq_zero_of_flip_symmetry (hinv : ∀ x, σ (σ x) = x) (hC : ∀ x, C (σ x) = C x)
    (hW : ∀ x, W (σ x) = !W x) : MI C W = 0 := by
  rcases isEmpty_or_nonempty Ω with hΩ | hΩ
  · simp [MI, H, img_eq_empty_of_isEmpty]
  rw [MI, H_pair_eq_add_log_two hinv hC hW, H_bool_eq_log_two (σ := σ) hinv hW]
  ring

end Flip

/-! ## 3. The battery form -/

section Battery

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

omit [Fintype ι] [DecidableEq ι] in
/-- **The which-factor wall, at every `k`.**  If an involution of the population preserves
every dial of the battery but flips the which-factor bit, then every sub-battery — of any
size — has exactly zero which-factor capacity.  Monotonicity of the capacity curve therefore
does not help: the curve for this label is identically zero. -/
theorem labelInfo_eq_zero_of_flip_symmetry (d : ι → Dial Ω) (S : Finset ι) {σ : Ω → Ω}
    {W : Ω → Bool} (hinv : ∀ x, σ (σ x) = x) (hd : ∀ (i : ι) (x : Ω), (d i).read (σ x) = (d i).read x)
    (hW : ∀ x, W (σ x) = !W x) : labelInfo d S W = 0 := by
  refine MI_eq_zero_of_flip_symmetry (σ := σ) hinv ?_ hW
  intro x
  funext i
  exact hd i.1 x

end Battery

/-! ## 4. A non-vacuous witness: the symmetric sum dial on unordered pairs

The hypotheses of `labelInfo_eq_zero_of_flip_symmetry` are satisfiable with a battery that is
genuinely informative and a label that genuinely carries one bit: the population of ordered
pairs of distinct residues, the dial reading their sum (a symmetric function, exactly like the
CRT residue of a product `N = p q`), and the which-factor bit `is the first coordinate the
smaller one`.  The swap involution preserves the dial and flips the bit, so the capacity for
that bit is exactly `0` even though the dial has positive entropy and the bit carries a full
bit of entropy. -/

section Witness

/-- Ordered pairs of distinct residues mod `5`: the toy population of semiprimes. -/
abbrev SwapPop : Type := {v : Fin 5 × Fin 5 // v.1 ≠ v.2}

instance : Nonempty SwapPop := ⟨⟨(0, 1), by decide⟩⟩

/-- Swapping the two factors. -/
def swapPop (v : SwapPop) : SwapPop := ⟨(v.1.2, v.1.1), fun h => v.2 h.symm⟩

/-- The symmetric dial: the residue of the sum of the two factors. -/
def sumDial : Dial SwapPop where
  modulus := 5
  modulus_pos := by norm_num
  read := fun v => (v.1.1.val + v.1.2.val) % 5
  read_lt := by
    intro v
    exact Nat.mod_lt _ (by norm_num)

/-- The which-factor bit: is the first coordinate the smaller one? -/
def whichFactor (v : SwapPop) : Bool := decide (v.1.1.val < v.1.2.val)

theorem swapPop_involutive : ∀ v : SwapPop, swapPop (swapPop v) = v := by decide

theorem sumDial_swap_invariant : ∀ v : SwapPop, sumDial.read (swapPop v) = sumDial.read v := by
  decide

theorem whichFactor_flip : ∀ v : SwapPop, whichFactor (swapPop v) = !whichFactor v := by decide

/-- **The which-factor wall on a concrete informative battery.**  The sum dial has strictly
positive entropy, the which-factor bit carries a full bit, and yet the battery reads exactly
zero about it. -/
theorem swap_which_factor_wall :
    0 < H sumDial.read ∧ H whichFactor = Real.log 2 ∧
      labelInfo (fun _ : Fin 1 => sumDial) Finset.univ whichFactor = 0 := by
  refine ⟨?_, ?_, ?_⟩
  · refine H_pos_of_ne (f := sumDial.read)
      (x := ⟨(0, 1), by decide⟩) (y := ⟨(0, 2), by decide⟩) ?_
    decide
  · exact H_bool_eq_log_two (σ := swapPop) swapPop_involutive whichFactor_flip
  · exact labelInfo_eq_zero_of_flip_symmetry _ _ swapPop_involutive
      (fun _ x => sumDial_swap_invariant x) whichFactor_flip

end Witness

end TraceBattery