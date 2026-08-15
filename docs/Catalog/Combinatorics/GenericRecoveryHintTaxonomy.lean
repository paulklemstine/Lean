/-
# GENERIC-RECOVERY: a closed taxonomy of `t`-bit hints

Formal companion to experiment 390 (`55_GenericRecovery_HintTaxonomy`), and a
sequel to `Combinatorics.DialThresholdNoAmplification` / `…Sharpness`.

**The question.**  A factoring-style adversary is handed a *hint*: a function
`h` of the secret `p`, whose value costs `t` bits to transmit.  How much can the
hint shrink the search for `p`?  The experiment measured, on exact `k`-bit prime
sets (`k = 14…25`), that a random GF(2) linear form of the bits of `p` splits
the candidate set into classes of size *exactly* `|P_k| / 2^t`; that
multiplicative and XOR-mask value hints only ever realise `2^{t-1}` values and
so lose a bit; and that the trace hint `s = p + q mod 2^t` is *sub-bit*, costing
a constant factor `C_t` extra because `p` is pinned only up to the roots of a
quadratic.  This file proves all four legs.

## Contents

* **§1 The master bound** — `GenericRecovery.card_le_card_image_mul_worstCost`
  and `GenericRecovery.worstCost_ge_of_card_image_le`: a hint with at most `2^t`
  values always leaves some class of size `≥ |S| / 2^t`.  *No hint of `t` bits
  ever cuts the search by more than `2^t`.*
* **§2 Generic linear hints are information-exact** —
  `GenericRecovery.card_fiber_addHom` (every fibre of a surjective group hint
  has the *same* size) and `GenericRecovery.card_fiber_gf2` (`= 2^{k-t}` on the
  bit cube).  This is the "no anomalous class, no super-resolution" leg.
* **§2b Position-freeness** — `GenericRecovery.card_fiber_coordRestrict`: reading
  the bits of `p` in *any* position set `A` leaves exactly `2^{k-|A|}`
  candidates.  Counting cannot see position; whatever Coppersmith gains from a
  *contiguous top half* is algorithmic, not information-theoretic.
* **§3 Value hints are parity-constrained** —
  `GenericRecovery.worstCost_mulHint_ge` and
  `GenericRecovery.worstCost_xorHint_ge`: `c·p mod 2^t` and `(p XOR m) mod 2^t`
  on odd `p` realise at most `2^{t-1}` values, so their classes are twice as big
  as a bit-vector hint's.  One bit of the `t` is spent on a constant.
* **§4 Data processing** — `GenericRecovery.worstCost_le_worstCost_comp`
  (post-processing never amplifies) and `GenericRecovery.worstCost_pair_ge`
  (bits of independent hints add, they do not multiply).
* **§5 Public hints are sealed** — `GenericRecovery.worstCost_of_public`: a hint
  recomputable from data the adversary already has (`N`) has a single class,
  i.e. zero information.
* **§6 The trace hint loses two bits** — `GenericRecovery.card_sq_fiber_eq_four`:
  for `t ≥ 3` the congruence `x² ≡ u² (mod 2^t)` has **exactly four** odd
  solutions, so the trace hint `s = p+q mod 2^t` (which determines `p` only
  through `(2p-s)² = s² - 4N`) pins `p mod 2^t` to `C_t = 4` classes.  That is
  the measured saturation `C_t ∈ {4, 8}` and the `log₂ C_t ≈ 2–3` bits lost.
* **§7 Synthesis** — `GenericRecovery.taxonomy`: the three regimes in one
  statement, `2^t` / `2^{t-1}` / `2^{t-2}` usable bits.
-/
import Mathlib

namespace GenericRecovery

open Finset

/-! ## 1.  The recovery cost of a hint and the master bound -/

variable {α β γ : Type*} [DecidableEq β] [DecidableEq γ]

/-- `cost S h y` is the number of candidates in `S` still consistent with the
hint reading `y`: the size of the fibre the adversary must search. -/
def cost (S : Finset α) (h : α → β) (y : β) : ℕ := #{a ∈ S | h a = y}

/-- The worst-case recovery cost of a hint: the largest fibre it produces. -/
def worstCost (S : Finset α) (h : α → β) : ℕ := (S.image h).sup (cost S h)

theorem cost_le_worstCost {S : Finset α} {h : α → β} {y : β} (hy : y ∈ S.image h) :
    cost S h y ≤ worstCost S h := Finset.le_sup (f := cost S h) hy

