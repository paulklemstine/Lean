import Mathlib
import NumberTheory.BealConjecture
import Bridges.BerggrenTrees.BerggrenPythagoreanCore

/-!
# The Berggren tree as a solvable model of the `abc` conjecture

Every Pythagorean triple `a² + b² = c²` is an instance of the `abc` situation `A + B = C`
with `A = a²`, `B = b²`, `C = c²`.  This file develops the *quality theory* of the
Berggren ternary tree of primitive Pythagorean triples (built from `bergA`, `bergB`, `bergC`
in `Bridges.BerggrenTrees.BerggrenPythagoreanCore`) using the radical `Beal.rad` from
`NumberTheory.BealConjecture`.

The `abc` quality of a node is

`quality a b c = log (c ^ 2) / log (rad (a ^ 2 * b ^ 2 * c ^ 2))`.

## Main results

* `BerggrenABC.rad_sq_triple` : `rad (a²b²c²) = rad (abc)` — the radical of a tree node is
  completely explicit.
* `BerggrenABC.treeInv_applyPath` : every node of the tree is a positive, primitive
  Pythagorean triple (hence a genuine `abc` triple).
* `BerggrenABC.one_lt_quality_iff`, `BerggrenABC.quality_lt_two_iff` : the exact arithmetic
  criteria `q > 1 ↔ rad(abc) < c²` and `q < 2 ↔ rad(abc) > c`.
* `BerggrenABC.two_thirds_lt_quality` : **unconditional lower edge of the spectrum**,
  `q > 2/3` for every node.
* `BerggrenABC.quality_lt_two_of_radSq` : the unconditional gap `q < 2` for every node whose
  `abc`-product is not "powerful" (`abc ≤ rad(abc)²`).
* `BerggrenABC.infinitely_many_abc_hits` : **infinitely many tree nodes have quality `> 1`**,
  along the explicit sub-family `n = 3 ^ (2 ^ k) - 1` of the `A`-spine.
* `BerggrenABC.quality_high_node` : an explicit tree node of quality `> 5/4`.
* `BerggrenABC.tree_abc_theorem` : conditional sharp bound — under the effective `abc` bound
  `Beal.ABCBound K`, every node with `K ≤ c ^ 4` has `q ≤ 13/10`.
-/

namespace BerggrenABC

open Beal

/-! ## 1. Radical toolkit -/

theorem rad_le_self {n : ℕ} (hn : 0 < n) : rad n ≤ n :=
  Nat.le_of_dvd hn (rad_dvd_self n)

theorem two_le_rad {n : ℕ} (hn : 2 ≤ n) : 2 ≤ rad n := by
  obtain ⟨p, hp, hpd⟩ := Nat.exists_prime_and_dvd (n := n) (by omega)
  have hmem : p ∈ n.primeFactors := Nat.mem_primeFactors.2 ⟨hp, hpd, by omega⟩
  have hdvd : p ∣ rad n := Finset.dvd_prod_of_mem _ hmem
  have := Nat.le_of_dvd rad_pos hdvd
  have := hp.two_le
  omega

/-- The radical is submultiplicative. -/
theorem rad_mul_le (m n : ℕ) : rad (m * n) ≤ rad m * rad n := by
  rcases Nat.eq_zero_or_pos m with rfl | hm
  · simpa [rad] using Nat.one_le_iff_ne_zero.2 (rad_pos (n := n)).ne'
  rcases Nat.eq_zero_or_pos n with rfl | hn
  · simpa [rad] using Nat.one_le_iff_ne_zero.2 (rad_pos (n := m)).ne'
  have hkey : rad (m * n) * ∏ p ∈ m.primeFactors ∩ n.primeFactors, p = rad m * rad n := by
    unfold rad
    rw [Nat.primeFactors_mul hm.ne' hn.ne']
    exact Finset.prod_union_inter
  have hpos : 0 < ∏ p ∈ m.primeFactors ∩ n.primeFactors, p :=
    Finset.prod_pos fun p hp => (Nat.prime_of_mem_primeFactors (Finset.mem_of_mem_inter_left hp)).pos
  nlinarith [rad_pos (n := m * n)]

/-- On coprime arguments the radical is multiplicative. -/
theorem rad_mul_coprime {m n : ℕ} (h : Nat.Coprime m n) (hm : 0 < m) (hn : 0 < n) :
    rad (m * n) = rad m * rad n := by
  unfold rad
  rw [Nat.primeFactors_mul hm.ne' hn.ne']
  exact Finset.prod_union h.disjoint_primeFactors

