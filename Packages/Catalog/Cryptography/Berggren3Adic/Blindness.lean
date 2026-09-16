import Mathlib
import Cryptography.Berggren3Adic.ParentLaw

/-!
# Adic blindness of the metric layer (BERGGREN-3ADIC, part III)

Part I showed that the 3-adic *skeleton* of the N-node (which coordinate is divisible
by `3`) is exactly the residue `N mod 3`.  This file proves the complementary
**blindness horn (H3)** for the *metric* layer — branch letter and depth — in a form
much stronger than the empirical nulls of the experiment: not merely "no measurable
mutual information at `3^k`, `k ≤ 6`", but

* `Berggren3Adic.all_letters_in_one_residue_class` — for **every** odd modulus `M ≥ 3`
  all three branch letters `A, B, C` occur on Fermat pairs whose `N` lies in a *single*
  residue class mod `M`;
* `Berggren3Adic.no_letter_function` — consequently **no** function of `N mod M` computes
  the first branch letter, for any odd `M ≥ 3`, in particular for every 3-adic level
  `3^k` (`no_letter_function_three_pow`, `letter_sealed_three_adically`);
* `Berggren3Adic.depths_unbounded_in_residue_class` and
  `Berggren3Adic.no_depth_function` — the depth channel takes infinitely many values
  inside one residue class mod `M`, for every `M ≥ 1`, so no function of `N mod M`
  computes the depth.

The positive controls of the experiment are proved as well:

* `Berggren3Adic.letter_eq_A_iff` etc. — the letter *is* a deterministic function of the
  ratio band (the live control that fires);
* `Berggren3Adic.band_knowledge_is_factorization` — and reading that band is exactly
  reading the factorisation of `N`, which is the circularity barrier.
-/

namespace Berggren3Adic

open BergGen

/-! ## Witness pairs inside a single residue class -/

/-- The `A`-witness `(M+1, M)`. -/
def witA (M : ℤ) : ℤ × ℤ := (M + 1, M)
/-- The `B`-witness `(3M−1, M)`. -/
def witB (M : ℤ) : ℤ × ℤ := (3 * M - 1, M)
/-- The `C`-witness `(3M+1, M)`. -/
def witC (M : ℤ) : ℤ × ℤ := (3 * M + 1, M)

theorem fermatPair_witA {M : ℤ} (hodd : M % 2 = 1) (hM : 3 ≤ M) : FermatPair (witA M) :=
  ⟨by simp only [witA]; omega, by simp only [witA]; omega,
    ⟨1, -1, by simp only [witA]; ring⟩, by simp only [witA]; omega⟩

theorem fermatPair_witB {M : ℤ} (hodd : M % 2 = 1) (hM : 3 ≤ M) : FermatPair (witB M) :=
  ⟨by simp only [witB]; omega, by simp only [witB]; omega,
    ⟨-1, 3, by simp only [witB]; ring⟩, by simp only [witB]; omega⟩

theorem fermatPair_witC {M : ℤ} (hodd : M % 2 = 1) (hM : 3 ≤ M) : FermatPair (witC M) :=
  ⟨by simp only [witC]; omega, by simp only [witC]; omega,
    ⟨1, -3, by simp only [witC]; ring⟩, by simp only [witC]; omega⟩

theorem letterOf_witA {M : ℤ} (hM : 3 ≤ M) : letterOf (witA M) = A := by
  simp only [letterOf, witA]
  rw [if_pos (by omega)]

theorem letterOf_witB {M : ℤ} (hM : 3 ≤ M) : letterOf (witB M) = B := by
  simp only [letterOf, witB]
  rw [if_neg (by omega), if_pos (by omega)]

theorem letterOf_witC {M : ℤ} (hM : 3 ≤ M) : letterOf (witC M) = C := by
  simp only [letterOf, witC]
  rw [if_neg (by omega), if_neg (by omega)]

theorem nOf_witA (M : ℤ) : nOf (witA M) = 2 * M + 1 := by simp only [nOf, witA]; ring
theorem nOf_witB (M : ℤ) : nOf (witB M) = 8 * M ^ 2 - 6 * M + 1 := by simp only [nOf, witB]; ring
theorem nOf_witC (M : ℤ) : nOf (witC M) = 8 * M ^ 2 + 6 * M + 1 := by simp only [nOf, witC]; ring

