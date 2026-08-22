/-
# The which-factor wall is an exact zero

The experimental report attaches a "which-factor" number `≈ 0.0001` to the cyclic
cubic channel: knowing the public data of a semiprime `N = p q` — the unordered
splitting-type pair `{T(p), T(q)}` together with the residue `N mod f` — tells you
essentially nothing about *which* of the two factors carries which type.

Here that `0.0001` is proved to be an exact `0`, and the mechanism is identified:
the public observable is invariant under the swap `(p,q) ↦ (q,p)`, while the
orientation bit "the first factor has the smaller type" is *anti*-invariant on the
off-diagonal set where the two types differ.  A fixed-point-free sign-flipping
involution forces every fibre of the observable to be exactly balanced.

General machinery (any finite set, any involution):

* `card_true_eq_card_false`, `two_mul_card_true` — balance of a flipped Bool;
* `uEnt_eq_one_of_flip` — a flipped Bool carries exactly one bit;
* `mutInfo_eq_zero_of_flip` — if the observable is invariant while the bit flips,
  the mutual information is exactly `0`;
* `decoder_success_half` — *every* decoder reading only the observable is correct
  on exactly half of the set: no strategy beats coin flipping.

Applied to the cyclic type channel this gives `whichFactor_wall` and
`whichFactor_decoder_half`, and at conductor `13` for the cubic subfield
(`m = 3`, `n = 12`) the concrete statement `conductor13_which_factor_zero`:
`64` off-diagonal exponent pairs, every decoder correct on exactly `32`.
-/
import Bridges.CyclicSubfieldUniformCover

namespace WhichFactorWall

open Finset hiding box
open CyclicTypeChannel

/-! ## 1. Sign-flipping involutions -/

variable {α γ : Type*} [DecidableEq γ]

/-- A fixed-point-free flip pairs the `true` half with the `false` half. -/
theorem card_true_eq_card_false {s : Finset α} {σ : α → α} {g : α → Bool}
    (hmaps : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, g (σ x) ≠ g x) :
    #{x ∈ s | g x = true} = #{x ∈ s | g x = false} := by
  classical
  refine Finset.card_bij' (fun x _ => σ x) (fun x _ => σ x) ?_ ?_ ?_ ?_
  · intro x hx
    simp only [mem_filter] at hx ⊢
    refine ⟨hmaps x hx.1, ?_⟩
    have := hflip x hx.1
    rw [hx.2] at this
    simpa using this
  · intro x hx
    simp only [mem_filter] at hx ⊢
    refine ⟨hmaps x hx.1, ?_⟩
    have := hflip x hx.1
    rw [hx.2] at this
    simpa using this
  · intro x hx
    exact hinv x (mem_filter.1 hx).1
  · intro x hx
    exact hinv x (mem_filter.1 hx).1

/-- Consequently each half is exactly half of the whole. -/
theorem two_mul_card_true {s : Finset α} {σ : α → α} {g : α → Bool}
    (hmaps : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, g (σ x) ≠ g x) :
    2 * #{x ∈ s | g x = true} = s.card := by
  classical
  have hpart : #{x ∈ s | g x = true} + #{x ∈ s | ¬ (g x = true)} = s.card :=
    Finset.card_filter_add_card_filter_not _
  have hneg : {x ∈ s | ¬ (g x = true)} = {x ∈ s | g x = false} := by
    ext x; simp [Bool.not_eq_true]
  rw [hneg] at hpart
  rw [← card_true_eq_card_false hmaps hinv hflip] at hpart
  omega

