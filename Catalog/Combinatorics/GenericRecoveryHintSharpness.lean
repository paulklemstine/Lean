/-
# GENERIC-RECOVERY, cycle II: the taxonomy is *tight*

Sequel to `Combinatorics.GenericRecoveryHintTaxonomy`.  Cycle I proved the
negative half of the hint taxonomy: a `t`-bit hint never cuts a candidate set by
more than `2^t`, parity-constrained value hints lose a bit, post-processing and
joining never help, and public hints are worthless.  A negative theory is only
as strong as its sharpness, and only as interesting as the *exact* deficit it
assigns to the borderline families.  This file supplies three sharpenings and
one bridge.

* **§1 Sharpness.**  `GenericRecovery.card_fiber_blockHint` and
  `GenericRecovery.image_blockHint`: on a candidate set of size `q·2^t` the
  block hint `p ↦ p / q` realises all `2^t` values with *every* fibre of size
  exactly `q = |S| / 2^t`.  Together with the master bound of cycle I, the
  reduction factor of a `t`-bit hint is exactly `2^t` — never more (cycle I),
  and attained (here).  Hints are worth their bits at face value.
* **§2 Average case, not just worst case.**
  `GenericRecovery.sq_sum_cost_ge`: by Cauchy–Schwarz, the *expected* number of
  candidates the adversary must scan (over the induced distribution of hint
  readings) is at least `|S| / 2^t`.  The experiment measured medians equal to
  the class size; this is the theorem behind that observation, and it rules out
  a hint whose typical class is small while a few classes soak up the mass.
* **§3 The trace/square hint is worth `t - 3` bits, exactly.**
  `GenericRecovery.card_natSqFiber` (every fibre of `p ↦ p² mod 2^t` on the odd
  residues has exactly 4 elements) and
  `GenericRecovery.card_image_sqHint` (the hint therefore realises exactly
  `2^{t-3}` values).  A `t`-bit trace hint carries `t-3` usable bits: one bit to
  parity (§3 of cycle I), two bits to the square-root ambiguity.  This is the
  measured `log₂ C_t ≈ 3` deficit, now a theorem.
* **§4 Bridge to DIAL-THRESHOLD.**  `GenericRecovery.worstCost_dialVec_ge`:
  a residue-dial system is a hint of `log₂ (M*/gcd(M*,m))` bits and therefore
  obeys the master bound.  The two negative programmes are one programme.
-/
import Mathlib
import Combinatorics.GenericRecoveryHintTaxonomy
import Combinatorics.DialThresholdNoAmplification

namespace GenericRecovery

open Finset

/-! ## 1.  Sharpness: the block hint attains the master bound exactly -/

theorem div_eq_iff_block (p q y : ℕ) (hq : 0 < q) :
    p / q = y ↔ (y * q ≤ p ∧ p < (y + 1) * q) := by
  constructor
  · rintro rfl
    exact ⟨(Nat.le_div_iff_mul_le hq).mp le_rfl,
      (Nat.div_lt_iff_lt_mul hq).mp (Nat.lt_succ_self _)⟩
  · rintro ⟨h1, h2⟩
    have e1 := (Nat.le_div_iff_mul_le hq).mpr h1
    have e2 := (Nat.div_lt_iff_lt_mul hq).mpr h2
    omega

theorem filter_blockHint (q t y : ℕ) (hq : 0 < q) (hy : y < 2 ^ t) :
    {p ∈ range (q * 2 ^ t) | p / q = y} = Finset.Ico (y * q) ((y + 1) * q) := by
  ext p
  simp only [mem_filter, mem_range, Finset.mem_Ico, div_eq_iff_block p q y hq]
  constructor
  · rintro ⟨_, h2, h3⟩
    exact ⟨h2, h3⟩
  · rintro ⟨h1, h2⟩
    refine ⟨lt_of_lt_of_le h2 ?_, h1, h2⟩
    calc (y + 1) * q ≤ 2 ^ t * q := Nat.mul_le_mul_right _ (by omega)
      _ = q * 2 ^ t := Nat.mul_comm _ _

