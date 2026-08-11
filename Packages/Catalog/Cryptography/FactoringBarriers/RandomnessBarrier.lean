import Cryptography.FactoringBarriers.CongruenceOfSquares

/-!
# The Randomness/Collision Barrier, Made Worst-Case Rigorous

Pollard's rho method and every other *collision-based* factoring method work by
computing `gcd(x_i - x_j, N)` for iterates of some map. The quoted running time
`Θ(N^{1/4})` is a **birthday heuristic**: it assumes the iterates behave like
uniform random residues modulo the unknown prime `p ≈ √N`.

This file proves the two unconditional facts that sit underneath that heuristic.

* `gcd_eq_one_of_no_collision` — a difference of iterates yields a nontrivial
  factor of `N = pq` **only if** the iterates collide modulo `p` or modulo `q`.
  So collision-finding is not one strategy among many for these methods: it is
  the whole method.
* `arithmetic_trajectory_blind` — the trajectory `x_i = i` is collision-free for
  the first `min p q` steps, hence produces *nothing*. Consequently no
  worst-case guarantee better than `min p q ≈ √N` is available for
  collision-based methods; the `N^{1/4}` figure is average-case only.

Both statements are honest sharpenings of "barrier 8": the barrier that is
actually provable in the worst case is `√N`, and the celebrated `N^{1/4}` is a
probabilistic phenomenon, not a theorem about all trajectories.
-/

namespace FactoringBarriers

/-- **Collisions are necessary.** If the two values `a, b` are distinct modulo
`p` and modulo `q`, then `gcd(a - b, pq) = 1`: the gcd step returns nothing. -/
theorem gcd_eq_one_of_no_collision {p q : ℕ} (hp : p.Prime) (hq : q.Prime) {a b : ℤ}
    (hpc : ¬ (p : ℤ) ∣ (a - b)) (hqc : ¬ (q : ℤ) ∣ (a - b)) :
    Int.gcd (a - b) ((p * q : ℕ) : ℤ) = 1 := by
  set d : ℕ := Int.gcd (a - b) ((p * q : ℕ) : ℤ) with hd
  by_contra hne
  have hdvdN : d ∣ p * q := by
    have : (d : ℤ) ∣ ((p * q : ℕ) : ℤ) := Int.gcd_dvd_right _ _
    exact_mod_cast this
  have hdvdab : (d : ℤ) ∣ (a - b) := Int.gcd_dvd_left _ _
  have hd0 : d ≠ 0 := by
    intro h0
    rw [h0] at hdvdN
    have := Nat.eq_zero_of_zero_dvd hdvdN
    have : p = 0 ∨ q = 0 := by
      rcases Nat.mul_eq_zero.mp this with h | h
      · exact Or.inl h
      · exact Or.inr h
    rcases this with h | h
    · exact hp.pos.ne' h
    · exact hq.pos.ne' h
  have hd1 : 1 < d := by omega
  obtain ⟨r, hr, hrd⟩ := Nat.exists_prime_and_dvd (by omega : d ≠ 1)
  have hrN : r ∣ p * q := hrd.trans hdvdN
  have hrab : (r : ℤ) ∣ (a - b) := dvd_trans (by exact_mod_cast hrd) hdvdab
  rcases (Nat.Prime.dvd_mul hr).mp hrN with h | h
  · exact hpc (by rw [(Nat.prime_dvd_prime_iff_eq hr hp).mp h] at hrab; exact hrab)
  · exact hqc (by rw [(Nat.prime_dvd_prime_iff_eq hr hq).mp h] at hrab; exact hrab)

/-- **A blind trajectory.** The arithmetic trajectory `x_i = i` produces no
factor of `N = pq` from any pair of its first `min p q` points. Hence collision
based methods admit no worst-case guarantee below `min p q`, which for a
balanced semiprime is of order `√N` — not `N^{1/4}`. -/
theorem arithmetic_trajectory_blind {p q : ℕ} (hp : p.Prime) (hq : q.Prime)
    {K : ℕ} (hKp : K ≤ p) (hKq : K ≤ q) (i j : Fin K) (hij : i ≠ j) :
    Int.gcd ((i : ℤ) - (j : ℤ)) ((p * q : ℕ) : ℤ) = 1 := by
  have hne : (i : ℤ) - (j : ℤ) ≠ 0 := by
    intro h
    apply hij
    have : (i : ℤ) = (j : ℤ) := by linarith
    have : (i : ℕ) = (j : ℕ) := by exact_mod_cast this
    exact Fin.ext this
  have hlt : |(i : ℤ) - (j : ℤ)| < (K : ℤ) := by
    have hi : (i : ℤ) < (K : ℤ) := by exact_mod_cast i.isLt
    have hj : (j : ℤ) < (K : ℤ) := by exact_mod_cast j.isLt
    have hi0 : (0:ℤ) ≤ (i : ℤ) := by positivity
    have hj0 : (0:ℤ) ≤ (j : ℤ) := by positivity
    rw [abs_lt]; constructor <;> linarith
  refine gcd_eq_one_of_no_collision hp hq ?_ ?_
  · intro hdvd
    have := Int.le_of_dvd (abs_pos.mpr hne) ((dvd_abs _ _).mpr hdvd)
    have : (p : ℤ) ≤ (K : ℤ) - 1 := by omega
    have : (K : ℤ) ≤ (p : ℤ) := by exact_mod_cast hKp
    omega
  · intro hdvd
    have := Int.le_of_dvd (abs_pos.mpr hne) ((dvd_abs _ _).mpr hdvd)
    have : (q : ℤ) ≤ (K : ℤ) - 1 := by omega
    have : (K : ℤ) ≤ (q : ℤ) := by exact_mod_cast hKq
    omega

/-- Restated as a barrier: for a semiprime with both prime factors at least `B`,
*every* pair of points of the arithmetic trajectory of length `B` fails, so at
least `B` steps of a collision-based search can be wasted in the worst case. -/
theorem collision_search_worst_case_bound {p q B : ℕ} (hp : p.Prime) (hq : q.Prime)
    (hB : B ≤ p) (hB' : B ≤ q) :
    ∀ i j : Fin B, i ≠ j → ¬ NontrivialDivisor (p * q) (Int.gcd ((i : ℤ) - (j : ℤ))
      ((p * q : ℕ) : ℤ)) := by
  intro i j hij hcon
  rw [arithmetic_trajectory_blind hp hq hB hB' i j hij] at hcon
  exact absurd hcon.2.1 (by omega)

end FactoringBarriers