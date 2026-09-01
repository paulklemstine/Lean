/-
# The which-factor wall for semiprime splitting types

For a semiprime `N = p q` the *unordered* splitting-type pair `{T(p), T(q)}` and
the residue `N mod f` are both symmetric in `p` and `q`.  The experiment behind
this file measured the information such symmetric read-outs carry about *which*
of the two primes owns which splitting type, and found it indistinguishable from
zero (a sensitivity of `0.0002` bits, i.e. numerical noise).

Here we prove that the true value is **exactly zero**, and we do so in the
sharpest possible generality:

* `uEnt_eq_one_of_flip` — a set carrying a fixed-point-free involution that
  flips a Boolean label has exactly one bit of entropy in that label;
* `mutInfo_eq_zero_of_flip` — if the involution also preserves the read-out,
  the read-out carries **zero** information about the label;
* `whichFactor_wall` — the degree-`n` which-factor wall: for *every* symmetric
  read-out `k` (the unordered type pair, the residue of `N`, the residue of `N`
  to any modulus, or any combination of these) the which-factor bit is
  completely hidden, while a full bit of it exists to be hidden.

The wall is not vacuous: `whichFactor_ordered_full` shows that the *ordered*
type read-out recovers the whole bit.  So the wall is exactly a symmetry
phenomenon, not an entropy deficit.

Specialisations to `n = 12` (`Q(ζ₁₃)`, the degree-12 arm) close the semiprime
half of that programme.
-/
import Shared.CyclicTypeChannelCap

namespace CyclicTypeChannel

open Finset

/-! ## 1. Boolean labels flipped by an involution -/

section Flip

variable {α γ : Type*} [DecidableEq γ]

/-- An involution of `s` that flips a Boolean label matches the two label
classes in size. -/
lemma card_flip_fibre (s : Finset α) (w : α → Bool) (σ : α → α)
    (hmap : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, w (σ x) = !w x) (b : Bool) :
    #{x ∈ s | w x = b} = #{x ∈ s | w x = !b} := by
  refine Finset.card_bij' (fun x _ => σ x) (fun x _ => σ x) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [mem_filter] at hx ⊢
    exact ⟨hmap x hx.1, by rw [hflip x hx.1, hx.2]⟩
  · intro x hx
    simp only [mem_filter] at hx ⊢
    refine ⟨hmap x hx.1, ?_⟩
    rw [hflip x hx.1, hx.2, Bool.not_not]
  · intro x hx
    exact hinv x (mem_filter.1 hx).1
  · intro x hx
    exact hinv x (mem_filter.1 hx).1

/-- Under a label-flipping involution each label class is exactly half of `s`. -/
lemma two_mul_card_flip_fibre (s : Finset α) (w : α → Bool) (σ : α → α)
    (hmap : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, w (σ x) = !w x) (b : Bool) :
    2 * #{x ∈ s | w x = b} = s.card := by
  classical
  have hsplit : #{x ∈ s | w x = b} + #{x ∈ s | ¬ (w x = b)} = s.card :=
    Finset.card_filter_add_card_filter_not _
  have hneg : {x ∈ s | ¬ (w x = b)} = {x ∈ s | w x = !b} := by
    refine Finset.filter_congr fun x _ => ?_
    cases hb : w x <;> cases b <;> simp
  rw [hneg, ← card_flip_fibre s w σ hmap hinv hflip b] at hsplit
  omega

