import MachineLearning.BerggrenHolyConstruction

/-!
# The prime spectrum of the Berggren tree is exactly the split primes

Fifth file of the *Moonshine from the null cone* cycle.  It closes the prime case of the
conjecture `D1` raised by the previous cycle.

`MachineLearning.BerggrenNiemeierMoonshine` proved one inclusion: no prime `p ≡ 3 (mod 4)`
divides a Berggren hypotenuse, and every hypotenuse is `≡ 1 (mod 4)`.  Here we prove the
converse for primes, so that the "radial spectrum" of the tree is pinned down exactly on
primes:

> **A prime `p` is the hypotenuse of some node of the Berggren tree if and only if
> `p ≡ 1 (mod 4)`** (`prime_isNodeHyp_iff`).

The construction direction uses Fermat's two-squares theorem (`Nat.Prime.sq_add_sq`) to
write `p = a² + b²`, upgrades the representation to an *admissible Euclid parameter pair*
(coprime, ordered, of opposite parity — the coprimality and parity being forced by
primality), and then feeds it into the catalog's Barning–Hall completeness theorem
`param_isNode`.

Auxiliary results of independent use:

* `isNode_iff_exists_applyGens` — the catalog's function-level notion of a node agrees
  with the symbolic `Gen`-address notion.
* `node_hyp_of_sum_two_coprime_squares` — any unordered coprime pair of opposite parity
  produces a node with the corresponding hypotenuse.

## Consequence for moonshine

Together with `not_node_hyp_196883` etc. this says that the tree's radial coordinate is a
*split-prime* object, while the McKay–Thompson head data is built from the supersingular
primes `2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71` of the Monster, a set
containing many inert primes (`3, 7, 11, 19, 23, 31, 47, 59, 71`).  The two prime spectra
are genuinely different, which is the arithmetic reason behind the refutation of part
(iii) of the moonshot.
-/

namespace BerggrenStars

/-! ### Symbolic addresses versus function words -/

theorem exists_gen_of_berggrenWord {W : List (Vec → Vec)} (hW : IsBerggrenWord W) :
    ∃ g : List Gen, ∀ v : Vec, applyWord W v = applyGens g v := by
  induction W with
  | nil => exact ⟨[], fun _ => rfl⟩
  | cons f t ih =>
      have ht : IsBerggrenWord t := fun x hx => hW x (List.mem_cons_of_mem _ hx)
      obtain ⟨g, hg⟩ := ih ht
      rcases hW f List.mem_cons_self with rfl | rfl | rfl
      · exact ⟨Gen.A :: g, fun v => by rw [applyWord_cons, applyGens_cons, hg]; rfl⟩
      · exact ⟨Gen.B :: g, fun v => by rw [applyWord_cons, applyGens_cons, hg]; rfl⟩
      · exact ⟨Gen.C :: g, fun v => by rw [applyWord_cons, applyGens_cons, hg]; rfl⟩

/-- The catalog's orbit definition of a node coincides with reachability by a symbolic
`Gen`-address. -/
theorem isNode_iff_exists_applyGens {v : Vec} :
    IsNode v ↔ ∃ g : List Gen, applyGens g root = v := by
  constructor
  · rintro ⟨W, hW, hWv⟩
    obtain ⟨g, hg⟩ := exists_gen_of_berggrenWord hW
    exact ⟨g, by rw [← hg]; exact hWv⟩
  · rintro ⟨g, rfl⟩
    exact ⟨g.map Gen.act, isBerggrenWord_map_act g, (applyGens_eq_applyWord g root).symm⟩

/-! ### From a coprime pair of opposite parity to a node -/

private theorem odd_neg_sub {m n : ℤ} (h : Odd (m - n)) : Odd (n - m) := by
  obtain ⟨k, hk⟩ := h
  exact ⟨-k - 1, by linarith⟩

/-- Any unordered pair of positive coprime integers of opposite parity is realised by a
node of the Berggren tree, whose hypotenuse is the sum of their squares. -/
theorem node_hyp_of_sum_two_coprime_squares {m n : ℤ} (hm : 0 < m) (hn : 0 < n)
    (hne : m ≠ n) (hcop : Int.gcd m n = 1) (hodd : Odd (m - n)) :
    ∃ g : List Gen, (applyGens g root).2.2 = m ^ 2 + n ^ 2 := by
  have key : ∀ x y : ℤ, 0 < y → y < x → Int.gcd x y = 1 → Odd (x - y) →
      ∃ g : List Gen, (applyGens g root).2.2 = x ^ 2 + y ^ 2 := by
    intro x y hy hxy hg hpar
    have hnode : IsNode (euclidTriple x y) := param_isNode ⟨hy, hxy, hg, hpar⟩
    obtain ⟨g, hgv⟩ := isNode_iff_exists_applyGens.mp hnode
    exact ⟨g, by rw [hgv]; rfl⟩
  rcases lt_or_gt_of_ne hne with h | h
  · exact key n m hm h (by rw [Int.gcd_comm]; exact hcop) (odd_neg_sub hodd) |>.imp
      fun g hgv => by rw [hgv]; ring
  · exact key m n hn h hcop hodd

/-! ### Fermat's two-squares theorem produces admissible parameters -/

