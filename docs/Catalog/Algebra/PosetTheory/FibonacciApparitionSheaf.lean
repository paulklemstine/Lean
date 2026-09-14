import Mathlib

/-!
# The Fibonacci rank of apparition

`Shared/NumberTheory/CarmichaelCompositeEntryPoint.lean` and
`MachineLearning/Primitive_Prime_Divisors_for_Composite_Index_Fibonacci_Numbers.lean`
both import this module path, but the module file itself was missing from the repository,
so the import failed and broke the build.  This file supplies the theory those modules
use: the **rank of apparition** (entry point) of a modulus in the Fibonacci sequence.

## Main results

* `exists_pos_dvd_fib` — every `p > 0` divides some positive-index Fibonacci number.  The
  proof is the classical pigeonhole on the state `(F n, F (n+1))` in `ZMod p × ZMod p`
  together with the **reversibility** of the Fibonacci recursion modulo `p`
  (`fibState_step`): a repeated state can be walked all the way back to the initial
  state `(F 0, F 1) = (0, 1)`, which forces `p ∣ F (j - i)`.
* `fibRank` — the rank of apparition, defined as the least positive index at which `p`
  appears, with `fibRank_pos`, `dvd_fib_fibRank` and the minimality property
  `fibRank_min`.
* `fibRank_dvd_iff` — the sheaf-like divisibility law: `p ∣ F n ↔ fibRank p ∣ n`, proved
  from the strong divisibility property `Nat.fib_gcd` of the Fibonacci sequence.
-/

namespace FibonacciApparitionSheaf

/-! ### Reversibility of the Fibonacci recursion modulo `p` -/

/-- The state of the Fibonacci recursion modulo `p` at time `n`. -/
private def fibState (p n : ℕ) : ZMod p × ZMod p :=
  ((Nat.fib n : ZMod p), (Nat.fib (n + 1) : ZMod p))

/-- The Fibonacci recursion is reversible modulo `p`: equal states at time `k+1` come
from equal states at time `k`, because `F k = F (k+2) - F (k+1)`. -/
private theorem fibState_step {p a b : ℕ} (h : fibState p (a + 1) = fibState p (b + 1)) :
    fibState p a = fibState p b := by
  have h1 : (Nat.fib (a + 1) : ZMod p) = (Nat.fib (b + 1) : ZMod p) := congrArg Prod.fst h
  have h2 : (Nat.fib (a + 2) : ZMod p) = (Nat.fib (b + 2) : ZMod p) := congrArg Prod.snd h
  have ea : (Nat.fib (a + 2) : ZMod p) = (Nat.fib a : ZMod p) + (Nat.fib (a + 1) : ZMod p) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have eb : (Nat.fib (b + 2) : ZMod p) = (Nat.fib b : ZMod p) + (Nat.fib (b + 1) : ZMod p) := by
    rw [Nat.fib_add_two]; push_cast; ring
  have hab : (Nat.fib a : ZMod p) = (Nat.fib b : ZMod p) := by
    linear_combination h2 - h1 - ea + eb
  exact Prod.ext hab h1

/-- Iterating reversibility: equal states at time `a+k` and `b+k` come from equal states
at times `a` and `b`. -/
private theorem fibState_down (p : ℕ) :
    ∀ k a b : ℕ, fibState p (a + k) = fibState p (b + k) → fibState p a = fibState p b := by
  intro k
  induction k with
  | zero => intro a b h; simpa using h
  | succ n ih =>
      intro a b h
      refine ih a b (fibState_step ?_)
      have ha : a + n + 1 = a + (n + 1) := by omega
      have hb : b + n + 1 = b + (n + 1) := by omega
      rw [ha, hb]; exact h

/-! ### Existence of the rank of apparition -/