/-- **All three branch letters inside one residue class (H3, letters).**
For every odd modulus `M ≥ 3` there are three Fermat pairs whose `N`-values are all
`≡ 1 (mod M)` and whose branch letters are `A`, `B` and `C`. -/
theorem all_letters_in_one_residue_class {M : ℤ} (hodd : M % 2 = 1) (hM : 3 ≤ M) :
    ∃ p₁ p₂ p₃ : ℤ × ℤ,
      FermatPair p₁ ∧ FermatPair p₂ ∧ FermatPair p₃ ∧
      M ∣ nOf p₁ - 1 ∧ M ∣ nOf p₂ - 1 ∧ M ∣ nOf p₃ - 1 ∧
      letterOf p₁ = A ∧ letterOf p₂ = B ∧ letterOf p₃ = C := by
  refine ⟨witA M, witB M, witC M, fermatPair_witA hodd hM, fermatPair_witB hodd hM,
    fermatPair_witC hodd hM, ⟨2, by rw [nOf_witA]; ring⟩, ⟨8 * M - 6, by rw [nOf_witB]; ring⟩,
    ⟨8 * M + 6, by rw [nOf_witC]; ring⟩, letterOf_witA hM, letterOf_witB hM, letterOf_witC hM⟩

/-- **No `N`-computable projection of the branch letter (H3).**
If `f` is *any* function of `N` that only depends on `N mod M` (`M` odd, `M ≥ 3`),
then `f` fails to compute the branch letter on some Fermat pair.  Blindness here is
exact, not statistical. -/
theorem no_letter_function {M : ℤ} (hodd : M % 2 = 1) (hM : 3 ≤ M) (f : ℤ → BergGen)
    (hf : ∀ a b : ℤ, M ∣ a - b → f a = f b) :
    ∃ p : ℤ × ℤ, FermatPair p ∧ f (nOf p) ≠ letterOf p := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨p₁, p₂, p₃, h1, h2, h3, d1, d2, d3, l1, l2, l3⟩ :=
    all_letters_in_one_residue_class hodd hM
  have e12 : f (nOf p₁) = f (nOf p₂) := by
    refine hf _ _ ?_
    obtain ⟨c₁, hc₁⟩ := d1
    obtain ⟨c₂, hc₂⟩ := d2
    exact ⟨c₁ - c₂, by linarith [hc₁, hc₂]⟩
  rw [hcon p₁ h1, hcon p₂ h2, l1, l2] at e12
  exact absurd e12 (by decide)

theorem three_pow_odd (k : ℕ) : ((3 : ℤ) ^ k) % 2 = 1 :=
  Int.odd_iff.mp (Odd.pow ⟨1, by norm_num⟩)

/-- The 3-adic specialisation: sealed at every level `3^k`, `k ≥ 1`
(the experiment tested `k ≤ 6`). -/
theorem no_letter_function_three_pow (k : ℕ) (hk : 1 ≤ k) (f : ℤ → BergGen)
    (hf : ∀ a b : ℤ, (3 : ℤ) ^ k ∣ a - b → f a = f b) :
    ∃ p : ℤ × ℤ, FermatPair p ∧ f (nOf p) ≠ letterOf p := by
  refine no_letter_function (M := (3 : ℤ) ^ k) (three_pow_odd k) ?_ f hf
  calc (3 : ℤ) = 3 ^ 1 := by norm_num
    _ ≤ 3 ^ k := pow_le_pow_right₀ (by norm_num) hk

/-- **The tree letter is adically sealed**: at every 3-adic level the three letters all
occur in one residue class of `N`. -/
theorem letter_sealed_three_adically (k : ℕ) (hk : 1 ≤ k) :
    ∃ p₁ p₂ p₃ : ℤ × ℤ,
      FermatPair p₁ ∧ FermatPair p₂ ∧ FermatPair p₃ ∧
      ((3 : ℤ) ^ k ∣ nOf p₁ - nOf p₂) ∧ ((3 : ℤ) ^ k ∣ nOf p₂ - nOf p₃) ∧
      letterOf p₁ = A ∧ letterOf p₂ = B ∧ letterOf p₃ = C := by
  have hodd : ((3 : ℤ) ^ k) % 2 = 1 := three_pow_odd k
  have hM : (3 : ℤ) ≤ 3 ^ k := by
    calc (3 : ℤ) = 3 ^ 1 := by norm_num
      _ ≤ 3 ^ k := pow_le_pow_right₀ (by norm_num) hk
  obtain ⟨p₁, p₂, p₃, h1, h2, h3, d1, d2, d3, l1, l2, l3⟩ :=
    all_letters_in_one_residue_class hodd hM
  obtain ⟨c₁, hc₁⟩ := d1
  obtain ⟨c₂, hc₂⟩ := d2
  obtain ⟨c₃, hc₃⟩ := d3
  exact ⟨p₁, p₂, p₃, h1, h2, h3, ⟨c₁ - c₂, by linarith⟩, ⟨c₂ - c₃, by linarith⟩, l1, l2, l3⟩

