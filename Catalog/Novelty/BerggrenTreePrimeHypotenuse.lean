import Novelty.BerggrenTreeZetaAbscissa

/-!
# Prime hypotenuses in the Berggren tree

Which primes occur as hypotenuses of nodes of the Berggren tree?  Since the nodes are
exactly the Euclid seeds (`seedEquiv`) and `c = m² + n²` with `m + n` odd and
`gcd (m,n) = 1`, the answer is governed by Fermat's two-square theorem:

* `hyp_mod_four` — **every** hypotenuse in the tree is `≡ 1 (mod 4)`;
* `prime_hyp_iff` — a prime is the hypotenuse of some node **iff** it is `≡ 1 (mod 4)`;
* `infinite_prime_hyp` — hence, by Dirichlet's theorem, infinitely many nodes of the tree
  carry a prime hypotenuse;
* `summable_primeNode_zeta` — the prime-node Dirichlet series `∑_{c(w) prime} c(w)^{-s}`
  converges for `s > 1`, and
* `primeNode_zeta_ge_primeSum` — it dominates the `χ₄`-restricted prime zeta function
  `∑_{p ≡ 1 (4)} p^{-s}`.

Consequently the "prime number theorem for the Berggren tree" is *not* a new analytic
phenomenon: the prime-hypotenuse counting function of the tree is the counting function of
the primes in the arithmetic progression `1 mod 4`, so an error term of square-root quality
for it is precisely the classical Riemann Hypothesis for the Dirichlet `L`-function
`L(s, χ₄)`.  The Berggren tree therefore transports, but does not simplify, the prime
distribution problem; what it *does* possess unconditionally is the silver critical line of
`Novelty.BerggrenTreeCriticalLine`.
-/

namespace BerggrenZeta

/-- **Every hypotenuse in the Berggren tree is `≡ 1 mod 4`.**  (One leg of the seed is even,
the other odd, so `m² + n² ≡ 0 + 1 mod 4`.) -/
theorem hyp_mod_four (w : List (Fin 3)) : hyp w % 4 = 1 := by
  obtain ⟨h1, h2, h3, h4⟩ := seed_isSeed w
  have key : hyp w = (seed w).1 ^ 2 + (seed w).2 ^ 2 := rfl
  rcases Nat.even_or_odd (seed w).1 with ⟨a, ha⟩ | ⟨a, ha⟩
  · -- `m` even, hence `n` odd
    obtain ⟨b, hb⟩ : ∃ b, (seed w).2 = 2 * b + 1 := ⟨(seed w).2 / 2, by omega⟩
    have hval : hyp w = 4 * (a ^ 2 + b ^ 2 + b) + 1 := by
      rw [key, ha, hb]; ring
    omega
  · -- `m` odd, hence `n` even
    obtain ⟨b, hb⟩ : ∃ b, (seed w).2 = 2 * b := ⟨(seed w).2 / 2, by omega⟩
    have hval : hyp w = 4 * (a ^ 2 + a + b ^ 2) + 1 := by
      rw [key, ha, hb]; ring
    omega

/-- A prime `≡ 1 mod 4` is the hypotenuse of a node of the Berggren tree. -/
theorem exists_node_of_prime_one_mod_four {p : ℕ} (hp : p.Prime) (h4 : p % 4 = 1) :
    ∃ w : List (Fin 3), hyp w = p := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq (p := p) (by omega)
  -- both `a` and `b` are positive
  have hp2 : 2 ≤ p := hp.two_le
  have ha0 : a ≠ 0 := by
    rintro rfl
    have hb2 : b ^ 2 = p := by simpa using hab
    have hbd : b ∣ p := ⟨b, by rw [← hb2]; ring⟩
    rcases hp.eq_one_or_self_of_dvd b hbd with hb1 | hbp
    · rw [hb1] at hb2; simp at hb2; omega
    · rw [hbp] at hb2; nlinarith
  have hb0 : b ≠ 0 := by
    rintro rfl
    have ha2 : a ^ 2 = p := by simpa using hab
    have had : a ∣ p := ⟨a, by rw [← ha2]; ring⟩
    rcases hp.eq_one_or_self_of_dvd a had with ha1 | hap
    · rw [ha1] at ha2; simp at ha2; omega
    · rw [hap] at ha2; nlinarith
  -- they are coprime
  have hcop : Nat.Coprime a b := by
    by_contra hcon
    obtain ⟨q, hq, hqa, hqb⟩ := Nat.Prime.not_coprime_iff_dvd.mp hcon
    have hqp : q ∣ p := by
      rw [← hab]
      exact dvd_add (Dvd.dvd.pow hqa (by norm_num)) (Dvd.dvd.pow hqb (by norm_num))
    have hqeq : q = p := by
      rcases (Nat.Prime.eq_one_or_self_of_dvd hp q hqp) with h | h
      · exact absurd h hq.one_lt.ne'
      · exact h
    subst hqeq
    have hqa' : q ≤ a := Nat.le_of_dvd (by omega) hqa
    have hqb' : q ≤ b := Nat.le_of_dvd (by omega) hqb
    nlinarith [hab, hq.two_le]
  -- opposite parity, since `p` is odd
  have hpar : (a + b) % 2 = 1 := by
    have hodd : p % 2 = 1 := by omega
    rcases Nat.even_or_odd a with ⟨x, hx⟩ | ⟨x, hx⟩ <;>
      rcases Nat.even_or_odd b with ⟨y, hy⟩ | ⟨y, hy⟩ <;>
      · have hax : a = _ := hx
        have hby : b = _ := hy
        subst hax; subst hby
        first
          | omega
          | (exfalso
             have : p = 4 * (x ^ 2 + y ^ 2) := by rw [← hab]; ring
             omega)
          | (exfalso
             have : p = 4 * (x ^ 2 + x + y ^ 2 + y) + 2 := by rw [← hab]; ring
             omega)
  have hne : a ≠ b := by
    intro h
    subst h
    omega
  -- order the pair into an admissible Euclid seed
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · have hseed : IsSeed (b, a) := ⟨hlt, by omega, (Nat.coprime_comm.mp hcop), by omega⟩
    obtain ⟨w, hw⟩ := isSeed_reachable _ hseed
    exact ⟨w, by simp only [hyp, hw]; omega⟩
  · have hseed : IsSeed (a, b) := ⟨hgt, by omega, hcop, hpar⟩
    obtain ⟨w, hw⟩ := isSeed_reachable _ hseed
    exact ⟨w, by simp only [hyp, hw]; omega⟩