/-- **Every positive modulus appears in the Fibonacci sequence.**  Pigeonhole on the
finitely many states `(F n, F (n+1)) ∈ ZMod p × ZMod p` produces a repetition, and
reversibility transports it back to the initial state, giving `p ∣ F (j - i)`. -/
theorem exists_pos_dvd_fib {p : ℕ} (hp : 0 < p) : ∃ n, 0 < n ∧ p ∣ Nat.fib n := by
  haveI : NeZero p := ⟨hp.ne'⟩
  have key : ∀ i j : ℕ, i < j → fibState p i = fibState p j → 0 < j - i ∧ p ∣ Nat.fib (j - i) := by
    intro i j hij heq
    have h0 : fibState p 0 = fibState p (j - i) := by
      refine fibState_down p i 0 (j - i) ?_
      have h1 : 0 + i = i := by omega
      have h2 : j - i + i = j := by omega
      rw [h1, h2]; exact heq
    have hfst : (Nat.fib 0 : ZMod p) = (Nat.fib (j - i) : ZMod p) := congrArg Prod.fst h0
    refine ⟨by omega, ?_⟩
    rw [← ZMod.natCast_eq_zero_iff]
    simpa using hfst.symm
  obtain ⟨i, j, hne, heq⟩ := Finite.exists_ne_map_eq_of_infinite (fibState p)
  rcases lt_or_gt_of_ne hne with h | h
  · exact ⟨j - i, (key i j h heq).1, (key i j h heq).2⟩
  · exact ⟨i - j, (key j i h heq.symm).1, (key j i h heq.symm).2⟩

/-- `p` has a Fibonacci rank of apparition: it divides some Fibonacci number of positive
index. -/
def HasFibRank (p : ℕ) : Prop := ∃ n, 0 < n ∧ p ∣ Nat.fib n

/-- Every positive modulus has a rank of apparition. -/
theorem hasFibRank_of_pos (p : ℕ) (hp : 0 < p) : HasFibRank p := exists_pos_dvd_fib hp

/-- The **rank of apparition** of `p`: the least positive index `n` with `p ∣ F n`. -/
noncomputable def fibRank (p : ℕ) : ℕ := sInf {n | 0 < n ∧ p ∣ Nat.fib n}

theorem fibRank_mem {p : ℕ} (h : HasFibRank p) : 0 < fibRank p ∧ p ∣ Nat.fib (fibRank p) :=
  Nat.sInf_mem h

/-- The rank of apparition is positive. -/
theorem fibRank_pos {p : ℕ} (h : HasFibRank p) : 0 < fibRank p := (fibRank_mem h).1

/-- `p` divides the Fibonacci number at its rank of apparition. -/
theorem dvd_fib_fibRank {p : ℕ} (h : HasFibRank p) : p ∣ Nat.fib (fibRank p) := (fibRank_mem h).2

/-- Minimality: `p` divides no earlier positive-index Fibonacci number. -/
theorem fibRank_min {p k : ℕ} (hk : 0 < k) (hlt : k < fibRank p) : ¬ p ∣ Nat.fib k := by
  intro hdvd
  exact Nat.notMem_of_lt_sInf hlt ⟨hk, hdvd⟩

/-- **The divisibility law of the rank of apparition.**  `p ∣ F n` exactly when the rank
of apparition of `p` divides `n`.  The forward direction uses the strong divisibility
property `F (gcd m n) = gcd (F m) (F n)` together with minimality. -/
theorem fibRank_dvd_iff {p : ℕ} (h : HasFibRank p) (n : ℕ) :
    p ∣ Nat.fib n ↔ fibRank p ∣ n := by
  constructor
  · intro hn
    rcases Nat.eq_zero_or_pos n with rfl | hpos
    · exact dvd_zero _
    · set r := fibRank p with hr
      have hg : p ∣ Nat.fib (Nat.gcd n r) := by
        rw [Nat.fib_gcd]
        exact Nat.dvd_gcd hn (dvd_fib_fibRank h)
      have hgpos : 0 < Nat.gcd n r := Nat.gcd_pos_of_pos_left _ hpos
      have hgle : Nat.gcd n r ≤ r := Nat.le_of_dvd (fibRank_pos h) (Nat.gcd_dvd_right n r)
      have hgr : Nat.gcd n r = r := by
        by_contra hne
        exact fibRank_min hgpos (lt_of_le_of_ne hgle hne) hg
      exact hgr ▸ Nat.gcd_dvd_left n r
  · intro hr
    exact dvd_trans (dvd_fib_fibRank h) (Nat.fib_dvd _ _ hr)

end FibonacciApparitionSheaf