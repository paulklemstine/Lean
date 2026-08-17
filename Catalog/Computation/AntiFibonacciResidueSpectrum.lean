import Novelty.Basic

/-!
# The residue spectrum of the anti-Fibonacci sequence modulo a prime

The companion file `Computation.AntiFibonacciModularPeriod` shows *when* the
anti-Fibonacci sequence of `Novelty.Basic` repeats modulo `m`.  This file determines
*what* it hits: modulo an odd prime `p`, the sequence attains **exactly `(p+1)/2` of the
`p` residues** — the quadratic-residue half of `ZMod p`, translated by the identity
`8 · antiFib n = (2n-1)² + 7`.

In particular the anti-Fibonacci sequence *omits* an entire residue class modulo every
odd prime — a genuine "avoidance" phenomenon, and a sharp contrast with Fibonacci, which
is surjective modulo many primes (e.g. mod `5`).

## Main results

* `AntiFibonacciSpectrum.mem_range_mod_iff` — `m : ZMod p` is a value of `antiFib`
  modulo `p` **iff** `8m - 7` is a square in `ZMod p`.
* `AntiFibonacciSpectrum.card_squares_zmod` — auxiliary but general: a finite prime field
  of odd characteristic has exactly `(p+1)/2` squares (proved by a fibre count: the
  squaring map is `2`-to-`1` away from `0`).
* `AntiFibonacciSpectrum.card_range_mod` — the residue spectrum has exactly `(p+1)/2`
  elements.
* `AntiFibonacciSpectrum.exists_omitted_residue` — hence some residue class modulo every
  odd prime is never attained.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): a sequence whose closed form is quadratic should hit exactly
the quadratic residues (suitably normalised), so its image modulo `p` should have size
`(p+1)/2` — asymptotically half of all residues, never all of them.

Experiment (Experimenter): the attained residues (computed below) are
mod 3 : `{1,2}` (2 = (3+1)/2), mod 5 : `{1,2,4}` (3), mod 7 : `{0,1,2,4}` (4),
mod 11 : `{0,1,2,4,5,7}` (6), mod 13 : `{1,2,3,4,7,9,11}` (7).  Exactly `(p+1)/2` each.

Analysis (Analyst): `8·antiFib n = (2n-1)² + 7`, so `m` is attained iff `8m - 7` is a
square; since `x ↦ (x²+7)/8` is a bijection from squares onto attained residues, the
spectrum has the same size as the set of squares, namely `(p+1)/2`.

Critique (Critic): the argument needs `8` and `2` invertible, so `p = 2` must be excluded
(indeed mod `2` the sequence attains both residues).  The surjectivity of `ℕ → ZMod p` is
used to convert an algebraic square root into an actual index, and is invoked explicitly
rather than assumed.
-- !-- Lab Notes -- !--
-/

open AntiFibonacci Finset

namespace AntiFibonacciSpectrum

/-- `2` is invertible modulo an odd prime. -/
theorem two_ne_zero_zmod (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) : (2 : ZMod p) ≠ 0 := by
  intro hcon
  have h2 : ((2 : ℕ) : ZMod p) = 0 := by exact_mod_cast hcon
  have hdvd := (ZMod.natCast_eq_zero_iff 2 p).1 h2
  have hle := Nat.le_of_dvd (by norm_num) hdvd
  have := (Fact.out : p.Prime).two_le
  omega

/-- `8` is invertible modulo an odd prime. -/
theorem eight_ne_zero_zmod (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) : (8 : ZMod p) ≠ 0 := by
  intro hcon
  have h2 := two_ne_zero_zmod p hp
  apply h2
  have : (2 : ZMod p) * (2 * 2) = 0 := by
    calc (2 : ZMod p) * (2 * 2) = 8 := by ring
      _ = 0 := hcon
  rcases mul_eq_zero.mp this with h | h
  · exact h
  · rcases mul_eq_zero.mp h with h' | h' <;> exact h'