/-- **The prime hypotenuses of the Berggren tree are exactly the primes `≡ 1 mod 4`.** -/
theorem prime_hyp_iff {p : ℕ} (hp : p.Prime) :
    (∃ w : List (Fin 3), hyp w = p) ↔ p % 4 = 1 := by
  constructor
  · rintro ⟨w, rfl⟩
    exact hyp_mod_four w
  · exact exists_node_of_prime_one_mod_four hp

/-- **Infinitely many nodes of the tree carry a prime hypotenuse.**  This is Dirichlet's
theorem for the progression `1 mod 4` transported to the Berggren tree. -/
theorem infinite_prime_hyp : {p : ℕ | p.Prime ∧ ∃ w : List (Fin 3), hyp w = p}.Infinite := by
  have hunit : IsUnit (1 : ZMod 4) := isUnit_one
  have hdir := Nat.infinite_setOf_prime_and_eq_mod (q := 4) (a := 1) hunit
  refine Set.Infinite.mono (s := {p : ℕ | p.Prime ∧ (p : ZMod 4) = 1}) ?_ hdir
  rintro p ⟨hp, hmod⟩
  refine ⟨hp, ?_⟩
  have : p % 4 = 1 := by
    have h := (ZMod.natCast_eq_natCast_iff p 1 4).mp (by simpa using hmod)
    simpa [Nat.ModEq] using h
  exact (prime_hyp_iff hp).mpr this

/-- The prime-node Dirichlet series `∑_{c(w) prime} c(w)^{-s}` converges for `s > 1`, being
dominated termwise by the full tree zeta series. -/
theorem summable_primeNode_zeta {s : ℝ} (hs : 1 < s) :
    Summable (fun w : List (Fin 3) =>
      if (hyp w).Prime then (hyp w : ℝ) ^ (-s) else 0) := by
  refine Summable.of_nonneg_of_le (fun w => ?_) (fun w => ?_)
    ((treeZeta_summable_iff s).mpr hs)
  · split
    · positivity
    · exact le_rfl
  · split
    · exact le_rfl
    · positivity

/-- The prime-node series dominates the `χ₄`-restricted prime zeta `∑_{p ≡ 1 (4)} p^{-s}`:
choosing, for each prime `p ≡ 1 mod 4`, a node with hypotenuse `p` gives an injection of
that set of primes into the prime nodes of the tree. -/
theorem primeNode_zeta_ge_primeSum {s : ℝ} (hs : 1 < s)
    (P : Finset ℕ) (hP : ∀ p ∈ P, p.Prime ∧ p % 4 = 1) :
    ∑ p ∈ P, (p : ℝ) ^ (-s) ≤
      ∑' w : List (Fin 3), (if (hyp w).Prime then (hyp w : ℝ) ^ (-s) else 0) := by
  classical
  -- pick a node for each prime of `P`
  have hchoice : ∀ p ∈ P, ∃ w : List (Fin 3), hyp w = p := by
    intro p hp
    obtain ⟨hp1, hp4⟩ := hP p hp
    exact (prime_hyp_iff hp1).mpr hp4
  choose! node hnode using hchoice
  have hinj : Set.InjOn node P := by
    intro p hp q hq hpq
    have h1 := hnode p hp
    have h2 := hnode q hq
    rw [hpq] at h1
    omega
  have himg : ∑ p ∈ P, (p : ℝ) ^ (-s)
      = ∑ w ∈ P.image node, (if (hyp w).Prime then (hyp w : ℝ) ^ (-s) else 0) := by
    rw [Finset.sum_image (fun x hx y hy h => hinj hx hy h)]
    refine Finset.sum_congr rfl (fun p hp => ?_)
    obtain ⟨hp1, -⟩ := hP p hp
    rw [hnode p hp, if_pos hp1]
  rw [himg]
  refine (summable_primeNode_zeta hs).sum_le_tsum _ (fun w _ => ?_)
  split
  · positivity
  · exact le_rfl

end BerggrenZeta