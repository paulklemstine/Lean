/-
  Unconditional cycle obstructions for the Collatz shortcut map
  ============================================================

  Building on the elementary facts in `Applications.Collatz.Basic`, this file
  records a small set of *unconditional* obstructions to nontrivial cycles of
  the Collatz step map
      T(n) = n / 2          if n is even,
      T(n) = 3 n + 1        if n is odd.

  Main results:

  * `T_no_fixed_point` : `T` has no positive fixed point.
  * `T_lt_of_even`     : an even step strictly decreases a positive input
                         (re-exported from `Basic`).
  * `T_gt_of_odd`      : an odd step strictly increases its input
                         (re-exported from `Basic`).
  * `all_even_descent` : if the first `k` iterates of `T` from `n` are all even,
                         then `T^[k] n = n / 2 ^ k`.
  * `periodic_has_odd` : every positive periodic orbit of `T` contains an odd
                         integer.

  Together these show that `T` cannot have a cycle made of even steps only,
  a necessary feature of any putative nontrivial Collatz cycle.
-/
import Mathlib
import Applications.Collatz.Basic

namespace Collatz

/-- `T` has no positive fixed point: for every `n > 0` we have `T n ≠ n`.
    On an even input `T` strictly decreases, on an odd input it strictly
    increases, so equality is impossible. -/
lemma T_no_fixed_point {n : ℕ} (hn : 0 < n) : T n ≠ n := by
  rcases Nat.even_or_odd n with he | ho
  · exact Nat.ne_of_lt (T_lt_of_even hn he)
  · exact Nat.ne_of_gt (T_gt_of_odd ho)

/-- **All-even descent.** If the first `k` iterates `T^[i] n` (`i < k`) are all
    even, then after `k` steps the orbit has been halved `k` times:
    `T^[k] n = n / 2 ^ k`. -/
lemma all_even_descent (n k : ℕ) (h : ∀ i < k, Even (T^[i] n)) :
    T^[k] n = n / 2 ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
    have hk : T^[k] n = n / 2 ^ k := ih (fun i hi => h i (by omega))
    have hek : Even (T^[k] n) := h k (by omega)
    rw [Function.iterate_succ', Function.comp_apply, T_even hek, hk,
        Nat.div_div_eq_div_mul, pow_succ]

/-- **Every positive periodic orbit contains an odd integer.**
    If `n > 0` is periodic with period `p > 0` (`T^[p] n = n`), then some iterate
    `T^[i] n` with `i < p` is odd.  Otherwise all the steps would be even, and by
    `all_even_descent` we would get `n = T^[p] n = n / 2 ^ p < n`, a
    contradiction. -/
lemma periodic_has_odd {n p : ℕ} (hn : 0 < n) (hp : 0 < p)
    (hper : T^[p] n = n) : ∃ i < p, Odd (T^[i] n) := by
  by_contra hc
  push_neg at hc
  have hall : ∀ i < p, Even (T^[i] n) := fun i hi =>
    Nat.not_odd_iff_even.mp (hc i hi)
  have hdesc := all_even_descent n p hall
  rw [hper] at hdesc
  have hlt : n / 2 ^ p < n :=
    Nat.div_lt_self hn (by
      calc 1 < 2 := one_lt_two
        _ ≤ 2 ^ p := Nat.le_self_pow (by omega) 2)
  omega

end Collatz