/-- **Sharpness, fibre side.**  Every class of the block hint has exactly
`q = |S| / 2^t` candidates. -/
theorem card_fiber_blockHint (q t y : ℕ) (hq : 0 < q) (hy : y < 2 ^ t) :
    cost (range (q * 2 ^ t)) (fun p => p / q) y = q := by
  rw [cost, filter_blockHint q t y hq hy, Nat.card_Ico, add_mul, one_mul]
  omega

/-- **Sharpness, image side.**  The block hint really does use all `2^t`
readings, so it is a genuine `t`-bit hint. -/
theorem image_blockHint (q t : ℕ) (hq : 0 < q) :
    (range (q * 2 ^ t)).image (fun p => p / q) = range (2 ^ t) := by
  ext y
  simp only [Finset.mem_image, mem_range]
  constructor
  · rintro ⟨p, hp, rfl⟩
    exact (Nat.div_lt_iff_lt_mul hq).mpr (by rw [Nat.mul_comm]; exact hp)
  · intro hy
    refine ⟨y * q, ?_, Nat.mul_div_cancel _ hq⟩
    calc y * q < 2 ^ t * q := by
          exact Nat.mul_lt_mul_of_lt_of_le hy le_rfl hq
      _ = q * 2 ^ t := Nat.mul_comm _ _

/-- **The reduction factor of a `t`-bit hint is exactly `2^t`.**  The block hint
has `2^t` readings and worst-case recovery cost exactly `|S| / 2^t`, matching the
master bound `worstCost_ge_of_bits` of cycle I. -/
theorem worstCost_blockHint (q t : ℕ) (hq : 0 < q) :
    worstCost (range (q * 2 ^ t)) (fun p => p / q) = q := by
  have hy0 : (0:ℕ) ∈ range (2 ^ t) := mem_range.mpr (Nat.pow_pos (by norm_num))
  refine le_antisymm (Finset.sup_le ?_) ?_
  · intro y hy
    rw [image_blockHint q t hq] at hy
    exact le_of_eq (card_fiber_blockHint q t y hq (mem_range.mp hy))
  · have hmem : (0:ℕ) ∈ (range (q * 2 ^ t)).image (fun p => p / q) := by
      rw [image_blockHint q t hq]; exact hy0
    have := cost_le_worstCost (S := range (q * 2 ^ t)) (h := fun p => p / q) hmem
    rwa [card_fiber_blockHint q t 0 hq (mem_range.mp hy0)] at this

/-! ## 2.  The average class is large too (Cauchy–Schwarz) -/

variable {α β : Type*} [DecidableEq β]

theorem sum_cost_eq_card (S : Finset α) (h : α → β) :
    ∑ y ∈ S.image h, cost S h y = #S := (Finset.card_eq_sum_card_image h S).symm

