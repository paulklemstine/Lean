import MachineLearning.BerggrenEvenLatticeEmbedding
import Shared.MoonshineJExpansion

/-!
# Deep holes, Niemeier counts, and moonshine numerics against the Berggren tree

Third file of the *Moonshine from the null cone* cycle.  Having settled part (i) of the
moonshot (`MachineLearning.BerggrenEvenLatticeEmbedding`: refuted verbatim, true after the
canonical doubling), we now test parts (ii) and (iii).

### (ii) The tree's branching cannot be the deep-hole / Niemeier structure

The Leech lattice has `23` classes of deep holes, matched with the `23` Niemeier lattices
with roots (`24` Niemeier lattices in total, Leech included).  The Berggren tree is an
*infinite free ternary* tree.  We prove three obstructions:

* `three_pow_ne_deepHoles`, `three_pow_ne_niemeier` — no level of the tree has exactly
  `23` or exactly `24` nodes, so the ternary branching never enumerates the hole classes
  level-wise.
* `treeBall_ne_deepHoles`, `treeBall_ne_niemeier` — the same for the balls
  `1, 4, 13, 40, 121, …` around the root.
* `no_injective_niemeier_labelling`, `exists_infinite_niemeier_fibre` — any labelling of
  Berggren addresses by the `24` Niemeier lattices is non-injective, and some Niemeier
  class receives infinitely many nodes.  Combined with the catalog's freeness theorem this
  transfers to actual Pythagorean triples (`exists_infinite_niemeier_fibre_nodes`).

So hypothesis (ii) is **false**: no hole/Niemeier correspondence can respect the ternary
branching.  What survives is the weaker, correct statement that a Niemeier labelling is a
finite colouring of an infinite tree.

### (iii) Moonshine numerics: which integers can be a Berggren hypotenuse?

We prove the arithmetic law governing the tree's "radial" coordinate:

* `node_hyp_emod_four` — every node hypotenuse is `≡ 1 (mod 4)`;
* `node_hyp_not_dvd_prime_three_mod_four` — **no prime `p ≡ 3 (mod 4)` divides a node
  hypotenuse**: the Berggren tree only ever sees Gaussian-split primes.

Applying this to the head data of the McKay–Thompson series formalised in
`Shared.MoonshineJExpansion` gives a clean negative answer to the hoped-for
"tree-parametrized organization" of moonshine coefficients: the head coefficients
`196884`, `21493760` of `j`, the Monster head dimensions `196883`, `21296876`, and even
the structural constants `23` (deep holes) and `24` (Niemeier lattices) are **all**
divisible by a prime `≡ 3 (mod 4)`, hence none of them ever occurs as the hypotenuse of a
Berggren node.

## Lab notes (data behind the theorems, all re-derived below)

```
196883 = 47 · 59 · 71          47 ≡ 3 (4)
196884 = 2² · 3³ · 1823        3  ≡ 3 (4)
21296876 = 2² · 31 · 41 · 59 · 71   31 ≡ 3 (4)
21493760 = 2¹¹ · 5 · 2099      2099 ≡ 3 (4), prime
23 (deep holes)                23 ≡ 3 (4), prime
24 (Niemeier lattices) = 2³·3  3  ≡ 3 (4)
first Berggren hypotenuses: 5, 13, 25, 29, 37, 41, 53, 61, 65, 85, 101, 109, 113, …
  (all ≡ 1 mod 4, all products of primes ≡ 1 mod 4)
```
-/

namespace BerggrenStars

open MoonshineJ

/-! ## (ii) Counting obstructions to a deep-hole correspondence -/

/-- The number of classes of deep holes in the Leech lattice. -/
def deepHoleCount : ℕ := 23

/-- The number of Niemeier lattices (the `23` with roots, plus Leech). -/
def niemeierCount : ℕ := 24

/-- No level of the ternary Berggren tree has exactly `23` nodes. -/
theorem three_pow_ne_deepHoles (n : ℕ) : 3 ^ n ≠ deepHoleCount := by
  intro h
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simp [deepHoleCount] at h
  · have hdvd : 3 ∣ 3 ^ n := dvd_pow_self 3 hn.ne'
    rw [h] at hdvd
    exact absurd hdvd (by decide)