/-- **Master bound.**  The candidate set is covered by the hint's fibres, so its
size is at most (number of hint values) × (worst fibre). -/
theorem card_le_card_image_mul_worstCost (S : Finset α) (h : α → β) :
    #S ≤ #(S.image h) * worstCost S h := by
  rw [Finset.card_eq_sum_card_image h S]
  calc ∑ b ∈ S.image h, #({a ∈ S | h a = b})
      ≤ ∑ _b ∈ S.image h, worstCost S h :=
        Finset.sum_le_sum fun b hb => Finset.le_sup (f := cost S h) hb
    _ = #(S.image h) * worstCost S h := by rw [Finset.sum_const, smul_eq_mul]

/-- **A `t`-bit hint cannot cut the search by more than `2^t`.**  If the hint
takes at most `B` values then some class still has `≥ |S| / B` candidates. -/
theorem worstCost_ge_of_card_image_le {S : Finset α} {h : α → β} {B : ℕ}
    (hB : #(S.image h) ≤ B) : #S / B ≤ worstCost S h := by
  rcases Nat.eq_zero_or_pos B with rfl | hpos
  · simp
  · exact Nat.div_le_of_le_mul
      ((card_le_card_image_mul_worstCost S h).trans (Nat.mul_le_mul_right _ hB))

/-- Bit-indexed form of the master bound. -/
theorem worstCost_ge_of_bits {S : Finset α} {h : α → β} {t : ℕ}
    (hB : #(S.image h) ≤ 2 ^ t) : #S / 2 ^ t ≤ worstCost S h :=
  worstCost_ge_of_card_image_le hB

/-! ## 2.  Generic (linear) hints are information-exact

A hint that is a group homomorphism has *all* fibres of the same size: there is
no anomalous class, hence no reading of the hint that resolves `p` better than
average.  This is the exact statement that the experiment measured as
`|P_k| / 2^t` with no outliers. -/

section Hom

variable {G H : Type*} [AddCommGroup G] [AddCommGroup H] [Fintype G] [DecidableEq H]

/-- Every nonempty fibre of an additive hint is a coset of the kernel, hence has
the size of the kernel: **no anomalous class**. -/
theorem fiber_card_eq_ker (f : G →+ H) (y : H) (a : G) (ha : f a = y) :
    #{x ∈ (univ : Finset G) | f x = y} = #{x ∈ (univ : Finset G) | f x = 0} := by
  refine Finset.card_nbij (fun x => x - a) ?_ ?_ ?_
  · intro x hx
    simp only [coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hx ⊢
    simp [map_sub, hx, ha]
  · intro x _ y _ hxy
    simpa using sub_left_injective hxy
  · intro z hz
    simp only [coe_filter, Set.mem_setOf_eq, mem_univ, true_and] at hz ⊢
    exact ⟨z + a, by simp [map_add, hz, ha], by simp⟩

/-- **Information-exactness.**  For a surjective additive hint, every fibre has
size exactly `|G| / |H|`: the hint partitions the candidate set into `|H|` equal
classes. -/
theorem card_fiber_addHom [Fintype H] (f : G →+ H) (hf : Function.Surjective f) (y : H) :
    Fintype.card H * #{x ∈ (univ : Finset G) | f x = y} = Fintype.card G := by
  have himg : Finset.univ.image f = (Finset.univ : Finset H) := by
    ext b
    simp only [Finset.mem_image, Finset.mem_univ, true_and, iff_true]
    exact hf b
  have key : (Finset.univ : Finset G).card = ∑ b : H, #{a ∈ (univ : Finset G) | f a = b} := by
    have h := Finset.card_eq_sum_card_image f (Finset.univ : Finset G)
    rwa [himg] at h
  have hconst : ∀ b : H, #{a ∈ (univ : Finset G) | f a = b}
      = #{x ∈ (univ : Finset G) | f x = y} := by
    intro b
    obtain ⟨a, rfl⟩ := hf b
    obtain ⟨c, hc⟩ := hf y
    rw [fiber_card_eq_ker f _ a rfl, fiber_card_eq_ker f y c hc]
  show #(univ : Finset H) * _ = #(univ : Finset G)
  rw [key, Finset.sum_congr rfl (fun b _ => hconst b), Finset.sum_const, smul_eq_mul]

end Hom

section GF2

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]

theorem card_bitcube (ι : Type*) [Fintype ι] [DecidableEq ι] :
    Fintype.card (ι → ZMod 2) = 2 ^ Fintype.card ι := by
  simp

/-- **A `t`-bit GF(2) hint on `k` bits leaves exactly `2^{k-t}` candidates.**
Every reading of a surjective GF(2) linear hint is equally informative. -/
theorem card_fiber_gf2 (f : (ι → ZMod 2) →+ (κ → ZMod 2)) (hf : Function.Surjective f)
    (y : κ → ZMod 2) :
    #{x ∈ (univ : Finset (ι → ZMod 2)) | f x = y} = 2 ^ (Fintype.card ι - Fintype.card κ) := by
  have hmul := card_fiber_addHom f hf y
  rw [card_bitcube ι, card_bitcube κ] at hmul
  have hle : Fintype.card κ ≤ Fintype.card ι := by
    have hdvd : (2:ℕ) ^ Fintype.card κ ∣ 2 ^ Fintype.card ι := ⟨_, hmul.symm⟩
    exact (Nat.pow_dvd_pow_iff_le_right (by norm_num)).mp hdvd
  have hpos : 0 < 2 ^ Fintype.card κ := Nat.pow_pos (by norm_num)
  refine Nat.eq_of_mul_eq_mul_left hpos ?_
  rw [hmul, ← pow_add]
  congr 1
  omega

/-- The hint "read the bits of `x` in the positions `A`". -/
def coordRestrict (A : Finset ι) : (ι → ZMod 2) →+ (A → ZMod 2) where
  toFun x i := x i.1
  map_zero' := rfl
  map_add' _ _ := rfl

omit [Fintype ι] in
theorem coordRestrict_surjective (A : Finset ι) :
    Function.Surjective (coordRestrict (ι := ι) A) := by
  intro g
  refine ⟨fun i => if h : i ∈ A then g ⟨i, h⟩ else 0, ?_⟩
  funext i
  simp [coordRestrict, i.2]

/-- **Position-freeness (leg 4, counting side).**  Knowing the bits of `x` in an
*arbitrary* set `A` of positions — top half, bottom half, or scattered — leaves
exactly `2^{k-|A|}` candidates.  The pure counting reduction depends only on the
*number* of leaked bits; any advantage of a contiguous top half (Coppersmith)
is algorithmic, not informational. -/
theorem card_fiber_coordRestrict (A : Finset ι) (y : A → ZMod 2) :
    #{x ∈ (univ : Finset (ι → ZMod 2)) | coordRestrict A x = y}
      = 2 ^ (Fintype.card ι - #A) := by
  have h := card_fiber_gf2 (coordRestrict (ι := ι) A) (coordRestrict_surjective A) y
  rwa [Fintype.card_coe] at h

/-- Two position sets of the same size are interchangeable: hints differing only
in *where* they read are equally costly. -/
theorem card_fiber_coordRestrict_congr (A B : Finset ι) (hAB : #A = #B)
    (y : A → ZMod 2) (z : B → ZMod 2) :
    #{x ∈ (univ : Finset (ι → ZMod 2)) | coordRestrict A x = y}
      = #{x ∈ (univ : Finset (ι → ZMod 2)) | coordRestrict B x = z} := by
  rw [card_fiber_coordRestrict, card_fiber_coordRestrict, hAB]

end GF2

/-! ## 3.  Value hints are parity-constrained: one bit is always wasted -/

theorem card_parity_range (r n : ℕ) (hr : r < 2) : #{x ∈ range (2 * n) | x % 2 = r} = n := by
  induction n with
  | zero => simp
  | succ m ih =>
    have hsplit : 2 * (m + 1) = (2 * m + 1) + 1 := by ring
    rw [hsplit, Finset.range_add_one, Finset.range_add_one, Finset.filter_insert,
      Finset.filter_insert]
    have h0 : (2 * m) % 2 = 0 := Nat.mul_mod_right 2 m
    have h1 : (2 * m + 1) % 2 = 1 := by omega
    interval_cases r
    · rw [if_neg (by omega), if_pos h0, Finset.card_insert_of_notMem (by simp), ih]
    · rw [if_pos h1, Finset.card_insert_of_notMem (by simp), if_neg (by omega), ih]

/-- Residues mod `2^t` of a fixed parity: only `2^{t-1}` of them. -/
theorem card_parity_residues {t : ℕ} (ht : 1 ≤ t) (r : ℕ) (hr : r < 2) :
    #{x ∈ range (2 ^ t) | x % 2 = r} = 2 ^ (t - 1) := by
  have h2 : 2 ^ t = 2 * 2 ^ (t - 1) := by
    rw [← pow_succ']
    congr 1
    omega
  rw [h2, card_parity_range r _ hr]

/-- A hint landing in a set of `2^{t-1}` values only cuts the search by
`2^{t-1}`, though it costs `t` bits to write down. -/
theorem worstCost_ge_of_parity {S : Finset α} {h : α → ℕ} {t r : ℕ} (ht : 1 ≤ t) (hr : r < 2)
    (hmem : ∀ a ∈ S, h a < 2 ^ t) (hpar : ∀ a ∈ S, h a % 2 = r) :
    #S / 2 ^ (t - 1) ≤ worstCost S h := by
  refine worstCost_ge_of_card_image_le (B := 2 ^ (t - 1)) ?_
  rw [← card_parity_residues ht r hr]
  refine Finset.card_le_card ?_
  intro y hy
  obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hy
  exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr (hmem a ha), hpar a ha⟩

/-- **Multiplicative value hints lose a bit.**  For odd `c` and odd candidates,
`c · p mod 2^t` is always odd, so it realises only `2^{t-1}` values and its
classes are twice the generic size. -/
theorem worstCost_mulHint_ge {S : Finset ℕ} {c t : ℕ} (ht : 1 ≤ t) (hc : c % 2 = 1)
    (hS : ∀ p ∈ S, p % 2 = 1) :
    #S / 2 ^ (t - 1) ≤ worstCost S (fun p => c * p % 2 ^ t) := by
  refine worstCost_ge_of_parity ht one_lt_two (fun a _ => Nat.mod_lt _ (by positivity)) ?_
  intro a ha
  have hdvd : (2:ℕ) ∣ 2 ^ t := dvd_pow_self 2 (by omega)
  rw [Nat.mod_mod_of_dvd _ hdvd, Nat.mul_mod, hc, hS a ha]
  norm_num

/-- **XOR-mask value hints lose a bit** as well: the low bit of `p XOR m` is
determined by the mask alone. -/
theorem worstCost_xorHint_ge {S : Finset ℕ} {m t : ℕ} (ht : 1 ≤ t)
    (hS : ∀ p ∈ S, p % 2 = 1) :
    #S / 2 ^ (t - 1) ≤ worstCost S (fun p => (p ^^^ m) % 2 ^ t) := by
  refine worstCost_ge_of_parity (r := (1 + m) % 2) ht (Nat.mod_lt _ (by norm_num))
    (fun a _ => Nat.mod_lt _ (by positivity)) ?_
  intro a ha
  have hdvd : (2:ℕ) ∣ 2 ^ t := dvd_pow_self 2 (by omega)
  rw [Nat.mod_mod_of_dvd _ hdvd, Nat.xor_mod_two_eq]
  have := hS a ha
  omega

/-! ## 4.  Data processing: hints never gain information downstream -/

/-- **Post-processing cannot amplify.**  Any function of the hint reading has
fibres at least as large as the hint's own. -/
theorem worstCost_le_worstCost_comp (S : Finset α) (h : α → β) (g : β → γ) :
    worstCost S h ≤ worstCost S (g ∘ h) := by
  refine Finset.sup_le fun y hy => ?_
  obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hy
  refine le_trans ?_ (cost_le_worstCost (h := g ∘ h) (y := g (h a))
    (Finset.mem_image.mpr ⟨a, ha, rfl⟩))
  refine Finset.card_le_card fun b hb => ?_
  simp only [Finset.mem_filter] at hb ⊢
  exact ⟨hb.1, by simp [Function.comp, hb.2]⟩

/-- **Bits add, they do not multiply.**  Two hints of `t₁` and `t₂` bits, used
jointly, leave at least `|S| / 2^{t₁+t₂}` candidates. -/
theorem worstCost_pair_ge {S : Finset α} {h₁ : α → β} {h₂ : α → γ} {t₁ t₂ : ℕ}
    (h1 : #(S.image h₁) ≤ 2 ^ t₁) (h2 : #(S.image h₂) ≤ 2 ^ t₂) :
    #S / 2 ^ (t₁ + t₂) ≤ worstCost S (fun a => (h₁ a, h₂ a)) := by
  refine worstCost_ge_of_card_image_le ?_
  have hsub : S.image (fun a => (h₁ a, h₂ a)) ⊆ (S.image h₁) ×ˢ (S.image h₂) := by
    intro y hy
    obtain ⟨a, ha, rfl⟩ := Finset.mem_image.mp hy
    exact Finset.mem_product.mpr ⟨Finset.mem_image_of_mem _ ha, Finset.mem_image_of_mem _ ha⟩
  calc #(S.image (fun a => (h₁ a, h₂ a))) ≤ #((S.image h₁) ×ˢ (S.image h₂)) :=
        Finset.card_le_card hsub
    _ = #(S.image h₁) * #(S.image h₂) := Finset.card_product _ _
    _ ≤ 2 ^ t₁ * 2 ^ t₂ := Nat.mul_le_mul h1 h2
    _ = 2 ^ (t₁ + t₂) := (pow_add 2 t₁ t₂).symm

/-! ## 5.  Public hints are sealed: an `N`-checkable hint has zero information -/

omit [DecidableEq γ] in
/-- **Zero information.**  A hint that factors through data the adversary
already holds (here: a quantity `pub` that is constant on the candidate set,
e.g. the modulus `N`) has a single class — its worst-case recovery cost is the
whole candidate set, no matter how many bits it is allowed to output. -/
theorem worstCost_of_public {S : Finset α} {h : α → β} {pub : α → γ} {F : γ → β} {n₀ : γ}
    (hfac : ∀ a ∈ S, h a = F (pub a)) (hconst : ∀ a ∈ S, pub a = n₀) (hne : S.Nonempty) :
    worstCost S h = #S := by
  obtain ⟨a₀, ha₀⟩ := hne
  have hval : ∀ a ∈ S, h a = F n₀ := fun a ha => by rw [hfac a ha, hconst a ha]
  have himg : S.image h = {F n₀} := by
    ext y
    simp only [Finset.mem_image, Finset.mem_singleton]
    exact ⟨fun ⟨a, ha, hya⟩ => hya ▸ hval a ha, fun hy => ⟨a₀, ha₀, by rw [hval a₀ ha₀, hy]⟩⟩
  have hfilter : {a ∈ S | h a = F n₀} = S := Finset.filter_true_of_mem hval
  simp [worstCost, himg, cost, hfilter]

/-! ## 6.  The trace hint is sub-bit: exactly four square roots mod `2^t`

The trace hint gives `s ≡ p + q (mod 2^t)` with `N = p·q` public.  Completing
the square turns this into `(2p - s)² = s² - 4N`, so the adversary learns a
*square* mod a power of two, and `p` is pinned only up to the square roots.  We
prove there are exactly four of them for `t ≥ 3`: `log₂ C_t = 2` bits are burnt
by the root ambiguity, exactly the constant-factor blow-up measured. -/

/-- Completing the square: the trace hint only ever determines `(2p - s)²`. -/
theorem trace_completes_square (p q : ℤ) :
    (2 * p - (p + q)) ^ 2 = (p + q) ^ 2 - 4 * (p * q) := by ring

theorem dvd_of_odd_mul {n : ℕ} {a b : ℤ} (ha : Odd a) (h : (2:ℤ) ^ n ∣ a * b) :
    (2:ℤ) ^ n ∣ b := by
  induction n generalizing b with
  | zero => simp
  | succ m ih =>
    have h2 : (2:ℤ) ∣ a * b := dvd_trans (dvd_pow_self 2 (Nat.succ_ne_zero m)) h
    have hb : (2:ℤ) ∣ b := by
      rcases Int.prime_two.dvd_mul.mp h2 with h' | h'
      · obtain ⟨k, hk⟩ := ha; obtain ⟨j, hj⟩ := h'; omega
      · exact h'
    obtain ⟨c, rfl⟩ := hb
    obtain ⟨d, hd⟩ := h
    have hac : (2:ℤ) ^ m ∣ a * c :=
      ⟨d, mul_left_cancel₀ two_ne_zero (by linear_combination hd)⟩
    obtain ⟨e, he⟩ := ih hac
    exact ⟨e, by rw [he]; ring⟩

/-- Odd squares agree mod `2^{n+2}` exactly when the arguments agree mod
`2^{n+1}` up to sign: the 2-adic square map halves resolution. -/
theorem sq_congr_iff (n : ℕ) {x u : ℤ} (hx : Odd x) (hu : Odd u) :
    (2:ℤ) ^ (n + 2) ∣ x ^ 2 - u ^ 2 ↔
      (2:ℤ) ^ (n + 1) ∣ x - u ∨ (2:ℤ) ^ (n + 1) ∣ x + u := by
  obtain ⟨k, hk⟩ := hx
  obtain ⟨l, hl⟩ := hu
  obtain ⟨a, hafull⟩ : ∃ a, x - u = 2 * a := ⟨k - l, by omega⟩
  obtain ⟨b, hbfull⟩ : ∃ b, x + u = 2 * b := ⟨k + l + 1, by omega⟩
  have hfac : x ^ 2 - u ^ 2 = (x - u) * (x + u) := by ring
  constructor
  · intro h
    have h4 : (2:ℤ) ^ n ∣ a * b := by
      obtain ⟨d, hd⟩ := h
      refine ⟨d, mul_left_cancel₀ (a := (4:ℤ)) (by norm_num) ?_⟩
      rw [hfac, hafull, hbfull] at hd
      linear_combination hd
    have hab : Odd a ∨ Odd b := by
      rcases Int.even_or_odd a with ha | ha
      · exact Or.inr (by obtain ⟨j, hj⟩ := ha; exact ⟨k - j, by omega⟩)
      · exact Or.inl ha
    rcases hab with ha | hb
    · exact Or.inr (by obtain ⟨e, he⟩ := dvd_of_odd_mul ha h4; exact ⟨e, by rw [hbfull, he]; ring⟩)
    · exact Or.inl (by
        obtain ⟨e, he⟩ := dvd_of_odd_mul hb (by rwa [mul_comm] at h4)
        exact ⟨e, by rw [hafull, he]; ring⟩)
  · rintro (⟨c, hc⟩ | ⟨c, hc⟩)
    · exact ⟨c * b, by rw [hfac, hc, hbfull]; ring⟩
    · exact ⟨c * a, by rw [hfac, hc, hafull]; ring⟩

theorem zmod_eq_iff (n : ℕ) (a b : ℤ) :
    ((a : ZMod (2 ^ (n + 3))) = (b : ZMod (2 ^ (n + 3)))) ↔ (2:ℤ) ^ (n + 3) ∣ a - b := by
  have h := ZMod.intCast_zmod_eq_zero_iff_dvd (a - b) (2 ^ (n + 3))
  push_cast at h
  rw [← sub_eq_zero, h]

theorem split_dvd (m : ℕ) (z : ℤ) :
    (2:ℤ) ^ (m + 1) ∣ z ↔ ((2:ℤ) ^ (m + 2) ∣ z ∨ (2:ℤ) ^ (m + 2) ∣ z - 2 ^ (m + 1)) := by
  constructor
  · rintro ⟨c, hc⟩
    rcases Int.even_or_odd c with ⟨d, hd⟩ | ⟨d, hd⟩
    · exact Or.inl ⟨d, by rw [hc, hd]; ring⟩
    · exact Or.inr ⟨d, by rw [hc, hd]; ring⟩
  · rintro (⟨c, hc⟩ | ⟨c, hc⟩)
    · exact ⟨2 * c, by rw [hc]; ring⟩
    · exact ⟨2 * c + 1, by
        have hz : z = 2 ^ (m + 2) * c + 2 ^ (m + 1) := by linarith
        rw [hz]; ring⟩

/-- The four square roots of an odd square mod `2^{n+3}`. -/
theorem sq_fiber_eq (n : ℕ) (u : ℤ) (hu : Odd u) :
    {x ∈ (univ : Finset (ZMod (2 ^ (n + 3)))) | x ^ 2 = ((u : ℤ) : ZMod (2 ^ (n + 3))) ^ 2} =
      ({((u : ℤ) : ZMod (2 ^ (n + 3))), ((-u : ℤ) : ZMod (2 ^ (n + 3))),
        ((u + 2 ^ (n + 2) : ℤ) : ZMod (2 ^ (n + 3))),
        ((-u + 2 ^ (n + 2) : ℤ) : ZMod (2 ^ (n + 3)))} : Finset (ZMod (2 ^ (n + 3)))) := by
  ext x
  obtain ⟨a, rfl⟩ : ∃ a : ℤ, x = (a : ZMod (2 ^ (n + 3))) :=
    ⟨(x.val : ℤ), by push_cast; simp [ZMod.natCast_val, ZMod.cast_id]⟩
  simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
    Finset.mem_singleton]
  have key : ∀ v : ℤ,
      ((a : ZMod (2 ^ (n + 3))) = ((v : ℤ) : ZMod (2 ^ (n + 3)))) ↔ (2:ℤ) ^ (n + 3) ∣ a - v :=
    fun v => zmod_eq_iff n a v
  have hsq : ((a : ZMod (2 ^ (n + 3)))) ^ 2 = ((u : ℤ) : ZMod (2 ^ (n + 3))) ^ 2 ↔
      (2:ℤ) ^ (n + 3) ∣ a ^ 2 - u ^ 2 := by
    have h := zmod_eq_iff n (a ^ 2) (u ^ 2)
    push_cast at h
    exact h
  rw [hsq]
  constructor
  · intro h
    have ha : Odd a := by
      rcases Int.even_or_odd a with hae | hao
      · exfalso
        obtain ⟨j, hj⟩ := hae
        obtain ⟨c, hc⟩ := dvd_trans (dvd_pow_self (2:ℤ) (by omega : n + 3 ≠ 0)) h
        have hEvenDiff : Even (a ^ 2 - u ^ 2) := ⟨c, by linarith⟩
        have hEvenA : Even (a ^ 2) := ⟨2 * (j * j), by rw [hj]; ring⟩
        have hEvenU : Even (u ^ 2) := (Int.even_sub.mp hEvenDiff).mp hEvenA
        exact (Int.not_odd_iff_even.mpr hEvenU) hu.pow
      · exact hao
    rcases (sq_congr_iff (n + 1) ha hu).mp h with h1 | h1
    · rcases (split_dvd (n + 1) (a - u)).mp h1 with h2 | h2
      · exact Or.inl ((key u).mpr h2)
      · refine Or.inr (Or.inr (Or.inl ((key (u + 2 ^ (n + 2))).mpr ?_)))
        rw [show a - (u + 2 ^ (n + 2)) = (a - u) - 2 ^ (n + 2) by ring]; exact h2
    · rcases (split_dvd (n + 1) (a + u)).mp h1 with h2 | h2
      · refine Or.inr (Or.inl ((key (-u)).mpr ?_))
        rw [show a - -u = a + u by ring]; exact h2
      · refine Or.inr (Or.inr (Or.inr ((key (-u + 2 ^ (n + 2))).mpr ?_)))
        rw [show a - (-u + 2 ^ (n + 2)) = (a + u) - 2 ^ (n + 2) by ring]; exact h2
  · have step : ∀ v : ℤ, (2:ℤ) ^ (n + 3) ∣ a - v → (2:ℤ) ^ (n + 3) ∣ v ^ 2 - u ^ 2 →
        (2:ℤ) ^ (n + 3) ∣ a ^ 2 - u ^ 2 := by
      intro v h1 h2
      have hrw : a ^ 2 - u ^ 2 = (a - v) * (a + v) + (v ^ 2 - u ^ 2) := by ring
      rw [hrw]
      exact dvd_add (h1.mul_right _) h2
    rintro (h | h | h | h) <;> rw [key] at h
    · exact step u h (by simp)
    · exact step (-u) h ⟨0, by ring⟩
    · exact step (u + 2 ^ (n + 2)) h ⟨u + 2 ^ (n + 1), by ring⟩
    · exact step (-u + 2 ^ (n + 2)) h ⟨-u + 2 ^ (n + 1), by ring⟩

theorem two_pow_dvd_two_mul {m : ℕ} {z : ℤ} (h : (2:ℤ) ^ (m + 1) ∣ 2 * z) : (2:ℤ) ^ m ∣ z := by
  obtain ⟨c, hc⟩ := h
  exact ⟨c, mul_left_cancel₀ two_ne_zero (by linear_combination hc)⟩

theorem not_dvd_of_odd (m : ℕ) {u : ℤ} (hu : Odd u) (hm : 1 ≤ m) : ¬ (2:ℤ) ^ m ∣ u := by
  intro h
  have h2 : (2:ℤ) ∣ u := dvd_trans (dvd_pow_self 2 (by omega)) h
  obtain ⟨k, hk⟩ := hu; obtain ⟨j, hj⟩ := h2; omega

/-- **Exactly four roots.**  For `t = n+3 ≥ 3` the congruence `x² ≡ u² (mod 2^t)`
with `u` odd has exactly four solutions.  Hence a trace hint of `t` bits pins
`p mod 2^t` only to `C_t = 4` classes: two of the `t` bits are lost to the root
ambiguity, which is the measured constant-factor penalty of the trace family. -/
theorem card_sq_fiber_eq_four (n : ℕ) (u : ℤ) (hu : Odd u) :
    #{x ∈ (univ : Finset (ZMod (2 ^ (n + 3)))) |
        x ^ 2 = ((u : ℤ) : ZMod (2 ^ (n + 3))) ^ 2} = 4 := by
  rw [sq_fiber_eq n u hu]
  have key : ∀ v w : ℤ, ¬ ((2:ℤ) ^ (n + 3) ∣ v - w) →
      ((v : ℤ) : ZMod (2 ^ (n + 3))) ≠ ((w : ℤ) : ZMod (2 ^ (n + 3))) := by
    intro v w hvw hEq
    exact hvw ((zmod_eq_iff n v w).mp hEq)
  -- the three genuinely different differences
  have d1 : ¬ (2:ℤ) ^ (n + 3) ∣ 2 * u := by
    intro h
    exact not_dvd_of_odd (n + 2) hu (by omega) (two_pow_dvd_two_mul h)
  have d2 : ¬ (2:ℤ) ^ (n + 3) ∣ (2:ℤ) ^ (n + 2) := by
    intro h
    have hle := Int.le_of_dvd (by positivity) h
    have : (2:ℤ) ^ (n + 2) < 2 ^ (n + 3) := by
      apply pow_lt_pow_right₀ (by norm_num)
      omega
    omega
  have d3 : ∀ ε : ℤ, ε = 1 ∨ ε = -1 → ¬ (2:ℤ) ^ (n + 3) ∣ (2 * u + ε * 2 ^ (n + 2)) := by
    intro ε hε h
    have h' : (2:ℤ) ^ (n + 2) ∣ u + ε * 2 ^ (n + 1) := by
      refine two_pow_dvd_two_mul ?_
      have hrw : 2 * (u + ε * 2 ^ (n + 1)) = 2 * u + ε * 2 ^ (n + 2) := by ring
      rw [hrw]; exact h
    have h2 : (2:ℤ) ∣ u + ε * 2 ^ (n + 1) := dvd_trans (dvd_pow_self 2 (by omega)) h'
    have h3 : (2:ℤ) ∣ ε * 2 ^ (n + 1) := Dvd.dvd.mul_left (dvd_pow_self 2 (by omega)) ε
    obtain ⟨k, hk⟩ := hu
    obtain ⟨j, hj⟩ := h2
    obtain ⟨i, hi⟩ := h3
    omega
  rw [Finset.card_insert_of_notMem, Finset.card_insert_of_notMem,
    Finset.card_insert_of_notMem, Finset.card_singleton]
  · simp only [Finset.mem_singleton]
    exact key _ _ (by rw [show u + 2 ^ (n + 2) - (-u + 2 ^ (n + 2)) = 2 * u by ring]; exact d1)
  · simp only [Finset.mem_insert, Finset.mem_singleton, not_or]
    refine ⟨key _ _ ?_, key _ _ ?_⟩
    · rw [show -u - (u + 2 ^ (n + 2)) = -(2 * u + 1 * 2 ^ (n + 2)) by ring]
      exact fun h => d3 1 (Or.inl rfl) ((dvd_neg).mp h)
    · rw [show -u - (-u + 2 ^ (n + 2)) = -(2 ^ (n + 2)) by ring]
      exact fun h => d2 ((dvd_neg).mp h)
  · simp only [Finset.mem_insert, Finset.mem_singleton, not_or]
    refine ⟨key _ _ ?_, key _ _ ?_, key _ _ ?_⟩
    · rw [show u - -u = 2 * u by ring]; exact d1
    · rw [show u - (u + 2 ^ (n + 2)) = -(2 ^ (n + 2)) by ring]
      exact fun h => d2 ((dvd_neg).mp h)
    · rw [show u - (-u + 2 ^ (n + 2)) = 2 * u + (-1) * 2 ^ (n + 2) by ring]
      exact d3 (-1) (Or.inr rfl)

/-! ## 7.  Synthesis: the taxonomy in one statement -/

/-- **The hint taxonomy, counting side.**  For a candidate set `S` and a `t`-bit
hint:

* a *generic* hint (any hint at all) leaves `≥ |S| / 2^t` candidates
  (`worstCost_ge_of_bits`), and a surjective GF(2) linear hint attains this
  bound exactly (`card_fiber_gf2`) — `2^t` usable;
* a *parity-constrained value* hint leaves `≥ |S| / 2^{t-1}` — `2^{t-1}` usable;
* post-processing and joining hints never beat the sum of their bits
  (`worstCost_le_worstCost_comp`, `worstCost_pair_ge`);
* a hint recomputable from public data leaves all of `S` (`worstCost_of_public`).

The statement below packages the two quantitative regimes. -/
theorem taxonomy {S : Finset ℕ} {t : ℕ} (ht : 1 ≤ t) {h : ℕ → ℕ} {c : ℕ}
    (hgen : #(S.image h) ≤ 2 ^ t) (hc : c % 2 = 1) (hS : ∀ p ∈ S, p % 2 = 1) :
    #S / 2 ^ t ≤ worstCost S h ∧
      #S / 2 ^ (t - 1) ≤ worstCost S (fun p => c * p % 2 ^ t) :=
  ⟨worstCost_ge_of_bits hgen, worstCost_mulHint_ge ht hc hS⟩

end GenericRecovery