/-! ## Depth blindness -/

/-- The `C`-spine word of length `d`. -/
def spine (d : ℕ) : BergWord := List.replicate d C

@[simp] theorem spine_length (d : ℕ) : (spine d).length = d := by
  simp [spine]

/-- The `C`-spine reaches exactly the nodes `(2 + 2d, 1)`; these are the twin-type nodes
`n = 1` that the experiment had to censor under its step cap. -/
theorem evalPair_spine (d : ℕ) : evalPair (spine d) = (2 + 2 * (d : ℤ), 1) := by
  induction d with
  | zero => simp [spine, evalPair, rootPair]
  | succ j ih =>
    have hrep : spine (j + 1) = C :: spine j := by
      simp [spine, List.replicate_succ]
    rw [hrep, show evalPair (C :: spine j) = actGen C (evalPair (spine j)) from rfl, ih]
    simp only [actGen]
    refine Prod.ext ?_ rfl
    push_cast
    ring

theorem nOf_spine (d : ℕ) : nOf (evalPair (spine d)) = (2 + 2 * (d : ℤ)) ^ 2 - 1 := by
  rw [evalPair_spine]; simp [nOf]

/-- **Unbounded depth inside one residue class (H3, depth).**
For every modulus `M ≥ 1` and every `j`, the spine nodes of depths `1` and `1 + jM`
carry `N`-values in the same class mod `M`.  The depth channel therefore takes infinitely
many values inside a single residue class. -/
theorem depths_unbounded_in_residue_class (M j : ℕ) :
    ((M : ℤ) ∣ nOf (evalPair (spine (1 + j * M))) - nOf (evalPair (spine 1))) ∧
    (spine (1 + j * M)).length = 1 + j * M := by
  refine ⟨?_, spine_length _⟩
  rw [nOf_spine, nOf_spine]
  refine ⟨4 * (j : ℤ) * (M : ℤ) * (j : ℤ) + 16 * (j : ℤ), ?_⟩
  push_cast
  ring

/-! ## How large the depth channel is: a sharp linear bound, saturated by the spine -/

/-- Each Berggren step increases `m + n` by at least `2`, so the depth of a node is at
most `(m + n - 3)/2`. -/
theorem two_mul_length_add_three_le_sum (w : BergWord) :
    2 * (w.length : ℤ) + 3 ≤ (evalPair w).1 + (evalPair w).2 := by
  induction w with
  | nil => simp [evalPair, rootPair]
  | cons g rest ih =>
    have hv := fermatPair_valid (fermatPair_evalPair rest)
    have hpos := hv.1
    have hlt := hv.2
    have hev : evalPair (g :: rest) = actGen g (evalPair rest) := rfl
    rw [hev]
    cases g <;> simp only [actGen, List.length_cons] <;> push_cast <;> omega

/-- The `C`-spine saturates the depth bound: the censored twin-type nodes `n = 1` are
exactly the deepest nodes of their size. -/
theorem spine_saturates_depth_bound (d : ℕ) :
    2 * ((spine d).length : ℤ) + 3 = (evalPair (spine d)).1 + (evalPair (spine d)).2 := by
  rw [spine_length, evalPair_spine]
  push_cast
  ring

/-- In terms of `N` itself: the Berggren depth of the `N`-node is at most `(N-3)/2`, a
bound linear in `N` and hence *exponential in the bit length of `N`*.  Reading the tree
position is therefore not a polynomial-time channel by itself. -/
theorem two_mul_length_add_three_le_nOf {w : BergWord} (hw : w ≠ []) :
    2 * (w.length : ℤ) + 3 ≤ nOf (evalPair w) := by
  have hb := two_mul_length_add_three_le_sum w
  have hF := fermatPair_evalPair w
  have hfac := (word_recovers_factorization hw).1
  have hlt := hF.lt
  have hpos := hF.pos
  have hone : 1 ≤ (evalPair w).1 - (evalPair w).2 := by omega
  nlinarith [hb, hfac, hone]

/-- **No `N`-computable projection of the depth.**  Any function of `N mod M` fails to
compute the Berggren depth of the node, for every modulus `M ≥ 1`. -/
theorem no_depth_function (M : ℕ) (hM : 1 ≤ M) (f : ℤ → ℕ)
    (hf : ∀ a b : ℤ, (M : ℤ) ∣ a - b → f a = f b) :
    ∃ w : BergWord, f (nOf (evalPair w)) ≠ w.length := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨hdvd, hlen⟩ := depths_unbounded_in_residue_class M 1
  have e := hf _ _ hdvd
  rw [hcon (spine (1 + 1 * M)), hcon (spine 1), spine_length, spine_length] at e
  omega