/-- **Every prime `p ≡ 1 (mod 4)` is a Berggren hypotenuse.**  Coprimality and opposite
parity of the two squares are forced by primality. -/
theorem prime_one_mod_four_is_node_hyp {p : ℕ} (hp : p.Prime) (h1 : p % 4 = 1) :
    ∃ g : List Gen, (applyGens g root).2.2 = (p : ℤ) := by
  haveI : Fact p.Prime := ⟨hp⟩
  obtain ⟨a, b, hab⟩ := Nat.Prime.sq_add_sq (p := p) (by omega)
  have hp2 : 2 ≤ p := hp.two_le
  -- coprimality
  have hcopN : Nat.gcd a b = 1 := by
    set d := Nat.gcd a b with hd
    have hda : d ∣ a := Nat.gcd_dvd_left a b
    have hdb : d ∣ b := Nat.gcd_dvd_right a b
    obtain ⟨s, hs⟩ := hda
    obtain ⟨t, ht⟩ := hdb
    have hdvd : d * d ∣ p := ⟨s ^ 2 + t ^ 2, by rw [← hab, hs, ht]; ring⟩
    rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdvd) with h | h
    · exact Nat.eq_one_of_mul_eq_one_right h
    · exfalso
      have hdp : d ∣ p := ⟨d, h.symm⟩
      rcases (Nat.Prime.eq_one_or_self_of_dvd hp _ hdp) with h' | h'
      · rw [h'] at h; omega
      · rw [h'] at h; nlinarith
  -- positivity
  have hb0 : b ≠ 0 := by
    rintro rfl
    have : a = 1 := by simpa [Nat.coprime_zero_right] using hcopN
    rw [this] at hab; omega
  have ha0 : a ≠ 0 := by
    rintro rfl
    have : b = 1 := by simpa using hcopN
    rw [this] at hab; omega
  -- distinctness
  have hne : a ≠ b := by
    rintro rfl
    have h2 : 2 ∣ p := ⟨a ^ 2, by omega⟩
    have := (Nat.prime_dvd_prime_iff_eq Nat.prime_two hp).mp h2
    omega
  -- move to `ℤ`
  set m : ℤ := (a : ℤ) with hmdef
  set n : ℤ := (b : ℤ) with hndef
  have habZ : m ^ 2 + n ^ 2 = (p : ℤ) := by
    rw [hmdef, hndef]; exact_mod_cast congrArg (Nat.cast : ℕ → ℤ) hab
  have hmpos : 0 < m := by
    rw [hmdef]; exact_mod_cast Nat.pos_of_ne_zero ha0
  have hnpos : 0 < n := by
    rw [hndef]; exact_mod_cast Nat.pos_of_ne_zero hb0
  have hneZ : m ≠ n := by
    rw [hmdef, hndef]; exact_mod_cast hne
  have hcopZ : Int.gcd m n = 1 := by
    rw [hmdef, hndef]; simpa using hcopN
  have hpodd : ((p : ℤ)) % 2 = 1 := by omega
  have hoddZ : Odd (m - n) := by
    rcases Int.even_or_odd (m - n) with hev | hod
    · exfalso
      obtain ⟨r, hr⟩ := hev
      have hm' : m = n + 2 * r := by linarith
      have hsplit : (p : ℤ) = 2 * (n ^ 2 + 2 * n * r + 2 * r ^ 2) := by
        rw [← habZ, hm']; ring
      obtain ⟨s, hs⟩ : ∃ s : ℤ, (p : ℤ) = 2 * s := ⟨_, hsplit⟩
      omega
    · exact hod
  obtain ⟨g, hg⟩ := node_hyp_of_sum_two_coprime_squares hmpos hnpos hneZ hcopZ hoddZ
  exact ⟨g, by rw [hg, habZ]⟩

/-- **The prime spectrum of the Berggren tree.**  A prime occurs as the hypotenuse of a
node of the Barning–Hall tree exactly when it is a split (Gaussian) prime `p ≡ 1 (mod 4)`.
The forward direction is the congruence law `node_hyp_emod_four`; the backward direction is
the two-squares construction above. -/
theorem prime_isNodeHyp_iff {p : ℕ} (hp : p.Prime) :
    (∃ g : List Gen, (applyGens g root).2.2 = (p : ℤ)) ↔ p % 4 = 1 := by
  constructor
  · rintro ⟨g, hg⟩
    have h4 := node_hyp_emod_four g
    rw [hg] at h4
    omega
  · exact prime_one_mod_four_is_node_hyp hp

/-! ### Split versus inert supersingular primes of the Monster -/

/-- Split supersingular primes of the Monster are Berggren hypotenuses. -/
theorem node_hyp_five : ∃ g : List Gen, (applyGens g root).2.2 = 5 :=
  prime_one_mod_four_is_node_hyp (p := 5) (by norm_num) (by norm_num)

theorem node_hyp_thirteen : ∃ g : List Gen, (applyGens g root).2.2 = 13 :=
  prime_one_mod_four_is_node_hyp (p := 13) (by norm_num) (by norm_num)

theorem node_hyp_seventeen : ∃ g : List Gen, (applyGens g root).2.2 = 17 :=
  prime_one_mod_four_is_node_hyp (p := 17) (by norm_num) (by norm_num)

theorem node_hyp_twentynine : ∃ g : List Gen, (applyGens g root).2.2 = 29 :=
  prime_one_mod_four_is_node_hyp (p := 29) (by norm_num) (by norm_num)

theorem node_hyp_fortyone : ∃ g : List Gen, (applyGens g root).2.2 = 41 :=
  prime_one_mod_four_is_node_hyp (p := 41) (by norm_num) (by norm_num)

/-- Inert supersingular primes of the Monster never divide a Berggren hypotenuse. -/
theorem supersingular_inert_not_dvd_node_hyp (g : List Gen) :
    ∀ p ∈ [3, 7, 11, 19, 23, 31, 47, 59, 71], ¬ ((p : ℤ) ∣ (applyGens g root).2.2) := by
  intro p hp
  fin_cases hp <;>
    exact node_hyp_not_dvd_prime_three_mod_four g (by norm_num) (by norm_num)

end BerggrenStars