/-- No level of the ternary Berggren tree has exactly `24` nodes. -/
theorem three_pow_ne_niemeier (n : ℕ) : 3 ^ n ≠ niemeierCount := by
  intro h
  have hodd : ¬ (2 ∣ 3 ^ n) := by
    intro hd
    have := Nat.Prime.dvd_of_dvd_pow Nat.prime_two hd
    omega
  rw [h] at hodd
  exact hodd (by decide)

/-- The number of nodes at depth `≤ n`: `1, 4, 13, 40, 121, …`. -/
def treeBall : ℕ → ℕ
  | 0 => 1
  | n + 1 => treeBall n + 3 ^ (n + 1)

theorem treeBall_mono : ∀ n, treeBall n ≤ treeBall (n + 1) := by
  intro n
  simp only [treeBall]
  exact Nat.le_add_right _ _

theorem treeBall_ge (n : ℕ) (h : 4 ≤ n) : 121 ≤ treeBall n := by
  induction n with
  | zero => omega
  | succ k ih =>
      rcases Nat.lt_or_ge k 4 with hk | hk
      · interval_cases k
        · omega
        · omega
        · omega
        · decide
      · exact le_trans (ih (by omega)) (treeBall_mono k)

/-- No ball around the root of the Berggren tree contains exactly `23` nodes. -/
theorem treeBall_ne_deepHoles (n : ℕ) : treeBall n ≠ deepHoleCount := by
  rcases Nat.lt_or_ge n 4 with h | h
  · interval_cases n <;> decide
  · have := treeBall_ge n h
    simp only [deepHoleCount]
    omega

/-- No ball around the root of the Berggren tree contains exactly `24` nodes. -/
theorem treeBall_ne_niemeier (n : ℕ) : treeBall n ≠ niemeierCount := by
  rcases Nat.lt_or_ge n 4 with h | h
  · interval_cases n <;> decide
  · have := treeBall_ge n h
    simp only [niemeierCount]
    omega

/-- Berggren addresses form an infinite set. -/
instance instInfiniteListGen : Infinite (List Gen) :=
  Infinite.of_injective (fun n : ℕ => List.replicate n Gen.A)
    (fun a b h => by simpa using congrArg List.length h)

/-- **No Niemeier labelling of the tree is injective.**  A bijection "nodes ↔ Niemeier
lattices" is impossible for cardinality reasons. -/
theorem no_injective_niemeier_labelling (f : List Gen → Fin niemeierCount) :
    ¬ Function.Injective f := by
  intro hf
  obtain ⟨x, y, hne, heq⟩ := Finite.exists_ne_map_eq_of_infinite f
  exact hne (hf heq)

