import Mathlib

/-!
# A universal barrier for collision-based factoring schemes

The previous files analysed specific rows of the birthday-bound hierarchy
(sumset, 3SUM, `r`-SUM, structured evaluations).  Here we abstract away the way
values are produced and keep only what all of them share: a finite *search
space* together with a *value map* into `ℕ`, and the rule that a factor is
extracted as `gcd (difference of two values) N`.

Two universal theorems are proved for this abstraction.

**Span barrier** (`reveals_le_span`).  If such a scheme reveals a factor `f`
of `N`, then two of its values differ by at least `f`.  For a semiprime
`N = p * q` with `q ≤ p` and `f = p`, this forces the scheme to manipulate
numbers of size at least `√N`: no scheme whose values live in a short interval
can ever factor, whatever its arity or internal structure.

**Coverage barrier** (`scheme_reveals_few_primes`).  A *fixed* scheme reveals
very few large primes: with `k` search points and values below `B`, at most
`log_P B · k²` primes `≥ P` can divide any of its `≤ k²` pairwise differences.
Hence a scheme that must succeed on `T` different semiprimes with larger factor
`≥ P` needs `k² ≥ T / log_P B`.  The exponent games of the hierarchy change how
`k` relates to arity, but never this counting bound.

Main results:

* `reveals_le_span`, `reveals_sqrt_barrier` — the span barrier.
* `pow_card_le_of_primes_dvd` — `P ^ |Q| ≤ d` for distinct primes `≥ P`
  dividing `d`.
* `card_le_log_of_primes_dvd` — hence `|Q| ≤ log_P d`.
* `scheme_reveals_few_primes` — the coverage barrier.
* `scheme_space_lower_bound` — its contrapositive cost form.
-/

namespace CollisionBarrier

open Finset