theorem rad_prime_pow {p t : ℕ} (hp : p.Prime) (ht : 0 < t) : rad (p ^ t) = p := by
  unfold rad
  rw [Nat.primeFactors_pow _ ht.ne', hp.primeFactors, Finset.prod_singleton]

/-- If a prime power `p ^ s` divides `n`, then the radical of `n` loses the factor `p ^ (s-1)`. -/
theorem rad_mul_pow_le {p s n : ℕ} (hp : p.Prime) (hn : 0 < n) (hdvd : p ^ s ∣ n) (hs : 1 ≤ s) :
    rad n * p ^ (s - 1) ≤ n := by
  set t := n.factorization p with ht
  have hst : s ≤ t := (Nat.Prime.pow_dvd_iff_le_factorization hp hn.ne').1 hdvd
  set u := n / p ^ t with hu
  have hsplit : p ^ t * u = n := Nat.ordProj_mul_ordCompl_eq_self n p
  have hupos : 0 < u := Nat.ordCompl_pos p hn.ne'
  have hcop : Nat.Coprime (p ^ t) u := (Nat.coprime_ordCompl hp hn.ne').pow_left _
  have htpos : 0 < t := lt_of_lt_of_le hs hst
  have hrad : rad n = p * rad u := by
    rw [← hsplit, rad_mul_coprime hcop (pow_pos hp.pos t) hupos, rad_prime_pow hp htpos]
  have hru : rad u ≤ u := rad_le_self hupos
  calc rad n * p ^ (s - 1) = p ^ (s - 1) * p * rad u := by rw [hrad]; ring
    _ = p ^ s * rad u := by
        rw [← pow_succ]
        congr 2
        omega
    _ ≤ p ^ s * u := Nat.mul_le_mul_left _ hru
    _ ≤ p ^ t * u := Nat.mul_le_mul_right _ (Nat.pow_le_pow_right hp.pos hst)
    _ = n := hsplit

/-! ## 2. The `abc` quality of a Pythagorean triple -/

/-- The `abc` quality of the triple `a² + b² = c²`, viewed as the `abc` triple
`A + B = C` with `A = a²`, `B = b²`, `C = c²`. -/
noncomputable def quality (a b c : ℕ) : ℝ :=
  Real.log ((c : ℝ) ^ 2) / Real.log ((rad (a ^ 2 * b ^ 2 * c ^ 2) : ℕ) : ℝ)

/-- The radical of the `abc` triple attached to a Pythagorean triple is the radical of `abc`. -/
theorem rad_sq_triple {a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    rad (a ^ 2 * b ^ 2 * c ^ 2) = rad (a * b * c) :=
  rad_pow_mul_pow_mul_pow ha hb hc two_pos two_pos two_pos

theorem quality_eq {a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    quality a b c = Real.log ((c : ℝ) ^ 2) / Real.log ((rad (a * b * c) : ℕ) : ℝ) := by
  rw [quality, rad_sq_triple ha hb hc]

theorem quality_eq_two_mul {a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 0 < c) :
    quality a b c = 2 * Real.log c / Real.log ((rad (a * b * c) : ℕ) : ℝ) := by
  rw [quality_eq ha hb hc, Real.log_pow]
  norm_num

/-! ## 3. The exact arithmetic criteria for the quality thresholds `1` and `2` -/

theorem log_rad_pos {n : ℕ} (hn : 2 ≤ n) : 0 < Real.log ((rad n : ℕ) : ℝ) := by
  have h2 : (2 : ℝ) ≤ ((rad n : ℕ) : ℝ) := by exact_mod_cast two_le_rad hn
  exact Real.log_pos (by linarith)

/-- **Quality exceeds `1` exactly when the radical drops below `c²`** — i.e. exactly when the
node is an `abc` hit. -/
theorem one_lt_quality_iff {a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 2 ≤ c)
    (h2 : 2 ≤ a * b * c) : 1 < quality a b c ↔ rad (a * b * c) < c ^ 2 := by
  have hlog := log_rad_pos h2
  have hcR : (0 : ℝ) < (c : ℝ) ^ 2 := by positivity
  have hr0 : (0 : ℝ) < ((rad (a * b * c) : ℕ) : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
  rw [quality_eq ha hb (by omega), lt_div_iff₀ hlog, one_mul,
    Real.log_lt_log_iff hr0 hcR]
  constructor
  · intro h; exact_mod_cast h
  · intro h; exact_mod_cast h

/-- **Quality stays below `2` exactly when the radical exceeds `c`.** -/
theorem quality_lt_two_iff {a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 2 ≤ c)
    (h2 : 2 ≤ a * b * c) : quality a b c < 2 ↔ c < rad (a * b * c) := by
  have hlog := log_rad_pos h2
  have hcR : (0 : ℝ) < (c : ℝ) := by positivity
  rw [quality_eq ha hb (by omega), div_lt_iff₀ hlog, Real.log_pow]
  constructor
  · intro h
    have hlt : Real.log (c : ℝ) < Real.log ((rad (a * b * c) : ℕ) : ℝ) := by
      push_cast at h ⊢; linarith
    have hr0 : (0 : ℝ) < ((rad (a * b * c) : ℕ) : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
    have := (Real.log_lt_log_iff hcR hr0).1 hlt
    exact_mod_cast this
  · intro h
    have hlt : (c : ℝ) < ((rad (a * b * c) : ℕ) : ℝ) := by exact_mod_cast h
    have := Real.log_lt_log hcR hlt
    push_cast
    linarith

/-! ## 4. The unconditional lower edge of the spectrum -/

/-- **Unconditional lower edge of the quality spectrum**: every Pythagorean `abc` triple
with legs `≥ 3` has quality `> 2/3`.  The value `2/3` is the exact infimum shape: it is the
quality of a completely squarefree product `abc ≍ c³`. -/
theorem two_thirds_lt_quality {a b c : ℕ} (ha : 3 ≤ a) (hb : 3 ≤ b) (hc : 5 ≤ c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) : 2 / 3 < quality a b c := by
  have hpos : 0 < a * b * c := by positivity
  have h2 : 2 ≤ a * b * c := by
    have : 3 * 3 * 5 ≤ a * b * c := Nat.mul_le_mul (Nat.mul_le_mul ha hb) hc
    omega
  have hlog := log_rad_pos h2
  have hab : 2 * (a * b) ≤ c ^ 2 := by
    have hz : ((a : ℤ)) ^ 2 + (b : ℤ) ^ 2 = (c : ℤ) ^ 2 := by exact_mod_cast h
    have h' : (2 : ℤ) * ((a : ℤ) * b) ≤ (c : ℤ) ^ 2 := by nlinarith [sq_nonneg ((a : ℤ) - b)]
    exact_mod_cast h'
  have hrad : 2 * rad (a * b * c) ≤ c ^ 3 := by
    have h1 : rad (a * b * c) ≤ a * b * c := rad_le_self hpos
    nlinarith
  have hr0 : (0 : ℝ) < ((rad (a * b * c) : ℕ) : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
  have hradR : ((rad (a * b * c) : ℕ) : ℝ) < (c : ℝ) ^ 3 := by
    have h2r : (2 : ℝ) * ((rad (a * b * c) : ℕ) : ℝ) ≤ (c : ℝ) ^ 3 := by exact_mod_cast hrad
    linarith
  have hlogc : 0 < Real.log (c : ℝ) := Real.log_pos (by exact_mod_cast (by omega : 1 < c))
  have hlt : Real.log ((rad (a * b * c) : ℕ) : ℝ) < 3 * Real.log (c : ℝ) := by
    have := Real.log_lt_log hr0 hradR
    rwa [Real.log_pow, Nat.cast_ofNat] at this
  rw [quality_eq_two_mul (by omega) (by omega) (by omega), lt_div_iff₀ hlog]
  linarith

/-! ## 5. Every node of the Berggren tree is an `abc` triple -/

/-- The invariant carried by every node of the Berggren tree: the legs are at least `3`, both
are smaller than the hypotenuse, the triple is Pythagorean and it is primitive. -/
def TreeInv (t : ℤ × ℤ × ℤ) : Prop :=
  3 ≤ t.1 ∧ 3 ≤ t.2.1 ∧ t.1 < t.2.2 ∧ t.2.1 < t.2.2 ∧ IsPythag t.1 t.2.1 t.2.2 ∧
    Int.gcd t.1 t.2.1 = 1

theorem treeInv_root : TreeInv (3, 4, 5) := by
  refine ⟨by norm_num, by norm_num, by norm_num, by norm_num, ?_, by decide⟩
  unfold IsPythag; norm_num

theorem treeInv_step (s : BerggrenStep) (t : ℤ × ℤ × ℤ) (h : TreeInv t) :
    TreeInv (applyStep s t) := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hac, hbc, hp, hg⟩ := h
  simp only at ha hb hac hbc hp hg
  cases s
  · refine ⟨by simp [applyStep, bergA]; omega, by simp [applyStep, bergA]; omega,
      by simp [applyStep, bergA]; omega, by simp [applyStep, bergA]; omega, ?_, ?_⟩
    · simpa [applyStep] using bergA_pyth a b c hp
    · simpa [applyStep] using bergA_prim a b c hp hg
  · refine ⟨by simp [applyStep, bergB]; omega, by simp [applyStep, bergB]; omega,
      by simp [applyStep, bergB]; omega, by simp [applyStep, bergB]; omega, ?_, ?_⟩
    · simpa [applyStep] using bergB_pyth a b c hp
    · simpa [applyStep] using bergB_prim a b c hp hg
  · refine ⟨by simp [applyStep, bergC]; omega, by simp [applyStep, bergC]; omega,
      by simp [applyStep, bergC]; omega, by simp [applyStep, bergC]; omega, ?_, ?_⟩
    · simpa [applyStep] using bergC_pyth a b c hp
    · simpa [applyStep] using bergC_prim a b c hp hg

theorem treeInv_applyPath (p : List BerggrenStep) : TreeInv (applyPath p) := by
  induction p using List.reverseRecOn with
  | nil => simpa using treeInv_root
  | append_singleton l s ih =>
      rw [applyPath_concat]
      exact treeInv_step s _ ih

/-- A natural-number triple is a Berggren tree node when it is reached from `(3,4,5)` by some
finite path of Berggren steps. -/
def IsTreeNode (a b c : ℕ) : Prop :=
  ∃ p : List BerggrenStep, applyPath p = ((a : ℤ), (b : ℤ), (c : ℤ))

/-- **Structure of a tree node**: legs `≥ 3`, hypotenuse `≥ 5`, Pythagorean and primitive. -/
theorem IsTreeNode.basic {a b c : ℕ} (h : IsTreeNode a b c) :
    3 ≤ a ∧ 3 ≤ b ∧ 5 ≤ c ∧ a ^ 2 + b ^ 2 = c ^ 2 ∧ Nat.Coprime a b := by
  obtain ⟨p, hp⟩ := h
  have hinv := treeInv_applyPath p
  rw [hp] at hinv
  obtain ⟨ha, hb, hac, hbc, hpy, hg⟩ := hinv
  simp only at ha hb hac hbc hpy hg
  have ha' : 3 ≤ a := by exact_mod_cast ha
  have hb' : 3 ≤ b := by exact_mod_cast hb
  have hsq : a ^ 2 + b ^ 2 = c ^ 2 := by
    unfold IsPythag at hpy; exact_mod_cast hpy
  have hc' : 5 ≤ c := by nlinarith
  exact ⟨ha', hb', hc', hsq, hg⟩

/-- **Every node of the Berggren tree is an `abc` triple**, and its radical is completely
explicit: `rad (a²b²c²) = rad (abc)`. -/
theorem tree_node_is_abc {a b c : ℕ} (h : IsTreeNode a b c) :
    a ^ 2 + b ^ 2 = c ^ 2 ∧ Nat.Coprime (a ^ 2) (b ^ 2) ∧
      rad (a ^ 2 * b ^ 2 * c ^ 2) = rad (a * b * c) := by
  obtain ⟨ha, hb, hc, hsq, hg⟩ := h.basic
  exact ⟨hsq, hg.pow 2 2, rad_sq_triple (by omega) (by omega) (by omega)⟩

/-- **The lower edge of the tree's quality spectrum**: every node has quality `> 2/3`. -/
theorem tree_quality_gt_two_thirds {a b c : ℕ} (h : IsTreeNode a b c) :
    2 / 3 < quality a b c := by
  obtain ⟨ha, hb, hc, hsq, _⟩ := h.basic
  exact two_thirds_lt_quality ha hb hc hsq

/-! ## 6. The unconditional gap `q < 2` away from the powerful locus -/

/-- For any Pythagorean triple with legs `≥ 3` the product of the legs dominates twice the
hypotenuse. -/
theorem two_mul_hyp_le_legs {a b c : ℕ} (ha : 3 ≤ a) (hb : 3 ≤ b) (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 * c ≤ a * b := by
  have hsq : (2 * c) ^ 2 ≤ (a * b) ^ 2 := by
    have ha' : (3 : ℤ) ≤ (a : ℤ) := by exact_mod_cast ha
    have hb' : (3 : ℤ) ≤ (b : ℤ) := by exact_mod_cast hb
    have hz : (a : ℤ) ^ 2 + (b : ℤ) ^ 2 = (c : ℤ) ^ 2 := by exact_mod_cast h
    have hzz : (2 * (c : ℤ)) ^ 2 ≤ ((a : ℤ) * b) ^ 2 := by
      nlinarith [mul_nonneg (by nlinarith : (0 : ℤ) ≤ (a : ℤ) ^ 2 - 9)
        (by nlinarith : (0 : ℤ) ≤ (b : ℤ) ^ 2 - 4)]
    exact_mod_cast hzz
  exact (Nat.pow_le_pow_iff_left (n := 2) (by norm_num)).1 hsq

/-- **Unconditional quality gap.**  As soon as the `abc`-product of a Pythagorean triple is not
"powerful" — i.e. `abc ≤ rad(abc)²`, which holds e.g. whenever `abc` is squarefree — the
quality is `< 2`.  Hence the only way for a tree node to approach the abstract ceiling `2` is
for `abc` to be extremely powerful. -/
theorem quality_lt_two_of_radSq {a b c : ℕ} (ha : 3 ≤ a) (hb : 3 ≤ b) (hc : 5 ≤ c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) (hpow : a * b * c ≤ (rad (a * b * c)) ^ 2) :
    quality a b c < 2 := by
  have h2 : 2 ≤ a * b * c := by
    have : 3 * 3 * 5 ≤ a * b * c := Nat.mul_le_mul (Nat.mul_le_mul ha hb) hc
    omega
  have hlegs : 2 * c ≤ a * b := two_mul_hyp_le_legs ha hb h
  have hbig : c ^ 2 < (rad (a * b * c)) ^ 2 := by nlinarith
  have : c < rad (a * b * c) := by
    by_contra hcon
    push_neg at hcon
    exact absurd (Nat.pow_le_pow_left hcon 2) (by omega)
  exact (quality_lt_two_iff (by omega) (by omega) (by omega) h2).2 this

/-! ## 7. The `A`-spine of the tree -/

/-- The `A`-spine node with parameter `k`: `(2k+1, 2k(k+1), 2k²+2k+1)`. -/
def spineTriple (k : ℕ) : ℤ × ℤ × ℤ :=
  ((2 * k + 1 : ℤ), (2 * k * (k + 1) : ℤ), (2 * (k : ℤ) ^ 2 + 2 * k + 1))

theorem spineTriple_one : spineTriple 1 = (3, 4, 5) := by
  simp [spineTriple]

theorem spine_step (k : ℕ) : applyStep BerggrenStep.A (spineTriple k) = spineTriple (k + 1) := by
  simp only [applyStep, spineTriple, bergA, Prod.mk.injEq]
  push_cast
  refine ⟨by ring, by ring, by ring⟩

/-- The `A`-spine is exactly the path `A^n` from the root. -/
theorem applyPath_replicate_A (n : ℕ) :
    applyPath (List.replicate n BerggrenStep.A) = spineTriple (n + 1) := by
  induction n with
  | zero => simpa using spineTriple_one.symm
  | succ n ih =>
      rw [List.replicate_succ', applyPath_concat, ih, spine_step]

/-- Every `A`-spine triple is a node of the Berggren tree. -/
theorem spine_isTreeNode (n : ℕ) (hn : 1 ≤ n) :
    IsTreeNode (2 * n + 1) (2 * n * (n + 1)) (2 * n ^ 2 + 2 * n + 1) := by
  refine ⟨List.replicate (n - 1) BerggrenStep.A, ?_⟩
  rw [applyPath_replicate_A]
  have hn' : n - 1 + 1 = n := by omega
  rw [hn']
  simp only [spineTriple, Prod.mk.injEq]
  refine ⟨by push_cast; ring, by push_cast; ring, by push_cast; ring⟩

/-! ## 8. Infinitely many `abc` hits in the tree -/

/-- **Hit criterion on the `A`-spine.**  If the radicals of `n` and `n+1` are small enough,
the `A`-spine node with parameter `n` is an `abc` hit. -/
theorem spine_hit_criterion (n : ℕ) (hn : 3 ≤ n)
    (hcrit : (2 * n + 1) * (2 * (rad n * rad (n + 1))) < 2 * n ^ 2 + 2 * n + 1) :
    1 < quality (2 * n + 1) (2 * n * (n + 1)) (2 * n ^ 2 + 2 * n + 1) := by
  set a := 2 * n + 1 with hadef
  set b := 2 * n * (n + 1) with hbdef
  set c := 2 * n ^ 2 + 2 * n + 1 with hcdef
  have hposa : 0 < a := by omega
  have hposb : 0 < b := by positivity
  have hposc : 0 < c := by positivity
  -- the radical of the even leg splits off the factor `2`
  have hradb : rad b ≤ 2 * (rad n * rad (n + 1)) := by
    have h1 : rad b ≤ rad (2 * n) * rad (n + 1) := rad_mul_le _ _
    have h2 : rad (2 * n) ≤ rad 2 * rad n := rad_mul_le _ _
    have h3 : rad 2 = 2 := by
      simpa using rad_prime_pow (p := 2) (t := 1) (by norm_num) (by norm_num)
    calc rad b ≤ rad (2 * n) * rad (n + 1) := h1
      _ ≤ (rad 2 * rad n) * rad (n + 1) := Nat.mul_le_mul_right _ h2
      _ = 2 * (rad n * rad (n + 1)) := by rw [h3]; ring
  -- hence the whole radical is below `c ^ 2`
  have hrad_le : rad (a * b * c) ≤ a * (2 * (rad n * rad (n + 1))) * c := by
    calc rad (a * b * c) ≤ rad (a * b) * rad c := rad_mul_le _ _
      _ ≤ (rad a * rad b) * rad c := Nat.mul_le_mul_right _ (rad_mul_le _ _)
      _ ≤ (a * (2 * (rad n * rad (n + 1)))) * c :=
          Nat.mul_le_mul (Nat.mul_le_mul (rad_le_self hposa) hradb) (rad_le_self hposc)
  have hfinal : rad (a * b * c) < c ^ 2 := by
    have hlt : a * (2 * (rad n * rad (n + 1))) * c < c * c :=
      Nat.mul_lt_mul_of_lt_of_le hcrit (le_refl c) hposc
    calc rad (a * b * c) ≤ a * (2 * (rad n * rad (n + 1))) * c := hrad_le
      _ < c * c := hlt
      _ = c ^ 2 := by ring
  have h2abc : 2 ≤ a * b * c := by
    have : 3 * 3 * 5 ≤ a * b * c :=
      Nat.mul_le_mul (Nat.mul_le_mul (by omega) (by nlinarith)) (by nlinarith)
    omega
  exact (one_lt_quality_iff hposa hposb (by omega) h2abc).2 hfinal

/-- Lifting the exponent for an odd base: `2 ^ (k+2)` divides `d ^ (2 ^ k) - 1` for odd `d`
and every `k ≥ 1`. -/
theorem int_two_pow_dvd_odd {d : ℤ} (hd : Odd d) (k : ℕ) (hk : 1 ≤ k) :
    (2 : ℤ) ^ (k + 2) ∣ d ^ (2 ^ k) - 1 := by
  induction k, hk using Nat.le_induction with
  | base =>
      obtain ⟨t, rfl⟩ := hd
      obtain ⟨u, hu⟩ := Int.even_mul_succ_self t
      refine ⟨u, ?_⟩
      have hexp : (2 * t + 1) ^ (2 ^ 1) - 1 = 4 * (t * (t + 1)) := by ring
      rw [hexp, hu]
      ring
  | succ k hk ih =>
      have hsplit : d ^ (2 ^ (k + 1)) - 1 = (d ^ (2 ^ k) - 1) * (d ^ (2 ^ k) + 1) := by
        have h2 : (2 : ℕ) ^ (k + 1) = 2 ^ k * 2 := by ring
        rw [h2, pow_mul]
        ring
      have hodd : (2 : ℤ) ∣ d ^ (2 ^ k) + 1 := by
        obtain ⟨m, hm⟩ := hd.pow (n := 2 ^ k)
        exact ⟨m + 1, by rw [hm]; ring⟩
      have hmul := mul_dvd_mul ih hodd
      rw [hsplit]
      calc (2 : ℤ) ^ (k + 1 + 2) = 2 ^ (k + 2) * 2 := by ring
        _ ∣ (d ^ (2 ^ k) - 1) * (d ^ (2 ^ k) + 1) := hmul

/-- The natural-number form of the previous lemma. -/
theorem nat_two_pow_dvd_odd {d : ℕ} (hd : Odd d) (hd1 : 1 ≤ d) (k : ℕ) (hk : 1 ≤ k) :
    2 ^ (k + 2) ∣ d ^ (2 ^ k) - 1 := by
  have h1 : 1 ≤ d ^ (2 ^ k) := Nat.one_le_pow _ _ (by omega)
  have hcast : ((d ^ (2 ^ k) - 1 : ℕ) : ℤ) = (d : ℤ) ^ (2 ^ k) - 1 := by
    push_cast [Nat.cast_sub h1]
    ring
  have hdZ : Odd ((d : ℤ)) := by
    obtain ⟨t, ht⟩ := hd
    exact ⟨(t : ℤ), by exact_mod_cast congrArg (fun x : ℕ => (x : ℤ)) ht⟩
  have hdvd := int_two_pow_dvd_odd hdZ k hk
  rw [← hcast] at hdvd
  exact_mod_cast hdvd

theorem rad_pow_eq {d m : ℕ} (hm : 0 < m) : rad (d ^ m) = rad d := by
  unfold rad
  rw [Nat.primeFactors_pow _ hm.ne']

/-- **The general hit family.**  Fix an odd base `d ≥ 3` and an exponent `k` with `d ≤ 2 ^ k`.
Then the `A`-spine node with parameter `n = d ^ (2 ^ k) - 1` is an `abc` hit.

The mechanism is the classical one behind `abc` hits: `n = d ^ (2 ^ k) - 1` is divisible by the
large power `2 ^ (k+2)` while `n + 1` is a pure power of `d`, so the even leg `b = 2n(n+1)` has
a radical smaller than its size by a factor `≈ 2 ^ k / rad d`. -/
theorem spine_family_hit_base {d k n : ℕ} (hd : Odd d) (hd3 : 3 ≤ d) (hk : 1 ≤ k)
    (hdk : d ≤ 2 ^ k) (hn : n + 1 = d ^ (2 ^ k)) :
    1 < quality (2 * n + 1) (2 * n * (n + 1)) (2 * n ^ 2 + 2 * n + 1) := by
  -- `n` is large
  have hn8 : 8 ≤ n := by
    have h2k : (2 : ℕ) ≤ 2 ^ k := by
      calc (2 : ℕ) = 2 ^ 1 := by norm_num
        _ ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) hk
    have : (9 : ℕ) ≤ d ^ (2 ^ k) := by
      calc (9 : ℕ) = 3 ^ 2 := by norm_num
        _ ≤ d ^ 2 := Nat.pow_le_pow_left hd3 2
        _ ≤ d ^ (2 ^ k) := Nat.pow_le_pow_right (by omega) h2k
    omega
  -- the radical of `n + 1` is the radical of the base
  have hradn1 : rad (n + 1) = rad d := by
    rw [hn]
    exact rad_pow_eq (by positivity)
  have hradd : rad d ≤ 2 ^ k := le_trans (rad_le_self (by omega)) hdk
  -- the radical of `n` is small: `2 ^ (k+1) · rad n ≤ n`
  have hsmall : 2 ^ (k + 1) * rad n ≤ n := by
    have hdvd : 2 ^ (k + 2) ∣ n := by
      have hd' := nat_two_pow_dvd_odd hd (by omega) k hk
      have hne : n = d ^ (2 ^ k) - 1 := by omega
      rw [hne]; exact hd'
    have hkey := rad_mul_pow_le (p := 2) (s := k + 2) (n := n) (by norm_num) (by omega) hdvd
      (by omega)
    have he : k + 2 - 1 = k + 1 := by omega
    rw [he] at hkey
    calc 2 ^ (k + 1) * rad n = rad n * 2 ^ (k + 1) := by ring
      _ ≤ n := hkey
  -- verify the hit criterion
  refine spine_hit_criterion n (by omega) ?_
  have hstep : 2 * (rad n * rad (n + 1)) ≤ n := by
    calc 2 * (rad n * rad (n + 1)) = 2 * (rad n * rad d) := by rw [hradn1]
      _ ≤ 2 * (rad n * 2 ^ k) := by
          exact Nat.mul_le_mul_left _ (Nat.mul_le_mul_left _ hradd)
      _ = 2 ^ (k + 1) * rad n := by ring
      _ ≤ n := hsmall
  calc (2 * n + 1) * (2 * (rad n * rad (n + 1))) ≤ (2 * n + 1) * n :=
        Nat.mul_le_mul_left _ hstep
    _ < 2 * n ^ 2 + 2 * n + 1 := by nlinarith

/-- **The base-`3` hit family**: for `n + 1 = 3 ^ (2 ^ k)` with `k ≥ 2`, the `A`-spine node with
parameter `n` has quality `> 1`. -/
theorem spine_family_hit (k n : ℕ) (hk : 2 ≤ k) (hn : n + 1 = 3 ^ (2 ^ k)) :
    1 < quality (2 * n + 1) (2 * n * (n + 1)) (2 * n ^ 2 + 2 * n + 1) := by
  have hdk : (3 : ℕ) ≤ 2 ^ k := by
    calc (3 : ℕ) ≤ 2 ^ 2 := by norm_num
      _ ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) hk
  exact spine_family_hit_base (by decide) (by norm_num) (by omega) hdk hn

/-- **Infinitely many nodes of the Berggren tree are `abc` hits**, and this holds along a family
attached to *every* odd base `d ≥ 3`: for every bound `N` there is a tree node with hypotenuse
`> N`, quality `> 1`, and spine parameter `n` with `n + 1` a power of `d`. -/
theorem infinitely_many_abc_hits_base {d : ℕ} (hd : Odd d) (hd3 : 3 ≤ d) (N : ℕ) :
    ∃ a b c : ℕ, IsTreeNode a b c ∧ N < c ∧ 1 < quality a b c := by
  obtain ⟨k, hk1, hkd, hkN⟩ : ∃ k : ℕ, 1 ≤ k ∧ d ≤ 2 ^ k ∧ N < 2 ^ k :=
    ⟨d + N + 1, by omega, le_of_lt (lt_of_le_of_lt (by omega) Nat.lt_two_pow_self),
      lt_of_le_of_lt (by omega) Nat.lt_two_pow_self⟩
  set n := d ^ (2 ^ k) - 1 with hndef
  have h1 : 1 ≤ d ^ (2 ^ k) := Nat.one_le_pow _ _ (by omega)
  have hn : n + 1 = d ^ (2 ^ k) := by omega
  have hbig : 2 ^ k < d ^ (2 ^ k) := by
    calc 2 ^ k < 2 ^ (2 ^ k) := Nat.pow_lt_pow_right (by norm_num) Nat.lt_two_pow_self
      _ ≤ d ^ (2 ^ k) := Nat.pow_le_pow_left (by omega) _
  have hnN : N < n := by omega
  have hn8 : 8 ≤ n := by
    have h2k : (2 : ℕ) ≤ 2 ^ k := by
      calc (2 : ℕ) = 2 ^ 1 := by norm_num
        _ ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) hk1
    have : (9 : ℕ) ≤ d ^ (2 ^ k) := by
      calc (9 : ℕ) = 3 ^ 2 := by norm_num
        _ ≤ d ^ 2 := Nat.pow_le_pow_left hd3 2
        _ ≤ d ^ (2 ^ k) := Nat.pow_le_pow_right (by omega) h2k
    omega
  refine ⟨2 * n + 1, 2 * n * (n + 1), 2 * n ^ 2 + 2 * n + 1, ?_, by nlinarith, ?_⟩
  · exact spine_isTreeNode n (by omega)
  · exact spine_family_hit_base hd hd3 hk1 hkd hn

/-- **Infinitely many nodes of the Berggren tree are `abc` hits.**  For every bound `N` there is
a tree node with hypotenuse `> N` and quality `> 1`. -/
theorem infinitely_many_abc_hits (N : ℕ) :
    ∃ a b c : ℕ, IsTreeNode a b c ∧ N < c ∧ 1 < quality a b c :=
  infinitely_many_abc_hits_base (d := 3) (by decide) (by norm_num) N

/-! ## 9. Explicit points of the spectrum -/

/-- Peeling off one prime power from a radical. -/
theorem rad_pow_mul {p t m : ℕ} (hp : p.Prime) (ht : 0 < t) (hm : 0 < m)
    (hcop : Nat.Coprime (p ^ t) m) : rad (p ^ t * m) = p * rad m := by
  rw [rad_mul_coprime hcop (pow_pos hp.pos t) hm, rad_prime_pow hp ht]

/-- A rational threshold for the quality, in purely arithmetic terms. -/
theorem ratio_lt_quality_iff {a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 2 ≤ c)
    (h2 : 2 ≤ a * b * c) (m k : ℕ) (hk : 0 < k) :
    ((m : ℝ) / k < quality a b c) ↔ (rad (a * b * c)) ^ m < c ^ (2 * k) := by
  have hlog := log_rad_pos h2
  have hr0 : (0 : ℝ) < ((rad (a * b * c) : ℕ) : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hcR : (0 : ℝ) < (c : ℝ) := by positivity
  rw [quality_eq ha hb (by omega), div_lt_div_iff₀ hkR hlog]
  have hL : (m : ℝ) * Real.log ((rad (a * b * c) : ℕ) : ℝ)
      = Real.log (((rad (a * b * c) : ℕ) : ℝ) ^ m) := by rw [Real.log_pow]
  have hR : Real.log ((c : ℝ) ^ 2) * k = Real.log ((c : ℝ) ^ (2 * k)) := by
    rw [Real.log_pow, Real.log_pow]
    push_cast
    ring
  rw [hL, hR, Real.log_lt_log_iff (by positivity) (by positivity)]
  constructor
  · intro h; exact_mod_cast h
  · intro h; exact_mod_cast h

/-- Quality below `1` in purely arithmetic terms. -/
theorem quality_lt_one_iff {a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 2 ≤ c)
    (h2 : 2 ≤ a * b * c) : quality a b c < 1 ↔ c ^ 2 < rad (a * b * c) := by
  have hlog := log_rad_pos h2
  have hr0 : (0 : ℝ) < ((rad (a * b * c) : ℕ) : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
  rw [quality_eq ha hb (by omega), div_lt_one hlog,
    Real.log_lt_log_iff (by positivity) hr0]
  constructor
  · intro h; exact_mod_cast h
  · intro h; exact_mod_cast h

/-! ### Radicals of a few explicit nodes -/

theorem rad_root : rad (3 * 4 * 5) = 30 := by
  have e : (3 * 4 * 5 : ℕ) = 2 ^ 2 * (3 ^ 1 * 5 ^ 1) := by norm_num
  have h1 : rad (2 ^ 2 * (3 ^ 1 * 5 ^ 1)) = 2 * rad (3 ^ 1 * 5 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h2 : rad (3 ^ 1 * 5 ^ 1) = 3 * rad (5 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h3 : rad (5 ^ 1) = 5 := rad_prime_pow (by norm_num) (by norm_num)
  rw [e, h1, h2, h3]

theorem rad_5_12_13 : rad (5 * 12 * 13) = 390 := by
  have e : (5 * 12 * 13 : ℕ) = 2 ^ 2 * (3 ^ 1 * (5 ^ 1 * 13 ^ 1)) := by norm_num
  have h1 : rad (2 ^ 2 * (3 ^ 1 * (5 ^ 1 * 13 ^ 1))) = 2 * rad (3 ^ 1 * (5 ^ 1 * 13 ^ 1)) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h2 : rad (3 ^ 1 * (5 ^ 1 * 13 ^ 1)) = 3 * rad (5 ^ 1 * 13 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h3 : rad (5 ^ 1 * 13 ^ 1) = 5 * rad (13 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h4 : rad (13 ^ 1) = 13 := rad_prime_pow (by norm_num) (by norm_num)
  rw [e, h1, h2, h3, h4]

theorem rad_7_24_25 : rad (7 * 24 * 25) = 210 := by
  have e : (7 * 24 * 25 : ℕ) = 2 ^ 3 * (3 ^ 1 * (5 ^ 2 * 7 ^ 1)) := by norm_num
  have h1 : rad (2 ^ 3 * (3 ^ 1 * (5 ^ 2 * 7 ^ 1))) = 2 * rad (3 ^ 1 * (5 ^ 2 * 7 ^ 1)) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h2 : rad (3 ^ 1 * (5 ^ 2 * 7 ^ 1)) = 3 * rad (5 ^ 2 * 7 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h3 : rad (5 ^ 2 * 7 ^ 1) = 5 * rad (7 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h4 : rad (7 ^ 1) = 7 := rad_prime_pow (by norm_num) (by norm_num)
  rw [e, h1, h2, h3, h4]

theorem rad_105_88_137 : rad (105 * 88 * 137) = 316470 := by
  have e : (105 * 88 * 137 : ℕ) = 2 ^ 3 * (3 ^ 1 * (5 ^ 1 * (7 ^ 1 * (11 ^ 1 * 137 ^ 1)))) := by
    norm_num
  have h1 : rad (2 ^ 3 * (3 ^ 1 * (5 ^ 1 * (7 ^ 1 * (11 ^ 1 * 137 ^ 1)))))
      = 2 * rad (3 ^ 1 * (5 ^ 1 * (7 ^ 1 * (11 ^ 1 * 137 ^ 1)))) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h2 : rad (3 ^ 1 * (5 ^ 1 * (7 ^ 1 * (11 ^ 1 * 137 ^ 1))))
      = 3 * rad (5 ^ 1 * (7 ^ 1 * (11 ^ 1 * 137 ^ 1))) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h3 : rad (5 ^ 1 * (7 ^ 1 * (11 ^ 1 * 137 ^ 1))) = 5 * rad (7 ^ 1 * (11 ^ 1 * 137 ^ 1)) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h4 : rad (7 ^ 1 * (11 ^ 1 * 137 ^ 1)) = 7 * rad (11 ^ 1 * 137 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h5 : rad (11 ^ 1 * 137 ^ 1) = 11 * rad (137 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h6 : rad (137 ^ 1) = 137 := rad_prime_pow (by norm_num) (by norm_num)
  rw [e, h1, h2, h3, h4, h5, h6]

theorem rad_record : rad (36207 * 18424 * 40625) = 19118190 := by
  have e : (36207 * 18424 * 40625 : ℕ)
      = 2 ^ 3 * (3 ^ 5 * (5 ^ 5 * (7 ^ 2 * (13 ^ 1 * (47 ^ 1 * 149 ^ 1))))) := by norm_num
  have h1 : rad (2 ^ 3 * (3 ^ 5 * (5 ^ 5 * (7 ^ 2 * (13 ^ 1 * (47 ^ 1 * 149 ^ 1))))))
      = 2 * rad (3 ^ 5 * (5 ^ 5 * (7 ^ 2 * (13 ^ 1 * (47 ^ 1 * 149 ^ 1))))) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h2 : rad (3 ^ 5 * (5 ^ 5 * (7 ^ 2 * (13 ^ 1 * (47 ^ 1 * 149 ^ 1)))))
      = 3 * rad (5 ^ 5 * (7 ^ 2 * (13 ^ 1 * (47 ^ 1 * 149 ^ 1)))) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h3 : rad (5 ^ 5 * (7 ^ 2 * (13 ^ 1 * (47 ^ 1 * 149 ^ 1))))
      = 5 * rad (7 ^ 2 * (13 ^ 1 * (47 ^ 1 * 149 ^ 1))) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h4 : rad (7 ^ 2 * (13 ^ 1 * (47 ^ 1 * 149 ^ 1))) = 7 * rad (13 ^ 1 * (47 ^ 1 * 149 ^ 1)) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h5 : rad (13 ^ 1 * (47 ^ 1 * 149 ^ 1)) = 13 * rad (47 ^ 1 * 149 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h6 : rad (47 ^ 1 * 149 ^ 1) = 47 * rad (149 ^ 1) :=
    rad_pow_mul (by norm_num) (by norm_num) (by norm_num) (by norm_num)
  have h7 : rad (149 ^ 1) = 149 := rad_prime_pow (by norm_num) (by norm_num)
  rw [e, h1, h2, h3, h4, h5, h6, h7]

/-! ### The explicit nodes themselves -/

theorem isTreeNode_root : IsTreeNode 3 4 5 := ⟨[], by norm_num [applyPath]⟩

theorem isTreeNode_5_12_13 : IsTreeNode 5 12 13 :=
  ⟨[BerggrenStep.A], by decide⟩

theorem isTreeNode_7_24_25 : IsTreeNode 7 24 25 :=
  ⟨[BerggrenStep.A, BerggrenStep.A], by decide⟩

theorem isTreeNode_105_88_137 : IsTreeNode 105 88 137 :=
  ⟨[BerggrenStep.A, BerggrenStep.A, BerggrenStep.B], by decide⟩

theorem isTreeNode_record : IsTreeNode 36207 18424 40625 :=
  ⟨[BerggrenStep.C, BerggrenStep.C, BerggrenStep.C, BerggrenStep.A, BerggrenStep.C,
    BerggrenStep.C, BerggrenStep.B, BerggrenStep.C], by decide⟩

/-- The root `(3,4,5)` is *not* an `abc` hit: its quality is `< 1`. -/
theorem quality_root_lt_one : quality 3 4 5 < 1 := by
  have h := quality_lt_one_iff (a := 3) (b := 4) (c := 5) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num)
  rw [h, rad_root]
  norm_num

/-- `(5,12,13)` is not an `abc` hit. -/
theorem quality_5_12_13_lt_one : quality 5 12 13 < 1 := by
  have h := quality_lt_one_iff (a := 5) (b := 12) (c := 13) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num)
  rw [h, rad_5_12_13]
  norm_num

/-- Its `A`-child `(7,24,25)` *is* an `abc` hit. -/
theorem quality_7_24_25_gt_one : 1 < quality 7 24 25 := by
  have h := one_lt_quality_iff (a := 7) (b := 24) (c := 25) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num)
  rw [h, rad_7_24_25]
  norm_num

/-- The `B`-child `(105,88,137)` of `(7,24,25)` is again not a hit. -/
theorem quality_105_88_137_lt_one : quality 105 88 137 < 1 := by
  have h := quality_lt_one_iff (a := 105) (b := 88) (c := 137) (by norm_num) (by norm_num)
    (by norm_num) (by norm_num)
  rw [h, rad_105_88_137]
  norm_num

/-- **The tree's high-quality region is nonempty well above the hit threshold**: the node
`(36207, 18424, 40625)` (path `CCCACCBC` from the root) has quality `> 5/4`. -/
theorem quality_record_gt_five_fourths : (5 : ℝ) / 4 < quality 36207 18424 40625 := by
  have h := ratio_lt_quality_iff (a := 36207) (b := 18424) (c := 40625) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) 5 4 (by norm_num)
  have hcast : ((5 : ℕ) : ℝ) / ((4 : ℕ) : ℝ) = (5 : ℝ) / 4 := by norm_num
  rw [hcast] at h
  rw [h, rad_record]
  norm_num

/-- **Quality is not monotone under Berggren descent.**  Along the edge `(5,12,13) → (7,24,25)`
the quality crosses *above* the hit threshold `1`, while along the edge
`(7,24,25) → (105,88,137)` it crosses back *below* it.  So the `abc` quality is neither
increasing nor decreasing along the tree's descent operators. -/
theorem quality_not_monotone :
    (quality 5 12 13 < 1 ∧ 1 < quality 7 24 25) ∧
      (1 < quality 7 24 25 ∧ quality 105 88 137 < 1) :=
  ⟨⟨quality_5_12_13_lt_one, quality_7_24_25_gt_one⟩,
    ⟨quality_7_24_25_gt_one, quality_105_88_137_lt_one⟩⟩

/-! ## 10. The conditional "tree `abc` theorem" -/

/-- **Tree `abc` theorem (conditional).**  Under the effective integral `abc` bound
`Beal.ABCBound K` of the catalog, every Pythagorean `abc` triple whose hypotenuse satisfies
`K ≤ c ^ 4` has quality at most `13/10`; in particular the ceiling `2` is beaten with the
explicit gap `ε = 7/10`.  Only the finitely many nodes with `c ^ 4 < K` escape the bound. -/
theorem quality_le_of_abcBound {K : ℕ} (hK : ABCBound K) {a b c : ℕ}
    (ha : 0 < a) (hb : 0 < b) (hc : 2 ≤ c) (hsq : a ^ 2 + b ^ 2 = c ^ 2)
    (hcop : Nat.Coprime a b) (hbig : K ≤ c ^ 4) : quality a b c ≤ 13 / 10 := by
  have h2 : 2 ≤ a * b * c := by
    have : 1 * 1 * 2 ≤ a * b * c := Nat.mul_le_mul (Nat.mul_le_mul ha hb) hc
    omega
  have hcpos : 0 < c := by omega
  -- apply the `abc` bound to `a² + b² = c²`
  have habc := hK (a ^ 2) (b ^ 2) (c ^ 2) (by positivity) (by positivity) hsq (hcop.pow 2 2)
  rw [rad_sq_triple ha hb hcpos] at habc
  set R := rad (a * b * c) with hR
  -- `c ^ 24 ≤ K * R ^ 13 ≤ c ^ 4 * R ^ 13`
  have h24 : c ^ 24 ≤ c ^ 4 * R ^ 13 := by
    calc c ^ 24 = (c ^ 2) ^ 12 := by ring
      _ ≤ K * R ^ 13 := habc
      _ ≤ c ^ 4 * R ^ 13 := Nat.mul_le_mul_right _ hbig
  have h20 : c ^ 20 ≤ R ^ 13 := by
    have hcancel : c ^ 4 * c ^ 20 ≤ c ^ 4 * R ^ 13 := by
      calc c ^ 4 * c ^ 20 = c ^ 24 := by ring
        _ ≤ c ^ 4 * R ^ 13 := h24
    exact Nat.le_of_mul_le_mul_left hcancel (by positivity)
  -- take logarithms
  have hlog := log_rad_pos h2
  have hcR : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hcpos
  have hlogc : 0 ≤ Real.log (c : ℝ) := Real.log_nonneg (by exact_mod_cast (by omega : 1 ≤ c))
  have hRR : ((c : ℝ)) ^ 20 ≤ ((R : ℕ) : ℝ) ^ 13 := by exact_mod_cast h20
  have hlogle : 20 * Real.log (c : ℝ) ≤ 13 * Real.log ((R : ℕ) : ℝ) := by
    have h := Real.log_le_log (by positivity) hRR
    rwa [Real.log_pow, Real.log_pow, Nat.cast_ofNat, Nat.cast_ofNat] at h
  rw [quality_eq_two_mul ha hb hcpos, div_le_iff₀ hlog]
  linarith

/-- The same statement, specialised to nodes of the Berggren tree. -/
theorem tree_abc_theorem {K : ℕ} (hK : ABCBound K) {a b c : ℕ} (h : IsTreeNode a b c)
    (hbig : K ≤ c ^ 4) : quality a b c ≤ 13 / 10 := by
  obtain ⟨ha, hb, hc, hsq, hcop⟩ := h.basic
  exact quality_le_of_abcBound hK (by omega) (by omega) (by omega) hsq hcop hbig

/-! ## 11. Silver-ratio growth along the `B`-spine -/

/-- The square of the silver ratio, `(1 + √2)² = 3 + 2√2`, which governs the growth of the
Pell branch of the tree. -/
noncomputable def silver : ℝ := 3 + 2 * Real.sqrt 2

theorem silver_eq_sq : silver = (1 + Real.sqrt 2) ^ 2 := by
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  unfold silver
  nlinarith [h]

theorem sqrt_two_ge : (1.4 : ℝ) ≤ Real.sqrt 2 := by
  have h : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  nlinarith [Real.sqrt_nonneg 2, h]

/-- The `B`-spine of the tree: iterate the `B` step from the root. -/
def bNode : ℕ → ℤ × ℤ × ℤ
  | 0 => (3, 4, 5)
  | n + 1 => applyStep BerggrenStep.B (bNode n)

theorem bNode_eq_applyPath (n : ℕ) : bNode n = applyPath (List.replicate n BerggrenStep.B) := by
  induction n with
  | zero => simp [bNode]
  | succ n ih => rw [List.replicate_succ', applyPath_concat, ← ih]; rfl

/-- The hypotenuses along the `B`-spine are exactly the Pell sequence `bHyp`, and the sum of the
legs is the associated companion sequence. -/
theorem bNode_hyp (n : ℕ) :
    (bNode n).2.2 = bHyp n ∧ 2 * ((bNode n).1 + (bNode n).2.1) = bHyp (n + 1) - 3 * bHyp n := by
  induction n with
  | zero => exact ⟨rfl, by decide⟩
  | succ n ih =>
      obtain ⟨h1, h2⟩ := ih
      have hb : bNode (n + 1)
          = bergB (bNode n).1 (bNode n).2.1 (bNode n).2.2 := rfl
      have hrec := bHyp_recurrence n
      have hrec2 := bHyp_recurrence (n + 1)
      rw [hb]
      simp only [bergB]
      exact ⟨by linarith, by linarith⟩

/-- Every `B`-spine triple is a node of the tree. -/
theorem isTreeNode_of_path (p : List BerggrenStep) :
    IsTreeNode (applyPath p).1.toNat (applyPath p).2.1.toNat (applyPath p).2.2.toNat := by
  obtain ⟨ha, hb, hac, hbc, _, _⟩ := treeInv_applyPath p
  refine ⟨p, ?_⟩
  have h1 : ((applyPath p).1.toNat : ℤ) = (applyPath p).1 := Int.toNat_of_nonneg (by omega)
  have h2 : ((applyPath p).2.1.toNat : ℤ) = (applyPath p).2.1 := Int.toNat_of_nonneg (by omega)
  have h3 : ((applyPath p).2.2.toNat : ℤ) = (applyPath p).2.2 := Int.toNat_of_nonneg (by omega)
  rw [h1, h2, h3]

theorem bHyp_pos (n : ℕ) : 0 < bHyp n := by
  induction n with
  | zero => decide
  | succ n ih => exact lt_trans ih (bHyp_increasing n)

/-- The Pell recursion grows at least geometrically with ratio `5`. -/
theorem bHyp_five_mul_le (n : ℕ) : 5 * bHyp n ≤ bHyp (n + 1) := by
  cases n with
  | zero => decide
  | succ n =>
      have hrec := bHyp_recurrence n
      have hinc := bHyp_increasing n
      linarith

theorem bHyp_ge_pow (n : ℕ) : (5 : ℤ) ^ (n + 1) ≤ bHyp n := by
  induction n with
  | zero => decide
  | succ n ih =>
      calc (5 : ℤ) ^ (n + 1 + 1) = 5 * 5 ^ (n + 1) := by ring
        _ ≤ 5 * bHyp n := by linarith
        _ ≤ bHyp (n + 1) := bHyp_five_mul_le n

/-- The Pell recursion grows at most with the silver ratio squared. -/
theorem bHyp_ratio_le (n : ℕ) : (bHyp (n + 1) : ℝ) ≤ silver * (bHyp n : ℝ) := by
  induction n with
  | zero =>
      have h := sqrt_two_ge
      have : ((bHyp 1 : ℤ) : ℝ) = 29 := by norm_num [bHyp]
      rw [this]
      have h0 : ((bHyp 0 : ℤ) : ℝ) = 5 := by norm_num [bHyp]
      rw [h0, silver]
      linarith
  | succ n ih =>
      have hrec : (bHyp (n + 2) : ℝ) = 6 * (bHyp (n + 1) : ℝ) - (bHyp n : ℝ) := by
        have := bHyp_recurrence n
        exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) this
      have hs : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
      have hsq2 : (1.4 : ℝ) ≤ Real.sqrt 2 := sqrt_two_ge
      have hpos : (0 : ℝ) < (bHyp (n + 1) : ℝ) := by exact_mod_cast bHyp_pos (n + 1)
      rw [hrec, silver] at *
      nlinarith [ih, hpos, hs, hsq2]

/-- **Silver-ratio growth law of the `B`-spine**: the depth-`n` Pell node has hypotenuse
between `5 ^ (n+1)` and `5 · (3 + 2√2) ^ n`. -/
theorem bHyp_bounds (n : ℕ) : (5 : ℤ) ^ (n + 1) ≤ bHyp n ∧ (bHyp n : ℝ) ≤ 5 * silver ^ n := by
  refine ⟨bHyp_ge_pow n, ?_⟩
  induction n with
  | zero => norm_num [bHyp]
  | succ n ih =>
      have hsil : (0 : ℝ) < silver := by
        have := sqrt_two_ge; unfold silver; linarith
      calc (bHyp (n + 1) : ℝ) ≤ silver * (bHyp n : ℝ) := bHyp_ratio_le n
        _ ≤ silver * (5 * silver ^ n) := by
            exact mul_le_mul_of_nonneg_left ih hsil.le
        _ = 5 * silver ^ (n + 1) := by ring

/-- The defining identity of the quality, in cleared-denominator form. -/
theorem quality_mul_log_rad {a b c : ℕ} (ha : 3 ≤ a) (hb : 3 ≤ b) (hc : 5 ≤ c) :
    quality a b c * Real.log ((rad (a * b * c) : ℕ) : ℝ) = 2 * Real.log (c : ℝ) := by
  have h2 : 2 ≤ a * b * c := by
    have : 3 * 3 * 5 ≤ a * b * c := Nat.mul_le_mul (Nat.mul_le_mul ha hb) hc
    omega
  have hlog := log_rad_pos h2
  rw [quality_eq_two_mul (by omega) (by omega) (by omega)]
  field_simp

/-- **The depth-`n` quality law along the Pell branch.**  The depth-`n` `B`-spine node is a tree
node; its quality `q` satisfies the exact identity `q · log (rad abc) = 2 log c` with
`5 ^ (n+1) ≤ c ≤ 5 · (3 + 2√2) ^ n`, and `q > 2/3`. -/
theorem bSpine_quality_law (n : ℕ) :
    ∃ a b c : ℕ, IsTreeNode a b c ∧ (c : ℤ) = bHyp n ∧
      2 / 3 < quality a b c ∧
      quality a b c * Real.log ((rad (a * b * c) : ℕ) : ℝ) = 2 * Real.log (c : ℝ) ∧
      (5 : ℝ) ^ (n + 1) ≤ (c : ℝ) ∧ (c : ℝ) ≤ 5 * silver ^ n := by
  set p := List.replicate n BerggrenStep.B with hp
  refine ⟨(applyPath p).1.toNat, (applyPath p).2.1.toNat, (applyPath p).2.2.toNat,
    isTreeNode_of_path p, ?_, ?_, ?_, ?_, ?_⟩
  · obtain ⟨_, _, _, hbc, _, _⟩ := treeInv_applyPath p
    have h3 : ((applyPath p).2.2.toNat : ℤ) = (applyPath p).2.2 := Int.toNat_of_nonneg (by omega)
    rw [h3, ← bNode_eq_applyPath n]
    exact (bNode_hyp n).1
  · exact tree_quality_gt_two_thirds (isTreeNode_of_path p)
  · obtain ⟨ha, hb, hc, _, _⟩ := (isTreeNode_of_path p).basic
    exact quality_mul_log_rad ha hb hc
  · obtain ⟨_, _, _, hbc, _, _⟩ := treeInv_applyPath p
    have h3 : ((applyPath p).2.2.toNat : ℤ) = (applyPath p).2.2 := Int.toNat_of_nonneg (by omega)
    have hb := bHyp_ge_pow n
    have hz : ((applyPath p).2.2.toNat : ℤ) = bHyp n := by
      rw [h3, ← bNode_eq_applyPath n]; exact (bNode_hyp n).1
    have : ((5 : ℤ) ^ (n + 1) : ℤ) ≤ ((applyPath p).2.2.toNat : ℤ) := by rw [hz]; exact hb
    exact_mod_cast this
  · obtain ⟨_, _, _, hbc, _, _⟩ := treeInv_applyPath p
    have h3 : ((applyPath p).2.2.toNat : ℤ) = (applyPath p).2.2 := Int.toNat_of_nonneg (by omega)
    have hz : ((applyPath p).2.2.toNat : ℤ) = bHyp n := by
      rw [h3, ← bNode_eq_applyPath n]; exact (bNode_hyp n).1
    have hup := (bHyp_bounds n).2
    have hcast : (((applyPath p).2.2.toNat : ℕ) : ℝ) = ((bHyp n : ℤ) : ℝ) := by
      exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) hz
    rw [hcast]
    exact hup

end BerggrenABC