import Computation.Factoring.FreeWitness

/-!
# Round-4 cycle: congruence-determined *candidate lists* must be unbounded

`FreeWitness.not_revealsFactor_of_congruenceDetermined` closes the case of an
`N`-only invariant that outputs a *single* candidate divisor.  A natural
strengthening of the hypothesis — and the obvious next loophole — is a
congruence-determined **candidate list**: a function of `N mod m` producing a
short list of numbers, one of which is promised to be a nontrivial factor of
`N`.  A list of length `L` would give a factoring algorithm with `L` trial
divisions, so barrier 4 predicts that `L` must be large.

This file proves exactly that, unconditionally:

* `CandidateLists.exists_coprime_semiprime_family` — for every modulus `m > 1`,
  every length `k` and every bound `B` there are `k` semiprimes above `B`, all
  congruent to `1 mod m`, whose `2k` prime factors are pairwise distinct (the
  primes are produced in strictly increasing blocks by Dirichlet's theorem);
* `CandidateLists.no_bounded_candidate_list` — hence no map
  `S : ZMod m → Finset ℕ` with `|S a| ≤ k` for all `a` can contain a nontrivial
  divisor of every large semiprime.  Each candidate can serve at most one member
  of a pairwise-coprime family, so a family of size `k + 1` defeats any list of
  size `k`.

Consequently a congruence-determined candidate list must have unbounded size:
the "short list" relaxation of the free-witness barrier is closed too.
-/

namespace CandidateLists

/-- **A pairwise-coprime family of semiprimes in one residue class.**  For every
`k` and `B` there are primes `p 0 < r 0 < p 1 < r 1 < ⋯ < r (k-1)`, all larger
than `B` and all congruent to `1 mod m`; the `k` semiprimes `p i * r i` are then
pairwise coprime and all lie in the class `1 mod m`. -/
theorem exists_coprime_semiprime_family {m : ℕ} (hm : 1 < m) (k B : ℕ) :
    ∃ p r : ℕ → ℕ,
      (∀ i < k, (p i).Prime ∧ (r i).Prime ∧ B < p i ∧ p i < r i ∧
        ((p i : ℕ) : ZMod m) = 1 ∧ ((r i : ℕ) : ZMod m) = 1) ∧
      (∀ i j, i < j → j < k → r i < p j) := by
  haveI : NeZero m := ⟨by omega⟩
  induction k generalizing B with
  | zero => exact ⟨fun _ => 0, fun _ => 0, by omega, by omega⟩
  | succ k ih =>
      -- the smallest block, above `B`
      obtain ⟨p₀, hp₀gt, hp₀, hp₀val⟩ :=
        Nat.forall_exists_prime_gt_and_eq_mod (q := m) (a := (1 : ZMod m)) isUnit_one B
      obtain ⟨r₀, hr₀gt, hr₀, hr₀val⟩ :=
        Nat.forall_exists_prime_gt_and_eq_mod (q := m) (a := (1 : ZMod m)) isUnit_one p₀
      -- all remaining blocks lie above `r₀`
      obtain ⟨p, r, hmain, hchain⟩ := ih r₀
      refine ⟨fun i => Nat.rec p₀ (fun j _ => p j) i, fun i => Nat.rec r₀ (fun j _ => r j) i,
        ?_, ?_⟩
      · rintro (_ | i) hi
        · exact ⟨hp₀, hr₀, hp₀gt, hr₀gt, hp₀val, hr₀val⟩
        · obtain ⟨h1, h2, h3, h4, h5, h6⟩ := hmain i (by omega)
          exact ⟨h1, h2, show B < p i by omega, h4, h5, h6⟩
      · rintro (_ | i) (_ | j) hij hj
        · omega
        · exact (hmain j (by omega)).2.2.1
        · omega
        · exact hchain i j (by omega) (by omega)

/-- **No bounded congruence-determined candidate list.**  Fix a modulus `m > 1`,
a bound `k` and a threshold `B`.  If `S : ZMod m → Finset ℕ` has `|S a| ≤ k` for
every class `a`, then some semiprime `N > B` has *no* nontrivial divisor inside
`S (N mod m)`.  So an `N`-only list of factor candidates cannot have bounded
length. -/
theorem no_bounded_candidate_list {m : ℕ} (hm : 1 < m) (k B : ℕ) (S : ZMod m → Finset ℕ)
    (hcard : ∀ a, (S a).card ≤ k) :
    ¬ (∀ N : ℕ, B < N → (∃ p r : ℕ, p.Prime ∧ r.Prime ∧ N = p * r) →
        ∃ d ∈ S ((N : ℕ) : ZMod m), d ∣ N ∧ 1 < d ∧ d < N) := by
  intro hS
  obtain ⟨p, r, hmain, hchain⟩ := exists_coprime_semiprime_family hm (k + 1) B
  -- every member of the family lies in the class `1 mod m`
  have hclass : ∀ i < k + 1, ((p i * r i : ℕ) : ZMod m) = 1 := by
    intro i hi
    obtain ⟨-, -, -, -, h5, h6⟩ := hmain i hi
    push_cast
    rw [h5, h6, one_mul]
  have hbig : ∀ i < k + 1, B < p i * r i := by
    intro i hi
    obtain ⟨h1, h2, h3, h4, -, -⟩ := hmain i hi
    nlinarith [h1.two_le, h2.two_le]
  -- pick, for each member, a candidate divisor from the (common) list `S 1`
  have key : ∀ i, i < k + 1 → ∃ d, d ∈ S (1 : ZMod m) ∧ (d = p i ∨ d = r i) := by
    intro i hi
    obtain ⟨h1, h2, h3, h4, -, -⟩ := hmain i hi
    obtain ⟨d, hdmem, hdvd, hd1, hdlt⟩ :=
      hS (p i * r i) (hbig i hi) ⟨p i, r i, h1, h2, rfl⟩
    rw [hclass i hi] at hdmem
    refine ⟨d, hdmem, ?_⟩
    rcases Semiprime.dvd_cases h1 h2 hdvd with h | h | h | h
    · omega
    · exact Or.inl h
    · exact Or.inr h
    · omega
  choose! f hf using key
  -- the assignment `i ↦ f i` is injective, because the family is coprime
  have hmemf : Set.MapsTo f (Finset.range (k + 1) : Finset ℕ) (S (1 : ZMod m)) := by
    intro i hi
    simp only [Finset.coe_range, Set.mem_Iio] at hi
    exact Finset.mem_coe.mpr (hf i hi).1
  have hinj : Set.InjOn f (Finset.range (k + 1)) := by
    have hmono : ∀ i j, i < j → j < k + 1 → f i < f j := by
      intro i j hij hj
      have hi : i < k + 1 := by omega
      obtain ⟨-, hcase_i⟩ := hf i hi
      obtain ⟨-, hcase_j⟩ := hf j hj
      have h4i := (hmain i hi).2.2.2.1
      have h4j := (hmain j hj).2.2.2.1
      have hrp := hchain i j hij hj
      rcases hcase_i with h | h <;> rcases hcase_j with h' | h' <;> omega
    intro i hi j hj hfij
    simp only [Finset.coe_range, Set.mem_Iio] at hi hj
    by_contra hne
    rcases Nat.lt_or_ge i j with h | h
    · exact absurd hfij (Nat.ne_of_lt (hmono i j h hj))
    · have : j < i := by omega
      exact absurd hfij.symm (Nat.ne_of_lt (hmono j i this hi))
  have hle := Finset.card_le_card_of_injOn f hmemf hinj
  rw [Finset.card_range] at hle
  exact absurd (hle.trans (hcard 1)) (by omega)

end CandidateLists