/-- An abstract collision-based factoring scheme: a finite search space
together with a map assigning a natural number to each search point.  A factor
is extracted from the difference of two values. -/
structure Scheme (α : Type*) where
  /-- The finite search space (its cardinality is the scheme's cost). -/
  space : Finset α
  /-- The value (residue representative, tuple sum, evaluation …) at a point. -/
  val : α → ℕ

variable {α : Type*}

/-- The set of nonnegative pairwise differences produced by a scheme. -/
noncomputable def diffs [DecidableEq α] (C : Scheme α) : Finset ℕ :=
  (C.space ×ˢ C.space).image (fun z => C.val z.1 - C.val z.2)

theorem card_diffs_le [DecidableEq α] (C : Scheme α) :
    (diffs C).card ≤ C.space.card ^ 2 := by
  calc (diffs C).card ≤ (C.space ×ˢ C.space).card := Finset.card_image_le
    _ = C.space.card ^ 2 := by rw [Finset.card_product, sq]

/-- The scheme *reveals* `f` from `N` if some pairwise difference has
`gcd` equal to `f`. -/
def Reveals [DecidableEq α] (C : Scheme α) (N f : ℕ) : Prop :=
  ∃ d ∈ diffs C, 0 < d ∧ Nat.gcd d N = f

/-! ## The span barrier -/

/-- **Span barrier.**  A scheme that reveals `f` must produce two values whose
difference is at least `f`. -/
theorem reveals_le_span [DecidableEq α] {C : Scheme α} {N f : ℕ}
    (h : Reveals C N f) : ∃ d ∈ diffs C, f ≤ d := by
  obtain ⟨d, hd, hpos, hgcd⟩ := h
  exact ⟨d, hd, hgcd ▸ Nat.le_of_dvd hpos (Nat.gcd_dvd_left d N)⟩

/-- **`√N` form of the span barrier.**  For a semiprime `N = p * q` with
`q ≤ p`, any scheme revealing the larger factor `p` must produce two values at
distance at least `√N`; in particular its largest value is at least `√N`. -/
theorem reveals_sqrt_barrier [DecidableEq α] {C : Scheme α} {p q : ℕ}
    (hqp : q ≤ p) (h : Reveals C (p * q) p) :
    ∃ d ∈ diffs C, Nat.sqrt (p * q) ≤ d := by
  obtain ⟨d, hd, hfd⟩ := reveals_le_span h
  refine ⟨d, hd, le_trans ?_ hfd⟩
  have : p * q ≤ p * p := Nat.mul_le_mul_left p hqp
  calc Nat.sqrt (p * q) ≤ Nat.sqrt (p * p) := Nat.sqrt_le_sqrt this
    _ = p := by rw [← Nat.pow_two, Nat.sqrt_eq']

/-- A scheme all of whose values lie below `p` cannot reveal the prime factor
`p` of `N = p * q`; with `B ≤ √N ≤ p` this says that small numbers never
factor. -/
theorem no_reveal_of_values_small [DecidableEq α] {C : Scheme α} {p q B : ℕ}
    (hB : ∀ x ∈ C.space, C.val x < B) (hBp : B ≤ p) :
    ¬ Reveals C (p * q) p := by
  intro h
  obtain ⟨d, hd, hfd⟩ := reveals_le_span h
  simp only [diffs, Finset.mem_image, Finset.mem_product] at hd
  obtain ⟨⟨x, y⟩, ⟨hx, hy⟩, rfl⟩ := hd
  have h1 := hB x hx
  dsimp only at hfd
  omega

/-! ## The coverage barrier -/

/-- If `Q` is a set of distinct primes, all at least `P`, all dividing a
positive `d`, then `P ^ |Q| ≤ d`. -/
theorem pow_card_le_of_primes_dvd {P d : ℕ} {Q : Finset ℕ} (hd : 0 < d)
    (hprime : ∀ p ∈ Q, p.Prime) (hge : ∀ p ∈ Q, P ≤ p) (hdvd : ∀ p ∈ Q, p ∣ d) :
    P ^ Q.card ≤ d := by
  have hprod : (∏ p ∈ Q, p) ∣ d :=
    Finset.prod_primes_dvd d (fun a ha => (hprime a ha).prime) hdvd
  calc P ^ Q.card = ∏ _p ∈ Q, P := by simp
    _ ≤ ∏ p ∈ Q, p := Finset.prod_le_prod' hge
    _ ≤ d := Nat.le_of_dvd hd hprod

/-- Logarithmic form: a positive integer `d` has at most `log_P d` distinct
prime divisors `≥ P`. -/
theorem card_le_log_of_primes_dvd {P d : ℕ} {Q : Finset ℕ} (hP : 1 < P)
    (hd : 0 < d) (hprime : ∀ p ∈ Q, p.Prime) (hge : ∀ p ∈ Q, P ≤ p)
    (hdvd : ∀ p ∈ Q, p ∣ d) : Q.card ≤ Nat.log P d :=
  (Nat.le_log_iff_pow_le hP hd.ne').mpr (pow_card_le_of_primes_dvd hd hprime hge hdvd)

/-- **Coverage barrier.**  A fixed scheme with search space of size `k` and all
pairwise differences below `B` reveals at most `log_P B · k²` primes `≥ P`:
the primes it can expose are the large prime divisors of its `≤ k²` pairwise
differences, and each difference has at most `log_P B` of them. -/
theorem scheme_reveals_few_primes [DecidableEq α] (C : Scheme α) {P B : ℕ}
    (hP : 1 < P) (Q : Finset ℕ)
    (hQ : ∀ p ∈ Q, p.Prime ∧ P ≤ p ∧
      ∃ d ∈ diffs C, 0 < d ∧ d ≤ B ∧ p ∣ d) :
    Q.card ≤ Nat.log P B * C.space.card ^ 2 := by
  classical
  -- choose, for every `p ∈ Q`, a difference of the scheme divisible by `p`
  set g : ℕ → ℕ := fun p => if h : p ∈ Q then (hQ p h).2.2.choose else 0 with hg
  have hgspec : ∀ p ∈ Q, g p ∈ diffs C ∧ 0 < g p ∧ g p ≤ B ∧ p ∣ g p := by
    intro p hp
    have := (hQ p hp).2.2.choose_spec
    simpa [hg, hp] using this
  -- each difference accounts for at most `log_P B` primes
  have hfiber : ∀ b ∈ Q.image g, {a ∈ Q | g a = b}.card ≤ Nat.log P B := by
    intro b hb
    rcases Finset.eq_empty_or_nonempty {a ∈ Q | g a = b} with hemp | ⟨p₀, hp₀⟩
    · simp [hemp]
    · simp only [Finset.mem_filter] at hp₀
      obtain ⟨hp₀Q, hp₀g⟩ := hp₀
      have hb0 : 0 < b := hp₀g ▸ (hgspec _ hp₀Q).2.1
      have hbB : b ≤ B := hp₀g ▸ (hgspec _ hp₀Q).2.2.1
      have hcard : {a ∈ Q | g a = b}.card ≤ Nat.log P b := by
        refine card_le_log_of_primes_dvd hP hb0 ?_ ?_ ?_ <;>
          intro p hp <;> simp only [Finset.mem_filter] at hp
        · exact (hQ p hp.1).1
        · exact (hQ p hp.1).2.1
        · exact hp.2 ▸ (hgspec p hp.1).2.2.2
      exact le_trans hcard (Nat.log_mono_right hbB)
  have himg : (Q.image g).card ≤ C.space.card ^ 2 := by
    refine le_trans (Finset.card_le_card ?_) (card_diffs_le C)
    intro b hb
    obtain ⟨p, hp, rfl⟩ := Finset.mem_image.mp hb
    exact (hgspec p hp).1
  calc Q.card ≤ Nat.log P B * (Q.image g).card :=
        Finset.card_le_mul_card_image Q _ hfiber
    _ ≤ Nat.log P B * C.space.card ^ 2 := Nat.mul_le_mul_left _ himg

/-- **Cost form of the coverage barrier.**  A scheme required to reveal each of
`T` distinct primes `≥ P`, with all differences bounded by `B`, needs a search
space of size `k` with `T ≤ log_P B · k²`; i.e. `k ≥ √(T / log_P B)`. -/
theorem scheme_space_lower_bound [DecidableEq α] (C : Scheme α) {P B T : ℕ}
    (hP : 1 < P) (Q : Finset ℕ) (hT : T ≤ Q.card)
    (hQ : ∀ p ∈ Q, p.Prime ∧ P ≤ p ∧
      ∃ d ∈ diffs C, 0 < d ∧ d ≤ B ∧ p ∣ d) :
    T ≤ Nat.log P B * C.space.card ^ 2 :=
  le_trans hT (scheme_reveals_few_primes C hP Q hQ)

end CollisionBarrier