/-- **Average-case master bound.**  For a `t`-bit hint, the expected size of the
class the adversary lands in (each class weighted by its own probability) is at
least `|S| / 2^t`: `|S|² ≤ 2^t · Σ_y cost(y)²`.  So a hint cannot be typically
sharp and rarely blunt; the information bound holds in the mean, not only in the
worst case. -/
theorem sq_sum_cost_ge {S : Finset α} {h : α → β} {t : ℕ} (hB : #(S.image h) ≤ 2 ^ t) :
    #S * #S ≤ 2 ^ t * ∑ y ∈ S.image h, (cost S h y) ^ 2 := by
  have hCS : (∑ y ∈ S.image h, cost S h y) ^ 2
      ≤ #(S.image h) * ∑ y ∈ S.image h, (cost S h y) ^ 2 := sq_sum_le_card_mul_sum_sq
  rw [sum_cost_eq_card S h, sq] at hCS
  exact hCS.trans (Nat.mul_le_mul_right _ hB)

/-! ## 3.  The trace hint is worth exactly `t - 3` bits -/

/-- A candidate matching an odd square mod `2^t` is itself odd. -/
theorem odd_of_sq_congr {t x u : ℕ} (ht : 1 ≤ t) (hu : u % 2 = 1)
    (h : x ^ 2 % 2 ^ t = u ^ 2 % 2 ^ t) : x % 2 = 1 := by
  have hdvd : (2:ℕ) ∣ 2 ^ t := dvd_pow_self 2 (by omega)
  have h2 : x ^ 2 % 2 = u ^ 2 % 2 := by
    rw [← Nat.mod_mod_of_dvd _ hdvd, ← Nat.mod_mod_of_dvd (u ^ 2) hdvd, h]
  rw [Nat.pow_mod, Nat.pow_mod u] at h2
  rw [hu] at h2
  rcases Nat.mod_two_eq_zero_or_one x with hx | hx
  · rw [hx] at h2; simp at h2
  · exact hx

/-- **Four candidates per reading.**  On the residues mod `2^t` (`t = n+3`), the
square hint `x ↦ x² mod 2^t` has every nonempty fibre of size exactly four:
this is `card_sq_fiber_eq_four` of cycle I, transported to `ℕ`. -/
theorem card_natSqFiber (n u : ℕ) (hu : u % 2 = 1) :
    #{x ∈ range (2 ^ (n + 3)) | x ^ 2 % 2 ^ (n + 3) = u ^ 2 % 2 ^ (n + 3)} = 4 := by
  have huZ : Odd (u : ℤ) := by
    obtain ⟨k, hk⟩ : ∃ k, u = 2 * k + 1 := ⟨u / 2, by omega⟩
    exact ⟨(k : ℤ), by rw [hk]; push_cast; ring⟩
  have hcast : ∀ x : ℕ, (x ^ 2 % 2 ^ (n + 3) = u ^ 2 % 2 ^ (n + 3)) ↔
      ((x : ZMod (2 ^ (n + 3))) ^ 2 = ((u : ℤ) : ZMod (2 ^ (n + 3))) ^ 2) := by
    intro x
    have h := ZMod.natCast_eq_natCast_iff' (x ^ 2) (u ^ 2) (2 ^ (n + 3))
    push_cast at h
    have hu2 : (((u : ℤ)) : ZMod (2 ^ (n + 3))) = ((u : ℕ) : ZMod (2 ^ (n + 3))) := by
      push_cast; ring
    rw [hu2]
    exact h.symm
  rw [← card_sq_fiber_eq_four n u huZ]
  refine Finset.card_nbij (fun x => (x : ZMod (2 ^ (n + 3)))) ?_ ?_ ?_
  · intro x hx
    simp only [coe_filter, Set.mem_setOf_eq, mem_range, mem_univ, true_and] at hx ⊢
    exact (hcast x).mp hx.2
  · intro x hx y hy hxy
    simp only [coe_filter, Set.mem_setOf_eq, mem_range] at hx hy
    have hxy' : ((x : ℕ) : ZMod (2 ^ (n + 3))) = ((y : ℕ) : ZMod (2 ^ (n + 3))) := hxy
    have hx' : (x : ZMod (2 ^ (n + 3))).val = x := ZMod.val_natCast_of_lt hx.1
    have hy' : (y : ZMod (2 ^ (n + 3))).val = y := ZMod.val_natCast_of_lt hy.1
    rw [← hx', ← hy', hxy']
  · intro z hz
    simp only [coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hz
    refine ⟨z.val, ?_, ?_⟩
    · simp only [coe_filter, Set.mem_setOf_eq, mem_range]
      refine ⟨ZMod.val_lt z, ?_⟩
      refine (hcast z.val).mpr ?_
      rwa [ZMod.natCast_val, ZMod.cast_id]
    · simp [ZMod.natCast_val, ZMod.cast_id]

/-- The odd residues mod `2^{n+3}`: the candidate set of the trace hint. -/
def oddResidues (n : ℕ) : Finset ℕ := {x ∈ range (2 ^ (n + 3)) | x % 2 = 1}

theorem card_oddResidues (n : ℕ) : #(oddResidues n) = 2 ^ (n + 2) := by
  have h := card_parity_residues (t := n + 3) (by omega) 1 one_lt_two
  simpa [oddResidues] using h

/-- On the odd residues the square hint still has four-element fibres: all four
square roots are odd. -/
theorem cost_sqHint (n u : ℕ) (hu : u ∈ oddResidues n) :
    cost (oddResidues n) (fun x => x ^ 2 % 2 ^ (n + 3)) (u ^ 2 % 2 ^ (n + 3)) = 4 := by
  have hu' : u % 2 = 1 := (Finset.mem_filter.mp hu).2
  rw [cost, ← card_natSqFiber n u hu']
  congr 1
  ext x
  simp only [oddResidues, Finset.mem_filter, mem_range]
  constructor
  · rintro ⟨⟨h1, _⟩, h3⟩
    exact ⟨h1, h3⟩
  · rintro ⟨h1, h2⟩
    exact ⟨⟨h1, odd_of_sq_congr (by omega) hu' h2⟩, h2⟩

/-- **The `t`-bit trace hint carries only `t-3` bits.**  With `t = n+3`, the
square hint (the content of a trace hint `s = p+q mod 2^t`, after completing the
square) realises exactly `2^{t-3}` distinct readings on the `2^{t-1}` odd
residues.  One bit is lost to parity, two to the square-root ambiguity. -/
theorem card_image_sqHint (n : ℕ) :
    #((oddResidues n).image (fun x => x ^ 2 % 2 ^ (n + 3))) = 2 ^ n := by
  set S := oddResidues n with hS
  set f : ℕ → ℕ := fun x => x ^ 2 % 2 ^ (n + 3) with hf
  have hsum : #S = ∑ y ∈ S.image f, cost S f y := Finset.card_eq_sum_card_image f S
  have hconst : ∀ y ∈ S.image f, cost S f y = 4 := by
    intro y hy
    obtain ⟨u, hu, rfl⟩ := Finset.mem_image.mp hy
    exact cost_sqHint n u hu
  rw [Finset.sum_congr rfl hconst, Finset.sum_const, smul_eq_mul,
    card_oddResidues n] at hsum
  have h4 : 2 ^ (n + 2) = 2 ^ n * 4 := by ring
  omega

/-- Worst-case recovery from the trace hint on the odd residues: four
candidates per reading, i.e. `C_t = 4` exactly. -/
theorem worstCost_sqHint (n : ℕ) :
    worstCost (oddResidues n) (fun x => x ^ 2 % 2 ^ (n + 3)) = 4 := by
  have hne : (oddResidues n).Nonempty := by
    refine ⟨1, ?_⟩
    simp only [oddResidues, Finset.mem_filter, mem_range]
    exact ⟨Nat.one_lt_two_pow (by omega), by trivial⟩
  refine le_antisymm (Finset.sup_le ?_) ?_
  · intro y hy
    obtain ⟨u, hu, rfl⟩ := Finset.mem_image.mp hy
    exact le_of_eq (cost_sqHint n u hu)
  · obtain ⟨u, hu⟩ := hne
    have hmem : (u ^ 2 % 2 ^ (n + 3)) ∈ (oddResidues n).image (fun x => x ^ 2 % 2 ^ (n + 3)) :=
      Finset.mem_image_of_mem _ hu
    have h := cost_le_worstCost (S := oddResidues n)
      (h := fun x => x ^ 2 % 2 ^ (n + 3)) hmem
    rwa [cost_sqHint n u hu] at h

/-! ## 4.  Bridge: residue dials are hints, and obey the master bound -/

open DialThreshold in
/-- **DIAL-THRESHOLD is an instance of GENERIC-RECOVERY.**  A dial system read on
a candidate set inside one hint class mod `m` is a hint with at most
`M*/gcd(M*,m)` readings; hence the master bound applies verbatim and the dials
leave at least `|Ω| · gcd(M*,m) / M*` candidates. -/
theorem worstCost_dialVec_ge {K : ℕ} (Ds : Fin K → Dial) (Ω : Finset ℕ) {m r : ℕ} (hm : 0 < m)
    (hΩ : ∀ p ∈ Ω, p % m = r % m) :
    #Ω / (condLcm Ds / Nat.gcd (condLcm Ds) m) ≤ worstCost Ω (dialVec Ds) :=
  worstCost_ge_of_card_image_le (card_image_dialVec_le Ds Ω hm hΩ)

end GenericRecovery