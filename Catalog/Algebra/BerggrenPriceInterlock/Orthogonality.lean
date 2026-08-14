import Algebra.BerggrenPriceInterlock.Interlock

/-!
# Berggren–Price interlock, Part V: orthogonality to factoring

Three exact statements sharpening the negative verdict for factoring.

1. **The two descents share exactly two edges** (`shared_edges`): if a node has the same
   parent in both trees along the same edge, it is `(3,2)` or `(4,1)` — the two trees
   diverge immediately below the root.
2. **Berggren depth is anti-correlated with Fermat cost** (`berg_depth_vs_fermat`): on the
   line `n = 1` the Berggren address has length `k` (linear in `N^{1/2}`), while Fermat's
   scan finds the very same factorisation in **one** trial value.  Deep Berggren nodes are
   precisely the *easy* factorisations: the tree measures the ratio `(p+q)/(q-p)`, not the
   product `pq`.
3. **A congruence obstruction to the hypotenuse embedding** (`not_dvd_hypot`): if `N` has
   a prime factor `p ≡ 3 (mod 4)` then *no* node at all has `N ∣ m² + n²`.  This is why
   the hypotenuse-`N` probe is empty for `N = 15, 21, 35, 77, 91`, and why the odd-leg
   embedding of Part III is the correct one.
-/

namespace BerggrenPrice

/-! ### The two descents share exactly two edges -/

/-- **Interlock rigidity.**  A tree edge belonging to both trees (same parent, same child)
exists only immediately below the root: the child is `(3,2)` or `(4,1)`. -/
theorem shared_edges (u v : Node) (hu : IsNode u) (i j : Fin 3)
    (h1 : berg i u = v) (h2 : price j u = v) : v = (3, 2) ∨ v = (4, 1) := by
  obtain ⟨hb1, hb2, hcop, -⟩ := hu
  have hdouble : u.1 = 2 * u.2 → u = root := by
    intro hd
    obtain ⟨x, y, hxy⟩ := hcop
    have hdvd : u.2 ∣ 1 := ⟨2 * x + y, by rw [hd] at hxy; linarith⟩
    have := Int.le_of_dvd one_pos hdvd
    have h2' : u.2 = 1 := by omega
    have h1' : u.1 = 2 := by omega
    exact Prod.ext h1' h2'
  subst h1
  fin_cases i <;> fin_cases j <;>
    simp only [berg, price, bA, bB, bC, pA, pB, pC, Prod.ext_iff] at h2 ⊢
  · exact absurd h2.1 (by omega)
  · exact absurd h2.1 (by omega)
  · -- `bA = pC` forces `m = 2n`, i.e. the root, and the child is `(3,2)`
    left
    have hd : u.1 = 2 * u.2 := by omega
    have hroot := hdouble hd
    have e1 : u.1 = 2 := congrArg Prod.fst hroot
    have e2 : u.2 = 1 := congrArg Prod.snd hroot
    omega
  · exact absurd h2.1 (by omega)
  · exact absurd h2.1 (by omega)
  · exact absurd h2.1 (by omega)
  · -- `bC = pA` forces `m = 2n`, i.e. the root, and the child is `(4,1)`
    right
    have hd : u.1 = 2 * u.2 := by omega
    have hroot := hdouble hd
    have e1 : u.1 = 2 := congrArg Prod.fst hroot
    have e2 : u.2 = 1 := congrArg Prod.snd hroot
    omega
  · exact absurd h2.1 (by omega)
  · exact absurd h2.2 (by omega)

/-- Both shared edges really occur, so `shared_edges` is not vacuous: `(3,2)` is
`berg 0 root = price 2 root` and `(4,1)` is `berg 2 root = price 0 root`. -/
theorem shared_edges_exist :
    berg 0 root = ((3 : ℤ), (2 : ℤ)) ∧ price 2 root = ((3 : ℤ), (2 : ℤ)) ∧
    berg 2 root = ((4 : ℤ), (1 : ℤ)) ∧ price 0 root = ((4 : ℤ), (1 : ℤ)) := by
  refine ⟨?_, ?_, ?_, ?_⟩ <;> decide

/-! ### Berggren depth versus Fermat cost on the line `n = 1` -/

theorem isNode_line (k : ℕ) : IsNode (2 * (k : ℤ) + 2, 1) := by
  refine ⟨le_refl 1, ?_, isCoprime_one_right, ⟨k + 1, ?_⟩⟩
  · show (1 : ℤ) < 2 * (k : ℤ) + 2
    have : (0 : ℤ) ≤ (k : ℤ) := Int.natCast_nonneg k
    omega
  show 2 * (k : ℤ) + 2 + 1 = 2 * ((k : ℤ) + 1) + 1
  ring