/-- **A flipped bit carries exactly one bit.** -/
theorem uEnt_eq_one_of_flip {s : Finset α} (hs : s.Nonempty) {σ : α → α} {g : α → Bool}
    (hmaps : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, g (σ x) ≠ g x) :
    uEnt s g = 1 := by
  classical
  have hbal := card_true_eq_card_false hmaps hinv hflip
  have h2c : 2 * #{x ∈ s | g x = true} = s.card := two_mul_card_true hmaps hinv hflip
  obtain ⟨x₀, hx₀⟩ := hs
  have hcpos : 0 < #{x ∈ s | g x = true} := by
    rcases hg : g x₀ with _ | _
    · have hne := hflip x₀ hx₀
      rw [hg] at hne
      have hst : g (σ x₀) = true := by simpa using hne
      exact Finset.card_pos.2 ⟨σ x₀, mem_filter.2 ⟨hmaps x₀ hx₀, hst⟩⟩
    · exact Finset.card_pos.2 ⟨x₀, mem_filter.2 ⟨hx₀, hg⟩⟩
  have hfib : ∀ a ∈ s, #{x ∈ s | g x = g a} = #{x ∈ s | g x = true} := by
    intro a _
    rcases hg : g a with _ | _
    · exact hbal.symm
    · rfl
  have hsum : ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)
      = (s.card : ℝ) * Real.logb 2 (#{x ∈ s | g x = true} : ℝ) := by
    rw [Finset.sum_congr rfl (fun a ha => by rw [hfib a ha])]
    simp [Finset.sum_const, nsmul_eq_mul]
  have hcR : (0 : ℝ) < (#{x ∈ s | g x = true} : ℝ) := by exact_mod_cast hcpos
  have hsR : (s.card : ℝ) = 2 * (#{x ∈ s | g x = true} : ℝ) := by
    have hcast : ((2 * #{x ∈ s | g x = true} : ℕ) : ℝ) = (s.card : ℝ) := by exact_mod_cast h2c
    push_cast at hcast
    linarith
  have hslog : Real.logb 2 (s.card : ℝ)
      = 1 + Real.logb 2 (#{x ∈ s | g x = true} : ℝ) := by
    rw [hsR, Real.logb_mul (by norm_num) (ne_of_gt hcR), Real.logb_self_eq_one]
    norm_num
  have hkey : (2 * (#{x ∈ s | g x = true} : ℝ) * Real.logb 2 (#{x ∈ s | g x = true} : ℝ))
      / (2 * (#{x ∈ s | g x = true} : ℝ)) = Real.logb 2 (#{x ∈ s | g x = true} : ℝ) :=
    mul_div_cancel_left₀ _ (by positivity)
  rw [uEnt, hsum, hslog, hsR, hkey]
  ring

/-- **The which-factor wall in the abstract.**  If a Bool read-out is flipped by an
involution that the observable cannot see, the observable carries exactly zero
information about the read-out. -/
theorem mutInfo_eq_zero_of_flip {s : Finset α} (hs : s.Nonempty) {σ : α → α} {g : α → Bool}
    {obs : α → γ}
    (hmaps : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, g (σ x) ≠ g x) (hobs : ∀ x ∈ s, obs (σ x) = obs x) :
    mutInfo s g obs = 0 := by
  classical
  have hH : uEnt s g = 1 := uEnt_eq_one_of_flip hs hmaps hinv hflip
  have hcond : condEnt s g obs = 1 := by
    have hterm : ∀ c ∈ s.image obs,
        ((#{x ∈ s | obs x = c} : ℝ) / s.card) * uEnt {x ∈ s | obs x = c} g
          = (#{x ∈ s | obs x = c} : ℝ) / s.card := by
      intro c hc
      obtain ⟨y, hy, rfl⟩ := mem_image.1 hc
      have hne : ({x ∈ s | obs x = obs y}).Nonempty := ⟨y, mem_filter.2 ⟨hy, rfl⟩⟩
      have hmaps' : ∀ x ∈ {x ∈ s | obs x = obs y}, σ x ∈ {x ∈ s | obs x = obs y} := by
        intro x hx
        simp only [mem_filter] at hx ⊢
        exact ⟨hmaps x hx.1, by rw [hobs x hx.1, hx.2]⟩
      have hinv' : ∀ x ∈ {x ∈ s | obs x = obs y}, σ (σ x) = x :=
        fun x hx => hinv x (mem_filter.1 hx).1
      have hflip' : ∀ x ∈ {x ∈ s | obs x = obs y}, g (σ x) ≠ g x :=
        fun x hx => hflip x (mem_filter.1 hx).1
      rw [uEnt_eq_one_of_flip hne hmaps' hinv' hflip', mul_one]
    rw [condEnt, Finset.sum_congr rfl hterm, ← Finset.sum_div]
    have hcards : ∑ c ∈ s.image obs, (#{x ∈ s | obs x = c} : ℝ) = (s.card : ℝ) := by
      exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s obs)
    rw [hcards, div_self]
    have : 0 < s.card := Finset.card_pos.2 hs
    positivity
  rw [mutInfo, hH, hcond, sub_self]

omit [DecidableEq γ] in
/-- **No decoder beats a coin flip.**  Any decision rule that sees only the
swap-invariant observable is correct on exactly half of the set. -/
theorem decoder_success_half {s : Finset α} {σ : α → α} {g : α → Bool} {obs : α → γ}
    (hmaps : ∀ x ∈ s, σ x ∈ s) (hinv : ∀ x ∈ s, σ (σ x) = x)
    (hflip : ∀ x ∈ s, g (σ x) ≠ g x) (hobs : ∀ x ∈ s, obs (σ x) = obs x) (d : γ → Bool) :
    2 * #{x ∈ s | d (obs x) = g x} = s.card := by
  classical
  set g' : α → Bool := fun x => decide (d (obs x) = g x) with hg'
  have hflip' : ∀ x ∈ s, g' (σ x) ≠ g' x := by
    intro x hx
    have h1 : g (σ x) ≠ g x := hflip x hx
    have h2 : obs (σ x) = obs x := hobs x hx
    simp only [hg', h2]
    cases hgx : g x <;> cases hgs : g (σ x) <;> cases hd : d (obs x) <;> simp_all
  have hcount := two_mul_card_true (s := s) (σ := σ) (g := g') hmaps hinv hflip'
  have hset : {x ∈ s | g' x = true} = {x ∈ s | d (obs x) = g x} := by
    ext x; simp [hg']
  rwa [hset] at hcount

/-! ## 2. The wall for the cyclic splitting-type channel -/

/-- The semiprimes whose two prime factors have *different* splitting types in the
degree-`m` subfield; on the diagonal there is nothing to decide. -/
def offDiagSub (m n : ℕ) : Finset (ℕ × ℕ) :=
  {x ∈ CyclicTypeChannel.box n | ordType m x.1 ≠ ordType m x.2}

/-- Swapping the two prime factors. -/
def swapPair (x : ℕ × ℕ) : ℕ × ℕ := (x.2, x.1)

/-- The which-factor bit: does the *first* factor carry the smaller type? -/
def orientSub (m : ℕ) (x : ℕ × ℕ) : Bool := decide (ordType m x.1 < ordType m x.2)

/-- Everything a semiprime reveals: the unordered type pair and the residue of the
product. -/
def obsSub (m : ℕ) (x : ℕ × ℕ) : (ℕ × ℕ) × ℕ := (typePair m x, prodRes m x)

theorem swapPair_maps {m n : ℕ} : ∀ x ∈ offDiagSub m n, swapPair x ∈ offDiagSub m n := by
  intro x hx
  simp only [offDiagSub, CyclicTypeChannel.box, mem_filter, Finset.mem_product, mem_range,
    swapPair] at hx ⊢
  exact ⟨⟨hx.1.2, hx.1.1⟩, fun h => hx.2 h.symm⟩

theorem swapPair_involutive (x : ℕ × ℕ) : swapPair (swapPair x) = x := rfl

theorem orientSub_flip {m n : ℕ} :
    ∀ x ∈ offDiagSub m n, orientSub m (swapPair x) ≠ orientSub m x := by
  intro x hx
  simp only [offDiagSub, mem_filter] at hx
  have h := hx.2
  simp only [orientSub, swapPair, ne_eq, decide_eq_decide]
  omega

theorem obsSub_invariant {m n : ℕ} :
    ∀ x ∈ offDiagSub m n, obsSub m (swapPair x) = obsSub m x := by
  intro x _
  obtain ⟨a, b⟩ := x
  simp only [obsSub, swapPair]
  rw [typePair_symm, prodRes_symm]

/-- The off-diagonal set is nonempty as soon as the subfield degree is `≥ 2` and
there are at least two exponents: `(0,1)` splits/does not split. -/
theorem offDiagSub_nonempty {m n : ℕ} (hm : 2 ≤ m) (hn : 2 ≤ n) : (offDiagSub m n).Nonempty := by
  refine ⟨(0, 1), ?_⟩
  have h0 : ordType m 0 = 1 := ordType_zero (by omega)
  have h1 : ordType m 1 = m := by simp [ordType]
  simp only [offDiagSub, CyclicTypeChannel.box, mem_filter, Finset.mem_product, mem_range]
  refine ⟨⟨by omega, by omega⟩, ?_⟩
  rw [h0, h1]
  omega

/-- **The which-factor wall: an exact zero.**  On the off-diagonal semiprimes the
public data `({T(p),T(q)}, N mod f)` carries *exactly zero* information about which
factor has which type. -/
theorem whichFactor_wall {m n : ℕ} (hm : 2 ≤ m) (hn : 2 ≤ n) :
    mutInfo (offDiagSub m n) (orientSub m) (obsSub m) = 0 :=
  mutInfo_eq_zero_of_flip (offDiagSub_nonempty hm hn) swapPair_maps
    (fun x _ => swapPair_involutive x) orientSub_flip obsSub_invariant

/-- The orientation bit itself is a full bit — the wall is not vacuous. -/
theorem whichFactor_entropy_one {m n : ℕ} (hm : 2 ≤ m) (hn : 2 ≤ n) :
    uEnt (offDiagSub m n) (orientSub m) = 1 :=
  uEnt_eq_one_of_flip (offDiagSub_nonempty hm hn) swapPair_maps
    (fun x _ => swapPair_involutive x) orientSub_flip

/-- **Every decoder is a coin flip.**  For any decision rule `d` reading only the
public data, the number of correctly oriented semiprimes is exactly half. -/
theorem whichFactor_decoder_half {m n : ℕ} (d : (ℕ × ℕ) × ℕ → Bool) :
    2 * #{x ∈ offDiagSub m n | d (obsSub m x) = orientSub m x} = (offDiagSub m n).card :=
  decoder_success_half swapPair_maps (fun x _ => swapPair_involutive x) orientSub_flip
    obsSub_invariant d

/-! ## 3. Conductor 13, cubic subfield -/

/-- At conductor `13` the cubic channel has `64` off-diagonal exponent pairs out of
`144`. -/
theorem conductor13_offDiag_card : (offDiagSub 3 12).card = 64 := by decide

/-- **The which-factor wall at conductor 13.**  The reported `0.0001` is exactly
`0`: the cubic type pair together with `N mod 13` says nothing at all about which
factor splits. -/
theorem conductor13_which_factor_zero :
    mutInfo (offDiagSub 3 12) (orientSub 3) (obsSub 3) = 0 :=
  whichFactor_wall (by norm_num) (by norm_num)

/-- ...while the orientation bit that is being hidden is a full bit. -/
theorem conductor13_orientation_entropy :
    uEnt (offDiagSub 3 12) (orientSub 3) = 1 :=
  whichFactor_entropy_one (by norm_num) (by norm_num)

/-- Concretely: every decoder is right on exactly `32` of the `64` off-diagonal
cubic semiprime classes at conductor `13`. -/
theorem conductor13_decoder_thirtytwo (d : (ℕ × ℕ) × ℕ → Bool) :
    #{x ∈ offDiagSub 3 12 | d (obsSub 3 x) = orientSub 3 x} = 32 := by
  have h := whichFactor_decoder_half (m := 3) (n := 12) d
  rw [conductor13_offDiag_card] at h
  omega

end WhichFactorWall