/-- **The number of squares in a prime field of odd characteristic is `(p+1)/2`.** -/
theorem card_squares_zmod (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (Finset.univ.image (fun x : ZMod p => x ^ 2)).card = (p + 1) / 2 := by
  classical
  set I := (Finset.univ.image (fun x : ZMod p => x ^ 2)) with hI
  have h0 : (0 : ZMod p) ∈ I := by
    rw [hI, Finset.mem_image]
    exact ⟨0, Finset.mem_univ _, by ring⟩
  have hsum : ∑ y ∈ I, ((Finset.univ : Finset (ZMod p)).filter (fun x => x ^ 2 = y)).card
      = (Finset.univ : Finset (ZMod p)).card := (Finset.card_eq_sum_card_image _ _).symm
  have hfib0 : ((Finset.univ : Finset (ZMod p)).filter (fun x : ZMod p => x ^ 2 = 0)).card = 1 := by
    have hset : ((Finset.univ : Finset (ZMod p)).filter (fun x : ZMod p => x ^ 2 = 0)) = {0} := by
      ext x
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_singleton]
      constructor
      · intro h; exact pow_eq_zero_iff (n := 2) (by norm_num) |>.1 h
      · rintro rfl; ring
    rw [hset]; simp
  have hfib : ∀ y ∈ I.erase 0,
      ((Finset.univ : Finset (ZMod p)).filter (fun x : ZMod p => x ^ 2 = y)).card = 2 := by
    intro y hy
    have hy0 : y ≠ 0 := (Finset.mem_erase.1 hy).1
    have hyI : y ∈ I := (Finset.mem_erase.1 hy).2
    rw [hI, Finset.mem_image] at hyI
    obtain ⟨a, -, rfl⟩ := hyI
    have ha : a ≠ 0 := by
      intro h; apply hy0; rw [h]; ring
    have hset : ((Finset.univ : Finset (ZMod p)).filter (fun x : ZMod p => x ^ 2 = a ^ 2))
        = {a, -a} := by
      ext x
      simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_insert,
        Finset.mem_singleton]
      constructor
      · intro h; exact sq_eq_sq_iff_eq_or_eq_neg.mp h
      · rintro (rfl | rfl) <;> ring
    rw [hset]
    have hne : a ≠ -a := by
      intro h
      have h2 : (2 : ZMod p) * a = 0 := by linear_combination h
      rcases mul_eq_zero.mp h2 with h' | h'
      · exact two_ne_zero_zmod p hp h'
      · exact ha h'
    rw [Finset.card_insert_of_notMem (by simpa using hne), Finset.card_singleton]
  have hsplit : ∑ y ∈ I, ((Finset.univ : Finset (ZMod p)).filter (fun x => x ^ 2 = y)).card
      = 2 * (I.card - 1) + 1 := by
    rw [← Finset.sum_erase_add _ _ h0, hfib0, Finset.sum_congr rfl hfib]
    simp [Finset.card_erase_of_mem h0, Nat.mul_comm]
  have hcard : (Finset.univ : Finset (ZMod p)).card = p := by
    simp [ZMod.card p]
  have hIpos : 1 ≤ I.card := Finset.card_pos.2 ⟨0, h0⟩
  omega

/-! ### The residue spectrum -/

/-- Every anti-Fibonacci value has the shape `((2k+1)² + 7)/8`. -/
theorem exists_odd_form (n : ℕ) : ∃ k, 8 * antiFib n = (2 * k + 1) ^ 2 + 7 := by
  cases n with
  | zero => exact ⟨0, by norm_num⟩
  | succ k =>
      refine ⟨k, ?_⟩
      have h := antiFib_closed (k + 1)
      nlinarith [h]

/-- **The residue spectrum.**  Modulo an odd prime `p`, a residue `m` is attained by the
anti-Fibonacci sequence iff `8m - 7` is a square. -/
theorem mem_range_mod_iff (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) (m : ZMod p) :
    (∃ n : ℕ, ((antiFib n : ℕ) : ZMod p) = m) ↔ IsSquare (8 * m - 7) := by
  constructor
  · rintro ⟨n, rfl⟩
    obtain ⟨k, hk⟩ := exists_odd_form n
    have hcast : ((8 * antiFib n : ℕ) : ZMod p) = (((2 * k + 1) ^ 2 + 7 : ℕ) : ZMod p) := by
      exact_mod_cast congrArg (fun t : ℕ => (t : ZMod p)) hk
    push_cast at hcast
    refine ⟨2 * (k : ZMod p) + 1, ?_⟩
    linear_combination hcast
  · rintro ⟨x, hx⟩
    have h2 : (2 : ZMod p) ≠ 0 := two_ne_zero_zmod p hp
    set t : ZMod p := (x - 1) / 2 with ht
    have ht2 : 2 * t + 1 = x := by
      rw [ht]; field_simp; ring
    obtain ⟨k, hk⟩ : ∃ k : ℕ, ((k : ℕ) : ZMod p) = t := by
      have : NeZero p := ⟨(Fact.out : p.Prime).ne_zero⟩
      exact ⟨t.val, by simp [ZMod.natCast_val, ZMod.cast_id]⟩
    refine ⟨k + 1, ?_⟩
    obtain ⟨j, hj⟩ := exists_odd_form (k + 1)
    have hjk : j = k := by
      have h1 := antiFib_closed (k + 1)
      nlinarith [hj, h1]
    rw [hjk] at hj
    have hcast : ((8 * antiFib (k + 1) : ℕ) : ZMod p)
        = (((2 * k + 1) ^ 2 + 7 : ℕ) : ZMod p) := by
      exact_mod_cast congrArg (fun s : ℕ => (s : ZMod p)) hj
    push_cast at hcast
    have hxx : x * x = 8 * m - 7 := hx.symm
    have h8 : (8 : ZMod p) * ((antiFib (k + 1) : ℕ) : ZMod p) = 8 * m := by
      calc (8 : ZMod p) * ((antiFib (k + 1) : ℕ) : ZMod p)
          = (2 * (k : ZMod p) + 1) ^ 2 + 7 := hcast
        _ = x ^ 2 + 7 := by rw [hk, ht2]
        _ = 8 * m := by linear_combination hxx
    exact mul_left_cancel₀ (eight_ne_zero_zmod p hp) h8