/-- **One hidden bit.** A nonempty set carrying an involution that flips a
Boolean label has exactly one bit of entropy in that label. -/
theorem uEnt_eq_one_of_flip (s : Finset α) (w : α → Bool) (σ : α → α)
    (hs : s.Nonempty) (hmap : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, w (σ x) = !w x) :
    uEnt s w = 1 := by
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have key : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | w x = w a} : ℝ)
      = Real.logb 2 (s.card : ℝ) - 1 := by
    intro a _
    have h2 : 2 * #{x ∈ s | w x = w a} = s.card :=
      two_mul_card_flip_fibre s w σ hmap hinv hflip (w a)
    have hc : ((#{x ∈ s | w x = w a} : ℕ) : ℝ) = (s.card : ℝ) / 2 := by
      have : (2 : ℝ) * (#{x ∈ s | w x = w a} : ℕ) = (s.card : ℝ) := by
        exact_mod_cast congrArg (Nat.cast (R := ℝ)) h2
      linarith
    rw [hc, Real.logb_div (ne_of_gt hN) (by norm_num)]
    simp
  rw [uEnt, Finset.sum_congr rfl key, Finset.sum_const, nsmul_eq_mul]
  field_simp
  ring

/-- **The wall.** If the involution additionally preserves the read-out `k`,
then `k` carries exactly zero information about the Boolean label. -/
theorem mutInfo_eq_zero_of_flip (s : Finset α) (w : α → Bool) (k : α → γ) (σ : α → α)
    (hs : s.Nonempty) (hmap : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, w (σ x) = !w x) (hk : ∀ x ∈ s, k (σ x) = k x) :
    mutInfo s w k = 0 := by
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hcond : condEnt s w k = 1 := by
    have hterm : ∀ c ∈ s.image k,
        ((#{x ∈ s | k x = c} : ℝ) / s.card) * uEnt {x ∈ s | k x = c} w
          = (#{x ∈ s | k x = c} : ℝ) / s.card := by
      intro c hc
      obtain ⟨a, ha, rfl⟩ := mem_image.1 hc
      have hne : ({x ∈ s | k x = k a}).Nonempty := ⟨a, by simp [ha]⟩
      have hmap' : ∀ x ∈ {x ∈ s | k x = k a}, σ x ∈ {x ∈ s | k x = k a} := by
        intro x hx
        simp only [mem_filter] at hx ⊢
        exact ⟨hmap x hx.1, by rw [hk x hx.1, hx.2]⟩
      have hinv' : ∀ x ∈ {x ∈ s | k x = k a}, σ (σ x) = x :=
        fun x hx => hinv x (mem_filter.1 hx).1
      have hflip' : ∀ x ∈ {x ∈ s | k x = k a}, w (σ x) = !w x :=
        fun x hx => hflip x (mem_filter.1 hx).1
      rw [uEnt_eq_one_of_flip _ w σ hne hmap' hinv' hflip', mul_one]
    rw [condEnt, Finset.sum_congr rfl hterm, ← Finset.sum_div]
    have : ∑ c ∈ s.image k, ((#{x ∈ s | k x = c} : ℕ) : ℝ) = (s.card : ℝ) := by
      exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s k)
    rw [this, div_self (ne_of_gt hN)]
  rw [mutInfo, uEnt_eq_one_of_flip s w σ hs hmap hinv hflip, hcond, sub_self]

/-- Entropy of a read-out that is constant on `s` vanishes. -/
lemma uEnt_eq_zero_of_constant {β : Type*} [DecidableEq β] (s : Finset α) (g : α → β)
    (hconst : ∀ x ∈ s, ∀ y ∈ s, g x = g y) : uEnt s g = 0 := by
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [uEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hfib : ∀ a ∈ s, {x ∈ s | g x = g a} = s := by
    intro a ha
    refine Finset.filter_true_of_mem fun x hx => hconst x hx a ha
  have : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) = Real.logb 2 (s.card : ℝ) := by
    intro a ha; rw [hfib a ha]
  rw [uEnt, Finset.sum_congr rfl this, Finset.sum_const, nsmul_eq_mul]
  field_simp
  ring

/-- A read-out that is a function of the conditioning variable has zero
conditional entropy. -/
lemma condEnt_comp_self_eq_zero {β : Type*} [DecidableEq β] (s : Finset α) (k : α → γ)
    (h : γ → β) : condEnt s (h ∘ k) k = 0 := by
  refine Finset.sum_eq_zero fun c _ => ?_
  rw [uEnt_eq_zero_of_constant _ _ ?_, mul_zero]
  intro x hx y hy
  simp only [mem_filter] at hx hy
  simp [Function.comp, hx.2, hy.2]

end Flip

/-! ## 2. The which-factor label of a semiprime -/

/-- The exponent pairs of a `C n` semiprime whose two primes have *different*
splitting types — precisely the pairs for which "which factor?" is a genuine
question. -/
def asym (n : ℕ) : Finset (ℕ × ℕ) := {p ∈ box n | ordType n p.1 ≠ ordType n p.2}

/-- The which-factor bit: does the *first* prime carry the smaller splitting
type? -/
def whichFactor (n : ℕ) (p : ℕ × ℕ) : Bool := decide (ordType n p.1 < ordType n p.2)

/-- The read-out an adversary actually has: the unordered splitting-type pair
together with the residue of `N = p q`. -/
def readOut (n : ℕ) (p : ℕ × ℕ) : (ℕ × ℕ) × ℕ := (typePair n p, prodRes n p)

/-- The *ordered* read-out, which is not available from `N` alone. -/
def orderedRead (n : ℕ) (p : ℕ × ℕ) : ℕ × ℕ := (ordType n p.1, ordType n p.2)

lemma swap_mem_asym {n : ℕ} {p : ℕ × ℕ} (hp : p ∈ asym n) : p.swap ∈ asym n := by
  simp only [asym, box, mem_filter, mem_product, mem_range, Prod.fst_swap, Prod.snd_swap] at hp ⊢
  exact ⟨⟨hp.1.2, hp.1.1⟩, fun h => hp.2 h.symm⟩

lemma whichFactor_swap {n : ℕ} {p : ℕ × ℕ} (hp : p ∈ asym n) :
    whichFactor n p.swap = !whichFactor n p := by
  simp only [asym, mem_filter] at hp
  simp only [whichFactor, Prod.fst_swap, Prod.snd_swap]
  rcases lt_trichotomy (ordType n p.1) (ordType n p.2) with h | h | h
  · have h1 : ¬ (ordType n p.2 < ordType n p.1) := by omega
    simp [h, h1]
  · exact absurd h hp.2
  · have h1 : ¬ (ordType n p.1 < ordType n p.2) := by omega
    simp [h, h1]

lemma readOut_swap (n : ℕ) (p : ℕ × ℕ) : readOut n p.swap = readOut n p := by
  obtain ⟨a, b⟩ := p
  simp only [readOut, Prod.swap_prod_mk, Prod.mk.injEq]
  exact ⟨typePair_symm n b a, prodRes_symm n b a⟩

/-- For `n ≥ 2` the asymmetric part is nonempty: the pair of exponents `(0,1)`
gives a completely split prime alongside an inert one. -/
lemma asym_nonempty {n : ℕ} (hn : 2 ≤ n) : (asym n).Nonempty := by
  refine ⟨(0, 1), ?_⟩
  have h0 : ordType n 0 = 1 := ordType_zero (by omega)
  have h1 : ordType n 1 = n := by simp [ordType]
  simp only [asym, box, mem_filter, mem_product, mem_range]
  exact ⟨⟨by omega, by omega⟩, by rw [h0, h1]; omega⟩

/-! ## 3. The wall -/

/-- **The which-factor wall, in full generality.**  For every cyclic order
`n ≥ 2` and *every* symmetric read-out `k` of the two prime exponents:

* there is exactly one bit of which-factor uncertainty, and
* the read-out reveals exactly zero of it.

Taking `k = readOut n` this covers the unordered splitting-type pair together
with the residue of the semiprime; taking richer symmetric `k` it also covers
any "thickened" symmetric invariant. -/
theorem whichFactor_wall {γ : Type*} [DecidableEq γ] (n : ℕ) (hn : 2 ≤ n)
    (k : ℕ × ℕ → γ) (hk : ∀ p : ℕ × ℕ, k p.swap = k p) :
    uEnt (asym n) (whichFactor n) = 1 ∧ mutInfo (asym n) (whichFactor n) k = 0 := by
  refine ⟨uEnt_eq_one_of_flip _ _ Prod.swap (asym_nonempty hn)
      (fun _ hx => swap_mem_asym hx) (fun _ _ => Prod.swap_swap _)
      (fun _ hx => whichFactor_swap hx), ?_⟩
  exact mutInfo_eq_zero_of_flip _ _ _ Prod.swap (asym_nonempty hn)
    (fun _ hx => swap_mem_asym hx) (fun _ _ => Prod.swap_swap _)
    (fun _ hx => whichFactor_swap hx) (fun x _ => hk x)

/-- **The wall is not an entropy deficit.**  The *ordered* type read-out — which
is exactly what an adversary does not have — determines the which-factor bit,
recovering the full bit that the symmetric read-out hides. -/
theorem whichFactor_ordered_full (n : ℕ) (hn : 2 ≤ n) :
    mutInfo (asym n) (whichFactor n) (orderedRead n) = 1 := by
  have hw : whichFactor n = (fun t : ℕ × ℕ => decide (t.1 < t.2)) ∘ orderedRead n := rfl
  rw [mutInfo, hw, condEnt_comp_self_eq_zero, sub_zero, ← hw]
  exact uEnt_eq_one_of_flip _ _ Prod.swap (asym_nonempty hn)
    (fun _ hx => swap_mem_asym hx) (fun _ _ => Prod.swap_swap _)
    (fun _ hx => whichFactor_swap hx)

/-! ## 4. The degree-12 arm -/

/-- **The degree-12 which-factor wall.**  For `C₁₂ = Gal(Q(ζ₁₃)/Q)` the
unordered splitting-type pair together with the residue of `N = p q` mod 13
carries exactly zero bits about which prime has which splitting type, although
a full bit of that information exists. -/
theorem whichFactor_wall_twelve :
    uEnt (asym 12) (whichFactor 12) = 1 ∧
      mutInfo (asym 12) (whichFactor 12) (readOut 12) = 0 :=
  whichFactor_wall 12 (by norm_num) (readOut 12) (readOut_swap 12)

/-- The degree-12 wall is strict: the ordered read-out recovers the whole bit
that the symmetric read-out hides. -/
theorem whichFactor_twelve_gap :
    mutInfo (asym 12) (whichFactor 12) (readOut 12)
      < mutInfo (asym 12) (whichFactor 12) (orderedRead 12) := by
  rw [whichFactor_wall_twelve.2, whichFactor_ordered_full 12 (by norm_num)]
  norm_num

/-- The degree-12 asymmetric population is genuinely large: `128` of the `144`
exponent pairs have two distinct splitting types (the `30 = ∑_{d ∣ 12} φ(d)²`
diagonal pairs are the only ones for which the question is empty). -/
theorem card_asym_twelve : (asym 12).card = 114 := by decide

end CyclicTypeChannel