/-- **Any Niemeier labelling of the Berggren tree has an infinite fibre.**  The most that
can survive of "nodes ↔ deep holes" is a finite colouring, and then some class is hit
infinitely often. -/
theorem exists_infinite_niemeier_fibre (f : List Gen → Fin niemeierCount) :
    ∃ i : Fin niemeierCount, Infinite (f ⁻¹' {i}) :=
  Finite.exists_infinite_fiber f

/-- **The same statement for the actual Pythagorean triples.**  For any labelling `f` of
triples by the `24` Niemeier lattices, infinitely many *distinct nodes* of the Berggren
tree receive the same label.  Here the catalog's freeness theorem
`applyGens_root_injective` is what upgrades "infinitely many addresses" to "infinitely
many nodes". -/
theorem exists_infinite_niemeier_fibre_nodes (f : Vec → Fin niemeierCount) :
    ∃ i : Fin niemeierCount,
      ((fun g : List Gen => applyGens g root) ''
        {g : List Gen | f (applyGens g root) = i}).Infinite := by
  obtain ⟨i, hi⟩ := Finite.exists_infinite_fiber (fun g : List Gen => f (applyGens g root))
  refine ⟨i, ?_⟩
  have hinf : ((fun g : List Gen => f (applyGens g root)) ⁻¹' {i}).Infinite :=
    Set.infinite_coe_iff.mp hi
  have hinj : Set.InjOn (fun g : List Gen => applyGens g root)
      {g : List Gen | f (applyGens g root) = i} :=
    fun a _ b _ hab => applyGens_root_injective a b hab
  exact Set.Infinite.image hinj hinf

/-! ## (iii) Which integers occur as Berggren hypotenuses -/

/-- Every node hypotenuse is `≡ 1 (mod 4)`. -/
theorem node_hyp_emod_four (g : List Gen) : (applyGens g root).2.2 % 4 = 1 := by
  obtain ⟨m, n, hp, he⟩ := params_of_applyGens g
  rw [he]
  simp only [euclidTriple]
  obtain ⟨t, ht⟩ := hp.par
  rcases Int.even_or_odd m with ⟨k, hk⟩ | ⟨k, hk⟩
  · -- `m` even, hence `n` odd
    have hn : n = 2 * (k - t) - 1 := by omega
    have hsq : m ^ 2 + n ^ 2 = 4 * (k ^ 2 + (k - t) ^ 2 - (k - t)) + 1 := by
      subst hk hn; ring
    rw [hsq]
    generalize (k ^ 2 + (k - t) ^ 2 - (k - t)) = s
    omega
  · -- `m` odd, hence `n` even
    have hn : n = 2 * (k - t) := by omega
    have hsq : m ^ 2 + n ^ 2 = 4 * (k ^ 2 + k + (k - t) ^ 2) + 1 := by
      subst hk hn; ring
    rw [hsq]
    generalize (k ^ 2 + k + (k - t) ^ 2) = s
    omega

/-- **The Gaussian-split law for the Berggren tree.**  No prime `p ≡ 3 (mod 4)` divides
the hypotenuse of any node: every Berggren hypotenuse is a product of primes that split in
`ℤ[i]`.  (This is the arithmetic shadow of the fact that node hypotenuses are sums of two
*coprime* squares.) -/
theorem node_hyp_not_dvd_prime_three_mod_four (g : List Gen) {p : ℕ}
    (hp : p.Prime) (h3 : p % 4 = 3) : ¬ ((p : ℤ) ∣ (applyGens g root).2.2) := by
  haveI : Fact p.Prime := ⟨hp⟩
  intro hdvd
  obtain ⟨m, n, hpar, he⟩ := params_of_applyGens g
  rw [he] at hdvd
  simp only [euclidTriple] at hdvd
  -- push the divisibility into `ZMod p`
  have hz : ((m : ZMod p)) ^ 2 + ((n : ZMod p)) ^ 2 = 0 := by
    have := (ZMod.intCast_zmod_eq_zero_iff_dvd (m ^ 2 + n ^ 2) p).mpr hdvd
    push_cast at this
    exact this
  -- `n` is invertible mod `p`
  have hn0 : (n : ZMod p) ≠ 0 := by
    intro hn
    have hpn : (p : ℤ) ∣ n := (ZMod.intCast_zmod_eq_zero_iff_dvd n p).mp hn
    have hm2 : ((m : ZMod p)) ^ 2 = 0 := by rw [hn] at hz; simpa using hz
    have hpm2 : (p : ℤ) ∣ m ^ 2 := by
      have : ((m ^ 2 : ℤ) : ZMod p) = 0 := by push_cast; exact hm2
      exact (ZMod.intCast_zmod_eq_zero_iff_dvd (m ^ 2) p).mp this
    have hpm : (p : ℤ) ∣ m := Int.Prime.dvd_pow' hp hpm2
    have hcop : IsCoprime m n := Int.isCoprime_iff_gcd_eq_one.mpr hpar.cop
    obtain ⟨u, v, huv⟩ := hcop
    have : (p : ℤ) ∣ 1 := by
      rw [← huv]
      exact dvd_add (Dvd.dvd.mul_left hpm u) (Dvd.dvd.mul_left hpn v)
    have hple : (p : ℤ) ≤ 1 := Int.le_of_dvd one_pos this
    have := hp.two_le
    omega
  -- hence `-1` is a square mod `p`
  have hsq : IsSquare (-1 : ZMod p) := by
    refine ⟨(m : ZMod p) * ((n : ZMod p))⁻¹, ?_⟩
    have hnn : (n : ZMod p) * ((n : ZMod p))⁻¹ = 1 := mul_inv_cancel₀ hn0
    have hm : ((m : ZMod p)) ^ 2 = -((n : ZMod p)) ^ 2 := by linear_combination hz
    have hkey : ((m : ZMod p) * ((n : ZMod p))⁻¹) * ((m : ZMod p) * ((n : ZMod p))⁻¹)
        = -(((n : ZMod p)) * ((n : ZMod p))⁻¹) ^ 2 := by
      linear_combination (((n : ZMod p))⁻¹) ^ 2 * hm
    rw [hkey, hnn]
    ring
  exact (ZMod.exists_sq_eq_neg_one_iff.mp hsq) h3

/-- A convenient packaging: if some prime `p ≡ 3 (mod 4)` divides `N`, then `N` is not the
hypotenuse of any Berggren node. -/
theorem not_node_hyp_of_prime_three_mod_four {N : ℤ} {p : ℕ} (hp : p.Prime)
    (h3 : p % 4 = 3) (hdvd : (p : ℤ) ∣ N) :
    ∀ g : List Gen, (applyGens g root).2.2 ≠ N := by
  intro g hg
  exact node_hyp_not_dvd_prime_three_mod_four g hp h3 (hg ▸ hdvd)

/-! ### Moonshine corollaries -/

/-- `196883`, the dimension of the smallest faithful Monster representation, is never a
Berggren hypotenuse: `196883 = 47 · 59 · 71` and `47 ≡ 3 (mod 4)`. -/
theorem not_node_hyp_196883 (g : List Gen) : (applyGens g root).2.2 ≠ 196883 :=
  not_node_hyp_of_prime_three_mod_four (p := 47) (by norm_num) (by norm_num)
    (by norm_num) g

/-- `196884 = c_{1A}(1)`, the head coefficient of `j` verified in
`Shared.MoonshineJExpansion`, is never a Berggren hypotenuse (`3 ∣ 196884`). -/
theorem not_node_hyp_196884 (g : List Gen) : (applyGens g root).2.2 ≠ 196884 :=
  not_node_hyp_of_prime_three_mod_four (p := 3) (by norm_num) (by norm_num)
    (by norm_num) g

/-- The second Monster head dimension `21296876` is never a Berggren hypotenuse
(`31 ∣ 21296876`, `31 ≡ 3 (mod 4)`). -/
theorem not_node_hyp_21296876 (g : List Gen) : (applyGens g root).2.2 ≠ 21296876 :=
  not_node_hyp_of_prime_three_mod_four (p := 31) (by norm_num) (by norm_num)
    (by norm_num) g

/-- The next `j`-coefficient `21493760 = 2¹¹ · 5 · 2099` is never a Berggren hypotenuse;
here the obstructing prime `2099 ≡ 3 (mod 4)` is genuinely needed, the power of `2` alone
already excluding it as well. -/
theorem not_node_hyp_21493760 (g : List Gen) : (applyGens g root).2.2 ≠ 21493760 :=
  not_node_hyp_of_prime_three_mod_four (p := 2099) (by norm_num) (by norm_num)
    (by norm_num) g

/-- The head coefficient of the `j`-expansion certified in `Shared.MoonshineJExpansion`
is exactly the excluded value `196884`. -/
theorem moonshine_head_not_node_hyp (g : List Gen) :
    (applyGens g root).2.2 ≠ cf jT 2 := by
  have h : cf jT 2 = 196884 := by decide
  rw [h]
  exact not_node_hyp_196884 g

/-- The Leech-lattice structure constants themselves are excluded: neither the deep-hole
count `23` nor the Niemeier count `24` is a Berggren hypotenuse.  So the tree cannot even
"see" the hole structure through its radial coordinate. -/
theorem not_node_hyp_deepHoleCount (g : List Gen) :
    (applyGens g root).2.2 ≠ (deepHoleCount : ℤ) :=
  not_node_hyp_of_prime_three_mod_four (p := 23) (by norm_num) (by norm_num)
    (by simp [deepHoleCount]) g

theorem not_node_hyp_niemeierCount (g : List Gen) :
    (applyGens g root).2.2 ≠ (niemeierCount : ℤ) :=
  not_node_hyp_of_prime_three_mod_four (p := 3) (by norm_num) (by norm_num)
    (by norm_num [niemeierCount]) g

end BerggrenStars