/-- The Berggren address of the node `(2k+2, 1)` has length exactly `k`. -/
theorem berg_depth_line (k : ℕ) (w : List (Fin 3))
    (hw : applyWord berg w root = (2 * (k : ℤ) + 2, 1)) : w.length = k := by
  obtain ⟨w₀, -, huniq⟩ := berg_tree _ (isNode_line k)
  have h1 : w = w₀ := huniq w hw
  have h2 : List.replicate k (2 : Fin 3) = w₀ := huniq _ (berg_replicate k)
  rw [h1, ← h2, List.length_replicate]

/-- For the same node, Fermat's scan on `N = (2k+1)(2k+3)` succeeds at its **first** trial
value: `r = ⌊√N⌋ = 2k+1` and the witness is `m = r + 1`. -/
theorem fermat_one_step (k : ℕ) :
    ∃ r : ℤ, r ^ 2 ≤ oddLeg (2 * (k : ℤ) + 2, 1) ∧
      oddLeg (2 * (k : ℤ) + 2, 1) < (r + 1) ^ 2 ∧ (2 * (k : ℤ) + 2) - r = 1 := by
  refine ⟨2 * (k : ℤ) + 1, ?_, ?_, by ring⟩
  · simp only [oddLeg]
    nlinarith [Int.natCast_nonneg k]
  · simp only [oddLeg]
    nlinarith [Int.natCast_nonneg k]

/-- **Anti-correlation, exact.**  The nodes of unboundedly large Berggren depth on the
line `n = 1` carry exactly the factorisations Fermat finds in one step. -/
theorem berg_depth_vs_fermat (k : ℕ) :
    (∀ w : List (Fin 3), applyWord berg w root = (2 * (k : ℤ) + 2, 1) → w.length = k) ∧
    oddLeg (2 * (k : ℤ) + 2, 1) = (2 * (k : ℤ) + 1) * (2 * (k : ℤ) + 3) ∧
    ∃ r : ℤ, r ^ 2 ≤ oddLeg (2 * (k : ℤ) + 2, 1) ∧
      oddLeg (2 * (k : ℤ) + 2, 1) < (r + 1) ^ 2 ∧ (2 * (k : ℤ) + 2) - r = 1 := by
  refine ⟨berg_depth_line k, ?_, fermat_one_step k⟩
  simp only [oddLeg]
  ring

/-! ### The hypotenuse embedding is obstructed mod 4 -/

/-- **Congruence obstruction.**  No node has a hypotenuse divisible by a prime
`p ≡ 3 (mod 4)`: primitivity forbids it. -/
theorem not_dvd_hypot_of_prime_three_mod_four {v : Node} (h : IsNode v) {p : ℕ}
    [Fact p.Prime] (hp : p % 4 = 3) : ¬ ((p : ℤ) ∣ hypot v) := by
  intro hdvd
  have hleg : legendreSym p (-1) = -1 := by
    rw [legendreSym.at_neg_one (by omega)]
    exact ZMod.χ₄_nat_three_mod_four hp
  have hform : (p : ℤ) ∣ v.1 ^ 2 - (-1) * v.2 ^ 2 := by
    simpa [hypot, sub_neg_eq_add] using hdvd
  obtain ⟨hm, hn⟩ := legendreSym.prime_dvd_of_eq_neg_one hleg hform
  have hunit : IsUnit ((p : ℤ)) := h.2.2.1.isUnit_of_dvd' hm hn
  rw [Int.isUnit_iff] at hunit
  have hp2 : 2 ≤ p := (Fact.out : p.Prime).two_le
  omega

/-- If `N` has a prime factor `p ≡ 3 (mod 4)`, no node's hypotenuse is divisible by `N`. -/
theorem not_dvd_hypot {v : Node} (h : IsNode v) {N : ℤ} {p : ℕ} [Fact p.Prime]
    (hp : p % 4 = 3) (hpN : (p : ℤ) ∣ N) : ¬ (N ∣ hypot v) := fun hN =>
  not_dvd_hypot_of_prime_three_mod_four h hp (hpN.trans hN)

/-- The empty hypotenuse probes: `15 = 3·5` never divides a primitive hypotenuse. -/
theorem not_dvd_hypot_fifteen {v : Node} (h : IsNode v) : ¬ ((15 : ℤ) ∣ hypot v) := by
  haveI : Fact (Nat.Prime 3) := ⟨by norm_num⟩
  exact not_dvd_hypot h (p := 3) (by norm_num) (by norm_num)

/-- `91 = 7·13` never divides a primitive hypotenuse either. -/
theorem not_dvd_hypot_ninetyone {v : Node} (h : IsNode v) : ¬ ((91 : ℤ) ∣ hypot v) := by
  haveI : Fact (Nat.Prime 7) := ⟨by norm_num⟩
  exact not_dvd_hypot h (p := 7) (by norm_num) (by norm_num)

end BerggrenPrice