/-- The affine map `s ↦ (s+7)/8` used to transport squares onto the residue spectrum. -/
theorem affine_injective (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    Function.Injective (fun s : ZMod p => (s + 7) / 8) := by
  have h8 : (8 : ZMod p) ≠ 0 := eight_ne_zero_zmod p hp
  intro a b hab
  simp only at hab
  field_simp at hab
  exact add_right_cancel hab

open Classical in
/-- **The residue spectrum has exactly `(p+1)/2` elements.** -/
theorem card_range_mod (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    (Finset.univ.filter (fun m : ZMod p => ∃ n : ℕ, ((antiFib n : ℕ) : ZMod p) = m)).card
      = (p + 1) / 2 := by
  classical
  have h8 : (8 : ZMod p) ≠ 0 := eight_ne_zero_zmod p hp
  have hset : (Finset.univ.filter (fun m : ZMod p => ∃ n : ℕ, ((antiFib n : ℕ) : ZMod p) = m))
      = (Finset.univ.image (fun x : ZMod p => x ^ 2)).image (fun s => (s + 7) / 8) := by
    ext m
    simp only [Finset.mem_filter, Finset.mem_univ, true_and, Finset.mem_image]
    rw [mem_range_mod_iff p hp m]
    constructor
    · rintro ⟨x, hx⟩
      refine ⟨x ^ 2, ⟨x, rfl⟩, ?_⟩
      rw [div_eq_iff h8]
      linear_combination -hx
    · rintro ⟨y, ⟨x, rfl⟩, rfl⟩
      refine ⟨x, ?_⟩
      field_simp
      ring
  rw [hset, Finset.card_image_of_injective _ (affine_injective p hp), card_squares_zmod p hp]

open Classical in
/-- **Avoidance.**  Modulo every odd prime the anti-Fibonacci sequence omits at least one
residue class: it can never be surjective. -/
theorem exists_omitted_residue (p : ℕ) [Fact p.Prime] (hp : p ≠ 2) :
    ∃ m : ZMod p, ∀ n : ℕ, ((antiFib n : ℕ) : ZMod p) ≠ m := by
  classical
  have hp3 : 3 ≤ p := by
    have h2 := (Fact.out : p.Prime).two_le
    omega
  have hcard := card_range_mod p hp
  have hlt : (Finset.univ.filter
      (fun m : ZMod p => ∃ n : ℕ, ((antiFib n : ℕ) : ZMod p) = m)).card
      < (Finset.univ : Finset (ZMod p)).card := by
    rw [hcard]
    have : (Finset.univ : Finset (ZMod p)).card = p := by simp [ZMod.card p]
    omega
  by_contra hcon
  push_neg at hcon
  have huniv : (Finset.univ.filter
      (fun m : ZMod p => ∃ n : ℕ, ((antiFib n : ℕ) : ZMod p) = m)) = Finset.univ := by
    apply Finset.eq_univ_of_forall
    intro m
    obtain ⟨n, hn⟩ := hcon m
    exact Finset.mem_filter.2 ⟨Finset.mem_univ _, ⟨n, hn⟩⟩
  rw [huniv] at hlt
  exact lt_irrefl _ hlt

/-! ### Experimental data -/

section Evidence

/-- The attained residues of `antiFib` modulo `m`, as a sorted list. -/
def spectrum (m k : ℕ) : List ℕ :=
  ((List.range k).map fun n => antiFib n % m).eraseDups.mergeSort (· ≤ ·)

/-- info: [1, 2] -/
#guard_msgs in #eval spectrum 3 30
/-- info: [1, 2, 4] -/
#guard_msgs in #eval spectrum 5 30
/-- info: [0, 1, 2, 4] -/
#guard_msgs in #eval spectrum 7 30
/-- info: [0, 1, 2, 4, 5, 7] -/
#guard_msgs in #eval spectrum 11 40
/-- info: [1, 2, 3, 4, 7, 9, 11] -/
#guard_msgs in #eval spectrum 13 40

end Evidence

end AntiFibonacciSpectrum