/-- The 3-adic specialisation of depth blindness. -/
theorem no_depth_function_three_pow (k : ℕ) (f : ℤ → ℕ)
    (hf : ∀ a b : ℤ, ((3 ^ k : ℕ) : ℤ) ∣ a - b → f a = f b) :
    ∃ w : BergWord, f (nOf (evalPair w)) ≠ w.length :=
  no_depth_function (3 ^ k) (Nat.one_le_pow _ _ (by norm_num)) f hf

/-! ## Positive controls: the band *is* the letter, and the band *is* the factorisation -/

theorem letter_eq_A_iff (p : ℤ × ℤ) : letterOf p = A ↔ p.1 < 2 * p.2 := by
  simp only [letterOf]
  split_ifs with h1 h2 <;> simp_all

theorem letter_eq_B_iff (p : ℤ × ℤ) :
    letterOf p = B ↔ (2 * p.2 ≤ p.1 ∧ p.1 < 3 * p.2) := by
  simp only [letterOf]
  split_ifs with h1 h2 <;> simp_all

/-- For a genuine node (`n > 0`) the third band is `3n ≤ m`. -/
theorem letter_eq_C_iff {p : ℤ × ℤ} (hpos : 0 < p.2) : letterOf p = C ↔ 3 * p.2 ≤ p.1 := by
  constructor
  · intro h
    by_contra hc
    simp only [letterOf] at h
    split_ifs at h
    all_goals simp_all
  · intro h
    simp only [letterOf]
    rw [if_neg (by omega), if_neg (by omega)]

/-- Two nodes with the same ratio band have the same letter: the letter is a
deterministic function of the band (the live positive control). -/
theorem letter_determined_by_band {p q : ℤ × ℤ}
    (h2 : (p.1 < 2 * p.2) ↔ (q.1 < 2 * q.2)) (h3 : (p.1 < 3 * p.2) ↔ (q.1 < 3 * q.2)) :
    letterOf p = letterOf q := by
  simp only [letterOf]
  by_cases hA : p.1 < 2 * p.2
  · rw [if_pos hA, if_pos (h2.mp hA)]
  · rw [if_neg hA, if_neg (fun hc => hA (h2.mpr hc))]
    by_cases hB : p.1 < 3 * p.2
    · rw [if_pos hB, if_pos (h3.mp hB)]
    · rw [if_neg hB, if_neg (fun hc => hB (h3.mpr hc))]

/-- **Reading the band is reading the factorisation** (the circularity barrier):
knowing the node `(m, n)` of `N` hands over the factors `m − n` and `m + n` of `N`. -/
theorem band_knowledge_is_factorization {p : ℤ × ℤ} (hp : FermatPair p) :
    nOf p = (p.1 - p.2) * (p.1 + p.2) ∧ 1 < p.1 + p.2 ∧ 0 < p.1 - p.2 := by
  refine ⟨nOf_eq_mul p, ?_, by have := hp.lt; omega⟩
  have h1 := hp.pos
  have h2 := hp.lt
  omega

/-! ## The seal: skeleton visible, metric layer invisible -/

/-- **THE TREE POSITION IS ADICALLY SEALED.**  At every 3-adic level `3^k` (`k ≥ 1`):
the skeleton flag `3 ∣ n` is a function of `N mod 3` (hence `N`-visible), while neither
the branch letter nor the depth is a function of `N mod 3^k`. -/
theorem tree_position_adically_sealed (k : ℕ) (hk : 1 ≤ k) :
    (∀ m n m' n' : ℤ, IsCoprime m n → IsCoprime m' n' →
        ((nOf (m, n) : ℤ) : ZMod 3) = ((nOf (m', n') : ℤ) : ZMod 3) →
        (((3 : ℤ) ∣ n) ↔ ((3 : ℤ) ∣ n'))) ∧
    (∀ f : ℤ → BergGen, (∀ a b : ℤ, (3 : ℤ) ^ k ∣ a - b → f a = f b) →
        ∃ p : ℤ × ℤ, FermatPair p ∧ f (nOf p) ≠ letterOf p) ∧
    (∀ f : ℤ → ℕ, (∀ a b : ℤ, ((3 ^ k : ℕ) : ℤ) ∣ a - b → f a = f b) →
        ∃ w : BergWord, f (nOf (evalPair w)) ≠ w.length) :=
  ⟨fun _ _ _ _ h h' hN => (skeleton_determined_by_residue h h' hN).2,
   fun f hf => no_letter_function_three_pow k hk f hf,
   fun f hf => no_depth_function_three_pow k f hf⟩

end Berggren3Adic